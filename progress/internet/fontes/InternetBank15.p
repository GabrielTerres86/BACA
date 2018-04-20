/*..............................................................................

   Programa: siscaixa/web/InternetBank15.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Julho/2007.                       Ultima atualizacao: 29/11/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Buscar aplicacoes RDCA e RDC para Internet.
   
   Alteracoes: 09/10/2007 - Gerar log com data TODAY e nao dtmvtolt (David).

               14/02/2008 - Nao retornar critica se associado nao possuir 
                            aplicacoes e retornar criticas da tt-erro (David) 
                          - Utilizar include de temp-tables (David)
                          
               03/11/2008 - Inclusao widget-pool (martin)         
               
               21/12/2010 - Retornar carencia da aplicacao no xml (David).  
   
               09/08/2013 - Incluir procedure retorna-valor-blqjud e tag xml
                            <vlblqjud> (Lucas R.).
                            
               26/05/2014 - Ajuste referente ao projeto de captação:
                            - Incluido a tag "podecanc" para indentificar as 
                            aplicações realizadas no dia corrente onde,
                            possam ser canceladas caso seja necessario.
                            (Adriano)             
                            
               25/07/2014 - Ajuste para constar no xml o saldo total para 
                            resgate atualizado (Adriano).             
                            
               11/08/2014 - Adicionar o tipo de aplicação no retorno do xml.
                            (Douglas - Projeto Captação Internet 2014/2)
                            
               20/08/2014 - Ajuste para buscar o horario limite de inicio/fim
                            para acesso as operaracoes de aplicacao
                            (Adriano).                            

               28/08/2014 - Ajuste para verificar se a aplicação possui bloqueio
                            de resgate (Douglas - Projeto Captação Internet 2014/2)
               
               01/09/2014 - Ajuste para listagem de novas e antigas aplicacoes,
                            Proj. Captacao (Jean Michel)
                                       
               24/09/2014 - Ajustar o totalizador do saldo disponivel para resgate.
                            Adicionar validação para definir aplicacao que pode ser 
                            resgatada.
                            (Douglas - Projeto Captação Internet 2014/2)
                            
               30/12/2014 - Correção da listagem de aplicações do cooperado, para 
                            serem listadas ambas aplicações de novos e 
                            antigos produtos de captacao. Assim como a correção 
                            da mascara do campo tt-saldo-rdca.tpaplica para o 
                            retorno correto da tela extrato_aplicacao.php.
                            (Carlos Rafael - Projeto Novos Produtos de Captação)
                            
               05/02/2015 - Inclusao do campo idtipapl na tt-saldo-rdca e ajuste
                            na leitura do XML (Jean Michel).
	           
			   05/02/2015 - Inclusao do campo dtcarenc na tt-saldo-rdca e ajuste
                            na leitura do XML SD 266191 (Kelvin).
	           
			   17/12/2015 - Ajuste na regra para liberar cancelamento de aplicação
                            (Dionathan).
                            
               29/11/2017 - Inclusao do valor de bloqueio em garantia. 
                            PRJ404 - Garantia.(Odirlei-AMcom)             
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0004 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0155 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0148 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0081 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0112 AS HANDLE                                         NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR aux_vlblqjud AS DECI                                           NO-UNDO.
DEF VAR aux_vlresblq AS DECI                                           NO-UNDO.
DEF VAR aux_vlsldtot AS DECI                                           NO-UNDO.
DEF VAR aux_vlsldisp AS DECI                                           NO-UNDO.
DEF VAR aux_vlsldblq AS DECI                                           NO-UNDO.
DEF VAR aux_vlsldnew AS DECI                                           NO-UNDO.
DEF VAR aux_hrlimini AS INT                                            NO-UNDO.
DEF VAR aux_hrlimfim AS INT                                            NO-UNDO.
DEF VAR aux_flgstapl AS LOGI                                           NO-UNDO.
DEF VAR aux_rsgtdisp AS LOGI                                           NO-UNDO.
DEF VAR aux_vlblqapl_gar  AS DECI                                      NO-UNDO.
DEF VAR aux_vlblqpou_gar  AS DECI                                      NO-UNDO.

/*DEF VAR aux_intipapl AS CHAR										   NO-UNDO.*/

/* Variaveis para o XML */ 
DEF VAR xDoc          AS HANDLE   NO-UNDO.   
DEF VAR xDoc2          AS HANDLE   NO-UNDO.  

DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                     NO-UNDO.
DEF INPUT PARAM par_cdagenci LIKE crapage.cdagenci                     NO-UNDO.
DEF INPUT PARAM par_nrdcaixa AS INT                                    NO-UNDO.
DEF INPUT PARAM par_cdoperad LIKE crapope.cdoperad                     NO-UNDO.
DEF INPUT PARAM par_idorigem AS INT                                    NO-UNDO.
DEF INPUT PARAM par_nmdatela AS CHAR                                   NO-UNDO.
DEF INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                     NO-UNDO.
DEF INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                     NO-UNDO.
DEF INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                     NO-UNDO.
DEF INPUT PARAM par_intipapl AS INT                                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_vldsaldo AS DECI               NO-UNDO.
DEF VAR aux_vlsldapl AS DECIMAL DECIMALS 8 NO-UNDO.
DEF VAR aux_vlsldrgt AS DECI               NO-UNDO.
    
DEF VAR xRoot         AS HANDLE   NO-UNDO.  
DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
DEF VAR xField        AS HANDLE   NO-UNDO. 
DEF VAR xText         AS HANDLE   NO-UNDO. 
DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
DEF VAR xml_req       AS LONGCHAR NO-UNDO.

    ASSIGN aux_dstransa = "Leitura de aplicacoes RDCA e RDC para Internet.".
    
    ASSIGN aux_vlblqjud = 0
           aux_vlresblq = 0
           aux_vlsldtot = 0
           aux_vlsldisp = 0
           aux_vlsldblq = 0
           aux_vlsldnew = 0
           aux_vlblqapl_gar = 0
           aux_vlblqpou_gar = 0.
    
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

    IF VALID-HANDLE(h-b1wgen0155) THEN
      DELETE PROCEDURE h-b1wgen0155.
    
    
    /*** Busca Saldo Bloqueado Garantia ***/
    IF  NOT VALID-HANDLE(h-b1wgen0112) THEN
        RUN sistema/generico/procedures/b1wgen0112.p 
            PERSISTENT SET h-b1wgen0112.

    RUN calcula_bloq_garantia IN h-b1wgen0112
                             ( INPUT par_cdcooper,
                               INPUT par_nrdconta,                                             
                              OUTPUT aux_vlblqapl_gar,
                              OUTPUT aux_vlblqpou_gar,
                              OUTPUT aux_dscritic).

    IF aux_dscritic <> "" THEN
    DO:
       ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".          
       RETURN "NOK".

    END.
        
    IF  VALID-HANDLE(h-b1wgen0112) THEN
        DELETE PROCEDURE h-b1wgen0112.    
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
    
    RUN STORED-PROCEDURE pc_horario_limite
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT par_cdoperad,
                                 INPUT par_nmdatela,
                                 INPUT par_idorigem,
                                 INPUT 2, /*Busca horario limite*/
                                 OUTPUT 0,
                                 OUTPUT 0,
                                 OUTPUT 0,
                                 OUTPUT 0,
                                 OUTPUT "").
    
    CLOSE STORED-PROC pc_horario_limite 
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_hrlimini = pc_horario_limite.pr_hrlimini
                              WHEN pc_horario_limite.pr_hrlimini <> ?
           aux_hrlimfim = pc_horario_limite.pr_hrlimfim
                              WHEN pc_horario_limite.pr_hrlimfim <> ?
           aux_cdcritic = pc_horario_limite.pr_cdcritic 
                              WHEN pc_horario_limite.pr_cdcritic <> ?
           aux_dscritic = pc_horario_limite.pr_dscritic
                              WHEN pc_horario_limite.pr_dscritic <> ?. 

    IF aux_cdcritic <> 0   OR
       aux_dscritic <> ""  THEN
       DO:
          IF aux_dscritic = "" THEN
             DO:
                FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                                   NO-LOCK NO-ERROR.
                
                IF AVAIL crapcri THEN
                   ASSIGN aux_dscritic = crapcri.dscritic.
                ELSE
                   ASSIGN aux_dscritic =  "Nao foi possivel validar o horario " +
                                          "limite.".
    
             END.
    
          ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                                "</dsmsgerr>".  
    
          RETURN "NOK".
    
       END.
    
    CREATE xml_operacao.
    
    ASSIGN xml_operacao.dslinxml = "<HORARIO>" + 
                                        "<hrlimini>" +  
                                               TRIM(STRING(aux_hrlimini,"HH:MM")) +
                                        "</hrlimini>" + 
                                        "<hrlimfim>" +  
                                               TRIM(STRING(aux_hrlimfim,"HH:MM")) +
                                        "</hrlimfim>" +
                                   "</HORARIO>".
    
    /********NOVA CONSULTA APLICACOOES*********/
    /** Saldo das aplicacoes **/
    
    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-DOCUMENT xDoc2.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
    
    /* Efetuar a chamada a rotina Oracle */ 
    RUN STORED-PROCEDURE pc_lista_aplicacoes_car
       aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,     /* Código da Cooperativa */
                                            INPUT "996",            /* Código do Operador */
                                            INPUT "InternetBank",   /* Nome da Tela */
                                            INPUT 3,                /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                            INPUT 900,              /* Numero do Caixa */
                                            INPUT par_nrdconta,     /* Número da Conta */
                                            INPUT 1,                /* Titular da Conta */
                                            INPUT 90,               /* Codigo da Agencia */
                                            INPUT "InternetBank",   /* Codigo do Programa */
                                            INPUT 0,                /* Número da Aplicação - Parâmetro Opcional */
                                            INPUT 0,                /* Código do Produto – Parâmetro Opcional */ 
                                            INPUT crapdat.dtmvtolt, /* Data de Movimento */
                                            INPUT 0,                /* Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas) */
                                            INPUT 1,                /* Identificador de Log (0 – Não / 1 – Sim) */ 																 
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
    

    /*Leitura do XML de retorno da proc e criacao dos registros na tt-saldo-rdca
    para visualizacao dos registros na tela */
    

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
                
                ASSIGN tt-saldo-rdca.nraplica = INT (xText:NODE-VALUE) WHEN xField:NAME = "nraplica".
                ASSIGN tt-saldo-rdca.qtdiauti = INT (xText:NODE-VALUE) WHEN xField:NAME = "qtdiauti".
                ASSIGN tt-saldo-rdca.nrdocmto = TRIM(xText:NODE-VALUE) WHEN xField:NAME = "nrdocmto".
                ASSIGN tt-saldo-rdca.indebcre =      xText:NODE-VALUE  WHEN xField:NAME = "indebcre".
                ASSIGN tt-saldo-rdca.vlaplica = DEC (xText:NODE-VALUE) WHEN xField:NAME = "vlaplica".
                ASSIGN tt-saldo-rdca.vllanmto = DEC (xText:NODE-VALUE) WHEN xField:NAME = "vllanmto".
                ASSIGN tt-saldo-rdca.sldresga = DEC (xText:NODE-VALUE) WHEN xField:NAME = "sldresga".
                ASSIGN tt-saldo-rdca.cddresga =      xText:NODE-VALUE  WHEN xField:NAME = "cddresga".
                ASSIGN tt-saldo-rdca.txaplmax =      xText:NODE-VALUE  WHEN xField:NAME = "txaplmax".
                ASSIGN tt-saldo-rdca.txaplmin =      xText:NODE-VALUE  WHEN xField:NAME = "txaplmin".
                ASSIGN tt-saldo-rdca.dshistor =      xText:NODE-VALUE  WHEN xField:NAME = "dshistor".
                ASSIGN tt-saldo-rdca.dssitapl =      xText:NODE-VALUE  WHEN xField:NAME = "dssitapl".
                ASSIGN tt-saldo-rdca.dtmvtolt = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtmvtolt".
                ASSIGN tt-saldo-rdca.dtvencto = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtvencto".
                ASSIGN tt-saldo-rdca.dtresgat = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtresgat".
                ASSIGN tt-saldo-rdca.tpaplica = INT (xText:NODE-VALUE) WHEN xField:NAME = "tpaplica".
                ASSIGN tt-saldo-rdca.idtipapl =      xText:NODE-VALUE  WHEN xField:NAME = "idtipapl".  
                ASSIGN tt-saldo-rdca.qtdiacar = INT (xText:NODE-VALUE) WHEN xField:NAME = "qtdiacar".  
                ASSIGN tt-saldo-rdca.dtcarenc = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtcarenc".  
            END. 
            
        END.
        
        SET-SIZE(ponteiro_xml) = 0.
    END.
    
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.
            
    /*******FIM CONSULTA APLICACAOES**********/
    
    VALIDATE tt-saldo-rdca.
    
    IF NOT VALID-HANDLE(h-b1wgen0148) THEN
      RUN sistema/generico/procedures/b1wgen0148.p 
          PERSISTENT SET h-b1wgen0148.
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<DADOS>".
    
    FOR EACH tt-saldo-rdca NO-LOCK:
      
      ASSIGN aux_vlsldtot = aux_vlsldtot + tt-saldo-rdca.sldresga
             aux_flgstapl = FALSE
			 aux_rsgtdisp = TRUE.

      IF tt-saldo-rdca.tpaplica <> 0 THEN
          DO:
              /* Para cada aplicação, validar se ela possui bloqueio de resgate */
              RUN busca-blqrgt IN h-b1wgen0148 (INPUT par_cdcooper,
                                                INPUT 90, /* cdagenci */
                                                INPUT 900, /* nrdcaixa */
                                                INPUT "996", /* cdoperad */
                                                INPUT par_nrdconta,
                                                INPUT tt-saldo-rdca.tpaplica,
                                                INPUT tt-saldo-rdca.nraplica,
                                                INPUT par_dtmvtolt,
        										INPUT tt-saldo-rdca.idtipapl, /*aux_intipapl*/
                                               OUTPUT aux_flgstapl,
                                               OUTPUT TABLE tt-erro).
        
              IF  RETURN-VALUE = "NOK"  THEN
                  DO:
                    
                      /* Se ocorrer erro, fechar a tag de DADOS */
                      CREATE xml_operacao.
                      ASSIGN xml_operacao.dslinxml = "</DADOS>".
                          
                      /* Deletar a BO*/
                      DELETE PROCEDURE h-b1wgen0148.
                      
                      FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
                      IF AVAILABLE tt-erro  THEN
                         ASSIGN aux_dscritic = tt-erro.dscritic.
                      ELSE
                         ASSIGN aux_dscritic = "Nao foi possivel consultar aplicacoes.".
        
                      ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        
                      RUN proc_geracao_log (INPUT FALSE).
        
                      RETURN "NOK".
                  END.
          END.

          /* Verificacao: 
               - Aplicação possui BLQRGT 
               - Data do sistema é igual a data da aplicação
             NÃO PERMITIR O RESGATE DA APLICAÇÃO
          */
          IF NOT aux_flgstapl OR par_dtmvtolt = tt-saldo-rdca.dtmvtolt THEN
              ASSIGN aux_rsgtdisp = FALSE.
          ELSE 
              /* Se a aplicação pode ser resgatada, totalizamos o valor disponivel */
              ASSIGN aux_vlsldisp = aux_vlsldisp + tt-saldo-rdca.sldresga.

          /* Totalizar o valor BLQRGT */
          IF NOT aux_flgstapl THEN
              ASSIGN aux_vlsldblq = aux_vlsldblq + tt-saldo-rdca.sldresga.

          /* Totalizar o valor de aplicações novas */
          IF par_dtmvtolt = tt-saldo-rdca.dtmvtolt THEN
              ASSIGN aux_vlsldnew = aux_vlsldnew + tt-saldo-rdca.sldresga.

          /* Totalizar o saldo de todas as aplicações */
         /* ASSIGN aux_vlsldtot = aux_vlsldtot + tt-saldo-rdca.sldresga.*/
         
      CREATE xml_operacao.
      
      ASSIGN xml_operacao.dslinxml = "<APLICACAO>" + 
               "<dtmvtolt>" + 
                   STRING(tt-saldo-rdca.dtmvtolt,"99/99/9999") +
               "</dtmvtolt>" + 
               "<dshistor>" +
                   tt-saldo-rdca.dshistor +
               "</dshistor>" + 
               "<nrdocmto>" +
                   tt-saldo-rdca.nrdocmto +
               "</nrdocmto>" + 
               "<dtvencto>" +
                   (IF tt-saldo-rdca.dtvencto = ? THEN
                       ""
                    ELSE
                       STRING(tt-saldo-rdca.dtvencto,"99/99/9999")) +
               "</dtvencto>" + 
               "<indebcre>" +
                   tt-saldo-rdca.indebcre +
               "</indebcre>" + 
               "<vllanmto>" +
                   TRIM(STRING(tt-saldo-rdca.vllanmto,"zzz,zzz,zz9.99-")) +
               "</vllanmto>" + 
               "<sldresga>" +
                   TRIM(STRING(tt-saldo-rdca.sldresga,"zzz,zzz,zz9.99-")) +
               "</sldresga>" + 
               "<nraplica>" +
                   TRIM(STRING(tt-saldo-rdca.nraplica)) +
               "</nraplica>" + 
               "<qtdiacar>" +
                   TRIM(STRING(tt-saldo-rdca.qtdiacar)) +
               "</qtdiacar>" + 
               "<vlblqjud>" +
                   TRIM(STRING(aux_vlblqjud,
                               "zzz,zzz,zzz,zz9.99")) +
               "</vlblqjud>"+
               (IF par_dtmvtolt = tt-saldo-rdca.dtmvtolt AND  /* Aplicação criada no dia */
                   tt-saldo-rdca.idtipapl = 'A'          AND  /* Produto Antigo          */
                   aux_flgstapl = TRUE                   THEN /* Disponível para resgate */
                   "<podecanc>1</podecanc>"
                ELSE
                   "<podecanc>0</podecanc>") +
               "<vlaplica>" +
                TRIM(STRING(tt-saldo-rdca.vlaplica,"zzz,zzz,zzz,zz9.99")) +
               "</vlaplica>" + 
               "<qtdiauti>" + 
               STRING(qtdiauti) +
               "</qtdiauti>" +
                "<tpaplica>" +
                   TRIM(STRING(tt-saldo-rdca.tpaplica,"zzz9")) +
               "</tpaplica>" + 
                "<idtipapl>" +
                   TRIM(tt-saldo-rdca.idtipapl) +
               "</idtipapl>" +  
               (IF aux_flgstapl THEN
                  "<apli_liberada>1</apli_liberada>"
               ELSE
                  "<apli_liberada>0</apli_liberada>") + 
                   (IF aux_rsgtdisp                 AND  /* Disponível para resgate */
                       tt-saldo-rdca.tpaplica = 8   AND  /* Aplicação RDCPOS        */
                       tt-saldo-rdca.idtipapl = 'A' THEN /* Produto Antigo          */
                      "<apli_disp_resg>1</apli_disp_resg>"
                   ELSE
                      "<apli_disp_resg>0</apli_disp_resg>") +
               "<dtcarenc>" + 
                   STRING(tt-saldo-rdca.dtcarenc,"99/99/9999") +
               "</dtcarenc>" + 
               "</APLICACAO>".
                   
    END.
    
    IF VALID-HANDLE(h-b1wgen0148) THEN
       DELETE PROCEDURE h-b1wgen0148.

    CREATE xml_operacao.
    
    ASSIGN xml_operacao.dslinxml = "</DADOS>".
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<SALDODISPONIVEL>" + 
                                      "<vlsldtot>" +  
                                             TRIM(STRING(aux_vlsldtot,"zzz,zzz,zz9.99-")) +
                                      "</vlsldtot>" + 
                                 "</SALDODISPONIVEL>".

      CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = "<SALDORESGATE>" + 
                                          "<vlsldisp>" +  
                                                 TRIM(STRING(aux_vlsldisp,"zzz,zzz,zz9.99-")) +
                                          "</vlsldisp>" + 
                                     "</SALDORESGATE>".
      
      CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = "<SALDOBLOQUEADO>" + 
                                          "<vlsldblq>" +  
                                                 TRIM(STRING(aux_vlsldblq,"zzz,zzz,zz9.99-")) +
                                          "</vlsldblq>" + 
                                     "</SALDOBLOQUEADO>".

      CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = "<SALDOAPLINOVA>" + 
                                          "<vlsldnew>" +  
                                                 TRIM(STRING(aux_vlsldnew,"zzz,zzz,zz9.99-")) +
                                          "</vlsldnew>" + 
                                     "</SALDOAPLINOVA>".
      
      CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = "<SALDOBLOQ_GARANTIA>" + 
                                          "<vlblqapl_gar>" +
                                           TRIM(STRING(aux_vlblqapl_gar,
                                                       "zzz,zzz,zzz,zz9.99")) +
                                          "</vlblqapl_gar>"+
                                          "<vlblqpou_gar>" +
                                           TRIM(STRING(aux_vlblqpou_gar,
                                                       "zzz,zzz,zzz,zz9.99")) +
                                          "</vlblqpou_gar>"+      
                                     "</SALDOBLOQ_GARANTIA>".
                                     
    RUN proc_geracao_log (INPUT TRUE). 
       
    RETURN "OK".

/*................................ PROCEDURES ................................*/

PROCEDURE proc_geracao_log:

    DEF INPUT PARAM par_flgtrans AS LOGICAL                         NO-UNDO.
    
    RUN sistema/generico/procedures/b1wgen0014.p PERSISTENT 
        SET h-b1wgen0014.
        
    IF  VALID-HANDLE(h-b1wgen0014)  THEN
        DO:
            RUN gera_log IN h-b1wgen0014 (INPUT par_cdcooper,
                                          INPUT "996",
                                          INPUT aux_dscritic,
                                          INPUT "INTERNET",
                                          INPUT aux_dstransa,
                                          INPUT TODAY,
                                          INPUT par_flgtrans,
                                          INPUT TIME,
                                          INPUT par_idseqttl,
                                          INPUT "INTERNETBANK",
                                          INPUT par_nrdconta,
                                          OUTPUT aux_nrdrowid).
                                           
            DELETE PROCEDURE h-b1wgen0014.
        END.
    
END PROCEDURE.

/*............................................................................*/


