pragma solidity ^0.7.6;
pragma abicoder v2;

import {CustomUnstakedFeeModuleTest} from "./CustomUnstakedFeeModule.t.sol";

contract SetCustomUnstakedFeeTest is CustomUnstakedFeeModuleTest {
    function setUp() public override {
        super.setUp();

        vm.startPrank({msgSender: users.feeManager});
    }

    function test_RevertIf_NotManager() public {
        vm.expectRevert();
        changePrank({msgSender: users.charlie});
        customUnstakedFeeModule.setCustomFee({pool: address(1), fee: 50});
    }

    function test_RevertIf_FeeTooHigh() public {
        address pool = createAndCheckPool({
            factory: poolFactory,
            token0: TEST_TOKEN_0,
            token1: TEST_TOKEN_1,
            tickSpacing: TICK_SPACING_LOW
        });

        vm.expectRevert();
        customUnstakedFeeModule.setCustomFee({pool: pool, fee: 2001});
    }

    function test_RevertIf_NotPool() public {
        vm.expectRevert();
        customUnstakedFeeModule.setCustomFee({pool: address(1), fee: 50});
    }

    function test_SetCustomFee() public {
        address pool = createAndCheckPool({
            factory: poolFactory,
            token0: TEST_TOKEN_0,
            token1: TEST_TOKEN_1,
            tickSpacing: TICK_SPACING_LOW
        });

        vm.expectEmit(true, true, false, false, address(customUnstakedFeeModule));
        emit SetCustomFee({pool: pool, fee: 50});
        customUnstakedFeeModule.setCustomFee({pool: pool, fee: 50});

        assertEqUint(customUnstakedFeeModule.customFee(pool), 50);
        assertEqUint(customUnstakedFeeModule.getFee(pool), 50);
        assertEqUint(poolFactory.getUnstakedFee(pool), 50);

        // revert to default fee
        vm.expectEmit(true, true, false, false, address(customUnstakedFeeModule));
        emit SetCustomFee({pool: pool, fee: 0});
        customUnstakedFeeModule.setCustomFee({pool: pool, fee: 0});

        assertEqUint(customUnstakedFeeModule.customFee(pool), 0);
        assertEqUint(customUnstakedFeeModule.getFee(pool), 1_000);
        assertEqUint(poolFactory.getUnstakedFee(pool), 1_000);

        // zero fee
        vm.expectEmit(true, true, false, false, address(customUnstakedFeeModule));
        emit SetCustomFee({pool: pool, fee: 420});
        customUnstakedFeeModule.setCustomFee({pool: pool, fee: 420});

        assertEqUint(customUnstakedFeeModule.customFee(pool), 420);
        assertEqUint(customUnstakedFeeModule.getFee(pool), 0);
        assertEqUint(poolFactory.getUnstakedFee(pool), 0);
    }
}
