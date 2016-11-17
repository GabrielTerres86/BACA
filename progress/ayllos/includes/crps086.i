/* ..........................................................................

   Programa: Includes/crps086.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/94.                       Ultima atualizacao: 21/01/2015

   Dados referentes ao programa:

   Frequencia: Sempre que executado o programa crps086.p.
   Objetivo  : Geracao dos arquivos de microfilmagem.

   Alteracoes: 05/07/94 - Alterado para somente compor o saldos dos emprestimos
                          contratos acima de 31/07/93 e liquidados ate 30/06/94
                          (em Cruzeiros Reais) ou os contratos acima de 30/06/94
                          (em Reais).

               03/03/95 - Alterado para modificar o layout da microficha (Odair)
               26/06/96 - Alterado para modificar o layout da microficha (Odair)
               24/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               30/10/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).
               09/07/2001 - Incluir linha de prejuizo (Margarete).
             
               29/06/2004 - Prever avalistas terceiros(Mirtes) 
               
               15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               23/01/2008 - Pegar somente 9 ultimos numeros do campo nrdocmto
                            da tabela craplem (David).

               01/09/2008 - Alteracao cdempres (Kbase IT).
               
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               21/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714)
                            
............................................................................ */

    
    ASSIGN aux_nmdaval1 = " "
           aux_nmdaval2 = " ".
    /* Avalistas - Terceiros --*/

    FOR EACH crapavt WHERE                                
             crapavt.cdcooper = glb_cdcooper     AND
             crapavt.nrdconta = crapepr.nrdconta AND
             crapavt.nrctremp = crapepr.nrctremp AND
             crapavt.tpctrato = 1 NO-LOCK:

        IF  crapepr.nrctaav1 = 0 AND
            aux_nmdaval1     = " " THEN
            ASSIGN aux_nmdaval1 = STRING(crapavt.nrcpfcgc) + " -  " +
                                         crapavt.nmdaval.
        ELSE   
        IF  crapepr.nrctaav2 = 0 AND
            aux_nmdaval2     = " " THEN
            ASSIGN aux_nmdaval2 = STRING(crapavt.nrcpfcgc) + " -  " +
                                         crapavt.nmdaval.
    END.         
 
    
    /*  Dados do primeiro avalista  */
    IF  crapepr.nrctaav1 <> 0 THEN
        DO:
           FIND crapass WHERE
                crapass.cdcooper = glb_cdcooper      AND
                crapass.nrdconta = crapepr.nrctaav1  NO-ERROR.

           IF   NOT AVAIL crapass   THEN
                aux_nmdaval1 = "NAO CADASTRADO".
           ELSE
                aux_nmdaval1 = crapass.nmprimtl.
        END.
        
     /*  Dados do segundo avalista  */
     IF  crapepr.nrctaav2 <> 0 THEN
         DO:

            FIND crapass WHERE
                 crapass.cdcooper = glb_cdcooper      AND
                 crapass.nrdconta = crapepr.nrctaav2  NO-ERROR.

            IF   NOT AVAILABLE crapass   THEN
                 aux_nmdaval2 = "NAO CADASTRADO".
            ELSE
                 aux_nmdaval2 = crapass.nmprimtl.
         END.

    /*  Dados do titular do emprestimo  */

    /*FIND crapass OF crapepr NO-LOCK NO-ERROR.*/
    FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                       crapass.nrdconta = crapepr.nrdconta
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapass   THEN
         DO:
             glb_cdcritic = 251.
             RUN fontes/critic.p.
             UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                glb_cdprogra + "' --> '" + glb_dscritic +
                                " CONTA = " + STRING(crapepr.nrdconta) +
                                " >> log/proc_batch.log").
             RETURN.
         END.

    IF   crapass.inpessoa = 1   THEN 
         DO:
             FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper       AND
                                crapttl.nrdconta = crapass.nrdconta   AND
                                crapttl.idseqttl = 1 NO-LOCK NO-ERROR.     
            
             IF   AVAIL crapttl  THEN
                  ASSIGN aux_cdempres = crapttl.cdempres.
         END.
    ELSE
         DO:
             FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper  AND
                                crapjur.nrdconta = crapass.nrdconta
                                NO-LOCK NO-ERROR.
                               
             IF   AVAIL crapjur  THEN
                  ASSIGN aux_cdempres = crapjur.cdempres.
         END.
    
    ASSIGN aux_nrdordem = 0

           reg_cabmex02 = STRING(aux_cdempres,"zzzz9")           + "   "   +
                          STRING(crapass.nrdconta,"zzzz,zz9,9")  + "  "    +
                          STRING(crapass.nmprimtl,"x(36)")       + "   "   +
                          STRING(reg_nmmesref,"x(14)")           + FILL(" ",50)

           reg_cabmex05 = " " +
                          STRING(crapepr.nrctremp,"zz,zzz,zz9") + " " +
                          STRING(tab_dslcremp[crapepr.cdlcremp],"x(35)") + " " +
                          STRING(crapepr.nrctaav1,"zzzz,zz9,9") + " - " +
                          STRING(aux_nmdaval1,"x(40)") + "  " +
                          STRING(crapepr.vlpreemp,"zzzzz,zzz,zz9.99") + "     "
                          +
                          STRING(crapepr.qtpreemp,"zz9")

           reg_cabmex08 = "           " +
                          STRING(tab_dsfinemp[crapepr.cdfinemp],"x(35)") + " " +
                          STRING(crapepr.nrctaav2,"zzzz,zz9,9") + " - " +
                          STRING(aux_nmdaval2,"x(40)") + "  " +
                          STRING(crapepr.vljuracu,"zzzzz,zzz,zz9.99") + "     ".

    IF   crapepr.inprejuz = 1   THEN
         ASSIGN reg_cabmex09 = "DATA TRANSF PREJUIZO: " +
                               STRING(crapepr.dtprejuz,"99/99/9999") +
                               "                VALOR TRANSF PREJUIZO: " +
                               STRING(crapepr.vlprejuz,"zzzzz,zzz,zz9.99") +
                               "                JUROS PREJUIZO: " +
                               STRING(crapepr.vljraprj,"zz,zzz,zz9.99").
    ELSE
         ASSIGN reg_cabmex09 = "".
                              
    IF   aux_flgfirst   THEN
         ASSIGN aux_flgfirst = FALSE
                mex_indsalto = "+".
    ELSE
         IF   aux_contlinh > 75   THEN
              ASSIGN mex_indsalto = "1"
                     aux_contlinh = 0.
         ELSE
              ASSIGN mex_indsalto = "0"
                     aux_contlinh = aux_contlinh + 1.

    { includes/crps086_1.i }    /*  Imprime cabecalho 1 (reg_cabmex01) */

    { includes/crps086_2.i }    /*  Imprime cabecalho 2 (reg_cabmex02) */

    { includes/crps086_3.i }    /*  Imprime cabecalho 3 (reg_cabmex03) */

    { includes/crps086_5.i }    /*  Imprime cabecalho 5 (reg_cabmex05) */

    { includes/crps086_8.i }    /*  Imprime cabecalho 8 (reg_cabmex08) */

    IF   crapepr.inprejuz = 1   THEN
         DO:
             { includes/crps086_9.i}
         END.
         
    { includes/crps086_4.i }    /*  Imprime cabecalho 4 (reg_cabmex04) */

    ASSIGN aux_contlinh = aux_contlinh + 8
           aux_vlsdeved = 0.

    RELEASE crapass.

    FOR EACH craplem WHERE craplem.cdcooper = glb_cdcooper       AND
                           craplem.nrdconta = crapepr.nrdconta   AND
                           craplem.nrctremp = crapepr.nrctremp
                           /*USE-INDEX craplem2*/ NO-LOCK
                           BREAK BY craplem.nrdconta
                                    BY STRING(YEAR(craplem.dtmvtolt),"9999") +
                                       STRING(MONTH(craplem.dtmvtolt),"99")
                                       BY craplem.dtmvtolt
                                          BY craplem.cdhistor
                                             BY craplem.nrdocmto:
    DO:
        FIND tt-craphis WHERE 
             tt-craphis.cdhistor = craplem.cdhistor 
             NO-LOCK NO-ERROR.

        ASSIGN reg_dtmvtolt = STRING(craplem.dtmvtolt,"99/99/9999") 
               reg_nrdocmto = STRING(INTE(SUBSTR(STRING(craplem.nrdocmto,
                              "99999999999999"),6,9)),"zzz,zzz,zz9")  
               reg_vllanmto = STRING(craplem.vllanmto,"zzz,zzz,zz9.99")
               reg_cdagenci = STRING(craplem.cdagenci,"zz9")
               reg_cdbccxlt = STRING(craplem.cdbccxlt,"zz9")
               reg_nrdolote = STRING(craplem.nrdolote,"zzzzz9")
               reg_dshistor = STRING(tt-craphis.dshistor,"x(19)")
               reg_indebcre = STRING(tt-craphis.indebcre,"x")
               reg_txjurepr = IF  craplem.txjurepr > 0
                                  THEN  STRING(craplem.txjurepr,"zz9.9999999")
                                  ELSE " "
               reg_dtpagemp = IF  craplem.dtpagemp <> ?
                                  THEN  STRING(craplem.dtpagemp,"99/99/9999")
                                  ELSE " "
               reg_vlpreemp = IF  craplem.vlpreemp > 0 THEN
                                  STRING(craplem.vlpreemp,"zz,zzz,zz9.99")
                                  ELSE " ".

        IF  FIRST-OF(craplem.nrdconta)   AND  
            craplem.cdhistor <> 99       THEN
            ASSIGN aux_vlsdeved = crapepr.vlprejuz.

        IF  (crapepr.dtmvtolt > 07/31/1993   AND
             crapepr.dtultpag < 07/01/1994)  OR
             crapepr.dtmvtolt > 06/30/1994   THEN
             DO:
                 IF   tt-craphis.indebcre = "D"   THEN
                      aux_vlsdeved = aux_vlsdeved + craplem.vllanmto.
                 ELSE
                 IF   tt-craphis.indebcre = "C"   AND
                      craplem.cdhistor <> 349   THEN
                      aux_vlsdeved = aux_vlsdeved - craplem.vllanmto.

                 IF   LAST-OF(STRING(YEAR(craplem.dtmvtolt),"9999") +
                              STRING(MONTH(craplem.dtmvtolt),"99"))   THEN
                      reg_vlsdeved = STRING(aux_vlsdeved,
                                            "zzzz,zzz,zzz,zz9.99-").
                 ELSE
                      reg_vlsdeved = "".
             END.
        ELSE
             reg_vlsdeved = "".

        ASSIGN reg_lindetal = STRING(reg_dtmvtolt,"x(10)") + " " +
                              STRING(reg_dshistor,"x(19)") + " " +
                              STRING(reg_nrdocmto,"x(11)") + " " +
                              STRING(reg_vllanmto,"x(14)") + " " +
                              STRING(reg_indebcre,"x(01)") + " " +
                              STRING(reg_vlsdeved,"x(20)") + " " +
                              STRING(reg_txjurepr,"x(11)") + " " +
                              STRING(reg_dtpagemp,"x(10)") + " " +
                              STRING(reg_vlpreemp,"x(13)") + " " +
                              STRING(reg_cdagenci,"x(03)") + " " +
                              STRING(reg_cdbccxlt,"x(03)") + " " +
                              STRING(reg_nrdolote,"x(06)").

        IF   aux_contlinh = 84   THEN
             IF   LAST-OF(craplem.nrdconta)   THEN
                  DO:
                      mex_indsalto = "1".
                      { includes/crps086_1.i }     /* cabecalho 1   */
                      { includes/crps086_2.i }     /* cabecalho 2   */
                      { includes/crps086_3.i }     /* cabecalho 3   */
                      { includes/crps086_5.i }     /* cabecalho 5   */
                      { includes/crps086_8.i }     /* cabecalho 8   */
                      
                      IF   crapepr.inprejuz = 1   THEN
                           DO:
                               { includes/crps086_9.i}
                           END.
                              
                      { includes/crps086_4.i }     /* cabecalho 4   */
                      { includes/crps086_7.i }     /* linha detalhe */
                      { includes/crps086_6.i }     /* cabecalho 6   */
                      aux_contlinh = 11.
                      RELEASE craplem.
                      LEAVE.
                  END.
             ELSE
                  DO:
                      mex_indsalto = "1".
                      { includes/crps086_1.i }     /* cabecalho 1   */
                      { includes/crps086_2.i }     /* cabecalho 2   */
                      { includes/crps086_3.i }     /* cabecalho 3   */
                      { includes/crps086_5.i }     /* cabecalho 5   */
                      { includes/crps086_8.i }     /* cabecalho 8   */
                                        
                       IF   crapepr.inprejuz = 1   THEN
                           DO:
                               { includes/crps086_9.i}
                           END.
                                                    
                      { includes/crps086_4.i }     /* cabecalho 4   */
                      { includes/crps086_7.i }     /* linha detalhe */
                      aux_contlinh = 9.
                  END.
        ELSE
             IF   LAST-OF(craplem.nrdconta)   THEN
                  DO:
                      { includes/crps086_7.i }             /* linha detalhe */
                      aux_contlinh = aux_contlinh + 1.
                      IF   aux_contlinh = 84   THEN
                           DO:
                               RELEASE craplem.
                               LEAVE.
                           END.
                      ELSE
                      IF  (aux_contlinh + 2) > 84   THEN
                           aux_contlinh = 84.
                      ELSE
                           DO:
                               { includes/crps086_6.i }     /* cabecalho 6   */
                               aux_contlinh = aux_contlinh + 2.
                               RELEASE craplem.
                               LEAVE.
                           END.
                  END.
             ELSE
                  DO:
                      { includes/crps086_7.i }             /* linha detalhe */
                      aux_contlinh = aux_contlinh + 1.
                  END.

        RELEASE craplem.

    END.   /*  Fim do DO  */
    END.   /*  Fim do FOR EACH da pesquisa dos lancamentos  */

/* .......................................................................... */

