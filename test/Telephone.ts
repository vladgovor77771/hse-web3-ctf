import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { ethers } from "hardhat";

describe("Telephone", function () {
  async function deployFixture() {
    const [player, owner] = await ethers.getSigners();

    const Telephone = await ethers.deployContract("Telephone", [owner]);
    await Telephone.waitForDeployment();
    const TelephoneAddr = Telephone.target;
    console.log("Адрес контракта Telephone:", TelephoneAddr);

    const TelephoneAttacker = await ethers.deployContract("TelephoneAttacker");
    await TelephoneAttacker.waitForDeployment();
    const TelephoneAttackerAddr = TelephoneAttacker.target;
    console.log("Адрес контракта TelephoneAttacker:", TelephoneAttackerAddr);

    return { Telephone, TelephoneAddr, TelephoneAttacker, player };
  }

  it("hack", async function () {
    const { Telephone, TelephoneAddr, TelephoneAttacker, player } = await loadFixture(deployFixture);

    await TelephoneAttacker.attack(TelephoneAddr, player)
    // теперь владелец контракта player, а не owner
    expect(await Telephone.owner()).to.equal(player);
  });
});
