preprocess_data  <- function(input){
  
  genes <- input[[1]]
  
  exprs_matrix <- as.matrix(input[,-1])
  
  rownames(exprs_matrix) <- genes
  
  exprs_matrix <- tinyscalop::exprs_levels(
    m = exprs_matrix,
    bulk = TRUE,
    log_scale = TRUE
  )
  
  # Filter out any genes which are zero across all samples
  exprs_matrix[Matrix::rowSums(exprs_matrix) != 0, ,drop = FALSE]
  
}
