// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {Sort} from "./utils/Sort.sol";
import {SortBytes} from "./utils/SortBytes.sol";
import {Compare} from "./utils/Compare.sol";

contract MerkleTree {
    bool duplicateOdd;
    bool sortLeaves;
    bool sortPairs;
    bytes32[] public leaves;
    bytes32[][] public layers;
    bytes32[] internal _proof;

    /**                         
When duplicateOdd is False, odd nodes are carried upwards in the tree until
they can be hashed as part of an "even" layer 

duplicateOdd=False
             ┌──────┐            
           ┌─┤H12345├─┐          
           │ └──────┘ │          
         ┌─┴───┐   ┌──┴─┐        
       ┌─┤H1234├──┐│ 5  ├ ┐      
       │ └─────┘  │└────┘        
    ┌──┴─┐      ┌─┴──┐  ┌ ┴ ─    
  ┌─┤H12 ├┐   ┌─┤H34 ├┐   5  │   
  │ └────┘│   │ └────┘│ └ ───    
┌─┴──┐┌───┴┐ ┌┴───┐┌──┴─┐  ┌└─── 
│ 1  ││ 2  │ │ 3  ││ 4  │    5  │
└────┘└────┘ └────┘└────┘  └ ─ ─     
                                            
                                            
When duplicateOdd is True, odd nodes in a layer are hashed with themselves,
and that result is included in the next layer of the tree  

duplicateOdd=True   
                   ┌─────────┐              
               ┌───┤H12345555├──┐           
               │   └─────────┘  │           
         ┌─────┤                └┬─────┐    
       ┌─┤H1234├──┐             ┌┤H5555├┐   
       │ └─────┘  │             │└─────┘│   
    ┌──┴─┐      ┌─┴──┐        ┌─┴──┐  ┌ ┴── 
  ┌─┤H12 ├┐   ┌─┤H34 ├┐     ┌─┤H55 ├┐  H55 │
  │ └────┘│   │ └────┘│     │ └────┘│ └ ─ ─ 
┌─┴──┐┌───┴┐ ┌┴───┐┌──┴─┐ ┌─┴──┐┌ ─ ┴       
│ 1  ││ 2  │ │ 3  ││ 4  │ │ 5  │  5  │      
└────┘└────┘ └────┘└────┘ └────┘└ ─ ─       
    */
    constructor(
        bool _sortLeaves,
        bool _sortPairs,
        bool _duplicateOdd
    ) {
        sortLeaves = _sortLeaves;
        sortPairs = _sortPairs;
        duplicateOdd = _duplicateOdd;
    }

    ///@notice returns the current layers of the Merkle tree
    function getLayers() public view returns (bytes32[][] memory) {
        return layers;
    }

    ///@notice return the hashed leaves of the Merkle tree
    function getHashedLeaves() public view returns (bytes32[] memory) {
        return leaves;
    }

    ///@notice get the root hash of the Merkle tree
    function getRoot() public view returns (bytes32) {
        if (layers.length == 0) {
            return bytes32(0);
        }
        return layers[layers.length - 1][0];
    }

    ///@notice given an unhashed leaf, return the Merkle proof of its inclusion
    ///@param _leaf the leaf to prove inclusion of
    ///@return bytes32[] - the Merkle proof of inclusion of the leaf
    function getProof(bytes memory _leaf) public returns (bytes32[] memory) {
        return _getProof(indexOf(leaves, keccak256(_leaf)));
    }

    ///@notice given a bytes32 leaf, return the Merkle proof of its inclusion
    ///@param _leaf the leaf to prove inclusion of
    ///@return bytes32[] - the Merkle proof of inclusion of the leaf
    function getProof(bytes32 _leaf) public returns (bytes32[] memory) {
        return _getProof(indexOf(leaves, _leaf));
    }

    ///@notice given the index of a leaf, return the Merkle proof of its inclusion
    ///@param _leafIndex the index of the leaf to prove inclusion of
    function _getProof(int256 _leafIndex) internal returns (bytes32[] memory) {
        _proof = new bytes32[](0);
        if (_leafIndex < 0) {
            return _proof;
        }
        for (uint256 i; i < layers.length; ++i) {
            bytes32[] memory layer = layers[i];
            bool isRightNode = (_leafIndex % 2) == 1;
            uint256 pairIndex = (
                isRightNode ? uint256(_leafIndex) - 1 : uint256(_leafIndex) + 1
            );
            if (pairIndex < layer.length) {
                _proof.push(layer[pairIndex]);
            }
            _leafIndex = _leafIndex / 2;
        }
        return _proof;
    }

    ////////////////////
    // SETTING LEAVES //
    ////////////////////

    ///////////
    // BYTES //
    ///////////

    ///@notice add a leaf's hash and reconstruct the Merkle tree
    ///@param _leaf the leaf to add
    function addLeaf(bytes calldata _leaf) public {
        leaves.push(keccak256(_leaf));
        processLeaves(leaves);
    }

    ///@notice add the hashes of multiple leaves and reconstruct the Merkle tree
    ///@param _leaves the leaves to add
    function addLeaves(bytes[] calldata _leaves) public {
        uint256 numLeaves = _leaves.length;
        for (uint256 i; i < numLeaves; ++i) {
            leaves.push(keccak256(_leaves[i]));
        }
        processLeaves(leaves);
    }

    ///@notice reconsruct the Merkle tree with a new set of leaves
    ///@param _leaves new set of leaves to reconstruct the Merkle tree
    function setLeaves(bytes[] calldata _leaves) public {
        hashAndProcessLeaves(_leaves);
    }

    /////////////
    // BYTES32 //
    /////////////

    ///@notice add a leaf and reconstruct the Merkle tree
    ///@param _leaf the leaf to add
    ///@param _hash whether to hash the leaf before adding
    function addLeaf(bytes32 _leaf, bool _hash) public {
        if (_hash) {
            leaves.push(keccak256(abi.encode(_leaf)));
        } else {
            leaves.push(_leaf);
        }
        processLeaves(leaves);
    }

    ///@notice add multiple leaves and reconstruct the Merkle tree
    ///@param _leaves the leaves to add
    ///@param _hash whether to hash the leaves before adding them
    function addLeaves(bytes32[] memory _leaves, bool _hash) public {
        uint256 numLeaves = _leaves.length;
        for (uint256 i; i < numLeaves; ++i) {
            if (_hash) {
                leaves.push(keccak256(abi.encode(_leaves[i])));
            } else {
                leaves.push(_leaves[i]);
            }
        }
        processLeaves(leaves);
    }

    ///@notice replace leaves, optionally hashing them, and re-build the Merkle tree
    ///@param _leaves bytes32[] leaves to use as base layer in merkle tree
    ///@param _hash bool whether to hash the leaves before re-building the Merkle tree
    function setLeaves(bytes32[] memory _leaves, bool _hash) public {
        if (_hash) {
            bytes32[] memory _hashedLeaves = new bytes32[](_leaves.length);
            for (uint256 i; i < _hashedLeaves.length; ++i) {
                _hashedLeaves[i] = keccak256(abi.encode(_leaves[i]));
            }
            leaves = _hashedLeaves;
        } else {
            leaves = _leaves;
        }
        processLeaves(leaves);
    }

    /////////////
    // UINT256 //
    /////////////

    ///@notice add a leaf and reconstruct the Merkle tree
    ///@param _leaf the leaf to add
    ///@param _hash whether to hash the leaf before adding
    function addLeaf(uint256 _leaf, bool _hash) public {
        addLeaf(bytes32(_leaf), _hash);
    }

    ///@notice add multiple leaves and reconstruct the Merkle tree
    ///@param _leaves the leaves to add
    ///@param _hash whether to hash the leaves before adding them
    function addLeaves(uint256[] memory _leaves, bool _hash) public {
        bytes32[] memory _castLeaves = new bytes32[](_leaves.length);
        for (uint256 i; i < _leaves.length; ++i) {
            _castLeaves[i] = bytes32(_leaves[i]);
        }
        addLeaves(_castLeaves, _hash);
    }

    ///@notice replace leaves, optionally hashing them, and re-build the Merkle tree
    ///@param _leaves uint256[] leaves to use as base layer in merkle tree
    ///@param _hash bool whether to hash the leaves before re-building the Merkle tree
    function setLeaves(uint256[] calldata _leaves, bool _hash) public {
        bytes32[] memory _castLeaves = new bytes32[](_leaves.length);
        for (uint256 i; i < _castLeaves.length; ++i) {
            _castLeaves[i] = bytes32(_leaves[i]);
        }
        setLeaves(_castLeaves, _hash);
    }

    ////////////////////
    // GETTING LEAVES //
    ////////////////////

    ///@notice get the leaf at a given index
    ///@param _index the index of the leaf
    ///@return the leaf at the given index (possibly hashed)
    function getLeaf(uint256 _index) public view returns (bytes32) {
        return leaves[_index];
    }

    ///@notice get the index of the a leaf's hash in the Merkle tree
    ///@param _leaf leaf to hash and find index of
    ///@return the index of the hash of the leaf in the Merkle tree, or -1 if not found
    function getLeafIndex(bytes calldata _leaf) public view returns (int256) {
        return getLeafIndex(keccak256(_leaf));
    }

    ///@notice get the index of the a bytes32 leaf in the Merkle tree
    ///@param _leaf the bytes32 leaf
    ///@return the index of the leaf in the Merkle tree, or -1 if not found
    function getLeafIndex(bytes32 _leaf) public view returns (int256) {
        for (uint256 i; i < leaves.length; ++i) {
            if (leaves[i] == _leaf) {
                return int256(i);
            }
        }
        return -1;
    }

    ///@notice get the index of a uint256 leaf in the Merkle tree
    ///@param _leaf the uint256 leaf
    ///@return the index of the leaf in the Merkle tree, or -1 if not found
    function getLeafIndex(uint256 _leaf) public view returns (int256) {
        return getLeafIndex(bytes32(_leaf));
    }

    ///////////////////////
    // CREATING THE TREE //
    ///////////////////////

    ///@notice hash bytes[] leaves and build the Merkle Tree
    ///@param _leaves bytes[] leaves to be hashed
    function hashAndProcessLeaves(bytes[] calldata _leaves) internal {
        bytes32[] memory hashedLeaves = new bytes32[](_leaves.length);
        for (uint256 i = 0; i < _leaves.length; i++) {
            hashedLeaves[i] = keccak256(_leaves[i]);
        }

        processLeaves(hashedLeaves);
    }

    ///@notice Process leaves to create the full Merkle Tree
    ///@param _leaves leaves as bytes32[]
    function processLeaves(bytes32[] memory _leaves) internal {
        // if sortLeaves is true, sort the hashed leaves in ascending order
        if (sortLeaves) {
            leaves = Sort.sort(_leaves);
        }
        createTree();
    }

    ///@notice build the Merkle tree from scratch using the stored leaves
    function createTree() internal {
        layers = [leaves];
        bytes32[] memory nodes = leaves;
        while (nodes.length > 1) {
            // push new layer onto the end of layers array
            uint256 layerIndex = layers.length;
            layers.push(new bytes32[](0));
            for (uint256 i; i < nodes.length; i += 2) {
                if (i + 1 == nodes.length) {
                    // when duplicateOdd is false, if there are an odd number of nodes,
                    // skip the last node and push it to the next layer up
                    if (nodes.length % 2 == 1 && !duplicateOdd) {
                        layers[layerIndex].push(nodes[i]);
                        continue;
                    }
                }
                // otherwise, hash this node with the next node and push the result to the current layer

                bytes32 left = nodes[i];
                // when duplicateOdd is true, hash odd leaves with themselves
                bytes32 right = (i + 1) == nodes.length ? left : nodes[i + 1];
                // when sortPairs is true, hash pairs of leaves in ascending order
                if (sortPairs) {
                    (left, right) = Sort.sortPair(left, right);
                }
                bytes32 hashed = keccak256(abi.encode(left, right));
                layers[layerIndex].push(hashed);
            }
            nodes = layers[layerIndex];
        }
    }

    //////////////////////
    // HELPER FUNCTIONS //
    //////////////////////

    ///@notice get the index of a bytes32 value in a bytes32[]
    ///@param _array the array to search
    ///@param _value the value to search for
    ///@return the index of the value in the array, or -1 if not found
    function indexOf(bytes32[] memory _array, bytes32 _value)
        internal
        pure
        returns (int256)
    {
        for (uint256 i; i < _array.length; ++i) {
            if (_array[uint256(i)] == _value) {
                return int256(i);
            }
        }
        return -1;
    }
}
