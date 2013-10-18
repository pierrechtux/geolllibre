VERSION 2.00
Begin Form Debasculement  '{{{
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Débasculement"
   ClientHeight    =   3960
   ClientLeft      =   990
   ClientTop       =   660
   ClientWidth     =   4755
   Height          =   4365
   Left            =   930
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3960
   ScaleWidth      =   4755
   Top             =   315
   Width           =   4875
   Begin CommandButton Command_ok 
      Cancel          =   -1  'True
      Caption         =   "ok"
      Height          =   315
      Left            =   2025
      TabIndex        =   7
      Top             =   1650
      Width           =   1215
   End
   Begin OptionButton Option_FSelec 
      Caption         =   "failles sélectionnées visibles"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   240
      Left            =   825
      TabIndex        =   0
      Top             =   300
      Width           =   2340
   End
   Begin OptionButton Option_FToutes 
      Caption         =   "toutes les failles"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   240
      Left            =   825
      TabIndex        =   1
      Top             =   600
      Width           =   2340
   End
   Begin TextBox text_azideb 
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   285
      Left            =   2550
      TabIndex        =   2
      Top             =   975
      Width           =   400
   End
   Begin TextBox text_dirpddeb 
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   285
      Left            =   3825
      TabIndex        =   4
      Top             =   975
      Width           =   400
   End
   Begin TextBox text_pddeb 
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   285
      Left            =   3150
      TabIndex        =   3
      Top             =   975
      Width           =   400
   End
   Begin CommandButton Command_cliq_pol 
      Caption         =   "Cliquer la polaire sur le stéréo"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   315
      Left            =   2400
      TabIndex        =   5
      Top             =   1275
      Width           =   2265
   End
   Begin CommandButton Command_Deba 
      Caption         =   "Débasculer"
      Default         =   -1  'True
      Height          =   315
      Left            =   450
      TabIndex        =   6
      Top             =   1650
      Width           =   1440
   End
   Begin CommandButton Command_annule 
      Caption         =   "Annuler"
      Height          =   315
      Left            =   3300
      TabIndex        =   8
      Top             =   1650
      Width           =   1365
   End
   Begin PictureBox Stereo 
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      BackColor       =   &H00FFFFFF&
      Height          =   2415
      Left            =   75
      ScaleHeight     =   2385
      ScaleWidth      =   2745
      TabIndex        =   9
      TabStop         =   0   'False
      Top             =   2100
      Width           =   2775
   End
   Begin Label Label1 
      Caption         =   "Débasculement de failles:"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   390
      Left            =   150
      TabIndex        =   10
      Top             =   75
      Width           =   2640
   End
   Begin Label Label2 
      Caption         =   "Plan à ramener à l'horizontale:"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   315
      Left            =   225
      TabIndex        =   11
      Top             =   975
      Width           =   2265
   End
End '}}}
               'alfa,beta,a,b, c,pddir$,zzz,r,t,aa,cc,bb,aaa,bbb,ccc,azimut,
    Dim test1, test2, a, b, c
    Dim aa, bb, cc, alfa, beta, zzz, r, t, alfa2
    Dim aaa, bbb, ccc
    Dim ax, ay, bx, by, mx, my, ox, oy
    Dim beta2, pddir$, pddir2$
    Dim azideb(), pddeb(), pddirdeb$(), pitchdeb(), DirPitchdeb$()

'Pour compter les clics sur le stéréo, lors des focalisations de stries
Dim nbclics As Integer

Sub Command_annule_Click () '{{{
   Unload Me
End Sub
 '}}}
Sub Command_cliq_pol_Click () '{{{
   On Error GoTo Traite_Erreurs6:
   'entrée pd à la souris**
   Stereo.Tag = "clic"
   Stereo.Visible = True
   Get_Put_image st!Stereo, Stereo, ""


'        Print "Veuillez bien pointer la polaire du plan sur le st‚r‚o, SVP."
'                  Do
'                   Call EtatSouris: RatX = PMAP(m3%, 2): RatY = PMAP(m4%, 3)
'                   LOCATE 1, 1: Print RatX, RatY
'                  Loop While (m2% = 0) Or (RatX ^ 2 + RatY ^ 2 > 1)
'                CacheCurseur
Exit Sub
Traite_Erreurs6:
   If Erreurs(Err, "Debasculement / Command_cliq_pol_Click") Then Resume Next
End Sub
 '}}}
Sub Command_Deba_Click () '{{{
   On Error GoTo Traite_Erreurs7:
   'Existe-t-il des failles à débasculer?
      If NbStations = 0 Or (Option_FSelec.Value = 1 And NbMesuresAffichees() = 0) Then
         Beep
         TheMessage$ = "Erreur : aucune mesure sélectionnée..."
         TheStyle = 16
         MsgBox TheMessage$, TheStyle, TheTitle$
         Exit Sub
      End If
      screen.MousePointer = 11
   'le pendage a ramener est-il bon?
      'azi<=180°?  ça doit être ok, checké lors change
      'pd >0°?     ça doit être ok, checké lors change
      'pd <=90°?   ça doit être ok, checké lors change
      'qdr ok?     ça doit être ok, checké lors change
   alfa2 = Val(text_azideb.Text) * pi / 180
   beta2 = Val(text_pddeb.Text) * pi / 180
   pddir2$ = text_dirpddeb.Text
   If pddir2$ = "W" And alfa2 < 3 * pi / 4 Then beta2 = -beta2
   If pddir2$ = "E" And alfa2 > 3 * pi / 4 Then beta2 = -beta2
   If pddir2$ = "N" Then beta2 = -beta2
          
   'IF pddir2$ = "W" AND alfa2 < pi / 2 THEN beta2 = -beta2
   'IF pddir2$ = "E" AND alfa2 > pi / 2 THEN beta2 = -beta2
   'IF pddir2$ = "N" THEN beta2 = -beta2
   
     'Mesures punitives... 25/5/91, d‚sespoir...
           'IF alfa2 <= pi / 4 AND pddir2$ = "W" THEN beta2 = -beta2
           'IF alfa2 > pi / 2 AND alfa2 <= 3 * pi / 4 AND pddir2$ = "N" THEN beta2 = -beta2
           'IF alfa2 > 3 * pi / 4 AND pddir2$ = "E" THEN beta2 = -beta2

   nsavant = ns
   iavant = i
      For ns = 1 To NbStations
         If Not (Site(ns).deleted) Then
            If Not (Affich_F_Stations_Icones = False And frm_Station(ns).WindowState = REDUIT) Then
               For i = 1 To Site(ns).NbMes
                  Select Case Option_FSelec.Value
                     Case True
                        If Site(ns).Faille(i).GroupeTri >= 0 Then
                           If MDI!menu_projettegroupe(Site(ns).Faille(i).GroupeTri).Checked Then           'Affichage(Site(ns).Faille(i).GroupeTri) Then
                              Call DebaMesure
                           End If
                        End If
                     Case Else
                        Call DebaMesure
                  End Select
                  If flag = True Then flag = False: screen.MousePointer = 0: Exit Sub
               Next
            End If
         End If
      Next
   ns = nsavant
   i = iavant
   'Stop
   'ok'Met à jour les calculs
   '      If Entre_faille_courante(i, azi, Pd, dirpd, pitch, dirpitch, jeu, Site(ns).Faille(i).commentaire) = True Then
   '         If Not (Saisie_mesure.annule.Enabled) Then Exit For
   '      Else
   '         Label_Numero = Str$(i) + " / " + Str$(imax)
   '         Me.Caption = frm_Station(ns).Caption '+ " : saisie de la mesure n°" + Str$(i)
   '         If i > Site(ns).NbMes Then Display_Faille
   '         azi.SetFocus
   '         SCREEN.MousePointer = defaut
   '         Exit Sub
   '      End If
   RedessinStereo Debasculement!Stereo
Exit Sub
Traite_Erreurs7:
   If Erreurs(Err, "Debasculement / Command_Deba_Click") Then Resume Next
End Sub
 '}}}
Sub Command_ok_Click () '{{{
   On Error GoTo Traite_Erreurs8:
   'Met à jour le tableau
   MetàJourStation
   MetàJourListeGroupe
   If Site(ns).dirty <> True Then Site(ns).dirty = True
   'Retrace le stéréo à neuf
   RedessinStereo st!Stereo
   Me.Hide
   If SystemLow() Then Unload Me
Exit Sub
Traite_Erreurs8:
   If Erreurs(Err, "Debasculement / Command_ok_Click") Then Resume Next
End Sub
 '}}}
Sub ConversionPlan () '{{{
   On Error GoTo Traite_Erreurs1:
   'ConversionPendage
   If alfa = pi / 2 Then a = 1: b = 0: GoTo lb3
   a = Abs(Tan(alfa)): b = -1: 'a = INT(TAN(alfa)): b = -1
   If alfa < pi / 2 Then a = -a
   
lb3: c = Sqr(1 + a ^ 2) / Tan(beta):    'lb3: c = sqr(1 + a^2) / tan(beta)
   If alfa = pi / 2 Then GoTo lb5
   If (pddir$ = "S" Or pddir$ = "W") And alfa >= pi / 2 Then c = -c
   If (pddir$ = "N" Or pddir$ = "W") And alfa <= pi / 2 Then c = -c
   'IF (pddir$ = "S") AND alfa >= pi / 2 THEN c = -c
   'IF (pddir$ = "N") AND alfa <= pi / 2 THEN c = -c
   If alfa = pi / 2 Then GoTo lb5
   If (a - b) / c > 0 Then GoTo lb4
   If pddir$ = "E" And alfa > 3 * pi / 4 Then GoTo lb5
   If pddir$ = "E" And alfa < pi / 4 Then GoTo lb5
   c = -c: GoTo lb5
   
lb4: If (pddir$ = "W") And (alfa > 3 * pi / 4) Then GoTo lb5
   If (pddir$ = "W") And (alfa < pi / 4) Then GoTo lb5
   If pddir$ = "S" Then GoTo lb5
   c = -c
   
   
lb5:
   'PRINT "valeur a:"; a: PRINT "valeur b:"; INT(b): PRINT "valeur c:"; c
   
   zzz = b / c
   r = -a / b
   t = -a / c
   
Exit Sub
Traite_Erreurs1:
   If Erreurs(Err, "Debasculement / ConversionPlan") Then Resume Next
End Sub
 '}}}
Sub deba () '{{{
   On Error GoTo Traite_Erreurs2:
   aa = a * Cos(alfa2) - b * Sin(alfa2):  'Mettre le pendage en N-S.
   cc = c
   bb = a * Sin(alfa2) + b * Cos(alfa2)
   
   aaa = aa:                                 'D‚basculer de la valeur du pendage.
   bbb = bb * Cos(beta2) - cc * Sin(beta2)
   ccc = bb * Sin(beta2) + cc * Cos(beta2)
   
   a = aaa * Cos(-alfa2) - bbb * Sin(-alfa2) 'Remettre le pendage ds la positø
   b = aaa * Sin(-alfa2) + bbb * Cos(-alfa2):       'initiale.
   c = ccc
Exit Sub
Traite_Erreurs2:
   If Erreurs(Err, "Debasculement / deba") Then Resume Next
End Sub
 '}}}
Sub DebaMesure () '{{{
   On Error GoTo Traite_Erreurs3:
   'plan
      Select Case Site(ns).Faille(i).azi '* 180 / pi
         Case 0 To 45
            alfa = Site(ns).Faille(i).azi: 'pddir$ = "E"
         Case 45 To 135
            alfa = Site(ns).Faille(i).azi: 'pddir$ = "S"
         Case 135 To 180
            alfa = Site(ns).Faille(i).azi: 'pddir$ = "W"
         'Case 180 To 225
         '   alfa = Site(ns).Faille(i).azi - 180: pddir$ = "W"
         'Case 225 To 315
         '   alfa = Site(ns).Faille(i).azi - 180: pddir$ = "N"
         'Case 225 To 360
         '   alfa = Site(ns).Faille(i).azi - 180: pddir$ = "E"
         Case Else
      End Select
   pddir$ = UCase$(Site(ns).Faille(i).DirPd)
   beta = Site(ns).Faille(i).Pd: 'pddir$ = DirPd$(ns, i)
   alfa = alfa * pi / 180
   beta = beta * pi / 180
   ConversionPlan
   deba
   pro
               'azideb(ns, i) = alfa: pddeb(ns, i) = beta: pddirdeb$(ns, i) = pddir$
                        'Print Int(Site(ns).Faille(i).azi * 180 / pi); " "; Int(Pd(ns, i) * 180 / pi); " "; DirPd$(ns, i), Int(azideb(ns, i) * 180 / pi); " "; Int(pddeb(ns, i) * 180 / pi); " "; pddirdeb$(ns, i)
   azi = alfa * 180 / pi
   Pd = beta * 180 / pi
   DirPd = pddir$
       
   'strie
   'Pour d‚ba >1 strie: traduire strie en un vecteur ds x,y,z de pro:strie(a,b,c)
   ' SX(ns, i), SY(ns, i)
   If Site(ns).Faille(i).param.SX = 0 And Site(ns).Faille(i).param.SY > 0 Then azimut = pi / 2: GoTo apres
   If Site(ns).Faille(i).param.SX = 0 And Site(ns).Faille(i).param.SY < 0 Then azimut = 3 * pi / 2: GoTo apres
   If Site(ns).Faille(i).param.SX > 0 And Site(ns).Faille(i).param.SY = 0 Then azimut = 0: GoTo apres
   If Site(ns).Faille(i).param.SX < 0 And Site(ns).Faille(i).param.SY = 0 Then azimut = pi: GoTo apres
   azimut = Atn(Site(ns).Faille(i).param.SX / Site(ns).Faille(i).param.SY)
   'IF sx(ns, i) > 0 AND sy(ns, i) > 0 THEN azimut = azimut
   If Site(ns).Faille(i).param.SX > 0 And Site(ns).Faille(i).param.SY < 0 Then azimut = azimut + pi
   If Site(ns).Faille(i).param.SX < 0 And Site(ns).Faille(i).param.SY > 0 Then azimut = azimut + 2 * pi
   If Site(ns).Faille(i).param.SX < 0 And Site(ns).Faille(i).param.SY < 0 Then azimut = azimut + pi
apres:
   plong = Atn(1 / Sqr(Site(ns).Faille(i).param.SX ^ 2 + Site(ns).Faille(i).param.SY ^ 2))
   SX = -Cos(azimut) * Cos(plong)
   SY = Sin(azimut) * Cos(plong)
   SZ = Sin(plong)
   If Site(ns).Faille(i).param.jv = "N" Then SX = -SX: SY = -SY: SZ = -SZ
            a = -SY
            b = SX
            c = SZ
   'Puis, moulinette des rotations de deba.
         deba
   'puis retraduire en strie g‚ol la strie math, moi-mˆme, tout seul, ignor‚ de tous...
      sydeb = -a
      sxdeb = b
      szdeb = c
      plongdeb = ArcSin(szdeb)
      azimutstrideb = Atn(sxdeb / sydeb)
      If szdeb < 0 Then jvdeb$ = "N":  Else jvdeb$ = "I"
         'D‚termination du pitch d‚bascul‚.
            azi = azi * pi / 180
            ro = azimutstrideb - azi 'azideb
            If ro > azi Then ro = ro - pi
            If ro < 0 Then ro = ro + 2 * pi
            If ro > 2 * pi Then ro = ro - 2 * pi
            azi = azi * 180 / pi
            'pitchdeb(ns, i) = Atn(-Tan(ro) * Cos(beta))
            Pitch = (Atn(-Tan(ro) * Cos(beta))) * 180 / pi
            If Pitch < 0 Then Pitch = -Pitch: jeu = "I":  Else jeu = "N"
                  If azi > 135 Then dirpitch = "S"
                  If azi < 135 Then dirpitch = "E"
                  If azi < 45 Then dirpitch = "N"
               Select Case Pitch
                  Case Is > 90
                     Pitch = Pitch - 90
                     If dirpitch = "S" Then dirpitch = "N"
                     If dirpitch = "E" Then dirpitch = "W"
                     If dirpitch = "N" Then dirpitch = "S"
                  Case Else
               End Select
        'Validation de la mesure
        azi = Int(azi)
        Pd = Int(Pd)
        Pitch = Int(Pitch)
        If Not (Entre_faille_courante(i, azi, Pd, DirPd, Pitch, dirpitch, jeu, commentaire)) Then
            flag = True 'Beep
        End If
Exit Sub
Traite_Erreurs3:
   If Erreurs(Err, "Debasculement / DebaMesure") Then Resume Next
End Sub
 '}}}
Sub Form_Activate () '{{{
   On Error Resume Next'pour le setfocus qui n'est pas valable quand la feuille n'est pas showée
   Stereo.Height = st!Stereo.Height
   Stereo.Width = st!Stereo.Width
   Form_Resize
   TourStereo Stereo
   ScaleMode = twips'PIXELS
   Get_Put_image st!Stereo, Stereo, ""
   screen.MousePointer = defaut
End Sub
 '}}}
Sub Form_Load () '{{{
   On Error GoTo Traite_Erreurs9:
   prompt "Débasculement"
   'centerformchild mdi, Me
   Form_Activate
   centerform Me
   screen.MousePointer = defaut
   prompt ""
Exit Sub
Traite_Erreurs9:
   If Erreurs(Err, "Debasculement / Form_Load") Then Resume Next
End Sub
 '}}}
Sub Form_Resize () '{{{
   On Error GoTo Traite_Erreurs10:
   If flag Or WindowState <> 0 Then flag = False: Exit Sub
   Stereo.Top = Command_annule.Top + Command_annule.Height + 100
   ScaleMode = st!Stereo.ScaleMode
      flagi = flag
      flag = True'pour éviter qu'on ne se morde la queue
      Height = Stereo.Top + Stereo.Height + 200 + hauteurbarretitre
      flag = True
      Width = max(Command_cliq_pol.Left + Command_cliq_pol.Width + 200, Stereo.Left + Stereo.Width + 200)
      flag = flagi
Exit Sub
Traite_Erreurs10:
   If Erreurs(Err, "Debasculement / Form_Resize") Then Resume Next
End Sub
 '}}}
Sub pro () '{{{
   On Error GoTo Traite_Erreurs4:
'procedure pro;    Traduction plan math->plan g‚ol.
'label lb1,lb2;
'begin
                                    'RepŠre m‚th‚matique: axe x=vers le S.
'INPUT "valeur a:"; a               '                         y=vers l'E.
'INPUT "valeur b:"; b               '                         z=vers le ht.
'INPUT "valeur c:"; c

If b = 0 Then
        alfa = 0
        Else
        alfa = (Atn(-a / b))
        End If

If a * b < 0 Then
        alfa = pi - alfa
        Else
          alfa = -alfa
        End If


If c = 0 Then beta = pi / 2: pddir$ = "S": GoTo lb1
beta = Abs(Atn(Sqr(a ^ 2 + b ^ 2) / c)): 'beta:=abs(arctan(sqrt(sqr(a)+sqr(b))/c));


If (a - b) / c < 0 Then
        pddir$ = "N"
        Else GoTo lb2
        End If

If alfa > 3 * pi / 4 Then pddir$ = "E"

If alfa < pi / 4 Then pddir$ = "E"
GoTo lb1


lb2: pddir$ = "S"
If alfa > 3 * pi / 4 Then pddir$ = "W"
If alfa < pi / 4 Then pddir$ = "W"



lb1: 'PRINT INT(alfa * 180 / pi); " "; INT(beta * 180 / pi); pddir$
zzz = b / c
r = -a / b
t = -a / c


'PRINT "(0,-1,"; zzz; ")"
'PRINT "(1,"; r; ",0)"
'PRINT "(1,0,"; t; ")"
'PRINT "alfa:="; alfa * 180 / pi


Exit Sub
Traite_Erreurs4:
   If Erreurs(Err, "Debasculement / pro") Then Resume Next
End Sub
 '}}}
Sub pro2 () '{{{
   On Error GoTo Traite_Erreurs5:
'********* cette procédure est-elle utile? ******
'procedure pro2;Traduction plan g‚ol-> plan math.

'label lb3,lb4,lb5;

Print "Entrée du plan à débasculer:"
'INPUT "alfa:"; alfa
'INPUT "beta:"; beta
'INPUT "pddir:"; pddir$: PRINT
'alfa = alfa * pi / 180
'beta = beta * pi / 180

ConversionPlan

Exit Sub
Traite_Erreurs5:
   If Erreurs(Err, "Debasculement / pro2") Then Resume Next
End Sub
 '}}}
Sub Stereo_MouseDown (Button As Integer, Shift As Integer, X As Single, Y As Single) '{{{
   On Error GoTo Traite_Erreurs11:
   If Stereo.Tag <> "clic" Or X ^ 2 + Y ^ 2 > 1 Then Exit Sub
   Stereo.MousePointer = 0
   Stereo.Tag = ""
   'On désigne le pendage à ramener à l'horizontale
   Get_Put_image st!Stereo, Stereo, ""
   Stereo.Circle (X, Y), .05
   'Stereo.DrawWidth = 2 * Stereo.DrawWidth
   Stereo.DrawStyle = 2
   Stereo.Line (X * .9, Y * .9)-(X * .1, Y * .1)
   'Stereo.DrawWidth = Stereo.DrawWidth / 2
   Stereo.DrawStyle = 0
Exit Sub
Traite_Erreurs11:
   If Erreurs(Err, "Debasculement / Stereo_MouseDown") Then Resume Next
End Sub
 '}}}
Sub Stereo_MouseMove (Button As Integer, Shift As Integer, X As Single, Y As Single) '{{{
   On Error GoTo Traite_Erreurs12:
   If Stereo.Tag <> "clic" Then Exit Sub
   distcentre = X ^ 2 + Y ^ 2
   Select Case distcentre
      Case Is > 1'***cadre
         Stereo.MousePointer = 0
      Case Else
         Stereo.MousePointer = 2
            If Y = 0 And X < 0 Then
               alfa2 = pi
            ElseIf Y = 0 And X >= 0 Then alfa2 = 0
            Else
               alfa2 = -Atn(Y / X)
            End If
         
         If X < 0 Then alfa2 = alfa2 + pi
         If alfa2 < 0 Then alfa2 = alfa2 + 2 * pi
            Select Case alfa2
               Case 0 To pi / 4
                     pddir2$ = "E"
               Case pi / 4 To 3 * pi / 4
                     pddir2$ = "S"
               Case 3 * pi / 4 To 5 * pi / 4
                     pddir2$ = "W"
               Case 5 * pi / 4 To 7 * pi / 4
                     pddir2$ = "N"
               Case 7 * pi / 4 To 2 * pi
                     pddir2$ = "E"
               Case Else
            End Select
         If alfa2 >= pi Then alfa2 = alfa2 - pi
         beta2 = ARCOS(-(X ^ 2 - (Cos(-alfa2)) ^ 2) / (X ^ 2 + (Cos(-alfa2)) ^ 2))
         text_azideb = Int(alfa2 * 180 / pi)
         text_dirpddeb = pddir2$
         text_pddeb = Int(beta2 * 180 / pi)
         
         'tracer la cyclo
      
         'LOCATE 1, 1: Print "N"; Int(alfa2 * 180 / pi); (beta2 * 180 / pi), pddir2$
   End Select
Exit Sub
Traite_Erreurs12:
   If Erreurs(Err, "Debasculement / Stereo_MouseMove") Then Resume Next
End Sub
 '}}}
Sub text_azideb_Change () '{{{
   If Err Then Exit Sub
   text_azideb.Text = UCase$(text_azideb.Text)
   text_azideb.SelStart = Len(text_azideb.Text)
   If Len(text_azideb.Text) > 3 Then text_azideb.Text = Right$(text_azideb.Text, 3)
   On Error Resume Next
   If CSng(text_azideb.Text) > 180 Then
      If Err = 0 Then
         text_azideb.Text = "180"
      Else
         text_azideb.Text = "": Err = 0
      End If
   End If
End Sub
 '}}}
Sub text_dirpddeb_Change () '{{{
   On Error Resume Next
   If Err Then Exit Sub
   Err = 1
   text_dirpddeb.Text = UCase$(text_dirpddeb.Text)
   text_dirpddeb.SelStart = Len(text_dirpddeb.Text)
   If Len(text_dirpddeb.Text) > 1 Then text_dirpddeb.Text = Right$(text_dirpddeb.Text, 1)
   On Error Resume Next
   Err = 1
   If text_dirpddeb.Text <> "N" And text_dirpddeb.Text <> "S" And text_dirpddeb.Text <> "E" And text_dirpddeb.Text <> "W" Then text_dirpddeb.Text = ""
   'vient de checke_mesure
   If (Val(text_azideb.Text) < 45 Or Val(text_azideb.Text) > 135) And (UCase$(text_dirpddeb) = "N" Or UCase$(dirpddeb) = "S") Then text_dirpddeb.Text = ""
   If (Val(text_azideb.Text) > 45 And Val(text_azideb.Text) < 135) And (UCase$(text_dirpddeb) = "W" Or UCase$(dirpddeb) = "E") Then text_dirpddeb.Text = ""
   
   If Err > 1 Then text_dirpddeb.Text = "": Err = 0
   Err = 0
End Sub
 '}}}
Sub text_pddeb_Change () '{{{
   If Err Then Exit Sub
   text_pddeb.Text = UCase$(text_pddeb.Text)
   text_pddeb.SelStart = Len(text_pddeb.Text)
   If Len(text_pddeb.Text) > 2 Then text_pddeb.Text = Right$(text_pddeb.Text, 2)
   On Error Resume Next
   If CSng(text_pddeb.Text) > 90 Then
      If Err = 0 Then
          text_pddeb.Text = "90"
      Else
          text_pddeb.Text = "": Err = 0
      End If
   End If
End Sub
 '}}}
