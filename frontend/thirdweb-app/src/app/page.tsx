"use client";

import { baseSepolia, sepolia } from "thirdweb/chains";
import { client } from "./client";
import { getContract } from "thirdweb";
import { CROWFUNDING_FACTORY } from "./constants/contract";
import { useReadContract } from "thirdweb/react";
import CampaignCard from "./components/CampaignCard";


export default function Home() {

  const contract = getContract({
    client: client,
    chain: sepolia,
    address: CROWFUNDING_FACTORY
  });

  const {data : campaigns, isLoading} = useReadContract({
    contract,
    method:
    "function getAllCampaigns() view returns ((address campaignAddress, address owner, string name, uint256 creationTime)[])",
  params: [],
  })


  


  return (
    <main className="mx-auto max-w-7xl px-4 mt-4 sm:px-6 lg:px-8">
      <div className="py-20 ">
      <h1 className="text-4xl font-bold mb-4">Campaigns:</h1>
        <div className="grid grid-cols-3 gap-4">
          {!isLoading && campaigns && (
            campaigns.length>0?(
              campaigns.map((campaign)=>(
                <CampaignCard key={campaign.campaignAddress}
                  campaignAddress={campaign.campaignAddress}
                />
              ))
            ):(
              <p>No campaigns found</p>
            )
            
          )}
        </div>
      </div>
    </main>
  );
}

