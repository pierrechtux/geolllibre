VERSION 2.00
Begin Form frmStation 
   ClientHeight    =   3915
   ClientLeft      =   690
   ClientTop       =   1455
   ClientWidth     =   5010
   ClipControls    =   0   'False
   Height          =   4320
   Icon            =   STATION.FRX:0000
   Left            =   630
   LinkTopic       =   "Feuille1"
   MDIChild        =   -1  'True
   ScaleHeight     =   3915
   ScaleWidth      =   5010
   Top             =   1110
   Width           =   5130
   Begin CommandButton CommandeAnnule 
      Cancel          =   -1  'True
      Caption         =   "x"
      FontBold        =   -1  'True
      FontItalic      =   -1  'True
      FontName        =   "Arial"
      FontSize        =   12
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   285
      Left            =   1560
      TabIndex        =   6
      Top             =   0
      Width           =   225
   End
   Begin CommandButton CommandeOk 
      Caption         =   "V"
      Default         =   -1  'True
      FontBold        =   -1  'True
      FontItalic      =   -1  'True
      FontName        =   "Arial"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   285
      Left            =   1770
      TabIndex        =   5
      Top             =   0
      Width           =   225
   End
   Begin TextBox Texte2 
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   405
      Left            =   1665
      TabIndex        =   2
      Top             =   3120
      Width           =   3150
   End
   Begin TextBox Texte1 
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   315
      Left            =   1980
      MousePointer    =   3  'I-Beam
      TabIndex        =   1
      Top             =   0
      Width           =   2910
   End
   Begin Grid Grille 
      Cols            =   9
      DragIcon        =   STATION.FRX:0302
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   2655
      Left            =   0
      TabIndex        =   0
      Top             =   480
      Width           =   4815
   End
   Begin Image cancelle 
      Height          =   480
      Left            =   1980
      Picture         =   STATION.FRX:0604
      Top             =   3285
      Visible         =   0   'False
      Width           =   480
   End
   Begin Label Etiquette2 
      Alignment       =   2  'Center
      Caption         =   "Commentaire du site:"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   390
      Left            =   0
      TabIndex        =   4
      Top             =   3120
      Width           =   1710
   End
   Begin Label Etiquette1 
      Alignment       =   2  'Center
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   240
      Left            =   0
      TabIndex        =   3
      Top             =   0
      Width           =   1575
   End
End
Sub CommandeAnnule_Click ()
      grille_click
      Grille.SetFocus
   CommandeOk.Enabled = False
   CommandeAnnule.Enabled = False
End Sub

Sub CommandeAnnule_GotFocus ()
   CommandeOk.Enabled = True
   CommandeAnnule.Enabled = True
End Sub

Sub CommandeOk_click ()
   On Error GoTo Traite_Erreurs1:
   ns = Me.Tag
   i = Grille.Row
      If Grille.Row > Site(ns).NbMes Then Exit Sub
      If Grille.Col < 7 Then Texte1.Text = UCase$(Texte1.Text)
      If Grille.Text = Texte1.Text Then
	 CommandeOk.Enabled = False
	 CommandeAnnule.Enabled = False
	 Grille.SetFocus
	 Exit Sub
      End If
      AuCasOu$ = Grille.Text
      Grille.Text = Texte1.Text
      screen.MousePointer = 11
	 If Grille.Col = 8 Then
	    Select Case Grille.Text   'keycode    '??
	       Case Chr$(96) To Chr$(96 + nbgroupesdetri)  '**sélectionner mesures en a,b,...
		  SélectionMesure (Asc(Grille.Text) - 96)
	       Case "*"
		  SélectionMesure (0)
	       Case " ", ""
		  SélectionMesure (-1)
		  Grille.Text = ""
	       Case Else
		  Grille.Text = AuCasOu$
	    End Select
	 End If
	 If Grille.Col < 7 Then
	       'Traquage des erreurs d'entrée: ancienne solution:
	      ' Select Case Grille.Col
	      '    Case 1
	      '       azitmp = Val(Grille.Text)
	      '       If azitmp < 0 Or azitmp > 180 Then erreur = True
	      '    Case 2
	      '       pdtmp = Val(Grille.Text)
	      '       If pdtmp < 0 Or pdtmp > 90 Then erreur = True
	      '    Case 3
	      '          colonne = Grille.Col
	      '          Flag = True
	      '          Grille.Col = 1
	      '          azitmp = Val(Grille.Text)
	      '          Grille.Col = colonne
	      '          Flag = False
	      '       dirpdtmp = Grille.Text
	      '       If UCase$(dirpdtmp) <> "W" And UCase$(dirpdtmp) <> "E" And UCase$(dirpdtmp) <> "N" And UCase$(dirpdtmp) <> "S" Then erreur = True
	      '       'azitmp = Site(ns).Faille(i).azi
	      '       If (azitmp < 45 Or azitmp > 135) And (UCase$(dirpdtmp) = "N" Or UCase$(dirpdtmp) = "S") Then erreur = True
	      '       If (azitmp > 45 And azitmp < 135) And (UCase$(dirpdtmp) = "W" Or UCase$(dirpdtmp) = "E") Then erreur = True
	      '    Case 4
	      '       pitchtmp = Val(Grille.Text)
	      '       If pitchtmp < 0 Or pitchtmp > 90 Then erreur = True
	      '    Case 5
	      '       dirpitmp = Grille.Text
	      '       If UCase$(dirpitmp) <> "W" And UCase$(dirpitmp) <> "E" And UCase$(dirpitmp) <> "N" And UCase$(dirpitmp) <> "S" Then erreur = True
	      '       'pdtmp = Site(ns).Faille(i).pd
	      '          colonne = Grille.Col
	      '          Flag = True
	      '          Grille.Col = 2
	      '          pdtmp = Val(Grille.Text)
	      '          Grille.Col = colonne
	      '          Flag = False
	      '       If (UCase$(pdtmp) = "W" Or UCase$(pdtmp) = "E") And (UCase$(dirpitmp) = "W" Or UCase$(dirpitmp) = "E") Then erreur = True
	      '       If (UCase$(pdtmp) = "N" Or UCase$(pdtmp) = "S") And (UCase$(dirpitmp) = "N" Or UCase$(dirpitmp) = "S") Then erreur = True
	      '    Case 6
	      '       jeutmp = Grille.Text
	      '       If UCase$(jeutmp) <> "N" And UCase$(jeutmp) <> "I" And UCase$(jeutmp) <> "S" And UCase$(jeutmp) <> "D" Then erreur = True
	      ' End Select
	      '    If Err Or erreur Then
	      '       Beep
	      '       Err = 0
	      '       screen.MousePointer = Defaut
	      '       MsgBox "Erreur: mesure de faille non valable"
	      '       Grille.Text = AuCasOu$
	      '       grille_click
	      '       Grille.SetFocus
	      '       CommandeOk.Enabled = False
	      '       CommandeAnnule.Enabled = False
	      '       Exit Sub
	      '    End If
	       'Traquage des erreurs d'entrée: nouvelle solution:
		  colonne = Grille.Col
		  flag = True
		  Grille.Col = 1: azitmp = Grille.Text
		  Grille.Col = 2: pdtmp = Grille.Text
		  Grille.Col = 3: dirpdtmp = Grille.Text
		  Grille.Col = 4: pitchtmp = Grille.Text
		  Grille.Col = 5: dirpitmp = Grille.Text
		  Grille.Col = 6: jeutmp = Grille.Text
		  Grille.Col = colonne
		  flag = False
	       rien = Checke_Mesure(azitmp, pdtmp, dirpdtmp, pitchtmp, dirpitmp, jeutmp)
	       If rien = False Then
		  cr$ = Chr$(13) + Chr$(10)
		  TheMessage$ = "Edition de la mesure au formulaire?"
		  'TheMessage$ = "Mesure de faille modifiée:" + cr$
		  '+ Str$(azitmp) + Str$(pdtmp) + Str$(dirpdtmp) + Str$(pitchtmp) + Str$(dirpitmp) + jeutmp + cr$
		  'TheMessage$ = TheMessage$ + Site(ns).Faille(i).mesure
		  'TheMessage$ = TheMessage$ + "incorrecte:" + cr$
		  'TheMessage$ = TheMessage$ + "corriger?" + cr$
		  TheStyle = 33
		  TheAnswer = MsgBox(TheMessage$, TheStyle)
		     If TheAnswer = 1 Then  'Answered OK
			Saisie_Mesure.suivante.Enabled = False
			Saisie_Mesure.precedente.Enabled = False
			Saisie_Mesure.annule.Enabled = False
			   Saisie_Mesure.Show 1
			Saisie_Mesure.suivante.Enabled = True
			Saisie_Mesure.precedente.Enabled = True
			Saisie_Mesure.annule.Enabled = True
			MetàJourStation
			MetàJourListeGroupe
			RedessinStereo st!Stereo
			GoTo fin:
		     Else     'Answered Cancel
			Grille.Text = AuCasOu$
			grille_click
			Grille.SetFocus
			CommandeOk.Enabled = False
			CommandeAnnule.Enabled = False
			screen.MousePointer = defaut
			Exit Sub
		     End If
	       End If
	    Site(ns).Faille(i).azi = azitmp
	    Site(ns).Faille(i).Pd = pdtmp
	    Site(ns).Faille(i).DirPd = dirpdtmp
	    Site(ns).Faille(i).pitch = pitchtmp
	    Site(ns).Faille(i).dirpi = dirpitmp
	    Site(ns).Faille(i).jeu = jeutmp
	       If 1 <= Grille.Col And Grille.Col <= 6 Then
		  CalculeParametresMesure'recalcul
	       End If
	 ElseIf Grille.Col = 7 Then
	    Site(ns).Faille(i).Commentaire = Grille.Text
	 End If

fin:
	    grille_click'
	    Grille.SetFocus
	    AfficheListeGroupes
	       If 1 <= Grille.Col And Grille.Col <= 6 Then
		  RedessinStereo st!Stereo
	       End If
      Site(Me.Tag).dirty = True
      screen.MousePointer = defaut
   CommandeOk.Enabled = False
   CommandeAnnule.Enabled = False
Exit Sub
Traite_Erreurs1:
   If Erreurs(Err, "Saisie_Mesure / CommandeOk_click") Then Resume Next
End Sub

Sub CommandeOk_GotFocus ()
   CommandeOk.Enabled = True
   CommandeAnnule.Enabled = True
End Sub

Sub Etiquette1_Click ()
   CommandeOk.Enabled = False
   CommandeAnnule.Enabled = False
End Sub

Sub Etiquette2_Click ()
   CommandeOk.Enabled = False
   CommandeAnnule.Enabled = False
End Sub

Sub Form_Activate ()
   ns = Me.Tag
End Sub

Sub Form_Click ()
   CommandeOk.Enabled = False
   CommandeAnnule.Enabled = False
End Sub

Sub Form_Load ()
   On Error GoTo Traite_Erreurs2:
   If Tag = "" Then Tag = ns'tag en train de se définir
      'If flag = flag_chargement Then
	 'f = "tectri.ini"
	 'gauche = getprivateprofileint("Fenêtres", "Données: left", 0, f)
	 'haut = getprivateprofileint("Fenêtres", "Données: top", 0, f)
	 'hauteur = getprivateprofileint("Fenêtres", "Données: height", 0, f)
	 'largeur = getprivateprofileint("Fenêtres", "Données: width", 0, f)
	 'largeur = 5355
	 'hauteur = 4530
	 'If gauche <> 0 Then Left = gauche
	 'If haut <> 0 Then Top = haut
	 'If hauteur <> 0 Then Height = hauteur
	 'If largeur <> 0 Then Width = largeur
      'Else
	 'Left = frm_Station(ns - 1).Left + 330
	 'Top = frm_Station(ns - 1).Top + 330
	 '   If frm_Station(ns - 1).WindowState <> reduit Then
	 '      Height = frm_Station(ns - 1).Height
	 '      Width = frm_Station(ns - 1).Width
	 '   Else
	 '      f = "tectri.ini"
	 '      hauteur = getprivateprofileint("Fenêtres", "Données: height", 0, f)
	 '      largeur = getprivateprofileint("Fenêtres", "Données: width", 0, f)
	 '      If hauteur <> 0 Then Height = hauteur
	 '      If largeur <> 0 Then Width = largeur
	 '   End If
      'End If
      Height = 4530
      Width = 5355
      If Site(ns).NbMes = 0 And Site(ns).NomFichier = "" Then 'ns = 1 And NbStations = 1 And
	 Site(ns).NomFichier = "(sans-titre :" & ns & ")"
	 Caption = LCase$(Site(ns).NomFichier)
	 Site(ns).dirty = False
      End If
      LoadTitles
      'Form_Resize
      Grille.Col = 1
      Grille.Row = 1
      Grille.SelStartRow = 1
      Grille.SelEndRow = 1
      Grille.SelStartCol = 1
      Grille.SelEndCol = 1
Exit Sub
Traite_Erreurs2:
   If Erreurs(Err, "Saisie_Mesure / Form_Load") Then Resume Next
End Sub

Sub Form_QueryUnload (cancel As Integer, unloadmode As Integer)
   On Error GoTo Traite_Erreurs3:
    ns = Me.Tag
    Response = QuestionFermeStation(ns)
	 Select Case Response
	    Case 6'Oui:Fichier Enregistrer
	       '!!!*** Appelle la procédure Enregistrer.
	       EnregistreLaStation (ns)
	       '!!! Si l'utilisateur a sélectionné le bouton Annuler dans la boîte de
	       ' dialogue Enregistrer sous (non pas dans la boîte de message), la zone de texte
	       ' Nom de fichier reste vide et le déchargement doit être annulé.
	       If flag = True Then
		     flag = False
		     cancel = True
	       End If
	    Case 7'non:décharger/fermer
	       cancel = False
	    Case 2'Annule
	       screen.MousePointer = defaut
	       cancel = True
	       If unloadmode = 1 Then flag = flag_cancel
	 End Select
Exit Sub
Traite_Erreurs3:
   If Erreurs(Err, "Saisie_Mesure / Form_QueryUnload") Then Resume Next
End Sub

Sub Form_Resize ()
   On Error GoTo Traite_Erreurs4:
Static oldWindowState
      If WindowState = reduit Then
	    '*** chgt icone form when not displayed
	    'If Affich_F_Stations_Icones = False Then
	    '   icon=nonaff.icon
	    'Else
	    '   icon=normal.icon
	    'End If
	 MetàJourListeGroupe
	 F9
      End If
   If WindowState <> reduit And oldWindowState = reduit Then MetàJourListeGroupe: F9
   oldWindowState = WindowState
   If Not (visible) Or (WindowState <> normal And WindowState <> agrandi) Then Exit Sub
   If scaleheight = 0 Then Exit Sub
   Grille.Width = ScaleWidth
   Grille.Height = MAX(1, scaleheight - Texte1.Height - etiquette2.Height)
   Grille.Top = Texte1.Height + Texte1.Top
   Texte1.Width = MAX(ScaleWidth - Texte1.Left, 1)
   Texte2.Width = MAX(ScaleWidth - Texte2.Left, 1)
   Texte2.Top = Grille.Top + Grille.Height
   etiquette2.Top = Texte2.Top
      
      'ce qui suit sert à adapter la largeur des colonnes à la taille de la fenêtre,
      'en élargissant la colonne des commentaires
      largeurcolonnes = 0
	 For k = 0 To Grille.Cols - 1
	    largeurcolonnes = largeurcolonnes + Grille.ColWidth(k)
	 Next
      largeurcolonnes = MAX(1, largeurcolonnes - Grille.ColWidth(7))'largeur cumulée des autres colonnes que celle des commentaires
'      Grille.ColWidth(7) = MIN(10 * 120, Me.ScaleWidth - largeurcolonnes + Grille.ColWidth(7))
      Grille.ColWidth(7) = -3.5 * 120 + MAX(10 * 120, Grille.Width - largeurcolonnes)
Exit Sub
Traite_Erreurs4:
   If Erreurs(Err, "Saisie_Mesure / Form_Resize") Then Resume Next
End Sub

Sub Form_Unload (cancel As Integer)
   On Error GoTo Traite_Erreurs5:
   '***Fermeture de la station
   screen.MousePointer = 11
   prompt "Fermeture de la station " + Site(ns).NomFichier
   Site(ns).NomFichier = ""
   Site(ns).NbMes = 0
      If NbStations - 1 <= 0 And flag <> flag_quitter Then
	 NbStations = 1
	 ReDim Site(MAX(NbStations, 2)) '(nsmax)
	 ReDim frm_Station(MAX(NbStations, 2))
      End If
   If ns = NbStations Then NbStations = MAX(1, NbStations - 1)
   If flag = flag_quitter Then Exit Sub
   Site(ns).deleted = True
   DimensionneVariables
   DimensionneObjets
   ns = 1
   i = 1
   MetàJourListeGroupe
   RedessinStereo st!Stereo
   screen.MousePointer = defaut
   prompt ""
Exit Sub
Traite_Erreurs5:
   If Erreurs(Err, "Saisie_Mesure / Form_Unload") Then Resume Next
End Sub

Sub grille_click ()
   On Error GoTo Traite_Erreurs6:
   ns = Me.Tag
   rien = Grille.Row
   i = Min(rien, Site(ns).NbMes + 1)
      flag = True
	 Grille.Row = 0
	 etiquette1.Caption = Str$(i) + " " + Grille.Text + " :"
	 Grille.Row = i
      flag = False
   Texte1.Text = Grille.Text
   CommandeOk.Enabled = False
   CommandeAnnule.Enabled = False
Exit Sub
Traite_Erreurs6:
   If Erreurs(Err, "Saisie_Mesure / grille_click") Then Resume Next
End Sub

Sub grille_Dblclick ()
   On Error GoTo Traite_Erreurs7:
      If Grille.Row > Site(ns).NbMes Then
	    TheMessage$ = "Entrée de nouvelle(s) mesure(s) de faille(s)?"
	    TheStyle = 33
	    TheTitle$ = "Tectri"
	    TheAnswer = MsgBox(TheMessage$, TheStyle, TheTitle$)
	       If TheAnswer = 1 Then  'Answered OK
		  i = Grille.Row
		  EntreeMesures
		  RedessinStereo st!Stereo
		  Exit Sub
	       Else     'Answered Cancel
		  Exit Sub
	       End If
      End If
   
   'If grille.Col = 8 Then selec (13): Exit Sub
   Texte1.Text = Grille.Text
   Texte1.SelStart = 0
   Texte1.SelLength = Len(Texte1.Text)
   Texte1.SetFocus
Exit Sub
Traite_Erreurs7:
   If Erreurs(Err, "Saisie_Mesure / grille_Dblclick") Then Resume Next
End Sub

Sub Grille_DragOver (Source As Control, x As Single, y As Single, State As Integer)
   'Source.DragIcon = cancelle.Picture
   prompt "Tri des failles : annulation"
End Sub

Sub Grille_GotFocus ()
   CommandeOk.Enabled = False
   CommandeAnnule.Enabled = False
End Sub

Sub grille_KeyDown (KeyCode As Integer, Shift As Integer)
   On Error GoTo Traite_Erreurs8:
   Select Case KeyCode
      Case &H71'TOUCHE_F2
	 grille_Dblclick
      Case 84
	 If Shift And Ctrl_Mask Then
	    Call Grille_MouseDown(1, 2, 0, 0)
	 End If
      Case &H2D'TOUCHE_INS
	 If Shift And Ctrl_Mask Then
	    CopieRange
	 ElseIf Shift And Shift_Mask Then
	    ColleRange
	 End If
      Case 67'c
	 If Shift And Ctrl_Mask Then
	    CopieRange
	 End If
      Case 86'v
	 If Shift And Ctrl_Mask Then
	    ColleRange
	 End If
      Case Else
      'Case 48 To 57, 65 To 90
      '   Texte1.SetFocus
      '   Texte1.Text = Chr$(KeyCode)
      '   Texte1.SelStart = Len(Texte1.Text)
   End Select
   Select Case KeyCode
      Case 65 To 64 + nbgroupesdetri, 32, 13, &H8, &HC, 46'TOUCHE_RETARR, TOUCHE_EFFACER, 46
	 If Shift Then Exit Sub
	 selecfailles Me, KeyCode
	 grille_click
      Case Else
   End Select
Exit Sub
Traite_Erreurs8:
   If Erreurs(Err, "Saisie_Mesure / grille_KeyDown") Then Resume Next
End Sub

Sub Grille_MouseDown (Button As Integer, Shift As Integer, x As Single, y As Single)
   On Error GoTo Traite_Erreurs9:
      If ((Button And 1) And (Shift = 2)) Or Button And 2 Then
	 '*** code déplacé dans  Minuterie_Timer **
	 'Ctrl+clic: on "drag" la cellule vers les tris...
	 Grille.Tag = ""
	    iavant = i
	       For i = Grille.SelStartRow To Min(Int(Grille.SelEndRow), Grille.Rows - 2)'Site(ns).NbMes
		  Grille.Tag = Grille.Tag + Str$(ns) + Chr$(9) + Str$(i) + Chr$(10)
	       Next
	    i = iavant
	 Grille.Drag
	 'Grille.Tag = ""
      Else
	 'grille_click
	 MDI!Minuterie.Enabled = False
	 MDI!Minuterie.Interval = 200
	 MDI!Minuterie.Enabled = True
	 xold = x
	 yold = y
      End If
Exit Sub
Traite_Erreurs9:
   If Erreurs(Err, "Saisie_Mesure / Grille_MouseDown") Then Resume Next
End Sub

Sub Grille_MouseMove (Button As Integer, Shift As Integer, x As Single, y As Single)
   If MDI!Minuterie.Interval = 200 And y <> yold And x <> xold Then 'bougé avec bouton enfonçé alors que timer non écoulé
      MDI!Minuterie.Interval = 10000

   'End If
   ElseIf (Button And 1) And (Shift = 2) Then
      Call Grille_MouseDown(Button, Shift, x, y)
   Else
      prompt "Tri : Ctrl-T, Ctrl-drag&&drop, drag bouton droit, ou lettre de groupe.   Editer : F2 ou dbl-clic"
   End If
End Sub

Sub Grille_MouseUp (Button As Integer, Shift As Integer, x As Single, y As Single)
   xold = -1
   yold = -1
   If MDI!Minuterie.Interval = 200 Then MDI!Minuterie.Interval = 10000
End Sub

Sub grille_RowColChange ()
   On Error Resume Next
   '***intérêt??? disablé pour le moment...et remis, pour afficher le contenu de la cellule dans la zone de texte.
   If flag = True Then Exit Sub
   'If (Grille.SelStartRow < Grille.Row < Grille.SelEndRow) And (Grille.SelStartCol < Grille.Col < Grille.SelEndCol) Then Exit Sub
      'flagi = flag
      'flag = True
      'newSelStartRow = Grille.SelStartRow
      'newRow = Grille.Row
      'newSelEndRow = Grille.SelEndRow
      'newSelStartCol = Grille.SelStartCol
      'newCol = Grille.Col
      'newSelEndCol = Grille.SelEndCol
      'flag = flagi
   grille_click
End Sub

Sub Grille_SelChange ()
   'On Error Resume Next
   'If (Grille.SelStartRow < Grille.Row < Grille.SelEndRow) And (Grille.SelStartCol < Grille.Col < Grille.SelEndCol) Then
   '    Grille.SelStartRow = newSelStartRow
   '    Grille.Row = newRow
   '    Grille.SelEndRow = newSelEndRow
   '    Grille.SelStartCol = newSelStartCol
   '    Grille.Col = newCol
   '    Grille.SelEndCol = newSelEndCol
   'End If
End Sub

Sub Texte1_GotFocus ()
   prompt "Modification de la mesure"
   CommandeOk.Enabled = True
   CommandeAnnule.Enabled = True
End Sub

Sub Texte1_KeyDown (KeyCode As Integer, Shift As Integer)
   Select Case KeyCode
      Case TOUCHE_HAUT, TOUCHE_BAS 'TOUCHE_DROITE, TOUCHE_GAUCHE
	 CommandeOk_click
	 Call grille_KeyDown(KeyCode, Shift)
      Case Else
   End Select
End Sub

Sub Texte1_LostFocus ()
   prompt ""
'   if         not(CommandeOk.activecontrol or CommandeAnnuler.activecontrol  )then
      'CommandeOk.ENABLED = False
      'CommandeAnnule.ENABLED = False
  ' End If
End Sub

Sub Texte2_Change ()
   CommandeOk.Enabled = False
   CommandeAnnule.Enabled = False
      If flag <> True Then
	 Site(ns).Situation = Texte2.Text
	 If Site(ns).dirty <> True Then Site(ns).dirty = True
	 ns = Me.Tag
      End If
End Sub

