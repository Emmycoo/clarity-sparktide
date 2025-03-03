import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

// Original tests remain...

Clarinet.test({
  name: "Ensures like/unlike functionality works correctly",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    // Like board
    let block = chain.mineBlock([
      Tx.contractCall("sparktide-core", "like-board", 
        [types.uint(1)],
        wallet_1.address
      )
    ]);
    
    block.receipts[0].result.expectOk().expectBool(true);
    
    // Try to like again - should fail
    block = chain.mineBlock([
      Tx.contractCall("sparktide-core", "like-board", 
        [types.uint(1)],
        wallet_1.address
      )
    ]);
    
    block.receipts[0].result.expectErr().expectUint(201);
    
    // Unlike board
    block = chain.mineBlock([
      Tx.contractCall("sparktide-core", "unlike-board", 
        [types.uint(1)],
        wallet_1.address
      )
    ]);
    
    block.receipts[0].result.expectOk().expectBool(true);
  },
});
