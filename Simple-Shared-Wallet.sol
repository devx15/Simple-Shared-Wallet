// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.0;

import "https://github.com/Normalities/OpenZepplin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/Normalities/OpenZepplin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract Allowance is Ownable{

    using SafeMath for uint;
 
    event AllowanceChanged(address indexed _forwho,address indexed _forWhom ,uint _oldAccount ,uint _newAccount);

    mapping (address=>uint) public  allowance;

    function addAllowance(address _who,uint _amount) public onlyOwner{
        emit AllowanceChanged ( _who , msg.sender, allowance[_who], _amount);
        allowance[_who]=_amount;
    }

    modifier onlyOrAllowance(uint _amount){
        require( isOwner() || allowance[msg.sender]>=_amount,"You are not allowed!!" );
        _;
    }

    function reduceAllowance(address _who,uint _amount)internal {
        emit AllowanceChanged(_who, msg.sender, allowance[_who], allowance[_who].sub(_amount));
        allowance[_who]=allowance[_who].sub(_amount);
    }
}

contract SimpleWallet is Allowance{
  
    event AmountRecieved(address indexed _from,uint _amount);
    event AmountSent(address indexed _beneficiary,uint _amount);
    
    function renounceOwnership() public override view  onlyOwner{
        revert("Can't renounce ownership here!! ");
    }

    function withdrawlMoney(address payable _to,uint _amount) public onlyOwner {
        require(_amount <= address(this).balance,"There is not enough fund!" );
        if (!isOwner()) {
            reduceAllowance(msg.sender,_amount);
        }
        emit AmountSent(_to, _amount);
        _to.transfer(_amount);
    }

    function newone( ) external payable{
        emit AmountRecieved(msg.sender, msg.value);
    }

}