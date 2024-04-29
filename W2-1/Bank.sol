// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Bank
{
    mapping (address=>uint) public record;
    fallback() external payable 
    {
        record[msg.sender]+=msg.value;
    }
    receive() external payable 
    {
        record[msg.sender]+=msg.value;
    }
    function withdraw() public payable 
    {
        require(record[msg.sender]>0,"No money");
        address payable addre=payable(msg.sender);
        addre.transfer(record[addre]);
        record[addre]=0;
    }
    function getbank(address addr) public view returns (uint)
    {
        return record[addr];
    }
}