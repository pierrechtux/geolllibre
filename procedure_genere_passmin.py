#!/usr/bin/env python
# -*-coding=utf-8
"""Détermination de passes minéralisées de données de sondages,
calculs de passes minéralisées de sondages (ou tout autre ouvrage 
en abscisse curviligne).
Je fais ça en pseudo-code, converti en python

Determination of mineralised intervals along drill holes, 
computation of mineralised stretched values along drill
holes (or any work with a curvilinear abscissa).
Originally written in pseudo-code, then converted to python.
"""

# Imports: #
import sqlalchemy, os, pickle, csv, decimal

# => On donne des: #
# - données: #{{{
# Une table contenant les données, correctement faite; une chaîne de connexion à une base:
table          = 'dh_sampling_grades'
connection_str =  'postgresql://pierre:pp@localhost/bdexplo'

# => @#passer ça en paramètres comme variables shell, $GLL_BD_HOST $GLL_BD_NAME

#}}}
# - EZ paramètres: #{{{
#   - définition des classe de passes minéralisées: 
#     1 par défaut; 2 = riche, 0 = large:
# mineralised_intervals_class = 1

#   - teneur de coupure en ppm:
# cutoff = decimal.Decimal('0.5')
#   - dilution ou pas:, et si oui, longueur maxi 
#     de stérile admis dans une passe minéralisée:
# flag_dilution = True
# max_barren_length = 2
#   - accu minimale pour une passe minéralisée:
# flag_accu_mini = False
# accu_mini = 0
#   - champ teneur à considérer: 
#                               FIXME: mettre plusieurs 
#                                      champs de teneurs
# gradefield = 'au6_ppm'

#   - opid de l'opération:
# opid = 18

#   - critère de sélection (en SQL, sans le mot-clé WHERE):
# criteria = "" #"id >= 'S520' AND id <= 'S528'"
#FIXME: attention, les caractères joker % ne passent pas, ça génère une erreur dans sqlalchemy
# }}}


def generate_mineralised_intervals(opid = 17, criteria='TRUE', mineralised_intervals_class=0, cutoff=0.5, flag_dilution=True, max_barren_length=10, flag_accu_mini=False, accu_mini=0, gradefield='au6_ppm',  insert_records=True, delete_records=False): #{{{
    # => On a en sortie:
    # les intervalles des passes minéralisées, sous forme d'une liste de dicos, 
    # ou carrément un ResultSet; comme, par exemple: (...) TODO
    # ...
    # ...
    #
    cutoff = decimal.Decimal(str(cutoff))
    # quelques classes:
    # Ces 3 classes viennent d'un article de Sébastien Chazallet paru dans GLMFen septembre 2011: #{{{
    class Extractor(object):#{{{
        def __init__(self, url):
            self.engine = sqlalchemy.create_engine(url)
        def __call__(self, request):
            connection = self.engine.connect()
            result = ResultSet(connection.execute(request).fetchall())
            #result = (connection.execute(request).fetchall())
            connection.close()
            return result
        #}}}
    class RequestsManager(list):#{{{
        filename = 'requests.pkl'
        def __init__(self):
            if os.path.isfile(self.filename):
                f = open(self.filename, 'rb')
                for d in pickle.load(f):
                    self.append(d)
                f.close()
            else:
                print('Nouveau fichier de données')
        def save(self):
            f = open(self.filename, 'wb')
            exported = []
            for d in self:
                exported.append(d)
            pickle.dump(exported, f)
            f.close()
        #}}}
    class ResultSet(list):#{{{
        def __init__(self, result):
            for r in result:
                self.append(dict((a, b) for a, b in r.items()))
        def export(self, filename, columns):
            f = open(filename, 'w')
            w = csv.DictWriter(f, columns)
            #w.writeheader()
            w.writerows(self)
            f.close()
    #}}}
    #}}}
    # Des classes pour gérer les intervalles, minéralisés ou intermédiaires stériles:{{{
    class Interval(object):#{{{
        def __init__(self, opid, id, depfrom, depto, accu):
            self.opid = opid
            self.id = id
            self.depfrom = depfrom
            self.depto = depto
            self.accu = accu
        def extendTo(self, depto,  accu):
            self.depto = depto
            self.accu += accu
        def getAvGrade(self):
            return self.accu/(self.depto - self.depfrom)
        def isValid(self):
            if flag_accu_mini:
                if self.accu < accu_mini:
                    return False
            return self.getAvGrade() >= cutoff 
        def close(self):
            mineralised_intervals.append(self)
            #del self           # marche pas? L'instance semble survivre à ce traitement...
            #self = None    # marche pas non plus? bof. 
        #}}}
    
    class IntervalMineralised(Interval):
        pass
    
    class IntervalBarren(Interval):
        pass
    
    #}}}
    
    
    
    ##############################################################
    # Début du processus:
    # Fabriquons un extracteur de données:
    data_extractor = Extractor(connection_str)
    # Sortons la liste des trous:
    #holes = data_extractor(("SELECT DISTINCT id FROM  %s WHERE opid ='%s' AND %s /*AND id IN (SELECT id FROM dh_collars_points_last_ana_results) */ ORDER BY id") % (table, opid, criteria))
    
    #print "-- Trous à traiter:"
    #print "-- ", holes
    
    # pour générer un ResultSet suitable pour les passes:
    mineralised_intervals = []  # bof, on fait une simple liste, pour le moment
    
    # Procédons (du pseudocode implémenté aufuramz):
    #  On met la variable interval_mine à None, pour
    # dire qu'on est pas dans un intervalle minéralisé
    interval_mine   = None
    # et aussi comme quoi on n'est pas dans un intervalle stérile:
    interval_barren = None
    
    
    # Boucle principale:
    print "-- Boucle principale"
    
    # 2012_07_10__11_16_47:
    # je change ça; plutôt, pour optimiser (le script est TRÈS lent), 
    # au lieu d'itérer sur les id des trous, en allant à chaque fois 
    # requêter pour sortir les échantillons, on va plutôt chercher 
    # l'ensemble des données dans la base, puis on scinde.
    
    # D'abord, si jamais le critère est vide ou null, on le remplace par true:
    if criteria == None or criteria == "": criteria = "TRUE"
    
    # l'ensemble des échantillons et teneurs:
    #  On extrait tous les échantillons de la bd, et dans l'ordre:
    sql  = "SELECT opid, id, depfrom, depto, core_loss_cm, sample_id, "
    sql += gradefield
    sql += " FROM dh_sampling_grades WHERE opid = "
    sql += str(opid)
    sql += " AND "
    sql += " ("
    sql += criteria
    sql += ") "
    sql += "ORDER BY id, depto"
    sql += ";"
    samples_all = data_extractor(sql)
    
    id_previous = None              # forcément, on n'est dans aucun trou, initialement
    for sample in samples_all:  # pour tous les échantillons:
        id = sample['id']           # le trou en cours
        if id_previous != id:           # test si on n'est PAS dansle même trou:
            print "\n-- " + id + ": ",  # NOUVEAU TROU
            if interval_mine:           # en ce cas, si une passe est en cours de définition:
                interval_mine.close()       # attention, un intervalle minéralisé est en cours;    
                interval_mine = None        # il date donc de l'ouvrage précédent:
                                            # donc on clot la passe en cours du sondage précédent 
                                            # (et le sondage précédent est ouvert en pied!):
            # Initialisons quelques variables:
            sample_previous = None      # D'abord, on remet à zéro les variables 
                                        # contenant les échantillons entourant 
                                        # l'échantillon courant
            sample_next     = None      #       FIXME: hm...
            interval_mine   = None      # On remet à zéro aussi le drapeau  => non, plutot l'objet 
                                        # interval_mine qui est nul, signalant si l'on est dans une 
                                        # passe ou pas
        # Quelques variables locales, juste pour faciliter la vie du codeur:
        opid,  depfrom,  depto,  grade = sample['opid'],  sample['depfrom'],  sample['depto'],  sample[gradefield]
        
        
        id_previous = id        # on positionne id_previous sur le trou en cours, pour la prochaine itération
        
        if depfrom is None:
                depfrom = 0
        if depto is None:
            depto = 0
        if grade is None or grade < 0:
            grade = 0           #FIXME: attention, si teneur NULL, il faut calculer différemment la passe; et aussi pour les codes divers en 999 => FIXME
        accu = (depto-depfrom) * grade
        if not(interval_mine):  # si on n'est pas dans une passe:
            if grade < cutoff:      # si teneur ech < tc: 
                # print("id, depfrom, depto, grade: %s %s %s %s"% (id, depfrom, depto, grade))
                # => au suivant;
                print ".",
                continue
            else:                   # sinon, minéralisé (teneur ech >= tc):
                #print "-- teneur > tc: " + str(grade)
                if interval_barren:
                    interval_barren = None
                # on commence une passe:
                #print "-- Début de passe minéralisée"
                print "[",
                interval_mine = IntervalMineralised(opid,  id,  depfrom,  depto,  accu)
                continue    # zou, au suivant
        else:                   # sinon (on est dans une passe):
            if grade < cutoff:      # si teneur ech < tc:
                if flag_dilution:   # si on autorise de la dilution: #TODO #
                    if interval_barren:     # si on a déjà commencé un intervalle stérile intermédiaire
                        interval_barren.depto = depto
                        interval_barren.accu += accu
                        if interval_barren.depto - interval_barren.depfrom > max_barren_length:    # si on a dépassé la longueur de passe stérile
                            # on ferme la passe entamée:
                            #print "-- Fermeture passe minéralisée"
                            print "]",
                            interval_mine.close()
                            interval_mine = None
                            interval_barren = None
                        continue
                    else:                       # pas d'intervalle stérile de commencé:
                        # on le commence:
                        #print "-- Début d'intervalle stérile"
                        interval_barren = Interval(opid,  id,  depfrom,  depto,  accu)
                    #    # si moyenne mobile du précédent et du suivant < tc:
                    #    # TODO  
                    #    # => il faudrait faire un tableau pour pouvoir accéder directement 
                    #    #    aux échantillons précédents et suivants
                else:                   # pas de dilution:
                    # on ferme l'intervalle:
                    #print "-- Fermeture d'intervalle"
                    print "]",
                    interval_mine.close()
                    interval_mine = None
                    continue
            else: # sinon, minéralisé (teneur ech >= tc):
                if interval_barren: # on est dans une passe stérile; qu'on incrémente à la passe minéralisée
                    interval_mine.accu += interval_barren.accu
                    interval_mine.depto = interval_barren.depto
                    interval_barren = None
                # on incrémente la passe minéralisée en cours:
                #print "-- incrémentation de la passe minéralisée en cours"
                print "=",
                interval_mine.extendTo(depto,  accu)
                # zou, au suivant
                continue
    
    
    if interval_mine != None: #{{{  # une fois tout fini, si une passe est en cours de définition:
        # attention, un intervalle minéralisé est en cours;    
        # il date donc du dernier ouvrage:
        # donc on clot la passe en cours du sondage précédent 
        # (et le sondage précédent est ouvert en pied!):
        interval_mine.close()
        interval_mine = None
    #}}}
    
    
    print("-- Résultat:")
    print("-- - paramètres:")
    print("--   - teneur de coupure: %s" % cutoff)
    print("--   - classe de passes minéralisées (1 par défaut; 2 = riche, 0 = large): %s" % mineralised_intervals_class)
    print("--   - dilution: %s" % flag_dilution)
    if flag_dilution:
        print("--   - longueur maximale d'intermédiaire stérile: %s" % max_barren_length)
    
    print("-- - passes minéralisées:")
    print("--   %s passe(s):" % len(mineralised_intervals))
    print("-- opid, id, depfrom, depto, accu")
    for i in mineralised_intervals:
        print "--", (i.opid,  i.id,  i.depfrom,  i.depto,  i.accu)
    
    print("\n")
    count_zaps = 0
    print("-- Ménage: ôt des passes ridicules, qui ont une teneur moyenne plus basse que la teneur de coupure")
    if flag_accu_mini:
        print("-- Ôt des passes dont l'accumulation est inférieure à %s" % accu_mini)
    
    copy_mineralised_intervals = mineralised_intervals[:] #sinon, ça interfère entre l'ôt des m et la liste
    for m in copy_mineralised_intervals:    # donc on itère prudemment sur une copie de la liste
        if not(m.isValid()):
            mineralised_intervals.remove(m)
            print('-- zap')
            count_zaps += 1
    
    del copy_mineralised_intervals
    
    print("\n")
    
    if count_zaps:
        print("-- Après ménage:")
        print("--   %s passe(s):" % len(mineralised_intervals))
        print("-- opid, id, depfrom, depto, accu")
        for i in mineralised_intervals:
            print "-- ", i.opid,  i.id,  i.depfrom,  i.depto,  i.accu
    print("\n")

    print
    print("--Mise en forme pour DELETEr dans la table dh_mineralised_intervals:")
    sqldel = "DELETE FROM public.dh_mineralised_intervals WHERE opid = "
    sqldel += str(opid)
    sqldel += " AND "
    sqldel += " ("
    sqldel += criteria
    sqldel += ") "
    sqldel += "AND mine = '"
    sqldel += str(mineralised_intervals_class)
    sqldel += "' ;"
    print(sqldel)
    print
    
    print("--Mise en forme pour INSERer dans la table dh_mineralised_intervals:")
    sqlins  = "INSERT INTO public.dh_mineralised_intervals \n"
    sqlins += "(opid, id, depfrom, depto, mine, avau, accu, stva) \n"
    sqlins += "VALUES "
    elts = []
    for i in mineralised_intervals:
        moy = float(i.accu/(i.depto - i.depfrom)) #.__format__(".2f")
        elts.append("(%s, '%s', %s, %s, %s, %s, %s, '%s')" %  (i.opid,  i.id,  i.depfrom,  i.depto,  mineralised_intervals_class ,  moy,  i.accu,  ((i.depto - i.depfrom)).__format__("g") + " m @ " + float(moy.__format__(".2f")).__format__("g") + " g/t"))
        
    sqlins += ", \n".join(elts)
    sqlins += ";"
    print(sqlins)
    print("\n")

    if delete_records:
        rien = data_extractor(sqldel)
    if insert_records:
        rien = data_extractor(sqlins)
    # }}}

# Il faudrait que je puisse utiliser une fonction, ou une classe, ainsi:
# generate_mineralised_intervals(classe=0, cutoff=0.5, max_barren_length=2, criteria="opid = 18 AND id ILIKE 'S%'", delete_records=True)

opid_ = 25
generate_mineralised_intervals(opid = opid_, criteria='TRUE', mineralised_intervals_class=0, cutoff=0.5, flag_dilution=True, max_barren_length=10, flag_accu_mini=False, accu_mini=0, gradefield='au6_ppm',  insert_records=False, delete_records=False)
generate_mineralised_intervals(opid = opid_, criteria='TRUE', mineralised_intervals_class=1, cutoff=0.5, flag_dilution=True, max_barren_length=2 , flag_accu_mini=False, accu_mini=0, gradefield='au6_ppm',  insert_records=False, delete_records=False)
generate_mineralised_intervals(opid = opid_, criteria='TRUE', mineralised_intervals_class=2, cutoff=2,   flag_dilution=True, max_barren_length=1 , flag_accu_mini=False, accu_mini=0, gradefield='au6_ppm',  insert_records=False, delete_records=False)






"""
:set foldclose=all
:set foldmethod=marker
:set syntax=python
:set autoindent
:set ts=4
:set sw=4
:set et
:set nowrap
:%s/\t/    /gc

"""

