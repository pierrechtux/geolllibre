#!/bin/bash
#   Title:   "Creation of postgeol database: postgresql database for geological data"
#   Name:    postgeol_database_creation.sh
#            (used to be: bdexplo_creation.r  => when it was a mining exploration database)
#   Version: 0.0.2
#   Date:    22-Aug-2018/22:29:08+2:00
#   Author:  "Pierre Chevalier"
#   License: {
echo "    Now running script $0"
echo "{{{"
echo "      This file is part of GeolLLibre software suite: FLOSS dedicated to Earth Sciences."
echo "      ###########################################################################"
echo "      ##          ____  ___/_ ____  __   __   __   _()____   ____  _____       ##"
echo "      ##         / ___\/ ___// _  |/ /  / /  / /  /  _/ _ \ / __ \/ ___/       ##"
echo "      ##        / /___/ /_  / / | / /  / /  / /   / // /_/_/ /_/ / /_          ##"
echo "      ##       / /_/ / /___|  \/ / /__/ /__/ /___/ // /_/ / _, _/ /___         ##"
echo "      ##       \____/_____/ \___/_____/___/_____/__/_____/_/ |_/_____/         ##"
echo "      ##                                                                       ##"
echo "      ###########################################################################"
echo "        Copyright (C) 2019 Pierre Chevalier <pierrechevaliergeol@free.fr>"
echo ""
echo "          GeolLLibre is free software: you can redistribute it and/or modify"
echo "          it under the terms of the GNU General Public License as published by"
echo "          the Free Software Foundation, either version 3 of the License, or"
echo "          (at your option) any later version."
echo "      "
echo "          This program is distributed in the hope that it will be useful,"
echo "          but WITHOUT ANY WARRANTY; without even the implied warranty of"
echo "          MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the"
echo "          GNU General Public License for more details."
echo "      "
echo "          You should have received a copy of the GNU General Public License"
echo "          along with this program.  If not, see <http://www.gnu.org/licenses/>"
echo "          or write to the Free Software Foundation, Inc., 51 Franklin Street,"
echo "          Fifth Floor, Boston, MA 02110-1301, USA."
echo "          See LICENSE file."
#      }
#]

echo
echo "   _________                      "
echo "  < BDexplo >               <= the ancester of postgeol, ca. 1992 to 2018"
echo "   ---------                      "
echo "          \   ^__^                "
echo "           \  (xx)\_______        "
echo "              (__)\       )\/\    "
echo "               U  ||----w |       "
echo "                  ||     ||       "
echo
echo "   __________                     "
echo " < PostGeol >                  <= the descendant of bdexplo, since 2016"
echo "   ----------"
echo "          \    __                 "
echo "           \ /(  )\_---------_    "
echo "            { (°°) }          )\  "
echo "            { /()\ }          | \ "
echo "             / () \  |____\   |   "
echo "            /  !! |\ |     |  |\  "
echo "               J  [__|     [__||  "  # TODO: hack cowsay source, and add a pachydermic option"
echo
echo "           ____________________________________"
echo "         oO                                    Oo"
echo "         °                                        \ "
echo "        {     PostGeol: PostgreSQL for Geology     }"
echo "         \                                        °"
echo "          °o____________________________________o°"

# General variables:
# TODO => les mettre dans ce script, plutôt que dans les .sql ; demander, au besoin, les valeurs interactivement.
# nom de la base à créer, hôte, port
# les rôles, sont-ils existants ou à créer, qui fait quoi (cf. autre script plus avant, de gestion des rôles).

#clear ################### <= ENLEVER APRES MISE AU POINT SCRIPT ######## TODO
echo
echo
echo
echo "Generation of a new empty database with PostGIS extension, with the PostgreSQL structure."
echo
#echo "Make a new empty database."
#echo "Also, create a schema with the current user's name, who becomes the creator and owner of the database."
echo
echo "}}}" #

echo "- 1. SERVER DEFINITION:                                                      {{{"
echo "- 1.1 HOST:                                                               {{{"
echo -e "Default postgresql database server is named after environment variable \$GLL_BD_HOST, which is now:\n  $GLL_BD_HOST"
echo "Press <Enter> to confirm, or type a valid postgresql server hostname and then <Enter>:"
read tmp
[[ ! -z "$tmp" ]] && GLL_BD_HOST=$tmp
echo "  Hostname: $GLL_BD_HOST"
echo
echo -e "If $GLL_BD_HOST is a GeoPoppy server, then the 'docker' role is used, instead of 'postgres'; is this a GeoPoppy server (default = yes)?"
POSTGRES=docker
echo "Press <Enter> to confirm, or anything else if $GLL_BD_HOST is *not* a GeoPoppy server, and then <Enter>:"
read tmp
# TODO gérer les autres réponses possibles: yes, y, n, no, si, oui, Y, etc.
[[ ! -z "$tmp" ]] && POSTGRES=postgres
echo "  Postgres superuser: $POSTGRES"
echo
echo "                                                                          }}}"
echo "- 1.2 PORT:                                                               {{{"
echo -e "Default port (traditionnally 5432) of the postgresql database is named after environment variable \$GLL_BD_PORT, which is now:\n  $GLL_BD_PORT"
echo "Press <Enter> to confirm, or type a valid port number used by postgresql on $GLL_BD_HOST server:"
read tmp
[[ ! -z "$tmp" ]] && GLL_BD_PORT=$tmp
echo "  Port: $GLL_BD_PORT"
echo
echo "                                                                          }}}"
echo "- 1.3 DATABASE NAME:                                                      {{{"
echo -e "The default database to be created is named after environment variable \$POSTGEOL, which is now:\n  $POSTGEOL"
#echo "Enter to validate this database name for the new database to be created; otherwise, enter a valid database name (no dashes, preferrably lowercase, underscores, etc.) to be created with postgeol structure:"
echo "Press <Enter> to confirm, or type a valid database name (no dashes, preferrably lowercase, underscores, etc.) to be created with postgeol structure on postgresql $GLL_BD_HOST server:"
read tmp
[[ ! -z "$tmp" ]] && POSTGEOL=$tmp
echo "  Database: $POSTGEOL"
echo
echo "                                                                          }}}"
echo "- 1.4 SUPERUSER NAME:                                                     {{{"
echo -e "The default database user name (\"role\", in PostgreSQL terminology) is named after environment variable \$GLL_BD_USER (which is usually by default the other environment variable \$USER), which is now:\n  $GLL_BD_USER"
#echo "Enter to validate this database name for the new database to be created; otherwise, enter a valid database name (no dashes, preferrably lowercase, underscores, etc.) to be created with postgeol structure:"
echo "Press <Enter> to confirm, or type a valid database role name (it should already exist in the database; TODO will implement later role creation; no hurry) to be used as the owner of the $POSTGEOL database to be created:"
read tmp
[[ ! -z "$tmp" ]] && GLL_BD_USER=$tmp
echo "  Username: $GLL_BD_USER"
echo
echo "                                                                          }}}"

######## On rappelle la connexion:
echo "- 1. SUMMARY:"
CONNINFO="-h $GLL_BD_HOST -p $GLL_BD_PORT -U $GLL_BD_USER $POSTGEOL"
echo -e "Summary: on postgresql server *$GLL_BD_HOST* listening on port *$GLL_BD_PORT*, the database *$POSTGEOL* is about to be created, with owner role *$GLL_BD_USER*.\nThis can be summarised as the options below:\n  $CONNINFO\nPress enter to confirm, Ctrl-C to cancel."
read tmp
echo "                                                                             }}}"
echo "- 2. DATABASE CREATION:                                                      {{{"
echo "- 2.1. DESTRUCTION (...):                                                 {{{"
echo "Before creating $POSTGEOL database, drop database $POSTGEOL, if it already exists (TODO to be implemented):"
echo "Enter to continue, Ctrl-C to cancel:"
read
#dropdb -h $GLL_BD_HOST -p $GLL_BD_PORT -U $GLL_BD_USER $POSTGEOL
echo "... deleting..."
dropdb $CONNINFO
echo "                                                                          }}}"
echo "- 2.2. CREATION:                                                          {{{"
echo "Database creation:"
#createdb $POSTGEOL --o $GLL_BD_USER -h $GLL_BD_HOST -p $GLL_BD_PORT
#createdb -h $GLL_BD_HOST -p $GLL_BD_PORT -U $GLL_BD_USER -O $GLL_BD_USER $POSTGEOL
createdb $CONNINFO -O $GLL_BD_USER
echo "Enter to continue, Ctrl-C to cancel:"
read
echo "                                                                          }}}"
echo "                                                                             }}}"
echo "- 3. IMPLEMENT EXTENSIONS AND LANGUAGES:                                     {{{"
psql $CONNINFO -U $POSTGRES -c "
 CREATE EXTENSION postgis;
 CREATE EXTENSION postgis_topology;
 GRANT ALL ON geometry_columns to $GLL_BD_USER;
 GRANT SELECT ON spatial_ref_sys to $GLL_BD_USER;
 CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
 CREATE SCHEMA $GLL_BD_USER;
 ALTER SCHEMA $GLL_BD_USER OWNER TO $GLL_BD_USER;
 GRANT ALL ON SCHEMA $GLL_BD_USER TO $GLL_BD_USER;"

## -- TODO removed also functions which called python scripts; put back, when issues of having plpythonu on geopopy will be solved
## => test on $POSTGRES='docker' => far to be ideal: TODO detect platform architecture to asses if plpythonu can be implemented
#if [ $POSTGRES='docker' ]; then
#	echo "This is apparently a GeoPoppy server: for the time being, plpythonu is not implemented within PostGeol on a Raspberry Pi platform."
#else
#	echo "This is not a GeoPoppy server, so we suppose that plpythonu can be implemented on the current platform."
#	psql $CONNINFO -U $POSTGRES -c "CREATE LANGUAGE plpythonu;"
#fi
# => DOESN'T WORK AS EXPECTED: TODO TO BE FIXED


echo "Enter to continue, Ctrl-C to cancel:"
read
echo "                                                                             }}}"
echo "- 4. SETUP POSTGEOL STRUCTURE:                                               {{{"
echo "Creation of postgeol structure in database named: " $POSTGEOL
echo "- 4.1. SCHEMAS AND TABLES:                                                {{{"
#echo " 1) schemas and tables:"
psql $CONNINFO -X --single-transaction             -f ./postgeol_structure_01_tables.sql    |& grep -v "^SET$\|^COMMENT$" |& grep -v "^CREATE TABLE$" |& grep -v "CREATE SCHEMA" |& grep -v "^psql:.* ERROR:  current transaction is aborted, commands ignored until end of transaction block$" # Note: all psql calls used to be the --single-transaction option, but it proved to make it very difficult to debug; so, instead, all .sql files have BEGIN TRANSACTION; and COMMIT; statements. => no... it proved to be easier to just grep -v ...
echo "                                                                          }}}"
echo "- 4.2. FUNCTIONS:                                                            {{{"
#echo " 2) functions
echo "Note: this part has to be run as postgresql superuser: $POSTGRES:"
psql $CONNINFO -X --single-transaction -U $POSTGRES -f ./postgeol_structure_02_functions.sql |& grep -v "^SET$\|^COMMENT$" |& grep -v "^CREATE FUNCTION$"
echo "                                                                          }}}"
echo "- 4.3. VIEWS:                                                                {{{"
#echo " 3) views:"
# create the queries set:
psql $CONNINFO -X --single-transaction             -f ./postgeol_structure_03_views.sql     |& grep -v "^SET$\|^COMMENT$" |& grep -v "^CREATE VIEW$" |& grep -v "^CREATE RULE$"
#~/geolllibre/gll_bdexplo_views_create.r 
./postgeol_structure_03_1_views_opid_create # TODO paramétrer le nom de la base => auquai => NON, PAS SI AUQUAI: À FAIRE PLUS TARD, POSÉMENT, EN REPRENANT BIEN LES VARIABLES D'ENVIRONNEMENT
echo "                                                                          }}}"

echo "                                                                             }}}"
echo "- 5. TRANSFER DATA FROM ANOTHER BASE:                                        {{{"

# à la fin, pour transférer les données de bdexplo vers postgeol:
echo "In order to transfer data from another database (i.e. bdexplo, postgeol ancestor), edit and run manually:
./postgeol_transfer_data_from_bdexplo
echo "                                                                             }}}"
echo "End."
#echo "FIN PROVISOIRE" && exit 0 ######## DEBUG #### _______________ENCOURS_______________GEOLLLIBRE
#exit 0 ###### si jamais...


