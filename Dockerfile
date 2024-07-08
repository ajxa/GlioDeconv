# Fix the version of R to 4.4.1
FROM rocker/shiny:4.4.1

# Install Ubuntu system dependencies
RUN sudo apt-get update && sudo apt-get --no-install-recommends install -y \
    libssl-dev \
    libxml2-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libtiff-dev \
    libicu-dev \
    build-essential \
    wget \
    && sudo apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install R packages    
RUN R -e 'install.packages("renv", repos = c(CRAN = "https://packagemanager.posit.co/cran/__linux__/focal/latest"))'

COPY renv.lock renv.lock

RUN mkdir -p renv

RUN R -e 'install.packages("stringi", type = "source")'
RUN R -e 'install.packages("openssl", type = "source")'
RUN R -e 'install.packages("xfun", type = "source")'
RUN R -e 'renv::restore()'

# Install Python 3.10.14
RUN wget https://www.python.org/ftp/python/3.10.14/Python-3.10.14.tgz && \
    tar -xvf Python-3.10.14.tgz && \
    cd Python-3.10.14 && \
    ./configure --enable-optimizations --enable-shared && \
    make && \
    make install && \
    ldconfig && \
    cd .. && \
    rm -rf Python-3.10.14 Python-3.10.14.tgz

# Create a Python virtual environment
RUN python3.10 -m venv /opt/GBMPurity
RUN /opt/GBMPurity/bin/pip install --upgrade pip

# Copy the requirements.txt file into the container
COPY requirements.txt /opt/GBMPurity/requirements.txt

# Install Python dependencies in the virtual environment
RUN /opt/GBMPurity/bin/pip install -r /opt/GBMPurity/requirements.txt

COPY GBMDeconvoluteR/data/ /srv/shiny-server/data/
COPY GBMDeconvoluteR/R/ /srv/shiny-server/R/
COPY GBMDeconvoluteR/Python/ /srv/shiny-server/Python/
COPY GBMDeconvoluteR/tabs/ /srv/shiny-server/tabs/
COPY GBMDeconvoluteR/www/ /srv/shiny-server/www/
COPY GBMDeconvoluteR/tools/ /srv/shiny-server/tools

COPY GBMDeconvoluteR/global.R /srv/shiny-server/
COPY GBMDeconvoluteR/ui.R /srv/shiny-server/
COPY GBMDeconvoluteR/server.R /srv/shiny-server/

USER shiny
EXPOSE 3838