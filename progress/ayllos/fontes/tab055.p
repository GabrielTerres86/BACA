/*..............................................................................

    Programa: Fontes/tab055.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : David
    Data    : Dezembro/2009                     Ultima alteracao: 08/06/2017

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Tab055 -  Horarios de Devolucao
   
    Alteracao : 10/09/2012 - Incluido faixa de horario para devolucao VLB.
                             (Fabricio)
                
                13/12/2013 - Alteracao referente a integracao Progress X 
                             Dataserver Oracle 
                             Inclusao do VALIDATE ( Andre Euzebio / SUPERO) 
                             
                19/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                           
                21/12/2015 - Ajustar os labels da tela para Devolucao Diurna e 
                             Devolucao Noturna (Douglas - Melhoria 100)
                
                25/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).                                         
                
                07/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
                            
                08/06/2017 - Tirada devoluçao VLB e alterada Devolucao Noturna para Devolucao
                             Fraudes e Impedimentos. PRJ367 - Compe Sessao Unica (Lombardi)
                            
..............................................................................*/

{ includes/var_online.i }

DEF VAR tel_hrinidv1 AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR tel_mminidv1 AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR tel_hrfimdv1 AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR tel_mmfimdv1 AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR tel_hrinidv2 AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR tel_mminidv2 AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR tel_hrfimdv2 AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR tel_mmfimdv2 AS INTE FORMAT "99"                               NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                             NO-UNDO.
DEF VAR aux_hrinidv1 AS CHAR                                           NO-UNDO.
DEF VAR aux_hrfimdv1 AS CHAR                                           NO-UNDO.
DEF VAR aux_hrinidv2 AS CHAR                                           NO-UNDO.
DEF VAR aux_hrfimdv2 AS CHAR                                           NO-UNDO.

DEF VAR aux_contador AS INTE                                           NO-UNDO.

DEF VAR aux_dadosusr AS CHAR                                           NO-UNDO.
DEF VAR par_loginusr AS CHAR                                           NO-UNDO.
DEF VAR par_nmusuari AS CHAR                                           NO-UNDO.
DEF VAR par_dsdevice AS CHAR                                           NO-UNDO.
DEF VAR par_dtconnec AS CHAR                                           NO-UNDO.
DEF VAR par_numipusr AS CHAR                                           NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                         NO-UNDO.



FORM WITH ROW 4 OVERLAY TITLE glb_tldatela SIZE 80 BY 18 FRAME f_moldura.

FORM glb_cddopcao AT 14 LABEL "Opcao"  AUTO-RETURN FORMAT "!(1)"
                  HELP "Entre com a opcao desejada (A,C)."
                  VALIDATE(CAN-DO("A,C",glb_cddopcao),"014 - Opcao errada.")
     SKIP(1)
     "----------- Devolucao Diurna ----------"
     SKIP(1)
     tel_hrinidv1       LABEL "Inicio" AUTO-RETURN
                  HELP "Entre com a hora inicial da primeira devolucao."
     ":"          AT 11
     tel_mminidv1 AT 12 NO-LABEL
                  HELP "Entre com a hora inicial da primeira devolucao."
     tel_hrfimdv1 AT 28 LABEL "Final"  AUTO-RETURN
                  HELP "Entre com a hora final da primeira devolucao."
     ":"          AT 37
     tel_mmfimdv1 AT 38 NO-LABEL
                  HELP "Entre com a hora final da primeira devolucao."
     SKIP(2)     
     "--- Devolucao Fraudes e Impedimentos --"  
     SKIP(1)
     tel_hrinidv2       LABEL "Inicio" AUTO-RETURN
                  HELP "Entre com a hora inicial da segunda devolucao."
     ":"          AT 11
     tel_mminidv2 AT 12 NO-LABEL
                  HELP "Entre com a hora inicial da segunda devolucao."
     tel_hrfimdv2 AT 28 LABEL "Final"  AUTO-RETURN
                  HELP "Entre com a hora final da segunda devolucao."
     ":"          AT 37
     tel_mmfimdv2 AT 38 NO-LABEL
                  HELP "Entre com a hora final da segunda devolucao."
     WITH ROW 6 OVERLAY CENTERED NO-BOX SIDE-LABELS FRAME f_tab055.

VIEW FRAME f_moldura.
PAUSE(0).

ASSIGN glb_cddopcao = "C".

DO WHILE TRUE:

    RUN fontes/inicia.p.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE glb_cddopcao WITH FRAME f_tab055.
        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            RUN fontes/novatela.p.

            IF  CAPS(glb_nmdatela) <> "tab054"  THEN
                DO:
                    HIDE FRAME f_tab055.
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

    IF  glb_cddopcao  = "A"  AND
        glb_cddepart <> 20   AND   /* TI                   */                
        glb_cddepart <>  8   AND   /* COORD.ADM/FINANCEIRO */
        glb_cddepart <>  9   AND   /* COORD.PRODUTOS       */
        glb_cddepart <>  4   THEN  /* COMPE                */
        
        DO:
            ASSIGN glb_cdcritic = 36.
            RUN fontes/critic.p.
            ASSIGN glb_cdcritic = 0.

            BELL.
            MESSAGE glb_dscritic.

            NEXT.
        END.

    FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "GENERI"     AND
                       craptab.cdempres = 0            AND
                       craptab.cdacesso = "HRTRDEVOLU" AND
                       craptab.tpregist = 0            NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craptab  THEN
        DO:
            DO TRANSACTION ON ERROR UNDO, LEAVE:
            
                CREATE craptab.
                ASSIGN craptab.cdcooper = glb_cdcooper
                       craptab.nmsistem = "CRED"
                       craptab.tptabela = "GENERI"
                       craptab.cdempres = 0
                       craptab.cdacesso = "HRTRDEVOLU"
                       craptab.tpregist = 0
                       craptab.dstextab = "00000;00000;28800;41400;41401;57600".
                VALIDATE craptab.

                FIND CURRENT craptab NO-LOCK NO-ERROR.

            END. /** Fim do DO TRANSACTION **/
        END.

    ASSIGN aux_hrinidv1 = STRING(INTE(ENTRY(3,craptab.dstextab,";")),"HH:MM")
           aux_hrfimdv1 = STRING(INTE(ENTRY(4,craptab.dstextab,";")),"HH:MM")
           aux_hrinidv2 = STRING(INTE(ENTRY(5,craptab.dstextab,";")),"HH:MM")
           aux_hrfimdv2 = STRING(INTE(ENTRY(6,craptab.dstextab,";")),"HH:MM")
           tel_hrinidv1 = INTE(SUBSTR(aux_hrinidv1,1,2))
           tel_mminidv1 = INTE(SUBSTR(aux_hrinidv1,4,2))
           tel_hrfimdv1 = INTE(SUBSTR(aux_hrfimdv1,1,2))
           tel_mmfimdv1 = INTE(SUBSTR(aux_hrfimdv1,4,2))
           tel_hrinidv2 = INTE(SUBSTR(aux_hrinidv2,1,2))
           tel_mminidv2 = INTE(SUBSTR(aux_hrinidv2,4,2))
           tel_hrfimdv2 = INTE(SUBSTR(aux_hrfimdv2,1,2))
           tel_mmfimdv2 = INTE(SUBSTR(aux_hrfimdv2,4,2)).

    DISPLAY tel_hrinidv1 tel_mminidv1 tel_hrfimdv1 tel_mmfimdv1
            tel_hrinidv2 tel_mminidv2 tel_hrfimdv2 tel_mmfimdv2
            WITH FRAME f_tab055.

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

                UPDATE tel_hrinidv1 tel_mminidv1 tel_hrfimdv1 tel_mmfimdv1 
                       tel_hrinidv2 tel_mminidv2 tel_hrfimdv2 tel_mmfimdv2 
                       WITH FRAME f_tab055.

                IF  tel_hrinidv1 > 23  THEN
                    DO:
                        ASSIGN glb_cdcritic = 687.
                        NEXT-PROMPT tel_hrinidv1 WITH FRAME f_tab055.
                        NEXT.
                    END.

                IF  tel_mminidv1 > 59  THEN
                    DO:
                        ASSIGN glb_cdcritic = 687.
                        NEXT-PROMPT tel_mminidv1 WITH FRAME f_tab055.
                        NEXT.
                    END.

                IF  tel_hrfimdv1 > 23  THEN
                    DO:
                        ASSIGN glb_cdcritic = 687.
                        NEXT-PROMPT tel_hrfimdv1 WITH FRAME f_tab055.
                        NEXT.
                    END.

                IF  tel_mmfimdv1 > 59  THEN
                    DO:
                        ASSIGN glb_cdcritic = 687.
                        NEXT-PROMPT tel_mmfimdv1 WITH FRAME f_tab055.
                        NEXT.
                    END.

                IF  ((tel_hrinidv1 * 3600) + (tel_mminidv1 * 60))  >= 
                    ((tel_hrfimdv1 * 3600) + (tel_mmfimdv1 * 60))  THEN
                    DO:
                        ASSIGN glb_cdcritic = 687.
                        NEXT-PROMPT tel_hrinidv1 WITH FRAME f_tab055.
                        NEXT.
                    END.

                IF  tel_hrinidv2 > 23  THEN
                    DO:
                        ASSIGN glb_cdcritic = 687.
                        NEXT-PROMPT tel_hrinidv2 WITH FRAME f_tab055.
                        NEXT.
                    END.

                IF  tel_mminidv2 > 59  THEN
                    DO:
                        ASSIGN glb_cdcritic = 687.
                        NEXT-PROMPT tel_mminidv2 WITH FRAME f_tab055.
                        NEXT.
                    END.

                IF  tel_hrfimdv2 > 23  THEN
                    DO:
                        ASSIGN glb_cdcritic = 687.
                        NEXT-PROMPT tel_hrfimdv2 WITH FRAME f_tab055.
                        NEXT.
                    END.

                IF  tel_mmfimdv2 > 59  THEN
                    DO:
                        ASSIGN glb_cdcritic = 687.
                        NEXT-PROMPT tel_mmfimdv2 WITH FRAME f_tab055.
                        NEXT.
                    END.

                IF  ((tel_hrinidv2 * 3600) + (tel_mminidv2 * 60))  >= 
                    ((tel_hrfimdv2 * 3600) + (tel_mmfimdv2 * 60))  THEN
                    DO:
                        ASSIGN glb_cdcritic = 687.
                        NEXT-PROMPT tel_hrinidv2 WITH FRAME f_tab055.
                        NEXT.
                    END.

                IF  ((tel_hrfimdv1 * 3600) + (tel_mmfimdv1 * 60))  >= 
                    ((tel_hrinidv2 * 3600) + (tel_mminidv2 * 60))  THEN
                    DO:
                        ASSIGN glb_cdcritic = 687.
                        NEXT-PROMPT tel_hrinidv2 WITH FRAME f_tab055.
                        NEXT.
                    END.

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

            ASSIGN aux_hrinidv1 = STRING((tel_hrinidv1 * 3600) + 
                                         (tel_mminidv1 * 60),"99999")
                   aux_hrfimdv1 = STRING((tel_hrfimdv1 * 3600) + 
                                         (tel_mmfimdv1 * 60),"99999")
                   aux_hrinidv2 = STRING((tel_hrinidv2 * 3600) + 
                                         (tel_mminidv2 * 60),"99999")
                   aux_hrfimdv2 = STRING((tel_hrfimdv2 * 3600) + 
                                         (tel_mmfimdv2 * 60),"99999").

            DO TRANSACTION ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

                DO aux_contador = 1 TO 10:

                    ASSIGN glb_cdcritic = 0.
    
                    FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                       craptab.nmsistem = "CRED"       AND
                                       craptab.tptabela = "GENERI"     AND
                                       craptab.cdempres = 0            AND
                                       craptab.cdacesso = "HRTRDEVOLU" AND
                                       craptab.tpregist = 0            
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                    IF  NOT AVAILABLE craptab  THEN
                        DO:
                            IF  LOCKED craptab  THEN
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
                
                ASSIGN craptab.dstextab = "00000;00000;" + /* horário inicial e final VLB zerados*/
                                          aux_hrinidv1 + ";" + 
                                          aux_hrfimdv1 + ";" +
                                          aux_hrinidv2 + ";" + 
                                          aux_hrfimdv2.

                FIND CURRENT craptab NO-LOCK NO-ERROR.

            END. /** Fim do DO TRANSACTION **/
        END.

END. /** Fim do DO WHILE TRUE **/

/*............................................................................*/
