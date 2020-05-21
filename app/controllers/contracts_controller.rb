class ContractsController < ApplicationController
  def create
    # @contract = Contract.new(game_id: params[:game_id], **contract_params)
    @game = Game.find(params[:game_id])

    @game.signed_contracts.sign(@game.month, params[:name])

    if @game.save
      redirect_to @game, notice: 'Contract was successfully signed.'
    else
      redirect_to @game, alert: "Failed to sign the contract: #{@game.errors.messages}"
    end
  end

  def cancel
    @game = Game.find(params[:id])
    @game.signed_contracts.cancel(@game.month)

    if @game.save
      redirect_to @game, notice: 'Cooling off cancellation was successfully signed.'
    else
      redirect_to @game, alert: "Failed to make a cooling off cancellation: #{@game.errors.messages}"
    end
  end

  # Only allow a list of trusted parameters through.
  private def contract_params
    params.require(:contract).permit(:game_id, :name)
  end
end
