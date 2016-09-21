/*.............................................................................

   Programa: Includes/extapla.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Novembro/2003                   Ultima alteracao: 04/10/2007  

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de lancamentos da tela extapl.

   Alteracoes: 24/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
   
               08/02/2006 - Inclusao de EXCLUSIVE-LOCK em FIND's - SQLWorks -
                            Eder
               
               21/05/2007 - Incluido RDC PRE e POS entre as aplicacoes que
                            podem ser alteradas (Elton).
              
               04/10/2007 - Mostrar data da aplicacao (Guilherme).
               
               22/08/2011 - Adaptado para uso de BO (Gabriel Capoia - DB1).
                            
............................................................................. */
/***
DEF VAR flg_tpemiext AS LOG  NO-UNDO.
DEF VAR aux_tpextrat AS INT  NO-UNDO.
DEF VAR aux_dsextrat AS CHAR NO-UNDO.
***/
NEXT-PROMPT tel_conlacto WITH FRAME f_aplicacao.

INICIO:

DO WHILE TRUE:

    ASSIGN tel_nrsequen = 0
           tel_descapli = ""
           tel_tpaplica = 0
           tel_nraplica = 0
           tel_tpemiext = 0
           tel_dsemiext = "".
    
    RUN Busca_Dados.

    IF  NOT TEMP-TABLE tt-extapl:HAS-RECORDS THEN
        DO:
            LEAVE.
        END.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        HIDE MESSAGE NO-PAUSE.

        CLEAR FRAME f_alterar ALL.
        HIDE FRAME f_alterar NO-PAUSE.

        CLEAR FRAME f_consultar ALL.
        HIDE FRAME f_consultar NO-PAUSE.

        CLEAR FRAME f_manutencao ALL.
        HIDE FRAME f_manutencao NO-PAUSE.

        DISPLAY tel_conlacto tel_altlacto tel_alttodas  
            WITH FRAME f_aplicacao.

        CHOOSE FIELD tel_conlacto tel_altlacto tel_alttodas  
            WITH FRAME f_aplicacao.

        HIDE MESSAGE NO-PAUSE.

        IF  FRAME-VALUE = tel_altlacto  THEN /* Alterar lancamento */
            DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
                HIDE MESSAGE NO-PAUSE.

                OPEN QUERY bworkapla-q FOR EACH tt-extapl.

                ENABLE bworkapla-b btn-alterar btn-sair1 
                    WITH FRAME f_alterar.

                ON  RETURN OF bworkapla-b
                    DO:
                        APPLY "CHOOSE" TO btn-alterar.
                        RETURN NO-APPLY.
                    END.

                ON  CHOOSE OF btn-alterar
                    DO:
                        /*** aqui o registro selecionado ja esta disponivel **/
                        DO WHILE TRUE ON ENDKEY UNDO,LEAVE:

                            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                DO:    
                                    PAUSE(0).
                                    LEAVE.
                                END.
                                
                            ASSIGN tel_nrsequen = tt-extapl.nrsequen
                                   tel_descapli = tt-extapl.descapli
                                   tel_nraplica = tt-extapl.nraplica
                                   tel_tpemiext = tt-extapl.tpemiext
                                   tel_dsemiext = tt-extapl.dsemiext
                                   tel_dtmvtolt = tt-extapl.dtmvtolt.

                            DISPLAY tel_descapli tel_nraplica 
                                    tel_tpemiext tel_dsemiext 
                                    tel_nrsequen tel_dtmvtolt
                                    WITH FRAME f_manutencao.

                            UPDATE tel_tpemiext WITH FRAME f_manutencao.

                            ASSIGN aux_cddopcao = "A"
                                   aux_descapli = tt-extapl.descapli
                                   aux_tpaplica = tt-extapl.tpaplica
                                   aux_nraplica = tt-extapl.nraplica
                                   aux_tpemiext = tel_tpemiext.

                            RUN Valida_Dados.

                            IF  RETURN-VALUE <> "OK" THEN
                                LEAVE.

                            RUN Grava_Dados.

                            CLEAR FRAME f_manutencao all.
                            ASSIGN tel_nrsequen = 0
                                   tel_descapli = ""
                                   tel_nraplica = 0
                                   tel_tpemiext = 0
                                   tel_dsemiext = ""
                                   tel_dtmvtolt = ?.

                            LEAVE.

                        END.

                        RUN Busca_Dados.

                        OPEN QUERY bworkapla-q FOR EACH tt-extapl.

                    END.
                                
                WAIT-FOR CHOOSE OF btn-sair1.

            END.

        IF  FRAME-VALUE = tel_conlacto   THEN /* consultar lancamentos */

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                HIDE MESSAGE NO-PAUSE.

                OPEN QUERY bworkaplc-q FOR EACH  tt-extapl NO-LOCK.
                ENABLE bworkaplc-b WITH FRAME f_consultar.

                WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
            END.

        IF  FRAME-VALUE = tel_alttodas  THEN /* Alterar todas ao mesmo tempo */
            DO WHILE TRUE ON ENDKEY UNDO,LEAVE:
                HIDE MESSAGE NO-PAUSE.

                OPEN QUERY bworkapla-q FOR EACH tt-extapl.

                ENABLE bworkapla-b btn-alterar btn-sair1 
                    WITH FRAME f_alterar.

                ON  RETURN OF bworkapla-b
                    DO:
                        APPLY "CHOOSE" TO btn-alterar.
                        RETURN NO-APPLY.
                    END.

                ON  CHOOSE OF btn-alterar
                    DO:
                        /*** aqui o registro selecionado ja esta disponivel **/
                        DO WHILE TRUE ON ENDKEY UNDO,LEAVE:

                            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                DO:
                                    PAUSE(0).
                                    LEAVE.
                                END.

                            ASSIGN aux_tpemiext = 0
                                   flg_tpemiext = FALSE.

                            MESSAGE COLOR NORMAL 

    "Todas as aplicacoes para impressao tipo (1-Individual,2-Todos,3-Nao imp):"
                                                  UPDATE aux_tpemiext.

                            ASSIGN aux_cddopcao = "T"
                                   aux_descapli = "" 
                                   aux_tpaplica = 0
                                   aux_nraplica = 0.
                            

                            RUN Valida_Dados.

                            IF  RETURN-VALUE <> "OK" THEN
                                NEXT.

                            RUN Grava_Dados.

                            CLEAR FRAME f_manutencao all.
                            ASSIGN tel_nrsequen = 0
                                   tel_descapli = ""
                                   tel_nraplica = 0
                                   tel_tpemiext = 0
                                   tel_dsemiext = ""
                                   tel_dtmvtolt = ?.

                            LEAVE.

                        END.
                        
                        RUN Busca_Dados.
                        OPEN QUERY bworkapla-q FOR EACH tt-extapl.

                    END.

                    WAIT-FOR CHOOSE OF btn-sair1.  

                END.

            END. 

        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
            DO:
                HIDE MESSAGE NO-PAUSE.
                CLEAR FRAME f_aplicacao ALL.
                HIDE FRAME f_aplicacao NO-PAUSE.
                HIDE FRAME f_moldura_extra NO-PAUSE.
                LEAVE.
            END.    
   
END.
/* .......................................................................... */
