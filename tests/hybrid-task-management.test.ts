import { describe, it, expect, beforeEach } from 'vitest';

// Simulated contract state
let taskCount = 0;
const tasks = new Map();

// Simulated contract functions
function createTask(description: string, quantumResources: number, classicalResources: number, sender: string) {
  const taskId = ++taskCount;
  tasks.set(taskId, {
    owner: sender,
    description,
    quantumResources,
    classicalResources,
    status: 'pending',
    result: null
  });
  return taskId;
}

function updateTaskStatus(taskId: number, newStatus: string, sender: string) {
  const task = tasks.get(taskId);
  if (!task) throw new Error('Task not found');
  if (task.owner !== sender) throw new Error('Not authorized');
  task.status = newStatus;
  tasks.set(taskId, task);
  return true;
}

function setTaskResult(taskId: number, result: string, sender: string) {
  const task = tasks.get(taskId);
  if (!task) throw new Error('Task not found');
  if (task.owner !== sender) throw new Error('Not authorized');
  task.result = result;
  task.status = 'completed';
  tasks.set(taskId, task);
  return true;
}

describe('Hybrid Task Management Contract', () => {
  beforeEach(() => {
    taskCount = 0;
    tasks.clear();
  });
  
  it('should create a new task', () => {
    const taskId = createTask('Test task', 5, 10, 'user1');
    expect(taskId).toBe(1);
    expect(tasks.size).toBe(1);
    const task = tasks.get(taskId);
    expect(task.description).toBe('Test task');
    expect(task.status).toBe('pending');
  });
  
  it('should update task status', () => {
    const taskId = createTask('Another task', 3, 7, 'user2');
    expect(updateTaskStatus(taskId, 'in-progress', 'user2')).toBe(true);
    const task = tasks.get(taskId);
    expect(task.status).toBe('in-progress');
  });
  
  it('should not allow unauthorized status update', () => {
    const taskId = createTask('Secure task', 2, 4, 'user3');
    expect(() => updateTaskStatus(taskId, 'completed', 'user4')).toThrow('Not authorized');
  });
  
  it('should set task result', () => {
    const taskId = createTask('Result task', 1, 2, 'user5');
    expect(setTaskResult(taskId, 'Task completed successfully', 'user5')).toBe(true);
    const task = tasks.get(taskId);
    expect(task.result).toBe('Task completed successfully');
    expect(task.status).toBe('completed');
  });
  
  it('should not allow unauthorized result setting', () => {
    const taskId = createTask('Protected task', 6, 8, 'user6');
    expect(() => setTaskResult(taskId, 'Unauthorized result', 'user7')).toThrow('Not authorized');
  });
});

