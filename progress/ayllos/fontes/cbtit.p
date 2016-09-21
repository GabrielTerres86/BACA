/* .............................................................................

   Programa: Fontes/cbtit.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2000.                      Ultima atualizacao: 08/12/2008  

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Entrar com a linha digitavel dos titulos compensaveis.

   Alteracoes: 08/12/2008 - Chamar programa pcrap03.p em vez do digm10.p
                            (David).

............................................................................. */

{ includes/var_online.i }

DEF OUTPUT PARAM par_dscodbar AS CHAR                                NO-UNDO.

DEF VAR tel_nrcampo1 AS DECIMAL FORMAT "9999999999"                  NO-UNDO.
DEF VAR tel_nrcampo2 AS DECIMAL FORMAT "99999999999"                 NO-UNDO.
DEF VAR tel_nrcampo3 AS DECIMAL FORMAT "99999999999"                 NO-UNDO.
DEF VAR tel_nrcampo4 AS INT     FORMAT "9"                           NO-UNDO.
DEF VAR tel_nrcampo5 AS DECIMAL FORMAT "zz,zzz,zzz,zzz999"           NO-UNDO.

DEF VAR aux_nrdigito AS INT                                          NO-UNDO.

FORM SKIP(1)
     " "
     tel_nrcampo1 AT  3 FORMAT "99999,99999"
     tel_nrcampo2 AT 15 FORMAT "99999,999999"
     tel_nrcampo3 AT 28 FORMAT "99999,999999"
     tel_nrcampo4 AT 41 FORMAT "9"
     tel_nrcampo5 AT 43 FORMAT "zz,zzz,zzz,zzz999" " "
     SKIP(1)
     WITH ROW 15 CENTERED NO-LABEL
          OVERLAY TITLE " Entre com a linha digitavel " FRAME f_linha.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   IF   glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

   UPDATE tel_nrcampo1 tel_nrcampo2 tel_nrcampo3 tel_nrcampo4 tel_nrcampo5
          WITH FRAME f_linha.

   /*  Calcula digito verificador do primeiro campo da linha digitavel  */
   
   glb_nrcalcul = tel_nrcampo1.

   RUN dbo/pcrap03.p (INPUT-OUTPUT glb_nrcalcul,
                      INPUT        TRUE,  /* Validar zeros */      
                            OUTPUT aux_nrdigito,
                            OUTPUT glb_stsnrcal).
 
   IF   NOT glb_stsnrcal   THEN
        DO:
            glb_cdcritic = 8.
            NEXT-PROMPT tel_nrcampo1 WITH FRAME f_linha.
            NEXT.
        END.

   /*  Calcula digito verificador do segundo campo da linha digitavel  */
   
   glb_nrcalcul = tel_nrcampo2.

   RUN dbo/pcrap03.p (INPUT-OUTPUT glb_nrcalcul,
                      INPUT        FALSE,  /* Validar zeros */
                            OUTPUT aux_nrdigito,
                            OUTPUT glb_stsnrcal).
    
   IF   NOT glb_stsnrcal   THEN
        DO:
            glb_cdcritic = 8.
            NEXT-PROMPT tel_nrcampo2 WITH FRAME f_linha.
            NEXT.
        END.

   /*  Calcula digito verificador do terceiro campo da linha digitavel  */
   
   glb_nrcalcul = tel_nrcampo3.

   RUN dbo/pcrap03.p (INPUT-OUTPUT glb_nrcalcul,
                      INPUT        FALSE,  /* Validar zeros */
                            OUTPUT aux_nrdigito,
                            OUTPUT glb_stsnrcal).
    
   IF   NOT glb_stsnrcal   THEN
        DO:
            glb_cdcritic = 8.
            NEXT-PROMPT tel_nrcampo3 WITH FRAME f_linha.
            NEXT.
        END.
  
   /*  Compoe o codigo de barras atraves da linha digitavel  */

   ASSIGN par_dscodbar = SUBSTRING(STRING(tel_nrcampo1,"9999999999"),1,4) +
                         STRING(tel_nrcampo4,"9") +
                         STRING(tel_nrcampo5,"99999999999999") +
                         SUBSTRING(STRING(tel_nrcampo1,"9999999999"),5,1) +
                         SUBSTRING(STRING(tel_nrcampo1,"9999999999"),6,4) +
                         SUBSTRING(STRING(tel_nrcampo2,"99999999999"),1,10) +
                         SUBSTRING(STRING(tel_nrcampo3,"99999999999"),1,10)
                         
          glb_nrcalcul = DECIMAL(par_dscodbar).
                  
   RUN fontes/digcbtit.p.

   IF   NOT glb_stsnrcal   THEN
        DO:
            glb_cdcritic = 8.
            NEXT-PROMPT tel_nrcampo4 WITH FRAME f_linha.
            NEXT.
        END.
    
   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_linha NO-PAUSE.

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
     par_dscodbar = "".

/* .......................................................................... */