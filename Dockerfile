FROM continuumio/miniconda3:4.8.2
LABEL description="Base docker image with conda and util libraries"
ARG ENV_NAME="proteogenomics-base"

# Install mamba for faster installation in the subsequent step
RUN conda install -c conda-forge mamba r-base -y

# Install procps so that Nextflow can poll CPU usage and
# deep clean the apt cache to reduce image/layer size
RUN apt-get update \
 && apt-get install -y procps \
 && apt-get clean -y && rm -rf /var/lib/apt/lists/*
 
# Install the conda environment
COPY environment.yml /
RUN mamba env create --quiet --name ${ENV_NAME} --file /environment.yml && conda clean -a

# Add conda installation dir to PATH (instead of doing 'conda activate')
ENV PATH /opt/conda/envs/${ENV_NAME}/bin:$PATH

# Dump the details of the installed packages to a file for posterity
RUN mamba env export --name ${ENV_NAME} > ${ENV_NAME}_exported.yml

# Copy additional scripts from bin and add to PATH
RUN mkdir /opt/bin
COPY modules/*/src/*.py /opt/bin/
RUN chmod +x /opt/bin/*
ENV PATH="$PATH:/opt/bin/"
