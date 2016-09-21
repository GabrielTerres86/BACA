/* .............................................................................

   Programa: Fontes/calc_cmc7.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Dezembro/2005.                  Ultima atualizacao: 15/08/2008

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Calcular o CMC-7 do cheque.
   
   Alteracoes : 23/12/2005 - Inclusao do tratamento para cheque TB (Julio).
   
                02/01/2007 - Alterado para enviar talonarios do convenio Bancoob
                            (Ze).

                15/08/2008 - Aceitar qualquer compe (Magui).
............................................................................. */

DEF INPUT  PARAM par_cdbanchq AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_cdcmpchq AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_cdagechq AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrctachq AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrcheque AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_tpcheque AS INT                                 NO-UNDO.
DEF OUTPUT PARAM par_dsdocmc7 AS CHAR                                NO-UNDO.

DEF VAR aux_nrcampo1 AS INT                                          NO-UNDO.
DEF VAR aux_nrcampo2 AS DECIMAL                                      NO-UNDO.
DEF VAR aux_nrcampo3 AS DECIMAL                                      NO-UNDO.
DEF VAR aux_dsdocmc7 AS CHAR                                         NO-UNDO.

DEF VAR aux_nrcalcul AS DECIMAL                                      NO-UNDO.
DEF VAR aux_nrdigito AS INT                                          NO-UNDO.
DEF VAR aux_digtpchq AS CHARACTER                                    NO-UNDO.
DEF VAR aux_stsnrcal AS LOGICAL                                      NO-UNDO.
DEF VAR aux_grpsetec AS INT                                          NO-UNDO.
DEF VAR aux_dscmpchq AS CHAR FORMAT "x(04)"                          NO-UNDO.

IF   par_tpcheque = 2   THEN
     aux_digtpchq = "9".    /* Cheque TB */
ELSE
     aux_digtpchq = "5".

IF   par_cdbanchq = 1 THEN  /* Banco do Brasil */
     aux_grpsetec = 7.
ELSE     
     aux_grpsetec = 0.

ASSIGN aux_dscmpchq = "<" + STRING(par_cdcmpchq,"999").

aux_dsdocmc7 = "<" + STRING(par_cdbanchq,"999") + STRING(par_cdagechq,"9999") + 
               "0" + aux_dscmpchq + STRING(par_nrcheque,"999999") +
               aux_digtpchq + ">0" + STRING(aux_grpsetec,"9") + "0" + 
               STRING(par_nrctachq,"99999999") + "0:".

ASSIGN aux_nrcampo1 = INT(SUBSTRING(aux_dsdocmc7,2,8))
       aux_nrcampo2 = DECIMAL(SUBSTRING(aux_dsdocmc7,11,10))
       aux_nrcampo3 = DECIMAL(SUBSTRING(aux_dsdocmc7,22,12)).

DO WHILE TRUE:

   /*  Calcula o digito do terceiro campo  - DV 1  */
           
   aux_nrcalcul = aux_nrcampo1.
                   
   RUN fontes/digm10.p (INPUT-OUTPUT aux_nrcalcul,
                              OUTPUT aux_nrdigito,
                              OUTPUT aux_stsnrcal).

   aux_nrcampo1 = aux_nrcalcul.

   /*  Calcula o digito do primeiro campo  - DV 2  */
       
   aux_nrcalcul = aux_nrcampo2 * 10.
               
   RUN fontes/digm10.p (INPUT-OUTPUT aux_nrcalcul,
                              OUTPUT aux_nrdigito,
                              OUTPUT aux_stsnrcal).

   aux_nrcampo2 = aux_nrcalcul.
                               
   /*  Calcula digito DV 3  */
   
   aux_nrcalcul = DECIMAL(SUBSTRING(STRING(aux_nrcampo3,"999999999999"),2,11)).

   RUN fontes/digm10.p (INPUT-OUTPUT aux_nrcalcul,
                              OUTPUT aux_nrdigito,
                              OUTPUT aux_stsnrcal).

   aux_nrcampo3 = aux_nrcalcul.
 
   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

par_dsdocmc7 = "<" + 
               SUBSTRING(STRING(aux_nrcampo1,"99999999"),1,7) +
               SUBSTRING(STRING(aux_nrcampo2,"99999999999"),11,1) +
               "<" + 
               SUBSTRING(STRING(aux_nrcampo2,"99999999999"),1,10) +
               ">" + 

               SUBSTRING(STRING(aux_nrcampo1,"999999999"),9,1) +
               SUBSTRING(STRING(aux_nrcampo3,"999999999999"),2,11) + ":".

/* .......................................................................... */
