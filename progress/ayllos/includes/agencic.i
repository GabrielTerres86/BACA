/*..............................................................................

   Programa: Includes/agencic.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Mirtes   
   Data    : Fevereiro/2004                     Ultima Atualizacao: 04/12/2009

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela AGENCI(Cad.agencias)

   Alteracoes: 23/05/2005 - Comentados campos referente Cidade, CNPJ, e
                            Situacao(Ativa)  (Diego).
               
               20/06/2007 - Retirado Comentarios dos campos referente 
                            Situacao(Ativa) (Guilherme).
                            
               04/12/2009 - Melhorias referente a COMPE - Tarefa 29111 (David).
                             
..............................................................................*/

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    UPDATE tel_cdageban WITH FRAME f_agencia.

    IF  tel_cdageban > 0  THEN
        DO:
            FIND crapagb WHERE crapagb.cddbanco = tel_cddbanco AND
                               crapagb.cdageban = tel_cdageban 
                               NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE crapagb  THEN
                DO:
                    ASSIGN glb_cdcritic = 15.
                    RUN fontes/critic.p.
                    ASSIGN glb_cdcritic = 0.
                      
                    BELL.
                    MESSAGE glb_dscritic.
                      
                    NEXT.
                END.
        END.
                
    LEAVE.

END. /** Fim do DO WHILE TRUE **/

IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
    NEXT.

IF  tel_cddbanco <> 0  AND
    tel_cdageban <> 0  THEN
    DO:
        FIND crapcaf WHERE crapcaf.cdcidade = crapagb.cdcidade 
                           NO-LOCK NO-ERROR.

        ASSIGN tel_dgagenci = crapagb.dgagenci
               tel_nmageban = crapagb.nmageban
               tel_nmcidade = IF  AVAILABLE crapcaf  THEN
                                  crapcaf.nmcidade
                              ELSE
                                  ""
               tel_cdufresd = IF  AVAILABLE crapcaf  THEN
                                  crapcaf.cdufresd
                              ELSE
                                  ""
               tel_cdcompen = IF  AVAILABLE crapcaf  THEN
                                  crapcaf.cdcompen
                              ELSE
                                  0
               tel_cdsitagb = crapagb.cdsitagb.  

        FOR EACH crapfsf WHERE crapfsf.cdcidade = crapagb.cdcidade 
                               NO-LOCK:
                      
            IF  ABS(crapfsf.dtferiad - glb_dtmvtolt) > 365  THEN 
                NEXT.
                       
            CREATE cratfsf.
            ASSIGN cratfsf.dtferiad = crapfsf.dtferiad.

        END.
        
        DISPLAY tel_dgagenci tel_nmageban tel_nmcidade tel_cdufresd 
                tel_cdsitagb tel_cdcompen WITH FRAME f_agencia.

        OPEN QUERY q-feriado 
             FOR EACH cratfsf NO-LOCK BY cratfsf.dtferiad.
                      
        IF  NUM-RESULTS("q-feriado") > 0  THEN
            DO:
                PAUSE(0).

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    UPDATE b-feriado WITH FRAME f_feriado.
                    LEAVE.

                END. /** Fim do DO WHILE TRUE **/

                HIDE FRAME f_feriado NO-PAUSE.
            END.
        
        CLOSE QUERY q-feriado.
    END.
ELSE
    DO:
        DISPLAY "" @ tel_cddbanco
                "" @ tel_nmextbcc
                WITH FRAME f_banco.

        DISPLAY "" @ tel_cdageban
                "" @ tel_dgagenci
                "" @ tel_cdcompen
                "" @ tel_nmageban
                "" @ tel_nmcidade
                "" @ tel_cdufresd
                "" @ tel_cdsitagb 
                WITH FRAME f_agencia.

        PAUSE(0).

        OPEN QUERY q-agencia 
             FOR EACH crapagb WHERE crapagb.cddbanco >= tel_cddbanco
                                    NO-LOCK BY crapagb.cddbanco
                                               BY crapagb.cdageban.
              
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
            UPDATE b-agencia WITH FRAME f_agencic.
            LEAVE.

        END. /** Fim do DO WHILE TRUE **/

        CLOSE QUERY q-agencia.

        HIDE FRAME f_agencic NO-PAUSE.
    END.
  
/*............................................................................*/
