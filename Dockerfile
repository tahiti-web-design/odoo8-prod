FROM tahitiwebdesign/centos7-without-systemd
LABEL maintainer="dev@tahitiwebdesign.com"

ENV ODOO_RPM_URL https://nightly.odoo.com/8.0/nightly/rpm/odoo_8.0.20171001.noarch.rpm
ENV ODOO_CFG /etc/odoo/openerp-server.conf
ENV WKHTMLTOX_URL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.1/wkhtmltox-0.12.1_linux-centos7-amd64.rpm

# Installation de la locale FR
RUN localedef -i fr_FR -f UTF-8 fr_FR.UTF-8;

# Installation des dependances centos et odoo
RUN yum -y swap -- remove fakesystemd -- install systemd systemd-libs && \
	yum clean all && yum -y update --disableplugin=fastestmirror && \
        yum -y install --disableplugin=fastestmirror epel-release && \
	yum -y update --disableplugin=fastestmirror && \
        yum -y install --disableplugin=fastestmirror \
        python-pip python-gevent tree less vim \
	python-devel git libjpeg-devel libtiff-devel gcc \
	libxslt-devel libxml2-devel graphviz openldap-devel postgresql;

COPY ./entrypoint.sh /

# Installation de xlwt pour python et les rapport excel
# trello est utilisé par TWD_task
RUN pip install xlwt trello pyparsing==2.1.4

# Pour fix le probleme d'install de package urllib3
# https://bugzilla.redhat.com/show_bug.cgi?id=1738348
RUN rm -rf /usr/lib/python2.7/site-packages/urllib3*


# Installation de odoo
# et creation du repertoire des addons metier
RUN curl -o odoo.rpm $ODOO_RPM_URL && yum -y install odoo.rpm && \
	mkdir -p /mnt/extra-addons && chown -R odoo:odoo /mnt/extra-addons && \
        mkdir -p /var/log/odoo && chown -R odoo:odoo /var/log/odoo;

# Installation de wkhtmltox 0.12.1
RUN curl -Lo wkhtmltox.rpm $WKHTMLTOX_URL && \
	yum -y localinstall wkhtmltox.rpm && \
	ln -s /usr/local/bin/wkhtmltopdf /usr/bin/wkhtmltopdf;

EXPOSE 8069 8071

VOLUME ["/etc/odoo", "/var/lib/odoo", "/var/log/odoo/", "/mnt/extra-addons"]

HEALTHCHECK --interval=1m --timeout=30s \
CMD curl -f http://localhost:8069 || exit 1

USER odoo

ENTRYPOINT ["/entrypoint.sh"]

CMD ["openerp-server", "-c", "/etc/odoo/openerp-server.conf"]
