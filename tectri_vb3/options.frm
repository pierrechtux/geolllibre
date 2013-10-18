VERSION 2.00
Begin Form Boîte_options 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Tectri: options générales"
   ClientHeight    =   5850
   ClientLeft      =   945
   ClientTop       =   930
   ClientWidth     =   5280
   ClipControls    =   0   'False
   ControlBox      =   0   'False
   Height          =   6255
   Icon            =   OPTIONS.FRX:0000
   Left            =   885
   LinkMode        =   1  'Source
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5850
   ScaleWidth      =   5280
   Top             =   585
   Width           =   5400
   Begin TextBox text_teta 
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   285
      Left            =   2025
      TabIndex        =   38
      Top             =   3750
      Width           =   735
   End
   Begin CheckBox Coche_Affich_F_Stations_Icones 
      Caption         =   "Affichage des stations icônisées"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   255
      Left            =   105
      TabIndex        =   37
      Top             =   4725
      Value           =   1  'Checked
      Width           =   2790
   End
   Begin CheckBox Coche_signale_erreurs 
      Caption         =   "&Signal d'erreurs"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   255
      Left            =   1425
      TabIndex        =   36
      Top             =   5475
      Value           =   1  'Checked
      Width           =   1440
   End
   Begin OptionButton Option_Impression_Vectorielle 
      Caption         =   "vectoriel"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   255
      Left            =   4200
      TabIndex        =   33
      Top             =   1440
      Width           =   915
   End
   Begin OptionButton Option_Impression_Bitmap 
      Caption         =   "bitmap"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   255
      Left            =   4200
      TabIndex        =   32
      Top             =   1200
      Width           =   885
   End
   Begin CheckBox Coche_barre_etat 
      Caption         =   "Barre d'&état"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   255
      Left            =   105
      TabIndex        =   15
      Top             =   5490
      Value           =   1  'Checked
      Width           =   1260
   End
   Begin Frame Cadre4 
      Caption         =   "&Fichiers"
      Height          =   2025
      Left            =   2880
      TabIndex        =   26
      Top             =   2115
      Width           =   2280
      Begin CheckBox coche_nfiles 
         Caption         =   "&ouvrir plusieurs fichiers"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   225
         Left            =   75
         TabIndex        =   43
         Top             =   1575
         Width           =   2115
      End
      Begin ComboBox Combo_separateur 
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   300
         Left            =   975
         Style           =   2  'Dropdown List
         TabIndex        =   40
         Top             =   1200
         Width           =   990
      End
      Begin CheckBox Coche_bkp 
         Caption         =   "créer fichiers &bkp"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   225
         Left            =   105
         TabIndex        =   12
         Top             =   900
         Width           =   1590
      End
      Begin CheckBox Coche_Param 
         Caption         =   "&enregistrer les paramètres"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   330
         Left            =   75
         TabIndex        =   11
         Top             =   225
         Width           =   2130
      End
      Begin Label Label3 
         Caption         =   "Séparateur:"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   285
         Left            =   75
         TabIndex        =   41
         Top             =   1200
         Width           =   915
      End
      Begin Label Etiquette4 
         Alignment       =   2  'Center
         Caption         =   "géométriques des failles (chargement rapide)"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   435
         Left            =   150
         TabIndex        =   27
         Top             =   525
         Width           =   2010
      End
   End
   Begin CheckBox Coche_Affich_F_non_Sélec 
      Caption         =   "par défaut, sélection des failles &non triées,"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   345
      Left            =   105
      TabIndex        =   13
      Top             =   4170
      Value           =   1  'Checked
      Width           =   3630
   End
   Begin Frame Cadre3 
      Caption         =   "Couleurs"
      Height          =   1590
      Left            =   105
      TabIndex        =   21
      Top             =   2115
      Width           =   2745
      Begin CommandButton Commande_Groupes 
         Caption         =   "..."
         Height          =   225
         Left            =   2205
         TabIndex        =   10
         Top             =   1155
         Width           =   435
      End
      Begin CommandButton Commande_X 
         Caption         =   "..."
         Height          =   225
         Left            =   2205
         TabIndex        =   8
         Top             =   840
         Width           =   435
      End
      Begin CommandButton Commande_Z 
         Caption         =   "..."
         Height          =   225
         Left            =   2205
         TabIndex        =   7
         Top             =   525
         Width           =   435
      End
      Begin ComboBox Liste_GroupTri 
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   300
         Left            =   1155
         Sorted          =   -1  'True
         Style           =   2  'Dropdown List
         TabIndex        =   9
         Top             =   1155
         Width           =   645
      End
      Begin Shape Forme_Groupes 
         FillColor       =   &H00FFFFFF&
         FillStyle       =   0  'Solid
         Height          =   225
         Left            =   1785
         Top             =   1155
         Width           =   435
      End
      Begin Shape Forme_X 
         FillColor       =   &H00FFFFFF&
         FillStyle       =   0  'Solid
         Height          =   225
         Left            =   1785
         Top             =   840
         Width           =   435
      End
      Begin Shape Forme_Z 
         FillColor       =   &H00FFFFFF&
         FillStyle       =   0  'Solid
         Height          =   225
         Left            =   1785
         Top             =   525
         Width           =   435
      End
      Begin Label Etiquette8 
         BackStyle       =   0  'Transparent
         Caption         =   "&Groupes de tri:"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   -1  'True
         Height          =   330
         Left            =   105
         TabIndex        =   25
         Top             =   1155
         Width           =   1170
      End
      Begin Label Etiquette3 
         Alignment       =   1  'Right Justify
         Caption         =   "&allongement:"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   330
         Left            =   210
         TabIndex        =   24
         Top             =   840
         Width           =   1500
      End
      Begin Label Etiquette2 
         Alignment       =   1  'Right Justify
         Caption         =   "&raccourcissement:"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   225
         Left            =   210
         TabIndex        =   23
         Top             =   525
         Width           =   1500
      End
      Begin Label Etiquette1 
         Caption         =   "Zones de dièdres droits:"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   -1  'True
         Height          =   330
         Left            =   105
         TabIndex        =   22
         Top             =   315
         Width           =   1800
      End
   End
   Begin CommandButton Commande_annule 
      Cancel          =   -1  'True
      Caption         =   "&Annuler"
      Height          =   375
      Left            =   4020
      TabIndex        =   17
      Top             =   5130
      Width           =   975
   End
   Begin CommandButton Commande_ok 
      Caption         =   "&OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   2940
      TabIndex        =   16
      Top             =   5130
      Width           =   975
   End
   Begin CheckBox Coche_barre_outils 
      Caption         =   "Barre d'&outils"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   255
      Left            =   105
      TabIndex        =   14
      Top             =   5220
      Value           =   1  'Checked
      Width           =   1455
   End
   Begin Frame Cadre2 
      Caption         =   "&Stéréogramme"
      Height          =   2010
      Left            =   105
      TabIndex        =   18
      Top             =   105
      Width           =   5055
      Begin CheckBox Coche_Tracage_Progressif 
         Caption         =   "Retraçage progressif"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   255
         Left            =   105
         TabIndex        =   42
         Top             =   1650
         Width           =   2040
      End
      Begin CommandButton Command_Police 
         Caption         =   "&Police..."
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   240
         Left            =   3825
         TabIndex        =   35
         Top             =   675
         Width           =   765
      End
      Begin PictureBox Image1 
         BorderStyle     =   0  'None
         Height          =   540
         Left            =   900
         ScaleHeight     =   540
         ScaleWidth      =   1590
         TabIndex        =   31
         Top             =   1125
         Width           =   1590
         Begin OptionButton Option_auto_F9 
            Caption         =   "&automatique"
            FontBold        =   0   'False
            FontItalic      =   0   'False
            FontName        =   "MS Sans Serif"
            FontSize        =   8.25
            FontStrikethru  =   0   'False
            FontUnderline   =   0   'False
            Height          =   255
            Left            =   0
            TabIndex        =   5
            Top             =   0
            Width           =   1335
         End
         Begin OptionButton Option_manuel_F9 
            Caption         =   "&manuel (F9)"
            FontBold        =   0   'False
            FontItalic      =   0   'False
            FontName        =   "MS Sans Serif"
            FontSize        =   8.25
            FontStrikethru  =   0   'False
            FontUnderline   =   0   'False
            Height          =   255
            Left            =   0
            TabIndex        =   6
            Top             =   240
            Width           =   1335
         End
      End
      Begin CheckBox Coche_stereo_enavant 
         Caption         =   "toujours en &avant"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   255
         Left            =   105
         TabIndex        =   4
         Top             =   840
         Visible         =   0   'False
         Width           =   1935
      End
      Begin OptionButton hemiinf 
         Caption         =   "&inférieure"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   255
         Left            =   2490
         TabIndex        =   3
         Top             =   735
         Width           =   1335
      End
      Begin OptionButton hemisup 
         Caption         =   "s&upérieure"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   255
         Left            =   2490
         TabIndex        =   2
         Top             =   495
         Width           =   1335
      End
      Begin HScrollBar Défilement_Diamètre 
         Height          =   255
         LargeChange     =   10
         Left            =   2400
         Max             =   200
         Min             =   10
         MousePointer    =   9  'Size W E
         TabIndex        =   1
         Top             =   240
         Value           =   20
         Width           =   2475
      End
      Begin TextBox Diamètre 
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   285
         Left            =   1560
         TabIndex        =   0
         Top             =   240
         Width           =   735
      End
      Begin Label Label1 
         Caption         =   "Mode d'impression:"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   255
         Left            =   2700
         TabIndex        =   34
         Top             =   1125
         Width           =   2265
      End
      Begin Label Etiquette11 
         Caption         =   "Retraçage:"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   255
         Left            =   105
         TabIndex        =   30
         Top             =   1155
         Width           =   2265
      End
      Begin Label Etiquette6 
         Caption         =   "Projection de Wulff, hémisphère:"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   255
         Left            =   120
         TabIndex        =   20
         Top             =   630
         Width           =   2445
      End
      Begin Label Etiquette5 
         Caption         =   "&Diamètre (cm):"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   255
         Left            =   120
         TabIndex        =   19
         Top             =   240
         Width           =   1335
      End
   End
   Begin Label Label2 
      Caption         =   "Angle &Têta (défaut=30°) :"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   255
      Left            =   75
      TabIndex        =   39
      Top             =   3750
      Width           =   1890
   End
   Begin Label Etiquette10 
      Caption         =   "à l'ouverture d'un fichier"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   225
      Left            =   360
      TabIndex        =   29
      Top             =   4485
      Width           =   1935
   End
   Begin Label Etiquette7 
      Caption         =   "&Nombre de groupes de tri:"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "Times New Roman"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   330
      Left            =   105
      TabIndex        =   28
      Top             =   4170
      Visible         =   0   'False
      Width           =   1905
   End
End
Dim CouleurGroupeTmp()   As Long

Sub Coche_barre_etat_Click ()
   MDI!Image2.Visible = -Coche_barre_etat.Value
End Sub

Sub Coche_barre_outils_Click ()
   MDI!barre_outils.Visible = -Coche_Barre_Outils.Value
End Sub

Sub Coche_stereo_enavant_Click ()
'******Met le stéréo en avant
'!!!*****ça marche pas; peut-être parce que la fenêtre stéréo est une fille?
'****en effet, avec la fenêtre mdi, ça va.
        'mnuSysInfo(Index).Checked = Not mnuSysInfo(Index).Checked
'        If Coche_stereo_enavant.Value Then
'            SetWindowPos st.hWnd, -1     , 0, 0, 0, 0, &H10 Or &H40
'        Else
'            SetWindowPos st.hWnd, -2, 0, 0, 0, 0, &H10 Or &H40
'        End If
End Sub

Sub Command_Police_Click ()
   On Error Resume Next
   screen.MousePointer = 11
   MDI!CMDialog.DialogTitle = "Tectri: police du stéréogramme"
   MDI!CMDialog.Flags = &H3& Or &H200&
   MDI!CMDialog.FontName = St!Stereo.FontName
   MDI!CMDialog.FontSize = 10 * DiamStereo / 5'St!Stereo.FontSize
   MDI!CMDialog.FontBold = St!Stereo.FontBold
   MDI!CMDialog.FontItalic = St!Stereo.FontItalic
   MDI!CMDialog.FontStrikeThru = St!Stereo.FontStrikethru
   MDI!CMDialog.FontUnderLine = St!Stereo.FontUnderline
   MDI!CMDialog.CancelError = True
   MDI!CMDialog.Action = 4
   Command_Police.Tag = "modif"
   Commande_Ok.Default = True
   'If Err <> 0 Then GoTo outta_here:
   'On Error GoTo Traite_Erreurs1:
'outta_here:
   screen.MousePointer = defaut
Exit Sub
Traite_Erreurs1:
   If Erreurs(Err, "Boîte_options / Command_Police_Click") Then Resume Next
End Sub

Sub Commande_annule_Click ()
   flag = flag_cancel
   Unload Boîte_Options
End Sub

Sub Commande_Groupes_Click ()
   Forme_Groupes.FillColor = getcolor("Couleur du groupe " & SymboleGroupeDeTri(Liste_GroupTri.ListIndex + 1), Forme_Groupes.FillColor)
   CouleurGroupeTmp(Liste_GroupTri.ListIndex + 1) = Forme_Groupes.FillColor
   Commande_Ok.SetFocus
End Sub

Sub Commande_Ok_Click ()
   On Error GoTo Traite_Erreurs2:
   screen.MousePointer = 11
   Boîte_Options.Hide
   CouleurDdroits_X = Forme_X.FillColor
   CouleurDdroits_Z = Forme_Z.FillColor
   If Boîte_Options.Caption = "Couleurs" Then Unload Boîte_Options: Exit Sub
      If DiamStereo <> Diamètre.Text Then
         DiamStereo = Diamètre.Text
         chg_diam_stereo
      End If
      If hemiinf.Value Then
         If Hémisphère = 1 Then DéfinitionHémisphère St!Stereo
      ElseIf hemisup.Value Then
         If Hémisphère = -1 Then DéfinitionHémisphère St!Stereo
      End If
      If Command_Police.Tag = "modif" Then
         Command_Police.Tag = ""
         St!Stereo.FontName = MDI!CMDialog.FontName
         St!Stereo.FontSize = MDI!CMDialog.FontSize
         St!Stereo.FontBold = MDI!CMDialog.FontBold
         St!Stereo.FontItalic = MDI!CMDialog.FontItalic
         St!Stereo.FontStrikethru = MDI!CMDialog.FontStrikeThru
         St!Stereo.FontUnderline = MDI!CMDialog.FontUnderLine
         'répété 2x, à la suite de pbms ...
         St!Stereo.FontName = MDI!CMDialog.FontName
         St!Stereo.FontSize = MDI!CMDialog.FontSize
         St!Stereo.FontBold = MDI!CMDialog.FontBold
         St!Stereo.FontItalic = MDI!CMDialog.FontItalic
         St!Stereo.FontStrikethru = MDI!CMDialog.FontStrikeThru
         St!Stereo.FontUnderline = MDI!CMDialog.FontUnderLine
         F9
      End If
      For tmp = 1 To NbGroupesDeTri
         If CouleurGroupe(tmp) <> CouleurGroupeTmp(tmp) Then changé = True
         CouleurGroupe(tmp) = CouleurGroupeTmp(tmp)
         'GroupTri!Label_Population_Groupe(tmp).ForeColor = CouleurGroupe(tmp)
      Next
   If Retracage_Manuel <> Option_manuel_F9.Value Then Retracage_Manuel = False: RedessinStereo St!Stereo
   Retracage_Manuel = Option_manuel_F9.Value
   MDI!menu_trace_auto.Checked = Not (Retracage_Manuel)
   Impression_vectorielle = -Option_Impression_Vectorielle.Value
   Fichiers_Bkp = -Coche_bkp.Value
   Open_nFichiers = -coche_nfiles.Value
   Fichiers_Param = -Coche_param.Value
      Select Case Combo_separateur.ListIndex
         Case 0
            Separateur_champs$ = Chr$(9)
         Case Else
            Separateur_champs$ = " "
      End Select
   Aff_F_non_Sélec = -Coche_Affich_F_non_Sélec.Value
   teta_tmp = text_teta.Text * pi / 180
      If teta_tmp <> teta Then '** recalcul paramètres **
         teta = teta_tmp
            For nsns = 1 To NbStations
               If Not (Site(nsns).deleted) Then
                  CalculeFichier
               End If
            Next
         'F9
         RedessinStereo St!Stereo
      End If
   Signale_Erreurs = -Coche_signale_erreurs.Value
   Tracage_Progressif = -Coche_Tracage_Progressif.Value
      If Affich_F_Stations_Icones <> -Coche_Affich_F_Stations_Icones.Value Then
         Affich_F_Stations_Icones = -Coche_Affich_F_Stations_Icones.Value
         changé = True
      End If
      'If NbGroupesDeTri <> Val(TexteNbGroupTri.Text) Then
      '   oldNbGroupesDeTri = NbGroupesDeTri
      '   NbGroupesDeTri = Val(TexteNbGroupTri.Text)
      '   'redimension des group de tri
      '    ReDim Preserve SymboleGroupeDeTri(-1 To NbGroupesDeTri)
      '    ReDim Preserve NbMesSelect(-1 To NbGroupesDeTri)
      '    ReDim Preserve Affichage(-1 To NbGroupesDeTri)
      '    ReDim Preserve CouleurGroupe(-1 To NbGroupesDeTri)
      '          For tmp = 1 To NbGroupesDeTri
      '             SymboleGroupeDeTri(tmp) = Chr$(tmp + 96)
      '          Next
      '      CouleurGroupe(-1) = fond_fenetre
      '      CouleurGroupe(0) = texte_FENETRE
      '      GroupTri.CommentaireGroupe(0) = "Groupe permanent"
      '      Affichage(0) = True
      '         If oldNbGroupesDeTri < NbGroupesDeTri Then
      '            For tmp = oldNbGroupesDeTri To NbGroupesDeTri
      '               CouleurGroupe(tmp) = -rouge * (modulo(tmp, 8) > 4) - bleu * (modulo(tmp, 4) > 2) - vert * (modulo(tmp, 2) > 1)
      '            Next
      '            For tmp = max(4, oldNbGroupesDeTri) To NbGroupesDeTri
      '               On Error Resume Next
      '               dummy = GroupTri!CocheProjectionGroupe(tmp).Top
      '               If Err Then 'on loade tout
      '                  Err = 0
      '                  Load GroupTri!CocheProjectionGroupe(tmp)
      '                  Load GroupTri!EtiqSymboleGroupe(tmp)
      '                  Load GroupTri!CommentaireGroupe(tmp)
      '                  Load GroupTri!PopulationGroupe(tmp)
      '
      '                  GroupTri!CocheProjectionGroupe(tmp).Visible = True
      '                  GroupTri!EtiqSymboleGroupe(tmp).Visible = True
      '                  GroupTri!CommentaireGroupe(tmp).Visible = True
      '                  GroupTri!PopulationGroupe(tmp).Visible = True
      '
      '                  GroupTri!CocheProjectionGroupe(tmp).Top = GroupTri!CocheProjectionGroupe(tmp - 1).Top + (GroupTri!CocheProjectionGroupe(tmp - 1).Top - GroupTri!CocheProjectionGroupe(tmp - 2).Top)
      '                  GroupTri!EtiqSymboleGroupe(tmp).Top = GroupTri!EtiqSymboleGroupe(tmp - 1).Top + (GroupTri!EtiqSymboleGroupe(tmp - 2).Top - GroupTri!EtiqSymboleGroupe(tmp - 1).Top)
      '                  GroupTri!CommentaireGroupe(tmp).Top = GroupTri!CommentaireGroupe(tmp - 1).Top + (GroupTri!CommentaireGroupe(tmp - 2).Top - GroupTri!CommentaireGroupe(tmp - 1).Top)
      '                  GroupTri!PopulationGroupe(tmp).Top = GroupTri!PopulationGroupe(tmp - 1).Top + (GroupTri!PopulationGroupe(tmp - 2).Top - GroupTri!PopulationGroupe(tmp - 1).Top)
      '
      '                  GroupTri!CocheProjectionGroupe(tmp).Left = GroupTri!CocheProjectionGroupe(tmp - 1).Left
      '                  GroupTri!EtiqSymboleGroupe(tmp).Left = GroupTri!EtiqSymboleGroupe(tmp - 1).Left
      '                  GroupTri!CommentaireGroupe(tmp).Left = GroupTri!CommentaireGroupe(tmp - 1).Left
      '                  GroupTri!PopulationGroupe(tmp).Left = GroupTri!PopulationGroupe(tmp - 1).Left
      '               End If
      '            Next
      '         End If
      '   GroupTri.Height = GroupTri!CommentaireGroupe(NbGroupesDeTri).Height + GroupTri!CommentaireGroupe(NbGroupesDeTri).Top + HauteurBarreTitre + 30
      '   changé = True
      'End If
      If changé Then
         MetàJourListeGroupe
         RedessinStereo St!Stereo
         changé = False
      End If
 If SystemLow() Then Unload Me
 screen.MousePointer = defaut
Exit Sub
Traite_Erreurs2:
   If Erreurs(Err, "Boîte_options / Commande_Ok_Click") Then Resume Next
End Sub

Sub Commande_X_Click ()
   Forme_X.FillColor = getcolor("Dièdres droits: allongement", Forme_X.FillColor)
   Commande_Ok.SetFocus
End Sub

Sub Commande_Z_Click ()
   Forme_Z.FillColor = getcolor("Dièdres droits: raccourcissement", Forme_Z.FillColor)
   Commande_Ok.SetFocus
End Sub

Sub Défilement_Diamètre_Change ()
   On Error GoTo Traite_Erreurs3:
   If flag Then Exit Sub 'chargement de la boîte d'options
   Diamètre.Text = Str$(Défilement_Diamètre.Value / 10)
Exit Sub
Traite_Erreurs3:
   If Erreurs(Err, "Boîte_options / Défilement_Diamètre_Change") Then Resume Next
End Sub

Sub Défilement_Diamètre_Scroll ()
   On Error GoTo Traite_Erreurs6:
   If flag Then Exit Sub 'chargement de la boîte d'options
   Diamètre.Text = Str$(Défilement_Diamètre.Value / 10)
Exit Sub
Traite_Erreurs6:
   If Erreurs(Err, "Boîte_options / Défilement_Diamètre_Scroll") Then Resume Next
End Sub

Sub Diamètre_Change ()
   On Error GoTo Traite_Erreurs4:
   If Val(Diamètre.Text) < 1 Then Beep: Diamètre.Text = "1"
   If Val(Diamètre.Text) > 20 Then Beep: Diamètre.Text = "20"
   Défilement_Diamètre.Value = CInt(Val(Diamètre.Text) * 10)
Exit Sub
Traite_Erreurs4:
   If Erreurs(Err, "Boîte_options / Diamètre_Change") Then Resume Next
End Sub

Sub Diamètre_GotFocus ()
   Diamètre.SelStart = 1
   Diamètre.SelLength = Len(Diamètre.Text)
End Sub

Sub Form_Activate ()
   On Error GoTo Traite_Erreurs5:
   prompt "Options générales"
   Forme_Z.FillColor = CouleurDdroits_Z
   Forme_X.FillColor = CouleurDdroits_X
      If flag = flag_D_Droits Then
         cadre2.Visible = False
         cadre4.Visible = False
         Forme_Groupes.Visible = False
         Liste_GroupTri.Enabled = False
         Liste_GroupTri.Visible = False
         Coche_Affich_F_non_Sélec.Visible = False
         Coche_Barre_Outils.Visible = False
         etiquette8.Enabled = False
         etiquette8.Visible = False
         etiquette10.Visible = False
         Commande_Groupes.Enabled = False
         Commande_Groupes.Visible = False
         cadre3.Top = 10
         Caption = "Couleurs"
         Commande_Ok.Left = 100
         Commande_Ok.Top = cadre3.Top + cadre3.Height + 50
         Commande_annule.Top = Commande_Ok.Top
         Commande_annule.Left = Commande_Ok.Left + Commande_Ok.Width + 100
         Height = Commande_Ok.Top + 700
         Width = cadre3.Width + 200
      Else
         Coche_Barre_Outils.Value = -MDI!barre_outils.Visible'Abs(MDI!menu_Barre_Outils.Checked)
         Coche_barre_etat.Value = -MDI!Image2.Visible
         
         ReDim CouleurGroupeTmp(NbGroupesDeTri)   As Long
         hemiinf.Value = (Hémisphère = -1)
         hemisup.Value = (Hémisphère = 1)
         Option_Impression_Bitmap.Value = (Impression_vectorielle = False)
         Option_Impression_Vectorielle.Value = (Impression_vectorielle = True)
         flagi = flag
         flag = True
         Diamètre.Text = Format$(DiamStereo, " ##.##")
            Liste_GroupTri.Clear
               For tmp = 1 To NbGroupesDeTri
                  Liste_GroupTri.AddItem SymboleGroupeDeTri(tmp)
                  CouleurGroupeTmp(tmp) = CouleurGroupe(tmp)
               Next
            Liste_GroupTri.ListIndex = 0
         'TexteNbGroupTri.Text = Str$(NbGroupesDeTri)
         
         '***
            Combo_separateur.Clear
            Combo_separateur.AddItem "tab"
            'Combo_separateur.AddItem ","
            Combo_separateur.AddItem "espace"
            'Combo_separateur.AddItem ";"
            Select Case Separateur_champs$
               Case Chr$(9)
                  Combo_separateur.ListIndex = 0
               Case Else
                  Combo_separateur.ListIndex = 1
            End Select
         '***
         
         flag = flagi
         Option_manuel_F9.Value = Retracage_Manuel
         Option_auto_F9.Value = Not (Option_manuel_F9.Value)
         Coche_bkp.Value = -Fichiers_Bkp
         coche_nfiles.Value = -Open_nFichiers
         Coche_param.Value = -Fichiers_Param
         Coche_Affich_F_non_Sélec.Value = -Aff_F_non_Sélec
         Coche_signale_erreurs.Value = -Signale_Erreurs
         Coche_Tracage_Progressif.Value = -Tracage_Progressif
         text_teta.Text = teta * 180 / pi
         Coche_Affich_F_Stations_Icones.Value = -Affich_F_Stations_Icones
      End If
   screen.MousePointer = defaut
Exit Sub
Traite_Erreurs5:
   If Erreurs(Err, "Boîte_options / Form_Activate") Then Resume Next
End Sub

Sub Form_Load ()
   centerform Me
End Sub

Sub Form_Unload (Cancel As Integer)
      prompt ""
End Sub

Sub Liste_GroupTri_Click ()
   Forme_Groupes.FillColor = CouleurGroupeTmp(Liste_GroupTri.ListIndex + 1)
End Sub

Sub text_teta_Change ()
   On Error GoTo Traite_Erreurs10:
   If Val(text_teta.Text) = 0 Then Beep: text_teta.Text = "30"
   If Val(text_teta.Text) < 1 Then Beep: text_teta.Text = "1"
   If Val(text_teta.Text) > 89 Then Beep: text_teta.Text = "89"
Exit Sub
Traite_Erreurs10:
   If Erreurs(Err, "Boîte_options / text_teta_Change") Then Resume Next
End Sub

