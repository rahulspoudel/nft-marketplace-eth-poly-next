import { ethers } from "ethers";
import { useEffect, useState } from "react";
import axios from "axios";
import Web3Modal from "web3modal";

import { nftaddress, nftmarketaddress } from "../config";

import NFT from "../artifacts/contracts/NFT.sol/NFT.json";
import Market from "../artifacts/contracts/NFTMarket.sol/NFTMarket.json";

export default function MyAssets() {
  const [nfts, setNFTs] = useState([]);
  const [sold, setSold] = useState([]);
  const [loadingState, setLoadingState] = useState("not-loaded");

  useEffect(() => {
    loadNFTs();
  }, []);

  async function loadNFTs() {
    // Open the wallet popup of Metamask
    // Can use try catch to handle properly - not implemented here
    const web3Modal = new Web3Modal();
    const connection = await web3Modal.connect();
    const provider = new ethers.providers.Web3Provider(connection);
    const signer = provider.getSigner();

    const tokenContract = new ethers.Contract(nftaddress, NFT.abi, provider);
    const marketContract = new ethers.Contract(
      nftmarketaddress,
      Market.abi,
      signer
    );

    const data = await marketContract.fetchItemsListed();
    console.log(data);
    // Get all the items
    const items = await Promise.all(
      data.map(async (i) => {
        const tokenUri = await tokenContract.tokenURI(i.tokenId); // returns IPFS url containing metadata
        // Now getting one metadata from the tokenUri as
        // we have to use it for working with IPFS
        // to be able to upload the JSON representation of NFTs
        const meta = await axios.get(tokenUri);
        let price = ethers.utils.formatUnits(i.price.toString(), "ether");
        let item = {
          price,
          tokenId: i.tokenId.toNumber(),
          seller: i.seller,
          owner: i.owner,
          sold: i.sold,
          image: meta.data.image,
        };
        return item;
      })
    );

    const soldItems = items.filter((i) => i.sold);
    setSold(soldItems);
    setNFTs(items);
    setLoadingState("loaded");
  }
  return (
    <div className="flex flex-col justify-center">
      <div className="p-4">
        <h2 className="text-2xl py-2">Items Created</h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 pt-4">
          {nfts.map((nft, index) => (
            <div
              key={index}
              className="border shadow rounded-xl overflow-hidden"
            >
              <img src={nft.image} className="rounded" />
              <div className="text-2xl font-bold text-black">
                Price - {nft.price} ether
              </div>
            </div>
          ))}
        </div>
      </div>
      <div>
        {Boolean(sold.length) && (
          <div className="p-4">
            <h2 className="text-2xl py-2">Items Sold</h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 pt-4">
              {sold.map((nft, index) => (
                <div
                  key={index}
                  className="border shadow rounded-xl overflow-hidden"
                >
                  <img src={nft.image} className="rounded" />
                  <div className="text-2xl font-bold text-black">
                    Price - {nft.price} ether
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
