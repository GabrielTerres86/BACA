/*..............................................................................

   Programa: siscaixa/web/InternetBank95.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Douglas
   Data    : Agosto/2014.                       Ultima atualizacao: 25/09/2014

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Buscar aplicacoes RDCA e RDC para Internet, juntamente com as 
               informacoes de aliquota e Imposto de Renda.
   
   Alteracoes: 24/09/2014 - Ajustado a busca das informações da aplicação.
                           (Douglas - Projeto Captação Internet 2014/2)

               25/09/2014 - Ajuste no calculo do imposto de renda e valor base
                            da aplicacao, conforme calculo no crps495.
                           (Douglas - Projeto Captação Internet 2014/2)

..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/var_internet.i }

DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                     NO-UNDO.
DEF INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                     NO-UNDO.
DEF INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                     NO-UNDO.
DEF INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                     NO-UNDO.
DEF INPUT PARAM par_dsaplica AS CHAR                                   NO-UNDO. /* Aplicações selecionadas */
DEF INPUT PARAM par_vlresgat AS CHAR                                   NO-UNDO. /* Valor das aplicações */

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0004 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0155 AS HANDLE                                         NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

/* Variaveis para saldo bloqueado judicialmente */
DEF VAR aux_vlblqjud AS DECI                                           NO-UNDO.
DEF VAR aux_vlresblq AS DECI                                           NO-UNDO.
DEF VAR aux_vlsldtot AS DECI                                           NO-UNDO.

/* Variaveis de Valor de resgate */
DEF VAR aux_vlsddrgt AS DECI                                           NO-UNDO.
DEF VAR aux_vlrenrgt AS DECI                                           NO-UNDO.
DEF VAR aux_vlrdirrf AS DECI                                           NO-UNDO.
DEF VAR aux_perirrgt AS DECI                                           NO-UNDO.
DEF VAR aux_vlrgttot AS DECI                                           NO-UNDO.
DEF VAR aux_vlirftot AS DECI                                           NO-UNDO.
DEF VAR aux_vlrendmm AS DECI                                           NO-UNDO.
DEF VAR aux_vlrvtfim AS DECI                                           NO-UNDO.
DEF VAR aux_vlsolrgt LIKE craplap.vllanmto                             NO-UNDO.
DEF VAR aux_vlbasrgt LIKE craplap.vllanmto                             NO-UNDO.
DEF VAR aux_sldpresg LIKE craplap.vllanmto                             NO-UNDO.

/* Aplicacoes por parametro */
DEF VAR aux_qtaplica AS INTE                                           NO-UNDO. /* Quantidade de aplicacoes por parametro */
DEF VAR aux_nraplica AS INTE                                           NO-UNDO. /* numero da aplicação */
DEF VAR aux_vlresgat AS DECI                                           NO-UNDO. /* Valor de resgate (recuperado do parametro)*/
DEF VAR aux_tpresgat AS INTE                                           NO-UNDO. 

/* Contadores */
DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_indice   AS INTE                                           NO-UNDO.


ASSIGN aux_dstransa = "Leitura do Resumo do Resgate de Aplicacao".

ASSIGN aux_vlblqjud = 0
       aux_vlresblq = 0
       aux_vlsldtot = 0
       aux_vlbasrgt = 0.


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


RUN sistema/generico/procedures/b1wgen0004.p PERSISTENT 
    SET h-b1wgen0004.
                
IF VALID-HANDLE(h-b1wgen0004)  THEN
DO: 
    /* Buscar as informacoes das aplicacoes da conta */
    RUN consulta-aplicacoes IN h-b1wgen0004 (INPUT par_cdcooper,
                                             INPUT 90,
                                             INPUT 900,
                                             INPUT "996",
                                             INPUT par_nrdconta,
                                             INPUT 0,
                                             INPUT 0, 
                                             INPUT ?,
                                             INPUT ?,
                                             INPUT "InternetBank",
                                             INPUT 3,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT TABLE tt-saldo-rdca).

    IF RETURN-VALUE = "NOK"  THEN
    DO:
        DELETE PROCEDURE h-b1wgen0004.
        
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
        IF AVAILABLE tt-erro  THEN
            ASSIGN aux_dscritic = tt-erro.dscritic.
        ELSE
            ASSIGN aux_dscritic = "Nao foi possivel consultar aplicacoes.".
             
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
           
        RUN proc_geracao_log (INPUT FALSE).
         
        RETURN "NOK".
    END.


    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<DADOS>".


    /* Quantidade de aplicacoes */
    ASSIGN aux_qtaplica = NUM-ENTRIES(par_dsaplica,"|").

    FOR EACH tt-saldo-rdca NO-LOCK:
        ASSIGN aux_indice = 0.
        /* Percorrer todas as aplicacoes para verificar o numero da aplicacao */
        DO aux_contador = 1 TO aux_qtaplica:
            IF INTE(ENTRY(aux_contador,par_dsaplica,"|")) = INTE(tt-saldo-rdca.nraplica) THEN
                ASSIGN aux_indice = aux_contador.
        END.

        IF aux_indice <> 0 THEN
        DO:
            
            ASSIGN aux_vlresgat = DECI(ENTRY(aux_indice,par_vlresgat,"|")).

            /* Calcula o valor atualizado das aplicacoes para verificacao do valor que será resgatado
               Nessa primeira chamada será calculado sem informar o valor de resgate  */
            RUN saldo_rgt_rdc_pos IN h-b1wgen0004 (INPUT par_cdcooper, 
                                                   INPUT par_nrdconta, 
                                                   INPUT tt-saldo-rdca.nraplica, 
                                                   INPUT par_dtmvtolt, 
                                                   INPUT par_dtmvtolt, 
                                                   INPUT 0,
                                                   INPUT FALSE, 
                                                  OUTPUT aux_vlsddrgt, /* Valor do resgate total sem IRRF*/
                                                  OUTPUT aux_vlrenrgt, /* Rendimento Total */
                                                  OUTPUT aux_vlrdirrf, /* IRRF do valor solicitado */
                                                  OUTPUT aux_perirrgt, /* Percentual da aliquota*/
                                                  OUTPUT aux_vlrgttot, /* Valor para zerar a aplicacao */
                                                  OUTPUT aux_vlirftot, /* IRRF para finalizar a aplicacao */
                                                  OUTPUT aux_vlrendmm, /* rendimento da ultima provisao ate a data do resgate */
                                                  OUTPUT aux_vlrvtfim, /* quanta provisao reverter para zerar a aplicacao */
                                                  OUTPUT TABLE tt-erro).

            IF RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                IF AVAILABLE tt-erro  THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.
                ELSE
                    ASSIGN aux_dscritic = "Nao foi possivel consultar aplicacoes.".
    
                ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
    
                DELETE xml_operacao.

                RUN proc_geracao_log (INPUT FALSE).
    
                RETURN "NOK".
            END.

            
            /* Verificar se existe valor para resgate*/
            IF  aux_vlresgat = aux_vlrgttot  THEN
                /* Valor solicitado para resgate = VALOR TOTAL */
                ASSIGN aux_vlsolrgt = aux_vlrgttot
                       aux_tpresgat = 2.
            ELSE
                /* Valor solicitado para resgate = VALOR RESGATAR */
                ASSIGN aux_vlsolrgt = aux_vlresgat
                       aux_tpresgat = 1.


            /*** Calcular o valor real a ser resgatado quando nao esta na carencia ***/
            IF   par_dtmvtolt - tt-saldo-rdca.dtmvtolt < tt-saldo-rdca.qtdiauti THEN
                ASSIGN aux_vlbasrgt = aux_vlresgat.
            ELSE 
                DO:     
                    RUN valor_original_resgatado IN h-b1wgen0004 (INPUT par_cdcooper,
                                                                  INPUT par_nrdconta,
                                                                  INPUT tt-saldo-rdca.nraplica,
                                                                  INPUT par_dtmvtolt,
                                                                  INPUT aux_vlsolrgt,
                                                                  INPUT aux_perirrgt,
                                                                 OUTPUT aux_vlbasrgt,
                                                                 OUTPUT TABLE tt-erro).
                    IF   RETURN-VALUE = "NOK"  THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                            IF AVAILABLE tt-erro  THEN
                                ASSIGN aux_dscritic = tt-erro.dscritic.
                            ELSE
                                ASSIGN aux_dscritic = "Nao foi possivel consultar aplicacoes.".
    
                            ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
                            
                            DELETE xml_operacao.
    
                            RUN proc_geracao_log (INPUT FALSE).
   
                            RETURN "NOK".
                    END.
                END.        

            /* Calcular as informacoes de imposto de renda com o valor base para resgate */
            RUN saldo_rgt_rdc_pos IN h-b1wgen0004 (INPUT par_cdcooper,
                                                   INPUT par_nrdconta,
                                                   INPUT tt-saldo-rdca.nraplica,
                                                   INPUT par_dtmvtolt,
                                                   INPUT par_dtmvtolt,
                                                   INPUT aux_vlbasrgt,
                                                   INPUT FALSE,
                                                  OUTPUT aux_sldpresg,  /* Valor do resgate total sem IRRF*/                      
                                                  OUTPUT aux_vlrenrgt,  /* Rendimento Total */                                    
                                                  OUTPUT aux_vlrdirrf,  /* IRRF do valor solicitado */                            
                                                  OUTPUT aux_perirrgt,  /* Percentual da aliquota*/                               
                                                  OUTPUT aux_vlrgttot,  /* Valor para zerar a aplicacao */                        
                                                  OUTPUT aux_vlirftot,  /* IRRF para finalizar a aplicacao */                     
                                                  OUTPUT aux_vlrendmm,  /* rendimento da ultima provisao ate a data do resgate */ 
                                                  OUTPUT aux_vlrvtfim,  /* quanta provisao reverter para zerar a aplicacao */     
                                                  OUTPUT TABLE tt-erro).

            IF   RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                    IF AVAILABLE tt-erro  THEN
                        ASSIGN aux_dscritic = tt-erro.dscritic.
                    ELSE
                        ASSIGN aux_dscritic = "Nao foi possivel consultar aplicacoes.".
    
                    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
    
                    DELETE xml_operacao.
    
                    RUN proc_geracao_log (INPUT FALSE).
    
                    RETURN "NOK".
                END.

            /* Adicionar as informações da aplicacao */
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
                                                       " "
                                                    ELSE
                                                       STRING(tt-saldo-rdca.dtvencto,"99/99/9999")) +
                                               "</dtvencto>" + 
                                               "<indebcre>" +
                                                   tt-saldo-rdca.indebcre +
                                               "</indebcre>" + 
                                               "<vllanmto>" +
                                                   TRIM(STRING(aux_vlresgat,"zzz,zzz,zz9.99-")) +
                                               "</vllanmto>" + 
                                               "<sldresga>" +
                                                   TRIM(STRING(tt-saldo-rdca.sldresga,"zzz,zzz,zz9.99-")) +
                                               "</sldresga>" + 
                                               "<nraplica>" +
                                                   TRIM(STRING(tt-saldo-rdca.nraplica,"zzz,zz9")) +
                                               "</nraplica>" + 
                                               "<qtdiacar>" +
                                                   (IF tt-saldo-rdca.qtdiacar = 0 THEN
                                                       ""
                                                    ELSE
                                                       STRING(tt-saldo-rdca.qtdiacar)) +
                                               "</qtdiacar>" + 
                                               "<vlblqjud>" +
                                                   TRIM(STRING(aux_vlblqjud,"zzz,zzz,zzz,zz9.99")) +
                                               "</vlblqjud>"+
                                               "<tpaplica>" +
                                                   TRIM(STRING(tt-saldo-rdca.tpaplica,"9")) +
                                               "</tpaplica>" +
                                               "<vlresgat>"+
                                                   STRING(aux_vlresgat,"zzz,zzz,zzz,zz9.99") + /* Valor resgatado*/
                                               "</vlresgat>"+
                                               "<vlaliquota>"+
                                                   STRING(aux_perirrgt) + "%" + /* Aliquota */
                                               "</vlaliquota>"+
                                               "<vlimprenda>"+
                                                   STRING(aux_vlrdirrf,"zzz,zzz,zzz,zz9.99") + /* Valor Imposto de renda*/
                                               "</vlimprenda>"+ 
                                               "<vlrenrgt>"+
                                                   STRING(aux_vlrenrgt,"zzz,zzz,zzz,zz9.99") + /* Rendimento */
                                               "</vlrenrgt>"+ 
                                               "<vlaplica>"+
                                                   STRING(tt-saldo-rdca.vlaplica,"zzz,zzz,zzz,zz9.99") +
                                               "</vlaplica>"+ 
                                               "<dtcarencia>" +
                                                   STRING(tt-saldo-rdca.dtmvtolt + tt-saldo-rdca.qtdiacar,"99/99/9999") +
                                                   " (" + STRING(tt-saldo-rdca.qtdiacar) + " dias)" +
                                               "</dtcarencia>" + 
                                               /* Novo IB */
                                               "<dtresgat>" +
                                                   STRING(par_dtmvtolt,"99/99/9999") +
                                               "</dtresgat>" +  
                                               "<dtcarenc>" +
                                                   STRING(tt-saldo-rdca.dtmvtolt + tt-saldo-rdca.qtdiacar,"99/99/9999") +
                                               "</dtcarenc>" + 
                                               "<idtipapl>A</idtipapl>" +  /* Fixo, tratar futuramente */
                                               "<tpresgat>" +
                                                   TRIM(STRING(aux_tpresgat,"9")) +
                                               "</tpresgat>" +                                                                                             
                                           "</APLICACAO>".

        END.
    END.
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "</DADOS>".


    RUN proc_geracao_log (INPUT TRUE). 
       
    RETURN "OK".
END.


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
