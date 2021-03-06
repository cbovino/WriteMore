import web3 from "web3"

const webthree = new web3("http://127.0.0.1:7545")

const jsonInterface = [
  {
    "inputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "_from",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "_value",
        "type": "uint256"
      }
    ],
    "name": "committed",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "atStakeAmount",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "duration",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "cutOff",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "latestSubmitDate",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "daysMissed",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "returnAmount",
        "type": "uint256"
      }
    ],
    "name": "committmentDetails",
    "type": "event"
  },
  {
    "constant": false,
    "inputs": [
      {
        "internalType": "uint256",
        "name": "cutOff",
        "type": "uint256"
      }
    ],
    "name": "initialCommit",
    "outputs": [],
    "payable": true,
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [],
    "name": "returnCommitmentDetails",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "internalType": "uint256",
        "name": "currentSubmissionDate",
        "type": "uint256"
      }
    ],
    "name": "updateCommitment",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "getBalance",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [],
    "name": "destroy",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  }
];


(async () => {


    // @ts-ignore
    const writemore =  new webthree.eth.Contract(jsonInterface, "0x4ADe3437f1111dfa8bb87ddae86E7D714Fe1F723");
    
    // @ts-ignore
    // const trans = await writemore.methods.initialCommit(1618919095).send({from: "0xCA743d77D9C2f01Aa866d12c5d3fE66Af35E9931", gas: "6721975", gasPrice:"2000", value: "20000000000000000"});
    const trans = await writemore.methods.returnCommitmentDetails().send({from: "0xCA743d77D9C2f01Aa866d12c5d3fE66Af35E9931", gas: "6721975", gasPrice:"2000"})
    console.log(trans.events.committmentDetails.returnValues)
})()

