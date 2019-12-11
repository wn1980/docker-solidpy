FROM ubuntu:18.04

ARG PYTHON_VERSION=3.6
ARG MINICONDA_SH=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

RUN apt-get update && apt-get install -y --no-install-recommends \
         sudo \
         build-essential \
         cmake \
         git \
         curl \
         software-properties-common \
         ca-certificates && \
     rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:openscad/releases
RUN sudo apt-get update && apt-get install -y --no-install-recommends openscad

# install Miniconda3
RUN curl -o ~/miniconda.sh -O $MINICONDA_SH && \
     chmod +x ~/miniconda.sh && \
     ~/miniconda.sh -b -p /opt/conda && \
     rm ~/miniconda.sh 

# set environment path
ENV PATH /opt/conda/bin:$PATH

# install basic Python packages
RUN conda install -y python=$PYTHON_VERSION

# install jupyter lab
#RUN conda install -y -c conda-forge jupyterlab
#RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager
RUN conda install -c anaconda jupyter -y

RUN pip install solidpython viewscad
RUN pip install -U jupyter_console

# clean
RUN conda clean -ya
RUN apt -y autoremove

# working dir
#RUN mkdir -p /home/works && chmod 1777 /home/works

# Configure user
ARG user=jupyter
ARG passwd=jupyter
ARG uid=1000
ARG gid=1000
ENV USER=$user
ENV PASSWD=$passwd
ENV UID=$uid
ENV GID=$gid
RUN groupadd $USER && \
    useradd --create-home --no-log-init -g $USER $USER && \
    usermod -aG sudo $USER && \
    echo "$PASSWD:$PASSWD" | chpasswd && \
    chsh -s /bin/bash $USER && \
    # Replace 1000 with your user/group id
    usermod  --uid $UID $USER && \
    groupmod --gid $GID $USER

# jupyter port
EXPOSE 8888

# finally, start up JupyterLab
ENV HOME /home/$user

RUN chmod 1777 $HOME

COPY startup.sh /

COPY Examples.ipynb $HOME

RUN chmod a+x startup.sh

USER $USER

CMD ["/startup.sh"]
