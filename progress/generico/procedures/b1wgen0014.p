/*..............................................................................

    Programa: b1wgen0014.p
    Autor   : Evandro
    Data    : Marco/2006                     Ultima Atualizacao: 03/11/2014
    
    Dados referentes ao programa:

    Objetivo  : BO para manutencao das tabelas de LOG.                     

    Alteracoes: 16/04/2014 - Ajuste na procedure "gera_log" para nao alimentar
                             o campo craplgm.nrsequen. (James)
                             
                25/09/2014 - Verificar erro na gravacao da LGM.NMDATELA (Ze).
                
                03/11/2014 - Retirar verificacao acima (David).
                   
..............................................................................*/

{ sistema/generico/includes/var_oracle.i }

PROCEDURE gera_log:

    /* Cria o registro principal do log das transacoes e devolte o ROWID do
       registro que foi criado */

    DEF INPUT  PARAM par_cdcooper LIKE craplgm.cdcooper              NO-UNDO.
    DEF INPUT  PARAM par_cdoperad LIKE craplgm.cdoperad              NO-UNDO.
    DEF INPUT  PARAM par_dscritic LIKE craplgm.dscritic              NO-UNDO.
    DEF INPUT  PARAM par_dsorigem LIKE craplgm.dsorigem              NO-UNDO.
    DEF INPUT  PARAM par_dstransa LIKE craplgm.dstransa              NO-UNDO.
    DEF INPUT  PARAM par_dttransa LIKE craplgm.dttransa              NO-UNDO.
    DEF INPUT  PARAM par_flgtrans LIKE craplgm.flgtrans              NO-UNDO.
    DEF INPUT  PARAM par_hrtransa LIKE craplgm.hrtransa              NO-UNDO.
    DEF INPUT  PARAM par_idseqttl LIKE craplgm.idseqttl              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela LIKE craplgm.nmdatela              NO-UNDO.
    DEF INPUT  PARAM par_nrdconta LIKE craplgm.nrdconta              NO-UNDO.
    DEF OUTPUT PARAM par_nrdrowid AS ROWID                           NO-UNDO.
    
    /* Cria o registro do LOG */
    CREATE craplgm.
    ASSIGN craplgm.cdcooper = par_cdcooper
           craplgm.cdoperad = par_cdoperad
           craplgm.dscritic = substr(par_dscritic,1,245)
           craplgm.dsorigem = par_dsorigem
           craplgm.dstransa = par_dstransa
           craplgm.dttransa = par_dttransa
           craplgm.flgtrans = par_flgtrans
           craplgm.hrtransa = par_hrtransa
           craplgm.idseqttl = par_idseqttl
           craplgm.nmdatela = par_nmdatela
           craplgm.nrdconta = par_nrdconta.
           
    par_nrdrowid = ROWID(craplgm).

    RELEASE craplgm.
    RETURN "OK".

END PROCEDURE.


PROCEDURE gera_log_item:

    /* Cria o registro dos itens log das transacoes vinculado ao registro que
       foi passado via parametro da tabela principal */

    DEF INPUT  PARAM par_nrdrowid AS ROWID                           NO-UNDO.
    DEF INPUT  PARAM par_nmdcampo LIKE craplgi.nmdcampo              NO-UNDO.
    DEF INPUT  PARAM par_dsdadant LIKE craplgi.dsdadant              NO-UNDO.
    DEF INPUT  PARAM par_dsdadatu LIKE craplgi.dsdadatu              NO-UNDO.
    
    DEF VAR aux_nrseqcmp AS INT                                      NO-UNDO.

    /* Pega o registro da tabela principal */
    FIND craplgm WHERE ROWID(craplgm) = par_nrdrowid NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE craplgm   THEN
         RETURN "NOK".
    
    DO WHILE TRUE:
    
       /* Pega o sequencial do registro */
       FIND LAST craplgi WHERE craplgi.cdcooper = craplgm.cdcooper   AND
                               craplgi.nrdconta = craplgm.nrdconta   AND
                               craplgi.idseqttl = craplgm.idseqttl   AND
                               craplgi.dttransa = craplgm.dttransa   AND
                               craplgi.hrtransa = craplgm.hrtransa   AND
                               craplgi.nrsequen = craplgm.nrsequen
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                               
       IF   NOT AVAILABLE craplgi   AND
            LOCKED(craplgi)         THEN
            DO:
                PAUSE 1 NO-MESSAGE.
                NEXT.
            END.
                                        
       LEAVE.
    END.

    IF   AVAILABLE craplgi   THEN
         aux_nrseqcmp = craplgi.nrseqcmp + 1.
    ELSE
         aux_nrseqcmp = 1.
    
    /* Cria o registro do item do LOG */
    CREATE craplgi.
    ASSIGN craplgi.cdcooper = craplgm.cdcooper
           craplgi.dsdadant = par_dsdadant
           craplgi.dsdadatu = par_dsdadatu
           craplgi.nmdcampo = par_nmdcampo
           craplgi.dttransa = craplgm.dttransa
           craplgi.hrtransa = craplgm.hrtransa
           craplgi.idseqttl = craplgm.idseqttl
           craplgi.nrdconta = craplgm.nrdconta
           craplgi.nrseqcmp = aux_nrseqcmp
           craplgi.nrsequen = craplgm.nrsequen.
    
    RELEASE craplgi.
    RETURN "OK".

END PROCEDURE.

PROCEDURE gera_log_oracle:

    /* Cria o registro principal do log das transacoes e devolte o ROWID do
       registro que foi criado */

    DEF INPUT  PARAM par_cdcooper LIKE craplgm.cdcooper              NO-UNDO.
    DEF INPUT  PARAM par_cdoperad LIKE craplgm.cdoperad              NO-UNDO.
    DEF INPUT  PARAM par_dscritic LIKE craplgm.dscritic              NO-UNDO.
    DEF INPUT  PARAM par_dsorigem LIKE craplgm.dsorigem              NO-UNDO.
    DEF INPUT  PARAM par_dstransa LIKE craplgm.dstransa              NO-UNDO.
    DEF INPUT  PARAM par_dttransa LIKE craplgm.dttransa              NO-UNDO.
    DEF INPUT  PARAM par_flgtrans LIKE craplgm.flgtrans              NO-UNDO.
    DEF INPUT  PARAM par_hrtransa LIKE craplgm.hrtransa              NO-UNDO.
    DEF INPUT  PARAM par_idseqttl LIKE craplgm.idseqttl              NO-UNDO.
    DEF INPUT  PARAM par_nmdatela LIKE craplgm.nmdatela              NO-UNDO.
    DEF INPUT  PARAM par_nrdconta LIKE craplgm.nrdconta              NO-UNDO.
    DEF OUTPUT PARAM par_nrdrowid AS INTE                            NO-UNDO.
    
    /* Gerar log(CRAPLGM) - Rotina Oracle */
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_gera_log_prog
        aux_handproc = PROC-HANDLE NO-ERROR
        (INPUT par_cdcooper      /* pr_cdcooper */
        ,INPUT par_cdoperad      /* pr_cdoperad */
        ,INPUT par_dscritic      /* pr_dscritic */
        ,INPUT par_dsorigem      /* pr_dsorigem */
        ,INPUT par_dstransa      /* pr_dstransa */
        ,INPUT par_dttransa      /* pr_dttransa */
        ,INPUT INT(par_flgtrans) /* pr_flgtrans */
        ,INPUT par_hrtransa      /* pr_hrtransa */
        ,INPUT par_idseqttl      /* pr_idseqttl */
        ,INPUT par_nmdatela      /* pr_nmdatela */
        ,INPUT par_nrdconta      /* pr_nrdconta */
        ,OUTPUT par_nrdrowid).   /* pr_nrrecid  */

    IF  ERROR-STATUS:ERROR  THEN DO:        
        RETURN "NOK".
    END.
    
    CLOSE STORED-PROC pc_gera_log_prog
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl}}

    RELEASE craplgm.
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE gera_log_item_oracle:

    /* Cria o registro dos itens log das transacoes vinculado ao registro que
       foi passado via parametro da tabela principal */

    DEF INPUT  PARAM par_nrdrowid AS INTE                            NO-UNDO.
    DEF INPUT  PARAM par_nmdcampo LIKE craplgi.nmdcampo              NO-UNDO.
    DEF INPUT  PARAM par_dsdadant LIKE craplgi.dsdadant              NO-UNDO.
    DEF INPUT  PARAM par_dsdadatu LIKE craplgi.dsdadatu              NO-UNDO.
    
    DEF VAR aux_nrseqcmp AS INT                                      NO-UNDO.

    /* Gerar log(CRAPLGM) - Rotina Oracle */
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_gera_log_item_prog
        aux_handproc = PROC-HANDLE NO-ERROR
        (INPUT par_nrdrowid      /* pr_nrrecid  */
        ,INPUT par_nmdcampo      /* pr_nmdcampo */
        ,INPUT par_dsdadant      /* pr_dsdadant */
        ,INPUT par_dsdadatu      /* pr_dsdadatu */
        ). 

    IF  ERROR-STATUS:ERROR  THEN DO:
        RETURN "NOK".
    END.
    
    CLOSE STORED-PROC pc_gera_log_prog
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl}}

    RELEASE craplgm.
    
    RETURN "OK".

END PROCEDURE.

/* .......................................................................... */
