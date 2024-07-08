# UI-elements for About tab
tabPanel(title = "About", icon = icon("info-circle"),
         
         tagList(
           tags$head(includeCSS("www/styles.css"))
           ),
         
         div(id = "about",
             
             panel_div(class_type = "primary", panel_title = "General",
                       content = includeMarkdown("tabs/About/General.Rmd")),
             
         panel_div(class_type = "primary", panel_title = "Data Processing",
                   content = includeMarkdown("tabs/About/Processing.Rmd")),
         
         panel_div(class_type = "primary", panel_title = "Interpreting Scores",
                   content = includeMarkdown("tabs/About/Interperting_scores.Rmd")),
         
         panel_div(class_type = "primary", panel_title = "App Info",
                   content = includeMarkdown("tabs/About/App_info.Rmd")),
         
         panel_div(class_type = "primary", panel_title = "Session Info",
                   content = htmlOutput("sessionInfo"))
         )
)