import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { ethers } from "hardhat";

describe("Coin", function () {
  async function deployFixture() {
    const [player, someOtherWallet] = await ethers.getSigners();

    const Coin = await ethers.deployContract("Coin");
    await Coin.waitForDeployment();
    const CoinAddr = Coin.target;
    console.log("Адрес Coin токена:", CoinAddr);
    console.log("Ваш баланс:", await Coin.balanceOf(player));

    return { Coin, player, someOtherWallet };
  }

  it("hack", async function () {
    const { Coin, player, someOtherWallet } = await loadFixture(deployFixture);

    await Coin.connect(player).approve(someOtherWallet, await Coin.INITIAL_SUPPLY());
    await Coin.connect(someOtherWallet).transferFrom(
      player,
      someOtherWallet,
      await Coin.INITIAL_SUPPLY()
    );
    // баланс контракта прокси в токене HSE должен стать 0
    expect(await Coin.balanceOf(player)).to.equal(0);
  });
});
