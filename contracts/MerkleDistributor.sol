// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.6.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/cryptography/MerkleProof.sol";
import "./interfaces/IMerkleDistributor.sol";

contract MerkleDistributor is IMerkleDistributor {
    address public immutable override token;
    bytes32 public immutable override merkleRoot;

    // This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;
    address deployer;

    constructor(address token_, bytes32 merkleRoot_) public {
        token = token_;
        merkleRoot = merkleRoot_;
        deployer = msg.sender; // the deployer address
    }

    function isClaimed(uint256 index) public view override returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external override {
        // [P] Uncomment: line below, requiring the claim to originate from the 'account'.
        //require(msg.sender == account, 'MerkleDistributor: Only account may withdraw');
        require(!isClaimed(index), 'MerkleDistributor: Drop already claimed.');

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), 'MerkleDistributor: Invalid proof.');

         // Mark it claimed and send the token.
        _setClaimed(index);
        // [P] Start (unix): 1607990400 | Tuesday, December 15th, 2020 @ 12:00AM GMT
        uint256 startTime = 1607495500;
        // [P] End (unix): 1616630400 | Thursday, March 25th, 2021 @ 12:00AM GMT
        uint256 endTime = 1616630400;       
        uint256 nowTime = block.timestamp;
        uint256 duraTime = nowTime - startTime;
        require(nowTime >= startTime, 'MerkleDistributor: Too soon');
        require(nowTime <= endTime, 'MerkleDistributor: Too late');
        // create a ceiling for the maximum amount of duraTime
        uint256 duraDays = duraTime / 86400 >= 90 ? 90 : duraTime / 86400; // divided by the number of seconds per day
        require(duraDays <= 100, 'MerkleDistributor: Too late'); // double check days
        uint256 availAmount = amount * (10 + duraDays) / 100;// 10% + 1% daily
        require(availAmount <= amount, 'MerkleDistributor: Slow your roll');// do not over-distribute
        uint256 foreitedAmount = amount - availAmount;
        
        require(IERC20(token).transfer(account, availAmount), 'MerkleDistributor: Transfer to Account failed.');
        require(IERC20(token).transfer(deployer, foreitedAmount), 'MerkleDistributor: Transfer to Deployer failed.');
        emit Claimed(index, account, amount);
    }

    function collectDust(address _token, uint256 _amount) external {
      require(msg.sender == deployer, "!deployer");
      require(_token != token, "!token");
      if (_token == address(0)) { // token address(0) = ETH
        payable(deployer).transfer(_amount);
      } else {
        IERC20(_token).transfer(deployer, _amount);
      }
    }
}
