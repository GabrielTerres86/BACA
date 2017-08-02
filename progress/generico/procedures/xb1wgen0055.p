/*.............................................................................

   Programa: xb1wgen0055.p
   Autor   : Jose Luis
   Data    : Janeiro/2010                   Ultima atualizacao: 20/04/2017

   Dados referentes ao programa:

   Objetivo: BO de Comunicacao XML x BO de Contas Pessoa Fisica (b1wgen0055.p)

   Alteracoes: 22/09/2010 -  Recebe parametro 'msgconta' no busca_dados 
                              e passa no XML. (Gabriel - DB1).
                              
               30/04/2012 - Incluido os parametros nrdeanos, nrdmeses, dsdidade
                            na procedure Valida_Dados e inclusao da temp-table
                            tt-resp na procedure grava_dados
                            (Adriano).
                            
               20/08/2013 - Incluido parametro cdufnatu nas procedures 
                            valida_dados e grava_dados. (Reinert)
                            
               27/07/2015 - Reformulacao cadastral (Gabriel-RKAM).             
               
               19/04/2017 - Alteraçao DSNACION pelo campo CDNACION.
                            PRJ339 - CRM (Odirlei-AMcom) 
               
			   20/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).          
               
.............................................................................*/

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_nrcpfcgc AS CHAR                                           NO-UNDO.
DEF VAR aux_cdoedttl AS CHAR                                           NO-UNDO.
DEF VAR aux_dtnasttl AS DATE                                           NO-UNDO.
DEF VAR aux_inhabmen AS INTE                                           NO-UNDO.
DEF VAR aux_cdfrmttl AS INTE                                           NO-UNDO.
DEF VAR aux_nmtalttl AS CHAR                                           NO-UNDO.
DEF VAR aux_qtfoltal AS INTE                                           NO-UNDO.
DEF VAR aux_nmextttl AS CHAR                                           NO-UNDO.
DEF VAR aux_dtcnscpf AS DATE                                           NO-UNDO.
DEF VAR aux_tpdocttl AS CHAR                                           NO-UNDO.
DEF VAR aux_cdufdttl AS CHAR                                           NO-UNDO.
DEF VAR aux_cdsexotl AS INTE                                           NO-UNDO.
DEF VAR aux_cdestcvl AS INTE                                           NO-UNDO.
DEF VAR aux_grescola AS INTE                                           NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.
DEF VAR aux_cdsitcpf AS INTE                                           NO-UNDO.
DEF VAR aux_nrdocttl AS CHAR                                           NO-UNDO.
DEF VAR aux_dtemdttl AS DATE                                           NO-UNDO.
DEF VAR aux_tpnacion AS INTE                                           NO-UNDO.
DEF VAR aux_dthabmen AS DATE                                           NO-UNDO.
DEF VAR aux_nmcertif AS CHAR                                           NO-UNDO.
DEF VAR aux_flgnvttl AS LOG                                            NO-UNDO.
DEF VAR aux_destpnac AS CHAR                                           NO-UNDO.
DEF VAR aux_cdnacion AS INTE                                           NO-UNDO.
DEF VAR aux_dsnacion AS CHAR                                           NO-UNDO.
DEF VAR aux_dsnatura AS CHAR                                           NO-UNDO.
DEF VAR aux_cdufnatu AS CHAR                                           NO-UNDO.
DEF VAR aux_dsestcvl AS CHAR                                           NO-UNDO.
DEF VAR aux_cdgraupr AS INTE                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_msgalert AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.
DEF VAR aux_nrctattl AS INTE                                           NO-UNDO.
DEF VAR aux_cdnatopc AS INTE                                           NO-UNDO.
DEF VAR aux_cdocpttl AS INTE                                           NO-UNDO.
DEF VAR aux_tpcttrab AS INTE                                           NO-UNDO.
DEF VAR aux_nmextemp AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcpfemp AS DECI                                           NO-UNDO.
DEF VAR aux_dsproftl AS CHAR                                           NO-UNDO.
DEF VAR aux_cdnvlcgo AS INTE                                           NO-UNDO.
DEF VAR aux_cdturnos AS INTE                                           NO-UNDO.
DEF VAR aux_dtadmemp AS DATE                                           NO-UNDO.
DEF VAR aux_vlsalari AS DECI                                           NO-UNDO.
DEF VAR aux_nrdeanos AS INT                                            NO-UNDO.
DEF VAR aux_nrdmeses AS INT                                            NO-UNDO.
DEF VAR aux_dsdidade AS CHAR                                           NO-UNDO.
DEF VAR aux_rowidrsp AS ROWID                                          NO-UNDO.
DEF VAR aux_verrespo AS LOG                                            NO-UNDO.
DEF VAR aux_permalte AS LOG                                            NO-UNDO.

{ sistema/generico/includes/b1wgen0055tt.i }
{ sistema/generico/includes/b1wgen0072tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-WEB=SIM }

/*...........................................................................*/
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
          WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
          WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
          WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
          WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
          WHEN "nrcpfcgc" THEN aux_nrcpfcgc = tt-param.valorCampo.
          WHEN "cdoedttl" THEN aux_cdoedttl = tt-param.valorCampo.
          WHEN "dtnasttl" THEN aux_dtnasttl = DATE(tt-param.valorCampo).
          WHEN "inhabmen" THEN aux_inhabmen = INTE(tt-param.valorCampo).
          WHEN "cdfrmttl" THEN aux_cdfrmttl = INTE(tt-param.valorCampo).
          WHEN "nmtalttl" THEN aux_nmtalttl = tt-param.valorCampo.
          WHEN "qtfoltal" THEN aux_qtfoltal = INTE(tt-param.valorCampo).
          WHEN "nmextttl" THEN aux_nmextttl = tt-param.valorCampo.
          WHEN "dtcnscpf" THEN aux_dtcnscpf = DATE(tt-param.valorCampo).
          WHEN "tpdocttl" THEN aux_tpdocttl = tt-param.valorCampo.
          WHEN "cdufdttl" THEN aux_cdufdttl = tt-param.valorCampo.
          WHEN "cdsexotl" THEN aux_cdsexotl = INTE(tt-param.valorCampo).
          WHEN "cdestcvl" THEN aux_cdestcvl = INTE(tt-param.valorCampo).
          WHEN "grescola" THEN aux_grescola = INTE(tt-param.valorCampo).
          WHEN "inpessoa" THEN aux_inpessoa = INTE(tt-param.valorCampo).
          WHEN "cdsitcpf" THEN aux_cdsitcpf = INTE(tt-param.valorCampo).
          WHEN "nrdocttl" THEN aux_nrdocttl = tt-param.valorCampo.
          WHEN "dtemdttl" THEN aux_dtemdttl = DATE(tt-param.valorCampo).
          WHEN "tpnacion" THEN aux_tpnacion = INTE(tt-param.valorCampo).
          WHEN "dthabmen" THEN aux_dthabmen = DATE(tt-param.valorCampo).
          WHEN "nmcertif" THEN aux_nmcertif = tt-param.valorCampo.
          WHEN "destpnac" THEN aux_destpnac = tt-param.valorCampo.
          WHEN "cdnacion" THEN aux_cdnacion = INTE(tt-param.valorCampo).
          WHEN "cdgraupr" THEN aux_cdgraupr = INTE(tt-param.valorCampo).
          WHEN "dsnacion" THEN aux_dsnacion = tt-param.valorCampo.
          WHEN "dsnatura" THEN aux_dsnatura = tt-param.valorCampo.
          WHEN "cdufnatu" THEN aux_cdufnatu = tt-param.valorCampo.
          WHEN "dsestcvl" THEN aux_dsestcvl = tt-param.valorCampo.
          WHEN "nrctattl" THEN aux_nrctattl = INTE(tt-param.valorCampo).
          WHEN "cdnatopc" THEN aux_cdnatopc = INTE(tt-param.valorCampo).
          WHEN "cdocpttl" THEN aux_cdocpttl = INTE(tt-param.valorCampo).
          WHEN "tpcttrab" THEN aux_tpcttrab = INTE(tt-param.valorCampo).
          WHEN "nmextemp" THEN aux_nmextemp = tt-param.valorCampo.
          WHEN "nrcpfemp" THEN aux_nrcpfemp = DECI(tt-param.valorCampo).
          WHEN "dsproftl" THEN aux_dsproftl = tt-param.valorCampo.
          WHEN "cdnvlcgo" THEN aux_cdnvlcgo = INTE(tt-param.valorCampo).
          WHEN "cdturnos" THEN aux_cdturnos = INTE(tt-param.valorCampo).
          WHEN "dtadmemp" THEN aux_dtadmemp = DATE(tt-param.valorCampo).
          WHEN "vlsalari" THEN aux_vlsalari = DECI(tt-param.valorCampo).
          WHEN "chavealt" THEN aux_chavealt = tt-param.valorCampo.
          WHEN "tpatlcad" THEN aux_tpatlcad = INTE(tt-param.valorCampo).
          WHEN "verrespo" THEN aux_verrespo = LOGICAL(tt-param.valorCampo).
          WHEN "permalte" THEN aux_permalte = LOGICAL(tt-param.valorCampo).

      END CASE.

  END. /** Fim do FOR EACH tt-param **/

  FOR EACH tt-param-i BREAK BY tt-param-i.nomeTabela
                             BY tt-param-i.sqControle:
        
      CASE tt-param-i.nomeTabela:

            WHEN "RespLegal" THEN DO:
                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:
                       CREATE tt-resp.
                       ASSIGN aux_rowidrsp = ROWID(tt-resp).
                    END.

                FIND tt-resp WHERE 
                     ROWID(tt-resp) = aux_rowidrsp NO-ERROR.

                CASE tt-param-i.nomeCampo:
                                            
                    WHEN "cddctato" THEN
                        ASSIGN tt-resp.cddctato = 
                            INTE(REPLACE(tt-param-i.valorCampo,"-","")).
                    WHEN "nrdrowid" THEN
                        ASSIGN tt-resp.nrdrowid = 
                          TO-ROWID(tt-param-i.valorCampo).
                    WHEN "cdcooper" THEN
                        ASSIGN tt-resp.cdcooper = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrctamen" THEN
                        ASSIGN tt-resp.nrctamen = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrcpfmen" THEN
                        ASSIGN tt-resp.nrcpfmen = 
                            DEC(tt-param-i.valorCampo).
                    WHEN "idseqmen" THEN
                        ASSIGN tt-resp.idseqmen = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrdconta" THEN
                        ASSIGN tt-resp.nrdconta = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "nrcpfcgc" THEN
                        ASSIGN tt-resp.nrcpfcgc = 
                            DEC(tt-param-i.valorCampo).
                    WHEN "nmrespon" THEN
                        ASSIGN tt-resp.nmrespon = 
                            tt-param-i.valorCampo.
                    WHEN "nridenti" THEN
                        ASSIGN tt-resp.nridenti = 
                            tt-param-i.valorCampo.
                    WHEN "tpdeiden" THEN
                        ASSIGN tt-resp.tpdeiden = 
                            tt-param-i.valorCampo.
                    WHEN "dsorgemi" THEN
                        ASSIGN tt-resp.dsorgemi = 
                            tt-param-i.valorCampo.
                    WHEN "cdufiden" THEN
                        ASSIGN tt-resp.cdufiden = 
                            tt-param-i.valorCampo.
                    WHEN "dtemiden" THEN
                        ASSIGN tt-resp.dtemiden = 
                            DATE(tt-param-i.valorCampo).
                    WHEN "dtnascin" THEN
                        ASSIGN tt-resp.dtnascin = 
                            DATE(tt-param-i.valorCampo).
                    WHEN "cddosexo" THEN
                        ASSIGN tt-resp.cddosexo = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "cdestciv" THEN
                        ASSIGN tt-resp.cdestciv = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "dsnacion" THEN
                        ASSIGN tt-resp.dsnacion = 
                            tt-param-i.valorCampo.
                    WHEN "cdnacion" THEN
                        ASSIGN tt-resp.cdnacion = 
                            INTE(tt-param-i.valorCampo).        
                    WHEN "dsnatura" THEN
                        ASSIGN tt-resp.dsnatura = 
                            tt-param-i.valorCampo.
                    WHEN "cdcepres" THEN
                        ASSIGN tt-resp.cdcepres = 
                            DEC(tt-param-i.valorCampo).
                    WHEN "dsendres" THEN
                        ASSIGN tt-resp.dsendres = 
                            tt-param-i.valorCampo.
                    WHEN "nrendres" THEN
                        ASSIGN tt-resp.nrendres = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "dscomres" THEN
                        ASSIGN tt-resp.dscomres = 
                            tt-param-i.valorCampo.
                    WHEN "dsbaires" THEN
                        ASSIGN tt-resp.dsbaires = 
                            tt-param-i.valorCampo.
                    WHEN "nrcxpost" THEN
                        ASSIGN tt-resp.nrcxpost = 
                            INTE(tt-param-i.valorCampo).
                    WHEN "dscidres" THEN
                        ASSIGN tt-resp.dscidres = 
                            tt-param-i.valorCampo.
                    WHEN "dsdufres" THEN
                        ASSIGN tt-resp.dsdufres = 
                            tt-param-i.valorCampo.
                    WHEN "nmpairsp" THEN
                        ASSIGN tt-resp.nmpairsp = 
                            tt-param-i.valorCampo.
                    WHEN "nmmaersp" THEN
                        ASSIGN tt-resp.nmmaersp = 
                            tt-param-i.valorCampo.
                    WHEN "cdrlcrsp" THEN
                        ASSIGN tt-resp.cdrlcrsp =
                            INTE(tt-param-i.valorCampo).
                    WHEN "cddopcao" THEN
                        ASSIGN tt-resp.cddopcao = 
                            tt-param-i.valorCampo.
                    WHEN "deletado" THEN
                        ASSIGN tt-resp.deletado = 
                            LOGICAL(tt-param-i.valorCampo). 
                                                          
                END CASE. /* CASE tt-param-i.nomeCampo */ 

            END. /* "resp Legal"  */

        END CASE. /* CASE tt-param-i.nomeTabela: */
                         
    END.

END PROCEDURE.    

/*****************************************************************************/
/**      Procedure para carregar dados para montar o cabeçalho da tela      **/
/*****************************************************************************/
PROCEDURE busca_dados:

    RUN busca_dados IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrdconta,
                            INPUT aux_idseqttl,
                            INPUT YES,
                            INPUT aux_cddopcao,
                            INPUT aux_cdgraupr,
                            INPUT aux_nrcpfcgc,
                           OUTPUT aux_msgalert,
                           OUTPUT TABLE tt-dados-fis,
                           OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").

            RETURN.
        END.

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "busca.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-dados-fis:HANDLE,
                            INPUT "DadosFisico").
           RUN piXmlAtributo (INPUT "msgalert", INPUT TRIM(aux_msgalert)).
           RUN piXmlSave.         
        END.
        
END PROCEDURE.

/*****************************************************************************/
/**  Procedure para validar os dados obtidos na tela web                    **/
/*****************************************************************************/
PROCEDURE Valida_Dados:

    RUN Valida_Dados IN hBO (INPUT aux_cdcooper, 
                             INPUT aux_cdagenci, 
                             INPUT aux_nrdcaixa, 
                             INPUT aux_cdoperad, 
                             INPUT aux_nmdatela, 
                             INPUT aux_idorigem, 
                             INPUT aux_nrdconta, 
                             INPUT aux_idseqttl, 
                             INPUT YES,
                             INPUT aux_cddopcao,
                             INPUT aux_dtmvtolt, 
                             INPUT aux_cdgraupr, 
                             INPUT aux_nrcpfcgc, 
                             INPUT aux_nmextttl, 
                             INPUT aux_nrctattl, 
                             INPUT aux_inpessoa, 
                             INPUT aux_dtcnscpf, 
                             INPUT aux_cdsitcpf, 
                             INPUT aux_tpdocttl, 
                             INPUT aux_nrdocttl, 
                             INPUT aux_cdoedttl, 
                             INPUT aux_cdufdttl, 
                             INPUT aux_dtemdttl,
                             INPUT aux_dtnasttl, 
                             INPUT aux_cdsexotl, 
                             INPUT aux_tpnacion, 
                             INPUT aux_cdnacion, 
                             INPUT aux_dsnatura,
                             INPUT aux_cdufnatu, 
                             INPUT aux_inhabmen, 
                             INPUT aux_dthabmen, 
                             INPUT aux_cdestcvl, 
                             INPUT aux_grescola, 
                             INPUT aux_cdfrmttl, 
                             INPUT aux_nmcertif,
                             INPUT aux_nmtalttl, 
                             INPUT aux_qtfoltal, 
                             INPUT aux_verrespo,
                             INPUT aux_permalte,
                             INPUT TABLE tt-resp,
                            OUTPUT aux_nmdcampo,
                            OUTPUT TABLE tt-erro,
                            OUTPUT aux_nrdeanos,
                            OUTPUT aux_nrdmeses,
                            OUTPUT aux_dsdidade) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO: 
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").

            RETURN.
        END.

        
    IF  RETURN-VALUE <> "OK" THEN
        DO: 
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "validacao.".
                END.
                
            RUN piXmlNew. 
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo", INPUT TRIM(aux_nmdcampo)).
            RUN piXmlSave.
        END.
    ELSE
        DO: 
            RUN piXmlNew. 
            RUN piXmlAtributo (INPUT "nrdeanos", INPUT aux_nrdeanos).
            RUN piXmlAtributo (INPUT "nrdmeses", INPUT aux_nrdmeses).
            RUN piXmlAtributo (INPUT "dsdidade", INPUT aux_dsdidade).
            RUN piXmlSave.
        END.
        
END PROCEDURE.

/*****************************************************************************/
/**  Procedure para processar os dados obtidos na tela web (valida e grava) **/
/*****************************************************************************/
PROCEDURE Grava_Dados:


    RUN Grava_Dados IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrdconta,
                            INPUT aux_idseqttl,
                            INPUT aux_cddopcao,
                            INPUT aux_dtmvtolt,
                            INPUT YES,         
                            INPUT aux_cdgraupr,
                            INPUT aux_nrcpfcgc,
                            INPUT aux_cdoedttl,
                            INPUT aux_dtnasttl,
                            INPUT aux_nmtalttl,
                            INPUT aux_inhabmen,
                            INPUT aux_cdfrmttl,
                            INPUT aux_qtfoltal,
                            INPUT aux_nmextttl,
                            INPUT aux_dtcnscpf,
                            INPUT aux_tpdocttl,
                            INPUT aux_cdufdttl,
                            INPUT aux_cdsexotl,
                            INPUT aux_cdnacion,
                            INPUT aux_cdestcvl,
                            INPUT aux_grescola,
                            INPUT aux_inpessoa,
                            INPUT aux_cdsitcpf,
                            INPUT aux_nrdocttl,
                            INPUT aux_dtemdttl,
                            INPUT aux_tpnacion,
                            INPUT aux_dsnatura,
                            INPUT aux_cdufnatu,
                            INPUT aux_dthabmen,
                            INPUT aux_nmcertif,
                            INPUT aux_cdnatopc,
                            INPUT aux_cdocpttl,
                            INPUT aux_tpcttrab,
                            INPUT aux_nmextemp,
                            INPUT aux_nrcpfemp,
                            INPUT aux_dsproftl,
                            INPUT aux_cdnvlcgo,
                            INPUT aux_cdturnos,
                            INPUT aux_dtadmemp,
                            INPUT aux_vlsalari,
                            INPUT TABLE tt-resp,
                           OUTPUT aux_msgalert,
                           OUTPUT aux_tpatlcad,
                           OUTPUT aux_msgatcad,
                           OUTPUT aux_chavealt,
                           OUTPUT TABLE tt-erro) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO: 
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = ERROR-STATUS:GET-MESSAGE(1).

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").

            RETURN.
        END.

    IF  RETURN-VALUE <> "OK" THEN
        DO: 
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "gravacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew. 
            RUN piXmlAtributo (INPUT "msgatcad", INPUT aux_msgatcad).
            RUN piXmlAtributo (INPUT "tpatlcad", INPUT aux_tpatlcad).
            RUN piXmlAtributo (INPUT "chavealt", INPUT aux_chavealt).
            RUN piXmlAtributo (INPUT "msgalert", INPUT aux_msgalert).
            RUN piXmlSave.
        END.
        
END PROCEDURE.
