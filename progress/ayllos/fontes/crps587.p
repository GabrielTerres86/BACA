/*..............................................................................

    Programa: Fontes/crps587.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Guilherme/Supero
    Data    : Dezembro/2010                     Ultima atualizacao: 25/08/2015 
    
    Dados referentes ao programa:

    Frequencia: Diario (Batch).
    Objetivo  : COPIA DO CRPS264 - ESPECIFICO PARA TRANSFERENCIA DE PA
                DIFERENCA: NAO GERA ARQUIVO


    Alteracoes: 18/01/2011 - Incluido os e-mails:
                             - fabiano@viacredi.coop.br
                             - moraes@viacredi.coop.br
                             (Adriano).
                             
                27/05/2011 - Fixar o tprelato para 1 (Ze).
                
                03/06/2011 - Alterado destinatário do envio de email na procedure
                             gera_relatorio_203_99; 
                             De: thiago.delfes@viacredi.coop.br
                             Para: brusque@viacredi.coop.br. (Fabricio)
                            
                18/06/2012 - Alteracao na leitura da craptco (David Kruger).
                
                02/08/2012 - Ajuste do format no campo nmrescop (David Kruger). 
                
                22/03/2013 - Ajuste referente ao Projeto Tarifas Fase 2 - Grupo
                             de Cheque (Lucas R.)
                
                11/10/2013 - Incluido parametro cdprogra nas procedures da 
                             b1wgen0153 que carregam dados de tarifas (Tiago).
                             
                14/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO) 
                            
                25/08/2015 - Inclusao do parametro pr_cdpesqbb na procedure
                            tari0001.pc_cria_lan_auto_tarifa, projeto de 
                            Tarifas-218(Jean Michel)                   
							
			    26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).
								  

                12/06/2018 - P450 - Chamada da rotina para consistir lançamento em conta 
                             corrente(LANC0001) na tabela CRAPLCM  - José Carvalho(AMcom)
				      
..............................................................................*/

DEF INPUT  PARAM p-cddevolu AS INT        /* Sempre 4 */             NO-UNDO.
DEF INPUT  PARAM p-cdcooper AS INT        /* Sempre 1 - VIACREDI */  NO-UNDO.
DEF INPUT  PARAM p-cdcopant AS INT        /* Sempre 2 - TEXTIL  */   NO-UNDO.

{ includes/var_batch.i }   
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0200tt.i }

DEF STREAM str_1. /* Relatorios */
DEF STREAM str_2. /* Arquivos   */

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.
DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR res_nrdctabb AS INT                                   NO-UNDO.
DEF        VAR res_nrdocmto AS INT                                   NO-UNDO.
DEF        VAR res_cdhistor AS INT                                   NO-UNDO.

DEF        VAR tab_txdevchq AS DECIMAL                               NO-UNDO.

DEF        VAR aux_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT     INIT 100                      NO-UNDO.
DEF        VAR aux_nmdbanco AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.

/* variaveis para conta de integracao */
DEF        BUFFER crabass5 FOR crapass.
DEF        VAR aux_nrctaass AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR aux_ctpsqitg LIKE craplcm.nrdctabb                    NO-UNDO.
DEF        VAR aux_nrdctitg LIKE crapass.nrdctitg                    NO-UNDO.

DEF        VAR rel_nrcpfcgc AS CHAR                                  NO-UNDO.
DEF        VAR rel_nmrescop AS CHAR EXTENT 2                         NO-UNDO.
DEF        VAR aux_nmcidade AS CHAR                                  NO-UNDO.
DEF        VAR rel_qtchqdev AS INT                                   NO-UNDO.
DEF        VAR rel_vlchqdev AS DECI    FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF        VAR aux_qtpalavr AS INT                                   NO-UNDO.
DEF        VAR aux_contapal AS INT                                   NO-UNDO.
DEF        VAR aux_cdbanchq AS INT                                   NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqlog AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqdev AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrdigitg AS CHAR                                  NO-UNDO.
DEF        VAR aux_dtmovime AS CHAR                                  NO-UNDO.

DEF        VAR flg_devolbcb AS LOG                                   NO-UNDO.

DEF        VAR h-b1wgen0011 AS HANDLE                                NO-UNDO.
    
DEF        VAR h-b1wgen0153 AS HANDLE                                NO-UNDO.
DEF        VAR aux_cdhistor AS INTE                                  NO-UNDO.
DEF        VAR aux_cdhisest AS INTE                                  NO-UNDO.
DEF        VAR aux_dtdivulg AS DATE                                  NO-UNDO.
DEF        VAR aux_dtvigenc AS DATE                                  NO-UNDO.
DEF        VAR aux_cdtarifa AS CHAR                                  NO-UNDO.
DEF        VAR par_dscritic LIKE crapcri.dscritic                    NO-UNDO.
DEF        VAR aux_vltarifa  AS DECIMAL FORMAT "zz9.99"              NO-UNDO.
DEF        VAR aux_cdfvlcop AS INTE                                  NO-UNDO.

/*variaveis da taxa bacen*/
DEF        VAR aux_cdhisbac AS INTE                                  NO-UNDO.
DEF        VAR aux_cdtarbac AS CHAR                                  NO-UNDO.
DEF        VAR aux_vltarbac AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR aux_cdfvlbac AS INTE                                  NO-UNDO.

/* Variáveis de uso da BO 200 */
DEF VAR h-b1wgen0200         AS HANDLE                              NO-UNDO.
DEF VAR aux_incrineg         AS INT                                 NO-UNDO.
DEF VAR aux_cdcritic         AS INT                                 NO-UNDO.
DEF VAR aux_dscritic         AS CHAR                                NO-UNDO.


ASSIGN glb_cdprogra = "crps587"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

IF   glb_inrestar > 0   AND   glb_nrctares = 0   THEN
     glb_inrestar = 0.
       
/* Busca dados da cooperativa */

FIND crapcop WHERE crapcop.cdcooper = p-cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> logo/proc_bath").
         RETURN.
     END.                      

ASSIGN aux_nmcidade = TRIM(crapcop.nmcidade)
       res_nrdctabb = INTEGER(SUBSTRING(glb_dsrestar,01,08))
       res_nrdocmto = INTEGER(SUBSTRING(glb_dsrestar,10,07))
       res_cdhistor = INTEGER(SUBSTRING(glb_dsrestar,18,03)).

/*  APENAS CECRED  */
ASSIGN aux_cdbanchq = crapcop.cdbcoctl.

HIDE MESSAGE NO-PAUSE.

RUN gera_lancamento.

IF   RETURN-VALUE = "OK"   THEN
     RUN gera_impressao.

/* .......................................................................... */

PROCEDURE gera_lancamento:

    DEF VAR aux_contador AS INTEGER                                  NO-UNDO.
    DEF VAR aux_nrdconta AS INTEGER                                  NO-UNDO.
    DEF VAR aux_nrdctabb AS INTEGER                                  NO-UNDO.
    DEF VAR aux_cdcooper AS INTEGER                                  NO-UNDO.
    DEF VAR aux_cdpesqbb AS CHAR                                     NO-UNDO.

    IF  NOT VALID-HANDLE(h-b1wgen0153) THEN
        RUN sistema/generico/procedures/b1wgen0153.p
            PERSISTENT SET h-b1wgen0153.

    TRANS_1:
    FOR EACH crapdev WHERE crapdev.cdcooper = p-cdcopant  AND
                           crapdev.insitdev = 0           AND
                           crapdev.cdpesqui = "TCO"       EXCLUSIVE-LOCK
                           TRANSACTION ON ERROR UNDO TRANS_1, RETURN:

        HIDE MESSAGE NO-PAUSE.

        FIND FIRST crapass WHERE crapass.cdcooper = crapdev.cdcooper AND
                                 crapass.nrdconta = crapdev.nrdconta
                                 NO-LOCK NO-ERROR.
                                 
        IF  NOT AVAILABLE crapass THEN
            DO:
                glb_cdcritic = 251.
                RUN fontes/critic.p. 
                UNIX SILENT VALUE
                         ("echo " + STRING(TIME,"HH:MM:SS") +
                         " - " + glb_cdprogra + "' --> '"  +
                         STRING(crapdev.nrdconta,"zzzz,zz9,9") +
                         glb_dscritic + 
                         " >> log/proc_batch.log").

                IF  VALID-HANDLE(h-b1wgen0153) THEN
                    DELETE OBJECT h-b1wgen0153.

                UNDO TRANS_1, RETURN "NOK".
            END.

        IF  crapass.inpessoa = 1 THEN
            ASSIGN aux_cdtarifa = "DEVOLCHQPF" 
                   aux_cdtarbac = "DEVCHQBCPF". 
            
        ELSE
            ASSIGN aux_cdtarifa = "DEVOLCHQPJ" 
                   aux_cdtarbac = "DEVCHQBCPJ". 
        
        IF  aux_cdtarifa = "DEVOLCHQPF" OR aux_cdtarifa = "DEVOLCHQPJ" THEN
            DO:
                RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                              (INPUT  p-cdcopant,
                                               INPUT  aux_cdtarifa,
                                               INPUT  crapdev.vllanmto, 
                                               INPUT  glb_cdprogra,
                                               OUTPUT aux_cdhistor,
                                               OUTPUT aux_cdhisest,
                                               OUTPUT aux_vltarifa,
                                               OUTPUT aux_dtdivulg,
                                               OUTPUT aux_dtvigenc,
                                               OUTPUT aux_cdfvlcop,
                                               OUTPUT TABLE tt-erro).
                
                IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                       FIND FIRST tt-erro NO-LOCK NO-ERROR.

                       IF AVAIL tt-erro THEN 
                          UNIX SILENT VALUE("echo " + 
                               STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '"
                               + tt-erro.dscritic +  
                               " >> log/proc_batch.log"). 

                       IF  VALID-HANDLE(h-b1wgen0153) THEN
                           DELETE OBJECT h-b1wgen0153.
        
                       UNDO TRANS_1, RETURN "NOK".

                    END.
            END.
        
        /* BUSCA INFORMACOES TAXA BACEN*/
        IF  aux_cdtarbac = "DEVCHQBCPF" OR aux_cdtarbac = "DEVCHQBCPJ" THEN
            DO:
                RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                                (INPUT  p-cdcopant,
                                                 INPUT  aux_cdtarbac,
                                                 INPUT  crapdev.vllanmto, 
                                                 INPUT  glb_cdprogra,
                                                 OUTPUT aux_cdhisbac,
                                                 OUTPUT aux_cdhisest,
                                                 OUTPUT aux_vltarbac,
                                                 OUTPUT aux_dtdivulg,
                                                 OUTPUT aux_dtvigenc,
                                                 OUTPUT aux_cdfvlbac,
                                                 OUTPUT TABLE tt-erro).
                
                IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF AVAIL tt-erro THEN
                           UNIX SILENT VALUE("echo " + 
                                STRING(TIME,"HH:MM:SS") +
                                " - " + glb_cdprogra + "' --> '"
                                + tt-erro.dscritic +  
                                " >> log/proc_batch.log").      

                        IF  VALID-HANDLE(h-b1wgen0153) THEN
                            DELETE OBJECT h-b1wgen0153.
        
                        UNDO TRANS_1, RETURN "NOK".

                    END.
            END.

        ASSIGN aux_contador = aux_contador + 1.

        MESSAGE "Gerando Lancamentos: " + STRING(aux_contador) + " ...".

        ASSIGN glb_cdcritic = 0
               glb_inrestar = 0.

        IF  crapdev.cdbanchq <> crapcop.cdbcoctl THEN
            NEXT.
                                                               
        FIND FIRST craptco WHERE craptco.cdcopant = crapdev.cdcooper AND
                                 craptco.nrctaant = crapdev.nrdconta AND
                                 craptco.tpctatrf = 1                AND
                                 craptco.flgativo = TRUE
                                 NO-LOCK NO-ERROR.
    
        IF  NOT AVAILABLE craptco THEN
            DO:
                MESSAGE "Erro na Geracao do Relatorio - TCO nao Encontrado".
                PAUSE 20 NO-MESSAGE.
                
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                  " - " + glb_cdprogra + "' --> '"  +
                                  "TCO Nao Encontrado - Conta:" +
                                  STRING(crapdev.nrdconta) + 
                                  " Veriique e Gere novamente o Rel. Dev. " +
                                  " >> log/proc_bath.log").
                NEXT.
            END.
                                                              
        ASSIGN aux_nrdconta = craptco.nrdconta      /* VIACREDI */
               aux_cdcooper = craptco.cdcooper.     /* VIACREDI */
                                                           
        IF  CAN-DO("47,191,338,573",STRING(crapdev.cdhistor))  THEN
            DO:
                glb_nrcalcul =
                    INT(SUBSTR(STRING(crapdev.nrcheque,"9999999"),1,6)).
                
                DO WHILE TRUE:

                   FIND crapfdc WHERE crapfdc.cdcooper = crapdev.cdcooper AND
                                      crapfdc.cdbanchq = crapdev.cdbanchq AND
                                      crapfdc.cdagechq = crapdev.cdagechq AND
                                      crapfdc.nrctachq = crapdev.nrctachq AND
                                      crapfdc.nrcheque = INT(glb_nrcalcul)
                                      USE-INDEX crapfdc1
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF  NOT AVAILABLE crapfdc   THEN
                       IF  LOCKED crapfdc   THEN
                           DO:
                               PAUSE 1 NO-MESSAGE.
                               NEXT.
                           END.
                       ELSE
                           DO:
                               glb_cdcritic = 268. 
                               LEAVE.
                           END.
                   LEAVE.

                END.  /*  Fim do DO WHILE TRUE  */

                IF  glb_cdcritic > 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                          " - " + glb_cdprogra + "' --> '"  +
                                          glb_dscritic +
                                          "CTA: " + STRING(crapdev.nrdconta) +
                                          "CBS: " + STRING(crapdev.nrdctabb) +
                                          "DOC: " + STRING(crapdev.nrcheque) +
                                          " >> log/proc_batch.log").
                        
                        IF  VALID-HANDLE(h-b1wgen0153) THEN
                            DELETE OBJECT h-b1wgen0153.

                        UNDO TRANS_1, RETURN "NOK".
                    END.

                /*  Leitura do lote de devolucao de cheque  */
                DO WHILE TRUE:

                   FIND craplot WHERE craplot.cdcooper = p-cdcooper   AND
                                      craplot.dtmvtolt = glb_dtmvtolt AND
                                      craplot.cdagenci = aux_cdagenci AND
                                      craplot.cdbccxlt = aux_cdbccxlt AND
                                      craplot.nrdolote = 10117
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF  NOT AVAILABLE craplot   THEN
                       IF  LOCKED craplot   THEN
                           DO:
                               PAUSE 1 NO-MESSAGE.
                               NEXT.
                           END.
                       ELSE
                           DO:
                               CREATE craplot.
                               ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                                      craplot.cdcooper = p-cdcooper
                                      craplot.cdagenci = aux_cdagenci
                                      craplot.cdbccxlt = aux_cdbccxlt
                                      craplot.tplotmov = 1
                                      craplot.nrdolote = 10117.
                               VALIDATE craplot.
                           END.
                   LEAVE.
                END.  /*  Fim do DO WHILE TRUE  */
                
                
              /* BLOCO DA INSERÇAO DA CRAPLCM */
              IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
                RUN sistema/generico/procedures/b1wgen0200.p 
                  PERSISTENT SET h-b1wgen0200.
                  
                  
              IF   crapdev.cdalinea <> 0 THEN
                ASSIGN aux_cdpesqbb = STRING(crapdev.cdalinea).
              ELSE 
                ASSIGN aux_cdpesqbb = "21".

              RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
                (INPUT craplot.dtmvtolt               /* par_dtmvtolt */
                ,INPUT craplot.cdagenci               /* par_cdagenci */
                ,INPUT craplot.cdbccxlt               /* par_cdbccxlt */
                ,INPUT craplot.nrdolote               /* par_nrdolote */
                ,INPUT aux_nrdconta                   /* par_nrdconta */
                ,INPUT crapdev.nrcheque               /* par_nrdocmto */
                ,INPUT crapdev.cdhistor               /* par_cdhistor */
                ,INPUT craplot.nrseqdig + 1           /* par_nrseqdig */
                ,INPUT crapdev.vllanmto               /* par_vllanmto */
                ,INPUT aux_nrdconta                   /* par_nrdctabb */
                ,INPUT aux_cdpesqbb                   /* par_cdpesqbb */
                ,INPUT 0                              /* par_vldoipmf */
                ,INPUT 0                              /* par_nrautdoc */
                ,INPUT 0                              /* par_nrsequni */
                ,INPUT crapdev.cdbanchq               /* par_cdbanchq */
                ,INPUT 0                              /* par_cdcmpchq */
                ,INPUT crapdev.cdagechq               /* par_cdagechq */
                ,INPUT crapdev.nrdconta               /* par_nrctachq */
                ,INPUT 0                              /* par_nrlotchq */
                ,INPUT 0                              /* par_sqlotchq */
                ,INPUT ""                             /* par_dtrefere */
                ,INPUT ""                             /* par_hrtransa */
                ,INPUT crapdev.cdoperad               /* par_cdoperad */
                ,INPUT 0                              /* par_dsidenti */
                ,INPUT aux_cdcooper                   /* par_cdcooper */
                ,INPUT ""                             /* par_nrdctitg */
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
                       UNIX SILENT VALUE("echo " + 
                          STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"
                           + aux_dscritic +  
                        " >> log/proc_batch.log").  

                       UNDO TRANS_1, RETURN "NOK".                     
                   END.   
                ELSE 
                   DO:
                     /* 19/06/2018- TJ - Posicionando no registro da craplcm criado acima */
                     FIND FIRST tt-ret-lancto.
                     FIND FIRST craplcm WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm NO-ERROR.
                   END.                
                
                IF  VALID-HANDLE(h-b1wgen0200) THEN
                  DELETE PROCEDURE h-b1wgen0200.
                

                
                ASSIGN craplot.vlinfocr = craplot.vlinfocr + craplcm.vllanmto
                       craplot.vlcompcr = craplot.vlcompcr + craplcm.vllanmto
                       craplot.qtinfoln = craplot.qtinfoln + 1
                       craplot.qtcompln = craplot.qtcompln + 1
                       craplot.nrseqdig = craplot.nrseqdig + 1

                       crapfdc.incheque = crapfdc.incheque - 5
                       crapfdc.dtliqchq = ?
                       crapfdc.vlcheque = 0
                       crapfdc.vldoipmf = 0
                       craplcm.nrdctitg = "" NO-ERROR.
                
                ASSIGN craplcm.nrdctitg = "".
                
                /* Atribui Valor para Alinea na GNCPCHQ */
                FIND gncpchq WHERE 
                             gncpchq.cdcooper = crapdev.cdcooper      AND
                             gncpchq.dtmvtolt = crapfdc.dtliqchq      AND
                             gncpchq.cdtipreg = 4                     AND
                             gncpchq.cdcmpchq = crapfdc.cdcmpchq      AND
                             gncpchq.cdbanchq = crapfdc.cdbanchq      AND
                             gncpchq.cdagechq = crapdev.cdagechq      AND
                             gncpchq.nrctachq = crapdev.nrctachq      AND
                             gncpchq.nrcheque = INT(crapdev.nrcheque) AND
                             gncpchq.vlcheque = crapdev.vllanmto 
                             USE-INDEX gncpchq1 EXCLUSIVE-LOCK NO-ERROR.
          
                IF  AVAILABLE gncpchq THEN
                    DO:
                        IF   crapdev.cdalinea <> 0 THEN
                             gncpchq.cdalinea = crapdev.cdalinea.
                        ELSE 
                             gncpchq.cdalinea = 21.
                    END.
                      
                ASSIGN crapdev.indevarq = 1         /* Segunda Devolucao */
                       craplcm.dsidenti = "TCO".
            END.
        ELSE
        IF  crapdev.cdhistor = 46 THEN
            DO:             
               /*  taxa de devolucao de cheque  */
               IF  crapass.inpessoa <> 3        AND 
                  (aux_cdtarifa = "DEVOLCHQPF"  OR 
                   aux_cdtarifa = "DEVOLCHQPJ") THEN
                   DO:
                       RUN cria_lan_auto_tarifa IN h-b1wgen0153
                                               (INPUT aux_cdcooper,
                                                INPUT aux_nrdconta, 
                                                INPUT glb_dtmvtolt,
                                                INPUT aux_cdhistor, 
                                                INPUT aux_vltarifa,
                                                INPUT "1", /*cdoperad*/
                                                INPUT 1, /*cdagenci*/
                                                INPUT 100,  /*cdbccxlt*/
                                                INPUT 8452, /*nrdolote*/
                                                INPUT 1,    /*tpdolote*/
                                                INPUT crapdev.nrcheque,
                                                INPUT aux_nrdconta,  /*nrdctabb*/
                                                INPUT crapdev.nrdctitg,
                                                INPUT "Fato gerador tarifa:" + STRING(crapdev.nrcheque),  /*cdpesqbb*/
                                                INPUT crapdev.cdbanchq,   
                                                INPUT crapdev.cdagechq,   
                                                INPUT crapdev.nrctachq,   
                                                INPUT TRUE, /*flgaviso*/
                                                INPUT 2,   /*tpaviso*/
                                                INPUT aux_cdfvlcop,
                                                INPUT glb_inproces,
                                                OUTPUT TABLE tt-erro).
                                             
                       IF  RETURN-VALUE = "NOK"  THEN
                           DO:
                               FIND FIRST tt-erro NO-LOCK NO-ERROR.
               
                               IF AVAIL tt-erro THEN
                                  UNIX SILENT VALUE("echo " + 
                                       STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '"
                                       + tt-erro.dscritic +  
                                       " >> log/proc_batch.log").                       
               
                               IF  VALID-HANDLE(h-b1wgen0153) THEN
                                   DELETE OBJECT h-b1wgen0153.
               
                               UNDO TRANS_1, RETURN "NOK".
               
                           END.
                   END. /* END do IF taxa normal devolucao cheque */ 
               
               /*cria lancamento para taxa bacen*/
               IF (aux_cdtarbac = "DEVCHQBCPF"  OR 
                   aux_cdtarbac = "DEVCHQBCPJ") AND
                   crapass.inpessoa <> 3        THEN
                   DO:
                       RUN cria_lan_auto_tarifa IN h-b1wgen0153
                                               (INPUT aux_cdcooper,
                                                INPUT aux_nrdconta, 
                                                INPUT glb_dtmvtolt,
                                                INPUT aux_cdhisbac, 
                                                INPUT aux_vltarbac,
                                                INPUT "1", /*cdoperad*/
                                                INPUT 1,   /*cdagenci*/
                                                INPUT 100,  /*cdbccxlt*/
                                                INPUT 8452, /*nrdolote*/
                                                INPUT 1,    /*tpdolote*/
                                                INPUT 0,
                                                INPUT aux_nrdconta,  /*nrdctabb*/
                                                INPUT crapdev.nrdctitg,
                                                INPUT "Fato gerador tarifa:" + STRING(crapdev.nrcheque),  /*cdpesqbb*/
                                                INPUT crapdev.cdbanchq,   
                                                INPUT crapdev.cdagechq,   
                                                INPUT crapdev.nrctachq,   
                                                INPUT FALSE, /*flgaviso*/
                                                INPUT 0,   /*tpaviso*/
                                                INPUT aux_cdfvlbac,
                                                INPUT glb_inproces,
                                                OUTPUT TABLE tt-erro).
                                             
                       IF  RETURN-VALUE = "NOK"  THEN
                           DO:
                               FIND FIRST tt-erro NO-LOCK NO-ERROR.
               
                               IF AVAIL tt-erro THEN
                                  UNIX SILENT VALUE("echo " + 
                                       STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '"
                                       + tt-erro.dscritic +  
                                       " >> log/proc_batch.log").                       
               
                               IF  VALID-HANDLE(h-b1wgen0153) THEN
                                   DELETE OBJECT h-b1wgen0153.
               
                               UNDO TRANS_1, RETURN "NOK".
               
                           END.
                   END. /*fim do if taxa bacen*/
        END.   /* fim if cdhistor = 46 */

        ASSIGN crapdev.insitdev = 1
               crapdev.indctitg = FALSE.
        
    END.  /*  Fim do FOR EACH e da transacao  */
    
    IF  VALID-HANDLE(h-b1wgen0153) THEN
        DELETE OBJECT h-b1wgen0153.

    RETURN "OK".

END PROCEDURE.

/* .......................................................................... */
    
PROCEDURE gera_impressao:

    DEF VAR aux_contador AS INTEGER                               NO-UNDO.
    DEF VAR aux_nmarqtmp AS CHAR    FORMAT "x(40)"                NO-UNDO.
    DEF VAR aux_tprelato AS INT                                   NO-UNDO.
    DEF VAR aux_nmrelato AS CHAR                                  NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR    FORMAT "x(40)"                NO-UNDO.
    DEF VAR aux_dsdevolu AS CHAR    FORMAT "x(6)"                 NO-UNDO.
    DEF VAR aux_nrdconta AS INT                                   NO-UNDO.
    
    FORM SKIP(3)
         aux_nmcidade    FORMAT "x(14)" "," 
         glb_dtmvtolt    FORMAT "99/99/9999"
         "."  
         SKIP(1)
         "A" SKIP
         aux_nmdbanco    FORMAT "x(20)"
         SKIP(3)
         "Solicitamos devolucao dos cheques do dia"
         glb_dtmvtoan FORMAT "99/99/9999"
         "abaixo relacionados."
         SKIP(2)
         WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_brasil.
    
    FORM "Banco  Age. Cta. Cheque    Cheque         Valor Alinea Titular(es)"
         SKIP
         "CPF/CNPJ/CONTA/PESQUISA"                  AT 56
         SKIP
         "----------------------------------------" AT 1
         "----------------------------------------" AT 41
         WITH NO-BOX NO-LABELS FRAME f_cabecalho.
       
    FORM crapdev.cdbanchq  FORMAT "z,zz9"          AT 01   NO-LABEL
         crapdev.cdagechq  FORMAT "z,zz9"          AT 07   NO-LABEL
         aux_nrdconta      FORMAT "zzzzz,zz9,9"    AT 13   NO-LABEL
         crapdev.nrcheque  FORMAT "zzz,zz9,9"      AT 26   NO-LABEL
         crapdev.vllanmto  FORMAT "zz,zzz,zz9.99"  AT 36   NO-LABEL
         crapdev.cdalinea  FORMAT "z9"             AT 52   NO-LABEL
         crapass.nmprimtl  FORMAT "x(25)"          AT 57   NO-LABEL 
         SKIP
         rel_nrcpfcgc      FORMAT "x(18)"          AT 57   NO-LABEL
         crapdev.nrdconta  FORMAT "zzzz,zzz,9"     AT 76   NO-LABEL
         SKIP
         crapdev.cdpesqui  FORMAT "x(54)"          AT 57   NO-LABEL
         WITH NO-BOX WIDTH 132 NO-LABELS DOWN FRAME f_lanctos.
 
    FORM SKIP(3)
         "  TOTAL   "
         rel_qtchqdev 
         rel_vlchqdev
         SKIP(2)
         "  Atenciosamente"
         SKIP(2)
         rel_nmrescop[1] FORMAT "x(40)"
         SKIP
         rel_nmrescop[2] FORMAT "x(40)"
         WITH NO-BOX NO-LABELS FRAME f_fim.
     
    FORM SKIP(3)
         "  TOTAL   "
         rel_qtchqdev 
         rel_vlchqdev
         WITH NO-BOX NO-LABELS FRAME f_fim_resumido.
    
    { includes/cabrel080_1.i }

    /*** Busca dados da cooperativa ***/
    FIND crapcop WHERE crapcop.cdcooper = p-cdcooper NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapcop  THEN
         DO:
             glb_cdcritic = 651.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '"  +
                               glb_dscritic + " >> logo/proc_bath").
             RETURN "NOK".
         END.

    ASSIGN aux_nmcidade = TRIM(crapcop.nmcidade)
           aux_nmarquiv = "crrl219_6.lst"
           aux_nmarqdev = "devtco_cecred_noturna.txt".

    OUTPUT STREAM str_1 TO VALUE("rl/" + aux_nmarquiv) PAGED PAGE-SIZE 80.

    VIEW STREAM str_1 FRAME f_cabrel080_1.

    /*  Relacao para o envio ao Banco do Brasil (sem Desconto e Custodia)  */

    FOR EACH crapdev WHERE crapdev.cdcooper = p-cdcopant       AND
                           crapdev.cdbanchq = aux_cdbanchq     AND
                           crapdev.insitdev = 1                AND
                           crapdev.cdhistor <> 46              AND
                           crapdev.cdalinea > 0                AND
                           crapdev.cdpesqui = "TCO"            NO-LOCK
                           BREAK BY crapdev.cdbccxlt
                                    BY crapdev.nrdctabb
                                       BY crapdev.nrcheque:
        
        FIND FIRST craptco WHERE craptco.cdcopant = crapdev.cdcooper AND
                                 craptco.nrctaant = crapdev.nrdconta AND
                                 craptco.tpctatrf = 1                AND
                                 craptco.flgativo = TRUE
                                 NO-LOCK NO-ERROR.
    
        IF  NOT AVAILABLE craptco THEN
            DO:
                MESSAGE "Erro na Geracao do Relatorio - TCO nao Encontrado".
                PAUSE 20 NO-MESSAGE.
                
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                  " - " + glb_cdprogra + "' --> '"  +
                                  "TCO Nao Encontrado - Conta:" +
                                  STRING(crapdev.nrdconta) + 
                                  " Veriique e Gere novamente o Rel. Dev. " +
                                  " >> log/proc_bath.log").
                NEXT.
            END.
        
        FIND crapass WHERE crapass.cdcooper = craptco.cdcooper AND
                           crapass.nrdconta = craptco.nrdconta 
                           NO-LOCK NO-ERROR.
                            
        IF  NOT AVAILABLE crapass THEN
            DO:
                MESSAGE "Erro na Geracao do Relatorio - ASS nao Encontrado".
                PAUSE 20 NO-MESSAGE.
                
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                  " - " + glb_cdprogra + "' --> '"  +
                                  "TCO Nao Encontrado - Conta:" +
                                  STRING(crapdev.nrdconta) + 
                                  " Veriique e Gere novamente o Rel. Dev. " +
                                  " >> log/proc_bath.log").
                NEXT.
            END.
            
        
        HIDE MESSAGE NO-PAUSE.

        ASSIGN aux_contador = aux_contador + 1
               aux_nrdconta = crapdev.nrdconta.

        MESSAGE "Gerando Relatorio: " + STRING(aux_contador) + "...".

        IF  FIRST-OF(crapdev.cdbccxlt) OR 
            LINE-COUNTER(str_1) > 80   THEN
            DO:
                 IF  FIRST-OF(crapdev.cdbccxlt) THEN
                     ASSIGN rel_qtchqdev = 0
                            rel_vlchqdev = 0.

                 aux_nmdbanco = "AILOS".
                                   
                 DISPLAY STREAM str_1 aux_nmcidade glb_dtmvtolt
                                      aux_nmdbanco glb_dtmvtoan  
                                      WITH FRAME f_brasil.

                 VIEW STREAM str_1 FRAME f_cabecalho.
            END.

        IF  crapass.inpessoa = 1 THEN
            ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                   rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xxx.xxx.xxx-xx").
        ELSE
            ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                   rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").
            
        ASSIGN rel_qtchqdev = rel_qtchqdev + 1
               rel_vlchqdev = rel_vlchqdev + crapdev.vllanmto.
          
        
        DISPLAY STREAM str_1 crapdev.cdbanchq   crapdev.cdagechq
                             aux_nrdconta       crapdev.nrcheque
                             crapdev.vllanmto   crapdev.cdalinea
                             crapass.nmprimtl WHEN
                                 (CAN-DO("12,13",STRING(crapdev.cdalinea)) OR
                                 (crapdev.cdalinea = 11                    AND
                                  crapdev.cdbccxlt = crapcop.cdbcoctl))
                             rel_nrcpfcgc     WHEN 
                                 (CAN-DO("12,13",STRING(crapdev.cdalinea)) OR
                                 (crapdev.cdalinea = 11                    AND 
                                  crapdev.cdbccxlt = crapcop.cdbcoctl))
                             crapdev.cdpesqui   
                             WITH FRAME f_lanctos.

        DOWN STREAM str_1 WITH FRAME f_lanctos.

        IF  LAST-OF(crapdev.cdbccxlt) THEN
            DO:
                /* Rotina p/ dividir campo crapcop.nmextcop em duas Strings */

                ASSIGN aux_qtpalavr = NUM-ENTRIES(TRIM(crapcop.nmextcop)," ")
                                      / 2
                       rel_nmrescop = "".

                DO aux_contapal = 1 TO NUM-ENTRIES(TRIM(crapcop.nmextcop)," "):

                   IF   aux_contapal <= aux_qtpalavr   THEN
                        rel_nmrescop[1] = rel_nmrescop[1] +
                                          (IF TRIM(rel_nmrescop[1]) = ""
                                          THEN "" ELSE " ") +
                                      ENTRY(aux_contapal,crapcop.nmextcop," ").
                   ELSE
                        rel_nmrescop[2] = rel_nmrescop[2] +
                                          (IF TRIM(rel_nmrescop[2]) = ""
                                          THEN "" ELSE " ") +
                                      ENTRY(aux_contapal,crapcop.nmextcop," ").
                END.  /*  Fim DO .. TO  */ 

                ASSIGN rel_nmrescop[1] = FILL(" ",20 - 
                                            INT(LENGTH(rel_nmrescop[1]) / 2)) +
                                            rel_nmrescop[1]
                       rel_nmrescop[2] = FILL(" ",20 - 
                                            INT(LENGTH(rel_nmrescop[2]) / 2)) +
                                            rel_nmrescop[2].
                /*  Fim da Rotina  */

                DISPLAY STREAM str_1 rel_qtchqdev rel_vlchqdev rel_nmrescop
                                     WITH FRAME f_fim.

                PAGE STREAM str_1.
            END.

    END.  /** Fim do FOR EACH crapdev **/

    OUTPUT STREAM str_1 CLOSE.

    /*  Salvar copia relatorio para "/rlnsv"  */
    UNIX SILENT VALUE("cp rl/" + aux_nmarquiv + " rlnsv").

    UNIX SILENT VALUE("ux2dos rl/" + aux_nmarquiv + " > /micros/" + 
                      crapcop.dsdircop + "/devolu/" + aux_nmarqdev).

    ASSIGN aux_nmrelato = " "
           aux_tprelato = 1.

    HIDE MESSAGE NO-PAUSE.

    FIND craprel WHERE craprel.cdcooper = p-cdcooper AND
                       craprel.cdrelato = 219
                       NO-LOCK NO-ERROR.

    IF  AVAILABLE craprel  THEN
        ASSIGN aux_nmrelato = craprel.nmrelato.

    ASSIGN aux_nmarqtmp = "tmppdf/" + aux_nmarquiv + ".txt"
           aux_nmarqpdf = SUBSTR(aux_nmarquiv,1,
                                 LENGTH(aux_nmarquiv) - 4) + ".pdf".

    OUTPUT STREAM str_2 TO VALUE (aux_nmarqtmp).

    PUT STREAM str_2 STRING(crapcop.nmrescop, "X(20)")                ";"
                     STRING(YEAR(glb_dtmvtolt),"9999") FORMAT "x(04)" ";"
                     STRING(MONTH(glb_dtmvtolt),"99")  FORMAT "x(02)" ";"
                     STRING(DAY(glb_dtmvtolt),"99")    FORMAT "x(02)" ";"
                     STRING(aux_tprelato,"z9")         FORMAT "x(02)" ";"
                     aux_nmarqpdf                                     ";"
                     CAPS(aux_nmrelato)                FORMAT "x(50)" ";"
                     SKIP.

    OUTPUT STREAM str_2 CLOSE.

    UNIX SILENT VALUE("script/CriaPDF.sh rl/" + aux_nmarquiv + " NAO 132col " +
                      STRING(YEAR(glb_dtmvtolt),"9999") + "_" + 
                      STRING(MONTH(glb_dtmvtolt),"99") + "/" + 
                      STRING(DAY(glb_dtmvtolt),"99")).

    RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT SET h-b1wgen0011.

    IF  NOT VALID-HANDLE (h-b1wgen0011)  THEN
        DO:
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - " + glb_cdprogra + "' --> '" +
                              "Handle invalido para h-b1wgen0011." +
                              " >> log/proc_batch.log").
            QUIT.          
        END.

    RUN converte_arquivo IN h-b1wgen0011(INPUT glb_cdcooper,
                                         INPUT "rl/" + aux_nmarquiv,
                                         INPUT aux_nmarquiv).

    RUN enviar_email IN h-b1wgen0011(INPUT glb_cdcooper,
                                     INPUT "crps587",
                                     INPUT "edesio@viacredi.coop.br," +
                                           "financeiro@creditextil.coop.br," +
                                           "brusque@viacredi.coop.br," +
                                           "fabiano@viacredi.coop.br," +
                                           "moraes@viacredi.coop.br",
                                     INPUT "Relatorio de Devolucoes Cheques " + 
                                           "AILOS das Contas do PA 58",
                                     INPUT aux_nmarquiv,
                                     INPUT FALSE).
    
    DELETE PROCEDURE h-b1wgen0011.
    
    RETURN "OK".

END PROCEDURE.

/* .......................................................................... */
