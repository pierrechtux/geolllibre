-- e functions:{{{
-- _______________ENCOURS_______________GEOLLLIBRE vv 3 
-- x generate_cross_sections_array:{{{
-- TODO doit être fait en tant que postgres; voir à améliorer ça.
-- \c postgeol postgres

CREATE FUNCTION public.generate_cross_sections_array() RETURNS trigger
    LANGUAGE plpython
    AS $$
#{{{
#{{{
# This function is called from a TRIGGER of
# sections_definition table, without any argument;
# it returns a trigger.
# TRIGGER definition:
#    CREATE TRIGGER sections_definition_change
#    AFTER INSERT OR UPDATE ON sections_definition
#    FOR EACH ROW
#    EXECUTE PROCEDURE generate_cross_sections_array();
#
# TODO @#faire le pendant, qui détruise les enregistrements de sections_array quand on supprime un enregistrement de sections_definition
# TODO @#do the symetric, to DELETE records from sections_array when a sections_definition record is DELETEd.
#}}}
from math import sin, cos, pi
import string

sep       = "," #"\t"      # Separator definition: comma
sepchar   = "\'"           # Character string separator definition: ', in SQL

# Get parameters defining cross-sections, from the sections_definition table:
#res = plpy.execute("SELECT opid, id, location, srid, ll_corner_x, ll_corner_y, ll_corner_z, azim_ng, interval, num_start, count, length, title FROM sections_definition / *WHERE opid IN (SELECT opid FROM operation_active)* /;") # this line had a C-style comment in the SQL: inserted whitespace, to avoid nested SQL comments conflicts in postgeol_structure.sql script
res = plpy.execute("SELECT opid, id, location, srid, ll_corner_x, ll_corner_y, ll_corner_z, azim_ng, interval, num_start, count, length, title FROM sections_definition;")

sql_insert = ""               #We build a sql_insert string which will contain everything necessary, mostly INSERTs.

# First, DELETE existing cross-sections from sections_array table:{{{
sql_insert += "DELETE FROM sections_array WHERE sections_array.opid IN (SELECT opid FROM operation_active) AND sections_array.id IS NOT NULL; "
# No: rather, just remove existing cross-sections having the same id as the one which has just been affected:
#sql_insert +="DELETE FROM sections_array WHERE substr(sections_array.title, 1, " + str(NEW["title"].len) + ") = " + sepchar + NEW["title"] + sepchar + ";"
# => marche pas:
#  ERREUR:  PL/python : NameError: global name 'NEW' is not defined
#  CONTEXTE : fonction PL/ generate_cross_sections_array Python
# =>@# TODO reprendre
#}}}

i = 0
for line in res:
    # Result is given as dictionaries tuples:
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
    #num   = 1                                 # no need, there is an autoincrement in the table
    section_nr = num_start                     # cross-section number
    sql_insert += "INSERT INTO sections_array (opid, location, id, title, srid, length, x1, y1, z1, x2, y2, z2) VALUES \n"
    for j in range(count):
        #out =  str(opid) + sep + sepchar + location + sepchar + sep + sepchar + location+'_'+str(section_nr).zfill(3) + sepchar + sep + sepchar + title + " - section # "+str(section_nr)                       + sepchar + sep + str(srid) + sep
        out  =  str(opid) + sep + sepchar + location + sepchar + sep + sepchar + location+'_'+str(section_nr).zfill(3) + sepchar + sep + sepchar + title + " - section " + location+'_'+str(section_nr).zfill(3) + sepchar + sep + str(srid) + sep
        x2 = ll_corner_x+interval_*(j) * cos((90.0-azim_ng)/180*pi)
        y2 = ll_corner_y+interval_*(j) * sin((90.0-azim_ng)/180*pi)
        x1 = x2 - length * sin((90.0-azim_ng)/180*pi)
        y1 = y2 + length * cos((90.0-azim_ng)/180*pi)
        z  = ll_corner_z
        out += str(length) + sep + str(x1) + sep + str(y1) + sep + str(z) + sep + str(x2) + sep + str(y2) + sep + str(z)
        sql_insert += "("+out+"),\n"
        section_nr += 1
    sql_insert = sql_insert[0:len(sql_insert)-2]  #pour enlever le dernier ",\n"
    sql_insert += ";\n"
    i += 1

# Instead of returning the string (like in the standalone python script), let's execute directly the SQL:
res = plpy.execute(sql_insert)
return 'OK'
#}}}
$$;
--\c $USER
--}}}
-- o string_to_int:{{{ TODO tiens, curieux: elle n'est pas dans bdexplo: ???
DROP FUNCTION IF EXISTS string_to_int(text);
CREATE OR REPLACE FUNCTION string_to_int(t text) RETURNS bigint AS
$$
--Fournit un entier à partir d'une chaîne; intérêt pour éviter d'avoir des champs serial, pour les tables à carter avec postgis.
--Returns an integer from a string; avoids the requirement for serial fields, for tables to be mapped using postgis.
DECLARE
 int_out bigint = 0;
 ch char(1);
 tt text;
 ttt text = '';
 i integer = 0;
BEGIN
 WHILE i<length(t) LOOP
  ch:=substring(t from i+1 for 1);
  tt:=ascii(ch)::text;
  ttt:=ttt || tt;
  i:=i+1;
 END LOOP;
 int_out:=ttt::bigint;
 return int_out;
END;
$$
LANGUAGE 'plpgsql' VOLATILE RETURNS NULL ON NULL INPUT SECURITY INVOKER;
--}}}

--}}}

