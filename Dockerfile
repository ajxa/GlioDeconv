# Install R version 3.5
FROM rocker/shiny:latest

# Install Ubuntu packages
RUN apt-get update && apt-get --no-install-recommends install -y \
    libssl-dev \
    libxml2-dev

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean

# Install R packages that are required using renv
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"
COPY ./renv.lock ./renv.lock
# approach one
#ENV RENV_PATHS_LIBRARY renv/library
# approach two
RUN mkdir -p renv
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json
RUN R -e "renv::restore()"

# Copy the Shiny server app code
COPY . /srv/shiny-server

USER shiny

EXPOSE 3838