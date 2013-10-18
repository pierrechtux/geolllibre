VERSION 2.00
Begin Form Presentation 
   BackColor       =   &H00FFFFFF&
   BorderStyle     =   3  'Fixed Double
   ClientHeight    =   6570
   ClientLeft      =   1395
   ClientTop       =   345
   ClientWidth     =   4755
   ControlBox      =   0   'False
   Height          =   6975
   Icon            =   0
   Left            =   1335
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   115.888
   ScaleMode       =   6  'Millimeter
   ScaleWidth      =   83.873
   Top             =   0
   Width           =   4875
End

Sub Form_Activate ()
   If windowstate = reduit Then Exit Sub
   screen.MousePointer = sablier
   Refresh
   Load MDI
End Sub

Sub Form_GotFocus ()
   Form_Activate
End Sub

Sub Form_Load ()
   '***Detecte si il y a une instance de tectri qui runne deja;
   '***au besoin, ca devrait lancer ouvrestation; marche pas...
      If app.PrevInstance Then
         If Command$ <> "" Then
            '*****ouvrir...
            '*******ifo faire ça avec un sendkeys...
            'f$ = Command$
            'LitStation f$
            'RedessinStereo St!Stereo
            'MDI!lblStatus.Caption = ""
            'screen.MousePointer = defaut
         Else
            '*****donne focus à la première session
         End If
         End
      End If
   centerform Me
   Me.Show
   If windowstate = reduit Then Exit Sub:  Else Caption = ""
   '***ôté pour voir si, ainsi, on peut tourner sous win 3.0***
   'SetWindowPos Me.hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE Or SWP_SHOWWINDOW
End Sub

Sub Form_Resize ()
   If flag Then Exit Sub
   If windowstate = reduit Then Caption = "TecTri": Exit Sub
   flag = True
   Caption = ""
   flag = False
End Sub

