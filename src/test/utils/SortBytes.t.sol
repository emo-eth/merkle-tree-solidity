// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {SortBytes} from "../../utils/SortBytes.sol";
import {Compare} from "../../utils/Compare.sol";
import {DSTestPlus} from "@rari-capital/solmate/src/test/utils/DSTestPlus.sol";

contract TestSortBytes is DSTestPlus {
    uint8[] uint8a;
    uint8[] uint8b;
    bytes[] bytes32a;
    bytes[] bytes32b;

    function _toBytesArray(uint8[] memory _arr)
        internal
        pure
        returns (bytes[] memory)
    {
        bytes[] memory ret = new bytes[](_arr.length);
        for (uint256 i = 0; i < _arr.length; i++) {
            ret[i] = abi.encodePacked(_arr[i]);
        }
        return ret;
    }

    function arrayEq(bytes[] memory a, bytes[] memory b) internal {
        assertEq(a.length, b.length);
        for (uint256 i = 0; i < a.length; i++) {
            assertTrue(Compare.bytesEq(a[i], b[i]));
        }
    }

    function testSort() public {
        uint8a = [3, 2, 1];

        bytes[] memory a = _toBytesArray(uint8a);
        a = SortBytes.sort(a);
        uint8b = [1, 2, 3];
        bytes[] memory b = _toBytesArray(uint8b);
        arrayEq(a, b);

        uint8a = [3, 5, 0, 0, 1, 4];
        uint8b = [0, 0, 1, 3, 4, 5];
        a = _toBytesArray(uint8a);
        a = SortBytes.sort(a);
        b = _toBytesArray(uint8b);
        arrayEq(a, b);

        bytes32a = [
            abi.encode(
                0x3ac225168df54212a25c1c01fd35bebfea408fdac2e31ddd6f80a4bbf9a5f1cb
            ),
            abi.encode(
                0xb5553de315e0edf504d9150af82dafa5c4667fa618ed0a6f19c69b41166c5510
            ),
            abi.encode(
                0x0b42b6393c1f53060fe3ddbfcd7aadcca894465a5a438f69c87d790b2299b9b2
            ),
            abi.encode(
                0xf1918e8562236eb17adc8502332f4c9c82bc14e19bfc0aa10ab674ff75b3d2f3
            ),
            abi.encode(
                0xa8982c89d80987fb9a510e25981ee9170206be21af3c8e0eb312ef1d3382e761
            ),
            abi.encode(
                0xd1e8aeb79500496ef3dc2e57ba746a8315d048b7a664a2bf948db4fa91960483
            ),
            abi.encode(
                0x14bcc435f49d130d189737f9762feb25c44ef5b886bef833e31a702af6be4748
            ),
            abi.encode(
                0xa766932420cc6e9072394bef2c036ad8972c44696fee29397bd5e2c06001f615
            ),
            abi.encode(
                0xea00237ef11bd9615a3b6d2629f2c6259d67b19bb94947a1bd739bae3415141c
            ),
            abi.encode(
                0xb31d742db54d6961c6b346af2c9c4c495eb8aff2ebf6b3699e052d1cef5cf50b
            )
        ];
        bytes32b = [
            abi.encode(
                0x0b42b6393c1f53060fe3ddbfcd7aadcca894465a5a438f69c87d790b2299b9b2
            ),
            abi.encode(
                0x14bcc435f49d130d189737f9762feb25c44ef5b886bef833e31a702af6be4748
            ),
            abi.encode(
                0x3ac225168df54212a25c1c01fd35bebfea408fdac2e31ddd6f80a4bbf9a5f1cb
            ),
            abi.encode(
                0xa766932420cc6e9072394bef2c036ad8972c44696fee29397bd5e2c06001f615
            ),
            abi.encode(
                0xa8982c89d80987fb9a510e25981ee9170206be21af3c8e0eb312ef1d3382e761
            ),
            abi.encode(
                0xb31d742db54d6961c6b346af2c9c4c495eb8aff2ebf6b3699e052d1cef5cf50b
            ),
            abi.encode(
                0xb5553de315e0edf504d9150af82dafa5c4667fa618ed0a6f19c69b41166c5510
            ),
            abi.encode(
                0xd1e8aeb79500496ef3dc2e57ba746a8315d048b7a664a2bf948db4fa91960483
            ),
            abi.encode(
                0xea00237ef11bd9615a3b6d2629f2c6259d67b19bb94947a1bd739bae3415141c
            ),
            abi.encode(
                0xf1918e8562236eb17adc8502332f4c9c82bc14e19bfc0aa10ab674ff75b3d2f3
            )
        ];
        a = SortBytes.sort(a);
        arrayEq(a, b);
    }

    function testSortPair() public {
        bytes memory a = "a";
        bytes memory b = "b";
        (bytes memory ra, bytes memory rb) = SortBytes.sortPair(a, b);

        assertTrue(Compare.bytesEq(ra, a));

        assertTrue(Compare.bytesEq(rb, b));

        (ra, rb) = SortBytes.sortPair(b, a);

        assertTrue(Compare.bytesEq(ra, a));

        assertTrue(Compare.bytesEq(rb, b));
    }
}
