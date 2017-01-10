/*.............................................................................

    Programa: sistema/generico/procedures/xb1wgen0181.p
    Autor   : Oliver Fagionato (GATI)
    Data    : Outubro/2013

    Objetivo  : BO de Comunicacao XML x BO 
                Tela CADSEG
                Consultar, alterar/cadastrar justificativa, listar,
                conultar detalhadamente, realizar e cancelar fechamento de
                movimentaþ§es de creditos diarios dos cooperados.
                
    Auteracoes: 20/01/2014 - Adicionado parametro aux_valdtudo. 
                           - Adotado padronizacao CECRED. (Jorge)

				06/12/2016 - P341-Automatização BACENJUD - Alterar a passagem da descrição do 
                             departamento como parametro e passar o o código (Renato Darosci)
.............................................................................*/

/*............................. DEFINICOES ..................................*/

DEF VAR aux_cddepart AS INTE                NO-UNDO.
DEF VAR aux_nmsegura AS CHAR                NO-UNDO.
DEF VAR aux_dsasauto AS CHAR                NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                NO-UNDO.
DEF VAR aux_cdprogra AS CHAR                NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                NO-UNDO.
DEF VAR aux_nmresseg AS CHAR                NO-UNDO.
DEF VAR aux_dsmsgseg AS CHAR                NO-UNDO.

DEF VAR aux_nrdconta AS INTE                NO-UNDO.
DEF VAR aux_cdcooper AS INTE                NO-UNDO.
DEF VAR aux_cdagenci AS INTE                NO-UNDO.
DEF VAR aux_cdbccxlt AS INTE                NO-UNDO.
DEF VAR aux_cdsegura AS INTE                NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                NO-UNDO.
DEF VAR aux_idorigem AS INTE                NO-UNDO.
DEF VAR aux_nrctrato AS INTE                NO-UNDO.
DEF VAR aux_nrultpra AS INTE                NO-UNDO.
DEF VAR aux_nrlimpra AS INTE                NO-UNDO.
DEF VAR aux_nrultprc AS INTE                NO-UNDO.
DEF VAR aux_nrlimprc AS INTE                NO-UNDO.
DEF VAR aux_nriniseq AS INTE                NO-UNDO.
DEF VAR aux_nrregist AS INTE                NO-UNDO.
DEF VAR aux_qtregist AS INTE                NO-UNDO.

DEF VAR aux_nrcgcseg AS DECI                NO-UNDO.

DEF VAR aux_valdtudo AS LOGI                NO-UNDO.
DEF VAR aux_flgativo AS LOGI                NO-UNDO.

DEF VAR aux_cdhstaut AS INTE EXTENT 10      NO-UNDO.
DEF VAR aux_cdhstcas AS INTE EXTENT 10      NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0181tt.i }

DEFINE VARIABLE aux_rowid_crapcsg AS ROWID NO-UNDO.

PROCEDURE valores_entrada:

    ASSIGN aux_rowid_crapcsg = ?.

    FOR EACH tt-param NO-LOCK:

        /* Acomodação dos valores nas respectivas variaveis */
        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN 
                 ASSIGN aux_cdcooper = INT(tt-param.valorCampo).
            WHEN "cdsegura" THEN 
                 ASSIGN aux_cdsegura = INT(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN 
                 ASSIGN aux_nrdcaixa = INT(tt-param.valorCampo).
            WHEN "cdoperad" THEN 
                 ASSIGN aux_cdoperad = tt-param.valorCampo.
            WHEN "idorigem" THEN 
                 ASSIGN aux_idorigem = INT(tt-param.valorCampo).
            WHEN "nmdatela" THEN 
                 ASSIGN aux_nmdatela = tt-param.valorCampo.
            WHEN "nrdconta" THEN 
                 ASSIGN aux_nrdconta = INT(tt-param.valorCampo).
            WHEN "cdprogra" THEN 
                 ASSIGN aux_cdprogra = tt-param.valorCampo.
            WHEN "cddopcao" THEN 
                 ASSIGN aux_cddopcao = tt-param.valorCampo.
            WHEN "cdagenci" THEN 
                 ASSIGN aux_cdagenci = INT(tt-param.valorCampo).
            WHEN "cdbccxlt" THEN 
                 ASSIGN aux_cdbccxlt = INT(tt-param.valorCampo).
            WHEN "cddepart" THEN 
                 ASSIGN aux_cddepart = INT(tt-param.valorCampo).
            WHEN "nmsegura" THEN 
                 ASSIGN aux_nmsegura = tt-param.valorCampo.
            WHEN "flgativo" THEN 
                 ASSIGN aux_flgativo = LOGICAL(tt-param.valorCampo).
            WHEN "nmresseg" THEN 
                 ASSIGN aux_nmresseg = tt-param.valorCampo.
            WHEN "nrcgcseg" THEN 
                 ASSIGN aux_nrcgcseg = DEC(tt-param.valorCampo).
            WHEN "nrctrato" THEN 
                 ASSIGN aux_nrctrato = INT(tt-param.valorCampo).
            WHEN "nrultpra" THEN 
                 ASSIGN aux_nrultpra = INT(tt-param.valorCampo).
            WHEN "nrlimpra" THEN 
                 ASSIGN aux_nrlimpra = INT(tt-param.valorCampo).
            WHEN "nrultprc" THEN 
                 ASSIGN aux_nrultprc = INT(tt-param.valorCampo).
            WHEN "nrlimprc" THEN 
                 ASSIGN aux_nrlimprc = INT(tt-param.valorCampo).
            WHEN "dsasauto" THEN 
                 ASSIGN aux_dsasauto = tt-param.valorCampo.
            WHEN "dsmsgseg" THEN 
                 ASSIGN aux_dsmsgseg = tt-param.valorCampo.
            WHEN "cdhstaut1" THEN 
                 ASSIGN aux_cdhstaut[1] = INT(tt-param.valorCampo).
            WHEN "cdhstaut2" THEN 
                ASSIGN aux_cdhstaut[2]  = INT(tt-param.valorCampo).
            WHEN "cdhstaut3" THEN 
                ASSIGN aux_cdhstaut[3]  = INT(tt-param.valorCampo).
            WHEN "cdhstaut4" THEN 
                ASSIGN aux_cdhstaut[4]  = INT(tt-param.valorCampo).
            WHEN "cdhstaut5" THEN 
                ASSIGN aux_cdhstaut[5]  = INT(tt-param.valorCampo).
            WHEN "cdhstaut6" THEN 
                ASSIGN aux_cdhstaut[6]  = INT(tt-param.valorCampo).
            WHEN "cdhstaut7" THEN 
                ASSIGN aux_cdhstaut[7]  = INT(tt-param.valorCampo).
            WHEN "cdhstaut8" THEN 
                ASSIGN aux_cdhstaut[8]  = INT(tt-param.valorCampo).
            WHEN "cdhstaut9" THEN 
                ASSIGN aux_cdhstaut[9]  = INT(tt-param.valorCampo).
            WHEN "cdhstaut10"THEN 
                ASSIGN aux_cdhstaut[10] = INT(tt-param.valorCampo).
            WHEN "cdhstcas1" THEN 
                ASSIGN aux_cdhstcas[1]  = INT(tt-param.valorCampo).
            WHEN "cdhstcas2" THEN 
                ASSIGN aux_cdhstcas[2]  = INT(tt-param.valorCampo).
            WHEN "cdhstcas3" THEN 
                ASSIGN aux_cdhstcas[3]  = INT(tt-param.valorCampo).
            WHEN "cdhstcas4" THEN 
                ASSIGN aux_cdhstcas[4]  = INT(tt-param.valorCampo).
            WHEN "cdhstcas5" THEN 
                ASSIGN aux_cdhstcas[5]  = INT(tt-param.valorCampo).
            WHEN "cdhstcas6" THEN 
                ASSIGN aux_cdhstcas[6]  = INT(tt-param.valorCampo).
            WHEN "cdhstcas7" THEN 
                ASSIGN aux_cdhstcas[7]  = INT(tt-param.valorCampo).
            WHEN "cdhstcas8" THEN 
                ASSIGN aux_cdhstcas[8]  = INT(tt-param.valorCampo).
            WHEN "cdhstcas9" THEN 
                ASSIGN aux_cdhstcas[9]  = INT(tt-param.valorCampo).
            WHEN "cdhstcas10" THEN 
                ASSIGN aux_cdhstcas[10] = INT(tt-param.valorCampo).
            WHEN "valdtudo"  THEN 
                ASSIGN aux_valdtudo = LOGICAL(tt-param.valorCampo).
            WHEN "nriniseq" THEN
                ASSIGN aux_nriniseq = INT(tt-param.valorCampo).
            WHEN "nrregist" THEN
                ASSIGN aux_nrregist = INT(tt-param .valorCampo).

        END CASE.
    END. /* FOR EACH tt-param */

END PROCEDURE. /* valores_entrada */

PROCEDURE Retorna_seguradoras:

    RUN Retorna_seguradoras IN hBO(INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_idorigem,
                                  INPUT aux_nmdatela,
                                  INPUT aux_cdprogra,
                                  INPUT aux_cdsegura,
                                 OUTPUT aux_nmdcampo,
                                 OUTPUT TABLE tt-crapcsg,
                                 OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapcsg:HANDLE,
                     INPUT "seguradora").
            RUN piXmlSave.
        END. 

END PROCEDURE.

PROCEDURE Grava_dados_seguradora:
    FIND FIRST tt-crapcsg NO-ERROR.
    RUN Grava_dados_seguradora IN hBO(INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_dtmvtolt,
                                      INPUT aux_idorigem,
                                      INPUT aux_nmdatela,
                                      INPUT aux_cdprogra,
                                      INPUT aux_cdbccxlt,
                                      INPUT aux_cdsegura,
                                      INPUT aux_nmsegura,
                                      INPUT aux_nmresseg,
                                      INPUT aux_flgativo,
                                      INPUT aux_nrcgcseg,
                                      INPUT aux_nrctrato,
                                      INPUT aux_nrultpra,
                                      INPUT aux_nrlimpra,
                                      INPUT aux_nrultprc,
                                      INPUT aux_nrlimprc,
                                      INPUT aux_dsasauto,
                                      INPUT aux_dsmsgseg,
                                      INPUT aux_cdhstaut,
                                      INPUT aux_cdhstcas,
                                      INPUT aux_cddopcao,
                                     OUTPUT aux_nmdcampo,
                                     OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            IF TEMP-TABLE tt-erro:HAS-RECORDS THEN 
                RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
            RUN piXmlSave.
        END.  

END PROCEDURE.

PROCEDURE Valida_inclusao_seguradora:

    RUN Valida_inclusao_seguradora IN hBO(INPUT aux_cdcooper,
                                          INPUT aux_cdagenci,
                                          INPUT aux_nrdcaixa,
                                          INPUT aux_cdoperad,
                                          INPUT aux_dtmvtolt,
                                          INPUT aux_idorigem,
                                          INPUT aux_nmdatela,
                                          INPUT aux_cdprogra,
                                          INPUT aux_cdbccxlt,
                                          INPUT aux_cdsegura,
                                          INPUT aux_nmsegura,
                                          INPUT aux_nrcgcseg,
                                          INPUT aux_dsasauto,
                                          INPUT aux_valdtudo,
                                          INPUT aux_cddopcao,
                                         OUTPUT aux_nmdcampo,
                                         OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            IF TEMP-TABLE tt-erro:HAS-RECORDS THEN 
                RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE Elimina_seguradora:

    RUN Elimina_seguradora IN hBO(INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_idorigem,
                                  INPUT aux_nmdatela,
                                  INPUT aux_cdprogra,
                                  INPUT aux_cdsegura,
                                 OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            IF TEMP-TABLE tt-erro:HAS-RECORDS THEN 
                RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
            RUN piXmlSave.
        END.  

END PROCEDURE.


PROCEDURE busca_crapcsg:

    RUN busca_crapcsg IN hBO
        ( INPUT aux_cdcooper,
          INPUT aux_cdsegura,
          INPUT aux_nmsegura,
          INPUT aux_flgativo,
          INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
          INPUT aux_nriniseq,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-crapcsg ).

    IF  LOOKUP(RETURN-VALUE,"OK,") = 0 THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca de dados.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapcsg:HANDLE,
                             INPUT "SEGURADORA").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.
