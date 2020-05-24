application accountdust
imports icedust
imports layout

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

template mutationsTable(mutations: List<Mutation>) {
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
          action("Delete", action {
            var entry := mutation.getEntry();
            mutation.delete();
            return editEntry(entry);
          })
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
          
          navigate createEntry(journal) { "Feit toevoegen" }  
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
      label("Omschrijving") { output(entry.description) }
      
      mutationsTable(entry.getMutations())
      
      
      navigate entries()[class="btn btn-secondary btn-lg"] {
        "Terug"
      }
      navigate createMutation(entry)[class="btn btn-success btn-lg"] {
        <i class="fa fas fa-plus"></i>
        "Boeking toevoegen"
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