//SPDX-License-Identifier: UNLICENCED
pragma solidity >=0.7.0 <0.9.0;

contract EVoteApp{
    struct Pool{
        string name;
        string description;
        uint256 totalVotes;
        address owner;
        mapping(address => Voter) voters;
        mapping(uint256 => Option) options;
        uint256 numOfOptions;
        bool isActive;
        uint256 poolIndex;
    }

    struct ShowPool{
        string name;
        string description;
        uint256 totalVotes;
        uint256 numOfOptions;
        uint256 poolIndex;
    }

    struct Option{
        string name;
        uint numOfVotes;
    }

    struct Voter{
        string name;
        uint256 selectedOption;
        bool isVoted;
        uint256 numOfParticipatedVotes;
    }

    event CreatePool(uint indexed poolIndex);

    mapping(uint256 => Pool) public pools;
    uint256 public numOfPools = 0;
    uint256 public numOfActivePools = 0;

    modifier onlyOwner(uint256 _poolIndex){
        require(msg.sender == pools[_poolIndex].owner);
        _;
    }

    modifier canVote(uint256 _poolIndex){
        require(!pools[_poolIndex].voters[msg.sender].isVoted);
        _;
    }

    function createPool(string memory _poolName, string memory _description) public returns(uint256){

        Pool storage _pool = pools[numOfPools++];

        _pool.name = _poolName;
        _pool.description = _description;
        _pool.totalVotes = 0;
        _pool.owner = msg.sender;
        _pool.numOfOptions = 0;
        _pool.isActive = false;
        _pool.poolIndex = numOfPools - 1;


        emit CreatePool(numOfPools - 1);
        return numOfPools - 1;
    }

    function addOption(uint256 _poolIndex, string memory _name) onlyOwner(_poolIndex) public{
        Pool storage _pool = pools[_poolIndex];

        _pool.options[_pool.numOfOptions++] = Option(_name, 0);
    }

    function startPool(uint256 _poolIndex) onlyOwner(_poolIndex) public{
        Pool storage _pool = pools[_poolIndex];

        _pool.isActive = true;
        numOfActivePools++;
    }

    function vote(uint256 _poolIndex, uint256 selectedOption, string memory _username) canVote(_poolIndex) public{
        Pool storage _pool = pools[_poolIndex];

        Voter storage _voter = _pool.voters[msg.sender];

        Option storage option = _pool.options[selectedOption];

        _pool.totalVotes++;

        _voter.name = _username;
        _voter.selectedOption = selectedOption;
        _voter.numOfParticipatedVotes++;
        _voter.isVoted = true;

        option.numOfVotes++;
    }

    function getNumOfVotes(uint256 _poolIndex) public view returns(uint256){
        return pools[_poolIndex].totalVotes;
    }

    function getNumOfOptions(uint256 _poolIndex) public view returns(uint256){
        return pools[_poolIndex].numOfOptions;
    }

    function getOptions(uint256 _poolIndex) public view returns(Option[] memory){

        Option[] memory _options = new Option[](pools[_poolIndex].numOfOptions);

        for (uint i = 0; i < pools[_poolIndex].numOfOptions; i++) {
            _options[i] = pools[_poolIndex].options[i];
        }
        return _options;
    }

    function getActivePools() public view returns(ShowPool[] memory){

        ShowPool[] memory _showPools = new ShowPool[](numOfActivePools);
        uint256 j = 0;

        for (uint i = 0; i < numOfPools; i++) {
            if(pools[i].isActive){
                _showPools[j++] = ShowPool(
                    pools[i].name,
                    pools[i].description,
                    pools[i].totalVotes,
                    pools[i].numOfOptions,
                    pools[i].poolIndex
                );
            }    
        }
        return _showPools;
    }
    
}