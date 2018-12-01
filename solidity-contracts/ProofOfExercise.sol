pragma solidity ^0.4.24;

import "./Token.sol";

contract ProofOfExercise is Token {

    // utilize off-chain & on-chain data
    struct Activity {
        address owner;
        string title;
        // type :  activity type
        int activity_type;
        uint256 score;
        string metadataURL;
        string metadataHash;
        uint timeStamp;
    }


    // utilize on-chain only
    struct Challenge {
        address owner;
        string title;
        uint256 deposit;
        uint timeStamp;
        string bargeURL;
        address winner;
        bool ended; 
        uint endTime;
    }

    struct Contender {

        address owner;
        uint256 activity_id;
        uint256 challenge_id;
        uint timeStamp;

    }



    mapping(uint256 => Activity) activities;
    mapping(uint256 => Challenge) challenges;
    mapping(uint256 => Contender) contenders;

    uint256 private activityCount = 0;
    uint256 private challengeCount = 0;
    uint256 private contenderCount = 0;

    constructor() public {
        initiateToken("EXERCOIN","XCOIN",16,1000000000);
    }
    
    function numActivity() public view returns (uint256) {
        return activityCount;
    }

    function numChallenge() public view returns (uint256) {
        return challengeCount;
    }

    function numContender() public view returns (uint256) {
        return contenderCount;
    }

    function createActivity(string _title, int _type, uint256 _score, string _metadataURL, string _metadataHash) public {
        activityCount = activityCount+1;
        activities[activityCount].owner = msg.sender;
        activities[activityCount].title = _title;
        activities[activityCount].activity_type = _type;
        activities[activityCount].score = _score;
        activities[activityCount].metadataURL = _metadataURL;
        activities[activityCount].metadataHash = _metadataHash;
        activities[activityCount].timeStamp = now;
    }



    function getActivityById(uint256 _id) public view returns (address, string, int, uint256, string) {
        return (activities[_id].owner, activities[_id].title, activities[_id].activity_type, activities[_id].score, activities[_id].metadataURL);
    }

    

    function getActivityIdByAddress(address owner) public view returns (uint256[]) {
        uint256[] memory outArray_ = new uint256[](16);
        uint count = 0; 
        uint max = activityCount+1;
        for (uint i=1; i<max;i++) {
            if (activities[i].owner == owner) {
                outArray_[count] = i;
                count = count+1;
            }
        }
        return (outArray_);
    }

    
    function createChallenge(string _title, uint256 _deposit, string _bargeURL, uint _endTime) public {
        require(_deposit > 0,"deposit has to be greater than 0");
        require(balances[msg.sender] > 0, "insufficient balance");

        challengeCount = challengeCount+1;
        challenges[challengeCount].owner = msg.sender;
        challenges[challengeCount].title = _title;
        challenges[challengeCount].deposit = _deposit;
        _burn(msg.sender,_deposit);
        challenges[challengeCount].timeStamp = now;
        challenges[challengeCount].endTime = _endTime;
        challenges[challengeCount].ended = false;
        challenges[challengeCount].bargeURL = _bargeURL;
    }

    function getChallenge(uint256 _id) public view returns (address, string, uint256, address, bool, string) {
        return (challenges[_id].owner, challenges[_id].title, challenges[_id].deposit, challenges[_id].winner, challenges[_id].ended, challenges[_id].bargeURL);
    } 

    function submitChallenge(uint256 _challenge_id, uint256 _activity_id) public {
        contenderCount = contenderCount+1;
        contenders[challengeCount].owner = msg.sender;
        contenders[challengeCount].challenge_id = _challenge_id;
        contenders[challengeCount].activity_id = _activity_id;
        contenders[challengeCount].timeStamp = now;
    } 

    function getChallengeContender(uint256 _challenge_id) public view returns (uint256[]) {
        uint256[] memory outArray_ = new uint256[](8);
        uint count = 0;
        uint max = contenderCount+1;
        for (uint i=1;i<max;i++) {
            if (contenders[i].challenge_id == _challenge_id) {
                outArray_[count] = i;
                count = count+1;
            }
        }
        return (outArray_);
    }

    function cancelChallenge(uint256 _id) public {
        _mint(challenges[_id].owner,challenges[_id].deposit);
        delete challenges[_id];
    }

    function challengeEnd(uint256 _id) public {
        //require(now >= challenges[_id].endTime, "Challenge not yet ended.");
        //require(!challenges[_id].ended, "Challenge not yet ended.");
        challenges[_id].ended = true;
        uint max = contenderCount+1;
        uint256 highestScore = 0;
        address winner = 0x0;
        for (uint i=1; i<max;i++) {
            if (contenders[i].challenge_id == _id) {
                if (activities[contenders[i].activity_id].score > highestScore  ) {
                    highestScore = activities[contenders[i].activity_id].score;
                    winner = activities[contenders[i].activity_id].owner;
                }
            }
        }
        require(winner != 0x0, "no winner");
        require(highestScore > 0, "final score has to be greater then 0 ");
        _mint(winner,challenges[_id].deposit);
    
    }


}