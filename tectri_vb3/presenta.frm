VERSION 2.00
Begin Form Presentation 
   BackColor       =   &H00FFFFFF&
   BorderStyle     =   3  'Fixed Double
   ClientHeight    =   6570
   ClientLeft      =   8805
   ClientTop       =   1980
   ClientWidth     =   4755
   ControlBox      =   0   'False
   Height          =   6975
   Icon            =   PRESENTA.FRX:0000
   Left            =   8745
   LinkMode        =   1  'Source
   LinkTopic       =   "Form3"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   Picture         =   PRESENTA.FRX:0302
   ScaleHeight     =   115.888
   ScaleMode       =   6  'Millimeter
   ScaleWidth      =   83.873
   Top             =   1635
   Width           =   4875
   Begin Frame Cadre_pass 
      Height          =   1140
      Left            =   375
      TabIndex        =   1
      Top             =   2250
      Visible         =   0   'False
      Width           =   3990
      Begin CommandButton annule 
         Cancel          =   -1  'True
         Caption         =   "annuler"
         Height          =   240
         Left            =   2475
         TabIndex        =   0
         Top             =   750
         Width           =   840
      End
      Begin CommandButton ok 
         Caption         =   "ok"
         Default         =   -1  'True
         Height          =   240
         Left            =   1575
         TabIndex        =   4
         Top             =   750
         Width           =   840
      End
      Begin TextBox password 
         Alignment       =   2  'Center
         FontBold        =   -1  'True
         FontItalic      =   0   'False
         FontName        =   "Courier New"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   390
         Left            =   1200
         PasswordChar    =   "_"
         TabIndex        =   3
         Top             =   300
         Width           =   2340
      End
      Begin Label Label1 
         BackStyle       =   0  'Transparent
         Caption         =   "Mot de passe:"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   465
         Left            =   75
         TabIndex        =   2
         Top             =   300
         Width           =   1440
      End
   End
   Begin Label Label2 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "                                                                IGAL"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   510
      Left            =   -75
      TabIndex        =   6
      Top             =   5025
      Width           =   2880
   End
   Begin Label Etiquette2 
      Alignment       =   2  'Center
      BackStyle       =   0  'Transparent
      Caption         =   "Copyrights © Pierre Chevalier   Version du 7/10/1995 => 5/6/2012"
      FontBold        =   0   'False
      FontItalic      =   -1  'True
      FontName        =   "Arial"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   435
      Left            =   2040
      TabIndex        =   5
      Top             =   4875
      Width           =   2715
   End
End

Sub annule_Click ()
   End
End Sub

Sub Form_Activate ()
   On Error GoTo Traite_Erreurs1:
   If windowstate = reduit Then Exit Sub
   Refresh
      '*********** modifs pour démo / password o/n **********
      password_protection = False
      If password_protection Then
         Cadre_pass.Visible = True  'pour non password, mettre en commentaire
         password.SetFocus          'pour non password, mettre en commentaire
      Else
         Load MDI                  'pour non password, mettre en code
      End If
      '******************************************************
Exit Sub
Traite_Erreurs1:
   If Erreurs(Err, "Presentation / Form_Activate") Then Resume Next
End Sub

Sub Form_GotFocus ()
   Form_Activate
End Sub

Sub Form_Load ()
   'lambda = 1000 '06/06/2012: facteur d'échelle entre méta et bmp stéréo => apparemment, pas employé => commenté
   On Error GoTo Traite_Erreurs2:
   '***Detecte si il y a une instance de tectri qui runne deja;
   '***au besoin, ca devrait lancer ouvrestation; marche pas...
      If app.PrevInstance Then
         If Command$ <> "" Then
            '*****ouvrir...
            '*******ifo faire ça avec un sendkeys...
            'f$ = Command$
            'LitStation f$
            'RedessinStereo St!Stereo
            'prompt  ""
            'screen.MousePointer = defaut
         Else
            '*****donne focus à la première session
            Title$ = "TecTri"
             X% = CheckUnique(Title$)
                If X% = 0 Then
                    End
                End If
             MDI.Caption = Title$
         End If
         End
      End If
   centerform Me
   Me.Show
   If windowstate = reduit Then Exit Sub:  Else Caption = ""
      '******** 22/05/2003**********************
      '/*ôté, ça emmerde plutot qu'autre chose*/
      'If Not ((GetVersion() And &HFFFF&) < &HA03) Then
      '   '***ôté pour voir si, ainsi, on peut tourner sous win 3.0***
      '   SetWindowPos Me.hWnd, -1, 0, 0, 0, 0, &H10 Or &H40
      'End If
      '*****************************************
Exit Sub
Traite_Erreurs2:
   If Erreurs(Err, "Presentation / Form_Load") Then Resume Next
End Sub

Sub Form_MouseMove (Button As Integer, Shift As Integer, X As Single, Y As Single)
   Form_Activate
End Sub

Sub Form_Resize ()
   If flag Then Exit Sub
   If windowstate = reduit Then Caption = "TecTri": Exit Sub
   flag = True
   Caption = ""
   wflag = False
End Sub

Sub ok_Click ()
   On Error GoTo Traite_Erreurs3:
   Static nbessais
      If password.Text = "Pedro Andres" Then
         Cadre_pass.Visible = False
         Load MDI
      Else
         Beep: Beep: Beep
         If nbessais > 1 Then annule_Click
         nbessais = nbessais + 1
         password.Text = ""
      End If
Exit Sub
Traite_Erreurs3:
   If Erreurs(Err, "Presentation / ok_Click") Then Resume Next
End Sub

