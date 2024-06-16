import Debug "mo:base/Debug";
import Wallet "wallet";

actor MyProject {

  public shared ({ caller }) func test() : async () {

    let address = Wallet.accountForUser(MyProject, caller);
    let balance = await Wallet.getBalance(address);

    let response = await Wallet.send(MyProject, caller, 1, balance);

    Debug.print(debug_show (response));
  };
};
