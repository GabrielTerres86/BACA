/* .............................................................................

   Programa: siscaixa/web/dbo/b1crap02.p
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 17/04/2017

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Consulta Conta

   Alteracoes: 11/08/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)
                            
               07/11/2005 - Alteracao de crapchs e crapchq p/ crapfdc 
                            (SQLWorks)
                            
               16/11/2005 - Adequacao ao padrao, analise de performance e dos
                            itens convertidos
                            
               24/11/2005 - Acertar leitura do crapfdc (Magui).
               
               22/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               12/12/2008 - Incluidos campos com informacoes das Cotas de
                            Capital e Aplicacoes (Elton).
                            
               16/02/2009 - Alteracao cdempres (Diego).

               10/03/2009 - Ajuste para unificacao dos bancos de dados
                            (Evandro)
                            
               25/05/2009 - Alteracao CDOPERAD (Kbase).
               
               18/06/2009 - Tratamento para impressão do SALDO EM APLICACAO 
                            (Diego).
               
               26/08/2009 - Incluido campo "Poup. Prog" na tela e o saldo da
                            poupanca programada na impressao do "Saldo em
                            Aplicacao" (Elton).
                            
               30/09/2009 - Adaptacao projeto nossa COMPE (Guilherme).
               
               04/11/2009 - Incluir novas variaveis utilizadas na procedure
                            saldo-rdca-resgate (b1wgen0004.i) (David).
                            
               02/06/2011 - Estanciado a b1wgen0004 ao inicio do programa e
                            deletado ao final para ganho de performance
                            (Adriano).
                                         
               07/07/2011 - Realizado correcao no format do campo c-literal[7]
                            para "zzzz,zz9.9" (Adriano).                       
                                                                      
               07/02/2013 - Incluir procedure valida_restricao_operador, 
                            incluir chamada da procedure valida_restricao_operador
                            (Lucas R.).
                            
               12/08/2013 - Incluir tratamento para imprimir valor bloq. jud 
                            dentro da procedure impressao-saldo (Lucas R.)
                            
               16/09/2013 - Tratamento para Imunidade Tributaria (Ze).
               
               14/11/2013 - Alterado totalizador de PAs de 99 para 999.
                            (Reinert)
                            
               03/07/2014 - Ajuste para restricao de operadores 
                           (Chamado 163002) (Jonata - RKAM).      
                           
               10/12/2014 - Incluso comentario na criação tt-conta (Daniel).   
			   
			   26/04/2016 - Inclusao dos horarios de SAC e OUVIDORIA nos
			                comprovantes, melhoria 112 (Tiago/Elton)    

			   17/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).

               17/07/2017 - Alteraçao CDOEDTTL pelo campo IDORGEXP.
                           PRJ339 - CRM (Odirlei-AMcom)  
             
........................................................................... */

/*---------------------------------------------------------------*/
/*  b1crap02.p - Consulta Conta                                  */
/*---------------------------------------------------------------*/


{ sistema/generico/includes/b1wgen0004tt.i }
/*{ sistema/generico/includes/var_oracle.i }*/

{dbo/bo-erro1.i}

DEF  VAR glb_nrcalcul    AS DECIMAL                            NO-UNDO.
DEF  VAR glb_dsdctitg    AS CHAR                               NO-UNDO.
DEF  VAR glb_stsnrcal    AS LOGICAL                            NO-UNDO.
            
DEF  VAR i-cod-erro      AS INTEGER                            NO-UNDO.
DEF  VAR c-desc-erro     AS CHAR                               NO-UNDO.
DEF  VAR aux_nrcpfcgc    AS CHAR                               NO-UNDO.
                                   
DEF  VAR aux_vltotrda    AS DEC                                NO-UNDO.    

DEF VAR h-b1wgen0155 AS HANDLE                                 NO-UNDO.
DEF VAR h-b1wgen0052b AS HANDLE                                NO-UNDO.
DEF VAR aux_vlblqjud AS DECI                                   NO-UNDO.
DEF VAR aux_vlblqpop AS DECI                                   NO-UNDO.
DEF VAR aux_vlresblq AS DECI                                   NO-UNDO.
DEF VAR aux_vlrespop AS DECI                                   NO-UNDO.

DEF  TEMP-TABLE tt-erro  NO-UNDO     LIKE craperr. 
DEF  TEMP-TABLE craterr  NO-UNDO     LIKE craperr.   

/* CASO SEJA INCLUSO NOVO CAMPO NA TT-CONTA DEVE-SE INCLUIR TAMBEM NHO FONTE 
   tempo_execucao_caixaonline.p */
DEF TEMP-TABLE tt-conta                                        NO-UNDO
    FIELD situacao           AS CHAR FORMAT "x(21)"
    field tipo-conta         AS CHAR FORMAT "x(21)"
    field empresa            AS CHAR FORMAT "x(15)"
    field devolucoes         AS INTE FORMAT "99"
    field agencia            AS CHAR FORMAT "x(15)"
    field magnetico          AS INTE FORMAT "z9"     
    field estouros           AS INTE FORMAT "zzz9"
    field folhas             AS INTE FORMAT "zzz,zz9"
    field identidade         AS CHAR 
    field orgao              AS CHAR 
    field cpfcgc             AS CHAR 
    field disponivel         AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD bloqueado          AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    field bloq-praca         AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    field bloq-fora-praca    AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    field cheque-salario     AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    field saque-maximo       AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    field acerto-conta       AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    field db-cpmf            AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    field limite-credito     AS DEC 
    field ult-atualizacao    AS DATE
    field saldo-total        AS DEC FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD nome-tit           AS CHAR
    FIELD nome-seg-tit       AS CHAR                                
    FIELD capital            AS DEC FORMAT "zzz,zzz,zzz,zz9.99-".
       
    
DEF  VAR de-valor-total  AS DEC NO-UNDO.

DEF  VAR c-literal       AS CHAR FORMAT "x(48)" EXTENT 28      NO-UNDO.
DEF  VAR c-nome-titular1 AS CHAR FORMAT "x(40)"                NO-UNDO.
DEF  VAR c-nome-titular2 AS CHAR FORMAT "x(40)"                NO-UNDO.

DEF  VAR aux_vltotrpp    AS DECI                               NO-UNDO.


PROCEDURE consulta-conta:
    /* SE FOR INCLUSO NOVO PARAMETRO, 
    O PROGRAMA programa tempo_execucao_caixaonline.p DEVE SER AJUSTADO! */
    DEF INPUT  PARAM p-cooper        AS CHAR NO-UNDO. 
    DEF INPUT  PARAM p-cod-agencia   AS INTE NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa     AS INTE NO-UNDO.
    DEF INPUT  PARAM p-nro-conta     AS INTE NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR  tt-conta.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
     
    ASSIGN p-nro-conta = int(REPLACE(string(p-nro-conta),".","")).
   
    DEF var aux_contador   as INTE                          NO-UNDO.
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
    
    DEF VAR aux_cdempres   AS INT                           NO-UNDO.
    DEF VAR aux_cdorgexp   AS CHAR                          NO-UNDO.

    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    EMPTY TEMP-TABLE tt-conta.
   
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.

    FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND 
                       crapass.nrdconta = p-nro-conta       NO-LOCK NO-ERROR.
                       
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
 
    CREATE tt-conta.
    ASSIGN tt-conta.nome-tit     = crapass.nmprimtl
           tt-conta.magnetico    = 0.

    FOR EACH crapcrm WHERE crapcrm.cdcooper = crapcop.cdcooper  AND
                           crapcrm.nrdconta = crapass.nrdconta  NO-LOCK:
                           
        IF  crapcrm.cdsitcar = 2                   AND
            crapcrm.dtvalcar >= crapdat.dtmvtolt   THEN
            tt-conta.magnetico = tt-conta.magnetico + 1.
    END.
    
    ASSIGN tt-conta.devolucoes = 0.
    FOR EACH crapneg WHERE crapneg.cdcooper = crapcop.cdcooper      AND
                           crapneg.nrdconta = crapass.nrdconta      AND
                           crapneg.cdhisest = 1                     AND
                    CAN-DO("11,12,13",STRING(crapneg.cdobserv))     
                           USE-INDEX crapneg1 NO-LOCK:
                    
        tt-conta.devolucoes = tt-conta.devolucoes + 1.
    END.
    
    ASSIGN tt-conta.agencia =  " ".
    FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper  AND
                       crapage.cdagenci = crapass.cdagenci  NO-LOCK NO-ERROR.
                       
    IF  AVAIL crapage THEN
        ASSIGN tt-conta.agencia = STRING(crapass.cdagenci,"999") + "-" +
                                  crapage.nmresage.
    ELSE
        ASSIGN tt-conta.agencia = STRING(crapass.cdagenci,"999").
                                       
    ASSIGN tt-conta.empresa = ""
               aux_cdempres = 0.
    
    IF  crapass.inpessoa = 1   THEN 
        DO:
            FOR FIRST crapttl FIELDS(crapttl.cdempres)
			                   WHERE crapttl.cdcooper = crapcop.cdcooper   AND
                               crapttl.nrdconta = crapass.nrdconta   AND
                                     crapttl.idseqttl = 1 
									 NO-LOCK:

                 ASSIGN aux_cdempres = crapttl.cdempres.

        END.

			FOR FIRST crapttl FIELDS(crapttl.nmextttl)
			                   WHERE crapttl.cdcooper = crapcop.cdcooper   AND
                                     crapttl.nrdconta = crapass.nrdconta   AND
                                     crapttl.idseqttl = 2
							         NO-LOCK:

                 ASSIGN tt-conta.nome-seg-tit = crapttl.nmextttl.
		    END.

        END.
    ELSE
        DO:
            FIND crapjur WHERE crapjur.cdcooper = crapcop.cdcooper  AND
                               crapjur.nrdconta = crapass.nrdconta
                               NO-LOCK NO-ERROR.

            IF   AVAIL crapjur  THEN
                 ASSIGN aux_cdempres = crapjur.cdempres.
        END.
    
    FIND crapemp WHERE crapemp.cdcooper = crapcop.cdcooper  AND
                       crapemp.cdempres = aux_cdempres  NO-LOCK NO-ERROR.
                       
    IF  AVAIL crapemp THEN
        ASSIGN tt-conta.empresa = STRING(aux_cdempres,"99999") + "-" + 
                                  crapemp.nmresemp.
    ELSE
        DO:
            ASSIGN i-cod-erro  = 40    /* Empresa nao cadastrada */ 
                   c-desc-erro = " ".
                            
            RUN cria-erro (INPUT p-cooper,
                           INPUT p-cod-agencia,
                           INPUT p-nro-caixa,
                           INPUT i-cod-erro,
                           INPUT c-desc-erro,
                           INPUT YES).
                           
            RETURN "NOK".                  
        END.
        
    ASSIGN tt-conta.tipo-conta = "".

    IF  crapass.cdtipcta > 0   THEN 
        DO:
            /* FIND craptip OF crapass NO-LOCK NO-ERROR. */
            FIND craptip WHERE craptip.cdcooper = crapcop.cdcooper  AND
                               craptip.cdtipcta = crapass.cdtipcta 
                               NO-LOCK NO-ERROR.
            
            IF  AVAIL craptip   THEN
                DO:
                    ASSIGN tt-conta.tipo-conta = 
                           STRING(crapass.cdtipcta,"z9") + 
                           " - " + craptip.dstipcta.

                   IF  crapass.cdtipcta = 8  THEN
                       DO:
                           IF  crapass.cdbcochq = 756 THEN
                               DO:
                                   ASSIGN tt-conta.tipo-conta = 
                                          STRING(crapass.cdtipcta,"z9") + 
                                          " - Normal Conv-BCB".
                               END.
                           ELSE
                               DO: 
                                   ASSIGN tt-conta.tipo-conta = 
                                          STRING(crapass.cdtipcta,"z9") + 
                                          " - Normal Conv-CTR".
                               END.
                       END.
                   ELSE
                   IF  crapass.cdtipcta = 9  THEN
                       DO:
                           IF  crapass.cdbcochq = 756 THEN
                               DO:
                                   ASSIGN tt-conta.tipo-conta = 
                                          STRING(crapass.cdtipcta,"z9") + 
                                          " - Espec. Conv-BCB".
                               END.
                           ELSE
                               DO: 
                                   ASSIGN tt-conta.tipo-conta = 
                                          STRING(crapass.cdtipcta,"z9") + 
                                          " - Espec. Conv-CTR".
                               END.
                       END.
                   ELSE
                   IF  crapass.cdtipcta = 10  THEN
                       DO:
                           IF  crapass.cdbcochq = 756 THEN
                               DO:
                                   ASSIGN tt-conta.tipo-conta = 
                                          STRING(crapass.cdtipcta,"z9") + 
                                          " - Cj. Conv-BCB".
                               END.
                           ELSE
                               DO: 
                                   ASSIGN tt-conta.tipo-conta = 
                                          STRING(crapass.cdtipcta,"z9") + 
                                          " - Cj. Conv-CTR".
                               END.
                       END.
                   ELSE
                   IF  crapass.cdtipcta = 11  THEN
                       DO:
                           IF  crapass.cdbcochq = 756 THEN
                               DO:
                                   ASSIGN tt-conta.tipo-conta = 
                                          STRING(crapass.cdtipcta,"z9") + 
                                          " - Cj.Esp.Conv-BCB".
                               END.
                           ELSE
                               DO: 
                                   ASSIGN tt-conta.tipo-conta = 
                                          STRING(crapass.cdtipcta,"z9") + 
                                          " - Cj.Esp.Conv-CTR".
                               END.
                       END.
                   ELSE
                       ASSIGN tt-conta.tipo-conta = 
                              STRING(crapass.cdtipcta,"z9") + " - " +
                              craptip.dstipcta.

                END.

            ELSE
                ASSIGN tt-conta.tipo-conta = STRING(crapass.cdtipcta,"z9").
        END.
    ELSE
        ASSIGN tt-conta.tipo-conta = STRING(crapass.cdtipcta,"z9").

    ASSIGN tt-conta.situacao = STRING(crapass.cdsitdct,"9") + " " +
                               IF crapass.cdsitdct = 1 THEN
                                  "NORMAL"
                               ELSE IF crapass.cdsitdct = 2 THEN
                                       "ENCERRADA P/ASSOCIADO"
                                    ELSE IF crapass.cdsitdct = 3 THEN
                                            "ENCERRADA P/COOP"
                                         ELSE IF crapass.cdsitdct = 4 THEN
                                                 "ENCERRADA P/DEMISSAO"
                                              ELSE IF crapass.cdsitdct = 5 THEN
                                                      "NAO APROVADA"
                                                   ELSE 
                                                   IF crapass.cdsitdct = 6 THEN                                                       "NORMAL - SEM TALAO"
                                                   ELSE
                                                      IF crapass.cdsitdct = 9
                                                         THEN 
                                                      "ENCERRADA P/OUTRO MOTIVO"
                                                      ELSE "".

    ASSIGN tt-conta.estouros = 0.

    FIND crapsld WHERE crapsld.cdcooper = crapcop.cdcooper  AND
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

    ASSIGN tt-conta.estouros = crapsld.qtddtdev
           tt-conta.folhas = 0.
           
    FOR EACH crapfdc WHERE crapfdc.cdcooper  = crapcop.cdcooper     AND
                           crapfdc.nrdconta  = crapass.nrdconta     AND
                           crapfdc.dtemschq <> ?                    AND
                           crapfdc.tpcheque  = 1                    NO-LOCK:
                           
        IF  crapfdc.dtretchq <> ? THEN
            IF  CAN-DO("0,1,2",STRING(crapfdc.incheque)) THEN
                ASSIGN tt-conta.folhas = tt-conta.folhas + 1.

    END.   /*  FOR EACH */
    
    
    /* Retornar orgao expedidor */
    IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
        RUN sistema/generico/procedures/b1wgen0052b.p 
            PERSISTENT SET h-b1wgen0052b.

    ASSIGN aux_cdorgexp = "".
    RUN busca_org_expedidor IN h-b1wgen0052b 
                       ( INPUT crapass.idorgexp,
                        OUTPUT aux_cdorgexp,
                        OUTPUT i-cod-erro, 
                        OUTPUT c-desc-erro).

    DELETE PROCEDURE h-b1wgen0052b.   
    
    IF c-desc-erro <> "" THEN
    DO:       
        RUN cria-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa,
                       INPUT i-cod-erro,
                       INPUT c-desc-erro,
                       INPUT YES).
        LEAVE.
    END.        
    
    ASSIGN tt-conta.identidade = crapass.nrdocptl
           tt-conta.orgao      = STRING(aux_cdorgexp) + " - " + 
                                 STRING(crapass.dtemdptl,"99/99/9999").

    IF  crapass.inpessoa = 1 THEN
        ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                aux_nrcpfcgc = STRING(aux_nrcpfcgc,"999.999.999-99").
    ELSE
        ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
               aux_nrcpfcgc = STRING(aux_nrcpfcgc,"99.999.999/999-99").
   
    ASSIGN tt-conta.cpfcgc          = aux_nrcpfcgc
           tt-conta.disponivel      = crapsld.vlsddisp
           tt-conta.bloqueado       = crapsld.vlsdbloq
           tt-conta.bloq-praca      = crapsld.vlsdblpr
           tt-conta.bloq-fora-praca = crapsld.vlsdblfp
           tt-conta.cheque-salario  = crapsld.vlsdchsl
           tt-conta.limite-credito  = crapass.vllimcre 
           tt-conta.ult-atualizacao = crapass.dtultlcr.

    /*** Retorna valores das Cotas Capital ***/
    FIND crapcot WHERE  crapcot.cdcooper = crapcop.cdcooper AND
                        crapcot.nrdconta = crapass.nrdconta NO-LOCK NO-ERROR.
                                   
    ASSIGN tt-conta.capital = crapcot.vldcotas.
    
    /* Verifica Lancamentos */
    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND
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
                               INT(SUBSTRING(craptab.dstextab,18,4)))
           tab_txcpmfcc = IF  crapdat.dtmvtolt >= tab_dtinipmf  AND
                              crapdat.dtmvtolt <= tab_dtfimpmf  THEN
                              DECIMAL(SUBSTR(craptab.dstextab,23,13))
                          ELSE
                              0
           tab_txrdcpmf = IF  crapdat.dtmvtolt >= tab_dtinipmf  AND
                              crapdat.dtmvtolt <= tab_dtfimpmf  THEN
                              DECIMAL(SUBSTR(craptab.dstextab,38,13))
                          ELSE 
                              1.

    FOR EACH craplcm WHERE craplcm.cdcooper  = crapcop.cdcooper     AND
                           craplcm.nrdconta  = crapsld.nrdconta     AND
                           craplcm.dtmvtolt  = crapdat.dtmvtolt     AND
                           craplcm.cdhistor <> 289                  
                           USE-INDEX craplcm2 NO-LOCK:

        FIND craphis WHERE craphis.cdcooper = craplcm.cdcooper   AND
                           craphis.cdhistor = craplcm.cdhistor
                           NO-LOCK NO-ERROR.

        IF  NOT AVAIL craphis   THEN 
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
            tt-conta.disponivel = tt-conta.disponivel + craplcm.vllanmto.
        ELSE
        IF  craphis.inhistor = 2   THEN
            tt-conta.cheque-salario = tt-conta.cheque-salario + 
                                       craplcm.vllanmto.
        ELSE
        IF  craphis.inhistor = 3   THEN
            tt-conta.bloqueado = tt-conta.bloqueado + craplcm.vllanmto.
        ELSE
        IF  craphis.inhistor = 4   THEN
            tt-conta.bloq-praca = tt-conta.bloq-praca + craplcm.vllanmto.
        ELSE
        IF  craphis.inhistor = 5   THEN
            tt-conta.bloq-fora-praca = tt-conta.bloq-fora-praca + 
                                       craplcm.vllanmto.
        ELSE
        IF  craphis.inhistor = 11   THEN
            tt-conta.disponivel = tt-conta.disponivel - craplcm.vllanmto.
        ELSE
        IF  craphis.inhistor = 12   THEN
            tt-conta.cheque-salario = tt-conta.cheque-salario - 
                                      craplcm.vllanmto.
        ELSE
        IF  craphis.inhistor = 13   THEN
            tt-conta.bloqueado = tt-conta.bloqueado - craplcm.vllanmto.
        ELSE
        IF  craphis.inhistor = 14   THEN
            tt-conta.bloq-praca = tt-conta.bloq-praca - craplcm.vllanmto.
        ELSE
        IF  craphis.inhistor = 15   THEN
            tt-conta.bloq-fora-praca = tt-conta.bloq-fora-praca - 
                                       craplcm.vllanmto.
        ELSE
            DO:
                ASSIGN i-cod-erro  = 83
                       c-desc-erro = " ".
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                LEAVE.
            END.

        /*  Calcula CPMF para os lancamentos  */
        IF  aux_indoipmf > 1   THEN
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
        ELSE
            IF  craphis.inhistor = 12   THEN 
                DO:
                    FIND crapfdc WHERE 
                         crapfdc.cdcooper = crapcop.cdcooper   AND
                         crapfdc.nrdconta = craplcm.nrdconta   AND
                         crapfdc.nrcheque = 
                               INTE(SUBSTR(
                                    STRING(craplcm.nrdocmto,"99999999"),1,7))
                         USE-INDEX crapfdc2 NO-LOCK NO-ERROR.
                                 
                    IF  NOT AVAIL crapfdc   THEN
                        DO:
                            IF  craplcm.nrdctabb = 978809   THEN
                                DO:
                                    ASSIGN i-cod-erro  = 286
                                           c-desc-erro = " ".
                                    RUN cria-erro (INPUT p-cooper,
                                                   INPUT p-cod-agencia,
                                                   INPUT p-nro-caixa,
                                                   INPUT i-cod-erro,
                                                   INPUT c-desc-erro,
                                                   INPUT YES).
                                    LEAVE.
                                END.
                            ELSE
                                IF  craplcm.cdhistor <> 43   THEN
                                    ASSIGN tt-conta.cheque-salario = 
                                                tt-conta.cheque-salario -
                                                (TRUNCATE(craplcm.vllanmto *
                                                          tab_txcpmfcc,2))
                                           tt-conta.disponivel = 
                                                tt-conta.disponivel +
                                                (TRUNCATE(craplcm.vllanmto * 
                                                          tab_txcpmfcc,2))
                                           aux_vlipmfap = aux_vlipmfap +
                                                (TRUNCATE(craplcm.vllanmto * 
                                                          tab_txcpmfcc,2)).
                        END.
                    ELSE     /*o campo vldoipmf nao foi alterado*/
                        ASSIGN tt-conta.cheque-salario =
                                        tt-conta.cheque-salario - 
                                        crapfdc.vldoipmf
                               tt-conta.disponivel = tt-conta.disponivel +
                                                     crapfdc.vldoipmf
                               aux_vlipmfap = aux_vlipmfap + crapfdc.vldoipmf.
                END.

        IF  CAN-DO("186,187",STRING(craplcm.cdhistor))   THEN
            ASSIGN aux_vlestorn = TRUNCATE(craplcm.vllanmto * tab_txcpmfcc,2) 
                   aux_vlipmfap = aux_vlipmfap + aux_vlestorn + 
                                  TRUNCATE(aux_vlestorn * tab_txcpmfcc,2)
                   aux_vlestabo = aux_vlestabo + craplcm.vllanmto.

    END.  /* for each  */

    RUN verifica-erro (INPUT p-cooper,
                       INPUT p-cod-agencia,
                       INPUT p-nro-caixa).
    IF  RETURN-VALUE = "NOK"   THEN
        RETURN "NOK".
        
    ASSIGN aux_vlestabo          = TRUNCATE(aux_vlestabo * tab_txiofapl,2)
           tt-conta.saldo-total  = tt-conta.disponivel + tt-conta.bloqueado +
                                   tt-conta.bloq-praca +
                                   tt-conta.bloq-fora-praca + 
                                   tt-conta.cheque-salario
           tt-conta.acerto-conta = tt-conta.disponivel - crapsld.vlipmfap -
                                    crapsld.vlipmfpg - aux_vlipmfap - 
                                    aux_vlestabo
            tt-conta.db-cpmf      = crapsld.vlipmfpg
            tt-conta.saque-maximo = IF tt-conta.acerto-conta <= 0
                                    THEN 0
                                    ELSE TRUNC(tt-conta.acerto-conta * 
                                               tab_txrdcpmf,2)
            tt-conta.acerto-conta = tt-conta.acerto-conta + tt-conta.bloqueado +
                                    tt-conta.bloq-praca +
                                    tt-conta.bloq-fora-praca
            tt-conta.acerto-conta = IF tt-conta.acerto-conta < 0
                                    THEN TRUNC(tt-conta.acerto-conta * (1 + 
                                               tab_txcpmfcc),2)
                                    ELSE tt-conta.acerto-conta.
        
     RETURN "OK".

END PROCEDURE.


FUNCTION centraliza RETURNS CHARACTER ( INPUT par_frase AS CHARACTER, INPUT par_tamlinha AS INTEGER ):

    DEF VAR vr_contastr AS INTEGER NO-UNDO.
    
    ASSIGN vr_contastr = TRUNC( (par_tamlinha - LENGTH(TRIM(par_frase))) / 2 ,0).

    RETURN FILL(' ',vr_contastr) + TRIM(par_frase).
END.


PROCEDURE impressao-saldo:
    DEF INPUT  PARAM p-cooper            AS CHAR                      NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia       AS INTE                      NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa         AS INTE                      NO-UNDO.
    DEF INPUT  PARAM p-cod-operador      AS CHAR                      NO-UNDO.
    DEF INPUT  PARAM p-nro-conta         AS INTE                      NO-UNDO.
    DEF INPUT  PARAM p-valor-disponivel  AS DEC                       NO-UNDO.
    DEF INPUT  PARAM p-valor-emprestimo  AS DEC                       NO-UNDO.
    DEF INPUT  PARAM p-valor-praca       AS DEC                       NO-UNDO.
    DEF INPUT  PARAM p-valor-fora-praca  AS DEC                       NO-UNDO.
    DEF INPUT  PARAM p-limite-credito    AS DEC                       NO-UNDO.
    DEF INPUT  PARAM p-valor-aplicacao   AS DEC                       NO-UNDO.
    DEF INPUT  PARAM p-valor-poupanca    AS DEC                       NO-UNDO.
    /* 1 - Saldo aplicação,  2 - Saldo conta corrente*/ 
    DEF INPUT  PARAM p-tipo-impressao    AS INT                       NO-UNDO.
    DEF OUTPUT PARAM p-literal-autentica AS CHAR                      NO-UNDO.
                 
    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
 
    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                       NO-LOCK NO-ERROR.

    ASSIGN c-nome-titular1 = " "
           c-nome-titular2 = " ".
           

    /*** Busca Saldo Bloqueado Judicial ***/
    IF  NOT VALID-HANDLE(h-b1wgen0155) THEN
        RUN sistema/generico/procedures/b1wgen0155.p 
            PERSISTENT SET h-b1wgen0155.

    /*** APLICACAO/POUPANCA PROGRAMADA ***/
    IF  p-tipo-impressao = 1 THEN
        DO:
            ASSIGN aux_vlblqjud = 0
                   aux_vlblqpop = 0
                   aux_vlresblq = 0
                   aux_vlrespop = 0.
            
            RUN retorna-valor-blqjud IN h-b1wgen0155(INPUT crapcop.cdcooper,
                                                     INPUT p-nro-conta,
                                                     INPUT 0, 
                                                     INPUT 0, 
                                                     INPUT 2, /*2 - Aplicacao*/
                                                     INPUT crapdat.dtmvtolt,
                                                     OUTPUT aux_vlblqjud,
                                                     OUTPUT aux_vlresblq).
                   
            IF  RETURN-VALUE <> "OK" THEN
                RETURN "NOK".

             RUN retorna-valor-blqjud IN h-b1wgen0155(INPUT crapcop.cdcooper,
                                                     INPUT p-nro-conta,
                                                     INPUT 0, 
                                                     INPUT 0, 
                                                     INPUT 3, /*3- poup prog*/
                                                     INPUT crapdat.dtmvtolt,
                                                     OUTPUT aux_vlblqpop,
                                                     OUTPUT aux_vlrespop).
                   
            IF  RETURN-VALUE <> "OK" THEN
                RETURN "NOK".
        END.    
    ELSE
        DO:
            ASSIGN aux_vlblqjud = 0
                   aux_vlresblq = 0.
        
            RUN retorna-valor-blqjud IN h-b1wgen0155(INPUT crapcop.cdcooper,
                                                     INPUT p-nro-conta,
                                                     INPUT 0, 
                                                     INPUT 0, 
                                                     INPUT 1, /*1- Dep. Vista*/
                                                     INPUT crapdat.dtmvtolt,
                                                     OUTPUT aux_vlblqjud,
                                                     OUTPUT aux_vlresblq).
            
            IF  RETURN-VALUE <> "OK" THEN
                RETURN "NOK".

        END.

    IF  VALID-HANDLE(h-b1wgen0155) THEN
        DELETE PROCEDURE h-b1wgen0155.

    FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                       crapass.nrdconta = p-nro-conta       NO-LOCK NO-ERROR.
                       
    IF   AVAIL crapass   THEN
	   DO:
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
			 
          ASSIGN c-nome-titular1 = crapass.nmprimtl.

	   END.

    ASSIGN de-valor-total = p-valor-disponivel + p-valor-emprestimo + 
                            p-valor-praca      + p-valor-fora-praca + 
                            aux_vlblqjud
           c-literal[1]  = TRIM(crapcop.nmrescop) +  " - " + 
                           TRIM(crapcop.nmextcop) 
           c-literal[2]  = " "
           c-literal[3]  = STRING(crapdat.dtmvtolt,"99/99/99") + " " + 
                           STRING(TIME,"HH:MM:SS") +  " PAC " + 
                           STRING(p-cod-agencia,"999") + "  CAIXA: " + 
                           STRING(p-nro-caixa,"Z99") + "/" +
                           SUBSTR(p-cod-operador,1,10)        
           c-literal[4]  = " ".

    IF   p-tipo-impressao = 1  THEN
         c-literal[5]  = "      **    SALDO EM APLICACAO     **".
    ELSE
         c-literal[5]  = "      **  SALDO EM CONTA CORRENTE  **".

    ASSIGN c-literal[6]  = " " 
           c-literal[7]  = "CONTA...: " + TRIM(STRING(p-nro-conta,"zzzz,zz9,9"))
           c-literal[8]  = "          " + TRIM(c-nome-titular1) 
           c-literal[9]  = "          " + TRIM(c-nome-titular2)
           c-literal[10] = " ".

    IF   p-tipo-impressao = 1  THEN
         ASSIGN c-literal[11] = "SALDO APLICACAO P/RESGATE: " +
                                STRING(p-valor-aplicacao,"ZZZ,ZZZ,ZZZ,ZZ9.99-")
                c-literal[12] = IF  aux_vlblqjud > 0 THEN 
                                    "VALOR BLOQ. JUDICIALMENTE: " +
                                    STRING(aux_vlblqjud,"ZZZ,ZZZ,ZZZ,ZZ9.99-")
                                ELSE
                                    " "   
                c-literal[13] = " " 
                c-literal[14] = " "
                c-literal[15] = "SALDO POUPANCA PROGRAMADA: " +
                                STRING(p-valor-poupanca,"ZZZ,ZZZ,ZZZ,ZZ9.99-") 
                c-literal[16] = IF  aux_vlblqpop > 0 THEN 
                                    "VALOR BLOQ. JUDICIALMENTE: " +
                                    STRING(aux_vlblqpop,"ZZZ,ZZZ,ZZZ,ZZ9.99-")
                                ELSE
                                    " "
                c-literal[17] = " " 
                c-literal[18] = " "
                c-literal[19] = " "
                c-literal[20] = " ".
    ELSE
         ASSIGN c-literal[11] = "               DISPONIVEL: " + 
                                STRING(p-valor-disponivel,"ZZZ,ZZZ,ZZZ,ZZ9.99-")
                c-literal[12] = "    EMPRESTIMOS A LIBERAR: " +                            
                                STRING(p-valor-emprestimo,"ZZZ,ZZZ,ZZZ,ZZ9.99-")
                c-literal[13] = "      EM CHEQUES DA PRACA: " + 
                                STRING(p-valor-praca,"ZZZ,ZZZ,ZZZ,ZZ9.99-")
                c-literal[14] = " EM CHEQUES FORA DA PRACA: " + 
                                STRING(p-valor-fora-praca,"ZZZ,ZZZ,ZZZ,ZZ9.99-")
                c-literal[15] = IF  aux_vlblqjud > 0 THEN 
                                    "VALOR BLOQ. JUDICIALMENTE: " +
                                    STRING(aux_vlblqjud,"ZZZ,ZZZ,ZZZ,ZZ9.99-")
                                ELSE
                                    " "
                c-literal[16] = "                           " + "-------------------"
                c-literal[17] = "              SALDO TOTAL: " + 
                                STRING(de-valor-total,"ZZZ,ZZZ,ZZZ,ZZ9.99-")
                c-literal[18] = " " 
                c-literal[19] = "        LIMITE DE CREDITO: " + 
                                STRING(p-limite-credito,"ZZZ,ZZZ,ZZZ,ZZ9.99-")
                c-literal[20] = " ".

    ASSIGN c-literal[21] = " "               
           c-literal[22] = "                                                "
           c-literal[23] = centraliza("SAC - " + STRING(crapcop.nrtelsac),48)
           c-literal[24] = centraliza("Atendimento todos os dias das " + REPLACE(REPLACE(STRING(crapcop.hrinisac,"HH:MM"),':','h'),'h00','h') + " as " + REPLACE(REPLACE(STRING(crapcop.hrfimsac,"HH:MM"),':','h'),'h00','h'),48)
           c-literal[25] = centraliza("OUVIDORIA - " + STRING(crapcop.nrtelouv),48)
           c-literal[26] = centraliza("Atendimento nos dias uteis das " + REPLACE(REPLACE(STRING(crapcop.hriniouv,"HH:MM"),':','h'),'h00','h') + " as " + REPLACE(REPLACE(STRING(crapcop.hrfimouv,"HH:MM"),':','h'),'h00','h'),48)    
		   c-literal[27] = " "    
           c-literal[28] = " ".    
                 
    ASSIGN p-literal-autentica = string(c-literal[1],"x(48)")   + 
                                 string(c-literal[2],"x(48)")   + 
                                 string(c-literal[3],"x(48)")   + 
                                 string(c-literal[4],"x(48)")   + 
                                 string(c-literal[5],"x(48)")   + 
                                 string(c-literal[6],"x(48)")   + 
                                 string(c-literal[7],"x(48)")   + 
                                 string(c-literal[8],"x(48)")   + 
                                 string(c-literal[9],"x(48)")   + 
                                 string(c-literal[10],"x(48)")  + 
                                 string(c-literal[11],"x(48)")  + 
                                 string(c-literal[12],"x(48)")  +
                                 string(c-literal[13],"x(48)")  + 
                                 string(c-literal[14],"x(48)")  + 
                                 string(c-literal[15],"x(48)")  + 
                                 string(c-literal[16],"x(48)")  + 
                                 string(c-literal[17],"x(48)")  +
                                 string(c-literal[18],"x(48)")  +
                                 string(c-literal[19],"x(48)")  + 
                                 string(c-literal[20],"x(48)")  + 
                                 string(c-literal[21],"x(48)")  +
                                 string(c-literal[22],"x(48)")  +
                                 string(c-literal[23],"x(48)")  +
                                 string(c-literal[24],"x(48)")  +
                                 string(c-literal[25],"x(48)")  + 
                                 string(c-literal[26],"x(48)")  + 
                                 string(c-literal[27],"x(48)")  +
                                 string(c-literal[28],"x(48)")  +
								 fill(' ',384).
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE retornaMsgTransferencia:
    /* SE FOR INCLUSO NOVO PARAMETRO, 
    O PROGRAMA programa tempo_execucao_caixaonline.p DEVE SER AJUSTADO! */
    DEFINE INPUT  PARAMETER p-cooper        AS CHAR         NO-UNDO.
    DEFINE INPUT  PARAMETER p-cod-agencia   AS INTEGER      NO-UNDO.
    DEFINE INPUT  PARAMETER p-nro-caixa     AS INTEGER      NO-UNDO.
    DEFINE INPUT  PARAMETER p-nro-conta     AS INTEGER      NO-UNDO.
    DEFINE OUTPUT PARAMETER cMsgTransfCta   AS CHARACTER    NO-UNDO INITIAL ''.

    DEFINE VARIABLE aux_nrdconta    LIKE craptrf.nrsconta   NO-UNDO.

    RUN retornaCtaTransferencia IN THIS-PROCEDURE (INPUT p-cooper,
                                                   INPUT p-cod-agencia, 
                                                   INPUT p-nro-caixa,
                                                   INPUT p-nro-conta,
                                                   OUTPUT aux_nrdconta).
    IF   RETURN-VALUE = 'NOK'   THEN
         RETURN 'NOK'.

    IF   aux_nrdconta <> 0   THEN
         ASSIGN cMsgTransfCta = 'Conta transferida do numero ' +
                                 TRIM(STRING(p-nro-conta, 'ZZZZ,ZZZ,9')) +
                                ' para o numero ' +
                                 TRIM(STRING(aux_nrdconta, 'ZZZZ,ZZZ,9')).

    RETURN 'OK':U.
END PROCEDURE.

PROCEDURE retornaCtaTransferencia:
/*metodo retorna a conta transferencia somente se a conta foi transferida caso
contrario retorna 0*/
    DEFINE INPUT  PARAMETER p-cooper        AS CHAR         NO-UNDO.
    DEFINE INPUT  PARAMETER p-cod-agencia   AS INTEGER      NO-UNDO.
    DEFINE INPUT  PARAMETER p-nro-caixa     AS INTEGER      NO-UNDO.
    DEFINE INPUT  PARAMETER p-nro-conta     AS INTEGER      NO-UNDO.
    DEFINE OUTPUT PARAMETER p-nro-cta-trans AS INTEGER      NO-UNDO INITIAL 0.

    DEFINE VARIABLE aux_nrdconta    LIKE craptrf.nrsconta   NO-UNDO.

    ASSIGN aux_nrdconta = p-nro-conta.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    /*bloco repete ate encontrar a ultima conta a ter sofrido transferencia*/
    DO WHILE TRUE:

        FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                           crapass.nrdconta = aux_nrdconta  
                           NO-LOCK NO-ERROR.
                           
        IF  NOT AVAILABLE crapass  THEN 
            DO:
                ASSIGN i-cod-erro  = 9   
                       c-desc-erro = ''.
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT  YES).
                RETURN 'NOK'.
            END.

        IF  crapass.dtelimin <> ?   THEN
            DO:
                ASSIGN i-cod-erro  = 410
                       c-desc-erro = ''.
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,
                               INPUT p-nro-caixa,
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT YES).
                RETURN 'NOK'.
            END.

        IF  CAN-DO('2,4,6,8', STRING(crapass.cdsitdtl))   THEN 
            DO:

                FIND FIRST craptrf WHERE 
                           craptrf.cdcooper = crapcop.cdcooper     AND
                           craptrf.nrdconta = crapass.nrdconta     AND
                           craptrf.tptransa = 1
                           USE-INDEX craptrf1 NO-LOCK NO-ERROR.

                IF   NOT AVAILABLE craptrf   THEN 
                     DO:
                         ASSIGN i-cod-erro  = 95 /* Titular Conta Bloqueado */
                                c-desc-erro = ''.
                         RUN cria-erro (INPUT p-cooper,
                                        INPUT p-cod-agencia,
                                        INPUT p-nro-caixa,
                                        INPUT i-cod-erro,
                                        INPUT c-desc-erro,
                                        INPUT YES).
                         RETURN 'NOK'.
                     END.

                ASSIGN aux_nrdconta = craptrf.nrsconta.

            END.
        ELSE
            LEAVE.

    END. /* do while */

    IF   aux_nrdconta <> p-nro-conta   THEN
         ASSIGN p-nro-cta-trans = aux_nrdconta.
             
    RETURN 'OK'.
END PROCEDURE.

PROCEDURE verifica_anota:
    /* SE FOR INCLUSO NOVO PARAMETRO, 
    O PROGRAMA programa tempo_execucao_caixaonline.p DEVE SER AJUSTADO! */
    DEFINE INPUT  PARAMETER p-cooper        AS CHAR                    NO-UNDO.
    DEFINE INPUT  PARAMETER p-cod-agencia   AS INTEGER                 NO-UNDO.
    DEFINE INPUT  PARAMETER p-nro-caixa     AS INTEGER                 NO-UNDO.
    DEFINE INPUT  PARAMETER p-nro-conta     AS INTEGER                 NO-UNDO.
 
    RUN elimina-erro (INPUT p-cooper,
                      INPUT p-cod-agencia,
                      INPUT p-nro-caixa).

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.
 
    FOR EACH crapobs WHERE crapobs.cdcooper = crapcop.cdcooper  AND
                           crapobs.nrdconta = p-nro-conta       NO-LOCK:
                           
        IF  crapobs.dsobserv <> " "   THEN
            DO:
                ASSIGN i-cod-erro  = 0
                       c-desc-erro = crapobs.dsobserv.
                RUN cria-erro (INPUT p-cooper,
                               INPUT p-cod-agencia,  
                               INPUT p-nro-caixa,  
                               INPUT i-cod-erro,
                               INPUT c-desc-erro,
                               INPUT NO).
            END.
    END.

    RETURN "OK".        
END PROCEDURE.


PROCEDURE calcula_aplicacoes:
/* SE FOR INCLUSO NOVO PARAMETRO, 
O PROGRAMA programa tempo_execucao_caixaonline.p DEVE SER AJUSTADO! */
             
{ includes/var_rdca2.i }
                
DEF INPUT  PARAM p-cooper      AS CHAR NO-UNDO.
DEF INPUT  PARAM p-cod-agencia AS INTE NO-UNDO.
DEF INPUT  PARAM p-nro-caixa   AS INTE NO-UNDO.
DEF OUTPUT PARAM aux_vltotrda  AS DECI NO-UNDO. 
DEF OUTPUT PARAM TABLE  FOR    craterr.

DEF VAR h-b1wgen0081 AS HANDLE NO-UNDO.

DEF VAR aux_cdcritic LIKE crapcri.cdcritic NO-UNDO.
DEF VAR aux_dscritic LIKE crapcri.dscritic NO-UNDO.

DEF VAR aux_vlsldtot AS DECI NO-UNDO.
DEF VAR aux_vlsldrgt AS DECI NO-UNDO.
DEF VAR aux_vlsldapl AS DECI NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    ASSIGN aux_vltotrda = 0.

    /** Saldo das aplicacoes **/
    RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT
        SET h-b1wgen0081.        
   
    IF  VALID-HANDLE(h-b1wgen0081)  THEN
        DO:
            
            RUN obtem-dados-aplicacoes IN h-b1wgen0081
                                      (INPUT crapcop.cdcooper,
                                       INPUT p-cod-agencia,
                                       INPUT p-nro-caixa,
                                       INPUT 1,
                                       INPUT "CRAP002",
                                       INPUT 1,
                                       INPUT crapass.nrdconta,
                                       INPUT 1,
                                       INPUT 0,
                                       INPUT "CRAP002",
                                       INPUT FALSE,
                                       INPUT ?,
                                       INPUT ?,
                                       OUTPUT aux_vlsldtot,
                                       OUTPUT TABLE tt-saldo-rdca,
                                       OUTPUT TABLE craterr).
        
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    DELETE PROCEDURE h-b1wgen0081.
                    
                    FIND FIRST craterr NO-LOCK NO-ERROR.
                 
                    IF  AVAILABLE craterr  THEN
                        ASSIGN aux_cdcritic = craterr.cdcritic
                               aux_dscritic = craterr.dscritic.
                
                    RUN proc_gerar_log (INPUT crapcop.cdcooper,
                                        INPUT 1,
                                        INPUT aux_dscritic,
                                        INPUT "CRAP002",
                                        INPUT "Consulta de Saldo de Aplicacao",
                                        INPUT FALSE,
                                        INPUT 1,
                                        INPUT "CRAP002",
                                        INPUT crapass.nrdconta,
                                       OUTPUT aux_nrdrowid).
        
                    RETURN "NOK".
                END.

            ASSIGN aux_vlsldapl = aux_vlsldtot.

            DELETE PROCEDURE h-b1wgen0081.
        END.
     
     ASSIGN aux_vlsldtot = 0
            aux_vlsldrgt = 0.

     /*Busca Saldo Novas Aplicacoes*/
     { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

      RUN STORED-PROCEDURE pc_busca_saldo_aplicacoes
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT crapcop.cdcooper, /* Código da Cooperativa */
                                 INPUT "1",              /* Código do Operador */
                                 INPUT "CRAP002",        /* Nome da Tela */
                                 INPUT 2,                /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                 INPUT crapass.nrdconta, /* Número da Conta */
                                 INPUT 1,                /* Titular da Conta */
                                 INPUT 0,                /* Número da Aplicação / Parâmetro Opcional */
                                 INPUT crapdat.dtmvtolt, /* Data de Movimento */
                                 INPUT 0,                /* Código do Produto */
                                 INPUT 1,            /* Identificador de Bloqueio de Resgate (1 – Todas / 2 – Bloqueadas / 3 – Desbloqueadas) */
                                 INPUT 0,            /* Identificador de Log (0 – Não / 1 – Sim) */
                                OUTPUT 0,            /* Saldo Total da Aplicação */
                                OUTPUT 0,            /* Saldo Total para Resgate */
                                OUTPUT 0,            /* Código da crítica */
                                OUTPUT "").          /* Descrição da crítica */
      
      CLOSE STORED-PROC pc_busca_saldo_aplicacoes
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
      
      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
      
      ASSIGN aux_cdcritic = 0
             aux_dscritic = ""
             aux_vlsldtot = 0
             aux_vlsldrgt = 0
             aux_cdcritic = pc_busca_saldo_aplicacoes.pr_cdcritic 
                             WHEN pc_busca_saldo_aplicacoes.pr_cdcritic <> ?
             aux_dscritic = pc_busca_saldo_aplicacoes.pr_dscritic
                             WHEN pc_busca_saldo_aplicacoes.pr_dscritic <> ?
             aux_vlsldtot = pc_busca_saldo_aplicacoes.pr_vlsldtot
                             WHEN pc_busca_saldo_aplicacoes.pr_vlsldtot <> ?
             aux_vlsldrgt = pc_busca_saldo_aplicacoes.pr_vlsldrgt
                             WHEN pc_busca_saldo_aplicacoes.pr_vlsldrgt <> ?.
      
      IF aux_cdcritic <> 0   OR
         aux_dscritic <> ""  THEN
         DO:
             IF aux_dscritic = "" THEN
                DO:
                   FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                      NO-LOCK NO-ERROR.
    
                   IF AVAIL crapcri THEN
                      ASSIGN aux_dscritic = crapcri.dscritic.
    
                END.
    
             CREATE craterr.
    
             ASSIGN craterr.cdcritic = aux_cdcritic
                    craterr.dscritic = aux_dscritic.
      
             RETURN "NOK".
                            
         END.
     ASSIGN aux_vltotrda = aux_vlsldapl + aux_vlsldrgt.
     /*Fim Busca Saldo Novas Aplicacoes*/

END PROCEDURE.


PROCEDURE critica_aplicacao:

  DEFINE INPUT  PARAMETER p-cooper        AS CHAR                     NO-UNDO.
  DEFINE INPUT  PARAMETER p-cod-agencia   AS INTEGER                  NO-UNDO.
  DEFINE INPUT  PARAMETER p-nro-caixa     AS INTEGER                  NO-UNDO.
  DEFINE INPUT  PARAMETER p-nro-conta     AS INTEGER                  NO-UNDO.
  DEFINE INPUT  PARAMETER TABLE           FOR craterr.
                    
  
  FOR EACH craterr :
  
      RUN cria-erro (INPUT p-cooper,
                     INPUT p-cod-agencia,
                     INPUT p-nro-caixa,
                     INPUT craterr.cdcritic,
                     INPUT "",
                     INPUT YES).
  END.

  RETURN "OK".

END PROCEDURE.
                              

PROCEDURE calcula_poupanca:
    /* SE FOR INCLUSO NOVO PARAMETRO, 
    O PROGRAMA programa tempo_execucao_caixaonline.p DEVE SER AJUSTADO! */
    DEFINE  INPUT   PARAM p-cooper      AS CHAR                       NO-UNDO.
    DEFINE  OUTPUT  PARAM aux_vltotrpp  AS DECI                       NO-UNDO.
                  
    DEFINE  VAR     p-cdcooper          AS INTE                       NO-UNDO.

    DEFINE  VAR     rpp_vllan150        AS DECIMAL                    NO-UNDO.
    DEFINE  VAR     rpp_vllan158        AS DECIMAL                    NO-UNDO.
    
    DEFINE  VAR     rpp_dtcalcul        AS DATE  FORMAT "99/99/9999"  NO-UNDO.
    DEFINE  VAR     rpp_dtmvtolt        AS DATE  FORMAT "99/99/9999"  NO-UNDO.
    DEFINE  VAR     rpp_dtrefere        AS DATE  FORMAT "99/99/9999"  NO-UNDO.
    DEFINE  VAR     rpp_vlsdrdpp        AS DECIMAL DECIMALS 8         NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = p-cooper NO-LOCK NO-ERROR.

    ASSIGN aux_vltotrpp = 0
           p-cdcooper   = crapcop.cdcooper. 

    /*  Leitura da poupanca programada  */
         
    FOR EACH craprpp WHERE craprpp.cdcooper = p-cdcooper        AND
                           craprpp.nrdconta = crapass.nrdconta  NO-LOCK:
      
        ASSIGN rpp_vllan150 = 0
               rpp_vllan158 = 0
               rpp_vlsdrdpp = craprpp.vlsdrdpp
               rpp_dtcalcul = craprpp.dtiniper
               rpp_dtrefere = craprpp.dtfimper
               rpp_dtmvtolt = crapdat.dtmvtolt + 1. /*Calculo ate dia do mvto*/

        /*  Leitura dos lancamentos de resgate da aplicacao  */

        FOR EACH craplpp WHERE craplpp.cdcooper  = p-cdcooper         AND
                               craplpp.nrdconta  = craprpp.nrdconta   AND
                               craplpp.nrctrrpp  = craprpp.nrctrrpp   AND
                              (craplpp.dtmvtolt >= rpp_dtcalcul       AND
                               craplpp.dtmvtolt <= rpp_dtmvtolt)      AND
                               craplpp.dtrefere  = rpp_dtrefere       AND
                               CAN-DO("150,152,154,155,158,496",
                                       STRING(craplpp.cdhistor)) NO-LOCK:

            IF  craplpp.cdhistor = 150   THEN   /* Credito do plano */
                DO:
                    rpp_vllan150 = rpp_vllan150 + craplpp.vllanmto.
                    NEXT.
                END.
            ELSE     
            IF  craplpp.cdhistor = 158  OR
                craplpp.cdhistor = 496 THEN   /* Resgate */
                DO:
                    rpp_vllan158 = rpp_vllan158 + craplpp.vllanmto.
                    NEXT.
                END.

        END.  /* Fim do FOR EACH -- Leitura dos lancamentos da aplicacao  */

        rpp_vlsdrdpp = rpp_vlsdrdpp + rpp_vllan150 - rpp_vllan158.

        IF  rpp_vlsdrdpp < 0  THEN
            rpp_vlsdrdpp = 0.
     
        /*  Arredondamento dos valores calculados  */
        
        ASSIGN rpp_vlsdrdpp = ROUND(rpp_vlsdrdpp,2)
               aux_vltotrpp = aux_vltotrpp + rpp_vlsdrdpp.

    END.  

END PROCEDURE.

PROCEDURE valida_restricao_operador:

    DEF  INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nmrescop AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                             NO-UNDO.


    DEF  VAR aux_cdcritic AS INTE                                     NO-UNDO.
    DEF  VAR aux_dscritic AS CHAR                                     NO-UNDO.
    DEF VAR h-b1wgen9998 AS HANDLE                                    NO-UNDO.

    FIND crapcop WHERE crapcop.nmrescop = par_nmrescop NO-LOCK NO-ERROR.
 
    RUN elimina-erro (INPUT par_nmrescop,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa).

    IF  NOT VALID-HANDLE(h-b1wgen9998) THEN
        RUN sistema/generico/procedures/b1wgen9998.p
            PERSISTENT SET h-b1wgen9998.

    RUN valida_restricao_operador IN h-b1wgen9998
                                  (INPUT par_cdoperad,
                                   INPUT par_nrdconta,
                                   INPUT "",
                                   INPUT crapcop.cdcooper,
                                  OUTPUT aux_dscritic).
     
    IF  VALID-HANDLE(h-b1wgen9998) THEN
        DELETE OBJECT h-b1wgen9998.
     
    IF  RETURN-VALUE <> "OK" THEN
        DO:
            RUN cria-erro (INPUT par_nmrescop,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 0,
                           INPUT aux_dscritic,
                           INPUT YES).
             
            RETURN "NOK".
        END.

END PROCEDURE.

/* b1crap02.p */        
/* ......................................................................... */
