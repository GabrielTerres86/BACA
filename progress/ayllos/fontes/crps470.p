/*..............................................................................

   Programa: fontes/crps470.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Marco/2007                        Ultima atualizacao: 25/11/2014

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Tratar arquivo retorno BANCOOB de INCLUSAO NO CCF.
               Emite relatorio crrl446.

   Alteracoes: 09/08/2007 - Retirado envio de e-mail para Suzana@cecred.coop.br
                           (Guilherme) 

               01/04/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)

               02/08/2012 - Ajuste do format no campo nmrescop (David Kruger).
               
               16/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               04/11/2013 - Alterado totalizador de PAs de 99 para 999.
                            (Reinert)   
                            
               11/09/2014 - Ajustes devido a migração da Concredi,
                            tratar importação de numero de contas da concredi
                            (Odirlei/AMcom).         
                            
               25/11/2014 - Incluir clausula no craptco flgativo = TRUE
                            (Lucas R./Rodrigo)                             
..............................................................................*/

{ includes/var_batch.i }

DEF   VAR b1wgen0011   AS HANDLE                                     NO-UNDO.

DEF STREAM str_1.
DEF STREAM str_2.
DEF STREAM str_3. /* arquivo anexo para enviar via email */

DEF BUFFER crabtab FOR craptab.

DEF TEMP-TABLE cratrej                                                  NO-UNDO
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrcheque AS INTE
    FIELD idseqttl AS INTE
    FIELD tpregist AS CHAR
    FIELD dsmotivo AS CHAR
    FIELD nrcpfcgc AS DECI
    FIELD dtocorre AS DATE
    FIELD vlcheque AS DECI
    FIELD nmextttl AS CHAR
    FIELD cdderros AS CHAR.
    
DEF TEMP-TABLE crawarq                                                  NO-UNDO
    FIELD nmarquiv AS CHAR
    FIELD nrsequen AS INTE
    INDEX crawarq1 AS PRIMARY nmarquiv nrsequen.

DEF VAR aux_qttpreg2 AS INTE                                           NO-UNDO.
DEF VAR aux_qttpreg4 AS INTE                                           NO-UNDO.
DEF VAR aux_qttpreg6 AS INTE                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.
DEF VAR aux_nrcheque AS INTE                                           NO-UNDO.
DEF VAR aux_tpregist AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_nrsequen AS INTE                                           NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_nrseqarq AS INTE                                           NO-UNDO.
DEF VAR aux_cdmotivo AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_tppessoa AS INTE                                           NO-UNDO.
DEF VAR aux_qtderros AS INTE                                           NO-UNDO.
DEF VAR aux_cddoerro AS INTE                                           NO-UNDO.
DEF VAR aux_nrposica AS INTE                                           NO-UNDO.

DEF VAR aux_cdderros AS CHAR                                           NO-UNDO.
DEF VAR aux_nmextttl AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_setlinha AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqdat AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqlog AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqrel AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdoerro AS CHAR                                           NO-UNDO.

DEF VAR aux_vlcheque AS DECI                                           NO-UNDO.
DEF VAR aux_nrcpfcgc AS DECI                                           NO-UNDO.

DEF VAR aux_flgfirst AS LOGI                                           NO-UNDO.
DEF VAR aux_flgrejei AS LOGI                                           NO-UNDO.

DEF VAR aux_dtiniest LIKE crapneg.dtiniest                             NO-UNDO.

DEF VAR rel_nmempres AS CHAR     FORMAT "x(15)"                        NO-UNDO.
DEF VAR rel_nmrelato AS CHAR     FORMAT "x(40)" EXTENT 5               NO-UNDO.

DEF VAR rel_nrmodulo AS INT      FORMAT "9"                            NO-UNDO.

DEF VAR rel_nmmodulo AS CHAR     FORMAT "x(15)" EXTENT 5
                                 INIT ["DEP. A VISTA   ","CAPITAL        ",
                                       "EMPRESTIMOS    ","DIGITACAO      ",
                                       "GENERICO       "]               NO-UNDO.

FORM
    cratrej.nrdconta  AT  1  FORMAT "zzzz,zzz,z"      NO-LABEL
    cratrej.nmextttl  AT 12  FORMAT "x(30)"           NO-LABEL
    cratrej.idseqttl  AT 49  FORMAT "9"               NO-LABEL
    cratrej.nrcheque  AT 51  FORMAT "999999"          NO-LABEL
    cratrej.vlcheque  AT 58  FORMAT "zzz,zz9.99"      NO-LABEL
    cratrej.dtocorre  AT 69  FORMAT "99/99/9999"      NO-LABEL
    aux_dsdoerro      AT 80  FORMAT "x(50)"           NO-LABEL
    WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_rejeitados.
    
FORM
    "CONTA/DV"                 AT  3  
    "NOME"                     AT 12
    "SEQ.TTL"                  AT 43
    "CHEQUE"                   AT 51
    "VALOR"                    AT 63
    "DATA"                     AT 69
    "DESCRICAO DO(S) ERRO(S)"  AT 80
    WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_cab_rejeitados.
    
FORM 
    aux_setlinha   FORMAT "x(173)"
    WITH NO-BOX NO-LABELS WIDTH 173 FRAME f_linha.
    
ASSIGN glb_cdprogra = "crps470"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0  THEN
    RETURN.

ASSIGN aux_nmarqlog = "log/prcbcb_" + STRING(YEAR(glb_dtmvtolt),"9999") + 
                      STRING(MONTH(glb_dtmvtolt),"99") + 
                      STRING(DAY(glb_dtmvtolt),"99") + ".log".

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

EMPTY TEMP-TABLE crawarq.
EMPTY TEMP-TABLE cratrej.

ASSIGN aux_nmarquiv = "/micros/" + crapcop.dsdircop + 
                      "/bancoob/RET_BCB_CCF*.CBE"
       aux_flgfirst = TRUE
       aux_contador = 0.
 
INPUT STREAM str_1 
            THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null") NO-ECHO.
                                              
DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

    SET STREAM str_1 aux_nmarquiv FORMAT "x(60)" .

    ASSIGN aux_contador = aux_contador + 1
           aux_nmarqdat = "integra/RET_BCB_CCF_" +
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
    ASSIGN crawarq.nrsequen = INT(SUBSTR(aux_setlinha,52,4))
           crawarq.nmarquiv = aux_nmarqdat
           aux_flgfirst     = FALSE.

    INPUT STREAM str_2 CLOSE.
                                                       
END. /*** Fim do DO WHILE TRUE ***/

INPUT STREAM str_1 CLOSE.

IF  aux_flgfirst  THEN
    DO: 
        ASSIGN glb_cdcritic = 182.
        RUN fontes/critic.p.
        
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - RET_BCB_CCF - " + glb_cdprogra + "' --> '" +
                          glb_dscritic + " >> " + aux_nmarqlog).
        
        RUN fontes/fimprg.p.
        RETURN.
    END.

FIND crabtab WHERE crabtab.cdcooper = glb_cdcooper AND
                   crabtab.nmsistem = "CRED"       AND
                   crabtab.tptabela = "GENERI"     AND
                   crabtab.cdempres = 00           AND
                   crabtab.cdacesso = "NRARQRTBCB" AND
                   crabtab.tpregist = 001          
                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT. 

IF  NOT AVAILABLE crabtab  THEN
    DO:
        ASSIGN glb_cdcritic = 393.
        RUN fontes/critic.p.
        
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          glb_dscritic + " >> " + aux_nmarqlog).
        
        RUN fontes/fimprg.p.
        RETURN.
    END.    

ASSIGN aux_nrsequen = INT(SUBSTR(crabtab.dstextab,01,05)).

FIND FIRST craptab WHERE craptab.cdcooper = glb_cdcooper AND
                         craptab.nmsistem = "CRED"       AND
                         craptab.tptabela = "GENERI"     AND
                         craptab.cdempres = 00           AND
                         craptab.cdacesso = "CDERROSBCB" NO-LOCK NO-ERROR.
     
IF  NOT AVAILABLE craptab  THEN
    DO:
        ASSIGN glb_cdcritic = 886.
        RUN fontes/critic.p.
        
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          glb_dscritic + " >> " + aux_nmarqlog).
        
        RUN fontes/fimprg.p.
        RETURN.
    END.    
     
FOR EACH crawarq BREAK BY crawarq.nrsequen:
                    
    IF  FIRST-OF(crawarq.nrsequen)  THEN
        DO:
            IF  crawarq.nrsequen <> aux_nrsequen  THEN
                DO:
                    ASSIGN glb_cdcritic = 476.
                    RUN fontes/critic.p.
                    
                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                      " - RET_BCB_CCF - " + glb_cdprogra + 
                                      "' --> '"  +
                                      glb_dscritic + " " + "SEQ.BANCOOB " +
                                      STRING(crawarq.nrsequen) + 
                                      " " + "SEQ.COOP " + 
                                      STRING(aux_nrsequen) + " - " +
                                      "integra/err" + 
                                      SUBSTR(crawarq.nmarquiv,9) +
                                      " >> " + aux_nmarqlog).

                    ASSIGN aux_nmarqimp = "arq/" + glb_cdprogra +
                                          "_ANEXO" + STRING(TIME).
                    OUTPUT STREAM str_3 TO VALUE(aux_nmarqimp).

                    PUT STREAM str_3 "ERRO DE SEQUENCIA no arquivo "
                                     "RET_BCB_CCF da cooperativa "
                                     crapcop.nmrescop FORMAT "x(20)"
                                     " / DIA: "
                                     STRING(glb_dtmvtolt,"99/99/9999")
                                     FORMAT "x(17)"
                                     SKIP.
                                    
                    OUTPUT STREAM str_3 CLOSE.

                    /* Move para diretorio converte para utilizar na BO */
                    UNIX SILENT VALUE
                         ("cp " + aux_nmarqimp + " /usr/coop/" +
                          crapcop.dsdircop + "/converte" +
                          " 2> /dev/null").
                    
                    /* envio de email */ 
                    RUN sistema/generico/procedures/b1wgen0011.p
                        PERSISTENT SET b1wgen0011.
         
                    RUN enviar_email IN b1wgen0011
                                       (INPUT glb_cdcooper,
                                        INPUT glb_cdprogra,
                                        INPUT "willian@cecred.coop.br",
                                        INPUT '"ERRO DE SEQUENCIA - "' +
                                              '"RET_BCB_CCF - "' +
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
            ASSIGN aux_nmarquiv = "integra/err" + 
                                  SUBSTR(crawarq.nmarquiv,9).

            UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " +
                              aux_nmarquiv).
                    
            UNIX SILENT VALUE("rm " + crawarq.nmarquiv + 
                              ".q 2> /dev/null").

            IF  LAST-OF(crawarq.nrsequen)  THEN
                RETURN.
        END.

END. /*** Fim do FOR EACH crawarq ***/

ASSIGN SUBSTR(crabtab.dstextab,1,5) = STRING(crawarq.nrsequen + 1,"99999")
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
                              " - RET_BCB_CCF - " + glb_cdprogra + "' --> '"  +
                              glb_dscritic + " - " +
                              crawarq.nmarquiv + " >> " + aux_nmarqlog).
        END.
        
END. /*** Fim do FOR EACH crawarq ***/    

IF  aux_flgfirst  THEN
    RUN rel_rejeitados.

RUN fontes/fimprg.p.                   

/*-------------------------------- PROCEDURES --------------------------------*/

PROCEDURE proc_processa_arquivo:

    ASSIGN glb_cdcritic = 0
           aux_qtregist = 1
           aux_flgrejei = FALSE.
             
    INPUT STREAM str_1 FROM VALUE(crawarq.nmarquiv + ".q") NO-ECHO.
   
    /*** Header ***/
    SET STREAM str_1 aux_setlinha WITH FRAME f_linha.

    IF  INT(SUBSTR(aux_setlinha,31,1)) <> 0  THEN
        ASSIGN glb_cdcritic = 468.
   
    IF  SUBSTR(aux_setlinha,32,12) <> "SERASA-ACHEI"  THEN
        ASSIGN glb_cdcritic = 887.

    IF  glb_cdcritic <> 0 THEN
        DO:
            INPUT STREAM str_1 CLOSE.
            
            RUN fontes/critic.p.
            ASSIGN aux_nmarquiv = "integra/err" + 
                                  SUBSTR(crawarq.nmarquiv,9).

            UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
            
            UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " + aux_nmarquiv).
            
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - RET_BCB_CCF - " + glb_cdprogra + "' --> '" +
                              glb_dscritic + " - " + aux_nmarquiv +
                              " >> " + aux_nmarqlog).
            
            RETURN.
        END.

    DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

        SET STREAM str_1 aux_setlinha WITH FRAME f_linha.

        ASSIGN glb_cdcritic = 0
               aux_qtregist = aux_qtregist + 1.
        
        /*** Trailer ***/ 
        IF  INT(SUBSTR(aux_setlinha,31,1)) = 9  THEN
            DO:
                /*** Verifica contagem dos tipos de registro ***/
                IF  aux_qttpreg2 <> INT(SUBSTR(aux_setlinha,32,7))  THEN
                    ASSIGN glb_cdcritic = 504.
                ELSE    
                IF  aux_qttpreg4 <> INT(SUBSTR(aux_setlinha,39,7))  THEN
                    ASSIGN glb_cdcritic = 504.
                ELSE
                IF  aux_qttpreg6 <> INT(SUBSTR(aux_setlinha,46,7))  THEN
                    ASSIGN glb_cdcritic = 504.

                IF  glb_cdcritic > 0  THEN
                    DO:
                        RUN fontes/critic.p.

                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                          " - RET_BCB_CCF - " + glb_cdprogra + 
                                          "' --> '" +
                                          glb_dscritic + 
                                          " - ARQUIVO PROCESSADO - " + 
                                          aux_nmarquiv +
                                          " >> " + aux_nmarqlog).
                        
                        LEAVE.
                    END.
            END.
        ELSE
            DO:
                /*** Detalhe ***/
                ASSIGN aux_nrdconta = INT(SUBSTR(aux_setlinha,8,12))
                       aux_nrcheque = INT(SUBSTR(aux_setlinha,20,6))
                       aux_tpregist = INT(SUBSTR(aux_setlinha,31,1))
                       aux_cdmotivo = INT(SUBSTR(aux_setlinha,32,2))
                       aux_tppessoa = INT(SUBSTR(aux_setlinha,35,1))
                       aux_nrcpfcgc = DECI(SUBSTR(aux_setlinha,36,14))
                       aux_dtiniest = DATE(INT(SUBSTRING(aux_setlinha,54,2)),
                                           INT(SUBSTRING(aux_setlinha,56,2)),
                                           INT(SUBSTRING(aux_setlinha,50,4)))
                       aux_vlcheque = DECI(SUBSTR(aux_setlinha,58,17)) / 100
                       aux_nmextttl = TRIM(SUBSTR(aux_setlinha,75,40))
                       aux_cdderros = TRIM(SUBSTR(aux_setlinha,115,45))
                       aux_idseqttl = INT(SUBSTR(aux_setlinha,28,2)).
                                       
                IF  aux_idseqttl = 0  THEN
                    aux_idseqttl = 1.
                    
                /*** Contadores por Tipo de Registro ***/
                IF  aux_tpregist = 2  THEN
                    ASSIGN aux_qttpreg2 = aux_qttpreg2 + 1.
                ELSE
                IF  aux_tpregist = 4  THEN
                    ASSIGN aux_qttpreg4 = aux_qttpreg4 + 1.
                ELSE
                IF  aux_tpregist = 6  THEN
                    ASSIGN aux_qttpreg6 = aux_qttpreg6 + 1.
                    
                
                IF glb_cdcooper = 1 THEN
                DO:
                  /*verifica se é uma conta migrada da concredi*/
                  FIND FIRST craptco 
                    WHERE craptco.cdcooper = glb_cdcooper 
                      AND craptco.nrctaant = aux_nrdconta 
                      AND craptco.cdcopant = 4  
                      AND craptco.flgativo = TRUE
                      NO-LOCK NO-ERROR.
            
                    /* se encontrar deve enviar cta antiga
                       se o cheque for da coop. antiga */
                    IF AVAIL(craptco) THEN 
                    DO:                      
                      FIND FIRST crapfdc
                     WHERE crapfdc.cdcooper = craptco.cdcooper
                       AND crapfdc.cdbanchq = 756                       
                       AND crapfdc.nrctachq = craptco.nrctaant 
                       AND crapfdc.nrcheque = aux_nrcheque 
                        NO-LOCK NO-ERROR.
                    
                      IF  AVAIL crapfdc THEN                      
                        ASSIGN aux_nrdconta = craptco.nrdconta.
                    END.    
                END.
                
                FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                   crapass.nrdconta = aux_nrdconta 
                                   NO-LOCK NO-ERROR.
                                   
                IF  NOT AVAILABLE crapass  THEN
                    DO:
                        ASSIGN glb_cdcritic = 9.
                        RUN fontes/critic.p.

                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                          " - RET_BCB_CCF - " + 
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
                        FIND crapneg WHERE 
                             crapneg.cdcooper = glb_cdcooper AND
                             crapneg.cdbanchq = 756          AND
                             crapneg.nrdconta = aux_nrdconta AND
                             crapneg.dtiniest = aux_dtiniest AND
                             INT(SUBSTR(STRING(crapneg.nrdocmto,"9999999"),1,6))
                                              = aux_nrcheque 
                             USE-INDEX crapneg1 EXCLUSIVE-LOCK NO-ERROR.
                                          
                        IF  AVAILABLE crapneg  THEN
                            ASSIGN crapneg.flgctitg = 2. 
                    END.
                ELSE
                    DO:
                        /*** Se registro teve erro, atualiza para Reenviar ***/
                        FIND crapneg WHERE 
                             crapneg.cdcooper = glb_cdcooper AND
                             crapneg.cdbanchq = 756          AND
                             crapneg.nrdconta = aux_nrdconta AND 
                             crapneg.flgctitg = 1            AND 
                             crapneg.dtiniest = aux_dtiniest AND
                             INT(SUBSTR(STRING(crapneg.nrdocmto,"9999999"),1,6))
                                              = aux_nrcheque 
                             USE-INDEX crapneg1 EXCLUSIVE-LOCK NO-ERROR.
                                          
                        IF  AVAILABLE crapneg  THEN
                            ASSIGN crapneg.flgctitg = 4. /*** Reenviar ***/
                            
                        RUN cria_rejeitado.
                        
                        ASSIGN aux_flgfirst = TRUE
                               aux_flgrejei = TRUE.

                    END.
            END. 
           
    END. /*** Fim do DO WHILE TRUE ***/
     
    INPUT STREAM str_1 CLOSE.
   
    UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
   
    UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " salvar").
   
END PROCEDURE. 

PROCEDURE cria_rejeitado:

    CREATE cratrej.
    ASSIGN cratrej.nrdconta = aux_nrdconta
           cratrej.cdagenci = crapass.cdagenci
           cratrej.nrcheque = aux_nrcheque
           cratrej.idseqttl = aux_idseqttl
           cratrej.tpregist = IF  aux_tpregist = 2  THEN
                                  "EXCLUSAO"
                              ELSE
                              IF  aux_tpregist = 4  THEN
                                  "INCLUSAO"
                              ELSE
                                  "ALTERACAO"
           cratrej.dsmotivo = IF  aux_cdmotivo = 12  THEN
                                  "CHEQUE SEM FUNDO"
                              ELSE
                              IF  aux_cdmotivo = 13  THEN
                                  "CONTA ENCERRADA"
                              ELSE
                                  ""
           cratrej.nrcpfcgc = aux_nrcpfcgc
           cratrej.dtocorre = aux_dtiniest
           cratrej.vlcheque = aux_vlcheque
           cratrej.nmextttl = aux_nmextttl
           cratrej.cdderros = aux_cdderros.

END PROCEDURE.

PROCEDURE rel_rejeitados:

    ASSIGN aux_nmarqrel = "rl/crrl446_999.lst".
    
    /*** Monta o cabecalho ***/
    { includes/cabrel132_1.i }
    
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqrel) APPEND PAGED PAGE-SIZE 84.

    VIEW STREAM str_1 FRAME f_cabrel132_1.
    
    VIEW STREAM str_1 FRAME f_cab_rejeitados.
    
    FOR EACH cratrej NO-LOCK BREAK BY cratrej.cdagenci
                                      BY cratrej.nrdconta:
    
        IF  FIRST-OF(cratrej.cdagenci)  THEN
            DO:
                ASSIGN aux_nmarqrel = "rl/crrl446_" + 
                                      STRING(cratrej.cdagenci,"999") + ".lst".

                OUTPUT STREAM str_2 TO VALUE(aux_nmarqrel) 
                                    APPEND PAGED PAGE-SIZE 84.
                
                VIEW STREAM str_2 FRAME f_cabrel132_1.

                FIND crapage WHERE crapage.cdcooper = glb_cdcooper     AND
                                   crapage.cdagenci = cratrej.cdagenci 
                                   NO-LOCK NO-ERROR.

                PUT STREAM str_2 SKIP
                                 "PA: " crapage.cdagenci " - " crapage.nmresage
                                 SKIP(1).
                
                VIEW STREAM str_2 FRAME f_cab_rejeitados.
            END.
                                  
        ASSIGN aux_qtderros = LENGTH(cratrej.cdderros) / 3
               aux_nrposica = 1.
        
        RUN procura_erro.
        
        DISPLAY STREAM str_1
                       cratrej.nrdconta
                       cratrej.nmextttl
                       cratrej.idseqttl
                       cratrej.nrcheque
                       cratrej.vlcheque
                       cratrej.dtocorre
                       aux_dsdoerro
                       WITH FRAME f_rejeitados.
                      
        DISPLAY STREAM str_2
                       cratrej.nrdconta
                       cratrej.nmextttl
                       cratrej.idseqttl
                       cratrej.nrcheque
                       cratrej.vlcheque
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
                
                /*** Se nao estiver rodando no PROCESSO copia relatorio ***/
                IF  glb_inproces = 1  THEN
                    UNIX SILENT VALUE("cp " + aux_nmarqrel + " rlnsv/" +
                         SUBSTRING(aux_nmarqrel,R-INDEX(aux_nmarqrel,"/") + 1,
                         LENGTH(aux_nmarqrel) - R-INDEX(aux_nmarqrel,"/"))).
            END.
    
    END. /*** Fim do FOR EACH cratrej ***/

    OUTPUT STREAM str_1 CLOSE.

    ASSIGN aux_nmarqrel = "rl/crrl446_999.lst".
    
    /*** Se nao estiver rodando no PROCESSO copia relatorio para "/rlnsv" ***/
    IF  glb_inproces = 1  THEN
        UNIX SILENT VALUE("cp " + aux_nmarqrel + " rlnsv/" +
                          SUBSTRING(aux_nmarqrel,R-INDEX(aux_nmarqrel,"/") + 1,
                          LENGTH(aux_nmarqrel) - R-INDEX(aux_nmarqrel,"/"))).

END PROCEDURE.

PROCEDURE procura_erro:

    ASSIGN aux_cddoerro = INT(SUBSTR(cratrej.cdderros,aux_nrposica,3))
           aux_dsdoerro = "".

    FIND FIRST craptab WHERE craptab.cdcooper = glb_cdcooper AND
                             craptab.nmsistem = "CRED"       AND
                             craptab.tptabela = "GENERI"     AND
                             craptab.cdempres = 00           AND
                             craptab.cdacesso = "CDERROSBCB" AND
                             craptab.tpregist = aux_cddoerro  
                             NO-ERROR NO-WAIT.
                             
    IF  AVAILABLE craptab  THEN
        ASSIGN aux_dsdoerro = CAPS(TRIM(craptab.dstextab)).
 
END PROCEDURE.

/*...........................................................................*/
