/* .............................................................................

   Programa: Fontes/ciptu.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Eduardo
   Data    : Janeiro/2001.                       Ultima atualizacao:   /  /  

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Entrar com a linha digitavel do codigo barra tipo 3. 
               LANTIT - referente ao IPTU e LANFAT - todas as faturas.
............................................................................. */

{ includes/var_online.i }

DEF OUTPUT PARAM par_dscodbar AS CHAR                                NO-UNDO.
                                        
DEF VAR tel_nrcampo1 AS DECIMAL FORMAT "999999999999"                 NO-UNDO.
DEF VAR tel_nrcampo2 AS DECIMAL FORMAT "999999999999"                 NO-UNDO.
DEF VAR tel_nrcampo3 AS DECIMAL FORMAT "999999999999"                 NO-UNDO.
DEF VAR tel_nrcampo4 AS DECIMAL FORMAT "999999999999"                 NO-UNDO.
                                        
DEF VAR aux_nrdigito AS INT                                          NO-UNDO.
DEF VAR aux_nrdigver AS INT                                          NO-UNDO.

FORM SKIP(1)
     " "
     tel_nrcampo1 AT  3 FORMAT "99999,999999,9"
     tel_nrcampo2 AT 18 FORMAT "99999,999999,9"
     tel_nrcampo3 AT 33 FORMAT "99999,999999,9"
     tel_nrcampo4 AT 48 FORMAT "99999,999999,9"
     " "                        
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

   UPDATE tel_nrcampo1 tel_nrcampo2 tel_nrcampo3 tel_nrcampo4 
          WITH FRAME f_linha.

   /*  Calcula digito verificador da linha digitavel 
       e compoe o codigo de  barras  */
       
           glb_nrcalcul = DECIMAL(
                          SUBSTR(STRING(tel_nrcampo1,"999999999999"),1,11) + 
                          SUBSTR(STRING(tel_nrcampo2,"999999999999"),1,11) + 
                          SUBSTR(STRING(tel_nrcampo3,"999999999999"),1,11) + 
                          SUBSTR(STRING(tel_nrcampo4,"999999999999"),1,11)).
                                                    
   par_dscodbar = STRING(glb_nrcalcul).

   RUN fontes/cdbarra3.p (OUTPUT aux_nrdigver).
   
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
