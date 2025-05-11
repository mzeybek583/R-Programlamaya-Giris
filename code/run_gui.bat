@echo off
REM Rscript.exe yolunu doğru şekilde ayarlayın
REM Eğer 64-bit R yüklüyse ve R 4.4.3 ise aşağıdaki yol genelde doğrudur:

set R_SCRIPT_PATH="C:\Program Files\R\R-4.4.3\bin\x64\Rscript.exe"

REM R kod dosyasının yolu (aynı klasördeyse sadece adı yeterlidir)
set R_FILE="gui_tcltk.R"

REM Çalıştır
%R_SCRIPT_PATH% %R_FILE%

pause