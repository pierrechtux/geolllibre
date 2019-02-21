#!/usr/bin/env python
# -*-coding=utf-8
"""
Je fais un script traitant d'un seul coup les résultats analytiques de Veritas:
Je fais ça en pseudo-code, converti en python

31_10_2012__10_41_45: je reprends ça, avec le nouveau format .csv que fournit veritas.
"""

 # import des fichiers analytiques de bureau veritas directement dans la bd:/*{{{*/

import os, sys, csv, string, psycopg2
# paramètres:/*{{{*/
# file_in = '/home/pierre/smi/transferts/from/polU/2012_10_31/u100133.csv'
opid = 18
labname = 'VERITAS'
scheme = 'FA001'
analyte = 'AU'
unit = 'PPM'

dbname  = 'bdexplo'
dbhost  = 'autan'
user    = 'pierre'
# /*}}}*/



####################################
# un argument en fin de ligne de commande? ## MODIF pour prendre plus de 2 arguments;
#                                          ## pour pouvoir mettre "python" en premier sur la ligne de commande
if len(sys.argv) >= 2:
    # oui: on définit le fichier comme le dernier argument:
    # file_in = sys.argv[1]
    file_in = sys.argv[len(sys.argv) -1]

else:
    # non: on demande le fichier à traiter:
    file_in = raw_input("Rien en argument.\nNom du fichier à traiter: ")

# on vérifie que ce soit un fichier:
try:
    test = open(file_in, 'r')
    # auquel cas, on le traite:
    path = os.getcwd()
    test.close()
except:
    print("Non, ça le fait pas, erreur en essayant d'ouvrir %s." % file_in)
    sys.exit(1)


# si on est arrivé jusqu'ici, c'est qu'on a un nom de fichier et un chemin.

# Il est temps de se connecter à la base: on fait une connexion et un curseur:/*{{{*/
# Connect to an existing database
conn = psycopg2.connect(database=dbname, user=user, host=dbhost)
#conn = psycopg2.connect(database=dbname, user=user, host=dbhost, password=passw)

# Open a cursor to perform database operations
cur = conn.cursor()
# /*}}}*/
# Définition d'un nouveau datasource:/*{{{*/
sql_string = "INSERT INTO public.lex_datasource (opid, filename, datasource_id) VALUES (%s, '%s', (SELECT max(datasource_id) + 1 FROM public.lex_datasource WHERE opid = %s));" % (opid, (path + os.sep + file_in), opid)
cur.execute(sql_string)

print(sql_string)

# Re-fetchons-le tout de suite:
sql_string = "SELECT max(datasource_id) FROM public.lex_datasource WHERE opid = %s;" % opid
cur.execute(sql_string)
datasource = cur.fetchall()[0][0]

print("\n-- datasource             =>  %s" % datasource)

# /*}}}*/
# Lecture du fichier, d'abord l'en-tête:/*{{{*/
file_in_reader = csv.reader(open(file_in, 'rb'), delimiter = ',', quotechar='"')
# on lit les lignes en les parsant, on informe les clés-valeurs dans un tableau:
# mieux: je construis un dico; mais comme j'ai besoin des données dans l'ordre,
# non, je fais une liste, 
key_values = []
for i in range(12):
    line = file_in_reader.next()
    (k, v) = line[0:2]
    key_values.append((k, v))

# j'en refais un dico dont je prends ce qui m'intéresse:
# bof, plus simple, j'itère:
for (k, v) in key_values:
    if   k == 'Batch_No':
        jobno   = v
    elif k == 'PO NUMBER':
        orderno = v

# Vérifions si ça s'est bien passé, si on a bien un jobno et un orderno:/*{{{*/
try:
    print("\n-- Batch_No    = jobno    =>  %s" % jobno)
except:
    # s'il n'y a pas de jobno défini, on sort.
    print("\n-- Batch_No    = jobno    =>  non défini:\nVérifier le fichier d'entrée")
    sys.exit(1)

try:
    print("\n-- PO NUMBER   = orderno  =>  %s" % orderno)
except:
    # s'il n'y a pas d'orderno, ça n'est pas si grave, on continue.
    print("\n-- PO NUMBER   = orderno  =>  non défini.")

print
# /*}}}*/

# /*}}}*/
# Construction de la chaîne SQL qui sera finalement "jouée": d'abord la partie lots:/*{{{*/
sql_string  = "INSERT INTO public.lab_ana_batches_reception (opid, jobno, datasource, generic_txt_col1, generic_txt_col2) VALUES \n"
for kv in key_values:
    sql_string += "(" + str(opid) + ", '" + str(jobno) + "', '" + str(datasource) + "', '" + str(kv[0]) + "', '" + str(kv[1]).replace("'", "\\'") + "'),\n"

sql_string = sql_string[0:-2] + ";\n\n"

# /*}}}*/
# Suite de la construction de la chaîne SQL: la partie des analyses:/*{{{*/
sql_string += "INSERT INTO public.lab_ana_results (opid,          labname, jobno,       orderno, datasource,             scheme,    analyte, sample_id,  value,  unit) VALUES \n"
for line in file_in_reader:
    sql_string += "(" + str(opid) + ", '" + str(labname) + "', '" + str(jobno) + "', '" + str(orderno) + "', '" + str(datasource) + "', '" + str(scheme) + "', '" + str(analyte) + "', '" + str(line[0]) + "', '" + str(line[1])  + "', '" + str(unit) + "'),\n"

sql_string = sql_string[0:-2] + ";\n"

# /*}}}*/
# On "joue" finalement le SQL résultant:/*{{{*/

cur.execute(sql_string)

print(sql_string)

#/*}}}*/
# /*}}}*/


# mise à jour des teneurs en fonction des analyses:
print("Mise à jour des teneurs dans la table échantillonnage...")

sql_string = "UPDATE public.dh_sampling_grades SET au1_ppm = tmp.au_fa_avg_ppm FROM (SELECT opid, sample_id, avg(value_num) AS au_fa_avg_ppm FROM lab_ana_results WHERE opid = 18 AND analyte = 'AU' AND scheme = 'FA001' GROUP BY opid, sample_id) AS tmp WHERE (dh_sampling_grades.opid = tmp.opid AND dh_sampling_grades.sample_id = tmp.sample_id AND au1_ppm IS NULL);"
print(sql_string)
cur.execute(sql_string)

Mise à jour de au6_ppm:
sql_string = 'UPDATE public.dh_sampling_grades SET au6_ppm = greatest(au1_ppm, au2_ppm, au3_ppm, au4_ppm, au5_ppm) WHERE opid = 18 AND au6_ppm IS NULL OR (au6_ppm != greatest(au1_ppm, au2_ppm, au3_ppm, au4_ppm, au5_ppm));'
print(sql_string)
cur.execute(sql_string)





# À la fin, ne pas oublier de commiter (ou pas):
conn.commit()
# conn.rollback()

# ni de tout fermer:
# Close communication with the database
cur.close()
conn.close()



"""
# TODO:

# lister les trous avec des résultats:
sql_string = "SELECT DISTINCT id FROM dh_sampling_grades WHERE sample_id IN ( SELECT sample_id FROM lab_ana_results WHERE datasource = (SELECT max(datasource) AS last_datasource FROM lab_ana_results));"
result = data_extractor(sql_text)
result.sort()

print "Sondages avec les derniers résultats:"
for i in result:
    print i['id']


# regardons les données nouvellement importées:
ligne_cmd = "echo \"SELECT id, depfrom, depto, sample_id, au1_ppm, au2_ppm, au6_ppm, repeat('#', (au6_ppm*5)::integer) AS graph_au_6 FROM dh_sampling_grades WHERE id IN (SELECT id FROM dh_collars_points_last_ana_results) ORDER BY id, depto\" | psql -X -d bdexplo | less"
sys.stdout.flush()
os.system(ligne_cmd)


# mise à jour de la sélection pour cartographie:
sql_text = "CREATE OR REPLACE VIEW collars_selection AS SELECT * FROM dh_collars_points_last_ana_results;"
result = data_extractor(sql_text)



# calcule les passes minéralisées:
# cf. procedure... TODO


# màjour de la somme des accus sur les têtes:
sql_text = "UPDATE public.dh_collars SET accusum = calcul_accusum FROM (SELECT opid, id, sum(accu) AS calcul_accusum FROM dh_mineralised_intervals WHERE mine = 0 GROUP BY opid, id) AS tmp WHERE (dh_collars.opid = tmp.opid AND dh_collars.id = tmp.id);"
result = data_extractor(sql_text)



# affiche la table dh_sampling_grades avec graphe teneurs, et passes minéralisées (j'avais fait ça, au Soudan): TODO
"""

"""
:set foldclose=all
:set foldmethod=marker
:set syntax=python
:set autoindent
:set ts=4
:set sw=4
:set et
:%s/\t/    /gc

"""
