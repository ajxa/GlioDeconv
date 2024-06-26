# This script contains the server logic for the GBMDeconvoluteR Shiny web application.
# You can run the application by clicking 'Run App' above.


shinyServer(function(input, output, session) {
  # SESSION INFO -----------------------------------------------------------------

  session$onSessionEnded(stopApp)

  output$sessionInfo <- renderPrint({
    capture.output(sessionInfo())
  })

  # HELP MODALS  -----------------------------------------------------------------

  # File Uploads
  observeEvent(input$upload_help, {
    showModal(
      modalDialog(
        title = "File Uploads",
        includeMarkdown("tabs/Run/help/help_uploading.Rmd"),
        footer = NULL,
        easyClose = TRUE,
        fade = TRUE
      )
    )
  })

  # File Uploads purity
  observeEvent(input$upload_help_purity, {
    showModal(
      modalDialog(
        title = "File Uploads",
        includeMarkdown("tabs/GBMpurity/help/help_uploading_purity.Rmd"),
        footer = NULL,
        easyClose = TRUE,
        fade = TRUE
      )
    )
  })

  # Example data
  observeEvent(input$run_example_help, {
    showModal(
      modalDialog(
        title = "Run Example Data",
        includeMarkdown("tabs/Run/help/help_run_example.Rmd"),
        footer = NULL,
        easyClose = TRUE,
        fade = TRUE
      )
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
      modalDialog(
        title = "Marker Gene List Selection",
        includeMarkdown("tabs/Run/help/help_marker_genelist.Rmd"),
        footer = NULL,
        easyClose = TRUE,
        fade = TRUE
      )
    )
  })

  # Tumour Intrinsic Genes
  observeEvent(input$TI_genes_help, {
    showModal(
      modalDialog(
        title = "Tumour Intrinsic Genes",
        includeMarkdown("tabs/Run/help/help_tumour_intrinsic.Rmd"),
        footer = NULL,
        easyClose = TRUE,
        fade = TRUE
      )
    )
  })

  ### GBMPurity Tab ----------------------------------------------------------------

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
        if (input$example_data_purity == FALSE && is.null(input$upload_file_purity)) {
          validate("Please upload data or run example to view")
        }
        req(input$upload_file_purity)
        ext <- tools::file_ext(input$upload_file_purity$name)
        if (ext %in% c("csv", "tsv", "xlsx")) {
          py_data <- py$pyLoadData(ext, input$upload_file_purity$datapath)
          return(py_to_r(py_data))
        } else {
          validate("Invalid file; Please upload a .csv, .tsv, or .xlsx file")
        }
      })

      # Render input for GBMPurity
      output$uploaded_data_purity <- renderDT({
        req(data_purity())
        datatable(data_purity(), options = list(dom = "lrtip"), rownames = FALSE)
      })

      # Compute purities on uploaded data
      purity_estimates <- reactive({
        req(data_purity())
        py_data <- py$GBMPurity(data_purity())
        df <- py_to_r(py_data)
        df$Purity <- as.numeric(df$Purity)
        df$Purity <- round(df$Purity, 3)
        return(df)
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
            openxlsx::write.xlsx(purity_estimates(), file, row.names = FALSE)
          }
        }
      )
    }
  })

  # DYNAMICALLY GENERATED BUTTON -------------------------------------------------

  # Reactivity required to display the Run and reset buttons
  output$finishedUploading <- reactive({
    if (is.null(input$upload_file)) 0 else 1
  })

  outputOptions(output, "finishedUploading", suspendWhenHidden = FALSE)


  # USER UPLOADED DATA -----------------------------------------------------------

  data <- reactive({
    if (input$example_data == FALSE && is.null(input$upload_file)) {
      validate("Please upload data or run example to view")
    }

    if (input$example_data) {
      return(example_data)
    }

    return(
      load_user_data(
        name = input$upload_file$name,
        path = input$upload_file$datapath
      )
    )
  })

  input_check <- reactive({
    check_user_data(data())
  })


  # Logic for the file input error modals
  observeEvent(!is.null(data()),
    {
      input_check <- check_user_data(data())

      if (!is.null(input_check)) {
        shinyWidgets::show_alert(
          title = "",
          type = "error",
          btn_labels = "Dismiss",
          btn_colors = "#b0aece",
          text = input_check
        )

        # showModal(modalDialog(
        #   # title = "FILE UPLOAD ERROR!",
        #   tags$br(),
        #   tags$image(src = "error.svg",
        #              style = "width: 25%; display: block; margin-left: auto; margin-right: auto;"),
        #   tags$br(),
        #   tags$text(input_check,
        #   style = "color: gray; font-size: 30px;font-variant-caps: all-small-caps;
        #            font-weight: 900;display: flex; width: 100%; justify-content: center;
        #            align-content: center;"),
        #   footer = NULL,
        #   easyClose = TRUE,
        #   fade = TRUE
        #   ))
      }
    },
    priority = 1,
    ignoreNULL = FALSE,
    once = FALSE
  )


  output$uploaded_data <- DT::renderDataTable(
    {
      req(is.null(input_check()))

      datatable(data(), rownames = FALSE)
    },
    server = TRUE
  )

  # DECONVOLUTION MARKERS -------------------------------------------------------

  cleaned_data <- reactive({
    req(is.null(input_check()))

    preprocess_data(data())
  })

  get_markers <- reactive({
    req(cleaned_data(), cancelOutput = TRUE)


    selected_markers <- switch(input$markergenelist,
      `Ajaib et.al (2022)` = {
        list(
          neoplastic_markers = gene_markers$neftel2019_neoplastic,
          immune_markers = gene_markers$ajaib2022_immune
        )
      },
      `Ruiz-Moreno et.al (2022)` = {
        list(
          neoplastic_markers = gene_markers$moreno2022_neoplastic,
          immune_markers = gene_markers$moreno2022_immune
        )
      }
    )


    if (input$tumour_intrinsic) {
      deconv_markers(
        exprs_matrix = cleaned_data(),
        neftel_sigs = selected_markers$neoplastic_markers,
        TI_genes_only = TRUE,
        TI_markers = gene_markers$wang2017_tumor_intrinsic,
        immune_markers = selected_markers$immune_markers
      )
    } else {
      deconv_markers(
        exprs_matrix = cleaned_data(),
        neftel_sigs = selected_markers$neoplastic_markers,
        immune_markers = selected_markers$immune_markers
      )
    }


    # if(input$tumour_intrinsic){
    #
    #   deconv_markers(exprs_matrix = cleaned_data(),
    #                  neftel_sigs = gene_markers$neftel2019_neoplastic,
    #                  TI_genes_only = TRUE,
    #                  TI_markers = gene_markers$wang2017_tumor_intrinsic,
    #                  immune_markers =  gene_markers$ajaib2022_immune
    #                  )
    #
    #   }else{
    #
    #   deconv_markers(exprs_matrix = cleaned_data(),
    #                  neftel_sigs = gene_markers$neftel2019_neoplastic,
    #                  immune_markers =  gene_markers$ajaib2022_immune)
    #   }
  })

  output$deconv_markers <- DT::renderDataTable(
    {
      datatable(get_markers(),
        rownames = FALSE,
        extensions = c("FixedColumns", "Buttons")
      )
    },
    server = TRUE
  )

  # DECONVOLUTION SCORES ---------------------------------------------------------

  scores <- reactive({
    req(get_markers(), cancelOutput = TRUE)

    score_data(
      exprs_data = cleaned_data(),
      markers = get_markers(),
      out_digits = 2
    )
  })

  output$deconv_scores <- DT::renderDataTable(
    {
      datatable(scores(),
        rownames = FALSE,
        extensions = c("FixedColumns", "Buttons")
      )
    },
    server = TRUE
  )

  # PLOT SCORES ------------------------------------------------------------------

  plot_output <- reactive({
    req(scores())

    switch(input$markergenelist,
      `Ajaib et.al (2022)` = plot_scores(
        scores = scores(),
        plot_order = plot_order$ajaib_et_al_2022
      ),
      `Ruiz-Moreno et.al (2022)` = plot_scores(
        scores = scores(),
        plot_order = plot_order$moreno_et_al_2022
      )
    )
  })

  # Dynamically scale the width of the bar plot
  scale_plot_width <- reactive({
    if (nrow(scores()) > 2) {
      scaling_factor <- nrow(scores()) * 50

      return(400 + scaling_factor)
    } else {
      return(400)
    }
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
  # DOWNLOAD PLOT ---------------------------------------------------------------

  output$download_options <- renderUI({
    req(!is.null(input$upload_file) || input$example_data)

    dropdown(
      selectInput(
        inputId = "file_format",
        label = tags$p("File Type",
          style = "font-weight: 300;
                                          color: #0000006e;
                                          margin-bottom: 0px"
        ),
        choices = list(
          "Vector Graphic Formats" = c("pdf", "svg"),
          "Raster Graphic Formats" = c("png", "tiff")
        ),
        multiple = FALSE
      ),
      br(),
      downloadBttn(
        outputId = "downloadData",
        label = "Click to Download",
        style = "unite",
        color = "success",
        size = "sm",
        no_outline = TRUE
      ),
      style = "simple",
      size = "md",
      label = "",
      no_outline = TRUE,
      icon = icon("sliders", verify_fa = FALSE),
      tooltip = tooltipOptions(
        placement = "right",
        title = "Download Options"
      ),
      status = "primary",
      width = "215px",
      animate = animateOptions(
        enter = animations$fading_entrances$fadeInLeftBig,
        exit = animations$fading_exits$fadeOutRightBig
      )
    )
  })


  output$downloadData <- downloadHandler(
    contentType = paste("img/", input$file_format, sep = ""),
    filename = function() {
      paste(format(Sys.time(), "%d-%m-%Y %H-%M-%S"),
        "_GBMDeconvoluteR_plot.",
        input$file_format,
        sep = ""
      )
    },
    content = function(file) {
      # Dynamically set plot width
      plot_width <- function(min_width = 6, sample_scaling = 0.5) {
        if (nrow(scores()) > 3) {
          scaling_factor <- nrow(scores()) * sample_scaling

          return(min_width * 1 + scaling_factor)
        } else {
          return(min_width)
        }
      }

      # Dynamically set plot width
      plot_height <- function() {
        switch(input$markergenelist,
          `Ajaib et.al (2022)` = 30,
          `Ruiz-Moreno et.al (2022)` = 45
        )
      }

      if (input$file_format == "svg") {
        svglite::svglite(
          filename = file,
          width = plot_width(),
          height = plot_height()
        )

        plot(plot_output())

        dev.off()
      } else if (input$file_format == "pdf") {
        pdf(
          file = file,
          width = plot_width(),
          height = plot_height()
        )

        plot(plot_output())

        dev.off()
      } else if (input$file_format == "tiff") {
        tiff(
          filename = file,
          width = plot_width(),
          height = plot_height(),
          units = "in",
          res = 300
        )

        plot(plot_output())

        dev.off()
      } else if (input$file_format == "png") {
        png(
          filename = file,
          width = plot_width(),
          height = plot_height(),
          units = "in",
          res = 300
        )

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
})
