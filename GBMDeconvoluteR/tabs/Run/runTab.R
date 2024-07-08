# UI-elements for the Run page
# this page consists of a tab panel where the options are set on a sidebar panel
# which will be on the left side of the page and then the results will be displayed
# on a main tabbed panel on the right hand side of the page.

tabPanel(
  
  title = "Run", icon = icon("running", lib = "font-awesome"),
  
  tagList(tags$head(includeCSS("www/styles.css"))),
  
  div(id = "run",
      
      sidebarLayout(
        
        fluid = FALSE,
        
        # SIDEBAR PANEL START ----
        
        sidebarPanel = sidebarPanel( id = "side-panel",
          
          # UPLOAD DATA WELL PANEL 
          
          tags$h4("Select Data"),
          
          br(), br(),

          fileInput(inputId = "upload_file",
                    multiple = FALSE,
                    label = tags$div(
                      class = "deconv_option_header",
                      "Upload Expression",
                      shiny::actionLink("upload_help", 
                                        label = img(src="Icons/help.svg", 
                                                    class = "help_icon"))
                      ),
                    buttonLabel = "Browse...",
                    accept=c(".csv", ".tsv", ".xlsx")),
          
          uiOutput(outputId = "reset_button", inline = TRUE),
          
          
          shinyWidgets::materialSwitch(inputId = "example_data",
                                       label = tags$div(
                                         class = "deconv_option_header2",
                                         "Run Example",
                                         shiny::actionLink("run_example_help", 
                                                           label = img(src="Icons/help.svg", 
                                                                       class = "help_icon")),
                                                        ),
                                       inline = TRUE, 
                                       value = FALSE,
                                       status = "primary"),
          
          # Code for conditional reset button
          
          # conditionalPanel(condition = "output.finishedUploading || input.example_data",
          # 
          #                  br(),
          #                  
          #                  div(style="display:inline-block;width:100%;text-align: center;",
          #                      
          #                      shinyWidgets::actionBttn(inputId = "reset",
          #                                               style = "unite",
          #                                               color = "primary",
          #                                               icon =  icon("arrow-rotate-left",
          #                                                            verify_fa = FALSE),
          #                                               size = "sm",
          #                                               label = "Clear Data")
          #                      )),
          
          hr(class = "hr_runpanel"),
          
          br(), 
          
          # RUN DECONVOLUTION WELL PANEL
          
          tags$h4("Deconvolution"),
          
          br(), br(),
          
          selectInput(inputId = "markergenelist",
                      label = tags$div(class = "deconv_option_header",
                                       "Marker Gene List",
                                       shiny::actionLink("marker_genelist_help", 
                                                         label = img(src="Icons/help.svg", 
                                                                     class = "help_icon"))
                      ),
                      
                      choices = c("Ajaib et.al (2022)","Ruiz-Moreno et.al (2022)"),
                      selected = c("Ajaib et.al (2022)"),
                      multiple = FALSE,
                      width = '200px',
                      ),
          br(),
          
          # # Input: Decimal interval with step value ----
          # sliderInput(inputId = "conserved_genes",
          #             label = tags$div(class = "deconv_option_header",
          #                              "% Genes Conserved",
          #                              shiny::actionLink("genes_conserved_percent", 
          #                                                label = img(src="Icons/help.svg", 
          #                                                            class = "help_icon"))
          #             ),
          #             min = 0, max = 100,
          #             value = 70, step = 5,
          #             width = '225px'),
          # 
          # br(),
          
          radioButtons(inputId = "tumour_intrinsic",
                       label = tags$div(class = "deconv_option_header",
                                        "Tumour Intrinsic Genes",
                                        shiny::actionLink("TI_genes_help", 
                                                          label = img(src="Icons/help.svg", 
                                                                      class = "help_icon"))
                                        ),
                       
                       choices = c("Yes" = TRUE,
                                   "No" = FALSE),
                       
                       inline = TRUE)
          
          # Code for conditional reset and run button
          
          # ,conditionalPanel(condition = "output.finishedUploading || input.example_data",
          #                  
          #                  hr(class = "hr_runpanel"),
          #                  
          #                  br(), 
          #                  
          #                  div(style="display:inline-block;width:100%;text-align: center;",
          #                      
          #                      shinyWidgets::actionBttn(inputId = "run_deconv",
          #                                               style = "unite",
          #                                               color = "success",
          #                                               icon =  icon("running"),
          #                                               size = "md",
          #                                               label = "Run")
          #                      
          #                      ,shinyWidgets::actionBttn(inputId = "reset",
          #                                               style = "unite",
          #                                               color = "danger",
          #                                               icon =  icon("arrow-rotate-left",
          #                                                            verify_fa = FALSE),
          #                                               size = "md",
          #                                               label = "Reset")
          # 
          #                      ))

        ),
        
        # SIDEBAR PANEL END ----
        
        # MAIN PANEL UI START ----
        
        mainPanel(
          
          tabsetPanel(id = "main_runpage_panel",
                      type = "tabs",
                      
            # File upload
            tabPanel(
              title = "Data",
              id = "uploaded_tab",
              value = "data_selected",
              DT::dataTableOutput(outputId = "uploaded_data") %>% 
                shinycssloaders::withSpinner(image = "gifs/Busy_running.gif",
                                             image.width = "50%")
              ),
            
            # Markers
            tabPanel(
              title = "Markers", 
              id = "marker_tab",
              value = "markers_selected",
              
              DT::dataTableOutput(outputId = "deconv_markers") %>% 
                shinycssloaders::withSpinner(image = "gifs/Busy_running.gif",
                                             image.width = "50%")
                     ),
            
            # Scores 
            tabPanel(
              title = "Scores",
              id = "scores_tab",
              value = "scores_selected",
              
              DT::dataTableOutput(outputId = "deconv_scores") %>% 
                shinycssloaders::withSpinner(image = "gifs/Busy_running.gif",
                                             image.width = "50%")
              ),
            
            # Bar plot
            tabPanel(
              title = "Plot",
              id = "barplot_tab",
              value = "barplot_selected", 
              
              style = c("height:575px;overflow-y: scroll;"),
              
              uiOutput("download_options"),
              
              div(id="plot_download_options",
              style ="display: flex;justify-content: center; align-items: flex-start;",
                  
                  uiOutput("filetype_select",
                           style="display: inline-block;vertical-align:top;width:50px;"),

                  uiOutput("download_button", class = "btn-download",
                           style="display: inline-block;vertical-align:top;width:100px;")
                  ),
              
        
              plotOutput(outputId = "scores_plot") %>%
                shinycssloaders::withSpinner(image = "gifs/Busy_running.gif",
                                             image.width = "50%")
              
                     ),
            
            ), # END TABSETPANEL
          
        # MAIN PANEL UI END ----
        
        ) # END MAINPANEL
    
      ) # END SIDEBARLAYOUT
  
  ) # END RUN DIV

) # END TABPANEL

