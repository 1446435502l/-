// SPDX-License-Identifier: MIT  
pragma solidity ^0.8.0;  
contract Score
{
    mapping (string=>uint8) public student;
    address teacher;
    constructor(address add)
    {
        teacher=add;
    }
    modifier limit(uint8 value)
    {
        require(teacher==msg.sender,"authority error");
        require(value<=100,"score error");
        _;
    }
    function update(string memory name,uint8 value)public limit(value)
    {
        student[name]=value;
    }
    function inquire(string calldata name)view public returns(uint8)
    {
        return student[name];
    }
}

contract Teacher
{
    mapping (string=>address)record;
    event Response(bool success,bytes data);
    function createclass(string calldata class)public returns(bool,address)
    {
        bool flag=false;
        bytes32 salt=keccak256(abi.encodePacked(class));
        //构造函数有参数记得也要把编码打包，不然计算出来的地址不对，交互的时候解码不出来
        address student=address(uint160(uint(keccak256(abi.encodePacked(bytes1(0xff),address(this),salt,keccak256(abi.encodePacked(type(Score).creationCode,abi.encode(address(this)))))))));
        if(record[class]==address(0))
        {
            record[class]=student;
            Score score=new Score{salt:salt}(address(this));
            flag=true;
        }
        return (flag,student);
    }
    function update(string calldata class,string calldata name,uint8 value) public returns(address)
    {
        bool flag=false;
        address new_class=address(0);
        if(record[class]==address(0))
        {
            (flag,new_class)=createclass(class);
        }
        address temp=record[class];
        (bool success,bytes memory data)=temp.call(abi.encodeWithSignature("update(string,uint8)",name,value));
        emit Response(success, data);
        return new_class;
    }
}