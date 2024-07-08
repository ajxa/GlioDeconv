check_marker_coverage <- function(input, markers, conserved_min = 50) {
  
  markers$Missing = !markers$`HUGO symbols` %in% rownames(input)
  
  marker_coverage = markers %>%
    dplyr::group_by(`Cell population`, Type) %>%
    dplyr::summarise(
      `Total Markers` = dplyr::n(),
      `Present Markers` = length(which(!Missing)),
      `Missing Markers` = length(which(Missing)), .groups = "keep"
      ) %>%
    dplyr::ungroup() %>%
    dplyr::arrange(dplyr::desc(`Missing Markers`))
  
  
  coverage_groups = marker_coverage %>%
    dplyr::group_by(Type) %>%
    dplyr::summarise(coverage = sum(`Missing Markers`)/sum(`Total Markers`)*100) %>%
    dplyr::ungroup()
  
  
  if(any(!coverage_groups$coverage < conserved_min)){
  
    # "This data is....<br>Please, be careful with..."
    
    error_msg = glue::glue("More than {conserved_min}% of the genes in the uploaded data are 
                           missing in the selected marker gene list.
                           <br><br> <i>Please see the Markers tab for a detailed breakdown</i>")
  
    
    return(
      list(
        error_msg = HTML(error_msg),
        coverage_table = marker_coverage
        )
      )
    
    }else NULL
  
}
