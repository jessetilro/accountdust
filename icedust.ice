module icedust // ctree collection=?+-2s constraints=0.025s analysis2=0.25s // jar collection=?<1s constraints=0.015 analysis2=0.05s

model

  entity Ledger {
    debit : Float = sum(accounts.debit) <+ 0.0
    credit : Float = sum(accounts.credit) <+ 0.0
    
    netDebit : Float = sum(accounts.netDebit) <+ 0.0
    netCredit : Float = sum(accounts.netCredit) <+ 0.0
    
    mainDebit : Float = sum(mains.mainDebit) <+ 0.0
    mainCredit : Float = sum(mains.mainCredit) <+ 0.0
    
    auxiliaryDebit : Float = sum(auxiliaries.auxiliaryDebit) <+ 0.0
    auxiliaryCredit : Float = sum(auxiliaries.auxiliaryCredit) <+ 0.0
    
    finalDebit : Float = sum(mains.finalDebit) <+ 0.0
    finalCredit : Float = sum(mains.finalCredit) <+ 0.0
    
    balanced : Boolean = sum(accounts.credit) == sum(accounts.debit)
    netIncome : Float = sum(revenues.balance) - sum(expenses.balance)
  }
  
  entity Category {
    name : String = "" (default)
    path : String = (parent.path <+ "") + " / " + name (incremental)
  }
  
  relation Category.parent ? <-> * Category.children
  relation Category.ledger 1 <-> * Ledger.categories
  relation Account.category ? <-> * Category.accounts

  entity Account {
    type : String = "asset/fixed" (default)
    auxiliary : Boolean = (type == "auxiliary/revenue" or type == "auxiliary/expense")
    main : Boolean = !auxiliary
    side : String =
      switch {
        case type == "asset/fixed" => "debit"
        case type == "asset/current" => "debit"
        case type == "auxiliary/expense" => "debit"
        case type == "liability/equity" => "credit"
        case type == "liability/debt" => "credit"
        case type == "auxiliary/revenue" => "credit"
        default => "credit"
      }
    name : String  = "Untitled" (default)
    number : Int = 0 (default)
    
    debit : Float = sum(mutations.debit) <+ 0.0
    credit : Float = sum(mutations.credit) <+ 0.0
    
    netDebit : Float = if (debit > credit) debit - credit else 0.0
    netCredit : Float = if (credit > debit) credit - debit else 0.0
    
    mainDebit : Float = if (main) netDebit else 0.0
    mainCredit : Float = if (main) netCredit else 0.0
    
    auxiliaryDebit : Float = if (auxiliary) netDebit else 0.0
    auxiliaryCredit : Float = if (auxiliary) netCredit else 0.0
    
    finalDebit : Float = mainDebit
    finalCredit : Float = mainCredit + (if (type == "liability/equity") ledger.netIncome else 0.0)
    
    balance : Float = if (side == "credit") credit - debit else debit - credit
  }
  
  relation Ledger.accounts * <-> 1 Account.ledger
  relation Ledger.mains * = accounts.filter(x => !x.auxiliary) <-> ? Account.ledger_as_main
  relation Ledger.auxiliaries * = accounts.filter(x => x.auxiliary) <-> ? Account.ledger_as_auxiliary
  relation Ledger.revenues * = accounts.filter(x => x.type == "auxiliary/revenue") <-> ? Account.ledger_as_revenue
  relation Ledger.expenses * = accounts.filter(x => x.type == "auxiliary/expense") <-> ? Account.ledger_as_expense
  
  entity Journal {
    balanced : Boolean = conj(entries.balanced)
  }
  
  relation Journal.ledger 1 <-> * Ledger.journals  
  
  entity Entry {
    description : String = "" (default)
    date : Datetime
    debit : Float = sum(mutations.debit)
    credit : Float = sum(mutations.credit)
    balanced : Boolean = debit == credit
  }
  
  relation Journal.entries * <-> 1 Entry.journal
  
  entity Mutation {
    date : Datetime? = entry.date
    debit : Float = 0.0 (default)
    credit : Float = 0.0 (default)
  }
  
  relation Mutation.account ? <-> * Account.mutations
  relation Mutation.entry ? <-> + Entry.mutations 
  relation Mutation.journal ? =
    entry.journal <-> * Journal.mutations
    
  // https://download.belastingdienst.nl/belastingdienst/docs/handboek-loonheffingen-jan-2020-lh0221t01fd.pdf
  entity Salary {
  	description : String = "Unnamed Salary" (default)
  	grossMonthSalary : Float = 0.0 (default)
  	applyZvwEmployerCharge : Boolean = true (default)
  	collectZvwContribution : Boolean = false (default)
  	
  	grossYearSalary : Float = 12.0 * grossMonthSalary
  	
  	incomeForTax : Float = grossYearSalary
  	incomeForZvw : Float = min(grossYearSalary ++ 57232.0)
  	
  	taxBracket : Float = 68507.0
  	incomeBracket1 : Float = min(incomeForTax ++ taxBracket)
    incomeBracket2 : Float = max(incomeForTax ++ taxBracket) - taxBracket
    // income tax includes payroll tax + national insurance premiums 
    incomeTax : Float = (37.35 / 100.0) * incomeBracket1 + (49.50 / 100.0) * incomeBracket2
    incomeTaxDiscount : Float = 0.0 // TODO
    
    zvwContribution : Float = if (collectZvwContribution) (5.45 / 100.0) * incomeForZvw else 0.0
    zvwEmployerCharge : Float = if (applyZvwEmployerCharge) (6.70 / 100.0) * incomeForZvw else 0.0
    
    collections : Float = incomeTax - incomeTaxDiscount + zvwContribution
    charges : Float = zvwEmployerCharge
    netYearSalary : Float = grossYearSalary - collections
  }
  
  entity PersonnelCosts {
  	grossSalaries : Float = sum(salaries.grossMonthSalary)
  	charges : Float = sum(salaries.charges)
  	collections : Float = sum(salaries.collections)
  	costs : Float = grossSalaries + charges
  	payments : Float = sum(salaries.netYearSalary)
  }
  
  relation Salary.personnelCosts ? <-> * PersonnelCosts.salaries

data

  ledger: Ledger {
    categories =
      assets: Category {
        name = "Activa"
        children =
          fixed: Category {
            ledger = ledger
            name = "Vaste activa"
          },
          current: Category {
            ledger = ledger
            name = "Vlottende activa"
            children =
              claims: Category {
                ledger = ledger
                name = "Vorderingen"
              },
              liquid: Category {
                ledger = ledger
                name = "Liquide middelen"
              }
          }
      },
      liabilities: Category {
        name = "Passiva"
        children =
          equity: Category {
            ledger = ledger
            name = "Eigen vermogen"
          },
          debt: Category {
            ledger = ledger
            name = "Vreemd vermogen"
          }
      },
      auxiliaries: Category {
        name = "Hulprekeningen"
      }
      
    accounts =
      r1: Account {
        number = 1
        type = "asset/current"
        name = "Voorraad"
      },
      r2: Account {
        number = 2
        type = "asset/current"
        name = "Debiteuren"
      },
      r120: Account {
        number = 120
        type = "asset/current"
        name = "Bank"
      },
      r4: Account {
        number = 4
        type = "asset/current"
        name = "Register"
      },
      
      r5: Account {
        number = 5
        type = "liability/equity"
        name = "Eigen vermogen"
      },
      
      r6: Account {
        number = 6
        type = "liability/debt"
        name = "Crediteuren"
      },
      r150: Account {
        number = 150
        type = "liability/debt"
        name = "Af te dragen loonheffingen"
      },
      
      r7: Account {
        number = 7
        type = "auxiliary/revenue"
        name = "Opbrengst verkopen"
      },
      r8: Account {
        number = 8
        type = "auxiliary/expense"
        name = "Inkoopprijs verkopen"
      },
      r9: Account {
        number = 9
        type = "auxiliary/expense"
        name = "Huurkosten"
      },
      r10: Account {
        number = 10
        type = "auxiliary/expense"
        name = "Loonkosten"
      },
      r11: Account {
        number = 11
        type = "auxiliary/expense"
        name = "Overige kosten"
      },
      r410: Account {
        number = 410
        type = "auxiliary/expense"
        name = "Loonkosten"
      },
      r412: Account {
        number = 412
        type = "auxiliary/expense"
        name = "Sociale lasten"
      }
  }
  
  journal: Journal {
    ledger = ledger
    entries =
      balance: Entry {
        description = "Naar balans"
        date = 2020-01-01 00:00:00
        mutations =
          m1: Mutation {
            account = r1
            debit = 80000.0
            credit = 35000.0
          },
          m2: Mutation {
            account = r2
            debit = 73000.0
            credit = 23000.0
          },
          m3: Mutation {
            account = r150
            debit = 39000.0
            credit = 32700.0
          },
          m4: Mutation {
            account = r4
            debit = 11000.0
            credit = 1300.0
          },
          m5: Mutation {
            account = r5
            debit = no value
            credit = 65000.0
          },
          m6: Mutation {
            account = r6
            debit = 25000.0
            credit = 65000.0
          },
          m7: Mutation {
            account = r7
            debit = no value
            credit = 50000.0
          },
          m8: Mutation {
            account = r8
            debit = 35000.0
            credit = no value
          },
          m9: Mutation {
            account = r9
            debit = 3000.0
            credit = no value
          },
          m10: Mutation {
            account = r10
            debit = 4700.0
            credit = no value
          },
          m11: Mutation {
            account = r11
            debit = 1300.0
            credit = no value
          }
      }
  }
  
  salary1: Salary {
  	description = "Aedan Petersen (CEO)"
  	grossMonthSalary = 10000.0
  }
  salary2: Salary {
  	description = "Jazmine Vang (HR Manager)"
  	grossMonthSalary = 3500.0
  }
  salary3: Salary {
  	description = "Rayan Garner (Janitor)"
  	grossMonthSalary = 2500.0
  }

execute
  
  ledger.balanced
  
