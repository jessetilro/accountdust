module layout

template layout() {
  head {
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
  
    <title>"AccountDust"</title>
    
    stylesheetTags()
  }
}

template stylesheetTags() {
  <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css" integrity="sha384-9aIt2nRpC12Uk9gS9baDl411NQApFmC26EwAOH8WgZl5MYYxFfc+NcPb1dKGj7Sk" crossorigin="anonymous">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.13.0/css/all.min.css" />  
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Open+Sans:400,700,300" /> 
    
  <link rel="stylesheet" href="/accountdust/stylesheets/page-container.css" />
  <link rel="stylesheet" href="/accountdust/stylesheets/primary-menu.css" />
  <link rel="stylesheet" href="/accountdust/stylesheets/content.css" />
  <link rel="stylesheet" href="/accountdust/stylesheets/pane.css" />
  <link rel="stylesheet" href="/accountdust/stylesheets/clean.css" />
}

template pageContainer() {
  <div class="page-container">
    <div class="page-container__primary">
      <div class="primary-menu">
        navigate root()[class="primary-menu__link"] {
          <i class="fa fas fa-balance-scale"></i><span class="primary-menu__link-text">
            "Balans"
          </span>
        }
        navigate entries()[class="primary-menu__link"] {
          <i class="fa fas fa-file-alt"></i><span class="primary-menu__link-text">
            "Journaal"
          </span>
        }
      </div>
    </div>
    <div class="page-container__secondary">
    </div>
    <div class="page-container__main">
      elements
    </div>
  </div>
}

template content() {
  <div class="content content--padded content--narrow">
    elements
  </div>
}

template clean() {
  <div class="clean">
    <div class="clean__content">
      elements
    </div>
  </div>
}

template pane(title: String) {
  pane(title, "") {
    elements
  }
}

template pane(title: String, subtitle: String) {
  <div class="pane mb-3">
    <div class="pane__body">
      <h5 class="pane-title">
        output(title)
      </h5>
      <h6 class="pane-subtitle mb-2 text-muted">
        output(subtitle)
      </h6>
      
      elements
    </div>
  </div>
}

override attributes submit{ class="btn btn-default" }
override attributes inputInt{ class="inputInt form-control" }
override attributes inputString{ class="inputString form-control" }
override attributes inputEmail{ class="inputEmail form-control" }
override attributes inputSecret{ class="inputSecret form-control" }
override attributes inputURL{ class="inputURL form-control " }
override attributes inputText{ class="inputTextarea inputText form-control" }
override attributes inputWikiText{ class="inputTextarea inputWikiText form-control" }
override attributes inputFloat{ class="inputFloat form-control" }
override attributes inputLong{ class="inputLong form-control" }
override attributes inputDate{ class="inputDate form-control" }
override attributes inputSelect{ class="select form-control" }
override attributes inputSelectMultiple{ class="select form-control" }
override attributes inputFile{ class="inputFile  form-control" }
override attributes inputMultiFile{ class="inputFile  form-control" }
override attributes inputSDF{ class="inputSDF form-control" }