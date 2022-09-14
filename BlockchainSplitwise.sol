// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title BlockchainSplitwise
 * @dev keep a ledger of people and their debts
 */
contract BlockchainSplitwise {

    struct MapIndex{
        uint32 amount;
        bool exists;
    }
    struct Person {
        address addr;
        mapping(address => MapIndex) owes;
        mapping(address => uint256) time;
        address[] creditors;
        uint32 count_creditors;
    }
    struct MapIndexUsers {
        Person person;
        bool exists;
    }

    mapping(address => MapIndexUsers) private users;
    mapping(address => uint256) private last_active;
    address[] private all_users;
    uint32 private count_users;
    
    /**
     * @dev make an edge or potentioaly a new node in the graph
     * @param creditor address and the amount
     */
    function add_IOU(address creditor, uint32 amount) public {
        uint32 owe = users[msg.sender].person.owes[creditor].amount + amount;
        uint32 debt = users[creditor].person.owes[msg.sender].amount;
        last_active[msg.sender] = block.timestamp;
        
        if(users[msg.sender].exists == false){
            all_users.push(msg.sender);
            users[msg.sender].exists = true;
            count_users += 1;
        }
        
        Person storage _sender = users[msg.sender].person;
        Person storage _creditor = users[creditor].person;
        
        if (_sender.owes[creditor].exists == false){
            _sender.creditors.push(creditor);
            _sender.count_creditors += uint32(1);
        }
        if (_creditor.owes[msg.sender].exists == false){
            _creditor.creditors.push(msg.sender);
            _creditor.count_creditors += uint32(1);
        }
        
        if (owe > debt){
            _sender.addr = msg.sender;
            _sender.owes[creditor] = MapIndex({amount : owe - debt, exists : true});
            _sender.time[creditor] = block.timestamp;
            
            _creditor.addr = creditor;
            _creditor.owes[msg.sender] = MapIndex({amount : uint32(0), exists : true});
            _creditor.time[msg.sender] = block.timestamp;
        }else{
            _sender.addr = msg.sender;
            _sender.owes[creditor] = MapIndex({amount : uint32(0), exists : true});
            _sender.time[creditor] = block.timestamp;
            
            _creditor.addr = creditor;
            _creditor.owes[msg.sender] = MapIndex({amount : debt - owe, exists : true});
            _creditor.time[msg.sender] = block.timestamp;
        }
    }

    /**
     * @dev Return value 
     * @return value of debt
     */
    function get_last_active(address a) public view returns (uint256){
        return last_active[a];
    }
     
    function lookup(address debtor, address creditor) public view returns (uint32){
        return users[debtor].person.owes[creditor].amount;
    }
    
    function getNeighbor(address debtor, uint32 index) public view returns (address){
        return users[debtor].person.creditors[index];
    }
    function getCountNeighbors(address debtor) public view returns (uint32){
        return users[debtor].person.count_creditors;
    }
    function getUser(uint32 index) public view returns (address){
        return all_users[index];
    }
    function getCountUser() public view returns (uint32){
        return count_users;
    }
}