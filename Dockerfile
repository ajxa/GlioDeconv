FROM rocker/shiny:latest

RUN apt-get update && apt-get --no-install-recommends install -y \
    libssl-dev \
    libxml2-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libtiff-dev \
    libicu-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


RUN mkdir /home/shiny-app
WORKDIR /home/shiny-app/

RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"

RUN mkdir -p renv
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json

COPY renv.lock renv.lock

COPY .Rprofile  .Rprofile
COPY server.R server.R
COPY ui.R ui.R
COPY global.R global.R
COPY data data
COPY R R
COPY tabs tabs
COPY tools tools
COPY www www

RUN R -e "renv::restore(rebuild = TRUE)"

RUN chown -R shiny:shiny /home/shiny-app

USER shiny

EXPOSE 3838

CMD ["/usr/bin/shiny-server"]




#RUN apt-get update && \
#    apt-get upgrade -y && \
#    apt-get clean \
#    rm -rf /var/lib/apt/lists/*

#RUN Rscript -e 'install.packages("renv", repos = c(CRAN = "https://packagemanager.posit.co/cran/__linux__/focal/latest"))'
#COPY ./renv.lock ./renv.lock

#RUN mkdir -p /srv/shiny-server/renv/library && \
#    R -e "renv::restore(lockfile = '/renv.lock', rebuild = TRUE, prompt = FALSE, library = '/srv/shiny-server/renv/library')"

#RUN Rscript -e 'renv::restore()'

#COPY . /srv/shiny-server/

# Ensure permissions are set correctly for the shiny user
#RUN chown -R shiny:shiny /srv/shiny-server
# Switch to the shiny user after all setup steps are complete
#USER shiny
# Expose port 3838
#EXPOSE 3838

#CMD ["/usr/bin/shiny-server"]