/* .............................................................................

   Programa: Fontes/cmc7.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2000.                         Ultima atualizacao:   /  /  

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Entrar com o CMC-7 manualmente.

............................................................................. */

{ includes/var_online.i } 

DEF OUTPUT PARAM par_dsdocmc7 AS CHAR                                NO-UNDO.

DEF VAR tel_nrcampo1 AS INT     FORMAT "99999999"                    NO-UNDO.
DEF VAR tel_nrcampo2 AS DECIMAL FORMAT "9999999999"                  NO-UNDO.
DEF VAR tel_nrcampo3 AS DECIMAL FORMAT "999999999999"                NO-UNDO.

DEF VAR aux_lsdigctr AS CHAR                                         NO-UNDO.

FORM SKIP(1)
     "<"            AT  3
     tel_nrcampo1   AT  4
     "<"            AT 12
     tel_nrcampo2   AT 13
     ">"            AT 23
     tel_nrcampo3   AT 24
     ":  "          AT 36
     SKIP(1)
     WITH ROW 15 CENTERED NO-LABEL
          OVERLAY TITLE " Digite o CMC-7 " FRAME f_cmc7.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   IF   glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

   UPDATE tel_nrcampo1 tel_nrcampo2 tel_nrcampo3 WITH FRAME f_cmc7.

   par_dsdocmc7 = "<" + STRING(tel_nrcampo1,"99999999") +
                  "<" + STRING(tel_nrcampo2,"9999999999") +
                  ">" + STRING(tel_nrcampo3,"999999999999") + ":".

   /*  Confere os digitos do CMC-7  */
   
   RUN fontes/dig_cmc7.p (INPUT  par_dsdocmc7, 
                          OUTPUT glb_nrcalcul,
                          OUTPUT aux_lsdigctr).
   
   IF   glb_nrcalcul > 0   THEN
        DO:
            IF   glb_nrcalcul = 1   THEN
                 NEXT-PROMPT tel_nrcampo1 WITH FRAME f_cmc7.
            ELSE
            IF   glb_nrcalcul = 2   THEN
                 NEXT-PROMPT tel_nrcampo2 WITH FRAME f_cmc7.
            ELSE
            IF   glb_nrcalcul = 3   THEN
                 NEXT-PROMPT tel_nrcampo3 WITH FRAME f_cmc7.
 
            glb_cdcritic = 8.
            NEXT.
        END.
    
   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_cmc7 NO-PAUSE.

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
     par_dsdocmc7 = "".

/* .......................................................................... */
