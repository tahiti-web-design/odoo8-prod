# Odoo8-prod

Environnement Odoo 8 à base de [Centos 7](https://hub.docker.com/r/tahitiwebdesign/centos7-without-systemd).

## Variables d'environnement

Les variables d'environnement suivantes sont nécessaires pour lancer correctement un container:

* `DB_HOST`: hôte de la base de données
* `DB_PORT`: port de la base de données
* `DB_NAME`: nom de la base de données
* `DB_USER`: utilisateur de la base de données
* `DB_PASSWORD`: mot de passe de la base de données

**@deprecated** (kept for backward compatibility)

* `DB_ADDR` pour l'adresse de l'hôte de la BDD

## Fichier de configuration

Cette image s'attend à trouver le fichier suivant:

```txt
/etc/odoo/openerp-server.conf
```

## Configuration par défaut

Par défaut, l'image va tenter de se connecter à la BDD suivante:

```txt
hôte de la BDD:         db
port de la BDD:         5432
nom de la BDD:          odoo
utilisateur de la BDD:  odoo
mot de passe de la BDD: odoo
```

## Volumes

Il est possible de monter les volumes suivants:

* `/etc/odoo` pour le fichier de config openerp-server.conf
* `/var/lib/odoo` pour le filestore Odoo
* `/var/log/odoo` pour le fichier de log odoo-server.log 
* `/mnt/extra-addons` pour les modules métier

## Exemple d'utilisation

```bash
docker run -d -p 80:8069 -p 8072:8072 -v /odoo/config:/etc/odoo \
           -v /odoo/log:/var/log/odoo -v /odoo/addons:/mnt/extra-addons \
           -e DB_HOST=localhost -e DB_PORT=5432 -e DB_NAME=odoo \
           -e DB_USER=odoo -e DB_PASSWORD=odoo tahitiwebdesign/odoo8-prod
```
