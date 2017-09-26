/*............................................................................

     Programa: sistema/generico/procedures/xb1wgen0120.p
     Autor   : Rogerius Militão
     Data    : Novembro/2011                    Ultima atualizacao: 15/08/2017

     Objetivo  : BO de Comunicacao XML x BO - Tela BCAIXA

     Alteracoes: 16/04/2013 - Incluir Parametro aux_tpcaicof na Busca_Dados.
                            - Incluir nova procedure imprime_caixa_cofre
                              referente ao Projeto Sangria de Caixa (Lucas R.)
                              
                 28/08/2013 - Incluido o parametro dtrefere na procedure 
                              Busca_Dados e imprime_caixa_cofre (Carlos)

                 15/08/2017 - Incluir parametros de entrada dtmvtolx e operauto
                              na procedure Grava_Dados (Lucas Ranghetti #665982)
............................................................................*/



/*..........................................................................*/
DEF VAR aux_cdcooper  AS INTE                                        NO-UNDO.
DEF VAR aux_cdagenci  AS INTE                                        NO-UNDO.
DEF VAR aux_nrdcaixa  AS INTE                                        NO-UNDO.
DEF VAR aux_cdoperad  AS CHAR                                        NO-UNDO.
DEF VAR aux_nmdatela  AS CHAR                                        NO-UNDO.
DEF VAR aux_idorigem  AS INTE                                        NO-UNDO.
DEF VAR aux_cdprogra  AS CHAR                                        NO-UNDO.

DEF VAR aux_cddopcao  AS CHAR                                        NO-UNDO.
DEF VAR aux_cdopecxa  AS CHAR                                        NO-UNDO.
DEF VAR aux_dtmvtolx  AS DATE                                        NO-UNDO.
DEF VAR aux_cdagencx  AS INTE                                        NO-UNDO.
DEF VAR aux_nrdcaixx  AS INTE                                        NO-UNDO.
DEF VAR aux_dtrefere  AS DATE                                        NO-UNDO.
DEF VAR aux_cdoplanc  AS CHAR                                        NO-UNDO.

DEF VAR aux_ndrrecid  AS RECID                                       NO-UNDO.
DEF VAR aux_nrdlacre  AS INTE                                        NO-UNDO.

DEF VAR aux_tipconsu  AS LOGICAL                                     NO-UNDO.
DEF VAR aux_vldsdfin  AS DECI                                        NO-UNDO.
DEF VAR aux_vlrttdeb  AS DECI                                        NO-UNDO.
DEF VAR aux_vldentra  AS DECI                                        NO-UNDO.
DEF VAR aux_vldsaida  AS DECI                                        NO-UNDO.
DEF VAR aux_qtautent  AS INTE                                        NO-UNDO.       
DEF VAR aux_vldsdini  AS DECI                                        NO-UNDO.
DEF VAR aux_nrdmaqui  AS INTE                                        NO-UNDO.

DEF VAR aux_cdhistor  AS INTE                                        NO-UNDO.
DEF VAR aux_nrdocmto  AS INTE                                        NO-UNDO.
DEF VAR aux_nrseqdig  AS INTE                                        NO-UNDO.

DEF VAR aux_vlrttcrd  AS DECI                                        NO-UNDO.
DEF VAR aux_nrctadeb  AS INTE                                        NO-UNDO.
DEF VAR aux_nrctacrd  AS INTE                                        NO-UNDO.
DEF VAR aux_dshistor  AS CHAR                                        NO-UNDO.
DEF VAR aux_dsdcompl  AS CHAR                                        NO-UNDO.
DEF VAR aux_vldocmto  AS DECI                                        NO-UNDO.
                      
DEF VAR aux_nmdcampo  AS CHAR                                        NO-UNDO.
DEF VAR aux_msgsenha  AS CHAR                                        NO-UNDO.
DEF VAR aux_msgretor  AS CHAR                                        NO-UNDO.
DEF VAR aux_flgsemhi  AS LOGICAL                                     NO-UNDO.
DEF VAR aux_saldot    AS DECI                                        NO-UNDO.

DEF VAR aux_indcompl  AS INTE                                        NO-UNDO.

DEF VAR aux_dsiduser  AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarqimp  AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarqpdf  AS CHAR                                        NO-UNDO.

DEF VAR aux_tpcaicof AS CHAR                                         NO-UNDO.
DEF VAR aux_operauto AS CHAR                                         NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0120tt.i }
{ sistema/generico/includes/b1wgen0096tt.i }

/*............................... PROCEDURES ................................*/
 PROCEDURE valores_entrada:

     FOR EACH tt-param:

         CASE tt-param.nomeCampo:
            
             WHEN "cdcooper"  THEN aux_cdcooper = INTE(tt-param.valorCampo).
             WHEN "cdagenci"  THEN aux_cdagenci = INTE(tt-param.valorCampo).
             WHEN "nrdcaixa"  THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
             WHEN "dtrefere"  THEN aux_dtrefere = DATE(tt-param.valorCampo).
             WHEN "cdoperad"  THEN aux_cdoperad = tt-param.valorCampo.
             WHEN "nmdatela"  THEN aux_nmdatela = tt-param.valorCampo.
             WHEN "dtmvtolt"  THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
             WHEN "dtmvtopr"  THEN aux_dtmvtopr = DATE(tt-param.valorCampo).
             WHEN "idorigem"  THEN aux_idorigem = INTE(tt-param.valorCampo).
             WHEN "cdprogra"  THEN aux_cdprogra = tt-param.valorCampo.
                              
             WHEN "cddopcao"  THEN aux_cddopcao = tt-param.valorCampo.
             WHEN "cdopecxa"  THEN aux_cdopecxa = tt-param.valorCampo.
             WHEN "dtmvtolx"  THEN aux_dtmvtolx = DATE(tt-param.valorCampo).
             WHEN "cdagencx"  THEN aux_cdagencx = INTE(tt-param.valorCampo).
             WHEN "nrdcaixx"  THEN aux_nrdcaixx = INTE(tt-param.valorCampo).
             WHEN "cdoplanc"  THEN aux_cdoplanc = tt-param.valorCampo.

             WHEN "ndrrecid"  THEN aux_ndrrecid = INTE(tt-param.valorCampo). 
             WHEN "nrdlacre"  THEN aux_nrdlacre = INTE(tt-param.valorCampo).  

             WHEN "tipconsu"  THEN aux_tipconsu = LOGICAL(tt-param.valorCampo).   
             WHEN "vldsdfin"  THEN aux_vldsdfin = DECI(tt-param.valorCampo).   
             WHEN "vlrttdeb"  THEN aux_vlrttdeb = DECI(tt-param.valorCampo).   
             WHEN "vldentra"  THEN aux_vldentra = DECI(tt-param.valorCampo).     
             WHEN "vldsaida"  THEN aux_vldsaida = DECI(tt-param.valorCampo).     
             WHEN "qtautent"  THEN aux_qtautent = INTE(tt-param.valorCampo).
             WHEN "vldsdini"  THEN aux_vldsdini = DECI(tt-param.valorCampo).
             WHEN "nrdmaqui"  THEN aux_nrdmaqui = INTE(tt-param.valorCampo).
            
             WHEN "cdhistor"  THEN aux_cdhistor = INTE(tt-param.valorCampo). 
             WHEN "nrdocmto"  THEN aux_nrdocmto = INTE(tt-param.valorCampo). 
             WHEN "nrseqdig"  THEN aux_nrseqdig = INTE(tt-param.valorCampo). 

             WHEN "vlrttcrd"  THEN aux_vlrttcrd = DECI(tt-param.valorCampo).
             WHEN "nrctadeb"  THEN aux_nrctadeb = INTE(tt-param.valorCampo). 
             WHEN "nrctacrd"  THEN aux_nrctacrd = INTE(tt-param.valorCampo). 
             WHEN "dshistor"  THEN aux_dshistor = tt-param.valorCampo. 
             WHEN "dsdcompl"  THEN aux_dsdcompl = tt-param.valorCampo. 
             WHEN "vldocmto"  THEN aux_vldocmto = DECI(tt-param.valorCampo). 

             WHEN "indcompl"  THEN aux_indcompl = INTE(tt-param.valorCampo).

             WHEN "nmdcampo"  THEN aux_nmdcampo = tt-param.valorCampo.
             WHEN "dsiduser"  THEN aux_dsiduser = tt-param.valorCampo.
             WHEN "nmarqimp"  THEN aux_nmarqimp = tt-param.valorCampo.
             WHEN "nmarqpdf"  THEN aux_nmarqpdf = tt-param.valorCampo.

             WHEN "tpcaicof"  THEN aux_tpcaicof = tt-param.valorCampo.
             WHEN "operauto"  THEN aux_operauto = tt-param.valorCampo.
             
         END CASE.

     END. /** Fim do FOR EACH tt-param **/


 END PROCEDURE. /* valores_entrada */

/* ------------------------------------------------------------------------ */
/*                    EFETUA A BUSCA DA TELA BCAIXA                         */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    RUN Busca_Dados IN hBO
                  ( INPUT aux_cdcooper,
                    INPUT aux_cdagenci,
                    INPUT aux_nrdcaixa,
                    INPUT aux_cdoperad,
                    INPUT aux_cdprogra,
                    INPUT aux_idorigem,
                    INPUT aux_dtmvtolt,
                    INPUT aux_dtmvtopr,
                    INPUT aux_nmdatela,
                    INPUT aux_dsiduser,
                    INPUT aux_cddopcao,
                    INPUT aux_cdopecxa,
                    INPUT aux_dtmvtolx,
                    INPUT aux_cdagencx,
                    INPUT aux_nrdcaixx, 
                    INPUT aux_dtrefere,
                    INPUT aux_cdoplanc, 
                    INPUT YES, /* flglog */
                    INPUT aux_tpcaicof,
                   OUTPUT aux_msgsenha,
                   OUTPUT aux_msgretor,
                   OUTPUT aux_flgsemhi,
                   OUTPUT aux_saldot,  
                   OUTPUT TABLE tt-boletimcx, 
                   OUTPUT TABLE tt-lanctos,
                   OUTPUT TABLE tt_crapbcx,
                   OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
               END.
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-boletimcx:HANDLE,
                            INPUT "boletimcx").
           RUN piXmlAtributo (INPUT "msgsenha", INPUT aux_msgsenha).
           RUN piXmlAtributo (INPUT "msgretor", INPUT aux_msgretor).
           RUN piXmlAtributo (INPUT "flgsemhi", INPUT aux_flgsemhi).
           RUN piXmlAtributo (INPUT "saldot",   INPUT aux_saldot).
           RUN piXmlExport (INPUT TEMP-TABLE tt-lanctos:HANDLE,
                            INPUT "lanctos").
           RUN piXmlExport (INPUT TEMP-TABLE tt_crapbcx:HANDLE,
                            INPUT "crapbcx").
           RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Dados */

 
/* ------------------------------------------------------------------------ */
/*                      GERA O TERMO PARA IMPRESSAO                         */
/* ------------------------------------------------------------------------ */
PROCEDURE Gera_Termo:

    RUN Gera_Termo IN hBO
                  ( INPUT aux_cdcooper,
                    INPUT aux_cdagenci,
                    INPUT aux_nrdcaixa,
                    INPUT aux_idorigem,
                    INPUT aux_dtmvtolt,
                    INPUT aux_cddopcao,
                    INPUT aux_dsiduser,
                    INPUT aux_ndrrecid,
                    INPUT aux_nrdlacre,
                   OUTPUT aux_nmarqimp, 
                   OUTPUT aux_nmarqpdf,
                   OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
               END.
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "nmarqimp", INPUT aux_nmarqimp).
           RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Gera_Termo */

/* ------------------------------------------------------------------------ */
/*                      GERA O Boletim PARA IMPRESSAO                         */
/* ------------------------------------------------------------------------ */
PROCEDURE Gera_Boletim:

    RUN Gera_Boletim IN hBO
                   ( INPUT aux_cdcooper,
                     INPUT aux_cdagenci,
                     INPUT aux_nrdcaixa,
                     INPUT aux_idorigem,
                     INPUT aux_nmdatela,
                     INPUT aux_dtmvtolt,
                     INPUT aux_dsiduser,
                     INPUT aux_tipconsu,
                     INPUT aux_ndrrecid,
                    OUTPUT aux_flgsemhi, 
                    OUTPUT aux_vldsdfin,
                    OUTPUT aux_vlrttcrd,
                    OUTPUT aux_vlrttdeb, 
                    OUTPUT aux_nmarqimp, 
                    OUTPUT aux_nmarqpdf,
                    OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
               END.
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "nmarqimp", INPUT aux_nmarqimp).
           RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Gera_Boletim */

/* ------------------------------------------------------------------------ */
/*                  GERA A FITA DE CAIXA PARA IMPRESSAO                     */
/* ------------------------------------------------------------------------ */
PROCEDURE Gera_Fita_Caixa:

    RUN Gera_Fita_Caixa IN hBO
                      ( INPUT aux_cdcooper,
                        INPUT aux_cdagenci,
                        INPUT aux_nrdcaixa,
                        INPUT aux_idorigem,
                        INPUT aux_nmdatela,
                        INPUT aux_dtmvtolt,
                        INPUT aux_cddopcao,
                        INPUT aux_dsiduser,
                        INPUT aux_ndrrecid,
                        INPUT aux_tipconsu,
                       OUTPUT aux_nmarqimp, 
                       OUTPUT aux_nmarqpdf,
                       OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
               END.
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "nmarqimp", INPUT aux_nmarqimp).
           RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Gera_Fita_Caixa */

/* ------------------------------------------------------------------------ */
/*                  GERA A FITA DE CAIXA PARA IMPRESSAO                     */
/* ------------------------------------------------------------------------ */
PROCEDURE Gera_Depositos_Saques:

    RUN Gera_Depositos_Saques IN hBO
                     ( INPUT aux_cdcooper,
                       INPUT aux_cdagenci,
                       INPUT aux_nrdcaixa,
                       INPUT aux_idorigem,
                       INPUT aux_nmdatela,
                       INPUT aux_dtmvtolt,
                       INPUT aux_cddopcao,
                       INPUT aux_dsiduser,
                       INPUT aux_ndrrecid,
                       INPUT aux_tipconsu,
                      OUTPUT aux_nmarqimp, 
                      OUTPUT aux_nmarqpdf,
                      OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
               END.
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "nmarqimp", INPUT aux_nmarqimp).
           RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Gera_Depositos_Saques */

/* ------------------------------------------------------------------------ */
/*                EFETUA A VALIDAÇÃO DOS DADOS DA TELA BCAIXA               */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Dados:

    RUN Valida_Dados IN hBO
                   ( INPUT aux_cdcooper,
                     INPUT aux_cdagenci,
                     INPUT aux_nrdcaixa,
                     INPUT aux_cdoperad,
                     INPUT aux_idorigem,
                     INPUT aux_dtmvtolt,
                     INPUT aux_dtmvtopr,
                     INPUT aux_nmdatela,
                     INPUT aux_dsiduser,
                     INPUT aux_cddopcao,
                     INPUT aux_cdopecxa,
                     INPUT aux_dtmvtolx,
                     INPUT aux_cdagencx,
                     INPUT aux_nrdcaixx,
                     INPUT aux_vldentra,
                     INPUT aux_vldsaida,
                     INPUT aux_cdoplanc,
                     INPUT aux_cdhistor,
                     INPUT aux_nrdocmto,
                     INPUT aux_nrseqdig,
                     INPUT aux_vldocmto,
                     INPUT YES,
                    OUTPUT aux_nmdcampo, 
                    OUTPUT aux_msgretor,
                    OUTPUT aux_vlrttcrd,
                    OUTPUT aux_vldsdfin,
                    OUTPUT aux_nrctadeb,
                    OUTPUT aux_nrctacrd,
                    OUTPUT aux_cdhistor,
                    OUTPUT aux_dshistor,
                    OUTPUT aux_dsdcompl,
                    OUTPUT aux_vldocmto,
                    OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
               END.
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlAtributo (INPUT "msgretor", INPUT aux_msgretor).
           RUN piXmlAtributo (INPUT "nmdcampo", INPUT aux_nmdcampo).
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "msgretor", INPUT aux_msgretor).
           RUN piXmlAtributo (INPUT "vlrttcrd", INPUT aux_vlrttcrd).
           RUN piXmlAtributo (INPUT "vldsdfin", INPUT aux_vldsdfin).
           RUN piXmlAtributo (INPUT "nrctadeb", INPUT aux_nrctadeb).
           RUN piXmlAtributo (INPUT "nrctacrd", INPUT aux_nrctacrd).
           RUN piXmlAtributo (INPUT "cdhistor", INPUT aux_cdhistor).
           RUN piXmlAtributo (INPUT "dshistor", INPUT aux_dshistor).
           RUN piXmlAtributo (INPUT "dsdcompl", INPUT aux_dsdcompl).
           RUN piXmlAtributo (INPUT "vldocmto", INPUT aux_vldocmto).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Valida_Dados */

/* ------------------------------------------------------------------------ */
/*                EFETUA A GRAVAÇÃO DOS DADOS DA TELA BCAIXA                */
/* ------------------------------------------------------------------------ */
PROCEDURE Grava_Dados:

    RUN Grava_Dados IN hBO
                   ( INPUT aux_cdcooper,
                     INPUT aux_cdagenci,
                     INPUT aux_nrdcaixa,
                     INPUT aux_cdoperad,
                     INPUT aux_idorigem,
                     INPUT aux_dtmvtolt,
                     INPUT aux_cddopcao,
                     INPUT aux_cdoplanc,
                     INPUT aux_cdagencx,
                     INPUT aux_nrdcaixx,
                     INPUT aux_cdopecxa,
                     INPUT aux_nrdlacre,
                     INPUT aux_qtautent,
                     INPUT aux_vldentra,
                     INPUT aux_vldsaida,
                     INPUT aux_vldsdini,
                     INPUT aux_nrdmaqui,
                     INPUT aux_nrdocmto,
                     INPUT aux_nrseqdig,
                     INPUT aux_cdhistor,
                     INPUT aux_dsdcompl,
                     INPUT aux_vldocmto,
                     INPUT YES,
                     INPUT aux_dtmvtolx,
                     INPUT aux_operauto,
                    OUTPUT aux_ndrrecid, 
                    OUTPUT aux_nrdlacre,
                    OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
               END.
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "ndrrecid", INPUT aux_ndrrecid).
           RUN piXmlAtributo (INPUT "nrdlacre", INPUT aux_nrdlacre).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Grava_Dados */

/* ------------------------------------------------------------------------ */
/*                EFETUA A GRAVAÇÃO DOS DADOS DA TELA BCAIXA                */
/* ------------------------------------------------------------------------ */
PROCEDURE Valida_Historico:

    
    RUN Valida_Historico IN hBO
                       ( INPUT aux_cdcooper,
                         INPUT aux_cdagenci,
                         INPUT aux_nrdcaixa,
                         INPUT aux_cdoperad,
                         INPUT aux_idorigem,
                         INPUT aux_cdoplanc,
                         INPUT aux_cdagencx,
                         INPUT aux_cdhistor,
                         INPUT aux_nrdocmto,
                         INPUT aux_nrseqdig,
                        OUTPUT aux_nrctadeb, 
                        OUTPUT aux_nrctacrd,
                        OUTPUT aux_cdhistor, 
                        OUTPUT aux_dshistor, 
                        OUTPUT aux_indcompl, 
                        OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "busca de dados.".
               END.
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "nrctadeb", INPUT aux_nrctadeb).
           RUN piXmlAtributo (INPUT "nrctacrd", INPUT aux_nrctacrd).
           RUN piXmlAtributo (INPUT "cdhistor", INPUT aux_cdhistor).
           RUN piXmlAtributo (INPUT "dshistor", INPUT aux_dshistor).
           RUN piXmlAtributo (INPUT "indcompl", INPUT aux_indcompl).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Valida_Historico */

PROCEDURE imprime_caixa_cofre:

    RUN imprime_caixa_cofre IN hBO
                   ( INPUT aux_cdcooper,
                     INPUT aux_dtmvtolt,
                     INPUT aux_idorigem,
                     INPUT aux_cdagenci,
                     INPUT aux_dtrefere,
                     INPUT aux_cdoperad,
                     INPUT aux_cdprogra,
                     INPUT aux_dsiduser,
                     INPUT aux_tpcaicof,
                    OUTPUT aux_nmarqimp, 
                    OUTPUT aux_nmarqpdf,
                    OUTPUT TABLE tt-msg-confirma).

           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "nmarqimp", INPUT aux_nmarqimp).
           RUN piXmlAtributo (INPUT "nmarqpdf", INPUT aux_nmarqpdf).
           RUN piXmlSave.

END PROCEDURE. /* imprime_caixa_cofre */
