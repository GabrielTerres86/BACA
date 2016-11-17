
/*..............................................................................

   Programa: Fontes/tab085.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Outubro/2009                        Ultima alteracao: 13/09/2016

   Dados referentes ao programa:

   Frequencia: Diario (On-Line)
   Objetivo  : Tab085 - Parametros para SPB.
   
   Alteracao :
              19/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
              
              06/03/2015 - Alterado para não validar o departamento do operador 
                           no momento de alteração.

              26/10/2015 - Inclusao indicador estado de crise. (Jaison/Andrino)
              
              02/12/2015 - Incluido alteracao de horarios para VRboleto para
                           todas as coops e log deste procedimento 
                           (Tiago/Elton Melhoria 261).

              19/08/2016 - Incluido campo "Operando com SPB-PAG". PRJ-312.
                           (Reinert)

              13/09/2016 - Ajuste para efetuar log de todas as informacoes alteradas
						   (Adriano).
						
..............................................................................*/

{ includes/var_online.i }

DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!"                                NO-UNDO.

DEF VAR aux_contador AS INTE                                           NO-UNDO.

DEF VAR tel_flgopstr AS LOGI FORMAT "SIM/NAO"                          NO-UNDO.
DEF VAR tel_flgoppag AS LOGI FORMAT "SIM/NAO"                          NO-UNDO.
DEF VAR tel_flgopbol AS LOGI FORMAT "SIM/NAO"                          NO-UNDO.
DEF VAR tel_flgcrise AS LOGI FORMAT "SIM/NAO"                          NO-UNDO.

DEF VAR hor_inioppag AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR min_inioppag AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR hor_fimoppag AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR min_fimoppag AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR tel_vlmaxpag LIKE crapcop.vlmaxpag FORMAT ">>>>,>>>,>>9.99"    NO-UNDO.
DEF VAR hor_iniopstr AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR min_iniopstr AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR hor_fimopstr AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR min_fimopstr AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR hor_iniopbol AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR min_iniopbol AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR hor_fimopbol AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR min_fimopbol AS INTE FORMAT "99"                               NO-UNDO.

DEF VAR log_flgcrise AS LOGI FORMAT "SIM/NAO"                          NO-UNDO.

DEF VAR log_flgopbol AS LOGI FORMAT "SIM/NAO"                          NO-UNDO.
DEF VAR log_inihrbol AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR log_inimnbol AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR log_fimhrbol AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR log_fimmnbol AS INTE FORMAT "99"                               NO-UNDO.

DEF VAR log_flgopstr AS LOGI FORMAT "SIM/NAO"                          NO-UNDO.
DEF VAR log_inihrstr AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR log_inimnstr AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR log_fimhrstr AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR log_fimmnstr AS INTE FORMAT "99"                               NO-UNDO.

DEF VAR log_flgoppag AS LOGI FORMAT "SIM/NAO"                          NO-UNDO.
DEF VAR log_inihrpag AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR log_inimnpag AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR log_fimhrpag AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR log_fimmnpag AS INTE FORMAT "99"                               NO-UNDO.

DEF VAR log_vlmaxpag LIKE crapcop.vlmaxpag FORMAT ">>>>,>>>,>>9.99"    NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_desccoop AS CHAR FORMAT "x(12)" VIEW-AS COMBO-BOX               
                        INNER-LINES 11                                 NO-UNDO.
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.


DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.
DEF        VAR h-b1wgen0014 AS HANDLE                                NO-UNDO.

DEF BUFFER crabtab FOR craptab.

FORM WITH ROW 4 OVERLAY SIZE 80 BY 18 TITLE glb_tldatela FRAME f_tab085.

FORM glb_cddopcao AT 05 LABEL "Opcao" AUTO-RETURN FORMAT "!"
                  HELP "Informe a opcao desejada (C)."
                  VALIDATE(glb_cddopcao = "C","014 - Opcao errada.")
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-LABEL NO-BOX FRAME f_opcao.

FORM glb_cddopcao AT 05 LABEL "Opcao" AUTO-RETURN FORMAT "!"
                  HELP "Informe a opcao desejada (A,C)."
                  VALIDATE(CAN-DO("C,A",glb_cddopcao),"014 - Opcao errada.")
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-LABEL NO-BOX FRAME f_opcao_cecred.      

FORM aux_desccoop AT 01 LABEL "Cooperativa" FORMAT "x(11)"
     WITH ROW 6 COLUMN 22 OVERLAY SIDE-LABELS NO-BOX NO-LABEL FRAME f_desccoop.

FORM "--------- Parametros SPB-STR --------"
     tel_flgopstr AT 01 LABEL "Operando com SPB-STR" 
                  HELP "Informe 'S' para SIM ou 'N' para NAO"
     SKIP
     hor_iniopstr AT 01 LABEL "Horario para SPB-STR"         
                  HELP "Informe o horario inicial para SPB-STR"
     ":"          AT 25
     min_iniopstr AT 26 NO-LABEL   
                  HELP "Informe o horario inicial para SPB-STR"
     "ate"        AT 29 
     hor_fimopstr AT 33 NO-LABEL
                  HELP "Informe o horario final para SPB-STR"
     ":"          AT 35
     min_fimopstr AT 36 NO-LABEL   
                  HELP "Informe o horario final para SPB-STR"
     SKIP(1)   
     "--------- Parametros SPB-PAG --------"
     tel_flgoppag AT 01 LABEL "Operando com SPB-PAG" 
                  HELP "Informe 'S' para SIM ou 'N' para NAO"
     SKIP
     hor_inioppag AT 01 LABEL "Horario para SPB-PAG"         
                  HELP "Informe o horario inicial para SPB-PAG"
     ":"          AT 25
     min_inioppag AT 26 NO-LABEL   
                  HELP "Informe o horario inicial para SPB-PAG"
     "ate"        AT 29
     hor_fimoppag AT 33 NO-LABEL
                  HELP "Informe o horario final para SPB-PAG"
     ":"          AT 35
     min_fimoppag AT 36 NO-LABEL   
                  HELP "Informe o horario final para SPB-PAG"    
     SKIP
     tel_vlmaxpag AT 09 LABEL "Valor maximo"
                  HELP "Informe o valor maximo para SPB-PAG"
     WITH ROW 7 CENTERED OVERLAY NO-LABEL SIDE-LABELS NO-BOX 
          FRAME f_dados.

FORM "-------- Parametros VR-BOLETO -------"
    tel_flgopbol AT 01 LABEL "Pagamento  VR-Boleto" 
                 HELP "Informe 'S' para SIM ou 'N' para NAO"
    SKIP
    hor_iniopbol AT 03 LABEL "Horario  VR-Boleto"         
                 HELP "Informe o horario inicial para VR-Boleto"
    ":"          AT 25
    min_iniopbol AT 26 NO-LABEL   
                 HELP "Informe o horario inicial para VR-Boleto"
    "ate"        AT 29
    hor_fimopbol AT 33 NO-LABEL
                 HELP "Informe o horario final para VR-Boleto"
    ":"          AT 35
    min_fimopbol AT 36 NO-LABEL   
                 HELP "Informe o horario final para VR-Boleto"    
     WITH ROW 16 CENTERED OVERLAY NO-LABEL SIDE-LABELS NO-BOX 
          FRAME f_dados_vrboleto.

FORM tel_flgcrise AT 01 LABEL "Sistema em estado de crise" 
                  HELP "Informe 'S' para SIM ou 'N' para NAO"
     WITH ROW 20 CENTERED OVERLAY NO-LABEL SIDE-LABELS NO-BOX 
          FRAME f_dados_cecred.


ASSIGN glb_cddopcao = "C".

VIEW FRAME f_tab085.
PAUSE(0).

RUN fontes/inicia.p.

ON  RETURN OF aux_desccoop
    DO:
        IF  aux_desccoop:SCREEN-VALUE = ? THEN
            DO: 
                  ASSIGN glb_dscritic = "Selecione uma cooperativa.".
                  BELL.
                  MESSAGE glb_dscritic.
                  
                  NEXT.

            END.
                        
        ASSIGN aux_cdcooper = INT(aux_desccoop:SCREEN-VALUE 
                                            IN FRAME f_desccoop).
        APPLY "GO".
    END.

DO WHILE TRUE TRANSACTION:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       
       IF (glb_cdcooper = 3) THEN
          UPDATE glb_cddopcao WITH FRAME f_opcao_cecred.
       ELSE
        UPDATE glb_cddopcao WITH FRAME f_opcao.
        
        LEAVE.
      
    END. 
   
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN    
        DO:
            RUN fontes/novatela.p.
            
            IF  CAPS(glb_nmdatela) <> "tab085"  THEN
                DO:
                    HIDE FRAME f_tab085.
                    IF (glb_cdcooper = 3) THEN
                    HIDE FRAME f_opcao.
                    ELSE
                      HIDE FRAME f_opcao_cecred.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.
    
    IF  aux_cddopcao <> glb_cddopcao  THEN
        DO:
            { includes/acesso.i }
            
            aux_cddopcao = glb_cddopcao.
        END.
    
    RUN pi_carrega_cooperativas.

    IF glb_cdcooper = 3 THEN
        UPDATE aux_desccoop WITH FRAME f_desccoop.
    ELSE
        DISP aux_desccoop WITH FRAME f_desccoop.

    IF  aux_cdcooper <> 0 THEN
        DO:
            FIND crapcop WHERE crapcop.cdcooper = aux_cdcooper NO-LOCK NO-ERROR.
    
            IF  NOT AVAILABLE crapcop  THEN
                DO:
                    ASSIGN glb_cdcritic = 651.
                    RUN fontes/critic.p.
                    ASSIGN glb_cdcritic = 0.
            
                    BELL.
                    MESSAGE glb_dscritic.
            
                    NEXT.
                END.            
        END.
    ELSE
        DO:
          FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

          IF  NOT AVAILABLE crapcop  THEN
              DO:
                  ASSIGN glb_cdcritic = 651.
                  RUN fontes/critic.p.
                  ASSIGN glb_cdcritic = 0.

                  BELL.
                  MESSAGE glb_dscritic.

                  NEXT.
              END.
        END.
    
    FIND craptab WHERE craptab.nmsistem = 'CRED'
                   AND craptab.tptabela = 'GENERI'
                   AND craptab.cdempres = 00
                   AND craptab.cdacesso = 'HRVRBOLETO'
                   AND craptab.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craptab  THEN
        DO:
            ASSIGN glb_cdcritic = 651.
            RUN fontes/critic.p.
            ASSIGN glb_cdcritic = 0.

            BELL.
            MESSAGE glb_dscritic.

            NEXT.
        END.            

    IF  aux_cdcooper <> 0 THEN
        DO:
          ASSIGN tel_flgopstr = crapcop.flgopstr
                 tel_flgoppag = crapcop.flgoppag
                 tel_flgopbol = LOGICAL(ENTRY(1,craptab.dstextab,";"))
                 log_flgopbol = tel_flgopbol
                 log_flgopstr = tel_flgopstr
                 log_flgoppag = tel_flgoppag
                 hor_iniopstr = INTE(SUBSTR(STRING(crapcop.iniopstr,"HH:MM"),1,2))
                 min_iniopstr = INTE(SUBSTR(STRING(crapcop.iniopstr,"HH:MM"),4,2))
                 hor_fimopstr = INTE(SUBSTR(STRING(crapcop.fimopstr,"HH:MM"),1,2))
                 min_fimopstr = INTE(SUBSTR(STRING(crapcop.fimopstr,"HH:MM"),4,2))
                 hor_inioppag = INTE(SUBSTR(STRING(crapcop.inioppag,"HH:MM"),1,2))
                 min_inioppag = INTE(SUBSTR(STRING(crapcop.inioppag,"HH:MM"),4,2))
                 hor_fimoppag = INTE(SUBSTR(STRING(crapcop.fimoppag,"HH:MM"),1,2))
                 min_fimoppag = INTE(SUBSTR(STRING(crapcop.fimoppag,"HH:MM"),4,2))
                 tel_vlmaxpag = crapcop.vlmaxpag
                 hor_iniopbol = INTE(SUBSTR(STRING(INTE(ENTRY(2,craptab.dstextab,";")),"HH:MM"),1,2))
                 min_iniopbol = INTE(SUBSTR(STRING(INTE(ENTRY(2,craptab.dstextab,";")),"HH:MM"),4,2))
                 hor_fimopbol = INTE(SUBSTR(STRING(INTE(ENTRY(3,craptab.dstextab,";")),"HH:MM"),1,2))
                 min_fimopbol = INTE(SUBSTR(STRING(INTE(ENTRY(3,craptab.dstextab,";")),"HH:MM"),4,2))
                 log_inihrbol = hor_iniopbol
                 log_inimnbol = min_iniopbol
                 log_fimhrbol = hor_fimopbol
                 log_fimmnbol = min_fimopbol		   
                 log_inihrstr = hor_iniopstr
                 log_inimnstr = min_iniopstr
                 log_fimhrstr = hor_fimopstr
                 log_fimmnstr = min_fimopstr		   
                 log_inihrpag = hor_inioppag
                 log_inimnpag = min_inioppag
                 log_fimhrpag = hor_fimoppag
                 log_fimmnpag = min_fimoppag
                 log_vlmaxpag = tel_vlmaxpag.
                       
        END.
    ELSE
        DO:
          ASSIGN tel_flgopstr = FALSE
                 tel_flgoppag = FALSE
                 tel_flgopbol = FALSE
                 log_flgopbol = FALSE
				 hor_iniopstr = 0
                 min_iniopstr = 0
                 hor_fimopstr = 0
                 min_fimopstr = 0
                 hor_inioppag = 0
                 min_inioppag = 0
                 hor_fimoppag = 0
                 min_fimoppag = 0
                 tel_vlmaxpag = 0
                 hor_iniopbol = 0
                 min_iniopbol = 0
                 hor_fimopbol = 0
                 min_fimopbol = 0
                 log_inihrbol = 0
                 log_inimnbol = 0
                 log_fimhrbol = 0
                 log_fimmnbol = 0.
        END.

    FIND craptab WHERE craptab.cdcooper = 0           AND
                       craptab.nmsistem = "CRED"      AND
                       craptab.tptabela = "GENERI"    AND
                       craptab.cdempres = 0           AND
                       craptab.cdacesso = "ESTCRISE"  AND
                       craptab.tpregist = 0           
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craptab   THEN
        ASSIGN tel_flgcrise = NO
			         log_flgcrise = tel_flgcrise.
    ELSE
        ASSIGN tel_flgcrise = IF craptab.dstextab = "S" THEN YES ELSE NO
			         log_flgcrise = tel_flgcrise.


    DISPLAY tel_flgopstr tel_flgoppag
            hor_iniopstr min_iniopstr
            hor_fimopstr min_fimopstr
            hor_inioppag min_inioppag
            hor_fimoppag min_fimoppag 
            tel_vlmaxpag WITH FRAME f_dados.

    IF  (glb_cddopcao = "C") OR 
        (glb_cddopcao = "A" AND glb_cdcooper = 3) THEN
        DO:
            DISPLAY tel_flgopbol
                    hor_iniopbol min_iniopbol
                    hor_fimopbol min_fimopbol WITH FRAME f_dados_vrboleto.
        
            IF aux_cdcooper = 0 OR glb_cddopcao = "C" THEN
            DISPLAY tel_flgcrise WITH FRAME f_dados_cecred.
            ELSE
               HIDE FRAME f_dados_cecred.
        END.

    IF  glb_cddopcao = "A" AND
        glb_cdcooper = 3   THEN
        DO:
            IF  glb_cdcooper <> 3  THEN
            DO:
                HIDE FRAME f_dados_vrboleto.
                HIDE FRAME f_dados_cecred.
            END.
                

             /*Agora a tela irá validar apenas pela tela PERMIS SD 242685*/
            /*IF  glb_dsdepart <> "TI"                    AND
                glb_dsdepart <> "SUPORTE"               AND
                glb_dsdepart <> "COORD.ADM/FINANCEIRO"  AND
                glb_dsdepart <> "COORD.PRODUTOS"        THEN
                DO:
                    ASSIGN glb_cdcritic = 36.
                    RUN fontes/critic.p.
                    ASSIGN glb_cdcritic = 0.
            
                    BELL.
                    MESSAGE glb_dscritic.
                    
                    NEXT.
                END.*/

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                UPDATE tel_flgopstr WITH FRAME f_dados.
                UPDATE hor_iniopstr WHEN tel_flgopstr = TRUE 
                       min_iniopstr WHEN tel_flgopstr = TRUE
                       hor_fimopstr WHEN tel_flgopstr = TRUE
                       min_fimopstr WHEN tel_flgopstr = TRUE 
                       WITH FRAME f_dados.

                IF  hor_iniopstr < 0 OR hor_iniopstr > 23  THEN
                    DO:
                        ASSIGN glb_cdcritic = 687.
                        RUN fontes/critic.p.
                        ASSIGN glb_cdcritic = 0.

                        BELL.
                        MESSAGE glb_dscritic.
                        
                        NEXT-PROMPT hor_iniopstr WITH FRAME f_dados.
                        NEXT.
                    END.

                IF  min_iniopstr < 0 OR min_iniopstr > 59  THEN
                    DO:
                        ASSIGN glb_cdcritic = 687.
                        RUN fontes/critic.p.
                        ASSIGN glb_cdcritic = 0.

                        BELL.
                        MESSAGE glb_dscritic.
                        
                        NEXT-PROMPT min_iniopstr WITH FRAME f_dados.
                        NEXT.
                    END.

                IF  hor_fimopstr < 0 OR hor_fimopstr > 23  THEN
                    DO:
                        ASSIGN glb_cdcritic = 687.
                        RUN fontes/critic.p.
                        ASSIGN glb_cdcritic = 0.

                        BELL.
                        MESSAGE glb_dscritic.
                        
                        NEXT-PROMPT hor_fimopstr WITH FRAME f_dados.
                        NEXT.
                    END.

                IF  min_fimopstr < 0 OR min_fimopstr > 59  THEN
                    DO:
                        ASSIGN glb_cdcritic = 687.
                        RUN fontes/critic.p.
                        ASSIGN glb_cdcritic = 0.

                        BELL.
                        MESSAGE glb_dscritic.
                        
                        NEXT-PROMPT min_fimopstr WITH FRAME f_dados.
                        NEXT.
                    END.

                IF  tel_flgopstr                                   AND
                    ((hor_iniopstr * 3600) + (min_iniopstr * 60))  >= 
                    ((hor_fimopstr * 3600) + (min_fimopstr * 60))  THEN
                    DO:
                        ASSIGN glb_cdcritic = 687.
                        RUN fontes/critic.p.
                        ASSIGN glb_cdcritic = 0.

                        BELL.
                        MESSAGE glb_dscritic.
                        
                        NEXT-PROMPT hor_iniopstr WITH FRAME f_dados.
                        NEXT.
                     END.

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    UPDATE tel_flgoppag WITH FRAME f_dados.
                    UPDATE hor_inioppag WHEN tel_flgoppag = TRUE
                           min_inioppag WHEN tel_flgoppag = TRUE
                           hor_fimoppag WHEN tel_flgoppag = TRUE
                           min_fimoppag WHEN tel_flgoppag = TRUE
                           tel_vlmaxpag WHEN tel_flgoppag = TRUE
                           WITH FRAME f_dados.

                    IF  hor_inioppag < 0 OR hor_inioppag > 23  THEN
                        DO:
                            ASSIGN glb_cdcritic = 687.
                            RUN fontes/critic.p.
                            ASSIGN glb_cdcritic = 0.
    
                            BELL.
                            MESSAGE glb_dscritic.
                            
                            NEXT-PROMPT hor_inioppag WITH FRAME f_dados.
                            NEXT.
                        END.
    
                    IF  min_inioppag < 0 OR min_inioppag > 59  THEN
                        DO:
                            ASSIGN glb_cdcritic = 687.
                            RUN fontes/critic.p.
                            ASSIGN glb_cdcritic = 0.
    
                            BELL.
                            MESSAGE glb_dscritic.
                            
                            NEXT-PROMPT min_inioppag WITH FRAME f_dados.
                            NEXT.
                        END.
    
                    IF  hor_fimoppag < 0 OR hor_fimoppag > 23  THEN
                        DO:
                            ASSIGN glb_cdcritic = 687.
                            RUN fontes/critic.p.
                            ASSIGN glb_cdcritic = 0.
    
                            BELL.
                            MESSAGE glb_dscritic.
                            
                            NEXT-PROMPT hor_fimoppag WITH FRAME f_dados.
                            NEXT.
                        END.
    
                    IF  min_fimoppag < 0 OR min_fimoppag > 59  THEN
                        DO:
                            ASSIGN glb_cdcritic = 687.
                            RUN fontes/critic.p.
                            ASSIGN glb_cdcritic = 0.
    
                            BELL.
                            MESSAGE glb_dscritic.
                            
                            NEXT-PROMPT min_fimoppag WITH FRAME f_dados.
                            NEXT.
                        END.
    
                    IF  tel_flgoppag                                   AND
                        ((hor_inioppag * 3600) + (min_inioppag * 60))  >= 
                        ((hor_fimoppag * 3600) + (min_fimoppag * 60))  THEN
                        DO:
                            ASSIGN glb_cdcritic = 687.
                            RUN fontes/critic.p.
                            ASSIGN glb_cdcritic = 0.
    
                            BELL.
                            MESSAGE glb_dscritic.
                            
                            NEXT-PROMPT hor_inioppag WITH FRAME f_dados.
                            NEXT.
                         END.

                    LEAVE.

                END. /** Fim do DO WHILE TRUE **/

                /****** VR BOLETO ***********************************/
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        
                    UPDATE tel_flgopbol hor_iniopbol min_iniopbol 
                            hor_fimopbol min_fimopbol WITH FRAME f_dados_vrboleto.
            
                    IF  hor_iniopbol < 0 OR hor_iniopbol > 23  THEN
                        DO:
                            ASSIGN glb_cdcritic = 687.
                            RUN fontes/critic.p.
                            ASSIGN glb_cdcritic = 0.
        
                            BELL.
                            MESSAGE glb_dscritic.
                                
                            NEXT-PROMPT hor_iniopbol WITH FRAME f_dados_vrboleto.
                            NEXT.
                        END.
            
                    IF  min_iniopbol < 0 OR min_iniopbol > 59  THEN
                        DO:
                            ASSIGN glb_cdcritic = 687.
                            RUN fontes/critic.p.
                            ASSIGN glb_cdcritic = 0.
        
                            BELL.
                            MESSAGE glb_dscritic.
                                
                            NEXT-PROMPT min_iniopbol WITH FRAME f_dados_vrboleto.
                            NEXT.
                        END.
            
                    IF  hor_fimopbol < 0 OR hor_fimopbol > 23  THEN
                        DO:
                            ASSIGN glb_cdcritic = 687.
                            RUN fontes/critic.p.
                            ASSIGN glb_cdcritic = 0.
        
                            BELL.
                            MESSAGE glb_dscritic.
                                
                            NEXT-PROMPT hor_fimopbol WITH FRAME f_dados_vrboleto.
                            NEXT.
                        END.
            
                    IF  min_fimopbol < 0 OR min_fimopbol > 59  THEN
                        DO:
                            ASSIGN glb_cdcritic = 687.
                            RUN fontes/critic.p.
                            ASSIGN glb_cdcritic = 0.
        
                            BELL.
                            MESSAGE glb_dscritic.
                                
                            NEXT-PROMPT min_fimopbol WITH FRAME f_dados_vrboleto.
                            NEXT.
                        END.
            
                    IF  tel_flgopbol                                   AND
                        ((hor_iniopbol * 3600) + (min_iniopbol * 60))  >= 
                        ((hor_fimopbol * 3600) + (min_fimopbol * 60))  THEN
                        DO:
                            ASSIGN glb_cdcritic = 687.
                            RUN fontes/critic.p.
                            ASSIGN glb_cdcritic = 0.
        
                            BELL.
                            MESSAGE glb_dscritic.
                                
                            NEXT-PROMPT hor_iniopbol WITH FRAME f_dados_vrboleto.
                            NEXT.
                            END.
            
                    IF  aux_cdcooper = 0  THEN
                        UPDATE tel_flgcrise WITH FRAME f_dados_cecred.
            
                    LEAVE.
        
                END. /** Fim do DO WHILE TRUE **/
    
    
                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                    NEXT.
                        
                LEAVE.
    
            END. /** Fim do DO WHILE TRUE **/

            /****** FIM VR BOLETO *******************************/

            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                DO:
                    HIDE FRAME f_dados NO-PAUSE.
                    HIDE FRAME f_dados_cecred NO-PAUSE.
                    HIDE FRAME f_dados_vrboleto NO-PAUSE.
                    NEXT.
                END.

            IF  NOT tel_flgopstr  THEN
                DO:
                    ASSIGN hor_iniopstr = 0
                           min_iniopstr = 0
                           hor_fimopstr = 0
                           min_fimopstr = 0.
            
                    DISPLAY hor_iniopstr min_iniopstr
                            hor_fimopstr min_fimopstr
                            WITH FRAME f_dados.
                END.

            IF  NOT tel_flgoppag  THEN
                DO:
                    ASSIGN hor_inioppag = 0
                           min_inioppag = 0
                           hor_fimoppag = 0
                           min_fimoppag = 0
                           tel_vlmaxpag = 0.
            
                    DISPLAY hor_inioppag min_inioppag
                            hor_fimoppag min_fimoppag
                            tel_vlmaxpag WITH FRAME f_dados.
                END.

            /* Tiago Zerar horarios qdo setar N
            IF  NOT tel_flgopbol  THEN
                DO:
                    ASSIGN hor_iniopbol = 0
                           min_iniopbol = 0
                           hor_fimopbol = 0
                           min_fimopbol = 0.

                    DISPLAY hor_iniopbol min_iniopbol
                            hor_fimopbol min_fimopbol
                            WITH FRAME f_dados_vrboleto.
                END.
            */

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
    
                    HIDE FRAME f_dados NO-PAUSE.
                    HIDE FRAME f_dados_vrboleto NO-PAUSE.
                    HIDE FRAME f_dados_cecred NO-PAUSE.

                    NEXT.
                END.

            MESSAGE "Aguarde...".

            IF  aux_cdcooper <> 0 THEN
                DO:
                    DO aux_contador = 1 TO 10:
                              
                      ASSIGN glb_cdcritic = 0.

                      FIND CURRENT crapcop EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                      IF NOT AVAILABLE crapcop  THEN
                         DO:
                            IF LOCKED crapcop  THEN
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
                              ASSIGN glb_cdcritic = 651.
                        END.

                      LEAVE.

                    END. /** Fim do DO ... TO **/

                    IF  glb_cdcritic > 0  THEN
                        DO:
                          RUN fontes/critic.p.
                          ASSIGN glb_cdcritic = 0.

                          BELL.
                          MESSAGE glb_dscritic.

                          NEXT.
                        END.

                    ASSIGN crapcop.flgopstr = tel_flgopstr
                           crapcop.flgoppag = tel_flgoppag
                           crapcop.iniopstr = (hor_iniopstr * 3600) + 
                                              (min_iniopstr * 60)
                           crapcop.fimopstr = (hor_fimopstr * 3600) + 
                                              (min_fimopstr * 60)
                           crapcop.inioppag = (hor_inioppag * 3600) + 
                                              (min_inioppag * 60)
                           crapcop.fimoppag = (hor_fimoppag * 3600) + 
                                              (min_fimoppag * 60)
                           crapcop.vlmaxpag = tel_vlmaxpag.

                    IF log_flgopstr <> tel_flgopstr THEN
                       DO:
                          UNIX SILENT
                              VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                              " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                              "Operador " + glb_cdoperad                        +
                              " alterou o campo Operando com SPB-STR de "       +
                              STRING(log_flgopstr,"SIM/NAO") + " para  "        +
                              STRING(tel_flgopstr,"SIM/NAO")                    +
							  " na cooperativa " + crapcop.nmrescop		        + 
                              " >> /usr/coop/cecred/log/tab085.log"). 
                       END.

                    IF log_inihrstr <> hor_iniopstr or
                       log_inimnstr <> min_iniopstr THEN
                       DO: 
                           UNIX SILENT
                            VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                            " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                            "Operador " + glb_cdoperad                        +
                            " alterou o campo Horario inicial para SPB-STR de "          +
                            STRING(log_inihrstr,"99") + ":" + STRING(log_inimnstr,"99") + " para  " +
                            STRING(hor_iniopstr,"99") + ":" + STRING(min_iniopstr,"99") +
                            " na cooperativa " + crapcop.nmrescop		        + 
                            " >> /usr/coop/cecred/log/tab085.log"). 
                       END.

                    IF log_fimhrstr <> hor_fimopstr or
                       log_fimmnstr <> min_fimopstr THEN
                       DO: 
                          UNIX SILENT
                            VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                            " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                            "Operador " + glb_cdoperad                        +
                            " alterou o campo Horario final para SPB-STR de "          +
                            STRING(log_fimhrstr,"99") + ":" + STRING(log_fimmnstr,"99") + " para  " +
                            STRING(hor_fimopstr,"99") + ":" + STRING(min_fimopstr,"99") +
                            " na cooperativa " + crapcop.nmrescop		        + 
                            " >> /usr/coop/cecred/log/tab085.log"). 
                       END.

                    IF log_flgoppag <> tel_flgoppag THEN
                       DO:
                          UNIX SILENT
                            VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                            " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                            "Operador " + glb_cdoperad                        +
                            " alterou o campo Operando com SPB-PAG de "       +
                            STRING(log_flgoppag,"SIM/NAO") + " para  " +
                            STRING(tel_flgoppag,"SIM/NAO") +
                           " na cooperativa " + crapcop.nmrescop		        + 
                            " >> /usr/coop/cecred/log/tab085.log"). 
                       END.

                    IF log_inihrpag <> hor_inioppag or
                       log_inimnpag <> min_inioppag THEN
                       DO: 
                           UNIX SILENT
                            VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                            " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                            "Operador " + glb_cdoperad                        +
                            " alterou o campo Horario inicial para SPB-PAG de "          +
                            STRING(log_inihrpag,"99") + ":" + STRING(log_inimnpag,"99") + " para  " +
                            STRING(hor_inioppag,"99") + ":" + STRING(min_inioppag,"99") +
                            " na cooperativa " + crapcop.nmrescop		        + 
                            " >> /usr/coop/cecred/log/tab085.log"). 
                       END.

                    IF log_fimhrpag <> hor_fimoppag or
                       log_fimmnpag <> min_fimoppag THEN
                       DO: 
                           UNIX SILENT
                            VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                            " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                            "Operador " + glb_cdoperad                        +
                            " alterou o campo Horario final para SPB-PAG de "          +
                            STRING(log_fimhrpag,"99") + ":" + STRING(log_fimmnpag,"99") + " para  " +
                            STRING(hor_fimoppag,"99") + ":" + STRING(min_fimoppag,"99") +
                            " na cooperativa " + crapcop.nmrescop		        + 
                            " >> /usr/coop/cecred/log/tab085.log"). 
                       END.

                    IF log_vlmaxpag <> tel_vlmaxpag THEN
                       DO: 
                          UNIX SILENT
                            VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999")  +
                            " " + STRING(TIME,"HH:MM:SS") + "' --> '"          +
                            "Operador " + glb_cdoperad                         +
                            " alterou o campo Valor maximo de "                +
                            STRING(log_vlmaxpag,"zzzz,zzz,zz9.99") + " para  " +
                            STRING(tel_vlmaxpag,"zzzz,zzz,zz9.99") + " para  " +
                            " na cooperativa " + crapcop.nmrescop		        + 
                            " >> /usr/coop/cecred/log/tab085.log"). 
                       END.

                END.
			      ELSE
            DO:
               FOR EACH crapcop WHERE crapcop.cdcooper <> 3 EXCLUSIVE-LOCK:
                 
				 ASSIGN log_inihrstr = INTE(SUBSTR(STRING(crapcop.iniopstr,"HH:MM"),1,2))
						log_inimnstr = INTE(SUBSTR(STRING(crapcop.iniopstr,"HH:MM"),4,2))
						log_fimhrstr = INTE(SUBSTR(STRING(crapcop.fimopstr,"HH:MM"),1,2))
						log_fimmnstr = INTE(SUBSTR(STRING(crapcop.fimopstr,"HH:MM"),4,2))
						log_inihrpag = INTE(SUBSTR(STRING(crapcop.inioppag,"HH:MM"),1,2))
						log_inimnpag = INTE(SUBSTR(STRING(crapcop.inioppag,"HH:MM"),4,2))
						log_fimhrpag = INTE(SUBSTR(STRING(crapcop.fimoppag,"HH:MM"),1,2))
						log_fimmnpag = INTE(SUBSTR(STRING(crapcop.fimoppag,"HH:MM"),4,2)).

                 IF crapcop.flgopstr <> tel_flgopstr THEN
                    DO:
                       UNIX SILENT
                        VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                        " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                        "Operador " + glb_cdoperad                        +
                        " alterou o campo Operando com SPB-STR de "       +
                        STRING(crapcop.flgopstr,"SIM/NAO") + " para  " +
                        STRING(tel_flgopstr,"SIM/NAO") +
                        " na cooperativa " + crapcop.nmrescop		        + 
                        " >> /usr/coop/cecred/log/tab085.log"). 
                    END.

                 IF log_inihrstr <> hor_iniopstr or
                    log_inimnstr <> min_iniopstr THEN
                    DO: 
                       UNIX SILENT
                        VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                        " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                        "Operador " + glb_cdoperad                        +
                        " alterou o campo Horario inicial para SPB-STR de "          +
                        STRING(log_inihrstr,"99") + ":" + STRING(log_inimnstr,"99") + " para  " +
                        STRING(hor_iniopstr,"99") + ":" + STRING(min_iniopstr,"99") +
                        " na cooperativa " + crapcop.nmrescop		        + 
                        " >> /usr/coop/cecred/log/tab085.log"). 
                    END.

                 IF log_fimhrstr <> hor_fimopstr or
                    log_fimmnstr <> min_fimopstr THEN
                    DO: 
                       UNIX SILENT
                        VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                        " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                        "Operador " + glb_cdoperad                        +
                        " alterou o campo Horario final para SPB-STR de "          +
                        STRING(log_fimhrstr,"99") + ":" + STRING(log_fimmnstr,"99") + " para  " +
                        STRING(hor_fimopstr,"99") + ":" + STRING(min_fimopstr,"99") +
                        " na cooperativa " + crapcop.nmrescop		        + 
                        " >> /usr/coop/cecred/log/tab085.log"). 
                    END.

                 IF crapcop.flgoppag <> tel_flgoppag THEN
                    DO:
                       UNIX SILENT
                        VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                        " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                        "Operador " + glb_cdoperad                        +
                        " alterou o campo Operando com SPB-PAG de "       +
                        STRING(crapcop.flgoppag,"SIM/NAO") + " para  "    +
                        STRING(tel_flgoppag,"SIM/NAO") +
                        " na cooperativa " + crapcop.nmrescop		        + 
                        " >> /usr/coop/cecred/log/tab085.log"). 
                    END.

                 IF log_inihrpag <> hor_inioppag or
                    log_inimnpag <> min_inioppag THEN
                    DO: 
                       UNIX SILENT
                        VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                        " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                        "Operador " + glb_cdoperad                        +
                        " alterou o campo Horario inicial para SPB-PAG de "          +
                        STRING(log_inihrpag,"99") + ":" + STRING(log_inimnpag,"99") + " para  " +
                        STRING(hor_inioppag,"99") + ":" + STRING(min_inioppag,"99") +
                        " na cooperativa " + crapcop.nmrescop		        + 
                        " >> /usr/coop/cecred/log/tab085.log").  
                    END.

                 IF log_fimhrpag <> hor_fimoppag or
                    log_fimmnpag <> min_fimoppag THEN
                    DO: 
                       UNIX SILENT
                        VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                        " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                        "Operador " + glb_cdoperad                        +
                        " alterou o campo Horario final para SPB-PAG de "          +
                        STRING(log_fimhrpag,"99") + ":" + STRING(log_fimmnpag,"99") + " para  " +
                        STRING(hor_fimoppag,"99") + ":" + STRING(min_fimoppag,"99") +
                        " na cooperativa " + crapcop.nmrescop		        + 
                        " >> /usr/coop/cecred/log/tab085.log"). 
                    END.

                 IF log_vlmaxpag <> tel_vlmaxpag THEN
                    DO: 
                       UNIX SILENT
                        VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999")  +
                        " " + STRING(TIME,"HH:MM:SS") + "' --> '"          +
                        "Operador " + glb_cdoperad                         +
                        " alterou o campo Valor maximo de "                +
                        STRING(log_vlmaxpag,"zzzz,zzz,zz9.99") + " para  " +
                        STRING(tel_vlmaxpag,"zzzz,zzz,zz9.99") + " para  " +
                        " na cooperativa " + crapcop.nmrescop		        + 
                        " >> /usr/coop/cecred/log/tab085.log"). 
                    END.

                 ASSIGN crapcop.flgopstr = tel_flgopstr
                        crapcop.flgoppag = tel_flgoppag
                        crapcop.iniopstr = (hor_iniopstr * 3600) + 
                                           (min_iniopstr * 60)
                        crapcop.fimopstr = (hor_fimopstr * 3600) + 
                                           (min_fimopstr * 60)
                        crapcop.inioppag = (hor_inioppag * 3600) + 
                                           (min_inioppag * 60)
                        crapcop.fimoppag = (hor_fimoppag * 3600) + 
                                           (min_fimoppag * 60)
                        crapcop.vlmaxpag = tel_vlmaxpag.
                        
              END.

				    END.

			      IF  aux_cdcooper = 0  THEN
                DO:
                    /***********PAGAMENTO DE VRBOLETO DIA 31/12 *******************************/
                    FOR EACH craptab WHERE craptab.cdcooper <> 3
                                       AND craptab.nmsistem = 'CRED'
                                       AND craptab.tptabela = 'GENERI'
                                       AND craptab.cdempres = 00
                                       AND craptab.cdacesso = 'HRVRBOLETO' NO-LOCK:

                      RUN atualiza_vrboleto(INPUT craptab.cdcooper).
                    END.

                    RUN gera_log_vrboleto (INPUT aux_cdcooper).
                    
                    /***********ESTADO DE CRISE***********************************************/
                    DO aux_contador = 1 TO 10:

                       FIND craptab WHERE 
                            craptab.cdcooper = 0           AND
                            craptab.nmsistem = "CRED"      AND
                            craptab.tptabela = "GENERI"    AND
                            craptab.cdempres = 0           AND
                            craptab.cdacesso = "ESTCRISE"  AND
                            craptab.tpregist = 0
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                       IF NOT AVAILABLE craptab   THEN
                          IF LOCKED craptab   THEN
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
                                
                                ASSIGN aux_dadosusr = "077 - Tabela sendo alterada p/ outro terminal.".
                                
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
                             DO:
                                 CREATE craptab.
                                 ASSIGN craptab.cdcooper = 0
                                        craptab.nmsistem = "CRED"
                                        craptab.tptabela = "GENERI"
                                        craptab.cdempres = 0
                                        craptab.cdacesso = "ESTCRISE"
                                        craptab.tpregist = 0
                                        craptab.dstextab = "N".
    
                                 VALIDATE craptab.
                                 LEAVE.
                             END.    

                        ELSE
                            glb_cdcritic = 0.
    
                        LEAVE.
    
                    END.  /*  Fim do DO .. TO  */

                    IF  glb_cdcritic > 0  THEN
                        DO:
                            RUN fontes/critic.p.
                            ASSIGN glb_cdcritic = 0.

                            BELL.
                            MESSAGE glb_dscritic.

                            NEXT.
                        END.

                    IF  tel_flgcrise  THEN
                        ASSIGN craptab.dstextab = "S".
                    ELSE
                        ASSIGN craptab.dstextab = "N".

					IF log_flgcrise <> tel_flgcrise THEN
                       UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                                         " " + STRING(TIME,"HH:MM:SS") + "' --> '"         +
                                         "Operador " + glb_cdoperad                        +
                                         " alterou o campo Sistema em estado de crise de "       +
                                         STRING(log_flgcrise,"SIM/NAO") + " para  " +
                                         STRING(tel_flgcrise,"SIM/NAO") +
                                         " >> /usr/coop/cecred/log/tab085.log").   

               END.
            ELSE
              DO:
                RUN atualiza_vrboleto(INPUT aux_cdcooper).              
                RUN gera_log_vrboleto(INPUT aux_cdcooper).
              END.
              
            HIDE FRAME f_dados NO-PAUSE.
            HIDE FRAME f_dados_vrboleto NO-PAUSE.
            HIDE FRAME f_dados_cecred NO-PAUSE.
            HIDE MESSAGE NO-PAUSE.
        END.

END. /** Fim do DO WHILE TRUE **/

PROCEDURE pi_carrega_cooperativas:

    DEFINE VARIABLE aux_nmcooper AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE aux_contador AS INTEGER     NO-UNDO.
                        
    FOR EACH crapcop NO-LOCK BY crapcop.cdcooper:

        IF  glb_cdcooper = 3 THEN
                            DO:
                IF glb_cddopcao = "A" AND
                   aux_contador = 0   THEN
                     ASSIGN aux_nmcooper = "TODAS,0,".
        
                IF aux_contador = 0 THEN
                   ASSIGN aux_nmcooper = aux_nmcooper + CAPS(crapcop.nmrescop) + "," +
                                                    STRING(crapcop.cdcooper)
                          aux_contador = 1.
                ELSE
                   ASSIGN aux_nmcooper = aux_nmcooper           + "," + 
                                         CAPS(crapcop.nmrescop) + "," + 
                                         STRING(crapcop.cdcooper).
                                
            END.
        ELSE
            DO:
                IF  crapcop.cdcooper = glb_cdcooper THEN
                                DO:
                        ASSIGN aux_nmcooper = CAPS(crapcop.nmrescop) + "," + 
                                              STRING(crapcop.cdcooper).
                                              
                    END.
                                END.

                                END.

    ASSIGN aux_desccoop = ""
           aux_desccoop:LIST-ITEM-PAIRS IN FRAME f_desccoop = aux_nmcooper.
    ASSIGN aux_cdcooper = INT(aux_desccoop:SCREEN-VALUE IN FRAME f_desccoop)
                      WHEN aux_desccoop:SCREEN-VALUE <> ? .

    RETURN "OK".

END PROCEDURE.

PROCEDURE atualiza_vrboleto:

  DEF INPUT PARAM par_cdcooper AS INTEGER                             NO-UNDO.

                    DO aux_contador = 1 TO 10:

     FIND crabtab WHERE 
          crabtab.cdcooper = par_cdcooper     AND
          crabtab.nmsistem = "CRED"           AND
          crabtab.tptabela = "GENERI"         AND
          crabtab.cdempres = 00               AND
          crabtab.cdacesso = "HRVRBOLETO"
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

     IF   NOT AVAILABLE crabtab   THEN
          IF   LOCKED crabtab   THEN
                                 DO:
                                      RUN sistema/generico/procedures/b1wgen9999.p
			                          PERSISTENT SET h-b1wgen9999.

                  RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crabtab),
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
                                 DO:
                   CREATE crabtab.
                   ASSIGN crabtab.cdcooper = par_cdcooper
                          crabtab.nmsistem = "CRED"
                          crabtab.tptabela = "GENERI"
                          crabtab.cdempres = 00
                          crabtab.cdacesso = "HRVRBOLETO"
                          crabtab.dstextab = "NO;25200;60600;".

                   VALIDATE crabtab.
                                    LEAVE.
                                 END.    
                       ELSE
                            glb_cdcritic = 0.

                       LEAVE.

                    END.  /*  Fim do DO .. TO  */

                    IF  glb_cdcritic > 0  THEN
                        DO:
                            RUN fontes/critic.p.
                            ASSIGN glb_cdcritic = 0.
        
                            BELL.
                            MESSAGE glb_dscritic.
        
                            NEXT.
                        END.

  ASSIGN crabtab.dstextab = UPPER(STRING(tel_flgopbol))       + ";" +
         STRING((hor_iniopbol * 3600) + (min_iniopbol * 60))  + ";" +
         STRING((hor_fimopbol * 3600) + (min_fimopbol * 60))  + ";".
  
  VALIDATE crabtab. 
  FIND CURRENT crabtab NO-LOCK NO-ERROR.
  RELEASE crabtab.

END PROCEDURE.

PROCEDURE gera_log_vrboleto:

  DEF INPUT PARAM par_cdcooper AS INTEGER                             NO-UNDO.

  DEF VAR aux_nmcooper AS CHAR                                        NO-UNDO.

  /***********Realizar log da operacao*******************/   
  IF par_cdcooper = 0 THEN
    ASSIGN aux_nmcooper = "TODAS".
                    ELSE
    FOR FIRST crapcop
        FIELDS (nmrescop)
        WHERE crapcop.cdcooper = par_cdcooper
        NO-LOCK:
        ASSIGN aux_nmcooper = crapcop.nmrescop.
    END.
  
  IF log_flgopbol <> tel_flgopbol THEN
    DO:
        UNIX SILENT
             VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999")    +
             " " + STRING(TIME,"HH:MM:SS") + " - " + aux_nmcooper + 
             "' --> '"                                            +
             "Operador " + glb_cdoperad                           +
             " alterou o campo Pagamento VRBOLETO de "            +
             STRING(log_flgopbol,"SIM/NAO") + " para  " +
             STRING(tel_flgopbol,"SIM/NAO") +
             " >> /usr/coop/cecred/log/tab085.log"). 
    END.

  IF log_inihrbol <> hor_iniopbol or
     log_inimnbol <> min_iniopbol THEN
    DO: 
        UNIX SILENT
             VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999")    +
             " " + STRING(TIME,"HH:MM:SS") + " - " + aux_nmcooper + 
             "' --> '"                                            +
             "Operador " + glb_cdoperad                           +
             " alterou o campo Horario inicial de pagamento VRBOLETO de "          +
             STRING(log_inihrbol,"99") + ":" + STRING(log_inimnbol,"99") + " para  " +
             STRING(hor_iniopbol,"99") + ":" + STRING(min_iniopbol,"99") +
             " >> /usr/coop/cecred/log/tab085.log"). 
                END.

  IF log_fimhrbol <> hor_fimopbol or
     log_fimmnbol <> min_fimopbol THEN
    DO: 
        UNIX SILENT
             VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999")    +
             " " + STRING(TIME,"HH:MM:SS") + " - " + aux_nmcooper + 
             "' --> '"                                            +
             "Operador " + glb_cdoperad                           +
             " alterou o campo Horario final de pagamento VRBOLETO de "          +
             STRING(log_fimhrbol,"99") + ":" + STRING(log_fimmnbol,"99") + " para  " +
             STRING(hor_fimopbol,"99") + ":" + STRING(min_fimopbol,"99") +
             " >> /usr/coop/cecred/log/tab085.log"). 
        END.
  /***********Fim do log ********************************/

END PROCEDURE.


/*............................................................................*/



