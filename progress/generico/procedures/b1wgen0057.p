/*.............................................................................

    Programa: b1wgen0057.p
    Autor   : Jose Luis (DB1)
    Data    : Marco/2010                   Ultima atualizacao: 31/01/2018

    Objetivo  : Tranformacao BO tela CONTAS - CONJUGE

    Alteracoes: 12/08/2010 - Ajuste na validacao de UF (David).
    
                 22/09/2010 -  Adicionado tratamento para conta 'pai' 
                              ou 'filha' (Gabriel - DB1).
                              
                 20/12/2010 - Adicionado parametros na chamada do procedure
                              Replica_Dados para tratamento do log e  erros
                              da validaçao na replicaçao (Gabriel - DB1).
                
                 12/11/2012 - Alterado processo de busca informaçoes conjuge
                              para nao efetuar limpeza campos tela quando efetuar
                              atualizaçoes de informaçoes Ayllos Web (Daniel).
                     
                 19/08/2013 - Incluido a chamada da procedure 
                              "atualiza_data_manutencao_cadastro" dentro da
                              procedure "grava_dados" (James).
                              
                 13/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
                 
                 06/06/2014 - (Chamado 117414) - Alteraçao conjuge da crapass para utilizar somente da 
                              crapcje. (Tiago Castro - RKAM)
                              
                 12/08/2015 - Reformulacao cadastral (Gabriel-RKAM).             
                              
				 20/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                  crapass, crapttl, crapjur 
							 (Adriano - P339).        

                 19/07/2017 - Alteraçao CDOEDTTL pelo campo IDORGEXP.
                              PRJ339 - CRM (Odirlei-AMcom)  
                              
				 28/08/2017 - Alterado tipos de documento para utilizarem CI, CN, 
							  CH, RE, PP E CT. (PRJ339 - Reinert)                              

                 22/09/2017 - Ajuste realizado na tela Contas/Dados Pessoais/Conjuge
						      onde o telefone comercial do conjugue estava sendo
							  carregado errado. PRJ339 (Kelvin).

				 28/09/2017 - Alterado para buscar nome da empresa do conjuge pelo
							  registro da crapttl. (PRJ339 - Reinert)
                
				 09/11/2017 - Criaçao do documento de conjuge (codigo 22). (PRJ339 - Lombardi)
         
                 31/01/2018 - Ajustar busca da descricao do Perfil do conjuge, caso valor 
                              venha nulo vamos considerar zero (Lucas Ranghetti #836600)

                 13/02/2018 - Ajustes na geraçao de pendencia de digitalizaçao.
                             PRJ366 - tipo de conta (Odirlei-AMcom)
				 
				 21/09/2018 - Ajuste na busca da empresa do conjuje (Alcemir - Mout's : INC0021853)

.............................................................................*/

/*............................. DEFINICOES ..................................*/

{ sistema/generico/includes/b1wgen0057tt.i &TT-LOG=SIM }
{ sistema/generico/includes/b1wgen0168tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-BO=SIM }

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_nrsequen AS INTE                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_retorno  AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR h-b1wgen0052b AS HANDLE                                        NO-UNDO.

FUNCTION ValidaCpfCnpj RETURNS LOGICAL 
    ( INPUT par_nrcpfcgc AS CHARACTER ) FORWARD.

FUNCTION ValidaNome RETURNS LOGICAL 
    ( INPUT  par_nmconjug AS CHARACTER,
      OUTPUT par_cdcritic AS INTEGER ) FORWARD.

/*............................. PROCEDURES ..................................*/
PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_nrctacje AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcje AS DECI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_msgconta AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapcje.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrdconta AS INTE                                    NO-UNDO.
    DEF VAR h-b1wgen0077 AS HANDLE                                  NO-UNDO.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca dados do Conjuge"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno  = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-crapcje.
        EMPTY TEMP-TABLE tt-erro.   

        FiltroBusca: DO ON ERROR UNDO FiltroBusca, LEAVE FiltroBusca:
            IF  par_nrdrowid <> ? THEN
                DO: 
                    RUN Busca_Dados_Id
                        ( INPUT par_cdcooper,
                          INPUT par_nrdconta,
                          INPUT par_idseqttl,
                          INPUT par_nrdrowid,
                          INPUT par_nrcpfcje,
                          INPUT par_cddopcao,
                         OUTPUT aux_cdcritic,
                         OUTPUT aux_dscritic ).                         
                END.
            ELSE
                IF  par_nrctacje <> 0 OR par_nrcpfcje <> 0 THEN
                    DO:     
                       RUN Busca_Dados_Cje
                           ( INPUT par_cdcooper,
                             INPUT par_nrdconta,
                             INPUT par_idseqttl,
                             INPUT par_nrctacje,
                             INPUT par_nrcpfcje,
                             INPUT par_cddopcao,
                            OUTPUT aux_cdcritic,
                            OUTPUT aux_dscritic ).
                    END.
        END. /* filtrobusca */

        IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
            LEAVE Busca.

        IF  par_cddopcao <> "C" THEN
            LEAVE Busca.

        FOR FIRST crapttl FIELDS(cdestcvl)
                          WHERE crapttl.cdcooper = par_cdcooper AND
                                crapttl.nrdconta = par_nrdconta AND
                                crapttl.idseqttl = par_idseqttl NO-LOCK:

            IF  crapttl.cdestcvl = 1 OR   /*SOLTEIRO*/
                crapttl.cdestcvl = 5 OR   /*VIUVO*/
                crapttl.cdestcvl = 6 OR   /*SEPARADO*/
                crapttl.cdestcvl = 7 THEN /*DIVORCIADO*/
                DO:
                   ASSIGN aux_dscritic = "Estado civil do associado nao " + 
                                         "permite conjuge.".
                   LEAVE Busca.
                END.
        END.

        FIND crapcje WHERE crapcje.cdcooper = par_cdcooper AND
                           crapcje.nrdconta = par_nrdconta AND
                           crapcje.idseqttl = par_idseqttl
                           NO-LOCK NO-ERROR.

        IF  AVAILABLE crapcje THEN
            RUN Busca_Dados_Id
                  ( INPUT par_cdcooper,
                    INPUT par_nrdconta,
                    INPUT par_idseqttl,
                    INPUT ROWID(crapcje),
                    INPUT par_nrcpfcje,
                    INPUT par_cddopcao,
                   OUTPUT aux_cdcritic,
                   OUTPUT aux_dscritic ). 
        ELSE
            DO:
                ASSIGN aux_dscritic = "Registro de conjuge nao encontrado. " + 
                                     "Verifique relac. com 1 titular.".
                LEAVE Busca.
            END.

        FOR FIRST crapttl FIELDS(nrcpfcgc)
                           WHERE crapttl.cdcooper = par_cdcooper AND
                                 crapttl.nrdconta = par_nrdconta AND
                                 crapttl.idseqttl = par_idseqttl NO-LOCK: 
        END.
     
        IF AVAILABLE crapttl THEN
            DO:
                /* Rotina para controle/replicacao entre contas */
                IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
                    RUN sistema/generico/procedures/b1wgen0077.p 
                        PERSISTENT SET h-b1wgen0077.
                
                RUN Busca_Conta IN h-b1wgen0077
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT crapttl.nrcpfcgc,
                      INPUT par_idseqttl,
                     OUTPUT aux_nrdconta,
                     OUTPUT par_msgconta,
                     OUTPUT aux_cdcritic,
                     OUTPUT aux_dscritic ).
                
                IF  VALID-HANDLE(h-b1wgen0077) THEN
                    DELETE OBJECT h-b1wgen0077.
            END. 
            LEAVE Busca.
    END.

    IF  VALID-HANDLE(h-b1wgen0077) THEN
        DELETE OBJECT h-b1wgen0077.
    
    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO: 
           ASSIGN aux_nrsequen = aux_nrsequen + 1.
                  aux_retorno  = "NOK".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,           
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.
    ELSE 
        ASSIGN aux_retorno = "OK".

    IF  par_flgerlog AND par_cddopcao = "C" THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF aux_retorno = "OK" THEN TRUE ELSE FALSE),
                            INPUT par_idseqttl, 
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).


    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Busca_Dados_Id:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcje AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF BUFFER crabttl FOR crapttl.

    ASSIGN aux_retorno = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-crapcje.
        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST crapass FIELDS(cdcooper nrdconta inpessoa)
                          WHERE crapass.cdcooper = par_cdcooper AND
                                crapass.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE crapass THEN
            DO:
               ASSIGN par_cdcritic = 9.
               LEAVE Busca.
            END.

        IF  crapass.inpessoa <> 1 THEN
            DO:
               ASSIGN par_cdcritic = 833.
               LEAVE Busca.
            END.

        FOR FIRST crapttl FIELDS(cdcooper nrdconta inpessoa cdgraupr idseqttl)
                          WHERE crapttl.cdcooper = crapass.cdcooper AND
                                crapttl.nrdconta = crapass.nrdconta AND 
                                crapttl.idseqttl = par_idseqttl     NO-LOCK:
        END.

        IF  NOT AVAILABLE crapttl THEN
            DO:
               ASSIGN par_dscritic = "Titular nao encontrado.".
               LEAVE Busca.
            END.

        IF  crapttl.inpessoa <> 1   THEN
            DO:
               ASSIGN par_cdcritic = 833.
               LEAVE Busca.
            END.

        FIND crapcje WHERE ROWID(crapcje) = par_nrdrowid NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapcje THEN
            DO:
               ASSIGN par_dscritic = "Registro de conjuge nao encontrado. " + 
                                     "Verifique relac. com 1 titular.".
               LEAVE Busca.
            END.           
            
        IF  par_cddopcao = "A" AND par_nrcpfcje <> crapcje.nrcpfcjg THEN
            DO:
               EMPTY TEMP-TABLE tt-crapcje.
               
               RUN Busca_Dados_Cje
                  ( INPUT par_cdcooper,
                    INPUT par_nrdconta,
                    INPUT par_idseqttl,
                    INPUT 0,
                    INPUT par_nrcpfcje,
                    INPUT par_cddopcao,
                   OUTPUT par_cdcritic,
                   OUTPUT par_dscritic ).
            END.

        IF  NOT AVAILABLE tt-crapcje THEN
            DO:
               CREATE tt-crapcje.
               ASSIGN tt-crapcje.nrctacje = crapcje.nrctacje.
            END.
            
        BUFFER-COPY crapcje EXCEPT nrctacje TO tt-crapcje
            ASSIGN 
               tt-crapcje.cdgraupr = crapttl.cdgraupr
               tt-crapcje.nrdrowid = ROWID(crapcje).


         IF tt-crapcje.idorgexp <> 0 THEN 
         DO:
          /* Retornar orgao expedidor */
          IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
              RUN sistema/generico/procedures/b1wgen0052b.p 
                  PERSISTENT SET h-b1wgen0052b.

          ASSIGN tt-crapcje.cdoedcje = "".
          RUN busca_org_expedidor IN h-b1wgen0052b 
                             ( INPUT tt-crapcje.idorgexp,
                              OUTPUT tt-crapcje.cdoedcje,
                              OUTPUT par_cdcritic, 
                              OUTPUT par_dscritic).

          DELETE PROCEDURE h-b1wgen0052b.   

          IF  RETURN-VALUE = "NOK" THEN
          DO:
              ASSIGN tt-crapcje.cdoedcje = ''.
              LEAVE Busca.
          END.            
        END.
        /* procurar a conta do titular conf. conta do conjuge */
        FOR FIRST crabttl FIELDS(nrcpfcgc nmextttl dtnasttl tpdocttl nrdocttl
                                 idorgexp cdufdttl dtemdttl cdfrmttl cdnatopc
                                 tpcttrab dsproftl cdnvlcgo cdturnos
                                 dtadmemp vlsalari cdcooper cdempres inpessoa
                                 idseqttl nrdconta grescola nrcpfemp cdocpttl)
                          WHERE crabttl.cdcooper = tt-crapcje.cdcooper AND
                                crabttl.nrdconta = tt-crapcje.nrctacje NO-LOCK:
        END.

        IF  AVAILABLE crabttl THEN
            DO:
               /* Opcao disponivel somente para pessoa fisica*/
               IF  crabttl.inpessoa <> 1   THEN
                   DO:
                      ASSIGN par_cdcritic = 833.
                      LEAVE Busca.
                   END.
                   
               IF   NOT AVAILABLE tt-crapcje THEN
                    DO:
                       CREATE tt-crapcje.
                       ASSIGN 
                           tt-crapcje.cdcooper = crabttl.cdcooper
                           tt-crapcje.nrdconta = crabttl.nrdconta
                           tt-crapcje.idseqttl = crabttl.idseqttl.
                    END.

               ASSIGN
                  tt-crapcje.nrctacje = crabttl.nrdconta
                  tt-crapcje.nrcpfcjg = crabttl.nrcpfcgc
                  tt-crapcje.nmconjug = crabttl.nmextttl
                  tt-crapcje.dtnasccj = crabttl.dtnasttl
                  tt-crapcje.tpdoccje = crabttl.tpdocttl
                  tt-crapcje.nrdoccje = crabttl.nrdocttl
                  tt-crapcje.cdufdcje = crabttl.cdufdttl
                  tt-crapcje.dtemdcje = crabttl.dtemdttl
                  tt-crapcje.grescola = crabttl.grescola
                  tt-crapcje.cdfrmttl = crabttl.cdfrmttl
                  tt-crapcje.cdnatopc = crabttl.cdnatopc
                  tt-crapcje.tpcttrab = crabttl.tpcttrab
                  tt-crapcje.dsproftl = crabttl.dsproftl
                  tt-crapcje.cdnvlcgo = crabttl.cdnvlcgo
                  tt-crapcje.cdturnos = crabttl.cdturnos
                  tt-crapcje.dtadmemp = crabttl.dtadmemp
                  tt-crapcje.vlsalari = crabttl.vlsalari
                  tt-crapcje.nrdocnpj = crabttl.nrcpfemp
                  tt-crapcje.cdocpcje = crabttl.cdocpttl.

               /* Retornar orgao expedidor */
               IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                  RUN sistema/generico/procedures/b1wgen0052b.p 
                      PERSISTENT SET h-b1wgen0052b.

               ASSIGN tt-crapcje.cdoedcje = "".
               RUN busca_org_expedidor IN h-b1wgen0052b 
                                 ( INPUT crabttl.idorgexp,
                                  OUTPUT tt-crapcje.cdoedcje,
                                  OUTPUT par_cdcritic, 
                                  OUTPUT par_dscritic).

               DELETE PROCEDURE h-b1wgen0052b.   

               IF  RETURN-VALUE = "NOK" THEN
               DO:
                  LEAVE Busca.
               END.   

			   
			   FOR FIRST crapcje FIELDS(nrdocnpj nmextemp)
                                 WHERE crapcje.cdcooper = crabttl.cdcooper
   				                   AND crapcje.nrctacje = crabttl.nrdconta
                                   AND crapcje.nrcpfcjg = crabttl.nrcpfcgc
                                   AND crapcje.nrdconta = par_nrdconta
                                   NO-LOCK:
               END.

               	        
	           IF AVAILABLE crapcje THEN
 	  	       DO:                            

                   FOR FIRST crapemp FIELDS(nmextemp) 
                                 WHERE crapemp.cdcooper = crabttl.cdcooper AND
                                       crapemp.cdempres = crabttl.cdempres AND 
                                       crapemp.nrdocnpj = crapcje.nrdocnpj
                                       NO-LOCK:
                   END.

                   
                   IF AVAILABLE crapemp THEN 
                      ASSIGN tt-crapcje.nmextemp = crapemp.nmextemp.
                   ELSE
                     DO:
                       IF (crapcje.nmextemp <> "") and (crapcje.nmextemp <> ?) THEN
		                  ASSIGN tt-crapcje.nmextemp = crapcje.nmextemp. 
                       ELSE
                          ASSIGN tt-crapcje.nmextemp = "NAO CADASTRADO".

                     END.
                 END.
               ELSE
                 DO:
                    /* Empresa */
                   FOR FIRST crapemp FIELDS(nmextemp) 
                                 WHERE crapemp.cdcooper = crabttl.cdcooper AND
                                       crapemp.cdempres = crabttl.cdempres 
                                       NO-LOCK:
                   END.

	      
	            IF  AVAILABLE crapemp THEN
                      ASSIGN tt-crapcje.nmextemp = crapemp.nmextemp.
                   ELSE
                      ASSIGN tt-crapcje.nmextemp = "NAO CADASTRADO".
       
                END.  

               /* Telefone Comercial*/
               FOR FIRST craptfc WHERE craptfc.cdcooper = crabttl.cdcooper  AND
                                       craptfc.nrdconta = crabttl.nrdconta AND
                                       craptfc.tptelefo = 3				   AND
									   craptfc.idseqttl = 1  NO-LOCK:
                   ASSIGN tt-crapcje.nrfonemp = string(craptfc.nrtelefo)
				          tt-crapcje.nrramemp = craptfc.nrdramal.
               END.
            END.
        ELSE 
            DO:
                IF  tt-crapcje.nrctacje <> 0 AND NOT AVAILABLE crabttl THEN
                    DO:
                       ASSIGN par_cdcritic = 9.
                       LEAVE Busca.
                    END.                    
            END.
            
        IF  par_cddopcao = "A" AND par_nrcpfcje <> 0 AND 
            par_nrcpfcje <> crapcje.nrcpfcjg THEN
            ASSIGN tt-crapcje.nrcpfcjg = par_nrcpfcje.            

        /*** Verifica se permite modificar o conjuge do titular ***/
        IF  (tt-crapcje.idseqttl = 1 OR tt-crapcje.cdgraupr = 1) AND
            par_cddopcao = "A" /* ALTERACAO */ THEN
            DO: 
                RUN Verifica_Conjuge_Titular
                    ( INPUT tt-crapcje.cdcooper,
                      INPUT tt-crapcje.nrdconta,
                      INPUT par_idseqttl,
                      INPUT crapcje.nrcpfcjg,
                      INPUT crapcje.idseqttl,
                      INPUT crapcje.nrctacje,
                     OUTPUT par_dscritic ).
                
                IF  par_dscritic <> "" THEN
                    LEAVE Busca.
            END.

        RUN Atualiza_Descricao.

        LEAVE Busca.
    END.

    IF  par_dscritic = "" AND par_cdcritic = 0 THEN
        ASSIGN aux_retorno = "OK".
                                                                             
    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Busca_Dados_Cje:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctacje AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcje AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
                                                                             
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF BUFFER crabttl FOR crapttl.

    ASSIGN aux_retorno = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-crapcje.
        EMPTY TEMP-TABLE tt-erro.

        IF  par_nrctacje = 0 AND par_nrcpfcje = 0 THEN
            LEAVE Busca.

        FOR FIRST crabttl FIELDS(nrdconta nrcpfcgc) 
                           WHERE crabttl.cdcooper = par_cdcooper AND 
                                 crabttl.nrdconta = par_nrdconta AND 
                                 crabttl.idseqttl = par_idseqttl NO-LOCK:
        END.

        IF  NOT AVAILABLE crabttl  THEN
            DO:    
                ASSIGN par_cdcritic = 9.
                LEAVE Busca.
            END.

        /* nao pode ser o titular */
        IF  par_nrcpfcje > 0                 AND
            crabttl.nrcpfcgc = par_nrcpfcje  THEN
            DO:
               ASSIGN par_dscritic = "Conjuge nao pode ser igual ao titular.".
               LEAVE Busca.
            END.           
        
        IF  par_nrctacje <> 0  THEN
            FOR FIRST crapass FIELDS(cdcooper nrdconta inpessoa nrcpfcgc)
                              WHERE crapass.cdcooper = par_cdcooper AND
                                    crapass.nrdconta = par_nrctacje NO-LOCK:
            END.
        ELSE
        IF  par_nrcpfcje <> 0  THEN
            FOR FIRST crapass FIELDS(cdcooper nrdconta inpessoa nrcpfcgc)
                              WHERE crapass.cdcooper = par_cdcooper AND
                                    crapass.nrcpfcgc = par_nrcpfcje NO-LOCK:
            END.
        
        IF  NOT AVAILABLE crapass  THEN
            DO: 
               IF  par_nrctacje <> 0  THEN
                   ASSIGN par_cdcritic = 9.

               IF  par_nrcpfcje <> 0  THEN
                   DO:
                      CREATE tt-crapcje.
                      ASSIGN tt-crapcje.nrcpfcjg = par_nrcpfcje.

                      FIND crapcje WHERE crapcje.cdcooper = par_cdcooper AND
                                         crapcje.nrdconta = par_nrdconta AND
                                         crapcje.idseqttl = par_idseqttl
                                         NO-LOCK NO-ERROR.
            
                      IF  AVAIL crapcje  THEN
                          DO:
                              IF  crapcje.nrcpfcjg = par_nrcpfcje  THEN
                                  DO:
                                      RUN Busca_Dados_Id
                                        ( INPUT par_cdcooper,
                                          INPUT par_nrdconta,
                                          INPUT par_idseqttl,
                                          INPUT ROWID(crapcje),
                                          INPUT par_nrcpfcje,
                                          INPUT par_cddopcao,
                                         OUTPUT aux_cdcritic,
                                         OUTPUT aux_dscritic ). 
                                  END.
                          END. 
                   END.

               LEAVE Busca.
            END.

        IF  crapass.inpessoa <> 1   THEN
            DO:
               ASSIGN par_cdcritic = 833.
               LEAVE Busca.
            END.

        /* procurar a conta do titular conf. conta do conjuge */
        FOR FIRST crapttl FIELDS(nrcpfcgc nmextttl dtnasttl tpdocttl nrdocttl
                                 idorgexp cdufdttl dtemdttl cdfrmttl cdnatopc
                                 tpcttrab dsproftl cdnvlcgo cdturnos
                                 dtadmemp vlsalari cdcooper cdempres inpessoa
                                 idseqttl nrdconta grescola nrcpfemp cdocpttl
                                 cdgraupr nmextemp)
                          WHERE crapttl.cdcooper = crapass.cdcooper AND
                                crapttl.nrdconta = crapass.nrdconta AND 
                                crapttl.nrcpfcgc = crapass.nrcpfcgc NO-LOCK:
        END.

        IF  NOT AVAILABLE crapttl THEN
            DO:
               ASSIGN par_dscritic = "Titular nao encontrado p/ o CPF " + 
                                     "informado".
               LEAVE Busca.
            END.

        /* Opcao disponivel somente para pessoa fisica*/
        IF  crapttl.inpessoa <> 1 THEN
            DO:
               ASSIGN par_cdcritic = 833.
               LEAVE Busca.
            END.
        
        /* deve ser previsto tb no valida dados */
        IF  crabttl.nrdconta = crapttl.nrdconta  AND 
            crabttl.nrcpfcgc = crapttl.nrcpfcgc  THEN
            DO:
               ASSIGN par_dscritic = "Conjuge nao pode ser igual ao titular.".
               LEAVE Busca.
            END.           

        CREATE tt-crapcje.
        ASSIGN 
           tt-crapcje.nrctacje = crapttl.nrdconta
           tt-crapcje.cdcooper = crapttl.cdcooper
           tt-crapcje.nrdconta = crapttl.nrdconta
           tt-crapcje.idseqttl = crapttl.idseqttl
           tt-crapcje.cdgraupr = crapttl.cdgraupr
           tt-crapcje.nrcpfcjg = crapttl.nrcpfcgc
           tt-crapcje.nmconjug = crapttl.nmextttl            
           tt-crapcje.dtnasccj = crapttl.dtnasttl
           tt-crapcje.tpdoccje = crapttl.tpdocttl
           tt-crapcje.nrdoccje = crapttl.nrdocttl
           tt-crapcje.cdufdcje = crapttl.cdufdttl
           tt-crapcje.dtemdcje = crapttl.dtemdttl
           tt-crapcje.grescola = crapttl.grescola
           tt-crapcje.cdfrmttl = crapttl.cdfrmttl
           tt-crapcje.cdnatopc = crapttl.cdnatopc
           tt-crapcje.tpcttrab = crapttl.tpcttrab
           tt-crapcje.dsproftl = crapttl.dsproftl
           tt-crapcje.cdnvlcgo = crapttl.cdnvlcgo
           tt-crapcje.cdturnos = crapttl.cdturnos
           tt-crapcje.dtadmemp = crapttl.dtadmemp
           tt-crapcje.vlsalari = crapttl.vlsalari
           tt-crapcje.nrdocnpj = crapttl.nrcpfemp
           tt-crapcje.cdocpcje = crapttl.cdocpttl NO-ERROR.
        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = ERROR-STATUS:GET-MESSAGE(1).
               LEAVE Busca.
            END.

        /* Retornar orgao expedidor */
        IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
          RUN sistema/generico/procedures/b1wgen0052b.p 
              PERSISTENT SET h-b1wgen0052b.

        ASSIGN tt-crapcje.cdoedcje = "".
        RUN busca_org_expedidor IN h-b1wgen0052b 
                         ( INPUT crapttl.idorgexp,
                          OUTPUT tt-crapcje.cdoedcje,
                          OUTPUT par_cdcritic, 
                          OUTPUT par_dscritic).

        DELETE PROCEDURE h-b1wgen0052b.   

        IF  RETURN-VALUE = "NOK" THEN
        DO:
          LEAVE Busca.
        END.   

        /* Empresa */
        FOR FIRST crapemp FIELDS(nmextemp) 
                          WHERE crapemp.cdcooper = crapttl.cdcooper AND
                                crapemp.cdempres = crapttl.cdempres 
                                NO-LOCK:
        END.

        IF  crapttl.nmextemp <> "" THEN
            ASSIGN tt-crapcje.nmextemp = crapttl.nmextemp.
        ELSE
          DO:
        IF  AVAILABLE crapemp THEN
            ASSIGN tt-crapcje.nmextemp = crapemp.nmextemp.
        ELSE
            ASSIGN tt-crapcje.nmextemp = "NAO CADASTRADO".
          END.

        /* Telefone Comercial*/
        FOR FIRST craptfc WHERE craptfc.cdcooper = crapttl.cdcooper AND
                                craptfc.nrdconta = crapttl.nrdconta AND
                                craptfc.tptelefo = 3 NO-LOCK:
            ASSIGN tt-crapcje.nrfonemp = string(craptfc.nrtelefo)
			       tt-crapcje.nrramemp = craptfc.nrdramal.
        END.

        RUN Atualiza_Descricao.

        LEAVE Busca.
    END.

    IF  par_dscritic = "" AND par_cdcritic = 0 THEN
        ASSIGN aux_retorno = "OK".
                                                                             
    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Atualiza_Descricao:

    DEF VAR h-b1wgen0060 AS HANDLE NO-UNDO.
    
    Descricao: DO ON ERROR UNDO Descricao, LEAVE Descricao:
        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p 
            PERSISTENT SET h-b1wgen0060.

        FOR EACH tt-crapcje:
            /* atulizar descricoes */
            DYNAMIC-FUNCTION("BuscaGrauEscolar" IN h-b1wgen0060,
                             INPUT IF tt-crapcje.grescola = ? THEN 0 ELSE tt-crapcje.grescola,
                             OUTPUT tt-crapcje.dsescola,
                             OUTPUT aux_dscritic).

            IF  tt-crapcje.dsescola = "" THEN
                ASSIGN tt-crapcje.dsescola = "NAO INFORMADO".

            DYNAMIC-FUNCTION("BuscaFormacao" IN h-b1wgen0060,
                             INPUT IF tt-crapcje.cdfrmttl = ? THEN 0 ELSE tt-crapcje.cdfrmttl,
                             OUTPUT tt-crapcje.rsfrmttl,
                             OUTPUT aux_dscritic).

            IF  tt-crapcje.rsfrmttl = "" THEN
                ASSIGN tt-crapcje.rsfrmttl = "NAO INFORMADO".

            DYNAMIC-FUNCTION("BuscaNatOcupacao" IN h-b1wgen0060,
                             INPUT IF tt-crapcje.cdnatopc = ? THEN 0 ELSE tt-crapcje.cdnatopc,
                             OUTPUT tt-crapcje.rsnatocp,
                             OUTPUT aux_dscritic).

            IF  tt-crapcje.rsnatocp = "" THEN
                ASSIGN tt-crapcje.rsnatocp = "NAO INFORMADO".

            DYNAMIC-FUNCTION("BuscaOcupacao" IN h-b1wgen0060,
                             INPUT IF tt-crapcje.cdocpcje = ? THEN 0 ELSE tt-crapcje.cdocpcje,
                             OUTPUT tt-crapcje.rsdocupa,
                             OUTPUT aux_dscritic).

            IF  tt-crapcje.rsdocupa = "" THEN
                ASSIGN tt-crapcje.rsdocupa = "NAO INFORMADO".

            DYNAMIC-FUNCTION("BuscaTpContrTrab" IN h-b1wgen0060,
                             INPUT tt-crapcje.tpcttrab,
                             OUTPUT tt-crapcje.dsctrtab,
                             OUTPUT aux_dscritic).

            DYNAMIC-FUNCTION("BuscaNivelCargo" IN h-b1wgen0060,
                             INPUT tt-crapcje.cdnvlcgo,
                             OUTPUT tt-crapcje.rsnvlcgo,
                             OUTPUT aux_dscritic).

            DYNAMIC-FUNCTION("BuscaTurnos" IN h-b1wgen0060,
                             INPUT tt-crapcje.cdcooper,
                             INPUT tt-crapcje.cdturnos,
                             OUTPUT tt-crapcje.dsturnos,
                             OUTPUT aux_dscritic).
            ASSIGN aux_dscritic = "".
        END.
    END.

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

END PROCEDURE.

PROCEDURE Verifica_Conjuge_Titular:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcjg AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_idseqcje AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctacje AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF BUFFER crabttl FOR crapttl.
    DEF BUFFER crabcje FOR crapcje.

    /*** Verifica se permite modificar o conjuge do titular ***/
    FOR FIRST crabttl FIELDS(idseqttl)
                      WHERE crabttl.cdcooper = par_cdcooper AND
                            crabttl.nrdconta = par_nrdconta AND
                            crabttl.nrcpfcgc = par_nrcpfcjg NO-LOCK:
    END.
    
    IF  AVAILABLE crabttl THEN
        DO:

           IF   par_idseqttl = 1 THEN
                DO: 
                   FOR FIRST crabttl FIELDS(idseqttl)
                                     WHERE crabttl.cdcooper = par_cdcooper AND
                                           crabttl.nrdconta = par_nrdconta AND
                                           crabttl.cdgraupr = 1 NO-LOCK:


                      IF  CAN-FIND(FIRST crabcje WHERE 
                                   crabcje.cdcooper = par_cdcooper AND
                                   crabcje.nrdconta = par_nrdconta AND
                                   crabcje.idseqttl = par_idseqcje) THEN
                          DO:
                             par_dscritic = "Alteracoes somente permitidas " +
                                            "no titular " + 
                                            STRING(crabttl.idseqttl,"9") +
                                            " desta conta.".
                          END.
                   END.
                END.
           ELSE DO: 
                   IF  par_nrctacje <> 0 THEN 
                       DO:
                          par_dscritic = "Alteracoes somente permitidas no " +
                                         "titular " + STRING(crabttl.idseqttl) 
                                         + " desta conta.".
                       END.
                END.
        END.

END PROCEDURE.

PROCEDURE Valida_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcjg AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmconjug AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtnasccj AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tpdoccje AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufdcje AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_gresccje AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdfrmttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdnatopc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddocupa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpcttrab AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmextemp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfemp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsproftl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdnvlcgo AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdturnos AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtadmemp AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctacje AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  BUFFER crabttl FOR crapttl.

    DEF VAR aux_nrcpfemp AS CHAR                                    NO-UNDO.
    
    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Valida dados do Conjuge"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
       EMPTY TEMP-TABLE tt-erro.

       FOR FIRST crapttl FIELDS(cdestcvl nrcpfcgc)
                         WHERE crapttl.cdcooper = par_cdcooper AND
                               crapttl.nrdconta = par_nrdconta AND
                               crapttl.idseqttl = par_idseqttl NO-LOCK:
    
           IF  crapttl.cdestcvl = 1 OR   /*SOLTEIRO*/
               crapttl.cdestcvl = 5 OR   /*VIUVO*/
               crapttl.cdestcvl = 6 OR   /*SEPARADO*/
               crapttl.cdestcvl = 7 THEN /*DIVORCIADO*/
               DO:
                  ASSIGN aux_dscritic = "Estado civil do associado nao " + 
                                        "permite conjuge.".
                  LEAVE Valida.
               END.
       END.

       /* cpf do conjuge caso seje informado */
       IF  par_nrcpfcjg <> "" AND DEC(par_nrcpfcjg) <> 0 AND
           NOT ValidaCpfCnpj(par_nrcpfcjg) THEN
           DO:
              ASSIGN aux_cdcritic = 27.
              LEAVE Valida.
           END.

       /* nao pode ser o titular */
       IF  DECI(par_nrcpfcjg) > 0                 AND
           crapttl.nrcpfcgc = DECI(par_nrcpfcjg)  THEN
           DO:                         
              ASSIGN aux_dscritic = "Conjuge nao pode ser igual ao titular.".
              LEAVE Valida.
           END.

       /* Se nao cooperado */
       IF  par_nrctacje = 0   THEN
           DO:
               
               /* tipo de documento - ultima posicao eh o vazio */
               IF  LOOKUP(par_tpdoccje,"CI,CN,CH,RE,PP,CT,") = 0 THEN
                   DO:
                      ASSIGN aux_cdcritic = 21.
                      LEAVE Valida.
                   END.
              
               /* unidade da federacao emissora do documento */
               IF  LOOKUP(par_cdufdcje,"AC,AL,AP,AM,BA,CE,DF,ES,GO,MA," +
                                       "MT,MS,MG,PA,PB,PR,PE,PI,RJ,RN," +
                                       "RS,RO,RR,SC,SP,SE,TO,") = 0 THEN
                   DO:
                      ASSIGN aux_cdcritic = 33.
                      LEAVE Valida.
                   END.

               /* grau de escolaridade */
               IF  NOT CAN-FIND(gngresc WHERE gngresc.grescola = par_gresccje)    and
                   par_gresccje > 0   THEN
                   DO:
                      ASSIGN aux_dscritic = "Grau de escolaridade nao cadastrado.".
                      LEAVE Valida.
                   END.
               
               /* curso superior */
               IF  NOT CAN-FIND(gncdfrm WHERE gncdfrm.cdfrmttl = par_cdfrmttl)   AND 
                   par_cdfrmttl > 0   THEN
                   DO:
                      ASSIGN aux_dscritic = "Curso superior nao cadastrado.".
                      LEAVE Valida.
                   END.
               
               /* natureza da ocupacao */
               IF  NOT CAN-FIND(gncdnto WHERE gncdnto.cdnatocp = par_cdnatopc)    and
                   par_cdnatopc > 0   THEN
                   DO:
                      ASSIGN aux_dscritic = "Natureza de ocupacao nao cadastrado.".
                      LEAVE Valida.
                   END.

               /* ocupacao */
               IF  NOT CAN-FIND(gncdocp WHERE gncdocp.cdocupa = par_cddocupa)   AND 
                   par_cddocupa > 0   THEN 
                   DO:
                      ASSIGN aux_dscritic = "Ocupacao nao cadastrada.".
                      LEAVE Valida.
                   END.

            END.               
       ELSE
            DO:
               IF  NOT CAN-FIND(crabttl WHERE crabttl.cdcooper = par_cdcooper AND
                                              crabttl.nrdconta = par_nrctacje AND
                                              crabttl.idseqttl = 1) THEN
                   DO:
                      /* Cooperado nao encontrado */
                      ASSIGN aux_cdcritic = 9.
                      LEAVE Valida.
                   END.
            END.

       /* escolaridade */
       IF  par_gresccje < 5 AND par_cdfrmttl <> 0 THEN
           DO:
              ASSIGN aux_dscritic = "Escolaridade errado!".
              LEAVE Valida.
           END.

       /* formacao */
       IF  par_gresccje >= 5 AND par_cdfrmttl = 0 THEN
           DO:
              ASSIGN aux_dscritic = "Codigo de formacao/curso superior nao " +
                                    "cadastrado.".
              LEAVE Valida.
           END.


       /* empresa onde trabalha caso haja vinculo  */
       IF  par_tpcttrab <> 3   AND 
           par_tpcttrab  > 0   THEN 
           DO:
              /* nome da empresa */
              IF  par_nmextemp = "" THEN
                  DO:
                     ASSIGN aux_dscritic = "Empresa onde trabalha nao " +
                                           "cadastrada.".
                     LEAVE Valida.
                  END.

              IF  par_nrctacje = 0 THEN
                  DO:
                     ASSIGN aux_nrcpfemp = REPLACE(REPLACE(REPLACE(
                         par_nrcpfemp,".",""),"/",""),"-","").
    
                     /* caso nao seje cooperado e tem vinculo */
                     IF  DEC(aux_nrcpfemp) <> 0 THEN
                         DO:
                            IF  NOT ValidaCpfCnpj(par_nrcpfemp) THEN
                                DO:
                                   aux_dscritic = "O CNPJ da empresa esta " + 
                                                         "incorreto.".
                                   LEAVE Valida.
                                END.
                         END.
    
                     /* funcao */
                     IF  par_dsproftl = "" THEN
                         DO:
                            ASSIGN aux_cdcritic = 44.
                            LEAVE Valida. 
                         END.

                     /* nivel cargo */
                     IF  NOT CAN-FIND(gncdncg WHERE 
                                      gncdncg.cdnvlcgo = par_cdnvlcgo) OR 
                         par_cdnvlcgo = 0 THEN
                         DO:
                            ASSIGN aux_dscritic = "Nivel do cargo nao " + 
                                                  "cadastrado.".
                            LEAVE Valida.
                         END.
    
                     /* turnos de trabalho */
                     IF  par_cdturnos < 1 OR par_cdturnos > 4 THEN
                         DO:
                            ASSIGN aux_cdcritic = 43.
                            LEAVE Valida.
                         END.            
                  END. /* par_nrctacje = 0 */
       END.

       LEAVE Valida.

    END.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_nrsequen = aux_nrsequen + 1.

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT aux_nrsequen,           
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.
    ELSE 
        ASSIGN aux_retorno = "OK".
                                                                             
    IF  par_flgerlog AND aux_retorno <> "OK" THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF aux_retorno = "OK" THEN YES ELSE NO),
                            INPUT par_idseqttl, 
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Grava_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_nrctacje AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcjg AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nmconjug AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtnasccj AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tpdoccje AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdoccje AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoedcje AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufdcje AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtemdcje AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_gresccje AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdfrmttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdnatopc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddocupa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpcttrab AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmextemp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfemp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsproftl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdnvlcgo AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrfonemp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrramemp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdturnos AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtadmemp AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vlsalari AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_msgrvcad AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
        
    DEF  BUFFER crabttl FOR crapttl.

    DEF VAR h-b1wgen0077 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0168 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0137 AS HANDLE                                  NO-UNDO.
        
    DEF VAR aux_idorgexp AS INT                                     NO-UNDO.
    DEF VAR aux_nmconjug AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrcpfcjg AS DECIMAL                                 NO-UNDO.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Grava dados do Conjuge"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_retorno = "NOK".

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        EMPTY TEMP-TABLE tt-erro.

        ContadorAss: DO aux_contador = 1 TO 10:

            FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                               crapass.nrdconta = par_nrdconta
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapass THEN
                DO:
                    IF  LOCKED(crapass) THEN
                        DO:
                           IF  aux_contador = 10 THEN
                               DO:
                                  aux_dscritic = "Associado sendo alterado" +
                                                 " em outra estacao".
                                  LEAVE ContadorAss.
                               END.
                           ELSE 
                               DO: 
                                  PAUSE 1 NO-MESSAGE.
                                  NEXT ContadorAss.
                               END.
                        END.
                    ELSE
                        DO:
                           ASSIGN aux_dscritic = "Associado nao cadastrado.".
                           LEAVE ContadorAss.  
                        END.
                END.
            ELSE 
                LEAVE ContadorAss.

        END.

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.  

        ContadorCje: DO aux_contador = 1 TO 10:

            FIND crapcje WHERE crapcje.cdcooper = par_cdcooper AND
                               crapcje.nrdconta = par_nrdconta AND
                               crapcje.idseqttl = par_idseqttl
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapcje THEN
                DO:
                   IF  LOCKED(crapcje) THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 aux_dscritic = "Conjuge sendo alterado " +
                                                "em outra estacao".
                                 LEAVE ContadorCje.
                              END.
                          ELSE 
                              DO: 
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT ContadorCje.
                              END.
                       END.
                   ELSE
                       DO:
                          /* Controle p/replicacao, Jose Luis, 18/10/2010 */
                          IF  par_cddopcao = "I" THEN
                              DO:
                                 CREATE crapcje.
                                 ASSIGN
                                     crapcje.cdcooper = par_cdcooper 
                                     crapcje.nrdconta = par_nrdconta 
                                     crapcje.idseqttl = par_idseqttl.
                                 VALIDATE crapcje.
                              END.
                          ELSE
                              ASSIGN aux_dscritic = "Registro de conjuge nao" +
                                                    " encontrado. Verifique " +
                                                    "relac. com 1 titular.".
                          LEAVE ContadorCje.  
                       END.
                END.
            ELSE
                DO:
                    ASSIGN aux_nmconjug = crapcje.nmconjug
                           aux_nrcpfcjg = crapcje.nrcpfcjg.
                LEAVE ContadorCje.
                END.

        END.

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.  

        ContadorTtl: DO aux_contador = 1 TO 10:

            FIND FIRST crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                     crapttl.nrdconta = par_nrdconta AND
                                     crapttl.idseqttl = par_idseqttl
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapttl THEN
                DO:
                   IF  LOCKED(crapttl) THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 aux_dscritic = "Titular sendo alterado " +
                                                "em outra estacao".
                                 LEAVE ContadorTtl.
                              END.
                          ELSE 
                              DO: 
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT ContadorTtl.
                              END.
                       END.
                   ELSE
                       DO:
                          ASSIGN aux_dscritic = "Titular nao cadastrado.".
                          LEAVE ContadorTtl.  
                       END.
                END.
            ELSE 
                LEAVE ContadorTtl.
            
        END.

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.  
        
        IF aux_nmconjug = ? THEN
            ASSIGN aux_nmconjug = "".
        IF aux_nrcpfcjg = ? THEN
            ASSIGN aux_nrcpfcjg = 0.
            
        IF par_cddopcao = "I"                  OR 
           aux_nmconjug <> UPPER(par_nmconjug) OR 
           aux_nrcpfcjg <> par_nrcpfcjg        THEN 
            DO:
              
              IF NOT VALID-HANDLE(h-b1wgen0137) THEN
                  RUN sistema/generico/procedures/b1wgen0137.p 
                  PERSISTENT SET h-b1wgen0137.
          
              RUN gera_pend_digitalizacao IN h-b1wgen0137                    
                        ( INPUT par_cdcooper,
                          INPUT par_nrdconta,
                          INPUT par_idseqttl,
                          INPUT crapttl.nrcpfcgc,
                          INPUT par_dtmvtolt,
                          INPUT "22", /* Documento do conjuge */
                          INPUT par_cdoperad,
                         OUTPUT aux_cdcritic,
                         OUTPUT aux_dscritic).

              IF  VALID-HANDLE(h-b1wgen0137) THEN
                DELETE OBJECT h-b1wgen0137.       
                
          
            
        END.

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.  
        
        IF  par_flgerlog  THEN 
            DO:
                { sistema/generico/includes/b1wgenalog.i }
            END.
        
        CREATE tt-crapcje-ant.
        BUFFER-COPY crapcje TO tt-crapcje-ant.

        IF  CAN-FIND(crabttl WHERE crabttl.cdcooper = par_cdcooper AND
                                   crabttl.nrdconta = par_nrctacje) THEN
            DO:
               ASSIGN crapcje.nrctacje = par_nrctacje
                      crapcje.nrcpfcjg = 0
                      crapcje.nmconjug = ""
                      crapcje.dtnasccj = ?
                      crapcje.tpdoccje = ""
                      crapcje.nrdoccje = ""
                      crapcje.idorgexp = 0
                      crapcje.cdufdcje = ""
                      crapcje.dtemdcje = ?
                      crapcje.grescola = 0
                      crapcje.cdfrmttl = 0
                      crapcje.cdnatopc = 0
                      crapcje.cdocpcje = 0
                      crapcje.tpcttrab = 0
                      crapcje.nmextemp = ""
                      crapcje.dsproftl = ""
                      crapcje.cdnvlcgo = 0
                      crapcje.nrfonemp = ""
                      crapcje.nrramemp = 0
                      crapcje.cdturnos = 0
                      crapcje.dtadmemp = ?
                      crapcje.vlsalari = 0
                      crapcje.nrdocnpj = 0.               
            END.
        ELSE 
            DO:
               
               IF par_cdoedcje <> "" THEN
               DO:               
               
                 /* Identificar orgao expedidor */
                 IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                      RUN sistema/generico/procedures/b1wgen0052b.p 
                          PERSISTENT SET h-b1wgen0052b.

                 ASSIGN aux_idorgexp = 0.
                 RUN identifica_org_expedidor IN h-b1wgen0052b 
                                   ( INPUT par_cdoedcje,
                                    OUTPUT aux_idorgexp,
                                    OUTPUT aux_cdcritic, 
                                    OUTPUT aux_dscritic).

                 DELETE PROCEDURE h-b1wgen0052b.   

                 IF  RETURN-VALUE = "NOK" THEN
                 DO:                    
                      UNDO Grava, LEAVE Grava.
                 END.
               END.
                 ELSE 
                   ASSIGN aux_idorgexp = 0.
               
                        
               ASSIGN crapcje.nrctacje = par_nrctacje     
                      crapcje.nrcpfcjg = par_nrcpfcjg
                      crapcje.nmconjug = UPPER(par_nmconjug)
                      crapcje.dtnasccj = par_dtnasccj
                      crapcje.tpdoccje = par_tpdoccje
                      crapcje.nrdoccje = par_nrdoccje
                      crapcje.idorgexp = aux_idorgexp
                      crapcje.cdufdcje = par_cdufdcje
                      crapcje.dtemdcje = par_dtemdcje
                      crapcje.grescola = par_gresccje
                      crapcje.cdfrmttl = par_cdfrmttl
                      crapcje.cdnatopc = par_cdnatopc
                      crapcje.cdocpcje = par_cddocupa
                      crapcje.tpcttrab = par_tpcttrab
                      crapcje.nmextemp = UPPER(par_nmextemp)
                      crapcje.dsproftl = UPPER(par_dsproftl)
                      crapcje.cdnvlcgo = par_cdnvlcgo
                      crapcje.nrfonemp = par_nrfonemp
                      crapcje.nrramemp = par_nrramemp
                      crapcje.cdturnos = par_cdturnos
                      crapcje.dtadmemp = par_dtadmemp
                      crapcje.vlsalari = par_vlsalari
                      crapcje.nrdocnpj = DEC(par_nrcpfemp) NO-ERROR.
               IF  ERROR-STATUS:ERROR THEN
                   DO:
                      ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                      UNDO Grava, LEAVE Grava.
                   END.
            END.
         
         CREATE tt-crapcje-atl.
         BUFFER-COPY crapcje TO tt-crapcje-atl.

        IF  par_flgerlog  THEN 
            DO:
                { sistema/generico/includes/b1wgenllog.i }
            END.
        
        /* Realiza a replicacao dos dados p/as contas relacionadas ao coop. */
        IF  par_idseqttl = 1 AND par_nmdatela = "CONTAS" THEN 
            DO:
               IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
                   RUN sistema/generico/procedures/b1wgen0077.p 
                        PERSISTENT SET h-b1wgen0077.
               
               RUN Replica_Dados IN h-b1wgen0077
                   ( INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT par_cdoperad,
                     INPUT par_nmdatela,
                     INPUT par_idorigem,
                     INPUT par_nrdconta,
                     INPUT par_idseqttl,
                     INPUT "CONJUGE",
                     INPUT par_dtmvtolt,
                     INPUT FALSE, /*par_flgerlog*/
                    OUTPUT aux_cdcritic,
                    OUTPUT aux_dscritic,
                    OUTPUT TABLE tt-erro ).

               IF  VALID-HANDLE(h-b1wgen0077) THEN
                   DELETE OBJECT h-b1wgen0077.

               IF  RETURN-VALUE <> "OK" THEN
                   UNDO Grava, LEAVE Grava.

               FIND FIRST crabttl WHERE crabttl.cdcooper = par_cdcooper AND
                                        crabttl.nrdconta = par_nrdconta AND
                                        crabttl.idseqttl = par_idseqttl
                                        NO-ERROR.
    
               IF AVAILABLE crabttl THEN DO:
                    
                   IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
                       RUN sistema/generico/procedures/b1wgen0077.p
                           PERSISTENT SET h-b1wgen0077.
                   
                   RUN Revisao_Cadastral IN h-b1wgen0077
                     ( INPUT par_cdcooper,
                       INPUT crabttl.nrcpfcgc,
                       INPUT par_nrdconta,
                      OUTPUT par_msgrvcad ).

                   IF  VALID-HANDLE(h-b1wgen0077) THEN
                       DELETE OBJECT h-b1wgen0077.
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
            IN h-b1wgen0168(INPUT  TABLE tt-crapcyb,
                            OUTPUT aux_cdcritic,
                            OUTPUT aux_dscritic).

        IF RETURN-VALUE <> "OK" THEN
           UNDO Grava, LEAVE Grava.  
        /* FIM - Atualizar os dados da tabela crapcyb */

        ASSIGN aux_retorno = "OK".

        LEAVE Grava.
    END.

    IF  VALID-HANDLE(h-b1wgen0077) THEN
        DELETE OBJECT h-b1wgen0077.

    IF VALID-HANDLE(h-b1wgen0168) THEN
       DELETE PROCEDURE(h-b1wgen0168).

    RELEASE crapass.
    RELEASE crapcje.
    RELEASE crapttl.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_nrsequen = aux_nrsequen + 1.

           ASSIGN aux_retorno = "NOK".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT aux_nrsequen,           
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.
                                                                             
    IF  par_flgerlog THEN
        RUN proc_gerar_log_tab
            ( INPUT par_cdcooper,
              INPUT par_cdoperad,
              INPUT aux_dscritic,
              INPUT aux_dsorigem,
              INPUT aux_dstransa,
              INPUT (IF aux_retorno = "OK" THEN TRUE ELSE FALSE),
              INPUT par_idseqttl, 
              INPUT par_nmdatela, 
              INPUT par_nrdconta, 
              INPUT YES,
              INPUT BUFFER tt-crapcje-ant:HANDLE,
              INPUT BUFFER tt-crapcje-atl:HANDLE ).

    RETURN aux_retorno.

END PROCEDURE.


/*............................. FUNCTIONS ...................................*/
FUNCTION ValidaCpfCnpj RETURNS LOGICAL 
    ( INPUT par_nrcpfcgc AS CHARACTER ):

    DEFINE VARIABLE h-b1wgen9999 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE aux_stsnrcal AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE aux_inpessoa AS INTEGER     NO-UNDO.

    /* Se houve erro na conversao para DEC, faz a critica */
    DEC(par_nrcpfcgc) NO-ERROR.
    
    IF  ERROR-STATUS:ERROR  THEN
        RETURN FALSE.

    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
        RUN sistema/generico/procedures/b1wgen9999.p 
            PERSISTENT SET h-b1wgen9999.

    RUN valida-cpf-cnpj IN h-b1wgen9999 (INPUT par_nrcpfcgc,
                                         OUTPUT aux_stsnrcal,
                                         OUTPUT aux_inpessoa).

    DELETE PROCEDURE h-b1wgen9999.

    RETURN aux_stsnrcal.
	
END FUNCTION.

FUNCTION ValidaNome RETURNS LOGICAL 
    ( INPUT  par_nmconjug AS CHARACTER,
      OUTPUT par_cdcritic AS INTEGER ):

    DEFINE VARIABLE h-b1wgen9999 AS HANDLE      NO-UNDO.

    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
        RUN sistema/generico/procedures/b1wgen9999.p 
            PERSISTENT SET h-b1wgen9999.

    RUN Critica_Nome IN h-b1wgen9999 (INPUT par_nmconjug,
                                     OUTPUT par_cdcritic).

    DELETE PROCEDURE h-b1wgen9999.

    RETURN (par_cdcritic = 0).
	
END FUNCTION.



