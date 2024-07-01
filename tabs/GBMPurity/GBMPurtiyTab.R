# UI-elements for the GBMPurity page
# this page consists of a tab panel where the options are set on a sidebar panel
# which will be on the left side of the page and then the results will be displayed
# on a main tabbed panel on the right hand side of the page.

tabPanel(
  title = "GBMPurity", value = "GBMPurity", icon = icon("robot", lib = "font-awesome"),
  tagList(tags$head(includeCSS("www/styles.css"))),
  div(
    id = "run",
    sidebarLayout(
      fluid = FALSE,

      # SIDEBAR PANEL START ----

      sidebarPanel = sidebarPanel(
        id = "side-panel-purity",

        # UPLOAD DATA WELL PANEL

        tags$h4("Select Data"),
        br(), br(),
        fileInput(
          inputId = "upload_file_purity",
          multiple = FALSE,
          label = tags$div(
            class = "deconv_option_header",
            "Upload Expression",
            shiny::actionLink("upload_help_purity",
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
          inputId = "example_data_purity",
          label = tags$div(
            class = "deconv_option_header2",
            "Run Example",
            shiny::actionLink("run_example_help_purity",
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
          id = "main_runpage_panel_purity",
          type = "tabs",

          # File upload
          tabPanel(
            title = "Data",
            id = "uploaded_tab_purity",
            value = "data_selected_purity",
            DT::dataTableOutput(outputId = "uploaded_data_purity") %>%
              shinycssloaders::withSpinner(
                image = "gifs/Busy_running.gif",
                image.width = "50%"
              )
          ),
          tabPanel(
            title = "Results",
            id = "results_tab_purity",
            value = "results_selected_purity",
            uiOutput("file_format_purity", style = "font-size: 14px;"),
            uiOutput("download_button_purity"),
            DT::dataTableOutput(outputId = "purity_estimates") %>%
              shinycssloaders::withSpinner(
                image = "gifs/Busy_running.gif",
                image.width = "50%"
              ),
          ),
          tabPanel(
            title = "Plot",
            id = "plot_tab_purity",
            value = "plot_selected_purity",
            plotOutput("purity_plot", width = "50%") %>%
              shinycssloaders::withSpinner(
                image = "gifs/Busy_running.gif",
                image.width = "50%"
              ),
            br(),
            uiOutput("file_format_plot", style = "font-size: 14px;"),
            uiOutput("download_button_plot")
          )
        ), # END TABSETPANEL
        # MAIN PANEL UI END ----
      ) # END MAINPANEL
    ) # END SIDEBARLAYOUT
  ) # END RUN DIV
) # END TABPANEL
