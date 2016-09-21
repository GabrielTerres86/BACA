/*..............................................................................

   Programa: siscaixa/web/InternetBank126.p
   Sistema : Mobile - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Outubro/2014.                       Ultima atualizacao: 10/06/2015

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (Mobile)
   Objetivo  : Validar dados para liberação de dispositivo, CPF e letras
   
   Alteracoes: Ajuste de retorno (Guilherme).
   
               10/06/2015 - Ajustes para aceitar CNPJ (Dionathan)
                            
               28/07/2015 - Adição de parâmetro flmobile para indicar que a origem
                            da chamada é do mobile (Dionathan)
..............................................................................*/

/* Criacao do objeto de saida */
CREATE WIDGET-POOL. 

/* Include padrao para uso do InternetBank */
{ sistema/generico/includes/var_internet.i }

/* Parametros de entrada */
DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_nrcpfcgc LIKE crapttl.nrcpfcgc                    NO-UNDO.
DEF  INPUT PARAM par_dssenlet AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_cddsenha AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_vldshlet AS LOGICAL                               NO-UNDO.
DEF  INPUT PARAM par_inaceblq AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nripuser AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_dsorigip AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_flmobile AS LOGI                                  NO-UNDO.
/* Parametro de saida */     
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

/* Variaveis locais */
DEF VAR h-b1wnet0002 AS HANDLE                                         NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

/*Trecho de código comentado que faz a validação de cpf e letras e bloqueia a senha em caso de necessidade
DEF VAR aux_grpletr1 AS CHAR                                           NO-UNDO.
DEF VAR aux_grpletr2 AS CHAR                                           NO-UNDO.
DEF VAR aux_grpletr3 AS CHAR                                           NO-UNDO.
DEF VAR aux_flsenlet AS LOGICAL                                        NO-UNDO.
DEF VAR h-b1wgen0011 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0025 AS HANDLE                                         NO-UNDO.

DEF VAR aux_flgtrans AS LOGICAL                                        NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_qtacerro AS INTE                                           NO-UNDO.
DEF VAR aux_qttenper AS INTE                                           NO-UNDO.
DEF VAR aux_qttentat AS INTE                                           NO-UNDO.
DEF VAR aux_qtdiauso AS INTE                                           NO-UNDO. 
DEF VAR aux_qtdiaalt AS INTE                                           NO-UNDO. 
DEF VAR aux_qtdiablq AS INTE                                           NO-UNDO. 
DEF VAR aux_totdiabq AS INTE                                           NO-UNDO.
DEF VAR aux_dtaltsnh AS DATE                                           NO-UNDO. 
DEF VAR aux_conteudo AS CHAR                                           NO-UNDO.

ASSIGN aux_dscritic = ""
       aux_flgtrans = TRUE.
**********************************************************************************************************/

/* Caso não possuir as letras cadastradas, gera erro*/
IF  NOT CAN-FIND(FIRST crapsnh WHERE 
                       crapsnh.cdcooper = par_cdcooper  AND
                       crapsnh.nrdconta = par_nrdconta  AND
                       crapsnh.idseqttl = par_idseqttl  AND
                       crapsnh.tpdsenha = 3             NO-LOCK)  THEN
DO:

    ASSIGN aux_dscritic = "Necessario o cadastro das letras de seguranca. Procure um Posto de Atendimento.".
    RETURN "NOK".
END.
ELSE
DO:
    FOR FIRST crapass FIELDS (inpessoa nrcpfcgc) 
        WHERE crapass.cdcooper = par_cdcooper
          AND crapass.nrdconta = par_nrdconta NO-LOCK: END.

    IF  NOT AVAIL crapass  THEN
    DO:
        ASSIGN aux_dscritic = "Associado nao cadastrado."
               xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic  + "</dsmsgerr>".
            
        RETURN "NOK".
    END.

    IF crapass.inpessoa = 1  THEN /* PF */
    DO:
        IF  NOT CAN-FIND(FIRST crapttl WHERE 
                               crapttl.cdcooper = par_cdcooper AND
                               crapttl.nrdconta = par_nrdconta AND
                               crapttl.idseqttl = par_idseqttl AND
                               crapttl.nrcpfcgc = par_nrcpfcgc NO-LOCK)  THEN
        DO:
            ASSIGN aux_dscritic = "Dados informados nao conferem."
                   xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic  + "</dsmsgerr>".
                
            RETURN "NOK".
        END.
    END.
    ELSE /* PJ */
    DO:
        IF  crapass.nrcpfcgc <> par_nrcpfcgc  THEN
        DO:
            ASSIGN aux_dscritic = "Dados informados nao conferem."
                   xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic  + "</dsmsgerr>".
        
            RETURN "NOK".
        END.
    END.

    RUN sistema/internet/procedures/b1wnet0002.p PERSISTENT SET h-b1wnet0002.
            
    IF  NOT VALID-HANDLE(h-b1wnet0002)  THEN
        DO:
            ASSIGN aux_dscritic = "Handle invalido para BO b1wnet0002."
                   xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic  + "</dsmsgerr>".
            
            RETURN "NOK".
        END.
    
    RUN valida-senha IN h-b1wnet0002 (INPUT par_cdcooper,
                                      INPUT 90,             /** PAC      **/
                                      INPUT 900,            /** Caixa    **/
                                      INPUT "996",          /** Operador **/
                                      INPUT "INTERNETBANK", /** Tela     **/
                                      INPUT 3,              /** Origem   **/
                                      INPUT par_nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT 0,
                                      INPUT par_cddsenha,
                                      INPUT "",
                                      INPUT par_dssenlet,
                                      INPUT par_vldshlet,
                                      INPUT 0,
                                      INPUT par_inaceblq,
                                      INPUT par_nripuser,
                                      INPUT par_dsorigip,
                                      INPUT TRUE,          /** Logar    **/
                                      INPUT par_flmobile,
                                     OUTPUT TABLE tt-erro).
                                  
    DELETE PROCEDURE h-b1wnet0002.

    IF  RETURN-VALUE = "NOK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR. 
                    
        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE           
            aux_dscritic = "Nao foi possivel validar a senha.".
                   
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
                                                       
        RETURN "NOK".
    END.
    /* Executa validações de senha na b1wgen0002 */
END.


/* Trecho de código comentado que faz a validação de cpf e letras e bloqueia a senha em caso de necessidade 
ELSE
/* Caso possuir senha cadastrada e for solicitado validação de letras e cpf */
IF  par_vldshlet  THEN
DO:
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
                             
    IF  NOT AVAILABLE crapcop  THEN
        ASSIGN aux_dscritic = "651 - Falta registro de controle da " + 
                              "cooperativa - ERRO DE SISTEMA". 

    FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapdat  THEN
        ASSIGN aux_dscritic = "001 - Sistema sem data de movimento.".

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
                             
    IF  NOT AVAILABLE crapass  THEN
        ASSIGN aux_dscritic = "009 - Associado nao cadastrado.".

    IF  aux_dscritic = ""  THEN
    DO:
        ASSIGN aux_flgtrans = FALSE.

        TRANSACAO:
        
        DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
        
            DO aux_contador = 1 TO 10:
        
                ASSIGN aux_dscritic = "".
                   
                FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                                   crapsnh.nrdconta = par_nrdconta AND
                                   crapsnh.idseqttl = par_idseqttl AND
                                   crapsnh.tpdsenha = 1            AND
                                   crapsnh.cdsitsnh = 1
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                IF  NOT AVAILABLE crapsnh  THEN
                    DO:
                        IF  LOCKED crapsnh  THEN
                            DO:
                                aux_dscritic = "Registro de senha esta " +
                                               "sendo alterado. Tente " +
                                               "novamente.".
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                        ELSE
                            aux_dscritic = "Registro de senha nao " +
                                           "cadastrado ou bloqueado.".
                    END.
                
                LEAVE.
                
            END. /** Fim do DO ... TO **/
        
            IF  aux_dscritic <> ""  THEN
                UNDO TRANSACAO, LEAVE TRANSACAO.
    
            /* Validação de letras de segurança */
            ASSIGN aux_grpletr1 = ENTRY(1,par_dssenlet,".")
                   aux_grpletr2 = ENTRY(2,par_dssenlet,".")
                   aux_grpletr3 = ENTRY(3,par_dssenlet,".")
                   aux_flsenlet = FALSE.

            RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT
                SET h-b1wgen0025.

            IF  VALID-HANDLE(h-b1wgen0025)  THEN
            DO: 
                RUN valida_letras_seguranca IN h-b1wgen0025 
                                       (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_idseqttl,
                                        INPUT aux_grpletr1,
                                        INPUT aux_grpletr2,
                                        INPUT aux_grpletr3,
                                        INPUT FALSE,
                                       OUTPUT aux_flsenlet,
                                       OUTPUT aux_dscritic).

                DELETE PROCEDURE h-b1wgen0025.

                IF  RETURN-VALUE <> "OK"  THEN

                    ASSIGN aux_dscritic = "Dados informados não conferem".
                ELSE
                    IF  NOT aux_flsenlet  THEN
                        ASSIGN aux_dscritic = "Dados informados não conferem".
            END.

            /* Validação para bloquear a senha, caso for indicado via parametro */
            IF  aux_dscritic <> ""  THEN
                DO:
                    ASSIGN aux_qtacerro = 0.
        
                    IF  par_inaceblq = 1  THEN
                        DO: 
                            ASSIGN aux_qttentat = 0.
        
                            IF  crapass.inpessoa = 1  THEN
                                FIND craptab WHERE 
                                     craptab.cdcooper = par_cdcooper AND
                                     craptab.nmsistem = "CRED"       AND
                                     craptab.tptabela = "GENERI"     AND
                                     craptab.cdempres = 0            AND
                                     craptab.cdacesso = "LIMINTERNT" AND
                                     craptab.tpregist = 1            
                                     NO-LOCK NO-ERROR.
                            ELSE
                                FIND craptab WHERE 
                                     craptab.cdcooper = par_cdcooper AND
                                     craptab.nmsistem = "CRED"       AND
                                     craptab.tptabela = "GENERI"     AND
                                     craptab.cdempres = 0            AND
                                     craptab.cdacesso = "LIMINTERNT" AND
                                     craptab.tpregist = 2            
                                     NO-LOCK NO-ERROR.
        
                            IF  NOT AVAILABLE craptab                     OR 
                                INTE(SUBSTR(craptab.dstextab,11,2)) <= 0  THEN
                                DO:
                                    aux_dscritic = "Tabela de Limites para " +
                                                   "Internet nao cadastrada.".
        
                                    UNDO TRANSACAO, LEAVE TRANSACAO.
                                END.
                            ELSE
                                aux_qttenper = INT(SUBSTR(craptab.dstextab,11,2)).
        
                            ASSIGN crapsnh.qtacerro = crapsnh.qtacerro + 1
                                   aux_qtacerro     = crapsnh.qtacerro.
        
                            IF  crapsnh.qtacerro >= aux_qttenper  THEN
                                ASSIGN crapsnh.cdsitsnh = 2
                                       crapsnh.dtaltsit = aux_datdodia
                                       crapsnh.cdoperad = "996"
                                       aux_dscritic     = "Acesso " +
                                                          "Bloqueado.".
                            ELSE
                                ASSIGN aux_qttentat = aux_qttenper - 
                                                      crapsnh.qtacerro.
        
                            IF  aux_qttentat > 0  THEN    
                                aux_dscritic = aux_dscritic + "\n" +
                                              (IF  aux_qttentat > 1  THEN    
                                                   "Restam " +
                                                   STRING(aux_qttentat) + 
                                                   " tentativas "
                                               ELSE
                                                   "Resta " +
                                                   STRING(aux_qttentat) +  
                                                   " tentativa ") +
                                               "para acessar a Conta On-Line.\nEm" +
                                               " caso de erro em todas as " +
                                               " tentativas possiveis, sua senha" +
                                               " sera bloqueada.".
                        END. /* Fim par_inaceblq = 1 */
        
                    /************************************************************/
                    /** Enviar e-mail se for uma tentativa de acesso direto ao **/
                    /** programa ou se for da penultima tentativa em diante.   **/
                    /************************************************************/
                    IF  par_inaceblq = 0                     OR
                       (par_inaceblq = 1                     AND 
                       (aux_qttenper - aux_qtacerro) < 1)    THEN
                        DO:
                            ASSIGN aux_conteudo = 
                             '<font face="Arial, Helvetica, sans-serif" size="2">' +
                             'Tentativa de acesso a Conta Mobile com senha ' +
                             'incorreta.<br><br>' +
                             'Cooperativa: <strong>' + 
                             CAPS(crapcop.nmrescop) + '</strong><br>' +
                             'Conta: <strong>' + 
                             TRIM(STRING(par_nrdconta,"zzzz,zzz,9")) + '</strong>' +
                             '<br>Data: <strong>' + 
                             STRING(aux_datdodia,"99/99/9999") + '</strong><br>' +
                             'Hor&aacute;rio: <strong>' + 
                             STRING(TIME,"HH:MM:SS") + '</strong><br>' +
                             'IP: <strong>' + par_nripuser + '</strong><br>' + 
                             'Tentativa Nr.: <strong>' + 
                            (IF  par_inaceblq = 0  THEN
                                 'Tentativa direta de acesso a operacao'
                             ELSE
                                 STRING(aux_qtacerro)) +
                            (IF  par_inaceblq = 1             AND
                                 aux_qttenper = aux_qtacerro  THEN
                                 ' (Acesso Bloqueado)'
                             ELSE
                                 '') +
                             '</strong></font><br><br>'.
        
                            RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT 
                                SET h-b1wgen0011.
        
                            IF  VALID-HANDLE(h-b1wgen0011)  THEN
                                DO:
                                    RUN enviar_email_completo IN h-b1wgen0011 
                                       (INPUT par_cdcooper,
                                        INPUT "INTERNETBANK126",
                                        INPUT "CECRED" +
                                              "<cpd@cecred.coop.br>",
                                        INPUT "diego.gomes@cecred.coop.br",
                                        INPUT "Conta Mobile - Senha Incorreta",
                                        INPUT "",
                                        INPUT "",
                                        INPUT aux_conteudo,
                                        INPUT FALSE).
        
                                    DELETE PROCEDURE h-b1wgen0011.    
                                END.
                        END.
                END. /* FIM - Validação para bloquear a senha, caso necessário */
            ELSE
                IF  par_inaceblq = 1  THEN 
                    ASSIGN crapsnh.qtacerro = 0.
        
            /* Alterar dados de último acesso */
            FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                           craptab.nmsistem = "CRED"       AND
                           craptab.tptabela = "GENERI"     AND
                           craptab.cdempres = 0            AND
                           craptab.cdacesso = "LIMINTERNT" AND
                           craptab.tpregist = 1   
                           NO-LOCK NO-ERROR.

            IF  NOT AVAIL craptab  THEN
                aux_dscritic = "Registro LIMINTERNT nao encontrado.".
            ELSE
                DO:
                    ASSIGN aux_qtdiauso = INTEGER(ENTRY(17,craptab.dstextab,";"))
                           aux_qtdiaalt = INTEGER(ENTRY(18,craptab.dstextab,";"))
                           aux_qtdiablq = INTEGER(ENTRY(19,craptab.dstextab,";"))
                           aux_dtaltsnh = crapsnh.dtaltsnh.

                    ASSIGN aux_totdiabq = (aux_qtdiauso + aux_qtdiaalt + 
                                           aux_qtdiablq).

                    IF  aux_datdodia >= (aux_dtaltsnh + aux_totdiabq) THEN
                        DO:
                            ASSIGN crapsnh.cdsitsnh = 2
                                   crapsnh.dtblutsh = aux_datdodia
                                   crapsnh.dtaltsit = aux_datdodia
                                   crapsnh.cdoperad = "996".

                            IF  aux_totdiabq = 1  THEN
                                ASSIGN aux_dscritic = "Acesso Bloqueado. " +
                                               "Senha nao alterada no ultimo dia.". 
                            ELSE
                               ASSIGN aux_dscritic = "Acesso Bloqueado. " +
                                               "Senha nao alterada nos ultimos " + 
                                                STRING(aux_totdiabq) + " dias.". 
                        END.
                END.
    
            ASSIGN aux_flgtrans = TRUE.
    
        END. /* Fim do DO TRANSACTION */

    END. /* Fim do aux_dscritic = "" */

END. /* Fim do par_vldshlet */
IF  NOT aux_flgtrans AND aux_dscritic = ""  THEN
    aux_dscritic = "Não foi possível verificar os dados.".

IF  aux_dscritic <> ""  THEN
    DO:
        xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
                                                       
        RETURN "NOK".
    END.
********************************************************************************************************/

RETURN "OK".

/* ................................................................................................ */

