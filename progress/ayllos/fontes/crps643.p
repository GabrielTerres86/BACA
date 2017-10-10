/*..............................................................................

    Programa: fontes/crps643.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Lunelli
    Data    : Maio/2013                       Ultima Atualizacao : 17/08/2017
    
    Dados referente ao programa:
    
    Frequencia : Diario (Batch). 
    Objetivo   : Convenios Sicredi - Descompactação de Extratos do Sicredi.
                                  
    Alteracoes : 26/06/2013 - Ajuste para data anterior e tratamento para
                              .ZIP da CECRED
                            - Adicionado tratamento para relatório crrl655 (Lucas).
                            
                 01/07/2013 - Alteração na permissão dos relatórios para
                              postagem na Intranet (Lucas).
                 
                 13/08/2013 - Correção caminho arquivos (Lucas).
                 
                 28/07/2014 - Tratamento para quebra de página nos arquivos recebidos
                              SD 1563648 (Vanessa Klein).
                 
                 29/03/2016 - Alterado trecho do codigo onde o programa chamava o 
                              imprim_unif.p para que gere relatorio apenas se importou
                              arquivo (Lucas Ranghetti #412518)
                              
                 04/07/2017 - Tratamento para enviar por e-mail os arquivos DE* para 
                              o convenios@cecred (Lucas Ranghetti #679608)
                              
                 17/08/2017 - Alterar o nome do arquivo DI* e OS* pelo dsdircop pois se 
                              usar o nmrescop, para casos que nem da Viacredi AV nao
                              iriamos enviar o arquivo em anexo pelo fato de quebrar o 
                              script pelo espaco entre viacredi e av (Lucas Ranghetti #735360)
..............................................................................*/

DEF STREAM str_1.  /* ARQ. IMPORTAÇÃO COMPACTADO  */
DEF STREAM str_2.  /* CRRL648 - EXTRATO - SICREDI */ 
DEF STREAM str_3.  /* CRRL649 - REL. DE MOVIMENTOS INCONSISTENTES DE DARF - SICREDI */ 
DEF STREAM str_4.  /* CRRL650 - INCONSISTENCIAS DA LEITURA DOS ARQUIVOS DE DEBITOS EFETUADOS (Layout) - SICREDI */ 
DEF STREAM str_5.  /* CRRL651 - REL. DE INCONSISTENCIAS LEIT. ARQ. DEBITOS EFETUADOS (Mvtos.) - SICREDI */
DEF STREAM str_6.  /* CRRL652 - RELATORIO DE ARRECADACOES DE DARF - SICREDI */ 
DEF STREAM str_7.  /* CRRL655 - INCONSISTENCIAS DE ARQUIVOS DE DARF - SICREDI */ 
DEF STREAM str_8.  /* REL. DE CRITICAS DOS ARQUIVOS DE DEBITOS EFETUADOS - SICREDI */ 

{ includes/var_batch.i "NEW" }

DEF  VAR aux_nmarquiv AS    CHAR   FORMAT "x(21)"                     NO-UNDO.
DEF  VAR aux_nmarqped AS    CHAR   FORMAT "x(21)"                     NO-UNDO.
DEF  VAR aux_nmrelsnv AS    CHAR   FORMAT "x(21)"                     NO-UNDO.
DEF  VAR aux_nmarqrel AS    CHAR   FORMAT "x(21)"                     NO-UNDO.
DEF  VAR aux_nmarqzip AS    CHAR   FORMAT "x(21)"                     NO-UNDO.
DEF  VAR aux_nmrelato AS    CHAR   FORMAT "x(21)"                     NO-UNDO.
DEF  VAR aux_nmdirfin AS    CHAR   FORMAT "x(21)"                     NO-UNDO.
DEF  VAR aux_nmarqema AS    CHAR   FORMAT "x(21)"                     NO-UNDO.
DEF  VAR aux_digitmes AS    CHAR   FORMAT "x(01)"                     NO-UNDO.
DEF  VAR aux_dsrellog AS    CHAR                                      NO-UNDO.
DEF  VAR aux_dsanexos AS    CHAR                                      NO-UNDO.
DEF  VAR aux_conteudo AS    CHAR                                      NO-UNDO.
DEF  VAR aux_contador AS    INTE                                      NO-UNDO.
DEF  VAR aux_flgarqui AS    LOGI                                      NO-UNDO.
DEF  VAR aux_dscritic AS    CHAR                                      NO-UNDO.

DEF  VAR aux_nmrellst AS    CHAR   FORMAT "x(21)"                     NO-UNDO.
DEF  VAR aux_nmarqlst AS    CHAR   FORMAT "x(21)"                     NO-UNDO.
    

DEF  VAR h-b1wgen0011 AS    HANDLE                                    NO-UNDO.

/* Mantem flgbatch como FALSE para rodar o programa fora do processo */
ASSIGN glb_flgbatch = FALSE
       glb_cdprogra = "crps643"
       glb_cdempres = 11
       glb_cdcooper = 3
       aux_flgarqui = FALSE. /* Para LOG */

UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")              + 
                        " - "   + STRING(TIME,"HH:MM:SS")            + 
                   " - "   + glb_cdprogra + "' --> '"                + 
                   "Iniciada importacao dos extratos e relatorios "  +
                   "do Sicredi."                                     +
                   " >> /usr/coop/cecred/log/crps643.log").

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF  NOT AVAILABLE crapcop   THEN
    DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")   + 
                            " - "   + STRING(TIME,"HH:MM:SS")      +
                            " - " + glb_cdprogra + "' --> '"       +
                            glb_dscritic                           + 
                            " >> /usr/coop/cecred/log/crps643.log").
         RETURN.
    END.

FIND crapdat WHERE crapdat.cdcooper = glb_cdcooper  NO-LOCK NO-ERROR.
    
IF  NOT AVAIL crapdat THEN
    DO:
        glb_cdcritic = 1.
        RUN fontes/critic.p.
        UNIX SILENT VALUE ("echo " + STRING(TODAY) + " - "              + 
                          STRING(TIME,"HH:MM:SS") + " - "               +
                          glb_cdprogra + "' --> '" + glb_dscritic       +
                          " - Cooperativa: " + STRING(glb_cdcooper)     +
                          " "                                           + 
                          " >> /usr/coop/cecred/log/crps643.log").
        RETURN.
    END.

IF  glb_cdcritic > 0 THEN
    RETURN.

ASSIGN  glb_dtmvtoan = crapdat.dtmvtoan
        glb_dtmvtolt = crapdat.dtmvtolt.

/* Monta digito do Mês para nome do arq */
IF  MONTH(glb_dtmvtoan) = 10 THEN
    ASSIGN aux_digitmes = "O".
ELSE
IF  MONTH(glb_dtmvtoan) = 11 THEN
    ASSIGN aux_digitmes = "N".
ELSE
IF  MONTH(glb_dtmvtoan) = 12 THEN
    ASSIGN aux_digitmes = "D".
ELSE
    ASSIGN aux_digitmes = STRING(MONTH(glb_dtmvtoan),"9").

/* Para cada Cooperativa */
FOR EACH crapcop NO-LOCK.

    /* Zerar anexos e contador */
    ASSIGN aux_dsanexos = ""
           aux_contador = 0
           aux_dsrellog = "".

    IF  crapcop.cdcooper = 3 THEN  /* CECRED */
        ASSIGN aux_nmarqped = SUBSTRING(STRING(crapcop.nrctasic), 1, 4) + 
                              "BC" + STRING(DAY(glb_dtmvtolt), "99") + ".ZIP".
    ELSE 
        ASSIGN aux_nmarqped = SUBSTRING(STRING(crapcop.cdagesic), 1, 4) + 
                              "BC" + STRING(DAY(glb_dtmvtolt), "99") + ".ZIP".

    ASSIGN  aux_nmarquiv = "/usr/connect/sicredi/recebe/" + aux_nmarqped
            aux_nmarqzip = aux_nmarquiv
            aux_nmdirfin = "/micros/financeiro/" + aux_nmarqped.
    
    /* Extrai o arquivo */
    INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
                   NO-ECHO.
    
    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

        IMPORT STREAM str_1 UNFORMATTED aux_nmarquiv.

        ASSIGN aux_dsrellog = ENTRY(6,aux_nmarquiv,"/").

        /* Copiar o arquivo extraído para o dir /micros/financeiro */
        UNIX SILENT VALUE("cp " + aux_nmarquiv + " " + aux_nmdirfin + " 2> /dev/null").

        UNIX SILENT VALUE("zipcecred.pl -silent -extract " + aux_nmarquiv + 
                          " /usr/coop/" + STRING(crapcop.dsdircop) + "/arq").
        
    END.
  
    INPUT STREAM str_1 CLOSE. 

    ASSIGN  aux_nmarqped = "0" + 
                           SUBSTRING(STRING(crapcop.nrctasic), 1, 5) + 
                           "BC.PRN"
            aux_nmarquiv = "/usr/coop/" + STRING(crapcop.dsdircop) +
                           "/arq/" + aux_nmarqped
            aux_nmrelato = "crrl648.lst"
            aux_nmarqrel = "/usr/coop/" + TRIM(crapcop.dsdircop) +
                           "/rl/" + aux_nmrelato
            aux_nmrellst = "crrl648"
            aux_nmarqlst = "/usr/coop/" + TRIM(crapcop.dsdircop) +
                           "/rl/" + aux_nmrellst
            aux_nmrelsnv = "/usr/coop/" + TRIM(crapcop.dsdircop) +
                           "/rlnsv/" + aux_nmrelato.

    /* crrl648 - procura arquivo de extrato Sicredi extraído */
    INPUT STREAM str_2 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
                   NO-ECHO.

    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

        IMPORT STREAM str_2 UNFORMATTED aux_nmarquiv.

        ASSIGN aux_flgarqui = TRUE.  /* Para LOG */

        
        /* Copiar o arquivo extraído para o /rl */
        UNIX SILENT VALUE("cp " + aux_nmarquiv + " " + aux_nmarqrel + " 2> /dev/null").

        /* Copiar o arquivo extraído para o /rlnsv */
        UNIX SILENT VALUE("cp " + aux_nmarquiv + " " + aux_nmrelsnv + " 2> /dev/null").

        /* Elimina o arquivo descompactado do dir /arq */
        UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").

        /* transforma o arquivo DOS para Unix e retira os caracteres DC2 e SI contidos no mesmo a escreve para outro arquivo*/
        UNIX SILENT VALUE("dos2ux " + aux_nmarqrel + " | tr -d '\032\017\022' > " + aux_nmarqlst + "ux.lst 2>/dev/null").

         /* Substitui o CRLF restantes para FF para poder fazer a quebra de página*/ 
        UNIX SILENT VALUE("sed 's/\r$/\f/' " + aux_nmarqlst + "ux.lst >" + aux_nmarqlst + "uxp.lst").
        
        /* Exclui a ultima linha e escreve para o arquivo de origem*/
        UNIX SILENT VALUE("sed '$d' " + aux_nmarqlst + "uxp.lst >"  + aux_nmarqrel + "").

        /* Elimina os arquivos gerados durante o processo
        UNIX SILENT VALUE("rm " + aux_nmarqlst + "ux.lst 2> /dev/null").*/
        UNIX SILENT VALUE("rm " + aux_nmarqlst + "uxp.lst 2> /dev/null").
                  
    END.

    INPUT STREAM str_2 CLOSE.

    /* Mover o arquivo .zip processado para o dir /recebidos */
    UNIX SILENT VALUE("mv " + aux_nmarqzip + " /usr/connect/sicredi/recebidos/ 2> /dev/null").
    

    /* LOG crrl648 */
    IF  aux_flgarqui THEN
        DO:
            UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")    + 
                               " - "   + STRING(TIME,"HH:MM:SS")       +
                               " - "   + glb_cdprogra + "' --> '"      +
                               "Arquivo " + aux_dsrellog               + 
                               " importado com sucesso."               +
                               " >> /usr/coop/cecred/log/crps643.log").
            
            /* Gerar relatorio apenas importou arquivo */
            ASSIGN glb_cdcritic    = 0
                   glb_cdrelato[1] = 648
                   glb_cdempres    = 11
                   glb_nrcopias    = 1
                   glb_nmformul    = "132col"
                   glb_nmarqimp    = aux_nmarqrel.
 
            UNIX SILENT VALUE("chmod 666 " + aux_nmrelsnv + " 2>/dev/null").
            UNIX SILENT VALUE("chmod 666 " + glb_nmarqimp + " 2>/dev/null").
            RUN fontes/imprim_unif.p (INPUT crapcop.cdcooper).

            ASSIGN aux_flgarqui = FALSE.
        END.
    
                             
    /* crrl649 - REL. DE MOVIMENTOS INCONSISTENTES DE DARF - SICREDI */
    ASSIGN  aux_nmarqped = "DI" + SUBSTRING(STRING(crapcop.cdagesic), 1, 4) +
                           "*." + STRING(DAY(glb_dtmvtoan), "99") + aux_digitmes
            aux_nmarquiv = "/usr/connect/sicredi/recebe/" + aux_nmarqped
            aux_dsrellog = ""
            aux_contador = 1.

    RUN sistema/generico/procedures/b1wgen0011.p
              PERSISTENT SET h-b1wgen0011.

    INPUT STREAM str_3 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
                   NO-ECHO.

    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

        IMPORT STREAM str_3 UNFORMATTED aux_nmarquiv.

        /* Incrementa contador para múltiplos arquivos */
        ASSIGN aux_contador = aux_contador + 1
               aux_nmarqema = aux_nmarqema + " " + ENTRY(6,aux_nmarquiv,"/")
               aux_nmrelato = "crrl649_" + STRING(aux_contador) +
                              "_" + CAPS(crapcop.dsdircop) + ".lst"
               aux_nmarqrel = "/usr/coop/cecred" +
                              "/rl/" + aux_nmrelato
               aux_nmrelsnv = "/usr/coop/cecred" +
                              "/rlnsv/" + aux_nmrelato
               aux_dsrellog = aux_dsrellog + " " + ENTRY(6,aux_nmarquiv,"/").

        /* Copiar o arq para o dir /rl com a nomenclatura de crrl649 */
        UNIX SILENT VALUE("cp " + aux_nmarquiv + " " + aux_nmarqrel + " 2> /dev/null").

        /* Copiar o arquivo para o dir /rlnsv */
        UNIX SILENT VALUE("cp " + aux_nmarquiv + " " + aux_nmrelsnv + " 2> /dev/null").

        /* Mover o arquivo para o dir /recebidos */
        UNIX SILENT VALUE("mv " + aux_nmarquiv + " /usr/connect/sicredi/recebidos/ 2> /dev/null").

        ASSIGN glb_cdcritic    = 0
               glb_cdrelato[1] = 649
               glb_cdempres    = 11
               glb_nrcopias    = 1
               glb_nmformul    = "132col"
               glb_nmarqimp    = "rl/" + aux_nmrelato.

        UNIX SILENT VALUE("chmod 666 " + aux_nmrelsnv + " 2>/dev/null").
        UNIX SILENT VALUE("chmod 666 " + glb_nmarqimp + " 2>/dev/null").
        RUN fontes/imprim.p.

        ASSIGN aux_dsanexos = aux_dsanexos + aux_nmrelato + ";"
               aux_flgarqui = TRUE. /* Para LOG */

        RUN converte_arquivo IN h-b1wgen0011 (INPUT glb_cdcooper,
                                              INPUT aux_nmarqrel,
                                              INPUT aux_nmrelato).

    END.

    DELETE PROCEDURE h-b1wgen0011.

    INPUT STREAM str_3 CLOSE.

    IF  aux_dsanexos <> "" THEN
        DO:
            ASSIGN aux_conteudo = "Em anexo o(s) relatório(s) contendo as " +
                                  "criticas de Darfs. " + aux_nmarqema + ".".

            /* envio de email do crrl649 */ 
            RUN sistema/generico/procedures/b1wgen0011.p
                PERSISTENT SET h-b1wgen0011.

            RUN enviar_email_completo IN h-b1wgen0011
                                  (INPUT glb_cdcooper,
                                   INPUT glb_cdprogra,
                                   INPUT "cpd@cecred.coop.br",
                                   INPUT "convenios@cecred.coop.br",
                                   INPUT "RELATORIO DE CRITICAS DE DARFS - DI",
                                   INPUT "",
                                   INPUT aux_dsanexos,
                                   INPUT aux_conteudo,
                                   INPUT FALSE).

            DELETE PROCEDURE h-b1wgen0011.
        END.

    /* LOG crrl649 */
    IF  aux_flgarqui THEN
        DO:
            UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")     +   
                               " - "   + STRING(TIME,"HH:MM:SS")        +   
                               " - "   + glb_cdprogra + "' --> '"       +   
                               "Arquivo " + aux_dsrellog                +   
                               " importado com sucesso."                +   
                               " >> /usr/coop/cecred/log/crps643.log"). 

            ASSIGN aux_flgarqui = FALSE.
        END.



    /* crrl650 - INCONSISTENCIAS DA LEITURA DOS ARQUIVOS DE DEBITOS EFETUADOS - SICREDI */
    ASSIGN  aux_dsanexos = ""
            aux_nmarqema = ""
            aux_dsrellog = ""
            aux_contador = 0
            aux_nmarqped = "OS" + SUBSTRING(STRING(crapcop.cdagesic), 1, 4) +
                           "*." + STRING(DAY(glb_dtmvtoan), "99") + aux_digitmes
            aux_nmarquiv = "/usr/connect/sicredi/recebe/" + aux_nmarqped.

    RUN sistema/generico/procedures/b1wgen0011.p
              PERSISTENT SET h-b1wgen0011.

    INPUT STREAM str_4 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
                   NO-ECHO.

    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

        IMPORT STREAM str_4 UNFORMATTED aux_nmarquiv.

        /* Incrementa contador para múltiplos arquivos */
        ASSIGN aux_contador = aux_contador + 1
               aux_nmarqema = aux_nmarqema + " " + ENTRY(6,aux_nmarquiv,"/")
               aux_nmrelato = "crrl650_" + STRING(aux_contador) +
                              "_" + CAPS(crapcop.dsdircop) + ".lst"
               aux_nmarqrel = "/usr/coop/cecred" +
                              "/rl/" + aux_nmrelato
               aux_nmrelsnv = "/usr/coop/cecred" +
                              "/rlnsv/" + aux_nmrelato
               aux_dsrellog = aux_dsrellog + " " + ENTRY(6,aux_nmarquiv,"/").

        /* Copiar o arq para o dir /rl com a nomenclatura de crrl650 */
        UNIX SILENT VALUE("cp " + aux_nmarquiv + " " + aux_nmarqrel + " 2> /dev/null").

        /* Copiar o arquivo para o dir /rlnsv */
        UNIX SILENT VALUE("cp " + aux_nmarquiv + " " + aux_nmrelsnv + " 2> /dev/null").

        /* Mover o arquivo para o dir /recebidos */
        UNIX SILENT VALUE("mv " + aux_nmarquiv + " /usr/connect/sicredi/recebidos/ 2> /dev/null").

        ASSIGN glb_cdcritic    = 0
               glb_cdrelato[1] = 650
               glb_cdempres    = 11
               glb_nrcopias    = 1
               glb_nmformul    = "132col"
               glb_nmarqimp    = "rl/" + aux_nmrelato.

        UNIX SILENT VALUE("chmod 666 " + aux_nmrelsnv + " 2>/dev/null").
        UNIX SILENT VALUE("chmod 666 " + glb_nmarqimp + " 2>/dev/null").
        RUN fontes/imprim.p.

        ASSIGN aux_dsanexos = aux_dsanexos + aux_nmrelato + ";"
               aux_flgarqui = TRUE. /* Para LOG */

        RUN converte_arquivo IN h-b1wgen0011 (INPUT glb_cdcooper,
                                              INPUT aux_nmarqrel,
                                              INPUT aux_nmrelato).
    END.

    DELETE PROCEDURE h-b1wgen0011.

    INPUT STREAM str_4 CLOSE.

    IF  aux_dsanexos <> "" THEN
        DO:
            ASSIGN aux_conteudo = "Em anexo o(s) relatório(s) contendo as "   +
                                  "inconsistencias da leitura dos arquivos "  +
                                  "de debidos efetuados. " + aux_nmarqema + ".".

            /* envio de email do crrl650 */ 
            RUN sistema/generico/procedures/b1wgen0011.p
                PERSISTENT SET h-b1wgen0011.

            RUN enviar_email_completo IN h-b1wgen0011
                                  (INPUT glb_cdcooper,
                                   INPUT glb_cdprogra,
                                   INPUT "cpd@cecred.coop.br",
                                   INPUT "convenios@cecred.coop.br",
                                   INPUT "INCONSISTENCIAS DOS ARQUIVOS DE DEBITOS EFETUADOS - OS",
                                   INPUT "",
                                   INPUT aux_dsanexos,
                                   INPUT aux_conteudo,
                                   INPUT FALSE).

            DELETE PROCEDURE h-b1wgen0011.
        END.

    /* LOG crrl650 */
    IF  aux_flgarqui THEN
        DO:
            UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")     +   
                               " - "   + STRING(TIME,"HH:MM:SS")        +   
                               " - "   + glb_cdprogra + "' --> '"       +   
                               "Arquivo " + aux_dsrellog                +   
                               " importado com sucesso."                +   
                               " >> /usr/coop/cecred/log/crps643.log"). 

            ASSIGN aux_flgarqui = FALSE.
        END.    

    /* REL. DE CRITICAS DOS ARQUIVOS DE DEBITOS EFETUADOS - SICREDI  */    
    ASSIGN  aux_nmarqped = "DE" + SUBSTRING(STRING(crapcop.cdagesic),1,4) + "*"
            aux_nmarquiv = "/usr/connect/sicredi/recebe/" + aux_nmarqped
            aux_dsrellog = ""
            aux_contador = 1.

    RUN sistema/generico/procedures/b1wgen0011.p
              PERSISTENT SET h-b1wgen0011.

    INPUT STREAM str_8 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
                   NO-ECHO.

    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

        IMPORT STREAM str_8 UNFORMATTED aux_nmarquiv.

        /* Incrementa contador para múltiplos arquivos */
        ASSIGN aux_contador = aux_contador + 1
               aux_nmarqema = aux_nmarqema + "/usr/connect/sicredi/recebidos/" + 
                                             ENTRY(6,aux_nmarquiv,"/") + ";"
               aux_dsrellog = aux_dsrellog + " " + ENTRY(6,aux_nmarquiv,"/")
               aux_flgarqui = TRUE. /* Para LOG */
               
        /* Mover o arquivo para o dir /recebidos */
        UNIX SILENT VALUE("mv " + aux_nmarquiv + " /usr/connect/sicredi/recebidos/ 2> /dev/null").

    END.

    DELETE PROCEDURE h-b1wgen0011.

    INPUT STREAM str_8 CLOSE.

    IF  aux_nmarqema <> "" THEN
        DO:
            ASSIGN aux_conteudo = "Em anexo o(s) arquivo(s) contendo as " +
                                  "criticas dos debitos efetuados(SICREDI). " + aux_dsrellog + ".".

            RUN sistema/generico/procedures/b1wgen0011.p
                PERSISTENT SET h-b1wgen0011.

            RUN solicita_email_oracle IN h-b1wgen0011
                                   ( INPUT glb_cdcooper /* par_cdcooper */
                                    ,INPUT glb_cdprogra /* par_cdprogra */
                                    ,INPUT "convenios@cecred.coop.br" 
                                    ,INPUT "RELATORIO DE CRITICAS DEBITOS EFETUADOS - DE" /* par_des_assunto */
                                    ,INPUT aux_conteudo /* par_des_corpo */
                                    ,INPUT aux_nmarqema /* par_des_anexo */
                                    ,INPUT "N" /* par_flg_remove_anex */
                                    ,INPUT "N" /* par_flg_remete_coop */
                                    ,INPUT "" /* par_des_nome_reply */
                                    ,INPUT "" /* par_des_email_reply */
                                    ,INPUT "N" /* par_flg_log_batch */
                                    ,INPUT "S" /* par_flg_enviar */
                                    ,OUTPUT aux_dscritic). /* par_des_erro */

            IF  aux_dscritic <> "" THEN
                DO:
                    UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999")     +   
                                      " - "   + STRING(TIME,"HH:MM:SS")        +   
                                      " - "   + glb_cdprogra + "' --> '"       +   
                                      "Arquivo " + aux_dsrellog                +   
                                      " Erro ao enviar e-mail: "               + 
                                      aux_dscritic + " >> /usr/coop/cecred/log/crps643.log").
                    ASSIGN aux_dscritic = ""
                           aux_flgarqui = FALSE.
                END.

            DELETE PROCEDURE h-b1wgen0011.
        END.

   
    IF  aux_flgarqui THEN
        DO:
            UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")     +   
                               " - "   + STRING(TIME,"HH:MM:SS")        +   
                               " - "   + glb_cdprogra + "' --> '"       +   
                               "Arquivo " + aux_dsrellog                +   
                               " importado com sucesso."                +   
                               " >> /usr/coop/cecred/log/crps643.log"). 

            ASSIGN aux_flgarqui = FALSE.
            
        END.    

END. /* FIM crapcop */



/* crrl651 - REL. DE INCONSISTENCIAS LEIT. ARQ. DEBITOS EFETUADOS (Mvtos.) - SICREDI */
ASSIGN  aux_dsanexos = ""
        aux_dsrellog = ""
        aux_contador = 0
        aux_nmarqped = "BO019900." + STRING(DAY(glb_dtmvtoan), "99") + aux_digitmes
        aux_nmarquiv = "/usr/connect/sicredi/recebe/" + aux_nmarqped.

RUN sistema/generico/procedures/b1wgen0011.p
          PERSISTENT SET h-b1wgen0011.

INPUT STREAM str_5 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
               NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

    IMPORT STREAM str_5 UNFORMATTED aux_nmarquiv.

    ASSIGN aux_nmrelato = "crrl651.lst"
           aux_nmarqrel = "/usr/coop/cecred" + "/rl/" + aux_nmrelato
           aux_nmrelsnv = "/usr/coop/cecred" + "/rlnsv/" + aux_nmrelato
           aux_dsrellog = aux_dsrellog + " " + ENTRY(6,aux_nmarquiv,"/").

    /* Copiar o arq para o dir /rl com a nomenclatura de crrl651 */
    UNIX SILENT VALUE("cp " + aux_nmarquiv + " " + aux_nmarqrel + " 2> /dev/null").

    /* Copiar o arquivo para o dir /rlnsv */
    UNIX SILENT VALUE("cp " + aux_nmarquiv + " " + aux_nmrelsnv + " 2> /dev/null").

    /* Move o arquivo para o dir /recebidos */
    UNIX SILENT VALUE("mv " + aux_nmarquiv + " /usr/connect/sicredi/recebidos/ 2> /dev/null").

    ASSIGN aux_dsanexos = aux_dsanexos + aux_nmrelato + ";"
           aux_flgarqui = TRUE. /* Para LOG */

    RUN converte_arquivo IN h-b1wgen0011 (INPUT glb_cdcooper,
                                          INPUT aux_nmarqrel,
                                          INPUT aux_nmrelato).

    ASSIGN glb_cdcritic    = 0
           glb_cdrelato[1] = 651
           glb_cdempres    = 11
           glb_nrcopias    = 1
           glb_nmformul    = "132col"
           glb_nmarqimp    = "rl/" + aux_nmrelato.
    
    UNIX SILENT VALUE("chmod 666 " + aux_nmrelsnv + " 2>/dev/null").
    UNIX SILENT VALUE("chmod 666 " + glb_nmarqimp + " 2>/dev/null").
    RUN fontes/imprim.p.
    
END.

DELETE PROCEDURE h-b1wgen0011.

INPUT STREAM str_5 CLOSE.

IF  aux_dsanexos <> "" THEN
    DO:
        ASSIGN aux_conteudo = "Em anexo o(s) relatório(s) contendo as "   +
                              "inconsistencias de movimentos dos arquivos "  +
                              "de debidos efetuados. " + aux_nmarqped + ".".

        /* envio de email do crrl651 */ 
        RUN sistema/generico/procedures/b1wgen0011.p
            PERSISTENT SET h-b1wgen0011.

        RUN enviar_email_completo IN h-b1wgen0011
                              (INPUT glb_cdcooper,
                               INPUT glb_cdprogra,
                               INPUT "cpd@cecred.coop.br",
                               INPUT "convenios@cecred.coop.br",
                               INPUT "INCONSISTENCIAS DE DEBITOS EFETUADOS - BO",
                               INPUT "",
                               INPUT aux_dsanexos,
                               INPUT aux_conteudo,
                               INPUT FALSE).

        DELETE PROCEDURE h-b1wgen0011.
    END.

/* LOG crrl651 */
IF  aux_flgarqui THEN
    DO:
        UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")     +   
                           " - "   + STRING(TIME,"HH:MM:SS")        +   
                           " - "   + glb_cdprogra + "' --> '"       +   
                           "Arquivo " + aux_dsrellog                +   
                           " importado com sucesso."                +   
                           " >> /usr/coop/cecred/log/crps643.log"). 

        ASSIGN aux_flgarqui = FALSE.
    END.




/* crrl652 - RELATORIO DE ARRECADACOES DE DARF - SICREDI */
ASSIGN  aux_dsanexos = ""
        aux_dsrellog = ""
        aux_contador = 0
        aux_nmarqped = "DARF" + aux_digitmes + 
                       STRING(DAY(glb_dtmvtoan), "99") + ".TXT"
        aux_nmarquiv = "/usr/connect/sicredi/recebe/" + aux_nmarqped.

INPUT STREAM str_6 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
               NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

    IMPORT STREAM str_6 UNFORMATTED aux_nmarquiv.

    ASSIGN aux_nmrelato = "crrl652.lst"
           aux_nmarqrel = "/usr/coop/cecred/rl/"    + aux_nmrelato
           aux_nmrelsnv = "/usr/coop/cecred/rlnsv/" + aux_nmrelato
           aux_nmdirfin = "/micros/financeiro/" + aux_nmarqped
           aux_dsrellog = aux_dsrellog + " " + ENTRY(6,aux_nmarquiv,"/")
           aux_flgarqui = TRUE. /* Para LOG */

    /* Copiar o arquivo para o dir /micros/financeiro */
    UNIX SILENT VALUE("cp " + aux_nmarquiv + " " + aux_nmdirfin + " 2> /dev/null").

    /* Copiar o arq para o dir /rl com a nomenclatura de crrl652 */
    UNIX SILENT VALUE("cp " + aux_nmarquiv + " " + aux_nmarqrel + " 2> /dev/null").

    /* Copiar o arquivo para o dir /rlnsv */
    UNIX SILENT VALUE("cp " + aux_nmarquiv + " " + aux_nmrelsnv + " 2> /dev/null").

    /* Mover o arquivo para o dir /recebidos */
    UNIX SILENT VALUE("mv " + aux_nmarquiv + " /usr/connect/sicredi/recebidos/ 2> /dev/null").

    ASSIGN glb_cdcritic    = 0
           glb_cdrelato[1] = 652
           glb_cdempres    = 11
           glb_nrcopias    = 1
           glb_nmformul    = "132col"
           glb_nmarqimp    = "rl/" + aux_nmrelato.
    
    UNIX SILENT VALUE("chmod 666 " + aux_nmrelsnv + " 2>/dev/null").
    UNIX SILENT VALUE("chmod 666 " + glb_nmarqimp + " 2>/dev/null").
    RUN fontes/imprim.p.

END.

INPUT STREAM str_6 CLOSE.

/* LOG crrl652 */
IF  aux_flgarqui THEN
    DO:
        UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")     +   
                           " - "   + STRING(TIME,"HH:MM:SS")        +   
                           " - "   + glb_cdprogra + "' --> '"       +   
                           "Arquivo " + aux_dsrellog                +   
                           " importado com sucesso."                +   
                           " >> /usr/coop/cecred/log/crps643.log"). 

        ASSIGN aux_flgarqui = FALSE.
    END.



/* crrl655 - INCONSISTENCIAS DE ARQUIVOS DE DARF - SICREDI */
ASSIGN  aux_dsanexos = ""
        aux_dsrellog = ""
        aux_contador = 0
        aux_nmarqped = "OQ019900." + STRING(DAY(glb_dtmvtoan), "99") + aux_digitmes
        aux_nmarquiv = "/usr/connect/sicredi/recebe/" + aux_nmarqped.

RUN sistema/generico/procedures/b1wgen0011.p
          PERSISTENT SET h-b1wgen0011.

INPUT STREAM str_7 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
               NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

    IMPORT STREAM str_7 UNFORMATTED aux_nmarquiv.

    ASSIGN aux_nmrelato = "crrl655.lst"
           aux_nmarqrel = "/usr/coop/cecred" + "/rl/" + aux_nmrelato
           aux_nmrelsnv = "/usr/coop/cecred" + "/rlnsv/" + aux_nmrelato
           aux_dsrellog = aux_dsrellog + " " + ENTRY(6,aux_nmarquiv,"/").

    /* Copiar o arq para o dir /rl com a nomenclatura de crrl655 */
    UNIX SILENT VALUE("cp " + aux_nmarquiv + " " + aux_nmarqrel + " 2> /dev/null").

    /* Copiar o arquivo para o dir /rlnsv */
    UNIX SILENT VALUE("cp " + aux_nmarquiv + " " + aux_nmrelsnv + " 2> /dev/null").

    /* Move o arquivo para o dir /recebidos */
    UNIX SILENT VALUE("mv " + aux_nmarquiv + " /usr/connect/sicredi/recebidos/ 2> /dev/null").
    
    ASSIGN aux_dsanexos = aux_dsanexos + aux_nmrelato + ";"
           aux_flgarqui = TRUE. /* Para LOG */

    RUN converte_arquivo IN h-b1wgen0011 (INPUT glb_cdcooper,
                                          INPUT aux_nmarqrel,
                                          INPUT aux_nmrelato).

    ASSIGN glb_cdcritic    = 0
           glb_cdrelato[1] = 655
           glb_cdempres    = 11
           glb_nrcopias    = 1
           glb_nmformul    = "132col"
           glb_nmarqimp    = "rl/" + aux_nmrelato.
    
    UNIX SILENT VALUE("chmod 666 " + aux_nmrelsnv + " 2>/dev/null").
    UNIX SILENT VALUE("chmod 666 " + glb_nmarqimp + " 2>/dev/null").
    RUN fontes/imprim.p.

END.

DELETE PROCEDURE h-b1wgen0011.

INPUT STREAM str_7 CLOSE.

IF  aux_dsanexos <> "" THEN
    DO:
        ASSIGN aux_conteudo = "Em anexo o(s) relatório(s) contendo as "   +
                              "inconsistencias arquivos de DARFs. " + aux_nmarqped + ".".

        /* envio de email do crrl655 */ 
        RUN sistema/generico/procedures/b1wgen0011.p
            PERSISTENT SET h-b1wgen0011.

        RUN enviar_email_completo IN h-b1wgen0011
                              (INPUT glb_cdcooper,
                               INPUT glb_cdprogra,
                               INPUT "cpd@cecred.coop.br",
                               INPUT "convenios@cecred.coop.br",
                               INPUT "RELATORIO DE CRITICAS DE ARQUIVOS DE DARFS - OQ",
                               INPUT "",
                               INPUT aux_dsanexos,
                               INPUT aux_conteudo,
                               INPUT FALSE).

        DELETE PROCEDURE h-b1wgen0011.
    END.

/* LOG crrl655 */
IF  aux_flgarqui THEN
    DO:
        UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")     +   
                           " - "   + STRING(TIME,"HH:MM:SS")        +   
                           " - "   + glb_cdprogra + "' --> '"       +   
                           "Arquivo " + aux_dsrellog                +   
                           " importado com sucesso."                +   
                           " >> /usr/coop/cecred/log/crps643.log"). 

        ASSIGN aux_flgarqui = FALSE.
    END.

/* FIM RELATORIOS */

UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")    + 
                   " - "   + STRING(TIME,"HH:MM:SS")       + 
                   " - "   + glb_cdprogra + "' --> '"      + 
                   "Finalizada importacao dos extratos e"  +
                   " relatorios do Sicredi."               +
                   " >> /usr/coop/cecred/log/crps643.log"). 

/* FIM crps643.p */


