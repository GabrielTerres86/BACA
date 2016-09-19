/* .............................................................................

   Programa: includes/tab004.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : James Prust Junior
   Data    : Julho/2013.                        Ultima atualizacao: 27/07/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela TAB004.

   Alteracoes: 
                22/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
    
                23/07/2015 - Alterado var de tel_txjurneg para tel_txnegcal e 
                            tel_txjursaq para tel_txsaqcal. Adicionado var
                            tel_txnegfix e tel_txsaqfix. Adicionado campos de 
                            Taxa fixa. (Jorge - Rodrigo) - SD 307304
............................................................................. */
ALTERA: DO TRANSACTION
    ON ERROR  UNDO ALTERA, LEAVE ALTERA
    ON QUIT   UNDO ALTERA, LEAVE ALTERA
    ON STOP   UNDO ALTERA, LEAVE ALTERA 
    ON ENDKEY UNDO ALTERA, LEAVE ALTERA:
    
    DO  aux_contador = 1 TO 10:
        FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND 
                           craptab.nmsistem = "CRED"         AND
                           craptab.tptabela = "USUARI"       AND
                           craptab.cdempres = 11             AND
                           craptab.cdacesso = "JUROSNEGAT"   AND
                           craptab.tpregist = 001            
                           EXCLUSIVE-LOCK NO-ERROR.
        IF  NOT AVAILABLE craptab   THEN
            IF  LOCKED craptab THEN
                 DO:
                    RUN sistema/generico/procedures/b1wgen9999.p
                    PERSISTENT SET h-b1wgen9999.
                    
                    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                                         INPUT "banco",
                                         INPUT "craptab",
                                         OUTPUT par_loginusr,
                                         OUTPUT par_nmusuari,
                                         OUTPUT par_dsdevice,
                                         OUTPUT par_dtconnec,
                                         OUTPUT par_numipusr).
                    
                    DELETE PROCEDURE h-b1wgen9999.
                    
                    ASSIGN aux_dadosusr = 
                    "077 - Tabela sendo alterada p/ outro terminal.".
                    
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    MESSAGE aux_dadosusr.
                    PAUSE 3 NO-MESSAGE.
                    LEAVE.
                    END.
                    
                    ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                  " - " + par_nmusuari + ".".
                    
                    HIDE MESSAGE NO-PAUSE.
                    
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    MESSAGE aux_dadosusr.
                    PAUSE 5 NO-MESSAGE.
                    LEAVE.
                    END.
                    
                    UNDO ALTERA, LEAVE ALTERA.
                  
                 END.
            ELSE
                 DO:
                     glb_cdcritic = 55.
                     CLEAR FRAME f_tab004.
                     LEAVE.
                 END.
        ELSE
            DO:
                glb_cdcritic = 0.
                LEAVE.
            END.
    END.

    ASSIGN tel_txnegcal = DECIMAL(SUBSTRING(craptab.dstextab,1,10))
           tel_txnegfix = DECIMAL(SUBSTRING(craptab.dstextab,12,6))
           log_txjurneg = tel_txnegfix.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        DISPLAY tel_txnegcal WITH FRAME f_tab004.
        UPDATE  tel_txnegfix WITH FRAME f_tab004.
        LEAVE.
    END.

    /* F4 ou FIM */
    IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN 
        UNDO ALTERA, LEAVE ALTERA.
    
    /* Atualiza o Registro na tabela */
    ASSIGN SUBSTRING(craptab.dstextab,12,6) = STRING(tel_txnegfix,"999.99").

    DO  aux_contador = 1 TO 10:
        FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND 
                           craptab.nmsistem = "CRED"         AND
                           craptab.tptabela = "USUARI"       AND
                           craptab.cdempres = 11             AND
                           craptab.cdacesso = "JUROSSAQUE"   AND
                           craptab.tpregist = 001            
                           EXCLUSIVE-LOCK NO-ERROR.
        IF  NOT AVAILABLE craptab   THEN
            IF  LOCKED craptab THEN
                 DO:
                     glb_cdcritic = 77.
                     PAUSE 1 NO-MESSAGE.
                     UNDO ALTERA, LEAVE ALTERA.
                 END.
            ELSE
                 DO:
                     glb_cdcritic = 55.
                     CLEAR FRAME f_tab004.
                     LEAVE.
                 END.
        ELSE
            DO:
                glb_cdcritic = 0.
                LEAVE.
            END.
    END.

    ASSIGN tel_txsaqcal = DECIMAL(SUBSTRING(craptab.dstextab,1,10))
           tel_txsaqfix = DECIMAL(SUBSTRING(craptab.dstextab,12,6))
           log_txjursaq = tel_txsaqfix.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        DISPLAY tel_txsaqcal WITH FRAME f_tab004.
        UPDATE  tel_txsaqfix WITH FRAME f_tab004.
        LEAVE.
    END.

    /* F4 ou FIM */
    IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN 
        UNDO ALTERA, LEAVE ALTERA.
    
    /* Atualiza o Registro na tabela */
    ASSIGN SUBSTRING(craptab.dstextab,12,6) = STRING(tel_txsaqfix,"999.99").

    /* Solicita para o usuario se deseja alterar o registro. */
    RUN fontes/confirma.p (INPUT "", 
                           OUTPUT aux_confirma).

    /* Vamos verificar se devemos alterar o registro */
    IF aux_confirma <> "S" THEN
        UNDO ALTERA, LEAVE ALTERA.

    RUN gera_log (INPUT glb_cddopcao,
                  INPUT tel_txnegfix, 
                  INPUT tel_txsaqfix, 
                  
                  INPUT log_txjurneg, 
                  INPUT log_txjursaq).
END.
/* .......................................................................... */
                                           
PROCEDURE gera_log:

    DEF INPUT PARAM par_cddopcao LIKE glb_cddopcao  NO-UNDO.
    DEF INPUT PARAM par_txjurneg AS DECIMAL FORMAT "zz9.999999"  NO-UNDO.
    DEF INPUT PARAM par_txjursaq AS DECIMAL FORMAT "zz9.999999"  NO-UNDO.

    DEF INPUT PARAM par_logurneg AS DECIMAL FORMAT "zz9.999999"  NO-UNDO.
    DEF INPUT PARAM par_logursaq AS DECIMAL FORMAT "zz9.999999"  NO-UNDO.

    IF par_txjurneg = par_logurneg AND par_txjursaq = par_logursaq THEN
        RETURN.

    UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                      " "     + STRING(TIME,"HH:MM:SS")  + "' --> '"    +
                      " Operador " + glb_cdoperad + " - " + "Alterou: " +
                      (IF par_txjurneg <> par_logurneg THEN
                          " A taxa fixa para saldos negativos de " + 
                          STRING(par_logurneg,"zz9.99") + " para " + 
                          STRING(par_txjurneg,"zz9.99") + "."
                       ELSE "")+
                      (IF par_txjursaq <> par_logursaq THEN
                          " A taxa fixa para saque bloqueado de " + 
                          STRING(par_logursaq,"zz9.99") + " para " + 
                          STRING(par_txjursaq,"zz9.99") + "."
                       ELSE "") 
                      + " >> log/tab004.log").

END PROCEDURE.
