/*.............................................................................

    Programa: sistema/generico/procedures/xb1wgen0182.p
    Data    : Setembro/2013
    Autor   : Renersson Ricardo Agostini (GATI)      Ultima atualizacao: 24/03/2014
  
    Dados referentes ao programa:
  
    Objetivo  : BO de Comunicacao XML x BO 
                Tela - ADMCRD
                BO - sistema/generico/procedures/b1wgen0182.p
                Cadastro de Administradoras de Cartoes de Credito.
                
  
    Alteracoes: 25/02/2014 - Reformulação e Correção da xBO182 (Lucas).
                24/03/2014 - Novos campos Projeto cartão Bancoob (Jean Michel).
    
.............................................................................*/

DEFINE VARIABLE aux_cdcooper AS INTE                                NO-UNDO.
DEFINE VARIABLE aux_cdagenci AS INTE                                NO-UNDO.
DEFINE VARIABLE aux_cdadmcrd AS INTE                                NO-UNDO.
DEFINE VARIABLE aux_nrregist AS INTE                                NO-UNDO.
DEFINE VARIABLE aux_nriniseq AS INTE                                NO-UNDO.
DEFINE VARIABLE aux_qtregist AS INTE                                NO-UNDO.
DEFINE VARIABLE aux_nrdcaixa AS INTE                                NO-UNDO.
DEFINE VARIABLE aux_cdoperad AS CHAR FORMAT "x(10)"                 NO-UNDO.
DEFINE VARIABLE aux_cddopcao AS CHAR                                NO-UNDO.
DEFINE VARIABLE aux_nmdcampo AS CHAR                                NO-UNDO.
DEFINE VARIABLE aux_flgerlog AS LOGI                                NO-UNDO.
DEFINE VARIABLE aux_flgcchip AS INTE                                NO-UNDO.

DEF   VAR   aux_cdagecta LIKE crapadc.cdagecta                      NO-UNDO.
DEF   VAR   aux_cddigage LIKE crapadc.cddigage                      NO-UNDO.
DEF   VAR   aux_cdufende LIKE crapadc.cdufende                      NO-UNDO.
DEF   VAR   aux_dsendere LIKE crapadc.dsendere                      NO-UNDO.
DEF   VAR   aux_nmadmcrd LIKE crapadc.nmadmcrd                      NO-UNDO.
DEF   VAR   aux_nmagecta LIKE crapadc.nmagecta                      NO-UNDO.
DEF   VAR   aux_nmbairro LIKE crapadc.nmbairro                      NO-UNDO.
DEF   VAR   aux_nmbandei LIKE crapadc.nmbandei                      NO-UNDO.
DEF   VAR   aux_nmcidade LIKE crapadc.nmcidade                      NO-UNDO.
DEF   VAR   aux_nmpescto LIKE crapadc.nmpescto                      NO-UNDO.
DEF   VAR   aux_nmresadm LIKE crapadc.nmresadm                      NO-UNDO.
DEF   VAR   aux_nrcepend LIKE crapadc.nrcepend                      NO-UNDO.
DEF   VAR   aux_nrctacor LIKE crapadc.nrctacor                      NO-UNDO.
DEF   VAR   aux_nrdigcta LIKE crapadc.nrdigcta                      NO-UNDO.
DEF   VAR   aux_nrrazcta LIKE crapadc.nrrazcta                      NO-UNDO.
DEF   VAR   aux_qtcarnom LIKE crapadc.qtcarnom                      NO-UNDO.
DEF   VAR   aux_dsemail1 LIKE crapadc.dsdemail                      NO-UNDO.
DEF   VAR   aux_dsemail2 LIKE crapadc.dsdemail                      NO-UNDO.
DEF   VAR   aux_dsemail3 LIKE crapadc.dsdemail                      NO-UNDO.
DEF   VAR   aux_dsemail4 LIKE crapadc.dsdemail                      NO-UNDO.
DEF   VAR   aux_dsemail5 LIKE crapadc.dsdemail                      NO-UNDO.
DEF   VAR   aux_inanuida LIKE crapadc.inanuida                      NO-UNDO.
DEF   VAR   aux_tpctahab LIKE crapadc.tpctahab                      NO-UNDO.
DEF   VAR   aux_nrctamae LIKE crapadc.nrctamae                      NO-UNDO.
DEF   VAR   aux_cdclasse LIKE crapadc.cdclasse                      NO-UNDO.

DEF   VAR   aux_insitadc AS LOGICAL FORMAT "ATIVADA/DESATIVADA" 
                                    INITIAL TRUE                    NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgen0182tt.i }

/*................................ PROCEDURES ................................*/
/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/

PROCEDURE valores_entrada:

     FOR EACH tt-param:
         CASE tt-param.nomeCampo:
             WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
             WHEN 'cdagenci' THEN aux_cdagenci = INTE(tt-param.valorCampo).
             WHEN 'nrdcaixa' THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
             WHEN 'cdoperad' THEN aux_cdoperad = tt-param.valorCampo.
             WHEN 'cddopcao' THEN aux_cddopcao = tt-param.valorCampo.
             WHEN "cdadmcrd" THEN aux_cdadmcrd = INTE(tt-param.valorCampo).
             WHEN "cdagecta" THEN aux_cdagecta = INTE(tt-param.valorCampo).
             WHEN "cddigage" THEN aux_cddigage = INTE(tt-param.valorCampo).
             WHEN "cdufende" THEN aux_cdufende = tt-param.valorCampo.
             WHEN "dsendere" THEN aux_dsendere = tt-param.valorCampo.
             WHEN "nmadmcrd" THEN aux_nmadmcrd = tt-param.valorCampo.
             WHEN "nmagecta" THEN aux_nmagecta = tt-param.valorCampo.
             WHEN "nmbairro" THEN aux_nmbairro = tt-param.valorCampo.
             WHEN "nmbandei" THEN aux_nmbandei = tt-param.valorCampo.
             WHEN "nmcidade" THEN aux_nmcidade = tt-param.valorCampo.
             WHEN "nmpescto" THEN aux_nmpescto = tt-param.valorCampo.
             WHEN "nmresadm" THEN aux_nmresadm = tt-param.valorCampo.
             WHEN "nrcepend" THEN aux_nrcepend = inte(tt-param.valorCampo).
             WHEN "nrctacor" THEN aux_nrctacor = INTE(tt-param.valorCampo).
             WHEN "nrdigcta" THEN aux_nrdigcta = INTE(tt-param.valorCampo).
             WHEN "nrrazcta" THEN aux_nrrazcta = INTE(tt-param.valorCampo).
             WHEN "qtcarnom" THEN aux_qtcarnom = INTE(tt-param.valorCampo).
             WHEN "inanuida" THEN aux_inanuida = INTE(tt-param.valorCampo).
             WHEN "dsemail1" THEN aux_dsemail1 = tt-param.valorCampo.
             WHEN "dsemail2" THEN aux_dsemail2 = tt-param.valorCampo.
             WHEN "dsemail3" THEN aux_dsemail3 = tt-param.valorCampo.
             WHEN "dsemail4" THEN aux_dsemail4 = tt-param.valorCampo.
             WHEN "dsemail5" THEN aux_dsemail5 = tt-param.valorCampo.
             WHEN "nmdcampo" THEN aux_nmdcampo = tt-param.valorCampo.
             WHEN "flgerlog" THEN aux_flgerlog = LOGICAL(tt-param.valorCampo).
             WHEN "flgcchip" THEN aux_flgcchip = INTE(tt-param.valorCampo).
             WHEN "tpctahab" THEN aux_tpctahab = INTE(tt-param.valorCampo).
             WHEN "nrctamae" THEN aux_nrctamae = INTE(tt-param.valorCampo).
             WHEN "cdclasse" THEN aux_cdclasse = INTE(tt-param.valorCampo).
             WHEN "insitadc" THEN aux_insitadc = LOGICAL(tt-param.valorCampo).
             WHEN "nrregist" THEN aux_nrregist = INT(tt-param.valorCampo).
             WHEN "nriniseq" THEN aux_nriniseq = INT(tt-param.valorCampo).
             WHEN "qtregist" THEN aux_qtregist = INT(tt-param.valorCampo).
         END CASE.

     END. /** Fim do FOR EACH tt-param **/


END PROCEDURE. /* valores_entrada */

PROCEDURE altera-adm-cartoes:
    
    RUN altera-adm-cartoes IN hBO(INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_cdadmcrd,
                                  INPUT aux_nmadmcrd,
                                  INPUT aux_nmresadm,
                                  INPUT aux_insitadc,
                                  INPUT aux_qtcarnom,
                                  INPUT aux_nmbandei,
                                  INPUT aux_nrctacor,
                                  INPUT aux_nrdigcta,
                                  INPUT aux_nrrazcta,
                                  INPUT aux_nmagecta,
                                  INPUT aux_cdagecta,
                                  INPUT aux_cddigage,
                                  INPUT aux_dsendere,
                                  INPUT aux_nmbairro,
                                  INPUT aux_nmcidade,
                                  INPUT aux_cdufende,
                                  INPUT aux_nrcepend,
                                  INPUT aux_nmpescto,
                                  INPUT aux_tpctahab,
                                  INPUT aux_nrctamae,
                                  INPUT aux_cdclasse,
                                  INPUT aux_inanuida,
                                  INPUT aux_dsemail1,
                                  INPUT aux_dsemail2,
                                  INPUT aux_dsemail3,
                                  INPUT aux_dsemail4,
                                  INPUT aux_dsemail5,
                                  INPUT aux_flgerlog,
                                  INPUT aux_flgcchip,
                                  OUTPUT aux_nmdcampo,
                                  OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
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
            RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE exclui-adm-cartoes:

    RUN exclui-adm-cartoes IN hBO(INPUT aux_cdcooper, 
                                  INPUT aux_cdagenci, 
                                  INPUT aux_nrdcaixa, 
                                  INPUT aux_cdoperad, 
                                  INPUT aux_dtmvtolt, 
                                  INPUT aux_cdadmcrd,
                                  INPUT aux_flgerlog,
                                  OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
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
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE inclui-adm-cartoes:

    RUN inclui-adm-cartoes IN hBO(INPUT aux_cdcooper, 
                                  INPUT aux_cdagenci, 
                                  INPUT aux_nrdcaixa, 
                                  INPUT aux_cdoperad, 
                                  INPUT aux_dtmvtolt, 
                                  INPUT aux_cdadmcrd, 
                                  INPUT aux_nmadmcrd, 
                                  INPUT aux_nmresadm,
                                  INPUT aux_insitadc,
                                  INPUT aux_qtcarnom,
                                  INPUT aux_nmbandei,
                                  INPUT aux_nrctacor,
                                  INPUT aux_nrdigcta,
                                  INPUT aux_nrrazcta,
                                  INPUT aux_nmagecta,
                                  INPUT aux_cdagecta,
                                  INPUT aux_cddigage,
                                  INPUT aux_dsendere,
                                  INPUT aux_nmbairro,
                                  INPUT aux_nmcidade,
                                  INPUT aux_cdufende,
                                  INPUT aux_nrcepend,
                                  INPUT aux_nmpescto,
                                  INPUT aux_dsemail1,
                                  INPUT aux_dsemail2,
                                  INPUT aux_dsemail3,
                                  INPUT aux_dsemail4,
                                  INPUT aux_dsemail5,
                                  INPUT aux_tpctahab,
                                  INPUT aux_nrctamae,
                                  INPUT aux_cdclasse,
                                  INPUT aux_inanuida,
                                  INPUT aux_flgerlog,
                                  INPUT aux_flgcchip,
                                  OUTPUT aux_nmdcampo,
                                  OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
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
            RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE consulta-administradora:

    RUN consulta-administradora IN hBO(INPUT aux_cdcooper, 
                                       INPUT aux_cdagenci, 
                                       INPUT aux_nrdcaixa, 
                                       INPUT aux_cdoperad, 
                                       INPUT aux_dtmvtolt, 
                                       INPUT aux_cddopcao,
                                       INPUT aux_cdadmcrd,
                                       INPUT aux_nmadmcrd,
                                       INPUT (IF aux_nrregist = 0 THEN 1 ELSE aux_nrregist),
                                       INPUT aux_nriniseq,
                                       OUTPUT aux_qtregist,
                                       OUTPUT TABLE tt-crapadc,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapadc:HANDLE,
                             INPUT "crapadc").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.

END PROCEDURE.
