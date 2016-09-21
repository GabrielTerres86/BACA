/*..............................................................................

   Programa: fontes/crps562.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Marco/2010                        Ultima atualizacao: 10/12/2014

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Fonte baseado no crps471
               Tratar arquivo retorno CECRED de CONTRA-ORDEM.
               Emite relatorio crrl551.

   Alteracoes: 05/04/2010 - Alterado para processar todas cooperativas, nao
                            mais por cooperativa Singular (Guilherme/Supero)
                            
               01/06/2010 - Acertos gerais (Guilherme).
               
               06/07/2010 - Alterar nomenclatura dos arquivos (Guilherme).
               
               16/09/2010 - Utilizar o imprim_unif (Guilherme).

               02/08/2012 - Ajuste do format no campo nmrescop (David Kruger).
               
               28/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               06/11/2013 - Alterado totalizador de PAs de 99 para 999.
                            (Reinert)     
                            
               20/06/2014 - Corrigida utilizacao do codigo da cooperativa
                            no arquivo de LOG (Diego).
               
               10/12/2014 - Ajustes incorporação credimilsul/concredi
                            verificar se conta cheque é uma conta migrada
                            e buscar crapcch pelo numero da conta do cheque
                            (Odirlei/AMcom)                
                                                          
..............................................................................*/

{ includes/var_batch.i }

DEF   VAR b1wgen0011   AS HANDLE                                     NO-UNDO.

DEF STREAM str_1.
DEF STREAM str_2.
DEF STREAM str_3. /* arquivo anexo para enviar via email */

DEF BUFFER crabcch FOR crapcch.
DEF BUFFER crabtab FOR craptab.

DEF TEMP-TABLE cratrej                                                  NO-UNDO
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD tpcomand AS CHAR
    FIELD nrcpfcgc AS DECI
    FIELD nmprimtl AS CHAR
    FIELD nrchqini AS INTE
    FIELD nrchqfim AS INTE
    FIELD dsmotivo AS CHAR
    FIELD vlcheque AS DECI
    FIELD dtocorre AS DATE    
    FIELD cdderros AS CHAR.
    
DEF TEMP-TABLE crawarq                                                  NO-UNDO
    FIELD nmarquiv AS CHAR
    FIELD nrsequen AS INTEGER
    INDEX crawarq1 AS PRIMARY
          nmarquiv nrsequen.

DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_nrchqini AS INTE                                           NO-UNDO.
DEF VAR aux_nrchqfim AS INTE                                           NO-UNDO.
DEF VAR aux_nrsequen AS INTE                                           NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_tpcomand AS INTE                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.
DEF VAR aux_qtderros AS INTE                                           NO-UNDO.
DEF VAR aux_cddoerro AS INTE                                           NO-UNDO.
DEF VAR aux_nrposica AS INTE                                           NO-UNDO.

DEF VAR aux_nmarqrel AS CHAR                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_dsmsglog AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdoerro AS CHAR                                           NO-UNDO.
DEF VAR aux_cdderros AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_setlinha AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqdat AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqlog AS CHAR                                           NO-UNDO.
DEF VAR aux_cdmotivo AS CHAR                                           NO-UNDO.
DEF VAR aux_cdagectl LIKE crapcop.cdagectl                             NO-UNDO.

DEF VAR aux_dtocorre AS DATE                                           NO-UNDO.
DEF VAR aux_dscooper AS CHAR                                           NO-UNDO.

DEF VAR aux_flgfirst AS LOGI                                           NO-UNDO.
DEF VAR aux_flgrejei AS LOGI                                           NO-UNDO.

DEF VAR aux_nrcpfcgc AS DECI                                           NO-UNDO.
DEF VAR aux_vlcheque AS DECI                                           NO-UNDO.

DEF VAR rel_nrmodulo AS INTE    FORMAT "9"                             NO-UNDO.

DEF VAR rel_nmempres AS CHAR    FORMAT "x(15)"                         NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5                NO-UNDO.

DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                     INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]                NO-UNDO.

FORM
    cratrej.nrdconta  AT  1  FORMAT "zzzz,zzz,z"      NO-LABEL
    cratrej.nmprimtl  AT 12  FORMAT "x(30)"           NO-LABEL
    cratrej.nrchqini  AT 44  FORMAT "999999"          NO-LABEL
    cratrej.nrchqfim  AT 52  FORMAT "999999"          NO-LABEL
    cratrej.tpcomand  AT 59  FORMAT "x(8)"            NO-LABEL
    cratrej.dtocorre  AT 68  FORMAT "99/99/9999"      NO-LABEL
    aux_dsdoerro      AT 79  FORMAT "x(50)"           NO-LABEL
    WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_rejeitados.
    
FORM    
    "CONTA/DV"                 AT  3  
    "NOME"                     AT 12
    "CHQ.INI"                  AT 43
    "CHQ.FIM"                  AT 51
    "COMANDO"                  AT 59
    "DATA"                     AT 68
    "DESCRICAO DO(S) ERRO(S)"  AT 79
    WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_cab_rejeitados.
 
FORM 
    aux_setlinha   FORMAT "x(194)"
    WITH NO-BOX NO-LABELS WIDTH 194 FRAME f_linha.
 
ASSIGN glb_cdprogra = "crps562"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0  THEN
    RETURN.

ASSIGN aux_nmarqlog = "/usr/coop/cecred/log/prcctl_" + 
                      STRING(YEAR(glb_dtmvtolt),"9999") + 
                      STRING(MONTH(glb_dtmvtolt),"99") + 
                      STRING(DAY(glb_dtmvtolt),"99") + ".log"
       aux_nmarquiv = "/micros/cecred/serasa/SER00005.*"
       aux_dscooper = "/usr/coop/cecred/"
       aux_flgfirst = TRUE
       aux_contador = 0.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF  NOT AVAILABLE crapcop  THEN
    DO:
        ASSIGN glb_cdcritic = 651.
        RUN fontes/critic.p.

        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          glb_dscritic + " >> " + aux_nmarqlog).

        RUN fontes/fimprg.p.
        RETURN.
    END.

EMPTY TEMP-TABLE cratrej.
EMPTY TEMP-TABLE crawarq.  

INPUT STREAM str_1 
      THROUGH VALUE("ls " + aux_nmarquiv + " 2> /dev/null") NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

    SET STREAM str_1 aux_nmarquiv FORMAT "x(60)" .

    ASSIGN aux_contador = aux_contador + 1
           aux_nmarqdat = aux_dscooper + "integra/SER00005" + 
                          STRING(DAY(glb_dtmvtolt),"99") +
                          STRING(MONTH(glb_dtmvtolt),"99") +
                          STRING(YEAR(glb_dtmvtolt),"9999") +
                          STRING(aux_contador,"999").
    
    UNIX SILENT VALUE("dos2ux " + aux_nmarquiv + " > " +
                      aux_nmarqdat + " 2> /dev/null").
    
    UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").
    
    UNIX SILENT VALUE("quoter " + aux_nmarqdat + " > " + 
                      aux_nmarqdat + ".q 2> /dev/null").

    INPUT STREAM str_2 FROM VALUE(aux_nmarqdat + ".q") NO-ECHO.

    SET STREAM str_2 aux_setlinha WITH FRAME f_linha.

    CREATE crawarq.
    ASSIGN crawarq.nrsequen = INT(SUBSTR(aux_setlinha,28,4))
           crawarq.nmarquiv = aux_nmarqdat
           aux_flgfirst     = FALSE.

    INPUT STREAM str_2 CLOSE.

END. /*** Fim do DO WHILE TRUE ***/

INPUT STREAM str_1 CLOSE.

IF  aux_flgfirst  THEN DO: 
    ASSIGN glb_cdcritic = 182.
    RUN fontes/critic.p.

    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - Coop:" + STRING(crapcop.cdcooper,"99") +
                      " - Processar: CONTRA-ORDEM" +
                      " - SER00005 - " + glb_cdprogra + "' --> '"  +
                      glb_dscritic + " >> " + aux_nmarqlog).

    NEXT.
END.

FIND crabtab WHERE crabtab.cdcooper = crapcop.cdcooper AND
                   crabtab.nmsistem = "CRED"           AND
                   crabtab.tptabela = "GENERI"         AND
                   crabtab.cdempres = 00               AND
                   crabtab.cdacesso = "NRARQRTSER"     AND
                   crabtab.tpregist = 002
                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT. 

IF  NOT AVAILABLE crabtab  THEN
    DO:
        ASSIGN glb_cdcritic = 55.
        RUN fontes/critic.p.

        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - Coop:" + STRING(crapcop.cdcooper,"99") +
                          " - Processar: CONTRA-ORDEM" +
                          " - " + glb_cdprogra + "' --> '"  +
                          glb_dscritic + " >> " + aux_nmarqlog).
        NEXT.
    END.    

ASSIGN aux_nrsequen = INT(SUBSTR(crabtab.dstextab,01,05)).

FIND FIRST craptab WHERE craptab.cdcooper = 3        AND
                         craptab.nmsistem = "CRED"   AND
                         craptab.tptabela = "GENERI" AND
                         craptab.cdempres = 00       AND
                         craptab.cdacesso = "CDERROSSER" NO-LOCK NO-ERROR.

IF  NOT AVAILABLE craptab  THEN
    DO:
        ASSIGN glb_cdcritic = 886.
        RUN fontes/critic.p.

        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - Coop:" + STRING(crapcop.cdcooper,"99") +
                          " - Processar: CONTRA-ORDEM" +
                          " - " + glb_cdprogra + "' --> '"  +
                          glb_dscritic + " >> " + aux_nmarqlog).

        NEXT.
    END.    

/* Valida sequencia do arquivo */
FOR EACH crawarq BREAK BY crawarq.nrsequen:

    IF  FIRST-OF(crawarq.nrsequen)  THEN DO:

        IF  crawarq.nrsequen <> aux_nrsequen  THEN DO:
            
            ASSIGN glb_cdcritic = 476.
            RUN fontes/critic.p.

            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - Coop:" + STRING(crapcop.cdcooper,"99") +
                              " - Processar: CONTRA-ORDEM" +
                              " - SER00005 - " +
                              glb_cdprogra + "' --> '"  +
                              glb_dscritic + " SEQ.SERASA " + 
                              STRING(crawarq.nrsequen) + 
                              " " + "SEQ.COOP " + 
                              STRING(aux_nrsequen) + " - " +
                              "integra/err" + 
                              SUBSTR(crawarq.nmarquiv,
                                     R-INDEX(crawarq.nmarquiv,"/") + 1,
                                     LENGTH(crawarq.nmarquiv)) +
                              " >> " + aux_nmarqlog).

            ASSIGN aux_nmarqimp = aux_dscooper + "arq/" +
                                  glb_cdprogra
                                  + "_ANEXO" + STRING(TIME).
                   
            OUTPUT STREAM str_3 TO VALUE(aux_nmarqimp).

            PUT STREAM str_3 "ERRO DE SEQUENCIA no arquivo "
                             "SER00005 "
                             "pela cooperativa "
                             crapcop.nmrescop FORMAT "x(20)"
                             " / DIA: "
                             STRING(glb_dtmvtolt,"99/99/9999")
                             FORMAT "x(17)"
                             SKIP.

            OUTPUT STREAM str_3 CLOSE.

            /* Move para diretorio converte para utilizar na BO */
            UNIX SILENT VALUE
                 ("cp " + aux_nmarqimp + " " + aux_dscooper
                  + "/converte" + " 2> /dev/null").

            /* envio de email */ 
            RUN sistema/generico/procedures/b1wgen0011.p
                PERSISTENT SET b1wgen0011.

            RUN enviar_email IN b1wgen0011
                               (INPUT crapcop.cdcooper,
                                INPUT glb_cdprogra,
                                INPUT "willian@cecred.coop.br," +
                                      "compe@cecred.coop.br",
                                INPUT '"ERRO DE SEQUENCIA - "' +
                                      '"SER00005 - "' +
                                      crapcop.nmrescop,
                                INPUT SUBSTRING(aux_nmarqimp, 5),
                                INPUT FALSE).

            DELETE PROCEDURE b1wgen0011.

            /* remover arquivo criado de anexo */
            UNIX SILENT VALUE("rm " + aux_nmarqimp +
                              " 2>/dev/null").

        END.
    END.

    IF  glb_cdcritic > 0  THEN
        DO:
            ASSIGN aux_nmarquiv = aux_dscooper + "integra/err" +
                                  SUBSTR(crawarq.nmarquiv,
                                         R-INDEX(crawarq.nmarquiv,"/") + 1,
                                         LENGTH(crawarq.nmarquiv)).


            UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " +
                              SUBSTR(crawarq.nmarquiv,
                                     R-INDEX(crawarq.nmarquiv,"/") + 1,
                                     LENGTH(crawarq.nmarquiv))).

            UNIX SILENT VALUE("rm " + crawarq.nmarquiv + 
                              ".q 2> /dev/null").

            IF  LAST-OF(crawarq.nrsequen)  THEN
                LEAVE.
        END.

END. /*** Fim do FOR EACH crawarq ***/

IF  glb_cdcritic > 0  THEN
    NEXT.

ASSIGN SUBSTR(crabtab.dstextab,1,5) = STRING(crawarq.nrsequen + 1,"99999").
       aux_flgfirst = FALSE.

FOR EACH crawarq BREAK BY crawarq.nrsequen
                       BY crawarq.nmarquiv: 
       
    RUN proc_processa_arquivo.

    IF  glb_cdcritic = 0  THEN
        DO:
            IF  aux_flgrejei  THEN
                ASSIGN glb_cdcritic = 191.
            ELSE
                ASSIGN glb_cdcritic = 190.

            RUN fontes/critic.p. 

            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - Coop:" + STRING(glb_cdcooper,"99") +
                              " - Processar: CONTRA-ORDEM" +
                              " - SER00005 - " + glb_cdprogra + 
                              "' --> '"  + glb_dscritic + " - " +
                              crawarq.nmarquiv + " >> " + aux_nmarqlog).
        END.

END. /*** Fim do FOR EACH crawarq ***/

IF  aux_flgfirst  THEN
    RUN rel_rejeitados.

RUN fontes/fimprg.p.       

/*-------------------------------- PROCEDURES --------------------------------*/

PROCEDURE proc_processa_arquivo.

    ASSIGN glb_cdcritic = 0
           aux_qtregist = 1
           aux_flgrejei = FALSE.

    INPUT STREAM str_1 FROM VALUE(crawarq.nmarquiv + ".q") NO-ECHO.
   
    /*** Header ***/
    SET STREAM str_1 aux_setlinha WITH FRAME f_linha.
   
    IF  INT(SUBSTR(aux_setlinha,1,1)) <> 0  THEN
        ASSIGN glb_cdcritic = 468.
   
    IF  SUBSTR(aux_setlinha,13,15) <> "SERASA-RECHEQUE"  THEN
        ASSIGN glb_cdcritic = 887.

    IF  INT(SUBSTR(aux_setlinha,188,7)) <> 1  THEN
        ASSIGN glb_cdcritic = 117.
    
    IF  glb_cdcritic <> 0  THEN
        DO:
            INPUT STREAM str_1 CLOSE.
            
            RUN fontes/critic.p.
            
            ASSIGN aux_nmarquiv = "/usr/coop/cecred/integra/err" + 
                                  SUBSTR(crawarq.nmarquiv,
                                         R-INDEX(crawarq.nmarquiv,"/") + 1,
                                         LENGTH(crawarq.nmarquiv)).
            
            UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
            
            UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " + aux_nmarquiv).
            
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - Coop:" + STRING(crapcop.cdcooper,"99") +
                              " - Processar: CONTRA-ORDEM" +
                              " - SER00005 - " + glb_cdprogra +
                              "' --> '" + glb_dscritic + " - " + aux_nmarquiv +
                              " >> " + aux_nmarqlog).
            
            RETURN.
        END.

    /*** Se houver erro no registro header ***/
    IF  TRIM(SUBSTR(aux_setlinha,143,45)) <> ""  THEN
        DO:
            ASSIGN aux_nmarquiv = "/usr/coop/cecred/integra/err" + 
                                  SUBSTR(crawarq.nmarquiv,
                                         R-INDEX(crawarq.nmarquiv,"/") + 1,
                                         LENGTH(crawarq.nmarquiv)).

            UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
            
            UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " + aux_nmarquiv).
            
            ASSIGN aux_cdderros = TRIM(SUBSTR(aux_setlinha,143,45))
                   aux_qtderros = LENGTH(aux_cdderros) / 3
                   aux_nrposica = 1
                   aux_dsmsglog = "echo " + STRING(TIME,"HH:MM:SS") +
                                  " - SER00005 - " + glb_cdprogra +
                                  "' --> '" + "ERROS: ".
            
            RUN procura_erro.

            ASSIGN aux_dsmsglog = aux_dsmsglog + STRING(aux_cddoerro,"999") + 
                                  " - " + aux_dsdoerro + " / ".
            
            DO aux_contador = 2 TO aux_qtderros:
            
                ASSIGN aux_nrposica = aux_nrposica + 3.
                
                RUN procura_erro.

                ASSIGN aux_dsmsglog = aux_dsmsglog + STRING(aux_cddoerro,"999")
                                      + " - " + aux_dsdoerro + " / ".
                
            END. /*** Fim do DO TO ***/

            ASSIGN aux_dsmsglog = aux_dsmsglog + " - " + aux_nmarquiv +
                                  " >> " + aux_nmarqlog
                   glb_cdcritic = 9999.
                                   
            UNIX SILENT VALUE(aux_dsmsglog).
            
            RETURN.
        END.
        
    DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

        SET STREAM str_1 aux_setlinha WITH FRAME f_linha.

        ASSIGN glb_cdcritic = 0
               aux_qtregist = aux_qtregist + 1.

        /*** Verifica se eh final do Arquivo ***/
        IF  INT(SUBSTR(aux_setlinha,1,1)) = 9  THEN DO:
            /*** Conferir o total do arquivo ***/
            IF  aux_qtregist <> INT(SUBSTR(aux_setlinha,188,7))  THEN DO:

                ASSIGN glb_cdcritic = 504.
                RUN fontes/critic.p.

                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                  " - Coop:" + STRING(glb_cdcooper,"99") +
                                  " - Processar: CONTRA-ORDEM" +
                                  " - SER00005 - " + 
                                  glb_cdprogra + "' --> '" +
                                  glb_dscritic + 
                                  " - ARQUIVO PROCESSADO - " + 
                                  aux_nmarquiv + " >> " + aux_nmarqlog).
                
                LEAVE.
            END.
        END.
        ELSE
            DO:
                /*** Detalhe ***/
                ASSIGN aux_tpcomand = INT(SUBSTR(aux_setlinha,2,1))  
                       aux_nrdconta = INT(SUBSTR(aux_setlinha,10,15))
                       aux_nrcpfcgc = DEC(SUBSTR(aux_setlinha,26,14))
                       aux_nmprimtl = TRIM(SUBSTR(aux_setlinha,40,70))
                       aux_cdmotivo = SUBSTR(aux_setlinha,122,1)
                       aux_vlcheque = DEC(SUBSTR(aux_setlinha,123,12)) * 100
                       aux_dtocorre = DATE(INT(SUBSTR(aux_setlinha,139,2)),
                                           INT(SUBSTR(aux_setlinha,141,2)),
                                           INT(SUBSTR(aux_setlinha,135,4)))
                       aux_nrchqini = INT(SUBSTR(aux_setlinha,110,6))
                       aux_nrchqfim = INT(SUBSTR(aux_setlinha,116,6))
                       aux_cdderros = TRIM(SUBSTR(aux_setlinha,143,45)).
                       
                ASSIGN aux_cdagectl = INT(SUBSTR(aux_setlinha,6,4)).
                /* tratar cooperativas incorporadas*/
                IF aux_cdagectl = 103 THEN /* se era concredi*/
                  ASSIGN aux_cdagectl = 101. /* vira viacredi*/
                ELSE IF aux_cdagectl = 114 THEN /* se era credimilsul*/
                  ASSIGN aux_cdagectl = 112.    /* vira scrcred*/
                
                FIND crapcop WHERE 
                     crapcop.cdagectl = aux_cdagectl
                     NO-LOCK NO-ERROR.

                IF  NOT AVAIL crapcop  THEN
                DO:
                    ASSIGN glb_cdcritic = 651.
                    RUN fontes/critic.p.

                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                      " - Coop:" + STRING(glb_cdcooper,"99") +
                                      " - Processar: CONTRA-ORDEM" +
                                      " - SER00005 - " + 
                                      glb_cdprogra + "' --> '" +
                                      glb_dscritic + 
                                      " - CONTA/DV: " + 
                                      STRING(aux_nrdconta,"zzzz,zzz,z") + 
                                      " - Registro " + 
                                      STRING(aux_qtregist,"9999999") +
                                      " - " + aux_nmarquiv + " >> " + 
                                      aux_nmarqlog).
                    
                    NEXT.
                END.
                
                FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                                   crapass.nrdconta = aux_nrdconta 
                                   NO-LOCK NO-ERROR.
                                 
                /* verificar se é uma conta migrada da credimilsul
                  ou concredi */
                RELEASE craptco.

                IF crapcop.cdcooper = 1 OR 
                   crapcop.cdcooper = 13  THEN
                DO:
                  FIND FIRST craptco 
                       WHERE craptco.cdcooper = crapcop.cdcooper
                         AND craptco.nrctaant = aux_nrdconta
                         AND (craptco.cdcopant = 4 OR
                              craptco.cdcopant = 15) 
                         AND craptco.flgativo = TRUE
                         NO-LOCK NO-ERROR.
                END.
                                

                /* se nao encontrar o associado e não for
                   uma conta migrada, deve gerar critica */
                IF  NOT AVAILABLE crapass  AND
                    NOT AVAILABLE craptco THEN DO:
                    ASSIGN glb_cdcritic = 9.
                    RUN fontes/critic.p.

                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                      " - Coop:" + STRING(glb_cdcooper,"99") +
                                      " - Processar: CONTRA-ORDEM" +
                                      " - SER00005 - " + 
                                      glb_cdprogra + "' --> '" +
                                      glb_dscritic + 
                                      " - CONTA/DV: " + 
                                      STRING(aux_nrdconta,"zzzz,zzz,z") + 
                                      " - Registro " + 
                                      STRING(aux_qtregist,"9999999") +
                                      " - " + aux_nmarquiv + " >> " + 
                                      aux_nmarqlog).
                    
                    NEXT.
                END.
                    
                IF  aux_cdderros = ""  THEN
                    DO:
                        /*** Se registro detalhe foi processado com sucesso ***/
                        FOR EACH crapcch WHERE 
                                 crapcch.cdcooper = crapcop.cdcooper AND
                                 /* alterado para buscar pelo numero da ctachq
                                    pois será enviado sempre o nrctachq, 
                                    para tratar os cheques de cooper incorporadas*/
                                 crapcch.nrctachq = aux_nrdconta     AND
                                 crapcch.cdbanchq = crapcop.cdbcoctl AND
                                 INT(SUBSTR(STRING(crapcch.nrchqini,"9999999"),
                                            1,6))
                                                  = aux_nrchqini AND
                                 INT(SUBSTR(STRING(crapcch.nrchqfim,"9999999"),
                                            1,6))
                                                  = aux_nrchqfim NO-LOCK
                                 BREAK BY crapcch.nrdconta
                                          BY crapcch.dtmvtolt:
                                 
                            IF  LAST-OF(crapcch.nrdconta)  THEN
                                DO WHILE TRUE:
                        
                                    FIND crabcch WHERE 
                                         RECID(crabcch) = RECID(crapcch) 
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT. 
                                       
                                    IF  NOT AVAILABLE crabcch  THEN
                                        IF  LOCKED crabcch  THEN
                                            DO:
                                                PAUSE 1 NO-MESSAGE.
                                                NEXT.
                                            END.
                                        ELSE
                                            LEAVE.
                            
                                    ASSIGN crapcch.flgctitg = 2.

                                    LEAVE.
                            
                                END. /*** Fim do DO WHILE TRUE ***/
                            
                        END. /*** Fim do FOR EACH crapcch ***/  
                    END.
                ELSE
                    DO:
                        /*** Com Erro ***/
                        DO WHILE TRUE:

                            /*** Atualiza cheques para reprocessar ***/
                            FIND crapcch WHERE 
                                 crapcch.cdcooper = crapcop.cdcooper AND
                                /* alterado para buscar pelo numero da ctachq
                                    pois será enviado sempre o nrctachq, 
                                    para tratar os cheques de cooper incorporadas*/ 
                                 crapcch.nrctachq = aux_nrdconta     AND 
                                 crapcch.flgctitg = 1                AND 
                                 crapcch.cdbanchq = crapcop.cdbcoctl AND
                                 INT(SUBSTR(STRING(crapcch.nrchqini,"9999999"),
                                            1,6))
                                                  = aux_nrchqini AND
                                 INT(SUBSTR(STRING(crapcch.nrchqfim,"9999999"),
                                            1,6))
                                                  = aux_nrchqfim 
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                            IF  NOT AVAILABLE crapcch  THEN
                                IF  LOCKED crapcch  THEN
                                    DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT.
                                    END.
                                ELSE   
                                    LEAVE.
                            
                            ASSIGN crapcch.flgctitg = 4. 

                            RUN cria_rejeitado.
                       
                            LEAVE.

                        END. /*** Fim do DO WHILE TRUE ***/
                        
                        ASSIGN aux_flgfirst = TRUE
                               aux_flgrejei = TRUE.
                    END.
            END. 
           
    END. /*** Fim do DO WHILE TRUE ***/
     
    INPUT STREAM str_1 CLOSE.
   
    UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
    
    UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " + aux_dscooper + "salvar").
   
END PROCEDURE. 

PROCEDURE cria_rejeitado:

    CREATE cratrej.
    ASSIGN cratrej.nrdconta = aux_nrdconta
           cratrej.cdcooper = crapcop.cdcooper
           cratrej.cdagenci = IF AVAIL crapass THEN crapass.cdagenci
                              ELSE craptco.cdagenci
           cratrej.tpcomand = IF  aux_tpcomand = 1  THEN
                                  "EXCLUSAO"
                              ELSE
                                  "INCLUSAO"
           cratrej.nrcpfcgc = aux_nrcpfcgc
           cratrej.nmprimtl = aux_nmprimtl
           cratrej.nrchqini = aux_nrchqini
           cratrej.nrchqfim = aux_nrchqfim
           cratrej.dsmotivo = IF  aux_cdmotivo = "E"  THEN
                                  "EXTRAVIADO"
                              ELSE
                              IF  aux_cdmotivo = "R"  THEN
                                  "ROUBADO"
                              ELSE
                              IF  aux_cdmotivo = "S"  THEN
                                  "SUSTADO"
                              ELSE
                              IF  aux_cdmotivo = "X"  THEN
                                  "CANCELADO"
                              ELSE
                                  ""
           cratrej.vlcheque = aux_vlcheque
           cratrej.dtocorre = aux_dtocorre
           cratrej.cdderros = aux_cdderros.

END PROCEDURE.

PROCEDURE rel_rejeitados:

    FOR EACH cratrej NO-LOCK BREAK BY cratrej.cdcooper
                                   BY cratrej.cdagenci
                                   BY cratrej.nrdconta:
        IF  FIRST-OF(cratrej.cdcooper)  THEN
            DO:
                FIND crapcop WHERE crapcop.cdcooper = cratrej.cdcooper
                                   NO-LOCK NO-ERROR.
                ASSIGN aux_dscooper = "/usr/coop/" +
                                      crapcop.dsdircop + "/"
                       aux_nmarqrel = aux_dscooper + "rl/crrl551_999.lst".
    
                /*** Monta o cabecalho ***/
                { includes/cabrel132_1.i }
    
                OUTPUT STREAM str_1 TO VALUE(aux_nmarqrel) APPEND PAGED 
                       PAGE-SIZE 84.
    
                VIEW STREAM str_1 FRAME f_cabrel132_1.
    
                VIEW STREAM str_1 FRAME f_cab_rejeitados.

            END.
        
        IF  FIRST-OF(cratrej.cdagenci)  THEN
            DO:
            
                ASSIGN aux_nmarqrel = aux_dscooper + "rl/crrl551_" + 
                                      STRING(cratrej.cdagenci,"999") + ".lst".

                OUTPUT STREAM str_2 TO VALUE(aux_nmarqrel) 
                                    APPEND PAGED PAGE-SIZE 84.
                
                VIEW STREAM str_2 FRAME f_cabrel132_1.

                FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper AND
                                   crapage.cdagenci = cratrej.cdagenci 
                                   NO-LOCK NO-ERROR.

                PUT STREAM str_2 SKIP
                                "PA:  " crapage.cdagenci " - " 
                                crapage.nmresage FORMAT "x(15)"
                                SKIP(1).
                
                VIEW STREAM str_2 FRAME f_cab_rejeitados.
            END.
                                  
        ASSIGN aux_qtderros = LENGTH(cratrej.cdderros) / 3
               aux_nrposica = 1
               aux_cdderros = cratrej.cdderros.
        
        RUN procura_erro.
        
        DISPLAY STREAM str_1
                       cratrej.nrdconta
                       cratrej.nmprimtl
                       cratrej.nrchqini
                       cratrej.nrchqfim
                       cratrej.tpcomand
                       cratrej.dtocorre
                       aux_dsdoerro
                       WITH FRAME f_rejeitados.
                      
        DISPLAY STREAM str_2
                       cratrej.nrdconta
                       cratrej.nmprimtl
                       cratrej.nrchqini
                       cratrej.nrchqfim
                       cratrej.tpcomand
                       cratrej.dtocorre
                       aux_dsdoerro
                       WITH FRAME f_rejeitados.               
                       
        DOWN STREAM str_1 WITH FRAME f_rejeitados.
        
        DOWN STREAM str_2 WITH FRAME f_rejeitados.
        
        DO aux_contador = 2 TO aux_qtderros:
        
            ASSIGN aux_nrposica = aux_nrposica + 3.
                
            RUN procura_erro.
            
            DISPLAY STREAM str_1 aux_dsdoerro WITH FRAME f_rejeitados.
            
            DISPLAY STREAM str_2 aux_dsdoerro WITH FRAME f_rejeitados.
            
            DOWN STREAM str_1 WITH FRAME f_rejeitados.
            
            DOWN STREAM str_2 WITH FRAME f_rejeitados.
        
        END. /*** Fim do DO TO ***/
        
        IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1)  THEN
            DO:
                PAGE STREAM str_1.
                VIEW STREAM str_1 FRAME f_cab_rejeitados.
            END.

        IF  LINE-COUNTER(str_2) > PAGE-SIZE(str_2)  THEN
            DO:
                PAGE STREAM str_2.
                VIEW STREAM str_2 FRAME f_cab_rejeitados.
            END.

        IF  LAST-OF(cratrej.cdagenci)  THEN
            DO:
                OUTPUT STREAM str_2 CLOSE.

                ASSIGN glb_nmformul = "132col"
                       glb_nmarqimp = aux_nmarqrel
                       glb_nrcopias = 1.
    
                RUN fontes/imprim_unif.p (INPUT cratrej.cdcooper).
                
                /*** Se nao estiver rodando no PROCESSO copia relatorio ***/
                IF  glb_inproces = 1  THEN
                    UNIX SILENT VALUE("cp " + aux_nmarqrel + " " + aux_dscooper
                                      + "rlnsv/" +
                         SUBSTRING(aux_nmarqrel,R-INDEX(aux_nmarqrel,"/") + 1,
                         LENGTH(aux_nmarqrel) - R-INDEX(aux_nmarqrel,"/"))).
            END.

        IF  LAST-OF(cratrej.cdcooper)  THEN
            DO:
                OUTPUT STREAM str_1 CLOSE.
    
                ASSIGN aux_nmarqrel = aux_dscooper + "rl/crrl551_999.lst"
                       glb_nmformul = "132col"
                       glb_nmarqimp = aux_nmarqrel
                       glb_nrcopias = 1.
    
                RUN fontes/imprim_unif.p (INPUT cratrej.cdcooper).
                
                /*** Se nao estiver rodando no PROCESSO copia relatorio para "/rlnsv" ***/
                IF glb_inproces = 1  THEN
                   UNIX SILENT VALUE("cp " + aux_nmarqrel + " " + 
                                     aux_dscooper + "rlnsv/" +
                                     SUBSTRING(aux_nmarqrel,
                                               R-INDEX(aux_nmarqrel,"/") + 1,
                                               LENGTH(aux_nmarqrel) - 
                                               R-INDEX(aux_nmarqrel,"/"))).
            END.

    END. /*** Fim do FOR EACH cratrej ***/

END PROCEDURE.

PROCEDURE procura_erro:

    ASSIGN aux_cddoerro = INT(SUBSTR(aux_cdderros,aux_nrposica,3))
           aux_dsdoerro = "".

    FIND FIRST craptab WHERE craptab.cdcooper = 3            AND
                             craptab.nmsistem = "CRED"       AND
                             craptab.tptabela = "GENERI"     AND
                             craptab.cdempres = 00           AND
                             craptab.cdacesso = "CDERROSSER" AND
                             craptab.tpregist = aux_cddoerro  
                             NO-ERROR NO-WAIT.
                             
    IF  AVAILABLE craptab  THEN
        ASSIGN aux_dsdoerro = CAPS(TRIM(craptab.dstextab)).
 
END PROCEDURE.

/*...........................................................................*/


