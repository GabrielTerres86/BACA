/*..............................................................................

   Programa: xb1wgen0153.p
   Autor   : Tiago Machado 
   Data    : Fevereiro/2014                   Ultima atualizacao: 11/10/2016

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO183 (b1wgen0183.p) 

   Alteracoes: 11/10/2016 - Acesso da tela HRCOMP em todas cooperativas SD381526 (Tiago/Elton)

               06/12/2016 - P341-Automatização BACENJUD - Alterar a passagem da descrição do 
                            departamento como parametro e passar o código (Renato Darosci)
..............................................................................*/

DEF VAR aux_cdcooper AS INTE                                        NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                        NO-UNDO.             
DEF VAR aux_nrdcaixa AS INTE                                        NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                        NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                        NO-UNDO.
DEF VAR aux_idorigem AS INTE                                        NO-UNDO.
DEF VAR aux_cddepart AS INTE                                        NO-UNDO.
DEF VAR aux_cdcoopex AS INTE                                        NO-UNDO.
DEF VAR aux_flgativo AS CHAR                                        NO-UNDO.
DEF VAR aux_nmproces AS CHAR                                        NO-UNDO.
DEF VAR aux_ageinihr AS INTE                                        NO-UNDO.
DEF VAR aux_ageinimm AS INTE                                        NO-UNDO.
DEF VAR aux_agefimhr AS INTE                                        NO-UNDO.
DEF VAR aux_agefimmm AS INTE                                        NO-UNDO.
DEF VAR aux_cddopcao AS CHAR										NO-UNDO.

{ sistema/generico/includes/b1wgen0183tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }

/* .........................PROCEDURES................................... */

/**************************************************************************
       Procedure para atribuicao dos dados de entrada enviados por XML
**************************************************************************/
PROCEDURE valores_entrada:
    

    FOR EACH tt-param NO-LOCK:
    /*    MESSAGE "183 XBO " tt-param.nomeCampo tt-param.valorCampo. */   
        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).           
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo). 
            WHEN "cddepart" THEN aux_cddepart = INTE(tt-param.valorCampo).
            WHEN "cdcoopex" THEN aux_cdcoopex = INTE(tt-param.valorCampo).
            WHEN "nmproces" THEN aux_nmproces = tt-param.valorCampo.
            WHEN "flgativo" THEN aux_flgativo = tt-param.valorCampo.
            WHEN "ageinihr" THEN aux_ageinihr = INTE(tt-param.valorCampo).
            WHEN "ageinimm" THEN aux_ageinimm = INTE(tt-param.valorCampo).
            WHEN "agefimhr" THEN aux_agefimhr = INTE(tt-param.valorCampo).
            WHEN "agefimmm" THEN aux_agefimmm = INTE(tt-param.valorCampo).
			WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
        END CASE.
                                                                    
    END. /** Fim do FOR EACH tt-param **/
    
END PROCEDURE.

/******************************************************************************/
/* busca os horarios que os arquivos devem ser processados dependendo da coop */
/******************************************************************************/
PROCEDURE busca_dados:

    RUN busca_dados IN hBO(INPUT  aux_cdcooper,
                           INPUT  aux_cdagenci,
                           INPUT  aux_nrdcaixa,
                           INPUT  aux_cdoperad,
                           INPUT  aux_nmdatela,
                           INPUT  aux_cddepart,
                           INPUT  aux_idorigem,
                           INPUT  aux_dtmvtolt,
                           INPUT  aux_cdcoopex,
                           OUTPUT TABLE tt-processos,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-processos:HANDLE,
                             INPUT "Processos").
            RUN piXmlSave.
        END.         

END PROCEDURE.

PROCEDURE carrega_cooperativas:

    RUN carrega_cooperativas 
                    IN hBO(INPUT  aux_cdcooper,
                           INPUT  aux_cdagenci,
                           INPUT  aux_nrdcaixa,
                           INPUT  aux_cdoperad,
                           INPUT  aux_nmdatela,
                           INPUT  aux_cddepart,
                           INPUT  aux_idorigem,
                           INPUT  aux_dtmvtolt,
                           OUTPUT TABLE tt-coop,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-coop:HANDLE,
                             INPUT "Cooperativas").
            RUN piXmlSave.
        END.         

END PROCEDURE.

/******************************************************************************/
/* grava os horarios que os arquivos devem ser processados dependendo da coop */
/******************************************************************************/
PROCEDURE grava_dados:

    DEF VAR log_flgativo    AS  LOGICAL                             NO-UNDO.

    IF  aux_flgativo = "N" THEN
        ASSIGN log_flgativo = FALSE.
    ELSE
        ASSIGN log_flgativo = TRUE.

    RUN grava_dados IN hBO(INPUT  aux_cdcooper,
                           INPUT  aux_cdagenci,
                           INPUT  aux_nrdcaixa,
                           INPUT  aux_cdoperad,
                           INPUT  aux_nmdatela,
                           INPUT  aux_cddepart,
                           INPUT  aux_idorigem,
                           INPUT  aux_dtmvtolt,
                           INPUT  aux_cdcoopex,
                           INPUT  aux_nmproces,
                           INPUT  log_flgativo,
                           INPUT  aux_ageinihr,
                           INPUT  aux_ageinimm,
                           INPUT  aux_agefimhr,
                           INPUT  aux_agefimmm,
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-processos:HANDLE,
                             INPUT "Processos").
            RUN piXmlSave.
        END.         

END PROCEDURE.


/******************************************************************************/
/* verificar o acesso  as opcoes da tela por departamento                     */
/******************************************************************************/
PROCEDURE acesso_opcao:

    RUN acesso_opcao IN hBO(INPUT  aux_cdcooper,
                            INPUT  aux_cdagenci,                            
							INPUT  aux_cddepart,
							INPUT  aux_cddopcao,
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
                            INPUT "ERRO").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.         

END PROCEDURE.
