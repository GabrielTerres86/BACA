/* .............................................................................

   Programa: siscaixa/web/dbo/b1crap56.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 15/07/2019

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Outros - Lancamento especiais

   Alteracoes: 29/08/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)
                            
               07/11/2005 - Alteracao de crapchq para crapfdc (SQLworks - Eder)
               19/11/2005 - Adequacao ao padrao, analise de performance e dos
                            itens convertidos (SQLWorks - Andre)
               24/11/2005 - Nenhum historico de cheque mais entra (Magui).
               24/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               09/04/2007 - Controlar horarios da conta salario somente para o
                            historico 561 (Evandro).
                
               10/09/2007 - Conversao de rotina ver_capital para BO 
                            (Sidnei/Precise)
                            
               29/01/2008 - Incluido PA do cooperado na impressao do
                            comprovante (Elton).

               23/12/2008 - Incluido campo "capital" na temp-table tt-conta
                            (Elton).             

               10/03/2009 - Ajuste para unificacao dos bancos de dados
                            (Evandro).
                            
               25/05/2009 - Alteracao CDOPERAD (Kbase).
               
               31/05/2010 - Adicionada FIND crapdat na procedures 
                            valida-saldo-conta (Fernando).
                            
               28/04/2011 - Adaptado a valida-saldo-conta para alimentar o 
                            p-valor-disponivel antes do IF para tambem
                            ser aproveitada no rotina 20 (Guilherme).
                            
               07/07/2011 - Realizado correcao no format do campo 
                            c-literal-compr[07] para "zzzz,zz9.9" (Adriano).    
                            
               28/07/2011 - Verificar o valor do tarifa tambem
                            antes de realizar a transferencia (Gabriel).  
                            
               25/08/2011 - Verificar valor da tarifa na procedure 
                            'valida-saldo-conta' somente quando for DOC/TED 
                            (Diego).                                 
               
               14/12/2011 - Verifica valor da tarifa na procedure 
                            'valida-saldo-conta' para transferencia entre
                            cooperativas (Elton)
                          - Incluidos os parametros p-cod-rotina e p-coopdest 
                            na procedure valida-saldo-conta (Elton).
                            
               23/12/2011 - Nao permitir incluir com historico 1030 (Gabriel)   
               
               
               11/03/2013 - Incluso critica para nao permitir deposito de
                            conta migrada (Daniel).          
                            
               17/07/2013 - Utilizar nova estrutura para obter valor das
                            tarifas (David).             
                            
               30/07/2013 - Utilizar nova estrutura para obter valor das
                            tarifas utilizando b1crap20 (Daniel).  
                 
               03/12/2013 - Trocar campo nrdconta por nrctabb na leitura
                            da craplcm (Tiago).
                            
               16/12/2013 - Ajuste migracao Acredi (Elton).             
               
               16/12/2013 - Adicionado validate para tabela crapavs (Tiago).
               
               05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
               
               15/06/2015 - Alterar o sistema para ubstituir a utilização
                            do parâmetro HRTRCTASAL dentro da CRAPTAB por
                            FOLHAIB_HOR_LIM_PORTAB.(Andre Santos - SUPERO)
							
			   13/11/2015 - Inclusao de verificacao estado de crise. 
                            (Jaison/Andrino)
                            
			   17/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).

			   23/08/2017 - Alterado para validar as informacoes do operador 
							pelo AD. (PRJ339 - Reinert)

			   06/02/2018 - Adicionado novo historico. (SD 838581 - Kelvin)

               16/03/2018 - Substituida verificacao "cdtipcta = 6,7" pela
                            modalidade do tipo de conta igual a 3. PRJ366 (Lombardi).
                            
         21/05/2018 - Alteraçoes para usar as rotinas mesmo com o processo 
                      norturno rodando (Douglas Pagel - AMcom).

               12/06/2018 - P450 - Chamada da rotina para consistir lançamento em conta corrente(LANC0001) na tabela CRAPLCM  - José Carvalho(AMcom)
               
               16/01/2019 - Revitalizacao (Remocao de lotes) - Pagamentos, Transferencias, Poupanca
                     Heitor (Mouts)

				02/02/2019 - Correção para o tipo de documento "TED C":
							-> Ao optar por "Espécie" deve ser permitir apenas para não cooperados
						   (Jonata - Mouts PRB0040337).
												   
                 15/07/2019 - Tratamento para nao permitir o historico 561, 
				              exceto ACENTRA - RITM0015559 (Jose Gracik/Mouts). 
............................................................................ */
/*----------------------------------------------------------------------*/
/*  b1crap56.p - Outros                                                */
/*----------------------------------------------------------------------*/

{dbo/bo-erro1.i}
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0200tt.i }

DEF VAR h-b1wgen0001 AS HANDLE                                  NO-UNDO.

DEF VAR i-cod-erro         AS INTE                              NO-UNDO.
DEF VAR c-desc-erro        AS CHAR                              NO-UNDO.

DEF VAR i-nro-lote         AS INTE                              NO-UNDO.
DEF VAR h_b2crap00         AS HANDLE                            NO-UNDO.
DEF VAR h-b1crap00         AS HANDLE                            NO-UNDO.
DEF VAR h-b1crap02         AS HANDLE                            NO-UNDO.

DEF VAR i_conta            AS DEC                               NO-UNDO.
DEF VAR aux_nrdconta       AS INTE                              NO-UNDO.
DEF VAR aux_nrdconta1      AS INTE                              NO-UNDO.
DEF VAR aux_nrtrfcta       LIKE craptrf.nrsconta                NO-UNDO.

DEF VAR i_nro-docto        AS INTE                              NO-UNDO.
DEF VAR i_documento        AS DEC                               NO-UNDO.
DEF VAR aux_vlsdchsl       AS DEC                               NO-UNDO.
DEF VAR aux_vlslchsl       AS DEC                               NO-UNDO.
DEF VAR aux_vlsdbloq       AS DEC                               NO-UNDO.
DEF VAR aux_vlsdblpr       AS DEC                               NO-UNDO.
DEF VAR aux_vlsdblfp       AS DEC                               NO-UNDO.
DEF VAR in99               AS INTE                              NO-UNDO.

DEF VAR p-literal          AS CHAR                              NO-UNDO.
DEF VAR c-literal-compr    AS CHAR FORMAT "x(48)" EXTENT 32.
DEF VAR p-ult-sequencia    AS INTE                              NO-UNDO.
DEF VAR p-registro         AS RECID                             NO-UNDO.
DEF VAR de-valor-libera    AS DECI                              NO-UNDO.

DEF VAR de-valor-bloqueado AS DEC                               NO-UNDO.
DEF VAR de-valor-liberado  AS DEC                               NO-UNDO.

DEF VAR i-nro-docto        AS INTE                              NO-UNDO.
DEF VAR i-tipo-lote        AS INTE                              NO-UNDO.
DEF VAR c-docto-salvo      AS CHAR                              NO-UNDO.
DEF VAR c-literal          AS CHAR                              NO-UNDO.
DEF VAR c-nome-operador    AS CHAR                              NO-UNDO.

DEF  VAR glb_nrcalcul      AS DECI                              NO-UNDO.
DEF  VAR glb_dsdctitg      AS CHAR                              NO-UNDO.
DEF  VAR glb_stsnrcal      AS LOGI                              NO-UNDO.

DEF  VAR aux_ponteiro      AS INTE                              NO-UNDO.
DEF  VAR aux_hrlimfol      AS CHAR                              NO-UNDO.

/* Variáveis de uso da BO 200 */
DEF VAR h-b1wgen0200         AS HANDLE                              NO-UNDO.
DEF VAR aux_incrineg         AS INT                                 NO-UNDO.
DEF VAR aux_cdcritic         AS INT                                 NO-UNDO.
DEF VAR aux_dscritic         AS CHAR                                NO-UNDO.


DEF BUFFER b-craphis FOR craphis.

DEF TEMP-TABLE tt-conta                                         NO-UNDO
    FIELD situacao           AS CHAR FORMAT "x(21)"
    FIELD tipo-conta         AS CHAR FORMAT "x(21)"
    FIELD empresa            AS CHAR FORMAT "x(15)"
    FIELD devolucoes         AS INTE FORMAT "99"
    FIELD agencia            AS CHAR FORMAT "x(15)"
    FIELD magnetico          AS INTE FORMAT "z9"     
    FIELD estouros           AS INTE FORMAT "zzz9"
    FIELD folhas             AS INTE FORMAT "zzz,zz9"
    FIELD identidade         AS CHAR 
    FIELD orgao              AS CHAR 
    FIELD cpfcgc             AS CHAR 
    FIELD disponivel         AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD bloqueado          AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD bloq-praca         AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD bloq-fora-praca    AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD cheque-salario     AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD saque-maximo       AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD acerto-conta       AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD db-cpmf            AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD limite-credito     AS DEC 
    FIELD ult-atualizacao    AS DATE
    FIELD saldo-total        AS DEC FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD nome-tit           AS CHAR
    FIELD nome-seg-tit       AS CHAR
    FIELD capital            AS DEC FORMAT "zzz,zzz,zzz,zz9.99-". 
  

PROCEDURE valida-outros-conta:
    DEF INPUT  PARAM p-cooper               AS CHAR NO-UNDO. 
    DEF INPUT  PARAM p-cod-agencia          AS INTE NO-UNDO. 
    DEF INPUT  PARAM p-nro-caixa            AS INTE NO-UNDO.      
    DEF INPUT  PARAM p-cdhistor             AS INTE NO-UNDO.    
    DEF INPUT  PARAM p-nro-docto            AS INTE NO-UNDO.
    DEF INPUT  PARAM p-nro-conta            AS INTE NO-UNDO.    
    DEF OUTPUT PARAM p-nome-titular         AS CHAR NO-UNDO.
    DEF OUTPUT PARAM p-poupanca             AS LOG  NO-UNDO.
    DEF OUTPUT PARAM p-dshist               AS CHAR NO-UNDO.
    DEF OUTPUT PARAM p-transferencia-conta  AS CHAR NO-UNDO.
    
    DEF VAR aux_dshistor AS CHAR                    NO-UNDO.
    DEF VAR aux_flestcri AS INTE                    NO-UNDO.
    DEF VAR aux_cdmodali AS INTE                    NO-UNDO.
    DEF VAR aux_des_erro AS CHAR                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                    NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
     
   ASSIGN p-poupanca            = NO
          p-transferencia-conta = " ".

   RUN elimina-erro (INPUT p-cooper,
                     INPUT p-cod-agencia,
                     INPUT p-nro-caixa).

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
    
    /* Efetuar a chamada a rotina Oracle */
    RUN STORED-PROCEDURE pc_estado_crise
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT "N"              /* Identificador para verificar processo (N – Nao / S – Sim) */
                                        ,OUTPUT 0               /* Identificador estado de crise (0 - Nao / 1 - Sim) */
                                        ,OUTPUT ?).             /* XML com informacoes das cooperativas */
    
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_estado_crise
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
    
    ASSIGN aux_flestcri = 0
           aux_flestcri = pc_estado_crise.pr_inestcri
                          WHEN pc_estado_crise.pr_inestcri <> ?.

    /* Se estiver em estado de crise */
    IF  aux_flestcri > 0  THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Sistema em estado de crise.".           
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.

   FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                      NO-LOCK NO-ERROR.

   ASSIGN aux_dshistor = "1,386,3,4,403,404,21,26,22,372,1030".

   IF  CAN-DO(aux_dshistor,STRING(p-cdhistor))   THEN
       DO:
           ASSIGN i-cod-erro  = 93  /* Historico Errado */
                  c-desc-erro = " ".           
           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
       END.

   IF  p-cdhistor        = 561 AND   /* Salario Liquido */
       crapcop.cdcooper <> 5   THEN  /* Exceto Cooperativa ACENTRA */
       DO:
           ASSIGN i-cod-erro  = 93  /* Historico Errado */
                  c-desc-erro = " ".           
           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
       END.

   IF  p-cdhistor = 2553 THEN
       DO:
         ASSIGN i-cod-erro  = 0 
                c-desc-erro = "Pagamentos no caixa devem ser realizados na rotina 54.".           
         RUN cria-erro (INPUT p-cooper,
                        INPUT p-cod-agencia,
                        INPUT p-nro-caixa,
                        INPUT i-cod-erro,
                        INPUT c-desc-erro,
                        INPUT YES).
         RETURN "NOK".   
       END.

   FIND craphis WHERE craphis.cdcooper = crapcop.cdcooper   AND
                      craphis.cdhistor = p-cdhistor
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
   ELSE 
        ASSIGN p-dshist = craphis.dshistor.

   IF   craphis.tplotmov <> 1   AND
        craphis.tplotmov <> 32 THEN  /* Historico 561 */
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

   IF   craphis.tpctbcxa <> 2   AND
        craphis.tpctbcxa <> 3   THEN 
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
                                         
    /* Se for histórico 561 - CONTA SALARIO, verifica horario dos TEDS */
    IF   craphis.cdhistor = 561   THEN
         DO:

            /* Verif. horario de corte */
            RUN STORED-PROC {&sc2_dboraayl}.send-sql-statement
                aux_ponteiro = PROC-HANDLE
                ("SELECT gene0001.fn_param_sistema('CRED','" +
                 STRING(crapcop.cdcooper) +
                 "','FOLHAIB_HOR_LIM_PORTAB') FROM dual").

            FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = aux_ponteiro:
                ASSIGN aux_hrlimfol = proc-text.
            END.

            CLOSE STORED-PROC {&sc2_dboraayl}.send-sql-statement
                WHERE PROC-HANDLE = aux_ponteiro.

            IF  (INT(SUBSTR(aux_hrlimfol,1,2)) * 3600 +
                 INT(SUBSTR(aux_hrlimfol ,4,2)) * 60) <= TIME THEN DO:
                
                ASSIGN i-cod-erro  = 676
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

   IF   p-nro-conta = 0   THEN  
        DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Informe Conta ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
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
   IF   RETURN-VALUE = "NOK"   THEN
        RETURN "NOK".
      
   ASSIGN aux_nrdconta = p-nro-conta.
                                       
   /* Conta Salario  - historico 561 */
   IF  p-cdhistor = 561 THEN      
       DO:
          FIND crapccs NO-LOCK WHERE
               crapccs.cdcooper = crapcop.cdcooper AND
               crapccs.nrdconta = aux_nrdconta NO-ERROR.
          IF   NOT  AVAIL crapccs THEN
               DO:
                  ASSIGN i-cod-erro  = 0                            
                         c-desc-erro = "Conta Salario nao Cadastrada".
                  RUN cria-erro (INPUT p-cooper,
                                 INPUT p-cod-agencia,
                                 INPUT p-nro-caixa,
                                 INPUT i-cod-erro,
                                 INPUT c-desc-erro,
                                 INPUT YES).
                  RETURN "NOK".
               END.        

          IF  crapccs.cdsitcta = 2 THEN     
              DO:
                 ASSIGN i-cod-erro  = 0                            
                        c-desc-erro = "Conta Salario Inativa".
                 RUN cria-erro (INPUT p-cooper,
                                INPUT p-cod-agencia,
                                INPUT p-nro-caixa,
                                INPUT i-cod-erro,
                                INPUT c-desc-erro,
                                INPUT YES).
                 RETURN "NOK".
              END.        

          ASSIGN p-nome-titular = crapccs.nmfuncio.
          RETURN "OK".
       
       END.

   
   IF p-nro-conta > 0 THEN
        DO:
           IF CAN-FIND(FIRST craptco WHERE 
                             craptco.cdcopant = crapcop.cdcooper  AND
                             craptco.nrctaant = p-nro-conta       AND
                             craptco.flgativo = TRUE) THEN DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Conta migrada para outra cooperativa, operacao nao permitida.".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END. 
        END.
  
   /* Cooperados */
   DO   WHILE TRUE:

        FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
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
                            craptrf.cdcooper = crapcop.cdcooper     AND
                            craptrf.nrdconta = crapass.nrdconta     AND
                            craptrf.tptransa = 1                    AND
                            craptrf.insittrs = 2  
                            USE-INDEX craptrf1 NO-LOCK NO-ERROR.

            IF   NOT AVAIL craptrf   THEN  
                 DO:
                     ASSIGN i-cod-erro  = 95 /* Titular da Conta Bloqueado */
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
                                             INPUT  crapdat.dtmvtolt,
                                             INPUT  "b1crap56",
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
   END.  /* DO WHILE */

   IF   aux_nrtrfcta > 0   THEN /* Transferencia de Conta */
        ASSIGN p-transferencia-conta = "Conta transferida do Numero  " +
                                       STRING(p-nro-conta,"zzzz,zzz,9") + 
                                       " para o numero " + 
                                       STRING(aux_nrtrfcta,"zzzz,zzz,9")                       aux_nrdconta = aux_nrtrfcta.

   ASSIGN p-nome-titular = crapass.nmprimtl.

   IF   craphis.indebcre = "C"   THEN 
        DO:
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
            
            IF   aux_cdmodali = 3 THEN  /* Conta tipo Poupan‡a */
             ASSIGN p-poupanca = YES.
        END.
   RETURN "OK".

END PROCEDURE.

PROCEDURE valida-outros:
    
    DEF INPUT  PARAM p-cooper          AS CHAR NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia     AS INTE NO-UNDO. 
    DEF INPUT  PARAM p-nro-caixa       AS INTE NO-UNDO.    
    DEF INPUT  PARAM p-cdhistor        AS INTE NO-UNDO.    
    DEF INPUT  PARAM p-nro-conta       AS INTE NO-UNDO.     
    DEF INPUT  PARAM p-nro-docto       AS INTE NO-UNDO.
    DEF INPUT  PARAM p-valor           AS DEC  NO-UNDO.
    DEF INPUT  PARAM p-liberacao       AS DATE NO-UNDO.
    DEF OUTPUT PARAM p-conta-atualiza  AS INTE NO-UNDO.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
     
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
    
    ASSIGN i-nro-lote = 11000 + p-nro-caixa.

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.

    FIND craphis WHERE craphis.cdcooper = crapcop.cdcooper   AND
                       craphis.cdhistor = p-cdhistor
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
                                          
    /* Se for histórico 561 - CONTA SALARIO, verifica horario dos TEDS */
    IF   craphis.cdhistor = 561   THEN
         DO:
             
             /* Verif. horario de corte */
            RUN STORED-PROC {&sc2_dboraayl}.send-sql-statement
                aux_ponteiro = PROC-HANDLE
                ("SELECT gene0001.fn_param_sistema('CRED','" +
                 STRING(crapcop.cdcooper) +
                 "','FOLHAIB_HOR_LIM_PORTAB') FROM dual").

            FOR EACH {&sc2_dboraayl}.proc-text-buffer WHERE PROC-HANDLE = aux_ponteiro:
                ASSIGN aux_hrlimfol = proc-text.
            END.

            CLOSE STORED-PROC {&sc2_dboraayl}.send-sql-statement
                WHERE PROC-HANDLE = aux_ponteiro.

            IF  (INT(SUBSTR(aux_hrlimfol,1,2)) * 3600 +
                 INT(SUBSTR(aux_hrlimfol ,4,2)) * 60) <= TIME THEN DO:
                
                ASSIGN i-cod-erro  = 676
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
                                                   
    IF   p-nro-docto = 0    AND  
        (p-cdhistor <>   5  AND
         p-cdhistor <> 355  AND  
         p-cdhistor <> 612  AND
         p-cdhistor <> 135  AND
         p-cdhistor <> 653  AND
         p-cdhistor <> 103  AND 
         p-cdhistor <> 555  AND
         p-cdhistor <> 503  AND
         p-cdhistor <> 486  AND 
         p-cdhistor <> 561  AND		
		 p-cdhistor <> 2553 )  THEN 
         DO:
             ASSIGN i-cod-erro  = 22
                    c-desc-erro = " ".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
    
    IF   p-valor = 0   THEN 
         DO: 
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Valor deve ser Informado".           
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
       
    IF   p-cdhistor = 103   OR /* DOC D" */
         p-cdhistor = 355   THEN /* DOC C */
         DO:
             FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper     AND
                                craptab.nmsistem = "CRED"               AND  
                                craptab.tptabela = "GENERI"             AND  
                                craptab.cdempres = 0                    AND 
                                craptab.cdacesso = "VLMAXPDOCS"         AND
                                craptab.tpregist = 0 
                                NO-LOCK NO-ERROR.
                                
             IF   NOT AVAIL craptab   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 0  
                             c-desc-erro = 
                                      "Tabela valor maximo DOC nao cadastrada".
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END. 

             IF   AVAILABLE craptab   THEN
                  DO:
                      IF   p-valor > DECIMAL(craptab.dstextab)   THEN
                           DO:
                               ASSIGN i-cod-erro  = 778
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
         END.

    ASSIGN aux_nrdconta = p-nro-conta.
    
                                                      
   /* Conta Salario  - historico 561 */
   IF  p-cdhistor = 561 THEN
       DO:
          FIND crapccs NO-LOCK WHERE
               crapccs.cdcooper = crapcop.cdcooper AND
               crapccs.nrdconta = aux_nrdconta NO-ERROR.
      
          IF   NOT  AVAIL crapccs THEN
               DO:
                  ASSIGN i-cod-erro  = 0                            
                         c-desc-erro = "Conta Salario nao Cadastrada".
                  RUN cria-erro (INPUT p-cooper,
                                 INPUT p-cod-agencia,
                                 INPUT p-nro-caixa,
                                 INPUT i-cod-erro,
                                 INPUT c-desc-erro,
                                 INPUT YES).
                  RETURN "NOK".
               END.        

          IF   crapccs.cdsitcta = 2 THEN     
               DO:
                  ASSIGN i-cod-erro  = 0                            
                         c-desc-erro = "Conta Salario Inativa".
                  RUN cria-erro (INPUT p-cooper,
                                 INPUT p-cod-agencia,
                                 INPUT p-nro-caixa,
                                 INPUT i-cod-erro,
                                 INPUT c-desc-erro,
                                 INPUT YES).
                  RETURN "NOK".
               END.        

          ASSIGN p-conta-atualiza = aux_nrdconta.
          
          RETURN "OK".
       END.
                                                    

    /* Contas Cooperados */

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
                                              INPUT  crapdat.dtmvtolt,
                                              INPUT  "b1crap56",
                                              INPUT  2, /*CAIXA*/
                                              OUTPUT TABLE tt-erro).

              DELETE PROCEDURE h-b1wgen0001.
         END.
         
         /* Verifica se houve erro */
         FIND FIRST tt-erro NO-LOCK  NO-ERROR.

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
    END.  /* DO WHILE*/
   
    IF   aux_nrtrfcta > 0   THEN    /* Transferencia de Conta */
         ASSIGN aux_nrdconta = aux_nrtrfcta.
        
    ASSIGN p-conta-atualiza = aux_nrdconta.

    IF   craphis.cdhistor = 6   THEN 
         DO: 
             IF   p-liberacao = ?   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 13  
                             c-desc-erro = " ".           
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
                      IF   p-liberacao <= crapdat.dtmvtocd      OR
                           p-liberacao > crapdat.dtmvtocd + 30  OR
                          (CAN-DO("1,7",STRING(weekday(p-liberacao))))   THEN
                           DO:
                               ASSIGN i-cod-erro  = 13  
                                      c-desc-erro = " ".           
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
                               FIND crapfer WHERE
                                    crapfer.cdcooper = crapcop.cdcooper     AND
                                    crapfer.dtferiad = p-liberacao 
                                    NO-LOCK NO-ERROR.
                                    
                               IF   AVAIL crapfer   THEN 
                                    DO:
                                        ASSIGN i-cod-erro  = 13  
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
         END. /* craphis.cdhistor = 6 */

   IF   craphis.cdhistor = 101   THEN 
         DO:
             FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper     AND
                                craplcm.nrdconta = p-conta-atualiza     AND
                                craplcm.dtmvtolt = crapdat.dtmvtocd     AND
                                craplcm.cdhistor = 26                   AND
                                craplcm.nrdocmto = p-nro-docto 
                                USE-INDEX craplcm2 NO-LOCK NO-ERROR.
                                
             IF   NOT AVAIL craplcm   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 99
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
             IF   craplcm.vllanmto <> p-valor   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 91
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.

         END. /* craphis.cdistor = 101 */

    IF   craphis.inhistor = 12   THEN  
         DO:
             FIND crapsld WHERE crapsld.cdcooper = crapcop.cdcooper     AND 
                                crapsld.nrdconta = aux_nrdconta 
                                NO-LOCK NO-ERROR.
                                
             IF   NOT AVAIL crapsld   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 10
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.

             ASSIGN aux_vlsdchsl  = crapsld.vlsdchsl.
        
             FOR EACH craplcm WHERE craplcm.cdcooper  = crapcop.cdcooper    AND
                                    craplcm.nrdconta  = crapsld.nrdconta    AND
                                    craplcm.dtmvtolt  = crapdat.dtmvtocd    AND
                                    craplcm.cdhistor <> 289 USE-INDEX craplcm2
                                    NO-LOCK:
                                    
                 FIND b-craphis WHERE b-craphis.cdcooper = crapcop.cdcooper   AND
                                      b-craphis.cdhistor = craplcm.cdhistor
                                      NO-LOCK NO-ERROR.

                 IF   NOT AVAIL b-craphis   THEN 
                      DO:
                          ASSIGN i-cod-erro  = 80
                                 c-desc-erro = " ".           
                          RUN cria-erro (INPUT p-cooper,
                                         INPUT p-cod-agencia,
                                         INPUT p-nro-caixa,
                                         INPUT i-cod-erro,
                                         INPUT c-desc-erro,
                                         INPUT YES).
                          RETURN "NOK".
                      END.
                 IF   b-craphis.inhistor = 2   THEN
                      ASSIGN aux_vlsdchsl = aux_vlsdchsl + craplcm.vllanmto.
                 ELSE
                      IF   b-craphis.inhistor = 12   THEN
                           ASSIGN  aux_vlsdchsl = aux_vlsdchsl - 
                                                  craplcm.vllanmto.
                      ELSE
                           NEXT.
             END. /* FOR EACH */
             IF   aux_vlslchsl < p-valor   THEN 
                  DO: 
                      ASSIGN i-cod-erro  = 135
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
         END.  /* craphis.inhistor = 12 */

    IF   craphis.inhistor >= 13   AND
         craphis.inhistor <= 15   THEN 
         DO:
             FIND FIRST crapdpb WHERE crapdpb.cdcooper = crapcop.cdcooper   AND 
                                      crapdpb.nrdconta = aux_nrdconta       AND
                                      crapdpb.nrdocmto = p-nro-docto        AND
                                      crapdpb.dtliblan > crapdat.dtmvtocd   AND
                                      crapdpb.inlibera  = 1  
                                      USE-INDEX crapdpb2 NO-LOCK NO-ERROR.
         
             IF   NOT AVAIL crapdpb   THEN 
                  DO: 
                      ASSIGN i-cod-erro  = 82
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
             IF   crapdpb.vllanmto <> p-valor   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 91
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
             IF   crapdpb.inlibera = 2   THEN  
                  DO:
                      ASSIGN i-cod-erro  = 220
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.

             FIND crapsld WHERE crapsld.cdcooper = crapcop.cdcooper     AND
                                crapsld.nrdconta = aux_nrdconta 
                                NO-LOCK NO-ERROR.
             IF   NOT AVAIL crapsld   THEN 
                  DO: 
                      ASSIGN i-cod-erro  = 10
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
                         
             ASSIGN aux_vlsdbloq = crapsld.vlsdbloq
                    aux_vlsdblpr = crapsld.vlsdblpr
                    aux_vlsdblfp = crapsld.vlsdblfp.

             FOR EACH craplcm WHERE craplcm.cdcooper  = crapcop.cdcooper    AND
                                    craplcm.nrdconta  = crapsld.nrdconta    AND
                                    craplcm.dtmvtolt  = crapdat.dtmvtocd    AND
                                    craplcm.cdhistor <> 289
                                    USE-INDEX craplcm2 NO-LOCK:

                 FIND b-craphis WHERE b-craphis.cdcooper = crapcop.cdcooper   AND
                                      b-craphis.cdhistor = craplcm.cdhistor 
                                      NO-LOCK NO-ERROR.

                 IF   NOT AVAIL b-craphis   THEN 
                      DO: 
                          ASSIGN i-cod-erro  = 80
                                 c-desc-erro = " ".           
                          RUN cria-erro (INPUT p-cooper,
                                         INPUT p-cod-agencia,
                                         INPUT p-nro-caixa,
                                         INPUT i-cod-erro,
                                         INPUT c-desc-erro,
                                         INPUT YES).
                          RETURN "NOK".
                      END.
            
                 IF   b-craphis.inhistor = 3   THEN
                      aux_vlsdbloq = aux_vlsdbloq  + craplcm.vllanmto.
                 ELSE
                 IF   b-craphis.inhistor = 4   THEN
                      aux_vlsdblpr = aux_vlsdblpr + craplcm.vllanmto.
                 ELSE
                 IF   b-craphis.inhistor = 5   THEN
                      aux_vlsdblfp = aux_vlsdblfp + craplcm.vllanmto.
                 ELSE
                 IF   b-craphis.inhistor = 13   THEN
                      aux_vlsdbloq = aux_vlsdbloq - craplcm.vllanmto.
                 ELSE
                 IF   b-craphis.inhistor = 14   THEN
                      aux_vlsdblpr = aux_vlsdblpr - craplcm.vllanmto.
                 ELSE
                 IF   b-craphis.inhistor = 15   THEN
                      aux_vlsdblfp = aux_vlsdblfp - craplcm.vllanmto.
                 ELSE
                      NEXT.
             END. /* FOR EACH craplcm */                       

             IF   craphis.inhistor = 13   THEN 
                  DO:
                      IF   aux_vlsdbloq < p-valor   THEN  
                           DO:
                               ASSIGN i-cod-erro  = 136
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
             IF   craphis.inhistor = 14   THEN 
                  DO: 
                      IF   aux_vlsdblpr < p-valor   THEN 
                           DO:
                               ASSIGN i-cod-erro  = 136
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
             IF   craphis.inhistor = 15   THEN 
                  DO: 
                      IF   aux_vlsdblfp < p-valor   THEN 
                           DO:
                               ASSIGN i-cod-erro  = 136
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
         END.    /* craphis.inhistor >= 13 <= 15 */
   
    IF   p-nro-docto > 0 THEN 
         DO:
             FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper     AND
                                craplcm.dtmvtolt = crapdat.dtmvtocd     AND
                                craplcm.cdagenci = p-cod-agencia        AND
                                craplcm.cdbccxlt = 11                   AND /*Fixo*/
                                craplcm.nrdolote = i-nro-lote           AND
                                craplcm.nrdctabb = aux_nrdconta         AND
                                craplcm.nrdocmto = p-nro-docto      
                                USE-INDEX craplcm1 NO-ERROR.
                                
             IF   AVAIL craplcm   THEN  
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

    IF   craphis.inautori = 1   THEN  
         DO:
             FIND crapatr WHERE crapatr.cdcooper = crapcop.cdcooper     AND
                                crapatr.nrdconta = crapass.nrdconta     AND
                                crapatr.cdhistor = craphis.cdhistor     AND
                                crapatr.cdrefere = p-nro-docto 
                                NO-LOCK NO-ERROR.
                                
             IF   NOT AVAIL crapatr   THEN 
                  DO: 
                      ASSIGN i-cod-erro  = 446
                             c-desc-erro = " ".           
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK". 
                  END.
             IF   crapatr.dtfimatr <> ?   THEN 
                  DO: 
                      ASSIGN i-cod-erro  = 447
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
    IF   craphis.inavisar = 1   THEN  
         DO:
             IF   CAN-FIND(crapavs WHERE 
                           crapavs.cdcooper = crapcop.cdcooper    AND
                           crapavs.dtmvtolt = crapdat.dtmvtocd    AND
                           crapavs.cdempres = 0                   AND
                           crapavs.cdagenci = crapass.cdagenci    AND
                           crapavs.cdsecext = crapass.cdsecext    AND
                           crapavs.nrdconta = crapass.nrdconta    AND
                           crapavs.dtdebito = crapdat.dtmvtocd    AND
                           crapavs.cdhistor = craphis.cdhistor    AND
                           crapavs.nrdocmto = p-nro-docto)        THEN  
                  DO:
                      ASSIGN i-cod-erro  = 22
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

    RETURN "OK".
END PROCEDURE.

PROCEDURE atualiza-outros:
    
    DEF INPUT  PARAM p-cooper           AS CHAR NO-UNDO.         
    DEF INPUT  PARAM p-cod-agencia      AS INT  NO-UNDO.         
    DEF INPUT  PARAM p-nro-caixa        AS INT  NO-UNDO.     
    DEF INPUT  PARAM p-cod-operador     AS CHAR NO-UNDO.
    DEF INPUT  PARAM p-cod-liberador    AS CHAR NO-UNDO.
    DEF INPUT  PARAM p-nro-conta        AS INT  NO-UNDO.    
    DEF INPUT  PARAM p-cdhistor         AS INT  NO-UNDO.      
    DEF INPUT  PARAM p-nro-docto        AS INT  NO-UNDO.
    DEF INPUT  PARAM p-valor            AS DEC  NO-UNDO.
    DEF INPUT  PARAM p-dtliblan         AS DATE NO-UNDO.
    DEF INPUT  PARAM p-conta-atualiza   AS INT  NO-UNDO.
 
    DEF INPUT  PARAM p-complem1         AS CHAR NO-UNDO.
    DEF INPUT  PARAM p-complem2         AS CHAR NO-UNDO.
    DEF INPUT  PARAM p-complem3         AS CHAR NO-UNDO.
    DEF OUTPUT PARAM p-pg               AS LOG  NO-UNDO.
    DEF OUTPUT PARAM p-literal-r        AS CHAR NO-UNDO.
    DEF OUTPUT PARAM p-ult-sequencia-r  AS INT  NO-UNDO.
  
    DEFINE  VARIABLE c-nome-titular1    AS CHAR NO-UNDO.
    DEFINE  VARIABLE c-nome-titular2    AS CHAR NO-UNDO.
    DEFINE  VARIABLE i                  AS INTE NO-UNDO.
    DEFINE  VARIABLE aux_nrseqdig       AS INTE NO-UNDO.
 
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
     
     
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    IF  p-cdhistor = 561 THEN /* Cheque Salario */
        ASSIGN i-nro-lote  = 26000 + p-nro-caixa 
               i-tipo-lote = 32.
    ELSE
        ASSIGN i-nro-lote = 11000 + p-nro-caixa 
               i-tipo-lote = 1.
  
    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.

    ASSIGN c-docto-salvo = STRING(TIME).
    IF   p-nro-docto = 0   THEN
         ASSIGN i-nro-docto = INTE(c-docto-salvo).
    ELSE
         ASSIGN i-nro-docto = p-nro-docto.

    ASSIGN p-nro-docto = i-nro-docto.

    ASSIGN aux_nrdconta = p-conta-atualiza.
    
    FIND craphis WHERE craphis.cdcooper = crapcop.cdcooper   AND
                       craphis.cdhistor = p-cdhistor
                       NO-LOCK NO-ERROR.

    IF    NOT AVAIL craphis   THEN 
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

    IF  p-cdhistor <> 561 THEN
        DO:
           FIND crapass WHERE
                crapass.cdcooper = crapcop.cdcooper  AND
                crapass.nrdconta = aux_nrdconta      NO-LOCK NO-ERROR.
                       
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
        END.

    IF  p-cdhistor = 561 THEN
        DO:
            /* Conta Salario  - historico 561 */
            FIND crapccs NO-LOCK WHERE
                 crapccs.cdcooper = crapcop.cdcooper AND
                 crapccs.nrdconta = aux_nrdconta NO-ERROR.
            IF   NOT  AVAIL crapccs THEN
                 DO:
                    ASSIGN i-cod-erro  = 0                            
                           c-desc-erro = "Conta Salario nao Cadastrada".
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                 END.        
        END.
 
    FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                       craplot.dtmvtolt = crapdat.dtmvtocd  AND
                       craplot.cdagenci = p-cod-agencia     AND
                       craplot.cdbccxlt = 11                AND  /* Fixo */
                       craplot.nrdolote = i-nro-lote 
                       EXCLUSIVE-LOCK NO-ERROR.
                       
    IF   NOT AVAIL craplot   THEN 
         DO:
             CREATE craplot.
             ASSIGN craplot.cdcooper = crapcop.cdcooper
                    craplot.dtmvtolt = crapdat.dtmvtocd
                    craplot.cdagenci = p-cod-agencia   
                    craplot.cdbccxlt = 11              
                    craplot.nrdolote = i-nro-lote
                    craplot.tplotmov = i-tipo-lote
                    craplot.cdoperad = p-cod-operador
                    craplot.cdhistor = 0 /* p-cdhistor  */
                    craplot.nrdcaixa = p-nro-caixa
                    craplot.cdopecxa = p-cod-operador.
         END.   
   

    IF   craphis.inautori = 1   THEN 
         DO:
             ASSIGN in99 = 0.
             DO   WHILE TRUE:
                  ASSIGN in99 = in99 + 1.
                  FIND crapatr WHERE crapatr.cdcooper = crapcop.cdcooper    AND
                                     crapatr.nrdconta = crapass.nrdconta    AND
                                     crapatr.cdhistor = craphis.cdhistor    AND
                                     crapatr.cdrefere = p-nro-docto    
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                     
                  IF   NOT AVAIL crapatr   THEN  
                       DO:
                           IF   LOCKED crapatr  THEN 
                                DO:
                                    IF   in99 <  100   THEN 
                                         DO:
                                             PAUSE 1 NO-MESSAGE.
                                             NEXT.
                                         END.
                                    ELSE 
                                         DO:
                                             ASSIGN i-cod-erro  = 0
                                                    c-desc-erro = 
                                                     "Tabela CRAPATR em uso ". 
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
                                    ASSIGN i-cod-erro  = 446
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
                  LEAVE.
             END. /* DO WHILE*/

             IF  (MONTH(crapatr.dtultdeb) <> MONTH(crapdat.dtmvtocd)    OR
                 (YEAR(crapatr.dtultdeb) <> YEAR(crapdat.dtmvtocd)))   THEN
                     ASSIGN crapatr.dtultdeb = crapdat.dtmvtocd.

             RELEASE crapatr.

         END. /* craphis.inautori = 1 */

    IF   craphis.inavisar = 1   THEN  
         DO:
             /* Revitalizacao - Remocao de lotes */
             IF p-cdhistor <> 561 THEN
             DO:
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                /* Busca a proxima sequencia do campo CRAPLOT.NRSEQDIG */
                RUN STORED-PROCEDURE pc_sequence_progress
                aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPLOT"
                                  ,INPUT "NRSEQDIG"
                                  ,STRING(crapcop.cdcooper) + ";" + STRING(crapdat.dtmvtocd,"99/99/9999") + ";" + STRING(p-cod-agencia) + ";11;" + STRING(i-nro-lote)
                                  ,INPUT "N"
                                  ,"").

                CLOSE STORED-PROC pc_sequence_progress
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                ASSIGN aux_nrseqdig = INTE(pc_sequence_progress.pr_sequence)
                            WHEN pc_sequence_progress.pr_sequence <> ?.
             END.
      
             CREATE crapavs.
             ASSIGN crapavs.cdcooper = crapcop.cdcooper
                    crapavs.cdagenci = crapass.cdagenci
                    crapavs.cdempres = 0
                    crapavs.cdhistor = craphis.cdhistor
                    crapavs.cdsecext = crapass.cdsecext
                    crapavs.dtdebito = crapdat.dtmvtocd
                    crapavs.dtmvtolt = crapdat.dtmvtocd
                    crapavs.dtrefere = crapdat.dtmvtocd
                    crapavs.insitavs = 0
                    crapavs.nrdconta = crapass.nrdconta
                    crapavs.nrdocmto = p-nro-docto
                    crapavs.nrseqdig = (IF p-cdhistor = 561 THEN craplot.nrseqdig + 1 ELSE aux_nrseqdig)
                    crapavs.tpdaviso = 2
                    crapavs.vldebito = 0
                    crapavs.vlestdif = 0
                    crapavs.vllanmto = p-valor
                    crapavs.flgproce = false.
             VALIDATE crapavs.

         END.  /* craphis.inavisar */
                                  
    ASSIGN aux_nrdconta1 = p-nro-conta.
    
    /* Contas cooperados */
    IF  p-cdhistor <> 561 THEN
        DO:
    
           /* Formata conta integracao */
           RUN fontes/digbbx.p (INPUT  aux_nrdconta,
                                OUTPUT glb_dsdctitg,
                                OUTPUT glb_stsnrcal).

          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

            /* Busca a proxima sequencia do campo CRAPLOT.NRSEQDIG */
            RUN STORED-PROCEDURE pc_sequence_progress
            aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPLOT"
                              ,INPUT "NRSEQDIG"
                              ,STRING(crapcop.cdcooper) + ";" + STRING(crapdat.dtmvtocd,"99/99/9999") + ";" + STRING(p-cod-agencia) + ";11;" + STRING(i-nro-lote)
                              ,INPUT "N"
                              ,"").

            CLOSE STORED-PROC pc_sequence_progress
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

            ASSIGN aux_nrseqdig = INTE(pc_sequence_progress.pr_sequence)
                        WHEN pc_sequence_progress.pr_sequence <> ?.
          
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
            ,INPUT p-nro-docto                    /* par_nrdocmto */
            ,INPUT p-cdhistor                     /* par_cdhistor */
            ,INPUT aux_nrseqdig                   /* par_nrseqdig */
            ,INPUT p-valor                        /* par_vllanmto */
            ,INPUT aux_nrdconta                   /* par_nrdctabb */
            ,INPUT "CRAP056," + p-cod-liberador   /* par_cdpesqbb */
            ,INPUT 0                              /* par_vldoipmf */
            ,INPUT 0                              /* par_nrautdoc */
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
            ,INPUT 0                              /* par_dsidenti */
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
              
           FIND FIRST tt-ret-lancto NO-LOCK NO-ERROR.

           FIND FIRST craplcm
                WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm
              EXCLUSIVE-LOCK NO-ERROR.
              
              
            IF  VALID-HANDLE(h-b1wgen0200) THEN
                DELETE PROCEDURE h-b1wgen0200.
           
           IF   craphis.indebcre = "D" THEN 
                ASSIGN p-pg              = YES.
           ELSE
                ASSIGN p-pg              = NO.

           IF   craphis.inhistor >= 13   AND
                craphis.inhistor <= 15   THEN 
                DO:
                     FIND FIRST crapdpb WHERE
                                crapdpb.cdcooper = crapcop.cdcooper   AND
                                crapdpb.nrdconta = aux_nrdconta       AND
                                crapdpb.nrdocmto = p-nro-docto        AND
                                crapdpb.dtliblan > crapdat.dtmvtolt   AND
                                crapdpb.inlibera = 1  
                                USE-INDEX crapdpb2 
                                EXCLUSIVE-LOCK NO-ERROR.
                     IF   NOT AVAIL crapdpb   THEN  
                          DO:
                              ASSIGN i-cod-erro  = 82
                                     c-desc-erro = " ".           
                              RUN cria-erro (INPUT p-cooper,
                                             INPUT p-cod-agencia,
                                             INPUT p-nro-caixa,
                                             INPUT i-cod-erro,
                                             INPUT c-desc-erro,
                                             INPUT YES).
                              RETURN "NOK".
                          END.
                     ASSIGN crapdpb.inlibera = 2.
                     RELEASE crapdpb.
                END.
           ELSE 
                DO:
                   IF   CAN-DO("3,4,5",STRING(craphis.inhistor))   THEN 
                        DO:
                           CREATE crapdpb.
                           ASSIGN 
                             crapdpb.cdcooper = crapcop.cdcooper
                             crapdpb.nrdconta = aux_nrdconta
                             crapdpb.dtliblan = p-dtliblan
                             crapdpb.cdhistor = p-cdhistor
                             crapdpb.nrdocmto = p-nro-docto
                             crapdpb.dtmvtolt = crapdat.dtmvtocd
                             crapdpb.cdagenci = p-cod-agencia
                             crapdpb.cdbccxlt = 11     /* Fixo */
                             crapdpb.nrdolote = i-nro-lote
                             crapdpb.vllanmto = p-valor
                             crapdpb.inlibera = 1.
                        END.
                        RELEASE crapdpb.
                END.
        END.


    /* Contas Salarios */
    IF  p-cdhistor = 561 THEN
        DO:

          
           CREATE craplcs.
           ASSIGN craplcs.cdcooper = crapcop.cdcooper
                  craplcs.dtmvtolt = crapdat.dtmvtocd
                  craplcs.nrdolote = i-nro-lote
                  craplcs.nrdconta = aux_nrdconta
                  craplcs.nrdocmto = p-nro-docto
                  craplcs.vllanmto = p-valor
                  craplcs.cdhistor = p-cdhistor
                  craplcs.cdbccxlt = 11
                  craplcs.cdagenci = p-cod-agencia
                  craplcs.cdopecrd = p-cod-operador.

           ASSIGN craplot.nrseqdig  = craplot.nrseqdig + 1 
                  craplot.qtcompln  = craplot.qtcompln + 1
                  craplot.qtinfoln  = craplot.qtinfoln + 1 
                  craplot.vlcompcr  = craplot.vlcompcr + p-valor
                  craplot.vlinfocr  = craplot.vlinfocr + p-valor
                  p-pg              = NO.
        
        END.
    

    RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
    RUN grava-autenticacao  IN h-b1crap00 (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT p-nro-caixa,
                                           INPUT p-cod-operador,
                                           INPUT DEC(p-valor),
                                           INPUT DEC(p-nro-docto), 
                                           INPUT p-pg, /* YES (PG), NO (REC) */
                                           INPUT "1",  /* On-line            */
                                           INPUT NO,   /* Nao estorno        */
                                           INPUT p-cdhistor, 
                                           INPUT ?, /* Data off-line */
                                           INPUT 0, /* Sequencia off-line */
                                           INPUT 0, /* Hora off-line */
                                           INPUT 0, /* Seq.orig.Off-line */
                                           OUTPUT p-literal,
                                           OUTPUT p-ult-sequencia,
                                           OUTPUT p-registro).
    DELETE PROCEDURE h-b1crap00.
    
    IF   RETURN-VALUE = "NOK"   THEN
         RETURN "NOK".
  
    /* Atualiza sequencia Autenticacao */
    IF  p-cdhistor <> 561 THEN
        ASSIGN craplcm.nrautdoc = p-ult-sequencia. 
    ELSE
        ASSIGN craplcs.nrautdoc = p-ult-sequencia.    

    ASSIGN p-ult-sequencia-r = p-ult-sequencia
           c-literal = p-literal.

    FIND crapope WHERE crapope.cdcooper = crapcop.cdcooper    AND
                       crapope.cdoperad = p-cod-operador 
                       NO-LOCK NO-ERROR.

    IF   AVAIL crapope THEN
         ASSIGN c-nome-operador = crapope.nmoperad.
 
    /* Qdo historico = 5/561  emitir um comprovante ao invés da autenticacao*/

    IF   p-cdhistor = 5   OR            
         p-cdhistor = 355 OR
         p-cdhistor = 612 OR
         p-cdhistor = 135 OR
         p-cdhistor = 653 OR
         p-cdhistor = 103 OR
         p-cdhistor = 555 OR
         p-cdhistor = 503 OR
         p-cdhistor = 486 OR    
         p-cdhistor = 561 OR
		 p-cdhistor = 2553 THEN 
         DO:
             ASSIGN c-nome-titular1 = " "
                    c-nome-titular2 = " ".
               
             IF  p-cdhistor <> 561 THEN 
                 DO:
                    FIND crapass WHERE
                         crapass.cdcooper = crapcop.cdcooper     AND
                         crapass.nrdconta = p-nro-conta 
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

                 END.
             ELSE  
                 DO:
                    FIND crapccs WHERE
                         crapccs.cdcooper = crapcop.cdcooper     AND
                         crapccs.nrdconta = p-nro-conta 
                         NO-LOCK NO-ERROR.

                    IF   AVAIL crapccs   THEN
                         ASSIGN c-nome-titular1 = crapccs.nmfuncio
                                c-nome-titular2 = " ".                  
                 END.
                  
             ASSIGN c-literal-compr[01] = TRIM(crapcop.nmrescop) +  " - " +
                                          TRIM(crapcop.nmextcop) 
                    c-literal-compr[02] = " "
                    c-literal-compr[03] = STRING(crapdat.dtmvtocd,"99/99/99")
                                          + " " + STRING(TIME,"HH:MM:SS") +
                                          " PA  " + 
                                          STRING(p-cod-agencia,"999") +
                                          "  CAIXA: " +
                                          STRING(p-nro-caixa,"Z99") + "/" +
                                          SUBSTR(p-cod-operador,1,10)
                    c-literal-compr[04]  = " ".
               
             IF   p-cdhistor = 5  OR   
                  p-cdhistor = 561 THEN
                  DO:
                      ASSIGN c-literal-compr[05]  = 
                                      "      ** COMPROVANTE DE DEPOSITO " + 
                                      STRING(p-nro-docto,"zzz,zz9") + " **"
                             c-literal-compr[06]  = " ".
                             c-literal-compr[07] = "CONTA...: " + 
                                      TRIM(STRING(p-nro-conta,"zzzz,zz9,9")). 
                       IF    p-cdhistor = 5 THEN
                             c-literal-compr[07] = c-literal-compr[07] + 
                                   "   PA:  " + TRIM(STRING(crapass.cdagenci)).
                       ELSE
                             c-literal-compr[07] = c-literal-compr[07] +  
                                   "   PA:  " + TRIM(STRING(crapccs.cdagenci)).
                       
                       ASSIGN               
                             c-literal-compr[08] = "       " + 
                                                   TRIM(c-nome-titular1)
                             c-literal-compr[09] = "       " + 
                                                   TRIM(c-nome-titular2)
                             c-literal-compr[10] = " "
                             c-literal-compr[11] =
                              "   TIPO DE DEPOSITO     VALOR EM R$ LIBERACAO EM"
                             c-literal-compr[12] = FILL('-', 48).
                       IF    p-cdhistor = 5 THEN     
                             c-literal-compr[13] = "         CR. CONTA: " + 
                                              STRING(p-valor,"ZZZ,ZZZ,ZZ9.99").
                       ELSE      
                             c-literal-compr[13] = "      SAL. LIQUIDO: " + 
                                              STRING(p-valor,"ZZZ,ZZZ,ZZ9.99").
                            
                       ASSIGN
                             c-literal-compr[14] = " "

                             c-literal-compr[15] = "  TOTAL DEPOSITADO: " + 
                                               STRING(p-valor,"ZZZ,ZZZ,ZZ9.99")
                             c-literal-compr[16] = " "
                             c-literal-compr[17] = p-literal
                             c-literal-compr[18] = " "
                             c-literal-compr[19] = " "
                             c-literal-compr[20] = " "
                             c-literal-compr[21] = " "
                             c-literal-compr[22] = " "
                             c-literal-compr[23] = " "
                             c-literal-compr[24] = " "
                             c-literal-compr[25] = " "
                             c-literal-compr[26] = " "
                             c-literal-compr[27] = " "
                             p-literal = "".
                      DO  i = 1 TO 27:
                          ASSIGN p-literal = p-literal + 
                                             STRING(c-literal-compr[i],"x(48)").
                      END.
                  END.
             ELSE
                  DO:
                      ASSIGN c-literal-compr[05]  = "      ** COMPROVANTE  " + 
                                          STRING(p-nro-docto,"zzz,zz9") + " **"
                             c-literal-compr[06]  = " "
                             c-literal-compr[07] = "CONTA...: " + 
                                        TRIM(STRING(p-nro-conta,"zzzz,zz9,9"))+
                                        "   PA:  " + 
                                        TRIM(STRING(crapass.cdagenci))
                             
                             c-literal-compr[08] = "       " + 
                                                  TRIM(c-nome-titular1)
                             c-literal-compr[09] = "       " + 
                                                  TRIM(c-nome-titular2)
                             c-literal-compr[10] = " "
                             c-literal-compr[11] =
                             "   TIPO DE DEBITO                   VALOR EM R$ "
                             c-literal-compr[12] = FILL('-', 48)
                             c-literal-compr[13] = "    " + 
                                STRING(SUBSTR(craphis.dshistor,1,29),"x(29)") +
                                       STRING(p-valor,"ZZZ,ZZZ,ZZ9.99")
                             c-literal-compr[14] = " "
                             p-literal = "".
                      DO i = 1 TO 14:
                         ASSIGN p-literal = p-literal + 
                                            STRING(c-literal-compr[i],"x(48)").
                      END.
              
                      IF   p-complem1 <> ""   THEN
                           ASSIGN p-literal = p-literal + 
                                              STRING(p-complem1,"x(48)").
                      IF   p-complem2 <> ""   THEN
                           ASSIGN p-literal = p-literal + 
                                              STRING(p-complem2,"x(48)").
                      IF   p-complem3 <> ""   THEN
                           ASSIGN p-literal = p-literal + 
                                              STRING(p-complem3,"x(48)").
               
                      ASSIGN c-literal-compr[19] =
                                         "    TOTAL DEBITADO:              " + 
                                         STRING(p-valor,"ZZZ,ZZZ,ZZ9.99")
                             c-literal-compr[20] = " "
                             c-literal-compr[21] = 
                              "_______________________________________________"
                             c-literal-compr[22] = "ASSINATURA"
                             c-literal-compr[23] = " "
                             c-literal-compr[24] = c-literal
                             c-literal-compr[25] = " "
                             c-literal-compr[26] = " "
                             c-literal-compr[27] = " "  
                             c-literal-compr[28] = " "
                             c-literal-compr[29] = " "  
                             c-literal-compr[30] = " "
                             c-literal-compr[31] = " " 
                             c-literal-compr[32] = " ".
   
                      DO i = 20 TO 32:
                         ASSIGN p-literal = p-literal + 
                                            STRING(c-literal-compr[i],"x(48)").
                      END.

                  END.

             ASSIGN in99 = 0. 
             DO   WHILE TRUE:
                  ASSIGN in99 = in99 + 1.
                  FIND crapaut WHERE RECID(crapaut) = p-registro 
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF   NOT AVAIL crapaut   THEN  
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
                                                      "Tabela CRAPAUT em uso ".                                             RUN cria-erro (INPUT p-cooper,
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
                                    ASSIGN i-cod-erro  = 0
                                           c-desc-erro = 
                                      "Erro Sistema - CRAPAUT nao Encontrado ".
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
                           ASSIGN  crapaut.dslitera = p-literal.
                           RELEASE crapaut.
                           LEAVE.
                       END.
             END.
         END.

    ASSIGN p-literal-r       = p-literal.

    RELEASE craplcm.
    RELEASE craplot.
    
    RELEASE craplcs.
    RETURN "OK".
END PROCEDURE.

PROCEDURE valida-saldo-conta:
    
    DEF INPUT  PARAM p-cooper           AS CHAR NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia      AS INTE NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa        AS INTE NO-UNDO.
    DEF INPUT  PARAM p-nro-conta        AS DEC  NO-UNDO.
    DEF INPUT  PARAM p-valor            AS DEC  NO-UNDO.
    DEF INPUT  PARAM p-cod-rotina       AS INT  NO-UNDO.
    DEF INPUT  PARAM p-coopdest         AS CHAR NO-UNDO. 
    DEF OUTPUT PARAM p-mensagem         AS CHAR NO-UNDO.
    DEF OUTPUT PARAM p-valor-disponivel AS DEC  NO-UNDO.
  
    DEF VAR          h-b1crap22         AS HANDLE NO-UNDO.
    DEF VAR          h-b1crap20         AS HANDLE NO-UNDO.
    DEF VAR          aux_vltarifa       AS DECI   NO-UNDO.
    DEF VAR          aux_cdhistor       AS INTE   NO-UNDO.
    DEF VAR          aux_cdhisest       AS INTE   NO-UNDO.
    DEF VAR          aux_cdfvlcop       AS INTE   NO-UNDO.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
 
    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.
      
    ASSIGN p-nro-conta = DEC(REPLACE(STRING(p-nro-conta),".",""))
           aux_nrdconta = p-nro-conta.
   
    /* Conta Salario  - historico 561 */
    FIND crapccs NO-LOCK WHERE
         crapccs.cdcooper = crapcop.cdcooper AND
         crapccs.nrdconta = aux_nrdconta NO-ERROR.
    IF  AVAIL crapccs THEN
        RETURN "OK".
    
    /* Contas Cooperados */    
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
		 IF   crapass.cdsitdct = 4 THEN 
              DO:
                  ASSIGN i-cod-erro  = 723
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
                           ASSIGN i-cod-erro  = 95 /* Titular Cta Bloqueado */
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
                                              INPUT  crapdat.dtmvtolt,
                                              INPUT  "b1crap56",
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
    END.  /* DO WHILE */

    ASSIGN p-mensagem         = " "
           p-valor-disponivel = 0.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
   
    RUN dbo/b1crap02.p PERSISTENT SET h-b1crap02.
                                         
    RUN  consulta-conta IN h-b1crap02(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT aux_nrdconta,
                                      OUTPUT TABLE tt-conta).
    DELETE PROCEDURE h-b1crap02.

    IF   RETURN-VALUE = "NOK"   THEN   
         RETURN "NOK".                    

    ASSIGN de-valor-libera = 0.
    FIND FIRST tt-conta NO-LOCK NO-ERROR.
    IF   AVAIL tt-conta   THEN  
         DO:
             ASSIGN de-valor-bloqueado = tt-conta.bloqueado +
                                         tt-conta.bloq-praca +
                                         tt-conta.bloq-fora-praca
                    de-valor-liberado  = tt-conta.acerto-conta -
                                         de-valor-bloqueado
                    p-valor-disponivel = de-valor-liberado + 
                                         tt-conta.limite-credito.
             
             /* Valor a movimentar nao disponivel */                           
             IF  de-valor-liberado  + tt-conta.limite-credito < p-valor THEN
                 DO:
                     ASSIGN p-valor-disponivel = 0
                            p-valor-disponivel = de-valor-liberado + 
                                                 tt-conta.limite-credito
                            de-valor-libera    = (de-valor-liberado - 
                                                 p-valor) * -1.
                     ASSIGN p-mensagem = "Saldo " +
                                         TRIM(STRING(de-valor-liberado,
                                         "zzz,zzz,zzz,zz9.99-")) + " Limite " +
                                         TRIM(STRING(tt-conta.limite-credito,
                                         "zzz,zzz,zzz,zz9.99-")) +
                                         " Excedido " + 
                                         TRIM(STRING(de-valor-libera,
                                         "zzz,zzz,zzz,zz9.99-")) + " Bloq. " + 
                                         TRIM(STRING(de-valor-bloqueado,
                                         "zzz,zzz,zzz,zz9.99-")).
                 END.
             ELSE 
                 DO: 
                     IF  p-cod-rotina = 20  THEN  /* DOC/TED */
                         DO:
                          
                             RUN dbo/b1crap20.p PERSISTENT SET h-b1crap20.

                             RUN busca-tarifa-ted IN h-b1crap20
                                 (INPUT crapcop.cdcooper,
                                  INPUT p-cod-agencia,
                                  INPUT aux_nrdconta,
                                  INPUT 1,              /* vllanmto */
                                  OUTPUT aux_vltarifa,
                                  OUTPUT aux_cdhistor,
                                  OUTPUT aux_cdhisest,
                                  OUTPUT aux_cdfvlcop,
                                  OUTPUT p-mensagem).

                             DELETE PROCEDURE h-b1crap20.

                             /* Valor a movimentar + tarifa nao disponivel */
                             IF  (de-valor-liberado + tt-conta.limite-credito) <
                                 (p-valor           + aux_vltarifa)      THEN
                                  DO:
                                     ASSIGN p-mensagem = 
                                                 "Saldo insuficiente para " +
                                                 "cobranca da tarifa.".
                                  END.
                         END.
                     ELSE
                         IF  p-cod-rotina = 22 THEN /* Transf. entre cooperativas */
                             DO: /** Faz verificacao se coop. origem <> coop.dest **/
                                    IF  p-cooper <> p-coopdest THEN 
                                        DO:
                                            RUN dbo/b1crap22.p PERSISTENT SET h-b1crap22.

                                            RUN tarifa-transf-intercooperativa IN h-b1crap22 
                                                  (INPUT crapcop.cdcooper,
                                                   INPUT p-cod-agencia,
                                                   INPUT aux_nrdconta,
                                                   INPUT p-valor,
                                                  OUTPUT aux_vltarifa,
                                                  OUTPUT aux_cdhistor,
                                                  OUTPUT aux_cdhisest,
                                                  OUTPUT aux_cdfvlcop,
                                                  OUTPUT p-mensagem).

                                            DELETE PROCEDURE h-b1crap22.
                                            
                                            /* Valor a movimentar + tarifa nao disponivel */
                                            IF  RETURN-VALUE = "OK"  AND
                                               (de-valor-liberado + tt-conta.limite-credito) <
                                               (p-valor           + aux_vltarifa)      THEN
                                                ASSIGN p-mensagem = "Saldo insuficiente para " +
                                                                    "cobranca da tarifa.".
                                        END.
                             END.
                 END.
         END.    
               
    RETURN "OK".

END PROCEDURE.


PROCEDURE valida-permissao-saldo-conta:

    DEFINE INPUT  PARAMETER p-cooper        AS CHAR         NO-UNDO.
    DEFINE INPUT  PARAMETER p-cdhistor      AS INTEGER      NO-UNDO.
    DEFINE INPUT  PARAMETER p-cod-agencia   AS INTEGER      NO-UNDO.
    DEFINE INPUT  PARAMETER p-nro-caixa     AS INTEGER      NO-UNDO.
    DEFINE INPUT  PARAMETER p-valor         AS DECIMAL      NO-UNDO.
    DEFINE INPUT  PARAMETER p-cod-operador  AS CHARACTER    NO-UNDO.
    DEFINE INPUT  PARAMETER p-codigo        AS CHARACTER    NO-UNDO.
    DEFINE INPUT  PARAMETER p-senha         AS CHARACTER    NO-UNDO.
    DEFINE INPUT  PARAMETER p-disponivel    AS DECIMAL      NO-UNDO.
    DEFINE INPUT  PARAMETER p-mensagem      AS CHARACTER    NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia, 
                      INPUT p-nro-caixa).

    FIND craphis WHERE craphis.cdcooper = crapcop.cdcooper   AND
                       craphis.cdhistor = p-cdhistor
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craphis   THEN
         RETURN 'NOK':U.

    IF   craphis.indebcre = 'D'   THEN 
         DO:
             ASSIGN de-valor-libera =  (p-disponivel - p-valor) * -1.

             IF   p-codigo = "  "   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 0
                             c-desc-erro = "Informe Codigo/Senha ".
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.

             FIND crapope WHERE crapope.cdcooper = crapcop.cdcooper   AND
                                crapope.cdoperad = p-codigo 
                                NO-LOCK NO-ERROR.

             IF   NOT AVAIL crapope   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 67
                             c-desc-erro = " ".
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.

          /* PRJ339 - REINERT (INICIO) */         
             /* Validacao de senha do usuario no AD somente no ambiente de producao */
             IF TRIM(OS-GETENV("PKGNAME")) = "pkgprod" THEN                
                  DO:
                  
                   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                   /* Efetuar a chamada da rotina Oracle */ 
                   RUN STORED-PROCEDURE pc_valida_senha_AD
                       aux_handproc = PROC-HANDLE NO-ERROR(INPUT crapcop.cdcooper, /*Cooperativa*/
                                                           INPUT p-codigo,         /*Operador   */
                                                           INPUT p-senha,          /*Nr.da Senha*/
                                                          OUTPUT 0,                /*Cod. critica */
                                                          OUTPUT "").              /*Desc. critica*/

                   /* Fechar o procedimento para buscarmos o resultado */ 
                   CLOSE STORED-PROC pc_valida_senha_AD
                          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

                   HIDE MESSAGE NO-PAUSE.

                   /* Busca possíveis erros */ 
                   ASSIGN i-cod-erro  = 0
                          c-desc-erro = ""
                          i-cod-erro  = pc_valida_senha_AD.pr_cdcritic 
                                        WHEN pc_valida_senha_AD.pr_cdcritic <> ?
                          c-desc-erro = pc_valida_senha_AD.pr_dscritic 
                                        WHEN pc_valida_senha_AD.pr_dscritic <> ?.
                                        
                  /* Apresenta a crítica */
                  IF  i-cod-erro <> 0 OR c-desc-erro <> "" THEN
                  DO:
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                         INPUT "",
                                     INPUT YES).
                      RETURN "NOK".
                  END.
                END.
          /* PRJ339 - REINERT (FIM) */
        
             IF   crapope.vlpagchq < de-valor-libera   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 0
                             c-desc-erro = "Sem Permissao p/Liberacao " +
                                           STRING(de-valor-libera).
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.  /* p-mensagem <> " " */
         END.

    RETURN "OK".
END PROCEDURE.

/* b1crap56.p */

/* .......................................................................... */

 

