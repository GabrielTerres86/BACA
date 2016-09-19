/*..............................................................................

    Programa  : b1wgen0026.p
    Autor     : Guilherme
    Data      : Fevereiro/2008                Ultima Atualizacao: 27/05/2014
    
    Dados referentes ao programa:

    Objetivo  : BO ref. Rotina CONVENIOS da tela ATENDA.

    Alteracoes: 03/06/2008 - Incluir cdcooper nos FIND's da craphis (David).
    
                10/11/2008 - Limpar variaveis de erro e dar return 'ok'
                             (Guilherme).

               27/05/2014 - Ajustado o campo tt-conven.cdrefere,
                            pois o mesmo estava vindo com 22 posicoes
                            (Andrino - RKAM)

..............................................................................*/
{ sistema/generico/includes/b1wgen0026tt.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.

PROCEDURE lista_conven:

    DEF  INPUT  PARAM  par_cdcooper  AS  INTE  NO-UNDO.                   
    DEF  INPUT  PARAM  par_cdagenci  AS  INTE  NO-UNDO. 
    DEF  INPUT  PARAM  par_nrdcaixa  AS  INTE  NO-UNDO.                     
    DEF  INPUT  PARAM  par_cdoperad  AS  CHAR  NO-UNDO.                
    DEF  INPUT  PARAM  par_nrdconta  AS  INTE  NO-UNDO.
    DEF  INPUT  PARAM  par_idorigem  AS  INTE  NO-UNDO. 
    DEF  INPUT  PARAM  par_idseqttl  AS  INTE  NO-UNDO.
    DEF  INPUT  PARAM  par_nmdatela  AS  CHAR  NO-UNDO.
    DEF  INPUT  PARAM  par_flgerlog  AS  LOGI  NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-conven.
    DEF OUTPUT PARAM TABLE FOR tt-totconven.

    DEF            VAR aux_cdcritic  AS  INTE  NO-UNDO.
    DEF            VAR aux_dscritic  AS  CHAR  NO-UNDO.
    DEF            VAR aux_qtconven  AS  INTE  NO-UNDO.
    
    EMPTY TEMP-TABLE tt-conven.
    EMPTY TEMP-TABLE tt-totconven.    
    
    /** Atribui descricao da origem e da transacao **/
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Listar convenios ativos.".

    FOR EACH crapatr WHERE crapatr.cdcooper = par_cdcooper      AND
                           crapatr.nrdconta = par_nrdconta      AND
                           crapatr.dtfimatr = ?                 NO-LOCK,
       FIRST craphis WHERE craphis.cdcooper = par_cdcooper      AND
                           craphis.cdhistor = crapatr.cdhistor  NO-LOCK
                           BY crapatr.dtiniatr
                           BY crapatr.cdhistor:
                           
       CREATE tt-conven.
       ASSIGN tt-conven.cdcooper = crapatr.cdcooper
              tt-conven.nrdconta = crapatr.nrdconta
              tt-conven.cdhistor = craphis.cdhistor
              tt-conven.dsexthst = SUBSTR(craphis.dsexthst,1,28)
              tt-conven.dtiniatr = crapatr.dtiniatr
              tt-conven.dtultdeb = crapatr.dtultdeb
              tt-conven.cdrefere = DEC(SUBSTR(STRING(crapatr.cdrefere,"9999999999999999999999999"),9,17)).
                           
    END.
    
    FOR EACH tt-conven NO-LOCK:
        ASSIGN aux_qtconven = aux_qtconven + 1.
    END.
    
    CREATE tt-totconven.
    ASSIGN tt-totconven.qtconven = aux_qtconven.

    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).

    RETURN "OK".

END PROCEDURE.    
/* ......................................................................... */

