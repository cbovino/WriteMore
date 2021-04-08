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
      "constant": true,
      "inputs": [],
      "name": "getName",
      "outputs": [
        {
          "internalType": "string",
          "name": "",
          "type": "string"
        }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    }
];


(async () => {


    // @ts-ignore
    const helloworld =  new webthree.eth.Contract(jsonInterface, "0x7f5c84D7daaF958dd4FD64E1f46d7eAf255247Af");
    
    // @ts-ignore
    const trans = await helloworld.methods.getName().call();
    console.log(trans)
})()

