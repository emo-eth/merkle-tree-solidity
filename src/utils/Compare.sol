// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

library Compare {
    function compareBytes(bytes memory a, bytes memory b)
        internal
        pure
        returns (int256)
    {
        if (a.length == b.length) {
            for (uint256 i = 0; i < a.length; ++i) {
                if (a[i] == b[i]) {
                    continue;
                }
                return a[i] < b[i] ? int256(-1) : int256(1);
            }
            return 0;
        }

        return a.length < b.length ? int256(-1) : int256(1);
    }

    function bytesEq(bytes memory a, bytes memory b)
        internal
        pure
        returns (bool)
    {
        return compareBytes(a, b) == 0;
    }

    function bytesLt(bytes memory a, bytes memory b)
        internal
        pure
        returns (bool)
    {
        return compareBytes(a, b) < 0;
    }

    function bytesGt(bytes memory a, bytes memory b)
        internal
        pure
        returns (bool)
    {
        return compareBytes(a, b) > 0;
    }

    function bytesLe(bytes memory a, bytes memory b)
        internal
        pure
        returns (bool)
    {
        return compareBytes(a, b) <= 0;
    }

    function bytesGe(bytes memory a, bytes memory b)
        internal
        pure
        returns (bool)
    {
        return compareBytes(a, b) >= 0;
    }
}
