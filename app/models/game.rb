class Game < ApplicationRecord
  belongs_to :player
  has_many :factories
  has_many :contracts

  def status
    case money
    when (...0)
      :game_over
    when 0..1000
      :in_progress
    when (1001..)
      :completed
    else
      raise 'Must not happen'
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
    ][month + 1 % 12]
  end

  def production
    factories.map(&:performance).sum / 2
  end

  # Similar to save()
  def hire(employee_type)
    factory = Factory.where(game_id: id, name: 'idle').first
    raise 'Must not happen' unless factory

    raise 'Must not happen' unless Employee::RECRUITING_FEES[employee_type]
    self.money -= Employee::RECRUITING_FEES[employee_type]

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
end
