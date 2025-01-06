import { describe, it, expect, beforeEach } from 'vitest';

// Simulated contract state
let listingCount = 0;
const listings = new Map();
const computeTimeTokenBalances = new Map();

// Simulated contract functions
function createListing(quantumTime: number, classicalTime: number, price: number, seller: string) {
  const listingId = ++listingCount;
  listings.set(listingId, {
    seller,
    quantumTime,
    classicalTime,
    price,
    active: true
  });
  return listingId;
}

function buyComputeTime(listingId: number, buyer: string) {
  const listing = listings.get(listingId);
  if (!listing) throw new Error('Listing not found');
  if (!listing.active) throw new Error('Listing is not active');

  const buyerBalance = computeTimeTokenBalances.get(buyer) || 0;
  if (buyerBalance < listing.price) throw new Error('Insufficient balance');

  computeTimeTokenBalances.set(buyer, buyerBalance - listing.price);
  const sellerBalance = computeTimeTokenBalances.get(listing.seller) || 0;
  computeTimeTokenBalances.set(listing.seller, sellerBalance + listing.price);

  listing.active = false;
  listings.set(listingId, listing);
  return true;
}

function cancelListing(listingId: number, seller: string) {
  const listing = listings.get(listingId);
  if (!listing) throw new Error('Listing not found');
  if (listing.seller !== seller) throw new Error('Not authorized');

  listing.active = false;
  listings.set(listingId, listing);
  return true;
}

describe('Compute Time Marketplace Contract', () => {
  beforeEach(() => {
    listingCount = 0;
    listings.clear();
    computeTimeTokenBalances.clear();
  });

  it('should create a new listing', () => {
    const listingId = createListing(100, 200, 50, 'seller1');
    expect(listingId).toBe(1);
    const listing = listings.get(listingId);
    expect(listing.quantumTime).toBe(100);
    expect(listing.classicalTime).toBe(200);
    expect(listing.price).toBe(50);
    expect(listing.active).toBe(true);
  });

  it('should buy compute time', () => {
    const listingId = createListing(150, 300, 75, 'seller2');
    computeTimeTokenBalances.set('buyer1', 100);
    expect(buyComputeTime(listingId, 'buyer1')).toBe(true);
    expect(computeTimeTokenBalances.get('buyer1')).toBe(25);
    expect(computeTimeTokenBalances.get('seller2')).toBe(75);
    const listing = listings.get(listingId);
    expect(listing.active).toBe(false);
  });

  it('should not allow purchase with insufficient balance', () => {
    const listingId = createListing(200, 400, 100, 'seller3');
    computeTimeTokenBalances.set('buyer2', 50);
    expect(() => buyComputeTime(listingId, 'buyer2')).toThrow('Insufficient balance');
  });

  it('should cancel a listing', () => {
    const listingId = createListing(250, 500, 125, 'seller4');
    expect(cancelListing(listingId, 'seller4')).toBe(true);
    const listing = listings.get(listingId);
    expect(listing.active).toBe(false);
  });

  it('should not allow unauthorized cancellation', () => {
    const listingId = createListing(300, 600, 150, 'seller5');
    expect(() => cancelListing(listingId, 'unauthorized_user')).toThrow('Not authorized');
  });
});

