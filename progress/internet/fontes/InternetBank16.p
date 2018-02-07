/*..............................................................................

   Programa: siscaixa/web/InternetBank16.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Julho/2007.                       Ultima atualizacao: 29/04/2015
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Buscar extrato de aplicacoes RDCA e RDC para Internet.
   
   Alteracoes: 09/10/2007 - Gerar log com data TODAY e nao dtmvtolt (David).
               
               06/03/2008 - Utilizar include de temp-tables (David).
   
               03/11/2008 - Inclusao widget-pool (martin)
               
               30/11/2010 - Utilizar BO b1wgen0081.p  e retirado a 
                            procedure de log (Adriano).
                            
               21/12/2010 - Retornar campo que indica se a aplicacao esta
                            bloqueada no xml (David).             
 
               02/01/2012 - Substituido valor da tag <dshistor> para receber 
                            campo dsextrat da temp-table. (Jorge)
                            
               09/08/2013 - Incluir procedure retorna-valor-blqjud e tag xml
                            <vlblqjud> (Lucas R.).
               
               30/12/2014 - Alteração nas informações de resumo que deverão 
                            ser apresentados no cabeçalho e rodape do 
                            detalhamento das aplicações do Internet Bank.
                            (Carlos Rafael Tanholi - Projeto Novos Produtos de Captação)
                            
               10/03/2015 - Adicionado o parametro de aliquota de IRRF na chamada da 
                            procedure pc_busca_extrato_aplicacao_car da APLI0005
                            (Carlos Rafael Tanholi - Projeto Novos Produtos de Captação)
                            
               11/03/2015 - Multiplicar os valores retornados nos parâmetros da 
                            pc_busca_extrato_aplicacao_car por 100. 
                            Resultante deve possuir 6 casas decimais
                            (Carlos Rafael Tanholi - Projeto Novos Produtos de Captação)  
                            
               17/03/2015 - Tratamento da data de vencimento para aplicacoes RDCA30/RDCA60
                            (Jean Michel). 
                            
               29/04/2015 - Incluido verificacao de ponteiro null, ocorria erro
                            somente no log (Jean Michel).                                    
..............................................................................*/
 
CREATE WIDGET-POOL.
    
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0081tt.i }
{ sistema/generico/includes/var_internet.i }

{ sistema/generico/includes/var_oracle.i }

DEF VAR h-b1wgen0081 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0004 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0155 AS HANDLE                                         NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dssitapl AS CHAR                                           NO-UNDO.

DEF VAR aux_sldresga AS DECI                                           NO-UNDO.

DEF VAR aux_vlblqjud AS DECI                                           NO-UNDO.
DEF VAR aux_vlresblq AS DECI                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF  INPUT PARAM par_nraplica LIKE craprda.nraplica                    NO-UNDO.
DEF  INPUT PARAM par_intipapl AS INTE                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

/* variaveis de retorno para os dados da aplicacao */
DEF VAR aux_vlresgat AS DECI                                           NO-UNDO INIT 0.
DEF VAR aux_vlsldrgt AS DECI                                           NO-UNDO INIT 0.
DEF VAR aux_percirrf AS DECI                                           NO-UNDO INIT 0.
DEF VAR aux_vlrendim AS DECI                                           NO-UNDO INIT 0.
DEF VAR aux_vldoirrf AS DECI                                           NO-UNDO INIT 0.
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_txaplica AS DECI DECIMALS 8                                NO-UNDO.
DEF VAR aux_qtdiacar AS INTE                                           NO-UNDO.
DEF VAR aux_nraplica AS INTE                                           NO-UNDO.
DEF VAR aux_vlaplica AS DECI                                           NO-UNDO. 
DEF VAR aux_dtmvtolt LIKE crapdat.dtmvtolt                             NO-UNDO.
DEF VAR aux_dtvencto AS CHAR                                           NO-UNDO.
DEF VAR aux_txacumul AS DECI DECIMALS 6                                NO-UNDO.
DEF VAR aux_txacumes AS DECI DECIMALS 6                                NO-UNDO.
DEF VAR aux_dsnomenc AS CHAR                                           NO-UNDO.
DEF VAR aux_qtdiaapl AS INTE                                           NO-UNDO. 
DEF VAR aux_nmdindex AS CHAR                                           NO-UNDO. 
DEF VAR aux_idtxfixa AS INTE                                           NO-UNDO.
DEF VAR aux_idtipapl AS CHAR                                           NO-UNDO.  
DEF VAR aux_tpaplica AS INTE                                           NO-UNDO.

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


ASSIGN aux_dstransa = "Extrato de aplicacoes RDCA e RDC para Internet.".

ASSIGN aux_vlblqjud = 0
       aux_vlresblq = 0.

FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper 
                         NO-LOCK NO-ERROR.

/*** Busca Saldo Bloqueado Judicial ***/
IF  NOT VALID-HANDLE(h-b1wgen0155) THEN
    RUN sistema/generico/procedures/b1wgen0155.p 
        PERSISTENT SET h-b1wgen0155.

RUN retorna-valor-blqjud IN h-b1wgen0155(INPUT par_cdcooper,
                                         INPUT par_nrdconta,
                                         INPUT 0, /* fixo - nrcpfcgc */
                                         INPUT 0, /* fixo - cdtipmov */
                                         INPUT 2, /* 2 - Aplicacao */
                                         INPUT crapdat.dtmvtolt,
                                         OUTPUT aux_vlblqjud,
                                         OUTPUT aux_vlresblq).

IF  VALID-HANDLE(h-b1wgen0155) THEN
    DELETE PROCEDURE h-b1wgen0155.
/*** FIM - Busca Saldo Bloqueado Judicial ***/                         


/********NOVA CONSULTA APLICACOOES*********/
/* Inicializando objetos para leitura do XML */ 
CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

/* Efetuar a chamada a rotina Oracle */ 
RUN STORED-PROCEDURE pc_lista_aplicacoes_car
   aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,     /* Código da Cooperativa */
                                        INPUT "996",            /* Código do Operador */
                                        INPUT "INTERNETBANK",   /* Nome da Tela */
                                        INPUT 3,                /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                        INPUT 900,              /* Numero do Caixa */
                                        INPUT par_nrdconta,     /* Número da Conta */
                                        INPUT par_idseqttl,     /* Titular da Conta */
                                        INPUT 90,               /* Codigo da Agencia */
                                        INPUT "INTERNETBANK",   /* Codigo do Programa */
                                        INPUT par_nraplica,     /* Número da Aplicação - Parâmetro Opcional */
                                        INPUT 0,                /* Código do Produto – Parâmetro Opcional */ 
                                        INPUT crapdat.dtmvtolt, /* Data de Movimento */
                                        INPUT 0,                /* Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas) */
                                        INPUT 0,                /* Identificador de Log (0 – Não / 1 – Sim) */ 																 
                                       OUTPUT ?,                /* XML com informações de LOG */
                                       OUTPUT 0,                /* Código da crítica */
                                       OUTPUT "").              /* Descrição da crítica */


/* Fechar o procedimento para buscarmos o resultado */ 
CLOSE STORED-PROC pc_lista_aplicacoes_car
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

/* Busca possíveis erros */ 
ASSIGN aux_cdcritic = 0
       aux_dscritic = ""
       aux_cdcritic = pc_lista_aplicacoes_car.pr_cdcritic 
                     WHEN pc_lista_aplicacoes_car.pr_cdcritic <> ?
       aux_dscritic = pc_lista_aplicacoes_car.pr_dscritic 
                     WHEN pc_lista_aplicacoes_car.pr_dscritic <> ?.

IF aux_cdcritic <> 0 OR
   aux_dscritic <> "" THEN
  DO:
        
    ASSIGN aux_dscritic = "Nao foi possivel consultar aplicacoes.".
    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
    RUN proc_geracao_log (INPUT FALSE).
     
    RETURN "NOK".    
 END.

/* Buscar o XML na tabela de retorno da procedure Progress */ 
ASSIGN xml_req = pc_lista_aplicacoes_car.pr_clobxmlc. 

/* Efetuar a leitura do XML*/ 
SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
PUT-STRING(ponteiro_xml,1) = xml_req. 

IF ponteiro_xml <> ? THEN
    DO:
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
        
                ASSIGN aux_nraplica =  INT(xText:NODE-VALUE) WHEN xField:NAME = "nraplica". 
                ASSIGN aux_dsnomenc =      xText:NODE-VALUE  WHEN xField:NAME = "dsnomenc".
                ASSIGN aux_vlaplica =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "vlaplica".
                ASSIGN aux_dtmvtolt = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtmvtolt".
                ASSIGN aux_dtvencto =      xText:NODE-VALUE  WHEN xField:NAME = "dtvencto".
                ASSIGN aux_qtdiaapl =  INT(xText:NODE-VALUE) WHEN xField:NAME = "qtdiaapl".
                ASSIGN aux_qtdiacar =  INT(xText:NODE-VALUE) WHEN xField:NAME = "qtdiauti".
                ASSIGN aux_idtxfixa =  INT(xText:NODE-VALUE) WHEN xField:NAME = "idtxfixa".
                ASSIGN aux_txaplica =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "txaplmax".
                ASSIGN aux_nmdindex =      xText:NODE-VALUE  WHEN xField:NAME = "nmdindex".
                ASSIGN aux_percirrf =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "percirrf".
                ASSIGN aux_sldresga =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "sldresga".
                ASSIGN aux_dssitapl =      xText:NODE-VALUE  WHEN xField:NAME = "dssitapl".
                ASSIGN aux_vlsldrgt =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "sldresga".
                ASSIGN aux_idtipapl =      xText:NODE-VALUE  WHEN xField:NAME = "idtipapl".
                ASSIGN aux_tpaplica =  INT(xText:NODE-VALUE) WHEN xField:NAME = "tpaplica".
        
            END. 
            
        END.
        
        SET-SIZE(ponteiro_xml) = 0.
    END.

DELETE OBJECT xDoc. 
DELETE OBJECT xRoot. 
DELETE OBJECT xRoot2. 
DELETE OBJECT xField. 
DELETE OBJECT xText.
    
/******* VALIDACAO DO TIPO DA APLICACAO - PARA GERACAO DO EXTRATO **********/

IF aux_idtipapl <> 'A' THEN /* APLICACOES NOVAS */
    DO:
        
        /* Inicializando objetos para leitura do XML */ 
        CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
        CREATE X-NODEREF  xRoot.   /* Vai conter a tag raiz em diante */ 
        CREATE X-NODEREF  xRoot2.  /* Vai conter a tag aplicacao em diante */ 
        CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
        CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */
        
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
        
        /* Efetuar a chamada a rotina Oracle */
        
        RUN STORED-PROCEDURE pc_busca_extrato_aplicacao_car
         aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper /* Código da Cooperativa */
                                             ,INPUT "996" /* Código do Operador */
                                             ,INPUT "INTERNETBANK" /* Nome da Tela */
                                             ,INPUT 3            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                             ,INPUT par_nrdconta /* Número da Conta */
                                             ,INPUT par_idseqttl /* Titular da Conta */
                                             ,INPUT par_dtmvtolt /* Data de Movimento */
                                             ,INPUT par_nraplica /* Número da Aplicação */
                                             ,INPUT 0            /* Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim) */
                                             ,INPUT 1            /* Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim) */
                                             ,OUTPUT 0           /* Valor de resgate    */
                                             ,OUTPUT 0           /* Valor de rendimento */
                                             ,OUTPUT 0           /* Valor do IRRF       */
                                             ,OUTPUT 0           /* Rendimento no mes   */
                                             ,OUTPUT 0           /* Rendimento total    */
                                             ,OUTPUT 0           /* Valor da aliquota de IRRF */
                                             ,OUTPUT ?           /* XML com informações de LOG*/
                                             ,OUTPUT 0           /* Código da crítica */
                                             ,OUTPUT "").        /* Descrição da crítica */
        
        /* Fechar o procedimento para buscarmos o resultado */ 
        CLOSE STORED-PROC pc_busca_extrato_aplicacao_car
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
        
        
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
        
        /* Busca possíveis erros */ 
        ASSIGN aux_cdcritic = 0
            aux_dscritic = ""
            aux_cdcritic = pc_busca_extrato_aplicacao_car.pr_cdcritic 
                           WHEN pc_busca_extrato_aplicacao_car.pr_cdcritic <> ?
            aux_dscritic = pc_busca_extrato_aplicacao_car.pr_dscritic 
                           WHEN pc_busca_extrato_aplicacao_car.pr_dscritic <> ?.
        
        
        IF aux_cdcritic > 0 OR 
        aux_dscritic <> "" THEN
        DO:
            ASSIGN aux_dscritic = "<dsmsgerr>" + STRING(aux_cdcritic) + " - " + aux_dscritic + "</dsmsgerr>".    
            RETURN "NOK".
        END.
        
        /* Buscar o XML na tabela de retorno da procedure Progress */ 
        ASSIGN xml_req = pc_busca_extrato_aplicacao_car.pr_clobxmlc.
        ASSIGN aux_vlresgat = pc_busca_extrato_aplicacao_car.pr_vlresgat WHEN pc_busca_extrato_aplicacao_car.pr_vlresgat <> ?.
        ASSIGN aux_vlrendim = pc_busca_extrato_aplicacao_car.pr_vlrendim WHEN pc_busca_extrato_aplicacao_car.pr_vlrendim <> ?.
        ASSIGN aux_vldoirrf = pc_busca_extrato_aplicacao_car.pr_vldoirrf WHEN pc_busca_extrato_aplicacao_car.pr_vldoirrf <> ?. 
        ASSIGN aux_txacumul = pc_busca_extrato_aplicacao_car.pr_txacumul WHEN pc_busca_extrato_aplicacao_car.pr_txacumul <> ?. 
        ASSIGN aux_txacumes = pc_busca_extrato_aplicacao_car.pr_txacumes WHEN pc_busca_extrato_aplicacao_car.pr_txacumes <> ?. 
    
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
            CREATE tt-extr-rdca.
        
         DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
        
             xRoot2:GET-CHILD(xField,aux_cont).
        
             IF xField:SUBTYPE <> "ELEMENT" THEN 
                 NEXT. 
        
             xField:GET-CHILD(xText,1).
             
             ASSIGN tt-extr-rdca.cdagenci = INTE(xText:NODE-VALUE) WHEN xField:NAME = "cdagenci"
                    tt-extr-rdca.dtmvtolt = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtmvtolt" 
                    tt-extr-rdca.cdhistor = INTE(xText:NODE-VALUE) WHEN xField:NAME = "cdhistor"
                    tt-extr-rdca.vllanmto = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vllanmto"
                    tt-extr-rdca.dshistor = STRING(tt-extr-rdca.cdhistor, "9999") + "-" + xText:NODE-VALUE WHEN xField:NAME = "dshistor"
                    tt-extr-rdca.dsextrat = STRING(xText:NODE-VALUE) WHEN xField:NAME = "dsextrat"
                    tt-extr-rdca.nrdocmto = INTE(xText:NODE-VALUE) WHEN xField:NAME = "nrdocmto"
                    tt-extr-rdca.indebcre = xText:NODE-VALUE WHEN xField:NAME = "indebcre"
                    tt-extr-rdca.vllanmto = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vllanmto"
                    tt-extr-rdca.vlsldapl = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsldtot"
                    tt-extr-rdca.txaplica = DECI(xText:NODE-VALUE) WHEN xField:NAME = "txaplmax"
                    tt-extr-rdca.dsaplica = STRING(xText:NODE-VALUE) WHEN xField:NAME = "nraplica".
        
         END.            
        
        END.                
        
        SET-SIZE(ponteiro_xml) = 0. 
        
        DELETE OBJECT xDoc. 
        DELETE OBJECT xRoot. 
        DELETE OBJECT xRoot2. 
        DELETE OBJECT xField. 
        DELETE OBJECT xText.
    END.
ELSE  /* APLICACOES ANTIGAS */
    DO:

        RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT
            SET h-b1wgen0081.

        RUN consulta-extrato-rdca IN h-b1wgen0081 (INPUT par_cdcooper,
                                                   INPUT 90,
                                                   INPUT 900,
                                                   INPUT "996",
                                                   INPUT "INTERNETBANK", 
                                                   INPUT par_nrdconta,
                                                   INPUT par_idseqttl, 
                                                   INPUT par_dtmvtolt, 
                                                   INPUT par_nraplica,
                                                   INPUT par_intipapl,
                                                   INPUT aux_sldresga,
                                                   INPUT ?,
                                                   INPUT ?,
                                                   INPUT "InternetBank",
                                                   INPUT 3,
                                                   INPUT TRUE,
                                                   OUTPUT TABLE tt-erro,
                                                   OUTPUT TABLE tt-extr-rdca).
               
        DELETE PROCEDURE h-b1wgen0081.
    
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                ASSIGN aux_dscritic = IF  AVAILABLE tt-erro  THEN
                                          TRIM(tt-erro.dscritic)
                                      ELSE 
                                          "Erro ao consultar extrato."
                                          xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
                                     
                RETURN "NOK".
            END.

    END.

IF aux_dtvencto = ? THEN
    ASSIGN aux_dtvencto = " ".

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "<APLICACOES dssitapl='" + aux_dssitapl + "'" +
                                          " idtipapl='" + aux_idtipapl + "'" +
                                          " vlaplica='" + TRIM(STRING(aux_vlaplica,"zzz,zzz,zz9.99-")) + "'" +
                                          " qtdiacar='" + TRIM(STRING(aux_qtdiacar)) + "'" +    
                                          " dtvencto='" + aux_dtvencto + "'" +
                                          " vlresgat='" + TRIM(STRING(aux_vlresgat,"zzz,zzz,zzz,zz9.99")) + "' " +
                                          " vlrendim='" + TRIM(STRING(aux_vlrendim,"zzz,zzz,zzz,zz9.99")) + "'" +
                                          " vldoirrf='" + TRIM(STRING(aux_vldoirrf,"zzz,zzz,zzz,zz9.99")) + "'" +
                                          " txacumul='" + TRIM(STRING(aux_txacumul,"zzz,zz9.999999")) + "'" +
                                          " txacumes='" + TRIM(STRING(aux_txacumes,"zzz,zz9.999999")) + "'" +
                                          " txaplica='" + TRIM(STRING(aux_txaplica,"zzz,zz9.99999999")) + "'" +
                                          " dsnomenc='" + aux_dsnomenc                        + "'" +
                                          " qtdiaapl='" + TRIM(STRING(aux_qtdiaapl)) + "'" +
                                          " idtxfixa='" + TRIM(STRING(aux_idtxfixa)) + "'" +
                                          " nmdindex='" + aux_nmdindex + "' " +
                                          " percirrf='" + STRING(aux_percirrf) + "' " +
                                          " tpaplica='" + STRING(aux_tpaplica) + "' >".


FOR EACH tt-extr-rdca NO-LOCK:

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<APLICACAO>" +
                                       "<dtmvtolt>" + STRING(tt-extr-rdca.dtmvtolt,"99/99/9999") + "</dtmvtolt>" +
                                       "<dshistor>" + TRIM(STRING(tt-extr-rdca.dsextrat)) + "</dshistor>" +
                                       "<nrdocmto>" + (IF  tt-extr-rdca.nrdocmto = 0  THEN " " ELSE TRIM(STRING(tt-extr-rdca.nrdocmto,"zzz,zzz,zz9")) ) + "</nrdocmto>" +
                                       "<indebcre>" + TRIM(STRING(tt-extr-rdca.indebcre)) + "</indebcre>" +
                                       "<vllanmto>" + (IF  tt-extr-rdca.vllanmto = 0  THEN " " ELSE TRIM(STRING(tt-extr-rdca.vllanmto,"zzz,zzz,zz9.99-")) ) + "</vllanmto>" +
                                       "<vlsldapl>" + TRIM(STRING(tt-extr-rdca.vlsldapl,"zzz,zzz,zz9.99-")) + "</vlsldapl>" +
                                       "<txaplica>" + (IF  tt-extr-rdca.txaplica = 0  THEN " " ELSE TRIM(STRING(tt-extr-rdca.txaplica,"zz9.999999"))) + "</txaplica>" +
                                       "<sldresga>" + TRIM(STRING(aux_sldresga,"zzz,zzz,zzz,zz9.99-")) + "</sldresga>" +
                                       "<dsaplica>" + TRIM(STRING(tt-extr-rdca.dsaplica),"zzz,zz9") + "</dsaplica>" +
                                       "<vlblqjud>" + TRIM(STRING(aux_vlblqjud,"zzz,zzz,zzz,zz9.99")) + "</vlblqjud>" +
                                   "</APLICACAO>".
END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = "</APLICACOES>".

/*............................................................................*/
