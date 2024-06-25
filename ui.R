# This is the main user-interface definition for the
# GBMDeconvoluteR Shiny web application.

shinyUI(
  navbarPage(
    title = div(
      div(
        id = "img-id", img(src = "Leeds_Uni_Logo.png", height = "60px", width = "170px")
      )
    ),
    header = tagList(
      useShinyjs(), # Set up shinyjs for tab URLs, handles empty case
      tags$head(tags$script(HTML("
        Shiny.addCustomMessageHandler('setPath', function(path) {
          history.pushState({}, '', path);
        });
        $(document).on('shiny:connected', function(event) {
          var path = window.location.pathname;
          if (path === '/' || path === '') {
            Shiny.setInputValue('nav', 'home');
            history.pushState({}, '', '/home');
          }
        });
      ")))
    ),
    collapsible = TRUE,
    windowTitle = "GBMDeconvoluteR",
    fluid = TRUE,
    footer = includeHTML("tools/footer.html"),
    id = "nav",
    source("tabs/Home/homeTab.R", local = TRUE)$value,
    source("tabs/Run/runTab.R", local = TRUE)$value,
    source("tabs/About/aboutTab.R", local = TRUE)$value,
    source("tabs/GBMPurity/GBMPurtiyTab.R", local = TRUE)$value
  )
)
