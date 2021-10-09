const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PokerBox", function () {
    before(async function () {
        this.PokerBox = await ethers.getContractFactory("PokerBox");
    });

    beforeEach(async function () {
        this.pokerBox = await this.PokerBox.deploy('Poker Box', 'PokerBox', "https://pic.leetcode-cn.com/1627640862-HgXcTO-Frame%201444.jpg?x-oss-process=image%2Fformat%2Cwebp");
        await this.pokerBox.deployed();
        // console.log("PokerBox deployed to: ", this.pokerBox.address);
    });

    it("Should mint success when the caller is owner", async function () {
        const [owner, other] = await ethers.getSigners();
        await expect(this.pokerBox.mint(owner.address))
            .to.emit(this.pokerBox, "Transfer");
        expect(await this.pokerBox.balanceOf(owner.address)).to.equal(1);
    });

    it("Should mint failed when the caller has not MINTER_ROLE", async function () {
        const [owner, other] = await ethers.getSigners();
        await expect(
            this.pokerBox.connect(other).mint(other.address)
        ).to.be.revertedWith('PokerKey: must have minter role to mint');
    });

    it("Should mint success when the caller granted to MINTER_ROLE", async function () {
        const [owner, other] = await ethers.getSigners();
        const keccak256 = require('keccak256');

        await expect(
            this.pokerBox.grantRole('0x'+keccak256('MINTER_ROLE').toString('hex'), other.address)
        ).to.emit(this.pokerBox, 'RoleGranted');

        await expect(
            this.pokerBox.connect(other).mint(other.address)
        ).to.emit(this.pokerBox, 'Transfer');
    });

    it("Check get token types", async function () {
        expect(await this.pokerBox.getTokenTypes()).to.empty;
    });

    it("Nonexistent token should revert for check token uri", async function () {
        await expect(this.pokerBox.tokenURI(100))
            .to.revertedWith('ERC721Metadata: URI query for nonexistent token');
    });

    it("Valid token should return token uri", async function () {
        const [owner] = await ethers.getSigners();
        await this.pokerBox.mint(owner.address);
        expect(await this.pokerBox.balanceOf(owner.address)).to.equal(1);
        // console.log((await this.pokerBox.tokenURI(1)).toString());
        expect(await this.pokerBox.tokenURI(1)).to.not.equal('');
    });

    it("Token Id should starts from 1", async function () {
        const [owner] = await ethers.getSigners();
        await this.pokerBox.mint(owner.address);
        expect(await this.pokerBox.balanceOf(owner.address)).to.equal(1);

        tokenId = await this.pokerBox.tokenOfOwnerByIndex(owner.address, 0);
        // tokens = await this.pokerBox.getUserTokensWithPaged(owner.address, 0, 1);
        // console.log(tokenId.toString());
        expect(
            await this.pokerBox.tokenOfOwnerByIndex(owner.address, 0)
        ).to.equal(1);
    });

    it("Get user tokens with valid page params should success", async function () {
        const [owner] = await ethers.getSigners();
        await this.pokerBox.mint(owner.address);
        await this.pokerBox.mint(owner.address);
        await this.pokerBox.mint(owner.address);
        expect(await this.pokerBox.balanceOf(owner.address)).to.equal(3);

        tokens = await this.pokerBox.getUserTokensWithPaged(owner.address, 0, 3);
        ids = ['1', '2', '3']
        for (const index in tokens) {
            expect(tokens[index].toString()).to.equal(ids[index]);
        }

        tokens = await this.pokerBox.getUserTokensWithPaged(owner.address, 1, 2);
        expect(tokens.toString()).to.equal('3');
    });

    it("Get user tokens with invalid page params should fail", async function () {
        const [owner] = await ethers.getSigners();
        await this.pokerBox.mint(owner.address);
        await this.pokerBox.mint(owner.address);
        await this.pokerBox.mint(owner.address);
        expect(await this.pokerBox.balanceOf(owner.address)).to.equal(3);

        await expect(
            this.pokerBox.getUserTokensWithPaged(owner.address, 1, 3)
        ).to.revertedWith('getUserTokensWithPaged: page parameter error');
    });

    it("transfer from approved user with approved token id should success", async function () {
        const [owner, spender] = await ethers.getSigners();
        await this.pokerBox.mint(owner.address);
        await this.pokerBox.mint(owner.address);
        await this.pokerBox.mint(owner.address);
        expect(await this.pokerBox.balanceOf(owner.address)).to.equal(3);

        await expect(
            this.pokerBox.approve(spender.address, 1)
        ).to.emit(this.pokerBox, 'Approval');

        await expect(
            this.pokerBox.connect(spender).transferFrom(owner.address, spender.address, 1)
        ).to.emit(this.pokerBox, 'Transfer');
        expect(await this.pokerBox.balanceOf(spender.address)).to.equal(1);
    }); 

    it("transfer from approved user with not approved token id should fail", async function () {
        const [owner, spender] = await ethers.getSigners();
        await this.pokerBox.mint(owner.address);
        await this.pokerBox.mint(owner.address);
        await this.pokerBox.mint(owner.address);
        expect(await this.pokerBox.balanceOf(owner.address)).to.equal(3);

        await expect(
            this.pokerBox.connect(spender).transferFrom(owner.address, spender.address, 1)
        ).to.revertedWith('ERC721: transfer caller is not owner nor approved');
    });

    it("transfer from approved user with approved all tokens should success", async function () {
        const [owner, spender] = await ethers.getSigners();
        await this.pokerBox.mint(owner.address);
        await this.pokerBox.mint(owner.address);
        await this.pokerBox.mint(owner.address);
        expect(await this.pokerBox.balanceOf(owner.address)).to.equal(3);

        await expect(
            this.pokerBox.setApprovalForAll(spender.address, true)
        ).to.emit(this.pokerBox, 'ApprovalForAll');

        await expect(
            this.pokerBox.connect(spender).transferFrom(owner.address, spender.address, 1)
        ).to.emit(this.pokerBox, 'Transfer');
        await expect(
            this.pokerBox.connect(spender).transferFrom(owner.address, spender.address, 2)
        ).to.emit(this.pokerBox, 'Transfer');
        expect(await this.pokerBox.balanceOf(spender.address)).to.equal(2);

        await expect(
            this.pokerBox.connect(spender).transferFrom(owner.address, spender.address, 12)
        ).to.revertedWith('ERC721: operator query for nonexistent token');
    });
});
