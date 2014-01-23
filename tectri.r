Tectri.r
rebol [
 title: "essai d'implementation de Tectri en Rebol"
 version: 0.2
 description: {premier codage "en aveugle", sur visor. bcp de code reste a traduire de vb; faire tests de vitesses; faire 1 autre test en python
=> implémenté en python:

-> voilà, on y est, je traduis rapidos}
auteur: "Pierre Chevalier"
date: 23/11/2006 ;pour la v0.1
;suite: suite de l'implémentation de tectri en python, 31/07/2009 dans TGV Agen-Besançon
;resuite, 20_05_2012__19_00_37
;
;puis re-merge en rebol, suite à libération de rebol
;  +-----------------+
;  |                 |
;  |   tectri.r      |
;  |                 |
;  +-----------------+

 date: 01/01/2013
 ]

;objet PLAN: mesure d'un plan, en convention usuelle du type N120/60/S
plan: make object! [
 direction: make float!
 pendage:   make float!
 quadrant:  make char!
 ]

;objet LIGNE; une ligne liée à 1 plan pourra être définie par pitch; azi et dl doivent alors être recalculés
ligne: make object! [
 azi: make float!
 pl: make float!
 pi: make float!
 quadr_pi: make char!
 calcule_azi: function [] [] [
  ...
  ]
 calcule_pl: function [] [] [
  ...
  ]
 calcule_pi: function [] [] [
  ...
  ]
 ]

;objet FAILLE: un plan & une ligne, + jeu, commentaire & tri. 1champ booleen de jeu sûr ou pas ajouté par rapport à tectri vx.x (vb 1995)
faille: make object![
 plan: make plan []
 strie: make ligne []
 jeu: make string!
 jeu_sur: make boolean!
 commentaire: make string!
 tri: make string!
 ]


do %rondibet.r

;objet STEREO: implemente(ra) methodes de tracés, un layout, des couches raster. Hérite de rondibet

stereo: make rondibet [
 ;ça, c plutôt pour le stéréo: @#à déplacer dans l'objet stereo
 hemisphere: make string! "S"


 trace_stereo_vierge: make function [] [] [
  trace_rondibet
  ]

 trace_plan_cyclo: make function[p plan][][
  ;voir si fonction arc ou <=> ds VID ou GCS; sinon, au pire, mettre 1 cache troué en cercle(...)
  ;voir ds logiciel CAD s/ knoppix cercle passant par rayon infini: comment est-fe impl351ment351?
  ;...
  ]
 trace_plan_polaire: make function[p plan][][
  ;...
  ]
 trace_ligne: make function[l ligne][][
  ;...
  ]
  trace_faille_plan_strie: make function[f faille][][
  ;...
  ]
 ]

;objet STATION: ensemble de failles, avec définition des groupes de tris de faille (avant, versions vb, les groupes étaient définis sur la machine dans tectri.ini). Coord pour carto, éventuellt.
station: make object![
 nom: make string!
 ;f: make faille [];[0 0 E 0 N N ? "Faille vide" a]
 failles: make list! [make faille[]] ;@#liste
 s0: make plan
 commentaire: make string!
 x_coord: make float!
 y_coord: make float!
 coordsys: make string!
 devia_mag: make decimal!
 groupes_tri: make string! ;@#implementer 1 tableau de grpes de tri par station, ek 1 commentaire a chaque
 ]

;widget quelconque grille, a telech; alias
grille: _widqet_grid_

;objet GRILLE_STATION: grille de données; hériter d'1 widget qq
grille_station: make object![][][
 grille_station: make grille [
  data:
   
  ]
 ]

;objet GRILLE_GROUP_TRI: grille de groupes de tri; hériter d'1 widget qq
grille_group_tri: make object![][][]


; Le coeur de tectri: le calcul des paramètres de mesure:/*{{{*/
; traduit^W recopié depuis routines.bas CalculeParametresMesure():
/*{{{*/
'}}}
Sub CalculeParametresMesure () '{{{
   On Error GoTo Traite_Erreurs5:
 If teta = 0 Then teta = pi / 6
 If Left$(MDI!lblStatus.Caption, 6) <> "Calcul" Then prompt "Calcul des paramètres géométriques de " + Site(ns).NomFichier: MDI!lblStatus.Refresh
      local_AZI = Site(ns).Faille(i).azi * pi / 180
      local_pd = Site(ns).Faille(i).Pd
      local_pitch = Site(ns).Faille(i).pitch

  If local_pd <= 1 Then local_pd = 2
  '**If local_pd >= 89 Then local_pd = 88
   local_pd = local_pd * pi / 180
  If local_pitch <= 1 Then local_pitch = 2
  If local_pitch >= 89 Then local_pitch = 88
   local_pitch = local_pitch * pi / 180
   PitchNoOrient = local_pitch
  If local_AZI < pi / 2 Then
   Select Case Site(ns).Faille(i).DirPd + Site(ns).Faille(i).dirpi + Site(ns).Faille(i).jeu
    Case "SEN", "SES", "SNN", "SNS", "EEN", "EES", "ENN", "ENS"
     Site(ns).Faille(i).param.jh = "S": Site(ns).Faille(i).param.jv = "N"
    Case "SEI", "SED", "SNI", "SND", "EEI", "EED", "ENI", "END"
     Site(ns).Faille(i).param.jh = "D": Site(ns).Faille(i).param.jv = "I": local_pitch = local_pitch + pi
    Case "SWN", "SWD", "SSN", "SSD", "EWN", "EWD", "ESN", "ESD"
     Site(ns).Faille(i).param.jh = "D": Site(ns).Faille(i).param.jv = "N": local_pitch = pi - local_pitch
    Case "SWI", "SWS", "SSI", "SSS", "EWI", "EWS", "ESI", "ESS"
     Site(ns).Faille(i).param.jh = "S": Site(ns).Faille(i).param.jv = "I": local_pitch = 2 * pi - local_pitch
    Case "NWN", "NWS", "NSN", "NSS", "WWN", "WWS", "WSN", "WSS"
    Site(ns).Faille(i).param.jh = "S": Site(ns).Faille(i).param.jv = "N": local_AZI = local_AZI + pi
    Case "NWI", "NWD", "NSI", "NSD", "WWI", "WWD", "WSI", "WSD"
     Site(ns).Faille(i).param.jh = "D": Site(ns).Faille(i).param.jv = "I": local_AZI = local_AZI + pi: local_pitch = local_pitch + pi
    Case "NEN", "NED", "NNN", "NND", "WEN", "WED", "WNN", "WND"
     Site(ns).Faille(i).param.jh = "D": Site(ns).Faille(i).param.jv = "N": local_AZI = local_AZI + pi: local_pitch = pi - local_pitch
    Case "NEI", "NES", "NNI", "NNS", "WEI", "WES", "WNI", "WNS"
     Site(ns).Faille(i).param.jh = "S": Site(ns).Faille(i).param.jv = "I": local_AZI = local_AZI + pi: local_pitch = 2 * pi - local_pitch
   End Select
  Else
   Select Case Site(ns).Faille(i).DirPd + Site(ns).Faille(i).dirpi + Site(ns).Faille(i).jeu
    Case "SEN", "SES", "SSN", "SSS", "WEN", "WES", "WSN", "WSS"
     Site(ns).Faille(i).param.jh = "S": Site(ns).Faille(i).param.jv = "N"
    Case "SEI", "SED", "SSI", "SSD", "WEI", "WED", "WSI", "WSD"
     Site(ns).Faille(i).param.jh = "D": Site(ns).Faille(i).param.jv = "I": local_pitch = local_pitch + pi
    Case "SWN", "SWD", "SNN", "SND", "WWN", "WWD", "WNN", "WND"
     Site(ns).Faille(i).param.jh = "D": Site(ns).Faille(i).param.jv = "N": local_pitch = pi - local_pitch
    Case "SWI", "SWS", "SNI", "SNS", "WWI", "WWS", "WNI", "WNS"
     Site(ns).Faille(i).param.jh = "S": Site(ns).Faille(i).param.jv = "I": local_pitch = 2 * pi - local_pitch
    Case "NWN", "NWS", "NNN", "NNS", "EWN", "EWS", "ENN", "ENS"
     Site(ns).Faille(i).param.jh = "S": Site(ns).Faille(i).param.jv = "N": local_AZI = local_AZI + pi
    Case "NWI", "NWD", "NNI", "NND", "EWI", "EWD", "ENI", "END"
     Site(ns).Faille(i).param.jh = "D": Site(ns).Faille(i).param.jv = "I": local_AZI = local_AZI + pi: local_pitch = local_pitch + pi
    Case "NEN", "NED", "NSN", "NSD", "EEN", "EED", "ESN", "ESD"
     Site(ns).Faille(i).param.jh = "D": Site(ns).Faille(i).param.jv = "N": local_AZI = local_AZI + pi: local_pitch = pi - local_pitch
    Case "NEI", "NES", "NSI", "NSS", "EEI", "EES", "ESI", "ESS"
     Site(ns).Faille(i).param.jh = "S": Site(ns).Faille(i).param.jv = "I": local_AZI = local_AZI + pi: local_pitch = 2 * pi - local_pitch
   End Select
  End If
 'CoordCercleTraceCyclo
  If local_pd = pi / 2 Then
     Site(ns).Faille(i).param.ox = Sin(local_AZI)
     Site(ns).Faille(i).param.oy = Cos(local_AZI)
     Site(ns).Faille(i).param.r = -1
     Site(ns).Faille(i).param.Angledep = 0
   Else
     Site(ns).Faille(i).param.ox = Tan(local_pd) * Cos(-local_AZI)
     Site(ns).Faille(i).param.oy = Tan(local_pd) * Sin(-local_AZI)
     Site(ns).Faille(i).param.r = Sqr((Tan(local_pd) * Tan(local_pd)) + 1)
     Site(ns).Faille(i).param.Angledep = modulo(pi - Atn(1 / Sqr(Site(ns).Faille(i).param.ox ^ 2 + Site(ns).Faille(i).param.oy ^ 2)) - local_AZI, 2 * pi)
      'If faille(ns,i).param.Angledep < 0 Then faille(ns,i).param.Angledep = 2 * pi + faille(ns,i).param.Angledep: If faille(ns,i).param.Angledep > 2 * pi Then faille(ns,i).param.Angledep = faille(ns,i).param.Angledep - 2 * pi
     Site(ns).Faille(i).param.Anglearr = modulo(pi + Atn(1 / Sqr(Site(ns).Faille(i).param.ox ^ 2 + Site(ns).Faille(i).param.oy ^ 2)) - local_AZI, 2 * pi)
      'If faille(ns,i).param.Anglearr < 0 Then faille(ns,i).param.Anglearr = 2 * pi + faille(ns,i).param.Anglearr: If faille(ns,i).param.Anglearr > 2 * pi Then faille(ns,i).param.Anglearr = faille(ns,i).param.Anglearr - 2 * pi
   End If

 'CoordPolaire
  Site(ns).Faille(i).param.PolX = (Sin(local_pd) / (Cos(local_pd) + 1)) * Cos(-local_AZI)
  Site(ns).Faille(i).param.PolY = (Sin(local_pd) / (Cos(local_pd) + 1)) * Sin(-local_AZI)

 'CoordStrie    ro=
  DENOM = Sqr(1 - (Sin(PitchNoOrient) ^ 2 * (Sin(local_pd)) ^ 2))
  SINRO = -((Sin(PitchNoOrient) * Cos(local_pd)) / DENOM)
  COSRO = (Cos(PitchNoOrient) / DENOM)
   If SINRO = 0 And COSRO = 1 Then
      Ro = 0
   ElseIf SINRO > 0 And COSRO >= 0 Then
      Ro = ARCOS(COSRO)
   ElseIf SINRO >= 0 And COSRO < 0 Then
      Ro = ARCOS(COSRO)
   ElseIf SINRO < 0 And COSRO <= 0 Then
      Ro = 2 * pi - ARCOS(COSRO)
   ElseIf SINRO < 0 And COSRO > 0 Then
      Ro = 2 * pi - ARCOS(COSRO)
   End If
  rs = (Sqr((Sin(PitchNoOrient) * Cos(local_pd)) ^ 2 + Cos(PitchNoOrient) ^ 2)) / (Sin(PitchNoOrient) * Sin(local_pd) + 1)
  If (0 < local_pitch And local_pitch < pi / 2) Or (pi < local_pitch And local_pitch < 3 * pi / 2) Then Site(ns).Faille(i).param.azstri = local_AZI + pi - Ro
  If (pi / 2 < local_pitch And local_pitch < pi) Or (3 * pi / 2 < local_pitch And local_pitch < 2 * pi) Then Site(ns).Faille(i).param.azstri = local_AZI + Ro
  Site(ns).Faille(i).param.SX = rs * Sin(Site(ns).Faille(i).param.azstri)
  Site(ns).Faille(i).param.SY = rs * Cos(Site(ns).Faille(i).param.azstri)
  If Site(ns).Faille(i).param.jv = "N" Then
   Site(ns).Faille(i).param.sax = (rs - .1) * Sin(Site(ns).Faille(i).param.azstri)
   Site(ns).Faille(i).param.say = (rs - .1) * Cos(Site(ns).Faille(i).param.azstri)
  End If
  If rs < .1 Then
   Site(ns).Faille(i).param.sax = 0
   Site(ns).Faille(i).param.say = 0
  End If
  If Site(ns).Faille(i).param.jv = "I" Then
   Site(ns).Faille(i).param.sax = (rs + .1) * Sin(Site(ns).Faille(i).param.azstri)
   Site(ns).Faille(i).param.say = (rs + .1) * Cos(Site(ns).Faille(i).param.azstri)
  End If
  lgflstr = .07
  alfastr = Atn(.1 * Tan(pi / 9) / rs)
  Select Case local_pitch
   Case 0 To pi / 2
    Site(ns).Faille(i).param.sfx = (rs - lgflstr) * Sin(Site(ns).Faille(i).param.azstri - alfastr)
    Site(ns).Faille(i).param.sfy = (rs - lgflstr) * Cos(Site(ns).Faille(i).param.azstri - alfastr)
   Case pi / 2 To pi
    Site(ns).Faille(i).param.sfx = (rs - lgflstr) * Sin(Site(ns).Faille(i).param.azstri + alfastr)
    Site(ns).Faille(i).param.sfy = (rs - lgflstr) * Cos(Site(ns).Faille(i).param.azstri + alfastr)
   Case pi To 3 * pi / 2
    Site(ns).Faille(i).param.sfx = (rs + lgflstr) * Sin(Site(ns).Faille(i).param.azstri - alfastr)
    Site(ns).Faille(i).param.sfy = (rs + lgflstr) * Cos(Site(ns).Faille(i).param.azstri - alfastr)
   Case 3 * pi / 2 To 2 * pi
    Site(ns).Faille(i).param.sfx = (rs + lgflstr) * Sin(Site(ns).Faille(i).param.azstri + alfastr)
    Site(ns).Faille(i).param.sfy = (rs + lgflstr) * Cos(Site(ns).Faille(i).param.azstri + alfastr)
   Case Else
  End Select

 'CoordAxeY
  G2 = local_pitch + pi / 2
  If G2 > pi Then G2 = G2 - pi: If G2 > pi Then G2 = G2 - pi: If G2 > pi Then G2 = G2 - pi
  S2X = -(Sin(G2) * Cos(local_pd) / (Sin(G2) * Sin(local_pd) + 1))
  S2Y = -Cos(G2) / (Sin(G2) * Sin(local_pd) + 1)
  ROS2 = Atn(Abs(S2X) / Abs(S2Y))
   If S2X >= 0 And S2Y >= 0 Then ROS2 = ROS2
   If S2X >= 0 And S2Y <= 0 Then ROS2 = pi - ROS2
   If S2X <= 0 And S2Y <= 0 Then ROS2 = pi + ROS2
   If S2X <= 0 And S2Y >= 0 Then ROS2 = 2 * pi - ROS2
  dMVT = Sqr(S2X ^ 2 + S2Y ^ 2)
  Site(ns).Faille(i).param.AxeYX = dMVT * Sin(ROS2 + local_AZI)
  Site(ns).Faille(i).param.AxeYY = dMVT * Cos(ROS2 + local_AZI)

 'CoordPmvt
  PdPmvt = ARCOS((1 - dMVT ^ 2) / (1 + dMVT ^ 2))
  OOmegaMvt = Tan(PdPmvt)
   Site(ns).Faille(i).param.xmvt = (OOmegaMvt * Site(ns).Faille(i).param.AxeYX / dMVT)
   Site(ns).Faille(i).param.ymvt = (OOmegaMvt * Site(ns).Faille(i).param.AxeYY / dMVT)
   Site(ns).Faille(i).param.Rmvt = Sqr(OOmegaMvt ^ 2 + 1)
   azpmvt = pi + pi / 2 + ROS2
   If azpmvt > pi Then azpmvt = azpmvt - pi: If azpmvt > pi Then azpmvt = azpmvt - pi
   angledepmvt = modulo(-local_AZI + pi - Atn(1 / Sqr(Site(ns).Faille(i).param.xmvt ^ 2 + Site(ns).Faille(i).param.ymvt ^ 2)) - azpmvt, 2 * pi)
    'Do While angledepmvt < 0: angledepmvt = angledepmvt + 2 * pi: Loop
    'Do While angledepmvt > 2 * pi: angledepmvt = angledepmvt - 2 * pi: Loop
   anglearrmvt = modulo(-local_AZI + pi + Atn(1 / Sqr(Site(ns).Faille(i).param.xmvt ^ 2 + Site(ns).Faille(i).param.ymvt ^ 2)) - azpmvt, 2 * pi)
    'Do While anglearrmvt < 0: anglearrmvt = anglearrmvt + 2 * pi: Loop
    'Do While anglearrmvt > 2 * pi: anglearrmvt = anglearrmvt - 2 * pi: Loop



 'CoordPaux
  daux = Sqr(Site(ns).Faille(i).param.SX ^ 2 + Site(ns).Faille(i).param.SY ^ 2)
  'Pdaux = arcos((1 - daux ^ 2) / (1 + daux ^ 2))
  Pdaux = ARCOS((1 - (Site(ns).Faille(i).param.SX ^ 2 + Site(ns).Faille(i).param.SY ^ 2)) / (1 + (Site(ns).Faille(i).param.SX ^ 2 + Site(ns).Faille(i).param.SY ^ 2)))
  OOMEGAaux = Tan(Pdaux)
   Site(ns).Faille(i).param.Xaux = OOMEGAaux * Site(ns).Faille(i).param.SX / daux
   Site(ns).Faille(i).param.Yaux = OOMEGAaux * Site(ns).Faille(i).param.SY / daux
   Site(ns).Faille(i).param.Raux = Sqr(OOMEGAaux ^ 2 + 1)
  If Site(ns).Faille(i).param.jv = "N" Then azaux = modulo(pi + pi / 2 + Site(ns).Faille(i).param.azstri, 2 * pi)
  If Site(ns).Faille(i).param.jv = "I" Then azaux = modulo(Site(ns).Faille(i).param.azstri + pi + 3 * pi / 2 + pi, 2 * pi)
   'Do While azaux < 0: azaux = azaux + 2 * pi: Loop
   'Do While azaux > 2 * pi: azaux = azaux - 2 * pi: Loop
  Site(ns).Faille(i).param.AngleDepAux = modulo(pi - Atn(1 / Sqr(Site(ns).Faille(i).param.Xaux ^ 2 + Site(ns).Faille(i).param.Yaux ^ 2)) - azaux, 2 * pi)
   'Do While faille(ns,i).param.AngleDepAux < 0: faille(ns,i).param.AngleDepAux = faille(ns,i).param.AngleDepAux + 2 * pi: Loop
   'Do While faille(ns,i).param.AngleDepAux > 2 * pi: faille(ns,i).param.AngleDepAux = faille(ns,i).param.AngleDepAux - 2 * pi: Loop
  Site(ns).Faille(i).param.AngleArrAux = modulo(pi + Atn(1 / Sqr(Site(ns).Faille(i).param.Xaux ^ 2 + Site(ns).Faille(i).param.Yaux ^ 2)) - azaux, 2 * pi)
   'Do While site(ns).faille(i).param.AngleArrAux < 0: site(ns).faille(i).param.AngleArrAux = site(ns).faille(i).param.AngleArrAux + 2 * pi: Loop
   'Do While site(ns).faille(i).param.AngleArrAux > 2 * pi: site(ns).faille(i).param.AngleArrAux = site(ns).faille(i).param.AngleArrAux - 2 * pi: Loop





 'CoordXZdemiPmvts
  Roprimstri = modulo(Site(ns).Faille(i).param.azstri - (local_AZI + azpmvt), 2 * pi)
   'Do While Roprimstri < 0: Roprimstri = Roprimstri + 2 * pi: Loop:
   'Do While Roprimstri > 2 * pi: Roprimstri = Roprimstri - 2 * pi: Loop
  Gprimstri = modulo(Atn(-Tan(Roprimstri) / Cos(PdPmvt)), pi)
   'Do While Gprimstri < 0: Gprimstri = Gprimstri + pi: Loop: Do While Gprimstri > pi: Gprimstri = Gprimstri - pi: Loop
  Anglestri = modulo(ARCOS(-(OOmegaMvt / Site(ns).Faille(i).param.Rmvt) * Cos(Roprimstri)) - Roprimstri - azpmvt - local_AZI, 2 * pi)
   'Do While Anglestri < 0: Anglestri = Anglestri + 2 * pi: Loop: Do While Anglestri > 2 * pi: Anglestri = Anglestri - 2 * pi: Loop
   'Calculs des coordonnées de la strie, à comparer avec les autres calculs...
   'strix = Site(ns).Faille(i).param.Rmvt * Cos(Anglestri) + Site(ns).Faille(i).param.xmvt
   'striy = site(ns).faille(i).param.Rmvt * Sin(Anglestri) + faille(ns,i).param.ymvt
    If (Site(ns).Faille(i).param.jh = "D" And Site(ns).Faille(i).param.jv = "N") Or (Site(ns).Faille(i).param.jh = "S" And Site(ns).Faille(i).param.jv = "I") Then
     Gprimz = modulo(Gprimstri - teta, pi)
     If Site(ns).Faille(i).param.jv = "I" Then Gprimz = modulo(Gprimstri - (pi / 2 - teta), pi)
      'Do While Gprimz < 0: Gprimz = Gprimz + pi: Loop: Do While Gprimz > pi: Gprimz = Gprimz - pi: Loop
     If Gprimz > pi / 2 Then GPRIMNOORIENTZ = pi - Gprimz:  Else GPRIMNOORIENTZ = Gprimz
     ROprimz = Atn(-Tan(Gprimz) * Cos(PdPmvt))
      Do While ROprimz < pi: ROprimz = ROprimz + pi: Loop: Do While ROprimz > 2 * pi: ROprimz = ROprimz - 2 * pi: Loop
     Anglez = modulo(ARCOS(-(OOmegaMvt / Site(ns).Faille(i).param.Rmvt) * Cos(ROprimz)) - ROprimz - azpmvt - local_AZI, 2 * pi)
      'Do While Anglez < 0: Anglez = Anglez + 2 * pi: Loop: Do While Anglez > 2 * pi: Anglez = Anglez - 2 * pi: Loop
     Site(ns).Faille(i).param.AxeZX = Site(ns).Faille(i).param.Rmvt * Cos(Anglez) + Site(ns).Faille(i).param.xmvt
     Site(ns).Faille(i).param.AxeZY = Site(ns).Faille(i).param.Rmvt * Sin(Anglez) + Site(ns).Faille(i).param.ymvt


     Gprimx = Gprimz + pi / 2: If Gprimx > pi Then Gprimx = Gprimx - pi
     ROprimx = Atn(-Tan(Gprimx) * Cos(PdPmvt))
      Do While ROprimx < pi: ROprimx = ROprimx + pi: Loop: Do While ROprimx > 2 * pi: ROprimx = ROprimx - pi: Loop
     Anglex = modulo(ARCOS(-(OOmegaMvt / Site(ns).Faille(i).param.Rmvt) * Cos(ROprimx)) - ROprimx - azpmvt - local_AZI, 2 * pi)
      'Do While Anglex < 0: Anglex = Anglex + 2 * pi: Loop: Do While Anglex > 2 * pi: Anglex = Anglex - 2 * pi: Loop
     Site(ns).Faille(i).param.AxeXX = Site(ns).Faille(i).param.Rmvt * Cos(Anglex) + Site(ns).Faille(i).param.xmvt
     Site(ns).Faille(i).param.AxeXY = Site(ns).Faille(i).param.Rmvt * Sin(Anglex) + Site(ns).Faille(i).param.ymvt
      If Site(ns).Faille(i).param.jv = "I" Then
       swap Site(ns).Faille(i).param.AxeXX, Site(ns).Faille(i).param.AxeZX
       swap Site(ns).Faille(i).param.AxeXY, Site(ns).Faille(i).param.AxeZY
      End If
  
     GPRIMARC = Gprimstri - pi / 2
     Roprimarc = Atn(-Tan(GPRIMARC) * Cos(PdPmvt))
      Do While Roprimarc < pi: Roprimarc = Roprimarc + pi: Loop: Do While Roprimarc > 2 * pi: Roprimarc = Roprimarc - pi: Loop
     Anglearc = modulo(ARCOS(-(OOmegaMvt / Site(ns).Faille(i).param.Rmvt) * Cos(Roprimarc)) - Roprimarc - azpmvt - local_AZI, 2 * pi)
      'Do While Anglearc < 0: Anglearc = Anglearc + 2 * pi: Loop: Do While Anglearc > 2 * pi: Anglearc = Anglearc - 2 * pi: Loop
      Site(ns).Faille(i).param.Angledeppmvtz1 = Anglearc
      Site(ns).Faille(i).param.Anglearrpmvtz1 = Anglestri
      Site(ns).Faille(i).param.Angledeppmvtz2 = Anglearc
      Site(ns).Faille(i).param.Anglearrpmvtz2 = Anglearc
      Site(ns).Faille(i).param.Angledeppmvtx1 = angledepmvt
      Site(ns).Faille(i).param.Anglearrpmvtx1 = Anglearc
      Site(ns).Faille(i).param.Angledeppmvtx2 = Anglestri
      Site(ns).Faille(i).param.Anglearrpmvtx2 = anglearrmvt
       If Site(ns).Faille(i).param.jv = "I" Then
        swap Site(ns).Faille(i).param.Angledeppmvtx1, Site(ns).Faille(i).param.Angledeppmvtz1
        swap Site(ns).Faille(i).param.Anglearrpmvtx1, Site(ns).Faille(i).param.Anglearrpmvtz1
        swap Site(ns).Faille(i).param.Angledeppmvtx2, Site(ns).Faille(i).param.Angledeppmvtz2
        swap Site(ns).Faille(i).param.Anglearrpmvtx2, Site(ns).Faille(i).param.Anglearrpmvtz2
       End If
    End If

    If (Site(ns).Faille(i).param.jh = "S" And Site(ns).Faille(i).param.jv = "N") Or (Site(ns).Faille(i).param.jh = "D" And Site(ns).Faille(i).param.jv = "I") Then
     Gprimz = modulo(Gprimstri + teta, pi)
     If Site(ns).Faille(i).param.jv = "I" Then Gprimz = modulo(Gprimstri + (pi / 2 - teta), pi)
      'Do While Gprimz < 0: Gprimz = Gprimz + pi: Loop: Do While Gprimz > pi: Gprimz = Gprimz - pi: Loop
     ROprimz = Atn(-Tan(Gprimz) * Cos(PdPmvt))
      Do While ROprimz < pi: ROprimz = ROprimz + pi: Loop
      Do While ROprimz > 2 * pi: ROprimz = ROprimz - pi: Loop
     Anglez = modulo((ARCOS(-(OOmegaMvt / Site(ns).Faille(i).param.Rmvt) * Cos(ROprimz)) - ROprimz - azpmvt) - local_AZI, 2 * pi)
      'Do While Anglez < 0: Anglez = Anglez + 2 * pi: Loop: Do While Anglez > 2 * pi: Anglez = Anglez - 2 * pi: Loop
     Site(ns).Faille(i).param.AxeZX = Site(ns).Faille(i).param.Rmvt * Cos(Anglez) + Site(ns).Faille(i).param.xmvt
     Site(ns).Faille(i).param.AxeZY = Site(ns).Faille(i).param.Rmvt * Sin(Anglez) + Site(ns).Faille(i).param.ymvt
     Gprimx = modulo(Gprimz + pi / 2, pi)
      'If Gprimx > pi Then Gprimx = Gprimx - pi
     ROprimx = Atn(-Tan(Gprimx) * Cos(PdPmvt))
      Do While ROprimx < pi: ROprimx = ROprimx + pi: Loop: Do While ROprimx > 2 * pi: ROprimx = ROprimx - pi: Loop
     Anglex = modulo((ARCOS(-(OOmegaMvt / Site(ns).Faille(i).param.Rmvt) * Cos(ROprimx)) - ROprimx - azpmvt) - local_AZI, 2 * pi)
      'Do While Anglex < 0: Anglex = Anglex + 2 * pi: Loop: Do While Anglex > 2 * pi: Anglex = Anglex - 2 * pi: Loop
     Site(ns).Faille(i).param.AxeXX = Site(ns).Faille(i).param.Rmvt * Cos(Anglex) + Site(ns).Faille(i).param.xmvt
     Site(ns).Faille(i).param.AxeXY = Site(ns).Faille(i).param.Rmvt * Sin(Anglex) + Site(ns).Faille(i).param.ymvt
      If Site(ns).Faille(i).param.jv = "I" Then
       swap Site(ns).Faille(i).param.AxeXX, Site(ns).Faille(i).param.AxeZX: swap Site(ns).Faille(i).param.AxeXY, Site(ns).Faille(i).param.AxeZY
      End If
     GPRIMARC = Gprimstri + pi / 2
     Roprimarc = Atn(-Tan(GPRIMARC) * Cos(PdPmvt))
      Do While Roprimarc < pi: Roprimarc = Roprimarc + pi: Loop: Do While Roprimarc > 2 * pi: Roprimarc = Roprimarc - pi: Loop
     Anglearc = modulo(ARCOS(-(OOmegaMvt / Site(ns).Faille(i).param.Rmvt) * Cos(Roprimarc)) - Roprimarc - azpmvt - local_AZI, 2 * pi)
      'Do While Anglearc < 0: Anglearc = Anglearc + 2 * pi: Loop: Do While Anglearc > 2 * pi: Anglearc = Anglearc - 2 * pi: Loop
     Site(ns).Faille(i).param.Angledeppmvtz1 = Anglestri
     Site(ns).Faille(i).param.Anglearrpmvtz1 = Anglearc
     Site(ns).Faille(i).param.Angledeppmvtz2 = Anglearc
     Site(ns).Faille(i).param.Anglearrpmvtz2 = Anglearc
     Site(ns).Faille(i).param.Angledeppmvtx1 = angledepmvt
     Site(ns).Faille(i).param.Anglearrpmvtx1 = Anglestri
     Site(ns).Faille(i).param.Angledeppmvtx2 = Anglearc
     Site(ns).Faille(i).param.Anglearrpmvtx2 = anglearrmvt
      If Site(ns).Faille(i).param.jv = "I" Then
       swap Site(ns).Faille(i).param.Angledeppmvtx1, Site(ns).Faille(i).param.Angledeppmvtz1
       swap Site(ns).Faille(i).param.Anglearrpmvtx1, Site(ns).Faille(i).param.Anglearrpmvtz1
       swap Site(ns).Faille(i).param.Angledeppmvtx2, Site(ns).Faille(i).param.Angledeppmvtz2
       swap Site(ns).Faille(i).param.Anglearrpmvtx2, Site(ns).Faille(i).param.Anglearrpmvtz2
      End If
    End If
Exit Sub
Traite_Erreurs5:
   If Erreurs(Err, "Routines / CalculeParametresMesure") Then Resume Next
End Sub

/*}}}*/

;/*}}}*/

