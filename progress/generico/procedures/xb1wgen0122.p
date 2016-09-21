/*.............................................................................

     Programa: sistema/generico/procedures/xb1wgen0122.p
     Autor   : Rogerius Militão
     Data    : Outubro/2011                     Ultima atualizacao: 08/07/2014

     Objetivo  : BO de Comunicacao XML x BO - Tela VERPRO

     Alteracoes:  28/02/2013 - Incluso paginacao tela web (Daniel).
     
                  27/06/2014 - Ajustes referente ao projeto de captacao
                              (Adriano).
                              
                  08/07/2014 - Adicionado recebimento de informacoes atraves
                               dos campos dslinha1, dslinha2 e dslinha3;
                               Projeto Captacao. (Fabricio)

.............................................................................*/



/*...........................................................................*/
DEF VAR aux_cdcooper  AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci  AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa  AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad  AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela  AS CHAR                                           NO-UNDO.
DEF VAR aux_idorigem  AS INTE                                           NO-UNDO.
                      
DEF VAR aux_nrdconta  AS INTE                                           NO-UNDO.
DEF VAR aux_nmprimtl  AS CHAR                                           NO-UNDO.
                      
DEF VAR aux_dataini   AS DATE                                           NO-UNDO.  
DEF VAR aux_datafin   AS DATE                                           NO-UNDO.  
DEF VAR aux_cdtippro  AS INTE                                           NO-UNDO. 
DEF VAR aux_nrdocmto  AS DECI                                           NO-UNDO.   
DEF VAR aux_nrseqaut  AS INTE                                           NO-UNDO.  
DEF VAR aux_nmprepos  AS CHAR                                           NO-UNDO.  
DEF VAR aux_nmoperad  AS CHAR                                           NO-UNDO.   
DEF VAR aux_dttransa  AS DATE                                           NO-UNDO.  
DEF VAR aux_hrautent  AS INTE                                           NO-UNDO.  
DEF VAR aux_dtmvtolx  AS DATE                                           NO-UNDO.   
DEF VAR aux_dsprotoc  AS CHAR                                           NO-UNDO.  
DEF VAR aux_cdbarras  AS CHAR                                           NO-UNDO.  
DEF VAR aux_lndigita  AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdbanco  AS CHAR                                           NO-UNDO. 
DEF VAR aux_dsageban  AS CHAR                                           NO-UNDO.
DEF VAR aux_nrctafav  AS CHAR                                           NO-UNDO.
DEF VAR aux_nmfavore  AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcpffav  AS CHAR                                           NO-UNDO.
DEF VAR aux_dsfinali  AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransf  AS CHAR                                           NO-UNDO.
                                                                        
DEF VAR aux_label     AS CHAR                                           NO-UNDO. 
DEF VAR aux_label2    AS CHAR                                           NO-UNDO. 
DEF VAR aux_valor     AS CHAR                                           NO-UNDO. 
DEF VAR aux_auxiliar  AS CHAR                                           NO-UNDO. 
DEF VAR aux_auxiliar2 AS CHAR                                           NO-UNDO. 
DEF VAR aux_auxiliar3 AS CHAR                                           NO-UNDO. 
DEF VAR aux_auxiliar4 AS CHAR                                           NO-UNDO. 

DEF VAR aux_dsiduser AS CHAR                                            NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                            NO-UNDO. 
DEF VAR aux_nmarqpdf AS CHAR                                            NO-UNDO. 
DEF VAR aux_dsinform LIKE crappro.dsinform                              NO-UNDO.

DEF VAR aux_nrregist AS INTE                                            NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                            NO-UNDO.

DEF VAR aux_qtregist AS INTE                                            NO-UNDO.

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/supermetodos.i } 
{ sistema/generico/includes/b1wgen0122tt.i }

/*............................... PROCEDURES ................................*/
 PROCEDURE valores_entrada:

     FOR EACH tt-param:
        
         CASE tt-param.nomeCampo:
             
             WHEN "cdcooper"  THEN aux_cdcooper = INTE(tt-param.valorCampo).
             WHEN "cdagenci"  THEN aux_cdagenci = INTE(tt-param.valorCampo).
             WHEN "nrdcaixa"  THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
             WHEN "cdoperad"  THEN aux_cdoperad = tt-param.valorCampo.
             WHEN "nmdatela"  THEN aux_nmdatela = tt-param.valorCampo.
             WHEN "dtmvtolt"  THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
             WHEN "idorigem"  THEN aux_idorigem = INTE(tt-param.valorCampo).
                              
             WHEN "nrdconta"  THEN aux_nrdconta = INTE(tt-param.valorCampo).
             WHEN "nmprimtl"  THEN aux_nmprimtl = tt-param.valorCampo.
                              
             WHEN "dataini"   THEN aux_dataini  = DATE(tt-param.valorCampo).
             WHEN "datafin "  THEN aux_datafin  = DATE(tt-param.valorCampo).
             WHEN "cdtippro"  THEN aux_cdtippro = INTE(tt-param.valorCampo).
             WHEN "nrdocmto"  THEN aux_nrdocmto = DECI(tt-param.valorCampo).  
             WHEN "nrseqaut"  THEN aux_nrseqaut = INTE(tt-param.valorCampo). 
             WHEN "nmprepos"  THEN aux_nmprepos = tt-param.valorCampo. 
             WHEN "nmoperad"  THEN aux_nmoperad = tt-param.valorCampo. 
             WHEN "dttransa"  THEN aux_dttransa = DATE(tt-param.valorCampo). 
             WHEN "hrautent"  THEN aux_hrautent = INTE(tt-param.valorCampo). 
             WHEN "dtmvtolx"  THEN aux_dtmvtolx = DATE(tt-param.valorCampo). 
             WHEN "dsprotoc"  THEN aux_dsprotoc = tt-param.valorCampo. 
             WHEN "cdbarras"  THEN aux_cdbarras = tt-param.valorCampo. 
             WHEN "lndigita"  THEN aux_lndigita = tt-param.valorCampo. 
             WHEN "dsdbanco"  THEN aux_dsdbanco = tt-param.valorCampo. 
             WHEN "dsageban"  THEN aux_dsageban = tt-param.valorCampo. 
             WHEN "nrctafav"  THEN aux_nrctafav = tt-param.valorCampo. 
             WHEN "nmfavore"  THEN aux_nmfavore = tt-param.valorCampo. 
             WHEN "nrcpffav"  THEN aux_nrcpffav = tt-param.valorCampo. 
             WHEN "dsfinali"  THEN aux_dsfinali = tt-param.valorCampo. 
             WHEN "dstransf"  THEN aux_dstransf = tt-param.valorCampo. 
            
             WHEN "label"     THEN aux_label     = tt-param.valorCampo.   
             WHEN "label2"    THEN aux_label2    = tt-param.valorCampo. 
             WHEN "valor"     THEN aux_valor     = tt-param.valorCampo. 
             WHEN "auxiliar"  THEN aux_auxiliar  = tt-param.valorCampo. 
             WHEN "auxiliar2" THEN aux_auxiliar2 = tt-param.valorCampo. 
             WHEN "auxiliar3" THEN aux_auxiliar3 = tt-param.valorCampo. 
             WHEN "auxiliar4" THEN aux_auxiliar4 = tt-param.valorCampo. 
                              
             WHEN "dsiduser"  THEN aux_dsiduser = tt-param.valorCampo.
             WHEN "nmarqimp"  THEN aux_nmarqimp = tt-param.valorCampo.
             WHEN "nmarqpdf"  THEN aux_nmarqpdf = tt-param.valorCampo.

             WHEN "nrregist"  THEN aux_nrregist = INTE(tt-param.valorCampo).
             WHEN "nriniseq"  THEN aux_nriniseq = INTE(tt-param.valorCampo).
            
             WHEN "qtregist"  THEN aux_qtregist = INTE(tt-param.valorCampo).

         END CASE.

     END. /** Fim do FOR EACH tt-param **/

     FOR EACH tt-param-i BREAK BY tt-param-i.nomeTabela
                               BY tt-param-i.sqControle:
        
         CASE tt-param-i.nomeTabela:

             WHEN "Inform" THEN DO:
                
                 CASE tt-param-i.nomeCampo:
                                            
                     WHEN "dslinha1" THEN
                         ASSIGN aux_dsinform[1] = tt-param-i.valorCampo.
                     WHEN "dslinha2" THEN
                         ASSIGN aux_dsinform[2] = tt-param-i.valorCampo.
                     WHEN "dslinha3" THEN
                         ASSIGN aux_dsinform[3] = tt-param-i.valorCampo. 

                 END CASE. /* CASE tt-param-i.nomeCampo */ 

             END. /* "Inform"  */

         END CASE. /* CASE tt-param-i.nomeTabela: */
                         
     END.
     
 END PROCEDURE. /* valores_entrada */

/* ------------------------------------------------------------------------ */
/*                    EFETUA A BUSCA DA TELA VERPRO                         */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    RUN Busca_Dados IN hBO
                  ( INPUT aux_cdcooper ,
                    INPUT aux_cdagenci ,
                    INPUT aux_nrdcaixa ,
                    INPUT aux_cdoperad ,
                    INPUT aux_nmdatela ,
                    INPUT aux_idorigem ,
                    INPUT aux_nrdconta ,
                    INPUT YES , /* flglog */
                   OUTPUT aux_nmprimtl,
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
           RUN piXmlAtributo (INPUT "nmprimtl", INPUT aux_nmprimtl).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Dados */

/* ------------------------------------------------------------------------ */
/*                 EFETUA A BUSCA DOS PROTOCOLOS TELA VERPRO                */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Protocolos:

    RUN Busca_Protocolos IN hBO
                       ( INPUT aux_cdcooper,
                         INPUT aux_cdagenci,
                         INPUT aux_nrdcaixa,
                         INPUT aux_cdoperad,
                         INPUT aux_nmdatela,
                         INPUT aux_idorigem,
                         INPUT aux_nrdconta,
                         INPUT aux_dataini, 
                         INPUT aux_datafin, 
                         INPUT aux_cdtippro,
                         INPUT YES , /* flglog */
                         INPUT aux_nrregist,
                         INPUT aux_nriniseq,
                        OUTPUT aux_qtregist,
                        OUTPUT TABLE tt-cratpro,
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
           RUN piXmlExport (INPUT TEMP-TABLE tt-cratpro:HANDLE,
                            INPUT "Protocolos").
           RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
           RUN piXmlSave.
        END.

END PROCEDURE. /* Busca_Protocolos */

/* ------------------------------------------------------------------------ */
/*                    EFETUA A IMPRESSAO DA TELA VERPRO                     */
/* ------------------------------------------------------------------------ */
PROCEDURE Gera_Impressao:

    RUN Gera_Impressao IN hBO
                     ( INPUT aux_cdcooper,
                       INPUT aux_cdagenci,
                       INPUT aux_nrdcaixa,
                       INPUT aux_cdoperad,
                       INPUT aux_nmdatela,
                       INPUT aux_idorigem,
                       INPUT aux_dsiduser,  
                       INPUT aux_nrdconta,  
                       INPUT aux_nmprimtl,
                       INPUT aux_cdtippro, 
                       INPUT aux_nrdocmto, 
                       INPUT aux_nrseqaut, 
                       INPUT aux_nmprepos, 
                       INPUT aux_nmoperad, 
                       INPUT aux_dttransa, 
                       INPUT aux_hrautent, 
                       INPUT aux_dtmvtolx, 
                       INPUT aux_dsprotoc, 
                       INPUT aux_cdbarras, 
                       INPUT aux_lndigita, 
                       INPUT aux_label,    
                       INPUT aux_label2,   
                       INPUT aux_valor,    
                       INPUT aux_auxiliar, 
                       INPUT aux_auxiliar2,
                       INPUT aux_auxiliar3,
                       INPUT aux_auxiliar4,
                       INPUT aux_dsdbanco,
                       INPUT aux_dsageban,
                       INPUT aux_nrctafav,
                       INPUT aux_nmfavore,
                       INPUT aux_nrcpffav,
                       INPUT aux_dsfinali,
                       INPUT aux_dstransf,
                       INPUT YES , /* flglog */
                       INPUT aux_dsinform,
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

END PROCEDURE. /* Busca_Protocolos */

 
