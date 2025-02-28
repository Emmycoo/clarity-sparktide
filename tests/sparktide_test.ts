import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensures users can create and update boards",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("sparktide-board", "create-board", 
        [types.utf8("My Board"), types.utf8("Test Description")],
        wallet_1.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    block.receipts[0].result.expectOk().expectUint(1);

    // Test board update
    block = chain.mineBlock([
      Tx.contractCall("sparktide-board", "update-board",
        [types.uint(1), types.utf8("Updated Board"), types.utf8("Updated Description")],
        wallet_1.address
      )
    ]);

    block.receipts[0].result.expectOk();
  },
});

Clarinet.test({
  name: "Ensures collaborator management works",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    const wallet_2 = accounts.get("wallet_2")!;
    
    // Create board
    let block = chain.mineBlock([
      Tx.contractCall("sparktide-board", "create-board",
        [types.utf8("Collab Board"), types.utf8("Test")],
        wallet_1.address
      )
    ]);
    
    // Add collaborator
    block = chain.mineBlock([
      Tx.contractCall("sparktide-board", "add-collaborator",
        [types.uint(1), types.principal(wallet_2.address)],
        wallet_1.address
      )
    ]);
    
    block.receipts[0].result.expectOk();
    
    // Remove collaborator
    block = chain.mineBlock([
      Tx.contractCall("sparktide-board", "remove-collaborator",
        [types.uint(1), types.principal(wallet_2.address)],
        wallet_1.address
      )
    ]);
    
    block.receipts[0].result.expectOk();
  },
});
