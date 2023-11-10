# This is the main user-interface definition for the 
# GBMDeconvoluteR Shiny web application. 
ui <-  navbarPage(
    title = div(
      div(
        id = "img-id",
        img(src = "Leeds_Uni_Logo.png", height = "60px", width = "170px")
      )
    ),
    header = useShinyjs(), # Set up shinyjs
    collapsible = TRUE,
    windowTitle = "GBMDeconvoluteR",
    fluid = TRUE,
    footer = includeHTML("tools/footer.html"),
    id = "nav",
    source("tabs/Home/homeTab.R", local = TRUE)$value,
    source("tabs/Run/runTab.R", local = TRUE)$value,
    source("tabs/About/aboutTab.R", local = TRUE)$value
  )

