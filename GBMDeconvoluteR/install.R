#' install.R for GBMDeconvoluteR

# This file is part of GMBDeconvoluteR
# Copyright (C) Shoaib Ali Ajaib
#
# GMBDeconvoluteR is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
# 
# GMBDeconvoluteR is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along with
# this program; if not, see <http://www.gnu.org/licenses/>.

#######################################################
# GMBDeconvoluteR Installation Instructions: 

# 1) Restart R
# 2) Run install_GMBDeconvoluteR(), included below, to install

#######################################################

# install_GBMDeconvoluteR <- function() {
#   
#   if (getRversion() < '4.0.0') stop("GBMDeconvoluteR requires R version 4.0.0 or greater.")
#   
#   
#   msg <- "Note: this will install or update packages needed to run GBMDeconvoluteR Do you want to continue?"
#   
#   
#   continue <- select.list(choices = c("Yes", "No"), 
#                           title = msg, 
#                           graphics = FALSE)
#   
#   
#   if (continue == "No") {
#     message("Installation canceled by user.")
#     return(invisible(NULL))
#   }
#   
#   # install needed packages from CRAN
#   pkg <- c("shiny", "shinyBS", "tidyverse", "DT", "openxlsx",
#            "markdown","devtools","curl")
#   
#   new.pkg <- pkg[!(pkg %in% installed.packages())]
#   
#   if (length(new.pkg)) {
#     install.packages(new.pkg, dependencies=TRUE)
#   }
#   
#   update.packages(pkg[!(pkg %in% new.pkg)])
# 
#   # install needed packages from Bioconductor
#   # bioc <- c()
#   # 
#   # if(!(bioc %in% installed.packages())){
#   #   source("http://bioconductor.org/biocLite.R")
#   #   BiocManager::install(pkgs = bioc)
#   # }
# 
#   # install needed packages from Github
#   
#   devtools::install_github("ajxa/GBMDeconvoluteR")
#   devtools::install_github("ebecht/MCPcounter")
#   
# 
#   message("\n All set. \n You might need to restart R before using GBMDeconvoluteR \n")
#   
#   return(invisible(NULL))
# }
# 
# install_GBMDeconvoluteR()
