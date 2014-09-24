--###############################################
--##      a suite of scripts to maintain       ##
--##       bdexplo bdgeol in postgresql        ##
--###############################################

--[ ;{{{ } } }
--	Title:   "Structured set of check queries on bdexplo database"
--	Author:  "Pierre Chevalier"
--	License: {
--		This file is part of GeolLLibre software suite: FLOSS dedicated to Earth Sciences.
--		###########################################################################
--		##          ____  ___/_ ____  __   __   __   _()____   ____  _____       ##
--		##         / ___\/ ___// _  |/ /  / /  / /  /  _/ _ \ / __ \/ ___/       ##
--		##        / /___/ /_  / / | / /  / /  / /   / // /_/_/ /_/ / /_          ##
--		##       / /_/ / /___|  \/ / /__/ /__/ /___/ // /_/ / _, _/ /___         ##
--		##       \____/_____/ \___/_____/___/_____/__/_____/_/ |_/_____/         ##
--		##                                                                       ##
--		###########################################################################
--		  Copyright (C) 2013 Pierre Chevalier <pierrechevaliergeol@free.fr>
--		 
--		    GeolLLibre is free software: you can redistribute it and/or modify
--		    it under the terms of the GNU General Public License as published by
--		    the Free Software Foundation, either version 3 of the License, or
--		    (at your option) any later version.
--		
--		    This program is distributed in the hope that it will be useful,
--		    but WITHOUT ANY WARRANTY; without even the implied warranty of
--		    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--		    GNU General Public License for more details.
--		
--		    You should have received a copy of the GNU General Public License
--		    along with this program.  If not, see <http://www.gnu.org/licenses/>
--		    or write to the Free Software Foundation, Inc., 51 Franklin Street, 
--		    Fifth Floor, Boston, MA 02110-1301, USA.
--		    See LICENSE file.
--		}
--] ;}}}


--------------------------------------------------------------------------------------------------------------------
-- usage:
-- For report generation, things are coded as follows:
-- any comment to be used is prefixed with # after --
-- --#BEGIN{{{ starting tag
-- --#{{{nHoles collars                                 Title of query, on one line only.
--                                                      indentation level is n (after -- and   
--                                                      curly braces, makes the hierarchy of
--                                                      the report.
--
-- --#List of drill-holes and trenches collars          If second comment just after title line, 
--                                                      texte to be printed.
--                                                      If empty line just after title line, the
--                                                      title is a section title, not a query's title.
--
-- --query to be optimised, later on                    if comment without #, off, ignored.
--
-- SELECT * FROM dh_collar;                             SQL query
--                                                      etc.
-- --#}}}                                               end of a paragraph
-- --#END}}} end


-- (usage, in French:)
-- Pour la génération d'un rapport, on code comme suit:
-- tout commentaire devant servir est préfixé par # après le --
-- --#BEGIN{{{ la balise de début
-- --#{{{nLes têtes d'ouvrages                          Titre de la requête, sur une seule ligne.
--                                                      l'indentation /*en nombre de + au début*/
--                                                      en n (après les -- et les accolades)
--                                                      fait la hiérarchie
--
-- --#Liste des têtes de sondages et tranchées          Si second commentaire juste après la ligne de titre, 
--                                                      texte à afficher.
--                                                      Si ligne vide après la ligne de titre, le titre fait celui 
--                                                      d'une rubrique, pas d'une requête.
--
-- --faudra peaufiner cette roquette                    si commentaire non diésé, commentaire off, ignoré
--
-- SELECT * FROM dh_collar;                             le SQL de la requête
--                                                      etc.
-- --#}}}                                               fin d'un paragraphe
-- --#END}}} la fin
--
--------------------------------------------------------------------------------------------------------------------


--#{{{1Some temporary queries

--#dh_sampling on HASS
SELECT * FROM dh_sampling WHERE id ILIKE 'HASS%' ORDER BY id, depto;

--#}}}


--#BEGIN{{{
--requêtes de vérifications des données

--#{{{1Check drill holes and trenches data
--sondages/tranchées

--#{{{2Collars information: dh_collars table

--#id duplicates in dh_collars
--CREATE OR REPLACE VIEW checks.doublons_dh_collars_id AS 
SELECT opid, id AS dh_collars_id_non_uniq, COUNT(id) FROM dh_collars GROUP BY opid, id HAVING COUNT(id)>1;

--#id, location fields: unconsistent data (when id is supposed to start with location): location vs. identifier prefix:
SELECT opid, split_part(id, '_', 1) AS id_left_part, location, count(*) AS nb_records FROM dh_collars /*WHERE completed IS TRUE*/ GROUP BY opid, split_part(id, '_', 1), location HAVING split_part(id, '_', 1) <> location ORDER BY split_part(id, '_', 1);

--#Field location refers to occurrences table.
--#Non-corresponding records, between dh_collars and occurrences:
SELECT dh_collars.opid, location AS collars_location, occurrences.opid, code AS occurrences_code, COUNT(*) 
FROM dh_collars 
FULL OUTER JOIN 
occurrences 
ON (dh_collars.opid = occurrences.opid AND dh_collars.location = occurrences.code)
GROUP BY dh_collars.opid, occurrences.opid, location, code 
HAVING dh_collars.location IS NULL OR occurrences.code IS NULL
ORDER BY coalesce(dh_collars.opid, occurrences.opid), coalesce(dh_collars.location, occurrences.code);

--#Records without location or sector:
SELECT opid, id, location FROM dh_collars WHERE location IS NULL ORDER BY 1,2,3;

--#id, shid fields: drill holes or trenches identifiers. id = IDentifier, shid = SHort IDentifier; unconsistent records:
SELECT opid, split_part(id, '_', 2) AS id_right_part, shid, replace(split_part(id, '_', 2), '0', '') AS id_right_part_no0, replace(shid, '0', '') AS shid_no0 FROM dh_collars WHERE replace(split_part(id, '_', 2), '0', '') <> replace(shid, '0', '') ORDER BY 1, 2, 3, 4;

--#Unconsistent geometries: azimuth and dip
SELECT opid, id, azim_ng, dip_hz, dh_type FROM dh_collars WHERE azim_ng >360 OR dip_hz < 0 OR dip_hz > 90 ORDER BY 1, 2, 3, 4;

--#Magnetic north vs. true north azimuths. These are all the possible differences between azimut Ng minus azimut Nm, found in the dh_collars table:
SELECT opid, azim_ng - azim_nm AS diff_azim_ng_m, count(*) FROM dh_collars GROUP BY opid, (azim_ng-azim_nm) ORDER BY opid, (azim_ng-azim_nm);

--#Missing coordinates:
SELECT opid, id, x, y, z FROM dh_collars WHERE x IS NULL OR x <0 OR y IS NULL OR y <0 OR z IS NULL OR z <0 ORDER BY opid, id;

--#Drill holes coordinates, suspect values: values rounded at 10m: Possibly type cast errors during data conversions?
SELECT opid, id, x,y,z from dh_collars where x=cast(x/10 as int)*10 or y=cast(y/10 as int)*10 ORDER BY opid, id;

--#Drill holes or trenches types unconsistent with identifiers. For instance, id = ABD_T014 and dh_type = D.
SELECT opid, id, dh_type FROM dh_collars WHERE substr(split_part(id, '_', 2), 1, 1) <> dh_type ORDER BY opid, dh_type, id;

--#Drill holes with shallow dips listed first: very flat drill holes can be suspect.
SELECT opid, id, dip_hz, dh_type from dh_collars /*WHERE dh_type <> 'T'*/ order by opid, dip_hz, id;

--#Drill holes at the same place: relative duplicates on coordinates:
SELECT opid, min(id) AS min_id, max(id) AS max_id, x, y, z, count(*) AS number_of_holes_at_same_place FROM dh_collars GROUP BY opid, x,y,z HAVING count(*) >1 ORDER BY opid, min_id, max_id;

--#... concerned drill holes:
SELECT opid, id, dh_collars.x, dh_collars.y, dh_collars.z, azim_ng, dip_hz FROM dh_collars JOIN (SELECT count(*),x,y FROM dh_collars GROUP BY x,y HAVING count(*) >1) tmp ON (dh_collars.x=tmp.x AND dh_collars.y=tmp.y) ORDER BY opid, id;

--#Drill holes lengths, comparison between total length, and various lengths (destructive, PQ, HQ, NQ, BQ). Records listed below are unconsistent:
--(not working any more since september 2013, after modifications SMI
SELECT opid, id, x,y,length, (coalesce((coalesce(len_destr,0) +coalesce(len_pq,0) +coalesce(len_hq,0) + coalesce(len_nq,0)+ coalesce(len_bq,0)),0)) as somme_lenX, len_destr, len_pq, len_hq, len_nq, len_bq, dh_type FROM dh_collars WHERE (length - coalesce((coalesce(len_destr,0) +coalesce(len_pq,0) +coalesce(len_hq,0) + coalesce(len_nq,0)+ coalesce(len_bq,0)),0)) <> 0 ORDER BY opid, id;


--#{{{3Check collars vs. runs tables: non-matching identifiers (orphan records) and unconsistent lengths
--#Comparison between data from dh_collars table and other tables: orphan records, and different drill holes or trenches lengths and depths.

--#Drill holes lengths, comparison between lengths from various down-hole tables:
SELECT * FROM (
 SELECT *, 
 dh_collars_length - coalesce(shift_reports_max_length          , dh_collars_length) AS diff_collars_shift_reports_SHOULD_BE_ZERO, 
 dh_collars_length - coalesce(dh_tech_max_depto                 , dh_collars_length) AS diff_collars_dh_tech_SHOULD_BE_ZERO, 
 dh_collars_length - coalesce(dh_devia_max_depto                , dh_collars_length) AS diff_collars_dh_devia_SHOULD_BE_SUP_TO_ZERO, 
 dh_collars_length - coalesce(dh_litho_max_depto                , dh_collars_length) AS diff_collars_dh_litho_SHOULD_BE_ZERO, 
 dh_collars_length - coalesce(dh_sampling_max_depto             , dh_collars_length) AS diff_collars_dh_sampling_SHOULD_BE_ZERO, 
 dh_collars_length - coalesce(dh_density_max_depto              , dh_collars_length) AS diff_collars_dh_density_SHOULD_BE_ZERO, 
 dh_collars_length - coalesce(dh_mineralised_intervals_max_depto, dh_collars_length) AS diff_collars_dh_mineralised_intervals_SHOULD_BE_SUP_TO_ZERO, 
 dh_collars_length - coalesce(dh_struct_max_depto               , dh_collars_length) AS diff_collars_dh_struct_SHOULD_BE_SUP_TO_ZERO  
 FROM (
  SELECT 
   shift_reports.opid AS shift_reports_opid, shift_reports.id AS shift_reports_id, 
   dh_collars.opid    AS dh_collars_opid,    dh_collars.id AS dh_collars_id, 
   shift_reports_max_length, dh_collars.length AS dh_collars_length, dh_tech_max_depto, dh_devia_max_depto, dh_litho_max_depto, dh_sampling_max_depto, dh_density_max_depto, dh_mineralised_intervals_max_depto, dh_struct_max_depto 
  FROM (
   SELECT opid, id, max(drilled_length) AS shift_reports_max_length 
   FROM shift_reports GROUP BY opid, id
   ) AS shift_reports 
  RIGHT JOIN 
   dh_collars 
  ON (shift_reports.opid = dh_collars.opid AND shift_reports.id = dh_collars.id) 
  LEFT JOIN 
   (SELECT opid, id, max(depto) AS dh_tech_max_depto 
    FROM dh_tech GROUP BY opid, id
   ) AS dh_tech 
   ON (dh_collars.opid = dh_tech.opid AND dh_collars.id = dh_tech.id)
  LEFT JOIN 
   (SELECT opid, id, max(depto) AS dh_devia_max_depto 
    FROM dh_devia GROUP BY opid, id
   ) AS dh_devia 
   ON (dh_collars.opid = dh_devia.opid AND dh_collars.id = dh_devia.id)
  LEFT JOIN 
   (SELECT opid, id, max(depto) AS dh_litho_max_depto 
    FROM dh_litho GROUP BY opid, id
   ) AS dh_litho 
   ON (dh_collars.opid = dh_litho.opid AND dh_collars.id = dh_litho.id)
  LEFT JOIN 
   (SELECT opid, id, max(depto) AS dh_sampling_max_depto 
    FROM dh_sampling GROUP BY opid, id
   ) AS dh_sampling 
   ON (dh_collars.opid = dh_sampling.opid AND dh_collars.id = dh_sampling.id)
  LEFT JOIN 
   (SELECT opid, id, max(depto) AS dh_density_max_depto 
    FROM dh_density 
    GROUP BY opid, id
   ) AS dh_density 
  ON (dh_collars.opid = dh_density.opid AND dh_collars.id = dh_density.id)
  LEFT JOIN 
   (SELECT opid, id, max(depto) AS dh_mineralised_intervals_max_depto 
    FROM dh_mineralised_intervals 
    GROUP BY opid, id
   ) AS dh_mineralised_intervals 
   ON (dh_collars.opid = dh_mineralised_intervals.opid AND dh_collars.id = dh_mineralised_intervals.id)
  LEFT JOIN 
   (SELECT opid, id, max(depto) AS dh_struct_max_depto 
    FROM dh_struct_measures 
    GROUP BY opid, id
   ) AS dh_struct_measures 
   ON (dh_collars.opid = dh_struct_measures.opid AND dh_collars.id = dh_struct_measures.id) 
  ) AS tmp 
 ) AS tmp 
WHERE 
   diff_collars_shift_reports_SHOULD_BE_ZERO <> 0 
OR diff_collars_dh_tech_SHOULD_BE_ZERO <> 0 
OR /*diff_collars_dh_devia_SHOULD_BE_ZERO <> 0 OR */ diff_collars_dh_litho_SHOULD_BE_ZERO <> 0 
OR diff_collars_dh_sampling_SHOULD_BE_ZERO <> 0 
OR diff_collars_dh_density_SHOULD_BE_ZERO <> 0 /*OR diff_collars_dh_mineralised_intervals_SHOULD_BE_ZERO <> 0 OR diff_collars_dh_struct_SHOULD_BE_ZERO <> 0*/
ORDER BY coalesce(shift_reports_opid, dh_collars_opid), coalesce(shift_reports_id, dh_collars_id);


--#<ul>

--#<li>dh_collars vs. shift_reports</li>

--#<ul><li>orphans</li>

--#Outer join between the two tables on dh_collars.id and shift_reports.id: the following query lists orphan records, they are all missing id, from one side or the other. Note that many historical holes do not have any shift report.
SELECT dh_collars.opid AS dh_collars_opid, dh_collars.id AS dh_collars_id, tmp.opid AS shift_opid, tmp.id AS shift_id, count
FROM dh_collars FULL OUTER JOIN 
(SELECT opid, id, count(*) AS count FROM shift_reports GROUP BY opid, id) tmp 
ON (dh_collars.opid = tmp.opid AND dh_collars.id = tmp.id) 
WHERE (dh_collars.id IS NULL OR tmp.id IS NULL) 
ORDER BY coalesce(dh_collars.opid, tmp.opid), coalesce(dh_collars.id, tmp.id);

--#id mentioned in shift reports, but not in dh_collars:
SELECT * FROM (
SELECT DISTINCT shift_reports.opid, shift_reports.id, dh_collars.opid, dh_collars.id 
FROM 
shift_reports 
LEFT JOIN 
dh_collars 
ON (shift_reports.opid = dh_collars.opid AND shift_reports.id = dh_collars.id) 
WHERE dh_collars.id IS NULL 
) AS tmp
ORDER BY coalesce(1, 3), coalesce(2, 4);

--#<li>Unconsistent data</li>

--#Status (completed or not) differ from shift_reports and dh_collars:
SELECT tmp.opid, tmp.id, dh_collars.completed, max_completed_shift_reports 
FROM 
(SELECT opid, id, max(completed::integer) AS max_completed_shift_reports FROM shift_reports GROUP BY opid, id) tmp 
JOIN 
dh_collars 
ON (tmp.opid = dh_collars.opid AND tmp.id = dh_collars.id) 
WHERE dh_collars.completed::integer <> max_completed_shift_reports;

-- #Azimuth differ from shift_reports and dh_collars:
--(not working any more since september 2013, after modifications SMI
--SELECT shift_reports.opid, shift_reports.id, /*shift_reports.azim_nm, */dh_collars.azim_nm FROM 
--shift_reports 
--JOIN dh_collars 
--ON (shift_reports.opid = dh_collars.opid AND shift_reports.id = dh_collars.id) 
--WHERE shift_reports.azim_ng <> dh_collars.azim_ng;

-- #Dip differ from shift_reports and dh_collars:
--(not working any more since september 2013, after modifications SMI
--SELECT shift_reports.id, shift_reports.dip AS shift_reports_dip, dh_collars.dip_hz AS dh_collars_dip FROM shift_reports JOIN dh_collars ON shift_reports.id = dh_collars.id WHERE shift_reports.dip <> dh_collars.dip_hz;

--#</ul>



--#<li>dh_collars vs. dh_tech</li>

--#<ul><li>orphans</li>

--#Outer join between the two tables on dh_collars.id and dh_tech.id: the following query lists orphan records, they are all missing id, from one side or the other.
SELECT dh_collars.opid AS dh_collars_opid, dh_collars.id AS dh_collars_id, tmp.id AS dh_tech_id, count
FROM dh_collars FULL OUTER JOIN 
(SELECT opid, id, count(*) AS count FROM dh_tech GROUP BY dh_tech.opid, dh_tech.id) tmp 
ON (dh_collars.opid = tmp.opid AND dh_collars.id = tmp.id) 
WHERE (dh_collars.id IS NULL OR tmp.id IS NULL) 
ORDER BY coalesce(dh_collars.opid, tmp.opid), coalesce(dh_collars.id, tmp.id);

--#<li>lengths</li>

--#Comparisons of lengths.
SELECT dh_collars.opid, dh_collars.id, length, max_depto, length - max_depto AS diff_SHOULD_BE_SUPERIOR_TO_ZERO 
FROM dh_collars INNER JOIN (SELECT opid, id,max(depto) AS max_depto FROM dh_tech GROUP BY opid, id) AS max_depto ON (dh_collars.opid = max_depto.opid AND dh_collars.id = max_depto.id) WHERE length - max_depto <> 0 ORDER BY opid, id;

--#</ul>



--#<li>dh_collars vs. dh_devia</li>

--#<ul><li>orphans</li>

--#Outer join between the two tables on dh_collars.id and dh_devia.id: the following query lists orphan records, they are all missing id, from one side or the other.
SELECT dh_collars.opid AS dh_collars_opid, dh_collars.id AS dh_collars_id, tmp.opid AS dh_devia_opid, tmp.id AS dh_devia_id, count
FROM dh_collars FULL OUTER JOIN 
(SELECT opid, id, count(*) AS count FROM dh_devia GROUP BY dh_devia.opid, dh_devia.id) tmp 
ON (dh_collars.opid = tmp.opid AND dh_collars.id = tmp.id) 
WHERE (dh_collars.id IS NULL OR tmp.id IS NULL) 
ORDER BY coalesce(dh_collars.opid, tmp.opid), coalesce(dh_collars.id, tmp.id);

--#<li>lengths</li>

--#Comparisons of lengths. Note: it is normal that deviation measurements do not necessarily reach the bottom of a hole.
SELECT dh_collars.opid, dh_collars.id, length, max_depto, length - max_depto AS diff_SHOULD_BE_SUPERIOR_TO_ZERO 
FROM dh_collars INNER JOIN (SELECT opid, id,max(depto) AS max_depto FROM dh_devia GROUP BY opid, id) AS max_depto ON (dh_collars.opid = max_depto.opid AND dh_collars.id = max_depto.id) WHERE length - max_depto <> 0 ORDER BY opid, id;
--#</ul>



--#<li>dh_collars vs. dh_litho</li>

--#<ul><li>orphans</li>

--#Outer join between the two tables on dh_collars.id and dh_litho.id: the following query lists orphan records, they are all missing id, from one side or the other.
SELECT dh_collars.opid AS dh_collars_opid, dh_collars.id AS dh_collars_id, tmp.opid AS dh_litho_opid, tmp.id AS dh_litho_id, count
FROM dh_collars FULL OUTER JOIN 
(SELECT opid, id, count(*) AS count FROM dh_litho GROUP BY dh_litho.opid, dh_litho.id) tmp 
ON (dh_collars.opid = tmp.opid AND dh_collars.id = tmp.id) 
WHERE (dh_collars.id IS NULL OR tmp.id IS NULL) 
ORDER BY coalesce(dh_collars.opid, tmp.opid), coalesce(dh_collars.id, tmp.id);
dh_collars.id || tmp.id;

--#Holes in dh_collars and not in dh_litho: sometimes tolerable, for holes not described, but there should not be many:
SELECT dh_collars.opid, dh_collars.id AS dh_collars_id_without_litho, dh_litho.id AS litho_id_nulls FROM dh_collars LEFT OUTER JOIN dh_litho ON 
(dh_collars.opid=dh_litho.opid 
AND 
dh_collars.id=dh_litho.id )
WHERE dh_litho.id IS NULL ORDER BY dh_collars.opid, dh_collars.id;

--#Holes in dh_litho but not in dh_collars: absolutely untolerable:
SELECT DISTINCT dh_collars.opid, dh_collars.id, dh_litho.opid, dh_litho.id AS litho_id FROM dh_collars RIGHT OUTER JOIN dh_litho ON 
(dh_collars.opid = dh_litho.opid AND dh_collars.id = dh_litho.id) WHERE dh_collars.id IS NULL ORDER BY dh_litho.opid, dh_litho.id;

--#<li>lengths</li>

--#Comparisons of lengths. Note that holes should be described until their end, but not beyond (negative differences).
SELECT dh_collars.opid, dh_collars.id, length, max_depto, length - max_depto AS diff_SHOULD_BE_ZERO 
FROM dh_collars INNER JOIN (SELECT opid, id,max(depto) AS max_depto FROM dh_litho GROUP BY opid, id) AS max_depto ON (dh_collars.opid = max_depto.opid AND dh_collars.id = max_depto.id) WHERE length - max_depto <> 0 ORDER BY opid, id;
--#</ul>



--#<li>dh_collars vs. dh_struct</li>

--#<ul><li>orphans</li>

--#Outer join between the two tables on dh_collars.id and dh_struct.id: the following query lists orphan records, they are all missing id, from one side or the other.
SELECT dh_collars.opid, dh_collars.id AS dh_collars_id, tmp.opid AS dh_struct_opid, tmp.id AS dh_struct_id, count
FROM dh_collars FULL OUTER JOIN 
(SELECT opid, id, count(*) AS count FROM dh_struct_measures GROUP BY dh_struct_measures.opid, dh_struct_measures.id) tmp 
ON (dh_collars.opid = tmp.opid AND dh_collars.id = tmp.id) 
WHERE (dh_collars.id IS NULL OR tmp.id IS NULL) 
ORDER BY coalesce(dh_collars.opid, tmp.opid), coalesce(dh_collars.id, tmp.id);

--#<li>lengths</li>

--#Comparisons of lengths.
SELECT dh_collars.opid, dh_collars.id, length, max_depto, length - max_depto AS diff_SHOULD_BE_SUPERIOR_TO_ZERO 
FROM dh_collars INNER JOIN (SELECT opid, id,max(depto) AS max_depto FROM dh_struct_measures GROUP BY opid, id) AS max_depto ON (dh_collars.opid = max_depto.opid AND dh_collars.id = max_depto.id) WHERE length - max_depto <> 0 ORDER BY opid, id;

--#</ul>



--#<li>dh_collars vs. dh_sampling</li>

--#<ul><li>orphans</li>

--#Unsampled holes and unallocated samples. Outer join between the two tables on dh_collars.id and dh_sampling.id: the following query lists orphan records, they are all missing id, from one side or the other. The field dh_collars.nb_samples is supposed to contain the number of samples taken in each hole/trench: when it is set to zero, it means that the hole/trench was not sampled.
SELECT dh_collars.opid, dh_collars.id AS dh_collars_id, dh_collars.nb_samples AS nb_samples_supposed, tmp.opid AS dh_sampling_opid, tmp.id AS dh_sampling_id, tmp.samples AS number_samples FROM (SELECT * FROM dh_collars WHERE NOT(coalesce('', comments) ILIKE '% => hole not sampled%')) AS dh_collars FULL OUTER JOIN (SELECT opid, id, count(*) AS samples FROM dh_sampling GROUP BY dh_sampling.opid, dh_sampling.id) tmp ON (dh_collars.opid = tmp.opid AND dh_collars.id = tmp.id) WHERE (dh_collars.id IS NULL OR tmp.id IS NULL) ORDER BY coalesce(dh_collars.opid, tmp.opid), coalesce(dh_collars.id, tmp.id);
--POUBELLE:
	----#{{{3When dh_collars_id do not correspond to any dh_sampling_id, it means (hopefully) that the hole/trench has not been sampled.  Strange, but explainable.  When it is the other way, it is a mistake: a sample without its collar defined is not acceptable. Amount of records from dh_sampling concerned:
	--SELECT SUM(number_samples) FROM (SELECT dh_collars.id AS dh_collars_id, tmp.id AS dh_sampling_id, tmp.samples AS number_samples FROM dh_collars FULL OUTER JOIN (SELECT id, COUNT(*)AS samples FROM dh_sampling GROUP BY dh_sampling.id) tmp ON dh_collars.id = tmp.id WHERE dh_collars.id IS NULL OR tmp.id IS NULL) AS tmp;
	----#}}}

--#Holes in dh_collars and not in child table: possible, for holes which were not sampled, but there should not be many.
SELECT dh_collars.opid, dh_collars.id AS dh_collars_id_without_samples, dh_sampling.opid AS samples_opid_nulls, dh_sampling.id AS samples_id_nulls FROM dh_collars LEFT OUTER JOIN dh_sampling ON (dh_collars.opid = dh_sampling.opid AND dh_collars.id = dh_sampling.id) WHERE (dh_collars.completed IS NOT NULL AND dh_collars.completed IS NOT FALSE) AND dh_sampling.id IS NULL ORDER BY dh_collars.opid, dh_collars.id;

--#Holes not in dh_collars and in child table: absolutely untolerable, samples lost
SELECT dh_sampling_id, count(*) AS nb_records FROM (SELECT dh_collars.opid, dh_collars.id, dh_sampling.opid AS dh_sampling_opid, dh_sampling.id AS dh_sampling_id FROM dh_collars RIGHT OUTER JOIN dh_sampling ON (dh_collars.opid = dh_sampling.opid AND dh_collars.id = dh_sampling.id) WHERE dh_collars.id IS NULL ORDER BY dh_sampling.opid, dh_sampling.id) tmp GROUP BY dh_sampling_opid, dh_sampling_id ORDER BY dh_sampling_opid, dh_sampling_id;

--#<li>lengths</li>

--#Comparisons of lengths. Note that some holes or trenches may not be sampled until the end (column diff > 0).
SELECT dh_collars.opid, dh_collars.id, length, max_depto, length - max_depto AS diff_SHOULD_BE_ZERO_OR_AT_LEAST_POSITIVE FROM dh_collars INNER JOIN (SELECT opid, id,max(depto) AS max_depto FROM dh_sampling GROUP BY opid, id) AS max_depto ON (dh_collars.opid = max_depto.opid AND dh_collars.id = max_depto.id) WHERE length - max_depto <> 0 ORDER BY opid, id;

--#</ul>



--#<li>dh_collars vs. dh_mineralised_intervals</li>

--#<ul><li>orphans</li>

--#Outer join between the two tables on dh_collars.id and dh_mineralised_intervals.id: the following query lists orphan records, they are all missing id, from one side or the other.
SELECT dh_collars.opid, dh_collars.id AS dh_collars_id, tmp.opid AS dh_mine_opid, tmp.id AS dh_mine_id, count_mineralised_intervals
FROM dh_collars FULL OUTER JOIN 
(SELECT opid, id, count(*) AS count_mineralised_intervals FROM dh_mineralised_intervals GROUP BY dh_mineralised_intervals.opid, dh_mineralised_intervals.id) tmp 
ON (dh_collars.opid = tmp.opid AND dh_collars.id = tmp.id) 
WHERE (dh_collars.id IS NULL OR tmp.id IS NULL) 
ORDER BY coalesce(dh_collars.opid, tmp.opid), coalesce(dh_collars.id, tmp.id);

--#<li>lengths</li>

--#Comparisons of lengths. Note that some holes or trenches may not have mineralised intervals until their end. Holes mineralised at the end should be redrilled, by the way.
SELECT dh_collars.opid, dh_collars.id, length, max_depto, length - max_depto AS diff_SHOULD_BE_SUPERIOR_TO_ZERO 
FROM dh_collars INNER JOIN (SELECT opid, id,max(depto) AS max_depto FROM dh_mineralised_intervals GROUP BY opid, id) AS max_depto ON (dh_collars.opid = max_depto.opid AND dh_collars.id = max_depto.id) WHERE length - max_depto <> 0 ORDER BY opid, id;

--#</ul>

--#</ul>

--#}}}3
--#}}}2

--#{{{2Samples: dh_sampling table

--#{{{3Unique identifier; primary key
--#The sample identifier and the key of dh_sampling table is dh_sampling.sample_id; it is supposed to be unique

--#<ul><li>list of sample_id not uniques:</li>
SELECT opid, sample_id, COUNT(*) FROM dh_sampling GROUP BY opid, sample_id HAVING COUNT(*) >1 ORDER BY 1, 2;

--#<li>Drill holes which have several duplicate sample_id's</li>
SELECT DISTINCT opid, id FROM
(
SELECT dh_sampling.opid, dh_sampling.id, dh_sampling.sample_id FROM dh_sampling JOIN 
 (
 SELECT opid, sample_id, COUNT(*) FROM dh_sampling GROUP BY opid, sample_id HAVING COUNT(*) >1
 ) AS tmp 
ON 
(dh_sampling.opid = tmp.opid AND dh_sampling.sample_id = tmp.sample_id)
)
AS tmp
ORDER BY opid, id;


--#<li>id-depto duplicates in dh_sampling</li>
--#Some of the duplicates above are normal, when trenches or drill holes are resampled with narrower intervals, or when composites samples are taken.
--CREATE OR REPLACE VIEW checks.doublons_dh_sampling_id_depto AS 
SELECT opid, id, depto, COUNT(*) FROM dh_sampling GROUP BY opid, id, depto HAVING COUNT(*) > 1 ORDER BY opid, id, depto;

--bof
--#Same records, with sample identifiers (sample_id):
--SELECT id, depfrom, depto, sample_id from dh_sampling where (id, depto) in (select id, depto from dh_sampling group by id, depto having count(*) >1) order by id, depto, sample_id;

--#<li>id-depfrom-depto duplicates in dh_sampling</li>
--#Here, there should not be any duplicate.
SELECT opid, id, depfrom, depto, COUNT(*) FROM dh_sampling GROUP BY opid, id, depfrom, depto HAVING COUNT(*) > 1 ORDER BY opid, id, depto;

--#</ul>

--#}}}3

--#{{{3Other variables in dh_sampling table:


--#<ul><li>Core losses from core samples.</li>

--#Worst cases sorted first: bigger core losses:
SELECT * FROM dh_sampling  WHERE core_loss_cm IS NOT NULL ORDER BY core_loss_cm DESC;

--#Impossible core losses, i.e. bigger than interval:
SELECT opid, id, depfrom, depto, core_loss_cm, sample_id FROM dh_sampling WHERE core_loss_cm IS NOT NULL AND (depto-depfrom) * 100 < core_loss_cm ORDER BY opid, core_loss_cm DESC;

--#Suspect values: core losses smaller than 1cm:
SELECT opid, id, depfrom, depto, core_loss_cm, sample_id FROM dh_sampling WHERE core_loss_cm <= 1ORDER BY opid, id, depto;

--#<li>Samples weigths.</li>

--#Extreme, most improbable values sorted first:
SELECT opid, id, depfrom, depto, weight_kg FROM dh_sampling WHERE weight_kg IS NOT NULL ORDER BY opid, weight_kg DESC;

--#<li>Batch identifier: should match lab_ana_batches_expedition table</li>
--#Non-matching records: samples with a batch defined, which does not correspond to a defined batch in lab_ana_batches_expedition table. Note that historical samples did not have any batch identification. Batch identifiers have been made up since.
SELECT dh_sampling.opid, id, depfrom, depto, sample_id, dh_sampling.batch_id FROM dh_sampling LEFT OUTER JOIN lab_ana_batches_expedition ON (dh_sampling.opid = lab_ana_batches_expedition.opid AND dh_sampling.batch_id = lab_ana_batches_expedition.batch_id) WHERE lab_ana_batches_expedition.batch_id IS NULL;

--#Non-matching batch_id from both dh_sampling and lab_ana_batches_expedition tables:
SELECT lab_ana_batches_expedition.opid, lab_ana_batches_expedition.batch_id AS lab_ana_batches_expedition_batch_id, dh_sampling.opid AS dh_sampling_opid, dh_sampling.batch_id AS dh_sampling_batch_id FROM lab_ana_batches_expedition FULL OUTER JOIN dh_sampling ON (lab_ana_batches_expedition.opid = dh_sampling.opid AND lab_ana_batches_expedition.batch_id = dh_sampling.batch_id) WHERE lab_ana_batches_expedition.batch_id IS NULL OR dh_sampling.batch_id IS NULL GROUP BY lab_ana_batches_expedition.opid, lab_ana_batches_expedition.batch_id, dh_sampling.opid, dh_sampling.batch_id ORDER BY lab_ana_batches_expedition.opid, lab_ana_batches_expedition.batch_id, dh_sampling.batch_id;
--#</ul>

--#}}}3
--#}}}2


--#}}}1
--#{{{1Analytical data

--#{{{2lab_ana_results table

--#Check data consistency:

--#<ul><li>Lab_ana_results absolute duplicates: sample identifier + scheme + analyte + value_num:
SELECT 
opid, sample_id, labname, jobno, orderno, batch_id, scheme, analyte, value, value_num, unit, db_update_timestamp, datasource
, count(*) FROM lab_ana_results 
GROUP BY 
opid, sample_id, labname, jobno, orderno, batch_id, scheme, analyte, value, value_num, unit, db_update_timestamp, datasource
HAVING count(*) > 1 ORDER BY 
opid, sample_id, labname, jobno, orderno, batch_id, scheme, analyte, value, value_num, unit, db_update_timestamp, datasource
;

--#Count of these absolute duplicate records for each datasource:
SELECT tmp.opid, tmp.datasource, filename, tmp.count FROM
(SELECT opid, datasource, count(*) AS count FROM 
(
SELECT 
opid, sample_id, labname, jobno, orderno, batch_id, scheme, analyte, value, value_num, unit, db_update_timestamp, datasource
, count(*) FROM lab_ana_results 
GROUP BY 
opid, sample_id, labname, jobno, orderno, batch_id, scheme, analyte, value, value_num, unit, db_update_timestamp, datasource
HAVING count(*) > 1 ORDER BY 
opid, sample_id, labname, jobno, orderno, batch_id, scheme, analyte, value, value_num, unit, db_update_timestamp, datasource
) 
AS tmp GROUP BY opid, datasource) AS tmp
LEFT OUTER JOIN lex_datasource ON (tmp.opid = lex_datasource.opid AND tmp.datasource = lex_datasource.datasource_id) 
ORDER BY opid, datasource;





--#<ul><li>Lab_ana_results relative duplicates: sample identifier + scheme + analyte
--#The following list shows the same combination of the three fields: sample_id, scheme, analyte
SELECT opid, sample_id, analyte, scheme, COUNT(*) FROM lab_ana_results WHERE value_num IS NOT NULL GROUP BY opid, sample_id, scheme, analyte HAVING COUNT(*) > 1
ORDER BY opid, sample_id, analyte, scheme;

--#The corresponding records in lab_ana_results table:
SELECT 
lab_ana_results.opid, batch_id, lab_ana_results.sample_id, scheme, analyte, labname, jobno, orderno, value_num, value, db_update_timestamp, datasource 
FROM lab_ana_results 
JOIN 
(SELECT DISTINCT opid, sample_id FROM (SELECT opid, sample_id, analyte, COUNT(*) FROM lab_ana_results WHERE value_num IS NOT NULL GROUP BY opid, sample_id, scheme, analyte HAVING COUNT(*) > 1) AS tmp)
 tmp ON (lab_ana_results.opid = tmp.opid AND lab_ana_results.sample_id = tmp.sample_id) ORDER BY lab_ana_results.opid, lab_ana_results.sample_id, scheme, analyte, lab_ana_results.orderno, lab_ana_results.jobno;






--#Check orphan records, samples vs. analyses:

--#<ul><li>Samples without assay 

--#These are normally pending results.</li>
SELECT dh_sampling.opid, dh_sampling.id, dh_sampling.depfrom, dh_sampling.depto, dh_sampling.sample_id AS dh_sampling_sample_id, lab_ana_results.sample_id AS lab_ana_results_sample_id FROM dh_sampling LEFT OUTER JOIN lab_ana_results ON (dh_sampling.opid = lab_ana_results.opid AND dh_sampling.sample_id = lab_ana_results.sample_id) WHERE lab_ana_results.sample_id IS NULL ORDER BY dh_sampling.opid, dh_sampling.id, dh_sampling.depto;

--#<li>Analyses without samples in dh_sampling table OR in qc_sampling table: absolutely untolerable, these should be rocks, soils</li>
--Information about sample types has to be put in batch table, so that comparisons can be made: at the moment, it is not possible to know whether a sample is a soil, a rock, a drill hole, etc., especially since the ticket_id system was put in place.<br>Note that 'scout' samples are routine samples, but considered as a first assay, so they are in qc_sampling table, rather than in dh_sampling, IF they have been assayed properly later.
SELECT dh_sampling_plus_qc.opid AS dh_sampling_plus_qc_sample_opid, dh_sampling_plus_qc.sample_id AS dh_sampling_plus_qc_sample_id, lab_ana_results.sample_id AS lab_ana_results_sample_id 
FROM 
(
SELECT opid, sample_id FROM dh_sampling UNION SELECT opid, sample_id FROM qc_sampling
) AS dh_sampling_plus_qc
RIGHT OUTER JOIN lab_ana_results ON (dh_sampling_plus_qc.opid = lab_ana_results.opid AND dh_sampling_plus_qc.sample_id = lab_ana_results.sample_id) WHERE dh_sampling_plus_qc.sample_id IS NULL GROUP BY dh_sampling_plus_qc.opid, dh_sampling_plus_qc.sample_id, lab_ana_results.opid, lab_ana_results.sample_id ORDER BY coalesce(dh_sampling_plus_qc.opid, lab_ana_results.opid), coalesce(dh_sampling_plus_qc.sample_id, lab_ana_results.sample_id);




--#<li>The two lists above, juxtaposed and sorted</li>
SELECT dh_sampling_plus_qc.opid AS dh_sampling_plus_qc_opid, dh_sampling_plus_qc.sample_id AS dh_sampling_plus_qc_sample_id, 
lab_ana_results.opid AS lab_ana_results_opid, lab_ana_results.sample_id AS lab_ana_results_sample_id 
FROM 
(
SELECT opid, sample_id FROM dh_sampling 
UNION 
SELECT opid, sample_id FROM qc_sampling
) AS dh_sampling_plus_qc
FULL OUTER JOIN 
lab_ana_results 
ON (dh_sampling_plus_qc.opid = lab_ana_results.opid AND dh_sampling_plus_qc.sample_id = lab_ana_results.sample_id) 
WHERE dh_sampling_plus_qc.sample_id IS NULL 
OR lab_ana_results.sample_id IS NULL 
GROUP BY 
dh_sampling_plus_qc.opid, lab_ana_results.opid, dh_sampling_plus_qc.sample_id, lab_ana_results.sample_id ORDER BY 
coalesce(dh_sampling_plus_qc.opid, lab_ana_results.opid),
coalesce(dh_sampling_plus_qc.sample_id, lab_ana_results.sample_id);

--#</ul>
--#</ul>


--}}}2

--#{{{2Samples batches for analysis: lab_ana_batches_expedition

--#A batch is defined for every sample homogeneous batch sent to a laboratory. Numbering of batches (batch_id) is made of year and a sequential number. For instance, 1789065 would be the 65th batch of samples sent for assay during the year 1789. Batch_id 0 is a special batch, for samples that have not been submitted for assay. Batch_id are defined in lab_ana_batches_expedition table; they are referenced in dh_sampling table, and also in lab_ana_results table. This makes a circular redundancy, which has to be checked. One sample may belong to several batches: in this case, the batch mentioned in dh_sampling table is the one which will be used for grades.

--#Summary of batches: batch_id, and amount of records in lab_ana_batches_expedition, dh_sampling, qc_sampling and lab_ana_results tables:
SELECT 
lab_ana_batches_expedition.opid, 
lab_ana_batches_expedition.batch_id, 
lab_ana_batches_expedition.samples_amount, 
dh_sampling_opid, 
dh_sampling_batch_id, 
count_dh_sampling, 
qc_sampling_batch_opid, 
qc_sampling_batch_id, 
count_qc_sampling, 
lab_ana_results_opid, 
lab_ana_results_batch_id, 
count_lab_ana_results 
FROM lab_ana_batches_expedition  
FULL OUTER JOIN 
(
SELECT opid AS dh_sampling_opid, batch_id AS dh_sampling_batch_id, count(dh_sampling.batch_id)     AS count_dh_sampling FROM dh_sampling GROUP BY dh_sampling.opid, dh_sampling.batch_id
) AS tmp1
ON (lab_ana_batches_expedition.opid = dh_sampling_opid AND lab_ana_batches_expedition.batch_id = tmp1.dh_sampling_batch_id) 
FULL OUTER JOIN
(
SELECT opid AS qc_sampling_batch_opid, batch_id AS qc_sampling_batch_id, count(qc_sampling.batch_id)     AS count_qc_sampling FROM qc_sampling GROUP BY qc_sampling.opid, qc_sampling.batch_id
) AS tmp2
ON (lab_ana_batches_expedition.opid = qc_sampling_batch_opid AND lab_ana_batches_expedition.batch_id = tmp2.qc_sampling_batch_id) 
FULL OUTER JOIN 
(
SELECT opid AS lab_ana_results_opid, batch_id AS lab_ana_results_batch_id, count(lab_ana_results.batch_id) AS count_lab_ana_results FROM lab_ana_results GROUP BY lab_ana_results.opid, lab_ana_results.batch_id
) AS tmp3
ON (lab_ana_batches_expedition.opid = lab_ana_results_opid AND lab_ana_batches_expedition.batch_id = tmp3.lab_ana_results_batch_id) 
ORDER BY 
coalesce(lab_ana_batches_expedition.opid,     dh_sampling_opid,     qc_sampling_batch_opid, lab_ana_results_opid), 
coalesce(lab_ana_batches_expedition.batch_id, dh_sampling_batch_id, qc_sampling_batch_id,   lab_ana_results_batch_id);



--#Orphans: samples not related to a batch in lab_ana_batches_expedition table:
SELECT dh_sampling.opid, sample_id, dh_sampling.batch_id, lab_ana_batches_expedition.batch_id FROM dh_sampling LEFT OUTER JOIN lab_ana_batches_expedition ON (dh_sampling.opid = lab_ana_batches_expedition.opid AND dh_sampling.batch_id = lab_ana_batches_expedition.batch_id) WHERE lab_ana_batches_expedition.batch_id IS NULL ORDER BY dh_sampling.opid, sample_id, dh_sampling.batch_id, lab_ana_batches_expedition.batch_id;

--#Orphans: control samples not related to a batch in lab_ana_batches_expedition table:
SELECT qc_sampling.opid, sample_id, qc_sampling.qc_type, qc_sampling.batch_id, lab_ana_batches_expedition.batch_id FROM qc_sampling LEFT OUTER JOIN lab_ana_batches_expedition ON (qc_sampling.opid = lab_ana_batches_expedition.opid AN qc_sampling.batch_id = lab_ana_batches_expedition.batch_id) WHERE lab_ana_batches_expedition.batch_id IS NULL ORDER BY qc_sampling.opid, sample_id, qc_sampling.batch_id, lab_ana_batches_expedition.batch_id;

--#Orphans: assay results not related to a batch in lab_ana_batches_expedition table:
SELECT lab_ana_results.opid, sample_id, lab_ana_results.batch_id, lab_ana_batches_expedition.batch_id FROM lab_ana_results LEFT OUTER JOIN lab_ana_batches_expedition ON (lab_ana_results.opid = lab_ana_batches_expedition.opid AND lab_ana_results.batch_id = lab_ana_batches_expedition.batch_id) ORDER BY sample_id, lab_ana_results.batch_id;

--#Orphans: batches referenced in lab_ana_batches_expedition table, without any corresponding sample or control sample or assay result:
SELECT DISTINCT lab_ana_batches_expedition.opid, lab_ana_batches_expedition.batch_id FROM lab_ana_batches_expedition LEFT OUTER JOIN (SELECT DISTINCT opid, batch_id FROM dh_sampling UNION SELECT DISTINCT opid, batch_id FROM qc_sampling UNION SELECT DISTINCT opid, batch_id FROM lab_ana_results) AS tmp ON (lab_ana_batches_expedition.opid = tmp.opid AND lab_ana_batches_expedition.batch_id = tmp.batch_id) WHERE tmp.batch_id IS NULL ORDER BY lab_ana_batches_expedition.opid, lab_ana_batches_expedition.batch_id;

--#Amount of samples per batch: small amounts (most suspect) listed first:
SELECT opid, batch_id, count(*) FROM dh_sampling GROUP BY opid, batch_id ORDER BY opid, count(*);

--#Unconsistency: no return date but results available
SELECT opid, batch_id, * FROM lab_ana_batches_expedition WHERE 
(reception_date IS NULL OR 
(results_received IS NULL OR NOT(results_received))
)
AND 
(opid, batch_id) IN (SELECT DISTINCT opid, batch_id FROM lab_ana_results);

--#Labname: at the moment, labname is mentioned in both lab_ana_results and in lab_ana_batches_expedition tables; it must be the same. Differences::
SELECT 
lab_ana_results.opid, lab_ana_results.batch_id, lab_ana_results.labname AS lab_ana_results_labname, lab_ana_batches_expedition.labname AS lab_ana_batches_expedition_labname
, count(*)
FROM 
lab_ana_results JOIN lab_ana_batches_expedition ON (lab_ana_results.opid = lab_ana_batches_expedition.opid AND lab_ana_results.batch_id = lab_ana_batches_expedition.batch_id) 
GROUP BY 
lab_ana_results.opid, lab_ana_results.batch_id, lab_ana_results.labname, lab_ana_batches_expedition.labname
--HAVING 
--lab_ana_results.labname <> lab_ana_batches_expedition.labname
ORDER BY 
lab_ana_results.opid, lab_ana_results.batch_id, lab_ana_results.labname, lab_ana_batches_expedition.labname;


--TODO check samples types and analysis request types

--}}}2

--TODO: samples batches from analysis: lab_ana_batches_reception
--}}}1
--#{{{1Analyses quality control

--#{{{2Quality Control samples: qc_sampling table
--#Different types of control samples:
SELECT opid, qc_type, count(*) FROM qc_sampling GROUP BY opid, qc_type ORDER BY qc_type;

--#Different cases: type of control samples, and refers_to empty or not; blank samples should not refer to any sample; duplicate samples should refer to a sample in dh_sampling (or qc_sampling); 
SELECT opid, qc_type, (refers_to IS NULL OR refers_to = '') AS refers_to_is_empty, count(*) FROM qc_sampling GROUP BY opid, qc_type, (refers_to IS NULL OR refers_to = '') ORDER BY opid, qc_type, refers_to IS NULL OR refers_to = '';

--#Samples found at the same time in dh_sampling and in qc_sampling:
SELECT opid, sample_id FROM dh_sampling INTERSECT SELECT opid, sample_id FROM qc_sampling;


--#{{{3Blank samples:

--#Blank samples referring to another sample:
SELECT * FROM qc_sampling WHERE qc_type = 'BLANK' AND (refers_to IS NOT NULL OR refers_to <> '');


--#{{{3Duplicate samples:

--#Duplicate samples not referring to any sample:
SELECT * FROM qc_sampling WHERE qc_type = 'DUPLICATE' AND (refers_to IS NULL OR refers_to = '');

--#Duplicate samples referring to themselves:
SELECT * FROM qc_sampling WHERE refers_to = sample_id;

--#Duplicate samples referring to a blank sample:
SELECT * FROM qc_sampling WHERE qc_type = 'DUPLICATE' AND refers_to IN (SELECT sample_id FROM qc_sampling WHERE qc_type = 'BLANK');

--#Orphan duplicate samples, referring to a sample_id not existing in dh_sampling or qc_sampling tables:
SELECT * FROM qc_sampling WHERE qc_type = 'DUPLICATE' AND (opid, refers_to) NOT IN (SELECT opid, sample_id FROM dh_sampling UNION SELECT opid, sample_id FROM qc_sampling);




--#{{{3Standard samples:

--#Table qc_standards 

--#Orphan standard samples, which have never been sent as a standard:
SELECT * FROM qc_standards WHERE (opid, qc_id) NOT IN (SELECT opid, refers_to FROM qc_sampling WHERE qc_type = 'STANDARD');


--#Orphan samples from qc_sampling not referring to a sample in qc_standards table:
SELECT * FROM qc_sampling WHERE qc_type = 'STANDARD' AND (opid, refers_to) NOT IN (SELECT opid, qc_id FROM qc_standards);

--#Orphans from qc_standards and qc_sampling, identifiers sorted:
SELECT tmp.opid, refers_to, qc_id FROM (SELECT DISTINCT opid, refers_to FROM qc_sampling WHERE qc_type = 'STANDARD') AS tmp FULL OUTER JOIN qc_standards ON (tmp.opid = qc_standards.opid AND tmp.refers_to = qc_standards.qc_id) 
WHERE tmp.refers_to IS NULL OR qc_standards.qc_id IS NULL 
ORDER BY coalesce(tmp.opid, qc_standards.opid), coalesce(tmp.refers_to, qc_standards.qc_id);



--#Standard samples with identifiers (sample_id) already used by standard sample (sample_id from dh_sampling), except for scout samples:
SELECT opid, sample_id, qc_type, refers_to FROM qc_sampling WHERE (opid, sample_id) IN (SELECT DISTINCT opid, sample_id FROM dh_sampling) AND qc_type <> 'SCOUT' ORDER BY opid, sample_id;


--#List of all duplicate samples, with reference to routine samples; the ones whose reference to duplicated sample points nowhere appear as holes in dh_sampling.sample_id column:
SELECT qc_sampling.opid, qc_sampling.sample_id, qc_type, refers_to, dh_sampling.sample_id AS sample_id_referred_to FROM qc_sampling LEFT OUTER JOIN dh_sampling ON qc_sampling.opid = dh_sampling.opid AND qc_sampling.refers_to = dh_sampling.sample_id WHERE qc_type = 'DUPLICATE' ORDER BY qc_sampling.opid, qc_sampling.sample_id, qc_sampling.refers_to;

--#List of duplicate samples referring to themselves (which should not happen!):
SELECT * FROM qc_sampling WHERE sample_id = refers_to ORDER BY opid, sample_id;

--#List of duplicate samples referring to another Quality Control sample (which is quite strange):
SELECT * FROM qc_sampling WHERE (opid, refers_to) IN (SELECT opid, sample_id FROM qc_sampling) ORDER BY opid, sample_id;


--#Duplicate quality control samples referring to nothing in dh_sampling table:
SELECT qc_sampling.* FROM qc_sampling LEFT OUTER JOIN dh_sampling ON qc_sampling.opid = dh_sampling.opid AND qc_sampling.refers_to = dh_sampling.sample_id WHERE dh_sampling.sample_id IS NULL AND qc_type NOT IN ('STANDARD', 'BLANK') ORDER BY qc_sampling.opid, qc_sampling.sample_id, qc_sampling.refers_to;



--#{{{2standards: qc_standards

--#Orphans: standard samples 
--(TODO SELECT * FROM qc_sampling WHERE qc_type <> 'DUPLICATE' AND qc_type <> 'BLANK' AND qc_type <> 'SCOUT') AS tmp;


--}}}
--}}}


--TODO depths checks:
--faire une procédure qui itère, pour chaque table, pour chaque sondage, et mette dans une table temporaire les table, id, depfrom, depto des enregistrements qui merdoient
--lancer cette procédure
--renvoyer les enregistrements de la table en sortie

--#{{{1Deviations: dh_devia

--#Strange values: bizarre angles, high temperatures, etc.
SELECT * FROM dh_devia WHERE azim_nm > 360 OR dip_hz > 90 OR azim_nm < 0 OR dip_hz < 0 OR temperature >= 100 OR roll >= 360 OR roll < 0 ORDER BY opid, id, depto;

--#Unconsistent orientations, with a different orientation in dh_devia table at 0 depth and dh_collars table:
SELECT dh_collars.opid, dh_collars.id, dh_collars.azim_ng, dh_collars.dip_hz, tmp.id, tmp.azim_ng, tmp.dip_hz 
FROM 
dh_collars 
JOIN 
(SELECT * FROM dh_devia  WHERE depto = 0) AS tmp 
ON dh_collars.opid = tmp.opid AND dh_collars.id = tmp.id 
WHERE dh_collars.azim_ng != tmp.azim_ng OR dh_collars.dip_hz != tmp.dip_hz 
ORDER BY dh_collars.opid, dh_collars.id;

--}}}




--#END}}}

--FINI; À PARTIR D'ICI, BROUILLONS---------------------------------------------
--TODO: continuer requêtes de vérification paranoïaques

--Requête pour vérifier les trous qui ont de la teneur vers le fond, donc à prolonger = trous ouverts:
--SELECT DISTINCT dh_sampling_aucy.id FROM dh_sampling_aucy JOIN dh_collars ON (dh_sampling_aucy.id = dh_collars.id) WHERE aucy > 1.5 AND dh_collars.length - depto < 2 ORDER BY dh_sampling_aucy.id;

--voyons les teneurs de ces trous ouverts:
--SELECT * FROM dh_sampling_graph_aucy WHERE id IN (SELECT DISTINCT dh_sampling_aucy.id FROM dh_sampling_aucy JOIN dh_collars ON (dh_sampling_aucy.id = dh_collars.id) WHERE aucy > 1.5 AND dh_collars.length - depto < 2 ORDER BY dh_sampling_aucy.id);







/*{{{*/

--#{{{3Lithological descriptions of trenches and drill holes: dh_litho table

--#{{{2id-depto duplicate in dh_litho

--#There should not be any duplicates:
--CREATE OR REPLACE VIEW checks.doublons_dh_litho_id_depto AS 
SELECT id, depto, COUNT(*) FROM dh_litho GROUP BY id, depto HAVING COUNT(*) > 1;

--vérification des codes litho:
--les codes litho GDM, les moins fréquents en tête:
CREATE OR REPLACE VIEW checks.codes_litho_codegdm AS 
SELECT codegdm, count_codegdm FROM (SELECT codegdm, count(*) AS count_codegdm FROM dh_litho GROUP BY codegdm) tmp ORDER BY count_codegdm;

--les codes litho GDM avec des blancs:
SELECT codegdm, strpos(codegdm, ' ') FROM dh_litho WHERE strpos(codegdm, ' ')<>0 ORDER BY codegdm;

--correspondance codes GDM et sermine:
SELECT codegdm, codeser, count(*) FROM dh_litho GROUP BY codegdm, codeser ORDER BY codegdm, codeser;

--@#faire les overlaps (pour toutes les tables de passes de sondages, d'ailleurs)




--#{{{3passes minéralisées: dh_mineralised_intervals
--passes minéralisées commençant ou finissant pas sur une cote d'échantillon:
@#à faire



--#{{{3structurales: dh_struct

--#{{{3logs techniques: dh_tech

--#{{{3passes minéralisées: dh_density

--#Densities at 0, impossible:
SELECT * FROM dh_density WHERE density <= 0 ORDER BY id, depto;


--#{{{2rapports journaliers de poste: shift_reports

--Vérifs des fichettes par rapport aux dh_collars:
(
--VAPAS information redondantes dans les fichettes incohérentes:
--1: yen a-t'il? les deux lignes doivent être pareilles:
/*SELECT nb_sondages_et_attributs FROM (SELECT count(*) AS nb_sondages_et_attributs FROM (SELECT id, planned_length, azim_ng, dip FROM shift_reports GROUP BY id, planned_length, azim_ng, dip) tmp) tmp1 UNION (SELECT count(DISTINCT id) AS nb_sondages FROM shift_reports) ;

--requête améliorable... 
--voilà:*/

--1: yen a-t'il? la différence doit être nulle:
CREATE OR REPLACE VIEW checks.fichettes_infos_redondantes_incoherentes AS 
SELECT nb_sondages_et_attributs, nb_sondages, nb_sondages_et_attributs-nb_sondages AS diff_SHOULD_BE_ZERO  FROM (SELECT count(*) AS nb_sondages_et_attributs FROM (SELECT id, planned_length, azim_ng, dip FROM shift_reports GROUP BY id, planned_length, azim_ng, dip) tmp) tmp1, (SELECT count(DISTINCT id) AS nb_sondages FROM shift_reports) tmp2 WHERE nb_sondages_et_attributs-nb_sondages <> 0;

--2: quels trous/fichettes sont concernés:
CREATE OR REPLACE VIEW checks.fichettes_infos_redondantes_incoherentes_quels_ouvrages AS 
SELECT id, min(planned_length) AS min_planned_length, max(planned_length) AS max_planned_length, (max(planned_length) - min(planned_length)) AS diff_planned_length , min(azim_ng) AS min_azim_ng, max(azim_ng) AS max_azim_ng, (max(azim_ng) - min(azim_ng)) AS diff_azim_ng, min(dip) AS min_dip, max(dip) AS max_dip, (max(dip) - min(dip)) AS diff_dip FROM shift_reports GROUP BY id HAVING (count(DISTINCT planned_length)>1 OR count(DISTINCT azim_ng)>1 OR count(DISTINCT dip)>1);


--2: quels trous/fichettes sont concernés pour les planned lengths(...):
CREATE OR REPLACE VIEW checks.fichettes_infos_redondantes_incoherentes_quels_ouvrages_planned AS 
SELECT id, min(planned_length) AS min_planned_length, max(planned_length) AS max_planned_length, (max(planned_length) - min(planned_length)) AS diff_planned_length FROM shift_reports GROUP BY id HAVING (count(DISTINCT planned_length)>1 );

--3: quels trous/fichettes sont concernés pour les orientations des sondages(...):
CREATE OR REPLACE VIEW checks.fichettes_infos_redondantes_incoherentes_quels_ouvrages_dipazi AS 
SELECT id, min(azim_ng) AS min_azim_ng, max(azim_ng) AS max_azim_ng, (max(azim_ng) - min(azim_ng)) AS diff_azim_ng, min(dip) AS min_dip, max(dip) AS max_dip, (max(dip) - min(dip)) AS diff_dip FROM shift_reports GROUP BY id HAVING (count(DISTINCT azim_ng)>1 OR count(DISTINCT dip)>1);



--VAPAS heure fin fichette antérieure à heure début
CREATE OR REPLACE VIEW checks.fichettes_infos_incoherentes_heures AS 
SELECT date, id, time_start, time_end FROM shift_reports WHERE time_start>time_end;

--VAPAS longueurs forées non cohérentes entre somme des longueurs par fichette et longueur finale sondage
CREATE OR REPLACE VIEW checks.fichettes_longueurs_incoherentes AS 
SELECT id, max_drilled_length, sum_drilled_length_during_shift FROM (SELECT id, max(drilled_length) AS max_drilled_length, sum(drilled_length_during_shift) AS sum_drilled_length_during_shift FROM shift_reports GROUP BY id ORDER BY id) tmp WHERE max_drilled_length <> sum_drilled_length_during_shift ;


--VAPAS longueurs forées différentes entre fichettes et dh_collars:
CREATE OR REPLACE VIEW checks.fichettes_vs_dh_collars_longueurs_incoherentes AS 
SELECT id, max_drilled_length, length FROM (SELECT id, max(drilled_length) AS max_drilled_length, sum(drilled_length_during_shift) AS sum_drilled_length_during_shift FROM shift_reports GROUP BY id ORDER BY id) tmp JOIN dh_collars ON (tmp.id = dh_collars.id) WHERE max_drilled_length <> length ;

--VAPAS sondages non completed:
CREATE OR REPLACE VIEW checks.fichettes_ouvrages_non_completed AS 
SELECT id, max(completed::integer) FROM shift_reports GROUP BY id HAVING max(completed::integer) <> 1;

--VAPAS somme drilled_length_during_shift <> max(drilled_length):
CREATE OR REPLACE VIEW checks.fichettes_infos_incoherentes_drilled_lengths AS 
SELECT min(no_fichette) AS first_fichette, max(no_fichette) AS last_fichette, id, SUM(drilled_length_during_shift) AS sum_drilled_length_during_shift, MAX(drilled_length) AS max_drilled_length FROM shift_reports GROUP BY id HAVING SUM(drilled_length_during_shift) <> MAX(drilled_length) ORDER BY id;

--VAPAS nb ech inconsistent avec samples_from et samples_to:
CREATE OR REPLACE VIEW checks.fichettes_infos_incoherentes_nb_samples AS 
SELECT no_fichette, id, samples_from, samples_to, (samples_to - samples_from +1) AS diff_samples_from_to, nb_samples FROM shift_reports WHERE (samples_to - samples_from +1) <> nb_samples;


--check daily reports

--diff somme longueurs forées par trou et max longueur trou
SELECT min(date) as date_start, id, max(drilled_length) as Max_drilled_length,sum(drilled_length_during_shift) as Sum_drilled_length_during_shift, max(drilled_length) - sum(drilled_length_during_shift) as Diff_should_be_zero FROM shift_reports GROUP BY id order by date_start, id;

--longueur forée par jour
SELECT date, sum(drilled_length_during_shift) as Sum_drilled_length_during_shift FROM shift_reports GROUP BY date order by date;

--moyenne sondée par jour
SELECT avg(Sum_drilled_length_during_shift) from (SELECT date, sum(drilled_length_during_shift) as Sum_drilled_length_during_shift FROM shift_reports GROUP BY date order by date) as tmp;

--trous non complétés
SELECT id FROM shift_reports WHERE completed = false GROUP BY id ORDER BY id ;

... @#à continuer
--}}}



--#{{{1géochimie

--#{{{2sédiments de ruisseaux et sols

--#{{{3échantillons: geoch_sampling

--#{{{3analyses: geoch_ana

--#{{{1échantillons de roches, affleurements ou volantes

--#{{{2échantillons: rock_sampling

--#{{{2analyses: rock_ana

--#{{{1contrôle teneurs: grade_ctrl



--#{{{1licences, permis: licences

--#{{{1indices: occurrences


--#{{{1zones, prospects: locations



--#{{{1opérations: operations



--lexique d'origine des données: lex_directory

--lexique de type d'ouvrage: lex_drill_hole_type

--lexique de labo: lex_labo_analysis

--lexique de code litho: lex_litho

/*}}}*/







--###############################################
--##           vérifications                   ##
--###############################################
--{{{
--#doublons

-- faire des vues multilingues, @#TOUDOUX
--}}}


--vues pour GDM:
CREATE OR REPLACE VIEW gdm_dh_mine_1 AS 
 SELECT dh_collars.id, dh_collars.x, dh_collars.y, dh_collars.z, dh_collars.azim_ng, dh_collars.dip_hz, dh_collars.length, dh_mineralised_intervals.depfrom, dh_mineralised_intervals.depto, dh_mineralised_intervals.avau, dh_mineralised_intervals.stva, dh_mineralised_intervals.accu,  dh_mineralised_intervals.dens
   FROM sel_loca
   LEFT JOIN dh_collars ON dh_collars.location = sel_loca.loca
   LEFT JOIN dh_mineralised_intervals ON dh_collars.id = dh_mineralised_intervals.id
   WHERE dh_mineralised_intervals.mine = 1
;


-- View: "gdm_dh_sampling"
--CREATE OR REPLACE VIEW gdm_dh_sampling AS 
-- SELECT dh_collars.id, dh_collars."location", dh_collars.shid, dh_collars.x, dh_collars.y, dh_collars.z, dh_collars.azim_ng, dh_collars.dip_hz, dh_collars.length, dh_sampling.depfrom, dh_sampling.depto, dh_sampling.num, dh_sampling.aucy, dh_sampling.dens, dh_sampling.thick
--   FROM sel_loca
--   LEFT JOIN dh_collars ON dh_collars."location"::text = sel_loca.loca::text
--   JOIN dh_sampling ON dh_collars.id::text = dh_sampling.id::text
--  ORDER BY dh_collars.id, dh_sampling.depto;


-- View: "gdm_dh_sampling_aucy"
CREATE OR REPLACE VIEW gdm_dh_sampling_aucy AS SELECT dh_collars.id, location, shid, x, y, z, azim_ng, dip_hz, length, dh_sampling_aucy.depfrom, dh_sampling_aucy.depto, dh_sampling_aucy.aucy, dh_sampling_aucy.thick  FROM sel_loca   LEFT JOIN dh_collars ON dh_collars.location = sel_loca.loca   JOIN dh_sampling_aucy ON dh_collars.id = dh_sampling_aucy.id  ORDER BY dh_collars.id, dh_sampling_aucy.depto;


-- View: "gdm_dh_sampling_base_metals"
CREATE OR REPLACE VIEW gdm_dh_sampling_base_metals AS SELECT dh_collars.id, location, shid, x, y, z, azim_ng, dip_hz, length, dh_sampling_base_metals.num, dh_sampling_base_metals.depfrom, dh_sampling_base_metals.depto, dh_sampling_base_metals.thick, dh_sampling_base_metals.au_gt, dh_sampling_base_metals.Ag_gt, dh_sampling_base_metals.Cu_pc, dh_sampling_base_metals.Zn_pc, dh_sampling_base_metals.Pb_pc, dh_sampling_base_metals.Fe_pc FROM 
--sel_loca LEFT JOIN 
dh_collars 
--ON dh_collars.location = sel_loca.loca   
JOIN dh_sampling_base_metals ON dh_collars.id = dh_sampling_base_metals.id  ORDER BY dh_collars.id, dh_sampling_base_metals.depto;



-- View: "gdm_dh_litho"
CREATE OR REPLACE VIEW gdm_dh_litho AS  SELECT dh_collars.id, dh_collars.location, dh_collars.shid, dh_collars.x, dh_collars.y, dh_collars.z, dh_collars.azim_ng, dh_collars.dip_hz, dh_collars.length, dh_litho.depfrom, dh_litho.depto, dh_litho.codegdm, dh_litho.codeser, dh_litho.oxidation, dh_litho.water, dh_litho.alter, dh_litho.weight, dh_litho.moist,  dh_litho.descr FROM sel_loca LEFT JOIN dh_collars ON dh_collars.location = sel_loca.loca JOIN dh_litho ON dh_collars.id = dh_litho.id ORDER BY dh_collars.id, dh_litho.depto;

--View: "gdm_preex_sampling"
CREATE OR REPLACE VIEW gdm_preex_sampling AS SELECT preex_sampling.* FROM sel_loca JOIN preex_sampling ON preex_sampling.id = sel_loca.loca;

/*--View: "gdm_dh_planned"
CREATE OR REPLACE VIEW gdm_dh_planned AS SELECT id, location, x, y, z, azim_ng, dip_hz, length, completed, comment, length AS depto FROM dh_collars WHERE completed<1 ORDER BY location, id;
--bof...
*/
--}}}




--###############################################
--##           vues pratiques                  ##
--###############################################
--{{{

--faisons une vue des échantillons et analyses aucy (comme avant):
--CREATE OR REPLACE VIEW dh_sampling_aucy AS SELECT id, depfrom, depto, thick, value AS aucy FROM dh_sampling LEFT JOIN dh_ana ON (dh_sampling.sampl_index = dh_ana.sampl_index) WHERE ana_type = 'aucy' ORDER BY id,depto;
--va pas, il faut les moyennes:
CREATE OR REPLACE VIEW dh_sampling_aucy AS 
 SELECT id, num, dh_sampling.sampl_index, depfrom, depto, thick, dh_ana_avg.value::numeric(10,2) AS aucy
   FROM dh_sampling
   LEFT JOIN 
	(SELECT sampl_index, avg(value) AS value
	FROM dh_ana WHERE ana_type = 'aucy' GROUP BY sampl_index) dh_ana_avg 
   ON dh_sampling.sampl_index = dh_ana_avg.sampl_index
 ORDER BY dh_sampling.id, dh_sampling.depto;




-- et une vue avec représentation des grades:
--CREATE OR REPLACE VIEW dh_sampling_graph_aucy AS SELECT id, depfrom, depto, aucy, repeat('|'::text, max((aucy * 10::numeric),10)::integer) AS graph_au FROM dh_sampling_aucy ORDER BY id, depto;
--CREATE OR REPLACE VIEW dh_sampling_graph_aucy AS SELECT id, depfrom, depto, aucy, repeat('#'::text, (least(aucy-0.1,10) * 5::numeric)::integer) AS graph_aucy FROM dh_sampling_aucy ORDER BY id, depto;
CREATE OR REPLACE VIEW dh_sampling_graph_aucy AS SELECT dh_sampling_aucy.id, dh_sampling_aucy.depfrom, dh_sampling_aucy.depto, dh_sampling_aucy.sampl_index, dh_sampling_aucy.aucy, repeat('#'::text, ((LEAST((dh_sampling_aucy.aucy - 0.1), (10)::numeric) * (5)::numeric))::integer) AS graph_aucy FROM dh_sampling_aucy ORDER BY dh_sampling_aucy.id, dh_sampling_aucy.depto;


--vue avec les points des topographes, temporaire, juste pour vérifs en carte:
CREATE OR REPLACE VIEW tmp_dh_topo_coordinates_points AS SELECT *, GeomFromEWKT('SRID=20136;POINT (' || x || ' ' || y || ' ' || z || ')') FROM tmp_dh_topo_coordinates;

--Créons une vue pour voir les pre-ex:
CREATE OR REPLACE VIEW preex_sampling_points AS SELECT *, GeomFromEWKT('SRID=20136;POINT (' || x || ' ' || y || ' ' || z || ')') FROM preex_sampling;

--échantillons de sondages en semis de points 3D @#marche pas: "La vue'public.drill_holes_samples_pts_3d' ne possède pas de colonne pour utiliser comme clef unique"
CREATE VIEW drill_holes_samples_pts_3D AS SELECT *, GeomFromEWKT('SRID=20136;POINT (' || x1 || ' ' || y1 || ' ' || z1 || ')') FROM (SELECT dh_collars.id, sampl_index, location, shid, x, y, z, azim_ng, dip_hz, length, depfrom, depto, aucy, (x + (depto * cos(dip_hz/180*pi())) * sin(azim_ng/180*pi()) ) as x1, (y + (depto * cos(dip_hz/180*pi())) * cos(azim_ng/180*pi())) as y1, (z - depto * sin(dip_hz/180*pi())) as z1 FROM dh_collars JOIN dh_sampling_aucy ON (dh_collars.id = dh_sampling_aucy.id) where utm_zone = '36N') as tmp ORDER BY id, depto;





@#JEANSUILA



--Voyons en même temps si les échantillons sont compris dans une passe minéralisée ou pas:
SELECT dh_sampling_graph_aucy.id, dh_sampling_graph_aucy.depfrom, dh_sampling_graph_aucy.depto, dh_sampling_graph_aucy.aucy, dh_mineralised_intervals.mine, dh_sampling_graph_aucy.graph_aucy FROM dh_sampling_graph_aucy LEFT OUTER JOIN dh_mineralised_intervals ON (dh_sampling_graph_aucy.id = dh_mineralised_intervals.id AND dh_sampling_graph_aucy.depto <= dh_mineralised_intervals.depto AND dh_sampling_graph_aucy.depfrom >= dh_mineralised_intervals.depfrom AND dh_mineralised_intervals.mine = 1);


--Oh,et une vue sympa avec les stretch values sous les graphiques:
--SELECT * FROM (SELECT dh_sampling_graph_aucy.*, dh_mineralised_intervals.mine, dh_sampling_graph_aucy.depto AS pied_passe_min FROM dh_sampling_graph_aucy LEFT OUTER JOIN dh_mineralised_intervals ON (dh_sampling_graph_aucy.id = dh_mineralised_intervals.id AND dh_sampling_graph_aucy.depto <= dh_mineralised_intervals.depto AND dh_sampling_graph_aucy.depfrom >= dh_mineralised_intervals.depfrom AND dh_mineralised_intervals.mine = 1)) tmp LEFT OUTER JOIN (SELECT id, depfrom,depto,avau,stva,accu FROM dh_mineralised_intervals)tmpmine ON (tmp.id = tmpmine.id AND tmp.pied_passe_min = tmpmine.depto) ORDER BY tmp.id, tmp.depto;
CREATE VIEW dh_sampling_graph_aucy_and_mineralised_intervals AS SELECT * FROM (SELECT dh_sampling_graph_aucy.*, dh_mineralised_intervals.mine, dh_sampling_graph_aucy.depto AS pied_passe_min FROM dh_sampling_graph_aucy LEFT OUTER JOIN dh_mineralised_intervals ON (dh_sampling_graph_aucy.id = dh_mineralised_intervals.id AND dh_sampling_graph_aucy.depto <= dh_mineralised_intervals.depto AND dh_sampling_graph_aucy.depfrom >= dh_mineralised_intervals.depfrom AND dh_mineralised_intervals.mine = 1)) tmp LEFT OUTER JOIN (SELECT id AS dh_min_id, depfrom AS dh_min_depfrom,depto AS dh_min_depto,avau,stva,accu FROM dh_mineralised_intervals)tmpmine ON (tmp.id = tmpmine.dh_min_id AND tmp.pied_passe_min = tmpmine.dh_min_depto) ORDER BY tmp.id, tmp.depto;




--métaux de base:
create view dh_sampling_base_metals AS
select azer.id, azer.num, azer.depfrom, azer.depto, azer.thick, Au_gt, Ag_gt, Cu_pc, Zn_pc, Pb_pc, Fe_pc from (select * from dh_sampling JOIN(select sampl_index, value AS Au_gt from dh_ana where ana_type = 'Au')Au ON (dh_sampling.sampl_index = Au.sampl_index)
LEFT JOIN(select sampl_index,  value AS Ag_gt from dh_ana where ana_type = 'Ag')Ag ON (dh_sampling.sampl_index = Ag.sampl_index)
LEFT JOIN(select sampl_index,   value AS Cu_pc from dh_ana where ana_type = 'Cu')Cu ON (dh_sampling.sampl_index = Cu.sampl_index)
LEFT JOIN(select sampl_index,   value AS Zn_pc from dh_ana where ana_type = 'Zn')Zn ON (dh_sampling.sampl_index = Zn.sampl_index)
LEFT JOIN(select sampl_index,   value AS Pb_pc from dh_ana where ana_type = 'Pb')Pb ON (dh_sampling.sampl_index = Pb.sampl_index)
LEFT JOIN(select sampl_index,   value AS Fe_pc from dh_ana where ana_type = 'Fe')Fe ON (dh_sampling.sampl_index = Fe.sampl_index))azer order by id, depto;


-- et une vue avec représentation des grades:
CREATE OR REPLACE VIEW dh_sampling_graph_base_metals AS 
SELECT dh_sampling_base_metals.id, dh_sampling_base_metals.depfrom, dh_sampling_base_metals.depto, 
dh_sampling_base_metals.Au_gt,
'Au'||repeat('u'::text, ((LEAST((Au_gt - 0.1), (10)::numeric) * (5)::numeric))::integer) AS graph_au,
dh_sampling_base_metals.Ag_gt,
'Ag'||repeat('g'::text, ((LEAST((coalesce(Ag_gt,0) - 0.1)/10, (10)::numeric) * (5)::numeric))::integer) AS graph_ag,
dh_sampling_base_metals.Cu_pc,
'Cu'||repeat('u'::text, ((LEAST((Cu_pc - 0.1), (10)::numeric) * (5)::numeric))::integer) AS graph_cu,
dh_sampling_base_metals.Pb_pc,
'Pb'||repeat('b'::text, ((LEAST((coalesce(Pb_pc,0) - 0.1), (10)::numeric) * (5)::numeric))::integer) AS graph_pb,
dh_sampling_base_metals.Zn_pc,
'Zn'||repeat('n'::text, ((LEAST((Zn_pc - 0.1)/2, (10)::numeric) * (5)::numeric))::integer) AS graph_zn,
dh_sampling_base_metals.Fe_pc,
'Fe'||repeat('e'::text, ((LEAST((coalesce(Fe_pc,0) - 0.1)/10, (10)::numeric) * (5)::numeric))::integer) AS graph_fe
FROM dh_sampling_base_metals ORDER BY dh_sampling_base_metals.id, dh_sampling_base_metals.depto;
--}}}





--###############################################
--##     calculs de passes minéralisées        ##
--###############################################
--{{{


--regardons les teneurs:
SELECT * FROM dh_sampling_graph_aucy WHERE id LIKE 'UMA_R%';

/*
UPDATE dh_mineralised_intervals SET stva = TMPRE.stretch_value, avau = TMPRE.avg_au, accu=TMPRE.accu FROM (
SELECT TMP.id, TMP.depfrom, TMP.depto, 
to_char(mineralised_length, '99990.99 m @ ') || to_char(avg_au, '99990.99') || ' g/t AuCy' as stretch_value, avg_au,
accu
FROM (
SELECT dh_mineralised_intervals.id, dh_mineralised_intervals.depfrom, dh_mineralised_intervals.depto, sum(dh_sampling_aucy.aucy), count(dh_sampling_aucy.aucy),
sum(aucy*(dh_sampling_aucy.depto - dh_sampling_aucy.depfrom)) as accu,
sum(dh_sampling_aucy.depto - dh_sampling_aucy.depfrom) as mineralised_length,
sum(aucy*(dh_sampling_aucy.depto - dh_sampling_aucy.depfrom)) /
sum(dh_sampling_aucy.depto - dh_sampling_aucy.depfrom) as avg_au

from dh_sampling_aucy, dh_mineralised_intervals WHERE dh_mineralised_intervals.id LIKE 'UMA_R%' and (dh_mineralised_intervals.id = dh_sampling_aucy.id and (dh_mineralised_intervals.depto >= dh_sampling_aucy.depto and dh_mineralised_intervals.depfrom <= dh_sampling_aucy.depfrom))
GROUP BY dh_mineralised_intervals.id,dh_mineralised_intervals.depfrom,dh_mineralised_intervals.depto

) AS TMP )
AS TMPRE where dh_mineralised_intervals.id = TMPRE.id and dh_mineralised_intervals.depfrom = TMPRE.depfrom and dh_mineralised_intervals.depto = TMPRE.depto  ;

*/

/*UPDATE dh_mineralised_intervals SET stva = TMPRE.stretch_value, avau = TMPRE.avg_au, accu=TMPRE.accu FROM (
SELECT TMP.id, TMP.depfrom, TMP.depto, 
to_char(mineralised_length, '99990.99 m @ ') || trim(to_char(avg_au, '99990.99')) || ' g/t AuCy' as stretch_value, avg_au,
accu
FROM (
SELECT dh_mineralised_intervals.id, dh_mineralised_intervals.depfrom, dh_mineralised_intervals.depto, sum(dh_sampling_aucy.aucy), count(dh_sampling_aucy.aucy),
sum(aucy*(dh_sampling_aucy.depto - dh_sampling_aucy.depfrom)) as accu,
sum(dh_sampling_aucy.depto - dh_sampling_aucy.depfrom) as mineralised_length,
sum(aucy*(dh_sampling_aucy.depto - dh_sampling_aucy.depfrom)) /
sum(dh_sampling_aucy.depto - dh_sampling_aucy.depfrom) as avg_au

from dh_sampling_aucy, dh_mineralised_intervals WHERE dh_mineralised_intervals.id LIKE 'UMA_R%' and (dh_mineralised_intervals.id = dh_sampling_aucy.id and (dh_mineralised_intervals.depto >= dh_sampling_aucy.depto and dh_mineralised_intervals.depfrom <= dh_sampling_aucy.depfrom))
GROUP BY dh_mineralised_intervals.id,dh_mineralised_intervals.depfrom,dh_mineralised_intervals.depto

) AS TMP )
AS TMPRE where dh_mineralised_intervals.id = TMPRE.id and dh_mineralised_intervals.depfrom = TMPRE.depfrom and dh_mineralised_intervals.depto = TMPRE.depto  ;
*/
UPDATE dh_mineralised_intervals SET stva = TMPRE.stretch_value, avau = TMPRE.avg_au, accu=TMPRE.accu FROM (SELECT TMP.id, TMP.depfrom, TMP.depto, replace(to_char(mineralised_length, 'FM99990.99 m @ '),'. m @ ',' m @ ') || trim(replace(to_char(avg_au, 'FM9999990.99 '), '. ', ' ')) || ' g/t AuCy' AS stretch_value, avg_au,accu FROM (SELECT dh_mineralised_intervals.id, dh_mineralised_intervals.depfrom, dh_mineralised_intervals.depto, sum(dh_sampling_aucy.aucy), count(dh_sampling_aucy.aucy),sum(aucy*(dh_sampling_aucy.depto - dh_sampling_aucy.depfrom)) as accu, sum(dh_sampling_aucy.depto - dh_sampling_aucy.depfrom) as mineralised_length, sum(aucy*(dh_sampling_aucy.depto - dh_sampling_aucy.depfrom)) / sum(dh_sampling_aucy.depto - dh_sampling_aucy.depfrom) as avg_au FROM dh_sampling_aucy, dh_mineralised_intervals WHERE dh_mineralised_intervals.stva IS NULL AND (dh_mineralised_intervals.id = dh_sampling_aucy.id AND (dh_mineralised_intervals.depto >= dh_sampling_aucy.depto and dh_mineralised_intervals.depfrom <= dh_sampling_aucy.depfrom)) GROUP BY dh_mineralised_intervals.id,dh_mineralised_intervals.depfrom,dh_mineralised_intervals.depto) AS TMP) AS TMPRE WHERE dh_mineralised_intervals.id = TMPRE.id AND dh_mineralised_intervals.depfrom = TMPRE.depfrom AND dh_mineralised_intervals.depto = TMPRE.depto;

UPDATE dh_collars SET accusum = accusum_calcul FROM (SELECT id, sum(dh_sampling_aucy.aucy) AS accusum_calcul FROM dh_sampling_aucy  WHERE aucy > 0.5 GROUP BY id) tmp WHERE tmp.id = dh_collars.id;


/*Calculons les ACCUs pour les dh_collars:(
	CALCUL_ACCUSUM_01
		SELECT ID, SUM((DEPTO-DEPFROM)*AUCY) AS ACCUSUM_calcul FROM DH_SAMPLING WHERE AUCY > 1.5 GROUP BY ID;
	CALCUL_ACCUSUM_02
		SELECT CALCUL_ACCUSUM_01.* INTO tmp_accusum FROM CALCUL_ACCUSUM_01;
	CALCUL_ACCUSUM_03
		UPDATE dh_collars INNER JOIN tmp_accusum ON dh_collars.ID = tmp_accusum.ID SET dh_collars.ACCUSUM = [tmp_accusum].[ACCUSUM_calcul];





	SELECT dh_collars.ID,SUM((DEPTO-DEPFROM)*AUCY) AS ACCUSUM FROM dh_collars INNER JOIN DH_SAMPL ON (dh_collars.ID=DH_SAMPL.ID) WHERE AUCY > 1.5 GROUP BY dh_collars.ID
	UPDATE dh_collars SET ACCUSUM=SUM((DEPTO-DEPFROM)*AUCY) 

)*/
--}}}


--###############################################
--##  000.  POUBELLE                           ##
--###############################################
--{{{
COPY dh_collars TO '/tmp/dh_collars.csv' WITH CSV HEADER;
COPY dh_litho TO '/tmp/dh_litho.csv' WITH CSV HEADER;
COPY dh_mineralised_intervals TO '/tmp/dh_mineralised_intervals.csv' WITH CSV HEADER;
COPY dh_sampling TO '/tmp/dh_sampling .csv' WITH CSV HEADER;
COPY dh_tech TO '/tmp/dh_tech.csv' WITH CSV HEADER;
COPY geometry_columns TO '/tmp/geometry_columns.csv' WITH CSV HEADER;
COPY preex_sampling TO '/tmp/preex_sampling.csv' WITH CSV HEADER;
COPY sel_loca TO '/tmp/sel_loca.csv' WITH CSV HEADER;


COPY dh_collars TO 'c:\\tmp\\dh_collars.csv' WITH CSV HEADER;
COPY dh_litho TO 'c:\\tmp\\dh_litho.csv' WITH CSV HEADER;
COPY dh_mineralised_intervals TO 'c:\\tmp\\dh_mineralised_intervals.csv' WITH CSV HEADER;
COPY dh_sampling TO 'c:\\tmp\\dh_sampling .csv' WITH CSV HEADER;
COPY dh_tech TO 'c:\\tmp\\dh_tech.csv' WITH CSV HEADER;
COPY geometry_columns TO 'c:\\tmp\\geometry_columns.csv' WITH CSV HEADER;
COPY preex_sampling TO 'c:\\tmp\\preex_sampling.csv' WITH CSV HEADER;
COPY sel_loca TO 'c:\\tmp\\sel_loca.csv' WITH CSV HEADER;

--###############################################
--##  100.  DONE                               ##
--###############################################
--{{{
ALTER TABLE dh_ana RENAME echant_index TO sampl_index;
--}}}

--###############################################
--##           changements                     ##
--###############################################
--cf. bd_amc_scripts_sql_CHANGEMENTS.txt

--###############################################
--##    0.  TOUDOUX                            ##
--##        --(done)   --> 100. DONE           ##
--###############################################
--{{{
--}}}

--###############################################
--##     1.    import de data dans la bd       ##
--###############################################
--{{{
--sauvegarde sur ma clé depuis linux:
pg_dump -O -h localhost -f bdamc.backup amc
cp bdamc.backup /mnt/disqusb1
(ou
cp bdamc.backup /media/EXPLOPIERRE/
)

--restauration depuis ma clé sous windows:
--RAZ bd amc
DROP DATABASE amc_bak;
ALTER DATABASE amc RENAME TO amc_bak;

CREATE DATABASE amc WITH TEMPLATE=template_postgis ENCODING='UTF8'OWNER=pierre;
@#NB: voilà la bonne méthode: (
CREATE DATABASE amc WITH TEMPLATE=template_postgis ENCODING='UTF8'OWNER=pierre;
psql amc -f sauvg_bd_blackbox.backup
	ou:
pg_restore -d amc /mnt/disqusb1/2008_04_02_bd_amc.backup 
)

--import dos (à adapter)

	alter database amc rename to amc_AAAA_MM_JJ;
	CREATE DATABASE amc WITH TEMPLATE=template_postgis ENCODING='UTF8'OWNER=pierre;


cd là où il faut
"c:\Program Files\PostgreSQL\8.2\bin\pg_restore.exe" -i -h localhost -p 5432 -U pierre -d amc -v "bdamc.backup"
	/*---> mis dans 
	H:\__data__\bd_managt\restaure_bd_js.bat
	que je mets dans le bon répertoire (mrd de windob, faut que je fasse un util ou bin dans le path) avec le féchier nommé comme il faut, ça le fait tout seul.
	*/


--import linux (à adapter)
cd hassai/from_jseb/200
pg_restore -i -h localhost -p 5432 -U pierre -d amc -v bdamc.backup
--}}}

--###############################################
--##           comparaisons, après import      ##
--###############################################
--{{{
--Comparons, voir:
--	dh_collars:
--		dans amc:
			COPY (SELECT id, location, sector, shid, profile, utm_zone, x, y, z, azim_ng, dip_hz, length, len_destr, len_pq, len_hq, len_nq, type, completed, accusum, samples, comment, old_flid, problems, export, len_bq, numauto, deviation, start_date, driller, azim_nm, directory FROM dh_collars ORDER BY id) TO 'c:/tmp/amc_dh_collars.csv' WITH CSV HEADER;
		dans le backup d'amc, en l'occurence amc_2008_03_14:
			COPY (SELECT id, location, sector, shid, profile, utm_zone, x, y, z, azim_ng, dip_hz, length, len_destr, len_pq, len_hq, len_nq, type, completed, accusum, samples, comment, old_flid, problems, export, len_bq, numauto, deviation, start_date, driller, azim_nm, directory FROM dh_collars ORDER BY id) TO 'c:/tmp/amc_dh_collars_AAA_MM_JJ.csv' WITH CSV HEADER;
--		Puis:
--			gvimdiff c:\tmp\amc_dh_collars.csv c:\tmp\amc_dh_collars_AAAA_MM_JJ.csv
--	Au quai, juste une différence, réglée par:
--		UPDATE dh_collars set length = 68.5 WHERE id = 'HASN_R049';

--	shift_reports:
			COPY (SELECT date, geologist, time_start, time_end, id, drilled_length_during_shift, drilled_length, planned_length, completed, x, y, z, azim_ng, dip, samples_from, samples_to, nb_samples, quartering, comments, no_fichette, rig FROM shift_reports ORDER BY no_fichette) TO 'c:/tmp/amc_shift_reports.csv' WITH CSV HEADER;
--		dans le backup d'amc, en l'occurence amc_2008_03_14:
			COPY (SELECT date, geologist, time_start, time_end, id, drilled_length_during_shift, drilled_length, planned_length, completed, x, y, z, azim_ng, dip, samples_from, samples_to, nb_samples, quartering, comments, no_fichette, rig FROM shift_reports ORDER BY no_fichette) TO 'c:/tmp/amc_shift_reports_AAAA_MM_JJ.csv' WITH CSV HEADER;
--		Puis:
--			gvimdiff c:\tmp\amc_shift_reports.csv c:\tmp\amc_shift_reports_AAAA_MM_JJ.csv
--			Là, plein de diffs; vaut mieux être bestial:
--			DELETE FROM shift_reports;
--			COPY shift_reports (date, geologist, time_start, time_end, id, drilled_length_during_shift, drilled_length, planned_length, completed, x, y, z, azim_ng, dip, samples_from, samples_to, nb_samples, quartering, comments, no_fichette, rig) FROM 'c:/tmp/amc_shift_reports_AAAA_MM_JJ.csv' WITH CSV HEADER;
--			Impecc!
--}}}


--###############################################
--##           exports de data de la bd        ##
--###############################################
--{{{
--dh_collars pour carter avec mapinforme:
COPY dh_collars TO 'h:/__data__/gis/dh_collars_export_postgresql.csv' WITH CSV HEADER;--on dirait que le lecteur SUBSTitué ne plait pas à PostgreSQL...




--je sauve en ascii tout:
--(faut que je sois superutilisateur:
ALTER ROLE pierre superuser valid until '2010-07-18 01:00:00';
	
--Voilà pour toutes les tables intéressantes:
--sauvg_bd_dans_tmp_csv.sql
--(
--###  pour linux:  ###
COPY dh_collars TO '/tmp/dh_collars.csv' WITH CSV HEADER;
COPY dh_ana TO '/tmp/.dh_ana.csv' WITH CSV HEADER;
COPY dh_devia TO '/tmp/dh_devia.csv' WITH CSV HEADER;
COPY dh_litho TO '/tmp/dh_litho.csv' WITH CSV HEADER;
COPY dh_mineralised_intervals TO '/tmp/dh_mineralised_intervals.csv' WITH CSV HEADER;
COPY dh_sampling TO '/tmp/dh_sampling.csv' WITH CSV HEADER;
COPY dh_struct TO '/tmp/dh_struct.csv' WITH CSV HEADER;
COPY dh_tech TO '/tmp/dh_tech.csv' WITH CSV HEADER;
COPY shift_reports TO '/tmp/shift_reports.csv' WITH CSV HEADER;
COPY geoch_ana TO '/tmp/geoch_ana.csv' WITH CSV HEADER;
COPY geoch_sampling TO '/tmp/geoch_sampling.csv' WITH CSV HEADER;
COPY geometry_columns TO '/tmp/geometry_columns.csv' WITH CSV HEADER;
COPY preex_sampling TO '/tmp/preex_sampling.csv' WITH CSV HEADER;
COPY qaqc TO '/tmp/qaqc.csv' WITH CSV HEADER;
COPY qaqc_ana TO '/tmp/qaqc_ana.csv' WITH CSV HEADER;
COPY sel_loca TO '/tmp/sel_loca.csv' WITH CSV HEADER;
COPY topo_points TO '/tmp/topo_points.csv' WITH CSV HEADER;

--###  pour dos:  ###


--marche pas... COPY dh_collars TO 'h:/__data__/bd_sauvegardes/' || current_date::text || 'dh_collars.csv' WITH CSV HEADER;
COPY dh_collars TO 'c:/tmp/dh_collars.csv' WITH CSV HEADER;
COPY dh_ana TO 'c:/tmp/dh_ana.csv' WITH CSV HEADER;
COPY dh_devia TO 'c:/tmp/dh_devia.csv' WITH CSV HEADER;
COPY dh_litho TO 'c:/tmp/dh_litho.csv' WITH CSV HEADER;
COPY dh_mineralised_intervals TO 'c:/tmp/dh_mineralised_intervals.csv' WITH CSV HEADER;
COPY dh_sampling TO 'c:/tmp/dh_sampling.csv' WITH CSV HEADER;
COPY dh_struct TO 'c:/tmp/dh_struct.csv' WITH CSV HEADER;
COPY dh_tech TO 'c:/tmp/dh_tech.csv' WITH CSV HEADER;
COPY shift_reports TO 'c:/tmp/shift_reports.csv' WITH CSV HEADER;
COPY geoch_ana TO 'c:/tmp/geoch_ana.csv' WITH CSV HEADER;
COPY geoch_sampling TO 'c:/tmp/geoch_sampling.csv' WITH CSV HEADER;
COPY geometry_columns TO 'c:/tmp/geometry_columns.csv' WITH CSV HEADER;
COPY preex_sampling TO 'c:/tmp/preex_sampling.csv' WITH CSV HEADER;
COPY qaqc TO 'c:/tmp/qaqc.csv' WITH CSV HEADER;
COPY qaqc_ana TO 'c:/tmp/qaqc_ana.csv' WITH CSV HEADER;
COPY sel_loca TO 'c:/tmp/sel_loca.csv' WITH CSV HEADER;
COPY topo_points TO 'c:/tmp/topo_points.csv' WITH CSV HEADER;

--)

--12/11/07
--Préparation data de la bd en csv pour Maxime:
COPY dh_collars TO 'c:\\tmp\\dh_collars.csv' WITH CSV HEADER;
COPY dh_litho TO 'c:\\tmp\\dh_litho.csv' WITH CSV HEADER;
COPY dh_mineralised_intervals TO 'c:\\tmp\\dh_mineralised_intervals.csv' WITH CSV HEADER;
COPY dh_sampling TO 'c:\\tmp\\dh_sampling .csv' WITH CSV HEADER;
COPY dh_tech TO 'c:\\tmp\\dh_tech.csv' WITH CSV HEADER;
COPY geometry_columns TO 'c:\\tmp\\geometry_columns.csv' WITH CSV HEADER;
COPY preex_sampling TO 'c:\\tmp\\preex_sampling.csv' WITH CSV HEADER;
COPY sel_loca TO 'c:\\tmp\\sel_loca.csv' WITH CSV HEADER;







--}}} FIN POUBELLE
--}}}


--###############################################
--##  000.  METTRE AILLEURS                    ##
--###############################################

--accumulations sur dh_collars:
CREATE OR REPLACE VIEW dh_collars_accu_sum_aucy_sup_0_5 AS (SELECT * FROM dh_collars_points JOIN (SELECT id as tmpid, sum(aucy)::int as sumaucy_sup_0_5 FROM dh_sampling_aucy WHERE aucy > 0.5 group by id) tmp ON dh_collars_points.id = tmp.tmpid);


--###############################################
--##    0.5 PROGRAMME SONDAGES                 ##
--###############################################
--{{{
--Les sondages programmés restant à faire:
SELECT location, id, x, y, z, azim_nm, azim_ng, dip_hz, length FROM dh_collars WHERE NOT completed  ORDER BY location, id;

--combien de mètres il reste à sonder:
SELECT sum(length) AS length_to_drill FROM dh_collars WHERE NOT completed;
--idem par type de sondage:
SELECT dh_type, sum(length) AS length_to_drill FROM dh_collars WHERE NOT completed  GROUP BY dh_type;
--idem par objectif:
SELECT location, sum(length) AS length_to_drill FROM dh_collars WHERE NOT completed  GROUP BY location ORDER BY location;
--idem par objectif et type de sondage:
SELECT location, dh_type, sum(length) AS length_to_drill FROM dh_collars WHERE NOT completed GROUP BY location, dh_type ORDER BY location, dh_type DESC;


--Voilà. Comme ça, ça me fait une requête pour voir ce qui me reste de prêt à sonder:
--foré / à forer, métrages, par type de sondages
SELECT completed, dh_type, sum(length) FROM dh_collars GROUP BY completed, dh_type ORDER BY completed DESC, dh_type;
--à implanter, puis forer
SELECT id, location, /*sector, utm_zone*/ srid, x, y, z, length, dip_hz, azim_ng, dh_type, profile, completed, comments FROM dh_collars WHERE NOT completed ORDER BY location, id;
--}}}


--###############################################
--##           statistiques                    ##
--###############################################
--{{{
--statistiques sondages
--STATS QUOTIDIENNES AVANCEMENTS SONDAGES -------------------------------------
--un peu amélioré, avec le nombre de sondages par jour, le métrage, premier et dernier trou:
--@#faire une sortie vers un html et mettre dans crontab
DROP VIEW stats_quotidiennes_avancements_sondages;
CREATE OR REPLACE VIEW stats_reports.stats_quotidiennes_avancements_sondages AS
SELECT date, rig, sum(drilled_length_during_shift) as drilled_length_per_day, repeat('|'::text, (sum(drilled_length_during_shift)/10)::integer) AS graph_drilled_length_per_day, count(DISTINCT id) AS nb_drill_holes, min(id) AS first_dh, max(id) AS last_dh from shift_reports group by rig, date order by date, rig;



--Stats mensuelles ____________________________________________________________
--pour les fameux tableaux de synthèse: (à compléter):
SELECT
extract(year from start_date) AS YEAR, dh_collars.id AS DH_NUMBER, start_date, profile, x, y, z, azim_ng, dip_hz, len_destr AS length_destr, (coalesce ((coalesce(len_pq,0) + coalesce(len_hq,0) + coalesce(len_nq,0) + coalesce(len_bq,0)),0)) as len_core, length AS total_length, nb_samples, NULL, NULL, depfrom, depto, stva, accu
FROM 
dh_collars 
LEFT OUTER JOIN dh_mineralised_intervals ON dh_collars.id = dh_mineralised_intervals.id
ORDER BY extract(year from start_date), dh_collars.ID, dh_mineralised_intervals.depto
;


CREATE OR REPLACE VIEW stats_reports.avancements_sondages_stats_mensuelles AS 
SELECT year, month, sum(drilled_length_during_shift) as drilled_length_during_month, sum(tmp.nb_samples) AS nb_samples_during_month FROM (SELECT extract(year from date) as year, extract(month from date) as month, drilled_length_during_shift, nb_samples FROM shift_reports) AS tmp GROUP BY year,month ORDER BY year, month;


--et avec l'outil de foration, aussi, tank à fer:
CREATE OR REPLACE VIEW stats_reports.avancements_sondages_stats_mensuelles_outil_foration AS 
 SELECT year, month, tool, sum(drilled_length_during_shift) as drilled_length_during_month, sum(tmp.nb_samples) AS nb_samples_during_month
 FROM 
 (
  SELECT extract(year from date) as year, extract (month from date) as month, tool, nb_samples, drilled_length_during_shift 
  FROM shift_reports
 ) AS tmp 
 GROUP BY year,month, tool ORDER BY year, month, tool;


--idem, avec location:
CREATE OR REPLACE VIEW stats_reports.avancements_sondages_stats_mensuelles_par_objectif AS 
SELECT year, month, target, sum(drilled_length_during_shift) as drilled_length_during_month FROM (SELECT extract(year from date) as year, extract (month from date) as month, drilled_length_during_shift, split_part (id, '_', 1) as target FROM shift_reports) AS tmp GROUP BY year,month, target ORDER BY year, month;


--pour vérifier la facturation:
CREATE OR REPLACE VIEW stats_reports.verif_facturation_sondeur AS 
SELECT invoice_nr, rig, tool, SUM(drilled_length_during_shift) FROM shift_reports WHERE (invoice_nr <>NULL OR invoice_nr >0) GROUP BY invoice_nr, rig, tool ORDER BY invoice_nr, rig, tool DESC;


--stats annuelles
CREATE OR REPLACE VIEW stats_reports.avancements_sondages_stats_annuelles AS 
SELECT year, sum(drilled_length_during_shift) as drilled_length_during_year FROM (SELECT extract(year from date) as year, drilled_length_during_shift FROM shift_reports) AS tmp GROUP BY year ORDER BY year;

--idem, avec location:
CREATE OR REPLACE VIEW stats_reports.avancements_sondages_stats_annuelles_par_objectif AS 
SELECT year, target, sum(drilled_length_during_shift) as drilled_length_during_month FROM (SELECT extract(year from date) as year, extract (month from date) as month, drilled_length_during_shift, split_part (id, '_', 1) as target FROM shift_reports) AS tmp GROUP BY year, target ORDER BY year;


--longueur explorée par location
CREATE OR REPLACE VIEW stats_reports.longueur_exploree_par_location AS 
select location,sum(length) from dh_collars group by location order by location;

--longueur explorée par location et type
CREATE OR REPLACE VIEW stats_reports.longueur_exploree_par_location_et_type AS 
select location,dh_type,sum(length) from dh_collars group by location,dh_type order by location,dh_type DESC;

--longueur explorée par type (en kilomètres):
CREATE OR REPLACE VIEW stats_reports.longueur_exploree_par_type_km AS 
select dh_type,sum(length)/1000 as km_explored_length from dh_collars group by dh_type order by dh_type DESC;

--graphe avec les longueurs forées:
CREATE OR REPLACE VIEW stats_reports.longueurs_forees_graphe AS 
SELECT date, sum(drilled_length_during_shift) as drilled_length_per_day, repeat('|'::text, (sum(drilled_length_during_shift)/10)::integer) AS graph from shift_reports group by date order by date;


--idem avec les targets:
CREATE OR REPLACE VIEW stats_reports.longueurs_forees_graphe_par_objectif AS 
SELECT date, sum(drilled_length_during_shift) as drilled_length_per_day, min(substr(id,1,4)) AS target,repeat('|'::text, (sum(drilled_length_during_shift)/10)::integer) AS graph from shift_reports group by date order by date;


--pour les bonus, voir la productivité, etc.:
--moyenne, par mois, des longueurs forées par jour @#(faudra faire ça par machine, sinon, c'est pas comparable):
SELECT year, month, avg(drilled_length_per_day) AS average_drilled_length_per_day FROM (SELECT date, extract(year from date) as year, extract (month from date) as month, sum(drilled_length_during_shift) as drilled_length_per_day, repeat('|'::text, (sum(drilled_length_during_shift)/10)::integer) AS graph from shift_reports group by date order by date) tmp GROUP BY year, month ORDER BY year, month;


--moyenne des longueurs forées par jour, rapportées au mois: pour comparer avec la performance:
SELECT avg(average_drilled_length_per_day ) FROM (SELECT year, month, avg(drilled_length_per_day) AS average_drilled_length_per_day FROM (SELECT date, extract(year from date) as year, extract (month from date) as month, sum(drilled_length_during_shift) as drilled_length_per_day, repeat('|'::text, (sum(drilled_length_during_shift)/10)::integer) AS graph from shift_reports group by date order by date) tmp GROUP BY year, month ORDER BY year, month) tmp2;

--course des sondeurs et trancheurs:
SELECT DISTINCT driller,  sum(length) FROM dh_collars GROUP BY driller;
SELECT DISTINCT driller, dh_type, sum(length) FROM dh_collars GROUP BY driller, dh_type;


--Quel trou a fait quelle machine
SELECT rig, id from shift_reports GROUP BY rig, id  order by rig, id ;

--}}}







--###############################################
--##     remettre ailleurs                     ##
--###############################################
--vérification des attachements journaliers du sondeur:
DROP VIEW stats_reports.verif_attachements_journaliers_sondeur ;
CREATE OR REPLACE VIEW stats_reports.verif_attachements_journaliers_sondeur AS 
SELECT rig, date, sum(drilled_length_during_shift) as drilled_length_per_day, repeat('|'::text, (sum(drilled_length_during_shift)/10)::integer) AS graph_drilled_length_per_day, count(DISTINCT id) AS nb_drill_holes, min(id) AS first_dh, max(id) AS last_dh from shift_reports group by rig, date order by rig, date;

}}}
