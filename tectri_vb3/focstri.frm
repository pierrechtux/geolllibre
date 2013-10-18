VERSION 2.00
Begin Form TenseurFocStri 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Calcul d'un tenseur par les focalisations de stries"
   ClientHeight    =   6195
   ClientLeft      =   1305
   ClientTop       =   480
   ClientWidth     =   5970
   Height          =   6600
   Icon            =   FOCSTRI.FRX:0000
   Left            =   1245
   LinkMode        =   1  'Source
   LinkTopic       =   "Form3"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   6195
   ScaleWidth      =   5970
   Top             =   135
   Width           =   6090
   Begin CommandButton CommandeCopier 
      Caption         =   "&Copier..."
      Enabled         =   0   'False
      Height          =   375
      Left            =   480
      TabIndex        =   20
      Top             =   1800
      Width           =   975
   End
   Begin Frame CadreTenseur 
      Height          =   2895
      Left            =   360
      TabIndex        =   7
      Top             =   3120
      Width           =   5175
      Begin CommandButton TestTenseur 
         Caption         =   "&Test tenseur"
         Height          =   375
         Left            =   960
         TabIndex        =   4
         Top             =   2160
         Width           =   1215
      End
      Begin PictureBox ImageMohr 
         AutoRedraw      =   -1  'True
         BackColor       =   &H00FFFFFF&
         Height          =   975
         Left            =   2880
         ScaleHeight     =   945
         ScaleWidth      =   2145
         TabIndex        =   10
         Top             =   1560
         Width           =   2175
      End
      Begin Frame Cadre1 
         Caption         =   "Axes du tenseur"
         Height          =   1215
         Left            =   2880
         TabIndex        =   14
         Top             =   240
         Width           =   2175
         Begin Label EtiquetteSigma 
            Caption         =   "Sigma3"
            Height          =   255
            Index           =   3
            Left            =   120
            TabIndex        =   17
            Top             =   840
            Width           =   1935
         End
         Begin Label EtiquetteSigma 
            Caption         =   "Sigma2"
            Height          =   255
            Index           =   2
            Left            =   120
            TabIndex        =   16
            Top             =   600
            Width           =   1935
         End
         Begin Label EtiquetteSigma 
            Caption         =   "Sigma1"
            Height          =   255
            Index           =   1
            Left            =   120
            TabIndex        =   15
            Top             =   360
            Width           =   1935
         End
      End
      Begin Label RegimeLabel 
         BorderStyle     =   1  'Fixed Single
         Height          =   450
         Left            =   960
         TabIndex        =   18
         Top             =   1560
         Width           =   1695
      End
      Begin Label RapportForme 
         BorderStyle     =   1  'Fixed Single
         Height          =   375
         Left            =   1800
         TabIndex        =   12
         Top             =   1080
         Width           =   495
      End
      Begin Label AngleFocStri 
         BorderStyle     =   1  'Fixed Single
         Height          =   375
         Left            =   1800
         TabIndex        =   9
         Top             =   480
         Width           =   495
      End
      Begin Label Etiquette3 
         BorderStyle     =   1  'Fixed Single
         Caption         =   "Cercle de Mohr"
         Height          =   255
         Left            =   3000
         TabIndex        =   13
         Top             =   2520
         Width           =   1695
      End
      Begin Label Etiquette7 
         Caption         =   "Régime:"
         Height          =   255
         Left            =   120
         TabIndex        =   19
         Top             =   1560
         Width           =   735
      End
      Begin Label Etiquette2 
         Caption         =   "Rapport de forme:"
         Height          =   375
         Left            =   120
         TabIndex        =   11
         Top             =   1080
         Width           =   1335
      End
      Begin Label Etiquette1 
         Caption         =   "Angle entre les focalisations:"
         Height          =   375
         Left            =   120
         TabIndex        =   8
         Top             =   480
         Width           =   1455
      End
   End
   Begin CheckBox Coche_letraset 
      Caption         =   "&flèches de déformation"
      Height          =   255
      Left            =   360
      TabIndex        =   3
      Top             =   2760
      Width           =   2415
   End
   Begin CommandButton Annuler 
      Cancel          =   -1  'True
      Caption         =   "&Annuler"
      Height          =   375
      Left            =   1560
      TabIndex        =   2
      Top             =   1800
      Width           =   975
   End
   Begin CommandButton Repointer 
      Caption         =   "&Repointer"
      Enabled         =   0   'False
      Height          =   375
      Left            =   1560
      TabIndex        =   1
      Top             =   1320
      Width           =   975
   End
   Begin CommandButton ok 
      Caption         =   "&Ok"
      Default         =   -1  'True
      Height          =   375
      Left            =   480
      TabIndex        =   0
      Top             =   1320
      Width           =   975
   End
   Begin PictureBox Stereo 
      AutoRedraw      =   -1  'True
      BackColor       =   &H00FFFFFF&
      DragIcon        =   FOCSTRI.FRX:0302
      DragMode        =   1  'Automatic
      Height          =   3015
      Left            =   2880
      MousePointer    =   1  'Arrow
      ScaleHeight     =   2.307
      ScaleLeft       =   -1.4
      ScaleMode       =   0  'User
      ScaleTop        =   1.4
      ScaleWidth      =   1.873
      TabIndex        =   5
      Top             =   0
      Width           =   3015
   End
   Begin PictureBox Bmp 
      AutoRedraw      =   -1  'True
      BackColor       =   &H00FFFFFF&
      Height          =   2955
      Left            =   945
      ScaleHeight     =   2925
      ScaleWidth      =   2925
      TabIndex        =   21
      Top             =   210
      Visible         =   0   'False
      Width           =   2955
   End
   Begin Label Etiquette 
      BorderStyle     =   1  'Fixed Single
      Height          =   735
      Left            =   120
      TabIndex        =   6
      Top             =   360
      Width           =   2655
   End
End
Dim xfoc1
Dim yfoc1
Dim xfoc2
Dim yfoc2
'Variables des clics stéréo pr les focstri
Dim RatX, RatY
Dim xsigma(1 To 3), ysigma(1 To 3), PlSigma(1 To 3), azsigma(1 To 3)
'Dim Tenseur_FStri As tenseur
Dim alfa
Dim Regime$
'Pour compter les clics sur le stéréo, lors des focalisations de stries
Dim nbclics As Integer

Sub AngleFocStri_Click ()
   On Error GoTo Traite_Erreurs7:
   Stereo.CurrentX = .7 * Hémisphère
   Stereo.CurrentY = 1.2 * Hémisphère
   tmp = Stereo.FontName
   Stereo.FontName = "symbol"
   Stereo.FontBold = False
   Stereo.FontSize = ST!Stereo.FontSize
   Stereo.Print "a=";
   Stereo.FontName = ST!Stereo.FontName
   Stereo.Print AngleFocStri.Caption
   bmp.CurrentX = .7 * Hémisphère
   bmp.CurrentY = 1.2 * Hémisphère
   tmp = bmp.FontName
   bmp.FontName = "symbol"
   bmp.FontBold = False
   bmp.Print "a=";
   bmp.FontName = ST!Stereo.FontName
   bmp.Print AngleFocStri.Caption
Exit Sub
Traite_Erreurs7:
   If Erreurs(Err, "TenseurFocStri / AngleFocStri_Click") Then Resume Next
End Sub

Sub annuler_Click ()
    Unload TenseurFocStri
End Sub

Sub CadreTenseur_MouseMove (Button As Integer, Shift As Integer, x As Single, y As Single)
   'Select Case RapportForme.Enabled
   '   Case True
   '      msg$ = Etiquette.Caption
   '   Case Else
   prompt "Clic sur rapport de forme, angle alfa, régime ou cercle de Mohr pour ajouter au stéréo."
End Sub

Sub calcul1 ()
   On Error GoTo Traite_Erreurs1:
'Et c'est parti...
'Calcul angle alfa entre les deux focalisations.
  'xfoc1;yfoc1-->foc1x;foc1y;foc1z:'en coordonn‚es r‚elles, pas pjet‚es.
  'xfoc2;yfoc2-->foc2x;foc2y:foc2z:'les vecteurs foci vont vers le haut.
 foc1x = (2 * (zfoc1 + 1) * xfoc1) / (xfoc1 ^ 2 + yfoc1 ^ 2 + (zfoc1 + 1) ^ 2)
 foc1y = (2 * (zfoc1 + 1) * yfoc1) / (xfoc1 ^ 2 + yfoc1 ^ 2 + (zfoc1 + 1) ^ 2)
 foc1z = (2 * (zfoc1 + 1) ^ 2) / (xfoc1 ^ 2 + yfoc1 ^ 2 + (zfoc1 + 1) ^ 2) - 1
 
 foc2x = (2 * (zfoc2 + 1) * xfoc2) / (xfoc2 ^ 2 + yfoc2 ^ 2 + (zfoc2 + 1) ^ 2)
 foc2y = (2 * (zfoc2 + 1) * yfoc2) / (xfoc2 ^ 2 + yfoc2 ^ 2 + (zfoc2 + 1) ^ 2)
 foc2z = (2 * (zfoc2 + 1) ^ 2) / (xfoc2 ^ 2 + yfoc2 ^ 2 + (zfoc2 + 1) ^ 2) - 1
  If foc1x = foc2x And foc1y = foc2y Then
    CR$ = Chr$(13) + Chr$(10)
    TheMessage$ = "Les deux foyers de stries doivent être distincts : ils correspondent à deux systèmes de failles conjuguées : recommencer en ne cliquant pas deux fois au même endroit." + CR$
    TheStyle = 48
    TheTitle$ = "Tectri : erreur!"
    MsgBox TheMessage$, TheStyle, TheTitle$
    nbclics = 0
    Stereo.Cls
    bmp.Cls
    TenseurFocStri!Etiquette.Caption = "Cliquez sur la première focalisation de stries..."
    Etiquette.Refresh
    Repointer_Click
    Exit Sub
   End If
   
 sigmasupx = foc1x + foc2x
 sigmasupy = foc1y + foc2y
 sigmasupz = foc1z + foc2z

 sigmainfx = foc1x - foc2x
 sigmainfy = foc1y - foc2y
 sigmainfz = foc1z - foc2z
 If sigmainfz < 0 Then sigmainfx = -sigmainfx: sigmainfy = -sigmainfy: sigmainfz = -sigmainfz
   
 If foc1x * foc2x + foc1y * foc2y + foc1z * foc2z > 0 Then
  sigma1x = sigmasupx / Sqr(sigmasupx ^ 2 + sigmasupy ^ 2 + sigmasupz ^ 2)
  sigma1y = sigmasupy / Sqr(sigmasupx ^ 2 + sigmasupy ^ 2 + sigmasupz ^ 2)
  sigma1z = sigmasupz / Sqr(sigmasupx ^ 2 + sigmasupy ^ 2 + sigmasupz ^ 2)
			
  sigma3x = sigmainfx / Sqr(sigmainfx ^ 2 + sigmainfy ^ 2 + sigmainfz ^ 2)
  sigma3y = sigmainfy / Sqr(sigmainfx ^ 2 + sigmainfy ^ 2 + sigmainfz ^ 2)
  sigma3z = sigmainfz / Sqr(sigmainfx ^ 2 + sigmainfy ^ 2 + sigmainfz ^ 2)
 
  alfa = ARCOS(foc1x * foc2x + foc1y * foc2y + foc1z * foc2z)
 End If

 If foc1x * foc2x + foc1y * foc2y + foc1z * foc2z < 0 Then
  sigma3x = sigmasupx / Sqr(sigmasupx ^ 2 + sigmasupy ^ 2 + sigmasupz ^ 2)
  sigma3y = sigmasupy / Sqr(sigmasupx ^ 2 + sigmasupy ^ 2 + sigmasupz ^ 2)
  sigma3z = sigmasupz / Sqr(sigmasupx ^ 2 + sigmasupy ^ 2 + sigmasupz ^ 2)
		       
  sigma1x = sigmainfx / Sqr(sigmainfx ^ 2 + sigmainfy ^ 2 + sigmainfz ^ 2)
  sigma1y = sigmainfy / Sqr(sigmainfx ^ 2 + sigmainfy ^ 2 + sigmainfz ^ 2)
  sigma1z = sigmainfz / Sqr(sigmainfx ^ 2 + sigmainfy ^ 2 + sigmainfz ^ 2)

  alfa = ARCOS(-(foc1x * foc2x + foc1y * foc2y + foc1z * foc2z))
 End If

'Sigma2
 sigma2x = sigma1y * sigma3z - sigma1z * sigma3y
 sigma2y = sigma1z * sigma3x - sigma1x * sigma3z
 sigma2z = sigma1x * sigma3y - sigma1y * sigma3x
  If sigma2z < 0 Then
   sigma2x = -sigma2x
   sigma2y = -sigma2y
   sigma2z = -sigma2z
  End If

'Projection des sigmai sur le st‚r‚o.
 xsigma(1) = sigma1x / (sigma1z + 1)
 ysigma(1) = sigma1y / (sigma1z + 1)
       
 xsigma(2) = sigma2x / (sigma2z + 1)
 ysigma(2) = sigma2y / (sigma2z + 1)

 xsigma(3) = sigma3x / (sigma3z + 1)
 ysigma(3) = sigma3y / (sigma3z + 1)
Exit Sub
Traite_Erreurs1:
   If Erreurs(Err, "ErreurPointage / calcul1") Then Resume Next
End Sub

Sub calcul2 ()
   On Error GoTo Traite_Erreurs2:
   'Calcul du rapport de forme RptFme=(s2-s1)/(s3-s1) ; tg^2(a)=R/(1-R)
   'Tenseur_FStri.
   RptFme = 1 / (1 + 1 / (Tan(pi / 2 - alfa / 2) ^ 2))

   'Az&pl des axes de contraintes
   tmp$ = ""
      For sigma = 1 To 3
	    'on a: xsigma()            on veut: azsigma()
	    '      ysigma()                     plsigma()
	 If ysigma(sigma) = 0 And xsigma(sigma) < 0 Then
	    alfa2 = pi
	 ElseIf ysigma(sigma) = 0 And xsigma(sigma) >= 0 Then alfa2 = 0
	 Else
	    alfa2 = -Atn(ysigma(sigma) / xsigma(sigma))
	    If xsigma(sigma) > 0 Then alfa2 = alfa2 + pi
	 End If
	    azsigma(sigma) = alfa2 + pi / 2
			' If xsigma(sigma) < 0 Then alfa2 = alfa2 + pi
			' If xsigma(sigma) < 0 Then alfa2 = alfa2 + 2 * pi
			'  Select Case alfa2
			'   Case 0 To pi / 4
			'          pddir2$ = "E"
			'   Case pi / 4 To 3 * pi / 4
			'          pddir2$ = "S"
			'   Case 3 * pi / 4 To 5 * pi / 4
			'          pddir2$ = "W"
			'   Case 5 * pi / 4 To 7 * pi / 4
			'          pddir2$ = "N"
			'   Case 7 * pi / 4 To 2 * pi
			'          pddir2$ = "E"
			'   Case Else
			'  End Select
			' If alfa2 >= pi Then alfa2 = alfa2 - pi
	 beta2 = ARCOS(-(xsigma(sigma) ^ 2 - (Cos(-alfa2)) ^ 2) / (xsigma(sigma) ^ 2 + (Cos(-alfa2)) ^ 2))
	 PlSigma(sigma) = pi / 2 - beta2
	 tmp$ = EtiquetteSigma(sigma).Caption
	 tmp$ = tmp$ + " : N" + Format$(CInt(azsigma(sigma) * 180 / pi), "000") + Format$(CInt(PlSigma(sigma) * 180 / pi), "  00")
	 EtiquetteSigma(sigma).Caption = tmp$
      Next

   
   '*******
   'ProjetteTenseur Tenseur_FStri, Stereo
   '*******
   FontBefore = Stereo.FontName
   Stereo.FontName = "symbol"
   Stereo.FontBold = False
   '********on peut pas définir bmp.fontname****
   'remplacer image par une picture box?
   '**ok**marche pas**
   bmp.FontName = "symbol"
   bmp.FontBold = False
      For sigma = 1 To 3
	 Stereo.Circle (xsigma(sigma), ysigma(sigma)), .03, TeintePremPlan%
	 Stereo.Print "s" + Str$(sigma)
	 'Bmp.ScaleMode = Stereo.ScaleMode
	 bmp.Circle (xsigma(sigma), ysigma(sigma)), .03, TeintePremPlan%
	 bmp.Print "s" + Str$(sigma)
	 'stereo.fontposition=indice: '!!!?????Comment faire ça?????
      Next
   Stereo.FontName = FontBefore
   '*****
   bmp.FontName = FontBefore

   'Nom du régime de contraintes
   'Régime homoaxial o/n?
   'Coupures en x*pi/2, pour savoir si un axe est trés basculé ou non:
    cut1 = .2
    cut2 = .35
    cut3 = .65
    cut4 = .8
    Regime$ = ""
      Select Case RptFme
	 Case 0 To .25
	    'Régime considéré comme homoaxial; sigma 3 principal
	    Select Case PlSigma(3)
	       Case cut2 * pi / 2 To cut3 * pi / 2
		  Regime$ = "(tenseur oblique)"
	       Case cut3 * pi / 2 To cut4 * pi / 2
		  Regime$ = "~Compression diffuse"
	       Case Is >= cut4 * pi / 2
		  Regime$ = "Compression diffuse"
	       Case cut1 * pi / 2 To cut2 * pi / 2
		  Regime$ = "~Transtension"
	       Case Is <= cut1 * pi / 2
		  Regime$ = "Transtension"
	       Case Else
	    End Select
	 Case .75 To 1
	    'Régime considéré comme homoaxial; sigma 1 principal
	    Select Case PlSigma(1)
	       Case cut2 * pi / 2 To cut3 * pi / 2
		 Regime$ = "(tenseur oblique)"
	       Case cut3 * pi / 2 To cut4 * pi / 2
		  Regime$ = "~Distension diffuse"
	       Case Is >= cut4 * pi / 2
		  Regime$ = "Distension diffuse"
	       Case cut1 * pi / 2 To cut2 * pi / 2
		 Regime$ = "~Transpression"
	       Case Is <= cut1 * pi / 2
		  Regime$ = "Transpression"
	       Case Else
	    End Select
	 Case Else
	    'Régime considéré comme non homoaxial
	    For sig = 1 To 3
	       If cut2 * pi / 2 <= PlSigma(sig) And PlSigma(sig) <= cut3 * pi / 2 Then
	       Regime$ = "(tenseur oblique)"
	       Exit For
	       End If
	    Next
	    
	    If Regime$ = "" Then
	       Select Case PlSigma(2)
					     'Case cut3 * pi / 2 To cut4 * pi / 2
					     ' Regime$ = "~Compression décrochante"
				       '        Case Is >= cut4 * pi / 2
		  Case Is >= cut3 * pi / 2
		     Regime$ = "Compression décrochante"
						'       Case Is <= cut1 * pi / 2
		  Case Is <= cut2 * pi / 2
		     Select Case PlSigma(1)
			Case Is <= cut2 * pi / 2
			   Regime$ = "Compression vraie"
			Case Is >= cut3 * pi / 2'cut4?
			   Regime$ = "Distension vraie"
			Case Else
		     End Select
		  Case Else
	       End Select
	       For sig = 1 To 3
		  If (cut1 * pi / 2 <= PlSigma(sig) And PlSigma(sig) <= cut2 * pi / 2) Or (cut3 * pi / 2 <= PlSigma(sig) And PlSigma(sig) <= cut4 * pi / 2) Then
		     Regime$ = "~" + Regime$
		     Exit For
		  End If
	       Next
	    End If
	 End Select
   
   'Affichage de RptFme.
   TenseurFocStri!AngleFocStri.Caption = Format$(alfa * 180 / pi, "###\°")
   TenseurFocStri!RapportForme.Caption = Format$(RptFme, "0.00")
   
   'Cercle de Mohr.   '!!!***Y plotter les failles
   ImageMohr.Scale (-.3, 1.3)-(1.3, -.3)
   TraceCercleMohr ImageMohr, RptFme
   
   'affiche résultats
   TenseurFocStri!RegimeLabel.Caption = Regime$
   TenseurFocStri!CadreTenseur.Enabled = True
   TenseurFocStri!Etiquette1.Enabled = True
   TenseurFocStri!AngleFocStri.Enabled = True
   TenseurFocStri!Etiquette2.Enabled = True
   TenseurFocStri!RapportForme.Enabled = True
   TenseurFocStri!Etiquette7.Enabled = True
   TenseurFocStri!RegimeLabel.Enabled = True
   TenseurFocStri!Cadre1.Enabled = True
   TenseurFocStri!ImageMohr.Enabled = True
   'TenseurFocStri!ImageMohr.DragMode = 1
   TenseurFocStri!Coche_letraset.Enabled = True
   TenseurFocStri!ok.Enabled = True
   TenseurFocStri!CommandeCopier.Enabled = True
   TenseurFocStri!Stereo.MousePointer = 0'fleche
   Stereo.Tag = ""
      If Coche_letraset.Value Then
	 onoff = Coche_letraset.Value
	 letraset TenseurFocStri!Stereo, Regime$, azsigma(), onoff
	 letraset TenseurFocStri!Bmp, Regime$, azsigma(), onoff
      End If
'***!!!Appel de TestTenseur, sur demande, pour tester le tenseur calcul‚ sur les mesures s‚lectionn‚es.
Exit Sub
Traite_Erreurs2:
   If Erreurs(Err, "ErreurPointage / calcul2") Then Resume Next
End Sub

Sub Coche_letraset_Click ()
   On Error GoTo Traite_Erreurs8:
    'si calcul disponible, appeler letrasets
  If flag Then Exit Sub
  onoff = Coche_letraset.Value
  tmp = drawstyle
  drawstyle = 6
  letraset TenseurFocStri!Stereo, Regime$, azsigma(), onoff
  letraset TenseurFocStri!Bmp, Regime$, azsigma(), onoff
  drawstyle = tmp
Exit Sub
Traite_Erreurs8:
   If Erreurs(Err, "TenseurFocStri / Coche_letraset_Click") Then Resume Next
End Sub

Sub CommandeCopier_Click ()
   On Error GoTo Traite_Erreurs9:
      '***changer le code de setdata pour copier le contenu de la feuille ds le presspap
   screen.MousePointer = 11
   CR$ = Chr$(13) + Chr$(10)
   tenseur$ = "Tectri         " + Now
   tenseur$ = tenseur$ + CR$ + "Tenseur de contraintes calculé par la méthode des focalisations de stries."
   tenseur$ = tenseur$ + CR$ + "Angle entre les foyers de stries:" + TenseurFocStri!AngleFocStri.Caption
   tenseur$ = tenseur$ + CR$ + "Régime tectonique : " + TenseurFocStri!RegimeLabel.Caption
   tenseur$ = tenseur$ + CR$ + "Rapport de forme du tenseur:" + TenseurFocStri!RapportForme.Caption
   For sigma = 1 To 3
      tenseur$ = tenseur$ + CR$ + EtiquetteSigma(sigma).Caption
   Next
      TheMessage$ = "Copier les résultats vers le presse-papier?" + CR$ + "(sinon, vers des fichiers bitmap et texte)"
      TheStyle = 35
      TheAnswer = MsgBox(TheMessage$, TheStyle)
      Select Case TheAnswer
	 Case 7   'Answered No
	    MDI!CMDialog.DialogTitle = "Enregistrer le tenseur calculé"
	    MDI!CMDialog.Filename = "tenseur.txt"
	    MDI!CMDialog.DefaultExt = "txt"
	    MDI!CMDialog.Filter = "Fichiers textes (*.txt)|*.txt|Tous fichiers (*.*)|*.*"
	    MDI!CMDialog.Flags = &H2& Or &H4&
	    MDI!CMDialog.CancelError = True
	    On Error Resume Next
	    MDI!CMDialog.Action = 2
	       If Not Err Then
		  On Error GoTo Traite_Erreurs9:
		  f$ = MDI!CMDialog.Filename
		  Open f$ For Append As #1
		  Print #1, tenseur$
		  Close #1
		  TheMessage$ = "Le fichier " & f$ & CR$ & "contient les résultats au format texte." + CR$
		  TheStyle = 48
		  MsgBox TheMessage$, TheStyle
	       End If
	    Err = False: On Error GoTo Traite_Erreurs9:
	    MDI!CMDialog.DialogTitle = "Enregistrer le stéréogramme en bitmap"
	    MDI!CMDialog.Filename = "tenseur.bmp"
	    MDI!CMDialog.Filter = "Fichiers bitmaps (*.bmp)|*.bmp|Tous fichiers (*.*)|*.*"
	    MDI!CMDialog.DefaultExt = "bmp"
	    MDI!CMDialog.Flags = &H2& Or &H4&
	    MDI!CMDialog.CancelError = True
	    On Error Resume Next
	    MDI!CMDialog.Action = 2
	    'InfoFichier.Caption = "Enregistrer le stéréogramme en bitmap"
	    'InfoFichier.TexteZone.Text = "tenseur.bmp"
	    'InfoFichier.Show 1
	       If Not Err Then
		  On Error GoTo Traite_Erreurs9:
		  f$ = MDI!CMDialog.Filename
		  SavePicture Stereo.Image, f$
		  CR$ = Chr$(13) + Chr$(10)
		  TheMessage$ = "Le fichier " & f$ & CR$ & "contient le stéréogramme au format bitmap." + CR$
		  TheStyle = 48
		  MsgBox TheMessage$, TheStyle
	       End If
	    Err = False: On Error GoTo Traite_Erreurs9:
	    MDI!CMDialog.DialogTitle = "Enregistrer le diagramme de Mohr"
	    MDI!CMDialog.Filename = "mohr.bmp"
	    MDI!CMDialog.Filter = "Fichiers bitmaps (*.bmp)|*.bmp|Tous fichiers (*.*)|*.*"
	    MDI!CMDialog.DefaultExt = "bmp"
	    MDI!CMDialog.Flags = &H2& Or &H4&
	    MDI!CMDialog.CancelError = True
	    On Error Resume Next
	    MDI!CMDialog.Action = 2
	    'InfoFichier.Caption = "Enregistrer le diagramme de Mohr"
	    'InfoFichier.TexteZone.Text = "mohr.bmp"
	    'InfoFichier.Show 1
	       If Not Err Then
		  On Error GoTo Traite_Erreurs9:
		  f$ = MDI!CMDialog.Filename
		  SavePicture ImageMohr.Image, f$
		  CR$ = Chr$(13) + Chr$(10)
		  TheMessage$ = "Le fichier " & f$ & CR$ & "contient le diagramme de Mohr au format bitmap." + CR$
		  TheStyle = 48
		  MsgBox TheMessage$, TheStyle
	       End If
	    Err = False: On Error GoTo Traite_Erreurs9:
	 Case 6   'Answered Yes
	    clipboard.Clear
	    clipboard.SetText tenseur$
	    TheMessage$ = "Le presse-papiers contient les résultats au format texte." + CR$
	    TheMessage$ = TheMessage$ + "Collez-le dans une application (notepad, excel, word, write, ...), puis faites OK." + CR$
	    TheStyle = 48
	    MsgBox TheMessage$, TheStyle
	    clipboard.Clear
	    clipboard.SetData Stereo.Image, 2
	    CR$ = Chr$(13) + Chr$(10)
	    TheMessage$ = "Le presse-papiers contient le stéréogramme au format bitmap." + CR$
	    TheMessage$ = TheMessage$ + "Collez-le dans une application (paintbrush, excel, word, write, ...), puis faites OK." + CR$
	    TheStyle = 48
	    MsgBox TheMessage$, TheStyle
	    clipboard.Clear
	    clipboard.SetData ImageMohr.Image, 2
	    CR$ = Chr$(13) + Chr$(10)
	    TheMessage$ = "Le presse-papiers contient le diagramme de Mohr au format bitmap." + CR$
	    TheMessage$ = TheMessage$ + "Collez-le dans une application (paintbrush, excel, word, write, ...), puis faites OK." + CR$
	    TheStyle = 48
	    MsgBox TheMessage$, TheStyle
	 Case Else  'Answered Cancel
      End Select
      
      'CommandeCopier.Visible = Not (CommandeCopier.Visible)
      'annuler.Visible = Not (annuler.Visible)
      'ok.Visible = Not (ok.Visible)
      'repointer.Visible = Not (repointer.Visible)
      'TestTenseur.Visible = Not (TestTenseur.Visible)
'***         clipboard.SetData Me, 2
      'CommandeCopier.Visible = Not (CommandeCopier.Visible)
      'annuler.Visible = Not (annuler.Visible)
      'ok.Visible = Not (ok.Visible)
      'repointer.Visible = Not (repointer.Visible)
      'TestTenseur.Visible = Not (TestTenseur.Visible)
   screen.MousePointer = defaut
Exit Sub
Traite_Erreurs9:
   If Erreurs(Err, "TenseurFocStri / CommandeCopier_Click") Then Resume Next
End Sub

Sub Form_Activate ()
   On Error GoTo Traite_Erreurs10:
	 Stereo.MousePointer = 2
	 Stereo.Tag = "Clic"
	 'TenseurFocStri!ImageMohr.DragMode = 0
	 'Ajustage
	 TenseurFocStri.ScaleMode = twips
	' TenseurFocStri!Stereo.ScaleMode = St!Stereo.ScaleMode
	 TenseurFocStri!Stereo.Height = ST!Stereo.Height
	 TenseurFocStri!Stereo.Width = ST!Stereo.Width
	 
	 TenseurFocStri!Stereo.FontName = ST!Stereo.FontName
	 TenseurFocStri!Stereo.FontSize = ST!Stereo.FontSize
	 'Redim_in_Stereo TenseurFocStri!Bmp, TenseurFocStri!Stereo, TenseurFocStri!Bmp.Left, TenseurFocStri!Bmp.Top, Abs(TenseurFocStri!Stereo.ScaleHeight), Abs(TenseurFocStri!Stereo.ScaleWidth)
	 TenseurFocStri.Bmp.Height = ST!Stereo.Height
	 TenseurFocStri.Bmp.Width = ST!Stereo.Width
	
	' TenseurFocStri.ScaleMode = twips
	 TenseurFocStri.Width = max(TenseurFocStri!Stereo.Left + TenseurFocStri!Stereo.Width + 675, CadreTenseur.Left + CadreTenseur.Width + 105)
	  tmp = TenseurFocStri!Stereo.Height + 105
	  If tmp > 3120 Then TenseurFocStri!CadreTenseur.Top = tmp
	 TenseurFocStri.Height = TenseurFocStri!CadreTenseur.Top + TenseurFocStri!CadreTenseur.Height + 555
	Get_Put_image ST!Stereo, TenseurFocStri!Stereo, ""
	bmp.Picture = LoadPicture("")
	TourStereo TenseurFocStri!Stereo
	bmp.ForeColor = bmp.BackColor
	TourStereo TenseurFocStri!Bmp
	bmp.ForeColor = Stereo.ForeColor
	TenseurFocStri!ImageMohr.Cls
	TenseurFocStri!ImageMohr.FontTransparent = True
	TenseurFocStri!AngleFocStri.Caption = ""
	TenseurFocStri!RapportForme.Caption = ""
	TenseurFocStri!RegimeLabel.Caption = ""
	 For sigma = 1 To 3
	  TenseurFocStri!EtiquetteSigma(sigma).Caption = "Sigma" + Str$(sigma)
	 Next
DebutTenseurfocstries:
 nbclics = 0
 TenseurFocStri!Etiquette.Caption = "Cliquez sur la première focalisation de stries..."
 TenseurFocStri!CadreTenseur.Enabled = False
 TenseurFocStri!Etiquette1.Enabled = False
 TenseurFocStri!AngleFocStri.Enabled = False
 TenseurFocStri!Etiquette2.Enabled = False
 TenseurFocStri!RapportForme.Enabled = False
 TenseurFocStri!Etiquette7.Enabled = False
 TenseurFocStri!RegimeLabel.Enabled = False
 TenseurFocStri!Cadre1.Enabled = False
 TenseurFocStri!ImageMohr.Enabled = False
 TenseurFocStri!Stereo.DragMode = 0
 TenseurFocStri.FontTransparent = True
 TenseurFocStri!Coche_letraset.Enabled = False
 TenseurFocStri!ok.Enabled = False
 TenseurFocStri!CommandeCopier.Enabled = False
 TenseurFocStri!Stereo.MousePointer = 2
 Stereo.Tag = "Clic"
' For sigma = 1 To 3
'  TenseurFocStri!EtiquetteSigma(sigma).visible = 0
' Next
 On Error Resume Next
 screen.MousePointer = 0
Exit Sub
Traite_Erreurs10:
   If Erreurs(Err, "TenseurFocStri / Form_Activate") Then Resume Next
End Sub

Sub ImageMohr_click ()
   On Error GoTo Traite_Erreurs11:
      '**tracer cercle mohr sur stéréo
      Stereo.Scale (-3.3, 4.3)-(1.3, -.3)
      bmp.Scale (-3.3, 4.3)-(1.3, -.3)
      TraceCercleMohr Stereo, Val(TenseurFocStri!RapportForme.Caption)
      TraceCercleMohr bmp, Val(TenseurFocStri!RapportForme.Caption)
      TourStereo Stereo'pour ravoir le système de cordonnées
Exit Sub
Traite_Erreurs11:
   If Erreurs(Err, "TenseurFocStri / ImageMohr_click") Then Resume Next
End Sub

Sub ok_Click ()
   On Error GoTo Traite_Erreurs12:
   TenseurFocStri.Hide
   'Copier stéréo ds feuille principale
   ST!Stereo.Picture = TenseurFocStri!Stereo.Image
   Get_Put_image TenseurFocStri!Bmp, ST!bmp, "and2"'St!bmp.Picture = TenseurFocStri!Bmp.Image

   'St!bmp.Picture = TenseurFocStri!Stereo.Picture
   'gET_put_image TenseurFocStri!Stereo, St!Bmp, ""
   
   'gET_put_image TenseurFocStri!Stereo, St!Stereo, ""
   TenseurFocStri.Stereo.Picture = LoadPicture("")
   If SystemLow() Then Unload Me
Exit Sub
Traite_Erreurs12:
   If Erreurs(Err, "TenseurFocStri / ok_Click") Then Resume Next
End Sub

Sub PremierClic (x, y)
   On Error GoTo Traite_Erreurs3:
'on vient de cliquer sur le stéréo pour la première fois
  repointer.Enabled = 1
  Stereo.Circle (x, y), .05, TeintePremPlan%
  bmp.Circle (x, y), .05, TeintePremPlan%
  xfoc1 = RatX: yfoc1 = RatY
  tmp$ = Etiquette.Caption
  tmp$ = tmp$ + Chr$(13) + Chr$(10) + "... et sur la seconde..."
  Etiquette.Caption = tmp$
  Etiquette.Refresh
Exit Sub
Traite_Erreurs3:
   If Erreurs(Err, "ErreurPointage / PremierClic") Then Resume Next
End Sub

Sub Quel ()
 Etiquette.Caption = "Traces des sigma 1 et 3. Cliquez sur le sigma1."
 Etiquette.Refresh
End Sub

Sub RapportForme_Click ()
   On Error GoTo Traite_Erreurs13:
   Stereo.CurrentX = .7 * Hémisphère
   Stereo.CurrentY = 1 * Hémisphère
   tmp = Stereo.FontName
   Stereo.FontName = "Arial"
   Stereo.FontBold = False
   Stereo.FontSize = ST!Stereo.FontSize
   Stereo.FontBold = False
   Stereo.Print "R=" & RapportForme.Caption

   bmp.CurrentX = .7 * Hémisphère
   bmp.CurrentY = 1 * Hémisphère
   tmp = bmp.FontName
   bmp.FontName = "Arial"
   bmp.FontBold = False
   'stereo.FontName = tmp
   bmp.FontBold = False
   bmp.Print "R=" & RapportForme.Caption
Exit Sub
Traite_Erreurs13:
   If Erreurs(Err, "TenseurFocStri / RapportForme_Click") Then Resume Next
End Sub

Sub RegimeLabel_Click ()
   On Error GoTo Traite_Erreurs14:
   Stereo.CurrentX = -1.2 * Hémisphère
   Stereo.CurrentY = -1.05 * Hémisphère
   tmp = Stereo.FontName
   Stereo.FontName = "Arial"
   Stereo.FontBold = False
   Stereo.FontSize = ST!Stereo.FontSize
   Stereo.FontBold = False
   Stereo.Print RegimeLabel.Caption

   bmp.CurrentX = -1.2 * Hémisphère
   bmp.CurrentY = -1.2 * Hémisphère
   tmp = bmp.FontName
   bmp.FontName = "Arial"
   bmp.FontBold = False
   'stereo.FontName = tmp
   bmp.FontBold = False
   bmp.Print RegimeLabel.Caption
Exit Sub
Traite_Erreurs14:
   If Erreurs(Err, "TenseurFocStri / RegimeLabel_Click") Then Resume Next
End Sub

Sub Repointer_Click ()
   Form_Activate
End Sub

Sub SecondClic (x, y)
   On Error GoTo Traite_Erreurs4:
'on vient de cliquer sur le stéréo pour la seconde fois
  Stereo.Circle (x, y), .05, TeintePremPlan%
  bmp.Circle (x, y), .05, TeintePremPlan%
   xfoc2 = RatX: yfoc2 = RatY
  Etiquette.Caption = "Calcul en cours..."
  Etiquette.Refresh
  calcul1
  If TenseurFocStri!Etiquette.Caption = "Cliquez sur la première focalisation de stries..." Then Exit Sub
'Quel est le sigma1?
 Stereo.Circle (xsigma(1), ysigma(1)), .03, TeintePremPlan%
 Stereo.Circle (xsigma(3), ysigma(3)), .03, TeintePremPlan%
Quel
Exit Sub
Traite_Erreurs4:
   If Erreurs(Err, "ErreurPointage / SecondClic") Then Resume Next
End Sub

Sub Sigma1clic (x, y)
   On Error GoTo Traite_Erreurs5:
   RatX = x
   RatY = y
   DistanceS1Cliq = Sqr((RatX - xsigma(1)) ^ 2 + (RatY - ysigma(1)) ^ 2)
   DistanceS3Cliq = Sqr((RatX - xsigma(3)) ^ 2 + (RatY - ysigma(3)) ^ 2)
   'Debug.Print DistanceS1Cliq, DistanceS3Cliq
      If DistanceS1Cliq > .2 And DistanceS3Cliq > .2 Then Quel: nbclics = 2: Exit Sub
      If DistanceS1Cliq > DistanceS3Cliq Then
	 swap xsigma(1), xsigma(3)
	 swap ysigma(1), ysigma(3)
	 alfa = pi - alfa
      End If
   Etiquette.Caption = "Calcul en cours..."
   Etiquette.Refresh
   calcul2
   Etiquette.Caption = "Ok pour copier le résultat obtenu sur le stéréogramme principal"
   Etiquette.Refresh
Exit Sub
Traite_Erreurs5:
   If Erreurs(Err, "ErreurPointage / Sigma1clic") Then Resume Next
End Sub

Sub Stereo_DragDrop (Source As Control, x As Single, y As Single)
   On Error Resume Next
   If Source Is ImageMohr Then
      ImageMohr_click
   End If
End Sub

Sub Stereo_MouseDown (Bouton As Integer, Maj As Integer, x As Single, y As Single)
   On Error GoTo Traite_Erreurs15:
   If Sqr(x ^ 2 + y ^ 2) > 1 Then Exit Sub
   nbclics = nbclics + 1
   RatX = x
   RatY = y
      Select Case nbclics
	 Case 1
	    screen.MousePointer = 11
	    PremierClic x, y
	 Case 2
	    screen.MousePointer = 11
	    SecondClic x, y
	 Case 3
	    screen.MousePointer = 11
	    Sigma1clic x, y
	 Case Else
	    Beep
      End Select
   screen.MousePointer = defaut
Exit Sub
Traite_Erreurs15:
   If Erreurs(Err, "TenseurFocStri / Stereo_MouseDown") Then Resume Next
End Sub

Sub Stereo_MouseMove (Button As Integer, Shift As Integer, x As Single, y As Single)
   If Stereo.Tag <> "" Then   'on demande au user de cliquer
      distcentre = x ^ 2 + y ^ 2
      Select Case distcentre
	 Case Is > 1'***cadre
	    Stereo.MousePointer = 0
	 Case Else
	    Stereo.MousePointer = 2
      End Select
   End If
End Sub

Sub TestTenseur_Click ()
   On Error GoTo Traite_Erreurs16:
    'Création d'un fichier sig.tmp avec le tenseur calculé
       Open "tenseur.tmp" For Output As #1
	 For sigma = 1 To 3
	  Print #1, EtiquetteSigma(sigma).Caption
	 Next
       MsgBox ("Tenseur calculé sauvé dans le fichier tenseur.tmp")
       Close #1
    NonDisponible
    'Calcultenseur_Click
Exit Sub
Traite_Erreurs16:
   If Erreurs(Err, "TenseurFocStri / TestTenseur_Click") Then Resume Next
End Sub

Sub TraceCercleMohr (objet As Control, ByVal RptFme)
   On Error GoTo Traite_Erreurs6:
   objet.Line (0, 0)-(1, 0), TeintePremPlan%
   objet.Circle (.5, 0), (.5), , 0, pi
   On Error Resume Next
   objet.Circle ((1 - RptFme) / 2, 0), (1 - RptFme) / 2, TeintePremPlan%, 0, pi
   objet.Circle (0 + (1 - RptFme) / 2 + 1 / 2, 0), (1 - (1 - RptFme)) / 2, TeintePremPlan%, 0, pi
   
   'On met les noms des sigmas. A modif pour les st‚r‚os en noir sur blanc...
   objet.FontName = "symbol"
   objet.FontBold = False
   objet.PSet (0, 0)
   objet.Print "s3"
   objet.PSet (1 - RptFme, 0)
   objet.Print "s2"
   objet.PSet (1, 0)
   objet.Print "s1"
   '!!!objet.fontposition=indice: '?????Comment faire ça?????
Exit Sub
Traite_Erreurs6:
   If Erreurs(Err, "ErreurPointage / TraceCercleMohr") Then Resume Next
End Sub

