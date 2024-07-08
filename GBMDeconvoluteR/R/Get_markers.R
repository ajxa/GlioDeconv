deconv_markers <- function(exprs_matrix, 
                           neftel_sigs,  
                           immune_markers,
                           TI_genes_only = FALSE,
                           TI_markers){
  
  # Refine Neftel markers
  set.seed(1234)
  
  refined_markers <- tinyscalop::filter_signatures(m = exprs_matrix,
                                                   sigs = neftel_sigs,
                                                   filter.threshold = 0.4)
  
  refined_markers  <- data.frame("marker" = unlist(refined_markers, 
                                                   use.names = FALSE),
                                 
                                 "population" = rep(names(refined_markers),
                                                    lengths(refined_markers))
  )
  
  if(TI_genes_only){
    
    refined_markers <- refined_markers[refined_markers$marker %in% TI_markers,]
    
  }
  
  
  refined_markers %>%
    
    tidyr::drop_na() %>%
    
    rename("HUGO symbols" = marker,
           "Cell population" = population) %>%
    
    rbind(immune_markers)
  
}
