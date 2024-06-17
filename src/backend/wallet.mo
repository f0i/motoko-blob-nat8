import Buffer "mo:base/Buffer";
import Principal "mo:base/Principal";
import Nat8 "mo:base/Nat8";
import Blob "mo:base/Blob";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Ledger "canister:ckusdc_ledger";

module {

  type Subaccount = [Nat8];
  public type Account = { owner : Principal; subaccount : Null };
  public type TokenInfo = { name : Text; decimals : Nat8; fee : Nat };
  public type AccountBlob = { owner : Principal; subaccount : ?Blob };

  public func accountForUser(self : actor {}, user : Principal) : Account {
    let account = {
      owner = Principal.fromActor(self);
      subaccount = null; //?principalToSubaccount(user);
    };
    return account;
  };

  public func accountForAuction(self : actor {}, id : Nat) : Account {
    let account : Account = {
      owner = Principal.fromActor(self);
      subaccount = null //?auctionToSubaccount(id);
    };
    return account;
  };

  /// Turn Principal into a 32 byte blob
  private func principalToSubaccount(principal : Principal) : Subaccount {
    assert (not Principal.isAnonymous(principal));

    var sub = Buffer.Buffer<Nat8>(32);
    let subaccount_blob = Principal.toBlob(principal);
    sub.add(Nat8.fromNat(subaccount_blob.size()));
    sub.append(Buffer.fromArray<Nat8>(Blob.toArray(subaccount_blob)));

    assert (sub.size() > 25); // ensure enough bytes to prevent collisions

    return to32ByteBlob(sub);
  };

  private func natBytes(value : Nat) : Buffer.Buffer<Nat8> {
    var buf = Buffer.Buffer<Nat8>(4);
    var val = value;
    if (value == 0) buf.add(0);
    while (val != 0) {
      buf.add(Nat8.fromIntWrap(val));
      val := Nat.bitshiftRight(val, 8);
      // Max 128 bit value.
      // For this app, values should mostly be below 32 bit which is 4 byte.
      // and we don't expect values that wouldn't fit in 64 bit or 8 byte.
      // If values need more bytes than this, it is likeley a bug.
      assert (buf.size() <= 16);
    };
    return buf;
  };

  private func auctionToSubaccount(id : Nat) : Subaccount {
    var sub = Buffer.Buffer<Nat8>(32);
    let subaccount_blob = natBytes(id);
    // Marker for auctions
    sub.add(100);
    sub.add(Nat8.fromNat(subaccount_blob.size()));
    sub.append(subaccount_blob);
    return to32ByteBlob(sub);
  };

  private func to32ByteBlob(buffer : Buffer.Buffer<Nat8>) : Subaccount {
    while (buffer.size() < 32) {
      buffer.add(0);
    };
    assert (buffer.size() == 32);
    return Buffer.toArray(buffer);
    //return Buffer.toArray(buffer);
  };

  public func getBalance(account : Account) : async Nat {
    //await Ledger.icrc1_balance_of(toAccountBlob(account));
    await Ledger.icrc1_balance_of(account);
  };

  public func getTokenInfo() : TokenInfo {
    return { name = "notUSDC"; decimals = 8; fee = 10000 };
  };

  public func send(self : actor {}, user : Principal, id : Nat, amount : Nat) : async {
    #ok;
    #err : Text;
  } {
    let sender = accountForUser(self, user);
    let auction = accountForAuction(self, id);
    let fee = 10000; // one cent

    type TransferArgs = {
      from_subaccount : Null;
      to : Account;
      amount : Nat;
      fee : ?Nat;
      memo : Null;
      created_at_time : Null;
    };
    let args = {
      from_subaccount = null; //sender.subaccount;
      //from_subaccount = ?Blob.fromArray(sender.subaccount);
      to = auction;
      // Cover the fee. Otherwise the transaction would fail if the user only send the exact funds.
      amount = amount - fee : Nat;
      fee = ?fee;
      memo = null;
      created_at_time = null;
    };

    let response = await Ledger.icrc1_transfer(args);

    switch (response) {
      case (#Ok(_transactionId)) {
        return #ok;
      };
      case (#Err(error)) {
        return #err(debug_show (error));
      };
    };
  };

};
