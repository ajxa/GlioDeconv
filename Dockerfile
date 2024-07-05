# Install the R(4.2.3) image with shiny server
FROM rocker/shiny:4.2.3

# Install Ubuntu packages
RUN apt-get update && apt-get --no-install-recommends install -y \
    libssl-dev \
    libxml2-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libtiff-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
# Update the installed Ubuntu packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install renv and restore the R packages using the .lock file
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://packagemanager.posit.co/cran/__linux__/focal/latest'))"
COPY ./renv.lock ./renv.lock
# approach one
ENV RENV_PATHS_LIBRARY renv/library
RUN R -e "renv::restore()"

# Copy the Shiny server app code
COPY . /srv/shiny-server

USER shiny

EXPOSE 3838