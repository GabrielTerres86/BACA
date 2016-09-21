/*..............................................................................

    Programa: Fontes/trfcmp.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Guilherme/Supero
    Data    : Janeiro/2010                      Ultima alteracao: 22/09/2014

    Dados referentes ao programa:

    Frequencia: 
    Objetivo  : TRFCMP - Tarifas da Compensacao
   
    Alteracao : 03/04/2012 - TIB DDA - Campo DDA em tela (Guilherme/Supero)
    
                23/04/2012 - Retirada chamada para o banco generico e 
                             substituido fonte do programa trfcmp.p pelo fonte
                             do programa trfcmpp.p (Elton).
                
                05/12/2013 - Alteracao referente a integracao Progress X 
                             Dataserver Oracle 
                             Inclusao do VALIDATE ( André Euzébio / SUPERO)
                             
                22/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                             b1wgen9999.p procedure acha-lock, que identifica qual 
                             é o usuario que esta prendendo a transaçao. (Vanessa)
              
..............................................................................*/

{ includes/var_online.i }

DEF VAR tel_dtaltera AS DATE FORMAT "99/99/9999"                       NO-UNDO.
DEF VAR tel_cdoperad AS CHAR                                           NO-UNDO.

DEF VAR tel_vltrfchq AS DECI FORMAT "zzz,zz9.99"                       NO-UNDO.
DEF VAR tel_vltrfdev AS DECI FORMAT "zzz,zz9.99"                       NO-UNDO.
DEF VAR tel_vltrftit AS DECI FORMAT "zzz,zz9.99"                       NO-UNDO.
DEF VAR tel_vltrfdoc AS DECI FORMAT "zzz,zz9.99"                       NO-UNDO.
DEF VAR tel_vlchqrob AS DECI FORMAT "zzz,zz9.99"                       NO-UNDO.
DEF VAR tel_vltrfccf AS DECI FORMAT "zzz,zz9.99"                       NO-UNDO.
DEF VAR tel_vltrficf AS DECI FORMAT "zzz,zz9.99"                       NO-UNDO.
DEF VAR tel_vltedtec AS DECI FORMAT "zzz,zz9.99"                       NO-UNDO.
DEF VAR tel_vltrfdda AS DECI FORMAT "zzz,zz9.99"                       NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                             NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR FORMAT "x(35)"                            NO-UNDO.

DEF VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.

FORM WITH ROW 4 OVERLAY TITLE glb_tldatela SIZE 80 BY 18 FRAME f_moldura.

FORM glb_cddopcao AT 3 LABEL "Opcao"  AUTO-RETURN FORMAT "!(1)"
                  HELP "Entre com a opcao desejada (A,C)."
                  VALIDATE(CAN-DO("A,C",glb_cddopcao),"014 - Opcao errada.")

     SKIP
     tel_vltrfchq AT 28 LABEL "Cheque" AUTO-RETURN
                  HELP "Entre com o valor da tarifa para Cheques"
     tel_vltrfdev AT 25 LABEL "Devolucao" AUTO-RETURN
                  HELP "Entre com o valor da tarifa para Devolucao de Cheques"
     SKIP(1)
     tel_vltrftit AT 19  LABEL "Titulo/Cobranca" AUTO-RETURN
                  HELP "Entre com o valor da tarifa para Titulo/Cobranca"
     tel_vltrfdoc AT 31 LABEL "DOC" AUTO-RETURN
                  HELP "Entre com o valor da tarifa para DOC"
     tel_vltrfdda AT 31 LABEL "DDA" AUTO-RETURN
                  HELP "Entre com o valor da tarifa para DDA"
     SKIP(1)
     tel_vlchqrob AT 20 LABEL "Cheque Roubado" AUTO-RETURN
                  HELP "Entre com o valor da tarifa para Cheque Roubado"
     tel_vltrfccf AT 31 LABEL "CCF" AUTO-RETURN
                  HELP "Entre com o valor da tarifa para CCF"
     SKIP(1)
     tel_vltrficf AT 31 LABEL "ICF" AUTO-RETURN
                  HELP "Entre com o valor da tarifa para ICF"
     SKIP(1)
     tel_vltedtec AT 27 LABEL "TED/TEC" AUTO-RETURN
                  HELP "Entre com o valor da tarifa para TED/TEC"
     SKIP(1)
     tel_dtaltera AT 3  LABEL "Dt. Alteracao"
     aux_cdoperad AT 33 LABEL "Operador"
     WITH ROW 5 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_trfcmp.

VIEW FRAME f_moldura.
PAUSE(0).

ASSIGN glb_cddopcao = "C".

DO WHILE TRUE:

    RUN fontes/inicia.p.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE glb_cddopcao WITH FRAME f_trfcmp.
        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            RUN fontes/novatela.p.

            IF  CAPS(glb_nmdatela) <> "trfcmp"  THEN
                DO:
                    HIDE FRAME f_trfcmp.
                    HIDE FRAME f_moldura.
                    
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> glb_cddopcao  THEN
        DO:
            { includes/acesso.i }
            ASSIGN aux_cddopcao = glb_cddopcao.
        END.

        /* Somente Cooperativa CECRED pode alterar */
        IF  glb_cddopcao = "A"  AND
            glb_cdcooper <> 3   THEN
        DO:
            ASSIGN glb_cdcritic = 36.
            RUN fontes/critic.p.
            ASSIGN glb_cdcritic = 0.

            BELL.
            MESSAGE glb_dscritic.

            NEXT.
        END.
        
        /* Somente estes departamentos da CECRED podem alterar os dados */
        IF  glb_cddopcao = "A" AND
            glb_cdcooper = 3   AND
            glb_dsdepart <> "COMPE"                AND
            glb_dsdepart <> "TI"                   AND
            glb_dsdepart <> "COORD.ADM/FINANCEIRO" AND
            glb_dsdepart <> "COORD.PRODUTOS"       THEN        
        DO:
            ASSIGN glb_cdcritic = 36.
            RUN fontes/critic.p.
            ASSIGN glb_cdcritic = 0.

            BELL.
            MESSAGE glb_dscritic.

            NEXT.
        END.
    
    FIND FIRST gncdtrf NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE gncdtrf  THEN
        DO:
            DO TRANSACTION ON ERROR UNDO, LEAVE:
            
                CREATE gncdtrf.
                ASSIGN gncdtrf.dtaltera = glb_dtmvtolt
                       gncdtrf.cdoperad = glb_cdoperad
                       gncdtrf.vltrfchq = 0
                       gncdtrf.vltrfdev = 0
                       gncdtrf.vltrftit = 0
                       gncdtrf.vltrfdoc = 0
                       gncdtrf.vlchqrob = 0
                       gncdtrf.vltrfccf = 0
                       gncdtrf.vltrficf = 0
                       gncdtrf.vltedtec = 0.
                VALIDATE gncdtrf. 

                FIND CURRENT gncdtrf NO-LOCK NO-ERROR.

            END. /** Fim do DO TRANSACTION **/
        END.

    FIND FIRST crapope
         WHERE crapope.cdcooper = glb_cdcooper
           AND crapope.cdoperad = gncdtrf.cdoperad NO-LOCK NO-ERROR.

    ASSIGN aux_cdoperad = crapope.cdoperad + "-" + crapope.nmoperad.

    ASSIGN tel_dtaltera = gncdtrf.dtaltera  
           tel_cdoperad = aux_cdoperad
           tel_vltrfchq = gncdtrf.vltrfchq
           tel_vltrfdev = gncdtrf.vltrfdev
           tel_vltrftit = gncdtrf.vltrftit
           tel_vltrfdoc = gncdtrf.vltrfdoc
           tel_vlchqrob = gncdtrf.vlchqrob
           tel_vltrfccf = gncdtrf.vltrfccf
           tel_vltrficf = gncdtrf.vltrficf
           tel_vltedtec = gncdtrf.vltedtec
           tel_vltrfdda = gncdtrf.vltrfdda.

    DISPLAY tel_vltrfchq tel_vltrfdev tel_vltrftit
            tel_vltrfdoc tel_vlchqrob tel_vltrfccf
            tel_vltrficf tel_vltedtec tel_vltrfdda
            tel_dtaltera aux_cdoperad
       WITH FRAME f_trfcmp.

    IF  glb_cddopcao = "A"  THEN
        DO:
            ASSIGN glb_cdcritic = 0.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                IF  glb_cdcritic > 0  THEN
                    DO:
                        RUN fontes/critic.p.
                        ASSIGN glb_cdcritic = 0.

                        BELL.
                        MESSAGE glb_dscritic.
                    END.

                UPDATE tel_vltrfchq tel_vltrfdev tel_vltrftit
                       tel_vltrfdoc tel_vltrfdda tel_vlchqrob 
                       tel_vltrfccf tel_vltrficf tel_vltedtec
                       WITH FRAME f_trfcmp.

                LEAVE.

            END. /** Fim do DO ... TO **/

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                NEXT.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                ASSIGN aux_confirma = "N"
                       glb_cdcritic = 78.
                RUN fontes/critic.p.
                ASSIGN glb_cdcritic = 0.

                BELL.
                MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.

                LEAVE.

            END. /** Fim do DO WHILE TRUE **/

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                aux_confirma <> "S"                 THEN
                DO:
                    ASSIGN glb_cdcritic = 79.
                    RUN fontes/critic.p.
                    ASSIGN glb_cdcritic = 0.                    

                    BELL.
                    MESSAGE glb_dscritic.

                    NEXT.
                END.

            DO TRANSACTION ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

                DO aux_contador = 1 TO 10:

                    ASSIGN glb_cdcritic = 0.
    
                    FIND FIRST gncdtrf EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                    IF  NOT AVAILABLE gncdtrf  THEN
                        DO:
                            IF  LOCKED gncdtrf  THEN
                                DO:
                                    RUN sistema/generico/procedures/b1wgen9999.p
                                    PERSISTENT SET h-b1wgen9999.
                                    
                                    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(gncdtrf),
                                    					 INPUT "banco",
                                    					 INPUT "gncdtrf",
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
                                    
                                    glb_cdcritic = 0.
                                    NEXT.
                                END.
                            ELSE
                                ASSIGN glb_cdcritic = 55.
                        END.
    
                    LEAVE.
    
                END. /** Fim do DO ... TO **/
    
                IF  glb_cdcritic > 0  THEN
                    DO:
                        RUN fontes/critic.p.
                        ASSIGN glb_cdcritic = 0.

                        BELL. 
                        MESSAGE glb_dscritic.

                        UNDO, LEAVE.
                    END.

                ASSIGN gncdtrf.dtaltera = glb_dtmvtolt
                       gncdtrf.cdoperad = glb_cdoperad
                       gncdtrf.vltrfchq = tel_vltrfchq
                       gncdtrf.vltrfdev = tel_vltrfdev
                       gncdtrf.vltrftit = tel_vltrftit
                       gncdtrf.vltrfdoc = tel_vltrfdoc
                       gncdtrf.vlchqrob = tel_vlchqrob
                       gncdtrf.vltrfccf = tel_vltrfccf
                       gncdtrf.vltrficf = tel_vltrficf
                       gncdtrf.vltedtec = tel_vltedtec
                       gncdtrf.vltrfdda = tel_vltrfdda.

                FIND CURRENT gncdtrf NO-LOCK NO-ERROR.

            END. /** Fim do DO TRANSACTION **/
        END.

END. /** Fim do DO WHILE TRUE **/

/*............................................................................*/

