import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { ethers } from "hardhat";

describe("Bank", function () {
  async function deployFixture() {
    const Bank = await ethers.deployContract("Bank", {
      value: ethers.parseEther("0.01"),
    });

    await Bank.waitForDeployment();

    console.log("Адрес контракта:", Bank.target);

    const contractBalance = await ethers.provider.getBalance(Bank.target);
    console.log("Баланс контракта:", ethers.formatEther(contractBalance), "ETH");

    return { Bank };
  }

  async function deployAttacker() {
    const [attacker] = await ethers.getSigners();
    const BankAttacker = await ethers.deployContract("BankAttacker", [attacker]);

    await BankAttacker.waitForDeployment();

    console.log("Адрес контракта BankAttacker:", BankAttacker.target);

    return { BankAttacker, attacker };
  }

  it("hack", async function () {
    const { Bank } = await loadFixture(deployFixture);
    const { BankAttacker, attacker } = await loadFixture(deployAttacker);

    console.log("Баланс атакующего:", ethers.formatEther(await ethers.provider.getBalance(attacker)), "ETH");

    await BankAttacker.connect(attacker).attack(Bank.target, { value: ethers.parseEther("0.001") });

    console.log("Баланс атакующего:", ethers.formatEther(await ethers.provider.getBalance(attacker)), "ETH");

    // баланс контракта Bank должен стать 0
    await Bank.setCompleted();
    expect(await Bank.completed()).to.equal(true);

    expect(await ethers.provider.getBalance(Bank.target)).to.equal(0);
  });
});
