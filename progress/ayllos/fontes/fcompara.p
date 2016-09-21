/* .............................................................................

   Programa: fontes/fcompara.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
............................................................................. */
def var prg_1 as char format "x(30)" label "Programa a comparar" no-undo.

do while true on endkey undo, leave:

   update prg_1 with side-labels centered title color messages
                " XCompares 1.0 " row 10.

   if   prg_1 = ""   then
        next.

   hide all no-pause.

   unix silent value("echo \n\n\n\n" +
                     "cmp fontes/" + prg_1 +
                     ".p  teste/fontes/" + prg_1 + ".p").
end.
