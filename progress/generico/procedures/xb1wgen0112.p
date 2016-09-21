/*.............................................................................

     Programa: sistema/generico/procedures/xb1wgen0112.p
     Autor   : Rogerius Militão
     Data    : Agosto/2011                       Ultima atualizacao: 21/01/2015

     Objetivo  : BO de Comunicacao XML x BO - Telas impres

     Alteracoes: 03/04/2012 - incluida procedure gera-impextepr (Tiago). 

                 28/08/2012 - Novo parametro na Valida_Opcao (tpmodelo)
                            - Nova procedure Gera_Impressa_Aplicacao
                              (Guilherme/Supero)
                              
                 24/10/2012 - Implementacao de melhorias (David Kruger).       
                 
                 31/10/2014 - Retirada chamada da procedure gera-impextepr
                              (Jean Michel).  
                              
                 21/01/2015 - Inclusao do parametro aux_intpextr na chamada 
                              da procedure Gera_impressao da B1WGEN0112.P
                              (Carlos Rafael Tanholi - Novos Produtos de Captacao)             

.............................................................................*/



/*...........................................................................*/
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_cdprogra AS CHAR                                           NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                           NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_tpextrat AS INTE                                           NO-UNDO.
DEF VAR aux_dtrefere AS DATE                                           NO-UNDO.
DEF VAR aux_dtreffim AS DATE                                           NO-UNDO.
DEF VAR aux_flgtarif AS LOGICAL                                        NO-UNDO.
DEF VAR aux_nranoref AS INTE                                           NO-UNDO.
DEF VAR aux_inselext AS INTE                                           NO-UNDO.
DEF VAR aux_nrctremp AS INTE                                           NO-UNDO.
DEF VAR aux_nraplica AS INTE                                           NO-UNDO.
DEF VAR aux_flgemiss AS LOGICAL                                        NO-UNDO.
DEF VAR aux_inrelext AS INTE                                           NO-UNDO.
DEF VAR aux_tpmodelo AS INTE                                           NO-UNDO.

DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.
DEF VAR aux_dsextrat AS CHAR                                           NO-UNDO.
DEF VAR aux_msgretor AS CHAR                                           NO-UNDO.

DEF VAR aux_flgrodar AS LOGICAL                                        NO-UNDO.

DEF VAR aux_flgerlog AS LOGICAL                                        NO-UNDO.
DEF VAR aux_intpextr AS INTE                                           NO-UNDO.

DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.

DEF VAR aux_dtvctini AS DATE                                           NO-UNDO.
DEF VAR aux_dtvctfim AS DATE                                           NO-UNDO.
DEF VAR aux_tprelato AS INTE                                           NO-UNDO.
DEF VAR aux_tpaplic2 AS INTE                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0112tt.i }
{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 

/*............................... PROCEDURES ................................*/
 PROCEDURE valores_entrada:

     DEFINE VARIABLE aux_rowidaux AS ROWID       NO-UNDO.

     FOR EACH tt-param:

         CASE tt-param.nomeCampo:
            
             WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
             WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
             WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
             WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
             WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
             WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
             WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
             WHEN "dtmvtopr" THEN aux_dtmvtopr = DATE(tt-param.valorCampo).
             WHEN "cdprogra" THEN aux_cdprogra = tt-param.valorCampo.
             WHEN "inproces" THEN aux_inproces = INTE(tt-param.valorCampo).
             WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.

             WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
             WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
             WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
             WHEN "tpextrat" THEN aux_tpextrat = INTE(tt-param.valorCampo).
             WHEN "dtrefere" THEN aux_dtrefere = DATE(tt-param.valorCampo).
             WHEN "dtreffim" THEN aux_dtreffim = DATE(tt-param.valorCampo).
             WHEN "flgtarif" THEN aux_flgtarif = LOGICAL(tt-param.valorCampo).
             WHEN "nranoref" THEN aux_nranoref = INTE(tt-param.valorCampo).
             WHEN "inselext" THEN aux_inselext = INTE(tt-param.valorCampo).
             WHEN "nrctremp" THEN aux_nrctremp = INTE(tt-param.valorCampo).
             WHEN "nraplica" THEN aux_nraplica = INTE(tt-param.valorCampo).
             WHEN "flgemiss" THEN aux_flgemiss = LOGICAL(tt-param.valorCampo).
             WHEN "inrelext" THEN aux_inrelext = INTE(tt-param.valorCampo).
             WHEN "nmdcampo" THEN aux_nmdcampo = tt-param.valorCampo.
             WHEN "dsextrat" THEN aux_dsextrat = tt-param.valorCampo.
             WHEN "intpextr" THEN aux_intpextr = INTE(tt-param.valorCampo).
             WHEN "flgrodar" THEN aux_flgrodar = LOGICAL(tt-param.valorCampo).
             WHEN "flgerlog" THEN aux_flgerlog = LOGICAL(tt-param.valorCampo).
             WHEN "tpmodelo" THEN aux_tpmodelo = INTE(tt-param.valorCampo).

             WHEN "dtvctini" THEN aux_dtvctini = DATE(tt-param.valorCampo).
             WHEN "dtvctfim" THEN aux_dtvctfim = DATE(tt-param.valorCampo).
             WHEN "tprelato" THEN aux_tprelato = INTE(tt-param.valorCampo).
             WHEN "tpaplic2" THEN aux_tpaplic2 = INTE(tt-param.valorCampo).

             WHEN "nmarqimp" THEN aux_nmarqimp = tt-param.valorCampo.
             WHEN "nmarqpdf" THEN aux_nmarqpdf = tt-param.valorCampo.
             
         END CASE.

     END. /** Fim do FOR EACH tt-param **/

     FOR EACH tt-param-i 
         BREAK BY tt-param-i.nomeTabela
               BY tt-param-i.sqControle:

         CASE tt-param-i.nomeTabela:

             WHEN "Impres" THEN DO:

                 IF  FIRST-OF(tt-param-i.sqControle) THEN
                     DO:
                        CREATE tt-impres.
                        ASSIGN aux_rowidaux = ROWID(tt-impres).
                     END.

                 FIND tt-impres WHERE ROWID(tt-impres) = aux_rowidaux
                                       NO-ERROR.

                 CASE tt-param-i.nomeCampo:
                     WHEN "nrdconta" THEN
                         tt-impres.nrdconta = INTE(tt-param-i.valorCampo).
                     WHEN "dtrefere" THEN
                         tt-impres.dtrefere = DATE(tt-param-i.valorCampo).
                     WHEN "dtreffim" THEN
                         tt-impres.dtreffim = DATE(tt-param-i.valorCampo).
                     WHEN "tpextrat" THEN
                         tt-impres.tpextrat = INTE(tt-param-i.valorCampo).
                     WHEN "dsextrat" THEN
                         tt-impres.dsextrat = tt-param-i.valorCampo.
                     WHEN "nranoref" THEN
                         tt-impres.nranoref = INTE(tt-param-i.valorCampo).
                     WHEN "nrctremp" THEN
                         tt-impres.nrctremp = INTE(tt-param-i.valorCampo).
                     WHEN "nraplica" THEN
                         tt-impres.nraplica = INTE(tt-param-i.valorCampo).
                     WHEN "inselext" THEN
                         tt-impres.inselext = INTE(tt-param-i.valorCampo).
                     WHEN "inrelext" THEN
                         tt-impres.inrelext = INTE(tt-param-i.valorCampo).
                     WHEN "inisenta" THEN
                         tt-impres.inisenta = LOGICAL(tt-param-i.valorCampo).
                     WHEN "insitext" THEN
                         tt-impres.insitext = INTE(tt-param-i.valorCampo).
                     WHEN "flgemiss" THEN
                         tt-impres.flgemiss = LOGICAL(tt-param-i.valorCampo).
                     WHEN "flgtarif" THEN
                         tt-impres.flgtarif = LOGICAL(tt-param-i.valorCampo).
                     WHEN "tpmodelo" THEN
                         tt-impres.tpmodelo = INTE(tt-param-i.valorCampo).

                 END CASE.
             END.

         END CASE.
     END.


 END PROCEDURE. /* valores_entrada */

/* ------------------------------------------------------------------------ */
/*                    EFETUA A BUSCA DOS DADOS DO ASSOCIADO                 */
/* ------------------------------------------------------------------------ */
 PROCEDURE Busca_Dados:

     RUN Busca_Dados IN hBO
                     ( INPUT aux_cdcooper,
                       INPUT aux_cdagenci,
                       INPUT aux_nrdcaixa,
                       INPUT aux_cdoperad,
                       INPUT aux_nmdatela,
                       INPUT aux_idorigem,
                       INPUT aux_cddopcao,
                       INPUT aux_nrdconta,
                       INPUT YES,
                      OUTPUT TABLE tt-impres,
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
            RUN piXmlExport   (INPUT TEMP-TABLE tt-impres:HANDLE,
                               INPUT "Impres").
            RUN piXmlSave.
         END.

 END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*                   EFETUA A VALIDAÇÃO DOS DADOS INFORMADOS                */
/* ------------------------------------------------------------------------ */
 PROCEDURE Valida_Dados:

     RUN Valida_Dados IN hBO
                      ( INPUT aux_cdcooper,
                        INPUT aux_cdagenci,
                        INPUT aux_nrdcaixa,
                        INPUT aux_cdoperad,
                        INPUT aux_nmdatela,
                        INPUT aux_idorigem,
                        INPUT aux_dtmvtolt,
                        INPUT aux_nrdconta,
                        INPUT aux_tpextrat,
                        INPUT aux_cddopcao,
                       OUTPUT aux_nmdcampo,
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
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT STRING(aux_nmdcampo)).
            RUN piXmlSave.

         END.
     ELSE
         DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "dsextrat",INPUT STRING(aux_dsextrat)).
            RUN piXmlSave.
         END.

 END PROCEDURE.

 /* ------------------------------------------------------------------------ */
/*                   EFETUA A VALIDAÇÃO DOS DADOS INFORMADOS                */
/* ------------------------------------------------------------------------ */
 PROCEDURE Valida_Opcao:

     RUN Valida_Opcao IN hBO
                      ( INPUT aux_cdcooper,
                        INPUT aux_cdagenci,
                        INPUT aux_nrdcaixa,
                        INPUT aux_cdoperad,
                        INPUT aux_nmdatela,
                        INPUT aux_idorigem,
                        INPUT aux_dtmvtolt,
                        INPUT aux_cddopcao,
                        INPUT aux_nrdconta,
                        INPUT aux_tpextrat,
                        INPUT aux_dtrefere,
                        INPUT aux_dtreffim,
                        INPUT aux_flgtarif,
                        INPUT aux_nranoref,
                        INPUT aux_inselext,
                        INPUT aux_nrctremp,
                        INPUT aux_nraplica,
                        INPUT aux_flgemiss,
                        INPUT aux_inrelext,
                        INPUT aux_tpmodelo,
                        INPUT TABLE tt-impres,
                       OUTPUT aux_nmdcampo,
                       OUTPUT aux_dtrefere,
                       OUTPUT aux_dtreffim,
                       OUTPUT aux_dsextrat,
                       OUTPUT aux_msgretor,
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
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT STRING(aux_nmdcampo)).
            RUN piXmlSave.

         END.
     ELSE
         DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "dtrefere",INPUT STRING(aux_dtrefere,"99/99/9999")).
            RUN piXmlAtributo (INPUT "dtreffim",INPUT STRING(aux_dtreffim,"99/99/9999")).
            RUN piXmlAtributo (INPUT "dsextrat",INPUT STRING(aux_dsextrat)).
            RUN piXmlAtributo (INPUT "msgretor",INPUT STRING(aux_msgretor)).
            RUN piXmlSave.
         END.

 END PROCEDURE.

/* ------------------------------------------------------------------------ */
/*         GRAVA RELATÓRIOS PARA SEREM IMPRESSOS EM PROCESSO NOTURNO        */
/* ------------------------------------------------------------------------ */
 PROCEDURE Grava_Dados:

     RUN Grava_Dados IN hBO
                     ( INPUT aux_cdcooper,
                       INPUT aux_cdagenci,
                       INPUT aux_nrdcaixa,
                       INPUT aux_cdoperad,
                       INPUT aux_nmdatela,
                       INPUT aux_idorigem,
                       INPUT aux_dtmvtolt,
                       INPUT aux_cddopcao,
                       INPUT aux_nrdconta,
                       INPUT aux_tpextrat,
                       INPUT aux_dtrefere,
                       INPUT aux_dtreffim,
                       INPUT aux_flgtarif,
                       INPUT aux_nranoref,
                       INPUT aux_inselext,
                       INPUT aux_nrctremp,
                       INPUT aux_nraplica,
                       INPUT aux_flgemiss,
                       INPUT aux_inrelext,
                       INPUT YES,
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
            RUN piXmlSave.
         END.

 END PROCEDURE.



/* ------------------------------------------------------------------------ */
/*                       GERA A IMPRESSÃO DOS RELATÓRIOS                    */
/* ------------------------------------------------------------------------ */
 PROCEDURE Gera_Impressao:

     RUN Gera_Impressao IN hBO
                      ( INPUT aux_cdcooper,
                        INPUT aux_cdagenci,
                        INPUT aux_nrdcaixa,
                        INPUT aux_idorigem,
                        INPUT aux_nmdatela,
                        INPUT aux_dtmvtolt,
                        INPUT aux_dtmvtopr,
                        INPUT aux_cdprogra,
                        INPUT aux_inproces,
                        INPUT aux_cdoperad,
                        INPUT aux_dsiduser,
                        INPUT aux_flgrodar,
                        INPUT aux_nrdconta,
                        INPUT aux_idseqttl,
                        INPUT aux_tpextrat,
                        INPUT aux_dtrefere,
                        INPUT aux_dtreffim,
                        INPUT aux_flgtarif,
                        INPUT aux_inrelext,
                        INPUT aux_inselext, 
                        INPUT aux_nrctremp, 
                        INPUT aux_nraplica, 
                        INPUT aux_nranoref, 
                        INPUT YES,
                        INPUT aux_intpextr,
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
            RUN piXmlAtributo (INPUT "nmarqimp",INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
         END.

 END PROCEDURE.

/*---------------------------------------------------------------------------
*      Gera impressão do relatorio de Aplicacoes
*---------------------------------------------------------------------------*/
 PROCEDURE Gera_Impressao_Aplicacao:

      RUN Gera_Impressao_Aplicacao IN hBO
                       ( INPUT aux_cdcooper,
                         INPUT aux_cdagenci,
                         INPUT aux_nrdcaixa,
                         INPUT aux_cdoperad,
                         INPUT aux_nmdatela,
                         INPUT aux_cdprogra,
                         INPUT aux_idorigem,
                         INPUT aux_idseqttl,
                         INPUT aux_dsiduser,
                         INPUT aux_inproces,
                         INPUT aux_nrdconta,
                         INPUT aux_tpmodelo,
                         INPUT aux_dtvctini,
                         INPUT aux_tprelato,
                         INPUT aux_nraplica,
                         INPUT aux_dtmvtolt,
                         INPUT aux_dtvctfim,

                        OUTPUT aux_nmarqimp,
                        OUTPUT aux_nmarqpdf,
                        OUTPUT TABLE tt-demonstrativo,
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
             RUN piXmlAtributo (INPUT "nmarqimp",INPUT STRING(aux_nmarqimp)).
             RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
             RUN piXmlSave.
          END.

  END PROCEDURE.

