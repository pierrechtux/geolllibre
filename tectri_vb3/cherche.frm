VERSION 2.00
Begin Form Cherche_txt 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Sélection de failles par recherche de caractères"
   ClientHeight    =   2040
   ClientLeft      =   330
   ClientTop       =   1260
   ClientWidth     =   5505
   Height          =   2445
   Left            =   270
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2040
   ScaleWidth      =   5505
   Top             =   915
   Width           =   5625
   Begin CheckBox Check_casse 
      Caption         =   "respect majuscules/minuscules"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   315
      Left            =   2700
      TabIndex        =   8
      Top             =   525
      Width           =   2640
   End
   Begin ComboBox Liste_GroupTri_to 
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   300
      Left            =   2700
      Sorted          =   -1  'True
      Style           =   2  'Dropdown List
      TabIndex        =   3
      Top             =   1575
      Width           =   1290
   End
   Begin ComboBox Liste_GroupTri_from 
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   300
      Left            =   2700
      Sorted          =   -1  'True
      Style           =   2  'Dropdown List
      TabIndex        =   2
      Top             =   1050
      Width           =   1290
   End
   Begin CommandButton Command_annule 
      Cancel          =   -1  'True
      Caption         =   "Annuler"
      Height          =   315
      Left            =   4350
      TabIndex        =   5
      Top             =   1575
      Width           =   915
   End
   Begin CommandButton Command_ok 
      Caption         =   "OK"
      Height          =   315
      Left            =   4350
      TabIndex        =   4
      Top             =   1125
      Width           =   915
   End
   Begin TextBox Text_to_find 
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "Arial"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   315
      Left            =   3075
      TabIndex        =   1
      Top             =   150
      Width           =   2265
   End
   Begin Label Label3 
      Alignment       =   1  'Right Justify
      Caption         =   "failles correspondantes à trier dans le groupe :"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "Arial"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   540
      Left            =   525
      TabIndex        =   7
      Top             =   1425
      Width           =   1905
   End
   Begin Label Label2 
      Alignment       =   1  'Right Justify
      Caption         =   "dans les failles du groupe :"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "Arial"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   315
      Left            =   300
      TabIndex        =   6
      Top             =   1050
      Width           =   2130
   End
   Begin Label Label1 
      Alignment       =   1  'Right Justify
      Caption         =   "Chaîne de caractères à rechercher :"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "Arial"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   315
      Left            =   150
      TabIndex        =   0
      Top             =   150
      Width           =   2790
   End
End
Sub Command_annule_Click ()
   Unload Me
End Sub

Sub Command_ok_Click ()
'*** si groupe_from=groupe_to, no vale
   If Liste_GroupTri_from.ListIndex = Liste_GroupTri_to.ListIndex Then
      TheMessage$ = "Erreur : tentative de tri de failles sans changement de groupe."
      TheStyle = 48
      MsgBox TheMessage$, TheStyle
      Exit Sub
   End If
'*** si chaine="", no vale
   If Text_to_find.Text = "" Then
      TheMessage$ = "Erreur : texte à rechercher absent."
      TheStyle = 48
      MsgBox TheMessage$, TheStyle, TheTitle$
      Text_to_find.SetFocus
      Exit Sub
   End If
   

   'InputBox("Chaîne de caractères à identifier:", "Sélection de failles")
   screen.MousePointer = 11
   nsavant = ns
   iavant = i
   For ns = 1 To NbStations
      If Not (Site(ns).deleted) Then
         If Not (Affich_F_Stations_Icones = False And frm_Station(ns).WindowState = REDUIT) Then
            For i = 1 To Site(ns).NbMes
               Mesure = Site(ns).Faille(i).azi + Sep$ + Site(ns).Faille(i).Pd + Sep$ + Site(ns).Faille(i).DirPd + Sep$ + Site(ns).Faille(i).pitch + Sep$ + Site(ns).Faille(i).dirpi + Sep$ + Site(ns).Faille(i).jeu + Sep$ + Site(ns).Faille(i).Commentaire
               If Liste_GroupTri_from.ListIndex = 0 Or Site(ns).Faille(i).GroupeTri = Liste_GroupTri_from.ListIndex - 1 Then
                  If InStr(1, Mesure, Text_to_find.Text, Abs(Not (-Check_casse.Value))) Then
                     SélectionMesure (Liste_GroupTri_to.ListIndex)
                     'Tracage St!Stereo
                  End If
               End If
            Next
         End If
      End If
   Next
   ns = nsavant
   i = iavant
   MetàJourListeGroupe
   F9
   screen.MousePointer = defaut
   Me.Hide
   If SystemLow() = True Then Unload Me
End Sub

Sub Form_Activate ()
   prompt "Sélection de failles d'après recherche de caractères"
   Text_to_find.SetFocus
   Command_ok.Default = True
   screen.MousePointer = defaut
End Sub

Sub Form_Load ()
   On Error GoTo Traite_Erreurs5:
   centerform Me
   Liste_GroupTri_from.Clear
   Liste_GroupTri_from.AddItem "(toutes failles)"
      For tmp = 0 To NbGroupesDeTri
         Liste_GroupTri_from.AddItem SymboleGroupeDeTri(tmp)
      Next
'   Liste_GroupTri_from.AddItem "(failles non triées)"
   Liste_GroupTri_from.ListIndex = 0
   Liste_GroupTri_to.Clear
      For tmp = 0 To NbGroupesDeTri
         Liste_GroupTri_to.AddItem SymboleGroupeDeTri(tmp)
      Next
   Liste_GroupTri_to.ListIndex = 1
Exit Sub
Traite_Erreurs5:
   If Erreurs(Err, "Cherche_txt / Form_Load") Then Resume Next
End Sub

