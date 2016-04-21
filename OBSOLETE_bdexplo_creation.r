#!/usr/bin/rebol -cs
rebol [ ;{{{ } } }
	Title:   "Creation of bdexplo database: postgresql database for exploration data"
	Name:    bdexplo_creation.r
	Version: 1.0.0
	Date:    
	Author:  "Pierre Chevalier"
	License: {
		This file is part of GeolLLibre software suite: FLOSS dedicated to Earth Sciences.
		###########################################################################
		##          ____  ___/_ ____  __   __   __   _()____   ____  _____       ##
		##         / ___\/ ___// _  |/ /  / /  / /  /  _/ _ \ / __ \/ ___/       ##
		##        / /___/ /_  / / | / /  / /  / /   / // /_/_/ /_/ / /_          ##
		##       / /_/ / /___|  \/ / /__/ /__/ /___/ // /_/ / _, _/ /___         ##
		##       \____/_____/ \___/_____/___/_____/__/_____/_/ |_/_____/         ##
		##                                                                       ##
		###########################################################################
		  Copyright (C) 2013 Pierre Chevalier <pierrechevaliergeol@free.fr>
		 
		    GeolLLibre is free software: you can redistribute it and/or modify
		    it under the terms of the GNU General Public License as published by
		    the Free Software Foundation, either version 3 of the License, or
		    (at your option) any later version.
		
		    This program is distributed in the hope that it will be useful,
		    but WITHOUT ANY WARRANTY; without even the implied warranty of
		    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		    GNU General Public License for more details.
		
		    You should have received a copy of the GNU General Public License
		    along with this program.  If not, see <http://www.gnu.org/licenses/>
		    or write to the Free Software Foundation, Inc., 51 Franklin Street, 
		    Fifth Floor, Boston, MA 02110-1301, USA.
		    See LICENSE file.
		}
]
;}}}

print "no, no: you MUST read, and copy-paste to a terminal, a bash, a psql, logged in as postgres or normal user, accordingly..."

old_code: [
;#!/bin/PASbash
;echo "non, non: faut lire, et faire en copiant-collant, selon, sur un terminal, un bash, un psql, en postgres ou utilisateur normal, selon..."
;exit 0
;

quit


# make a new empty database, with postgis
newdb="emptybdexplo"

# su postgres {{{
bd=$newdb

dropdb $bd
createdb $bd --o $LOGNAME

echo "CREATE EXTENSION postgis;"                    | psql -d $bd
echo "CREATE EXTENSION postgis_topology;"           | psql -d $bd

echo "grant all on geometry_columns to $LOGNAME;"   | psql -d $bd
echo "grant select on spatial_ref_sys to $LOGNAME;" | psql -d $bd
echo "CREATE LANGUAGE plpythonu;"                   | psql -d $bd


psql -d $bd
--#generate_cross_sections_array: {{{
--# --Définissons la fonction, en superutilisateur (postgres): 


DROP FUNCTION IF EXISTS generate_cross_sections_array();
CREATE OR REPLACE FUNCTION generate_cross_sections_array() RETURNS trigger AS $$
#{{{
#{{{
# Cette fonction est appelée depuis un TRIGGER de la 
# table sections_definition, sans arguments, et elle 
# renvoie un trigger.
# définition du TRIGGER:
#    CREATE TRIGGER sections_definition_change 
#    AFTER INSERT OR UPDATE ON sections_definition 
#    FOR EACH ROW 
#    EXECUTE PROCEDURE generate_cross_sections_array();
#
# @#faire le pendant, qui détruise les enregistrements de sections_array quand on supprime un enregistrement de sections_definition
#}}}
from math import sin, cos, pi
import string

sep       = "," #"\t"      #définition du séparateur: la virgule 
sepchar   = "\'"           #définition du séparateur de chaîne de caractères: le ', en SQL

#Cherchons les paramètres définissant les coupes, dans la table sections_definition:
res = plpy.execute("SELECT opid, id, location, srid, ll_corner_x, ll_corner_y, ll_corner_z, azim_ng, interval, num_start, count, length, title FROM sections_definition /*WHERE opid IN (SELECT opid FROM operation_active)*/;")

sql_insert = ""               #on bâtit une chaîne sql_insert qui contiendra tout ce qu'il faudra faire, des insertions essentiellement

#on enlève d'abord les coupes existantes dans la table sections_array{{{
sql_insert += "DELETE FROM sections_array WHERE sections_array.opid IN (SELECT opid FROM operation_active) AND sections_array.id IS NOT NULL; "
#non: plutôt, on enlève seulement les coupes existantes pour le même id que celui qui vient d'être affecté:
#sql_insert +="DELETE FROM sections_array WHERE substr(sections_array.title, 1, " + str(NEW["title"].len) + ") = " + sepchar + NEW["title"] + sepchar + ";"
# => marche pas:
#  ERREUR:  PL/python : NameError: global name 'NEW' is not defined
#  CONTEXTE : fonction PL/python Â« generate_cross_sections_array Â»
# =>@#reprendre
#}}}

i = 0
for line in res:
    #le résultat est fourni sous forme de tuples de dictionnaires:
    opid              = line["opid"]
    id                = line["id"]
    srid              = line["srid"]
    location          = line["location"]
    ll_corner_x       = line["ll_corner_x"]
    ll_corner_y       = line["ll_corner_y"]
    ll_corner_z       = line["ll_corner_z"]
    azim_ng           = line["azim_ng"]
    interval_         = line["interval"]
    num_start         = line["num_start"]
    count             = line["count"]
    length            = line["length"]
    title             = line["title"]
    #num   = 1                                   #pas besoin, on a mis un autoincrément dans la table 
    indice_coupe = num_start                     #l'indice de la coupe 
    sql_insert += "INSERT INTO sections_array (opid, location, id, title, srid, length, x1, y1, z1, x2, y2, z2) VALUES \n"
    for j in range(count):
        #out =  str(opid) + sep + sepchar + location + sepchar + sep + sepchar + location+'_'+str(indice_coupe).zfill(3) + sepchar + sep + sepchar + title + " - section # "+str(indice_coupe)                       + sepchar + sep + str(srid) + sep
        out  =  str(opid) + sep + sepchar + location + sepchar + sep + sepchar + location+'_'+str(indice_coupe).zfill(3) + sepchar + sep + sepchar + title + " - section " + location+'_'+str(indice_coupe).zfill(3) + sepchar + sep + str(srid) + sep
        x2 = ll_corner_x+interval_*(j) * cos((90.0-azim_ng)/180*pi)
        y2 = ll_corner_y+interval_*(j) * sin((90.0-azim_ng)/180*pi)
        x1 = x2 - length * sin((90.0-azim_ng)/180*pi)
        y1 = y2 + length * cos((90.0-azim_ng)/180*pi)
        z  = ll_corner_z
        out += str(length) + sep + str(x1) + sep + str(y1) + sep + str(z) + sep + str(x2) + sep + str(y2) + sep + str(z)
        sql_insert += "("+out+"),\n"
        indice_coupe += 1
    sql_insert = sql_insert[0:len(sql_insert)-2]  #pour enlever le dernier ",\n"
    sql_insert += ";\n"
    i += 1

# au lieu de retourner la chaine (comme dans le script python indépendant), executons directement le SQL:
res = plpy.execute(sql_insert)
return 'OK'
#}}}
$$LANGUAGE plpythonu;

--}}}


# }}}
# su normal user{{{
bd=$newdb
#echo "CREATE SCHEMA amc   ;" | psql -d $bd
#echo "CREATE SCHEMA bof   ;" | psql -d $bd
#echo "CREATE SCHEMA smi;" | psql -d $bd
#echo "CREATE SCHEMA tmp_a_traiter;" | psql -d $bd
echo "CREATE SCHEMA tmp_imports;" | psql -d $bd
echo "CREATE SCHEMA $LOGNAME   ;" | psql -d $bd

psql -d $bd

--#lab_ana_results_sample_id_default_value_num:{{{

CREATE OR REPLACE FUNCTION public.lab_ana_results_sample_id_default_value_num()
 RETURNS trigger AS
$BODY$
BEGIN
--UPDATE public.lab_ana_results SET sample_id = lab_sampleid WHERE (sample_id IS NULL OR sample_id = '') AND (lab_sampleid IS NOT NULL OR lab_sampleid <> '');
UPDATE public.lab_ana_results SET sample_id_lab = sample_id;
UPDATE public.lab_ana_results SET sample_id = REPLACE(sample_id, 'STD:', '') WHERE sample_id ILIKE 'STD%';

UPDATE public.lab_ana_results SET value_num = 
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(
REPLACE(value,     'IS',           '-999'), 
                  'NSS',           '-999'), 
                  'LNR',          '-9999'), 
                   'NA',            '-99'), 
                    '<',              '-'),
                    '>',               ''),
                 'Not Received',  '-9999'),
                 'Bag Empty',     '-9999'),
                  'N/L',           '-9999')::numeric WHERE value <> 'NULL' AND value IS NOT NULL AND value_num IS NULL;
RETURN NULL;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE;



--#}}}

# }}}
]

