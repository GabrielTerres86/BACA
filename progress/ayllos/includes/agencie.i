/*..............................................................................

   Programa: Includes/agencie.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes  
   Data    : Fevereiro/2004                    Ultima Atualizacao: 22/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela AGENCI(Cad.Agencias)

   Alteracoes: 23/05/2005 - Comentados campos referente Cidade, CNPJ, e
                            Situacao(Ativa)  (Diego).
                            
               20/06/2007 - Retirado Comentarios dos campos referente 
                            Cidade, CNPJ, e Situacao(Ativa) (Guilherme).
                            
               08/12/2009 - Melhorias referente a COMPE - Tarefa 29111 (David).
               
               22/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
..............................................................................*/

DO WHILE TRUE TRANSACTION ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

    UPDATE tel_cdageban WITH FRAME f_agencia.

    DO aux_contador = 1 TO 10:

        ASSIGN glb_cdcritic = 0.
                
        FIND crapagb WHERE crapagb.cddbanco = tel_cddbanco AND
                           crapagb.cdageban = tel_cdageban
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAILABLE crapagb  THEN
            IF  LOCKED crapagb  THEN
                DO:
                    RUN sistema/generico/procedures/b1wgen9999.p
                    PERSISTENT SET h-b1wgen9999.
                    
                    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crapagb),
                    					 INPUT "banco",
                    					 INPUT "crapagb",
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
                ASSIGN glb_cdcritic = 15.
        
        LEAVE.

    END. /** Fim do DO ... TO **/

    IF  glb_cdcritic > 0  THEN
        DO:
            RUN fontes/critic.p.
            ASSIGN glb_cdcritic = 0.

            BELL.
            MESSAGE glb_dscritic.
            
            UNDO, NEXT.
        END.

    /** Cidade da agencia **/
    FIND crapcaf WHERE crapcaf.cdcidade = crapagb.cdcidade NO-LOCK NO-ERROR.

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

    DISPLAY tel_dgagenci
            tel_nmageban
            tel_cdsitagb
            tel_cdcompen
            tel_nmcidade
            tel_cdufresd
            WITH FRAME f_agencia.

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
            
            UNDO, LEAVE.
        END.

    DELETE crapagb.

    LEAVE.

END. /** Fim do DO TRANSACTION **/

/*............................................................................*/
