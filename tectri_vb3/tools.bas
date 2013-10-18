'*** Routines diverses en VB ***     du grand livre VB
'*** autres routines diverses ajoutees ***

'*** Les 3 routines suivantes viennent de remline.bas de microsoft ***
'DECLARE FUNCTION GetToken$ (Search$, Delim$)
'DECLARE FUNCTION StrSpn% (InString$, Separator$)
'DECLARE FUNCTION StrBrk% (InString$, Separator$)

'  User Profile Routines
Declare Function GetProfileInt Lib "Kernel" (ByVal lpAppName As String, ByVal lpKeyName As String, ByVal nDefault As Integer) As Integer
Declare Function GetProfileString Lib "Kernel" (ByVal lpAppName As String, ByVal lpKeyName As String, ByVal lpDefault As String, ByVal lpReturnedString As String, ByVal nSize As Integer) As Integer
Declare Function GetAllProfileStrings Lib "Kernel" Alias "GetProfileString" (ByVal lpAppName As String, ByVal lpKeyNameNull As Long, ByVal lpDefault As String, ByVal lpReturnedString As String, ByVal nSize As Integer) As Integer
Declare Function WriteProfileString Lib "Kernel" (ByVal lpApplicationName As String, ByVal lpKeyName As String, ByVal lpString As String) As Integer
'on passe                                             nom fichier ini,
Declare Function getprivateprofileint Lib "Kernel" (ByVal lpApplicationName As String, ByVal lpKeyName As String, ByVal nDefault As Integer, ByVal lpFileName As String) As Integer
Declare Function getprivateprofilestring Lib "Kernel" (ByVal lpApplicationName As String, ByVal lpKeyName As String, ByVal lpDefault As String, ByVal lpReturnedString As String, ByVal nSize As Integer, ByVal lpFileName As String) As Integer
Declare Function writeprivateprofilestring Lib "Kernel" (ByVal lpApplicationName As String, ByVal lpKeyName As String, ByVal lpString As String, ByVal lplFileName As String) As Integer

'DefInt A-Z

Dim Shared Seps$
' Start of module-level program code
'  Token$ = GetToken$(InLin$, Seps$)'   Seps$ = " ,:=<>()" + CHR$(9)

'________________________________
' PSETUP.FRM contains the example for using PSETUP.DLL.
' This is Revision C.

' We use GetProfileString to retrieve the current Printer Driver's Name and output port (e.g. LPT1:)
'Declare Function GetProfileString Lib "KERNEL" (ByVal App$, ByVal Keyname$, ByVal DefaultVal$, ByVal RetBuf$, ByVal Size%) As Integer

' PSETUP.DLL has only one function: DoPrinterSetup which invokes the Windows 3.0 standard
' Printer Setup Dialog.  It expects three parameters: the calling form's hWnd handle,
' the name of the printer driver, and the ouptut port. The function returns true if the
' Printer Setup dialog was implemented and false if it wasn't, but in most cases you won't
' need to check the return value.
Declare Function DoPrinterSetup Lib "PSETUP.DLL" (ByVal hWnd%, ByVal DriverName$, ByVal PortName$) As Integer

' We use LoadLibrary to load PSETUP.DLL
Declare Function LoadLibrary Lib "KERNEL" (ByVal lpLibFileName$) As Integer

' The FreeLibrary procedure frees PSETUP.DLL
Declare Sub FreeLibrary Lib "KERNEL" (ByVal hLibModule%)

' Fonctions pour rappeler une session tournant déjà
Declare Function FindWindow% Lib "user" (ByVal lpClassName As Any, ByVal lpCaption As Any)
Declare Function ShowWindow% Lib "User" (ByVal Handle As Integer, ByVal Cmd As Integer)
Declare Function SFocus% Lib "User" Alias "SetFocus" (ByVal Handle As Integer)

Declare Function GetVersion Lib "Kernel" () As Long

Function ARCOS# (p)
   On Error GoTo Traite_Erreurs1:
   'DEF FNARCOS (p) = -pi * (p < 0) + (-1) ^ (p < 0) * ATN(SQR((1 - p ^ 2) / p ^ 2)):
   ARCOS = -pi * (p < 0) + (-1) ^ (p < 0) * Atn(Sqr((1 - p ^ 2) / p ^ 2))
Exit Function
Traite_Erreurs1:
   If Erreurs(Err, "Tools / Arcos#") Then Resume Next
End Function

Function ArcSin# (p)
   On Error GoTo Traite_Erreurs2:
   '  DEF FNARCSIN (p) = pi / 2 - FNARCOS(p)
   ArcSin = pi / 2 - ARCOS(p)
Exit Function
Traite_Erreurs2:
   If Erreurs(Err, "Tools / ArcSin#") Then Resume Next
End Function

Sub BackUp (ByVal fichier As String)
   On Error Resume Next 'On Error GoTo Traite_Erreurs3:
      bkpf$ = Left$(fichier, InStr(max(4, (Len(fichier) - 4)), fichier, ".")) + "bak"
      On Error Resume Next
      Name fichier As bkpf$
      If Err = 58 Then Kill bkpf$: Name fichier As bkpf$
Exit Sub
Traite_Erreurs3:
   If Erreurs(Err, "Tools / BackUp") Then Resume Next
End Sub

Sub centerform (Fo As Form)
'** Centrer la feuille Fo sur l'écran **
   Fo.Top = (screen.Height - Fo.Height) / 2
   Fo.Left = (screen.Width - Fo.Width) / 2
End Sub

Sub CenterFormChild (frmParent As MDIForm, frmChild As Form)
   On Error GoTo Traite_Erreurs4:
' Cette procédure centre une feuille fille sur une feuille mère.
' L'appel de cette routine charge la boîte de dialogue. Utilisez la méthode
' Show pour afficher la boîte de dialogue après avoir appelé cette routine (MyFrm.Show 1)

  ' Obtient le décalage à gauche
  l = frmParent.Left + ((frmParent.Width - frmChild.Width) / 2)
  If (l + frmChild.Width > screen.Width) Then
    l = screen.Width = frmChild.Width
  End If

  ' Obtient le décalage au sommet
  t = frmParent.Top + ((frmParent.Height - frmChild.Height) / 2)
  If (t + frmChild.Height > screen.Height) Then
    t = screen.Height - frmChild.Height
  End If

  ' Centre la feuille fille
  frmChild.Move l, t
Exit Sub
Traite_Erreurs4:
   If Erreurs(Err, "Tools / CenterFormChild") Then Resume Next
End Sub

Function Checke_Mesure (azi, pd, dirpd, pitch, dirpitch, jeu)
   On Error Resume Next  'On Error GoTo Traite_Erreurs5:
   'vérifie tout ça; ok: renvoie true
                    'pas bon: renvoie false
   If Not (IsNumeric(azi)) Then Erreur = True
   If Not (IsNumeric(pd)) Then Erreur = True
   If Not (IsNumeric(pitch)) Then Erreur = True
   If azi < 0 Or azi > 180 Then Erreur = True
   If pd < 0 Or pd > 90 Then Erreur = True
   If UCase$(dirpd) <> "W" And UCase$(dirpd) <> "E" And UCase$(dirpd) <> "N" And UCase$(dirpd) <> "S" Then Erreur = True
   If (azi < 45 Or azi > 135) And (UCase$(dirpd) = "N" Or UCase$(dirpd) = "S") Then Erreur = True
   If (azi > 45 And azi < 135) And (UCase$(dirpd) = "W" Or UCase$(dirpd) = "E") Then Erreur = True
   If (azi < 45 Or azi > 135) And (UCase$(dirpitch) = "E" Or UCase$(dirpitch) = "E") Then Erreur = True
   If (azi > 45 And azi < 135) And (UCase$(dirpitch) = "N" Or UCase$(dirpitch) = "S") Then Erreur = True
   'If ((UCase$(dirpd) = "W" Or UCase$(dirpd) = "E") And (UCase$(dirpitch) = "W" Or UCase$(dirpitch) = "E")) Or ((UCase$(dirpd) = "N" Or UCase$(dirpd) = "S") And (UCase$(dirpitch) = "N" Or UCase$(dirpitch) = "S")) Then erreur = True
   
   If pitch < 0 Or pitch > 90 Then Erreur = True
   If UCase$(dirpitch) <> "W" And UCase$(dirpitch) <> "E" And UCase$(dirpitch) <> "N" And UCase$(dirpitch) <> "S" Then Erreur = True
   'If (UCase$(dirpd) = "N" Or UCase$(dirpd) = "S") And (UCase$(dirpitch) = "N" Or UCase$(dirpitch) = "S") Then erreur = True
   If UCase$(jeu) <> "N" And UCase$(jeu) <> "I" And UCase$(jeu) <> "S" And UCase$(jeu) <> "D" Then Erreur = True
      If Err Or Erreur Then
         Beep
         Err = 0: Erreur = 0
            CR$ = Chr$(13) + Chr$(10)
            TheMessage$ = "Mesure de faille non valable:" + CR$
            TheMessage$ = TheMessage$ + Site(ns).NomFichier
            TheMessage$ = TheMessage$ + ", mesure n°" + Str$(i) + ":" + CR$
            TheMessage$ = TheMessage$ & azi & " " & pd & " " & dirpd & " " & pitch & " " & dirpitch & " " & jeu
            'TheMessage$ = TheMessage$ + Site(ns).Faille(i).mesure
            'TheMessage$ = TheMessage$ + "Afficher le formulaire pour éditer la mesure"
            TheStyle = 48
            TheTitle = "TecTri: erreur"
            MsgBox TheMessage$, TheStyle, TheTitle
         Checke_Mesure = False
      Else
         Checke_Mesure = True
      End If
Exit Function
Traite_Erreurs5:
   If Erreurs(Err, "Tools / Checke_Mesure") Then Resume Next
End Function

Function CheckUnique (FormName As String) As Integer
   Dim Handle As Integer
   Handle = FindWindow(0&, FormName)
      If Handle = 0 Then
         ' -1 is a true value.
         CheckUnique = -1
      Else
         x% = ShowWindow(Handle, 1)
         x% = SFocus(Handle)
         ' 0 is a false value.
         CheckUnique = 0
      End If
End Function

Sub creemetafile ()
   '***REMETTRE METASTEREO***hmf = CreateMetaFile("temp.wmf")
   If hmf = 0 Then Beep
End Sub

Function Erreurs (ByVal Erreur, ByVal objet As String)
   On Error Resume Next
   '***Traitement des erreurs
   'MSG
      If Signale_Erreurs = True Then
         CR$ = Chr$(13) + Chr$(10)
         TheMessage$ = "Une erreur est intervenue:" + CR$ + Error$(Erreur) + CR$
         TheMessage$ = TheMessage$ + "tentative de continuer en passant outre?" + CR$
         TheStyle = 20
         TheTitle$ = "Tectri: erreur"
         TheAnswer = MsgBox(TheMessage$, TheStyle, TheTitle$)
            'Ask pour un commentaire
            comment = InputBox$("Entrez un bref commentaire sur les conditions de l'erreur:" + CR$ + "(voir fichier erreurs.log)")
      End If
   'stockage dans fichier err's
   libre = FreeFile
      file_error$ = app.Path & "\" & "erreurs.log"
      msg_error$ = Now & Chr$(9) & Str$(Erreur) & Chr$(9) & Error$(Erreur) & Chr$(9) & objet & Chr$(9) & comment
      Open app.Path & "\" & "erreurs.log" For Append As libre
      If LOF(libre) = 0 Then Print #libre, "Date_heure" & Chr$(9) & "Code_erreur" & Chr$(9) & "Description" & Chr$(9) & "Objet" & Chr$(9) & "Commentaire"
      Print #libre, msg_error$
'        Print #libre, Now & Chr$(9) & Str$(Erreur) & Chr$(9) & Error$(Erreur) & Chr$(9) & objet & Chr$(9) & comment
'         Print #libre, "____________________________________________________"
 '        Print #libre, Now
  '       Print #libre, "Erreur " & Str$(Erreur) & " :" & Chr$(9) & Error$(Erreur)
   '      Print #libre, "Contexte :" & Chr$(9) & objet
    '     If Len(comment) Then Print #libre, "Commentaire :" & Chr$(9) & comment
         'Print #libre, "____________________________________________________"
         'Print #libre, "Erreur " & Str$(Erreur) & " :" & Chr$(9) & Error$(Erreur)
         'Print #libre, "Contexte :" & Chr$(9) & objet
         'If Len(comment) Then Print #libre, "Commentaire :" & Chr$(9) & comment
      Close #libre
   If TheAnswer = 6 Or Signale_Erreurs = False Then  'Answered Yes
      Erreurs = True
   Else     'Answered No
      Stop
   End If
End Function

Function getcolor (ByVal titre As String, ByVal color_defaut As Long) As Long
   On Error GoTo Traite_Erreurs6:
   screen.MousePointer = 11
   On Error Resume Next
   MDI!CMDialog.DialogTitle = titre
   MDI!CMDialog.Flags = &H1&
   MDI!CMDialog.Color = color_defaut
   MDI!CMDialog.CancelError = True
   MDI!CMDialog.Action = 3
   If Not (Err) Then getcolor = MDI!CMDialog.Color:  Else getcolor = color_defaut
   screen.MousePointer = defaut
  ' couleurs.Caption = titre
  ' couleurs!ScrollCoul(0).Value = (color_defaut And rouge) / rouge * 100
  ' couleurs!ScrollCoul(1).Value = (color_defaut And vert) / vert * 100
  ' couleurs!ScrollCoul(2).Value = (color_defaut And bleu) / bleu * 100
  ' couleurs!Picture1.BackColor = RGB(couleurs!ScrollCoul(0).Value * 255 / 100, couleurs!ScrollCoul(1).Value * 255 / 100, couleurs!ScrollCoul(2).Value * 255 / 100)
  ' flag = False
  ' screen.MousePointer = 11
  ' couleurs.Show 1
  '    If flag <> -1 Then
  '       getcolor = flag
  '    Else
  '       getcolor = color_defaut
  '    End If
  ' screen.MousePointer = defaut
Exit Function
Traite_Erreurs6:
   If Erreurs(Err, "Tools / getcolor") Then Resume Next
End Function

Static Function GetToken$ (Search$, Delim$)
   On Error GoTo Traite_Erreurs7:
'DEFINT A-Z
'
' GetToken$:
'  Extracts tokens from a string. A token is a word that is surrounded
'  by separators, such as spaces or commas. Tokens are extracted and
'  analyzed when parsing sentences or commands. To use the GetToken$
'  function, pass the string to be parsed on the first call, then pass
'  a null string on subsequent calls until the function returns a null
'  to indicate that the entire string has been parsed.
' Input:
'  Search$ = string to search
'  Delim$  = String of separators
' Output:
'  GetToken$ = next token
'

   ' Note that SaveStr$ and BegPos must be static from call to call
   ' (other variables are only static for efficiency).
   ' If first call, make a copy of the string
   If (Search$ <> "") Then
      BegPos = 1
      SaveStr$ = Search$
   End If
  
   ' Find the start of the next token
   NewPos = StrSpn(Mid$(SaveStr$, BegPos, Len(SaveStr$)), Delim$)
   If NewPos Then
      ' Set position to start of token
      BegPos = NewPos + BegPos - 1
   Else
      ' If no new token, quit and return null
      GetToken$ = ""
      Exit Function
   End If

   ' Find end of token
   NewPos = StrBrk(Mid$(SaveStr$, BegPos, Len(SaveStr$)), Delim$)
   If NewPos Then
      ' Set position to end of token
      NewPos = BegPos + NewPos - 1
   Else
      ' If no end of token, return set to end a value
      NewPos = Len(SaveStr$) + 1
   End If
   ' Cut token out of search string
   GetToken$ = Mid$(SaveStr$, BegPos, NewPos - BegPos)
   ' Set new starting position
   BegPos = NewPos
Exit Function
Traite_Erreurs7:
   If Erreurs(Err, "Tools / GetToken$") Then Resume Next
End Function

Function LargeurBordure ()
   Entry$ = Space$(255)
   Ret% = GetProfileString("WINDOWS", "BorderWidth", "(Aucune entrée)", Entry$, 255)
   LargeurBordure = Val(Left$(Entry$, Ret%))
End Function

Function max (donnee1, donnee2)
'Comme son nom l'indique, cette fonction fournit le plus
'gros des 2 nombres qu'on lui passe
   tmp = 0
   tmp = donnee1
   If donnee2 > donnee1 Then tmp = donnee2
   max = tmp
End Function

Function Min (donnee1, donnee2)
'Comme son nom l'indique, cette fonction fournit le plus
'petit des 2 nombres qu'on lui passe
   tmp = 0
   tmp = donnee1
   If donnee2 < donnee1 Then tmp = donnee2
   Min = tmp
End Function

Function modulo (ByVal angle As Double, ByVal pipi As Double)
    'Fonction mathématique modulo: application à la trigo: pipi vaut pi, ou 2*pi
    'Intérêt: cercles des traces cyclo
    While angle < 0
     angle = angle + pipi
    Wend
    While pipi < angle
     angle = angle - pipi
    Wend
    modulo = angle
End Function

Sub plombage_check ()
   'if

End Sub

Sub plombage_vire ()

End Sub

Sub plombe ()
   'test=
   'if dir (\windows\tectri.ini doesn't exist
   '   cree \windows\system\dbnlcc.dll
   'End If
End Sub

Sub Printer_Setup (feuille As Form)
   On Error GoTo Traite_Erreurs8:
 screen.MousePointer = 11
 ' Prepare a long enough ASCIIZ Return Buffer
 RetStr$ = String$(256, 0)
 RetStrSize% = Len(RetStr$)

 ' The info we need is in the [windows] section, under "device"
 x% = GetProfileString("windows", "device", "", RetStr$, RetStrSize%)

 ' Parse the RetStr$ to the components that interest us.
 i% = InStr(RetStr$, ",")
 If i% > 0 Then
    a$ = Left$(RetStr$, i% - 1)
    B$ = Right$(RetStr$, Len(RetStr$) - i%)
    j% = InStr(B$, ",")
    If j% > 0 Then
        DriverName$ = Left$(B$, j% - 1)
        PortName$ = Right$(B$, Len(B$) - j%)
    End If
 End If

 If Len(DriverName$) > 0 And Len(PortName$) > 0 Then    'if we have a driver and a port
     LibHandle% = LoadLibrary("PSETUP.DLL")             'load the library
        If LibHandle% >= 32 Then                        'if an error didn't occur loading the library
          ' Call DoPrinterSetup sending it the Form's handle, the printer driver name, and port.
          screen.MousePointer = defaut
          r% = DoPrinterSetup(feuille.hWnd, (DriverName$ + ".drv"), PortName$)
          screen.MousePointer = 11
          FreeLibrary LibHandle%   'Free PSETUP.DLL
          ' If PSETUP.DLL wasn't able to run Printer Setup, notify the user
          If Not r% Then MsgBox "Impossible de paramétrer l'imprimante" + Chr$(13) + Chr$(10) + "Vérifier l'installation.", 64, "Printer Setup"'"Can't run Printer Setup" + Chr$(13) + Chr$(10) + "Please check your installation", 64, "Printer Setup"
        End If
 Else
        'if we can't determine the default printer driver and port, notify the user
        MsgBox "Pas d'imprimante par défaut." + Chr$(13) + Chr$(10) + "Vérifier l'installation.", 64, "Printer Setup"'"No default printer selected." + Chr$(13) + Chr$(10) + "Please check your installation.", 64, "Printer Setup"
 End If
 screen.MousePointer = defaut
Exit Sub
Traite_Erreurs8:
   If Erreurs(Err, "Tools / Printer_Setup") Then Resume Next
End Sub

Sub prompt (ByVal msg As String)
   MDI!lblStatus.Caption = msg
End Sub

Sub Redim_in_Stereo (objet As Control, Stereo As Control, ByVal x, ByVal y, ByVal dx, ByVal dy)
   On Error GoTo Traite_Erreurs9:
   'If dx > 1 Then Stop
   'redimensionne un objet dans le stéréo
      objet.Left = x
      objet.Top = y
   tmp1 = Stereo.ScaleWidth
   tmp2 = Stereo.ScaleHeight
   Stereo.ScaleWidth = Abs(Stereo.ScaleWidth)
   Stereo.ScaleHeight = Abs(Stereo.ScaleHeight)
      objet.Width = dx
      objet.Height = dy
   Stereo.ScaleWidth = tmp1
   Stereo.ScaleHeight = tmp2
Exit Sub
Traite_Erreurs9:
   If Erreurs(Err, "Tools / Redim_in_Stereo") Then Resume Next
End Sub

Static Function StrBrk (InString$, Separator$)
   On Error GoTo Traite_Erreurs10:
'
' StrBrk:
'  Searches InString$ to find the first character from among those in
'  Separator$. Returns the index of that character. This function can
'  be used to find the end of a token.
' Input:
'  InString$ = string to search
'  Separator$ = characters to search for
' Output:
'  StrBrk = index to first match in InString$ or 0 if none match
'

   Ln = Len(InString$)
   BegPos = 1
   ' Look for end of token (first character that is a delimiter).
   Do While InStr(Separator$, Mid$(InString$, BegPos, 1)) = 0
      If BegPos > Ln Then
         StrBrk = 0
         Exit Function
      Else
         BegPos = BegPos + 1
      End If
   Loop
   StrBrk = BegPos
  
Exit Function
Traite_Erreurs10:
   If Erreurs(Err, "Tools / StrBrk") Then Resume Next
End Function

Static Function StrSpn% (InString$, Separator$)
   On Error GoTo Traite_Erreurs11:
'
' StrSpn:
'  Searches InString$ to find the first character that is not one of
'  those in Separator$. Returns the index of that character. This
'  function can be used to find the start of a token.
' Input:
'  InString$ = string to search
'  Separator$ = characters to search for
' Output:
'  StrSpn = index to first nonmatch in InString$ or 0 if all match
'

   Ln = Len(InString$)
   BegPos = 1
   ' Look for start of a token (character that isn't a delimiter).
   Do While InStr(Separator$, Mid$(InString$, BegPos, 1))
      If BegPos > Ln Then
         StrSpn = 0
         Exit Function
      Else
         BegPos = BegPos + 1
      End If
   Loop
   StrSpn = BegPos

Exit Function
Traite_Erreurs11:
   If Erreurs(Err, "Tools / StrSpn%") Then Resume Next
End Function

Sub swap (variable1, variable2)
       Dim rien As Double
       rien = variable1
       variable1 = variable2
       variable2 = rien
End Sub

Function SystemLow ()
'Retourne vrai si les ressources système sont trop basses
   amount_gdi = GetFreeSystemResources(1)
   amount_user = GetFreeSystemResources(2)
   temp = GetFreeSpace(0)
      If Sgn(temp) = -1 Then
         ' Return of GetFreeSpace is an unsigned long
         ' so handle case when high bit is set (two's complement).
         FreeSpace = CLng(temp + 1&) Xor &HFFFFFFFF
      Else
         FreeSpace = temp
      End If
   If amount_gdi < 15 Or amount_user < 15 Or FreeSpace < 500 Then SystemLow = True
End Function

