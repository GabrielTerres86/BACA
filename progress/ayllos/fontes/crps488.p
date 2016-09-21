/* ..........................................................................
   
   Programa: Fontes/crps488.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Julho/2007                      Ultima atualizacao: 25/01/2016

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Enviar informativos por email.
               
   Alteracoes: 30/07/2007 - Rodar programa somente no Processo Mensal (Diego).
   
               30/08/2007 - Modificada forma para envio de E-mail (Diego). 
               
               12/08/2008 - Desconsiderar contas que estao encerradas no envio
                            de Informativos (Diego).
                            
               30/12/2008 - Logar quando os Informativos nao estiverem postados
                            (Diego).
                
               15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop na
                            leitura e gravacao dos arquivos (Elton).
               
               16/12/2010 - Possibilitar envio de informativos e progr. progrid
                            com periodicidade 4 - PERIODICO (Irlan)
                            
               08/02/2011 - Alterado controle de transações. 
                            Inserido DO TRANSACTION (Irlan / Julio).
                            
               17/03/2011 - Alterado para enviar a Programação do Progrid
                            com arquivo zipado. (Irlan)
                            
               13/05/2011 - Chamar procedure enviar_email_spool ao invés de
                            enviar_email na BO11. (Irlan)
                            
               30/09/2011 - Incluido tratamento na busca de associado (Henrique)
               
               13/12/2011 - Alteração no procedure 'enviar_email_spoon' para
                            definir o assunto de seus respectivos emails (Lucas).
                   
               28/12/2012 - Retirar a palavra mensal do e-mail (Gabriel)   
               
               08/05/2014 - Retirada a mensagem do log: "Informativos nao foram 
                            postados no diretorio /integra." conforme chamado:
                            144957. Jéssica (DB1).                                                        
                                                                           
               25/01/2016 - Melhoria para alterar proc_batch pelo proc_message
                            na critica 812 e "Conta nao encontrada na CRAPASS".
                            (Jaison/Diego - SD: 273581)

..............................................................................*/

{ includes/var_batch.i "NEW" }

DEF STREAM str_1.

DEF        VAR aux_diretori AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqui1 AS CHAR                                  NO-UNDO.
DEF        VAR aux_dsemail1 AS CHAR                                  NO-UNDO.
DEF        VAR aux_totmail1 AS INT                                   NO-UNDO.
DEF        VAR aux_nmarqui2 AS CHAR                                  NO-UNDO.
DEF        VAR aux_dsemail2 AS CHAR                                  NO-UNDO.
DEF        VAR aux_totmail2 AS INT                                   NO-UNDO.
DEF        VAR aux_arqu2zip AS CHAR                                  NO-UNDO.
DEF        VAR aux_stenvinf AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgevent AS LOG                                   NO-UNDO.
DEF        VAR aux_flgmensa AS LOG                                   NO-UNDO.
DEF        VAR aux_cdperiod AS INT                                   NO-UNDO.
DEF        VAR aux_stultenv AS CHAR FORMAT "x(10)"                   NO-UNDO.
DEF        VAR aux_nmarqsp1 AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqsp2 AS CHAR                                  NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.

DEF        VAR b1wgen0011   AS HANDLE                                NO-UNDO.

/* Para BO de Log */
DEF        VAR h-b1wgen0014 AS HANDLE                                NO-UNDO.
DEF        VAR aux_critilog AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrdrowid AS ROWID                                 NO-UNDO.

DEF TEMP-TABLE t-enviados
    FIELD nrdconta AS INT
    FIELD idseqttl AS INT
    FIELD cdprogra AS INT
    FIELD cdrelato AS INT
    FIELD cdperiod AS INT
    FIELD cddfrenv AS INT
    FIELD cdseqinc AS INT. 

ASSIGN glb_cdprogra = "crps488".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0   THEN
     QUIT.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         QUIT.
     END.

ASSIGN aux_flgevent = FALSE.

/* Condição para Rodar Periodico */
FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "USUARI"       AND
                   craptab.cdempres = 11             AND
                   craptab.cdacesso = "ENVINFORMA"   AND
                   craptab.tpregist = 001
                   NO-LOCK NO-ERROR.
IF   AVAIL craptab  THEN
     DO:           
        ASSIGN aux_stenvinf = UPPER(SUBSTRING(craptab.dstextab,1,3))
               aux_stultenv = SUBSTRING(craptab.dstextab,5,10).

        IF   aux_stenvinf = "SIM"   THEN
             ASSIGN aux_flgevent = TRUE.
        ELSE
             ASSIGN aux_flgevent = FALSE.
     END.
ELSE
     ASSIGN aux_flgevent = FALSE.

/* So rodar quando tiver uma solicitação periodica */
IF   aux_flgevent = FALSE  THEN
     DO:
         RUN fontes/fimprg.p. 
         QUIT.     
     END.

ASSIGN aux_diretori = "/usr/coop/" + crapcop.dsdircop + "/integra/*.*"
       aux_nmarqui1 = ""
       aux_nmarqui2 = ""
       aux_arqu2zip = ""
       aux_dsemail1 = ""
       aux_dsemail2 = ""
       aux_totmail1 = 0
       aux_totmail2 = 0.
                              
INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_diretori + " 2> /dev/null")
             NO-ECHO.
                                              
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_1 aux_diretori FORMAT "x(120)" WITH WIDTH 125.

   IF   aux_diretori MATCHES "*INFOR01*.pdf"  THEN
        ASSIGN aux_nmarqui1 = SUBSTRING(aux_diretori,
                              R-INDEX(aux_diretori,"/") + 1).
   ELSE
   IF   aux_diretori MATCHES "*PROG*.mht"  THEN
        DO:
            ASSIGN aux_nmarqui2 = SUBSTRING(aux_diretori,
                                R-INDEX(aux_diretori,"/") + 1).
            
                   aux_arqu2zip = SUBSTRING(aux_diretori, 1, LENGTH(aux_diretori) - 4) + ".zip".

            UNIX SILENT VALUE("zipcecred.pl -silent  -add " + aux_arqu2zip + " " + aux_diretori + " 2> /dev/null"). 
                        
            ASSIGN aux_arqu2zip = SUBSTRING(aux_arqu2zip, 
                                            R-INDEX(aux_arqu2zip,"/") + 1).

        END.
END.

INPUT STREAM str_1 CLOSE.

/* Se nao existir informativos para envio */
IF   aux_nmarqui1 = ""  AND  aux_arqu2zip = ""  THEN
     DO:
         IF  aux_flgevent THEN
             DO:
                 DO TRANSACTION:
                     /*Limpa a solicitação de envio eventual da TAB088*/
                     FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                        craptab.nmsistem = "CRED"         AND
                                        craptab.tptabela = "USUARI"       AND
                                        craptab.cdempres = 11             AND
                                        craptab.cdacesso = "ENVINFORMA"   AND
                                        craptab.tpregist = 001
                                        EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                     IF  AVAIL craptab THEN
                         ASSIGN craptab.dstextab = "Nao " + aux_stultenv.
                 END.
             END.
             
         RUN fontes/fimprg.p. 
         QUIT.     
     END.

/* Roda Periodico */
IF  aux_flgevent    THEN
    DO:

        RUN envia_informativo (INPUT 4).

        DO TRANSACTION:
            /*Limpa a solicitação de envio eventual da TAB088 após enviar*/
            FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "USUARI"       AND
                               craptab.cdempres = 11             AND
                               craptab.cdacesso = "ENVINFORMA"   AND
                               craptab.tpregist = 001
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  AVAIL craptab THEN
                ASSIGN craptab.dstextab = "Nao " + STRING(TODAY, "99/99/9999").
        END.
    END.

/* Move os informativos para o diretorio salvar */ 

IF   aux_nmarqui1 <> ""  THEN
     UNIX SILENT VALUE("mv " + "/usr/coop/" + crapcop.dsdircop
                       + "/integra/" + aux_nmarqui1 + " /usr/coop/" +
                       crapcop.dsdircop + "/salvar").

IF   aux_arqu2zip <> ""  THEN
     DO:

        UNIX SILENT VALUE("mv " + "/usr/coop/" + crapcop.dsdircop
                  + "/integra/" + aux_nmarqui2 + " /usr/coop/" +
                  crapcop.dsdircop + "/salvar").

        UNIX SILENT VALUE("mv " + "/usr/coop/" + crapcop.dsdircop
                          + "/integra/" + aux_arqu2zip + " /usr/coop/" +
                          crapcop.dsdircop + "/salvar").

     END.

RUN fontes/fimprg.p.


PROCEDURE envia_informativo.
    DEF INPUT PARAM par_cdperiod AS INT          NO-UNDO.

    EMPTY TEMP-TABLE t-enviados.
    
    FOR EACH crapcra WHERE crapcra.cdcooper = glb_cdcooper AND
                           crapcra.cdprogra = 488          AND
                           crapcra.cdperiod = par_cdperiod NO-LOCK
                           BREAK BY crapcra.nrdconta :
        DO  TRANSACTION:
            FIND crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                               crapass.nrdconta = crapcra.nrdconta 
                               NO-LOCK NO-ERROR.
    
            IF  NOT AVAIL crapass THEN
                DO:
                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")     + 
                                      " - " + glb_cdprogra + "' --> '"      +
                                      glb_dscritic + " CONTA = "            +
                                      STRING(crapcra.nrdconta)              +
                                      " -- Conta nao encontrada na CRAPASS" +
                                      ">> log/proc_message.log").
                    NEXT.
                END.

            IF  crapass.dtdemiss <> ?  THEN
                NEXT.
    
            FIND craptab WHERE craptab.cdcooper = 0            AND
                               craptab.nmsistem = "CRED"       AND
                               craptab.tptabela = "USUARI"     AND
                               craptab.cdempres = 11           AND
                               craptab.cdacesso = "FORENVINFO" AND
                               craptab.tpregist = crapcra.cddfrenv 
                               NO-LOCK NO-ERROR.

            IF   ENTRY(2,craptab.dstextab,",") = "crapcem"  THEN
                 DO:

                      FIND crapcem WHERE 
                           crapcem.cdcooper = glb_cdcooper     AND
                           crapcem.nrdconta = crapcra.nrdconta AND
                           crapcem.idseqttl = crapcra.idseqttl AND
                           crapcem.cddemail = crapcra.cdseqinc
                           NO-LOCK NO-ERROR.
    
                      IF   NOT AVAILABLE crapcem   THEN
                           DO: 
                               glb_cdcritic = 812.
                               RUN fontes/critic.p.
                               glb_cdcritic = 0.
                               UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                                           " - " + glb_cdprogra + "' --> '" +
                                           glb_dscritic + " CONTA = " +
                                           STRING(crapcra.nrdconta) +
                                           ">> log/proc_message.log").
                               NEXT.
                           END.
    
                      IF   crapcra.cdrelato = 1  AND  /* Jornal */
                           aux_nmarqui1 <> ""  THEN  
                           DO:
                               ASSIGN aux_dsemail1 = aux_dsemail1 +
                                                     crapcem.dsdemail + ","
                                      aux_totmail1 = aux_totmail1 + 1.

                               CREATE t-enviados.
                               ASSIGN t-enviados.nrdconta = crapcra.nrdconta
                                      t-enviados.idseqttl = crapcra.idseqttl
                                      t-enviados.cdprogra = crapcra.cdprogra
                                      t-enviados.cdrelato = crapcra.cdrelato
                                      t-enviados.cdperiod = crapcra.cdperiod
                                      t-enviados.cddfrenv = crapcra.cddfrenv
                                      t-enviados.cdseqinc = crapcra.cdseqinc.

                           END.
                      ELSE
                      IF   crapcra.cdrelato = 2  AND  /* Programacao PROGRID */
                           aux_arqu2zip <> ""  THEN  
                           DO:
                               ASSIGN aux_dsemail2 = aux_dsemail2 +
                                                     crapcem.dsdemail + ","
                                      aux_totmail2 = aux_totmail2 + 1.

                               CREATE t-enviados.
                               ASSIGN t-enviados.nrdconta = crapcra.nrdconta
                                      t-enviados.idseqttl = crapcra.idseqttl
                                      t-enviados.cdprogra = crapcra.cdprogra
                                      t-enviados.cdrelato = crapcra.cdrelato
                                      t-enviados.cdperiod = crapcra.cdperiod
                                      t-enviados.cddfrenv = crapcra.cddfrenv
                                      t-enviados.cdseqinc = crapcra.cdseqinc.
                           END.
                 END.
                 
                 /************* Maximo 600 emails por vez **************/
                 IF   aux_totmail1 = 600  THEN
                      DO: 
                          aux_nmarqsp1 = "INFOR".  /* Nome dos arquivos textos que serão criados na pasta de spool*/

                          RUN envia_email (INPUT aux_nmarqui1, 
                                           INPUT aux_dsemail1,
                                           INPUT aux_nmarqsp1).
                              
                          RUN loga_enviados (INPUT 1).  /* Informativo JORNAL */ 
                                
                          ASSIGN aux_totmail1 = 0
                                 aux_dsemail1 = ""
                                 aux_nmarqsp1 = "".
                      END.
         
                 IF   aux_totmail2 = 600  THEN
                      DO: 
                          aux_nmarqsp2 = "PROGR".  /* Nome dos arquivos textos que serão criados na pasta de spool*/

                          RUN envia_email (INPUT aux_arqu2zip, 
                                           INPUT aux_dsemail2,
                                           INPUT aux_nmarqsp2).
                              
                          RUN loga_enviados (INPUT 2). /* Informat PROG.PROGRID */.
                                
                          ASSIGN aux_totmail2 = 0
                                 aux_dsemail2 = ""
                                 aux_nmarqsp2 = "".
                      END.                                           

        END. /* Do Transaction */

    END. /* For each crapcra */

    IF   aux_totmail1 <> 0  THEN
         DO: 
            aux_nmarqsp1 = "INFOR".  /* Nome dos arquivos textos que serão criados na pasta de spool*/

             RUN envia_email (INPUT aux_nmarqui1, 
                              INPUT aux_dsemail1,
                              INPUT aux_nmarqsp1).
                 
             RUN loga_enviados (INPUT 1).  /* Informativo JORNAL */.
                 
             ASSIGN aux_totmail1 = 0
                    aux_dsemail1 = ""
                    aux_nmarqsp1 = "".
         END.

    IF   aux_totmail2 <> 0  THEN
         DO:         
            aux_nmarqsp2 = "PROGR".  /* Nome dos arquivos textos que serão criados na pasta de spool*/

             RUN envia_email (INPUT aux_arqu2zip, 
                              INPUT aux_dsemail2,
                              INPUT aux_nmarqsp2).
                 
             RUN loga_enviados (INPUT 2).  /* Informativo PROG.PROGRID */.
                   
             ASSIGN aux_totmail2 = 0
                    aux_dsemail2 = ""
                    aux_nmarqsp2 = "".         
         END.


END PROCEDURE.


PROCEDURE envia_email.

    DEF INPUT PARAM par_nmarquiv AS CHAR.
    DEF INPUT PARAM par_dsdemail AS CHAR.
    DEF INPUT PARAM par_nmarqspo AS CHAR.
    DEF VAR aux_asunteml AS CHAR.

    /* Avalia o nome do Arquivo para determinar o assunto do email */   
    IF   (par_nmarqspo = "INFOR")   THEN
        ASSIGN aux_asunteml = "Informativo " + crapcop.nmrescop.        
    ELSE
        ASSIGN aux_asunteml = "Agenda de Eventos do Progrid - " + crapcop.nmrescop.
   /* FIM */


    IF   SEARCH ("/usr/coop/" + crapcop.dsdircop +
                 "/converte/" + par_nmarquiv) = ?  THEN
         /* Copia para diretorio converte para utilizar na BO */
         UNIX SILENT VALUE ("cp " + "/usr/coop/" + crapcop.dsdircop +
                            "/integra/" + par_nmarquiv + " /usr/coop/" +
                            crapcop.dsdircop + "/converte" +
                            " 2> /dev/null").

    RUN sistema/generico/procedures/b1wgen0011.p
        PERSISTENT SET b1wgen0011.
                                   
    RUN enviar_email_spool IN b1wgen0011
                         (INPUT glb_cdcooper,
                          INPUT glb_cdprogra,
                          INPUT par_dsdemail,
                          INPUT aux_asunteml,
                          INPUT par_nmarquiv,
                          INPUT par_nmarqspo,
                          INPUT TRUE).
                        
    DELETE PROCEDURE b1wgen0011.
  
END PROCEDURE.


PROCEDURE loga_enviados.

   DEF INPUT PARAM par_cdrelato AS INT.

   /* Logar os envios efetuados com sucesso */ 
   FOR EACH t-enviados WHERE t-enviados.cdrelato = par_cdrelato NO-LOCK:
                                    
       FIND gnrlema WHERE gnrlema.cdprogra = t-enviados.cdprogra AND
                          gnrlema.cdrelato = t-enviados.cdrelato
                          NO-LOCK NO-ERROR.
                
       ASSIGN aux_critilog = "Envio de informativo: " +
                             STRING(gnrlema.cdrelato) + "-" + gnrlema.nmrelato
              aux_nrdrowid = ROWID(t-enviados).
                
       RUN gera_log (INPUT aux_critilog,
                     INPUT TRUE).
                
       DO  aux_contador = 1 TO 3:
            
           IF   aux_contador = 1  THEN
                DO:
                    FIND craptab WHERE craptab.cdcooper = 0  AND
                                       craptab.nmsistem = "CRED"         AND
                                       craptab.tptabela = "USUARI"       AND
                                       craptab.cdempres = 11             AND
                                       craptab.cdacesso = "PERIODICID"   AND
                                       craptab.tpregist = t-enviados.cdperiod 
                                       NO-LOCK NO-ERROR.
                              
                    RUN gera_log_item (INPUT "Periodo",
                                       INPUT 0,
                                       INPUT STRING(t-enviados.cdperiod) + "-" 
                                             + craptab.dstextab).
                END.
           ELSE
           IF   aux_contador = 2  THEN
                DO:
                    FIND craptab WHERE craptab.cdcooper = 0            AND
                                       craptab.nmsistem = "CRED"       AND
                                       craptab.tptabela = "USUARI"     AND
                                       craptab.cdempres = 11           AND
                                       craptab.cdacesso = "FORENVINFO" AND
                                       craptab.tpregist = t-enviados.cddfrenv 
                                       NO-LOCK NO-ERROR.
                              
                    RUN gera_log_item (INPUT "Canal",
                                       INPUT 0,
                                       INPUT STRING(t-enviados.cddfrenv) + "-" +
                                             STRING(ENTRY(1,craptab.dstextab,
                                             ","))).
                END.
           ELSE
           IF   aux_contador = 3  THEN
                DO:
                    FIND crapcem WHERE 
                         crapcem.cdcooper = glb_cdcooper        AND
                         crapcem.nrdconta = t-enviados.nrdconta AND
                         crapcem.idseqttl = t-enviados.idseqttl AND
                         crapcem.cddemail = t-enviados.cdseqinc
                         NO-LOCK NO-ERROR.
                              
                    RUN gera_log_item (INPUT "Endereco",
                                       INPUT 0,
                                       INPUT STRING(t-enviados.cdseqinc) + 
                                             "-" + crapcem.dsdemail).
                END.      
       END.
       
       DELETE t-enviados.
   END.

END PROCEDURE.

/* Rotina para gerar log na nova estrutura - craplgm */
PROCEDURE gera_log:
    
    DEF INPUT PARAM par_dstransa LIKE craplgm.dstransa              NO-UNDO.
    DEF INPUT PARAM par_flgtrans LIKE craplgm.flgtrans              NO-UNDO.

    RUN sistema/generico/procedures/b1wgen0014.p PERSISTENT 
        SET h-b1wgen0014.
        
    IF  VALID-HANDLE(h-b1wgen0014)  THEN
        DO:              
            RUN gera_log IN h-b1wgen0014 (INPUT glb_cdcooper,
                                          INPUT 1,
                                          INPUT "",
                                          INPUT "AYLLOS",
                                          INPUT par_dstransa,
                                          INPUT glb_dtmvtolt,
                                          INPUT par_flgtrans,
                                          INPUT TIME,
                                          INPUT t-enviados.idseqttl,
                                          INPUT glb_cdprogra,
                                          INPUT t-enviados.nrdconta,
                                          OUTPUT aux_nrdrowid).
                                           
            DELETE PROCEDURE h-b1wgen0014.
        END.
        
END PROCEDURE.

/* Rotina para gerar log na nova estrutura - craplgi */
PROCEDURE gera_log_item:

    DEF INPUT PARAM par_nmdcampo LIKE craplgi.nmdcampo              NO-UNDO.
    DEF INPUT PARAM par_dsdadant LIKE craplgi.dsdadant              NO-UNDO.
    DEF INPUT PARAM par_dsdadatu LIKE craplgi.dsdadatu              NO-UNDO.

    RUN sistema/generico/procedures/b1wgen0014.p PERSISTENT 
        SET h-b1wgen0014.
        
    IF  VALID-HANDLE(h-b1wgen0014)  THEN
        DO:
            RUN gera_log_item IN h-b1wgen0014 (INPUT aux_nrdrowid,
                                               INPUT par_nmdcampo,
                                               INPUT par_dsdadant,
                                               INPUT par_dsdadatu).
                                           
            DELETE PROCEDURE h-b1wgen0014.
        END.
        
END PROCEDURE.

/* ..........................................................................*/
