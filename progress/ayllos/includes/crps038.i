/* ..........................................................................

   Programa: Includes/crps038.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/94.                         Ultima atualizacao: 03/01/2012

   Dados referentes ao programa:

   Frequencia: Sempre que executado o programa crps038.p ou crps077.p.
   Objetivo  : Gera arquivos de microfilmagem do capital.

   Alteracao : 21/03/95 - Alterado para ajustar o layout para mostrar os
                          lancamentos em  moeda fixa (Odair).

               23/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               23/03/2000 - Tratar arquivos de microfilmagem, transmitindo 
                            para Hering somente arquivos com registros (Odair).
                            
               30/10/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner)  
                          
               14/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               30/10/2008 - Alteracao cdempres (Kbase IT).
               
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               1/12/2010 - (001) Alteração de format para x(50) 
                           Leonardo Américo (Kbase). 
               
               03/01/2012 - Ajuste tamanho nr.documento (David).            
                           
............................................................................ */

    /*  Verifica se o associado teve lancamentos no mes, caso contrario nao
        imprime o extrato  */

    FIND FIRST craplct WHERE craplct.cdcooper  = glb_cdcooper       AND
                             craplct.nrdconta  = crapass.nrdconta   AND
                        YEAR(craplct.dtmvtolt) = YEAR(aux_dtrefere)
                             USE-INDEX craplct2 NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craplct   THEN
         NEXT.

    aux_regexist = TRUE.

    FIND crapcot WHERE crapcot.cdcooper = glb_cdcooper     AND
                       crapcot.nrdconta = crapass.nrdconta NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapcot   THEN
         DO:
             glb_cdcritic = 169.
             RUN fontes/critic.p.
             UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                glb_cdprogra + "' --> '" +
                                glb_dscritic + " >> log/proc_batch.log").
             QUIT.
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

           reg_cabmex02 = " " +
                          STRING(aux_cdempres,"99999")       + "    "  +
                          STRING(crapass.nrdconta,"z,zzz,zzz,9") + "   "   +
                          STRING(crapass.nmprimtl,"x(50)")       + "     " + 
                          "ANO REF. " + STRING(YEAR(aux_dtrefere),"9999") +
                          "                "

           reg_cabmex03 = FILL(" ",11) + "SALDO ANTERIOR: EM VALOR:  " +
                          STRING(crapcot.vlcotext,"zzzzz,zzz,zz9.99-")   +
                          "MFX: " +
                          STRING(crapcot.qtextmfx,"zzz,zzz,zzz,zz9.9999-") +
                          FILL(" ",29)

           reg_cabmex05 = FILL(" ",12) + "SALDO ATUAL: EM VALOR:    " +
                          STRING(crapcot.vlcotant,"zzzzz,zzz,zz9.99-")  +
                          "MFX: " +
                          STRING(crapcot.qtantmfx,"zzz,zzz,zzz,zz9.9999-") +
                          FILL(" ",29).

    IF   aux_flgfirst   THEN
         ASSIGN aux_flgfirst = FALSE
                mex_indsalto = "+".
    ELSE
         IF   aux_contlinh > 77   THEN
              ASSIGN mex_indsalto = "1"
                     aux_contlinh = 0.
         ELSE
              ASSIGN mex_indsalto = "0"
                     aux_contlinh = aux_contlinh + 1.

    { includes/crps038_1.i }    /*  Imprime cabecalho 1 (reg_cabmex01) */

    { includes/crps038_2.i }    /*  Imprime cabecalho 2 (reg_cabmex02) */

    { includes/crps038_3.i }    /*  Imprime cabecalho 3 (reg_cabmex03) */

    { includes/crps038_4.i }    /*  Imprime cabecalho 4 (reg_cabmex04) */

    aux_contlinh = aux_contlinh + 5.

    RELEASE crapcot.

    FOR EACH craplct WHERE craplct.cdcooper  = glb_cdcooper       AND
                           craplct.nrdconta  = crapass.nrdconta   AND
                      YEAR(craplct.dtmvtolt) = YEAR(aux_dtrefere)
                           NO-LOCK USE-INDEX craplct2
                           BREAK BY craplct.nrdconta:

    DO:
        FIND tt-craphis WHERE
             tt-craphis.cdhistor = craplct.cdhistor
             NO-LOCK NO-ERROR.
    
        IF   craplct.nrctrpla > 0   THEN
             DO:
                 FIND crappla WHERE crappla.cdcooper = glb_cdcooper       AND
                                    crappla.nrdconta = craplct.nrdconta   AND
                                    crappla.nrctrpla = craplct.nrctrpla   AND
                                    crappla.tpdplano = 1
                                    NO-LOCK NO-ERROR.

                 IF   NOT AVAILABLE crappla   THEN
                      reg_dtinipla = "".
                 ELSE
                      reg_dtinipla = STRING(crappla.dtinipla,"99/99/9999").

                 reg_nrctrpla = STRING(craplct.nrctrpla,"zzz,zz9").
             END.
        ELSE
             ASSIGN reg_dtinipla = ""
                    reg_nrctrpla = "".

        ASSIGN reg_ddmvtolt = SUBSTRING(STRING(craplct.dtmvtolt,"99/99/99"),1,5)

               reg_dshistor = IF tt-craphis.dshistor = ""
                                 THEN STRING(craplct.cdhistor,"zzz9") + " - "
                                 ELSE STRING(tt-craphis.dshistor)

               reg_nrdocmto = STRING(craplct.nrdocmto,"zzz,zzz,zz9")
               reg_vllanmto = STRING(craplct.vllanmto,"zzzzz,zzz,zz9.99")
               reg_vllanmfx = STRING(craplct.qtlanmfx,"zzz,zzz,zzz,zz9.9999")

               reg_indebcre = IF CAN-DO("66",STRING(craplct.cdhistor))
                                 THEN "*"
                                 ELSE STRING(tt-craphis.indebcre)

               reg_cdagenci = STRING(craplct.cdagenci,"zz9")
               reg_cdbccxlt = STRING(craplct.cdbccxlt,"zz9")
               reg_nrdolote = STRING(craplct.nrdolote,"zzzzz9")

               reg_lindetal = STRING(reg_ddmvtolt,"x(05)") + " "   +
                              STRING(reg_dshistor,"x(20)") + " "   +
                              STRING(reg_nrdocmto,"x(11)") + " "   +
                              STRING(reg_vllanmto,"x(16)") + "  "  +
                              STRING(reg_indebcre,"x(01)") + "   " +
                              STRING(reg_vllanmfx,"x(20)") + " "   +
                              STRING(reg_cdagenci,"x(03)") + " "   +
                              STRING(reg_cdbccxlt,"x(03)") + " "   +
                              STRING(reg_nrdolote,"x(06)") + " "   +
                              STRING(reg_nrctrpla,"x(07)") + " "   +
                              STRING(reg_dtinipla,"x(10)").

        IF   aux_contlinh = 84   THEN
             IF   LAST-OF(craplct.nrdconta)   THEN
                  DO:
                      mex_indsalto = "1".
                      { includes/crps038_1.i }     /* cabecalho 1   */
                      { includes/crps038_2.i }     /* cabecalho 2   */
                      { includes/crps038_4.i }     /* cabecalho 4   */
                      { includes/crps038_7.i }     /* linha detalhe */
                      { includes/crps038_5.i }     /* cabecalho 5   */
                      { includes/crps038_6.i }     /* cabecalho 6   */
                      aux_contlinh = 8.
                      RELEASE craplct.
                      LEAVE.
                  END.
             ELSE
                  DO:
                      mex_indsalto = "1".
                      { includes/crps038_1.i }     /* cabecalho 1   */
                      { includes/crps038_2.i }     /* cabecalho 2   */
                      { includes/crps038_4.i }     /* cabecalho 4   */
                      { includes/crps038_7.i }     /* linha detalhe */
                      aux_contlinh = 5.
                  END.
        ELSE
             IF   LAST-OF(craplct.nrdconta)   THEN
                  DO:
                      { includes/crps038_7.i }             /* linha detalhe */
                      aux_contlinh = aux_contlinh + 1.
                      IF   aux_contlinh = 84   THEN
                           DO:
                               mex_indsalto = "1".
                               { includes/crps038_1.i }    /* cabecalho 1   */
                               { includes/crps038_2.i }    /* cabecalho 2   */
                               { includes/crps038_5.i }    /* cabecalho 5   */
                               { includes/crps038_6.i }    /* cabecalho 6   */
                               aux_contlinh = 5.
                               RELEASE craplct.
                               LEAVE.
                           END.

                      { includes/crps038_5.i }             /* cabecalho 5   */
                      aux_contlinh = aux_contlinh + 1.
                      IF   aux_contlinh > 82   THEN
                           DO:
                               RELEASE craplct.
                               LEAVE.
                           END.

                      { includes/crps038_6.i }             /* cabecalho 6   */
                      aux_contlinh = aux_contlinh + 2.
                      RELEASE craplct.
                      LEAVE.
                  END.
             ELSE
                  DO:
                      { includes/crps038_7.i }            /* linha detalhe */
                      aux_contlinh = aux_contlinh + 1.
                  END.

        RELEASE craplct.

    END.   /*  Fim do DO  */
    END.   /*  Fim do FOR EACH da pesquisa dos lancamentos  */

    RELEASE crapass.

/* .......................................................................... */

