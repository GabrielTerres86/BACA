/*.............................................................................

   Programa: xb1wgen0155.p
   Autor   : Guilherme / SUPERO
   Data    : Abril/2013                     Ultima atualizacao: 14/03/2018

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO - Tela BLQJUD.

   Alteracoes: 06/09/2013 - Incluido campo aux_cddopcao na procedure
                            consulta-bloqueio-jud (Lucas R.)
                            
               15/09/2014 - Adicionado retorno de "OK" em procedure
                            efetua-desbloqueio-jud. (Jorge)	

               30/11/2017 - Removido rotinas efetua-desbloqueio-jud e 
                            busca-contas-cooperado que nao sao mais utilizadas.
                            PRJ404-Garantia(Odirlei-Amcom) 
				
			   14/03/2018 - Adicionado parametro que faltava na chamada da procedure
				     		consulta-bloqueio-jud. (Kelvin)
............................................................................ */

DEF VAR aux_cooperad AS DECI NO-UNDO.
DEF VAR aux_cdtppesq AS INT  NO-UNDO.

DEF VAR aux_dtinireq AS DATE NO-UNDO.
DEF VAR aux_intipreq AS INTE NO-UNDO.
DEF VAR aux_cdbanori AS INTE NO-UNDO.
DEF VAR aux_cdbanreq AS INTE NO-UNDO.
DEF VAR aux_nroficon AS CHAR NO-UNDO.
DEF VAR aux_nrctacon AS CHAR NO-UNDO.
DEF VAR aux_dacaojud AS CHAR NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR NO-UNDO.

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_agenctel AS INTE                                           NO-UNDO. 

DEF VAR aux_dtiniper AS DATE                                           NO-UNDO.
DEF VAR aux_dtfimper AS DATE                                           NO-UNDO.
DEF VAR aux_dtinicio AS DATE                                           NO-UNDO.
DEF VAR aux_dtafinal AS DATE                                           NO-UNDO.

DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_dsinfadc AS CHAR                                           NO-UNDO.

DEF VAR aux_nrdctitg AS CHAR                                           NO-UNDO.

DEF VAR aux_operacao AS CHAR                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nrofides AS CHAR                                           NO-UNDO.
DEF VAR aux_dtenvdes AS DATE                                           NO-UNDO.
DEF VAR aux_dsinfdes AS CHAR                                           NO-UNDO.
DEF VAR aux_fldestrf AS LOGI                                           NO-UNDO.

DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgen0155tt.i }


/*................................ PROCEDURES ................................*/


/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/
PROCEDURE valores_entrada:

    DEF VAR aux_rowidicf AS ROWID NO-UNDO.

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper"  THEN aux_cdcooper =  INTE(tt-param.valorCampo).
            WHEN "cdagenci"  THEN aux_cdagenci =  INTE(tt-param.valorCampo).
            WHEN "nrdcaixa"  THEN aux_nrdcaixa =  INTE(tt-param.valorCampo).
            WHEN "cdoperad"  THEN aux_cdoperad =  tt-param.valorCampo.
            WHEN "dtiniper"  THEN aux_dtiniper =  DATE(tt-param.valorCampo).
            WHEN "dtfimper"  THEN aux_dtfimper =  DATE(tt-param.valorCampo).
            WHEN "idorigem"  THEN aux_idorigem =  INTE(tt-param.valorCampo).
            WHEN "idseqttl"  THEN aux_idseqttl =  INTE(tt-param.valorCampo).
            WHEN "nmdatela"  THEN aux_nmdatela =  tt-param.valorCampo.
            
            WHEN "cooperad"  THEN aux_cooperad =  DECI(tt-param.valorCampo).
            WHEN "cdtppesq"  THEN aux_cdtppesq =  INTE(tt-param.valorCampo).
            
            WHEN "nrdconta"  THEN aux_nrdconta =  tt-param.valorCampo.
            WHEN "cdtipmov"  THEN aux_cdtipmov =  tt-param.valorCampo.
            WHEN "cdmodali"  THEN aux_cdmodali =  tt-param.valorCampo.
            WHEN "vlbloque"  THEN aux_vlbloque =  tt-param.valorCampo.
            WHEN "vlresblq"  THEN aux_vlresblq =  tt-param.valorCampo.
            WHEN "nroficio"  THEN aux_nroficio =  tt-param.valorCampo.
            WHEN "nrproces"  THEN aux_nrproces =  tt-param.valorCampo.
            WHEN "dsjuizem"  THEN aux_dsjuizem =  tt-param.valorCampo.
            WHEN "dsresord"  THEN aux_dsresord =  tt-param.valorCampo.
            WHEN "flblcrft"  THEN aux_flblcrft =  LOGICAL(tt-param.valorCampo).
            WHEN "vlrsaldo"  THEN aux_vlrsaldo =  DECI(tt-param.valorCampo).
            WHEN "dtenvres"  THEN aux_dtenvres =  DATE(tt-param.valorCampo).
            WHEN "dsinfadc"  THEN aux_dsinfadc =  tt-param.valorCampo. 

            WHEN "nroficon"  THEN aux_nroficon =  tt-param.valorCampo.
            WHEN "nrctacon"  THEN aux_nrctacon =  tt-param.valorCampo.

            WHEN "agenctel" THEN  aux_agenctel = INTE(tt-param.valorCampo).
            WHEN "dtinicio" THEN  aux_dtinicio = DATE(tt-param.valorCampo).
            WHEN "dtafinal" THEN  aux_dtafinal = DATE(tt-param.valorCampo).

            WHEN "operacao" THEN aux_operacao = tt-param.valorCampo.
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.

            WHEN "nrofides" THEN aux_nrofides = tt-param.valorCampo.
            WHEN "dtenvdes" THEN aux_dtenvdes = DATE(tt-param.valorCampo).
            WHEN "dsinfdes" THEN aux_dsinfdes = tt-param.valorCampo.
            WHEN "fldestrf" THEN aux_fldestrf = LOGICAL(tt-param.valorCampo).

            WHEN "nmarqimp" THEN aux_nmarqimp = tt-param.valorCampo.
            WHEN "nmarqpdf" THEN aux_nmarqpdf = tt-param.valorCampo.
        END CASE.
    
    END. /** Fim do FOR EACH tt-param **/
     
END PROCEDURE.

PROCEDURE consulta-bloqueio-jud-oficio:

    RUN consulta-bloqueio-jud-oficio IN hBO (INPUT aux_cdcooper,
										     INPUT aux_nrctacon,
										     INPUT aux_nroficon,
										     OUTPUT TABLE tt-dados-blq-oficio,
										     OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Registro nao encontrado.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlSave.

        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-dados-blq-oficio:HANDLE, INPUT "DADO_BLQ").
           RUN piXmlSave.
        END.


END PROCEDURE.

PROCEDURE retorna-sld-conta-invt:

	RUN retorna-sld-conta-invt IN hBO (INPUT aux_cdcooper,
									   INPUT aux_nrdconta,
									   INPUT aux_dtmvtolt,
									   OUTPUT aux_vlresblq).
    
    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF NOT AVAILABLE tt-erro THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel consultar os " +
                                      "registros.".
        END.

        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        RUN piXmlSave.
    END.
    ELSE
    DO:
        RUN piXmlNew.
        RUN piXmlAtributo (INPUT "vlresblq", INPUT aux_vlresblq).
        RUN piXmlSave.
    END.

END PROCEDURE.

PROCEDURE consulta-bloqueio-jud:

    RUN consulta-bloqueio-jud IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_operacao,
                                      INPUT aux_cddopcao,
                                      INPUT aux_nrctacon,
                                      INPUT aux_nroficon,
                                     OUTPUT TABLE tt-dados-blq,
                                     OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Registro nao encontrado.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlSave.

        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-dados-blq:HANDLE, INPUT "DADO_BLQ").
           RUN piXmlSave.
        END.


END PROCEDURE.

PROCEDURE inclui-bloqueio-jud:

   RUN inclui-bloqueio-jud IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_nrdconta,
                                   INPUT aux_cdtipmov,
                                   INPUT aux_cdmodali,
                                   INPUT aux_vlbloque,
                                   INPUT aux_vlresblq,
                                   INPUT aux_nroficio,
                                   INPUT aux_nrproces,
                                   INPUT aux_dsjuizem,
                                   INPUT aux_dsresord,
                                   INPUT aux_flblcrft,
                                   INPUT aux_dtenvres,
                                   INPUT aux_vlrsaldo,
                                   INPUT aux_dtmvtolt,
                                   INPUT aux_cdoperad,
                                   INPUT aux_dsinfadc,
                                  OUTPUT TABLE tt-dados-blq,
                                  OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF NOT AVAILABLE tt-erro THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel consultar os " +
                                      "registros.".
        END.

        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        RUN piXmlSave.
    END.
    ELSE
    DO:
        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-dados-blq:HANDLE,
                         INPUT "BLOQUEIOS").
        RUN piXmlSave.
    END.


END PROCEDURE.


PROCEDURE retorna-valor-blqjud:
 
   RUN retorna-valor-blqjud IN hBO (INPUT aux_cdcooper,
                                    INPUT INT(aux_nrdconta),
                                    INPUT DECI(aux_nrcpfcgc),
                                    INPUT INT(aux_cdtipmov),
                                    INPUT INT(aux_cdmodali),
                                    INPUT aux_dtmvtolt,
                                   OUTPUT aux_vlbloque,
                                   OUTPUT aux_vlresblq).

    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF NOT AVAILABLE tt-erro THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel consultar os " +
                                      "registros.".
        END.

        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        RUN piXmlSave.
    END.
    ELSE
    DO:
        RUN piXmlNew.
        RUN piXmlAtributo (INPUT "vlbloque", INPUT aux_vlbloque).
        RUN piXmlAtributo (INPUT "vlresblq", INPUT aux_vlresblq).
        RUN piXmlSave.
    END.

END PROCEDURE.

PROCEDURE altera-bloqueio-jud:

    RUN altera-bloqueio-jud IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_dtmvtolt,
                                    INPUT aux_cdoperad,
                                    INPUT aux_cdmodali,
                                    INPUT aux_nroficio,
                                    INPUT aux_nrproces,
                                    INPUT aux_dsjuizem,
                                    INPUT aux_dsresord,
                                    INPUT aux_flblcrft,
                                    INPUT aux_dtenvres,
                                    INPUT aux_nroficon,
                                    INPUT aux_nrctacon,
                                    INPUT aux_dsinfadc,
                                    INPUT aux_nrofides,
                                    INPUT aux_dtenvdes,
                                    INPUT aux_dsinfdes,
                                    INPUT aux_fldestrf,
                                   OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF NOT AVAILABLE tt-erro THEN
            DO:
                CREATE tt-erro.
                ASSIGN tt-erro.dscritic = "Nao foi possivel alterar os " +
                                          "registros.".
            END.
    
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "ERRO").
            RUN piXmlSave.
        END.
    ELSE
        DO:
              RUN piXmlNew.      
              RUN piXmlSave. 
        END.     

END PROCEDURE.

PROCEDURE imprime_bloqueio_jud:

    RUN imprime_bloqueio_jud IN hBO(INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_dtmvtolt,
                                    INPUT aux_nroficon,
                                    INPUT aux_nrctacon,
									INPUT aux_operacao,
									input aux_cddopcao,
                                   OUTPUT aux_nmarqimp,
                                   OUTPUT aux_nmarqpdf,
                                   OUTPUT TABLE tt-erro).


    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF NOT AVAILABLE tt-erro THEN
            DO:
                CREATE tt-erro.
                ASSIGN tt-erro.dscritic = "Nao foi possivel gerar arquivo " +
                                          "de impressao.".
            END.
    
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "ERRO").
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp", INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE Gera_Impressao:

    RUN Gera_Impressao IN hBO(INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_idorigem,
                              INPUT aux_nmdatela,
                              INPUT aux_dtmvtolt,
                              INPUT aux_dtinicio,
                              INPUT aux_dtafinal,
                              INPUT aux_agenctel,
                             OUTPUT aux_nmarqimp,
                             OUTPUT aux_nmarqpdf,
                             OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF NOT AVAILABLE tt-erro THEN
            DO:
                CREATE tt-erro.
                ASSIGN tt-erro.dscritic = "Nao foi possivel gerar arquivo " +
                                          "de impressao.".
            END.
    
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "ERRO").
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp", INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.

END PROCEDURE.
