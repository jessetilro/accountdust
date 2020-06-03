application accountdust
imports icedust
imports layout

extend entity Entry { 
  validate(description.length() > 0, "Description cannot be empty") 
} 

template balance(ledger: Ledger) {
  <table class="table table-sm">
    <thead>
      <tr>
        <td colspan="2"></td>
        <td colspan="2">text("Proefbalans")</td>
        <td colspan="2">text("Saldibalans")</td>
        <td colspan="2">text("Resultatenrekening")</td>
        <td colspan="2">text("Balans")</td>
      </tr>
      <tr>
        <td>text("Nr.")</td>
        <td>text("Rekening")</td>
        <td>text("Debet")</td>
        <td>text("Credit")</td>
        <td>text("Debet")</td>
        <td>text("Credit")</td>
        <td>text("Debet")</td>
        <td>text("Credit")</td>
        <td>text("Debet")</td>
        <td>text("Credit")</td>
      </tr>
    </thead>
   
    <tbody>
      for (account : Account in ledger.getAccounts()) {
        <tr>
          <td>
            output(account.number)
          </td>
          <td>
            output(account.name)
          </td>
          <td>
            output(account.getDebit())
          </td>
          <td>
            output(account.getCredit())
          </td>
          <td>
            output(account.getNetDebit())
          </td>
          <td>
            output(account.getNetCredit())
          </td>
          <td>
            output(account.getAuxiliaryDebit())
          </td>
          <td>
            output(account.getAuxiliaryCredit())
          </td>
          <td>
           output(account.getFinalDebit())
          </td>
          <td>
           output(account.getFinalCredit())
          </td>
        </tr>
      }  
      
      <tfoot>
        <tr>
          <td>
          </td>
          <td>
           text("Nettoresultaat")
          </td>
          <td colspan="4">
          </td>
          <td>
           <strong>
             output(ledger.getNetIncome())
           </strong>
          </td>
          <td cospan="3">
          </td>
        </tr>
        <tr>
          <td colspan="2">
          </td>
          <td>
            output(ledger.getDebit())
          </td>
          <td>
            output(ledger.getCredit())
          </td>
          <td>
            output(ledger.getNetDebit())
          </td>
          <td>
            output(ledger.getNetCredit())
          </td>
          <td>
            output(ledger.getAuxiliaryCredit())
          </td>
          <td>
            output(ledger.getAuxiliaryCredit())
          </td>
          <td>
            output(ledger.getFinalDebit())
          </td>
          <td>
            output(ledger.getFinalCredit())
          </td>
        </tr>
      </tfoot>
    </tbody>
  </table>
}

template entriesTable(entries: List<Entry>) {
  table[class="table table-sm"] {
    for (entry: Entry in entries) {
      <tr>
        <td>
          navigate editEntry(entry) {
            output(entry.getDescription())  
          }
        </td>
        <td>
          output(entry.getDebit())
        </td>
        <td>
          output(entry.getCredit())
        </td>
        <td>
          output(entry.date)
        </td>
        <td>
          output(entry.getBalanced())
        </td>
      </tr>
    }
  }
}

template mutationsTable(mutations: List<Mutation>, ph: Placeholder) {
  table[class="table table-sm"] {
    for (mutation: Mutation in mutations) {
      
      <tr>
        <td>
          output(mutation.getAccount().getName())
        </td>
        <td>
          output(mutation.getDebit())
        </td>
        <td>
          output(mutation.getCredit())
        </td>
        <td>
          submitlink action {
            var entry := mutation.getEntry();
            entry.mutations.remove(mutation);
            mutation.delete();
            replace(ph);
          }{ "Delete" }
        </td>
      </tr>
    }
  }
}

page root {
  layout()
  
  pageContainer() {
    content {
      pane("Kolommenbalans", "Proefbalans, saldibalans, resultatenrekening en eindbalans van alle grootboekrekeningen") {
        for( ledger: Ledger ) {
          balance(ledger)
        }
      }
    }
  }
}

page entries {
  layout()
  
  pageContainer() {
    content {
      pane("Journaal", "Alle financiele feiten / boekstukken") {
        for (journal: Journal) {
          entriesTable(journal.getEntries())
          
          submitlink action {
				    var entry := Entry{
				      journal := journal
				      date := today()
				      description := "New entry"
				    }.save();
				    return editEntry(entry);
				  }[class="btn btn-sm btn-success"]{
				    <i class="fa fas fa-plus"></i>
				    " Add entry"
			    }
        }
      }
    }
  }
}

page createEntry(journal: Journal) {
  layout()
  
  var entry := Entry {}
  
  clean {
    pane("Feit toevoegen") {
		  form { 
		    group("Entry") { 
		      label("Omschrijving") { input(entry.description) }
		      label("Datum") { input(entry.date) } 
		      action("Opslaan", action{
		        entry.journal := journal;
		        entry.save();
		        return editEntry(entry);
		      }) 
		    } 
		  }
	  }
  }
}

page editEntry(entry: Entry) {
  layout()
  
  clean {
    pane("Feit") {
      placeholder ph {
	      form {
		      label("Omschrijving") { input(entry.description) }
		      
		      //mutationsTable(entry.getMutations(), ph)
		      table[class="table table-sm mt-3"] {
				    for (mutation: Mutation in entry.mutations) {
				      <tr>
				        <td>
				          input(mutation.account)
				        </td>
				        <td>
				          input(mutation.debit)
				        </td>
				        <td>
				          input(mutation.credit)
				        </td>
				        <td>
				          submitlink action {
				            entry.mutations.remove(mutation);
				            mutation.account.mutations.remove(mutation);
				            mutation.delete();
				            replace(ph);
				          }[class="btn btn-sm btn-default"]{
				            <i class="fa fas fa-trash"></i>
				            " Delete"
			            }
				        </td>
				      </tr>
				    }
				  }
				  
				  div[class="mb-3"] {
				  	submitlink action {
				  		var account : Account := (from Account limit 1)[0];
	            entry.mutations.add(Mutation{
	              credit := 0.0
	              debit := 0.0
	              account := account
	            });
	            replace(ph);
	          }[class="btn btn-default btn-sm"]{
	            <i class="fa fas fa-plus"></i>
	            " Add mutation"  
	          }
				  }
		      
		      div[class="mt-3"] {
		      	navigate entries()[class="btn btn-light btn-lg mr-3"] {
	            <i class="fa fas fa-times"></i>
	            " Cancel"
	          }
	          submitlink action{
	            entry.save();
	            return entries();
	          }[class="btn btn-primary btn-lg"]{
	            <i class="fa fas fa-save"></i>
	            " Save"
	          }
		      }
	      }
      }
    }
  }
}

page createMutation(entry: Entry) {
  var mutation := Mutation {}
  
  layout()
  
  clean {
    pane("Boeking toevoegen") {
		  form { 
		    group("Mutation") {
		      label("Account") { input(mutation.account) } 
		      label("Debit") { input(mutation.debit) }
		      label("Credit") { input(mutation.credit) } 
		      
		      navigate editEntry(mutation.getEntry())[class="btn btn-secondary btn-lg"] {
		        "Terug"
		      }
		      
		      action("Opslaan", action{
		        mutation.entry := entry;
		        mutation.save();
		        return editEntry(entry);
		      }) 
		    } 
		  }
	  }
  }
}

entity User {
  name : String
  pass : Secret
}
principal is User with credentials name, pass
access control rules
rule page *(*){true}
rule logsql { true }