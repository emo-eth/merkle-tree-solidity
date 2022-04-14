// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {Sort} from "./utils/Sort.sol";
import {SortBytes} from "./utils/SortBytes.sol";
import {Compare} from "./utils/Compare.sol";

contract MerkleTree {
    bool duplicateOdd;
    bool sortHashedLeaves;
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
    constructor(bytes[] memory _leaves, bool _duplicateOdd) {
        duplicateOdd = _duplicateOdd;
        // for now, always sort leaves
        sortHashedLeaves = true;
        // for now, always sort pairs
        sortPairs = true;
        hashAndProcessLeaves(_leaves);
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

    ///@notice add a leaf's hash and reconstruct the Merkle tree
    ///@param _leaf the leaf to add
    function addLeaf(bytes memory _leaf) external {
        leaves.push(keccak256(_leaf));
        processLeaves(leaves);
    }

    ///@notice add the hashes of multiple leaves and reconstruct the Merkle tree
    ///@param _leaves the leaves to add
    function addLeaves(bytes[] memory _leaves) external {
        uint256 numLeaves = _leaves.length;
        for (uint256 i; i < numLeaves; ++i) {
            leaves.push(keccak256(_leaves[i]));
        }
        processLeaves(leaves);
    }

    ///@notice reconsruct the Merkle tree with a new set of leaves
    ///@param _leaves new set of leaves to reconstruct the Merkle tree
    function setLeaves(bytes[] memory _leaves) public {
        hashAndProcessLeaves(_leaves);
    }

    ///@notice add a hashed leaf and reconstruct the Merkle tree
    ///@param _leaf the leaf to add
    function addHashedLeaf(bytes32 _leaf) external {
        leaves.push(_leaf);
        processLeaves(leaves);
    }

    ///@notice add multiple leaf hashes and reconstruct the Merkle tree
    ///@param _leaves the leaves to add
    function addHashedLeaves(bytes32[] memory _leaves) external {
        uint256 numLeaves = _leaves.length;
        for (uint256 i; i < numLeaves; ++i) {
            leaves.push(_leaves[i]);
        }
        processLeaves(leaves);
    }

    ///@notice directly set leaf hashes, and re-build the Merkle tree
    ///@param _hashedLeaves hashed leaves to use as base layer in merkle tree
    function setHashedLeaves(bytes32[] memory _hashedLeaves) public {
        leaves = _hashedLeaves;
        processLeaves(leaves);
    }

    ///@notice get the leaf hash at a given index
    ///@param _index the index of the leaf hash
    ///@return the leaf hash at the given index
    function getHashedLeaf(uint256 _index) public view returns (bytes32) {
        return leaves[_index];
    }

    ///@notice get the index of the a leaf's hash in the Merkle tree
    ///@param _leaf leaf to hash and find index of
    ///@return the index of the hash of the leaf in the Merkle tree, or -1 if not found
    function getLeafIndex(bytes memory _leaf) public view returns (int256) {
        return getHashedLeafIndex(keccak256(_leaf));
    }

    ///@notice get the index of the hash of a leaf in the Merkle tree
    ///@param _hashedLeaf the hash of the leaf
    ///@return the index of the leaf in the Merkle tree, or -1 if not found
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

    ///@notice hash bytes[] leaves and build the Merkle Tree
    ///@param _leaves leaves to hash as bytes[]
    function hashAndProcessLeaves(bytes[] memory _leaves) internal {
        bytes32[] memory hashedLeaves = new bytes32[](_leaves.length);
        for (uint256 i = 0; i < _leaves.length; i++) {
            hashedLeaves[i] = keccak256(_leaves[i]);
        }

        processLeaves(hashedLeaves);
    }

    ///@notice Process hashed leaves to create the full Merkle Tree
    ///@param _leaves hashed leaves as bytes32[]
    function processLeaves(bytes32[] memory _leaves) internal {
        // if sortHashedLeaves is true, sort the hashed leaves in ascending order
        if (sortHashedLeaves) {
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
