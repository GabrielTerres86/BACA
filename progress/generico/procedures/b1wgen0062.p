/*.............................................................................

    Programa: b1wgen0062.p
    Autor   : Jose Luis (DB1)
    Data    : Marco/2010                   Ultima atualizacao: 14/03/2018

    Objetivo  : Tranformacao BO tela CONTAS - IMPRESSAO FICHA CADASTRAL

    Alteracoes: 28/07/2010 - Acerto na impressao da FICHA CADASTRAL (David).
   
                10/08/2010 - Inclusao de parametro na function 
                "BuscaNaturezaJuridica", INPUT "dsnatjur" - Jose Luis, DB1
                
                11/03/2011 - Retirar campo dsdemail da crapass (Gabriel).
                
                19/08/2011 - Adicioando campos nrdoapto e cddbloco em 
                             &CAMPOS-END e Adicioando condicional para pegar
                             endereco. (Jorge)
                             
                03/04/2012 - Retirado campo nranores e adicionado campo dtinires
                             em &CAMPOS-END.
                             Adicionado tratamento para atribuicao de campos
                             tt-fcad.dtabrres e tt-fcad.dstemres. (Jorge)
                             
                             
                25/04/2012 - Ajuste referente ao projeto GP - Socios Menores
                             (Adriano).
                             
                25/04/2013 - Incluir campos dsnatura, cdufnatu para armazenar
                             na temp-table tt-fcad-psfis (Lucas R.)
                
                03/07/2013 - Inclusao da tabela tt-fcad-poder p/ exibir
                             poderes de Procurador/Representante (Jean Michel)
                
                26/08/2013 - Ficha cadastral - Alteraçao de onde é pega a 
                             filiaçao; da crapttl, ao invés da crapass.
                             Aplicado em Busca_PJ e Busca_PF (Carlos)
                             
                01/10/2013 - Removido a atribuicao do campo nrfonres nas 
                             temp-table tt-fcad-ctato e tt-fcad-refer.
                             (Reinert)
                             
                12/11/2013 - Removido campo dsnatura do FOR FIRST crabass.
                             (Reinert)
                             
                23/05/2014 - Adicionado campo de CPF em tt-fcad-poder.
                             (Jorge/Rosangela) - SD 1554081

                27/05/2014 - Alterado a informacao do estado civil da
                             crapass para crapttl (Douglas - Chamado 131253)
               
                07/10/2014 - Remoçao do Endividamento e dos Bens dos representantes
                             por caracterizar quebra de sigilo bancário (Dionathan)
                             
                12/08/2015 - Projeto Reformulacao cadastral
                             Eliminado o campo nmdsecao (Tiago Castro - RKAM).
                             
                08/01/2016 - #350828 Criacao da tela PEP (Carlos)

                04/08/2016 - Ajuste para pegar o idcidade e nao mais cdcidade.
                             (Jaison/Anderson)
							 				
				19/04/2017 - Alteraçao DSNACION pelo campo CDNACION.
                             PRJ339 - CRM (Odirlei-AMcom)  
                             
				20/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur 
							(Adriano - P339).

                17/07/2017 - Alteraçao CDOEDTTL pelo campo IDORGEXP.
                             PRJ339 - CRM (Odirlei-AMcom) 
                11/10/2017 - Ajuste referente ao projeto 339. (Kelvin)
                03/10/2017 - Correcao para carregar campo DSNACION.
                             (Jaison/Andrino - PRJ339)	 

                09/10/2017 - Projeto 410 - RF 52/62 - Adicionado indicador de 
                             impressão da declaração do simples nacional na 
                             crapjur (Diogo - Mouts).
							 
				14/03/2018 - Ajuste realizado para que a chamada da procedure 
							 busca_org_expedidor não esteja com mais inputs que
						     outputs. (Kelvin)
				 
.............................................................................*/

/*............................. DEFINICOES ..................................*/
{ sistema/generico/includes/b1wgen0062tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/gera_erro.i }


DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_retorno  AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_contador AS INTE                                        NO-UNDO.
DEF VAR h-b1wgen0052b AS HANDLE                                     NO-UNDO.

/*............................. PROCEDURES ..................................*/
PROCEDURE Busca_Impressao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-fcad.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-telef.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-email.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-psfis.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-filia.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-comer.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-cbens.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-depen.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-ctato.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-respl.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-cjuge.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-psjur.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-regis.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-procu.
    /*DEF OUTPUT PARAM TABLE FOR tt-fcad-bensp.*/
    DEF OUTPUT PARAM TABLE FOR tt-fcad-refer.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-poder.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdopetfn AS CHAR                                    NO-UNDO.
    DEF VAR aux_lsopetfn AS CHAR                                    NO-UNDO.
    DEF VAR aux_tptelefo AS CHAR EXTENT 4 INIT["RESIDENCIAL","CELULAR",
                                               "COMERCIAL","CONTATO"]   
                                                     FORMAT "x(11)" NO-UNDO.
    
    DEF VAR h-b1wgen0038 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_tempores AS CHAR                                    NO-UNDO.


    &SCOPED-DEFINE CAMPOS-END incasprp dtinires vlalugue nmcidade                               dsendere nrendere complend nmbairro                               cdufende nrcxapst nrdoapto cddbloco

    &SCOPED-DEFINE CAMPOS-TEL nrdddtfc nrtelefo nrdramal secpscto nmpescto
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca dados do associado para Ficha Cadastral"
           aux_dscritic = ""
           aux_cdcritic = 0
           aux_retorno = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-erro.

        RUN Zera_TempTable.

        /* Busca dados da cooperativa */
        FOR FIRST crapcop FIELDS(nmextcop)
                          WHERE crapcop.cdcooper = par_cdcooper NO-LOCK:
        END.

        IF  NOT AVAILABLE crapcop THEN
            DO:
               ASSIGN aux_cdcritic = 651.
               LEAVE Busca.
            END.

        /* Busca dados do cooperado */
        FOR FIRST crapass FIELDS(nrdconta cdagenci nrmatric inpessoa nmprimtl)
                          WHERE crapass.cdcooper = par_cdcooper AND
                                crapass.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE crapass THEN
            DO:
               ASSIGN aux_cdcritic = 9.
               LEAVE Busca.
            END.

        /* Busca dados da agencia */
        FOR FIRST crapage FIELDS(cdagenci nmresage idcidade)
                          WHERE crapage.cdcooper = par_cdcooper     AND
                                crapage.cdagenci = crapass.cdagenci 
                                NO-LOCK:
        END.

        CREATE tt-fcad.

        /* f_identi */
        IF AVAIL crapage THEN
        DO:
            FIND FIRST crapmun WHERE crapmun.idcidade = crapage.idcidade NO-LOCK NO-ERROR.
        
            ASSIGN tt-fcad.dscidade = IF AVAIL crapmun 
                                      THEN crapmun.dscidade
                                      ELSE 'CIDADE NAO CADASTRADA'.
        END.
        ELSE 
            ASSIGN tt-fcad.dscidade = 'CIDADE NAO CADASTRADA'.
    
        ASSIGN tt-fcad.nmextcop = crapcop.nmextcop
               tt-fcad.nrdconta = TRIM(STRING(crapass.nrdconta,"zzzz,zzz,9"))
               tt-fcad.nrmatric = STRING(crapass.nrmatric,"zzz,zz9")
               tt-fcad.inpessoa = crapass.inpessoa
               tt-fcad.dsagenci = (IF AVAILABLE crapage 
                                   THEN (STRING(crapage.cdagenci,"999") + 
                                        " - " + crapage.nmresage)
                                   ELSE (STRING(crapass.cdagenci,"999") + 
                                        " - NAO CADASTRADO")).

        FOR FIRST crapttl FIELDS(nmextttl inpolexp)
                          WHERE crapttl.cdcooper = par_cdcooper AND
                                crapttl.nrdconta = par_nrdconta AND
                                crapttl.idseqttl = par_idseqttl 
                                NO-LOCK:
        END.

        /* f_cadast */
        IF  AVAILABLE crapttl THEN
            ASSIGN tt-fcad.nmprimtl = crapttl.nmextttl.
        ELSE
            ASSIGN tt-fcad.nmprimtl = crapass.nmprimtl.

        ASSIGN tt-fcad.dsmvtolt = "DATA: " + STRING(par_dtmvtolt,"99/99/9999").

        /* f_responsa */
        FOR FIRST crapope FIELDS(nmoperad)
                          WHERE crapope.cdcooper = par_cdcooper AND
                                crapope.cdoperad = par_cdoperad 
                                NO-LOCK:
        END.
                           
        IF  NOT AVAILABLE crapope THEN
            ASSIGN tt-fcad.dsoperad = TRIM(par_cdoperad) + 
                                      " - NAO ENCONTRADO!".
        ELSE
            ASSIGN tt-fcad.dsoperad = TRIM(par_cdoperad) + 
                                      " - " + TRIM(crapope.nmoperad).
        
        /* f_endereco */
        FOR FIRST crapenc FIELDS({&CAMPOS-END} nrcepend)
                          WHERE crapenc.cdcooper = par_cdcooper   AND
                                crapenc.nrdconta = par_nrdconta   AND
                                crapenc.idseqttl = par_idseqttl   AND
                                crapenc.tpendass = (IF tt-fcad.inpessoa = 1
                                                    THEN 10 ELSE 9) NO-LOCK:

            BUFFER-COPY crapenc USING {&CAMPOS-END} TO tt-fcad
                ASSIGN tt-fcad.nrcepend = STRING(crapenc.nrcepend,"99999,999").
            
            CASE tt-fcad.incasprp:
                WHEN 1 THEN ASSIGN tt-fcad.dscasprp = "QUITADO".
                WHEN 2 THEN ASSIGN tt-fcad.dscasprp = "FINANCI".         
                WHEN 3 THEN ASSIGN tt-fcad.dscasprp = "ALUGADO".
                WHEN 4 THEN ASSIGN tt-fcad.dscasprp = "FAMILIA".         
                WHEN 5 THEN ASSIGN tt-fcad.dscasprp = "CEDIDO".
                OTHERWISE ASSIGN tt-fcad.dscasprp = "".
            END CASE.                          
        END.
        
        /* tratar data resumida de inicio de res. e tempo de res. */
        IF  tt-fcad.dtinires <> ?  THEN
        DO:
            ASSIGN tt-fcad.dtabrres = 
                   SUBSTR(STRING(tt-fcad.dtinires,"99/99/9999"),4).

            IF  NOT VALID-HANDLE(h-b1wgen0038) THEN
                RUN sistema/generico/procedures/b1wgen0038.p 
                PERSISTENT SET h-b1wgen0038.

            RUN trata-inicio-resid IN h-b1wgen0038  
                ( INPUT par_cdcooper,
                  INPUT par_cdagenci,
                  INPUT par_nrdcaixa,
                  INPUT tt-fcad.dtabrres,
                 OUTPUT aux_tempores,
                 OUTPUT TABLE tt-erro ).
            
            ASSIGN tt-fcad.dstemres = aux_tempores.

            IF  CAN-FIND(FIRST tt-erro) THEN
                ASSIGN tt-fcad.dtabrres = "".
          
            IF  VALID-HANDLE(h-b1wgen0038) THEN
                DELETE PROCEDURE h-b1wgen0038.
            
            IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
                LEAVE Busca.

        END.

        /* Carrega lista das operadoras - codigo e descricao */
        ASSIGN aux_cdopetfn = ""
               aux_lsopetfn = "".
                  
        FOR EACH craptab FIELDS(tpregist dstextab)
                         WHERE craptab.cdcooper = 0            AND
                               craptab.nmsistem = "CRED"       AND
                               craptab.tptabela = "USUARI"     AND
                               craptab.cdempres = 11           AND
                               craptab.cdacesso = "OPETELEFON" 
                               NO-LOCK:
        
            ASSIGN aux_cdopetfn = aux_cdopetfn + STRING(craptab.tpregist) + ","
                   aux_lsopetfn = aux_lsopetfn + craptab.dstextab + ",".
        END.
                       
        /* tira a ultima "," e insere a operadora 0 para ser em branco */
        ASSIGN aux_cdopetfn = SUBSTRING(aux_cdopetfn,1,LENGTH(aux_cdopetfn) - 1)
               aux_lsopetfn = SUBSTRING(aux_lsopetfn,1,LENGTH(aux_lsopetfn) - 1)
               aux_cdopetfn = "0," + aux_cdopetfn
               aux_lsopetfn = " ," + aux_lsopetfn.

        FOR EACH craptfc FIELDS({&CAMPOS-TEL} cdopetfn tptelefo)
                         WHERE craptfc.cdcooper = par_cdcooper AND
                               craptfc.nrdconta = par_nrdconta AND
                               craptfc.idseqttl = par_idseqttl 
                               NO-LOCK:
                               
            /* f_telefone */
            CREATE tt-fcad-telef.

            BUFFER-COPY craptfc USING {&CAMPOS-TEL} TO tt-fcad-telef
                ASSIGN tt-fcad-telef.dsopetfn = ENTRY(LOOKUP
                                                  (STRING(craptfc.cdopetfn),
                                                   aux_cdopetfn),aux_lsopetfn)
                       tt-fcad-telef.tptelefo = aux_tptelefo[craptfc.tptelefo].
        END.

        /* Buscar os dados do email */
        FOR EACH crapcem FIELDS(dsdemail secpscto nmpescto)
                         WHERE crapcem.cdcooper = par_cdcooper AND
                               crapcem.nrdconta = par_nrdconta AND
                               crapcem.idseqttl = par_idseqttl 
                               NO-LOCK BY crapcem.dsdemail:

            /* f_emails */
            CREATE tt-fcad-email.
            ASSIGN tt-fcad-email.dsdemail = crapcem.dsdemail 
                   tt-fcad-email.secpscto = crapcem.secpscto 
                   tt-fcad-email.nmpescto = crapcem.nmpescto.
        END.

        /* buscar dados dos bens */
        FOR EACH crapbem FIELDS(dsrelbem persemon qtprebem vlprebem vlrdobem)
                         WHERE crapbem.cdcooper = par_cdcooper AND
                               crapbem.nrdconta = par_nrdconta AND
                               crapbem.idseqttl = par_idseqttl 
                               NO-LOCK:
                               
            CREATE tt-fcad-cbens.
            ASSIGN tt-fcad-cbens.dsrelbem = crapbem.dsrelbem
                   tt-fcad-cbens.persemon = crapbem.persemon
                   tt-fcad-cbens.qtprebem = crapbem.qtprebem
                   tt-fcad-cbens.vlprebem = crapbem.vlprebem
                   tt-fcad-cbens.vlrdobem = crapbem.vlrdobem.
        END.
        
        CASE tt-fcad.inpessoa:
            WHEN 1 THEN DO:
                RUN Busca_PF 
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,
                     OUTPUT aux_cdcritic,
                     OUTPUT aux_dscritic,
                     OUTPUT TABLE tt-fcad-psfis,
                     OUTPUT TABLE tt-fcad-filia,
                     OUTPUT TABLE tt-fcad-comer,
                     OUTPUT TABLE tt-fcad-depen,
                     OUTPUT TABLE tt-fcad-ctato,
                     OUTPUT TABLE tt-fcad-procu,
                     /*OUTPUT TABLE tt-fcad-bensp,*/
                     OUTPUT TABLE tt-fcad-respl,
                     OUTPUT TABLE tt-fcad-poder).
                
                
                IF  RETURN-VALUE <> "OK" THEN
                    UNDO Busca, LEAVE Busca.
            END.
                
            OTHERWISE DO:
                RUN Busca_PJ
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                     OUTPUT aux_cdcritic,
                     OUTPUT aux_dscritic,
                     OUTPUT TABLE tt-fcad-psjur,
                     OUTPUT TABLE tt-fcad-regis,
                     OUTPUT TABLE tt-fcad-procu,
                     /*OUTPUT TABLE tt-fcad-bensp,*/
                     OUTPUT TABLE tt-fcad-refer,
                     OUTPUT TABLE tt-fcad-respl,
                     OUTPUT TABLE tt-fcad-poder).

                IF  RETURN-VALUE <> "OK" THEN
                    UNDO Busca, LEAVE Busca.
            END.

        END CASE.

        LEAVE Busca.
    END.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0  THEN
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

    IF  NOT TEMP-TABLE tt-erro:HAS-RECORDS  THEN
	  DO:
        /* Marca o registro da declaração do simples nacional como "impresso" */
        FIND crapjur WHERE crapjur.cdcooper = par_cdcooper AND
                              crapjur.nrdconta = par_nrdconta AND 
                              crapjur.idimpdsn <> 2 AND 
                              (crapjur.tpregtrb = 1)
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        IF AVAILABLE crapjur AND crapjur.idimpdsn <> 2 THEN
          DO:
              ASSIGN crapjur.idimpdsn = 2.
              VALIDATE crapjur.
              /* Grava a informação que o documento deve ser digitalizado no DIGIDOC */
                ContadorDoc55: DO aux_contador = 1 TO 10:
                  FIND FIRST crapdoc WHERE crapdoc.cdcooper = par_cdcooper AND
                                     crapdoc.nrdconta = par_nrdconta AND
                                     crapdoc.tpdocmto = 55            AND
                                     crapdoc.dtmvtolt = par_dtmvtolt AND
                                     crapdoc.idseqttl = 1
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                  IF NOT AVAILABLE crapdoc THEN
                      DO:
                          IF LOCKED(crapdoc) THEN
                              DO:
                                  IF aux_contador = 10 THEN
                                      DO:
                                          ASSIGN aux_cdcritic = 341.
                                          LEAVE ContadorDoc55.
                                      END.
                                  ELSE 
                                      DO: 
                                          PAUSE 1 NO-MESSAGE.
                                          NEXT ContadorDoc55.
                                      END.
                              END.
                          ELSE
                              DO:
                                  CREATE crapdoc.
                                  ASSIGN crapdoc.cdcooper = par_cdcooper
                                         crapdoc.nrdconta = par_nrdconta
                                         crapdoc.flgdigit = FALSE
                                         crapdoc.dtmvtolt = par_dtmvtolt
                                         crapdoc.tpdocmto = 55
                                         crapdoc.idseqttl = 1.
                                  VALIDATE crapdoc.
                                  LEAVE ContadorDoc55.
                              END.
                      END.
                  ELSE
                      DO:
                          ASSIGN crapdoc.flgdigit = FALSE
                                 crapdoc.dtmvtolt = par_dtmvtolt.
                          LEAVE ContadorDoc55.
                      END.
                END.
          END.
        ASSIGN aux_retorno = "OK".        
      END.

    IF  par_flgerlog THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF aux_retorno = "OK"
                                   THEN TRUE ELSE FALSE),
                            INPUT par_idseqttl, 
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Busca_PF:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-psfis.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-filia.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-comer.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-depen.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-ctato.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-procu.
    /*DEF OUTPUT PARAM TABLE FOR tt-fcad-bensp.*/
    DEF OUTPUT PARAM TABLE FOR tt-fcad-respl.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-poder.

    DEF VAR h-b1wgen0060 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_nrcardin AS CHAR EXTENT 10 INIT["Primeiro","Segundo",
                                                "Terceiro","Quarto",
                                                "Quinto","Sexto",
                                                "Setimo","Oitavo",
                                                "Nono","Decimo"]    NO-UNDO.

    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabttl FOR crapttl.
    DEF BUFFER crabenc FOR crapenc.

    &SCOPED-DEFINE CAMPOS-TTL inpessoa dtcnscpf cdsitcpf tpdocttl nrdocttl~
						      idorgexp cdufdttl dtemdttl dtnasttl tpnacion~
							  cdnacion dsnatura inhabmen dthabmen cdgraupr~
							  cdestcvl grescola cdfrmttl nmtalttl~
							  nmmaettl nmpaittl cdnatopc cdocpttl tpcttrab~
							  cdempres nmextemp dsproftl cdnvlcgo cdturnos~
							  dtadmemp vlsalari tpdrendi vldrendi~
							  nrcpfemp cdufnatu inpolexp

    &SCOPED-DEFINE CAMPOS-CJE vlsalari nmconjug dtnasccj tpdoccje nrdoccje~
	                          idorgexp cdufdcje dtemdcje grescola cdfrmttl~
	                          cdnatopc cdocpcje tpcttrab nmextemp dsproftl~
	                          cdnvlcgo nrfonemp nrramemp cdturnos dtadmemp
    ASSIGN par_dscritic = ""
           par_cdcritic = 0
           aux_retorno = "NOK".

    BuscaPf: DO ON ERROR UNDO BuscaPf, LEAVE BuscaPf:
        EMPTY TEMP-TABLE tt-fcad-psfis.

        /* Busca dados do cooperado */
        FOR FIRST crabass FIELDS(qtfoltal)
                          WHERE crabass.cdcooper = par_cdcooper AND
                                crabass.nrdconta = par_nrdconta 
                                NO-LOCK:

        END.

        IF  NOT AVAILABLE crabass THEN
            DO:
               ASSIGN par_cdcritic = 9.
               LEAVE BuscaPf.
            END.

        FOR FIRST crabttl FIELDS({&CAMPOS-TTL} nmextttl idseqttl cdsexotl nrcpfcgc)
                          WHERE crabttl.cdcooper = par_cdcooper AND
                                crabttl.nrdconta = par_nrdconta AND
                                crabttl.idseqttl = par_idseqttl 
                                NO-LOCK:
        END.

        IF  NOT AVAILABLE crabttl THEN
            DO:
               ASSIGN par_dscritic = "Titular nao cadastrado".
               LEAVE BuscaPf.
            END.

        CREATE tt-fcad-psfis.

        ASSIGN tt-fcad-psfis.dspessoa = "FISICA"
               tt-fcad-psfis.qtfoltal = crabass.qtfoltal
               tt-fcad-psfis.nmextttl = aux_nrcardin[crabttl.idseqttl] + 
                                        " Titular: " + crabttl.nmextttl
               tt-fcad-psfis.nmextttl = FILL(" ",INT((76 - LENGTH
                                               (tt-fcad-psfis.nmextttl)) / 2)) +
                                        tt-fcad-psfis.nmextttl
               tt-fcad-psfis.nrcpfcgc = STRING(STRING
                                               (crabttl.nrcpfcgc,"99999999999"),
                                               "xxx.xxx.xxx-xx")
               tt-fcad-psfis.cdsexotl = (IF crabttl.cdsexotl = 1 
                                         THEN "M" ELSE "F").

        BUFFER-COPY crabttl USING {&CAMPOS-TTL} TO tt-fcad-psfis NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = ERROR-STATUS:GET-MESSAGE(1).
               LEAVE BuscaPf.
            END.

        /* Buscar a Nacionalidade */
        FOR FIRST crapnac FIELDS(dsnacion)
                          WHERE crapnac.cdnacion = crabttl.cdnacion
                                NO-LOCK:
            ASSIGN tt-fcad-psfis.dsnacion = crapnac.dsnacion.
        END.

        /* Retornar orgao expedidor */
        IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
            RUN sistema/generico/procedures/b1wgen0052b.p 
                PERSISTENT SET h-b1wgen0052b.

        ASSIGN tt-fcad-psfis.cdoedttl = "".
        RUN busca_org_expedidor IN h-b1wgen0052b 
                           ( INPUT crabttl.idorgexp,
                            OUTPUT tt-fcad-psfis.cdoedttl,
                            OUTPUT par_cdcritic, 
                            OUTPUT par_dscritic).

        DELETE PROCEDURE h-b1wgen0052b.   

        IF  RETURN-VALUE = "NOK" THEN
        DO:
            tt-fcad-psfis.cdoedttl = 'NAO CADAST.'.
        END.    

        /* deve mostrar o primeiro titular */
        IF  crabttl.idseqttl <> 1 THEN
            DO:
               FOR FIRST crapttl FIELDS(nmextttl inpolexp)
                                 WHERE crapttl.cdcooper = par_cdcooper AND
                                       crapttl.nrdconta = par_nrdconta AND
                                       crapttl.idseqttl = 1 
                                       NO-LOCK:

                   ASSIGN tt-fcad-psfis.nmprimtl = crapttl.nmextttl.
               END.
            END.

        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p 
                PERSISTENT SET h-b1wgen0060.

        DYNAMIC-FUNCTION("BuscaSituacaoCpf" IN h-b1wgen0060,
                          INPUT tt-fcad-psfis.cdsitcpf, 
                         OUTPUT tt-fcad-psfis.dssitcpf,
                         OUTPUT aux_dscritic).

        DYNAMIC-FUNCTION("BuscaHabilitacao" IN h-b1wgen0060,
                          INPUT tt-fcad-psfis.inhabmen,
                         OUTPUT tt-fcad-psfis.dshabmen,
                         OUTPUT aux_dscritic).

        DYNAMIC-FUNCTION("BuscaParentesco" IN h-b1wgen0060,
                          INPUT tt-fcad-psfis.cdgraupr,
                         OUTPUT tt-fcad-psfis.dsgraupr,
                         OUTPUT aux_dscritic).

        DYNAMIC-FUNCTION("BuscaEstadoCivil" IN h-b1wgen0060,
                          INPUT tt-fcad-psfis.cdestcvl,
                          INPUT "rsestcvl",
                         OUTPUT tt-fcad-psfis.dsestcvl,
                         OUTPUT aux_dscritic).

        DYNAMIC-FUNCTION("BuscaTipoNacion" IN h-b1wgen0060,
                          INPUT tt-fcad-psfis.tpnacion,
                          INPUT "restpnac",
                         OUTPUT tt-fcad-psfis.restpnac,
                         OUTPUT aux_dscritic).

        DYNAMIC-FUNCTION("BuscaGrauEscolar" IN h-b1wgen0060,
                          INPUT tt-fcad-psfis.grescola,
                         OUTPUT tt-fcad-psfis.dsescola,
                         OUTPUT aux_dscritic).

        DYNAMIC-FUNCTION("BuscaFormacao" IN h-b1wgen0060,
                          INPUT tt-fcad-psfis.cdfrmttl,
                         OUTPUT tt-fcad-psfis.rsfrmttl,
                         OUTPUT aux_dscritic).

        IF  tt-fcad-psfis.restpnac = "NAO CADASTRADO" THEN 
            ASSIGN tt-fcad-psfis.restpnac = "DESCONHECIDA".

        /* f_filiacao */
        CREATE tt-fcad-filia.
        ASSIGN tt-fcad-filia.nmmaettl = crabttl.nmmaettl
               tt-fcad-filia.nmpaittl = crabttl.nmpaittl.

        /* f_comercial */
        CREATE tt-fcad-comer.
        ASSIGN tt-fcad-comer.cdempres = crabttl.cdempres.

        
        /* Endereco Comercial */
        /* se for Emp. Diversas, pega da crapenc, senao pega da crapemp */
/*        IF((par_cdcooper = 2 AND tt-fcad-comer.cdempres = 88) OR
           (par_cdcooper <> 2 AND tt-fcad-comer.cdempres = 81)) THEN*/
            DO:
               FOR FIRST crabenc FIELDS(dsendere complend nmbairro nmcidade
                                        cdufende nrcxapst nrendere nrcepend)
                                 WHERE crabenc.cdcooper = par_cdcooper   AND
                                       crabenc.nrdconta = par_nrdconta   AND
                                       crabenc.idseqttl = par_idseqttl   AND
                                       crabenc.tpendass = 9 /* Comercial */ 
                                       NO-LOCK:

                   ASSIGN tt-fcad-comer.dsendere = crabenc.dsendere
                          tt-fcad-comer.complend = crabenc.complend
                          tt-fcad-comer.nmbairro = crabenc.nmbairro
                          tt-fcad-comer.nmcidade = crabenc.nmcidade
                          tt-fcad-comer.cdufende = crabenc.cdufende
                          tt-fcad-comer.nrcxapst = crabenc.nrcxapst
                          tt-fcad-comer.nrendere = crabenc.nrendere.
        
                   IF crabenc.nrcepend = 0 THEN
                      ASSIGN tt-fcad-comer.nrcepend = STRING(0).
                   ELSE 
                      ASSIGN tt-fcad-comer.nrcepend = STRING(crabenc.nrcepend,
                                                             "99999,999").
               END.
            END.
        /*ELSE
           DO:
              FOR FIRST crapemp FIELDS(dsendemp dscomple nmbairro nmcidade 
                                       cdufdemp nrendemp nrcepend) 
                                WHERE crapemp.cdcooper = par_cdcooper AND
                                      crapemp.cdempres = tt-fcad-comer.cdempres
                                      NO-LOCK:

                  ASSIGN tt-fcad-comer.dsendere = CAPS(crapemp.dsendemp)
                         tt-fcad-comer.complend = CAPS(crapemp.dscomple)
                         tt-fcad-comer.nmbairro = CAPS(crapemp.nmbairro)
                         tt-fcad-comer.nmcidade = CAPS(crapemp.nmcidade)
                         tt-fcad-comer.cdufende = CAPS(crapemp.cdufdemp)
                         tt-fcad-comer.nrendere = crapemp.nrendemp.
                     
                  IF crapemp.nrcepend = 0 THEN
                     ASSIGN tt-fcad-comer.nrcepend = STRING(0).
                  ELSE 
                     ASSIGN tt-fcad-comer.nrcepend = 
                                   STRING(crapemp.nrcepend,"99999,999").
              END.

           END.*/
        

        /* Empresa */
        FOR FIRST crapemp FIELDS(nmresemp)
                          WHERE crapemp.cdcooper = par_cdcooper           AND
                                crapemp.cdempres = tt-fcad-comer.cdempres
                                NO-LOCK:

            ASSIGN tt-fcad-comer.nmresemp = crapemp.nmresemp.

        END.

        /* Pessoa politicamente exposta (PPE)*/
        
        FOR FIRST tbcadast_politico_exposto WHERE
            tbcadast_politico_exposto.cdcooper = par_cdcooper AND
            tbcadast_politico_exposto.nrdconta = par_nrdconta AND
            tbcadast_politico_exposto.idseqttl = par_idseqttl 
            NO-LOCK:

            ASSIGN 
            tt-fcad-comer.cdocupacao       = tbcadast_politico_exposto.cdocupacao      
            tt-fcad-comer.cdrelacionamento = tbcadast_politico_exposto.cdrelacionamento
            tt-fcad-comer.dtinicio         = tbcadast_politico_exposto.dtinicio        
            tt-fcad-comer.dttermino        = tbcadast_politico_exposto.dttermino       
            tt-fcad-comer.nmempresa        = tbcadast_politico_exposto.nmempresa       
            tt-fcad-comer.nmpolitico       = tbcadast_politico_exposto.nmpolitico      
            tt-fcad-comer.nrcnpj_empresa   = tbcadast_politico_exposto.nrcnpj_empresa  
            tt-fcad-comer.nrcpf_politico   = tbcadast_politico_exposto.nrcpf_politico  
            tt-fcad-comer.tpexposto        = tbcadast_politico_exposto.tpexposto.

            FOR FIRST gncdocp WHERE gncdocp.cdocupa = tbcadast_politico_exposto.cdocupacao
                NO-LOCK:
                tt-fcad-comer.dsdocupa = gncdocp.dsdocupa.
            END.
            
            FOR FIRST craptab
                WHERE craptab.cdcooper = 1 AND
                      craptab.nmsistem = 'CRED'       AND
                      craptab.tptabela = 'GENERI'     AND
                      craptab.cdempres = 0            AND
                      craptab.cdacesso = 'VINCULOTTL' AND
                      craptab.tpregist = 0 NO-LOCK:
                /* dstextab: conjuge,1,pai,3*/
                ASSIGN tt-fcad-comer.dsrelacionamento = 
                     ENTRY(LOOKUP(STRING(tbcadast_politico_exposto.cdrelacionamento),
                           craptab.dstextab) - 1,craptab.dstextab) NO-ERROR.
            END.
        END.

        ASSIGN tt-fcad-comer.nmextttl = crabttl.nmextttl.


        ASSIGN tt-fcad-comer.nmextemp = crabttl.nmextemp
               tt-fcad-comer.dsproftl = crabttl.dsproftl
               tt-fcad-comer.vlsalari = crabttl.vlsalari
               tt-fcad-comer.cdturnos = crabttl.cdturnos
               tt-fcad-comer.dtadmemp = crabttl.dtadmemp
               tt-fcad-comer.cdnatopc = crabttl.cdnatopc
               tt-fcad-comer.cdocpttl = crabttl.cdocpttl
               tt-fcad-comer.tpcttrab = crabttl.tpcttrab
               tt-fcad-comer.cdnvlcgo = crabttl.cdnvlcgo
               tt-fcad-comer.tpdrend1 = crabttl.tpdrendi[1]
               tt-fcad-comer.vldrend1 = crabttl.vldrendi[1]
               tt-fcad-comer.tpdrend2 = crabttl.tpdrendi[2]
               tt-fcad-comer.vldrend2 = crabttl.vldrendi[2]
               tt-fcad-comer.tpdrend3 = crabttl.tpdrendi[3]
               tt-fcad-comer.vldrend3 = crabttl.vldrendi[3]
               tt-fcad-comer.tpdrend4 = crabttl.tpdrendi[4]
               tt-fcad-comer.vldrend4 = crabttl.vldrendi[4]
               tt-fcad-comer.nrcgcemp = STRING(STRING
                                               (crabttl.nrcpfemp,
                                                "99999999999999"),
                                               "XX.XXX.XXX/XXXX-XX").

        /* Descricao do(s) rendimento(s) */
        DYNAMIC-FUNCTION("BuscaTipoRendimento" IN h-b1wgen0060,
                         INPUT par_cdcooper,
                         INPUT tt-fcad-comer.tpdrend1,
                        OUTPUT tt-fcad-comer.dstipre1,
                        OUTPUT par_dscritic ).

        DYNAMIC-FUNCTION("BuscaTipoRendimento" IN h-b1wgen0060,
                         INPUT par_cdcooper,
                         INPUT tt-fcad-comer.tpdrend2,
                        OUTPUT tt-fcad-comer.dstipre2,
                        OUTPUT par_dscritic ).

        DYNAMIC-FUNCTION("BuscaTipoRendimento" IN h-b1wgen0060,
                         INPUT par_cdcooper,
                         INPUT tt-fcad-comer.tpdrend3,
                        OUTPUT tt-fcad-comer.dstipre3,
                        OUTPUT par_dscritic ).

        DYNAMIC-FUNCTION("BuscaTipoRendimento" IN h-b1wgen0060,
                         INPUT par_cdcooper,
                         INPUT tt-fcad-comer.tpdrend4,
                        OUTPUT tt-fcad-comer.dstipre4,
                        OUTPUT par_dscritic ).

        ASSIGN par_dscritic = "".

        DYNAMIC-FUNCTION("BuscaNatOcupacao" IN h-b1wgen0060,
                          INPUT tt-fcad-comer.cdnatopc,
                         OUTPUT tt-fcad-comer.rsnatocp,
                         OUTPUT aux_dscritic).

        DYNAMIC-FUNCTION("BuscaOcupacao" IN h-b1wgen0060,
                          INPUT tt-fcad-comer.cdocpttl,
                         OUTPUT tt-fcad-comer.rsocupa,
                         OUTPUT aux_dscritic).

        DYNAMIC-FUNCTION("BuscaTpContrTrab" IN h-b1wgen0060,
                          INPUT tt-fcad-comer.tpcttrab,
                         OUTPUT tt-fcad-comer.dsctrtab,
                         OUTPUT aux_dscritic).

        DYNAMIC-FUNCTION("BuscaNivelCargo" IN h-b1wgen0060,
                          INPUT tt-fcad-comer.cdnvlcgo,
                         OUTPUT tt-fcad-comer.rsnvlcgo,
                         OUTPUT aux_dscritic).

        IF  tt-fcad-comer.rsnvlcgo = "NAO INFORMADO" THEN
            ASSIGN tt-fcad-comer.rsnvlcgo = "".

        /* f_conjuge_pf */
        /* Conjuge */
        IF   crabttl.cdestcvl <> 1 AND       /*SOLTEIRO*/
             crabttl.cdestcvl <> 5 AND       /*VIUVO*/
             crabttl.cdestcvl <> 6 AND       /*SEPARADO*/
             crabttl.cdestcvl <> 7 THEN     /*DIVORCIADO*/
             DO:

                 CREATE tt-fcad-cjuge.

                 FOR FIRST crapcje FIELDS({&CAMPOS-CJE} nrdocnpj 
                                          nrcpfcjg nrctacje)
                                   WHERE crapcje.cdcooper = par_cdcooper AND
                                         crapcje.nrdconta = par_nrdconta AND
                                         crapcje.idseqttl = par_idseqttl
                                         NO-LOCK:
                     
                     BUFFER-COPY crapcje USING {&CAMPOS-CJE} TO tt-fcad-cjuge
                         ASSIGN
                            tt-fcad-cjuge.nrctacje = TRIM(STRING(
                                                       crapcje.nrctacje,
                                                       "zzzz,zzz,9"))
                            tt-fcad-cjuge.nrcpfemp = STRING(crapcje.nrdocnpj)
                            tt-fcad-cjuge.nrcpfcje = STRING(STRING
                                                             (crapcje.nrcpfcjg,
                                                              "99999999999"),
                                                             "xxx.xxx.xxx-xx")
                            tt-fcad-cjuge.gresccje = crapcje.grescola
                            tt-fcad-cjuge.cdocpttl = crapcje.cdocpcje.
                 
                     /* Retornar orgao expedidor */
                     IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                        RUN sistema/generico/procedures/b1wgen0052b.p 
                            PERSISTENT SET h-b1wgen0052b.

                     ASSIGN tt-fcad-cjuge.cdoedcje = "".
                     RUN busca_org_expedidor IN h-b1wgen0052b 
                                       ( INPUT crapcje.idorgexp,
                                        OUTPUT tt-fcad-cjuge.cdoedcje,
                                        OUTPUT aux_cdcritic, 
                                        OUTPUT aux_dscritic).

                     DELETE PROCEDURE h-b1wgen0052b.   

                     IF  RETURN-VALUE = "NOK" THEN
                     DO:
                        tt-fcad-cjuge.cdoedcje = 'NAO CADAST'.
                 END.
                 
                 END.

                 FOR FIRST crapttl FIELDS(nrdconta nrcpfcgc nrcpfemp
                                          nmextttl dtnasttl tpdocttl
                                          nrdocttl cdufdttl dtemdttl
                                          grescola cdfrmttl cdnatopc
                                          cdocpttl tpcttrab dsproftl
                                          cdnvlcgo cdturnos idorgexp
                                          dtadmemp vlsalari )
                     WHERE crapttl.nrdconta = crapcje.nrctacje AND
                           crapttl.cdcooper = par_cdcooper NO-LOCK:

                     ASSIGN
                         tt-fcad-cjuge.nrctacje = TRIM(STRING(crapttl.nrdconta,
                                                    "zzzz,zzz,9"))
                         tt-fcad-cjuge.nrcpfcje = STRING(STRING
                                                          (crapttl.nrcpfcgc,
                                                           "99999999999"),
                                                          "xxx.xxx.xxx-xx")
                         tt-fcad-cjuge.nmconjug = crapttl.nmextttl
                         tt-fcad-cjuge.dtnasccj = crapttl.dtnasttl
                         tt-fcad-cjuge.tpdoccje = crapttl.tpdocttl
                         tt-fcad-cjuge.nrdoccje = crapttl.nrdocttl
                         tt-fcad-cjuge.cdufdcje = crapttl.cdufdttl
                         tt-fcad-cjuge.dtemdcje = crapttl.dtemdttl
                         tt-fcad-cjuge.gresccje = crapttl.grescola
                         tt-fcad-cjuge.cdfrmttl = crapttl.cdfrmttl
                         tt-fcad-cjuge.cdnatopc = crapttl.cdnatopc
                         tt-fcad-cjuge.cdocpttl = crapttl.cdocpttl
                         tt-fcad-cjuge.tpcttrab = crapttl.tpcttrab
                         tt-fcad-cjuge.nrcpfemp = STRING(crapttl.nrcpfemp)
                         tt-fcad-cjuge.dsproftl = crapttl.dsproftl
                         tt-fcad-cjuge.cdnvlcgo = crapttl.cdnvlcgo
                         tt-fcad-cjuge.cdturnos = crapttl.cdturnos
                         tt-fcad-cjuge.dtadmemp = crapttl.dtadmemp
                         tt-fcad-cjuge.vlsalari = crapttl.vlsalari.                         

                     /* Retornar orgao expedidor */
                     IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                        RUN sistema/generico/procedures/b1wgen0052b.p 
                            PERSISTENT SET h-b1wgen0052b.

                     ASSIGN tt-fcad-cjuge.cdoedcje = "".
                     RUN busca_org_expedidor IN h-b1wgen0052b 
                                       (INPUT crapttl.idorgexp,
                                        OUTPUT tt-fcad-cjuge.cdoedcje,
                                        OUTPUT aux_cdcritic, 
                                        OUTPUT aux_dscritic).

                     DELETE PROCEDURE h-b1wgen0052b.   

                     IF  RETURN-VALUE = "NOK" THEN
                     DO:
                         tt-fcad-cjuge.cdoedcje = "NAO CADAST.".
                     END.

                     /* Telefone Comercial*/
                     FOR FIRST craptfc FIELDS(nrdramal)
                         WHERE craptfc.nrdconta = crapttl.nrdconta AND
                               craptfc.cdcooper = par_cdcooper     AND
                               craptfc.tptelefo = 3 
                               NO-LOCK:

                         ASSIGN tt-fcad-cjuge.nrfonemp = string(craptfc.nrtelefo)
						        tt-fcad-cjuge.nrramemp = craptfc.nrdramal.

                     END.
                 END.
                                     
                 DYNAMIC-FUNCTION("BuscaGrauEscolar" IN h-b1wgen0060,
                                   INPUT tt-fcad-cjuge.gresccje,
                                  OUTPUT tt-fcad-cjuge.dsescola,
                                  OUTPUT aux_dscritic).

                 DYNAMIC-FUNCTION("BuscaFormacao" IN h-b1wgen0060,
                                   INPUT tt-fcad-cjuge.cdfrmttl,
                                  OUTPUT tt-fcad-cjuge.rsfrmttl,
                                  OUTPUT aux_dscritic).

                 DYNAMIC-FUNCTION("BuscaNatOcupacao" IN h-b1wgen0060,
                                   INPUT tt-fcad-cjuge.cdnatopc,
                                  OUTPUT tt-fcad-cjuge.rsnatocp,
                                  OUTPUT aux_dscritic).

                 DYNAMIC-FUNCTION("BuscaOcupacao" IN h-b1wgen0060,
                                   INPUT tt-fcad-cjuge.cdocpttl,
                                  OUTPUT tt-fcad-cjuge.rsocupa,
                                  OUTPUT aux_dscritic).

                 DYNAMIC-FUNCTION("BuscaTpContrTrab" IN h-b1wgen0060,
                                   INPUT tt-fcad-cjuge.tpcttrab,
                                  OUTPUT tt-fcad-cjuge.dsctrtab,
                                  OUTPUT aux_dscritic).

                 DYNAMIC-FUNCTION("BuscaNivelCargo" IN h-b1wgen0060,
                                   INPUT tt-fcad-cjuge.cdnvlcgo,
                                  OUTPUT tt-fcad-cjuge.rsnvlcgo,
                                  OUTPUT aux_dscritic).

                 IF  tt-fcad-cjuge.rsnvlcgo = "NAO INFORMADO" THEN
                     ASSIGN tt-fcad-cjuge.rsnvlcgo = "".
             END.

        /* f_dependentes */
        FOR EACH crapdep FIELDS(nmdepend tpdepend dtnascto)
                         WHERE crapdep.cdcooper = par_cdcooper   AND
                               crapdep.nrdconta = par_nrdconta   
                               NO-LOCK:

            CREATE tt-fcad-depen.

            ASSIGN tt-fcad-depen.nmdepend = crapdep.nmdepend 
                   tt-fcad-depen.tpdepend = crapdep.tpdepend
                   tt-fcad-depen.dtnascto = crapdep.dtnascto.

            FOR FIRST craptab FIELDS(dstextab)
                              WHERE craptab.cdcooper = par_cdcooper  AND
                                    craptab.nmsistem = "CRED"        AND
                                    craptab.tptabela = "GENERI"      AND
                                    craptab.cdempres = 0             AND
                                    craptab.cdacesso = "DSTPDEPEND"  AND
                                    craptab.tpregist = crapdep.tpdepend 
                                    NO-LOCK:

                ASSIGN tt-fcad-depen.dstextab = craptab.dstextab.

            END.

        END.

       
        /* lista de contatos */
        FOR EACH crapavt FIELDS(nrdctato nmdavali nrcepend dsendres 
                                nrendere complend nmbairro nmcidade
                                cdufresd nrcxapst nrtelefo dsdemail)
                         WHERE crapavt.cdcooper = par_cdcooper   AND
                               crapavt.tpctrato = 5 /*contato*/  AND
                               crapavt.nrdconta = par_nrdconta   AND
                               crapavt.nrctremp = par_idseqttl   
                               NO-LOCK BREAK BY crapavt.nrdconta:
        
            CREATE tt-fcad-ctato.

            ASSIGN tt-fcad-ctato.nrdctato = TRIM(STRING(crapavt.nrdctato,
                                                        "zzzz,zzz,9")).
        
            /* Se for associado, pega os dados da crapass */
            IF crapavt.nrdctato <> 0 THEN
               DO:
                  /* Associado */
                  FOR FIRST crabass FIELDS(nmprimtl)
                                    WHERE crabass.cdcooper = par_cdcooper AND
                                          crabass.nrdconta = crapavt.nrdctato
                                          NO-LOCK:
                      ASSIGN tt-fcad-ctato.nmdavali = crabass.nmprimtl.

                  END.
                                     
                  /* Telefones */
                  FOR FIRST craptfc FIELDS(nrtelefo)
                                    WHERE craptfc.cdcooper = par_cdcooper AND
                                          craptfc.idseqttl = 1            AND
                                          craptfc.cdseqtfc = 1            AND
                                          craptfc.nrdconta = crapavt.nrdctato
                                          NO-LOCK:
        
                      tt-fcad-ctato.nrtelefo = STRING(craptfc.nrtelefo).
                  END.
                                            
                  /* Emails */
                  FOR FIRST crapcem FIELDS(dsdemail)
                                    WHERE crapcem.cdcooper = par_cdcooper AND
                                          crapcem.idseqttl = 1            AND
                                          crapcem.cddemail = 1            AND
                                          crapcem.nrdconta = crapavt.nrdctato
                                          NO-LOCK:
        
                      ASSIGN tt-fcad-ctato.dsdemail = crapcem.dsdemail.
                  END.
                                     
                  /* Endereco */
                  FOR FIRST crapenc FIELDS(nrcepend dsendere nrendere 
                                           complend nmbairro nmcidade 
                                           cdufende nrcxapst)
                                    WHERE crapenc.cdcooper = par_cdcooper AND
                                          crapenc.idseqttl = 1            AND
                                          crapenc.cdseqinc = 1            AND
                                          crapenc.nrdconta = crapavt.nrdctato
                                          NO-LOCK:

                      ASSIGN tt-fcad-ctato.dsendere = crapenc.dsendere
                             tt-fcad-ctato.nrendere = crapenc.nrendere
                             tt-fcad-ctato.complend = crapenc.complend
                             tt-fcad-ctato.nmbairro = crapenc.nmbairro
                             tt-fcad-ctato.nmcidade = crapenc.nmcidade
                             tt-fcad-ctato.cdufende = crapenc.cdufende
                             tt-fcad-ctato.nrcxapst = crapenc.nrcxapst.
        
                      IF  crapenc.nrcepend <> 0 THEN
                          ASSIGN tt-fcad-ctato.nrcepend = STRING(
                                                           crapenc.nrcepend,
                                                           "99999,999").
                      ELSE
                          ASSIGN tt-fcad-ctato.nrcepend = STRING(0).
                  END.
               END.
            ELSE
               DO:
                  ASSIGN tt-fcad-ctato.nmdavali = crapavt.nmdavali
                         tt-fcad-ctato.dsendere = crapavt.dsendres[1]
                         tt-fcad-ctato.nrendere = crapavt.nrendere
                         tt-fcad-ctato.complend = crapavt.complend
                         tt-fcad-ctato.nmbairro = crapavt.nmbairro
                         tt-fcad-ctato.nmcidade = crapavt.nmcidade
                         tt-fcad-ctato.cdufende = crapavt.cdufresd
                         tt-fcad-ctato.nrcxapst = crapavt.nrcxapst
                         tt-fcad-ctato.nrtelefo = crapavt.nrtelefo
                         tt-fcad-ctato.dsdemail = crapavt.dsdemail.
        
                  IF crapavt.nrcepend <> 0 THEN
                     ASSIGN tt-fcad-ctato.nrcepend = STRING(crapavt.nrcepend,
                                                             "99999,999").
                  ELSE 
                     ASSIGN tt-fcad-ctato.nrcepend = STRING(0).

               END.
        END.
        
        FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper   AND
                               crapavt.tpctrato = 6 /*juridica*/ AND
                               crapavt.nrdconta = par_nrdconta   AND
                               crapavt.nrctremp = par_idseqttl
                               NO-LOCK:
           
           CREATE tt-fcad-procu.
                              
           ASSIGN tt-fcad-procu.nrdctato = crapavt.nrdctato
                  tt-fcad-procu.nrcpfcgc = STRING(STRING(crapavt.nrcpfcgc,
                                               "99999999999"),"xxx.xxx.xxx-xx") 
                  tt-fcad-procu.dtvalida = IF crapavt.dtvalida = 12/31/9999 
                                           THEN "INDETERMINADO"
                                           ELSE STRING(crapavt.dtvalida,
                                                       "99/99/9999")
                  tt-fcad-procu.cdsexcto = IF crapavt.cdsexcto = 1 
                                           THEN "M" ELSE "F"
                  tt-fcad-procu.nmdavali = crapavt.nmdavali
                  tt-fcad-procu.tpdocava = crapavt.tpdocava
                  tt-fcad-procu.nrdocava = crapavt.nrdocava
                  tt-fcad-procu.cdufddoc = crapavt.cdufddoc
                  tt-fcad-procu.dtemddoc = crapavt.dtemddoc
                  tt-fcad-procu.dtnascto = crapavt.dtnascto
                  tt-fcad-procu.cdestcvl = crapavt.cdestcvl
                  tt-fcad-procu.cdnacion = crapavt.cdnacion
                  tt-fcad-procu.dsnatura = crapavt.dsnatura
                  tt-fcad-procu.nmmaecto = crapavt.nmmaecto
                  tt-fcad-procu.nmpaicto = crapavt.nmpaicto
                  /*tt-fcad-procu.vledvmto = crapavt.vledvmto*/
                  tt-fcad-procu.dsendere = crapavt.dsendres[1]
                  tt-fcad-procu.nrendere = crapavt.nrendere
                  tt-fcad-procu.complend = crapavt.complend
                  tt-fcad-procu.nmbairro = crapavt.nmbairro
                  tt-fcad-procu.nmcidade = crapavt.nmcidade
                  tt-fcad-procu.cdufende = crapavt.cdufresd
                  tt-fcad-procu.nrcxapst = crapavt.nrcxapst
                  tt-fcad-procu.inhabmen = crapavt.inhabmen
                  tt-fcad-procu.dthabmen = crapavt.dthabmen
                  tt-fcad-procu.cpfprocu = crapavt.nrcpfcgc.
                    
                  /* Buscar a Nacionalidade */
                  FOR FIRST crapnac FIELDS(dsnacion)
                                    WHERE crapnac.cdnacion = crapavt.cdnacion
                                          NO-LOCK:
                      ASSIGN tt-fcad-procu.dsnacion = crapnac.dsnacion.
                  END.

                  /* Retornar orgao expedidor */
                   IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                      RUN sistema/generico/procedures/b1wgen0052b.p 
                          PERSISTENT SET h-b1wgen0052b.

                   ASSIGN tt-fcad-procu.cdoeddoc = "".
                   RUN busca_org_expedidor IN h-b1wgen0052b 
                                     (INPUT crapavt.idorgexp,
                                      OUTPUT tt-fcad-procu.cdoeddoc,
                                      OUTPUT aux_cdcritic, 
                                      OUTPUT aux_dscritic).

                   DELETE PROCEDURE h-b1wgen0052b.   

                   IF  RETURN-VALUE = "NOK" THEN
                   DO:
                       tt-fcad-procu.cdoeddoc = "NAO CADAST.".
                   END.
                  
                  FOR EACH crappod WHERE crappod.cdcooper = par_cdcooper     AND
                                         crappod.nrdconta = par_nrdconta     AND
                                         crappod.nrctapro = crapavt.nrdctato AND
                                         crappod.nrcpfpro = crapavt.nrcpfcgc
                                         NO-LOCK:
                    CREATE tt-fcad-poder.
                    
                    ASSIGN tt-fcad-poder.nrdconta = par_nrdconta
                           tt-fcad-poder.nrctapro = crapavt.nrdctato
                           tt-fcad-poder.nrcpfcgc = STRING(
                                                    STRING(crappod.nrcpfpro,
                                                    "99999999999"),
                                                    "xxx.xxx.xxx-xx")
                           tt-fcad-poder.dscpoder = STRING(crappod.cddpoder)
                           tt-fcad-poder.flgisola = STRING(crappod.flgisola)
                           tt-fcad-poder.flgconju = STRING(crappod.flgconju)
                           tt-fcad-poder.dsoutpod = crappod.dsoutpod.
                  END.

           DYNAMIC-FUNCTION("BuscaHabilitacao" IN h-b1wgen0060,
                            INPUT tt-fcad-procu.inhabmen,
                            OUTPUT tt-fcad-procu.dshabmen,
                            OUTPUT aux_dscritic).

           IF crapavt.nrcepend <> 0 THEN
              ASSIGN tt-fcad-procu.nrcepend = STRING(crapavt.nrcepend,
                                                      "99999,999").
           ELSE
              ASSIGN tt-fcad-procu.nrcepend = STRING(0).

           /* Bens do procurador do cooperado */
         /*  DO  aux_contador = 1 TO EXTENT(crapavt.dsrelbem):
               IF  crapavt.dsrelbem[aux_contador] = "" THEN
                   NEXT.

               CREATE tt-fcad-bensp.

               ASSIGN tt-fcad-bensp.nrcpfcgc = tt-fcad-procu.nrcpfcgc
                      tt-fcad-bensp.dsrelbem = crapavt.dsrelbem[aux_contador]
                      tt-fcad-bensp.persemon = crapavt.persemon[aux_contador]
                      tt-fcad-bensp.qtprebem = crapavt.qtprebem[aux_contador]
                      tt-fcad-bensp.vlprebem = crapavt.vlprebem[aux_contador]
                      tt-fcad-bensp.vlrdobem = crapavt.vlrdobem[aux_contador].

           END.
           */
           /* buscar dados do contato */
           FOR FIRST crabass FIELDS(cdsexotl nmprimtl tpdocptl nrdocptl
                                    idorgexp cdufdptl dtemdptl dsproftl
                                    dtnasctl cdnacion
                                    nmmaeptl nmpaiptl nrdconta)
                              WHERE crabass.cdcooper = par_cdcooper     AND
                                    crabass.nrdconta = crapavt.nrdctato 
                                    NO-LOCK:

               /* Valor do endividamento do procurador */
            /*   FOR EACH crapsdv FIELDS(vldsaldo tpdsaldo)
                                WHERE crapsdv.cdcooper = par_cdcooper     AND
                                      crapsdv.nrdconta = crabass.nrdconta AND
                                CAN-DO("1,2,3,6",STRING(crapsdv.tpdsaldo))
                                NO-LOCK:

                   ASSIGN tt-fcad-procu.vledvmto = tt-fcad-procu.vledvmto +
                                                   crapsdv.vldsaldo.
               END.*/

               ASSIGN tt-fcad-procu.cdsexcto = IF crabass.cdsexotl = 1 THEN 
                                                  "M" 
                                               ELSE 
                                                  "F"
                      tt-fcad-procu.nmdavali = crabass.nmprimtl
                      tt-fcad-procu.tpdocava = crabass.tpdocptl
                      tt-fcad-procu.nrdocava = crabass.nrdocptl
                      tt-fcad-procu.cdufddoc = crabass.cdufdptl
                      tt-fcad-procu.dtemddoc = crabass.dtemdptl
                      tt-fcad-procu.dtnascto = crabass.dtnasctl
                      tt-fcad-procu.cdnacion = crabass.cdnacion.

               /* Buscar a Nacionalidade */
               FOR FIRST crapnac FIELDS(dsnacion)
                                 WHERE crapnac.cdnacion = crabass.cdnacion
                                       NO-LOCK:
                   ASSIGN tt-fcad-procu.dsnacion = crapnac.dsnacion.
               END.

               /* Retornar orgao expedidor */
               IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                  RUN sistema/generico/procedures/b1wgen0052b.p 
                      PERSISTENT SET h-b1wgen0052b.

               ASSIGN tt-fcad-procu.cdoeddoc = "".
               RUN busca_org_expedidor IN h-b1wgen0052b 
                                 (INPUT crabass.idorgexp,
                                  OUTPUT tt-fcad-procu.cdoeddoc,
                                  OUTPUT aux_cdcritic, 
                                  OUTPUT aux_dscritic).

               DELETE PROCEDURE h-b1wgen0052b.   

               IF  RETURN-VALUE = "NOK" THEN
               DO:
                   tt-fcad-procu.cdoeddoc = "NAO CADAST.".
               END. 

               /* Filiaçao e naturalidade, pegos da crapttl */
                           FOR FIRST crabttl FIELDS(dsnatura nmmaettl nmpaittl cdestcvl)
                                   WHERE crabttl.cdcooper = par_cdcooper     AND
                                         crabttl.nrdconta = crabass.nrdconta AND
                                         crabttl.idseqttl = 1 
                                         NO-LOCK:

                   ASSIGN tt-fcad-procu.dsnatura = crabttl.dsnatura
                          tt-fcad-procu.nmmaecto = crabttl.nmmaettl
                          tt-fcad-procu.nmpaicto = crabttl.nmpaittl
                          tt-fcad-procu.cdestcvl = crabttl.cdestcvl.
               END.

               /* Bens do representante cooperado */
               /*FOR EACH tt-fcad-bensp WHERE tt-fcad-bensp.nrcpfcgc = 
                                            tt-fcad-procu.nrcpfcgc:
                   DELETE tt-fcad-bensp.
               END.

               FOR EACH crapbem FIELDS(dsrelbem persemon qtprebem
                                       vlprebem vlrdobem)
                                WHERE crapbem.cdcooper = par_cdcooper     AND
                                      crapbem.nrdconta = crabass.nrdconta AND
                                      crapbem.idseqttl = 1 
                                      NO-LOCK:

                   CREATE tt-fcad-bensp.

                   ASSIGN tt-fcad-bensp.nrcpfcgc = tt-fcad-procu.nrcpfcgc
                          tt-fcad-bensp.dsrelbem = crapbem.dsrelbem
                          tt-fcad-bensp.persemon = crapbem.persemon
                          tt-fcad-bensp.qtprebem = crapbem.qtprebem
                          tt-fcad-bensp.vlprebem = crapbem.vlprebem
                          tt-fcad-bensp.vlrdobem = crapbem.vlrdobem.

               END.
               */
           END.           

           /* Endereco */
           FOR FIRST crapenc FIELDS(nrcepend dsendere nrendere complend
                                    nmbairro nmcidade cdufende nrcxapst)
                             WHERE crapenc.cdcooper = par_cdcooper       AND
                                   crapenc.nrdconta = crapavt.nrdctato   AND
                                   crapenc.idseqttl = 1                  AND
                                   crapenc.cdseqinc = 1                  AND
                                   crapenc.tpendass = 10 /*Residencial*/
                                   NO-LOCK:

               ASSIGN tt-fcad-procu.dsendere = crapenc.dsendere
                      tt-fcad-procu.nrendere = crapenc.nrendere
                      tt-fcad-procu.complend = crapenc.complend
                      tt-fcad-procu.nmbairro = crapenc.nmbairro
                      tt-fcad-procu.nmcidade = crapenc.nmcidade
                      tt-fcad-procu.cdufende = crapenc.cdufende
                      tt-fcad-procu.nrcxapst = crapenc.nrcxapst.

               IF crapenc.nrcepend <> 0 THEN
                  ASSIGN tt-fcad-procu.nrcepend = STRING(crapenc.nrcepend,
                                                         "99999,999").
               ELSE
                  ASSIGN tt-fcad-procu.nrcepend = STRING(0).
           END.

           DYNAMIC-FUNCTION("BuscaEstadoCivil" IN h-b1wgen0060,
                             INPUT tt-fcad-procu.cdestcvl,
                             INPUT "rsestcvl",
                            OUTPUT tt-fcad-procu.dsestcvl,
                            OUTPUT aux_dscritic).

        END.

              
        /* lista de responsaveis legais */
        FOR EACH crapcrl WHERE crapcrl.cdcooper = par_cdcooper AND
                               crapcrl.nrctamen = par_nrdconta AND
                               crapcrl.idseqmen = par_idseqttl
                               NO-LOCK BREAK BY crapcrl.nrdconta:
        
            
            CREATE tt-fcad-respl.

            ASSIGN tt-fcad-respl.nrdconta = TRIM(STRING(crapcrl.nrdconta,
                                                        "zzzz,zzz,9")).

            /* Se for associado, pega os dados da crapttl */
            IF crapcrl.nrdconta <> 0 THEN
               DO:
                  /* 1o. Titular */
                  FOR FIRST crabttl FIELDS(nrcpfcgc nmextttl tpdocttl 
                                           nrdocttl idorgexp cdufdttl 
                                           dtemdttl dtnasttl cdsexotl 
                                           cdestcvl cdnacion dsnatura
                                           nmmaettl nmpaittl)
                                    WHERE crabttl.cdcooper = par_cdcooper     AND
                                          crabttl.nrdconta = crapcrl.nrdconta AND
                                          crabttl.idseqttl = 1 
                                          NO-LOCK:

                      ASSIGN tt-fcad-respl.nmrespon = crabttl.nmextttl
                             tt-fcad-respl.tpdeiden = crabttl.tpdocttl
                             tt-fcad-respl.nridenti = crabttl.nrdocttl
                             tt-fcad-respl.cdufiden = crabttl.cdufdttl
                             tt-fcad-respl.dtemiden = crabttl.dtemdttl
                             tt-fcad-respl.dtnascin = crabttl.dtnasttl
                             tt-fcad-respl.cddosexo = IF crabttl.cdsexotl = 1 
                                                      THEN "M" ELSE "F"
                             tt-fcad-respl.cdestciv = crabttl.cdestcvl
                             tt-fcad-respl.cdnacion = crabttl.cdnacion
                             tt-fcad-respl.dsnatura = crabttl.dsnatura
                             tt-fcad-respl.nmmaersp = crabttl.nmmaettl
                             tt-fcad-respl.nmpairsp = crabttl.nmpaittl
                             tt-fcad-respl.nrcpfcgc = STRING(STRING
                                                             (crabttl.nrcpfcgc,
                                                              "99999999999"),
                                                             "xxx.xxx.xxx-xx")
                             tt-fcad-respl.nrcpfmen = crapcrl.nrcpfmen.

                     /* Buscar a Nacionalidade */
                     FOR FIRST crapnac FIELDS(dsnacion)
                                       WHERE crapnac.cdnacion = crabttl.cdnacion
                                             NO-LOCK:
                         ASSIGN tt-fcad-respl.dsnacion = crapnac.dsnacion.
                     END.

                     /* Retornar orgao expedidor */
                     IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                        RUN sistema/generico/procedures/b1wgen0052b.p 
                            PERSISTENT SET h-b1wgen0052b.

                     ASSIGN tt-fcad-respl.dsorgemi = "".
                     RUN busca_org_expedidor IN h-b1wgen0052b 
                                       (INPUT crabttl.idorgexp,
                                        OUTPUT tt-fcad-respl.dsorgemi,
                                        OUTPUT aux_cdcritic, 
                                        OUTPUT aux_dscritic).

                     DELETE PROCEDURE h-b1wgen0052b.   

                     IF  RETURN-VALUE = "NOK" THEN
                     DO:
                         tt-fcad-respl.dsorgemi = "NAO CADAST.".
                  END.

                  END.
       
                  /* Endereco */
                  FOR FIRST crapenc FIELDS(nrcepend dsendere nrendere 
                                           complend nmbairro nmcidade 
                                           cdufende nrcxapst)
                                    WHERE crapenc.cdcooper = par_cdcooper     AND
                                          crapenc.nrdconta = crapcrl.nrdconta AND
                                          crapenc.idseqttl = 1                AND
                                          crapenc.cdseqinc = 1                AND
                                          crapenc.tpendass = 10 /*Residencial*/
                                          NO-LOCK:

                      ASSIGN tt-fcad-respl.dsendres = crapenc.dsendere
                             tt-fcad-respl.nrendres = crapenc.nrendere
                             tt-fcad-respl.dscomres = crapenc.complend
                             tt-fcad-respl.dsbaires = crapenc.nmbairro
                             tt-fcad-respl.dscidres = crapenc.nmcidade
                             tt-fcad-respl.dsdufres = crapenc.cdufende
                             tt-fcad-respl.nrcxpost = crapenc.nrcxapst.
    
                      IF crapenc.nrcepend <> 0 THEN
                         ASSIGN tt-fcad-respl.cdcepres = 
                                          STRING(crapenc.nrcepend,"99999,999").
                      ELSE 
                        ASSIGN tt-fcad-respl.cdcepres = STRING(0).

                  END.
               END.
            ELSE
               DO:
                  ASSIGN tt-fcad-respl.nmrespon = crapcrl.nmrespon    
                         tt-fcad-respl.tpdeiden = crapcrl.tpdeiden    
                         tt-fcad-respl.nridenti = crapcrl.nridenti    
                         tt-fcad-respl.cdufiden = crapcrl.cdufiden    
                         tt-fcad-respl.dtemiden = crapcrl.dtemiden    
                         tt-fcad-respl.dtnascin = crapcrl.dtnascin    
                         tt-fcad-respl.cddosexo = IF crapcrl.cddosexo = 1 
                                                  THEN "M" ELSE "F"
                         tt-fcad-respl.cdestciv = crapcrl.cdestciv    
                         tt-fcad-respl.cdnacion = crapcrl.cdnacion    
                         tt-fcad-respl.dsnatura = crapcrl.dsnatura    
                         tt-fcad-respl.dsendres = crapcrl.dsendres 
                         tt-fcad-respl.nrendres = crapcrl.nrendres    
                         tt-fcad-respl.dscomres = crapcrl.dscomres    
                         tt-fcad-respl.dsbaires = crapcrl.dsbaires    
                         tt-fcad-respl.dscidres = crapcrl.dscidres    
                         tt-fcad-respl.dsdufres = crapcrl.dsdufres    
                         tt-fcad-respl.nrcxpost = crapcrl.nrcxpost    
                         tt-fcad-respl.nmmaersp = crapcrl.nmmaersp    
                         tt-fcad-respl.nmpairsp = crapcrl.nmpairsp
                         tt-fcad-respl.nrcpfcgc = STRING(STRING(
                                                  crapcrl.nrcpfcgc,
                                                  "99999999999"),
                                                  "xxx.xxx.xxx-xx")
                         tt-fcad-respl.nrcpfmen = crapcrl.nrcpfmen.

                  /* Buscar a Nacionalidade */
                  FOR FIRST crapnac FIELDS(dsnacion)
                                    WHERE crapnac.cdnacion = crapcrl.cdnacion
                                          NO-LOCK:
                      ASSIGN tt-fcad-respl.dsnacion = crapnac.dsnacion.
                  END.

                  /* Retornar orgao expedidor */
                  IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                      RUN sistema/generico/procedures/b1wgen0052b.p 
                          PERSISTENT SET h-b1wgen0052b.

                  ASSIGN tt-fcad-respl.dsorgemi = "".
                  RUN busca_org_expedidor IN h-b1wgen0052b 
                                     (INPUT crapcrl.idorgexp,
                                      OUTPUT tt-fcad-respl.dsorgemi,
                                      OUTPUT aux_cdcritic, 
                                      OUTPUT aux_dscritic).

                  DELETE PROCEDURE h-b1wgen0052b.   

                  IF  RETURN-VALUE = "NOK" THEN
                  DO:
                       tt-fcad-respl.dsorgemi = "NAO CADAST.".
                  END.     

                  IF crapcrl.cdcepres <> 0 THEN
                     ASSIGN tt-fcad-respl.cdcepres = STRING(crapcrl.cdcepres,
                                                            "99999,999").
                  ELSE 
                     ASSIGN tt-fcad-respl.cdcepres = STRING(0).
               END.
                           
            DYNAMIC-FUNCTION("BuscaEstadoCivil" IN h-b1wgen0060,
                              INPUT tt-fcad-respl.cdestciv,
                              INPUT "rsestcvl",
                              OUTPUT tt-fcad-respl.dsestciv,
                              OUTPUT aux_dscritic).

        END.

        ASSIGN aux_retorno = "OK".
    END.

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Busca_PJ:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-psjur.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-regis.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-procu.
    /*DEF OUTPUT PARAM TABLE FOR tt-fcad-bensp.*/
    DEF OUTPUT PARAM TABLE FOR tt-fcad-refer.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-respl.
    DEF OUTPUT PARAM TABLE FOR tt-fcad-poder.

    DEF VAR h-b1wgen0060 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_contador AS INTEGER                                 NO-UNDO.

    DEF BUFFER crabass FOR crapass.
    DEF BUFFER cracttl FOR crapttl.

    &SCOPED-DEFINE CAMPOS-ASS qtfoltal nmprimtl dtcnscpf cdsitcpf inpessoa                               nrcpfcgc
    
    &SCOPED-DEFINE CAMPOS-JUR nmfansia natjurid qtfilial qtfuncio dtiniatv cdseteco                              cdrmativ dsendweb nmtalttl

    ASSIGN par_dscritic = ""
           par_cdcritic = 0
           aux_retorno = "NOK".

    BuscaPj: DO ON ERROR UNDO BuscaPj, LEAVE BuscaPj:
        EMPTY TEMP-TABLE tt-fcad-psjur.

        /* Busca dados do cooperado */
        FOR FIRST crabass FIELDS({&CAMPOS-ASS})
                          WHERE crabass.cdcooper = par_cdcooper AND
                                crabass.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE crabass THEN
            DO:
               ASSIGN par_cdcritic = 9.
               LEAVE BuscaPj.
            END.

        CREATE tt-fcad-psjur.

        BUFFER-COPY crabass USING {&CAMPOS-ASS} TO tt-fcad-psjur
            ASSIGN tt-fcad-psjur.dspessoa = "JURIDICA" 
                   tt-fcad-psjur.nrcpfcgc = STRING(STRING(crabass.nrcpfcgc,
                                               "99999999999999"),
                                               "xx.xxx.xxx/xxxx-xx") NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = ERROR-STATUS:GET-MESSAGE(1).
               LEAVE BuscaPj.
            END.

        FOR FIRST crapjur FIELDS({&CAMPOS-JUR} 
                                 vlfatano vlcaprea nrregemp dtregemp orregemp 
                                 nrinsmun dtinsnum flgrefis nrcdnire nrinsest)
                           WHERE crapjur.cdcooper = par_cdcooper AND
                                 crapjur.nrdconta = par_nrdconta 
                                 NO-LOCK:
        END.

        BUFFER-COPY crapjur USING {&CAMPOS-JUR} TO tt-fcad-psjur NO-ERROR.

        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN par_dscritic = ERROR-STATUS:GET-MESSAGE(1).
               LEAVE BuscaPj.
            END.

        CREATE tt-fcad-regis.

        ASSIGN tt-fcad-regis.vlfatano = crapjur.vlfatano
               tt-fcad-regis.vlcaprea = crapjur.vlcaprea
               tt-fcad-regis.nrregemp = crapjur.nrregemp
               tt-fcad-regis.dtregemp = crapjur.dtregemp
               tt-fcad-regis.orregemp = crapjur.orregemp
               tt-fcad-regis.nrinsmun = crapjur.nrinsmun
               tt-fcad-regis.dtinsnum = crapjur.dtinsnum
               tt-fcad-regis.flgrefis = STRING(crapjur.flgrefis,"Sim/Nao")
               tt-fcad-regis.nrcdnire = crapjur.nrcdnire
               tt-fcad-regis.nrinsest = IF crapjur.nrinsest <> 0 THEN 
                                           TRIM(STRING(crapjur.nrinsest,
                                                       "zzz,zzz,zzz,zzz,9"))
                                        ELSE 
                                           "ISENTO".
               
        FOR FIRST crapjfn FIELDS(perfatcl)
                          WHERE crapjfn.cdcooper = par_cdcooper AND
                                crapjfn.nrdconta = par_nrdconta 
                                NO-LOCK:

            ASSIGN tt-fcad-regis.perfatcl = crapjfn.perfatcl.

        END.

        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p 
                PERSISTENT SET h-b1wgen0060.

        DYNAMIC-FUNCTION("BuscaSituacaoCpf" IN h-b1wgen0060,
                          INPUT tt-fcad-psjur.cdsitcpf, 
                         OUTPUT tt-fcad-psjur.dssitcpf,
                         OUTPUT aux_dscritic).
        
        DYNAMIC-FUNCTION("BuscaNaturezaJuridica" IN h-b1wgen0060,
                          INPUT tt-fcad-psjur.natjurid, 
                          INPUT "dsnatjur",
                         OUTPUT tt-fcad-psjur.dsnatjur,
                         OUTPUT aux_dscritic).
        
        DYNAMIC-FUNCTION("BuscaSetorEconomico" IN h-b1wgen0060,
                          INPUT par_cdcooper,
                          INPUT tt-fcad-psjur.cdseteco, 
                         OUTPUT tt-fcad-psjur.nmseteco,
                         OUTPUT aux_dscritic).

        DYNAMIC-FUNCTION("BuscaRamoAtividade" IN h-b1wgen0060,
                          INPUT tt-fcad-psjur.cdseteco,
                          INPUT tt-fcad-psjur.cdrmativ, 
                         OUTPUT tt-fcad-psjur.dsrmativ,
                         OUTPUT aux_dscritic).
        
        FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper   AND
                               crapavt.tpctrato = 6 /*juridica*/ AND
                               crapavt.nrdconta = par_nrdconta   
                               NO-LOCK:
           
           CREATE tt-fcad-procu.
                              
           ASSIGN tt-fcad-procu.nrdctato = crapavt.nrdctato
                  tt-fcad-procu.nrcpfcgc = STRING(STRING(crapavt.nrcpfcgc,
                                               "99999999999"),"xxx.xxx.xxx-xx") 
                  tt-fcad-procu.dtvalida = IF crapavt.dtvalida = 12/31/9999 
                                           THEN "INDETERMINADO"
                                           ELSE STRING(crapavt.dtvalida,
                                                       "99/99/9999")
                  tt-fcad-procu.cdsexcto = IF crapavt.cdsexcto = 1 
                                           THEN "M" ELSE "F"
                  tt-fcad-procu.nmdavali = crapavt.nmdavali
                  tt-fcad-procu.tpdocava = crapavt.tpdocava
                  tt-fcad-procu.nrdocava = crapavt.nrdocava
                  tt-fcad-procu.cdufddoc = crapavt.cdufddoc
                  tt-fcad-procu.dtemddoc = crapavt.dtemddoc
                  tt-fcad-procu.dsproftl = crapavt.dsproftl
                  tt-fcad-procu.dtnascto = crapavt.dtnascto
                  tt-fcad-procu.cdestcvl = crapavt.cdestcvl
                  tt-fcad-procu.cdnacion = crapavt.cdnacion
                  tt-fcad-procu.dsnatura = crapavt.dsnatura
                  tt-fcad-procu.nmmaecto = crapavt.nmmaecto
                  tt-fcad-procu.nmpaicto = crapavt.nmpaicto
                  /*tt-fcad-procu.vledvmto = crapavt.vledvmto*/
                  tt-fcad-procu.dsendere = crapavt.dsendres[1]
                  tt-fcad-procu.nrendere = crapavt.nrendere
                  tt-fcad-procu.complend = crapavt.complend
                  tt-fcad-procu.nmbairro = crapavt.nmbairro
                  tt-fcad-procu.nmcidade = crapavt.nmcidade
                  tt-fcad-procu.cdufende = crapavt.cdufresd
                  tt-fcad-procu.nrcxapst = crapavt.nrcxapst
                  tt-fcad-procu.inhabmen = crapavt.inhabmen
                  tt-fcad-procu.dthabmen = crapavt.dthabmen
                  tt-fcad-procu.flgdepec = crapavt.flgdepec
                  tt-fcad-procu.persocio = crapavt.persocio
                  tt-fcad-procu.cpfprocu = crapass.nrcpfcgc.

                  /* Buscar a Nacionalidade */
                  FOR FIRST crapnac FIELDS(dsnacion)
                                    WHERE crapnac.cdnacion = crapavt.cdnacion
                                          NO-LOCK:
                      ASSIGN tt-fcad-procu.dsnacion = crapnac.dsnacion.
                  END.

                  /* Retornar orgao expedidor */
                  IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                      RUN sistema/generico/procedures/b1wgen0052b.p 
                          PERSISTENT SET h-b1wgen0052b.

                  ASSIGN tt-fcad-procu.cdoeddoc = "".
                  RUN busca_org_expedidor IN h-b1wgen0052b 
                                     (INPUT crapavt.idorgexp,
                                      OUTPUT tt-fcad-procu.cdoeddoc,
                                      OUTPUT aux_cdcritic, 
                                      OUTPUT aux_dscritic).

                  DELETE PROCEDURE h-b1wgen0052b.   

                  IF  RETURN-VALUE = "NOK" THEN
                  DO:
                       tt-fcad-procu.cdoeddoc = "NAO CADAST.".
                  END.  

                  FOR EACH crappod WHERE crappod.cdcooper = par_cdcooper     AND
                                         crappod.nrdconta = par_nrdconta     AND
                                         crappod.nrctapro = crapavt.nrdctato AND
                                         crappod.nrcpfpro = crapavt.nrcpfcgc
                                         NO-LOCK:
                    CREATE tt-fcad-poder.

                    ASSIGN tt-fcad-poder.nrdconta = par_nrdconta
                           tt-fcad-poder.nrctapro = crapavt.nrdctato
                           tt-fcad-poder.nrcpfcgc = STRING(
                                                    STRING(crappod.nrcpfpro,
                                                    "99999999999"),
                                                    "xxx.xxx.xxx-xx")
                           tt-fcad-poder.dscpoder = STRING(crappod.cddpoder)
                           tt-fcad-poder.flgisola = STRING(crappod.flgisola)
                           tt-fcad-poder.flgconju = STRING(crappod.flgconju)
                           tt-fcad-poder.dsoutpod = crappod.dsoutpod.
                  END.

           DYNAMIC-FUNCTION("BuscaHabilitacao" IN h-b1wgen0060,
                            INPUT tt-fcad-procu.inhabmen,
                            OUTPUT tt-fcad-procu.dshabmen,
                            OUTPUT aux_dscritic).

           IF  crapavt.nrcepend <> 0 THEN
               ASSIGN tt-fcad-procu.nrcepend = STRING(crapavt.nrcepend,
                                                      "99999,999").
           ELSE
               ASSIGN tt-fcad-procu.nrcepend = STRING(0).

           /* Bens do procurador do cooperado */
           /*DO  aux_contador = 1 TO EXTENT(crapavt.dsrelbem):
               IF  crapavt.dsrelbem[aux_contador] = "" THEN
                   NEXT.

               CREATE tt-fcad-bensp.

               ASSIGN tt-fcad-bensp.nrcpfcgc = tt-fcad-procu.nrcpfcgc
                      tt-fcad-bensp.dsrelbem = crapavt.dsrelbem[aux_contador]
                      tt-fcad-bensp.persemon = crapavt.persemon[aux_contador]
                      tt-fcad-bensp.qtprebem = crapavt.qtprebem[aux_contador]
                      tt-fcad-bensp.vlprebem = crapavt.vlprebem[aux_contador]
                      tt-fcad-bensp.vlrdobem = crapavt.vlrdobem[aux_contador].
           END.
           */

           /* buscar dados do contato */
           FOR FIRST crabass FIELDS(cdsexotl nmprimtl tpdocptl nrdocptl
                                    idorgexp cdufdptl dtemdptl dsproftl
                                    dtnasctl cdnacion
                                    nmmaeptl nmpaiptl nrdconta)
                              WHERE crabass.cdcooper = par_cdcooper     AND
                                    crabass.nrdconta = crapavt.nrdctato 
                                    NO-LOCK:

               /* Valor do endividamento do procurador */
              /* FOR EACH crapsdv FIELDS(vldsaldo tpdsaldo)
                                WHERE crapsdv.cdcooper = par_cdcooper     AND
                                      crapsdv.nrdconta = crabass.nrdconta AND
                                CAN-DO("1,2,3,6",STRING(crapsdv.tpdsaldo))
                                NO-LOCK:

                   ASSIGN tt-fcad-procu.vledvmto = tt-fcad-procu.vledvmto +
                                                   crapsdv.vldsaldo.
               END.*/

               ASSIGN tt-fcad-procu.cdsexcto = IF crabass.cdsexotl = 1 THEN 
                                                  "M" 
                                               ELSE
                                                  "F"
                      tt-fcad-procu.nmdavali = crabass.nmprimtl
                      tt-fcad-procu.tpdocava = crabass.tpdocptl
                      tt-fcad-procu.nrdocava = crabass.nrdocptl
                      tt-fcad-procu.cdufddoc = crabass.cdufdptl
                      tt-fcad-procu.dtemddoc = crabass.dtemdptl
                      tt-fcad-procu.dsproftl = crapavt.dsproftl
                      tt-fcad-procu.dtnascto = crabass.dtnasctl
                      tt-fcad-procu.cdnacion = crabass.cdnacion.

                /* Buscar a Nacionalidade */
                FOR FIRST crapnac FIELDS(dsnacion)
                                  WHERE crapnac.cdnacion = crabass.cdnacion
                                        NO-LOCK:
                    ASSIGN tt-fcad-procu.dsnacion = crapnac.dsnacion.
                END.

                /* Retornar orgao expedidor */
                IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                    RUN sistema/generico/procedures/b1wgen0052b.p 
                        PERSISTENT SET h-b1wgen0052b.

                ASSIGN tt-fcad-procu.cdoeddoc = "".
                RUN busca_org_expedidor IN h-b1wgen0052b 
                                   (INPUT crabass.idorgexp,
                                    OUTPUT tt-fcad-procu.cdoeddoc,
                                    OUTPUT aux_cdcritic, 
                                    OUTPUT aux_dscritic).

                DELETE PROCEDURE h-b1wgen0052b.   

                IF  RETURN-VALUE = "NOK" THEN
                DO:
                     tt-fcad-procu.cdoeddoc = "NAO CADAST.".
                END.               

               /* Filiaçao, pega da crapttl */
               FIND FIRST crapttl WHERE crapttl.cdcooper = par_cdcooper     AND
                                        crapttl.nrdconta = crabass.nrdconta AND
                                        crapttl.idseqttl = 1 
                                        NO-LOCK NO-ERROR.

               ASSIGN tt-fcad-procu.dsnatura = crapttl.dsnatura
                      tt-fcad-procu.nmmaecto = crapttl.nmmaettl
                      tt-fcad-procu.nmpaicto = crapttl.nmpaittl
                      tt-fcad-procu.cdestcvl = crapttl.cdestcvl.

               /* Bens do representante cooperado */
               /*FOR EACH tt-fcad-bensp WHERE tt-fcad-bensp.nrcpfcgc = 
                                            tt-fcad-procu.nrcpfcgc:
                   DELETE tt-fcad-bensp.

               END.

               FOR EACH crapbem FIELDS(dsrelbem persemon qtprebem
                                       vlprebem vlrdobem)
                                WHERE crapbem.cdcooper = par_cdcooper     AND
                                      crapbem.nrdconta = crabass.nrdconta AND
                                      crapbem.idseqttl = 1 
                                      NO-LOCK:

                   CREATE tt-fcad-bensp.

                   ASSIGN tt-fcad-bensp.nrcpfcgc = tt-fcad-procu.nrcpfcgc
                          tt-fcad-bensp.dsrelbem = crapbem.dsrelbem
                          tt-fcad-bensp.persemon = crapbem.persemon
                          tt-fcad-bensp.qtprebem = crapbem.qtprebem
                          tt-fcad-bensp.vlprebem = crapbem.vlprebem
                          tt-fcad-bensp.vlrdobem = crapbem.vlrdobem.

               END.
               */

           END.

           /* Endereco */
           FOR FIRST crapenc FIELDS(nrcepend dsendere nrendere complend
                                    nmbairro nmcidade cdufende nrcxapst)
                             WHERE crapenc.cdcooper = par_cdcooper       AND
                                   crapenc.nrdconta = crapavt.nrdctato   AND
                                   crapenc.idseqttl = 1                  AND
                                   crapenc.cdseqinc = 1                  AND
                                   crapenc.tpendass = 10 /*Residencial*/
                                   NO-LOCK:

               ASSIGN tt-fcad-procu.dsendere = crapenc.dsendere
                      tt-fcad-procu.nrendere = crapenc.nrendere
                      tt-fcad-procu.complend = crapenc.complend
                      tt-fcad-procu.nmbairro = crapenc.nmbairro
                      tt-fcad-procu.nmcidade = crapenc.nmcidade
                      tt-fcad-procu.cdufende = crapenc.cdufende
                      tt-fcad-procu.nrcxapst = crapenc.nrcxapst.

               IF crapenc.nrcepend <> 0 THEN
                  ASSIGN tt-fcad-procu.nrcepend = STRING(crapenc.nrcepend,
                                                          "99999,999").
               ELSE
                  ASSIGN tt-fcad-procu.nrcepend = STRING(0).
           END.

           DYNAMIC-FUNCTION("BuscaEstadoCivil" IN h-b1wgen0060,
                             INPUT tt-fcad-procu.cdestcvl,
                             INPUT "rsestcvl",
                            OUTPUT tt-fcad-procu.dsestcvl,
                            OUTPUT aux_dscritic).


           /* lista de responsaveis legais */
           FOR EACH crapcrl WHERE crapcrl.cdcooper = crapavt.cdcooper    AND
                                  crapcrl.nrctamen = crapavt.nrdctato    AND
                                 (IF crapcrl.nrctamen = 0 THEN 
                                     crapcrl.nrcpfmen = crapavt.nrcpfcgc
                                  ELSE 
                                     TRUE)                               /*AND
                                  crapcrl.idseqmen = crapavt.nrctremp*/
                                  NO-LOCK BREAK BY crapcrl.nrdconta:
           
               CREATE tt-fcad-respl.
           
               ASSIGN tt-fcad-respl.nrdconta = TRIM(STRING(crapcrl.nrdconta,
                                                           "zzzz,zzz,9")).
           
               /* Se for associado, pega os dados da crapttl */
               IF crapcrl.nrdconta <> 0 THEN
                  DO:
                     /* 1o. Titular */
                     FOR FIRST cracttl 
                               FIELDS(nrcpfcgc nmextttl tpdocttl nrdocttl 
                                      idorgexp cdufdttl dtemdttl dtnasttl 
                                      cdsexotl cdestcvl cdnacion dsnatura
                                      nmmaettl nmpaittl)
                               WHERE cracttl.cdcooper = par_cdcooper     AND
                                     cracttl.nrdconta = crapcrl.nrdconta AND
                                     cracttl.idseqttl = 1 
                                     NO-LOCK:
                                                             
                         ASSIGN tt-fcad-respl.nmrespon = cracttl.nmextttl
                                tt-fcad-respl.tpdeiden = cracttl.tpdocttl
                                tt-fcad-respl.nridenti = cracttl.nrdocttl
                                tt-fcad-respl.cdufiden = cracttl.cdufdttl
                                tt-fcad-respl.dtemiden = cracttl.dtemdttl
                                tt-fcad-respl.dtnascin = cracttl.dtnasttl
                                tt-fcad-respl.cddosexo = IF cracttl.cdsexotl = 1
                                                         THEN "M" ELSE "F"
                                tt-fcad-respl.cdestciv = cracttl.cdestcvl
                                tt-fcad-respl.cdnacion = cracttl.cdnacion
                                tt-fcad-respl.dsnatura = cracttl.dsnatura
                                tt-fcad-respl.nmmaersp = cracttl.nmmaettl
                                tt-fcad-respl.nmpairsp = cracttl.nmpaittl
                                tt-fcad-respl.nrcpfcgc = STRING(STRING
                                                             (cracttl.nrcpfcgc,
                                                              "99999999999"),
                                                              "xxx.xxx.xxx-xx")
                                tt-fcad-respl.nrcpfmen = crapcrl.nrcpfmen
                                tt-fcad-respl.nrctamen = crapcrl.nrctamen.
                            
                        /* Buscar a Nacionalidade */
                        FOR FIRST crapnac FIELDS(dsnacion)
                                          WHERE crapnac.cdnacion = cracttl.cdnacion
                                                NO-LOCK:
                            ASSIGN tt-fcad-respl.dsnacion = crapnac.dsnacion.
                        END.

                         /* Retornar orgao expedidor */
                        IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                            RUN sistema/generico/procedures/b1wgen0052b.p 
                                PERSISTENT SET h-b1wgen0052b.

                        ASSIGN tt-fcad-respl.dsorgemi = "".
                        RUN busca_org_expedidor IN h-b1wgen0052b 
                                           (INPUT cracttl.idorgexp,
                                            OUTPUT tt-fcad-respl.dsorgemi,
                                            OUTPUT aux_cdcritic, 
                                            OUTPUT aux_dscritic).

                        DELETE PROCEDURE h-b1wgen0052b.   

                        IF  RETURN-VALUE = "NOK" THEN
                        DO:
                             tt-fcad-respl.dsorgemi = "NAO CADAST.".
                     END.

                     END.
           
                     /* Endereco */
                     FOR FIRST crapenc 
                               FIELDS(nrcepend dsendere nrendere complend 
                                      nmbairro nmcidade cdufende nrcxapst)
                               WHERE crapenc.cdcooper = par_cdcooper     AND
                                     crapenc.nrdconta = crapcrl.nrdconta AND
                                     crapenc.idseqttl = 1                AND
                                     crapenc.cdseqinc = 1                AND
                                     crapenc.tpendass = 10 /*Residencial*/
                                     NO-LOCK:
           
                         ASSIGN tt-fcad-respl.dsendres = crapenc.dsendere
                                tt-fcad-respl.nrendres = crapenc.nrendere
                                tt-fcad-respl.dscomres = crapenc.complend
                                tt-fcad-respl.dsbaires = crapenc.nmbairro
                                tt-fcad-respl.dscidres = crapenc.nmcidade
                                tt-fcad-respl.dsdufres = crapenc.cdufende
                                tt-fcad-respl.nrcxpost = crapenc.nrcxapst.
           
                         IF crapenc.nrcepend <> 0 THEN
                            ASSIGN tt-fcad-respl.cdcepres = 
                                          STRING(crapenc.nrcepend,"99999,999").
                         ELSE 
                           ASSIGN tt-fcad-respl.cdcepres = STRING(0).
           
                     END.
                  END.
               ELSE
                  DO:
                     ASSIGN tt-fcad-respl.nmrespon = crapcrl.nmrespon    
                            tt-fcad-respl.tpdeiden = crapcrl.tpdeiden    
                            tt-fcad-respl.nridenti = crapcrl.nridenti    
                            tt-fcad-respl.cdufiden = crapcrl.cdufiden    
                            tt-fcad-respl.dtemiden = crapcrl.dtemiden    
                            tt-fcad-respl.dtnascin = crapcrl.dtnascin    
                            tt-fcad-respl.cddosexo = IF crapcrl.cddosexo = 1 
                                                     THEN "M" ELSE "F"
                            tt-fcad-respl.cdestciv = crapcrl.cdestciv    
                            tt-fcad-respl.cdnacion = crapcrl.cdnacion    
                            tt-fcad-respl.dsnatura = crapcrl.dsnatura    
                            tt-fcad-respl.dsendres = crapcrl.dsendres 
                            tt-fcad-respl.nrendres = crapcrl.nrendres    
                            tt-fcad-respl.dscomres = crapcrl.dscomres    
                            tt-fcad-respl.dsbaires = crapcrl.dsbaires    
                            tt-fcad-respl.dscidres = crapcrl.dscidres    
                            tt-fcad-respl.dsdufres = crapcrl.dsdufres    
                            tt-fcad-respl.nrcxpost = crapcrl.nrcxpost    
                            tt-fcad-respl.nmmaersp = crapcrl.nmmaersp    
                            tt-fcad-respl.nmpairsp = crapcrl.nmpairsp
                            tt-fcad-respl.nrcpfcgc = STRING(STRING(
                                                     crapcrl.nrcpfcgc,
                                                     "99999999999"),
                                                     "xxx.xxx.xxx-xx")
                            tt-fcad-respl.nrcpfmen = crapcrl.nrcpfmen
                            tt-fcad-respl.nrctamen = crapcrl.nrctamen.
           
                     /* Buscar a Nacionalidade */
                     FOR FIRST crapnac FIELDS(dsnacion)
                                       WHERE crapnac.cdnacion = crapcrl.cdnacion
                                             NO-LOCK:
                         ASSIGN tt-fcad-respl.dsnacion = crapnac.dsnacion.
                     END.

                     /* Retornar orgao expedidor */
                     IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                          RUN sistema/generico/procedures/b1wgen0052b.p 
                              PERSISTENT SET h-b1wgen0052b.

                     ASSIGN tt-fcad-respl.dsorgemi = "".
                     RUN busca_org_expedidor IN h-b1wgen0052b 
                                         (INPUT crapcrl.idorgexp,
                                          INPUT tt-fcad-respl.dsorgemi,
                                          INPUT aux_cdcritic, 
                                          INPUT aux_dscritic).

                     DELETE PROCEDURE h-b1wgen0052b.   

                     IF  RETURN-VALUE = "NOK" THEN
                     DO:
                           tt-fcad-respl.dsorgemi = "NAO CADAST.".
                     END.   
           
                     IF crapcrl.cdcepres <> 0 THEN
                        ASSIGN tt-fcad-respl.cdcepres = 
                                          STRING(crapcrl.cdcepres,"99999,999").
                     ELSE 
                        ASSIGN tt-fcad-respl.cdcepres = STRING(0).


                  END.
                              
               DYNAMIC-FUNCTION("BuscaEstadoCivil" IN h-b1wgen0060,
                                 INPUT tt-fcad-respl.cdestciv,
                                 INPUT "rsestcvl",
                                 OUTPUT tt-fcad-respl.dsestciv,
                                 OUTPUT aux_dscritic).
           
           END.

        END.

        /* referencias */
        FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper   AND
                               crapavt.tpctrato = 5 /*contato*/  AND
                               crapavt.nrdconta = par_nrdconta  
                               NO-LOCK:

            CREATE tt-fcad-refer.

            ASSIGN tt-fcad-refer.nrdctato = TRIM(STRING(crapavt.nrdctato,
                                                        "zzzz,zzz,9")).

            /* Se for associado, pega os dados da crapass */
            IF  crapavt.nrdctato <> 0   THEN
                DO:
                   FOR FIRST crabass FIELDS(nmprimtl)
                                     WHERE 
                                     crabass.cdcooper = par_cdcooper AND
                                     crabass.nrdconta = crapavt.nrdctato 
                                     NO-LOCK:

                       ASSIGN tt-fcad-refer.nmdavali = crabass.nmprimtl.

                   END.
                                             
                   /* Telefones */
                   FOR FIRST craptfc FIELDS(nrtelefo)
                                     WHERE 
                                     craptfc.cdcooper = par_cdcooper     AND
                                     craptfc.nrdconta = crapavt.nrdctato AND
                                     craptfc.idseqttl = 1                AND
                                     craptfc.cdseqtfc = 1 
                                     NO-LOCK:

                       tt-fcad-refer.nrtelefo = STRING(craptfc.nrtelefo).
                   END.
                                             
                   /* Emails */
                   FOR FIRST crapcem FIELDS(dsdemail)
                                     WHERE 
                                     crapcem.cdcooper = par_cdcooper     AND
                                     crapcem.nrdconta = crapavt.nrdctato AND
                                     crapcem.idseqttl = 1                AND
                                     crapcem.cddemail = 1 
                                     NO-LOCK:

                       ASSIGN tt-fcad-refer.dsdemail = crapcem.dsdemail.

                   END.
                                      
                   /* Endereco */
                   FOR FIRST crapenc FIELDS(nrcepend dsendere nrendere 
                                            complend nmbairro nmcidade 
                                            cdufende nrcxapst)
                                     WHERE 
                                     crapenc.cdcooper = par_cdcooper     AND
                                     crapenc.nrdconta = crapavt.nrdctato AND
                                     crapenc.idseqttl = 1                AND
                                     crapenc.cdseqinc = 1 
                                     NO-LOCK:

                       ASSIGN tt-fcad-refer.dsendere = crapenc.dsendere
                              tt-fcad-refer.nrendere = crapenc.nrendere
                              tt-fcad-refer.complend = crapenc.complend
                              tt-fcad-refer.nmbairro = crapenc.nmbairro
                              tt-fcad-refer.nmcidade = crapenc.nmcidade
                              tt-fcad-refer.cdufende = crapenc.cdufende
                              tt-fcad-refer.nrcxapst = crapenc.nrcxapst.

                       IF  crapenc.nrcepend <> 0 THEN
                           ASSIGN tt-fcad-refer.nrcepend = STRING
                           (crapenc.nrcepend,"99999,999").
                       ELSE
                           ASSIGN tt-fcad-refer.nrcepend = STRING(0).
                   END.
        
                   ASSIGN tt-fcad-refer.dsproftl = ""
                          tt-fcad-refer.nmextemp = ""
                          tt-fcad-refer.cddbanco = 0
                          tt-fcad-refer.dsdbanco = ""
                          tt-fcad-refer.cdagenci = 0.
                END.
            ELSE        
                DO:
                    ASSIGN tt-fcad-refer.nmdavali = crapavt.nmdavali
                           tt-fcad-refer.nmextemp = crapavt.nmextemp
                           tt-fcad-refer.cddbanco = crapavt.cddbanco
                           tt-fcad-refer.cdagenci = crapavt.cdagenci
                           tt-fcad-refer.dsproftl = crapavt.dsproftl
                           tt-fcad-refer.dsendere = crapavt.dsendres[1]
                           tt-fcad-refer.nrendere = crapavt.nrendere
                           tt-fcad-refer.complend = crapavt.complend
                           tt-fcad-refer.nmbairro = crapavt.nmbairro
                           tt-fcad-refer.nmcidade = crapavt.nmcidade
                           tt-fcad-refer.cdufende = crapavt.cdufresd
                           tt-fcad-refer.nrcxapst = crapavt.nrcxapst
                           tt-fcad-refer.nrtelefo = crapavt.nrtelefo
                           tt-fcad-refer.dsdemail = crapavt.dsdemail.
    
                    IF  crapavt.nrcepend <> 0 THEN
                        ASSIGN tt-fcad-refer.nrcepend = STRING
                        (crapavt.nrcepend,"99999,999").
                    ELSE
                        ASSIGN tt-fcad-refer.nrcepend = STRING(0).

                    FOR FIRST crapban FIELDS(nmresbcc)
                                      WHERE crapban.cdbccxlt = crapavt.cddbanco
                                      NO-LOCK:
    
                        ASSIGN tt-fcad-refer.dsdbanco = crapban.nmresbcc.
                    END.
                END.
        END.

        ASSIGN aux_retorno = "OK".
    END.

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE des_tipo_rendimento:

    DEF INPUT  PARAM par_cdcooper  AS INTE                       NO-UNDO.
    DEF INPUT  PARAM par_tpdrendi  AS INTE                       NO-UNDO.
    DEF OUTPUT PARAM par_dstipren  AS CHAR                       NO-UNDO.

    /* Descricao do rendimento */
    FIND craptab WHERE craptab.cdcooper = par_cdcooper       AND
                       craptab.nmsistem = "CRED"             AND
                       craptab.tptabela = "GENERI"           AND
                       craptab.cdempres = 0                  AND
                       craptab.cdacesso = "DSRENDIMEN"       AND
                       craptab.tpregist = par_tpdrendi       NO-LOCK NO-ERROR.

    ASSIGN par_dstipren = IF   AVAILABLE craptab  THEN
                               craptab.dstextab
                          ELSE
                               "NAO CADASTRADO".

END PROCEDURE.

PROCEDURE Zera_TempTable.

    EMPTY TEMP-TABLE tt-fcad.      
    EMPTY TEMP-TABLE tt-fcad-telef.
    EMPTY TEMP-TABLE tt-fcad-email.
    EMPTY TEMP-TABLE tt-fcad-psfis.
    EMPTY TEMP-TABLE tt-fcad-filia.
    EMPTY TEMP-TABLE tt-fcad-comer.
    EMPTY TEMP-TABLE tt-fcad-cbens.
    EMPTY TEMP-TABLE tt-fcad-depen.
    EMPTY TEMP-TABLE tt-fcad-ctato.
    EMPTY TEMP-TABLE tt-fcad-respl.
    EMPTY TEMP-TABLE tt-fcad-cjuge.
    EMPTY TEMP-TABLE tt-fcad-psjur.
    EMPTY TEMP-TABLE tt-fcad-regis.
    EMPTY TEMP-TABLE tt-fcad-procu.
    /*EMPTY TEMP-TABLE tt-fcad-bensp.*/
    EMPTY TEMP-TABLE tt-fcad-refer.
    EMPTY TEMP-TABLE tt-fcad-poder.

END PROCEDURE.



