import React from "react"

const GFG = {
  GameContext: React.createContext(),

  currentMonth(month) {
    return [
      'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December'
    ][month % 12]
  },

  numberToCurrency(n) {
    return `$${n}K`;
  }
};

export default GFG;
