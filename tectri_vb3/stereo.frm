VERSION 2.00
Begin Form st 
   Caption         =   "Stéréogramme"
   ClientHeight    =   2955
   ClientLeft      =   825
   ClientTop       =   1785
   ClientWidth     =   4635
   FontBold        =   0   'False
   FontItalic      =   0   'False
   FontName        =   "MS Sans Serif"
   FontSize        =   8.25
   FontStrikethru  =   0   'False
   FontUnderline   =   0   'False
   Height          =   3360
   Icon            =   STEREO.FRX:0000
   Left            =   765
   LinkTopic       =   "Feuille1"
   MDIChild        =   -1  'True
   ScaleHeight     =   2955
   ScaleWidth      =   4635
   Top             =   1440
   Width           =   4755
   Begin PictureBox Stereo 
      AutoRedraw      =   -1  'True
      BackColor       =   &H00FFFFFF&
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "Arial"
      FontSize        =   9.75
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   2955
      Left            =   0
      MousePointer    =   2  'Cross
      ScaleHeight     =   2.261
      ScaleLeft       =   -1.4
      ScaleMode       =   0  'User
      ScaleTop        =   1.4
      ScaleWidth      =   1.835
      TabIndex        =   0
      Top             =   0
      Width           =   2955
      Begin Shape rectangle 
         BorderColor     =   &H000000FF&
         FillColor       =   &H00C0C0FF&
         Height          =   1065
         Left            =   630
         Top             =   840
         Visible         =   0   'False
         Width           =   1170
      End
      Begin Label EtiquetteInfo 
         AutoSize        =   -1  'True
         BorderStyle     =   1  'Fixed Single
         DragIcon        =   STEREO.FRX:0302
         Height          =   225
         Left            =   90
         MousePointer    =   1  'Arrow
         TabIndex        =   2
         Top             =   0
         Visible         =   0   'False
         Width           =   1290
         WordWrap        =   -1  'True
      End
   End
   Begin PictureBox bmp 
      AutoRedraw      =   -1  'True
      Enabled         =   0   'False
      Height          =   3015
      Left            =   3255
      MousePointer    =   1  'Arrow
      ScaleHeight     =   2.307
      ScaleLeft       =   -1.4
      ScaleMode       =   0  'User
      ScaleTop        =   1.4
      ScaleWidth      =   1.873
      TabIndex        =   1
      Top             =   0
      Visible         =   0   'False
      Width           =   3015
   End
   Begin Image bmp_image 
      Height          =   2580
      Left            =   2730
      Picture         =   STEREO.FRX:0604
      Stretch         =   -1  'True
      Top             =   0
      Visible         =   0   'False
      Width           =   3195
   End
End
Dim focus
Dim xdebut, ydebut, xdernier, ydernier, X, Y

Sub EtiquetteInfo_Click ()
   If EtiquetteInfo.Visible Then EtiquetteInfo.Visible = False
End Sub

Sub EtiquetteInfo_DblClick ()
   EtiquetteInfo_Click
End Sub

Sub EtiquetteInfo_DragDrop (source As Control, X As Single, Y As Single)
   If source Is EtiquetteInfo Then EtiquetteInfo_Click
End Sub

Sub EtiquetteInfo_MouseDown (Button As Integer, Shift As Integer, X As Single, Y As Single)
	 'DragIcon = Grouptri.Icon
	 EtiquetteInfo.Drag
	 prompt "Drag && drop vers un groupe de tri pour trier la(les) faille(s)"
End Sub

Sub EtiquetteInfo_MouseMove (Button As Integer, Shift As Integer, X As Single, Y As Single)
   prompt "Drag && drop vers un groupe de tri pour trier la(les) faille(s), clic pour effacer " ' & EtiquetteInfo.Tag
End Sub

Sub EtiquetteInfo_MouseUp (Button As Integer, Shift As Integer, X As Single, Y As Single)
   EtiquetteInfo_DblClick
End Sub

Sub Form_KeyDown (KeyCode As Integer, Shift As Integer)
   On Error GoTo Traite_Erreurs1:
   If KeyCode = &H2D And (Shift And 2) Then  'Ctrl+Ins
      'copie stéréo ds le clipboard
      CopieStereo
   ElseIf KeyCode = &H2D And (Shift And 1) Then 'Shift+Ins
      'colle clipboard sur le stéréo
      ColleStereo
   ElseIf EtiquetteInfo.Visible Then
	 If Shift Then Exit Sub
	 Select Case KeyCode
	    Case 65 To 64 + nbgroupesdetri
	       DropFaille KeyCode - 64, EtiquetteInfo
	       'selecfailles Me, keycode
	    Case 13 '*
	       DropFaille 0, EtiquetteInfo
	    Case &H8, &HC 'TOUCHE_RETARR, TOUCHE_EFFACER, 46 **46???**
	       DropFaille -1, EtiquetteInfo
	    Case Else
	 End Select
   End If
Exit Sub
Traite_Erreurs1:
   If Erreurs(Err, "Stéréo / Form_KeyDown") Then Resume Next
End Sub

Sub Form_Load ()
   On Error GoTo Traite_Erreurs2:
     'If flag = flag_chargement Then Exit Sub
     temp1 = flag
     chg_diam_stereo
     flag = False
     keypreview = True
     Stereo.Tag = "stéréo"
     Me.Tag = "stéréo"
     flag = temp1
Exit Sub
Traite_Erreurs2:
   If Erreurs(Err, "Stéréo / Form_Load") Then Resume Next
End Sub

Sub Form_QueryUnload (Cancel As Integer, unloadmode As Integer)
   If unloadmode <> 1 Then Cancel = True
End Sub

Sub Form_Resize ()
   On Error GoTo Traite_Erreurs3:
   If flag = flag_chargement Then Exit Sub 'sinon, ça rappelle 2x
   Static stereo_reduit, Diam_Tmp
   Static width_old, height_old
   'Redimension de la feuille=> redimension du stéréo
      If WindowState = REDUIT Then
	 stereo_reduit = REDUIT
	 Diam_Tmp = diamstereo
	 Exit Sub
      ElseIf stereo_reduit = REDUIT Then
	 stereo_reduit = 0
	 If Diam_Tmp = diamstereo Then Exit Sub
      End If
   If stereo_reduit = AGRANDI And WindowState <> AGRANDI Then stereo_reduit = 0: diamstereo = Diam_Tmp: GoTo change:
   If flag = True Then flag = False: Exit Sub'pour éviter que la procédure ne s'auto-appelle aux lignes 8&9
   If WindowState = AGRANDI And stereo_reduit <> AGRANDI Then stereo_reduit = AGRANDI: Diam_Tmp = diamstereo
   ST!Stereo.Picture = LoadPicture("")
   screen.MousePointer = 11
   bordures = ST.Width - ST.ScaleWidth
      Select Case WindowState
	 Case normal
	    delta_width = Width - width_old
	    delta_height = Height - height_old
	       If Abs(delta_width) > Abs(delta_height) Then
		  ratata = Width - Int(bordures * 2)'Width - Int(bordures / 2)
	       Else
		  ratata = Height - HauteurBarreTitre - Int(bordures) 'Height - HauteurBarreTitre - Int(bordures / 2)
	       End If
	    'a = Height - HauteurBarreTitre - Int(bordures / 2)
	    'b = Width - Int(bordures / 2)
	 Case Else
	    ratata = min(Width - Int(bordures), Height - HauteurBarreTitre - Int(bordures * 2))
      End Select
      'ratata = -(windowstate = normal) * (a + b) / 2 - (windowstate <> normal) * min(a, b)  'max(a, b) 'min(a, b)
   diamstereo = ratata / (1.2 * 567)'* 15.67164179104 - 1837.5) * 10 / 525
   
change:
   'Stereo.FontName = "Arial"
   'Stereo.FontBold = False
   'Stereo.FontSize = 10 * diamstereo / 5
   'Stereo.FontName = "Arial"
   'Stereo.FontBold = False
   'Stereo.FontSize = 10 * diamstereo / 5
   If flag = flag_chargement Then Exit Sub
   chg_diam_stereo
   Redim_in_Stereo ST!bmp, ST!Stereo, ST!bmp.Left, ST!bmp.Top, Abs(ST!Stereo.ScaleWidth), Abs(ST!Stereo.ScaleHeight)
   ST!bmp.Width = ST!Stereo.Width
   ST!bmp.Height = ST!Stereo.Height
   screen.MousePointer = defaut
   width_old = Width
   height_old = Height
Exit Sub
Traite_Erreurs3:
   If Erreurs(Err, "Stéréo / Form_Resize") Then Resume Next
End Sub

Sub pointefaille (ByVal X, ByVal Y, ByVal x1, ByVal y1)
   On Error GoTo Traite_Erreurs4:
   '****Dispositif de pointage sur le stéréo
   screen.MousePointer = 11
   prompt "Pointage de failles"
   MDI!lblStatus.Refresh
      If x1 = -2 Then
	 NbFailles = 1
	 ReDim Preserve nsnsns(NbFailles)
	 ReDim Preserve iii(NbFailles)
	 prompt "Pointage d'une faille"
      Else
	 NbFailles = 0
	 prompt "Pointage de failles"
      End If
   tmp = 0: eltlineaire = 0
   EtiquetteInfo.Caption = ""
   EtiquetteInfo.Tag = ""

debut:
      If eltlineaire = 0 Then
	 For Index = 2 To 6
	    If MDI!menu_trace(Index).Checked Then tmp = tmp + 1: eltlineaire = Index'MDI!menu_strie.Caption
	 Next
			   'If MDI!menu_trace(2).Checked Then tmp = tmp + 1: eltlineaire = 1'MDI!menu_strie.Caption
			   'If MDI!menu_trace(3).Checked Then tmp = tmp + 1: eltlineaire = 2'MDI!menu_pol.Caption
			   'If MDI!menu_trace(4).Checked Then tmp = tmp + 1: eltlineaire = 3'MDI!menu_y.Caption
			   'If MDI!menu_trace(5).Checked Then tmp = tmp + 1: eltlineaire = 4'MDI!menu_y.Caption
			   'If MDI!menu_trace(6).Checked Then tmp = tmp + 1: eltlineaire = 5'MDI!menu_strie.Caption
      End If
   nblignes = tmp
      Select Case nblignes   'nombre d'éléments linéaires projetés
	 Case 0
	    ErreurPointage!msg.Caption = "Erreur : on désigne un faille par un et un seul élément linéaire qui lui est associé."
	    ErreurPointage!Etiquette2.Caption = "Projection de :"
	    flag = 0
	    ErreurPointage.Show 1
	       If flag Then
		  flag = 0
		  screen.MousePointer = defaut
		  prompt ""
		  Exit Sub' cancel
	       Else
		  GoTo debut:
	       End If
	 Case Else
	    DistanceMini = 4
	       For nsns = 1 To NbStations
		  If Not (Site(nsns).deleted) Then
		     If Not (Affich_F_Stations_Icones = False And frm_Station(nsns).WindowState = REDUIT) Then
			For ii = 1 To Site(nsns).NbMes
			   For groupe = 0 To nbgroupesdetri
			      If MDI!menu_projettegroupe(groupe).Checked And Site(nsns).Faille(ii).GroupeTri = groupe Then 'If Affichage(groupe) And Site(nsns).Faille(ii).GroupeTri = groupe Then
				 If MDI!menu_trace(2).Checked Then
				    xref = Site(nsns).Faille(ii).param.SX
				    yref = Site(nsns).Faille(ii).param.SY
				    GoSub CalculDistanceCliq
				 End If
				 If MDI!menu_trace(3).Checked Then
				    xref = Site(nsns).Faille(ii).param.PolX
				    yref = Site(nsns).Faille(ii).param.PolY
				    GoSub CalculDistanceCliq
				 End If
				 If MDI!menu_trace(4).Checked Then
				    xref = Site(nsns).Faille(ii).param.AxeXX
				    yref = Site(nsns).Faille(ii).param.AxeXY
				    GoSub CalculDistanceCliq
				 End If
				 If MDI!menu_trace(5).Checked Then
				    xref = Site(nsns).Faille(ii).param.AxeYX
				    yref = Site(nsns).Faille(ii).param.AxeYY
				    GoSub CalculDistanceCliq
				 End If
				 If MDI!menu_trace(6).Checked Then
				    xref = Site(nsns).Faille(ii).param.AxeZX
				    yref = Site(nsns).Faille(ii).param.AxeZY
				    GoSub CalculDistanceCliq
				 End If
			      End If
			   Next
			Next
		     End If
		  End If
	       Next
	 If Not (found) Then Exit Sub
	 EtiquetteInfo.Left = -(x1 * Not (x1 = -2)) - (xtrouvé * (x1 = -2))' xtrouvé'Site(ns).Faille(i).param.SX
	 EtiquetteInfo.Top = -(y1 * Not (y1 = -2)) - (ytrouvé * (y1 = -2))'ytrouvé'Site(ns).Faille(i).param.SY
	    For Faille = 1 To NbFailles
	       ns = nsnsns(Faille)
	       i = iii(Faille)
	       frm_Station(ns).Grille.HighLight = False
	       frm_Station(ns).Grille.SelEndRow = i
	       frm_Station(ns).Grille.SelStartRow = i
	       frm_Station(ns).Grille.Row = i
	       SelStartCol_i = frm_Station(ns).Grille.SelStartCol
	       SelEndCol_i = frm_Station(ns).Grille.SelEndCol
	       frm_Station(ns).Grille.SelStartCol = 1
	       frm_Station(ns).Grille.SelEndCol = 7
	       frm_Station(ns).Grille.HighLight = True
	    
	       'tmp = drawmode
	       'drawmode = noirceur'MASQUE_CRAYONAFFICHAGE
	       '  Stereo.Line (SX(ns, i), faille(ns,i).param.sy)-(x, y)
	       '     CR$ = Chr$(13) + Chr$(10)
	       '     TheMessage$ = "Pointage de la strie de la faille :" + CR$
	       '     TheMessage$ = TheMessage$ + faille(ns,i).mesure + CR$
	       '     TheStyle = 64
	       '     TheTitle$ = "Clic sur le stéréogramme"
	       '     MsgBox TheMessage$, TheStyle, TheTitle$
	       '  drawmode = NON_MASQUE_CRAYONAFFICHAGE
	       'Line (Site(ns).Faille(i).param.SX, Site(ns).Faille(i).param.SY)-(ClicX, ClicY)
	       'tmp = drawmode
	       'drawmode = XOR_Pen
		  If Len(EtiquetteInfo.Caption) Then
		     If Not (EtiquetteInfo.Caption = "(" & Str$(NbFailles) & " failles)") Then EtiquetteInfo.Caption = "(" & Str$(NbFailles) & " failles)"
		  Else
		     Mesure = frm_Station(ns).Grille.Clip
		     frm_Station(ns).Grille.SelStartCol = SelStartCol_i
		     frm_Station(ns).Grille.SelEndCol = SelEndCol_i
		     NC = Chr$(9)
			For rien = 1 To Len(Mesure)
			   If Mid$(Mesure, rien, 1) = NC Then Mid$(Mesure, rien, 1) = " "
			Next
		     EtiquetteInfo.Caption = Mesure
		  End If
	       EtiquetteInfo.Tag = EtiquetteInfo.Tag + Str$(ns) + Chr$(9) + Str$(i) + Chr$(10)
	       EtiquetteInfo.Visible = True
	       flag = flag_cede_main
	       prompt "Drag && drop vers un groupe de tri pour trier la faille"
	       'drawmode = 10
	       'Stereo.Line (xtrouvé, ytrouvé)-(x, y)
	       'drawmode = tmp
	    Next
	 EtiquetteInfo.Width = min(Abs(EtiquetteInfo.Width), Abs(Abs(ST!Stereo.ScaleWidth) / 2 - EtiquetteInfo.Left))
	 If ST.WindowState <> 2 Then
	    frm_Station(ns).ZOrder 0
	    Me.ZOrder 0
	 End If
      End Select
   Exit Sub

CalculDistanceCliq:
   If x1 = -2 Then
      'on désigne une seule faille
      DistanceCarree = (xref - X) ^ 2 + (yref - Y) ^ 2
	 'LINE (SX(nsns, ii), SY(nsns, ii))-(ClicX, ClicY)
	 If DistanceCarree < DistanceMini Then
		   DistanceMini = DistanceCarree
		   xtrouvé = xref: ytrouvé = yref
		   nsnsns(NbFailles) = nsns: iii(NbFailles) = ii
		   found = True
	 End If
   Else
      'on désigne un "rectangle de" failles
      If (xref > min(X, x1) And xref < max(X, x1)) And (yref > min(Y, y1) And yref < max(Y, y1)) Then
	 'dans le rectangle!
	    found = True
	    'Cette faille a-t'elle déjà été trouvée, par un autre élément linéaire?
	    déjà_trouvée = False
	    For N = 1 To NbFailles
	       If nsnsns(N) = nsns And iii(N) = ii Then déjà_trouvée = True: Exit For
	    Next
	 If Not (déjà_trouvée) Then
	    NbFailles = NbFailles + 1
	    ReDim Preserve nsnsns(NbFailles)
	    ReDim Preserve iii(NbFailles)
	    nsnsns(NbFailles) = nsns
	    iii(NbFailles) = ii
	    xtrouvé = X'min(x, x1)
	    ytrouvé = Y'min(y, y1)
	 End If
      End If
   End If
Return
Exit Sub
Traite_Erreurs4:
   If Erreurs(Err, "Stéréo / pointefaille") Then Resume Next
End Sub

Sub Stereo_DblClick ()
   'Effacer et retracer stéréo
   If Not (Me.MousePointer = 2) Then
      'on est sur la bordure, procéder
      CtrlF9
   End If
End Sub

Sub Stereo_DragDrop (source As Control, X As Single, Y As Single)
   On Error GoTo Traite_Erreurs5:
      If source Is EtiquetteInfo Then
	 source.Left = X
	 source.Top = Y
      ElseIf source.Parent Is GroupTri Then   'Val(source.Tag) <> 0 Then
	 On Error Resume Next
	 dum = CDbl(source.Tag)
	 If Err Then Exit Sub
	 On Error GoTo Traite_Erreurs5:
	 If source.Tag <> 0 Then
	    GroupTri!CocheProjectionGroupe(Val(source.Tag)).Value = Abs(Not (-GroupTri!CocheProjectionGroupe(Val(source.Tag)).Value))
	 End If
      'ElseIf source.Parent Is Grille Then
      End If
Exit Sub
Traite_Erreurs5:
   If Erreurs(Err, "Stéréo / Stereo_DragDrop") Then Resume Next
End Sub

Sub Stereo_DragOver (source As Control, X As Single, Y As Single, State As Integer)
   On Error Resume Next
   dum = CDbl(source.Tag)
      If Err Or dum = 0 Then
	 Exit Sub
      Else
	 msg2$ = "des failles du groupe " + symbolegroupedetri(Val(source.Tag))
	    Select Case MDI!menu_projettegroupe(Val(source.Tag)).Checked'affichage du groupe se faisant draguer depuis les groupes de tri
	       Case True
		  msg1$ = "Non affichage "
	       Case Else
		  msg1$ = "Affichage "
	    End Select
	 prompt msg1$ + msg2$
      End If
Exit Sub
Traite_Erreurs6:
   If Erreurs(Err, "Stéréo / Stereo_DragOver") Then Resume Next
End Sub

Sub Stereo_GotFocus ()
   If focus = False And flag <> flag_cede_main And EtiquetteInfo.Visible Then EtiquetteInfo_Click
   If flag = flag_cede_main Then flag = False
   'flag = True 'why?????
   focus = True
End Sub

Sub Stereo_KeyDown (KeyCode As Integer, Shift As Integer)
   Select Case KeyCode
      Case &H2D'TOUCHE_INS
	 If Shift And Ctrl_Mask Then
	    CopieStereo
	 ElseIf Shift And Shift_Mask Then
	    ColleStereo
	 End If
      Case 67'c
	 If Shift And Ctrl_Mask Then
	    CopieStereo
	 End If
      Case 86'v
	 If Shift And Ctrl_Mask Then
	    ColleStereo
	 End If
   End Select
End Sub

Sub Stereo_LostFocus ()
   focus = False
   xdebut = -2: ydebut = -2
End Sub

Sub Stereo_MouseDown (Bouton As Integer, Maj As Integer, X As Single, Y As Single)
   On Error GoTo Traite_Erreurs7:
   If EtiquetteInfo.Visible Then EtiquetteInfo.Visible = False': Exit Sub
   If focus = False Then Exit Sub'Not (MDI!ActiveForm.Tag = "stéréo")
   If EtiquetteInfo.Visible Then Exit Sub
      'début processus!
      distcentre = X ^ 2 + Y ^ 2
	 If distcentre < 1 Then
	    xdebut = X: ydebut = Y
	    xdernier = X: ydernier = Y
	 Else
	 End If
      Exit Sub
Exit Sub




'old:
   distcentre = X ^ 2 + Y ^ 2
   Select Case distcentre
      Case Is > 1'***clic dans le cadre: on refait le stéréo
	  tmp = Retracage_Manuel
	  Retracage_Manuel = False
	  RedessinStereo ST!Stereo
	  Retracage_Manuel = tmp
      Case Else
	    If NbMesuresAffichees() <> 0 Then
	       pointefaille X, Y, -2, -2
	       screen.MousePointer = defaut
	    Else
	       screen.MousePointer = default
	       Exit Sub
	    End If
   End Select
   screen.MousePointer = default
			   '********ancien test de la fonction paint
			   'msg$ = "Clic sur le stéréo à la position " + Str$(X) + Str$(Y)
			   'MsgBox msg$
			   'RedessinStereo
			   '    couleur& = St!Stereo.ForeColor
			   '    paint St!Stereo, X, Y, couleur&
			      'res% = floodfill(St!Stereo, x, y, St!Stereo.forecolor)
			   'Clic dans la fenêtre du stéréo
Exit Sub
Traite_Erreurs7:
   If Erreurs(Err, "Stéréo / Stereo_MouseDown") Then Resume Next
End Sub

Sub Stereo_MouseMove (Button As Integer, Shift As Integer, X As Single, Y As Single)
   On Error GoTo Traite_Erreurs8:
   If Button And Not (xdebut = -2 And ydebut = -2) Then
      If xdernier = X And ydernier = Y Then 'pas bougé
      Else
	    X = max(-1.2, X)
	    X = min(1.2, X)
	    Y = max(-1.2, Y)
	    Y = min(1.2, Y)
	 If Button And 1 Then
	    Call TraceRectangle(1, ST!Stereo, xdebut, ydebut, X, Y, xdernier, ydernier)
	    xdernier = X: ydernier = Y
	    Exit Sub
	 Else
	    ST!rectangle.Visible = 0
	 End If
      End If
      Exit Sub
   End If

      If Not (MDI.ActiveForm.Tag = "stéréo") Then
	 focus = False
	 ST!Stereo.MousePointer = defaut
	 prompt "Stéréogramme"
	 Exit Sub
      End If
   distcentre = X ^ 2 + Y ^ 2
   Select Case distcentre
      Case Is > 1'***cadre: on refait le stéréo
	 ST!Stereo.MousePointer = 1
	 If ST.Caption = "{F9}Stéréogramme" Then
	    prompt "Clic ou F9 pour remettre à jour le stéréo"
	 Else
	    prompt "Clic dans le cadre pour retracer le stéréo, Ctrl-clic pour effacer et retracer"
	 End If
      Case Else
	 If ST.Caption = "{F9}Stéréogramme" Then
	    prompt "Clic ou F9 pour remettre à jour le stéréo"
	 Else
	    ST!Stereo.MousePointer = 2
	    prompt "Clic sur le stéréo pour désigner une faille"
	 End If
   End Select
Exit Sub
Traite_Erreurs8:
   If Erreurs(Err, "Stéréo / Stereo_MouseMove") Then Resume Next
End Sub

Sub Stereo_MouseUp (Button As Integer, Shift As Integer, X As Single, Y As Single)
   On Error GoTo Traite_Erreurs9:
   If focus = False Then Exit Sub
   If flag = True Then flag = False: Exit Sub
   If xdebut <> -2 Then
	 Call TraceRectangle(0, ST!Stereo, xdebut, ydebut, X, Y, xdernier, ydernier)
   End If
   If (X = xdebut And Y = ydebut) Or (xdebut = -2 And ydebut = -2) Then
      distcentre = X ^ 2 + Y ^ 2
      Select Case distcentre
	 Case Is > 1    '***clic dans le cadre: on refait le stéréo
	    If X > 1.2 Or X < -1.2 Or Y > 1.2 Or Y < -1.2 Then
	       'release out stereo: cancel action
	       Exit Sub
	    Else
	       If Shift = 0 And (Button And 1) Then
		  F9
	       Else
		  CtrlF9
	       End If
	    End If
	 Case Else
	    If ST.Caption = "{F9}Stéréogramme" Then
	       If Shift = 0 And (Button And 1) Then
		  F9
	       Else
		  CtrlF9
	       End If
	    Else
	       If NbMesuresAffichees() <> 0 Then
		  pointefaille X, Y, -2, -2
		  screen.MousePointer = defaut
	       Else
		  screen.MousePointer = default
		  xdebut = -2: ydebut = -2
		  Exit Sub
	       End If
	    End If
      End Select
      screen.MousePointer = default
   Else
      'sélection des failles dans le rectangle xdebut,ydebut,x,y
      pointefaille xdebut, ydebut, X, Y
      screen.MousePointer = defaut
   End If
   xdebut = -2: ydebut = -2
Exit Sub
Traite_Erreurs9:
   If Erreurs(Err, "Stéréo / Stereo_MouseUp") Then Resume Next
End Sub

