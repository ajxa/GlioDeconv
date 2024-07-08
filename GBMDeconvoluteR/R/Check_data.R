check_user_data <- function(input){
  
  if(ncol(input) < 3){
    
    return("Insufficient samples (< 2) in data")
    
  }else if(nrow(input) < 500){
    
    return("Insufficient genes (n < 500) in data")
    
  }else if(!is.character(input[[1]])){
    
    return("Gene symbols not detected in the first column")
    
  }else if(length(unique(colnames(input))) != ncol(input)){
    
    return("Duplicate sample names detected in the data")
    
  }else if(length(unique(input[[1]])) != nrow(input)){
    
    return("Duplicate genes symbols detected in the data")
    
  }else if(any(apply(input[,-1], 2, function(x) any(is.na(x))))){
    
    return("Missing values detected in the data")
    
  }else if(any(apply(input[,-1], 2, function(x) any(x<0)))){
    
    return("Negative values detected in the data")
    
  }else{
    
    NULL
    
  }
  
}