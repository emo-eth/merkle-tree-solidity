// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {SortBytes} from "./utils/SortBytes.sol";
import {Compare} from "./utils/Compare.sol";

contract MerkleTree {
    bool immutable hashLeaves;
    bool immutable sortLeaves;
    bool immutable sortPairs;
    bytes[] public leaves;
    bytes[][] public layers;
    bytes[] internal _proof;

    function getLayers() public view returns (bytes[][] memory) {
        return layers;
    }

    function getLeaves() public view returns (bytes[] memory) {
        return leaves;
    }

    constructor(
        bytes[] memory _leaves,
        bool _hashLeaves,
        bool _sortLeaves,
        bool _sortPairs
    ) {
        hashLeaves = _hashLeaves;
        sortLeaves = _sortLeaves;
        sortPairs = _sortPairs;
        processLeaves(_leaves);
    }

    function getRoot() public view returns (bytes memory) {
        if (layers.length == 0) {
            return bytes("");
        }
        return layers[layers.length - 1][0];
    }

    function getProof(bytes memory _leaf) public returns (bytes[] memory) {
        int256 index = indexOf(leaves, _leaf);

        _proof = new bytes[](0);
        if (index < 0) {
            return _proof;
        }

        for (uint256 i; i < layers.length; ++i) {
            bytes[] memory layer = layers[i];
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
        leaves.push(leaf);
        processLeaves(leaves);
    }

    function addLeaves(bytes[] memory _leaves) external {
        uint256 numLeaves = _leaves.length;
        for (uint256 i; i < numLeaves; ++i) {
            leaves.push(_leaves[i]);
        }
        processLeaves(leaves);
    }

    function setLeaves(bytes[] memory _leaves) public {
        leaves = _leaves;
        processLeaves(leaves);
    }

    function getLeaf(uint256 _index) public view returns (bytes memory) {
        return leaves[_index];
    }

    function getLeafIndex(bytes memory _leaf) public view returns (int256) {
        for (uint256 i; i < leaves.length; ++i) {
            if (Compare.bytesEq(leaves[i], _leaf)) {
                return int256(i);
            }
        }
        return -1;
    }

    function processLeaves(bytes[] memory _leaves) internal {
        layers = new bytes[][](0);

        if (hashLeaves) {
            for (uint256 i = 0; i < _leaves.length; i++) {
                _leaves[i] = abi.encode(keccak256(_leaves[i]));
            }
        }
        if (sortLeaves) {
            leaves = SortBytes.sort(_leaves);
        } else {
            leaves = _leaves;
        }

        layers = [leaves];
        createTree(leaves);
    }

    function createTree(bytes[] memory nodes) internal {
        while (nodes.length > 1) {
            uint256 layerIndex = layers.length;
            layers.push(new bytes[](0));
            for (uint256 i; i < nodes.length; i += 2) {
                if (i + 1 == nodes.length) {
                    if (nodes.length % 2 == 1) {
                        layers[layerIndex].push(nodes[i]);
                        continue;
                    }
                }
                bytes memory left = nodes[i];
                // this ternary is left over from merkletreejs's duplicateOdd option
                bytes memory right = (i + 1) == nodes.length
                    ? left
                    : nodes[i + 1];
                if (sortPairs) {
                    (left, right) = SortBytes.sortPair(left, right);
                }
                bytes memory hashed = abi.encode(
                    keccak256(bytes.concat(left, right))
                );
                layers[layerIndex].push(hashed);
            }
            nodes = layers[layerIndex];
        }
    }

    function indexOf(bytes[] memory _leaves, bytes memory _leaf)
        internal
        pure
        returns (int256)
    {
        for (uint256 i; i < _leaves.length; ++i) {
            if (Compare.bytesEq(_leaves[uint256(i)], _leaf)) {
                return int256(i);
            }
        }
        return -1;
    }
}
