FROM tahitiwebdesign/centos7-without-systemd
LABEL maintainer="paraita@tahitiwebdesign.com"

ENV ODOO_RPM_URL http://cdn.tahiti-web-management.com/odoo_8.0.20171001.noarch.rpm
ENV ODOO_CFG /etc/odoo/openerp-server.conf

# Installation de la locale FR
RUN localedef -i fr_FR -f UTF-8 fr_FR.UTF-8;

# Installation des dependances centos et odoo
RUN yum -y swap -- remove fakesystemd -- install systemd systemd-libs && \
	yum clean all && yum -y update && yum -y install epel-release && \
	yum -y update && yum -y install python-gevent tree less vim \
	python-pip python-devel git libjpeg-devel libtiff-devel gcc \
	libxslt-devel libxml2-devel graphviz openldap-devel;

COPY ./entrypoint.sh /

# Installation de odoo
# et creation du repertoire des addons metier
RUN curl -o odoo.rpm $ODOO_RPM_URL && yum -y install odoo.rpm && \
	mkdir -p /mnt/extra-addons && chown -R odoo:odoo /mnt/extra-addons && \
        mkdir -p /var/log/odoo && chown -R odoo:odoo /var/log/odoo;

EXPOSE 8089 8071

VOLUME ["/etc/odoo", "/var/lib/odoo", "/var/log/odoo/", "/mnt/extra-addons"]

HEALTHCHECK --interval=1m --timeout=30s \
CMD curl -f http://localhost:8069 || exit 1

USER odoo

ENTRYPOINT ["/entrypoint.sh"]

CMD ["openerp-server", "-c", "/etc/odoo/openerp-server.conf"]
