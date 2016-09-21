/*..............................................................................
   
   Programa: Fontes/indkfx.p
   Sistema : Conta-Corrente - Cooperativa de Credito 
   Sigla   : CRED
   Autor   : Adriano
   Data    : Maio/2011.                       Ultima Atualizacao: 16/01/2014
            
   Dados referentes ao programa:

   Frequencia: Diario 
   Objetivo  : Mostra a tela INDKFX.
               Indisponibilizacao do KOFAX.
               
   Alteracoes: 14/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               06/12/2013 - Inclusao de VALIDATE crapikx (Carlos)
               
               16/01/2014 - Alterado para mostrar critica 962 ao nao encontrar
                            PA, na procedure valida_pac. (Reinert)

.............................................................................*/

{ includes/var_online.i }

DEF VAR tel_cdcooper AS CHAR FORMAT "x(12)" VIEW-AS COMBO-BOX
                             INNER-LINES 11                     NO-UNDO.
DEF VAR tel_cdcoope2 AS CHAR FORMAT "x(12)" VIEW-AS COMBO-BOX
                             INNER-LINES 11                     NO-UNDO.
DEF VAR tel_cdcoope3 AS CHAR FORMAT "x(12)" VIEW-AS COMBO-BOX
                             INNER-LINES 11                     NO-UNDO.
DEF VAR tel_cdagenci AS   INT  FORMAT "zz9"                     NO-UNDO.
DEF VAR tel_dtindisp AS   DATE FORMAT "99/99/9999"              NO-UNDO.
DEF VAR tel_flindisp AS   LOG  FORMAT "Sim/Nao"                 NO-UNDO.
DEF VAR tel_motivind AS   CHAR FORMAT "x(40)"                   NO-UNDO.


DEF VAR aux_nmcooper AS CHAR FORMAT "x(12)"                     NO-UNDO.
DEF VAR aux_contador AS INT                                     NO-UNDO.  
DEF VAR aux_cddopcao AS CHAR                                    NO-UNDO.
DEF VAR aux_cdcooper AS INT  FORMAT "zz9"                       NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!" INIT "N"                NO-UNDO.
DEF VAR aux_cdagenci AS CHAR FORMAT "x(12)"                     NO-UNDO.
DEF VAR aux_flregexi AS LOG                                     NO-UNDO.

DEF VAR log_cdcooper LIKE tel_cdcooper                          NO-UNDO.
DEF VAR log_cdagenci LIKE tel_cdagenci                          NO-UNDO.
DEF VAR log_motivind LIKE tel_motivind                          NO-UNDO.



FORM SKIP(1)
     glb_cddopcao AT 03 LABEL "Opcao" AUTO-RETURN
                  HELP "Informe a opcao (A,C,E,I)."
     VALIDATE (CAN-DO("A,C,E,I",glb_cddopcao),"014 - Opcao Errada")
     SKIP(14)
     WITH ROW 4 OVERLAY WIDTH 80 SIDE-LABELS TITLE glb_tldatela FRAME f_opcao.


FORM SKIP(1)
     tel_cdcoope2 AT 20 LABEL "Cooperativa"
                        HELP "Selecione a Cooperativa."
     SKIP(1)
     tel_cdagenci AT 28 LABEL "PA"
                        HELP "Entre com o numero do PA." 
     aux_cdagenci NO-LABEL
     SKIP(1) 
     tel_motivind AT 4  LABEL "Motivo de Indisponibilidade"
                              HELP "Informe o motivo."
     VALIDATE(tel_motivind <> "", "Informe um motivo.")
     WITH NO-BOX ROW 8 COLUMN 2 OVERLAY WIDTH 75 SIDE-LABELS FRAME f_indkfx.


FORM SKIP(1)
     tel_cdcooper AT 20 LABEL "Cooperativa"
                        HELP "Selecione a Cooperativa."
     SKIP(1)
     tel_cdagenci AT 28 LABEL "PA"
                        HELP "Informe o numero do PA."
     aux_cdagenci NO-LABEL
     WITH NO-BOX ROW 8 COLUMN 2 OVERLAY WIDTH 75 SIDE-LABELS FRAME f_consulta.


FORM SKIP(1)
     tel_cdcoope3 AT 20 LABEL "Cooperativa"
                        HELP "Selecione a Cooperativa."
     SKIP(1)
     tel_cdagenci AT 28 LABEL "PA"
                        HELP "Entre com o numero do PA." 
     aux_cdagenci NO-LABEL 
     SKIP(1)
     tel_motivind LABEL "Motivo Indisponibilidade" AT 7                   
     WITH NO-BOX ROW 8 COLUMN 2 OVERLAY WIDTH 75 SIDE-LABELS FRAME f_exclusao.


DEF QUERY q_consulta FOR crapikx.

DEF BROWSE b_consulta QUERY q_consulta
    DISPLAY crapikx.cdcooper COLUMN-LABEL "Cooperativa"  
            crapikx.cdagenci COLUMN-LABEL "PA"                SPACE(15)
            crapikx.dtindisp COLUMN-LABEL "Data de Inicio"     SPACE(15)
            crapikx.flindisp COLUMN-LABEL "Indisponivel" 
                                              FORMAT "Sim/Nao" SPACE(10)
    WITH 7 DOWN NO-BOX WIDTH 74.

FORM b_consulta 
     HELP "Use: SETAS Navegar <F4> Sair."
     WITH ROW 8 CENTERED OVERLAY  NO-LABELS WIDTH 76
                TITLE " Consulta " FRAME f_browse.

FORM tel_motivind LABEL "Motivo da Indisponibilidade"
     WITH NO-BOX ROW 19 COLUMN 5 OVERLAY WIDTH 75 SIDE-LABELS FRAME f_motivo.


DEF BUFFER b-crapikx1 FOR crapikx.
DEF BUFFER b-crapage1 FOR crapage.
DEF BUFFER b-crapcop1 FOR crapcop.

DEF TEMP-TABLE tt-log
    FIELD cddopcao LIKE glb_cddopcao
    FIELD cdcooper LIKE crapikx.cdcooper
    FIELD cdagenci LIKE tel_cdagenci
    FIELD dtindisp LIKE tel_dtindisp
    FIELD motivind LIKE tel_motivind
    FIELD motivant LIKE log_motivind
    INDEX cdcooper cdagenci dtindisp.


ON LEAVE OF b_consulta IN FRAME f_browse DO:

    IF  NOT AVAILABLE crapikx   THEN  
        RETURN.
END.

ON RETURN OF tel_cdcooper, tel_cdcoope2, tel_cdcoope3 
   DO:
     ASSIGN tel_cdcooper = tel_cdcooper:SCREEN-VALUE
            tel_cdcoope2 = tel_cdcoope2:SCREEN-VALUE
            tel_cdcoope3 = tel_cdcoope3:SCREEN-VALUE.
     ASSIGN aux_contador = 0.
     APPLY "TAB".

   END.

ON VALUE-CHANGED, ENTRY OF b_consulta
   DO:
      IF AVAIL crapikx THEN
         DO:
            tel_motivind = crapikx.dsmotivo.

            DISPLAY tel_motivind
                    WITH FRAME f_motivo.
         END.

   END.
  

VIEW FRAME f_opcao.

PAUSE(0).

RUN fontes/inicia.p.
    

FOR EACH crapcop NO-LOCK BY crapcop.nmrescop:
       
    IF aux_contador = 0 THEN
       ASSIGN aux_nmcooper = "TODAS,0," + 
                             CAPS(crapcop.dsdircop) + "," +
                             STRING(crapcop.cdcooper)
              aux_contador = 1.
       ELSE
          ASSIGN aux_nmcooper = aux_nmcooper + "," +
                                CAPS(crapcop.dsdircop) + "," +
                                STRING(crapcop.cdcooper).
    

END.


ASSIGN tel_cdcooper:LIST-ITEM-PAIRS = aux_nmcooper
       tel_cdcoope2:LIST-ITEM-PAIRS = aux_nmcooper
       tel_cdcoope3:LIST-ITEM-PAIRS = aux_nmcooper.


DO WHILE TRUE:

   CLEAR FRAME f_consulta.
   CLEAR FRAME f_indkfx.
   CLEAR FRAME f_exclusao.
   
   ASSIGN  glb_cddopcao = "C"
           tel_cdagenci = 0
           tel_dtindisp = ?
           tel_flindisp = FALSE
           tel_motivind = ""
           aux_cddopcao = ""
           aux_cdcooper = 0
           aux_cdagenci = ""
           log_cdcooper = ""
           log_cdagenci = 0
           log_motivind = ""
           aux_flregexi = FALSE.


   EMPTY TEMP-TABLE tt-log.
   
            
    IF glb_cdcritic > 0 THEN
       DO:
           RUN fontes/critic.p.
           BELL.
           MESSAGE glb_dscritic.
           ASSIGN glb_cdcritic = 0.

       END.


    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE glb_cddopcao 
               WITH FRAME f_opcao.

        LEAVE.

    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            RUN fontes/novatela.p.

            IF  CAPS(glb_nmdatela) <> "INDKFX"  THEN
                DO:
                    HIDE FRAME f_indkfx NO-PAUSE.
                    HIDE FRAME f_opcao  NO-PAUSE.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> INPUT glb_cddopcao  THEN
        DO:
            { includes/acesso.i }

            ASSIGN aux_cddopcao = INPUT glb_cddopcao.
        END.
 

    IF glb_cddopcao = "C" THEN
       DO:                        
           CLEAR FRAME f_browse.
           HIDE  FRAME f_browse.   
           HIDE  FRAME f_consulta.   

           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

              UPDATE tel_cdcooper
                     tel_cdagenci
                     WITH FRAME f_consulta.

              aux_cdcooper = INT(tel_cdcooper).

              IF tel_cdagenci <> 0 THEN
                 DO:
                     RUN valida_pac (INPUT  aux_cdcooper,
                                     INPUT  tel_cdagenci,
                                     OUTPUT aux_cdagenci).
                    
                     IF RETURN-VALUE = "NOK" THEN
                        NEXT.
    
                     DISPLAY aux_cdagenci 
                             WITH FRAME f_consulta.
                     PAUSE 0.
                 END.

              
                     
              IF  aux_cdcooper <> 0 AND
                  tel_cdagenci <> 0 THEN
                  DO:
                      OPEN QUERY q_consulta 
                                FOR EACH crapikx WHERE 
                                         crapikx.cdcooper = aux_cdcooper AND
                                         crapikx.cdagenci = tel_cdagenci
                                         NO-LOCK BY crapikx.cdcooper.
                     
                  END.
              ELSE
                  IF  aux_cdcooper <> 0 AND
                      tel_cdagenci =  0 THEN
                      DO:
                         OPEN QUERY q_consulta
                                    FOR EACH crapikx WHERE 
                                             crapikx.cdcooper = aux_cdcooper 
                                             NO-LOCK BY crapikx.cdcooper.
                      END.
                  ELSE
                      IF  aux_cdcooper = 0 AND
                          tel_cdagenci = 0 THEN
                          DO:
                            OPEN QUERY q_consulta
                                       FOR EACH crapikx 
                                                NO-LOCK BY crapikx.cdcooper.
                           
                          END.
                      ELSE
                          IF  aux_cdcooper = 0  AND
                              tel_cdagenci <> 0 THEN
                              DO:
                                 OPEN QUERY q_consulta
                                       FOR EACH crapikx WHERE 
                                                crapikx.cdagenci = tel_cdagenci
                                                NO-LOCK BY crapikx.cdcooper.
                              END.
                    
                
                  UPDATE b_consulta WITH FRAME f_browse.
                  CLOSE QUERY q_consulta.
                  LEAVE.
                
           END.  
       
       END. /* FIM DA OPCAO C */

    ELSE
       IF glb_cddopcao = "I" THEN
          DO:
             aux_confirma = "N".
             
             VIEW FRAME f_indkfx.
             
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                UPDATE tel_cdcoope2
                       tel_cdagenci
                       WITH FRAME f_indkfx.
                
                aux_cdcooper = INT(tel_cdcoope2).


                 IF tel_cdagenci <> 0 THEN
                    DO:
                      RUN valida_pac (INPUT  aux_cdcooper,
                                      INPUT  tel_cdagenci,
                                      OUTPUT aux_cdagenci).
                  
                      IF RETURN-VALUE = "NOK" THEN
                         NEXT.
    
                      DISPLAY aux_cdagenci 
                              WITH FRAME f_indkfx.
                  
                    END.
                
                LEAVE.

             END.

             IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                NEXT.

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                UPDATE tel_motivind
                       WITH FRAME f_indkfx.
                LEAVE.

             END.
        
             IF KEYFUNCTION (LAST-KEY) = "END-ERROR" THEN
                NEXT.


             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                MESSAGE "Confirma a operação?"
                UPDATE aux_confirma.
                LEAVE.

             END.

             IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                NEXT.

             IF aux_confirma = "S" THEN
                DO:
                   DO TRANSACTION:

                       IF aux_cdcooper <> 0 AND 
                          tel_cdagenci <> 0 THEN
                          DO:
                             FIND crapikx WHERE crapikx.cdcooper = aux_cdcooper AND
                                                crapikx.cdagenci = tel_cdagenci AND
                                                crapikx.dtindisp = glb_dtmvtolt 
                                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
               
                             IF NOT AVAIL crapikx THEN
                                DO:
                                  IF LOCKED crapikx THEN
                                     DO:
                                        PAUSE 2 NO-MESSAGE.
                                        NEXT.
                           
                                     END.
                                  ELSE
                                     DO:
                                        CREATE crapikx.
                           
                                        ASSIGN crapikx.cdcooper = aux_cdcooper
                                               crapikx.cdagenci = tel_cdagenci
                                               crapikx.dtindisp = glb_dtmvtolt 
                                               crapikx.flindisp = YES 
                                               crapikx.dsmotivo = tel_motivind.
                                        
                                        VALIDATE crapikx.

                                        RUN gera_log (INPUT glb_cddopcao,
                                                      INPUT tel_cdcoope2:SCREEN-VALUE,
                                                      INPUT tel_cdagenci,
                                                      INPUT tel_motivind,
                                                      INPUT "").
                                     END.
                                END. 
                             ELSE 
                                 DO:
                                    MESSAGE "Indisponibilidade ja cadastrada.". 
                                    PAUSE(2) NO-MESSAGE.
                                 END.
                          END.
                       ELSE
                         IF aux_cdcooper = 0  AND
                            tel_cdagenci <> 0 THEN
                            DO:
                               FOR EACH b-crapcop1 NO-LOCK:
                            
                                   FIND crapikx WHERE crapikx.cdcooper = b-crapcop1.cdcooper AND
                                                      crapikx.cdagenci = tel_cdagenci        AND
                                                      crapikx.dtindisp = glb_dtmvtolt 
                                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                             
                                   IF NOT AVAIL crapikx THEN
                                      DO:
                                         IF LOCKED crapikx THEN
                                            DO:
                                               PAUSE 2 NO-MESSAGE.
                                               NEXT.
                                            
                                            END.
                                         ELSE
                                            DO:
                                               aux_flregexi = TRUE.

                                               CREATE crapikx.
                                     
                                               ASSIGN crapikx.cdcooper = b-crapcop1.cdcooper
                                                      crapikx.cdagenci = tel_cdagenci
                                                      crapikx.dtindisp = glb_dtmvtolt
                                                      crapikx.flindisp = YES
                                                      crapikx.dsmotivo = tel_motivind.

                                               VALIDATE crapikx.

                                            END.
                                      END.
                               END.
                             
                               IF aux_flregexi = FALSE THEN
                                  DO:
                                     MESSAGE "Indisponibilidade ja cadastrada.". 
                                     PAUSE(2) NO-MESSAGE.
                                  END.

                               RUN gera_log (INPUT glb_cddopcao,
                                             INPUT tel_cdcoope2:SCREEN-VALUE,
                                             INPUT tel_cdagenci,
                                             INPUT tel_motivind,
                                             INPUT "").
                            END.
                         ELSE
                           IF aux_cdcooper = 0 AND
                              tel_cdagenci = 0 THEN
                              DO:
                                 FOR EACH b-crapcop1 NO-LOCK:

                                     FOR EACH crapage WHERE crapage.cdcooper = b-crapcop1.cdcooper
                                                            NO-LOCK:
                            
                                         FIND crapikx WHERE crapikx.cdcooper = b-crapcop1.cdcooper AND
                                                            crapikx.cdagenci = crapage.cdagenci    AND
                                                            crapikx.dtindisp = glb_dtmvtolt 
                                                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                       
                                         IF NOT AVAIL crapikx THEN
                                            DO:
                                               IF LOCKED crapikx THEN
                                                  DO:
                                                     PAUSE 2 NO-MESSAGE.
                                                     NEXT.
                                                  
                                                  END.
                                               ELSE
                                                  DO:
                                                     aux_flregexi = TRUE.

                                                     CREATE crapikx.
                                            
                                                     ASSIGN crapikx.cdcooper = b-crapcop1.cdcooper
                                                            crapikx.cdagenci = crapage.cdagenci
                                                            crapikx.dtindisp = glb_dtmvtolt 
                                                            crapikx.flindisp = YES 
                                                            crapikx.dsmotivo = tel_motivind.

                                                     VALIDATE crapikx.

                                                  END.

                                            END. 
                                     END.
                              
                                 END.
                                 
                                 IF aux_flregexi = FALSE THEN 
                                    DO:
                                       MESSAGE "Indisponibilidade ja cadastrada.". 
                                       PAUSE(2) NO-MESSAGE.
                                    
                                    END.

                                 RUN gera_log (INPUT glb_cddopcao,
                                               INPUT tel_cdcoope2:SCREEN-VALUE,
                                               INPUT tel_cdagenci,
                                               INPUT tel_motivind,
                                               INPUT "").
                              END.
                           ELSE
                              IF aux_cdcooper <> 0 AND
                                 tel_cdagenci =  0 THEN
                                 DO:
                                    FOR EACH crapage WHERE crapage.cdcooper = aux_cdcooper 
                                                           NO-LOCK:
                              
                                        FIND crapikx WHERE crapikx.cdcooper = aux_cdcooper     AND
                                                           crapikx.cdagenci = crapage.cdagenci AND
                                                           crapikx.dtindisp = glb_dtmvtolt 
                                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                        
                                        IF NOT AVAIL crapikx THEN
                                           DO:
                                            IF LOCKED crapikx THEN
                                               DO:
                                                  PAUSE 2 NO-MESSAGE.
                                                  NEXT.
                                               
                                               END.
                                            ELSE
                                               DO:
                                                  aux_flregexi = TRUE.
                                                  
                                                  CREATE crapikx.
                                        
                                                  ASSIGN crapikx.cdcooper = aux_cdcooper
                                                         crapikx.cdagenci = crapage.cdagenci
                                                         crapikx.dtindisp = glb_dtmvtolt
                                                         crapikx.flindisp = YES
                                                         crapikx.dsmotivo = tel_motivind.

                                                  VALIDATE crapikx.

                                               END.

                                          END. 
                                    END.
                                    
                                    IF aux_flregexi = FALSE THEN
                                       DO:
                                          MESSAGE "Indisponibilidade ja cadastrada.". 
                                          PAUSE(2) NO-MESSAGE.
                                        
                                       END.

                                    RUN gera_log (INPUT glb_cddopcao,
                                                  INPUT tel_cdcoope2:SCREEN-VALUE,
                                                  INPUT tel_cdagenci,
                                                  INPUT tel_motivind,
                                                  INPUT "").
                                 END.
                   END.
               
                   RELEASE crapikx.
                
                END.
             ELSE
                HIDE FRAME f_indkfx.

          END. /* FIM DA OPCAO I */
       ELSE
          IF glb_cddopcao = "A" THEN
             DO:
                aux_confirma = "N".
             
                VIEW FRAME f_indkfx.
                
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
             
                   UPDATE tel_cdcoope2
                          tel_cdagenci
                          WITH FRAME f_indkfx.
                   
                   aux_cdcooper = INT(tel_cdcoope2).


                   IF tel_cdagenci <> 0 THEN
                      DO:
                         RUN valida_pac (INPUT  aux_cdcooper,
                                         INPUT  tel_cdagenci,
                                         OUTPUT aux_cdagenci).
                     
                         IF RETURN-VALUE = "NOK" THEN
                            NEXT.

                         DISPLAY aux_cdagenci 
                                 WITH FRAME f_indkfx.  
                     
                      END.

                   LEAVE.
     
                END.
     
                IF KEYFUNCTION (LAST-KEY) = "END-ERROR" THEN
                   NEXT.
     
                IF aux_cdcooper <> 0 AND
                   tel_cdagenci <> 0 THEN
                   DO:
                       FIND crapikx WHERE crapikx.cdcooper = aux_cdcooper AND
                                          crapikx.cdagenci = tel_cdagenci AND
                                          crapikx.dtindisp = glb_dtmvtolt 
                                          NO-LOCK NO-ERROR.
                       
                       IF NOT AVAIL crapikx THEN
                          DO:
                            IF LOCKED crapikx THEN
                               DO:
                                  PAUSE 2 NO-MESSAGE.
                                  NEXT.
                       
                               END.
                            ELSE
                               DO:
                                    MESSAGE "Indisponibilidade nao encontrada.".
                                    PAUSE 2 NO-MESSAGE.
                                    RETURN.
                               END.
                          END. 
                       ELSE 
                          DO:
                             ASSIGN tel_motivind = crapikx.dsmotivo
                                    log_motivind = crapikx.dsmotivo.
                          END.
                   END.
                ELSE
                   IF aux_cdcooper <> 0 AND
                      tel_cdagenci =  0 THEN
                      DO:
                        FOR EACH crapage WHERE crapage.cdcooper = aux_cdcooper
                                               NO-LOCK:

                            FOR EACH crapikx WHERE crapikx.cdcooper = aux_cdcooper     AND
                                                   crapikx.cdagenci = crapage.cdagenci AND
                                                   crapikx.dtindisp = glb_dtmvtolt 
                                                   NO-LOCK:
                            
                                aux_flregexi = TRUE.

                                CREATE tt-log.
                         
                                ASSIGN tt-log.cddopcao = glb_cddopcao
                                       tt-log.cdcooper = crapikx.cdcooper
                                       tt-log.cdagenci = crapikx.cdagenci
                                       tt-log.dtindisp = glb_dtmvtolt     
                                       tt-log.motivant = crapikx.dsmotivo.    
                            END.
                        END.

                        IF  aux_flregexi = FALSE THEN
                            DO:
                                MESSAGE "Indisponibilidade nao encontrada.".
                                PAUSE 2 NO-MESSAGE.
                                RETURN.
                            END.
                   END.
                ELSE
                   IF aux_cdcooper =  0  AND
                      tel_cdagenci <> 0  THEN
                      DO:
                        FOR EACH b-crapcop1 NO-LOCK:
                       
                            FOR EACH crapikx WHERE crapikx.cdcooper = b-crapcop1.cdcooper AND
                                                   crapikx.cdagenci = tel_cdagenci        AND
                                                   crapikx.dtindisp = glb_dtmvtolt 
                                                   NO-LOCK:
                            
                                ASSIGN aux_flregexi = TRUE.
                                
                                CREATE tt-log.
                             
                                ASSIGN tt-log.cddopcao = glb_cddopcao
                                       tt-log.cdcooper = crapikx.cdcooper
                                       tt-log.cdagenci = tel_cdagenci
                                       tt-log.dtindisp = glb_dtmvtolt
                                       tt-log.motivant = crapikx.dsmotivo.  
                            END.
                        END.

                        IF  aux_flregexi = FALSE THEN
                            DO:
                                MESSAGE "Indisponibilidade nao encontrada.".
                                PAUSE 2 NO-MESSAGE.
                                RETURN.
                            END.
                      END.
                   ELSE
                     IF aux_cdcooper = 0  AND
                        tel_cdagenci = 0  THEN
                        DO:
                           FOR EACH crapikx WHERE crapikx.dtindisp = glb_dtmvtolt 
                                                  NO-LOCK:
                          
                               IF LOCKED crapikx THEN
                                  DO:
                                     PAUSE 2 NO-MESSAGE.
                                     NEXT.
                           
                                  END.
                               ELSE
                                  DO:
                                     ASSIGN aux_flregexi = TRUE.
                                
                                     CREATE tt-log.
                                  
                                     ASSIGN tt-log.cddopcao = glb_cddopcao
                                            tt-log.cdcooper = crapikx.cdcooper
                                            tt-log.cdagenci = crapikx.cdagenci
                                            tt-log.dtindisp = glb_dtmvtolt     
                                            tt-log.motivant = crapikx.dsmotivo.  
                                  END.
                           END.

                           IF  aux_flregexi = FALSE THEN
                               DO:
                                  MESSAGE "Indisponibilidade nao encontrada.".
                                  PAUSE 2 NO-MESSAGE.
                                  RETURN.
                               END. 
                        END.

                DISPLAY tel_motivind
                        WITH FRAME f_indkfx.


                IF KEYFUNCTION (LAST-KEY) = "END-ERROR" THEN
                   NEXT.

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                   UPDATE tel_motivind
                          WITH FRAME f_indkfx.

                   LEAVE.

                END.

                IF KEYFUNCTION (LAST-KEY) = "END-ERROR" THEN
                   NEXT.

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                   MESSAGE "Confirma a operação?"
                   UPDATE aux_confirma.
                   LEAVE.
     
                END.
     
                IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                   NEXT.
     
                IF aux_confirma = "S" THEN
                   DO:
                      DO TRANSACTION:
     
                          IF aux_cdcooper <> 0 AND
                             tel_cdagenci <> 0 THEN
                             DO: 
                                FIND b-crapikx1 WHERE b-crapikx1.cdcooper = aux_cdcooper AND
                                                      b-crapikx1.cdagenci = tel_cdagenci AND
                                                      b-crapikx1.dtindisp = glb_dtmvtolt
                                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                  
                                IF LOCKED b-crapikx1 THEN
                                   DO:
                                      PAUSE 2 NO-MESSAGE.
                                      NEXT.
                              
                                   END.
                                ELSE
                                   DO:
                                      ASSIGN b-crapikx1.flindisp = YES 
                                             b-crapikx1.dsmotivo = tel_motivind.
    
                                   END.

                                RUN gera_log (INPUT glb_cddopcao,
                                              INPUT tel_cdcoope2:SCREEN-VALUE,
                                              INPUT tel_cdagenci,
                                              INPUT tel_motivind,
                                              INPUT log_motivind).
                             END.
                          ELSE
                             IF aux_cdcooper <> 0 AND
                                tel_cdagenci =  0 THEN
                                DO:
                                   FOR EACH b-crapage1 WHERE b-crapage1.cdcooper = aux_cdcooper
                                                             NO-LOCK:

                                       FOR EACH b-crapikx1 WHERE b-crapikx1.cdcooper = b-crapage1.cdcooper AND
                                                                 b-crapikx1.cdagenci = b-crapage1.cdagenci AND
                                                                 b-crapikx1.dtindisp = glb_dtmvtolt
                                                                 EXCLUSIVE-LOCK:
                
                                           IF LOCKED b-crapikx1 THEN
                                              DO:
                                                 PAUSE 2 NO-MESSAGE.
                                                 NEXT.
                                     
                                              END.
                                           ELSE
                                             DO:
                                                FIND tt-log WHERE tt-log.cdcooper = b-crapikx1.cdcooper AND
                                                                  tt-log.cdagenci = b-crapikx1.cdagenci AND
                                                                  tt-log.dtindisp = glb_dtmvtolt 
                                                                  NO-LOCK NO-ERROR.
                                                
                                                IF AVAIL tt-log THEN
                                                   ASSIGN b-crapikx1.flindisp = YES 
                                                          b-crapikx1.dsmotivo = tel_motivind
                                                          tt-log.motivind = tel_motivind.
                                  
                                             END.
                                       END.
                                   END.
                                  
                                   FOR EACH tt-log NO-LOCK BY tt-log.cdcooper
                                                            BY tt-log.cdagenci:
                                       
                                       RUN gera_log (INPUT tt-log.cddopcao,
                                                     INPUT tt-log.cdcooper,
                                                     INPUT tt-log.cdagenci,
                                                     INPUT tt-log.motivind,
                                                     INPUT tt-log.motivant).
                                     
                                   END.


                                END.
                             ELSE
                                IF aux_cdcooper = 0  AND
                                   tel_cdagenci <> 0 THEN
                                   DO:
                                     FOR EACH b-crapcop1 NO-LOCK:
                          
                                         FOR EACH b-crapikx1 WHERE b-crapikx1.cdcooper = b-crapcop1.cdcooper AND
                                                                   b-crapikx1.cdagenci = tel_cdagenci        AND
                                                                   b-crapikx1.dtindisp = glb_dtmvtolt
                                                                   EXCLUSIVE-LOCK:
                                        
                                             IF LOCKED b-crapikx1 THEN
                                                DO: 
                                                   PAUSE 2 NO-MESSAGE.
                                                   NEXT.
                                                END.
                                              
                                             ELSE
                                                FIND tt-log WHERE tt-log.cdcooper = b-crapikx1.cdcooper AND
                                                                  tt-log.cdagenci = b-crapikx1.cdagenci AND
                                                                  tt-log.dtindisp = b-crapikx1.dtindisp 
                                                                  NO-LOCK NO-ERROR.
                                                
                                                IF AVAIL tt-log THEN
                                                   ASSIGN b-crapikx1.flindisp = YES 
                                                          b-crapikx1.dsmotivo = tel_motivind
                                                          tt-log.motivind = tel_motivind.
                                         END.

                                     END.
                                    
                                     FOR EACH tt-log NO-LOCK BY tt-log.cdcooper
                                                              BY tt-log.cdagenci:
                                       
                                         RUN gera_log (INPUT tt-log.cddopcao,
                                                       INPUT tt-log.cdcooper,
                                                       INPUT tt-log.cdagenci,
                                                       INPUT tt-log.motivind,
                                                       INPUT tt-log.motivant).
                                     END.
                                   END.
                               ELSE
                                 IF aux_cdcooper = 0  AND
                                    tel_cdagenci = 0  THEN
                                    DO:
                                       FOR EACH b-crapikx1 WHERE b-crapikx1.dtindisp = glb_dtmvtolt
                                                                 EXCLUSIVE-LOCK:
                               
                                           IF LOCKED b-crapikx1 THEN
                                              DO:
                                                 PAUSE 2 NO-MESSAGE.
                                                 NEXT.
                                        
                                              END.
                                           ELSE  
                                              FIND tt-log WHERE tt-log.cdcooper = b-crapikx1.cdcooper  AND
                                                                tt-log.cdagenci = b-crapikx1.cdagenci  AND
                                                                tt-log.dtindisp = b-crapikx1.dtindisp
                                                                NO-LOCK NO-ERROR.
                                                
                                              IF AVAIL tt-log THEN
                                                 ASSIGN b-crapikx1.flindisp = YES 
                                                        b-crapikx1.dsmotivo = tel_motivind
                                                        tt-log.motivind = tel_motivind.
                                       END.
                                      
                                       FOR EACH tt-log NO-LOCK BY tt-log.cdcooper
                                                                BY tt-log.cdagenci:
                                       
                                           RUN gera_log (INPUT tt-log.cddopcao,
                                                         INPUT tt-log.cdcooper,
                                                         INPUT tt-log.cdagenci,
                                                         INPUT tt-log.motivind,
                                                         INPUT tt-log.motivant).
                                         
                                       END.
                                    
                                    END.
     
                      END.
                  
                      RELEASE b-crapikx1.
                   
                   END.
                ELSE
                   HIDE FRAME f_indkfx.
             END.
          ELSE
             IF glb_cddopcao = "E" THEN
                DO:
                   aux_confirma = "N".

                   VIEW FRAME f_exclusao.
                    
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                      UPDATE tel_cdcoope3
                             tel_cdagenci
                             WITH FRAME f_exclusao.

                      aux_cdcooper = INT(tel_cdcoope3).


                       IF tel_cdagenci <> 0 THEN
                          DO:
                            RUN valida_pac (INPUT  aux_cdcooper,
                                            INPUT  tel_cdagenci,
                                            OUTPUT aux_cdagenci).
                         
                            IF RETURN-VALUE = "NOK" THEN
                               NEXT.

                            DISPLAY aux_cdagenci
                                    WITH FRAME f_exclusao.

                      
                          END.
                      
                      LEAVE.
                   END.
                                 
                   IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                      NEXT.        
                        
                   IF  aux_cdcooper <> 0 AND
                       tel_cdagenci <> 0 THEN
                       DO:
                           FIND crapikx WHERE crapikx.cdcooper = aux_cdcooper AND
                                              crapikx.cdagenci = tel_cdagenci AND
                                              crapikx.dtindisp = glb_dtmvtolt
                                              NO-LOCK NO-ERROR.
        
                           IF  NOT AVAILABLE crapikx   THEN
                               DO:
                                  MESSAGE "Indisponibilidade nao encontrada.".
                                  PAUSE 2 NO-MESSAGE.
                                  RETURN.
                               END.
                           ELSE 
                               DO:
                                    ASSIGN tel_motivind = crapikx.dsmotivo.
                                    DISPLAY tel_motivind WITH FRAME f_exclusao.
                               END.
                       END.
                      
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                      MESSAGE "Confirma a operação?"
                      UPDATE aux_confirma.
                      LEAVE.
                   END.
                
                   IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                      NEXT.
                
                   IF aux_confirma = "S" THEN
                      DO:
                         DO TRANSACTION:            
                             
                             IF aux_cdcooper <> 0 AND
                                tel_cdagenci <> 0 THEN
                                DO: 
                                   FIND CURRENT crapikx EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                   IF NOT AVAILABLE crapikx   THEN
                                      DO:
                                         IF LOCKED crapikx  THEN
                                            DO:
                                               PAUSE 2 NO-MESSAGE.
                                               NEXT.

                                            END.
                                         ELSE
                                            DO:
                                               MESSAGE "Indisponibilidade nao encontrada.".
                                               PAUSE 2 NO-MESSAGE.
                                               RETURN.
                                            END.
                                      END.
                                   
                                   DELETE crapikx.
                                    
                                   RUN gera_log (INPUT glb_cddopcao,
                                                 INPUT tel_cdcoope3:SCREEN-VALUE,
                                                 INPUT tel_cdagenci,
                                                 INPUT "",
                                                 INPUT "").
                                END.
                             ELSE
                                IF aux_cdcooper = 0 AND
                                   tel_cdagenci = 0 THEN
                                   DO: 
                                      FOR EACH b-crapcop1 NO-LOCK:

                                          FOR EACH crapage WHERE crapage.cdcooper = b-crapcop1.cdcooper
                                                                 NO-LOCK:
                                              
                                              FIND crapikx WHERE crapikx.cdcooper = crapage.cdcooper AND
                                                                 crapikx.cdagenci = crapage.cdagenci AND
                                                                 crapikx.dtindisp = glb_dtmvtolt
                                                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                                         
                                              IF NOT AVAILABLE crapikx   THEN
                                                 DO:
                                                    IF LOCKED crapikx  THEN
                                                       DO:
                                                          PAUSE 2 NO-MESSAGE.
                                                          NEXT.
                                                       END.
                                                 END.
                                               ELSE
                                                  DO: 
                                                     aux_flregexi = TRUE.

                                                     DELETE crapikx.
                                                  
                                                  END.
                                          END.
                                      END.
                                      
                                      IF aux_flregexi = FALSE THEN
                                         DO:
                                            MESSAGE "Indisponibilidade nao encontrada.".
                                            PAUSE(2) NO-MESSAGE.
                                            RETURN.
                                     
                                         END.
                                     
                                      RUN gera_log (INPUT glb_cddopcao,
                                                    INPUT tel_cdcoope3:SCREEN-VALUE,
                                                    INPUT tel_cdagenci,
                                                    INPUT "",
                                                    INPUT "").

                                    
                                   END.
                                ELSE
                                  IF aux_cdcooper <> 0 AND
                                     tel_cdagenci = 0 THEN
                                     DO: 
                                        FOR EACH crapage WHERE crapage.cdcooper = aux_cdcooper
                                                               NO-LOCK:
                                  
                                            FIND crapikx WHERE crapikx.cdcooper = aux_cdcooper     AND
                                                               crapikx.cdagenci = crapage.cdagenci AND
                                                               crapikx.dtindisp = glb_dtmvtolt
                                                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                                       
                                  
                                            IF NOT AVAILABLE crapikx   THEN
                                               DO:
                                                  IF LOCKED crapikx  THEN
                                                     DO:
                                                        PAUSE 2 NO-MESSAGE.
                                                        NEXT.
                                                     END.
                                                     
                                               END.
                                            ELSE
                                               DO:
                                                 aux_flregexi = TRUE. 
                                               
                                                 DELETE crapikx.

                                               END.
                                          
                                            
                                        END.

                                        IF aux_flregexi = FALSE THEN
                                           DO:
                                              MESSAGE "Indisponibilidade nao encontrada.".
                                              PAUSE(2) NO-MESSAGE.
                                              RETURN.
                                       
                                           END.
                                  
                                        RUN gera_log (INPUT glb_cddopcao,
                                                      INPUT tel_cdcoope3:SCREEN-VALUE,
                                                      INPUT tel_cdagenci,
                                                      INPUT "",
                                                      INPUT "").

                                      
                                     END.
                                  ELSE
                                     IF aux_cdcooper = 0  AND
                                        tel_cdagenci <> 0 THEN
                                        DO: 
                                           FOR EACH b-crapcop1 NO-LOCK:
                                     
                                               FIND crapikx WHERE crapikx.cdcooper = b-crapcop1.cdcooper AND
                                                                  crapikx.cdagenci = tel_cdagenci        AND
                                                                  crapikx.dtindisp = glb_dtmvtolt
                                                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                                          
                                     
                                               IF NOT AVAILABLE crapikx   THEN
                                                  DO:
                                                     IF LOCKED crapikx  THEN
                                                        DO:
                                                           PAUSE 2 NO-MESSAGE.
                                                           NEXT.
                                                        END.
                                                        
                                                  END.
                                               ELSE
                                                 DO:
                                                   aux_flregexi = TRUE. 
                                                   
                                                   DELETE crapikx.
                                                 
                                                 END.

                                     
                                           END.

                                           IF aux_flregexi = FALSE THEN
                                              DO:
                                                 MESSAGE "Indisponibilidade nao encontrada.".
                                                 PAUSE(2) NO-MESSAGE.
                                                 RETURN.
                                           
                                              END.
                                     
                                           RUN gera_log (INPUT glb_cddopcao,
                                                         INPUT tel_cdcoope3:SCREEN-VALUE,
                                                         INPUT tel_cdagenci,
                                                         INPUT "",
                                                         INPUT "").
                                        END.
                         END.

                         RELEASE crapikx.
                      
                      END.

                   ELSE
                     HIDE  FRAME f_exclusao.
                END.


END.



PROCEDURE valida_pac:


   DEF INPUT  PARAM par_cdcooper LIKE aux_cdcooper NO-UNDO.
   DEF INPUT  PARAM par_cdagenci LIKE tel_cdagenci NO-UNDO.
   DEF OUTPUT PARAM par_auxcdage LIKE aux_cdagenci NO-UNDO.

   DEF VAR aux_ageexist AS LOG                     NO-UNDO.
   

   aux_ageexist = FALSE.

   IF par_cdcooper <> 0 AND
      par_cdagenci <> 0  THEN
      DO:
        FIND crapage WHERE crapage.cdcooper = par_cdcooper AND
                           crapage.cdagenci = par_cdagenci
                           NO-LOCK NO-ERROR.
    
        IF AVAIL crapage THEN
           ASSIGN aux_ageexist = TRUE
                  par_auxcdage = " - " + crapage.nmresage.
        ELSE
           DO:
              glb_cdcritic = 962.
              RUN fontes/critic.p.
              BELL.
              MESSAGE glb_dscritic.
              ASSIGN glb_cdcritic = 0.
    
           END.
   
      END.
   ELSE
      DO:
        FIND FIRST crapage WHERE crapage.cdagenci = par_cdagenci
                                 NO-LOCK NO-ERROR.
      
        IF NOT AVAIL crapage THEN
           DO:
              glb_cdcritic = 962.
              RUN fontes/critic.p.
              BELL.
              MESSAGE glb_dscritic.
              ASSIGN glb_cdcritic = 0.      
           END.
        ELSE
           aux_ageexist = TRUE.
     
      END.
     
   IF aux_ageexist = TRUE THEN
      RETURN "OK".
   ELSE
      RETURN "NOK".
      

END. /*FIM */



PROCEDURE gera_log:

    DEF INPUT PARAM par_cddopcao  LIKE glb_cddopcao       NO-UNDO.
    DEF INPUT PARAM par_cdcooper  AS CHAR FORMAT "x(12)"  NO-UNDO.
    DEF INPUT PARAM par_cdagenci  LIKE tel_cdagenci       NO-UNDO.
    DEF INPUT PARAM par_motivind  LIKE tel_motivind       NO-UNDO.
    DEF INPUT PARAM par_mtindant  LIKE tel_motivind       NO-UNDO.
    

    IF par_cddopcao = "I" THEN
       UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999")        +
                         " "     + STRING(TIME,"HH:MM:SS")  + "' --> '"     +
                         " Operador " + glb_cdoperad + " - " + "Criou"      +
                         " a indisponibilidade para "                       + 
                         (IF INT(par_cdcooper) = 0 THEN
                         "todas as cooperativas" ELSE "a Cooperativa "      +  
                         STRING(par_cdcooper))                              + 
                         (IF INT(par_cdagenci) = 0 THEN
                         ", todos os PAs" ELSE " PA "      +  
                         STRING(par_cdagenci))  + ", data de inicio "       + 
                         STRING(glb_dtmvtolt,"99/99/9999")                  +
                         ", motivo: " + par_motivind + "."                  +
                         " >> log/indkfx.log").
    ELSE
       IF par_cddopcao = "E" THEN
          UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999")       +
                           " "     + STRING(TIME,"HH:MM:SS")  + "' --> '"     +
                           " Operador " + glb_cdoperad + " - " + "Excluiu"    +
                           " a indisponibilidade para "                       + 
                           (IF INT(par_cdcooper) = 0 THEN
                           "todas as cooperativas" ELSE "a Cooperativa "      +  
                           STRING(par_cdcooper))                              + 
                           (IF INT(par_cdagenci) = 0 THEN
                           ", todos os PAs" ELSE " PA "                     +  
                           STRING(par_cdagenci))                              +
                           ", data de inicio "                                + 
                           STRING(glb_dtmvtolt,"99/99/9999") + "."            + 
                           " >> log/indkfx.log").
    ELSE
       IF par_cddopcao = "A" THEN
          UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999")       +
                " "     + STRING(TIME,"HH:MM:SS")  + "' --> '"                +
                " Operador " + glb_cdoperad + " - " + "Alterou"               +
                " a indisponibilidade para a Cooperativa "                    +  
                STRING(par_cdcooper) + " PA " + STRING(par_cdagenci)         +                                                    
                ", motivo " + par_mtindant + " para "                         +
                (IF par_motivind = par_mtindant THEN  
                "---" ELSE
                par_motivind) + "." + " >> log/indkfx.log").



END PROCEDURE.


/***************************************************************************/

