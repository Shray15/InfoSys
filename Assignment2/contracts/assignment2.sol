pragma solidity >=0.7 0<0.9.0;

contract QuestionVotes{
   
    struct Stakeholder{
        bool vote;      // votes -yes or no
        uint accesstovote; /// have access to vote or not
     
    }

    struct Question{
        uint id;
        string question;
        uint vote_count_yes;
        uint vote_count_no;
        uint256 StartTime;
        uint256 EndTime;
    }

    Question[] private questions;

    mapping(address => Stakeholder) public stakeholders;

 

    address public director;

    constructor(){
        director = msg.sender;
        
    }

    function addQuestion(uint id, string memory question, uint256 st, uint256 et) public {
        require(msg.sender == director, 'Only Director can add a question');
        questions.push(Question(id, question, 0, 0, st, et));
    }

    function setEndTime(uint qID, uint256 et) public {
        require(msg.sender == director, 'Only Director can set end time');
        for(uint i = 0; i < questions.length; i++) {
            if(questions[i].id == qID) {
                questions[i].EndTime = et;
                break;
            }
        }
    }

    ///authentication of voters
    function rightToVote(address voter, uint access) public {
        require(msg.sender == director, "Only the Director can give access to vote");
        require(!stakeholders[voter].vote,"Already Voted");
        stakeholders[voter].accesstovote = access;
    }

    //function of voting
    ///if voted true then yes else no
    function castAVote(uint qID, bool cast, uint256 currentTime_) public {
        Stakeholder storage sender = stakeholders[msg.sender];
        require(sender.accesstovote !=0, " No right to vote");
        require(!sender.vote , "Already Voted");

        for(uint i = 0; i < questions.length; i++) {
            require(currentTime_ >= questions[i].StartTime, "Voting Lines are not opened yet");
            require(currentTime_ <= questions[i].EndTime,"Voting Lines are closed");
            if(questions[i].id == qID) {
                if(cast == true ) {
                    questions[i].vote_count_yes += 1;
                } else {
                    questions[i].vote_count_no += 1;
                }
                break;
            }
        }
        sender.vote = true;
        sender.accesstovote = 0; 
           
    }
        
    ////final results
    function results(uint qID, uint256 currentTime_) public view returns(string memory majority_result){
        require(stakeholders[msg.sender].accesstovote == 1, "No access to voting/viewing results");
        for(uint i = 0; i < questions.length; i++) {
            require(currentTime_ > questions[i].EndTime,"Voting is not done yet");
            if(questions[i].id == qID) {
                if(questions[i].vote_count_yes > questions[i].vote_count_no) {
                    majority_result = "True";
                } else {
                    majority_result = "False";
                }
                break;
            }
        }
    }
}
