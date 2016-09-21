/*............................................................................

     Programa: sistema/generico/procedures/xb1wgen0160.p
     Autor   : Gabriel Capoia
     Data    : 12/07/2013                    Ultima atualizacao: 00/00/0000

     Objetivo  : BO de Comunicacao XML x BO - Tela PESQSR

     Alteracoes: 

............................................................................*/



/*..........................................................................*/

DEF VAR aux_cdcooper AS INTE                                         NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                         NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                         NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                         NO-UNDO.
DEF VAR aux_dtcheque AS DATE                                         NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                         NO-UNDO.
DEF VAR aux_idorigem AS INTE                                         NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                         NO-UNDO.
DEF VAR aux_nrdocmto AS INTE                                         NO-UNDO.
DEF VAR aux_nrdctabb AS INTE                                         NO-UNDO.
DEF VAR aux_cdbaninf AS INTE                                         NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                         NO-UNDO.
DEF VAR aux_cdbccxlt AS INTE                                         NO-UNDO.
DEF VAR aux_dtmvtola AS DATE                                         NO-UNDO.
DEF VAR aux_flgerlog AS LOGI                                         NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                         NO-UNDO.
DEF VAR ret_nmarquiv AS CHAR                                         NO-UNDO.
DEF VAR ret_nmarqpdf AS CHAR                                         NO-UNDO.

DEF TEMP-TABLE tt-teste NO-UNDO
    FIELD nrseqchq AS CHAR
    FIELD dtmvtolt AS CHAR
    FIELD cdalinea AS CHAR.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0160tt.i }

/*............................... PROCEDURES ................................*/
 PROCEDURE valores_entrada:

     FOR EACH tt-param:

         CASE tt-param.nomeCampo:

             WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
             WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
             WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
             WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
             WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
             WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
             WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
             WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
             WHEN "nrdocmto" THEN aux_nrdocmto = INTE(tt-param.valorCampo).
             WHEN "nrdctabb" THEN aux_nrdctabb = INTE(tt-param.valorCampo).
             WHEN "cdbaninf" THEN aux_cdbaninf = INTE(tt-param.valorCampo).
             WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
             WHEN "cdbccxlt" THEN aux_cdbccxlt = INTE(tt-param.valorCampo).
             WHEN "dtmvtola" THEN aux_dtmvtola = DATE(tt-param.valorCampo).
             WHEN "dtcheque" THEN aux_dtcheque = DATE(tt-param.valorCampo).
             WHEN "nmarqimp" THEN aux_nmarqimp = tt-param.valorCampo.    
                              
         END CASE.

     END. /** Fim do FOR EACH tt-param **/


 END PROCEDURE. /* valores_entrada */


/* ------------------------------------------------------------------------ */
/*                       EFETUA A PESQUISA DE REMESSA                       */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:            
    
    RUN Busca_Dados IN hBO
                  ( INPUT aux_cdcooper,
                    INPUT aux_cdagenci,
                    INPUT aux_nrdcaixa,
                    INPUT aux_cdoperad,
                    INPUT aux_nmdatela,
                    INPUT aux_idorigem,
                    INPUT aux_dtmvtolt,
                    INPUT aux_cddopcao,
                    INPUT aux_nrdocmto,
                    INPUT aux_nrdctabb,
                    INPUT aux_cdbaninf,
                    INPUT aux_nrdconta,
                    INPUT aux_cdbccxlt,
                    INPUT aux_dtmvtola,
                    INPUT TRUE, /* flgerlog */
                   OUTPUT TABLE tt-pesqsr,
                   OUTPUT TABLE tt-dados-cheque,
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
/*            MESSAGE "chw ---- tt-pesqsr ----".
            FOR EACH tt-pesqsr:
                DISP tt-pesqsr WITH 1 COL.
            END.
            MESSAGE "chw ---- fim tt-pesqsr ----".

            MESSAGE "chw ---- tt-dados-cheque ----".
            FOR EACH tt-dados-cheque:
                DISP tt-dados-cheque WITH 1 COL.
            END.
            MESSAGE "chw ---- fim tt-dados-cheque ----".
*/
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-pesqsr:HANDLE,
                             INPUT "Dados"). 

/*
CREATE tt-teste.
   ASSIGN tt-teste.nrseqchq = "1"
          tt-teste.dtmvtolt = "01/10/2016"
          tt-teste.cdalinea = "12345".
   VALIDATE tt-teste.

RUN piXmlExport (INPUT TEMP-TABLE tt-teste:HANDLE,
                             INPUT "Cheques").
*/
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-cheque:HANDLE,
                             INPUT "Cheques").
            RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Dados */

PROCEDURE Busca_Opcao_R.

    RUN Busca_Opcao_R IN hBO
                   ( INPUT aux_cdcooper,
                     INPUT aux_dtmvtolt,
                     INPUT aux_idorigem,
                     INPUT aux_dtcheque,
                     INPUT aux_nmarqimp,
                     OUTPUT ret_nmarquiv,
                     OUTPUT ret_nmarqpdf,
                     OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro THEN
                DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").

        END.
    ELSE DO:
        RUN piXmlNew.
        RUN piXmlAtributo (INPUT "nmarquiv",INPUT STRING(ret_nmarquiv)).
        RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(ret_nmarqpdf)).
        RUN piXmlSave.
    END.

END PROCEDURE.
