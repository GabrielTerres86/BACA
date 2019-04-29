/* ............................................................................

   Programa: Fontes/b1wgen0170.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas R.
   Data    : Agosto/2013                         Ultima atualizacao: 04/06/2018

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : BO referente as informacoes da tela cadcyb

   Alteracoes: 01/10/2013 - Ajustes na grava-dados-crapcyc para acumlar as 
                            mensagens de erro e mostrar no final do processo.
                          - Retirado validacao crapass.dtdemiss <> ? da 
                            valida-cadcyb. (Lucas R.)

               12/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
               
               31/12/2013 - Ajuste no Log das procedure "grava-dados-crapcyc",
                            "altera-dados-crapcyc" e "excluir-dados-crapcyc"
                            (James).
                            
               09/06/2014 - Incluso procedure importa-dados-crapcyc (Daniel).
               
               15/01/2014 - (Chamado 236661) Sempre que ocorrer uma inclusao 
                            de contrato, deve realizar os pontos abaixo:
                            -Alteraçao da situaçao da conta para nao aprovada,
                            -Efetuar bloqueio do cartao magnético,
                            -Efetuar cancelamento do acesso a conta corrente 
                             pelo internet banking (Tiago Castro - RKAM).
                
               22/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714)

               15/09/2015 - Adicionado os campos de Motivio CIN e Assessoria
                            (Douglas - Melhoria 12)
               
               17/09/2015 - Alterado o bloqueio de senhas para nao bloquear a
                            senha de LETRAS (Douglas - Chamado 324848)
							
			   06/11/2015 - Adicionado log na rotina de importacao conforme solicitado
						    no chamado 342859. (Kelvin)
			   
			   04/02/2016 - Chamado 376144, Atualizar data de manutencao cadastral
			                ao alterar dados na CADCYB (Heitor - RKAM)

			   13/10/2016 - 533466-Cyber, Atualizar data de manutencao cadastral
			                ao inserir dados na CADCYB (Gil Furtado - Mouts)

			   13/03/2018 - 806202- Não possibilitar mudança/inserção de CDMOTCIN 2 e 7
			                se operador não for do depto.Jurídico (Everton Souza - Mouts)

               04/06/2018 - Projeto 403 - Envio de titulos descontados para a Cyber (Lucas Lazari - GFT)
			   
			   26/04/2018 - P437 - Consignado. Alteração na grava-dados-crapcyc e importa-dados-crapcyc
                             (Fernanda Kelli de Oliveira - AMcom)
.............................................................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0170tt.i }
{ sistema/generico/includes/b1wgen0168tt.i }
{ sistema/generico/includes/var_oracle.i }

{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i  }

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.

DEF VAR aux_flgjudic AS LOG                                           NO-UNDO.
DEF VAR aux_flextjud AS LOG                                           NO-UNDO.
DEF var aux_flgehvip AS LOG                                           NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF STREAM str_1.
DEF STREAM str_2.

PROCEDURE valida-cadcyb:

    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdorigem AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_nrborder AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrtitulo AS INTE                               NO-UNDO.

    DEF OUTPUT PARAM par_flgmsger AS LOG INIT FALSE                    NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapcyc.
    DEF OUTPUT PARAM TABLE FOR tt-erro.   

    DEF VAR aux_nrborder AS INTE                                       NO-UNDO.
    DEF VAR aux_nrtitulo AS INTE                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_cdcritic = 0  
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Validacao de contrato para tela CADCYB.". 

    IF  par_cddopcao = "C" AND par_nrdconta = 0 THEN
        RETURN "OK".
    ELSE
        DO:
            FIND crapass WHERE crapass.cdcooper = par_cdcooper AND 
                               crapass.nrdconta = par_nrdconta   
                               NO-LOCK NO-ERROR.
            
            IF  NOT AVAIL(crapass) THEN
                DO: 
                    ASSIGN aux_cdcritic = 0
	        			   aux_dscritic = "Conta inexistente!".
            
                    RUN gera_erro (INPUT par_cdcooper,        
                                   INPUT par_cdagenci,
                                   INPUT 1, /* nrdcaixa  */
                                   INPUT 1, /* sequencia */
                                   INPUT aux_cdcritic,        
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.

           
            CREATE tt-crapcyc.
            ASSIGN tt-crapcyc.cdcooper = par_cdcooper
                   tt-crapcyc.nrdconta = par_nrdconta
                   tt-crapcyc.nrctremp = par_nrctremp
                   tt-crapcyc.nrborder = par_nrborder
                   tt-crapcyc.nrtitulo = par_nrtitulo.

            IF  par_cddopcao <> "E" THEN
                DO:
                   /* Verifica contrato somente para emprestimo cdorigem = 3 */
                    IF  par_cdorigem = 3 THEN
                        DO:
                            FIND FIRST crapepr WHERE 
                                        crapepr.cdcooper = par_cdcooper AND
                                        crapepr.nrdconta = par_nrdconta AND 
                                        crapepr.nrctremp = par_nrctremp
                                        NO-LOCK NO-ERROR NO-WAIT.
                            
                             IF  NOT AVAIL crapepr THEN
                                 DO:
                                     ASSIGN aux_cdcritic = 356
                                            aux_dscritic = "".
                                    
                                     RUN gera_erro (INPUT par_cdcooper,
                                                    INPUT par_cdagenci,
                                                    INPUT par_nrdcaixa,
                                                    INPUT 1,  /** Sequencia **/
                                                    INPUT aux_cdcritic,
                                                    INPUT-OUTPUT aux_dscritic).
                            
                                     RUN proc_gerar_log (INPUT par_cdcooper,
                                                         INPUT par_cdoperad,
                                                         INPUT aux_dscritic,
                                                         INPUT aux_dsorigem,
                                                         INPUT aux_dstransa,
                                                         INPUT FALSE,
                                                         INPUT par_idseqttl,
                                                         INPUT par_nmdatela,
                                                         INPUT par_nrdconta,
                                                        OUTPUT aux_nrdrowid).
                                     
                                     RETURN "NOK".
                                 END. 
                        END.
                END.
                /* Verifica se titulo e bordero existem somente para  cdorigem = 4 */
                IF  par_cdorigem = 4 THEN
                    DO:
                        /* verifica a existencia do bordero */       
                        FIND FIRST crapbdt WHERE 
                                    crapbdt.cdcooper = par_cdcooper AND
                                    crapbdt.nrdconta = par_nrdconta AND 
                                    crapbdt.nrborder = par_nrborder
                                    NO-LOCK NO-ERROR NO-WAIT.
                        
                         IF  NOT AVAIL crapbdt THEN
                             DO:
                                 ASSIGN aux_cdcritic = 0
                                        aux_dscritic = "Bordero nao encontrado!".
                                
                                 RUN gera_erro (INPUT par_cdcooper,
                                                INPUT par_cdagenci,
                                                INPUT par_nrdcaixa,
                                                INPUT 1,  /** Sequencia **/
                                                INPUT aux_cdcritic,
                                                INPUT-OUTPUT aux_dscritic).
                        
                                 RUN proc_gerar_log (INPUT par_cdcooper,
                                                     INPUT par_cdoperad,
                                                     INPUT aux_dscritic,
                                                     INPUT aux_dsorigem,
                                                     INPUT aux_dstransa,
                                                     INPUT FALSE,
                                                     INPUT par_idseqttl,
                                                     INPUT par_nmdatela,
                                                     INPUT par_nrdconta,
                                                    OUTPUT aux_nrdrowid).
                                 
                                 RETURN "NOK".
        END.
                             
                        /* Verifica a existencia do titulo */
                        FIND FIRST craptdb WHERE 
                                    craptdb.cdcooper = par_cdcooper AND
                                    craptdb.nrdconta = par_nrdconta AND 
                                    craptdb.nrborder = par_nrborder AND
                                    craptdb.nrtitulo = par_nrtitulo
                                    NO-LOCK NO-ERROR NO-WAIT.
                        
                         IF  NOT AVAIL craptdb THEN
                             DO:
                                 ASSIGN aux_cdcritic = 0
                                        aux_dscritic = "Titulo nao encontrado!".
                                
                                 RUN gera_erro (INPUT par_cdcooper,
                                                INPUT par_cdagenci,
                                                INPUT par_nrdcaixa,
                                                INPUT 1,  /** Sequencia **/
                                                INPUT aux_cdcritic,
                                                INPUT-OUTPUT aux_dscritic).
                        
                                 RUN proc_gerar_log (INPUT par_cdcooper,
                                                     INPUT par_cdoperad,
                                                     INPUT aux_dscritic,
                                                     INPUT aux_dsorigem,
                                                     INPUT aux_dstransa,
                                                     INPUT FALSE,
                                                     INPUT par_idseqttl,
                                                     INPUT par_nmdatela,
                                                     INPUT par_nrdconta,
                                                    OUTPUT aux_nrdrowid).
                                 
                                 RETURN "NOK".
                             END.
                         IF par_nrborder > 0 AND par_cddopcao <> "I" THEN
                            DO:
                                FIND FIRST tbdsct_titulo_cyber WHERE tbdsct_titulo_cyber.cdcooper = par_cdcooper AND
                                                               tbdsct_titulo_cyber.nrdconta = par_nrdconta AND
                                                               tbdsct_titulo_cyber.nrtitulo = par_nrtitulo AND
                                                               tbdsct_titulo_cyber.nrborder = par_nrborder
                                                               NO-LOCK NO-ERROR.
                                 IF NOT AVAIL(tbdsct_titulo_cyber) THEN
                                    DO: 
                                        ASSIGN aux_cdcritic = 0
                                               aux_dscritic = "Bordero inexistente!".
                                
                                        RUN gera_erro (INPUT par_cdcooper,        
                                                       INPUT par_cdagenci,
                                                       INPUT 1, /* nrdcaixa  */
                                                       INPUT 1, /* sequencia */
                                                       INPUT aux_cdcritic,        
                                                       INPUT-OUTPUT aux_dscritic).
                                        RETURN "NOK".
                                    END.                          
                                ASSIGN tt-crapcyc.nrctremp = tbdsct_titulo_cyber.nrctrdsc
                                       par_nrctremp        = tbdsct_titulo_cyber.nrctrdsc.
                            END.
                        
                END.
        END.

    IF  par_cddopcao <> "I" THEN
        DO:
            FIND FIRST crapcyc WHERE crapcyc.cdcooper = par_cdcooper AND
                                     crapcyc.cdorigem = par_cdorigem AND
                                     crapcyc.nrdconta = par_nrdconta AND
                                     crapcyc.nrctremp = par_nrctremp 
                                     NO-LOCK NO-ERROR NO-WAIT.
           
            IF  AVAIL crapcyc THEN
                DO:
                    ASSIGN tt-crapcyc.flgjudic = (IF crapcyc.flgjudic THEN "SIM" ELSE "NAO")
                           tt-crapcyc.flextjud = (IF crapcyc.flextjud THEN "SIM" ELSE "NAO")
                           tt-crapcyc.flgehvip = (IF crapcyc.flgehvip THEN "SIM" ELSE "NAO")
                           tt-crapcyc.dtenvcbr = crapcyc.dtenvcbr
                           tt-crapcyc.cdassess = crapcyc.cdassess
                           tt-crapcyc.cdmotcin = crapcyc.cdmotcin.

                    /* Buscar o nome da assessoria */
                    FIND FIRST tbcobran_assessorias 
                         WHERE tbcobran_assessorias.cdassessoria = crapcyc.cdassess
                         NO-LOCK NO-ERROR.
                    IF AVAIL tbcobran_assessorias THEN
                        ASSIGN tt-crapcyc.nmassess = tbcobran_assessorias.nmassessoria.

                    /* Buscar a descricao do motivo */
                    FIND FIRST tbcobran_motivos_cin
                         WHERE tbcobran_motivos_cin.cdmotivo = crapcyc.cdmotcin
                         NO-LOCK NO-ERROR.
                    IF AVAIL tbcobran_motivos_cin THEN
                        ASSIGN tt-crapcyc.dsmotcin = tbcobran_motivos_cin.dsmotivo.
                END.
            ELSE
                DO:
                     ASSIGN aux_cdcritic = 0
                            aux_dscritic = "Registro nao encontrado.".
                    
                     RUN gera_erro (INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT 1,            /** Sequencia **/
                                    INPUT aux_cdcritic,
                                    INPUT-OUTPUT aux_dscritic).
           
                     RETURN "NOK".
                END.
        END.

    IF  par_cddopcao = "E" THEN
        DO:
           /* Verifica se conta/contrato foi enviado para cobranca */
           FIND FIRST crapcyb WHERE crapcyb.cdcooper = par_cdcooper AND
                                    crapcyb.cdorigem = par_cdorigem AND
                                    crapcyb.nrdconta = par_nrdconta AND
                                    crapcyb.nrctremp = par_nrctremp 
                                    NO-LOCK NO-ERROR NO-WAIT.
           
           IF  AVAIL crapcyb THEN
               ASSIGN par_flgmsger = TRUE.

        END.
        
    RETURN "OK".

END PROCEDURE.

PROCEDURE grava-dados-crapcyc:
    
    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_inproces AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_lsdconta AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_lsnrctrc AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_lsnrbord AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_lsnrtitu AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_lsorigem AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_lsjudici AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_lsextjud AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_lsgehvip AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_lsdtenvc AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_lsassess AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_lsmotcin AS CHAR                               NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    DEF VAR aux_flgretur AS LOGICAL INIT FALSE                         NO-UNDO.
    DEF VAR aux_cdorigem AS INTE                                       NO-UNDO.

    DEF VAR par_cdorigem AS CHAR                                       NO-UNDO.
    DEF VAR par_nrdconta AS INTE                                       NO-UNDO.
    DEF VAR par_nrctremp AS INTE                                       NO-UNDO.
    DEF VAR par_nrborder AS INTE                                       NO-UNDO.
    DEF VAR par_nrtitulo AS INTE                                       NO-UNDO.
    DEF VAR par_flgjudic AS CHAR                                       NO-UNDO.
    DEF VAR par_flextjud AS CHAR                                       NO-UNDO.
    DEF VAR par_flgehvip AS CHAR                                       NO-UNDO.
    DEF VAR aux_nrdconta AS CHAR FORMAT "x(12)"                        NO-UNDO.
    DEF VAR aux_nrctremp AS CHAR FORMAT "x(12)"                        NO-UNDO.
    DEF VAR aux_dsmsglog AS CHAR                                       NO-UNDO.
    DEF VAR aux_dtenvcbr AS DATE                                       NO-UNDO.
    DEF VAR aux_cdassess AS INTE                                       NO-UNDO.
    DEF VAR aux_cdmotcin AS INTE                                       NO-UNDO.
    DEF VAR aux_nrctrdsc AS INTE                                       NO-UNDO.

    DEF VAR aux_conta    AS  INTE                                      NO-UNDO.
    DEF VAR aux_contaok  AS  INTE                                      NO-UNDO.
    DEF VAR aux_contanok AS  INTE                                      NO-UNDO.
    DEF VAR h-b1wgen0168 AS HANDLE                                     NO-UNDO.

    ASSIGN aux_cdcritic = 0  
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Grava registros para tela CADCYB.". 

    ASSIGN aux_contaok  = 0
           aux_contanok = 0.

    DO  aux_conta = 1 TO NUM-ENTRIES(par_lsnrctrc,';'):
        /* Conta/dv */
        par_nrdconta = INTE(ENTRY(aux_conta,par_lsdconta,';')).

        /* Contrato  */
        par_nrctremp = INTE(ENTRY(aux_conta,par_lsnrctrc,';')).    
        
        /* Bordero  */
        par_nrborder = INTE(ENTRY(aux_conta,par_lsnrbord,';')).    
        
        /* Titulo  */
        par_nrtitulo = INTE(ENTRY(aux_conta,par_lsnrtitu,';')).    
        
        /* Origem,Conta ou Contrato */
        par_cdorigem = ENTRY(aux_conta,par_lsorigem,';').                
        
        /* Flag Judicial */
        par_flgjudic = ENTRY(aux_conta,par_lsjudici,';').
        
        /* Flag Extra Judicial */
        par_flextjud = ENTRY(aux_conta,par_lsextjud,';').
        
        /* Flag Vip */
        par_flgehvip = ENTRY(aux_conta,par_lsgehvip,';').
        
        /* data de envio para cobrança */
        aux_dtenvcbr = DATE(ENTRY(aux_conta,par_lsdtenvc,';')).
        
        /* assessoria */
        aux_cdassess = INTE(ENTRY(aux_conta,par_lsassess,';')).
        
        /* motivo CIN */
        aux_cdmotcin = INTE(ENTRY(aux_conta,par_lsmotcin,';')).

        IF  par_flgjudic MATCHES "*Nao*" THEN
            ASSIGN aux_flgjudic = FALSE.
        ELSE
            ASSIGN aux_flgjudic = TRUE.
        
        IF  par_flextjud MATCHES "*Nao*" THEN
            ASSIGN aux_flextjud = FALSE.
        ELSE
            ASSIGN aux_flextjud = TRUE.
        
        IF  par_flgehvip MATCHES "*Nao*" THEN
            ASSIGN aux_flgehvip = FALSE.
        ELSE
            ASSIGN aux_flgehvip = TRUE.
        
						   
		/*P437 - Consignado - Motivo 8 Repasse Consignado é utilizado apenas pela tela CONSIG, quando Interromper da Cobrança da Empresa */
		IF aux_cdmotcin = 8 THEN
		 DO:
		   ASSIGN aux_dscritic  = "Motivo exclusivo para utilizacao do sistema.".
		   
		   RUN gera_erro (INPUT par_cdcooper,
						  INPUT par_cdagenci,
						  INPUT par_nrdcaixa,
						  INPUT 1,
						  INPUT 0,
						  INPUT-OUTPUT aux_dscritic).
		   RETURN "NOK".
		END.
		
         /* 1 - Conta, 3 - Contrato, 4 - Desconto de Titulos */
        IF  par_cdorigem MATCHES "*Conta*" THEN
          DO:
            ASSIGN par_nrctremp = INTE(par_nrdconta)
                   aux_cdorigem = 1.
          END.
        ELSE
        IF  par_cdorigem MATCHES "*Titulo*" THEN
          DO:
                ASSIGN aux_cdorigem = 4.
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

            RUN STORED-PROCEDURE pc_inserir_titulo_cyber
                aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                    ,INPUT par_nrdconta
                                                    ,INPUT par_nrborder
                                                    ,INPUT par_nrtitulo
                                                    ,OUTPUT 0 
                                                    ,OUTPUT "").

            CLOSE STORED-PROC pc_inserir_titulo_cyber
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

            ASSIGN aux_dscritic  = pc_inserir_titulo_cyber.pr_dscritic WHEN pc_inserir_titulo_cyber.pr_dscritic <> ?.

            IF aux_dscritic <> "" THEN
             DO:
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,
                              INPUT 0,
                              INPUT-OUTPUT aux_dscritic).
               RETURN "NOK".
            END. 

            /* Substitui o numero do contrato de emprestimo com o sequencial especifico do desconto de titulos */
            ASSIGN par_nrctremp = INT(pc_inserir_titulo_cyber.pr_nrctrdsc).
          END.
        ELSE
            ASSIGN aux_cdorigem = 3.

        /* data de envio para cobrança */
        aux_dtenvcbr = DATE(ENTRY(aux_conta,par_lsdtenvc,';')).
        /* assessoria */
        aux_cdassess = INTE(ENTRY(aux_conta,par_lsassess,';')).
        /* motivo CIN */
        aux_cdmotcin = INTE(ENTRY(aux_conta,par_lsmotcin,';')).

        FIND FIRST crapcyc WHERE crapcyc.cdcooper = par_cdcooper AND
                                 crapcyc.cdorigem = aux_cdorigem AND
                                 crapcyc.nrdconta = par_nrdconta AND
                                 crapcyc.nrctremp = par_nrctremp
                                 NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapcyc THEN
            DO:

                 FIND FIRST crapope WHERE crapope.cdcooper = par_cdcooper
                                      AND crapope.cdoperad = par_cdoperad
                                      NO-LOCK NO-ERROR.
                 IF AVAIL crapope THEN
				   DO:
                   IF (crapope.cddepart <> 13) and (aux_cdmotcin = 2 or aux_cdmotcin = 7) then
                     DO:
                         ASSIGN aux_cdcritic = 0
                         aux_dscritic = "Somente operadores do departamento juridico " +
                                              "podem cadastrar MOTIVO CIN 2 ou 7 !".
                        RUN gera_erro (INPUT par_cdcooper,        
                                       INPUT par_cdagenci,
                                       INPUT 1, /* nrdcaixa  */
                                       INPUT 1, /* sequencia */
                                       INPUT aux_cdcritic,        
                                       INPUT-OUTPUT aux_dscritic).                                            
                        RETURN "NOK".
                     END.	
                   END. 

                 /* INICIO - Atualizar os dados da tabela crapcyb (CYBER) */
                 IF NOT VALID-HANDLE(h-b1wgen0168) THEN
                    RUN sistema/generico/procedures/b1wgen0168.p
                        PERSISTENT SET h-b1wgen0168.
                              
                 EMPTY TEMP-TABLE tt-crapcyb.
                
                 CREATE tt-crapcyb.
                 ASSIGN tt-crapcyb.cdcooper = par_cdcooper
                        tt-crapcyb.nrdconta = par_nrdconta
                        tt-crapcyb.dtmancad = par_dtmvtolt.
                
                 RUN atualiza_data_manutencao_cadastro
                     IN h-b1wgen0168(INPUT TABLE tt-crapcyb,
                                     OUTPUT aux_cdcritic,
                                     OUTPUT aux_dscritic).
                              
                 IF VALID-HANDLE(h-b1wgen0168) THEN
                    DELETE PROCEDURE(h-b1wgen0168).
        
                /*   Bloco de atualisacao da crapcyb  */
                CREATE crapcyc.
                ASSIGN crapcyc.cdcooper = par_cdcooper
                       crapcyc.cdorigem = aux_cdorigem
                       crapcyc.nrdconta = par_nrdconta
                       crapcyc.nrctremp = par_nrctremp
                       crapcyc.flgjudic = aux_flgjudic
                       crapcyc.flextjud = aux_flextjud
                       crapcyc.flgehvip = aux_flgehvip
                       crapcyc.cdoperad = par_cdoperad
                       crapcyc.dtenvcbr = aux_dtenvcbr
                       crapcyc.cdassess = aux_cdassess
                       crapcyc.cdmotcin = aux_cdmotcin
                       crapcyc.dtinclus = par_dtmvtolt
                       crapcyc.cdopeinc = par_cdoperad
                       crapcyc.dtaltera = par_dtmvtolt.
                VALIDATE crapcyc.
                IF  aux_flgjudic     OR /* judicial */
                    aux_flextjud     THEN /* extra judicial */
                DO:
                
                  /* alterar situacao da conta para 5 = nao aprovada */
                  FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                     crapass.nrdconta = par_nrdconta 
                                     EXCLUSIVE-LOCK.
                  ASSIGN crapass.cdsitdct = 5. /* Nao aprovada */
                  VALIDATE crapass.
                  
                  /* Bloquear todos cartoes magneticos ativos */
                  FOR EACH crapcrm WHERE crapcrm.cdcooper = par_cdcooper AND  
                                         crapcrm.nrdconta = par_nrdconta AND 
                                         crapcrm.cdsitcar = 2
                                         EXCLUSIVE-LOCK.
                  
                    ASSIGN crapcrm.cdsitcar = 4. /* Bloqueado */
                  END.
                  VALIDATE crapcrm.
                  
                  /* Bloquear acesso de todos os titulares no internetbank */
                  FOR EACH crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                                         crapsnh.nrdconta = par_nrdconta AND
                                         crapsnh.tpdsenha <> 3           AND /* Nao alterar a senha de letras */
                                         crapsnh.cdsitsnh = 1 
                                         EXCLUSIVE-LOCK.
                  
                    ASSIGN crapsnh.cdsitsnh = 3. /* Cancelado */
                  END.
                  VALIDATE crapsnh.
                  
                END.
                
                ASSIGN aux_contaok = aux_contaok + 1.

                ASSIGN aux_dsmsglog = "Contrato: "                            +
                                      STRING(par_nrctremp,"zz,zzz,zz9")        +
                                      ". Jud.: "                              +
                                      (IF aux_flgjudic THEN "Sim" ELSE "Nao") +
                                      ". Extra Jud.: "                        +
                                      (IF aux_flextjud THEN "Sim" ELSE "Nao") +
                                      ". CIN: "                               +
                                      (IF aux_flgehvip THEN "Sim" ELSE "Nao").

                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dsmsglog,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT TRUE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).

            END. /* IF NOT AVAIL crapcyc */
        ELSE
            DO: 
                FIND FIRST tt-msg EXCLUSIVE-LOCK NO-ERROR.
            
                IF  NOT AVAIL tt-msg THEN
                    DO:
                       CREATE tt-msg.
                       ASSIGN tt-msg.cdcritic = 0
                              tt-msg.dscritic = "Conta: "           +
                              STRING(crapcyc.nrdconta,"zzzz,zzz,z") +
                              " com contrato: "                     +
                              STRING(crapcyc.nrctremp,"zz,zzz,zz9")  +
                              " do tipo: "                     +
                              par_cdorigem  +
                              " ja cadastrados. <br> ". 
                    END.
                ELSE
                    DO: 
                        ASSIGN tt-msg.dscritic = tt-msg.dscritic     + 
                               "Conta: "                             + 
                               STRING(crapcyc.nrdconta,"zzzz,zzz,z") +
                               " com contrato: "                     +
                               STRING(crapcyc.nrctremp,"zz,zzz,zz9")  + 
                               " do tipo: "                     +
                               par_cdorigem  +
                               " ja cadastrados. <br> ".
                          
                    END.

                ASSIGN aux_contanok = aux_contanok + 1
                       aux_dsmsglog = "Contrato: "                     + 
                                      STRING(par_nrctremp,"zz,zzz,zz9") +
                                      " ja cadastrado.".

                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dsmsglog,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).

            END. /* END ELSE */
            

    END. /* fim da entrada contrato */                   
   
    FIND FIRST tt-msg NO-LOCK NO-ERROR.
        
    IF  AVAIL tt-msg THEN
        DO: 
            ASSIGN aux_dscritic = tt-msg.dscritic                         +
                                  STRING(aux_contaok,"zzz,zzz,zz9")       +
                                  " Contas/Contratos/Titulos foram incluidos com" +
                                  " sucesso.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /** Sequencia **/
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
       
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE altera-dados-crapcyc:

    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdorigem AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_flgjudic AS LOG                                NO-UNDO.
    DEF INPUT PARAM par_flextjud AS LOG                                NO-UNDO.
    DEF INPUT PARAM par_flgehvip AS LOG                                NO-UNDO.
    DEF INPUT PARAM par_dtenvcbr AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_cdassess AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdmotcin AS INTE                               NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    DEF VAR aux_dsmsglog AS CHAR                                       NO-UNDO.
    DEF VAR aux_contador AS INTE                                       NO-UNDO.
    DEF VAR h-b1wgen0168 AS HANDLE                                     NO-UNDO.

    ASSIGN aux_cdcritic = 0  
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Alterar registros da tabela crapcyc.". 

    DO  aux_contador = 1 TO 10:

        FIND crapcyc WHERE crapcyc.cdcooper = par_cdcooper AND
                           crapcyc.cdorigem = par_cdorigem AND
                           crapcyc.nrctremp = par_nrctremp AND
                           crapcyc.nrdconta = par_nrdconta    
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL crapcyc THEN
			DO:
			   IF  LOCKED crapcyc THEN
			   	   DO:
			   	      IF  aux_contador = 10 THEN
                          DO:
    		   	      	     ASSIGN aux_cdcritic = 77.
                   
                             RUN gera_erro (INPUT par_cdcooper,        
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa, 
                                            INPUT 1, /* sequencia */
                                            INPUT aux_cdcritic,        
                                            INPUT-OUTPUT aux_dscritic).

                             RUN proc_gerar_log (INPUT par_cdcooper,
                                                 INPUT par_cdoperad,
                                                 INPUT aux_dscritic,
                                                 INPUT aux_dsorigem,
                                                 INPUT aux_dstransa,
                                                 INPUT FALSE,
                                                 INPUT 1,
                                                 INPUT par_nmdatela,
                                                 INPUT par_nrdconta,
                                                OUTPUT aux_nrdrowid).

                             RETURN "NOK".
                          END.
			   	      ELSE
                          DO:
                             PAUSE 1 NO-MESSAGE.
			   	      	     NEXT.
                          END.
			   	   END.
			   ELSE
    		   	   DO:
                      ASSIGN aux_cdcritic = 0
			                 aux_dscritic = "Tentativa de alterar registro " +
                                            "inexistente!".

                      RUN gera_erro (INPUT par_cdcooper,        
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT 1, /* sequencia */
                                     INPUT aux_cdcritic,        
                                     INPUT-OUTPUT aux_dscritic).
                      
                      RUN proc_gerar_log (INPUT par_cdcooper,
                                          INPUT par_cdoperad,
                                          INPUT aux_dscritic,
                                          INPUT aux_dsorigem,
                                          INPUT aux_dstransa,
                                          INPUT FALSE,
                                          INPUT 1,
                                          INPUT par_nmdatela,
                                          INPUT par_nrdconta,
                                         OUTPUT aux_nrdrowid).

                      RETURN "NOK".
    		   	   END.
			END.
		ELSE
            DO:
              FIND FIRST crapope WHERE crapope.cdcooper = par_cdcooper
                                   AND crapope.cdoperad = par_cdoperad
                                    NO-LOCK NO-ERROR.
              IF AVAIL crapope THEN
                 DO:
                   IF (crapope.cddepart <> 13) and (crapcyc.cdmotcin = 2 or crapcyc.cdmotcin = 7) and (crapcyc.cdmotcin <> par_cdmotcin) then
                     DO:
                        ASSIGN aux_cdcritic = 0
                        aux_dscritic = "Somente operadores do departamento juridico " +
                                       "podem alterar MOTIVO CIN 2 ou 7 cadastrados previamente !".
                        RUN gera_erro (INPUT par_cdcooper,        
                                   INPUT par_cdagenci,
                                   INPUT 1, /* nrdcaixa  */
                                   INPUT 1, /* sequencia */
                                   INPUT aux_cdcritic,        
                                   INPUT-OUTPUT aux_dscritic).                                            
                        RETURN "NOK".
                     END.	
                   IF (crapope.cddepart <> 13) and (par_cdmotcin = 2 or par_cdmotcin = 7) and (crapcyc.cdmotcin <> par_cdmotcin) then
                     DO:
                        ASSIGN aux_cdcritic = 0
			                   aux_dscritic = "Somente operadores do departamento juridico " +
                                              "podem alterar para MOTIVO CIN 2 e 7 !".
                        RUN gera_erro (INPUT par_cdcooper,        
                                   INPUT par_cdagenci,
                                   INPUT 1, /* nrdcaixa  */
                                   INPUT 1, /* sequencia */
                                   INPUT aux_cdcritic,        
                                   INPUT-OUTPUT aux_dscritic).                                            
						RETURN "NOK".
                    END.									
                END.   

			   ASSIGN crapcyc.flgjudic = par_flgjudic
                      crapcyc.flextjud = par_flextjud
                      crapcyc.flgehvip = par_flgehvip
                      crapcyc.cdoperad = par_cdoperad
                      crapcyc.dtaltera = par_dtmvtolt
                      crapcyc.dtenvcbr = par_dtenvcbr
                      crapcyc.cdassess = par_cdassess
                      crapcyc.cdmotcin = par_cdmotcin. 

               ASSIGN aux_dsmsglog = "Contrato: "                             +
                                      STRING(par_nrctremp,"zz,zzz,zz9")        +
                                      ". Jud.: "                              +
                                      (IF par_flgjudic THEN "Sim" ELSE "Nao") +
                                      ". Extra Jud.: "                        +
                                      (IF par_flextjud THEN "Sim" ELSE "Nao") +
                                      ". CIN: "                               +
                                      (IF par_flgehvip THEN "Sim" ELSE "Nao").

               RUN proc_gerar_log (INPUT par_cdcooper,
                                   INPUT par_cdoperad,
                                   INPUT aux_dsmsglog,
                                   INPUT aux_dsorigem,
                                   INPUT aux_dstransa,
                                   INPUT TRUE,
                                   INPUT 1,
                                   INPUT par_nmdatela,
                                   INPUT par_nrdconta,
                                  OUTPUT aux_nrdrowid).

               /* INICIO - Atualizar os dados da tabela crapcyb (CYBER) */
               IF NOT VALID-HANDLE(h-b1wgen0168) THEN
                  RUN sistema/generico/procedures/b1wgen0168.p
                      PERSISTENT SET h-b1wgen0168.
                            
               EMPTY TEMP-TABLE tt-crapcyb.
              
               CREATE tt-crapcyb.
               ASSIGN tt-crapcyb.cdcooper = par_cdcooper
                      tt-crapcyb.nrdconta = par_nrdconta
                      tt-crapcyb.dtmancad = par_dtmvtolt.
              
               RUN atualiza_data_manutencao_cadastro
                   IN h-b1wgen0168(INPUT TABLE tt-crapcyb,
                                   OUTPUT aux_cdcritic,
                                   OUTPUT aux_dscritic).
                            
               IF VALID-HANDLE(h-b1wgen0168) THEN
                  DELETE PROCEDURE(h-b1wgen0168).
    
               LEAVE.
            END.
    END.
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE excluir-dados-crapcyc:

    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrborder AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrtitulo AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdorigem AS INTE                               NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    DEF VAR aux_flgerlog AS LOG INIT FALSE                             NO-UNDO.
    DEF VAR aux_contador AS INTE                                       NO-UNDO.

    ASSIGN aux_cdcritic = 0  
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = STRING(par_nrctremp,"99999999") + 
                          " - Exluir registro para tela CADCYB.". 

    DO  aux_contador = 1 TO 10:

        FIND crapcyc WHERE crapcyc.cdcooper = par_cdcooper AND
                           crapcyc.cdorigem = par_cdorigem AND
                           crapcyc.nrctremp = par_nrctremp AND
                           crapcyc.nrdconta = par_nrdconta    
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        IF  NOT AVAIL crapcyc THEN
			DO:
			   IF  LOCKED crapcyc THEN
			   	   DO:
			   	      IF  aux_contador = 10 THEN
                          DO:
    		   	      	     ASSIGN aux_cdcritic = 77.
                   
                             RUN gera_erro (INPUT par_cdcooper,        
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa, 
                                            INPUT 1, /* sequencia */
                                            INPUT aux_cdcritic,        
                                            INPUT-OUTPUT aux_dscritic).

                             RUN proc_gerar_log (INPUT par_cdcooper,
                                                 INPUT par_cdoperad,
                                                 INPUT aux_dscritic,
                                                 INPUT aux_dsorigem,
                                                 INPUT aux_dstransa,
                                                 INPUT FALSE,
                                                 INPUT 1,
                                                 INPUT par_nmdatela,
                                                 INPUT par_nrdconta,
                                                OUTPUT aux_nrdrowid).

                             RETURN "NOK".
                          END.
			   	      ELSE
                          DO:
                             PAUSE 1 NO-MESSAGE.
			   	      	     NEXT.
                          END.
			   	   END.
			   ELSE
    		   	   DO:
                      ASSIGN aux_cdcritic = 0
			                 aux_dscritic = "Tentativa de excluir registro " +
                                            "inexistente!".

                      RUN gera_erro (INPUT par_cdcooper,        
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT 1, /* sequencia */
                                     INPUT aux_cdcritic,        
                                     INPUT-OUTPUT aux_dscritic).

                      RUN proc_gerar_log (INPUT par_cdcooper,
                                          INPUT par_cdoperad,
                                          INPUT aux_dscritic,
                                          INPUT aux_dsorigem,
                                          INPUT aux_dstransa,
                                          INPUT FALSE,
                                          INPUT 1,
                                          INPUT par_nmdatela,
                                          INPUT par_nrdconta,
                                         OUTPUT aux_nrdrowid).

                      RETURN "NOK".
    		   	   END.
			END.
		ELSE
            DO:

			  FIND FIRST crapope WHERE crapope.cdcooper = par_cdcooper
                                   AND crapope.cdoperad = par_cdoperad
                                   NO-LOCK NO-ERROR.

              IF AVAIL crapope THEN
			  DO:
                IF (crapope.cddepart <> 13) and (crapcyc.cdmotcin = 2 or crapcyc.cdmotcin = 7) then
                DO:
				  ASSIGN aux_cdcritic = 0
			             aux_dscritic = "Somente operadores do departamento juridico " +
                                        "podem excluir registros com MOTIVO CIN 2 ou 7 !".
                
				  RUN gera_erro (INPUT par_cdcooper,        
                                 INPUT par_cdagenci,
                                 INPUT 1, /* nrdcaixa  */
                                 INPUT 1, /* sequencia */
                                 INPUT aux_cdcritic,        
                                 INPUT-OUTPUT aux_dscritic).                                            

			      RETURN "NOK".
   		        END.	
              END.  

			   DELETE crapcyc.
               ASSIGN aux_flgerlog = TRUE.
               LEAVE.
            END.
    END.
    
    /* Registra em log a exclusao do registro */
    IF  aux_flgerlog THEN
        DO:
            ASSIGN aux_dscritic = "Exclusao de registro para tela crapcyc.".

            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT aux_dscritic,
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT 1,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE consulta-dados-crapcyc:

    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrctremp AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdorigem AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdassess AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdmotcin AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrborder AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrtitulo AS INTE                               NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapcyc.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    

    DEF VAR aux_dscritic AS CHAR                                       NO-UNDO.
    DEF VAR aux_nrregist AS INTE                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    DEF VAR aux_flgretur AS LOG INIT FALSE                             NO-UNDO.
    DEF VAR aux_contador AS INTE                                       NO-UNDO.
    DEF VAR aux_dsorigem AS CHAR                                       NO-UNDO.

    DEF VAR aux_nmoperad AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmopeinc AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmassess AS CHAR                                       NO-UNDO.
    DEF VAR aux_dsmotcin AS CHAR                                       NO-UNDO.

    DEF VAR aux_nrborder AS INTE                                       NO-UNDO.
    DEF VAR aux_nrtitulo AS INTE                                       NO-UNDO.
    DEF VAR aux_nrctrdsc AS INTE                                       NO-UNDO.
    DEF VAR aux_nrdocmto AS INTE                                       NO-UNDO.
 
    ASSIGN aux_nrregist = par_nrregist.

    IF  par_nrdconta > 0 THEN
        DO:  
            IF  aux_nrregist > 0 THEN
                DO: 
                    /*** Traz registro especifico ***/
                    FOR EACH crapcyc WHERE crapcyc.cdcooper = par_cdcooper 
                                       AND crapcyc.cdorigem = par_cdorigem 
                                       AND crapcyc.nrdconta = par_nrdconta 
                                       AND (IF par_nrctremp > 0 THEN
                                               crapcyc.nrctremp = par_nrctremp
                                            ELSE
                                               crapcyc.nrctremp > 0)
                                       /* Realizar a pesquisa pelo código de assessoria quando informado */
                                       AND (IF par_cdassess > 0 THEN
                                               crapcyc.cdassess = par_cdassess
                                            ELSE
                                               crapcyc.cdassess >= 0)
                                       /* Realziar a pesquisa pelo código de motivo CIN quando informado */ 
                                       AND (IF par_cdmotcin > 0 THEN
                                               crapcyc.cdmotcin = par_cdmotcin
                                            ELSE
                                               crapcyc.cdmotcin >= 0)
                                     NO-LOCK:
                    
                        IF  crapcyc.cdorigem = 1 THEN
                            ASSIGN aux_dsorigem = "Conta".
                        ELSE
                        IF  crapcyc.cdorigem = 3 THEN
                            ASSIGN aux_dsorigem = "Emprestimo".
                        ELSE
                          DO:
                            ASSIGN aux_dsorigem = "Desconto de Titulo"
                                   aux_nrctrdsc = crapcyc.nrctremp.

                            FIND FIRST tbdsct_titulo_cyber WHERE tbdsct_titulo_cyber.cdcooper = par_cdcooper
                                                             AND tbdsct_titulo_cyber.nrdconta = par_nrdconta
                                                             AND tbdsct_titulo_cyber.nrctrdsc = aux_nrctrdsc
                                                             AND (IF par_nrborder > 0 THEN
                                                                     tbdsct_titulo_cyber.nrborder = par_nrborder
                                                                                                  ELSE
                                                                                                     tbdsct_titulo_cyber.nrborder > 0)
                                                                                             AND (IF par_nrtitulo > 0 THEN 
                                                                                                     tbdsct_titulo_cyber.nrtitulo = par_nrtitulo
                                                                                                  ELSE
                                                                                                     tbdsct_titulo_cyber.nrtitulo > 0)
                                                          NO-LOCK NO-ERROR.

                            IF NOT AVAIL tbdsct_titulo_cyber THEN
                              NEXT.

                            FIND FIRST craptdb WHERE craptdb.cdcooper = par_cdcooper
                                                 AND craptdb.nrdconta = par_nrdconta
                                                 AND craptdb.nrborder = tbdsct_titulo_cyber.nrborder
                                                 AND craptdb.nrtitulo = tbdsct_titulo_cyber.nrtitulo
                                                            NO-LOCK NO-ERROR.
                            IF NOT AVAIL craptdb THEN
                              NEXT.
                          END.
                        ASSIGN par_qtregist = par_qtregist + 1
                               aux_nmoperad = ""
                               aux_nmopeinc = ""
                               aux_nmassess = ""
                               aux_dsmotcin = "".

                        IF  (par_qtregist < par_nriniseq) OR
                            (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                            NEXT.

                        FIND FIRST crapope WHERE crapope.cdcooper = crapcyc.cdcooper
                                             AND crapope.cdoperad = crapcyc.cdoperad
                                           NO-LOCK NO-ERROR.
                        IF AVAIL crapope THEN
                            ASSIGN aux_nmoperad = crapope.cdoperad + " - " +
                                                  crapope.nmoperad.

                        FIND FIRST crapope WHERE crapope.cdcooper = crapcyc.cdcooper
                                             AND crapope.cdoperad = crapcyc.cdopeinc
                                           NO-LOCK NO-ERROR.
                        IF AVAIL crapope THEN
                            ASSIGN aux_nmopeinc = crapope.cdoperad + " - " +
                                                  crapope.nmoperad.

                        FIND FIRST tbcobran_assessorias 
                             WHERE tbcobran_assessorias.cdassessoria = crapcyc.cdassess
                             NO-LOCK NO-ERROR.
                        IF AVAIL tbcobran_assessorias THEN
                            ASSIGN aux_nmassess = STRING(tbcobran_assessorias.cdassessoria, "zzzz9") + " - " +
                                                  tbcobran_assessorias.nmassessoria.

                        FIND FIRST tbcobran_motivos_cin
                             WHERE tbcobran_motivos_cin.cdmotivo = crapcyc.cdmotcin
                             NO-LOCK NO-ERROR.
                        IF AVAIL tbcobran_motivos_cin THEN
                            ASSIGN aux_dsmotcin = STRING(tbcobran_motivos_cin.cdmotivo, "zz9") + " - " +
                                                  tbcobran_motivos_cin.dsmotivo.
                        
                        CREATE tt-crapcyc.
                        ASSIGN tt-crapcyc.cdcooper = crapcyc.cdcooper
                               tt-crapcyc.cdorigem = crapcyc.cdorigem
                               tt-crapcyc.nrdconta = crapcyc.nrdconta
                               tt-crapcyc.nrctremp = crapcyc.nrctremp
                               tt-crapcyc.dsorigem = aux_dsorigem
                               tt-crapcyc.flgjudic = STRING(crapcyc.flgjudic,
                                                            "Sim/Nao")
                               tt-crapcyc.flextjud = STRING(crapcyc.flextjud,
                                                            "Sim/Nao")
                               tt-crapcyc.flgehvip = STRING(crapcyc.flgehvip,
                                                            "Sim/Nao")
                               tt-crapcyc.dtenvcbr = crapcyc.dtenvcbr
                               tt-crapcyc.dtinclus = crapcyc.dtinclus
                               tt-crapcyc.cdoperad = aux_nmoperad
                               tt-crapcyc.cdopeinc = aux_nmopeinc
                               tt-crapcyc.dtaltera = crapcyc.dtaltera
                               tt-crapcyc.nmassess = aux_nmassess
                               tt-crapcyc.dsmotcin = aux_dsmotcin
                               tt-crapcyc.nrborder = tbdsct_titulo_cyber.nrborder
                               tt-crapcyc.nrtitulo = tbdsct_titulo_cyber.nrtitulo
                               tt-crapcyc.nrdocmto = craptdb.nrdocmto.

                    END.                   
                END.

                ASSIGN aux_nrregist = aux_nrregist - 1.                
        END.                                       
    ELSE
        DO: 
            IF  aux_nrregist > 0 THEN
                DO: 
                    
                   /*** Traz todos os registros de cada origem selecionada ***/
                    FOR EACH crapcyc WHERE crapcyc.cdcooper = par_cdcooper 
                                       AND crapcyc.cdorigem = par_cdorigem 
                                       AND crapcyc.nrdconta > 0 
                                       /* Realizar a pesquisa pelo código de assessoria quando informado */
                                       AND (IF par_cdassess > 0 THEN
                                               crapcyc.cdassess = par_cdassess
                                            ELSE
                                               crapcyc.cdassess >= 0)
                                       /* Realziar a pesquisa pelo código de motivo CIN quando informado */ 
                                       AND (IF par_cdmotcin > 0 THEN
                                               crapcyc.cdmotcin = par_cdmotcin
                                            ELSE
                                               crapcyc.cdmotcin >= 0)
                                     NO-LOCK:

                        IF  crapcyc.cdorigem = 1 THEN
                            ASSIGN aux_dsorigem = "Conta".
                        ELSE
                        IF  crapcyc.cdorigem = 3 THEN
                            ASSIGN aux_dsorigem = "Emprestimo".
                        ELSE
                          DO:
                            ASSIGN aux_dsorigem = "Desconto de Titulo".
                                   aux_nrctrdsc = crapcyc.nrctremp.

                            FIND FIRST tbdsct_titulo_cyber WHERE tbdsct_titulo_cyber.cdcooper = par_cdcooper
                                                             AND tbdsct_titulo_cyber.nrdconta = crapcyc.nrdconta
                                                             AND tbdsct_titulo_cyber.nrctrdsc = aux_nrctrdsc
                                                             AND (IF par_nrborder > 0 THEN
                                                                     tbdsct_titulo_cyber.nrborder = par_nrborder
                                                                  ELSE
                                                                     tbdsct_titulo_cyber.nrborder > 0)
                                                             AND (IF par_nrtitulo > 0 THEN 
                                                                     tbdsct_titulo_cyber.nrtitulo = par_nrtitulo
                                                                  ELSE
                                                                     tbdsct_titulo_cyber.nrtitulo > 0)
                                                          NO-LOCK NO-ERROR.

                            IF NOT AVAIL tbdsct_titulo_cyber THEN
                                NEXT. 
                                   
                            FIND FIRST craptdb WHERE craptdb.cdcooper = par_cdcooper
                                                 AND craptdb.nrdconta = crapcyc.nrdconta
                                                 AND craptdb.nrborder = tbdsct_titulo_cyber.nrborder
                                                 AND craptdb.nrtitulo = tbdsct_titulo_cyber.nrtitulo
                                                            NO-LOCK NO-ERROR.
                            IF NOT AVAIL craptdb THEN
                              NEXT.       
                          END.
                        
                        ASSIGN par_qtregist = par_qtregist + 1
                               aux_nmoperad = ""
                               aux_nmopeinc = ""
                               aux_nmassess = ""
                               aux_dsmotcin = "".
                        
                        /* controles da paginaçao */
                        IF  (par_qtregist < par_nriniseq) OR
                            (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                            NEXT.
                    
                        FIND FIRST crapope WHERE crapope.cdcooper = crapcyc.cdcooper
                                             AND crapope.cdoperad = crapcyc.cdoperad
                                           NO-LOCK NO-ERROR.
                        IF AVAIL crapope THEN
                            ASSIGN aux_nmoperad = crapope.cdoperad + " - " +
                                                  crapope.nmoperad.

                        FIND FIRST crapope WHERE crapope.cdcooper = crapcyc.cdcooper
                                             AND crapope.cdoperad = crapcyc.cdopeinc
                                           NO-LOCK NO-ERROR.
                        IF AVAIL crapope THEN
                            ASSIGN aux_nmopeinc = crapope.cdoperad + " - " +
                                                  crapope.nmoperad.
                        
                        FIND FIRST tbcobran_assessorias
                             WHERE tbcobran_assessorias.cdassessoria = crapcyc.cdassess
                             NO-LOCK NO-ERROR.
                        IF AVAIL tbcobran_assessorias THEN
                            ASSIGN aux_nmassess = STRING(tbcobran_assessorias.cdassessoria, "zzzz9") + " - " +
                                                  tbcobran_assessorias.nmassessoria.

                        FIND FIRST tbcobran_motivos_cin
                             WHERE tbcobran_motivos_cin.cdmotivo = crapcyc.cdmotcin
                             NO-LOCK NO-ERROR.
                        IF AVAIL tbcobran_motivos_cin THEN
                            ASSIGN aux_dsmotcin = STRING(tbcobran_motivos_cin.cdmotivo, "zz9") + " - " +
                                                  tbcobran_motivos_cin.dsmotivo.
                        
                        CREATE tt-crapcyc.
                        ASSIGN tt-crapcyc.cdcooper = crapcyc.cdcooper
                               tt-crapcyc.cdorigem = crapcyc.cdorigem
                               tt-crapcyc.nrdconta = crapcyc.nrdconta
                               tt-crapcyc.nrctremp = crapcyc.nrctremp
                               tt-crapcyc.dsorigem = aux_dsorigem
                               tt-crapcyc.flgjudic = STRING(crapcyc.flgjudic,
                                                            "Sim/Nao")
                               tt-crapcyc.flextjud = STRING(crapcyc.flextjud,
                                                            "Sim/Nao")
                               tt-crapcyc.flgehvip = STRING(crapcyc.flgehvip,
                                                            "Sim/Nao")
                               tt-crapcyc.dtenvcbr = crapcyc.dtenvcbr
                               tt-crapcyc.dtinclus = crapcyc.dtinclus
                               tt-crapcyc.cdoperad = aux_nmoperad
                               tt-crapcyc.cdopeinc = aux_nmopeinc
                               tt-crapcyc.dtaltera = crapcyc.dtaltera
                               tt-crapcyc.nmassess = aux_nmassess
                               tt-crapcyc.dsmotcin = aux_dsmotcin
                               tt-crapcyc.nrborder = tbdsct_titulo_cyber.nrborder
                               tt-crapcyc.nrtitulo = tbdsct_titulo_cyber.nrtitulo
                               tt-crapcyc.nrdocmto = craptdb.nrdocmto.
                    END.
                END.
                
                ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

    RETURN "OK".   

END PROCEDURE.


PROCEDURE importa-dados-crapcyc:

    DEF INPUT PARAM par_cdcooper AS INTE                                  NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                                  NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                                  NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                                  NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                                  NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                                  NO-UNDO.
    DEF INPUT PARAM par_nmarquiv AS CHAR                                  NO-UNDO.
    DEF INPUT PARAM par_dsdircop AS CHAR                                  NO-UNDO. 
    DEF INPUT PARAM par_dtmvtolt AS DATE                                  NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    
    DEF VAR aux_flgjudic AS LOG                                           NO-UNDO.
    DEF VAR aux_flextjud AS LOG                                           NO-UNDO.
    DEF var aux_flgehvip AS LOG                                           NO-UNDO.
    DEF VAR aux_nrdconta AS INTE                                          NO-UNDO.
    DEF VAR aux_nrctremp AS INTE                                          NO-UNDO.
    DEF VAR aux_nrborder AS INTE                                          NO-UNDO.
    DEF VAR aux_nrtitulo AS INTE                                          NO-UNDO.
    DEF VAR aux_nrdocmto AS INTE                                          NO-UNDO.
    DEF VAR aux_cdorigem AS INTE                                          NO-UNDO.
    DEF VAR aux_cdcooper AS INTE                                          NO-UNDO.
    DEF VAR aux_counttdb AS INTE                                          NO-UNDO.
    DEF VAR aux_flgerro  AS LOG                                           NO-UNDO.
    DEF VAR aux_linhaarq AS CHAR                                          NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                                          NO-UNDO.
    DEF VAR aux_filename AS CHAR                                          NO-UNDO.
    DEF VAR aux_dsdircop AS CHAR                                          NO-UNDO.
    DEF VAR aux_registro AS CHAR                                          NO-UNDO.  
    
    DEF VAR aux_dsorigem AS CHAR                                          NO-UNDO.  
    DEF VAR aux_dstransa AS CHAR                                          NO-UNDO.  
    DEF VAR aux_dsmsglog AS CHAR                                          NO-UNDO.

    DEF VAR aux_contador AS INTE                                          NO-UNDO.

    DEF VAR aux_dtenvcbr AS DATE                                          NO-UNDO.
    DEF VAR aux_cdassess AS INTE                                          NO-UNDO.
    DEF VAR aux_cdmotcin AS INTE                                          NO-UNDO.
    DEF VAR h-b1wgen0168 AS HANDLE                                        NO-UNDO.

    ASSIGN aux_dsdircop = "/micros/" + par_dsdircop + "/cadcyb/" + par_dsdircop + ".err"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Importar arquivo CSV de contas para o CYBER.".

    IF SEARCH(par_nmarquiv) = ? THEN
     DO:
       aux_dscritic = "Arquivo nao localizado em: " + par_nmarquiv.

       RUN gera_erro (INPUT par_cdcooper,        
                      INPUT par_cdagenci,
                      INPUT 1, /* nrdcaixa  */
                      INPUT 1, /* sequencia */
                      INPUT aux_cdcritic,        
                      INPUT-OUTPUT aux_dscritic).
       
       RUN proc_gerar_log (INPUT par_cdcooper,
                           INPUT par_cdoperad,
                           INPUT aux_dscritic,
                           INPUT aux_dsorigem,
                           INPUT aux_dstransa,
                           INPUT TRUE,
                           INPUT 1,
                           INPUT par_nmdatela,
                           INPUT aux_nrdconta,
                          OUTPUT aux_nrdrowid).

       RETURN "NOK".

    END.

    INPUT STREAM str_1 FROM VALUE(par_nmarquiv) NO-ECHO.
    OUTPUT STREAM str_2 TO VALUE (aux_dsdircop).

    ASSIGN aux_flgerro = FALSE.

    importa_arquivo:         
 /*   DO TRANSACTION ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE: */

        /* Processamento do arquivo a ser importado */
        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:   
                   
           IMPORT STREAM str_1 UNFORMATTED aux_linhaarq. 

           /* formato da linha do arquivo: 
           No Coop, Nome Coop.,	Origem,	No Conta, No Contrato,	Judicial, Extrajudicial,	CIN, Data Cobrança Assessoria, Codigo assessoria, Codigo Motivo CIN */
           ASSIGN aux_cdcooper = INTE( ENTRY(1, aux_linhaarq, ";") )
                  aux_cdorigem = INTE( ENTRY(3, aux_linhaarq, ";") )
                  aux_nrdconta = INTE( ENTRY(4, aux_linhaarq, ";") )
                  aux_nrctremp = INTE( ENTRY(5, aux_linhaarq, ";") )
                  aux_flgjudic = IF ENTRY(6, aux_linhaarq, ";") = "S" THEN TRUE ELSE FALSE
                  aux_flextjud = IF ENTRY(7, aux_linhaarq, ";") = "S" THEN TRUE ELSE FALSE
                  aux_flgehvip = IF ENTRY(8, aux_linhaarq, ";") = "S" THEN TRUE ELSE FALSE 
                  aux_dtenvcbr = DATE( ENTRY(9, aux_linhaarq, ";") )
                  aux_cdassess = INTE( ENTRY(10, aux_linhaarq, ";") )
                  aux_cdmotcin = INTE( ENTRY(11, aux_linhaarq, ";") ) 
                  aux_nrborder = IF INTE( ENTRY(12, aux_linhaarq, ";") ) > 0 THEN INTE( ENTRY(12, aux_linhaarq, ";") ) ELSE 0
                  aux_nrdocmto = IF INTE( ENTRY(13, aux_linhaarq, ";") ) > 0 THEN INTE( ENTRY(13, aux_linhaarq, ";") ) ELSE 0
                NO-ERROR.

           IF ERROR-STATUS:ERROR THEN DO:
               PUT STREAM str_2 UNFORMATTED "Erro na estrutura da linha: " +
                                             aux_linhaarq SKIP.
               ASSIGN aux_flgerro = TRUE.
               NEXT.
           END.
           
           /* Validar se eh vip, e caso nao seja eliminar o motivo CIN*/
           IF NOT aux_flgehvip THEN DO:
               ASSIGN aux_cdmotcin = 0.
           END.

           ASSIGN aux_registro = " Origem:   "   + STRING(aux_cdorigem, "9")            +
                                 " Conta:    "   + STRING(aux_nrdconta, "zzzz,zzz,9")   +
                                 " Contrato: "   + STRING(aux_nrctremp, "zz,zzz,zz9")   +
                                 " Bordero:  "   + STRING(aux_nrborder, "zzzz9")   +
                                 " Titulo:   "   + STRING(aux_nrdocmto, "zz9")   +
                                 " Judicial: "   + IF aux_flgjudic THEN "S" ELSE "N"    +
                                 " Extrajud: "   + IF aux_flextjud THEN "S" ELSE "N"    +
                                 " CIN:      "   + IF aux_flgehvip THEN "S" ELSE "N"    +
                                 " Data Assessoria Cobranca: " + STRING(aux_dtenvcbr, "99/99/9999") + 
                                 " Assessoria: " + STRING(aux_cdassess, "zzzz9")        +
                                 " Motivo Cin: " + STRING(aux_cdmotcin, "zz9").
    
           IF aux_cdcooper <> par_cdcooper THEN DO:
                PUT STREAM str_2 UNFORMATTED "Registro nao pertence a cooperativa processada. - " +
                                              aux_registro SKIP.
                ASSIGN aux_flgerro = TRUE.
                NEXT.
           END.
		   
		   /* P437 - Consignado - Motivo 8 Repasse Consignado é utilizado apenas pela tela CONSIG, quando Interromper da Cobrança da Empresa */
		   IF aux_cdmotcin = 8 THEN DO:
                PUT STREAM str_2 UNFORMATTED "Motivo 8 Repasse Consignado exclusivo para utilizacao do sistema. - " +
                                              aux_registro SKIP.
                ASSIGN aux_flgerro = TRUE.
                NEXT.
           END.

           IF aux_cdorigem <> 1 AND
              aux_cdorigem <> 3 AND 
              aux_cdorigem <> 4 THEN DO:
                PUT STREAM str_2 UNFORMATTED "Origem informada invalida: " +
                                              aux_registro SKIP.
                ASSIGN aux_flgerro = TRUE.
                NEXT.
           END.

           FOR FIRST crapass FIELDS(nrdconta)
               WHERE crapass.cdcooper = aux_cdcooper 
                 AND crapass.nrdconta = aux_nrdconta   
                 NO-LOCK: END.
                
           IF  NOT AVAIL crapass THEN
               DO:
                   PUT STREAM str_2 UNFORMATTED "Conta nao encontrada. - " +
                                              aux_registro SKIP.
                   ASSIGN aux_flgerro = TRUE.
                   NEXT.
               END.
           
           IF  aux_cdorigem = 3 THEN
               DO:
                   FOR FIRST crapepr FIELDS(nrctremp)
                       WHERE crapepr.cdcooper = aux_cdcooper 
                         AND crapepr.nrdconta = aux_nrdconta 
                         AND crapepr.nrctremp = aux_nrctremp
                         NO-LOCK: END.
                                  
                   IF  NOT AVAIL crapepr THEN
                       DO:
                          PUT STREAM str_2 UNFORMATTED "Contrato nao localizado. - " +
                                              aux_registro SKIP.
                          ASSIGN aux_flgerro = TRUE.
                          NEXT.
                       END.
               END.
            ELSE
                IF aux_cdorigem = 4 THEN
                    DO:
                        /* Verifica se o bordero e o titulo foram preenchidos */
                        IF aux_nrborder = 0 OR aux_nrdocmto = 0 THEN
                            DO:
                                 PUT STREAM str_2 UNFORMATTED "Bordero e Titulo deve ser preenchido. - " +
                                                                                        aux_registro SKIP.
                                   ASSIGN aux_flgerro = TRUE.
                                   NEXT.
                            END.
                        /* verifica a existencia do bordero */       
                        FIND FIRST crapbdt WHERE 
                                    crapbdt.cdcooper = aux_cdcooper AND
                                    crapbdt.nrdconta = aux_nrdconta AND 
                                    crapbdt.nrborder = aux_nrborder
                                    NO-LOCK NO-ERROR NO-WAIT.

                         IF  NOT AVAIL crapbdt THEN
                             DO:
                                PUT STREAM str_2 UNFORMATTED "Bordero nao encontrado. - " +
                                                                                    aux_registro SKIP.
                                ASSIGN aux_flgerro = TRUE.
                                NEXT.
                             END.
                             
                        /* Zera o contador de resultados da TDB */    
                        ASSIGN aux_counttdb = 0.

                        /* Verifica a existencia do titulo */
                        FOR EACH craptdb WHERE 
                                  craptdb.cdcooper = aux_cdcooper AND
                                  craptdb.nrdconta = aux_nrdconta AND 
                                  craptdb.nrborder = aux_nrborder AND
                                  craptdb.nrdocmto = aux_nrdocmto
                                NO-LOCK:
                            /* Coloca o valor do nrtitulo */
                            ASSIGN aux_nrtitulo = craptdb.nrtitulo.
                            ASSIGN aux_counttdb = aux_counttdb + 1.
                        END.

                        IF aux_counttdb = 0 THEN
                            DO:
                              PUT STREAM str_2 UNFORMATTED "Titulo nao encontrado. - " +
                                                                                  aux_registro SKIP.
                              ASSIGN aux_flgerro = TRUE.
                              NEXT.
                            END.
                            
                        /* Caso tenha mais de um resultado, coloca crítica e não importa */
                        IF aux_counttdb > 1 THEN
                          DO:
                            PUT STREAM str_2 UNFORMATTED "Mais de um titulo encontrado, fazer importacao manual. - " +
                                                                                    aux_registro SKIP.
                            ASSIGN aux_flgerro = TRUE.
                            NEXT.
                          END.
                        ELSE  

                        /* Verifica se já está inserido na tabela de titulos da Cyber */
                        FIND FIRST tbdsct_titulo_cyber WHERE tbdsct_titulo_cyber.cdcooper = aux_cdcooper AND
                                                             tbdsct_titulo_cyber.nrdconta = aux_nrdconta AND
                                                             tbdsct_titulo_cyber.nrtitulo = aux_nrtitulo AND
                                                             tbdsct_titulo_cyber.nrborder = aux_nrborder AND
                                                             tbdsct_titulo_cyber.nrctrdsc = aux_nrctremp
                                                        NO-LOCK NO-ERROR.
                        /* Caso nao exista, insere um novo e atribui o valor de contrato */                                                        
                        IF NOT AVAIL(tbdsct_titulo_cyber) THEN
                            DO:
                                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                                RUN STORED-PROCEDURE pc_inserir_titulo_cyber
                                    aux_handproc = PROC-HANDLE NO-ERROR (INPUT aux_cdcooper
                                                                        ,INPUT aux_nrdconta
                                                                        ,INPUT aux_nrborder
                                                                        ,INPUT aux_nrtitulo
                                                                        ,OUTPUT 0 
                                                                        ,OUTPUT "").

                                CLOSE STORED-PROC pc_inserir_titulo_cyber
                                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                                ASSIGN aux_dscritic  = pc_inserir_titulo_cyber.pr_dscritic WHEN pc_inserir_titulo_cyber.pr_dscritic <> ?.
                                IF aux_dscritic <> "" THEN
                                    DO:
                                        PUT STREAM str_2 UNFORMATTED aux_dscritic + " - " +
                                                                                            aux_registro SKIP.
                                        ASSIGN aux_flgerro = TRUE.
                                        NEXT.
                                    END.
                                /* Substitui o numero do contrato de emprestimo com o sequencial especifico do desconto de titulos */
                                ASSIGN aux_nrctremp = INT(pc_inserir_titulo_cyber.pr_nrctrdsc).
                            END.
                    END.
           FOR FIRST crapcyc FIELD(flgjudic flgehvip flextjud 
                                   dtenvcbr cdassess cdmotcin)
               WHERE crapcyc.cdcooper = aux_cdcooper 
                 AND crapcyc.cdorigem = aux_cdorigem 
                 AND crapcyc.nrdconta = aux_nrdconta 
                 AND crapcyc.nrctremp = aux_nrctremp 
                 NO-LOCK: END.
            
           IF  NOT AVAIL crapcyc THEN
               DO:
                  CREATE crapcyc.
                  ASSIGN crapcyc.cdcooper = aux_cdcooper
                         crapcyc.nrdconta = aux_nrdconta
                         crapcyc.nrctremp = aux_nrctremp
                         crapcyc.cdorigem = aux_cdorigem
                         crapcyc.flgjudic = aux_flgjudic
                         crapcyc.flextjud = aux_flextjud                         
                         crapcyc.flgehvip = aux_flgehvip
                         crapcyc.cdoperad = par_cdoperad
                         crapcyc.dtinclus = par_dtmvtolt
                         crapcyc.cdopeinc = par_cdoperad
                         crapcyc.dtaltera = par_dtmvtolt
                         crapcyc.dtenvcbr = aux_dtenvcbr
                         crapcyc.cdassess = aux_cdassess
                         crapcyc.cdmotcin = aux_cdmotcin.
                  
                  ASSIGN aux_dsmsglog = "Contrato: "                             +
                         STRING(aux_nrctremp,"zz,zzz,zz9")        +
                         ". Jud.: "                              +
                         (IF aux_flgjudic THEN "Sim" ELSE "Nao") +
                         ". Extra Jud.: "                        +
                         (IF aux_flextjud THEN "Sim" ELSE "Nao") +
                         ". CIN: "                               +
                         (IF aux_flgehvip THEN "Sim" ELSE "Nao").
                  
                  RUN proc_gerar_log (INPUT par_cdcooper,
                                      INPUT par_cdoperad,
                                      INPUT aux_dsmsglog,
                                      INPUT aux_dsorigem,
                                      INPUT aux_dstransa,
                                      INPUT TRUE,
                                      INPUT 1,
                                      INPUT par_nmdatela,
                                      INPUT aux_nrdconta,
                                     OUTPUT aux_nrdrowid).

                  VALIDATE crapcyc.
               END.
          ELSE
              DO:
                   
                IF (aux_flgjudic <> crapcyc.flgjudic) OR
                   (aux_flgehvip <> crapcyc.flgehvip) OR
                   (aux_flextjud <> crapcyc.flextjud) OR
                   (aux_dtenvcbr <> crapcyc.dtenvcbr) OR
                   (aux_cdassess <> crapcyc.cdassess) OR
                   (aux_cdmotcin <> crapcyc.cdmotcin) THEN
                DO:

                   ASSIGN aux_contador = 0.

                   DO WHILE TRUE:
                    
                       FOR FIRST crapcyc FIELD(flgjudic flgehvip flextjud 
                                               dtenvcbr cdassess cdmotcin)
                           WHERE crapcyc.cdcooper = aux_cdcooper 
                             AND crapcyc.cdorigem = aux_cdorigem 
                             AND crapcyc.nrdconta = aux_nrdconta 
                             AND crapcyc.nrctremp = aux_nrctremp 
                             EXCLUSIVE-LOCK: END.
    
    
                       IF NOT AVAIL crapcyc THEN DO:
    
                          IF LOCKED craplot THEN DO:
                                    
                             ASSIGN aux_contador = aux_contador + 1.
                
                             IF  aux_contador = 10  THEN DO:
        
                                PUT STREAM str_2 UNFORMATTED "Erro ao Atualizar CRAPCYC. - " +
                                              aux_registro SKIP.
                                ASSIGN aux_flgerro = TRUE.
                                LEAVE.
                             END.
                
                             PAUSE 1 NO-MESSAGE.
                             NEXT.
                          END.

                       END.
                       ELSE DO:
                            ASSIGN crapcyc.flgjudic = aux_flgjudic
                                   crapcyc.flextjud = aux_flextjud                         
                                   crapcyc.flgehvip = aux_flgehvip
                                   crapcyc.cdoperad = par_cdoperad
                                   crapcyc.dtaltera = par_dtmvtolt
                                   crapcyc.dtenvcbr = aux_dtenvcbr
                                   crapcyc.cdassess = aux_cdassess
                                   crapcyc.cdmotcin = aux_cdmotcin.
                            
                            ASSIGN aux_dsmsglog = "Contrato: "                             +
                                   STRING(aux_nrctremp,"zz,zzz,zz9")        +
                                   ". Jud.: "                              +
                                   (IF aux_flgjudic THEN "Sim" ELSE "Nao") +
                                   ". Extra Jud.: "                        +
                                   (IF aux_flextjud THEN "Sim" ELSE "Nao") +
                                   ". CIN: "                               +
                                   (IF aux_flgehvip THEN "Sim" ELSE "Nao").
                            
                            RUN proc_gerar_log (INPUT par_cdcooper,
                                                INPUT par_cdoperad,
                                                INPUT aux_dsmsglog,
                                                INPUT aux_dsorigem,
                                                INPUT aux_dstransa,
                                                INPUT TRUE,
                                                INPUT 1,
                                                INPUT par_nmdatela,
                                                INPUT aux_nrdconta,
                                               OUTPUT aux_nrdrowid).

                            /* INICIO - Atualizar os dados da tabela crapcyb (CYBER) */
                           IF NOT VALID-HANDLE(h-b1wgen0168) THEN
                              RUN sistema/generico/procedures/b1wgen0168.p
                                  PERSISTENT SET h-b1wgen0168.
                                        
                           EMPTY TEMP-TABLE tt-crapcyb.
                          
                           CREATE tt-crapcyb.
                           ASSIGN tt-crapcyb.cdcooper = par_cdcooper
                                  tt-crapcyb.nrdconta = aux_nrdconta
                                  tt-crapcyb.dtmancad = par_dtmvtolt.
                          
                           RUN atualiza_data_manutencao_cadastro
                               IN h-b1wgen0168(INPUT TABLE tt-crapcyb,
                                               OUTPUT aux_cdcritic,
                                               OUTPUT aux_dscritic).
                                        
                           IF VALID-HANDLE(h-b1wgen0168) THEN
                              DELETE PROCEDURE(h-b1wgen0168).
                       END.

                       LEAVE.
    
                    END.

                END. /* IF */ 
              END. /* Else */
    
           NEXT.
    
        END.  /*
END. /* DO TRANSACTION */ */

    INPUT STREAM str_1 CLOSE.
    OUTPUT STREAM str_2 CLOSE.

    IF aux_flgerro = TRUE THEN DO:

        aux_dscritic = "Arquivo processado com erros. Verifique arquivo: " + aux_dsdircop.

        RUN gera_erro (INPUT par_cdcooper,        
                      INPUT par_cdagenci,
                      INPUT 1, /* nrdcaixa  */
                      INPUT 1, /* sequencia */
                      INPUT aux_cdcritic,        
                      INPUT-OUTPUT aux_dscritic).
        
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT 1,
                            INPUT par_nmdatela,
                            INPUT aux_nrdconta,
                           OUTPUT aux_nrdrowid).

        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.

