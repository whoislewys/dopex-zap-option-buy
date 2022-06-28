contract Aave_Zap_Polygon_V1_0_2 is ZapInBaseV3_1, ZapOutBaseV3_1 {
    using SafeERC20 for IERC20;

    uint256 private constant deadline =
        0xf000000000000000000000000000000000000000000000000000000000000000;

    uint256 private constant permitAllowance = 79228162514260000000000000000;

    address private constant wmaticTokenAddress =
        address(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270);

    //@dev targets must be Zaps (not tokens!!!)
    constructor(
        address[] memory targets,
        uint256 _goodwill,
        uint256 _affiliateSplit
    ) ZapBaseV2_1(_goodwill, _affiliateSplit) {
        approvedTargets[0xDef1C0ded9bec7F1a1670819833240f027b25EfF] = true;
        for (uint256 i = 0; i < targets.length; i++) {
            approvedTargets[targets[i]] = true;
        }
    }

    event zapIn(address sender, address token, uint256 tokensRec);
    event zapOut(address sender, address token, uint256 tokensRec);

    /**
    @notice This function deposits assets into aave with MATIC or ERC20 tokens
    @param fromToken The token used for entry (address(0) if MATIC)
    @param amountIn The amount of fromToken to invest
    @param aToken Address of the aToken
    @param minATokens The minimum acceptable quantity aTokens to receive. Reverts otherwise
    @param swapTarget Excecution target for the swap or zap
    @param swapData DEX or Zap data. Must swap to aToken underlying address
    @param affiliate Affiliate address
    @return aTokensRec Quantity of aTokens received
     */
    function ZapIn(
        address fromToken,
        uint256 amountIn,
        address aToken,
        uint256 minATokens,
        address swapTarget,
        bytes calldata swapData,
        address affiliate
    ) external payable stopInEmergency returns (uint256 aTokensRec) {
        uint256 toInvest = _pullTokens(fromToken, amountIn, affiliate, true);

        address toToken = getUnderlyingToken(aToken);

        uint256 tokensBought =
            _fillQuote(fromToken, toToken, toInvest, swapTarget, swapData);

        (aTokensRec) = enterAave(aToken, tokensBought, minATokens);

        emit zapIn(msg.sender, aToken, aTokensRec);
    }

    function enterAave(
        address aToken,
        uint256 underlyingAmount,
        uint256 minATokens
    ) internal returns (uint256 aTokensRec) {
        ILendingPool lendingPool = getLendingPool(aToken);

        address underlyingToken = getUnderlyingToken(aToken);

        uint256 initialBalance = IERC20(aToken).balanceOf(msg.sender);

        _approveToken(underlyingToken, address(lendingPool), underlyingAmount);

        lendingPool.deposit(underlyingToken, underlyingAmount, msg.sender, 151);

        aTokensRec = IERC20(aToken).balanceOf(msg.sender) - initialBalance;

        require(aTokensRec > minATokens, "High Slippage");
    }

    /**
    @notice This function withdraws assets from aave, receiving tokens or MATIC with permit
    @param fromToken The aToken being withdrawn
    @param amountIn The quantity of fromToken to withdraw
    @param toToken Address of the token to receive (0 address if MATIC)
    @param minToTokens The minimum acceptable quantity tokens to receive. Reverts otherwise
    @param permitSig Signature for permit
    @param swapTarget Excecution target for the swap or zap
    @param swapData DEX or Zap data
    @param affiliate Affiliate address
    @return tokensRec Quantity of aTokens received
     */
    function ZapOutWithPermit(
        address fromToken,
        uint256 amountIn,
        address toToken,
        uint256 minToTokens,
        bytes calldata permitSig,
        address swapTarget,
        bytes calldata swapData,
        address affiliate
    ) external stopInEmergency returns (uint256) {
        _permit(fromToken, permitAllowance, permitSig);

        return (
            ZapOut(
                fromToken,
                amountIn,
                toToken,
                minToTokens,
                swapTarget,
                swapData,
                affiliate
            )
        );
    }

    function _permit(
        address aToken,
        uint256 amountIn,
        bytes memory permitSig
    ) internal {
        require(permitSig.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(permitSig, 32))
            s := mload(add(permitSig, 64))
            v := byte(0, mload(add(permitSig, 96)))
        }
        IAToken(aToken).permit(
            msg.sender,
            address(this),
            amountIn,
            deadline,
            v,
            r,
            s
        );
    }

    /**
    @notice This function withdraws assets from aave, receiving tokens or MATIC
    @param fromToken The aToken being withdrawn
    @param amountIn The quantity of fromToken to withdraw
    @param toToken Address of the token to receive (0 address if MATIC)
    @param minToTokens The minimum acceptable quantity tokens to receive. Reverts otherwise
    @param swapTarget Excecution target for the swap or zap
    @param swapData DEX or Zap data
    @param affiliate Affiliate address
    @return tokensRec Quantity of aTokens received
     */
    function ZapOut(
        address fromToken,
        uint256 amountIn,
        address toToken,
        uint256 minToTokens,
        address swapTarget,
        bytes calldata swapData,
        address affiliate
    ) public stopInEmergency returns (uint256 tokensRec) {
        amountIn = _pullTokens(fromToken, amountIn);

        uint256 underlyingRec = exitAave(fromToken, amountIn);

        address underlyingToken = getUnderlyingToken(fromToken);

        tokensRec = _fillQuote(
            underlyingToken,
            toToken,
            underlyingRec,
            swapTarget,
            swapData
        );

        require(tokensRec >= minToTokens, "High Slippage");

        uint256 totalGoodwillPortion;

        if (toToken == address(0)) {
            totalGoodwillPortion = _subtractGoodwill(
                ETHAddress,
                tokensRec,
                affiliate,
                true
            );

            payable(msg.sender).transfer(tokensRec - totalGoodwillPortion);
        } else {
            totalGoodwillPortion = _subtractGoodwill(
                toToken,
                tokensRec,
                affiliate,
                true
            );

            IERC20(toToken).safeTransfer(
                msg.sender,
                tokensRec - totalGoodwillPortion
            );
        }

        tokensRec = tokensRec - totalGoodwillPortion;

        emit zapOut(msg.sender, toToken, tokensRec);
    }

    function exitAave(address aToken, uint256 aTokenAmount)
        internal
        returns (uint256 tokensRec)
    {
        address underlyingToken = getUnderlyingToken(aToken);

        ILendingPool lendingPool = getLendingPool(aToken);

        tokensRec = lendingPool.withdraw(
            underlyingToken,
            aTokenAmount,
            address(this)
        );
    }

    function _fillQuote(
        address fromToken,
        address toToken,
        uint256 _amount,
        address swapTarget,
        bytes memory swapData
    ) internal returns (uint256 amountBought) {
        if (fromToken == toToken) {
            return _amount;
        }

        if (fromToken == address(0) && toToken == wmaticTokenAddress) {
            IWETH(wmaticTokenAddress).deposit{ value: _amount }();
            return _amount;
        }

        if (fromToken == wmaticTokenAddress && toToken == address(0)) {
            IWETH(wmaticTokenAddress).withdraw(_amount);
            return _amount;
        }

        uint256 valueToSend;
        if (fromToken == address(0)) {
            valueToSend = _amount;
        } else {
            _approveToken(fromToken, swapTarget);
        }

        uint256 initialBalance = _getBalance(toToken);

        require(approvedTargets[swapTarget], "Target not Authorized");
        (bool success, ) = swapTarget.call{ value: valueToSend }(swapData);
        require(success, "Error Swapping Tokens");

        amountBought = _getBalance(toToken) - initialBalance;

        require(amountBought > 0, "Swapped To Invalid Intermediate");
    }

    function getUnderlyingToken(address aToken) public returns (address) {
        return IAToken(aToken).UNDERLYING_ASSET_ADDRESS();
    }

    function getLendingPool(address aToken) internal returns (ILendingPool) {
        return ILendingPool(IAToken(aToken).POOL());
    }
}
