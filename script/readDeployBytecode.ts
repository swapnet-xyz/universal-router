
import fs from 'fs';
import hre from 'hardhat';
import { UniversalRouter } from '../typechain'

export const generateRouterBytecodeWithImmutablesAsync = async (): Promise<{ deployedBytecode: string }> => {

    const PERMIT2_ADDRESS = "0x000000000022D473030F116dDEE9F6B43aC78BA3";
    const WETH = "0x4300000000000000000000000000000000000004";
    const FEW_FACTORY_ADDRESS = "0x455b20131D59f01d082df1225154fDA813E8CeE9";
    const UNSUPPORTED = "0x5ab1B56FB16238dB874258FB7847EFe248eb8496";

    const routerParameters = {
        permit2: PERMIT2_ADDRESS,
        weth9: WETH,
        fewFactory: FEW_FACTORY_ADDRESS,
        seaportV1_5: UNSUPPORTED,
        seaportV1_4: UNSUPPORTED,
        openseaConduit: UNSUPPORTED,
        nftxZap: UNSUPPORTED,
        x2y2: UNSUPPORTED,
        foundation: UNSUPPORTED,
        sudoswap: UNSUPPORTED,
        elementMarket: UNSUPPORTED,
        nft20Zap: UNSUPPORTED,
        cryptopunks: UNSUPPORTED,
        looksRareV2: UNSUPPORTED,
        routerRewardsDistributor: UNSUPPORTED,
        looksRareRewardsDistributor: UNSUPPORTED,
        looksRareToken: UNSUPPORTED,
        v2Factory: "0x5C346464d33F90bABaf70dB6388507CC889C1070",
        v3Factory: "0x792edAdE80af5fC680d96a2eD80A44247D2Cf6Fd",
        pairInitCodeHash: "0x96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f",
        poolInitCodeHash: "0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54",
        v2Thruster3kFactory: "0xb4A7D971D0ADea1c73198C97d7ab3f9CE4aaFA13",
        v2Thruster10kFactory: "0x37836821a2c03c171fB1a595767f4a16e2b93Fc4",
        v3ThrusterFactory: "0xa08ae3d3f4dA51C22d3c041E468bdF4C61405AaB",     // This is actually Thruster deployer contract address, which is separated from factory
        v2Thruster3kPairInitCodeHash: "0x6f0346418750a1a53597a51ceff4f294b5f0e87f09715525b519d38ad3fab2cb",
        v2Thruster10kPairInitCodeHash: "0x32a9ff5a51b653cbafe88e38c4da86b859135750d3ca435f0ce732c8e3bb8335",
        v3ThrusterPoolInitCodeHash: "0xd0c3a51b16dbc778f000c620eaabeecd33b33a80bd145e1f7cbc0d4de335193d",
        v2RingswapFactory: "0x24F5Ac9A706De0cF795A8193F6AB3966B14ECfE6",
        v3RingswapFactory: "0x890509Fab3dD11D4Ff57d8471b5eAC74687E4C75",
        v2RingswapPairInitCodeHash: "0x501ce753061ab6e75837b15f074633bb775f5972f8dc1112fcc829c2e88dc689",
        v3RingswapPoolInitCodeHash: "0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54",
    };

    const routerFactory = await hre.ethers.getContractFactory('UniversalRouter');
    const router = (await routerFactory.deploy(routerParameters, { gasLimit: "30000000" })) as unknown as UniversalRouter;

    // console.log(`router address: ${router.address }`);
    const deployedBytecodeWithImmutables = await hre.network.provider.send('eth_getCode', [ router.address ]);
    // console.log(`deployedBytecodeWithImmutables: ${deployedBytecodeWithImmutables}`);
    return { deployedBytecode: deployedBytecodeWithImmutables };
};

generateRouterBytecodeWithImmutablesAsync().then(obj => {
    try {
        fs.statSync(`${__dirname}/../artifacts`);
    }
    catch(error) {
        fs.mkdirSync(`${__dirname}/../artifacts`);
    }
    fs.writeFileSync(`${__dirname}/../artifacts/routerDeployedBytecode.json`, JSON.stringify(obj, null, 4, "utf8"));
});