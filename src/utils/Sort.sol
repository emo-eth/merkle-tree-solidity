// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

library Sort {
    function sort(bytes32[] calldata arr)
        public
        pure
        returns (bytes32[] memory)
    {
        bytes32[] memory copy = arr[:];
        if (copy.length > 0) quickSort(copy, 0, copy.length - 1);
        return copy;
    }

    function quickSort(
        bytes32[] memory arr,
        uint256 left,
        uint256 right
    ) public pure {
        if (left == right) return;

        uint256 i = left;
        uint256 j = right;
        bytes32 pivot = arr[uint256(left + (right - left) / 2)];

        while (i <= j) {
            while (arr[i] < pivot) ++i;
            while (arr[j] > pivot) --j;
            if (i <= j) {
                (arr[i], arr[j]) = (arr[j], arr[i]);
                ++i;
                if (j == 0) break;
                --j;
            }
        }

        if (left < j) {
            quickSort(arr, left, j);
        }
        if (i < right) {
            quickSort(arr, i, right);
        }
    }

    function sortPair(bytes32 _a, bytes32 _b)
        public
        pure
        returns (bytes32, bytes32)
    {
        return (_a < _b) ? (_a, _b) : (_b, _a);
    }
}
