/*............................................................................

     Programa: sistema/generico/procedures/xb1wgen0185.p
     Autor   : Jéssica Laverde Gracino (DB1)
     Data    : 24/02/2014                    Ultima atualizacao: 21/01/2015

     Objetivo  : BO de Comunicacao XML x BO - Tela MOVTOS

     Alteracoes: 21/01/2015 - Ajustes para liberacao (Adriano).

	             06/12/2016 - P341-Automatização BACENJUD - Alterar a passagem da descrição do 
                              departamento como parametro e passar o o código (Renato Darosci)
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
DEF VAR aux_tppessoa AS INTE                                         NO-UNDO.
DEF VAR aux_cdultrev AS INTE                                         NO-UNDO.
DEF VAR aux_dtinicio AS DATE                                         NO-UNDO.
DEF VAR aux_ddtfinal AS DATE                                         NO-UNDO.
DEF VAR aux_cdempres AS INTE                                         NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                         NO-UNDO.
DEF VAR aux_nmarqint AS CHAR                                         NO-UNDO.
DEF VAR aux_tpcontas AS CHAR                                         NO-UNDO.
DEF VAR aux_tpdopcao AS CHAR                                         NO-UNDO.
DEF VAR aux_dsadmcrd AS CHAR                                         NO-UNDO.
DEF VAR aux_tpdomvto AS CHAR                                         NO-UNDO.
DEF VAR aux_lgvisual AS CHAR                                         NO-UNDO.
DEF VAR aux_situacao AS CHAR                                         NO-UNDO.
DEF VAR aux_cdagenca AS INTE                                         NO-UNDO.

DEF VAR aux_dsiduser AS CHAR                                         NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                         NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                         NO-UNDO.
DEF VAR aux_nomedarq AS CHAR                                         NO-UNDO.
DEF VAR aux_linhacre AS CHAR                                         NO-UNDO.
DEF VAR aux_finalida AS CHAR                                         NO-UNDO.

DEF VAR aux_nrregist AS INTE                                         NO-UNDO.    
DEF VAR aux_nriniseq AS INTE                                         NO-UNDO.
                                                                     
DEF VAR aux_qtregist AS INTE                                         NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                         NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0185tt.i }

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
             WHEN "tppessoa" THEN aux_tppessoa = INTE(tt-param.valorCampo).     
             WHEN "cdultrev" THEN aux_cdultrev = INTE(tt-param.valorCampo).     
             WHEN "dtinicio" THEN aux_dtinicio = DATE(tt-param.valorCampo).     
             WHEN "ddtfinal" THEN aux_ddtfinal = DATE(tt-param.valorCampo).     
             WHEN "cdempres" THEN aux_cdempres = INTE(tt-param.valorCampo).     
             WHEN "nmarquiv" THEN aux_nmarquiv = tt-param.valorCampo.           
             WHEN "nmarqint" THEN aux_nmarqint = tt-param.valorCampo.           
             WHEN "tpcontas" THEN aux_tpcontas = tt-param.valorCampo.           
             WHEN "tpdopcao" THEN aux_tpdopcao = tt-param.valorCampo.           
             WHEN "dsadmcrd" THEN aux_dsadmcrd = tt-param.valorCampo.           
             WHEN "tpdomvto" THEN aux_tpdomvto = tt-param.valorCampo.  
             WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
             WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
             WHEN "lgvisual" THEN aux_lgvisual = tt-param.valorCampo.
             WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.
             WHEN "nmarqimp" THEN aux_nmarqimp = tt-param.valorCampo.
             WHEN "nmarqpdf" THEN aux_nmarqpdf = tt-param.valorCampo.
             WHEN "situacao" THEN aux_situacao = tt-param.valorCampo.
             WHEN "cdagenca" THEN aux_cdagenca = INTE(tt-param.valorCampo).
             WHEN "nomedarq" THEN aux_nomedarq = tt-param.valorCampo.
             WHEN "linhacre" THEN aux_linhacre = tt-param.valorCampo.
             WHEN "finalida" THEN aux_finalida = tt-param.valorCampo.
             WHEN "inproces" THEN aux_inproces = INTE(tt-param.valorCampo).
             
         END CASE.

     END. /** Fim do FOR EACH tt-param **/


END PROCEDURE. /* valores_entrada */

/* -------------------------------------------------------------------------- */
/*              EFETUA A IMPRESSãO DOS HISTORICOS OPCAO COOPERADO             */
/* -------------------------------------------------------------------------- */
PROCEDURE Gera_Impressao:
                   
     RUN Gera_Impressao IN hBO
                    (   INPUT aux_cdcooper,     
                        INPUT aux_cdagenci,     
                        INPUT aux_nrdcaixa,     
                        INPUT aux_cdoperad,     
                        INPUT aux_nmdatela,     
                        INPUT aux_idorigem,  
                        INPUT aux_inproces,
                        INPUT aux_cddepart,     
                        INPUT aux_dtmvtolt,     
                        INPUT aux_cddopcao,     
                        INPUT aux_tpdopcao,     
                        INPUT aux_dtinicio,     
                        INPUT TRUE,             
                        INPUT aux_dsiduser,     
                        INPUT aux_cdempres,     
                        INPUT aux_tppessoa,     
                        INPUT aux_dtmvtopr,     
                        INPUT aux_lgvisual,     
                        INPUT aux_ddtfinal,     
                        INPUT aux_cdultrev,     
                        INPUT aux_tpcontas,     
                        INPUT aux_dsadmcrd,    
                        INPUT aux_tpdomvto,    
                        INPUT aux_situacao,  
                        INPUT aux_linhacre,          
                        INPUT aux_finalida,
                        INPUT aux_cdagenca,    
                        INPUT aux_nmarquiv,    
                       OUTPUT aux_nmarqimp,                       
                       OUTPUT aux_nmarqpdf,    
                       OUTPUT TABLE tt-cartoes,
                       OUTPUT TABLE tt-erro).  
                     
        IF RETURN-VALUE <> "OK" THEN
           DO:
              FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
              IF NOT AVAILABLE tt-erro  THEN
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
              RUN piXmlSave.
           END.

END PROCEDURE. /* Gera_Impressao */

/* -------------------------------------------------------------------------- */
/*                      EFETUA A PESQUISA DOS HISTORICOS                      */
/* -------------------------------------------------------------------------- */
PROCEDURE busca_linhas_finalidades:
                     
    RUN busca_linhas_finalidades IN hBO(INPUT aux_cdcooper,             
                                        INPUT aux_cdagenci,             
                                        INPUT aux_nrdcaixa,             
                                        INPUT aux_cdoperad,             
                                        INPUT aux_nmdatela,             
                                        INPUT aux_idorigem,             
                                        INPUT aux_cddepart,             
                                        INPUT aux_dtmvtolt,             
                                        INPUT aux_nrregist,             
                                        INPUT aux_nriniseq,             
                                        INPUT TRUE, /*flgerlog*/
                                        OUTPUT aux_qtregist,
                                        OUTPUT aux_nmdcampo,
                                        OUTPUT TABLE tt-lincred,        
                                        OUTPUT TABLE tt-finalidade,
                                        OUTPUT TABLE tt-erro).  
                             
    IF RETURN-VALUE <> "OK" THEN 
       DO: 
          FIND FIRST tt-erro NO-LOCK NO-ERROR. 
   
          IF NOT AVAILABLE tt-erro  THEN 
             DO:   
                CREATE tt-erro.  
                ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " + 
                                          "busca dos dados.". 
             END.                                                

          RUN piXmlNew.                                              
          RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE, INPUT "Erro").
          RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
          RUN piXmlSave.               
                               
       END.              
    ELSE
       DO:  
          RUN piXmlNew.   
          RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)). 
          RUN piXmlExport (INPUT TEMP-TABLE tt-lincred:HANDLE,INPUT "Lincred").
          RUN piXmlExport (INPUT TEMP-TABLE tt-finalidade:HANDLE,
                           INPUT "Finalidade").
          RUN piXmlSave.
       END.               
    
END PROCEDURE. /* Busca_Dados */
