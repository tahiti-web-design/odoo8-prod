FROM tahitiwebdesign/odoo8-base
LABEL maintainer="dev@tahitiwebdesign.com"

COPY ./entrypoint.sh /

# Create odoo user
RUN mkhomedir_helper odoo
USER odoo
WORKDIR /home/odoo

# Install poetry
ENV POETRY_VERSION=1.1.5
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python - && \
	source $HOME/.poetry/env && \
	poetry config virtualenvs.create false

# Startup
ENTRYPOINT ["/entrypoint.sh"]
