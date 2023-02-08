// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

// We need some util functions for strings.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import { Base64 } from "./libraries/Base64.sol";


contract NFTGenerator is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  // SVG base code
  string firstSvgSection = "<svg viewBox='0 0 900 600' width='900' height='600' xmlns='http://www.w3.org/2000/svg'><path fill='";
  string secondSvgSection = "' d='M0 0h900v600H0z'/><path d='M0 199h900v402H0Z' fill='";
  string thirdSvgSection = "'/><path d='M0 399h900v202H0Z' fill='";

  // color selection
  string[] firstWords = ["#000000","#330000","#660000","#990000","#CC0000","#FF0000","#003300","#333300","#663300","#993300","#CC3300","#FF3300","#006600","#336600","#666600","#996600","#CC6600","#FF6600","#009900","#339900","#669900","#999900","#CC9900","#FF9900","#00CC00","#33CC00","#66CC00","#99CC00","#CCCC00","#FFCC00","#00FF00","#33FF00","#66FF00","#99FF00","#CCFF00","#FFFF0"];
  string[] secondWords = ["#000000","#330000","#660000","#990000","#CC0000","#FF0000","#003300","#333300","#663300","#993300","#CC3300","#FF3300","#006600","#336600","#666600","#996600","#CC6600","#FF6600","#009900","#339900","#669900","#999900","#CC9900","#FF9900","#00CC00","#33CC00","#66CC00","#99CC00","#CCCC00","#FFCC00","#00FF00","#33FF00","#66FF00","#99FF00","#CCFF00","#FFFF0"];
  string[] thirdWords = ["#000000","#330000","#660000","#990000","#CC0000","#FF0000","#003300","#333300","#663300","#993300","#CC3300","#FF3300","#006600","#336600","#666600","#996600","#CC6600","#FF6600","#009900","#339900","#669900","#999900","#CC9900","#FF9900","#00CC00","#33CC00","#66CC00","#99CC00","#CCCC00","#FFCC00","#00FF00","#33FF00","#66FF00","#99FF00","#CCFF00","#FFFF0"];

  event NewEpicNFTMinted(address sender, uint256 tokenId);

  constructor() ERC721 ("flagNFT", "FLAG") {
    console.log("This is a NFT contract.");
  }

  function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
    rand = rand % firstWords.length;
    return firstWords[rand];
  }

  function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
    rand = rand % secondWords.length;
    return secondWords[rand];
  }

  function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
    rand = rand % thirdWords.length;
    return thirdWords[rand];
  }

  function random(string memory input) internal pure returns (uint256) {
      return uint256(keccak256(abi.encodePacked(input)));
  }

  function createNFT() public {
    uint256 newItemId = _tokenIds.current();

    string memory first = pickRandomFirstWord(newItemId);
    string memory second = pickRandomSecondWord(newItemId);
    string memory third = pickRandomThirdWord(newItemId);
    string memory combinedWord = string(abi.encodePacked(first, second, third));

    // concatenation of svg
    string memory finalSvg = string(abi.encodePacked(firstSvgSection, first, secondSvgSection, second, thirdSvgSection, third, "'/></svg>"));
    
    string memory json = Base64.encode(
    bytes(
        string(
            abi.encodePacked(
                '{'
                    '"name": "Flag', combinedWord, '", '
                    '"description": "A highly acclaimed collection of flags.", '
                    '"image": "data:image/svg+xml;base64,', Base64.encode(bytes(finalSvg)), '"'
                '}'
            )
        )
    )
);

    string memory finalTokenUri = string(
        abi.encodePacked("data:application/json;base64,", json)
    );

    _safeMint(msg.sender, newItemId);
  
    _setTokenURI(newItemId, finalTokenUri);
  
    _tokenIds.increment();
    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
    emit NewEpicNFTMinted(msg.sender, newItemId);
  }
}