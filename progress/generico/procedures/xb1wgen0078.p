/*.............................................................................

    Programa: sistema/generico/procedures/xb1wgen0078.p
    Autor   : David
    Data    : Marco/2011                      Ultima atualizacao: 00/00/0000

    Dados referentes ao programa:

    Objetivo  : BO de Comunicacao XML Vs BO de rotinas DDA (b1wgen0078.p).

    Alteracoes: 	
	
				25/10/2017 -  Ajustado para especificar adesão de DDA pelo Mobile
							  PRJ356.4 - DDA (Ricardo Linhares)
    
.............................................................................*/
                                                                            
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagecxa AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_nritmini AS INTE                                           NO-UNDO.
DEF VAR aux_nritmfin AS INTE                                           NO-UNDO.
DEF VAR aux_qterrdda AS INTE                                           NO-UNDO.
DEF VAR aux_cdopecxa AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_dtmvtlog AS DATE                                           NO-UNDO.
DEF VAR aux_nmdtest1 AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdtest2 AS CHAR                                           NO-UNDO.
DEF VAR aux_cpftest1 AS DECI                                           NO-UNDO.
DEF VAR aux_cpftest2 AS DECI                                           NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                           NO-UNDO.
DEF VAR aux_dtvenini AS DATE                                           NO-UNDO.
DEF VAR aux_dtvenfin AS DATE                                           NO-UNDO.
DEF VAR aux_cdsittit AS INTE                                           NO-UNDO.
DEF VAR aux_idordena AS INTE                                           NO-UNDO.
DEF VAR aux_nrcpftes AS DECI                                           NO-UNDO.

DEF VAR par_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR par_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR par_qttitulo AS INTE                                           NO-UNDO.
DEF VAR par_flgverif AS LOGI                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0078tt.i }
{ sistema/generico/includes/b1wgen0079tt.i }
{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 

                                             
/*................................ PROCEDURES ...............................*/


/*****************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML    **/
/*****************************************************************************/
PROCEDURE valores_entrada:

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagecxa" THEN aux_cdagecxa = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdopecxa" THEN aux_cdopecxa = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "nritmini" THEN aux_nritmini = INTE(tt-param.valorCampo).
            WHEN "nritmfin" THEN aux_nritmfin = INTE(tt-param.valorCampo).
            WHEN "qterrdda" THEN aux_qterrdda = INTE(tt-param.valorCampo).
            WHEN "dtmvtlog" THEN aux_dtmvtlog = DATE(tt-param.valorCampo).
            WHEN "nmdtest1" THEN aux_nmdtest1 = tt-param.valorCampo.
            WHEN "nmdtest2" THEN aux_nmdtest2 = tt-param.valorCampo.
            WHEN "cpftest1" THEN aux_cpftest1 = DECI(tt-param.valorCampo).
            WHEN "cpftest2" THEN aux_cpftest2 = DECI(tt-param.valorCampo).
            WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.
            WHEN "dtvenini" THEN aux_dtvenini = DATE(tt-param.valorCampo).
            WHEN "dtvenfin" THEN aux_dtvenfin = DATE(tt-param.valorCampo). 
            WHEN "cdsittit" THEN aux_cdsittit = INTE(tt-param.valorCampo).
            WHEN "idordena" THEN aux_idordena = INTE(tt-param.valorCampo).
            WHEN "nrcpftes" THEN aux_nrcpftes = DECI(tt-param.valorCampo).

        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.    


/*****************************************************************************/
/**      Procedure para consultar lista de erros que ocorreram no JDDDA     **/
/*****************************************************************************/
PROCEDURE lista-erros-dda:

    RUN lista-erros-dda IN hBO (INPUT aux_cdcooper,
                                INPUT aux_cdagecxa,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdopecxa,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT aux_dtmvtlog,
                                INPUT aux_nritmini,
                                INPUT aux_nritmfin,
                               OUTPUT aux_qterrdda,
                               OUTPUT TABLE tt-logdda,
                               OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-logdda:HANDLE,
                             INPUT "Dados").
            RUN piXmlAtributo (INPUT "qterrdda", INPUT STRING(aux_qterrdda)).
            RUN piXmlSave.
        END.

END PROCEDURE.


/****************************************************************************
 Procedure que mostra os dados do sacado eletronico. Rotina de DDA na CONTAS
*****************************************************************************/
PROCEDURE consulta-sacado-eletronico:

    RUN consulta-sacado-eletronico IN hBo (INPUT aux_cdcooper,
                                           INPUT aux_cdagecxa,
                                           INPUT aux_nrdcaixa,
                                           INPUT aux_cdopecxa,
                                           INPUT aux_nmdatela,
                                           INPUT aux_idorigem,
                                           INPUT aux_nrdconta,
                                           INPUT aux_idseqttl,
                                           INPUT aux_dtmvtolt,
                                           INPUT TRUE,
                                          OUTPUT TABLE tt-erro,
                                          OUTPUT TABLE tt-sacado-eletronico).

    IF   RETURN-VALUE <> "OK"   THEN
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
             RUN piXmlExport (INPUT TEMP-TABLE tt-sacado-eletronico:HANDLE,
                              INPUT "Sacado").
             RUN piXmlSave.
         END.
         
END PROCEDURE.


/*****************************************************************************
 Incluir o titular da conta como sacado eletronico.
*****************************************************************************/
PROCEDURE aderir-sacado:

    RUN aderir-sacado IN hBo (INPUT aux_cdcooper,
                              INPUT aux_cdagecxa,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdopecxa,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_nrdconta,
                              INPUT aux_idseqttl,
                              INPUT aux_dtmvtolt,
                              INPUT TRUE,
                              INPUT 0,
                             OUTPUT TABLE tt-erro).

    IF   RETURN-VALUE <> "OK"   THEN
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

END PROCEDURE.


/******************************************************************************
 Encerrar a adesao ao DDA do cooperado
******************************************************************************/
PROCEDURE encerrar-sacado-dda:

    RUN encerrar-sacado-dda IN hBo (INPUT aux_cdcooper,  
                                    INPUT aux_cdagecxa,  
                                    INPUT aux_nrdcaixa,  
                                    INPUT aux_cdopecxa,  
                                    INPUT aux_nmdatela,  
                                    INPUT aux_idorigem,  
                                    INPUT aux_nrdconta,  
                                    INPUT aux_idseqttl,  
                                    INPUT aux_dtmvtolt,  
                                    INPUT TRUE,          
                                   OUTPUT TABLE tt-erro).

    IF   RETURN-VALUE <> "OK"   THEN
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

END PROCEDURE.

/*****************************************************************************
 Trazer o nome da testemunha se o CPF dele é de cooperado
*****************************************************************************/
PROCEDURE traz-nome-testemunha :

    RUN traz-nome-testemunha IN hBo (INPUT aux_cdcooper,
                                     INPUT aux_nrcpftes,
                                    OUTPUT TABLE tt-testemunha).

    RUN piXmlNew.
    RUN piXmlExport (INPUT TEMP-TABLE tt-testemunha:HANDLE,
                     INPUT "Testemunha").
    RUN piXmlSave.

END PROCEDURE.

/*****************************************************************************
 Validar os CPF das testemunhas para a impressao do termo de adesao
*****************************************************************************/
PROCEDURE valida-cpf-testemunhas:

    RUN valida-cpf-testemunhas IN hBo (INPUT aux_cdcooper,
                                       INPUT aux_cdagecxa,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdopecxa,
                                       INPUT aux_nmdatela,
                                       INPUT aux_idorigem,
                                       INPUT aux_nrdconta,
                                       INPUT aux_nmdtest1,
                                       INPUT aux_cpftest1,
                                       INPUT aux_nmdtest2,
                                       INPUT aux_cpftest2,
                                       INPUT aux_idseqttl,
                                       INPUT aux_dtmvtolt,
                                       INPUT TRUE,
                                      OUTPUT TABLE tt-erro).

    IF   RETURN-VALUE <> "OK"   THEN
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
         
END PROCEDURE.


/*****************************************************************************
 Efetuar a impressao do termo de adesao.
*****************************************************************************/
PROCEDURE imprime-termo-adesao:

    RUN imprime-termo-adesao IN hBo (INPUT aux_cdcooper,
                                     INPUT aux_cdagecxa,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdopecxa,
                                     INPUT aux_nmdatela,
                                     INPUT aux_idorigem,
                                     INPUT aux_nrdconta,
                                     INPUT aux_nmdtest1,
                                     INPUT aux_cpftest1,
                                     INPUT aux_nmdtest2,
                                     INPUT aux_cpftest2,
                                     INPUT aux_dsiduser,
                                     INPUT aux_idseqttl,
                                     INPUT aux_dtmvtolt,
                                     INPUT TRUE,
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT par_nmarqimp,
                                    OUTPUT par_nmarqpdf).

     IF   RETURN-VALUE <> "OK"   THEN
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
              RUN piXmlAtributo (INPUT "nmarqpdf", INPUT STRING(par_nmarqpdf)).
              RUN piXmlSave.
          END.

END PROCEDURE.


/*****************************************************************************
 Efetuar a impressao do termo de exclusao.
*****************************************************************************/
PROCEDURE imprime-termo-exclusao:

    RUN imprime-termo-exclusao IN hBo (INPUT aux_cdcooper,
                                       INPUT aux_cdagecxa,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdopecxa,
                                       INPUT aux_nmdatela,
                                       INPUT aux_idorigem,
                                       INPUT aux_nrdconta,
                                       INPUT aux_nmdtest1,
                                       INPUT aux_cpftest1,
                                       INPUT aux_nmdtest2,
                                       INPUT aux_cpftest2,
                                       INPUT aux_dsiduser,
                                       INPUT aux_idseqttl,
                                       INPUT aux_dtmvtolt,
                                       INPUT TRUE,
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT par_nmarqimp,
                                      OUTPUT par_nmarqpdf).

     IF   RETURN-VALUE <> "OK"   THEN
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
              RUN piXmlAtributo (INPUT "nmarqpdf", INPUT STRING(par_nmarqpdf)).
              RUN piXmlSave.
          END.

END PROCEDURE.


/****************************************************************************
 Efetuar a verificacao se o CPF/CNPJ é um sacado eletronico na base JDDDA  
****************************************************************************/
PROCEDURE verifica-sacado:

    RUN verifica-sacado IN hBo (INPUT aux_cdcooper,
                                INPUT aux_cdagecxa,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdopecxa,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT aux_nrdconta,
                                INPUT aux_idseqttl,
                                INPUT TRUE,
                               OUTPUT TABLE tt-erro,
                               OUTPUT par_flgverif).

    IF   RETURN-VALUE <> "OK"   THEN
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
             RUN piXmlAtributo (INPUT "flgverif", INPUT STRING(par_flgverif)).
             RUN piXmlSave.
         END.

END PROCEDURE.


/***************************************************************************
 Trazer todos os titulos bloqueados.
***************************************************************************/
PROCEDURE lista-grupo-titulos-sacado:

    RUN lista-grupo-titulos-sacado IN hBo 
                                (INPUT aux_cdcooper,
                                 INPUT aux_cdagecxa,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdopecxa,
                                 INPUT aux_nmdatela,
                                 INPUT aux_idorigem,
                                 INPUT aux_nrdconta,
                                 INPUT aux_idseqttl,
                                 INPUT aux_dtvenini,
                                 INPUT aux_dtvenfin,
                                 INPUT aux_cdsittit,
                                 INPUT aux_idordena,
                                 INPUT TRUE,
                                OUTPUT par_qttitulo,
                                OUTPUT TABLE tt-grupo-titulos-sacado-dda,
                                OUTPUT TABLE tt-grupo-instr-tit-sacado-dda,
                                OUTPUT TABLE tt-grupo-descto-tit-sacado-dda,
                                OUTPUT TABLE tt-erro). 

    IF   RETURN-VALUE <> "OK"   THEN
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
             RUN piXmlExport (INPUT TEMP-TABLE tt-grupo-titulos-sacado-dda:HANDLE,
                              INPUT "Titulos").
             RUN piXmlExport (INPUT TEMP-TABLE tt-grupo-instr-tit-sacado-dda:HANDLE,
                              INPUT "Instrucoes").
             RUN piXmlExport (INPUT TEMP-TABLE tt-grupo-descto-tit-sacado-dda:HANDLE,
                              INPUT "Desconto").
             RUN piXmlSave.   
         END.

END PROCEDURE.

/*...........................................................................*/

