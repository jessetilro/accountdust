application accountdust
imports icedust

page root {
  for( b: Balance ){
  	for (asset: Account in b.assets) {
  		table {
	      derive viewRows from asset
	    }
  	}
    <hr>
    for (liability: Account in b.liabilities) {
  		table {
	      derive viewRows from liability
	    }
  	}
    <hr>
  }
  navigate derivedvalues() { "derivedvalues" }
}

entity User {
  name : String
  pass : Secret
}
principal is User with credentials name, pass
access control rules
rule page root{ true }