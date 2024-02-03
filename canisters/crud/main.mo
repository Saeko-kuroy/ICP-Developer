import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Nat8 "mo:base/Nat8";

actor ProdCrud {

	type ProdId = Nat32;
	type Materials = {
		materialName: Text;
		materialQty: Nat8;
	};
	type Prod = {
		user: Principal;
		name: Text;
		materials: [Materials];
	};

	stable var prodId: ProdId = 0;
	let prodList = HashMap.HashMap<Text, Prod>(0, Text.equal, Text.hash);

	private func generateTaskId() : Nat32 {
		prodId += 1;
		return prodId;
	};

	public shared (msg) func createProd(name: Text, materials: [Materials]) : async () {
		let user: Principal = msg.caller;
		let prod : Prod = {user=user; name=name; materials=materials;};

		prodList.put(Nat32.toText(generateTaskId()), prod);
		Debug.print("New product created! ID: " # Nat32.toText(prodId));
		return ();
	};

	public query func getProds () : async [(Text, Prod)] {
		let prodIter : Iter.Iter<(Text, Prod)> = prodList.entries();
		let prodArray : [(Text, Prod)] = Iter.toArray(prodIter);

		return prodArray;
	};

	public query func getProd (id: Text) : async ?Prod {
		let prod: ?Prod = prodList.get(id);
		return prod;
	};

	public shared (msg) func updateProd (id: Text, name: Text, materials: [Materials]) : async Bool {
		let user: Principal = msg.caller;
		let prod: ?Prod = prodList.get(id);

		switch (prod) {
			case (null) {
				return false;
			};
			case (?currentProd) {
				let newProd: Prod = {user=user; name=name; materials=materials;};
				prodList.put(id, newProd);
				Debug.print("Updated product with ID: " # id);
				return true;
			};
		};

	};

	public func deleteProd (id: Text) : async Bool {
		let prod : ?Prod = prodList.get(id);
		switch (prod) {
			case (null) {
				return false;
			};
			case (_) {
				ignore prodList.remove(id);
				Debug.print("Delete product with ID: " # id);
				return true;
			};
		};
	};
}