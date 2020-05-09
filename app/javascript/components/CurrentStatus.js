import React from "react"
import PropTypes from "prop-types"

import GFG from '../gfg'

class CurrentStatus extends React.Component {
  render () {
    const moneyCol = (this.props.dept == 0) ? this.props.cash : 123
    return (
      <React.Fragment>
        <table>
          <tbody>
            <tr>
              <th><strong>Date</strong></th>
              <td>
                { GFG.currentMonth(this.props.month) } { 2020 + Math.floor(this.props.month / 12) }
              </td>
              <td></td>
            </tr>
            <tr>
              <th><strong>Money</strong></th>
              <td>
                {
                  (this.props.debt == 0)
                    ?  <b>{ GFG.numberToCurrency(this.props.cash) }</b>
                    : <span>
                      Cash: <b>{ GFG.numberToCurrency(this.props.cash) }</b><br/>
                      Debt: <b>{ GFG.numberToCurrency(this.props.debt) }</b><br/>
                      Total: <b>{ GFG.numberToCurrency(this.props.cash + this.props.debt) }</b>
                    </span>
                }
              </td>
              <td></td>
            </tr>
            <tr>
              <th><strong>Credit</strong></th>
              <td>{ this.props.credit }</td>
              <td></td>
            </tr>
            <tr>
              <th><strong>Storage</strong></th>
              <td>
                Size: { this.props.storage }t
                <br/>
                Ingredient: { this.props.ingredient }t (+ { this.props.ingredientSubscription }t)
                <br/>
                Product: { this.props.product }t
              </td>
              <td>
                🗄️
                <br/>
                📦
                <br/>
                <br/>
              </td>
            </tr>
            <tr>
              <th><strong>Idle Employees</strong></th>
              <td>
                {
                  React.Children.map(
                    [
                      ...Array(this.props.idleFactory.junior).fill('junior'),
                      ...Array(this.props.idleFactory.intermediate).fill('intermediate'),
                      ...Array(this.props.idleFactory.senior).fill('senior')
                    ],
                    (e) =>
                      <img src={`/images/employee-${e}.png`} width="16" title={e} />)
                }
              </td>
              <td>
                💼
              </td>
            </tr>
            <tr>
              <th><strong>Factories</strong></th>
              <td>
                { this.props.factoryNames.join(", ") }
              </td>
              <td>
                🏭
              </td>
            </tr>
            <tr>
              <th><strong>Contracts</strong></th>
              <td>
                { this.props.contractNames.join(", ") }
              </td>
              <td>
                📜
              </td>
            </tr>
          </tbody>
        </table>
      </React.Fragment>
    );
  }
}

CurrentStatus.propTypes = {
  month: PropTypes.number,
  cash: PropTypes.number,
  debt: PropTypes.number,
  credit: PropTypes.number,
  storage: PropTypes.number,
  ingredient: PropTypes.number,
  ingredientSubscription: PropTypes.number,
  product: PropTypes.number,
  idleFactory: PropTypes.object,
  factoryNames: PropTypes.array,
  contractNames: PropTypes.array,
};
export default CurrentStatus
