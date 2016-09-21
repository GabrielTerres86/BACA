/* ..........................................................................

   Programa: includes/crps479.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Fabricio
   Data    : Junho/2011                        Ultima atualizacao: 05/12/2013
                                                                          
   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background) ou Tela.
   Objetivo  : Importacao Folha(Holerite de pagamento)
               
   Alteracoes: 31/07/2013 - Alterar email para recebimento de retorno (David).
               
               05/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO)  
............................................................................. */

EMPTY TEMP-TABLE w_retorno.

/* Verifica quais arquivos serao importados */

INPUT STREAM str_2 THROUGH VALUE( "ls " + par_diretori + " 2> /dev/null")
             NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

    SET STREAM str_2 aux_nmarquiv FORMAT "x(60)".
   
    RUN processa_arquivo.
   
    IF   RETURN-VALUE = "NOK"   THEN
    DO:
        /* Limpa a temp-table do arquivo com problema */
        FOR EACH w_retorno WHERE w_retorno.nmarquiv = aux_nmarquiv 
                                                                EXCLUSIVE-LOCK:
            DELETE w_retorno.
        END.
            
        /* Troca o nome para err */
        UNIX SILENT VALUE("mv " + aux_nmarquiv + " integra/err" +
                      SUBSTRING(aux_nmarquiv,9)).
                              
        /* Coloca o erro no LOG do processo */
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")           +
                      " - " + glb_cdprogra + "' --> '"            +
                      "Comprovante de pagamento ja processado - " +
                      "arquivo: " + " integra/err"                +
                      SUBSTRING(aux_nmarquiv,9)                   +
                      " >> log/proc_batch.log").

        NEXT.
    END.
   
    RUN gera_retorno.
   
    /* Move o arquivo importado para o diretorio "salvar" */
    UNIX SILENT VALUE("mv " + aux_nmarquiv + " salvar 2> /dev/null").
END.
  
/* Se teve algum retorno */
IF   aux_lsretarq <> ""   THEN
     DO:
        /* Manda os retornos via e-mail para a empresa DP */
        RUN sistema/generico/procedures/b1wgen0011.p
            PERSISTENT SET h-b1wgen0011.
        
        IF   VALID-HANDLE(h-b1wgen0011)   THEN
             DO:
                 RUN enviar_email IN h-b1wgen0011
                                    (INPUT glb_cdcooper,
                                     INPUT glb_cdprogra,
                                     INPUT "dp@cecred.coop.br," +
                                           "driele@hsprocessamento.com.br",
                                     INPUT "RETORNO COMPROVANTE PAGAMENTO",
                                     INPUT aux_lsretarq,
                                     INPUT TRUE).
                                   
                 DELETE PROCEDURE h-b1wgen0011.
             END.
     
        /* Gera o relatorio com cada um dos arquivos processados */
        OUTPUT STREAM str_1 TO VALUE("rl/crrl449.lst") PAGED PAGE-SIZE 84.

        { includes/cabrel080_1.i }  /*  Monta cabecalho do rel. de aceitos   */

        VIEW STREAM str_1 FRAME f_cabrel080_1.

        FOR EACH w_retorno NO-LOCK BREAK BY w_retorno.nmarquiv:

            IF   FIRST-OF(w_retorno.nmarquiv)   THEN
                 ASSIGN rel_qtderros = 0
                        rel_qtdgeral = 0
                        rel_qtdcerto = 0.
                
            IF   w_retorno.tpregist  = 1   THEN
                 rel_qtderros = rel_qtderros + 1.
         
            IF   LAST-OF(w_retorno.nmarquiv)   THEN
                 DO:
                     ASSIGN rel_qtdgeral = w_retorno.qtheader - 1 /* header */
                            rel_qtdcerto = rel_qtdgeral - rel_qtderros.
                    
                     /* Erro no header do arquivo */
                     IF   rel_qtdgeral = -1   THEN
                          DISPLAY STREAM str_1
                                  w_retorno.nmarquiv +
                                  " - ARQUIVO REJEITADO " @ w_retorno.nmarquiv
                                  "------"                @ rel_qtdgeral
                                  "------"                @ rel_qtdcerto
                                  "------"                @ rel_qtderros
                                  WITH FRAME f_relatorio.
                     ELSE
                          DISPLAY STREAM str_1
                                  w_retorno.nmarquiv
                                  rel_qtdgeral
                                  rel_qtdcerto
                                  rel_qtderros
                                  WITH FRAME f_relatorio.
                     
                     DOWN STREAM str_1 WITH FRAME f_relatorio.
                 END.
        END.

        OUTPUT STREAM str_1 CLOSE.

        ASSIGN glb_nrcopias = 1
               glb_nmformul = "80col"
               glb_nmarqimp = "rl/crrl449.lst".

        RUN fontes/imprim.p.
        /* Fim do relatorio */
        
     END.

PROCEDURE processa_arquivo:

    ASSIGN aux_qtheader = 1
           aux_flgrecus = NO
           aux_nrseqddp = 0
           aux_nrseqmdp = 0
           aux_qtreghol = 0
           aux_qtregarq = 0.

    INPUT STREAM str_1 FROM VALUE(aux_nmarquiv) NO-ECHO.

    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

       IMPORT STREAM str_1 UNFORMATTED aux_dsdlinha.
   
       /* Verifica se ha o caracter "^V" na linha e troca por "-" */
       IF   aux_dsdlinha MATCHES "*" + CHR(22) + "*"   THEN
            DO aux_contador = 1 TO LENGTH(aux_dsdlinha):
               IF   ASC(SUBSTRING(aux_dsdlinha,aux_contador,1)) = 22   THEN
                    SUBSTRING(aux_dsdlinha,aux_contador,1) = "-".
            END.
   
       /* Se deu problema no arquivo, so deixa passar pelo trailler */
       IF   aux_qtheader = 0                     AND
            SUBSTRING(aux_dsdlinha,1,1) <> "9"   THEN
            NEXT.

       RUN cria_retorno.
   
       /* Header do arquivo */
       IF   SUBSTRING(aux_dsdlinha,1,1) = "0"   THEN
            DO:
                /* Verifica a descricao do arquivo */
                IF   SUBSTRING(aux_dsdlinha,2,20) <> "REMESSA HPAG EMPRESA"
                     THEN
                     DO:
                         IF   w_retorno.cddmsgm1 = 0   THEN
                              w_retorno.cddmsgm1 = 906.
                         ELSE
                         IF   w_retorno.cddmsgm2 = 0   THEN
                              w_retorno.cddmsgm2 = 906.
                         ELSE
                         IF   w_retorno.cddmsgm3 = 0   THEN
                              w_retorno.cddmsgm3 = 906.
                     END.
                 
                /* Nao obrigatorio - lote maior que zeros - Mirtes */
                IF   INT(SUBSTRING(aux_dsdlinha,31,9)) >= 0  THEN
                     DO:
                        .
                     END.
                ELSE 
                     DO:
                         IF   w_retorno.cddmsgm1 = 0   THEN
                              w_retorno.cddmsgm1 = 907.
                         ELSE
                         IF   w_retorno.cddmsgm2 = 0   THEN
                              w_retorno.cddmsgm2 = 907.
                         ELSE
                         IF   w_retorno.cddmsgm3 = 0   THEN
                              w_retorno.cddmsgm3 = 907.
                     END.

                /* CNPJ e codigo da empresa */
                ASSIGN aux_nrcgcemp = DEC(SUBSTRING(aux_dsdlinha,40,15))
                       aux_cdempres = INT(SUBSTRING(aux_dsdlinha,22,9)).
                               
                /* Valida o CNPJ da empresa */
                glb_nrcalcul = aux_nrcgcemp.
            
                RUN fontes/cpfcgc.p.
            
                IF   NOT glb_stsnrcal   THEN
                     DO:
                         IF   w_retorno.cddmsgm1 = 0   THEN
                              w_retorno.cddmsgm1 = 917.
                         ELSE
                         IF   w_retorno.cddmsgm2 = 0   THEN
                              w_retorno.cddmsgm2 = 917.
                         ELSE
                         IF   w_retorno.cddmsgm3 = 0   THEN
                              w_retorno.cddmsgm3 = 917.
                     END.
            
                IF   SUBSTRING(aux_dsdlinha,64,5) <> "00777"   THEN
                     DO:
                         IF   w_retorno.cddmsgm1 = 0   THEN
                              w_retorno.cddmsgm1 = 918.
                         ELSE
                         IF   w_retorno.cddmsgm2 = 0   THEN
                              w_retorno.cddmsgm2 = 918.
                         ELSE
                         IF   w_retorno.cddmsgm3 = 0   THEN
                              w_retorno.cddmsgm3 = 918.
                     END.

                IF   w_retorno.cddmsgm1 <> 0   THEN
                     aux_qtheader = 0. /* Nao processara mais os registros */
            END.
       ELSE
       /* Header do comprovante */
       IF   SUBSTRING(aux_dsdlinha,1,1) = "1"   THEN
            DO:
                ASSIGN aux_flgrecus = NO
                       aux_nrseqddp = 0
                       aux_nrseqmdp = 0
                       aux_qtreghol = 0
                       aux_qtregarq = aux_qtregarq + 1.
            
                RUN valida_comprovante (INPUT 1).

                IF   w_retorno.cddmsgm1 <> 0   THEN
                     DO:
                         aux_flgrecus = YES.
                         NEXT.
                     END.

                ASSIGN aux_dtrefere = DATE(INT(SUBSTRING(aux_dsdlinha,6,2)),1,
                                           INT(SUBSTRING(aux_dsdlinha,8,4)))
                                       
                       /* Pega o ultimo dia do mes de referencia */
                       aux_dtrefere = ((DATE(MONTH(aux_dtrefere),28,
                                             YEAR(aux_dtrefere)) + 4) - 
                                        DAY(DATE(MONTH(aux_dtrefere),28,
                                                 YEAR(aux_dtrefere)) + 4)).
                                                 
                DO WHILE TRUE:
                
                   /* Se o comprovante ja foi importado, tenta importar com a
                      referencia do dia anterior */
                   FIND craphdp WHERE
                                craphdp.cdcooper = glb_cdcooper          AND
                                craphdp.nrdconta = 
                                         INT(SUBSTRING(aux_dsdlinha,29,13) +
                                             STRING(INT(SUBSTRING(aux_dsdlinha,
                                                        42,2))))            AND
                                craphdp.idseqttl = aux_idseqttl          AND
                                craphdp.dtrefere = aux_dtrefere          AND
                                craphdp.cddpagto = 
                                         INT(SUBSTRING(aux_dsdlinha,3,3))   AND
                                craphdp.dtmvtolt = glb_dtmvtolt          AND
                                craphdp.tpregist = 1                     AND
                                craphdp.nrsequen = 1
                                NO-LOCK NO-ERROR.
                                   
                   IF   AVAILABLE craphdp  THEN
                        DO:
                            aux_dtrefere = aux_dtrefere - 1.
                            NEXT.
                        END.
                   
                   LEAVE.
                END.
                
                CREATE craphdp.
                ASSIGN craphdp.cdcooper = glb_cdcooper
                       craphdp.cddpagto = INT(SUBSTRING(aux_dsdlinha,3,3))
                       craphdp.cdempres = aux_cdempres
                       craphdp.tprefope = SUBSTRING(aux_dsdlinha,2,1)
                       craphdp.dsfuncao = SUBSTRING(aux_dsdlinha,133,40)

                       craphdp.dtadmiss =
                                      DATE(INT(SUBSTRING(aux_dsdlinha,175,2)),
                                           INT(SUBSTRING(aux_dsdlinha,173,2)),
                                           INT(SUBSTRING(aux_dsdlinha,177,4)))
                       craphdp.dtlibera = aux_dtrefere     
                       
                       /*-Data liberacao igual data referencia  - Mirtes
                       craphdp.dtlibera =   
                                      DATE(INT(SUBSTRING(aux_dsdlinha,14,2)),
                                           INT(SUBSTRING(aux_dsdlinha,12,2)),
                                           INT(SUBSTRING(aux_dsdlinha,16,4)))
                       ----*/
                       
                       craphdp.dtmvtolt = glb_dtmvtolt
                       craphdp.dtrefere = aux_dtrefere
                   
                       craphdp.flgrgatv = IF   craphdp.tprefope = "I"   THEN
                                               YES
                                          ELSE NO
                   
                       craphdp.nmfuncio = SUBSTRING(aux_dsdlinha,91,30)
                       craphdp.nrcgcemp = aux_nrcgcemp
                   
                       craphdp.nrcpfcgc = 
                                      DECIMAL(SUBSTRING(aux_dsdlinha,44,9) +
                                              SUBSTRING(aux_dsdlinha,53,2))
                   
                       craphdp.nrctpfco = SUBSTRING(aux_dsdlinha,82,9)

                       craphdp.nrdconta = INT(SUBSTRING(aux_dsdlinha,29,13) +
                                          STRING(INT(SUBSTRING(aux_dsdlinha,
                                                     42,2))))
                   
                       craphdp.nrdocfco = SUBSTRING(aux_dsdlinha,69,13)
                       craphdp.nrdolote = 0 /* Fixo */
                       craphdp.dsnromat = SUBSTRING(aux_dsdlinha,121,12)
                       craphdp.nrpisfco = SUBSTRING(aux_dsdlinha,55,14)
                       craphdp.nrsequen = 1
                       craphdp.tpregist = 1
                       craphdp.idseqttl = aux_idseqttl
                     
                       aux_flgrgatv     = craphdp.flgrgatv
                       aux_cddpagto     = craphdp.cddpagto
                       aux_nrdconta     = craphdp.nrdconta.

                VALIDATE craphdp.
            END.
       ELSE
       /* Detalhe do comprovante */
       IF   SUBSTRING(aux_dsdlinha,1,1) = "2"   THEN
            DO:
                ASSIGN aux_qtreghol = aux_qtreghol + 1
                       aux_qtregarq = aux_qtregarq + 1.
                       
                IF   aux_flgrecus   THEN
                     NEXT.
                     
                aux_nrseqddp = aux_nrseqddp + 1.       
            
                RUN valida_comprovante (INPUT 2).

                IF   w_retorno.cddmsgm1 <> 0   THEN
                     NEXT.

                CREATE crapddp.
                ASSIGN crapddp.cdcooper = glb_cdcooper
                       crapddp.cddpagto = aux_cddpagto
                       crapddp.dscodlan = SUBSTRING(aux_dsdlinha,2,4)
                       crapddp.dslancto = SUBSTRING(aux_dsdlinha,6,20)
                       crapddp.dtmvtolt = glb_dtmvtolt
                       crapddp.dtrefere = aux_dtrefere
                       crapddp.flgrgatv = aux_flgrgatv
                       crapddp.idlancto = INT(SUBSTRING(aux_dsdlinha,38,1))
                       crapddp.nrdconta = aux_nrdconta
                       crapddp.nrsequen = aux_nrseqddp
                       crapddp.tpregist = 2
                       crapddp.idseqttl = aux_idseqttl
                       crapddp.vllancto = 
                               DEC(SUBSTRING(aux_dsdlinha,26,12)) / 100.
               VALIDATE crapddp.
            END.
       ELSE
       /* Mensagem do comprovante */
       IF   SUBSTRING(aux_dsdlinha,1,1) = "3"   THEN
            DO:
                ASSIGN aux_qtreghol = aux_qtreghol + 1
                       aux_qtregarq = aux_qtregarq + 1.
                       
                IF   aux_flgrecus   THEN
                     NEXT.

                aux_nrseqmdp = aux_nrseqmdp + 1.
            
                RUN valida_comprovante (INPUT 3).
        
                IF   w_retorno.cddmsgm1 <> 0   THEN
                     NEXT.

                CREATE crapmdp.
                ASSIGN crapmdp.cdcooper = glb_cdcooper
                       crapmdp.cddpagto = aux_cddpagto
                       crapmdp.dscomprv = SUBSTRING(aux_dsdlinha,2,40)
                       crapmdp.dtmvtolt = glb_dtmvtolt
                       crapmdp.dtrefere = aux_dtrefere
                       crapmdp.flgrgatv = aux_flgrgatv
                       crapmdp.nrdconta = aux_nrdconta
                       crapmdp.nrsequen = aux_nrseqmdp
                       crapmdp.tpregist = 3
                       crapmdp.idseqttl = aux_idseqttl.
                VALIDATE crapmdp.
            END.
       ELSE
       /* Trailler do comprovante */
       IF   SUBSTRING(aux_dsdlinha,1,1) = "5"   THEN
            DO:
                aux_qtregarq = aux_qtregarq + 1.

                RUN valida_comprovante (INPUT 5).

                IF   w_retorno.cddmsgm1 <> 0   THEN
                     DO:
                         /* Pula para o proximo Header */
                         aux_qtheader = aux_qtheader + 1.
                         NEXT.
                     END.
                 
                /* se nao houve erro no holerite (a nao ser no header do
                   arquivo) nao volta no retorno */
                IF   NOT CAN-FIND(FIRST w_retorno WHERE
                                        w_retorno.nmarquiv = aux_nmarquiv  AND
                                        w_retorno.qtheader = aux_qtheader  AND
                                        w_retorno.cddmsgm1 <> 0            AND
                                        w_retorno.tpregist <> 0
                                        NO-LOCK)                           THEN
                     FOR EACH w_retorno WHERE 
                              w_retorno.nmarquiv  = aux_nmarquiv   AND
                              w_retorno.qtheader  = aux_qtheader   AND
                              w_retorno.tpregist <> 0
                              EXCLUSIVE-LOCK:
                         DELETE w_retorno.
                     END.
                 
                /* Prepara para o proximo Header */
                aux_qtheader = aux_qtheader + 1.
            END.
       ELSE
       /* Trailler do arquivo */
       IF   SUBSTRING(aux_dsdlinha,1,1) = "9"   THEN
            DO:
                /* Header + Trailler */
                aux_qtregarq = aux_qtregarq + 2.
            
                IF   INT(SUBSTRING(aux_dsdlinha,2,5)) <> aux_qtregarq   THEN
                     DO:
                         IF   w_retorno.cddmsgm1 = 0   THEN
                              w_retorno.cddmsgm1 = 916.
                         ELSE
                         IF   w_retorno.cddmsgm2 = 0   THEN
                              w_retorno.cddmsgm2 = 916.
                         ELSE
                         IF   w_retorno.cddmsgm3 = 0   THEN
                              w_retorno.cddmsgm3 = 916.
                     END.
            END.

    END. /* Fim do DO WHILE */

    INPUT STREAM str_1 CLOSE. /* fim da importacao do arquivo */

    RETURN "OK".
    
END PROCEDURE. /* Fim processa_arquivo */


PROCEDURE cria_retorno:

   DEF VAR aux_qttamlin   AS INTEGER                                NO-UNDO.
   
   /* tamanho original de cada tipo de registro */
   aux_qttamlin = IF SUBSTRING(aux_dsdlinha,1,1) = "0" THEN 233
                  ELSE
                  IF SUBSTRING(aux_dsdlinha,1,1) = "1" THEN 233
                  ELSE 236.

   CREATE w_retorno.
   ASSIGN w_retorno.nmarquiv = aux_nmarquiv
          w_retorno.dslinarq = SUBSTRING(aux_dsdlinha,1,aux_qttamlin)
          w_retorno.cddmsgm1 = 0
          w_retorno.cddmsgm2 = 0
          w_retorno.cddmsgm3 = 0
          /* ultimas 5 posicoes da linha */
          w_retorno.nrsequen = INT(SUBSTRING(aux_dsdlinha,
                                             LENGTH(aux_dsdlinha) - 4))
          w_retorno.tpregist = INT(SUBSTRING(aux_dsdlinha,1,1))
          w_retorno.qtheader = aux_qtheader.

END PROCEDURE. /* Fim cria_retorno */


PROCEDURE valida_comprovante:
    
    DEF INPUT PARAM par_tpregist AS INT                             NO-UNDO.
    
    /* Header do comprovante */
    IF   par_tpregist = 1   THEN
         DO:
            IF   SUBSTRING(aux_dsdlinha,2,1) <> "I"   AND
                 SUBSTRING(aux_dsdlinha,2,1) <> "E"   THEN
                 DO:
                     IF   w_retorno.cddmsgm1 = 0   THEN
                          w_retorno.cddmsgm1 = 101.
                     ELSE
                     IF   w_retorno.cddmsgm2 = 0   THEN
                          w_retorno.cddmsgm2 = 101.
                     ELSE
                     IF   w_retorno.cddmsgm3 = 0   THEN
                          w_retorno.cddmsgm3 = 101.
                 END.
            
            IF   INT(SUBSTRING(aux_dsdlinha,3,3)) < 1   OR
                 INT(SUBSTRING(aux_dsdlinha,3,3)) > 5   THEN
                 DO:
                     IF   w_retorno.cddmsgm1 = 0   THEN
                          w_retorno.cddmsgm1 = 103.
                     ELSE
                     IF   w_retorno.cddmsgm2 = 0   THEN
                          w_retorno.cddmsgm2 = 103.
                     ELSE
                     IF   w_retorno.cddmsgm3 = 0   THEN
                          w_retorno.cddmsgm3 = 103.
                 END.
                 
            IF   INT(SUBSTRING(aux_dsdlinha,6,2)) < 1    OR
                 INT(SUBSTRING(aux_dsdlinha,6,2)) > 12   THEN
                 DO:
                     IF   w_retorno.cddmsgm1 = 0   THEN
                          w_retorno.cddmsgm1 = 105.
                     ELSE
                     IF   w_retorno.cddmsgm2 = 0   THEN
                          w_retorno.cddmsgm2 = 105.
                     ELSE
                     IF   w_retorno.cddmsgm3 = 0   THEN
                          w_retorno.cddmsgm3 = 105.
                 END.
                 
            IF   INT(SUBSTRING(aux_dsdlinha,8,4)) < 2003   THEN
                 DO:
                     IF   w_retorno.cddmsgm1 = 0   THEN
                          w_retorno.cddmsgm1 = 106.
                     ELSE
                     IF   w_retorno.cddmsgm2 = 0   THEN
                          w_retorno.cddmsgm2 = 106.
                     ELSE
                     IF   w_retorno.cddmsgm3 = 0   THEN
                          w_retorno.cddmsgm3 = 106.
                 END.
                 
            IF   SUBSTRING(aux_dsdlinha,20,4) <> "0009"   THEN
                 DO:
                     IF   w_retorno.cddmsgm1 = 0   THEN
                          w_retorno.cddmsgm1 = 110.
                     ELSE
                     IF   w_retorno.cddmsgm2 = 0   THEN
                          w_retorno.cddmsgm2 = 110.
                     ELSE
                     IF   w_retorno.cddmsgm3 = 0   THEN
                          w_retorno.cddmsgm3 = 110.
                 END.

            /* Conta e digito juntos */
            FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                               crapass.nrdconta = 
                                       INT(SUBSTRING(aux_dsdlinha,29,13) +
                                       STRING(INT(SUBSTRING(aux_dsdlinha,
                                                  42,2))))
                                       NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapass   THEN
                 DO:
                     IF   w_retorno.cddmsgm1 = 0   THEN
                          w_retorno.cddmsgm1 = 113.
                     ELSE
                     IF   w_retorno.cddmsgm2 = 0   THEN
                          w_retorno.cddmsgm2 = 113.
                     ELSE
                     IF   w_retorno.cddmsgm3 = 0   THEN
                          w_retorno.cddmsgm3 = 113.
                 END.
                 
            /* CPF e digito juntos */
            glb_nrcalcul = DECIMAL(SUBSTRING(aux_dsdlinha,44,9) +
                                   SUBSTRING(aux_dsdlinha,53,2)).
            
            RUN fontes/cpfcgc.p.
            
            IF   NOT glb_stsnrcal   THEN
                 DO:
                     IF   w_retorno.cddmsgm1 = 0   THEN
                          w_retorno.cddmsgm1 = 116.
                     ELSE
                     IF   w_retorno.cddmsgm2 = 0   THEN
                          w_retorno.cddmsgm2 = 116.
                     ELSE
                     IF   w_retorno.cddmsgm3 = 0   THEN
                          w_retorno.cddmsgm3 = 116.
                 END.
                 
            /* Pega o sequencial do titular */
            FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper       AND
                               crapttl.nrdconta = crapass.nrdconta   AND
                               crapttl.nrcpfcgc = glb_nrcalcul
                               NO-LOCK NO-ERROR.
                               
            IF   AVAILABLE crapttl   THEN
                 aux_idseqttl = crapttl.idseqttl.
            ELSE
                 DO:
                     IF   w_retorno.cddmsgm1 = 0   THEN
                          w_retorno.cddmsgm1 = 116.
                     ELSE
                     IF   w_retorno.cddmsgm2 = 0   THEN
                          w_retorno.cddmsgm2 = 116.
                     ELSE
                     IF   w_retorno.cddmsgm3 = 0   THEN
                          w_retorno.cddmsgm3 = 116.
                 END.
                 
            IF   SUBSTRING(aux_dsdlinha,91,30) = ""   THEN
                 DO:
                     IF   w_retorno.cddmsgm1 = 0   THEN
                          w_retorno.cddmsgm1 = 117.
                     ELSE
                     IF   w_retorno.cddmsgm2 = 0   THEN
                          w_retorno.cddmsgm2 = 117.
                     ELSE
                     IF   w_retorno.cddmsgm3 = 0   THEN
                          w_retorno.cddmsgm3 = 117.
                 END.
            
            IF   SUBSTRING(aux_dsdlinha,173,8) = ""   THEN
                 DO:
                     IF   w_retorno.cddmsgm1 = 0   THEN
                          w_retorno.cddmsgm1 = 138.
                     ELSE
                     IF   w_retorno.cddmsgm2 = 0   THEN
                          w_retorno.cddmsgm2 = 138.
                     ELSE
                     IF   w_retorno.cddmsgm3 = 0   THEN
                          w_retorno.cddmsgm3 = 138.
                 END.
                 
         END. /* Fim Header do comprovante */
    ELSE
    /* Detalhe do comprovante */
    IF   par_tpregist = 2   THEN
         DO:
            IF   SUBSTRING(aux_dsdlinha,6,20) = ""   THEN
                 DO:
                     IF   w_retorno.cddmsgm1 = 0   THEN
                          w_retorno.cddmsgm1 = 119.
                     ELSE
                     IF   w_retorno.cddmsgm2 = 0   THEN
                          w_retorno.cddmsgm2 = 119.
                     ELSE
                     IF   w_retorno.cddmsgm3 = 0   THEN
                          w_retorno.cddmsgm3 = 119.
                 END.
                 
            IF   SUBSTRING(aux_dsdlinha,26,12) = ""   THEN
                 DO:
                     IF   w_retorno.cddmsgm1 = 0   THEN
                          w_retorno.cddmsgm1 = 120.
                     ELSE
                     IF   w_retorno.cddmsgm2 = 0   THEN
                          w_retorno.cddmsgm2 = 120.
                     ELSE
                     IF   w_retorno.cddmsgm3 = 0   THEN
                          w_retorno.cddmsgm3 = 120.
                 END.
             
            IF   INT(SUBSTRING(aux_dsdlinha,38,1)) < 1   OR
                 INT(SUBSTRING(aux_dsdlinha,38,1)) > 6   THEN
                 DO:
                     IF   w_retorno.cddmsgm1 = 0   THEN
                          w_retorno.cddmsgm1 = 122.
                     ELSE
                     IF   w_retorno.cddmsgm2 = 0   THEN
                          w_retorno.cddmsgm2 = 122.
                     ELSE
                     IF   w_retorno.cddmsgm3 = 0   THEN
                          w_retorno.cddmsgm3 = 122.
                 END.
         END.
    ELSE
    /* Mensagem do comprovante */
    IF   par_tpregist = 3   THEN
         DO:
            /*--- Nao obrigatorio(Mirtes)
            IF   SUBSTRING(aux_dsdlinha,2,40) = ""   THEN
                 DO:
                     IF   w_retorno.cddmsgm1 = 0   THEN
                          w_retorno.cddmsgm1 = 129.
                     ELSE
                     IF   w_retorno.cddmsgm2 = 0   THEN
                          w_retorno.cddmsgm2 = 129.
                     ELSE
                     IF   w_retorno.cddmsgm3 = 0   THEN
                          w_retorno.cddmsgm3 = 129.
                 END.
            ---*/
         
         END.
    ELSE
    /* Trailler do comprovante */
    IF   par_tpregist = 5   THEN
         DO:

            IF   INT(SUBSTRING(aux_dsdlinha,2,5)) <> aux_qtreghol   THEN
                 DO:
                     IF   w_retorno.cddmsgm1 = 0   THEN
                          w_retorno.cddmsgm1 = 132.
                     ELSE
                     IF   w_retorno.cddmsgm2 = 0   THEN
                          w_retorno.cddmsgm2 = 132.
                     ELSE
                     IF   w_retorno.cddmsgm3 = 0   THEN
                          w_retorno.cddmsgm3 = 132.

                 END.
         END.
         

END PROCEDURE. /* Fim valida_comprovante */

PROCEDURE gera_retorno:

    DEF VAR aux_nmarqret AS CHAR                                    NO-UNDO.
    
    /* O nome do arquivo de retorno eh o mesmo que o de importacao mas com a
       extensao .RET */

    IF INDEX(aux_nmarquiv, "micros") > 0 THEN
    DO:
        ASSIGN aux_nmarqret = SUBSTR(aux_nmarquiv, INDEX(aux_nmarquiv, "/", 9),
                              (LENGTH(aux_nmarquiv) - 
                               INDEX(aux_nmarquiv, "/", 9) - 2)) + "RET"
               aux_nmarqret = "salvar" + aux_nmarqret.
    END.
    ELSE
    DO:
        ASSIGN aux_nmarqret = SUBSTRING(aux_nmarquiv,1,R-INDEX(aux_nmarquiv,".")) +
                        "RET"
               aux_nmarqret = "salvar" + SUBSTRING(aux_nmarqret,8).
    END.
        
    /* Verifica se houve algum erro no arquivo importado */
    IF   CAN-FIND(FIRST w_retorno WHERE w_retorno.nmarquiv = aux_nmarquiv   AND
                                        w_retorno.cddmsgm1 <> 0 NO-LOCK)
         THEN
         aux_flgrecus = YES.
    ELSE
         aux_flgrecus = NO.
    
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqret).

    FOR EACH w_retorno WHERE w_retorno.nmarquiv = aux_nmarquiv NO-LOCK:
    
        /* Saida do header com a mensagem 0 */
        IF   w_retorno.tpregist = 0   THEN
             DO:
                 PUT STREAM str_1 UNFORMATTED
                            w_retorno.dslinarq.
                        
                 /* Verifica se deu erro no Header do arquivo */
                 IF   w_retorno.cddmsgm1 <> 0   THEN
                      PUT STREAM str_1 UNFORMATTED
                          "999".
                 ELSE
                      PUT STREAM str_1 UNFORMATTED
                          aux_flgrecus        FORMAT "001/000".
                          
                 PUT STREAM str_1 UNFORMATTED
                            w_retorno.cddmsgm1  FORMAT "999"
                            w_retorno.cddmsgm2  FORMAT "999"
                            w_retorno.cddmsgm3  FORMAT "999"
                            w_retorno.nrsequen  FORMAT "99999"
                            SKIP.
             END.
        ELSE
        /* Header do comprovante que teve algum erro */
        IF   w_retorno.tpregist = 1   THEN
             PUT STREAM str_1 UNFORMATTED
                        w_retorno.dslinarq
                        "999"
                        w_retorno.cddmsgm1  FORMAT "999"
                        w_retorno.cddmsgm2  FORMAT "999"
                        w_retorno.cddmsgm3  FORMAT "999"
                        w_retorno.nrsequen  FORMAT "99999"
                        SKIP.
        ELSE                    
             /* Registros detalhe */
             PUT STREAM str_1 UNFORMATTED
                        w_retorno.dslinarq
                        w_retorno.cddmsgm1  FORMAT "999"
                        w_retorno.cddmsgm2  FORMAT "999"
                        w_retorno.cddmsgm3  FORMAT "999"
                        w_retorno.nrsequen  FORMAT "99999"
                        SKIP.
    END.     
    
    OUTPUT STREAM str_1 CLOSE.
    
    /* Converte o arquivo para windows */
    RUN sistema/generico/procedures/b1wgen0011.p
        PERSISTENT SET h-b1wgen0011.
        
    IF   VALID-HANDLE(h-b1wgen0011)   THEN
         DO:
             RUN converte_arquivo IN h-b1wgen0011
                                    (INPUT glb_cdcooper,
                                     INPUT aux_nmarqret,
                                     INPUT SUBSTRING(aux_nmarqret,8)).
             
             DELETE PROCEDURE h-b1wgen0011.
         END.
         
    /* Retornos somente se arquivo tiver "_DP" */
    IF   SUBSTRING(aux_nmarqret,8) MATCHES "*_DP*"   THEN
         DO:
            /* lista de retornos que serao enviados via e-mail */
            IF   aux_lsretarq = ""   THEN
                 aux_lsretarq = SUBSTRING(aux_nmarqret,8).
            ELSE
                 aux_lsretarq = aux_lsretarq + ";" + SUBSTRING(aux_nmarqret,8).
         END.

END PROCEDURE. /* Fim gera_retorno */
