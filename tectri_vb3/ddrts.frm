VERSION 2.00
Begin Form Boite_Diedres_Droits 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Dièdres droits"
   ClientHeight    =   5850
   ClientLeft      =   195
   ClientTop       =   780
   ClientWidth     =   6630
   Height          =   6255
   Icon            =   0
   Left            =   135
   LinkMode        =   1  'Source
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   390
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   442
   Top             =   435
   Width           =   6750
   Begin CommandButton CommandeOptions 
      Caption         =   "&Options"
      Height          =   375
      Left            =   2640
      TabIndex        =   14
      Top             =   1980
      Width           =   855
   End
   Begin PictureBox DiedreMesureCourante 
      AutoSize        =   -1  'True
      BackColor       =   &H00FFFFFF&
      Height          =   1815
      Left            =   3720
      ScaleHeight     =   1785
      ScaleWidth      =   1785
      TabIndex        =   9
      TabStop         =   0   'False
      Top             =   5640
      Visible         =   0   'False
      Width           =   1815
   End
   Begin PictureBox StereoToutNoir 
      AutoSize        =   -1  'True
      BackColor       =   &H00FFFFFF&
      Height          =   1935
      Left            =   960
      ScaleHeight     =   1905
      ScaleWidth      =   2025
      TabIndex        =   5
      TabStop         =   0   'False
      Top             =   5640
      Visible         =   0   'False
      Width           =   2055
   End
   Begin PictureBox StereoIntersectifCumulX 
      AutoSize        =   -1  'True
      BackColor       =   &H00FFFFFF&
      Height          =   2055
      Left            =   2880
      ScaleHeight     =   2025
      ScaleWidth      =   1905
      TabIndex        =   8
      TabStop         =   0   'False
      Top             =   3120
      Width           =   1935
   End
   Begin PictureBox StereoIntersectifCumulZ 
      AutoSize        =   -1  'True
      BackColor       =   &H00FFFFFF&
      Height          =   2055
      Left            =   60
      ScaleHeight     =   2025
      ScaleWidth      =   2100
      TabIndex        =   7
      TabStop         =   0   'False
      Top             =   3060
      Width           =   2130
   End
   Begin CheckBox Coche_ddroits_rapides 
      Caption         =   "Affichage des &secteurs X et Z"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   315
      Left            =   120
      TabIndex        =   4
      Top             =   2400
      Width           =   3015
   End
   Begin CommandButton Commande_Annuler 
      Cancel          =   -1  'True
      Caption         =   "&Annuler"
      Height          =   375
      Left            =   2640
      TabIndex        =   2
      Top             =   1560
      Width           =   855
   End
   Begin CheckBox Coche_Pas_a_pas 
      Caption         =   "&Pas à pas"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   375
      Left            =   120
      TabIndex        =   3
      Top             =   1980
      Width           =   1215
   End
   Begin CommandButton Commande_ok 
      Caption         =   "&OK"
      Enabled         =   0   'False
      Height          =   375
      Left            =   1560
      TabIndex        =   1
      Top             =   1560
      Width           =   855
   End
   Begin CommandButton commande_commence 
      Caption         =   "&Commencer"
      Height          =   375
      Left            =   120
      TabIndex        =   0
      Top             =   1560
      Width           =   1215
   End
   Begin PictureBox Stereo 
      AutoSize        =   -1  'True
      BackColor       =   &H00FFFFFF&
      Height          =   2415
      Left            =   3600
      ScaleHeight     =   2385
      ScaleWidth      =   2745
      TabIndex        =   11
      TabStop         =   0   'False
      Top             =   0
      Width           =   2775
   End
   Begin PictureBox Bmp 
      BackColor       =   &H00FFFFFF&
      Height          =   2955
      Left            =   3600
      ScaleHeight     =   2925
      ScaleWidth      =   2925
      TabIndex        =   15
      Top             =   750
      Visible         =   0   'False
      Width           =   2955
   End
   Begin Label Etiquettex 
      Caption         =   "Secteur X"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   255
      Left            =   2880
      TabIndex        =   13
      Top             =   2760
      Width           =   975
   End
   Begin Label Etiquettez 
      Caption         =   "Secteur Z"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   255
      Left            =   120
      TabIndex        =   12
      Top             =   2760
      Width           =   975
   End
   Begin Label info 
      BorderStyle     =   1  'Fixed Single
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   975
      Left            =   240
      TabIndex        =   10
      Top             =   480
      Width           =   3135
   End
   Begin Label Etiquette1 
      Alignment       =   2  'Center
      Caption         =   "Dièdres droits: méthode dite manuelle appliquée aux failles sélectionnées"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   495
      Left            =   225
      TabIndex        =   6
      Top             =   0
      Width           =   3165
   End
End

Sub AffDiedreDroit ()
   On Error GoTo Traite_Erreurs1:
   '****Ancienne solution, avec des paint
   Stereo.Cls
   TourStereo Stereo
   affTraceCyclo Stereo, 1
   paint Stereo, Site(ns).Faille(i).param.PolX, Site(ns).Faille(i).param.PolY, CouleurRemplissage&: '
   getstereo Stereo, DiedreMesureCourante
   Stereo.Cls
   TourStereo Stereo
   affAuxDdroit Stereo, 1
   'paint Stereo, strix(ns, i), striy(ns, i), CouleurRemplissage&: 'TeintePremPlan%
   paint Stereo, Site(ns).Faille(i).param.SX, Site(ns).Faille(i).param.SY, CouleurRemplissage&: 'TeintePremPlan%
   'PUT (-1, -1), DiedreMesureCourante, XOR
   PutStereo DiedreMesureCourante, "XOR", Stereo
   TourStereo Stereo
   'temp% = BitBlt(St!Stereo.hDC, 0, 0, St!Stereo.height, St!Stereo.width, St!Stereo.hDC, 0, 0, &H330008)
   'Debug.Print temp%
   getstereo Stereo, DiedreMesureCourante
   
      If Site(ns).Faille(i).param.jv = "N" Then
         PutStereo StereoIntersectifCumulX, "AND", Stereo
         'tourstereo
         getstereo Stereo, StereoIntersectifCumulX
         
         PutStereo DiedreMesureCourante, "PSET", Stereo
         PutStereo StereoToutNoir, "XOR", Stereo
         TourStereo Stereo
         PutStereo StereoIntersectifCumulZ, "AND", Stereo
         'tourstereo
         getstereo Stereo, StereoIntersectifCumulZ
      End If
      If Site(ns).Faille(i).param.jv = "I" Then
         PutStereo StereoIntersectifCumulZ, "AND", Stereo
         TourStereo Stereo
         getstereo Stereo, StereoIntersectifCumulZ
         PutStereo DiedreMesureCourante, "PSET", Stereo
         PutStereo StereoToutNoir, "XOR", Stereo
         TourStereo Stereo
         PutStereo StereoIntersectifCumulX, "AND", Stereo
         TourStereo Stereo
         getstereo Stereo, StereoIntersectifCumulX
      End If
Exit Sub
Traite_Erreurs1:
   If Erreurs(Err, "Boite_Diedres_Droits / AffDiedreDroit") Then Resume Next
End Sub

Sub Coche_ddroits_rapides_Click ()
    'Ddrts_rapides = Coche_ddroits_rapides.value
    'Redimension_feuille Boite_Diedres_droits
   Form_Resize
End Sub

Sub Coloriage ()
   On Error GoTo Traite_Erreurs2:
   Stereo.Cls
   Stereo.FillStyle = plein
   Stereo.FillColor = CouleurDdroits_X
   TourStereo Stereo
   Stereo.FillStyle = transparent
   PutStereo StereoIntersectifCumulX, "paint", Stereo
   getstereo StereoIntersectifCumulX, StereoToutNoir
   
   getstereo Stereo, StereoIntersectifCumulX

   Stereo.Cls
   Stereo.FillStyle = plein
   Stereo.FillColor = CouleurDdroits_Z
   TourStereo Stereo
   Stereo.FillStyle = transparent
   PutStereo StereoIntersectifCumulZ, "paint", Stereo
   'getstereo Stereo, StereoIntersectifCumulZ

   PutStereo StereoIntersectifCumulX, "xor", Stereo
   getstereo StereoToutNoir, StereoIntersectifCumulX
   'TourStereo Stereo
   TeintePremPlan% = TeintePremPlani
   TeinteFond% = TeinteFondi
   Stereo.FillStyle = plein
   Stereo.FillColor = CouleurDdroits_X
   Stereo.Line (-1.1 * Hémisphère, -.9 * Hémisphère)-Step(.2 * Hémisphère, .1 * Hémisphère), , B
   Stereo.Print "x"
   Stereo.FillColor = CouleurDdroits_Z
   Stereo.Line (-1.1 * Hémisphère, -.7 * Hémisphère)-Step(.2 * Hémisphère, .1 * Hémisphère), , B
   Stereo.Print "z"
   bmp.Picture = Stereo.Image
   
   Stereo.FillStyle = transparent
   TourStereo Stereo
Exit Sub
Traite_Erreurs2:
   If Erreurs(Err, "Boite_Diedres_Droits / Coloriage") Then Resume Next
End Sub

Sub Commande_Annuler_Click ()
   On Error GoTo Traite_Erreurs4:
   If Flag = flag_cede_main Then
      Flag = False
      CR$ = Chr$(13) + Chr$(10)
      TheMessage$ = "Arrêter le traitement des failles sélectionnées?"
      TheStyle = 52
      TheTitle$ = "Dièdres droits: interuption"
      TheAnswer = MsgBox(TheMessage$, TheStyle, TheTitle$)
         If TheAnswer = 6 Then  'Answered Yes
            Flag = flag_cancel
         Else     'Answered No
            
         End If
   Else
       boite_diedres_droits.Hide : 'Unload
       If SystemLow() = True Then Unload Me
   End If
Exit Sub
Traite_Erreurs4:
   If Erreurs(Err, "Boite_Diedres_Droits / Commande_Annuler_Click") Then Resume Next
End Sub

Sub commande_commence_Click ()
   On Error GoTo Traite_Erreurs5:
   If Flag = flag_cede_main Then Exit Sub
   screen.MousePointer = 11
   prompt "Tracé des dièdres droits en cours..."
   MDI!lblStatus.Refresh
         'Définition des autoredraw's
         DiedreMesureCourante.AutoRedraw = True
         Stereo.AutoRedraw = True
         StereoIntersectifCumulX.AutoRedraw = True
         StereoIntersectifCumulZ.AutoRedraw = True
         StereoToutNoir.AutoRedraw = True
         bmp.AutoRedraw = True
   DiedresDroits
   prompt ""
      If commande_ok.Enabled Then
         commande_commence.Default = False
         commande_ok.Default = True
         commande_ok.SetFocus
      End If
   screen.MousePointer = defaut
Exit Sub
Traite_Erreurs5:
   If Erreurs(Err, "Boite_Diedres_Droits / commande_commence_Click") Then Resume Next
End Sub

Sub Commande_Ok_Click ()
   On Error GoTo Traite_Erreurs6:
   If Flag = flag_cede_main Then Exit Sub
   '*************Remettre le stéréo des dièdres droits ainsi
   '*************obtenu par-dessus le stéréo de tectri
   'Hide
   'gET_put_image St!Stereo, Stereo, "and2"
   Get_Put_image Stereo, St!Stereo, "and2"
   Get_Put_image bmp, St!bmp, "and2"
   
   'windowstate = reduit
    Stereo.Picture = LoadPicture("")
    boite_diedres_droits.Hide 'Unload
    If SystemLow() Then Unload Me
   '*******St.SetFocus
   ' cyclo = cycloi
   ' aux = auxi
Exit Sub
Traite_Erreurs6:
   If Erreurs(Err, "Boite_Diedres_Droits / Commande_Ok_Click") Then Resume Next
End Sub

Sub CommandeOptions_Click ()
   On Error GoTo Traite_Erreurs7:
   If Flag = flag_cede_main Then Exit Sub
   'Choisir les couleurs des diedres
   Flag = flag_D_Droits
   screen.MousePointer = 11
   Boîte_Options.Show 1
   If Flag <> flag_cancel Then Coloriage
   screen.MousePointer = defaut
   Flag = False
Exit Sub
Traite_Erreurs7:
   If Erreurs(Err, "Boite_Diedres_Droits / CommandeOptions_Click") Then Resume Next
End Sub

Sub DiedresDroits ()
   On Error GoTo Traite_Erreurs3:
   Static compteur, CompteTotal
   compteur = 0
   CompteTotal = NbMesuresAffichees()
      If CompteTotal = 0 Then
         Beep
         msg$ = "Erreur : aucune mesure sélectionnée..."
         info.Caption = msg$
         info.Refresh
         commande_Annuler.Default = True
         commande_Annuler.SetFocus
         Exit Sub
       End If
   'AutoRedraw = True
   Refresh
   rsttemoin = rst
      '***A modif: paramétrer ds Initdéfaut, options, tectri.ini : cleurs ddroits
      ForeColor = texte_fenetre
      CouleurRemplissage& = ForeColor

   Stereo.Cls
   Stereo.FillStyle = plein
   Stereo.FillColor = CouleurRemplissage&
   TourStereo Stereo
   Stereo.FillStyle = transparent

   getstereo Stereo, StereoToutNoir
   getstereo Stereo, StereoIntersectifCumulZ
   getstereo Stereo, StereoIntersectifCumulX

   cycloi = MDI!menu_trace(1).Checked
   MDI!menu_trace(1).Checked = True
   auxi = MDI!menu_trace(11).Checked
   MDI!menu_trace(11).Checked = True

   compteur = 1
   nsns = 0
   nsi = ns
      For ns = 1 To NbStations
         If Not (Site(ns).deleted) Then
            If Not (Affich_F_Stations_Icones = False And frm_Station(ns).WindowState = REDUIT) Then
               nsns = nsns + 1
               For i = 1 To Site(ns).NbMes
                     If (Site(ns).Faille(i).GroupeTri >= 0) Then
                        If MDI!menu_projettegroupe(Site(ns).Faille(i).GroupeTri).Checked Then                'Affichage(Site(ns).Faille(i).GroupeTri) Then
                           msg$ = "Traitement de la" + Str$(i) + "° faille du" + Str$(nsns) + "° site"
                           msg$ = msg$ + Chr$(13) + Chr$(10) + Str$(compteur) + "° mesure / " + Str$(CompteTotal)
                           msg$ = msg$ + Chr$(13) + Chr$(10) + Str$(CInt((compteur) / CompteTotal * 100)) + "% effectués    "
                           msg$ = msg$ + Chr$(13) + Chr$(10) + "                       Esc pour interrompre"
                           info.Caption = msg$
                           info.Refresh
                              AffDiedreDroit
                              compteur = compteur + 1
                                 If Coche_Pas_a_pas.Value <> 0 Then
                                    Sep$ = " "
                                    CR$ = Chr$(13) + Chr$(10)
                                    TheMessage$ = "Dernière faille traitée : " + CR$
                                    Station = "site " + Str$(ns) + ": " + Site(ns).NomFichier + CR$
                                    mesure = "mesure n°" + Str$(i) + ":" + CR$ + Site(ns).Faille(i).azi + Sep$ + Site(ns).Faille(i).Pd + Sep$ + Site(ns).Faille(i).DirPd + Sep$ + Site(ns).Faille(i).pitch + Sep$ + Site(ns).Faille(i).dirpi + Sep$ + Site(ns).Faille(i).jeu + Sep$ + Site(ns).Faille(i).Commentaire
                                    TheMessage$ = TheMessage$ + CR$ + Station + CR$ + mesure + CR$
                                    TheStyle = 64 + 1
                                    TheTitle$ = "Dièdres droits : option pas à pas"
                                    screen.MousePointer = defaut
                                    tmp = MsgBox(TheMessage$, TheStyle, TheTitle$)
                                    screen.MousePointer = 11
                                    Refresh
                                    If tmp = 2 Then Flag = flag_cancel: Exit For
                                 End If
                        End If
                     End If
                '  msg$ = "Traitement de la " + Str$(i) + "° mesure de la" + Str$(ns) + "° station"
                '  msg$ = msg$ + Chr$(13) + Chr$(10) + Str$(compteur) + "° mesure:"
                '  msg$ = msg$ + Chr$(13) + Chr$(10) + Str$(Int((compteur - 1) / CompteTotal * 100)) + "% effectués    "
                '  info.Caption = msg$
                  If compteur > CompteTotal Then Exit For
                  Flag = flag_cede_main
                  dummy = DoEvents()
                  If Flag = flag_cancel Then Exit For
                  Flag = 0
               Next
               If Flag = flag_cancel Then Exit For
               If compteur > CompteTotal Then Exit For
               Refresh
            End If
         End If
      Next
   ns = nsi
   Flag = False
   msg$ = "100% effectués" + Chr$(13) + Chr$(10)
   msg$ = msg$ + "Coloriage des secteurs"
   info.Caption = msg$
   info.Refresh
   MDI!menu_trace(1).Checked = cycloi
   MDI!menu_trace(11).Checked = auxi
   Coloriage
   
   msg$ = "Ok pour copier le résultat obtenu sur le stéréogramme principal"
   If Flag = flag_cancel Then Flag = 0: msg$ = msg$ + Chr$(13) + Chr$(10) + "Attention : résultat incomplet!"
   info.Caption = msg$
   commande_ok.Enabled = True
Exit Sub
Traite_Erreurs3:
   If Erreurs(Err, "Boite_Diedres_Droits / DiedresDroits") Then Resume Next
End Sub

Sub Form_Activate ()
   On Error GoTo Traite_Erreurs8:
  '!!!virer tt ce qui est à cette hauteur
                                                '    If windowstate = 1 Then windowstate = 0
    On Error Resume Next'pour le setfocus qui n'est pas valable quand la feuille n'est pas showée
    If Not (Flag) Then Exit Sub'on revient d'un choix de couleurs
    Flag = False
    'If windowstate <> 1 Then
    Form_Resize
    Flag = False
    info.Caption = ""
      commande_Annuler.Default = False
      commande_commence.Default = True
      commande_ok.Enabled = False
      commande_commence.SetFocus

       TourStereo Stereo
       ScaleMode = twips'PIXELS
       Get_Put_image St!Stereo, Stereo, ""
       DiedreMesureCourante.Cls
       StereoToutNoir.Cls
       StereoIntersectifCumulZ.Cls
       StereoIntersectifCumulX.Cls
   screen.MousePointer = defaut
   commande_commence_Click
Exit Sub
Traite_Erreurs8:
   If Erreurs(Err, "Boite_Diedres_Droits / Form_Activate") Then Resume Next
End Sub

Sub Form_Load ()
   On Error GoTo Traite_Erreurs9:
   
   prompt "Dièdres droits : initialisation..."
   'centerformchild mdi, Me
   centerform Me
   Form_Activate
   screen.MousePointer = defaut
   prompt ""
Exit Sub
Traite_Erreurs9:
   If Erreurs(Err, "Boite_Diedres_Droits / Form_Load") Then Resume Next
End Sub

Sub Form_LostFocus ()
Beep
End Sub

Sub Form_QueryUnload (Cancel As Integer, UnloadMode As Integer)
   On Error GoTo Traite_Erreurs10:
   If Flag = flag_cede_main Then Commande_Annuler_Click
Exit Sub
Traite_Erreurs10:
   If Erreurs(Err, "Boite_Diedres_Droits / Form_QueryUnload") Then Resume Next
End Sub

Sub Form_Resize ()
   On Error GoTo Traite_Erreurs11:
   On Error Resume Next
   If (Flag <> 0 And Flag <> flag_cede_main) Or WindowState <> 0 Then Exit Sub
   tmp = -Coche_ddroits_rapides.Value
   Etiquettez.Visible = tmp
   'StereoIntersectifCumulZ.Visible = tmp
   'StereoIntersectifCumulX.Visible = tmp
   Etiquettex.Visible = tmp
   Stereo.Top = 100
   ScaleMode = St!Stereo.ScaleMode
   DiedreMesureCourante.Height = St!Stereo.Height
   DiedreMesureCourante.Width = St!Stereo.Width
                                          'DiedreMesureCourante.Cls
   StereoToutNoir.Height = St!Stereo.Height
   StereoToutNoir.Width = St!Stereo.Width
                                          'StereoToutNoir.Cls
   Stereo.Height = St!Stereo.Height
   Stereo.Width = St!Stereo.Width
   Etiquettez.Top = max(Stereo.Top + Stereo.Height, Coche_ddroits_rapides.Top + Coche_ddroits_rapides.Height) '+ hauteurbarretitre
                                           'Etiquettez.Top = min(Stereo.Top + Stereo.Height, Coche_ddroits_rapides.Top + Coche_ddroits_rapides.Height + 100) + hauteurbarretitre
                                       '    If Etiquettez.Top < Stereo.Top + Stereo.Height Then Etiquettez.Top = Stereo.Top + Stereo.Height
   StereoIntersectifCumulZ.Top = Etiquettez.Top + 250'20
   StereoIntersectifCumulZ.Left = Etiquettez.Left
   StereoIntersectifCumulZ.Height = St!Stereo.Height
   StereoIntersectifCumulZ.Width = St!Stereo.Width
                                           'StereoIntersectifCumulZ.Cls
                                           
   Etiquettex.Top = Etiquettez.Top
   Etiquettex.Left = StereoIntersectifCumulZ.Left + StereoIntersectifCumulZ.Width + 400'20
   StereoIntersectifCumulX.Left = Etiquettex.Left
   StereoIntersectifCumulX.Top = StereoIntersectifCumulZ.Top
   StereoIntersectifCumulX.Height = St!Stereo.Height
   StereoIntersectifCumulX.Width = St!Stereo.Width
                                             'StereoIntersectifCumulX.Cls
                                             'etiquettex.left = StereoIntersectifCumulX.left
                                             'ScaleMode = twips
                                             'ScaleMode = twips
      Flagi = Flag
      Flag = True'pour éviter qu'on ne se morde la queue
      Select Case Coche_ddroits_rapides.Value
         Case 0
            Flag = True
            Height = max(Coche_ddroits_rapides.Top + Coche_ddroits_rapides.Height, Stereo.Top + Stereo.Height) + 100 + hauteurbarretitre
            'width = Coche_ddroits_rapides.left + Coche_ddroits_rapides.width + 2000
            Flag = True
            Width = Stereo.Left + Stereo.Width + 100
         Case Else
            Flag = True
            Height = StereoIntersectifCumulX.Top + StereoIntersectifCumulX.Height + 100 + hauteurbarretitre
            Flag = True
            Width = max(StereoIntersectifCumulX.Left + StereoIntersectifCumulX.Width + 100, Stereo.Left + Stereo.Width + 100)
      End Select
      Flag = Flagi
      If boite_diedres_droits.Visible <> 0 And Stereo.AutoRedraw <> True Then Stereo.AutoRedraw = True
      'Get_Put_image St!Stereo, Stereo, ""
Exit Sub
Traite_Erreurs11:
   If Erreurs(Err, "Boite_Diedres_Droits / Form_Resize") Then Resume Next
End Sub

Sub Stereo_Click ()
   On Error GoTo Traite_Erreurs12:
   If Flag = flag_cede_main Then Exit Sub
   Select Case commande_ok.Enabled
      Case True
         Commande_Ok_Click
      Case Else
         commande_commence_Click
   End Select
Exit Sub
Traite_Erreurs12:
   If Erreurs(Err, "Boite_Diedres_Droits / Stereo_Click") Then Resume Next
End Sub

Sub Stereo_MouseMove (Button As Integer, Shift As Integer, X As Single, Y As Single)
   On Error GoTo Traite_Erreurs13:
   If Flag = flag_cede_main Then Exit Sub
         minimum = .15
         If Abs(X) > 1.2 - minimum Or Abs(Y) > 1.2 - minimum Then
            prompt ""
         Else
            Select Case commande_ok.Enabled
               Case True
                  prompt "Cliquez sur le stéréo pour copier le résultat"
               Case Else
                  prompt "Cliquez sur le stéréo pour commencer"
            End Select
         End If
Exit Sub
Traite_Erreurs13:
   If Erreurs(Err, "Boite_Diedres_Droits / Stereo_MouseMove") Then Resume Next
End Sub

