#' global.R for GBMDeconvoluteR
#
# GBMDeconvoluteR is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published by
# the Free SoftwareFoundation; either version 3 of the License, or (at your option) any later
# version.
#
# GBMDeconvoluteR is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, see <http://www.gnu.org/licenses/>.

# PACKAGES ----

library(shiny)
library(shinyBS)
library(shinyjs)
library(shinyWidgets)
library(shinycssloaders)
library(tidyverse)
library(markdown)
library(DT)
library(MCPcounter)
library(tinyscalop)
library(openxlsx)
library(reticulate)
library(shinymanager)

# Allowing use of Python
use_condaenv("GBMPurity")
source_python("./Python/GBMPurity.py")

# GLOABAL OPTIONS ----

# Disable graphical rendering by the Cairo package, if it is installed
options(shiny.usecairo = TRUE)

# Sets the maximum file upload size to 200Mb
options(shiny.maxRequestSize = 50 * 1024^2)

# DT options

options(
  DT.options = list(
    lengthMenu = list(
      c(50, 100, -1),
      c("50", "100", "All")
    ),
    buttons = list(
      "copy",
      list(
        extend = "collection",
        buttons = c("csv", "excel", "pdf"),
        text = "Download"
      )
    ),
    serverSide = FALSE,
    pagingType = "full",
    dom = "lfBrtip",
    width = "100%",
    height = "100%",
    scrollX = TRUE,
    scrollY = "475px",
    scrollCollapse = TRUE,
    orderClasses = TRUE,
    autoWidth = FALSE,
    search = list(regex = TRUE)
  )
)




# LOAD MULTIPLE DATASETS FUNCTION ----

# Function which reads in multiple datasets at once
# load_datasets <- function(x){
#
#   tryCatch(                       # Applying tryCatch
#
#     expr = {                      # Specifying expression
#
#       assign(x = tools::file_path_sans_ext(basename(x)),
#              value = readRDS(x),
#              envir = .GlobalEnv)
#
#
#       message(
#
#         crayon::green("Loaded", tools::file_path_sans_ext(basename(x))),
#
#         appendLF = TRUE
#
#         )
#
#     },
#
#     error = function(e){          # Specifying error message
#
#       message(
#
#         crayon::red(tools::file_path_sans_ext(basename(x)),
#                     "Could Not Be Loaded!"),
#
#         appendLF = TRUE
#
#         )
#     },
#
#     warning = function(w){        # Specifying warning message
#       message("There was a warning message.")
#     }
#   )
#
# }

# load_datasets usage
# plyr::l_ply(indata, load_datasets)

# LOAD DATASETS ----

gene_markers <- list()

# Neoplastic cell-state markers
gene_markers$neftel2019_neoplastic <- readRDS("data/Neftel_et_al_2019_four_state_neoplastic_markers.rds")

gene_markers$moreno2022_neoplastic <- readRDS("data/Moreno_et_al_2022_lvl3_neoplastic_markers.rds")

# Immune cell markers
gene_markers$ajaib2022_immune <- readRDS("data/Ajaib_et_al_2022_GBM_Immune_markers.rds")

gene_markers$moreno2022_immune <- readRDS("data/Moreno_et_al_2022_lvl3_immune_markers.rds")

# Tumour intrinsic markers
gene_markers$wang2017_tumor_intrinsic <- readRDS("data/Wang_et_al_2017_GBM_TI_markers.rds")

# example data
example_data <- readRDS("data/TGCA_GBM_example.rds")


# Plot colors
plot_cols <- readRDS("data/plot_colors.rds")

# Plot order
plot_order <- readRDS("data/plot_order.rds")

# PANEL DIVS ----

# Generates the panels found on the home and about tabs

panel_div <- function(class_type, panel_title, content) {
  HTML(paste0("<div class='panel panel-", class_type,
    "'> <div class='panel-heading'><h3 class='panel-title'>", panel_title,
    "</h3></div><div class='panel-body'>", content, "</div></div>",
    sep = ""
  ))
}

# END ----
