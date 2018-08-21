#!/bin/bash
#!/usr/bin/rebol -cs
#rebol [ ;{{{ } } }
#	Title:   "Creation of postgeol database: postgresql database for geological data"
#	Name:    postgeol_database_creation.sh
#            (used to be: bdexplo_creation.r  => when it was a mining exploration database)
#	Version: 0.0.1
#	Date:    14-Apr-2016/14:42:35+2:00
#	Author:  "Pierre Chevalier"
#	License: {
#		This file is part of GeolLLibre software suite: FLOSS dedicated to Earth Sciences.
#		###########################################################################
#		##          ____  ___/_ ____  __   __   __   _()____   ____  _____       ##
#		##         / ___\/ ___// _  |/ /  / /  / /  /  _/ _ \ / __ \/ ___/       ##
#		##        / /___/ /_  / / | / /  / /  / /   / // /_/_/ /_/ / /_          ##
#		##       / /_/ / /___|  \/ / /__/ /__/ /___/ // /_/ / _, _/ /___         ##
#		##       \____/_____/ \___/_____/___/_____/__/_____/_/ |_/_____/         ##
#		##                                                                       ##
#		###########################################################################
#		  Copyright (C) 2018 Pierre Chevalier <pierrechevaliergeol@free.fr>
#		 
#		    GeolLLibre is free software: you can redistribute it and/or modify
#		    it under the terms of the GNU General Public License as published by
#		    the Free Software Foundation, either version 3 of the License, or
#		    (at your option) any later version.
#		
#		    This program is distributed in the hope that it will be useful,
#		    but WITHOUT ANY WARRANTY; without even the implied warranty of
#		    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#		    GNU General Public License for more details.
#		
#		    You should have received a copy of the GNU General Public License
#		    along with this program.  If not, see <http://www.gnu.org/licenses/>
#		    or write to the Free Software Foundation, Inc., 51 Franklin Street, 
#		    Fifth Floor, Boston, MA 02110-1301, USA.
#		    See LICENSE file.
#		}
#]
#;}}}

echo "Make a new empty database, with postgis extension."
echo "Also, create a schema with the current user's name."

echo "The database to be created comes from environment variable \$POSTGEOL, which is now '$POSTGEOL'."
newdb=$POSTGEOL
# TODO treat case when environment variable is not defined; maybe offer a choice to the user, for another database name.

echo "Drop database $POSTGEOL, if it already exists:"
# TODO prompt for a confirmation
dropdb $newdb

echo "Database creation:"
createdb $newdb --o $LOGNAME

echo "Implement extensions and languages:"
psql -X -U postgres -d $newdb --single-transaction -c "
 CREATE EXTENSION postgis;  
 CREATE EXTENSION postgis_topology;
 GRANT ALL ON geometry_columns to $LOGNAME;
 GRANT SELECT ON spatial_ref_sys to $LOGNAME;
 CREATE LANGUAGE plpythonu;
 CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
 CREATE SCHEMA $LOGNAME; 
 GRANT ALL ON SCHEMA $LOGNAME TO $LOGNAME;"

echo "Create the database structure:"
echo "Creation of postgeol structure in database named: " $newdb
psql -d $newdb -f ~/geolllibre/postgeol_structure_01_tables.sql | grep -v "SET\|COMMENT"

echo "Create functions (to be run as superuser):"
psql -d $newdb -U postgres -f ~/geolllibre/postgeol_structure_02_functions.sql

exit 0 #################################### DEBUG ####

# create the queries set:


~/geolllibre/gll_bdexplo_views_create.r # TODO paramétrer le nom de la base

