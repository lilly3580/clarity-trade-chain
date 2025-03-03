import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can create new trade agreement",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('trade-chain', 'create-agreement', [
        types.principal(wallet1.address),
        types.uint(1000),
        types.ascii("Test trade agreement")
      ], deployer.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectUint(1);
  }
});

Clarinet.test({
  name: "Can accept and complete agreement",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;
    
    // Create agreement
    let block = chain.mineBlock([
      Tx.contractCall('trade-chain', 'create-agreement', [
        types.principal(wallet1.address),
        types.uint(1000),
        types.ascii("Test trade agreement")
      ], deployer.address)
    ]);
    
    // Accept agreement
    block = chain.mineBlock([
      Tx.contractCall('trade-chain', 'accept-agreement', [
        types.uint(1)
      ], wallet1.address)
    ]);
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectBool(true);
    
    // Complete agreement
    block = chain.mineBlock([
      Tx.contractCall('trade-chain', 'complete-agreement', [
        types.uint(1)
      ], deployer.address)
    ]);
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectBool(true);
  }
});

Clarinet.test({
  name: "Cannot complete non-existent agreement",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('trade-chain', 'complete-agreement', [
        types.uint(999)
      ], deployer.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectErr().expectUint(101);
  }
});
