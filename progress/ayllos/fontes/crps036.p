/* ..........................................................................

   Programa: Fontes/crps036.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/92.                        Ultima atualizacao: 22/04/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 023.
               Processar as solicitacoes de geracao dos debitos de capital.
               Gera aviso de debito para os planos com debito de COTAS 
               vinculado a FOLHA(crappla.flgpagto = TRUE).

   Alteracoes: 05/07/94 - Alterado o literal "cruzeiros reais" e eliminado
                          o valor da URV.

               07/10/94 - Alterado para gerar arquivo de descontos para a
                          empresa 11 no formato da folha RUBI (Edson).

               25/10/94 - Alterado para gerar os descontos com o codigo da verba
                          utilizada na empresa a que se refere (Edson).

               11/01/95 - Alterado para trocar o codigo da empresa 10 para 1
                          na geracao do arquivo (padrao RUBI) para a HERCO
                          (Edson).

               23/01/94 - Incluida a empresa 13 - Associacao no formato RUBI
                          (Deborah).

               04/04/95 - Alterado para registrar no log o aviso para tranmis-
                          sao e gravacao dos arquivos das empresas 1,4,9,20 e
                          99 e copiar os mesmos arquivos para o diretorio salvar
                          (Edson).

               28/04/95 - Alterado para copiar os arquivos gerados para o dire-
                          torio integrar (Edson).

               26/05/95 - Alterado para gerar crapavs para as empresas com
                          tipo de debito igual 2 (Debito em conta) (Edson).

               09/08/95 - Alterado para eliminar a diferenciacao feita na gra-
                          vacao do avs do campo cdsecext para empresa 4 (Odair).

               16/01/96 - Alterado para tratar empresa 9 (Consumo), gravando no
                          formato RUBI com codigo de empresa 1 (Odair).

               11/11/96 - Alterado para selecionar planos com flgpagto = TRUE
                          (Odair).

               24/03/97 - Alterado para incorporar o valor da CPMF a prestacao
                          quando a empresa for LOJAS HERING (Edson).

               16/07/97 - Quando for criar avs verificar tpconven para gerar a
                          crapavs.dtmvtolt (Odair)

               05/08/97 - Na geracao do avs alimentar o campo cdempcnv com
                          crapsol.cdempres (Odair).

               27/08/97 - Alterado para incluir o campo flgproce na criacao
                          do crapavs (Deborah).

               22/01/98 - Alterado para gerar cdsecext para Ceval Jaragua com
                          zeros (Deborah).

               24/03/98 - Cancelada a alteracao anterior (Deborah).

               31/05/1999 - Tratar CPMF (Deborah).

               17/01/2000 - Tratar tpdebcot = 3 (Deborah).

               28/06/2005 - Alimentado campo cdcooper da tabela crapavs                                     (Diego).

               14/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
               
               09/04/2008 - Alterado formato do campo "crappla.qtprepag" e da 
                            variável "rel_qtprepag" de "999" para "zz9" - 
                            Kbase IT Solutions - Paulo Ricardo Maciel.
                             
               01/09/2008 - Alteracao CDEMPRES (Kbase).
               
               22/08/2013 - Removido geracao do relatorio crrl035. (Fabricio)
               
               23/10/2013 - Tratamento para desconsiderar colaboradores que
                            mudaram de empresa, na leitura da crappla. 
                            (Fabricio)
                            
               11/12/2013 - Efetuada correcao na eliminacao dos avisos de 
                            debitos de cotas (Diego).
                            
               14/01/2014 - Inclusao de VALIDATE crapavs (Carlos).    
               
               22/04/2014 - Efetuada correcao na exclusao dos avisos de debito
                            em duplicidade (Diego).         
               
............................................................................. */

DEF STREAM str_1.  /*  Para exportacao/importacao dos debitos  */
DEF STREAM str_3.  /*  Para a opcao de saida como arquivo no formato RHFP  */

{ includes/var_batch.i {1} } 

{ includes/var_cpmf.i } 

DEF        VAR rel_nrcadast AS INT                                   NO-UNDO.
DEF        VAR rel_nrdconta AS INT                                   NO-UNDO.
DEF        VAR rel_nrdocmto AS INT                                   NO-UNDO.
DEF        VAR rel_cdsecext AS INT                                   NO-UNDO.
DEF        VAR rel_cdagenci AS INT                                   NO-UNDO.
DEF        VAR rel_vlprepla AS DECIMAL                               NO-UNDO.
DEF        VAR rel_qtprepag AS INT                                   NO-UNDO.
DEF        VAR rel_nmprimtl AS CHAR                                  NO-UNDO.

DEF        VAR rel_dtrefere AS INT   FORMAT "99999999"               NO-UNDO.
DEF        VAR rel_dtproces AS INT   FORMAT "99999999"               NO-UNDO.
DEF        VAR rel_nrversao AS INT                                   NO-UNDO.
DEF        VAR rel_nrseqdeb AS INT                                   NO-UNDO.

DEF        VAR rel_dtultdia AS DATE                                  NO-UNDO.

DEF        VAR rel_cddescto AS INT     INIT 421                      NO-UNDO.
DEF        VAR rel_cdempres AS INT                                   NO-UNDO.
DEF        VAR rel_espvazio AS CHAR    INIT "          "             NO-UNDO.
DEF        VAR rel_nmsistem AS CHAR    INIT "CT"                     NO-UNDO.

DEF        VAR rel_inisipmf AS INT                                   NO-UNDO.

DEF        VAR con_nrcadast AS INT                                   NO-UNDO.

DEF        VAR aux_nmarqdeb AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_nmarqtrf AS CHAR                                  NO-UNDO.
DEF        VAR aux_intipsai AS CHAR                                  NO-UNDO.

DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgplano AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgarqab AS LOGICAL                               NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_cdcalcul AS INT                                   NO-UNDO.

DEF        VAR aux_tpdebito AS INT     FORMAT "9"                    NO-UNDO.

DEF        VAR aux_vldaurvs AS DECIMAL FORMAT "zz,zz9.99"            NO-UNDO.
DEF        VAR aux_vlprepla AS DECIMAL FORMAT "99999999999999.99"    NO-UNDO.

DEF        VAR aux_dtmvtolt AS DATE                                  NO-UNDO.

ASSIGN glb_cdprogra = "crps036".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

{ includes/cpmf.i } 

ASSIGN aux_regexist = FALSE

       rel_dtrefere = INTEGER(STRING(YEAR(glb_dtmvtolt), "9999") +
                              STRING(MONTH(glb_dtmvtolt),"99") +
                              STRING(DAY(glb_dtmvtolt),"99"))

       rel_dtproces = rel_dtrefere

       rel_dtultdia = ((DATE(MONTH(glb_dtmvtolt),28,YEAR(glb_dtmvtolt)) + 4) -
                                   DAY(DATE(MONTH(glb_dtmvtolt),28,
                                            YEAR(glb_dtmvtolt)) + 4)).

FOR EACH crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND
                       crapsol.dtrefere = glb_dtmvtolt   AND
                       crapsol.nrsolici = 23             AND
                       crapsol.insitsol = 1:
            
    IF   glb_inproces = 1   THEN
         IF   SUBSTRING(crapsol.dsparame,3,1) = "1"   THEN
              NEXT.

    ASSIGN glb_cdcritic = 0.

    ASSIGN aux_regexist = TRUE
           aux_flgfirst = TRUE
           aux_flgarqab = FALSE
           aux_flgplano = FALSE

           aux_nmarqdeb = "arq/cot" +
                          STRING(MONTH(glb_dtmvtolt),"99") +
                          STRING(YEAR(glb_dtmvtolt),"9999") + "." +
                          STRING(crapsol.cdempres,"99999")     

           aux_nmarqtrf = SUBSTRING(aux_nmarqdeb,5,20)

           aux_intipsai = SUBSTRING(crapsol.dsparame,1,1)

           aux_tpdebito = INTEGER(SUBSTRING(crapsol.dsparame,5,1))

           aux_vldaurvs = DECIMAL(SUBSTRING(crapsol.dsparame,7,9))

           aux_cdcalcul = INTEGER(SUBSTRING(crapsol.dsparame,17,3))

           rel_nrseqdeb = 0.

    /*  Leitura dos planos  */
    FOR EACH crappla WHERE crappla.cdcooper = glb_cdcooper       AND
                           crappla.cdempres = crapsol.cdempres   AND
                           crappla.tpdplano = 1                  AND
                           crappla.dtinipla <= glb_dtmvtolt      AND
                           crappla.cdsitpla = 1                  AND
                           crappla.qtprepag <= crappla.qtpremax  AND
                           crappla.flgpagto = TRUE
                           USE-INDEX crappla2 NO-LOCK:
    
        IF   aux_flgfirst   THEN
             DO:
                 ASSIGN aux_flgplano = TRUE
                        aux_flgfirst = FALSE.

                 OUTPUT STREAM str_1 TO arq/crps036.tmp.  /* Gera temporario */
             END.

        /*FIND crapass OF crappla NO-LOCK NO-ERROR.*/
        FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
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

        IF   aux_tpdebito = 1 THEN   /* valor da prestacao em reais */
             aux_vlprepla = crappla.vlprepla.
        ELSE                                   /*  valor da prestacao em URV */
             DO:
                 aux_vlprepla = TRUNCATE(crappla.vlprepla / aux_vldaurvs,2).

                 IF   aux_vlprepla = 0   THEN
                      aux_vlprepla = 0.01.
             END.

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
         UNIX SILENT VALUE("sort +0.0 -0.9 -o arq/crps036.tmp arq/crps036.tmp").

    aux_flgfirst = TRUE.

    /*  Leitura do cadastro da empresa  */

    /* FIND crapemp OF crapsol NO-LOCK NO-ERROR.*/
    FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper AND
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

                  IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtmvtolt))) OR
                       CAN-FIND(crapfer WHERE 
                                crapfer.cdcooper =  glb_cdcooper   AND
                                crapfer.dtferiad =  aux_dtmvtolt)
                            THEN
                       NEXT.

                  LEAVE.
               END.  /* DO WHILE TRUE */
          END.
     ELSE
          aux_dtmvtolt = glb_dtmvtolt.

    IF   crapemp.cddescto[2] = 0   THEN
         rel_cddescto = 421.
    ELSE
         rel_cddescto = crapemp.cddescto[2].


    INPUT STREAM str_1 FROM arq/crps036.tmp NO-ECHO.

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

       IF   crapsol.cdempres = 9   THEN
            con_nrcadast = TRUNCATE((rel_nrcadast - 3100000) / 10,0).

       IF   CAN-DO("1,4,5",aux_intipsai)   AND   
            NOT CAN-DO("2,3",STRING(crapemp.tpdebcot,"9"))   THEN
            IF   CAN-DO("1,4,20,99",STRING(crapsol.cdempres))   THEN
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
                                  crapsol.cdempres FORMAT "99999" 
                                  aux_tpdebito     FORMAT "9"
                                  (aux_vldaurvs * 100)
                                                   FORMAT "9999999"
                                  FILL(" ",16)     FORMAT "x(16)" SKIP.
                          END.

                     PUT STREAM str_3
                         crapsol.cdempres   FORMAT "99999"      
                         rel_nrcadast       FORMAT "9999999"   /*  7 digitos  */
                         rel_cddescto       FORMAT "999"
                         rel_espvazio       FORMAT "x"
                         rel_dtrefere       FORMAT "99999999"
                         rel_nrseqdeb       FORMAT "99999"
                         rel_espvazio       FORMAT "x"
                         rel_nmsistem       FORMAT "x(2)"
                         rel_vlprepla * 100 FORMAT "9999999999999999"
                         rel_espvazio       FORMAT "x(4)" SKIP.
                 END.
            ELSE
            IF   CAN-DO("9,10,11,13",STRING(crapsol.cdempres))   THEN
                 DO:
                     IF   aux_flgfirst   THEN     /*  Formato SENIOR - RUBI  */
                          DO:
                              OUTPUT STREAM str_3 TO VALUE(aux_nmarqdeb).

                              ASSIGN aux_flgarqab = TRUE
                                     rel_cdempres = IF crapsol.cdempres = 10 OR
                                                       crapsol.cdempres =  9
                                                       THEN 1
                                                    ELSE
                                                    IF crapsol.cdempres = 13
                                                       THEN 10
                                                    ELSE crapsol.cdempres.

                              PUT STREAM str_3 "0;FP-EVENTOS" SKIP.
                          END.

                     PUT STREAM str_3 "1;"
                                rel_cdempres       FORMAT "99999" ";"
                                aux_cdcalcul       FORMAT "999" ";"
                                (IF crapsol.cdempres = 9
                                    THEN con_nrcadast
                                    ELSE rel_nrcadast) FORMAT "999999999" ";"
                                rel_cddescto       FORMAT "9999" ";;100;"
                                rel_vlprepla * 100 FORMAT "99999999999" SKIP.
                 END.
            ELSE
                 DO:
                     IF   aux_flgfirst   THEN  /*  Formato CREDITO  */
                          DO:
                              OUTPUT STREAM str_3 TO VALUE(aux_nmarqdeb).

                              aux_flgarqab = TRUE.

                              PUT STREAM str_3
                                  "1"                                 " "
                                  rel_dtultdia     FORMAT "99999999"  " "
                                  crapsol.cdempres FORMAT "99999"     " " 
                                  aux_tpdebito     FORMAT "9"         " "
                                  aux_vldaurvs     FORMAT "99999.99"
                                  FILL(" ",10)     FORMAT "x(10)" SKIP.
                          END.

                     PUT STREAM str_3
                         "0"                                " "
                         rel_nrseqdeb FORMAT "999999"       " "
                         rel_nrdconta FORMAT "99999999"     " "
                         rel_vlprepla FORMAT "999999999.99" " "
                         "62"                               SKIP.
                 END.
       ELSE
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
            IF   aux_flgfirst   THEN
                ASSIGN aux_flgarqab = TRUE.

       ASSIGN aux_flgfirst = FALSE.

    END.  /*  Fim do DO WHILE TRUE  */

    IF   aux_flgarqab   THEN
         DO:
             IF   CAN-DO("1,4,5",aux_intipsai)   AND
                  NOT CAN-DO("2,3",STRING(crapemp.tpdebcot,"9"))  THEN
                  DO:
                      IF   NOT CAN-DO("1,4,9,10,11,13,20,99",
                                      STRING(crapsol.cdempres)) THEN
                           PUT STREAM str_3
                               "9 999999 99999999 999999999,99 99" SKIP.

                      OUTPUT STREAM str_3 CLOSE.

                      IF   CAN-DO("1,20,99",STRING(crapsol.cdempres))   THEN
                           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                             " - " + glb_cdprogra + "' --> '" +
                                             "Transmitir o arquivo " +
                                             aux_nmarqtrf + " '(ap/cccr/'" +
                                             "cotas/" +
                                             STRING(crapsol.cdempres,"99999") +
                                             "')' para a Hering" +
                                             " >> log/proc_batch.log").
                      ELSE
                      IF   crapsol.cdempres = 4    THEN
                           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                             " - " + glb_cdprogra + "' --> '" +
                                             "Gravar fita para a Ceval com o " +
                                             "arquivo " + aux_nmarqtrf +
                                             " >> log/proc_batch.log").
                      ELSE
                      IF   crapsol.cdempres =  9   THEN
                           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                             " - " + glb_cdprogra + "' --> '" +
                                             "Gravar disquete para a CONSUMO " +
                                             "com o arquivo " + aux_nmarqtrf +
                                             " >> log/proc_batch.log").
                      ELSE
                      IF   crapsol.cdempres = 10   THEN
                           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                             " - " + glb_cdprogra + "' --> '" +
                                             "Gravar disquete para a HERCO " +
                                             "com o arquivo " + aux_nmarqtrf +
                                             " >> log/proc_batch.log").
                      ELSE
                      IF   crapsol.cdempres = 13   THEN
                           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                             " - " + glb_cdprogra + "' --> '" +
                                             "Gravar disquete para a ADH com " +
                                             "o arquivo " + aux_nmarqtrf +
                                             " >> log/proc_batch.log").
                      ELSE
                      IF   CAN-DO("5,26,29,31",STRING(crapsol.cdempres)) THEN
                           UNIX SILENT VALUE("cp " + aux_nmarqdeb          +
                                             " integra/c"                  +
                                             STRING(crapsol.cdempres,"99999") +
                                             STRING(rel_dtultdia,"99999999") +
                                             ".05 2> /dev/null").

                      UNIX SILENT VALUE("cp " + aux_nmarqdeb + " salvar " +
                                        "2> /dev/null").
                  END.
         END.

    INPUT STREAM str_1 CLOSE.

    UNIX SILENT VALUE("rm arq/crps036.tmp 2> /dev/null").

    DO TRANSACTION ON ERROR UNDO, RETURN:

       crapsol.insitsol = 2.

       DO WHILE TRUE :

          /*FIND crapemp OF crapsol EXCLUSIVE-LOCK NO-ERROR NO-WAIT.*/
          FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper AND
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
                                               STRING(crapsol.cdempres,"99999")
                                          + " >> log/proc_batch.log").
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
                           " - SOL023" + " >> log/proc_batch.log").
         RETURN.
     END.

RUN fontes/fimprg.p.

/* .......................................................................... */

