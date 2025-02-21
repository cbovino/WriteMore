// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition
import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const WriteMoreModule = buildModule("WriteMoreModule", (m) => {

  const writeMore = m.contract("WriteMore", [], {
    value: 0n, // No initial value needed for WriteMore contract
  });

  return { writeMore };
});

export default WriteMoreModule;
