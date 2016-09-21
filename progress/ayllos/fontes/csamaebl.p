/* .............................................................................
                    
   Programa: Fontes/csamaebl.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Eduardo
   Data    : Janeiro/2001.                       Ultima atualizacao:   /  /  

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Entrar com o codigo de barras para as faturas compesaveis    
               SOMENTE COM O HISTORICO 306. SAMAE Blumenau.
............................................................................. */

{ includes/var_online.i }

DEF  OUTPUT PARAM par_dscodbar AS CHAR   FORMAT "x(44)"               NO-UNDO.

DEF  VAR          aux_lsvalido AS CHAR                                NO-UNDO.
DEF  VAR          aux_nrdigver AS INT                                 NO-UNDO.

aux_lsvalido = "1,2,3,4,5,6,7,8,9,0,RETURN,F4,CURSOR-LEFT,CURSOR-RIGHT".
 
FORM SKIP(1)
     " "
     par_dscodbar FORMAT "x(44)" AT 03 
     " "                                
     SKIP(1)
     WITH ROW 16 CENTERED NO-LABEL
          OVERLAY TITLE " Entre com o codigo de barras " FRAME f_codbar.

PAUSE 0.    
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   par_dscodbar = "".
   
   IF   glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

   UPDATE par_dscodbar  WITH FRAME f_codbar

   EDITING:
      
           READKEY.
           IF   NOT CAN-DO(aux_lsvalido, KEYLABEL(LASTKEY))   THEN
                DO:
                    glb_cdcritic = 666.
                    NEXT.   
                END.
           
           APPLY LASTKEY.
                                   
   END.  /*  Fim do EDITING  */

   IF   TRIM(par_dscodbar) <> "" THEN
        DO:
           IF   LENGTH(par_dscodbar) <> 44 THEN
                DO:
                    glb_cdcritic = 666.
                    NEXT.
                END.
                                   
           glb_nrcalcul = DECIMAL(par_dscodbar).
                     
           RUN fontes/cdbarra3.p (OUTPUT aux_nrdigver).
                             
           IF   NOT glb_stsnrcal   THEN
                DO:
                    glb_cdcritic = 8.
                    NEXT.
                END.

        END.  /*     Fim do IF  TRIM    */

   LEAVE.
   
END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_codbar NO-PAUSE.

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
     par_dscodbar = "".

/* .......................................................................... */