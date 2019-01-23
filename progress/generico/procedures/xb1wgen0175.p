/*.............................................................................

   Programa: xb1wgen0175.p
   Autor   : Andre Santos - SUPERO
   Data    : Setembro/2013                     Ultima atualizacao: 19/08/2016

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao referente a tela DEVOLU, 
               Devolucoes.

   Alteracoes: 19/08/2016 - Ajustes referentes a Melhoria 69 - Devolucao automatica 
                            de cheques (Lucas Ranghetti #484923)
   
               03/10/2018 - Procedure para receber nova opcao de exclusao na 
                            tela devolu.
                            Chamado SCTASK0029653 - Gabriel (Mouts).
							
               07/12/2018 - Melhoria no processo de devoluções de cheques.
                            Alcemir Mout's (INC0022559).
							
               23/01/2019 - Alteracao na rotina de alteracao de alinea e
                            melhoria na gravacao do log na verlog.
                            Chamado - PRB0040476 - Gabriel Marcos (Mouts).

............................................................................ */

DEF VAR aux_cdcooper LIKE crapcop.cdcooper                             NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci LIKE crapass.cdagenci                             NO-UNDO.
DEF VAR aux_cdlcremp LIKE crapepr.cdlcremp                             NO-UNDO.
DEF VAR aux_cddotipo AS CHAR FORMAT "X(1)"                             NO-UNDO.
DEF VAR aux_cddopcao AS CHAR FORMAT "X(1)"                             NO-UNDO.
DEF VAR aux_dtinicio AS DATE                                           NO-UNDO.
DEF VAR aux_dttermin AS DATE                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR aux_flgexist AS LOG                                            NO-UNDO.
DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.
DEF VAR aux_stsnrcal AS LOGICAL                                        NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdconta LIKE crapass.nrdconta                             NO-UNDO.
DEF VAR aux_valorvlb AS DECI                                           NO-UNDO.
DEF VAR aux_nrcalcul AS INTE                                           NO-UNDO.
DEF VAR ret_dsdctitg AS CHAR                                           NO-UNDO.
DEF VAR aux_flghrexe AS LOGICAL                                        NO-UNDO.
DEF VAR aux_nroposic AS INTE                                           NO-UNDO.
DEF VAR aux_cddevolu AS INTE                                           NO-UNDO.
DEF VAR aux_cdprogra AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_cddsenha AS CHAR                                           NO-UNDO.
DEF VAR aux_dsbccxlt AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdocmto AS INTE                                           NO-UNDO.
DEF VAR aux_nrdctitg AS CHAR                                           NO-UNDO.
DEF VAR aux_cdbanchq AS INTE                                           NO-UNDO.
DEF VAR aux_cdagechq AS INTE                                           NO-UNDO.
DEF VAR aux_cddsitua AS INTE                                           NO-UNDO.
DEF VAR aux_nrdrecid AS INTE                                           NO-UNDO.
DEF VAR aux_vllanmto AS DECI                                           NO-UNDO.
DEF VAR aux_flag     AS LOGICAL                                        NO-UNDO.
DEF VAR aux_banco    AS INTE                                           NO-UNDO.
DEF VAR aux_pedsenha AS LOGICAL                                        NO-UNDO.
DEF VAR aux_execucao AS LOGICAL                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_nrctachq AS DECI                                           NO-UNDO.
DEF VAR aux_cdalinea AS INTE                                           NO-UNDO.
DEF VAR aux_cdbccxlt AS INTE                                           NO-UNDO.
DEF VAR aux_inchqdev AS INTE                                           NO-UNDO.
DEF VAR aux_cdhistor AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_flgpagin AS LOG                                            NO-UNDO.
DEF VAR aux_cdbandep AS INTE                                           NO-UNDO.
DEF VAR aux_cdagedep AS INTE                                           NO-UNDO.
DEF VAR aux_nrctadep AS DECI                                           NO-UNDO.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen0175tt.i }
                                       
/*................................ PROCEDURES ................................*/

/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/

PROCEDURE valores_entrada:
    
    DEFINE VARIABLE aux_rowid AS ROWID       NO-UNDO.
    
    FOR EACH tt-param:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "dtmvtopr" THEN aux_dtmvtopr = DATE(tt-param.valorCampo).
            WHEN "stsnrcal" THEN aux_stsnrcal = LOGICAL(tt-param.valorCampo).
            WHEN "cdlcremp" THEN aux_cdlcremp = INTE(tt-param.valorCampo).
            WHEN "cddotipo" THEN aux_cddotipo = STRING(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = STRING(tt-param.valorCampo).
            WHEN "dtinicio" THEN aux_dtinicio = DATE(tt-param.valorCampo).
            WHEN "dttermin" THEN aux_dttermin = DATE(tt-param.valorCampo).
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "flgpagin" THEN aux_flgpagin = LOGICAL(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "nrcalcul" THEN aux_nrcalcul = INTE(tt-param.valorCampo).
            WHEN "nroposic" THEN aux_nroposic = INTE(tt-param.valorCampo).
            WHEN "cddevolu" THEN aux_cddevolu = INTE(tt-param.valorCampo).
            WHEN "dtmvtoan" THEN aux_dtmvtoan = DATE(tt-param.valorCampo).
            WHEN "cdprogra" THEN aux_cdprogra = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "cddsenha" THEN aux_cddsenha = tt-param.valorCampo.
            WHEN "dsbccxlt" THEN aux_dsbccxlt = tt-param.valorCampo.
            WHEN "nrdocmto" THEN aux_nrdocmto = INTE(tt-param.valorCampo).
            WHEN "nrdctitg" THEN aux_nrdctitg = tt-param.valorCampo.
            WHEN "cdbanchq" THEN aux_cdbanchq = INTE(tt-param.valorCampo).
            WHEN "cdagechq" THEN aux_cdagechq = INTE(tt-param.valorCampo).
            WHEN "cddsitua" THEN aux_cddsitua = INTE(tt-param.valorCampo).
            WHEN "nrdrecid" THEN aux_nrdrecid = INTE(tt-param.valorCampo).
            WHEN "flag"     THEN aux_flag     = LOGICAL(tt-param.valorCampo).
            WHEN "nrctachq" THEN aux_nrctachq = DECI(tt-param.valorCampo).
            WHEN "cdalinea" THEN aux_cdalinea = INTE(tt-param.valorCampo).
            WHEN "banco"    THEN aux_banco    = INTE(tt-param.valorCampo).
            WHEN "vllanmto" THEN aux_vllanmto = DECI(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "cdbandep" THEN aux_cdbandep = INTE(tt-param.valorCampo).
            WHEN "cdagedep" THEN aux_cdagedep = INTE(tt-param.valorCampo).
            WHEN "nrctadep" THEN aux_nrctadep = DECI(tt-param.valorCampo).
			
	    END CASE.
    END. /** Fim do FOR EACH tt-param **/

    FOR EACH tt-param-i 
        BREAK BY tt-param-i.nomeTabela
              BY tt-param-i.sqControle:

        CASE tt-param-i.nomeTabela:

            WHEN "Desmarcar" THEN DO:
            
               IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:
                       CREATE tt-desmarcar.
                       ASSIGN aux_rowid = ROWID(tt-desmarcar).
                    END.
                    
               FIND tt-desmarcar WHERE ROWID(tt-desmarcar) = aux_rowid NO-ERROR.
                  
               CASE tt-param-i.nomeCampo:
                    WHEN "banco" THEN
                        tt-desmarcar.cdbanchq = INT(tt-param-i.valorCampo).
                    WHEN "cdagechq" THEN
                        tt-desmarcar.cdagechq = INT(tt-param-i.valorCampo).
                    WHEN "nrctachq" THEN
                        tt-desmarcar.nrctachq = DEC(tt-param-i.valorCampo).
                    WHEN "nrcheque" THEN
                        tt-desmarcar.nrcheque = DEC(tt-param-i.valorCampo).
                    WHEN "nrdconta" THEN
                         tt-desmarcar.nrdconta = DEC(tt-param-i.valorCampo).
                    WHEN "vllanmto" THEN
                        tt-desmarcar.vllanmto = DEC(tt-param-i.valorCampo).
                    WHEN "cdalinea" THEN
                        tt-desmarcar.cdalinea = INT(tt-param-i.valorCampo).
                    WHEN "nrdctitg" THEN
                        tt-desmarcar.nrdctitg = DEC(tt-param-i.valorCampo).
                    WHEN "nrdrecid" THEN
                        STRING(tt-desmarcar.nrdrecid) = STRING(tt-param-i.valorCampo).						
					WHEN "cdbandep" THEN
                        tt-desmarcar.cdbandep = INT(tt-param-i.valorCampo).
                    WHEN "cdagedep" THEN
                        tt-desmarcar.cdagedep = INT(tt-param-i.valorCampo).
                    WHEN "nrctadep" THEN
					    tt-desmarcar.nrctadep = DEC(tt-param-i.valorCampo).
                    WHEN "flag" THEN
                        tt-desmarcar.flag = LOGICAL(tt-param-i.valorCampo). 
               END CASE.
            END.            
        END CASE.
    END.

END PROCEDURE.


PROCEDURE busca-devolucoes-cheque:

    /* Busca Todas as Devolucoes */
    RUN busca-devolucoes-cheque IN hBO
                              ( INPUT aux_cdcooper,
                                INPUT aux_dtmvtolt,
                                INPUT aux_dtmvtoan, 
                                INPUT TRUE,
                                INPUT aux_nrdconta,
                                INPUT aux_cdagenci,
                                INPUT aux_flgpagin,
                                INPUT aux_nriniseq,
                                INPUT aux_nrregist,
                                OUTPUT aux_qtregist,
                                OUTPUT aux_nmprimtl,
                                OUTPUT ret_dsdctitg,
                                OUTPUT TABLE tt-lancto,
                                OUTPUT TABLE tt-devolu,                                
                                OUTPUT TABLE tt-erro).   
    
    IF  RETURN-VALUE <> "OK" THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
        IF  NOT AVAILABLE tt-erro THEN DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
        END.

        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
    END.
    ELSE DO:
        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-devolu:HANDLE,
                         INPUT "Devolucoes").
        RUN piXmlExport (INPUT TEMP-TABLE tt-lancto:HANDLE,
                         INPUT "Lancamento").        
        RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
        RUN piXmlAtributo (INPUT "nmprimtl",INPUT STRING(aux_nmprimtl)).
        RUN piXmlSave.
    END.
    
END PROCEDURE.

PROCEDURE busca-telefone-email:

      RUN busca-telefone-email IN hBO
                              (INPUT aux_cdcooper
                              ,INPUT aux_nrdconta
                              ,OUTPUT TABLE tt-telefones
                              ,OUTPUT TABLE tt-emails).
                              
      IF  RETURN-VALUE <> "OK" THEN DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.
          
          IF  NOT AVAILABLE tt-erro THEN DO:
              CREATE tt-erro.
              ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
          END.

          RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
      END.
      ELSE DO:
          RUN piXmlNew.          
          RUN piXmlExport (INPUT TEMP-TABLE tt-telefones:HANDLE,
                           INPUT "Telefones").
          RUN piXmlExport (INPUT TEMP-TABLE tt-emails:HANDLE,
                           INPUT "Emails").          
          RUN piXmlSave.
      END.

END PROCEDURE.

PROCEDURE marcar_cheque_devolu:

    /* Marca o cheque para devolver */
    RUN marcar_cheque_devolu IN hBO
                            (INPUT aux_cdcooper,
                             INPUT aux_dtmvtolt,
                             INPUT aux_dsbccxlt,
                             INPUT aux_vllanmto,
                             OUTPUT aux_pedsenha,
                             OUTPUT aux_execucao,
                             OUTPUT TABLE tt-erro).

    IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE tt-erro THEN DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
        END.
        
        ASSIGN aux_dscritic = tt-erro.dscritic.

        RUN piXmlNew.
        RUN piXmlAtributo (INPUT "pedsenha",INPUT STRING(aux_pedsenha)).
        RUN piXmlAtributo (INPUT "dscritic",INPUT STRING(aux_dscritic)).
        RUN piXmlAtributo (INPUT "execucao",INPUT STRING(aux_execucao)).
        RUN piXmlSave.
        
    END.
    ELSE DO:

        ASSIGN aux_dscritic = "".

        RUN piXmlNew.
        RUN piXmlAtributo (INPUT "pedsenha",INPUT STRING(aux_pedsenha)).
        RUN piXmlAtributo (INPUT "dscritic",INPUT STRING(aux_dscritic)).
        RUN piXmlAtributo (INPUT "execucao",INPUT STRING(aux_execucao)).
        RUN piXmlSave.
    END.

END PROCEDURE.


PROCEDURE verifica-folha-cheque:

    /* Procedimento inicial para devolução de cheques */
    RUN verifica-folha-cheque IN hBO
                             (INPUT aux_cdcooper,
                              INPUT aux_dtmvtolt,
                              INPUT aux_nrctachq,
                              INPUT aux_vllanmto,
                              INPUT aux_dsbccxlt,
                              INPUT aux_nrdocmto,
                              INPUT aux_nrdctitg,
                              INPUT aux_cdbanchq,
                              INPUT aux_cdagechq,
                              INPUT aux_cddsitua,
                              INPUT aux_nrdrecid,
							  INPUT aux_cdbandep,
							  INPUT aux_cdagedep,
							  INPUT aux_nrctadep,
                              INPUT aux_flag,
                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE tt-erro THEN DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
        END.

        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
    END.

END PROCEDURE.


PROCEDURE verifica_alinea:

    /* Segunda etapa do procedimento de devolucao de cheques */
    RUN verifica_alinea IN hBO
                       (INPUT aux_cdcooper,
                        INPUT aux_dtmvtolt,
                        INPUT aux_cdbanchq,
                        INPUT aux_cdagechq,
                        INPUT aux_nrctachq,
                        INPUT aux_nrdocmto,
                        INPUT aux_cdalinea,
                        OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN DO:
    
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE tt-erro THEN DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
        END.
        
        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
        
    END.
    ELSE
    DO:
        RUN piXmlNew.
        RUN piXmlSave.
    END.  

END PROCEDURE.


PROCEDURE geracao-devolu:

    /* Terceira etapa do procedimento de devolucao de cheques */
    RUN geracao-devolu IN hBO
                   (INPUT aux_cdcooper,
                    INPUT aux_dtmvtolt,
                    INPUT aux_banco,
                    INPUT aux_nrdrecid,
                    INPUT aux_inchqdev,
                    INPUT aux_nrdctitg,
                    INPUT aux_vllanmto,
                    INPUT aux_cdalinea,
                    INPUT aux_cdhistor,
                    INPUT aux_cdoperad,
                    INPUT aux_cdagechq,
                    INPUT aux_nrctachq,
                    INPUT aux_nrdconta,
                    INPUT aux_nrdocmto,
                    INPUT aux_nmdatela,
                    INPUT aux_flag,
					INPUT aux_cdbandep,
					INPUT aux_cdagedep,
					INPUT aux_nrctadep,
                    INPUT TABLE tt-desmarcar,
                    OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE tt-erro THEN DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
        END.

        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
    END.

END PROCEDURE.


PROCEDURE gera_log:

    /* Terceira etapa do procedimento de devolucao de cheques */
    RUN gera_log IN hBO
                (INPUT aux_cdcooper,
                 INPUT aux_dtmvtolt,
                 INPUT aux_cdoperad,
                 INPUT aux_flag,
                 INPUT aux_vllanmto,
                 INPUT aux_nrdocmto,
                 INPUT aux_nrctachq,
                 INPUT aux_cdbanchq,
                 INPUT aux_cdalinea,
                 INPUT aux_nmdatela,
                 INPUT TABLE tt-desmarcar,
                 OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE tt-erro THEN DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
        END.

        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
    END.

END PROCEDURE.


PROCEDURE verifica-solicitacao-processo:

    RUN verifica-solicitacao-processo IN hBO
                                     (INPUT aux_cdcooper,
                                      INPUT aux_dtmvtolt,
                                      INPUT aux_cddevolu,
                                      OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE tt-erro THEN DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
        END.

        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
    END.
    
END PROCEDURE.


PROCEDURE grava_processo_solicitacao:

    RUN grava_processo_solicitacao IN hBO
                                  (INPUT aux_cdcooper,
                                   INPUT aux_dtmvtolt,
                                   INPUT aux_cddsenha,
                                   INPUT aux_cddevolu,
                                   OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE tt-erro THEN DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
        END.

        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
    END.

END PROCEDURE.


PROCEDURE executa-processo-devolu:
    
    RUN executa-processo-devolu IN hBO
                               (INPUT aux_cdcooper,
                                INPUT aux_inproces,
                                INPUT aux_dtmvtolt,
                                INPUT aux_dtmvtoan,
                                INPUT aux_cdprogra,
                                INPUT aux_nmdatela,
                                INPUT aux_cdoperad,
                                INPUT aux_cddevolu, 
                                OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE tt-erro THEN DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
        END.

        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
    END.
    
END PROCEDURE.

PROCEDURE altera-alinea:

    RUN altera-alinea IN hBO(INPUT aux_cdcooper,                        
                             INPUT aux_cdbanchq,
                             INPUT aux_cdagechq,
                             INPUT aux_nrctachq,
                             INPUT aux_nrdocmto,
                             INPUT aux_cdalinea,
                             INPUT aux_cdoperad, 
                             INPUT aux_cdbandep,
							 INPUT aux_cdagedep,
							 INPUT aux_nrctadep,
							 INPUT aux_vllanmto,		
                             INPUT aux_dtmvtolt,
                             INPUT aux_nmdatela,						 
                             OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE tt-erro THEN DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
        END.

        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
    END.
    ELSE
    DO:
        RUN piXmlNew.
        RUN piXmlSave.
    END.  

END PROCEDURE.

PROCEDURE excluir-cheque-devolu:

    RUN excluir-cheque-devolu IN hBO(INPUT aux_cdcooper,                        
                                     INPUT aux_cdbanchq,
                                     INPUT aux_cdagechq,
                                     INPUT aux_nrdconta,
                                     INPUT aux_nrctachq,
                                     INPUT aux_nrdocmto,
                                     INPUT aux_cdoperad, 
								     INPUT aux_cdbandep,
									 INPUT aux_cdagedep,
									 INPUT aux_nrctadep,
									 INPUT aux_vllanmto,
                                     OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE tt-erro THEN DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Operacao nao efetuada.".
        END.

        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
    END.
    ELSE
    DO:
        RUN piXmlNew.
        RUN piXmlSave.
    END.  

END PROCEDURE.