/* .............................................................................
 
   Programa: siscaixa/web/dbo/b1crap05.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 12/12/2017

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Solicitacao/Liberacoes Taloes Normal e TB

   Alteracoes: 31/08/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)

               07/11/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks)
               
               16/11/2005 - Adequacao ao padrao, analise de performance e dos
                            itens convertidos (SQLWorks - Andre)
                            
               30/11/2005 - Acertar leitura do crapfdc (Magui)
               
               12/01/2006 - Somente solicitar/entregar se conta
                            integracao(Mirtes)
                  
               10/02/2006 - Nao permitir a requisicao para tipos de conta
                            05, 06, 07, 17 e 18 (Evandro).
               
               22/02/2006 - Unificacao dos bancos - SQLWorks - Eder   
               
               10/04/2006 - Criticar multiplos so para A4 (Magui).
               
               12/02/2007 - Adequacao ao BANCOOB e preparacao para uso tanto do
                            CAIXA ON-LINE quanto do AYLLOS (Evandro).
                            
               06/03/2007 - Verifica se o cheque esta cancelado (Ze).
               
               16/03/2007 - Fazer controles de acordo com o sistema que esta
                            chamando a BO - AYLLOS ou CAIXA ON-LINE (Evandro).
                            
               10/09/2007 - Conversao de rotina ver_capital para BO 
                            (Sidnei/Precise)

               15/02/2008 - Faz critica 860 somente no caso da solicitacao do
                            cheque for do BB (Elton).
                            
               14/11/2008 - Incluido controle de LOCK para a crapfdc e alterado
                            o tempo de espera para 3 segundos (Evandro).
                            
               29/09/2009 - Procedure valida-dados retornar a agencia do banco
                            Adaptacoes projeto IF CECRED (Guilherme).
                            
               04/03/2010 - Correcao no output par_cdagechq (Guilherme).
               
               23/09/2011 - Incluido chamada para a procedure alerta_fraude 
                            (Adriano).
                            
               15/03/2013 - Ajustes realizados:
                            - Retirado a chamada da procedure alerta_fraude 
                              dentro da solicita-entrega-talao e posto na 
                              valida-dados;
                            - Incluido os parametros p-sistema, p-operador
                              na procedure valida-dados  
                            (Adriano).             
               
               03/01/2014 - Incluido validate para as tabelas craptrq,
                            crapreq (Tiago).             
                            
               27/06/2016 - Tratamentos para utilizaçao do Cartao CECRED e 
                            PinPad Novo (Lucas Lunelli - [PROJ290])
                            
               12/12/2017 - Passar como texto o campo nrcartao na chamada da procedure 
                            pc_gera_log_ope_cartao (Lucas Ranghetti #810576)
............................................................................ */
/*----------------------------------------------------------------------*/
/*  b1crap05.p - Solicitacao/Liberacoes Taloes Normal                   */
/*----------------------------------------------------------------------*/
{dbo/bo-erro1.i}
{ sistema/generico/includes/var_internet.i }

DEF NEW SHARED VAR glb_nrcalcul  AS DECIMAL                           NO-UNDO.
DEF NEW SHARED VAR glb_stsnrcal  AS LOGICAL                           NO-UNDO.

DEF VAR glb_dsdctitg             AS CHAR                              NO-UNDO.
DEF VAR glb_cdcritic             AS INT                               NO-UNDO.
DEF VAR glb_dscritic             AS CHAR                              NO-UNDO.

DEF VAR in99                     AS INTE                              NO-UNDO.                                                                      
DEF VAR i-cod-erro               AS INTE                              NO-UNDO.
DEF VAR c-desc-erro              AS CHAR                              NO-UNDO.
DEF VAR i-nro-lote               AS INTE                              NO-UNDO.

DEF VAR h_b2crap00               AS HANDLE                            NO-UNDO.
DEF VAR h-b1crap02               AS HANDLE                            NO-UNDO.

DEF TEMP-TABLE tt-taloes
    FIELD nrtalao           AS DECI
    FIELD nrinicial         AS DECI
    FIELD nrfinal           AS DECI
    .

FUNCTION f_multiplo4 RETURN LOGICAL(INPUT par_nrinichq AS INTEGER,
                                    INPUT par_nrfimchq AS INTEGER):

   par_nrinichq = INT(TRUNC(par_nrinichq / 10, 0)).
   par_nrfimchq = INT(TRUNC(par_nrfimchq / 10, 0)).

   RETURN  ((par_nrfimchq - par_nrinichq + 1) MODULO 4) = 0 AND
            (par_nrfimchq - par_nrinichq) > 0.
END.      


PROCEDURE valida-dados:
                 
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
    /* Operador*/
    DEF INPUT PARAM p-operador       AS CHAR                          NO-UNDO.

    DEF OUTPUT PARAM par_cdagechq    AS INT                           NO-UNDO.

    DEF VAR aux_nrinital             AS INT                           NO-UNDO.
    DEF VAR aux_nrfintal             AS INT                           NO-UNDO.
    DEF VAR aux_nrdconta             AS INT                           NO-UNDO. 
    DEF VAR aux_seqatual             AS INT                           NO-UNDO.
    DEF VAR aux_contorig             AS INT                           NO-UNDO.
    DEF VAR aux_cdorigem             AS INT                           NO-UNDO.
    DEF VAR aux_dsrotina             AS CHAR                          NO-UNDO.

    DEF VAR h-b1wgen0001 AS HANDLE                                    NO-UNDO.
    DEF VAR h-b1wgen0110 AS HANDLE                                    NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    
    ASSIGN p-nro-conta = DEC(REPLACE(STRING(p-nro-conta),".","")).

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    /* Validacoes de digitos da conta e existencia do cheque inicial */
    /* Verifica o digito da conta do cheque */
    ASSIGN glb_nrcalcul = p-nro-conta.

    RUN fontes/digfun.p.

    IF NOT glb_stsnrcal   THEN
       DO:
           ASSIGN i-cod-erro  = 0
                  c-desc-erro = "008 - Digito errado(" +
                                STRING(p-nro-conta) + ")".

           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
       END.
    ELSE 
       DO:
           /* Verifica o digito podendo ser conta integração */
           ASSIGN aux_nrdconta = p-nro-conta.

           RUN fontes/digbbx.p (INPUT  p-nro-conta,
                                OUTPUT glb_dsdctitg,
                                OUTPUT glb_stsnrcal).

           IF NOT glb_stsnrcal   THEN
              DO:
                  ASSIGN i-cod-erro  = 0
                         c-desc-erro = "008 - Digito errado(" +
                                       STRING(p-nro-conta) + ")".
                  
                  RUN cria-erro (INPUT p-cooper,
                                 INPUT p-cod-agencia,
                                 INPUT p-nro-caixa,
                                 INPUT i-cod-erro,
                                 INPUT c-desc-erro,
                                 INPUT YES).
                  RETURN "NOK".
              END.
           ELSE 
           /* Verifica a numeração dos cheques */
           IF  (p-nro-inicial  = 0   AND   p-nro-final <> 0)   OR
               (p-nro-inicial <> 0   AND   p-nro-final  = 0)   OR
                p-nro-final    < p-nro-inicial                 THEN
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "129 - Numero do cheque errado(" +
                                         STRING(p-nro-inicial) + ")".
                    
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".                  
                END.
           ELSE
           /* Verifica a quantidade de talonários */
           IF p-nro-inicial = 0   AND   
              p-nro-final   = 0   THEN
              DO:
                  ASSIGN aux_nrinital = 0
                         aux_nrfintal = 0.
                  
                  FIND FIRST crappco WHERE crappco.cdcooper = crapcop.cdcooper AND 
                                           crappco.cdpartar = 34
                                           NO-LOCK NO-ERROR NO-WAIT.
                  
                  IF  NOT AVAIL crappco THEN
                      DO:
                         ASSIGN i-cod-erro  = 0
                                c-desc-erro = "Nao foi possivel obter limite de taloes.".
                         
                         RUN cria-erro (INPUT p-cooper,
                                        INPUT p-cod-agencia,
                                        INPUT p-nro-caixa,
                                        INPUT i-cod-erro,
                                        INPUT c-desc-erro,
                                        INPUT YES).
                         RETURN "NOK".
                      END.
                  
                  IF p-qtde-req-talao = 0  OR     
                     p-qtde-req-talao > INTEGER(crappco.dsconteu) THEN  
                     DO:
                         ASSIGN i-cod-erro  = 0
                                c-desc-erro = "Quantidade de taloes solicitados superior ao permitido de " + STRING(crappco.dsconteu) + " taloes".
                         
                         RUN cria-erro (INPUT p-cooper,
                                        INPUT p-cod-agencia,
                                        INPUT p-nro-caixa,
                                        INPUT i-cod-erro,
                                        INPUT c-desc-erro,
                                        INPUT YES).
                         RETURN "NOK".
                     END.
              END.
           ELSE
           /* Digito e existencia do cheque inicial */
           IF p-nro-inicial <> 0   THEN
              DO:
                  /* Digito do cheque inicial */
                  ASSIGN glb_nrcalcul = p-nro-inicial.

                  RUN fontes/digfun.p.

                  IF NOT glb_stsnrcal   THEN
                     DO:
                         ASSIGN i-cod-erro  = 0
                                c-desc-erro = "008 - Digito errado(" +
                                              STRING(p-nro-inicial) + ")".
                         
                         RUN cria-erro (INPUT p-cooper,
                                        INPUT p-cod-agencia,
                                        INPUT p-nro-caixa,
                                        INPUT i-cod-erro,
                                        INPUT c-desc-erro,
                                        INPUT YES).
                         RETURN "NOK".
                     END.
                  ELSE 
                     DO: 
                         /* Verifica se o cheque inicial existe */
                         FIND crapfdc WHERE 
                              crapfdc.cdcooper = crapcop.cdcooper   AND
                              crapfdc.cdbanchq = p-banco-chq        AND
                              crapfdc.cdagechq = p-agencia-chq      AND
                              crapfdc.nrctachq = p-nro-conta        AND
                              crapfdc.nrcheque = 
                                      INTE(SUBSTR(STRING(p-nro-inicial,
                                                  "99999999"),1,7))
                              USE-INDEX crapfdc1
                              NO-LOCK NO-ERROR.

                         IF NOT AVAILABLE crapfdc   THEN
                            DO:
                                ASSIGN i-cod-erro  = 108
                                       c-desc-erro = SUBSTR(STRING(p-nro-inicial,"99999999"),1,7).
                                
                                RUN cria-erro (INPUT p-cooper,
                                               INPUT p-cod-agencia,
                                               INPUT p-nro-caixa,
                                               INPUT i-cod-erro,
                                               INPUT c-desc-erro,
                                               INPUT YES).
                                RETURN "NOK".
                            END.
                         ELSE
                         IF crapfdc.tpcheque <> p-tprequis   THEN
                            DO:
                                ASSIGN i-cod-erro  = 513
                                       c-desc-erro = "".
                                
                                RUN cria-erro (INPUT p-cooper,
                                               INPUT p-cod-agencia,
                                               INPUT p-nro-caixa,
                                               INPUT i-cod-erro,
                                               INPUT c-desc-erro,
                                               INPUT YES).
                                RETURN "NOK".
                            END.
                         ELSE
                            DO:
                                ASSIGN aux_seqatual = crapfdc.nrseqems
                                       aux_nrdconta = crapfdc.nrdconta.
                                            
                                /* Verifica se existe cheque anterior
                                   que nao entrou (incheque = 0) e eh
                                   do mesmo sequencial de emissao */
                                FIND PREV crapfdc WHERE
                                          crapfdc.cdcooper = 
                                                  crapcop.cdcooper  AND
                                          crapfdc.cdbanchq = 
                                                  p-banco-chq       AND
                                          crapfdc.cdagechq = 
                                                  p-agencia-chq     AND
                                          crapfdc.nrctachq = 
                                                  p-nro-conta
                                          NO-LOCK NO-ERROR.
                                 
                                IF AVAILABLE crapfdc      AND
                                   crapfdc.dtretchq = ?   THEN
                                   DO:
                                       IF crapfdc.nrcheque <>
                                            INTE(SUBSTR(STRING(
                                              p-nro-inicial,
                                              "99999999"),1,7)) AND
                                          crapfdc.nrseqems  =
                                              aux_seqatual
                                          THEN
                                          DO:
                                              ASSIGN 
                                                  i-cod-erro  = 906
                                                  c-desc-erro = "".
                                              
                                              RUN cria-erro (
                                               INPUT p-cooper,
                                               INPUT p-cod-agencia,
                                               INPUT p-nro-caixa,
                                               INPUT i-cod-erro,
                                               INPUT c-desc-erro,
                                               INPUT YES).
                                               
                                              RETURN "NOK".
                                          END.
                                   END.

                            END.

                     END.

              END. /* Fim da verificacao do cheque inicial */
           ELSE
           /* Verifica se eh multiplo de 4 */
           IF  AVAILABLE crapfdc                            AND
               crapfdc.tpforchq = "A4"                      AND
               NOT f_multiplo4(p-nro-inicial,p-nro-final)   AND
              (p-nro-inicial > 0 OR
               p-nro-final   > 0)                           THEN
               DO:
                   ASSIGN p-nro-inicial = 0
                          p-nro-final   = 0.

                   ASSIGN i-cod-erro  = 859
                          c-desc-erro = "".
                   
                   RUN cria-erro (INPUT p-cooper,
                                  INPUT p-cod-agencia,
                                  INPUT p-nro-caixa,
                                  INPUT i-cod-erro,
                                  INPUT c-desc-erro,
                                  INPUT YES).
                   RETURN "NOK".
               END.

       END. /* Fim das Validacoes de digitos da conta e existencia do cheque
               inicial */

               
    FIND FIRST crappco WHERE crappco.cdcooper = crapcop.cdcooper AND 
                             crappco.cdpartar = 34
                             NO-LOCK NO-ERROR NO-WAIT.
    
    IF  NOT AVAIL crappco THEN
       DO:
           ASSIGN i-cod-erro  = 0
                  c-desc-erro = "Nao foi possivel obter limite de taloes.".
                             
          RUN cria-erro (INPUT p-cooper,
                         INPUT p-cod-agencia,
                         INPUT p-nro-caixa,
                         INPUT i-cod-erro,
                         INPUT c-desc-erro,
                         INPUT YES).
          RETURN "NOK".
        END.

    IF p-qtde-req-talao > INTEGER(crappco.dsconteu) THEN  
       DO:
          ASSIGN i-cod-erro  = 0
                 c-desc-erro = "Quantidade de taloes solicitados superior ao permitido de " + STRING(crappco.dsconteu) + " taloes".
                             
          RUN cria-erro (INPUT p-cooper,
                         INPUT p-cod-agencia,
                         INPUT p-nro-caixa,
                         INPUT i-cod-erro,
                         INPUT c-desc-erro,
                         INPUT YES).
          RETURN "NOK".

       END.

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    /* Validacoes da conta e existencia do cheque final */
    FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper   AND
                       crapass.nrdconta = aux_nrdconta       
                       NO-LOCK NO-ERROR.

    IF NOT AVAILABLE crapass   THEN
       DO:
           ASSIGN i-cod-erro  = 9
                  c-desc-erro = "".
           
           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
       END.
    ELSE
    IF crapass.dtelimin <> ?   THEN
       DO:
           ASSIGN i-cod-erro  = 410
                  c-desc-erro = "".
           
           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
       END.
    ELSE
    IF crapass.cdtipcta <= 07   OR
       crapass.cdtipcta  = 17   OR
       crapass.cdtipcta  = 18   THEN
       DO:
           ASSIGN i-cod-erro  = 17
                  c-desc-erro = "".
           
           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
       END.
    ELSE
    /* Verifica se tem conta integracao e se esta ativa  - somente p chq.BB */
    IF  p-banco-chq = 1             AND
        crapass.cdtipcta >= 12      AND
        crapass.cdtipcta <= 18      AND
       (crapass.nrdctitg  = "" OR
        crapass.flgctitg <> 2)      THEN
        DO:
            ASSIGN i-cod-erro  = 860
                   c-desc-erro = "".
            
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
    ELSE
       DO:
       
           /* Comentado Andrino/Lucas - PROJ290
           IF  crapass.inpessoa = 1         AND
              (crapass.cdtipcta = 12   OR
               crapass.cdtipcta = 13   OR            
               crapass.cdtipcta = 8    OR
               crapass.cdtipcta = 9)        AND
               p-qtde-req-talao > 2         THEN
               DO:
                   ASSIGN i-cod-erro  = 26
                          c-desc-erro = "".
                   
                   RUN cria-erro (INPUT p-cooper,
                                  INPUT p-cod-agencia,
                                  INPUT p-nro-caixa,
                                  INPUT i-cod-erro,
                                  INPUT c-desc-erro,
                                  INPUT YES).
                   RETURN "NOK".
               END.
           ELSE
           IF  crapass.inpessoa = 1         AND
              (crapass.cdtipcta = 14   OR
               crapass.cdtipcta = 15   OR      
               crapass.cdtipcta = 10   OR
               crapass.cdtipcta = 11)       AND
               p-qtde-req-talao > 4         THEN
               DO:
                   ASSIGN i-cod-erro  = 26
                          c-desc-erro = "".
                   
                   RUN cria-erro (INPUT p-cooper,
                                  INPUT p-cod-agencia,
                                  INPUT p-nro-caixa,
                                  INPUT i-cod-erro,
                                  INPUT c-desc-erro,
                                  INPUT YES).
                   RETURN "NOK".
               END.
           */

           RUN sistema/generico/procedures/b1wgen0001.p
               PERSISTENT SET h-b1wgen0001.
      
           IF VALID-HANDLE(h-b1wgen0001)   THEN
              DO:
                   RUN ver_capital IN h-b1wgen0001(INPUT  crapcop.cdcooper,
                                                   INPUT  aux_nrdconta,
                                                   INPUT  p-cod-agencia,
                                                   INPUT  p-nro-caixa,
                                                   0,
                                                   INPUT  crapdat.dtmvtolt,
                                                   INPUT  "b1crap05",
                                                   INPUT  2, /*CAIXA*/
                                                   OUTPUT TABLE tt-erro).
              
                   DELETE PROCEDURE h-b1wgen0001.
              END.
       
           /* Verifica se houve erro */
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF AVAILABLE tt-erro   THEN
              DO:
                   ASSIGN i-cod-erro  = tt-erro.cdcritic
                          c-desc-erro = tt-erro.dscritic.
                       
                   RUN cria-erro (INPUT p-cooper,
                                  INPUT p-cod-agencia,
                                  INPUT p-nro-caixa,
                                  INPUT i-cod-erro,
                                  INPUT c-desc-erro,
                                  INPUT YES).
                   RETURN "NOK".
              END.

           IF p-nro-final  > 0   THEN
              DO:
                  /* Digito do cheque final */
                  ASSIGN glb_nrcalcul = p-nro-final.

                  RUN fontes/digfun.p.

                  IF NOT glb_stsnrcal   THEN
                     DO:
                         ASSIGN i-cod-erro  = 0
                                c-desc-erro = "008 - Digito errado(" + 
                                              STRING(p-nro-final) + ")".
                         
                         RUN cria-erro (INPUT p-cooper,
                                        INPUT p-cod-agencia,
                                        INPUT p-nro-caixa,
                                        INPUT i-cod-erro,
                                        INPUT c-desc-erro,
                                        INPUT YES).
                         RETURN "NOK".
                     END.
                  ELSE
                     DO:
                         /* Verifica se o cheque final existe */
                         FIND crapfdc WHERE 
                              crapfdc.cdcooper = crapcop.cdcooper  AND
                              crapfdc.cdbanchq = p-banco-chq       AND
                              crapfdc.cdagechq = p-agencia-chq     AND
                              crapfdc.nrctachq = p-nro-conta       AND
                              crapfdc.nrcheque = 
                                      INTE(SUBSTR(STRING(p-nro-final,
                                                  "99999999"),1,7))
                              NO-LOCK NO-ERROR.

                         IF NOT AVAIL crapfdc   THEN 
                            DO: 
                                ASSIGN i-cod-erro  = 108
                                       c-desc-erro = "".
                                
                                RUN cria-erro (INPUT p-cooper,
                                               INPUT p-cod-agencia,
                                               INPUT p-nro-caixa,
                                               INPUT i-cod-erro,
                                               INPUT c-desc-erro,
                                               INPUT YES).
                                RETURN "NOK".
                            END.
                         ELSE
                            DO:
                                ASSIGN aux_seqatual = crapfdc.nrseqems.

                                /* Verifica se existe um cheque
                                   posterior que nao entrou
                                   (incheque = 0) e eh do mesmo
                                   sequencial de emissao */
                                FIND NEXT crapfdc WHERE
                                          crapfdc.cdcooper = 
                                                  crapcop.cdcooper  AND
                                          crapfdc.cdbanchq = 
                                                  p-banco-chq       AND
                                          crapfdc.cdagechq = 
                                                  p-agencia-chq     AND
                                          crapfdc.nrctachq = 
                                                  p-nro-conta
                                          USE-INDEX crapfdc1
                                          NO-LOCK NO-ERROR.
                      
                                IF AVAILABLE crapfdc      AND
                                   crapfdc.incheque = 0   AND
                                   crapfdc.tpforchq <> "FC" THEN
                                   DO:
                                       IF crapfdc.nrcheque <>
                                             INTE(SUBSTR(STRING(
                                             p-nro-final,
                                             "99999999"),1,7))  AND
                                          crapfdc.nrseqems  =
                                             aux_seqatual
                                          THEN
                                          DO:
                                              ASSIGN i-cod-erro  = 129
                                                     c-desc-erro = "".
                                              
                                              RUN cria-erro (
                                               INPUT p-cooper,
                                               INPUT p-cod-agencia,
                                               INPUT p-nro-caixa,
                                               INPUT i-cod-erro,
                                               INPUT c-desc-erro,
                                               INPUT YES).
                                               
                                              RETURN "NOK".
                                          END.

                                   END.

                            END.

                     END.

              END.      
                
           FIND crapreq WHERE crapreq.cdcooper = crapcop.cdcooper   AND
                              crapreq.dtmvtolt = crapdat.dtmvtolt   AND
                              crapreq.tprequis = p-tprequis         AND
                              crapreq.nrdctabb = p-nro-conta        AND
                              crapreq.nrinichq = p-nro-inicial      AND
                              crapreq.cdagelot = p-cod-agencia     
                              USE-INDEX crapreq2 NO-LOCK NO-ERROR.
          
           IF AVAILABLE crapreq   THEN
              IF crapreq.insitreq = 6   THEN
                 DO:
                     ASSIGN i-cod-erro  = 350
                            c-desc-erro = "".
                     
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN "NOK".
                 END.
              ELSE
                 DO:
                     ASSIGN i-cod-erro  = 68
                            c-desc-erro = "".
                     
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN "NOK".
                 END.
           
       END. /* Fim das Validacoes da conta e existencia do cheque final */
    
    IF  p-banco-chq = 1  THEN
        /* Banco do Brasil - sem DV */
        par_cdagechq = INT(SUBSTRING(STRING(crapcop.cdagedbb),1,
                           LENGTH(STRING(crapcop.cdagedbb)) - 1)).
    ELSE
    IF   p-banco-chq = 756  THEN
         par_cdagechq = crapcop.cdagebcb. /* BANCOOB */
    ELSE
    /*Se o banco informado for IF CECRED utilizar a agencia da IF CECRED */
    IF  p-banco-chq = crapcop.cdbcoctl  AND
        crapcop.cdbcoctl <> 0           THEN
        par_cdagechq = crapcop.cdagectl.
    ELSE
         par_cdagechq = 0.


    DO aux_contorig = 1 TO NUM-ENTRIES(des_dorigens):

       IF p-sistema = ENTRY(aux_contorig,des_dorigens) THEN
          ASSIGN aux_cdorigem = aux_contorig.

    END.

    
    IF NOT VALID-HANDLE(h-b1wgen0110) THEN
       RUN sistema/generico/procedures/b1wgen0110.p PERSISTENT SET h-b1wgen0110.

    /* Monta a mensagem de descricao da operacao para envio no email */
    ASSIGN aux_dsrotina = "Tentativa de solicitacao "                  +
                          "de taloes de cheque na conta "              +
                          STRING(crapass.nrdconta,"zzzz,zzz,9")        + 
                         (IF crapass.inpessoa = 1 THEN
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999")),"xxx.xxx.xxx-xx")
                          ELSE
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999999")),
                                     "xx.xxx.xxx/xxxx-xx")).

    RUN alerta_fraude IN h-b1wgen0110(INPUT crapcop.cdcooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa ,
                                      INPUT p-operador, 
                                      INPUT (IF p-sistema = "CAIXA" THEN
                                                "CAIXA-ONLINE"
                                             ELSE
                                                "LANREQ"),
                                      INPUT crapdat.dtmvtolt,
                                      INPUT aux_cdorigem,
                                      INPUT crapass.nrcpfcgc,
                                      INPUT crapass.nrdconta,
                                      INPUT 1, /*idseqttl*/
                                      INPUT TRUE, /*bloqueia operacao*/
                                      INPUT 25, /*cdoperac*/
                                      INPUT aux_dsrotina,
                                      OUTPUT TABLE tt-erro).
        
    IF VALID-HANDLE(h-b1wgen0110) THEN
       DELETE PROCEDURE(h-b1wgen0110).
    
    IF RETURN-VALUE <> "OK" THEN
       DO:
          /* Verifica se houve erro */ 
          FIND FIRST tt-erro NO-LOCK NO-ERROR.
          
          IF AVAIL tt-erro THEN
             DO: 
                ASSIGN i-cod-erro  = tt-erro.cdcritic
                       c-desc-erro = tt-erro.dscritic.
                   
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
          
             END.
          ELSE
            DO:
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Nao foi possivel verificar o " +
                                     "cadastro restritivo." .
                   
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).

            END.

          RETURN "NOK".

       END.
    
    RETURN "OK".

END PROCEDURE. /* Fim da valida-dados */


PROCEDURE solicita-entrega-talao:

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
    /* Operador              */
    DEF INPUT PARAM p-operador       AS CHAR                          NO-UNDO.
    /* Sistema de origem     */
    DEF INPUT PARAM p-sistema        AS CHAR                          NO-UNDO.
    /* CPF Terceiro     */
    DEF INPUT PARAM p-nrcpfcgc       AS CHAR                          NO-UNDO.
    /* Nome Terceiro     */
    DEF INPUT PARAM p-dsnomter       AS CHAR                          NO-UNDO.
    /* Nr. Cartao */ 
    DEF INPUT PARAM p-nrcartao       AS DECI                          NO-UNDO.
    /* Tipo Cartao */
    DEF INPUT PARAM p-idtipcar       AS INTE                          NO-UNDO.    
    /* Tabela com taloes a serem retirados */
    DEF INPUT PARAM TABLE FOR tt-taloes.
    

    DEF VAR aux_nrdconta             AS INT                           NO-UNDO. 
    DEF VAR aux_nrseqems             LIKE crapfdc.nrseqems            NO-UNDO.
    DEF VAR aux_qttalent             AS INT                           NO-UNDO.
    DEF VAR aux_tpchqerr             AS LOGICAL                       NO-UNDO.
    DEF VAR aux_nrseqdig             AS INT                           NO-UNDO.
    DEF VAR aux_nrcheque             AS INT                           NO-UNDO.
    DEF VAR aux_num_cheque_inicial   AS INT                           NO-UNDO.
    DEF VAR aux_num_cheque_final     AS INT                           NO-UNDO.
    DEF VAR aux_nrdolote             AS INT                           NO-UNDO.
    DEF VAR aux_contador             AS INT                           NO-UNDO.
    DEF VAR aux_cdcritic             AS INT                           NO-UNDO.
    DEF VAR aux_dscritic             AS CHAR                          NO-UNDO.

    IF p-sistema = "CAIXA"   THEN
       ASSIGN aux_nrdolote = 19000 + p-nro-caixa.
    ELSE
       ASSIGN aux_nrdolote = p-nro-caixa.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    
    ASSIGN p-nro-conta  = DEC(REPLACE(STRING(p-nro-conta),".",""))
           aux_nrdconta = p-nro-conta
           aux_contador = 1. /* Contador para gravar taloes somente na primeiro laço do FOR EACH */

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    /* Chamado pelo Ayllos (tela LANREQ) ou 
       Formulário Continuo ou
       Solicitaçao de talonários */
    
    IF  NOT TEMP-TABLE tt-taloes:HAS-RECORDS THEN
        DO:
            CREATE tt-taloes.
            ASSIGN tt-taloes.nrinicial = p-nro-inicial
                   tt-taloes.nrfinal   = p-nro-final.
        END.
    
    TRANS_1:
    DO WHILE TRUE TRANSACTION ON QUIT   UNDO TRANS_1, LEAVE TRANS_1
                              ON ERROR  UNDO TRANS_1, LEAVE TRANS_1
                              ON ENDKEY UNDO TRANS_1, LEAVE TRANS_1
                              ON STOP   UNDO TRANS_1, LEAVE TRANS_1:

       FOR EACH tt-taloes NO-LOCK:
                        
       ASSIGN in99 = 0.
       
           ASSIGN p-nrcpfcgc = REPLACE(p-nrcpfcgc, ".", "").
           ASSIGN p-nrcpfcgc = REPLACE(p-nrcpfcgc, "-", "").
           
       DO WHILE TRUE:            
         
          FIND craptrq WHERE craptrq.cdcooper = crapcop.cdcooper     AND
                             craptrq.cdagelot = p-cod-agencia        AND
                             craptrq.tprequis = 0                    AND
                             craptrq.nrdolote = aux_nrdolote 
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                            
          ASSIGN in99 = in99 + 1.
           
          IF NOT AVAIL craptrq   THEN 
             DO:
                 IF LOCKED craptrq   THEN 
                    DO:
                        /* Tenta por 3 segundos */
                        IF in99 < 3   THEN 
                           DO:
                               PAUSE 1 NO-MESSAGE.
                               NEXT.
                           END.
                        ELSE 
                           DO:
                               ASSIGN i-cod-erro  = 0
                                      c-desc-erro = 
                                            "Tabela CRAPTRQ em uso ".
                                            
                               RUN cria-erro (INPUT p-cooper,
                                              INPUT p-cod-agencia,
                                              INPUT p-nro-caixa,
                                              INPUT i-cod-erro,
                                              INPUT c-desc-erro,
                                              INPUT YES).
                               RETURN "NOK".
                           END.

                    END.
                 ELSE 
                    DO:
                       /* Para o AYLLOS, o registro ja deveria ter sido
                          criado na tela LOTREQ */
                       IF p-sistema = "AYLLOS"   THEN
                          DO:
                              ASSIGN i-cod-erro  = 63
                                     c-desc-erro = "".
                                     
                                  UNDO TRANS_1, LEAVE TRANS_1.
                          END.
                       ELSE
                          /* Para o CAIXA ON-LINE, a criacao do
                             registro eh automatica */
                          DO:
                              CREATE craptrq.

                              ASSIGN craptrq.cdcooper = 
                                             crapcop.cdcooper
                                     craptrq.cdagelot = p-cod-agencia
                                     craptrq.nrdolote = aux_nrdolote
                                     craptrq.tprequis = 0
                                     craptrq.nrseqdig = 0
                                     craptrq.cdoperad = p-operador.
                          END.

                    END.

             END.
         
          LEAVE.

       END. /* Fim do WHILE */

       ASSIGN aux_nrseqdig = craptrq.nrseqdig + 1.
       
           IF tt-taloes.nrinicial > 0   AND
              tt-taloes.nrfinal   > 0   THEN
          DO:
              /* Verifica o digito da conta */
              RUN fontes/digbbx.p (INPUT  p-nro-conta,
                                   OUTPUT glb_dsdctitg,
                                   OUTPUT glb_stsnrcal).

              IF NOT glb_stsnrcal   THEN
                 DO:
                     ASSIGN i-cod-erro  = 8
                            c-desc-erro = "".
                     
                         UNDO TRANS_1, LEAVE TRANS_1.
                 END.

                     /* Cheque inicial sem digito */
              ASSIGN aux_num_cheque_inicial = INT(SUBSTR(STRING(
                                                             tt-taloes.nrinicial,
                                                         "9999999"),1,6))
                     /* Cheque final sem digito */
                         aux_num_cheque_final   = INT(SUBSTR(STRING(tt-taloes.nrfinal,
                                                         "9999999"),1,6))
                     aux_nrseqems = 0
                     aux_qttalent = 0
                     aux_tpchqerr = NO.

              /* Verifica se os cheques correspondem ao tipo informado */
              FOR EACH crapfdc WHERE crapfdc.cdcooper = crapcop.cdcooper  AND
                                     crapfdc.cdbanchq = p-banco-chq       AND
                                     crapfdc.cdagechq = p-agencia-chq     AND
                                     crapfdc.nrctachq = p-nro-conta       AND
                                     crapfdc.nrcheque >= 
                                             aux_num_cheque_inicial       AND
                                     crapfdc.nrcheque <= 
                                             aux_num_cheque_final
                                     NO-LOCK:
       
                  IF crapfdc.tpcheque <> p-tprequis   THEN /* chq normal */
                     DO:
                         ASSIGN i-cod-erro  = 68
                                c-desc-erro = "".
                         
                             UNDO TRANS_1, LEAVE TRANS_1.
                     END.

                  /* Se nao tiver taloes, atualiza o talao */
                  IF tt-taloes.nrtalao = 0 THEN
                    ASSIGN tt-taloes.nrtalao = crapfdc.nrseqems.

              END.
   
              /* Faz a entrega dos cheques */
              DO aux_nrcheque = aux_num_cheque_inicial TO 
                                aux_num_cheque_final   BY 1:
   
                 ASSIGN in99 = 0.

                 DO WHILE TRUE:

                    FIND crapfdc WHERE
                                 crapfdc.cdcooper = crapcop.cdcooper   AND
                                 crapfdc.cdbanchq = p-banco-chq        AND
                                 crapfdc.cdagechq = p-agencia-chq      AND
                                 crapfdc.nrctachq = p-nro-conta        AND
                                 crapfdc.nrcheque = aux_nrcheque
                                 USE-INDEX crapfdc1
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
                    IF NOT AVAILABLE crapfdc   THEN
                       IF LOCKED crapfdc   THEN
                          DO:
                              /* Tenta por 3 segundos */
                              IF in99 = 3   THEN
                                 DO:
                                     ASSIGN i-cod-erro  = 077
                                            c-desc-erro = "".
                                    
                                         UNDO TRANS_1, LEAVE TRANS_1.
                                 END.
                              
                              PAUSE 1 NO-MESSAGE.
                              ASSIGN in99 = in99 + 1.
                              NEXT.

                          END.
                       ELSE
                          DO:
                              ASSIGN i-cod-erro  = 108
                                     c-desc-erro = "".
                              
                                  UNDO TRANS_1, LEAVE TRANS_1.

                          END.

                    LEAVE.

                 END. /* do while */         
                 
                 IF crapfdc.dtemschq = ?   THEN
                    DO:
                        ASSIGN i-cod-erro  = 224
                               c-desc-erro = "".
                        
                            UNDO TRANS_1, LEAVE TRANS_1.
                    END.
                 ELSE
                 IF crapfdc.dtretchq <> ?            AND
                    crapfdc.dtretchq <> 01/01/0001   THEN
                    DO:
                        ASSIGN i-cod-erro  = 112
                               c-desc-erro = "".
                        
                            UNDO TRANS_1, LEAVE TRANS_1.
                    END.
                 ELSE
                 IF p-nro-conta <> crapfdc.nrctachq   THEN
                    DO:
                        ASSIGN i-cod-erro  = 517
                               c-desc-erro = "".
                        
                            UNDO TRANS_1, LEAVE TRANS_1.
                    END.
                 ELSE
                 IF crapfdc.tpcheque <> p-tprequis   THEN
                    DO:
                        ASSIGN i-cod-erro  = 646
                               c-desc-erro = "".
                        
                            UNDO TRANS_1, LEAVE TRANS_1.
                    END.
                 ELSE
                 IF crapfdc.incheque = 8   THEN
                    DO:
                        ASSIGN i-cod-erro  = 320
                               c-desc-erro = "".
                        
                            UNDO TRANS_1, LEAVE TRANS_1.
                            
                    END.
     

                 /* Atualiza o registro do cheque */
                 ASSIGN crapfdc.dtretchq = crapdat.dtmvtolt
                        crapfdc.cdoperad = p-operador
                        aux_nrdconta     = crapfdc.nrdconta.
   
                 IF aux_nrseqems <> crapfdc.nrseqems   THEN
                    ASSIGN aux_nrseqems = crapfdc.nrseqems
                           aux_qttalent = aux_qttalent + 1.
       
              END.  /* Fim do DO ... TO ... */

          END.

       FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper   AND
                          crapass.nrdconta = aux_nrdconta       
                          NO-LOCK NO-ERROR.
    
       CREATE crapreq.

       ASSIGN crapreq.nrdconta = aux_nrdconta
              crapreq.nrdctabb = p-nro-conta
              crapreq.cdagelot = p-cod-agencia
              crapreq.nrdolote = aux_nrdolote
              crapreq.cdagenci = crapass.cdagenci
              crapreq.cdtipcta = crapass.cdtipcta
                  crapreq.nrinichq = tt-taloes.nrinicial
              crapreq.insitreq = 1
                  crapreq.nrfinchq = tt-taloes.nrfinal
                  crapreq.qtreqtal = IF aux_contador = 1 THEN p-qtde-req-talao ELSE 0
              crapreq.nrseqdig = aux_nrseqdig
              crapreq.dtmvtolt = crapdat.dtmvtolt
              crapreq.tprequis = p-tprequis
              crapreq.tpformul = 1
              crapreq.cdcooper = crapcop.cdcooper
              crapreq.cdoperad = p-operador
              crapreq.dtpedido = crapdat.dtmvtolt
    
              craptrq.qtcomprq = craptrq.qtcomprq + 1
                  craptrq.qtcomptl = IF aux_contador = 1 THEN (craptrq.qtcomptl + p-qtde-req-talao) ELSE craptrq.qtcomptl
              craptrq.qtcompen = craptrq.qtcompen + aux_qttalent
              craptrq.nrseqdig = aux_nrseqdig.
              
       VALIDATE crapreq.

       /* Para o CAIXA ON-LINE, atualiza tambem as quantidades informadas */
       IF p-sistema = "CAIXA"   THEN
          ASSIGN craptrq.qtinforq = craptrq.qtinforq + 1
                     craptrq.qtinfotl = IF aux_contador = 1 THEN (craptrq.qtinfotl + p-qtde-req-talao) ELSE craptrq.qtinfotl
                 craptrq.qtinfoen = craptrq.qtinfoen + aux_qttalent.

       VALIDATE craptrq.

           /* GERAÇAO DE LOG para cada talao processado */    
           { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
          
           RUN STORED-PROCEDURE pc_gera_log_ope_cartao
               aux_handproc = PROC-HANDLE NO-ERROR
                                      (INPUT crapcop.cdcooper, /* Código da Cooperativa */
                                       INPUT p-nro-conta,     /* Numero da Conta */ 
                                       INPUT 5,                /* Solicitaçao Taloes */
                                       INPUT IF p-sistema = "CAIXA" THEN 2 ELSE 1,
                                       INPUT p-idtipcar,
                                       INPUT aux_nrdolote,      /* Nrd Documento */               
                                       INPUT 0, 
                                       INPUT STRING(p-nrcartao),
                                       INPUT IF aux_contador = 1 THEN p-qtde-req-talao ELSE 0,
                                       INPUT p-operador,   /* Código do Operador */
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT p-cod-agencia,
                                       INPUT tt-taloes.nrtalao,
                                       INPUT p-dsnomter,
                                       INPUT DECI(p-nrcpfcgc),
                                      OUTPUT "").              /* Descriçao da crítica */

           /* Código da crítica */    
           CLOSE STORED-PROC pc_gera_log_ope_cartao
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
          
           { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
          
           ASSIGN aux_cdcritic = 0
                  aux_dscritic = ""           
                  aux_dscritic = pc_gera_log_ope_cartao.pr_dscritic
                                WHEN pc_gera_log_ope_cartao.pr_dscritic <> ?.
                                
           IF (aux_dscritic <> "" AND aux_dscritic <> ?) THEN
              DO:                 
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = aux_dscritic.
                         
                    UNDO TRANS_1, LEAVE TRANS_1.
              END.
       
           ASSIGN aux_contador = aux_contador + 1. /* incremento de contador */
       
       END. /* for each tt-taloes */
       
       LEAVE.

    END.    /* Fim da transacao */

    /* Verifica se houve algum erro */
    IF i-cod-erro  <> 0    OR
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
         
    ASSIGN i-cod-erro  = 0 
           c-desc-erro = "Operacao realizada com sucesso.".

    RUN cria-erro (INPUT p-cooper,
                   INPUT p-cod-agencia,
                   INPUT p-nro-caixa,
                   INPUT i-cod-erro,
                   INPUT c-desc-erro,
                   INPUT YES).
         
    RETURN "OK".

END PROCEDURE. /* Fim da solicita-entrega-talao */

/******************************************************************************/

PROCEDURE calcula-digito:

     DEF INPUT  PARAM p-cooper                  AS CHAR         NO-UNDO.
     DEF INPUT  PARAM p-cod-agencia             AS INTE         NO-UNDO.
     DEF INPUT  PARAM p-nro-caixa               AS INTE         NO-UNDO.
     DEF INPUT  PARAM p-nrdconta                AS INTE         NO-UNDO.
     DEF INPUT  PARAM p-banco                   AS INTE         NO-UNDO.     
     DEF OUTPUT PARAM p-nrcalcul                AS INTE         NO-UNDO.
     DEF OUTPUT PARAM p-agencia                 AS CHAR         NO-UNDO.
     
     DEF VAR aux_stsnrcal        AS LOGICAL            NO-UNDO.
     DEF VAR v-dscalcul        AS CHARACTER          NO-UNDO.
     
     RUN elimina-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa).
     
     /* Banco do Brasil - sem DV */
     IF p-banco = 1   THEN
        DO:
            /* Procura pela conta integração */
            ASSIGN p-nrcalcul = INT(p-nrdconta).

            RUN fontes/digbbx.p (INPUT  p-nrcalcul,
                                 OUTPUT v-dscalcul,
                                 OUTPUT aux_stsnrcal).

            FIND crapass WHERE
                 crapass.cdcooper = crapcop.cdcooper AND
                 crapass.nrdctitg = v-dscalcul
                 NO-LOCK NO-ERROR.

            ASSIGN p-agencia = SUBSTRING(
                               STRING(crapcop.cdagedbb),
                                1,LENGTH(STRING(
                                crapcop.cdagedbb)) - 1).
        END.
     ELSE
        DO:
          /* Procura pela conta corrente */
          FIND crapass WHERE
               crapass.cdcooper = crapcop.cdcooper AND
               crapass.nrdconta = INT(p-nrdconta)
               NO-LOCK NO-ERROR.  

          /* BANCOOB */
          IF p-banco = 756   THEN
             ASSIGN p-agencia = STRING(crapcop.cdagebcb).
          ELSE
             DO: /* IF CECRED */
                IF p-banco = crapcop.cdbcoctl  AND
                   p-banco <> 0                THEN
                   ASSIGN p-agencia = STRING(crapcop.cdagectl).
                ELSE
                   ASSIGN p-agencia = "0".
             END.

        END.
        
     RETURN "OK".
     
END PROCEDURE.


PROCEDURE retorna-taloes:

     DEF INPUT  PARAM p-cooper                  AS CHAR         NO-UNDO.
     DEF INPUT  PARAM p-cod-agencia             AS INTE         NO-UNDO.
     DEF INPUT  PARAM p-nro-caixa               AS INTE         NO-UNDO.
     DEF INPUT  PARAM p-nrdconta                AS INTE         NO-UNDO.
     DEF INPUT  PARAM p-banco                   AS INTE         NO-UNDO.     
     DEF INPUT  PARAM p-tprequis                AS INTE         NO-UNDO.
     DEF OUTPUT PARAM TABLE FOR tt-taloes.
     
     DEF BUFFER crabfdc  FOR crapfdc. 
     DEF BUFFER crapfdc2 FOR crapfdc. 
     
     DEF VAR aux_stsnrcal        AS LOGICAL            NO-UNDO.
     
     FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
     
     RUN elimina-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa).                                             
                            
     FOR EACH crapfdc2 WHERE crapfdc2.cdcooper =  crapcop.cdcooper AND
                             crapfdc2.cdbanchq =  p-banco          AND
                             crapfdc2.nrctachq =  p-nrdconta       AND 
                             crapfdc2.tpcheque =  p-tprequis       AND
                             crapfdc2.dtretchq =  ?                AND
                             crapfdc2.dtemschq <> ?                AND
                             crapfdc2.incheque <> 8                AND /* cancelado */
                             crapfdc2.tpforchq <> 'FC'
                             NO-LOCK 
                             BREAK BY (crapfdc2.nrseqems).
                     
         IF  FIRST-OF (crapfdc2.nrseqems) THEN
             DO:
                 FIND FIRST crapfdc WHERE crapfdc.cdcooper = crapcop.cdcooper   AND
                                          crapfdc.cdbanchq = p-banco            AND
                                          crapfdc.cdagechq = crapfdc2.cdagechq  AND
                                          crapfdc.nrctachq = p-nrdconta         AND
                                          crapfdc.tpcheque = p-tprequis         AND
                                          crapfdc.dtretchq =  ?                 AND
                                          crapfdc.dtemschq <> ?                 AND
                                          crapfdc.incheque <> 8                 AND
                                          crapfdc.tpforchq <> 'FC'              AND
                                          crapfdc.nrseqems = crapfdc2.nrseqems
                                          NO-LOCK NO-ERROR.
                                          
                 IF  AVAIL crapfdc THEN
                     DO:
                        ASSIGN glb_nrcalcul = (crapfdc.nrcheque * 10).
                        RUN fontes/digfun.p.
                        
                        CREATE tt-taloes.
                        ASSIGN tt-taloes.nrtalao    = crapfdc.nrseqems
                               tt-taloes.nrinicial  = glb_nrcalcul.
                               
                        FIND LAST crabfdc WHERE crabfdc.cdcooper = crapfdc.cdcooper  AND
                                                crabfdc.cdbanchq = crapfdc.cdbanchq  AND                                                
                                                crabfdc.cdagechq = crapfdc.cdagechq  AND
                                                crabfdc.nrctachq = crapfdc.nrctachq  AND
                                                crabfdc.tpcheque = crapfdc.tpcheque  AND                                                
                                                crabfdc.dtretchq = crapfdc.dtretchq  AND
                                                crabfdc.dtemschq = crapfdc.dtemschq  AND
                                                crabfdc.incheque = crapfdc.incheque  AND
                                                crabfdc.tpforchq = crapfdc.tpforchq  AND
                                                crabfdc.nrseqems = crapfdc.nrseqems
                                                NO-LOCK NO-ERROR.
                                                
                        IF  AVAIL crabfdc THEN
                            DO:
                                ASSIGN glb_nrcalcul = (crabfdc.nrcheque * 10).
                                RUN fontes/digfun.p.
                                
                                ASSIGN tt-taloes.nrfinal = glb_nrcalcul.
                            END.                        
                     END.
                     
                 RELEASE crapfdc.
                 RELEASE crabfdc.
                     
             END. /* FIRST-OF */
     END. /* for each */
         
     RELEASE crapfdc2.
        
     RETURN "OK".
     
END PROCEDURE.

     
PROCEDURE verifica-conta:

     DEF INPUT  PARAM p-cooper                  AS CHAR         NO-UNDO.
     DEF INPUT  PARAM p-cod-agencia             AS INTE         NO-UNDO.
     DEF INPUT  PARAM p-nro-caixa               AS INTE         NO-UNDO.
     DEF INPUT  PARAM p-nrdconta                AS INTE         NO-UNDO.
     DEF OUTPUT PARAM p-nometit1                AS CHAR         NO-UNDO.
     DEF OUTPUT PARAM p-cpfcnpj1                AS CHAR         NO-UNDO.
     DEF OUTPUT PARAM p-nometit2                AS CHAR         NO-UNDO.
     DEF OUTPUT PARAM p-cpfcnpj2                AS CHAR         NO-UNDO.

     FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
     
     RUN elimina-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa).
     
     FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                        crapass.nrdconta = p-nrdconta  
                        NO-LOCK NO-ERROR.
                        
     IF  AVAIL crapass  THEN
         DO: 
             IF  crapass.dtdemiss <> ? THEN
                 DO:
                     ASSIGN i-cod-erro  = 64
                            c-desc-erro = " ".
                               
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     
                     RETURN "NOK".
                 END.
             
             IF crapass.inpessoa = 1  THEN DO:
                FIND FIRST crapttl WHERE crapttl.cdcooper = crapcop.cdcooper
                                     AND crapttl.nrdconta = crapass.nrdconta
                                     AND crapttl.idseqttl = 2 /* Dados do Segundo Titular */
                                     USE-INDEX crapttl1 
                                     NO-LOCK NO-ERROR.
                IF  AVAIL crapttl THEN
                    ASSIGN  p-nometit2    = crapttl.nmextttl
                            p-cpfcnpj2 = STRING(crapttl.nrcpfcgc,"99999999999")
                            p-cpfcnpj2 = STRING(p-cpfcnpj2,"xxx.xxx.xxx-xx").
             END.
             ELSE DO:
                FIND FIRST crapjur WHERE crapjur.cdcooper = crapcop.cdcooper
                                     AND crapjur.nrdconta = crapass.nrdconta
                                     NO-LOCK NO-ERROR.

                IF  AVAIL crapttl THEN
                    ASSIGN  p-nometit2    = crapjur.nmextttl.
             END.              
             
             ASSIGN  p-nometit1    = crapass.nmprimtl.
    
             IF   crapass.inpessoa = 1   THEN
                  ASSIGN p-cpfcnpj1 = STRING(crapass.nrcpfcgc,"99999999999")
                         p-cpfcnpj1 = STRING(p-cpfcnpj1, "xxx.xxx.xxx-xx").
             ELSE
                  ASSIGN p-cpfcnpj1 = STRING(crapass.nrcpfcgc,"99999999999999")
                         p-cpfcnpj1 = STRING(p-cpfcnpj1,"xx.xxx.xxx/xxxx-xx"). 
             
         END. /** Fim avail crapass **/
     ELSE 
         DO: 
              ASSIGN i-cod-erro  = 9
                     c-desc-erro = " ".
                     
              RUN cria-erro (INPUT p-cooper,
                             INPUT p-cod-agencia,
                             INPUT p-nro-caixa,
                             INPUT i-cod-erro,
                             INPUT c-desc-erro,
                             INPUT YES).
              RETURN "NOK".
         END.
         
     RETURN "OK".

END PROCEDURE.



PROCEDURE retorna-conta-cartao:
    
    DEF INPUT        PARAM p-cooper              AS CHAR.
    DEF INPUT        PARAM p-cod-agencia         AS INTEGER.  /* Cod. Agencia    */
    DEF INPUT        PARAM p-nro-caixa           AS INTEGER.  /* Numero Caixa    */
    DEF INPUT        PARAM p-cartao              AS DEC.      /* Nro Cartao */
    DEF OUTPUT       PARAM p-nro-conta           AS DEC.      /* Nro Conta       */
    DEF OUTPUT       PARAM p-nrcartao            AS DECI.
    DEF OUTPUT       PARAM p-idtipcar            AS INTE.
                      
    DEF VAR h-b1wgen0025 AS HANDLE               NO-UNDO.
    DEF VAR aux_dscartao AS CHAR                 NO-UNDO.

    DEF VAR aux_nrcartao AS DEC                  NO-UNDO.
    DEF VAR aux_nrdconta AS INT                  NO-UNDO.
    DEF VAR aux_cdcooper AS INT                  NO-UNDO.
    DEF VAR aux_inpessoa AS INT                  NO-UNDO.
    DEF VAR aux_idsenlet AS LOGICAL              NO-UNDO.
    DEF VAR aux_idseqttl AS INT                  NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                 NO-UNDO.  
    DEF VAR i_conta      AS DEC                   NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.

    ASSIGN p-nro-conta = INT(REPLACE(STRING(p-nro-conta),".","")).

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    ASSIGN i-nro-lote = 11000 + p-nro-caixa.
  
    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.
 
    IF   p-cartao = 0   THEN      
          DO:
              ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Numero do cartao deve ser Informado".           
              RUN cria-erro (INPUT p-cooper,
                             INPUT p-cod-agencia,
                             INPUT p-nro-caixa,
                             INPUT i-cod-erro,
                             INPUT c-desc-erro,
                             INPUT YES).
              RETURN "NOK".
          END.
          
     ASSIGN aux_dscartao = "XX" + SUBSTR(STRING(p-cartao),1,16) + "=" + SUBSTR(STRING(p-cartao),17).
          
     RUN sistema/generico/procedures/b1wgen0025.p 
         PERSISTENT SET h-b1wgen0025.
         
     RUN verifica_cartao IN h-b1wgen0025(INPUT crapcop.cdcooper,
                                         INPUT 0,
                                         INPUT aux_dscartao, 
                                         INPUT crapdat.dtmvtolt,
                                        OUTPUT p-nro-conta,
                                        OUTPUT aux_cdcooper,
                                        OUTPUT p-nrcartao,
                                        OUTPUT aux_inpessoa,
                                        OUTPUT aux_idsenlet,
                                        OUTPUT aux_idseqttl,
                                        OUTPUT p-idtipcar,
                                        OUTPUT aux_dscritic).

     DELETE PROCEDURE h-b1wgen0025.
     
     IF   RETURN-VALUE <> "OK"   THEN /* Se retornou erro */
          DO:
              RUN cria-erro (INPUT p-cooper,
                             INPUT p-cod-agencia,
                             INPUT p-nro-caixa,
                             INPUT i-cod-erro,
                             INPUT aux_dscritic,
                             INPUT YES).
              RETURN "NOK".
          END.
    
    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.
    
    ASSIGN i_conta = p-nro-conta.

    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT i_conta).
    DELETE PROCEDURE h_b2crap00.

    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    RUN dbo/b1crap02.p PERSISTENT SET h-b1crap02.

    RUN retornaCtaTransferencia IN h-b1crap02 (INPUT p-cooper,
                                               INPUT p-cod-agencia, 
                                               INPUT p-nro-caixa, 
                                               INPUT p-nro-conta, 
                                              OUTPUT aux_nrdconta).
    IF   RETURN-VALUE = "NOK" THEN 
         DO:
             DELETE PROCEDURE h-b1crap02.
             RETURN "NOK".
         END.
         
    IF   aux_nrdconta <> 0 THEN
         ASSIGN p-nro-conta = aux_nrdconta.
    
    RETURN "OK".

END PROCEDURE.


PROCEDURE valida_senha_cartao: 
    
    DEF INPUT  PARAM p-cooper           AS CHAR.
    DEF INPUT  PARAM p-cod-agencia      AS INTE.
    DEF INPUT  PARAM p-nro-caixa        AS INTE.
    DEF INPUT  PARAM p-nro-conta        AS DEC.     
    DEF INPUT  PARAM p-nrcartao         AS DECI.
    DEF INPUT  PARAM p-opcao            AS CHAR.
    DEF INPUT  PARAM p-senha-cartao     AS CHAR.
    DEF INPUT  PARAM p-idtipcar         AS INTE.
    DEF INPUT  PARAM p-infocry          AS CHAR.
    DEF INPUT  PARAM p-chvcry           AS CHAR.
    
    DEF VAR h-b1wgen0025 AS HANDLE                                NO-UNDO.
    
    DEF VAR aux_cdcritic AS INTE                                  NO-UNDO.    
    DEF VAR aux_dscritic AS CHAR                                  NO-UNDO.
    
    ASSIGN p-nro-conta = DEC(REPLACE(STRING(p-nro-conta),".","")).
           
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
     
    IF   p-opcao = "C"   THEN
         DO:
            IF  TRIM(p-senha-cartao) = '' THEN
                DO:
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT 0,
                                   INPUT "Insira uma senha.",
                                   INPUT YES).
                     RETURN "NOK".
                END.
				
            RUN sistema/generico/procedures/b1wgen0025.p 
                 PERSISTENT SET h-b1wgen0025.
                 
            RUN valida_senha_tp_cartao IN h-b1wgen0025(INPUT crapcop.cdcooper,
                                                       INPUT p-nro-conta, 
                                                       INPUT p-nrcartao,
                                                       INPUT p-idtipcar,
                                                       INPUT p-senha-cartao,
                                                       INPUT p-infocry,
                                                       INPUT p-chvcry,
                                                      OUTPUT aux_cdcritic,
                                                      OUTPUT aux_dscritic). 

            DELETE PROCEDURE h-b1wgen0025.
           
            IF   RETURN-VALUE <> "OK"   THEN /* Se retornou erro */
                 DO:
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT aux_cdcritic,
                                    INPUT aux_dscritic,
                                    INPUT YES).
                     RETURN "NOK".
                 END.
         END.
         
    RETURN "OK".
    
END PROCEDURE.


PROCEDURE busca-info-terceiro:

     DEF INPUT         PARAM p-cooper                  AS CHAR         NO-UNDO.
     DEF INPUT         PARAM p-cod-agencia             AS INTE         NO-UNDO.
     DEF INPUT         PARAM p-nro-caixa               AS INTE         NO-UNDO.
     DEF INPUT-OUTPUT  PARAM p-nrcpfcgc                AS CHAR         NO-UNDO.     
     DEF OUTPUT        PARAM p-dsnomcop                AS CHAR         NO-UNDO.
     DEF OUTPUT        PARAM p-nrdconta                AS CHAR         NO-UNDO.
     
     DEFINE VARIABLE h-b1wgen9999 AS HANDLE              NO-UNDO.
     
     DEF VAR aux_stsnrcal         AS LOGI                NO-UNDO.
     DEF VAR aux_inpessoa         AS INTE                NO-UNDO.

     FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
     
     RUN elimina-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa).

     ASSIGN p-nrcpfcgc = REPLACE(p-nrcpfcgc, ".", "").
     ASSIGN p-nrcpfcgc = REPLACE(p-nrcpfcgc, "-", "").
     
     RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
     RUN valida-cpf-cnpj IN h-b1wgen9999 (INPUT p-nrcpfcgc,
                                         OUTPUT aux_stsnrcal,
                                         OUTPUT aux_inpessoa).
     DELETE PROCEDURE h-b1wgen9999.
     
     IF  RETURN-VALUE <> "OK" OR 
         aux_stsnrcal <> YES  THEN
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Digito verificador do CPF invalido".
                       
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             
             RETURN "NOK".
         END.
                       
     FIND FIRST crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                              crapass.nrcpfcgc = DECI(p-nrcpfcgc)
                              NO-LOCK NO-ERROR.
                              
     IF  AVAIL crapass  THEN
        ASSIGN p-nrdconta = STRING(crapass.nrdconta, "zzzz,zzz,9")                       
               p-dsnomcop = crapass.nmprimtl.
         
    ASSIGN p-nrcpfcgc = STRING(p-nrcpfcgc,"99999999999")
           p-nrcpfcgc = STRING(p-nrcpfcgc,"999.999.999-99").

    RETURN "OK".
    
END PROCEDURE

/* .......................................................................... */
  
