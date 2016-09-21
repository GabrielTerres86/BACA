/* .............................................................................
 
   Programa: siscaixa/web/dbo/b1crap05.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 03/01/2014

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
                  
                  IF p-qtde-req-talao = 0  OR     
                     p-qtde-req-talao > 10 THEN  
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

    IF p-qtde-req-talao > 10 THEN  
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
    

    DEF VAR aux_nrdconta             AS INT                           NO-UNDO. 
    DEF VAR aux_nrseqems             LIKE crapfdc.nrseqems            NO-UNDO.
    DEF VAR aux_qttalent             AS INT                           NO-UNDO.
    DEF VAR aux_tpchqerr             AS LOGICAL                       NO-UNDO.
    DEF VAR aux_nrseqdig             AS INT                           NO-UNDO.
    DEF VAR aux_nrcheque             AS INT                           NO-UNDO.
    DEF VAR aux_num_cheque_inicial   AS INT                           NO-UNDO.
    DEF VAR aux_num_cheque_final     AS INT                           NO-UNDO.
    DEF VAR aux_nrdolote             AS INT                           NO-UNDO.

    
    IF p-sistema = "CAIXA"   THEN
       ASSIGN aux_nrdolote = 19000 + p-nro-caixa.
    ELSE
       ASSIGN aux_nrdolote = p-nro-caixa.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    
    ASSIGN p-nro-conta  = DEC(REPLACE(STRING(p-nro-conta),".",""))
           aux_nrdconta = p-nro-conta.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    
    TRANS_1:

    DO WHILE TRUE TRANSACTION ON ERROR UNDO TRANS_1, LEAVE:
                        
       ASSIGN in99 = 0.
       
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
                                     
                              UNDO TRANS_1, LEAVE.
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
       
       IF p-nro-inicial > 0   AND
          p-nro-final   > 0   THEN
          DO:
              /* Verifica o digito da conta */
              RUN fontes/digbbx.p (INPUT  p-nro-conta,
                                   OUTPUT glb_dsdctitg,
                                   OUTPUT glb_stsnrcal).

              IF NOT glb_stsnrcal   THEN
                 DO:
                     ASSIGN i-cod-erro  = 8
                            c-desc-erro = "".
                     
                     UNDO TRANS_1, LEAVE.
                 END.

                     /* Cheque inicial sem digito */
              ASSIGN aux_num_cheque_inicial = INT(SUBSTR(STRING(
                                                         p-nro-inicial,
                                                         "9999999"),1,6))
                     /* Cheque final sem digito */
                     aux_num_cheque_final   = INT(SUBSTR(STRING(p-nro-final,
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
                         
                         UNDO TRANS_1, LEAVE.
                     END.

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
                                    
                                     UNDO TRANS_1, LEAVE.
                                 END.
                              
                              PAUSE 1 NO-MESSAGE.
                              ASSIGN in99 = in99 + 1.
                              NEXT.

                          END.
                       ELSE
                          DO:
                              ASSIGN i-cod-erro  = 108
                                     c-desc-erro = "".
                              
                              UNDO TRANS_1, LEAVE.

                          END.

                    LEAVE.

                 END. /* do while */         
                 
                 IF crapfdc.dtemschq = ?   THEN
                    DO:
                        ASSIGN i-cod-erro  = 224
                               c-desc-erro = "".
                        
                        UNDO TRANS_1, LEAVE.
                    END.
                 ELSE
                 IF crapfdc.dtretchq <> ?            AND
                    crapfdc.dtretchq <> 01/01/0001   THEN
                    DO:
                        ASSIGN i-cod-erro  = 112
                               c-desc-erro = "".
                        
                        UNDO TRANS_1, LEAVE.
                    END.
                 ELSE
                 IF p-nro-conta <> crapfdc.nrctachq   THEN
                    DO:
                        ASSIGN i-cod-erro  = 517
                               c-desc-erro = "".
                        
                        UNDO TRANS_1, LEAVE.
                    END.
                 ELSE
                 IF crapfdc.tpcheque <> p-tprequis   THEN
                    DO:
                        ASSIGN i-cod-erro  = 646
                               c-desc-erro = "".
                        
                        UNDO TRANS_1, LEAVE.
                    END.
                 ELSE
                 IF crapfdc.incheque = 8   THEN
                    DO:
                        ASSIGN i-cod-erro  = 320
                               c-desc-erro = "".
                        
                        UNDO TRANS_1, LEAVE.
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
              crapreq.nrinichq = p-nro-inicial
              crapreq.insitreq = 1
              crapreq.nrfinchq = p-nro-final
              crapreq.qtreqtal = p-qtde-req-talao
              crapreq.nrseqdig = aux_nrseqdig
              crapreq.dtmvtolt = crapdat.dtmvtolt
              crapreq.tprequis = p-tprequis
              crapreq.tpformul = 1
              crapreq.cdcooper = crapcop.cdcooper
              crapreq.cdoperad = p-operador
              crapreq.dtpedido = crapdat.dtmvtolt
    
              craptrq.qtcomprq = craptrq.qtcomprq + 1
              craptrq.qtcomptl = craptrq.qtcomptl + p-qtde-req-talao
              craptrq.qtcompen = craptrq.qtcompen + aux_qttalent
              craptrq.nrseqdig = aux_nrseqdig.
              
       VALIDATE crapreq.

       /* Para o CAIXA ON-LINE, atualiza tambem as quantidades informadas */
       IF p-sistema = "CAIXA"   THEN
          ASSIGN craptrq.qtinforq = craptrq.qtinforq + 1
                 craptrq.qtinfotl = craptrq.qtinfotl + p-qtde-req-talao
                 craptrq.qtinfoen = craptrq.qtinfoen + aux_qttalent.

       VALIDATE craptrq.

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
         
    RETURN "OK".

END PROCEDURE. /* Fim da solicita-entrega-talao */

/* .......................................................................... */
  
