/*..............................................................................

Programa : fontes/agentes_simulstaneos.p
Autor    : Fernando Klock
Data     : 13/05/2010
Objetivo : Buscar o numero de agentes simultaneos requisitados durante o dia
           por cooperativa/servico.

Alteracoes : 25/06/2010 - Pegar caminho do log no ubroker.properties -
                          srvrLogFile e incluir o servico TAA (Fernando).

             18/10/2010 - Ajustar os filtros para os novos servicos unificados
                          (Fernando).
                          
             11/04/2014 - Criando arquivo de LOG de processo em vez de gravar
                          no Banco (Andre Santos/SUPERO).
             
..............................................................................*/
DEFINE STREAM str_1.
DEFINE STREAM str_2.
DEFINE STREAM str_3.

DEFINE VARIABLE aux_cdcooper  AS INTEGER     FORMAT "zz9"            NO-UNDO.
DEFINE VARIABLE aux_nmcooper  AS CHARACTER   FORMAT "x(15)"          NO-UNDO.
DEFINE VARIABLE aux_nmservico AS CHARACTER                           NO-UNDO.
DEFINE VARIABLE aux_dsarqlog  AS CHARACTER                           NO-UNDO.
DEFINE VARIABLE aux_setlinha  AS CHARACTER  FORMAT "x(400)"          NO-UNDO.
DEFINE VARIABLE aux_cdexeprg  AS INTEGER    INIT 0                   NO-UNDO.
DEFINE VARIABLE aux_cdpidprg  AS INTEGER                             NO-UNDO.
DEFINE VARIABLE aux_nrdahora  AS INTEGER                             NO-UNDO.
DEFINE VARIABLE aux_nrminuto  AS INTEGER                             NO-UNDO.
DEFINE VARIABLE aux_nrsegund  AS INTEGER                             NO-UNDO.
DEFINE VARIABLE aux_dshhmmss  AS CHARACTER                           NO-UNDO.
DEFINE VARIABLE aux_nrhorint  AS INTEGER                             NO-UNDO.
DEFINE VARIABLE aux_dsservic  AS CHARACTER                           NO-UNDO.
DEFINE VARIABLE aux_qtdtempo  AS INTEGER                             NO-UNDO.
DEFINE VARIABLE aux_qttmptot  AS INTEGER                             NO-UNDO.
DEFINE VARIABLE aux_nridproc  AS INTEGER                             NO-UNDO.
DEFINE VARIABLE aux_nrposwds  AS INTEGER                             NO-UNDO.
DEFINE VARIABLE aux_dsdiames  AS CHARACTER                           NO-UNDO.
DEFINE VARIABLE aux_nrmeslog  AS INTEGER                             NO-UNDO.
DEFINE VARIABLE aux_flgbatch  AS LOGICAL                             NO-UNDO.
DEFINE VARIABLE aux_qtagente  AS INTEGER INITIAL 0                   NO-UNDO.
DEFINE VARIABLE aux_mxagente  AS INTEGER INITIAL 0                   NO-UNDO.
DEFINE VARIABLE aux_horamaxi  AS CHARACTER INITIAL 0                 NO-UNDO.
DEFINE VARIABLE aux_dtmvtolt  AS CHARACTER                           NO-UNDO.
DEFINE VARIABLE aux_datamaxi  AS CHARACTER                           NO-UNDO.
DEFINE VARIABLE aux_flgerror  AS LOGICAL                             NO-UNDO.
DEFINE VARIABLE aux_flgexist  AS LOGICAL                             NO-UNDO.
DEFINE VARIABLE aux_nmarquiv  AS CHARACTER                           NO-UNDO.
DEFINE VARIABLE aux_nmarqlog AS CHAR                                NO-UNDO.

DEF TEMP-TABLE ttPrg  NO-UNDO
        FIELD cdexeprg AS INTE
        FIELD cdpidprg AS INTE
        FIELD nrhorexe AS INTE
        FIELD nrtmpexe AS INTE
        FIELD dsprogra AS CHAR
        FIELD dsstatus AS CHAR.

DEF TEMP-TABLE tt-servicos NO-UNDO
    FIELD nome_servico  AS CHAR FORMAT "x(20)"
    FIELD nome_resumido AS CHAR
    FIELD nome_banco    AS CHAR
    FIELD local_do_log  AS CHAR
    FIELD nr_servico    AS INTE
    FIELD cod_banco     AS INTE
    FIELD init_agentes  AS INTE
    FIELD max_agentes   AS INTE
    FIELD min_agentes   AS INTE.

DEF TEMP-TABLE tt-tb_Servicos NO-UNDO
    FIELD CodServico  AS INTE
    FIELD DataColeta  AS DATE
    FIELD HoraAgeSimu AS INTE
    FIELD InitAgente  AS INTE
    FIELD MaxAgente   AS INTE
    FIELD MinAgente   AS INTE
    FIELD NomeServico AS CHAR
    FIELD TotAgeSimu  AS INTE
    FIELD CodCooper   AS INTE.
    
/*********** IRA RODAR TODO O DIA - FERNANDO KLOCK ***********

Rodar somente com o processo 
INPUT STREAM str_1 THROUGH VALUE("ls /usr/coop/viacredi/arquivos/.procfer*" +
                                 " 2> /dev/null") NO-ECHO.

DO  WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
    
    IMPORT STREAM str_1 UNFORMATTED aux_nmarquiv.

    /* Se existir arquivos significa que eh feriado ou final de semana */
    IF  aux_nmarquiv <> "" THEN
        RETURN.

    LEAVE.
END.                            
*/

EMPTY TEMP-TABLE tt-servicos.

INPUT STREAM str_1 THROUGH
      VALUE("egrep 'UBroker.WS.|initialSrvrInstance|maxSrvrInstance|" +
       "minSrvrInstance|srvrLogFile' /usr/dlc/properties/ubroker.properties " +
       "2> /dev/null") NO-ECHO.
       
DO  WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

    IF  aux_flgexist = FALSE THEN
        IMPORT STREAM str_1 UNFORMATTED aux_nmservico.

    IF  NOT aux_nmservico MATCHES "[UBroker.WS.*"              OR
            aux_nmservico MATCHES "*[UBroker.WS.wsbroker1]*"   OR
            aux_nmservico MATCHES "*[UBroker.WS.wsdynamics1]*" OR
            TRIM(aux_nmservico) = ""                           THEN DO:

        ASSIGN aux_flgexist = FALSE.
        NEXT.
    END.

    ASSIGN aux_nmservico = SUBSTRING(TRIM(aux_nmservico),13,
                                   LENGTH(aux_nmservico) - 12).

    IF  aux_nmservico = ""   THEN
        NEXT.

    CREATE tt-servicos.
    ASSIGN tt-servicos.nome_servico  = SUBSTRING(aux_nmservico, 1,
                                          LENGTH(aux_nmservico) - 1).

    DO  WHILE TRUE ON ERROR UNDO, LEAVE:

        IMPORT STREAM str_1 UNFORMATTED aux_nmservico.
    
        ASSIGN aux_flgexist = TRUE.

        /* Numero inicial de agentes quando o servico subir */
        IF  aux_nmservico MATCHES "*initialSrvrInstance*"   THEN DO:

            ASSIGN tt-servicos.init_agentes =
                                           INT(SUBSTRING(TRIM(aux_nmservico),21,
                                                  LENGTH(aux_nmservico) - 20))
                   aux_flgexist = FALSE.
        END.
        ELSE
            /* Maximo numero de agentes que o servico pode chamar */
            IF  aux_nmservico MATCHES "*maxSrvrInstance*"   THEN DO:
                ASSIGN tt-servicos.max_agentes =
                                           INT(SUBSTRING(TRIM(aux_nmservico),17,
                                                  LENGTH(aux_nmservico) - 16))
                       aux_flgexist = FALSE.
            END.
            ELSE
                /* Numero de agentes minimos para que o servico possa subir */
                IF  aux_nmservico MATCHES "*minSrvrInstance*"   THEN DO:
                    ASSIGN tt-servicos.min_agentes =
                                           INT(SUBSTRING(TRIM(aux_nmservico),17,
                                                  LENGTH(aux_nmservico) - 16))
                           aux_flgexist = FALSE.
                END.
                ELSE
                    /* Caminho para buscar o log */
                    IF  aux_nmservico MATCHES "*srvrLogFile*" THEN DO:
                        ASSIGN tt-servicos.local_do_log =
                                               SUBSTRING(TRIM(aux_nmservico),13,
                                                  LENGTH(aux_nmservico) - 12)
                               aux_flgexist = FALSE.
                    END.
                    ELSE
                        LEAVE.

    END. /* Fim do DO WHILE TRUE */

END. /* Fim do DO WHILE TRUE */

INPUT STREAM str_1 CLOSE.

FOR EACH tt-servicos:

    IF  tt-servicos.nome_servico = "ws_internet" THEN DO:
    
        ASSIGN tt-servicos.nome_resumido = "internet"
               tt-servicos.nr_servico    = 3.
    END.
    ELSE
    IF  tt-servicos.nome_servico = "ws_ayllos" THEN DO:
      
        ASSIGN tt-servicos.nome_resumido = "ayllos"
               tt-servicos.nr_servico    = 4.
    END.
    ELSE
    IF  tt-servicos.nome_servico = "ws_progrid" THEN DO:
        ASSIGN tt-servicos.nome_resumido = "progrid"
               tt-servicos.nr_servico    = 2.
    END.
    ELSE
    IF  tt-servicos.nome_servico = "ws_URA" THEN DO:

        ASSIGN tt-servicos.nome_resumido = "ura"
               tt-servicos.nr_servico    = 5.
    END.
    ELSE
    IF  tt-servicos.nome_servico = "ws_TAA"  THEN DO:
    
        ASSIGN tt-servicos.nome_resumido = "TAA"
               tt-servicos.nr_servico    = 6.
    END.
    ELSE
    IF  tt-servicos.nome_servico = "ws_caixaonline"  THEN DO:
        
        ASSIGN tt-servicos.nome_resumido = "cx_online"
               tt-servicos.nr_servico    = 1.
    END.
    ELSE
    IF  tt-servicos.nome_servico = "ws_CQL"  THEN DO:
        ASSIGN tt-servicos.nome_resumido = "CQL"
               tt-servicos.nr_servico    = 7.
    END.
    ELSE
    IF  tt-servicos.nome_servico = "ws_GED"  THEN DO:
        
        ASSIGN tt-servicos.nome_resumido = "GED"
               tt-servicos.nr_servico    = 8.
    END.

END. /* Fim do FOR EACH - tt-servicos */

FOR EACH tt-servicos:

    /* Caso alguma das configuracoes (ubroker.properties) estejam em default */
    IF  tt-servicos.init_agentes = 0   THEN
        ASSIGN tt-servicos.init_agentes = 5.

    IF  tt-servicos.max_agentes = 0   THEN
        ASSIGN tt-servicos.max_agentes = 10.

    IF  tt-servicos.min_agentes = 0   THEN
        ASSIGN tt-servicos.min_agentes = 1.

    ASSIGN aux_dsarqlog = tt-servicos.local_do_log
           aux_flgerror = FALSE.

    IF  SEARCH(aux_dsarqlog) = ?   THEN
        NEXT.

    UNIX SILENT VALUE("cp " + TRIM(aux_dsarqlog) + " /tmp/log_caixa.log").

    UNIX SILENT VALUE("echo fimdolog >> /tmp/log_caixa.log").
    UNIX SILENT VALUE("quoter /tmp/log_caixa.log > /tmp/log_caixa.q").

    INPUT STREAM str_2 FROM VALUE("/tmp/log_caixa.q") NO-ECHO.

    IMPORT STREAM str_2 aux_setlinha.

    DO  WHILE (TRIM(aux_setlinha) <> "fimdolog"):

        /* TOKEN web-disp existe sempre que um agente foi utilizado */
        ASSIGN aux_nrposwds = LOOKUP("web-disp", aux_setlinha, " ").

        IF  aux_nrposwds > 0   THEN DO:
            ASSIGN aux_cdpidprg = INT(ENTRY(aux_nrposwds + 1,aux_setlinha, " "))
                   aux_dtmvtolt = SUBSTR(ENTRY(1, aux_setlinha, "@"), 2, 8)
                   aux_dshhmmss = SUBSTR(ENTRY(2, aux_setlinha, "@"), 1, 8)
                   aux_nrdahora = INT(ENTRY(1, aux_dshhmmss, ":"))
                   aux_nrminuto = INT(ENTRY(2, aux_dshhmmss, ":"))
                   aux_nrsegund = INT(ENTRY(3, aux_dshhmmss, ":")) NO-ERROR.

            IF  ERROR-STATUS:ERROR THEN DO:
                ASSIGN aux_flgerror = TRUE.
                LEAVE.
            END.

            FIND ttprg WHERE ttprg.cdpidprg = aux_cdpidprg
                         AND ttprg.cdexeprg = 0 NO-ERROR.

            IF  AVAILABLE ttprg   THEN DO:

                ASSIGN aux_nrhorint = (aux_nrdahora * 3600) +
                                      (aux_nrminuto * 60) + aux_nrsegund
                       ttprg.nrtmpexe = aux_nrhorint - ttprg.nrhorexe.
                
                DELETE ttprg.

                ASSIGN aux_qtagente = aux_qtagente - 1.
            END.
            ELSE DO:
                /* Quando o agente foi Iniciado */
                IF  INDEX(aux_setlinha, "Iniciado") > 0   THEN DO:
                    CREATE ttprg.
                    ASSIGN ttprg.cdpidprg = aux_cdpidprg
                           ttprg.nrhorexe = (aux_nrdahora * 3600) +
                                            (aux_nrminuto * 60) + aux_nrsegund
                           ttprg.dsprogra = ENTRY(aux_nrposwds + 2,
                                                  aux_setlinha, " ")
                           ttprg.dsstatus = "Executando".

                    ASSIGN aux_qtagente = aux_qtagente + 1.

                    IF  aux_qtagente >= aux_mxagente  THEN DO:
                        ASSIGN aux_mxagente = aux_qtagente
                               aux_horamaxi = aux_dshhmmss
                               aux_datamaxi = aux_dtmvtolt.
                    END.
                END.
            END.
        END.

        IMPORT STREAM str_2 aux_setlinha.

    END. /* Fim do DO WHILE TRUE */

    IF  aux_flgerror = TRUE THEN DO:
        ASSIGN aux_cdpidprg = 0
               aux_dtmvtolt = ""
               aux_dshhmmss = ""
               aux_nrdahora = 0
               aux_nrminuto = 0
               aux_nrsegund = 0
               aux_mxagente = 0
               aux_horamaxi = ""
               aux_datamaxi = ""
               aux_qtagente = 0.

        EMPTY TEMP-TABLE ttprg.
        NEXT.
    END.

    /* Data em branco ou errada */
    IF  LENGTH(TRIM(aux_datamaxi)) < 8 THEN DO:
        
        FIND ttprg WHERE ttprg.cdpidprg = aux_cdpidprg
                     AND ttprg.cdexeprg = 0
                     NO-ERROR.

        /* Caso nenhum agente tenha "startado" */
        IF  NOT AVAILABLE ttprg THEN DO:
            ASSIGN aux_cdpidprg = 0
                   aux_dtmvtolt = ""
                   aux_dshhmmss = ""
                   aux_nrdahora = 0
                   aux_nrminuto = 0
                   aux_nrsegund = 0
                   aux_mxagente = 0
                   aux_horamaxi = ""
                   aux_datamaxi = ""
                   aux_qtagente = 0.
 
            EMPTY TEMP-TABLE ttprg.
            NEXT.
        END.
        
        NEXT.
        
    END.

    DO  TRANSACTION ON ERROR UNDO, LEAVE:

        CREATE tt-tb_Servicos.
        ASSIGN tt-tb_Servicos.CodCooper   = 1 /* Servicos Unificados */
               tt-tb_Servicos.CodServico  = tt-servicos.nr_servico
               tt-tb_Servicos.NomeServico = tt-servicos.nome_servico
               tt-tb_Servicos.HoraAgeSimu = 
                                        (INT(ENTRY(1,aux_horamaxi, ":")) * 3600)
                                      + (INT(ENTRY(2,aux_horamaxi, ":")) * 60)
                                      +  INT(ENTRY(3,aux_horamaxi, ":"))
               tt-tb_Servicos.DataColeta  = DATE(SUBSTR(aux_datamaxi,7,2)
                                                + "/" +
                                                SUBSTR(aux_datamaxi,4,2)
                                                + "/" +
                                                SUBSTR(aux_datamaxi,1,2))
               tt-tb_Servicos.InitAgente  = tt-servicos.init_agentes
               tt-tb_Servicos.MaxAgente   = tt-servicos.max_agentes
               tt-tb_Servicos.MinAgente   = tt-servicos.min_agentes
               tt-tb_Servicos.TotAgeSimu  = aux_mxagente.

    END. /* Fim do DO TRANSACTION */

    ASSIGN aux_cdpidprg = 0
           aux_dtmvtolt = ""
           aux_dshhmmss = ""
           aux_nrdahora = 0
           aux_nrminuto = 0
           aux_nrsegund = 0
           aux_mxagente = 0
           aux_horamaxi = ""
           aux_datamaxi = ""
           aux_qtagente = 0.

    EMPTY TEMP-TABLE ttprg.

END. /* Fim do FOR EACH - tt-servicos */

/* Inicio do Log de Processos */

ASSIGN aux_nmarqlog = "/usr/coop/cecred/salvar/agentes_simultaneos_"
                    + STRING(OS-GETENV("HOST")) + "_" 
                    + STRING(YEAR(TODAY),"9999")
                    + STRING(MONTH(TODAY),"99")
                    + STRING(DAY(TODAY),"99") + ".log".

OUTPUT STREAM str_1 TO VALUE(aux_nmarqlog).

   PUT STREAM str_1
       "CodServico;DataColeta;HoraAgeSimu;InitAgente;MaxAgente;" FORMAT "x(55)"
       "MinAgente;NomeServico;TotAgeSimu;CodCooper;"             FORMAT "x(43)"
       SKIP.

   FOR EACH tt-tb_Servicos:
       PUT STREAM str_1
           tt-tb_Servicos.CodServico   
           ";"                       
           tt-tb_Servicos.DataColeta 
           ";"                       
           STRING(tt-tb_Servicos.HoraAgeSimu,"HH:MM:SS")
           ";"                       
           tt-tb_Servicos.InitAgente
           ";"                       
           tt-tb_Servicos.MaxAgente
           ";"                       
           tt-tb_Servicos.MinAgente
           ";"
           tt-tb_Servicos.NomeServico FORMAT 'x(30)'
           ";"
           tt-tb_Servicos.TotAgeSimu
           ";"
           tt-tb_Servicos.CodCooper
           SKIP.
   END.

OUTPUT STREAM str_1 CLOSE.

