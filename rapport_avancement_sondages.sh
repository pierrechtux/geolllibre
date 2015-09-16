horodate=`date +%Y_%m_%d_%Hh%M`

filename1=sondages_tetes_$horodate.csv
sql2csv "SELECT id, date_start AS date_début, date_completed AS date_fin, x, y, z, azim_ng AS azimut_ng, dip_hz AS plongement, length AS longueur, len_destr AS long_destructif, len_pq AS long_PQ, len_hq AS long_HQ, completed::integer AS fini, comments AS commentaires FROM dh_collars WHERE opid = 18 AND (id ILIKE 'I%' OR id ILIKE 'S%' OR id ILIKE 'PJ%') ORDER BY date_start, id" > $filename1
filename2=sondages_echantillons_teneurs_$horodate.csv
sql2csv "SELECT id, depfrom, depto, mineralised_interval, sample_id, weight_kg AS poids_kg, core_loss_cm AS perte_k_cm, aumaxi_ppm, graph_aumaxi FROM dh_sampling_mineralised_intervals_graph_au6 WHERE opid = 18 ORDER BY id, depto" > $filename2
filename3=sondages_passes_mineralisees_$horodate.csv
sql2csv "SELECT id, depfrom, depto, mine, depto - depfrom AS longueur, avau AS moyenne_au_ppm, stva AS passe_mineraliseee, accu FROM dh_mineralised_intervals WHERE opid = 18 AND mine = 0 ORDER BY id, depto" > $filename3

ls -trlh | tail -3
oocalc $filename1
oocalc $filename2
oocalc $filename3

