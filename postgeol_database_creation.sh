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

# Make a new empty database, with the postgis extension.
# Also, create a schema with the current user's name.
newdb="postgeol"
dropdb $newdb
createdb $newdb --o $LOGNAME
psql -U postgres -d $newdb --single-transaction -c "CREATE EXTENSION postgis;  CREATE EXTENSION postgis_topology;  GRANT ALL ON geometry_columns to $LOGNAME;  GRANT SELECT ON spatial_ref_sys to $LOGNAME;  CREATE LANGUAGE plpythonu;  CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;  COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';  CREATE SCHEMA $LOGNAME; GRANT ALL ON SCHEMA $LOGNAME TO $LOGNAME;"

newdb="postgeol" #VIRER CETTE LIGNE APRÈS TESTS
# create the database structure:
echo "Creation of postgeol structure in database named: " $newdb
psql -d $newdb -f ~/geolllibre/postgeol_structure.sql | grep -v "SET\|COMMENT"

# create the queries set:
~/geolllibre/gll_bdexplo_views_create.r # TODO paramétrer le nom de la base

