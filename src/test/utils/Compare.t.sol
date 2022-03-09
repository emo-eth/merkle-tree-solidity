// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {Compare} from "../../utils/Compare.sol";
import {DSTestPlus} from "sm/test/utils/DSTestPlus.sol";

contract TestCompare is DSTestPlus {
    function testCompare() public {
        bytes memory a = "a";
        bytes memory b = "a";
        // same is 0
        assertEq(Compare.compareBytes(a, b), 0);
        b = "b";
        // lt is -1
        assertEq(Compare.compareBytes(a, b), -1);
        // gt is 1
        assertEq(Compare.compareBytes(b, a), 1);
        // longer is bigger
        b = "aa";
        assertEq(Compare.compareBytes(b, a), 1);
        // end character is bigger
        a = "ab";
        assertEq(Compare.compareBytes(a, b), 1);
        // start character is bigger
        a = "ba";
        assertEq(Compare.compareBytes(a, b), 1);
    }

    function testEq() public {
        bytes memory a = "a";
        bytes memory b = "a";
        assertTrue(Compare.bytesEq(a, b));
        b = "b";
        assertFalse(Compare.bytesEq(a, b));
        b = "aa";
        assertFalse(Compare.bytesEq(a, b));
        b = "ab";
        assertFalse(Compare.bytesEq(a, b));
        b = "ba";
        assertFalse(Compare.bytesEq(a, b));
        a = "ba";
        assertTrue(Compare.bytesEq(a, b));
    }

    function testLt() public {
        bytes memory a = "a";
        bytes memory b = "a";
        assertFalse(Compare.bytesLt(a, b));
        b = "b";
        assertTrue(Compare.bytesLt(a, b));
        b = "aa";
        assertTrue(Compare.bytesLt(a, b));
        a = "aa";
        b = "ab";
        assertTrue(Compare.bytesLt(a, b));
        b = "ba";
        assertTrue(Compare.bytesLt(a, b));
        a = "ba";
        assertFalse(Compare.bytesLt(a, b));
    }

    function testGt() public {
        bytes memory a = "a";
        bytes memory b = "a";
        assertFalse(Compare.bytesGt(a, b));
        b = "b";
        assertFalse(Compare.bytesGt(a, b));
        b = "aa";
        assertFalse(Compare.bytesGt(a, b));
        a = "aa";
        b = "ab";
        assertFalse(Compare.bytesGt(a, b));
        b = "ba";
        assertFalse(Compare.bytesGt(a, b));
        a = "ba";
        assertFalse(Compare.bytesGt(a, b));
    }

    function testLe() public {
        bytes memory a = "a";
        bytes memory b = "a";
        assertTrue(Compare.bytesLe(a, b));
        b = "b";
        assertTrue(Compare.bytesLe(a, b));
        b = "aa";
        assertTrue(Compare.bytesLe(a, b));
        a = "aa";
        b = "ab";
        assertTrue(Compare.bytesLe(a, b));
        b = "ba";
        assertTrue(Compare.bytesLe(a, b));
        a = "ba";
        assertTrue(Compare.bytesLe(a, b));
        a = "ca";
        assertFalse(Compare.bytesLe(a, b));
    }

    function testGe() public {
        bytes memory a = "a";
        bytes memory b = "a";
        assertTrue(Compare.bytesGe(a, b));
        b = "b";
        assertFalse(Compare.bytesGe(a, b));
        b = "aa";
        assertFalse(Compare.bytesGe(a, b));
        a = "aa";
        b = "ab";
        assertFalse(Compare.bytesGe(a, b));
        b = "ba";
        assertFalse(Compare.bytesGe(a, b));
        a = "ba";
        assertTrue(Compare.bytesGe(a, b));
    }
}
