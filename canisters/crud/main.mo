import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Nat8 "mo:base/Nat8";

actor ProdCrud {
	//Material class definition
	type Material = {
		name: Text;
		partnum: Text;
		qty: Nat8;
	};
	//Product class definition
	type Prod = {
		user: Principal;
		name: Text;
		materials: [Material];
	};
	//Product list storage
	let prodList = HashMap.HashMap<Text, Prod>(0, Text.equal, Text.hash);
	
	//Creates a product and store it in a HashMap with the Part Number as a key. The product is confonformed by it's name and an array of materials 
	public shared (msg) func createProd(name: Text, materials: [Material], partNumber: Text) : async () {
		let user: Principal = msg.caller;
		let prod : Prod = {user=user; name=name; materials=materials;};

		prodList.put(partNumber, prod);
		Debug.print("New product created! Part number: " # partNumber);
		return ();
	};
	//Creates an array of products
	public query func getProds () : async [(Text, Prod)] {
		let prodIter : Iter.Iter<(Text, Prod)> = prodList.entries();
		let prodArray : [(Text, Prod)] = Iter.toArray(prodIter);
		return prodArray;
	};
	//Creates an array of product part numbers
    public query func getPartNumbers () : async [Text] {
		let prodIter : Iter.Iter<Text> = prodList.keys();
		let prodArray : [Text] = Iter.toArray(prodIter);
		return prodArray;
	};
	//Creates an array of products
	public query func getProd (pn: Text) : async ?Prod {
		let prod: ?Prod = prodList.get(pn);
		return prod;
	};
	//Upgrades a product
	public shared (msg) func updateProd (pn: Text, name: Text, materials: [Material]) : async Bool {
		let user: Principal = msg.caller;
		let prod: ?Prod = prodList.get(pn);

		switch (prod) {
			case (null) {
				return false;
			};
			case (?currentProd) {
				let newProd: Prod = {user=user; name=name; materials=materials;};
				prodList.put(pn, newProd);
				Debug.print("Updated product with ID: " # pn);
				return true;
			};
		};

	};
	//Delets a product
	public func deleteProd (pn: Text) : async Bool {
		let prod : ?Prod = prodList.get(pn);
		switch (prod) {
			case (null) {
				return false;
			};
			case (_) {
				ignore prodList.remove(pn);
				Debug.print("Delete product with ID: " # pn);
				return true;
			};
		};
	};
}