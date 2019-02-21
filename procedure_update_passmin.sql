--###PROCEDURE_UPDATE_PASSMIN: Procédure pour màj passes minéralisées### (correction: teneurs négatives zérotées): /*{{{*/

UPDATE public.dh_mineralised_intervals 
SET stva = tmp2.stretch_value, avau = tmp2.avg_au, accu=tmp2.accu
 FROM (

------------------------------------------------

  SELECT 
   tmp.opid, tmp.id, tmp.depfrom, tmp.depto, tmp.mine,
   replace(to_char(mineralised_length, 'FM99990.99 m @ '),'. m @ ',' m @ ') || trim(replace(to_char(avg_au, 'FM9999990.99 '), '. ', ' ')) || ' g/t Au' AS stretch_value, avg_au,accu 
   FROM (
    SELECT 
     dh_mineralised_intervals.opid, dh_mineralised_intervals.id, dh_mineralised_intervals.depfrom, dh_mineralised_intervals.depto, dh_mineralised_intervals.mine, sum(dh_sampling_au.au_ppm), count(dh_sampling_au.au_ppm),
     sum(au_ppm*(dh_sampling_au.depto - dh_sampling_au.depfrom)) as accu, 
     sum(dh_sampling_au.depto - dh_sampling_au.depfrom) as mineralised_length, 
     sum(au_ppm*(dh_sampling_au.depto - dh_sampling_au.depfrom)) / sum(dh_sampling_au.depto - dh_sampling_au.depfrom) as avg_au 
     FROM 
      (
      -- c'est ici qu'on choisit le champ au à moyenner
      SELECT *, greatest(0, au6_ppm) AS au_ppm FROM dh_sampling_grades
      WHERE sample_type IS NULL OR sample_type NOT IN ('DUP', 'NS')
      )
      AS dh_sampling_au
      , dh_mineralised_intervals 
      WHERE 
       dh_mineralised_intervals.stva IS NULL 
      AND 
       (dh_mineralised_intervals.opid = dh_sampling_au.opid 
        AND dh_mineralised_intervals.id = dh_sampling_au.id 
        AND (
         dh_mineralised_intervals.depto >= dh_sampling_au.depto 
         AND 
         dh_mineralised_intervals.depfrom <= dh_sampling_au.depfrom
        )
       ) 
     GROUP BY dh_mineralised_intervals.opid, dh_mineralised_intervals.id, dh_mineralised_intervals.depfrom, dh_mineralised_intervals.depto, dh_mineralised_intervals.mine
   )
  AS tmp

-----------------------------------------------------

 ) 
 AS tmp2 
 WHERE 
  dh_mineralised_intervals.opid = tmp2.opid 
  AND dh_mineralised_intervals.id = tmp2.id 
  AND dh_mineralised_intervals.depfrom = tmp2.depfrom 
  AND dh_mineralised_intervals.depto = tmp2.depto
  AND dh_mineralised_intervals.mine = tmp2.mine;
/*}}}*/

