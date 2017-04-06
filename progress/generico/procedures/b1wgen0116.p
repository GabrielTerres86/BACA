/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | b1wgen0116.p                    | DDDA0001                          |
  | gerar-mensagem                  | GENE0003.pc_gerar_mensagem        | 
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/




/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0116.p
    Autor   : Jorge Issamu Hamaguchi
    Data    : Outubro/2011                     Ultima atualizacao: 12/12/2013

    Objetivo  : BO responsavel pela parte de mensagens no InternetBank.

    Alteracoes: 06/08/2012 - Criado proc. cadastrar-mensagem. (Jorge). 
    
                26/02/2013 - Ajustes em log de erros e performance. (Jorge)
                
                14/11/2013 - Retornar qtd de msg nao lidas na procedure 
                             listar-mensagens independente do tipo de 
                             consulta (David).
                             
                12/12/2013 - Adicionado VALIDATE para o CREATE. (Jorge)
                             
                16/01/2017 - Chamada da procedure do Oracle para evitar lock (Dionathan)
   
............................................................................*/

/*............................. DEFINICOES .................................*/

{ sistema/generico/includes/b1wgen0116tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_dsidpara AS CHAR                                        NO-UNDO.
DEF VAR aux_creatcdm AS CHAR                                        NO-UNDO.
DEF VAR par_dsrterro AS CHAR                                        NO-UNDO.

DEF VAR aux_contador AS INTE                                        NO-UNDO.
DEF VAR aux_ultnrmsg AS INTE                                        NO-UNDO.
DEF VAR aux_ultimcdm AS INTE                                        NO-UNDO.
DEF VAR aux_totenvia AS INTE                                        NO-UNDO.

DEF VAR aux_nrregist AS INTE                                        NO-UNDO.               
DEF VAR aux_iniseque AS INTE                                        NO-UNDO.
DEF VAR aux_fimseque AS INTE                                        NO-UNDO.
DEF VAR aux_nrseqerr AS INTE                                        NO-UNDO.

DEF VAR aux_dsassunt AS CHAR                                        NO-UNDO.

DEF STREAM str_1.

/*................................ PROCEDURES ..............................*/

PROCEDURE excluir-cadmsg:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdcadmsg AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_retrerro AS CHAR                           NO-UNDO.

    ExcluirMsg: DO TRANSACTION
                ON ERROR  UNDO ExcluirMsg, LEAVE ExcluirMsg
                ON QUIT   UNDO ExcluirMsg, LEAVE ExcluirMsg
                ON STOP   UNDO ExcluirMsg, LEAVE ExcluirMsg
                ON ENDKEY UNDO ExcluirMsg, LEAVE ExcluirMsg:

        DO  aux_contador = 1 TO 10:
            FIND FIRST crapcdm WHERE crapcdm.cdcooper = par_cdcooper
                                 AND crapcdm.cdcadmsg = par_cdcadmsg
                              EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
            
            IF  NOT AVAIL crapcdm THEN
                IF LOCKED crapcdm THEN DO:
                   ASSIGN aux_dscritic = "O cadastro da mensagem esta " +
                                         "sendo alterado. Tente novamente.".
                   PAUSE 1 NO-MESSAGE.
                   NEXT.
                END.
                ELSE  
                    ASSIGN aux_dscritic = "Erro ao acessar cadastro de " +
                                          "mensagem. Operacao abortada.".
            ELSE
            DO:
                FOR EACH crapmsg WHERE crapmsg.cdcadmsg = par_cdcadmsg
                                 EXCLUSIVE-LOCK:
                    DELETE crapmsg.
                END.
                ASSIGN aux_dsassunt = crapcdm.dsdassun.
                DELETE crapcdm.
            END.
            LEAVE.
        END.
        
    END. /* ExcluirMsg */
 
    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN par_retrerro = aux_dscritic.

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 90,
                           INPUT 900,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            UNIX SILENT VALUE('echo "' + STRING(TODAY,"99/99/9999")   +
                              ' ' + STRING(TIME,"HH:MM:SS")           +
                              ' - Operador: ' + par_cdoperad          + 
                              ' --> ' + aux_dscritic                  +
                              '" >> /usr/coop/cecred/log/cadmsg.log').

            RETURN "NOK".
        END.
    ELSE
        DO:
            ASSIGN aux_dscritic = "Mensagens '" + aux_dsassunt + "' excluidas.".
            UNIX SILENT VALUE('echo "' + STRING(TODAY,"99/99/9999")   +
                              ' ' + STRING(TIME,"HH:MM:SS")           +
                              ' - Operador: ' + par_cdoperad          + 
                              ' --> ' + aux_dscritic                  +
                              '" >> /usr/coop/cecred/log/cadmsg.log').
        END.


    RETURN "OK".

END PROCEDURE. /* excluir-cadmsg */


PROCEDURE carregar-cadmsg:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdcadmsg AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-cadmsg.
    
    DEF QUERY q_crapcdm FOR crapcdm.
    DEF VAR aux_query    AS CHAR                                       NO-UNDO.
    DEF VAR aux_dscdmsg  AS CHAR                                       NO-UNDO.
    
    EMPTY TEMP-TABLE tt-cadmsg.

    IF  par_cdcadmsg > 0 THEN
        ASSIGN aux_dscdmsg = " AND crapcdm.cdcadmsg = " + STRING(par_cdcadmsg).

    ASSIGN aux_query = "FOR EACH crapcdm WHERE " + 
                       "crapcdm.cdcooper = " + STRING(par_cdcooper) +
                       aux_dscdmsg + " NO-LOCK:".

    QUERY q_crapcdm:QUERY-CLOSE().
    QUERY q_crapcdm:QUERY-PREPARE(aux_query).
    QUERY q_crapcdm:QUERY-OPEN().
    
    GET FIRST q_crapcdm.
    DO  WHILE AVAIL(crapcdm):
        CREATE tt-cadmsg.
        ASSIGN tt-cadmsg.cdcadmsg = crapcdm.cdcadmsg
               tt-cadmsg.cdcooper = crapcdm.cdcooper
               tt-cadmsg.cdidpara = crapcdm.cdidpara
               tt-cadmsg.cdoperad = crapcdm.cdoperad
               tt-cadmsg.dsdassun = crapcdm.dsdassun
               tt-cadmsg.dsdmensg = crapcdm.dsdmensg
               tt-cadmsg.dsidpara = crapcdm.dsidpara
               tt-cadmsg.dtdmensg = crapcdm.dtdmensg
               tt-cadmsg.hrdmensg = crapcdm.hrdmensg
               tt-cadmsg.qttotenv = crapcdm.qttotenv
               tt-cadmsg.qttotlid = crapcdm.qttotlid.
       GET NEXT q_crapcdm.
    END.

    QUERY q_crapcdm:QUERY-CLOSE().

    RETURN "OK".

END PROCEDURE. /* carregar-cadmsg */



PROCEDURE cadastrar-cadmsg:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdassun AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdmensg AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdidpara AS INTE                           NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-dsidpara.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF QUERY q_crapmsg  FOR crapcop, crapsnh.
    DEF VAR aux_query    AS CHAR                                    NO-UNDO.
    DEF VAR aux_qnrconta AS CHAR                                    NO-UNDO.
    DEF VAR aux_errorlog AS CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro. 

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_creatcdm = "NOK".

    Cadastrar: DO TRANSACTION
           ON ERROR  UNDO Cadastrar, LEAVE Cadastrar
           ON QUIT   UNDO Cadastrar, LEAVE Cadastrar
           ON STOP   UNDO Cadastrar, LEAVE Cadastrar
           ON ENDKEY UNDO Cadastrar, LEAVE Cadastrar:

        DO  aux_contador = 1 TO 10:
            FIND LAST crapcdm WHERE crapcdm.cdcooper = par_cdcooper
                              EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
            
            IF  NOT AVAIL crapcdm THEN
                IF LOCKED crapcdm THEN DO:
                   ASSIGN aux_dscritic = "Ultimo registro de mensagem esta " +
                                         "sendo alterado. Tente novamente.".

                   PAUSE 1 NO-MESSAGE.
                   NEXT.
                END.
                ELSE  
                    ASSIGN aux_ultimcdm = 1.
            ELSE
                ASSIGN aux_ultimcdm = crapcdm.cdcadmsg + 1.
            LEAVE.
        END.
        
        /* se for destinatario por cooperativa, grava as cooperativas em campo */
        IF  par_cdidpara = 1 THEN
            DO:
                ASSIGN aux_contador = 1.
                FOR EACH tt-dsidpara NO-LOCK:
                    IF  aux_contador = 1 THEN
                        ASSIGN aux_dsidpara = STRING(tt-dsidpara.cdcooper)
                               aux_contador = 2.
                    ELSE
                        ASSIGN aux_dsidpara = aux_dsidpara + "," +
                                              STRING(tt-dsidpara.cdcooper).
                END.
            END.
        
        /* trocando alguns caracteres por codigo URL */
        ASSIGN par_dsdmensg = REPLACE(par_dsdmensg,"<","%3C")
               par_dsdmensg = REPLACE(par_dsdmensg,">","%3E")
               par_dsdmensg = REPLACE(par_dsdmensg,"&","%26").
       
        /* criando o cadastro da mensagem */
        CREATE  crapcdm.
        ASSIGN  crapcdm.cdcadmsg = aux_ultimcdm
        		crapcdm.cdcooper = par_cdcooper
        		crapcdm.cdidpara = par_cdidpara
        		crapcdm.cdoperad = par_cdoperad
        		crapcdm.dsdassun = par_dsdassun
        		crapcdm.dsdmensg = par_dsdmensg
        		crapcdm.dsidpara = aux_dsidpara
        		crapcdm.dtdmensg = TODAY
        	    crapcdm.hrdmensg = TIME	
                crapcdm.qttotenv = 0
        		crapcdm.qttotlid = 0.
        VALIDATE crapcdm.
        
         ASSIGN aux_creatcdm = "OK".

    END. /* Cadastrar */

    IF aux_creatcdm = "OK" THEN
    DO:

        OUTPUT STREAM str_1 TO VALUE ("/micros/cecred/cadmsg" + 
                                      STRING(aux_ultimcdm) + ".log").

        ASSIGN aux_totenvia = 0.

        /* verificar se na temp-table veio cdcooper = 0 "Todas cooperativas" */
        IF  CAN-FIND ( FIRST tt-dsidpara WHERE tt-dsidpara.cdcooper = 0)  THEN
            DO:
               /* limpa tabela e adiciona todas cooperativas */
               EMPTY TEMP-TABLE tt-dsidpara.
               FOR EACH crapcop NO-LOCK:
                   CREATE tt-dsidpara.
                   ASSIGN tt-dsidpara.cdcooper = crapcop.cdcooper.
               END.
            END.
        
        /* pega os destinatarios */
        FOR EACH tt-dsidpara NO-LOCK:
            IF  par_cdidpara = 1 THEN
                ASSIGN aux_qnrconta = "> 0".
            ELSE
                ASSIGN aux_qnrconta = "= " + STRING(tt-dsidpara.nrdconta).

            ASSIGN aux_query = 
            "FOR EACH crapcop WHERE "                                       +
            "         crapcop.cdcooper = " + STRING(tt-dsidpara.cdcooper)   +
            "         NO-LOCK, "                                            +
            "    EACH crapsnh WHERE crapsnh.cdcooper = crapcop.cdcooper "   +
            "                   AND crapsnh.tpdsenha = 1 "                  +
            "                   AND crapsnh.cdsitsnh = 1 "                  +
            "                   AND crapsnh.nrdconta " + aux_qnrconta       + 
            "                   NO-LOCK:".
            
            QUERY q_crapmsg:QUERY-CLOSE().
            QUERY q_crapmsg:QUERY-PREPARE(aux_query).
            QUERY q_crapmsg:QUERY-OPEN().
            
            GET FIRST q_crapmsg.
            
            IF  AVAIL crapsnh THEN
                DO:
                    DO  WHILE AVAIL(crapsnh):
                        
                        /* gerar zmensagem para o cooperado */
                        RUN gerar-mensagem (
                                        INPUT tt-dsidpara.cdcooper,
                                        INPUT crapsnh.nrdconta,
                                        INPUT crapsnh.idseqttl,
                                        INPUT "CRAPMSG", /* cdprogra */
                                        INPUT 0,         /* inpriori */
                                        INPUT par_dsdmensg,
                                        INPUT par_dsdassun,
                                        INPUT crapcop.nmrescop,
                                        INPUT "Mensagem Aviso",
                                        INPUT par_cdoperad,
                                        INPUT aux_ultimcdm,
                                       OUTPUT par_dsrterro).
        
                        IF  RETURN-VALUE = "NOK" THEN						
                        DO:
                            ASSIGN aux_cdcritic = 1
							       aux_dscritic = "Erro de envio: "
                                   aux_dscritic = aux_dscritic +
                                   "(" + STRING(tt-dsidpara.cdcooper) + ";" + 
                                   STRING(crapsnh.nrdconta) + ") " .								  

                            PUT STREAM str_1 
                                       aux_dscritic FORMAT "X(80)" SKIP.

                            CREATE tt-erro.
                            ASSIGN tt-erro.dscritic = aux_dscritic
                                   tt-erro.nrsequen = aux_nrseqerr
                                   aux_nrseqerr     = aux_nrseqerr + 1.
                        END.
                        ELSE
                            ASSIGN aux_totenvia = aux_totenvia + 1.
                         
                        GET NEXT q_crapmsg.
                    END. /* Do while avail */
                END.
            ELSE
                DO:
                    /* sem acesso a internet */
                    ASSIGN aux_dscritic = "(" + STRING(tt-dsidpara.cdcooper) + 
                                          ";" + STRING(tt-dsidpara.nrdconta) + 
                                          ") Conta invalida ou nao possui "  +
                                          "acesso a internet.".

                    PUT STREAM str_1 
                               aux_dscritic FORMAT "X(80)" SKIP. 
                    
                    CREATE tt-erro.
                    ASSIGN tt-erro.cdcritic = aux_cdcritic
                           tt-erro.dscritic = aux_dscritic
                           tt-erro.nrsequen = aux_nrseqerr
                           aux_nrseqerr     = aux_nrseqerr + 1.
                     
                END.

        END. /* fim For each tt-dsidpara */

        OUTPUT STREAM str_1 CLOSE.
        
        /* limite para passar erros para nao estourar o xml */
        IF  aux_nrseqerr > 2500 THEN
            DO:
                ASSIGN aux_dscritic = "".
                IF aux_totenvia > 0 THEN
                    ASSIGN aux_dscritic = "Mensagens enviadas parcialmente.<br> "
                                          + "Enviadas: " + STRING(aux_totenvia)
                                          + ". ".
                
                ASSIGN aux_dscritic = aux_dscritic + 
                                      "Falhou: " + STRING(aux_nrseqerr) + 
                                      ".<br>" +
                                      "Verifique o arquivo de LOG (cadmsg"     +
                                      STRING(aux_ultimcdm) + ".log) para "     +
                                      "visualizar os erros.".
                EMPTY TEMP-TABLE tt-erro.
                CREATE tt-erro.
                ASSIGN tt-erro.dscritic = aux_dscritic
                       tt-erro.nrsequen = 0.

            END.

        DO TRANSACTION:
            ASSIGN crapcdm.qttotenv = aux_totenvia.
        END.
        
    END. /* fim if */
    ELSE
    DO:
        CREATE tt-erro.
        ASSIGN aux_dscritic = "Problema ao cadastrar mensagem."
               tt-erro.dscritic = aux_dscritic
               tt-erro.nrsequen = aux_nrseqerr
               aux_nrseqerr = aux_nrseqerr + 1.
    END.
                   
    IF  aux_dscritic <> ? OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".
           
            UNIX SILENT VALUE('echo "' + STRING(TODAY,"99/99/9999")   +
                              ' ' + STRING(TIME,"HH:MM:SS")           +
                              ' - Operador: ' + par_cdoperad          + 
                              ' --> ' + aux_dscritic                  +
                              '" >> /usr/coop/cecred/log/cadmsg.log').
    
        END.
    ELSE
        DO:
            ASSIGN aux_dscritic = "Mensagens '" + par_dsdassun + "' " +
                                  "enviadas com sucesso.".

            UNIX SILENT VALUE('echo "' + STRING(TODAY,"99/99/9999")   +
                              ' ' + STRING(TIME,"HH:MM:SS")           +
                              ' - Operador: ' + par_cdoperad          + 
                              ' --> ' + aux_dscritic                  +
                              '" >> /usr/coop/cecred/log/cadmsg.log').

            ASSIGN aux_returnvl = "OK".
        END.

    RETURN aux_returnvl.

END PROCEDURE. /* cadastrar-mensagem */



PROCEDURE gerar-mensagem:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inpriori AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsdmensg AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdassun AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdremet AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdplchv AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdcadmsg AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_retrerro AS CHAR                           NO-UNDO.
    
    DEF VAR aux_nrsequen          AS INTE                           NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_returnvl = "NOK".
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_gerar_mensagem aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_nrdconta,
                          INPUT par_idseqttl,
                          INPUT par_cdprogra,
                          INPUT par_inpriori,
                          INPUT par_dsdmensg,
                          INPUT par_dsdassun,
                          INPUT par_dsdremet,
                          INPUT par_dsdplchv,
                          INPUT par_cdoperad,
                          INPUT par_cdcadmsg,
                          OUTPUT "").
                          
    CLOSE STORED-PROC pc_gerar_mensagem aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_dscritic = pc_gerar_mensagem.pr_dscritic.	

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF   aux_dscritic = ? 
	OR aux_dscritic = "" THEN DO:
         ASSIGN aux_returnvl = "OK".	  
    END.
    
    RETURN aux_returnvl.

END PROCEDURE. /* gerar-mensagem */





PROCEDURE listar-mensagens:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_iddmensg AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_retrerro AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_qtmsnlid AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dsasnlid AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-mensagens.
    
    DEF VAR aux_nrregist AS INTE NO-UNDO.               
    DEF VAR aux_iniseque AS INTE NO-UNDO.
    DEF VAR aux_fimseque AS INTE NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_nrregist = 0
           aux_iniseque = par_nriniseq
           aux_fimseque = par_nriniseq + par_nrregist.
    
    Listar: DO ON ERROR UNDO Listar, LEAVE Listar:
        EMPTY TEMP-TABLE tt-mensagens.

        RUN quantidade-mensagens (INPUT par_cdcooper, 
    	                          INPUT par_nrdconta,
                                  INPUT par_idseqttl,
                                  INPUT 1,
                                  INPUT 0, 
                                  INPUT 0, 
                                 OUTPUT aux_dscritic,
                                 OUTPUT par_dsasnlid,
                                 OUTPUT par_qtmsnlid).

        IF  RETURN-VALUE <> "OK"  THEN
            UNDO Listar, LEAVE Listar.
        
        FOR EACH crapmsg NO-LOCK WHERE crapmsg.cdcooper = par_cdcooper
                                   AND crapmsg.nrdconta = par_nrdconta
                                   AND (crapmsg.idseqttl = 0 OR
                                        crapmsg.idseqttl = par_idseqttl)
                                    BY crapmsg.dtdmensg DESC
                                    BY crapmsg.hrdmensg DESC:
            
            /* mensgens nao lidas */
            IF  par_iddmensg = 1         AND 
               (crapmsg.flgleitu = TRUE  OR
                crapmsg.flgexclu = TRUE) THEN NEXT.
            /* mensagens lidas */
            ELSE IF par_iddmensg = 2         AND 
                   (crapmsg.flgleitu = FALSE OR
                    crapmsg.flgexclu = TRUE) THEN NEXT.
            /* mensagens excluidas */
            ELSE IF par_iddmensg = 3         AND
                    crapmsg.flgexclu = FALSE THEN NEXT.
            
            ASSIGN aux_nrregist = aux_nrregist + 1.
            
            IF  par_nrregist > 0              AND 
               (aux_nrregist <  aux_iniseque  OR
                aux_nrregist >= aux_fimseque) THEN
                NEXT.

            CREATE tt-mensagens.
            ASSIGN tt-mensagens.cdcooper = crapmsg.cdcooper
                   tt-mensagens.nrdconta = crapmsg.nrdconta
                   tt-mensagens.idseqttl = crapmsg.idseqttl
                   tt-mensagens.nrdmensg = crapmsg.nrdmensg
                   tt-mensagens.cdprogra = crapmsg.cdprogra
                   tt-mensagens.dtdmensg = crapmsg.dtdmensg
                   tt-mensagens.hrdmensg = crapmsg.hrdmensg
                   tt-mensagens.dsdremet = crapmsg.dsdremet
                   tt-mensagens.dsdassun = crapmsg.dsdassun
                   tt-mensagens.dsdmensg = crapmsg.dsdmensg
                   tt-mensagens.flgleitu = crapmsg.flgleitu
                   tt-mensagens.dtdleitu = crapmsg.dtdleitu
                   tt-mensagens.hrdleitu = crapmsg.hrdleitu
                   tt-mensagens.inpriori = crapmsg.inpriori
                   tt-mensagens.flgexclu = crapmsg.flgexclu.
                   
        END. /* FIM For each */

        FIND FIRST tt-mensagens EXCLUSIVE-LOCK NO-ERROR.
        IF AVAIL tt-mensagens THEN
            ASSIGN tt-mensagens.qtdresul = aux_nrregist.

    END. /* Listar */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK"
                   par_retrerro = aux_dscritic.

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 90,
                           INPUT 900,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* listar-mensagens */


PROCEDURE quantidade-mensagens:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_iddmensg AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_retrerro AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dsassunt AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_qtdmensg AS INTE                           NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".
    
    Qtdmsg: DO ON ERROR UNDO Qtdmsg, LEAVE Qtdmsg:
 
        FOR EACH crapmsg WHERE crapmsg.cdcooper = par_cdcooper
                           AND crapmsg.nrdconta = par_nrdconta
                           AND (crapmsg.idseqttl = 0 OR
                                crapmsg.idseqttl = par_idseqttl)
                           NO-LOCK
                           BY crapmsg.dtdmensg DESC
                           BY crapmsg.hrdmensg DESC:

            /* mensgens nao lidas */
            IF  par_iddmensg = 1         AND 
               (crapmsg.flgleitu = TRUE  OR
                crapmsg.flgexclu = TRUE) THEN NEXT.
            /* mensagens lidas */
            ELSE IF par_iddmensg = 2         AND 
                   (crapmsg.flgleitu = FALSE OR
                    crapmsg.flgexclu = TRUE) THEN NEXT.
            /* mensagens excluidas */
            ELSE IF par_iddmensg = 3         AND
                    crapmsg.flgexclu = FALSE THEN NEXT.

            ASSIGN par_qtdmensg = (par_qtdmensg + 1)
                   par_dsassunt = (par_dsassunt + "|" + crapmsg.dsdassun).
                   
        END.

    END. /* Qtdmsg */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK"
                   par_retrerro = aux_dscritic.

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 90,
                           INPUT 900,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* quantidade-mensagens */


PROCEDURE excluir-mensagem:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdmensg AS DECI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_retrerro AS CHAR                           NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK".
    
    Excluir: DO ON ERROR UNDO Excluir, LEAVE Excluir:

        DO aux_contador = 1 TO 10:

            FIND FIRST crapmsg WHERE cdcooper = par_cdcooper 
    	                         AND nrdconta = par_nrdconta
    	                         AND nrdmensg = par_nrdmensg 
    	                         EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
    	
            IF  NOT AVAIL crapmsg THEN
                DO:
                    IF  LOCKED crapmsg THEN
                        DO:
                            ASSIGN aux_dscritic = 
                                   "Registro da mensagem esta sendo " +
                                   "alterado. Tente novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        ASSIGN aux_dscritic = 
                               "Erro ao acessar mensagem. Operacao abortada.".
                END.
            ELSE    
                ASSIGN crapmsg.flgexclu = TRUE.
            LEAVE.

        END. /* FIM Do  1 To 10 */
            

    END. /* Excluir */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK"
                   par_retrerro = aux_dscritic.

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 90,
                           INPUT 900,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* excluir-mensagem */


PROCEDURE ler-mensagem:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdmensg AS DECI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtmsnlid AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dsasnlid AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-mensagens.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_msgmlida AS LOGI                                    NO-UNDO.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_msgmlida = FALSE.
    
    Ler: DO ON ERROR UNDO Ler, LEAVE Ler:

        DO  aux_contador = 1 TO 10:

            ASSIGN aux_dscritic = "".
               
            FIND FIRST crapmsg WHERE crapmsg.cdcooper = par_cdcooper 
    	                         AND crapmsg.nrdconta = par_nrdconta
    	                         AND crapmsg.nrdmensg = par_nrdmensg 
    	                         EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
    	
            IF  NOT AVAIL crapmsg THEN
                DO:
                    IF  LOCKED crapmsg THEN
                        DO:
                            ASSIGN aux_dscritic = 
                                   "Registro da mensagem esta sendo " +
                                   "alterado. Tente novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        ASSIGN aux_dscritic = 
                               "Erro ao acessar mensagem. Operacao abortada.".
                END.
            ELSE
                DO:
                    IF  NOT crapmsg.flgleitu THEN
                        DO:
                            ASSIGN crapmsg.flgleitu = TRUE
                                   crapmsg.dtdleitu = TODAY
                                   crapmsg.hrdleitu = TIME
                                   aux_msgmlida     = TRUE.
                        END.
                END.

            LEAVE.
                
        END. /* fim Do 1 to 10 */

        IF  aux_dscritic <> ""  THEN
            UNDO Ler, LEAVE Ler.
                
        CREATE tt-mensagens.
        ASSIGN tt-mensagens.cdcooper = crapmsg.cdcooper
               tt-mensagens.nrdconta = crapmsg.nrdconta
               tt-mensagens.idseqttl = crapmsg.idseqttl
               tt-mensagens.nrdmensg = crapmsg.nrdmensg
               tt-mensagens.cdprogra = crapmsg.cdprogra
               tt-mensagens.dtdmensg = crapmsg.dtdmensg
               tt-mensagens.hrdmensg = crapmsg.hrdmensg
               tt-mensagens.dsdremet = crapmsg.dsdremet
               tt-mensagens.dsdassun = crapmsg.dsdassun
               tt-mensagens.dsdmensg = crapmsg.dsdmensg
               tt-mensagens.flgleitu = crapmsg.flgleitu
               tt-mensagens.dtdleitu = crapmsg.dtdleitu
               tt-mensagens.hrdleitu = crapmsg.hrdleitu
               tt-mensagens.inpriori = crapmsg.inpriori
               tt-mensagens.flgexclu = crapmsg.flgexclu.       

        IF  crapmsg.cdcadmsg > 0 AND aux_msgmlida  THEN
            DO:
                DO aux_contador = 1 TO 10:
                       
                   ASSIGN aux_dscritic = "".

                   FIND FIRST crapcdm WHERE crapcdm.cdcooper = 3 /* CECRED */
                                        AND crapcdm.cdcadmsg = crapmsg.cdcadmsg
                                        EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
            
                   IF  NOT AVAIL crapcdm THEN
                       DO:
                           IF  LOCKED crapcdm THEN
                               DO:
                                   ASSIGN aux_dscritic = 
                                          "Cadastro da mensagem esta sendo " +
                                          "alterado. Tente novamente.".
                                   PAUSE 1 NO-MESSAGE.
                                   NEXT.
                               END.
                           ELSE
                               ASSIGN aux_dscritic = 
                                      "Erro ao acessar cadastro de mensagem. " +
                                      "Operacao abortada.".
                       END.
                   ELSE
                       DO:
                           ASSIGN crapcdm.qttotlid = crapcdm.qttotlid + 1.
                       END.

                   LEAVE.
                    
                END.

                IF  aux_dscritic <> ""  THEN
                    UNDO Ler, LEAVE Ler.
            END.

        RUN quantidade-mensagens (INPUT par_cdcooper, 
    	                          INPUT par_nrdconta,
                                  INPUT par_idseqttl,
                                  INPUT 1,
                                  INPUT 0, 
                                  INPUT 0, 
                                 OUTPUT aux_dscritic,
                                 OUTPUT par_dsasnlid,
                                 OUTPUT par_qtmsnlid).

        IF  RETURN-VALUE <> "OK"  THEN
            UNDO Ler, LEAVE Ler.
        
    END. /* Ler */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 90,
                           INPUT 900,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* ler-mensagem */

/*.............................. PROCEDURES (FIM) ...........................*/
