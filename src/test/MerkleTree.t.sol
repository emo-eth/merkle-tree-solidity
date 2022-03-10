// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {MerkleTree} from "..//MerkleTree.sol";
import {DSTestPlus} from "sm/test/utils/DSTestPlus.sol";
import {Compare} from "../utils/Compare.sol";

/**
    TODO: test for sortLeaves/sortPairs = false
 */
contract TestMerkleTree is DSTestPlus {
    MerkleTree test;

    string[] strings;
    bytes32[] _expectedProof;

    function testGetRootEvenNumberOfLeaves() public {
        strings = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"];

        bytes[] memory leaves = _mapStringToBytes(strings);

        test = new MerkleTree(leaves);
        assertEq(
            bytes32(test.getRoot()),
            bytes32(
                0x60219f87561939610b484575e45c6e81156a53b86d7cd16640d930d14f21758e
            )
        );
    }

    function testGetProofEvenNumberOfLeaves() public {
        _expectedProof = [
            bytes32(
                0xa8982c89d80987fb9a510e25981ee9170206be21af3c8e0eb312ef1d3382e761
            ),
            bytes32(
                0xb2a8b3e5fe1052c7a1c930feca2f96db946a728cf22d75ca5724b5f614b19880
            ),
            bytes32(
                0xcd6219da3e048c69367e19d0b60a695ffff3a1eb513389e18c9024c4fb61750f
            ),
            bytes32(
                0xef1784de53111025b1934639fe9ef7bc93372d109883270282e6e7b9489e2adb
            )
        ];
        strings = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"];

        bytes[] memory leaves = _mapStringToBytes(strings);
        test = new MerkleTree(leaves);

        bytes32[] memory proof = test.getProof("j");
        _arrayEqBytes32(proof, _expectedProof);
    }

    function testGetRootOddNumberOfLeaves() public {
        bytes32 root = bytes32(
            0x89f26d14449ca2e91ab102cda8e3494a81f8385c776245c3d9d8181cb0030df1
        );
        strings = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k"];

        bytes[] memory leaves = _mapStringToBytes(strings);

        test = new MerkleTree(leaves);
        assertEq(bytes32(test.getRoot()), root);
    }

    function testGetProofOddNumberOfLeaves() public {
        _expectedProof = [
            bytes32(
                0xa8982c89d80987fb9a510e25981ee9170206be21af3c8e0eb312ef1d3382e761
            ),
            bytes32(
                0xb2a8b3e5fe1052c7a1c930feca2f96db946a728cf22d75ca5724b5f614b19880
            ),
            bytes32(
                0xcd6219da3e048c69367e19d0b60a695ffff3a1eb513389e18c9024c4fb61750f
            ),
            bytes32(
                0x88436570ff8ed6e41b9885f4897904f8d63e742532a0d718c94ae7eff2629582
            )
        ];
        strings = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k"];

        bytes[] memory leaves = _mapStringToBytes(strings);
        test = new MerkleTree(leaves);

        bytes32[] memory proof = test.getProof("j");
        _arrayEqBytes32(proof, _expectedProof);
    }

    function testGetRootOneLeaf() public {
        bytes32 root = bytes32(keccak256("k"));
        strings = ["k"];

        bytes[] memory leaves = _mapStringToBytes(strings);

        test = new MerkleTree(leaves);
        assertEq(bytes32(test.getRoot()), root);
    }

    function testGetProofOneLeaf() public {
        _expectedProof = new bytes32[](0);
        strings = ["k"];

        bytes[] memory leaves = _mapStringToBytes(strings);
        test = new MerkleTree(leaves);

        bytes32[] memory proof = test.getProof("k");
        _arrayEqBytes32(proof, _expectedProof);
    }

    function testGetRootTwoLeaves() public {
        bytes32 root = bytes32(
            0xadc33f0d2ee200c13670a7beb7981e41f2e6db243f484bc42045bdfff71ba568
        );
        strings = ["j", "k"];

        bytes[] memory leaves = _mapStringToBytes(strings);

        test = new MerkleTree(leaves);
        assertEq(bytes32(test.getRoot()), root);
    }

    function testGetProofTwoLeaves() public {
        _expectedProof = [
            bytes32(
                0xf3d0adcb6a1c70832365e9da0a6b2f5199422f6a53c67cfad171114e3442aa0f
            )
        ];
        strings = ["j", "k"];

        bytes[] memory leaves = _mapStringToBytes(strings);
        test = new MerkleTree(leaves);

        bytes32[] memory proof = test.getProof("j");
        _arrayEqBytes32(proof, _expectedProof);
    }

    function testHashesAreSorted() public {
        bytes32 root = bytes32(
            0x89f26d14449ca2e91ab102cda8e3494a81f8385c776245c3d9d8181cb0030df1
        );
        strings = ["d", "e", "f", "g", "h", "i", "a", "b", "c", "j", "k"];

        bytes[] memory leaves = _mapStringToBytes(strings);

        test = new MerkleTree(leaves);
        assertEq(bytes32(test.getRoot()), root);
    }

    function _emitArray(bytes32[] memory a) public {
        for (uint256 i = 0; i < a.length; i++) {
            emit log_bytes32(a[i]);
        }
    }

    function _mapKeccak(string[] memory input)
        internal
        pure
        returns (bytes32[] memory)
    {
        bytes32[] memory output = new bytes32[](input.length);
        for (uint256 i = 0; i < input.length; i++) {
            output[i] = keccak256(abi.encodePacked(input[i]));
        }
        return output;
    }

    function _mapStringToBytes(string[] memory input)
        internal
        pure
        returns (bytes[] memory)
    {
        bytes[] memory output = new bytes[](input.length);
        for (uint256 i = 0; i < input.length; i++) {
            output[i] = abi.encodePacked(input[i]);
        }
        return output;
    }

    function _mapBytes32ToBytes(bytes32[] memory input)
        internal
        pure
        returns (bytes[] memory)
    {
        bytes[] memory output = new bytes[](input.length);
        for (uint256 i = 0; i < input.length; i++) {
            output[i] = abi.encodePacked(input[i]);
        }
        return output;
    }

    function _arrayEqBytes(bytes[] memory a, bytes[] memory b) internal {
        assertEq(a.length, b.length);
        for (uint256 i = 0; i < a.length; i++) {
            assertTrue(Compare.bytesEq(a[i], b[i]));
        }
    }

    function _arrayEqBytes32(bytes32[] memory a, bytes32[] memory b) internal {
        assertEq(a.length, b.length);
        if (a.length == b.length) {
            for (uint256 i = 0; i < a.length; i++) {
                assertEq(a[i], b[i]);
            }
        }
    }
}
