
/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0169.p
    Autor   : Jorge I. Hamaguchi
    Data    : Agosto/2013                Ultima Atualizacao: 12/12/2013
     
    Dados referentes ao programa:
   
    Objetivo  : BO referente a tela CADRET
                 
    Alteracoes: 12/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)

				24/06/2016 - Adicionar o parametro par_cdprodut (Renato - Supero)

.............................................................................*/

{ sistema/generico/includes/b1wgen0169tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }



/*****************************************************************************
  Consultar cadastro de retorno      
******************************************************************************/
PROCEDURE consultar_cadret:

    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_idorigem AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_cddopcao AS CHAR                           NO-UNDO.
	DEF  INPUT  PARAM par_cdprodut AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperac AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_nrtabela AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdretorn AS INTE                           NO-UNDO.
    
    DEF  OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.
    DEF  OUTPUT PARAM TABLE FOR tt-cadret.


    DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-cadret.

    RUN valida_operad_depto(INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                           OUTPUT par_nmdcampo,
                           OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK" THEN
       RETURN "NOK".
                                        
    IF par_cddopcao = "C" THEN
    DO:
        FOR EACH craprto WHERE craprto.cdprodut = par_cdprodut  /* => 1 - produto GRAVAMES / 2 - Alienação de imóveis */
                           AND craprto.cdoperac = par_cdoperac
                           AND craprto.nrtabela = par_nrtabela
                           NO-LOCK:
    
            CREATE tt-cadret.
            ASSIGN tt-cadret.cdoperac = craprto.cdoperac
                   tt-cadret.nrtabela = craprto.nrtabela
                   tt-cadret.cdretorn = craprto.cdretorn
                   tt-cadret.dsretorn = craprto.dsretorn.
        END.
    END.
    ELSE IF par_cddopcao = "A" THEN
    DO:
        FIND FIRST craprto WHERE craprto.cdprodut = par_cdprodut  /* => 1 - produto GRAVAMES / 2 - Alienação de imóveis */
                             AND craprto.cdoperac = par_cdoperac
                             AND craprto.nrtabela = par_nrtabela
                             AND craprto.cdretorn = par_cdretorn
                             NO-LOCK NO-ERROR.
        
        IF NOT AVAIL craprto THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Cadastro de Retorno nao cadastrado!"
                   par_nmdcampo = "cdretorn".
      
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
      
            RETURN "NOK".
        END.
    
        CREATE tt-cadret.
        ASSIGN tt-cadret.cdoperac = craprto.cdoperac
               tt-cadret.nrtabela = craprto.nrtabela
               tt-cadret.cdretorn = craprto.cdretorn
               tt-cadret.dsretorn = craprto.dsretorn.
    END.

    RETURN "OK".

END PROCEDURE.


/*****************************************************************************
  Incluir Retorno      
******************************************************************************/
    
PROCEDURE incluir_cadret:

    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_idorigem AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_cddopcao AS CHAR                           NO-UNDO.
	DEF  INPUT  PARAM par_cdprodut AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperac AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_nrtabela AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdretorn AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_dsretorn AS CHAR                           NO-UNDO.

    DEF  OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.


    DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    RUN valida_operad_depto(INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                           OUTPUT par_nmdcampo,
                           OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK" THEN
       RETURN "NOK".
                                        
    IF par_cdretorn = 0 OR TRIM(par_dsretorn) = "" THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Codigo ou Descricao invalido!"
               par_nmdcampo = "cdretorn".
  
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
  
        RETURN "NOK".
    END.

    IF CAN-FIND(craprto WHERE craprto.cdprodut = par_cdprodut  /* => 1 - produto GRAVAMES / 2 - Alienação de imóveis */
                          AND craprto.cdoperac = par_cdoperac
                          AND craprto.nrtabela = par_nrtabela
                          AND craprto.cdretorn = par_cdretorn
                          NO-LOCK) THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Este cadastro de retorno ja se " +
                              "encontra cadastrado!"
               par_nmdcampo = "cdretorn".
  
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
  
        RETURN "NOK".
    END.

    CREATE craprto.
    ASSIGN craprto.cdprodut = par_cdprodut
           craprto.cdoperac = par_cdoperac
           craprto.nrtabela = par_nrtabela
           craprto.cdretorn = par_cdretorn
           craprto.dsretorn = par_dsretorn.
    VALIDATE craprto.

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
  Alterar Retorno      
******************************************************************************/
    
PROCEDURE alterar_cadret:

    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_idorigem AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT  PARAM par_cddopcao AS CHAR                           NO-UNDO.
	DEF  INPUT  PARAM par_cdprodut AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperac AS CHAR                           NO-UNDO.
    DEF  INPUT  PARAM par_nrtabela AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdretorn AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_dsretorn AS CHAR                           NO-UNDO.

    DEF  OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdcritic AS INTE                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                     NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    RUN valida_operad_depto(INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                           OUTPUT par_nmdcampo,
                           OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK" THEN
       RETURN "NOK".

    FIND FIRST craprto WHERE craprto.cdprodut = par_cdprodut
                         AND craprto.cdoperac = par_cdoperac
                         AND craprto.nrtabela = par_nrtabela
                         AND craprto.cdretorn = par_cdretorn
                         EXCLUSIVE-LOCK NO-ERROR.

    IF NOT AVAIL craprto THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Cadastro de retorno nao encontrado!"
               par_nmdcampo = "cdretorn".
  
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
  
        RETURN "NOK".
    END.

    ASSIGN craprto.dsretorn = par_dsretorn.

    RETURN "OK".

END PROCEDURE.


/*****************************************************************************
  Verificar permissao de acesso conforme departamento
******************************************************************************/
PROCEDURE valida_operad_depto:
    
    DEF  INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
    
    DEF  OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_cdcritic AS INTE                                    NO-UNDO.
    DEF  VAR aux_dscritic AS CHAR                                    NO-UNDO.

    FIND crapope WHERE crapope.cdcooper = par_cdcooper  AND
                       crapope.cdoperad = par_cdoperad
                       EXCLUSIVE-LOCK NO-ERROR.
        
    IF  NOT AVAIL crapope THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Nao foi possivel " +
                                  "encontrar o operador.".
                   par_nmdcampo = "cdoperad".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,  /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

     IF   crapope.dsdepart <> "TI"       AND
          crapope.dsdepart <> "PRODUTOS" THEN
          DO:
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = "Voce nao tem permissao para realizar " 
                                    + "esta acao.".

              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,            /** Sequencia **/
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).
              RETURN "NOK".
          END.

      RETURN "OK".

END PROCEDURE.

