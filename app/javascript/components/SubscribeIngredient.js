import React from "react"
import PropTypes from "prop-types"
class SubscribeIngredient extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      ingredientSubscription: this.props.ingredientSubscription,
    };
  }

  render () {
    const volBefore = this.props.ingredientSubscription
    const volAfter = this.state.ingredientSubscription
    const changeFee = Math.max((volAfter - volBefore) * 0.05, 0)
    // const maxVol = volBefore + this.props.cash / 0.05
    const maxVol = this.props.storage

    return (
      <React.Fragment>
        <div className="modal-body">
          <p>
            $1K for every 20t ingredients.
          </p>

          Current subscription: {this.props.ingredientSubscription}t ${this.props.ingredientSubscription * 0.05}K<br/>

          <input
          type="range" className="custom-range" id="form-range-subscribe-ingredient"
          name="ingredient_subscription" value={this.state.ingredientSubscription}
          min="0" max={maxVol} step="20"
          onChange={(event) =>
            this.setState({ingredientSubscription: event.target.value})
          }/>

          New subscription: {this.state.ingredientSubscription}t ${this.state.ingredientSubscription * 0.05}K<br/>
          Change fee: ${changeFee}K
        </div>
        <div className="modal-footer">
          <input type="submit" value="Subscribe" className="btn btn-primary" />
        </div>
      </React.Fragment>
    );
  }
}

SubscribeIngredient.propTypes = {
  cash: PropTypes.number,
  ingredientSubscription: PropTypes.number,
  storage: PropTypes.number,
};
export default SubscribeIngredient
