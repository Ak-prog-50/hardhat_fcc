const { getPriceFeedAddr, getCoordinatorAddr, getLinkAddr } = require("../../utils/helpers")

const lotteryArgs = [
    getPriceFeedAddr(),
    getCoordinatorAddr(),
    50,
    0, // * This should be zero for local development and 4262 for rinkeby
]

module.exports = lotteryArgs;