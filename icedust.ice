module icedust // ctree collection=?+-2s constraints=0.025s analysis2=0.25s // jar collection=?<1s constraints=0.015 analysis2=0.05s

model

  entity Balance {
    debit : Float = sum(assets.net_debit) <+ 0.0
    credit : Float = sum(assets.net_credit) <+ 0.0
  }

  entity Account {
    name : String  = "Untitled" (default)
    debit : Float = 0.0 (default)
    credit : Float = 0.0 (default)
    net_debit : Float = if (debit > credit) debit - credit else 0.0 (incremental)
    net_credit : Float = if (credit > debit) credit - debit else 0.0 (incremental)
  }
  
  relation Balance.assets * <-> * Account.balances_as_asset
  relation Balance.liabilities * <-> * Account.balances_as_liability

data

  balance: Balance {
    assets =
      supplies: Account {
        name = "Voorraad"
        debit = 50000.0
      },
      liquid_assets: Account {
        name = "Voorraad"
        debit = 15000.0
      }
    liabilities = 
      equity: Account {
        name = "Eigen vermogen"
        credit = 65000.0
      }
  }

execute

  
