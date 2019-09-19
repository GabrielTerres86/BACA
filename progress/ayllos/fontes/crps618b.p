/******************************************************************************
   Programa: fontes/crps618.p
   Sistema : Cobranca - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Rafael
   Data    : janeiro/2012.                     Ultima atualizacao: 30/12/2013

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Buscar confirmacao de registro dos titulos na CIP.
               Registrar titulos na CIP a partir de novembro/2013.
   
   Observacoes: O script /usr/local/cecred/bin/crps618.pl executa este 
                programa para verificar o registro/rejeicao dos titulos 
                na CIP enviados no dia.
                
                Horario de execucao: todos os dias, das 6:00h as 22:00h
                                     a cada 15 minutos.
                                     
   Alteracoes: 27/08/2013 - Alterado busca de registros de titulos utilizando
                            a data do movimento anterior (Rafael).
                            
               21/10/2013 - Incluido parametro novo na prep-retorno-cooperado
                            ref. ao numero de remessa do arquivo (Rafael).
                            
               15/11/2013 - Mudanças no processo de registro dos titulos na 
                            CIP: a partir da liberação de novembro/2013, os
                            titulos gerados serão registrados por este 
                            programa definidos pela CRON. O campo 
                            "crapcob.insitpro" irá utilizar os seguintes 
                            valores:
                            0 -> sacado comum (nao DDA);
                            1 -> sacado a verificar se é DDA;
                            2 -> Enviado a CIP;
                            3 -> Sacado DDA OK;
                            4 -> não haverá mais -> retornar a "zero";
                            
               03/12/2013 - Incluido nome da temp-table tt-remessa-dda nos 
                            campos onde faltavam o nome da tabela. (Rafael)
                            
               30/12/2013 - Ajuste na leitura/gravacao das informacoes dos
                            titulos ref. ao DDA. (Rafael)                            
 ........................................................................... */

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/b1wgen0087tt.i }

DEF BUFFER crabcob   FOR crapcob.
DEF VAR h-b1wgen0087 AS HANDLE                                  NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
DEF VAR aux_insitpro AS INTE                                    NO-UNDO.
DEF VAR aux_contador AS INTE                                    NO-UNDO.


/**** Executara na CECRED - Rafael ****/
ASSIGN glb_cdprogra = "crps618"
       glb_cdcooper = 3. 

UNIX SILENT VALUE("echo " + STRING(TODAY) + " " + 
                            STRING(TIME,"HH:MM:SS") +
                  " - " + glb_cdprogra + "' --> '"  +
                  "Programa iniciado" + " >> log/crps618.log").

/* Busca dados da cooperativa */
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         ASSIGN glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TODAY) + " " + 
                            STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         QUIT.
     END.     

/* Conexao com a JD */
RUN /usr/coop/sistema/generico/procedures/b1wgen9999.p
    PERSISTENT SET h-b1wgen9999.

IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
DO:
    UNIX SILENT VALUE("echo " + STRING(TODAY) + " " + 
                        STRING(TIME,"HH:MM:SS") +
                       " - " + glb_cdprogra + "' --> '"  +
                       "Handle invalido para BO b1wgen0087." + 
                       " >> log/crps618.log").
    QUIT.
END.

RUN p-conectajddda IN h-b1wgen9999 NO-ERROR.

IF  RETURN-VALUE <> "OK" THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TODAY) + " " + 
                    STRING(TIME,"HH:MM:SS") +
                   " - " + glb_cdprogra + "' --> '"  +
                   "Erro de conexao DDA." + 
                   " >> log/crps618.log").
    QUIT.
END.

RUN sistema/generico/procedures/b1wgen0087b.p 
    PERSISTENT SET h-b1wgen0087.

IF  NOT VALID-HANDLE(h-b1wgen0087) THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TODAY) + " " + 
                        STRING(TIME,"HH:MM:SS") +
                       " - " + glb_cdprogra + "' --> '"  +
                       "Handle invalido para BO b1wgen0087." + 
                       " >> log/crps618.log").
END.
     
/* Busca data do sistema */ 
FIND FIRST crapdat WHERE crapdat.cdcooper = glb_cdcooper  NO-LOCK NO-ERROR.

IF   NOT AVAIL crapdat THEN 
     DO:
         ASSIGN glb_cdcritic = 1.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TODAY) + " " + 
                                     STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         QUIT.
     END.

/**** Abortar programa quando processo estiver rodando   
IF   TODAY > crapdat.dtmvtolt  THEN
     DO:
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           "Processo rodando !!" + " >> log/proc_batch.log").
         QUIT.
     
     END.  
****/                          

EMPTY TEMP-TABLE tt-remessa-dda.
EMPTY TEMP-TABLE tt-retorno-dda.

/* rotina para registrar os títulos na CIP */

FOR EACH crapcop 
   WHERE crapcop.cdcooper <> 3
         NO-LOCK
   ,EACH crapcco 
   WHERE crapcco.cdcooper = crapcop.cdcooper
     AND crapcco.cddbanco = crapcop.cdbcoctl
     AND crapcco.flgregis = TRUE
         NO-LOCK
   ,EACH crapceb
   WHERE crapceb.cdcooper = crapcco.cdcooper
     AND crapceb.nrconven = crapcco.nrconven
         NO-LOCK
   ,EACH crapass
   WHERE crapass.cdcooper = crapceb.cdcooper
     AND crapass.nrdconta = crapceb.nrdconta
         NO-LOCK
   ,EACH crapcob 
   WHERE crapcob.cdcooper = crapceb.cdcooper
     AND crapcob.nrcnvcob = crapceb.nrconven
     AND crapcob.nrdconta = crapceb.nrdconta
     AND crapcob.flgregis = TRUE 
     AND crapcob.insitpro = 1 
     AND crapcob.dtmvtolt >= crapdat.dtmvtoan
     AND crapcob.dtmvtolt <= today
     AND crapcob.incobran = 0
     and crapcob.nrdconta = 3883418
         NO-LOCK
   ,EACH crapsab 
   WHERE crapsab.cdcooper = crapcob.cdcooper
     AND crapsab.nrdconta = crapcob.nrdconta
     AND crapsab.nrinssac = crapcob.nrinssac
         NO-LOCK

     BREAK BY crapcob.nrinssac :

    IF  FIRST-OF(crapcob.nrinssac) THEN DO:

        EMPTY TEMP-TABLE tt-verifica-sacado.

        CREATE tt-verifica-sacado.
        ASSIGN tt-verifica-sacado.nrcpfcgc = INT64(crapcob.nrinssac)
               tt-verifica-sacado.tppessoa = IF crapcob.cdtpinsc = 1 
                                              THEN 
                                                "F"  /*Fisica*/
                                              ELSE 
                                                "J" /*Juridica*/
               tt-verifica-sacado.flgsacad  = ?.

        RUN Verifica-Sacado-DDA IN h-b1wgen0087
            (INPUT-OUTPUT TABLE tt-verifica-sacado).

        IF  RETURN-VALUE = "OK" THEN DO:

            FIND FIRST tt-verifica-sacado 
                 NO-LOCK NO-ERROR.

            IF  AVAIL(tt-verifica-sacado) THEN DO:
                IF  tt-verifica-sacado.flgsacad THEN
                    aux_insitpro = 2. /* enviar/enviado p/ CIP */
                ELSE
                    aux_insitpro = 0. /* nao eh sacado DDA */
            END.
        END.
    END.

    /* se sacado for DDA, entao titulo eh DDA */
    IF  aux_insitpro = 2 THEN DO:

        DO aux_contador = 1 TO 10:

            FIND FIRST crabcob WHERE
                 ROWID(crabcob) = ROWID(crapcob)
                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAIL crabcob THEN DO:
                IF  LOCKED crabcob THEN
                    NEXT.                 
            END.

            ASSIGN crabcob.flgcbdda = TRUE
                   crabcob.insitpro = 2. /* enviar p/ CIP */

            LEAVE.
        END.

        RELEASE crabcob.

        RUN p_cria_titulo.

        IF  RETURN-VALUE <> "OK" THEN DO:

            DO aux_contador = 1 TO 10:
    
                FIND FIRST crabcob WHERE
                     ROWID(crabcob) = ROWID(crapcob)
                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                IF  NOT AVAIL crabcob THEN DO:
                    IF  LOCKED crabcob THEN
                        NEXT.                 
                END.
        
                ASSIGN crabcob.flgcbdda = FALSE
                       crabcob.insitpro = 0
                       crabcob.idtitleg = 0
                       crabcob.idopeleg = 0.

                LEAVE.
            END. /* fim - aux_contador */

            RELEASE crabcob.
        END. /* fim - return_value */
    END.
    ELSE
    DO: 
        DO aux_contador = 1 TO 10:

            FIND FIRST crabcob WHERE
                 ROWID(crabcob) = ROWID(crapcob)
                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAIL crabcob THEN DO:
                IF  LOCKED crabcob THEN
                    NEXT.                 
            END.
    
            ASSIGN crabcob.flgcbdda = FALSE
                   crabcob.insitpro = 0.

            LEAVE.
        END. /* fim - aux_contador */

        RELEASE crabcob.
    END.
    
END. 

/* executar procedure remessa-titulos-dda - b1wgen0087.p */            
RUN remessa-titulos-dda  IN h-b1wgen0087
   (INPUT-OUTPUT TABLE tt-remessa-DDA,
          OUTPUT TABLE tt-retorno-DDA).

IF  VALID-HANDLE(h-b1wgen0087) THEN
    DELETE PROCEDURE h-b1wgen0087.

/* desconectar banco JD */
IF VALID-HANDLE(h-b1wgen9999) THEN
DO:
    RUN p-desconectajddda IN h-b1wgen9999.
    DELETE PROCEDURE h-b1wgen9999.
END.

/* FIM - rotina para registrar os títulos na CIP */


/* rotina para buscar o "OK" da CIP */
EMPTY TEMP-TABLE tt-remessa-dda.
EMPTY TEMP-TABLE tt-retorno-dda.

FOR EACH crapcop 
   WHERE crapcop.cdcooper <> 3
         NO-LOCK
   ,EACH crapcco 
   WHERE crapcco.cdcooper = crapcop.cdcooper
     AND crapcco.cddbanco = crapcop.cdbcoctl
     AND crapcco.flgregis = TRUE
         NO-LOCK
   ,EACH crapceb
   WHERE crapceb.cdcooper = crapcco.cdcooper
     AND crapceb.nrconven = crapcco.nrconven
         NO-LOCK
   ,EACH crapcob 
   WHERE crapcob.cdcooper = crapceb.cdcooper
     AND crapcob.nrcnvcob = crapceb.nrconven
     AND crapcob.nrdconta = crapceb.nrdconta
     AND crapcob.flgregis = TRUE 
     AND crapcob.flgcbdda = TRUE
     AND crapcob.insitpro = 2
     AND crapcob.dtmvtolt >= crapdat.dtmvtoan
     AND crapcob.incobran = 0
     and crapcob.nrdconta = 3883418
     NO-LOCK :
   
    FIND crapban WHERE crapban.cdbccxlt = crapcob.cdbandoc
        NO-LOCK NO-ERROR.

    /* carrega temp remessa-dda para verificacao */
    CREATE tt-remessa-dda.
    ASSIGN tt-remessa-dda.nrispbif = crapban.nrispbif
           tt-remessa-dda.cdlegado = "LEG"
           tt-remessa-dda.idtitleg = STRING(crapcob.idtitleg)
           tt-remessa-dda.idopeleg = crapcob.idopeleg
           tt-remessa-dda.insitpro = crapcob.insitpro.
  
END.

IF TEMP-TABLE tt-remessa-dda:HAS-RECORDS THEN
   RUN verifica_titulos_dda.
ELSE
   UNIX SILENT VALUE("echo " + STRING(TODAY) + " " + 
                               STRING(TIME,"HH:MM:SS") +
                     " - " + glb_cdprogra + "' --> '"  +
                     "Nenhum titulo registrado" + " >> log/crps618.log").

UNIX SILENT VALUE("echo " + STRING(TODAY) + " " + 
                  STRING(TIME,"HH:MM:SS") +
                  " - " + glb_cdprogra + "' --> '"  +
                  "Programa finalizado" + " >> log/crps618.log").

IF  VALID-HANDLE(h-b1wgen0087) THEN 
    DELETE PROCEDURE h-b1wgen0087.

IF  VALID-HANDLE(h-b1wgen9999) THEN 
    DELETE PROCEDURE h-b1wgen9999.

/*............................................................................*/

/* Rotina para verificar titulos confirmados/rejeitados na CIP */
PROCEDURE verifica_titulos_dda:

    DEF VAR h-b1wgen0087 AS HANDLE                     NO-UNDO.
    DEF VAR h-b1wgen0088 AS HANDLE                     NO-UNDO.
    DEF VAR h-b1wgen0090 AS HANDLE                     NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                     NO-UNDO.
    DEF VAR aux_nrdocmto AS DECIMAL FORMAT "zzz,zzz,9" NO-UNDO.
    DEF VAR aux_qttitreg AS INTE INIT 0                NO-UNDO.
    DEF VAR aux_qttitrej AS INTE INIT 0                NO-UNDO.

    /* conectar no banco da JD */
    RUN sistema/generico/procedures/b1wgen9999.p
        PERSISTENT SET h-b1wgen9999.

    RUN p-conectajddda IN h-b1wgen9999.

    RUN sistema/generico/procedures/b1wgen0087b.p 
        PERSISTENT SET h-b1wgen0087.

    IF NOT VALID-HANDLE(h-b1wgen0087) THEN
    DO:
        glb_dscritic = "Handle invalido para a BO b1wgen0087.".
         UNIX SILENT VALUE("echo " + STRING(TODAY) + " " + 
                            STRING(TIME,"HH:MM:SS") +      
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/crps618.log").
    END.

    RUN Retorno-Operacao-Titulos-DDA IN h-b1wgen0087
        ( INPUT TABLE tt-remessa-dda,
         OUTPUT TABLE tt-retorno-dda).

    DELETE PROCEDURE h-b1wgen0087.       
        
    /*FIND FIRST tt-retorno-dda NO-LOCK NO-ERROR.*/
    
    /*IF NOT AVAIL tt-retorno-dda THEN LEAVE.*/

    /*IF tt-retorno-dda.insitpro = 2 THEN  
    DO:
      MESSAGE "Nao registrado ainda. " VIEW-AS ALERT-BOX.
      RETURN "NOK".
    END.*/

    IF NOT VALID-HANDLE(h-b1wgen0088) THEN
       RUN sistema/generico/procedures/b1wgen0088.p
           PERSISTENT SET h-b1wgen0088.

    IF NOT VALID-HANDLE(h-b1wgen0088) THEN
    DO:
        glb_dscritic = "Handle invalido para a BO b1wgen0088.".
        UNIX SILENT VALUE("echo " + STRING(TODAY) + " " + 
                           STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          glb_dscritic + " >> log/crps618.log").
    END. 

    FOR EACH tt-retorno-dda 
        WHERE tt-retorno-dda.insitpro = 4 /* EJ/EC erro */
        NO-LOCK:

        FIND FIRST crapcob WHERE crapcob.idtitleg = DECI(tt-retorno-dda.idtitleg)
             USE-INDEX crapcob7.

        IF AVAIL crapcob THEN
        DO:
            ASSIGN crapcob.insitpro = 0 /* sacado comum */
                   crapcob.flgcbdda = FALSE.

            RUN cria-log-cobranca IN h-b1wgen0088
                  (INPUT ROWID(crapcob),
                   INPUT glb_cdoperad,
                   INPUT TODAY,
                   INPUT "Titulo Rejeitado na CIP" ).

            ASSIGN aux_qttitrej = aux_qttitrej + 1.

            
            /* nao rejeitar mais o titulo caso a CIP rejeitar 
            IF crapcob.inemiten = 2 THEN /* cooperado emite e expede */
            DO:
                ASSIGN crapcob.incobran = 4. /* titulo rejeitado */

                /* gerar retorno de entrada rejeitada ao cooperado */
                RUN sistema/generico/procedures/b1wgen0090.p PERSISTENT 
                    SET h-b1wgen0090.

                IF  NOT VALID-HANDLE(h-b1wgen0090) THEN
                    RETURN "NOK".

                FIND FIRST crapcop WHERE crapcop.cdcooper = crapcob.cdcooper
                    NO-LOCK NO-ERROR.

                RUN prep-retorno-cooperado 
                    IN h-b1wgen0090 (INPUT ROWID(crapcob),
                                     INPUT 3, /* ent rejeitada */
                                     INPUT "",
                                     INPUT 0,
                                     INPUT crapcop.cdbcoctl,
                                     INPUT crapcop.cdagectl,
                                     INPUT TODAY,
                                     INPUT glb_cdoperad,
                                     INPUT crapcob.nrremass ).

                DELETE PROCEDURE h-b1wgen0090.
            END. /* if crapcob.inemiten = 2 */ */

            /* nao registrar mais o titulo no BB */
            /*IF crapcob.inemiten = 1 THEN /* banco emite e expede */
            DO:
                ASSIGN crapcob.incobran = 4. /* titulo rejeitado */

                RUN cria-log-cobranca IN h-b1wgen0088
                                  (INPUT ROWID(crapcob),
                                   INPUT glb_cdoperad,
                                   INPUT TODAY,
                                   INPUT "Titulo Rejeitado - Sacado Comum").

                ASSIGN glb_dscritic = "Titulo: " + 
                                      STRING(crapcob.cdcooper) + " / " +
                                      STRING(crapcob.nrcnvcob) + " / " +
                                      STRING(crapcob.nrdconta) + " / " + 
                                      STRING(crapcob.nrdocmto) + " - " + 
                                      "Titulo Rejeitado - Sacado Comum".

                UNIX SILENT VALUE("echo " + STRING(TODAY) + " " + 
                                  STRING(TIME,"HH:MM:SS") +
                                  " - " + glb_cdprogra + "' --> '"  +
                                  glb_dscritic + " >> log/crps618.log").

                /* buscar convenio Banco do Brasil */
                FIND crapcco WHERE crapcco.cdcooper = crapcob.cdcooper
                               AND crapcco.cddbanco = 001
                               AND crapcco.flgativo = TRUE
                               AND crapcco.flgregis = TRUE
                                                     /* cob. Registrada */
                               AND crapcco.flginter = TRUE /* internet */
                               AND crapcco.dsorgarq = "INTERNET"
                               NO-LOCK NO-ERROR.

                IF AVAIL crapcco THEN
                DO:
                    /* buscar o convenio cadastrado do cooperado */
                    FIND crapceb WHERE crapceb.cdcooper = crapcco.cdcooper
                                   AND crapceb.nrdconta = crapcob.nrdconta
                                   AND crapceb.nrconven = crapcco.nrconven
                                   NO-LOCK NO-ERROR.                        

                    IF AVAIL crapceb THEN
                    DO:
                        /* buscar o ultimo titulo do documento do cooperado
                                                        no novo convenio */
                        FIND LAST crapcob 
                                WHERE crapcob.cdcooper = crapceb.cdcooper
                                  AND crapcob.nrdconta = crapceb.nrdconta
                                  AND crapcob.nrcnvcob = crapcco.nrconven
                                  AND crapcob.nrdctabb = crapcco.nrdctabb
                                  AND crapcob.cdbandoc = crapcco.cddbanco
                                  NO-LOCK NO-ERROR.

                        IF AVAIL crapcob THEN
                        DO:
                            ASSIGN aux_nrdocmto = crapcob.nrdocmto + 1.

                            CREATE crapcob.
                            BUFFER-COPY crapcob 
                                 EXCEPT crapcob.nrcnvcob crapcob.nrdocmto 
                                        crapcob.incobran crapcob.cdcartei 
                                        crapcob.nrnosnum crapcob.cdbandoc
                                        crapcob.nrdctabb
                                     TO crapcob 
                                 ASSIGN crapcob.nrcnvcob = crapcco.nrconven
                                        crapcob.cdbandoc = crapcco.cddbanco
                                        crapcob.nrdctabb = crapcco.nrdctabb
                                        crapcob.cdcartei = crapcco.cdcartei
                                        crapcob.incobran = 0                                                                                    
                                        crapcob.nrdocmto = aux_nrdocmto
                                        crapcob.nrnosnum = 
                                 STRING(crapcco.nrconven, "9999999") + 
                                 STRING(crapceb.nrcnvceb, "9999") + 
                                 STRING(aux_nrdocmto, "999999").

                            RUN gera_pedido_remessa IN h-b1wgen0088
                                                 (INPUT ROWID(crapcob),
                                                  INPUT crapdat.dtmvtocd,
                                                  INPUT glb_cdoperad).

                            RUN cria-log-cobranca IN h-b1wgen0088
                                  (INPUT ROWID(crapcob),
                                   INPUT glb_cdoperad,
                                   INPUT crapdat.dtmvtocd,
                                   INPUT "Titulo Gerado - Sacado nao DDA").

                        END.

                    END.
                END.
            END. /* if crapcob.inemiten = 1 */ */

        END. /* if avail crapcob */

    END. /* for each tt-retorno-dda */

    /* desconectar banco JD */
    IF VALID-HANDLE(h-b1wgen9999) THEN
    DO:
        RUN p-desconectajddda IN h-b1wgen9999.
        DELETE PROCEDURE h-b1wgen9999.
    END.

    IF NOT VALID-HANDLE(h-b1wgen0088) THEN
       RUN sistema/generico/procedures/b1wgen0088.p
           PERSISTENT SET h-b1wgen0088.

    /* gerar retorno de entrada confirmada ao cooperado */
    RUN sistema/generico/procedures/b1wgen0090.p PERSISTENT 
        SET h-b1wgen0090.

    IF  NOT VALID-HANDLE(h-b1wgen0090) THEN
        RETURN "NOK".

    FOR EACH  tt-retorno-dda 
        WHERE tt-retorno-dda.insitpro = 3 /* RC - Registro CIP */
        NO-LOCK:

        ASSIGN aux_qttitreg = aux_qttitreg + 1.

        FIND crapcob WHERE crapcob.idtitleg = DECI(tt-retorno-dda.idtitleg)
             USE-INDEX crapcob7 NO-ERROR.

        IF AVAIL crapcob THEN
        DO:
            ASSIGN crapcob.insitpro = tt-retorno-dda.insitpro
                   crapcob.flgcbdda = TRUE.

            RUN cria-log-cobranca IN h-b1wgen0088
                  (INPUT ROWID(crapcob),
                   INPUT glb_cdoperad,
                   INPUT TODAY,
                   INPUT "Titulo Registrado - CIP").

            FIND FIRST crapret WHERE
                       crapret.cdcooper = crapcob.cdcooper AND
                       crapret.nrdconta = crapcob.nrdconta AND
                       crapret.nrcnvcob = crapcob.nrcnvcob AND
                       crapret.nrdocmto = crapcob.nrdocmto AND
                       crapret.cdocorre = 2                AND
                       crapret.cdmotivo = ""
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  AVAIL(crapret) THEN 
                ASSIGN crapret.cdmotivo = "A4".

            /*FIND FIRST crapcop WHERE crapcop.cdcooper = crapcob.cdcooper
                NO-LOCK NO-ERROR.

            RUN prep-retorno-cooperado IN h-b1wgen0090 
                (INPUT ROWID(crapcob),
                 INPUT 2,
                 /* A4 = sacado DDA ~*/
                 INPUT "A4", 
                 INPUT 0,
                 INPUT crapcop.cdbcoctl,
                 INPUT crapcop.cdagectl,
                 INPUT TODAY,
                 INPUT glb_cdoperad,
                 INPUT crapcob.nrremass ).*/

        END. /* if avail crapcob */

    END. /* for each tt-retorno-dda*/

    IF  VALID-HANDLE(h-b1wgen0090) THEN 
        DELETE PROCEDURE h-b1wgen0090.

    IF  VALID-HANDLE(h-b1wgen0088) THEN 
        DELETE PROCEDURE h-b1wgen0088.

    IF  VALID-HANDLE(h-b1wgen9999) THEN DO:
        RUN p-desconectajddda IN h-b1wgen9999 NO-ERROR.
        DELETE PROCEDURE h-b1wgen9999.
    END.

    IF aux_qttitreg > 0 THEN
    DO:
       ASSIGN glb_dscritic = "Titulos registrados: " + STRING(aux_qttitreg).
       UNIX SILENT VALUE("echo " + STRING(TODAY) + " " + 
                         STRING(TIME,"HH:MM:SS") +
                         " - " + glb_cdprogra + "' --> '"  +
                         glb_dscritic + " >> log/crps618.log").
    END.
    ELSE
    DO:
       UNIX SILENT VALUE("echo " + STRING(TODAY) + " " + 
                         STRING(TIME,"HH:MM:SS") +
                         " - " + glb_cdprogra + "' --> '"  +
                         "Nenhum titulo registrado" + " >> log/crps618.log").
    END.

    IF aux_qttitrej > 0 THEN
    DO:
       ASSIGN glb_dscritic = "Titulos rejeitados: " + STRING(aux_qttitrej).
       UNIX SILENT VALUE("echo " + STRING(TODAY) + " " + 
                         STRING(TIME,"HH:MM:SS") +
                         " - " + glb_cdprogra + "' --> '"  +
                         glb_dscritic + " >> log/crps618.log").
    END.

    RETURN "OK".

END PROCEDURE.

/*procedure para criacao de titulo */
PROCEDURE p_cria_titulo:
                                                        
    DEF VAR aux_cdbarras AS CHAR                            NO-UNDO.
    DEF VAR aux_dsdjuros AS CHAR                            NO-UNDO.
    DEF VAR aux_vltarifa LIKE crapcct.vltarifa              NO-UNDO.
    DEF VAR aux_cdtarhis LIKE crapcct.cdtarhis              NO-UNDO.
    DEF VAR aux_nrnosnum LIKE crapcob.nrnosnum              NO-UNDO.
    DEF VAR aux_cddespec AS CHAR                            NO-UNDO.
    DEF VAR aux_dtemissa AS DATE                            NO-UNDO.
    
    IF  crapcco.cddbanco <> 085 THEN
        ASSIGN aux_nrnosnum = STRING(crapcob.nrcnvcob, "9999999") + 
                              STRING(crapceb.nrcnvceb, "9999") + 
                              STRING(crapcob.nrdocmto, "999999").
    ELSE
        ASSIGN aux_nrnosnum = STRING(crapcob.nrdconta,"99999999") +
                              STRING(crapcob.nrdocmto,"999999999").
        
    /*Rafael Ferreira (Mouts) - INC0022229
      Conforme informado por Deise Carina Tonn da area de Negócio, esta validaçao nao é mais necessária
      pois agora Todas as cidades podem ter protesto*/
    /*FIND crappnp WHERE crappnp.nmextcid = crapsab.nmcidsac AND
                       crappnp.cduflogr = crapsab.cdufsaca NO-LOCK NO-ERROR.
    
    IF  AVAILABLE crappnp THEN
    DO:
        ASSIGN crapcob.flgdprot = FALSE 
               crapcob.qtdiaprt = 0 
               crapcob.indiaprt = 3.

        CREATE crapcol.
        ASSIGN crapcol.cdcooper = crapcob.cdcooper
               crapcol.nrdconta = crapcob.nrdconta
               crapcol.nrdocmto = crapcob.nrdocmto
               crapcol.nrcnvcob = crapcob.nrcnvcob
               crapcol.dslogtit = "Obs.: Praca nao executante de protesto"
               crapcol.cdoperad = "1"
               crapcol.dtaltera = TODAY
               crapcol.hrtransa = TIME.
    END.*/

    ASSIGN  crapcob.idopeleg = NEXT-VALUE(seqcob_idopeleg)                              
            crapcob.idtitleg = NEXT-VALUE(seqcob_idtitleg).
                
    RUN p_calc_codigo_barras(OUTPUT aux_cdbarras).

    IF crapcob.tpjurmor = 1 THEN
        ASSIGN aux_dsdjuros = "1".
    ELSE IF crapcob.tpjurmor = 2 THEN
        ASSIGN aux_dsdjuros = "3".
    ELSE IF crapcob.tpjurmor = 3 THEN
        ASSIGN aux_dsdjuros = "5".

    CASE crapcob.cddespec: 
        WHEN 1 THEN ASSIGN aux_cddespec = "02".
        WHEN 2 THEN ASSIGN aux_cddespec = "04".
        WHEN 3 THEN ASSIGN aux_cddespec = "12".
        WHEN 4 THEN ASSIGN aux_cddespec = "21".
        WHEN 5 THEN ASSIGN aux_cddespec = "23".
        WHEN 6 THEN ASSIGN aux_cddespec = "17".
        WHEN 7 THEN ASSIGN aux_cddespec = "99".
    END CASE.

    IF  NOT AVAIL(crapban) THEN
        FIND crapban WHERE crapban.cdbccxlt = crapcob.cdbandoc
             NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapban THEN RETURN "NOK".

    IF  NOT AVAIL(crapdat) THEN
        FIND crapdat WHERE crapdat.cdcooper = crapcob.cdcooper
             NO-LOCK NO-ERROR.

    IF  AVAIL(crapdat) THEN DO:
        IF  TODAY > crapdat.dtmvtolt THEN
            ASSIGN aux_dtemissa = crapdat.dtmvtolt.
        ELSE
            IF  TODAY < crapdat.dtmvtolt THEN
                ASSIGN aux_dtemissa = crapdat.dtmvtoan.
            ELSE
                ASSIGN aux_dtemissa = crapdat.dtmvtolt.
    END.
    ELSE
        aux_dtemissa = TODAY.

    CREATE tt-remessa-dda.
    ASSIGN tt-remessa-dda.cdlegado = "LEG"
           tt-remessa-dda.nrispbif = crapban.nrispbif
           tt-remessa-DDA.idopeleg = crapcob.idopeleg
           tt-remessa-DDA.idtitleg = STRING(crapcob.idtitleg)
           tt-remessa-dda.tpoperad = "I"
           tt-remessa-dda.cdifdced = 085
           tt-remessa-dda.tppesced = (IF crapass.inpessoa = 1 THEN "F" ELSE "J")
           tt-remessa-dda.nrdocced = INT64(crapass.nrcpfcgc)
           tt-remessa-dda.nmdocede = REPLACE(crapass.nmprimtl,"&","%26")
           tt-remessa-dda.cdageced = INTE(STRING(crapcop.cdagectl,"9999"))
           tt-remessa-dda.nrctaced = crapcob.nrdconta
           tt-remessa-dda.tppesori = (IF crapass.inpessoa = 1 THEN "F" ELSE "J")
           tt-remessa-dda.nrdocori = INT64(crapass.nrcpfcgc)
           tt-remessa-dda.nmdoorig = REPLACE(crapass.nmprimtl,"&","%26")
           tt-remessa-dda.tppessac = (IF crapsab.cdtpinsc = 1 THEN 
                          "F" 
                       ELSE 
                          "J")
           tt-remessa-dda.nrdocsac = crapsab.nrinssac
           tt-remessa-dda.nmdosaca = crapsab.nmdsacad
           tt-remessa-DDA.dsendsac = crapsab.dsendsac
           tt-remessa-dda.dscidsac = crapsab.nmcidsac
           tt-remessa-dda.dsufsaca = crapsab.cdufsaca
           tt-remessa-DDA.nrcepsac = crapsab.nrcepsac
           tt-remessa-dda.tpdocava = (IF crapcob.cdtpinav = 0 THEN 0 
                       ELSE crapcob.cdtpinav)
           tt-remessa-dda.nrdocava = (IF crapcob.cdtpinav = 0 THEN ? 
                       ELSE INT64(crapcob.nrinsava))
           tt-remessa-dda.nmdoaval = (IF TRIM(crapcob.nmdavali) = "" THEN ? 
                       ELSE TRIM(crapcob.nmdavali))
           tt-remessa-DDA.cdcartei = "1" /* cobranca simples */
           tt-remessa-dda.cddmoeda = "09" /* 9 = Real */
           tt-remessa-dda.dsnosnum = crapcob.nrnosnum
           tt-remessa-dda.dscodbar = aux_cdbarras
           tt-remessa-DDA.dtvencto = 
                           INTE(STRING(YEAR(crapcob.dtvencto),"9999") +
                           STRING(MONTH(crapcob.dtvencto), "99") + 
                           STRING(DAY(crapcob.dtvencto), "99"))
           tt-remessa-dda.vlrtitul = crapcob.vltitulo
           tt-remessa-dda.nrddocto = STRING(crapcob.dsdoccop)
           tt-remessa-dda.cdespeci = aux_cddespec
           tt-remessa-dda.dtemissa = 
                           INTE(STRING(YEAR(aux_dtemissa),"9999") +
                                STRING(MONTH(aux_dtemissa), "99") + 
                                STRING(DAY(aux_dtemissa), "99"))
           tt-remessa-dda.nrdiapro = (IF crapcob.flgdprot = TRUE THEN crapcob.qtdiaprt ELSE ?)
           tt-remessa-dda.tpdepgto = 3 /* vencto indeterminado */
           tt-remessa-dda.dtlipgto = (IF crapcob.flgdprot = TRUE THEN
                 INTE(STRING(YEAR(crapcob.dtvencto + crapcob.qtdiaprt),"9999") +
                      STRING(MONTH(crapcob.dtvencto + crapcob.qtdiaprt), "99") + 
                      STRING(DAY(crapcob.dtvencto + crapcob.qtdiaprt), "99"))
                 ELSE
                 INTE(STRING(YEAR(crapcob.dtvencto + 15),"9999") +
                      STRING(MONTH(crapcob.dtvencto + 15), "99") + 
                      STRING(DAY(crapcob.dtvencto + 15), "99")))
           tt-remessa-dda.indnegoc = "N"
           tt-remessa-dda.vlrabati = crapcob.vlabatim
           tt-remessa-dda.dtdjuros = (IF crapcob.vljurdia > 0 THEN 
                          INTE(STRING(YEAR(crapcob.dtvencto + 1),"9999") +
                               STRING(MONTH(crapcob.dtvencto + 1), "99") + 
                               STRING(DAY(crapcob.dtvencto + 1), "99"))
                       ELSE ?)
           tt-remessa-dda.dsdjuros = aux_dsdjuros 
           tt-remessa-DDA.vlrjuros = (IF crapcob.vljurdia > 0 THEN crapcob.vljurdia ELSE 0)
           tt-remessa-dda.dtdmulta = (IF crapcob.tpdmulta = 3 THEN ?
                                               ELSE INTE(STRING(YEAR(crapcob.dtvencto + 1),"9999") +
                                 STRING(MONTH(crapcob.dtvencto + 1), "99") + 
                                 STRING(DAY(crapcob.dtvencto + 1), "99")))
           tt-remessa-dda.cddmulta = (IF crapcob.tpdmulta = 3 THEN "3"
                                               ELSE STRING(crapcob.tpdmulta))
           tt-remessa-DDA.vlrmulta = (IF crapcob.tpdmulta = 3 THEN 0
                                               ELSE crapcob.vlrmulta)
           tt-remessa-DDA.flgaceit = (IF crapcob.flgaceit THEN "S"
                                               ELSE "N")
           tt-remessa-dda.dtddesct = (IF crapcob.vldescto > 0 THEN 
                           INTE(STRING(YEAR(crapcob.dtvencto),"9999") +
                           STRING(MONTH(crapcob.dtvencto), "99") + 
                           STRING(DAY(crapcob.dtvencto), "99"))
                       ELSE ?)
           tt-remessa-dda.cdddesct = (IF crapcob.vldescto > 0 THEN "1" ELSE "0")
           tt-remessa-dda.vlrdesct = (IF crapcob.vldescto > 0 THEN crapcob.vldescto ELSE 0)
           tt-remessa-dda.dsinstru = crapcob.dsdinstr
           tt-remessa-dda.tpmodcal = "01"
           tt-remessa-dda.flavvenc = "S".
                       
    CREATE crapcol.
    ASSIGN crapcol.cdcooper = crapcob.cdcooper
           crapcol.nrdconta = crapcob.nrdconta
           crapcol.nrcnvcob = crapcob.nrcnvcob
           crapcol.nrdocmto = crapcob.nrdocmto
           crapcol.dslogtit = "Titulo enviado a CIP"
           crapcol.cdoperad = "1"
           crapcol.dtaltera = TODAY
           crapcol.hrtransa = TIME.

    RETURN "OK".

END PROCEDURE.

PROCEDURE p_calc_codigo_barras:

    DEF OUTPUT PARAM par_cod_barras        AS CHAR     NO-UNDO. 
    
    DEF VAR aux      AS CHAR                           NO-UNDO.
    DEF VAR dtini    AS DATE INIT "10/07/1997"         NO-UNDO.

    ASSIGN aux = string(crapcob.cdbandoc,"999")
                           + "9" /* moeda */
                           + "1" /* nao alterar - constante */
                           + string((crapcob.dtvencto - dtini), "9999")
                           + string(crapcob.vltitulo * 100, "9999999999")
                           + string(crapcob.nrcnvcob, "999999")
                           + string(crapcob.nrnosnum, "99999999999999999")
                           + string(crapcob.cdcartei, "99")
               glb_nrcalcul = DECI(aux).

    RUN sistema/ayllos/fontes/digcbtit.p.
        ASSIGN par_cod_barras = STRING(glb_nrcalcul, 
           "99999999999999999999999999999999999999999999").
        
END PROCEDURE.


/* .......................................................................... */
