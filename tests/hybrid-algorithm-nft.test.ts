import { describe, it, expect, beforeEach } from 'vitest';

// Simulated contract state
let lastTokenId = 0;
const tokenMetadata = new Map();
const tokenOwners = new Map();

// Simulated contract functions
function mint(name: string, description: string, quantumComponent: string, classicalComponent: string, sender: string) {
  const tokenId = ++lastTokenId;
  tokenMetadata.set(tokenId, {
    name,
    description,
    creator: sender,
    quantumComponent,
    classicalComponent
  });
  tokenOwners.set(tokenId, sender);
  return tokenId;
}

function transfer(tokenId: number, recipient: string, sender: string) {
  if (tokenOwners.get(tokenId) !== sender) throw new Error('Not authorized');
  tokenOwners.set(tokenId, recipient);
  return true;
}

describe('Hybrid Algorithm NFT Contract', () => {
  beforeEach(() => {
    lastTokenId = 0;
    tokenMetadata.clear();
    tokenOwners.clear();
  });
  
  it('should mint a new hybrid algorithm NFT', () => {
    const tokenId = mint('Quantum Fourier Transform', 'A hybrid QFT implementation', 'QFT circuit', 'Classical post-processing', 'creator1');
    expect(tokenId).toBe(1);
    expect(tokenOwners.get(tokenId)).toBe('creator1');
    const metadata = tokenMetadata.get(tokenId);
    expect(metadata.name).toBe('Quantum Fourier Transform');
    expect(metadata.quantumComponent).toBe('QFT circuit');
    expect(metadata.classicalComponent).toBe('Classical post-processing');
  });
  
  it('should transfer an NFT', () => {
    const tokenId = mint('Quantum Error Correction', 'Hybrid error correction algorithm', 'Quantum stabilizer codes', 'Classical decoding', 'creator2');
    expect(transfer(tokenId, 'recipient1', 'creator2')).toBe(true);
    expect(tokenOwners.get(tokenId)).toBe('recipient1');
  });
  
  it('should not allow unauthorized transfer', () => {
    const tokenId = mint('Quantum Machine Learning', 'Hybrid quantum-classical ML', 'Quantum feature maps', 'Classical optimization', 'creator3');
    expect(() => transfer(tokenId, 'recipient2', 'unauthorized_user')).toThrow('Not authorized');
  });
});

