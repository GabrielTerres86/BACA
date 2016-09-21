/*.............................................................................

   Programa: fontes/zoom_aplicacoes.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel Capoia - DB1
   Data    : Julho/2011                           Ultima alteracao: 10/10/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom para seleção de aplicações.

   Alteracoes: 18/09/2012 - Novos parametros DATA na chamada da procedure
                            obtem-dados-aplicacoes (Guilherme/Supero).
                            
               10/10/2014 - Adicionado tratamento para produtos de aplicações 
                            de captação. (Reinert)
 ........................................................................... */

{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }
{ includes/var_online.i }

DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.

DEF OUTPUT PARAM par_nraplica AS INTE                           NO-UNDO.

DEF VAR h-b1wgen0081 AS HANDLE                                  NO-UNDO.
DEF VAR aux_vlsldapl AS DECI                                    NO-UNDO.

DEF VAR aux_cdcritic AS INT                                     NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.

/* Variaveis retornadas da procedure pc_busca_aplicacoes_car */
DEF VAR aux_nraplica   AS INTE                                  NO-UNDO.
DEF VAR aux_dsnomenc   AS CHAR                                  NO-UNDO.
DEF VAR aux_vlaplica   AS DECI                                  NO-UNDO.
DEF VAR aux_dtmvtolt   AS CHAR                                  NO-UNDO.

/* Variáveis utilizadas para receber clob da rotina no oracle */
DEF VAR xDoc          AS HANDLE   NO-UNDO.   
DEF VAR xRoot         AS HANDLE   NO-UNDO.  
DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
DEF VAR xField        AS HANDLE   NO-UNDO. 
DEF VAR xText         AS HANDLE   NO-UNDO. 
DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
DEF VAR xml_req       AS LONGCHAR NO-UNDO.


DEF QUERY  q_craprda FOR tt-saldo-rdca.
DEF BROWSE b_craprda QUERY q_craprda
      DISP tt-saldo-rdca.dtmvtolt COLUMN-LABEL "Data"      FORMAT "99/99/9999"
           tt-saldo-rdca.nraplica COLUMN-LABEL "Aplicacao" FORMAT "zzz,zz9" 
           tt-saldo-rdca.dsaplica NO-LABEL                 FORMAT "x(20)"
           tt-saldo-rdca.vlaplica COLUMN-LABEL "Valor"     FORMAT "zzz,zzz,zzz,zz9.99" 
           WITH CENTERED WIDTH 64 7 DOWN OVERLAY TITLE " Aplicacoes ".

FORM b_craprda HELP "Pressione ENTER para selecionar ou F4 para sair."
          WITH NO-BOX CENTERED OVERLAY ROW 10 FRAME f_aplicacoes.


ON  END-ERROR OF b_craprda
    DO:
        HIDE FRAME f_aplicacoes.
    END.

ON  RETURN OF b_craprda
    DO:
       IF  AVAIL tt-saldo-rdca THEN
           DO:
               ASSIGN par_nraplica = tt-saldo-rdca.nraplica.
               CLOSE QUERY q_craprda.

               APPLY "END-ERROR" TO b_craprda.
           END.
    END.


    IF  NOT VALID-HANDLE(h-b1wgen0081)  THEN
        RUN sistema/generico/procedures/b1wgen0081.p
            PERSISTENT SET h-b1wgen0081.
    
    RUN obtem-dados-aplicacoes IN h-b1wgen0081
                              ( INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT par_cdoperad,
                                INPUT CAPS(par_nmdatela),
                                INPUT 1,  /** origem **/
                                INPUT par_nrdconta,
                                INPUT 1,  /** idseqttl **/
                                INPUT 0,  /** nraplica **/
                                INPUT CAPS(par_nmdatela),
                                INPUT FALSE, /** Log **/
                                INPUT ?,
                                INPUT ?,
                               OUTPUT aux_vlsldapl,
                               OUTPUT TABLE tt-saldo-rdca,
                               OUTPUT TABLE tt-erro ).
    
    IF  VALID-HANDLE(h-b1wgen0081)  THEN
        DELETE PROCEDURE h-b1wgen0081.

    /********NOVA CONSULTA APLICACOOES*********/
    /** Saldo das aplicacoes **/
    
    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag raiz em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag aplicacao em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
    
    /* Efetuar a chamada a rotina Oracle */
    RUN STORED-PROCEDURE pc_busca_aplicacoes_car
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper     /* Código da Cooperativa*/
                                        ,INPUT par_cdoperad     /* Código do Operador*/
                                        ,INPUT par_nmdatela     /* Nome da Tela*/
                                        ,INPUT 1                /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA*/
                                        ,INPUT par_nrdconta     /* Número da Conta*/
                                        ,INPUT 1                /* Titular da Conta*/
                                        ,INPUT 0                /* Número da Aplicação - Parâmetro Opcional*/
                                        ,INPUT 0                /* Código do Produto – Parâmetro Opcional */
                                        ,INPUT glb_dtmvtolt     /* Data de Movimento*/
                                        ,INPUT 5                /* Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas) */
                                        ,INPUT 0                /* Identificador de Log (0 – Não / 1 – Sim) */
                                        ,OUTPUT ?               /* XML com informações de LOG*/
                                        ,OUTPUT 0               /* Código da crítica */
                                        ,OUTPUT "").            /* Descrição da crítica */

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_busca_aplicacoes_car
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

    /* Busca possíveis erros */ 
    ASSIGN aux_cdcritic = 0
          aux_dscritic = ""
          aux_cdcritic = pc_busca_aplicacoes_car.pr_cdcritic 
                         WHEN pc_busca_aplicacoes_car.pr_cdcritic <> ?
          aux_dscritic = pc_busca_aplicacoes_car.pr_dscritic 
                         WHEN pc_busca_aplicacoes_car.pr_dscritic <> ?.
                                                        
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_busca_aplicacoes_car.pr_clobxmlc.

    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 
     
    xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
    xDoc:GET-DOCUMENT-ELEMENT(xRoot).
    
    DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
    
        xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
    
        IF xRoot2:SUBTYPE <> "ELEMENT"   THEN 
         NEXT. 
    
        IF xRoot2:NUM-CHILDREN > 0 THEN
           CREATE tt-saldo-rdca.

        DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
        
            xRoot2:GET-CHILD(xField,aux_cont).
                
            IF xField:SUBTYPE <> "ELEMENT" THEN 
                NEXT. 
            
            xField:GET-CHILD(xText,1).            

            ASSIGN aux_nraplica = INT (xText:NODE-VALUE) WHEN xField:NAME = "nraplica"
                   aux_dsnomenc = xText:NODE-VALUE WHEN xField:NAME = "dsnomenc"
                   aux_vlaplica = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlaplica"
                   aux_dtmvtolt = xText:NODE-VALUE WHEN xField:NAME = "dtmvtolt".
        END.            

        ASSIGN tt-saldo-rdca.dtmvtolt = DATE(aux_dtmvtolt)
               tt-saldo-rdca.nraplica = aux_nraplica
               tt-saldo-rdca.dsaplica = aux_dsnomenc
               tt-saldo-rdca.vlaplica = aux_vlaplica.

    END.                

    SET-SIZE(ponteiro_xml) = 0. 
 
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.
                
    /*******FIM CONSULTA APLICACAOES**********/
    
    OPEN QUERY q_craprda FOR EACH tt-saldo-rdca NO-LOCK 
                                                BY tt-saldo-rdca.nraplica.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE :
        UPDATE b_craprda WITH FRAME f_aplicacoes.
        LEAVE.
    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            EMPTY TEMP-TABLE tt-saldo-rdca.

            HIDE FRAME f_aplicacoes NO-PAUSE.

            CLOSE QUERY q_craprda.
        END.
/* ......................................................................... */

