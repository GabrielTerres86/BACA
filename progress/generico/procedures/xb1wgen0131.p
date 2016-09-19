/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0131.p
    Autor   : Gabriel Capoia
    Data    : Dezembro/2011                      Ultima atualizacao: 00/00/0000

    Objetivo  : BO de Comunicacao XML x BO - Tela PREVIS

    Alteracoes: 13/08/2012 - Ajuste referente ao projeto Fluxo Financeiro
                             (Adriano).
   
.............................................................................*/

/*...........................................................................*/
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_cdprogra AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdepart AS CHAR                                           NO-UNDO.
DEF VAR aux_nmrescop AS CHAR                                           NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_dtmvtolx AS DATE                                           NO-UNDO.
DEF VAR aux_cdagencx AS INTE                                           NO-UNDO.
DEF VAR aux_cdcoopex AS INTE                                           NO-UNDO.
DEF VAR aux_cdcoper2 AS INTE                                           NO-UNDO.
DEF VAR aux_vldepesp AS DECI                                           NO-UNDO.
DEF VAR aux_vldvlnum AS DECI                                           NO-UNDO.
DEF VAR aux_vldvlbcb AS DECI                                           NO-UNDO.
DEF VAR aux_vlremdoc AS DECI                                           NO-UNDO.
DEF VAR aux_qtremdoc AS INTE                                           NO-UNDO.
DEF VAR aux_nmcooper AS CHAR                                           NO-UNDO.
DEF VAR aux_nmcoper2 AS CHAR                                           NO-UNDO.
DEF VAR aux_tpdmovto AS CHAR                                           NO-UNDO.

DEF VAR aux_qtmoedas AS INTE EXTENT 6                                  NO-UNDO.
DEF VAR aux_qtmoeda1 AS INTE                                           NO-UNDO.
DEF VAR aux_qtmoeda2 AS INTE                                           NO-UNDO.
DEF VAR aux_qtmoeda3 AS INTE                                           NO-UNDO.
DEF VAR aux_qtmoeda4 AS INTE                                           NO-UNDO.
DEF VAR aux_qtmoeda5 AS INTE                                           NO-UNDO.
DEF VAR aux_qtmoeda6 AS INTE                                           NO-UNDO.

DEF VAR aux_qtdnotas AS INTE EXTENT 6                                  NO-UNDO.
DEF VAR aux_qtdnota1 AS INTE                                           NO-UNDO.
DEF VAR aux_qtdnota2 AS INTE                                           NO-UNDO.
DEF VAR aux_qtdnota3 AS INTE                                           NO-UNDO.
DEF VAR aux_qtdnota4 AS INTE                                           NO-UNDO.
DEF VAR aux_qtdnota5 AS INTE                                           NO-UNDO.
DEF VAR aux_qtdnota6 AS INTE                                           NO-UNDO.

DEF VAR aux_cdagefim AS INT                                            NO-UNDO.
DEF VAR aux_vlresgat AS DEC                                            NO-UNDO.
DEF VAR aux_vlresgan AS DEC                                            NO-UNDO.
DEF VAR aux_vlaplica AS DEC                                            NO-UNDO.
DEF VAR aux_vlaplian AS DEC                                            NO-UNDO.
DEF VAR aux_vlrepass AS DEC EXTENT 4                                   NO-UNDO.
DEF VAR aux_vlnumera AS DEC EXTENT 4                                   NO-UNDO.
DEF VAR aux_vlrfolha AS DEC EXTENT 4                                   NO-UNDO.
DEF VAR aux_vloutros AS DEC EXTENT 4                                   NO-UNDO.
DEF VAR aux_hrpermit AS LOG                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_permiace AS LOG                                            NO-UNDO.
DEF VAR aux_dstextab AS CHAR                                           NO-UNDO.
DEF VAR aux_msgaviso AS CHAR                                           NO-UNDO.
DEF VAR aux_nmoperad AS CHAR                                           NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0131tt.i } 
    

                    
/*............................... PROCEDURES ................................*/
PROCEDURE valores_entrada:

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:

            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "cdprogra" THEN aux_cdprogra = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "dsdepart" THEN aux_dsdepart = tt-param.valorCampo.
            WHEN "nmrescop" THEN aux_nmrescop = tt-param.valorCampo.
            WHEN "nmoperad" THEN aux_nmoperad = tt-param.valorCampo.
                
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "dtmvtolx" THEN aux_dtmvtolx = DATE(tt-param.valorCampo).
            WHEN "cdagencx" THEN aux_cdagencx = INTE(tt-param.valorCampo).
            WHEN "cdcoopex" THEN aux_cdcoopex = INTE(tt-param.valorCampo).
            WHEN "cdcoper2" THEN aux_cdcoper2 = INTE(tt-param.valorCampo).
            WHEN "qtremdoc" THEN aux_qtremdoc = INTE(tt-param.valorCampo).
            WHEN "vldepesp" THEN aux_vldepesp = DECI(tt-param.valorCampo).
            WHEN "vldvlnum" THEN aux_vldvlnum = DECI(tt-param.valorCampo).
            WHEN "vldvlbcb" THEN aux_vldvlbcb = DECI(tt-param.valorCampo).
            WHEN "vlremdoc" THEN aux_vlremdoc = DECI(tt-param.valorCampo).
            WHEN "tpdmovto" THEN aux_tpdmovto = tt-param.valorCampo.

            WHEN "qtmoeda1" THEN aux_qtmoedas[1] = INTE(tt-param.valorCampo).
            WHEN "qtmoeda2" THEN aux_qtmoedas[2] = INTE(tt-param.valorCampo).
            WHEN "qtmoeda3" THEN aux_qtmoedas[3] = INTE(tt-param.valorCampo).
            WHEN "qtmoeda4" THEN aux_qtmoedas[4] = INTE(tt-param.valorCampo).
            WHEN "qtmoeda5" THEN aux_qtmoedas[5] = INTE(tt-param.valorCampo).
            WHEN "qtmoeda6" THEN aux_qtmoedas[6] = INTE(tt-param.valorCampo).

            WHEN "qtdnota1" THEN aux_qtdnotas[1] = INTE(tt-param.valorCampo).
            WHEN "qtdnota2" THEN aux_qtdnotas[2] = INTE(tt-param.valorCampo).
            WHEN "qtdnota3" THEN aux_qtdnotas[3] = INTE(tt-param.valorCampo).
            WHEN "qtdnota4" THEN aux_qtdnotas[4] = INTE(tt-param.valorCampo).
            WHEN "qtdnota5" THEN aux_qtdnotas[5] = INTE(tt-param.valorCampo).
            WHEN "qtdnota6" THEN aux_qtdnotas[6] = INTE(tt-param.valorCampo).
                
            WHEN "cdagefim" THEN aux_cdagefim = INT(tt-param.valorCampo).
            WHEN "vlresgat" THEN aux_vlresgat = DEC(tt-param.valorCampo).
            WHEN "vlresgan" THEN aux_vlresgan = DEC(tt-param.valorCampo).
            WHEN "vlaplica" THEN aux_vlaplica = DEC(tt-param.valorCampo).
            WHEN "vlaplian" THEN aux_vlaplian = DEC(tt-param.valorCampo).

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

  
    FOR EACH tt-param-i BREAK BY tt-param-i.nomeTabela
                               BY tt-param-i.sqControle:

      CASE tt-param-i.nomeTabela:

            WHEN "Vlrepass" THEN DO:
                
                CASE tt-param-i.nomeCampo:

                    WHEN "cdbcoval85" THEN
                        ASSIGN aux_vlrepass[1] = 
                          DEC(tt-param-i.valorCampo).
                    WHEN "cdbcoval01" THEN
                        ASSIGN aux_vlrepass[2] = 
                          DEC(tt-param-i.valorCampo).
                    WHEN "cdbcoval756" THEN
                        ASSIGN aux_vlrepass[3] = 
                          DEC(tt-param-i.valorCampo).
                    WHEN "cdbcoval100" THEN
                        ASSIGN aux_vlrepass[4] = 
                          DEC(tt-param-i.valorCampo).
                                                          
                END CASE. /* CASE tt-param-i.nomeCampo */ 

            END. 

            WHEN "Vlnumera" THEN DO:
                
                CASE tt-param-i.nomeCampo:
                    
                    WHEN "cdbcoval85" THEN
                        ASSIGN aux_vlnumera[1] = 
                          DEC(tt-param-i.valorCampo).
                    WHEN "cdbcoval01" THEN
                        ASSIGN aux_vlnumera[2] = 
                          DEC(tt-param-i.valorCampo).
                    WHEN "cdbcoval756" THEN
                        ASSIGN aux_vlnumera[3] = 
                          DEC(tt-param-i.valorCampo).
                    WHEN "cdbcoval100" THEN
                        ASSIGN aux_vlnumera[4] = 
                          DEC(tt-param-i.valorCampo).
                                                          
                END CASE. /* CASE tt-param-i.nomeCampo */ 

            END. 

            WHEN "Vlrfolha" THEN DO:
                
                CASE tt-param-i.nomeCampo:
                    
                    WHEN "cdbcoval85" THEN
                        ASSIGN aux_vlrfolha[1] = 
                          DEC(tt-param-i.valorCampo).
                    WHEN "cdbcoval01" THEN
                        ASSIGN aux_vlrfolha[2] = 
                          DEC(tt-param-i.valorCampo).
                    WHEN "cdbcoval756" THEN
                        ASSIGN aux_vlrfolha[3] = 
                          DEC(tt-param-i.valorCampo).
                    WHEN "cdbcoval100" THEN
                        ASSIGN aux_vlrfolha[4] = 
                          DEC(tt-param-i.valorCampo).
                                                          
                END CASE. /* CASE tt-param-i.nomeCampo */ 

            END.

            WHEN "Vloutros" THEN DO:
                
                CASE tt-param-i.nomeCampo:
                    
                    WHEN "cdbcoval85" THEN
                        ASSIGN aux_vloutros[1] = 
                          DEC(tt-param-i.valorCampo).
                    WHEN "cdbcoval01" THEN
                        ASSIGN aux_vloutros[2] = 
                          DEC(tt-param-i.valorCampo).
                    WHEN "cdbcoval756" THEN
                        ASSIGN aux_vloutros[3] = 
                          DEC(tt-param-i.valorCampo).
                    WHEN "cdbcoval100" THEN
                        ASSIGN aux_vloutros[4] = 
                          DEC(tt-param-i.valorCampo).
                                                          
                END CASE. /* CASE tt-param-i.nomeCampo */ 

            END.

        END CASE. /* CASE tt-param-i.nomeTabela: */
                         
    END.


END PROCEDURE. /* valores_entrada */

/* ------------------------------------------------------------------------ */
/*                     EFETUA A BUSCA DOS DADOS PARA EXIBIÇÃO               */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:
    

    RUN Busca_Dados IN hBO ( INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_cdprogra,
                             INPUT aux_idorigem,
                             INPUT aux_dtmvtolt,
                             INPUT aux_dtmvtopr,
                             INPUT aux_nmdatela,
                             INPUT aux_dsdepart,
                             INPUT aux_cddopcao,
                             INPUT aux_dtmvtolx,
                             INPUT aux_cdagencx,
                             INPUT aux_cdcoopex,
                             INPUT aux_tpdmovto,
                             INPUT aux_dtmvtoan,
                             INPUT aux_cdagefim, 
                             OUTPUT TABLE tt-previs,
                             OUTPUT TABLE tt-fluxo,
                             OUTPUT TABLE tt-ffin-mvto-cent, 
                             OUTPUT TABLE tt-ffin-mvto-sing, 
                             OUTPUT TABLE tt-ffin-cons-cent, 
                             OUTPUT TABLE tt-ffin-cons-sing, 
                             OUTPUT TABLE tt-erro).

    IF RETURN-VALUE <> "OK" THEN
       DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.
          
          IF  NOT AVAILABLE tt-erro  THEN
              DO:
                 CREATE tt-erro.

                 ASSIGN tt-erro.dscritic = "Nao foi possivel concluir " + 
                                           "a validacao de dados.".

              END.

          RUN piXmlNew.
          RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
          RUN piXmlSave.

       END.
    ELSE
       DO:
          RUN piXmlNew.
          RUN piXmlExport (INPUT TEMP-TABLE tt-previs:HANDLE,
                           INPUT "Previsao").
          RUN piXmlExport (INPUT TEMP-TABLE tt-fluxo:HANDLE,
                           INPUT "Fluxo").
          RUN piXmlExport (INPUT TEMP-TABLE tt-ffin-mvto-cent:HANDLE,
                           INPUT "Movto-Cent").
          RUN piXmlExport (INPUT TEMP-TABLE tt-ffin-mvto-sing:HANDLE,
                           INPUT "Movto-Sing").                      
          RUN piXmlExport (INPUT TEMP-TABLE tt-ffin-cons-cent:HANDLE,
                           INPUT "ConsCent").
          RUN piXmlExport (INPUT TEMP-TABLE tt-ffin-cons-sing:HANDLE,
                           INPUT "Cons-Sing").
          IF TEMP-TABLE tt-erro:HAS-RECORDS THEN
             RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Msg").
             
             

          RUN piXmlSave.

       END.

END PROCEDURE. /* Busca_Dados */

/* ------------------------------------------------------------------------- */
/*                 REALIZA A GRAVACAO DOS DADOS DA TELA PREVIS               */
/* ------------------------------------------------------------------------- */
PROCEDURE Grava_Dados:

    RUN Grava_Dados IN hBO ( INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_cdprogra,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_dtmvtolt,
                             INPUT aux_dtmvtopr,
                             INPUT aux_cddopcao,
                             INPUT aux_cdagencx,
                             INPUT aux_vldepesp,
                             INPUT aux_vldvlnum,
                             INPUT aux_vldvlbcb,
                             INPUT aux_qtmoedas,
                             INPUT aux_qtdnotas,
                            OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                  CREATE tt-erro.
                  ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                            "validacao de dados.".
               END.

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
           RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlSave.
        END.


END PROCEDURE. /* Grava_Dados */

/* ------------------------------------------------------------------------- */
/*    RETORNA AS VARIAVEIS PARA PREENCHIMENTO DO COMBO DE COOPERATIVAS       */
/* ------------------------------------------------------------------------- */
PROCEDURE Busca_Cooperativas:

    RUN Busca_Cooperativas IN hBO ( INPUT aux_cdcooper,
                                   OUTPUT aux_nmcooper).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                  CREATE tt-erro.
                  ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                            "validacao de dados.".
               END.

           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
           RUN piXmlSave.
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "nmcooper", INPUT aux_nmcooper).
           RUN piXmlSave.
        END.


END PROCEDURE. /* Busca_Cooperativas */


/* ------------------------------------------------------------------------- */
/*    VALIDA O HORAIO PARA DIGITACAO DE CAMPOS                               */
/* ------------------------------------------------------------------------- */
PROCEDURE valida_horario:

    DYNAMIC-FUNCTION("valida_horario" IN hBO, 
                     INPUT aux_cdcooper,
                     INPUT TIME,
                     OUTPUT aux_hrpermit,
                     OUTPUT aux_dscritic).

   RUN piXmlNew.
   RUN piXmlAtributo (INPUT "hrpermit", INPUT aux_hrpermit).
   RUN piXmlAtributo (INPUT "dscritic", INPUT aux_dscritic).
   RUN piXmlSave.

END PROCEDURE.


/* ------------------------------------------------------------------------- */
/*    VERIFICA SE TELA ESTA SENDO USADA                                      */
/* ------------------------------------------------------------------------- */
PROCEDURE verifica_acesso:

   RUN verifica_acesso IN hBO ( INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nmoperad,
                                INPUT aux_cdcoopex,
                                OUTPUT aux_permiace,
                                OUTPUT aux_dstextab,
                                OUTPUT aux_msgaviso,
                                OUTPUT TABLE tt-erro).


   IF  RETURN-VALUE <> "OK" THEN
       DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.

          IF  NOT AVAILABLE tt-erro  THEN
              DO:
                 CREATE tt-erro.
                 ASSIGN tt-erro.dscritic = "Nao foi possivel validar o " +
                                           "acesso a tela.".
              END.

          RUN piXmlNew.
          RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
          RUN piXmlSave.

       END.
   ELSE
       DO:
          RUN piXmlNew.
          RUN piXmlAtributo (INPUT "permiace", INPUT aux_permiace).
          RUN piXmlAtributo (INPUT "dstextab", INPUT aux_dstextab).
          RUN piXmlAtributo (INPUT "msgaviso", INPUT aux_msgaviso).
          RUN piXmlSave.
       END.


END PROCEDURE.


/* ------------------------------------------------------------------------- */
/*   LIBERA O ACESSO A TELA                                                  */
/* ------------------------------------------------------------------------- */
PROCEDURE libera_acesso:

    RUN libera_acesso IN hBO(INPUT aux_cdcooper,
                             INPUT aux_cdagenci,
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_cdcoopex,
                             OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
       DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.

          IF  NOT AVAILABLE tt-erro  THEN
              DO:
                 CREATE tt-erro.
                 ASSIGN tt-erro.dscritic = "Nao foi possivel liberar o " +
                                           "acesso a tela.".
              END.

          RUN piXmlNew.
          RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
          RUN piXmlSave.

       END.
   ELSE
       DO:
          RUN piXmlNew.
          RUN piXmlSave.
       END.

END PROCEDURE.


/* ------------------------------------------------------------------------- */
/*    GRAVA O VALOR DOS DIVERSOS                                             */
/* ------------------------------------------------------------------------- */
PROCEDURE diversos:

   RUN pi_diversos_f IN hBO(INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_dtmvtolt,
                            INPUT aux_nmdatela,
                            INPUT aux_tpdmovto,
                            INPUT aux_vlrepass,
                            INPUT aux_vlnumera,
                            INPUT aux_vlrfolha,
                            INPUT aux_vloutros,
                            OUTPUT TABLE tt-erro).

   IF RETURN-VALUE <> "OK" THEN
      DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.

         IF  NOT AVAILABLE tt-erro  THEN
             DO:
                CREATE tt-erro.
                ASSIGN tt-erro.dscritic = "Nao foi possivel gravar o valor " +
                                          "dos diversos.".
             END.

         RUN piXmlNew.
         RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
         RUN piXmlSave.

      END.
   ELSE
      DO:
         RUN piXmlNew.
         RUN piXmlSave.
      END.


END PROCEDURE.


/* ------------------------------------------------------------------------- */
/*    BUSCA DADOS DO FLUXO DA SINGULAR                                       */
/* ------------------------------------------------------------------------- */
PROCEDURE busca_dados_fluxo_singular:

   
   RUN busca_dados_fluxo_singular IN hBO (INPUT aux_cdcooper,
                                          INPUT aux_dtmvtolx,
                                          INPUT aux_tpdmovto,
                                          OUTPUT TABLE tt-ffin-mvto-sing).

   IF  RETURN-VALUE <> "OK" THEN
       DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.

          IF  NOT AVAILABLE tt-erro  THEN
              DO:
                 CREATE tt-erro.
                 ASSIGN tt-erro.dscritic = "Nao foi possivel buscar o valor " +
                                           "do fluxo singular.".
              END.

          RUN piXmlNew.
          RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
          RUN piXmlSave.

       END.
   ELSE
       DO:
          RUN piXmlNew.
          RUN piXmlExport (INPUT TEMP-TABLE tt-ffin-mvto-sing:HANDLE,
                           INPUT "Previsao").
          RUN piXmlSave.
       END.


END PROCEDURE.

/* ------------------------------------------------------------------------- */
/*    GRAVA O VALOR DA APLICACAO E DO RESGATE                                */
/* ------------------------------------------------------------------------- */
PROCEDURE grava_apli_resg:

    
   RUN grava_apli_resg IN hBO(INPUT aux_cdcooper,  
                              INPUT aux_cdagenci,  
                              INPUT aux_nrdcaixa,  
                              INPUT aux_cdoperad,  
                              INPUT aux_nmdatela,  
                              INPUT aux_dtmvtolt,  
                              INPUT aux_dtmvtolx,  
                              INPUT aux_vlresgat,
                              INPUT aux_vlresgan,
                              INPUT aux_vlaplica,  
                              INPUT aux_vlaplian,  
                              OUTPUT TABLE tt-erro).

   IF RETURN-VALUE <> "OK" THEN
     DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF NOT AVAILABLE tt-erro  THEN
           DO:
              CREATE tt-erro.
              ASSIGN tt-erro.dscritic = "Nao foi possivel gravar o valor " +
                                        "da aplicacao/resgate.".
           END.

        RUN piXmlNew.
        RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
        RUN piXmlSave.

     END.
   ELSE
     DO:
        RUN piXmlNew.
        RUN piXmlSave.

     END.
        

END PROCEDURE.

/* ------------------------------------------------------------------------- */
/*    BUSCA DADOS CONSOLIDADOS DA SINGULAR                                   */
/* ------------------------------------------------------------------------- */
PROCEDURE busca_dados_consolidado_singular:

   RUN busca_dados_consolidado_singular IN hBO(INPUT aux_cdcooper,
                                               INPUT aux_dtmvtolt,
                                               INPUT aux_cdcoopex,
                                               OUTPUT TABLE tt-ffin-cons-sing).


   IF RETURN-VALUE <> "OK" THEN
      DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.

         IF NOT AVAILABLE tt-erro  THEN
            DO:
               CREATE tt-erro.
               ASSIGN tt-erro.dscritic = "Nao buscar os dados consolidados " +
                                         "da singular.".
            END.

         RUN piXmlNew.
         RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,INPUT "Erro").
         RUN piXmlSave.

      END.
   ELSE
      DO:
         RUN piXmlNew.
         RUN piXmlExport (INPUT TEMP-TABLE tt-ffin-cons-sing:HANDLE,
                          INPUT "Consolidado").
         RUN piXmlSave.

      END.


END PROCEDURE.
