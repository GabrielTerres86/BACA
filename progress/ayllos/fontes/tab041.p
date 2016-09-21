/* .............................................................................

   Programa: Fontes/tab041.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Diego         
   Data    : Maio/2006                         Ultima alteracao: 08/01/2014 
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Cadastrar Horario limite para efetuar processo sem arquivos de
               compensacao.
   
   Alteracoes: 11/09/2006 - Alterado help dos campos da tela (Elton).
               
               08/01/2014 - Incluido criacao de arquivo de log tab041.log
                            para registrar mudanca de horario para consulta 
                            na LOGTEL (Tiago).
............................................................................. */

{ includes/var_online.i }

DEF    VAR tel_nrdhhini  AS INT                                     NO-UNDO.
DEF    VAR tel_nrdmmini  AS INT                                     NO-UNDO.
DEF    VAR tel_cddsenha  AS CHAR    FORMAT "x(10)"                  NO-UNDO.

DEF    VAR aux_cddopcao  AS CHAR                                    NO-UNDO.
DEF    VAR aux_confirma  AS CHAR    FORMAT "!(1)"                   NO-UNDO.
DEF    VAR aux_nrdahora  AS INT                                     NO-UNDO.
DEF    VAR aux_flgsenha  AS LOGICAL                                 NO-UNDO.
DEF    VAR aux_cdoperad  AS CHAR                                    NO-UNDO.
DEF    VAR aux_dstransa  AS CHAR                                    NO-UNDO.

FORM WITH NO-LABEL TITLE COLOR MESSAGE glb_tldatela          
     ROW 4 COLUMN 1 SIZE 80 BY 18 OVERLAY WITH FRAME f_moldura.

FORM SKIP(2)
     glb_cddopcao AT 36 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A, C)."
                        VALIDATE(CAN-DO("A,C",glb_cddopcao),
                                    "014 - Opcao errada.")
     SKIP(3)
     tel_nrdhhini AT 5   LABEL "Horario limite para aguardar a COMPE"
                         FORMAT "99" AUTO-RETURN
                         HELP "Informe o horario limite (4 a 9)."
     ":"          AT 45 
     tel_nrdmmini AT 46  NO-LABEL FORMAT "99" 
                         HELP "Informe os minutos limite (0 a 59)."
     "Horas"
     SKIP(2)
     "  ATENCAO! A partir do horario informado acima, o sistema iniciara" SKIP
     "           o processamento diario independentemente do recebimento" SKIP
     "           dos arquivos da compensacao (DEBITOS e/ou CREDITOS)."    SKIP
     WITH ROW 6 COLUMN 4 SIDE-LABELS OVERLAY NO-BOX FRAME f_horario.

VIEW FRAME f_moldura. 
PAUSE(0).

glb_cddopcao = "C".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao WITH FRAME f_horario.
      LEAVE.
      
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "TAB041"   THEN
                 DO:
                     HIDE FRAME f_horario.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF   glb_cddopcao = "A" THEN
        DO:
            DO TRANSACTION ON ENDKEY UNDO, LEAVE:
            
               FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                  craptab.nmsistem = "CRED"         AND
                                  craptab.tptabela = "USUARI"       AND
                                  craptab.cdempres = 11             AND
                                  craptab.cdacesso = "HORLIMPROC"
                                  EXCLUSIVE-LOCK NO-ERROR.
                    
               ASSIGN aux_nrdahora = INT(SUBSTR(craptab.dstextab,1,5))
                      tel_nrdhhini = INT(SUBSTR(STRING(aux_nrdahora,
                                                       "HH:MM:SS"),1,2))
                      tel_nrdmmini = INT(SUBSTR(STRING(aux_nrdahora,
                                                       "HH:MM:SS"),4,2)).

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               
                  UPDATE tel_nrdhhini tel_nrdmmini WITH FRAME f_horario.

                  IF   tel_nrdhhini = 0   AND   tel_nrdmmini = 0   THEN
                       .
                  ELSE
                       DO:
                           IF   tel_nrdhhini < 4   OR
                                tel_nrdhhini > 9   OR
                               (tel_nrdhhini = 9   AND
                                tel_nrdmmini > 0)  THEN
                                DO:
                                    glb_cdcritic = 687.
                                    RUN fontes/critic.p.
                                    BELL.
                                    MESSAGE glb_dscritic.
                                    glb_cdcritic = 0.
                                    NEXT.
                                END.

                           IF   tel_nrdmmini > 59  THEN
                                DO:
                                    glb_cdcritic = 687.
                                    RUN fontes/critic.p.
                                    BELL.
                                    MESSAGE glb_dscritic.
                                    glb_cdcritic = 0.
                                    NEXT.
                                END.
                       END.

                  RUN fontes/pedesenha.p (INPUT glb_cdcooper, 
                                          INPUT 3, 
                                          OUTPUT aux_flgsenha,
                                          OUTPUT aux_cdoperad).               
                                          
                  LEAVE.
                  
               END.  /*  Fim do DO WHILE TRUE  */
               
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                    NEXT.
               
               RUN Confirma.

               IF   aux_confirma = "S"  THEN
                    DO:
                        ASSIGN aux_nrdahora = (tel_nrdhhini * 3600) + 
                                              (tel_nrdmmini * 60)
                               
                               glb_cddopcao = "C"

                               aux_dstransa = "Alteracao do horario limite " +
                                              "de " +
                                              STRING(INT(craptab.dstextab),
                                                     "HH:MM") + " para " +
                                              STRING(aux_nrdahora,"HH:MM") +
                                              ". Autorizado pelo operador " +
                                              aux_cdoperad.
                               
                        /*log para logtel da tab041 mudanca de horario*/
                        UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + 
                             " " + STRING(TIME,"HH:MM:SS")  + "' --> '" +
                             "Operador " + glb_cdoperad     +
                             " alterou o Horario limite "   +
                             "para aguardar a COMPE de  "   +
                              STRING(INT(craptab.dstextab),
                                     "HH:MM") + " para "    +
                              STRING(aux_nrdahora,"HH:MM")  +
                             " >> log/tab041.log").          

                        craptab.dstextab = STRING(aux_nrdahora,"99999").

                        RUN fontes/gera_log.p (INPUT glb_cdcooper,
                                               INPUT 0,
                                               INPUT glb_cdoperad,
                                               INPUT aux_dstransa,
                                               INPUT glb_nmdatela).

                        CLEAR FRAME f_horario NO-PAUSE.
                    END.
            
            END. /* Fim da Transacao */

            RELEASE craptab.
        END.      
   ELSE
   IF   glb_cddopcao = "C" THEN
        DO:
            FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "USUARI"       AND
                               craptab.cdempres = 11             AND
                               craptab.cdacesso = "HORLIMPROC"
                               NO-LOCK NO-ERROR.
                    
            ASSIGN aux_nrdahora = INT(SUBSTR(craptab.dstextab,1,5))
                   tel_nrdhhini = INT(SUBSTR(STRING(aux_nrdahora,
                                                    "HH:MM:SS"),1,2))
                   tel_nrdmmini = INT(SUBSTR(STRING(aux_nrdahora,
                                                    "HH:MM:SS"),4,2)).
                                                    
            DISPLAY tel_nrdhhini tel_nrdmmini WITH FRAME f_horario.
        END.
        
END.

PROCEDURE confirma.

   /* Confirma */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.
             RUN fontes/critic.p.
             glb_cdcritic = 0.
             BELL.
             MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
             LEAVE.
   END.  /*  Fim do DO WHILE TRUE  */
           
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
            MESSAGE glb_dscritic.
            PAUSE 2 NO-MESSAGE.
            CLEAR FRAME f_horario.
        END. /* Mensagem de confirmacao */

END PROCEDURE.

/* .......................................................................... */
