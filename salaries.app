module salaries

template salariesTable(salaries: List<Salary>) {
  table[class="table table-sm"] {
    for (salary: Salary in salaries) {
      <tr>
        <td>
          navigate editSalary(salary) {
            output(salary.getDescription())  
          }
        </td>
        <td>
          output(salary.getGrossMonthSalary())
        </td>
      </tr>
    }
  }
}

page salaries {
  layout()
  
  pageContainer() {
    content {
      pane("Salaries", "Administration of all employees on the payroll") {
          salariesTable(from Salary)          
          
          
          submitlink action {
          			var personnelCosts : PersonnelCosts := PersonnelCosts {
          				salaries := (from Salary).set()
          			};
				    var entry := Entry{
				      journal := (from Journal limit 1)[0]
				      date := today()
				      description := "Payrolls"
				      mutations := Set<Mutation>(
				      	Mutation {
				      		account := (from Account where number = 410 limit 1)[0]
				      		debit := personnelCosts.getCosts()
				      	}
				      )
				    }.save();
				    return editEntry(entry);
				  }[class="btn btn-sm btn-success"]{
				    <i class="fa fas fa-play"></i>
				    " Book payrolls"
			    }
        
      }
    }
  }
}

page editSalary(salary: Salary) {
  layout()
  
  clean {
    pane("Salary") {
    	table { derive viewRows from salary }
    }
  }
}