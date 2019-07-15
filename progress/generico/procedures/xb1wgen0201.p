/* ............................................................................

   Programa: sistema/generico/procedures/xb1wgen0201.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Reinert
   Data    : Maio/2017.                       Ultima atualizacao:  /  /  

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : BO de Comunicacao XML VS BO de envio de informacoes 
               para o Desligamento de cooperados (b1wgen0197.p)

   Alteracoes:
   
.............................................................................*/   


DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS DECI                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.
DEF VAR aux_tpemprst AS INTE                                           NO-UNDO.
DEF VAR aux_vlemprst AS DECI                                           NO-UNDO.
DEF VAR aux_vlliqemp AS DECI                                           NO-UNDO.
DEF VAR aux_vliofepr AS DECI                                           NO-UNDO.
DEF VAR aux_percetop AS DECI                                           NO-UNDO.
DEF VAR aux_qtpreemp AS INTE                                           NO-UNDO.
DEF VAR aux_vlpreemp AS DECI                                           NO-UNDO.
DEF VAR aux_cdlcremp AS INTE                                           NO-UNDO.
DEF VAR aux_cdfinemp AS INTE                                           NO-UNDO.
DEF VAR aux_dsobserv AS CHAR                                           NO-UNDO.
DEF VAR aux_flgimppr AS INTE                                           NO-UNDO.
DEF VAR aux_dtdpagto AS DATE                                           NO-UNDO.
DEF VAR aux_dsdalien AS CHAR                                           NO-UNDO.
DEF VAR aux_flgerlog AS LOGI                                           NO-UNDO.
DEF VAR aux_dsdopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nrctremp AS DECI                                           NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_rowidavt AS ROWID                                          NO-UNDO.
DEF VAR aux_cdcoploj AS INTE                                           NO-UNDO.
DEF VAR aux_nrctaloj AS INTE                                           NO-UNDO.
DEF VAR aux_dsvended AS CHAR                                           NO-UNDO.
DEF VAR aux_inresapr AS INTE                                           NO-UNDO.
DEF VAR aux_dsjsonan AS LONGCHAR                                       NO-UNDO.
DEF VAR aux_flgdocje AS LOGI                                           NO-UNDO.
DEF VAR aux_nrctaav1 AS INTE                                           NO-UNDO.
DEF VAR aux_nrctaav2 AS INTE                                           NO-UNDO.
    


{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }
{ sistema/generico/includes/b1wgen0201tt.i }

/*................................ PROCEDURES ................................*/

/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/
PROCEDURE valores_entrada:    

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:

            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).             
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).              
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).              
            WHEN "cdoperad" THEN aux_cdoperad = STRING(tt-param.valorCampo).                     
            WHEN "nmdatela" THEN aux_nmdatela = STRING(tt-param.valorCampo).                 
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).  
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).  
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo). 
            WHEN "nrctremp" THEN aux_nrctremp = DECI(tt-param.valorCampo).
            WHEN "inpessoa" THEN aux_inpessoa = INTE(tt-param.valorCampo).
            WHEN "tpemprst" THEN aux_tpemprst = INTE(tt-param.valorCampo).
            WHEN "vlemprst" THEN aux_vlemprst = DECI(tt-param.valorCampo).
            WHEN "vlliqemp" THEN aux_vlliqemp = DECI(tt-param.valorCampo).
            WHEN "vliofepr" THEN aux_vliofepr = DECI(tt-param.valorCampo).
            WHEN "percetop" THEN aux_percetop = DECI(tt-param.valorCampo).
            WHEN "qtpreemp" THEN aux_qtpreemp = INTE(tt-param.valorCampo).
            WHEN "vlpreemp" THEN aux_vlpreemp = DECI(tt-param.valorCampo).
            WHEN "cdlcremp" THEN aux_cdlcremp = INTE(tt-param.valorCampo).
            WHEN "cdfinemp" THEN aux_cdfinemp = INTE(tt-param.valorCampo).
            WHEN "dsobserv" THEN aux_dsobserv = STRING(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "flgimppr" THEN aux_flgimppr = INTE(tt-param.valorCampo).
            WHEN "dtdpagto" THEN aux_dtdpagto = DATE(tt-param.valorCampo).
            WHEN "dsdalien" THEN aux_dsdalien = tt-param.valorCampo.
            WHEN "inresapr" THEN aux_inresapr = INTE(tt-param.valorCampo).            
            WHEN "flgdocje" THEN aux_flgdocje = IF CAN-DO("TRUE,SIM,YES,1", 
                                                          CAPS(tt-param.valorCampo)) THEN TRUE
                                                ELSE FALSE.
            WHEN "cdcoploj" THEN aux_cdcoploj = INTE(tt-param.valorCampo).
            WHEN "nrctaloj" THEN aux_nrctaloj = INTE(tt-param.valorCampo).
            WHEN "dsvended" THEN aux_dsvended = tt-param.valorCampo.            
            WHEN "flgerlog" THEN aux_flgerlog = IF CAN-DO("TRUE,SIM,YES,1", 
                                                          CAPS(tt-param.valorCampo)) THEN TRUE
                                                ELSE FALSE.
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "dsdopcao" THEN aux_dsdopcao = tt-param.valorCampo.
            
        END CASE.
    END. /** Fim do FOR EACH tt-param **/  
    
     FOR EACH tt-param-i 
        BREAK BY tt-param-i.nomeTabela
              BY tt-param-i.sqControle:

        CASE CAPS(tt-param-i.nomeTabela):
            WHEN "AVALISTAS" THEN DO:
            
              IF  FIRST-OF(tt-param-i.sqControle) THEN
                  DO:
                     CREATE tt-avalista.
                     ASSIGN aux_rowidavt = ROWID(tt-avalista).
                  END.
                          
              FIND tt-avalista WHERE ROWID(tt-avalista) = aux_rowidavt
                                     NO-ERROR.

              CASE CAPS(tt-param-i.nomeCampo):
                WHEN "IDENTIFICACAOAVALISTA" THEN
                  tt-avalista.idavalis = INTE(tt-param-i.valorCampo).
                WHEN "COOPERATIVAAVALISTACODIGO" THEN
                  tt-avalista.cdcooper = INTE(tt-param-i.valorCampo).
                WHEN "CONTAAVALISTANUMERO" THEN
                  tt-avalista.nrctaava = DECI(tt-param-i.valorCampo).
                WHEN "CONTAAVALISTADV" THEN
                  tt-avalista.nrdvctav = INTE(tt-param-i.valorCampo).
                WHEN "NOMEAVALISTA" THEN
                  tt-avalista.nmavalis = tt-param-i.valorCampo.
                WHEN "CPFCNPJAVALISTA" THEN
                  tt-avalista.nrcpfcgc = DECI(tt-param-i.valorCampo).
                WHEN "TIPOPESSOA" THEN
                  tt-avalista.tppessoa = INTE(tt-param-i.valorCampo).
                WHEN "DATANASCAVALISTA" THEN
                  tt-avalista.dtnascto = DATE(tt-param-i.valorCampo).
                WHEN "TIPODOCUMENTOAUXAVALISTA" THEN
                  tt-avalista.tpdocava = tt-param-i.valorCampo.
                WHEN "NUMERODOCUMENTOAUXAVALISTA" THEN
                  tt-avalista.nrdocava = tt-param-i.valorCampo.
                WHEN "CEPAVALISTA" THEN
                  tt-avalista.nrcepava = INTE(REPLACE(tt-param-i.valorCampo,"-","")).
                WHEN "ENDERECOAVALISTA" THEN
                  tt-avalista.dsendere = tt-param-i.valorCampo.
                WHEN "NUMEROENDERECOAVALISTA" THEN
                  tt-avalista.nrendere = INTE(tt-param-i.valorCampo).
                WHEN "COMPLEMENTOENDERECOAVALISTA" THEN
                  tt-avalista.dscomple = tt-param-i.valorCampo.
                WHEN "NUMEROCAIXAPOSTALAVALISTA" THEN
                  tt-avalista.nrcxpost = INTE(tt-param-i.valorCampo).
                WHEN "BAIRROAVALISTA" THEN
                  tt-avalista.dsbairro = tt-param-i.valorCampo.
                WHEN "CIDADEAVALISTA" THEN
                  tt-avalista.dscidade = tt-param-i.valorCampo.
                WHEN "UFAVALISTA" THEN
                  tt-avalista.cdufende = tt-param-i.valorCampo.
                WHEN "NACIONALIDADEAVALISTA" THEN
                  tt-avalista.dsnacion = tt-param-i.valorCampo.
                WHEN "NUMEROTELEFONEAVALISTA" THEN
                  tt-avalista.nrtelefo = tt-param-i.valorCampo.
                WHEN "EMAILAVALISTA" THEN
                  tt-avalista.dsdemail = tt-param-i.valorCampo.
                WHEN "VALORRENDIMENTOMENSAL" THEN
                  tt-avalista.vlrenmes = DECI(tt-param-i.valorCampo).
                WHEN "VALORENDIVIDAMENTOMAXIMO" THEN
                  tt-avalista.vlendmax = DECI(tt-param-i.valorCampo).
                WHEN "NOMECONJUGEAVALISTA" THEN
                  tt-avalista.nmconjug = tt-param-i.valorCampo.
                WHEN "CPFCNPJCONJUGE" THEN
                  tt-avalista.nrcpfcon = DECI(tt-param-i.valorCampo).
                WHEN "TIPODOCUMENTOAUXCONJUGE" THEN
                  tt-avalista.tpdoccon = tt-param-i.valorCampo.
                WHEN "NUMERODOCUMENTOAUXCONJUGE" THEN
                  tt-avalista.nrdoccon = tt-param-i.valorCampo.

              END CASE.
              
            END.
        END CASE.
    END.
 
END PROCEDURE.


/******************************************************************************/
/**           Procedure para integrar propostas CDC                          **/
/******************************************************************************/
PROCEDURE integra_proposta:

     RUN integra_proposta IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,                                    
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT aux_inpessoa,
                                  INPUT aux_tpemprst,
                                  INPUT aux_vlemprst,
                                  INPUT aux_vlliqemp,
                                  INPUT aux_vliofepr,
                                  INPUT aux_percetop,
                                  INPUT aux_qtpreemp,
                                  INPUT aux_vlpreemp,
                                  INPUT aux_cdlcremp,
                                  INPUT aux_cdfinemp,
                                  INPUT aux_dsobserv,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_dtmvtopr,
                                  INPUT aux_flgimppr,
                                  INPUT aux_dtdpagto,
                                  INPUT aux_dsdalien,
                                  INPUT aux_cddopcao,
                                  INPUT aux_inresapr,
                                  INPUT aux_cdcoploj,
                                  INPUT aux_nrctaloj,
                                  INPUT aux_dsvended,
                                  INPUT aux_flgdocje,
                                  
                                 INPUT-OUTPUT aux_nrctremp,
                                 OUTPUT aux_nrctaav1,
                                 OUTPUT aux_nrctaav2,
                                 OUTPUT aux_dsjsonan,
                                 OUTPUT TABLE tt-erro) NO-ERROR.
       
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Erro geral no sistema.".
               END.
           ELSE
             DO:
                RUN fontes/substitui_caracter.p
                                    (INPUT-OUTPUT tt-erro.dscritic). 
             END.
               
    
             
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.    
    ELSE
        DO:
        
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nrctremp", INPUT aux_nrctremp).
            RUN piXmlAtributo (INPUT "nrctaav1", INPUT aux_nrctaav1).
            RUN piXmlAtributo (INPUT "nrctaav2", INPUT aux_nrctaav2).
            RUN piXmlAtributo (INPUT "dsjsonan", INPUT aux_dsjsonan).
            RUN piXmlSave.
        END.    

END PROCEDURE.    

PROCEDURE integra_dados_avalista:

  RUN integra_dados_avalista IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nmdatela,
                                     INPUT aux_idorigem,
                                     INPUT aux_nrdconta,
                                     INPUT aux_idseqttl,
                                     INPUT aux_nrctremp,
                                     INPUT aux_flgerlog,
                                     INPUT aux_dsdopcao,
                                     INPUT aux_inresapr,
                                     INPUT TABLE tt-avalista,
                                    OUTPUT aux_nrctaav1,
                                    OUTPUT aux_nrctaav2,
                                    OUTPUT aux_dsjsonan, 
                                    OUTPUT TABLE tt-erro) NO-ERROR.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
               
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Erro geral no sistema.".
  END.
           ELSE
               DO:
                RUN fontes/substitui_caracter.p
                                    (INPUT-OUTPUT tt-erro.dscritic). 
               END.
    
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.    
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nrctaav1", INPUT aux_nrctaav1).
            RUN piXmlAtributo (INPUT "nrctaav2", INPUT aux_nrctaav2).
            RUN piXmlAtributo (INPUT "dsjsonan", INPUT aux_dsjsonan).
            RUN piXmlSave.
        END.    


END PROCEDURE.