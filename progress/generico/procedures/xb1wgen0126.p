/*............................................................................

     Programa: sistema/generico/procedures/xb1wgen0126.p
     Autor   : Rogerius Militão
     Data    : Dezembro/2011                    Ultima atualizacao: 06/06/2014

     Objetivo  : BO de Comunicacao XML x BO - Tela ALTAVA

     Alteracoes: 06/06/2014 - Adicionado tratamento para novos campos inpessoa e
                              dtnascto, incluso parametros nas procedures 
                              Grava_Dados, Valida_Avalista (Daniel). 

.............................................................................*/
 
/*...........................................................................*/
 DEF VAR aux_cdcooper  AS INTE                                           NO-UNDO.
 DEF VAR aux_cdagenci  AS INTE                                           NO-UNDO.
 DEF VAR aux_cdagencx  AS INTE                                           NO-UNDO. 
 DEF VAR aux_nrdcaixa  AS INTE                                           NO-UNDO.
 DEF VAR aux_cdoperad  AS CHAR                                           NO-UNDO.
 DEF VAR aux_nmoperad  AS CHAR                                           NO-UNDO.
 DEF VAR aux_nmdatela  AS CHAR                                           NO-UNDO.
 DEF VAR aux_idorigem  AS INTE                                           NO-UNDO.
 DEF VAR aux_dsiduser  AS CHAR                                           NO-UNDO.                     

 /* Cabecalho */      
 DEF VAR aux_nrdconta  AS INTE                                           NO-UNDO.
 DEF VAR aux_nrctremp  AS INTE                                           NO-UNDO.
                      
 /* Avalista */       
 DEF VAR aux_nrdcontx  AS INTE                                           NO-UNDO.  
 DEF VAR aux_nrcpfcgc  AS DECI                                           NO-UNDO. 
 DEF VAR aux_idavalis  AS INTE                                           NO-UNDO. 
 DEF VAR aux_nrctaava  AS INTE                                           NO-UNDO. 
 DEF VAR aux_nmdavali  AS CHAR                                           NO-UNDO. 
 DEF VAR aux_nrcpfava  AS DECI                                           NO-UNDO. 
 DEF VAR aux_nrcpfcjg  AS DECI                                           NO-UNDO. 
 DEF VAR aux_dsendere  AS CHAR                                           NO-UNDO.  
 DEF VAR aux_cdufresd  AS CHAR                                           NO-UNDO. 
 DEF VAR aux_nrcepend  AS INTE                                           NO-UNDO. 

 DEF VAR aux_inpessoa  AS INTE                                           NO-UNDO.
 DEF VAR aux_dtnascto  AS DATE                                           NO-UNDO.
                      
 /* Avalista 1 */
 DEF VAR aux_nrctaav1  AS INTE                                           NO-UNDO. 
 DEF VAR aux_cpfcgc1   AS DECI                                           NO-UNDO. 
 DEF VAR aux_nmdaval1  AS CHAR                                           NO-UNDO. 
 DEF VAR aux_cpfccg1   AS DECI                                           NO-UNDO. 
 DEF VAR aux_nmcjgav1  AS CHAR                                           NO-UNDO. 
 DEF VAR aux_tpdoccj1  AS CHAR                                           NO-UNDO. 
 DEF VAR aux_dscfcav1  AS CHAR                                           NO-UNDO. 
 DEF VAR aux_tpdocav1  AS CHAR                                           NO-UNDO. 
 DEF VAR aux_dscpfav1  AS CHAR                                           NO-UNDO. 
 DEF VAR aux_dsenda11  AS CHAR                                           NO-UNDO. 
 DEF VAR aux_dsenda12  AS CHAR                                           NO-UNDO. 
 DEF VAR aux_nrfonres1 AS CHAR                                           NO-UNDO. 
 DEF VAR aux_dsdemail1 AS CHAR                                           NO-UNDO. 
 DEF VAR aux_nmcidade1 AS CHAR                                           NO-UNDO. 
 DEF VAR aux_cdufresd1 AS CHAR                                           NO-UNDO. 
 DEF VAR aux_nrcepend1 AS INTE                                           NO-UNDO. 
 DEF VAR aux_nrendere1 AS INTE                                           NO-UNDO. 
 DEF VAR aux_complend1 AS CHAR                                           NO-UNDO. 
 DEF VAR aux_nrcxapst1 AS INTE                                           NO-UNDO. 
 DEF VAR aux_inpessoa1 AS INTE                                           NO-UNDO.
 DEF VAR aux_cdnacion1 AS INTE                                           NO-UNDO.
 DEF VAR aux_vlrencjg1 AS DECI                                           NO-UNDO. 
 DEF VAR aux_vlrenmes1 AS DECI                                           NO-UNDO. 
 DEF VAR aux_dtnascto1 AS DATE                                           NO-UNDO.

 /* Avalista 2 */
 DEF VAR aux_nrctaav2  AS INTE                                           NO-UNDO.
 DEF VAR aux_cpfcgc2   AS DECI                                           NO-UNDO.
 DEF VAR aux_nmdaval2  AS CHAR                                           NO-UNDO.
 DEF VAR aux_cpfccg2   AS DECI                                           NO-UNDO.
 DEF VAR aux_nmcjgav2  AS CHAR                                           NO-UNDO.
 DEF VAR aux_tpdoccj2  AS CHAR                                           NO-UNDO.
 DEF VAR aux_dscfcav2  AS CHAR                                           NO-UNDO.
 DEF VAR aux_tpdocav2  AS CHAR                                           NO-UNDO.
 DEF VAR aux_dscpfav2  AS CHAR                                           NO-UNDO.
 DEF VAR aux_dsenda21  AS CHAR                                           NO-UNDO.
 DEF VAR aux_dsenda22  AS CHAR                                           NO-UNDO.
 DEF VAR aux_nrfonres2 AS CHAR                                           NO-UNDO.
 DEF VAR aux_dsdemail2 AS CHAR                                           NO-UNDO.
 DEF VAR aux_nmcidade2 AS CHAR                                           NO-UNDO.
 DEF VAR aux_cdufresd2 AS CHAR                                           NO-UNDO.
 DEF VAR aux_nrcepend2 AS INTE                                           NO-UNDO.
 DEF VAR aux_nrendere2 AS INTE                                           NO-UNDO.
 DEF VAR aux_complend2 AS CHAR                                           NO-UNDO.
 DEF VAR aux_nrcxapst2 AS INTE                                           NO-UNDO.
 DEF VAR aux_inpessoa2 AS INTE                                           NO-UNDO.
 DEF VAR aux_cdnacion2 AS INTE                                           NO-UNDO.
 DEF VAR aux_vlrencjg2 AS DECI                                           NO-UNDO. 
 DEF VAR aux_vlrenmes2 AS DECI                                           NO-UNDO.  
 DEF VAR aux_dtnascto2 AS DATE                                           NO-UNDO.
 
 /* Imprimir */
 DEF VAR aux_uladitiv  AS INTE                                           NO-UNDO.

 /* Output */
 DEF VAR aux_nrctatos AS INTE                                            NO-UNDO.
 DEF VAR aux_nmdcampo AS CHAR                                            NO-UNDO.
 DEF VAR aux_nmarqimp AS CHAR                                            NO-UNDO. 
 DEF VAR aux_nmarqpdf AS CHAR                                            NO-UNDO. 

 { sistema/generico/includes/var_internet.i } 
 { sistema/generico/includes/supermetodos.i } 
 { sistema/generico/includes/b1wgen0126tt.i }

 /*............................... PROCEDURES ................................*/
  PROCEDURE valores_entrada:

      FOR EACH tt-param:

          CASE tt-param.nomeCampo:

              WHEN "cdcooper" THEN aux_cdcooper  = INTE(tt-param.valorCampo).
              WHEN "cdagenci" THEN aux_cdagenci  = INTE(tt-param.valorCampo).
              WHEN "cdagencx" THEN aux_cdagencx  = INTE(tt-param.valorCampo).
              WHEN "nrdcaixa" THEN aux_nrdcaixa  = INTE(tt-param.valorCampo).
              WHEN "cdoperad" THEN aux_cdoperad  = tt-param.valorCampo.
              WHEN "nmoperad" THEN aux_nmoperad  = tt-param.valorCampo.
              WHEN "nmdatela" THEN aux_nmdatela  = tt-param.valorCampo.
              WHEN "idorigem" THEN aux_idorigem  = INTE(tt-param.valorCampo).
              WHEN "dtmvtolt" THEN aux_dtmvtolt  = DATE(tt-param.valorCampo).
              WHEN "dsiduser" THEN aux_dsiduser  = tt-param.valorCampo.

              WHEN "nrdconta" THEN aux_nrdconta  = INTE(tt-param.valorCampo).
              WHEN "nrctremp" THEN aux_nrctremp  = INTE(tt-param.valorCampo).
                                                 
              WHEN "nrdcontx" THEN aux_nrdcontx  = INTE(tt-param.valorCampo). 
              WHEN "nrcpfcgc" THEN aux_nrcpfcgc  = DECI(tt-param.valorCampo). 
              WHEN "idavalis" THEN aux_idavalis  = INTE(tt-param.valorCampo). 
              WHEN "nrctaava" THEN aux_nrctaava  = INTE(tt-param.valorCampo). 
              WHEN "nmdavali" THEN aux_nmdavali  = tt-param.valorCampo.       
              WHEN "nrcpfava" THEN aux_nrcpfava  = DECI(tt-param.valorCampo).       
              WHEN "nrcpfcjg" THEN aux_nrcpfcjg  = DECI(tt-param.valorCampo). 
              WHEN "dsendere" THEN aux_dsendere  = tt-param.valorCampo. 
              WHEN "cdufresd" THEN aux_cdufresd  = tt-param.valorCampo. 
              WHEN "nrcepend" THEN aux_nrcepend  = INTE(tt-param.valorCampo). 

              WHEN "inpessoa" THEN aux_inpessoa = INTE(tt-param.valorCampo).  
              WHEN "dtnascto" THEN aux_dtnascto = DATE(tt-param.valorCampo). 
                                                 
              WHEN "nrctaav1"  THEN aux_nrctaav1  = INTE(tt-param.valorCampo). 
              WHEN "cpfcgc1"   THEN aux_cpfcgc1   = DECI(tt-param.valorCampo). 
              WHEN "nmdaval1"  THEN aux_nmdaval1  = tt-param.valorCampo. 
              WHEN "cpfccg1"   THEN aux_cpfccg1   = DECI(tt-param.valorCampo). 
              WHEN "nmcjgav1"  THEN aux_nmcjgav1  = tt-param.valorCampo.       
              WHEN "tpdoccj1"  THEN aux_tpdoccj1  = tt-param.valorCampo. 
              WHEN "dscfcav1"  THEN aux_dscfcav1  = tt-param.valorCampo. 
              WHEN "tpdocav1"  THEN aux_tpdocav1  = tt-param.valorCampo.       
              WHEN "dscpfav1"  THEN aux_dscpfav1  = tt-param.valorCampo.       
              WHEN "dsenda11"  THEN aux_dsenda11  = tt-param.valorCampo. 
              WHEN "dsenda12"  THEN aux_dsenda12  = tt-param.valorCampo. 
              WHEN "nrfonres1" THEN aux_nrfonres1 = tt-param.valorCampo. 
              WHEN "dsdemail1" THEN aux_dsdemail1 = tt-param.valorCampo. 
              WHEN "nmcidade1" THEN aux_nmcidade1 = tt-param.valorCampo. 
              WHEN "cdufresd1" THEN aux_cdufresd1 = tt-param.valorCampo.       
              WHEN "nrcepend1" THEN aux_nrcepend1 = INTE(tt-param.valorCampo). 
              WHEN "nrendere1" THEN aux_nrendere1 = INTE(tt-param.valorCampo). 
              WHEN "complend1" THEN aux_complend1 = tt-param.valorCampo.       
              WHEN "nrcxapst1" THEN aux_nrcxapst1 = INTE(tt-param.valorCampo).  
              WHEN "inpessoa1" THEN aux_inpessoa1 = INTE(tt-param.valorCampo).  
              WHEN "cdnacion1" THEN aux_cdnacion1 = INTE(tt-param.valorCampo).  
              WHEN "vlrencjg1" THEN aux_vlrencjg1 = DECI(tt-param.valorCampo). 
              WHEN "vlrenmes1" THEN aux_vlrenmes1 = DECI(tt-param.valorCampo). 
              WHEN "dtnascto1" THEN aux_dtnascto1 = DATE(tt-param.valorCampo). 

              WHEN "nrctaav2"  THEN aux_nrctaav2  = INTE(tt-param.valorCampo). 
              WHEN "cpfcgc2"   THEN aux_cpfcgc2   = DECI(tt-param.valorCampo). 
              WHEN "nmdaval2"  THEN aux_nmdaval2  = tt-param.valorCampo. 
              WHEN "cpfccg2"   THEN aux_cpfccg2   = DECI(tt-param.valorCampo). 
              WHEN "nmcjgav2"  THEN aux_nmcjgav2  = tt-param.valorCampo.       
              WHEN "tpdoccj2"  THEN aux_tpdoccj2  = tt-param.valorCampo. 
              WHEN "dscfcav2"  THEN aux_dscfcav2  = tt-param.valorCampo. 
              WHEN "tpdocav2"  THEN aux_tpdocav2  = tt-param.valorCampo.       
              WHEN "dscpfav2"  THEN aux_dscpfav2  = tt-param.valorCampo.       
              WHEN "dsenda21"  THEN aux_dsenda21  = tt-param.valorCampo. 
              WHEN "dsenda22"  THEN aux_dsenda22  = tt-param.valorCampo. 
              WHEN "nrfonres2" THEN aux_nrfonres2 = tt-param.valorCampo. 
              WHEN "dsdemail2" THEN aux_dsdemail2 = tt-param.valorCampo. 
              WHEN "nmcidade2" THEN aux_nmcidade2 = tt-param.valorCampo. 
              WHEN "cdufresd2" THEN aux_cdufresd2 = tt-param.valorCampo.       
              WHEN "nrcepend2" THEN aux_nrcepend2 = INTE(tt-param.valorCampo). 
              WHEN "nrendere2" THEN aux_nrendere2 = INTE(tt-param.valorCampo). 
              WHEN "complend2" THEN aux_complend2 = tt-param.valorCampo.       
              WHEN "nrcxapst2" THEN aux_nrcxapst2 = INTE(tt-param.valorCampo).  
              WHEN "inpessoa2" THEN aux_inpessoa2 = INTE(tt-param.valorCampo).  
              WHEN "cdnacion2" THEN aux_cdnacion2 = INTE(tt-param.valorCampo).  
              WHEN "vlrencjg2" THEN aux_vlrencjg2 = DECI(tt-param.valorCampo). 
              WHEN "vlrenmes2" THEN aux_vlrenmes2 = DECI(tt-param.valorCampo). 
              WHEN "dtnascto2" THEN aux_dtnascto2 = DATE(tt-param.valorCampo). 

              WHEN "uladitiv"  THEN aux_uladitiv  = INTE(tt-param.valorCampo). 
          END CASE.

      END. /** Fim do FOR EACH tt-param **/


  END PROCEDURE. /* valores_entrada */


 /* ------------------------------------------------------------------------ */
 /*             BUSCA DOS DADOS ASSOCIADO P/ ALTERAR AVAL/FIADORES           */
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
                     INPUT aux_nrdconta,
                     INPUT YES, /* flgerlog */
                    OUTPUT aux_nrctatos,
                    OUTPUT aux_nrctremp,
                    OUTPUT TABLE tt-infoass,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-infoass:HANDLE,
                             INPUT "Associado").
            RUN piXmlSave.

         END.
     ELSE
         DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-infoass:HANDLE,
                             INPUT "Associado").
            RUN piXmlAtributo (INPUT "nrctatos", INPUT aux_nrctatos).
            RUN piXmlAtributo (INPUT "nrctremp", INPUT aux_nrctremp).

            RUN piXmlSave.
         END.


 END PROCEDURE. /* Busca_Dados */


 /* ------------------------------------------------------------------------ */
 /*  VALIDA OS DADOS DO AVALISTA COM CONTA P/ ALTERAR CONTRATO DE EMPRESTIMO */
 /* ------------------------------------------------------------------------ */
 PROCEDURE Valida_Conta:

     RUN Valida_Conta IN hBO
                    ( INPUT aux_cdcooper,
                      INPUT aux_cdagenci,
                      INPUT aux_nrdcaixa,
                      INPUT aux_cdoperad,
                      INPUT aux_nmdatela,
                      INPUT aux_idorigem,
                      INPUT aux_dtmvtolt,
                      INPUT aux_nrdconta,
                      INPUT aux_nrctaava, 
                      INPUT YES, /* flgerlog */
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


 END PROCEDURE. /* Valida_Dados */


 /* ------------------------------------------------------------------------ */
 /*             BUSCA DOS DADOS CONTRATO P/ ALTERAR AVAL/FIADORES            */
 /* ------------------------------------------------------------------------ */
 PROCEDURE Busca_Contrato:

     RUN Busca_Contrato IN hBO
                      ( INPUT aux_cdcooper,
                        INPUT aux_cdagenci,
                        INPUT aux_nrdcaixa,
                        INPUT aux_cdoperad,
                        INPUT aux_nmdatela,
                        INPUT aux_idorigem,
                        INPUT aux_dtmvtolt,
                        INPUT aux_nrdconta,
                        INPUT aux_nrctremp, 
                        INPUT YES, /* flgerlog */
                       OUTPUT TABLE tt-contrato,
                       OUTPUT TABLE tt-contrato-avalista,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-contrato:HANDLE,
                             INPUT "Contrato").
            RUN piXmlExport (INPUT TEMP-TABLE tt-contrato-avalista:HANDLE,
                             INPUT "Avalista").
            RUN piXmlSave.
         END.


 END PROCEDURE. /* Busca_Contrato */
 
 /* ------------------------------------------------------------------------ */
 /*     VALIDACAO DOS DADOS DO AVALISTA P/ ALTERAR CONTRATO DE EMPRESTIMO    */
 /* ------------------------------------------------------------------------ */
 PROCEDURE Valida_Avalista:
    
     RUN Valida_Avalista IN hBO
                       ( INPUT aux_cdcooper, 
                         INPUT aux_cdagenci, 
                         INPUT aux_nrdcaixa, 
                         INPUT aux_cdoperad, 
                         INPUT aux_nmdatela, 
                         INPUT aux_idorigem, 
                         INPUT aux_dtmvtolt, 
                         INPUT aux_nrdconta, 
                         INPUT aux_nrdcontx, 
                         INPUT aux_nrcpfcgc, 
                         INPUT aux_idavalis, 
                         INPUT aux_nrctaava, 
                         INPUT aux_nmdavali, 
                         INPUT aux_nrcpfava, 
                         INPUT aux_nrcpfcjg, 
                         INPUT aux_dsendere, 
                         INPUT aux_cdufresd, 
                         INPUT aux_nrcepend, 
                         INPUT YES, /* flgerlog */
                         INPUT aux_inpessoa,
                         INPUT aux_dtnascto,
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
            RUN piXmlSave.

         END.
     ELSE
         DO:
            RUN piXmlNew.
            RUN piXmlSave.
         END.

 END PROCEDURE. /* Valida_Avalista */
 

 /* ------------------------------------------------------------------------ */
 /*        BUSCA DOS DADOS AVALISTA P/ ALTERAR CONTRATOS DE EMPRESTIMO       */
 /* ------------------------------------------------------------------------ */
 PROCEDURE Busca_Avalista:

     RUN Busca_Avalista IN hBO
                      ( INPUT aux_cdcooper ,
                        INPUT aux_nrctaava ,
                        INPUT aux_nrcpfcgc ,
                       OUTPUT TABLE tt-avalista).

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
            RUN piXmlExport (INPUT TEMP-TABLE tt-avalista:HANDLE,
                             INPUT "Avalista").
            RUN piXmlSave.
         END.

 END PROCEDURE. /* Busca_Avalista */


 /* ------------------------------------------------------------------------ */
 /*        BUSCA DOS DADOS AVALISTA P/ ALTERAR CONTRATOS DE EMPRESTIMO       */
 /* ------------------------------------------------------------------------ */
 PROCEDURE Grava_Dados:

     RUN Grava_Dados IN hBO
                   ( INPUT aux_cdcooper,
                     INPUT aux_cdagenci,
                     INPUT aux_nrdcaixa,
                     INPUT aux_cdoperad,
                     INPUT aux_nmdatela, 
                     INPUT aux_dtmvtolt, 
                     INPUT aux_idorigem, 
                     INPUT aux_nrdconta, 
                     INPUT aux_nrctremp, 
                     INPUT aux_nrctaav1,  
                     INPUT aux_cpfcgc1,   
                     INPUT aux_nmdaval1,  
                     INPUT aux_cpfccg1,   
                     INPUT aux_nmcjgav1,  
                     INPUT aux_tpdoccj1,  
                     INPUT aux_dscfcav1,  
                     INPUT aux_tpdocav1,  
                     INPUT aux_dscpfav1,  
                     INPUT aux_dsenda11,  
                     INPUT aux_dsenda12,  
                     INPUT aux_nrfonres1, 
                     INPUT aux_dsdemail1, 
                     INPUT aux_nmcidade1, 
                     INPUT aux_cdufresd1, 
                     INPUT aux_nrcepend1, 
                     INPUT aux_nrendere1, 
                     INPUT aux_complend1, 
                     INPUT aux_nrcxapst1,

                     INPUT aux_inpessoa1,
                     INPUT aux_cdnacion1,
                     INPUT aux_vlrencjg1,
                     INPUT aux_vlrenmes1,                     
                     INPUT aux_dtnascto1,

                     INPUT aux_nrctaav2, 
                     INPUT aux_cpfcgc2,  
                     INPUT aux_nmdaval2, 
                     INPUT aux_cpfccg2,  
                     INPUT aux_nmcjgav2, 
                     INPUT aux_tpdoccj2, 
                     INPUT aux_dscfcav2, 
                     INPUT aux_tpdocav2, 
                     INPUT aux_dscpfav2, 
                     INPUT aux_dsenda21, 
                     INPUT aux_dsenda22,
                     INPUT aux_nrfonres2,
                     INPUT aux_dsdemail2,
                     INPUT aux_nmcidade2,
                     INPUT aux_cdufresd2,
                     INPUT aux_nrcepend2,
                     INPUT aux_nrendere2,
                     INPUT aux_complend2,
                     INPUT aux_nrcxapst2,

                     INPUT aux_inpessoa2,
                     INPUT aux_cdnacion2,
                     INPUT aux_vlrencjg2,
                     INPUT aux_vlrenmes2,
                     INPUT aux_dtnascto2,

                     INPUT TRUE, /* flgerlog */
                     OUTPUT TABLE tt-contrato-imprimir,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-contrato-imprimir:HANDLE,
                             INPUT "Imprimir").
            RUN piXmlSave.
         END.


 END PROCEDURE. /* Grava_Dados */


 /* ------------------------------------------------------------------------ */
 /*     IMPRIMI OS DADOS DO AVALISTA ALTERADOS NO CONTRATO DE EMPRESTIMO     */
 /* ------------------------------------------------------------------------ */
 PROCEDURE Gera_Impressao:

     RUN Gera_Impressao IN hBO
                      ( INPUT aux_cdcooper,
                        INPUT aux_cdagenci,
                        INPUT aux_nrdcaixa,
                        INPUT aux_cdoperad,
                        INPUT aux_nmoperad,
                        INPUT aux_dtmvtolt,
                        INPUT aux_idorigem,
                        INPUT aux_dsiduser,
                        INPUT aux_nrdconta,
                        INPUT aux_nrctremp,
                        INPUT aux_nrcpfava,
                        INPUT aux_nmdavali,
                        INPUT aux_uladitiv,
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

 END PROCEDURE. /* Gera_Impressao */

