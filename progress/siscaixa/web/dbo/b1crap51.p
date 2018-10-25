/* .............................................................................

   Programa: siscaixa/web/b1crap51.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 13/07/2018

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Depositos com Captura 

   Alteracoes: 11/08/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)
                            
               08/11/2005 - Alteracao de crapchq e crapchs p/ crapfdc(SQLWorks)
               
               17/11/2005 - Adequacao ao padrao, analise de performance e dos
                            itens convertidos (SQLWorks - Andre)
                            
               23/02/2006 - Unificacao dos bancos - SQLWorks - Eder            
                
               23/02/2007 - Alteracao dos FINDs da crapfdc e crapcor;
                          - Alimentacao dos campos "crapfdc.cdbandep",
                            "crapfdc.cdagedep" e "crapfdc.nrctadep" (Evandro).
               
               10/09/2007 - Conversao de rotina ver_capital para BO 
                            (Sidnei/Precise)

               29/01/2008 - Incluido o PAC do cooperado na autenticacao
                            (Elton). 

               23/12/2008 - Incluido campo "capital" na temp-table tt-conta
                            (Elton).

               10/03/2009 - Ajuste para unificacao dos bancos de dados
                            (Evandro).
                            
               25/05/2009 - Alteracao CDOPERAD (Kbase).
               
               14/08/2009 - Alterado para pedir senha quando a soma dos cheques
                            depositados de uma mesma conta excederem o seu
                            saldo disponivel (Elton).

               07/10/2009 - Adaptacoes projeto IF CECRED
                            Adaptacoes para o CAF (Guilherme).
                            
               24/02/2010 - Ajuste para criacao da crapchd (Guilherme/Evandro).
               
               29/10/2010 - Chama rotina atualiza-previa-caixa (Elton).
               
               28/12/2010 - Tratamento para cheques de contas migradas 
                            (Guilherme).
                          - Chama rotina atualiza-previa-caixa somente para
                            cheques de fora (Elton).
                            
               14/02/2011 - Quando o cheque for de uma cooperativa migrada
                            e o cheque estiver sendo pago na "nova" cooperativa
                            efetuar o lancamento de pagamento com historico 21 
                            (Guilherme).
                            
               15/02/2011 - Alimentar ":" ao fim do CMC7 somente se ele possuir
                            LENGTH 34 (Guilherme).
                            
               09/12/2011 - Sustaçao provisória (André R./Supero).             
               
               27/03/2012 - Controle de LOCK no craplot (Guilherme).
               
               02/05/2012 - Inclusao da procedure autentica_cheques.
                            (David Kruger).
                            
               31/05/2012 - Corrigido procedure acima para, no estorno, apenas 
                            autenticar cheques da cooperativa  (Guilherme).
                            
               18/06/2012 - Alteracao na leitura da craptco (David Kruger).
               
               20/06/2012 - substituiçao do FIND craptab para os registros 
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.).
                            
               23/08/2012 - Procedures critica-contra-ordem e 
                            critica-contra-ordem-migradotratamento cheques 
                            custodia - Projeto Tic (Richard/Supero).             
                            
               26/10/2012 - Retirado PAUSE 20 indevido. (Diego)
                          - Alteracao da logica para migracao de PAC
                            devido a migracao da AltoVale (Guilherme).
               
               04/01/2013 - Acerto migracao Alto Vale (Elton).
               
               08/01/2013 - Acerto migracao Alto Vale na procedure
                            atualiza-deposito-com-captura-migrado-host (Elton).
                            
               10/01/2013 - Critica para nao permitir que se pague cheques de 
                            contas migradas, com cheques de contas nao migradas 
                            ou de outros bancos ao mesmo tempo (Elton).
                            
               14/01/2013 - Permite pagar cheques de contas migradas para Alto 
                            Vale no caixa da Viacredi solicitando a senha do 
                            coordenador (Elton).

               16/01/2013 - Ajuste migracao Alto Vale (Elton).

               21/06/2013 - Ajustado processo para chamar tela liberacao supervisor
                            na rotina 61 (Jean Michel).

               25/10/2013 - Tratamento para migracao dos PA's da Acredi para 
                            Viacredi (Elton).

               16/12/2013 - Adicionado validate para as tabelas crapdpb,
                            craplcm, crapchd, cra2lcm, craplcx, cra2fdc,
                            cra2lot, crapmrw (Tiago).

               19/02/2014 - Ajuste leitura craptco (Daniel).

               11/06/2014 - Somente emitir a crítica 950 apenas se a 
                            crapfdc.dtlibtic >= data do movimento
                            (SD. 163588 - Lunelli)

               20/06/2014 - Deposito Intercooperativas
                            - Novo parametro "Coop Destino"
                              -- valida-deposito-com-captura
                              -- valida-deposito-com-captura-migrado
                              -- valida-deposito-com-captura-migrado-host
                            Corrigida procedure autentica_cheques pois estava
                            posicionando na tabela crapmdw sendo que esta 
                            utilizando a buffer (erro progress 91)
                            (Guilherme/SUPERO)
                            
               16/07/2014 - Conversao de procedure autentica_cheque do fonte b1crap51
                            para pc_autentica_cheque do pacote CXON0051.
                            (Andre Santos - SUPERO)
                            
               18/12/2014 - (Chamado 230051) - Alterado mensagem de quantidade 
                            de cheques e valor, estava sempre duplicando
                            (Tiago Castro - RKAM).
                            
               19/05/2015 - Aumento do campo de Nr.Docmto da Rotina 71 
                           (Lunelli SD 285059).
                           
               29/10/2015 - Adicionado validacao para que cheques do banco 479 sejam
                            ignorados, conforme solicitado no chamado 329206. (Kelvin)

			   26/04/2016 - Inclusao dos horarios de SAC e OUVIDORIA nos
			                comprovantes, melhoria 112 (Tiago/Elton) 
               20/06/2016 - Adicionado validacao para nao permitir o recebimento 
                            de cheques de bancos que nao participam da COMPE
                            (Douglas - Chamado 417655)
                            
               05/07/2016 - #444746 A mensagem da crítica foi melhorada para 
                            "Erro de captura. Tente novamente. INF(ENTRY) = ..."
                            (Carlos)

			   18/07/2016 - Tratamento para inclusao de chave duplicada 
			                quando realizar deposito via envolope rotina 61
							e 51 (Tiago/Thiago).

               27/10/2016 - Alterado validacao para nao permitir o recebimento 
                            de cheques de bancos que nao participam da COMPE
                            Utilizar apenas BANCO e FLAG ativo
                            (Tiago - Chamado 546031)

               17/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).

               01/06/2017 - Incluso tratativa para critica 757 apenas quando 
			                cheque nao estiver descontado. (Daniel)	
                            
               21/06/2017 - Substituidos os históricos 3 e 4 pelo histórico 2433-DEPOSITO BLOQ. 
                            PRJ367 - Compe Sessao Unica (Lombardi)
               
                      
               16/03/2018 - Substituida verificacao "cdtipcta entre 8 e 11" pela
                            modalidade do tipo de conta igual a 3. PRJ366 (Lombardi).
                            
               17/05/2018 - Utilizaçao do caixa on-line mesmo com o processo batch (noturno) executando
                            (Fabio Adriano - AMcom)
                            
               25/06/2018 - inc0016988 inclusao de controles de locks (Carlos)
               
               27/06/2018 - PRJ450 - Chamada da rotina para consistir lançamentos em conta 
                            corrente (LANC0001) na tabela CRAPLCM  (Teobaldo J. - AMcom)
               
               13/07/2018 - Correcao na procedure autentica_cheques que estava gerando
                            10 autenticoes para cada deposito de cheque (Tiago/Fabricio)
............................................................................. */

/*--------------------------------------------------------------------------*/
/*  b1crap51.p   - Depositos com Captura                                    */
/*  Historicos   - 01(Dinheiro)/386(Cheque)/03(Cheq.Praca)/04(Cheq.F.Praca) */
/*--------------------------------------------------------------------------*/

{ dbo/bo-erro1.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0200tt.i }

DEF  VAR glb_nrcalcul   AS DECIMAL                        NO-UNDO.
DEF  VAR glb_dsdctitg   AS CHAR                           NO-UNDO.
DEF  VAR glb_stsnrcal   AS LOGICAL                        NO-UNDO.

/* Variavel utilizada no include includes/proc_conta_integracao.i */
DEF  VAR glb_cdcooper   AS INT                            NO-UNDO.

DEF TEMP-TABLE tt-conta                                   NO-UNDO
        FIELD situacao           AS CHAR FORMAT "x(21)"
        FIELD tipo-conta         AS CHAR FORMAT "x(21)"
        FIELD empresa            AS CHAR FORMAT "x(15)"
        FIELD devolucoes         AS INT  FORMAT "99"
        FIELD agencia            AS CHAR FORMAT "x(15)"
        FIELD magnetico          AS INT  FORMAT "z9"
        FIELD estouros           AS INT  FORMAT "zzz9"
        FIELD folhas             AS INT  FORMAT "zzz,zz9"
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
        

DEF TEMP-TABLE w-compel                                   NO-UNDO
    FIELD dsdocmc7 AS CHAR    FORMAT "X(34)"
    FIELD cdcmpchq AS INT     FORMAT "zz9"
    FIELD cdbanchq AS INT     FORMAT "zz9"
    FIELD cdagechq AS INT     FORMAT "zzz9"
    FIELD nrddigc1 AS INT     FORMAT "9"
    FIELD nrctaaux AS INT
    FIELD nrctachq AS DECIMAL FORMAT "zzz,zzz,zzz,9"
    FIELD nrctabdb AS DECIMAL FORMAT "zzz,zzz,zzz,9"
    FIELD nrddigc2 AS INT     FORMAT "9"
    FIELD nrcheque AS INT     FORMAT "zzz,zz9"
    FIELD nrddigc3 AS INT     FORMAT "9"
    FIELD vlcompel AS DECIMAL FORMAT "zzz,zzz,zz9.99"
    FIELD dtlibcom AS DATE    FORMAT "99/99/9999"
    FIELD lsdigctr AS CHAR
    FIELD tpdmovto AS INTE
    FIELD nrseqdig AS INTE
    FIELD cdtipchq AS INTE
    FIELD nrdocmto AS DEC FORMAT "zzz,zzz,9"
    FIELD nrposchq AS INTE
    FIELD tpcheque AS INTE
    INDEX compel1 AS UNIQUE PRIMARY
          dsdocmc7
    INDEX compel2 AS UNIQUE
          nrseqdig DESCENDING.

DEF VAR de-valor-libera         AS DEC                    NO-UNDO.
DEF VAR i-cod-erro              AS INT                    NO-UNDO.
DEF VAR c-desc-erro             AS CHAR                   NO-UNDO.

DEF VAR h_b2crap00              AS HANDLE                 NO-UNDO.
DEF VAR h-b1crap02              AS HANDLE                 NO-UNDO.

DEF VAR de-valor-bloqueado      AS DEC                    NO-UNDO.
DEF VAR de-valor-liberado       AS DEC                    NO-UNDO.

DEF VAR p-nro-calculado         AS DEC                    NO-UNDO.
DEF VAR p-lista-digito          AS CHAR                   NO-UNDO.
DEF VAR de-nrctachq             AS DEC     FORMAT 
                                          "zzz,zzz,zzz,9" NO-UNDO.
DEF VAR c-cmc-7                 AS CHAR                   NO-UNDO.
DEF VAR i-nro-lote              AS INTE                   NO-UNDO.
DEF VAR i-cdhistor              AS INTE                   NO-UNDO.
DEF VAR aux_lsconta1            AS CHAR                   NO-UNDO.
DEF VAR aux_lsconta2            AS CHAR                   NO-UNDO.
DEF VAR aux_lsconta3            AS CHAR                   NO-UNDO.
DEF VAR aux_lscontas            AS CHAR                   NO-UNDO.
DEF VAR i_conta                 AS DEC                    NO-UNDO.
DEF VAR aux_nrtrfcta            LIKE craptrf.nrsconta     NO-UNDO.
DEF VAR aux_nrdconta            AS INTE                   NO-UNDO.
DEF VAR i_nro-folhas            AS INTE                   NO-UNDO.
DEF VAR i_posicao               AS INTE                   NO-UNDO.
DEF VAR i_nro-talao             AS INTE                   NO-UNDO.
DEF VAR i_nro-docto             AS INTE                   NO-UNDO.

DEF VAR p-literal               AS CHAR                   NO-UNDO.
def VAR p-ult-sequencia         AS INTE                   NO-UNDO.
DEF VAR p-registro              AS RECID                  NO-UNDO.
DEF VAR aux-p-literal           AS CHAR                   NO-UNDO.
def VAR aux-p-ult-sequencia     AS INTE                   NO-UNDO.
DEF VAR aux-p-registro          AS RECID                  NO-UNDO.

DEF VAR dt-liberacao            AS DATE                   NO-UNDO.
DEF VAR dt-menor-praca          AS DATE                   NO-UNDO.
DEF VAR dt-maior-praca          AS DATE                   NO-UNDO.
DEF VAR dt-menor-fpraca         AS DATE                   NO-UNDO.
DEF VAR dt-maior-fpraca         AS DATE                   NO-UNDO.
DEF VAR aux_contador            AS INTE                   NO-UNDO.
DEF VAR c-nome-titular1         AS CHAR                   NO-UNDO.
DEF VAR c-nome-titular2         AS CHAR                   NO-UNDO.

DEF VAR i-seq-386               AS INTE                   NO-UNDO.
                                            
DEF VAR aux_tpdmovto            AS INTE                   NO-UNDO.
DEF VAR in99                    AS INTE                   NO-UNDO.

DEF VAR p-nome-titular          AS CHAR                   NO-UNDO.
DEF VAR p-poupanca              AS LOGICAL                NO-UNDO.
DEF VAR aux_cdcooper            AS INTE                   NO-UNDO.

DEF BUFFER crablcm   FOR craplcm.
DEF BUFFER crabfdc   FOR crapfdc.

DEFINE TEMP-TABLE tt-cheques NO-UNDO
       FIELD dtlibera AS DATE
       FIELD nrdocmto AS INTE
       FIELD vlcompel AS DECI
       FIELD nrsequen AS INTE
       FIELD nrseqlcm AS INTE
       INDEX tt-cheques1 nrdocmto dtlibera.

DEF VAR aux_nrsequen            AS INTE                   NO-UNDO.
DEF VAR i-codigo-erro           AS INTE                   NO-UNDO.
DEF VAR aux_nrctcomp            AS INT                    NO-UNDO.
DEF VAR aux_nrctachq            AS INTE                   NO-UNDO.
DEF VAR aux_nritgchq            LIKE crapfdc.nrdctitg     NO-UNDO.
DEF VAR aux_nrtalchq            AS INTE                   NO-UNDO.
DEF VAR aux_tpcheque            AS INTE                   NO-UNDO.
DEF VAR aux_nrdocchq            AS INTE                   NO-UNDO.

DEF VAR c-docto-salvo           AS CHAR                   NO-UNDO.
DEF VAR c-docto                 AS CHAR                   NO-UNDO.
DEF VAR de-valor                AS DEC                    NO-UNDO.
DEF VAR de-dinheiro             AS DEC                    NO-UNDO.
DEF VAR de-cooperativa          AS DEC                    NO-UNDO.
DEF VAR de-maior-praca          AS DEC                    NO-UNDO.
DEF VAR de-menor-praca          AS DEC                    NO-UNDO.
DEF VAR de-maior-fpraca         AS DEC                    NO-UNDO.
DEF VAR de-menor-fpraca         AS DEC                    NO-UNDO.
DEF VAR l-achou-horario-corte   AS LOG                    NO-UNDO.

DEF VAR i-digito                AS INTE                   NO-UNDO.
DEF VAR i-nro-docto             AS INTE                   NO-UNDO.
DEF VAR i-nrdocmto              AS INTE                   NO-UNDO.

DEF VAR h_b1crap00              AS HANDLE                 NO-UNDO.

DEF VAR i-p-nro-cheque          AS INT    FORMAT 
                                          "zzz,zz9"       NO-UNDO. /* Cheque */
DEF VAR i-p-nrddigc3            AS INT    FORMAT "9"      NO-UNDO. /* C3 */
DEF VAR i-p-cdbanchq            AS INT    FORMAT "zz9"    NO-UNDO. /* Banco */
DEF VAR i-p-cdagechq            AS INT    FORMAT "zzz9"   NO-UNDO. /* Agencia */
DEF VAR i-p-valor               AS DEC                    NO-UNDO.
DEF VAR i-p-transferencia-conta AS CHAR                   NO-UNDO.
DEF VAR i-p-aviso-cheque        AS CHAR                   NO-UNDO.
DEF VAR i-p-nrctabdb            AS DEC    FORMAT  
                                          "zzz,zzz,zzz,9" NO-UNDO. /*Conta*/

DEF VAR aux_cdagebcb            AS INTE                   NO-UNDO.
DEF VAR tab_vlchqmai            AS DEC                    NO-UNDO.

DEF VAR c-literal               AS CHAR   FORMAT "x(48)" 
                                          EXTENT 35       NO-UNDO.

DEF  VAR aux_ctpsqitg           AS DEC                    NO-UNDO.
DEF  VAR aux_nrdctitg           LIKE crapass.nrdctitg     NO-UNDO.
DEF  VAR aux_nrctaass           LIKE crapass.nrdconta     NO-UNDO.

{dbo/bo-vercheque.i}
{dbo/bo-vercheque-migrado.i}

/**   Conta Integracao **/       
DEF  VAR aux_nrdigitg           AS CHAR                   NO-UNDO.
DEF  BUFFER crabass5 FOR crapass.                             
{includes/proc_conta_integracao.i}

PROCEDURE valida-conta:
    DEF INPUT  PARAM p-cooper               AS CHAR NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia          AS INT  NO-UNDO. /* Cod.Agencia  */
    DEF INPUT  PARAM p-nro-caixa            AS INT  NO-UNDO. /* Numero Caixa */
    DEF INPUT  PARAM p-nro-conta            AS INT  NO-UNDO. /* Nro Conta    */
    DEF OUTPUT PARAM p-nome-titular         AS CHAR NO-UNDO.
    DEF OUTPUT PARAM p-transferencia-conta  AS CHAR NO-UNDO.
    DEF OUTPUT PARAM p-poupanca             AS LOG  NO-UNDO.
       
    DEF VAR h-b1wgen0001 AS HANDLE                                    NO-UNDO.
    
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

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
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
         FIND FIRST crapass WHERE crapass.cdcooper = crapcop.cdcooper   AND
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

                  IF   NOT AVAIL craptrf THEN  
                       DO:
                           ASSIGN i-cod-erro  = 95 /*Titular da Cta Bloqueado*/
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
                           craptco.nrctaant = crapass.nrdconta  AND
                           craptco.flgativo = TRUE) THEN    
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
              RUN ver_capital IN h-b1wgen0001(INPUT  aux_cdcooper, /*crapcop.cdcooper,*/
                                              INPUT  aux_nrdconta,
                                              INPUT  p-cod-agencia,
                                              INPUT  p-nro-caixa,
                                              0,
                                              INPUT  crapdat.dtmvtocd,
                                              INPUT  "b1crap51",
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
    END. /* do while */

    IF   aux_nrtrfcta > 0   THEN 
         ASSIGN p-transferencia-conta = "Conta transferida do Numero " + 
                                        STRING(p-nro-conta,"zzzz,zzz,9") +
                                        " para o numero " +
                                        STRING(aux_nrtrfcta,"zzzz,zzz,9")
                aux_nrdconta          = aux_nrtrfcta.

    ASSIGN p-nome-titular = crapass.nmprimtl.
    IF   crapass.cdtipcta = 6   OR
         crapass.cdtipcta = 7   THEN /* Conta tipo Poupanca */
         ASSIGN p-poupanca = YES.

    IF   CAN-DO("3",STRING(crapass.cdsitdtl))   THEN
         ASSIGN  p-transferencia-conta = TRIM(p-transferencia-conta) +
                                         "*****  CONTA DESATIVADA ******".

    RETURN "OK".

END PROCEDURE.

PROCEDURE critica-cheque-valor-individual:
    DEF INPUT PARAM p-cooper       AS CHAR           NO-UNDO.
    DEF INPUT PARAM p-cod-agencia  AS INT            NO-UNDO. /* Cod. Agencia */
    DEF INPUT PARAM p-nro-caixa    AS INT FORMAT "999" NO-UNDO. /* Nro Caixa */
    DEF INPUT PARAM p-valor        AS DEC            NO-UNDO.
           
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
    DEF INPUT PARAM p-cooper         AS CHAR        NO-UNDO.
    DEF INPUT PARAM p-cod-agencia    AS INT         NO-UNDO. /* Cod. Agencia */
    DEF INPUT PARAM p-nro-caixa      AS INT FORMAT "999" NO-UNDO. /*Nro Caixa*/
    DEF INPUT PARAM p-incluir        AS LOG         NO-UNDO.
    DEF INPUT PARAM p-saldo-inf      AS DEC         NO-UNDO. /* Numero Conta */

    DEF VAR de-saldo-cheque AS DEC NO-UNDO.
    DEF VAR aux_vlrdifer    AS DEC NO-UNDO.
           
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
                    c-desc-erro = "Saldo de cheque Informado e maior ou " + 
                                  "igual Saldo dos cheque processados".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
         END.
    IF   de-saldo-cheque <> p-saldo-inf AND NOT p-incluir THEN
         DO:
             ASSIGN i-cod-erro = 710
                    aux_vlrdifer = p-saldo-inf - de-saldo-cheque   
                    c-desc-erro = "Calculado " +
                                TRIM(STRING(de-saldo-cheque,"zzz,zzz,zz9.99")) +
                                   " Diferenca de " +
                                   TRIM(STRING(aux_vlrdifer,"zzz,zzz,zz9.99-")).
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

PROCEDURE critica-cheque-cooperativa-autenticado:

    DEF INPUT PARAM p-cooper        AS CHAR NO-UNDO.
    DEF INPUT PARAM p-cod-agencia   AS INT NO-UNDO. /* Cod. Agencia    */
    DEF INPUT PARAM p-nro-caixa     AS INT FORMAT "999" NO-UNDO. /* Nro Caixa */
    DEF INPUT PARAM p-autentica     AS LOG NO-UNDO.
    DEF INPUT PARAM p-finaliza      AS LOG NO-UNDO. 

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND FIRST crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper    AND
                             crapmdw.cdagenci = p-cod-agencia       AND
                             crapmdw.nrdcaixa = p-nro-caixa         AND
                             crapmdw.cdhistor = 386  
                             NO-LOCK NO-ERROR.
                         
    IF   NOT AVAIL crapmdw AND NOT p-finaliza   THEN
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Nao existem cheques das cooperativas " + 
                                  "a autenticar".
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
                             crapmdw.nrdcaixa = p-nro-caixa         AND
                             crapmdw.cdhistor = 386                 AND
                             crapmdw.inautent = p-autentica   
                             NO-LOCK NO-ERROR.
    
    IF   p-finaliza   THEN
         DO: 
             IF   AVAIL crapmdw AND NOT p-autentica   THEN
                  DO:
                      ASSIGN i-cod-erro  = 0
                             c-desc-erro = "Faltam cheques da cooperativa a " +
                                           "serem autenticados".
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
             IF   NOT AVAIL crapmdw AND NOT p-autentica   THEN
                  DO:
                      ASSIGN i-cod-erro  = 0
                             c-desc-erro = "Nao existem cheques da " +
                                           "cooperativa a serem autenticados".
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

PROCEDURE critica-codigo-cheque-valor:
    DEF INPUT PARAM p-cooper      AS CHAR NO-UNDO.
    DEF INPUT PARAM p-cod-agencia AS INT NO-UNDO. /* Cod. Agencia       */
    DEF INPUT PARAM p-nro-caixa   AS INT FORMAT "999" NO-UNDO. /* Nro Caixa  */
    DEF INPUT PARAM p-cmc-7       AS CHAR NO-UNDO.
    DEF INPUT PARAM p-valor       AS DEC NO-UNDO.
            
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

             IF   LENGTH(p-cmc-7)      <> 34    OR
                  SUBSTR(p-cmc-7,1,1)  <> "<"   OR
                  SUBSTR(p-cmc-7,10,1) <> "<"   OR
                  SUBSTR(p-cmc-7,21,1) <> ">"   OR
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
                  
             RUN dbo/pcrap09.p (INPUT  p-cooper,
                                INPUT  p-cmc-7,
                                OUTPUT p-nro-calculado,
                                OUTPUT p-lista-digito).

             IF   p-nro-calculado              > 0  OR
                  NUM-ENTRIES(p-lista-digito) <> 3  THEN 
                  DO:
                      ASSIGN i-cod-erro  = 666
                             c-desc-erro = " ".
            
                      IF   p-nro-calculado > 1   THEN
                           ASSIGN i-cod-erro = 666.
             
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

    DEF INPUT PARAM p-cooper      AS CHAR           NO-UNDO.
    DEF INPUT PARAM p-cod-agencia AS INT            NO-UNDO. /* Cod.Agencia  */
    DEF INPUT PARAM p-nro-caixa   AS INT FORMAT "999" NO-UNDO. /* Nro Caixa */
    DEF INPUT PARAM p-valor       AS DEC            NO-UNDO.
    DEF INPUT PARAM p-dinheiro    AS DEC            NO-UNDO.
    DEF OUTPUT PARAM p-cod-erro   AS INT            NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    IF   p-valor = 0   THEN 
         DO:
             ASSIGN i-cod-erro = 269
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

    DEF INPUT PARAM p-cooper      AS CHAR NO-UNDO.
    DEF INPUT PARAM p-cod-agencia AS INT NO-UNDO. /* Cod. Agencia*/
    DEF INPUT PARAM p-nro-caixa   AS INT FORMAT "999" NO-UNDO. /* Numero Caixa*/
    DEF INPUT PARAM p-cmc-7-dig   AS CHAR NO-UNDO.

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
                           ASSIGN i-cod-erro = 841.
             
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

    DEF INPUT  PARAM p-cooper      AS CHAR                          NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia AS INT                           NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa   AS INT  FORMAT "999"             NO-UNDO.
    DEF INPUT  PARAM p-cmc-7       AS CHAR                          NO-UNDO.
    DEF INPUT  PARAM p-cmc-7-dig   AS CHAR                          NO-UNDO.
    DEF OUTPUT PARAM p-cdcmpchq    AS INT  FORMAT "zz9"             NO-UNDO.
    DEF OUTPUT PARAM p-cdbanchq    AS INT  FORMAT "zz9"             NO-UNDO.
    DEF OUTPUT PARAM p-cdagechq    AS INT  FORMAT "zzz9"            NO-UNDO.
    DEF OUTPUT PARAM p-nrddigc1    AS INT  FORMAT "9"               NO-UNDO.
    DEF OUTPUT PARAM p-nrctabdb    AS DEC  FORMAT "zzz,zzz,zzz,9"   NO-UNDO.
    DEF OUTPUT PARAM p-nrddigc2    AS INT  FORMAT "9"               NO-UNDO.
    DEF OUTPUT PARAM p-nrcheque    AS INT  FORMAT "zzz,zz9"         NO-UNDO.
    DEF OUTPUT PARAM p-nrddigc3    AS INT  FORMAT "9"               NO-UNDO.

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

    ASSIGN p-cdagechq = INT(SUBSTRING(c-cmc-7,05,04)) NO-ERROR.
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
    ASSIGN  p-cdcmpchq = INT(SUBSTR(c-cmc-7,11,03)) NO-ERROR.
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

    ASSIGN p-nrcheque = INT(SUBSTR(c-cmc-7,14,06)) NO-ERROR.
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
    ASSIGN p-nro-calculado = DEC(STRING(p-cdcmpchq,"999") +
                                 STRING(p-cdbanchq,"999") +
                                 STRING(p-cdagechq,"9999") + "0").
    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.
    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT p-nro-calculado).
    DELETE PROCEDURE h_b2crap00.
    ASSIGN p-nrddigc1 = INT(SUBSTRING(STRING(p-nro-calculado),
                                      LENGTH(STRING(p-nro-calculado)))).

    /*  Calcula segundo digito de controle  */
    IF   p-cdbanchq = 1   THEN
         ASSIGN p-nro-calculado =  p-nrctabdb  * 10.
    ELSE
         ASSIGN p-nro-calculado =  de-nrctachq * 10.

    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.
    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT p-nro-calculado).
    DELETE PROCEDURE h_b2crap00.
    ASSIGN p-nrddigc2 = INT(SUBSTR(STRING(p-nro-calculado),
                                   LENGTH(STRING(p-nro-calculado)))).

    /*  Calcula terceiro digito de controle  */

    ASSIGN p-nro-calculado = p-nrcheque * 10.

    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.
    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT p-nro-calculado).
    DELETE PROCEDURE h_b2crap00.
    ASSIGN p-nrddigc3 = 
      INT(SUBSTR(STRING(p-nro-calculado),LENGTH(STRING(p-nro-calculado)))).

    RETURN "OK".
END PROCEDURE.

PROCEDURE valida-deposito-com-captura:
    DEF INPUT PARAM  p-cooper        AS CHAR NO-UNDO.
    DEF INPUT PARAM  p-cod-agencia   AS INT NO-UNDO. /* Cod. Agencia */
    DEF INPUT PARAM  p-nro-caixa     AS INT FORMAT "999" NO-UNDO. /*Nro Cxa */
    DEF INPUT PARAM  p-cod-operador  AS CHAR NO-UNDO.
    DEF INPUT PARAM  p-cod-liberador AS CHAR NO-UNDO.
    DEF INPUT PARAM  p-cooper-dest   AS CHAR NO-UNDO.
    DEF INPUT PARAM  p-nro-conta     AS INT NO-UNDO.
    DEF INPUT PARAM  p-cmc-7         AS CHAR NO-UNDO.
    DEF INPUT PARAM  p-cmc-7-dig     AS CHAR NO-UNDO.
    DEF INPUT PARAM  p-cdcmpchq      AS INT FORMAT "zz9" NO-UNDO. /* Comp */
    DEF INPUT PARAM  p-cdbanchq      AS INT FORMAT "zz9" NO-UNDO. /* Banco */
    DEF INPUT PARAM  p-cdagechq      AS INT FORMAT "zzz9" NO-UNDO. /* Agencia */
    DEF INPUT PARAM  p-nrddigc1      AS INT FORMAT "9" NO-UNDO. /* C1 */
    DEF INPUT PARAM  p-nrctabdb      AS DEC FORMAT "zzz,zzz,zzz,9" NO-UNDO.    
    DEF INPUT PARAM  p-nrddigc2      AS INT FORMAT "9" NO-UNDO. /* C2 */
    DEF INPUT PARAM  p-nro-cheque    AS INT FORMAT "zzz,zz9" NO-UNDO. /* Chq */
    DEF INPUT PARAM  p-nrddigc3      AS INT FORMAT "9" NO-UNDO.
    DEF INPUT PARAM  p-valor         AS DEC NO-UNDO.
    DEF INPUT  PARAM p-grava-tabela  AS LOG NO-UNDO. /* Grava tabela */
    DEF OUTPUT PARAM p-transferencia-conta AS CHAR NO-UNDO.
    DEF OUTPUT PARAM p-aviso-cheque        AS CHAR NO-UNDO.
    DEF OUTPUT PARAM p-mensagem            AS CHAR NO-UNDO.
    DEF OUTPUT PARAM p-valor-disponivel    AS DEC NO-UNDO.

    DEF VAR aux_totvlchq AS DEC                                       NO-UNDO.
    DEF VAR h-b1wgen0001 AS HANDLE                                    NO-UNDO.
    DEF VAR h-b1wgen0044 AS HANDLE                                    NO-UNDO.
    
    DEF BUFFER crabcop FOR crapcop.
    DEF BUFFER cradcop FOR crapcop. /* Cooperativa Destino */

    DEF VAR aux_contlock AS INTE NO-UNDO.
    

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    /* Intercooperativa - Coop Destino */
    FIND cradcop WHERE cradcop.nmrescop = p-cooper-dest NO-LOCK NO-ERROR.


    ASSIGN p-nro-conta = DEC(REPLACE(STRING(p-nro-conta),".","")).
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
                      
    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.

    
    FIND FIRST crapage WHERE crapage.cdcooper = crapcop.cdcooper
                                                NO-LOCK NO-ERROR.
    

    ASSIGN p-aviso-cheque        = " "
           p-transferencia-conta = " "
           p-mensagem            = " ".
    
    IF  p-cmc-7 <> " "   THEN
        ASSIGN c-cmc-7              = p-cmc-7
               SUBSTR(c-cmc-7,34,1) = ":".
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
    
    RUN dbo/pcrap09.p (INPUT p-cooper,
                       INPUT c-cmc-7,
                       OUTPUT p-nro-calculado,
                       OUTPUT p-lista-digito).

    /*  Le tabela com as contas convenio do Banco do Brasil - Geral  */
        RUN fontes/ver_ctace.p(INPUT crapcop.cdcooper,
                               INPUT 0,
                               OUTPUT aux_lscontas).

    ASSIGN aux_nrdctitg = "".
    /** Conta Integracao **/
    IF  LENGTH(STRING(p-nrctabdb)) <= 8   THEN
        DO:
            ASSIGN aux_ctpsqitg = p-nrctabdb
                   glb_cdcooper = crapcop.cdcooper.
            RUN existe_conta_integracao.  
        END.   
    .
    /* Le tabela com as contas convenio do Banco do Brasil - talao normal*/
    RUN fontes/ver_ctace.p(INPUT crapcop.cdcooper,
                           INPUT 1,
                           OUTPUT aux_lsconta1).

   /*  Le tabela com as contas convenio do Banco do Brasil - talao transf.*/
    RUN fontes/ver_ctace.p(INPUT crapcop.cdcooper,
                           INPUT 2,
                           OUTPUT aux_lsconta2).

   /*  Le tabela com as contas convenio do Banco do Brasil - chq.salario */
    RUN fontes/ver_ctace.p(INPUT crapcop.cdcooper,
                           INPUT 3,
                           OUTPUT aux_lsconta3).

    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.
    ASSIGN i_conta = dec(p-nro-conta).
    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT i_conta).
    DELETE PROCEDURE h_b2crap00.

    IF  RETURN-VALUE = "NOK"   THEN
        RETURN "NOK".
    
    ASSIGN aux_nrdconta = p-nro-conta.
    ASSIGN aux_nrtrfcta = 0.

    /* Intercooperativa - Validar conta conforme destino */
    /** Valida se destino for diferente origem */
    IF  p-cooper      <> p-cooper-dest /* Via Rotina 22 */
    AND p-cooper-dest <> " "  THEN     /* Via Rotina 55 */
        ASSIGN aux_cdcooper = cradcop.cdcooper.
    ELSE
        ASSIGN aux_cdcooper = crapcop.cdcooper.


    DO  WHILE TRUE:
        /** Esta verificando sempre a conta de DESTINO (??) */
        FIND FIRST crapass WHERE crapass.cdcooper = aux_cdcooper
                             AND crapass.nrdconta = aux_nrdconta 
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
        IF   crapass.dtelimin <> ? THEN 
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
                 FIND FIRST craptrf
                      WHERE craptrf.cdcooper = aux_cdcooper
                        AND craptrf.nrdconta = crapass.nrdconta     AND
                            craptrf.tptransa = 1                    AND
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
             RUN ver_capital IN h-b1wgen0001(INPUT  aux_cdcooper,
                                             INPUT  aux_nrdconta,
                                             INPUT  p-cod-agencia,
                                             INPUT  p-nro-caixa,
                                             0,
                                             INPUT  crapdat.dtmvtocd,
                                             INPUT  "b1crap51",
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
    
    IF  aux_nrtrfcta  > 0              AND
        aux_nrdconta <> aux_nrtrfcta   THEN /* Transferencia de Conta */
        ASSIGN aux_nrdconta = aux_nrtrfcta
               p-nrctabdb   = aux_nrtrfcta.

    ASSIGN aux_cdagebcb = crapcop.cdagebcb.

    ASSIGN  i-p-nro-cheque           = p-nro-cheque  /* variaveis proc.ver_cheque */
            i-p-nrddigc3             = p-nrddigc3
            i-p-cdbanchq             = p-cdbanchq
            i-p-cdagechq             = p-cdagechq
            i-p-nrctabdb             = p-nrctabdb
            i-p-valor                = p-valor
            i-p-transferencia-conta  = " "
            i-p-aviso-cheque         = " "
            de-nrctachq              = DEC(SUBSTR(c-cmc-7,23,10)).

    RUN ver_cheque.  /* include - bo-vercheque.i */
        
    ASSIGN  p-transferencia-conta  = i-p-transferencia-conta
            p-aviso-cheque         = i-p-aviso-cheque
            p-nrctabdb             = IF i-p-transferencia-conta <> ""
                                     THEN aux_nrctcomp
                                     ELSE p-nrctabdb.
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

    IF   aux_nrctcomp > 0   THEN
         ASSIGN i-cdhistor = 386.
    ELSE
         ASSIGN i-cdhistor = 2433.

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

    IF   craphis.tpctbcxa   <> 2 AND
         craphis.tpctbcxa   <> 3   THEN
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

    EMPTY TEMP-TABLE w-compel.

    FIND FIRST craptab WHERE craptab.cdcooper = crapcop.cdcooper    AND
                             craptab.nmsistem = "CRED"              AND
                             craptab.tptabela = "USUARI"            AND
                             craptab.cdempres = 11                  AND
                             craptab.cdacesso = "MAIORESCHQ"        AND
                             craptab.tpregist = 1 
                             NO-LOCK NO-ERROR.
                             
    IF   NOT AVAIL craptab   THEN
         ASSIGN TAB_vlchqmai = 1.
    ELSE
         ASSIGN TAB_vlchqmai  = DEC(SUBSTR(craptab.dstextab,1,15)).

    IF   p-valor < tab_vlchqmai   THEN
         ASSIGN  aux_tpdmovto = 2.
    ELSE
         ASSIGN  aux_tpdmovto = 1.


    IF   CAN-FIND (crapchd WHERE crapchd.cdcooper = crapcop.cdcooper     AND
                                 crapchd.dtmvtolt = crapdat.dtmvtocd    AND
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

    FIND crapcst WHERE crapcst.cdcooper = crapcop.cdcooper AND
                       crapcst.cdcmpchq = p-cdcmpchq       AND
                       crapcst.cdbanchq = p-cdbanchq       AND
                       crapcst.cdagechq = p-cdagechq       AND
                       crapcst.nrctachq = p-nrctabdb       AND
                       crapcst.nrcheque = p-nro-cheque     AND
                       crapcst.dtdevolu = ?                AND
					   crapcst.nrborder = 0                AND
					   crapcst.dtlibera > crapdat.dtmvtoan AND
                       crapcst.insitchq = 0 /* Nao processado */
                       NO-LOCK NO-ERROR.
  

    IF  AVAILABLE crapcst  THEN
        DO:
            ASSIGN i-cod-erro  = 757 /* cheque em custodia */
                   c-desc-erro = "".
   
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
   
            
                RETURN "NOK".  
            
        END.
    
    FIND crapcdb WHERE crapcdb.cdcooper = crapcop.cdcooper  AND
                       crapcdb.cdcmpchq = p-cdcmpchq        AND
                       crapcdb.cdbanchq = p-cdbanchq        AND
                       crapcdb.cdagechq = p-cdagechq        AND
                       crapcdb.nrctachq = p-nrctabdb        AND
                       crapcdb.nrcheque = p-nro-cheque      AND
                       crapcdb.dtdevolu = ?                 AND
                       crapcdb.insitchq = 2 /*processado*/  AND         
                       crapcdb.dtlibera >= crapdat.dtmvtoan NO-LOCK NO-ERROR.

    IF  AVAILABLE crapcdb  THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Cheque esta em desconto.".
            
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            
            RETURN "NOK".
        END.
    
    CREATE w-compel.
    ASSIGN w-compel.dsdocmc7 = c-cmc-7
           w-compel.cdcmpchq = p-cdcmpchq
           w-compel.cdbanchq = p-cdbanchq
           w-compel.cdagechq = p-cdagechq
           w-compel.nrddigc1 = p-nrddigc1
           w-compel.nrctaaux = aux_nrctcomp
           w-compel.nrctachq = de-nrctachq
           w-compel.nrctabdb = p-nrctabdb
           w-compel.nrddigc2 = p-nrddigc2
           w-compel.nrcheque = p-nro-cheque
           w-compel.nrddigc3 = p-nrddigc3
           w-compel.vlcompel = p-valor
           w-compel.dtlibcom = ?
           w-compel.lsdigctr = p-lista-digito
           w-compel.tpdmovto = aux_tpdmovto
           w-compel.cdtipchq = INTE(SUBSTRING(c-cmc-7,20,1))
           w-compel.nrseqdig = 1
           w-compel.tpcheque = aux_tpcheque.
    
     /*IF   aux_nrtalchq <> 0   THEN
          ASSIGN w-compel.nrtalchq = aux_nrtalchq
                 w-compel.nrposchq = i_posicao.
     ELSE
          IF   aux_nrdocchq <> 0   THEN
               ASSIGN w-compel.nrdocmto = aux_nrdocchq.*/

    FOR EACH w-compel NO-LOCK :   /* Verifica Lancamento Existente */
        FIND FIRST crapchd WHERE crapchd.cdcooper = crapcop.cdcooper    AND
                                 crapchd.dtmvtolt = crapdat.dtmvtocd    AND
                                 crapchd.cdcmpchq = w-compel.cdcmpchq   AND
                                 crapchd.cdbanchq = w-compel.cdbanchq   AND
                                 crapchd.cdagechq = w-compel.cdagechq   AND
                                 crapchd.nrctachq = (IF aux_nrctcomp > 0 
                                                        THEN p-nrctabdb
                                                    ELSE de-nrctachq)   AND
                                 crapchd.nrcheque = w-compel.nrcheque 
                                 NO-LOCK NO-ERROR.
                                  
        IF  AVAIL crapchd THEN DO:
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

    IF  i-cdhistor <> 386 THEN DO:
              /* Verifica horario de Corte */
              FIND FIRST craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                                       craptab.nmsistem = "CRED"            AND
                                       craptab.tptabela = "GENERI"          AND
                                       craptab.cdempres = 0                 AND
                                       craptab.cdacesso = "HRTRCOMPEL"      AND
                                       craptab.tpregist = p-cod-agencia  
                                       NO-LOCK NO-ERROR.
                                       
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
    END.    /* Verifica Horario de Corte */
    ELSE DO:
        /** Validacao Dep. Intercooperativas
             Valida conta apenas se Mesma Coop */
        /** Coop Dest " " quando mesma coop    */
        IF  p-cooper-dest = " "  THEN
            IF  p-nro-conta = aux_nrctcomp THEN DO:

                ASSIGN i-cod-erro = 758
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

     ASSIGN dt-liberacao    = ?
            dt-menor-praca  = ?
            dt-maior-praca  = ?
            dt-menor-fpraca = ?
            dt-maior-fpraca = ?.
     
     ASSIGN i-digito =  0.
     
     IF   p-grava-tabela = YES   THEN 
          DO:
              ASSIGN i-digito = 1.
              FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper    AND
                                     crapmdw.cdagenci = p-cod-agencia       AND
                                     crapmdw.nrdcaixa = p-nro-caixa 
                                     NO-LOCK BREAK BY crapmdw.nrseqdig:
                  IF   LAST(crapmdw.nrseqdig)   THEN
                       ASSIGN i-digito = crapmdw.nrseqdig + 1.

                  /* Tentar 10x */
                  DO aux_contlock = 1 TO 10:
                      
                  /* verifica se o cheque eh da cooperativa acolhedora(HOST)*/ 
                  FIND crabfdc WHERE crabfdc.cdcooper = crapmdw.cdcooper   AND
                                     crabfdc.cdbanchq = crapmdw.cdbanchq   AND
                                     crabfdc.cdagechq = crapmdw.cdagechq   AND
                                     crabfdc.nrctachq = crapmdw.nrctachq   AND
                                     crabfdc.nrcheque = crapmdw.nrcheque
                                       USE-INDEX crapfdc1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                         
                    IF  NOT AVAIL crabfdc  THEN 
                      DO:         
                      IF  LOCKED(crabfdc) THEN
                      DO:
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = "Registro de cheque esta em uso no momento.".
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                      END.
                      ELSE
                      DO: /* not avail */
                        IF  crapmdw.cdbanchq = 85 THEN
                        DO:
                          FIND crabcop WHERE 
                               crabcop.cdagectl = crapmdw.cdagechq  NO-LOCK NO-ERROR.

                          IF  AVAIL crabcop THEN
                          DO:
                            /* verifica se a conta do cheque migrou para a
                             cooperativa acolhedora do deposito */
                            FIND craptco WHERE craptco.cdcooper = crapmdw.cdcooper AND
                                               craptco.nrctaant = crapmdw.nrctachq AND
                                               craptco.cdcopant = crabcop.cdcooper AND
                                            craptco.tpctatrf = 1                AND
                                            craptco.flgativo = TRUE
                                            NO-LOCK NO-ERROR.
                                         
                         IF  AVAIL craptco  THEN
                             DO:  
                                  ASSIGN i-cod-erro  = 0        
                                         c-desc-erro = "ATENÇAO, esse deposito pode conter apenas cheques de " +
                                                   "contas migradas para a cooperativa " + crapcop.nmrescop + ". " + 
                                                       "Efetue um deposito separado, caso possui " +
                                                       "cheques da " + crapcop.nmrescop + " ou de Bancos.".
                                                       
                                  RUN cria-erro (INPUT p-cooper,
                                                 INPUT p-cod-agencia,
                                                 INPUT p-nro-caixa,
                                                 INPUT i-cod-erro,
                                                 INPUT c-desc-erro,
                                                 INPUT YES).
                                  
                                  RETURN "NOK".
                             END.       
                      END.
                        END. /* IF rapmdw.cdbanchq = 85 */                          

                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = "".
                        LEAVE.

                      END. /* nao existe e nao locked*/
                    END.  
                    ELSE 
                    DO: /* AVAIL */
                      /* verifica se a conta do cheque migrou para outra cooperativa */
                      FIND craptco WHERE craptco.cdcopant = crabfdc.cdcooper AND
                                         craptco.nrctaant = crabfdc.nrdconta AND
                                                              craptco.tpctatrf = 1                AND
                                                              craptco.flgativo = TRUE
                                                              NO-LOCK NO-ERROR.
                                           IF  AVAIL craptco  THEN
                                               DO:  
                        FIND crabcop WHERE crabcop.cdcooper = craptco.cdcooper NO-LOCK NO-ERROR.

                                                   ASSIGN i-cod-erro  = 0        
                                                           c-desc-erro = "ATENÇAO, esse deposito pode conter apenas cheques de " +
                                             "contas migradas para a cooperativa " + crabcop.nmrescop + ". " + 
                                                                         "Efetue um deposito separado, caso possui " +
                                                                         "cheques da " + crapcop.nmrescop + " ou de Bancos.".
                                                                       
                                                   RUN cria-erro (INPUT p-cooper,
                                                                  INPUT p-cod-agencia,
                                                                  INPUT p-nro-caixa,
                                                                  INPUT i-cod-erro,
                                                                  INPUT c-desc-erro,
                                                                  INPUT YES).
                                                    
                                                   RETURN "NOK".

                                               END. 
                    END. /* avail */
                  
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "".
                    LEAVE.

                  END. /* fim contador */

              END. /* for each */


              DO aux_contlock = 1 TO 10:
              FIND FIRST crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper  AND
                                       crapmdw.cdagenci = p-cod-agencia     AND
                                       crapmdw.nrdcaixa = p-nro-caixa       AND
                                       crapmdw.nrctabdb = p-nrctabdb        AND
                                       crapmdw.nrcheque = p-nro-cheque 
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                IF NOT AVAILABLE crapmdw THEN
                DO:
                  IF LOCKED(crapmdw) THEN
                  DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Registro crapmdw esta em uso no momento. Deposito com captura.".
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                  END.
                  ELSE /* nao existe, criar */
                   DO:
                       CREATE crapmdw.
                       ASSIGN crapmdw.cdcooper  = crapcop.cdcooper
                              crapmdw.cdagenci  = p-cod-agencia
                              crapmdw.nrdcaixa  = p-nro-caixa
                              crapmdw.nrctabdb  = p-nrctabdb
                              crapmdw.nrcheque  = p-nro-cheque.
                   END.
                END.

                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "".
                LEAVE.

              END. /* end contador */

              /* Instanciar a BO que fara o calculo do bloqueio do cheque */
              RUN sistema/generico/procedures/b1wgen0044.p 
                  PERSISTENT SET h-b1wgen0044.
              
              IF  NOT VALID-HANDLE(h-b1wgen0044)  THEN
                  DO:
                      ASSIGN i-cod-erro  = 0
                             c-desc-erro = "Handle invalido para h-b1wgen0044".
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                          
                      RETURN "NOK".
                  END.              
              
              RUN calcula_bloqueio_cheque IN h-b1wgen0044
                                          (INPUT crapcop.cdcooper,
                                          INPUT crapdat.dtmvtocd,
                                           INPUT p-cod-agencia,
                                           INPUT p-cdbanchq,
                                           INPUT p-cdagechq,
                                           INPUT p-valor,
                                           OUTPUT dt-liberacao,
                                           OUTPUT TABLE tt-erro).

              /* Remover a instancia da b1wgen0044 da memoria */
              DELETE PROCEDURE h-b1wgen0044.
              
              FIND LAST tt-erro NO-LOCK NO-ERROR.
              
              IF  RETURN-VALUE = "NOK"  THEN
                  DO:
                      FIND LAST tt-erro NO-LOCK NO-ERROR.
                      IF  AVAIL tt-erro THEN
                          ASSIGN c-desc-erro = tt-erro.dscritic
                                 i-cod-erro  = tt-erro.cdcritic.
                      ELSE
                          c-desc-erro = "Erro no calculo do " +
                                        "bloqueio do cheque".
                      
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                        
                      RETURN "NOK".
                  END.
                  

              ASSIGN crapmdw.nrdconta = p-nro-conta
                     crapmdw.cdopecxa = p-cod-operador
                     crapmdw.cdopelib = p-cod-liberador
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
                     crapmdw.nrddigc3 = p-nrddigc3            /* Digito */
                     crapmdw.vlcompel = p-valor              /* Valor  */
                     crapmdw.dtlibcom = dt-liberacao
                     crapmdw.lsdigctr = p-lista-digito
                     crapmdw.tpdmovto = aux_tpdmovto
                     crapmdw.nrseqdig = i-digito
                     crapmdw.cdtipchq = INTE(SUBSTRING(c-cmc-7,20,1)).
              
              IF   aux_nrtalchq <> 0   THEN
                   ASSIGN crapmdw.nrtalchq = aux_nrtalchq
                          crapmdw.nrposchq = i_posicao.
              
              /* antiga separaçao: 3-Menor Praca,4-Maior Praca,5-Menor Fora Praca,6-Maior Fora Praca */
              IF crapmdw.cdhistor = 2433 THEN
                           ASSIGN crapmdw.nrdocmto = 6.

              RELEASE crapmdw.

          END.  /* Grava Tabela */
    
                    
    IF  i-cdhistor = 386   THEN 
        DO:   /* Cheque Cooperativa */
            
            RUN dbo/b1crap02.p PERSISTENT SET h-b1crap02.

            RUN consulta-conta IN h-b1crap02(INPUT p-cooper,
                                             INPUT p-cod-agencia,
                                             INPUT p-nro-caixa,
                                             INPUT aux_nrctcomp,
                                             OUTPUT TABLE tt-conta).
            DELETE PROCEDURE h-b1crap02.

            IF  RETURN-VALUE = "NOK"   THEN
                RETURN "NOK".

            ASSIGN de-valor-libera = 0.
            FIND FIRST tt-conta NO-LOCK NO-ERROR.
            IF  AVAIL tt-conta   THEN  
                DO:
                    IF  tt-conta.cheque-salario = 0   THEN
                        DO:
                            ASSIGN de-valor-bloqueado = 
                                            tt-conta.bloqueado      +
                                            tt-conta.bloq-praca     +
                                            tt-conta.bloq-fora-praca
                                   de-valor-liberado = 
                                            tt-conta.acerto-conta   -
                                            de-valor-bloqueado.
                                                       
                            ASSIGN  aux_totvlchq = 0
                                    i-digito     = 0.
                            /**Contabiliza os cheques que entram em conjunto**/ 
                            
                            FOR EACH crapmdw WHERE 
                                     crapmdw.cdcooper = crapcop.cdcooper    AND
                                     crapmdw.cdagenci = p-cod-agencia       AND
                                     crapmdw.nrdcaixa = p-nro-caixa         AND
                                     crapmdw.nrctabdb = p-nrctabdb
                                     NO-LOCK:
                         
                                ASSIGN  i-digito     = i-digito     + 1
                                        aux_totvlchq = dec(aux_totvlchq) +
                                                       dec(crapmdw.vlcompel).
                                
                            END.
                            
                            IF  ((de-valor-liberado + tt-conta.limite-credito) < aux_totvlchq)  THEN
                                DO:
                                
                            /*--- Anterior
                            IF  tt-conta.acerto-conta + 
                                tt-conta.limite-credito < p-valor THEN
                                DO:
                            --*/
                
                            /*--- Nao considera CPMF e considera limite ---
                            IF  tt-conta.disponivel + tt-conta.limite-credito <
                                p-valor THEN
                                DO:
                                    ASSIGN de-valor = 
                                                tt-conta.disponivel          +
                                                tt-conta.limite-credito
                                           p-valor-disponivel =                                                                  de-valor
                                           de-valor-libera =
                                              ((tt-conta.disponivel          +
                                                tt-conta.limite-credito)     -
                                                p-valor) * -1
                                           p-mensagem = 
                                                "Nao existe Saldo "          +
                                                "Disponivel.. "              +
                                                TRIM(STRING(de-valor,
                                                     "zzz,zzz,zzz,zz9.99-")) +
                                                "  Excedido.. " + 
                                                TRIM(STRING(de-valor-libera,
                                                     "zzz,zzz,zzz,zz9.99-")).
                            -------------------------------------*/
                            
                                    /*--- Anterior
                                    ASSIGN p-valor-disponivel = 
                                                tt-conta.acerto-conta         + 
                                                tt-conta.limite-credito
                                           de-valor-libera    = 
                                               (tt-conta.acerto-conta         - 
                                                p-valor) * -1
                                           p-mensagem = 
                                                "Saldo.. "                    +
                                                TRIM(STRING(
                                                     tt-conta.acerto-conta,
                                                     "zzz,zzz,zzz,zz9.99-"))  +
                                                "  Limite Credito.. "         +
                                                TRIM(STRING(
                                                     tt-conta.limite-credito,"
                                                     zzz,zzz,zzz,zz9.99-"))   +
                                                "  EXCEDIDO.. "               + 
                                                TRIM(STRING(de-valor-libera,
                                                     "zzz,zzz,zzz,zz9.99-")).
                                    -------------------*/            
                                    
                                    IF  p-grava-tabela = TRUE THEN
                                        DO:
                                          de-valor-libera    = 
                                                 (de-valor-liberado - 
                                                  aux_totvlchq) * -1.
                                        END.
                                    ELSE
                                        DO:
                                             de-valor-libera    = 
                                                 (de-valor-liberado - 
                                                  p-valor - aux_totvlchq) * -1.
                                        END.
                                    
                                    
                                        ASSIGN p-valor-disponivel =  
                                                de-valor-liberado             + 
                                                tt-conta.limite-credito
                                       /*  de-valor-libera    = 
                                                 (de-valor-liberado - 
                                                  p-valor - aux_totvlchq) * -1  */
                                        
                                           p-mensagem         = 
                                                "Saldo "                      +
                                                TRIM(STRING(de-valor-liberado,
                                                     "zzz,zzz,zzz,zz9.99-"))  + 
                                                " Limite "                    +
                                                TRIM(STRING(
                                                     tt-conta.limite-credito,
                                                     "zzz,zzz,zzz,zz9.99-"))  +
                                                " Excedido "                  + 
                                                TRIM(STRING(de-valor-libera,
                                                     "zzz,zzz,zzz,zz9.99-"))  +
                                                " Bloq. "                     + 
                                                TRIM(STRING(de-valor-bloqueado,
                                                     "zzz,zzz,zzz,zz9.99-"))
                                           p-aviso-cheque = p-aviso-cheque + 
                                                     " Cheques " +
                                                 TRIM(STRING(i-digito)) +
                                                     " Valor " + 
                                                 TRIM(STRING((aux_totvlchq ),
                                                      "zzz,zzz,zzz,zz9.99-")).
                                          
                                END. /* IF  de-valor-liberado + */
                                
                        END. /* IF  tt-conta.cheque-salario = 0  */
                            
                END. /* IF  AVAIL tt-conta */
                   
        END. /* IF  i-cdhistor = 386 */
        
    RETURN "OK".
    
END PROCEDURE.

PROCEDURE valida-deposito-com-captura-migrado-host:
    DEF INPUT PARAM  p-cooper        AS CHAR NO-UNDO.
    DEF INPUT PARAM  p-nmcooper      AS CHAR NO-UNDO.
    DEF INPUT PARAM  p-cod-agencia   AS INT NO-UNDO. /* Cod. Agencia */
    DEF INPUT PARAM  p-nro-caixa     AS INT FORMAT "999" NO-UNDO. /*Nro Cxa */
    DEF INPUT PARAM  p-cod-operador  AS CHAR NO-UNDO.
    DEF INPUT PARAM  p-cod-liberador AS CHAR NO-UNDO.
    DEF INPUT PARAM  p-cooper-dest   AS CHAR NO-UNDO.
    DEF INPUT PARAM  p-nro-conta     AS INT NO-UNDO.
    DEF INPUT PARAM  p-cmc-7         AS CHAR NO-UNDO.
    DEF INPUT PARAM  p-cmc-7-dig     AS CHAR NO-UNDO.
    DEF INPUT PARAM  p-cdcmpchq      AS INT FORMAT "zz9" NO-UNDO. /* Comp */
    DEF INPUT PARAM  p-cdbanchq      AS INT FORMAT "zz9" NO-UNDO. /* Banco */
    DEF INPUT PARAM  p-cdagechq      AS INT FORMAT "zzz9" NO-UNDO. /* Agencia */
    DEF INPUT PARAM  p-nrddigc1      AS INT FORMAT "9" NO-UNDO. /* C1 */
    DEF INPUT PARAM  p-nrctabdb      AS DEC FORMAT "zzz,zzz,zzz,9" NO-UNDO.    
    DEF INPUT PARAM  p-nrddigc2      AS INT FORMAT "9" NO-UNDO. /* C2 */
    DEF INPUT PARAM  p-nro-cheque    AS INT FORMAT "zzz,zz9" NO-UNDO. /* Chq */
    DEF INPUT PARAM  p-nrddigc3      AS INT FORMAT "9" NO-UNDO.
    DEF INPUT PARAM  p-valor         AS DEC NO-UNDO.
    DEF INPUT  PARAM p-grava-tabela  AS LOG NO-UNDO. /* Grava tabela */
    DEF INPUT PARAM p-nro-conta-nova AS INT NO-UNDO.
    DEF INPUT PARAM p-nro-conta-anti AS INT NO-UNDO.
    DEF OUTPUT PARAM p-transferencia-conta AS CHAR NO-UNDO.
    DEF OUTPUT PARAM p-aviso-cheque        AS CHAR NO-UNDO.
    DEF OUTPUT PARAM p-mensagem            AS CHAR NO-UNDO.
    DEF OUTPUT PARAM p-valor-disponivel    AS DEC NO-UNDO.
    
    DEF VAR aux_totvlchq AS DEC         FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
    DEF VAR h-b1wgen0001 AS HANDLE                                    NO-UNDO.
    DEF VAR h-b1wgen0044 AS HANDLE                                    NO-UNDO.

    DEF VAR tt-disponivel        AS DEC FORMAT "zzz,zzz,zzz,zz9.99-"   NO-UNDO.
    DEF VAR tt-bloqueado         AS DEC FORMAT "zzz,zzz,zzz,zz9.99-"   NO-UNDO.
    DEF VAR tt-bloq-praca        AS DEC FORMAT "zzz,zzz,zzz,zz9.99-"   NO-UNDO.
    DEF VAR tt-bloq-fora-praca   AS DEC FORMAT "zzz,zzz,zzz,zz9.99-"   NO-UNDO.
    DEF VAR tt-acerto-conta      AS DEC FORMAT "zzz,zzz,zzz,zz9.99-"   NO-UNDO.
    DEF VAR tt-limite-credito    AS DEC                                NO-UNDO.

    DEF VAR tab_dtinipmf   AS DATE                          NO-UNDO.
    DEF VAR tab_dtfimpmf   AS DATE                          NO-UNDO.
    DEF VAR tab_txcpmfcc   AS DEC                           NO-UNDO.
    DEF VAR tab_txrdcpmf   AS DEC                           NO-UNDO.
    DEF VAR aux_indoipmf   AS INT                           NO-UNDO.
    DEF VAR aux_vlipmfap   AS DEC                           NO-UNDO.
    DEF VAR aux_txdoipmf   AS DEC                           NO-UNDO.
    DEF VAR aux_vlestorn   AS DEC                           NO-UNDO.
    DEF VAR aux_vlestabo   AS DEC                           NO-UNDO.
    DEF VAR tab_txiofapl   AS DEC FORMAT "zzzzzzzz9,999999" NO-UNDO.

    DEF BUFFER crabcop FOR crapcop.
    DEF BUFFER cradcop FOR crapcop. /* Cooperativa Destino */

    DEF VAR aux_contlock AS INTE NO-UNDO.

    /* cooperativa antiga */
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    
    /* cooperativa nova */
    FIND crabcop WHERE crabcop.nmrescop = p-nmcooper NO-LOCK NO-ERROR.

    /* Intercooperativa - Coop Destino */
    FIND cradcop WHERE cradcop.nmrescop = p-cooper-dest NO-LOCK NO-ERROR.


    ASSIGN p-nro-conta = DEC(REPLACE(STRING(p-nro-conta),".","")).
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
                      
    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.

    
    FIND FIRST crapage WHERE crapage.cdcooper = crapcop.cdcooper
                                                NO-LOCK NO-ERROR.
                                                
    ASSIGN p-aviso-cheque        = " "
           p-transferencia-conta = " "
           p-mensagem            = " ".
    
    IF  p-cmc-7 <> " "   THEN
        ASSIGN c-cmc-7              = p-cmc-7
               SUBSTR(c-cmc-7,34,1) = ":".
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

    RUN dbo/pcrap09.p (INPUT p-cooper,
                       INPUT c-cmc-7,
                       OUTPUT p-nro-calculado,
                       OUTPUT p-lista-digito).

    /*  Le tabela com as contas convenio do Banco do Brasil - Geral  */
        RUN fontes/ver_ctace.p(INPUT crapcop.cdcooper,
                               INPUT 0,
                               OUTPUT aux_lscontas).

    ASSIGN aux_nrdctitg = "".
    /** Conta Integracao **/
    IF  LENGTH(STRING(p-nrctabdb)) <= 8   THEN
        DO:
            ASSIGN aux_ctpsqitg = p-nrctabdb
                   glb_cdcooper = crapcop.cdcooper.
            RUN existe_conta_integracao.  
        END.   

    /* Le tabela com as contas convenio do Banco do Brasil - talao normal*/
        RUN fontes/ver_ctace.p(INPUT crapcop.cdcooper,
                               INPUT 1,
                               OUTPUT aux_lsconta1).
    
  /*  Le tabela com as contas convenio do Banco do Brasil - talao transf.*/
        RUN fontes/ver_ctace.p(INPUT crapcop.cdcooper,
                               INPUT 2,
                               OUTPUT aux_lsconta2).
    
  /*  Le tabela com as contas convenio do Banco do Brasil - chq.salario */
        RUN fontes/ver_ctace.p(INPUT crapcop.cdcooper,
                               INPUT 3,
                               OUTPUT aux_lsconta3).

    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.
    ASSIGN i_conta = dec(p-nro-conta).
    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT i_conta).
    DELETE PROCEDURE h_b2crap00.

    IF  RETURN-VALUE = "NOK"   THEN
        RETURN "NOK".
    
    ASSIGN aux_nrdconta = p-nro-conta.
    ASSIGN aux_nrtrfcta = 0.

    /* Intercooperativa - Validar conta conforme destino */
    /** Valida se destino for diferente origem */
    IF  p-cooper      <> p-cooper-dest /* Via Rotina 22 */
    AND p-cooper-dest <> " "  THEN     /* Via Rotina 55 */
        ASSIGN aux_cdcooper = cradcop.cdcooper.
    ELSE
        ASSIGN aux_cdcooper = crapcop.cdcooper.


    DO  WHILE TRUE:
        /** Esta verificando sempre a conta de DESTINO (??) */
        FIND FIRST crapass WHERE crapass.cdcooper = aux_cdcooper
                             AND crapass.nrdconta = aux_nrdconta
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
        IF   crapass.dtelimin <> ? THEN 
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
        
        RUN sistema/generico/procedures/b1wgen0001.p
            PERSISTENT SET h-b1wgen0001.

        IF   VALID-HANDLE(h-b1wgen0001)   THEN
        DO:
             RUN ver_capital IN h-b1wgen0001(INPUT  aux_cdcooper,
                                             INPUT  aux_nrdconta,
                                             INPUT  p-cod-agencia,
                                             INPUT  p-nro-caixa,
                                             0,
                                             INPUT  crapdat.dtmvtocd,
                                             INPUT  "b1crap51",
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

    IF  aux_nrtrfcta  > 0              AND
        aux_nrdconta <> aux_nrtrfcta   THEN /* Transferencia de Conta */
        ASSIGN aux_nrdconta = aux_nrtrfcta
               p-nrctabdb   = aux_nrtrfcta.

    ASSIGN aux_cdagebcb = crapcop.cdagebcb.

    ASSIGN  i-p-nro-cheque           = p-nro-cheque  /* variaveis proc.ver_cheque */
            i-p-nrddigc3             = p-nrddigc3
            i-p-cdbanchq             = p-cdbanchq
            i-p-cdagechq             = p-cdagechq
            i-p-nrctabdb             = p-nrctabdb
            i-p-valor                = p-valor
            i-p-transferencia-conta  = " "
            i-p-aviso-cheque         = " "
            de-nrctachq              = DEC(SUBSTR(c-cmc-7,23,10)).

    RUN ver_cheque_migrado.  /* include - bo-vercheque.i */
        
    ASSIGN  p-transferencia-conta  = i-p-transferencia-conta
            p-aviso-cheque         = i-p-aviso-cheque
            p-nrctabdb             = IF i-p-transferencia-conta <> ""
                                     THEN aux_nrctcomp
                                     ELSE p-nrctabdb.
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

    IF   aux_nrctcomp > 0   THEN
         ASSIGN i-cdhistor = 386.
    ELSE
         ASSIGN i-cdhistor = 2433.

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

    IF   craphis.tpctbcxa   <> 2 AND
         craphis.tpctbcxa   <> 3   THEN
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

    EMPTY TEMP-TABLE w-compel.

    FIND FIRST craptab WHERE craptab.cdcooper = crapcop.cdcooper    AND
                             craptab.nmsistem = "CRED"              AND
                             craptab.tptabela = "USUARI"            AND
                             craptab.cdempres = 11                  AND
                             craptab.cdacesso = "MAIORESCHQ"        AND
                             craptab.tpregist = 1 
                             NO-LOCK NO-ERROR.
                             
    IF   NOT AVAIL craptab   THEN
         ASSIGN TAB_vlchqmai = 1.
    ELSE
         ASSIGN TAB_vlchqmai  = DEC(SUBSTR(craptab.dstextab,1,15)).

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

    FIND crapcst WHERE crapcst.cdcooper = crapcop.cdcooper AND
                       crapcst.cdcmpchq = p-cdcmpchq       AND
                       crapcst.cdbanchq = p-cdbanchq       AND
                       crapcst.cdagechq = p-cdagechq       AND
                       crapcst.nrctachq = p-nrctabdb       AND
                       crapcst.nrcheque = p-nro-cheque     AND
                       crapcst.dtdevolu = ?                AND
					   crapcst.nrborder = 0                AND 
					   crapcst.dtlibera > crapdat.dtmvtoan AND
                       crapcst.insitchq = 0 /* Nao processado */
                       NO-LOCK NO-ERROR.
   
    IF  AVAILABLE crapcst  THEN
        DO:
            ASSIGN i-cod-erro  = 757 /* cheque em custodia */
                   c-desc-erro = "".
   
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            
            RETURN "NOK".      
        END.
    
    FIND crapcdb WHERE crapcdb.cdcooper = crapcop.cdcooper  AND
                       crapcdb.cdcmpchq = p-cdcmpchq        AND
                       crapcdb.cdbanchq = p-cdbanchq        AND
                       crapcdb.cdagechq = p-cdagechq        AND
                       crapcdb.nrctachq = p-nrctabdb        AND
                       crapcdb.nrcheque = p-nro-cheque      AND
                       crapcdb.dtdevolu = ?                 AND
                       crapcdb.insitchq = 2 /*processado*/  AND         
                       crapcdb.dtlibera >= crapdat.dtmvtoan NO-LOCK NO-ERROR.

    IF  AVAILABLE crapcdb  THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Cheque esta em desconto.".
            
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            
            RETURN "NOK".
        END.
    
    CREATE w-compel.
    ASSIGN w-compel.dsdocmc7 = c-cmc-7
           w-compel.cdcmpchq = p-cdcmpchq
           w-compel.cdbanchq = p-cdbanchq
           w-compel.cdagechq = p-cdagechq
           w-compel.nrddigc1 = p-nrddigc1
           w-compel.nrctaaux = aux_nrctcomp
           w-compel.nrctachq = de-nrctachq
           w-compel.nrctabdb = p-nrctabdb
           w-compel.nrddigc2 = p-nrddigc2
           w-compel.nrcheque = p-nro-cheque
           w-compel.nrddigc3 = p-nrddigc3
           w-compel.vlcompel = p-valor
           w-compel.dtlibcom = ?
           w-compel.lsdigctr = p-lista-digito
           w-compel.tpdmovto = aux_tpdmovto
           w-compel.cdtipchq = INTE(SUBSTRING(c-cmc-7,20,1))
           w-compel.nrseqdig = 1
           w-compel.tpcheque = aux_tpcheque.

     /*IF   aux_nrtalchq <> 0   THEN
          ASSIGN w-compel.nrtalchq = aux_nrtalchq
                 w-compel.nrposchq = i_posicao.
     ELSE
          IF   aux_nrdocchq <> 0   THEN
               ASSIGN w-compel.nrdocmto = aux_nrdocchq.*/

     FOR EACH w-compel NO-LOCK :   /* Verifica Lancamento Existente */
         FIND FIRST crapchd WHERE crapchd.cdcooper = crapcop.cdcooper    AND
                                  crapchd.dtmvtolt = crapdat.dtmvtocd    AND
                                  crapchd.cdcmpchq = w-compel.cdcmpchq   AND
                                  crapchd.cdbanchq = w-compel.cdbanchq   AND
                                  crapchd.cdagechq = w-compel.cdagechq   AND
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

     IF   i-cdhistor <> 386   THEN 
          DO:
              /* Verifica horario de Corte */
              FIND FIRST craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                                       craptab.nmsistem = "CRED"            AND
                                       craptab.tptabela = "GENERI"          AND
                                       craptab.cdempres = 0                 AND
                                       craptab.cdacesso = "HRTRCOMPEL"      AND
                                       craptab.tpregist = p-cod-agencia  
                                       NO-LOCK NO-ERROR.
                                       
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
    END.    /* Verifica Horario de Corte */
    ELSE DO:
        /** Validacao Dep. Intercooperativas
             Valida conta apenas se Mesma Coop */
        /** Coop Dest " " quando mesma coop    */
        IF  p-cooper-dest = " "  THEN
            IF  p-nro-conta = aux_nrctcomp THEN DO:

                ASSIGN i-cod-erro = 758
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

     ASSIGN dt-liberacao    = ?
            dt-menor-praca  = ?
            dt-maior-praca  = ?
            dt-menor-fpraca = ?
            dt-maior-fpraca = ?.
     
     ASSIGN i-digito =  0.
     
     IF   p-grava-tabela = YES   THEN 
          DO:
              ASSIGN i-digito = 1.
              FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper    AND
                                     crapmdw.cdagenci = p-cod-agencia       AND
                                     crapmdw.nrdcaixa = p-nro-caixa 
                                     NO-LOCK BREAK BY crapmdw.nrseqdig:
                  IF   LAST(crapmdw.nrseqdig)   THEN
                       ASSIGN i-digito = crapmdw.nrseqdig + 1.

                DO aux_contlock = 1 TO 10:
                  
                  /* verifica se o cheque eh da cooperativa acolhedora
                     do deposito */
                  FIND crabfdc WHERE crabfdc.cdcooper = crapmdw.cdcooper   AND
                                     crabfdc.cdbanchq = crapmdw.cdbanchq   AND
                                     crabfdc.cdagechq = crapmdw.cdagechq   AND
                                     crabfdc.nrctachq = crapmdw.nrctachq   AND
                                     crabfdc.nrcheque = crapmdw.nrcheque
                                     USE-INDEX crapfdc1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                 
                  IF NOT AVAILABLE crabfdc THEN
                  DO:
                    IF LOCKED(crabfdc) THEN
                      DO:          
                      ASSIGN i-cod-erro  = 0
                             c-desc-erro = "Registro de cheque esta em uso no momento.".
                      PAUSE 1 NO-MESSAGE.
                      NEXT.
                    END.    
                    ELSE
                    DO: /* not avail */
                      ASSIGN i-cod-erro  = 0
                             c-desc-erro = "ATENÇAO, esse deposito nao pode conter cheques de contas " +
                                           "migradas para a cooperativa " + crabcop.nmrescop + ". Efetue um " + 
                                           "novo deposito na rotina 51, apenas com cheques da " + crabcop.nmrescop + ".".

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
                  DO: /* avail */
                         /* verifica se a conta do cheque migrou para outra
                            cooperativa */
                         FIND craptco WHERE craptco.cdcopant = crabfdc.cdcooper AND
                                            craptco.nrctaant = crabfdc.nrdconta AND
                                            craptco.tpctatrf = 1                AND
                                            craptco.flgativo = TRUE
                                            NO-LOCK NO-ERROR.
                         IF  NOT AVAIL craptco  THEN
                             DO: 
                                  ASSIGN   i-cod-erro  = 0       
                                           c-desc-erro = "ATENÇAO, esse deposito nao pode conter cheques de contas " +
                                                         "migradas para a cooperativa " + crabcop.nmrescop + ". Efetue um " + 
                                                         "novo deposito na rotina 51, apenas com cheques da " + crabcop.nmrescop + ".".
                                  
                                  RUN cria-erro (INPUT p-cooper,
                                                 INPUT p-cod-agencia,
                                                 INPUT p-nro-caixa,
                                                 INPUT i-cod-erro,
                                                 INPUT c-desc-erro,
                                                 INPUT YES).
                                  
                                  RETURN "NOK".
                             END.
                      END.

                  ASSIGN i-cod-erro  = 0
                         c-desc-erro = "".
                  LEAVE.

                END. /* fim contador */

                IF i-cod-erro <> 0 OR 
                   c-desc-erro <> "" THEN
                      DO: 
                              RUN cria-erro (INPUT p-cooper,
                                             INPUT p-cod-agencia,
                                             INPUT p-nro-caixa,
                                             INPUT i-cod-erro,
                                             INPUT c-desc-erro,
                                             INPUT YES).
                              RETURN "NOK".
                END.
    

              END. /* fim for each */
                         
              
              DO aux_contlock = 1 TO 10:
              FIND FIRST crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper  AND
                                       crapmdw.cdagenci = p-cod-agencia     AND
                                       crapmdw.nrdcaixa = p-nro-caixa       AND
                                       crapmdw.nrctabdb = p-nrctabdb        AND
                                       crapmdw.nrcheque = p-nro-cheque 
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                IF NOT AVAIL crapmdw   THEN 
                DO:
                  IF LOCKED(crapmdw) THEN
                   DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Registro crapmdw esta em uso no momento.".
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                  END.
                  ELSE
                  DO: /* not avail */
                       CREATE crapmdw.
                       ASSIGN crapmdw.cdcooper  = crapcop.cdcooper
                              crapmdw.cdagenci  = p-cod-agencia
                              crapmdw.nrdcaixa  = p-nro-caixa
                              crapmdw.nrctabdb  = p-nrctabdb
                              crapmdw.nrcheque  = p-nro-cheque.
                   END.
                END.

                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "".
                LEAVE.
              END. /* fim contador */

              IF i-cod-erro <> 0 OR 
                 c-desc-erro <> "" THEN
              DO:
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).                      
                RETURN "NOK".
              END.


              /* Instanciar a BO que fara o calculo do bloqueio do cheque */
              RUN sistema/generico/procedures/b1wgen0044.p 
                  PERSISTENT SET h-b1wgen0044.
              
              IF  NOT VALID-HANDLE(h-b1wgen0044)  THEN
                  DO:
                      ASSIGN i-cod-erro  = 0
                             c-desc-erro = "Handle invalido para h-b1wgen0044".
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      
                      RETURN "NOK".
              
                  END.              
                    
              RUN calcula_bloqueio_cheque IN h-b1wgen0044
                                          (INPUT crapcop.cdcooper,
                                           INPUT crapdat.dtmvtocd,
                                           INPUT p-cod-agencia,
                                           INPUT p-cdbanchq,
                                           INPUT p-cdagechq,
                                           INPUT p-valor,
                                           OUTPUT dt-liberacao,
                                           OUTPUT TABLE tt-erro).

              /* Remover a instancia da b1wgen0044 da memoria */
              DELETE PROCEDURE h-b1wgen0044.
              
              IF  RETURN-VALUE = "NOK"  THEN
                  DO:
                      FIND LAST tt-erro NO-LOCK NO-ERROR.
                      IF  AVAIL tt-erro THEN
                          ASSIGN c-desc-erro = tt-erro.dscritic
                                 i-cod-erro  = tt-erro.cdcritic.
                      ELSE
                          c-desc-erro = "Erro no calculo do " +
                                        "bloqueio do cheque".
                      
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      
                      RETURN "NOK".
                  END.
                  
              
              ASSIGN crapmdw.nrdconta = p-nro-conta
                     crapmdw.cdopecxa = p-cod-operador
                     crapmdw.cdopelib = p-cod-liberador
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
                     crapmdw.nrddigc3 = p-nrddigc3            /* Digito */
                     crapmdw.vlcompel = p-valor              /* Valor  */
                     crapmdw.dtlibcom = dt-liberacao
                     crapmdw.lsdigctr = p-lista-digito
                     crapmdw.tpdmovto = aux_tpdmovto
                     crapmdw.nrseqdig = i-digito
                     crapmdw.cdtipchq = INTE(SUBSTRING(c-cmc-7,20,1)).
              
              IF   aux_nrtalchq <> 0   THEN
                   ASSIGN crapmdw.nrtalchq = aux_nrtalchq
                          crapmdw.nrposchq = i_posicao.
              
              /* antiga separaçao: 3-Menor Praca,4-Maior Praca,5-Menor Fora Praca,6-Maior Fora Praca */
              IF crapmdw.cdhistor = 2433 THEN
                           ASSIGN crapmdw.nrdocmto = 6.

              RELEASE crapmdw.

          END.  /* Grava Tabela */

    IF  i-cdhistor = 386   THEN 
        DO:   /* Cheque Cooperativa */
            /**********************************************************        
            RUN dbo/b1crap02.p PERSISTENT SET h-b1crap02.

            RUN consulta-conta IN h-b1crap02(INPUT p-cooper,
                                             INPUT p-cod-agencia,
                                             INPUT p-nro-caixa,
                                             INPUT aux_nrctcomp,
                                             OUTPUT TABLE tt-conta).
            DELETE PROCEDURE h-b1crap02.

            IF  RETURN-VALUE = "NOK"   THEN
                RETURN "NOK".
            *********************************************************************/
        
        FIND crapass WHERE crapass.cdcooper = crabcop.cdcooper  AND 
                           crapass.nrdconta = p-nro-conta-nova
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

        FIND crapsld WHERE crapsld.cdcooper = crapass.cdcooper  AND
                           crapsld.nrdconta = crapass.nrdconta  NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapsld THEN 
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

        ASSIGN tt-disponivel      = crapsld.vlsddisp
               tt-bloqueado       = crapsld.vlsdbloq
               tt-bloq-praca      = crapsld.vlsdblpr
               tt-bloq-fora-praca = crapsld.vlsdblfp
               tt-limite-credito  = crapass.vllimcre.

        /* Verifica Lancamentos */
        FIND craptab WHERE craptab.cdcooper = crapass.cdcooper  AND
                           craptab.nmsistem = "CRED"            AND
                           craptab.tptabela = "USUARI"          AND
                           craptab.cdempres = 11                AND
                           craptab.cdacesso = "CTRCPMFCCR"      AND
                           craptab.tpregist = 1 
                           USE-INDEX craptab1 NO-LOCK NO-ERROR.

        IF  NOT AVAIL craptab   THEN 
            DO:
                ASSIGN i-cod-erro  = 641
                       c-desc-erro = " ".
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                
                RETURN "NOK".
            END.

        ASSIGN tab_dtinipmf = DATE(INT(SUBSTRING(craptab.dstextab,4,2)),
                                   INT(SUBSTRING(craptab.dstextab,1,2)),
                                   INT(SUBSTRING(craptab.dstextab,7,4)))
               tab_dtfimpmf = DATE(INT(SUBSTRING(craptab.dstextab,15,2)),
                                   INT(SUBSTRING(craptab.dstextab,12,2)),
                                   INT(SUBSTRING(craptab.dstextab,18,4))).
                                   
        ASSIGN tab_txcpmfcc = IF  crapdat.dtmvtocd >= tab_dtinipmf  AND
                                  crapdat.dtmvtocd <= tab_dtfimpmf  THEN
                                  DECIMAL(SUBSTR(craptab.dstextab,23,13))
                              ELSE
                                  0
               tab_txrdcpmf = IF  crapdat.dtmvtocd >= tab_dtinipmf  AND
                                  crapdat.dtmvtocd <= tab_dtfimpmf  THEN
                                  DECIMAL(SUBSTR(craptab.dstextab,38,13))
                              ELSE 
                                  1.


        FOR EACH craplcm WHERE craplcm.cdcooper  = crapsld.cdcooper     AND
                               craplcm.nrdconta  = crapsld.nrdconta     AND
                               craplcm.dtmvtolt  = crapdat.dtmvtocd     AND
                               craplcm.cdhistor <> 289                  
                               USE-INDEX craplcm2 NO-LOCK:

            FIND craphis WHERE craphis.cdcooper = craplcm.cdcooper   AND
                               craphis.cdhistor = craplcm.cdhistor
                               NO-LOCK NO-ERROR.

            IF   NOT AVAIL craphis   THEN 
                 DO:
                     ASSIGN i-cod-erro  = 80
                            c-desc-erro = " ".
                     RUN cria-erro (INPUT p-cooper,
                                    INPUT p-cod-agencia,
                                    INPUT p-nro-caixa,
                                    INPUT i-cod-erro,
                                    INPUT c-desc-erro,
                                    INPUT YES).
                     
                     LEAVE.
                 END.   

            ASSIGN aux_txdoipmf = tab_txcpmfcc             
                   aux_indoipmf = IF   CAN-DO("114,117,127,160",
                                              STRING(craplcm.cdhistor))
                                  THEN 1
                                  ELSE craphis.indoipmf.
            IF  craphis.inhistor = 1   THEN
                tt-disponivel = tt-disponivel + craplcm.vllanmto.
            ELSE
            IF   craphis.inhistor = 3   THEN
                 tt-bloqueado = tt-bloqueado + craplcm.vllanmto.
            ELSE
            IF   craphis.inhistor = 4   THEN
                 tt-bloq-praca = tt-bloq-praca + craplcm.vllanmto.
            ELSE
            IF   craphis.inhistor = 5   THEN
                 tt-bloq-fora-praca = tt-bloq-fora-praca + 
                                            craplcm.vllanmto.
            ELSE
            IF   craphis.inhistor = 11   THEN
                 tt-disponivel = tt-disponivel - craplcm.vllanmto.
            ELSE
            IF   craphis.inhistor = 13   THEN
                 tt-bloqueado = tt-bloqueado - craplcm.vllanmto.
            ELSE
            IF   craphis.inhistor = 14   THEN
                 tt-bloq-praca = tt-bloq-praca - craplcm.vllanmto.
            ELSE
            IF   craphis.inhistor = 15   THEN
                 tt-bloq-fora-praca = tt-bloq-fora-praca - 
                                            craplcm.vllanmto.

            /*  Calcula CPMF para os lancamentos  */
            IF   aux_indoipmf > 1   THEN
                 DO:
                     IF   craphis.indebcre = "D"   THEN
                          aux_vlipmfap = aux_vlipmfap + (TRUNCATE(craplcm.vllanmto *
                                                                  tab_txcpmfcc,2)).
                     ELSE
                          IF   craphis.indebcre = "C"   THEN
                               aux_vlipmfap = aux_vlipmfap -
                                              (TRUNCATE(craplcm.vllanmto *
                                               tab_txcpmfcc,2)).
                 END.

            IF   CAN-DO("186,187",STRING(craplcm.cdhistor))   THEN
                 ASSIGN aux_vlestorn = TRUNCATE(craplcm.vllanmto * tab_txcpmfcc,2) 
                        aux_vlipmfap = aux_vlipmfap + aux_vlestorn + 
                                       TRUNCATE(aux_vlestorn * tab_txcpmfcc,2)
                        aux_vlestabo = aux_vlestabo + craplcm.vllanmto.

        END.  /*  for each  */

        ASSIGN aux_vlestabo    = TRUNCATE(aux_vlestabo * tab_txiofapl,2)
               tt-acerto-conta = tt-disponivel - crapsld.vlipmfap -
                                 crapsld.vlipmfpg - aux_vlipmfap - aux_vlestabo
               tt-acerto-conta = tt-acerto-conta + tt-bloqueado +
                                 tt-bloq-praca + tt-bloq-fora-praca
               tt-acerto-conta = IF tt-acerto-conta < 0
                                 THEN TRUNC(tt-acerto-conta * (1 + tab_txcpmfcc),2)
                                 ELSE tt-acerto-conta.

        /******************************************************************/
        /******************************************************************/

        ASSIGN de-valor-libera = 0
               de-valor-bloqueado = 
                        tt-bloqueado      +
                        tt-bloq-praca     +
                        tt-bloq-fora-praca
               de-valor-liberado = 
                        tt-acerto-conta   -
                        de-valor-bloqueado.
                                   
        ASSIGN  aux_totvlchq = 0
                i-digito     = 0.
        /**Contabiliza os cheques que entram em conjunto**/ 
        FOR EACH crapmdw WHERE 
                 crapmdw.cdcooper = crapcop.cdcooper    AND
                 crapmdw.cdagenci = p-cod-agencia       AND
                 crapmdw.nrdcaixa = p-nro-caixa         AND
                 crapmdw.nrctabdb = p-nrctabdb
                 NO-LOCK:
     
            ASSIGN  i-digito     = i-digito     + 1
                    aux_totvlchq = aux_totvlchq +
                                   crapmdw.vlcompel.
        END. 

        IF  de-valor-liberado + tt-limite-credito -
            aux_totvlchq      < 0 THEN
            DO:

        /*--- Anterior
        IF  tt-conta.acerto-conta + 
            tt-conta.limite-credito < p-valor THEN
            DO:
        --*/

        /*--- Nao considera CPMF e considera limite ---
        IF  tt-conta.disponivel + tt-conta.limite-credito <
            p-valor THEN
            DO:
                ASSIGN de-valor = 
                            tt-conta.disponivel          +
                            tt-conta.limite-credito
                       p-valor-disponivel =                                                                  de-valor
                       de-valor-libera =
                          ((tt-conta.disponivel          +
                            tt-conta.limite-credito)     -
                            p-valor) * -1
                       p-mensagem = 
                            "Nao existe Saldo "          +
                            "Disponivel.. "              +
                            TRIM(STRING(de-valor,
                                 "zzz,zzz,zzz,zz9.99-")) +
                            "  Excedido.. " + 
                            TRIM(STRING(de-valor-libera,
                                 "zzz,zzz,zzz,zz9.99-")).
        -------------------------------------*/
        
                /*--- Anterior
                ASSIGN p-valor-disponivel = 
                            tt-conta.acerto-conta         + 
                            tt-conta.limite-credito
                       de-valor-libera    = 
                           (tt-conta.acerto-conta         - 
                            p-valor) * -1
                       p-mensagem = 
                            "Saldo.. "                    +
                            TRIM(STRING(
                                 tt-conta.acerto-conta,
                                 "zzz,zzz,zzz,zz9.99-"))  +
                            "  Limite Credito.. "         +
                            TRIM(STRING(
                                 tt-conta.limite-credito,"
                                 zzz,zzz,zzz,zz9.99-"))   +
                            "  EXCEDIDO.. "               + 
                            TRIM(STRING(de-valor-libera,
                                 "zzz,zzz,zzz,zz9.99-")).
                -------------------*/            
                
                IF  p-grava-tabela = TRUE THEN
                    DO:
                      de-valor-libera    = 
                             (de-valor-liberado - 
                              aux_totvlchq) * -1.
                    END.
                ELSE
                    DO:
                         de-valor-libera    = 
                             (de-valor-liberado - 
                              p-valor - aux_totvlchq) * -1.
                    END.
                
                ASSIGN p-valor-disponivel =  
                            de-valor-liberado    + 
                            tt-limite-credito
                  /*   de-valor-libera    = 
                             (de-valor-liberado - 
                              p-valor - aux_totvlchq) * -1  */
                       p-mensagem         = 
                            "Saldo "                      +
                            TRIM(STRING(de-valor-liberado,
                                 "zzz,zzz,zzz,zz9.99-"))  + 
                            " Limite "                    +   
                            TRIM(STRING( 
                                tt-limite-credito,
                                 "zzz,zzz,zzz,zz9.99-"))  +     
                            " Excedido "                  + 
                            TRIM(STRING(de-valor-libera,
                                 "zzz,zzz,zzz,zz9.99-"))  +
                            " Bloq. "                     + 
                            TRIM(STRING(de-valor-bloqueado,
                                 "zzz,zzz,zzz,zz9.99-"))
                       p-aviso-cheque = p-aviso-cheque + 
                                 " Cheques " +
                             TRIM(STRING(i-digito + 1)) +
                                 " Valor " + 
                             TRIM(STRING((aux_totvlchq + 
                                          p-valor),
                                  "zzz,zzz,zzz,zz9.99-")).
             
            END. /* IF  de-valor-liberado + */
            
        END. /* IF  i-cdhistor = 386 */

    RETURN "OK".
    
END PROCEDURE.


PROCEDURE valida-deposito-com-captura-migrado:
    DEF INPUT PARAM  p-cooper        AS CHAR NO-UNDO.
    DEF INPUT PARAM  p-nmcooper      AS CHAR NO-UNDO.
    DEF INPUT PARAM  p-cod-agencia   AS INT NO-UNDO. /* Cod. Agencia */
    DEF INPUT PARAM  p-nro-caixa     AS INT FORMAT "999" NO-UNDO. /*Nro Cxa */
    DEF INPUT PARAM  p-cod-operador  AS CHAR NO-UNDO.
    DEF INPUT PARAM  p-cod-liberador AS CHAR NO-UNDO.
    DEF INPUT PARAM  p-cooper-dest   AS CHAR NO-UNDO.
    DEF INPUT PARAM  p-nro-conta     AS INT NO-UNDO.
    DEF INPUT PARAM  p-cmc-7         AS CHAR NO-UNDO.
    DEF INPUT PARAM  p-cmc-7-dig     AS CHAR NO-UNDO.
    DEF INPUT PARAM  p-cdcmpchq      AS INT FORMAT "zz9" NO-UNDO. /* Comp */
    DEF INPUT PARAM  p-cdbanchq      AS INT FORMAT "zz9" NO-UNDO. /* Banco */
    DEF INPUT PARAM  p-cdagechq      AS INT FORMAT "zzz9" NO-UNDO. /* Agencia */
    DEF INPUT PARAM  p-nrddigc1      AS INT FORMAT "9" NO-UNDO. /* C1 */
    DEF INPUT PARAM  p-nrctabdb      AS DEC FORMAT "zzz,zzz,zzz,9" NO-UNDO.    
    DEF INPUT PARAM  p-nrddigc2      AS INT FORMAT "9" NO-UNDO. /* C2 */
    DEF INPUT PARAM  p-nro-cheque    AS INT FORMAT "zzz,zz9" NO-UNDO. /* Chq */
    DEF INPUT PARAM  p-nrddigc3      AS INT FORMAT "9" NO-UNDO.
    DEF INPUT PARAM  p-valor         AS DEC NO-UNDO.
    DEF INPUT  PARAM p-grava-tabela  AS LOG NO-UNDO. /* Grava tabela */
    DEF INPUT  PARAM p-nro-conta-nova AS INT NO-UNDO.
    DEF INPUT  PARAM p-nro-conta-anti AS INT NO-UNDO.
    DEF OUTPUT PARAM p-transferencia-conta AS CHAR NO-UNDO.
    DEF OUTPUT PARAM p-aviso-cheque        AS CHAR NO-UNDO.
    DEF OUTPUT PARAM p-mensagem            AS CHAR NO-UNDO.
    DEF OUTPUT PARAM p-valor-disponivel    AS DEC NO-UNDO.

    DEF VAR aux_totvlchq AS DEC                                       NO-UNDO.
    DEF VAR h-b1wgen0001 AS HANDLE                                    NO-UNDO.
    DEF VAR h-b1wgen0044 AS HANDLE                                    NO-UNDO.

    DEF VAR tt-disponivel        AS DEC FORMAT "zzz,zzz,zzz,zz9.99-"   NO-UNDO.
    DEF VAR tt-bloqueado         AS DEC FORMAT "zzz,zzz,zzz,zz9.99-"   NO-UNDO.
    DEF VAR tt-bloq-praca        AS DEC FORMAT "zzz,zzz,zzz,zz9.99-"   NO-UNDO.
    DEF VAR tt-bloq-fora-praca   AS DEC FORMAT "zzz,zzz,zzz,zz9.99-"   NO-UNDO.
    DEF VAR tt-acerto-conta      AS DEC FORMAT "zzz,zzz,zzz,zz9.99-"   NO-UNDO.
    DEF VAR tt-limite-credito    AS DEC                                NO-UNDO.

    DEF VAR tab_dtinipmf   AS DATE                          NO-UNDO.
    DEF VAR tab_dtfimpmf   AS DATE                          NO-UNDO.
    DEF VAR tab_txcpmfcc   AS DEC                           NO-UNDO.
    DEF VAR tab_txrdcpmf   AS DEC                           NO-UNDO.
    DEF VAR aux_indoipmf   AS INT                           NO-UNDO.
    DEF VAR aux_vlipmfap   AS DEC                           NO-UNDO.
    DEF VAR aux_txdoipmf   AS DEC                           NO-UNDO.
    DEF VAR aux_vlestorn   AS DEC                           NO-UNDO.
    DEF VAR aux_vlestabo   AS DEC                           NO-UNDO.
    DEF VAR tab_txiofapl   AS DEC FORMAT "zzzzzzzz9,999999" NO-UNDO.

    DEF VAR aux_contlock AS INTE NO-UNDO.

    DEF BUFFER crabcop FOR crapcop.
    DEF BUFFER craccop FOR crapcop. /** COOP DO CHEQUE */
    DEF BUFFER cradcop FOR crapcop. /** COOP DESTINO   */
    
    /* cooperativa atual */
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    /* cooperativa antiga */
    FIND crabcop WHERE crabcop.nmrescop = p-nmcooper NO-LOCK NO-ERROR.
    
    /* Intercooperativa - Coop Destino */
    FIND cradcop WHERE cradcop.nmrescop = p-cooper-dest NO-LOCK NO-ERROR.


    ASSIGN p-nro-conta = DEC(REPLACE(STRING(p-nro-conta),".","")).
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
                      
    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.

    
    FIND FIRST crapage WHERE crapage.cdcooper = crabcop.cdcooper
                                                NO-LOCK NO-ERROR.
                                                
    ASSIGN p-aviso-cheque        = " "
           p-transferencia-conta = " "
           p-mensagem            = " ".
    
    IF  p-cmc-7 <> " "   THEN
        ASSIGN c-cmc-7              = p-cmc-7
               SUBSTR(c-cmc-7,34,1) = ":".
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

    RUN dbo/pcrap09.p (INPUT p-cooper,
                       INPUT c-cmc-7,
                       OUTPUT p-nro-calculado,
                       OUTPUT p-lista-digito).

    /*  Le tabela com as contas convenio do Banco do Brasil - Geral  */
        RUN fontes/ver_ctace.p(INPUT crabcop.cdcooper,
                               INPUT 0,
                               OUTPUT aux_lscontas).
    
    ASSIGN aux_nrdctitg = "".
    /** Conta Integracao **/
    IF  LENGTH(STRING(p-nrctabdb)) <= 8   THEN
        DO:
            ASSIGN aux_ctpsqitg = p-nrctabdb
                   glb_cdcooper = crapcop.cdcooper.
            RUN existe_conta_integracao.  
        END.   

    /* Le tabela com as contas convenio do Banco do Brasil - talao normal*/
        RUN fontes/ver_ctace.p(INPUT crabcop.cdcooper,
                               INPUT 1,
                               OUTPUT aux_lsconta1).

  /*  Le tabela com as contas convenio do Banco do Brasil - talao transf.*/
        RUN fontes/ver_ctace.p(INPUT crabcop.cdcooper,
                               INPUT 2,
                               OUTPUT aux_lsconta2).

  /*  Le tabela com as contas convenio do Banco do Brasil - chq.salario */
        RUN fontes/ver_ctace.p(INPUT crabcop.cdcooper,
                               INPUT 3,
                               OUTPUT aux_lsconta3).

    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.
    ASSIGN i_conta = dec(p-nro-conta).
    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT i_conta).
    DELETE PROCEDURE h_b2crap00.
   
    IF   RETURN-VALUE = "NOK"   THEN
        RETURN "NOK".
    
    ASSIGN aux_nrdconta = p-nro-conta.
    ASSIGN aux_nrtrfcta = 0.

    
    /* Intercooperativa - Logica para identificar a coop do cheque */
    /* Localizar COOP do cheque */
    FIND crabcop WHERE crabcop.cdagectl = p-cdagechq NO-LOCK NO-ERROR.
    
    /** Como se trata de conta migrada, verificar o TCO */
    FIND FIRST craptco
         WHERE craptco.cdcopant = crabcop.cdcooper
           AND craptco.nrdconta = p-nro-conta-nova
           AND craptco.tpctatrf = 1
           AND craptco.flgativo = TRUE
       NO-LOCK NO-ERROR.

    ASSIGN aux_cdcooper = craptco.cdcooper.
    /* Intercooperativa - Logica para identificar a coop do cheque */
        
    DO  WHILE TRUE:
        /** Validar associado do CHEQUE **/
        FIND FIRST crapass WHERE crapass.cdcooper = aux_cdcooper
                             AND crapass.nrdconta = p-nro-conta-nova
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
        IF   crapass.dtelimin <> ? THEN 
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
        
        RUN sistema/generico/procedures/b1wgen0001.p
            PERSISTENT SET h-b1wgen0001.
        
        IF   VALID-HANDLE(h-b1wgen0001)   THEN
        DO:
             RUN ver_capital IN h-b1wgen0001(INPUT  crapcop.cdcooper,
                                             INPUT  p-nro-conta-nova,
                                             INPUT  p-cod-agencia,
                                             INPUT  p-nro-caixa,
                                             0,
                                             INPUT  crapdat.dtmvtocd,
                                             INPUT  "b1crap51",
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
    
    IF  aux_nrtrfcta  > 0              AND
        aux_nrdconta <> aux_nrtrfcta   THEN /* Transferencia de Conta */
        ASSIGN aux_nrdconta = aux_nrtrfcta
               p-nrctabdb   = aux_nrtrfcta.

    /* Buscar registro da cooperativa antiga p/ vercheque*/
    FIND crapcop WHERE crapcop.nmrescop = p-nmcooper NO-LOCK NO-ERROR.
    
    ASSIGN aux_cdagebcb = crapcop.cdagebcb.

    ASSIGN  i-p-nro-cheque     = p-nro-cheque  /* variaveis proc.ver_cheque */
            i-p-nrddigc3             = p-nrddigc3
            i-p-cdbanchq             = p-cdbanchq
            i-p-cdagechq             = p-cdagechq
            i-p-nrctabdb             = p-nrctabdb
            i-p-valor                = p-valor
            i-p-transferencia-conta  = " "
            i-p-aviso-cheque         = " "
            de-nrctachq              = DEC(SUBSTR(c-cmc-7,23,10)).

    RUN ver_cheque_migrado.  /* include - bo-vercheque.i */

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    ASSIGN  p-transferencia-conta  = i-p-transferencia-conta
            p-aviso-cheque         = i-p-aviso-cheque
            p-nrctabdb             = IF i-p-transferencia-conta <> ""
                                     THEN aux_nrctcomp
                                     ELSE p-nrctabdb.
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

    IF   aux_nrctcomp > 0   THEN
         ASSIGN i-cdhistor = 386.
    ELSE
         ASSIGN i-cdhistor = 2433.

    FIND craphis WHERE craphis.cdcooper = crabcop.cdcooper   AND
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

    IF   craphis.tpctbcxa   <> 2 AND
         craphis.tpctbcxa   <> 3   THEN
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

    EMPTY TEMP-TABLE w-compel.

    FIND FIRST craptab WHERE craptab.cdcooper = crabcop.cdcooper    AND
                             craptab.nmsistem = "CRED"              AND
                             craptab.tptabela = "USUARI"            AND
                             craptab.cdempres = 11                  AND
                             craptab.cdacesso = "MAIORESCHQ"        AND
                             craptab.tpregist = 1 
                             NO-LOCK NO-ERROR.
                             
    IF   NOT AVAIL craptab   THEN
         ASSIGN TAB_vlchqmai = 1.
    ELSE
         ASSIGN TAB_vlchqmai  = DEC(SUBSTR(craptab.dstextab,1,15)).

    IF   p-valor < tab_vlchqmai   THEN
         ASSIGN  aux_tpdmovto = 2.
    ELSE
         ASSIGN  aux_tpdmovto = 1.
    
    IF   CAN-FIND(crapchd WHERE crapchd.cdcooper = crabcop.cdcooper     AND
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
    
    FIND crapcst WHERE crapcst.cdcooper = crabcop.cdcooper AND
                       crapcst.cdcmpchq = p-cdcmpchq       AND
                       crapcst.cdbanchq = p-cdbanchq       AND
                       crapcst.cdagechq = p-cdagechq       AND
                       crapcst.nrctachq = p-nrctabdb       AND
                       crapcst.nrcheque = p-nro-cheque     AND
                       crapcst.dtdevolu = ?                AND
					   crapcst.nrborder = 0                AND 
					   crapcst.dtlibera > crapdat.dtmvtoan AND
                       crapcst.insitchq = 0 /* Nao processado */
                       NO-LOCK NO-ERROR.
   
    IF  AVAILABLE crapcst  THEN
        DO:
            ASSIGN i-cod-erro  = 757 /* cheque em custodia */
                   c-desc-erro = "".
   
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".      
        END.
    
    FIND crapcdb WHERE crapcdb.cdcooper = crabcop.cdcooper  AND
                       crapcdb.cdcmpchq = p-cdcmpchq        AND
                       crapcdb.cdbanchq = p-cdbanchq        AND
                       crapcdb.cdagechq = p-cdagechq        AND
                       crapcdb.nrctachq = p-nrctabdb        AND
                       crapcdb.nrcheque = p-nro-cheque      AND
                       crapcdb.dtdevolu = ?                 AND
                       crapcdb.insitchq = 2 /*processado*/  AND         
                       crapcdb.dtlibera >= crapdat.dtmvtoan NO-LOCK NO-ERROR.

    IF  AVAILABLE crapcdb  THEN
        DO:
            ASSIGN i-cod-erro  = 0
                   c-desc-erro = "Cheque esta em desconto.".
            
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
        END.
    
    CREATE w-compel.
    ASSIGN w-compel.dsdocmc7 = c-cmc-7
           w-compel.cdcmpchq = p-cdcmpchq
           w-compel.cdbanchq = p-cdbanchq
           w-compel.cdagechq = p-cdagechq
           w-compel.nrddigc1 = p-nrddigc1
           w-compel.nrctaaux = aux_nrctcomp
           w-compel.nrctachq = de-nrctachq 
           w-compel.nrctabdb = p-nrctabdb 
           w-compel.nrddigc2 = p-nrddigc2
           w-compel.nrcheque = p-nro-cheque
           w-compel.nrddigc3 = p-nrddigc3
           w-compel.vlcompel = p-valor
           w-compel.dtlibcom = ?
           w-compel.lsdigctr = p-lista-digito
           w-compel.tpdmovto = aux_tpdmovto
           w-compel.cdtipchq = INTE(SUBSTRING(c-cmc-7,20,1))
           w-compel.nrseqdig = 1
           w-compel.tpcheque = aux_tpcheque.

     /*IF   aux_nrtalchq <> 0   THEN
          ASSIGN w-compel.nrtalchq = aux_nrtalchq
                 w-compel.nrposchq = i_posicao.
     ELSE
          IF   aux_nrdocchq <> 0   THEN
               ASSIGN w-compel.nrdocmto = aux_nrdocchq.*/

     FOR EACH w-compel NO-LOCK :   /* Verifica Lancamento Existente */
         FIND FIRST crapchd WHERE crapchd.cdcooper = crabcop.cdcooper    AND
                                  crapchd.dtmvtolt = crapdat.dtmvtocd    AND
                                  crapchd.cdcmpchq = w-compel.cdcmpchq   AND
                                  crapchd.cdbanchq = w-compel.cdbanchq   AND
                                  crapchd.cdagechq = w-compel.cdagechq   AND
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

     IF   i-cdhistor <> 386   THEN 
          DO:
              /* Verifica horario de Corte */
              FIND FIRST craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
                                       craptab.nmsistem = "CRED"            AND
                                       craptab.tptabela = "GENERI"          AND
                                       craptab.cdempres = 0                 AND
                                       craptab.cdacesso = "HRTRCOMPEL"      AND
                                       craptab.tpregist = p-cod-agencia  
                                       NO-LOCK NO-ERROR.
                                       
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
    END.    /* Verifica Horario de Corte */
    ELSE DO:
        /** Validacao Dep. Intercooperativas
             Valida conta apenas se Mesma Coop */
        /** Coop Dest " " quando mesma coop    */
        IF  p-cooper-dest = " "  THEN
            IF  p-nro-conta = aux_nrctcomp THEN DO:

                ASSIGN i-cod-erro = 758
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

     ASSIGN dt-liberacao    = ?
            dt-menor-praca  = ?
            dt-maior-praca  = ?
            dt-menor-fpraca = ?
            dt-maior-fpraca = ?.
     
     ASSIGN i-digito =  0.
     
     IF   p-grava-tabela = YES   THEN 
          DO:
              ASSIGN i-digito = 1.
              FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper    AND
                                     crapmdw.cdagenci = p-cod-agencia       AND
                                     crapmdw.nrdcaixa = p-nro-caixa 
                                     NO-LOCK BREAK BY crapmdw.nrseqdig:
                  IF   LAST(crapmdw.nrseqdig)   THEN
                       ASSIGN i-digito = crapmdw.nrseqdig + 1.

              END.


              DO aux_contlock = 1 TO 10:
              FIND FIRST crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper  AND
                                       crapmdw.cdagenci = p-cod-agencia     AND
                                       crapmdw.nrdcaixa = p-nro-caixa       AND
                                       crapmdw.nrctabdb = p-nrctabdb        AND
                                       crapmdw.nrcheque = p-nro-cheque 
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                IF NOT AVAILABLE crapmdw THEN
                   DO:
                  IF LOCKED(crapmdw) THEN
                  DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Registro crapmdw esta em uso no momento. Dep migrado.".
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                  END.
                  ELSE
                  DO:
                       CREATE crapmdw.
                       ASSIGN crapmdw.cdcooper  = crapcop.cdcooper
                              crapmdw.cdagenci  = p-cod-agencia
                              crapmdw.nrdcaixa  = p-nro-caixa
                              crapmdw.nrctabdb  = p-nrctabdb
                              crapmdw.nrcheque  = p-nro-cheque.
                   END.
                END.

                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "".
                LEAVE.
              END. /* fim contador */
              
              IF i-cod-erro <> 0 OR 
                 c-desc-erro <> "" THEN
              DO:
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).                      
                RETURN "NOK".
              END.


              /* Instanciar a BO que fara o calculo do bloqueio do cheque */
              RUN sistema/generico/procedures/b1wgen0044.p 
                  PERSISTENT SET h-b1wgen0044.
              
              IF  NOT VALID-HANDLE(h-b1wgen0044)  THEN
                  DO:
                      ASSIGN i-cod-erro  = 0
                             c-desc-erro = "Handle invalido para h-b1wgen0044".
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
              
                  END.              
                    
              RUN calcula_bloqueio_cheque IN h-b1wgen0044
                                          (INPUT crapcop.cdcooper,
                                           INPUT crapdat.dtmvtocd,
                                           INPUT p-cod-agencia,
                                           INPUT p-cdbanchq,
                                           INPUT p-cdagechq,
                                           INPUT p-valor,
                                           OUTPUT dt-liberacao,
                                           OUTPUT TABLE tt-erro).

              /* Remover a instancia da b1wgen0044 da memoria */
              DELETE PROCEDURE h-b1wgen0044.
              
              IF  RETURN-VALUE = "NOK"  THEN
                  DO:
                      FIND LAST tt-erro NO-LOCK NO-ERROR.
                      IF  AVAIL tt-erro THEN
                          ASSIGN c-desc-erro = tt-erro.dscritic
                                 i-cod-erro  = tt-erro.cdcritic.
                      ELSE
                          c-desc-erro = "Erro no calculo do " +
                                        "bloqueio do cheque".
                      
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
                  

              ASSIGN crapmdw.nrdconta = p-nro-conta  
                     crapmdw.cdopecxa = p-cod-operador
                     crapmdw.cdopelib = p-cod-liberador
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
                     crapmdw.nrddigc3 = p-nrddigc3            /* Digito */
                     crapmdw.vlcompel = p-valor              /* Valor  */
                     crapmdw.dtlibcom = dt-liberacao
                     crapmdw.lsdigctr = p-lista-digito
                     crapmdw.tpdmovto = aux_tpdmovto
                     crapmdw.nrseqdig = i-digito
                     crapmdw.cdtipchq = INTE(SUBSTRING(c-cmc-7,20,1)).
              
              IF   aux_nrtalchq <> 0   THEN
                   ASSIGN crapmdw.nrtalchq = aux_nrtalchq
                          crapmdw.nrposchq = i_posicao.
              /* antiga separaçao: 3-Menor Praca,4-Maior Praca,5-Menor Fora Praca,6-Maior Fora Praca */
              IF crapmdw.cdhistor = 2433 THEN
                           ASSIGN crapmdw.nrdocmto = 6.

              RELEASE crapmdw.

          END.  /* Grava Tabela */
    
    IF  i-cdhistor = 386   THEN 
        DO:   /* Cheque Cooperativa */
           
            RUN dbo/b1crap02.p PERSISTENT SET h-b1crap02.
            
            RUN consulta-conta IN h-b1crap02(INPUT p-cooper,
                                             INPUT p-cod-agencia,
                                             INPUT p-nro-caixa,
                                             INPUT p-nro-conta-nova,
                                             OUTPUT TABLE tt-conta).
            DELETE PROCEDURE h-b1crap02.

            IF  RETURN-VALUE = "NOK"   THEN
                RETURN "NOK".
            
                
            ASSIGN de-valor-libera = 0.
            FIND FIRST tt-conta NO-LOCK NO-ERROR.
            IF  AVAIL tt-conta   THEN  
                DO:
                    IF  tt-conta.cheque-salario = 0   THEN
                        DO:
                            ASSIGN de-valor-bloqueado = 
                                            tt-conta.bloqueado      +
                                            tt-conta.bloq-praca     +
                                            tt-conta.bloq-fora-praca
                                   de-valor-liberado = 
                                            tt-conta.acerto-conta   -
                                            de-valor-bloqueado.

                            ASSIGN  aux_totvlchq = 0
                                    i-digito     = 0.
                            /**Contabiliza os cheques que entram em conjunto**/ 
                            FOR EACH crapmdw WHERE 
                                     crapmdw.cdcooper = crapcop.cdcooper    AND
                                     crapmdw.cdagenci = p-cod-agencia       AND
                                     crapmdw.nrdcaixa = p-nro-caixa         AND
                                     crapmdw.nrctabdb = p-nrctabdb
                                     NO-LOCK:

                                ASSIGN  i-digito     = i-digito     + 1
                                        aux_totvlchq = aux_totvlchq +
                                                       crapmdw.vlcompel.
                            END.

                            IF  de-valor-liberado + tt-conta.limite-credito -
                                aux_totvlchq      < 0    THEN
                                DO:

                            /*--- Anterior
                            IF  tt-conta.acerto-conta + 
                                tt-conta.limite-credito < p-valor THEN
                                DO:
                            --*/

                            /*--- Nao considera CPMF e considera limite ---
                            IF  tt-conta.disponivel + tt-conta.limite-credito <
                                p-valor THEN
                                DO:
                                    ASSIGN de-valor = 
                                                tt-conta.disponivel          +
                                                tt-conta.limite-credito
                                           p-valor-disponivel =                                                                  de-valor
                                           de-valor-libera =
                                              ((tt-conta.disponivel          +
                                                tt-conta.limite-credito)     -
                                                p-valor) * -1
                                           p-mensagem = 
                                                "Nao existe Saldo "          +
                                                "Disponivel.. "              +
                                                TRIM(STRING(de-valor,
                                                     "zzz,zzz,zzz,zz9.99-")) +
                                                "  Excedido.. " + 
                                                TRIM(STRING(de-valor-libera,
                                                     "zzz,zzz,zzz,zz9.99-")).
                            -------------------------------------*/

                                    /*--- Anterior
                                    ASSIGN p-valor-disponivel = 
                                                tt-conta.acerto-conta         + 
                                                tt-conta.limite-credito
                                           de-valor-libera    = 
                                               (tt-conta.acerto-conta         - 
                                                p-valor) * -1
                                           p-mensagem = 
                                                "Saldo.. "                    +
                                                TRIM(STRING(
                                                     tt-conta.acerto-conta,
                                                     "zzz,zzz,zzz,zz9.99-"))  +
                                                "  Limite Credito.. "         +
                                                TRIM(STRING(
                                                     tt-conta.limite-credito,"
                                                     zzz,zzz,zzz,zz9.99-"))   +
                                                "  EXCEDIDO.. "               + 
                                                TRIM(STRING(de-valor-libera,
                                                     "zzz,zzz,zzz,zz9.99-")).
                                    -------------------*/            

                                          
                                    IF  p-grava-tabela = TRUE THEN
                                        DO:
                                             de-valor-libera    = 
                                                 (de-valor-liberado - 
                                                  aux_totvlchq) * -1.
                                        END.
                                    ELSE
                                        DO:
                                             de-valor-libera    = 
                                                 (de-valor-liberado - 
                                                  p-valor - aux_totvlchq) * -1.
                                        END.
                                    

                                    ASSIGN p-valor-disponivel =  
                                                de-valor-liberado             + 
                                                tt-conta.limite-credito
                                     /*    de-valor-libera    = 
                                                 (de-valor-liberado - 
                                                  p-valor - aux_totvlchq) * -1 */
                                           p-mensagem         = 
                                                "Saldo "                      +
                                                TRIM(STRING(de-valor-liberado,
                                                     "zzz,zzz,zzz,zz9.99-"))  + 
                                                " Limite "                    +
                                                TRIM(STRING(
                                                     tt-conta.limite-credito,
                                                     "zzz,zzz,zzz,zz9.99-"))  +
                                                " Excedido "                  + 
                                                TRIM(STRING(de-valor-libera,
                                                     "zzz,zzz,zzz,zz9.99-"))  +
                                                " Bloq. "                     + 
                                                TRIM(STRING(de-valor-bloqueado,
                                                     "zzz,zzz,zzz,zz9.99-"))
                                           p-aviso-cheque = p-aviso-cheque + 
                                                     " Cheques " +
                                                 TRIM(STRING(i-digito + 1)) +
                                                     " Valor " + 
                                                 TRIM(STRING((aux_totvlchq + 
                                                              p-valor),
                                                      "zzz,zzz,zzz,zz9.99-")).

                                END. /* IF  de-valor-liberado + */

                        END. /* IF  tt-conta.cheque-salario = 0  */

                END. /* IF  AVAIL tt-conta */

        END. /* IF  i-cdhistor = 386 */

    RETURN "OK".
    
END PROCEDURE.

FUNCTION centraliza RETURNS CHARACTER ( INPUT par_frase AS CHARACTER, INPUT par_tamlinha AS INTEGER ):

    DEF VAR vr_contastr AS INTEGER NO-UNDO.
    
    ASSIGN vr_contastr = TRUNC( (par_tamlinha - LENGTH(TRIM(par_frase))) / 2 ,0).

    RETURN FILL(' ',vr_contastr) + TRIM(par_frase).
END.

PROCEDURE atualiza-deposito-com-captura:
               
    DEF INPUT  PARAM  p-cooper              AS CHAR NO-UNDO.
    DEF INPUT  PARAM  p-cod-agencia         AS INT  NO-UNDO. /* Cod.Agencia  */
    DEF INPUT  PARAM  p-nro-caixa           AS INT  NO-UNDO. /* Numero Caixa */
    DEF INPUT  PARAM  p-cod-operador        AS CHAR NO-UNDO.
    DEF INPUT  PARAM  p-nro-conta           AS INT  NO-UNDO.



/*
    DEF INPUT  PARAM pCodAprovador              AS CHAR NO-UNDO.
*/    
    
    DEF INPUT  PARAM  p-nome-titular            AS CHAR NO-UNDO.
    DEF INPUT  PARAM  p-identifica              AS CHAR NO-UNDO.
    DEF INPUT  PARAM  p-vestorno                AS LOG  NO-UNDO.
    DEF OUTPUT PARAM  p-literal-autentica       AS CHAR NO-UNDO.
    DEF OUTPUT PARAM  p-ult-sequencia-autentica AS INT  NO-UNDO.
    DEF OUTPUT PARAM  p-nro-docto               AS INT  NO-UNDO.

    DEF VAR aux_contalot AS INTE NO-UNDO.
 
    DEF VAR aux_contlock AS INTE NO-UNDO.
 
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    
    DO   WHILE TRUE:
        
         FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper   AND
                            crapass.nrdconta = INT(p-nro-conta) 
                            NO-LOCK NO-ERROR.
                                  
         IF   NOT AVAIL crapass   THEN 
              LEAVE.

         IF   AVAIL crapass   THEN 
              DO:
                  IF  CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN 
                      DO:
                          FIND FIRST craptrf WHERE 
                                     craptrf.cdcooper = crapcop.cdcooper    AND
                                     craptrf.nrdconta = crapass.nrdconta    AND
                                     craptrf.tptransa = 1                   AND
                                     craptrf.insittrs = 2   
                                     USE-INDEX craptrf1 NO-LOCK NO-ERROR.
    
                          IF   AVAIL craptrf   THEN  
                               ASSIGN aux_nrtrfcta = craptrf.nrsconta
                                      aux_nrdconta = craptrf.nrsconta
                                      p-nro-conta  = craptrf.nrsconta.
                          ELSE 
                              LEAVE.
                      END.
                  ELSE
                      LEAVE.
              END.
    END. /* DO WHILE */
    
    ASSIGN p-nro-conta = DEC(REPLACE(STRING(p-nro-conta),".","")).

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    ASSIGN i-nro-lote = 11000 + p-nro-caixa.

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.

    FIND FIRST crapmrw WHERE crapmrw.cdcooper = crapcop.cdcooper    AND 
                             crapmrw.cdagenci = p-cod-agencia       AND
                             crapmrw.nrdcaixa = p-nro-caixa   
                             NO-LOCK NO-ERROR.
                             
    IF   NOT AVAIL crapmrw   THEN 
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Nao existem valores a serem Depositados ".
                    run cria-erro (INPUT p-cooper,
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
                        c-desc-erro = "Erro de captura. Tente novamente. INF(ENTRY) = " + 
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

    ASSIGN dt-menor-praca  = ?
           dt-maior-praca  = ?
           dt-menor-fpraca = ?
           dt-maior-fpraca = ?
           dt-menor-fpraca = crapdat.dtmvtocd.
           
    ASSIGN aux_nrdconta = p-nro-conta.
    /*--- Verifica se Houve Transferencia de Conta --*/
    ASSIGN aux_nrtrfcta = 0.
    DO   WHILE TRUE:
         FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper   AND
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
    END. /* do while */
    IF   aux_nrtrfcta > 0  THEN    /* Transferencia de Conta */
         ASSIGN aux_nrdconta = aux_nrtrfcta.

    ASSIGN p-nro-conta = aux_nrdconta.
    
    ASSIGN l-achou-horario-corte  = no.
    FOR EACH crapmrw WHERE crapmrw.cdcooper = crapcop.cdcooper  AND
                           crapmrw.cdagenci = p-cod-agencia     AND
                           crapmrw.nrdcaixa = p-nro-caixa       NO-LOCK:
                           
        IF  crapmrw.vlchqipr <> 0   OR
            crapmrw.vlchqspr <> 0   OR
            crapmrw.vlchqifp <> 0   OR
            crapmrw.vlchqsfp <> 0   THEN
            ASSIGN l-achou-horario-corte  = yes.
    END.

    IF  l-achou-horario-corte   THEN  
        DO:
            /* Verifica horario de Corte */
            FIND FIRST craptab WHERE craptab.cdcooper = crapcop.cdcooper    AND 
                                     craptab.nmsistem = "CRED"              AND
                                     craptab.tptabela = "GENERI"            AND
                                     craptab.cdempres = 0                   AND
                                     craptab.cdacesso = "HRTRCOMPEL"        AND
                                     craptab.tpregist = p-cod-agencia  
                                     NO-LOCK NO-ERROR.
                                     
            IF  NOT AVAIL craptab   THEN  
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

            IF  INT(SUBSTR(craptab.dstextab,1,1)) <> 0   THEN 
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

            IF  INT(SUBSTR(craptab.dstextab,3,5)) <= TIME   THEN 
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
         END.    /* Verifica Horario de Corte */

    ASSIGN c-docto-salvo = STRING(time).

    /* 5 tentativas para pegar lock no craplot */
    DO aux_contalot = 1 TO 5:
    
        FIND FIRST craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                                 craplot.dtmvtolt = crapdat.dtmvtocd  AND
                                 craplot.cdagenci = p-cod-agencia     AND
                                 craplot.cdbccxlt = 11                AND /* Fixo */
                                 craplot.nrdolote = i-nro-lote 
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
             
        IF  NOT AVAIL craplot  THEN 
        DO: 
            IF  LOCKED(craplot) THEN
                DO:
                    ASSIGN i-cod-erro  = 0
                           c-desc-erro = "Registro de lote esta em uso no momento.".
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
            ELSE
               DO:
                   CREATE craplot.
                   ASSIGN craplot.cdcooper = crapcop.cdcooper
                          craplot.dtmvtolt = crapdat.dtmvtocd
                          craplot.cdagenci = p-cod-agencia
                          craplot.cdbccxlt = 11
                          craplot.nrdolote = i-nro-lote
                          craplot.tplotmov = 1
                          craplot.cdoperad = p-cod-operador
                          craplot.cdhistor = 0 /* 700 */
                          craplot.nrdcaixa = p-nro-caixa
                          craplot.cdopecxa = p-cod-operador.
               END.
        END.

        ASSIGN i-cod-erro  = 0
               c-desc-erro = "".
        LEAVE.

    END.

    IF  i-cod-erro > 0    OR
        c-desc-erro <> "" THEN
    DO:
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).

        FIND CURRENT craplot NO-LOCK.
        RELEASE craplot.


        RETURN "NOK".
    END.

    ASSIGN de-valor        = 0
           de-dinheiro     = 0
           de-cooperativa  = 0
           de-maior-praca  = 0
           de-menor-praca  = 0
           de-maior-fpraca = 0
           de-menor-fpraca = 0.
    
    /* Montar o Resumo */
    /* Buscar os totais de dinheiro e Cheque Cooperativa */
    FIND FIRST crapmrw WHERE crapmrw.cdcooper = crapcop.cdcooper    AND
                             crapmrw.cdagenci = p-cod-agencia       AND
                             crapmrw.nrdcaixa = p-nro-caixa
                             NO-LOCK NO-ERROR.
                             
    IF   AVAIL crapmrw   THEN 
         DO:
             ASSIGN de-dinheiro     = crapmrw.vldepdin
                    de-cooperativa  = crapmrw.vlchqcop
                    de-valor = de-dinheiro + de-cooperativa.
         END.

    FIND FIRST craptab WHERE craptab.cdcooper = crapcop.cdcooper    AND
                             craptab.nmsistem = "CRED"              AND
                             craptab.tptabela = "USUARI"            AND
                             craptab.cdempres = 11                  AND
                             craptab.cdacesso = "MAIORESCHQ"        AND
                             craptab.tpregist = 1 
                             NO-LOCK NO-ERROR.
      
    /* Buscar os totais de cheque maior e menor da Praca ou fora Praca */
    FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper AND
                           crapmdw.cdagenci = p-cod-agencia    AND
                           crapmdw.nrdcaixa = p-nro-caixa NO-LOCK:
        
        FIND tt-cheques WHERE tt-cheques.dtlibera = crapmdw.dtlibcom AND
                              tt-cheques.nrdocmto = crapmdw.nrdocmto
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL tt-cheques  THEN
            CREATE tt-cheques.

        IF  crapmdw.vlcompel < DEC(SUBSTR(craptab.dstextab,1,15))  THEN
            ASSIGN  aux_tpdmovto = 2.
        ELSE
            ASSIGN  aux_tpdmovto = 1.                
        
        IF crapmdw.cdhistor = 2433 THEN
            ASSIGN tt-cheques.nrdocmto = 6
                   tt-cheques.dtlibera = crapmdw.dtlibcom
                   tt-cheques.vlcompel = tt-cheques.vlcompel + crapmdw.vlcompel
                   de-valor = de-valor + crapmdw.vlcompel.
        
        FIND CURRENT tt-cheques NO-LOCK.
        
    END.    
    /* Fim da montagem do Resumo */     
         
    ASSIGN i-nro-docto = INT(c-docto-salvo)
           p-nro-docto = INT(c-docto-salvo).
    
    /*--- Grava Autenticacao Arquivo/Spool --*/
    RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
    RUN grava-autenticacao  IN h_b1crap00 (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT p-nro-caixa,
                                           INPUT p-cod-operador,
                                           INPUT de-valor,
                                           INPUT dec(i-nro-docto),
                                           INPUT NO, /* YES (PG), NO (REC) */
                                           INPUT "1",  /* On-line  */     
                                           INPUT NO,   /* Nao estorno */     
                                           INPUT 700,
                                           INPUT ?, /* Data off-line */
                                           INPUT 0, /* Sequencia off-line */
                                           INPUT 0, /* Hora off-line */
                                           INPUT 0, /* Seq.orig.Off-line */
                                           OUTPUT p-literal,
                                           OUTPUT p-ult-sequencia,
                                           OUTPUT p-registro).
    DELETE PROCEDURE h_b1crap00.

    IF   RETURN-VALUE = "NOK"  THEN
         RETURN "NOK".
         
    IF   AVAIL crapmrw   THEN  
         DO:
         
             /* Formata conta integracao */
             RUN fontes/digbbx.p (INPUT  p-nro-conta,
                                  OUTPUT glb_dsdctitg,
                                  OUTPUT glb_stsnrcal).
         
             /* Dinheiro */
             IF   crapmrw.vldepdin <> 0   THEN 
                  DO:
                      ASSIGN c-docto = c-docto-salvo + 
                                       /* 'Sequencial' fixo 01 */
                                       "01" + 
                                       "1".

                      /*--- Verifica se Lancamento ja Existe ---*/
                      FIND FIRST craplcm WHERE
                                 craplcm.cdcooper = crapcop.cdcooper    AND
                                 craplcm.dtmvtolt = crapdat.dtmvtocd    AND
                                 craplcm.cdagenci = p-cod-agencia       AND
                                 craplcm.cdbccxlt = 11                  AND
                                 craplcm.nrdolote = i-nro-lote          AND
                                 craplcm.nrseqdig = craplot.nrseqdig + 1 
                                 USE-INDEX craplcm3 NO-LOCK NO-ERROR.

                      IF   AVAIL craplcm THEN   
                           DO:
                               ASSIGN i-cod-erro  = 0
                                      c-desc-erro = "Lancamento ja existente".
                               RUN cria-erro (INPUT p-cooper,
                                              INPUT p-cod-agencia,
                                              INPUT p-nro-caixa,
                                              INPUT i-cod-erro,
                                              INPUT c-desc-erro,
                                              INPUT YES).
                               RETURN "NOK".
                           END.

                      FIND FIRST craplcm WHERE 
                                 craplcm.cdcooper = crapcop.cdcooper    AND
                                 craplcm.dtmvtolt = crapdat.dtmvtocd    AND
                                 craplcm.cdagenci = p-cod-agencia       AND
                                 craplcm.cdbccxlt = 11                  AND
                                 craplcm.nrdolote = i-nro-lote          AND
                                 craplcm.nrdctabb = p-nro-conta         AND
                                 craplcm.nrdocmto = INT(c-docto) 
                                 USE-INDEX craplcm1 NO-LOCK NO-ERROR.

                      IF   AVAIL craplcm   THEN 
                           DO:
                               ASSIGN i-cod-erro  = 0
                                      c-desc-erro = 
                                          "Lancamento(Primario) ja existente".
                               RUN cria-erro (INPUT p-cooper,
                                              INPUT p-cod-agencia,
                                              INPUT p-nro-caixa,
                                              INPUT i-cod-erro,
                                              INPUT c-desc-erro,
                                              INPUT YES).
                               RETURN "NOK".
                           END.
                      
                      /* BLOCO DA INSERÇAO DA CRAPLCM */
                      IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
                        RUN sistema/generico/procedures/b1wgen0200.p 
                          PERSISTENT SET h-b1wgen0200.
                          
                      RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
                        (INPUT crapdat.dtmvtolt               /* par_dtmvtolt */
                        ,INPUT p-cod-agencia                  /* par_cdagenci */
                        ,INPUT 11                             /* par_cdbccxlt */
                        ,INPUT i-nro-lote                     /* par_nrdolote */
                        ,INPUT aux_nrdconta                   /* par_nrdconta */
                        ,INPUT INTE(c-docto)                  /* par_nrdocmto */
                        ,INPUT 1                              /* par_cdhistor */
                        ,INPUT craplot.nrseqdig + 1           /* par_nrseqdig */
                        ,INPUT crapmrw.vldepdin               /* par_vllanmto */
                        ,INPUT p-nro-conta                    /* par_nrdctabb */
                        ,INPUT "CRAP51"                       /* par_cdpesqbb */
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
                        ,INPUT ""                             /* par_cdoperad */
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
                        /* CAMPOS DE SAIDA                                                                     */                                            
                        ,OUTPUT TABLE tt-ret-lancto           /* Collection que contem o retorno do lancamento */
                        ,OUTPUT aux_incrineg                  /* Indicador de critica de negocio               */
                        ,OUTPUT aux_cdcritic                  /* Codigo da critica                             */
                        ,OUTPUT aux_dscritic).                /* Descricao da critica                          */
                        
                      IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                         DO: 
                             /* Tratamento de erros conforme anteriores */
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
                      ELSE 
                         DO:
                           /* Posicionando no registro da craplcm criado acima */
                           FIND FIRST tt-ret-lancto.
                           FIND FIRST craplcm WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm NO-ERROR.
                         END.                
                      
                      IF  VALID-HANDLE(h-b1wgen0200) THEN
                        DELETE PROCEDURE h-b1wgen0200.


                      ASSIGN craplot.nrseqdig  = craplot.nrseqdig + 1
                             craplot.qtcompln  = craplot.qtcompln + 1
                             craplot.qtinfoln  = craplot.qtinfoln + 1
                             craplot.vlcompcr  = craplot.vlcompcr + 
                                                 crapmrw.vldepdin              
                             craplot.vlinfocr  = craplot.vlinfocr +  
                                                 crapmrw.vldepdin.
                  END.
             
             /* Cheque Cooperativa */
             IF   crapmrw.vlchqcop <> 0   THEN 
                  DO:
                      ASSIGN c-docto = c-docto-salvo + 
                                      /* 'Sequencial' fixo 01 */
                                      "01" + 
                                      "2".

                      /*--- Verifica se Lancamento ja Existe ---*/
                      FIND FIRST craplcm WHERE
                                 craplcm.cdcooper = crapcop.cdcooper    AND
                                 craplcm.dtmvtolt = crapdat.dtmvtocd    AND
                                 craplcm.cdagenci = p-cod-agencia       AND
                                 craplcm.cdbccxlt = 11                  AND
                                 craplcm.nrdolote = i-nro-lote          AND
                                 craplcm.nrseqdig = craplot.nrseqdig + 1 
                                 USE-INDEX craplcm3 NO-LOCK NO-ERROR.

                      IF   AVAIL craplcm   THEN 
                           DO:
                               ASSIGN i-cod-erro  = 0
                                      c-desc-erro = "Lancamento  ja existente".
                               RUN cria-erro (INPUT p-cooper,
                                              INPUT p-cod-agencia,
                                              INPUT p-nro-caixa,
                                              INPUT i-cod-erro,
                                              INPUT c-desc-erro,
                                              INPUT YES).
                               RETURN "NOK".
                           END.

                      FIND FIRST craplcm WHERE
                                 craplcm.cdcooper = crapcop.cdcooper    AND
                                 craplcm.dtmvtolt = crapdat.dtmvtocd    AND
                                 craplcm.cdagenci = p-cod-agencia       AND
                                 craplcm.cdbccxlt = 11                  AND
                                 craplcm.nrdolote = i-nro-lote          AND
                                 craplcm.nrdctabb = p-nro-conta         AND
                                 craplcm.nrdocmto = inte(c-docto) 
                                 USE-INDEX craplcm1 NO-LOCK NO-ERROR.
                                 
                      IF   AVAIL craplcm   THEN 
                           DO:
                               ASSIGN i-cod-erro  = 0
                                      c-desc-erro = "Lancamento(Primario) ja " +
                                                    "existente".
                               RUN cria-erro (INPUT p-cooper,
                                              INPUT p-cod-agencia,
                                              INPUT p-nro-caixa,
                                              INPUT i-cod-erro,
                                              INPUT c-desc-erro,
                                              INPUT YES).
                               RETURN "NOK".
                           END.
                      
                      /* BLOCO DA INSERÇAO DA CRAPLCM */
                      IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
                        RUN sistema/generico/procedures/b1wgen0200.p 
                          PERSISTENT SET h-b1wgen0200.
                          
                      RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
                        (INPUT crapdat.dtmvtolt               /* par_dtmvtolt */
                        ,INPUT p-cod-agencia                  /* par_cdagenci */
                        ,INPUT 11                             /* par_cdbccxlt */
                        ,INPUT i-nro-lote                     /* par_nrdolote */
                        ,INPUT aux_nrdconta                   /* par_nrdconta */
                        ,INPUT INT(c-docto)                   /* par_nrdocmto */
                        ,INPUT 386                            /* par_cdhistor */
                        ,INPUT craplot.nrseqdig + 1           /* par_nrseqdig */
                        ,INPUT crapmrw.vlchqcop               /* par_vllanmto */
                        ,INPUT p-nro-conta                    /* par_nrdctabb */
                        ,INPUT "CRAP51"                       /* par_cdpesqbb */
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
                        ,INPUT ""                             /* par_cdoperad */
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
                        /* CAMPOS DE SAIDA                                                                     */                                            
                        ,OUTPUT TABLE tt-ret-lancto           /* Collection que contem o retorno do lancamento */
                        ,OUTPUT aux_incrineg                  /* Indicador de critica de negocio               */
                        ,OUTPUT aux_cdcritic                  /* Codigo da critica                             */
                        ,OUTPUT aux_dscritic).                /* Descricao da critica                          */
                        
                      IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                         DO: 
                             /* Tratamento de erros conforme anteriores */
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
                      ELSE 
                         DO:
                           /* Posicionando no registro da craplcm criado acima */
                           FIND FIRST tt-ret-lancto.
                           FIND FIRST craplcm WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm NO-ERROR.
                         END.                
                      
                      IF  VALID-HANDLE(h-b1wgen0200) THEN
                        DELETE PROCEDURE h-b1wgen0200.
                      

                      ASSIGN i-seq-386 =  craplot.nrseqdig + 1.

                      ASSIGN craplot.nrseqdig  = craplot.nrseqdig + 1
                             craplot.qtcompln  = craplot.qtcompln + 1
                             craplot.qtinfoln  = craplot.qtinfoln + 1
                             craplot.vlcompcr  = craplot.vlcompcr +  
                                                 crapmrw.vlchqcop
                             craplot.vlinfocr  = craplot.vlinfocr +  
                                                 crapmrw.vlchqcop.
                  END.
             
         END. /* if  avail crapmrw */

    /* Cheques praça e fora praça serao dinamicos 
       pela influencia do CAF */

    ASSIGN aux_nrsequen = 0.
    
    FOR EACH tt-cheques WHERE tt-cheques.nrdocmto = 6 EXCLUSIVE-LOCK:
        /* Sequencial utilizado para separar um lançamento em conta para cada
           data nao ocorrendo duplicidade de chave */
        ASSIGN aux_nrsequen = aux_nrsequen + 1
               c-docto = c-docto-salvo + /* TIME atribuído anteriormente */
                         STRING(aux_nrsequen,"99") + /* sequenciaL para cada data de liberaçao */
                         STRING(tt-cheques.nrdocmto) /* será sempre 6 */
               /* numero de sequencia sera utilizado para identificar cada
                  cheque(crapchd) do lancamento total da data */
               tt-cheques.nrsequen = aux_nrsequen.

        /*--- Verifica se Lancamento ja Existe ---*/
        FIND FIRST craplcm WHERE
                   craplcm.cdcooper = crapcop.cdcooper    AND
                   craplcm.dtmvtolt = crapdat.dtmvtocd    AND
                   craplcm.cdagenci = p-cod-agencia       AND
                   craplcm.cdbccxlt = 11                  AND
                   craplcm.nrdolote = i-nro-lote          AND
                   craplcm.nrseqdig = craplot.nrseqdig + 1 
                   USE-INDEX craplcm3 NO-LOCK NO-ERROR.

        IF   AVAIL craplcm   THEN 
             DO:
                 ASSIGN i-cod-erro  = 0
                        c-desc-erro = "Lancamento  ja existente".
                 RUN cria-erro (INPUT p-cooper,
                                INPUT p-cod-agencia,
                                INPUT p-nro-caixa,
                                INPUT i-cod-erro,
                                INPUT c-desc-erro,
                                INPUT YES).
                 RETURN "NOK".
             END.

        FIND FIRST craplcm WHERE
                   craplcm.cdcooper = crapcop.cdcooper    AND
                   craplcm.dtmvtolt = crapdat.dtmvtocd    AND
                   craplcm.cdagenci = p-cod-agencia       AND
                   craplcm.cdbccxlt = 11                  AND
                   craplcm.nrdolote = i-nro-lote          AND
                   craplcm.nrdctabb = p-nro-conta         AND
                   craplcm.nrdocmto = inte(c-docto) 
                   USE-INDEX craplcm1 NO-LOCK NO-ERROR.

        IF   AVAIL craplcm   THEN 
             DO:
                 ASSIGN i-cod-erro  = 0
                        c-desc-erro = 
                            "Lancamento(Primario) ja existente".
                 RUN cria-erro (INPUT p-cooper,
                                INPUT p-cod-agencia,
                                INPUT p-nro-caixa,
                                INPUT i-cod-erro,
                                INPUT c-desc-erro,
                                INPUT YES).
                 RETURN "NOK".
             END.
        /*----------------------------------------------------*/        

        /* BLOCO DA INSERÇAO DA CRAPLCM */
        IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
          RUN sistema/generico/procedures/b1wgen0200.p 
            PERSISTENT SET h-b1wgen0200.
            
        RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
          (INPUT crapdat.dtmvtolt               /* par_dtmvtolt */
          ,INPUT p-cod-agencia                  /* par_cdagenci */
          ,INPUT 11                             /* par_cdbccxlt */
          ,INPUT i-nro-lote                     /* par_nrdolote */
          ,INPUT aux_nrdconta                   /* par_nrdconta */
          ,INPUT INT(c-docto)                   /* par_nrdocmto */
          ,INPUT 2433                           /* par_cdhistor */
          ,INPUT craplot.nrseqdig + 1           /* par_nrseqdig */
          ,INPUT tt-cheques.vlcompel            /* par_vllanmto */
          ,INPUT p-nro-conta                    /* par_nrdctabb */
          ,INPUT "CRAP51"                       /* par_cdpesqbb */
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
          ,INPUT ""                             /* par_cdoperad */
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
          /* CAMPOS DE SAIDA                                                                     */                                            
          ,OUTPUT TABLE tt-ret-lancto           /* Collection que contem o retorno do lancamento */
          ,OUTPUT aux_incrineg                  /* Indicador de critica de negocio               */
          ,OUTPUT aux_cdcritic                  /* Codigo da critica                             */
          ,OUTPUT aux_dscritic).                /* Descricao da critica                          */
          
        IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
           DO: 
               /* Tratamento de erros conforme anteriores */
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
        ELSE 
           DO:
             /* Posicionando no registro da craplcm criado acima */
             FIND FIRST tt-ret-lancto.
             FIND FIRST craplcm WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm NO-ERROR.
           END.                
        
        IF  VALID-HANDLE(h-b1wgen0200) THEN
          DELETE PROCEDURE h-b1wgen0200.

               
               /* Guarda o sequencial usado no lancamento */
               tt-cheques.nrseqlcm = craplot.nrseqdig + 1.


        ASSIGN craplot.nrseqdig  = craplot.nrseqdig + 1
               craplot.qtcompln  = craplot.qtcompln + 1
               craplot.qtinfoln  = craplot.qtinfoln + 1
              craplot.vlcompcr  = craplot.vlcompcr + tt-cheques.vlcompel
              craplot.vlinfocr  = craplot.vlinfocr + tt-cheques.vlcompel.
        CREATE crapdpb.
        ASSIGN crapdpb.cdcooper = crapcop.cdcooper
               crapdpb.nrdconta = aux_nrdconta
               crapdpb.dtliblan = tt-cheques.dtlibera
              crapdpb.cdhistor = 2433
               crapdpb.nrdocmto = INT(c-docto)
               crapdpb.dtmvtolt = crapdat.dtmvtocd
               crapdpb.cdagenci = p-cod-agencia
               crapdpb.cdbccxlt = 11
               crapdpb.nrdolote = i-nro-lote
               crapdpb.vllanmto = tt-cheques.vlcompel
               crapdpb.inlibera = 1.
        VALIDATE crapdpb.
                
             END.
       
    FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper  AND
                           crapmdw.cdagenci = p-cod-agencia     AND
                           crapmdw.nrdcaixa = p-nro-caixa       NO-LOCK:

        /* Formata conta integracao */
        RUN fontes/digbbx.p (INPUT  crapmdw.nrctabdb,
                             OUTPUT glb_dsdctitg,
                             OUTPUT glb_stsnrcal).

        FIND FIRST crapchd WHERE crapchd.cdcooper = crapcop.cdcooper    AND
                                 crapchd.dtmvtolt = crapdat.dtmvtocd    AND
                                 crapchd.cdcmpchq = crapmdw.cdcmpchq    AND
                                 crapchd.cdbanchq = crapmdw.cdbanchq    AND
                                 crapchd.cdagechq = crapmdw.cdagechq    AND
                                 crapchd.nrctachq = crapmdw.nrctachq    AND
                                 crapchd.nrcheque = crapmdw.nrcheque  
                                 USE-INDEX crapchd1 NO-LOCK NO-ERROR.

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

        IF   crapmdw.cdhistor = 386   THEN
               ASSIGN i-nrdocmto = INTEGER(c-docto-salvo + "02" + "2").

        /* Buscar de qual sequencia eh o cheque */
        FIND tt-cheques WHERE tt-cheques.dtlibera = crapmdw.dtlibcom AND
                              tt-cheques.nrdocmto = crapmdw.nrdocmto
                              NO-LOCK NO-ERROR.

        IF crapmdw.cdhistor = 2433 THEN
           ASSIGN i-nrdocmto = INTEGER(c-docto-salvo + STRING(tt-cheques.nrsequen,"99") + "6").

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
                                      WHEN NUM-ENTRIES(crapmdw.lsdigctr) = 3
               crapchd.nrddigv2 = INT(ENTRY(2,crapmdw.lsdigctr)) 
                                      WHEN NUM-ENTRIES(crapmdw.lsdigctr) = 3
               crapchd.nrddigv3 = INT(ENTRY(3,crapmdw.lsdigctr)) 
                                      WHEN NUM-ENTRIES(crapmdw.lsdigctr) = 3
               crapchd.nrdolote = i-nro-lote
               crapchd.tpdmovto = crapmdw.tpdmovto
               crapchd.nrterfin = 0
               crapchd.vlcheque = crapmdw.vlcompel.

        IF   crapmdw.cdhistor = 386   THEN
             ASSIGN crapchd.nrseqdig = i-seq-386.
        ELSE
            DO:
                 /* Sequencia dos lancamentos */
                 ASSIGN crapchd.nrseqdig = tt-cheques.nrseqlcm.
                
                /** Incrementa contagem de cheques para a previa **/
                RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
                RUN atualiza-previa-caixa  IN h_b1crap00  (INPUT p-cooper,
                                                           INPUT p-cod-agencia,
                                                           INPUT p-nro-caixa,
                                                           INPUT p-cod-operador,
                                                           INPUT crapdat.dtmvtocd,
                                                           INPUT 1). /*Inclusao*/ 
                DELETE PROCEDURE h_b1crap00.
            END.
                                
        VALIDATE crapchd.

        IF   crapmdw.cdhistor <> 386   THEN NEXT.
        
        /* guarda infos da ultima autenticacao 700 */
        ASSIGN aux-p-literal = p-literal
               aux-p-ult-sequencia = p-ult-sequencia
               aux-p-registro = p-registro.

        RUN autentica_cheques (INPUT p-cooper,                
                               INPUT p-cod-agencia,           
                               INPUT p-nro-conta,             
                               INPUT p-vestorno,             
                               INPUT p-nro-caixa,             
                               INPUT p-cod-operador,
                               INPUT ROWID(crapmdw),
                               INPUT crapdat.dtmvtocd,
                               INPUT 0).             

        /* volta infos da ultima autenticacao 700 */
        ASSIGN p-literal = aux-p-literal
               p-ult-sequencia = aux-p-ult-sequencia
               p-registro = aux-p-registro.
                     
        IF RETURN-VALUE = "NOK" THEN
           RETURN "NOK".
           
        /* Formata conta integracao */
        RUN fontes/digbbx.p (INPUT  crapmdw.nrctabdb,
                             OUTPUT glb_dsdctitg,
                             OUTPUT glb_stsnrcal).

        CREATE crablcm.

        /* Pagamento Cheque */
        
        ASSIGN crablcm.cdcooper = crapcop.cdcooper
               crablcm.dtmvtolt = crapdat.dtmvtocd
               crablcm.cdagenci = p-cod-agencia
               crablcm.cdbccxlt = 11 /* Fixo */
               crablcm.nrdolote = i-nro-lote
               crablcm.dsidenti = p-identifica
               crablcm.nrdconta = crapmdw.nrctaaux
               crablcm.nrdocmto = INT(STRING(crapmdw.nrcheque,"999999") +
                                      STRING(crapmdw.nrddigc3,"9"))
               crablcm.vllanmto = crapmdw.vlcompel
               crablcm.nrseqdig = craplot.nrseqdig + 1
               crablcm.nrdctabb = crapmdw.nrctabdb
               /*crablcm.nrautdoc = p-ult-sequencia*/
               crablcm.nrautdoc = crapmdw.nrautdoc
               crablcm.cdpesqbb = "CRAP51," + crapmdw.cdopelib
               crablcm.nrdctitg = glb_dsdctitg
               
               craplot.nrseqdig = craplot.nrseqdig + 1
               craplot.qtcompln = craplot.qtcompln + 1
               craplot.qtinfoln = craplot.qtinfoln + 1
               craplot.vlcompdb = craplot.vlcompdb + crapmdw.vlcompel
               craplot.vlinfodb = craplot.vlinfodb + crapmdw.vlcompel.
        

        DO aux_contlock = 1 TO 10:
        FIND crabfdc WHERE crabfdc.cdcooper = crapchd.cdcooper   AND
                           crabfdc.cdbanchq = crapchd.cdbanchq   AND
                           crabfdc.cdagechq = crapchd.cdagechq   AND
                           crabfdc.nrctachq = crapchd.nrctachq   AND
                           crabfdc.nrcheque = crapmdw.nrcheque
                           USE-INDEX crapfdc1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
          IF NOT AVAILABLE crabfdc THEN
          DO:
            IF LOCKED(crabfdc) THEN
            DO:
              ASSIGN i-cod-erro  = 0
                     c-desc-erro = "Registro crabfdc esta em uso no momento.".
              PAUSE 1 NO-MESSAGE.
              NEXT.
            END.
            ELSE
             DO:
                 ASSIGN i-cod-erro  = 108
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

          ASSIGN i-cod-erro  = 0
                 c-desc-erro = "".
          LEAVE.
        END. /* fim contador */
        
        IF i-cod-erro <> 0 OR 
           c-desc-erro <> "" THEN
        DO:
          RUN cria-erro (INPUT p-cooper,
                         INPUT p-cod-agencia,
                         INPUT p-nro-caixa,
                         INPUT i-cod-erro,
                         INPUT c-desc-erro,
                         INPUT YES).                      
          RETURN "NOK".
        END.

        ASSIGN crabfdc.incheque = crabfdc.incheque + 5
               crabfdc.dtliqchq = crapdat.dtmvtocd
               crabfdc.cdoperad = p-cod-operador
               crabfdc.vlcheque = crapmdw.vlcompel
               
               /* Associado que recebe o cheque */
               crabfdc.nrctadep = crapass.nrdconta
               crablcm.cdbanchq = crabfdc.cdbanchq
               crablcm.cdagechq = crabfdc.cdagechq
               crablcm.nrctachq = crabfdc.nrctachq.
        
        /* Atualiza os campos de acordo com o tipo da conta do associado que
           recebe o cheque */
           
        /*
        IF  crapass.cdtipcta >= 8    AND
            crapass.cdtipcta <= 11   THEN
            DO:
                /* BANCOOB */
                IF  crapass.cdbcochq = 756 THEN
                    ASSIGN crabfdc.cdbandep = 756
                           crabfdc.cdagedep = crapcop.cdagebcb.
                ELSE*/
                    ASSIGN crabfdc.cdbandep = crapcop.cdbcoctl
                           crabfdc.cdagedep = crapcop.cdagectl.
/*            END.
        ELSE
        /* BANCO DO BRASIL - SEM DIGITO */
             ASSIGN crabfdc.cdbandep = 1
                    crabfdc.cdagedep = INT(SUBSTRING(
                                           STRING(crapcop.cdagedbb),1,
                                           LENGTH(STRING(crapcop.cdagedbb))
                                           - 1)).*/

        IF   crabfdc.tpcheque = 1   THEN
             ASSIGN crablcm.cdhistor = 21.
        ELSE
             ASSIGN crablcm.cdhistor = 26.
        
        VALIDATE crablcm.
    END. /* for each crapmdw */

    IF   de-valor = 0   THEN
         DO:
             ASSIGN i-cod-erro  = 269
                    c-desc-erro = " ".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
          END.
                        
    /*---- Gera literal autenticacao - RECEBIMENTO(Rolo) ----*/
    ASSIGN c-nome-titular1 = " "
           c-nome-titular2 = " ".

    FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper    AND
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
           c-literal[1]  = TRIM(crapcop.nmrescop) + " - " + 
                           TRIM(crapcop.nmextcop)
           c-literal[2]  = " "
           c-literal[3]  = STRING(crapdat.dtmvtocd,"99/99/99") + " " + 
                           STRING(TIME,"HH:MM:SS") +  " PAC " +
                           STRING(p-cod-agencia,"999") + "  CAIXA: " + 
                           STRING(p-nro-caixa,"Z99") + "/" +
                           SUBSTR(p-cod-operador,1,10)
           c-literal[4]  = " "
           c-literal[5]  = "      ** COMPROVANTE DE DEPOSITO " + 
                           STRING(i-nro-docto,"ZZZ,ZZ9")  + " **"
           c-literal[6]  = " "
           c-literal[7]  = "CONTA: "    +  
                           TRIM(STRING(aux_nrdconta,"zzzz,zzz,9"))     +
                           "   PAC: " + TRIM(STRING(crapass.cdagenci)) 
           c-literal[8]  = "       "    +  TRIM(c-nome-titular1)
           c-literal[9]  = "       "    +  TRIM(c-nome-titular2)
           c-literal[10] = " ".
                   
    IF   p-identifica <> "  "   THEN
         ASSIGN c-literal[11] = "DEPOSITADO POR"  
                c-literal[12] = TRIM(p-identifica)
                c-literal[13] = " ".  
             
    ASSIGN c-literal[14] = "   TIPO DE DEPOSITO     VALOR EM R$ LIBERACAO EM"
           c-literal[15] = "------------------------------------------------".

    IF   de-dinheiro > 0   THEN
         ASSIGN c-literal[16] = "   EM DINHEIRO.....: " +  
                                STRING(de-dinheiro,"ZZZ,ZZZ,ZZ9.99") + "   ".

    IF   de-cooperativa > 0   THEN
         ASSIGN c-literal[17] = "CHEQ.COOPERATIVA...: " +  
                                STRING(de-cooperativa,"ZZZ,ZZZ,ZZ9.99") + " ".
    
    ASSIGN c-literal[22] = " "
           c-literal[23] = "TOTAL DEPOSITADO...: " +   
                           STRING(de-valor,"ZZZ,ZZZ,ZZ9.99")
           c-literal[24] = " "
           c-literal[25] = p-literal
           c-literal[26] = " "
           c-literal[27] = " "
           c-literal[28] = " "
           c-literal[29] = " "
           c-literal[30] = " "
           c-literal[31] = " "
           c-literal[32] = " "
           c-literal[33] = " "
           c-literal[34] = " "
           c-literal[35] = " ".

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
         ASSIGN p-literal-autentica =
                p-literal-autentica + STRING(c-literal[11],"x(48)")
                p-literal-autentica =
                p-literal-autentica + STRING(c-literal[12],"x(48)")
                p-literal-autentica =
                p-literal-autentica + STRING(c-literal[13],"x(48)").

    ASSIGN p-literal-autentica =
           p-literal-autentica + STRING(c-literal[14],"x(48)")
           p-literal-autentica =
           p-literal-autentica + STRING(c-literal[15],"x(48)").

    IF   c-literal[16] <> " "   THEN
         ASSIGN p-literal-autentica = p-literal-autentica + 
                                      STRING(c-literal[16],"x(48)").

    IF   c-literal[17] <> " "   THEN
         ASSIGN p-literal-autentica = p-literal-autentica + 
                                      STRING(c-literal[17],"x(48)").
    
    FOR EACH tt-cheques WHERE tt-cheques.nrdocmto = 6 NO-LOCK:
        ASSIGN p-literal-autentica = p-literal-autentica +
                     STRING("CHEQ. OUTROS BANCOS: " +
                                STRING(tt-cheques.vlcompel,"ZZZ,ZZZ,ZZ9.99") +
                            " " +
                                STRING(tt-cheques.dtlibera,"99/99/9999"),
                                "x(48)").
        END.

    ASSIGN c-literal[30] = centraliza("SAC - " + STRING(crapcop.nrtelsac),48)
           c-literal[31] = centraliza("Atendimento todos os dias das " + REPLACE(REPLACE(STRING(crapcop.hrinisac,"HH:MM"),':','h'),'h00','h') + " as " + REPLACE(REPLACE(STRING(crapcop.hrfimsac,"HH:MM"),':','h'),'h00','h'),48)
           c-literal[32] = centraliza("OUVIDORIA - " + STRING(crapcop.nrtelouv),48)
           c-literal[33] = centraliza("Atendimento nos dias uteis das " + REPLACE(REPLACE(STRING(crapcop.hriniouv,"HH:MM"),':','h'),'h00','h') + " as " + REPLACE(REPLACE(STRING(crapcop.hrfimouv,"HH:MM"),':','h'),'h00','h'),48).    

    ASSIGN p-literal-autentica = p-literal-autentica         +
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
                                 STRING(c-literal[32],"x(48)")   +
                                 STRING(c-literal[33],"x(48)")   +
                                 STRING(c-literal[34],"x(48)")   +
                                 STRING(c-literal[35],"x(48)")   +
								 FILL(' ',384).

    ASSIGN p-ult-sequencia-autentica = p-ult-sequencia.

    ASSIGN in99 = 0.
    DO   WHILE TRUE:
         ASSIGN in99 = in99 + 1.
         FIND FIRST crapaut WHERE RECID(crapaut) = p-registro 
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAIL crapaut   THEN 
              DO:
                  IF   LOCKED crapaut   THEN 
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
                  ASSIGN  crapaut.dslitera = p-literal-autentica.
                  RELEASE crapaut.
                  LEAVE.
              END.
    END. /* DO WHILE */

    RELEASE craplot.

    RETURN "OK".

    /*Bloco para tratamento de erro do create da lcm try catch*/
    CATCH eSysError AS Progress.Lang.SysError:
      /*eSysError:GetMessage(1) Pegar a mensagem de erro do sistema*/
      /*Definindo minha propria critica*/
      ASSIGN i-cod-erro  = 0
             c-desc-erro = "Problemas na efetivacao do deposito. Repita a operação. " + eSysError:GetMessage(1).

      run cria-erro (INPUT p-cooper,
                     INPUT p-cod-agencia,
                     INPUT p-nro-caixa,
                     INPUT i-cod-erro,
                     INPUT c-desc-erro,
                     INPUT YES).

      RETURN "NOK".
    END CATCH.

END PROCEDURE.

PROCEDURE atualiza-deposito-com-captura-migrado:

    DEF INPUT  PARAM  p-cooper              AS CHAR NO-UNDO.
    DEF INPUT  PARAM  p-nmcooper            AS CHAR NO-UNDO.
    DEF INPUT  PARAM  p-cod-agencia         AS INT  NO-UNDO. /* Cod.Agencia  */
    DEF INPUT  PARAM  p-nro-caixa           AS INT  NO-UNDO. /* Numero Caixa */
    DEF INPUT  PARAM  p-cod-operador        AS CHAR NO-UNDO.
    DEF INPUT  PARAM  p-nro-conta           AS INT  NO-UNDO.
/*
    DEF INPUT  PARAM pCodAprovador              AS CHAR NO-UNDO.
*/    
    DEF INPUT  PARAM  p-nome-titular            AS CHAR NO-UNDO.
    DEF INPUT  PARAM  p-identifica              AS CHAR NO-UNDO.
    DEF INPUT  PARAM  p-nro-conta-nova          AS INTE NO-UNDO.
    DEF INPUT  PARAM  p-nro-conta-anti          AS INTE NO-UNDO.
    DEF INPUT  PARAM  p-vestorno                AS LOG  NO-UNDO.

    DEF OUTPUT PARAM  p-literal-autentica       AS CHAR NO-UNDO.
    DEF OUTPUT PARAM  p-ult-sequencia-autentica AS INT  NO-UNDO.
    DEF OUTPUT PARAM  p-nro-docto               AS INT  NO-UNDO.

    DEF BUFFER crabcop FOR crapcop.
    DEF BUFFER crabass FOR crapass.

    DEF VAR aux_contalot AS INTE NO-UNDO.
    DEF VAR aux_cdmodali AS INTE NO-UNDO.
    DEF VAR aux_des_erro AS CHAR NO-UNDO.
    DEF VAR aux_dscritic AS CHAR NO-UNDO.
    
    /* Variaveis para rotina de lancamento craplcm */
    DEF VAR h-b1wgen0200 AS HANDLE  NO-UNDO.
    DEF VAR aux_incrineg AS INT     NO-UNDO.
    DEF VAR aux_cdcritic AS INT     NO-UNDO.
    DEF VAR aux_contlock AS INTE NO-UNDO.

    /* cooperativa nova */
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    /* cooperativa antiga */
    FIND crabcop WHERE crabcop.nmrescop = p-nmcooper NO-LOCK NO-ERROR.

    DO   WHILE TRUE:
        
         FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper   AND
                            crapass.nrdconta = INT(p-nro-conta) 
                            NO-LOCK NO-ERROR.
                                  
         IF   NOT AVAIL crapass   THEN 
              LEAVE.

         IF   AVAIL crapass   THEN 
              DO:
                  IF  CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN 
                      DO:
                          FIND FIRST craptrf WHERE 
                                     craptrf.cdcooper = crapcop.cdcooper    AND
                                     craptrf.nrdconta = crapass.nrdconta    AND
                                     craptrf.tptransa = 1                   AND
                                     craptrf.insittrs = 2   
                                     USE-INDEX craptrf1 NO-LOCK NO-ERROR.
    
                          IF   AVAIL craptrf   THEN  
                               ASSIGN aux_nrtrfcta = craptrf.nrsconta
                                      aux_nrdconta = craptrf.nrsconta
                                      p-nro-conta  = craptrf.nrsconta.
                          ELSE 
                              LEAVE.
                      END.
                  ELSE
                      LEAVE.
              END.
    END. /* DO WHILE */
    
    ASSIGN p-nro-conta = DEC(REPLACE(STRING(p-nro-conta),".","")).

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    ASSIGN i-nro-lote = 11000 + p-nro-caixa.

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.

    FIND FIRST crapmrw WHERE crapmrw.cdcooper = crapcop.cdcooper    AND 
                             crapmrw.cdagenci = p-cod-agencia       AND
                             crapmrw.nrdcaixa = p-nro-caixa   
                             NO-LOCK NO-ERROR.
                             
    IF   NOT AVAIL crapmrw   THEN 
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Nao existem valores a serem Depositados ".
                    run cria-erro (INPUT p-cooper,
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
                        c-desc-erro = "Erro de captura. Tente novamente. INF(ENTRY) = " + 
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

    ASSIGN dt-menor-praca  = ?
           dt-maior-praca  = ?
           dt-menor-fpraca = ?
           dt-maior-fpraca = ?
           dt-menor-fpraca = crapdat.dtmvtocd.
           
    ASSIGN aux_nrdconta = p-nro-conta.
    /*--- Verifica se Houve Transferencia de Conta --*/
    ASSIGN aux_nrtrfcta = 0.
    DO   WHILE TRUE:
         FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper   AND
                            crapass.nrdconta = p-nro-conta 
                            NO-LOCK NO-ERROR.
                                  
         IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN 
              DO:
                  FIND FIRST craptrf WHERE
                             craptrf.cdcooper = crapcop.cdcooper    AND
                             craptrf.nrdconta = crapass.nrdconta    AND
                             craptrf.tptransa = 1                   AND
                             craptrf.insittrs = 2   
                             USE-INDEX craptrf1 NO-LOCK NO-ERROR.
                             
                  IF  AVAIL craptrf  THEN
                  ASSIGN aux_nrtrfcta = craptrf.nrsconta
                         aux_nrdconta = craptrf.nrsconta.
                  NEXT.
              END.
         LEAVE.
    END. /* do while */
    IF   aux_nrtrfcta > 0  THEN    /* Transferencia de Conta */
         ASSIGN aux_nrdconta = aux_nrtrfcta.

    ASSIGN p-nro-conta = aux_nrdconta.
    
    ASSIGN l-achou-horario-corte  = no.
    FOR EACH crapmrw WHERE crapmrw.cdcooper = crapcop.cdcooper  AND
                           crapmrw.cdagenci = p-cod-agencia     AND
                           crapmrw.nrdcaixa = p-nro-caixa       NO-LOCK:
                           
        IF  crapmrw.vlchqipr <> 0   OR
            crapmrw.vlchqspr <> 0   OR
            crapmrw.vlchqifp <> 0   OR
            crapmrw.vlchqsfp <> 0   THEN
            ASSIGN l-achou-horario-corte  = yes.
    END.

    IF  l-achou-horario-corte   THEN  
        DO:
            /* Verifica horario de Corte */
            FIND FIRST craptab WHERE craptab.cdcooper = crapcop.cdcooper    AND 
                                     craptab.nmsistem = "CRED"              AND
                                     craptab.tptabela = "GENERI"            AND
                                     craptab.cdempres = 0                   AND
                                     craptab.cdacesso = "HRTRCOMPEL"        AND
                                     craptab.tpregist = p-cod-agencia  
                                     NO-LOCK NO-ERROR.
                                     
            IF  NOT AVAIL craptab   THEN  
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

            IF  INT(SUBSTR(craptab.dstextab,1,1)) <> 0   THEN 
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

            IF  INT(SUBSTR(craptab.dstextab,3,5)) <= TIME   THEN 
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
         END.    /* Verifica Horario de Corte */

    ASSIGN c-docto-salvo = STRING(time).

    ASSIGN de-valor        = 0
           de-dinheiro     = 0
           de-cooperativa  = 0
           de-maior-praca  = 0
           de-menor-praca  = 0
           de-maior-fpraca = 0
           de-menor-fpraca = 0.
    
    /* Montar o Resumo */
    /* Buscar os totais de dinheiro e Cheque Cooperativa */
    FIND FIRST crapmrw WHERE crapmrw.cdcooper = crapcop.cdcooper    AND
                             crapmrw.cdagenci = p-cod-agencia       AND
                             crapmrw.nrdcaixa = p-nro-caixa
                             NO-LOCK NO-ERROR.
                             
    IF   AVAIL crapmrw   THEN 
         DO:
             ASSIGN de-dinheiro     = crapmrw.vldepdin
                    de-cooperativa  = crapmrw.vlchqcop
                    de-valor = de-dinheiro + de-cooperativa.
         END.

    FIND FIRST craptab WHERE craptab.cdcooper = crapcop.cdcooper    AND
                             craptab.nmsistem = "CRED"              AND
                             craptab.tptabela = "USUARI"            AND
                             craptab.cdempres = 11                  AND
                             craptab.cdacesso = "MAIORESCHQ"        AND
                             craptab.tpregist = 1 
                             NO-LOCK NO-ERROR.
      
    /* Buscar os totais de cheque maior e menor da Praca ou fora Praca */
    FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper AND
                           crapmdw.cdagenci = p-cod-agencia    AND
                           crapmdw.nrdcaixa = p-nro-caixa NO-LOCK:
        
        FIND tt-cheques WHERE tt-cheques.dtlibera = crapmdw.dtlibcom AND
                              tt-cheques.nrdocmto = crapmdw.nrdocmto
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL tt-cheques  THEN
            CREATE tt-cheques.

        IF  crapmdw.vlcompel < DEC(SUBSTR(craptab.dstextab,1,15))  THEN
            ASSIGN  aux_tpdmovto = 2.
        ELSE
            ASSIGN  aux_tpdmovto = 1.                
        
        IF  crapmdw.cdhistor = 2433  THEN
            ASSIGN tt-cheques.nrdocmto = 6
                   tt-cheques.dtlibera = crapmdw.dtlibcom
                   tt-cheques.vlcompel = tt-cheques.vlcompel + crapmdw.vlcompel
                   de-valor = de-valor + crapmdw.vlcompel.
        
        FIND CURRENT tt-cheques NO-LOCK.
        
    END.    
    /* Fim da montagem do Resumo */     
         
    ASSIGN i-nro-docto = INT(c-docto-salvo)
           p-nro-docto = INT(c-docto-salvo).
    
    /*--- Grava Autenticacao Arquivo/Spool --*/
    RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
    RUN grava-autenticacao  IN h_b1crap00 (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT p-nro-caixa,
                                           INPUT p-cod-operador,
                                           INPUT de-valor,
                                           INPUT dec(i-nro-docto),
                                           INPUT NO, /* YES (PG), NO (REC) */
                                           INPUT "1",  /* On-line  */     
                                           INPUT NO,   /* Nao estorno */     
                                           INPUT 700,
                                           INPUT ?, /* Data off-line */
                                           INPUT 0, /* Sequencia off-line */
                                           INPUT 0, /* Hora off-line */
                                           INPUT 0, /* Seq.orig.Off-line */
                                           OUTPUT p-literal,
                                           OUTPUT p-ult-sequencia,
                                           OUTPUT p-registro).
    DELETE PROCEDURE h_b1crap00.

    IF   RETURN-VALUE = "NOK"  THEN
         RETURN "NOK".

    /* 5 tentativas para pegar lock no craplot */
    DO aux_contalot = 1 TO 5:
    
        FIND FIRST craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                                 craplot.dtmvtolt = crapdat.dtmvtocd  AND
                                 craplot.cdagenci = p-cod-agencia     AND
                                 craplot.cdbccxlt = 11                AND /* Fixo */
                                 craplot.nrdolote = i-nro-lote 
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
             
        IF  NOT AVAIL craplot  THEN 
        DO: 
            IF  LOCKED(craplot) THEN
            DO:
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Registro de lote esta em uso no momento.".
                PAUSE 1 NO-MESSAGE.
                NEXT.
            END.
            ELSE
            DO:
                CREATE craplot.
                ASSIGN craplot.cdcooper = crapcop.cdcooper
                       craplot.dtmvtolt = crapdat.dtmvtocd
                       craplot.cdagenci = p-cod-agencia
                       craplot.cdbccxlt = 11
                       craplot.nrdolote = i-nro-lote
                       craplot.tplotmov = 1
                       craplot.cdoperad = p-cod-operador
                       craplot.cdhistor = 0 /* 700 */
                       craplot.nrdcaixa = p-nro-caixa
                       craplot.cdopecxa = p-cod-operador.
            END.
        END.
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "".
        LEAVE.
    END.

    IF  i-cod-erro > 0 OR
        c-desc-erro <> "" THEN
    DO:
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.
         
    IF   AVAIL crapmrw   THEN  
         DO:
         
             /* Formata conta integracao */
             RUN fontes/digbbx.p (INPUT  p-nro-conta,
                                  OUTPUT glb_dsdctitg,
                                  OUTPUT glb_stsnrcal).
         
             /* Dinheiro */
             IF   crapmrw.vldepdin <> 0   THEN 
                  DO:
                      ASSIGN c-docto = c-docto-salvo + 
                                       /* 'Sequencial' fixo 01 */
                                       "01" + 
                                       "1".

                      /*--- Verifica se Lancamento ja Existe ---*/
                      FIND FIRST craplcm WHERE
                                 craplcm.cdcooper = crapcop.cdcooper    AND
                                 craplcm.dtmvtolt = crapdat.dtmvtocd    AND
                                 craplcm.cdagenci = p-cod-agencia       AND
                                 craplcm.cdbccxlt = 11                  AND
                                 craplcm.nrdolote = i-nro-lote          AND
                                 craplcm.nrseqdig = craplot.nrseqdig + 1 
                                 USE-INDEX craplcm3 NO-LOCK NO-ERROR.

                      IF   AVAIL craplcm THEN   
                           DO:
                               ASSIGN i-cod-erro  = 0
                                      c-desc-erro = "Lancamento ja existente".
                               RUN cria-erro (INPUT p-cooper,
                                              INPUT p-cod-agencia,
                                              INPUT p-nro-caixa,
                                              INPUT i-cod-erro,
                                              INPUT c-desc-erro,
                                              INPUT YES).
                               RETURN "NOK".
                           END.

                      FIND FIRST craplcm WHERE 
                                 craplcm.cdcooper = crapcop.cdcooper    AND
                                 craplcm.dtmvtolt = crapdat.dtmvtocd    AND
                                 craplcm.cdagenci = p-cod-agencia       AND
                                 craplcm.cdbccxlt = 11                  AND
                                 craplcm.nrdolote = i-nro-lote          AND
                                 craplcm.nrdctabb = p-nro-conta         AND
                                 craplcm.nrdocmto = INT(c-docto) 
                                 USE-INDEX craplcm1 NO-LOCK NO-ERROR.

                      IF   AVAIL craplcm   THEN 
                           DO:
                               ASSIGN i-cod-erro  = 0
                                      c-desc-erro = 
                                          "Lancamento(Primario) ja existente".
                               RUN cria-erro (INPUT p-cooper,
                                              INPUT p-cod-agencia,
                                              INPUT p-nro-caixa,
                                              INPUT i-cod-erro,
                                              INPUT c-desc-erro,
                                              INPUT YES).
                               RETURN "NOK".
                           END.
                      
                      /* BLOCO DA INSERÇAO DA CRAPLCM */
                      IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
                        RUN sistema/generico/procedures/b1wgen0200.p 
                          PERSISTENT SET h-b1wgen0200.
                          
                      RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
                        (INPUT crapdat.dtmvtolt               /* par_dtmvtolt */
                        ,INPUT p-cod-agencia                  /* par_cdagenci */
                        ,INPUT 11                             /* par_cdbccxlt */
                        ,INPUT i-nro-lote                     /* par_nrdolote */
                        ,INPUT aux_nrdconta                   /* par_nrdconta */
                        ,INPUT INTE(c-docto)                  /* par_nrdocmto */
                        ,INPUT 1                              /* par_cdhistor */
                        ,INPUT craplot.nrseqdig + 1           /* par_nrseqdig */
                        ,INPUT crapmrw.vldepdin               /* par_vllanmto */
                        ,INPUT p-nro-conta                    /* par_nrdctabb */
                        ,INPUT "CRAP51"                       /* par_cdpesqbb */
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
                        ,INPUT ""                             /* par_cdoperad */
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
                        /* CAMPOS DE SAIDA                                                                     */                                            
                        ,OUTPUT TABLE tt-ret-lancto           /* Collection que contem o retorno do lancamento */
                        ,OUTPUT aux_incrineg                  /* Indicador de critica de negocio               */
                        ,OUTPUT aux_cdcritic                  /* Codigo da critica                             */
                        ,OUTPUT aux_dscritic).                /* Descricao da critica                          */
                        
                      IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                         DO: 
                             /* Tratamento de erros conforme anteriores */
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
                      ELSE 
                         DO:
                           /* Posicionando no registro da craplcm criado acima */
                           FIND FIRST tt-ret-lancto.
                           FIND FIRST craplcm WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm NO-ERROR.
                         END.                
                      
                      IF  VALID-HANDLE(h-b1wgen0200) THEN
                        DELETE PROCEDURE h-b1wgen0200.
                           

                      ASSIGN craplot.nrseqdig  = craplot.nrseqdig + 1
                             craplot.qtcompln  = craplot.qtcompln + 1
                             craplot.qtinfoln  = craplot.qtinfoln + 1
                             craplot.vlcompcr  = craplot.vlcompcr + 
                                                 crapmrw.vldepdin              
                             craplot.vlinfocr  = craplot.vlinfocr +  
                                                 crapmrw.vldepdin.
                      /*tiago*/
                  END.
             
             /* Cheque Cooperativa */
             IF   crapmrw.vlchqcop <> 0   THEN 
                  DO:
                      ASSIGN c-docto = c-docto-salvo + 
                                      /* 'Sequencial' fixo 01 */
                                      "01" + 
                                      "2".

                      /*--- Verifica se Lancamento ja Existe ---*/
                      FIND FIRST craplcm WHERE
                                 craplcm.cdcooper = crapcop.cdcooper    AND
                                 craplcm.dtmvtolt = crapdat.dtmvtocd    AND
                                 craplcm.cdagenci = p-cod-agencia       AND
                                 craplcm.cdbccxlt = 11                  AND
                                 craplcm.nrdolote = i-nro-lote          AND
                                 craplcm.nrseqdig = craplot.nrseqdig + 1 
                                 USE-INDEX craplcm3 NO-LOCK NO-ERROR.

                      IF   AVAIL craplcm   THEN 
                           DO:
                               ASSIGN i-cod-erro  = 0
                                      c-desc-erro = "Lancamento  ja existente".
                               RUN cria-erro (INPUT p-cooper,
                                              INPUT p-cod-agencia,
                                              INPUT p-nro-caixa,
                                              INPUT i-cod-erro,
                                              INPUT c-desc-erro,
                                              INPUT YES).
                               RETURN "NOK".
                           END.

                      FIND FIRST craplcm WHERE
                                 craplcm.cdcooper = crapcop.cdcooper    AND
                                 craplcm.dtmvtolt = crapdat.dtmvtocd    AND
                                 craplcm.cdagenci = p-cod-agencia       AND
                                 craplcm.cdbccxlt = 11                  AND
                                 craplcm.nrdolote = i-nro-lote          AND
                                 craplcm.nrdctabb = p-nro-conta         AND
                                 craplcm.nrdocmto = inte(c-docto) 
                                 USE-INDEX craplcm1 NO-LOCK NO-ERROR.
                                 
                      IF   AVAIL craplcm   THEN 
                           DO:
                               ASSIGN i-cod-erro  = 0
                                      c-desc-erro = "Lancamento(Primario) ja " +
                                                    "existente".
                               RUN cria-erro (INPUT p-cooper,
                                              INPUT p-cod-agencia,
                                              INPUT p-nro-caixa,
                                              INPUT i-cod-erro,
                                              INPUT c-desc-erro,
                                              INPUT YES).
                               RETURN "NOK".
                           END.
                      
                      /* BLOCO DA INSERÇAO DA CRAPLCM */
                      IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
                        RUN sistema/generico/procedures/b1wgen0200.p 
                          PERSISTENT SET h-b1wgen0200.
                          
                      RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
                        (INPUT crapdat.dtmvtolt               /* par_dtmvtolt */
                        ,INPUT p-cod-agencia                  /* par_cdagenci */
                        ,INPUT 11                             /* par_cdbccxlt */
                        ,INPUT i-nro-lote                     /* par_nrdolote */
                        ,INPUT aux_nrdconta                   /* par_nrdconta */
                        ,INPUT INT(c-docto)                   /* par_nrdocmto */
                        ,INPUT 386                            /* par_cdhistor */
                        ,INPUT craplot.nrseqdig + 1           /* par_nrseqdig */
                        ,INPUT crapmrw.vlchqcop               /* par_vllanmto */
                        ,INPUT p-nro-conta                    /* par_nrdctabb */
                        ,INPUT "CRAP51"                       /* par_cdpesqbb */
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
                        ,INPUT ""                             /* par_cdoperad */
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
                        /* CAMPOS DE SAIDA                                                                     */                                            
                        ,OUTPUT TABLE tt-ret-lancto           /* Collection que contem o retorno do lancamento */
                        ,OUTPUT aux_incrineg                  /* Indicador de critica de negocio               */
                        ,OUTPUT aux_cdcritic                  /* Codigo da critica                             */
                        ,OUTPUT aux_dscritic).                /* Descricao da critica                          */
                        
                      IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                         DO: 
                             /* Tratamento de erros conforme anteriores */
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
                      ELSE 
                         DO:
                           /* Posicionando no registro da craplcm criado acima */
                           FIND FIRST tt-ret-lancto.
                           FIND FIRST craplcm WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm NO-ERROR.
                         END.                
                      
                      IF  VALID-HANDLE(h-b1wgen0200) THEN
                        DELETE PROCEDURE h-b1wgen0200.


                      ASSIGN i-seq-386 =  craplot.nrseqdig + 1.

                      ASSIGN craplot.nrseqdig  = craplot.nrseqdig + 1
                             craplot.qtcompln  = craplot.qtcompln + 1
                             craplot.qtinfoln  = craplot.qtinfoln + 1
                             craplot.vlcompcr  = craplot.vlcompcr +  
                                                 crapmrw.vlchqcop
                             craplot.vlinfocr  = craplot.vlinfocr +  
                                                 crapmrw.vlchqcop.
                  END.
             
         END. /* if  avail crapmrw */

    /* Cheques praça e fora praça serao dinamicos 
       pela influencia do CAF */
    ASSIGN aux_nrsequen = 0.
    
    FOR EACH tt-cheques WHERE tt-cheques.nrdocmto = 6 EXCLUSIVE-LOCK:

        /* Sequencial utilizado para separar um lançamento em conta para cada
           data nao ocorrendo duplicidade de chave */
        ASSIGN aux_nrsequen = aux_nrsequen + 1
               c-docto = c-docto-salvo + /* TIME atribuído anteriormente */
                         STRING(aux_nrsequen,"99") + /* sequenciaL para cada data de liberaçao */
                         STRING(tt-cheques.nrdocmto) /* será sempre 6 */
               /* numero de sequencia sera utilizado para identificar cada
                  cheque(crapchd) do lancamento total da data */
               tt-cheques.nrsequen = aux_nrsequen.

        /*--- Verifica se Lancamento ja Existe ---*/
        FIND FIRST craplcm WHERE
                   craplcm.cdcooper = crapcop.cdcooper    AND
                   craplcm.dtmvtolt = crapdat.dtmvtocd    AND
                   craplcm.cdagenci = p-cod-agencia       AND
                   craplcm.cdbccxlt = 11                  AND
                   craplcm.nrdolote = i-nro-lote          AND
                   craplcm.nrseqdig = craplot.nrseqdig + 1 
                   USE-INDEX craplcm3 NO-LOCK NO-ERROR.

        IF   AVAIL craplcm   THEN 
             DO:
                 ASSIGN i-cod-erro  = 0
                        c-desc-erro = "Lancamento  ja existente".
                 RUN cria-erro (INPUT p-cooper,
                                INPUT p-cod-agencia,
                                INPUT p-nro-caixa,
                                INPUT i-cod-erro,
                                INPUT c-desc-erro,
                                INPUT YES).
                 RETURN "NOK".
             END.

        FIND FIRST craplcm WHERE
                   craplcm.cdcooper = crapcop.cdcooper    AND
                   craplcm.dtmvtolt = crapdat.dtmvtocd    AND
                   craplcm.cdagenci = p-cod-agencia       AND
                   craplcm.cdbccxlt = 11                  AND
                   craplcm.nrdolote = i-nro-lote          AND
                   craplcm.nrdctabb = p-nro-conta         AND
                   craplcm.nrdocmto = inte(c-docto) 
                   USE-INDEX craplcm1 NO-LOCK NO-ERROR.

        IF   AVAIL craplcm   THEN 
             DO:
                 ASSIGN i-cod-erro  = 0
                        c-desc-erro = 
                            "Lancamento(Primario) ja existente".
                 RUN cria-erro (INPUT p-cooper,
                                INPUT p-cod-agencia,
                                INPUT p-nro-caixa,
                                INPUT i-cod-erro,
                                INPUT c-desc-erro,
                                INPUT YES).
                 RETURN "NOK".
             END.
        
        /*----------------------------------------------------*/        

        /* BLOCO DA INSERÇAO DA CRAPLCM */
        IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
          RUN sistema/generico/procedures/b1wgen0200.p 
            PERSISTENT SET h-b1wgen0200.
            
        RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
          (INPUT crapdat.dtmvtolt               /* par_dtmvtolt */
          ,INPUT p-cod-agencia                  /* par_cdagenci */
          ,INPUT 11                             /* par_cdbccxlt */
          ,INPUT i-nro-lote                     /* par_nrdolote */
          ,INPUT aux_nrdconta                   /* par_nrdconta */
          ,INPUT INT(c-docto)                   /* par_nrdocmto */
          ,INPUT 2433                           /* par_cdhistor */
          ,INPUT craplot.nrseqdig + 1           /* par_nrseqdig */
          ,INPUT tt-cheques.vlcompel            /* par_vllanmto */
          ,INPUT p-nro-conta                    /* par_nrdctabb */
          ,INPUT "CRAP51"                       /* par_cdpesqbb */
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
          ,INPUT ""                             /* par_cdoperad */
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
          /* CAMPOS DE SAIDA                                                                     */                                            
          ,OUTPUT TABLE tt-ret-lancto           /* Collection que contem o retorno do lancamento */
          ,OUTPUT aux_incrineg                  /* Indicador de critica de negocio               */
          ,OUTPUT aux_cdcritic                  /* Codigo da critica                             */
          ,OUTPUT aux_dscritic).                /* Descricao da critica                          */
          
        IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
           DO: 
               /* Tratamento de erros conforme anteriores */
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
        ELSE 
           DO:
             /* Posicionando no registro da craplcm criado acima */
             FIND FIRST tt-ret-lancto.
             FIND FIRST craplcm WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm NO-ERROR.
           END.                
        
        IF  VALID-HANDLE(h-b1wgen0200) THEN
          DELETE PROCEDURE h-b1wgen0200.

               
               /* Guarda o sequencial usado no lancamento */
               tt-cheques.nrseqlcm = craplot.nrseqdig + 1.

        ASSIGN craplot.nrseqdig  = craplot.nrseqdig + 1
               craplot.qtcompln  = craplot.qtcompln + 1
               craplot.qtinfoln  = craplot.qtinfoln + 1
               craplot.vlcompcr  = craplot.vlcompcr +  
                                   tt-cheques.vlcompel
               craplot.vlinfocr  = craplot.vlinfocr +  
                                   tt-cheques.vlcompel.
        CREATE crapdpb.
        ASSIGN crapdpb.cdcooper = crapcop.cdcooper
               crapdpb.nrdconta = aux_nrdconta
               crapdpb.dtliblan = tt-cheques.dtlibera
              crapdpb.cdhistor = 2433
               crapdpb.nrdocmto = INT(c-docto)
               crapdpb.dtmvtolt = crapdat.dtmvtocd
               crapdpb.cdagenci = p-cod-agencia
               crapdpb.cdbccxlt = 11
               crapdpb.nrdolote = i-nro-lote
               crapdpb.vllanmto = tt-cheques.vlcompel
               crapdpb.inlibera = 1.
        VALIDATE crapdpb.
       
             END.
        

    FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper  AND
                           crapmdw.cdagenci = p-cod-agencia     AND
                           crapmdw.nrdcaixa = p-nro-caixa       NO-LOCK:
        
        /* Formata conta integracao */
        RUN fontes/digbbx.p (INPUT  crapmdw.nrctabdb,
                             OUTPUT glb_dsdctitg,
                             OUTPUT glb_stsnrcal).

        /* Validar o chd na cooperativa geradora do cheque */
        FIND FIRST crapchd WHERE crapchd.cdcooper = crapmdw.cdcooper    AND
                                 crapchd.dtmvtolt = crapdat.dtmvtocd    AND
                                 crapchd.cdcmpchq = crapmdw.cdcmpchq    AND
                                 crapchd.cdbanchq = crapmdw.cdbanchq    AND
                                 crapchd.cdagechq = crapmdw.cdagechq    AND
                                 crapchd.nrctachq = crapmdw.nrctachq    AND
                                 crapchd.nrcheque = crapmdw.nrcheque  
                                 USE-INDEX crapchd1 NO-LOCK NO-ERROR.

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

        IF   crapmdw.cdhistor = 386   THEN
               ASSIGN i-nrdocmto = INTEGER(c-docto-salvo + "02" + "2").

        /* Buscar de qual sequencia eh o cheque */
        FIND tt-cheques WHERE tt-cheques.dtlibera = crapmdw.dtlibcom AND
                              tt-cheques.nrdocmto = crapmdw.nrdocmto
                              NO-LOCK NO-ERROR.

        IF  crapmdw.cdhistor = 2433 THEN 
            ASSIGN i-nrdocmto = INTEGER(c-docto-salvo + STRING(tt-cheques.nrsequen,"99") + "6").

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
                                      WHEN NUM-ENTRIES(crapmdw.lsdigctr) = 3
               crapchd.nrddigv2 = INT(ENTRY(2,crapmdw.lsdigctr)) 
                                      WHEN NUM-ENTRIES(crapmdw.lsdigctr) = 3
               crapchd.nrddigv3 = INT(ENTRY(3,crapmdw.lsdigctr)) 
                                      WHEN NUM-ENTRIES(crapmdw.lsdigctr) = 3
               crapchd.nrdolote = i-nro-lote
               crapchd.tpdmovto = crapmdw.tpdmovto
               crapchd.nrterfin = 0
               crapchd.vlcheque = crapmdw.vlcompel.

        IF   crapmdw.cdhistor = 386   THEN
             ASSIGN crapchd.nrseqdig = i-seq-386.
        ELSE
            DO:     
                /* Sequencia dos lancamentos */
                ASSIGN crapchd.nrseqdig = tt-cheques.nrseqlcm.
    
                /** Incrementa contagem de cheques para a previa **/
                RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
                RUN atualiza-previa-caixa  IN h_b1crap00  (INPUT p-cooper,
                                                           INPUT p-cod-agencia,
                                                           INPUT p-nro-caixa,
                                                           INPUT p-cod-operador,
                                                           INPUT crapdat.dtmvtocd,
                                                           INPUT 1). /*Inclusao*/ 
                DELETE PROCEDURE h_b1crap00.
            END.
        VALIDATE crapchd.     
        
        IF   crapmdw.cdhistor <> 386   THEN NEXT.

        /* guarda infos da ultima autenticacao 700 */
        ASSIGN aux-p-literal = p-literal
               aux-p-ult-sequencia = p-ult-sequencia
               aux-p-registro = p-registro.

        RUN autentica_cheques (INPUT p-cooper,                
                               INPUT p-cod-agencia,           
                               INPUT p-nro-conta,             
                               INPUT p-vestorno,             
                               INPUT p-nro-caixa,             
                               INPUT p-cod-operador,
                               INPUT ROWID(crapmdw),
                               INPUT crapdat.dtmvtocd,
                               INPUT 0).             

        /* volta infos da ultima autenticacao 700 */
        ASSIGN p-literal = aux-p-literal
               p-ult-sequencia = aux-p-ult-sequencia
               p-registro = aux-p-registro.

        
        IF RETURN-VALUE = "NOK" THEN
           RETURN "NOK".

        
        /* Formata conta integracao */
        RUN fontes/digbbx.p (INPUT  crapmdw.nrctabdb,
                             OUTPUT glb_dsdctitg,
                             OUTPUT glb_stsnrcal).

        DO aux_contlock = 1 TO 10:
        FIND crabfdc WHERE crabfdc.cdcooper = crapcop.cdcooper   AND
                           crabfdc.cdbanchq = crapchd.cdbanchq   AND
                           crabfdc.cdagechq = crapchd.cdagechq   AND
                           crabfdc.nrctachq = crapchd.nrctachq   AND
                           crabfdc.nrcheque = crapmdw.nrcheque
                             USE-INDEX crapfdc1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
          IF AVAILABLE crabfdc THEN
        DO:  
             CREATE crablcm.
             
             /* Pagamento Cheque */
             
             ASSIGN crablcm.cdcooper = crapcop.cdcooper
                    crablcm.dtmvtolt = crapdat.dtmvtocd
                    crablcm.cdagenci = p-cod-agencia
                    crablcm.cdbccxlt = 11 /* Fixo */
                    crablcm.nrdolote = i-nro-lote
                    crablcm.dsidenti = p-identifica
                    crablcm.nrdconta = crapmdw.nrctaaux
                    crablcm.nrdocmto = INT(STRING(crapmdw.nrcheque,"999999") +
                                           STRING(crapmdw.nrddigc3,"9"))
                    crablcm.vllanmto = crapmdw.vlcompel
                    crablcm.nrseqdig = craplot.nrseqdig + 1
                    crablcm.nrdctabb = crapmdw.nrctabdb
                    /*crablcm.nrautdoc = p-ult-sequencia*/
                    crablcm.nrautdoc = crapmdw.nrautdoc
                    crablcm.cdpesqbb = "CRAP51," + crapmdw.cdopelib
                    crablcm.nrdctitg = glb_dsdctitg
             
                    craplot.nrseqdig = craplot.nrseqdig + 1
                    craplot.qtcompln = craplot.qtcompln + 1
                    craplot.qtinfoln = craplot.qtinfoln + 1
                    craplot.vlcompdb = craplot.vlcompdb + crapmdw.vlcompel
                    craplot.vlinfodb = craplot.vlinfodb + crapmdw.vlcompel.
             
             
             ASSIGN crabfdc.incheque = crabfdc.incheque + 5
                    crabfdc.dtliqchq = crapdat.dtmvtocd
                    crabfdc.cdoperad = "1" /* SUPER-USUARIO para migracao */
                    crabfdc.vlcheque = crapmdw.vlcompel
             
                    /* Associado que recebe o cheque */
                    crabfdc.nrctadep = p-nro-conta
                    crablcm.cdbanchq = crabfdc.cdbanchq
                    crablcm.cdagechq = crabfdc.cdagechq
                    crablcm.nrctachq = crabfdc.nrctachq.
             
             /* Atualiza os campos de acordo com o tipo da conta do associado que
                recebe o cheque */

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
             
             IF  aux_cdmodali = 3 THEN
                 DO:
                     /* BANCOOB */
                     IF  crapass.cdbcochq = 756 THEN
                         ASSIGN crabfdc.cdbandep = 756
                                crabfdc.cdagedep = crapcop.cdagebcb.
                     ELSE
                         ASSIGN crabfdc.cdbandep = crapcop.cdbcoctl
                                crabfdc.cdagedep = crapcop.cdagectl.
                 END.
             ELSE
             /* BANCO DO BRASIL - SEM DIGITO */
                  ASSIGN crabfdc.cdbandep = 1
                         crabfdc.cdagedep = INT(SUBSTRING(
                                                STRING(crapcop.cdagedbb),1,
                                                LENGTH(STRING(crapcop.cdagedbb))
                                                - 1)).
             
             IF   crabfdc.tpcheque = 1   THEN
                  ASSIGN crablcm.cdhistor = 21.
             ELSE
                  ASSIGN crablcm.cdhistor = 26.

             VALIDATE crablcm.
         END.
         ELSE
         DO:
            IF LOCKED(crabfdc) THEN
            DO:
              ASSIGN i-cod-erro  = 0
                     c-desc-erro = "Registro crabfdc esta em uso no momento.".
              PAUSE 1 NO-MESSAGE.
              NEXT.
            END.
            ELSE /* nao existe */
            DO:
             /* verifica se o cheque eh da cooperativa migrada */
             FIND crabfdc WHERE crabfdc.cdcooper = crabcop.cdcooper   AND
                                crabfdc.cdbanchq = crapchd.cdbanchq   AND
                                crabfdc.cdagechq = crapchd.cdagechq   AND
                                crabfdc.nrctachq = crapchd.nrctachq   AND
                                crabfdc.nrcheque = crapmdw.nrcheque
                                USE-INDEX crapfdc1 EXCLUSIVE-LOCK NO-ERROR.
             IF  AVAIL crabfdc  THEN
             DO:             
                 /* verifica se a conta do cheque eh migrada */
                 FIND craptco WHERE craptco.cdcopant = crabfdc.cdcooper AND
                                    craptco.nrctaant = crabfdc.nrdconta AND
                                    craptco.tpctatrf = 1                AND
                                    craptco.flgativo = TRUE
                                    NO-LOCK NO-ERROR.
                 IF  AVAIL craptco  THEN
                 DO: 
                     
                     CREATE crablcm.
                 
                     /* Pagamento Cheque */                 

                     ASSIGN crablcm.cdcooper = crapcop.cdcooper
                            crablcm.dtmvtolt = crapdat.dtmvtocd
                            crablcm.cdagenci = craplot.cdagenci
                            crablcm.cdbccxlt = craplot.cdbccxlt
                            crablcm.nrdolote = craplot.nrdolote
                            crablcm.dsidenti = p-identifica
                            crablcm.nrdconta = craptco.nrdconta
                            crablcm.nrdocmto = INT(STRING(crapmdw.nrcheque,"999999") +
                                                   STRING(crapmdw.nrddigc3,"9"))
                            crablcm.vllanmto = crapmdw.vlcompel
                            crablcm.nrseqdig = craplot.nrseqdig + 1
                            crablcm.nrdctabb = crapmdw.nrctabdb
                            /*crablcm.nrautdoc = p-ult-sequencia*/
                            crablcm.nrautdoc = crapmdw.nrautdoc
                            crablcm.cdpesqbb = "CRAP51," + crapmdw.cdopelib
                            crablcm.nrdctitg = glb_dsdctitg
                 
                            craplot.nrseqdig = craplot.nrseqdig + 1
                            craplot.qtcompln = craplot.qtcompln + 1
                            craplot.qtinfoln = craplot.qtinfoln + 1
                            craplot.vlcompdb = craplot.vlcompdb + crapmdw.vlcompel
                            craplot.vlinfodb = craplot.vlinfodb + crapmdw.vlcompel.
                 
                 
                     ASSIGN crabfdc.incheque = crabfdc.incheque + 5
                            crabfdc.dtliqchq = crapdat.dtmvtocd
                            crabfdc.cdoperad = "1" /* SUPER-USUARIO para migracao */
                            crabfdc.vlcheque = crapmdw.vlcompel
                 
                            /* Associado que recebe o cheque */
                            crabfdc.nrctadep = crapass.nrdconta
                            crablcm.cdbanchq = crabfdc.cdbanchq
                            crablcm.cdagechq = crabfdc.cdagechq
                            crablcm.nrctachq = crabfdc.nrctachq.

                     IF  crapass.cdtipcta >= 8    AND
                         crapass.cdtipcta <= 11   THEN
                         DO:
                             /* BANCOOB */
                             IF  crapass.cdbcochq = 756 THEN
                                 ASSIGN crabfdc.cdbandep = 756
                                        crabfdc.cdagedep = crapcop.cdagebcb.
                             ELSE
                                 ASSIGN crabfdc.cdbandep = crapcop.cdbcoctl
                                        crabfdc.cdagedep = crapcop.cdagectl.
                         END.
                     ELSE
                     /* BANCO DO BRASIL - SEM DIGITO */
                          ASSIGN crabfdc.cdbandep = 1
                                 crabfdc.cdagedep = INT(SUBSTRING(
                                                        STRING(crapcop.cdagedbb),1,
                                                        LENGTH(STRING(crapcop.cdagedbb))
                                                        - 1)).

                     IF   crabfdc.tpcheque = 1   THEN
                          ASSIGN crablcm.cdhistor = 21.
                     ELSE
                          ASSIGN crablcm.cdhistor = 26.

                     VALIDATE crablcm. 
                 END.
              END. /* fim AVAIL crabfdc */

            END. /* fim nao existe */
          END. /* fim not avail */ 

          ASSIGN i-cod-erro  = 0
                 c-desc-erro = "".
          LEAVE.

        END. /* fim contador */

        IF i-cod-erro <> 0 OR 
           c-desc-erro <> "" THEN
        DO:
          RUN cria-erro (INPUT p-cooper,
                         INPUT p-cod-agencia,
                         INPUT p-nro-caixa,
                         INPUT i-cod-erro,
                         INPUT c-desc-erro,
                         INPUT YES).                      
          RETURN "NOK".
         END.


    END. /* for each crapmdw */

    IF   de-valor = 0   THEN
         DO:
             ASSIGN i-cod-erro  = 269
                    c-desc-erro = " ".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
          END.
                        
    /*---- Gera literal autenticacao - RECEBIMENTO(Rolo) ----*/
    ASSIGN c-nome-titular1 = " "
           c-nome-titular2 = " ".

    FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper    AND
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
           c-literal[1]  = TRIM(crapcop.nmrescop) + " - " + 
                           TRIM(crapcop.nmextcop)
           c-literal[2]  = " "
           c-literal[3]  = STRING(crapdat.dtmvtocd,"99/99/99") + " " + 
                           STRING(TIME,"HH:MM:SS") +  " PAC " +
                           STRING(p-cod-agencia,"999") + "  CAIXA: " + 
                           STRING(p-nro-caixa,"Z99") + "/" +
                           SUBSTR(p-cod-operador,1,10)
           c-literal[4]  = " "
           c-literal[5]  = "      ** COMPROVANTE DE DEPOSITO " + 
                           STRING(i-nro-docto,"ZZZ,ZZ9")  + " **"
           c-literal[6]  = " "
           c-literal[7]  = "CONTA: "    +  
                           TRIM(STRING(aux_nrdconta,"zzzz,zzz,9"))     +
                           "   PAC: " + TRIM(STRING(crapass.cdagenci)) 
           c-literal[8]  = "       "    +  TRIM(c-nome-titular1)
           c-literal[9]  = "       "    +  TRIM(c-nome-titular2)
           c-literal[10] = " ".
                   
    IF   p-identifica <> "  "   THEN
         ASSIGN c-literal[11] = "DEPOSITADO POR"  
                c-literal[12] = TRIM(p-identifica)
                c-literal[13] = " ".  
             
    ASSIGN c-literal[14] = "   TIPO DE DEPOSITO     VALOR EM R$ LIBERACAO EM"
           c-literal[15] = "------------------------------------------------".

    IF   de-dinheiro > 0   THEN
         ASSIGN c-literal[16] = "   EM DINHEIRO.....: " +  
                                STRING(de-dinheiro,"ZZZ,ZZZ,ZZ9.99") + "   ".

    IF   de-cooperativa > 0   THEN
         ASSIGN c-literal[17] = "CHEQ.COOPERATIVA...: " +  
                                STRING(de-cooperativa,"ZZZ,ZZZ,ZZ9.99") + " ".
    
    ASSIGN c-literal[22] = " "
           c-literal[23] = "TOTAL DEPOSITADO...: " +   
                           STRING(de-valor,"ZZZ,ZZZ,ZZ9.99")
           c-literal[24] = " "
           c-literal[25] = p-literal
           c-literal[26] = " "
           c-literal[27] = " "
           c-literal[28] = " "
           c-literal[29] = " "
           c-literal[30] = " "
           c-literal[31] = " "
           c-literal[32] = " "
           c-literal[33] = " "
           c-literal[34] = " "
           c-literal[35] = " ".

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
         ASSIGN p-literal-autentica =
                p-literal-autentica + STRING(c-literal[11],"x(48)")
                p-literal-autentica =
                p-literal-autentica + STRING(c-literal[12],"x(48)")
                p-literal-autentica =
                p-literal-autentica + STRING(c-literal[13],"x(48)").

    ASSIGN p-literal-autentica =
           p-literal-autentica + STRING(c-literal[14],"x(48)")
           p-literal-autentica =
           p-literal-autentica + STRING(c-literal[15],"x(48)").

    IF   c-literal[16] <> " "   THEN
         ASSIGN p-literal-autentica = p-literal-autentica + 
                                      STRING(c-literal[16],"x(48)").

    IF   c-literal[17] <> " "   THEN
         ASSIGN p-literal-autentica = p-literal-autentica + 
                                      STRING(c-literal[17],"x(48)").
    
    FOR EACH tt-cheques NO-LOCK:
        IF  tt-cheques.nrdocmto = 6 THEN
            ASSIGN p-literal-autentica = 
                                p-literal-autentica + 
                     STRING("CHEQ. OUTROS BANCOS: " +
                                STRING(tt-cheques.vlcompel,"ZZZ,ZZZ,ZZ9.99") +
                            " " +
                                STRING(tt-cheques.dtlibera,"99/99/9999"),
                                "x(48)").
        END.


    ASSIGN c-literal[30] = centraliza("SAC - " + STRING(crapcop.nrtelsac),48)
           c-literal[31] = centraliza("Atendimento todos os dias das " + REPLACE(REPLACE(STRING(crapcop.hrinisac,"HH:MM"),':','h'),'h00','h') + " as " + REPLACE(REPLACE(STRING(crapcop.hrfimsac,"HH:MM"),':','h'),'h00','h'),48)
           c-literal[32] = centraliza("OUVIDORIA - " + STRING(crapcop.nrtelouv),48)
           c-literal[33] = centraliza("Atendimento nos dias uteis das " + REPLACE(REPLACE(STRING(crapcop.hriniouv,"HH:MM"),':','h'),'h00','h') + " as " + REPLACE(REPLACE(STRING(crapcop.hrfimouv,"HH:MM"),':','h'),'h00','h'),48).    

    ASSIGN p-literal-autentica = p-literal-autentica         +
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
                                 STRING(c-literal[32],"x(48)")   +
                                 STRING(c-literal[33],"x(48)")   +
                                 STRING(c-literal[34],"x(48)")   +
                                 STRING(c-literal[35],"x(48)")   +
								 FILL(' ',384).

    ASSIGN p-ult-sequencia-autentica = p-ult-sequencia.

    ASSIGN in99 = 0.
    DO   WHILE TRUE:
         ASSIGN in99 = in99 + 1.
         FIND FIRST crapaut WHERE RECID(crapaut) = p-registro 
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAIL crapaut   THEN 
              DO:
                  IF   LOCKED crapaut   THEN 
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
                  ASSIGN  crapaut.dslitera = p-literal-autentica.
                  RELEASE crapaut.
                  LEAVE.
              END.
    END. /* DO WHILE */

    RELEASE craplot.

    RETURN "OK".

    /*Bloco para tratamento de erro do create da lcm try catch*/
    CATCH eSysError AS Progress.Lang.SysError:
      /*eSysError:GetMessage(1) Pegar a mensagem de erro do sistema*/
      /*Definindo minha propria critica*/
      ASSIGN i-cod-erro  = 0
             c-desc-erro = "Problemas na efetivacao do deposito. Repita a operação. " + eSysError:GetMessage(1).

      run cria-erro (INPUT p-cooper,
                     INPUT p-cod-agencia,
                     INPUT p-nro-caixa,
                     INPUT i-cod-erro,
                     INPUT c-desc-erro,
                     INPUT YES).

      RETURN "NOK".
    END CATCH.

END PROCEDURE.

PROCEDURE atualiza-deposito-com-captura-migrado-host:

    DEF INPUT  PARAM  p-cooper              AS CHAR NO-UNDO.
    DEF INPUT  PARAM  p-nmcooper            AS CHAR NO-UNDO.
    DEF INPUT  PARAM  p-cod-agencia         AS INT  NO-UNDO. /* Cod.Agencia  */
    DEF INPUT  PARAM  p-nro-caixa           AS INT  NO-UNDO. /* Numero Caixa */
    DEF INPUT  PARAM  p-cod-operador        AS CHAR NO-UNDO.
    DEF INPUT  PARAM  p-nro-conta           AS INT  NO-UNDO.
/*
    DEF INPUT  PARAM pCodAprovador              AS CHAR NO-UNDO.
*/    
    DEF INPUT  PARAM  p-nome-titular            AS CHAR NO-UNDO.
    DEF INPUT  PARAM  p-identifica              AS CHAR NO-UNDO.
    DEF INPUT  PARAM  p-nro-conta-nova          AS INTE NO-UNDO.
    DEF INPUT  PARAM  p-nro-conta-anti          AS INTE NO-UNDO.
    DEF INPUT  PARAM  p-vestorno                AS LOG  NO-UNDO.

    DEF OUTPUT PARAM  p-literal-autentica       AS CHAR NO-UNDO.
    DEF OUTPUT PARAM  p-ult-sequencia-autentica AS INT  NO-UNDO.
    DEF OUTPUT PARAM  p-nro-docto               AS INT  NO-UNDO.
    
    DEF BUFFER crabcop FOR crapcop.
    DEF BUFFER cra2fdc FOR crapfdc.
    DEF BUFFER cra2lot FOR craplot.
    DEF BUFFER cra2lcm FOR craplcm.

    DEF VAR aux_contalot AS INTE NO-UNDO.

    /* Variaveis para rotina de lancamento craplcm */
    DEF VAR h-b1wgen0200 AS HANDLE  NO-UNDO.
    DEF VAR aux_incrineg AS INT     NO-UNDO.
    DEF VAR aux_cdcritic AS INT     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR    NO-UNDO.
    DEF VAR aux_contlock AS INTE NO-UNDO.
    DEF VAR aux_temlock  AS LOG INIT FALSE NO-UNDO.

    /* cooperativa antiga */
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    /* cooperativa nova */
    FIND crabcop WHERE crabcop.nmrescop = p-nmcooper NO-LOCK NO-ERROR.
    
    DO   WHILE TRUE:
        
         FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper   AND
                            crapass.nrdconta = INT(p-nro-conta) 
                            NO-LOCK NO-ERROR.
                                  
         IF   NOT AVAIL crapass   THEN 
              LEAVE.

         IF   AVAIL crapass   THEN 
              DO:
                  IF  CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN 
                      DO:
                          FIND FIRST craptrf WHERE 
                                     craptrf.cdcooper = crapcop.cdcooper    AND
                                     craptrf.nrdconta = crapass.nrdconta    AND
                                     craptrf.tptransa = 1                   AND
                                     craptrf.insittrs = 2   
                                     USE-INDEX craptrf1 NO-LOCK NO-ERROR.
    
                          IF   AVAIL craptrf   THEN  
                               ASSIGN aux_nrtrfcta = craptrf.nrsconta
                                      aux_nrdconta = craptrf.nrsconta
                                      p-nro-conta  = craptrf.nrsconta.
                          ELSE 
                              LEAVE.
                      END.
                  ELSE
                      LEAVE.
              END.
    END. /* DO WHILE */
    
    ASSIGN p-nro-conta = DEC(REPLACE(STRING(p-nro-conta),".","")).

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    ASSIGN i-nro-lote = 11000 + p-nro-caixa.

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.

    FIND FIRST crapmrw WHERE crapmrw.cdcooper = crapcop.cdcooper    AND 
                             crapmrw.cdagenci = p-cod-agencia       AND
                             crapmrw.nrdcaixa = p-nro-caixa   
                             NO-LOCK NO-ERROR.
                             
    IF   NOT AVAIL crapmrw   THEN 
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Nao existem valores a serem Depositados ".
                    run cria-erro (INPUT p-cooper,
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
                        c-desc-erro = "Erro de captura. Tente novamente. INF(ENTRY) = " + 
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

    ASSIGN dt-menor-praca  = ?
           dt-maior-praca  = ?
           dt-menor-fpraca = ?
           dt-maior-fpraca = ?
           dt-menor-fpraca = crapdat.dtmvtocd.
           
    ASSIGN aux_nrdconta = p-nro-conta.
    /*--- Verifica se Houve Transferencia de Conta --*/
    ASSIGN aux_nrtrfcta = 0.
    DO   WHILE TRUE:
         FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper   AND
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
                             
                  IF  AVAIL craptrf  THEN
                  ASSIGN aux_nrtrfcta = craptrf.nrsconta
                         aux_nrdconta = craptrf.nrsconta.
                  NEXT.
              END.
         LEAVE.
    END. /* do while */
    IF   aux_nrtrfcta > 0  THEN    /* Transferencia de Conta */
         ASSIGN aux_nrdconta = aux_nrtrfcta.

    ASSIGN p-nro-conta = aux_nrdconta.
    
    ASSIGN l-achou-horario-corte  = no.
    FOR EACH crapmrw WHERE crapmrw.cdcooper = crapcop.cdcooper  AND
                           crapmrw.cdagenci = p-cod-agencia     AND
                           crapmrw.nrdcaixa = p-nro-caixa       NO-LOCK:
                           
        IF  crapmrw.vlchqipr <> 0   OR
            crapmrw.vlchqspr <> 0   OR
            crapmrw.vlchqifp <> 0   OR
            crapmrw.vlchqsfp <> 0   THEN
            ASSIGN l-achou-horario-corte  = yes.
    END.

    IF  l-achou-horario-corte   THEN  
        DO:
            /* Verifica horario de Corte */
            FIND FIRST craptab WHERE craptab.cdcooper = crapcop.cdcooper    AND 
                                     craptab.nmsistem = "CRED"              AND
                                     craptab.tptabela = "GENERI"            AND
                                     craptab.cdempres = 0                   AND
                                     craptab.cdacesso = "HRTRCOMPEL"        AND
                                     craptab.tpregist = p-cod-agencia  
                                     NO-LOCK NO-ERROR.
                                     
            IF  NOT AVAIL craptab   THEN  
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

            IF  INT(SUBSTR(craptab.dstextab,1,1)) <> 0   THEN 
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

            IF  INT(SUBSTR(craptab.dstextab,3,5)) <= TIME   THEN 
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
         END.    /* Verifica Horario de Corte */

    ASSIGN c-docto-salvo = STRING(time).

    /* 5 tentativas para pegar lock no craplot */
    DO aux_contalot = 1 TO 5:
    
        FIND FIRST craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                                 craplot.dtmvtolt = crapdat.dtmvtocd  AND
                                 craplot.cdagenci = p-cod-agencia     AND
                                 craplot.cdbccxlt = 11                AND /* Fixo */
                                 craplot.nrdolote = i-nro-lote 
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
             
        IF  NOT AVAIL craplot  THEN 
        DO: 
            IF  LOCKED(craplot) THEN
            DO:
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Registro de lote esta em uso no momento.".
                PAUSE 1 NO-MESSAGE.
                NEXT.
            END.
            ELSE
            DO:
                CREATE craplot.
                ASSIGN craplot.cdcooper = crapcop.cdcooper
                       craplot.dtmvtolt = crapdat.dtmvtocd
                       craplot.cdagenci = p-cod-agencia
                       craplot.cdbccxlt = 11
                       craplot.nrdolote = i-nro-lote
                       craplot.tplotmov = 1
                       craplot.cdoperad = p-cod-operador
                       craplot.cdhistor = 0 /* 700 */
                       craplot.nrdcaixa = p-nro-caixa
                       craplot.cdopecxa = p-cod-operador.
            END.
        END.
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "".
        LEAVE.
    END.

    IF  i-cod-erro > 0 OR
        c-desc-erro <> "" THEN
    DO:
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        RETURN "NOK".
    END.
         
    ASSIGN de-valor        = 0
           de-dinheiro     = 0
           de-cooperativa  = 0
           de-maior-praca  = 0
           de-menor-praca  = 0
           de-maior-fpraca = 0
           de-menor-fpraca = 0.
    
    /* Montar o Resumo */
    /* Buscar os totais de dinheiro e Cheque Cooperativa */
    FIND FIRST crapmrw WHERE crapmrw.cdcooper = crapcop.cdcooper    AND
                             crapmrw.cdagenci = p-cod-agencia       AND
                             crapmrw.nrdcaixa = p-nro-caixa
                             NO-LOCK NO-ERROR.
                             
    IF   AVAIL crapmrw   THEN 
         DO:
             ASSIGN de-dinheiro     = crapmrw.vldepdin
                    de-cooperativa  = crapmrw.vlchqcop
                    de-valor = de-dinheiro + de-cooperativa.
         END.

    FIND FIRST craptab WHERE craptab.cdcooper = crapcop.cdcooper    AND
                             craptab.nmsistem = "CRED"              AND
                             craptab.tptabela = "USUARI"            AND
                             craptab.cdempres = 11                  AND
                             craptab.cdacesso = "MAIORESCHQ"        AND
                             craptab.tpregist = 1 
                             NO-LOCK NO-ERROR.
    
    /* Buscar os totais de cheque maior e menor da Praca ou fora Praca */
    FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper AND
                           crapmdw.cdagenci = p-cod-agencia    AND
                           crapmdw.nrdcaixa = p-nro-caixa NO-LOCK:
        
        FIND tt-cheques WHERE tt-cheques.dtlibera = crapmdw.dtlibcom AND
                              tt-cheques.nrdocmto = crapmdw.nrdocmto
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL tt-cheques  THEN
            CREATE tt-cheques.

        IF  crapmdw.vlcompel < DEC(SUBSTR(craptab.dstextab,1,15))  THEN
            ASSIGN  aux_tpdmovto = 2.
        ELSE
            ASSIGN  aux_tpdmovto = 1.                
        
        IF crapmdw.cdhistor = 2433 THEN
            ASSIGN tt-cheques.nrdocmto = 6
                   tt-cheques.dtlibera = crapmdw.dtlibcom
                   tt-cheques.vlcompel = tt-cheques.vlcompel + crapmdw.vlcompel
                   de-valor = de-valor + crapmdw.vlcompel.
        
        FIND CURRENT tt-cheques NO-LOCK.
        
    END.    
    /* Fim da montagem do Resumo */     
         
    ASSIGN i-nro-docto = INT(c-docto-salvo)
           p-nro-docto = INT(c-docto-salvo).
    
    /*--- Grava Autenticacao Arquivo/Spool --*/
    RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
    RUN grava-autenticacao  IN h_b1crap00 (INPUT p-cooper,
                                           INPUT p-cod-agencia,
                                           INPUT p-nro-caixa,
                                           INPUT p-cod-operador,
                                           INPUT de-valor,
                                           INPUT dec(i-nro-docto),
                                           INPUT NO, /* YES (PG), NO (REC) */
                                           INPUT "1",  /* On-line  */     
                                           INPUT NO,   /* Nao estorno */     
                                           INPUT 700,
                                           INPUT ?, /* Data off-line */
                                           INPUT 0, /* Sequencia off-line */
                                           INPUT 0, /* Hora off-line */
                                           INPUT 0, /* Seq.orig.Off-line */
                                           OUTPUT p-literal,
                                           OUTPUT p-ult-sequencia,
                                           OUTPUT p-registro).
    DELETE PROCEDURE h_b1crap00.

    IF   RETURN-VALUE = "NOK"  THEN
         RETURN "NOK".
         
    IF   AVAIL crapmrw   THEN  
         DO:
         
             /* Formata conta integracao */
             RUN fontes/digbbx.p (INPUT  p-nro-conta,
                                  OUTPUT glb_dsdctitg,
                                  OUTPUT glb_stsnrcal).
         
             /* Dinheiro */
             IF   crapmrw.vldepdin <> 0   THEN 
                  DO:
                      ASSIGN c-docto = c-docto-salvo + 
                                       /* 'Sequencial' fixo 01 */
                                       "01" + 
                                       "1".

                      /*--- Verifica se Lancamento ja Existe ---*/
                      FIND FIRST craplcm WHERE
                                 craplcm.cdcooper = crapcop.cdcooper    AND
                                 craplcm.dtmvtolt = crapdat.dtmvtocd    AND
                                 craplcm.cdagenci = p-cod-agencia       AND
                                 craplcm.cdbccxlt = 11                  AND
                                 craplcm.nrdolote = i-nro-lote          AND
                                 craplcm.nrseqdig = craplot.nrseqdig + 1 
                                 USE-INDEX craplcm3 NO-LOCK NO-ERROR.

                      IF   AVAIL craplcm THEN   
                           DO:
                               ASSIGN i-cod-erro  = 0
                                      c-desc-erro = "Lancamento ja existente".
                               RUN cria-erro (INPUT p-cooper,
                                              INPUT p-cod-agencia,
                                              INPUT p-nro-caixa,
                                              INPUT i-cod-erro,
                                              INPUT c-desc-erro,
                                              INPUT YES).
                               RETURN "NOK".
                           END.

                      FIND FIRST craplcm WHERE 
                                 craplcm.cdcooper = crapcop.cdcooper    AND
                                 craplcm.dtmvtolt = crapdat.dtmvtocd    AND
                                 craplcm.cdagenci = p-cod-agencia       AND
                                 craplcm.cdbccxlt = 11                  AND
                                 craplcm.nrdolote = i-nro-lote          AND
                                 craplcm.nrdctabb = p-nro-conta         AND
                                 craplcm.nrdocmto = INT(c-docto) 
                                 USE-INDEX craplcm1 NO-LOCK NO-ERROR.

                      IF   AVAIL craplcm   THEN 
                           DO:
                               ASSIGN i-cod-erro  = 0
                                      c-desc-erro = 
                                          "Lancamento(Primario) ja existente".
                               RUN cria-erro (INPUT p-cooper,
                                              INPUT p-cod-agencia,
                                              INPUT p-nro-caixa,
                                              INPUT i-cod-erro,
                                              INPUT c-desc-erro,
                                              INPUT YES).
                               RETURN "NOK".
                           END.
                      
                      /* BLOCO DA INSERÇAO DA CRAPLCM */
                      IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
                        RUN sistema/generico/procedures/b1wgen0200.p 
                          PERSISTENT SET h-b1wgen0200.
                          
                      RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
                        (INPUT crapdat.dtmvtolt               /* par_dtmvtolt */
                        ,INPUT p-cod-agencia                  /* par_cdagenci */
                        ,INPUT 11                             /* par_cdbccxlt */
                        ,INPUT i-nro-lote                     /* par_nrdolote */
                        ,INPUT aux_nrdconta                   /* par_nrdconta */
                        ,INPUT INTE(c-docto)                  /* par_nrdocmto */
                        ,INPUT 1                              /* par_cdhistor */
                        ,INPUT craplot.nrseqdig + 1           /* par_nrseqdig */
                        ,INPUT crapmrw.vldepdin               /* par_vllanmto */
                        ,INPUT p-nro-conta                    /* par_nrdctabb */
                        ,INPUT "CRAP51"                       /* par_cdpesqbb */
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
                        ,INPUT ""                             /* par_cdoperad */
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
                        /* CAMPOS DE SAIDA                                                                     */                                            
                        ,OUTPUT TABLE tt-ret-lancto           /* Collection que contem o retorno do lancamento */
                        ,OUTPUT aux_incrineg                  /* Indicador de critica de negocio               */
                        ,OUTPUT aux_cdcritic                  /* Codigo da critica                             */
                        ,OUTPUT aux_dscritic).                /* Descricao da critica                          */
                        
                      IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                         DO: 
                             /* Tratamento de erros conforme anteriores */
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
                      ELSE 
                         DO:
                           /* Posicionando no registro da craplcm criado acima */
                           FIND FIRST tt-ret-lancto.
                           FIND FIRST craplcm WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm NO-ERROR.
                         END.                
                      
                      IF  VALID-HANDLE(h-b1wgen0200) THEN
                        DELETE PROCEDURE h-b1wgen0200.
                               

                      ASSIGN craplot.nrseqdig  = craplot.nrseqdig + 1
                             craplot.qtcompln  = craplot.qtcompln + 1
                             craplot.qtinfoln  = craplot.qtinfoln + 1
                             craplot.vlcompcr  = craplot.vlcompcr + 
                                                 crapmrw.vldepdin              
                             craplot.vlinfocr  = craplot.vlinfocr +  
                                                 crapmrw.vldepdin.
                  END.
             
             /* Cheque Cooperativa */
             IF   crapmrw.vlchqcop <> 0   THEN 
                  DO:
                      ASSIGN c-docto = c-docto-salvo + 
                                      /* 'Sequencial' fixo 01 */
                                      "01" + 
                                      "2".

                      /*--- Verifica se Lancamento ja Existe ---*/
                      FIND FIRST craplcm WHERE
                                 craplcm.cdcooper = crapcop.cdcooper    AND
                                 craplcm.dtmvtolt = crapdat.dtmvtocd    AND
                                 craplcm.cdagenci = p-cod-agencia       AND
                                 craplcm.cdbccxlt = 11                  AND
                                 craplcm.nrdolote = i-nro-lote          AND
                                 craplcm.nrseqdig = craplot.nrseqdig + 1 
                                 USE-INDEX craplcm3 NO-LOCK NO-ERROR.

                      IF   AVAIL craplcm   THEN 
                           DO:
                               ASSIGN i-cod-erro  = 0
                                      c-desc-erro = "Lancamento  ja existente".
                               RUN cria-erro (INPUT p-cooper,
                                              INPUT p-cod-agencia,
                                              INPUT p-nro-caixa,
                                              INPUT i-cod-erro,
                                              INPUT c-desc-erro,
                                              INPUT YES).
                               RETURN "NOK".
                           END.

                      FIND FIRST craplcm WHERE
                                 craplcm.cdcooper = crapcop.cdcooper    AND
                                 craplcm.dtmvtolt = crapdat.dtmvtocd    AND
                                 craplcm.cdagenci = p-cod-agencia       AND
                                 craplcm.cdbccxlt = 11                  AND
                                 craplcm.nrdolote = i-nro-lote          AND
                                 craplcm.nrdctabb = p-nro-conta         AND
                                 craplcm.nrdocmto = inte(c-docto) 
                                 USE-INDEX craplcm1 NO-LOCK NO-ERROR.
                                 
                      IF   AVAIL craplcm   THEN 
                           DO:
                               ASSIGN i-cod-erro  = 0
                                      c-desc-erro = "Lancamento(Primario) ja " +
                                                    "existente".
                               RUN cria-erro (INPUT p-cooper,
                                              INPUT p-cod-agencia,
                                              INPUT p-nro-caixa,
                                              INPUT i-cod-erro,
                                              INPUT c-desc-erro,
                                              INPUT YES).
                               RETURN "NOK".
                           END.
                      
                      /* BLOCO DA INSERÇAO DA CRAPLCM */
                      IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
                        RUN sistema/generico/procedures/b1wgen0200.p 
                          PERSISTENT SET h-b1wgen0200.
                          
                      RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
                        (INPUT crapdat.dtmvtolt               /* par_dtmvtolt */
                        ,INPUT p-cod-agencia                  /* par_cdagenci */
                        ,INPUT 11                             /* par_cdbccxlt */
                        ,INPUT i-nro-lote                     /* par_nrdolote */
                        ,INPUT aux_nrdconta                   /* par_nrdconta */
                        ,INPUT INT(c-docto)                   /* par_nrdocmto */
                        ,INPUT 386                            /* par_cdhistor */
                        ,INPUT craplot.nrseqdig + 1           /* par_nrseqdig */
                        ,INPUT crapmrw.vlchqcop               /* par_vllanmto */
                        ,INPUT p-nro-conta                    /* par_nrdctabb */
                        ,INPUT "CRAP51"                       /* par_cdpesqbb */
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
                        ,INPUT ""                             /* par_cdoperad */
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
                        /* CAMPOS DE SAIDA                                                                     */                                            
                        ,OUTPUT TABLE tt-ret-lancto           /* Collection que contem o retorno do lancamento */
                        ,OUTPUT aux_incrineg                  /* Indicador de critica de negocio               */
                        ,OUTPUT aux_cdcritic                  /* Codigo da critica                             */
                        ,OUTPUT aux_dscritic).                /* Descricao da critica                          */
                        
                      IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                         DO: 
                             /* Tratamento de erros conforme anteriores */
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
                      ELSE 
                         DO:
                           /* Posicionando no registro da craplcm criado acima */
                           FIND FIRST tt-ret-lancto.
                           FIND FIRST craplcm WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm NO-ERROR.
                         END.                
                      
                      IF  VALID-HANDLE(h-b1wgen0200) THEN
                        DELETE PROCEDURE h-b1wgen0200.


                      ASSIGN i-seq-386 =  craplot.nrseqdig + 1.

                      ASSIGN craplot.nrseqdig  = craplot.nrseqdig + 1
                             craplot.qtcompln  = craplot.qtcompln + 1
                             craplot.qtinfoln  = craplot.qtinfoln + 1
                             craplot.vlcompcr  = craplot.vlcompcr +  
                                                 crapmrw.vlchqcop
                             craplot.vlinfocr  = craplot.vlinfocr +  
                                                 crapmrw.vlchqcop.
                  END.
             
         END. /* if  avail crapmrw */

    /* Cheques praça e fora praça serao dinamicos 
       pela influencia do CAF */
    ASSIGN aux_nrsequen = 0.
    
    FOR EACH tt-cheques WHERE tt-cheques.nrdocmto = 6 EXCLUSIVE-LOCK:
        /* Sequencial utilizado para separar um lançamento em conta para cada
           data nao ocorrendo duplicidade de chave */
        ASSIGN aux_nrsequen = aux_nrsequen + 1
               c-docto = c-docto-salvo + /* TIME atribuído anteriormente */
                         STRING(aux_nrsequen,"99") + /* sequenciaL para cada data de liberaçao */
                         STRING(tt-cheques.nrdocmto) /* será sempre 6 */
               /* numero de sequencia sera utilizado para identificar cada
                  cheque(crapchd) do lancamento total da data */
               tt-cheques.nrsequen = aux_nrsequen.

        /*--- Verifica se Lancamento ja Existe ---*/
        FIND FIRST craplcm WHERE
                   craplcm.cdcooper = crapcop.cdcooper    AND
                   craplcm.dtmvtolt = crapdat.dtmvtocd    AND
                   craplcm.cdagenci = p-cod-agencia       AND
                   craplcm.cdbccxlt = 11                  AND
                   craplcm.nrdolote = i-nro-lote          AND
                   craplcm.nrseqdig = craplot.nrseqdig + 1 
                   USE-INDEX craplcm3 NO-LOCK NO-ERROR.

        IF   AVAIL craplcm   THEN 
             DO:
                 ASSIGN i-cod-erro  = 0
                        c-desc-erro = "Lancamento  ja existente".
                 RUN cria-erro (INPUT p-cooper,
                                INPUT p-cod-agencia,
                                INPUT p-nro-caixa,
                                INPUT i-cod-erro,
                                INPUT c-desc-erro,
                                INPUT YES).
                 RETURN "NOK".
             END.

        FIND FIRST craplcm WHERE
                   craplcm.cdcooper = crapcop.cdcooper    AND
                   craplcm.dtmvtolt = crapdat.dtmvtocd    AND
                   craplcm.cdagenci = p-cod-agencia       AND
                   craplcm.cdbccxlt = 11                  AND
                   craplcm.nrdolote = i-nro-lote          AND
                   craplcm.nrdctabb = p-nro-conta         AND
                   craplcm.nrdocmto = inte(c-docto) 
                   USE-INDEX craplcm1 NO-LOCK NO-ERROR.

        IF   AVAIL craplcm   THEN 
             DO:
                 ASSIGN i-cod-erro  = 0
                        c-desc-erro = 
                            "Lancamento(Primario) ja existente".
                 RUN cria-erro (INPUT p-cooper,
                                INPUT p-cod-agencia,
                                INPUT p-nro-caixa,
                                INPUT i-cod-erro,
                                INPUT c-desc-erro,
                                INPUT YES).
                 RETURN "NOK".
             END.
        /*----------------------------------------------------*/        

        /* BLOCO DA INSERÇAO DA CRAPLCM */
        IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
          RUN sistema/generico/procedures/b1wgen0200.p 
            PERSISTENT SET h-b1wgen0200.
            
        RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
          (INPUT crapdat.dtmvtolt               /* par_dtmvtolt */
          ,INPUT p-cod-agencia                  /* par_cdagenci */
          ,INPUT 11                             /* par_cdbccxlt */
          ,INPUT i-nro-lote                     /* par_nrdolote */
          ,INPUT aux_nrdconta                   /* par_nrdconta */
          ,INPUT INT(c-docto)                   /* par_nrdocmto */
          ,INPUT 2433                           /* par_cdhistor */
          ,INPUT craplot.nrseqdig + 1           /* par_nrseqdig */
          ,INPUT tt-cheques.vlcompel            /* par_vllanmto */
          ,INPUT p-nro-conta                    /* par_nrdctabb */
          ,INPUT "CRAP51"                       /* par_cdpesqbb */
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
          ,INPUT ""                             /* par_cdoperad */
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
          /* CAMPOS DE SAIDA                                                                     */                                            
          ,OUTPUT TABLE tt-ret-lancto           /* Collection que contem o retorno do lancamento */
          ,OUTPUT aux_incrineg                  /* Indicador de critica de negocio               */
          ,OUTPUT aux_cdcritic                  /* Codigo da critica                             */
          ,OUTPUT aux_dscritic).                /* Descricao da critica                          */
          
        IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
           DO: 
               /* Tratamento de erros conforme anteriores */
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
        ELSE 
           DO:
             /* Posicionando no registro da craplcm criado acima */
             FIND FIRST tt-ret-lancto.
             FIND FIRST craplcm WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm NO-ERROR.
           END.                
        
        IF  VALID-HANDLE(h-b1wgen0200) THEN
          DELETE PROCEDURE h-b1wgen0200.

               
               /* Guarda o sequencial usado no lancamento */
               tt-cheques.nrseqlcm = craplot.nrseqdig + 1.

        ASSIGN craplot.nrseqdig  = craplot.nrseqdig + 1
               craplot.qtcompln  = craplot.qtcompln + 1
               craplot.qtinfoln  = craplot.qtinfoln + 1
               craplot.vlcompcr  = craplot.vlcompcr +  
                                   tt-cheques.vlcompel
               craplot.vlinfocr  = craplot.vlinfocr +  
                                   tt-cheques.vlcompel.
        CREATE crapdpb.
        ASSIGN crapdpb.cdcooper = crapcop.cdcooper
               crapdpb.nrdconta = aux_nrdconta
               crapdpb.dtliblan = tt-cheques.dtlibera
              crapdpb.cdhistor = 2433
               crapdpb.nrdocmto = INT(c-docto)
               crapdpb.dtmvtolt = crapdat.dtmvtocd
               crapdpb.cdagenci = p-cod-agencia
               crapdpb.cdbccxlt = 11
               crapdpb.nrdolote = i-nro-lote
               crapdpb.vllanmto = tt-cheques.vlcompel
               crapdpb.inlibera = 1.
        VALIDATE crapdpb.
             END.
       

    FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper  AND
                           crapmdw.cdagenci = p-cod-agencia     AND
                           crapmdw.nrdcaixa = p-nro-caixa       NO-LOCK:
        
        /* Formata conta integracao */
        RUN fontes/digbbx.p (INPUT  crapmdw.nrctabdb,
                             OUTPUT glb_dsdctitg,
                             OUTPUT glb_stsnrcal).

        FIND FIRST crapchd WHERE crapchd.cdcooper = crapcop.cdcooper    AND
                                 crapchd.dtmvtolt = crapdat.dtmvtocd    AND
                                 crapchd.cdcmpchq = crapmdw.cdcmpchq    AND
                                 crapchd.cdbanchq = crapmdw.cdbanchq    AND
                                 crapchd.cdagechq = crapmdw.cdagechq    AND
                                 crapchd.nrctachq = crapmdw.nrctachq    AND
                                 crapchd.nrcheque = crapmdw.nrcheque  
                                 USE-INDEX crapchd1 NO-LOCK NO-ERROR.

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

        IF   crapmdw.cdhistor = 386   THEN
               ASSIGN i-nrdocmto = INTEGER(c-docto-salvo + "02" + "2").

        /* Buscar de qual sequencia eh o cheque */
        FIND tt-cheques WHERE tt-cheques.dtlibera = crapmdw.dtlibcom AND
                              tt-cheques.nrdocmto = crapmdw.nrdocmto
                              NO-LOCK NO-ERROR.

        IF crapmdw.cdhistor = 2433 THEN
           ASSIGN i-nrdocmto = INTEGER(c-docto-salvo + STRING(tt-cheques.nrsequen,"99") + "6").

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
                                      WHEN NUM-ENTRIES(crapmdw.lsdigctr) = 3
               crapchd.nrddigv2 = INT(ENTRY(2,crapmdw.lsdigctr)) 
                                      WHEN NUM-ENTRIES(crapmdw.lsdigctr) = 3
               crapchd.nrddigv3 = INT(ENTRY(3,crapmdw.lsdigctr)) 
                                      WHEN NUM-ENTRIES(crapmdw.lsdigctr) = 3
               crapchd.nrdolote = i-nro-lote
               crapchd.tpdmovto = crapmdw.tpdmovto
               crapchd.nrterfin = 0
               crapchd.vlcheque = crapmdw.vlcompel.

        IF   crapmdw.cdhistor = 386   THEN
             ASSIGN crapchd.nrseqdig = i-seq-386.
        ELSE
            DO:                                             
                 /* Sequencia dos lancamentos */
                 ASSIGN crapchd.nrseqdig = tt-cheques.nrseqlcm.
                 
                 /** Incrementa contagem de cheques para a previa **/
                 RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
                 RUN atualiza-previa-caixa  IN h_b1crap00  (INPUT p-cooper,
                                                            INPUT p-cod-agencia,
                                                            INPUT p-nro-caixa,
                                                            INPUT p-cod-operador,
                                                            INPUT crapdat.dtmvtocd,
                                                            INPUT 1). /*Inclusao*/ 
                 DELETE PROCEDURE h_b1crap00.
            END.
            
        VALIDATE crapchd.
            
        IF   crapmdw.cdhistor <> 386   THEN NEXT.

        /* guarda infos da ultima autenticacao 700 */
        ASSIGN aux-p-literal = p-literal
               aux-p-ult-sequencia = p-ult-sequencia
               aux-p-registro = p-registro.

        RUN autentica_cheques (INPUT p-cooper,                
                               INPUT p-cod-agencia,           
                               INPUT p-nro-conta,             
                               INPUT p-vestorno,             
                               INPUT p-nro-caixa,             
                               INPUT p-cod-operador,
                               INPUT ROWID(crapmdw),
                               INPUT crapdat.dtmvtocd,
                               INPUT 0).             

        /* volta infos da ultima autenticacao 700 */
        ASSIGN p-literal = aux-p-literal
               p-ult-sequencia = aux-p-ult-sequencia
               p-registro = aux-p-registro.
        
        IF RETURN-VALUE = "NOK" THEN
           RETURN "NOK".


        /* Formata conta integracao */
        RUN fontes/digbbx.p (INPUT  crapmdw.nrctabdb,
                             OUTPUT glb_dsdctitg,
                             OUTPUT glb_stsnrcal).

        /* Tentar 10x */
        DO aux_contlock = 1 TO 10:
        FIND cra2fdc WHERE cra2fdc.cdcooper = crapcop.cdcooper   AND
                           cra2fdc.cdbanchq = crapchd.cdbanchq   AND
                           cra2fdc.cdagechq = crapchd.cdagechq   AND
                           cra2fdc.nrctachq = crapchd.nrctachq   AND
                           cra2fdc.nrcheque = crapmdw.nrcheque
                             USE-INDEX crapfdc1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
          IF NOT AVAILABLE cra2fdc THEN
          DO:
            IF LOCKED(cra2fdc) THEN
        DO: 
              ASSIGN i-cod-erro  = 0
                     c-desc-erro = "Registro cheque esta em uso no momento. Migrado host.".
              IF aux_temlock = FALSE THEN
              DO: /* Criar o erro apenas uma vez */
                ASSIGN aux_temlock = TRUE.
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
              END.
              PAUSE 1 NO-MESSAGE.
              NEXT.              
            END.
          END.
          ELSE 
          DO: /* cra2fdc avail */
            ASSIGN aux_temlock = FALSE.
            
            /**verificar se o cheque eh de uma conta que foi migrada**/
            FIND FIRST craptco WHERE craptco.cdcopant = cra2fdc.cdcooper AND
                                     craptco.nrctaant = cra2fdc.nrdconta AND
                                     craptco.tpctatrf = 1                AND
                                     craptco.flgativo = TRUE
                                     NO-LOCK NO-ERROR.
            IF  AVAIL craptco  THEN
            DO:
                FIND FIRST cra2lot WHERE cra2lot.cdcooper = crabcop.cdcooper AND
                                         cra2lot.dtmvtolt = crapdat.dtmvtocd AND
                                         cra2lot.cdagenci = craptco.cdagenci AND
                                         cra2lot.cdbccxlt = 100              AND
                                         cra2lot.nrdolote = 205000 + craptco.cdagenci
                                         EXCLUSIVE-LOCK NO-ERROR.
    
                IF   NOT AVAIL cra2lot   THEN 
                     DO: 
                         CREATE cra2lot.
                         ASSIGN cra2lot.cdcooper = crabcop.cdcooper
                                cra2lot.dtmvtolt = crapdat.dtmvtocd
                                cra2lot.cdagenci = craptco.cdagenci
                                cra2lot.cdbccxlt = 100
                                cra2lot.nrdolote = 205000 + craptco.cdagenci
                                cra2lot.tplotmov = 1
                                cra2lot.cdoperad = "1" /* SUPER-USUARIO para migracao */
                                cra2lot.cdhistor = 0. /* 700 */

                         VALIDATE cra2lot.
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

                         RUN cria-erro (INPUT p-cooper,
                                        INPUT p-cod-agencia,
                                        INPUT p-nro-caixa,
                                        INPUT i-cod-erro,
                                        INPUT c-desc-erro,
                                        INPUT YES).
                         RETURN "NOK".
                     END.

                /* Utilizado como base bcaixal.i */
                CREATE craplcx.
                ASSIGN craplcx.dtmvtolt = crapdat.dtmvtocd
                       craplcx.cdagenci = p-cod-agencia
                       craplcx.nrdcaixa = p-nro-caixa
                       craplcx.cdopecxa = p-cod-operador
                       craplcx.nrdocmto = INT(STRING(crapmdw.nrcheque,"999999") +
                                              STRING(crapmdw.nrddigc3,"9"))
                       craplcx.nrseqdig = crapbcx.qtcompln + 1
                       craplcx.nrdmaqui = crapbcx.nrdmaqui
                       craplcx.cdhistor = 704
                       craplcx.dsdcompl = "Saque da conta sobreposta " +
                                          STRING(crapchd.nrctachq,"zzzz,zzz,z")
                       crapbcx.qtcompln = crapbcx.qtcompln + 1
                       craplcx.vldocmto = crapmdw.vlcompel
                       craplcx.cdcooper = crapcop.cdcooper.
                VALIDATE craplcx.
          
                CREATE cra2lcm.
        
                /* Pagamento Cheque */
                
                ASSIGN cra2lcm.cdcooper = cra2lot.cdcooper
                       cra2lcm.dtmvtolt = crapdat.dtmvtocd
                       cra2lcm.cdagenci = cra2lot.cdagenci
                       cra2lcm.cdbccxlt = cra2lot.cdbccxlt
                       cra2lcm.nrdolote = cra2lot.nrdolote
                       cra2lcm.dsidenti = p-identifica
                       cra2lcm.nrdconta = craptco.nrdconta 
                       cra2lcm.nrdocmto = INT(STRING(crapmdw.nrcheque,"999999") +
                                              STRING(crapmdw.nrddigc3,"9"))
                       cra2lcm.vllanmto = crapmdw.vlcompel
                       cra2lcm.nrseqdig = cra2lot.nrseqdig + 1
                       cra2lcm.nrdctabb = crapmdw.nrctabdb
                       /*crablcm.nrautdoc = p-ult-sequencia*/
                       cra2lcm.nrautdoc = crapmdw.nrautdoc
                       cra2lcm.cdpesqbb = "CRAP51," + crapmdw.cdopelib
                       cra2lcm.nrdctitg = glb_dsdctitg
                       
                       cra2lot.nrseqdig = cra2lot.nrseqdig + 1
                       cra2lot.qtcompln = cra2lot.qtcompln + 1
                       cra2lot.qtinfoln = cra2lot.qtinfoln + 1
                       cra2lot.vlcompdb = cra2lot.vlcompdb + crapmdw.vlcompel
                       cra2lot.vlinfodb = cra2lot.vlinfodb + crapmdw.vlcompel.
                
                ASSIGN cra2fdc.incheque = cra2fdc.incheque + 5
                       cra2fdc.dtliqchq = crapdat.dtmvtocd
                       cra2fdc.cdoperad = p-cod-operador
                       cra2fdc.vlcheque = crapmdw.vlcompel
                       
                       /* Associado que recebe o cheque */
                       cra2fdc.nrctadep = crapass.nrdconta
                       cra2lcm.cdbanchq = cra2fdc.cdbanchq
                       cra2lcm.cdagechq = cra2fdc.cdagechq
                       cra2lcm.nrctachq = cra2fdc.nrctachq.
                VALIDATE cra2lcm.
                VALIDATE cra2lot.

                /* Atualiza os campos de acordo com o tipo da conta do associado que
                   recebe o cheque */
                IF  crapass.cdtipcta >= 8    AND
                    crapass.cdtipcta <= 11   THEN
                    DO:
                        /* BANCOOB */
                        IF  crapass.cdbcochq = 756 THEN
                            ASSIGN cra2fdc.cdbandep = 756
                                   cra2fdc.cdagedep = crapcop.cdagebcb.
                        ELSE
                            ASSIGN cra2fdc.cdbandep = crapcop.cdbcoctl
                                   cra2fdc.cdagedep = crapcop.cdagectl.
                    END.
                ELSE
                /* BANCO DO BRASIL - SEM DIGITO */
                     ASSIGN cra2fdc.cdbandep = 1
                            cra2fdc.cdagedep = INT(SUBSTRING(
                                                   STRING(crapcop.cdagedbb),1,
                                                   LENGTH(STRING(crapcop.cdagedbb))
                                                   - 1)).
                
                IF   cra2fdc.tpcheque = 1   THEN /* chq normal */
                     ASSIGN cra2lcm.cdhistor = 521.
                ELSE
                     ASSIGN cra2lcm.cdhistor = 26. /* chq salario */

                VALIDATE cra2fdc.
            END.
            /*********************************************************/
            ELSE
            DO:
            
                CREATE crablcm.
        
                /* Pagamento Cheque */                          
                
                ASSIGN crablcm.cdcooper = crapcop.cdcooper
                       crablcm.dtmvtolt = crapdat.dtmvtocd
                       crablcm.cdagenci = p-cod-agencia
                       crablcm.cdbccxlt = 11 /* Fixo */
                       crablcm.nrdolote = i-nro-lote
                       crablcm.dsidenti = p-identifica
                       crablcm.nrdconta = crapmdw.nrctaaux
                       crablcm.nrdocmto = INT(STRING(crapmdw.nrcheque,"999999") +
                                              STRING(crapmdw.nrddigc3,"9"))
                       crablcm.vllanmto = crapmdw.vlcompel
                       crablcm.nrseqdig = craplot.nrseqdig + 1
                       crablcm.nrdctabb = crapmdw.nrctabdb
                       /*crablcm.nrautdoc = p-ult-sequencia*/
                       crablcm.nrautdoc = crapmdw.nrautdoc
                       crablcm.cdpesqbb = "CRAP51," + crapmdw.cdopelib
                       crablcm.nrdctitg = glb_dsdctitg
                       
                       craplot.nrseqdig = craplot.nrseqdig + 1
                       craplot.qtcompln = craplot.qtcompln + 1
                       craplot.qtinfoln = craplot.qtinfoln + 1
                       craplot.vlcompdb = craplot.vlcompdb + crapmdw.vlcompel
                       craplot.vlinfodb = craplot.vlinfodb + crapmdw.vlcompel.
                
            
                FIND crabfdc WHERE crabfdc.cdcooper = crapchd.cdcooper   AND
                                   crabfdc.cdbanchq = crapchd.cdbanchq   AND
                                   crabfdc.cdagechq = crapchd.cdagechq   AND
                                   crabfdc.nrctachq = crapchd.nrctachq   AND
                                   crabfdc.nrcheque = crapmdw.nrcheque
                                   USE-INDEX crapfdc1 EXCLUSIVE-LOCK NO-ERROR.
                                   
                IF   NOT AVAIL crabfdc   THEN   
                     DO:
                         ASSIGN i-cod-erro  = 108
                                c-desc-erro = " ".
                         RUN cria-erro (INPUT p-cooper,
                                        INPUT p-cod-agencia,
                                        INPUT p-nro-caixa,
                                        INPUT i-cod-erro,
                                        INPUT c-desc-erro,
                                        INPUT YES).
                         RETURN "NOK".
                     END.
        
                ASSIGN crabfdc.incheque = crabfdc.incheque + 5
                       crabfdc.dtliqchq = crapdat.dtmvtocd
                       crabfdc.cdoperad = p-cod-operador
                       crabfdc.vlcheque = crapmdw.vlcompel
                       
                       /* Associado que recebe o cheque */
                       crabfdc.nrctadep = crapass.nrdconta
                       crablcm.cdbanchq = crabfdc.cdbanchq
                       crablcm.cdagechq = crabfdc.cdagechq
                       crablcm.nrctachq = crabfdc.nrctachq.
                       
                /* Atualiza os campos de acordo com o tipo da conta do associado que
                   recebe o cheque */
                   
                
                IF  crapass.cdtipcta >= 8    AND
                    crapass.cdtipcta <= 11   THEN
                    DO:
                        /* BANCOOB */
                        IF  crapass.cdbcochq = 756 THEN
                            ASSIGN crabfdc.cdbandep = 756
                                   crabfdc.cdagedep = crapcop.cdagebcb.
                        ELSE
                            ASSIGN crabfdc.cdbandep = crapcop.cdbcoctl
                                   crabfdc.cdagedep = crapcop.cdagectl.
                    END.
                ELSE
                /* BANCO DO BRASIL - SEM DIGITO */
                     ASSIGN crabfdc.cdbandep = 1
                            crabfdc.cdagedep = INT(SUBSTRING(
                                                   STRING(crapcop.cdagedbb),1,
                                                   LENGTH(STRING(crapcop.cdagedbb))
                                                   - 1)).
        
                IF   crabfdc.tpcheque = 1   THEN
                     ASSIGN crablcm.cdhistor = 21.
                ELSE
                     ASSIGN crablcm.cdhistor = 26.

                VALIDATE crablcm.
            END.

          END. /* FIM cra2fdc avail */

          IF aux_temlock = TRUE THEN
          DO:
            RETURN "NOK".
          END.
          
          ASSIGN i-cod-erro  = 0
                 c-desc-erro = "".
          LEAVE.
        END.

    END. /* for each crapmdw */

    IF   de-valor = 0   THEN
         DO:
             ASSIGN i-cod-erro  = 269
                    c-desc-erro = " ".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
             RETURN "NOK".
          END.
                        
    /*---- Gera literal autenticacao - RECEBIMENTO(Rolo) ----*/
    ASSIGN c-nome-titular1 = " "
           c-nome-titular2 = " ".

    FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper    AND
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
           c-literal[1]  = TRIM(crapcop.nmrescop) + " - " + 
                           TRIM(crapcop.nmextcop)
           c-literal[2]  = " "
           c-literal[3]  = STRING(crapdat.dtmvtocd,"99/99/99") + " " + 
                           STRING(TIME,"HH:MM:SS") +  " PAC " +
                           STRING(p-cod-agencia,"999") + "  CAIXA: " + 
                           STRING(p-nro-caixa,"Z99") + "/" +
                           SUBSTR(p-cod-operador,1,10)
           c-literal[4]  = " "
           c-literal[5]  = "      ** COMPROVANTE DE DEPOSITO " + 
                           STRING(i-nro-docto,"ZZZ,ZZ9")  + " **"
           c-literal[6]  = " "
           c-literal[7]  = "CONTA: "    +  
                           TRIM(STRING(aux_nrdconta,"zzzz,zzz,9"))     +
                           "   PAC: " + TRIM(STRING(crapass.cdagenci)) 
           c-literal[8]  = "       "    +  TRIM(c-nome-titular1)
           c-literal[9]  = "       "    +  TRIM(c-nome-titular2)
           c-literal[10] = " ".
                   
    IF   p-identifica <> "  "   THEN
         ASSIGN c-literal[11] = "DEPOSITADO POR"  
                c-literal[12] = TRIM(p-identifica)
                c-literal[13] = " ".  
             
    ASSIGN c-literal[14] = "   TIPO DE DEPOSITO     VALOR EM R$ LIBERACAO EM"
           c-literal[15] = "------------------------------------------------".

    IF   de-dinheiro > 0   THEN
         ASSIGN c-literal[16] = "   EM DINHEIRO.....: " +  
                                STRING(de-dinheiro,"ZZZ,ZZZ,ZZ9.99") + "   ".

    IF   de-cooperativa > 0   THEN
         ASSIGN c-literal[17] = "CHEQ.COOPERATIVA...: " +  
                                STRING(de-cooperativa,"ZZZ,ZZZ,ZZ9.99") + " ".
    
    ASSIGN c-literal[22] = " "
           c-literal[23] = "TOTAL DEPOSITADO...: " +   
                           STRING(de-valor,"ZZZ,ZZZ,ZZ9.99")
           c-literal[24] = " "
           c-literal[25] = p-literal
           c-literal[26] = " "
           c-literal[27] = " "
           c-literal[28] = " "
           c-literal[29] = " "
           c-literal[30] = " "
           c-literal[31] = " "
           c-literal[32] = " "
           c-literal[33] = " "
           c-literal[34] = " "
           c-literal[35] = " ".

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
         ASSIGN p-literal-autentica =
                p-literal-autentica + STRING(c-literal[11],"x(48)")
                p-literal-autentica =
                p-literal-autentica + STRING(c-literal[12],"x(48)")
                p-literal-autentica =
                p-literal-autentica + STRING(c-literal[13],"x(48)").

    ASSIGN p-literal-autentica =
           p-literal-autentica + STRING(c-literal[14],"x(48)")
           p-literal-autentica =
           p-literal-autentica + STRING(c-literal[15],"x(48)").

    IF   c-literal[16] <> " "   THEN
         ASSIGN p-literal-autentica = p-literal-autentica + 
                                      STRING(c-literal[16],"x(48)").

    IF   c-literal[17] <> " "   THEN
         ASSIGN p-literal-autentica = p-literal-autentica + 
                                      STRING(c-literal[17],"x(48)").
    
    FOR EACH tt-cheques NO-LOCK:
        IF  tt-cheques.nrdocmto = 6  THEN
            ASSIGN p-literal-autentica = 
                                p-literal-autentica + 
                     STRING("CHEQ. OUTROS BANCOS: " +
                                STRING(tt-cheques.vlcompel,"ZZZ,ZZZ,ZZ9.99") +
                            " " +
                                STRING(tt-cheques.dtlibera,"99/99/9999"),
                                "x(48)").
        END.

    ASSIGN c-literal[30] = centraliza("SAC - " + STRING(crapcop.nrtelsac),48)
           c-literal[31] = centraliza("Atendimento todos os dias das " + REPLACE(REPLACE(STRING(crapcop.hrinisac,"HH:MM"),':','h'),'h00','h') + " as " + REPLACE(REPLACE(STRING(crapcop.hrfimsac,"HH:MM"),':','h'),'h00','h'),48)
           c-literal[32] = centraliza("OUVIDORIA - " + STRING(crapcop.nrtelouv),48)
           c-literal[33] = centraliza("Atendimento nos dias uteis das " + REPLACE(REPLACE(STRING(crapcop.hriniouv,"HH:MM"),':','h'),'h00','h') + " as " + REPLACE(REPLACE(STRING(crapcop.hrfimouv,"HH:MM"),':','h'),'h00','h'),48).    

    ASSIGN p-literal-autentica = p-literal-autentica         +
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
                                 STRING(c-literal[32],"x(48)")   +
                                 STRING(c-literal[33],"x(48)")   +
                                 STRING(c-literal[34],"x(48)")   +
                                 STRING(c-literal[35],"x(48)")   +
								 FILL(' ',384).

    ASSIGN p-ult-sequencia-autentica = p-ult-sequencia.

    ASSIGN in99 = 0.
    DO   WHILE TRUE:
         ASSIGN in99 = in99 + 1.
         FIND FIRST crapaut WHERE RECID(crapaut) = p-registro 
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAIL crapaut   THEN 
              DO:
                  IF   LOCKED crapaut   THEN 
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
                  ASSIGN  crapaut.dslitera = p-literal-autentica.
                  RELEASE crapaut.
                  LEAVE.
              END.
    END. /* DO WHILE */

    RELEASE craplot.

    RETURN "OK".

    /*Bloco para tratamento de erro do create da lcm try catch*/
    CATCH eSysError AS Progress.Lang.SysError:
      /*eSysError:GetMessage(1) Pegar a mensagem de erro do sistema*/
      /*Definindo minha propria critica*/
      ASSIGN i-cod-erro  = 0
             c-desc-erro = "Problemas na efetivacao do deposito. Repita a operação. " + eSysError:GetMessage(1).

      run cria-erro (INPUT p-cooper,
                     INPUT p-cod-agencia,
                     INPUT p-nro-caixa,
                     INPUT i-cod-erro,
                     INPUT c-desc-erro,
                     INPUT YES).

      RETURN "NOK".
    END CATCH.

END PROCEDURE.

PROCEDURE gera-tabela-resumo-dinheiro:

     DEF INPUT PARAM  p-cooper         AS CHAR NO-UNDO.
     DEF INPUT PARAM  p-cod-agencia    AS INT NO-UNDO. /* Cod.Agencia       */
     DEF INPUT PARAM  p-nro-caixa      AS INT NO-UNDO. /* Numero Caixa       */
     DEF INPUT PARAM  p-cod-operador   AS CHAR NO-UNDO.
     DEF INPUT PARAM  p-nro-conta      AS INT NO-UNDO.
     DEF INPUT PARAM  p-valor          AS DEC NO-UNDO.  /* Valor Dinheiro */

     DEF VAR aux_contlock AS INTEGER NO-UNDO.

     FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
      
     ASSIGN p-nro-conta = DEC(REPLACE(STRING(p-nro-conta),".","")).

    DO aux_contlock = 1 TO 10:
     FIND FIRST crapmrw WHERE crapmrw.cdcooper = crapcop.cdcooper   AND
                              crapmrw.cdagenci = p-cod-agencia      AND
                              crapmrw.nrdcaixa = p-nro-caixa   
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      IF NOT AVAILABLE crapmrw THEN
      DO:
        IF LOCKED(crapmrw) THEN
          DO:
          ASSIGN i-cod-erro  = 0
                 c-desc-erro = "Registro crapmrw esta em uso no momento. (Res. din)".
          PAUSE 1 NO-MESSAGE.
          NEXT.      
        END.
        ELSE
        DO: /* se n estiver locked e n existir, criar */
              CREATE crapmrw.
              ASSIGN crapmrw.cdcooper = crapcop.cdcooper
                     crapmrw.cdagenci = p-cod-agencia
                     crapmrw.nrdcaixa = p-nro-caixa
                     crapmrw.nrdconta = p-nro-conta.
          
          ASSIGN i-cod-erro  = 0
                 c-desc-erro = "".
          LEAVE.
        END.
      END.
      
      ASSIGN i-cod-erro  = 0
             c-desc-erro = "".
      LEAVE.
    END. /* fim contador */

    IF c-desc-erro <> "" THEN
    DO:
      RUN cria-erro (INPUT p-cooper,
                     INPUT p-cod-agencia,
                     INPUT p-nro-caixa,
                     INPUT i-cod-erro,
                     INPUT c-desc-erro,
                     INPUT YES).
      RETURN "NOK".
          END.

    ASSIGN crapmrw.cdopecxa = p-cod-operador
           crapmrw.vldepdin = p-valor.
     VALIDATE crapmrw.

     RETURN "OK".
END PROCEDURE.

PROCEDURE gera-tabela-resumo-cheques:
     DEF INPUT PARAM  p-cooper         AS CHAR NO-UNDO.
     DEF INPUT PARAM  p-cod-agencia    AS INT NO-UNDO. /* Cod. Agencia       */
     DEF INPUT PARAM  p-nro-caixa      AS INT NO-UNDO. /* Numero Caixa       */
     DEF INPUT PARAM  p-cod-operador   AS CHAR NO-UNDO.
     DEF INPUT PARAM  p-nro-conta      AS INT NO-UNDO.

     DEF VAR aux_contlock AS INT NO-UNDO.

     FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

     ASSIGN p-nro-conta = DEC(REPLACE(STRING(p-nro-conta),".","")).

     FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                        NO-LOCK NO-ERROR.

     ASSIGN dt-menor-praca  = ?
            dt-maior-praca  = ?
            dt-menor-fpraca = ?
            dt-maior-fpraca = ?
            dt-menor-fpraca = crapdat.dtmvtocd.
            
     DO   aux_contador = 1 TO 4:
          ASSIGN dt-menor-fpraca = dt-menor-fpraca + 1.

          IF   WEEKDAY(dt-menor-fpraca) = 1   THEN                           
               dt-menor-fpraca = dt-menor-fpraca + 1.
          ELSE
               IF   WEEKDAY(dt-menor-fpraca) = 7   THEN   
                    dt-menor-fpraca = dt-menor-fpraca + 2.

          DO   WHILE TRUE:
               FIND FIRST crapfer WHERE crapfer.cdcooper = crapcop.cdcooper AND
                                        crapfer.dtferiad = dt-menor-fpraca 
                                        NO-LOCK NO-ERROR.
                                        
               IF   AVAIL crapfer   THEN 
                    DO:
                       IF   WEEKDAY(dt-menor-fpraca + 1) = 1   THEN    
                            ASSIGN dt-menor-fpraca = dt-menor-fpraca + 2.
                       ELSE
                            IF  WEEKDAY(dt-menor-fpraca + 1) = 7   THEN
                                ASSIGN dt-menor-fpraca = dt-menor-fpraca + 3.
                            ELSE
                                ASSIGN dt-menor-fpraca = dt-menor-fpraca + 1. 
                       NEXT.
                    END.
               IF   aux_contador = 1   THEN
                    ASSIGN dt-maior-praca = dt-menor-fpraca.
               ELSE
                    IF   aux_contador = 2   THEN
                         ASSIGN dt-menor-praca = dt-menor-fpraca.
                    ELSE
                         IF   aux_contador = 3   THEN
                              ASSIGN dt-maior-fpraca = dt-menor-fpraca.
               LEAVE.
          END.  /*  do while */
     END.     /* do */


    DO aux_contlock = 1 TO 10:
     FIND FIRST crapmrw WHERE crapmrw.cdcooper = crapcop.cdcooper   AND
                              crapmrw.cdagenci = p-cod-agencia      AND
                              crapmrw.nrdcaixa = p-nro-caixa 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      IF NOT AVAILABLE crapmrw THEN
      DO:
        IF LOCKED(crapmrw) THEN
          DO:
          ASSIGN i-cod-erro  = 0
                 c-desc-erro = "Registro crapmrw esta em uso no momento. (Res. ch)".
          PAUSE 1 NO-MESSAGE.
          NEXT.      
        END.
        ELSE
        DO: /* se n estiver locked e n existir, criar */
              CREATE crapmrw.
              ASSIGN crapmrw.cdcooper = crapcop.cdcooper
                     crapmrw.cdagenci = p-cod-agencia
                     crapmrw.nrdcaixa = p-nro-caixa
                     crapmrw.nrdconta = p-nro-conta.
          END.
      END.
      
      ASSIGN i-cod-erro  = 0
             c-desc-erro = "".
      LEAVE.
    END. /* fim contador */

    IF c-desc-erro <> "" THEN
    DO:
      RUN cria-erro (INPUT p-cooper,
                     INPUT p-cod-agencia,
                     INPUT p-nro-caixa,
                     INPUT i-cod-erro,
                     INPUT c-desc-erro,
                     INPUT YES).
      RETURN "NOK".
    END.
           
     ASSIGN crapmrw.cdopecxa  = p-cod-operador
            crapmrw.vlchqcop  = 0
            crapmrw.vlchqspr  = 0
            crapmrw.vlchqipr  = 0
            crapmrw.vlchqsfp  = 0
            crapmrw.vlchqifp  = 0.
           
     VALIDATE crapmrw.

     FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper AND
                            crapmdw.cdagenci = p-cod-agencia    AND
                            crapmdw.nrdcaixa = p-nro-caixa      NO-LOCK:

         IF   crapmdw.cdhistor = 386   THEN
              ASSIGN crapmrw.vlchqcop = crapmrw.vlchqcop + crapmdw.vlcompel.

         IF   crapmdw.cdhistor = 3   THEN 
              DO:   /* Praca */
                  IF   crapmdw.dtlibcom = dt-menor-praca THEN
                       ASSIGN crapmrw.vlchqipr = crapmrw.vlchqipr + 
                                                         crapmdw.vlcompel
                              crapmrw.dtchqipr = crapmdw.dtlibcom.
                  ELSE
                       ASSIGN crapmrw.vlchqspr = crapmrw.vlchqspr + 
                                                 crapmdw.vlcompel
                              crapmrw.dtchqspr = crapmdw.dtlibcom.
              END.

         IF   crapmdw.cdhistor = 4   THEN 
              DO:     /* Fora Praca */
                  IF   crapmdw.dtlibcom = dt-menor-fpraca   THEN
                       ASSIGN crapmrw.vlchqifp = crapmrw.vlchqifp +
                                                         crapmdw.vlcompel
                              crapmrw.dtchqifp = crapmdw.dtlibcom.
                  ELSE
                       ASSIGN crapmrw.vlchqsfp = crapmrw.vlchqsfp + 
                                                         crapmdw.vlcompel
                              crapmrw.dtchqsfp = crapmdw.dtlibcom.
              END.
     END. /* for each crapmdw */
     RETURN "OK".
END PROCEDURE.

PROCEDURE critica-valor-dinheiro-cheque:
    DEF INPUT  PARAM p-cooper          AS CHAR NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia     AS INT  NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa       AS INT  NO-UNDO.
    DEF INPUT  PARAM p-valor           AS DEC  NO-UNDO.
    DEF INPUT  PARAM p-valor1          AS DEC  NO-UNDO.
    DEF OUTPUT PARAM p-achou-crapmdw   AS LOG  NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.

    IF   p-valor  = 0 AND
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

    IF   p-valor1 <> 0 AND NOT AVAIL crapmdw THEN 
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

PROCEDURE critica-contra-ordem:

    DEF INPUT  PARAM  p-cooper             AS CHAR                    NO-UNDO.
    DEF INPUT  PARAM  p-cod-agencia        AS INT                     NO-UNDO.
    DEF INPUT  PARAM  p-nro-caixa          AS INT  FORMAT "999"       NO-UNDO.
    DEF INPUT  PARAM  p-cod-operador       AS CHAR                    NO-UNDO.
    DEF INPUT  PARAM  p-nro-conta          AS INT                     NO-UNDO.
    DEF INPUT  PARAM  p-cmc-7              AS CHAR                    NO-UNDO.
    DEF INPUT  PARAM  p-cmc-7-dig          AS CHAR                    NO-UNDO.
    DEF INPUT  PARAM  p-cdcmpchq           AS INT  FORMAT "zz9"       NO-UNDO.
    DEF INPUT  PARAM  p-cdbanchq           AS INT  FORMAT "zz9"       NO-UNDO.
    DEF INPUT  PARAM  p-cdagechq           AS INT  FORMAT "zzz9"      NO-UNDO.
    DEF INPUT  PARAM  p-nrddigc1           AS INT  FORMAT "9"         NO-UNDO.
    DEF INPUT  PARAM  p-nrctabdb           AS DEC  FORMAT  
                                                   "zzz,zzz,zzz,9"    NO-UNDO.
    DEF INPUT  PARAM  p-nrddigc2           AS INT  FORMAT "9"         NO-UNDO.
    DEF INPUT  PARAM  p-nro-cheque         AS INT  FORMAT "zzz,zz9"   NO-UNDO.
    DEF INPUT  PARAM  p-nrddigc3           AS INT  FORMAT "9"         NO-UNDO.
    DEF INPUT  PARAM  p-valor              AS DEC                     NO-UNDO.
    DEF INPUT  PARAM p-grava-tabela        AS LOG  /* Grava tabela */ NO-UNDO.
    
    DEF OUTPUT PARAM p-transferencia-conta AS CHAR                    NO-UNDO.
    DEF OUTPUT PARAM p-aviso-cheque        AS CHAR                    NO-UNDO.
    DEF OUTPUT PARAM p-mensagem            AS CHAR                    NO-UNDO.
    DEF OUTPUT PARAM p-valor-disponivel    AS DEC                     NO-UNDO.
    
    DEF OUTPUT PARAM p-flg-cta-migrada     AS LOGICAL                 NO-UNDO.
    DEF OUTPUT PARAM p-coop-migrada        AS CHAR                    NO-UNDO.
    DEF OUTPUT PARAM p-flg-coop-host       AS LOGICAL                 NO-UNDO.
    DEF OUTPUT PARAM p-nro-conta-nova      AS INT                     NO-UNDO.
    DEF OUTPUT PARAM p-nro-conta-anti      AS INT                     NO-UNDO.

    DEF VAR aux_nrctaneg                   LIKE crapass.nrdconta      NO-UNDO.
                                                                  
    DEF BUFFER crabcop FOR crapcop.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR. 
    
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    ASSIGN i_nro-docto  = INTE(STRING(p-nro-cheque) + STRING(p-nrddigc3))
           i_nro-folhas = 0.
    
    RUN dbo/pcrap01.p (INPUT-OUTPUT i_nro-docto,     /* Nro Cheque       */
                       INPUT-OUTPUT i_nro-talao,     /* Nro Talao        */
                       INPUT-OUTPUT i_posicao,       /* Posicao          */  
                       INPUT-OUTPUT i_nro-folhas).   /* Nro Folhas       */ 

    ASSIGN aux_cdagebcb = crapcop.cdagebcb.
           glb_nrcalcul = INT(SUBSTR(STRING(i_nro-docto, "9999999"),1,6)).  

    FIND crapfdc WHERE crapfdc.cdcooper = crapcop.cdcooper   AND
                       crapfdc.cdbanchq = p-cdbanchq         AND
                       crapfdc.cdagechq = p-cdagechq         AND
                       crapfdc.nrctachq = p-nrctabdb         AND
                       crapfdc.nrcheque = INT(glb_nrcalcul)
                       NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapfdc   THEN
    DO:    
        /* Caso nao encontrar, validar se cheque eh de uma conta migrada */
        /* Se for Bco Cecred ou Bancoob usa o nrctaant = de-nrctabdb na busca da conta */
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
                                         crapfdc.nrcheque = INT(glb_nrcalcul)
                                         NO-LOCK NO-ERROR.
                IF  AVAIL crapfdc  THEN
                DO:
                    FIND crabcop WHERE crabcop.cdcooper = craptco.cdcopant
                       NO-LOCK NO-ERROR.
                    
                    ASSIGN p-flg-cta-migrada = TRUE
                           p-coop-migrada    = crabcop.nmrescop 
                           p-flg-coop-host   = FALSE
                           p-nro-conta-nova  = craptco.nrdconta
                           p-nro-conta-anti  = craptco.nrctaant.
                    
                END.
            END.
        END.
        ELSE 
        /* Se for BB usa a conta ITG para buscar conta migrada */
        /* Usa o nrdctitg = de-nrctabdb na busca da conta */
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
                                         crapfdc.nrcheque = INT(glb_nrcalcul)
                                         NO-LOCK NO-ERROR.

                IF  NOT AVAIL crapfdc  THEN
                DO:
                    FIND crabcop WHERE crabcop.cdcooper = craptco.cdcopant
                       NO-LOCK NO-ERROR.
                    
                    ASSIGN p-flg-cta-migrada = TRUE
                           p-coop-migrada    = crabcop.nmrescop
                           p-flg-coop-host   = FALSE
                           p-nro-conta-nova  = craptco.nrdconta
                           p-nro-conta-anti  = craptco.nrctaant.
                END.
            END.
        END.
    END.
    ELSE
    DO: 
        /* Localiza se o cheque é de uma conta migrada */
        FIND FIRST craptco WHERE 
                   craptco.cdcopant = crapcop.cdcooper  AND /* coop ant     */
                   craptco.nrctaant = inte(p-nrctabdb)  AND /* conta antiga */
                   craptco.tpctatrf = 1                 AND
                   craptco.flgativo = TRUE
                   NO-LOCK NO-ERROR.
        IF  AVAIL craptco  THEN
        DO:
            FIND crabcop WHERE crabcop.cdcooper = craptco.cdcooper
               NO-LOCK NO-ERROR.
                   
            ASSIGN p-flg-cta-migrada = TRUE
                   p-coop-migrada    = crabcop.nmrescop
                   p-flg-coop-host   = TRUE
                   p-nro-conta-nova  = craptco.nrdconta
                   p-nro-conta-anti  = craptco.nrctaant.
        END.
    END.
    
    /* Caso for cheque da cooperativa, continua a validacao */
    IF  AVAIL crapfdc  THEN
    DO:
    
    /*** Magui pesquisa primeiro se nao e conta ITG ***/
    ASSIGN aux_nrdctitg = "".
    /**  Conta Integracao **/
    IF   LENGTH(STRING(p-nrctabdb)) <= 8   THEN
         DO:
             ASSIGN aux_ctpsqitg = p-nrctabdb.
             IF  p-flg-cta-migrada  THEN
                 ASSIGN glb_cdcooper = crapfdc.cdcooper.
             RUN existe_conta_integracao.  
         END.

    /* Formata conta integracao */
    RUN fontes/digbbx.p (INPUT  p-nrctabdb,
                         OUTPUT glb_dsdctitg,                                
                         OUTPUT glb_stsnrcal).

    IF   aux_nrdctitg = ""   THEN
         DO   WHILE TRUE:
         FIND crapass WHERE crapass.cdcooper = crapfdc.cdcooper AND
                            crapass.nrdconta = aux_nrctaass 
                            NO-LOCK NO-ERROR.
                                  
         IF   NOT AVAIL crapass   THEN LEAVE.
         IF   AVAIL crapass   THEN 
              DO:
                  ASSIGN aux_nrctaneg = crapass.nrdconta.
                  IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN 
                       DO:
                           FIND FIRST craptrf WHERE
                                      craptrf.cdcooper = crapass.cdcooper   AND
                                      craptrf.nrdconta = crapass.nrdconta   AND
                                      craptrf.tptransa = 1                  AND
                                      craptrf.insittrs = 2  
                                      USE-INDEX craptrf1 NO-LOCK NO-ERROR.
    
                           IF   AVAIL craptrf   THEN  
                                DO:
                                    ASSIGN aux_nrtrfcta = craptrf.nrsconta
                                           aux_nrdconta = craptrf.nrsconta
                                           p-nrctabdb   = craptrf.nrsconta.
                                END.
                           ELSE 
                                LEAVE.
                       END.
                  ELSE
                       LEAVE.    
              END.
    END. /* DO WHILE */

    ASSIGN  i-p-nro-cheque      = p-nro-cheque  /* variaveis proc.ver_cheque */
            i-p-nrddigc3        = p-nrddigc3
            i-p-cdbanchq        = p-cdbanchq
            i-p-cdagechq        = p-cdagechq
            i-p-nrctabdb        = p-nrctabdb
            i-p-valor           = p-valor
            i-p-transferencia-conta  = " "
            i-p-aviso-cheque    = " "
            de-nrctachq         = DEC(SUBSTR(c-cmc-7,23,10)).
            
    /*  Le tabela com as contas convenio do Banco do Brasil - talao normal */
        RUN fontes/ver_ctace.p(INPUT crapfdc.cdcooper,
                               INPUT 1,
                               OUTPUT aux_lsconta1).

    /*  Le tabela com as contas convenio do Banco do Brasil - chq.salario */
        RUN fontes/ver_ctace.p(INPUT crapfdc.cdcooper,
                               INPUT 3,
                               OUTPUT aux_lsconta3).

    IF  CAN-DO(aux_lsconta3,STRING(p-nrctabdb))   THEN 
    DO:
        IF  CAN-DO("5,7", STRING(crapfdc.incheque))   THEN 
        DO:
            ASSIGN i-cod-erro  = 97
                   c-desc-erro = " ".           
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK". 
        END.
    
        IF  crapfdc.incheque = 8   THEN 
        DO:
            ASSIGN i-cod-erro  = 320
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
    ELSE 
         DO:
             ASSIGN aux_nrctaneg = crapfdc.nrdconta.
    
             IF   crapfdc.dtemschq = ?   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 108
                             c-desc-erro = " ".
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
             IF   crapfdc.dtretchq = ?   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 109
                             c-desc-erro = " ".
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.
    
             IF   CAN-DO("5,6,7", STRING(crapfdc.incheque))   THEN 
                  DO:
        
                      ASSIGN i-cod-erro  =  97 
                             c-desc-erro = " ".                        
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.

             IF   crapfdc.incheque = 8   THEN 
                  DO:
                      ASSIGN i-cod-erro  = 320
                             c-desc-erro = " ".
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.

              IF  (crapfdc.cdbantic <> 0
              OR   crapfdc.cdagetic <> 0
              OR   crapfdc.nrctatic <> 0) 
             AND  (crapfdc.dtlibtic >= crapdat.dtmvtocd
              OR   crapfdc.dtlibtic  = ?) THEN
                  DO:
                      ASSIGN i-cod-erro  = 950 
                             c-desc-erro = " ".
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".
                  END.

             IF   crapfdc.incheque = 1  OR
                  crapfdc.incheque = 2   THEN 
                  DO:

                    FIND crapass WHERE
                           crapass.cdcooper = crapfdc.cdcooper    AND
                           crapass.nrdconta = crapfdc.nrdconta
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
       
                      FIND crapcor WHERE
                           crapcor.cdcooper = crapfdc.cdcooper   AND
                           crapcor.cdbanchq = i-p-cdbanchq       AND
                           crapcor.cdagechq = i-p-cdagechq       AND
                           crapcor.nrctachq = i-p-nrctabdb       AND
                           crapcor.nrcheque = 
                                         INT(STRING(p-nro-cheque) +
                                         STRING(p-nrddigc3))     AND
                           crapcor.flgativo = TRUE
                           NO-LOCK NO-ERROR.
                      
                      IF   NOT AVAIL crapcor   THEN  
                           DO:
                               ASSIGN i-cod-erro  = 101
                                      c-desc-erro = " ".
                               RUN cria-erro (INPUT p-cooper,
                                              INPUT p-cod-agencia,
                                              INPUT p-nro-caixa,
                                              INPUT i-cod-erro,
                                              INPUT c-desc-erro,
                                              INPUT YES).
                               RETURN "NOK".
                           END.
                                                           
                      ASSIGN i-cod-erro  = 96
                             c-desc-erro = " ".
                      RUN cria-erro (INPUT p-cooper,
                                     INPUT p-cod-agencia,
                                     INPUT p-nro-caixa,
                                     INPUT i-cod-erro,
                                     INPUT c-desc-erro,
                                     INPUT YES).
                      RETURN "NOK".                       
                  END.
             
             FOR EACH crapneg WHERE 
                      crapneg.cdcooper = crapfdc.cdcooper AND
                      crapneg.nrdconta = aux_nrctaneg     AND
                      crapneg.nrdocmto = i_nro-docto      AND
                      crapneg.cdhisest = 1 
                      USE-INDEX crapneg1 NO-LOCK
                      BY crapneg.nrseqdig DESCENDING: 
                      
                 IF   CAN-DO("12,13",STRING(crapneg.cdobserv))  AND
                      crapneg.dtfimest = ?                      THEN
                      DO:        
                          ASSIGN i-cod-erro  = 761
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
    END. /* Fim AVAIL crapfdc */

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/
/*          Criticar o cheque se ele estiver em desconto de cheques           */
/******************************************************************************/
PROCEDURE critica_desconto_cheque:

    DEF INPUT  PARAM  par_cdcooper AS INTE NO-UNDO.
    DEF INPUT  PARAM  par_cdagenci AS INTE NO-UNDO.
    DEF INPUT  PARAM  par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT  PARAM  par_cdoperad AS CHAR NO-UNDO.
    DEF INPUT  PARAM  par_nrdconta AS INTE NO-UNDO.
    DEF INPUT  PARAM  par_cdcmpchq AS INTE NO-UNDO.
    DEF INPUT  PARAM  par_cdbanchq AS INTE NO-UNDO.
    DEF INPUT  PARAM  par_cdagechq AS INTE NO-UNDO.
    DEF INPUT  PARAM  par_nrctachq AS DECI NO-UNDO.
    DEF INPUT  PARAM  par_nrcheque AS INTE NO-UNDO.
    
    RUN elimina-erro (INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa).
    
    
    RETURN "OK".

END PROCEDURE.



/******************************************************************************/
/*               Criticar o cheque se ele estiver em custodia                 */
/******************************************************************************/
PROCEDURE critica_custodia:

    DEF INPUT  PARAM  par_cdcooper AS INTE NO-UNDO.
    DEF INPUT  PARAM  par_cdagenci AS INTE NO-UNDO.
    DEF INPUT  PARAM  par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT  PARAM  par_cdoperad AS CHAR NO-UNDO.
    DEF INPUT  PARAM  par_nrdconta AS INTE NO-UNDO.
    DEF INPUT  PARAM  par_cdcmpchq AS INTE NO-UNDO.
    DEF INPUT  PARAM  par_cdbanchq AS INTE NO-UNDO.
    DEF INPUT  PARAM  par_cdagechq AS INTE NO-UNDO.
    DEF INPUT  PARAM  par_nrctachq AS DECI NO-UNDO.
    DEF INPUT  PARAM  par_nrcheque AS INTE NO-UNDO.
    
    RUN elimina-erro (INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa).

    
    RETURN "OK".

END PROCEDURE.

/******************************************************************************/
/* Rotina de processamento automatico das autenticacoes, deposito e estorno   */
/******************************************************************************/
PROCEDURE autentica_cheques:

    DEF INPUT PARAM par_cdcooper AS CHAR   NO-UNDO.      
    DEF INPUT PARAM par_cdagenci AS INT    NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INT    NO-UNDO.
    DEF INPUT PARAM par_vestorno AS LOG    NO-UNDO.
    
    DEF INPUT PARAM p-nro-caixa  AS INT    NO-UNDO.
    DEF INPUT PARAM v_operador   AS CHAR   NO-UNDO.
    DEF INPUT PARAM par_nrdrowid AS ROWID  NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE   NO-UNDO.
    DEF INPUT PARAM par_nrdocmto AS DECI   NO-UNDO.
    

    DEF VAR h-b1crap00           AS HANDLE NO-UNDO.
    DEF VAR aux_nrcheque         AS INT    NO-UNDO.
    
    DEF BUFFER b-crapmdw1 FOR   crapmdw.

    DEF VAR aux_contlock AS INTEGER NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = par_cdcooper 
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapcop THEN
        DO:
            ASSIGN i-cod-erro  = 794
                   c-desc-erro = "".

           RUN cria-erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
    
           RETURN "NOK".       
        END.

    IF  NOT VALID-HANDLE(h-b1crap00) THEN
        RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.

    IF  par_vestorno = NO THEN
        DO:
        
          DO aux_contlock = 1 TO 10:

           FIND FIRST b-crapmdw1 WHERE b-crapmdw1.cdcooper = crapcop.cdcooper   AND
                                       b-crapmdw1.cdagenci = par_cdagenci       AND
                                       b-crapmdw1.nrdconta = par_nrdconta       AND
                                      (IF par_nrdrowid <> ? THEN 
                                           ROWID(b-crapmdw1) = par_nrdrowid
                                        ELSE
                                           TRUE)
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF NOT AVAILABLE b-crapmdw1 THEN
            DO:
              IF LOCKED(b-crapmdw1) THEN
              DO:
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Registro esta em uso no momento. (Aut. ch)".
                PAUSE 1 NO-MESSAGE.
                NEXT.      
              END.
              ELSE
              DO:
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = "Registro inexistente. (Aut. ch)".
                LEAVE.
              END.
            END.
            ELSE
              DO:
                  ASSIGN aux_nrcheque =  /* Estava usando "crapmdw" */
                         INTE(STRING(b-crapmdw1.nrcheque,"zzz,zz9") +  
                              STRING(b-crapmdw1.nrddigc3,"9")).
                  
                  RUN grava-autenticacao
                      IN h-b1crap00 (INPUT par_cdcooper /*v_coop*/,
                                     INPUT par_cdagenci /*int(v_pac)*/,
                                     INPUT p-nro-caixa /*int(v_caixa)*/,
                                     INPUT v_operador,
                                     INPUT b-crapmdw1.vlcompel,
                                     INPUT aux_nrcheque, 
                                     INPUT YES, /* YES (PG), NO (REC) */
                                     INPUT "1",  /* On-line            */                                             
                                     INPUT NO,   /* Nao estorno        */
                                     INPUT 386, 
                                     INPUT ?, /* Data off-line */
                                     INPUT 0, /* Sequencia off-line */
                                     INPUT 0, /* Hora off-line */
                                     INPUT 0, /* Seq.orig.Off-line */
                                     OUTPUT p-literal,
                                     OUTPUT p-ult-sequencia,
                                     OUTPUT p-registro).
                  
                  IF  RETURN-VALUE = "NOK" THEN
                      DO:
                          ASSIGN i-cod-erro  = 0
                                 c-desc-erro = "Erro na Autenticaçao".
                  
                          RUN cria-erro (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT p-nro-caixa,
                                         INPUT i-cod-erro,
                                         INPUT c-desc-erro,
                                         INPUT YES).
                  
                          FIND CURRENT b-crapmdw1 NO-LOCK.
                          RELEASE b-crapmdw1.
                  
                          IF  VALID-HANDLE(h-b1crap00) THEN
                          DELETE PROCEDURE h-b1crap00.

                          RETURN "NOK".  
                      END.
                   
                  ASSIGN b-crapmdw1.nrautdoc = p-ult-sequencia.

                  FIND CURRENT b-crapmdw1 NO-LOCK.
                  RELEASE b-crapmdw1.
                 
              IF  VALID-HANDLE(h-b1crap00) THEN
                  DELETE PROCEDURE h-b1crap00.
              
              RETURN "OK".
  
            END.
          END. /* fim contador */
          
          IF c-desc-erro <> "" THEN
          DO:
            RUN cria-erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
            RETURN "NOK".
              END.

        END.
    ELSE
       DO:  
           FOR EACH crapchd WHERE crapchd.cdcooper = crapcop.cdcooper    AND
                                  crapchd.dtmvtolt = par_dtmvtolt        AND
                                  crapchd.cdagenci = par_cdagenci        AND
                                  crapchd.cdbccxlt = 11                  AND
                                  crapchd.nrdolote = 11000 + p-nro-caixa AND
                                  crapchd.nrdconta = par_nrdconta        AND
                                  crapchd.inchqcop = 1
                                  NO-LOCK:
                 
               IF  STRING(crapchd.nrdocmto) BEGINS STRING(par_nrdocmto)  THEN
               DO:
                   ASSIGN aux_nrcheque = 
                           INTE(STRING(crapchd.nrcheque,"zzz,zz9") + 
                                STRING(crapchd.nrddigc3,"9")).
    
                   RUN grava-autenticacao  
                         IN h-b1crap00 (INPUT par_cdcooper /*v_coop*/,
                                        INPUT par_cdagenci /*int(v_pac)*/,
                                        INPUT p-nro-caixa /*int(v_caixa)*/,
                                        INPUT v_operador,
                                        INPUT crapchd.vlcheque,
                                        INPUT aux_nrcheque, 
                                        INPUT YES, /* YES (PG), NO (REC) */
                                        INPUT "1",  /* On-line            */ 
                                        INPUT YES,   /* Nao estorno        */
                                        INPUT 386, 
                                        INPUT ?, /* Data off-line */
                                        INPUT 0, /* Sequencia off-line */
                                        INPUT 0, /* Hora off-line */
                                        INPUT 0, /* Seq.orig.Off-line */
                                        OUTPUT p-literal,
                                        OUTPUT p-ult-sequencia,
                                        OUTPUT p-registro).
    
                    IF  RETURN-VALUE = "NOK" THEN
                    DO:
                        ASSIGN i-cod-erro  = 0
                               c-desc-erro = "Erro na Autenticaçao".
    
                        RUN cria-erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT p-nro-caixa,
                                       INPUT i-cod-erro,
                                       INPUT c-desc-erro,
                                       INPUT YES).
                        
                        IF  VALID-HANDLE(h-b1crap00) THEN
                        DELETE PROCEDURE h-b1crap00.
                        
                        RETURN "NOK".  
                    END.
               END.
           END.

       END.

    IF  VALID-HANDLE(h-b1crap00) THEN
        DELETE PROCEDURE h-b1crap00.
    
    RETURN "OK".
  
END PROCEDURE.

/*********************/
/* b1crap51.p */
 
/* ......................................................................... */ 