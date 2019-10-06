pragma solidity >=0.4.22 <0.6.0;

contract Escrow {
    
    enum State {AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE, REFUNDED} // different states of transactions
    State public currentState; //create instance
    
    
    //other state variables 
    address payable public buyer;
    address payable public seller;
    address public arbiter; // arbiter is trusted third party
    
    // modifier is created because we want to set a  condition into the function or restriction. 
    modifier buyerOnly() {
        require(msg.sender == buyer || msg.sender == arbiter);
        _;
    }
    
    modifier inState(State expectedState) {
        require(currentState == expectedState);
        _;
    }
    
    modifier sellerOnly(){
        require(msg.sender == seller || msg.sender == arbiter);
        _;
    }
    
    // initialize the state variables in constructor
    constructor(address payable _buyer, address payable _seller, address _arbiter) public {
        buyer = _buyer;
        seller = _seller;
        arbiter = _arbiter;
    }
    
    // create send payment function 
    function sendPayment() external payable buyerOnly inState(State.AWAITING_PAYMENT) {
        currentState = State.AWAITING_DELIVERY;
    }
    
    // create a function to confirm the delivery
    function confirmDelivery() external buyerOnly inState(State.AWAITING_DELIVERY){
        currentState = State.COMPLETE;
        seller.transfer(address(this).balance);
    }
    
    // create a refund buyer function
    function refundBuyer() external sellerOnly inState(State.AWAITING_DELIVERY){
        currentState = State.REFUNDED;
        buyer.transfer(address(this).balance);
    }
}
