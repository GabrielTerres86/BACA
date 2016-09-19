/* .............................................................................

   Programa: crps699.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Reinert
   Data    : 08/07/2015                     Ultima atualizacao: 

   Dados referentes ao programa: 

   Frequencia: Diário (Executado via CRON).
   Objetivo  : Efetivar propostas de portabilidade de todas as cooperativas
               quando a mesma for concluída pelo JDCTC.

   Alteracoes: 

............................................................................ */

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/b1wgen0043tt.i }

ASSIGN glb_cdprogra = "crps699"
       glb_cdcritic = 0
       glb_dscritic = "".

/* Variaveis para o tratamento de criticas */
DEF VAR aux_des_erro AS CHAR                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                            NO-UNDO.

/* Variaveis auxiliares */
DEF VAR aux_nrispbif LIKE crapban.nrispbif                              NO-UNDO.
DEF VAR aux_nrportab LIKE tbepr_portabilidade.nrunico_portabilidade     NO-UNDO.
DEF VAR aux_cnpjbase LIKE tbepr_portabilidade.nrcnpjbase_if_origem      NO-UNDO.
DEF VAR aux_nrctrifo LIKE tbepr_portabilidade.nrcontrato_if_origem      NO-UNDO.
DEF VAR aux_cdmodali AS CHAR                                            NO-UNDO.
DEF VAR aux_nrcpfcgc LIKE crapass.nrcpfcgc                              NO-UNDO.
DEF VAR aux_dsmensag AS CHAR                                            NO-UNDO.
DEF VAR aux_cdagenci LIKE crapass.cdagenci                              NO-UNDO.
DEF VAR aux_nmarqlog AS CHAR                                            NO-UNDO.

/* Variaveis utilizadas para receber clob da rotina no oracle */
DEF VAR xDoc          AS HANDLE   NO-UNDO.   
DEF VAR xRoot         AS HANDLE   NO-UNDO.  
DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
DEF VAR xRoot3        AS HANDLE   NO-UNDO.  
DEF VAR xRoot4        AS HANDLE   NO-UNDO.  
DEF VAR xRoot5        AS HANDLE   NO-UNDO.  
DEF VAR xField        AS HANDLE   NO-UNDO. 
DEF VAR xText         AS HANDLE   NO-UNDO. 
DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
DEF VAR xml_req       AS LONGCHAR NO-UNDO.

/* Handles */
DEF VAR h-b1wgen0084 AS HANDLE                                          NO-UNDO.
DEF VAR h-b1wgen0171 AS HANDLE                                          NO-UNDO.

DEF TEMP-TABLE tt-dados-portabilidade NO-UNDO
    FIELD ispbif                AS DECI
    FIELD identdpartadmdo       AS DECI
    FIELD cnpjbase_iforcontrto  AS DECI
    FIELD nuportlddctc          AS CHAR
    FIELD codcontrtoor          AS CHAR
    FIELD tpcontrto             AS CHAR
    FIELD tpcli                 AS CHAR
    FIELD cnpj_cpfcli           AS DECI
    FIELD stportabilidade       AS CHAR.

UNIX SILENT VALUE("echo " + 
                  STRING(TODAY,"99/99/9999") + " - " +
                  STRING(TIME,"HH:MM:SS") +
                  " - " + glb_cdprogra + "' --> '" +
                  "Inicio da Execucao. " + 
                  " >> /usr/coop/cecred/log/proc_batch.log").                     


/* Para todas as cooperativas menos a central */
FOR EACH crapcop WHERE crapcop.cdcooper <> 3
                 NO-LOCK:

    FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper 
                       NO-LOCK NO-ERROR.
                      
    /* Atribuir caminho para o arquivo de log */
    ASSIGN aux_nmarqlog = "/usr/coop/" + crapcop.dsdircop + "/log/" +
                          "logprt.log".

    /* Busca todas as propostas de PORTABILIDADE aprovadas 
       a partir de 3 dias atras, pois apos enviarmos o pagamento para
       a IF Credora Original, ela tera mais 2 dias para confirmar o nosso
       pagamento e a proposta ser efetivada na cabine JDCTC */
    FOR EACH crawepr WHERE crawepr.cdcooper = crapcop.cdcooper
                       AND CAN-DO("1,3", STRING(crawepr.insitapr))
                       AND crawepr.dtaprova >= (crapdat.dtmvtolt - 9)
                       NO-LOCK,
        FIRST crapfin WHERE crapfin.cdcooper = crawepr.cdcooper
                        AND crapfin.cdfinemp = crawepr.cdfinemp
                        AND crapfin.tpfinali = 2 /*PORTABILIDADE DE CREDITO*/
                        NO-LOCK:

            /* Verifica se proposta ja foi efetivada */
            FIND crapepr WHERE crapepr.cdcooper = crawepr.cdcooper
                           AND crapepr.nrdconta = crawepr.nrdconta
                           AND crapepr.nrctremp = crawepr.nrctremp
                           NO-LOCK NO-ERROR.

            /* Se encontrou registro na crapepr proposta ja foi efetivada
                e deve ser ignorada */
            IF  AVAIL crapepr THEN
                NEXT.

            /* Zerar campos */
            ASSIGN aux_nrispbif = 0
                   aux_nrportab = ""
                   aux_cnpjbase = 0
                   aux_nrctrifo = ""
                   aux_cdmodali = ""
                   aux_nrcpfcgc = 0
                   aux_cdagenci = 0.

            EMPTY TEMP-TABLE tt-dados-portabilidade.

            /* Busca registro de banco da cooperativa central */
            FOR FIRST crapban FIELDS(nrispbif)
                      WHERE crapban.cdbccxlt = 85 NO-LOCK:

                ASSIGN aux_nrispbif = crapban.nrispbif.

            END.

            /* Busca registro de portabilidade */
            FOR FIRST tbepr_portabilidade
                FIELDS (nrunico_portabilidade nrcontrato_if_origem
                        nrcnpjbase_if_origem)
                WHERE tbepr_portabilidade.cdcooper = crawepr.cdcooper
                  AND tbepr_portabilidade.nrdconta = crawepr.nrdconta
                  AND tbepr_portabilidade.nrctremp = crawepr.nrctremp
                NO-LOCK:

                ASSIGN aux_nrportab = tbepr_portabilidade.nrunico_portabilidade 
                                        WHEN tbepr_portabilidade.nrunico_portabilidade <> ?
                       aux_cnpjbase = tbepr_portabilidade.nrcnpjbase_if_origem
                       aux_nrctrifo = tbepr_portabilidade.nrcontrato_if_origem.
            END.

            /* Buscar modalidade da proposta de emprestimo */
            FOR FIRST craplcr FIELDS (cdmodali cdsubmod)
                              WHERE craplcr.cdcooper = crawepr.cdcooper
                                AND craplcr.cdlcremp = crawepr.cdlcremp
                              NO-LOCK:

                ASSIGN aux_cdmodali = craplcr.cdmodali + craplcr.cdsubmod.

            END.

            /* Busca cpf/cnpj do cooperado */
            FOR FIRST crapass FIELDS (nrcpfcgc cdagenci)
                              WHERE crapass.cdcooper = crawepr.cdcooper
                                AND crapass.nrdconta = crawepr.nrdconta
                              NO-LOCK:
                ASSIGN aux_nrcpfcgc = crapass.nrcpfcgc
                       aux_cdagenci = crapass.cdagenci.
            END.

            /* Consulta situacao da portabilidade no JDCTC */
            RUN consulta_situacao(INPUT crawepr.cdcooper                    /* Código da Cooperativa*/
                                 ,INPUT aux_nrispbif                        /* Numero ISPB IF (085) */
                                 ,INPUT SUBSTRING(STRING(crapcop.nrdocnpj,  
                                                  "99999999999999"), 1, 8)  /* Identificador Participante Administrado */
                                 ,INPUT SUBSTRING(STRING(aux_cnpjbase,
                                                  "99999999999999"), 1, 8)  /* CNPJ Base IF Credora Original Contrato  */
                                 ,INPUT aux_nrportab                        /* Número único da portabilidade na CTC    */
                                 ,INPUT aux_nrctrifo                        /* Código Contrato Original                */
                                 ,INPUT aux_cdmodali                        /* Tipo Contrato                           */
                                 ,INPUT aux_nrcpfcgc                        /* CNPJ CPF Cliente                        */
                                 ,OUTPUT aux_des_erro                       /* Indicador erro OK/NOK */
                                 ,OUTPUT aux_dscritic).                     /* Descrição da crítica */ 

            /* Se retornou erro, gerar log na logprt */
            IF  aux_des_erro <> "OK" OR
                aux_dscritic <> ""   THEN
                DO:
                    
                    FOR FIRST tbepr_portabilidade
                       FIELDS (flgerro_efetivacao)
                        WHERE tbepr_portabilidade.cdcooper = crawepr.cdcooper
                          AND tbepr_portabilidade.nrdconta = crawepr.nrdconta
                          AND tbepr_portabilidade.nrctremp = crawepr.nrctremp
                        EXCLUSIVE-LOCK:
                        ASSIGN tbepr_portabilidade.flgerro_efetivacao = TRUE.
                    END.                    

                    UNIX SILENT VALUE("echo '" + STRING(crapdat.dtmvtolt, "99/99/9999") + " "
                                              + STRING(TIME,"HH:MM:SS") +
                                              " => Efetivacao " + 
                                              "|" + TRIM(STRING(aux_cdagenci, "zzz9")) +           /* PA */
                                              "|" + TRIM(STRING(crawepr.nrdconta, "zzzz,zzz,9")) + /* Conta*/
                                              "|" + TRIM(STRING(crawepr.nrctremp, "zzzzzzzzz9")) + /* Contrato*/
                                              "|" + TRIM(aux_nrportab) +                           /* Portabilidade */
                                              "|" + aux_dscritic +                           /* Erro */
                                              "' >> " + aux_nmarqlog).
                    NEXT.
                END.

            /* Busca dados retornados do JDCTC */
            FIND FIRST tt-dados-portabilidade NO-LOCK NO-ERROR.

            IF  AVAIL tt-dados-portabilidade THEN
                DO:                    
                    IF  tt-dados-portabilidade.stportabilidade = "SR9" OR 
                        tt-dados-portabilidade.stportabilidade = "SRF"  THEN
                        DO:
                            
                            RUN sistema/generico/procedures/b1wgen0084.p 
                                PERSISTENT SET h-b1wgen0084.

                            /* Grava a efetivacao da proposta */
                            RUN grava_efetivacao_proposta IN h-b1wgen0084
                                (INPUT crawepr.cdcooper
                                ,INPUT aux_cdagenci
                                ,INPUT 100
                                ,INPUT "1"
                                ,INPUT "crps699"
                                ,INPUT 1
                                ,INPUT crawepr.nrdconta
                                ,INPUT 1
                                ,INPUT crapdat.dtmvtolt
                                ,INPUT FALSE
                                ,INPUT crawepr.nrctremp
                                ,INPUT crawepr.insitapr
                                ,INPUT crawepr.dsobscmt
                                ,INPUT crawepr.dtdpagto
                                ,INPUT 0 /*cdbccxlt*/
                                ,INPUT 0 /*nrdolote*/
                                ,INPUT crapdat.dtmvtopr
                                ,INPUT crapdat.inproces
                                ,INPUT 0
                                ,INPUT 0
                                ,INPUT 0
                                ,INPUT 0
                                ,OUTPUT aux_dsmensag
                                ,OUTPUT TABLE tt-ratings
                                ,OUTPUT TABLE tt-erro).

                            IF  VALID-HANDLE(h-b1wgen0084) THEN
                                DELETE PROCEDURE h-b1wgen0084.

                            /* Procura erro */
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.

                            /* Se encontrou algum erro */
                            IF  AVAIL tt-erro THEN
                                DO:
                                    /* Gera log */
                                    UNIX SILENT VALUE("echo '" + STRING(crapdat.dtmvtolt, "99/99/9999") + " "
                                              + STRING(TIME,"HH:MM:SS") +
                                              " => Efetivacao " + 
                                              "|" + TRIM(STRING(aux_cdagenci, "zzz9")) +           /* PA */
                                              "|" + TRIM(STRING(crawepr.nrdconta, "zzzz,zzz,9")) + /* Conta*/
                                              "|" + TRIM(STRING(crawepr.nrctremp, "zzzzzzzzz9")) + /* Contrato*/
                                              "|" + TRIM(aux_nrportab) +                           /* Portabilidade */
                                              "|" + tt-erro.dscritic +                           /* Erro */
                                              "' >> " + aux_nmarqlog).

                                    NEXT.
                                END.

                            RUN sistema/generico/procedures/b1wgen0171.p 
                                PERSISTENT SET h-b1wgen0171.

                            RUN registrar_gravames IN h-b1wgen0171(INPUT crawepr.cdcooper
                                                                  ,INPUT crawepr.nrdconta
                                                                  ,INPUT crawepr.nrctremp
                                                    ,INPUT crapdat.dtmvtolt
                                                                  ,INPUT "E"
                                                                  ,OUTPUT TABLE tt-erro).

                            IF  VALID-HANDLE(h-b1wgen0171) THEN
                                DELETE PROCEDURE h-b1wgen0171.

                            /* Procura erro */
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.

                            /* Se encontrou algum erro, nao interfere na 
                               efetivacao */
                            IF  AVAIL tt-erro THEN
                                NEXT.
                        END.
                END.
    END.

END.

UNIX SILENT VALUE("echo " + 
                  STRING(TODAY,"99/99/9999") + " - " +
                  STRING(TIME,"HH:MM:SS") +
                  " - " + glb_cdprogra + "' --> '" +
                  "Fim da Execucao. " + 
                  " >> /usr/coop/cecred/log/proc_batch.log").

PROCEDURE consulta_situacao:

    DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                              NO-UNDO.
    DEF INPUT  PARAM par_nrispbif LIKE crapban.nrispbif                              NO-UNDO.    
    DEF INPUT  PARAM par_nrdocnpj AS CHAR                                            NO-UNDO.
    DEF INPUT  PARAM par_cnpjbase AS CHAR                                            NO-UNDO.
    DEF INPUT  PARAM par_nrportab LIKE tbepr_portabilidade.nrunico_portabilidade     NO-UNDO.
    DEF INPUT  PARAM par_nrctrifo LIKE tbepr_portabilidade.nrcontrato_if_origem      NO-UNDO.
    DEF INPUT  PARAM par_cdmodali AS CHAR                                            NO-UNDO.
    DEF INPUT  PARAM par_nrcpfcgc LIKE crapass.nrcpfcgc                              NO-UNDO.
    DEF OUTPUT PARAM par_des_erro AS CHAR                                            NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                                            NO-UNDO.

    /******** CONSULTA SITUACAO DE PORTABILIDADE NA JDCTC *********/    
    
    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag raiz em diante */ 
    CREATE X-NODEREF  xRoot2.   
    CREATE X-NODEREF  xRoot3.   
    CREATE X-NODEREF  xRoot4.   
    CREATE X-NODEREF  xRoot5.   
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
    
    /* Efetuar a chamada a rotina Oracle */
    RUN STORED-PROCEDURE pc_consulta_situacao_car
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper         /* Código da Cooperativa*/
                                        ,INPUT 1                    /* Proponente */
                                        ,INPUT "LEG"                /* Codigo Legado */
                                        ,INPUT par_nrispbif         /* Numero ISPB IF (085)                    */
                                        ,INPUT DECI(par_nrdocnpj)   /* Identificador Participante Administrado */
                                        ,INPUT DECI(par_cnpjbase)   /* CNPJ Base IF Credora Original Contrato  */
                                        ,INPUT par_nrportab         /* Número único da portabilidade na CTC    */
                                        ,INPUT par_nrctrifo         /* Código Contrato Original                */
                                        ,INPUT par_cdmodali         /* Tipo Contrato                           */
                                        ,INPUT "F"                  /* Tipo Cliente - Fixo 'F'                 */
                                        ,INPUT par_nrcpfcgc         /* CNPJ CPF Cliente                        */
                                        ,OUTPUT ?                   /* XML com dados da portabilidade*/
                                        ,OUTPUT ""                  /* Indicador erro OK/NOK */
                                        ,OUTPUT "").                /* Descrição da crítica */

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_consulta_situacao_car
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

    /* Busca possíveis erros */ 
    ASSIGN par_des_erro = ""
           par_dscritic = ""
           par_des_erro = pc_consulta_situacao_car.pr_des_erro 
                          WHEN pc_consulta_situacao_car.pr_des_erro <> ?
           par_dscritic = pc_consulta_situacao_car.pr_dscritic 
                          WHEN pc_consulta_situacao_car.pr_dscritic <> ?.

    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_consulta_situacao_car.pr_clobxmlc.

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
                  CREATE tt-dados-portabilidade.

               DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
               
                   xRoot2:GET-CHILD(xField,aux_cont).
                       
                   IF xField:SUBTYPE <> "ELEMENT" THEN 
                       NEXT. 
                   
                   xField:GET-CHILD(xText,1).            
        
                   ASSIGN tt-dados-portabilidade.ispbif               = DECI(xText:NODE-VALUE) WHEN xField:NAME = "ispbif"
                          tt-dados-portabilidade.identdpartadmdo      = DECI(xText:NODE-VALUE) WHEN xField:NAME = "identdpartadmdo"
                          tt-dados-portabilidade.cnpjbase_iforcontrto = DECI(xText:NODE-VALUE) WHEN xField:NAME = "cnpjbase_iforcontrto"
                          tt-dados-portabilidade.nuportlddctc         = xText:NODE-VALUE WHEN xField:NAME = "nuportlddctc"
                          tt-dados-portabilidade.codcontrtoor         = xText:NODE-VALUE WHEN xField:NAME = "codcontrtoor"
                          tt-dados-portabilidade.tpcontrto            = xText:NODE-VALUE WHEN xField:NAME = "tpcontrto"
                          tt-dados-portabilidade.tpcli                = xText:NODE-VALUE WHEN xField:NAME = "tpcli"
                          tt-dados-portabilidade.cnpj_cpfcli          = DECI(xText:NODE-VALUE) WHEN xField:NAME = "cnpj_cpfcli"
                          tt-dados-portabilidade.stportabilidade      = xText:NODE-VALUE WHEN xField:NAME = "stportabilidade".
               END.            
               
           END.                
    
      END.

    SET-SIZE(ponteiro_xml) = 0. 
 
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.
                
    /*******FIM CONSULTA SITUACAO DE PORTABILIDADE NA JDCTC *********/    
END PROCEDURE.
