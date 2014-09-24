VERSION 2.00
Begin MDIForm MDI 
   Caption         =   "TecTri"
   ClientHeight    =   4605
   ClientLeft      =   2685
   ClientTop       =   2190
   ClientWidth     =   6645
   Height          =   5295
   Icon            =   MDI.FRX:0000
   Left            =   2625
   LinkMode        =   1  'Source
   LinkTopic       =   "Form1"
   Top             =   1560
   Width           =   6765
   Begin PictureBox Image2 
      Align           =   2  'Align Bottom
      BackColor       =   &H00C0C0C0&
      Height          =   405
      Left            =   0
      ScaleHeight     =   375
      ScaleMode       =   0  'User
      ScaleWidth      =   6615
      TabIndex        =   3
      Top             =   4200
      Width           =   6645
      Begin SSPanel lblStatus 
         Alignment       =   1  'Left Justify - MIDDLE
         BackColor       =   &H00C0C0C0&
         BevelOuter      =   1  'Inset
         Caption         =   "Initialisation..."
         Font3D          =   0  'None
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   240
         Left            =   75
         TabIndex        =   4
         Top             =   75
         Width           =   6615
      End
      Begin CommonDialog CMDialog 
         Left            =   6300
         Top             =   0
      End
      Begin Timer Minuterie 
         Interval        =   10000
         Left            =   5880
         Top             =   0
      End
   End
   Begin PictureBox barre_outils 
      Align           =   1  'Align Top
      BackColor       =   &H8000000F&
      Height          =   615
      Left            =   0
      ScaleHeight     =   585
      ScaleWidth      =   6615
      TabIndex        =   0
      Top             =   0
      Width           =   6645
      Begin SSCheck Check3D_trace 
         Caption         =   "y"
         Font3D          =   3  'Inset w/light shading
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   240
         Index           =   5
         Left            =   3525
         TabIndex        =   10
         Top             =   75
         Width           =   390
      End
      Begin SSCheck Check3D_trace 
         Caption         =   "z"
         Font3D          =   3  'Inset w/light shading
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   240
         Index           =   6
         Left            =   3900
         TabIndex        =   11
         Top             =   75
         Width           =   390
      End
      Begin SSCheck Check3D_trace 
         Caption         =   "x"
         Font3D          =   3  'Inset w/light shading
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   240
         Index           =   4
         Left            =   3150
         TabIndex        =   16
         Top             =   75
         Width           =   390
      End
      Begin SSCheck Check3D_trace 
         Caption         =   "polaire"
         Font3D          =   3  'Inset w/light shading
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   240
         Index           =   3
         Left            =   1725
         TabIndex        =   15
         Top             =   225
         Width           =   765
      End
      Begin SSCheck Check3D_trace 
         Caption         =   "strie"
         Font3D          =   3  'Inset w/light shading
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   240
         Index           =   2
         Left            =   2475
         TabIndex        =   14
         Top             =   0
         Width           =   615
      End
      Begin SSCheck Check3D_trace 
         Caption         =   "pmvt"
         Font3D          =   3  'Inset w/light shading
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   240
         Index           =   7
         Left            =   2475
         TabIndex        =   13
         Top             =   225
         Width           =   690
      End
      Begin SSCheck Check3D_trace 
         Caption         =   "cyclo"
         Font3D          =   3  'Inset w/light shading
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   240
         Index           =   1
         Left            =   1725
         TabIndex        =   12
         Top             =   0
         Width           =   690
      End
      Begin SSCommand Command3D_save 
         AutoSize        =   2  'Adjust Button Size To Picture
         Font3D          =   3  'Inset w/light shading
         Height          =   345
         Left            =   825
         Picture         =   MDI.FRX:0302
         TabIndex        =   9
         Top             =   75
         Width           =   360
      End
      Begin SSCommand Command3D_open 
         AutoSize        =   2  'Adjust Button Size To Picture
         Font3D          =   3  'Inset w/light shading
         Height          =   345
         Left            =   450
         Picture         =   MDI.FRX:03F4
         TabIndex        =   8
         Top             =   75
         Width           =   360
      End
      Begin SSCommand Command3D_new 
         AutoSize        =   2  'Adjust Button Size To Picture
         Font3D          =   3  'Inset w/light shading
         Height          =   345
         Left            =   75
         Picture         =   MDI.FRX:04E6
         TabIndex        =   7
         Top             =   75
         Width           =   360
      End
      Begin CommandButton CommandeFocStri 
         Caption         =   "Foc.Stries"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   255
         Left            =   5250
         TabIndex        =   6
         Top             =   0
         Width           =   1275
      End
      Begin CommandButton CommandeDDroits 
         Caption         =   "Dièdres Droits"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   255
         Left            =   5250
         TabIndex        =   5
         Top             =   300
         Width           =   1290
      End
      Begin PictureBox HémisphèreIco 
         AutoSize        =   -1  'True
         BackColor       =   &H00C0C0C0&
         BorderStyle     =   0  'None
         Height          =   480
         Index           =   1
         Left            =   5100
         Picture         =   MDI.FRX:05D8
         ScaleHeight     =   480
         ScaleWidth      =   480
         TabIndex        =   1
         Top             =   780
         Visible         =   0   'False
         Width           =   480
      End
      Begin PictureBox HémisphèreIco 
         AutoRedraw      =   -1  'True
         AutoSize        =   -1  'True
         BackColor       =   &H00C0C0C0&
         BorderStyle     =   0  'None
         Height          =   480
         Index           =   2
         Left            =   5100
         Picture         =   MDI.FRX:08DA
         ScaleHeight     =   480
         ScaleWidth      =   480
         TabIndex        =   2
         Top             =   780
         Visible         =   0   'False
         Width           =   480
      End
      Begin Image hemisphere 
         Height          =   480
         Left            =   4500
         MousePointer    =   1  'Arrow
         Top             =   75
         Width           =   480
      End
      Begin Image desPasteButtonDn 
         Height          =   330
         Left            =   9840
         Picture         =   MDI.FRX:0BDC
         Top             =   480
         Visible         =   0   'False
         Width           =   375
      End
      Begin Image desPasteButtonUp 
         Height          =   330
         Left            =   10200
         Picture         =   MDI.FRX:0DB6
         Top             =   480
         Visible         =   0   'False
         Width           =   375
      End
   End
   Begin Menu menu_Fichier 
      Caption         =   "&Fichier"
      Begin Menu menu_nouvelle_station 
         Caption         =   "&Nouvelle station"
      End
      Begin Menu menu_ChargeStation 
         Caption         =   "&Ouvrir station..."
      End
      Begin Menu menu_enregistrer 
         Caption         =   "&Enregistrer"
      End
      Begin Menu mEnregistreAs 
         Caption         =   "Enregistrer &sous..."
      End
      Begin Menu menu_enregistrer_tout 
         Caption         =   "Enre&gistrer tout"
      End
      Begin Menu menu_ferme_station 
         Caption         =   "&Fermer station"
      End
      Begin Menu m_fermetout 
         Caption         =   "To&ut fermer"
      End
      Begin Menu m_jjjjj 
         Caption         =   "-"
      End
      Begin Menu menu_stéréo 
         Caption         =   "Sté&réo"
         Begin Menu mEnregistreBmp 
            Caption         =   "&Enregistrer le stéréo en bitmap..."
         End
         Begin Menu menu_imprimer_stereo 
            Caption         =   "&Imprimer..."
            Enabled         =   0   'False
         End
      End
      Begin Menu menu_SauverSelection 
         Caption         =   "Enregistrer &sélection en cours"
         Enabled         =   0   'False
         Visible         =   0   'False
      End
      Begin Menu zzzzzzii 
         Caption         =   "&Tenseurs"
         Begin Menu menu_FichierTratr 
            Caption         =   "Créer fichier pour &Tratr"
         End
         Begin Menu Calcultenseur 
            Caption         =   "&Calcul de tenseur (programme Mercier)"
         End
      End
      Begin Menu zz 
         Caption         =   "-"
      End
      Begin Menu menu_imprimer 
         Caption         =   "&Imprimer..."
      End
      Begin Menu menu_config_prn 
         Caption         =   "Configuration de l'im&primante"
      End
      Begin Menu zzzz 
         Caption         =   "-"
      End
      Begin Menu menu_Quitter 
         Caption         =   "&Quitter"
      End
      Begin Menu m_zzzzzzzzzzzz 
         Caption         =   "-"
      End
      Begin Menu mnuRecentFile 
         Index           =   1
      End
      Begin Menu mnuRecentFile 
         Index           =   2
      End
      Begin Menu mnuRecentFile 
         Index           =   3
      End
      Begin Menu mnuRecentFile 
         Index           =   4
      End
      Begin Menu mnuRecentFile 
         Index           =   5
      End
      Begin Menu mnuRecentFile 
         Index           =   6
      End
      Begin Menu mnuRecentFile 
         Index           =   7
      End
      Begin Menu mnuRecentFile 
         Index           =   8
      End
   End
   Begin Menu menu_edition 
      Caption         =   "&Edition"
      Begin Menu menu_entree_mesure 
         Caption         =   "&Formulaire ..."
      End
      Begin Menu zzz 
         Caption         =   "-"
      End
      Begin Menu menu_annuler 
         Caption         =   "&Annuler"
         Visible         =   0   'False
      End
      Begin Menu menu_copier 
         Caption         =   "&Copier"
      End
      Begin Menu menu_coller 
         Caption         =   "C&oller"
      End
      Begin Menu zzzzzzzzz 
         Caption         =   "-"
      End
      Begin Menu menu_copie_stereo 
         Caption         =   "Copier &stéréo vers presse-papiers"
      End
      Begin Menu menu_colle_stereo 
         Caption         =   "Coller &presse-papier sur stéréo"
      End
   End
   Begin Menu menu_selection 
      Caption         =   "&Sélection"
      Begin Menu menu_selabcd 
         Caption         =   "&Groupes a,b,c,d"
         Begin Menu menu_class_mesure 
            Caption         =   "Classement dans &a"
            Index           =   1
         End
         Begin Menu menu_class_mesure 
            Caption         =   "Classement dans &b"
            Index           =   2
         End
         Begin Menu menu_class_mesure 
            Caption         =   "Classement dans &c"
            Index           =   3
         End
         Begin Menu menu_class_mesure 
            Caption         =   "Classement dans &d"
            Index           =   4
         End
         Begin Menu menu_class_mesure 
            Caption         =   "Classement dans &e"
            Index           =   5
         End
         Begin Menu menu_class_mesure 
            Caption         =   "Classement dans &f"
            Index           =   6
         End
         Begin Menu menu_class_mesure 
            Caption         =   "Classement dans &g"
            Index           =   7
         End
         Begin Menu menu_class_mesure 
            Caption         =   "Classement dans &h"
            Index           =   8
         End
         Begin Menu menu_class_mesure 
            Caption         =   "Classement dans &i"
            Index           =   9
         End
         Begin Menu menu_class_mesure 
            Caption         =   "Classement dans &j"
            Index           =   10
         End
         Begin Menu menu_class_mesure 
            Caption         =   "Classement dans &k"
            Index           =   11
         End
         Begin Menu menu_class_mesure 
            Caption         =   "Classement dans &l"
            Index           =   12
         End
         Begin Menu menu_class_mesure 
            Caption         =   "Classement dans &m"
            Index           =   13
         End
         Begin Menu menu_class_mesure 
            Caption         =   "Classement dans &n"
            Index           =   14
         End
         Begin Menu menu_class_mesure 
            Caption         =   "Classement dans &o"
            Index           =   15
         End
         Begin Menu menu_class_mesure 
            Caption         =   "Classement dans &p"
            Index           =   16
         End
         Begin Menu menu_class_mesure 
            Caption         =   "Classement dans &q"
            Index           =   17
         End
         Begin Menu menu_class_mesure 
            Caption         =   "Classement dans &r"
            Index           =   18
         End
         Begin Menu menu_class_mesure 
            Caption         =   "Classement dans &s"
            Index           =   19
         End
         Begin Menu menu_class_mesure 
            Caption         =   "Classement dans &t"
            Index           =   20
         End
         Begin Menu menu_class_mesure 
            Caption         =   "Classement dans &u"
            Index           =   21
         End
         Begin Menu menu_class_mesure 
            Caption         =   "Classement dans &v"
            Index           =   22
         End
         Begin Menu menu_class_mesure 
            Caption         =   "Classement dans &w"
            Index           =   23
         End
         Begin Menu menu_class_mesure 
            Caption         =   "Classement dans &x"
            Index           =   24
         End
         Begin Menu menu_class_mesure 
            Caption         =   "Classement dans &y"
            Index           =   25
         End
         Begin Menu menu_class_mesure 
            Caption         =   "Classement dans &z"
            Index           =   26
         End
         Begin Menu zzzzzzzz 
            Caption         =   "-"
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe *"
            Checked         =   -1  'True
            Index           =   0
            Visible         =   0   'False
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe a"
            Index           =   1
            Shortcut        =   {F1}
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe b"
            Index           =   2
            Shortcut        =   {F2}
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe c"
            Index           =   3
            Shortcut        =   {F3}
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe d"
            Index           =   4
            Shortcut        =   {F4}
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe e"
            Index           =   5
            Shortcut        =   {F5}
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe f"
            Index           =   6
            Shortcut        =   {F6}
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe g"
            Index           =   7
            Shortcut        =   {F7}
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe h"
            Index           =   8
            Shortcut        =   {F8}
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe i"
            Index           =   9
            Shortcut        =   {F9}
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe j"
            Index           =   10
            Shortcut        =   {F11}
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe k"
            Index           =   11
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe l"
            Index           =   12
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe m"
            Index           =   13
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe n"
            Index           =   14
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe o"
            Index           =   15
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe p"
            Index           =   16
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe q"
            Index           =   17
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe r"
            Index           =   18
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe s"
            Index           =   19
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe t"
            Index           =   20
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe u"
            Index           =   21
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe v"
            Index           =   22
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe w"
            Index           =   23
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe x"
            Index           =   24
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe y"
            Index           =   25
         End
         Begin Menu menu_projettegroupe 
            Caption         =   "Projection groupe z"
            Index           =   26
         End
      End
      Begin Menu zzzzzz 
         Caption         =   "-"
      End
      Begin Menu menu_class_mesure0 
         Caption         =   "Classement dans groupe &*"
      End
      Begin Menu menu_declass_mesure 
         Caption         =   "&Déselection"
      End
      Begin Menu zzzzzzzzzzzzz 
         Caption         =   "-"
      End
      Begin Menu seljeux 
         Caption         =   "Sélection de mesures par &jeux"
         Begin Menu menu_seljeu_dn 
            Caption         =   "de&xtres-normaux"
         End
         Begin Menu menu_seljeu_di 
            Caption         =   "d&extres-inverses"
         End
         Begin Menu menu_seljeu_sn 
            Caption         =   "sénestres-norm&aux"
         End
         Begin Menu menu_seljeu_si 
            Caption         =   "sénes&tres-inverses"
         End
         Begin Menu menu_seljeu_n 
            Caption         =   "&normaux"
         End
         Begin Menu menu_seljeu_i 
            Caption         =   "&inverses"
         End
         Begin Menu menu_seljeu_D 
            Caption         =   "&dextres"
         End
         Begin Menu menu_seljeu_s 
            Caption         =   "&sénestres"
         End
      End
      Begin Menu zzzzz 
         Caption         =   "-"
      End
      Begin Menu menu_recherchctaires 
         Caption         =   "&Recherche d'après commentaires..."
      End
   End
   Begin Menu menu_traces 
      Caption         =   "&Traces"
      Begin Menu menu_trace 
         Caption         =   "Trace &cyclographique"
         Checked         =   -1  'True
         Index           =   1
      End
      Begin Menu menu_trace 
         Caption         =   "&Strie"
         Checked         =   -1  'True
         Index           =   2
      End
      Begin Menu menu_trace 
         Caption         =   "Trace &polaire"
         Index           =   3
      End
      Begin Menu menu_trace 
         Caption         =   "Axe &X néoformé"
         Index           =   4
      End
      Begin Menu menu_trace 
         Caption         =   "Axe &Y néoformé"
         Index           =   5
      End
      Begin Menu menu_trace 
         Caption         =   "Axe &Z néoformé"
         Index           =   6
      End
      Begin Menu menu_trace 
         Caption         =   "Plan de &mouvement"
         Index           =   7
      End
      Begin Menu menu_trace 
         Caption         =   "Demi-Pmvt en &allgt"
         Index           =   8
      End
      Begin Menu menu_trace 
         Caption         =   "Demi-Pmvt en &racct"
         Index           =   9
      End
      Begin Menu menu_trace 
         Caption         =   "Az&imut strie"
         Index           =   10
      End
      Begin Menu menu_trace 
         Caption         =   "Plan a&uxiliaire"
         Index           =   11
      End
      Begin Menu zzzzzzzzzzzz 
         Caption         =   "-"
      End
      Begin Menu menu_ddrts 
         Caption         =   "&Dièdres droits"
      End
      Begin Menu menu_focstri 
         Caption         =   "&Focalisations de stries"
      End
      Begin Menu zzzzzzzzzzzzzzz 
         Caption         =   "-"
         Visible         =   0   'False
      End
      Begin Menu menu_deba 
         Caption         =   "Dé&basculement..."
      End
      Begin Menu menu_rosaces 
         Caption         =   "&Rosaces"
         Enabled         =   0   'False
         Visible         =   0   'False
         Begin Menu menu_pasangul 
            Caption         =   "&Pas angulaire: ## "
         End
         Begin Menu menu_ros_faill 
            Caption         =   "&directions de failles"
         End
         Begin Menu menu_ros_azdip 
            Caption         =   "azimuts de vecteurs &dip"
         End
         Begin Menu menu_ros_azstri 
            Caption         =   "azimuts de &stries"
         End
         Begin Menu menu_ros_dn 
            Caption         =   "plans dextres-normaux"
         End
         Begin Menu menu_ros_di 
            Caption         =   "plans dextres-inverses"
         End
         Begin Menu menu_ros_sn 
            Caption         =   "plans sénestres-normaux"
         End
         Begin Menu menu_ros_si 
            Caption         =   "plans sénestres-inverses"
         End
         Begin Menu menu_ros_n 
            Caption         =   "plans normaux"
         End
         Begin Menu menu_ros_i 
            Caption         =   "plans inverses"
         End
         Begin Menu menu_ros_d 
            Caption         =   "plans dextres"
         End
         Begin Menu menu_ros_s 
            Caption         =   "plans sénestres"
         End
         Begin Menu menu_ros_couleur 
            Caption         =   "Coloration rosace"
         End
      End
   End
   Begin Menu menu_fenetre 
      Caption         =   "Fe&nêtre"
      WindowList      =   -1  'True
      Begin Menu menu_cascade 
         Caption         =   "&Cascade"
      End
      Begin Menu menu_mos_vert 
         Caption         =   "Mosaïque &verticale"
      End
      Begin Menu menu_mos_horiz 
         Caption         =   "Mosaïque &horizontale"
      End
      Begin Menu menu_arrg_ico 
         Caption         =   "&Arranger les icônes"
      End
   End
   Begin Menu menu_Options_titre 
      Caption         =   "&Options"
      Begin Menu menu_Options 
         Caption         =   "&Paramètres..."
      End
      Begin Menu menu_remkstereo 
         Caption         =   "&Retracer stéréo"
         Shortcut        =   {F12}
      End
      Begin Menu menu_clear_remkstereo 
         Caption         =   "&Effacer et retracer stéréo"
         Shortcut        =   ^{F9}
      End
      Begin Menu menu_trace_auto 
         Caption         =   "&Tracé automatique du stéréo"
      End
      Begin Menu menu_hémisphère 
         Caption         =   "Hémisphère s&up"
      End
      Begin Menu menu_diametre_stereo 
         Caption         =   "&Diamètre stéréo..."
      End
      Begin Menu menu_sauve_parametres 
         Caption         =   "Enregistrer &les paramètres"
         Checked         =   -1  'True
      End
   End
   Begin Menu mh 
      Caption         =   "&?"
      Enabled         =   0   'False
      Begin Menu m_help_Index 
         Caption         =   "&Index"
      End
      Begin Menu m_help_cherche 
         Caption         =   "C&hercher de l'aide sur..."
      End
      Begin Menu m_help_clavier 
         Caption         =   "&Clavier"
      End
      Begin Menu m_help_commandes 
         Caption         =   "C&ommandes"
      End
      Begin Menu zzzzzzzzzzz 
         Caption         =   "-"
      End
      Begin Menu m_about 
         Caption         =   "&A propos..."
      End
   End
End

Sub Calcultenseur_Click ()
    NonDisponible
    '!!!Envoi vers tratr/tentra, et récupération des calculs


'!!!Créer fichier pour tratr

'!!!Runner tratr (icônisé, ou en fenêtre: option)
 'si erreur de run, demander le répertoire de mercier&co

'!!!Runner tentra (icônisé, ou en fenêtre: option)
 'si erreur de run, demander le répertoire de mercier&co

'!!!Lire les fichiers temporaires créés (vérifier que c'est le bon par la date)

'!!!Projeter les résultats de calcul sur une copie du stéréo ourant sur une feuille à part (cf fostri), à recopier sur le stéréo principal si ok, et boutons pour retenter un calcul
'!!!loader tenseur.frm (trés similaire à focstri.frm)
End Sub

Sub Check3D_trace_Click (Index As Integer, Value As Integer)
   If flag <> False Then Exit Sub
   menu_trace_Click (Index)
End Sub

Sub Check3D_trace_MouseMove (Index As Integer, Button As Integer, Shift As Integer, X As Single, Y As Single)
   Select Case Index
      Case 1
	 msg$ = "Trace les traces cyclographiques des plans de failles sélectionnés"
      Case 2
	 msg$ = "Trace les stries des failles sélectionnées"
      Case 3
	 msg$ = "Trace les polaires des failles sélectionnées"
      Case 4
	 msg$ = "Trace les axes d'allongement des failles sélectionnées"
      Case 5
	 msg$ = "Trace les polaires des plans de mouvement des failles sélectionnées"
      Case 6
	 msg$ = "Trace les axes de raccourcissement des failles sélectionnées"
      Case 7
	 msg$ = "Trace les plans de mouvement des failles sélectionnées"
   End Select
   prompt msg$
End Sub

Sub Command3D_new_Click ()
    nouvelle_station
End Sub

Sub Command3D_new_MouseMove (Button As Integer, Shift As Integer, X As Single, Y As Single)
    prompt "Crée un nouveau fichier de mesures"
End Sub

Sub Command3D_open_Click ()
    menu_ChargeStation_Click
End Sub

Sub Command3D_open_MouseMove (Button As Integer, Shift As Integer, X As Single, Y As Single)
    prompt "Ouvre un fichier de mesures"
End Sub

Sub Command3D_save_Click ()
   screen.MousePointer = 11
   EnregistreLaStation ns
   screen.MousePointer = defaut
End Sub

Sub Command3D_save_MouseMove (Button As Integer, Shift As Integer, X As Single, Y As Single)
    On Error Resume Next
    prompt "Enregistre " & LCase$(Site(ns).NomFichier)
End Sub

Sub CommandeDDroits_Click ()
   menu_ddrts_Click
End Sub

Sub CommandeDDroits_MouseMove (Button As Integer, Shift As Integer, X As Single, Y As Single)
    prompt "Méthode des dièdres droits appliquée aux failles sélectionnées"
End Sub

Sub CommandeFocStri_Click ()
   menu_focstri_Click
End Sub

Sub CommandeFocStri_MouseMove (Button As Integer, Shift As Integer, X As Single, Y As Single)
    prompt "Méthode des focalisations de stries appliquée aux failles sélectionnées"
End Sub

Sub hemisphere_Click ()
    Hemisphere.Refresh
    menu_hémisphère_Click
End Sub

Sub hemisphere_MouseDown (Button As Integer, Shift As Integer, X As Single, Y As Single)
      Hemisphere.Picture = MDI!HémisphèreIco(1 / 2 * Hémisphère + 1.5).Picture
End Sub

Sub hemisphere_MouseMove (Button As Integer, Shift As Integer, X As Single, Y As Single)
   ' Si le bouton est activé, affiche le bitmap supérieur
    ' lorsque la souris glisse hors de la zone du bouton ;
    ' sinon affiche le bitmap supérieur.
    Select Case Button
    Case 1
	If X <= 0 Or X > Hemisphere.Width Or Y < 0 Or Y > Hemisphere.Height Then
	    If Hemisphere.Picture <> MDI!HémisphèreIco(-1 / 2 * Hémisphère + 1.5).Picture Then Hemisphere.Picture = MDI!HémisphèreIco(-1 / 2 * Hémisphère + 1.5).Picture
	Else
	    If Hemisphere.Picture <> MDI!HémisphèreIco(1 / 2 * Hémisphère + 1.5).Picture Then Hemisphere.Picture = MDI!HémisphèreIco(1 / 2 * Hémisphère + 1.5).Picture
	End If
    End Select
    prompt "Change l'hémisphère de projection"
End Sub

Sub hemisphere_MouseUp (Button As Integer, Shift As Integer, X As Single, Y As Single)
      If Hemisphere.Picture <> MDI!HémisphèreIco(-1 / 2 * Hémisphère + 1.5).Picture Then Hemisphere.Picture = MDI!HémisphèreIco(1 / 2 * Hémisphère + 1.5).Picture
End Sub

Sub m_about_Click ()
   flag = True
   '**** faire 1 petit écran de copyright, et tout, et tout...
End Sub

Sub m_fermetout_Click ()
   Ferme_Tout
End Sub

Sub MDIForm_Load ()
   On Error GoTo Traite_Erreurs1:
   'Demo
   screen.MousePointer = 11
   prompt "Initialisation..."
   MDI!lblStatus.Refresh
   LectureTectriIni
   Unload Presentation
   'rien = DoEvents()
   prompt "Initialisation..."
   MDI!lblStatus.Refresh
   screen.MousePointer = 11
   NbStations = 1'Evite erreur tableau.grille.rows
   'rien = DoEvents()
   St.Refresh
   DimensionneVariables'ments
   DimensionneObjets
   GroupTri.Refresh
'   Tableau.Refresh
   'rien = DoEvents()
   barre_outils.Refresh
      If Command$ <> "" Then
	 LitStation Command$
	 RedessinStereo St!Stereo
      End If
   'rien = DoEvents()
   St!Stereo.Tag = "stereo"
   Hémisphère = -(Hémisphère)'il est reinversé pdt definitionhemisphere
      rien = Retracage_Manuel
	 Retracage_Manuel = False
	 DéfinitionHémisphère St!Stereo
      Retracage_Manuel = rien
   flag = False
   AfficheListeGroupes
   screen.MousePointer = defaut
   prompt ""
Exit Sub
Traite_Erreurs1:
   If Erreurs(Err, "MDI / MDIForm_Load") Then Resume Next
End Sub

Sub MDIForm_QueryUnload (Cancel As Integer, UnloadMode As Integer)
   menu_quitter_Click
End Sub

Sub mEnregistreAs_Click ()
   EnregistreSous
   flag = False
End Sub

Sub mEnregistreBmp_Click ()
   On Error Resume Next
   MDI!CMDialog.DialogTitle = "Enregistrer le stéréogramme en bitmap"
   MDI!CMDialog.Filename = "stereo.bmp"
   MDI!CMDialog.DefaultExt = "bmp"
   MDI!CMDialog.Filter = "Fichiers bitmaps (*.bmp)|*.bmp|Tous fichiers (*.*)|*.*"
   MDI!CMDialog.Flags = &H2& Or &H4&
   MDI!CMDialog.CancelError = True
   MDI!CMDialog.Action = 2
      If Err = 0 Then
	 On Error GoTo Traite_Erreurs2:
	 f$ = MDI!CMDialog.Filename
	 SavePicture St!Stereo.Image, f$
	 CR$ = Chr$(13) + Chr$(10)
	 TheMessage$ = "Le fichier " & f$ & CR$ & "contient le stéréogramme au format bitmap." + CR$
	 TheStyle = 48
	 MsgBox TheMessage$, TheStyle
      End If
   flag = False
Exit Sub
Traite_Erreurs2:
   If Erreurs(Err, "MDI / mEnregistreBmp_Click") Then Resume Next
End Sub

Sub menu_arrg_ico_Click ()
   Arrange 3
End Sub

Sub menu_cascade_Click ()
      Proc_Cascade
End Sub

Sub menu_ChargeStation_Click ()
   On Error Resume Next
   MDI!CMDialog.DialogTitle = "TecTri: ouvrir"
   MDI!CMDialog.Filename = ""
   MDI!CMDialog.Filter = "Fichiers tectri (*.tec)|*.tec|Fichiers calculs (*. )|*. |Tous fichiers (*.*)|*.*"
   MDI!CMDialog.FilterIndex = 1
   MDI!CMDialog.Flags = &H200& Or &H1000& Or &H4&
   MDI!CMDialog.CancelError = True
   MDI!CMDialog.Action = 1
   If Err Then Exit Sub
   On Error GoTo Traite_Erreurs3:
   screen.MousePointer = 11
   liste_open$ = LCase$(MDI!CMDialog.Filename)
      Select Case InStr(liste_open$, " ")
	 Case False
	    LitStation liste_open$
	 Case Else ' on tente de lire plus d'un fichier
	    Rep$ = GetToken(liste_open$, " ")
	    precedent$ = Rep$
	       Do
		  f$ = GetToken$(Mid$(liste_open$, InStr(liste_open$, precedent$) + Len(precedent$) + 1), " ")
		  If f$ = "" Then Exit Do
		  precedent$ = f$
		  LitStation Rep$ & "\" & f$
	       Loop
      End Select
   RedessinStereo St!Stereo
   prompt ""
   screen.MousePointer = defaut
Exit Sub
Traite_Erreurs3:
   If Erreurs(Err, "MDI / menu_ChargeStation_Click") Then Resume Next
End Sub

Sub menu_class_mesure_Click (Index As Integer)
   selecfailles Me, Index + 64
End Sub

Sub menu_clear_remkstereo_Click ()
   CtrlF9
End Sub

Sub menu_colle_stereo_Click ()
   ColleStereo
End Sub

Sub menu_coller_Click ()
   ColleRange
End Sub

Sub menu_config_prn_Click ()
   Printer_Setup MDI
End Sub

Sub menu_copie_stereo_Click ()
   CopieStereo
End Sub

Sub menu_copier_Click ()
   CopieRange
End Sub

Sub menu_ddrts_Click ()
   ' If Boite_Diedres_droits!Stereo.Tag <> "chargé" Then
   '  Boite_Diedres_droits!Stereo.Tag = "chargé"
    'If Boite_Diedres_droits.WindowState <> normal Then Boite_Diedres_droits.WindowState = normal
    screen.MousePointer = 11
    flag = True
    Boite_Diedres_droits.Show 1
    flag = False
End Sub

Sub menu_deba_Click ()
   'Débasculement
   Debasculement.Show 1
End Sub

Sub menu_declass_mesure_Click ()
   SélectionMesure (-1)
End Sub

Sub menu_diametre_stereo_Click ()
   On Error Resume Next
   diam = InputBox("Diamètre du stéréogramme (cm)?", , DiamStereo)
      If diam = "" Then diam = 0
      If DiamStereo <> diam And diam <> 0 Then
	 DiamStereo = diam
	 chg_diam_stereo
      End If
End Sub

Sub menu_enregistrer_Click ()
   'Enregistrer station courante
   screen.MousePointer = 11
   EnregistreLaStation ns
   screen.MousePointer = defaut
End Sub

Sub menu_enregistrer_tout_Click ()
   EnregistreTout
End Sub

Sub menu_entree_mesure_Click ()
   If NbStations = 0 Then menu_nouvelle_station_Click: Exit Sub
   If ns = 0 Then ns = 1
   EntreeMesures
   RedessinStereo St!Stereo
End Sub

Sub menu_ferme_station_Click ()
   On Error Resume Next
   Unload frm_Station(ns)
   flag = 0
End Sub

Sub menu_FichierTratr_Click ()
   FichierTratr
End Sub

Sub menu_focstri_Click ()
   screen.MousePointer = 11
   TenseurFocStri.Show 1
End Sub

Sub menu_hémisphère_Click ()
    DéfinitionHémisphère St!Stereo
End Sub

Sub menu_imprimer_Click ()
   imprime
End Sub

Sub menu_mos_horiz_Click ()
   Proc_Tile_Horizontal
End Sub

Sub menu_mos_vert_Click ()
   Proc_Tile_Vertical
End Sub

Sub menu_nouvelle_station_Click ()
   nouvelle_station
End Sub

Sub menu_options_Click ()
   screen.MousePointer = 11
   Boîte_Options.Show 1
   flag = False
End Sub

Sub menu_projettegroupe_Click (Index As Integer)
 'GroupTri!CocheProjectionGroupe_Click Index
 If Index > 0 Then GroupTri!CocheProjectionGroupe(Index).Value = Abs(Not (menu_projettegroupe(Index).Checked))
 'GroupTri!CocheProjectionGroupe_Click (index)
End Sub

Sub menu_quitter_Click ()
   bye_bye
End Sub

Sub menu_recherchctaires_Click ()
'   cherche_comment
   screen.MousePointer = 11
   Cherche_txt.Show 1
End Sub

Sub menu_remkstereo_Click ()
   F9
End Sub

Sub menu_sauve_parametres_Click ()
   menu_sauve_parametres.Checked = Not (menu_sauve_parametres.Checked)
   a = writeprivateprofilestring("Options", "Sauvegarde paramètres", Str$(MDI!menu_sauve_parametres.Checked), "tectri.ini")
End Sub

Sub menu_seljeu_D_Click ()
   selecfailles_jeu "d"
End Sub

Sub menu_seljeu_di_Click ()
   selecfailles_jeu "di"
End Sub

Sub menu_seljeu_dn_Click ()
   selecfailles_jeu "dn"
End Sub

Sub menu_seljeu_i_Click ()
   selecfailles_jeu "i"
End Sub

Sub menu_seljeu_n_Click ()
   selecfailles_jeu "n"
End Sub

Sub menu_seljeu_s_Click ()
   selecfailles_jeu "s"
End Sub

Sub menu_seljeu_si_Click ()
   selecfailles_jeu "si"
End Sub

Sub menu_seljeu_sn_Click ()
   selecfailles_jeu "sn"
End Sub

Sub menu_trace_auto_Click ()
   Retracage_Manuel = Not (Retracage_Manuel)
   menu_trace_auto.Checked = Not (Retracage_Manuel)
   If Not (Retracage_Manuel) Then F9
End Sub

Sub menu_trace_Click (Index As Integer)
   Toggle (Index)
End Sub

Sub Minuterie_Timer ()
   If MDI!Minuterie.Interval = 200 Then   'on a laissé la souris appuyée sur la grille de data, pour draguer
      MDI!Minuterie.Interval = 10000
	 'Ctrl+clic: on "drag" la cellule vers les tris...
	 frm_Station(ns).Grille.Tag = ""
	    iavant = i
	       For i = frm_Station(ns).Grille.SelStartRow To Min(Int(frm_Station(ns).Grille.SelEndRow), frm_Station(ns).Grille.Rows - 2)'Site(ns).NbMes
		  frm_Station(ns).Grille.Tag = frm_Station(ns).Grille.Tag + Str$(ns) + Chr$(9) + Str$(i) + Chr$(10)
	       Next
	    i = iavant
	 frm_Station(ns).Grille.Drag
   End If
   If MDI!lblStatus.Caption = "Modification de la mesure" Then Exit Sub:   Else lblStatus.Caption = ""
End Sub

Sub mnuRecentFile_Click (Index As Integer)
   On Error GoTo Traite_Erreurs4:
   screen.MousePointer = 11
   LitStation (Right$(MDI!mnuRecentFile(Index).Caption, Len(MDI!mnuRecentFile(Index).Caption) - 3))
   ' Update recent files list for new notepad.
   GetRecentFiles
   RedessinStereo St!Stereo
   prompt ""
   screen.MousePointer = defaut
Exit Sub
Traite_Erreurs4:
   If Erreurs(Err, "MDI / mnuRecentFile_Click") Then Resume Next
End Sub

