# UI-elements for Home tab
tabPanel(title = "Home", icon = icon("home", lib = "font-awesome"),
         tagList(

           tags$head(

             includeCSS("www/styles.css"),
             
             # Javascript for the share buttons at the bottom of the page
             tags$script(
               type="text/javascript",
               src="https://platform-api.sharethis.com/js/sharethis.js#property=62a6096405284b00197c54c9&product=inline-follow-buttons",
               async="async"
               ),
             
             # sets the webpage icon
             tags$link(rel="shortcut icon", href="./page_icon.bmp")
             )
           ),
         
         div(id = "home",
             br(),
             img(src = "Logos/Main_logo_6.png", width = 1150),
             div(class="intro-divider"),
            
             div(class = "lead_head",   
                 "Welcome to GBMDeconvoluteR!"
                 ),
             
             div(class = "lead_text",
                 "A web application for estimating the abundance of immune, stromal and neoplastic cell populations using bulk RNA-sequencing expression profiles, from grade IV glioblastoma (GBM) tumour samples."
                 ),
             
             panel_div(class_type = "primary", 
                       panel_title = "How Does It Work?",
                       content = includeMarkdown("tabs/Home/How_does_It_work.Rmd")),
             
             panel_div(class_type = "primary", 
                       panel_title = "FAQ's",
                       content = includeMarkdown("tabs/Home/FAQs.Rmd"))
             )
         )
