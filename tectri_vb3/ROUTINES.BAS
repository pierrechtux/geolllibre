Dim NomCompletFichier As String
Dim FailleBad()
Dim NbBadFailles
Dim local_AZI, local_pd, local_pitch As Double   'variables temporaires locales pour CalculeParametresMesure

Sub AfficheListeGroupes () '{{{
   On Error GoTo Traite_Erreurs1:
   If flag = flag_chargement Then Exit Sub
   'Afficher la liste des groupes de tri, avec les populations.
   On Error Resume Next
      NbTotalMesures = 0
      For nsns = 1 To NbStations
	 If Not (Site(nsns).deleted) Then
	    If Not (Affich_F_Stations_Icones = False And frm_Station(nsns).WindowState = REDUIT) Then
	       NbTotalMesures = NbTotalMesures + Site(nsns).NbMes
	    End If
	 End If
      Next
      If NbTotalMesures = 0 Then NbTotalMesures = 1'pour avoid division par 0
      For index = 0 To NbGroupesdeTri
	 '***remplacer ce code
	    GroupTri!PopulationGroupe(index).Cls
	    GroupTri!PopulationGroupe(index).Line (NbMesSelect%(index) * GroupTri!PopulationGroupe(index).Width / NbTotalMesures, GroupTri!PopulationGroupe(index).Height)-(0, 0), CouleurGroupe(index), BF
	  ' GroupTri!PopulationGroupe(index).ForeColor = (CouleurGroupe(index)) Or (GroupTri!PopulationGroupe(index).BackColor)
	    GroupTri!PopulationGroupe(index).ForeColor = (CouleurGroupe(index)) And (GroupTri!PopulationGroupe(index).BackColor)
	    GroupTri!PopulationGroupe(index).DrawStyle = 5
	    'GroupTri!PopulationGroupe(index).ForeColor = (Not (CouleurGroupe(index)) Or Not (GroupTri.BackColor))
	    'GroupTri!PopulationGroupe(index).ForeColor = GroupTri.BackColor
	    'GroupTri!PopulationGroupe(index).ForeColor = (CouleurGroupe(index) And GroupTri.BackColor)
	    GroupTri!PopulationGroupe(index).Print NbMesSelect%(index)
	 '***
	 '/*** code de remplacement
       '  GroupTri!shpBar(index).Width = GroupTri!Label_Population_Groupe(index).Width * NbMesSelect%(index) / NbTotalMesures
       '  'NbMesSelect%(index) * GroupTri!PopulationGroupe(index).Width / NbTotalMesures
       '  GroupTri!Label_Population_Groupe(index).Caption = NbMesSelect%(index)
	 '***/
      Next
Exit Sub
Traite_Erreurs1:
   If Erreurs(Err, "Routines / AfficheListeGroupes") Then Resume Next
End Sub
'}}}
Function AnyPadsLeft () As Integer '{{{
   On Error GoTo Traite_Erreurs2:
    Dim i As Integer

    ' Parcourt le tableau de documents.
    ' Renvoie True s'il reste au moins
    ' un document ouvert.
    For i = 1 To UBound(Site)
	If Not Site(i).deleted Then
	    AnyPadsLeft = True
	    Exit Function
	End If
    Next
Exit Function
Traite_Erreurs2:
   If Erreurs(Err, "Routines / AnyPadsLeft") Then Resume Next
End Function
'}}}
Sub bye_bye () '{{{
   On Error GoTo Traite_Erreurs3:
   If MDI!menu_sauve_parametres.Checked Then SauveTectriIni
   prompt "Fin de session"
   '***options générales
      CR$ = Chr$(13) + Chr$(10)
      TheMessage$ = "Fin de session Tectri?"
      TheStyle = 292 - 256
      TheTitle$ = "Tectri"
      TheAnswer = MsgBox(TheMessage$, TheStyle, TheTitle$)
   If TheAnswer = 6 Then  'Answered Yes
      flag = flag_quitter
      Ferme_Tout
	 If flag = flag_quitter Then
	    End
	 Else
	    Exit Sub
	 End If
       'Unload MDI
   Else     'Answered No

   End If
Exit Sub
Traite_Erreurs3:
   If Erreurs(Err, "Routines / bye_bye") Then Resume Next
End Sub
'}}}
Sub CalculeFichier () '{{{
   On Error GoTo Traite_Erreurs4:
 prompt "Calcul des paramètres géométriques de " & Site(ns).NomFichier
 MDI!lblStatus.Refresh
 On Error Resume Next
 NbBadFailles = 0
 If teta = 0 Then teta = pi / 6
 ' PRINT USING "Tˆta=##.#ø"; Teta * 180 / pi; : PRINT
    '**** Qu'est ceci? ***
    'If Site(ns).NbMes = 0 Then
    '    TratrTectri$ = TestFormatFicTratrTectri$(Site(ns).NomFichier)
    '    Open Site(ns).NomFichier For Input As #1
    '       Line Input #1, Entete$
    '       LitFicPartieDat
    '    Close #1
    '    Kill Site(ns).NomFichier
    '    Open Site(ns).NomFichier For Output As #1
    '       Print #1, Entete$
    '       EcritFicPartieDat ns
    '          If TratrTectri$ = "tratr" Then
    '             Print #1, Chr$(26)
    '          End If
    '    Close #1
    ' End If
   For i = 1 To Site(ns).NbMes
      prompt "Calcul de " + Site(ns).NomFichier + " : " + Str$(i) + "/" + Str$(Site(ns).NbMes)
      MDI!lblStatus.Refresh
      'DecryptageMesure (Site(ns).Faille(i).mesure)
	 If (Checke_Mesure(Site(ns).Faille(i).azi, Site(ns).Faille(i).Pd, Site(ns).Faille(i).DirPd, Site(ns).Faille(i).pitch, Site(ns).Faille(i).dirpi, Site(ns).Faille(i).jeu)) Then
	    CalculeParametresMesure
	 Else
	    NbBadFailles = NbBadFailles + 1
	    FailleBad(NbBadFailles) = i
	 End If
   Next i
prompt ""
Exit Sub
Traite_Erreurs4:
   If Erreurs(Err, "Routines / CalculeFichier") Then Resume Next
End Sub
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
'}}}
Sub cherche_comment () '{{{
   On Error GoTo Traite_Erreurs6:
   'sélection de mesures d'après une recherche dans les commentaires
   chaine_a_chercher = InputBox("Chaîne de caractères à identifier:", "Sélection de failles")
   If chaine_a_chercher = "" Then Exit Sub
   screen.MousePointer = 11
   nsavant = ns
   iavant = i
   For ns = 1 To NbStations
      If Not (Site(ns).deleted) Then
	 If Not (Affich_F_Stations_Icones = False And frm_Station(ns).WindowState = REDUIT) Then
	    For i = 1 To Site(ns).NbMes
	       Mesure = Site(ns).Faille(i).azi + sep$ + Site(ns).Faille(i).Pd + sep$ + Site(ns).Faille(i).DirPd + sep$ + Site(ns).Faille(i).pitch + sep$ + Site(ns).Faille(i).dirpi + sep$ + Site(ns).Faille(i).jeu + sep$ + Site(ns).Faille(i).Commentaire
	       If InStr(Mesure, chaine_a_chercher) Then
		  SélectionMesure (0)
		  Tracage St!Stereo
	       End If
	    Next
	 End If
      End If
   Next
   ns = nsavant
   i = iavant
   MetàJourListeGroupe
   screen.MousePointer = defaut
Exit Sub
Traite_Erreurs6:
   If Erreurs(Err, "Routines / cherche_comment") Then Resume Next
End Sub
'}}}
Sub ColleRange () '{{{
   On Error GoTo Traite_Erreurs7:
   prompt "Colle depuis le presse-papiers"
   
   'Si presse-papier au format texte, ok, sinon, out
   If Not (clipboard.GetFormat(1)) Then Beep: Exit Sub
   AColler$ = clipboard.GetText()
   
   frm_Station(ns).Grille.HighLight = False
   
   'on sauve position dans data
   SelStartCo = frm_Station(ns).Grille.SelStartCol
   SelEndCo = frm_Station(ns).Grille.SelEndCol
   Co = frm_Station(ns).Grille.Col
   SelStartRo = frm_Station(ns).Grille.SelStartRow
   SelEndRo = frm_Station(ns).Grille.SelEndRow
   Ro = frm_Station(ns).Grille.Row

    ' Initialise les nouvelles variables de colonne (NC) & de ligne (NR).
    NC = Chr$(9)
    NR = Chr$(13) & Chr$(10)
   
   'Si le dernier caractère est un RC, le virer (cas des clips XL, engendrant une ligne vide)
   If Len(AColler$) > 1 Then
      If Mid$(AColler$, Len(AColler$) - 1, 1) = Chr$(13) Then
	 AColler$ = Left(AColler$, Len(AColler$) - 2)
      End If
   End If

   'Détermination du nb de cols du presse-papier
   test$ = Left$(AColler$, InStr(AColler$, NR) + 1)
   If InStr(AColler$, NR) = 0 Then test$ = AColler$
   If Len(test$) > 0 Then NbCols = 1:  Else GoTo Out:
    For Count = 1 To Len(test$)
	' Si le caractère en cours est un tab
	If Mid$(test$, Count, 1) = NC Then NbCols = NbCols + 1
    Next Count

   'Détermination du nb de rows du presse-papier
   test$ = AColler$
   If Len(test$) > 0 Then NbRows = 1:  Else GoTo Out:
    For Count = 1 To Len(test$)
	' Si le caractère en cours est un rc
	If Mid$(test$, Count, 1) = Chr$(13) Then NbRows = NbRows + 1
    Next Count
   
   'Si pas assez de rows, en ajouter
   Rows_JustInCase = frm_Station(ns).Grille.Rows 'sauver avant modif
   If frm_Station(ns).Grille.SelStartRow + NbRows > frm_Station(ns).Grille.Rows - 1 Then
      frm_Station(ns).Grille.Rows = frm_Station(ns).Grille.SelStartRow + NbRows + 1'1 ligne vide
   End If

   'sauver le contenu précédent de frm_Station(ns) dans une variable, just in case...
   frm_Station(ns).Grille.SelStartCol = frm_Station(ns).Grille.Col
   frm_Station(ns).Grille.SelEndCol = Min(frm_Station(ns).Grille.SelStartCol + NbCols - 1, frm_Station(ns).Grille.Cols - 1)
   frm_Station(ns).Grille.SelStartRow = frm_Station(ns).Grille.Row
   frm_Station(ns).Grille.SelEndRow = Min(frm_Station(ns).Grille.SelStartRow + NbRows - 1, max(frm_Station(ns).Grille.Rows - 2, 1))
   
   clip_SelStartCol = frm_Station(ns).Grille.SelStartCol
   clip_SelEndCol = frm_Station(ns).Grille.SelEndCol
   clip_SelStartRow = frm_Station(ns).Grille.SelStartRow
   clip_SelEndRow = frm_Station(ns).Grille.SelEndRow
   
   JustInCase = frm_Station(ns).Grille.Clip

   'Coller
   frm_Station(ns).Grille.Clip = AColler$

   'Checker toutes les mesures modifiées
   NbBadFailles = 0
   i1 = frm_Station(ns).Grille.SelStartRow '- 1
   i2 = frm_Station(ns).Grille.SelEndRow '- 1
   For i = i1 To i2
      'Debug.Print i; "/"; Site(ns).NbMes; "---->"; Site(ns).faille(i).mesure
      prompt "Calcul des paramètres géométriques de " + Site(ns).NomFichier + ": " + Str$(i) + "/" + Str$(max(i, Site(ns).NbMes))
      MDI!lblStatus.Refresh
      flag = True
      frm_Station(ns).Grille.Row = i
      frm_Station(ns).Grille.Col = 1
      flag = False
      frm_Station(ns).Grille.SelStartCol = 1
      frm_Station(ns).Grille.SelEndCol = frm_Station(ns).Grille.Cols - 1
      frm_Station(ns).Grille.SelStartRow = i
      frm_Station(ns).Grille.SelEndRow = i
      Mesure = frm_Station(ns).Grille.Clip
      DecryptageMesure (Mesure)
      For rien = 1 To Len(Mesure)
	 If Mid$(Mesure, rien, 1) = NC Then Mid$(Mesure, rien, 1) = " "
      Next
	 If Entre_faille_courante(i, Site(ns).Faille(i).azi, Site(ns).Faille(i).Pd, Site(ns).Faille(i).DirPd, Site(ns).Faille(i).pitch, Site(ns).Faille(i).dirpi, Site(ns).Faille(i).jeu, Site(ns).Faille(i).Commentaire) Then
	    'tvb'old:CalculeParametresMesure
	 Else
	    NbBadFailles = NbBadFailles + 1
	    FailleBad(NbBadFailles) = i
	 End If
   Next i
   
   If NbBadFailles > 0 Then
      'Ca va pas
      TheMessage$ = "corriger ces erreurs?"
      TheStyle = 305
      'TheTitle$ = "MsgBox Editor"
      TheAnswer = MsgBox(TheMessage$, TheStyle)
	 If TheAnswer = 1 Then  'Answered OK
	    MsgBox "Correction de mesures de failles incorrectes"
	    Saisie_mesure.suivante.Enabled = False
	    Saisie_mesure.precedente.Enabled = False
	    Saisie_mesure.annule.Enabled = False
	       For k = 1 To NbBadFailles
		  i = FailleBad(k)
		  'screen.MousePointer = 11
		  Saisie_mesure.Show 1
		  'saise_mesure (ns,i), avec >, <, et cancel disabled
	       Next
	    Saisie_mesure.suivante.Enabled = True
	    Saisie_mesure.precedente.Enabled = True
	    Saisie_mesure.annule.Enabled = True
	 Else     'Answered Cancel
	    'si renoncement, on remet tout en l'état
	    frm_Station(ns).Grille.SelStartCol = clip_SelStartCol
	    frm_Station(ns).Grille.SelEndCol = clip_SelEndCol
	    frm_Station(ns).Grille.SelStartRow = clip_SelStartRow
	    frm_Station(ns).Grille.SelEndRow = clip_SelEndRow
	    
	    frm_Station(ns).Grille.Clip = JustInCase
	    frm_Station(ns).Grille.Rows = Rows_JustInCase - 1
	    frm_Station(ns).Grille.Rows = Rows_JustInCase
	    GoTo Out:
	 End If
   Else        'tvb
   End If
   'If frm_Station(ns).Grille.Rows > Rows_JustInCase Then
   Site(ns).NbMes = frm_Station(ns).Grille.Rows - 2
   DimensionneVariables
   DimensionneObjets
   MetàJourStation
   MetàJourListeGroupe
   RedessinStereo St!Stereo
   If Site(ns).dirty <> True Then Site(ns).dirty = True
   
   'on se remet à position dans data
    frm_Station(ns).Grille.SelStartCol = SelStartCo
    frm_Station(ns).Grille.SelEndCol = SelEndCo
    frm_Station(ns).Grille.Col = Co
    frm_Station(ns).Grille.SelStartRow = SelStartRo
    frm_Station(ns).Grille.SelEndRow = SelEndRo
    frm_Station(ns).Grille.Row = Ro
Out: frm_Station(ns).Grille.HighLight = True
prompt ""
Exit Sub
Traite_Erreurs7:
   If Erreurs(Err, "Routines / ColleRange") Then Resume Next
End Sub
'}}}
Sub CopieRange () '{{{
   On Error GoTo Traite_Erreurs8:
    prompt "Copie vers le presse-papiers"
    ' Déclare les variables locales.
    Dim ClipText
    Dim CopyText
    Dim NC
    Dim NR
    Dim Count
    Dim ColStrt
    Dim ColEnd
    Dim RowStrt
    Dim RowEnd
    Dim HeadTxt
    ' Initialise les nouvelles variables de colonne (NC) & de ligne (NR).
    NC = Chr$(9)
    NR = Chr$(13) & Chr$(10)
    ' Initialise les variables pour lignes/col sélectionnées.
     ColStrt = frm_Station(ns).Grille.SelStartCol
     ColEnd = frm_Station(ns).Grille.SelEndCol
     RowStrt = frm_Station(ns).Grille.SelStartRow
     RowEnd = frm_Station(ns).Grille.SelEndRow
    'redimensionne sélection pour avoid dernière ligne vide
     If frm_Station(ns).Grille.SelEndRow > Site(ns).NbMes Then frm_Station(ns).Grille.SelEndRow = Site(ns).NbMes
    ' Initialise la variable qui reçoit des entrées à partir de la grille.
     ClipText = frm_Station(ns).Grille.Clip
    ' Initialise la variable qui contient la sortie au Presse-papiers.
     CopyText = ""
   ' ' Ligne d'en-tête = ligne actuelle
   '  frm_Station(ns).Grille.Row = 0
   ' ' Pour chaque cellule de la ligne d'en-tête
   ' For Count = ColStrt To ColEnd
   '     ' Définit la colonne en cours
   '     frm_Station(ns).Grille.Col = Count
   '     HeadTxt = Mid$(frm_Station(ns).Grille.Text, 2, Len(frm_Station(ns).Grille.Text) - 1)
   '     ' Copie l'en-tête de colonne dans la variable de sortie.
   '     CopyText = CopyText & NC & HeadTxt
   ' Next Count
  '  CopyText = CopyText & NR
  '  ' Ajoute l'en-tête de 1ère ligne à la variable de sortie.
  '  grdPayments.Col = 0
  '  grdPayments.Row = RowStrt
  '  CopyText = CopyText & grdPayments.Text & NC
    ' Copie le texte de la variable d'entrée dans la variable de sortie.
    For Count = 1 To Len(ClipText)
	' Si le caractère en cours n'est pas un retour chariot
	If Mid$(ClipText, Count, 1) <> Chr$(13) Then
	    ' Attache le caractère à la variable de sortie.
	    CopyText = CopyText & Mid$(ClipText, Count, 1)
	' Si le caractère en cours est un retour chariot
	Else
	    ' Atache un retour chariot/retour ligne à la varirable de sortie.
	    'frm_Station(ns).Grille.Row = frm_Station(ns).Grille.Row + 1
	    CopyText = CopyText & NR
	End If
    Next Count
  '  ' Copie le contenu de la variable de sortie dans le Presse-papiers.
    clipboard.SetText CopyText 'ClipText
prompt ""
Exit Sub
Traite_Erreurs8:
   If Erreurs(Err, "Routines / CopieRange") Then Resume Next
End Sub
'}}}
Function CouleurMesureàProjeter (ByVal couleurfond As Long, ByVal switch_) As Long '{{{
   On Error GoTo Traite_Erreurs9:
   'Retourne couleur du groupe  ou  couleurfond, selon que
   'la mesure ns,i doive être projetée ou non
      'couleur du groupe virée, pour éviter bug si couleur du groupe est noire (&h0)
      'cleur& = (Site(ns).faille(i).GroupeTri >= 0) * Affichage(Site(ns).faille(i).GroupeTri) * CouleurGroupe(Site(ns).faille(i).GroupeTri)
   If Site(ns).Faille(i).GroupeTri >= 0 Then
      temp& = -MDI!menu_projettegroupe(Site(ns).Faille(i).GroupeTri).Checked          'Affichage(Site(ns).Faille(i).GroupeTri)'* CouleurGroupe(Site(ns).Faille(i).GroupeTri)
   Else
      temp& = 0
   End If
   If temp& = 0 Or Not (switch_) Then
      temp& = couleurfond
   Else
      temp& = temp& * CouleurGroupe(Site(ns).Faille(i).GroupeTri)
   End If
     CouleurMesureàProjeter = temp&
Exit Function
Traite_Erreurs9:
   If Erreurs(Err, "Routines / CouleurMesureàProjeter") Then Resume Next
End Function
'}}}
Sub CreatFicPgmTRATR (NomFichier$) '{{{
   On Error GoTo Traite_Erreurs10:
'Créat° d'un fichier pouvant être utilisé directement par le calcul de tenseurs tratr Mercier, en y mettant toutes les mesures affichées au stéréo.
'Print "Création d'un fichier tecto pour le programme de calculs de tenseurs Mercier."
' INPUT "Répertoire\nom du fichier à créer "; NomFichier$
 'IF NomFichier$ = "" THEN CLS 2: EXIT SUB
  On Error Resume Next
  ReDim Elt$(6)
   CompteTotal = NbMesuresAffichees()
      If CompteTotal = 0 Then
	 Beep
	 CR$ = Chr$(13) + Chr$(10)
	 TheMessage$ = "Erreur: aucune mesure sélectionnée..."
	 TheStyle = 16
	 TheTitle$ = ""
	 MsgBox TheMessage$, TheStyle, TheTitle$
	 Exit Sub
       End If
   Open NomFichier$ For Output As #2
      Write #2, CompteTotal
	 nsi = ns
	 For ns = 1 To NbStations
	    If Not (Site(ns).deleted) Then
	       If Not (Affich_F_Stations_Icones = False And frm_Station(ns).WindowState = REDUIT) Then
		  For i = 1 To Site(ns).NbMes
		     If Site(ns).Faille(i).GroupeTri <> -1 Then
			If MDI!menu_projettegroupe(Site(ns).Faille(i).GroupeTri).Checked Then
			   For h = 1 To 6: aecrire$ = aecrire$ + Elt$(h) + ",": Next
			   aecrire$ = Site(ns).Faille(i).azi + "," + Site(ns).Faille(i).Pd + "," + Site(ns).Faille(i).DirPd
			   aecrire$ = aecrire$ + "," + Site(ns).Faille(i).pitch + "," + Site(ns).Faille(i).dirpi
			   aecrire$ = aecrire$ + "," + Site(ns).Faille(i).jeu + "," + Str$(i)
			   Print #2, aecrire$: aecrire$ = ""
			   For Rg = 1 To 6: Elt$(Rg) = "": Next
			End If
		     End If
		  Next i
	       End If
	    End If
	 Next ns
	 ns = nsi
      Print #2, Chr$(26)
   Close #2
Exit Sub
Traite_Erreurs10:
   If Erreurs(Err, "Routines / CreatFicPgmTRATR") Then Resume Next
End Sub
'}}}
Sub CtrlF9 () '{{{
   St!bmp.Picture = LoadPicture("")
   F9
End Sub
'}}}
Sub DecryptageMesure (fault As String) '{{{
   On Error GoTo Traite_Erreurs11:
   Select Case Left$(Site(ns).format, 5)
      Case "tectr"
	 Separation$ = " " + Chr$(9)
      Case Else
	 Separation$ = " ,;" + Chr$(9)
   End Select
 Site(ns).Faille(i).azi = (GetToken$(fault, Separation$))
 Site(ns).Faille(i).Pd = (GetToken$("", Separation$))
 Site(ns).Faille(i).DirPd = GetToken$("", Separation$)
 Site(ns).Faille(i).pitch = (GetToken$("", Separation$))
 Site(ns).Faille(i).dirpi = GetToken$("", Separation$)
 Site(ns).Faille(i).jeu = GetToken$("", Separation$)
 Site(ns).Faille(i).Commentaire = Trim$(GetToken$("", "[]" + Trim$(Separation$)))
Exit Sub
Traite_Erreurs11:
   If Erreurs(Err, "Routines / DecryptageMesure") Then Resume Next
End Sub
'}}}
Sub Demo () '{{{
   If i > 8 Or ns > 1 Then MsgBox ("Version d'évaluation limitée " + Chr$(13) + Chr$(10) + "à 1 sites de 8 failles" + Chr$(13) + Chr$(10) + "Arrêt du programme"): Stop
End Sub
'}}}
Sub DimensionneObjets () '{{{
   On Error GoTo Traite_Erreurs12:
   ReDim Preserve frm_Station(NbStations)'MAX(NbStations, 2))     ' (NbStations)
'   Tableau.Grille.Rows = max(NbStations + 1, 2)
      imax = 1
      nsi = ns
      flagi = flag
	 If NbStations = 1 Then 'And (Site(1).deleted) Then
	    'il reste qu'1 site, et il est effacé
	    flag = flag_chargement
	 End If
	 For ns = 1 To NbStations
	    If Site(ns).deleted <> True Then
	       imax = max(imax, Site(ns).NbMes)
	       '***déconne***
	       frm_Station(ns).Tag = ns
	       '*************
	    End If
	 Next
      ns = nsi
      flag = flagi
Exit Sub
Traite_Erreurs12:
   If Erreurs(Err, "Routines / DimensionneObjets") Then Resume Next
End Sub
'}}}
Sub DimensionneVariables () '{{{
   On Error GoTo Traite_Erreurs13:
   ReDim Preserve Site(max(NbStations, 2))'(nsmax)
      imax = 1
      nsi = ns
	 For ns = 1 To NbStations
	    If Not (Site(ns).deleted) Then imax = max(imax, Site(ns).NbMes)
	 Next
      ns = nsi
      If flag <> flag_RechargerFichier Then
	 ReDim Preserve Faille(imax)
      Else
	 ReDim Faille(imax)
      End If
Exit Sub
Traite_Erreurs13:
   If Erreurs(Err, "Routines / DimensionneVariables") Then Resume Next
End Sub
'}}}
Sub DropFaille (index As Integer, source As Control) '{{{
   On Error GoTo Traite_Erreurs__2:
   nsavant = ns
   'ObjetDéposéIcon = Source.DragIcon
   'If Source.Tag = "" Then
      If index <= NbGroupesdeTri And index >= 0 Then
	 GroupTri!CommentaireGroupe(index).BackColor = FOND_FENETRE
	 GroupTri!CommentaireGroupe(index).ForeColor = TEXTE_FENETRE
      End If
   atrier$ = source.Tag
      If Len(atrier$) > 1 Then
	 ns = Val(GetToken$(atrier$, " " + Chr$(9)))
	    Do
	       i = Val(GetToken$("", " " + Chr$(9) + Chr$(10)))
	       If ns = 0 Or i = 0 Then Exit Do
	       SélectionMesure (index)
	       Tracage St!Stereo
	       ns = Val(GetToken$("", " " + Chr$(9) + Chr$(10)))
	    Loop Until ns = 0
	 ns = nsavant
      Else
	 If Val(atrier$) = index Then
	    'on lâche le groupe sur lui-même: proj° du groupe
	    If index <> 0 Then GroupTri!CocheProjectionGroupe(index).Value = Abs(Not (-Abs(GroupTri!CocheProjectionGroupe(index).Value)))
	    Exit Sub
	 End If
	 'tri d'un groupe de tri vers un autre
	 screen.MousePointer = 11
	    iavant = i
	    For ns = 1 To NbStations
	       If Not (Site(ns).deleted) Then
		  If Not (Affich_F_Stations_Icones = False And frm_Station(ns).WindowState = REDUIT) Then
		     For i = 1 To Site(ns).NbMes
			If Site(ns).Faille(i).GroupeTri = Val(atrier$) Then
			   SélectionMesure (index)
			   Tracage St!Stereo
			End If
		     Next
		  End If
	       End If
	    Next
	    i = iavant
	 screen.MousePointer = defaut
      End If
   MetàJourListeGroupe
   ns = nsavant
   If St.EtiquetteInfo.Visible Then St.EtiquetteInfo.Visible = False
Exit Sub
Traite_Erreurs__2:
   If Erreurs(Err, "TenseurFocStri / DropFaille") Then Resume Next
End Sub
'}}}
Sub EcritFicPartieCal (nsns As Integer) '{{{
   On Error GoTo Traite_Erreurs14:
      NomCompletFichier = Site(nsns).NomFichier
  If Site(nsns).format = "tectri_parametres" Then
    Close #1
     Open NomCompletFichier For Append As #1
      Print #1, Chr$(13)
      Write #1, "*** Paramètres géométriques - effacer en cas d'édition des données ***", Site(nsns).NbMes   'Write #1, Site(nsns).Situation, Site(nsns).NbMes
       For i = 1 To Site(nsns).NbMes
	'Dans la version qb, l'input tenait sur une ligne: ce n'est hélas plus possible...
	'Pour EnregistrePartieCal, il faut interposer quelques variables intermédiaires........................
	a1 = 0'Site(nsns).Faille(i).azi
	a2 = 0'Site(nsns).Faille(i).Pd
	a3 = 0'Site(nsns).Faille(i).pitch
	a4 = Site(nsns).Faille(i).param.azstri
	a5 = Site(nsns).Faille(i).param.ox
	a6 = Site(nsns).Faille(i).param.oy
	a7 = Site(nsns).Faille(i).param.r
	a8 = Site(nsns).Faille(i).param.PolX
	a9 = Site(nsns).Faille(i).param.PolY
	a10 = Site(nsns).Faille(i).param.Angledep
	a11 = Site(nsns).Faille(i).param.Anglearr
	a12 = Site(nsns).Faille(i).param.SX
	a13 = Site(nsns).Faille(i).param.SY
	a14 = Site(nsns).Faille(i).param.sax
	a15 = Site(nsns).Faille(i).param.say
	a16 = Site(nsns).Faille(i).param.sfx
	a17 = Site(nsns).Faille(i).param.sfy
	a18 = Site(nsns).Faille(i).param.AxeYX
	a19 = Site(nsns).Faille(i).param.AxeYY
	a20 = Site(nsns).Faille(i).param.xmvt
	a21 = Site(nsns).Faille(i).param.ymvt
	a22 = Site(nsns).Faille(i).param.Rmvt
	a23 = Site(nsns).Faille(i).param.Angledeppmvtx1
	a24 = Site(nsns).Faille(i).param.Anglearrpmvtx1
	a25 = Site(nsns).Faille(i).param.Angledeppmvtx2
	a26 = Site(nsns).Faille(i).param.Anglearrpmvtx2
	a27 = Site(nsns).Faille(i).param.Angledeppmvtz1
	a28 = Site(nsns).Faille(i).param.Anglearrpmvtz1
	a29 = Site(nsns).Faille(i).param.Angledeppmvtz2
	a30 = Site(nsns).Faille(i).param.Anglearrpmvtz2
	a31 = Site(nsns).Faille(i).param.AxeZX
	a32 = Site(nsns).Faille(i).param.AxeZY
	a33 = Site(nsns).Faille(i).param.AxeXX
	a34 = Site(nsns).Faille(i).param.AxeXY
	a35 = Site(nsns).Faille(i).param.Xaux
	a36 = Site(nsns).Faille(i).param.Yaux
	a37 = Site(nsns).Faille(i).param.Raux
	a38 = Site(nsns).Faille(i).param.AngleDepAux
	a39 = Site(nsns).Faille(i).param.AngleArrAux
	a40 = Site(nsns).Faille(i).param.jv
	a41 = Site(nsns).Faille(i).param.jh
	Write #1, " ", a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25, a26, a27, a28, a29, a30, a31, a32, a33, a34, a35, a36, a37, a38, a39, a40, a41', a42
       Next
     Close #1
   End If
Exit Sub
Traite_Erreurs14:
   If Erreurs(Err, "Routines / EcritFicPartieCal") Then Resume Next
End Sub
'}}}
Sub EcritFicPartieDat (nsns As Integer) '{{{
   On Error GoTo Traite_Erreurs15:
   If (Left$(Site(ns).format, 6) = "tectri" Or Site(ns).format = "") Then
      sep$ = Separateur_champs$
      If sep$ = "" Then sep$ = Chr$(9)
   Else
      sep$ = ","
   End If
      For i = 1 To Site(nsns).NbMes
	 Mesure = Site(ns).Faille(i).azi + sep$ + Site(ns).Faille(i).Pd + sep$ + Site(ns).Faille(i).DirPd + sep$ + Site(ns).Faille(i).pitch + sep$ + Site(ns).Faille(i).dirpi + sep$ + Site(ns).Faille(i).jeu
	 If sep$ = "," Then
	    Mesure = Mesure + sep$ + Str$(i)
	 Else
	    Mesure = Mesure + sep$ + Site(ns).Faille(i).Commentaire
	    If Site(nsns).Faille(i).GroupeTri >= 0 Then
	       Mesure = Mesure + "[" + SymboleGroupeDeTri(Site(nsns).Faille(i).GroupeTri) + "]"
	    End If
	 End If
	 Print #1, Mesure
      Next
   '
   'For i = 1 To Site(nsns).NbMes
   '   If Site(nsns).Faille(i).GroupeTri >= 0 Then
   '      Print #1, Site(nsns).Faille(i).mesure + "[" + SymboleGroupeDeTri(Site(nsns).Faille(i).GroupeTri) + "]"
   '   Else
   '      Print #1, Site(nsns).Faille(i).mesure
   '   End If
   'Next
Exit Sub
Traite_Erreurs15:
   If Erreurs(Err, "Routines / EcritFicPartieDat") Then Resume Next
End Sub
'}}}
Sub EnregistreLaStation (nsns As Integer) '{{{
   On Error GoTo Traite_Erreurs16:
   If Site(nsns).NomFichier = "" Or Left(Site(nsns).NomFichier, 11) = "(sans-titre" Then EnregistreSous
   NomCompletFichier = Site(nsns).NomFichier
   prompt "Ecriture du fichier " & NomCompletFichier
   On Error Resume Next
      If Fichiers_Bkp Then BackUp (NomCompletFichier) 'Else Kill NomCompletFichier
   Open NomCompletFichier For Output As #1
	 If (Left$(Site(ns).format, 6) = "tectri" Or Site(ns).format = "") Then
	    Err = 0
	    dummy = CDbl(Site(nsns).Situation$)
	    If Err = 0 Then
	       Site(nsns).Situation$ = "'" & Site(nsns).Situation$
	    End If
	    Err = 0
	    Entete$ = Site(nsns).Situation '+ "," + Str$(NOS) + "," + Str$(Site(nsns).NbMes)
	 Else
	    Entete$ = Str$(Site(nsns).NbMes)
	 End If
      Print #1, Entete$
      EcritFicPartieDat nsns
	 If Left$(Site(nsns).format, 5) = "tratr" Then 'If TratrTectri$ = "tratr" Then
	    Print #1, Chr$(26)
	 End If
      'EcritFicPartieCal nsns
   Close #1
   Site(nsns).dirty = False
   prompt ""
Exit Sub
Traite_Erreurs16:
   If Erreurs(Err, "Routines / EnregistreLaStation") Then Resume Next
End Sub
'}}}
Sub EnregistreLesStations () '{{{
   On Error GoTo Traite_Erreurs17:
   screen.MousePointer = 11
   'Print "Sauvegarde des stations en m‚moire et de leurs s‚lections."
      For nsns = 1 To NbStations
	 If Not (Site(nsns).deleted) Then EnregistreLaStation (nsns)
      Next
   screen.MousePointer = defaut
Exit Sub
Traite_Erreurs17:
   If Erreurs(Err, "Routines / EnregistreLesStations") Then Resume Next
End Sub
'}}}
Sub EnregistreSous () '{{{
   On Error Resume Next
   MDI!CMDialog.DialogTitle = "TecTri: enregistrer sous"
      If Site(ns).NomFichier = "" Or Left(Site(ns).NomFichier, 11) = "(sans-titre" Then
	 MDI!CMDialog.Filename = ""
      Else
	 MDI!CMDialog.Filename = Site(ns).NomFichier
      End If
   'MDI!CMDialog.DefaultExt = "tec"
   MDI!CMDialog.Flags = &H2& Or &H4&
   MDI!CMDialog.Filter = "Tectri (*.tec)|*.tec|Tectri rapide (*.tec)|*.tec|Calcul tenseur (*. )|*. |Tous fichiers (*.*)|*.*"
      'format du fichier
      Select Case Site(ns).format
	 Case "tectri"                 'format tectri
	    If Fichiers_Param <> 0 Then Site(ns).format = "tectri_parametres": MDI!CMDialog.FilterIndex = 2:  Else MDI!CMDialog.FilterIndex = 1
	 Case "tectri_parametres"      'format tectri param's
	    If Fichiers_Param = 0 Then Site(ns).format = "tectri": MDI!CMDialog.FilterIndex = 1:  Else MDI!CMDialog.FilterIndex = 2
	 Case "tratr"                  'format tratr
	    MDI!CMDialog.FilterIndex = 3
	 Case Else                     'format non défini
	    If Fichiers_Param <> 0 Then MDI!CMDialog.FilterIndex = 2:  Else MDI!CMDialog.FilterIndex = 1
      End Select
   MDI!CMDialog.CancelError = True
   MDI!CMDialog.Action = 2
      If Err Then Exit Sub
   On Error GoTo Traite_Erreurs18:
   screen.MousePointer = 11
   f$ = MDI!CMDialog.Filename
   If InStr(f$, ".") = 0 Then f$ = f$ + ".   " 'pour éviter erreur qd tentative chgt station pour tratr
   Site(ns).NomFichier = LCase$(f$)
      Select Case MDI!CMDialog.FilterIndex
      '**va pas, FilterIndex indique l'option PAR DEFFAUT
	 Case 1
	    Site(ns).format = "tectri"
	 Case 2
	    Site(ns).format = "tectri_parametres"
	 Case 3
	    Site(ns).format = "tratr"
      End Select
   EnregistreLaStation (ns)
   frm_Station(ns).Caption = LCase$(Site(ns).NomFichier)
   UpdateFileMenu (Site(ns).NomFichier)
   screen.MousePointer = defaut
Exit Sub
Traite_Erreurs18:
   If Erreurs(Err, "Routines / EnregistreSous") Then Resume Next
End Sub
'}}}
Sub EnregistreTout () '{{{
   On Error GoTo Traite_Erreurs41:
   screen.MousePointer = 11
   nsi = ns
      For ns = 1 To NbStations
	 If Not (Site(ns).deleted) Then EnregistreLaStation (ns)
      Next
   ns = nsi
   screen.MousePointer = defaut
Exit Sub
Traite_Erreurs41:
   If Erreurs(Err, "Routines / EnregistreSous") Then Resume Next
End Sub
'}}}
Function Entre_faille_courante (i, ByVal azi, ByVal Pd, ByVal DirPd, ByVal pitch, ByVal dirpitch, ByVal jeu, ByVal Commentaire) '{{{
   On Error GoTo Traite_Erreurs19:
   If Not (Checke_Mesure(azi, Pd, DirPd, pitch, dirpitch, jeu) = True) Then
      Entre_faille_courante = False
   Else
      Site(ns).Faille(i).azi = azi
      Site(ns).Faille(i).Pd = Pd
      Site(ns).Faille(i).DirPd = DirPd
      Site(ns).Faille(i).pitch = pitch
      Site(ns).Faille(i).dirpi = dirpitch
      Site(ns).Faille(i).jeu = jeu
      Site(ns).Faille(i).Commentaire = Commentaire
      CalculeParametresMesure
      'Site(ns).NbMes = Site(ns).NbMes + 1
	 If Saisie_mesure.Visible Then
	    Site(ns).Faille(i).GroupeTri = Saisie_mesure.Liste_GroupTri.ListIndex
	 Else
	    'Site(ns).Faille(i).GroupeTri = 0
	 End If
      Entre_faille_courante = True
   End If
Exit Function
Traite_Erreurs19:
   If Erreurs(Err, "Routines / Entre_faille_courante") Then Resume Next
End Function
'}}}
Sub EntreeMesures () '{{{
   On Error GoTo Traite_Erreurs20:
   temoin = Site(ns).NbMes
   Site(ns).NbMes = InputFaille(i)
   'rajoute 1 ligne au tableau
   DimensionneVariables
   DimensionneObjets
   MetàJourStation
   MetàJourListeGroupe
   RedessinStereo St!Stereo
   If temoin <> Site(ns).NbMes Then If Site(ns).dirty <> True Then Site(ns).dirty = True
   'si cancel, exit sub
Exit Sub
Traite_Erreurs20:
   If Erreurs(Err, "Routines / EntreeMesures") Then Resume Next
End Sub
'}}}
Sub F9 () '{{{
   On Error GoTo Traite_Erreurs21:
    St!Stereo.Picture = St!bmp.Picture'LoadPicture("")
      '***REMETTRE METASTEREO***metastereo!Stereo.Picture = St!bmp.Picture
    tmp = Retracage_Manuel
    Retracage_Manuel = False
    RedessinStereo St!Stereo
    Retracage_Manuel = tmp
    'St.ZOrder 0
Exit Sub
Traite_Erreurs21:
   If Erreurs(Err, "Routines / F9") Then Resume Next
End Sub
'}}}
Sub Ferme_Tout () '{{{
   On Error GoTo Traite_Erreurs22:
   Retracage_Manueli = Retracage_Manuel
   nsi = ns
   Retracage_Manuel = True
	 '***ça bugue !!! ************
	 'ns = 0
	 'Do While UBound(frm_Station) <> 0
	 '   ns = ns + 1
	 '   If Not (Site(ns).deleted) Then
	 '      Unload frm_Station(ns)
	 '      If flag = flag_cancel Then Exit Do
	 '   End If
	 'Loop
	 '****************************
      For ns = 1 To Min(UBound(Site), NbStations)
	 If ns > Min(UBound(Site), NbStations) Then Exit For
	 If Not (Site(ns).deleted) Then
	    Unload frm_Station(ns)
	    If flag = flag_cancel Then Exit For
	 End If
      Next
   ns = nsi
   Retracage_Manuel = False
   If flag <> flag_quitter Then RedessinStereo St!Stereo
   Retracage_Manuel = Retracage_Manueli
   If flag = flag_cancel Then flag = False: Exit Sub
   NbStations = 0
   If flag = flag_quitter Then Exit Sub
   flag = True
   nouvelle_station
   flag = False
Exit Sub
Traite_Erreurs22:
   If Erreurs(Err, "Routines / Ferme_Tout") Then Resume Next
End Sub
'}}}
Sub FichierTratr () '{{{
    On Error Resume Next
    '***Création d'un fichier pour pgm Mercier
   CompteTotal = NbMesuresAffichees()
      If CompteTotal = 0 Then
	 Beep
	 MsgBox ("Erreur: aucune mesure sélectionnée...")
	 Exit Sub
      End If
   On Error Resume Next
   MDI!CMDialog.Filter = "Tous fichiers (*.*)|*.*"
   MDI!CMDialog.DefaultExt = " "
   MDI!CMDialog.Filename = "tenseur"
   MDI!CMDialog.Flags = &H2& Or &H4&
   MDI!CMDialog.CancelError = True
   MDI!CMDialog.DialogTitle = "Enregistrer un fichier des failles visibles pour calcul de tenseur"
   MDI!CMDialog.Action = 2
   If Err Then Exit Sub
   On Error GoTo Traite_Erreurs23:
	   screen.MousePointer = 11
	   f$ = MDI!CMDialog.Filename
	   If InStr(Len(f$) - 12, f$, ".") = 0 Then f$ = f$ + ".   "'pour éviter erreur qd tentative chgt station pour tratr
	 CreatFicPgmTRATR f$
	   screen.MousePointer = defaut
Exit Sub
Traite_Erreurs23:
   If Erreurs(Err, "Routines / FichierTratr") Then Resume Next
End Sub
'}}}
Function FindFreeIndex () As Integer '{{{
   On Error GoTo Traite_Erreurs24:
    Dim index As Integer
    Dim ArrayCount As Integer
    
    ArrayCount = UBound(Site)
    ' Parcourt le tableau de documents. Si l'un des documents
    ' est vide et non modifié, on en renvoie l'index'on le supprime
    For index = 1 To ArrayCount
	If Not (Site(index).dirty) And Site(index).NbMes = 0 Then
	    FindFreeIndex = index
	    Site(index).deleted = False
	    Exit Function
	    'FState(index).Deleted = True
	    'Unload frm_Station(index)
	End If
    Next


    ' Parcourt le tableau de documents. Si l'un des documents
    ' a été supprimé, en renvoie
    ' l'index.
    For index = 1 To ArrayCount
	If Site(index).deleted Then
	    FindFreeIndex = index
	    Site(index).deleted = False
	    Exit Function
	End If
    Next

    ' Si aucun des éléments du tableau de documents n'a
    ' été supprimé, incrémente le document et les
    ' tableaux State de un et renvoie l'index au nouvel
    ' élément.
	 'Stop   'non:  Dimensionnements est appelé un peu + tard, quand on connait imax
    FindFreeIndex = UBound(Site) + 1
Exit Function
Traite_Erreurs24:
   If Erreurs(Err, "Routines / FindFreeIndex") Then Resume Next
End Function
'}}}
Sub GetRecentFiles () '{{{
   On Error GoTo Traite_Erreurs25:
  Dim RetVal, key, index, j
  Dim IniString As String

  ' This variable must be large enough to hold the return string
  ' from the GetPrivateProfileString API.
  IniString = String(255, 0)

  ' Get recent file strings from MDINOTE.INI
  '***MDI!mnuRappel.Visible = False
  For index = 1 To 8
    key = "Fichier" & index
    RetVal = getprivateprofilestring("Liste des derniers fichiers", key, "Non Utilisé", IniString, Len(IniString), "tectri.ini")
      If RetVal And Left(IniString, 11) <> "Non Utilisé" Then
	 ' Update the MDI form's menu.
	 '***MDI!mnuRappel.Visible = True
	 MDI!mnuRecentFile(index).Caption = "&" + index + " " + IniString
	 MDI!mnuRecentFile(index).Visible = True
      Else
	 MDI!mnuRecentFile(index).Visible = False
      End If
  Next index
Exit Sub
Traite_Erreurs25:
   If Erreurs(Err, "Routines / GetRecentFiles") Then Resume Next
End Sub
'}}}
Sub imprime () '{{{
   On Error GoTo ErrorHandler ' Installe une routine de gestion
			      ' d'erreurs
   Select Case MDI.ActiveForm.Tag
      Case "stéréo"
	 'Impression du stereogramme, simple recopie de bmp, pour l'instant
	 CR$ = Chr$(13) + Chr$(10)
	 TheMessage$ = "Impression du stéréogramme?"
	 TheStyle = 33
	 TheAnswer = MsgBox(TheMessage$, TheStyle)
	    If TheAnswer = 1 Then  'Answered ok
	     '** cas d'Impression_Vectorielle viré: remettre
	     '  Select Case Impression_Vectorielle
	     '     Case True
		     'Impression du stereogramme, avec la resolution de l'imprimante
		     '***il faudra ameliorer, pour pouvoir sortir les ddrts ou focstri, avec cette methode.
		     'RedessinStereo printer'***déconne...
		     flag = flag_imprime
		     F9
	    '      Case Else
		     St.PrintForm   ' Imprime la feuille en bmp.
	    '      End Select
	       printer.EndDoc
	    Else     'Answered non
	       Exit Sub
	    End If
      Case 1 To UBound(frm_Station)
	 'Impression de la station en cours
	 CR$ = Chr$(13) + Chr$(10)
	 ns = MDI.ActiveForm.Tag
	 TheMessage$ = "Impression des données du site " & Site(ns).NomFichier
	 TheStyle = 33
	 TheAnswer = MsgBox(TheMessage$, TheStyle)
	    If TheAnswer = 1 Then  'Answered ok
	     ' '***impression
		Dim ClipText
		Dim CopyText
		Dim NC
		Dim NR
		Dim Count
		Dim ColStrt
		Dim ColEnd
		Dim RowStrt
		Dim RowEnd
		Dim HeadTxt
	     '  ' Initialise les nouvelles variables de colonne (NC) & de ligne (NR).
	     '  NC = Chr$(9)
	     '  NR = Chr$(13) & Chr$(10)
	     '  ' Initialise les variables pour lignes/col sélectionnées.
	     '   ColStrt = 1
	     '   ColEnd = frm_Station(ns)!Grille.Cols
	     '   RowStrt = 1
	     '   RowEnd = frm_Station(ns)!Grille.Rows
	     '  ' Initialise la variable qui reçoit des entrées à partir de la grille.
	     '   ClipText = frm_Station(ns).Grille.Clip
	     '  ' Initialise la variable qui contient la sortie au Presse-papiers.
	     '   CopyText = Site(ns).NomFichier + NR
	     '  ' Copie le texte de la variable d'entrée dans la variable de sortie.
	     '     For Count = 1 To Len(ClipText)
	     '         ' Si le caractère en cours n'est pas un retour chariot
	     '         If Mid$(ClipText, Count, 1) <> Chr$(13) Then
	     '             ' Attache le caractère à la variable de sortie.
	     '             CopyText = CopyText & Mid$(ClipText, Count, 1)
	     '         ' Si le caractère en cours est un retour chariot
	     '         Else
	     '             ' Attache un retour chariot/retour ligne à la varirable de sortie.
	     '             'frm_Station(ns).Grille.Row = frm_Station(ns).Grille.Row + 1
	     '             CopyText = CopyText & NR
	     '         End If
	     '     Next Count
	     ''  Imprime le contenu de la variable de sortie dans le Presse-papiers.
	     ' printer.Print CopyText 'ClipText
	     ' printer.EndDoc
	       'rowi = frm_Station(ns).Grille.Row
	       'coli = frm_Station(ns).Grille.Col
	       selstartrowi = frm_Station(ns).Grille.SelStartRow
	       selendrowi = frm_Station(ns).Grille.SelEndRow
	       selstartcoli = frm_Station(ns).Grille.SelStartCol
	       selendcoli = frm_Station(ns).Grille.SelEndCol
		  frm_Station(ns).Grille.HighLight = False
		  frm_Station(ns).Grille.SelStartRow = 1
		  frm_Station(ns).Grille.SelEndRow = frm_Station(ns).Grille.Rows - 1
		  frm_Station(ns).Grille.SelStartCol = 1
		  frm_Station(ns).Grille.SelEndCol = frm_Station(ns).Grille.Cols - 1
		  CopyText = Site(ns).NomFichier + Chr$(13) & Chr$(10) + frm_Station(ns).Grille.Clip
		  printer.Print frm_Station(ns).Grille.Clip
		  printer.EndDoc
	       'frm_Station(ns).Grille.Row = rowi
	       'frm_Station(ns).Grille.Col = coli
	       frm_Station(ns).Grille.SelStartRow = selstartrowi
	       frm_Station(ns).Grille.SelEndRow = selendrowi
	       frm_Station(ns).Grille.SelStartCol = selstartcoli
	       frm_Station(ns).Grille.SelEndCol = selendcoli
	       frm_Station(ns).Grille.HighLight = True
	    Else     'Answered non
	    
	    End If
      Case Else
   End Select
   Exit Sub
ErrorHandler:
   If Err <> 13 Then MsgBox "Erreur d'impression"' Affiche le message.
   Resume Next
End Sub
'}}}
Function InputFaille (ByVal faille1 As Integer) '{{{
   On Error GoTo Traite_Erreurs26:
   'Rentre une ou plusieurs mesures; renvoie le nouveau nb de mesures
   i = faille1 '+ 1
   screen.MousePointer = 11
   Saisie_mesure.Show 1
   InputFaille = Site(ns).NbMes
Exit Function
Traite_Erreurs26:
   If Erreurs(Err, "Routines / InputFaille") Then Resume Next
End Function
'}}}
Sub LectureTectriIni () '{{{
   On Error GoTo Traite_Erreurs27:
      '***REMETTRE METASTEREO***creemetafile
f = "tectri.ini"
'***Position et état des fenêtres
   '*fenêtre tectri
   MDI.Left = getprivateprofileint("Fenêtres", "Tectri: left", 1500, f)
   MDI.Top = getprivateprofileint("Fenêtres", "Tectri: top", 200, f)
   MDI.Width = getprivateprofileint("Fenêtres", "Tectri: width", 7500, f)
   MDI.Height = getprivateprofileint("Fenêtres", "Tectri: height", 6000, f)
      tmp = getprivateprofileint("Fenêtres", "Tectri: état", 0, f)
      If tmp = 1 Then tmp = 0
   MDI.WindowState = tmp
   
'***options générales
   MDI!menu_sauve_parametres.Checked = getprivateprofileint("Options", "Sauvegarde paramètres", True, f)
   Retracage_Manuel = -getprivateprofileint("Options", "Retracage manuel", False, f)
   MDI!menu_trace_auto.Checked = Not (Retracage_Manuel)
      'mdi.f9.Visible = Retracage_Manuel
   Fichiers_Bkp = -getprivateprofileint("Options", "Fichiers bkp", 1, f)
   Open_nFichiers = -getprivateprofileint("Options", "Ouvrir n fichiers", 1, f)
   Fichiers_Param = -getprivateprofileint("Options", "Enregistrement paramètres géométriques", 1, f)
   
   'séparateur champs
      retstring$ = Space$(50)
      ret = getprivateprofilestring("Options", "Séparateur de champs", " ", retstring$, 50, f)
      tmp = Left$(retstring$, ret)
	 Select Case tmp
	    Case "tab"
	       Separateur_champs$ = Chr$(9)
	    Case Else
	       Separateur_champs$ = " "
	 End Select
   
   Aff_F_non_Sélec = -getprivateprofileint("Options", "Affichage mesures non triées", 1, f)
   MDI!Image2.Visible = -getprivateprofileint("Options", "Barre d'état", 1, f)
   MDI!barre_outils.Visible = -getprivateprofileint("Options", "Barre d'outils", 1, f)
   Impression_Vectorielle = -getprivateprofileint("Options", "Impression vectorielle", 1, f)
   Signale_Erreurs = -getprivateprofileint("Options", "Signalement des erreurs d'exécution", 0, f)
   Tracage_Progressif = -getprivateprofileint("Options", "Traçage progressif du stéréo", 0, f)
	 '***
	 'retstring$ = Space$(50)
	 'ret = getprivateprofilestring("Options", "Angle teta", "30", retstring$, 50, f)
	 'teta = Val(retstring$)
	 teta = getprivateprofileint("Options", "Angle teta", 0, f)
	 If teta < 1 Then teta = 1
	 If teta > 89 Then teta = 89
	 teta = teta * pi / 180
	 '***
   Affich_F_Stations_Icones = -getprivateprofileint("Options", "Affichage des stations icônisées", 1, f)

'**Groupes de tri
   NbGroupesdeTri = getprivateprofileint("Groupes de tri", "Nombre de groupes", 10, f)
       ReDim SymboleGroupeDeTri(-1 To NbGroupesdeTri)
       ReDim NbMesSelect(-1 To NbGroupesdeTri)
       ReDim CouleurGroupe(-1 To NbGroupesdeTri)
       SymboleGroupeDeTri(-1) = " "
       SymboleGroupeDeTri(0) = "*"
	 For tmp = 1 To NbGroupesdeTri
	    SymboleGroupeDeTri(tmp) = Chr$(tmp + 96)
	 Next
	 flag = flag_chargement
	    For tmp = 1 To NbGroupesdeTri
	       titre$ = "Groupe " + Str$(tmp)
	       retstring$ = Space$(50)
	       ret = getprivateprofilestring("Groupes de tri", titre$ + ": couleur", "", retstring$, 50, f)
		  CouleurGroupe(tmp) = Val(retstring$) + (Asc(LTrim(retstring$)) = 0)
	       retstring$ = Space$(50)
	       ret = getprivateprofilestring("Groupes de tri", titre$ + ": commentaire", "", retstring$, 50, f)
	       GroupTri!CommentaireGroupe(tmp) = Left$(retstring$, ret)
	       ret = getprivateprofileint("Groupes de tri", titre$ + ": affichage", (tmp = 0), f)
	       MDI!menu_projettegroupe(tmp).Checked = ret   'Affichage(Tmp) = ret
	       GroupTri!CocheProjectionGroupe(tmp).Value = -MDI!menu_projettegroupe(tmp).Checked 'GroupTri!CocheProjectionGroupe(Tmp).Value = -Affichage(Tmp)
	    Next
	 flag = False
      CouleurGroupe(-1) = FOND_FENETRE
      CouleurGroupe(0) = TEXTE_FENETRE
      GroupTri!CommentaireGroupe(0) = "Groupe permanent"
      MDI!menu_projettegroupe(0).Checked = True'Affichage(0) = True
	    For bidon = 1 To NbGroupesdeTri
	       If CouleurGroupe(bidon) = -1 Then CouleurGroupe(bidon) = -rouge * (modulo(bidon + 1, 8) > 4) - bleu * (modulo(bidon + 1, 4) > 2) - vert * (modulo(bidon + 1, 2) > 1)
	    Next
   GroupTri.Left = getprivateprofileint("Fenêtres", "Groupes de tri: left", 0, f)
   GroupTri.Top = getprivateprofileint("Fenêtres", "Groupes de tri: top", 0, f)
   GroupTri.WindowState = getprivateprofileint("Fenêtres", "Groupes de tri: état", 0, f)

'***traces sélectionnées
   flag = flag_chargement
   MDI!menu_trace(1).Checked = getprivateprofileint("Traces", "Traces cyclographiques de plans de failles", True, f)
      MDI!Check3D_trace(1).Value = MDI!menu_trace(1).Checked
   MDI!menu_trace(2).Checked = getprivateprofileint("Traces", "Stries", True, f)
      MDI!Check3D_trace(2).Value = MDI!menu_trace(2).Checked
   MDI!menu_trace(3).Checked = getprivateprofileint("Traces", "Polaires", False, f)
      MDI!Check3D_trace(3).Value = MDI!menu_trace(3).Checked
   MDI!menu_trace(4).Checked = getprivateprofileint("Traces", "Axes X", False, f)
      MDI!Check3D_trace(4).Value = MDI!menu_trace(4).Checked
   MDI!menu_trace(5).Checked = getprivateprofileint("Traces", "Axes Y", False, f)
      MDI!Check3D_trace(5).Value = MDI!menu_trace(5).Checked
   MDI!menu_trace(6).Checked = getprivateprofileint("Traces", "Axes Z", False, f)
      MDI!Check3D_trace(6).Value = MDI!menu_trace(6).Checked
   MDI!menu_trace(8).Checked = getprivateprofileint("Traces", "Plans de mouvement X", False, f)
   MDI!menu_trace(9).Checked = getprivateprofileint("Traces", "Plans de mouvement Z", False, f)
      If MDI!menu_trace(8).Checked And MDI!menu_trace(9).Checked Then MDI!menu_trace(7).Checked = True
      MDI!Check3D_trace(7).Value = MDI!menu_trace(7).Checked
   MDI!menu_trace(11).Checked = getprivateprofileint("Traces", "Plans auxiliaires", False, f)
      'MDI!Check3D_trace(11).Value = MDI!menu_trace(11).Checked
   MDI!menu_trace(10).Checked = getprivateprofileint("Traces", "Directions des stries", False, f)
      'MDI!Check3D_trace(10).Value = MDI!menu_trace(10).Checked

'***stéréo
   retstring$ = Space$(50)
   ret = getprivateprofilestring("Stéréogramme", "Diamètre stéréo", "5", retstring$, 50, f)
   DiamStereo = Val(retstring$)
   If DiamStereo < .5 Then DiamStereo = 5
   Hémisphère = getprivateprofileint("Stéréogramme", "Hémisphère", 1, f)
   retstring$ = Space$(50)
   ret = getprivateprofilestring("Stéréogramme", "Police", "Arial", retstring$, 50, f)
   St.Stereo.FontName = retstring$
   St.bmp.FontName = retstring$
   St.Stereo.FontSize = getprivateprofileint("Stéréogramme", "Taille caractères", 8, f)
   St.Stereo.FontBold = getprivateprofileint("Stéréogramme", "Gras", False, f)
   St.Stereo.FontItalic = getprivateprofileint("Stéréogramme", "Italique", False, f)

'***Dièdres droits
   retstring$ = Space$(50)
   ret = getprivateprofilestring("Dièdres droits", "Couleur Z", "", retstring$, 50, f)
   CouleurDDroits_Z = Val(retstring$)
   If CouleurDDroits_Z = 0 Then CouleurDDroits_Z = rouge
   retstring$ = Space$(50)
   ret = getprivateprofilestring("Dièdres droits", "Couleur X", "", retstring$, 50, f)
   CouleurDDroits_X = Val(retstring$)
   If CouleurDDroits_X = 0 Then CouleurDDroits_X = vert

'***ancienne place des lectures des positions des fenêtres
   '***Position stéréo; génère un form.load, qui implique un redessin stéréo;
   'il faut donc que les tableaux supra soient dimensionnés
   'flag = False
   St.Left = getprivateprofileint("Fenêtres", "Stéréo: left", 5000, f)
  ' flag = True
   St.Top = getprivateprofileint("Fenêtres", "Stéréo: top", 0, f)
   St.WindowState = getprivateprofileint("Fenêtres", "Stéréo: état", 0, f)
   'st.width = getprivateprofileint("Fenêtres", "Stéréo: width", 200, f)
   'st.height = getprivateprofileint("Fenêtres", "Stéréo: height", 200, f)
      'St_left = St.Left: St_top = St.Top
    
'*********
'   frm_Station(ns).Left = getprivateprofileint("Fenêtres", "Données: left", 0, f)
'   frm_Station(ns).Top = getprivateprofileint("Fenêtres", "Données: top", 0, f)
'   frm_Station(ns).Height = getprivateprofileint("Fenêtres", "Données: height", 0, f)
'   frm_Station(ns).Width = getprivateprofileint("Fenêtres", "Données: width", 0, f)

   GetRecentFiles
Exit Sub
Traite_Erreurs27:
   If Erreurs(Err, "Routines / LectureTectriIni") Then Resume Next
End Sub
'}}}
Sub lit_fichier_tra () '{{{
'   libre = FreeFile
'      Open fichier_tenseur For Input As libre
'      input libre,nbfailles
'         For j = 1 To nbfailles
'            line input libre,nbfailles
'         Next
'         For sigma = 1 To 3
'            input libre,valeur_propre (sigma)
'         Next
'      input libre,rapport_forme
'         For sigma = 1 To 3
'            input libre, sig,azi(sigma), plong(sigma)
'         Next
'   Close libre
End Sub
'}}}
Sub LitFicPartieCal () '{{{
   On Error GoTo Traite_Erreurs28:
   For i = 1 To Site(ns).NbMes
   'Dans la version qb, l'input tenait sur une ligne: ce n'est hélas plus possible...
   'Je suis le conseil de l'aide en ligne, en décomposant la ligne.
   'Pour EnregistrePartieCal, il faudra interposer quelques variables intermédiaires
   'INPUT #1, rien$, azi(ns, i), Pd(ns, i), Pitch(ns, i), faille(ns,i).param.AzStri, ox(ns, i), oy(ns, i), r(ns, i), PolX(ns, i), PolY(ns, i), faille(ns,i).param.Angledep, faille(ns,i).param.Anglearr, SX(ns, i), SY(ns, i), SAX(ns, i), SAY(ns, i), SFX(ns, i), SFY(ns, i), site(ns).faille( i).param.axeYX,  _
   'site(ns).faille( i).param.axeYY, Xmvt(ns, i), Ymvt(ns, i), site(ns).faille( i).param.Rmvt, faille(ns,i).param.Angledeppmvtx1, faille(ns,i).param.Anglearrpmvtx1, faille(ns,i).param.Angledeppmvtx2, faille(ns,i).param.Anglearrpmvtx2, faille(ns,i).param.Angledeppmvtz1, faille(ns,i).param.Anglearrpmvtz1, faille(ns,i).param.Angledeppmvtz2, faille(ns,i).param.Anglearrpmvtz2, site(ns).faille( i).param.axeZX _
   ', site(ns).faille( i).param.axeZY, faille(ns,i).param.axexx, site(ns).faille( i).param.axeXY, faille(ns,i).param.Xaux, faille(ns,i).param.Yaux, faille(ns,i).param.Raux, faille(ns,i).param.AngleDepAux, site(ns).faille( i).param.AngleArrAux, site(ns).faille( i).param.jv, site(ns).faille( i).param.jh, site(ns).faille( i).Tri
      Input #1, rien$, azi_bidon, Pd_bidon, pitch_bidon, Site(ns).Faille(i).param.azstri, Site(ns).Faille(i).param.ox, Site(ns).Faille(i).param.oy, Site(ns).Faille(i).param.r, Site(ns).Faille(i).param.PolX, Site(ns).Faille(i).param.PolY, Site(ns).Faille(i).param.Angledep, Site(ns).Faille(i).param.Anglearr, Site(ns).Faille(i).param.SX, Site(ns).Faille(i).param.SY, Site(ns).Faille(i).param.sax, Site(ns).Faille(i).param.say, Site(ns).Faille(i).param.sfx, Site(ns).Faille(i).param.sfy, Site(ns).Faille(i).param.AxeYX
      Input #1, Site(ns).Faille(i).param.AxeYY, Site(ns).Faille(i).param.xmvt, Site(ns).Faille(i).param.ymvt, Site(ns).Faille(i).param.Rmvt, Site(ns).Faille(i).param.Angledeppmvtx1, Site(ns).Faille(i).param.Anglearrpmvtx1, Site(ns).Faille(i).param.Angledeppmvtx2, Site(ns).Faille(i).param.Anglearrpmvtx2, Site(ns).Faille(i).param.Angledeppmvtz1, Site(ns).Faille(i).param.Anglearrpmvtz1, Site(ns).Faille(i).param.Angledeppmvtz2, Site(ns).Faille(i).param.Anglearrpmvtz2
      Input #1, Site(ns).Faille(i).param.AxeZX, Site(ns).Faille(i).param.AxeZY, Site(ns).Faille(i).param.AxeXX, Site(ns).Faille(i).param.AxeXY, Site(ns).Faille(i).param.Xaux, Site(ns).Faille(i).param.Yaux, Site(ns).Faille(i).param.Raux, Site(ns).Faille(i).param.AngleDepAux, Site(ns).Faille(i).param.AngleArrAux, Site(ns).Faille(i).param.jv, Site(ns).Faille(i).param.jh
      'Input #1, tritmp: If Site(ns).Faille(i).tri = 0 And tritmp <> 0 Then Site(ns).Faille(i).tri = tritmp
   Next i
Exit Sub
Traite_Erreurs28:
   If Erreurs(Err, "Routines / LitFicPartieCal") Then Err = 1000: Resume Next
End Sub
'}}}
Sub LitFicPartieDat () '{{{
   On Error GoTo Traite_Erreurs29:
      Select Case Left$(Site(ns).format, 5)
	 Case "tratr"
	    For i = 1 To Site(ns).NbMes
	       'Demo
	       GoSub LitLigne
	    Next
	 Case "tectr"
	    Site(ns).NbMes = 0
	    i = 0
	       Do
		  'Demo
		  GoSub LitLigne
	       Loop While Not (rien$ = "" Or EOF(1))
	 Case Else
      End Select
   Exit Sub


LitLigne:
      Err = 0
      Line Input #1, rien$
      On Error Resume Next
      test_int = CDbl(GetToken$(rien$, " " + Chr$(9) + ","))'(Left$(rien$, 3))
      If rien$ = "" Or Err Then Exit Sub
      On Error GoTo Traite_Erreurs29:
	 If Left$(Site(ns).format, 5) = "tectr" Then
	    i = i + 1
	 If Site(ns).NbMes <= i Then ReDim Preserve Faille(i + 10)
	    Site(ns).NbMes = i
	 End If
      Mesure = GetToken$(rien$, "[]")
      tria$ = GetToken$("", "[]" + Chr$(9))
      DecryptageMesure (Mesure)
	 If Aff_F_non_Sélec Then
	    If tria$ = "" Or tria$ = " " Then tria$ = "*"
	 End If
	 For GroupeGroupe = 0 To NbGroupesdeTri
	    Site(ns).Faille(i).GroupeTri = -1
	    If tria$ = SymboleGroupeDeTri(GroupeGroupe) Then
	       Site(ns).Faille(i).GroupeTri = GroupeGroupe
	       NbMesSelect%(GroupeGroupe) = NbMesSelect%(GroupeGroupe) + 1
	       Exit For
	    End If
	 Next
Return
Exit Sub
Traite_Erreurs29:
   If Erreurs(Err, "Routines / LitFicPartieDat") Then Resume Next
End Sub
'}}}
Sub LitStation (NomCompletFichier)  'NomCompletFichier est drive+répertoire+fichier '{{{
   NbBadFailles = 0
   prompt "Ouverture du fichier " + NomCompletFichier
   'If InStr(NomCompletFichier, ".") = 0 Then NomCompletFichier = NomCompletFichier + ".tec"
   'TestFicExiste
   On Error Resume Next
   Close #1
   Open NomCompletFichier For Input As #1
   Close #1
      If Err Then
	    'Le fichier existe pas
	    MsgBox "Impossible d'ouvrir le fichier : " + NomCompletFichier
	 Exit Sub
      End If
   nsavant = ns
   iavant = i
      'Ce fichier est-il déjà ouvert?
      For ns = 1 To NbStations
	 If Not (Site(ns).deleted) And LCase$(Site(ns).NomFichier) = LCase$(NomCompletFichier) Then
	    CR$ = Chr$(13) + Chr$(10)
	    TheMessage$ = "Fichier " + Site(ns).NomFichier + " déjà ouvert:" + CR$
	    TheMessage$ = TheMessage$ + "relire les données sur disque?"
	    TheStyle = 305
	    TheTitle$ = "Tectri"
	    TheAnswer = MsgBox(TheMessage$, TheStyle, TheTitle$)
	       If TheAnswer = 1 Then  'Answered OK
		  flag = flag_RechargerFichier
		  Site(ns).Faille(1).param.r = 0
		  Exit For
	       Else     'Answered Cancel
		  screen.MousePointer = defaut
		  Exit Sub
	       End If
	 End If
      Next
   '***Du bloc-notes mdi
    ' Modifie la légende de la feuille et affiche
    'le nouveau texte.
   If flag <> flag_RechargerFichier Then
      ns = FindFreeIndex()'libre
      NbStations = max(NbStations, ns)
      DimensionneVariables
      DimensionneObjets
      'NbStations = MAX(NbStations, UBound(frm_Station))
   End If
      'flag = 0
	    Site(ns).NomFichier = NomCompletFichier
	    Site(ns).format = TestFormatFicTratrTectri$(NomCompletFichier)
	     ' TratrTectri$
	    Select Case Left$(Site(ns).format, 5)
	       Case "tratr"
		  Open NomCompletFichier For Input As #1
		  Line Input #1, Ligne$
		  Site(ns).NbMes = Val(Ligne$)
	       Case "tectr"
		  Open NomCompletFichier For Input As #1
		  'Stop'**on refera les structures de fichiers
		  'Input #1, Site(ns).Situation, NOS, Site(ns).NbMes
		  Line Input #1, Ligne$
		   '  Seps$ = ",""" + Chr$(9)
		     Site(ns).Situation = Ligne$'GetToken$(Ligne$, Seps$)
		     While Left$(Site(ns).Situation, 1) = "'"
			Site(ns).Situation = Right$(Site(ns).Situation, Len(Site(ns).Situation) - 1)
		     Wend
		     While Right$(Site(ns).Situation, 1) = Chr$(9)
			Site(ns).Situation = Left$(Site(ns).Situation, Len(Site(ns).Situation) - 1)
		     Wend
		  '   NOS = Val(GetToken$("", Seps$))
		  '   Site(ns).NbMes = Val(GetToken$("", Seps$))
	       Case Else
		  msg$ = "Fichier " + NomCompletFichier + " de format non valable."
		  MsgBox msg$, 0 + 48, "Format de fichier incorrect"
		  Exit Sub
	    End Select
    DimensionneVariables
    LitFicPartieDat
    ReDim FailleBad(Site(ns).NbMes)
       frm_Station(ns).Caption = LCase$(Site(ns).NomFichier)
       frm_Station(ns).Refresh
	    On Error GoTo FicNonCalcule:
	       If Left$(Site(ns).format, 5) = "tectr" Then
		     Do
			'*** désormais, on calcule tout le temps, because bugs ...
			'If Site(ns).Faille(1).param.r <> 0 And Site(ns).Faille(i).param.PolX <> 0 And Site(ns).Faille(i).param.PolY <> 0 Then Exit Do
			'***
			   If EOF(1) Then
			      CalculeFichier 'EcritFicPartieCal ns
			      Exit Do
			   End If
			Input #1, Ligne$
			If Left$(Site(ns).Situation, Len(Ligne$)) = Ligne$ Or Ligne$ = "*** Paramètres géométriques - effacer en cas d'édition des données ***" Then
			   Do
			      Site(ns).format = Site(ns).format + "_parametres"
			      '*** désormais, on calcule tout le temps, because bugs ...
			      'If (Site(ns).Faille(1).param.r <> 0 And Site(ns).Faille(i).param.PolX <> 0 And Site(ns).Faille(i).param.PolY <> 0) Then Exit Do
			      '***
			      Input #1, NbMesures
			   Loop While NbMesures <> Site(ns).NbMes
			   LitFicPartieCal
			   If Err = 1000 Then Err = 0: CalculeFichier
			End If
		     Loop While Ligne$ <> Site(ns).Situation
		  Close #1
	       Else
		  CalculeFichier
		  'EcritFicPartieCal ns
	       End If
    On Error Resume Next' GoTo 0
      '*****virer cette boucle, après avoir nettoyé les calculs des tableaux inutiles
      'For i = 1 To Site(ns).NbMes
      '   DecryptageMesure (Site(ns).Faille(i).mesure)
      'Next
   DimensionneObjets
    Site(ns).deleted = False
    frm_Station(ns).Tag = ns
    Site(ns).dirty = False
    
   i = 1
      If NbBadFailles > 0 Then
	 '***fin de litstation, une fois la station chargée, mettre:
	 MsgBox "Correction de mesures de failles incorrectes"
	 Saisie_mesure.suivante.Enabled = False
	 Saisie_mesure.precedente.Enabled = False
	 Saisie_mesure.annule.Enabled = False
	    For k = 1 To NbBadFailles
	       i = FailleBad(k)
	       'screen.MousePointer = 11
	       Saisie_mesure.Show 1
	       'saise_mesure (ns,i), avec >, <, et cancel disabled
	    Next
	 Saisie_mesure.suivante.Enabled = True
	 Saisie_mesure.precedente.Enabled = True
	 Saisie_mesure.annule.Enabled = True
	 'Unload Saisie_mesure
	 Saisie_mesure.Hide
	 'If SystemLow() Then Unload Saisie_mesure
      End If
    '****on a  ici l'ancien code de load de station
   'If frm_Station(ns).Tag = "" Then frm_Station(ns).Tag = ns'tag en train de se définir
   'grille.ScaleMode = CARACTERE
   'Charger les titres
   'LoadTitles
   MetàJourStation
   MetàJourListeGroupe
   UpdateFileMenu (Site(ns).NomFichier)
   Exit Sub
FicNonCalcule:
   On Error GoTo Traite_Erreurs30:
   CalculeFichier
   'EcritFicPartieCal ns
   Resume Next
Exit Sub
Traite_Erreurs30:
   If Erreurs(Err, "Routines / LitStation") Then Resume Next
End Sub
'}}}
Sub LoadTitles () '{{{
   On Error GoTo Traite_Erreurs31:
	 'ns = Val(Me.Tag)
	 'If ns = 0 Then ns = 1
	 flag = True
	 frm_Station(ns).Refresh
	 'frm_Station(ns).Grille.Rows = Site(ns).NbMes + 2'1 pour titres, 1 pour une nouvelle mesure
	 frm_Station(ns).Grille.Row = 0
	 frm_Station(ns).Grille.Col = 0
	 frm_Station(ns).Grille.Text = "Faille"'"N°"
	 frm_Station(ns).Grille.ColWidth(frm_Station(ns).Grille.Col) = 4 * 120
	 frm_Station(ns).Grille.Col = frm_Station(ns).Grille.Col + 1
	 frm_Station(ns).Grille.Text = "Dir"
	 frm_Station(ns).Grille.ColWidth(frm_Station(ns).Grille.Col) = 3 * 120
	 frm_Station(ns).Grille.Col = frm_Station(ns).Grille.Col + 1
	 frm_Station(ns).Grille.Text = "Pd"
	 frm_Station(ns).Grille.ColWidth(frm_Station(ns).Grille.Col) = 3 * 120
	 frm_Station(ns).Grille.Col = frm_Station(ns).Grille.Col + 1
	 frm_Station(ns).Grille.Text = "Qdr"
	 frm_Station(ns).Grille.ColWidth(frm_Station(ns).Grille.Col) = 2 * 120
	 frm_Station(ns).Grille.Col = frm_Station(ns).Grille.Col + 1
	 frm_Station(ns).Grille.Text = "Pitch"
	 frm_Station(ns).Grille.ColWidth(frm_Station(ns).Grille.Col) = 3 * 120
	 frm_Station(ns).Grille.Col = frm_Station(ns).Grille.Col + 1
	 frm_Station(ns).Grille.Text = "Qdr"
	 frm_Station(ns).Grille.ColWidth(frm_Station(ns).Grille.Col) = 2 * 120
	 frm_Station(ns).Grille.Col = frm_Station(ns).Grille.Col + 1
	 frm_Station(ns).Grille.Text = "Mvt"
	 frm_Station(ns).Grille.ColWidth(frm_Station(ns).Grille.Col) = 2 * 120
	 frm_Station(ns).Grille.Col = frm_Station(ns).Grille.Col + 1
	 frm_Station(ns).Grille.Text = "Commentaire"
	 frm_Station(ns).Grille.ColWidth(frm_Station(ns).Grille.Col) = 10 * 120
	 frm_Station(ns).Grille.Col = frm_Station(ns).Grille.Col + 1
	 frm_Station(ns).Grille.Text = "Tri"
	 frm_Station(ns).Grille.ColWidth(frm_Station(ns).Grille.Col) = 2 * 120
Exit Sub
Traite_Erreurs31:
   If Erreurs(Err, "Routines / LoadTitles") Then Resume Next
End Sub
'}}}
Sub menu_barre_etat_Click () '{{{
    'menu_Barre_Etat.Checked = Not (menu_Barre_Etat.Checked)
    MDI!Image2.Visible = Not (MDI!Image2.Visible)' menu_Barre_Etat.Checked
End Sub
'}}}
Sub menu_Barre_Outils_click () '{{{
    'menu_Barre_Outils.Checked = Not (menu_Barre_Outils.Checked)
    MDI!barre_outils.Visible = Not (MDI!barre_outils.Visible)'menu_Barre_Outils.Checked
End Sub
'}}}
Sub MetàJourListeGroupe () '{{{
   On Error GoTo Traite_Erreurs32:
    'Mettre à jour la liste des groupes de tri, avec les populations.
   ' For groupe = 0 To NbGroupesDeTri
   '  NbMesSelect%(groupe) = 0
   ' Next
   ReDim NbMesSelect%(0 To NbGroupesdeTri)
    For nsns = 1 To NbStations
      If Not (Site(nsns).deleted) Then
	 If Not (Affich_F_Stations_Icones = False And frm_Station(nsns).WindowState = REDUIT) Then
	   For ii = 1 To Site(nsns).NbMes
	    groupe = Site(nsns).Faille(ii).GroupeTri
	    If groupe <> -1 Then NbMesSelect(groupe) = NbMesSelect(groupe) + 1
	    'frm_Station(nsns).Grille.ForeColor = CouleurGroupe(groupe)
	   Next
	 End If
      End If
    Next
    AfficheListeGroupes
Exit Sub
Traite_Erreurs32:
   If Erreurs(Err, "Routines / MetàJourListeGroupe") Then Resume Next
End Sub
'}}}
Sub MetàJourMesureTableau (ByVal nsns, ByVal ii) '{{{
   On Error GoTo Traite_Erreurs33:
'   Tableau.Grille.Row = nsns
'   Tableau.Grille.Col = ii
'   Tableau.Grille.Text = SymboleGroupeDeTri(Site(nsns).Faille(ii).GroupeTri)
   flag = True
   frm_Station(nsns).Grille.Row = ii
   frm_Station(nsns).Grille.Col = 8
   frm_Station(nsns).Grille.Text = SymboleGroupeDeTri(Site(nsns).Faille(ii).GroupeTri)
   flag = False
Exit Sub
Traite_Erreurs33:
   If Erreurs(Err, "Routines / MetàJourMesureTableau") Then Resume Next
End Sub
'}}}
Sub MetàJourStation () '{{{
   On Error GoTo Traite_Erreurs34:
   'Met à jour le tableau des données de la station courante
   If flag = flag_RechargerFichier Then flag = True: frm_Station(ns).Grille.Rows = 2
   flag = True
   frm_Station(ns).Grille.Rows = Site(ns).NbMes + 2
      For i = 1 To Site(ns).NbMes
	 frm_Station(ns)!Grille.Col = 0
	 frm_Station(ns)!Grille.Row = i
	 frm_Station(ns)!Grille.Text = Str$(i)
	 frm_Station(ns)!Grille.Col = frm_Station(ns).Grille.Col + 1
	 frm_Station(ns)!Grille.Text = Site(ns).Faille(i).azi
	 frm_Station(ns)!Grille.Col = frm_Station(ns).Grille.Col + 1
	 frm_Station(ns)!Grille.Text = Site(ns).Faille(i).Pd
	 frm_Station(ns)!Grille.Col = frm_Station(ns).Grille.Col + 1
	 frm_Station(ns)!Grille.Text = Site(ns).Faille(i).DirPd
	 frm_Station(ns)!Grille.Col = frm_Station(ns).Grille.Col + 1
	 frm_Station(ns)!Grille.Text = Site(ns).Faille(i).pitch
	 frm_Station(ns)!Grille.Col = frm_Station(ns).Grille.Col + 1
	 frm_Station(ns)!Grille.Text = Site(ns).Faille(i).dirpi
	 frm_Station(ns)!Grille.Col = frm_Station(ns).Grille.Col + 1
	 frm_Station(ns)!Grille.Text = Site(ns).Faille(i).jeu
	 frm_Station(ns)!Grille.Col = frm_Station(ns).Grille.Col + 1
	 frm_Station(ns)!Grille.Text = Site(ns).Faille(i).Commentaire
	 frm_Station(ns)!Grille.Col = frm_Station(ns).Grille.Col + 1
	 frm_Station(ns)!Grille.Text = SymboleGroupeDeTri(Site(ns).Faille(i).GroupeTri)'Chr$(Site(ns).faille(i).GroupeTri + 96)
      Next
   flag = True
   frm_Station(ns)!Texte2.Text = Site(ns).Situation
   flag = False
   frm_Station(ns)!Texte1.Text = frm_Station(ns)!Grille.Text
   frm_Station(ns).Refresh
Exit Sub
Traite_Erreurs34:
   If Erreurs(Err, "Routines / MetàJourStation") Then Resume Next
End Sub
'}}}
Function NbMesuresAffichees () '{{{
   tmp = 0
      For groupe = 0 To NbGroupesdeTri
	 tmp = tmp + NbMesSelect(groupe) * MDI!menu_projettegroupe(groupe).Checked    'Affichage(groupe)
      Next
   NbMesuresAffichees = Abs(tmp)
End Function
'}}}
Sub NonDisponible () '{{{
 CR$ = Chr$(13) + Chr$(10)
 TheMessage$ = "Cette option n'est pas encore disponible dans la version présente de Tectri."
 TheStyle = 16
 TheTitle$ = "Tectri"
 MsgBox TheMessage$, TheStyle, TheTitle$
End Sub
'}}}
Sub nouvelle_station () '{{{
   On Error GoTo Traite_Erreurs35:
   'NbStations = NbStations + 1
   'trouver un numéro libre
   ns = FindFreeIndex()
   NbStations = max(ns, NbStations)
   'redimensionner
   DimensionneVariables
   DimensionneObjets
   'Charger une nouvelle table frm_Station()
   'ns = NbStations
   Site(ns).NbMes = 0
   frm_Station(ns).Tag = ns
   'Et y rentrer des mesures, éventuellement
      If flag = 0 Then
	 TheMessage$ = "Entrée de nouvelles mesures de failles?"
	 TheStyle = 20
	 TheTitle$ = "Tectri"
	 TheAnswer = MsgBox(TheMessage$, TheStyle, TheTitle$)
	    If TheAnswer = 6 Then  'Answered oui
	       EntreeMesures
	       RedessinStereo St!Stereo
	       Exit Sub
	    End If
      End If
Exit Sub
Traite_Erreurs35:
   If Erreurs(Err, "Routines / nouvelle_station") Then Resume Next
End Sub
'}}}
Function OnRecentFilesList (Filename) As Integer '{{{
  Dim index
     Filename = LCase$(Filename)
     For index = 1 To 8
       'If LCase$(MDI!mnuRecentFile(index).Caption) = Filename Then
       If LCase$(Right$(MDI!mnuRecentFile(index).Caption, max(Len(MDI!mnuRecentFile(index).Caption) - 3, 0))) = Filename Then
	 OnRecentFilesList = True
	 Exit Function
       End If
     Next index
  OnRecentFilesList = False
End Function
'}}}
Sub Proc_Cascade () '{{{
   etatstereo = St.WindowState
   etatgrouptri = GroupTri.WindowState
   St.WindowState = REDUIT
   GroupTri.WindowState = REDUIT
   MDI.Arrange 0
   GroupTri.WindowState = etatgrouptri
   St.WindowState = etatstereo
End Sub
'}}}
Sub Proc_Tile_Horizontal () '{{{
   etatstereo = St.WindowState
   etatgrouptri = GroupTri.WindowState
   St.WindowState = REDUIT
   GroupTri.WindowState = REDUIT
   MDI.Arrange 1
   GroupTri.WindowState = etatgrouptri
   St.WindowState = etatstereo
End Sub
'}}}
Sub Proc_Tile_Vertical () '{{{
   etatstereo = St.WindowState
   etatgrouptri = GroupTri.WindowState
   St.WindowState = REDUIT
   GroupTri.WindowState = REDUIT
   MDI.Arrange 2
   GroupTri.WindowState = etatgrouptri
   St.WindowState = etatstereo
End Sub
'}}}
Function QuestionFermeStation (nsns As Integer) '{{{
    Dim msg, Filename, NL
    Dim Response As Integer
       If Site(nsns).dirty Then
	   Filename = Site(nsns).NomFichier
	   NL = Chr$(13) & Chr$(10)
	   msg = "Le fichier " & Filename & " a été modifié."
	   msg = msg & NL
	   msg = msg & "Enregistrer les modifications ?"
	   QuestionFermeStation = MsgBox(msg, 51)
       Else
	   QuestionFermeStation = 7
       End If
End Function
'}}}
Sub SauveTectriIni () '{{{
   On Error GoTo Traite_Erreurs36:
prompt "Sauvegarde des paramètres dans tectri.ini"
f = "tectri.ini"
'***options
   a = writeprivateprofilestring("Options", "Retracage manuel", Str$(Abs(Retracage_Manuel)), f)
   a = writeprivateprofilestring("Options", "Fichiers bkp", Str$(Abs(Fichiers_Bkp)), f)
   a = writeprivateprofilestring("Options", "Ouvrir n fichiers", Str$(Abs(Open_nFichiers)), f)
   a = writeprivateprofilestring("Options", "Enregistrement paramètres géométriques", Str$(Abs(Fichiers_Param)), f)
   
   'séparateur champs
      Select Case Separateur_champs$
	 Case Chr$(9)
	    tmp = "tab"
	 Case Else
	    tmp = "espace"
      End Select
   a = writeprivateprofilestring("Options", "Séparateur de champs", tmp, f)
   
   a = writeprivateprofilestring("Options", "Affichage mesures non triées", Str$(Abs(Aff_F_non_Sélec)), f)
   a = writeprivateprofilestring("Options", "Barre d'état", Str$(Abs(MDI!Image2.Visible)), f)
   a = writeprivateprofilestring("Options", "Barre d'outils", Str$(Abs(MDI!barre_outils.Visible)), f)
   a = writeprivateprofilestring("Options", "Impression vectorielle", Str$(Abs(Impression_Vectorielle)), f)
   a = writeprivateprofilestring("Options", "Signalement des erreurs d'exécution", Str$(Abs(Signale_Erreurs)), f)
   a = writeprivateprofilestring("Options", "Traçage progressif du stéréo", Str$(Abs(Tracage_Progressif)), f)
   a = writeprivateprofilestring("Options", "Angle teta", Str$(teta / pi * 180), f)
   a = writeprivateprofilestring("Options", "Affichage des stations icônisées", Str$(Abs(Affich_F_Stations_Icones)), f)

'***dimensions
'   a = writeprivateprofilestring("Tableau", "NbMaxiMesures", Str$(imax), f)
   
'***traces sélectionnées
   a = writeprivateprofilestring("Traces", "Traces cyclographiques de plans de failles", Str$(MDI!menu_trace(1).Checked), f)
   a = writeprivateprofilestring("Traces", "Stries", Str$(MDI!menu_trace(2).Checked), f)
   a = writeprivateprofilestring("Traces", "Polaires", Str$(MDI!menu_trace(3).Checked), f)
   a = writeprivateprofilestring("Traces", "Axes X", Str$(MDI!menu_trace(4).Checked), f)
   a = writeprivateprofilestring("Traces", "Axes Y", Str$(MDI!menu_trace(5).Checked), f)
   a = writeprivateprofilestring("Traces", "Axes Z", Str$(MDI!menu_trace(6).Checked), f)
   a = writeprivateprofilestring("Traces", "Plans de mouvement X", Str$(MDI!menu_trace(8).Checked), f)
   a = writeprivateprofilestring("Traces", "Plans de mouvement Z", Str$(MDI!menu_trace(9).Checked), f)
   a = writeprivateprofilestring("Traces", "Plans auxiliaires", Str$(MDI!menu_trace(11).Checked), f)
   a = writeprivateprofilestring("Traces", "Directions des stries", Str$(MDI!menu_trace(10).Checked), f)

'***stéréo
   a = writeprivateprofilestring("Stéréogramme", "Diamètre stéréo", Str$(DiamStereo), f)
   a = writeprivateprofilestring("Stéréogramme", "Hémisphère", Str$(Hémisphère), f)
   a = writeprivateprofilestring("Stéréogramme", "Police", St.Stereo.FontName, f)
   a = writeprivateprofilestring("Stéréogramme", "Taille caractères", St.Stereo.FontSize, f)
   a = writeprivateprofilestring("Stéréogramme", "Gras", St.Stereo.FontBold, f)
   a = writeprivateprofilestring("Stéréogramme", "Italique", St.Stereo.FontItalic, f)

'***Dièdres droits
   retstring$ = Space$(50)
   a = writeprivateprofilestring("Dièdres droits", "Couleur Z", Str$(CouleurDDroits_Z), f)
   retstring$ = Space$(50)
   a = writeprivateprofilestring("Dièdres droits", "Couleur X", Str$(CouleurDDroits_X), f)

'***Position et état des fenêtres        **** ABANDONNE, SUITE PROBLEMS ****
'   tmp = max(1, LBound(frm_Station))
   EtatMdi = MDI.WindowState
   etatstereo = St.WindowState
'   EtatDonnees = frm_Station(tmp).WindowState
   etatgrouptri = GroupTri.WindowState
   'If EtatMdi <> normal Then MDI.Hide : MDI.WindowState = normal
   'If EtatStereo <> normal Then St.WindowState = normal
   'If EtatTableau <> normal Then Tableau.WindowState = normal
   'If EtatGrouptri <> normal Then GroupTri.WindowState = normal
   '*fenêtre tectri
   a = writeprivateprofilestring("Fenêtres", "Tectri: état", Str$(EtatMdi), f)
   If EtatMdi = normal Then
      a = writeprivateprofilestring("Fenêtres", "Tectri: left", Str$(MDI.Left), f)
      a = writeprivateprofilestring("Fenêtres", "Tectri: top", Str$(MDI.Top), f)
      a = writeprivateprofilestring("Fenêtres", "Tectri: width", Str$(MDI.Width), f)
      a = writeprivateprofilestring("Fenêtres", "Tectri: height", Str$(MDI.Height), f)
   End If
   '*fenêtres-filles
'   a = writeprivateprofilestring("Fenêtres", "Tableau: état", Str$(EtatTableau), f)
'   If EtatTableau = normal Then
'      a = writeprivateprofilestring("Fenêtres", "Tableau: left", Str$(Tableau.Left), f)
'      a = writeprivateprofilestring("Fenêtres", "Tableau: top", Str$(Tableau.Top), f)
'      a = writeprivateprofilestring("Fenêtres", "Tableau: width", Str$(Tableau.Width), f)
'      a = writeprivateprofilestring("Fenêtres", "Tableau: height", Str$(Tableau.Height), f)
'   End If

   'flag = true
   a = writeprivateprofilestring("Fenêtres", "Stéréo: état", Str$(etatstereo), f)
   If etatstereo = normal Then
      a = writeprivateprofilestring("Fenêtres", "Stéréo: left", Str$(St.Left), f)
      a = writeprivateprofilestring("Fenêtres", "Stéréo: top", Str$(St.Top), f)
   End If
   a = writeprivateprofilestring("Fenêtres", "Groupes de tri: état", Str$(etatgrouptri), f)
   If etatgrouptri = normal Then
      a = writeprivateprofilestring("Fenêtres", "Groupes de tri: left", Str$(GroupTri.Left), f)
      a = writeprivateprofilestring("Fenêtres", "Groupes de tri: top", Str$(GroupTri.Top), f)
   End If
'****************
a = writeprivateprofilestring("Fenêtres", "Données: état", Str$(EtatDonnees), f)
'If EtatDonnees = normal Then
'   a = writeprivateprofilestring("Fenêtres", "Données: left", Str$(frm_Station(tmp).Left), f)
'   a = writeprivateprofilestring("Fenêtres", "Données: top", Str$(frm_Station(tmp).Top), f)
'   a = writeprivateprofilestring("Fenêtres", "Données: height", Str$(frm_Station(tmp).Height), f)
'   a = writeprivateprofilestring("Fenêtres", "Données: width", Str$(frm_Station(tmp).Width), f)
'End If
'***************
'**restauration de l'état des fenêtres
   'If MDI.Visible = False Then MDI.Visible = True
   'If MDI.WindowState <> EtatMdi Then MDI.WindowState = EtatMdi
   'If St.WindowState <> EtatStereo Then St.WindowState = EtatStereo
   'If Tableau.WindowState <> EtatTableau Then Tableau.WindowState = EtatTableau
   'If GroupTri.WindowState <> EtatGrouptri Then GroupTri.WindowState = EtatGrouptri

'**Groupes de tri
   a = writeprivateprofilestring("Groupes de tri", "Nombre de groupes", Str$(NbGroupesdeTri), f)
	 For tmp = 1 To NbGroupesdeTri
	    titre$ = "Groupe " + Str$(tmp)
	    retstring$ = Space$(50)
	    a = writeprivateprofilestring("Groupes de tri", titre$ + ": couleur", Str$(CouleurGroupe(tmp)), f)
	    a = writeprivateprofilestring("Groupes de tri", titre$ + ": commentaire", GroupTri!CommentaireGroupe(tmp), f)
	    a = writeprivateprofilestring("Groupes de tri", titre$ + ": affichage", Str$(MDI!menu_projettegroupe(tmp).Checked), f)             'Str$(Affichage(Tmp)), f)
	 Next
Exit Sub
Traite_Erreurs36:
   If Erreurs(Err, "Routines / SauveTectriIni") Then Resume Next
End Sub
'}}}
Sub selec (keyascii As Integer) '{{{
   On Error GoTo Traite_Erreurs37:
'            screen.MousePointer = 11
	    Select Case keyascii
	       Case 65 To 64 + NbGroupesdeTri   '**sélectionner mesures en a
		  SélectionMesure (keyascii - 64)
	       Case &H8, &HC, 46 'TOUCHE_RETARR, TOUCHE_EFFACER, 46
		  SélectionMesure (-1)
	       Case 32
		  '*****inverser la sélection
		  If Site(ns).Faille(i).GroupeTri = 0 Or Site(ns).Faille(i).GroupeTri = -1 Then SélectionMesure (Not (Site(ns).Faille(i).GroupeTri))
		  MetàJourMesureTableau ns, i
		  If flag <> True Then MetàJourListeGroupe
	       Case 13  '**sélectionner mesures
		  SélectionMesure (0)
	    End Select
	    If Site(ns).dirty <> True Then Site(ns).dirty = True
'            screen.MousePointer = defaut
Exit Sub
Traite_Erreurs37:
   If Erreurs(Err, "Routines / selec") Then Resume Next
End Sub
'}}}
Sub selecfailles (objet As Form, keyascii As Integer) '{{{
   On Error GoTo Traite_Erreurs38:
   screen.MousePointer = 11
   Select Case keyascii
      Case 65 To 64 + NbGroupesdeTri, 32, 13, &H8, &HC, 46'TOUCHE_RETARR, TOUCHE_EFFACER, 46
      Case Else
	 Exit Sub
   End Select
    '  If flag Then 'appel depuis le tableau de sélection
    Select Case objet.Tag
      Case "tableau"
	 ns1 = objet.Grille.SelStartRow
	 ns2 = objet.Grille.SelEndRow
	 i1 = objet.Grille.SelStartCol
	 i2 = objet.Grille.SelEndCol
      Case "stéréo"
	 ns1 = ns
	 ns2 = ns
	 i1 = i
	 i2 = i
      Case 1 To NbStations
	 i1 = objet.Grille.SelStartRow
	 i2 = objet.Grille.SelEndRow
	 ns1 = ns
	 ns2 = ns
      Case Else
	 screen.MousePointer = defaut
	 Exit Sub
      End Select
    '  Else
    '     row1 = ns
    '     row2 = ns
    '     col1 = i
    '     col2 = i
    '  End If
      nsavant = ns
      iavant = i
      For ns = ns1 To Min(ns2, NbStations)
	 If Not (Site(ns).deleted) Then
	    If Not (Affich_F_Stations_Icones = False And frm_Station(ns).WindowState = REDUIT) Then
	       If ns = 0 Then ns = 1
	       For i = i1 To Min(i2, Site(ns).NbMes)
		  If i = 0 Then i = 1
		  flagi = flag
		  flag = True
		  selec (keyascii)
		  Tracage St!Stereo
		  flag = flagi
	       Next
	    End If
	 End If
      Next
      ns = nsavant
      i = iavant
   MetàJourListeGroupe
   screen.MousePointer = defaut
Exit Sub
Traite_Erreurs38:
   If Erreurs(Err, "Routines / selecfailles") Then Resume Next
End Sub
'}}}
Sub selecfailles_jeu (ByVal jeux As String) '{{{
   On Error GoTo Traite_Erreurs39:
   'Sélectionne les failles de jeu "jeu"
   screen.MousePointer = 11
   jeux = UCase$(jeux)
      nsavant = ns
      iavant = i
      For ns = 1 To NbStations
	 If Not (Site(ns).deleted) Then
	    If Not (Affich_F_Stations_Icones = False And frm_Station(ns).WindowState = REDUIT) Then
	       For i = 1 To Site(ns).NbMes
		  Select Case Len(jeux)
		     Case 1
			If UCase$(Site(ns).Faille(i).param.jv) = jeux Or UCase$(Site(ns).Faille(i).param.jh) = jeux Then GoSub Selection
		     Case 2
			If (UCase$(Site(ns).Faille(i).param.jv) = Mid$(jeux, 1, 1) And UCase$(Site(ns).Faille(i).param.jh) = Mid$(jeux, 2, 1)) Or (UCase$(Site(ns).Faille(i).param.jv) = Mid$(jeux, 2, 1) And UCase$(Site(ns).Faille(i).param.jh) = Mid$(jeux, 1, 1)) Then GoSub Selection
		     Case Else
		  End Select
	       Next
	    End If
	 End If
      Next
      ns = nsavant
      i = iavant
   MetàJourListeGroupe
   screen.MousePointer = defaut
   Exit Sub
Selection:
   If Site(ns).Faille(i).GroupeTri <> 0 Then
      SélectionMesure (0)
      If Site(ns).dirty <> True Then Site(ns).dirty = True
      Tracage St!Stereo
   End If
Return
Exit Sub
Traite_Erreurs39:
   If Erreurs(Err, "Routines / selecfailles_jeu") Then Resume Next
End Sub
'}}}
Sub SélectionMesure (groupe) '{{{
   On Error GoTo Traite_Erreurs40:
'Nb:        groupe  symbolegroupedetri
'              -1
'               0   *
'               1   a
'               2   b
'               3   c
'               4   d
   If (i > Site(ns).NbMes Or Site(ns).Faille(i).GroupeTri = groupe) Then Exit Sub
      rien = Site(ns).Faille(i).GroupeTri
      If rien >= 0 Then NbMesSelect%(rien) = NbMesSelect%(rien) - 1
   If Site(ns).dirty <> True Then Site(ns).dirty = True
   'Incrémentation populat° groupe
   If groupe >= 0 Then NbMesSelect%(groupe) = NbMesSelect%(groupe) + 1
   Site(ns).Faille(i).GroupeTri = groupe
   MetàJourMesureTableau ns, i
   'MetàJourListeGroupe
   'Tracage St!Stereo
Exit Sub
Traite_Erreurs40:
   If Erreurs(Err, "Routines / SélectionMesure") Then Resume Next
End Sub
'}}}
Function TestFormatFicTratrTectri$ (fichier) '{{{
   On Error Resume Next
   Close #1
   Open fichier For Input As #1
   'Test: fichier tectri ou tratr?
      Line Input #1, Ligne$
      dummy = CDbl(Ligne$)
      If Err Then
	 TestFormatFicTratrTectri$ = "tectri"
      Else
	 TestFormatFicTratrTectri$ = "tratr"
      End If
   Err = 0
   Close #1
End Function
'}}}
Sub UpdateFileMenu (Filename) '{{{
	Filename = LCase$(Filename)
	Dim RetVal
	' Check if OpenFileName is already on MRU list.
	RetVal = OnRecentFilesList(Filename)
	If Not RetVal Then
	  WriteRecentFiles (Filename)
	End If
	' Update menus for most recent file list.
	GetRecentFiles
End Sub
'}}}
Sub WriteRecentFiles (OpenFileName) '{{{
  Dim index, j, key, RetVal
  Dim IniString As String
  IniString = String(255, 0)
  OpenFileName = LCase$(OpenFileName)

  ' Copy RecentFile1 to RecentFile2, etc.
  For index = 7 To 1 Step -1
    key = "Fichier" & index
    RetVal = getprivateprofilestring("Liste des derniers fichiers", key, "Non Utilisé", IniString, Len(IniString), "tectri.ini")
    If RetVal And Left(IniString, 8) <> "Non Utilisé" Then
      key = "Fichier" & (index + 1)
      RetVal = writeprivateprofilestring("Liste des derniers fichiers", key, IniString, "tectri.ini")
    End If
  Next index
  
  ' Write openfile to first Recent File.
    RetVal = writeprivateprofilestring("Liste des derniers fichiers", "Fichier1", OpenFileName, "tectri.ini")
End Sub
'}}}
