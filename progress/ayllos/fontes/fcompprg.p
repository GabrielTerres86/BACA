/* .............................................................................

   Programa: fontes/fcompprg.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
............................................................................. */
def var aux_cdprogra as char format "x(78)" no-undo.
def var aux_nmprogra as char format "x(78)" no-undo.
def var aux_nmprogr2 as char format "x(78)" no-undo.

do while true on endkey undo, return:

    set aux_nmprogra
        validate(aux_nmprogra <> "",
                 "Nome do(s) fonte(s) deve(m) ser informado(s).")
        aux_nmprogr2
        with row 6 no-labels centered title " XCompiler 1.1 " frame f_nmprogra.

    leave.
end.

input through ls value(aux_nmprogra + " " + aux_nmprogr2) no-echo.
do while true on endkey undo, next:
   set aux_cdprogra with frame a.

   if substring(aux_cdprogra,length(aux_cdprogra) - 1,2) <> ".p"  then
      next.

   message "compilando" aux_cdprogra.
   compile value(aux_cdprogra) save.
   hide message no-pause.
end.
input close.
return.
