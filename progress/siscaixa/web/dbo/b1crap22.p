/********************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +-----------------------------------+---------------------------------------+
  | Rotina Progress                   | Rotina Oracle PLSQL                   |
  +-----------------------------------+---------------------------------------+
  | dbo/b1crap22.p                    | CXON0022                              |
  |  realiza-transferencia            | CXON0022.pc_realiza_transferencia     |
  |  gera-log                         | CXON0022.pc_gera_log                  |
  |  tarifa-transf-intercooperativa   | TARI0001.pc_busca_tar_transf_intercoop|
  +-----------------------------------+---------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/*-----------------------------------------------------------------------------
* .............................................................................

   Programa: siscaixa/web/dbo/b1crap22.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Elton
   Data    : Outubro/2011                      Ultima atualizacao: 14/11/2018

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Transferencia e deposito entre cooperativas.

   Alteracoes: 15/12/2011 - Retirado comentarios (Elton).
   
               12/04/2013 - Transferencia intercooperativa (Gabriel). 
               
               11/07/2013   Alteraçoes na procedure realiza-transferencia:
                          - Tratado undo de transaçao para chamada da procedure
                            grava-autenticacao-internet.
                          - Campo craplcm.hrtransa alimentado com TIME (Lucas).
   
               14/10/2013 - Incluido parametro cdprogra nas procedures da
                            b1wgen0153 que carregam dados da tarifa(Tiago).
                            
               16/12/2013 - Adicionado validate para as tabelas craplcx,
                            craplot, craplcm, crapldt (Tiago).          
                            
               21/03/2014 - Retirar FIND FIRST desnecessarios (Gabriel)
               
               12/06/2014 - Troca do campos crapass pela crapttl
                            (Tiago Castro - RKAM).
                            
               13/06/2014 - Transferencia e deposito de cheques entre
                            cooperativas. Conversao das procedures
                            realiza-deposito-cheque,
                            realiza-deposito-cheque-migrado,
                            realiza-deposito-cheque-migrado-host para
                            pc_realiza_dep_cheq,
                            pc_realiz_dep_cheque_mig
                            pc_realiz_dep_chq_mig_host
                            Ajustando a gravacao do log para gravar o
                            PA do caixa em vez de gravar ZERO na procedure
                            realiza-deposito (Andre Santos - SUPERO)
                            
               17/11/2014 - Atribuir craplcm.cdagenci = 1 no deposito de 
                            dinheiro intercooperativa (Diego).
                            
               03/12/2014 - Tratamento para evitar repetição de nr.Docmto
                            quando forem realizados 2 depósitos de envelopes seguido
                            (Lucas Lunelli SD. 227937)
                            
               05/01/2015 - Ajustes na rotina realiza-deposito:
                            - Criado controle de transacao
                            - Fixado cdagenci na leitura da craplcm pois
                              nao encontrava o registro e consequentemente
                              nao entrava no if para incrementar o numero do 
                              documento. Desta forma, gera um registro na 
                              craplcm com chave duplicada.
                            (Adriano SD - 237890).
               
               21/01/2015 - Conversão da fn_sequence para procedure para não
                            gerar cursores abertos no Oracle. (Dionathan)
                               
               03/08/2015 - Ajuste para retirar o caminho absoluto na chamada
                            dos fontes
                            (Adriano - SD 314469).
                            
               06/08/2015 - Incluir regra para evitar que sejam efetivadas
                            2 transferencias iguais enviadas pelo ambiente 
                            mobile (David).                            
               
               26/08/2015 - Alterado parametro pr_pesqbb da procedure 
                            lan-tarifa-online da b1wgen0153 (Jean Michel).
                            
               16/03/2016 - Tratamentos para utilizaçao do Cartao CECRED e 
                             PinPad Novo (Lucas Lunelli - [PROJ290])
                            
               22/03/2016 - Ajuste na mensagem de alerta que identifica transferencias duplicadas
                            conforme solicitado no chamado 421403. (Kelvin)                            
                            
               26/04/2016 - Inclusao dos horarios de SAC e OUVIDORIA nos
                            comprovantes, melhoria 112 (Tiago/Elton)              

               17/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
                            crapass, crapttl, crapjur (Adriano - P339).

               12/12/2017 - Passar como texto o campo nrcartao na chamada da procedure 
                            pc_gera_log_ope_cartao (Lucas Ranghetti #810576) 

               07/06/2018 - Alterado a inclusao na CRAPLCM para a Centralizadora de 
                            Lançamentos de Conta Corrente - PRJ450 - Diego Simas - AMcom  
							
			   09/11/2018 - Incluso a validaçao referente a conta salário para nao permitir recebimento
                            de crédito de CNPJ diferente ao do empregador. (P485 - Augusto SUPERO)				    

			   14/11/2018 - Remoção de comandos MESSAGE deixados no código após testes
			                Reginaldo/AMcom/P450 
                      
               16/01/2019 - Revitalizacao (Remocao de lotes) - Pagamentos, Transferencias, Poupanca
                     Heitor (Mouts)
                           
               27/02/2019 - Realizar atribuicao do historico 1014 na variavel para geracao de LOG.
                            INC0031856 - Heitor (Mouts)
                           
-----------------------------------------------------------------------------*/

{dbo/bo-erro1.i}
{ sistema/generico/includes/b1wgen0200tt.i }

DEF  VAR glb_nrcalcul        AS DECIMAL                             NO-UNDO.
DEF  VAR glb_dsdctitg        AS CHAR                                NO-UNDO.
DEF  VAR glb_stsnrcal        AS LOGICAL                             NO-UNDO.
DEF VAR h-b1wgen0200         AS HANDLE                              NO-UNDO.
DEF VAR aux_incrineg         AS INT                                 NO-UNDO.
DEF VAR aux_cdcritic         AS INT                                 NO-UNDO.
DEF VAR aux_dscritic         AS CHAR                                NO-UNDO.
DEF VAR vr-cdpesqbb          AS CHAR                                NO-UNDO.
DEF VAR vr-cdcoptfn          AS INTEGER                             NO-UNDO. 
DEF VAR vr-cdagetfn          AS INTEGER                             NO-UNDO.
DEF VAR vr-nrterfin          AS INTEGER                             NO-UNDO.
DEF VAR vr-nrsequni          AS INTEGER                             NO-UNDO. 
DEF VAR vr-nrautdoc          AS INTEGER                             NO-UNDO. 
DEF VAR i-cod-erro           AS INTEGER                             NO-UNDO.
DEF VAR c-desc-erro          AS CHAR                                NO-UNDO.
                                                                    
DEF VAR i-nro-lote           AS INTE                                NO-UNDO.
                                                                    
DEF VAR p-literal            AS CHAR                                NO-UNDO.
DEF VAR p-ult-sequencia      AS INTE                                NO-UNDO.
DEF VAR p-registro           AS RECID                               NO-UNDO.
                                                                    
DEF VAR h_b1crap00           AS HANDLE                              NO-UNDO.
DEF VAR h-b1wgen0118         AS HANDLE                              NO-UNDO.

DEF VAR c-texto-2-via        AS CHAR                                NO-UNDO.
DEF VAR in99                 AS INTE                                NO-UNDO.
DEF VAR c-literal            AS CHAR    FORMAT "x(48)" EXTENT 100.

DEF VAR c-cgc-para-1         AS CHAR    FORMAT "x(19)"              NO-UNDO.
DEF VAR c-cgc-para-2         AS CHAR    FORMAT "x(19)"              NO-UNDO.

DEF VAR p-literal-lcm        AS CHAR                                NO-UNDO.
DEF VAR p-ult-sequencia-lcm  AS INTE                                NO-UNDO.


DEF VAR p-literal-lcx        AS CHAR                                NO-UNDO.
DEF VAR p-registro-lcx       AS RECID                               NO-UNDO.
DEF VAR p-ult-sequencia-lcx  AS INTE                                NO-UNDO.


DEF VAR c-nome-titular1      AS CHAR                                NO-UNDO.
DEF VAR c-nome-titular2      AS CHAR                                NO-UNDO.
DEF VAR c-pa-titular         AS CHAR                                NO-UNDO.

/** Variaveis para realiza-deposito-cheque */
DEF VAR aux_nrtrfcta         LIKE craptrf.nrsconta                  NO-UNDO.
DEF VAR aux_nrdconta         AS INTE                                NO-UNDO.
DEF VAR dt-liberacao         AS DATE                                NO-UNDO.
DEF VAR aux_contador         AS INTE                                NO-UNDO.
DEF VAR de-valor-total       AS DEC                                 NO-UNDO.
DEF VAR de-dinheiro          AS DEC                                 NO-UNDO.
DEF VAR de-cooperativa       AS DEC                                 NO-UNDO.
DEF VAR de-maior-praca       AS DEC                                 NO-UNDO.
DEF VAR de-menor-praca       AS DEC                                 NO-UNDO.
DEF VAR de-maior-fpraca      AS DEC                                 NO-UNDO.
DEF VAR de-menor-fpraca      AS DEC                                 NO-UNDO.
DEF VAR de-chq-intercoop     AS DEC                                 NO-UNDO.
DEF VAR c-docto-salvo        AS CHAR                                NO-UNDO.
DEF VAR c-docto              AS CHAR                                NO-UNDO.
DEF VAR l-achou-horario-corte AS LOG                                NO-UNDO.
DEF VAR aux_tpdmovto         AS INTE                                NO-UNDO.
DEF VAR i-nro-docto          AS INTE                                NO-UNDO.
DEF VAR i-seq-386            AS INTE                                NO-UNDO.
DEF VAR aux_nrsequen         AS INTE                                NO-UNDO.
DEF VAR i-nrdocmto           AS INTE                                NO-UNDO.
DEF VAR aux-p-literal        AS CHAR                                NO-UNDO.
DEF VAR aux-p-ult-sequencia  AS INTE                                NO-UNDO.
DEF VAR c-cdpacrem           AS INTE                                NO-UNDO.

DEF VAR h-b1crap51 AS HANDLE NO-UNDO.
DEF VAR h_b2crap00           AS HANDLE                              NO-UNDO.
DEF VAR h-b1crap02           AS HANDLE                              NO-UNDO.

DEF VAR aux-p-registro       AS RECID                               NO-UNDO.
DEF VAR p-nrcpfemp           AS CHAR                                NO-UNDO.

DEF BUFFER crablcm   FOR craplcm.
DEF BUFFER crabfdc   FOR crapfdc.
DEF BUFFER crabcop   FOR crapcop.
DEF BUFFER crabass   FOR crapass.    


DEFINE TEMP-TABLE tt-cheques NO-UNDO
       FIELD dtlibera AS DATE
       FIELD nrdocmto AS INTE
       FIELD vlcompel AS DECI
       FIELD nrsequen AS INTE
       FIELD nrseqlcm AS INTE
       INDEX tt-cheques1 nrdocmto dtlibera.


DEF TEMP-TABLE tt-erro NO-UNDO LIKE craperr.


PROCEDURE verifica-conta:

     DEF INPUT  PARAM p-cooper                  AS CHAR         NO-UNDO.
     DEF INPUT  PARAM p-cod-agencia             AS INTE         NO-UNDO.
     DEF INPUT  PARAM p-nro-caixa               AS INTE         NO-UNDO.
     DEF INPUT  PARAM p-coop-erro               AS CHAR         NO-UNDO.
     DEF INPUT  PARAM p-nrdconta                AS INTE         NO-UNDO.
     DEF INPUT  PARAM p-tp-docto                AS CHAR         NO-UNDO.
     DEF INPUT  PARAM p-cpfcgcde                AS CHAR         NO-UNDO.
     DEF OUTPUT PARAM p-nometit1                AS CHAR         NO-UNDO.
     DEF OUTPUT PARAM p-cpfcnpj1                AS CHAR         NO-UNDO.
     DEF OUTPUT PARAM p-nometit2                AS CHAR         NO-UNDO.
     DEF OUTPUT PARAM p-cpfcnpj2                AS CHAR         NO-UNDO.
     
     DEF VAR aux-modalidade                     AS INT          NO-UNDO.
     DEF VAR aux-dscritic                       AS CHAR         NO-UNDO.

     FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
     
     FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                        crapass.nrdconta = p-nrdconta  
                        NO-LOCK NO-ERROR.
     
     IF  AVAIL crapass  THEN
         DO:
             IF  crapass.dtdemiss <> ? THEN
                 DO:
                     ASSIGN i-cod-erro  = 64
                            c-desc-erro = " ".
                               
                     RUN cria-erro (INPUT p-coop-erro,
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
                            
                            
                            
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
           
                RUN STORED-PROCEDURE pc_busca_modalidade_tipo
                    aux_handproc = PROC-HANDLE NO-ERROR
                                            (INPUT crapass.inpessoa,
                                             INPUT crapass.cdtipcta,
                                             OUTPUT 0,   /* pr_cdmodalidade_tipo */
                                             OUTPUT "",  /* pr_des_erro */
                                             OUTPUT ""). /* pr_dscritic */
                            
                CLOSE STORED-PROC pc_busca_modalidade_tipo
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                
                ASSIGN aux-modalidade = 0
                       aux-dscritic = ""
                       aux-modalidade = pc_busca_modalidade_tipo.pr_cdmodalidade_tipo                          
                                          WHEN pc_busca_modalidade_tipo.pr_cdmodalidade_tipo <> ?
                       aux-dscritic = pc_busca_modalidade_tipo.pr_dscritic
                                          WHEN pc_busca_modalidade_tipo.pr_dscritic <> ?.
                                          
                                          
                IF aux-dscritic <> "" THEN
                DO:
                    ASSIGN i-cod-erro = 0
                           c-desc-erro = aux-dscritic.
                    
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN "NOK".
                END.


                IF p-tp-docto = "Transferencia" AND p-cpfcgcde <> "" AND aux-modalidade = 2 THEN
                DO:
                
                   FIND FIRST crapttl WHERE crapttl.cdcooper = crapcop.cdcooper
                                        AND crapttl.nrdconta = crapass.nrdconta
                                        AND crapttl.idseqttl = 1 /* Dados do Primeiro Titular */
                                        USE-INDEX crapttl1 NO-LOCK NO-ERROR.

                   IF  AVAIL crapttl THEN
                       ASSIGN p-nrcpfemp = STRING(crapttl.nrcpfemp).
                       
                     ASSIGN p-cpfcgcde  = STRING(REPLACE(REPLACE(REPLACE(p-cpfcgcde, ".", ""), "-", ""), "/", "")).
                     
                     IF INDEX(p-cpfcgcde, p-nrcpfemp) = 0 THEN
                     DO:
                   
                       ASSIGN i-cod-erro  = 0                            
                              c-desc-erro = "Lancamento nao permitido para este tipo de conta.".
                             
                       RUN cria-erro (INPUT p-coop-erro,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT i-cod-erro,
                                      INPUT c-desc-erro,
                                      INPUT YES).                 
                           
                       RETURN "NOK".
                   END.
                END.

                IF (p-tp-docto = "Deposito" OR p-tp-docto = "Cheque") AND aux-modalidade = 2 THEN
                DO:
                   ASSIGN i-cod-erro  = 0
                          c-desc-erro = "Conta salario nao permite deposito.".
                           
                   RUN cria-erro (INPUT p-coop-erro,
                                  INPUT p-cod-agencia,
                                  INPUT p-nro-caixa,
                                  INPUT i-cod-erro,
                                  INPUT c-desc-erro,
                                  INPUT YES).
                   RETURN "NOK".                        
               END.

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
                       
                RUN cria-erro (INPUT p-coop-erro,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                RETURN "NOK".
         END.
         
     RETURN "OK".

END PROCEDURE.

FUNCTION centraliza RETURNS CHARACTER ( INPUT par_frase AS CHARACTER, INPUT par_tamlinha AS INTEGER ):

    DEF VAR vr_contastr AS INTEGER NO-UNDO.
    
    ASSIGN vr_contastr = TRUNC( (par_tamlinha - LENGTH(TRIM(par_frase))) / 2 ,0).

    RETURN FILL(' ',vr_contastr) + TRIM(par_frase).
END.

PROCEDURE realiza-deposito: 
    
    DEF INPUT  PARAM p-cooper                  AS CHAR      NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia             AS INTE      NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa               AS INTE      NO-UNDO.
    DEF INPUT  PARAM p-cod-operador            AS CHAR      NO-UNDO.
    DEF INPUT  PARAM p-cooper-dest             AS CHAR      NO-UNDO.
    DEF INPUT  PARAM p-nrdcontapara            AS INTE      NO-UNDO. 
    DEF INPUT  PARAM p-valor                   AS DECI      NO-UNDO.
    DEF INPUT  PARAM p-identifica              AS CHAR      NO-UNDO.

    DEF OUTPUT PARAM p-nro-docto               AS INTE      NO-UNDO.    
    DEF OUTPUT PARAM p-nro-lote                AS INTE      NO-UNDO.
    DEF OUTPUT PARAM p-literal-autentica       AS CHAR      NO-UNDO.
    DEF OUTPUT PARAM p-ult-seq-autentica       AS INTE      NO-UNDO.
 
    DEF VAR aux_returnvl AS CHAR INIT "NOK"                 NO-UNDO.

    DEF BUFFER crabcop FOR crapcop.

    Deposito:
    DO TRANSACTION ON QUIT   UNDO Deposito, LEAVE Deposito
                   ON ERROR  UNDO Deposito, LEAVE Deposito
                   ON ENDKEY UNDO Deposito, LEAVE Deposito
                   ON STOP   UNDO Deposito, LEAVE Deposito:

       /** Cooperativa origem **/
       FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
       
       IF NOT AVAILABLE crapcop THEN
          DO:
             ASSIGN i-cod-erro  = 651
                    c-desc-erro = " ".
       
             UNDO Deposito, LEAVE Deposito.

          END.
       
       FIND crabcop WHERE crabcop.nmrescop = p-cooper-dest NO-LOCK NO-ERROR.
       
       IF NOT AVAILABLE crabcop THEN
          DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Cooperativa destino nao encontrada.".
       
             UNDO Deposito, LEAVE Deposito.
           
          END.
       
       FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.
       
       IF NOT AVAILABLE crapdat THEN
          DO:
             ASSIGN i-cod-erro  = 1
                    c-desc-erro = " ".
       
             UNDO Deposito, LEAVE Deposito.
           
          END.
       
       /* Validar para criar o lancamento ao fim da procedure */
       FIND LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper  AND
                               crapbcx.dtmvtolt = crapdat.dtmvtocd  AND  /* 25/05/2018 - Alterado para considerar o campo dtmvtocd - Everton Deserto(AMCom) */
                               crapbcx.cdagenci = p-cod-agencia     AND
                               crapbcx.nrdcaixa = p-nro-caixa       AND
                               crapbcx.cdopecxa = p-cod-operador    AND
                               crapbcx.cdsitbcx = 1
                               EXCLUSIVE-LOCK NO-ERROR.
       
       IF NOT AVAILABLE crapbcx   THEN
          DO: 
              ASSIGN i-cod-erro  = 698
                     c-desc-erro = "".
       
              UNDO Deposito, LEAVE Deposito.

          END.
       
       ASSIGN p-nro-lote = 10118
              p-nro-docto = TIME.
       
       /*--- Associa novo docmt(time) caso dois depositos seguidos ---*/
       FIND LAST craplcm WHERE craplcm.cdcooper = crabcop.cdcooper AND
                               craplcm.dtmvtolt = crapdat.dtmvtocd AND  /* 25/05/2018 - Alterado para considerar o campo dtmvtocd - Everton Deserto(AMCom) */
                               craplcm.cdagenci = 1                AND
                               craplcm.cdbccxlt = 100              AND
                               craplcm.nrdolote = p-nro-lote       AND
                               craplcm.nrdctabb = p-nrdcontapara   AND
                               craplcm.nrdocmto = p-nro-docto
                               NO-LOCK NO-ERROR.
       
       IF AVAIL craplcm THEN 
          DO:
             PAUSE 1 NO-MESSAGE.
             ASSIGN p-nro-docto = TIME.
          END.
       
       /*--- Grava Autenticacao Arquivo/Spool --*/
       IF NOT VALID-HANDLE(h_b1crap00) THEN
          RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
       
       RUN grava-autenticacao  IN h_b1crap00 (INPUT p-cooper,
                                              INPUT p-cod-agencia,
                                              INPUT p-nro-caixa,
                                              INPUT p-cod-operador,
                                              INPUT p-valor,
                                              INPUT p-nro-docto,
                                              INPUT no, /* YES (PG), NO (REC) */
                                              INPUT "1",  /* On-line            */         
                                              INPUT NO,   /* Nao estorno        */
                                              INPUT 1003, 
                                              INPUT ?, /* Data off-line */
                                              INPUT 0, /* Sequencia off-line */
                                              INPUT 0, /* Hora off-line */
                                              INPUT 0, /* Seq.orig.Off-line */
                                              OUTPUT p-literal,
                                              OUTPUT p-ult-sequencia,
                                              OUTPUT p-registro).
       
       IF VALID-HANDLE(h_b1crap00) THEN
          DELETE PROCEDURE h_b1crap00.
       
       IF RETURN-VALUE <> "OK" THEN
          DO:    
             FIND craperr WHERE craperr.cdcooper = crapcop.cdcooper AND
                                craperr.cdagenci = p-cod-agencia    AND
                                craperr.nrdcaixa = p-nro-caixa
                                NO-LOCK NO-ERROR.

             IF AVAIL craperr THEN
                DO:
                   IF craperr.cdcritic = 0 THEN
                      ASSIGN i-cod-erro  = craperr.cdcritic
                             c-desc-erro = craperr.dscritic.
                   ELSE
                      ASSIGN i-cod-erro  = craperr.cdcritic
                             c-desc-erro = "".

                END.
             ELSE
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Nao foi possível gerar a " + 
                                     "autenticacao.".
              
             UNDO Deposito, LEAVE Deposito.

          END.
       
       IF p-ult-sequencia = 0 THEN
          UNDO Deposito, LEAVE Deposito.
       
       /*** Informacao da cooperativa de origem ***/
       CREATE craplcx.
       
       ASSIGN craplcx.cdcooper = crapcop.cdcooper
              craplcx.dtmvtolt = crapdat.dtmvtocd   /* 25/05/2018 - Alterado para considerar o campo dtmvtocd - Everton Deserto(AMCom) */
              craplcx.cdagenci = p-cod-agencia
              craplcx.nrdcaixa = p-nro-caixa
              craplcx.cdopecxa = p-cod-operador
              craplcx.nrdocmto = p-nro-docto
              craplcx.nrseqdig = crapbcx.qtcompln + 1
              craplcx.nrdmaqui = crapbcx.nrdmaqui
              craplcx.cdhistor = 1003
              craplcx.dsdcompl = "Agencia:" + STRING(crabcop.cdagectl,"zzz9") + 
                                 " Conta/DV:" + STRING(p-nrdcontapara,"zzzz,zzz,9")
              craplcx.vldocmto = p-valor
              craplcx.nrautdoc = p-ult-sequencia.
       
       VALIDATE craplcx.
       
       ASSIGN crapbcx.qtcompln = crapbcx.qtcompln + 1.
       
       /*** Informacao da cooperativa de destino ***/
       FIND craplot WHERE craplot.cdcooper = crabcop.cdcooper  AND
                          craplot.dtmvtolt = crapdat.dtmvtocd  AND  /* 25/05/2018 - Alterado para considerar o campo dtmvtocd - Everton Deserto(AMCom) */
                          craplot.cdagenci = 1                 AND
                          craplot.cdbccxlt = 100               AND /* Fixo */
                          craplot.nrdolote = p-nro-lote        AND
                          craplot.tplotmov = 1
                          EXCLUSIVE-LOCK NO-ERROR.
            
       IF NOT AVAIL craplot   THEN 
          DO: 
              CREATE craplot.
       
              ASSIGN craplot.cdcooper = crabcop.cdcooper
                     craplot.dtmvtolt = crapdat.dtmvtocd    /* 25/05/2018 - Alterado para considerar o campo dtmvtocd - Everton Deserto(AMCom) */
                     craplot.cdagenci = 1   
                     craplot.cdbccxlt = 100
                     craplot.nrdolote = p-nro-lote
                     craplot.tplotmov = 1.
          END.
       
       /*--- Verifica se Lancamento ja Existe na coop. destino ---*/
       FIND craplcm WHERE craplcm.cdcooper = crabcop.cdcooper     AND
                          craplcm.dtmvtolt = crapdat.dtmvtocd     AND /* 25/05/2018 - Alterado para considerar o campo dtmvtocd - Everton Deserto(AMCom) */
                          craplcm.cdagenci = 1                    AND
                          craplcm.cdbccxlt = 100                  AND
                          craplcm.nrdolote = p-nro-lote           AND
                          craplcm.nrseqdig = craplot.nrseqdig + 1 
                          USE-INDEX craplcm3 NO-LOCK NO-ERROR.
       
       IF AVAIL craplcm   THEN 
          DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Lancamento  ja existente".
       
             UNDO Deposito, LEAVE Deposito.
       
          END.
       
       IF NOT VALID-HANDLE(h-b1wgen0200) THEN
          RUN sistema/generico/procedures/b1wgen0200.p 
            PERSISTENT SET h-b1wgen0200.
       
       RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
         (INPUT crapdat.dtmvtocd               /* par_dtmvtolt */
         ,INPUT 1                              /* par_cdagenci */
         ,INPUT 100                            /* par_cdbccxlt */
         ,INPUT p-nro-lote                     /* par_nrdolote */
         ,INPUT p-nrdcontapara                 /* par_nrdconta */
         ,INPUT p-nro-docto                    /* par_nrdocmto */
         ,INPUT 1004 /* Crédito */             /* par_cdhistor */
         ,INPUT craplot.nrseqdig + 1           /* par_nrseqdig */
         ,INPUT p-valor                        /* par_vllanmto */
         ,INPUT p-nrdcontapara                 /* par_nrdctabb */
         ,INPUT "CRAP22"                       /* par_cdpesqbb */
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
         ,INPUT TIME                           /* par_hrtransa */
         ,INPUT p-cod-operador                 /* par_cdoperad */
         ,INPUT p-identifica                   /* par_dsidenti */
         ,INPUT crabcop.cdcooper               /* par_cdcooper */
         ,INPUT 0                              /* par_nrdctitg */
         ,INPUT ""                             /* par_dscedent */
         ,INPUT crapcop.cdcooper               /* par_cdcoptfn */
         ,INPUT p-cod-agencia                  /* par_cdagetfn */
         ,INPUT p-nro-caixa                    /* par_nrterfin */
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
       
       IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO:   
             ASSIGN i-cod-erro  = aux_cdcritic
                    c-desc-erro = aux_dscritic.
             UNDO Deposito, LEAVE Deposito.
       END.
       
       IF  VALID-HANDLE(h-b1wgen0200) THEN
           DELETE PROCEDURE h-b1wgen0200.
       
       ASSIGN  craplot.nrseqdig  = craplot.nrseqdig + 1
               craplot.qtcompln  = craplot.qtcompln + 1
               craplot.qtinfoln  = craplot.qtinfoln + 1
               craplot.vlcompcr  = craplot.vlcompcr + p-valor
               craplot.vlinfocr  = craplot.vlinfocr + p-valor.
       
       VALIDATE craplot.  
          
       /** Se veio da Rotina 61 **/
       IF p-identifica MATCHES("*Deposito de envelope*") THEN
          ASSIGN c-cdpacrem = 91. /* TAA */
       ELSE
          ASSIGN c-cdpacrem = p-cod-agencia.
       
       RUN gera-log (INPUT  p-cooper,
                     INPUT  p-cod-agencia,
                     INPUT  p-nro-caixa,
                     INPUT  p-cod-operador,
                     INPUT  p-cooper-dest,
                     INPUT  0,
                     INPUT  p-nrdcontapara,
                     INPUT  1, /** Deposito **/
                     INPUT p-valor,
                     INPUT p-nro-docto,
                     INPUT c-cdpacrem).
       
       /*---- Gera literal autenticacao - RECEBIMENTO(Rolo) ----*/
       ASSIGN c-nome-titular1 = " "
              c-nome-titular2 = " ".
       
       /*** Cooperativa de destino ***/
       FIND crapass WHERE crapass.cdcooper = crabcop.cdcooper AND
                          crapass.nrdconta = p-nrdcontapara      
                          NO-LOCK NO-ERROR.
       
       IF AVAIL crapass THEN
	      DO:
          ASSIGN c-nome-titular1 = crapass.nmprimtl
                 c-pa-titular    = "   PAC: " + STRING(crapass.cdagenci,"99").
       
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
              c-literal[1]  = TRIM(crapcop.nmrescop) + " - " + 
                              TRIM(crapcop.nmextcop)
              c-literal[2]  = " "
              c-literal[3]  = STRING(crapdat.dtmvtocd,"99/99/99") + " " +   /* 25/05/2018 - Alterado para considerar o campo dtmvtocd - Everton Deserto(AMCom) */
                              STRING(TIME,"HH:MM:SS") +  " PAC " +
                              STRING(p-cod-agencia,"999") + "  CAIXA: " + 
                              STRING(p-nro-caixa,"Z99") + "/" +
                              SUBSTR(p-cod-operador,1,10)
              c-literal[4]  = " "
              c-literal[5]  = "      ** COMPROVANTE DE DEPOSITO " + 
                              STRING(p-nro-docto,"ZZZ,ZZ9")  + " **"
              c-literal[6]  = " "
              c-literal[7]  = "AGENCIA: " + STRING(crabcop.cdagectl,"9999") + 
                              " - " + p-cooper-dest
              c-literal[8]  = "CONTA: "    +  
                              TRIM(STRING(p-nrdcontapara,"zzzz,zzz,9"))     +
                              c-pa-titular 
              c-literal[9]  = "       "    +  TRIM(c-nome-titular1)
              c-literal[10] = "       "    +  TRIM(c-nome-titular2)
              c-literal[11] = " ".
            
       IF p-identifica <> "  "   THEN
          ASSIGN c-literal[12] = "DEPOSITADO POR"  
                 c-literal[13] = TRIM(p-identifica)
                 c-literal[14] = " ".  
            
       ASSIGN c-literal[15] = "   TIPO DE DEPOSITO     VALOR EM R$"
              c-literal[16] = "------------------------------------------------"
              c-literal[17] = "   EM DINHEIRO.....: " +  
                                  STRING(p-valor,"ZZZ,ZZZ,ZZ9.99") + "   "
              c-literal[23] = " "                 
              c-literal[24] = "TOTAL DEPOSITADO...: " +   
                              STRING(p-valor,"ZZZ,ZZZ,ZZ9.99")     
              c-literal[25] = " "
              c-literal[26] = p-literal
              c-literal[27] = " "
              c-literal[28] = " "
              c-literal[29] = " "
              c-literal[30] = " "
              c-literal[31] = " "
              c-literal[32] = " "
              c-literal[33] = " "
              c-literal[34] = " "
              c-literal[35] = " "
              c-literal[36] = " "
              p-literal-autentica = STRING(c-literal[1],"x(48)")   +
                                    STRING(c-literal[2],"x(48)")   +
                                    STRING(c-literal[3],"x(48)")   +
                                    STRING(c-literal[4],"x(48)")   +
                                    STRING(c-literal[5],"x(48)")   +
                                    STRING(c-literal[6],"x(48)")   +
                                    STRING(c-literal[7],"x(48)")   +
                                    STRING(c-literal[8],"x(48)")   +
                                    STRING(c-literal[9],"x(48)")   +
                                    STRING(c-literal[10],"x(48)")  +
                                    STRING(c-literal[11],"x(48)").   
         
       IF c-literal[13] <> " "   THEN
          ASSIGN p-literal-autentica =
                 p-literal-autentica + STRING(c-literal[12],"x(48)")
                 p-literal-autentica =
                 p-literal-autentica + STRING(c-literal[13],"x(48)")
                 p-literal-autentica =
                 p-literal-autentica + STRING(c-literal[14],"x(48)").
       
       ASSIGN p-literal-autentica =
              p-literal-autentica + STRING(c-literal[15],"x(48)")
              p-literal-autentica =
              p-literal-autentica + STRING(c-literal[16],"x(48)").
       
       IF c-literal[17] <> " "   THEN
          ASSIGN p-literal-autentica = p-literal-autentica + 
                                       STRING(c-literal[17],"x(48)").
       
       ASSIGN c-literal[30] = centraliza("SAC - " + STRING(crapcop.nrtelsac),48)
              c-literal[31] = centraliza("Atendimento todos os dias das " + REPLACE(REPLACE(STRING(crapcop.hrinisac,"HH:MM"),':','h'),'h00','h') + " as " + REPLACE(REPLACE(STRING(crapcop.hrfimsac,"HH:MM"),':','h'),'h00','h'),48)
              c-literal[32] = centraliza("OUVIDORIA - " + STRING(crapcop.nrtelouv),48)
              c-literal[33] = centraliza("Atendimento nos dias uteis das " + REPLACE(REPLACE(STRING(crapcop.hriniouv,"HH:MM"),':','h'),'h00','h') + " as " + REPLACE(REPLACE(STRING(crapcop.hrfimouv,"HH:MM"),':','h'),'h00','h'),48).    

       ASSIGN p-literal-autentica = p-literal-autentica         +
                                    STRING(c-literal[23],"x(48)")   +
                                    STRING(c-literal[24],"x(48)")   +
                                    STRING(c-literal[25],"x(48)")   +
                                    STRING(c-literal[26],"x(48)")   +
                                    STRING(c-literal[27],"x(48)")   +
                                    STRING(c-literal[28],"x(48)")   +
                                    STRING(c-literal[29],"x(48)")   +
                                    STRING(c-literal[30],"x(48)")   +
                                    STRING(c-literal[31],"x(48)")   +
                                    STRING(c-literal[32],"x(48)")   +
                                    STRING(c-literal[33],"x(48)")   +
                                    STRING(c-literal[34],"x(48)")   +
                                    STRING(c-literal[35],"x(48)")   +
                                    STRING(c-literal[36],"x(48)")   + 
									FILL(' ',384)                   +
									'.'
                                    p-ult-seq-autentica = p-ult-sequencia
                                    in99 = 0.
       
       DO WHILE TRUE:
       
          ASSIGN in99 = in99 + 1.
       
          FIND crapaut WHERE RECID(crapaut) = p-registro 
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
          IF NOT AVAIL crapaut THEN 
             DO:
                IF LOCKED crapaut THEN 
                   DO:
                      IF in99 < 100 THEN 
                         DO:
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                         END.
                      ELSE 
                         DO:
                            ASSIGN i-cod-erro  = 0
                                   c-desc-erro = "Tabela CRAPAUT em uso ".
       
                            UNDO Deposito, LEAVE Deposito.
       
                         END.
       
                   END.     

             END.
          ELSE 
             DO:
                ASSIGN  crapaut.dslitera = p-literal-autentica.
                RELEASE crapaut.
                LEAVE.
             END.
       
       END. /* DO WHILE */

       ASSIGN aux_returnvl = "OK".

    END.

    IF i-cod-erro <> 0   OR 
       c-desc-erro <> "" THEN
       RUN cria-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa,
                      INPUT i-cod-erro,
                      INPUT c-desc-erro,
                      INPUT YES).
       
    RETURN aux_returnvl.

END PROCEDURE.

/***************************************************************************/

PROCEDURE realiza-deposito-cheque:

    DEF INPUT  PARAM p-cooper                  AS CHAR      NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia             AS INTE      NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa               AS INTE      NO-UNDO.
    DEF INPUT  PARAM p-cod-operador            AS CHAR      NO-UNDO.
    DEF INPUT  PARAM p-cooper-dest             AS CHAR      NO-UNDO.
    DEF INPUT  PARAM p-nro-conta /* Cta Para*/ AS INTE      NO-UNDO.
    DEF INPUT  PARAM p-nro-conta-de            AS INTE      NO-UNDO. 
    DEF INPUT  PARAM p-valor                   AS DECI      NO-UNDO.
    DEF INPUT  PARAM p-identifica              AS CHAR      NO-UNDO.
    DEF INPUT  PARAM p-vestorno                AS LOG       NO-UNDO.

    DEF OUTPUT PARAM p-nro-docto               AS INTE      NO-UNDO.
    DEF OUTPUT PARAM p-literal-autentica       AS CHAR      NO-UNDO.
    DEF OUTPUT PARAM p-ult-seq-autentica       AS INTE      NO-UNDO.

    DEF VAR aux_cdcritic AS INTE                            NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                            NO-UNDO.
    DEF VAR aux_vretorno AS CHAR                            NO-UNDO.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_realiza_dep_cheq aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT p-cooper, 
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT p-cod-operador,
                          INPUT p-cooper-dest,
                          INPUT p-nro-conta,
                          INPUT p-nro-conta-de,
                          INPUT p-valor,
                          INPUT p-identifica,
                          INPUT INT(STRING(p-vestorno,"1/0")),
                          OUTPUT 0,
                          OUTPUT "",
                          OUTPUT 0,
                          OUTPUT "",
                          OUTPUT 0,
                          OUTPUT "").
    
    CLOSE STORED-PROC pc_realiza_dep_cheq aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_vretorno = ""
           p-nro-docto  = 0
           p-literal-autentica = ""
           p-ult-seq-autentica = 0
           p-nro-docto  = pc_realiza_dep_cheq.pr_nro_docmto
                          WHEN pc_realiza_dep_cheq.pr_nro_docmto <> ?
           p-literal-autentica = pc_realiza_dep_cheq.pr_literal_autentica
                                 WHEN pc_realiza_dep_cheq.pr_literal_autentica <> ?
           p-ult-seq-autentica = pc_realiza_dep_cheq.pr_ult_seq_autentica
                                 WHEN pc_realiza_dep_cheq.pr_ult_seq_autentica <> ?
           aux_vretorno = pc_realiza_dep_cheq.pr_retorno
                          WHEN pc_realiza_dep_cheq.pr_retorno <> ?
           aux_cdcritic = pc_realiza_dep_cheq.pr_cdcritic
                          WHEN pc_realiza_dep_cheq.pr_cdcritic <> ?
           aux_dscritic = pc_realiza_dep_cheq.pr_dscritic
                          WHEN pc_realiza_dep_cheq.pr_dscritic <> ?.

    /* O dataserver elimina os espaçoes em branco a esquerda de uma string, a solução
    encontrada foi colocar um caracter curinga para ser substituido por um espaço em
    branco no lado do progress. Dessa forma não é desconsiderado os espaços em branco. */
    ASSIGN p-literal-autentica = REPLACE(p-literal-autentica,"#"," ").

        
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    IF  AVAIL(crapcop) THEN
        DO:
            ASSIGN p-literal-autentica = RIGHT-TRIM(p-literal-autentica) + FILL(' ',144)  
                   + STRING(centraliza("SAC - " + STRING(crapcop.nrtelsac),48),"x(48)")
                   + STRING(centraliza("Atendimento todos os dias das " + REPLACE(REPLACE(STRING(crapcop.hrinisac,"HH:MM"),':','h'),'h00','h') + " as " + REPLACE(REPLACE(STRING(crapcop.hrfimsac,"HH:MM"),':','h'),'h00','h'),48),"x(48)")
                   + STRING(centraliza("OUVIDORIA - " + STRING(crapcop.nrtelouv),48),"x(48)")
                   + STRING(centraliza("Atendimento nos dias uteis das " + REPLACE(REPLACE(STRING(crapcop.hriniouv,"HH:MM"),':','h'),'h00','h') + " as " + REPLACE(REPLACE(STRING(crapcop.hrfimouv,"HH:MM"),':','h'),'h00','h'),48),"x(48)")
				   + FILL(' ',384)
				   + '.'.


            FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.

		    IF AVAIL(crapdat) THEN
			DO:
				FIND crapaut WHERE crapaut.cdcooper = crapcop.cdcooper 
							   AND crapaut.dtmvtolt = crapdat.dtmvtocd /* 25/05/2018 - Alterado para considerar o campo dtmvtocd - Everton Deserto(AMCom) */
							   AND crapaut.cdagenci = p-cod-agencia
							   AND crapaut.nrdcaixa = p-nro-caixa
							   AND crapaut.nrsequen = p-ult-seq-autentica EXCLUSIVE-LOCK NO-ERROR.

				IF AVAIL(crapaut) THEN
				DO:
				  ASSIGN crapaut.dslitera = p-literal-autentica.
				  VALIDATE crapaut.
				  RELEASE crapaut.			  
        END.
			END.

        END.
        
        
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF aux_cdcritic = 0  OR
       aux_dscritic = "" OR
       aux_vretorno <> "OK" THEN DO:

        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT aux_cdcritic,
                       INPUT aux_dscritic,
                       INPUT YES).

       RETURN aux_vretorno. /* NOK */
    END.

    RETURN aux_vretorno. /* OK */

END PROCEDURE.

/***************************************************************************/

PROCEDURE realiza-deposito-cheque-migrado:

    DEF INPUT  PARAM p-cooper                  AS CHAR      NO-UNDO.
    DEF INPUT  PARAM p-cooper-migrada          AS CHAR      NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia             AS INTE      NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa               AS INTE      NO-UNDO.
    DEF INPUT  PARAM p-cod-operador            AS CHAR      NO-UNDO.
    DEF INPUT  PARAM p-cooper-dest             AS CHAR      NO-UNDO.
    DEF INPUT  PARAM p-nro-conta /* Cta Para*/ AS INTE      NO-UNDO.
    DEF INPUT  PARAM p-nro-conta-de            AS INTE      NO-UNDO. 
    DEF INPUT  PARAM p-valor                   AS DECI      NO-UNDO.
    DEF INPUT  PARAM p-identifica              AS CHAR      NO-UNDO.
    DEF INPUT  PARAM p-vestorno                AS LOG       NO-UNDO.

    DEF OUTPUT PARAM p-nro-docto               AS INTE      NO-UNDO.
    DEF OUTPUT PARAM p-literal-autentica       AS CHAR      NO-UNDO.
    DEF OUTPUT PARAM p-ult-seq-autentica       AS INTE      NO-UNDO.

    DEF VAR aux_cdcritic AS INTE                            NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                            NO-UNDO.
    DEF VAR aux_vretorno AS CHAR                            NO-UNDO.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_realiz_dep_cheque_mig aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT p-cooper, 
                          INPUT p-cooper-migrada,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT p-cod-operador,
                          INPUT p-cooper-dest,
                          INPUT p-nro-conta,
                          INPUT p-nro-conta-de,
                          INPUT p-valor,
                          INPUT p-identifica,
                          INPUT INT(STRING(p-vestorno,"1/0")),
                          OUTPUT 0,
                          OUTPUT "",
                          OUTPUT 0,
                          OUTPUT "",
                          OUTPUT 0,
                          OUTPUT "").
    
    CLOSE STORED-PROC pc_realiz_dep_cheque_mig aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_vretorno = ""
           p-nro-docto  = 0
           p-literal-autentica = ""
           p-ult-seq-autentica = 0
           p-nro-docto  = pc_realiz_dep_cheque_mig.pr_nro_docmto
                          WHEN pc_realiz_dep_cheque_mig.pr_nro_docmto <> ?
           p-literal-autentica = pc_realiz_dep_cheque_mig.pr_literal_autentica
                                 WHEN pc_realiz_dep_cheque_mig.pr_literal_autentica <> ?
           p-ult-seq-autentica = pc_realiz_dep_cheque_mig.pr_ult_seq_autentica
                                 WHEN pc_realiz_dep_cheque_mig.pr_ult_seq_autentica <> ?
           aux_vretorno = pc_realiz_dep_cheque_mig.pr_retorno
                          WHEN pc_realiz_dep_cheque_mig.pr_retorno <> ?
           aux_cdcritic = pc_realiz_dep_cheque_mig.pr_cdcritic
                          WHEN pc_realiz_dep_cheque_mig.pr_cdcritic <> ?
           aux_dscritic = pc_realiz_dep_cheque_mig.pr_dscritic
                          WHEN pc_realiz_dep_cheque_mig.pr_dscritic <> ?.


    /* O dataserver elimina os espaçoes em branco a esquerda de uma string, a solução
    encontrada foi colocar um caracter curinga para ser substituido por um espaço em
    branco no lado do progress. Dessa forma não é desconsiderado os espaços em branco. */
    ASSIGN p-literal-autentica = REPLACE(p-literal-autentica,"#"," ").

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    IF  AVAIL(crapcop) THEN
        DO:
            ASSIGN p-literal-autentica = RIGHT-TRIM(p-literal-autentica) + FILL(' ',144)  
                   + STRING(centraliza("SAC - " + STRING(crapcop.nrtelsac),48),"x(48)")
                   + STRING(centraliza("Atendimento todos os dias das " + REPLACE(REPLACE(STRING(crapcop.hrinisac,"HH:MM"),':','h'),'h00','h') + " as " + REPLACE(REPLACE(STRING(crapcop.hrfimsac,"HH:MM"),':','h'),'h00','h'),48),"x(48)")
                   + STRING(centraliza("OUVIDORIA - " + STRING(crapcop.nrtelouv),48),"x(48)")
                   + STRING(centraliza("Atendimento nos dias uteis das " + REPLACE(REPLACE(STRING(crapcop.hriniouv,"HH:MM"),':','h'),'h00','h') + " as " + REPLACE(REPLACE(STRING(crapcop.hrfimouv,"HH:MM"),':','h'),'h00','h'),48),"x(48)")
				   + FILL(' ',384)
				   + '.'.

            FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.

		    IF AVAIL(crapdat) THEN
			DO:
				FIND crapaut WHERE crapaut.cdcooper = crapcop.cdcooper 
							   AND crapaut.dtmvtolt = crapdat.dtmvtocd  /* 25/05/2018 - Alterado para considerar o campo dtmvtocd - Everton Deserto(AMCom) */
							   AND crapaut.cdagenci = p-cod-agencia
							   AND crapaut.nrdcaixa = p-nro-caixa
							   AND crapaut.nrsequen = p-ult-seq-autentica EXCLUSIVE-LOCK NO-ERROR.

				IF AVAIL(crapaut) THEN
				DO:
				  ASSIGN crapaut.dslitera = p-literal-autentica.
				  VALIDATE crapaut.
				  RELEASE crapaut.			  
				END.
			END.

        END.

        
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }


    IF aux_cdcritic = 0  OR
       aux_dscritic = "" OR
       aux_vretorno <> "OK" THEN DO:

        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT aux_cdcritic,
                       INPUT aux_dscritic,
                       INPUT YES).
        RETURN aux_vretorno. /* NOK */
    END.

    RETURN aux_vretorno. /* OK */

END PROCEDURE.

/***************************************************************************/

PROCEDURE realiza-deposito-cheque-migrado-host:

    DEF INPUT  PARAM p-cooper                  AS CHAR      NO-UNDO.
    DEF INPUT  PARAM p-cooper-migrada          AS CHAR      NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia             AS INTE      NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa               AS INTE      NO-UNDO.
    DEF INPUT  PARAM p-cod-operador            AS CHAR      NO-UNDO.
    DEF INPUT  PARAM p-cooper-dest             AS CHAR      NO-UNDO.
    DEF INPUT  PARAM p-nro-conta /* Cta Para*/ AS INTE      NO-UNDO.
    DEF INPUT  PARAM p-nro-conta-de            AS INTE      NO-UNDO. 
    DEF INPUT  PARAM p-valor                   AS DECI      NO-UNDO.
    DEF INPUT  PARAM p-identifica              AS CHAR      NO-UNDO.
    DEF INPUT  PARAM p-vestorno                AS LOG       NO-UNDO.

    DEF OUTPUT PARAM p-nro-docto               AS INTE      NO-UNDO.
    DEF OUTPUT PARAM p-literal-autentica       AS CHAR      NO-UNDO.
    DEF OUTPUT PARAM p-ult-seq-autentica       AS INTE      NO-UNDO.

    DEF VAR aux_cdcritic AS INTE                            NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                            NO-UNDO.
    DEF VAR aux_vretorno AS CHAR                            NO-UNDO.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_realiz_dep_chq_mig_host aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT p-cooper,
                          INPUT p-cooper-migrada,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT p-cod-operador,
                          INPUT p-cooper-dest,
                          INPUT p-nro-conta,
                          INPUT p-nro-conta-de,
                          INPUT p-valor,
                          INPUT p-identifica,
                          INPUT INT(STRING(p-vestorno,"1/0")),
                          OUTPUT 0,
                          OUTPUT "",
                          OUTPUT 0,
                          OUTPUT "",
                          OUTPUT 0,
                          OUTPUT "").
    
    CLOSE STORED-PROC pc_realiz_dep_chq_mig_host aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_vretorno = ""
           p-nro-docto  = 0
           p-literal-autentica = ""
           p-ult-seq-autentica = 0
           p-nro-docto  = pc_realiz_dep_chq_mig_host.pr_nro_docmto
                          WHEN pc_realiz_dep_chq_mig_host.pr_nro_docmto <> ?
           p-literal-autentica = pc_realiz_dep_chq_mig_host.pr_literal_autentica
                                 WHEN pc_realiz_dep_chq_mig_host.pr_literal_autentica <> ?
           p-ult-seq-autentica = pc_realiz_dep_chq_mig_host.pr_ult_seq_autentica
                                 WHEN pc_realiz_dep_chq_mig_host.pr_ult_seq_autentica <> ?
           aux_vretorno = pc_realiz_dep_chq_mig_host.pr_retorno
                          WHEN pc_realiz_dep_chq_mig_host.pr_retorno <> ?
           aux_cdcritic = pc_realiz_dep_chq_mig_host.pr_cdcritic
                          WHEN pc_realiz_dep_chq_mig_host.pr_cdcritic <> ?
           aux_dscritic = pc_realiz_dep_chq_mig_host.pr_dscritic
                          WHEN pc_realiz_dep_chq_mig_host.pr_dscritic <> ?.


    /* O dataserver elimina os espaçoes em branco a esquerda de uma string, a solução
    encontrada foi colocar um caracter curinga para ser substituido por um espaço em
    branco no lado do progress. Dessa forma não é desconsiderado os espaços em branco. */
    ASSIGN p-literal-autentica = REPLACE(p-literal-autentica,"#"," ").

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    IF  AVAIL(crapcop) THEN
        DO:
            ASSIGN p-literal-autentica = RIGHT-TRIM(p-literal-autentica) + FILL(' ',144)  
                   + STRING(centraliza("SAC - " + STRING(crapcop.nrtelsac),48),"x(48)")
                   + STRING(centraliza("Atendimento todos os dias das " + REPLACE(REPLACE(STRING(crapcop.hrinisac,"HH:MM"),':','h'),'h00','h') + " as " + REPLACE(REPLACE(STRING(crapcop.hrfimsac,"HH:MM"),':','h'),'h00','h'),48),"x(48)")
                   + STRING(centraliza("OUVIDORIA - " + STRING(crapcop.nrtelouv),48),"x(48)")
                   + STRING(centraliza("Atendimento nos dias uteis das " + REPLACE(REPLACE(STRING(crapcop.hriniouv,"HH:MM"),':','h'),'h00','h') + " as " + REPLACE(REPLACE(STRING(crapcop.hrfimouv,"HH:MM"),':','h'),'h00','h'),48),"x(48)")
				   + FILL(' ',384)
				   + '.'.

            FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.

		    IF AVAIL(crapdat) THEN
			DO:
				FIND crapaut WHERE crapaut.cdcooper = crapcop.cdcooper 
							   AND crapaut.dtmvtolt = crapdat.dtmvtocd
							   AND crapaut.cdagenci = p-cod-agencia
							   AND crapaut.nrdcaixa = p-nro-caixa
							   AND crapaut.nrsequen = p-ult-seq-autentica EXCLUSIVE-LOCK NO-ERROR.

				IF AVAIL(crapaut) THEN
				DO:
				  ASSIGN crapaut.dslitera = p-literal-autentica.
				  VALIDATE crapaut.
				  RELEASE crapaut.			  
				END.
			END.

        END.
        
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }


    IF  aux_cdcritic = 0  OR
        aux_dscritic = "" OR
        aux_vretorno <> "OK" THEN DO:

        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT aux_cdcritic,
                       INPUT aux_dscritic,
                       INPUT YES).

        RETURN aux_vretorno. /* NOK */
    END.

    RETURN aux_vretorno. /* OK */


END PROCEDURE.

/***************************************************************************/

PROCEDURE realiza-transferencia: 
    
    DEF INPUT  PARAM p-cooper                  AS CHAR          NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia             AS INTE          NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa               AS INTE          NO-UNDO.
    DEF INPUT  PARAM p-cod-operador            AS CHAR          NO-UNDO.
    DEF INPUT  PARAM p-idorigem                AS INTE          NO-UNDO.
    DEF INPUT  PARAM p-cooper-dest             AS CHAR          NO-UNDO.
    DEF INPUT  PARAM p-nrdcontade              AS INTE          NO-UNDO.
    DEF INPUT  PARAM p-idseqttl                AS INTE          NO-UNDO.
    DEF INPUT  PARAM p-nrdcontapara            AS INTE          NO-UNDO. 
    DEF INPUT  PARAM p-valor                   AS DECI          NO-UNDO.
    DEF INPUT  PARAM p-nrsequni                AS INTE          NO-UNDO.
    DEF INPUT  PARAM p-idagenda                AS INTE          NO-UNDO. 
    DEF INPUT  PARAM p-cdcoptfn                AS INTE          NO-UNDO.
    DEF INPUT  PARAM p-nrterfin                AS INTE          NO-UNDO.
    DEF INPUT  PARAM p-idtipcar                AS INT           NO-UNDO.
    DEF INPUT  PARAM p-opcao                   AS CHAR          NO-UNDO. 
    DEF INPUT  PARAM p-dsimpvia                AS CHAR          NO-UNDO.    
    DEF INPUT  PARAM p-nrcartao                AS DECI          NO-UNDO.    

    DEF OUTPUT PARAM p-literal-autentica       AS CHAR          NO-UNDO.
    DEF OUTPUT PARAM p-ult-seq-autentica       AS INTE          NO-UNDO.
    DEF OUTPUT PARAM p-nro-docto               AS DECI          NO-UNDO. 
    DEF OUTPUT PARAM p-nro-docto-cred          AS DECI          NO-UNDO. 
    DEF OUTPUT PARAM p-cdlantar           LIKE craplat.cdlantar NO-UNDO.
    DEF OUTPUT PARAM p-registro-lcm-deb        AS RECID         NO-UNDO.  
    DEF OUTPUT PARAM p-registro-lcm-cre        AS RECID         NO-UNDO. 
    DEF OUTPUT PARAM p-nrultaut                AS INTE          NO-UNDO. 

    DEF VAR iLnAut                       AS INTE                NO-UNDO.
    DEF VAR iContLn                      AS INTE                NO-UNDO.

    DEF VAR c-desc-banco                 AS CHAR FORMAT "x(38)" NO-UNDO. 
    DEF VAR c-desc-banco2                AS CHAR FORMAT "x(38)" NO-UNDO. 
    DEF VAR c-desc-agencia1              AS CHAR FORMAT "x(38)" NO-UNDO.
    DEF VAR c-desc-agencia2              AS CHAR FORMAT "x(38)" NO-UNDO. 

    DEF VAR aux_linha1                   AS CHAR                NO-UNDO.
    DEF VAR aux_linha2                   AS CHAR                NO-UNDO.
    DEF VAR aux_nrdcaixa                 LIKE crapaut.nrdcaixa  NO-UNDO.
    DEF VAR aux_vertexto                 AS LOGI                NO-UNDO.
    DEF VAR aux_nrterfin                 LIKE craptfn.nrterfin  NO-UNDO.
    DEF VAR aux_cdcoptfn                 LIKE craptfn.cdcooper  NO-UNDO.
    DEF VAR aux_cdagetfn                 LIKE craptfn.cdagenci  NO-UNDO.
    DEF VAR aux_cdcritic                 AS INTE                NO-UNDO.
    DEF VAR aux_dscritic                 AS CHAR                NO-UNDO.
	DEF VAR aux_nmsegntl1				 LIKE crapttl.nmextttl  NO-UNDO.
	DEF VAR aux_nmsegntl2				 LIKE crapttl.nmextttl  NO-UNDO.
    DEF VAR aux_nrcpfcgc2				 LIKE crapttl.nrcpfcgc  NO-UNDO.
    
    DEF VAR aux_vltarifa                 AS DECI                NO-UNDO.
    DEF VAR aux_flgtrans                 AS LOGI                NO-UNDO.
    DEF VAR aux_contador                 AS INTE                NO-UNDO.
    DEF VAR aux_cdhisdeb                 AS INTE                NO-UNDO.
    DEF VAR aux_cdhistor                 AS INTE                NO-UNDO.
    DEF VAR aux_cdhisest                 AS INTE                NO-UNDO.
    DEF VAR aux_cdfvlcop                 AS INTE                NO-UNDO.
    DEF VAR h-b1wgen0153                 AS HANDLE              NO-UNDO.
	DEF VAR aux_nrseqdig                 AS INTE                NO-UNDO.

    DEF BUFFER crabhis FOR craphis.
    DEF BUFFER crabcop FOR crapcop.
    
    /* Tratamento de erros para internet e TAA */
    IF   p-idorigem = 2   THEN   /** Caixa online   **/
         ASSIGN aux_nrdcaixa = p-nro-caixa.
    ELSE                         /** Internet / TAA **/
         ASSIGN aux_nrdcaixa = INT(STRING(p-nrdcontade) + STRING(p-idseqttl)).                      
    
    REAL_TRANS:
    DO TRANSACTION ON ENDKEY UNDO REAL_TRANS, LEAVE REAL_TRANS
                   ON ERROR  UNDO REAL_TRANS, LEAVE REAL_TRANS
                   ON STOP   UNDO REAL_TRANS, LEAVE REAL_TRANS:

       /** Cooperativa origem **/
       FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
       
       IF   NOT AVAIL crapcop   THEN
            DO:
                ASSIGN i-cod-erro  = 651
                       c-desc-erro = "".
                        
                UNDO REAL_TRANS, LEAVE REAL_TRANS.
            END.

       /** Cooperativa destino **/
       FIND crabcop WHERE crabcop.nmrescop = p-cooper-dest NO-LOCK NO-ERROR.
       
       IF   NOT AVAIL crabcop   THEN
            DO:
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Cooperativa de destino nao cadastrada.".
                        
                UNDO REAL_TRANS, LEAVE REAL_TRANS.
            END.

       FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.
       
       IF   NOT AVAIL crapdat   THEN
            DO:
                ASSIGN i-cod-erro  = 1
                       c-desc-erro = "".
                        
                UNDO REAL_TRANS, LEAVE REAL_TRANS.   
            END.

       /*** Informacoes da conta de origem **/
       FIND crapass WHERE  crapass.cdcooper = crapcop.cdcooper AND
                           crapass.nrdconta = p-nrdcontade NO-LOCK NO-ERROR.
       
       IF   NOT AVAIL crapass   THEN
            DO:
                ASSIGN i-cod-erro  = 9
                       c-desc-erro = "".
                        
                UNDO REAL_TRANS, LEAVE REAL_TRANS.
            END.
           
	   IF crapass.inpessoa = 1 THEN
	      DO:
		     FOR FIRST crapttl FIELDS(crapttl.nmextttl)
			                    WHERE crapttl.cdcooper = crapass.cdcooper AND
							       	  crapttl.nrdconta = crapass.nrdconta AND
								      crapttl.idseqttl = 2
								      NO-LOCK:

			    ASSIGN aux_nmsegntl1 = crapttl.nmextttl.

			 END.

		  END.
           
       /** Informacoes da conta de destino **/
       FIND crabass WHERE  crabass.cdcooper = crabcop.cdcooper  AND
                           crabass.nrdconta = p-nrdcontapara NO-LOCK NO-ERROR.
       
       IF   NOT AVAIL crabass   THEN
            DO:
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Conta de destino nao cadastrada.".
                        
                UNDO REAL_TRANS, LEAVE REAL_TRANS.
            END.

	   IF crabass.inpessoa = 1 THEN
	      DO:
		     FOR FIRST crapttl FIELDS(crapttl.nmextttl crapttl.nrcpfcgc)
			                    WHERE crapttl.cdcooper = crabass.cdcooper AND
							      	  crapttl.nrdconta = crabass.nrdconta AND
								      crapttl.idseqttl = 2
								      NO-LOCK:

			 
			    ASSIGN aux_nmsegntl2 = crapttl.nmextttl
					   aux_nrcpfcgc2 = crapttl.nrcpfcgc.

		     END.

		  END.

       /* Validar para criar o lancamento ao fim da procedure */
       FIND LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper  AND
                               crapbcx.dtmvtolt = crapdat.dtmvtocd  AND
                               crapbcx.cdagenci = p-cod-agencia     AND
                               crapbcx.nrdcaixa = p-nro-caixa       AND
                               crapbcx.cdopecxa = p-cod-operador    AND
                               crapbcx.cdsitbcx = 1
                               EXCLUSIVE-LOCK NO-ERROR.
       
       IF   NOT AVAILABLE crapbcx   THEN
            DO:
                ASSIGN i-cod-erro  = 698
                       c-desc-erro = "".
                UNDO REAL_TRANS, LEAVE REAL_TRANS.
            END.
       
       /* TAA e numero do terminal prenchido */
       IF   p-idorigem  = 4   AND 
            p-nrterfin <> 0   THEN
            DO:
                FIND craptfn WHERE craptfn.cdcooper = p-cdcoptfn   AND 
                                   craptfn.nrterfin = p-nrterfin
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAIL craptfn THEN
                    IF  LOCKED craptfn   THEN
                        DO:
                            PAUSE 2 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            ASSIGN i-cod-erro  = 0
                                   c-desc-erro = 
                             "Terminal Financeiro nao cadastrado.".

                            UNDO REAL_TRANS, LEAVE REAL_TRANS.
                        END.

                ASSIGN aux_nrterfin = craptfn.nrterfin
                       aux_cdcoptfn = craptfn.cdcooper
                       aux_cdagetfn = craptfn.cdagenci.
            END.
       ELSE
       IF   p-idorigem = 4   THEN
            ASSIGN aux_cdcoptfn = p-cdcoptfn.
        
       /*** Transferencia para mesma cooperativa ***/
       IF  p-cooper = p-cooper-dest THEN
           DO:
               ASSIGN i-nro-lote   = 11000 + p-nro-caixa
                      aux_vertexto = FALSE.
           
               FIND craplot WHERE craplot.cdcooper = crabcop.cdcooper  AND
                                  craplot.dtmvtolt = crapdat.dtmvtocd  AND
                                  craplot.cdagenci = p-cod-agencia     AND
                                  craplot.cdbccxlt = 11                AND 
                                  craplot.nrdolote = i-nro-lote
                                  NO-LOCK NO-ERROR.
                    
               IF   NOT AVAIL craplot   THEN 
                     DO: 
                        CREATE craplot.
                        ASSIGN craplot.cdcooper = crabcop.cdcooper
                               craplot.dtmvtolt = crapdat.dtmvtocd
                               craplot.cdagenci = p-cod-agencia   
                               craplot.cdbccxlt = 11
                               craplot.tplotmov = 1   
                               craplot.nrdolote = i-nro-lote
                               craplot.nrdcaixa = p-nro-caixa   
                               craplot.cdopecxa = p-cod-operador.
                    END.

			   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

				/* Busca a proxima sequencia do campo CRAPLOT.NRSEQDIG */
				RUN STORED-PROCEDURE pc_sequence_progress
				aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPLOT"
													,INPUT "NRSEQDIG"
													,STRING(crabcop.cdcooper) + ";" + STRING(crapdat.dtmvtocd,"99/99/9999") + ";" + STRING(p-cod-agencia) + ";11;" + STRING(i-nro-lote)
													,INPUT "N"
													,"").

				CLOSE STORED-PROC pc_sequence_progress
				aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

				{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

				ASSIGN aux_nrseqdig = INTE(pc_sequence_progress.pr_sequence)
									  WHEN pc_sequence_progress.pr_sequence <> ?.
			   
               ASSIGN p-nro-docto = aux_nrseqdig.

               /*--- Grava Autenticacao PG --*/
               RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
               
               RUN grava-autenticacao-internet  
                         IN h_b1crap00 (INPUT p-cooper,
                                        INPUT p-nrdcontade,
                                        INPUT p-idseqttl,
                                        INPUT p-cod-agencia,
                                        INPUT p-nro-caixa,
                                        INPUT p-cod-operador,
                                        INPUT p-valor, 
                                        INPUT p-nro-docto,
             /* YES (PG), NO (REC) */   INPUT YES, 
             /* On-line            */   INPUT "1",  
             /* Nao estorno        */   INPUT NO,   
                                        INPUT 1014, /* Debito*/
             /* Data off-line */        INPUT ?, 
             /* Sequencia off-line */   INPUT 0, 
             /* Hora off-line */        INPUT 0, 
             /* Seq.orig.Off-line */    INPUT 0, 
                                        INPUT "",
                                        OUTPUT p-literal-lcm,
                                        OUTPUT p-ult-sequencia-lcm,
                                        OUTPUT p-registro-lcm-deb).

               DELETE PROCEDURE h_b1crap00.
            
               IF  RETURN-VALUE = "NOK" THEN
                   UNDO REAL_TRANS, LEAVE REAL_TRANS.
            
               /** Lancamento conta origem **/  
               FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper        AND
                                  craplcm.dtmvtolt = crapdat.dtmvtocd        AND
                                  craplcm.cdagenci = INTE(p-cod-agencia)     AND
                                  craplcm.cdbccxlt = 11                      AND
                                  craplcm.nrdolote = i-nro-lote              AND
                                  craplcm.nrseqdig = aux_nrseqdig
                                  USE-INDEX craplcm3 NO-LOCK NO-ERROR.
               
               IF   AVAIL craplcm   THEN 
                    DO:
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = "Lancamento ja existente".
                        
                        UNDO REAL_TRANS, LEAVE REAL_TRANS.
                    END.
               
               ASSIGN vr-cdpesqbb = "CRAP22"
                      vr-cdcoptfn = crapcop.cdcooper 
                      vr-cdagetfn = p-cod-agencia
                      vr-nrterfin = 0
                      vr-nrsequni = aux_nrseqdig
                      vr-nrautdoc  = p-ult-sequencia-lcm
					  aux_cdhisdeb = 1014.
               

               IF  p-idagenda > 1 THEN DO:
                   ASSIGN vr-cdpesqbb = vr-cdpesqbb + " AGENDADO".
               END.                                    

               IF  p-idorigem = 4 THEN DO:
                   ASSIGN vr-cdcoptfn = aux_cdcoptfn
                          vr-cdagetfn = aux_cdagetfn
                          vr-nrterfin = aux_nrterfin.
                       
                   IF   aux_nrterfin <> 0  THEN DO:
                            ASSIGN craptfn.nrultaut = craptfn.nrultaut + 1
                               vr-nrsequni = p-nrsequni
                               vr-nrautdoc = craptfn.nrultaut
                                   p-nrultaut       = craptfn.nrultaut. 
                   END.
               END.
               
               IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
                   RUN sistema/generico/procedures/b1wgen0200.p 
                     PERSISTENT SET h-b1wgen0200.

               RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
                  (INPUT crapdat.dtmvtocd               /* par_dtmvtolt */
                  ,INPUT p-cod-agencia                  /* par_cdagenci */
                  ,INPUT 11                             /* par_cdbccxlt */
                  ,INPUT i-nro-lote                     /* par_nrdolote */
                  ,INPUT p-nrdcontade                   /* par_nrdconta */
                  ,INPUT p-nro-docto                    /* par_nrdocmto */
                  ,INPUT 1014  /*  Débito */            /* par_cdhistor */
                  ,INPUT aux_nrseqdig                   /* par_nrseqdig */
                  ,INPUT p-valor                        /* par_vllanmto */
                  ,INPUT p-nrdcontapara                 /* par_nrdctabb */
                  ,INPUT vr-cdpesqbb                    /* par_cdpesqbb */
                  ,INPUT 0                              /* par_vldoipmf */
                  ,INPUT vr-nrautdoc                    /* par_nrautdoc */
                  ,INPUT vr-nrsequni                    /* par_nrsequni */
                  ,INPUT 0                              /* par_cdbanchq */
                  ,INPUT 0                              /* par_cdcmpchq */
                  ,INPUT 0                              /* par_cdagechq */
                  ,INPUT 0                              /* par_nrctachq */
                  ,INPUT 0                              /* par_nrlotchq */
                  ,INPUT 0                              /* par_sqlotchq */
                  ,INPUT ""                             /* par_dtrefere */
                  ,INPUT TIME                           /* par_hrtransa */
                  ,INPUT p-cod-operador                 /* par_cdoperad */
                  ,INPUT 0                              /* par_dsidenti */
                  ,INPUT crapcop.cdcooper               /* par_cdcooper */
                  ,INPUT "0"                            /* par_nrdctitg */
                  ,INPUT ""                             /* par_dscedent */
                  ,INPUT vr-cdcoptfn                    /* par_cdcoptfn */
                  ,INPUT vr-cdagetfn                    /* par_cdagetfn */
                  ,INPUT vr-nrterfin                    /* par_nrterfin */
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
                
               IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO:   
                     ASSIGN i-cod-erro  = aux_cdcritic
                            c-desc-erro = aux_dscritic.                        
                     UNDO REAL_TRANS, LEAVE REAL_TRANS.
               END.
               
               IF  VALID-HANDLE(h-b1wgen0200) THEN
                   DELETE PROCEDURE h-b1wgen0200.

                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

				/* Busca a proxima sequencia do campo CRAPLOT.NRSEQDIG */
				RUN STORED-PROCEDURE pc_sequence_progress
				aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPLOT"
													,INPUT "NRSEQDIG"
													,STRING(crabcop.cdcooper) + ";" + STRING(crapdat.dtmvtocd,"99/99/9999") + ";" + STRING(p-cod-agencia) + ";11;" + STRING(i-nro-lote)
													,INPUT "N"
													,"").

				CLOSE STORED-PROC pc_sequence_progress
				aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

				{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
               
				ASSIGN aux_nrseqdig = INTE(pc_sequence_progress.pr_sequence)
									  WHEN pc_sequence_progress.pr_sequence <> ?.

               /**** Lancamento conta destino ****/
               FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper        AND
                                  craplcm.dtmvtolt = crapdat.dtmvtocd        AND
                                  craplcm.cdagenci = INTE(p-cod-agencia)     AND
                                  craplcm.cdbccxlt = 11                      AND
                                  craplcm.nrdolote = i-nro-lote              AND
                                  craplcm.nrseqdig = aux_nrseqdig
                                  USE-INDEX craplcm3 NO-LOCK NO-ERROR.
               
               IF   AVAIL craplcm   THEN 
                    DO:
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = "Lancamento  ja existente".
               
                        UNDO REAL_TRANS, LEAVE REAL_TRANS.
                    END.
            
               /*--- Grava Autenticacao Autenticacao RC --*/
               RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
               
               RUN grava-autenticacao-internet IN h_b1crap00 
                                            (INPUT p-cooper,
                                             INPUT p-nrdcontade,
                                             INPUT p-idseqttl,
                                             INPUT p-cod-agencia,
                                             INPUT p-nro-caixa,
                                             INPUT p-cod-operador,
                                             INPUT p-valor,
                                             INPUT p-nro-docto, 
                                             INPUT NO, /* YES (PG), NO (REC) */
                                             INPUT "1",  /* On-line            */         
                                             INPUT NO,   /* Nao estorno        */
                                             INPUT 1015, /* Credito */
                                             INPUT ?, /* Data off-line */
                                             INPUT 0, /* Sequencia off-line */
                                             INPUT 0, /* Hora off-line */
                                             INPUT 0, /* Seq.orig.Off-line */
                                             INPUT "",
                                             OUTPUT p-literal,
                                             OUTPUT p-ult-sequencia,
                                             OUTPUT p-registro-lcm-cre).
               DELETE PROCEDURE h_b1crap00.
               
               IF  RETURN-VALUE = "NOK" THEN
                   UNDO REAL_TRANS, LEAVE REAL_TRANS.
        
               ASSIGN vr-cdpesqbb = "CRAP22"
                      vr-cdcoptfn = crapcop.cdcooper 
                      vr-cdagetfn = p-cod-agencia
                      vr-nrterfin = 0
                      vr-nrsequni = aux_nrseqdig
                      vr-nrautdoc = p-ult-sequencia.
               

               IF  p-idagenda > 1 THEN DO:
                   ASSIGN vr-cdpesqbb = vr-cdpesqbb + " AGENDADO".
               END.                                    

               IF  p-idorigem = 4 THEN DO:
                   ASSIGN vr-cdcoptfn = aux_cdcoptfn
                          vr-cdagetfn = aux_cdagetfn
                          vr-nrterfin = aux_nrterfin.

                   IF   aux_nrterfin <> 0  THEN DO:
                            ASSIGN craptfn.nrultaut = craptfn.nrultaut + 1
                               vr-nrsequni = p-nrsequni
                               vr-nrautdoc = craptfn.nrultaut
                                   p-nrultaut       = craptfn.nrultaut.
                   END.
               END.
               
               IF NOT VALID-HANDLE(h-b1wgen0200) THEN
                  RUN sistema/generico/procedures/b1wgen0200.p 
                    PERSISTENT SET h-b1wgen0200.

               RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
                  (INPUT crapdat.dtmvtocd               /* par_dtmvtolt */
                  ,INPUT p-cod-agencia                  /* par_cdagenci */
                  ,INPUT 11                             /* par_cdbccxlt */
                  ,INPUT i-nro-lote                     /* par_nrdolote */
                  ,INPUT p-nrdcontapara                 /* par_nrdconta */
                  ,INPUT p-nro-docto                    /* par_nrdocmto */
                  ,INPUT 1015     /* Crédito */         /* par_cdhistor */
                  ,INPUT aux_nrseqdig                   /* par_nrseqdig */
                  ,INPUT p-valor                        /* par_vllanmto */
                  ,INPUT p-nrdcontade                   /* par_nrdctabb */
                  ,INPUT vr-cdpesqbb                    /* par_cdpesqbb */
                  ,INPUT 0                              /* par_vldoipmf */
                  ,INPUT vr-nrautdoc                    /* par_nrautdoc */
                  ,INPUT vr-nrsequni                    /* par_nrsequni */
                  ,INPUT 0                              /* par_cdbanchq */
                  ,INPUT 0                              /* par_cdcmpchq */
                  ,INPUT 0                              /* par_cdagechq */
                  ,INPUT 0                              /* par_nrctachq */
                  ,INPUT 0                              /* par_nrlotchq */
                  ,INPUT 0                              /* par_sqlotchq */
                  ,INPUT ""                             /* par_dtrefere */
                  ,INPUT TIME                           /* par_hrtransa */
                  ,INPUT p-cod-operador                 /* par_cdoperad */
                  ,INPUT 0                              /* par_dsidenti */
                  ,INPUT crapcop.cdcooper               /* par_cdcooper */
                  ,INPUT ""                             /* par_nrdctitg */
                  ,INPUT ""                             /* par_dscedent */
                  ,INPUT vr-cdcoptfn                    /* par_cdcoptfn */
                  ,INPUT vr-cdagetfn                    /* par_cdagetfn */
                  ,INPUT vr-nrterfin                    /* par_nrterfin */
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
		
               IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO:   
                     ASSIGN i-cod-erro  = aux_cdcritic
                            c-desc-erro = aux_dscritic.               
                     UNDO REAL_TRANS, LEAVE REAL_TRANS.
               END.
                  
               IF VALID-HANDLE(h-b1wgen0200) THEN
                  DELETE PROCEDURE h-b1wgen0200.

               VALIDATE craplot.

               RUN gera-log (INPUT p-cooper,
                             INPUT p-cod-agencia,
                             INPUT p-nro-caixa,
                             INPUT p-cod-operador,
                             INPUT p-cooper-dest,
                             INPUT p-nrdcontade,
                             INPUT p-nrdcontapara,
                             INPUT 4, /* Transferencia mesma coop */
                             INPUT DECI(p-valor),
                             INPUT p-nro-docto,
                             INPUT 0).
           END. 
       ELSE     /** Transferencia para cooperativa diferente **/
           DO:
               ASSIGN i-nro-lote = 29000 + p-nro-caixa
                      aux_vertexto = TRUE.

               /* Validar para criar o lancamento ao fim da procedure */
               FIND LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper  AND
                                       crapbcx.dtmvtolt = crapdat.dtmvtocd  AND
                                       crapbcx.cdagenci = p-cod-agencia     AND
                                       crapbcx.nrdcaixa = p-nro-caixa       AND
                                       crapbcx.cdopecxa = p-cod-operador    AND
                                       crapbcx.cdsitbcx = 1
                                       EXCLUSIVE-LOCK NO-ERROR.
               
               IF   NOT AVAILABLE crapbcx   THEN
                    DO:
                        ASSIGN i-cod-erro  = 698
                               c-desc-erro = "".
           
                        UNDO REAL_TRANS, LEAVE REAL_TRANS.
                    END.
           
                /*** Informacao da cooperativa de origem ***/
               FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                                  craplot.dtmvtolt = crapdat.dtmvtocd  AND
                                  craplot.cdagenci = p-cod-agencia     AND
                                  craplot.cdbccxlt = 11                AND 
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
                               craplot.tplotmov = 1
                               craplot.nrdcaixa = p-nro-caixa   
                               craplot.cdopecxa = p-cod-operador.
                 END.

               ASSIGN p-nro-docto = craplot.nrseqdig + 1.

               /*** Informacao da cooperativa de origem ***/
               CREATE craplcx.
               ASSIGN craplcx.cdcooper = crapcop.cdcooper
                      craplcx.dtmvtolt = crapdat.dtmvtocd
                      craplcx.cdagenci = p-cod-agencia
                      craplcx.nrdcaixa = p-nro-caixa
                      craplcx.cdopecxa = p-cod-operador
                      craplcx.nrdocmto = p-nro-docto
                      craplcx.nrseqdig = crapbcx.qtcompln + 1
                      craplcx.nrdmaqui = crapbcx.nrdmaqui
                      craplcx.cdhistor = 1016 /* Credito*/
                      craplcx.dsdcompl =  "Agencia:" + STRING(crabcop.cdagectl,"9999") + 
                                          " Conta/DV:" + STRING(p-nrdcontapara,"zzzz,zzz,9")
                      craplcx.vldocmto = p-valor
                      craplcx.nrautdoc = p-ult-sequencia.  
               VALIDATE craplcx.

               ASSIGN crapbcx.qtcompln = crapbcx.qtcompln + 1.
          
               /*--- Grava Autenticacao PG --*/
               RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.               

               RUN grava-autenticacao-internet   
                         IN h_b1crap00 (INPUT p-cooper,
                                        INPUT p-nrdcontade,
                                        INPUT p-idseqttl,
                                        INPUT p-cod-agencia,
                                        INPUT p-nro-caixa,
                                        INPUT p-cod-operador,
                                        INPUT p-valor, 
                                        INPUT p-nro-docto,
             /* YES (PG), NO (REC) */   INPUT YES, 
             /* On-line            */   INPUT "1",  
             /* Nao estorno        */   INPUT NO,   
                                        INPUT 1009, /* Debito */
             /* Data off-line */        INPUT ?, 
             /* Sequencia off-line */   INPUT 0, 
             /* Hora off-line */        INPUT 0, 
             /* Seq.orig.Off-line */    INPUT 0, 
                                        INPUT "",
                                        OUTPUT p-literal-lcm,
                                        OUTPUT p-ult-sequencia-lcm,
                                        OUTPUT p-registro-lcm-deb).

               DELETE PROCEDURE h_b1crap00.
                              
               IF  RETURN-VALUE = "NOK" THEN
                   UNDO REAL_TRANS, LEAVE REAL_TRANS.
               
               /*--- Verifica se Lancamento ja Existe ---*/
               FIND craplcm WHERE craplcm.cdcooper = crapcop.cdcooper        AND
                                  craplcm.dtmvtolt = crapdat.dtmvtocd        AND
                                  craplcm.cdagenci = INTE(p-cod-agencia)     AND
                                  craplcm.cdbccxlt = craplot.cdbccxlt        AND
                                  craplcm.nrdolote = i-nro-lote              AND
                                  craplcm.nrseqdig = craplot.nrseqdig + 1 
                                  USE-INDEX craplcm3 NO-LOCK NO-ERROR.
               
               IF   AVAIL craplcm   THEN 
                    DO:  
                          ASSIGN i-cod-erro  = 0
                                 c-desc-erro = "Lancamento ja existente".

                          UNDO REAL_TRANS, LEAVE REAL_TRANS.              
                    END.

               IF  p-idagenda = 1  THEN
                   DO:
                       FOR LAST craplcm FIELDS (hrtransa) WHERE
                                craplcm.cdcooper = crapcop.cdcooper AND
                                craplcm.nrdconta = p-nrdcontade     AND
                                craplcm.dtmvtolt = crapdat.dtmvtocd AND    
                                craplcm.cdhistor = 1009             AND
                                craplcm.vllanmto = p-valor          AND
                                INTE(SUBSTR(craplcm.cdpesqbb,10)) = crabcop.cdagectl AND
                                craplcm.nrdctabb = p-nrdcontapara
                                NO-LOCK: END.

                       IF  AVAIL craplcm AND (TIME - craplcm.hrtransa) <= 30  THEN
                           DO:
                               ASSIGN i-cod-erro  = 0
                                      c-desc-erro = "Ja existe transferencia. " +
                                                    "de mesmo valor e favorecido. " +
                                                    "Consulte seu extrato.".
                               UNDO REAL_TRANS, LEAVE REAL_TRANS.
                           END.
                   END.
            
               ASSIGN vr-cdpesqbb = "CRAP22 - " + STRING(crabcop.cdagectl,"9999")
                      vr-cdcoptfn = crabcop.cdcooper 
                      vr-cdagetfn = crabass.cdagenci /** PAC do destinatario **/
                      vr-nrterfin = 0
                      vr-nrsequni = craplot.nrseqdig + 1
                      vr-nrautdoc = p-ult-sequencia-lcm .
               
               
               IF  p-idagenda > 1 THEN DO:
                   ASSIGN vr-cdpesqbb = vr-cdpesqbb + " AGENDADO".
               END.                                    
              
               IF  p-idorigem = 4 THEN DO:
                   ASSIGN vr-cdcoptfn = aux_cdcoptfn
                          vr-cdagetfn = aux_cdagetfn
                          vr-nrterfin = aux_nrterfin.

                   IF   aux_nrterfin <> 0  THEN DO:
                            ASSIGN craptfn.nrultaut = craptfn.nrultaut + 1
                               vr-nrsequni = p-nrsequni
                               vr-nrautdoc = craptfn.nrultaut
                                   p-nrultaut       = craptfn.nrultaut.
                   END.
               END.
               
               IF NOT VALID-HANDLE(h-b1wgen0200) THEN
                  RUN sistema/generico/procedures/b1wgen0200.p 
                    PERSISTENT SET h-b1wgen0200.

               RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
                  (INPUT crapdat.dtmvtocd                                    /* par_dtmvtolt */
                  ,INPUT p-cod-agencia                                       /* par_cdagenci */
                  ,INPUT craplot.cdbccxlt                                    /* par_cdbccxlt */
                  ,INPUT i-nro-lote                                          /* par_nrdolote */
                  ,INPUT p-nrdcontade                                        /* par_nrdconta */
                  ,INPUT p-nro-docto                                         /* par_nrdocmto */
                  ,INPUT 1009           /* Debito */                         /* par_cdhistor */
                  ,INPUT craplot.nrseqdig + 1                                /* par_nrseqdig */
                  ,INPUT p-valor                                             /* par_vllanmto */
                  ,INPUT p-nrdcontapara                                      /* par_nrdctabb */
                  ,INPUT vr-cdpesqbb                                         /* par_cdpesqbb */
                  ,INPUT 0                                                   /* par_vldoipmf */
                  ,INPUT vr-nrautdoc                                         /* par_nrautdoc */
                  ,INPUT vr-nrsequni                                         /* par_nrsequni */
                  ,INPUT 0                                                   /* par_cdbanchq */
                  ,INPUT 0                                                   /* par_cdcmpchq */
                  ,INPUT 0                                                   /* par_cdagechq */
                  ,INPUT 0                                                   /* par_nrctachq */
                  ,INPUT 0                                                   /* par_nrlotchq */
                  ,INPUT 0                                                   /* par_sqlotchq */
                  ,INPUT ""                                                  /* par_dtrefere */
                  ,INPUT TIME                                                /* par_hrtransa */
                  ,INPUT p-cod-operador                                      /* par_cdoperad */
                  ,INPUT "Agencia: "   + STRING(crabcop.cdagectl,"9999") + 
                         " Conta/DV: " + STRING(p-nrdcontapara,">>>>,>>>,9") /* par_dsidenti */
                  ,INPUT crapcop.cdcooper                                    /* par_cdcooper */
                  ,INPUT "0"                                                 /* par_nrdctitg */
                  ,INPUT ""                                                  /* par_dscedent */
                  ,INPUT vr-cdcoptfn                                         /* par_cdcoptfn */
                  ,INPUT vr-cdagetfn                                         /* par_cdagetfn */
                  ,INPUT vr-nrterfin                                         /* par_nrterfin */
                  ,INPUT 0                                                   /* par_nrparepr */
                  ,INPUT 0                                                   /* par_nrseqava */
                  ,INPUT 0                                                   /* par_nraplica */
                  ,INPUT 0                                                   /* par_cdorigem */
                  ,INPUT 0                                                   /* par_idlautom */
                  /* CAMPOS OPCIONAIS DO LOTE                                                            */ 
                  ,INPUT 0                              /* Processa lote                                 */
                  ,INPUT 0                              /* Tipo de lote a movimentar                     */
                  /* CAMPOS DE SAÍDA                                                                     */                                            
                  ,OUTPUT TABLE tt-ret-lancto           /* Collection que contém o retorno do lançamento */
                  ,OUTPUT aux_incrineg                  /* Indicador de crítica de negócio               */
                  ,OUTPUT aux_cdcritic                  /* Código da crítica                             */
                  ,OUTPUT aux_dscritic).                /* Descriçao da crítica                          */

               IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO:   
                     ASSIGN i-cod-erro  = aux_cdcritic
                            c-desc-erro = aux_dscritic.
                     UNDO REAL_TRANS, LEAVE REAL_TRANS.
               END.
                  
               IF VALID-HANDLE(h-b1wgen0200) THEN
                  DELETE PROCEDURE h-b1wgen0200.
                  
               FIND FIRST tt-ret-lancto.
               
               /* REPOSICIONAR REGISTRO CRAPLCM  */
               FIND FIRST craplcm 
                 WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm
                 NO-LOCK NO-ERROR.  
       
               IF NOT AVAIL craplcm THEN DO:
                  ASSIGN i-cod-erro  = 0
                         c-desc-erro = "Lancamento nao encontrado".
                  UNDO REAL_TRANS, LEAVE REAL_TRANS.                    
               END.

               ASSIGN   craplot.nrseqdig  = craplot.nrseqdig + 1
                        craplot.qtcompln  = craplot.qtcompln + 1
                        craplot.qtinfoln  = craplot.qtinfoln + 1
                        craplot.vlcompdb  = craplot.vlcompdb + p-valor
                        craplot.vlinfodb  = craplot.vlinfodb + p-valor
                        aux_cdhisdeb      = 1009.
                        
               VALIDATE craplot.

               /********* Lancamento da tarifa **********/

               /** Obtem valor e historico da tarifa **/
               RUN tarifa-transf-intercooperativa (INPUT crapcop.cdcooper,
                                                   INPUT p-cod-agencia,
                                                   INPUT p-nrdcontade,
                                                   INPUT p-valor,
                                                  OUTPUT aux_vltarifa,
                                                  OUTPUT aux_cdhistor,
                                                  OUTPUT aux_cdhisest,
                                                  OUTPUT aux_cdfvlcop,
                                                  OUTPUT c-desc-erro).

               IF  RETURN-VALUE <> "OK"  THEN
                   DO:
                       ASSIGN i-cod-erro = 0.
                       UNDO REAL_TRANS, LEAVE REAL_TRANS.              
                   END.
                              
               /** Tratamento para tarifa **/
               IF  aux_vltarifa <> 0 THEN 
                   DO:
                       RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT 
                           SET h-b1wgen0153.

                       RUN lan-tarifa-online IN h-b1wgen0153
                                   (INPUT crapcop.cdcooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nrdcontade,            
                                    INPUT 100,   /* cdbccxlt */         
                                    INPUT 10119, /* nrdolote */        
                                    INPUT 1,     /* tpdolote */         
                                    INPUT p-cod-operador,
                                    INPUT crapdat.dtmvtolt,
                                    INPUT crapdat.dtmvtocd,
                                    INPUT p-nrdcontapara,
                                    INPUT "0",
                                    INPUT aux_cdhistor,
                                    INPUT "Fato gerador tarifa:" + STRING(p-nrdcontapara),
                                    INPUT 0,     /* cdbanchq */
                                    INPUT 0,     /* cdagechq */
                                    INPUT 0,     /* nrctachq */
                                    INPUT FALSE, /* flgaviso */
                                    INPUT 0,     /* tpdaviso */
                                    INPUT aux_vltarifa,
                                    INPUT 0,     /* nrdocmto */
                                    INPUT craplcm.cdcoptfn,
                                    INPUT craplcm.cdagetfn,
                                    INPUT craplcm.nrterfin,
                                    INPUT craplcm.nrsequni,
                                    INPUT craplcm.nrautdoc,
                                    INPUT craplcm.dsidenti,
                                    INPUT aux_cdfvlcop,
                                    INPUT crapdat.inproces,
                                   OUTPUT p-cdlantar,
                                   OUTPUT TABLE tt-erro).

                       DELETE PROCEDURE h-b1wgen0153.

                       IF  RETURN-VALUE <> "OK"  THEN
                           DO:                       
                               FIND FIRST tt-erro NO-LOCK NO-ERROR.

                               ASSIGN i-cod-erro = 0
                                      c-desc-erro = IF AVAIL tt-erro THEN 
                                                       tt-erro.dscritic
                                                    ELSE
                                                       "Nao foi possivel " +
                                                       "lancar a tarifa.".

                               UNDO REAL_TRANS, LEAVE REAL_TRANS.
                           END.
                   END. 
           
               /***** Conta de destino *****/
               FIND craplot WHERE craplot.cdcooper = crabcop.cdcooper  AND
                                  craplot.dtmvtolt = crapdat.dtmvtocd  AND
                                  craplot.cdagenci = p-cod-agencia     AND
                                  craplot.cdbccxlt = 100               AND 
                                  craplot.nrdolote = 10120
                                  EXCLUSIVE-LOCK NO-ERROR.
                    
               IF   NOT AVAIL craplot   THEN 
                    DO: 
                        CREATE craplot.
                        ASSIGN craplot.cdcooper = crabcop.cdcooper
                               craplot.dtmvtolt = crapdat.dtmvtocd
                               craplot.cdagenci = p-cod-agencia
                               craplot.cdbccxlt = 100
                               craplot.nrdolote = 10120
                               craplot.tplotmov = 1.
                    END.

               ASSIGN p-nro-docto-cred = craplot.nrseqdig + 1.

               /*--- Grava Autenticacao RC --*/
               RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
               
               RUN grava-autenticacao-internet IN h_b1crap00
                                             (INPUT p-cooper,
                                              INPUT p-nrdcontade,
                                              INPUT p-idseqttl,
                                              INPUT p-cod-agencia,
                                              INPUT p-nro-caixa,
                                              INPUT p-cod-operador,
                                              INPUT p-valor,
                                              INPUT p-nro-docto-cred, 
                                              INPUT NO, /* YES (PG), NO (REC) */
                                              INPUT "1",  /* On-line            */         
                                              INPUT NO,   /* Nao estorno        */
                                              INPUT 1011, /* Credito */
                                              INPUT ?, /* Data off-line */
                                              INPUT 0, /* Sequencia off-line */
                                              INPUT 0, /* Hora off-line */
                                              INPUT 0, /* Seq.orig.Off-line */
                                              INPUT "",
                                              OUTPUT p-literal,
                                              OUTPUT p-ult-sequencia,
                                              OUTPUT p-registro-lcm-cre).
               DELETE PROCEDURE h_b1crap00.
               
               IF  RETURN-VALUE = "NOK" THEN
                   UNDO REAL_TRANS, LEAVE REAL_TRANS.
               
               FIND craplcm WHERE craplcm.cdcooper = crabcop.cdcooper        AND
                                  craplcm.dtmvtolt = crapdat.dtmvtocd        AND
                                  craplcm.cdagenci = p-cod-agencia           AND 
                                  craplcm.cdbccxlt = 100                     AND
                                  craplcm.nrdolote = craplot.nrdolote        AND
                                  craplcm.nrseqdig = craplot.nrseqdig + 1 
                                  USE-INDEX craplcm3 NO-LOCK NO-ERROR.
                               
               IF   AVAIL craplcm   THEN 
                    DO:
                         ASSIGN i-cod-erro  = 0
                                c-desc-erro = "Lancamento ja existente".
                         UNDO REAL_TRANS, LEAVE REAL_TRANS.
                    END.
            
               ASSIGN vr-cdpesqbb = "CRAP22 - " + STRING(crapcop.cdagectl,"9999")
                      vr-cdcoptfn = crapcop.cdcooper
                      vr-cdagetfn = p-cod-agencia /** PAC do destinatario **/
                      vr-nrterfin = 0
                      vr-nrsequni = craplot.nrseqdig + 1
                      vr-nrautdoc = p-ult-sequencia.
               
               
               IF  p-idagenda > 1 THEN DO:
                   ASSIGN vr-cdpesqbb = vr-cdpesqbb + " AGENDADO".
               END.                                    
               
               IF  p-idorigem = 4 THEN DO:
                   ASSIGN vr-cdcoptfn = aux_cdcoptfn
                          vr-cdagetfn = aux_cdagetfn
                          vr-nrterfin = aux_nrterfin.

                   IF   aux_nrterfin <> 0  THEN DO:
                            ASSIGN craptfn.nrultaut = craptfn.nrultaut + 1
                               vr-nrsequni = p-nrsequni
                               vr-nrautdoc = craptfn.nrultaut
                                   p-nrultaut       = craptfn.nrultaut. 
                   END.
               END.
               
               IF NOT VALID-HANDLE(h-b1wgen0200) THEN
                  RUN sistema/generico/procedures/b1wgen0200.p 
                    PERSISTENT SET h-b1wgen0200.

               RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
                 (INPUT crapdat.dtmvtocd                                 /* par_dtmvtolt */
                 ,INPUT p-cod-agencia                                    /* par_cdagenci */
                 ,INPUT 100                                              /* par_cdbccxlt */
                 ,INPUT craplot.nrdolote                                 /* par_nrdolote */
                 ,INPUT p-nrdcontapara                                   /* par_nrdconta */
                 ,INPUT p-nro-docto-cred                                 /* par_nrdocmto */
                 ,INPUT 1011     /* Crédito */                           /* par_cdhistor */
                 ,INPUT craplot.nrseqdig + 1                             /* par_nrseqdig */
                 ,INPUT p-valor                                          /* par_vllanmto */
                 ,INPUT p-nrdcontade                                     /* par_nrdctabb */
                 ,INPUT vr-cdpesqbb                                      /* par_cdpesqbb */
                 ,INPUT 0                                                /* par_vldoipmf */
                 ,INPUT vr-nrautdoc                                      /* par_nrautdoc */
                 ,INPUT vr-nrsequni                                      /* par_nrsequni */
                 ,INPUT 0                                                /* par_cdbanchq */
                 ,INPUT 0                                                /* par_cdcmpchq */
                 ,INPUT 0                                                /* par_cdagechq */
                 ,INPUT 0                                                /* par_nrctachq */
                 ,INPUT 0                                                /* par_nrlotchq */
                 ,INPUT 0                                                /* par_sqlotchq */
                 ,INPUT ""                                               /* par_dtrefere */
                 ,INPUT TIME                                             /* par_hrtransa */
                 ,INPUT p-cod-operador                                   /* par_cdoperad */
                 ,INPUT "Agencia:"   + STRING(crapcop.cdagectl,"9999")   +  
                        " Conta/DV:" + STRING(p-nrdcontade,"zzzz,zzz,9") /* par_dsidenti */
                 ,INPUT crabcop.cdcooper                                 /* par_cdcooper */
                 ,INPUT ""                                               /* par_nrdctitg */
                 ,INPUT ""                                               /* par_dscedent */
                 ,INPUT vr-cdcoptfn                                      /* par_cdcoptfn */
                 ,INPUT vr-cdagetfn                                      /* par_cdagetfn */
                 ,INPUT vr-nrterfin                                      /* par_nrterfin */
                 ,INPUT 0                                                /* par_nrparepr */
                 ,INPUT 0                                                /* par_nrseqava */
                 ,INPUT 0                                                /* par_nraplica */
                 ,INPUT 0                                                /* par_cdorigem */
                 ,INPUT 0                                                /* par_idlautom */
                 /* CAMPOS OPCIONAIS DO LOTE                                                            */ 
                 ,INPUT 0                              /* Processa lote                                 */
                 ,INPUT 0                              /* Tipo de lote a movimentar                     */
                 /* CAMPOS DE SAÍDA                                                                     */                                            
                 ,OUTPUT TABLE tt-ret-lancto           /* Collection que contém o retorno do lançamento */
                 ,OUTPUT aux_incrineg                  /* Indicador de crítica de negócio               */
                 ,OUTPUT aux_cdcritic                  /* Código da crítica                             */
                 ,OUTPUT aux_dscritic).                /* Descriçao da crítica                          */

               IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO:   
                     ASSIGN i-cod-erro = aux_cdcritic
                           c-desc-erro = aux_dscritic.
                     UNDO REAL_TRANS, LEAVE REAL_TRANS. 
               END.
                
               IF VALID-HANDLE(h-b1wgen0200) THEN
                  DELETE PROCEDURE h-b1wgen0200.

               ASSIGN   craplot.nrseqdig  = craplot.nrseqdig + 1
                        craplot.qtcompln  = craplot.qtcompln + 1
                        craplot.qtinfoln  = craplot.qtinfoln + 1
                        craplot.vlcompcr  = craplot.vlcompcr + p-valor
                        craplot.vlinfocr  = craplot.vlinfocr + p-valor.
               VALIDATE craplot.

               RUN gera-log (INPUT p-cooper,
                             INPUT p-cod-agencia,
                             INPUT p-nro-caixa,
                             INPUT p-cod-operador,
                             INPUT p-cooper-dest,
                             INPUT p-nrdcontade,
                             INPUT p-nrdcontapara,
                             INPUT 2, /** Transferencia coop diferente **/
                             INPUT p-valor,
                             INPUT p-nro-docto,
                             INPUT 0).
           END.
        
       /*---- Gera literal autenticacao - RECEBIMENTO(Rolo) ----*/
       
       /** Cooperativa Remetente **/
       ASSIGN c-desc-banco  = " ".
       
       FIND crapban WHERE crapban.cdbccxlt = crapcop.cdbcoctl   NO-LOCK NO-ERROR.
       
       IF  AVAIL crapban THEN 
           ASSIGN c-desc-banco = crapban.nmresbcc. 
       
       ASSIGN c-desc-agencia1 = " ".
       
       FIND crapagb WHERE crapagb.cdageban = crapcop.cdagectl   AND
                          crapagb.cddbanco = crapcop.cdbcoctl       
                          NO-LOCK NO-ERROR.
            
       IF  AVAIL crapagb THEN
           ASSIGN c-desc-agencia1 = crapagb.nmageban.
       
       /** Cooperativa Destinatario **/
       ASSIGN c-desc-agencia2 = " ".
       
       FIND crapagb WHERE crapagb.cdageban = crabcop.cdagectl   AND
                          crapagb.cddbanco = crabcop.cdbcoctl       
                          NO-LOCK NO-ERROR.
            
       IF  AVAIL crapagb THEN
           ASSIGN c-desc-agencia2 = crapagb.nmageban.
                         
       FIND crapage WHERE  crapage.cdcooper = crapcop.cdcooper AND
                           crapage.cdagenci = p-cod-agencia 
                           NO-LOCK NO-ERROR.
                            
       ASSIGN c-cgc-para-1 = STRING(crabass.nrcpfcgc)
              c-cgc-para-2 = STRING(aux_nrcpfcgc2).
       
       ASSIGN c-literal  = "". /* Limpa o conteudo do vetor */
       
       ASSIGN iLnAut = 1   
              c-literal[iLnAut] = TRIM(crapcop.nmrescop) +  " - " +
                                  TRIM(crapcop.nmextcop) 
              iLnAut = iLnAut + 1
              c-literal[iLnAut] = ""
              iLnAut = iLnAut + 1
              c-literal[iLnAut] = STRING(crapdat.dtmvtocd,"99/99/99") + " " + 
                                  STRING(TIME,"HH:MM:SS") 
                                  +  " PAC " + 
                                  STRING(p-cod-agencia,"999") +
                                  "  CAIXA: " +
                               STRING(p-nro-caixa,"Z99") + "/" +
                               SUBSTR(p-cod-operador,1,10)
              iLnAut = iLnAut + 1 
              c-literal[iLnAut] = ""
              iLnAut = iLnAut + 1 
              c-literal[iLnAut] = "      ** COMPROVANTE  TRANSFERENCIA ** ".
       
       ASSIGN iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
              iLnAut = iLnAut + 1  c-literal[iLnAut] = "REMETENTE: "
              iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
                                            
              iLnAut = iLnAut + 1  c-literal[iLnAut] = "BANCO...: " + STRING(crapcop.cdbcoctl) + 
                                                       " - " + c-desc-banco
              iLnAut = iLnAut + 1  c-literal[iLnAut] = "AGENCIA.: " + STRING(crapcop.cdagectl) +
                                                       " - " + c-desc-agencia1
              iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
              iLnAut = iLnAut + 1  c-literal[iLnAut] = "CONTA...: "  + 
                                   TRIM(STRING(p-nrdcontade,"ZZZZ,ZZ9,9")) 
                                   
              iLnAut = iLnAut + 1  c-literal[iLnAut] = "TITULAR1: "  + crapass.nmprimtl
              iLnAut = iLnAut + 1  c-literal[iLnAut] = "TITULAR2: "  + aux_nmsegntl1
              iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
              iLnAut = iLnAut + 1  c-literal[iLnAut] = "DESTINATARIO:"  
              iLnAut = iLnAut + 1  c-literal[iLnAut] = "" 
              iLnAut = iLnAut + 1  c-literal[iLnAut] = "BANCO...: " + 
                                   TRIM(STRING(crapcop.cdbcoctl,"z999")) + " - " + 
                                TRIM(c-desc-banco)        
              iLnAut = iLnAut + 1  c-literal[iLnAut] = "AGENCIA.: " +
                                   TRIM(STRING(crabcop.cdagectl,"z999")) + " - " +  
                                   TRIM(c-desc-agencia2)              
              iLnAut = iLnAut + 1  c-literal[iLnAut] = ""       
              iLnAut = iLnAut + 1  c-literal[iLnAut] = "CONTA...: " + 
                                   TRIM(STRING(p-nrdcontapara,"ZZZZ,ZZ9,9"))
              iLnAut = iLnAut + 1  c-literal[iLnAut] = "TITULAR1: "  + 
                                   crabass.nmprimtl
              iLnAut = iLnAut + 1  c-literal[iLnAut] = "TITULAR2: "  + 
                                   aux_nmsegntl2
              iLnAut = iLnAut + 1  c-literal[iLnAut] = "CPF/CNPJ: " + 
                                   "TITULAR1: " +  c-cgc-para-1  
              iLnAut = iLnAut + 1  c-literal[iLnAut] = "          " + 
                                   "TITULAR2: " +  c-cgc-para-2  
              iLnAut = iLnAut + 1  c-literal[iLnAut] = "". 
           
           
       ASSIGN iLnAut = iLnAut + 1  c-literal[iLnAut] = p-literal
              iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
              iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
              iLnAut = iLnAut + 1  c-literal[iLnAut] = "VALOR R$ " + STRING(p-valor,">>>,>>9.99")
              iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
              iLnAut = iLnAut + 1  c-literal[iLnAut] = "".       
      
       IF  aux_vertexto = TRUE  THEN
           DO:
               ASSIGN iLnAut = iLnAut + 1  c-literal[iLnAut] =
                                        "AUTORIZO A COOPERATIVA A DEBITAR EM MINHA CONTA "
                                      
                                           iLnAut = iLnAut + 1  c-literal[iLnAut] =
                                        "E A COOPERATIVA DE  DESTINO  CREDITAR  CONFORME "
                                      
                                           iLnAut = iLnAut + 1  c-literal[iLnAut] = 
                                        "DADOS INFORMADOS ACIMA".
               
               IF  aux_vltarifa <> 0  THEN
                   ASSIGN c-literal[iLnAut] = c-literal[iLnAut] +
                                               ", ACRESCIDO DA TARIFA  DE "
                          iLnAut = iLnAut + 1  c-literal[iLnAut] =
                                               "PRESTACAO DESTE SERVICO.".  
               ELSE
                   ASSIGN c-literal[iLnAut] = c-literal[iLnAut] + ".".
           END.

       ASSIGN iLnAut = iLnAut + 1  c-literal[iLnAut] = ""                        
              iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
              iLnAut = iLnAut + 1  c-literal[iLnAut] = p-literal-lcm. 
       
       ASSIGN iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
              iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
              iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
              iLnAut = iLnAut + 1  c-literal[iLnAut] =
                       "------------------------------------------------"
              iLnAut = iLnAut + 1  c-literal[iLnAut] =
                       "         ASSINATURA DO REMETENTE                "
              iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
              iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
              iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
              iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
              iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
              iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
              iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
              iLnAut = iLnAut + 1  c-literal[iLnAut] = ""
              iLnAut = iLnAut + 1  c-literal[iLnAut] = "".
       
       ASSIGN p-literal-autentica = "".

       DO iContLn = 1 TO iLnAut:
           ASSIGN p-literal-autentica = p-literal-autentica +
                                        STRING(c-literal[iContLn],"x(48)").
       END.
      
       ASSIGN p-literal-autentica = RIGHT-TRIM(p-literal-autentica)
			 + FILL(' ',112)
			 + STRING(centraliza("SAC - " + STRING(crapcop.nrtelsac),48),"x(48)")
			 + STRING(centraliza("Atendimento todos os dias das " + REPLACE(REPLACE(STRING(crapcop.hrinisac,"HH:MM"),':','h'),'h00','h') + " as " + REPLACE(REPLACE(STRING(crapcop.hrfimsac,"HH:MM"),':','h'),'h00','h'),48),"x(48)")
			 + STRING(centraliza("OUVIDORIA - " + STRING(crapcop.nrtelouv),48),"x(48)")
			 + STRING(centraliza("Atendimento nos dias uteis das " + REPLACE(REPLACE(STRING(crapcop.hriniouv,"HH:MM"),':','h'),'h00','h') + " as " + REPLACE(REPLACE(STRING(crapcop.hrfimouv,"HH:MM"),':','h'),'h00','h'),48),"x(48)")
			 + FILL(' ',480).
      
       ASSIGN c-texto-2-via = p-literal-autentica.
                        
        IF  p-opcao    = "R"  AND 
            p-dsimpvia = "S"  THEN
       ASSIGN p-literal-autentica = p-literal-autentica + c-texto-2-via.
      
       ASSIGN p-ult-seq-autentica = p-ult-sequencia.
      
       /* Autenticacao REC */
       ASSIGN in99 = 0. 

       DO  WHILE TRUE:
           
           ASSIGN in99 = in99 + 1.
           FIND crapaut WHERE RECID(crapaut) = p-registro-lcm-cre
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
           IF  NOT AVAIL crapaut THEN  
               DO:
                   IF  LOCKED crapaut  THEN 
                       DO:
                           IF  in99 < 100  THEN 
                               DO:
                                   PAUSE 1 NO-MESSAGE.
                                   NEXT.
                               END.
                           ELSE 
                               DO:
                                   ASSIGN i-cod-erro  = 0
                                          c-desc-erro = "Tabela CRAPAUT em uso ".
                                   
                                   UNDO REAL_TRANS, LEAVE REAL_TRANS.
                               END.
                       END.
                   ELSE 
                       DO:
                           ASSIGN i-cod-erro  = 0
                                  c-desc-erro = 
                                       "Erro Sistema - CRAPAUT nao Encontrado ".
                           UNDO REAL_TRANS, LEAVE REAL_TRANS.
                       END.
               END.
           ELSE 
               DO: 
                   ASSIGN  crapaut.dslitera = p-literal-autentica.
                   RELEASE crapaut.
                   LEAVE.
               END.
       END. /* fim do DO WHILE */
    
       /* Autenticacao PAG */
       ASSIGN in99 = 0. 
       DO  WHILE TRUE:
        
        ASSIGN in99 = in99 + 1.
        FIND crapaut WHERE RECID(crapaut) = p-registro-lcm-deb 
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
        IF  NOT AVAIL crapaut THEN  
            DO:
                IF  LOCKED crapaut  THEN 
                    DO:
                        IF  in99 < 100  THEN 
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                        ELSE 
                            DO:
                               ASSIGN i-cod-erro  = 0
                                      c-desc-erro = "Tabela CRAPAUT em uso".
                        
                               UNDO REAL_TRANS, LEAVE REAL_TRANS.
                            END.
                    END.
                ELSE 
                    DO:
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = 
                                  "Erro Sistema - CRAPAUT nao Encontrado ".

                        UNDO REAL_TRANS, LEAVE REAL_TRANS.
                    END.
            END.
        ELSE 
            DO:
                ASSIGN  crapaut.dslitera = p-literal-autentica.
                RELEASE crapaut.
                LEAVE.
            END.

       END. /* fim do DO WHILE */
    
       RELEASE craplot.
       ASSIGN aux_flgtrans = TRUE.
                    
    END. /* Fim transacao */

    IF   NOT aux_flgtrans  THEN
         DO:
              RUN cria-erro (INPUT p-cooper,
                             INPUT p-cod-agencia,
                             INPUT aux_nrdcaixa,
                             INPUT i-cod-erro,
                             INPUT c-desc-erro,
                             INPUT YES).
              RETURN "NOK".
         END.

    /* GERAÇAO DE LOG realiza-transferencia ORIGEM */    
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_gera_log_ope_cartao
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT crapcop.cdcooper, /* Código da Cooperativa */
                                 INPUT p-nrdcontade,     /* Numero da Conta */ 
                                 INPUT 4,                /* Transferencia */
                                 INPUT 2,                /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */ 
                                 INPUT p-idtipcar,
                                 INPUT p-nro-docto,      /* Nrd Documento */               
                                 INPUT aux_cdhisdeb,     /* HIST Debito */
                                 INPUT STRING(p-nrcartao),
                                 INPUT p-valor,
                                 INPUT p-cod-operador,   /* Código do Operador */
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT p-cod-agencia,
                                 INPUT 0,
                                 INPUT "",
                                 INPUT 0,
                                OUTPUT "").              /* Descriçao da crítica */

    /* Código da crítica */    
    CLOSE STORED-PROC pc_gera_log_ope_cartao
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""           
           aux_dscritic = pc_gera_log_ope_cartao.pr_dscritic
                          WHEN pc_gera_log_ope_cartao.pr_dscritic <> ?.
                          
    IF (aux_dscritic <> "" AND aux_dscritic <> ?) THEN
      DO:                 
         RUN cria-erro (INPUT p-cooper,
                        INPUT p-cod-agencia,
                        INPUT p-nro-caixa,
                        INPUT aux_cdcritic,
                        INPUT aux_dscritic,
                        INPUT YES).

              RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.


/* Estorna Transferencia intercooperativa */
PROCEDURE estorna-transferencia-intercooperativa:

    DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci LIKE craplot.cdagenci             NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa LIKE craplot.nrdcaixa             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta             NO-UNDO.
    DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl             NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagectl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctadst LIKE craplau.nrctadst             NO-UNDO.
    DEF  INPUT PARAM par_nrdocdeb LIKE craplcm.nrdocmto             NO-UNDO.
    DEF  INPUT PARAM par_nrdoccre LIKE craplcm.nrdocmto             NO-UNDO.
    DEF  INPUT PARAM par_cdlantar LIKE craplat.cdlantar             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad LIKE crapope.cdoperad             NO-UNDO.

    DEF OUTPUT PARAM par_dstransa AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dsprotoc AS CHAR                           NO-UNDO.

    DEF  VAR         aux_contador AS INTE                           NO-UNDO.
    DEF  VAR         aux_dslitera AS CHAR                           NO-UNDO.
    DEF  VAR         aux_sequenci AS INTE                           NO-UNDO.
    DEF  VAR         aux_nrdrecid AS RECID                          NO-UNDO.

    DEF  VAR         h-b1crap00   AS HANDLE                         NO-UNDO.
    DEF  VAR         h-b1wgen0153 AS HANDLE                         NO-UNDO.
    
    DEF  BUFFER      crabcop FOR crapcop.
    DEF  BUFFER      crablcm FOR craplcm.                         

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN par_dscritic = "Cooperativa nao cadastrada.".
            RETURN "NOK".
        END.

    FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN par_dscritic = "Registro de data nao encontrado.".
            RETURN "NOK".
        END.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
                       
    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN par_dscritic = "Associado nao cadastrado.".
            RETURN "NOK".
        END.

    FIND crabcop WHERE crabcop.cdagectl = par_cdagectl NO-LOCK NO-ERROR.

    IF   NOT AVAIL crabcop   THEN
         DO:
             ASSIGN par_dscritic = "Cooperativa de destino nao cadastrada.".
             RETURN "NOK".
         END.

    DO TRANSACTION ON ERROR UNDO, RETURN "NOK":
    
        /* Validar para criar o lancamento ao fim da procedure */
        FIND LAST crapbcx WHERE crapbcx.cdcooper = par_cdcooper     AND
                                crapbcx.dtmvtolt = crapdat.dtmvtocd AND
                                crapbcx.cdagenci = par_cdagenci     AND
                                crapbcx.nrdcaixa = par_nrdcaixa     AND
                                crapbcx.cdopecxa = par_cdoperad     AND
                                crapbcx.cdsitbcx = 1
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
       
        IF  NOT AVAILABLE crapbcx  THEN
            DO:
                ASSIGN par_dscritic = "Boletim de caixa nao esta aberto.".
                UNDO, RETURN "NOK".
            END.

        /** Busca registro do lote das transferencias **/
        DO aux_contador = 1 TO 10:

            ASSIGN par_dscritic = "".
        
            FIND craplot WHERE craplot.cdcooper = par_cdcooper     AND
                               craplot.dtmvtolt = crapdat.dtmvtocd AND
                               craplot.cdagenci = par_cdagenci     AND
                               craplot.cdbccxlt = 11               AND
                               craplot.nrdolote = 29000 + par_nrdcaixa
                               USE-INDEX craplot1
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE craplot  THEN
                DO:
                    IF  LOCKED craplot  THEN
                        DO:
                            ASSIGN par_dscritic = "O lote de debito esta " +
                                                  "sendo alterado. Tente " +
                                                  "novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        ASSIGN par_dscritic = "Lote nao cadastrado.". 
                END.
                               
            LEAVE.
                              
        END. /** Fim do DO ... TO **/

        IF  par_dscritic <> ""  THEN
            UNDO, RETURN "NOK".

        /** Busca registro de lancamento do debito da transferencia **/
        FIND craplcm WHERE craplcm.cdcooper = par_cdcooper     AND
                           craplcm.nrdconta = par_nrdconta     AND
                           craplcm.dtmvtolt = crapdat.dtmvtocd AND
                           craplcm.cdhistor = 1009             AND
                           craplcm.nrdocmto = par_nrdocdeb 
                           USE-INDEX craplcm2 NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE craplcm  THEN
            DO:
                ASSIGN par_dscritic = "Lancamento do debito nao encontrado.".
                UNDO, RETURN "NOK".
            END.

        RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
        
        IF  NOT VALID-HANDLE(h-b1crap00)  THEN
            DO:
                ASSIGN par_dscritic = "Handle invalido para BO b1crap00.".
                UNDO, RETURN "NOK".
            END.

        /** Grava autenticacao do estorno do debito da transferencia **/
        RUN grava-autenticacao IN h-b1crap00 (INPUT crapcop.nmrescop,
                                              INPUT craplot.cdagenci,
                                              INPUT craplot.nrdcaixa,
                                              INPUT par_cdoperad,
                                              INPUT craplcm.vllanmto,
                                              INPUT craplcm.nrdocmto, 
                                              INPUT YES, /** Debito/Credito **/
                                              INPUT "1", /** Status         **/
                                              INPUT YES, /** Estorno        **/
                                              INPUT craplcm.cdhistor, 
                                              INPUT ?, /** Data off-line    **/ 
                                              INPUT 0, /** Seq off-line     **/
                                              INPUT 0, /** Hora off-line    **/
                                              INPUT 0, /** Seq.Org.Off-line **/
                                             OUTPUT aux_dslitera,
                                             OUTPUT aux_sequenci,
                                             OUTPUT aux_nrdrecid).

        DELETE PROCEDURE h-b1crap00.

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                ASSIGN par_dscritic = "Nao foi possivel estornar autenticacao" +
                                      " do debito.".
                UNDO, RETURN "NOK".
            END.

        /** Atualiza registro do lote **/
        ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
               craplot.qtcompln = craplot.qtcompln + 1
               craplot.nrseqdig = craplot.nrseqdig + 1
               /** CREDITO ESTORNO **/
               craplot.vlinfocr = craplot.vlinfocr + craplcm.vllanmto
               craplot.vlcompcr = craplot.vlcompcr + craplcm.vllanmto.

        IF NOT VALID-HANDLE(h-b1wgen0200) THEN
           RUN sistema/generico/procedures/b1wgen0200.p 
             PERSISTENT SET h-b1wgen0200.
        
        RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
           (INPUT crapdat.dtmvtocd               /* par_dtmvtolt */
           ,INPUT craplot.cdagenci               /* par_cdagenci */
           ,INPUT craplot.cdbccxlt               /* par_cdbccxlt */
           ,INPUT craplot.nrdolote               /* par_nrdolote */
           ,INPUT par_nrdconta                   /* par_nrdconta */
           ,INPUT craplot.nrseqdig               /* par_nrdocmto */
           ,INPUT 1163     /* Crédito */         /* par_cdhistor */
           ,INPUT craplot.nrseqdig               /* par_nrseqdig */
           ,INPUT craplcm.vllanmto               /* par_vllanmto */
           ,INPUT par_nrctadst                   /* par_nrdctabb */
           ,INPUT "CRAP22 - " + STRING(par_cdagectl,"9999")  /* par_cdpesqbb */
           ,INPUT 0                              /* par_vldoipmf */
           ,INPUT aux_sequenci                   /* par_nrautdoc */
           ,INPUT craplot.nrseqdig               /* par_nrsequni */
           ,INPUT 0                              /* par_cdbanchq */
           ,INPUT 0                              /* par_cdcmpchq */
           ,INPUT 0                              /* par_cdagechq */
           ,INPUT 0                              /* par_nrctachq */
           ,INPUT 0                              /* par_nrlotchq */
           ,INPUT 0                              /* par_sqlotchq */
           ,INPUT crapdat.dtmvtocd               /* par_dtrefere */
           ,INPUT TIME                           /* par_hrtransa */
           ,INPUT par_cdoperad                   /* par_cdoperad */
           ,INPUT 0                              /* par_dsidenti */
           ,INPUT par_cdcooper                   /* par_cdcooper */
           ,INPUT STRING(par_nrdconta,"99999999")/* par_nrdctitg */
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
                
        IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO:
              ASSIGN par_dscritic = aux_dscritic.
              UNDO, RETURN "NOK".
        END.
                 
        IF VALID-HANDLE(h-b1wgen0200) THEN
           DELETE PROCEDURE h-b1wgen0200.

        IF VALID-HANDLE(h-b1wgen0200) THEN
           DELETE PROCEDURE h-b1wgen0200.
                  
           FIND FIRST tt-ret-lancto.
               
           /* REPOSICIONAR REGISTRO CRAPLCM  */
           FIND FIRST craplcm 
                WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm
              NO-LOCK NO-ERROR.  
       
           IF NOT AVAIL craplcm THEN DO:
              ASSIGN i-cod-erro  = 0
                     c-desc-erro = "Lancamento nao encontrado".
             UNDO, RETURN "NOK".
        END.

        /*** Informacao da cooperativa de origem ***/
        CREATE craplcx.
        ASSIGN craplcx.cdcooper = par_cdcooper
               craplcx.dtmvtolt = crapdat.dtmvtocd
               craplcx.cdagenci = par_cdagenci
               craplcx.nrdcaixa = par_nrdcaixa
               craplcx.cdopecxa = par_cdoperad
               craplcx.nrdocmto = craplot.nrseqdig
               craplcx.nrseqdig = crapbcx.qtcompln + 1
               craplcx.nrdmaqui = crapbcx.nrdmaqui
               craplcx.cdhistor = 1164
               craplcx.dsdcompl = "Agencia:" + STRING(par_cdagectl,"9999") + 
                                " Conta/DV:" + STRING(par_nrctadst,"zzzz,zzz,9")
               craplcx.vldocmto = craplcm.vllanmto
               craplcx.nrautdoc = 0.  
        VALIDATE craplcx.

        ASSIGN crapbcx.qtcompln = crapbcx.qtcompln + 1.
               
        IF  par_cdlantar <> 0  THEN /* Valor da tarifa */
            DO:
                RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT
                    SET h-b1wgen0153.

                RUN estorno-baixa-tarifa IN h-b1wgen0153 (INPUT par_cdcooper,
                                                          INPUT par_cdagenci,
                                                          INPUT par_nrdcaixa,
                                                          INPUT par_cdoperad,
                                                          INPUT crapdat.dtmvtocd,
                                                          INPUT "B1CRAP22",
                                                          INPUT par_idorigem,
                                                          INPUT crapdat.inproces,
                                                          INPUT par_nrdconta,
                                                          INPUT 1,
                                                          INPUT STRING(par_cdlantar),
                                                          INPUT "99999",
                                                          INPUT FALSE,
                                                         OUTPUT TABLE tt-erro).
                                                        
                DELETE PROCEDURE h-b1wgen0153.

                IF  RETURN-VALUE <> "OK"  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        ASSIGN par_dscritic = IF  AVAIL tt-erro  THEN
                                                  tt-erro.dscritic
                                              ELSE
                                                  "Nao foi possivel estornar a tarifa.".

                        UNDO, RETURN "NOK".
                    END.
            END.                

        /* Busca registro de lancamento credito da transferencia - DESTINO */
        FIND craplcm WHERE craplcm.cdcooper = crabcop.cdcooper AND
                           craplcm.nrdconta = par_nrctadst     AND
                           craplcm.dtmvtolt = crapdat.dtmvtocd AND
                           craplcm.cdhistor = 1011             AND
                           craplcm.nrdocmto = par_nrdoccre 
                           USE-INDEX craplcm2 NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE craplcm  THEN
            DO:
                ASSIGN par_dscritic = "Lancamento do credito nao encontrado.".
                UNDO, RETURN "NOK".
            END.
        
        DO aux_contador = 1 TO 10:
        
            FIND craplot WHERE craplot.cdcooper = crabcop.cdcooper AND
                               craplot.dtmvtolt = crapdat.dtmvtocd AND
                               craplot.cdagenci = par_cdagenci     AND
                               craplot.cdbccxlt = 100              AND 
                               craplot.nrdolote = 10120
                               EXCLUSIVE-LOCK NO-ERROR.

            IF  NOT AVAILABLE craplot  THEN
                DO:
                    IF  LOCKED craplot  THEN
                        DO:
                            ASSIGN par_dscritic = "O lote de debito esta " +
                                                  "sendo alterado. Tente " +
                                                  "novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        ASSIGN par_dscritic = "Lote nao cadastrado.". 
                END.
                               
            LEAVE.
                              
        END. /** Fim do DO ... TO **/

        IF  par_dscritic <> ""  THEN
            UNDO, RETURN "NOK".

        RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
        
        IF  NOT VALID-HANDLE(h-b1crap00)  THEN
            DO:
                ASSIGN par_dscritic = "Handle invalido para BO b1crap00.".
                UNDO, RETURN "NOK".
            END.

        /** Grava autenticacao do estorno do credito da transferencia **/
        RUN grava-autenticacao IN h-b1crap00 (INPUT crabcop.nmrescop,
                                              INPUT craplot.cdagenci,
                                              INPUT craplot.nrdcaixa,
                                              INPUT par_cdoperad,
                                              INPUT craplcm.vllanmto,
                                              INPUT craplcm.nrdocmto, 
                                              INPUT NO,  /** Debito/Credito **/
                                              INPUT "1", /** Status         **/
                                              INPUT YES, /** Estorno        **/
                                              INPUT craplcm.cdhistor, 
                                              INPUT ?, /** Data off-line    **/ 
                                              INPUT 0, /** Seq off-line     **/
                                              INPUT 0, /** Hora off-line    **/
                                              INPUT 0, /** Seq.Org.Off-line **/
                                             OUTPUT aux_dslitera,
                                             OUTPUT aux_sequenci,
                                             OUTPUT aux_nrdrecid).

        DELETE PROCEDURE h-b1crap00.

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                ASSIGN par_dscritic = "Nao foi possivel estornar autenticacao" +
                                      " do credito.".
                UNDO, RETURN "NOK".
            END.            

        /** Atualiza registro do lote **/
        ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
               craplot.qtcompln = craplot.qtcompln + 1
               craplot.nrseqdig = craplot.nrseqdig + 1
               /** DEBITO ESTORNO **/
               craplot.vlinfodb = craplot.vlinfodb + craplcm.vllanmto
               craplot.vlcompdb = craplot.vlcompdb + craplcm.vllanmto.
        
        IF NOT VALID-HANDLE(h-b1wgen0200) THEN
           RUN sistema/generico/procedures/b1wgen0200.p 
             PERSISTENT SET h-b1wgen0200.

        RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
           (INPUT crapdat.dtmvtocd               /* par_dtmvtolt */
           ,INPUT craplot.cdagenci               /* par_cdagenci */
           ,INPUT craplot.cdbccxlt               /* par_cdbccxlt */
           ,INPUT craplot.nrdolote               /* par_nrdolote */
           ,INPUT par_nrctadst                   /* par_nrdconta */
           ,INPUT craplot.nrseqdig               /* par_nrdocmto */
           ,INPUT 1167          /* Débito */     /* par_cdhistor */
           ,INPUT craplot.nrseqdig               /* par_nrseqdig */
           ,INPUT craplcm.vllanmto               /* par_vllanmto */
           ,INPUT par_nrdconta                   /* par_nrdctabb */
           ,INPUT "CRAP22 - " + STRING(crapcop.cdagectl,"9999") /* par_cdpesqbb */
           ,INPUT 0                              /* par_vldoipmf */
           ,INPUT aux_sequenci                   /* par_nrautdoc */
           ,INPUT craplot.nrseqdig               /* par_nrsequni */
           ,INPUT 0                              /* par_cdbanchq */
           ,INPUT 0                              /* par_cdcmpchq */
           ,INPUT 0                              /* par_cdagechq */
           ,INPUT 0                              /* par_nrctachq */
           ,INPUT 0                              /* par_nrlotchq */
           ,INPUT 0                              /* par_sqlotchq */
           ,INPUT crapdat.dtmvtocd               /* par_dtrefere */
           ,INPUT TIME                           /* par_hrtransa */
           ,INPUT par_cdoperad                   /* par_cdoperad */
           ,INPUT 0                              /* par_dsidenti */
           ,INPUT crabcop.cdcooper               /* par_cdcooper */
           ,INPUT STRING(par_nrctadst,"99999999")/* par_nrdctitg */
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

        IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO:   
              ASSIGN par_dscritic = aux_dscritic.
              UNDO, RETURN "NOK".
        END.
  
        IF VALID-HANDLE(h-b1wgen0200) THEN
           DELETE PROCEDURE h-b1wgen0200.

        DO aux_contador = 1 TO 10:

            FIND crapldt WHERE crapldt.cdcooper = par_cdcooper     AND
                               crapldt.cdagerem = crapcop.cdagectl AND
                               crapldt.nrctarem = par_nrdconta     AND
                               crapldt.tpoperac = 2                AND
                               crapldt.dttransa = crapdat.dtmvtocd AND
                               crapldt.nrdocmto = par_nrdocdeb
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF   NOT AVAIL crapldt   THEN
                 IF   LOCKED crapldt   THEN
                      DO:
                          ASSIGN par_dscritic = "Registro sendo alterado.".
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                      END.
                 ELSE
                      DO:
                          ASSIGN par_dscritic = "Registro log de transferencia " +
                                                "nao encontrado.".
                      END.

            LEAVE.          

        END.

        IF  par_dscritic <> ""  THEN
            UNDO, RETURN "NOK".

        ASSIGN crapldt.flgestor = TRUE.

    END. /** Fim do DO TRANSACTION - TRANSACAO **/ 

    RETURN "OK".

END PROCEDURE.


PROCEDURE gera-log: 
    
    DEF INPUT  PARAM p-cooper                  AS CHAR          NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia             AS INTE          NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa               AS INTE          NO-UNDO.
    DEF INPUT  PARAM p-operador                AS CHAR          NO-UNDO.
    DEF INPUT  PARAM p-cooper-dest             AS CHAR          NO-UNDO.
    DEF INPUT  PARAM p-nrdcontade              AS INTE          NO-UNDO.
    DEF INPUT  PARAM p-nrdcontapara            AS INTE          NO-UNDO.
    DEF INPUT  PARAM p-tpoperac                AS INTE          NO-UNDO. 
    DEF INPUT  PARAM p-valor                   AS DECI          NO-UNDO.
    DEF INPUT  PARAM p-nrdocmto                AS INTE          NO-UNDO.
    DEF INPUT  PARAM p-cdpacrem                AS INTE          NO-UNDO.

    DEF VAR aux_nrsequen                       AS INTE          NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.

    FIND crabcop WHERE crabcop.nmrescop = p-cooper-dest NO-LOCK NO-ERROR.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    /* Busca a proxima sequencia do campo crapldt.nrsequen */
    RUN STORED-PROCEDURE pc_sequence_progress
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPLDT"
                                        ,INPUT "NRSEQUEN"
                                        ,STRING(crapcop.cdcooper) + ";" + STRING(crapcop.cdagectl) + ";" + STRING(p-nrdcontade) + ";" + STRING(p-tpoperac)
                                        ,INPUT "N"
                                        ,"").
    
    CLOSE STORED-PROC pc_sequence_progress
    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_nrsequen = INTE(pc_sequence_progress.pr_sequence)
                          WHEN pc_sequence_progress.pr_sequence <> ?.

    CREATE  crapldt.
    ASSIGN  crapldt.cdcooper = crapcop.cdcooper
            crapldt.cdagerem = crapcop.cdagectl
            crapldt.nrctarem = p-nrdcontade
            crapldt.cdagedst = crabcop.cdagectl
            crapldt.nrctadst = p-nrdcontapara
            crapldt.tpoperac = p-tpoperac
            crapldt.cdoperad = p-operador
            crapldt.cdpacrem = IF p-cdpacrem <> 0 THEN 
                                  p-cdpacrem      /* Deposito TAA */ 
                               ELSE p-cod-agencia /* Deposito Caixa Online */
            crapldt.dttransa = crapdat.dtmvtocd
            crapldt.hrtransa = TIME
            crapldt.nrsequen = aux_nrsequen
            crapldt.vllanmto = p-valor
            crapldt.nrdocmto = p-nrdocmto.
    VALIDATE crapldt.

    RETURN "OK".

END PROCEDURE.                                      

PROCEDURE tarifa-transf-intercooperativa:

    DEF  INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                    NO-UNDO.
    DEF  INPUT PARAM par_vllanmto AS DECI                    NO-UNDO.

    DEF OUTPUT PARAM par_vltarifa AS DECI                    NO-UNDO.
    DEF OUTPUT PARAM par_cdhistor AS INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_cdhisest AS INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_cdfvlcop AS INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                    NO-UNDO.

    DEF VAR aux_dssigtar AS CHAR                             NO-UNDO.
    DEF VAR aux_dtdivulg AS DATE                             NO-UNDO.
    DEF VAR aux_dtvigenc AS DATE                             NO-UNDO.
    DEF VAR h-b1wgen0153 AS HANDLE                           NO-UNDO.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapass  THEN
        DO:
            ASSIGN par_dscritic = "Associado nao cadastrado.".
            RETURN "NOK".
        END.

    /** Conta administrativa nao sofre tarifacao **/
    IF  crapass.inpessoa = 3  THEN
        RETURN "OK".

    IF  par_cdagenci = 91  THEN  /** TAA **/
        ASSIGN aux_dssigtar = IF crapass.inpessoa = 1 
                              THEN "TROUTTAAPF" ELSE "TROUTTAAPJ".
    ELSE
    IF  par_cdagenci = 90  THEN  /** Internet **/
        ASSIGN aux_dssigtar = IF crapass.inpessoa = 1 
                              THEN "TROUTINTPF" ELSE "TROUTINTPJ".
    ELSE  /** Caixa On-Line **/
        ASSIGN aux_dssigtar = IF crapass.inpessoa = 1 
                              THEN "TROUTPREPF" ELSE "TROUTPREPJ".

    RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT SET h-b1wgen0153.

    IF  NOT VALID-HANDLE(h-b1wgen0153)  THEN
        DO: 
            ASSIGN par_dscritic = "Nao foi possivel carregar a tarifa.".
            RETURN "NOK".
        END.

    RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                    (INPUT par_cdcooper,
                                     INPUT aux_dssigtar,
                                     INPUT par_vllanmto,
                                     INPUT "", /* cdprogra */
                                    OUTPUT par_cdhistor,
                                    OUTPUT par_cdhisest,
                                    OUTPUT par_vltarifa,
                                    OUTPUT aux_dtdivulg,
                                    OUTPUT aux_dtvigenc,
                                    OUTPUT par_cdfvlcop,
                                    OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0153.

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAIL tt-erro  THEN
                ASSIGN par_dscritic = tt-erro.dscritic.
            ELSE
                ASSIGN par_dscritic = "Nao foi possivel carregar a tarifa.".

            RETURN "NOK".
        END.
    
    RETURN "OK".

END PROCEDURE.                                      

PROCEDURE valida-valores:

    DEF INPUT  PARAM p-cooper                  AS CHAR       NO-UNDO.
    DEF INPUT  PARAM p-cooppara                AS CHAR       NO-UNDO. 
    DEF INPUT  PARAM p-cod-agencia             AS INTE       NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa               AS INTE       NO-UNDO.

    DEF INPUT  PARAM p-tpdocto                 AS CHAR       NO-UNDO.
    DEF INPUT  PARAM p-nrdcontade              AS INTE       NO-UNDO.
    DEF INPUT  PARAM p-nrdcontapara            AS INTE       NO-UNDO. 

    DEF INPUT  PARAM p-valor                   AS DECI       NO-UNDO.
    
    /** Valida Valor **/
    IF  p-valor = 0  THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Valor deve ser Informado.". 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN 'NOK'.
        END. 
                                                        
    /** Valida Conta Remetente **/
    IF  p-tpdocto = 'transferencia' THEN
        DO:
            IF  p-nrdcontade = 0 THEN
                DO:
                    ASSIGN  i-cod-erro  = 0
                            c-desc-erro = "Conta do remetente deve ser informada.". 
                    RUN cria-erro (INPUT p-cooper,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    RETURN 'NOK'.
                END.
            /** Critica se transferencia for para mesma conta e cooperativa **/
            IF  p-cooper     = p-cooppara       AND
                p-nrdcontade = p-nrdcontapara   THEN
                DO:
                    ASSIGN  i-cod-erro = 36
                            c-desc-erro = "".
                    RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     RETURN 'NOK'.
                
                END.

        END.

    IF  p-nrdcontapara = 0 THEN
        DO:
            ASSIGN  i-cod-erro  = 0
                    c-desc-erro = "Conta do destinatario deve ser informada.". 
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN 'NOK'.
        END.
    
    RETURN "OK".

END PROCEDURE.


PROCEDURE verifica-limite-coop:

    DEF INPUT  PARAM p-cooper                  AS CHAR       NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia             AS INTE       NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa               AS INTE       NO-UNDO.
    DEF INPUT  PARAM p-operador                AS CHAR       NO-UNDO.
    DEF INPUT  PARAM p-valor                   AS DECI       NO-UNDO.
    
    DEF VAR aux_vllimite                       AS DECI       NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    
    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.
    
    RUN sistema/generico/procedures/b1wgen0118.p PERSISTENT SET h-b1wgen0118.  

    RUN busca-parametro IN h-b1wgen0118 (INPUT crapcop.cdcooper,
                                         INPUT p-cod-agencia,
                                         INPUT p-nro-caixa,
                                         INPUT 1, /* operador fixo*/
                                         INPUT "ROTINA22",
                                         INPUT 2, /** idorigem **/
                                         INPUT crapdat.dtmvtolt,
                                         INPUT FALSE,
                                         OUTPUT TABLE tt-erro, 
                                         OUTPUT aux_vllimite). 
                            
    DELETE PROCEDURE h-b1wgen0118.
    
    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".
    ELSE
        DO:  
            IF  p-valor > aux_vllimite THEN
                DO:
                    ASSIGN  i-cod-erro  = 0
                        c-desc-erro = "Valor informado maior que o valor parametrizado pela cooperativa.". 

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



PROCEDURE  valida_identificacao_dep:
              
    DEF INPUT  PARAM p-cooper         AS CHAR                  NO-UNDO.
    DEF INPUT  PARAM p-cooper-erro    AS CHAR                  NO-UNDO. 
    DEF INPUT  PARAM p-cod-agencia    AS INTEGER               NO-UNDO. /* Cod. Agencia   */
    DEF INPUT  PARAM p-nro-caixa      AS INTEGER               NO-UNDO. /* Numero Caixa       */
    DEF INPUT  PARAM p-nro-conta      AS INTEGER               NO-UNDO. /* Nro Conta          */
    DEF INPUT  PARAM p-dsidenti       AS CHAR                  NO-UNDO.
           
    DEF VAR          aux_nrdconta     AS INTEGER               NO-UNDO.
    DEF VAR          aux_nrtrfcta     AS INTEGER               NO-UNDO.
    DEF VAR          aux_dsidenti     AS CHAR                  NO-UNDO.
    DEF VAR          in01             AS INTEGER               NO-UNDO.

    ASSIGN p-nro-conta = DEC(REPLACE(STRING(p-nro-conta),".","")).

    RUN elimina-erro (INPUT p-cooper-erro,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
    
    /** Cooperativa de destino do deposito **/
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
     
    /** Cooperativa do caixa que executa o deposito **/
    FIND crabcop WHERE crabcop.nmrescop = p-cooper-erro NO-LOCK NO-ERROR.

    
    ASSIGN aux_nrdconta = p-nro-conta.
   
    IF  LENGTH(STRING(aux_nrdconta)) <= 8 THEN 
        DO: /* Nao Conta Invest. */
             
            /*--- Verifica se Houve Transferencia de Conta --*/
            ASSIGN aux_nrtrfcta = 0.
            DO  WHILE TRUE:
                FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                                   crapass.nrdconta = aux_nrdconta 
                                   NO-ERROR.
                      
                IF  CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN 
                    DO:
          
                        FIND FIRST craptrf WHERE 
                                   craptrf.cdcooper = crapcop.cdcooper  AND
                                   craptrf.nrdconta = crapass.nrdconta  AND
                                   craptrf.tptransa = 1                 AND
                                   craptrf.insittrs = 2   
                                   USE-INDEX craptrf1 NO-LOCK NO-ERROR.
                            
                        ASSIGN aux_nrtrfcta = craptrf.nrsconta
                               aux_nrdconta = craptrf.nrsconta.
                        NEXT.
                    END.
                LEAVE.
            END. /* do while */
            IF  aux_nrtrfcta > 0  THEN    /* Transferencia de Conta */
                ASSIGN aux_nrdconta = aux_nrtrfcta.
            /*-------------------------------------------------*/
        END.  
     
    ASSIGN p-nro-conta = aux_nrdconta.

    ASSIGN aux_dsidenti = p-dsidenti.
                 
    ASSIGN in01        = 1
           i-cod-erro  = 0
           c-desc-erro = " ".

    DO  WHILE in01 LE 50:
        IF  SUBSTR(aux_dsidenti,in01,1) = " " OR
            SUBSTR(aux_dsidenti,in01,1) = "A" OR  
            SUBSTR(aux_dsidenti,in01,1) = "B" OR   
            SUBSTR(aux_dsidenti,in01,1) = "C" OR                       
            SUBSTR(aux_dsidenti,in01,1) = "D" OR
            SUBSTR(aux_dsidenti,in01,1) = "E" OR   
            SUBSTR(aux_dsidenti,in01,1) = "F" OR  
            SUBSTR(aux_dsidenti,in01,1) = "G" OR   
            SUBSTR(aux_dsidenti,in01,1) = "H" OR   
            SUBSTR(aux_dsidenti,in01,1) = "I" OR                              
            SUBSTR(aux_dsidenti,in01,1) = "J" OR                             
            SUBSTR(aux_dsidenti,in01,1) = "K" OR                          
            SUBSTR(aux_dsidenti,in01,1) = "L" OR                   
            SUBSTR(aux_dsidenti,in01,1) = "M" OR                  
            SUBSTR(aux_dsidenti,in01,1) = "N" OR                   
            SUBSTR(aux_dsidenti,in01,1) = "O" OR                  
            SUBSTR(aux_dsidenti,in01,1) = "P" OR 
            SUBSTR(aux_dsidenti,in01,1) = "Q" OR                     
            SUBSTR(aux_dsidenti,in01,1) = "R" OR   
            SUBSTR(aux_dsidenti,in01,1) = "S" OR                       
            SUBSTR(aux_dsidenti,in01,1) = "T" OR
            SUBSTR(aux_dsidenti,in01,1) = "U" OR   
            SUBSTR(aux_dsidenti,in01,1) = "V" OR 
            SUBSTR(aux_dsidenti,in01,1) = "X" OR   
            SUBSTR(aux_dsidenti,in01,1) = "W" OR   
            SUBSTR(aux_dsidenti,in01,1) = "Y" OR                              
            SUBSTR(aux_dsidenti,in01,1) = "Z" OR                             
            SUBSTR(aux_dsidenti,in01,1) = "a" OR                          
            SUBSTR(aux_dsidenti,in01,1) = "b" OR                   
            SUBSTR(aux_dsidenti,in01,1) = "c" OR                  
            SUBSTR(aux_dsidenti,in01,1) = "d" OR                   
            SUBSTR(aux_dsidenti,in01,1) = "d" OR                  
            SUBSTR(aux_dsidenti,in01,1) = "e" OR 
            SUBSTR(aux_dsidenti,in01,1) = "f" OR                     
            SUBSTR(aux_dsidenti,in01,1) = "g" OR   
            SUBSTR(aux_dsidenti,in01,1) = "h" OR                       
            SUBSTR(aux_dsidenti,in01,1) = "i" OR
            SUBSTR(aux_dsidenti,in01,1) = "j" OR   
            SUBSTR(aux_dsidenti,in01,1) = "k" OR 
            SUBSTR(aux_dsidenti,in01,1) = "l" OR   
            SUBSTR(aux_dsidenti,in01,1) = "m" OR   
            SUBSTR(aux_dsidenti,in01,1) = "n" OR                              
            SUBSTR(aux_dsidenti,in01,1) = "o" OR                             
            SUBSTR(aux_dsidenti,in01,1) = "p" OR                          
            SUBSTR(aux_dsidenti,in01,1) = "q" OR                   
            SUBSTR(aux_dsidenti,in01,1) = "r" OR                  
            SUBSTR(aux_dsidenti,in01,1) = "s" OR                   
            SUBSTR(aux_dsidenti,in01,1) = "t" OR                  
            SUBSTR(aux_dsidenti,in01,1) = "u" OR 
            SUBSTR(aux_dsidenti,in01,1) = "v" OR                     
            SUBSTR(aux_dsidenti,in01,1) = "x" OR   
            SUBSTR(aux_dsidenti,in01,1) = "w" OR                       
            SUBSTR(aux_dsidenti,in01,1) = "y" OR
            SUBSTR(aux_dsidenti,in01,1) = "z" OR   
            SUBSTR(aux_dsidenti,in01,1) = "0" OR   
            SUBSTR(aux_dsidenti,in01,1) = "1" OR   
            SUBSTR(aux_dsidenti,in01,1) = "2" OR                              
            SUBSTR(aux_dsidenti,in01,1) = "3" OR                             
            SUBSTR(aux_dsidenti,in01,1) = "4" OR                          
            SUBSTR(aux_dsidenti,in01,1) = "5" OR                   
            SUBSTR(aux_dsidenti,in01,1) = "6" OR                  
            SUBSTR(aux_dsidenti,in01,1) = "7" OR                   
            SUBSTR(aux_dsidenti,in01,1) = "8" OR                  
            SUBSTR(aux_dsidenti,in01,1) = "9" THEN 
            DO:
                .
            END.
            ELSE 
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = 
                          "Ident.Deposito preenchido com caracteres invalidos".
                    RUN cria-erro (INPUT p-cooper-erro,
                                   INPUT p-cod-agencia,
                                   INPUT p-nro-caixa,
                                   INPUT i-cod-erro,
                                   INPUT c-desc-erro,
                                   INPUT YES).
                    LEAVE.
                END.
            ASSIGN in01 = in01 + 1.
    END.
    IF  c-desc-erro <> " " THEN
        RETURN "NOK".
     
    IF  crapass.flgiddep = YES  AND
        p-dsidenti       = " "  THEN 
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Ident.Deposito obrigatorio para esta conta".
            RUN cria-erro (INPUT p-cooper-erro,
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
