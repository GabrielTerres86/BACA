/* ........................................................................... 

   Programa: Fontes/corrige_segntl.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Setembro/2003.                    Ultima atualizacao:   /  /    .
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Eliminar os caracteres "E", "E/OU", "OU", do inicio da expressao
               passada como parametro.
               
   Alteracoes: 

............................................................................. */

DEF   INPUT  PARAMETER    par_nmsegntl   AS CHAR                       NO-UNDO.
DEF   OUTPUT PARAMETER    par_nmresult   AS CHAR                       NO-UNDO.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

  IF   CAPS(SUBSTR(par_nmsegntl, 1, 4)) = "EOU "   THEN 
       DO:
           par_nmsegntl = SUBSTR(par_nmsegntl, 5, LENGTH(par_nmsegntl)).
           NEXT.
       END.

  IF   INDEX(SUBSTR(par_nmsegntl, 1, 5), "/") > 0   THEN
       DO:
           par_nmsegntl = SUBSTR(par_nmsegntl, 
                                 INDEX(SUBSTR(par_nmsegntl, 1, 5), "/") + 1, 
                                 LENGTH(par_nmsegntl)).
           NEXT.
       END.
     
  IF   INDEX(SUBSTR(par_nmsegntl, 1, 2), " ") > 0   THEN
       DO:
           par_nmsegntl = SUBSTR(par_nmsegntl, 
                                 INDEX(SUBSTR(par_nmsegntl, 1, 2), " ") + 1,
                                 LENGTH(par_nmsegntl)).
           NEXT.
       END.

  IF   INDEX(CAPS(SUBSTR(par_nmsegntl, 1, 3)), "OU ") > 0   THEN
       DO:
           par_nmsegntl = SUBSTR(par_nmsegntl, 
                            INDEX(CAPS(SUBSTR(par_nmsegntl, 1, 3)), "OU ") + 1,
                            LENGTH(par_nmsegntl)).
           NEXT.
       END.
     
  LEAVE.
  
END.

par_nmresult = par_nmsegntl.

/*............................................................................*/