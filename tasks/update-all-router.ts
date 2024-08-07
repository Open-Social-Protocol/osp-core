import '@nomiclabs/hardhat-ethers';
import fs from 'fs';
import { task } from 'hardhat/config';
import { OspRouterImmutable__factory } from '../target/typechain-types';
import { deployContract, getAddresses, waitForTx } from './helpers/utils';
import { getDeployer } from './helpers/kms';

function getFunSig(logicName: string) {
  const interfaceName = logicName.at(0)?.toUpperCase() + logicName.slice(1);
  return JSON.parse(
    fs
      .readFileSync(`./target/fun-sig/core/logics/interfaces/I${interfaceName}Logic.json`)
      .toString()
  );
}

task('update-router', 'update-router')
  .addParam('logic')
  .addParam('env')
  .setAction(async ({ logic, env }, hre) => {
    const { ospAddressConfig, calldata } = await getUpdateCallDatas(logic, hre, env);
    const router = OspRouterImmutable__factory.connect(
      ospAddressConfig.routerProxy,
      await getDeployer(hre)
    );
    await waitForTx(router.multicall(calldata));
    fs.writeFileSync(
      `addresses-${env}-${hre.network.name}.json`,
      JSON.stringify(ospAddressConfig, null, 2)
    );
  });

export async function getUpdateCallDatas(logic, hre, env) {
  const logics = (logic as string).split(',');
  console.log(logics);
  const ospAddressConfig = getAddresses(hre, env);
  const deployer = await getDeployer(hre);
  const ospAddress = ospAddressConfig.routerProxy;
  const router = OspRouterImmutable__factory.connect(ospAddress, deployer);
  const calldata: string[] = [];
  for (const logicName of logics) {
    console.log(`start update router ,logic is ${logicName}.`);
    const allRouters = await router.getAllRouters();
    const logicRouters = await router.getAllFunctionsOfRouter(
      ospAddressConfig[`${logicName}Logic`]
    );

    console.log('logic old functions:');
    console.log(logicRouters);

    const funSig = getFunSig(logicName);

    const removeFun = new Set(logicRouters);
    const updateFun: Set<any> = new Set();
    const addFun: Set<any> = new Set();

    for (const key in funSig) {
      const selector = funSig[key];
      if (logicRouters.find((item) => item == selector)) {
        removeFun.delete(selector);
        updateFun.add({
          functionSignature: key,
          functionSelector: selector,
        });
      } else {
        addFun.add({
          functionSignature: key,
          functionSelector: selector,
        });
      }
    }
    console.log('remove functions:');
    console.log(removeFun);
    console.log('update functions:');
    console.log(updateFun);
    console.log('add functions:');
    console.log(addFun);
    const logicContract = await deployContract(
      hre.ethers.deployContract(
        // eslint-disable-next-line @typescript-eslint/ban-ts-comment
        // @ts-ignore
        `${logicName.at(0).toUpperCase() + logicName.slice(1)}Logic`,
        deployer
      )
    );
    const contractAddress = logicContract.address;
    console.log(`deploy logic contract: ${logicContract.address}`);
    removeFun.forEach((selector) => {
      calldata.push(
        router.interface.encodeFunctionData('removeRouter', [
          selector,
          // eslint-disable-next-line @typescript-eslint/ban-ts-comment
          // @ts-ignore
          allRouters.find((item) => item.functionSelector == selector).functionSignature as string,
        ])
      );
    });

    updateFun.forEach((item) => {
      calldata.push(
        router.interface.encodeFunctionData('updateRouter', [
          {
            functionSignature: item.functionSignature,
            functionSelector: item.functionSelector,
            routerAddress: contractAddress,
          },
        ])
      );
    });

    addFun.forEach((item) => {
      calldata.push(
        router.interface.encodeFunctionData('addRouter', [
          {
            functionSignature: item.functionSignature,
            functionSelector: item.functionSelector,
            routerAddress: contractAddress,
          },
        ])
      );
    });
    ospAddressConfig[`${logicName}Logic`] = contractAddress;
  }
  console.log(calldata);
  console.log(calldata.length);
  return { ospAddressConfig, calldata };
}
