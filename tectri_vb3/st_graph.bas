 
 'Ensemble des subs concernant les tracés sur stéréogramme.

 'Définitions pour les dièdres droits:
Declare Function FloodFill Lib "Gdi" (ByVal hDC%, ByVal x%, ByVal y%, ByVal crColor&) As Integer

Declare Function ExtFloodFill Lib "Gdi" (ByVal hDC%, ByVal x%, ByVal y%, ByVal crColor&, ByVal wFillType%) As Integer

'  ExtFloodFill style flags
Const FLOODFILLBORDER = 0
Const FLOODFILLSURFACE = 1

'*** Démo Blit***

Dim Xs%, Ys%, X1%, Y1%
Dim lpRect As RECT

Sub affAuxDdroit (feuille As Control, Entier%)
   On Error GoTo Traite_Erreurs1:
      cleur& = CouleurMesureàProjeter(feuille.BackColor, MDI!menu_trace(11).Checked)
      On Error Resume Next
	 Select Case Entier%
	    Case 1
	       feuille.Circle (Site(ns).Faille(i).param.Xaux, Site(ns).Faille(i).param.Yaux), Site(ns).Faille(i).param.Raux, feuille.ForeColor: ', , , forme
	    Case Else
	       feuille.Circle (Site(ns).Faille(i).param.Xaux, Site(ns).Faille(i).param.Yaux), Site(ns).Faille(i).param.Raux, cleur&, modulo(-(Hémisphère < 0) * pi + Site(ns).Faille(i).param.AngleDepAux, 2 * pi), modulo(-(Hémisphère < 0) * pi + Site(ns).Faille(i).param.AngleArrAux, 2 * pi)
	 End Select
      If Err Then
	 theta = Atn(Site(ns).Faille(i).param.Xaux / Site(ns).Faille(i).param.Yaux) + pi / 2
	 feuille.Line (Sin(theta), Cos(theta))-(-Sin(theta), -Cos(theta)), feuille.ForeColor
      End If
Exit Sub
Traite_Erreurs1:
   If Erreurs(Err, "St-Graph / affAuxDdroit") Then Resume Next
End Sub

Sub affFlechesDirMvtsRelBlocs (feuille As Control)
   On Error GoTo Traite_Erreurs2:
cleur& = CouleurMesureàProjeter(feuille.BackColor, MDI!menu_trace(10).Checked)
'feuille.Line (d1 * Sin(faille(ns,i).param.AzStri), d1 * Cos(faille(ns,i).param.AzStri))-(d2 * Sin(faille(ns,i).param.AzStri), d2 * Cos(faille(ns,i).param.AzStri)), cleur&
'feuille.Line (-d1 * Sin(faille(ns,i).param.AzStri), -d1 * Cos(faille(ns,i).param.AzStri))-(-d2 * Sin(faille(ns,i).param.AzStri), -d2 * Cos(faille(ns,i).param.AzStri)), cleur&
 If Site(ns).Faille(i).param.sax ^ 2 + Site(ns).Faille(i).param.say ^ 2 < Site(ns).Faille(i).param.SX ^ 2 + Site(ns).Faille(i).param.SY ^ 2 Then
  tracefleche feuille, Site(ns).Faille(i).param.azstri, "distension", cleur&, 1
 End If
 If Site(ns).Faille(i).param.sax ^ 2 + Site(ns).Faille(i).param.say ^ 2 > Site(ns).Faille(i).param.SX ^ 2 + Site(ns).Faille(i).param.SY ^ 2 Then
  tracefleche feuille, Site(ns).Faille(i).param.azstri, "compression", cleur&, 1
 End If
Exit Sub
Traite_Erreurs2:
   If Erreurs(Err, "St-Graph / affFlechesDirMvtsRelBlocs") Then Resume Next
End Sub

Sub affpmvtx (feuille As Control)
   On Error GoTo Traite_Erreurs3:
   cleur& = CouleurMesureàProjeter(feuille.BackColor, MDI!menu_trace(8).Checked)
   On Error Resume Next
   If Site(ns).Faille(i).param.Angledeppmvtx1 <> Site(ns).Faille(i).param.Anglearrpmvtx1 Then
      feuille.Circle (Site(ns).Faille(i).param.xmvt, Site(ns).Faille(i).param.ymvt), Site(ns).Faille(i).param.Rmvt, cleur&, modulo(-(Hémisphère < 0) * pi + Site(ns).Faille(i).param.Angledeppmvtx1, 2 * pi), modulo(-(Hémisphère < 0) * pi + Site(ns).Faille(i).param.Anglearrpmvtx1, 2 * pi)
   End If
   If Site(ns).Faille(i).param.Angledeppmvtx2 <> Site(ns).Faille(i).param.Anglearrpmvtx2 Then
      feuille.Circle (Site(ns).Faille(i).param.xmvt, Site(ns).Faille(i).param.ymvt), Site(ns).Faille(i).param.Rmvt, cleur&, modulo(-(Hémisphère < 0) * pi + Site(ns).Faille(i).param.Angledeppmvtx2, 2 * pi), modulo(-(Hémisphère < 0) * pi + Site(ns).Faille(i).param.Anglearrpmvtx2, 2 * pi):      ', forme
   End If
   If Err Then
      theta = Atn(Site(ns).Faille(i).param.xmvt / Site(ns).Faille(i).param.ymvt) + pi / 2
      feuille.Line (Sin(theta), Cos(theta))-(-Sin(theta), -Cos(theta)), feuille.ForeColor
   End If
Exit Sub
Traite_Erreurs3:
   If Erreurs(Err, "St-Graph / affpmvtx") Then Resume Next
End Sub

Sub affpmvtz (feuille As Control)
   On Error GoTo Traite_Erreurs4:
   cleur& = CouleurMesureàProjeter(feuille.BackColor, MDI!menu_trace(9).Checked)
   On Error Resume Next
   If Site(ns).Faille(i).param.Angledeppmvtz1 <> Site(ns).Faille(i).param.Anglearrpmvtz1 Then
      feuille.Circle (Site(ns).Faille(i).param.xmvt, Site(ns).Faille(i).param.ymvt), Site(ns).Faille(i).param.Rmvt, cleur&, modulo(-(Hémisphère < 0) * pi + Site(ns).Faille(i).param.Angledeppmvtz1, 2 * pi), modulo(-(Hémisphère < 0) * pi + Site(ns).Faille(i).param.Anglearrpmvtz1, 2 * pi)
      '  Debug.Print faille(ns,i).param.xmvt, faille(ns,i).param.ymvt, site(ns).faille(i).param.Rmvt
      '  Debug.Print 180 / pi * modulo(-(Hémisphère < 0) * pi + faille(ns,i).param.Angledeppmvtz1, 2 * pi)
      '  Debug.Print 180 / pi * modulo(-(Hémisphère < 0) * pi + faille(ns,i).param.Anglearrpmvtz1, 2 * pi)
      'Circle (faille(ns,i).param.xmvt, faille(ns,i).param.ymvt), site(ns).faille(i).param.Rmvt, cleur, faille(ns,i).param.Angledeppmvtz1, faille(ns,i).param.Anglearrpmvtz1, forme
   End If
   If Site(ns).Faille(i).param.Angledeppmvtz2 <> Site(ns).Faille(i).param.Anglearrpmvtz2 Then
      feuille.Circle (Site(ns).Faille(i).param.xmvt, Site(ns).Faille(i).param.ymvt), Site(ns).Faille(i).param.Rmvt, cleur&, modulo(-(Hémisphère < 0) * pi + Site(ns).Faille(i).param.Angledeppmvtz2, 2 * pi), modulo(-(Hémisphère < 0) * pi + Site(ns).Faille(i).param.Anglearrpmvtz2, 2 * pi):      ', forme
   End If
   'Circle (faille(ns,i).param.xmvt, faille(ns,i).param.ymvt), site(ns).faille(i).param.Rmvt, cleur, faille(ns,i).param.Angledeppmvtz1, faille(ns,i).param.Anglearrpmvtz1, forme
   If Err Then
      theta = Atn(Site(ns).Faille(i).param.xmvt / Site(ns).Faille(i).param.ymvt) + pi / 2
      feuille.Line (Sin(theta), Cos(theta))-(-Sin(theta), -Cos(theta)), feuille.ForeColor
   End If
Exit Sub
Traite_Erreurs4:
   If Erreurs(Err, "St-Graph / affpmvtz") Then Resume Next
End Sub

Sub affPol (feuille As Control)
   On Error GoTo Traite_Erreurs5:
	cleur& = CouleurMesureàProjeter(feuille.BackColor, MDI!menu_trace(3).Checked)
	'point
	'feuille.PSet (Site(ns).Faille(i).param.PolX, Site(ns).Faille(i).param.PolY), cleur&
	'croix
	zoo = .02
	feuille.Line (Site(ns).Faille(i).param.PolX - zoo, Site(ns).Faille(i).param.PolY - zoo)-(Site(ns).Faille(i).param.PolX + zoo, Site(ns).Faille(i).param.PolY + zoo), cleur&
	feuille.Line (Site(ns).Faille(i).param.PolX - zoo, Site(ns).Faille(i).param.PolY + zoo)-(Site(ns).Faille(i).param.PolX + zoo, Site(ns).Faille(i).param.PolY - zoo), cleur&
Exit Sub
Traite_Erreurs5:
   If Erreurs(Err, "St-Graph / affPol") Then Resume Next
End Sub

Sub affstrie (feuille As Control)
   On Error GoTo Traite_Erreurs6:
   cleur& = CouleurMesureàProjeter(feuille.BackColor, MDI!menu_trace(2).Checked)
  If Hémisphère < 0 Then
    localSAX = Site(ns).Faille(i).param.SX - (Site(ns).Faille(i).param.sax - Site(ns).Faille(i).param.SX)
    localSAY = Site(ns).Faille(i).param.SY - (Site(ns).Faille(i).param.say - Site(ns).Faille(i).param.SY)
    localSFX = Site(ns).Faille(i).param.SX - (Site(ns).Faille(i).param.sfx - Site(ns).Faille(i).param.SX)
    localSFY = Site(ns).Faille(i).param.SY - (Site(ns).Faille(i).param.sfy - Site(ns).Faille(i).param.SY)
  Else
    localSAX = Site(ns).Faille(i).param.sax
    localSAY = Site(ns).Faille(i).param.say
    localSFX = Site(ns).Faille(i).param.sfx
    localSFY = Site(ns).Faille(i).param.sfy
  End If
    feuille.Line (localSAX, localSAY)-(Site(ns).Faille(i).param.SX, Site(ns).Faille(i).param.SY), cleur&
    feuille.Circle (Site(ns).Faille(i).param.SX, Site(ns).Faille(i).param.SY), .01, cleur&: ', , , forme
    feuille.Line (localSAX, localSAY)-(localSFX, localSFY), cleur&
Exit Sub
Traite_Erreurs6:
   If Erreurs(Err, "St-Graph / affstrie") Then Resume Next
End Sub

Sub affTraceCyclo (feuille As Control, Entier%)
    'Affiche la trace cyclographique de la faille ns, i sur le stéréo feuille; l'Entier semble être un flag?
   On Error GoTo Traite_Erreurs7:
   cleur& = CouleurMesureàProjeter(feuille.BackColor, MDI!menu_trace(1).Checked)
   On Error Resume Next
   Select Case Entier%
      Case 1
	 feuille.Circle (Site(ns).Faille(i).param.ox, Site(ns).Faille(i).param.oy), Site(ns).Faille(i).param.r, feuille.ForeColor: 'cleur&: ', forme
      Case Else
	 If Site(ns).Faille(i).param.r = -1 Then '**Plan vertical
	    feuille.Line (Site(ns).Faille(i).param.ox, Site(ns).Faille(i).param.oy)-(-Site(ns).Faille(i).param.ox, -Site(ns).Faille(i).param.oy), cleur&
	 Else
	    feuille.Circle (Site(ns).Faille(i).param.ox, Site(ns).Faille(i).param.oy), Site(ns).Faille(i).param.r, cleur&, modulo(-(Hémisphère < 0) * pi + Site(ns).Faille(i).param.Angledep, 2 * pi), modulo(-(Hémisphère < 0) * pi + Site(ns).Faille(i).param.Anglearr, 2 * pi):      ', forme
	 End If
   End Select
   If Err Then
      theta = Atn(Site(ns).Faille(i).param.ox / Site(ns).Faille(i).param.oy) + pi / 2
      feuille.Line (Sin(theta), Cos(theta))-(-Sin(theta), -Cos(theta)), feuille.ForeColor
   End If
Exit Sub
Traite_Erreurs7:
   If Erreurs(Err, "St-Graph / affTraceCyclo") Then Resume Next
End Sub

Sub affx (feuille As Control)
   On Error GoTo Traite_Erreurs8:
	cleur& = CouleurMesureàProjeter(feuille.BackColor, MDI!menu_trace(4).Checked)
 feuille.PSet (Site(ns).Faille(i).param.AxeXX, Site(ns).Faille(i).param.AxeXY), cleur&
 feuille.Line (Site(ns).Faille(i).param.AxeXX - .02, Site(ns).Faille(i).param.AxeXY)-(Site(ns).Faille(i).param.AxeXX + .02, Site(ns).Faille(i).param.AxeXY), cleur&
 feuille.Line (Site(ns).Faille(i).param.AxeXX, Site(ns).Faille(i).param.AxeXY - .02)-(Site(ns).Faille(i).param.AxeXX, Site(ns).Faille(i).param.AxeXY + .02), cleur&
 feuille.Circle (Site(ns).Faille(i).param.AxeXX, Site(ns).Faille(i).param.AxeXY), .02, cleur&: ', , , forme
Exit Sub
Traite_Erreurs8:
   If Erreurs(Err, "St-Graph / affx") Then Resume Next
End Sub

Sub affy (feuille As Control)
   On Error GoTo Traite_Erreurs9:
	cleur& = CouleurMesureàProjeter(feuille.BackColor, MDI!menu_trace(5).Checked)
	feuille.Circle (Site(ns).Faille(i).param.AxeYX, Site(ns).Faille(i).param.AxeYY), .02, cleur&: ', , , forme
	feuille.PSet (Site(ns).Faille(i).param.AxeYX, Site(ns).Faille(i).param.AxeYY), cleur&
Exit Sub
Traite_Erreurs9:
   If Erreurs(Err, "St-Graph / affy") Then Resume Next
End Sub

Sub affz (feuille As Control)
   On Error GoTo Traite_Erreurs10:
	cleur& = CouleurMesureàProjeter(feuille.BackColor, MDI!menu_trace(6).Checked)
	feuille.PSet (Site(ns).Faille(i).param.AxeZX, Site(ns).Faille(i).param.AxeZY), cleur&
	feuille.Line Step(.02, 0)-Step(-.04, 0), cleur&
	feuille.PSet (Site(ns).Faille(i).param.AxeZX, Site(ns).Faille(i).param.AxeZY), cleur&
	feuille.Line Step(0, .02)-Step(0, -.04), cleur&
Exit Sub
Traite_Erreurs10:
   If Erreurs(Err, "St-Graph / affz") Then Resume Next
End Sub

Sub chg_diam_stereo ()
   On Error GoTo Traite_Erreurs11:
   'Change le diamètre du stéréo et de sa fenêtre; appelé par st_resize
   prompt "Changement du diamètre du stéréo"
   bordures = st.Width - st.ScaleWidth
   If DiamStereo < 1 Then DiamStereo = 1
   tmp = DiamStereo * (1.2 * 567) + bordures'* 1.04817927170868'*567 si scalemode en twips; *1.04817927170868=correction: width & scalewidth ont une ptite diff
      flagi = flag
	 If st.WindowState = normal Then
	    flag = True
	    st.Height = tmp + HauteurBarreTitre + bordures
	    flag = True
	    st.Width = tmp + bordures
	 End If
      flag = flagi
   st!Stereo.Width = tmp
   st!Stereo.Height = tmp
      'If st!bmp.Picture <> LoadPicture("") Then
	 'stretcher le bmp, puis le resizer
	 st!Stereo.Cls
	 st!Stereo.ScaleMode = 3
	 st!bmp.ScaleMode = 3
	 st!bmp.Refresh
	 Res% = StretchBlt(st!Stereo.hDC, 0, 0, st!Stereo.ScaleWidth, st!Stereo.ScaleHeight, st!bmp.hDC, 0, 0, st!bmp.ScaleWidth, st!bmp.ScaleHeight, &HCC0020) 'Res% = StretchBlt(St!Stereo.hDC, 0, 0, Abs(St!Stereo.ScaleWidth), Abs(St!Stereo.ScaleHeight), St!bmp.hDC, 0, 0, Abs(St!bmp.ScaleWidth), Abs(St!bmp.ScaleHeight), SRCCOPY)
	 st!Stereo.Refresh
		  'res% = StretchBlt(stereo.hDC, 0, 0, stereo.ScaleWidth, stereo.ScaleHeight, stereotmp.hDC, 0, 0, stereotmp.ScaleWidth, stereotmp.ScaleHeight, SRCCOPY)
		  'Res% = StretchBlt(stereo.hDC, 0, 0, stereo.ScaleWidth, stereo.ScaleHeight, stereotmp.hDC, 0, 0, stereotmp.ScaleWidth, stereotmp.ScaleHeight, SRCCOPY)
		  'res% = StretchBlt(stereotmp.hDC, 0, 0, stereotmp.ScaleWidth, stereotmp.ScaleHeight, stereo.hDC, 0, 0, stereo.ScaleWidth, stereo.ScaleHeight, SRCCOPY)
	     'stereolargeur = Stereo.Width / TwipsPerPixelX
	     'stereohauteur = Stereo.Height / TwipsPerPixelY
	    ' Res% = StretchBlt(Stereo.hDC, 0, 0, Int(Stereo.Width / screen.TwipsPerPixelX), Int(Stereo.Height / screen.TwipsPerPixelY), stereotmp.hDC, 0, 0, Int(stereotmp.Width / screen.TwipsPerPixelX), Int(stereotmp.Height / screen.TwipsPerPixelY), SRCCOPY)
	    '      Stereo.Refresh
		  
	     '     If Res% = 0 Then Beep
      
	 st!bmp.Width = tmp
	 st!bmp.Height = tmp
	 st!bmp.Picture = st!Stereo.Image
      'Else
      '   st!bmp.Width = tmp
      '   st!bmp.Height = tmp
      'End If
   If flag = flag_chargement Then Exit Sub
   RedessinStereo st!Stereo
Exit Sub
Traite_Erreurs11:
   If Erreurs(Err, "St-Graph / chg_diam_stereo") Then Resume Next
End Sub

Sub ColleStereo ()
   On Error GoTo Traite_Erreurs12:
   If (clipboard.GetFormat(8) Or clipboard.GetFormat(2)) Then
      st!bmp.Picture = clipboard.GetData()
      RedessinStereo st!Stereo
   Else
      Beep
   End If
Exit Sub
Traite_Erreurs12:
   If Erreurs(Err, "St-Graph / collestereo") Then Resume Next
End Sub

Sub CopieStereo ()
   On Error GoTo Traite_Erreurs13:
   prompt "Copie du stéréo dans le presse-papier"
   MDI!lblStatus.Refresh
   'essayer tout ça, l'optionner au besoin
      '(à partir de boite_options, modif conséquente du titre de ce menu)
   screen.MousePointer = 11
   clipboard.Clear
 '  clipboard.SetData St!Stereo.Image
   clipboard.SetData st!Stereo.Image, 2 'marche
 '  clipboard.SetData St!Stereo.Image, 3 'marche pas
 '  clipboard.SetData St!Stereo.Image, &HBF00 'marche pas
 '  clipboard.SetData St!Stereo.Image, 8 'marche
   screen.MousePointer = defaut
Exit Sub
Traite_Erreurs13:
   If Erreurs(Err, "St-Graph / CopieStereo") Then Resume Next
End Sub

Sub DéfinitionHémisphère (feuille As Control)
   On Error GoTo Traite_Erreurs14:
   'Hémisphère -> +1: sup
   '              -1: inf
   screen.MousePointer = 11
   Hémisphère = -(Hémisphère)
      Select Case Hémisphère
	 Case -1
	    MDI!menu_hémisphère.Caption = "Hémisphère sup"  '      MDI!HémisphèreIco(1).Visible = False
	 Case 1
	    MDI!menu_hémisphère.Caption = "Hémisphère inf"  '      MDI!HémisphèreIco(1).Visible = True
      End Select
			      '    MDI!HémisphèreIco(2).Visible = Not (MDI!HémisphèreIco(1).Visible)
				  'tmp1 = MDI!HémisphèreIco(1).Visible
				  'tmp2 = MDI!HémisphèreIco(2).Visible
				  ' swap tmp1, tmp2
				  'MDI!HémisphèreIco(1).Visible = tmp1
				  'MDI!HémisphèreIco(2).Visible = tmp2
   If MDI!hemisphere.Picture <> MDI!HémisphèreIco(-1 / 2 * Hémisphère + 1.5).Picture Then MDI!hemisphere.Picture = MDI!HémisphèreIco(-1 / 2 * Hémisphère + 1.5).Picture
   flagi = flag
   flag = True
	 '            If Hémisphère = -1 Then
	 '               If MDI!Hemisphere_Push3D1.Value <> -1 Then MDI!Hemisphere_Push3D1.Value = -1
	 '            ElseIf Hémisphère = 1 Then
	 '               If MDI!Hemisphere_Push3D1.Value <> 1 Then MDI!Hemisphere_Push3D1.Value = 1
	 '            End If
   'If MDI!Hemisphere_Push3D1.Value <> Hémisphère Then MDI!Hemisphere_Push3D1.Value = Hémisphère
   flag = flagi
   'If MDI!barre_outils.Visible Then MDI!barre_outils.Refresh
      If Retracage_Manuel Then
	 If st.Caption <> "{F9}Stéréogramme" Then
	    st.Caption = "{F9}Stéréogramme"
	 End If
	 screen.MousePointer = defaut
	 Exit Sub
      Else
	 If st.Caption <> "Stéréogramme" Then
	    st.Caption = "Stéréogramme"
	 End If
      End If
   CtrlF9
   screen.MousePointer = defaut
Exit Sub
Traite_Erreurs14:
   If Erreurs(Err, "St-Graph / DéfinitionHémisphère") Then Resume Next
End Sub

Sub Get_Put_image (provenance As Control, destination As Control, operateur As String)
   On Error GoTo Traite_Erreurs15:
   'Destiné à remplacer get et put du qb.
      Select Case LCase$(operateur)
	 'or,xor,and,and1,and2,paint,invert
	 Case "and"
	    rop& = &HEE0086'srcpaint
	 Case "or"
	    rop& = &HEE0086'srcpaint
	 Case "xor"
	    rop& = &H660046'srcinvert
	 Case "and1"
	    rop& = &H1100A6'notsrcerase
	 Case "paint"
	    rop& = &HEE0086'srcpaint
	 Case "and2"
	    rop& = &H8800C6'srcand
	 Case Else
	    rop& = &HCC0020'SRCCOPY
      End Select
   If rop& = 0 Then Beep: Beep: Exit Sub
   temp% = BitBlt(destination.hDC, 0, 0, provenance.Height, provenance.Width, provenance.hDC, 0, 0, rop&)
 
   If LCase$(operateur) = "xor" Then
      tmptmp = destination.DrawMode
      destination.DrawMode = MASQUE_CRAYON_NONAFFICHAGE
      destination.Line (-coté, -coté)-(coté, coté), destination.BackColor, BF
      destination.DrawMode = tmptmp
   End If
   destination.Refresh
Exit Sub
Traite_Erreurs15:
   If Erreurs(Err, "St-Graph / Get_Put_image") Then Resume Next
End Sub

Sub getstereo (provenance As Control, destination As Control)
    Get_Put_image provenance, destination, ""
End Sub

Sub letraset (Stereo As Control, Regime$, azsigma(), onoff)
   On Error GoTo Traite_Erreurs16:
    'Sub destinée à tracer sur le stéréo indiqué, une fois
    'un calcul de tenseur effectué, les flèches de compression
    'et/ou distension
    '  input:
    '   -stereo sur lequel tracer
    '   -régime
    '   -direction des 2 tenseurs horiz
  Select Case onoff
   Case False
    cleur& = Stereo.BackColor
   Case Else
    cleur& = Stereo.ForeColor
  End Select
 Select Case Regime$
    Case "(tenseur oblique)"
     If onoff Then flag = True: TenseurFocStri!Coche_letraset.Value = False: flag = False: If Stereo Is TenseurFocStri!Stereo Then Beep
     Exit Sub
    Case "Compression diffuse", "~Compression diffuse"
       nb_fl_ext = 0
       nb_fl_comp = 4
       tracefleche Stereo, azsigma(1), "compression", cleur&, 2
       tracefleche Stereo, azsigma(2), "compression", cleur&, 2
    Case "Compression vraie", "~Compression vraie"
       nb_fl_ext = 0
       nb_fl_comp = 2
       tracefleche Stereo, azsigma(1), "compression", cleur&, 2
    Case "Transpression", "~Transpression"
       tracefleche Stereo, azsigma(1), "compression", cleur&, 2
    Case "Compression décrochante", "~Compression décrochante"
       tracefleche Stereo, azsigma(1), "compression", cleur&, 2
       tracefleche Stereo, azsigma(3), "distension", cleur&, 2
    Case "Transtension", "~Transtension"
       tracefleche Stereo, azsigma(3), "distension", cleur&, 2
    Case "Distension vraie", "~Distension vraie"
       tracefleche Stereo, azsigma(3), "distension", cleur&, 2
    Case "Distension diffuse", "~Distension diffuse"
       tracefleche Stereo, azsigma(3), "distension", cleur&, 2
       tracefleche Stereo, azsigma(2), "distension", cleur&, 2
 End Select
Exit Sub
Traite_Erreurs16:
   If Erreurs(Err, "St-Graph / letraset") Then Resume Next
End Sub

Sub paint (dessin As Control, x, y, couleur&)
   On Error GoTo Traite_Erreurs17:
   'Redéfinition de dessin.scalemode
   'pour pouvoir passer à floodfill des valeurs entières en x,y, pixels
   dessin.ScaleMode = pixel
   facteur = dessin.ScaleWidth
      xprime = (x * facteur / (2 * coté * Hémisphère)) + facteur / 2
      yprime = (-y * facteur / (2 * coté * Hémisphère)) + facteur / 2
   
   tmp1 = dessin.FillStyle
   dessin.FillStyle = plein
   tmp = FloodFill(dessin.hDC, xprime, yprime, couleur&)
   dessin.Refresh
   If tmp = 0 Then Beep 'pbm; sinon, tvb
   dessin.FillStyle = tmp1
   dessin.Scale (-coté * Hémisphère, coté * Hémisphère)-(coté * Hémisphère, -coté * Hémisphère)
Exit Sub
Traite_Erreurs17:
   If Erreurs(Err, "St-Graph / paint") Then Resume Next
End Sub

Sub ProjetteLes (feuille As Control, ByVal trac)
   On Error GoTo Traite_Erreurs18:
If NbMesuresAffichees() = 0 Then Exit Sub
   nsavant = ns
   iavant = i
      For ns = 1 To NbStations
	 If Not (Site(ns).deleted) Then
	    If Not (Affich_F_Stations_Icones = False And frm_Station(ns).WindowState = REDUIT) Then
	       For i = 1 To Site(ns).NbMes
		  If Site(ns).Faille(i).GroupeTri >= 0 Then
		     If MDI!menu_projettegroupe(Site(ns).Faille(i).GroupeTri).Checked Then           'Affichage(Site(ns).Faille(i).GroupeTri) Then
			'trace st!Stereo, trac
			trace feuille, trac
			If Tracage_Progressif Then If Tracage_Progressif Then feuille.Refresh  'Refresh_Stereo
		     End If
		  End If
	       Next
	    End If
	 End If
      Next
   ns = nsavant
   i = iavant
Exit Sub
Traite_Erreurs18:
   If Erreurs(Err, "St-Graph / ProjetteLes") Then Resume Next
End Sub

Sub ProjetteTenseur ()
'(tenseur As tenseur, feuille As Control, flags)
   
   '*** projette le tenseur en question sur le stéréo indiqué ***
   ' from focstri Dim xsigma(1 To 3), ysigma(1 To 3), PlSigma(1 To 3), azsigma(1 To 3)
   

End Sub

Sub PutStereo (provenance As Control, operateur As String, destination As Control)
    Get_Put_image provenance, destination, operateur
End Sub

Sub RedessinStereo (feuille As Control)
   On Error GoTo Traite_Erreurs19:
 'Demo
 If Retracage_Manuel Then
   If st.Caption <> "{F9}Stéréogramme" Then
      st.Caption = "{F9}Stéréogramme"
   End If
   Exit Sub
 Else
   If st.Caption <> "Stéréogramme" Then
      st.Caption = "Stéréogramme"
   End If
 End If
 prompt "Retraçage du stéréo"
 MDI!lblStatus.Refresh
 screen.MousePointer = 11
 TraceStereoVierge feuille
 If Tracage_Progressif Then feuille.Refresh  'Refresh_Stereo
 
   For index = 1 To 11
      If index <> 7 Then
	 If MDI!menu_trace(index).Checked Then ProjetteLes feuille, index
      End If
   Next
  'If MDI!menu_trace(1).Checked Then ProjetteLes feuille, "TraceCyclo"
  'If MDI!menu_trace(1).Checked Then ProjetteLes feuille, "TraceCyclo"
  'If MDI!menu_trace(2).Checked Then ProjetteLes feuille, "Stries"
  'If MDI!menu_trace(3).Checked Then ProjetteLes feuille, "Polaire"
  'If MDI!menu_trace(4).Checked Then ProjetteLes feuille, "axeX"
  'If MDI!menu_trace(5).Checked Then ProjetteLes feuille, "axeY"
  'If MDI!menu_trace(6).Checked Then ProjetteLes feuille, "axeZ"
  'If MDI!menu_trace(8).Checked Then ProjetteLes feuille, "pmvtXs"
  'If MDI!menu_trace(9).Checked Then ProjetteLes feuille, "pmvtZs"
  'If MDI!menu_trace(11).Checked Then ProjetteLes feuille, "AuxDdroit"
  'If MDI!menu_trace(10).Checked Then ProjetteLes feuille, "FlechesDirMvtsRelBlocs"
 prompt ""
 screen.MousePointer = defaut
Exit Sub
Traite_Erreurs19:
   If Erreurs(Err, "St-Graph / RedessinStereo") Then Resume Next
End Sub

Sub Toggle (ByVal index)
   On Error GoTo Traite_Erreurs20:
   'Toggle la trace Index:
      'Index Trace
      '1  cyclo
      '2  strie
      '3  pol
      '4  x
      '5  y
      '6  z
      '7  pmvt
      '8  pmvtx
      '9  pmvtz
      '10 azstri
      '11 aux
   screen.MousePointer = 11
   MDI!menu_trace(index).Checked = Not (MDI!menu_trace(index).Checked)
			   'tmp$ = MDI!bouton_cyclo.Caption
			   '   Select Case MDI!menu_trace(index).Checked
			   '      Case -1
			   '         tmp$ = UCase$(tmp$)
			   '      Case Else
			   '         tmp$ = LCase$(tmp$)
			   '   End Select
			   'MDI!bouton_cyclo.Caption = tmp$
      If index <= 9 And index >= 7 Then 'on touche aux pmvts
	 If index = 7 Then
	    MDI!menu_trace(8).Checked = MDI!menu_trace(index).Checked
	    MDI!menu_trace(9).Checked = MDI!menu_trace(index).Checked
	    'flag = True
	    'Toggle (8)
	    'Toggle (9)
	    'flag = False
	 End If
	 If index = 8 Or index = 9 Then
	    'MDI!menu_trace(index).Checked = Not (MDI!menu_trace(index).Checked)
	    MDI!menu_trace(7).Checked = MDI!menu_trace(8).Checked And MDI!menu_trace(9).Checked
	       If Not (MDI!Check3D_trace(7).Value = MDI!menu_trace(7).Checked) Then
		  flag = True
		  MDI!Check3D_trace(7).Value = MDI!menu_trace(7).Checked
		  flag = False
	       ElseIf (Abs(MDI!Check3D_trace(7).Value) <> 1) And (MDI!menu_trace(8).Checked <> MDI!menu_trace(9).Checked) Then
		  flag = True
		  MDI!Check3D_trace(7).Value = 2
		  flag = False
	       End If
	    '   If flag = False Then
	    '      flag = True
	    '      Toggle (index)
	    '   End If
	 End If
      End If
      If index <= 7 Then
	 If Not (MDI!Check3D_trace(index).Value = MDI!menu_trace(index).Checked) Then
	    flag = True
	    MDI!Check3D_trace(index).Value = MDI!menu_trace(index).Checked
	    flag = False
	 End If
      End If
   'ProjetteLes St!Stereo, "TraceCyclo"
   ProjetteLes st!Stereo, index
   screen.MousePointer = defaut
Exit Sub
Traite_Erreurs20:
   If Erreurs(Err, "St-Graph / Toggle") Then Resume Next
End Sub

Sub TourStereo (feuille As Control)
   On Error GoTo Traite_Erreurs21:
   coté_signe = coté * Hémisphère
   feuille.Scale (-coté_signe, coté_signe)-(coté_signe, -coté_signe)
   feuille.Circle (0, 0), 1
Exit Sub
Traite_Erreurs21:
   If Erreurs(Err, "St-Graph / TourStereo") Then Resume Next
End Sub

Sub Tracage (feuille As Control)
   On Error GoTo Traite_Erreurs22:
 If Retracage_Manuel Then
   If st.Caption <> "{F9}Stéréogramme" Then
      st.Caption = "{F9}Stéréogramme"
   End If
   Exit Sub
 Else
   If st.Caption <> "Stéréogramme" Then
      st.Caption = "Stéréogramme"
   End If
 End If
   If MDI!menu_trace(1).Checked Then affTraceCyclo st!Stereo, 0: If Tracage_Progressif Then feuille.Refresh             'Refresh_Stereo
   If MDI!menu_trace(2).Checked Then affstrie st!Stereo: If Tracage_Progressif Then feuille.Refresh                     'Refresh_Stereo
   If MDI!menu_trace(3).Checked Then affPol st!Stereo: If Tracage_Progressif Then feuille.Refresh                       'Refresh_Stereo
   If MDI!menu_trace(4).Checked Then affx st!Stereo: If Tracage_Progressif Then feuille.Refresh                         'Refresh_Stereo
   If MDI!menu_trace(5).Checked Then affy st!Stereo: If Tracage_Progressif Then feuille.Refresh                         'Refresh_Stereo
   If MDI!menu_trace(6).Checked Then affz st!Stereo: If Tracage_Progressif Then feuille.Refresh                         'Refresh_Stereo
   If MDI!menu_trace(8).Checked Then affpmvtx st!Stereo: If Tracage_Progressif Then feuille.Refresh                     'Refresh_Stereo
   If MDI!menu_trace(9).Checked Then affpmvtz st!Stereo: If Tracage_Progressif Then feuille.Refresh                     'Refresh_Stereo
   If MDI!menu_trace(11).Checked Then affAuxDdroit st!Stereo, 0: If Tracage_Progressif Then feuille.Refresh             'Refresh_Stereo
   If MDI!menu_trace(10).Checked Then affFlechesDirMvtsRelBlocs st!Stereo: If Tracage_Progressif Then feuille.Refresh   'Refresh_Stereo
	       
	       'If MDI!menu_cyclo.Checked Then affTraceCyclo St!Stereo, 0
	       'If MDI!menu_strie.Checked Then affstrie St!Stereo
	       'If MDI!menu_pol.Checked Then affPol St!Stereo
	       'If MDI!menu_x.Checked Then affx St!Stereo
	       'If MDI!menu_y.Checked Then affy St!Stereo
	       'If MDI!menu_z.Checked Then affz St!Stereo
	       'If MDI!menu_pmvtx.Checked Then affpmvtx St!Stereo
	       'If MDI!menu_pmvtz.Checked Then affpmvtz St!Stereo
	       'If MDI!menu_paux.Checked Then affAuxDdroit St!Stereo, 0
	       'If MDI!menu_azstri.Checked Then affFlechesDirMvtsRelBlocs St!Stereo
Exit Sub
Traite_Erreurs22:
   If Erreurs(Err, "St-Graph / Tracage") Then Resume Next
End Sub

Sub trace (feuille As Control, tce)
   On Error GoTo Traite_Erreurs23:
   If Retracage_Manuel Then
      If st.Caption <> "{F9}Stéréogramme" Then
	 st.Caption = "{F9}Stéréogramme"
      End If
      Exit Sub
   Else
      If st.Caption <> "Stéréogramme" Then
	 st.Caption = "Stéréogramme"
      End If
   End If
		     'Select Case UCase$(tce$)
		     '   Case "TRACECYCLO": affTraceCyclo St!Stereo, 0
		     '   Case "STRIES": affstrie St!Stereo
		     '   Case "POLAIRE": affPol St!Stereo
		     '   Case "AXEX": affx St!Stereo
		     '   Case "AXEY": affy St!Stereo
		     '   Case "AXEZ": affz St!Stereo
		     '   Case "PMVTXS": affpmvtx St!Stereo
		     '   Case "PMVTZS": affpmvtz St!Stereo
		     '   Case "AUXDDROIT": affAuxDdroit St!Stereo, 0
		     '   Case "FLECHESDIRMVTSRELBLOCS": affFlechesDirMvtsRelBlocs St!Stereo
		     '   Case Else
		     'End Select
   Select Case tce
      Case 1: affTraceCyclo feuille, 0
      Case 2: affstrie feuille
      Case 3: affPol feuille
      Case 4: affx feuille
      Case 5: affy feuille
      Case 6: affz feuille
      Case 7: affpmvtx feuille: affpmvtz feuille
      Case 8: affpmvtx feuille
      Case 9: affpmvtz feuille
      Case 11: affAuxDdroit feuille, 0
      Case 10: affFlechesDirMvtsRelBlocs feuille
      Case Else
   End Select

   'stereogramme.SetFocus
Exit Sub
Traite_Erreurs23:
   If Erreurs(Err, "St-Graph / trace") Then Resume Next
End Sub

Sub tracefleche (feuille As Control, azimut, compext$, couleur&, taille)
   On Error GoTo Traite_Erreurs24:
   tmp = feuille.DrawWidth
    d1 = 1.05: d2 = 1.1: d3 = 1.075: d4 = 1.075
   If taille = 2 Then
    d1 = 1.05: d2 = 1.19: d3 = 1.1: d4 = 1.1
    feuille.DrawWidth = taille
   End If
   feuille.Line (d1 * Sin(azimut), d1 * Cos(azimut))-(d2 * Sin(azimut), d2 * Cos(azimut)), couleur&
   feuille.Line (-d1 * Sin(azimut), -d1 * Cos(azimut))-(-d2 * Sin(azimut), -d2 * Cos(azimut)), couleur&
      Select Case compext$
	 Case "distension"
	    feuille.Line (d2 * Sin(azimut), d2 * Cos(azimut))-(d4 * Sin(azimut + 2 * pi / 180), d4 * Cos(azimut + 2 * pi / 180)), couleur&
	    feuille.Line (d2 * Sin(azimut), d2 * Cos(azimut))-(d4 * Sin(azimut - 2 * pi / 180), d4 * Cos(azimut - 2 * pi / 180)), couleur&
	    feuille.Line (-d2 * Sin(azimut), -d2 * Cos(azimut))-(-d4 * Sin(azimut + 2 * pi / 180), -d4 * Cos(azimut + 2 * pi / 180)), couleur&
	    feuille.Line (-d2 * Sin(azimut), -d2 * Cos(azimut))-(-d4 * Sin(azimut - 2 * pi / 180), -d4 * Cos(azimut - 2 * pi / 180)), couleur&
	 Case "compression"
	    feuille.Line (d1 * Sin(azimut), d1 * Cos(azimut))-(d3 * Sin(azimut + 2 * pi / 180), d3 * Cos(azimut + 2 * pi / 180)), couleur&
	    feuille.Line (d1 * Sin(azimut), d1 * Cos(azimut))-(d3 * Sin(azimut - 2 * pi / 180), d3 * Cos(azimut - 2 * pi / 180)), couleur&
	    feuille.Line (-d1 * Sin(azimut), -d1 * Cos(azimut))-(-d3 * Sin(azimut + 2 * pi / 180), -d3 * Cos(azimut + 2 * pi / 180)), couleur&
	    feuille.Line (-d1 * Sin(azimut), -d1 * Cos(azimut))-(-d3 * Sin(azimut - 2 * pi / 180), -d3 * Cos(azimut - 2 * pi / 180)), couleur&
	 Case Else
      End Select
   feuille.DrawWidth = tmp
Exit Sub
Traite_Erreurs24:
   If Erreurs(Err, "St-Graph / tracefleche") Then Resume Next
End Sub

Sub TraceRectangle (onoff%, objet As Control, ByVal xdebut, ByVal ydebut, ByVal x, ByVal y, ByVal xdernier, ByVal ydernier)
   On Error GoTo Traite_Erreurs25:
   ligne = 2
   Select Case ligne
      Case 1 'on trace rectangle par méthode line
	 Select Case onoff%
	    Case 1
	       'bougé
	       tmp = objet.DrawMode
	       
	       objet.DrawMode = 10
	      ' Stereo.DrawStyle = 3
		  objet.Line (xdebut, ydebut)-(xdernier, ydernier), rouge, B
		  objet.Line (xdebut, ydebut)-(x, y), rouge, B
	       objet.DrawMode = tmp
	     '  Stereo.DrawStyle = 0
	       'EtiquetteInfo.Caption = ""
	       'EtiquetteInfo.AutoSize = False
	    Case Else 'off
	       objet.DrawMode = 10
		  objet.Line (xdebut, ydebut)-(xdernier, ydernier), rouge, B
	       objet.DrawMode = 13
	    End Select
	 Case Else 'on trace par objet; c'est +élégant, mais ça marche pas
	    Select Case onoff%
	       Case 1
		  Redim_in_Stereo st!rectangle, st!Stereo, Min(xdebut, x), Max(ydebut, y), Abs(xdebut - x), Abs(y - ydebut)
			'Debug.Print min(xdebut, x), max(ydebut, y), Abs(xdebut - x), Abs(y - ydebut)
			'Debug.Print st!rectangle.Left, st!rectangle.Top
		  'st!rectangle.Left = min(xdebut, x)
		  'st!rectangle.Height = Abs(y - ydebut)
		  'st!rectangle.Top = max(ydebut, y)
		  'st!rectangle.Width = Abs(xdebut - x)
		  'aa = Abs(ydebut - y)
		  'If aa > .5 Then st!rectangle.Height = aa
		  'Debug.Print st!rectangle.Height, Abs(y - ydebut)
		  'If aa > 1 Then Stop
		  st!rectangle.Visible = True
	       Case Else
		  st!rectangle.Visible = False
	       End Select
	 End Select
Exit Sub
Traite_Erreurs25:
   If Erreurs(Err, "St-Graph / TraceRectangle") Then Resume Next
End Sub

Sub TraceStereoVierge (feuille As Control)
   On Error GoTo Traite_Erreurs26:
    feuille.Cls
    If feuille Is st!Stereo Then st!Stereo.Picture = st!bmp.Image
   
   '!!!Effet de relief au bord
   'feuille.Line (feuille.left + shift, feuille.top + shift)-(feuille.left + feuille.width + shift, feuille.top + feuille.height + shift), b
   TourStereo feuille'st!Stereo
    MsgWulff$ = "Wulff "
    If Hémisphère = 1 Then
     MsgWulff$ = MsgWulff$ + "Sup."
    Else
     MsgWulff$ = MsgWulff$ + "Inf."
    End If
    feuille.CurrentY = coté * Hémisphère
    feuille.CurrentX = -1 * Hémisphère
    feuille.Print MsgWulff$
'      x = (coté - .25) * Hémisphère
'      y = -.7 * Hémisphère
'      rayon = .1
'      feuille.Circle (x, y), rayon, , 5.5, 4.2
	   ' (x -rayon*cos(pi/4),y -rayon*cos(pi/4))-(x-rayon, y -rayon*cos(pi/4))
	   ' (x +rayon*cos(pi/4),y -rayon*cos(pi/4))-(x+rayon, y -rayon*cos(pi/4))
    
   feuille.CurrentY = (1.1 + feuille.TextHeight("N") * .75) * Hémisphère
   feuille.CurrentX = 0 - feuille.TextWidth("N") * .4 * Hémisphère
   feuille.Print "N"
 POT = .03'333333333333  '1 / 30
 feuille.Line (-POT, 0)-(POT, 0)
 feuille.Line (0, POT)-(0, -POT)
 tmp = 1.1
 feuille.Line (0, 1)-(tmp * 0, tmp * 1)
 feuille.Line (1, 0)-(tmp * 1, tmp * 0)
 feuille.Line (0, -1)-(tmp * 0, tmp * (-1))
 feuille.Line (-1, 0)-(tmp * (-1), tmp * 0)
Exit Sub
Traite_Erreurs26:
   If Erreurs(Err, "St-Graph / TraceStereoVierge") Then Resume Next
End Sub

