
/*..............................................................................

   Programa: xb1wgen0132.p
   Autor   : Lucas
   Data    : Nov/2011                       Ultima atualizacao:

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO132 (b1wgen0132.p) [TAB007]

   Alteracoes: 06/12/2016 - P341-Automatização BACENJUD - Alterar a passagem 
                            da descrição do departamento como parametro e 
							passar o código (Renato Darosci)

..............................................................................*/

DEF VAR aux_cdcooper AS INTE                                       NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                       NO-UNDO.             
DEF VAR aux_nrdcaixa AS INTE                                       NO-UNDO.
DEF VAR aux_idorigem AS INTE                                       NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                       NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                       NO-UNDO.
DEF VAR aux_cddepart AS INTE                                       NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                       NO-UNDO.
DEF VAR aux_flgerlog AS LOGI                                       NO-UNDO.
DEF VAR aux_vlmaidep AS DECI                                       NO-UNDO.
DEF VAR aux_vlmaiapl AS DECI                                       NO-UNDO.
DEF VAR aux_vlmaicot AS DECI                                       NO-UNDO.
DEF VAR aux_vlmaisal AS DECI                                       NO-UNDO.
DEF VAR aux_vlsldneg AS DECI                                       NO-UNDO.
                                                                  

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }

/* .........................PROCEDURES................................... */


/**************************************************************************
       Procedure para atribuicao dos dados de entrada enviados por XML
**************************************************************************/
PROCEDURE valores_entrada:

    FOR EACH tt-param NO-LOCK:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).           
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "flgerlog" THEN aux_flgerlog = LOGICAL(tt-param.valorCampo).
            WHEN "cddepart" THEN aux_cddepart = INTE(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "vlmaidep" THEN aux_vlmaidep = DEC(tt-param.valorCampo).
            WHEN "vlmaiapl" THEN aux_vlmaiapl = DEC(tt-param.valorCampo).
            WHEN "vlmaicot" THEN aux_vlmaicot = DEC(tt-param.valorCampo).
            WHEN "vlmaisal" THEN aux_vlmaisal = DEC(tt-param.valorCampo).
            WHEN "vlsldneg" THEN aux_vlsldneg = DEC(tt-param.valorCampo).

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.

/*****************************************************************************
  Valida permissão
******************************************************************************/

PROCEDURE permiss_tab007:

        RUN permiss_tab007 IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_cddepart,
                                   OUTPUT TABLE tt-erro).
                                 

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE tt-erro THEN
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
               RUN piXmlSave.
            END.

END PROCEDURE.


/*****************************************************************************
  Carregar os dados gravados na TAB007
******************************************************************************/

PROCEDURE busca_tab007:

        RUN busca_tab007 IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 OUTPUT aux_vlmaidep,
                                 OUTPUT aux_vlmaiapl,
                                 OUTPUT aux_vlmaicot,
                                 OUTPUT aux_vlmaisal,
                                 OUTPUT aux_vlsldneg,
                                 OUTPUT TABLE tt-erro).
                                 

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE tt-erro THEN
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
               RUN piXmlAtributo (INPUT "vlmaidep", INPUT STRING(aux_vlmaidep,"zzz,zzz,zzz,zz9.99")).
               RUN piXmlAtributo (INPUT "vlmaiapl", INPUT STRING(aux_vlmaiapl,"zzz,zzz,zzz,zz9.99")).
               RUN piXmlAtributo (INPUT "vlmaicot", INPUT STRING(aux_vlmaicot,"zzz,zzz,zzz,zz9.99")).
               RUN piXmlAtributo (INPUT "vlmaisal", INPUT STRING(aux_vlmaisal,"zzz,zzz,zzz,zz9.99")).
               RUN piXmlAtributo (INPUT "vlsldneg", INPUT STRING(aux_vlsldneg,"zzz,zzz,zzz,zz9.99")).
               RUN piXmlSave.
            END.

END PROCEDURE.

 /*****************************************************************************
  Alterar os dados gravados na TAB007
******************************************************************************/

PROCEDURE altera_tab007:

    RUN altera_tab007 IN hBO (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_dtmvtolt,
                              INPUT TRUE,
                              INPUT aux_cddepart,
                              INPUT aux_vlmaidep,
                              INPUT aux_vlmaiapl,
                              INPUT aux_vlmaicot,
                              INPUT aux_vlmaisal,
                              INPUT aux_vlsldneg,
                              OUTPUT TABLE tt-erro).
                              

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
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
            RUN piXmlSave.
        END.

END PROCEDURE.
