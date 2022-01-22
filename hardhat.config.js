require("@nomiclabs/hardhat-waffle");
const projectId = 'fda4a204559140fd9668efcacb9b3593'
const fs = require('fs')
const keyData = fs.readFileSync('./.env',{
  endcoding:'utf8', flag:'r'
});

module.exports = {
  defaultNetwork: 'hardhat',
  networks:{
    hardhat:{
      chainId: 1337 // config standard
    },
    mumbai:{
      url:`https://polygon-mumbai.infura.io/v3/${projectId}`,
      accounts:[]
    },
    mainnet:{
      url:`https://mainnet.infura.io/v3/${projectId}`,
      accounts:[]
    }
  },
  solidity:{
    version: "0.8.4",
    settings:{
      optimizer:{ 
      enabled: true,
      runs:2000
      }
    }
  }
};