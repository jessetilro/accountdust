application accountdust
imports icedust

page root {
  h1 { output("Kolommenbalans") }
  
  for( ledger: Ledger ){
    table {
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
            output(account.getNet_debit())
          </td>
          <td>
            output(account.getNet_credit())
          </td>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
        </tr>
      }  
    }
  }
  
  h1 { output("Journaal") }
  
  table {
    for (mutation: Mutation) {
      <tr>
        <td>
          output(mutation.getAccount().name)
        </td>
        <td>
          output(mutation.getDebit())
        </td>
        <td>
          output(mutation.getCredit())
        </td>
      </tr>
    }    
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