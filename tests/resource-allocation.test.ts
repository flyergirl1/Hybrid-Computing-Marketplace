import { describe, it, expect, beforeEach } from 'vitest';

// Simulated contract state
const resourceProviders = new Map();
const allocatedResources = new Map();

// Simulated contract functions
function registerProvider(quantumCapacity: number, classicalCapacity: number, sender: string) {
  resourceProviders.set(sender, {
    quantumCapacity,
    classicalCapacity,
    reputation: 0,
    totalTasksCompleted: 0
  });
  return true;
}

function allocateResources(taskId: number, quantumNeeded: number, classicalNeeded: number, sender: string) {
  const provider = resourceProviders.get(sender);
  if (!provider) throw new Error('Provider not found');
  if (provider.quantumCapacity < quantumNeeded) throw new Error('Insufficient quantum capacity');
  if (provider.classicalCapacity < classicalNeeded) throw new Error('Insufficient classical capacity');
  
  allocatedResources.set(taskId, {
    provider: sender,
    quantumAllocated: quantumNeeded,
    classicalAllocated: classicalNeeded
  });
  return true;
}

function completeTask(taskId: number) {
  const allocation = allocatedResources.get(taskId);
  if (!allocation) throw new Error('Allocation not found');
  const provider = resourceProviders.get(allocation.provider);
  if (!provider) throw new Error('Provider not found');
  
  provider.reputation += 1;
  provider.totalTasksCompleted += 1;
  resourceProviders.set(allocation.provider, provider);
  return true;
}

describe('Resource Allocation Contract', () => {
  beforeEach(() => {
    resourceProviders.clear();
    allocatedResources.clear();
  });
  
  it('should register a new provider', () => {
    expect(registerProvider(10, 20, 'provider1')).toBe(true);
    const provider = resourceProviders.get('provider1');
    expect(provider.quantumCapacity).toBe(10);
    expect(provider.classicalCapacity).toBe(20);
  });
  
  it('should allocate resources', () => {
    registerProvider(15, 25, 'provider2');
    expect(allocateResources(1, 5, 10, 'provider2')).toBe(true);
    const allocation = allocatedResources.get(1);
    expect(allocation.provider).toBe('provider2');
    expect(allocation.quantumAllocated).toBe(5);
    expect(allocation.classicalAllocated).toBe(10);
  });
  
  it('should not allocate resources if capacity is insufficient', () => {
    registerProvider(5, 5, 'provider3');
    expect(() => allocateResources(2, 10, 5, 'provider3')).toThrow('Insufficient quantum capacity');
    expect(() => allocateResources(2, 5, 10, 'provider3')).toThrow('Insufficient classical capacity');
  });
  
  it('should complete a task and update provider reputation', () => {
    registerProvider(20, 30, 'provider4');
    allocateResources(3, 10, 15, 'provider4');
    expect(completeTask(3)).toBe(true);
    const provider = resourceProviders.get('provider4');
    expect(provider.reputation).toBe(1);
    expect(provider.totalTasksCompleted).toBe(1);
  });
});

