// SPDX-License-Identifier: HF
pragma solidity ^0.5.2;

//VCG Double Auction
contract DoubleAuction 
{
    
   uint constant private maxSize = 1000;
   uint constant private Kpercentage = 50; //This is K, = 0.5 normally but uints are more convenient
   uint constant private AuctionInterval = 300; //time in seconds
    struct bids
    { 
      uint quantity;
      uint price;
      address payable accountAddress;
    }
    
    bids[maxSize] public buyers; //all the current buy bids
    bids[maxSize] public sellers; //all the current sell bids
    
    bids private temp;
    
    uint public currentBuyersBids = 0;
    uint private currentSellersBids = 0;
    
    address[maxSize] selAddresses; //the final arrays of (sell address, buy address, prices, quantities)
    address[maxSize] buyAddresses;
    uint[maxSize] SellerPrices; //The values the Sellers have to pay
    uint[maxSize] quantities;
    uint[maxSize] BuyerPrices; //The values the Buyers have to pay 
    
    address[maxSize] public addedAddresses; //these are the addresses to track to see whether or not a bid is new or not
    
    uint C = 0; //clearing price
    bool breakevenFound = false;
    uint breakeven = 0;
    
    uint lastTime = block.timestamp;
    


  function quickSortBuyers(int left, int right) private //just a simple descending quicksort
  {
        int i = left;
        int j = right;
        
        if(i==j) return;
        
        uint pivot = uint(left);
        
        while (i <= j) 
        {
            while (buyers[uint(i)].price > buyers[pivot].price) i++;
            while (buyers[pivot].price > buyers[uint(j)].price) j--;
            if (i <= j) 
            {
                //swap
                temp.quantity = buyers[uint(i)].quantity;
                temp.accountAddress = buyers[uint(i)].accountAddress;
                temp.price = buyers[uint(i)].price;
                
                buyers[uint(i)].quantity = buyers[uint(j)].quantity;
                buyers[uint(i)].accountAddress = buyers[uint(j)].accountAddress;
                buyers[uint(i)].price = buyers[uint(j)].price;
                
                buyers[uint(j)].quantity = temp.quantity;
                buyers[uint(j)].accountAddress = temp.accountAddress;
                buyers[uint(j)].price = temp.price;
                
                i++;
                j--;
            }
        }
        if (left < j)
            quickSortBuyers(left, j);
        if (i < right)
            quickSortBuyers(i, right);
        
    }
    
  function quickSortSellers(int left, int right) private //just a simple ascending quicksort
  {
        int i = left;
        int j = right;
        
        if(i==j) return;
        
        uint pivot = uint(left);
        
        while (i <= j) 
        {
            while (sellers[uint(i)].price < sellers[pivot].price) i++;
            while (sellers[pivot].price < sellers[uint(j)].price) j--;
            if (i <= j) 
            {
                //swap
                temp.quantity = sellers[uint(i)].quantity;
                temp.accountAddress = sellers[uint(i)].accountAddress;
                temp.price = sellers[uint(i)].price;
                
                sellers[uint(i)].quantity = sellers[uint(j)].quantity;
                sellers[uint(i)].accountAddress = sellers[uint(j)].accountAddress;
                sellers[uint(i)].price = sellers[uint(j)].price;
                
                sellers[uint(j)].quantity = temp.quantity;
                sellers[uint(j)].accountAddress = temp.accountAddress;
                sellers[uint(j)].price = temp.price;
                
                i++;
                j--;
            }
        }
        if (left < j)
            quickSortSellers(left, j);
        if (i < right)
            quickSortSellers(i, right);
    }

    //add a new buyer bid if it doesn't already exist
    function addBuyer(uint quantity, uint price) public payable
    {
       if((currentSellersBids + currentBuyersBids + 1)>=maxSize) 
       {
           return;
       }
       for(uint i = 0; i < (currentSellersBids + currentBuyersBids); i++)
       {
           if(msg.sender == addedAddresses[i])
                return;
       }

        buyers[currentBuyersBids].quantity = quantity;
        buyers[currentBuyersBids].price = price;
        buyers[currentBuyersBids].accountAddress = payable(msg.sender);
        addedAddresses[currentBuyersBids+currentSellersBids] = msg.sender;
        currentBuyersBids++;
    } 
   

    //add a new seller bid if it doesn't already exist 
   function addSeller(uint quantity, uint price) public payable
   {
       
       if((currentSellersBids + currentBuyersBids + 1)>=maxSize) {
           return;
       }

       for(uint i = 0; i < currentSellersBids + currentBuyersBids; i ++)
       {
           if(msg.sender == addedAddresses[i])
                return;
       }

       
        sellers[currentSellersBids].quantity = quantity;
        sellers[currentSellersBids].price = price;
        sellers[currentSellersBids].accountAddress = payable(msg.sender);
        addedAddresses[currentBuyersBids+currentSellersBids] = msg.sender;
        currentSellersBids++;
    } 
    
    function getTime() view public returns (bool canRunContractNow, uint timeElasped) 
    {
        bool canRun = (block.timestamp - lastTime) > AuctionInterval;
        return (canRun, (block.timestamp - lastTime));
    }
    
    function max(uint A, uint B) pure private returns(uint retInt)
    {
    	if(A > B)
    	{
    	    return A;
    	}
    	return B;
    } 
    
    function min(uint A, uint B) pure private returns(uint retInt)
    {
    	if(A < B)
    	{
    	    return A;
    	}
    	return B;
    }
   
    function doubleAuction() public 
    {

        if((block.timestamp - lastTime) < AuctionInterval)
		return;
        lastTime = block.timestamp;

        // sort buyers and sellers
        quickSortBuyers(0,int(currentBuyersBids)-1);
        quickSortSellers(0,int(currentSellersBids)-1);
        
        
        C = 0; //clearing price
        
        breakeven = 0;
        breakevenFound = false;
        
        uint length = currentSellersBids < currentBuyersBids ? currentSellersBids : currentBuyersBids;
        
        for(uint i = 0; i < length; i++) 
        {
            //The only difference is over here, we find k*Bk >= (1-k)*Sk. 
            //This is the same as in K-DA
            if((buyers[i].price * Kpercentage )>= (sellers[i].price * (100 - Kpercentage))) 
            {
                breakeven = i;
                breakevenFound = true;
            }
            else
                break;
        }
        
        if(breakevenFound == false)
        {
            currentSellersBids = 0;
            currentBuyersBids = 0; 
            return;
        }
	
	C = (buyers[breakeven].price+sellers[breakeven].price)/2;
 
        for(uint i = 0; i <= breakeven; i++) 
        {
            selAddresses[i] = sellers[i].accountAddress;
            buyAddresses[i] = buyers[i].accountAddress;
            
            	BuyerPrices[i] = C;
            	SellerPrices[i] = C;
            
            if(sellers[i].quantity < buyers[i].quantity)
                quantities[i] = sellers[i].quantity;
            else
                quantities[i] = buyers[i].quantity;

        }
        
                
        currentSellersBids = 0;
        currentBuyersBids = 0;
    }



    function getHistory() public view returns(address[maxSize] memory sellerAddresses, address[maxSize] memory buyerAddresses, uint clearingPrice,uint[maxSize] memory q, uint NumberOfMatches, bool matchFound) 
    {
        return (selAddresses, buyAddresses, C, quantities,breakeven, breakevenFound);
    }    
    
    
}

