/* .............................................................................

   Programa: Fontes/dig_cmc7.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2000.                         Ultima atualizacao:   /  /  

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Calcular os digitos do CMC-7.

............................................................................. */

DEF INPUT  PARAM par_dsdocmc7 AS CHAR                                NO-UNDO.
DEF OUTPUT PARAM par_nrdcampo AS INT                                 NO-UNDO.
DEF OUTPUT PARAM par_lsdigctr AS CHAR                                NO-UNDO.

DEF VAR aux_nrcalcul AS DECIMAL                                      NO-UNDO.
DEF VAR aux_nrdigito AS INT                                          NO-UNDO.
DEF VAR aux_stsnrcal AS LOGICAL                                      NO-UNDO.

DEF VAR aux_nrcampo1 AS INT                                          NO-UNDO.
DEF VAR aux_nrcampo2 AS DECIMAL                                      NO-UNDO.
DEF VAR aux_nrcampo3 AS DECIMAL                                      NO-UNDO.

IF   LENGTH(par_dsdocmc7) <> 34   THEN
     DO:
         par_nrdcampo = 1.
         RETURN.
     END.

/*  Conteudo do par_dsdocmc7 =  <00100950<0168086015>870000575178:  */

ASSIGN aux_nrcampo1 = INT(SUBSTRING(par_dsdocmc7,2,8)) NO-ERROR.

IF   ERROR-STATUS:ERROR   THEN
     DO:
         par_nrdcampo = 1.
         RETURN.
     END.
 
ASSIGN aux_nrcampo2 = DECIMAL(SUBSTRING(par_dsdocmc7,11,10)) NO-ERROR.

IF   ERROR-STATUS:ERROR   THEN
     DO:
         par_nrdcampo = 1.
         RETURN.
     END.

ASSIGN aux_nrcampo3 = DECIMAL(SUBSTRING(par_dsdocmc7,22,12)) NO-ERROR.

IF   ERROR-STATUS:ERROR   THEN
     DO:
         par_nrdcampo = 1.
         RETURN.
     END.

par_nrdcampo = 0.
       
DO WHILE TRUE:

   /*  Calcula o digito do terceiro campo  - DV 1  */
           
   aux_nrcalcul = aux_nrcampo1.
                   
   RUN fontes/digm10.p (INPUT-OUTPUT aux_nrcalcul,
                              OUTPUT aux_nrdigito,
                              OUTPUT aux_stsnrcal).

   par_lsdigctr = STRING(aux_nrdigito,"9").

   IF   aux_nrdigito <> INT(SUBSTR(STRING(aux_nrcampo3,"999999999999"),1,1)) 
        THEN
        DO:
            par_nrdcampo = 3.
            LEAVE.
        END.

   /*  Calcula o digito do primeiro campo  - DV 2  */
       
   aux_nrcalcul = aux_nrcampo2 * 10.
               
   RUN fontes/digm10.p (INPUT-OUTPUT aux_nrcalcul,
                              OUTPUT aux_nrdigito,
                              OUTPUT aux_stsnrcal).

   par_lsdigctr = par_lsdigctr + "," + STRING(aux_nrdigito,"9").
                               
   IF   aux_nrdigito <>
        INT(SUBSTR(STRING(aux_nrcampo1),LENGTH(STRING(aux_nrcampo1)),1))   THEN
        DO:
            par_nrdcampo = 1.
            LEAVE.
        END.
 
   /*  Calcula digito DV 3  */
   
   aux_nrcalcul = DECIMAL(SUBSTRING(STRING(aux_nrcampo3,"999999999999"),2,11)).

   RUN fontes/digm10.p (INPUT-OUTPUT aux_nrcalcul,
                              OUTPUT aux_nrdigito,
                              OUTPUT aux_stsnrcal).

   par_lsdigctr = par_lsdigctr + "," + STRING(aux_nrdigito,"9").
 
   IF   NOT aux_stsnrcal   THEN
        DO:
            par_nrdcampo = 3.
            LEAVE.
        END.

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */