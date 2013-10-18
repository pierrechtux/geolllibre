VERSION 2.00
Begin Form MetaStereo 
   Caption         =   "Méta Stéréo"
   ClientHeight    =   2940
   ClientLeft      =   1095
   ClientTop       =   1485
   ClientWidth     =   3000
   Height          =   3345
   Left            =   1035
   LinkTopic       =   "Form1"
   MDIChild        =   -1  'True
   ScaleHeight     =   2940
   ScaleWidth      =   3000
   Top             =   1140
   Width           =   3120
   Begin PictureBox bmp 
      AutoRedraw      =   -1  'True
      Enabled         =   0   'False
      Height          =   3015
      Left            =   3450
      MousePointer    =   1  'Arrow
      ScaleHeight     =   2.307
      ScaleLeft       =   -1.4
      ScaleMode       =   0  'User
      ScaleTop        =   1.4
      ScaleWidth      =   1.873
      TabIndex        =   2
      Top             =   0
      Visible         =   0   'False
      Width           =   3015
   End
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
      Begin Label EtiquetteInfo 
         AutoSize        =   -1  'True
         BorderStyle     =   1  'Fixed Single
         DragIcon        =   METASTER.FRX:0000
         Height          =   225
         Left            =   90
         MousePointer    =   1  'Arrow
         TabIndex        =   1
         Top             =   0
         Visible         =   0   'False
         Width           =   1290
         WordWrap        =   -1  'True
      End
      Begin Shape rectangle 
         BorderColor     =   &H000000FF&
         BorderStyle     =   3  'Dot
         FillColor       =   &H00C0C0FF&
         Height          =   1065
         Left            =   630
         Top             =   840
         Visible         =   0   'False
         Width           =   1170
      End
   End
   Begin Image bmp_image 
      Height          =   2580
      Left            =   1950
      Picture         =   METASTER.FRX:0302
      Stretch         =   -1  'True
      Top             =   0
      Visible         =   0   'False
      Width           =   3195
   End
End
