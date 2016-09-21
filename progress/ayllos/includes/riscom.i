
/* .............................................................................

   Programa: Includes/riscom.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Felipe Oliveira
   Data    : Dezembro/2014                   Ultima Alteracao: 05/01/2015
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Gerar Arq. dos saldos de emprestimos e financiamentos das contas
               migradas.

   Alteracao :     05/12/2014 - Separar resultados por cooperativa (Felipe)
                   05/01/2015 - Ajuste para filtrar a crapris com a data informada
                            em tela. (James)
   ............................................................................. */ 
    FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapcop THEN
    DO:
        ASSIGN glb_cdcritic = 651.
        RUN fontes/critic.p.
        UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                            " - " + glb_cdprogra + "' --> '" +
                            glb_dscritic + " >> log/proc_batch.log").
        RETURN.
    END.
   

        /* Opcao disponivel apenas para cooperativas que possuem contas migradas */
    IF  glb_cdcooper <> 1   AND
        glb_cdcooper <> 13  AND
        glb_cdcooper <> 16  THEN
        DO:
            MESSAGE "Cooperativa nao possui contas migradas.".
            NEXT.
        END.
    
    IF  tel_dtrefere = ? THEN
        DO:
            MESSAGE "Data de referencia deve ser informada".
            NEXT.
        END.
    
    RUN fontes/confirma.p (INPUT "",
                          OUTPUT aux_confirma).
    
    IF   aux_confirma <> "S"   THEN
         NEXT.    
    
    ASSIGN aux_nmarqdat = "/micros/" + crapcop.dsdircop + "/contab/" /* Caminho do relatorio */
           aux_nmarqsai = "Migracao_" + STRING(MONTH(tel_dtrefere), "99") + "_" + 
                                        STRING(YEAR(tel_dtrefere)) + ".lst" /* Nome do relatorio */
           rel_valr0299 = 0 /* Zera variaveis do relatorio */
           rel_qtde0299 = 0
           rel_jurs0299 = 0
           rel_valr0499 = 0
           rel_qtde0499 = 0
           rel_jurs0499 = 0.
    
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqdat + "temp.lst").

    /* Cabecalho do relatorio */
    DISP STREAM str_1 crapcop.nmrescop
                  tel_dtrefere WITH FRAME f_cab_rel_emp_fin.
           
    FOR EACH craptco 
    FIELDS (   craptco.cdcooper
               craptco.nrdconta
               craptco.cdcopant
               craptco.nrctaant
               craptco.cdageant
               ) WHERE craptco.cdcooper = glb_cdcooper  AND
                       craptco.tpctatrf <> 3 NO-LOCK:

    
   /* Setar aqui a cooperativa anterior e a data de migração */
    CASE craptco.cdcopant:                      
        WHEN 15 THEN
              ASSIGN aux_dtmigrac  = 11/30/2014.
        WHEN 4 THEN
              ASSIGN aux_dtmigrac  = 11/30/2014.
        WHEN 2 THEN
              ASSIGN aux_dtmigrac  = 12/31/2013.
        WHEN 1 THEN
              ASSIGN aux_dtmigrac  = 12/31/2012.

    END CASE.

    
    /* SE A COOPERATIVA FOR IMGRACAO DA ACREDI CONTABILIZAR SOMENTE AGENCIAS SELECIONADAS */
    IF craptco.cdcopant = 2  AND NOT CAN-DO ("2,4,6,7,11",STRING(craptco.cdageant)) THEN
          NEXT.
    
    
    
   
   



    FOR EACH crapris FIELDS(crapris.cdcooper crapris.nrdconta crapris.nrctremp crapris.vldivida crapris.vljura60 crapris.cdmodali ) 
        WHERE  crapris.cdcooper = craptco.cdcooper    AND
               crapris.nrdconta = craptco.nrdconta    AND
               crapris.dtrefere = tel_dtrefere        AND
               crapris.inddocto = 1            AND
               (crapris.cdmodali = 0299         OR  /* Emprestimo    */
                crapris.cdmodali = 0499)        AND  /* Financiamento */
                crapris.cdorigem = 3            /* Emprestimos */ 
        NO-LOCK: 
                


        FIND FIRST crapepr WHERE 
                            crapepr.cdcooper = crapris.cdcooper AND 
                            crapepr.nrdconta = crapris.nrdconta AND
                            crapepr.nrctremp = crapris.nrctremp AND
                            crapepr.dtmvtolt <= aux_dtmigrac NO-LOCK NO-ERROR.

    
        IF  AVAIL crapepr THEN

           DO:
                   
                   IF ( crapris.cdmodali = 0299 ) THEN
                        DO:
                           /*verificar se ja existe o indice totalizador da cooperativa na temp-table*/ 
                           FIND FIRST tt-incorporada WHERE tt-incorporada.cdcooper = craptco.cdcopant NO-LOCK NO-ERROR.
                       
                           IF AVAIL tt-incorporada  THEN
                               DO:
                                  ASSIGN   tt-incorporada.rel_valr0299  =  tt-incorporada.rel_valr0299 + crapris.vldivida
                                           tt-incorporada.rel_jurs0299 =  tt-incorporada.rel_jurs0299 + crapris.vljura60
                                           tt-incorporada.rel_qtde0299 =  tt-incorporada.rel_qtde0299 + 1.
                               END.
                              
                           ELSE
                                 DO:
                                        CREATE tt-incorporada.
                                          ASSIGN tt-incorporada.cdcooper     = craptco.cdcopant
                                                 tt-incorporada.rel_valr0299 = crapris.vldivida
                                                 tt-incorporada.rel_jurs0299 = crapris.vljura60
                                                 tt-incorporada.rel_qtde0299 = 1.
                                 END.
                                  
                          END.

        ELSE
                        
                DO:
              
                   /*verificar se ja existe o indice totalizador da cooperativa na temp-table*/ 
                   FIND FIRST tt-incorporada WHERE tt-incorporada.cdcooper = craptco.cdcopant NO-LOCK NO-ERROR.
               
                       IF AVAIL tt-incorporada  THEN
                               DO:
                                   ASSIGN  tt-incorporada.rel_valr0499  =  tt-incorporada.rel_valr0499 + crapris.vldivida
                                          tt-incorporada.rel_jurs0499 =  tt-incorporada.rel_jurs0499 + crapris.vljura60
                                          tt-incorporada.rel_qtde0499 =  tt-incorporada.rel_qtde0499 + 1.
    
                               END.
                       ELSE
                              DO:
                                   CREATE tt-incorporada.
                                   ASSIGN tt-incorporada.cdcooper     = craptco.cdcopant
                                          tt-incorporada.rel_valr0499 = crapris.vldivida
                                          tt-incorporada.rel_jurs0499 = crapris.vljura60
                                          tt-incorporada.rel_qtde0499 = 1.
                             END.
               END.
           END.

        
           END.



    
END.
                      
FOR EACH tt-incorporada,
    EACH crapcop WHERE crapcop.cdcooper=tt-incorporada.cdcooper:
       
      DISP STREAM str_1 crapcop.nmrescop COLUMN-LABEL "COOPERATIVA".
      DISP STREAM str_1
         tt-incorporada.rel_valr0299 
         tt-incorporada.rel_jurs0299
         tt-incorporada.rel_qtde0299
         tt-incorporada.rel_valr0499 
         tt-incorporada.rel_jurs0499
         tt-incorporada.rel_qtde0499 WITH FRAME f_rel_emp_fin.
     
END.


OUTPUT STREAM str_1 CLOSE.
UNIX SILENT VALUE
     ("ux2dos " + aux_nmarqdat + "temp.lst > " + aux_nmarqdat + aux_nmarqsai). 
     
IF aux_nmarqdat <> "" THEN
    UNIX SILENT VALUE
         ("rm " + aux_nmarqdat + "temp.lst").

DISP (aux_nmarqdat + aux_nmarqsai) @ aux_nmarqsai WITH FRAME f_contabiliza_m.
PAUSE 6 NO-MESSAGE.

