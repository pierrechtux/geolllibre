#!/bin/bash
echo "Détermination des passes minéralisées pour la base $GLL_BD_NAME sur l'hôte $GLL_BD_HOST"
python ~/bin/procedure_genere_passmin.py | psql -X -h $GLL_BD_HOST -d $GLL_BD_NAME

