/* .............................................................................

   Programa: siscaixa/web/b1crap66.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Guilherme
   Data    : Julho/2011                      Ultima atualizacao: 27/07/2016

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Lançamento de cheques (adaptacao da rotina 51 + lanchq) 

   Alteracoes: 29/07/2011 - Adaptado da rotina 51 (Guilherme).
   
               21/09/2011 - Alterar banco caixa de 500 p/ 11 
                          - Alterar o Lote de 28000 + nro-caixa 
                                         para 30000 + Nro-caixa
                          - Alterar o Tipo de Lote de 1 
                                                 para 23
                          - Procedure grava-autenticacao de RC para PG
                          - Adaptar para criacao do registro craplcx com o valor
                            total de lancamento (o vinculo lcx com chd ocorre
                                                 pelo nrautdoc, ver b1crap86)
                            (Guilherme).
                            
               21/05/2012 - substituição do FIND craptab para os registros 
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.)
                            
               18/06/2012 - Alteracao na leitura da craptco (David Kruger).        
               
               10/10/2012 - Alteracao da logica para migracao de PA
                            devido a migracao da AltoVale (Guilherme).
                            
               03/01/2014 - Incluido validate para as tabelas crapchd
                            craplcx crapmrw (Tiago).  
                            
               19/02/2014 - Ajuste leitura craptco (Daniel).
               
               05/08/2014 - Alteração da Nomeclatura para PA (Vanessa). 
                            
               20/06/2016 - Adicionado validacao para nao permitir o recebimento 
                            de cheques de bancos que nao participam da COMPE
                            (Douglas - Chamado 417655)
                            
               27/07/2016 - Alterado validacao para nao permitir o recebimento 
                            de cheques de bancos que nao participam da COMPE
                            Utilizar apenas BANCO e FLAG ativo
                            (Douglas - Chamado 417655)

               16/03/2018 - Substituida verificacao "cdtipcta = 6,7" pela
                            modalidade do tipo de conta igual a 3. PRJ366 (Lombardi).
............................................................................. */

/*--------------------------------------------------------------------------*/
/*  b1crap51.p   - Depositos com Captura                                    */
/*--------------------------------------------------------------------------*/

{ dbo/bo-erro1.i }
{ sistema/generico/includes/var_internet.i }

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
    
    IF   aux_cdmodali = 3 THEN /* Conta tipo Poupanca */
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

    DEF VAR aux_totvlchq AS INTE                                      NO-UNDO.
    DEF VAR h-b1wgen0001 AS HANDLE                                    NO-UNDO.
    DEF VAR h-b1wgen0044 AS HANDLE                                    NO-UNDO.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

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

    ASSIGN i-nro-lote = 30000 + p-nro-caixa.

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

    /* Le tabela com as contas convenio do Banco do Brasil - chq.salario */
    RUN fontes/ver_ctace.p(INPUT crapcop.cdcooper,
                           INPUT 3,
                           OUTPUT aux_lsconta3).

    ASSIGN i_conta = dec(p-nro-conta). 

    RUN dbo/b2crap00.p PERSISTENT SET h_b2crap00.
    RUN verifica-digito IN h_b2crap00(INPUT p-cooper,
                                      INPUT p-cod-agencia,
                                      INPUT p-nro-caixa,
                                      INPUT-OUTPUT i_conta).
    DELETE PROCEDURE h_b2crap00.

    IF   RETURN-VALUE = "NOK"   THEN
         RETURN "NOK".

    ASSIGN aux_nrdconta = p-nro-conta 
           aux_nrtrfcta = 0.

    DO  WHILE TRUE:
        FIND FIRST crapass WHERE crapass.cdcooper = crapcop.cdcooper    AND
                                 crapass.nrdconta = aux_nrdconta 
                                 NO-LOCK NO-ERROR.
                                 
        IF   NOT AVAIL crapass   THEN 
             DO:
                 ASSIGN i-cod-erro  = 911
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
                 FIND FIRST craptrf WHERE 
                            craptrf.cdcooper = crapcop.cdcooper     AND 
                            craptrf.nrdconta = crapass.nrdconta     AND
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
             RUN ver_capital IN h-b1wgen0001(INPUT  crapcop.cdcooper,
                                             INPUT  aux_nrdconta,
                                             INPUT  p-cod-agencia,
                                             INPUT  p-nro-caixa,
                                             0,
                                             INPUT  crapdat.dtmvtolt,
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

    ASSIGN aux_cdagebcb = crapcop.cdagebcb
           i-p-nro-cheque     = p-nro-cheque  /* variaveis proc.ver_cheque */
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
    DO:
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "Cheque da cooperativa, utilizar rotina 53.".
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

    IF  CAN-FIND(crapchd WHERE crapchd.cdcooper = crapcop.cdcooper     AND
                               crapchd.dtmvtolt = crapdat.dtmvtolt     AND
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
         FIND FIRST crapchd WHERE crapchd.cdcooper = crapcop.cdcooper   AND
                                  crapchd.dtmvtolt = crapdat.dtmvtolt   AND
                                  crapchd.cdcmpchq = w-compel.cdcmpchq  AND
                                  crapchd.cdbanchq = w-compel.cdbanchq  AND
                                  crapchd.cdagechq = w-compel.cdagechq  AND
                                  crapchd.nrctachq = (IF aux_nrctcomp > 0 
                                                         THEN p-nrctabdb
                                                     ELSE de-nrctachq)  AND
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

     ASSIGN dt-liberacao    = ?
            dt-menor-praca  = ?
            dt-maior-praca  = ?
            dt-menor-fpraca = ?
            dt-maior-fpraca = ?
            i-digito =  0.
     
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

              FIND FIRST crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper  AND
                                       crapmdw.cdagenci = p-cod-agencia     AND
                                       crapmdw.nrdcaixa = p-nro-caixa       AND
                                       crapmdw.nrctabdb = p-nrctabdb        AND
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
                     crapmdw.lsdigctr = p-lista-digito
                     crapmdw.tpdmovto = aux_tpdmovto
                     crapmdw.nrseqdig = i-digito
                     crapmdw.cdtipchq = INTE(SUBSTRING(c-cmc-7,20,1)).
              
              IF   aux_nrtalchq <> 0   THEN
                   ASSIGN crapmdw.nrtalchq = aux_nrtalchq
                          crapmdw.nrposchq = i_posicao.
              
              RELEASE crapmdw.

          END.  /* Grava Tabela */
        
    RETURN "OK".
    
END PROCEDURE.

PROCEDURE atualiza-deposito-com-captura:

    DEF INPUT  PARAM  p-cooper              AS CHAR NO-UNDO.
    DEF INPUT  PARAM  p-cod-agencia         AS INT  NO-UNDO. /* Cod.Agencia  */
    DEF INPUT  PARAM  p-nro-caixa           AS INT  NO-UNDO. /* Numero Caixa */
    DEF INPUT  PARAM  p-cod-operador        AS CHAR NO-UNDO.
    DEF INPUT  PARAM  p-nro-conta           AS INT  NO-UNDO.
    
    DEF INPUT  PARAM  p-nome-titular            AS CHAR NO-UNDO.
    DEF INPUT  PARAM  p-identifica              AS CHAR NO-UNDO.
    DEF INPUT  PARAM  par_cdoperad              AS CHAR NO-UNDO.
    DEF INPUT  PARAM  par_cddsenha              AS CHAR NO-UNDO.
    
    DEF OUTPUT PARAM  p-literal-autentica       AS CHAR NO-UNDO.
    DEF OUTPUT PARAM  p-ult-sequencia-autentica AS INT  NO-UNDO.
    DEF OUTPUT PARAM  p-nro-docto               AS INT  NO-UNDO.

    DEFINE VARIABLE h_b1wgen0000 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE aux_qtcheque AS INT         NO-UNDO.
    
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
    
    DO  WHILE TRUE:
        
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
    
    RUN sistema/generico/procedures/b1wgen0000.p 
                  PERSISTENT SET h_b1wgen0000.

    RUN valida-senha-coordenador IN h_b1wgen0000 (INPUT crapcop.cdcooper,
                                                  INPUT p-cod-agencia,            
                                                  INPUT p-nro-caixa,            
                                                  INPUT p-cod-operador, 
                                                  INPUT "b1crap66", 
                                                  INPUT 2, /* cx online */  
                                                  INPUT 0,  /* conta */
                                                  INPUT 0,  /* se ttl */
                                                  INPUT 2, /* coordenador */
                                                  INPUT par_cdoperad,
                                                  INPUT par_cddsenha,
                                                  INPUT FALSE,       
                                                 OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h_b1wgen0000.

    IF  RETURN-VALUE = "NOK"  THEN
    DO:
         FIND FIRST tt-erro NO-ERROR.
         IF   AVAIL tt-erro   THEN
         DO:
            ASSIGN i-cod-erro  = 0
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
                    c-desc-erro = "Erro ao validar senha de coordenador".
             RUN cria-erro (INPUT p-cooper,
                            INPUT p-cod-agencia,
                            INPUT p-nro-caixa,
                            INPUT i-cod-erro,
                            INPUT c-desc-erro,
                            INPUT YES).
         END.
    
         RETURN "NOK".
    END.
    
    ASSIGN i-nro-lote = 30000 + p-nro-caixa.

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.

    FIND FIRST crapmrw WHERE crapmrw.cdcooper = crapcop.cdcooper    AND 
                             crapmrw.cdagenci = p-cod-agencia       AND
                             crapmrw.nrdcaixa = p-nro-caixa   
                             NO-LOCK NO-ERROR.
                             
    IF   NOT AVAIL crapmrw   THEN 
         DO:
             ASSIGN i-cod-erro  = 0
                    c-desc-erro = "Nao existem valores a serem lançados".
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

    ASSIGN dt-menor-praca  = ?
           dt-maior-praca  = ?
           dt-menor-fpraca = ?
           dt-maior-fpraca = ?
           dt-menor-fpraca = crapdat.dtmvtolt
           aux_nrdconta = p-nro-conta.
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

    ASSIGN c-docto-salvo = STRING(time).

    FIND FIRST craplot WHERE craplot.cdcooper = crapcop.cdcooper  AND
                             craplot.dtmvtolt = crapdat.dtmvtolt  AND
                             craplot.cdagenci = p-cod-agencia     AND
                             craplot.cdbccxlt = 11                AND /* Fixo */
                             craplot.nrdolote = i-nro-lote 
                             EXCLUSIVE-LOCK NO-ERROR.
         
    IF   NOT AVAIL craplot   THEN 
         DO: 
             CREATE craplot.
             ASSIGN craplot.cdcooper = crapcop.cdcooper
                    craplot.dtmvtolt = crapdat.dtmvtolt
                    craplot.cdagenci = p-cod-agencia
                    craplot.cdbccxlt = 11
                    craplot.nrdolote = i-nro-lote
                    craplot.tplotmov = 23
                    craplot.cdoperad = p-cod-operador
                    craplot.cdhistor = 731
                    craplot.nrdcaixa = p-nro-caixa
                    craplot.cdopecxa = p-cod-operador.
         END.
             
    ASSIGN de-valor        = 0
           de-maior-praca  = 0
           de-menor-praca  = 0
           de-maior-fpraca = 0
           de-menor-fpraca = 0.
    
    /* Buscar os totais de cheque maior e menor da Praca ou fora Praca */
    FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper AND
                           crapmdw.cdagenci = p-cod-agencia    AND
                           crapmdw.nrdcaixa = p-nro-caixa NO-LOCK:
        
        ASSIGN de-valor     = de-valor + crapmdw.vlcompel
               aux_qtcheque = aux_qtcheque + 1.
        
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
                                           INPUT YES, /* YES (PG), NO (REC) */
                                           INPUT "1",  /* On-line  */     
                                           INPUT NO,   /* Nao estorno */     
                                           INPUT craplot.cdhistor,
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
         
    /* Cheques praça e fora praça serão dinamicos 
       pela influencia do CAF */
    ASSIGN aux_nrsequen = 0.
    
    FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper  AND
                           crapmdw.cdagenci = p-cod-agencia     AND
                           crapmdw.nrdcaixa = p-nro-caixa       NO-LOCK:
        
        /* Formata conta integracao */
        RUN fontes/digbbx.p (INPUT  crapmdw.nrctabdb,
                             OUTPUT glb_dsdctitg,
                             OUTPUT glb_stsnrcal).

        FIND FIRST crapchd WHERE crapchd.cdcooper = crapcop.cdcooper    AND
                                 crapchd.dtmvtolt = crapdat.dtmvtolt    AND
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

        CREATE crapchd.
        ASSIGN crapchd.cdcooper = crapcop.cdcooper
               crapchd.cdagechq = crapmdw.cdagechq
               crapchd.cdagenci = p-cod-agencia
               crapchd.cdbanchq = crapmdw.cdbanchq
               crapchd.cdbccxlt = 11
               crapchd.nrdocmto = p-ult-sequencia
               crapchd.cdcmpchq = crapmdw.cdcmpchq
               crapchd.cdoperad = p-cod-operador
               crapchd.cdsitatu = 1
               crapchd.dsdocmc7 = crapmdw.dsdocmc7
               crapchd.dtmvtolt = crapdat.dtmvtolt
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
               crapchd.vlcheque = crapmdw.vlcompel 
               crapchd.nrseqdig = craplot.nrseqdig + 1

               craplot.nrseqdig  = craplot.nrseqdig + 1
               craplot.qtcompln  = craplot.qtcompln + 1
               craplot.qtinfoln  = craplot.qtinfoln + 1
               craplot.vlcompcr  = craplot.vlcompcr + crapmdw.vlcompel
               craplot.vlinfocr  = craplot.vlinfocr + crapmdw.vlcompel.
        VALIDATE crapchd.
        
        /** Incrementa contagem de cheques para a previa **/
        RUN dbo/b1crap00.p PERSISTENT SET h_b1crap00.
        RUN atualiza-previa-caixa  IN h_b1crap00  (INPUT p-cooper,
                                                   INPUT p-cod-agencia,
                                                   INPUT p-nro-caixa,
                                                   INPUT p-cod-operador,
                                                   INPUT crapdat.dtmvtolt,
                                                   INPUT 1). /*Inclusao*/ 
        DELETE PROCEDURE h_b1crap00.

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

    FIND LAST crapbcx WHERE crapbcx.cdcooper = crapcop.cdcooper  AND
                            crapbcx.dtmvtolt = crapdat.dtmvtolt  AND
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

    CREATE craplcx.
    ASSIGN craplcx.dtmvtolt = crapdat.dtmvtolt
           craplcx.cdagenci = p-cod-agencia
           craplcx.nrdcaixa = p-nro-caixa
           craplcx.cdopecxa = p-cod-operador
           craplcx.nrdocmto = p-ult-sequencia
           craplcx.nrseqdig = crapbcx.qtcompln + 1
           craplcx.nrdmaqui = crapbcx.nrdmaqui
           craplcx.cdhistor = 731
           craplcx.nrautdoc = p-ult-sequencia
           craplcx.dsdcompl = "LANCHQ (" + STRING(aux_qtcheque,"9999") + 
                              ") - Conta/dv:" + 
                              STRING(crapchd.nrdconta,"zzzz,zzz,z")
           crapbcx.qtcompln = crapbcx.qtcompln + 1
           craplcx.vldocmto = de-valor
           craplcx.cdcooper = crapcop.cdcooper.
    VALIDATE craplcx.

                          
    /*---- Gera literal autenticacao - RECEBIMENTO(Rolo) ----*/
    ASSIGN c-nome-titular1 = " "
           c-nome-titular2 = " "
           c-literal = " "
           c-literal[1]  = TRIM(crapcop.nmrescop) + " - " + 
                           TRIM(crapcop.nmextcop)
           c-literal[2]  = " "
           c-literal[3]  = STRING(crapdat.dtmvtolt,"99/99/99") + " " + 
                           STRING(TIME,"HH:MM:SS") +  " PA  " +
                           STRING(p-cod-agencia,"999") + "  CAIXA: " + 
                           STRING(p-nro-caixa,"Z99") + "/" +
                           SUBSTR(p-cod-operador,1,10)
           c-literal[4]  = " "
           c-literal[5]  = "     ** COMPROVANTE DE LANCAMENTO " + 
                           STRING(i-nro-docto,"ZZZ,ZZ9")  + " **"
           c-literal[10] = " ".
                   
    IF   p-identifica <> "  "   THEN
         ASSIGN c-literal[11] = "LANCADO POR"  
                c-literal[12] = TRIM(p-identifica)
                c-literal[13] = " ".  
             
    ASSIGN c-literal[22] = " "
           c-literal[23] = "TOTAL LANCADO......: " +   
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
           p-literal-autentica = STRING(c-literal[1],"x(48)")   +
                                 STRING(c-literal[2],"x(48)")   +
                                 STRING(c-literal[3],"x(48)")   +
                                 STRING(c-literal[4],"x(48)")   +
                                 STRING(c-literal[5],"x(48)")   +
                                 STRING(c-literal[10],"x(48)").   
      
    IF   c-literal[12] <> " "   THEN
         ASSIGN p-literal-autentica =
                p-literal-autentica + STRING(c-literal[11],"x(48)")
                p-literal-autentica =
                p-literal-autentica + STRING(c-literal[12],"x(48)")
                p-literal-autentica =
                p-literal-autentica + STRING(c-literal[13],"x(48)").
    
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
                                 STRING(c-literal[35],"x(48)")
           p-ult-sequencia-autentica = p-ult-sequencia.

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
END PROCEDURE.

PROCEDURE gera-tabela-resumo-cheques:
     DEF INPUT PARAM  p-cooper         AS CHAR NO-UNDO.
     DEF INPUT PARAM  p-cod-agencia    AS INT NO-UNDO. /* Cod. Agencia       */
     DEF INPUT PARAM  p-nro-caixa      AS INT NO-UNDO. /* Numero Caixa       */
     DEF INPUT PARAM  p-cod-operador   AS CHAR NO-UNDO.
     DEF INPUT PARAM  p-nro-conta      AS INT NO-UNDO.

     FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

     ASSIGN p-nro-conta = DEC(REPLACE(STRING(p-nro-conta),".","")).

     FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                        NO-LOCK NO-ERROR.

     ASSIGN dt-menor-praca  = ?
            dt-maior-praca  = ?
            dt-menor-fpraca = ?
            dt-maior-fpraca = ?
            dt-menor-fpraca = crapdat.dtmvtolt.
            
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
                            IF   WEEKDAY(dt-menor-fpraca + 1) = 7   THEN                                         
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

     FIND FIRST crapmrw WHERE crapmrw.cdcooper = crapcop.cdcooper   AND
                              crapmrw.cdagenci = p-cod-agencia      AND
                              crapmrw.nrdcaixa = p-nro-caixa 
                              EXCLUSIVE-LOCK NO-ERROR.

     IF   NOT AVAIL crapmrw   THEN  
          DO:
              CREATE crapmrw.
              ASSIGN crapmrw.cdcooper = crapcop.cdcooper
                     crapmrw.cdagenci = p-cod-agencia
                     crapmrw.nrdcaixa = p-nro-caixa
                     crapmrw.nrdconta = p-nro-conta.
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
                            crapmdw.nrdcaixa = p-nro-caixa      EXCLUSIVE-LOCK:

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

    /* Validar se a folha de cheque é da cooperativa */
    FIND crapfdc WHERE crapfdc.cdcooper = crapcop.cdcooper   AND
                       crapfdc.cdbanchq = p-cdbanchq         AND
                       crapfdc.cdagechq = p-cdagechq         AND
                       crapfdc.nrctachq = p-nrctabdb         AND
                       crapfdc.nrcheque = INT(glb_nrcalcul)
                       NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapfdc   THEN
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
                                        crapfdc.nrcheque = INT(glb_nrcalcul)
                                        NO-LOCK NO-ERROR.
               IF  AVAIL crapfdc  THEN
               DO:
                   ASSIGN i-cod-erro  = 0
                          c-desc-erro = "Cheque da cooperativa, utilizar rotina 53".
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
                                        crapfdc.nrcheque = INT(glb_nrcalcul)
                                        NO-LOCK NO-ERROR.

               IF  AVAIL crapfdc  THEN
               DO:
                   ASSIGN i-cod-erro  = 0
                          c-desc-erro = "Cheque da cooperativa, utilizar rotina 53".
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
    ELSE
    DO:
        ASSIGN i-cod-erro  = 0
               c-desc-erro = "Cheque da cooperativa, utilizar rotina 53".
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


/*********************/
/* b1crap66.p */
 
/* ......................................................................... */ 

 


