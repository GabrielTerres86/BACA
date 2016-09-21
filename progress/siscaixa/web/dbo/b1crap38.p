/*---------------------------------------------------------------------------
    
    b1crap38.p - Gera Arquivo Texto(Talonários)
    
    Ultima Atualizacao: 
    
    Alteracoes:
----------------------------------------------------------------------------*/

{dbo/bo-erro1.i}
{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1crap00  AS HANDLE                       NO-UNDO.

DEF VAR i-cod-erro               AS INTE                              NO-UNDO.
DEF VAR c-desc-erro              AS CHAR                              NO-UNDO.
DEF VAR c-arquivo                AS CHAR                              NO-UNDO.

DEF TEMP-TABLE tt-registro-talonarios
    FIELD cdagenci AS INTE
    FIELD dsagenci AS CHAR
    FIELD dtmvtore AS DATE
    FIELD nrdconta AS CHAR
    FIELD nmprimtl AS CHAR
    FIELD nrdtalao AS CHAR
    FIELD nrini    AS CHAR
    FIELD nrfim    AS CHAR
    FIELD tpentreg AS CHAR
    FIELD tpdforma AS CHAR
    FIELD tpcartao AS CHAR
    FIELD nrcpfter AS CHAR
    FIELD dsnomter AS CHAR
    FIELD hrtransa AS CHAR
    FIELD formcont AS INTE.

PROCEDURE busca-nome-pa:

    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF OUTPUT PARAM p-dsagenci      AS CHAR.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
    
    IF  p-cod-agencia <> 0 THEN
        DO:
 
          FIND FIRST crapage WHERE crapage.cdcooper = crapcop.cdcooper AND  
                                   crapage.cdagenci = p-cod-agencia
                                   NO-LOCK NO-ERROR.
                                   
          IF  AVAIL crapage THEN
              ASSIGN p-dsagenci = crapage.nmresage.
          ELSE
              ASSIGN p-dsagenci = "NAO ENCONTRADO".
        END.
    ELSE
        ASSIGN p-dsagenci = "TODOS".
                             
    RETURN "OK".
    
END PROCEDURE.



PROCEDURE gera-arquivo-texto:

    DEF INPUT  PARAM p-cooper        AS CHAR.
    DEF INPUT  PARAM p-cod-agencia   AS INTE.
    DEF INPUT  PARAM p-nro-caixa     AS INTE.
    DEF INPUT  PARAM p-dtini         AS CHAR.
    DEF INPUT  PARAM p-dtfim         AS CHAR.
    DEF INPUT  PARAM p-cdagenci      AS INTE.
    DEF OUTPUT PARAM p-arquivo       AS CHAR.
    
    DEF VAR aux_dsagenci       AS CHAR   NO-UNDO.
    
    
    FORM " PA CONTA        TITULAR                          TALAO   ETG FORMA  TP CART    CPF TERCEIRO   NOME TERCEIRO                HORA"  SKIP         
         "--- ------------ -------------------------------- ------- --- ------ ---------- -------------- ---------------------------- -----" SKIP 
         WITH COLUMN 1 NO-BOX WIDTH 220 FRAME f_cab_talonario.
         
    FORM " PA CONTA        TITULAR                          INICIAL    FINAL      ETG FORMA  TP CART    CPF TERCEIRO   NOME TERCEIRO                HORA"  SKIP
         "--- ------------ -------------------------------- ---------- ---------- --- ------ ---------- -------------- ---------------------------- -----" SKIP
         WITH COLUMN 1 NO-BOX WIDTH 220 FRAME f_cab_continuo.
         
    FORM tt-registro-talonarios.cdagenci 
         tt-registro-talonarios.nrdconta 
         tt-registro-talonarios.nmprimtl 
         tt-registro-talonarios.nrdtalao 
         tt-registro-talonarios.tpentreg 
         tt-registro-talonarios.tpdforma 
         tt-registro-talonarios.tpcartao 
         tt-registro-talonarios.nrcpfter 
         tt-registro-talonarios.dsnomter 
         tt-registro-talonarios.hrtransa 
         WITH DOWN COLUMN 1 NO-BOX WIDTH 220 FRAME f_talonario.
         
    FORM tt-registro-talonarios.cdagenci
         tt-registro-talonarios.nrdconta
         tt-registro-talonarios.nmprimtl
         tt-registro-talonarios.nrini   
         tt-registro-talonarios.nrfim   
         tt-registro-talonarios.tpentreg
         tt-registro-talonarios.tpdforma
         tt-registro-talonarios.tpcartao
         tt-registro-talonarios.nrcpfter
         tt-registro-talonarios.dsnomter
         tt-registro-talonarios.hrtransa
         WITH DOWN COLUMN 1 NO-BOX WIDTH 220 FRAME f_continuo.
                           
    EMPTY TEMP-TABLE tt-registro-talonarios.
    
    FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
 
    FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper
                             NO-LOCK NO-ERROR.
    
    /* Chamada do Oracle */
    /* Variaveis utilizadas para receber clob da rotina no oracle */
    DEF VAR xDoc          AS HANDLE   NO-UNDO.   
    DEF VAR xRoot         AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
    DEF VAR xField        AS HANDLE   NO-UNDO. 
    DEF VAR xText         AS HANDLE   NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR NO-UNDO.
    DEF VAR aux_dscritic  AS CHAR     NO-UNDO.
    DEF VAR aux_des_erro  AS CHAR     NO-UNDO.
    
    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag raiz em diante */ 
    CREATE X-NODEREF  xRoot2.   
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
    
    /* Efetuar a chamada a rotina Oracle */
    RUN STORED-PROCEDURE pc_busca_talonarios_car
    aux_handproc = PROC-HANDLE NO-ERROR ( INPUT crapcop.cdcooper
                                         ,INPUT DATE(p-dtini)
                                         ,INPUT DATE(p-dtfim)
                                         ,INPUT p-cdagenci
                                        ,OUTPUT ?        
                                        ,OUTPUT ""       
                                        ,OUTPUT "").     

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_busca_talonarios_car
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

    /* Busca possíveis erros */ 
    ASSIGN aux_des_erro = ""
           aux_dscritic = ""
           aux_des_erro = pc_busca_talonarios_car.pr_des_erro 
                          WHEN pc_busca_talonarios_car.pr_des_erro <> ?
           aux_dscritic = pc_busca_talonarios_car.pr_dscritic 
                          WHEN pc_busca_talonarios_car.pr_dscritic <> ?.
                          
    IF  aux_des_erro <> "OK" AND TRIM(aux_dscritic) <> "" THEN
        DO:
           ASSIGN i-cod-erro  = 0
                  c-desc-erro = aux_dscritic.

           RUN cria-erro (INPUT p-cooper,
                          INPUT p-cod-agencia,
                          INPUT p-nro-caixa,
                          INPUT i-cod-erro,
                          INPUT c-desc-erro,
                          INPUT YES).
           RETURN "NOK".
        END.

    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_busca_talonarios_car.pr_clobxmlc.

    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 

    IF ponteiro_xml <> ? THEN
       DO:
           xDoc:LOAD("MEMPTR",ponteiro_xml, FALSE). 
           xDoc:GET-DOCUMENT-ELEMENT(xRoot).

           DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
           
               xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
           
               IF xRoot2:SUBTYPE <> "ELEMENT"   THEN 
                 NEXT.     
                 
               IF xRoot2:NUM-CHILDREN > 0 THEN
                  CREATE tt-registro-talonarios.

               DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
               
                   xRoot2:GET-CHILD(xField,aux_cont).
                       
                   IF  xField:SUBTYPE <> "ELEMENT" THEN 
                       NEXT. 
                   
                   xField:GET-CHILD(xText,1).  
                                                        
                   ASSIGN tt-registro-talonarios.cdagenci =   INTE(xText:NODE-VALUE) WHEN xField:NAME = "cdagenci"                          
                          tt-registro-talonarios.formcont =   INTE(xText:NODE-VALUE) WHEN xField:NAME = "formcont"                          
                          tt-registro-talonarios.dtmvtore =   DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtmvtore"
                          tt-registro-talonarios.nrdconta = STRING(xText:NODE-VALUE) WHEN xField:NAME = "nrdconta"
                          tt-registro-talonarios.nmprimtl = STRING(xText:NODE-VALUE) WHEN xField:NAME = "nmprimtl"
                          tt-registro-talonarios.nrdtalao = STRING(xText:NODE-VALUE) WHEN xField:NAME = "nrdtalao"
                          tt-registro-talonarios.nrini    = STRING(xText:NODE-VALUE) WHEN xField:NAME = "nrini"
                          tt-registro-talonarios.nrfim    = STRING(xText:NODE-VALUE) WHEN xField:NAME = "nrfim"
                          tt-registro-talonarios.tpentreg = STRING(xText:NODE-VALUE) WHEN xField:NAME = "tpentreg"
                          tt-registro-talonarios.tpdforma = STRING(xText:NODE-VALUE) WHEN xField:NAME = "tpdforma"
                          tt-registro-talonarios.tpcartao = STRING(xText:NODE-VALUE) WHEN xField:NAME = "tpcartao"
                          tt-registro-talonarios.nrcpfter = STRING(xText:NODE-VALUE) WHEN xField:NAME = "nrcpfter"
                          tt-registro-talonarios.dsnomter = STRING(xText:NODE-VALUE) WHEN xField:NAME = "dsnomter"
                          tt-registro-talonarios.hrtransa = STRING(xText:NODE-VALUE) WHEN xField:NAME = "hrtransa".
                          
                   IF  xField:NAME = "cdagenci" THEN 
                       DO:
                           RUN busca-nome-pa (INPUT p-cooper,
                                              INPUT INTE(tt-registro-talonarios.cdagenci),
                                             OUTPUT aux_dsagenci).
                                             
                           ASSIGN tt-registro-talonarios.dsagenci = aux_dsagenci.
                       END.
               END.            
           END.                
      END.

    SET-SIZE(ponteiro_xml) = 0. 
 
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.

            ASSIGN c-arquivo = "/usr/coop/sistema/siscaixa/web/spool/" +
                               crapcop.dsdircop + 
                               STRING(p-cod-agencia,"999") + 
                               STRING(p-nro-caixa,"999") + STRING(YEAR(crapdat.dtmvtolt),  "9999") + 
                                                           STRING(MONTH(crapdat.dtmvtolt), "99")   + 
                                                           STRING(DAY(crapdat.dtmvtolt),   "99")   + 
                               ".txt".  /* Nome Fixo  */
                               
            ASSIGN p-arquivo = "spool/"  + crapcop.dsdircop + 
                               STRING(p-cod-agencia,"999") + 
                               STRING(p-nro-caixa,"999") + STRING(YEAR(crapdat.dtmvtolt),  "9999") +
                                                           STRING(MONTH(crapdat.dtmvtolt), "99")   +
                                                           STRING(DAY(crapdat.dtmvtolt),   "99")   +                               
                               ".txt".  
                               
            OUTPUT TO VALUE(c-arquivo).                             
    
    IF  TEMP-TABLE tt-registro-talonarios:HAS-RECORDS THEN
        DO:
    FIND FIRST tt-registro-talonarios WHERE tt-registro-talonarios.formcont = 1 NO-LOCK NO-ERROR.
    IF  AVAIL tt-registro-talonarios THEN
        PUT UNFORMATTED FILL(" ",68) + "REQUISICAO DE TALONARIOS" SKIP(1).
        
    /* Req talonarios  */
    FOR EACH tt-registro-talonarios WHERE tt-registro-talonarios.formcont = 1 NO-LOCK
                                          BREAK BY tt-registro-talonarios.dtmvtore
                                                BY tt-registro-talonarios.cdagenci:
                                                
        IF  FIRST-OF (tt-registro-talonarios.dtmvtore) OR 
            FIRST-OF (tt-registro-talonarios.cdagenci) THEN
            DO:
                PUT UNFORMATTED SKIP(1).
                PUT UNFORMATTED "DATA: " + STRING(tt-registro-talonarios.dtmvtore) SKIP.
                PUT UNFORMATTED "PA: "   + STRING(tt-registro-talonarios.cdagenci) +
                                " - "    + string(tt-registro-talonarios.dsagenci) SKIP(1).                                
                VIEW FRAME f_cab_talonario.
            END.
            
        DISPLAY tt-registro-talonarios.cdagenci   NO-LABELS     FORMAT "zz9"
                tt-registro-talonarios.nrdconta   NO-LABELS     FORMAT "x(12)"
                tt-registro-talonarios.nmprimtl   NO-LABELS     FORMAT "x(32)"
                tt-registro-talonarios.nrdtalao   NO-LABELS     FORMAT "x(07)"
                tt-registro-talonarios.tpentreg   NO-LABELS     FORMAT "x(03)"
                tt-registro-talonarios.tpdforma   NO-LABELS     FORMAT "x(06)"
                tt-registro-talonarios.tpcartao   NO-LABELS     FORMAT "x(10)"
                tt-registro-talonarios.nrcpfter   NO-LABELS     FORMAT "x(14)"
                tt-registro-talonarios.dsnomter   NO-LABELS     FORMAT "x(28)"
                tt-registro-talonarios.hrtransa   NO-LABELS     FORMAT "x(05)"
                WITH FRAME f_talonario.
                
        DOWN WITH FRAME f_talonario.
    
    END.
    
    /* Formulário continuo */
    FIND FIRST tt-registro-talonarios WHERE tt-registro-talonarios.formcont = 2 NO-LOCK NO-ERROR.
    IF  AVAIL tt-registro-talonarios THEN
        DO:
            PUT UNFORMATTED SKIP(3).
            PUT UNFORMATTED FILL(" ",55) + "REQUISICAO DE FORMULARIOS CONTINUOS" SKIP(1).
        END.
       
    FOR EACH tt-registro-talonarios WHERE tt-registro-talonarios.formcont = 2 NO-LOCK
                                          BREAK BY tt-registro-talonarios.dtmvtore
                                                BY tt-registro-talonarios.cdagenci:
                                                
        IF  FIRST-OF (tt-registro-talonarios.dtmvtore) OR 
            FIRST-OF (tt-registro-talonarios.cdagenci) THEN
            DO:
                PUT UNFORMATTED SKIP(1).
                PUT UNFORMATTED "DATA: " + STRING(tt-registro-talonarios.dtmvtore) SKIP.
                PUT UNFORMATTED "PA: "   + STRING(tt-registro-talonarios.cdagenci) +
                                " - "    + string(tt-registro-talonarios.dsagenci) SKIP(1).
                VIEW FRAME f_cab_continuo.
            END.
    
        DISPLAY tt-registro-talonarios.cdagenci   NO-LABELS   FORMAT "zz9"
                tt-registro-talonarios.nrdconta   NO-LABELS   FORMAT "x(12)"
                tt-registro-talonarios.nmprimtl   NO-LABELS   FORMAT "x(32)"
                tt-registro-talonarios.nrini      NO-LABELS   FORMAT "x(10)"
                tt-registro-talonarios.nrfim      NO-LABELS   FORMAT "x(10)"
                tt-registro-talonarios.tpentreg   NO-LABELS   FORMAT "x(03)"
                tt-registro-talonarios.tpdforma   NO-LABELS   FORMAT "x(06)"
                tt-registro-talonarios.tpcartao   NO-LABELS   FORMAT "x(10)"
                tt-registro-talonarios.nrcpfter   NO-LABELS   FORMAT "x(14)"
                tt-registro-talonarios.dsnomter   NO-LABELS 	FORMAT "x(28)"
                tt-registro-talonarios.hrtransa   NO-LABELS   FORMAT "x(05)"
                WITH FRAME f_continuo.
                
        DOWN WITH FRAME f_continuo.
    END.   
        END.
    ELSE 
        DO:
            PUT UNFORMATTED  "NAO HA REGISTROS COM OS PARAMETROS INFORMADOS.".
        END.
    
        OUTPUT CLOSE.
    
    RETURN "OK".
    
END PROCEDURE.
    
/* .......................................................................... */

