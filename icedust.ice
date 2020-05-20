module icedust // ctree collection=?+-2s constraints=0.025s analysis2=0.25s // jar collection=?<1s constraints=0.015 analysis2=0.05s

model

  entity Ledger {
    debit : Float = sum(accounts.net_debit) <+ 0.0 (incremental)
    credit : Float = sum(accounts.net_credit) <+ 0.0 (incremental)
    balanced : Boolean = sum(accounts.credit) == sum(accounts.debit)
  }
  
  entity Category {
    name : String = "" (default)
    path : String = (parent.path <+ "") + " / " + name (incremental)
  }
  
  relation Category.parent ? <-> * Category.children
  relation Category.ledger 1 <-> * Ledger.categories
  relation Account.category ? <-> * Category.accounts

  entity Account {
    type : String = "asset" (default)
    side : String =
      switch {
        case type == "asset" => "debit"
        case type == "auxiliary/expense" => "debit"
        case type == "liability/equity" => "credit"
        case type == "liability" => "credit"
        case type == "auxiliary/revenue" => "credit"
        default => "credit"
      }
    name : String  = "Untitled" (default)
    number : Int = 0 (default)
    debit : Float = sum(mutations.debit) <+ 0.0
    credit : Float = sum(mutations.credit) <+ 0.0
    net_debit : Float = if (debit > credit) debit - credit else 0.0 (incremental)
    net_credit : Float = if (credit > debit) credit - debit else 0.0 (incremental)
    balance : Float = if (side == "credit") credit - debit else debit - credit
  }
  
  relation Ledger.accounts * <-> 1 Account.ledger
  relation Ledger.assets * = accounts.filter(x => x.type == "asset") <-> ? Account.ledger_as_asset
  relation Ledger.equities * = accounts.filter(x => x.type == "equity") <-> ? Account.ledger_as_equity
  relation Ledger.liabilities * = accounts.filter(x => x.type == "liability") <-> ? Account.ledger_as_liability
  relation Ledger.revenues * = accounts.filter(x => x.type == "revenue") <-> ? Account.ledger_as_revenue
  relation Ledger.expenses * = accounts.filter(x => x.type == "expense") <-> ? Account.ledger_as_expense
  
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
    date : Datetime = entry.date
    debit : Float = 0.0 (default)
    credit : Float = 0.0 (default)
  }
  
  relation Mutation.account 1 <-> * Account.mutations
  relation Mutation.entry 1 <-> + Entry.mutations 
  relation Mutation.journal 1 =
    entry.journal <-> * Journal.mutations

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
        type = "asset"
        name = "Voorraad"
      },
      r2: Account {
        number = 2
        type = "asset"
        name = "Debiteuren"
      },
      r3: Account {
        number = 3
        type = "asset"
        name = "Bank"
      },
      r4: Account {
        number = 4
        type = "asset"
        name = "Register"
      },
      
      r5: Account {
        number = 5
        type = "equity"
        name = "Eigen vermogen"
      },
      
      r6: Account {
        number = 6
        type = "liability"
        name = "Crediteuren"
      },
      
      r7: Account {
        number = 7
        type = "revenue"
        name = "Opbrengst verkopen"
      },
      r8: Account {
        number = 8
        type = "xpense"
        name = "Inkoopprijs verkopen"
      },
      r9: Account {
        number = 9
        type = "expense"
        name = "Huurkosten"
      },
      r10: Account {
        number = 10
        type = "expense"
        name = "Loonkosten"
      },
      r11: Account {
        number = 11
        type = "expense"
        name = "Overige kosten"
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
            account = r3
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

execute
  
  ledger.balanced
  
