// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {Compare} from "./Compare.sol";

library SortBytes {
    function sort(bytes[] memory _arr) internal pure returns (bytes[] memory) {
        bytes[] memory copy = _copyBytesArray(_arr);
        if (copy.length > 0) quickSort(copy, 0, copy.length - 1);
        return copy;
    }

    function quickSort(
        bytes[] memory arr,
        uint256 left,
        uint256 right
    ) internal pure {
        if (left == right) return;

        uint256 i = left;
        uint256 j = right;
        bytes memory pivot = arr[left + (right - left) / 2];

        while (i <= j) {
            while (Compare.bytesLt(arr[i], pivot)) ++i;
            while (Compare.bytesGt(arr[j], pivot)) --j;
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

    function sortPair(bytes calldata _a, bytes calldata _b)
        public
        pure
        returns (bytes memory, bytes memory)
    {
        return (Compare.bytesLt(_a, _b)) ? (_a, _b) : (_b, _a);
    }

    function _copyBytesArray(bytes[] memory input)
        internal
        pure
        returns (bytes[] memory)
    {
        bytes[] memory output = new bytes[](input.length);
        for (uint256 i = 0; i < input.length; i++) {
            output[i] = input[i];
        }
        return output;
    }
}
