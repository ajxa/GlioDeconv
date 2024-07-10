# This script contains the server logic for the GBMDeconvoluteR Shiny web application. 
# You can run the application by clicking 'Run App' above.

server <- function(input, output, session) {
# SESSION INFO -----------------------------------------------------------------  
  
  session$onSessionEnded(stopApp)
  
  output$sessionInfo <- renderPrint({
    capture.output(sessionInfo())
  })  
  
# HELP MODALS  -----------------------------------------------------------------  

  # File Uploads
  observeEvent(input$upload_help, {
    
    showModal(
      
      modalDialog( title = "File Uploads",
                   includeMarkdown("tabs/Run/help/help_uploading.Rmd"),
                   footer = NULL,
                   easyClose = TRUE, 
                   fade = TRUE)
    )
  })  
  
  # File Uploads purity
  observeEvent(input$upload_help_purity, {
    showModal(
      modalDialog(
        title = "File Uploads",
        includeMarkdown("tabs/GBMPurity/help/help_uploading_purity.Rmd"),
        footer = NULL,
        easyClose = TRUE,
        fade = TRUE
      )
    )
  })
  
  # Example data
  observeEvent(input$run_example_help, {
    
    showModal(
      
      modalDialog( title = "Run Example Data",
                   includeMarkdown("tabs/Run/help/help_run_example.Rmd"),
                   footer = NULL,
                   easyClose = TRUE, 
                   fade = TRUE)
    )
  })  
  
  # Example data purity
  observeEvent(input$run_example_help_purity, {
    showModal(
      modalDialog(
        title = "Run Example Data",
        includeMarkdown("tabs/GBMPurity/help/help_run_example_purity.Rmd"),
        footer = NULL,
        easyClose = TRUE,
        fade = TRUE
      )
    )
  })
  
  # Marker Gene List
  observeEvent(input$marker_genelist_help, {
    
    showModal(
      
      modalDialog( title = "Marker Gene List Selection",
                   includeMarkdown("tabs/Run/help/help_marker_genelist.Rmd"),
                   footer = NULL,
                   easyClose = TRUE, 
                   fade = TRUE)
    )
  })  
  
  # Tumour Intrinsic Genes
  observeEvent(input$TI_genes_help, {
  
    showModal(
      
      modalDialog( title = "Tumour Intrinsic Genes",
                   includeMarkdown("tabs/Run/help/help_tumour_intrinsic.Rmd"),
                   footer = NULL,
                   easyClose = TRUE, 
                   fade = TRUE)
      )
  })  
  
# GBMPURITY TAB ----------------------------------------------------------------
  
  # URL navigation
  observe({
    path <- sub("/", "", session$clientData$url_pathname)
    updateNavbarPage(session, "nav", selected = path)
  })
  
  observeEvent(input$nav, {
    path <- paste0("/", input$nav)
    session$sendCustomMessage(type = "setPath", path)
  })
  
  observe({
    if (input$nav == "GBMPurity") {
      # Reactive expression to handle uploaded file for GBMPurity
      data_purity <- reactive({
        if (input$example_data_purity) {
          example <- read.csv("data/GBMPurity-example-input.csv")
          return(example)
        } else {
          if (input$example_data_purity == FALSE && is.null(input$upload_file_purity)) {
            validate("Please upload data or run example to view")
          }
          req(input$upload_file_purity)
          ext <- tools::file_ext(input$upload_file_purity$name)
          if (ext %in% c("csv", "tsv", "xlsx")) {
            tryCatch(
              {
                py_data <- py$pyLoadData(ext, input$upload_file_purity$datapath)
                return(py_to_r(py_data))
              },
              error = function(e) {
                showModal(modalDialog(
                  title = "Error",
                  paste("Failed to read the file:", e$message),
                  easyClose = TRUE,
                  footer = NULL
                ))
                NULL
              }
            )
          } else {
            validate("Invalid file; Please upload a .csv, .tsv, or .xlsx file")
          }
        }
      })

      # Render input for GBMPurity
      output$uploaded_data_purity <- renderDT({
        req(data_purity())
        datatable(data_purity(), options = list(dom = "lrtip"), rownames = FALSE)
      })

      data_purity_processed <- reactive({
        req(data_purity())
        tryCatch(
          {
            results <- py$pyCheckData(data_purity())
            errors <- results[[1]]
            warnings <- results[[2]]
            data <- results[[3]]

            if (length(errors) > 0) {
              error_message <- paste(
                "We encountered the following error(s),
                please check and reupload the data:<br><ul>",
                paste(paste("<li>", errors, "</li>"), collapse = ""),
                "</ul>"
              )
              showModal(modalDialog(
                title = "Error",
                HTML(error_message),
                easyClose = TRUE,
                footer = NULL
              ))
              return(NULL)
            }

            if (length(warnings) > 0) {
              warning_message <- paste(
                "We encountered the following warning(s),
                please read and understand them before proceeding:<br><ul>",
                paste(paste("<li>", warnings, "</li>"), collapse = ""),
                "</ul>"
              )
              showModal(modalDialog(
                title = "Warnings",
                HTML(warning_message),
                easyClose = FALSE,
                footer = modalButton("Proceed")
              ))
              return(data)
            }

            return(data)
          },
          error = function(e) {
            showModal(modalDialog(
              title = "Error",
              paste("Failed to process the file:", e$message),
              easyClose = TRUE,
              footer = NULL
            ))
            NULL
          }
        )
      })

      # Compute purities on uploaded data
      purity_estimates <- reactive({
        req(data_purity_processed())
        tryCatch(
          {
            py_data <- py$GBMPurity(data_purity_processed())
            df <- py_to_r(py_data)
            df$Purity <- as.numeric(df$Purity)
            df$Purity <- round(df$Purity, 3)
            return(df)
          },
          error = function(e) {
            showModal(modalDialog(
              title = "Error",
              paste("GBMPurity failed to run:", e$message),
              easyClose = TRUE,
              footer = NULL
            ))
            NULL
          }
        )
      })

      # Render purity results
      output$purity_estimates <- renderDT({
        req(purity_estimates())
        datatable(purity_estimates(), options = list(dom = "lrtip"), rownames = FALSE)
      })

      # Conditional file format selection input
      output$file_format_purity <- renderUI({
        req(input$upload_file_purity) # Ensure file is uploaded
        selectInput(
          inputId = "file_format_purity",
          label = "Download file format",
          choices = c("CSV" = "csv", "Excel" = "xlsx")
        )
      })

      # Conditional download button
      output$download_button_purity <- renderUI({
        req(input$upload_file_purity) # Ensure file is uploaded
        downloadButton(outputId = "download_purity_estimates", label = "Download Results")
      })

      # Download handler for purity estimates
      output$download_purity_estimates <- downloadHandler(
        filename = function() {
          paste("GBMPurity_estimates-", Sys.Date(), ".", input$file_format_purity, sep = "")
        },
        content = function(file) {
          req(input$file_format_purity)
          if (input$file_format_purity == "csv") {
            write.csv(purity_estimates(), file, row.names = FALSE)
          } else if (input$file_format_purity == "xlsx") {
            openxlsx::write.xlsx(purity_estimates(), file, rowNames = FALSE)
          }
        }
      )

      # Display purity plot
      output$purity_plot <- renderPlot(
        {
          req(purity_estimates())

          ggplot(purity_estimates(), aes(y = Purity, x = 1)) +
            geom_violin(fill = "#629dff", alpha = 0.2, color = NA) +
            geom_beeswarm(color = "#629dff", size = 1.5, cex = 1.5) +
            scale_y_continuous(limits = c(-0.02, 1.02)) +
            labs(y = "GBMPurity") +
            theme_minimal() +
            theme(
              axis.title.x = element_blank(),
              axis.text.x = element_blank(),
              axis.ticks.x = element_blank(),
              panel.grid.major.x = element_blank(),
              panel.grid.minor.x = element_blank()
            )
        },
        res = 96,
      )

      # Beeswarm plot
      # UI for download button
      output$download_button_plot <- renderUI({
        downloadButton("download_plot", "Download Plot")
      })

      # UI for file format selection
      output$file_format_plot <- renderUI({
        selectInput("plot_download_format", "Select format:",
                    choices = c("PNG", "TIFF", "PDF")
        )
      })

      output$download_plot <- downloadHandler(
        filename = function() {
          paste("GBMPurity_plot-", Sys.Date(), ".", tolower(input$plot_download_format), sep = "")
        },
        content = function(file) {
          plot <- ggplot(purity_estimates(), aes(y = Purity, x = 1)) +
            geom_violin(fill = "#629dff", alpha = 0.2, color = NA) +
            geom_beeswarm(color = "#629dff", size = 2, cex = 1.5) +
            scale_y_continuous(limits = c(-0.02, 1.02)) +
            labs(y = "GBMPurity") +
            theme_minimal() +
            theme(
              axis.title.x = element_blank(),
              axis.text.x = element_blank(),
              axis.ticks.x = element_blank(),
              panel.grid.major.x = element_blank(),
              panel.grid.minor.x = element_blank()
            )

          if (input$plot_download_format == "PNG") {
            ggsave(file, plot, width = 4, height = 6, units = "in", dpi = 300, device = "png")
          } else if (input$plot_download_format == "TIFF") {
            ggsave(file, plot, width = 4, height = 6, units = "in", dpi = 300, device = "tiff")
          } else if (input$plot_download_format == "PDF") {
            ggsave(file, plot, width = 4, height = 6, units = "in", device = "pdf")
          }
        }
      )

      output$about_content <- renderUI({
        includeMarkdown("tabs/GBMPurity/help/about_GBMPurity.rmd")
      })
  }
  })

# DYNAMICALLY GENERATED RESET BUTTON -------------------------------------------

  # Render the file reset button UI dynamically when a file is uploaded
  output$reset_button <- renderUI({

    if(!is.null(input$upload_file)){

      actionButton(inputId = "reset", 
                   label = "Reset File Input")
    }

  })
  
  # Reset file upload when the reset button is clicked
  observeEvent(input$reset, {

    # Reset the file input by updating its value to NULL
    shinyjs::reset()

  })
  
  observeEvent(!is.null(input$upload_file), {
    
    reset("example_data")
    
  })


# USER DATA AND EXAMPLE DATA ---------------------------------------------------
 
  # Reactive function to ensure data is present
  data_present <- reactive({
    
    if(input$example_data == FALSE && is.null(input$upload_file)){
      
      validate('Please upload data or run example to view')
      
    }else return(TRUE)

  })
  
  # User selected input data
  data <- reactive({
  
    req(data_present())
    
    if(input$example_data){
      
      return(example_data)
      
    }else{
      
      return(
        load_user_data(name = input$upload_file$name,
                       path = input$upload_file$datapath)
        )
    }
    
  })
 
  # Reactive function to check user data
  input_check <- reactive({

    check_user_data(data())

  })
  
  # Logic for the file input error modals
  observeEvent(!is.null(data()),{

    input_check <- check_user_data(data())

    if(!is.null(input_check)){
      
      shinyWidgets::show_alert(title = "ERROR",
                               type = "error",
                               btn_labels = 'Dismiss',
                               btn_colors = "#b0aece",
                               text = input_check)
    }

  }, priority = 1, ignoreNULL = FALSE, once = FALSE)

  
# DATA PREPROCESSING -----------------------------------------------------------  
  
  # Preprocess the user data
  cleaned_data <- reactive({
    
    req(is.null(input_check()))
    
    preprocess_data(data())
    
  })
  
  output$uploaded_data <- DT::renderDataTable({

    req(cleaned_data())
    
      datatable(cleaned_data(), rownames = TRUE)
    
  }, server = TRUE)
  
# DECONVOLUTION MARKERS --------------------------------------------------------
  
  # get_markers =  gene_markers$ajaib2022
  # 
  # cleaned_data = preprocess_data(example_data)
  # 
  # check_marker_coverage(
  #   input = cleaned_data,
  #   markers = get_markers,
  #   conserved_min = 50
  # )

  # User selected markers
  get_markers <- reactive({
    
    req(cleaned_data(), cancelOutput = TRUE)
    
    selected = switch(input$markergenelist,
      `Ajaib et.al (2022)` = gene_markers$ajaib2022,
      `Ruiz-Moreno et.al (2022)` = gene_markers$moreno2022
      )
    
    # if(input$tumour_intrinsic){
    #   
    #   deconv_markers(
    #     exprs_matrix = cleaned_data(),
    #     neftel_sigs = selected_markers$neoplastic_markers,
    #     TI_genes_only = TRUE,
    #     TI_markers = gene_markers$wang2017_tumor_intrinsic,
    #     immune_markers =  selected_markers$immune_markers
    #   )
    # 
    # }else{
    # 
    #   deconv_markers(
    #     exprs_matrix = cleaned_data(),
    #     neftel_sigs = selected_markers$neoplastic_markers,
    #     immune_markers =  selected_markers$immune_markers
    #   )
    # }
    
  })
  
  # Check the refined markers
  marker_coverage_check <- reactive({
    
    req(cleaned_data(), cancelOutput = TRUE)
    
    check_marker_coverage(input = cleaned_data(),
                          markers = get_markers(),
                          conserved_min = 50)
    
  })
  
  # Logic for the file input error modals
  observeEvent(!is.null(marker_coverage_check()),{

    if(!is.null(marker_coverage_check())){
    
    shinyWidgets::show_alert(title = "Error: Low Marker Coverage",
                             type = "error",
                             btn_labels = 'Dismiss',
                             btn_colors = "#b0aece",
                             text = marker_coverage_check()$error_msg,
                             html = TRUE
                             )
      
    }

    }, priority = 1, ignoreNULL = FALSE, once = FALSE)

  output$deconv_markers <- DT::renderDataTable({
    
    req(!is.null(get_markers()))
    
    if(!is.null(marker_coverage_check())){
      
      datatable(marker_coverage_check()$coverage_table, 
                rownames = FALSE, 
                extensions = c("FixedColumns", 'Buttons')
                )
      
    }else{
      
      datatable(get_markers(), rownames = FALSE, 
                extensions = c("FixedColumns", 'Buttons')
                )
    }
    
  }, server = TRUE)
  
# DECONVOLUTION SCORES ---------------------------------------------------------
  
  # Score the cleaned data using the refined markers
  scores  <-  reactive({
    
    req(get_markers(), cancelOutput = FALSE)
    
    if(!is.null(marker_coverage_check())){
      
      validate('Gene coverage is too low to score data')
    
    }
    
    score_data(exprs_data = cleaned_data(),
               markers = get_markers(),
               out_digits = 2)
    }) 
    
  output$deconv_scores <- DT::renderDataTable({
    
    datatable(scores(),
              rownames = FALSE, 
              extensions = c("FixedColumns", 'Buttons')
              )
    
  }, server = TRUE)
  
# PLOT SCORES ------------------------------------------------------------------
  
  plot_output <- reactive({
    
    req(scores(), cancelOutput = FALSE)
    
    switch(input$markergenelist,
           
           `Ajaib et.al (2022)` = plot_scores(scores = scores(),
                                              plot_order = plot_order$ajaib_et_al_2022),
           
           `Ruiz-Moreno et.al (2022)` = plot_scores(scores = scores(),
                                                   plot_order = plot_order$moreno_et_al_2022)
             )

  })
  
  # Dynamically scale the width of the bar plot
  scale_plot_width <- reactive({

    if(nrow(scores()) > 2){
      
      scaling_factor <- nrow(scores()) * 50
      
      return( 400 + scaling_factor)
      
    } else return(400)
  
  })
  
  
  scale_plot_height <- reactive({
    
    switch(input$markergenelist,
           
           `Ajaib et.al (2022)` = 2500,
           
           `Ruiz-Moreno et.al (2022)` = 4000
    )
    
    
  })
  

  output$scores_plot <- renderPlot(plot_output(), 
                                   width = scale_plot_width, 
                                   height = scale_plot_height
                                   ) 
  
# DYNAMIC DOWNLOAD PLOT BUTTON -------------------------------------------------
  
  # Dynamically render the plot download button
  output$download_options <- renderUI({
    
    if(!is.null(input$upload_file) || input$example_data == TRUE) {
      
      if(is.null(marker_coverage_check())){
      
      dropdown(
        
        selectInput(inputId = "file_format", 
                    label = tags$p("File Type",
                                   style = "font-weight: 300;
                                          color: #0000006e;
                                          margin-bottom: 0px"),
                    choices= list("Vector Graphic Formats" = c("pdf","svg"),
                                  "Raster Graphic Formats" = c("png","tiff")),
                    multiple = FALSE),
        br(),
        
        downloadBttn(outputId = "downloadData",
                     label = "Click to Download",
                     style = "unite",
                     color = "success",
                     size = "sm",
                     no_outline = TRUE),
        
        style = "simple",
        size = "md",
        label = "",
        no_outline = TRUE,
        icon = icon("sliders", verify_fa = FALSE),
        
        tooltip = tooltipOptions(placement = "right",
                                 title = "Download Options") ,
        status = "primary", 
        width = "215px",
        
        animate = animateOptions(
          enter = animations$fading_entrances$fadeInLeftBig,
          exit = animations$fading_exits$fadeOutRightBig
        ),
      )
      
        }
      }
    
  })
  
  
# DOWNLOAD BUTTON HANDLER ------------------------------------------------------

  output$downloadData <- downloadHandler(
    
    contentType = paste("img/", input$file_format, sep = ""),
    
    filename = function(){
      
      paste(format(Sys.time(), "%d-%m-%Y %H-%M-%S"),
            "_GBMDeconvoluteR_plot.", 
            input$file_format, 
            sep = "") 
    },
      
    content = function(file) {
    
      # Dynamically set plot width 
      plot_width <- function(min_width = 6, sample_scaling= 0.5){
        
        if(nrow(scores()) > 3){
          
          scaling_factor <- nrow(scores()) * sample_scaling
          
          return( min_width * 1 + scaling_factor)
          
        } else return(min_width)
        
      }
      
      # Dynamically set plot width 
      plot_height <- function(){
        
        switch(input$markergenelist,
               
               `Ajaib et.al (2022)` = 30,
               
               `Ruiz-Moreno et.al (2022)` = 45
        )
        
      }
      
      if(input$file_format == "svg"){
        
        svglite::svglite(filename = file,
                         width = plot_width(),
                         height = plot_height())
        
        plot(plot_output())
        
        dev.off()
        
      }else if(input$file_format == "pdf"){
        
        pdf(file = file, 
            width = plot_width(),
            height = plot_height())
        
        plot(plot_output())
        
        dev.off()
        
      }else if(input$file_format == "tiff"){
        
        tiff(
          filename = file, 
          width = plot_width(),
          height = plot_height(),
          units = "in",
          res = 300)
        
        plot(plot_output())
        
        dev.off()
        
      }else if(input$file_format == "png"){
        
        png(
          filename = file, 
          width = plot_width(),
          height = plot_height(),
          units = "in",
          res = 300)
        
        plot(plot_output())
        
        dev.off()
        
      }
      
        # ggsave(file,
        #        plot = plot_output(),
        #        width = plot_width(),
        #        device =  grDevices::cairo_ps,
        #        height = plot_height(),
        #        units = "in",
        #        limitsize = FALSE)


      }
    
    )
  
# END --------------------------------------------------------------------------  
}
