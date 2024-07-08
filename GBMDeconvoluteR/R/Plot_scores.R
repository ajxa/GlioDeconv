plot_scores <- function(scores, plot_order = NULL){
  
  plot_theme <- function(legend = TRUE, base_txt_size = 24){
    
    out <- theme_classic(base_size = base_txt_size, base_family = "") +
      
      theme(plot.title = element_text(hjust = 0.5, face = "bold"),
            legend.title = element_blank(),
            axis.text = element_text(size = 20),
            axis.text.x = element_text(angle = 90, vjust = 0.5),
            axis.title = element_text(face = "bold"),
            strip.background = element_blank(),
            strip.text.x = element_text(face = "bold", size = 30),
            panel.spacing.y = unit(2, "lines")
      )
    
    if(!legend) out <- out + theme(legend.position = "none")
    
    return(out)
    
  }
  
  
  plot_data <- scores %>%
    
    tidyr::pivot_longer(cols = -Mixture,
                        names_to = "population",
                        values_to = "score") %>%
    
    dplyr::mutate(across(population, factor))
    
  
  if(!is.null(plot_order)){
    
    plot_data <- plot_data %>%
      
      dplyr::mutate(across(population, ~forcats::fct_relevel(., plot_order)))
    
  }
  
  
  # Selecting colours only present in the population variable
  plot_col_filt <- plot_cols[levels(plot_data$population) %in% names(plot_cols)]
  
  plot_col_filt <- plot_col_filt[match(levels(plot_data$population), names(plot_col_filt))]
  
  
  plot_col_filt <- viridis::viridis(n = length(levels(plot_data$population))) %>% 
      set_names(names(plot_col_filt))

  
  ggplot(data = plot_data, aes(x = Mixture, y = score, fill = population)) +
    
    geom_bar(stat = "identity")  +
    
    
    scale_fill_manual(values = plot_col_filt)  +
    
    
    labs(x = "", 
         y = "Cell Type Estimates\n") +
    
    facet_wrap(~ population, scales = "free_y", ncol = 1) +
    
    plot_theme(legend = FALSE)
        

}







