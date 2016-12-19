/*.............................................................................
    Programa: sistema/generico/procedures/b1wgen0184.p
    Autor   : Jéssica Laverde Gracino (DB1)
    Data    : 18/02/2014                     Ultima atualizacao: 09/11/2015

    Objetivo  : Tranformacao BO tela LISLOT.

    Alteracoes: 
               25/06/2014 - #141531 Incluidos os historicos 351, 770, 397, 47,
                            621 e 521 para listar no relatorio "LOTE P/PA" 
                            (Carlos)  
                            
               09/10/2014 - (Chamado 170798) Alteracao no calculo de
                            quantidade do limite de consulta para 
                            efetivamente 03 meses inteiros 
                            (Tiago Castro - RKAM).
                
               11/11/2014 - #170798 Aumento de 30 para 31 no numero de dias da
                            divisao dos meses para atender o prazo de 3 meses
                            de consulta. Retornada a versão sem chamada ao fonte
                            b1wgen0184.p pois a versao web nao foi liberada ainda. 
                            VERSAO WEB deste fonte: 020000 (Versão RoundTable)
                            (Carlos)
                                    
               28/01/2015 - Inserido nova tabela craplac no filtro do campo 
                            nmestrut da busca da tabela craphis. (Reinert)
                            
               15/04/2015 - Aumentar format do nrdocmto para 25 posicoes    
                            (Lucas Ranghetti #275848)
                            
               22/07/2015 - Aumentar o format do vllanmto pois estava bugando a tela
                            (Kelvin)
               
               09/11/2015 - Removido as virgulas do numero de documento para aumentar
                            seus format para 31 posicoes conforme solicitado no chamado
                            348989. (Kelvin)   

			   06/12/2016 - P341-Automatização BACENJUD - Alterar o uso da descrição do
                            departamento passando a considerar o código (Renato Darosci)
............................................................................*/

/*............................. DEFINICOES .................................*/
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0184tt.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF STREAM str_1.

DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_nrregist AS INTE                                        NO-UNDO.
DEF VAR aux_contador AS INTE                                        NO-UNDO.

DEF VAR aux_txcpmfcc AS DECI FORMAT "9.9999"                        NO-UNDO.


DEF  VAR  par_dtinicio AS DATE                           NO-UNDO.
DEF  VAR  par_dttermin AS DATE                           NO-UNDO.

DEF VAR aux_nmendter AS CHAR                                        NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                      NO-UNDO.



/*................................ PROCEDURES ..............................*/

/* -------------------------------------------------------------------------- */
/*              EFETUA A BUSCA DA LISTA DE HISTORICOS NO SISTEMA              */
/* -------------------------------------------------------------------------- */

PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tpdopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtinicio AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dttermin AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF  VAR aux_cont     AS INTE INIT 0                            NO-UNDO.
    DEF  VAR aux_texto    AS CHAR FORMAT "X(9)"                     NO-UNDO.
    

    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_vllanmto AS DECI FORMAT ">>>,>>>,>>9.99"   NO-UNDO.
    DEF OUTPUT PARAM par_registro AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-lislot.
    DEF OUTPUT PARAM TABLE FOR tt-lislot-aux.
    DEF OUTPUT PARAM TABLE FOR tt-retorno.
    DEF OUTPUT PARAM TABLE FOR tt-craplcx.
    DEF OUTPUT PARAM TABLE FOR tt-craplcx-aux.
    DEF OUTPUT PARAM TABLE FOR tt-craplcm.   
    DEF OUTPUT PARAM TABLE FOR tt-craplcm-aux.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Dados Lista Historicos Do Sistema".              

    EMPTY TEMP-TABLE tt-lislot.
    EMPTY TEMP-TABLE tt-retorno.
    EMPTY TEMP-TABLE tt-craplcx.
    EMPTY TEMP-TABLE tt-craplcm.
    EMPTY TEMP-TABLE tt-erro.
    
    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:

        IF par_dtinicio = ? AND par_dtinicio > par_dttermin THEN
            DO:
                ASSIGN aux_cdcritic = 0 
                       aux_dscritic = "013 - Data invalida"
                       par_nmdcampo = "".
                LEAVE Busca.
            END.

        IF par_dttermin = ? THEN
            DO:
                ASSIGN aux_cdcritic = 0 
                       aux_dscritic = "013 - Data invalida"
                       par_nmdcampo = "".
                LEAVE Busca.
            END.

        IF  par_tpdopcao = "COOPERADO" THEN
            DO:
                RUN Busca_Cooperado                                                     
                ( INPUT par_cdcooper,              
                  INPUT par_cdagenci,              
                  INPUT par_nrdcaixa,              
                  INPUT par_cdoperad,              
                  INPUT par_nmdatela,              
                  INPUT par_idorigem,              
                  INPUT par_cddepart,              
                  INPUT par_dtmvtolt,              
                  INPUT par_cddopcao,              
                  INPUT par_tpdopcao,              
                  INPUT par_cdhistor,              
                  INPUT par_nrdconta,              
                  INPUT par_dtinicio,              
                  INPUT par_dttermin,              
                  INPUT par_nrregist,              
                  INPUT par_nriniseq,
                  INPUT par_flgerlog,                           
                 OUTPUT par_qtregist,              
                 OUTPUT par_nmdcampo,   
                 OUTPUT par_vllanmto,
                 OUTPUT par_registro,
                 OUTPUT TABLE tt-retorno,          
                 OUTPUT TABLE tt-lislot,     
                 OUTPUT TABLE tt-erro).            
            END.

        ELSE IF par_tpdopcao = "CAIXA" THEN
            DO:
                RUN Busca_Caixa
                    (INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT par_cdoperad,
                     INPUT par_nmdatela,
                     INPUT par_idorigem,
                     INPUT par_cddepart,
                     INPUT par_dtmvtolt,
                     INPUT par_cddopcao,
                     INPUT par_tpdopcao,
                     INPUT par_cdhistor,
                     INPUT par_nrdconta,
                     INPUT par_dtinicio,
                     INPUT par_dttermin,
                     INPUT par_nrregist,
                     INPUT par_nriniseq,
                     INPUT par_flgerlog,
                    OUTPUT par_qtregist,              
                    OUTPUT par_nmdcampo, 
                    OUTPUT par_vllanmto,
                    OUTPUT par_registro,
                    OUTPUT TABLE tt-craplcx,
                    OUTPUT TABLE tt-craplcx-aux,
                    OUTPUT TABLE tt-erro).  

            END.

        ELSE IF par_tpdopcao = "LOTE P/PA" THEN
            DO:
                RUN Busca_Lote
                    (INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT par_cdoperad,
                     INPUT par_nmdatela,
                     INPUT par_idorigem,
                     INPUT par_cddepart,
                     INPUT par_dtmvtolt,
                     INPUT par_cddopcao,
                     INPUT par_tpdopcao,
                     INPUT par_cdhistor,
                     INPUT par_nrdconta,
                     INPUT par_dtinicio,
                     INPUT par_dttermin,
                     INPUT par_nrregist,
                     INPUT par_nriniseq,
                     INPUT par_flgerlog,
                    OUTPUT par_qtregist,              
                    OUTPUT par_nmdcampo, 
                    OUTPUT par_vllanmto,              
                    OUTPUT par_registro,                 
                    OUTPUT TABLE tt-craplcm,
                    OUTPUT TABLE tt-craplcm-aux,
                    OUTPUT TABLE tt-erro).  

            END.
                                                       
        LEAVE Busca.                                   
                                                       
    END. /* Busca */    

    
    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0  OR 
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN

                FIND FIRST tt-erro NO-ERROR.

                IF  AVAIL tt-erro THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.

            ELSE
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT NO,
                                    INPUT 1, /** idseqttl **/
                                    INPUT par_nmdatela,
                                    INPUT 0, /* nrdconta */
                                   OUTPUT aux_nrdrowid).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Dados */


/* -------------------------------------------------------------------------- */
/*              GERA A IMPRESSAO DA LISTA DE HISTORICOS NO SISTEMA            */
/* -------------------------------------------------------------------------- */
PROCEDURE Gera_Impressao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tpdopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtinicio AS DATE FORMAT "99/99/9999"       NO-UNDO.
    DEF  INPUT PARAM par_dttermin AS DATE FORMAT "99/99/9999"       NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdopcao AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                           NO-UNDO.
    
    DEF  VAR par_qtregist         AS INTE                           NO-UNDO.
    DEF  VAR par_nmdcampo         AS CHAR                           NO-UNDO.
    DEF  VAR aux_vllanmto         AS DECI  FORMAT ">>>,>>>,>>9.99"  NO-UNDO.  
    DEF  VAR aux_registro         AS INTE                           NO-UNDO.
    
    DEF  OUTPUT PARAM aux_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqpdf AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM par_nmdireto AS CHAR                          NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Dados Manutencao do Historico".

    EMPTY TEMP-TABLE tt-erro.

    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:

        RUN Busca_Dados
            (INPUT par_cdcooper,                       
             INPUT par_cdagenci,                       
             INPUT par_nrdcaixa,                       
             INPUT par_cdoperad,                       
             INPUT par_nmdatela,                       
             INPUT 1, 
             INPUT par_cddepart,                       
             INPUT par_dtmvtolt,                       
             INPUT par_cddopcao,                       
             INPUT par_tpdopcao,                       
             INPUT par_cdhistor,                       
             INPUT par_nrdconta,                       
             INPUT par_dtinicio,                       
             INPUT par_dttermin,                                            
             INPUT 0,                       
             INPUT 0,                       
             INPUT TRUE,                                                  
            OUTPUT par_qtregist,                       
            OUTPUT par_nmdcampo,    
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

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Imprime.
        
        IF  par_tpdopcao = "COOPERADO" THEN
            DO:
                
                RUN Gera_Impressao_Cooperado                                                     
                    ( INPUT par_cdcooper,                       
                      INPUT par_cdagenci,                       
                      INPUT par_nrdcaixa,                       
                      INPUT par_cdoperad,                       
                      INPUT par_nmdatela,                       
                      INPUT par_idorigem,                       
                      INPUT par_cddepart,                       
                      INPUT par_dtmvtolt,                       
                      INPUT par_cddopcao,                       
                      INPUT par_nrdconta,                       
                      INPUT par_dtinicio,                       
                      INPUT par_dttermin,                                    
                      INPUT par_dsiduser,                       
                      INPUT par_nmdopcao,                       
                      INPUT TRUE,  
                      INPUT par_cdhistor,
                      INPUT aux_registro, 
                      INPUT aux_vllanmto,
                     OUTPUT aux_nmarqpdf,                       
                     OUTPUT aux_nmarqimp,                       
                     OUTPUT par_nmdireto,
                     INPUT TABLE tt-retorno,              
                     OUTPUT TABLE tt-erro). 
                      
            END.

        ELSE IF par_tpdopcao = "CAIXA" THEN
            DO:
                RUN Gera_Impressao_Caixa
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_cdoperad,
                      INPUT par_nmdatela,
                      INPUT par_idorigem,
                      INPUT par_cddepart,
                      INPUT par_dtmvtolt,
                      INPUT par_cddopcao,
                      INPUT par_tpdopcao,
                      INPUT par_cdhistor,
                      INPUT par_nrdconta,
                      INPUT par_dtinicio,
                      INPUT par_dttermin,
                      INPUT TRUE,
                      INPUT par_dsiduser,
                      INPUT par_nmdopcao,
                      INPUT aux_registro,
                      INPUT aux_vllanmto,
                     OUTPUT aux_nmarqpdf,
                     OUTPUT aux_nmarqimp,
                     OUTPUT par_nmdireto,
                      INPUT TABLE tt-craplcx,
                     OUTPUT TABLE tt-erro).

            END.

        ELSE IF par_tpdopcao = "LOTE P/PA" THEN
            DO:
                
                RUN Gera_Impressao_Lote
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_cdoperad,
                      INPUT par_nmdatela,
                      INPUT par_idorigem,
                      INPUT par_cddepart,
                      INPUT par_dtmvtolt,
                      INPUT par_cddopcao,
                      INPUT par_tpdopcao,
                      INPUT par_cdhistor,
                      INPUT par_nrdconta,
                      INPUT par_dtinicio,
                      INPUT par_dttermin,
                      INPUT TRUE,
                      INPUT par_dsiduser,
                      INPUT par_nmdopcao,
                      INPUT aux_vllanmto,
                      INPUT aux_registro,
                     OUTPUT aux_nmarqpdf,
                     OUTPUT aux_nmarqimp,
                     OUTPUT par_nmdireto,
                      INPUT TABLE tt-craplcm,
                     OUTPUT TABLE tt-erro).

            END.
           
        LEAVE Imprime.

    END. /* Imprime */

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0  OR 
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN

                FIND FIRST tt-erro NO-ERROR.

                IF  AVAIL tt-erro THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.
                
            ELSE
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT NO,
                                    INPUT 1, /** idseqttl **/
                                    INPUT par_nmdatela,
                                    INPUT 0, /* nrdconta */
                                   OUTPUT aux_nrdrowid).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* Gera_Impressao*/

/* -------------------------------------------------------------------------- */
/*                        EFETUA A BUSCA POR COOPERADO                        */
/* -------------------------------------------------------------------------- */

PROCEDURE Busca_Cooperado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tpdopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtinicio AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dttermin AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF  VAR aux_cont     AS INTE INIT 0                            NO-UNDO.
    DEF  VAR aux_texto    AS CHAR FORMAT "X(9)"                     NO-UNDO.
    DEF  VAR aux_qtdmeses AS INTE                                   NO-UNDO.
    DEF  VAR aux_soma     AS INTE                                   NO-UNDO.
    DEF  VAR aux_dslog    AS CHAR                                   NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_vllanmto AS DECI FORMAT ">>>,>>>,>>9.99"   NO-UNDO.
    DEF OUTPUT PARAM par_registro AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-retorno.
    DEF OUTPUT PARAM TABLE FOR tt-lislot.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dstransa = "Dados Lista Historicos Do Sistema por cooperado".              

    EMPTY TEMP-TABLE tt-lislot.
    EMPTY TEMP-TABLE tt-retorno.
    EMPTY TEMP-TABLE tt-erro.
    
    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:

        IF  (par_cdagenci <> 0) THEN  
            DO:
                FIND FIRST crapage WHERE crapage.cdagenci = par_cdagenci AND 
                                         crapage.cdcooper = par_cdcooper
                                         NO-LOCK.  
            END.

            
        IF  (par_nrdconta <> 0) THEN
            DO:
                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = par_nrdconta
                                   NO-LOCK NO-ERROR.
            END.
           
        FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                           craphis.cdhistor = par_cdhistor 
                           NO-LOCK NO-ERROR.
        
        IF  NOT AVAILABLE craphis THEN
            DO:

                ASSIGN aux_cdcritic = 526 
                       aux_dscritic = ""
                       par_nmdcampo = "".
                LEAVE Busca. 
            
            END.
        ELSE
            IF NOT AVAILABLE crapage AND par_cdagenci <> 0 THEN   
                DO:
                  
                    ASSIGN aux_cdcritic = 15
                           aux_dscritic = ""
                           par_nmdcampo = ""
                           par_cdagenci = 0 
                           par_cdhistor = 0 
                           par_nrdconta = 0.
                    LEAVE Busca. 
                    
                END.
        ELSE
            IF NOT AVAILABLE crapass AND par_nrdconta <> 0 THEN
                DO:
                    
                    ASSIGN aux_cdcritic = 127
                           aux_dscritic = ""
                           par_nmdcampo = ""
                           par_cdagenci = 0 
                           par_cdhistor = 0 
                           par_nrdconta = 0.
                    LEAVE Busca.
                    
                END.
            ELSE
                FOR EACH craphis WHERE CAN-DO("craplct,craplcm,craplem,craplpp,craplap,craplac",
                                               craphis.nmestrut)               AND
                                       craphis.cdcooper = par_cdcooper         AND 
                                       craphis.cdhistor = par_cdhistor         
                                       NO-LOCK:
                       
                            
                            aux_qtdmeses = (par_dttermin - par_dtinicio) / 31.

                            IF  aux_qtdmeses > 3  THEN
                                DO:
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = "Nao e possivel listar em um periodo superior a 3 meses."
                                           par_nmdcampo = "".
                                    LEAVE Busca.

                                END.
                           
                            aux_soma = 0. 


                            RUN Busca_Dados_T
                                (INPUT par_nrdcaixa,
                                 INPUT par_cdoperad,
                                 INPUT par_nmdatela,
                                 INPUT par_idorigem,
                                 INPUT par_cddepart,
                                 INPUT craphis.nmestrut,                                
                                 INPUT par_cdhistor,   
                                 INPUT par_cdagenci,   
                                 INPUT par_nrdconta,
                                 INPUT par_cdcooper,
                                 INPUT par_dtinicio,
                                 INPUT par_dttermin,
                                INPUT-OUTPUT par_vllanmto,
                                INPUT-OUTPUT par_registro,
                                INPUT-OUTPUT TABLE tt-retorno,
                                OUTPUT TABLE tt-erro).    
                  
                       
                    aux_cont =  1.  
                    
                END.
      
            /** certifica q os historicos seja um dos permitidos */
            IF  aux_cont = 0 THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Historico nao permitido."
                           par_nmdcampo = "".
                    LEAVE Busca.
                END.

            IF par_cddopcao = "T" THEN
                DO:
                   
                    FOR FIRST crapcop WHERE                                                                                         
                       crapcop.cdcooper = par_cdcooper NO-LOCK: END. 
        
                    IF AVAIL tt-retorno THEN
                        DO:
            
                            ASSIGN aux_dslog = STRING(par_dtmvtolt, "99/99/9999") + " " +
                                               STRING(TIME, "HH:MM:SS") + " '-->' " +
                                               "Operador " + STRING(par_cdoperad) + " - " +
                                               "Visualizou listagem dos historicos, entre " +
                                               STRING(par_dtinicio, "99/99/9999") + " e " +
                                               STRING(par_dttermin, "99/99/9999") +
                                               ", filtrando por".
                    
                            IF par_cdagenci <> 0 THEN
                                ASSIGN aux_dslog = aux_dslog + ", PA " + STRING(par_cdagenci).
                    
                            ASSIGN aux_dslog = aux_dslog + ", historico " + STRING(par_cdhistor).
                    
                            IF par_nrdconta <> 0 THEN
                                ASSIGN aux_dslog = aux_dslog + ", conta/dv " + STRING(par_nrdconta).
                    
                            ASSIGN aux_dslog = aux_dslog + ". >> /usr/coop/" +                                                           
                                                TRIM(crapcop.dsdircop) +               
                                                "/log/lislot.log".
                    
                            UNIX SILENT VALUE("echo " + aux_dslog).
                        END.
            
                    ELSE                                                                               
                        DO: 
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Nenhum Registro Encontrado.".
                            
        
                            ASSIGN aux_dslog = STRING(par_dtmvtolt, "99/99/9999") + " " +
                                    STRING(TIME, "HH:MM:SS") + " '-->' " +
                                    "Operador " + STRING(par_cdoperad) + " - " +
                                    "Tentou visualizar listagem dos historicos, entre "
                                    + STRING(par_dtinicio, "99/99/9999") + " e " + 
                                    STRING(par_dttermin, "99/99/9999") +
                                    ", filtrando por".
        
                            IF par_cdagenci <> 0 THEN
                                ASSIGN aux_dslog = aux_dslog + ", PA " + STRING(par_cdagenci).
                    
                            ASSIGN aux_dslog = aux_dslog + ", historico " + STRING(par_cdhistor).
                    
                            IF par_nrdconta <> 0 THEN
                                ASSIGN aux_dslog = aux_dslog + ", conta/dv " + STRING(par_nrdconta).
                    
                            ASSIGN aux_dslog = aux_dslog + ", mas nenhum registro foi encontrado."
                                               + " >> /usr/coop/" +                                                           
                                                TRIM(crapcop.dsdircop) +               
                                                "/log/lislot.log".
                    
                            UNIX SILENT VALUE("echo " + aux_dslog).
        
                            LEAVE Busca.
        
                        END.
                END.

        LEAVE Busca.
                   
            
    END. /* Busca */

    IF  par_idorigem = 5 THEN DO:                      
        RUN pi_paginacao
            ( INPUT par_nrregist,
              INPUT par_nriniseq,
              INPUT TABLE tt-retorno,
              OUTPUT par_qtregist,
              OUTPUT TABLE tt-lislot-aux).

        EMPTY TEMP-TABLE tt-retorno.
    
    END.

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0  OR 
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN

                FIND FIRST tt-erro NO-ERROR.

                IF  AVAIL tt-erro THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.

            ELSE
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT NO,
                                    INPUT 1, /** idseqttl **/
                                    INPUT par_nmdatela,
                                    INPUT 0, /* nrdconta */
                                   OUTPUT aux_nrdrowid).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Cooperado*/

PROCEDURE Busca_Dinamica:

    DEF  INPUT PARAM par_nmestrut  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM aux_campos    AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM aux_filtros   AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM aux_param_e   AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM aux_temptable AS CHAR                           NO-UNDO.

    DEF  OUTPUT PARAM TABLE-HANDLE tt-handle.
         
    DEF  VAR hQuery                AS HANDLE                         NO-UNDO.
    DEF  VAR hBuffer               AS HANDLE                         NO-UNDO.
    DEF  VAR hTTReturn             AS HANDLE                         NO-UNDO.
    DEF  VAR hBufferTT             AS HANDLE                         NO-UNDO.


    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dstransa = "Dados Busca Dinamica".              

    EMPTY TEMP-TABLE tt-erro.
    
    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:

        /*Cria buffers e Query*/
        CREATE BUFFER hBuffer FOR TABLE par_nmestrut.
        
        /*Cria handle da Temp-table para a tabela principal da query*/
        CREATE TEMP-TABLE tt-handle.
        
        CREATE BUFFER hTTReturn FOR TABLE aux_temptable.
    
        tt-handle:CREATE-LIKE(hTTReturn).
        /* hTempTable:ADD-NEW-FIELD("abfield","char",0,"abc"). */
        
        tt-handle:TEMP-TABLE-PREPARE("tt-" + TRIM(par_nmestrut)).
    
        hBufferTT = tt-handle:DEFAULT-BUFFER-HANDLE.
        
        CREATE QUERY hQuery.
        hQuery:SET-BUFFERS(hBuffer).
        
        hQuery:QUERY-PREPARE("FOR EACH " + par_nmestrut + " FIELDS(" + aux_campos + ")" + aux_filtros + " NO-LOCK").
        hQuery:QUERY-OPEN().
        hQuery:GET-FIRST(NO-LOCK).
        REPEAT:
           IF hQuery:QUERY-OFF-END THEN 
              LEAVE.
           hBufferTT:BUFFER-CREATE().
           hBufferTT:BUFFER-COPY(hBuffer).
           IF ENTRY(1,aux_param_e) <> ? AND ENTRY(1,aux_param_e) = "1" THEN
              LEAVE.
           hQuery:GET-NEXT(NO-LOCK).
        END.
        hQuery:QUERY-CLOSE().
        DELETE OBJECT hBuffer.
        DELETE OBJECT hQuery.

        LEAVE Busca.

    END. /* Busca */

END PROCEDURE. /* Busca_Dinamica*/

PROCEDURE Busca_Dados_T:

    DEF  INPUT PARAM par_nrdcaixa AS INTE                                 NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                                 NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                                 NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                                 NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                                 NO-UNDO.

    DEF  INPUT PARAM par_nmestrut AS CHAR                                 NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                                 NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                                 NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                                 NO-UNDO.
    DEF  INPUT PARAM par_cdcooper AS INTE                                 NO-UNDO.
    DEF  INPUT PARAM par_dtinicio AS DATE                                 NO-UNDO.
    DEF  INPUT PARAM par_dttermin AS DATE                                 NO-UNDO.
    
    DEF INPUT-OUTPUT PARAM par_vllanmto AS DECI FORMAT ">>>,>>>,>>9.99"   NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_registro AS INTE                           NO-UNDO.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-retorno.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_filtros   AS CHAR                                         NO-UNDO.
    DEF VAR aux_campos    AS CHAR                                         NO-UNDO.
    DEF VAR aux_temptable AS CHAR                                         NO-UNDO.
    
    DEF VAR aux_soma      AS INTE                                         NO-UNDO.

    ASSIGN aux_campos = "dtmvtolt nrdconta nrdocmto vllanmto"
           aux_temptable = "tt-handle".

    EMPTY TEMP-TABLE tt-handle.

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:

        IF  par_cdagenci <> 0 AND par_nrdconta <> 0  THEN
        DO:
            ASSIGN aux_filtros = " WHERE cdcooper  = " + STRING(par_cdcooper) + " AND" +
                                 "       nrdconta  = " + STRING(par_nrdconta) + " AND" +
                                 "       dtmvtolt >= " + STRING(par_dtinicio) + " AND" +
                                 "       dtmvtolt <= " + STRING(par_dttermin) + " AND" +
                                 "       cdhistor  = " + STRING(par_cdhistor).
            RUN Busca_Dinamica
                ( INPUT par_nmestrut,                                                   
                  INPUT aux_campos,
                  INPUT aux_filtros,
                  INPUT "",
                  INPUT aux_temptable,
                 OUTPUT TABLE tt-handle). 
    
            FOR EACH tt-handle NO-LOCK,
                FIRST crapass   NO-LOCK WHERE
                                crapass.cdcooper = par_cdcooper  AND
                                crapass.cdagenci = par_cdagenci  AND
                                crapass.nrdconta = tt-handle.nrdconta
                                BY tt-handle.dtmvtolt
                                BY crapass.cdagenci
                                BY tt-handle.nrdconta
                                BY tt-handle.nrdocmto.
    
                CREATE tt-retorno.
                ASSIGN tt-retorno.dtmvtolt = tt-handle.dtmvtolt
                       tt-retorno.cdagenci = crapass.cdagenci
                       tt-retorno.nrdconta = tt-handle.nrdconta
                       tt-retorno.nmprimtl = crapass.nmprimtl
                       tt-retorno.nrdocmto = tt-handle.nrdocmto
                       tt-retorno.vllanmto = tt-handle.vllanmto
                       par_vllanmto = par_vllanmto + tt-handle.vllanmto
                       par_registro = par_registro + 1. 
    
                
            END.
        END.
        ELSE
        IF  par_cdagenci <> 0 AND par_nrdconta = 0  THEN
            DO:
    
                ASSIGN aux_filtros = " WHERE cdcooper  = " + STRING(par_cdcooper) + " AND" +
                                     "       dtmvtolt >= " + STRING(par_dtinicio) + " AND" +
                                     "       dtmvtolt <= " + STRING(par_dttermin) + " AND" +
                                     "       cdhistor  = " + STRING(par_cdhistor).
        
                RUN Busca_Dinamica
                ( INPUT par_nmestrut,
                  INPUT aux_campos,
                  INPUT aux_filtros,
                  INPUT "",
                  INPUT aux_temptable,
                 OUTPUT TABLE tt-handle). 



        
                FOR EACH tt-handle,
                    FIRST crapass WHERE  crapass.cdcooper = par_cdcooper AND
                                         crapass.cdagenci = par_cdagenci AND
                                         crapass.nrdconta = tt-handle.nrdconta
                                           NO-LOCK
                                           BY tt-handle.dtmvtolt
                                           BY crapass.cdagenci
                                           BY tt-handle.nrdconta
                                           BY tt-handle.nrdocmto.
        
                    CREATE tt-retorno.
                    ASSIGN tt-retorno.dtmvtolt = tt-handle.dtmvtolt
                           tt-retorno.cdagenci = crapass.cdagenci
                           tt-retorno.nrdconta = tt-handle.nrdconta
                           tt-retorno.nmprimtl = crapass.nmprimtl
                           tt-retorno.nrdocmto = tt-handle.nrdocmto
                           tt-retorno.vllanmto = tt-handle.vllanmto
                           par_vllanmto = par_vllanmto + tt-handle.vllanmto
                           par_registro = par_registro + 1. 
            END.
        END.
        ELSE
        IF  par_cdagenci = 0 AND par_nrdconta <> 0  THEN
            DO:
    
            ASSIGN aux_filtros = " WHERE cdcooper  = " + STRING(par_cdcooper) + " AND" +
                                 "       nrdconta  = " + STRING(par_nrdconta) + " AND" +
                                 "       dtmvtolt >= " + STRING(par_dtinicio) + " AND" +
                                 "       dtmvtolt <= " + STRING(par_dttermin) + " AND" +
                                 "       cdhistor  = " + STRING(par_cdhistor).
        
                RUN Busca_Dinamica
                    ( INPUT par_nmestrut,
                      INPUT aux_campos,
                      INPUT aux_filtros,
                      INPUT "",
                      INPUT aux_temptable,
                     OUTPUT TABLE tt-handle). 
        
                FOR EACH tt-handle,
                    FIRST crapass WHERE  crapass.cdcooper = par_cdcooper   AND
                                         crapass.nrdconta = tt-handle.nrdconta
                                         NO-LOCK
                                         BY tt-handle.dtmvtolt
                                         BY crapass.cdagenci
                                         BY tt-handle.nrdconta
                                         BY tt-handle.nrdocmto.
        
                    CREATE tt-retorno.
                    ASSIGN tt-retorno.dtmvtolt = tt-handle.dtmvtolt
                           tt-retorno.cdagenci = crapass.cdagenci
                           tt-retorno.nrdconta = tt-handle.nrdconta
                           tt-retorno.nmprimtl = crapass.nmprimtl
                           tt-retorno.nrdocmto = tt-handle.nrdocmto
                           tt-retorno.vllanmto = tt-handle.vllanmto
                           par_vllanmto = par_vllanmto + tt-handle.vllanmto
                           par_registro = par_registro + 1. 
                END.
           END.
        ELSE
            DO:
                ASSIGN aux_filtros = " WHERE cdcooper  = " + STRING(par_cdcooper) + " AND" +
                                     "       dtmvtolt >= " + STRING(par_dtinicio) + " AND" +
                                     "       dtmvtolt <= " + STRING(par_dttermin) + " AND" +
                                     "       cdhistor  = " + STRING(par_cdhistor).
            
                    RUN Busca_Dinamica
                        ( INPUT par_nmestrut,
                          INPUT aux_campos,
                          INPUT aux_filtros,
                          INPUT "",
                          INPUT aux_temptable,
                         OUTPUT TABLE tt-handle). 
            
                    FOR EACH tt-handle,
                        FIRST crapass WHERE  crapass.cdcooper = par_cdcooper   AND
                                             crapass.nrdconta = tt-handle.nrdconta
                                             NO-LOCK
                                             BY tt-handle.dtmvtolt
                                             BY crapass.cdagenci
                                             BY tt-handle.nrdconta
                                             BY tt-handle.nrdocmto.
            
                        CREATE tt-retorno.
                        ASSIGN tt-retorno.dtmvtolt = tt-handle.dtmvtolt
                               tt-retorno.cdagenci = crapass.cdagenci
                               tt-retorno.nrdconta = tt-handle.nrdconta
                               tt-retorno.nmprimtl = crapass.nmprimtl
                               tt-retorno.nrdocmto = tt-handle.nrdocmto
                               tt-retorno.vllanmto = tt-handle.vllanmto
                               par_vllanmto = par_vllanmto + tt-handle.vllanmto
                               par_registro = par_registro + 1. 
                    END.
               
            END.


    END. /*Busca*/


END PROCEDURE.



/* -------------------------------------------------------------------------- */
/*       EFETUA A BUSCA DA LISTA DE HISTORICOS NO SISTEMA POR LOTE P/PA       */
/* -------------------------------------------------------------------------- */

PROCEDURE Busca_Lote:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tpdopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtinicio AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dttermin AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    

    DEF  VAR aux_cont     AS INTE INIT 0                            NO-UNDO.
    DEF  VAR aux_texto    AS CHAR FORMAT "X(9)"                     NO-UNDO.
    DEF  VAR aux_dslog    AS CHAR                                   NO-UNDO.
    

    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_vllanmto AS DECI FORMAT ">>>,>>>,>>9.99"   NO-UNDO.
    DEF OUTPUT PARAM par_registro AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-craplcm.
    DEF OUTPUT PARAM TABLE FOR tt-craplcm-aux.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Dados Lista Historicos Do Sistema Por Lote".              

    EMPTY TEMP-TABLE tt-craplcm.
    EMPTY TEMP-TABLE tt-erro.
    
    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
                                                                                                
                
        IF  par_cdhistor <> 0   AND
            par_cdhistor <> 8   AND
            par_cdhistor <> 105 AND
            par_cdhistor <> 626 AND
            par_cdhistor <> 889 AND 
            par_cdhistor <> 351 AND
            par_cdhistor <> 770 AND 
            par_cdhistor <> 397 AND 
            par_cdhistor <> 47  AND 
            par_cdhistor <> 621 AND 
            par_cdhistor <> 521    THEN
            DO:
                 ASSIGN aux_cdcritic = 0
                        aux_dscritic = "Historico nao permitido."
                        par_nmdcampo = "".
                 LEAVE Busca.
            END.
  
        IF  par_cdhistor > 0 THEN
            DO:
                FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                                   craphis.cdhistor = par_cdhistor
                                   NO-LOCK NO-ERROR.

                IF NOT AVAILABLE craphis THEN
                    DO:
                        ASSIGN aux_cdcritic = 526
                               aux_dscritic = ""
                               par_nmdcampo = ""
                               par_cdhistor = 0. 
                        LEAVE Busca.
                        

                    END.
            END.

                RUN Terminal_Lote(INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT par_cdoperad,
                                  INPUT par_nmdatela,
                                  INPUT par_idorigem,
                                  INPUT par_cddepart,
                                  INPUT par_dtmvtolt,
                                  INPUT par_cddopcao,
                                  INPUT par_tpdopcao,
                                  INPUT par_cdhistor,
                                  INPUT par_nrdconta,
                                  INPUT par_dtinicio,
                                  INPUT par_dttermin,
                                  INPUT par_nrregist,
                                  INPUT par_nriniseq,
                                  INPUT par_flgerlog,
                                 OUTPUT par_qtregist,        
                                 OUTPUT par_nmdcampo,
                                 OUTPUT par_vllanmto,
                                 OUTPUT par_registro,
                                 OUTPUT TABLE tt-craplcm,    
                                 OUTPUT TABLE tt-craplcm-aux,
                                 OUTPUT TABLE tt-erro).      

       IF par_cddopcao = "T" THEN
           DO: 

               FOR FIRST crapcop WHERE                                                                                         
                          crapcop.cdcooper = par_cdcooper NO-LOCK: END.
    
               IF AVAIL tt-craplcm THEN
                   DO:
                
                       ASSIGN aux_dslog = STRING(par_dtmvtolt, "99/99/9999") + " "     +
                                          STRING(TIME, "HH:MM:SS") + " '-->' "         +
                                          "Operador " + par_cdoperad   + " - "         +
                                          "Visualizou listagem dos historicos, entre " +
                                          STRING(par_dtinicio, "99/99/9999") + " e "   +
                                          STRING(par_dttermin, "99/99/9999")           +
                                          ", filtrando por , historico "               +
                                          STRING(par_cdhistor) + ". >> /usr/coop/" +                                                           
                                                 TRIM(crapcop.dsdircop) +               
                                                 "/log/lislot.log".
    
                       UNIX SILENT VALUE("echo " + aux_dslog).
            
                   END.
               ELSE
                   DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Nenhum Registro Encontrado."
                               par_nmdcampo = "".
                
                        ASSIGN aux_dslog = STRING(par_dtmvtolt, "99/99/9999") + " "         +
                                           STRING(TIME, "HH:MM:SS") + " '-->' "             +
                                           "Operador " + STRING(par_cdoperad) + " - "       +
                                           "Tentou visualizar listagem dos historicos, "    +
                                           "entre " + STRING(par_dtinicio, "99/99/9999")    +
                                           " e " + STRING(par_dttermin, "99/99/9999")       +
                                           ", historico " + STRING(par_cdhistor)            +
                                           ", mas nenhum registro foi encontrado."          +
                                           " >> /usr/coop/" +                                                           
                                                TRIM(crapcop.dsdircop) +               
                                                "/log/lislot.log".
                
                        UNIX SILENT VALUE("echo " + aux_dslog).
      
                        LEAVE Busca.
            
                  END.
           END.

           ASSIGN par_cdhistor = 0.

        
        LEAVE Busca.

    END. /* Busca */

    IF  par_idorigem = 5 THEN DO:                      
        RUN pi_paginacao_lote
            ( INPUT par_nrregist,
            INPUT par_nriniseq,
            INPUT TABLE tt-craplcm,
            OUTPUT par_qtregist,
            OUTPUT TABLE tt-craplcm-aux).
        
        EMPTY TEMP-TABLE tt-craplcm.
    
    END.

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0  OR 
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN

                FIND FIRST tt-erro NO-ERROR.

                IF  AVAIL tt-erro THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.

            ELSE
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT NO,
                                    INPUT 1, /** idseqttl **/
                                    INPUT par_nmdatela,
                                    INPUT 0, /* nrdconta */
                                   OUTPUT aux_nrdrowid).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Lote*/


/* -------------------------------------------------------------------------- */
/*         EFETUA A BUSCA DA LISTA DE HISTORICOS NO SISTEMA POR CAIXA         */
/* -------------------------------------------------------------------------- */

PROCEDURE Busca_Caixa:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tpdopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtinicio AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dttermin AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.            
    
    DEF  VAR aux_cont     AS INTE INIT 0                            NO-UNDO.
    DEF  VAR aux_texto    AS CHAR FORMAT "X(9)"                     NO-UNDO.
    DEF  VAR aux_dslog    AS CHAR                                   NO-UNDO.
    

    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_vllanmto AS DECI  FORMAT ">>>,>>>,>>9.99"  NO-UNDO.
    DEF OUTPUT PARAM par_registro AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-craplcx.
    DEF OUTPUT PARAM TABLE FOR tt-craplcx-aux.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Dados Lista Historicos Do Sistema Por Caixa".              

    EMPTY TEMP-TABLE tt-craplcx.
    EMPTY TEMP-TABLE tt-erro.

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:

        IF  (par_cdagenci <> 0) THEN  
            DO:
                FIND FIRST crapage WHERE crapage.cdagenci = par_cdagenci AND 
                                         crapage.cdcooper = par_cdcooper
                                         NO-LOCK.  
            END.
       
        IF  (par_nrdconta <> 0) THEN
            DO:
                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = par_nrdconta
                                   NO-LOCK NO-ERROR.
            END.
       
        FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                           craphis.cdhistor = par_cdhistor 
                           NO-LOCK NO-ERROR.
    
        IF  NOT AVAILABLE craphis THEN
            DO: 
                ASSIGN aux_cdcritic = 526
                       aux_dscritic = ""
                       par_nmdcampo = ""
                       par_cdagenci = 0  
                       par_cdhistor = 0 
                       par_nrdconta = 0.
                LEAVE Busca.
               
            END.
        ELSE
            IF NOT AVAILABLE crapage AND par_cdagenci <> 0 THEN   
                DO:
                    ASSIGN aux_cdcritic = 15
                           aux_dscritic = ""
                           par_nmdcampo = ""
                           par_cdagenci = 0  
                           par_cdhistor = 0 
                           par_nrdconta = 0.
                    LEAVE Busca.
                END.
        ELSE
            IF NOT AVAILABLE crapass AND par_nrdconta <> 0 THEN
                DO:
                    ASSIGN aux_cdcritic = 127
                           aux_dscritic = ""
                           par_nmdcampo = ""
                           par_cdagenci = 0  
                           par_cdhistor = 0 
                           par_nrdconta = 0.
                    LEAVE Busca.
                END.
        ELSE
            FOR EACH craphis WHERE craphis.cdcooper = par_cdcooper   AND
                                   craphis.cdhistor = par_cdhistor   AND
                                   craphis.nmestrut = "craplcx"
                                   NO-LOCK:
                   
                RUN Terminal_Caixa(INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_cdoperad,
                                   INPUT par_nmdatela,
                                   INPUT par_idorigem,
                                   INPUT par_cddepart,
                                   INPUT par_dtmvtolt,
                                   INPUT par_cddopcao,
                                   INPUT par_tpdopcao,
                                   INPUT par_cdhistor,
                                   INPUT par_nrdconta,
                                   INPUT par_dtinicio,
                                   INPUT par_dttermin,
                                   INPUT par_nrregist,
                                   INPUT par_nriniseq,
                                   INPUT par_flgerlog,
                                  OUTPUT par_nmdcampo,
                                  INPUT-OUTPUT par_vllanmto,
                                  INPUT-OUTPUT par_registro,
                                  INPUT-OUTPUT TABLE tt-craplcx,
                                  OUTPUT TABLE tt-erro).
                aux_cont =  1.
            END.
  
        /** certifica q os historicos seja um dos permitidos */
        IF  aux_cont = 0 THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Historico nao permitido."
                       par_nmdcampo = "".
                LEAVE Busca.
            END.

        IF par_cddopcao = "T" THEN
            DO:

                FOR FIRST crapcop WHERE                                                                                         
                          crapcop.cdcooper = par_cdcooper NO-LOCK: END. 
        
                IF AVAIL tt-craplcx THEN
                    DO:
                
                        ASSIGN aux_dslog = STRING(par_dtmvtolt, "99/99/9999") + " " +
                                           STRING(TIME, "HH:MM:SS") + " '-->' " +
                                           "Operador " + par_cdoperad   + " - " +
                                           "Visualizou listagem dos historicos, entre " +
                                           STRING(par_dtinicio, "99/99/9999") + " e " +
                                           STRING(par_dttermin, "99/99/9999").
            
                        IF par_cdagenci <> 0 THEN
                           DO:
                               ASSIGN aux_dslog = aux_dslog + ", filtrando por, PA "   +
                                                  STRING(par_cdagenci) + ", historico " +
                                                  STRING(par_cdhistor)                  +
                                                  ".>> /usr/coop/" +                                                           
                                                    TRIM(crapcop.dsdircop) +               
                                                  "/log/lislot.log".
                           END.
                        ELSE
                           ASSIGN aux_dslog = aux_dslog + ", filtrando por , historico " +
                                              STRING(par_cdhistor)                       +
                                              ". >> /usr/coop/" +                                                           
                                                TRIM(crapcop.dsdircop) +               
                                                "/log/lislot.log".
            
                        UNIX SILENT VALUE("echo " + aux_dslog).
            
                    END.
                ELSE
                    DO:
                       
                         ASSIGN aux_cdcritic = 0
                                aux_dscritic = "Nenhum Registro Encontrado."
                                par_nmdcampo = "".
            
                         ASSIGN aux_dslog = STRING(par_dtmvtolt, "99/99/9999") + " " +
                                            STRING(TIME, "HH:MM:SS") + " '-->' " +
                                            "Operador " + STRING(par_cdoperad) + " - " +
                                            "Tentou visualizar listagem dos historicos, entre "
                                            + STRING(par_dtinicio, "99/99/9999") + " e " +
                                            STRING(par_dttermin, "99/99/9999").
            
                         IF par_cdagenci <> 0 THEN
                             ASSIGN aux_dslog = aux_dslog + ", filtrando por, PA " +
                                                STRING(par_cdagenci) +
                                                ", historico " + STRING(par_cdhistor)       +
                                                ", mas nenhum registro foi encontrado."     +
                                                " >> /usr/coop/" +                                                           
                                                TRIM(crapcop.dsdircop) +               
                                                "/log/lislot.log".
                         ELSE
                             ASSIGN aux_dslog = aux_dslog + ", historico " + STRING(par_cdhistor) +
                                                ", mas nenhum registro foi encontrado."          +
                                                " >> /usr/coop/" +                                                           
                                                TRIM(crapcop.dsdircop) +               
                                                "/log/lislot.log".
            
                         UNIX SILENT VALUE("echo " + aux_dslog).
            
                         LEAVE Busca.
            
                   END.
            END.

        LEAVE Busca.

    END. /* Busca */

    IF  par_idorigem = 5 THEN DO:                      
        RUN pi_paginacao_caixa
            ( INPUT par_nrregist,
              INPUT par_nriniseq,
              INPUT TABLE tt-craplcx,
              OUTPUT par_qtregist,
              OUTPUT TABLE tt-craplcx-aux).

        EMPTY TEMP-TABLE tt-craplcx.
    
    END.

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0  OR 
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN

                FIND FIRST tt-erro NO-ERROR.

                IF  AVAIL tt-erro THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.

            ELSE
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT NO,
                                    INPUT 1, /** idseqttl **/
                                    INPUT par_nmdatela,
                                    INPUT 0, /* nrdconta */
                                   OUTPUT aux_nrdrowid).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Caixa */


/* -------------------------------------------------------------------------- */
/*          EFETUA A BUSCA TERMINAL QUANDO O TIPO DA OPÇAO FOR CAIXA          */
/* -------------------------------------------------------------------------- */

PROCEDURE Terminal_Caixa:

    DEF  INPUT PARAM par_cdcooper AS INTE                                NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                                NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                                NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                                NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                                NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                                NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                                NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                                NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                                NO-UNDO.
    DEF  INPUT PARAM par_tpdopcao AS CHAR                                NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                                NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                                NO-UNDO.
    DEF  INPUT PARAM par_dtinicio AS DATE                                NO-UNDO.
    DEF  INPUT PARAM par_dttermin AS DATE                                NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                                NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                                NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                                NO-UNDO.
    

    DEF  VAR aux_cont     AS INTE INIT 0                                 NO-UNDO.
    DEF  VAR aux_texto    AS CHAR FORMAT "X(9)"                          NO-UNDO.


    DEF  VAR aux_soma     AS INT                                         NO-UNDO.
    DEF  VAR tot_vllanmto AS DEC                                         NO-UNDO.
    DEF  VAR tot_registro AS INT                                         NO-UNDO.
    DEF  VAR aux_dslog    AS CHAR                                        NO-UNDO.
    DEF  VAR aux_qtdmeses AS INTE                                        NO-UNDO.
    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                                NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vllanmto AS DECI FORMAT ">>>,>>>,>>9.99"  NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_registro AS INTE                          NO-UNDO.

    DEF INPUT-OUTPUT PARAM TABLE FOR tt-craplcx.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Dados Lista Historicos Do Sistema Por Caixa".              

    EMPTY TEMP-TABLE tt-erro.
    
    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:

        aux_soma = 0.

        IF  par_cdagenci <> 0 THEN
            DO:
                FOR EACH craplcx WHERE craplcx.cdcooper =  par_cdcooper  AND
                                       craplcx.cdagenci =  par_cdagenci  AND
                                       craplcx.cdhistor =  par_cdhistor  AND
                                       craplcx.dtmvtolt >= par_dtinicio  AND
                                       craplcx.dtmvtolt <= par_dttermin
                                       NO-LOCK.
   
                    ASSIGN par_vllanmto = par_vllanmto + craplcx.vldocmto
                           par_registro = par_registro + 1.
       
                    CREATE tt-craplcx.
                    BUFFER-COPY craplcx TO tt-craplcx.
   
                END.
            END.
        ELSE                                      
            IF  par_cdagenci = 0 THEN
                DO:
                    FOR EACH craplcx WHERE craplcx.cdcooper =  par_cdcooper  AND
                                           craplcx.cdhistor =  par_cdhistor  AND
                                           craplcx.dtmvtolt >= par_dtinicio  AND
                                           craplcx.dtmvtolt <= par_dttermin
                                           NO-LOCK.
   

                        ASSIGN par_vllanmto = par_vllanmto + craplcx.vldocmto
                               par_registro = par_registro + 1.
   
                        CREATE tt-craplcx.
                        BUFFER-COPY craplcx TO tt-craplcx.
   
                    END.

                END.


        LEAVE Busca.

    END. /* Busca */

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0  OR 
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN

                FIND FIRST tt-erro NO-ERROR.

                IF  AVAIL tt-erro THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.

            ELSE
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT NO,
                                    INPUT 1, /** idseqttl **/
                                    INPUT par_nmdatela,
                                    INPUT 0, /* nrdconta */
                                   OUTPUT aux_nrdrowid).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE. /* Terminal_Caixa */

/* -------------------------------------------------------------------------- */
/*              GERA IMPRESSAO QUANDO O TIPO DA OPÇAO FOR CAIXA               */
/* -------------------------------------------------------------------------- */

PROCEDURE Gera_Impressao_Caixa:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.        
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tpdopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtinicio AS DATE FORMAT "99/99/9999"       NO-UNDO.
    DEF  INPUT PARAM par_dttermin AS DATE FORMAT "99/99/9999"       NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdopcao AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_registro AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vllanmto AS DECI                           NO-UNDO.

    DEF  VAR aux_cont     AS INTE INIT 0                            NO-UNDO.
    DEF  VAR aux_texto    AS CHAR FORMAT "X(9)"                     NO-UNDO.


    DEF  VAR aux_soma     AS INT                                    NO-UNDO.
    DEF  VAR tot_vllanmto AS DEC                                    NO-UNDO.
    DEF  VAR tot_registro AS INT                                    NO-UNDO.
    DEF  VAR aux_dslog    AS CHAR                                   NO-UNDO.
    
    DEF  VAR  aux_dsexthst   LIKE craphis.dsexthst                  NO-UNDO.

    DEF   VAR aux_flgescra           AS LOGI                        NO-UNDO.
    DEF   VAR aux_dscomand           AS CHAR                        NO-UNDO.
    DEF   VAR aux_contador           AS INTE                        NO-UNDO.
    
    DEF   VAR aux_nmendter           AS CHAR                        NO-UNDO. 
    DEF   VAR aux_nmarquiv           AS CHAR                        NO-UNDO.


    DEF OUTPUT PARAM aux_nmarqpdf AS CHAR                           NO-UNDO. 
    DEF OUTPUT PARAM aux_nmarqimp AS CHAR                           NO-UNDO. 
    DEF OUTPUT PARAM par_nmdireto AS CHAR                           NO-UNDO. 
                                    
                                         
    DEF INPUT PARAM TABLE FOR tt-craplcx.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Dados Lista Historicos Do Sistema Por Caixa".              


    EMPTY TEMP-TABLE tt-erro.

    FORM          
        tt-craplcx.dtmvtolt    LABEL "Data"   
        tt-craplcx.cdagenci    LABEL "PA"
        tt-craplcx.nrdcaixa    LABEL "Caixa"
        tt-craplcx.nrdocmto    LABEL "Documento" 
        FORMAT "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz9"
        tt-craplcx.vldocmto    LABEL "Valor"  FORMAT ">>>,>>>,>>9.99"  
    WITH NO-BOX NO-LABEL DOWN FRAME f_rel_historico WIDTH 132. 

    FORM
        "De:"  par_dtinicio         SPACE(3)
        "Ate:" par_dttermin         SPACE(3) 
        "Historico: " par_cdhistor  SPACE 
        "-"                         SPACE
        aux_dsexthst                SKIP(1) 
    WITH FRAME f_dados_2 NO-LABEL NO-BOX WIDTH 132.
   
    FORM SKIP(2)
        "Quantidade de Registros:" AT 1
        par_registro               AT 25 FORMAT ">>>>>>>>9"
        "Valor Total:"             AT 37
        par_vllanmto               AT 50 FORMAT ">>>,>>>,>>9.99"
    WITH NO-BOX NO-LABEL DOWN FRAME f_total WIDTH 132.

    
    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:

        INPUT CLOSE.

        FOR FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK: END.              
                                                                                           
            ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop + "/rl/" + par_dsiduser. 
                                                                                                                                                                                      
            ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)                              
                   aux_nmarqimp = aux_nmendter + ".ex"                                     
                   aux_nmarqpdf = aux_nmendter + ".pdf"
                   aux_nmarquiv = "/micros/" + crapcop.dsdircop + "/" + par_dsiduser
                   aux_nmarquiv = aux_nmarquiv + ".txt"

                   par_nmdireto = aux_nmarquiv.

            FIND FIRST craphis WHERE
                       craphis.cdcooper = par_cdcooper AND
                       craphis.cdhistor = par_cdhistor NO-LOCK NO-ERROR.


            IF  NOT AVAIL craphis THEN
                DO:

                    ASSIGN aux_cdcritic = 526
                           aux_dscritic = "".
                    LEAVE Imprime.

                END.
                
            ASSIGN aux_dsexthst = craphis.dsexthst.
                                                                                           
                                                                                           
            OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.                 
                                                                                           

        /* Cdempres = 11 , Relatorio 452 em 132 colunas */
        { sistema/generico/includes/cabrel.i "11" "452" "132" }


        DISPLAY STREAM str_1 
                       par_dtinicio    
                       par_dttermin
                       par_cdhistor
                       aux_dsexthst
        WITH FRAME f_dados_2.
                                                                                           
                                                                                           
        FOR EACH tt-craplcx:

            DISP STREAM str_1 
                        tt-craplcx.dtmvtolt
                        tt-craplcx.cdagenci
                        tt-craplcx.nrdcaixa
                        tt-craplcx.nrdocmto
                        tt-craplcx.vldocmto 
            WITH FRAME f_rel_historico.
   
            DOWN STREAM str_1 WITH FRAME f_rel_historico.
                                                                                           
            IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN                            
                DO:                                                                      
                    PAGE STREAM str_1.                                                    
                    VIEW STREAM str_1 FRAME f_cabrel132_1.
                    VIEW STREAM str_1 FRAME f_dados_2.                                     
                                                                                           
                END.   

             
        END.

        IF par_registro = 0 THEN
            DO:
                ASSIGN aux_cdcritic = 263
                       aux_dscritic = "".
                LEAVE Imprime.
            END.

        DISPLAY STREAM str_1                 
                       par_registro          
                       par_vllanmto          
        WITH FRAME f_total.                                       
        DOWN STREAM str_1 WITH FRAME f_total.

        OUTPUT STREAM str_1 CLOSE.                                                         

        IF  par_nmdopcao THEN
            DO:
                UNIX SILENT VALUE("ux2dos " + aux_nmarqimp + " > " + aux_nmarquiv).

                /*log*/

                ASSIGN aux_dslog = STRING(par_dtmvtolt, "99/99/9999") + " " +
                                   STRING(TIME, "HH:MM:SS") + " '-->' " +
                                   "Operador " + STRING(par_cdoperad) + " - " +
                                   "Gerou o arquivo " + par_nmdireto + ", com a " +
                                   "listagem dos historicos, entre " +
                                   STRING(par_dtinicio, "99/99/9999") + " e " +
                                   STRING(par_dttermin, "99/99/9999").
    
                IF par_cdagenci <> 0 THEN
                    DO:
                        ASSIGN aux_dslog = aux_dslog + ", filtrando por, PA "   +
                                           STRING(par_cdagenci) + ", historico " +
                                           STRING(par_cdhistor)                  +
                                           ". >> /usr/coop/" +                                                           
                                              TRIM(crapcop.dsdircop) +               
                                              "/log/lislot.log".
                    END.
                ELSE
                    ASSIGN aux_dslog = aux_dslog + ", filtrando por, historico " +
                                       STRING(par_cdhistor)                       +
                                       ". >> /usr/coop/" +                                                           
                                          TRIM(crapcop.dsdircop) +               
                                          "/log/lislot.log".
    
                UNIX SILENT VALUE("echo " + aux_dslog).
            END.
        ELSE
            DO:
        
                ASSIGN aux_dslog = STRING(par_dtmvtolt, "99/99/9999") +
                                   " " + STRING(TIME, "HH:MM:SS") +
                                   " '-->' Operador " +
                                   STRING(par_cdoperad) + " - " +
                                   "Imprimiu o arquivo " + aux_nmarqimp +
                                   ", com a listagem dos historicos, " +
                                   "entre " +
                                   STRING(par_dtinicio, "99/99/9999") +
                                   " e " +
                                   STRING(par_dttermin, "99/99/9999").

                IF par_cdagenci <> 0 THEN
                    DO:
                        ASSIGN aux_dslog = aux_dslog + ", filtrando por, PA "   +
                                           STRING(par_cdagenci) + ", historico " +
                                           STRING(par_cdhistor)                  +
                                           ". >> /usr/coop/" +                                                           
                                              TRIM(crapcop.dsdircop) +               
                                              "/log/lislot.log".
                    END.
                ELSE
                    ASSIGN aux_dslog = aux_dslog + ", filtrando por, historico " +
                                          STRING(par_cdhistor)                      +
                                          ". >> /usr/coop/" +                                                           
                                          TRIM(crapcop.dsdircop) +               
                                          "/log/lislot.log".
    
                UNIX SILENT VALUE("echo " + aux_dslog).
            END.

        IF  par_idorigem = 5  THEN  /** Ayllos Web **/                     
            DO:    
                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT    
                    SET h-b1wgen0024.                                      
                                                                           
                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN                   
                    DO:                                                    
                        ASSIGN aux_dscritic = "Handle invalido para BO " + 
                                              "b1wgen0024.".               
                        LEAVE Imprime.                                     
                    END.                                                   
                                                                           
                RUN envia-arquivo-web IN h-b1wgen0024                      
                    ( INPUT par_cdcooper,                                  
                      INPUT par_cdagenci,                                  
                      INPUT par_nrdcaixa,                                  
                      INPUT aux_nmarqimp,                                  
                     OUTPUT aux_nmarqpdf,                                  
                     OUTPUT TABLE tt-erro ).                               
                                                                           
                IF  VALID-HANDLE(h-b1wgen0024)  THEN                       
                    DELETE PROCEDURE h-b1wgen0024.                         
                                                                           
                IF  RETURN-VALUE <> "OK" THEN                              
                    RETURN "NOK".                                          
            END.
        
        LEAVE Imprime.

    END. /* Imprime */

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0  OR 
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN

                FIND FIRST tt-erro NO-ERROR.

                IF  AVAIL tt-erro THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.
                
            ELSE
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT NO,
                                    INPUT 1, /** idseqttl **/
                                    INPUT par_nmdatela,
                                    INPUT 0, /* nrdconta */
                                   OUTPUT aux_nrdrowid).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* Gera_Impressao_Caixa*/


/* -------------------------------------------------------------------------- */
/*          EFETUA A BUSCA TERMINAL QUANDO O TIPO DA OPÇAO FOR LOTE           */
/* -------------------------------------------------------------------------- */

PROCEDURE Terminal_Lote:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tpdopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtinicio AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dttermin AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    

    DEF  VAR aux_cont     AS INTE INIT 0                            NO-UNDO.
    DEF  VAR aux_texto    AS CHAR FORMAT "X(9)"                     NO-UNDO.

    DEF  VAR aux_data     AS DATE                                   NO-UNDO. 
    
    DEF  VAR aux_soma     AS INT                                    NO-UNDO.
    DEF  VAR tot_vllanmto AS DEC                                    NO-UNDO.
    DEF  VAR tot_registro AS INT                                    NO-UNDO.
    DEF  VAR aux_dslog    AS CHAR                                   NO-UNDO.
    

    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_vllanmto AS DECI FORMAT ">>>,>>>,>>9.99"   NO-UNDO.
    DEF OUTPUT PARAM par_registro AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-craplcm.
    DEF OUTPUT PARAM TABLE FOR tt-craplcm-aux.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Dados Lista Historicos Do Sistema Por Caixa".              

    EMPTY TEMP-TABLE tt-craplcm.
    EMPTY TEMP-TABLE tt-erro.
    
    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:


        IF par_cdhistor = 0 THEN
            DO:

                
                DO aux_data = par_dtinicio TO par_dttermin:

                    FOR EACH craplcm WHERE (craplcm.cdcooper = par_cdcooper AND
                                            craplcm.dtmvtolt = aux_data     AND 
                                            craplcm.cdhistor = 8  )         OR
                                           (craplcm.cdcooper = par_cdcooper AND
                                            craplcm.dtmvtolt = aux_data     AND 
                                            craplcm.cdhistor = 105 )        OR
                                           (craplcm.cdcooper = par_cdcooper AND
                                            craplcm.dtmvtolt = aux_data     AND 
                                            craplcm.cdhistor = 626 )        OR
                                           (craplcm.cdcooper = par_cdcooper AND
                                            craplcm.dtmvtolt = aux_data     AND 
                                            craplcm.cdhistor = 889 )        OR
                                           (craplcm.cdcooper = par_cdcooper AND
                                            craplcm.dtmvtolt = aux_data     AND 
                                            craplcm.cdhistor = 351 )        OR
                                           (craplcm.cdcooper = par_cdcooper AND
                                            craplcm.dtmvtolt = aux_data     AND 
                                            craplcm.cdhistor = 770 )        OR
                                           (craplcm.cdcooper = par_cdcooper AND
                                            craplcm.dtmvtolt = aux_data     AND 
                                            craplcm.cdhistor = 397 )        OR
                                           (craplcm.cdcooper = par_cdcooper AND
                                            craplcm.dtmvtolt = aux_data     AND 
                                            craplcm.cdhistor = 47  )        OR
                                           (craplcm.cdcooper = par_cdcooper AND
                                            craplcm.dtmvtolt = aux_data     AND 
                                            craplcm.cdhistor = 621 )        OR
                                           (craplcm.cdcooper = par_cdcooper AND
                                            craplcm.dtmvtolt = aux_data     AND 
                                            craplcm.cdhistor = 521 )    NO-LOCK
                                            BREAK BY craplcm.dtmvtolt
                                                  BY craplcm.cdagenci
                                                  BY craplcm.nrdconta
                                                  BY craplcm.cdbccxlt
                                                  BY craplcm.nrdolote
                                                  BY craplcm.vllanmto
                                                  BY craplcm.cdhistor.
                  
                        ASSIGN par_vllanmto = par_vllanmto + craplcm.vllanmto
                               par_registro = par_registro + 1.
            
                        CREATE tt-craplcm.
                        BUFFER-COPY craplcm TO tt-craplcm.
                    END.
                END.
            END.
        ELSE
            DO:
                DO aux_data = par_dtinicio TO par_dttermin:

                    FOR EACH craplcm WHERE craplcm.cdcooper  = par_cdcooper AND
                                           craplcm.dtmvtolt  = aux_data     AND
                                           craplcm.cdhistor  = par_cdhistor NO-LOCK
                                           BREAK BY craplcm.dtmvtolt
                                                 BY craplcm.cdagenci
                                                 BY craplcm.nrdconta
                                                 BY craplcm.cdbccxlt
                                                 BY craplcm.nrdolote
                                                 BY craplcm.vllanmto
                                                 BY craplcm.cdhistor.
                  
                        ASSIGN par_vllanmto = par_vllanmto + craplcm.vllanmto
                               par_registro = par_registro + 1.
            
                        CREATE tt-craplcm.
                        BUFFER-COPY craplcm TO tt-craplcm.
                    END.
                END.
            END.

        LEAVE Busca.

    END. /* Busca */

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0  OR 
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN

                FIND FIRST tt-erro NO-ERROR.

                IF  AVAIL tt-erro THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.

            ELSE
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT NO,
                                    INPUT 1, /** idseqttl **/
                                    INPUT par_nmdatela,
                                    INPUT 0, /* nrdconta */
                                   OUTPUT aux_nrdrowid).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE. /* Terminal_Lote */

/* -------------------------------------------------------------------------- */
/*              GERA IMPRESSAO QUANDO O TIPO DA OPÇAO FOR LOTE                */
/* -------------------------------------------------------------------------- */

PROCEDURE Gera_Impressao_Lote:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.        
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tpdopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtinicio AS DATE FORMAT "99/99/9999"       NO-UNDO.
    DEF  INPUT PARAM par_dttermin AS DATE FORMAT "99/99/9999"       NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdopcao AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_vllanmto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_registro AS INTE                           NO-UNDO.

    DEF  VAR aux_cont     AS INTE INIT 0                            NO-UNDO.
    DEF  VAR aux_texto    AS CHAR FORMAT "X(9)"                     NO-UNDO.
    DEF  VAR aux_dsvlrtot AS CHAR                                   NO-UNDO.


    DEF  VAR aux_soma     AS INT                                    NO-UNDO.
    DEF  VAR tot_vllanmto AS DEC                                    NO-UNDO.
    DEF  VAR tot_registro AS INT                                    NO-UNDO.
    DEF  VAR aux_dslog    AS CHAR                                   NO-UNDO.
   
    DEF  VAR  aux_dsexthst   LIKE craphis.dsexthst                  NO-UNDO.
    DEF  VAR  aux_nmarquiv           AS CHAR                        NO-UNDO.

    DEF   VAR aux_flgescra           AS LOGI                        NO-UNDO.
    DEF   VAR aux_dscomand           AS CHAR                        NO-UNDO.
    DEF   VAR aux_contador           AS INTE                        NO-UNDO.
    DEF   VAR aux_vlpalcto           AS DECI                        NO-UNDO.
    
    DEF   VAR aux_nmendter           AS CHAR                        NO-UNDO.   
                                                                    
    DEF OUTPUT PARAM aux_nmarqpdf AS CHAR                           NO-UNDO. 
    DEF OUTPUT PARAM aux_nmarqimp AS CHAR                           NO-UNDO. 
    DEF OUTPUT PARAM par_nmdireto AS CHAR                           NO-UNDO. 

    DEF INPUT  PARAM TABLE FOR tt-craplcm.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Dados Lista Historicos Do Sistema Por Lote".              

    EMPTY TEMP-TABLE tt-erro.


    FORM tt-craplcm.dtmvtolt    LABEL "Data"   
         tt-craplcm.cdagenci    LABEL "PA"
         tt-craplcm.nrdconta    LABEL "Conta/Dv."
         tt-craplcm.cdbccxlt    LABEL "Banco/Caixa" FORMAT "zz9"
         tt-craplcm.nrdolote    LABEL "Lote"        FORMAT "zzz,zz9"
         tt-craplcm.vllanmto    LABEL "Valor"       FORMAT "zzz,zzz,zzz,zz9.99"
         tt-craplcm.cdhistor    LABEL "Historico"   FORMAT "zzz9"  
    WITH FRAME f_rel_historico NO-BOX NO-LABEL DOWN WIDTH 132.

    FORM "De:"  par_dtinicio         SPACE(3)
         "Ate:" par_dttermin         SPACE(3) 
         "Historico: " par_cdhistor  SPACE 
         "-"                         SPACE
         aux_dsexthst
         SKIP(1) 
    WITH FRAME f_dados_2 NO-LABEL NO-BOX WIDTH 132.

    FORM SKIP(2)
         aux_dsvlrtot       FORMAT "x(25)"
         aux_vlpalcto AT 51 FORMAT ">>>,>>>,>>9.99"
         SKIP(1)
    WITH FRAME f_total NO-LABEL NO-BOX DOWN WIDTH 132.

    
    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:


        FOR FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK: END.              
                                                                                           
            ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop + "/rl/" + par_dsiduser. 
                                                                                           
            ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)                              
                   aux_nmarqimp = aux_nmendter + ".ex"                                     
                   aux_nmarqpdf = aux_nmendter + ".pdf"
                   aux_nmarquiv = "/micros/" + crapcop.dsdircop + "/" + par_dsiduser
                   aux_nmarquiv = aux_nmarquiv + ".txt". 

                   par_nmdireto = aux_nmarquiv.

            IF par_cdhistor = 0 THEN
                ASSIGN aux_dsexthst = "8,105,626,889".
            ELSE
                DO:

                    FIND FIRST craphis WHERE
                               craphis.cdcooper = par_cdcooper AND
                               craphis.cdhistor = par_cdhistor NO-LOCK NO-ERROR.


            IF  NOT AVAIL craphis THEN
                DO:
                    ASSIGN aux_cdcritic = 526
                           aux_dscritic = "".
                    LEAVE Imprime.
                END.



                    ASSIGN aux_dsexthst = craphis.dsexthst.
                END.
                                                                                           
                                                                                           
            OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.                 
                                                                                           
        /* Cdempres = 11 , Relatorio 452 em 132 colunas */
        { sistema/generico/includes/cabrel.i "11" "452" "132" }


        DISPLAY STREAM str_1 
                       par_dtinicio    
                       par_dttermin
                       par_cdhistor
                       aux_dsexthst
        WITH FRAME f_dados_2.
                                                                                           
                                                                                           
        FOR EACH tt-craplcm NO-LOCK
            BREAK BY tt-craplcm.cdagenci
                     BY tt-craplcm.dtmvtolt
                       BY tt-craplcm.nrdconta
                         BY tt-craplcm.cdbccxlt
                           BY tt-craplcm.nrdolote
                             BY tt-craplcm.vllanmto
                                BY tt-craplcm.cdhistor:


            ASSIGN aux_vlpalcto = aux_vlpalcto + tt-craplcm.vllanmto.

            DISP STREAM str_1 
                        tt-craplcm.dtmvtolt
                        tt-craplcm.cdagenci
                        tt-craplcm.nrdconta
                        tt-craplcm.cdbccxlt
                        tt-craplcm.nrdolote
                        tt-craplcm.vllanmto
                        tt-craplcm.cdhistor
            WITH FRAME f_rel_historico.
   
            DOWN STREAM str_1 WITH FRAME f_rel_historico.

            /* Totalizador por agencia */
            IF LAST-OF(tt-craplcm.cdagenci) THEN
                DO:
                    ASSIGN aux_dsvlrtot = "Valor Total PA " +
                                           STRING(tt-craplcm.cdagenci) + ":".
    
                    DISP STREAM str_1
                                aux_dsvlrtot
                                aux_vlpalcto
                    WITH FRAME f_total.
    
                     ASSIGN aux_vlpalcto = 0.
                 END.

                                                                                                           
            IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN                            
                DO:                                                                      
                    PAGE STREAM str_1.                                                    
                    VIEW STREAM str_1 FRAME f_cabrel132_1.
                    VIEW STREAM str_1 FRAME f_dados_2.                                     
                                                                                           
                END.   

        END.

        IF par_registro = 0 THEN
            DO:
                ASSIGN aux_cdcritic = 263
                       aux_dscritic = "".
                LEAVE Imprime.
                                  
            END.                                             

        DOWN STREAM str_1 WITH FRAME f_total.

        ASSIGN aux_dsvlrtot = "Total Geral:".
               aux_vlpalcto = par_vllanmto.
    
        DISPLAY STREAM str_1
                       aux_dsvlrtot
                       aux_vlpalcto
        WITH FRAME f_total.
                                          
        OUTPUT STREAM str_1 CLOSE.                                                         

        IF  par_nmdopcao THEN
            DO:
                UNIX SILENT VALUE("ux2dos " + aux_nmarqimp + " > " + aux_nmarquiv).

                /*log*/

                ASSIGN aux_dslog = STRING(par_dtmvtolt, "99/99/9999") + " "       +
                                   STRING(TIME, "HH:MM:SS") + " '-->' "           +
                                   "Operador " + STRING(par_cdoperad) + " - "     +
                                   "Gerou o arquivo " + par_nmdireto + ", com a " +
                                   "listagem dos historicos, entre "              +
                                   STRING(par_dtinicio, "99/99/9999") + " e "     +
                                   STRING(par_dttermin, "99/99/9999")             +
                                   ", filtrando por, historico "                  +
                                   STRING(par_cdhistor)  +  ". >> /usr/coop/" +                                                           
                                                            TRIM(crapcop.dsdircop) +               
                                                            "/log/lislot.log".
        
                UNIX SILENT VALUE("echo " + aux_dslog).
            END.
        ELSE
            DO:
                
                ASSIGN aux_dslog = STRING(par_dtmvtolt, "99/99/9999")   +
                                   " " + STRING(TIME, "HH:MM:SS")       +
                                   " '-->' Operador "                   +
                                   STRING(par_cdoperad) + " - "         +
                                   "Imprimiu o arquivo " + aux_nmarqimp +
                                   ", com a listagem dos historicos, "  +
                                   "entre "                             +
                                   STRING(par_dtinicio, "99/99/9999")   +
                                   " e "                                +
                                   STRING(par_dttermin, "99/99/9999")   +
                                   ", filtrando por, historico "        +
                                   STRING(par_cdhistor)                 +
                                   ". >> /usr/coop/" +                                                           
                                      TRIM(crapcop.dsdircop) +               
                                      "/log/lislot.log".
    
                UNIX SILENT VALUE("echo " + aux_dslog).
            END.
        IF  par_idorigem = 5  THEN  /** Ayllos Web **/                     
            DO:
                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT    
                    SET h-b1wgen0024.                                      
                                                                           
                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN                   
                    DO:                                                    
                        ASSIGN aux_dscritic = "Handle invalido para BO " + 
                                              "b1wgen0024.".               
                        LEAVE Imprime.                                     
                    END.                                                   
                                                                           
                RUN envia-arquivo-web IN h-b1wgen0024                      
                    ( INPUT par_cdcooper,                                  
                      INPUT par_cdagenci,                                  
                      INPUT par_nrdcaixa,                                  
                      INPUT aux_nmarqimp,                                  
                     OUTPUT aux_nmarqpdf,                                  
                     OUTPUT TABLE tt-erro ).                               
                                                                           
                IF  VALID-HANDLE(h-b1wgen0024)  THEN                       
                    DELETE PROCEDURE h-b1wgen0024.                         
                                                                           
                IF  RETURN-VALUE <> "OK" THEN                              
                    RETURN "NOK".                                          
            END.
        
        LEAVE Imprime.

    END. /* Imprime */

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0  OR 
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN

                FIND FIRST tt-erro NO-ERROR.

                IF  AVAIL tt-erro THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.
                
            ELSE
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT NO,
                                    INPUT 1, /** idseqttl **/
                                    INPUT par_nmdatela,
                                    INPUT 0, /* nrdconta */
                                   OUTPUT aux_nrdrowid).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* Gera_Impressao_Lote*/


/* -------------------------------------------------------------------------- */
/*            GERA IMPRESSAO QUANDO O TIPO DA OPÇAO FOR COOPERADO             */
/* -------------------------------------------------------------------------- */

PROCEDURE Gera_Impressao_Cooperado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddepart AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtinicio AS DATE FORMAT "99/99/9999"       NO-UNDO.
    DEF  INPUT PARAM par_dttermin AS DATE FORMAT "99/99/9999"       NO-UNDO.
    

    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    
    DEF  INPUT PARAM par_nmdopcao AS LOGI                           NO-UNDO.

    DEF VAR aux_dsexthst   LIKE craphis.dsexthst                    NO-UNDO.
    
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_registro AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vllanmto AS DECI                           NO-UNDO.
    
    DEF  VAR aux_cont     AS INTE INIT 0                            NO-UNDO.
    DEF  VAR aux_texto    AS CHAR FORMAT "X(9)"                     NO-UNDO.


    DEF  VAR aux_soma     AS INT                                    NO-UNDO.
    DEF  VAR tot_vllanmto AS DEC                                    NO-UNDO.
    DEF  VAR tot_registro AS INT                                    NO-UNDO.
    DEF  VAR aux_dslog    AS CHAR                                   NO-UNDO.


    /* Variaveis de Impressao */

    DEF   VAR aux_flgescra           AS LOGI                        NO-UNDO.
    DEF   VAR aux_dscomand           AS CHAR                        NO-UNDO.
    DEF   VAR aux_contador           AS INTE                        NO-UNDO. 
    DEF   VAR aux_nmendter           AS CHAR                        NO-UNDO.
    DEF   VAR aux_qtdmeses           AS INTE                        NO-UNDO.   
    DEF   VAR aux_nmarquiv           AS CHAR                        NO-UNDO.
    
    DEF OUTPUT PARAM aux_nmarqpdf AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmdireto AS CHAR                           NO-UNDO.
    
    
    DEF INPUT PARAM TABLE FOR tt-retorno.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Dados Lista Historicos Do Sistema Por Lote".              

    EMPTY TEMP-TABLE tt-erro.

    FORM
        tt-retorno.dtmvtolt   LABEL "Data"
        tt-retorno.cdagenci   LABEL "PA "
        tt-retorno.nrdconta   LABEL "Conta"
        tt-retorno.nmprimtl   LABEL "Titular"
                              FORMAT "x(50)"
        tt-retorno.nrdocmto   LABEL "Documento"
                              FORMAT "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz9"
        tt-retorno.vllanmto   LABEL "Valor" FORMAT ">>>,>>>,>>9.99"
    WITH NO-BOX NO-LABEL DOWN FRAME f_rel_historico WIDTH 132.


    FORM
        "De:" par_dtinicio           SPACE(3)
        "Ate:"  par_dttermin         SPACE(3)
        "Historico: " par_cdhistor   SPACE
        "-"                          SPACE
        aux_dsexthst SKIP(1)
        WITH FRAME f_dados2 NO-LABEL NO-BOX WIDTH 132.
    
    FORM SKIP(2)
         "Quantidade de Registros:" AT 1
         par_registro               AT 25 FORMAT ">>>>>>>>9"
         "Valor Total:"             AT 37
         par_vllanmto               AT 50 FORMAT ">>>,>>>,>>9.99"
    WITH NO-BOX NO-LABEL DOWN FRAME f_total WIDTH 132.


    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:

        aux_qtdmeses = (par_dttermin - par_dtinicio) / 30.                                
                                                                                          
        IF  aux_qtdmeses > 3  THEN                                                        
            DO:      

                ASSIGN aux_cdcritic = 0                                                                            
                       aux_dscritic = "Nao e possivel listar em um periodo superior a 3 meses.".
                       
                LEAVE Imprime.                                                                   

            END.                                                                          

        FOR FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK: END.              
                                                                                           
            ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop + "/rl/" + par_dsiduser. 
                                                                                                                                                                                      
            ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)                              
                   aux_nmarqimp = aux_nmendter + ".ex"                                     
                   aux_nmarqpdf = aux_nmendter + ".pdf"

                   aux_nmarquiv = "/micros/" + crapcop.dsdircop + "/" + par_dsiduser
                   aux_nmarquiv = aux_nmarquiv + ".txt"

                   par_nmdireto = aux_nmarquiv.

            FIND FIRST craphis WHERE
                       craphis.cdcooper = par_cdcooper AND
                       craphis.cdhistor = par_cdhistor NO-LOCK NO-ERROR.
            
            ASSIGN aux_dsexthst = craphis.dsexthst.
                                                                                           
                                                                                           
            OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.                 

        /* Cdempres = 11 , Relatorio 452 em 132 colunas */
        { sistema/generico/includes/cabrel.i "11" "452" "132" }


        DISPLAY STREAM str_1 par_dtinicio    
                             par_dttermin
                             par_cdhistor
                             aux_dsexthst
        WITH FRAME f_dados2.
                                                                                           
                                                                                           
        FOR EACH tt-retorno:

            DISP STREAM str_1
                         tt-retorno.dtmvtolt
                         tt-retorno.cdagenci
                         tt-retorno.nrdconta
                         tt-retorno.nmprimtl
                         tt-retorno.nrdocmto
                         tt-retorno.vllanmto
                         WITH FRAME f_rel_historico.
            DOWN STREAM str_1 WITH FRAME f_rel_historico.
                                                                                           
            IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN                            
                DO:                                                                      
                    PAGE STREAM str_1.                                                    
                    VIEW STREAM str_1 FRAME f_cabrel132_1.
                    VIEW STREAM str_1 FRAME f_dados2.                                                                                                                                
                END.   

        END.

        IF par_registro = 0 THEN
            DO:
                ASSIGN aux_cdcritic = 263
                       aux_dscritic = "".
                LEAVE Imprime.
                                      
            END.

        
        DISPLAY STREAM str_1
            par_registro
            par_vllanmto
        WITH FRAME f_total.
        DOWN STREAM str_1 WITH FRAME f_total.

                                          
        OUTPUT STREAM str_1 CLOSE.  

        /*log*/
        IF  par_nmdopcao  THEN
            DO:
                UNIX SILENT VALUE("ux2dos " + aux_nmarqimp + " > " + aux_nmarquiv).

                ASSIGN aux_dslog = STRING(par_dtmvtolt, "99/99/9999") + " " +
                                   STRING(TIME, "HH:MM:SS") + " '-->' " +
                                   "Operador " + STRING(par_cdoperad) + " - " +
                                   "Gerou o arquivo " + par_nmdireto + ", com a " +
                                   "listagem dos historicos, entre " +
                                   STRING(par_dtinicio, "99/99/9999") + " e " +
                                   STRING(par_dttermin, "99/99/9999") +
                                   ", filtrando por".
        
                IF par_cdagenci <> 0 THEN
                    ASSIGN aux_dslog = aux_dslog + ", PA " + STRING(par_cdagenci).
        
                    ASSIGN aux_dslog = aux_dslog + ", historico " + STRING(par_cdhistor).
        
                IF par_nrdconta <> 0 THEN
                    ASSIGN aux_dslog = aux_dslog + ", conta/dv " + STRING(par_nrdconta).
        
                    ASSIGN aux_dslog = aux_dslog + ". >> /usr/coop/" +                                                           
                                                      TRIM(crapcop.dsdircop) +               
                                                      "/log/lislot.log".
        
                UNIX SILENT VALUE("echo " + aux_dslog).

            END.
        ELSE 
            DO:
                ASSIGN aux_dslog = STRING(par_dtmvtolt, "99/99/9999") +
                                    " " + STRING(TIME, "HH:MM:SS") +
                                    " '-->' Operador " +
                                    STRING(par_cdoperad) + " - " +
                                    "Imprimiu o arquivo " + aux_nmarqimp +
                                    ", com a listagem dos historicos, " +
                                    "entre " +
                                    STRING(par_dtinicio, "99/99/9999") +
                                    " e " +
                                    STRING(par_dttermin, "99/99/9999") +
                                    ", filtrando por".

                IF par_cdagenci <> 0 THEN
                    ASSIGN aux_dslog = aux_dslog + ", PA " + STRING(par_cdagenci).

                ASSIGN aux_dslog = aux_dslog + ", historico " +
                                   STRING(par_cdhistor).

                IF par_nrdconta <> 0 THEN
                    ASSIGN aux_dslog = aux_dslog + ", conta/dv " +
                                       STRING(par_nrdconta).

                ASSIGN aux_dslog = aux_dslog + ". >> /usr/coop/" +                                                           
                                                       TRIM(crapcop.dsdircop) +               
                                                       "/log/lislot.log".
               
                UNIX SILENT VALUE("echo " + aux_dslog).
            END.
        
            IF  par_idorigem = 5  THEN  /** Ayllos Web **/                     
            DO: 

                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT    
                    SET h-b1wgen0024.                                      
                                                                           
                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN                   
                    DO:                                                    
                        ASSIGN aux_dscritic = "Handle invalido para BO " + 
                                              "b1wgen0024.".               
                        LEAVE Imprime.                                     
                    END.                                                   
                                                                           
                RUN envia-arquivo-web IN h-b1wgen0024                      
                    ( INPUT par_cdcooper,                                  
                      INPUT par_cdagenci,                                  
                      INPUT par_nrdcaixa,                                  
                      INPUT aux_nmarqimp,                                  
                     OUTPUT aux_nmarqpdf,                                  
                     OUTPUT TABLE tt-erro ).                               
                                                                           
                IF  VALID-HANDLE(h-b1wgen0024)  THEN                       
                    DELETE PROCEDURE h-b1wgen0024.                         
                                                                           
                IF  RETURN-VALUE <> "OK" THEN                              
                    RETURN "NOK".                                          
            END.                                                           

        LEAVE Imprime.

    END. /* Imprime */

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0  OR 
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN

                FIND FIRST tt-erro NO-ERROR.

                IF  AVAIL tt-erro THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.
                
            ELSE
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT NO,
                                    INPUT 1, /** idseqttl **/
                                    INPUT par_nmdatela,
                                    INPUT 0, /* nrdconta */
                                   OUTPUT aux_nrdrowid).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* Gera_Impressao_Cooperado*/


PROCEDURE pi_paginacao:

    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF  INPUT PARAM TABLE FOR tt-retorno.

    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-lislot-aux.

    ASSIGN aux_nrregist = par_nrregist.

    EMPTY TEMP-TABLE tt-lislot-aux.

    Pagina: DO ON ERROR UNDO Pagina, LEAVE Pagina:
        

        FOR EACH tt-retorno:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                    CREATE tt-lislot-aux.
                    BUFFER-COPY tt-retorno TO tt-lislot-aux.
                END.

            ASSIGN aux_nrregist = aux_nrregist - 1.

        END.

    END. /* Pagina */

    RETURN "OK".

END PROCEDURE. /*pi_paginacao*/

PROCEDURE pi_paginacao_caixa:

    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF  INPUT PARAM TABLE FOR tt-craplcx.

    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-craplcx-aux.

    ASSIGN aux_nrregist = par_nrregist.

    EMPTY TEMP-TABLE tt-craplcx-aux.

    Pagina: DO ON ERROR UNDO Pagina, LEAVE Pagina:
        

        FOR EACH tt-craplcx:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                    CREATE tt-craplcx-aux.
                    BUFFER-COPY tt-craplcx TO tt-craplcx-aux.
                END.

            ASSIGN aux_nrregist = aux_nrregist - 1.

        END.

    END. /* Pagina */

    RETURN "OK".

END PROCEDURE. /*pi_paginacao_caixa*/

PROCEDURE pi_paginacao_lote:

    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF  INPUT PARAM TABLE FOR tt-craplcm.

    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-craplcm-aux.

    ASSIGN aux_nrregist = par_nrregist.

    EMPTY TEMP-TABLE tt-craplcm-aux.

    Pagina: DO ON ERROR UNDO Pagina, LEAVE Pagina:
        

        FOR EACH tt-craplcm:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                    CREATE tt-craplcm-aux.
                    BUFFER-COPY tt-craplcm TO tt-craplcm-aux.
                END.

            ASSIGN aux_nrregist = aux_nrregist - 1.

        END.

    END. /* Pagina */

    RETURN "OK".

END PROCEDURE. /*pi_paginacao_lote*/


