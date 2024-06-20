import { task } from 'hardhat/config';
import { deployContract, getAddresses, OspAddress, waitForTx } from './helpers/utils';
import { getDeployer } from './helpers/kms';
import {
  FixedFeeCommunityCond,
  FixedFeeCommunityCond__factory,
  OspClient__factory,
  OspRouterImmutable,
  OspRouterImmutable__factory,
  PresaleSigCommunityCond__factory,
  WhitelistAddressCommunityCond__factory,
} from '../target/typechain-types';
import fs from 'fs';
import { create2_directory, deployCreate2, getDeployData } from './helpers/create2';
import { ethers } from 'ethers';

task('deploy-fixed-fee-cond-create2')
  .addParam('env')
  .setAction(async ({ env }, hre) => {
    const address: OspAddress = getAddresses(hre, env);
    const deployer = await getDeployer(hre);
    const ospClient = OspClient__factory.connect(address.routerProxy, deployer);
    const create2AccountFileName = `${create2_directory}/osp-${env}.json`;
    const create2 = JSON.parse(fs.readFileSync(create2AccountFileName).toString());
    if (!create2.fixedFeeCommunityCond) {
      create2.fixedFeeCommunityCond = getDeployData(
        new FixedFeeCommunityCond__factory(deployer).getDeployTransaction(address.routerProxy)
      );
      const json = JSON.stringify(create2, null, 2);
      fs.writeFileSync(create2AccountFileName, json, 'utf-8');
      console.log(create2.fixedFeeCommunityCond);
    }
    await deployCreate2(create2.fixedFeeCommunityCond, deployer);
    const fixedFeeCond: FixedFeeCommunityCond = FixedFeeCommunityCond__factory.connect(
      create2.fixedFeeCommunityCond.address,
      deployer
    );
    await waitForTx(
      fixedFeeCond.setFixedFeeCondData({
        price1Letter: ethers.utils.parseEther('2.048'),
        price2Letter: ethers.utils.parseEther('0.256'),
        price3Letter: ethers.utils.parseEther('0.064'),
        price4Letter: ethers.utils.parseEther('0.016'),
        price5Letter: ethers.utils.parseEther('0.004'),
        price6Letter: ethers.utils.parseEther('0.002'),
        price7ToMoreLetter: ethers.utils.parseEther('0.001'),
        createStartTime: 1721404800, // 2024-07-20 00:00:00
        treasure: deployer.getAddress(),
      })
    );
    address.fixedFeeCommunityCond = create2.fixedFeeCommunityCond.address;
    fs.writeFileSync(
      `addresses-${env}-${hre.network.name}.json`,
      JSON.stringify(address, null, 2),
      'utf-8'
    );
    await waitForTx(ospClient.whitelistApp(create2.fixedFeeCommunityCond.address, true));
  });

task('redeploy-whitelist-cond-create2')
  .addParam('env')
  .setAction(async ({ env }, hre) => {
    const deployer = await getDeployer(hre);
    const addresses: OspAddress = getAddresses(hre, env);
    const ospClient = OspClient__factory.connect(addresses.routerProxy, deployer);
    const oldAddr = addresses.whitelistAddressCommunityCond;
    console.log(`old whitelist is ${oldAddr}`);
    const create2AccountFileName = `${create2_directory}/osp-${env}.json`;
    const create2 = JSON.parse(fs.readFileSync(create2AccountFileName).toString());
    const whitelistAddressCommunityCond = getDeployData(
      new WhitelistAddressCommunityCond__factory(deployer).getDeployTransaction(
        addresses.routerProxy
      )
    );
    if (create2.whitelistAddressCommunityCond.initCode == whitelistAddressCommunityCond.initCode) {
      throw new Error('same initCode');
    }
    create2.whitelistAddressCommunityCond = whitelistAddressCommunityCond;
    const json = JSON.stringify(create2, null, 2);
    fs.writeFileSync(create2AccountFileName, json, 'utf-8');
    addresses.whitelistAddressCommunityCond = whitelistAddressCommunityCond.address;
    fs.writeFileSync(
      `addresses-${env}-${hre.network.name}.json`,
      JSON.stringify(addresses, null, 2)
    );
    await deployCreate2(whitelistAddressCommunityCond, deployer);
    const initData = [
      ospClient.interface.encodeFunctionData('whitelistApp', [oldAddr, false]),
      ospClient.interface.encodeFunctionData('whitelistApp', [
        whitelistAddressCommunityCond.address,
        true,
      ]),
    ];
    const router: OspRouterImmutable = OspRouterImmutable__factory.connect(
      create2.ospRouter.address,
      deployer
    );
    await waitForTx(router.connect(deployer).multicall(initData));
  });

//dev PresaleSigCommunityCond deployed at 0x4519a02901d0881daC65C54C8CAD619d0C0ED97d
//beta PresaleSigCommunityCond deployed at 0x2210BA143E2c6144F11F23C4267E0830224F2dAF
task('deploy-presale-sig-cond')
  .addParam('env')
  .setAction(async ({ env }, hre) => {
    const signer: Record<string, string> = {
      dev: '0x511436a5199827dd1aa37462a680921a410d0947',
      beta: '0x511436a5199827dd1aa37462a680921a410d0947',
      pre: '0xee59c698401c9f7a949b8c1d3012c57349acb82d',
      prod: '0xca2771d61e2bde5c005cc44f6fab3845b2c180e3',
    };
    const address: OspAddress = getAddresses(hre, env);
    const deployer = await getDeployer(hre);
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    const fixedFeeCommunityCond = address.fixedFeeCommunityCond!;
    console.log(`fixedFeeCommunityCond is ${fixedFeeCommunityCond}, ${address.routerProxy}`);
    const presaleSigCond = await deployContract(
      new PresaleSigCommunityCond__factory(deployer).deploy(
        address.routerProxy,
        fixedFeeCommunityCond,
        signer[env],
        Math.floor(Date.now() / 1000)
      )
    );
    console.log('PresaleSigCommunityCond deployed at', presaleSigCond.address);
    const ospClient = OspClient__factory.connect(address.routerProxy, deployer);
    await waitForTx(ospClient.whitelistApp(presaleSigCond.address, true));
  });
