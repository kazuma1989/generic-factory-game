class Game < ApplicationRecord
  belongs_to :player
  has_many :factories
  has_many :contracts

  def history
    history_encoded ? JSON.parse(history_encoded).freeze : {}.freeze
  end

  def set_history(key, value)
    self.history_encoded = history.merge(key => value).to_json
  end

  def status
    if cash < 0
      :game_over
    elsif 1000 <= cash - debt
      :completed
    else
      :in_progress
    end
  end

  def current_month
    [
      'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December'
    ][month % 12]
  end

  def next_month
    [
      'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December'
    ][month.succ % 12]
  end

  def production
    factories.map(&:performance).sum / 2
  end

  def capped_production
    [production, ingredient / 2].min
  end

  def idle_factory
    Factory.where(game_id: id, name: 'idle').first or raise 'Must not happen'
  end

  def active_factories
    Factory.where(game_id: id).where.not(name: 'idle').all
  end

  # Similar to save()
  def hire(employee_type)
    factory = idle_factory()
    raise 'Must not happen' unless factory

    raise 'Must not happen' unless Employee::RECRUITING_FEES[employee_type]
    self.cash -= Employee::RECRUITING_FEES[employee_type]

    case employee_type
    when :junior
      factory.junior += 1
    when :intermediate
      factory.intermediate += 1
    when :senior
      factory.senior += 1
    else
      raise 'Must not happen'
    end
    save && factory.save
  end

  def salary
    factories.map {|factory|
      factory.junior * 3 + factory.intermediate * 5 + factory.senior * 9
    }.sum
  end

  def interest
    ((10 - credit / 10.0) * 0.01 * debt).ceil
  end

  # Like update(), it doesn't save.
  def settlement
    messages = []

    self.month += 1

    # produce
    production_vol = self.capped_production
    self.ingredient -= production_vol * 2
    messages << "🏭 Consume #{production_vol * 2}t ingredients" if 0 < production_vol
    messages << "🏭 Produce #{production_vol}t products" if 0 < production_vol

    # if self.ingredient + self.product + production_vol <= self.storage
    #   # good
    # else
    #   # pay penalty
    #   self.cash -= 10 * (self.ingredient + self.product + production_vol - self.storage)
    #   production_vol = self.storage - self.product - self.ingredient
    # end

    self.product += production_vol

    # Deliver products
    (delivery_total, sales_total, credit_total) = [0, 0, 0]
    self.contracts.each do |contract|
      (required_products, sales) = Contract::RULES[contract.name][self.current_month]
      if required_products <= self.product
        # good
        self.product -= required_products
        self.cash += sales

        delivery_total += required_products; sales_total += sales
        credit_total += 1
      else
        # penalty
        self.cash -= sales * 10
        credit_total -= 10

        messages << "⚠️ Products not enough"
        messages << "💸 Pay $#{sales * 10}K penalty for contract #{contract.name}"
      end
    end
    if 0 < delivery_total
      messages << "📜 Deliver #{delivery_total}t products"
      messages << "📜 Gain $#{sales_total}K sales"

      self.credit = self.class.normalize_credit(self.credit + credit_total)
      messages << "❤️ #{"++-"[credit_total <=> 0]}#{credit_total.abs} credit"
    end

    # pay fees
    self.cash -= self.storage / 100
    messages << "🗄️ Pay $#{self.storage / 100}K for storage" if 0 < storage

    self.cash -= self.salary
    messages << "💼 Pay $#{self.salary}K for salary" if 0 < salary

    self.cash -= self.interest
    messages << "🏦 Pay $#{self.interest}K for interest" if 0 < interest

    # receive ingredients
    self.ingredient += self.ingredient_subscription
    self.cash -= self.ingredient_subscription * 0.05
    messages << "📦 Receive #{self.ingredient_subscription}t ingredient" if 0 < self.ingredient_subscription
    messages << "📦 Pay $#{self.ingredient_subscription * 0.05}K for subscription" if 0 < self.ingredient_subscription

    # overflow
    if self.storage < self.ingredient + self.production
      diff = self.ingredient - (self.storage - self.production)
      messages << "🗑️ Dispose #{diff}t ingredient due to overflow"
      self.ingredient -= diff
    end
    messages << "💵 Cash balance $#{self.cash}K"

    messages
  end

  # Always between 0 to 100
  def self.normalize_credit(credit)
    [[0, credit].max, 100].min
  end

  def self.best_games(game_version)
    Game.
      includes(:player).
      where('version = ? AND 1000 <= cash', game_version).
      order(month: :asc)
  end
end
