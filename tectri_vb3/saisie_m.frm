VERSION 2.00
Begin Form Saisie_Mesure 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Saisie d'une mesure de faille"
   ClientHeight    =   3195
   ClientLeft      =   165
   ClientTop       =   1575
   ClientWidth     =   4845
   ClipControls    =   0   'False
   Height          =   3600
   Left            =   105
   LinkMode        =   1  'Source
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3195
   ScaleWidth      =   4845
   Top             =   1230
   Width           =   4965
   Begin TextBox plonge_ligne 
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   285
      Left            =   4125
      TabIndex        =   31
      Top             =   1275
      Width           =   615
   End
   Begin TextBox azi_ligne 
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   285
      Left            =   2475
      TabIndex        =   30
      Top             =   1275
      Width           =   615
   End
   Begin TextBox Texte_Comm_Site 
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   285
      Left            =   1950
      MaxLength       =   30
      TabIndex        =   25
      Top             =   315
      Width           =   2745
   End
   Begin CommandButton precedente 
      Caption         =   "&<"
      Height          =   255
      Left            =   1785
      TabIndex        =   10
      Top             =   2625
      Width           =   495
   End
   Begin CommandButton annule 
      Cancel          =   -1  'True
      Caption         =   "&annuler"
      Height          =   330
      Left            =   735
      TabIndex        =   12
      Top             =   2625
      Width           =   750
   End
   Begin ComboBox ListeModifiable3 
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   300
      Left            =   1740
      TabIndex        =   23
      Text            =   "ListeModifiable1"
      Top             =   945
      Visible         =   0   'False
      Width           =   645
   End
   Begin ComboBox ListeModifiable2 
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   300
      Left            =   1740
      TabIndex        =   22
      Text            =   "ListeModifiable1"
      Top             =   1575
      Visible         =   0   'False
      Width           =   645
   End
   Begin ComboBox ListeModifiable1 
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   300
      Left            =   1740
      TabIndex        =   21
      Text            =   "ListeModifiable1"
      Top             =   1890
      Visible         =   0   'False
      Width           =   645
   End
   Begin CommandButton OK 
      Caption         =   "&ok"
      Default         =   -1  'True
      Height          =   330
      Left            =   105
      TabIndex        =   11
      Top             =   2625
      Width           =   540
   End
   Begin CommandButton suivante 
      Caption         =   "&>"
      Height          =   255
      Left            =   2415
      TabIndex        =   9
      Top             =   2625
      Width           =   495
   End
   Begin TextBox commentaire 
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   285
      Left            =   1110
      TabIndex        =   7
      Top             =   2205
      Width           =   3585
   End
   Begin TextBox jeu 
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   285
      Left            =   1110
      TabIndex        =   6
      Top             =   1890
      Width           =   615
   End
   Begin ComboBox Liste_GroupTri 
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   300
      Left            =   4200
      Style           =   2  'Dropdown List
      TabIndex        =   8
      Top             =   2520
      Width           =   540
   End
   Begin TextBox dirpitch 
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   285
      Left            =   1110
      TabIndex        =   5
      Top             =   1575
      Width           =   615
   End
   Begin TextBox pitch 
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   285
      Left            =   1110
      TabIndex        =   4
      Top             =   1260
      Width           =   615
   End
   Begin TextBox dirpd 
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   285
      Left            =   1110
      TabIndex        =   3
      Top             =   945
      Width           =   615
   End
   Begin TextBox pd 
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   285
      Left            =   1110
      TabIndex        =   2
      Top             =   630
      Width           =   615
   End
   Begin TextBox azi 
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   285
      Left            =   1110
      TabIndex        =   1
      Top             =   315
      Width           =   615
   End
   Begin ComboBox NatureObjet 
      Height          =   300
      Left            =   6300
      TabIndex        =   20
      Text            =   "Nature de l'objet"
      Top             =   735
      Visible         =   0   'False
      Width           =   1935
   End
   Begin ComboBox MethMesure 
      Enabled         =   0   'False
      Height          =   300
      Left            =   5985
      TabIndex        =   19
      Text            =   "Méthode de mesure"
      Top             =   1155
      Visible         =   0   'False
      Width           =   2175
   End
   Begin Label Label2 
      Caption         =   "Direction"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   195
      Left            =   1800
      TabIndex        =   29
      Top             =   1275
      Width           =   615
   End
   Begin Label Label1 
      Caption         =   "Plongement"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   195
      Left            =   3225
      TabIndex        =   28
      Top             =   1275
      Width           =   915
   End
   Begin Label Label_Numero 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      BorderStyle     =   1  'Fixed Single
      Caption         =   "1/1"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   225
      Left            =   150
      TabIndex        =   27
      Top             =   0
      Width           =   885
   End
   Begin Label Etiquette4 
      Caption         =   "Commentaire du site:"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   195
      Left            =   2265
      TabIndex        =   26
      Top             =   105
      Width           =   2010
   End
   Begin Label Etiquette9 
      Caption         =   "Quadrant"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   195
      Left            =   105
      TabIndex        =   24
      Top             =   1575
      Width           =   1125
   End
   Begin Label Etiquette2 
      Caption         =   "Commentaire"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   195
      Left            =   105
      TabIndex        =   14
      Top             =   2205
      Width           =   1125
   End
   Begin Label Etiquette3 
      Caption         =   "Jeu"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   195
      Left            =   105
      TabIndex        =   15
      Top             =   1890
      Width           =   1125
   End
   Begin Label Etiquette8 
      Caption         =   "Classement:"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   330
      Left            =   3255
      TabIndex        =   13
      Top             =   2520
      Width           =   1065
   End
   Begin Label Etiquette5 
      Caption         =   "Pitch"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   195
      Left            =   105
      TabIndex        =   16
      Top             =   1260
      Width           =   1125
   End
   Begin Label Etiquette6 
      Caption         =   "Quadrant"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   195
      Left            =   105
      TabIndex        =   17
      Top             =   945
      Width           =   1125
   End
   Begin Label Etiquette7 
      Caption         =   "Pendage"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   195
      Left            =   105
      TabIndex        =   18
      Top             =   630
      Width           =   1125
   End
   Begin Label Etiquette1 
      Caption         =   "Direction"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   195
      Left            =   105
      TabIndex        =   0
      Top             =   315
      Width           =   1125
   End
End
Dim Modifiee()
Dim imax

Sub annule_Click ()
   If annule.Enabled = False Then GoTo out:
   SCREEN.MousePointer = 11
         Unload Saisie_Mesure
out:
   SCREEN.MousePointer = defaut
End Sub

Sub azi_Change ()
   If Err Then Exit Sub
   azi.Text = UCase$(azi.Text)
   azi.SelStart = Len(azi.Text)
   If Len(azi.Text) > 3 Then azi.Text = Right$(azi.Text, 3)
   On Error Resume Next
   If CSng(azi.Text) > 180 Then
      If Err = 0 Then
         Beep: azi.Text = "180"
      Else
         Beep: azi.Text = "": Err = 0
      End If
   End If
   Modifiee(i) = True
End Sub

Sub azi_GotFocus ()
   prompt "Direction du plan de faille ; tab pour passer au champ suivant."
   azi.SelStart = 0
   azi.SelLength = Len(azi.Text)
End Sub

Sub azi_ligne_Change ()
   flagi = flag
   flag = True

End Sub

Sub commentaire_Change ()
   If Err Then Exit Sub
   Modifiee(i) = True
End Sub

Sub commentaire_GotFocus ()
   prompt "Commentaire libre ; tab pour passer au champ suivant."
   Commentaire.SelStart = 0
   Commentaire.SelLength = Len(Commentaire.Text)
End Sub

Sub dirpd_Change ()
   If Err Then Exit Sub
   Err = 1
   DirPd.Text = UCase$(DirPd.Text)
   DirPd.SelStart = Len(DirPd.Text)
   If Len(DirPd.Text) > 1 Then DirPd.Text = Right$(DirPd.Text, 1)
   On Error Resume Next
   Err = 1
   If DirPd.Text <> "N" And DirPd.Text <> "S" And DirPd.Text <> "E" And DirPd.Text <> "W" Then Beep: DirPd.Text = ""
   'vient de checke_mesure
   If (azi < 45 Or azi > 135) And (UCase$(DirPd) = "N" Or UCase$(DirPd) = "S") Then Beep: DirPd.Text = ""
   If (azi > 45 And azi < 135) And (UCase$(DirPd) = "W" Or UCase$(DirPd) = "E") Then Beep: DirPd.Text = ""
   
   If Err > 1 Then Beep: DirPd.Text = "": Err = 0
   Err = 0
   Modifiee(i) = True
End Sub

Sub dirpd_GotFocus ()
   prompt "Quadrant du pendage du plan de faille ; tab pour passer au champ suivant."
   DirPd.SelStart = 0
   DirPd.SelLength = Len(DirPd.Text)
End Sub

Sub dirpitch_Change ()
   If Err Then Exit Sub
   Err = 1
   dirpitch.Text = UCase$(dirpitch.Text)
   dirpitch.SelStart = Len(dirpitch.Text)
   If Len(dirpitch.Text) > 1 Then dirpitch.Text = Right$(dirpitch.Text, 1)
   On Error Resume Next
   Err = 1
   If dirpitch.Text <> "N" And dirpitch.Text <> "S" And dirpitch.Text <> "E" And dirpitch.Text <> "W" Then Beep: dirpitch.Text = ""
   'vient de checke_mesure
   If ((UCase$(DirPd) = "W" Or UCase$(DirPd) = "E") And (UCase$(dirpitch) = "W" Or UCase$(dirpitch) = "E")) Or ((UCase$(DirPd) = "N" Or UCase$(DirPd) = "S") And (UCase$(dirpitch) = "N" Or UCase$(dirpitch) = "S")) Then Beep: dirpitch.Text = ""

   If Err > 1 Then Beep: dirpitch.Text = "": Err = 0
   Err = 0
   Modifiee(i) = True
End Sub

Sub dirpitch_GotFocus ()
   prompt "Quadrant du pitch du mouvement du plan de faille ; tab pour passer au champ suivant."
   dirpitch.SelStart = 0
   dirpitch.SelLength = Len(dirpitch.Text)
End Sub

Sub Display_Faille ()
   Err = 1
      azi = Site(ns).Faille(i).azi
      Pd = Site(ns).Faille(i).Pd
      DirPd = Site(ns).Faille(i).DirPd
      pitch = Site(ns).Faille(i).pitch
      dirpitch = Site(ns).Faille(i).dirpi
      jeu = Site(ns).Faille(i).jeu
      Commentaire = Site(ns).Faille(i).Commentaire
      Liste_GroupTri.ListIndex = Site(ns).Faille(i).GroupeTri
   Err = 0
End Sub

Sub Form_Activate ()
   On Error GoTo Traite_Erreurs1:
   Label_Numero = Str$(i) + " / " + Str$(imax)
   Me.Caption = Site(ns).NomFichier '+ " : saisie de la mesure n°" + Str$(i)
   Texte_Comm_Site.Text = Site(ns).Situation
   ReDim Modifiee(max(i, imax))
      If Not (i > Site(ns).NbMes) Then
         'mesure déjà entrée
         Display_Faille
      End If
      azi.SetFocus
   imax = max(i, Site(ns).NbMes)
   SCREEN.MousePointer = defaut
Exit Sub
Traite_Erreurs1:
   If Erreurs(Err, "Saisie_Mesure / Form_Activate") Then Resume Next
End Sub

Sub Form_KeyDown (KeyCode As Integer, Shift As Integer)
   Select Case KeyCode
      Case TOUCHE_HAUT
         SendKeys "+{TAB}", True
      Case TOUCHE_BAS
         SendKeys "{TAB}", True
      Case Else
   End Select
End Sub

Sub Form_Load ()
   On Error GoTo Traite_Erreurs2:
   centerform Me
   'loader les groupes de tri dans la drop down list
      If Liste_GroupTri.ListCount <> NbGroupesDeTri Then
         Liste_GroupTri.Clear
            For tmp = 0 To NbGroupesDeTri
               Liste_GroupTri.AddItem SymboleGroupeDeTri(tmp)
            Next
         Liste_GroupTri.ListIndex = 0
      End If
   keypreview = True
   On Error Resume Next
Exit Sub
Traite_Erreurs2:
   If Erreurs(Err, "Saisie_Mesure / Form_Load") Then Resume Next
End Sub

Sub Form_Paint ()
   Form_Activate
End Sub

Sub jeu_Change ()
   If Err Then Exit Sub
   Err = 1
   jeu.Text = UCase$(jeu.Text)
   jeu.SelStart = Len(jeu.Text)
   If Len(jeu.Text) > 1 Then jeu.Text = Right$(jeu.Text, 1)
   On Error Resume Next
   Err = 1
   If jeu.Text <> "N" And jeu.Text <> "I" And jeu.Text <> "D" And jeu.Text <> "S" Then Beep: jeu.Text = ""
   If Err > 1 Then Beep: jeu.Text = "": Err = 0
   Err = 0
   Modifiee(i) = True
End Sub

Sub jeu_GotFocus ()
   prompt "Jeu de la faille ; tab pour passer au champ suivant."
   jeu.SelStart = 0
   jeu.SelLength = Len(jeu.Text)
End Sub

Sub Liste_GroupTri_Change ()
   Modifiee(i) = True
End Sub

Sub Liste_GroupTri_GotFocus ()
   prompt "Classement de la faille ; tab pour passer au champ suivant."
End Sub

Sub ok_Click ()
   On Error GoTo Traite_Erreurs3:
   SCREEN.MousePointer = 11
   icourant = i
   imax = max(i, imax)
   imax = max(imax, Site(ns).NbMes)
   ReDim Preserve Modifiee(max(i, imax))
      Nb_F_modif = 0
         For k = 1 To imax
            Nb_F_modif = Nb_F_modif + Modifiee(k)
         Next
      If Nb_F_modif = 0 Then annule_Click: Exit Sub
      For i = 1 To imax
         If Not (Not (Saisie_Mesure.annule.Enabled) And icourant <> i) Then
            If Modifiee(i) Or i > Site(ns).NbMes Then
                  If Entre_faille_courante(i, azi, Pd, DirPd, pitch, dirpitch, jeu, Commentaire.Text) = True Then
                     If Not (Saisie_Mesure.annule.Enabled) Then Exit For
                  Else
                     Label_Numero = Str$(i) + " / " + Str$(imax)
                     Me.Caption = frm_Station(ns).Caption '+ " : saisie de la mesure n°" + Str$(i)
                     If i > Site(ns).NbMes Then Display_Faille
                     azi.SetFocus
                     SCREEN.MousePointer = defaut
                     Exit Sub
                  End If
            End If
         End If
      Next
      For ii = 1 To imax
         If Modifiee(ii) Then If Site(ns).dirty <> True Then Site(ns).dirty = True: Exit For
      Next
   Site(ns).Situation = Texte_Comm_Site.Text
   Site(ns).NbMes = imax
   'Unload Saisie_mesure
   'If Saisie_Mesure.suivante.Enabled Then
   Saisie_Mesure.Hide
   If SystemLow() Then Unload Me
   SCREEN.MousePointer = defaut
Exit Sub
Traite_Erreurs3:
   If Erreurs(Err, "Saisie_Mesure / ok_Click") Then Resume Next
End Sub

Sub pd_Change ()
   If Err Then Exit Sub
   Pd.Text = UCase$(Pd.Text)
   Pd.SelStart = Len(Pd.Text)
   If Len(Pd.Text) > 2 Then Pd.Text = Right$(Pd.Text, 2)
   On Error Resume Next
   If CSng(Pd.Text) > 90 Then
      If Err = 0 Then
         Beep: Pd.Text = "90"
      Else
         Beep: Pd.Text = "": Err = 0
      End If
   End If
   Modifiee(i) = True
End Sub

Sub pd_GotFocus ()
   prompt "Pendage du plan de faille ; tab pour passer au champ suivant."
   Pd.SelStart = 0
   Pd.SelLength = Len(Pd.Text)
End Sub

Sub pitch_Change ()
   If Err Then Exit Sub
   pitch.Text = UCase$(pitch.Text)
   pitch.SelStart = Len(pitch.Text)
   If Len(pitch.Text) > 2 Then pitch.Text = Right$(pitch.Text, 2)
   On Error Resume Next
   If CSng(pitch.Text) > 90 Then
      If Err = 0 Then
         Beep: pitch.Text = "90"
      Else
         Beep: pitch.Text = "": Err = 0
      End If
   End If
   Modifiee(i) = True
End Sub

Sub pitch_GotFocus ()
   prompt "Pitch du vecteur mouvement de la faille ; tab pour passer au champ suivant."
   pitch.SelStart = 0
   pitch.SelLength = Len(pitch.Text)
End Sub

Sub precedente_Click ()
   On Error GoTo Traite_Erreurs4:
   If i <= 1 Then Beep:  Exit Sub
   SCREEN.MousePointer = 11
      If Modifiee(i) Then 'Or i > Site(ns).NbMes Then
         If Not (Entre_faille_courante(i, azi, Pd, DirPd, pitch, dirpitch, jeu, Commentaire.Text)) Then SCREEN.MousePointer = defaut: Exit Sub
         Modifiee(i) = False
      End If
         imax = max(i, imax)
         imax = max(imax, Site(ns).NbMes)
         i = i - 1
         Label_Numero = Str$(i) + " / " + Str$(imax)
         Me.Caption = frm_Station(ns).Caption '+ ": saisie de la mesure n°" + Str$(i)
      'End If
      If Not (i > Site(ns).NbMes) Then
         'mesure déjà entrée
         Display_Faille
      End If
   azi.SetFocus
   ReDim Preserve Modifiee(max(i, imax))
   SCREEN.MousePointer = defaut
Exit Sub
Traite_Erreurs4:
   If Erreurs(Err, "Saisie_Mesure / precedente_Click") Then Resume Next
End Sub

Sub precedente_GotFocus ()
   prompt "Passe à la faille précédente ; tab pour passer au champ suivant."
End Sub

Sub suivante_Click ()
   On Error GoTo Traite_Erreurs5:
   If i > imax Then Beep: Exit Sub
   SCREEN.MousePointer = 11
      If Modifiee(i) Then 'Or i > Site(ns).NbMes Then
         If Not (Entre_faille_courante(i, azi, Pd, DirPd, pitch, dirpitch, jeu, Commentaire.Text)) Then SCREEN.MousePointer = defaut: Exit Sub
         Modifiee(i) = False
      End If
         imax = max(i, imax)
         imax = max(imax, Site(ns).NbMes)
         i = i + 1
         imax = max(i, imax)
         Label_Numero = Str$(i) + " / " + Str$(imax)
         'clear champs
         Display_Faille
         Me.Caption = frm_Station(ns).Caption '+ " : saisie de la mesure n°" + Str$(i)
      If Not (i > Site(ns).NbMes) Then
         'mesure déjà entrée
         Display_Faille
      End If
   azi.SetFocus
   ReDim Preserve Modifiee(max(i, imax))
   SCREEN.MousePointer = defaut
Exit Sub
Traite_Erreurs5:
   If Erreurs(Err, "Saisie_Mesure / suivante_Click") Then Resume Next
End Sub

Sub suivante_GotFocus ()
   prompt "Passe à la faille suivante ; tab pour passer au champ suivant."
End Sub

