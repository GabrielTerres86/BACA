/* .............................................................................

   Programa: Fontes/testa_boletim.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/2002                       Ultima atualizacao: 13/02/2006

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Verificar se o boletim de caixa esta fechado.
   
   Alteracoes: 27/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

               13/02/2006 - Inclusao do parametro cdcooper para a unificacao
                            dos bancos de dados - SQLWorks - Fernando.
............................................................................. */

DEF INPUT  PARAM par_cdcooper AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt AS DATE                                NO-UNDO.
DEF INPUT  PARAM par_cdagenci AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_cdbccxlt AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrdolote AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrdcaixa AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_cdopecxa AS CHAR                                NO-UNDO.
DEF OUTPUT PARAM par_cdcritic AS INT                                 NO-UNDO.

par_cdcritic = 0.
    
IF   par_cdbccxlt = 11     AND
     par_nrdcaixa > 0      AND
     par_cdagenci <> 11    THEN  /* boletim de caixa -   EDSON PAC1 */ 
     DO:
         FIND LAST crapbcx WHERE crapbcx.cdcooper = par_cdcooper   AND
                                 crapbcx.dtmvtolt = par_dtmvtolt   AND
                                 crapbcx.cdagenci = par_cdagenci   AND
                                 crapbcx.nrdcaixa = par_nrdcaixa   AND         
                                 crapbcx.cdopecxa = par_cdopecxa   NO-LOCK
                                 USE-INDEX crapbcx2 NO-ERROR.

         IF   NOT AVAILABLE crapbcx    THEN
              DO:
                  par_cdcritic = 701. 
                  RETURN.
              END.
                      
         IF   crapbcx.cdsitbcx = 2   THEN
              DO:
                  par_cdcritic = 698.
                  RETURN.
              END.               
     END.

/* .......................................................................... */

