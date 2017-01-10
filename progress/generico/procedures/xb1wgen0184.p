
/*............................................................................

     Programa: sistema/generico/procedures/xb1wgen0184.p
     Autor   : JÈssica Laverde Gracino (DB1)
     Data    : 19/02/2014                    Ultima atualizacao: 00/00/0000

     Objetivo  : BO de Comunicacao XML x BO - Tela LISLOT

     Alteracoes: 06/12/2016 - P341-AutomatizaÁ„o BACENJUD - Alterar a passagem da descriÁ„o do 
                              departamento como parametro e passar o o cÛdigo (Renato Darosci)

............................................................................*/


/*..........................................................................*/

DEF VAR aux_cdcooper AS INTE                                         NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                         NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                         NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                         NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                         NO-UNDO.
DEF VAR aux_idorigem AS INTE                                         NO-UNDO.
DEF VAR aux_cddepart AS INTE                                         NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                         NO-UNDO.   
DEF VAR aux_tpdopcao AS CHAR                                         NO-UNDO.
DEF VAR aux_cdhistor AS INTE                                         NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                         NO-UNDO.
DEF VAR aux_dtinicio AS DATE                                         NO-UNDO.
DEF VAR aux_dttermin AS DATE                                         NO-UNDO.
DEF VAR aux_nrregist AS INTE                                         NO-UNDO.    
DEF VAR aux_nriniseq AS INTE                                         NO-UNDO.

DEF VAR aux_dsiduser AS CHAR                                         NO-UNDO.
DEF VAR aux_nmdopcao AS LOGI                                         NO-UNDO.
DEF VAR aux_nmdireto AS CHAR                                         NO-UNDO.

DEF VAR aux_nmarqimp AS CHAR                                         NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                         NO-UNDO.

DEF VAR aux_qtregist AS INTE                                         NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                         NO-UNDO.
DEF VAR aux_vllanmto AS DECI FORMAT ">>>,>>>,>>9.99"                 NO-UNDO.
DEF VAR aux_registro AS INTE                                         NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0184tt.i }

/*............................... PROCEDURES ................................*/

PROCEDURE valores_entrada:

     FOR EACH tt-param:

         CASE tt-param.nomeCampo:

             WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
             WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
             WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
             WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
             WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
             WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
             WHEN "cddepart" THEN aux_cddepart = INTE(tt-param.valorCampo).
             WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
             WHEN "tpdopcao" THEN aux_tpdopcao = tt-param.valorCampo.
             WHEN "cdhistor" THEN aux_cdhistor = INTE(tt-param.valorCampo).
             WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
             WHEN "dtinicio" THEN aux_dtinicio = DATE(tt-param.valorCampo).
             WHEN "dttermin" THEN aux_dttermin = DATE(tt-param.valorCampo).
             WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
             WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
             WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.
             WHEN "nmdopcao" THEN aux_nmdopcao = LOGICAL(tt-param.valorCampo).
             WHEN "nmdireto" THEN aux_nmdireto = tt-param.valorCampo.
             WHEN "nmarqimp" THEN aux_nmarqimp = tt-param.valorCampo.
             WHEN "nmarqpdf" THEN aux_nmarqpdf = tt-param.valorCampo.

         END CASE.

     END. /** Fim do FOR EACH tt-param **/


END PROCEDURE. /* valores_entrada */


/* -------------------------------------------------------------------------- */
/*                      EFETUA A PESQUISA DOS HISTORICOS                      */
/* -------------------------------------------------------------------------- */
PROCEDURE Busca_Dados:

    RUN Busca_Dados IN hBO
                  (  INPUT aux_cdcooper,    
                     INPUT aux_cdagenci,               
                     INPUT aux_nrdcaixa,               
                     INPUT aux_cdoperad,               
                     INPUT aux_nmdatela,               
                     INPUT aux_idorigem,               
                     INPUT aux_cddepart,               
                     INPUT aux_dtmvtolt,
                     INPUT aux_cddopcao,               
                     INPUT aux_tpdopcao,
                     INPUT aux_cdhistor,               
                     INPUT aux_nrdconta,
                     INPUT aux_dtinicio,
                     INPUT aux_dttermin,
                     INPUT aux_nrregist,               
                     INPUT aux_nriniseq,
                     INPUT TRUE,                       
                    OUTPUT aux_qtregist,               
                    OUTPUT aux_nmdcampo,  
                    OUTPUT aux_vllanmto,
                    OUTPUT aux_registro,
                    OUTPUT TABLE tt-lislot,
                    OUTPUT TABLE tt-lislot-aux,
                    OUTPUT TABLE tt-retorno,
                    OUTPUT TABLE tt-craplcx,
                    OUTPUT TABLE tt-craplcx-aux,
                    OUTPUT TABLE tt-craplcm,    
                    OUTPUT TABLE tt-craplcm-aux,
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
           RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlExport (INPUT TEMP-TABLE tt-lislot-aux:HANDLE,
                            INPUT "Dados").
           RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
           RUN piXmlAtributo (INPUT "vllanmto",INPUT DECIMAL(aux_vllanmto)).
           RUN piXmlExport (INPUT TEMP-TABLE tt-retorno:HANDLE,
                            INPUT "Retorno").
           RUN piXmlExport (INPUT TEMP-TABLE tt-craplcx-aux:HANDLE,
                            INPUT "Caixa").
           RUN piXmlExport (INPUT TEMP-TABLE tt-craplcm-aux:HANDLE,
                            INPUT "Lote").
           
           RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Dados */

/* -------------------------------------------------------------------------- */
/*              EFETUA A IMPRESS„O DOS HISTORICOS OPCAO COOPERADO             */
/* -------------------------------------------------------------------------- */
PROCEDURE Gera_Impressao:

     RUN Gera_Impressao IN hBO
                    (   INPUT aux_cdcooper,          
                        INPUT aux_cdagenci,          
                        INPUT aux_nrdcaixa,          
                        INPUT aux_cdoperad,          
                        INPUT aux_nmdatela,          
                        INPUT 5,                     
                        INPUT aux_cddepart,          
                        INPUT aux_dtmvtolt,          
                        INPUT aux_cddopcao,          
                        INPUT aux_tpdopcao,          
                        INPUT aux_nrdconta,          
                        INPUT aux_dtinicio,          
                        INPUT aux_dttermin,          
                        INPUT TRUE,                  
                        INPUT aux_dsiduser,          
                        INPUT aux_nmdopcao,          
                        INPUT aux_cdhistor,         
                       OUTPUT aux_nmarqimp,          
                       OUTPUT aux_nmarqpdf,
                       OUTPUT aux_nmdireto,
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
           RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
           RUN piXmlAtributo (INPUT "nmarqimp",INPUT STRING(aux_nmarqimp)).
           RUN piXmlAtributo (INPUT "nmdireto",INPUT aux_nmdireto).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Gera_Impressao */














    



