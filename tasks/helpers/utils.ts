import '@nomiclabs/hardhat-ethers';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { Contract, ContractTransaction, PopulatedTransaction } from 'ethers';
import fs from 'fs';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { hardhatAccounts } from '../../config/hardhat-accounts';

export const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';

export enum ProtocolState {
  Unpaused,
  PublishingPaused,
  Paused,
}

export function getAddrs(): any {
  const json = fs.readFileSync('addresses.json', 'utf8');
  const addrs = JSON.parse(json);
  return addrs;
}

export async function waitForTx(tx: Promise<ContractTransaction>) {
  await (await tx).wait();
}

export async function deployContract(tx: any): Promise<Contract> {
  const result = await tx;
  await result.deployTransaction.wait();
  return result;
}

export async function deployWithVerify(
  tx: any,
  args: any,
  contractPath: string
): Promise<Contract> {
  const deployedContract = await deployContract(tx);
  let count = 0;
  const maxTries = 8;
  const runtimeHRE = require('hardhat');
  while (true) {
    await delay(10000);
    try {
      console.log('Verifying contract at', deployedContract.address);
      await runtimeHRE.run('verify:verify', {
        address: deployedContract.address,
        constructorArguments: args,
        contract: contractPath,
      });
      break;
    } catch (error) {
      if (String(error).includes('Already Verified')) {
        console.log(
          `Already verified contract at ${contractPath} at address ${deployedContract.address}`
        );
        break;
      }
      if (++count == maxTries) {
        console.log(
          `Failed to verify contract at ${contractPath} at address ${deployedContract.address}, error: ${error}`
        );
        break;
      }
      console.log(`Retrying... Retry #${count}, last error: ${error}`);
    }
  }
  return deployedContract;
}

export async function verify(address: string, args: any, contractPath: string): Promise<string> {
  let count = 0;
  const maxTries = 8;
  const runtimeHRE = require('hardhat');
  while (true) {
    await delay(10000);
    try {
      console.log('Verifying contract at', address);
      await runtimeHRE.run('verify:verify', {
        address: address,
        constructorArguments: args,
        contract: contractPath,
      });
      break;
    } catch (error) {
      if (String(error).includes('Already Verified')) {
        console.log(`Already verified contract at ${contractPath} at address ${address}`);
        break;
      }
      if (++count == maxTries) {
        console.log(
          `Failed to verify contract at ${contractPath} at address ${address}, error: ${error}`
        );
        break;
      }
      console.log(`Retrying... Retry #${count}, last error: ${error}`);
    }
  }
  return address;
}

export async function initEnv(hre: HardhatRuntimeEnvironment): Promise<SignerWithAddress[]> {
  const ethers = hre.ethers; // This allows us to access the hre (Hardhat runtime environment)'s injected ethers instance easily

  const accounts = await ethers.getSigners(); // This returns an array of the default signers connected to the hre's ethers instance
  const governance = accounts[1];
  const treasury = accounts[2];
  const user = accounts[3];

  return [governance, treasury, user];
}

async function delay(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

export function isHardhatNetwork(hre): boolean {
  return (
    hre.network.config.accounts instanceof Array &&
    hre.network.config.accounts.length == hardhatAccounts.length
  );
}

export type OspAddress = {
  routerProxy: string;
  governanceLogic?: string;
  profileLogic?: string;
  communityLogic?: string;
  contentLogic?: string;
  relationLogic?: string;
  //impl
  followSBTImpl?: string;
  joinNFTImpl?: string;
  communityNFT: string;
  //nftProxy
  communityNFTProxy: string;
  //reaction
  voteReaction: string;
  //joinCondition
  holdTokenJoinCond: string;
  erc20FeeJoinCond: string;
  nativeFeeJoinCond: string;
  //referencedCondition
  onlyMemberReferenceCond: string;
  //condition
  slotNFTCommunityCond?: string;
  whitelistAddressCommunityCond: string;
};

export function getAddresses(hre, env): OspAddress | null {
  if (!fs.existsSync(`addresses-${env}-${hre.network.name}.json`)) {
    return null;
  }
  return JSON.parse(fs.readFileSync(`addresses-${env}-${hre.network.name}.json`).toString());
}
