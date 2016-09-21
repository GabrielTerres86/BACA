/*..............................................................................

    Programa: b1wgen0029.p
    Autor   : Guilherme
    Data    : Julho/2008                     Ultima Atualizacao:   /  /
           
    Dados referentes ao programa:
                
    Objetivo  : BO de uso do F2 (Ajuda) das telas.    
                    
    Alteracoes:
                        
..............................................................................*/

{ sistema/generico/includes/b1wgen0029tt.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

PROCEDURE busca_help:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_nmrotina AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_inrotina AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-f2.

    DEF VAR h-b1wgen9999 AS HANDLE                  NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-f2.
    
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
        SET h-b1wgen9999.
                          
    IF  VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            RUN p-conectagener IN h-b1wgen9999.
                          
            IF  RETURN-VALUE = "OK"  THEN
                DO:
                    RUN sistema/generico/procedures/b1wgen0029a.p
                                                        (INPUT par_cdcooper,
                                                         INPUT par_nmdatela,
                                                         INPUT par_nmrotina,
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_inrotina,
                                                        OUTPUT TABLE tt-f2).
                    IF  RETURN-VALUE = "NOK"  THEN
                        DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Ajuda nao cadastrada.".
        
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,            /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                           
                            RUN p-desconectagener IN h-b1wgen9999.

                            DELETE PROCEDURE h-b1wgen9999.
                            
                            RETURN "NOK".
                        END.
                
                    RUN p-desconectagener IN h-b1wgen9999.
                END.
            ELSE
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Nao foi possivel conectar ao banco"
                                          + " generico.".
        
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                           
                    DELETE PROCEDURE h-b1wgen9999.
                    
                    RETURN "NOK".
                END.

            DELETE PROCEDURE h-b1wgen9999.
        END.
    ELSE
        DO:
             ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Nao foi possivel conectar ao banco generico".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).                
                            
             DELETE PROCEDURE h-b1wgen9999.
             
             RETURN "NOK".
        
        END.
        
    RETURN "OK".                                                   
    
END.

/* .......................................................................... */
