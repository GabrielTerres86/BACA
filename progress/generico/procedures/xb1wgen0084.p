/* ........................................................................... 

   Programa: xb1wgen0084.p
   Autor   : Gabriel
   Data    : Maio/2011                           Ultima atualizacao: 28/10/2015
           
   Dados referentes ao programa:
   
   Objetivo  : BO de comunicacao XML VS BO da Rotina "Novo Produto de Crédito 
               "com taxa Pré-fixada"
   
   Alteracoes: 17/04/2012 - Retirada procedure imprime extrato (Tiago). 
   
               08/09/2014 - Incluido parametro valor da tarifa na procedure 
                            "grava_efetivacao_proposta". (James)
                            
               03/11/2014 - Incluso nova procedure transf_contrato_prejuizo,
                            Projeto transf. prejuizo (Daniel/Oscar) 

              18/11/2014 - Inclusao do parametro nrcpfope. (Jaison)
              
              04/02/2015 - Incluso nova procedure desfaz_transferencia_prejuizo,
                            Projeto transf. prejuizo (Daniel/Oscar)
                            
              28/10/2015 - Desenvolvimento do projeto 126. (James)
                            
........................................................................... */
DEF VAR aux_cdcooper AS INTE                                          NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                          NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                          NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                          NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                          NO-UNDO.
DEF VAR aux_idorigem AS INTE                                          NO-UNDO. 
DEF VAR aux_nrdconta AS INTE                                          NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                          NO-UNDO.
DEF VAR aux_flgerlog AS LOGI                                          NO-UNDO.
DEF VAR aux_nrctremp AS INTE                                          NO-UNDO.
DEF VAR aux_cdlcremp AS INTE                                          NO-UNDO.
DEF VAR aux_vlemprst AS DECI                                          NO-UNDO.
DEF VAR aux_qtparepr AS INTE                                          NO-UNDO.
DEF VAR aux_dtlibera AS DATE                                          NO-UNDO.
DEF VAR aux_cdoperac AS CHAR                                          NO-UNDO.
DEF VAR aux_dtdpagto AS DATE                                          NO-UNDO.
DEF VAR aux_vloperac AS DECI                                          NO-UNDO.
DEF VAR aux_flgalcad AS logi                                          NO-UNDO.
DEF VAR aux_dtcalcul AS DATE                                          NO-UNDO.
DEF VAR aux_flgcondc AS LOGI                                          NO-UNDO.
DEF VAR aux_dtiniper AS DATE                                          NO-UNDO.
DEF VAR aux_dtfimper AS DATE                                          NO-UNDO.
DEF VAR aux_intpextr AS INTE                                          NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                          NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                          NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                          NO-UNDO.
DEF VAR aux_vltarifa AS DECI                                          NO-UNDO.
DEF VAR aux_vltaxiof AS DECI                                          NO-UNDO.
DEF VAR aux_vltariof AS DECI                                          NO-UNDO.
DEF VAR aux_nrcpfope AS DECI                                          NO-UNDO.
DEF VAR aux_dsjustificativa AS CHAR                                   NO-UNDO.
DEF VAR aux_idfiniof AS INTEGER                                       NO-UNDO.

DEF VAR aux_insitapv AS INTE                                          NO-UNDO.
DEF VAR aux_dsobscmt AS CHAR                                          NO-UNDO.
DEF VAR aux_cdbccxlt AS INTE                                          NO-UNDO.
DEF VAR aux_nrdolote AS INTE                                          NO-UNDO.
DEF VAR aux_cdprogra AS CHAR                                          NO-UNDO.
DEF VAR par_qtdiacar AS INTE                                          NO-UNDO.
DEF VAR par_vlajuepr AS DECI                                          NO-UNDO.
DEF VAR par_txdiaria AS DECI                                          NO-UNDO.
DEF VAR par_txmensal AS DECI                                          NO-UNDO.
DEF VAR par_vliofepr AS DECI                                          NO-UNDO.
DEF VAR par_vlrtarif AS DECI                                          NO-UNDO.
DEF VAR par_vllibera AS DECI                                          NO-UNDO.
DEF VAR aux_rowidavt AS ROWID                                         NO-UNDO.
DEF VAR par_mensagem AS CHAR                                          NO-UNDO.

{ sistema/generico/includes/var_internet.i  }
{ sistema/generico/includes/supermetodos.i  }
{ sistema/generico/includes/b1wgen0084tt.i  }
{ sistema/generico/includes/b1wgen0084att.i }
{ sistema/generico/includes/b1wgen0043tt.i  }

/*............................... PROCEDURES ...............................*/

PROCEDURE valores_entrada:

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:

            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "flgerlog" THEN aux_flgerlog = LOGICAL(tt-param.valorCampo).
            WHEN "nrctremp" THEN aux_nrctremp = INTE(tt-param.valorCampo).
            WHEN "cdlcremp" THEN aux_cdlcremp = INTE(tt-param.valorCampo).
            WHEN "vlemprst" THEN aux_vlemprst = DEC(tt-param.valorCampo).
            WHEN "qtparepr" THEN aux_qtparepr = INTE(tt-param.valorCampo).
            WHEN "dtlibera" THEN aux_dtlibera = DATE(tt-param.valorCampo).
            WHEN "dtdpagto" THEN aux_dtdpagto = DATE(tt-param.valorCampo).
            WHEN "insitapv" THEN aux_insitapv = INTE(tt-param.valorCampo).
            WHEN "dsobscmt" THEN aux_dsobscmt = tt-param.valorCampo.
            WHEN "cdoperac" THEN aux_cdoperac = tt-param.valorCampo.
            WHEN "vloperac" THEN aux_vloperac = dec(tt-param.valorCampo).
            WHEN "cdprogra" THEN aux_cdprogra = tt-param.valorCampo.
            WHEN "nrdolote" THEN aux_nrdolote = INTE(tt-param.valorCampo).
            WHEN "cdbccxlt" THEN aux_cdbccxlt = INTE(tt-param.valorCampo).
            WHEN "dtcalcul" THEN aux_dtcalcul = DATE(tt-param.valorCampo).
            WHEN "flgcondc" THEN aux_flgcondc = LOGICAL(tt-param.valorCampo).
            WHEN "dtiniper" THEN aux_dtiniper = DATE(tt-param.valorCampo).
            WHEN "dtfimper" THEN aux_dtfimper = DATE(tt-param.valorCampo).
            WHEN "intpextr" THEN aux_intpextr = INTE(tt-param.valorCampo).
            WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.
            WHEN "nmarqimp" THEN aux_nmarqimp = tt-param.valorCampo.
            WHEN "nmarqpdf" THEN aux_nmarqpdf = tt-param.valorCampo.
            WHEN "vltarifa" THEN aux_vltarifa = DEC(tt-param.valorCampo).
            WHEN "vltaxiof" THEN aux_vltaxiof = DEC(tt-param.valorCampo).
            WHEN "vltariof" THEN aux_vltariof = DEC(tt-param.valorCampo).
            WHEN "nrcpfope" THEN aux_nrcpfope = DEC(tt-param.valorCampo).
            WHEN "idfiniof" THEN aux_idfiniof = INTE(tt-param.valorCampo).
            WHEN "dsjustificativa" THEN aux_dsjustificativa = tt-param.valorCampo.

       END CASE.

    END. /** Fim do FOR EACH tt-param **/

    FOR EACH tt-param-i 
        BREAK BY tt-param-i.nomeTabela
              BY tt-param-i.sqControle:

        CASE tt-param-i.nomeTabela:

            WHEN "Pagamentos" THEN DO:

                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:
                       CREATE tt-pagamentos-parcelas.
                       ASSIGN aux_rowidavt = ROWID(tt-pagamentos-parcelas).
                    END.

                FIND tt-pagamentos-parcelas WHERE 
                     ROWID(tt-pagamentos-parcelas) = aux_rowidavt
                     NO-ERROR.

                CASE tt-param-i.nomeCampo:

                    WHEN "cdcooper" THEN
                        tt-pagamentos-parcelas.cdcooper = 
                            INTE(tt-param-i.valorCampo).

                    WHEN "nrdconta" THEN
                        tt-pagamentos-parcelas.nrdconta = 
                            INTE(tt-param-i.valorCampo).

                    WHEN "nrctremp" THEN
                        tt-pagamentos-parcelas.nrctremp = 
                            INTE(tt-param-i.valorCampo).

                    WHEN "nrparepr" THEN
                        tt-pagamentos-parcelas.nrparepr = 
                            INTE(tt-param-i.valorCampo).

                    WHEN "vlparepr" THEN
                        tt-pagamentos-parcelas.vlparepr = 
                            DECI(tt-param-i.valorCampo).

                    WHEN "vljinpar" THEN
                        tt-pagamentos-parcelas.vljinpar = 
                            DECI(tt-param-i.valorCampo).

                    WHEN "vlmtapar" THEN
                        tt-pagamentos-parcelas.vlmtapar = 
                            DECI(tt-param-i.valorCampo).

                    WHEN "vlmrapar" THEN
                        tt-pagamentos-parcelas.vlmrapar = 
                            DECI(tt-param-i.valorCampo).
			        WHEN "vliofcpl" THEN
                        tt-pagamentos-parcelas.vliofcpl = 
                            DECI(tt-param-i.valorCampo).
                    WHEN "vlmtzepr" THEN
                        tt-pagamentos-parcelas.vlmtzepr = 
                            DECI(tt-param-i.valorCampo).

                    WHEN "dtvencto" THEN
                        tt-pagamentos-parcelas.dtvencto = 
                            DATE(tt-param-i.valorCampo).

                    WHEN "dtultpag" THEN
                        tt-pagamentos-parcelas.dtultpag = 
                            DATE(tt-param-i.valorCampo).

                    WHEN "vlpagpar" THEN
                        tt-pagamentos-parcelas.vlpagpar = 
                            DECI(tt-param-i.valorCampo).

                    WHEN "vlpagmta" THEN
                        tt-pagamentos-parcelas.vlpagmta = 
                            DECI(tt-param-i.valorCampo).

                    WHEN "vlpagmra" THEN
                        tt-pagamentos-parcelas.vlpagmra = 
                            DECI(tt-param-i.valorCampo).

                    WHEN "indpagto" THEN
                        tt-pagamentos-parcelas.indpagto = 
                            INTE(tt-param-i.valorCampo).

                    WHEN "txjuremp" THEN
                        tt-pagamentos-parcelas.txjuremp = 
                            DECI(tt-param-i.valorCampo).

                    WHEN "vlatupar" THEN
                        tt-pagamentos-parcelas.vlatupar = 
                            DECI(tt-param-i.valorCampo).

                    WHEN "vldespar" THEN
                        tt-pagamentos-parcelas.vldespar = 
                            DECI(tt-param-i.valorCampo).

                END CASE.   /*  CASE tt-param-i.nomeCampo   */

            END.    /* WHEN "Pagamentos"  */

        END CASE. /* CASE tt-param-i.nomeTabela */

    END.

END PROCEDURE. /* valores entrada */


/*****************************************************************************/
/**      Procedure para Busca as parcelas do empréstimo                  **/
/*****************************************************************************/
PROCEDURE busca_parcelas_proposta:

    RUN busca_parcelas_proposta IN hBo (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nmdatela,
                                        INPUT aux_idorigem,
                                        INPUT aux_nrdconta,
                                        INPUT aux_idseqttl,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_flgerlog,
                                        INPUT aux_nrctremp,
                                        INPUT aux_cdlcremp,
                                        INPUT aux_vlemprst,
                                        INPUT aux_qtparepr,
                                        INPUT aux_dtlibera,
                                        INPUT aux_dtdpagto,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-parcelas-epr).

    IF   RETURN-VALUE <> "OK"  THEN
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
             RUN piXmlExport (INPUT TEMP-TABLE tt-parcelas-epr:HANDLE,
                              INPUT "Parcelas").
             RUN piXmlSave.   
         END.

END PROCEDURE. /* busca parcelas proposta */


PROCEDURE busca_dados_efetivacao_proposta:
    
    RUN busca_dados_efetivacao_proposta IN hBo ( INPUT aux_cdcooper,
                                                 INPUT aux_cdagenci,
                                                 INPUT aux_nrdcaixa,
                                                 INPUT aux_cdoperad,
                                                 INPUT aux_nmdatela,
                                                 INPUT aux_idorigem,
                                                 INPUT aux_nrdconta,
                                                 INPUT aux_idseqttl,
                                                 INPUT aux_dtmvtolt,
                                                 INPUT aux_flgerlog,
                                                 INPUT aux_dtmvtopr,
                                                 INPUT aux_inproces,
                                                 INPUT aux_nrctremp,
                                                 INPUT aux_cdprogra,
                                                 OUTPUT TABLE tt-erro,
                                                 OUTPUT TABLE tt-msg-confirma,
                                                 OUTPUT TABLE tt-efetiv-epr,
                                                 OUTPUT TABLE tt-msg-aval,
                                                 OUTPUT TABLE tt-empr-aval-1,
                                                 OUTPUT TABLE tt-empr-aval-2). 
                               

    IF   RETURN-VALUE <> "OK"  THEN
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
             RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                              INPUT "Mensagens").
             RUN piXmlExport (INPUT TEMP-TABLE tt-efetiv-epr:HANDLE,
                              INPUT "ParcelasEfetiv").
             RUN piXmlExport (INPUT TEMP-TABLE tt-msg-aval:HANDLE,
                              INPUT "MensagensAvalistas").
             RUN piXmlExport (INPUT TEMP-TABLE tt-empr-aval-1:HANDLE,
                              INPUT "EmprestimosAvalista1").
             RUN piXmlExport (INPUT TEMP-TABLE tt-empr-aval-2:HANDLE,
                              INPUT "EmprestimosAvalista2").
             RUN piXmlSave.
         END.


END PROCEDURE. /*   busca dados efetivacao proposta */


PROCEDURE grava_efetivacao_proposta:
        
    RUN grava_efetivacao_proposta IN hBo (INPUT aux_cdcooper,
                                          INPUT aux_cdagenci,
                                          INPUT aux_nrdcaixa,
                                          INPUT aux_cdoperad,
                                          INPUT aux_nmdatela,
                                          INPUT aux_idorigem,
                                          INPUT aux_nrdconta,
                                          INPUT aux_idseqttl,
                                          INPUT aux_dtmvtolt,
                                          INPUT aux_flgerlog,
                                          INPUT aux_nrctremp,
                                          INPUT aux_insitapv,
                                          INPUT aux_dsobscmt,
                                          INPUT aux_dtdpagto,
                                          INPUT aux_cdbccxlt,
                                          INPUT aux_nrdolote,
                                          INPUT aux_dtmvtopr,
                                          INPUT aux_inproces,
                                          INPUT aux_nrcpfope,
                                          OUTPUT par_mensagem,
                                          OUTPUT TABLE tt-ratings,
                                          OUTPUT TABLE tt-erro).

    IF   RETURN-VALUE <> "OK"  THEN
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
             RUN piXmlAtributo (INPUT "mensagem", INPUT par_mensagem).
             RUN piXmlExport (INPUT TEMP-TABLE tt-ratings:HANDLE,
                              INPUT "Rating_Cooperado").
             RUN piXmlSave.   
         END.


END PROCEDURE. /* grava efetivacao proposta */
 

/*****************************************************************************/
/**      Procedure para calcular as parcelas do empréstimo                  **/
/*****************************************************************************/
PROCEDURE calcula_emprestimo:

    RUN calcula_emprestimo IN hBo (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nmdatela,
                                   INPUT aux_idorigem,
                                   INPUT aux_nrdconta,
                                   INPUT aux_idseqttl,
                                   INPUT aux_cdlcremp,
                                   INPUT aux_vlemprst,
                                   INPUT aux_qtparepr,
                                   INPUT aux_dtmvtolt,
                                   INPUT aux_dtdpagto,
                                   INPUT TRUE,
                                   OUTPUT par_qtdiacar,
                                   OUTPUT par_vlajuepr,
                                   OUTPUT par_txdiaria,
                                   OUTPUT par_txmensal,
                                   OUTPUT par_vliofepr,
                                   OUTPUT par_vlrtarif,
                                   OUTPUT par_vllibera,
                                   OUTPUT TABLE tt-parcelas-epr,
                                   OUTPUT TABLE tt-erro).

    IF   RETURN-VALUE <> "OK"  THEN
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
             RUN piXmlAtributo (INPUT "qtdiacar", INPUT par_qtdiacar).
             RUN piXmlAtributo (INPUT "vlajuepr", INPUT par_vlajuepr).
             RUN piXmlAtributo (INPUT "txdiaria", INPUT par_txdiaria).
             RUN piXmlAtributo (INPUT "txmensal", INPUT par_txmensal).
             RUN piXmlAtributo (INPUT "vliofepr", INPUT par_vliofepr).
             RUN piXmlAtributo (INPUT "vlrtarif", INPUT par_vlrtarif).
             RUN piXmlAtributo (INPUT "vllibera", INPUT par_vllibera).
             RUN piXmlExport (INPUT TEMP-TABLE tt-parcelas-epr:HANDLE,
                              INPUT "Parcelas").                                   
             RUN piXmlSave.   
         END.

END PROCEDURE. /* calcula emprestimo */
              
PROCEDURE busca_desfazer_efetivacao_emprestimo:

    RUN busca_desfazer_efetivacao_emprestimo IN hBo ( INPUT  aux_cdcooper,
                                                      INPUT  aux_cdagenci,
                                                      INPUT  aux_nrdcaixa,
                                                      INPUT  aux_cdoperad,
                                                      INPUT  aux_nmdatela,
                                                      INPUT  aux_idorigem,
                                                      INPUT  aux_nrdconta,
                                                      INPUT  aux_idseqttl,
                                                      INPUT  aux_dtmvtolt,
                                                      INPUT  aux_flgerlog,
                                                      INPUT  aux_nrctremp,
                                                      OUTPUT TABLE tt-erro).

    IF   RETURN-VALUE <> "OK"  THEN
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
             RUN piXmlSave.   
         END.


END PROCEDURE. /* busca desfazer efetivacao emprestimo */


PROCEDURE desfaz_efetivacao_emprestimo:

    RUN desfaz_efetivacao_emprestimo IN hBO ( INPUT  aux_cdcooper,
                                              INPUT  aux_cdagenci,
                                              INPUT  aux_nrdcaixa,
                                              INPUT  aux_cdoperad,
                                              INPUT  aux_nmdatela,
                                              INPUT  aux_idorigem,
                                              INPUT  aux_nrdconta,
                                              INPUT  aux_idseqttl,
                                              INPUT  aux_dtmvtolt,
                                              INPUT  aux_dtmvtopr,
                                              INPUT  aux_flgerlog,
                                              INPUT  aux_nrctremp,
                                              INPUT  aux_inproces,
                                              OUTPUT TABLE tt-erro).

    IF   RETURN-VALUE <> "OK"  THEN
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
             RUN piXmlSave.   
         END.
END PROCEDURE. /* desfaz efetivacao emprestimo */

PROCEDURE transf_contrato_prejuizo:

    RUN transf_contrato_prejuizo IN hBO ( INPUT  aux_cdcooper,
                                          INPUT  aux_cdagenci,
                                          INPUT  aux_nrdcaixa,
                                          INPUT  aux_cdoperad,
                                          INPUT  aux_nmdatela,
                                          INPUT  aux_idorigem,
                                          INPUT  aux_nrdconta,
                                          INPUT  aux_idseqttl,
                                          INPUT  aux_dtmvtolt,
                                          INPUT  aux_dtmvtopr,
                                          INPUT  aux_nrctremp,
                                          INPUT  aux_inproces,
                                          OUTPUT TABLE tt-erro).
  
    IF   RETURN-VALUE <> "OK"  THEN
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
             RUN piXmlSave.   
         END.
END PROCEDURE. /* transf_contrato_prejuizo */
  
PROCEDURE desfaz_transferencia_prejuizo:

    RUN desfaz_transferencia_prejuizo IN hBO ( INPUT  aux_cdcooper,
                                              INPUT  aux_cdagenci,
                                              INPUT  aux_nrdcaixa,
                                              INPUT  aux_cdoperad,
                                              INPUT  aux_nmdatela,
                                              INPUT  aux_idorigem,
                                              INPUT  aux_nrdconta,
                                              INPUT  aux_idseqttl,
                                              INPUT  aux_dtmvtolt,
                                              INPUT  aux_dtmvtopr,
                                              INPUT  aux_nrctremp,
                                              INPUT  aux_inproces,
                                              OUTPUT TABLE tt-erro).
  
    IF   RETURN-VALUE <> "OK"  THEN
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
             RUN piXmlSave.   
         END.
END PROCEDURE. /* desfaz_transferencia_prejuizo */

PROCEDURE efetua_estorno_pagamentos_pp:

    RUN efetua_estorno_pagamentos_pp IN hBO (INPUT aux_cdcooper,
                                             INPUT aux_cdagenci,
                                             INPUT aux_nrdcaixa,
                                             INPUT aux_cdoperad,
                                             INPUT aux_nmdatela,
                                             INPUT aux_idorigem,
                                             INPUT aux_nrdconta,
                                             INPUT aux_idseqttl,
                                             INPUT aux_dtmvtolt,
                                             INPUT aux_dtmvtopr,
                                             INPUT aux_nrctremp,
                                             INPUT aux_dsjustificativa,
                                             INPUT aux_inproces,
                                             OUTPUT TABLE tt-erro).
  
    IF RETURN-VALUE <> "OK" THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.
           IF NOT AVAILABLE tt-erro THEN
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

END.
/* .......................................................................... */ 
