FROM ubuntu

ENV VIRTUAL_ENV /srv/.venv
ENV PROJECT_DIR /srv/project
ENV PATH $VIRTUAL_ENV/bin:$PATH

# Install Python.
RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-venv

# Create run-as user and group.
RUN groupadd -g 1000 runas \
    && useradd -m -g 1000 -u 1000 runas

# Create folder as runas.
RUN mkdir $VIRTUAL_ENV \
    && mkdir $PROJECT_DIR \
    && chown -R 1000:1000 $VIRTUAL_ENV \
    && chown -R 1000:1000 $PROJECT_DIR

# Switch to user so project and venv files can be modified by user.
USER 1000:1000

# Install JupyterLab, and dependencies.
COPY requirements.txt .
RUN python3 -m venv $VIRTUAL_ENV \
    && pip install wheel \
    && pip install -r requirements.txt \
    && nodeenv -p \
    && jupyter labextension install @jupyter-widgets/jupyterlab-manager \
    && jupyter labextension enable @jupyter-widgets/jupyterlab-manager
    
# File cleanup.
USER root:root
RUN rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && apt-get autoremove
USER 1000:1000

ENTRYPOINT ["jupyter", "lab", "--ip=0.0.0.0", "--allow-root", "--no-browser"]
WORKDIR $PROJECT_DIR
VOLUME $PROJECT_DIR
EXPOSE 8888
