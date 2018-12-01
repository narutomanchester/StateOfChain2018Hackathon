pragma solidity ^0.4.24;

import "./Token.sol";

contract ProofOfExercise is Token {

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

    mapping(uint256 => Activity) activities;

    uint256 private activityCount = 0;

    //constructor() public {
        //initiateToken("EXERCOIN","XCOIN",16,1000000000);
    //}
    
    function numActivity() public view returns (uint256) {
        return activityCount;
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

    function getActivityById(uint256 _id) public view  {
        return (activities[_id].owner, activities[_id].title, activities[_id].activity_type, activities[_id].score, activities[_id].metadataURL);
    }

    



}