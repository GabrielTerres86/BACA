/* ........................................................................... 

   Programa: xb1wgen0084a.p
   Autor   : Oliver
   Data    : Outubro/2011                    Ultima atualizacao: 09/06/2014
           
   Dados referentes ao programa:
   
   Objetivo  : BO de comunicacao XML VS BO
   
   Alteracoes: 21/02/2013 - Criada procedure para calcular o desconto da 
                            parcela (Gabriel).                       
                            
               11/06/2013 - 2a. fase do projeto Credito (Gabriel)       
               
               04/11/2013 - Ajuste para inclusao do parametro cdpactra
                            na procedure gera_pagamentos_parcelas
                            (Adriano).
                              
               09/06/2014 - Inserir procedure "busca_avalista_pagamento_parcela"
                            (James)
........................................................................... */

DEF VAR aux_inmotivo AS INTE                                          NO-UNDO.
DEF VAR aux_dsmotivo AS CHAR                                          NO-UNDO.
DEF VAR aux_opalcada AS CHAR                                          NO-UNDO.
DEF VAR aux_snalcada AS CHAR                                          NO-UNDO.
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
DEF VAR aux_nrparepr AS INTE                                          NO-UNDO.
DEF VAR aux_dtmvtini AS DATE                                          NO-UNDO.
DEF VAR aux_dtmvtfin AS DATE                                          NO-UNDO.
DEF VAR aux_rowidavt AS ROWID                                         NO-UNDO.
DEF VAR aux_totatual AS DECI                                          NO-UNDO.
DEF VAR aux_totpagto AS DECI                                          NO-UNDO.
DEF VAR aux_dspagpar AS CHAR                                          NO-UNDO.
DEF VAR aux_cdpactra AS INT                                           NO-UNDO.
DEF VAR aux_nrseqava AS INT                                           NO-UNDO.

DEF VAR aux_dtcobemp AS DATE                                          NO-UNDO.

{ sistema/generico/includes/var_internet.i  }
{ sistema/generico/includes/supermetodos.i  }
{ sistema/generico/includes/b1wgen0084tt.i  }
{ sistema/generico/includes/b1wgen0084att.i }

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
            WHEN "dtcobemp" THEN aux_dtcobemp = DATE(tt-param.valorCampo).
            WHEN "flgerlog" THEN aux_flgerlog = LOGICAL(tt-param.valorCampo).
            WHEN "nrctremp" THEN aux_nrctremp = INTE(tt-param.valorCampo).
            WHEN "nrparepr" THEN aux_nrparepr = INTE(tt-param.valorCampo).
            WHEN "dtmvtini" THEN aux_dtmvtini = DATE(tt-param.valorCampo).
            WHEN "dtmvtfin" THEN aux_dtmvtfin = DATE(tt-param.valorCampo).
            WHEN "inmotivo" THEN aux_inmotivo = INTE(tt-param.valorCampo).
            WHEN "dsmotivo" THEN aux_dsmotivo = tt-param.valorCampo.
            WHEN "opalcada" THEN aux_opalcada = tt-param.valorCampo.
            WHEN "snalcada" THEN aux_snalcada = tt-param.valorCampo.
            WHEN "dtmvtoan" THEN aux_dtmvtoan = DATE(tt-param.valorCampo).
            WHEN "totatual" THEN aux_totatual = DECI(tt-param.valorCampo).
            WHEN "totpagto" THEN aux_totpagto = DECI(tt-param.valorCampo).
            WHEN "vlpagpar" THEN aux_dspagpar = tt-param.valorCampo.
            WHEN "cdpactra" THEN aux_cdpactra = INT(tt-param.valorCampo).
            WHEN "nrseqava" THEN aux_nrseqava = INT(tt-param.valorCampo).
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

    FOR EACH tt-param-i 
        BREAK BY tt-param-i.nomeTabela
              BY tt-param-i.sqControle:

			  /*
        MESSAGE tt-param-i.nomeTabela
            VIEW-AS ALERT-BOX INFO BUTTONS OK.
			*/

        CASE tt-param-i.nomeTabela:
            WHEN "Lancamentos" THEN DO:
                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:
                        CREATE tt-lanctos-parcelas.
                        ASSIGN /*tt-lanctos-parcelas.nrseqdig =
                                                   tt-param-i.sqControle*/
                               aux_rowidavt = ROWID(tt-lanctos-parcelas).
                    END.

                FIND tt-lanctos-parcelas WHERE 
                     ROWID(tt-lanctos-parcelas) = aux_rowidavt NO-ERROR.

                CASE tt-param-i.nomeCampo:
                    WHEN "dtmvtolt" THEN
                        ASSIGN tt-lanctos-parcelas.dtmvtolt =
                            DATE(tt-param-i.valorCampo).
                    WHEN "cdagenci" THEN
                        ASSIGN tt-lanctos-parcelas.cdagenci =
                            INTE(tt-param-i.valorCampo).
                    WHEN "cdbccxlt" THEN
                        ASSIGN tt-lanctos-parcelas.cdbccxlt =
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrdolote" THEN
                        ASSIGN tt-lanctos-parcelas.nrdolote =
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrdconta" THEN
                        ASSIGN tt-lanctos-parcelas.nrdconta =
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrdocmto" THEN
                        ASSIGN tt-lanctos-parcelas.nrdocmto =
                            DEC(tt-param-i.valorCampo).
                    WHEN "cdhistor" THEN
                        ASSIGN tt-lanctos-parcelas.cdhistor =
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrseqdig" THEN
                        ASSIGN tt-lanctos-parcelas.nrseqdig =
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrctremp" THEN
                        ASSIGN tt-lanctos-parcelas.nrctremp =
                            INTE(tt-param-i.valorCampo).
                    WHEN "vllanmto" THEN
                        ASSIGN tt-lanctos-parcelas.vllanmto =
                            DEC(tt-param-i.valorCampo).
                    WHEN "dtpagemp" THEN
                        ASSIGN tt-lanctos-parcelas.dtpagemp =
                            DATE(tt-param-i.valorCampo).
                    WHEN "txjurepr" THEN
                        ASSIGN tt-lanctos-parcelas.txjurepr =
                            DEC(tt-param-i.valorCampo).
                    WHEN "vlpreemp" THEN
                        ASSIGN tt-lanctos-parcelas.vlpreemp =
                            DEC(tt-param-i.valorCampo).
                    WHEN "nrautdoc" THEN
                        ASSIGN tt-lanctos-parcelas.nrautdoc =
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrsequni" THEN
                        ASSIGN tt-lanctos-parcelas.nrsequni =
                            INTE(tt-param-i.valorCampo).
                    WHEN "cdcooper" THEN
                        ASSIGN tt-lanctos-parcelas.cdcooper =
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrparepr" THEN
                        ASSIGN tt-lanctos-parcelas.nrparepr =
                            INTE(tt-param-i.valorCampo).
                    WHEN "dshistor" THEN
                        ASSIGN tt-lanctos-parcelas.dshistor =
                            tt-param-i.valorCampo.
                    WHEN "flgalcad" THEN
                        ASSIGN tt-lanctos-parcelas.flgalcad =
                            LOGICAL(tt-param-i.valorCampo).
                END CASE. /* CASE tt-param-i.nomeCampo */
            END. /*  "Lancamentos"  */
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
                        ASSIGN tt-pagamentos-parcelas.cdcooper = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrdconta" THEN
                        ASSIGN tt-pagamentos-parcelas.nrdconta = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrctremp" THEN
                        ASSIGN tt-pagamentos-parcelas.nrctremp = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrparepr" THEN
                        ASSIGN tt-pagamentos-parcelas.nrparepr = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "vlparepr" THEN
                        ASSIGN tt-pagamentos-parcelas.vlparepr = 
                            DECI(tt-param-i.valorCampo).
                    WHEN "vlmtapar" THEN
                        ASSIGN tt-pagamentos-parcelas.vlmtapar = 
                            DECI(tt-param-i.valorCampo).
                    WHEN "vlmrapar" THEN
                        ASSIGN tt-pagamentos-parcelas.vlmrapar = 
                            DECI(tt-param-i.valorCampo).
                    WHEN "vlmtzepr" THEN
                        ASSIGN tt-pagamentos-parcelas.vlmtzepr = 
                            DECI(tt-param-i.valorCampo).
                    WHEN "dtvencto" THEN
                        ASSIGN tt-pagamentos-parcelas.dtvencto = 
                            DATE(tt-param-i.valorCampo).
                    WHEN "dtultpag" THEN
                        ASSIGN tt-pagamentos-parcelas.dtultpag = 
                            DATE(tt-param-i.valorCampo).
                    WHEN "vlpagpar" THEN
                        ASSIGN tt-pagamentos-parcelas.vlpagpar = 
                            DECI(tt-param-i.valorCampo).
                    WHEN "vlpagmta" THEN
                        ASSIGN tt-pagamentos-parcelas.vlpagmta = 
                            DECI(tt-param-i.valorCampo).
                    WHEN "vlpagmra" THEN
                        ASSIGN tt-pagamentos-parcelas.vlpagmra = 
                            DECI(tt-param-i.valorCampo).
                    WHEN "indpagto" THEN
                        ASSIGN tt-pagamentos-parcelas.indpagto = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "txjuremp" THEN
                        ASSIGN tt-pagamentos-parcelas.txjuremp = 
                            DECI(tt-param-i.valorCampo).
                    WHEN "vlatupar" THEN
                        ASSIGN tt-pagamentos-parcelas.vlatupar = 
                            DECI(tt-param-i.valorCampo).
                END CASE. /* CASE tt-param-i.nomeCampo */
            END. /* "Pagamentos"  */
        END CASE. /* CASE tt-param-i.nomeTabela: */
    END.

END PROCEDURE. /* valores_entrada */

PROCEDURE busca_lancamentos_parcelas:
    RUN busca_lancamentos_parcelas IN hBo (INPUT aux_cdcooper,                  
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
                                           INPUT aux_nrparepr,                  
                                           INPUT aux_dtmvtini,                  
                                           INPUT aux_dtmvtfin,                  
                                           OUTPUT TABLE tt-erro,
                                           OUTPUT TABLE tt-lanctos-parcelas).

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
             RUN piXmlExport (INPUT TEMP-TABLE tt-lanctos-parcelas:HANDLE,
                              INPUT "Lancamentos_parcelas").
             RUN piXmlSave.   
         END.

END PROCEDURE. /* busca lancamentos parcelas */

PROCEDURE gera_estorno_lancamentos:
    RUN gera_estorno_lancamentos IN hBo (INPUT aux_cdcooper,
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
                                         INPUT aux_inmotivo,
                                         INPUT aux_dsmotivo,
                                         INPUT aux_opalcada,
                                         INPUT aux_snalcada,
                                         INPUT TABLE tt-lanctos-parcelas,
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

END PROCEDURE. /* gera estorno lancamentos */

PROCEDURE gera_pagamentos_parcelas:

    RUN gera_pagamentos_parcelas IN hBo (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_nmdatela,
                                         INPUT aux_idorigem,
                                         INPUT aux_cdpactra,
                                         INPUT aux_nrdconta,
                                         INPUT aux_idseqttl,
                                         INPUT aux_dtmvtolt,
                                         INPUT aux_flgerlog,
                                         INPUT aux_nrctremp,
                                         INPUT aux_dtmvtoan,
                                         INPUT aux_totatual,
                                         INPUT aux_totpagto,
                                         INPUT aux_nrseqava,
                                         INPUT TABLE tt-pagamentos-parcelas,
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

END PROCEDURE. /* gera pagamentos parcelas */

PROCEDURE busca_pagamentos_parcelas:

    RUN busca_pagamentos_parcelas IN hBo (INPUT aux_cdcooper,
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
                                          INPUT aux_dtmvtoan,
                                          INPUT 0, /* Todas */
                                         OUTPUT TABLE tt-erro,
                                         OUTPUT TABLE tt-pagamentos-parcelas,
                                         OUTPUT TABLE tt-calculado).

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
             RUN piXmlExport (INPUT TEMP-TABLE tt-pagamentos-parcelas:HANDLE,
                              INPUT "Pagamentos").
             RUN piXmlExport (INPUT TEMP-TABLE tt-calculado:HANDLE,
                              INPUT "Calculado").
             RUN piXmlSave.   
         END.

END PROCEDURE. /* busca pagamentos parcelas */

PROCEDURE busca_pagamentos_parcelas_cobemp:

    aux_dtmvtoan = aux_dtcobemp.

    DO WHILE TRUE:

        aux_dtmvtoan = aux_dtmvtoan - 1.

        IF  LOOKUP(STRING(WEEKDAY(aux_dtmvtoan)),"1,7") <> 0   THEN
            NEXT.

        IF  CAN-FIND(crapfer WHERE
                     crapfer.cdcooper = aux_cdcooper       AND
                     crapfer.dtferiad = aux_dtmvtoan)  THEN
            NEXT.

        LEAVE.

    END.

    RUN busca_pagamentos_parcelas IN hBo (INPUT aux_cdcooper,
                                          INPUT aux_cdagenci,
                                          INPUT aux_nrdcaixa,
                                          INPUT aux_cdoperad,
                                          INPUT aux_nmdatela,
                                          INPUT aux_idorigem,
                                          INPUT aux_nrdconta,
                                          INPUT aux_idseqttl,
                                          INPUT aux_dtcobemp,
                                          INPUT aux_flgerlog,
                                          INPUT aux_nrctremp,
                                          INPUT aux_dtmvtoan,
                                          INPUT 0, /* Todas */
                                         OUTPUT TABLE tt-erro,
                                         OUTPUT TABLE tt-pagamentos-parcelas,
                                         OUTPUT TABLE tt-calculado).

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
             RUN piXmlExport (INPUT TEMP-TABLE tt-pagamentos-parcelas:HANDLE,
                              INPUT "Pagamentos").
             RUN piXmlExport (INPUT TEMP-TABLE tt-calculado:HANDLE,
                              INPUT "Calculado").
             RUN piXmlSave.   
         END.

END PROCEDURE. /* busca pagamentos parcelas */


PROCEDURE calcula_desconto_parcela:

    RUN calcula_desconto_parcela IN hBo (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_nmdatela,
                                         INPUT aux_idorigem,
                                         INPUT aux_nrdconta,
                                         INPUT aux_idseqttl,
                                         INPUT aux_nrctremp,
                                         INPUT aux_nrparepr,
                                         INPUT aux_dspagpar,
                                         INPUT aux_dtmvtolt,
                                         INPUT aux_dtmvtoan,
                                         INPUT aux_flgerlog,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-desconto).   

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
             RUN piXmlExport (INPUT TEMP-TABLE tt-desconto:HANDLE,
                              INPUT "Desconto").
             RUN piXmlSave.
         END.

END PROCEDURE.

PROCEDURE busca_avalista_pagamento_parcela:

    RUN busca_avalista_pagamento_parcela IN hBo (INPUT aux_cdcooper,
                                                 INPUT aux_cdagenci,
                                                 INPUT aux_nrdcaixa,
                                                 INPUT aux_cdoperad,
                                                 INPUT aux_nmdatela,
                                                 INPUT aux_idorigem,
                                                 INPUT aux_nrdconta,
                                                 INPUT aux_idseqttl,
                                                 INPUT aux_nrctremp,
                                                OUTPUT TABLE tt-erro,
                                                OUTPUT TABLE tt-dados-aval).

    IF RETURN-VALUE <> "OK"  THEN
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-dados-aval:HANDLE,
                            INPUT "Avalista").
           RUN piXmlSave.
       END.

END PROCEDURE.
/* ......................................................................... */
