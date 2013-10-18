@echo off
cls
echo Installation de Tectri
c:
md tectri
cd tectri
ren tectri.exe tectri.old
copy a:\tectri.exe /v
copy a:\exemple.tec /v
cd \windows\system
copy a:\*.vbx /v
copy a:\*.dll /v