score_data <- function(exprs_data, markers, out_digits = 2){
  
  scores <- MCPcounter::MCPcounter.estimate(exprs_data, 
                                            featuresType = "HUGO_symbols", 
                                            genes = markers)
  
  as.data.frame(t(scores)) %>%
    
    tibble::rownames_to_column(var = "Mixture") %>%
    
    rename(Macrophage = TAM,
           Monocyte = Monocytes) %>%
    
    rename_with(~str_replace_all(.,"cells$", "Cells")) %>%
    
    mutate(across(-Mixture, ~round(.x, digits = out_digits))) %>%
    
    arrange("AC","MES","NPC", "OPC",
            "DC","Mast Cells","B Cells",
            "T Cells", "NK Cells", "Monocyte",
            "Macrophage", "Microglia")
  
}