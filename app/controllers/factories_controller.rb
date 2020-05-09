class FactoriesController < ApplicationController
  # GET /factories/new
  def new
    @factory = Factory.new
    @game = Game.find(params[:game_id])
  end

  # POST /factories
  # POST /factories.json
  def create
    @factory = Factory.new(game_id: params[:game_id], **factory_params)
    @game = Game.find(params[:game_id])

    @game = Game.find(params[:game_id])
    @game.cash -= Factory::COST_TO_BUY[@factory.name.to_sym]

    if 0 <= @game.cash
      if @factory.save && @game.save
        redirect_to @game, notice: "Successfully built #{@factory.name.capitalize} Factory!"
      else
        render :new
      end
    else
      redirect_to @game, notice: "Not enough cash to build #{@factory.name.capitalize} Factory!"
    end
  end

  private
    # Only allow a list of trusted parameters through.
    def factory_params
      params.require(:factory).permit(:game_id, :name)
    end
end
