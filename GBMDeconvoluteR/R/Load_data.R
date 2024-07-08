load_user_data <- function(name, path){
  
  ext <- tools::file_ext(name)
  
  switch(ext,

         csv = readr::read_csv(path, col_types = cols(), name_repair = "minimal"),

         tsv = readr::read_tsv(path, col_types = cols(), name_repair = "minimal"),

         xlsx = openxlsx::read.xlsx(path, colNames = T, check.names = FALSE),

         # validate works similarly to stop() outside of shiny
         validate("Invalid file; Please upload a .csv, .tsv or .xlsx file")

         )
}





