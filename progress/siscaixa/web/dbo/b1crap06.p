/* .............................................................................

   Programa: siscaixa/web/dbo/b1crap06.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 11/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Estorno Talao Normal e TB

   Alteracoes: 31/08/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)
                            
               08/11/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks)
               
               16/11/2005 - Adequacao ao padrao, analise de performance e dos
                            itens convertidos (SQLWorks - Andre)

               01/12/2005 - Acertar leitura do crapfdc (Margarete).
               
               22/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               12/02/2007 - Adequacao ao BANCOOB e preparacao para uso tanto do
                            CAIXA ON-LINE quanto do AYLLOS (Evandro).
               
               16/03/2007 - Fazer controles de acordo com o sistema que esta
                            chamando a BO - AYLLOS ou CAIXA ON-LINE (Evandro).

               23/08/2012 - Procedure exclui-solicitacao-entrega-talao 
                            tratamento cheques custodia - Projeto Tic
                            (Richard/Supero). 

               11/06/2014 - Somente emitir a crítica 950 apenas se a 
                            crapfdc.dtlibtic >= data do movimento (SD. 163588 - Lunelli)                            
............................................................................ */
/*----------------------------------------------------------------------*/
/*  b1crap06.p - Estorno  Talao Normal                                  */
/*----------------------------------------------------------------------*/

{dbo/bo-erro1.i}

DEF NEW SHARED VAR glb_nrcalcul  AS DECIMAL                           NO-UNDO.
DEF NEW SHARED VAR glb_stsnrcal  AS LOGICAL                           NO-UNDO.

DEF VAR glb_dsdctitg             AS CHAR                              NO-UNDO.
DEF VAR glb_cdcritic             AS INT                               NO-UNDO.
DEF VAR glb_dscritic             AS CHAR                              NO-UNDO.
                                                                      
DEF VAR i-cod-erro               AS INTE                              NO-UNDO.
DEF VAR c-desc-erro              AS CHAR                              NO-UNDO.


PROCEDURE exclui-solicitacao-entrega-talao:

    /* Nome Cooperativa      */
    DEF INPUT PARAM p-cooper         AS CHAR                          NO-UNDO.
    /* Cod. Agencia          */
    DEF INPUT PARAM p-cod-agencia    AS INT                           NO-UNDO.
    /* Nro Caixa             */
    DEF INPUT PARAM p-nro-caixa      AS INT FORMAT "999"              NO-UNDO.
    /* Nro Conta             */
    DEF INPUT PARAM p-nro-conta      AS INT FORMAT ">>>>>>>>>>>>>9"   NO-UNDO.  
    /* 1=Normal 2=TB         */
    DEF INPUT PARAM p-tprequis       AS INT                           NO-UNDO.
    /* Qtde de Talao         */
    DEF INPUT PARAM p-qtde-req-talao AS INT                           NO-UNDO.
    /* Cod Banco do Cheque   */
    DEF INPUT PARAM p-banco-chq      AS INT                           NO-UNDO.
    /* Cod Agencia do Cheque */
    DEF INPUT PARAM p-agencia-chq    AS INT                           NO-UNDO.
    /* Cheque Inicial        */
    DEF INPUT PARAM p-nro-inicial    AS INT                           NO-UNDO.
    /* Cheque Final          */
    DEF INPUT PARAM p-nro-final      AS INT                           NO-UNDO.
    /* Sistema de origem     */
    DEF INPUT PARAM p-sistema        AS CHAR                          NO-UNDO.
 
    DEF VAR aux_nrfintal             AS INT                           NO-UNDO.
    DEF VAR aux_nrseqems             LIKE crapfdc.nrseqems            NO-UNDO.
    DEF VAR aux_qttalent             AS INT                           NO-UNDO.
    DEF VAR aux_num_cheque_inicial   AS INT                           NO-UNDO.
    DEF VAR aux_num_cheque_final     AS INT                           NO-UNDO.
    DEF VAR aux_nrcheque             AS INT                           NO-UNDO.
    DEF VAR aux_nrdolote             AS INT                           NO-UNDO.

    
    IF   p-sistema = "CAIXA"   THEN
         aux_nrdolote = 19000 + p-nro-caixa.
    ELSE
         aux_nrdolote = p-nro-caixa.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    
    ASSIGN p-nro-conta  = DEC(REPLACE(STRING(p-nro-conta),".","")).

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    TRANS_1:
 
    DO WHILE TRUE TRANSACTION ON ERROR UNDO TRANS_1, LEAVE:
 
       DO WHILE TRUE:
 
          FIND craptrq WHERE craptrq.cdcooper = crapcop.cdcooper   AND
                             craptrq.cdagelot = p-cod-agencia      AND
                             craptrq.tprequis = 0                  AND
                             craptrq.nrdolote = aux_nrdolote                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
 
          IF   NOT AVAILABLE craptrq   THEN
               IF   LOCKED craptrq   THEN
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
               ELSE
                    DO:
                        ASSIGN i-cod-erro  = 63
                               c-desc-erro = "".
                             
                        UNDO TRANS_1, LEAVE.
                    END.
          LEAVE.
       END.
 
       DO WHILE TRUE:
 
          FIND crapreq WHERE crapreq.cdcooper = crapcop.cdcooper   AND
                             crapreq.dtmvtolt = crapdat.dtmvtolt   AND
                             crapreq.cdagelot = p-cod-agencia      AND
                             crapreq.tprequis = p-tprequis         AND
                             crapreq.nrdolote = aux_nrdolote       AND
                             crapreq.nrdctabb = p-nro-conta        AND
                             crapreq.nrinichq = p-nro-inicial
                             USE-INDEX crapreq1 
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
 
          IF   NOT AVAILABLE crapreq   THEN
               IF   LOCKED crapreq   THEN
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
               ELSE
                    DO:
                        ASSIGN i-cod-erro  = 66
                               c-desc-erro = "".
                             
                        UNDO TRANS_1, LEAVE.
                    END.
          LEAVE.
       END.
 
       IF   crapreq.insitreq <> 1   THEN
            DO:
                ASSIGN i-cod-erro  = 113
                       c-desc-erro = "".
 
                UNDO TRANS_1, LEAVE.
            END.
 
       ASSIGN aux_nrfintal = 0
              aux_nrseqems = 0
              aux_qttalent = 0.
 
       IF   crapreq.nrfinchq > 0   THEN
            DO:
                ASSIGN aux_num_cheque_inicial = INT(SUBSTR(STRING(
                                                       p-nro-inicial,
                                                       "9999999"),1,6))
                       aux_num_cheque_final   = INT(SUBSTR(STRING(p-nro-final,
                                                       "9999999"),1,6)).
             
                DO aux_nrcheque = aux_num_cheque_inicial TO 
                                  aux_num_cheque_final   BY 1:      
                                  
                   DO WHILE TRUE:
 
                      FIND crapfdc WHERE 
                                   crapfdc.cdcooper = crapcop.cdcooper   AND
                                   crapfdc.cdbanchq = p-banco-chq        AND
                                   crapfdc.cdagechq = p-agencia-chq      AND
                                   crapfdc.nrctachq = p-nro-conta        AND
                                   crapfdc.nrcheque = aux_nrcheque
                                   USE-INDEX crapfdc1
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                      
                      IF   NOT AVAILABLE crapfdc   THEN
                           IF   LOCKED crapfdc   THEN
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                           ELSE
                                DO:
                                    ASSIGN i-cod-erro  = 108
                                           c-desc-erro = "".
      
                                    UNDO TRANS_1, LEAVE.
                                END.
                      LEAVE.
 
                   END.
 
                   IF   crapfdc.dtemschq = ?   THEN
                        DO:
                            ASSIGN i-cod-erro  = 108
                                   c-desc-erro = "".
 
                            UNDO TRANS_1, LEAVE.
                        END.
                   ELSE
                   IF   crapfdc.dtretchq = ? THEN
                        DO:
                            ASSIGN i-cod-erro  = 109
                                   c-desc-erro = "".
 
                            UNDO TRANS_1, LEAVE.
                        END.
                   
                   ELSE
                   IF  (crapfdc.cdbantic <> 0
                   OR   crapfdc.cdagetic <> 0
                   OR   crapfdc.nrctatic <> 0)
                  AND  (crapfdc.dtlibtic >= crapdat.dtmvtolt
                   OR   crapfdc.dtlibtic  = ?) THEN
                        DO:
                            ASSIGN i-cod-erro  = 950 
                                   c-desc-erro = "".
 
                            UNDO TRANS_1, LEAVE.
                        END.
 
                   /* Atualiza o registro do cheque */
                   ASSIGN crapfdc.dtretchq = ?
                          crapfdc.cdoperad = "".

                   IF   aux_nrseqems <> crapfdc.nrseqems   THEN
                        ASSIGN aux_nrseqems = crapfdc.nrseqems
                               aux_qttalent = aux_qttalent + 1.
 
                END.  /* Fim do DO ... TO ... */
            END.
 
       DELETE crapreq.
 
       ASSIGN craptrq.qtcomprq = craptrq.qtcomprq - 1
              craptrq.qtcomptl = craptrq.qtcomptl - p-qtde-req-talao
              craptrq.qtcompen = craptrq.qtcompen - aux_qttalent.
              
       /* Para o CAIXA ON-LINE, atualiza tambem as quantidades informadas e
          exclui o registro se for necessario */
       IF   p-sistema = "CAIXA"   THEN
            DO:
                ASSIGN craptrq.qtinforq = craptrq.qtinforq - 1
                       craptrq.qtinfotl = craptrq.qtinfotl - p-qtde-req-talao
                       craptrq.qtinfoen = craptrq.qtinfoen - aux_qttalent.
                
                IF   craptrq.qtinforq <= 0   AND
                     craptrq.qtinfotl <= 0   AND
                     craptrq.qtcomprq <= 0   AND
                     craptrq.qtcomptl <= 0   THEN
                     DELETE craptrq.
            END.
 
       LEAVE.
    END.    /* Fim da transacao */

    /* Verifica se houve algum erro */
    IF   i-cod-erro  <> 0    OR
         c-desc-erro <> ""   THEN
         DO:
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE. /* Fim da exclui-solicitacao-entrega-talao */

/* .......................................................................... */
