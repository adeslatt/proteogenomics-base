# Full contents of Dockerfile
FROM continuumio/miniconda3
LABEL description="Base docker image with conda and util libraries"

# Install mamba for faster installation in the subsequent step
# Install r-base for being able to run the install.R script
RUN conda install -c conda-forge mamba -y

# Install the conda environment
COPY environment.yml /
RUN mamba env create --quiet --name ${ENV_NAME} --file /environment.yml && conda clean -a

# Add conda installation dir to PATH (instead of doing 'conda activate')
ENV PATH /opt/conda/envs/${ENV_NAME}/bin:$PATH

# Dump the details of the installed packages to a file for posterity
RUN mamba env export --name ${ENV_NAME} > ${ENV_NAME}_exported.yml

# Copy additional scripts from bin and add to PATH
RUN mkdir /opt/bin
COPY src/* /opt/bin/
RUN chmod +x /opt/bin/*
ENV PATH="$PATH:/opt/bin/"
