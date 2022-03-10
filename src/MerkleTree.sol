// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {Sort} from "./utils/Sort.sol";
import {SortBytes} from "./utils/SortBytes.sol";
import {Compare} from "./utils/Compare.sol";

contract MerkleTree {
    bool duplicateOdd;
    bytes32[] public leaves;
    bytes32[][] public layers;
    bytes32[] internal _proof;

    function getLayers() public view returns (bytes32[][] memory) {
        return layers;
    }

    function getLeaves() public view returns (bytes32[] memory) {
        return leaves;
    }

    constructor(bytes[] memory _leaves, bool _duplicateOdd) {
        duplicateOdd = _duplicateOdd;
        hashAndProcessLeaves(_leaves);
    }

    function getRoot() public view returns (bytes32) {
        if (layers.length == 0) {
            return bytes32(0);
        }
        return layers[layers.length - 1][0];
    }

    function getProof(bytes memory _leaf) public returns (bytes32[] memory) {
        int256 index = indexOf(leaves, keccak256(_leaf));

        _proof = new bytes32[](0);
        if (index < 0) {
            return _proof;
        }

        for (uint256 i; i < layers.length; ++i) {
            bytes32[] memory layer = layers[i];
            bool isRightNode = (index % 2) == 1;
            uint256 pairIndex = (
                isRightNode ? uint256(index) - 1 : uint256(index) + 1
            );
            if (pairIndex < layer.length) {
                _proof.push(layer[pairIndex]);
            }
            index = index / 2;
        }
        return _proof;
    }

    function addLeaf(bytes memory leaf) external {
        leaves.push(keccak256(leaf));
        processLeaves(leaves);
    }

    function addLeaves(bytes[] memory _leaves) external {
        uint256 numLeaves = _leaves.length;
        for (uint256 i; i < numLeaves; ++i) {
            leaves.push(keccak256(_leaves[i]));
        }
        processLeaves(leaves);
    }

    function setLeaves(bytes[] memory _leaves) public {
        hashAndProcessLeaves(_leaves);
    }

    function setHashedLeaves(bytes32[] memory _hashedLeaves) public {
        leaves = _hashedLeaves;
        processLeaves(leaves);
    }

    function getLeaf(uint256 _index) public view returns (bytes32) {
        return leaves[_index];
    }

    function getLeafIndex(bytes memory _leaf) public view returns (int256) {
        return getHashedLeafIndex(keccak256(_leaf));
    }

    function getHashedLeafIndex(bytes32 _hashedLeaf)
        public
        view
        returns (int256)
    {
        for (uint256 i; i < leaves.length; ++i) {
            if (leaves[i] == _hashedLeaf) {
                return int256(i);
            }
        }
        return -1;
    }

    function hashAndProcessLeaves(bytes[] memory _leaves) internal {
        bytes32[] memory hashedLeaves = new bytes32[](_leaves.length);
        for (uint256 i = 0; i < _leaves.length; i++) {
            hashedLeaves[i] = keccak256(_leaves[i]);
        }

        processLeaves(hashedLeaves);
    }

    function processLeaves(bytes32[] memory _leaves) internal {
        // always sort leaves
        leaves = Sort.sort(_leaves);
        layers = [leaves];
        createTree(leaves);
    }

    function createTree(bytes32[] memory nodes) internal {
        while (nodes.length > 1) {
            uint256 layerIndex = layers.length;
            layers.push(new bytes32[](0));
            for (uint256 i; i < nodes.length; i += 2) {
                if (i + 1 == nodes.length) {
                    if (nodes.length % 2 == 1 && !duplicateOdd) {
                        layers[layerIndex].push(nodes[i]);
                        continue;
                    }
                }
                bytes32 left = nodes[i];
                // when duplicateOdd is true, hash odd leaves with themselves
                bytes32 right = (i + 1) == nodes.length ? left : nodes[i + 1];
                // always sort pairs
                (left, right) = Sort.sortPair(left, right);
                bytes32 hashed = keccak256(bytes.concat(left, right));
                layers[layerIndex].push(hashed);
            }
            nodes = layers[layerIndex];
        }
    }

    function indexOf(bytes32[] memory _leaves, bytes32 _hashedLeaf)
        internal
        pure
        returns (int256)
    {
        for (uint256 i; i < _leaves.length; ++i) {
            if (_leaves[uint256(i)] == _hashedLeaf) {
                return int256(i);
            }
        }
        return -1;
    }
}
