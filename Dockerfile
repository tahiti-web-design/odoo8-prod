FROM tahitiwebdesign/odoo8-base:release-1.2.0
LABEL maintainer="dev@tahitiwebdesign.com"

# Install poetry
ENV POETRY_VERSION=1.1.9
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python - && \
    echo ". $HOME/.poetry/env" >> $HOME/.bashrc
RUN	source $HOME/.poetry/env && \
	poetry config virtualenvs.create true && \
    poetry config virtualenvs.in-project true

# Startup
COPY ./entrypoint.sh /

RUN mkdir -p /mnt/extra-addons && \
    mkdir -p /mnt/project-addons 
COPY ./config/openerp-server.conf /etc/odoo

USER odoo
ENTRYPOINT ["/entrypoint.sh"]
CMD ["openerp-server"]
