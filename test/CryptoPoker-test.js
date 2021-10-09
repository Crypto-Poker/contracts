const { expect } = require("chai");
const { ethers } = require("hardhat");

const cardInfoList = [
    { name: 'SPADE_2', cardType: 'SPADE', displayValue: '2', diamonTokenId: 0, weaponTokenId: 0, value: 2, level: 1, powerValue: 100, attackPower: 3, votality: 1, rarity: 0, },
    { name: 'HEART_2', cardType: 'HEART', displayValue: '2', diamonTokenId: 0, weaponTokenId: 0, value: 2, level: 1, powerValue: 100, attackPower: 2, votality: 2, rarity: 0, },
    { name: 'CLUB_2', cardType: 'CLUB', displayValue: '2', diamonTokenId: 0, weaponTokenId: 0, value: 2, level: 1, powerValue: 100, attackPower: 2, votality: 2, rarity: 0, },
    { name: 'DIAMOND_2', cardType: 'DIAMOND', displayValue: '2', diamonTokenId: 0, weaponTokenId: 0, value: 2, level: 1, powerValue: 100, attackPower: 1, votality: 3, rarity: 0, },

    { name: 'SPADE_3', cardType: 'SPADE', displayValue: '3', diamonTokenId: 0, weaponTokenId: 0, value: 3, level: 1, powerValue: 110, attackPower: 2, votality: 3, rarity: 0, },
    { name: 'HEART_3', cardType: 'HEART', displayValue: '3', diamonTokenId: 0, weaponTokenId: 0, value: 3, level: 1, powerValue: 110, attackPower: 1, votality: 3, rarity: 0, },
    { name: 'CLUB_3', cardType: 'CLUB', displayValue: '3', diamonTokenId: 0, weaponTokenId: 0, value: 3, level: 1, powerValue: 110, attackPower: 2, votality: 4, rarity: 0, },
    { name: 'DIAMOND_3', cardType: 'DIAMOND', displayValue: '3', diamonTokenId: 0, weaponTokenId: 0, value: 3, level: 1, powerValue: 110, attackPower: 2, votality: 3, rarity: 0, },

    { name: 'SPADE_4', cardType: 'SPADE', displayValue: '4', diamonTokenId: 0, weaponTokenId: 0, value: 4, level: 1, powerValue: 120, attackPower: 3, votality: 5, rarity: 0, },
    { name: 'HEART_4', cardType: 'HEART', displayValue: '4', diamonTokenId: 0, weaponTokenId: 0, value: 4, level: 1, powerValue: 120, attackPower: 2, votality: 3, rarity: 0, },
    { name: 'CLUB_4', cardType: 'CLUB', displayValue: '4', diamonTokenId: 0, weaponTokenId: 0, value: 4, level: 1, powerValue: 120, attackPower: 2, votality: 3, rarity: 0, },
    { name: 'DIAMOND_4', cardType: 'DIAMOND', displayValue: '4', diamonTokenId: 0, weaponTokenId: 0, value: 4, level: 1, powerValue: 120, attackPower: 2, votality: 3, rarity: 0, },

    { name: 'SPADE_5', cardType: 'SPADE', displayValue: '5', diamonTokenId: 0, weaponTokenId: 0, value: 5, level: 1, powerValue: 130, attackPower: 2, votality: 6, rarity: 0, },
    { name: 'HEART_5', cardType: 'HEART', displayValue: '5', diamonTokenId: 0, weaponTokenId: 0, value: 5, level: 1, powerValue: 130, attackPower: 2, votality: 4, rarity: 0, },
    { name: 'CLUB_5', cardType: 'CLUB', displayValue: '5', diamonTokenId: 0, weaponTokenId: 0, value: 5, level: 1, powerValue: 130, attackPower: 3, votality: 2, rarity: 0, },
    { name: 'DIAMOND_5', cardType: 'DIAMOND', displayValue: '5', diamonTokenId: 0, weaponTokenId: 0, value: 5, level: 1, powerValue: 130, attackPower: 2, votality: 4, rarity: 0, },

    { name: 'SPADE_6', cardType: 'SPADE', displayValue: '6', diamonTokenId: 0, weaponTokenId: 0, value: 6, level: 1, powerValue: 140, attackPower: 2, votality: 7, rarity: 0, },
    { name: 'HEART_6', cardType: 'HEART', displayValue: '6', diamonTokenId: 0, weaponTokenId: 0, value: 6, level: 1, powerValue: 140, attackPower: 1, votality: 6, rarity: 0, },
    { name: 'CLUB_6', cardType: 'CLUB', displayValue: '6', diamonTokenId: 0, weaponTokenId: 0, value: 6, level: 1, powerValue: 140, attackPower: 2, votality: 4, rarity: 0, },
    { name: 'DIAMOND_6', cardType: 'DIAMOND', displayValue: '6', diamonTokenId: 0, weaponTokenId: 0, value: 6, level: 1, powerValue: 140, attackPower: 2, votality: 5, rarity: 0, },

    { name: 'SPADE_7', cardType: 'SPADE', displayValue: '7', diamonTokenId: 0, weaponTokenId: 0, value: 7, level: 1, powerValue: 200, attackPower: 4, votality: 6, rarity: 1, },
    { name: 'HEART_7', cardType: 'HEART', displayValue: '7', diamonTokenId: 0, weaponTokenId: 0, value: 7, level: 1, powerValue: 200, attackPower: 5, votality: 6, rarity: 1, },
    { name: 'CLUB_7', cardType: 'CLUB', displayValue: '7', diamonTokenId: 0, weaponTokenId: 0, value: 7, level: 1, powerValue: 200, attackPower: 4, votality: 3, rarity: 1, },
    { name: 'DIAMOND_7', cardType: 'DIAMOND', displayValue: '7', diamonTokenId: 0, weaponTokenId: 0, value: 7, level: 1, powerValue: 200, attackPower: 2, votality: 5, rarity: 1, },

    { name: 'SPADE_8', cardType: 'SPADE', displayValue: '8', diamonTokenId: 0, weaponTokenId: 0, value: 8, level: 1, powerValue: 220, attackPower: 7, votality: 4, rarity: 1, },
    { name: 'HEART_8', cardType: 'HEART', displayValue: '8', diamonTokenId: 0, weaponTokenId: 0, value: 8, level: 1, powerValue: 220, attackPower: 3, votality: 8, rarity: 1, },
    { name: 'CLUB_8', cardType: 'CLUB', displayValue: '8', diamonTokenId: 0, weaponTokenId: 0, value: 8, level: 1, powerValue: 220, attackPower: 4, votality: 4, rarity: 1, },
    { name: 'DIAMOND_8', cardType: 'DIAMOND', displayValue: '8', diamonTokenId: 0, weaponTokenId: 0, value: 8, level: 1, powerValue: 220, attackPower: 3, votality: 6, rarity: 1, },

    { name: 'SPADE_9', cardType: 'SPADE', displayValue: '9', diamonTokenId: 0, weaponTokenId: 0, value: 9, level: 1, powerValue: 240, attackPower: 6, votality: 6, rarity: 1, },
    { name: 'HEART_9', cardType: 'HEART', displayValue: '9', diamonTokenId: 0, weaponTokenId: 0, value: 9, level: 1, powerValue: 240, attackPower: 7, votality: 5, rarity: 1, },
    { name: 'CLUB_9', cardType: 'CLUB', displayValue: '9', diamonTokenId: 0, weaponTokenId: 0, value: 9, level: 1, powerValue: 240, attackPower: 4, votality: 6, rarity: 1, },
    { name: 'DIAMOND_9', cardType: 'DIAMOND', displayValue: '9', diamonTokenId: 0, weaponTokenId: 0, value: 9, level: 1, powerValue: 240, attackPower: 7, votality: 2, rarity: 1, },

    { name: 'SPADE_10', cardType: 'SPADE', displayValue: '10', diamonTokenId: 0, weaponTokenId: 0, value: 10, level: 1, powerValue: 280, attackPower: 5, votality: 9, rarity: 1, },
    { name: 'HEART_10', cardType: 'HEART', displayValue: '10', diamonTokenId: 0, weaponTokenId: 0, value: 10, level: 1, powerValue: 280, attackPower: 4, votality: 10, rarity: 1, },
    { name: 'CLUB_10', cardType: 'CLUB', displayValue: '10', diamonTokenId: 0, weaponTokenId: 0, value: 10, level: 1, powerValue: 280, attackPower: 5, votality: 6, rarity: 1, },
    { name: 'DIAMOND_10', cardType: 'DIAMOND', displayValue: '10', diamonTokenId: 0, weaponTokenId: 0, value: 10, level: 1, powerValue: 280, attackPower: 3, votality: 8, rarity: 1, },

    { name: 'SPADE_J', cardType: 'SPADE', displayValue: 'J', diamonTokenId: 0, weaponTokenId: 0, value: 11, level: 1, powerValue: 500, attackPower: 7, votality: 10, rarity: 2, },
    { name: 'HEART_J', cardType: 'HEART', displayValue: 'J', diamonTokenId: 0, weaponTokenId: 0, value: 11, level: 1, powerValue: 500, attackPower: 6, votality: 9, rarity: 2, },
    { name: 'CLUB_J', cardType: 'CLUB', displayValue: 'J', diamonTokenId: 0, weaponTokenId: 0, value: 11, level: 1, powerValue: 500, attackPower: 5, votality: 7, rarity: 2, },
    { name: 'DIAMOND_J', cardType: 'DIAMOND', displayValue: 'J', diamonTokenId: 0, weaponTokenId: 0, value: 11, level: 1, powerValue: 500, attackPower: 8, votality: 8, rarity: 2, },

    { name: 'SPADE_Q', cardType: 'SPADE', displayValue: 'Q', diamonTokenId: 0, weaponTokenId: 0, value: 12, level: 1, powerValue: 600, attackPower: 8, votality: 11, rarity: 2, },
    { name: 'HEART_Q', cardType: 'HEART', displayValue: 'Q', diamonTokenId: 0, weaponTokenId: 0, value: 12, level: 1, powerValue: 600, attackPower: 5, votality: 11, rarity: 2, },
    { name: 'CLUB_Q', cardType: 'CLUB', displayValue: 'Q', diamonTokenId: 0, weaponTokenId: 0, value: 12, level: 1, powerValue: 600, attackPower: 5, votality: 12, rarity: 2, },
    { name: 'DIAMOND_Q', cardType: 'DIAMOND', displayValue: 'Q', diamonTokenId: 0, weaponTokenId: 0, value: 12, level: 1, powerValue: 600, attackPower: 7, votality: 13, rarity: 2, },

    { name: 'SPADE_K', cardType: 'SPADE', displayValue: 'K', diamonTokenId: 0, weaponTokenId: 0, value: 13, level: 1, powerValue: 2000, attackPower: 6, votality: 17, rarity: 3, },
    { name: 'HEART_K', cardType: 'HEART', displayValue: 'K', diamonTokenId: 0, weaponTokenId: 0, value: 13, level: 1, powerValue: 2000, attackPower: 6, votality: 14, rarity: 3, },
    { name: 'CLUB_K', cardType: 'CLUB', displayValue: 'K', diamonTokenId: 0, weaponTokenId: 0, value: 13, level: 1, powerValue: 2000, attackPower: 2, votality: 12, rarity: 3, },
    { name: 'DIAMOND_K', cardType: 'DIAMOND', displayValue: 'K', diamonTokenId: 0, weaponTokenId: 0, value: 13, level: 1, powerValue: 2000, attackPower: 15, votality: 9, rarity: 3, },

    { name: 'SPADE_A', cardType: 'SPADE', displayValue: 'A', diamonTokenId: 0, weaponTokenId: 0, value: 14, level: 1, powerValue: 2500, attackPower: 10, votality: 15, rarity: 3, },
    { name: 'HEART_A', cardType: 'HEART', displayValue: 'A', diamonTokenId: 0, weaponTokenId: 0, value: 14, level: 1, powerValue: 2500, attackPower: 8, votality: 14, rarity: 3, },
    { name: 'CLUB_A', cardType: 'CLUB', displayValue: 'A', diamonTokenId: 0, weaponTokenId: 0, value: 14, level: 1, powerValue: 2500, attackPower: 9, votality: 13, rarity: 3, },
    { name: 'DIAMOND_A', cardType: 'DIAMOND', displayValue: 'A', diamonTokenId: 0, weaponTokenId: 0, value: 14, level: 1, powerValue: 2500, attackPower: 10, votality: 15, rarity: 3, },

    { name: 'SPADE_Joker', cardType: 'SPADE', displayValue: 'Joker', diamonTokenId: 0, weaponTokenId: 0, value: 15, level: 1, powerValue: 8000, attackPower: 25, votality: 25, rarity: 4, },
    { name: 'HEART_Joker', cardType: 'HEART', displayValue: 'Joker', diamonTokenId: 0, weaponTokenId: 0, value: 15, level: 1, powerValue: 10000, attackPower: 25, votality: 25, rarity: 4, },
];

async function addCardTemplate(address) {
    const CryptoPoker = await ethers.getContractFactory("CryptoPoker");
    const cryptoPoker = await CryptoPoker.attach(address);

    for (const index in cardInfoList) {
        cardInfo = cardInfoList[index];
        // console.log('add card modal: ', cardInfo);
        await cryptoPoker.addCardModal(cardInfo.name, cardInfo.cardType, cardInfo.displayValue,
            cardInfo.diamonTokenId, cardInfo.weaponTokenId, cardInfo.value, cardInfo.level,
            cardInfo.powerValue, cardInfo.attackPower, cardInfo.votality, cardInfo.rarity);
    }

    // for (let i = 0; i < 54; i++) {
    //     console.log((await cryptoPoker.cardTemplate(i)).toString());
    // }
}

describe("CryptoPoker", function () {
    before(async function () {
        this.CryptoPoker = await ethers.getContractFactory("CryptoPoker");
        this.PowerValueCalculator = await ethers.getContractFactory("PowerValueCalculator");
    });

    beforeEach(async function () {
        // We get the contract to deploy
        this.cryptoPoker = await this.CryptoPoker.deploy('Test NFT', 'TNF', 'http://www.baidu.com');
        await this.cryptoPoker.deployed();

        await addCardTemplate(this.cryptoPoker.address);
        // console.log("cryptoPoker deployed to: ", this.cryptoPoker.address);
    });

    it("Should mint success when the caller is owner", async function () {
        const [owner, other] = await ethers.getSigners();
        await expect(this.cryptoPoker.mint(owner.address))
            .to.emit(this.cryptoPoker, "Transfer");
        expect(await this.cryptoPoker.balanceOf(owner.address)).to.equal(1);
    });

    it("Should mint failed when the caller has not MINTER_ROLE", async function () {
        const [owner, other] = await ethers.getSigners();
        await expect(
            this.cryptoPoker.connect(other).mint(other.address)
        ).to.be.revertedWith('CryptoPoker: must have minter role to mint');
    });

    it("Should mint success when the caller granted to MINTER_ROLE", async function () {
        const [owner, other] = await ethers.getSigners();
        const keccak256 = require('keccak256');

        await expect(
            this.cryptoPoker.grantRole('0x' + keccak256('MINTER_ROLE').toString('hex'), other.address)
        ).to.emit(this.cryptoPoker, 'RoleGranted');

        await expect(
            this.cryptoPoker.connect(other).mint(other.address)
        ).to.emit(this.cryptoPoker, 'Transfer');
    });

    it("Check get token types", async function () {
        const types = ["Ordinary", "Rare", "Ledgends", "Epics", "Mythology"];
        const tokenTypes = await this.cryptoPoker.getTokenTypes();
        expect(tokenTypes).to.eql(types);
    });

    it("Nonexistent token should revert for check token uri", async function () {
        await expect(this.cryptoPoker.tokenURI(100))
            .to.revertedWith('ERC721Metadata: URI query for nonexistent token');
    });

    it("Valid token should return token uri", async function () {
        const [owner, second] = await ethers.getSigners();
        await this.cryptoPoker.mint(owner.address);
        expect(await this.cryptoPoker.balanceOf(owner.address)).to.equal(1);

        const tokenUri = await this.cryptoPoker.tokenURI(1);
        console.log(tokenUri);
        expect(await this.cryptoPoker.tokenURI(1)).to.not.equal('');

        for (let i = 2; i < 50; i++) {
            await this.cryptoPoker.mint(owner.address);
            // const tokenUri = await this.cryptoPoker.tokenURI(i);
            // console.log(tokenUri);
        }

        const totalPowerValue = await this.cryptoPoker.getTotalBasicPowerValue();
        console.log(`total basic power value: ${totalPowerValue.toString()}`);

        const totalExtraPowerValue = await this.cryptoPoker.getTotalExtralPowerValue();
        console.log(`total extra power value: ${totalExtraPowerValue.toString()}`);

        let userBasicPowerValue = await this.cryptoPoker.getUserBasicPowerValue(owner.address);
        console.log(`owner basic power value: ${userBasicPowerValue.toString()}`);

        let userExtraPowerValue = await this.cryptoPoker.getUserExtraPowerValue(owner.address);
        console.log(`owner extra power value: ${userExtraPowerValue.toString()}`);
    });

    it("Token Id should starts from 1", async function () {
        const [owner] = await ethers.getSigners();
        await this.cryptoPoker.mint(owner.address);
        expect(await this.cryptoPoker.balanceOf(owner.address)).to.equal(1);

        tokenId = await this.cryptoPoker.tokenOfOwnerByIndex(owner.address, 0);
        // tokens = await this.cryptoPoker.getUserTokensWithPaged(owner.address, 0, 1);
        // console.log(tokenId.toString());
        expect(
            await this.cryptoPoker.tokenOfOwnerByIndex(owner.address, 0)
        ).to.equal(1);
    });

    it("Get user tokens with valid page params should success", async function () {
        const [owner] = await ethers.getSigners();
        await this.cryptoPoker.mint(owner.address);
        await this.cryptoPoker.mint(owner.address);
        await this.cryptoPoker.mint(owner.address);
        expect(await this.cryptoPoker.balanceOf(owner.address)).to.equal(3);

        tokens = await this.cryptoPoker.getUserTokensWithPaged(owner.address, 0, 3);
        ids = ['1', '2', '3']
        for (const index in tokens) {
            expect(tokens[index].toString()).to.equal(ids[index]);
        }

        tokens = await this.cryptoPoker.getUserTokensWithPaged(owner.address, 1, 2);
        expect(tokens.toString()).to.equal('3');
    });

    it("Get user tokens with invalid page params should fail", async function () {
        const [owner] = await ethers.getSigners();
        await this.cryptoPoker.mint(owner.address);
        await this.cryptoPoker.mint(owner.address);
        await this.cryptoPoker.mint(owner.address);
        expect(await this.cryptoPoker.balanceOf(owner.address)).to.equal(3);

        await expect(
            this.cryptoPoker.getUserTokensWithPaged(owner.address, 1, 3)
        ).to.revertedWith('getUserTokensWithPaged: page parameter error');
    });

    it("transfer from approved user with approved token id should success", async function () {
        const [owner, spender] = await ethers.getSigners();
        await this.cryptoPoker.mint(owner.address);
        await this.cryptoPoker.mint(owner.address);
        await this.cryptoPoker.mint(owner.address);
        expect(await this.cryptoPoker.balanceOf(owner.address)).to.equal(3);

        await expect(
            this.cryptoPoker.approve(spender.address, 1)
        ).to.emit(this.cryptoPoker, 'Approval');

        await expect(
            this.cryptoPoker.connect(spender).transferFrom(owner.address, spender.address, 1)
        ).to.emit(this.cryptoPoker, 'Transfer');
        expect(await this.cryptoPoker.balanceOf(spender.address)).to.equal(1);
    });

    it("transfer from approved user with not approved token id should fail", async function () {
        const [owner, spender] = await ethers.getSigners();
        await this.cryptoPoker.mint(owner.address);
        await this.cryptoPoker.mint(owner.address);
        await this.cryptoPoker.mint(owner.address);
        expect(await this.cryptoPoker.balanceOf(owner.address)).to.equal(3);

        await expect(
            this.cryptoPoker.connect(spender).transferFrom(owner.address, spender.address, 1)
        ).to.revertedWith('ERC721: transfer caller is not owner nor approved');
    });

    it("transfer from approved user with approved all tokens should success", async function () {
        const [owner, spender] = await ethers.getSigners();
        await this.cryptoPoker.mint(owner.address);
        await this.cryptoPoker.mint(owner.address);
        await this.cryptoPoker.mint(owner.address);
        expect(await this.cryptoPoker.balanceOf(owner.address)).to.equal(3);

        await expect(
            this.cryptoPoker.setApprovalForAll(spender.address, true)
        ).to.emit(this.cryptoPoker, 'ApprovalForAll');

        await expect(
            this.cryptoPoker.connect(spender).transferFrom(owner.address, spender.address, 1)
        ).to.emit(this.cryptoPoker, 'Transfer');
        await expect(
            this.cryptoPoker.connect(spender).transferFrom(owner.address, spender.address, 2)
        ).to.emit(this.cryptoPoker, 'Transfer');
        expect(await this.cryptoPoker.balanceOf(spender.address)).to.equal(2);

        await expect(
            this.cryptoPoker.connect(spender).transferFrom(owner.address, spender.address, 12)
        ).to.revertedWith('ERC721: operator query for nonexistent token');
    });

    it("Upgrade card should failed with 3 same card", async function () {
        const [owner] = await ethers.getSigners();
        await this.cryptoPoker.mint(owner.address);
        expect(await this.cryptoPoker.balanceOf(owner.address)).to.equal(1);

        await expect(
            this.cryptoPoker.upgradeToken(1, 1, 1)
        ).to.revertedWith('upgradeToken: you must use 3 unique cards');
    });

    it("Upgrade card should failed if trigger is not the ownner", async function () {
        const [owner, spender] = await ethers.getSigners();
        await this.cryptoPoker.mint(owner.address);
        expect(await this.cryptoPoker.balanceOf(owner.address)).to.equal(1);

        await expect(
            this.cryptoPoker.connect(spender).upgradeToken(1, 1, 1)
        ).to.revertedWith('upgradeToken: caller is not owner');
    });

    it("Upgrade card should failed if 3 cards not the same type", async function () {
        const [owner, spender] = await ethers.getSigners();
        await this.cryptoPoker.mint(owner.address);
        await this.cryptoPoker.mint(owner.address);
        await this.cryptoPoker.mint(owner.address);
        expect(await this.cryptoPoker.balanceOf(owner.address)).to.equal(3);

        console.log(await this.cryptoPoker.tokenURI(1))
        console.log(await this.cryptoPoker.tokenURI(2))
        console.log(await this.cryptoPoker.tokenURI(3))

        await expect(
            this.cryptoPoker.upgradeToken(1, 2, 3)
        ).to.revertedWith('upgradeToken: specified 3 cards must be the same type');

        // const tokenUri = await this.cryptoPoker.tokenURI(4);
        // console.log(tokenUri);
    });

    it("Upgrade card should success if all condition meeting", async function () {
        const [owner, spender] = await ethers.getSigners();

        let spade3Count = 0;
        let spade3Ids = [];
        let index = 1;

        while (spade3Count < 3) {
            await this.cryptoPoker.mint(owner.address);
            const info = await this.cryptoPoker.tokenURI(index);
            const cardInfo = JSON.parse(info);
            if (cardInfo.name == 'SPADE_3') {
                spade3Count += 1;
                spade3Ids.push(index);
            }
            index += 1;
        }

        await expect(
            this.cryptoPoker.upgradeToken(spade3Ids[0], spade3Ids[1], spade3Ids[2])
        ).to.emit(this.cryptoPoker, 'PokerCardUpgraded');

        const tokenUri = await this.cryptoPoker.tokenURI(index);
        console.log(tokenUri);

        let tokenInfo = await this.cryptoPoker.getTokenInfo(index);
        console.log(tokenInfo);
        console.log(tokenInfo.toString());
    });

    it("Create Joker should successfully created by owner", async function () {
        const [owner] = await ethers.getSigners();
        await this.cryptoPoker.createJoker(owner.address, true);
        expect(await this.cryptoPoker.balanceOf(owner.address)).to.equal(1);
        
        let tokenInfo = await this.cryptoPoker.getTokenInfo(1);
        console.log(tokenInfo);
        expect(tokenInfo.name).to.equal('HEART_Joker');

        await this.cryptoPoker.createJoker(owner.address, false);
        expect(await this.cryptoPoker.balanceOf(owner.address)).to.equal(2);

        tokenInfo = await this.cryptoPoker.getTokenInfo(2);
        console.log(tokenInfo);
        expect(tokenInfo.name).to.equal('SPADE_Joker');
    });
});
