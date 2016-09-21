/* .............................................................................

   Programa: includes/gera_co_responsavel.i 
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Agosto/2009                         Ultima atualizacao: 25/04/2014    

   Dados referentes ao programa:

   Frequencia: Diario 
   Objetivo  : Includes para gerar os saldos e emprestimos do co-responsavel
               na impressao da proposta de emprestimo.

   Alteracoes: 24/09/2010 - Incluir campo de Prejuizo e linha de credito
                            (Gabriel)
    
               25/04/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                            posicoes (Tiago/Gielow SD137074).
............................................................................. */

/*  Calcula saldo de emprestimos  */

FOR EACH crapepr WHERE
         crapepr.cdcooper = glb_cdcooper   AND
         crapepr.nrdconta = inc_nrdconta   AND

       ((crapepr.cdcooper = 4       AND  /* Conta 5940 somente contr.abertos */
         crapepr.nrdconta = 5940    AND
         crapepr.inliquid = 0)      OR
       
        (crapepr.cdcooper = 4       AND
         crapepr.nrdconta <> 5940)  OR
          
        (crapepr.cdcooper <> 4))    AND 
       ((crapepr.nrctremp = inc_nrctremp   AND
         inc_nrctremp     > 0)             OR          
         inc_nrctremp     = 0)             NO-LOCK
         BY crapepr.cdlcremp
            BY crapepr.cdfinemp:

    /*  Inicialiazacao das variaves para a rotina de calculo  */

    ASSIGN aux_nrdconta = crapepr.nrdconta
           aux_nrctremp = crapepr.nrctremp
           aux_vlsdeved = crapepr.vlsdeved
           aux_vljuracu = crapepr.vljuracu
           aux_txdjuros = crapepr.txjuremp
           aux_qtprecal = IF crapepr.inliquid = 0
                             THEN crapepr.qtprecal
                             ELSE crapepr.qtpreemp

           aux_dtcalcul = inc_dtcalcul
           
           aux_dtultdia = ((DATE(MONTH(glb_dtmvtolt),28,YEAR(glb_dtmvtolt))
                                 + 4) - DAY(DATE(MONTH(glb_dtmvtolt),28,
                                                  YEAR(glb_dtmvtolt)) + 4)).
    
    { includes/lelem.i }    /*  Rotina para calculo do saldo devedor  */
    
    /*  Verifica se deve deixar saldo provisionado no chq. sal  */
    
    ASSIGN aux_qtprecal = aux_qtprecal + IF crapepr.inliquid = 0
                                            THEN lem_qtprecal
                                            ELSE 0
           aux_qtpreapg = IF crapepr.qtpreemp < aux_qtprecal
                          THEN 0
                          ELSE crapepr.qtpreemp - aux_qtprecal.


    FIND crawepr WHERE crawepr.cdcooper = glb_cdcooper        AND
                       crawepr.nrdconta = crapepr.nrdconta    AND
                       crawepr.nrctremp = crapepr.nrctremp    NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crawepr   THEN
         ASSIGN  aux_dtinipag = crapepr.dtdpagto.
    ELSE
         ASSIGN  aux_dtinipag = crawepr.dtdpagto.

    /*  Magui em 18/11/2008 ***/
    IF  MONTH(crapepr.dtmvtolt) = MONTH(glb_dtmvtolt)   AND
        YEAR(crapepr.dtmvtolt) =  YEAR(glb_dtmvtolt)   THEN
        ASSIGN aux_dtinipag = crapepr.dtdpagto.

    
    /*  Leitura da descricao da linha de credito do emprestimo  */

    FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper AND
                       craplcr.cdlcremp = crapepr.cdlcremp
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craplcr   THEN
         aux_dslcremp = STRING(crapepr.cdlcremp,"zzz9") + "-" + "N/CADASTRADA!".
    ELSE
         aux_dslcremp = STRING(craplcr.cdlcremp,"zzz9") + "-" + craplcr.dslcremp.

    /*  Leitura da descricao da finalidade do emprestimo  */

    FIND crapfin WHERE crapfin.cdcooper = glb_cdcooper AND
                       crapfin.cdfinemp = crapepr.cdfinemp
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapfin   THEN
         aux_dsfinemp = STRING(crapepr.cdfinemp,"zz9") + "-" + "N/CADASTRADA!".
    ELSE
         aux_dsfinemp = STRING(crapfin.cdfinemp,"zz9") + "-" + crapfin.dsfinemp.

    
    CREATE w-co-responsavel.

    ASSIGN w-co-responsavel.nrdconta = crapepr.nrdconta
           w-co-responsavel.nrctremp = crapepr.nrctremp
           w-co-responsavel.qtpreemp = crapepr.qtpreemp
           w-co-responsavel.vlemprst = crapepr.vlemprst
           w-co-responsavel.inprejuz = crapepr.inprejuz
           w-co-responsavel.vlsdeved = aux_vlsdeved
           w-co-responsavel.vlpreemp = crapepr.vlpreemp
           w-co-responsavel.vlprepag = aux_vlprepag
           w-co-responsavel.cdlcremp = craplcr.cdlcremp WHEN AVAIL craplcr
           w-co-responsavel.dslcremp = aux_dslcremp
           w-co-responsavel.dsfinemp = aux_dsfinemp.
           
    
    IF   crapepr.flgpagto = FALSE /* Conta */                      THEN
         IF   MONTH(crapepr.dtdpagto) = MONTH(glb_dtmvtolt)        AND 
              YEAR(crapepr.dtdpagto)  = YEAR(glb_dtmvtolt)         THEN
              /*  Ainda nao pagou no mes */
              IF   crapepr.dtdpagto <= glb_dtmvtolt                THEN
                   w-co-responsavel.qtmesdec = crapepr.qtmesdec + 1.
              ELSE
                   w-co-responsavel.qtmesdec = crapepr.qtmesdec.
         ELSE                 
              IF   MONTH(crapepr.dtmvtolt) = MONTH(glb_dtmvtolt)   AND
                   YEAR(crapepr.dtmvtolt)  = YEAR(glb_dtmvtolt)    THEN
                   /* Contrato do mes */
                   IF   MONTH(aux_dtinipag) = MONTH(glb_dtmvtolt)  AND
                        YEAR(aux_dtinipag) = YEAR(glb_dtmvtolt)    THEN
                        /* Devia ter pago a primeira no mes do contrato */
                        w-co-responsavel.qtmesdec = crapepr.qtmesdec + 1.
                   ELSE
                        /* Paga a primeira somente no mes seguinte */
                        w-co-responsavel.qtmesdec = crapepr.qtmesdec. 
              ELSE
                   DO:
                       IF  (crapepr.dtdpagto < glb_dtmvtolt  AND 
                           DAY(crapepr.dtdpagto) <= DAY(glb_dtmvtolt)) 
                       OR  crapepr.dtdpagto > glb_dtmvtolt  THEN    
                           ASSIGN w-co-responsavel.qtmesdec = 
                                                   crapepr.qtmesdec + 1.
                       ELSE
                           
                            ASSIGN w-co-responsavel.qtmesdec = crapepr.qtmesdec.

                   END.
    ELSE
         IF   MONTH(crapepr.dtmvtolt) = MONTH(glb_dtmvtolt)    AND
              YEAR(crapepr.dtmvtolt)  = YEAR(glb_dtmvtolt)     THEN
              /* Contrato do mes - ainda nao atualizou o qtmesdec */
              w-co-responsavel.qtmesdec = crapepr.qtmesdec. 
         ELSE
              DO:
                  ASSIGN aux_dtrefavs = glb_dtmvtolt - DAY(glb_dtmvtolt)
                         aux_flghaavs = FALSE.
                         
                  FOR EACH crapavs WHERE crapavs.cdcooper = glb_cdcooper     AND
                                         crapavs.nrdconta = crapepr.nrdconta AND
                                         crapavs.cdhistor = 108              AND
                                         crapavs.dtrefere = aux_dtrefavs     AND
                                         crapavs.tpdaviso = 1                AND
                                         crapavs.flgproce = FALSE
                                         NO-LOCK:
                
                      aux_flghaavs = TRUE.
                  END.
                                            
                  IF   aux_flghaavs THEN
                       w-co-responsavel.qtmesdec = crapepr.qtmesdec.
                  ELSE
                       w-co-responsavel.qtmesdec = crapepr.qtmesdec + 1.
              END.

    ASSIGN w-co-responsavel.qtmesdec = IF   w-co-responsavel.qtmesdec < 0 THEN
                                            0
                                       ELSE 
                                            w-co-responsavel.qtmesdec
                                                                      
           w-co-responsavel.dspreapg = "   " +
                                       STRING(aux_qtprecal,"-z9.9999") + "/" +
                                       STRING(crapepr.qtpreemp,"zz9") + " ->" +
                                       STRING(aux_qtpreapg,"zz9.9999-").
                                        
    IF   crapepr.qtprecal > crapepr.qtmesdec  AND 
         crapepr.dtdpagto <= glb_dtmvtolt     AND
         crapepr.flgpagto  = FALSE  THEN
       
         DO:                     
             ASSIGN w-co-responsavel.vlpreapg = crapepr.vlpreemp - aux_vlprepag.
               IF   w-co-responsavel.vlpreapg < 0   THEN
                    ASSIGN w-co-responsavel.vlpreapg = 0.
         END.
    ELSE                                  
         ASSIGN w-co-responsavel.vlpreapg = 
                     IF   (w-co-responsavel.qtmesdec - aux_qtprecal) > 0 THEN
                          (w-co-responsavel.qtmesdec - aux_qtprecal) *
                           crapepr.vlpreemp
                     ELSE
                           0. 
                           
    IF    w-co-responsavel.qtmesdec > crapepr.qtpreemp   THEN 
          ASSIGN w-co-responsavel.vlpreapg = aux_vlsdeved.
    ELSE                     
          ASSIGN w-co-responsavel.vlpreapg = 
                             IF   w-co-responsavel.vlpreapg > aux_vlsdeved THEN
                                  aux_vlsdeved
                             ELSE
                                  w-co-responsavel.vlpreapg.

    ASSIGN w-co-responsavel.qtprecal = aux_qtprecal.
                  
    IF   w-co-responsavel.vlpreapg < 0   THEN
         ASSIGN w-co-responsavel.vlpreapg = 0.
         
END.  /*  Fim do FOR EACH  --  Leitura dos contratos de emprestimos  */

/* .......................................................................... */
    
