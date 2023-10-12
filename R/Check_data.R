check_user_data <- function(input){
  
  if(ncol(input) < 3){
    
    return("Insufficient samples (< 2) in data")
    
  }else if(nrow(input) < 100){
    
    return("Insufficient genes (n < 100) in data")
    
  }else if(!is.character(input[[1]])){
    
    return("Gene symbols not detected in data")
    
  }else if(length(unique(colnames(input))) != ncol(input)){
    
    return("Duplicate samples detected in the data")
    
  }else if(length(unique(input[[1]])) != nrow(input)){
    
    return("Duplicate genes detected in the data")
    
  }else if(any(apply(input[,-1], 2, function(x) any(is.na(x))))){
    
    return("Missing values detected in the data")
    
  }else if(any(apply(input[,-1], 2, function(x) any(x<0)))){
    
    return("Negative values detected in the data")
    
  }else{
    
    NULL
    
  }
  
}