FROM continuumio/miniconda3

WORKDIR /app
ENV WORKDIR=$WORKDIR
RUN conda install python=3.8
RUN conda update pip -y \
    && conda install pytorch -c pytorch \
    && conda install cudatoolkit -c anaconda


ENV LANG=en_US.UTF-8

RUN apt update && \
    apt install -y rsync build-essential

ADD requirements.txt /
RUN pip3 install -r /requirements.txt 
ADD . /app

# RUN chmod -R 777 .

