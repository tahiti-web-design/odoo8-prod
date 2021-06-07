FROM tahitiwebdesign/odoo8-base:release-1.1.0
LABEL maintainer="dev@tahitiwebdesign.com"

COPY ./entrypoint.sh /

# Install poetry
ENV POETRY_VERSION=1.1.5
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python - && \
    echo ". $HOME/.poetry/env" >> $HOME/.bashrc
RUN	source $HOME/.poetry/env && \
	poetry config virtualenvs.create false

# Startup
USER odoo
ENTRYPOINT ["/entrypoint.sh"]
