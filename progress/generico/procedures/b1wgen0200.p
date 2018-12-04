/*..............................................................................

   Programa: b1wgen0200.p
   Autora  : Odirlei Busana - AMcom.
   Data    : Junho/2018                        Ultima atualizacao: 01/06/2018

   Dados referentes ao programa:

   Objetivo  : BO - Rotinas generica para geraçao de lancamento em conta corrento do cooperado

   Alteracoes: 
               16/11/2018 - prj450 - história 10669:Crédito de Estorno de Saque em conta em Prejuízo
                            (Fabio Adriano - AMcom).
 ..............................................................................*/

/*................................ DEFINICOES ................................*/

{ sistema/generico/includes/b1wgen0200tt.i  }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }  


/*............................ PROCEDURES EXTERNAS ...........................*/

/******************************************************************************/
/**     Procedure para gerar lancamento completa com todos os param          **/
/******************************************************************************/
PROCEDURE gerar_lancamento_conta_comple:

    DEF  INPUT PARAM par_dtmvtolt LIKE craplcm.dtmvtolt    NO-UNDO.
    DEF  INPUT PARAM par_cdagenci LIKE craplcm.cdagenci    NO-UNDO.
    DEF  INPUT PARAM par_cdbccxlt LIKE craplcm.cdbccxlt    NO-UNDO.
    DEF  INPUT PARAM par_nrdolote LIKE craplcm.nrdolote    NO-UNDO.
    DEF  INPUT PARAM par_nrdconta LIKE craplcm.nrdconta    NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto LIKE craplcm.nrdocmto    NO-UNDO.
    DEF  INPUT PARAM par_cdhistor LIKE craplcm.cdhistor    NO-UNDO.
    DEF  INPUT PARAM par_nrseqdig LIKE craplcm.nrseqdig    NO-UNDO.
    DEF  INPUT PARAM par_vllanmto LIKE craplcm.vllanmto    NO-UNDO.
    DEF  INPUT PARAM par_nrdctabb LIKE craplcm.nrdctabb    NO-UNDO.
    DEF  INPUT PARAM par_cdpesqbb LIKE craplcm.cdpesqbb    NO-UNDO.
    DEF  INPUT PARAM par_vldoipmf LIKE craplcm.vldoipmf    NO-UNDO.
    DEF  INPUT PARAM par_nrautdoc LIKE craplcm.nrautdoc    NO-UNDO.
    DEF  INPUT PARAM par_nrsequni LIKE craplcm.nrsequni    NO-UNDO.
    DEF  INPUT PARAM par_cdbanchq LIKE craplcm.cdbanchq    NO-UNDO.
    DEF  INPUT PARAM par_cdcmpchq LIKE craplcm.cdcmpchq    NO-UNDO.
    DEF  INPUT PARAM par_cdagechq LIKE craplcm.cdagechq    NO-UNDO.
    DEF  INPUT PARAM par_nrctachq LIKE craplcm.nrctachq    NO-UNDO.
    DEF  INPUT PARAM par_nrlotchq LIKE craplcm.nrlotchq    NO-UNDO.
    DEF  INPUT PARAM par_sqlotchq LIKE craplcm.sqlotchq    NO-UNDO.
    DEF  INPUT PARAM par_dtrefere LIKE craplcm.dtrefere    NO-UNDO.
    DEF  INPUT PARAM par_hrtransa LIKE craplcm.hrtransa    NO-UNDO.
    DEF  INPUT PARAM par_cdoperad LIKE craplcm.cdoperad    NO-UNDO.
    DEF  INPUT PARAM par_dsidenti LIKE craplcm.dsidenti    NO-UNDO.
    DEF  INPUT PARAM par_cdcooper LIKE craplcm.cdcooper    NO-UNDO.
    DEF  INPUT PARAM par_nrdctitg LIKE craplcm.nrdctitg    NO-UNDO.
    DEF  INPUT PARAM par_dscedent LIKE craplcm.dscedent    NO-UNDO.
    DEF  INPUT PARAM par_cdcoptfn LIKE craplcm.cdcoptfn    NO-UNDO.
    DEF  INPUT PARAM par_cdagetfn LIKE craplcm.cdagetfn    NO-UNDO.
    DEF  INPUT PARAM par_nrterfin LIKE craplcm.nrterfin    NO-UNDO.
    DEF  INPUT PARAM par_nrparepr LIKE craplcm.nrparepr    NO-UNDO.
    DEF  INPUT PARAM par_nrseqava LIKE craplcm.nrseqava    NO-UNDO.
    DEF  INPUT PARAM par_nraplica LIKE craplcm.nraplica    NO-UNDO.
    DEF  INPUT PARAM par_cdorigem LIKE craplcm.cdorigem    NO-UNDO.
    DEF  INPUT PARAM par_idlautom LIKE craplcm.idlautom    NO-UNDO.
       
    /**-- Dados do lote (Opcional) --**/   
    DEF  INPUT PARAM par_inprolot  AS   INTEGER            NO-UNDO. /* Indica se a proced~ ure deve processar (incluir/atualizar) o LOTE (CRAPLOT) */
    DEF  INPUT PARAM par_tplotmov  LIKE craplot.tplotmov   NO-UNDO.
    
    /*** Saida ***/
    DEF OUTPUT PARAM TABLE FOR tt-ret-lancto.                       /* Retorno em formato xml */
    DEF OUTPUT PARAM par_incrineg AS INTEGER               NO-UNDO. /* Indicador de crítica ~ de negócio */    
    DEF OUTPUT PARAM par_cdcritic AS INTE                  NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                  NO-UNDO.
    
    
    /* Variaveis para o XML */ 
    DEF VAR xDoc          AS HANDLE                                 NO-UNDO.   
    DEF VAR xRoot         AS HANDLE                                 NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE                                 NO-UNDO.  
    DEF VAR xField        AS HANDLE                                 NO-UNDO. 
    DEF VAR xText         AS HANDLE                                 NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER                                NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER                                NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR                                 NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR                               NO-UNDO.
    
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_gerar_lancto_conta_prog
    aux_handproc = PROC-HANDLE
       ( INPUT  par_dtmvtolt  /* pr_dtmvtolt */
        ,INPUT  par_cdagenci  /* pr_cdagenci */
        ,INPUT  par_cdbccxlt  /* pr_cdbccxlt */
        ,INPUT  par_nrdolote  /* pr_nrdolote */
        ,INPUT  par_nrdconta  /* pr_nrdconta */
        ,INPUT  par_nrdocmto  /* pr_nrdocmto */
        ,INPUT  par_cdhistor  /* pr_cdhistor */
        ,INPUT  par_nrseqdig  /* pr_nrseqdig */
        ,INPUT  par_vllanmto  /* pr_vllanmto */
        ,INPUT  par_nrdctabb  /* pr_nrdctabb */
        ,INPUT  par_cdpesqbb  /* pr_cdpesqbb */
        ,INPUT  par_vldoipmf  /* pr_vldoipmf */
        ,INPUT  par_nrautdoc  /* pr_nrautdoc */
        ,INPUT  par_nrsequni  /* pr_nrsequni */
        ,INPUT  par_cdbanchq  /* pr_cdbanchq */
        ,INPUT  par_cdcmpchq  /* pr_cdcmpchq */
        ,INPUT  par_cdagechq  /* pr_cdagechq */
        ,INPUT  par_nrctachq  /* pr_nrctachq */
        ,INPUT  par_nrlotchq  /* pr_nrlotchq */
        ,INPUT  par_sqlotchq  /* pr_sqlotchq */
        ,INPUT  par_dtrefere  /* pr_dtrefere */
        ,INPUT  par_hrtransa  /* pr_hrtransa */
        ,INPUT  par_cdoperad  /* pr_cdoperad */
        ,INPUT  par_dsidenti  /* pr_dsidenti */
        ,INPUT  par_cdcooper  /* pr_cdcooper */
        ,INPUT  par_nrdctitg  /* pr_nrdctitg */
        ,INPUT  par_dscedent  /* pr_dscedent */
        ,INPUT  par_cdcoptfn  /* pr_cdcoptfn */
        ,INPUT  par_cdagetfn  /* pr_cdagetfn */
        ,INPUT  par_nrterfin  /* pr_nrterfin */
        ,INPUT  par_nrparepr  /* pr_nrparepr */
        ,INPUT  par_nrseqava  /* pr_nrseqava */
        ,INPUT  par_nraplica  /* pr_nraplica */
        ,INPUT  par_cdorigem  /* pr_cdorigem */
        ,INPUT  par_idlautom  /* pr_idlautom */
                
        /*-- Dados do lote (Opcional)                    --*/
        , INPUT par_inprolot /* pr_inprolot -- Indica se a procedure deve processar (incluir/atualizar) o LOTE (CRAPLOT) */
        , INPUT par_tplotmov /* pr_tplotmov */
        
        , OUTPUT ""          /* pr_dsretorn_xml -- Retorno em formato xml */
        , OUTPUT 0           /* pr_incrineg  -- Indicador de crítica de negócio */ 
        , OUTPUT 0           /* pr_cdcritic */
        , OUTPUT ""          /* pr_dscritic */
        ).

    CLOSE STORED-PROCEDURE pc_gerar_lancto_conta_prog WHERE PROC-HANDLE = aux_handproc.
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

          ASSIGN par_cdcritic = 0
           par_cdcritic = pc_gerar_lancto_conta_prog.pr_cdcritic
                          WHEN pc_gerar_lancto_conta_prog.pr_cdcritic <> ?
           par_dscritic = ""
           par_dscritic = pc_gerar_lancto_conta_prog.pr_dscritic
                          WHEN pc_gerar_lancto_conta_prog.pr_dscritic <> ?
           par_incrineg = 0
           par_incrineg = pc_gerar_lancto_conta_prog.pr_incrineg
                          WHEN pc_gerar_lancto_conta_prog.pr_incrineg <> ?               .    
                          
    IF par_cdcritic > 0 OR 
      par_dscritic <> "" THEN                       
    DO:
      RETURN "NOK".
    END.
   
    ASSIGN xml_req = ""
           xml_req = pc_gerar_lancto_conta_prog.pr_dsretorn_xml
                          WHEN pc_gerar_lancto_conta_prog.pr_dsretorn_xml <> ?
   
   
    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 

    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 

    IF ponteiro_xml <> ? THEN
      DO:
          xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
          xDoc:GET-DOCUMENT-ELEMENT(xRoot).

          DO aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 

              xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
           
              IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
                  NEXT. 

              IF xRoot2:NUM-CHILDREN > 0 THEN
              DO:
                CREATE tt-ret-lancto.
                       
              END.
              
              DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:

                  xRoot2:GET-CHILD(xField,aux_cont).
                  
                  IF xField:SUBTYPE <> "ELEMENT" THEN 
                      NEXT. 

                  xField:GET-CHILD(xText,1) NO-ERROR.
                  
                  ASSIGN tt-ret-lancto.rowid_lcm = xText:NODE-VALUE  WHEN xField:NAME = "rowid_lcm" NO-ERROR. 
                  ASSIGN tt-ret-lancto.recid_lcm = INTEGER(xText:NODE-VALUE)  WHEN xField:NAME = "recid_lcm" NO-ERROR.
                  ASSIGN tt-ret-lancto.nmtabela  = xText:NODE-VALUE  WHEN xField:NAME = "nmtabela" NO-ERROR.
                  ASSIGN tt-ret-lancto.rowid_lot = xText:NODE-VALUE  WHEN xField:NAME = "rowid_lot" NO-ERROR.
                  ASSIGN tt-ret-lancto.recid_lot = xText:NODE-VALUE  WHEN xField:NAME = "recid_lot" NO-ERROR.
                  
                  
                       
              END.

          END.

          SET-SIZE(ponteiro_xml) = 0. 

      END.


    /*Elimina os objetos criados*/
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.
   
    RETURN "OK".    
    
END.    

/******************************************************************************/
/**     Procedure para estornar lancamento em conta corrente                 **/
/******************************************************************************/
PROCEDURE estorna_lancamento_conta:
    DEF  INPUT PARAM par_cdcooper LIKE craplcm.cdcooper    NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt LIKE craplcm.dtmvtolt    NO-UNDO.
    DEF  INPUT PARAM par_cdagenci LIKE craplcm.cdagenci    NO-UNDO.
    DEF  INPUT PARAM par_cdbccxlt LIKE craplcm.cdbccxlt    NO-UNDO.
    DEF  INPUT PARAM par_nrdolote LIKE craplcm.nrdolote    NO-UNDO.
    DEF  INPUT PARAM par_nrdctabb LIKE craplcm.nrdctabb    NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto LIKE craplcm.nrdocmto    NO-UNDO.
    DEF  INPUT PARAM par_cdhistor LIKE craplcm.cdhistor    NO-UNDO.
    DEF  INPUT PARAM par_nrctachq LIKE craplcm.nrctachq    NO-UNDO.
    DEF  INPUT PARAM par_nrdconta LIKE craplcm.nrdconta    NO-UNDO.
    DEF  INPUT PARAM par_cdpesqbb LIKE craplcm.cdpesqbb    NO-UNDO.
    /*** Saida ***/
    DEF OUTPUT PARAM par_cdcritic AS INTE                  NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                  NO-UNDO.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_estorna_lancto_prog
    aux_handproc = PROC-HANDLE
       ( INPUT  par_cdcooper  /* pr_cdcooper */
        ,INPUT  par_dtmvtolt  /* pr_dtmvtolt */
        ,INPUT  par_cdagenci  /* pr_cdagenci */
        ,INPUT  par_cdbccxlt  /* pr_cdbccxlt */
        ,INPUT  par_nrdolote  /* pr_nrdolote */
        ,INPUT  par_nrdctabb  /* pr_nrdctabb */
        ,INPUT  par_nrdocmto  /* pr_nrdocmto */
        ,INPUT  par_cdhistor  /* pr_cdhistor */
        ,INPUT  par_nrctachq  /* pr_nrctachq */
        ,INPUT  par_nrdconta  /* pr_nrdconta */
        ,INPUT  par_cdpesqbb  /* pr_cdpesqbb */
        ,OUTPUT 0             /* pr_cdcritic */
        ,OUTPUT ""            /* pr_dscritic */
        ).

    CLOSE STORED-PROCEDURE pc_estorna_lancto_prog WHERE PROC-HANDLE = aux_handproc.
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

          ASSIGN par_cdcritic = 0
           par_cdcritic = pc_estorna_lancto_prog.pr_cdcritic
                          WHEN pc_estorna_lancto_prog.pr_cdcritic <> ?
           par_dscritic = ""
           par_dscritic = pc_estorna_lancto_prog.pr_dscritic
                          WHEN pc_estorna_lancto_prog.pr_dscritic <> ?.    

    IF par_cdcritic > 0 OR 
      par_dscritic <> "" THEN                       
    DO:
      RETURN "NOK".
    END.
   
    RETURN "OK".    
    
END.    

/******************************************************************************/
/**        Procedure para gerar lancamento parametros reduzidos              **/
/******************************************************************************/
PROCEDURE gerar_lancamento_conta:

    DEF  INPUT PARAM par_dtmvtolt LIKE craplcm.dtmvtolt    NO-UNDO.
    DEF  INPUT PARAM par_cdagenci LIKE craplcm.cdagenci    NO-UNDO.
    DEF  INPUT PARAM par_cdbccxlt LIKE craplcm.cdbccxlt    NO-UNDO.
    DEF  INPUT PARAM par_nrdolote LIKE craplcm.nrdolote    NO-UNDO.
    DEF  INPUT PARAM par_nrdconta LIKE craplcm.nrdconta    NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto LIKE craplcm.nrdocmto    NO-UNDO.
    DEF  INPUT PARAM par_cdhistor LIKE craplcm.cdhistor    NO-UNDO.
    DEF  INPUT PARAM par_nrseqdig LIKE craplcm.nrseqdig    NO-UNDO.
    DEF  INPUT PARAM par_vllanmto LIKE craplcm.vllanmto    NO-UNDO.
    DEF  INPUT PARAM par_nrdctabb LIKE craplcm.nrdctabb    NO-UNDO.
    DEF  INPUT PARAM par_cdpesqbb LIKE craplcm.cdpesqbb    NO-UNDO.
    DEF  INPUT PARAM par_nrautdoc LIKE craplcm.nrautdoc    NO-UNDO.
    DEF  INPUT PARAM par_nrsequni LIKE craplcm.nrsequni    NO-UNDO.
    DEF  INPUT PARAM par_dtrefere LIKE craplcm.dtrefere    NO-UNDO.
    DEF  INPUT PARAM par_cdoperad LIKE craplcm.cdoperad    NO-UNDO.    
    DEF  INPUT PARAM par_cdcooper LIKE craplcm.cdcooper    NO-UNDO.
    DEF  INPUT PARAM par_nrdctitg LIKE craplcm.nrdctitg    NO-UNDO.    
    DEF  INPUT PARAM par_cdcoptfn LIKE craplcm.cdcoptfn    NO-UNDO.
    DEF  INPUT PARAM par_cdagetfn LIKE craplcm.cdagetfn    NO-UNDO.
    DEF  INPUT PARAM par_nrterfin LIKE craplcm.nrterfin    NO-UNDO.
    DEF  INPUT PARAM par_cdorigem LIKE craplcm.cdorigem    NO-UNDO.
       
    /**-- Dados do lote (Opcional) --**/   
    DEF  INPUT PARAM par_inprolot  AS   INTEGER            NO-UNDO. /* Indica se a proced~ ure deve processar (incluir/atualizar) o LOTE (CRAPLOT) */
    DEF  INPUT PARAM par_tplotmov  LIKE craplot.tplotmov   NO-UNDO.
    
    /*** Saida ***/
    DEF OUTPUT PARAM TABLE FOR tt-ret-lancto.                       /* Retorno em formato xml */
    DEF OUTPUT PARAM par_incrineg AS INTEGER              NO-UNDO. /* Indicador de crítica ~ de negócio */    
    DEF OUTPUT PARAM par_cdcritic AS INTE                  NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                  NO-UNDO.
    
    RUN gerar_lancamento_conta_comple 
               ( INPUT par_dtmvtolt
                ,INPUT par_cdagenci
                ,INPUT par_cdbccxlt
                ,INPUT par_nrdolote
                ,INPUT par_nrdconta
                ,INPUT par_nrdocmto
                ,INPUT par_cdhistor
                ,INPUT par_nrseqdig
                ,INPUT par_vllanmto
                ,INPUT par_nrdctabb
                ,INPUT par_cdpesqbb
                ,INPUT 0 /* par_vldoipmf */
                ,INPUT par_nrautdoc
                ,INPUT par_nrsequni
                ,INPUT 0 /* par_cdbanchq */
                ,INPUT 0 /* par_cdcmpchq */
                ,INPUT 0 /* par_cdagechq */
                ,INPUT 0 /* par_nrctachq */
                ,INPUT 0 /* par_nrlotchq */
                ,INPUT 0 /* par_sqlotchq */
                ,INPUT par_dtrefere
                ,INPUT TIME /* par_hrtransa */
                ,INPUT par_cdoperad
                ,INPUT "" /* par_dsidenti */
                ,INPUT par_cdcooper
                ,INPUT par_nrdctitg
                ,INPUT "" /* par_dscedent */
                ,INPUT par_cdcoptfn
                ,INPUT par_cdagetfn
                ,INPUT par_nrterfin
                ,INPUT 0 /* par_nrparepr */
                ,INPUT 0 /* par_nrseqava */
                ,INPUT 0 /* par_nraplica */
                ,INPUT par_cdorigem
                ,INPUT 0  /* par_idlautom */
                ,INPUT par_inprolot 
                ,INPUT par_tplotmov 
                
                ,OUTPUT TABLE tt-ret-lancto
                ,OUTPUT par_incrineg
                ,OUTPUT par_cdcritic
                ,OUTPUT par_dscritic).
                
                
    IF par_cdcritic > 0 OR 
      par_dscritic <> "" THEN                       
    DO:
      RETURN "NOK".
    END.    
    
    RETURN "OK". 
END.    


/******************************************************************************/
/**     Procedure para Crédito de Estorno de Saque em conta em Prejuízo                 **/
/******************************************************************************/
PROCEDURE pc_estorna_saque_conta_prej:
    DEF  INPUT PARAM par_cdcooper LIKE craplcm.cdcooper    NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt LIKE craplcm.dtmvtolt    NO-UNDO.
    DEF  INPUT PARAM par_cdagenci LIKE craplcm.cdagenci    NO-UNDO.
    DEF  INPUT PARAM par_cdbccxlt LIKE craplcm.cdbccxlt    NO-UNDO.
    DEF  INPUT PARAM par_nrdctabb LIKE craplcm.nrdctabb    NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto LIKE craplcm.nrdocmto    NO-UNDO.
    DEF  INPUT PARAM par_cdhistor LIKE craplcm.cdhistor    NO-UNDO.
    DEF  INPUT PARAM par_nrdconta LIKE craplcm.nrdconta    NO-UNDO.
    DEF  INPUT PARAM par_nrseqdig LIKE craplcm.nrseqdig    NO-UNDO. 
    DEF  INPUT PARAM par_vllanmto LIKE craplcm.vllanmto    NO-UNDO. 
    /*** Saida ***/
    DEF OUTPUT PARAM par_cdcritic AS INTE                  NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                  NO-UNDO.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_estorna_saque_conta_prej
    aux_handproc = PROC-HANDLE
       ( INPUT  par_cdcooper  /* pr_cdcooper */
        ,INPUT  par_dtmvtolt  /* pr_dtmvtolt */
        ,INPUT  par_cdagenci  /* pr_cdagenci */
        ,INPUT  par_cdbccxlt  /* pr_cdbccxlt */
        ,INPUT  par_nrdctabb  /* pr_nrdctabb */
        ,INPUT  par_nrdocmto  /* pr_nrdocmto */
        ,INPUT  par_cdhistor  /* pr_cdhistor */
        ,INPUT  par_nrdconta  /* pr_nrdconta */
        ,INPUT  par_nrseqdig  /* par_nrseqdig */
        ,INPUT  par_vllanmto  /* par_vllanmto */
        ,OUTPUT 0             /* pr_cdcritic */
        ,OUTPUT ""            /* pr_dscritic */
        ).

    CLOSE STORED-PROCEDURE pc_estorna_saque_conta_prej WHERE PROC-HANDLE = aux_handproc.
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

          ASSIGN par_cdcritic = 0
           par_cdcritic = pc_estorna_saque_conta_prej.pr_cdcritic
                          WHEN pc_estorna_saque_conta_prej.pr_cdcritic <> ?
           par_dscritic = ""
           par_dscritic = pc_estorna_saque_conta_prej.pr_dscritic
                          WHEN pc_estorna_saque_conta_prej.pr_dscritic <> ?.    

    IF par_cdcritic > 0 OR 
      par_dscritic <> "" THEN                       
    DO:
      RETURN "NOK".
    END.
   
    RETURN "OK".    
    
END.    


/*................................. FUNCTIONS ...............................*/

FUNCTION PodeDebitar RETURNS LOGICAL 
    (  INPUT par_cdcooper LIKE craplcm.cdcooper
      ,INPUT par_nrdconta LIKE craplcm.nrdconta
      ,INPUT par_cdhistor LIKE craplcm.cdhistor):
    
    DEF VAR aux_flpoddeb AS INTEGER          NO-UNDO.
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_pode_debitar
    aux_handproc = PROC-HANDLE
       ( INPUT  par_cdcooper  /* pr_cdcooper */
        ,INPUT  par_nrdconta  /* pr_nrdconta */
        ,INPUT  par_cdhistor  /* pr_cdhistor */        
        ,OUTPUT 0             /* pr_flpoddeb */
        ).

    CLOSE STORED-PROCEDURE pc_pode_debitar WHERE PROC-HANDLE = aux_handproc.
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_flpoddeb = 0
           aux_flpoddeb = pc_pode_debitar.pr_flpoddeb
                          WHEN pc_pode_debitar.pr_flpoddeb <> ?.    
                          
   
    RETURN LOGICAL(aux_flpoddeb).
        
END FUNCTION.

 
