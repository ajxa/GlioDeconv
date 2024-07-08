FROM rocker/shiny:4.4.1

RUN sudo apt-get update && sudo apt-get --no-install-recommends install -y \
    libssl-dev \
    libxml2-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libtiff-dev \
    libicu-dev \
    && sudo apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
RUN R -e 'install.packages("renv", repos = c(CRAN = "https://packagemanager.posit.co/cran/__linux__/focal/latest"))'

COPY renv.lock renv.lock

RUN mkdir -p renv

RUN R -e '.libPaths()'
RUN R -e 'install.packages("stringi", type = "source")'
RUN R -e 'install.packages("openssl", type = "source")'
RUN R -e 'renv::restore()'

COPY GBMDeconvoluteR/data/ /srv/shiny-server/data/
COPY GBMDeconvoluteR/R/ /srv/shiny-server/R/
COPY GBMDeconvoluteR/tabs/ /srv/shiny-server/tabs/
COPY GBMDeconvoluteR/www/ /srv/shiny-server/www/
COPY GBMDeconvoluteR/tools/ /srv/shiny-server/tools

COPY GBMDeconvoluteR/global.R /srv/shiny-server/
COPY GBMDeconvoluteR/ui.R /srv/shiny-server/
COPY GBMDeconvoluteR/server.R /srv/shiny-server/

USER shiny
EXPOSE 3838