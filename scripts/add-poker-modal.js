const { ethers, upgrades } = require("hardhat");

const cryptoPokerAddress = '0x12Bcb546bC60fF39F1Adfc7cE4605d5Bd6a6A876';
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
        console.log('add card modal: ', cardInfo);
        await cryptoPoker.addCardModal(cardInfo.name, cardInfo.cardType, cardInfo.displayValue,
            cardInfo.diamonTokenId, cardInfo.weaponTokenId, cardInfo.value, cardInfo.level,
            cardInfo.powerValue, cardInfo.attackPower, cardInfo.votality, cardInfo.rarity);
    }

    for (let i = 0; i < 54; i++) {
        console.log((await cryptoPoker.cardTemplate(i)).toString());
    }
}

async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await hre.run('compile');

    // We get the contract to deploy
    const CryptoPoker = await ethers.getContractFactory("CryptoPoker");
    const cryptoPoker = await CryptoPoker.attach(cryptoPokerAddress);

    for (const index in cardInfoList) {
        cardInfo = cardInfoList[index];
        console.log('add card modal: ', cardInfo);
        await cryptoPoker.addCardModal(cardInfo.name, cardInfo.cardType, cardInfo.displayValue,
            cardInfo.diamonTokenId, cardInfo.weaponTokenId, cardInfo.value, cardInfo.level,
            cardInfo.powerValue, cardInfo.attackPower, cardInfo.votality, cardInfo.rarity);
    }

    for (let i = 0; i < 54; i++) {
        console.log((await cryptoPoker.cardTemplate(i)).toString());
    }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
