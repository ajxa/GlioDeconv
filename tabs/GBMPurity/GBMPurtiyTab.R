# UI-elements for the GBMPurity page
# this page consists of a tab panel where the options are set on a sidebar panel
# which will be on the left side of the page and then the results will be displayed
# on a main tabbed panel on the right hand side of the page.

tabPanel(
  title = "GBMPurity", icon = icon("robot", lib = "font-awesome"),
  tagList(tags$head(includeCSS("www/styles.css"))),
  div(
    id = "GBMPurity",
    sidebarLayout(
      fluid = FALSE,

      # SIDEBAR PANEL START ----

      sidebarPanel = sidebarPanel(
        id = "side-panel",

        # UPLOAD DATA WELL PANEL

        tags$h4("Select Data"),
        br(), br(),
        fileInput(
          inputId = "upload_file",
          multiple = FALSE,
          label = tags$div(
            class = "deconv_option_header",
            "Upload Expression",
            shiny::actionLink("upload_help",
              label = img(
                src = "Icons/help.svg",
                class = "help_icon"
              )
            )
          ),
          buttonLabel = "Browse...",
          accept = c(".csv", ".tsv", ".xlsx")
        ),
        shinyWidgets::materialSwitch(
          inputId = "example_data",
          label = tags$div(
            class = "deconv_option_header2",
            "Run Example",
            shiny::actionLink("run_example_help",
              label = img(
                src = "Icons/help.svg",
                class = "help_icon"
              )
            ),
          ),
          inline = TRUE,
          value = FALSE,
          status = "primary"
        ),
      ),

      # SIDEBAR PANEL END ----

      # MAIN PANEL UI START ----

      mainPanel(
        tabsetPanel(
          id = "main_runpage_panel",
          type = "tabs",

          # File upload
          tabPanel(
            title = "Data",
            id = "uploaded_tab",
            value = "data_selected",
            DT::dataTableOutput(outputId = "uploaded_data") %>%
              shinycssloaders::withSpinner(
                image = "gifs/Busy_running.gif",
                image.width = "50%"
              )
          ),
        ), # END TABSETPANEL

        # MAIN PANEL UI END ----
      ) # END MAINPANEL
    ) # END SIDEBARLAYOUT
  ) # END RUN DIV
) # END TABPANEL
