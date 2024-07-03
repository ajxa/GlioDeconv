# Install R version 3.5
FROM rocker/shiny:latest

# Install Ubuntu packages
RUN apt-get update && apt-get --no-install-recommends install -y \
    libssl-dev \
    libxml2-dev \
    wget \
    bzip2 \
    ca-certificates

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean

# Install miniconda
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p $CONDA_DIR && \
    rm ~/miniconda.sh

# Put conda in path so we can use conda activate
ENV PATH=$CONDA_DIR/bin:$PATH

# Copy environment.yml file
COPY environment.yml .

# Create conda environment
RUN conda env create -f environment.yml

# Set the RETICULATE_PYTHON env var
ENV RETICULATE_PYTHON $CONDA_DIR/envs/GBMPurity/bin/python

# Copy configuration files into the Docker image
COPY ./renv.lock ./renv.lock

# install renv & restore packages
RUN Rscript -e 'install.packages("renv")'
RUN Rscript -e 'renv::restore()'

COPY . /srv/shiny-server

USER shiny

EXPOSE 3838
