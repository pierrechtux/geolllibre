#!/bin/bash
# Transfert des données depuis la base bdexplo, historique, vers la base postgeol, après un gros ménage.

# Script scindé en paragraphes à faire tourner, au furàmz, par des F8 bien sentis.
pg_dump -d bdexplo -a -t public.doc_postgeol_table_categories | sed -e 's/doc_bdexplo_/doc_postgeol_/g'    |  psql postgeol --single-transaction
pg_dump -d bdexplo -a -t public.doc_bdexplo_tables_descriptions  | sed -e 's/doc_bdexplo_/doc_postgeol_/g' |  psql postgeol --single-transaction
__________***_JEANSUILA_***__________

psql postgeol -c "ALTER TABLE public.operations ADD COLUMN numauto integer;"
pg_dump -d bdexplo -a -t public.operations | grep -v "operations_numauto_seq"    |  psql postgeol --single-transaction
psql postgeol -c "ALTER TABLE public.operations DROP COLUMN numauto;"

SELECT * FROM public.operations;






> /tmp/tt && less /tmp/tt
psql postgeol -f /tmp/tt




