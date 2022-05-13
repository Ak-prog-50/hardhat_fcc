const { getPriceFeedAddr, getCoordinatorAddr } = require("../../utils/helpers")

const lotteryArgs = [
    getPriceFeedAddr(),
    getCoordinatorAddr(),
    50,
    4262
]

module.exports = lotteryArgs;