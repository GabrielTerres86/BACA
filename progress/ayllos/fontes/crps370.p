/* ..........................................................................

   Programa: Fontes/crps370.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah 
   Data    : Novembro/2003                     Ultima atualizacao: 24/04/2014

   Dados referentes ao programa:

   Frequencia: por solicitacao 69 automatica 
   Objetivo  : Atende a solicitacao 069.
               Processar as solicitacoes de geracao dos debitos de capital para
               Cecrisacred.
               Gera aviso de debito para os planos com debito de COTAS 
               vinculado a FOLHA(crappla.flgpagto = TRUE).

   Alteracoes: 08/06/2004 - Acrescentou 1 centavo no CPMF, diferenca no saldo
                            devedor (Ze Eduardo).

               30/06/2005 - Alimentado campo cdcooper da tabela crapavs (Diego).

               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               17/02/2006 - Unificacao dos bancos - SQLWorks - Eder             

               18/03/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)

               09/04/2008 - Alterado formato do campo "crappla.qtprepag" de
                            "999" para "zz9" e da variavel "rel_qtprepag" de
                            "999" para "zz9" - Kbase IT Solutions -  
                            Paulo Ricardo  Maciel.
                            
               01/09/2008 - Alteracao CDEMPRES (Kbase).
               
               12/09/2011 - Alterado e-mail jcc@cecrisa.com.br para 
                            ama@colorminas.com.br e 
                            paulo.ribeiro@colorminas.com.br (Adriano).
                            
               04/01/2012 - Ajuste para encaminhar os arquivos para os e-mails
                            de acordo com crapemp.dsdemail (Adriano).
                            
               22/08/2013 - Removido geracao do relatorio crrl316. (Fabricio)
               
               23/10/2013 - Tratamento para desconsiderar colaboradores que
                            mudaram de empresa, na leitura da crappla. 
                            (Fabricio)
                            
               11/12/2013 - Efetuada correcao na eliminacao dos avisos de 
                            debitos de cotas (Diego).             
               
               21/01/2014 - Incluir VALIDATE crapavs (Lucas R.)
               
               24/04/2014 - Efetuada correcao na exclusao dos avisos de debito
                            em duplicidade (Diego).
                            
............................................................................. */

DEF STREAM str_1.  /*  Para exportacao/importacao dos debitos  */
DEF STREAM str_3.  /*  Para a opcao de saida como arquivo no formato RHFP  */

{ includes/var_batch.i {1} } 

{ includes/var_cpmf.i } 

DEF   VAR b1wgen0011   AS HANDLE                                     NO-UNDO.

DEF        VAR rel_nrcadast AS INT                                   NO-UNDO.
DEF        VAR rel_nrdconta AS INT                                   NO-UNDO.
DEF        VAR rel_nrdocmto AS INT                                   NO-UNDO.
DEF        VAR rel_cdsecext AS INT                                   NO-UNDO.
DEF        VAR rel_cdagenci AS INT                                   NO-UNDO.
DEF        VAR rel_vlprepla AS DECIMAL                               NO-UNDO.
DEF        VAR rel_qtprepag AS INT                                   NO-UNDO.
DEF        VAR rel_nmprimtl AS CHAR                                  NO-UNDO.

DEF        VAR rel_dtrefere AS INT     FORMAT "99999999"             NO-UNDO.
DEF        VAR rel_dtproces AS INT     FORMAT "99999999"             NO-UNDO.
DEF        VAR rel_nrversao AS INT                                   NO-UNDO.
DEF        VAR rel_nrseqdeb AS INT                                   NO-UNDO.

DEF        VAR rel_dtultdia AS DATE                                  NO-UNDO.

DEF        VAR rel_cddescto AS INT                                   NO-UNDO.
DEF        VAR rel_espvazio AS CHAR    INIT "          "             NO-UNDO.
DEF        VAR rel_nmsistem AS CHAR    INIT "CT"                     NO-UNDO.

DEF        VAR rel_inisipmf AS INT                                   NO-UNDO.

DEF        VAR aux_nmarqdeb AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_intipsai AS CHAR                                  NO-UNDO.

DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgplano AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgarqab AS LOGICAL                               NO-UNDO.

DEF        VAR aux_vlprepla AS DECIMAL FORMAT "99999999999999.99"    NO-UNDO.
DEF        VAR aux_vldacpmf AS DECIMAL                               NO-UNDO.

DEF        VAR aux_dtmvtolt AS DATE                                  NO-UNDO.

ASSIGN glb_cdprogra = "crps370".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

/* Busca dados da cooperativa */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         QUIT.
     END.

{ includes/cpmf.i } 

ASSIGN aux_regexist = FALSE

       rel_dtrefere = INTEGER(STRING(YEAR(glb_dtmvtolt), "9999") +
                              STRING(MONTH(glb_dtmvtolt),"99") +
                              STRING(DAY(glb_dtmvtolt),"99"))

       rel_dtproces = rel_dtrefere

       rel_dtultdia = ((DATE(MONTH(glb_dtmvtolt),28,YEAR(glb_dtmvtolt)) + 4) -
                                   DAY(DATE(MONTH(glb_dtmvtolt),28,
                                            YEAR(glb_dtmvtolt)) + 4)).

FOR EACH crapsol WHERE crapsol.cdcooper = glb_cdcooper  AND
                       crapsol.dtrefere = glb_dtmvtolt  AND
                       crapsol.nrsolici = 69            AND
                       crapsol.insitsol = 1:

    IF   glb_inproces = 1   THEN
         IF   SUBSTRING(crapsol.dsparame,3,1) = "1"   THEN
              NEXT.                                 
                                                           
    ASSIGN glb_cdcritic = 0
           glb_cdempres = 11
           glb_nrdevias = crapsol.nrdevias.

    ASSIGN aux_regexist = TRUE
           aux_flgfirst = TRUE
           aux_flgarqab = FALSE
           aux_flgplano = FALSE

           aux_nmarqdeb = "arq/cot" +
                          STRING(MONTH(glb_dtmvtolt),"99") +
                          STRING(YEAR(glb_dtmvtolt),"9999") + "." +
                          STRING(crapsol.cdempres,"99999")       

           aux_intipsai = SUBSTRING(crapsol.dsparame,1,1)

           rel_nrseqdeb = 0.

    /*  Leitura dos planos  */

    FOR EACH crappla WHERE crappla.cdcooper  = glb_cdcooper         AND
                           crappla.cdempres  = crapsol.cdempres     AND
                           crappla.tpdplano  = 1                    AND
                           crappla.dtinipla <= glb_dtmvtolt         AND
                           crappla.cdsitpla  = 1                    AND
                           crappla.qtprepag <= crappla.qtpremax     AND
                           crappla.flgpagto  = TRUE               
                           USE-INDEX crappla2 NO-LOCK:

        IF   aux_flgfirst   THEN
             DO:
                 ASSIGN aux_flgplano = TRUE
                        aux_flgfirst = FALSE.

                 OUTPUT STREAM str_1 TO arq/crps370.tmp.  /* Gera temporario */
             END.

       /*  FIND crapass OF crappla NO-LOCK NO-ERROR. */
       FIND crapass WHERE crapass.cdcooper = glb_cdcooper       AND
                          crapass.nrdconta = crappla.nrdconta   
                          NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE crapass   THEN
             DO:
                 glb_cdcritic = 251.
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                   " - " + glb_cdprogra + "' --> '" +
                                   glb_dscritic + " CONTA = " +
                                   STRING(crappla.nrdconta,"zzzz,zzz,9") +
                                   " EMPRESA = " + STRING(crapsol.cdempres) +
                                   " >> log/proc_batch.log").
                 LEAVE.  /*  Sai do FOR EACH  */
             END.

        aux_vlprepla = crappla.vlprepla.

        FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper     AND
                           crapttl.nrdconta = crappla.nrdconta AND
                           crapttl.idseqttl = 1 NO-LOCK NO-ERROR.
        
        IF AVAIL crapttl THEN
            /* Desconsiderar colaboradores que mudaram de empresa */
            IF crapttl.cdempres <> crappla.cdempres THEN
                NEXT.

        PUT STREAM str_1
            crapass.nrcadast     FORMAT "99999999"          " "
            crapass.nrdconta     FORMAT "99999999"          " "
            crappla.nrctrpla     FORMAT "999999"            " "
            crapass.cdsecext     FORMAT "9999"              " "
            crapass.cdagenci     FORMAT "999"               " "
            crapass.inisipmf     FORMAT "9"                 " "
            aux_vlprepla         FORMAT "99999999999999.99" " "
            crappla.qtprepag + 1 FORMAT "zz9"               ' "'
            crapass.nmprimtl     FORMAT "x(40)"             '" ' SKIP.

    END.  /*  Fim do FOR EACH -- Leitura dos planos  */

    IF   glb_cdcritic > 0   THEN
         NEXT.          /*  Le a proxima solicitacao  */   
    ELSE
         IF   NOT aux_flgplano   THEN
              NEXT.  /*  Le a proxima solicitacao caso nao tenha planos  */
                                                                   
    PUT STREAM str_1
        "99999999 99999999 999999 9999 999 9 99999999999999,99 999 " +
        FILL("X",40) FORMAT "x(40)" SKIP.

    OUTPUT STREAM str_1 CLOSE.   /*  Fecha o arquivo temporario  */

    IF   CAN-DO("3,5",aux_intipsai)   THEN
         UNIX SILENT VALUE("sort +0.0 -0.9 -o arq/crps370.tmp arq/crps370.tmp").

    aux_flgfirst = TRUE.

    /*  Leitura do cadastro da empresa  */

    /* FIND crapemp OF crapsol NO-LOCK NO-ERROR. */
    FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper      AND
                       crapemp.cdempres = crapsol.cdempres  
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapemp   THEN
         DO:
             glb_cdcritic = 40.
             RUN fontes/critic.p.
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                               glb_cdprogra + "' --> '" + glb_dscritic +
                               " Empresa: " + STRING(crapsol.cdempres,"99999")
                               + " >> log/proc_batch.log").
             RETURN.
         END.

     IF   crapemp.tpconven = 2 THEN
          DO:
               aux_dtmvtolt = rel_dtultdia.

               DO WHILE TRUE:

                  aux_dtmvtolt = aux_dtmvtolt + 1.

                  IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtmvtolt)))  OR
                       CAN-FIND(crapfer WHERE 
                                crapfer.cdcooper = glb_cdcooper     AND
                                crapfer.dtferiad = aux_dtmvtolt)   THEN
                       NEXT.

                  LEAVE.
               END.  /* DO WHILE TRUE */
          END.
     ELSE
          aux_dtmvtolt = glb_dtmvtolt.

    rel_cddescto = crapemp.cddescto[2].


    INPUT STREAM str_1 FROM arq/crps370.tmp NO-ECHO.

    DO WHILE TRUE ON ERROR UNDO, RETURN:

       SET STREAM str_1
           rel_nrcadast FORMAT "99999999"
           rel_nrdconta FORMAT "99999999"
           rel_nrdocmto FORMAT "999999"
           rel_cdsecext FORMAT "9999"
           rel_cdagenci FORMAT "999"
           rel_inisipmf FORMAT "9"
           rel_vlprepla FORMAT "99999999999999.99"
           rel_qtprepag FORMAT "zz9"
           rel_nmprimtl FORMAT "x(40)".

       IF   rel_nrcadast = 99999999   THEN
            LEAVE.

       rel_nrseqdeb = rel_nrseqdeb + 1.

       IF   CAN-DO("1,4,5",aux_intipsai)  THEN    
            DO:
                IF   aux_flgfirst   THEN  /*  Formato HERING  */
                     DO:
                         OUTPUT STREAM str_3 TO VALUE(aux_nmarqdeb).

                         aux_flgarqab = TRUE.

                         PUT STREAM str_3 "DEBIT"
                             crapemp.sgempres FORMAT "x"
                             rel_dtproces     FORMAT "99999999"
                             rel_dtrefere     FORMAT "99999999"
                             rel_nrversao     FORMAT "999"
                             crapemp.cdempfol FORMAT "99999"
                             FILL(" ",61)     FORMAT "x(61)" SKIP.
                     END.
                
                /*
                IF   rel_inisipmf = 1 THEN
                     aux_vldacpmf = ROUND(rel_vlprepla * tab_txcpmfcc,2) + 0.01.
                ELSE
                     aux_vldacpmf = 0.
                */
                PUT STREAM str_3
                    crapsol.cdempres   FORMAT "99999"      
                    rel_nrcadast       FORMAT "9999999"   /*  7 digitos  */
                    rel_cddescto       FORMAT "999"
                    rel_espvazio       FORMAT "x"
                    rel_dtrefere       FORMAT "99999999"
                    rel_nrseqdeb       FORMAT "99999"
                    rel_espvazio       FORMAT "x"
                    rel_nmsistem       FORMAT "x(2)"
                    (rel_vlprepla + aux_vldacpmf) * 100 
                                       FORMAT "9999999999999999"
                    rel_espvazio       FORMAT "x(1)" 
                    '"' 
                    rel_nmprimtl       FORMAT "x(40)"
                    '"' SKIP.
            END.
       
       IF   (crapemp.tpdebcot = 2 OR crapemp.tpdebcot = 3)   THEN
            DO TRANSACTION ON ERROR UNDO, RETURN:

               DO WHILE TRUE:
           
                   /*  Elimina os avisos criados antes do restart  */

                   /* Quando ocorre alteracao na CADEMP, eh atualizado o 
                     campo crapemp.inavscot = 0 automaticamente. Da maneira
                     que esta na PROCES1, podera ser criada nova solicitacao
                     para este programa. Se o mesmo executar pela segunda
                     vez no mes, devera limpar os avisos de debitos ja criados,
                     pois serao criados novamente. Deve ocorrer apenas um 
                     debito do plano cotas no mes. */
                  FIND crapavs WHERE crapavs.cdcooper = glb_cdcooper     AND
                                     crapavs.dtmvtolt = aux_dtmvtolt     AND
                                     crapavs.cdempres = crapsol.cdempres AND
                                     crapavs.cdagenci = rel_cdagenci     AND
                                     crapavs.cdsecext = rel_cdsecext     AND
                                     crapavs.nrdconta = rel_nrdconta     AND
                                     crapavs.dtdebito = ?                AND
                                     crapavs.cdhistor = 127              AND
                                     crapavs.nrdocmto = rel_nrdocmto
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                
                  IF  AVAIL crapavs  THEN
                      DELETE crapavs.
                  ELSE
                  IF  LOCKED crapavs  THEN
                      DO:
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                      END.
                      
                  LEAVE.

               END. /** Fim do DO WHILE TRUE **/
           
               CREATE crapavs.
               ASSIGN crapavs.dtmvtolt = aux_dtmvtolt
                      crapavs.nrdconta = rel_nrdconta
                      crapavs.nrdocmto = rel_nrdocmto
                      crapavs.vllanmto = rel_vlprepla
                      crapavs.cdagenci = rel_cdagenci
                      crapavs.tpdaviso = 1
                      crapavs.cdhistor = 127
                      crapavs.dtdebito = ?
                      crapavs.cdsecext = rel_cdsecext
                      crapavs.cdempres = crapsol.cdempres
                      crapavs.cdempcnv = crapsol.cdempres
                      crapavs.insitavs = 0
                      crapavs.dtrefere = rel_dtultdia
                      crapavs.vldebito = 0
                      crapavs.vlestdif = 0
                      crapavs.nrseqdig = 1
                      crapavs.flgproce = false
                      crapavs.cdcooper = glb_cdcooper.
               VALIDATE crapavs.
            END.

       IF   CAN-DO("2,3,4,5",aux_intipsai)   THEN
            DO:
                IF   aux_flgfirst   THEN
                      aux_flgarqab = TRUE.

                IF   rel_inisipmf = 1  THEN
                    ASSIGN aux_vldacpmf = 
                               ROUND(rel_vlprepla * tab_txcpmfcc,2) + 0.01
                           rel_vlprepla = rel_vlprepla + aux_vldacpmf.
                ELSE
                    ASSIGN aux_vldacpmf = 0.
            END.

       aux_flgfirst = FALSE.

    END.  /*  Fim do DO WHILE TRUE  */

    IF   aux_flgarqab   THEN
         DO:                    
             IF   CAN-DO("1,4,5",aux_intipsai)  THEN
                  DO:
                      PUT STREAM str_3
                      "9 999999 99999999 999999999,99 99             " 
                      "                                           " SKIP.
                      OUTPUT STREAM str_3 CLOSE.

                      /* Move para diretorio converte para utilizar na BO */
                      UNIX SILENT VALUE 
                                  ("cp " + aux_nmarqdeb + " /usr/coop/" +
                                   crapcop.dsdircop + "/converte" + 
                                   " 2> /dev/null").

                      /* envio de email */ 
                      RUN sistema/generico/procedures/b1wgen0011.p
                          PERSISTENT SET b1wgen0011.
             
                      RUN enviar_email IN b1wgen0011
                                (INPUT glb_cdcooper,
                                 INPUT glb_cdprogra,
                                 INPUT crapemp.dsdemail,
                                 INPUT '"Arquivo de desconto de cotas ' +
                                       CAPS(crapcop.nmrescop) + '"', 
                                 INPUT SUBSTRING(aux_nmarqdeb, 5),
                                 INPUT FALSE).
                                   
                      DELETE PROCEDURE b1wgen0011.

                      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                                   " - "                                  +
                                   glb_cdprogra + "' --> '" + "ARQUIVO "  +
                                   "/usr/coop/"                           +
                                   crapcop.dsdircop +  "/"                + 
                                   aux_nmarqdeb + " ENVIADO PARA "        +
                                   crapemp.dsdemail                       +
                                   " >> log/proc_batch.log").

                      UNIX SILENT VALUE("cp " + aux_nmarqdeb + " salvar " +
                                        "2> /dev/null").
                  END.                      

         END.

    INPUT STREAM str_1 CLOSE.

    UNIX SILENT VALUE("rm arq/crps370.tmp 2> /dev/null").  

    DO TRANSACTION ON ERROR UNDO, RETURN:

       crapsol.insitsol = 2. 

       DO WHILE TRUE :

          /* FIND crapemp OF crapsol EXCLUSIVE-LOCK NO-ERROR NO-WAIT. */
          FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper        AND 
                             crapemp.cdempres = crapsol.cdempres
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                             
          IF   NOT AVAILABLE crapemp   THEN
               IF   LOCKED crapemp   THEN
                    DO:
                        PAUSE 2 NO-MESSAGE.
                        NEXT.
                    END.
               ELSE
                    DO:
                        glb_cdcritic = 40.
                        RUN fontes/critic.p.
                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                          " - " + glb_cdprogra +
                                          "' --> '" + glb_dscritic +
                                          " Empresa: " +
                                          STRING(crapsol.cdempres,"99999") +
                                          " >> log/proc_batch.log").
                        RETURN.
                    END.

          crapemp.inavscot = 1.  

          LEAVE.

       END.  /*  Fim do DO WHILE TRUE  */

    END.  /*  Fim da transacao  */  

END.  /*  Fim do FOR EACH  -- Leitura das solicitacoes --  */

IF   NOT aux_regexist   THEN
     DO:
         glb_cdcritic = 157.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" + glb_dscritic +
                           " - SOL069" + " >> log/proc_batch.log").
         RETURN.
     END.

RUN fontes/fimprg.p. 

/* .......................................................................... */

