VERSION 2.00
Begin Form ErreurPointage 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Pointage d'une faille"
   ClientHeight    =   2415
   ClientLeft      =   5280
   ClientTop       =   255
   ClientWidth     =   3810
   Height          =   2820
   Left            =   5220
   LinkTopic       =   "Feuille1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2415
   ScaleWidth      =   3810
   Top             =   -90
   Width           =   3930
   Begin CommandButton Commande_trace 
      Caption         =   "&z"
      Height          =   300
      Index           =   6
      Left            =   1785
      TabIndex        =   7
      Top             =   1890
      Width           =   1400
   End
   Begin CommandButton Commande_trace 
      Caption         =   "&y"
      Height          =   300
      Index           =   5
      Left            =   1785
      TabIndex        =   6
      Top             =   1575
      Width           =   1400
   End
   Begin CommandButton Commande_trace 
      Caption         =   "&x"
      Height          =   300
      Index           =   4
      Left            =   1785
      TabIndex        =   5
      Top             =   1260
      Width           =   1400
   End
   Begin CommandButton Commande_trace 
      Caption         =   "traces &polaires"
      Height          =   300
      Index           =   3
      Left            =   1785
      TabIndex        =   4
      Top             =   945
      Width           =   1400
   End
   Begin CommandButton Commande_trace 
      Caption         =   "&stries"
      Height          =   300
      Index           =   2
      Left            =   1785
      TabIndex        =   3
      Top             =   630
      Width           =   1400
   End
   Begin CommandButton annuler 
      Cancel          =   -1  'True
      Caption         =   "&Annuler"
      Height          =   330
      Left            =   105
      TabIndex        =   2
      Top             =   1995
      Width           =   1275
   End
   Begin Label Etiquette2 
      Caption         =   "Projection des:"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   375
      Left            =   210
      TabIndex        =   1
      Top             =   630
      Width           =   1305
   End
   Begin Label msg 
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   615
      Left            =   210
      TabIndex        =   0
      Top             =   0
      Width           =   3435
   End
End

Sub annuler_Click ()
   On Error GoTo Traite_Erreurs1:
   flag = -1
   Unload Me
Exit Sub
Traite_Erreurs1:
   If Erreurs(Err, "ErreurPointage / annuler_Click") Then Resume Next
End Sub

Sub Commande_trace_Click (Index As Integer)
   On Error GoTo Traite_Erreurs2:
   Toggle (Index)
   Unload Me
Exit Sub
Traite_Erreurs2:
   If Erreurs(Err, "ErreurPointage / Commande_trace_Click") Then Resume Next
End Sub

Sub Form_Load ()
   On Error GoTo Traite_Erreurs3:
   centerform Me
   screen.MousePointer = defaut
Exit Sub
Traite_Erreurs3:
   If Erreurs(Err, "ErreurPointage / Form_Load") Then Resume Next
End Sub

Sub Form_Unload (Cancel As Integer)
   screen.MousePointer = 11
End Sub

