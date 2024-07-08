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
