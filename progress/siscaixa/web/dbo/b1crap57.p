/* .............................................................................

   Programa: siscaixa/web/dbo/b1crap057.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 12/06/2018

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Depositos Cheques Liberados(Varios) 

   Alteracoes: 17/08/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)
               
               07/11/2005 - Alteracao de crapchq e crapchs p/ crapfdc 
                            (SQLWorks - Eder)         
               
               19/11/2005 - Adequacao ao padrao, analise de performance e dos
                            itens convertidos (SQLWorks - Andre)
               
               23/11/2005 - Acessos ao crapfdc (Magui)
               
               24/02/2006 - Unificacao dos bancos - SQLWorks - Eder
                   
               26/02/2007 - Alterado o FIND da crapfdc (Evandro).
               
               23/05/2007 - Substituido campo crapass.nrctainv pelo campo
                            crapass.nrdconta nos FIND's (Elton).

               10/09/2007 - Conversao de rotina ver_capital para BO 
                            (Sidnei/Precise)
               
               29/01/2008 - Incluido PA do cooperado na impressao da
                            autenticacao (Elton).

               22/12/2008 - Ajustes para unificacao dos bancos de dados
                            (Evandro).
                            
               04/06/2009 - Alteracao CDOPERAD (Diego).
               
               09/10/2009 - Adaptacoes projeto IF CECRED (Guilherme).
               
               29/10/2010 - Chama rotina atualiza-previa-caixa (Elton).
               
               22/12/2010 - Quando caixa da Viacredi não permitir cheques de 
                            cooperados da Acredi migrados (Guilherme).               
                            
               15/02/2011 - Alimentar ":" ao fim do CMC7 somente se ele possuir 
                            LENGTH 34 (Guilherme).
                            
               18/06/2012 - Alteracao na leitura da craptco (David Kruger).
               
               10/10/2012 - Alteracao da logica para migracao de PA
                            devido a migracao da AltoVale (Guilherme).
                            
               03/01/2014 - Incluido validate para as tabelas craplcm
                            craplci crapsli crapmdw crapmrw (Tiago).
                            
               15/01/2014 - Ajuste leitura craptco (Daniel).
               
               05/08/2014 - Alteração da Nomeclatura para PA (Vanessa). 
               
               09/09/2014 - #198254 Incorporacao concredi e credimilsul (Carlos)
               
               29/10/2015 - Adicionado validacao para que cheques do banco 479 sejam
                            ignorados, conforme solicitado no chamado 329206. (Kelvin)
                                           
			   26/04/2016 - Inclusao dos horarios de SAC e OUVIDORIA nos
			                comprovantes, melhoria 112 (Tiago/Elton)                                            

               20/06/2016 - Adicionado validacao para nao permitir o recebimento 
                            de cheques de bancos que nao participam da COMPE
                            (Douglas - Chamado 417655)
                            
               27/07/2016 - Alterado validacao para nao permitir o recebimento 
                            de cheques de bancos que nao participam da COMPE
                            Utilizar apenas BANCO e FLAG ativo
                            (Douglas - Chamado 417655)

			   17/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).

               16/03/2018 - Substituida verificacao "cdtipcta = 6,7" pela
                            modalidade do tipo de conta igual a 3. PRJ366 (Lombardi).
                            
               25/05/2018 - Alteraçoes para usar as rotinas mesmo com o processo 
                            norturno rodando (Douglas Pagel - AMcom).



               12/06/2018 - P450 - Chamada da rotina para consistir lançamento em conta corrente(LANC0001) na tabela CRAPLCM  - José Carvalho(AMcom)
               
               16/01/2019 - Revitalizacao (Remocao de lotes) - Pagamentos, Transferencias, Poupanca
                     Heitor (Mouts)

............................................................................ */
/*-------------------------------------------------------------------------*/
/* b1crap57.p   - Depositos Cheques Liberados(Varios)                      */  
/* Historico    - 372                                                      */
/*-------------------------------------------------------------------------*/

{dbo/bo-erro1.i}
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0200tt.i }

DEF VAR h-b1wgen0001 AS HANDLE                                         NO-UNDO.

DEF  VAR glb_nrcalcul           AS DECIMAL                             NO-UNDO.
DEF  VAR glb_dsdctitg           AS CHAR                                NO-UNDO.
DEF  VAR glb_stsnrcal           AS LOGICAL                             NO-UNDO.
DEF  VAR aux_nrctainv           AS INTEGER                             NO-UNDO.

DEF TEMP-TABLE w-compel                                                NO-UNDO
    FIELD cdcooper AS INT     FORMAT "zz9"
    FIELD dsdocmc7 AS CHAR    FORMAT "X(34)"
    FIELD cdcmpchq AS INT     FORMAT "zz9"
    FIELD cdbanchq AS INT     FORMAT "zz9"
    FIELD cdagechq AS INT     FORMAT "zzz9"
    FIELD nrddigc1 AS INT     FORMAT "9"   
    FIELD nrctaaux AS INT     
    FIELD nrctachq AS DECIMAL FORMAT "zzz,zzz,zzz,9"
    FIELD nrctabdb AS DECIMAL FORMAT "zzz,zzz,zzz,9"
    FIELD nrdctitg LIKE crapfdc.nrdctitg
    FIELD nrddigc2 AS INT     FORMAT "9"            
    FIELD nrcheque AS INT     FORMAT "zzz,zz9"      
    FIELD nrddigc3 AS INT     FORMAT "9"            
    FIELD vlcompel AS DECIMAL FORMAT "zzz,zzz,zz9.99"
    FIELD dtlibcom AS DATE    FORMAT "99/99/9999"
    FIELD lsdigctr AS CHAR
    FIELD tpdmovto AS INTE
    FIELD nrseqdig AS INTE
    FIELD cdtipchq AS INTE
    FIELD nrposchq AS INTE
    INDEX compel1 AS UNIQUE PRIMARY
          dsdocmc7
    INDEX compel2 AS UNIQUE
          nrseqdig DESCENDING.

DEF VAR de-valor-libera         AS DEC                                 NO-UNDO.
DEF VAR i-cod-erro              AS INT                                 NO-UNDO.
DEF VAR c-desc-erro             AS CHAR                                NO-UNDO.

DEF VAR h_b2crap00              AS HANDLE                              NO-UNDO.

DEF VAR p-nro-calculado         AS DEC                                 NO-UNDO.
DEF VAR p-lista-digito          AS CHAR                                NO-UNDO.
DEF VAR de-nrctachq             AS DEC  FORMAT "zzz,zzz,zzz,9"         NO-UNDO.
DEF VAR c-cmc-7                 AS CHAR                                NO-UNDO.
DEF VAR i-nro-lote              AS INTE                                NO-UNDO.
DEF VAR i-cdhistor              AS INTE                                NO-UNDO.
DEF VAR aux_lsconta1            AS CHAR                                NO-UNDO.
DEF VAR aux_lsconta2            AS CHAR                                NO-UNDO.
DEF VAR aux_lsconta3            AS CHAR                                NO-UNDO.
DEF VAR aux_lscontas            AS CHAR                                NO-UNDO.
DEF VAR i_conta                 AS DEC                                 NO-UNDO.
DEF VAR aux_nrtrfcta            LIKE craptrf.nrsconta                  NO-UNDO.
DEF VAR aux_nrdconta            AS INTE                                NO-UNDO.
DEF VAR i_nro-folhas            AS INTE                                NO-UNDO.
DEF VAR i_posicao               AS INTE                                NO-UNDO.
DEF VAR i_nro-talao             AS INTE                                NO-UNDO.
DEF VAR i_nro-docto             AS INTE                                NO-UNDO.

DEF VAR  p-literal              AS CHAR                                NO-UNDO.
DEF VAR  p-ult-sequencia        AS INTE                                NO-UNDO.
DEF VAR  p-registro             AS RECID                               NO-UNDO.

DEF VAR c-nome-titular1         AS CHAR                                NO-UNDO.
DEF VAR c-nome-titular2         AS CHAR                                NO-UNDO.
DEF VAR i-sequencia             AS INTE                                NO-UNDO.
                                        
DEF VAR aux_tpdmovto            AS INTE                                NO-UNDO.
DEF VAR in99                    AS INTE                                NO-UNDO.

DEF VAR  i-codigo-erro          AS INTE                                NO-UNDO.
DEF VAR  aux_nrctcomp           AS INT                                 NO-UNDO.
DEF VAR  aux_nrctachq           AS INTE                                NO-UNDO.
DEF VAR  aux_nrtalchq           AS INTE                                NO-UNDO.
DEF VAR  aux_nrdocchq           AS INTE                                NO-UNDO.

DEF VAR c-docto-salvo           AS CHAR                                NO-UNDO.
DEF VAR c-docto                 AS CHAR                                NO-UNDO.
DEF VAR de-valor                AS DEC                                 NO-UNDO.
DEF VAR de-dinheiro             AS DEC                                 NO-UNDO.
DEF VAR de-cheque               AS DEC                                 NO-UNDO.

DEF VAR i-digito                AS INTE                                NO-UNDO.

DEF VAR i-nro-docto             AS INTE                                NO-UNDO.
DEF VAR i-nrdocmto              AS INTE                                NO-UNDO.

DEF VAR h_b1crap00              AS HANDLE                              NO-UNDO.

DEF VAR i-p-nro-cheque          AS INT  FORMAT "zzz,zz9"  /* Cheque */ NO-UNDO.
DEF VAR i-p-nrddigc3            AS INT  FORMAT "9"            /* C3 */ NO-UNDO. 
DEF VAR i-p-cdbanchq            AS INT  FORMAT "zz9"       /* Banco */ NO-UNDO.     /* Banco */
DEF VAR i-p-cdagechq            AS INT  FORMAT "zzz9"    /* Agencia */ NO-UNDO.
DEF VAR i-p-valor               AS DEC                                 NO-UNDO.
DEF VAR i-p-transferencia-conta AS CHAR                                NO-UNDO.
DEF VAR i-p-aviso-cheque        AS CHAR                                NO-UNDO.
DEF VAR i-p-nrctabdb            AS DEC  FORMAT "zzz,zzz,zzz,9" /*Cta*/ NO-UNDO.

DEF VAR aux_cdagebcb            AS INT                                 NO-UNDO.
DEF VAR tab_vlchqmai            AS DEC                                 NO-UNDO.

DEF VAR c-literal               AS CHAR FORMAT "x(48)" EXTENT 31       NO-UNDO.

/* Variáveis de uso da BO 200 */
DEF VAR h-b1wgen0200         AS HANDLE                              NO-UNDO.
DEF VAR aux_incrineg         AS INT                                 NO-UNDO.
DEF VAR aux_cdcritic         AS INT                                 NO-UNDO.
DEF VAR aux_dscritic         AS CHAR                                NO-UNDO.


PROCEDURE valida-conta:

    DEF INPUT  PARAM p-cooper               AS CHAR NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia          AS INT  NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa            AS INT  NO-UNDO. /* Nro Caixa */
    DEF INPUT  PARAM p-nro-conta            AS INT  NO-UNDO. /* Nro Conta */
    DEF OUTPUT PARAM p-nome-titular         AS CHAR NO-UNDO.
    DEF OUTPUT PARAM p-transferencia-conta  AS CHAR NO-UNDO.
    DEF OUTPUT PARAM p-poupanca             AS LOG  NO-UNDO.
 
    DEF VAR aux_cdmodali AS INTE                    NO-UNDO.
    DEF VAR aux_des_erro AS CHAR                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                    NO-UNDO.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    ASSIGN p-nro-conta = DEC(REPLACE(STRING(p-nro-conta),".","")).
   
    ASSIGN p-nome-titular        = " "
           p-transferencia-conta = " "
           p-poupanca            = NO.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    IF   p-nro-conta = 0   THEN 
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Conta deve ser Informada".           
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

    aux_nrdconta = p-nro-conta.

    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.
    ASSIGN i_conta = p-nro-conta.
    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT i_conta).
    DELETE PROCEDURE h_b2crap00.

    IF   RETURN-VALUE = "NOK"   THEN
         RETURN "NOK".
    
    DO   WHILE TRUE:
        
        IF   LENGTH(STRING(aux_nrdconta)) = 9   THEN /* Conta Investimento */
             DO:        
                 ASSIGN aux_nrctainv = aux_nrdconta.
                 RUN gera_nrdconta.
                 ASSIGN aux_nrdconta = aux_nrctainv.
             
                 FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper     AND
                                    crapass.nrdconta = aux_nrdconta 
                                    NO-LOCK NO-ERROR.
             END.
        ELSE 
             FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper     AND
                                crapass.nrdconta = aux_nrdconta 
                                NO-LOCK NO-ERROR.
         
        IF   NOT AVAIL crapass   THEN  
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
        ASSIGN p-nro-conta  = crapass.nrdconta 
               aux_nrdconta = p-nro-conta.
       
        IF   crapass.dtelimin <> ?   THEN 
             DO:
                 ASSIGN i-cod-erro  = 410
                        c-desc-erro = " ".           
                 RUN cria-erro (INPUT p-cooper,
                                INPUT p-cod-agencia,
                                INPUT p-nro-caixa,
                                INPUT i-cod-erro,
                                INPUT c-desc-erro,
                                INPUT YES).
                 RETURN "NOK".
             END.

        IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN 
             DO:
                 FIND FIRST craptrf WHERE 
                            craptrf.cdcooper = crapcop.cdcooper     AND
                            craptrf.nrdconta = crapass.nrdconta     AND
                            craptrf.tptransa = 1                    AND
                            craptrf.insittrs = 2   
                            USE-INDEX craptrf1 NO-LOCK NO-ERROR.

                 IF   NOT AVAIL craptrf   THEN  
                      DO:
                          ASSIGN i-cod-erro  = 95 /* Titular Conta Bloqueado */
                                 c-desc-erro = " ".           
                          RUN cria-erro (INPUT p-cooper,
                                         INPUT p-cod-agencia,
                                         INPUT p-nro-caixa,
                                         INPUT i-cod-erro,
                                         INPUT c-desc-erro,
                                         INPUT YES).
                          RETURN "NOK".
                      END.
                 ASSIGN aux_nrtrfcta = craptrf.nrsconta
                        aux_nrdconta = craptrf.nrsconta.
                 NEXT.
             END.

        IF CAN-FIND(FIRST craptco WHERE 
                          craptco.cdcopant = crapcop.cdcooper  AND
                          craptco.nrctaant = crapass.nrdconta) THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Conta de outra cooperativa, operacao nao permitida para deposito em cheque. Para depositos em dinheiro utilize a rotina 22.".
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
        
        IF   VALID-HANDLE(h-b1wgen0001)   THEN
        DO:
             RUN ver_capital IN h-b1wgen0001(INPUT  crapcop.cdcooper,
                                             INPUT  aux_nrdconta,
                                             INPUT  p-cod-agencia,
                                             INPUT  p-nro-caixa,
                                             0,
                                             INPUT  crapdat.dtmvtocd,
                                             INPUT  "b1crap57",
                                             INPUT  2, /*CAIXA*/
                                             OUTPUT TABLE tt-erro).

             DELETE PROCEDURE h-b1wgen0001.
        END.
         
        /* Verifica se houve erro */
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF   AVAILABLE tt-erro   THEN
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

        LEAVE.
    END. /* DO WHILE */

    IF   aux_nrtrfcta > 0   THEN   /* Transferencia de Conta */
         ASSIGN p-transferencia-conta = "Conta transferida do Numero " +
                                        STRING(p-nro-conta,"zzzz,zzz,9") +
                                        " para o numero " + 
                                        STRING(aux_nrtrfcta,"zzzz,zzz,9")
                aux_nrdconta = aux_nrtrfcta.

    ASSIGN p-nome-titular = crapass.nmprimtl.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_busca_modalidade_tipo
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.inpessoa, /* Tipo de pessoa */
                                         INPUT crapass.cdtipcta, /* Tipo de conta */
                                        OUTPUT 0,                /* Modalidade */
                                        OUTPUT "",               /* Flag Erro */
                                        OUTPUT "").              /* Descriçao da crítica */

    CLOSE STORED-PROC pc_busca_modalidade_tipo
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdmodali = 0
           aux_des_erro = ""
           aux_dscritic = ""
           aux_cdmodali = pc_busca_modalidade_tipo.pr_cdmodalidade_tipo 
                          WHEN pc_busca_modalidade_tipo.pr_cdmodalidade_tipo <> ?
           aux_des_erro = pc_busca_modalidade_tipo.pr_des_erro 
                          WHEN pc_busca_modalidade_tipo.pr_des_erro <> ?
           aux_dscritic = pc_busca_modalidade_tipo.pr_dscritic
                          WHEN pc_busca_modalidade_tipo.pr_dscritic <> ?.
    
    IF aux_des_erro = "NOK"  THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = aux_dscritic.
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
        
    IF   aux_cdmodali = 3 THEN /* Conta tipo Poupan‡a */
         ASSIGN p-poupanca = YES.

    IF   CAN-DO("3",STRING(crapass.cdsitdtl))   THEN
         ASSIGN  p-transferencia-conta = TRIM(p-transferencia-conta) + 
                                         "*****  CONTA DESATIVADA ******".

    RETURN "OK".
END PROCEDURE.

PROCEDURE critica-cheque-valor-individual:
    
    DEF INPUT PARAM p-cooper       AS CHAR                             NO-UNDO.
    DEF INPUT PARAM p-cod-agencia  AS INT           /* Cod. Agencia */ NO-UNDO.
    DEF INPUT PARAM p-nro-caixa    AS INT FORMAT "999" /* Nro Caixa */ NO-UNDO.
    DEF INPUT PARAM p-valor        AS DEC                              NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
                  
    IF   p-valor = 0   THEN 
         DO: 
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Informe valor".           
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

PROCEDURE critica-saldo-cheque:
    
    DEF INPUT PARAM p-cooper         AS CHAR                           NO-UNDO.
    DEF INPUT PARAM p-cod-agencia    AS INT         /* Cod. Agencia */ NO-UNDO.
    DEF INPUT PARAM p-nro-caixa      AS INT FORMAT "999" /*Nro Caixa*/ NO-UNDO.
    DEF INPUT PARAM p-incluir        AS LOG                            NO-UNDO.
    DEF INPUT PARAM p-saldo-inf      AS DEC         /* Numero Conta */ NO-UNDO.
            
    DEFINE VARIABLE de-saldo-cheque  AS DECIMAL                        NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    ASSIGN de-saldo-cheque = 0.

    FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper  AND
                           crapmdw.cdagenci = p-cod-agencia     AND
                           crapmdw.nrdcaixa = p-nro-caixa       NO-LOCK:
        ASSIGN de-saldo-cheque = de-saldo-cheque + crapmdw.vlcompel.
    END.

    IF   de-saldo-cheque >= p-saldo-inf AND p-incluir   THEN
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = 
     "Saldo de cheque Informado é maior ou igual Saldo dos cheque processados".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    IF   de-saldo-cheque <> p-saldo-inf AND NOT p-incluir   THEN
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = 
               "Saldo de cheque Informado difere Saldo dos cheque processados".
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

PROCEDURE critica-codigo-cheque-valor:
    
    DEF INPUT PARAM p-cooper       AS CHAR                             NO-UNDO.
    DEF INPUT PARAM p-cod-agencia  AS INT         /* Cod. Agencia   */ NO-UNDO.
    DEF INPUT PARAM p-nro-caixa    AS INT FORMAT "999" /* Nro Caixa */ NO-UNDO.
    DEF INPUT PARAM p-cmc-7        AS CHAR                             NO-UNDO.
    DEF INPUT PARAM p-valor        AS DEC                              NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
   
    IF   p-valor = 0   THEN 
         DO: 
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Informe valor".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    IF   p-cmc-7 <> " "   THEN 
         DO:
             IF  LENGTH(p-cmc-7) = 34  THEN
                 ASSIGN SUBSTR(p-cmc-7,34,1) = ":".

             IF   LENGTH(p-cmc-7)      <> 34  OR
                  SUBSTR(p-cmc-7,1,1)  <> "<" OR
                  SUBSTR(p-cmc-7,10,1) <> "<" OR
                  SUBSTR(p-cmc-7,21,1) <> ">" OR
                  SUBSTR(p-cmc-7,34,1) <> ":"   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 666
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
             RUN dbo/pcrap09.p (INPUT p-cooper,
                                INPUT p-cmc-7,
                                OUTPUT p-nro-calculado,
                                OUTPUT p-lista-digito).
             IF   p-nro-calculado > 0 OR
                  NUM-ENTRIES(p-lista-digito) <> 3   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 666
                             c-desc-erro = " ".           
                      IF   p-nro-calculado > 1   THEN
                           ASSIGN i-cod-erro = p-nro-calculado.
 
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
         END.
  
    RETURN "OK".
END PROCEDURE.
 
PROCEDURE critica-valor:
    
    DEF INPUT PARAM p-cooper      AS CHAR                              NO-UNDO.
    DEF INPUT PARAM p-cod-agencia AS INT            /* Cod. Agencia */ NO-UNDO.
    DEF INPUT PARAM p-nro-caixa   AS INT  FORMAT "999" /* Nro Caixa */ NO-UNDO.
    DEF INPUT PARAM p-valor       AS DEC                               NO-UNDO.
    DEF INPUT PARAM p-dinheiro    AS DEC                               NO-UNDO.
    DEF OUTPUT PARAM p-cod-erro   AS INT                               NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
   
    IF   p-valor = 0   THEN 
         DO: 
             ASSIGN i-cod-erro  = 269
                    p-cod-erro = 269
                    c-desc-erro = "".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    IF   p-valor = p-dinheiro   THEN
         DO:
             ASSIGN i-cod-erro  = 760
                    p-cod-erro  = 760
                    c-desc-erro = "".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT NO).
             RETURN "NOK".
         END.
 
    RETURN "OK".
END PROCEDURE.
 
PROCEDURE critica-codigo-cheque-dig:
    
    DEF INPUT PARAM p-cooper      AS CHAR                             NO-UNDO.
    DEF INPUT PARAM p-cod-agencia AS INT         /* Cod. Agencia   */ NO-UNDO.
    DEF INPUT PARAM p-nro-caixa   AS INT FORMAT "999" /* Nro Caixa */ NO-UNDO.
    DEF INPUT PARAM p-cmc-7-dig   AS CHAR                             NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
   
    IF   p-cmc-7-dig <> " "   THEN  
         DO:
             RUN dbo/pcrap09.p (INPUT p-cooper,
                                INPUT p-cmc-7-dig,
                                OUTPUT p-nro-calculado,
                                OUTPUT p-lista-digito).
             IF   p-nro-calculado > 0   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 8
                             c-desc-erro = " ".           
            
                      IF   p-nro-calculado > 1   THEN
                           ASSIGN i-cod-erro = p-nro-calculado.
 
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
         END.

    RETURN "OK".
END PROCEDURE.

PROCEDURE valida-codigo-cheque:

    DEF INPUT  PARAM p-cooper      AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia AS INT          /* Cod. Agencia   */ NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa   AS INT  FORMAT "999" /* Nro Caixa */ NO-UNDO.
    DEF INPUT  PARAM p-cmc-7       AS CHAR                              NO-UNDO.
    DEF INPUT  PARAM p-cmc-7-dig   AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM p-cdcmpchq    AS INT  FORMAT "zz9"      /* Comp */ NO-UNDO.
    DEF OUTPUT PARAM p-cdbanchq    AS INT  FORMAT "zz9"     /* Banco */ NO-UNDO.
    DEF OUTPUT PARAM p-cdagechq    AS INT  FORMAT "zzz9"    /* Agcia */ NO-UNDO.
    DEF OUTPUT PARAM p-nrddigc1    AS INT  FORMAT "9"          /* C1 */ NO-UNDO.
    DEF OUTPUT PARAM p-nrctabdb    AS DEC  FORMAT "zzz,zzz,zzz,9"       NO-UNDO.
    DEF OUTPUT PARAM p-nrddigc2    AS INT  FORMAT "9"          /* C2 */ NO-UNDO.
    DEF OUTPUT PARAM p-nrcheque    AS INT  FORMAT "zzz,zz9"   /* Chq */ NO-UNDO.
    DEF OUTPUT PARAM p-nrddigc3    AS INT  FORMAT "9"          /* C3 */ NO-UNDO.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    IF   p-cmc-7 <> " "   THEN
         ASSIGN c-cmc-7              = p-cmc-7
                SUBSTR(c-cmc-7,34,1) = ":".
    ELSE
         ASSIGN c-cmc-7 = p-cmc-7-dig. /* <99999999<9999999999>999999999999: */

    ASSIGN p-cdbanchq = INT(SUBSTRING(c-cmc-7,02,03)) NO-ERROR.
    
    IF   ERROR-STATUS:ERROR   THEN 
         DO:
             ASSIGN i-cod-erro  = 666
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
       
    IF p-cdbanchq = 479 THEN
        DO:
            ASSIGN i-cod-erro  = 956
                    c-desc-erro = " ".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".    
        
        END.

    ASSIGN p-cdagechq = INT(SUBSTRING(c-cmc-7,05,04)) NO-ERROR.
    IF   ERROR-STATUS:ERROR    THEN 
         DO:
             ASSIGN i-cod-erro  = 666
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
 
    /* Buscar os dados da agencia do cheque */
    FIND FIRST crapagb WHERE crapagb.cddbanco = p-cdbanchq
                         AND crapagb.cdsitagb = "S"
                       NO-LOCK NO-ERROR.
    IF NOT AVAILABLE crapagb THEN
    DO:
        /* Se nao existir agencia com a flag ativa igual a "S" ela nao participa da COMPE
           por isso rejeitamos o cheque */
        ASSIGN i-cod-erro  = 956
               c-desc-erro = " ".           
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.
 
 
    ASSIGN p-cdcmpchq = INT(SUBSTRING(c-cmc-7,11,03)) NO-ERROR.
    IF   ERROR-STATUS:ERROR    THEN 
         DO:
             ASSIGN i-cod-erro  = 666
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
 
    ASSIGN p-nrcheque = INT(SUBSTR(c-cmc-7,14,06)) NO-ERROR.
    IF   ERROR-STATUS:ERROR    THEN 
         DO:
             ASSIGN i-cod-erro  = 666
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
                                                 
    ASSIGN de-nrctachq = DEC(SUBSTR(c-cmc-7,23,10)) NO-ERROR.
    IF   ERROR-STATUS:ERROR   THEN 
         DO:
             ASSIGN i-cod-erro  = 666
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
        END.

    ASSIGN p-nrctabdb = IF p-cdbanchq = 1 
                        THEN DEC(SUBSTR(c-cmc-7,25,08))
                        ELSE DEC(SUBSTR(c-cmc-7,23,10)) NO-ERROR.
    IF   ERROR-STATUS:ERROR   THEN 
         DO:
             ASSIGN i-cod-erro  = 666
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
  
    /*  Calcula primeiro digito de controle  */
    ASSIGN p-nro-calculado = DECIMAL(STRING(p-cdcmpchq,"999") +
                                     STRING(p-cdbanchq,"999") +
                                     STRING(p-cdagechq,"9999") + "0").
                                  
    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.

    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT p-nro-calculado).
    DELETE PROCEDURE h_b2crap00.
    /*
    IF   RETURN-VALUE = "NOK"   THEN 
         RETURN "NOK".
     */
   
    ASSIGN p-nrddigc1 = INT(SUBSTRING(STRING(p-nro-calculado),
                            LENGTH(STRING(p-nro-calculado)))).    
    /*  Calcula segundo digito de controle  */
    ASSIGN p-nro-calculado =  de-nrctachq * 10.
    
    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.

    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT p-nro-calculado).
    DELETE PROCEDURE h_b2crap00.
    /*
    IF  RETURN-VALUE = "NOK" THEN  
        RETURN "NOK".
    */              
    ASSIGN p-nrddigc2 = INT(SUBSTRING(STRING(p-nro-calculado),
                            LENGTH(STRING(p-nro-calculado)))).     
    /*  Calcula terceiro digito de controle  */
    ASSIGN p-nro-calculado = p-nrcheque * 10.
    
    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.

    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT p-nro-calculado).
    DELETE PROCEDURE h_b2crap00.
    /*
    IF  RETURN-VALUE = "NOK" THEN  
        RETURN "NOK". 
    */              
    ASSIGN p-nrddigc3 = INT(SUBSTRING(STRING(p-nro-calculado),
                            LENGTH(STRING(p-nro-calculado)))).
   
    /*** Pesquisa se o cheque e nosso ***/
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

         /* Banco do Brasil */
    IF  (p-cdbanchq = 1   AND p-cdagechq = 3420)               OR
         /* BANCOOB */
        (p-cdbanchq = 756)   OR
        /* IF CECRED */
        (p-cdbanchq = crapcop.cdbcoctl) THEN
         DO:
             /* Formata conta integracao */
             RUN fontes/digbbx.p (INPUT  p-nrctabdb,
                                  OUTPUT glb_dsdctitg,
                                  OUTPUT glb_stsnrcal).
             IF   NOT glb_stsnrcal   THEN
                  DO:
                      ASSIGN i-cod-erro  = 8
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
    
             FIND crapfdc WHERE crapfdc.cdcooper = crapcop.cdcooper   AND
                                crapfdc.cdbanchq = p-cdbanchq         AND
                                crapfdc.cdagechq = p-cdagechq         AND
                                crapfdc.nrctachq = p-nrctabdb         AND
                                crapfdc.nrcheque = p-nrcheque
                                NO-LOCK NO-ERROR.
                                
             IF   AVAILABLE crapfdc   THEN
                  DO:              
                      IF   p-cdcmpchq = crapfdc.cdcmpchq   AND
                           p-cdbanchq = crapfdc.cdbanchq   AND
                           p-cdagechq = crapfdc.cdagechq   THEN 
                           DO:
                               /* Cheque da Cooperativa */
                               ASSIGN i-cod-erro  = 746 
                                      c-desc-erro = " ".           
                               RUN cria-erro (INPUT p-cooper,
                                              INPUT p-cod-agencia,
                                              INPUT p-nro-caixa,
                                              INPUT i-cod-erro,
                                              INPUT c-desc-erro,
                                              INPUT YES).
                               RETURN "NOK".
                           END.
                  END.
         END.
    
    RETURN "OK".
END PROCEDURE.

PROCEDURE valida-deposito-com-captura:

    DEF INPUT PARAM p-cooper        AS CHAR                            NO-UNDO.
    DEF INPUT PARAM p-cod-agencia   AS INT         /* Cod. Agencia  */ NO-UNDO.
    DEF INPUT PARAM p-nro-caixa     AS INT  FORMAT "999" /*Nro Caixa*/ NO-UNDO.
    DEF INPUT PARAM p-cod-operador  AS CHAR                            NO-UNDO.
    DEF INPUT PARAM p-nro-conta     AS INT                             NO-UNDO.
    DEF INPUT PARAM p-cmc-7         AS CHAR                            NO-UNDO.
    DEF INPUT PARAM p-cmc-7-dig     AS CHAR                            NO-UNDO.
    DEF INPUT PARAM p-cdcmpchq      AS INT  FORMAT "zz9"    /* Comp */ NO-UNDO.
    DEF INPUT PARAM p-cdbanchq      AS INT  FORMAT "zz9"   /* Banco */ NO-UNDO.
    DEF INPUT PARAM p-cdagechq      AS INT  FORMAT "zzz9"     /* Ag */ NO-UNDO.
    DEF INPUT PARAM p-nrddigc1      AS INT  FORMAT "9"        /* C1 */ NO-UNDO.
    DEF INPUT PARAM p-nrctabdb      AS DEC  FORMAT "zzz,zzz,zzz,9"     NO-UNDO.
    DEF INPUT PARAM p-nrddigc2      AS INT  FORMAT "9"        /* C2 */ NO-UNDO.
    DEF INPUT PARAM p-nro-cheque    AS INT  FORMAT "zzz,zz9" /* Chq */ NO-UNDO.
    DEF INPUT PARAM p-nrddigc3      AS INT  FORMAT "9"        /* C3 */ NO-UNDO.
    DEF INPUT PARAM p-valor         AS DEC                             NO-UNDO.
    DEF INPUT PARAM p-grava-tabela  AS LOG          /* Grava tabela */ NO-UNDO.
    
    DEF OUTPUT PARAM p-transferencia-conta AS CHAR                     NO-UNDO.
    DEF OUTPUT PARAM p-aviso-cheque        AS CHAR                     NO-UNDO.
    DEF OUTPUT PARAM p-mensagem            AS CHAR                     NO-UNDO.
    DEF OUTPUT PARAM p-valor-disponivel    AS DEC                      NO-UNDO.
   
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    ASSIGN p-nro-conta = DEC(REPLACE(STRING(p-nro-conta),".","")).

    IF   LENGTH(STRING(p-nro-conta)) = 9   THEN  
         DO: /* Conta Investimento */
             
             ASSIGN aux_nrctainv = p-nro-conta.
             RUN gera_nrdconta.
             ASSIGN p-nro-conta = aux_nrctainv.
             
             FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper     AND
                                crapass.nrdconta = p-nro-conta 
                                NO-LOCK NO-ERROR.
             ASSIGN p-nro-conta = crapass.nrdconta.
         END.
 
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
    
    ASSIGN p-aviso-cheque        = " "
           p-transferencia-conta = " "
           p-mensagem            = " ".
   
    IF   p-cmc-7 <> " "   THEN
         ASSIGN c-cmc-7              = p-cmc-7
                substr(c-cmc-7,34,1) = ":".
    ELSE
         ASSIGN c-cmc-7 = p-cmc-7-dig. /* <99999999<9999999999>999999999999: */

    /* Buscar os dados da agencia do cheque */
    FIND FIRST crapagb WHERE crapagb.cddbanco = INT(SUBSTRING(c-cmc-7,02,03))
                         AND crapagb.cdsitagb = "S"
                       NO-LOCK NO-ERROR.
    IF NOT AVAILABLE crapagb THEN
    DO:
        /* Se nao existir agencia com a flag ativa igual a "S" ela nao participa da COMPE
           por isso rejeitamos o cheque */
        ASSIGN i-cod-erro  = 956
               c-desc-erro = " ".           
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.

    ASSIGN i-nro-lote = 11000 + p-nro-caixa.

    ASSIGN i-cdhistor = 372.

    RUN dbo/pcrap09.p (INPUT p-cooper,
                       INPUT c-cmc-7,
                       OUTPUT p-nro-calculado,
                       OUTPUT p-lista-digito).
 
    FIND craphis WHERE craphis.cdcooper = crapcop.cdcooper   AND
                       craphis.cdhistor = i-cdhistor
                       NO-LOCK NO-ERROR.

    IF   NOT AVAIL craphis   THEN 
         DO:
             ASSIGN i-cod-erro  = 93
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
    IF   craphis.tplotmov <> 1   THEN 
         DO:
             ASSIGN i-cod-erro  = 94
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
   
    IF   craphis.tpctbcxa <> 2  AND
         craphis.tpctbcxa <> 3  THEN 
         DO:
             ASSIGN i-cod-erro  = 689
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.
    ASSIGN i_conta = DEC(p-nro-conta). 
    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT i_conta).
    DELETE PROCEDURE h_b2crap00.

    IF   RETURN-VALUE = "NOK"   THEN
         RETURN "NOK".

    ASSIGN  aux_nrdconta = p-nro-conta.
  
    ASSIGN aux_nrtrfcta = 0.  
    DO   WHILE TRUE:
         FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper     AND 
                            crapass.nrdconta = aux_nrdconta 
                            NO-LOCK NO-ERROR.
         IF   NOT AVAIL crapass   THEN  
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
         IF   crapass.dtelimin <> ?   THEN 
              DO:
                  ASSIGN i-cod-erro  = 410
                         c-desc-erro = " ".           
                  RUN cria-erro (INPUT p-cooper,
                                 INPUT p-cod-agencia,
                                 INPUT p-nro-caixa,
                                 INPUT i-cod-erro,
                                 INPUT c-desc-erro,
                                 INPUT YES).
                  RETURN "NOK".
              END.
         IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN 
              DO:
                  FIND FIRST craptrf WHERE
                             craptrf.cdcooper = crapcop.cdcooper    AND
                             craptrf.nrdconta = crapass.nrdconta    AND
                             craptrf.tptransa = 1                   AND
                             craptrf.insittrs = 2   
                             USE-INDEX craptrf1 NO-LOCK NO-ERROR.

                  IF   NOT AVAIL craptrf   THEN  
                       DO:
                           ASSIGN i-cod-erro  = 95 /* Titular Conta Bloqueado */
                                  c-desc-erro = " ".           
                           RUN cria-erro (INPUT p-cooper,
                                          INPUT p-cod-agencia,
                                          INPUT p-nro-caixa,
                                          INPUT i-cod-erro,
                                          INPUT c-desc-erro,
                                          INPUT YES).
                           RETURN "NOK".
                       END.
                  ASSIGN aux_nrtrfcta = craptrf.nrsconta
                         aux_nrdconta = craptrf.nrsconta.
                  NEXT.
              END.
    
         RUN sistema/generico/procedures/b1wgen0001.p
             PERSISTENT SET h-b1wgen0001.
        
         IF   VALID-HANDLE(h-b1wgen0001)   THEN
         DO:
              RUN ver_capital IN h-b1wgen0001(INPUT  crapcop.cdcooper,
                                              INPUT  aux_nrdconta,
                                              INPUT  p-cod-agencia,
                                              INPUT  p-nro-caixa,
                                              0,
                                              INPUT  crapdat.dtmvtocd,
                                              INPUT  "b1crap57",
                                              INPUT  2, /*CAIXA*/
                                              OUTPUT TABLE tt-erro).

              DELETE PROCEDURE h-b1wgen0001.
         END.
         
         /* Verifica se houve erro */
         FIND FIRST tt-erro NO-LOCK NO-ERROR.

         IF   AVAILABLE tt-erro   THEN
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

         LEAVE.

    END.   /* do while */
   
    IF   aux_nrtrfcta > 0   THEN  /* Transferencia de Conta */
         ASSIGN aux_nrdconta = aux_nrtrfcta.
    
    ASSIGN p-transferencia-conta  = i-p-transferencia-conta
           p-aviso-cheque         = i-p-aviso-cheque.
    
    IF   i-codigo-erro > 0   THEN 
         DO:
             ASSIGN i-cod-erro  = i-codigo-erro
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    /*******************************
      Validar se o cheque é de um cooperado migrado 
    ********************************/
    /* Validar se a folha de cheque é da cooperativa */
    FIND crapfdc WHERE crapfdc.cdcooper = crapcop.cdcooper   AND
                       crapfdc.cdbanchq = p-cdbanchq         AND
                       crapfdc.cdagechq = p-cdagechq         AND
                       crapfdc.nrctachq = p-nrctabdb         AND
                       crapfdc.nrcheque = p-nro-cheque
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapfdc   THEN
         DO:
            /* Caso nao encontrar, validar se cheque eh de uma conta migrada */
            /* Se for Bco Cecred ou Bancoob usa o nrctaant = p-nrctabdb na busca da conta */
            IF  p-cdbanchq = crapcop.cdbcoctl  OR 
                p-cdbanchq = 756               THEN
            DO:
                /* Localiza se o cheque é de uma conta migrada */
                FIND FIRST craptco WHERE 
                           craptco.cdcooper = crapcop.cdcooper AND /* coop nova    */
                           craptco.nrctaant = INT(p-nrctabdb)  AND /* conta antiga */
                           craptco.tpctatrf = 1                AND
                           craptco.flgativo = TRUE
                           NO-LOCK NO-ERROR.

                IF  AVAIL craptco  THEN
                DO:
                    /* verifica se o cheque pertence a conta migrada */
                    FIND FIRST crapfdc WHERE crapfdc.cdcooper = craptco.cdcopant AND
                                             crapfdc.cdbanchq = p-cdbanchq       AND
                                             crapfdc.cdagechq = p-cdagechq       AND
                                             crapfdc.nrctachq = p-nrctabdb       AND
                                             crapfdc.nrcheque = p-nro-cheque
                                             NO-LOCK NO-ERROR.
                    IF  AVAIL crapfdc  THEN
                    DO:
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = "Conta do cheque migrada, favor " +
                                             "utilizar rotina 51 ou 53.".

                        RUN cria-erro (INPUT p-cooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                        RETURN "NOK".
                    END.

                END.
            END.
            ELSE 
            /* Se for BB usa a conta ITG para buscar conta migrada */
            /* Usa o nrdctitg = p-nrctabdb na busca da conta */
            IF  p-cdbanchq = 1 AND p-cdagechq = 3420  THEN
            DO:
                /* Formata conta integracao */
                RUN fontes/digbbx.p (INPUT  p-nrctabdb,
                                     OUTPUT glb_dsdctitg,
                                     OUTPUT glb_stsnrcal).
                IF   NOT glb_stsnrcal   THEN
                     DO:
                         ASSIGN i-cod-erro  = 8
                                c-desc-erro = " ".           
                         RUN cria-erro (INPUT p-cooper,
                                        INPUT p-cod-agencia,
                                        INPUT p-nro-caixa,
                                        INPUT i-cod-erro,
                                        INPUT c-desc-erro,
                                        INPUT YES).
                         RETURN "NOK".
                     END.

                /* Localiza se o cheque é de uma conta migrada */
                FIND FIRST craptco WHERE 
                           craptco.cdcooper = crapcop.cdcooper AND /* coop nova                 */
                           craptco.nrdctitg = glb_dsdctitg     AND /* conta ITG da conta antiga */
                           craptco.tpctatrf = 1                AND
                           craptco.flgativo = TRUE
                           NO-LOCK NO-ERROR.

                IF  AVAIL craptco  THEN
                DO:
                    /* verifica se o cheque pertence a conta migrada */
                    FIND FIRST crapfdc WHERE crapfdc.cdcooper = craptco.cdcopant AND
                                             crapfdc.cdbanchq = p-cdbanchq       AND
                                             crapfdc.cdagechq = p-cdagechq       AND
                                             crapfdc.nrctachq = p-nrctabdb       AND
                                             crapfdc.nrcheque = p-nro-cheque
                                             NO-LOCK NO-ERROR.

                    IF  AVAIL crapfdc  THEN
                    DO:
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = "Conta do cheque migrada, favor " +
                                             "utilizar rotina 51 ou 53.".

                        RUN cria-erro (INPUT p-cooper,
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
    /*******************************
      FIM - Validar se o cheque é de um cooperado migrado 
    ********************************/

    EMPTY TEMP-TABLE w-compel.

    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND 
                       craptab.nmsistem = "CRED"            AND
                       craptab.tptabela = "USUARI"          AND
                       craptab.cdempres = 11                AND
                       craptab.cdacesso = "MAIORESCHQ"      AND
                       craptab.tpregist = 1                 NO-LOCK NO-ERROR.
                       
    IF   NOT AVAIL craptab   THEN
         ASSIGN TAB_vlchqmai = 1.
    ELSE
         ASSIGN TAB_vlchqmai = DEC(SUBSTR(craptab.dstextab,1,15)).
        
    IF   p-valor < tab_vlchqmai   THEN
         ASSIGN  aux_tpdmovto = 2.
    ELSE
         ASSIGN  aux_tpdmovto = 1.
    
    IF   CAN-FIND(crapchd WHERE crapchd.cdcooper = crapcop.cdcooper     AND
                                crapchd.dtmvtolt = crapdat.dtmvtocd     AND
                                crapchd.cdcmpchq = p-cdcmpchq           AND
                                crapchd.cdbanchq = p-cdbanchq           AND
                                crapchd.cdagechq = p-cdagechq           AND
                                crapchd.nrctachq = (IF aux_nrctcomp > 0 
                                                    THEN p-nrctabdb
                                                    ELSE de-nrctachq)   AND
                                crapchd.nrcheque = p-nro-cheque)        THEN 
         DO:
             ASSIGN i-cod-erro  = 92
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
   
    /*  Formata conta integracao  */
    RUN fontes/digbbx.p (INPUT  p-nrctabdb,
                         OUTPUT glb_dsdctitg,
                         OUTPUT glb_stsnrcal).
        
    CREATE w-compel.
    ASSIGN w-compel.cdcooper = crapcop.cdcooper
           w-compel.dsdocmc7 = c-cmc-7
           w-compel.cdcmpchq = p-cdcmpchq
           w-compel.cdbanchq = p-cdbanchq
           w-compel.cdagechq = p-cdagechq
           w-compel.nrddigc1 = p-nrddigc1   
           w-compel.nrctaaux = aux_nrctcomp 
           w-compel.nrctachq = de-nrctachq
           w-compel.nrctabdb = p-nrctabdb
           w-compel.nrdctitg = glb_dsdctitg
           w-compel.nrddigc2 = p-nrddigc2            
           w-compel.nrcheque = p-nro-cheque      
           w-compel.nrddigc3 = p-nrddigc3            
           w-compel.vlcompel = p-valor
           w-compel.dtlibcom = ?
           w-compel.lsdigctr = p-lista-digito
           w-compel.tpdmovto = aux_tpdmovto
           w-compel.cdtipchq = INTE(SUBSTRING(c-cmc-7,20,1))
           w-compel.nrseqdig = 1.
     
     FOR EACH w-compel NO-LOCK:   /* Verifica Lancamento Existente */
         FIND crapchd WHERE crapchd.cdcooper = crapcop.cdcooper     AND
                            crapchd.dtmvtolt = crapdat.dtmvtocd     AND
                            crapchd.cdcmpchq = w-compel.cdcmpchq    AND
                            crapchd.cdbanchq = w-compel.cdbanchq    AND
                            crapchd.cdagechq = w-compel.cdagechq    AND
                            crapchd.nrctachq = (IF aux_nrctcomp > 0 
                                                THEN p-nrctabdb
                                                ELSE de-nrctachq)   AND
                            crapchd.nrcheque = w-compel.nrcheque 
                            NO-LOCK NO-ERROR.
                            
         IF   AVAIL crapchd   THEN  
              DO:
                  ASSIGN i-cod-erro  = 92
                         c-desc-erro = " ".           
                  RUN cria-erro (INPUT p-cooper,
                                 INPUT p-cod-agencia,
                                 INPUT p-nro-caixa,
                                 INPUT i-cod-erro,
                                 INPUT c-desc-erro,
                                 INPUT YES).
                  RETURN "NOK".
              END.
     END.
    
    /* Verifica horario de Corte */
    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                       craptab.nmsistem = "CRED"            AND
                       craptab.tptabela = "GENERI"          AND
                       craptab.cdempres = 0                 AND
                       craptab.cdacesso = "HRTRCOMPEL"      AND
                       craptab.tpregist = p-cod-agencia     NO-LOCK NO-ERROR.
                       
    IF   NOT AVAIL craptab   THEN  
         DO:
             ASSIGN i-cod-erro  = 676
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".          
         END.   

    IF   INT(SUBSTR(craptab.dstextab,1,1)) <> 0   THEN 
         DO:
             ASSIGN i-cod-erro  = 677
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.    

    IF   INT(SUBSTR(craptab.dstextab,3,5)) <= TIME   THEN 
         DO:
             ASSIGN i-cod-erro  = 676
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END. 
  
    ASSIGN i-digito =  0.

    IF   p-grava-tabela = YES   THEN 
         DO:
             ASSIGN i-digito = 1.
             FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper     AND
                                    crapmdw.cdagenci = p-cod-agencia        AND
                                    crapmdw.nrdcaixa = p-nro-caixa 
                                    NO-LOCK BREAK BY crapmdw.nrseqdig:
                                    
                 IF   LAST(crapmdw.nrseqdig)   THEN
                      ASSIGN i-digito = crapmdw.nrseqdig + 1.
             END.

             FIND crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper     AND
                                crapmdw.cdagenci = p-cod-agencia        AND
                                crapmdw.nrdcaixa = p-nro-caixa          AND
                                crapmdw.nrctabdb = p-nrctabdb           AND
                                crapmdw.nrcheque = p-nro-cheque     
                                EXCLUSIVE-LOCK NO-ERROR.
                                
             IF   NOT AVAIL crapmdw   THEN 
                  DO:
                      CREATE crapmdw.
                      ASSIGN crapmdw.cdcooper  = crapcop.cdcooper
                             crapmdw.cdagenci  = p-cod-agencia
                             crapmdw.nrdcaixa  = p-nro-caixa
                             crapmdw.nrctabdb  = p-nrctabdb 
                             crapmdw.nrcheque  = p-nro-cheque.
                  END.

             ASSIGN crapmdw.nrdconta = p-nro-conta
                    crapmdw.cdopecxa = p-cod-operador
                    crapmdw.cdhistor = i-cdhistor
                    crapmdw.dsdocmc7 = c-cmc-7
                    crapmdw.cdcmpchq = p-cdcmpchq
                    crapmdw.cdbanchq = p-cdbanchq
                    crapmdw.cdagechq = p-cdagechq
                    crapmdw.nrddigc1 = p-nrddigc1   
                    crapmdw.nrctaaux = aux_nrctcomp 
                    crapmdw.nrctachq = de-nrctachq
                    crapmdw.nrctabdb = p-nrctabdb            /* Conta */
                    crapmdw.nrddigc2 = p-nrddigc2            
                    crapmdw.nrddigc3 = p-nrddigc3            /* Digito */                          crapmdw.vlcompel = p-valor              /* Valor  */
                    crapmdw.lsdigctr = p-lista-digito
                    crapmdw.tpdmovto = aux_tpdmovto
                    crapmdw.nrseqdig = i-digito
                    crapmdw.cdtipchq = INTE(SUBSTRING(c-cmc-7,20,1)).
             
             IF   aux_nrtalchq <> 0   THEN
                  ASSIGN crapmdw.nrtalchq = aux_nrtalchq
                         crapmdw.nrposchq = i_posicao.
             ELSE
                  IF   aux_nrdocchq <> 0   THEN
                       ASSIGN crapmdw.nrdocmto = aux_nrdocchq.

            VALIDATE crapmdw.

         END.  /* Grava Tabela */

    RETURN "OK".  
END PROCEDURE.

FUNCTION centraliza RETURNS CHARACTER ( INPUT par_frase AS CHARACTER, INPUT par_tamlinha AS INTEGER ):

    DEF VAR vr_contastr AS INTEGER NO-UNDO.
    
    ASSIGN vr_contastr = TRUNC( (par_tamlinha - LENGTH(TRIM(par_frase))) / 2 ,0).

    RETURN FILL(' ',vr_contastr) + TRIM(par_frase).
END.

PROCEDURE atualiza-deposito-com-captura:
  
    DEF INPUT  PARAM  p-cooper                  AS CHAR     NO-UNDO.
    DEF INPUT  PARAM  p-cod-agencia             AS INTEGER  NO-UNDO.
    DEF INPUT  PARAM  p-nro-caixa               AS INTEGER  NO-UNDO.
    DEF INPUT  PARAM  p-cod-operador            AS CHAR     NO-UNDO.
    DEF INPUT  PARAM  p-nro-conta               AS INTE     NO-UNDO.
    DEF INPUT  PARAM  p-nome-titular            AS CHAR     NO-UNDO.
    DEF INPUT  PARAM  p-identifica              AS CHAR     NO-UNDO.
    DEF OUTPUT PARAM  p-literal-autentica       AS CHAR     NO-UNDO.
    DEF OUTPUT PARAM  p-ult-sequencia-autentica AS INTE     NO-UNDO.
    DEF OUTPUT PARAM  p-nro-docto               AS INTE     NO-UNDO.

    DEF VAR flg_ci       AS LOG INIT NO                     NO-UNDO.
    DEF VAR i-tplotmov   LIKE craplot.tplotmov              NO-UNDO.
    DEF VAR aux_dtrefere AS DATE                            NO-UNDO.
    DEF VAR aux_flcrialot AS LOGICAL INIT NO                 NO-UNDO.
    DEF VAR aux_contador  AS INTEGER                         NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    
    ASSIGN p-nro-conta = DEC(REPLACE(STRING(p-nro-conta),".","")).
     
    IF   LENGTH(STRING(p-nro-conta)) = 9   THEN  
         DO: /* Conta Investimento */
             ASSIGN flg_ci = YES
                    aux_nrctainv = p-nro-conta.
             RUN gera_nrdconta.
             ASSIGN p-nro-conta = aux_nrctainv.
             
             FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper     AND
                                crapass.nrdconta = p-nro-conta 
                                NO-LOCK NO-ERROR.
             ASSIGN p-nro-conta = crapass.nrdconta.
         END.
     
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa). 

    IF   flg_ci = NO   THEN
         ASSIGN i-nro-lote = 11000 + p-nro-caixa
                i-tplotmov = 1.
    ELSE
         ASSIGN i-nro-lote = 23000 + p-nro-caixa
                i-tplotmov = 29.

    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    FIND FIRST crapmrw WHERE crapmrw.cdcooper = crapcop.cdcooper    AND
                             crapmrw.cdagenci = p-cod-agencia       AND
                             crapmrw.nrdcaixa = p-nro-caixa   
                             NO-LOCK NO-ERROR.
    IF   NOT AVAIL crapmrw   THEN 
         DO: 
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Nao existem valores a serem Depositados ".  
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper  AND
                           crapmdw.cdagenci = p-cod-agencia     AND
                           crapmdw.nrdcaixa = p-nro-caixa       NO-LOCK:

        IF   NUM-ENTRIES(crapmdw.lsdigctr) <> 3   THEN 
             DO:
                 ASSIGN i-cod-erro  = 0
                        c-desc-erro = "Avise INF(ENTRY) = " + 
                                      STRING(crapmdw.lsdigctr) + " - " + 
                                      STRING(crapmdw.nrcheque).
                 RUN cria-erro (INPUT p-cooper,
                                INPUT p-cod-agencia,
                                INPUT p-nro-caixa,
                                INPUT i-cod-erro,
                                INPUT c-desc-erro,
                                INPUT YES).
                 RETURN "NOK".
             END.
    END.

    ASSIGN aux_nrdconta = p-nro-conta.
   
    /*--- Verifica se Houve Transferencia de Conta --*/
    ASSIGN aux_nrtrfcta = 0.
    DO   WHILE TRUE:
         FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper     AND
                            crapass.nrdconta = aux_nrdconta 
                            NO-LOCK NO-ERROR.
                            
         IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN 
              DO:
                  FIND FIRST craptrf WHERE
                             craptrf.cdcooper = crapcop.cdcooper    AND
                             craptrf.nrdconta = crapass.nrdconta    AND
                             craptrf.tptransa = 1                   AND
                             craptrf.insittrs = 2   
                             USE-INDEX craptrf1 NO-LOCK NO-ERROR.
                  ASSIGN aux_nrtrfcta = craptrf.nrsconta
                         aux_nrdconta = craptrf.nrsconta.
                  NEXT.
              END.
         LEAVE.
    END. /* DO WHILE */
    IF   aux_nrtrfcta > 0   THEN    /* Transferencia de Conta */
         ASSIGN aux_nrdconta = aux_nrtrfcta.
    /*-------------------------------------------------*/
  
    ASSIGN p-nro-conta = aux_nrdconta.

    FIND FIRST crapmrw WHERE crapmrw.cdcooper = crapcop.cdcooper    AND
                             crapmrw.cdagenci = p-cod-agencia       AND
                             crapmrw.nrdcaixa = p-nro-caixa   
                             NO-LOCK NO-ERROR.
 
    IF   AVAIL crapmrw                  AND
               crapmrw.vldepdin <> 0    AND
         flg_ci = YES   THEN 
         DO:
             ASSIGN i-cod-erro  = 269
                    c-desc-erro = "".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    IF   AVAIL crapmrw          AND  
         crapmrw.vlchqipr > 0   THEN 
         DO:
             /* Verifica horario de Corte */
             FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper     AND
                                craptab.nmsistem = "CRED"               AND
                                craptab.tptabela = "GENERI"             AND
                                craptab.cdempres = 0                    AND
                                craptab.cdacesso = "HRTRCOMPEL"         AND
                                craptab.tpregist = p-cod-agencia 
                                NO-LOCK NO-ERROR.
                                
            IF   NOT AVAIL craptab THEN  
                 DO:
                     ASSIGN i-cod-erro  = 676
                            c-desc-erro = " ".           
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN "NOK".
                 END.    
               
            IF   INT(SUBSTR(craptab.dstextab,1,1)) <> 0   THEN 
                 DO:
                     ASSIGN i-cod-erro  = 677
                            c-desc-erro = " ".           
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN "NOK".
                 END.    

            IF   INT(SUBSTR(craptab.dstextab,3,5)) <= TIME   THEN 
                 DO:
                     ASSIGN i-cod-erro  = 676
                            c-desc-erro = " ".           
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN "NOK".
                 END.
         END.
  
    ASSIGN c-docto-salvo = STRING(TIME).
  
     DO aux_contador = 1 TO 10:
    
        c-desc-erro = "".
        
    FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                       craplot.dtmvtolt = crapdat.dtmvtocd  AND
                       craplot.cdagenci = p-cod-agencia     AND
                       craplot.cdbccxlt = 11                AND  /* Fixo */
                       craplot.nrdolote = i-nro-lote 
                           EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                       
        IF  NOT AVAILABLE craplot  THEN
         DO:
                IF  LOCKED craplot  THEN
                    DO:
                        c-desc-erro = "Lote " + STRING(i-nro-lote) + " ja esta sendo alterado. " +
                                      "Tente novamente.".
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    DO:
                        aux_flcrialot = TRUE. 
                        LEAVE.
                    END.
            END.
    
        aux_flcrialot = FALSE.
    
        LEAVE.
        
     END. /* Fim do DO ... TO */

     IF  c-desc-erro <> "" THEN      
         DO:
              ASSIGN i-cod-erro  = 0.
         
              RUN cria-erro (INPUT p-cooper,
                             INPUT p-cod-agencia,
                             INPUT p-nro-caixa,
                             INPUT i-cod-erro,
                             INPUT c-desc-erro,
                             INPUT YES).
              RETURN "NOK".
          
         END.

     IF aux_flcrialot = TRUE THEN  
         DO:
             CREATE craplot.
             ASSIGN craplot.cdcooper = crapcop.cdcooper
                    craplot.dtmvtolt = crapdat.dtmvtocd
                    craplot.cdagenci = p-cod-agencia   
                    craplot.cdbccxlt = 11              
                    craplot.nrdolote = i-nro-lote
                    craplot.tplotmov = i-tplotmov
                    craplot.cdoperad = p-cod-operador
                    craplot.cdhistor = 0 /* 700 */
                    craplot.nrdcaixa = p-nro-caixa
                    craplot.cdopecxa = p-cod-operador.
         END.
  
    ASSIGN de-valor = 0.
          
    FIND FIRST crapmrw WHERE crapmrw.cdcooper = crapcop.cdcooper    AND
                             crapmrw.cdagenci = p-cod-agencia       AND
                             crapmrw.nrdcaixa = p-nro-caixa   
                             NO-LOCK NO-ERROR.
                             
    IF   AVAIL crapmrw   THEN  
         ASSIGN de-valor    = crapmrw.vldepdin +  crapmrw.vlchqipr
                de-dinheiro = crapmrw.vldepdin
                de-cheque   = crapmrw.vlchqipr.
  
    /*-----*/
    ASSIGN i-nro-docto = INTE(c-docto-salvo)
           p-nro-docto = INTE(c-docto-salvo).
           
    /*--- Grava Autenticacao Arquivo/Spool --*/
    RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
    RUN grava-autenticacao  IN h_b1crap00 (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT p-nro-caixa,
                                           INPUT p-cod-operador,
                                           INPUT de-valor,
                                           INPUT DEC(i-nro-docto),
                                           INPUT NO, /* YES (PG), NO (REC) */
                                           INPUT "1",  /* On-line          */
                                           INPUT NO,   /* Nao estorno        */
                                           INPUT 700,
                                           INPUT ?, /* Data off-line */
                                           INPUT 0, /* Sequencia off-line */
                                           INPUT 0, /* Hora off-line */
                                           INPUT 0, /* Seq.orig.Off-line */
                                           OUTPUT p-literal,
                                           OUTPUT p-ult-sequencia,
                                           OUTPUT p-registro).
    DELETE PROCEDURE h_b1crap00.
 
    IF   RETURN-VALUE = "NOK" THEN
         RETURN "NOK".

    IF   AVAIL crapmrw  THEN  
         DO:
             /* Formata conta integracao */
             RUN fontes/digbbx.p (INPUT  p-nro-conta,
                                  OUTPUT glb_dsdctitg,
                                  OUTPUT glb_stsnrcal).
              
             IF   crapmrw.vldepdin <> 0   THEN 
                  DO:
                      ASSIGN c-docto = c-docto-salvo + "1".
                      
                      
                      /* BLOCO DA INSERÇAO DA CRAPLCM */
                      IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
                        RUN sistema/generico/procedures/b1wgen0200.p 
                          PERSISTENT SET h-b1wgen0200.

                      RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
                        (INPUT crapdat.dtmvtocd               /* par_dtmvtolt */
                        ,INPUT p-cod-agencia                  /* par_cdagenci */
                        ,INPUT 11                             /* par_cdbccxlt */
                        ,INPUT i-nro-lote                     /* par_nrdolote */
                        ,INPUT aux_nrdconta                   /* par_nrdconta */
                        ,INPUT INTE(c-docto)                  /* par_nrdocmto */
                        ,INPUT 1 /* Dinheiro */               /* par_cdhistor */
                        ,INPUT craplot.nrseqdig + 1           /* par_nrseqdig */
                        ,INPUT crapmrw.vldepdin               /* par_vllanmto */
                        ,INPUT p-nro-conta                    /* par_nrdctabb */
                        ,INPUT "CRAP57"                       /* par_cdpesqbb */
                        ,INPUT 0                              /* par_vldoipmf */
                        ,INPUT p-ult-sequencia                /* par_nrautdoc */
                        ,INPUT 0                              /* par_nrsequni */
                        ,INPUT 0                              /* par_cdbanchq */
                        ,INPUT 0                              /* par_cdcmpchq */
                        ,INPUT 0                              /* par_cdagechq */
                        ,INPUT 0                              /* par_nrctachq */
                        ,INPUT 0                              /* par_nrlotchq */
                        ,INPUT 0                              /* par_sqlotchq */
                        ,INPUT ""                             /* par_dtrefere */
                        ,INPUT ""                             /* par_hrtransa */
                        ,INPUT 0                              /* par_cdoperad */
                        ,INPUT p-identifica                   /* par_dsidenti */
                        ,INPUT crapcop.cdcooper               /* par_cdcooper */
                        ,INPUT glb_dsdctitg                   /* par_nrdctitg */
                        ,INPUT ""                             /* par_dscedent */
                        ,INPUT 0                              /* par_cdcoptfn */
                        ,INPUT 0                              /* par_cdagetfn */
                        ,INPUT 0                              /* par_nrterfin */
                        ,INPUT 0                              /* par_nrparepr */
                        ,INPUT 0                              /* par_nrseqava */
                        ,INPUT 0                              /* par_nraplica */
                        ,INPUT 0                              /* par_cdorigem */
                        ,INPUT 0                              /* par_idlautom */
                        /* CAMPOS OPCIONAIS DO LOTE                                                            */ 
                        ,INPUT 0                              /* Processa lote                                 */
                        ,INPUT 0                              /* Tipo de lote a movimentar                     */
                        /* CAMPOS DE SAÍDA                                                                     */                                            
                        ,OUTPUT TABLE tt-ret-lancto           /* Collection que contém o retorno do lançamento */
                        ,OUTPUT aux_incrineg                  /* Indicador de crítica de negócio               */
                        ,OUTPUT aux_cdcritic                  /* Código da crítica                             */
                        ,OUTPUT aux_dscritic).                /* Descriçao da crítica                          */
  
                        IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                          DO:  
                             ASSIGN i-cod-erro  = aux_cdcritic
								    c-desc-erro = aux_dscritic.     
							 RUN cria-erro (INPUT p-cooper,
											INPUT p-cod-agencia,
											INPUT p-nro-caixa,
											INPUT i-cod-erro,
											INPUT c-desc-erro,
											INPUT YES).
							 RETURN "NOK".
                          END.   
                          
                        IF  VALID-HANDLE(h-b1wgen0200) THEN
                            DELETE PROCEDURE h-b1wgen0200.

                      ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1 
                             craplot.qtcompln = craplot.qtcompln + 1
                             craplot.qtinfoln = craplot.qtinfoln + 1
                             craplot.vlcompcr = craplot.vlcompcr +  
                                                crapmrw.vldepdin
                             craplot.vlinfocr = craplot.vlinfocr +  
                                                crapmrw.vldepdin.
                  END.
     
             IF   crapmrw.vlchqipr <> 0   THEN 
                  DO:
                      ASSIGN c-docto = c-docto-salvo + "2".
            
                      IF   flg_ci = NO   THEN 
                           DO:
                              /* BLOCO DA INSERÇAO DA CRAPLCM */
                              IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
                                RUN sistema/generico/procedures/b1wgen0200.p 
                                  PERSISTENT SET h-b1wgen0200.

                              RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
                                (INPUT crapdat.dtmvtocd               /* par_dtmvtolt */
                                ,INPUT p-cod-agencia                  /* par_cdagenci */
                                ,INPUT 11                             /* par_cdbccxlt */
                                ,INPUT i-nro-lote                     /* par_nrdolote */
                                ,INPUT aux_nrdconta                   /* par_nrdconta */
                                ,INPUT INTE(c-docto)                  /* par_nrdocmto */
                                ,INPUT 372                            /* par_cdhistor */
                                ,INPUT craplot.nrseqdig + 1           /* par_nrseqdig */
                                ,INPUT crapmrw.vlchqipr               /* par_vllanmto */
                                ,INPUT p-nro-conta                    /* par_nrdctabb */
                                ,INPUT "CRAP57"                       /* par_cdpesqbb */
                                ,INPUT 0                              /* par_vldoipmf */
                                ,INPUT p-ult-sequencia                /* par_nrautdoc */
                                ,INPUT 0                              /* par_nrsequni */
                                ,INPUT 0                              /* par_cdbanchq */
                                ,INPUT 0                              /* par_cdcmpchq */
                                ,INPUT 0                              /* par_cdagechq */
                                ,INPUT 0                              /* par_nrctachq */
                                ,INPUT 0                              /* par_nrlotchq */
                                ,INPUT 0                              /* par_sqlotchq */
                                ,INPUT ""                             /* par_dtrefere */
                                ,INPUT ""                             /* par_hrtransa */
                                ,INPUT 0                              /* par_cdoperad */
                                ,INPUT p-identifica                   /* par_dsidenti */
                                ,INPUT crapcop.cdcooper               /* par_cdcooper */
                                ,INPUT glb_dsdctitg                   /* par_nrdctitg */
                                ,INPUT ""                             /* par_dscedent */
                                ,INPUT 0                              /* par_cdcoptfn */
                                ,INPUT 0                              /* par_cdagetfn */
                                ,INPUT 0                              /* par_nrterfin */
                                ,INPUT 0                              /* par_nrparepr */
                                ,INPUT 0                              /* par_nrseqava */
                                ,INPUT 0                              /* par_nraplica */
                                ,INPUT 0                              /* par_cdorigem */
                                ,INPUT 0                              /* par_idlautom */
                                /* CAMPOS OPCIONAIS DO LOTE                                                            */ 
                                ,INPUT 0                              /* Processa lote                                 */
                                ,INPUT 0                              /* Tipo de lote a movimentar                     */
                                /* CAMPOS DE SAÍDA                                                                     */                                            
                                ,OUTPUT TABLE tt-ret-lancto           /* Collection que contém o retorno do lançamento */
                                ,OUTPUT aux_incrineg                  /* Indicador de crítica de negócio               */
                                ,OUTPUT aux_cdcritic                  /* Código da crítica                             */
                                ,OUTPUT aux_dscritic).                /* Descriçao da crítica                          */
  
                              IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                                DO:  
									 ASSIGN i-cod-erro  = aux_cdcritic
										    c-desc-erro = aux_dscritic.     
									 RUN cria-erro (INPUT p-cooper,
													INPUT p-cod-agencia,
													INPUT p-nro-caixa,
													INPUT i-cod-erro,
													INPUT c-desc-erro,
													INPUT YES).
									 RETURN "NOK".
                                END.   
                                
                              IF  VALID-HANDLE(h-b1wgen0200) THEN
                                  DELETE PROCEDURE h-b1wgen0200.
                           END.     
                      ELSE 
                           DO:
                               CREATE craplci.
                               ASSIGN craplci.cdcooper = crapcop.cdcooper
                                      craplci.dtmvtolt = crapdat.dtmvtocd
                                      craplci.cdagenci = p-cod-agencia
                                      craplci.cdbccxlt = 11
                                      craplci.nrdolote = i-nro-lote
                                      craplci.nrdconta = aux_nrdconta
                                      craplci.nrdocmto = INTE(c-docto)
                                      craplci.vllanmto = crapmrw.vlchqipr
                                      craplci.cdhistor = 487
                                      craplci.nrseqdig = craplot.nrseqdig + 1.
                               VALIDATE craplci.
      
                               /*----- Atualizar Saldo Conta Investimento */
                               FIND crapsli WHERE
                                    crapsli.cdcooper = crapcop.cdcooper     AND
                                    crapsli.nrdconta = aux_nrdconta         AND
                                    MONTH(crapsli.dtrefere) = 
                                                   MONTH(crapdat.dtmvtocd)  AND
                                    YEAR(crapsli.dtrefere) = 
                                                   YEAR(crapdat.dtmvtocd) 
                                    EXCLUSIVE-LOCK NO-ERROR.
                               IF   NOT AVAIL crapsli   THEN
                                    DO:
                                        ASSIGN aux_dtrefere =  
                                           ((DATE(MONTH(crapdat.dtmvtocd),
                                               28,YEAR(crapdat.dtmvtocd)) + 4) -
                                            DAY(DATE(MONTH(crapdat.dtmvtocd),28,
                                               YEAR(crapdat.dtmvtocd)) + 4)).
           
                                        CREATE crapsli.
                                        ASSIGN crapsli.cdcooper =
                                                       crapcop.cdcooper
                                               crapsli.dtrefere = aux_dtrefere
                                               crapsli.nrdconta = aux_nrdconta.
                                    END.

                               ASSIGN crapsli.vlsddisp = crapsli.vlsddisp +  
                                                         crapmrw.vlchqipr.
                               VALIDATE crapsli.
                           END.
            
                      ASSIGN i-sequencia      = craplot.nrseqdig + 1
                             craplot.nrseqdig = craplot.nrseqdig + 1 
                             craplot.qtcompln = craplot.qtcompln + 1
                             craplot.qtinfoln = craplot.qtinfoln + 1
                             craplot.vlcompcr = craplot.vlcompcr + 
                                                 crapmrw.vlchqipr
                             craplot.vlinfocr = craplot.vlinfocr + 
                                                crapmrw.vlchqipr.
                  END.
       
         END. /* IF  AVAIL crapmrw */
   
    FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper  AND 
                           crapmdw.cdagenci = p-cod-agencia     AND
                           crapmdw.nrdcaixa = p-nro-caixa       NO-LOCK:
        FIND crapchd WHERE crapchd.cdcooper = crapcop.cdcooper  AND
                           crapchd.dtmvtolt = crapdat.dtmvtocd  AND
                           crapchd.cdcmpchq = crapmdw.cdcmpchq  AND
                           crapchd.cdbanchq = crapmdw.cdbanchq  AND
                           crapchd.cdagechq = crapmdw.cdagechq  AND
                           crapchd.nrctachq = crapmdw.nrctachq  AND
                           crapchd.nrcheque = crapmdw.nrcheque  
                           USE-INDEX crapchd1 NO-LOCK NO-ERROR.

        IF   AVAILABLE crapchd   THEN
             DO:
                 ASSIGN i-cod-erro  = 92
                        c-desc-erro = " ".           
                 RUN cria-erro (INPUT p-cooper,
                                INPUT p-cod-agencia,
                                INPUT p-nro-caixa,
                                INPUT i-cod-erro,
                                INPUT c-desc-erro,
                                INPUT YES).
                 RETURN "NOK".
             END.

        ASSIGN i-nrdocmto = INTE(c-docto-salvo + "2").

        CREATE crapchd.
        ASSIGN crapchd.cdcooper = crapcop.cdcooper
               crapchd.cdagechq = crapmdw.cdagechq
               crapchd.cdagenci = p-cod-agencia
               crapchd.cdbanchq = crapmdw.cdbanchq
               crapchd.cdbccxlt = 11
               crapchd.nrdocmto = i-nrdocmto 
               crapchd.cdcmpchq = crapmdw.cdcmpchq
               crapchd.cdoperad = p-cod-operador
               crapchd.cdsitatu = 1
               crapchd.dsdocmc7 = crapmdw.dsdocmc7
               crapchd.dtmvtolt = crapdat.dtmvtocd
               crapchd.inchqcop = IF crapmdw.nrctaaux > 0 THEN 1 ELSE 0
               crapchd.insitchq = 0
               crapchd.cdtipchq = crapmdw.cdtipchq
               crapchd.nrcheque = crapmdw.nrcheque
               crapchd.nrctachq = IF crapchd.inchqcop = 1
                                  THEN crapmdw.nrctabdb
                                  ELSE crapmdw.nrctachq
               crapchd.nrdconta = aux_nrdconta
               crapchd.nrddigc1 = crapmdw.nrddigc1
               crapchd.nrddigc2 = crapmdw.nrddigc2
               crapchd.nrddigc3 = crapmdw.nrddigc3
               crapchd.nrddigv1 = INT(ENTRY(1,crapmdw.lsdigctr))
               crapchd.nrddigv2 = INT(ENTRY(2,crapmdw.lsdigctr))
               crapchd.nrddigv3 = INT(ENTRY(3,crapmdw.lsdigctr))
               crapchd.nrdolote = i-nro-lote
               crapchd.tpdmovto = crapmdw.tpdmovto
               crapchd.nrterfin = 0
               crapchd.vlcheque = crapmdw.vlcompel.
               crapchd.nrseqdig = i-sequencia.
        VALIDATE crapchd.
        
        RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
        RUN atualiza-previa-caixa  IN h_b1crap00  (INPUT p-cooper,
                                                   INPUT p-cod-agencia,
                                                   INPUT p-nro-caixa,
                                                   INPUT p-cod-operador,
                                                   INPUT crapdat.dtmvtocd,
                                                   INPUT 1). /**Inclusao**/ 
        DELETE PROCEDURE h_b1crap00.
        

    END. /* FOR EACH crapmdw */
  
    /*---- Gera literal autenticacao - RECEBIMENTO(Rolo) ----*/
    ASSIGN c-nome-titular1 = " "
           c-nome-titular2 = " ".

    FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                       crapass.nrdconta = aux_nrdconta      
					   NO-LOCK NO-ERROR.

    IF   AVAIL crapass   THEN
	   DO:
          ASSIGN c-nome-titular1 = crapass.nmprimtl.
          
		  IF crapass.inpessoa = 1 THEN
		     DO:
			    FOR FIRST crapttl FIELDS(crapttl.nmextttl)
				                   WHERE crapttl.cdcooper = crapass.cdcooper AND
				                         crapttl.nrdconta = crapass.nrdconta AND
								         crapttl.idseqttl = 2
								         NO-LOCK:

				  ASSIGN c-nome-titular2 = crapttl.nmextttl.

		        END.

			 END.

	   END.
       
    ASSIGN c-literal = " "
           c-literal[1] = TRIM(crapcop.nmrescop) +  " - " + 
                                                 TRIM(crapcop.nmextcop) 
           c-literal[2]  = " "
           c-literal[3]  = STRING(crapdat.dtmvtocd,"99/99/99") + " " + 
                           STRING(TIME,"HH:MM:SS") +  " PA  " + 
                           STRING(p-cod-agencia,"999") + "  CAIXA: " + 
                           STRING(p-nro-caixa,"Z99") + "/" +
                           SUBSTR(p-cod-operador,1,10)  
             c-literal[4]  = " " 
             c-literal[5]  = "      ** COMPROVANTE DE DEPOSITO " + 
                             STRING(i-nro-docto,"ZZZ,ZZ9")  + " **".
             
    IF   flg_ci = YES   THEN
         c-literal[5] = "* COMPROVANTE DEPOSITO CONTA INV." + 
                        STRING(i-nro-docto,"ZZZ,ZZ9")  + "  *". 

    ASSIGN c-literal[6]  = " "  
           c-literal[7]  = "CONTA: " + TRIM(STRING(aux_nrdconta,"zzzzz,zzz,9"))
                           + "   PA:  " + TRIM(STRING(crapass.cdagenci,"zz9"))
           c-literal[8]  = "       " +  TRIM(c-nome-titular1)
           c-literal[9]  = "       " +  TRIM(c-nome-titular2)
           c-literal[10] = " ".
                  
    IF   p-identifica <> "  "   THEN
         ASSIGN c-literal[11] = "DEPOSITADO POR"  
                c-literal[12] = TRIM(p-identifica)
                c-literal[13] = " ".  
          
    ASSIGN c-literal[14] = "   TIPO DE DEPOSITO     VALOR EM R$ LIBERACAO EM"              c-literal[15] = "------------------------------------------------".
     
    IF   de-dinheiro > 0   THEN  
         ASSIGN c-literal[16] = "   EM DINHEIRO.....: " + 
                                STRING(de-dinheiro,"ZZZ,ZZZ,ZZ9.99") + "   ". 
     
    IF   de-cheque  > 0   THEN   
         ASSIGN  c-literal[17]  = "CHEQ.LIBERADO......: " +
                                  STRING(de-cheque,"ZZZ,ZZZ,ZZ9.99") + " ".
    
    ASSIGN c-literal[18] = " "  
           c-literal[19] = "TOTAL DEPOSITADO...: " + 
                           STRING(de-valor,"ZZZ,ZZZ,ZZ9.99") 
           c-literal[20] = " "
           c-literal[21] = p-literal
           c-literal[22] = " "
           c-literal[23] = " "
           c-literal[24] = " "
           c-literal[25] = " "
           c-literal[26] = " "
           c-literal[27] = " "
           c-literal[28] = " "
           c-literal[29] = " "
           c-literal[30] = " "
           c-literal[31] = " ".
           
    ASSIGN p-literal-autentica = STRING(c-literal[1],"x(48)")   + 
                                 STRING(c-literal[2],"x(48)")   + 
                                 STRING(c-literal[3],"x(48)")   + 
                                 STRING(c-literal[4],"x(48)")   + 
                                 STRING(c-literal[5],"x(48)")   + 
                                 STRING(c-literal[6],"x(48)")   + 
                                 STRING(c-literal[7],"x(48)")   + 
                                 STRING(c-literal[8],"x(48)")   + 
                                 STRING(c-literal[9],"x(48)")   + 
                                 STRING(c-literal[10],"x(48)").
                                       
     IF   c-literal[12] <> " "   THEN
          ASSIGN p-literal-autentica = p-literal-autentica + 
                                       STRING(c-literal[11],"x(48)")
                 p-literal-autentica = p-literal-autentica + 
                                       STRING(c-literal[12],"x(48)")
                 p-literal-autentica = p-literal-autentica + 
                                       STRING(c-literal[13],"x(48)").

     ASSIGN p-literal-autentica = p-literal-autentica + 
                                  STRING(c-literal[14],"x(48)")
            p-literal-autentica = p-literal-autentica + 
                                  STRING(c-literal[15],"x(48)").

     IF   c-literal[16] <> " "   THEN
          ASSIGN p-literal-autentica = p-literal-autentica +
                                       STRING(c-literal[16],"x(48)").

     IF   c-literal[17] <> " "   THEN
          ASSIGN p-literal-autentica = p-literal-autentica +
                                       STRING(c-literal[17],"x(48)").
     
     ASSIGN c-literal[26] = centraliza("SAC - " + STRING(crapcop.nrtelsac),48)
            c-literal[27] = centraliza("Atendimento todos os dias das " + REPLACE(REPLACE(STRING(crapcop.hrinisac,"HH:MM"),':','h'),'h00','h') + " as " + REPLACE(REPLACE(STRING(crapcop.hrfimsac,"HH:MM"),':','h'),'h00','h'),48)
            c-literal[28] = centraliza("OUVIDORIA - " + STRING(crapcop.nrtelouv),48)
            c-literal[29] = centraliza("Atendimento nos dias uteis das " + REPLACE(REPLACE(STRING(crapcop.hriniouv,"HH:MM"),':','h'),'h00','h') + " as " + REPLACE(REPLACE(STRING(crapcop.hrfimouv,"HH:MM"),':','h'),'h00','h'),48).    

     ASSIGN p-literal-autentica = p-literal-autentica         +
                                  STRING(c-literal[18],"x(48)")   + 
                                  STRING(c-literal[19],"x(48)")   + 
                                  STRING(c-literal[20],"x(48)")   +
                                  STRING(c-literal[21],"x(48)")   + 
                                  STRING(c-literal[22],"x(48)")   + 
                                  STRING(c-literal[23],"x(48)")   + 
                                  STRING(c-literal[24],"x(48)")   + 
                                  STRING(c-literal[25],"x(48)")   + 
                                  STRING(c-literal[26],"x(48)")   + 
                                  STRING(c-literal[27],"x(48)")   + 
                                  STRING(c-literal[28],"x(48)")   + 
                                  STRING(c-literal[29],"x(48)")   +
                                  STRING(c-literal[30],"x(48)")   +
                                  STRING(c-literal[31],"x(48)")   +
								  FILL(' ',384).
                                   
     ASSIGN p-ult-sequencia-autentica = p-ult-sequencia.

     ASSIGN in99 = 0. 
     DO   WHILE TRUE:
          ASSIGN in99 = in99 + 1.
          FIND crapaut WHERE RECID(crapaut) = p-registro 
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF   NOT AVAIL crapaut THEN  
               DO:
                   IF   LOCKED crapaut   THEN 
                        DO:
                            IF   in99 < 100   THEN 
                                 DO:
                                     PAUSE 1 NO-MESSAGE.
                                     NEXT.
                                 END.
                            ELSE 
                                 DO:
                                     ASSIGN i-cod-erro  = 0
                                            c-desc-erro = 
                                                    "Tabela CRAPAUT em uso ".
                                     RUN cria-erro (INPUT p-cooper,
                                                    INPUT p-cod-agencia,
                                                    INPUT p-nro-caixa,
                                                    INPUT i-cod-erro,
                                                    INPUT c-desc-erro,
                                                    INPUT YES).
                                     RETURN "NOK".
                                 END.
                        END.
               END.
          ELSE 
               DO:
                   ASSIGN crapaut.dslitera = p-literal-autentica.
                   RELEASE crapaut.
                   LEAVE.
               END.
     END.

     RELEASE craplot.
     RETURN "OK".
END PROCEDURE.

PROCEDURE gera-tabela-resumo-dinheiro:

     DEF INPUT PARAM  p-cooper         AS CHAR NO-UNDO.
     DEF INPUT PARAM  p-cod-agencia    AS INT  NO-UNDO. /* Cod. Agencia       */
     DEF INPUT PARAM  p-nro-caixa      AS INT  NO-UNDO. /* Numero Caixa       */
     DEF INPUT PARAM  p-cod-operador   AS CHAR NO-UNDO.
     DEF INPUT PARAM  p-nro-conta      AS INTE NO-UNDO.
     DEF INPUT PARAM  p-valor          AS DEC  NO-UNDO. /* Valor Dinheiro */
   
     DEF VAR aux_contador              AS INT  NO-UNDO.
     DEF VAR aux_flcriarw              AS LOGICAL NO-UNDO.
   
   
     FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

     RUN elimina-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa).

     ASSIGN p-nro-conta = DEC(REPLACE(STRING(p-nro-conta),".","")).

     IF   LENGTH(STRING(p-nro-conta)) = 9   THEN 
          DO: /* Conta Investimento */
              
              ASSIGN aux_nrctainv = p-nro-conta.
              RUN gera_nrdconta.
              ASSIGN p-nro-conta = aux_nrctainv.
              
              FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper    AND
                                 crapass.nrdconta = p-nro-conta 
                                 NO-LOCK NO-ERROR.
              ASSIGN p-nro-conta = crapass.nrdconta.
          END.
     
     DO aux_contador = 1 TO 10:
    
        c-desc-erro = "".
        
     FIND FIRST crapmrw WHERE crapmrw.cdcooper = crapcop.cdcooper   AND
                              crapmrw.cdagenci = p-cod-agencia      AND
                              crapmrw.nrdcaixa = p-nro-caixa   
                                 EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                                 
        IF  NOT AVAILABLE crapmrw  THEN
            DO:
                IF  LOCKED crapmrw  THEN
                    DO:
                        c-desc-erro = "Resumo do dinheiro ja esta sendo alterado. " +
                                       "Tente novamente.".
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    DO:
                        aux_flcriarw = TRUE. 
                        LEAVE.
                    END.
            END.
    
        aux_flcriarw = FALSE.
    
        LEAVE.
        
     END. /* Fim do DO ... TO */

     IF  c-desc-erro <> "" THEN  
     DO:
       ASSIGN i-cod-erro  = 0.
              
       RUN cria-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa,
                      INPUT i-cod-erro,
                      INPUT c-desc-erro,
                      INPUT YES).
     
       RETURN "NOK".      
     END.
                              
     IF aux_flcriarw = TRUE THEN  
          DO:
              CREATE crapmrw.
              ASSIGN crapmrw.cdcooper = crapcop.cdcooper
                     crapmrw.cdagenci = p-cod-agencia 
                     crapmrw.nrdcaixa = p-nro-caixa   
                     crapmrw.nrdconta = p-nro-conta.
          END.

     ASSIGN crapmrw.cdopecxa = p-cod-operador
            crapmrw.vldepdin = p-valor.
     
     VALIDATE crapmrw.
      
     RETURN "OK".
END PROCEDURE.

PROCEDURE gera-tabela-resumo-cheques:

     DEF INPUT PARAM  p-cooper         AS CHAR NO-UNDO.
     DEF INPUT PARAM  p-cod-agencia    AS INT  NO-UNDO. /* Cod. Agencia */
     DEF INPUT PARAM  p-nro-caixa      AS INT  NO-UNDO. /* Numero Caixa */
     DEF INPUT PARAM  p-cod-operador   AS CHAR NO-UNDO.
     DEF INPUT PARAM  p-nro-conta      AS INT  NO-UNDO.
      
     DEF VAR aux_contador              AS INT  NO-UNDO.
     DEF VAR aux_flcriarw              AS LOGICAL NO-UNDO.
     DEF VAR aux_vlcompel              LIKE crapmdw.vlcompel NO-UNDO.
     
     
      
     ASSIGN p-nro-conta = DEC(REPLACE(STRING(p-nro-conta),".","")).

     RUN elimina-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa).

     FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
      
     IF   LENGTH(STRING(p-nro-conta)) = 9   THEN  
          DO: /* Conta Investimento */
              
              ASSIGN aux_nrctainv = p-nro-conta.
              RUN gera_nrdconta.
              ASSIGN p-nro-conta = aux_nrctainv.
              
              FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper    AND
                                 crapass.nrdconta = p-nro-conta 
                                 NO-LOCK NO-ERROR.
              ASSIGN p-nro-conta = crapass.nrdconta.
          END.
        
     FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                              NO-LOCK NO-ERROR.

     
    DO aux_contador = 1 TO 10:
    
        c-desc-erro = "".
        
     FIND FIRST crapmrw WHERE crapmrw.cdcooper = crapcop.cdcooper   AND
                              crapmrw.cdagenci = p-cod-agencia      AND
                              crapmrw.nrdcaixa = p-nro-caixa 
                                 EXCLUSIVE-LOCK  NO-WAIT NO-ERROR.        
                                 
        IF  NOT AVAILABLE crapmrw  THEN
            DO:
                IF  LOCKED crapmrw  THEN
                    DO:
                        c-desc-erro = "Resumo do cheque ja esta sendo alterado. " +
                                      "Tente novamente.".
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    DO:
                        aux_flcriarw = TRUE. 
                        LEAVE.
                    END.
            END.
    
        aux_flcriarw = FALSE.
    
        LEAVE.
        
    END. /* Fim do DO ... TO */

    IF  c-desc-erro <> "" THEN      
    DO:
       ASSIGN i-cod-erro  = 0.
              
       RUN cria-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa,
                      INPUT i-cod-erro,
                      INPUT c-desc-erro,
                      INPUT YES).
    
       RETURN "NOK".      
    END.

    IF aux_flcriarw = TRUE THEN  
          DO:
              CREATE crapmrw.
              ASSIGN crapmrw.cdcooper = crapcop.cdcooper
                     crapmrw.cdagenci = p-cod-agencia 
                     crapmrw.nrdcaixa = p-nro-caixa   
                     crapmrw.nrdconta = p-nro-conta.
          END.

     ASSIGN crapmrw.cdopecxa = p-cod-operador
            crapmrw.vlchqcop = 0
            crapmrw.vlchqspr = 0
            crapmrw.vlchqipr = 0
            crapmrw.vlchqsfp = 0
            crapmrw.vlchqifp = 0
            aux_vlcompel = 0.

     FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper     AND
                            crapmdw.cdagenci = p-cod-agencia        AND
                            crapmdw.nrdcaixa = p-nro-caixa 
                            NO-LOCK:
         ASSIGN aux_vlcompel = aux_vlcompel + crapmdw.vlcompel.
     END. /* FOR EACH crapmdw */
     
     ASSIGN crapmrw.vlchqipr  = aux_vlcompel.
     
     VALIDATE crapmrw.
                            
     
     RETURN "OK".
END PROCEDURE.

PROCEDURE critica-valor-dinheiro-cheque:

    DEF INPUT PARAM  p-cooper         AS CHAR NO-UNDO.
    DEF INPUT PARAM  p-cod-agencia    AS INT  NO-UNDO. /* Cod. Agencia */
    DEF INPUT PARAM  p-nro-caixa      AS INT  NO-UNDO. /* Numero Caixa */
    DEF INPUT PARAM  p-valor          AS DEC  NO-UNDO.
    DEF INPUT PARAM  p-valor1         AS DEC  NO-UNDO.
    DEF OUTPUT PARAM p-achou-crapmdw  AS LOG  NO-UNDO.
                
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
                             
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    IF   p-valor  = 0   AND
         p-valor1 = 0   THEN 
         DO: 
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Informe Valor ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.

    FIND FIRST crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper    AND
                             crapmdw.cdagenci = p-cod-agencia       AND
                             crapmdw.nrdcaixa = p-nro-caixa   
                             NO-LOCK NO-ERROR.
                             
    ASSIGN p-achou-crapmdw = AVAIL crapmdw.
    IF   p-valor1 <> 0 AND NOT AVAIL crapmdw   THEN 
         DO: 
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Efetue Captura".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
    IF   p-valor1 = 0 AND AVAIL crapmdw   THEN 
         DO: 
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Informe o valor de cheques".           
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


PROCEDURE gera_nrdconta.

    DEF VAR aux_controle AS CHAR                                NO-UNDO.

    
    ASSIGN aux_controle = SUBSTR(STRING(aux_nrctainv),9,1)
           aux_nrctainv = INT(SUBSTR(STRING(aux_nrctainv),1,8)) - 60000000.   
           
    ASSIGN aux_nrctainv = INT(STRING(aux_nrctainv) + aux_controle)
           glb_nrcalcul = aux_nrctainv.

    RUN fontes/digbbx.p(INPUT  glb_nrcalcul,
                        OUTPUT glb_dsdctitg,
                        OUTPUT glb_stsnrcal).
    
    ASSIGN aux_nrctainv = INT(glb_dsdctitg).
    
                        
END PROCEDURE.

/* b1crap57.p */

/* ......................................................................... */

