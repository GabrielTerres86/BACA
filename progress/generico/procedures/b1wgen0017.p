/*..............................................................................

    Programa: b1wgen0017.p
    Autor   : Evandro
    Data    : Maio/2007                      Ultima Atualizacao: 09/12/2015
    
    Dados referentes ao programa:

    Objetivo  : BO para listar os holerites.

    Alteracoes: 07/03/2008 - Utilizar include para temp-table (David).
    
                28/07/2011 - Alterado ordenacao por data decrescente (Jorge).
                
                27/12/2013 - Alterado 3a linha de PAC para PA. (Reinert)
                
                18/08/2015 - Alteraçoes Projeto 158 - Folha IB (Vanessa)
                
                09/12/2015 - Ajustando campo dtrefere para CHAR.
                             (Andre Santos - SUPERO)
..............................................................................*/
{ sistema/generico/includes/b1wgen0017tt.i }
{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }


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



PROCEDURE lista_holerites:

    DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper             NO-UNDO.
    DEF INPUT  PARAM par_nrdconta LIKE crapass.nrdconta             NO-UNDO.
    DEF INPUT  PARAM par_idseqttl LIKE crapttl.idseqttl             NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-holerites.
    DEF OUTPUT PARAM par_dscritic LIKE crapcri.dscritic             NO-UNDO.
    
    DEF VAR aux_cdcritic AS INT                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtrefere AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdpagto AS CHAR                                    NO-UNDO.
    DEF VAR aux_idtipfol AS INT                                     NO-UNDO.
    DEF VAR aux_nrdrowid AS CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-holerites.
    
    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag raiz em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag aplicacao em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
    
   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
   
    /* Efetuar a chamada a rotina Oracle */
    RUN STORED-PROCEDURE pc_lista_holerites_ib
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper     /* Código da Cooperativa*/
                                        ,INPUT par_nrdconta             /* Código do Operador*/
                                        ,INPUT par_idseqttl     /* Nome da Tela*/
                                        ,OUTPUT ?               /* XML com informações de LOG*/
                                        ,OUTPUT 0               /* Código da crítica */
                                        ,OUTPUT "").            /* Descrição da crítica */

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_lista_holerites_ib
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

    /* Busca possíveis erros */ 
    ASSIGN aux_cdcritic = 0
          aux_dscritic = ""
          aux_cdcritic = pc_lista_holerites_ib.pr_cdcritic 
                         WHEN pc_lista_holerites_ib.pr_cdcritic <> ?
          aux_dscritic = pc_lista_holerites_ib.pr_dscritic 
                         WHEN pc_lista_holerites_ib.pr_dscritic <> ?.
                                                        
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_lista_holerites_ib.pr_clobxml.
    
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
           CREATE tt-holerites.

        DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
        
            xRoot2:GET-CHILD(xField,aux_cont).
            
           
       
            IF xField:SUBTYPE <> "ELEMENT" THEN 
                NEXT. 
            
            xField:GET-CHILD(xText,1).                   
            
            
            ASSIGN aux_dtrefere =     (xText:NODE-VALUE) WHEN xField:NAME = "dtrefere"
                   aux_dsdpagto =     (xText:NODE-VALUE) WHEN xField:NAME = "dsdpagto"
                   aux_idtipfol = INT (xText:NODE-VALUE) WHEN xField:NAME = "idtipfol"
                   aux_nrdrowid =     (xText:NODE-VALUE) WHEN xField:NAME = "nrdrowid".                   
             
                   
        END.
        
        ASSIGN tt-holerites.dtrefere = aux_dtrefere
               tt-holerites.dsdpagto = aux_dsdpagto
               tt-holerites.nrdrowid = aux_nrdrowid
               tt-holerites.idtipfol = aux_idtipfol.
        
   
    END.
    
    
    FIND FIRST tt-holerites NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE tt-holerites   THEN
         DO:
             par_dscritic = "Nao ha registro de holerites para o cooperado".
             RETURN "NOK".
         END.
   
    
    RETURN "OK".
 
END PROCEDURE.

/*Convertido para Oracle folh0002.pc_impressao_comprovante => pr_idtipfol = 0*/ 
PROCEDURE detalha_holerite:

    DEF INPUT  PARAM par_nrdrowid AS ROWID                          NO-UNDO.

    DEF OUTPUT PARAM par_dsholeri AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic LIKE crapcri.dscritic             NO-UNDO.

    DEF VAR aux_dsdpagto          AS CHAR                           NO-UNDO.
    DEF VAR aux_nmextemp          LIKE crapemp.nmextemp             NO-UNDO.

    FIND craphdp WHERE ROWID(craphdp) = par_nrdrowid NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE craphdp   THEN
         DO:
             par_dscritic = "Registro do holerite nao encontrado".
             RETURN "NOK".
         END.

    /* Busca a data do sistema */
    FIND FIRST crapdat WHERE crapdat.cdcooper = craphdp.cdcooper
                             NO-LOCK NO-ERROR.
                             
    IF   NOT AVAILABLE crapdat   THEN
         DO:
             par_dscritic = "Registo de data nao encontrado".
             RETURN "NOK".
         END.
         
    FIND crapass WHERE crapass.cdcooper = craphdp.cdcooper   AND
                       crapass.nrdconta = craphdp.nrdconta   NO-LOCK NO-ERROR.
                       
    IF   NOT AVAILABLE crapass   THEN
         DO:
             par_dscritic = "Associado nao cadastrado".
             RETURN "NOK".
         END.
         
    /* Procura o nome da empresa */
    FIND crapemp WHERE crapemp.cdcooper = craphdp.cdcooper   AND
                       crapemp.nrdocnpj = craphdp.nrcgcemp   NO-LOCK NO-ERROR.
                       
    IF   AVAILABLE crapemp   THEN
         ASSIGN aux_nmextemp = crapemp.nmextemp
                aux_nmextemp = FILL(" ",INT((40 - LENGTH(aux_nmextemp)) / 2)) +
                               aux_nmextemp
                aux_nmextemp = aux_nmextemp +
                               FILL(" ",40 - LENGTH(aux_nmextemp)).
    ELSE
         aux_nmextemp = "".
         
    aux_dsdpagto = IF   craphdp.cddpagto = 1   THEN
                        "            PAGAMENTO MENSAL"
                   ELSE
                   IF   craphdp.cddpagto = 2   THEN
                        "         PAGAMENTO 1a QUINZENA"
                   ELSE
                   IF   craphdp.cddpagto = 3   THEN
                        "              ADIANTAMENTO"
                   ELSE
                   IF   craphdp.cddpagto = 4   THEN
                        "                 FERIAS"
                   ELSE
                   IF   craphdp.cddpagto = 5   THEN
                        "              13o SALARIO"
                   ELSE "".

    
    /* Monta as linhas para a impressao do holerite - linhas 40 caracteres */
                   /* 1a linha */
    par_dsholeri = STRING(aux_dsdpagto,"x(40)") +
                   
                   /* 2a linha */
                   STRING(crapdat.dtmvtolt,"99/99/9999") +
                   "                         "           +
                   STRING(TIME,"HH:MM")                  +
                   
                   /* 3a linha */
                   "PA: "                                 +
                   STRING(crapass.cdagenci,"9999")        +
                   "              "                       +
                   "CONTA: "                              +
                   STRING(craphdp.nrdconta,"9,999,999,9") +
                   
                   /* 4a linha */
                   "            DADOS DA EMPRESA:           " +
                   
                   /* 5a linha */
                   aux_nmextemp                               +
                   
                   /* 6a linha */
                   "        CNPJ: "                                   +
                   STRING(STRING(craphdp.nrcgcemp,"99999999999999"),
                                 "xx.xxx.xxx/xxxx-xx")                +
                   "        "                                         +
                   
                   /* 7a linha */
                   "========================================" +

                   /* 8a linha */
                   "         DADOS DO FUNCIONARIO:          " +
                   
                   /* 9a linha */
                   STRING(craphdp.nmfuncio,"x(40)") +
                   
                   /* 10a linha */
                   "CARGO: "                        +
                   STRING(craphdp.dsfuncao,"x(33)") + 
                   
                   /* 11a linha */
                   "MATRICULA: "                                    +
                   STRING(STRING(DEC(craphdp.dsnromat),"99999999"),
                          "xx.xxx.xxx")                             +
                   " "                                              +
                   "ADMISSAO: "                                     +
                   STRING(craphdp.dtadmiss,"99/99/99")              +
                   
                   /* 12a linha */
                   "CPF: "                                            +
                   STRING(STRING(craphdp.nrcpfcgc,"99999999999"),
                                 "xxx.xxx.xxx-xx")                    +
                   "   RG:  "                                         +
                   STRING(craphdp.nrdocfco,"x(13)")                   +
                                 
                   /* 13a linha */
                   "PIS/PASEP: "                                       +
                   craphdp.nrpisfco +
                   
                   " CTPS:"                                           +
                   craphdp.nrctpfco  +
                   
                   /* 14a linha */
                   "========================================" +
                   
                   /* 15a linha */
                   "         DADOS DO COMPROVANTE:          " +
                   
                   /* 16a linha */
                   "PERIODO: "                           +
                   STRING(craphdp.dtrefere,"99/99/9999") +
                   "       NRO. LOTE: "                  +
                   STRING(craphdp.nrdolote,"999")        +
                   
                   /* 17a linha */
                   "COD. DESCRICAO                     VALOR".
                   
    /* Registros do salario */
    FOR EACH crapddp WHERE crapddp.cdcooper = craphdp.cdcooper   AND
                           crapddp.nrdconta = craphdp.nrdconta   AND
                           crapddp.idseqttl = craphdp.idseqttl   AND
                           crapddp.dtrefere = craphdp.dtrefere   AND
                           crapddp.cddpagto = craphdp.cddpagto   AND
                           crapddp.dtmvtolt = craphdp.dtmvtolt   AND
                           crapddp.tpregist = 2                  NO-LOCK
                           BY crapddp.nrsequen:
                           
        par_dsholeri = par_dsholeri                     +
                       STRING(crapddp.dscodlan,"9999")  +
                       " "                              + 
                       STRING(crapddp.dslancto,"x(20)") +
                       " "                              +
                       STRING(crapddp.vllancto,"zzz,zzz,zz9.99").
    END.
    
    par_dsholeri = par_dsholeri +
                   "========================================".
                   
    /* Mensagens do salario */                   
    FOR EACH crapmdp WHERE crapmdp.cdcooper = craphdp.cdcooper   AND
                           crapmdp.nrdconta = craphdp.nrdconta   AND
                           crapmdp.idseqttl = craphdp.idseqttl   AND
                           crapmdp.dtrefere = craphdp.dtrefere   AND
                           crapmdp.cddpagto = craphdp.cddpagto   AND
                           crapmdp.dtmvtolt = craphdp.dtmvtolt   AND
                           crapmdp.tpregist = 3                  NO-LOCK
                           BY crapmdp.nrsequen:
                           
        par_dsholeri = par_dsholeri +
                       STRING(crapmdp.dscomprv,"x(40)").
    END.
    
    par_dsholeri = par_dsholeri                               +
                   "========================================" +
                   "AS   INFORMACOES    DISPONIVEIS    NESTE" +
                   "COMPROVANTE  SAO   DE   RESPONSABILIDADE" +
                   "EXCLUSIVA  DA  EMPRESA  FONTE  PAGADORA." +
                   "QUALQUER   OCORRENCIA    MOTIVADA    POR" +
                   "DIVERGENCIA    ENTRE    OS     REGISTROS" +
                   "CONSTANTES  NESTE   COMPROVANTE   DEVERA" +
                   "SER   ESCLARECIDO   JUNTO   A   EMPRESA.".

    RETURN "OK".

END PROCEDURE.


