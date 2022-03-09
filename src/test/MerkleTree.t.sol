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
    bytes[] bytes_;
    bytes[] stuff;
    bytes[][] layers;
    bytes[] _expectedProof;

    function testPreHashedLeavesEven() public {
        strings = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"];
        bytes_ = _mapStringToBytes(strings);
        bytes[] memory leaves = _mapBytes32ToBytes(_mapKeccak(strings));
        test = new MerkleTree(leaves, false, true, true);
        assertEq(
            bytes32(test.getRoot()),
            bytes32(
                0x60219f87561939610b484575e45c6e81156a53b86d7cd16640d930d14f21758e
            )
        );
    }

    function testPreHashedLeavesOdd() public {
        strings = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k"];

        bytes[] memory leaves = _mapBytes32ToBytes(_mapKeccak(strings));
        test = new MerkleTree(leaves, false, true, true);
        assertEq(
            bytes32(test.getRoot()),
            bytes32(
                0x89f26d14449ca2e91ab102cda8e3494a81f8385c776245c3d9d8181cb0030df1
            )
        );
    }

    function testGetProofPreHashedLeavesEven() public {
        _expectedProof = [
            abi.encode(
                0xa8982c89d80987fb9a510e25981ee9170206be21af3c8e0eb312ef1d3382e761
            ),
            abi.encode(
                0xb2a8b3e5fe1052c7a1c930feca2f96db946a728cf22d75ca5724b5f614b19880
            ),
            abi.encode(
                0xcd6219da3e048c69367e19d0b60a695ffff3a1eb513389e18c9024c4fb61750f
            ),
            abi.encode(
                0xef1784de53111025b1934639fe9ef7bc93372d109883270282e6e7b9489e2adb
            )
        ];

        strings = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"];

        bytes[] memory leaves = _mapBytes32ToBytes(_mapKeccak(strings));
        test = new MerkleTree(leaves, false, true, true);
        bytes[] memory proof = test.getProof(
            abi.encodePacked(keccak256(abi.encodePacked(bytes("j"))))
        );
        _arrayEqBytes(proof, _expectedProof);
    }

    function testGetProofPreHashedLeavesOdd() public {
        _expectedProof = [
            abi.encode(
                0xa8982c89d80987fb9a510e25981ee9170206be21af3c8e0eb312ef1d3382e761
            ),
            abi.encode(
                0xb2a8b3e5fe1052c7a1c930feca2f96db946a728cf22d75ca5724b5f614b19880
            ),
            abi.encode(
                0xcd6219da3e048c69367e19d0b60a695ffff3a1eb513389e18c9024c4fb61750f
            ),
            abi.encode(
                0x88436570ff8ed6e41b9885f4897904f8d63e742532a0d718c94ae7eff2629582
            )
        ];
        strings = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k"];

        bytes[] memory leaves = _mapBytes32ToBytes(_mapKeccak(strings));
        test = new MerkleTree(leaves, false, true, true);
        bytes[] memory proof = test.getProof(
            abi.encode(keccak256(abi.encodePacked("j")))
        );
        _arrayEqBytes(proof, _expectedProof);
    }

    function testHashLeavesEven() public {
        strings = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"];

        bytes[] memory leaves = _mapStringToBytes(strings);

        test = new MerkleTree(leaves, true, true, true);
        assertEq(
            bytes32(test.getRoot()),
            bytes32(
                0x60219f87561939610b484575e45c6e81156a53b86d7cd16640d930d14f21758e
            )
        );
    }

    function testGetProofHashLeavesEven() public {
        _expectedProof = [
            abi.encode(
                0xa8982c89d80987fb9a510e25981ee9170206be21af3c8e0eb312ef1d3382e761
            ),
            abi.encode(
                0xb2a8b3e5fe1052c7a1c930feca2f96db946a728cf22d75ca5724b5f614b19880
            ),
            abi.encode(
                0xcd6219da3e048c69367e19d0b60a695ffff3a1eb513389e18c9024c4fb61750f
            ),
            abi.encode(
                0x88436570ff8ed6e41b9885f4897904f8d63e742532a0d718c94ae7eff2629582
            )
        ];
        strings = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"];

        bytes[] memory leaves = _mapStringToBytes(strings);
        test = new MerkleTree(leaves, true, true, true);
        bytes[] memory proof = test.getProof(
            abi.encode(keccak256(abi.encodePacked("j")))
        );
        _arrayEqBytes(proof, _expectedProof);
    }

    function testAddLeaves() public {
        strings = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"];

        bytes_ = _mapStringToBytes(strings);
        bytes[] memory leaves = _mapBytes32ToBytes(_mapKeccak(strings));
        test = new MerkleTree(leaves, false, true, true);
        assertEq(
            bytes32(test.getRoot()),
            bytes32(
                0x60219f87561939610b484575e45c6e81156a53b86d7cd16640d930d14f21758e
            )
        );
        _expectedProof = [
            abi.encode(
                0xa8982c89d80987fb9a510e25981ee9170206be21af3c8e0eb312ef1d3382e761
            ),
            abi.encode(
                0xb2a8b3e5fe1052c7a1c930feca2f96db946a728cf22d75ca5724b5f614b19880
            ),
            abi.encode(
                0xcd6219da3e048c69367e19d0b60a695ffff3a1eb513389e18c9024c4fb61750f
            ),
            abi.encode(
                0xef1784de53111025b1934639fe9ef7bc93372d109883270282e6e7b9489e2adb
            )
        ];

        bytes[] memory proof = test.getProof(
            abi.encodePacked(keccak256(abi.encodePacked("j")))
        );
        _arrayEqBytes(proof, _expectedProof);

        strings = ["k"];
        test.addLeaves(_mapBytes32ToBytes(_mapKeccak(strings)));

        assertEq(
            bytes32(test.getRoot()),
            bytes32(
                0x89f26d14449ca2e91ab102cda8e3494a81f8385c776245c3d9d8181cb0030df1
            )
        );

        _expectedProof = [
            abi.encode(
                0xa8982c89d80987fb9a510e25981ee9170206be21af3c8e0eb312ef1d3382e761
            ),
            abi.encode(
                0xb2a8b3e5fe1052c7a1c930feca2f96db946a728cf22d75ca5724b5f614b19880
            ),
            abi.encode(
                0xcd6219da3e048c69367e19d0b60a695ffff3a1eb513389e18c9024c4fb61750f
            ),
            abi.encode(
                0x88436570ff8ed6e41b9885f4897904f8d63e742532a0d718c94ae7eff2629582
            )
        ];
        // strings = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k"];

        // bytes[] memory leaves = _mapBytes32ToBytes(_mapKeccak(strings));
        // test = new MerkleTree(leaves, false, true, true);
        proof = test.getProof(abi.encode(keccak256(abi.encodePacked("j"))));
        _arrayEqBytes(proof, _expectedProof);
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
            Compare.bytesEq(a[i], b[i]);
        }
    }
}
