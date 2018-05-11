/*............................................................................

     Programa: sistema/generico/procedures/xb1wgen0179.p
     Autor   : Jéssica Laverde Gracino (DB1)
     Data    : 02/10/2013                    Ultima atualizacao: 10/03/2016

     Objetivo  : BO de Comunicacao XML x BO - Tela HISTOR

     Alteracoes: 10/03/2016 - Homologacao e ajustes da conversao da tela 
                              HISTOR para WEB (Douglas - Chamado 412552)

		         06/12/2016 - P341-Automatização BACENJUD - Alterar a passagem 
				              da descrição do departamento como parametro e 
							  passar o o código (Renato Darosci)

                 05/12/2017 - Melhoria 458 adicionado campo inmonpld - Antonio R. Jr (Mouts)
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
DEF VAR aux_cdhistor AS INTE                                         NO-UNDO.    
DEF VAR aux_dshistor AS CHAR                                         NO-UNDO.    

DEF VAR aux_tpltmvpq AS INTE                                         NO-UNDO.
DEF VAR aux_cdhinovo AS INTE                                         NO-UNDO.

DEF VAR aux_flgclass AS LOGI                                         NO-UNDO. 
DEF VAR aux_nrregist AS INTE                                         NO-UNDO.    
DEF VAR aux_nriniseq AS INTE                                         NO-UNDO.
DEF VAR aux_indebcre AS CHAR                                         NO-UNDO.

DEF VAR aux_dsiduser AS CHAR                                         NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                         NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                         NO-UNDO.

DEF VAR aux_qtregist AS INTE                                         NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                         NO-UNDO.

DEF VAR aux_cdhstctb AS INTE                                         NO-UNDO.
DEF VAR aux_dsexthst AS CHAR                                         NO-UNDO.
DEF VAR aux_inautori AS INTE                                         NO-UNDO.
DEF VAR aux_inavisar AS INTE                                         NO-UNDO.
DEF VAR aux_inclasse AS INTE                                         NO-UNDO.
DEF VAR aux_incremes AS INTE                                         NO-UNDO.
DEF VAR aux_inmonpld AS INTE                                         NO-UNDO.
DEF VAR aux_indcompl AS INTE                                         NO-UNDO.
DEF VAR aux_indebcta AS INTE                                         NO-UNDO.
DEF VAR aux_indoipmf AS INTE                                         NO-UNDO.
DEF VAR aux_inhistor AS INTE                                         NO-UNDO.
DEF VAR aux_nmestrut AS CHAR                                         NO-UNDO.
DEF VAR aux_nrctacrd AS INTE                                         NO-UNDO.
DEF VAR aux_nrctatrc AS INTE                                         NO-UNDO.
DEF VAR aux_nrctadeb AS INTE                                         NO-UNDO.
DEF VAR aux_nrctatrd AS INTE                                         NO-UNDO.
DEF VAR aux_tpctbccu AS INTE                                         NO-UNDO.
DEF VAR aux_tplotmov AS INTE                                         NO-UNDO.
DEF VAR aux_tpctbcxa AS INTE                                         NO-UNDO.
DEF VAR aux_ingercre AS INTE                                         NO-UNDO.
DEF VAR aux_ingerdeb AS INTE                                         NO-UNDO.
DEF VAR aux_flgsenha AS LOGI                                         NO-UNDO.
DEF VAR aux_dsextrat AS CHAR                                         NO-UNDO.
DEF VAR aux_vltarayl AS DECI                                         NO-UNDO.
DEF VAR aux_vltarcxo AS DECI                                         NO-UNDO.
DEF VAR aux_vltarint AS DECI                                         NO-UNDO.
DEF VAR aux_vltarcsh AS DECI                                         NO-UNDO.
DEF VAR aux_indebfol AS INTE                                         NO-UNDO.
DEF VAR aux_txdoipmf AS INTE                                         NO-UNDO.
DEF VAR log_vltarayl AS DECI                                         NO-UNDO.
DEF VAR log_vltarcxo AS DECI                                         NO-UNDO.
DEF VAR log_vltarint AS DECI                                         NO-UNDO.
DEF VAR log_vltarcsh AS DECI                                         NO-UNDO.

DEF VAR aux_cdagrupa AS INTE                                         NO-UNDO.
DEF VAR aux_dsagrupa AS CHAR                                         NO-UNDO.
DEF VAR aux_cdgrphis AS INTE                                         NO-UNDO.

DEF VAR aux_cdprodut AS INTE                                         NO-UNDO.
DEF VAR aux_dsprodut AS CHAR                                         NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0179tt.i }

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
             WHEN "cdhistor" THEN aux_cdhistor = INTE(tt-param.valorCampo).
             WHEN "dshistor" THEN aux_dshistor = tt-param.valorCampo.

             WHEN "tpltmvpq" THEN aux_tpltmvpq = INTE(tt-param.valorCampo). 
             WHEN "cdhinovo" THEN aux_cdhinovo = INTE(tt-param.valorCampo).

             WHEN "flgclass" THEN aux_flgclass = LOGICAL(tt-param.valorCampo).
             WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).
             WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
             WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.
             WHEN "indebcre" THEN aux_indebcre = tt-param.valorCampo.
             WHEN "cdhstctb" THEN aux_cdhstctb = INTE(tt-param.valorCampo).
             WHEN "dsexthst" THEN aux_dsexthst = tt-param.valorCampo.
             WHEN "inautori" THEN aux_inautori = INTE(tt-param.valorCampo).
             WHEN "inavisar" THEN aux_inavisar = INTE(tt-param.valorCampo).
             WHEN "inclasse" THEN aux_inclasse = INTE(tt-param.valorCampo).
             WHEN "incremes" THEN aux_incremes = INTE(tt-param.valorCampo).
             WHEN "inmonpld" THEN aux_inmonpld = INTE(tt-param.valorCampo).
             WHEN "indcompl" THEN aux_indcompl = INTE(tt-param.valorCampo).
             WHEN "indebcta" THEN aux_indebcta = INTE(tt-param.valorCampo).
             WHEN "indoipmf" THEN aux_indoipmf = INTE(tt-param.valorCampo).
             WHEN "inhistor" THEN aux_inhistor = INTE(tt-param.valorCampo).
             WHEN "nmestrut" THEN aux_nmestrut = tt-param.valorCampo.
             WHEN "nrctacrd" THEN aux_nrctacrd = INTE(tt-param.valorCampo).
             WHEN "nrctatrc" THEN aux_nrctatrc = INTE(tt-param.valorCampo).
             WHEN "nrctadeb" THEN aux_nrctadeb = INTE(tt-param.valorCampo).
             WHEN "nrctatrd" THEN aux_nrctatrd = INTE(tt-param.valorCampo).
             WHEN "tpctbccu" THEN aux_tpctbccu = INTE(tt-param.valorCampo).
             WHEN "tplotmov" THEN aux_tplotmov = INTE(tt-param.valorCampo).
             WHEN "tpctbcxa" THEN aux_tpctbcxa = INTE(tt-param.valorCampo).
             WHEN "ingercre" THEN aux_ingercre = INTE(tt-param.valorCampo).
             WHEN "ingerdeb" THEN aux_ingerdeb = INTE(tt-param.valorCampo).
             WHEN "flgsenha" THEN aux_flgsenha = LOGICAL(tt-param.valorCampo).
             WHEN "dsextrat" THEN aux_dsextrat = tt-param.valorCampo.
             WHEN "vltarayl" THEN aux_vltarayl = DECI(tt-param.valorCampo).
             WHEN "vltarcxo" THEN aux_vltarcxo = DECI(tt-param.valorCampo).
             WHEN "vltarint" THEN aux_vltarint = DECI(tt-param.valorCampo).
             WHEN "vltarcsh" THEN aux_vltarcsh = DECI(tt-param.valorCampo).
             WHEN "indebfol" THEN aux_indebfol = INTE(tt-param.valorCampo).
             WHEN "txdoipmf" THEN aux_txdoipmf = INTE(tt-param.valorCampo).
             WHEN "vltarayl" THEN log_vltarayl = DECI(tt-param.valorCampo).
             WHEN "vltarcxo" THEN log_vltarcxo = DECI(tt-param.valorCampo).
             WHEN "vltarint" THEN log_vltarint = DECI(tt-param.valorCampo).
             WHEN "vltarcsh" THEN log_vltarcsh = DECI(tt-param.valorCampo).

             WHEN "cdagrupa" THEN aux_cdagrupa = INTE(tt-param.valorCampo).
             WHEN "dsagrupa" THEN aux_dsagrupa = tt-param.valorCampo.

             WHEN "cdprodut" THEN aux_cdprodut = INTE(tt-param.valorCampo).
             WHEN "dsprodut" THEN aux_dsprodut = tt-param.valorCampo.
             WHEN "cdgrphis" THEN aux_cdgrphis = INTE(tt-param.valorCampo).

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
                     INPUT aux_dtmvtolt,
                     INPUT aux_cddepart,                            
                     INPUT aux_cddopcao,                            
                     INPUT aux_cdhistor,                            
                     INPUT aux_dshistor,                            
                     INPUT aux_tpltmvpq,                       
                     INPUT aux_cdhinovo,                  
                     INPUT aux_cdgrphis,
                     INPUT aux_nrregist,                            
                     INPUT aux_nriniseq,                            
                     INPUT TRUE,                                    
                    OUTPUT aux_qtregist,
                    OUTPUT aux_nmdcampo,
                    OUTPUT TABLE tt-histor,
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-histor:HANDLE,
                            INPUT "Dados").
           RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Dados */


/* -------------------------------------------------------------------------- */
/*               EFETUA A PESQUISA DOS PRODUTOS DOS HISTORICOS                */
/* -------------------------------------------------------------------------- */
PROCEDURE Busca_Produto:
    
    RUN Busca_Produto IN hBO
                  (  INPUT aux_cdcooper,    
                     INPUT aux_cdagenci,    
                     INPUT aux_nrdcaixa,    
                     INPUT aux_cdoperad,    
                     INPUT aux_nmdatela,    
                     INPUT aux_idorigem,    
                     INPUT aux_cddepart,  
                     INPUT aux_nrregist,                            
                     INPUT aux_nriniseq,                            
                     INPUT aux_cdprodut,
                     INPUT aux_dsprodut,
                    OUTPUT aux_qtregist,
                    OUTPUT TABLE tt-produto).
                    
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-produto:HANDLE,
                            INPUT "Dados").
           RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Produto */


/* -------------------------------------------------------------------------- */
/*                EFETUA A PESQUISA DOS GRUPOS DOS HISTORICOS                 */
/* -------------------------------------------------------------------------- */
PROCEDURE Busca_Grupo:

    RUN Busca_Grupo IN hBO
                  (  INPUT aux_cdcooper,       
                     INPUT aux_cdagenci,       
                     INPUT aux_nrdcaixa,       
                     INPUT aux_cdoperad,       
                     INPUT aux_nmdatela,       
                     INPUT aux_idorigem,       
                     INPUT aux_cddepart,       
                     INPUT aux_nrregist,                            
                     INPUT aux_nriniseq,                            
                     INPUT aux_cdagrupa,       
                     INPUT aux_dsagrupa,       
                    OUTPUT aux_qtregist,
                    OUTPUT TABLE tt-agrupamento).
                    
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-agrupamento:HANDLE,
                            INPUT "Dados").
           RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Grupo */

/* ------------------------------------------------------------------------ */
/*                        GRAVA DADOS DOS HISTORICOS                        */
/* ------------------------------------------------------------------------ */
PROCEDURE Grava_Dados:

    RUN Grava_Dados IN hBO
                  (  INPUT aux_cdcooper,     
                     INPUT aux_cdagenci,     
                     INPUT aux_nrdcaixa,     
                     INPUT aux_cdoperad,     
                     INPUT aux_dtmvtolt,     
                     INPUT aux_nmdatela,     
                     INPUT aux_idorigem,     
                     INPUT aux_cddopcao,     
                     
                     INPUT aux_cdhistor,     
                     INPUT aux_cdhinovo,   
                     
                     INPUT aux_cdhstctb,     
                     INPUT aux_dsexthst,     
                     INPUT aux_dshistor,     
                     INPUT aux_inautori,     
                     INPUT aux_inavisar,     
                     INPUT aux_inclasse,     
                     INPUT aux_incremes,     
                     INPUT aux_inmonpld, 
                     INPUT aux_indcompl,     
                     INPUT aux_indebcta,     
                     INPUT aux_indoipmf,     
                     
                     INPUT aux_inhistor,     
                     INPUT aux_indebcre,     
                     INPUT aux_nmestrut,     
                     INPUT aux_nrctacrd,     
                     INPUT aux_nrctatrc,     
                     INPUT aux_nrctadeb,     
                     INPUT aux_nrctatrd,     
                     INPUT aux_tpctbccu,     
                     INPUT aux_tplotmov,     
                     INPUT aux_tpctbcxa,     
                     
                     INPUT aux_ingercre,     
                     INPUT aux_ingerdeb,     
                     
                     INPUT aux_cdgrphis,
                     
                     INPUT aux_flgsenha,     
                     INPUT aux_cdprodut,     
                     INPUT aux_cdagrupa,     
                     INPUT aux_dsextrat,     
                     INPUT aux_vltarayl,     
                     INPUT aux_vltarcxo,     
                     INPUT aux_vltarint,     
                     INPUT aux_vltarcsh,
                     INPUT aux_indebfol,
                     INPUT aux_txdoipmf,
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
           RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlSave.
        END.

END PROCEDURE. /* Grava_Dados */

/* -------------------------------------------------------------------------- */
/*             EFETUA A IMPRESSãO MANUTENCAO DOS HISTORICOS OPCAO B           */
/* -------------------------------------------------------------------------- */
PROCEDURE Gera_ImpressaoB:

    RUN Gera_ImpressaoB IN hBO
                    (   INPUT aux_cdcooper,                      
                        INPUT aux_cdagenci,                      
                        INPUT aux_nrdcaixa,                      
                        INPUT aux_cdoperad,                      
                        INPUT aux_nmdatela,                      
                        INPUT aux_dtmvtolt,                      
                        INPUT aux_idorigem,                      
                        INPUT aux_dsiduser,                      
                        INPUT aux_cdhistor,
                        INPUT aux_indebcre,
                        INPUT TRUE,                              
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
           RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Gera_ImpressaoB */

/* -------------------------------------------------------------------------- */
/*             EFETUA A IMPRESSãO MANUTENCAO DOS HISTORICOS OPCAO O           */
/* -------------------------------------------------------------------------- */
PROCEDURE Gera_ImpressaoO:
    
    RUN Gera_ImpressaoO IN hBO
                    (   INPUT aux_cdcooper,                      
                        INPUT aux_cdagenci,                      
                        INPUT aux_nrdcaixa,                      
                        INPUT aux_cdoperad,                      
                        INPUT aux_nmdatela,                      
                        INPUT aux_dtmvtolt,                      
                        INPUT aux_idorigem,                      
                        INPUT aux_dsiduser,                      
                        INPUT TRUE,                              
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
           RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
           RUN piXmlSave.
           
        END.
    ELSE
        DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Gera_ImpressaoO */

