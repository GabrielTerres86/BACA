/*..............................................................................

   Programa: Includes/agencii.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes   
   Data    : Fevereiro/2004                    Ultima Atualizacao: 28/02/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela AGENCI(Cad.Agencia)

   Alteracoes: 23/05/2005 - Comentados campos referente Cidade, CNPJ, e
                            Situacao(Ativa)  (Diego).

               16/04/2007 - Atualiza os campos crapagb.dtmvtolt e
                            crapagb.cdoperad quando inclui nova agencia (Elton).

               20/06/2007 - Retirado Comentarios dos campos referente 
                            Situacao(Ativa) (Guilherme).
                            
               08/12/2009 - Melhorias referente a COMPE - Tarefa 29111 (David).
               
               28/02/2014 - Incluso VALIDATE (Daniel).
               
..............................................................................*/

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    UPDATE tel_cdageban WITH FRAME f_agencia.

    IF  tel_cdageban = 0  THEN
        DO:
            ASSIGN glb_cdcritic = 375.
            RUN fontes/critic.p.
            ASSIGN glb_cdcritic = 0.
    
            BELL.
            MESSAGE glb_dscritic.
            
            NEXT.
        END.
    
    FIND crapagb WHERE crapagb.cddbanco = tel_cddbanco AND
                       crapagb.cdageban = tel_cdageban NO-LOCK NO-ERROR.
    
    IF  AVAILABLE crapagb  THEN
        DO:
            ASSIGN glb_cdcritic = 787. 
            RUN fontes/critic.p.
            ASSIGN glb_cdcritic = 0.
    
            BELL.
            MESSAGE glb_dscritic.
            
            NEXT.
        END. 

    LEAVE.

END. /** Fim do DO WHILE TRUE **/

IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
    NEXT.  

DO WHILE TRUE TRANSACTION ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

    UPDATE tel_dgagenci tel_nmageban tel_cdsitagb WITH FRAME f_agencia.
    
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

    CREATE crapagb.
    ASSIGN crapagb.cddbanco = tel_cddbanco
           crapagb.cdageban = tel_cdageban
           crapagb.dgagenci = tel_dgagenci
           crapagb.nmageban = CAPS(tel_nmageban)
           crapagb.cdoperad = glb_cdoperad
           crapagb.dtmvtolt = glb_dtmvtolt
           crapagb.cdsitagb = tel_cdsitagb.  
    VALIDATE crapagb.

    FIND CURRENT crapagb NO-LOCK NO-ERROR.

    LEAVE.
   
END. /** Fim do DO TRANSACTION **/

/*............................................................................*/
