/* ..........................................................................

   Programa: Fontes/crps290.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson        
   Data    : Maio/2000.                      Ultima atualizacao: 30/05/2015

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 5.
               Efetuar os lancamentos automaticos no sistema de cheques em
               custodia e titulos compensaveis.
               Emite relatorio 238.

               Valores para insitlau: 1  ==> a processar
                                      2  ==> processada
                                      3  ==> com erro

   Alteracoes: 23/10/2000 - Desmembrar a critica 95 conforme a situacao do 
                            titular (Eduardo).

               17/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               11/07/2001 - Alterado para adaptar o nome de campo (Edson).

               08/10/2003 - Atualizar craplcm.dtrefere (Margarete). 

               30/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm e craprej (Diego).

               21/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               16/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
               
               02/11/2005 - Uso da procedure digbbx.p para conversao de campo
                            inteiro para caracter (SQLWorks - Andre).
                            
               11/11/2005 - Acertar leitura do crapfdc (Magui).       
                     
               10/12/2005 - Atualizar craprej.nrdctitg (Magui).
                     
               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.       
                 
               13/02/2007 - Alterar consultas com indice crapfdc1 (David).
                 
               07/03/2007 - Ajustes para o Bancoob (Magui).

               04/06/2008 - Campo dsorigem nas leituras da craplau (David)

               17/07/2009 - incluido no for each a condição - 
                            craplau.dsorigem <> "PG555" - Precise - paulo
                            
               02/06/2011 - incluido no for each a condição - 
                            craplau.dsorigem <> "TAA" (Evandro).
                            
               03/10/2011 - Ignorado dsorigem = "CARTAOBB" na leitura da
                            craplau. (Fabricio)
                            
               24/10/2012 - Tratamento para os cheques das contas migradas
                            (Viacredi -> Alto Vale), realizado na procedure 
                            proc_trata_custodia. (Fabricio)
                            
               23/01/2013 - Criar de rejeicao para as criticas 680 e 681 apos
                            leitura da craplot (David).
                            
               03/06/2013 - Incluido no FOR EACH craplau a condicao -
                            craplau.dsorigem <> "BLOQJUD" (Andre Santos - SUPERO)
                            
               20/01/2014 - Efetuada correção na leitura da tabela craptco da 
                            procedure 'proc_trata_custodia' (Diego).           
               
               24/01/2014 - Incluir VALIDATE craplot, craplcm, craprej (Lucas R)
                            Incluido 'RELEASE craptco' para garantir que o 
                            programa nao pegue um registro lido anteriormente.
                            (Fabricio)
                            
               31/03/2014 - incluido nas consultas da craplau
                            craplau.dsorigem <> "DAUT BANCOOB" (Lucas).
                            
               28/09/2015 - Incluido nas consultas da craplau
                            craplau.dsorigem <> "CAIXA" (Lombardi).
                            
               30/05/2016 - Incluir criticas 251, 695, 410, 95 no relatorio e
                            atualizar o insitlau para 3(Cancelado) (Lucas Ranghetti #449799)
............................................................................. */

DEF STREAM str_1.   /*  Para relatorio de criticas  */

{ includes/var_batch.i }

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR rel_dsintegr AS CHAR                                  NO-UNDO.
DEF        VAR rel_dshistor AS CHAR                                  NO-UNDO.
DEF        VAR rel_qtdifeln AS INT                                   NO-UNDO.
DEF        VAR rel_vldifedb AS DECIMAL                               NO-UNDO.
DEF        VAR rel_vldifecr AS DECIMAL                               NO-UNDO.

DEF        VAR tot_contareg AS INT                                   NO-UNDO.

DEF        VAR ind_dtmvtolt AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR ind_cdagenci AS INT     FORMAT "999"                  NO-UNDO.
DEF        VAR ind_cdbccxlt AS INT     FORMAT "999"                  NO-UNDO.
DEF        VAR ind_nrdolote AS INT     FORMAT "999999"               NO-UNDO.
DEF        VAR ind_cdcmpchq AS INT     FORMAT "999"                  NO-UNDO.
DEF        VAR ind_cdbanchq AS INT     FORMAT "999"                  NO-UNDO.
DEF        VAR ind_cdagechq AS INT     FORMAT "9999"                 NO-UNDO.
DEF        VAR ind_nrctachq AS DECIMAL FORMAT "99999999999999"       NO-UNDO.
DEF        VAR ind_nrcheque AS INT     FORMAT "999999"               NO-UNDO.
DEF        VAR ind_dscodbar AS CHAR    FORMAT "x(50)"                NO-UNDO.

DEF        VAR aux_nrdconta AS INT                                   NO-UNDO.
DEF        VAR aux_nrcustod AS INT                                   NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR    INIT "rl/crrl238.lst"         NO-UNDO.

DEF        VAR aux_flgentra AS LOGICAL                               NO-UNDO.
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.

DEF        VAR h-b1wgen0012 AS HANDLE                                NO-UNDO.

DEF        VAR aux_cdcritic AS INT                                   NO-UNDO.
DEF        VAR aux_qtarquiv AS INT                                   NO-UNDO.
DEF        VAR aux_totregis AS INT                                   NO-UNDO.
DEF        VAR aux_vlrtotal AS DEC                                   NO-UNDO.

DEF VAR aux_dtmvtolt AS DATE                                         NO-UNDO.
DEF VAR aux_cdagenci AS INT                                          NO-UNDO.
DEF VAR aux_cdbccxlt AS INT                                          NO-UNDO.
DEF VAR aux_nrdolote AS INT                                          NO-UNDO.
DEF VAR aux_tplotmov AS INT                                          NO-UNDO.

DEF BUFFER crablot FOR craplot.

DEF TEMP-TABLE tt-cheques-contas-altoVale NO-UNDO
    FIELD cdcooper LIKE craplcm.cdcooper
    FIELD nrdconta LIKE craplcm.nrdconta
    FIELD nrdctabb LIKE craplcm.nrdctabb
    FIELD nrdctitg LIKE craplcm.nrdctitg
    FIELD nrdocmto LIKE craplcm.nrdocmto
    FIELD cdhistor LIKE craplcm.cdhistor
    FIELD vllanmto LIKE craplcm.vllanmto
    FIELD cdbanchq LIKE crapfdc.cdbanchq
    FIELD cdagechq LIKE crapfdc.cdagechq
    FIELD nrctachq LIKE crapfdc.nrctachq.

FORM rel_dsintegr     AT  1 FORMAT "x(40)"      LABEL "TIPO"
     SKIP(1)
     craplot.dtmvtolt AT  1 FORMAT "99/99/9999" LABEL "DATA"
     craplot.cdagenci AT 18 FORMAT "zz9"        LABEL "AGENCIA"
     craplot.cdbccxlt AT 33 FORMAT "zz9"        LABEL "BANCO/CAIXA"
     craplot.nrdolote AT 52 FORMAT "zzz,zz9"    LABEL "LOTE"
     craplot.tplotmov AT 66 FORMAT "9"          LABEL "TIPO"
     SKIP(1)
     WITH NO-BOX SIDE-LABELS NO-LABELS WIDTH 80 FRAME f_integracao.

FORM rel_dshistor AT  1 FORMAT "x(132)" 
                        LABEL "RESGATAR OS SEGUINTES CHEQUES/TITULOS"
     WITH NO-BOX DOWN NO-LABELS WIDTH 132 FRAME f_rejeitados.

FORM SKIP(1)
     "QTD               DEBITO               CREDITO" AT 26
     SKIP(1)
     "A INTEGRAR: "     AT  9
     craplot.qtinfoln   AT 22 FORMAT "zzz,zz9-"
     craplot.vlinfodb   AT 32 FORMAT "zzz,zzz,zzz,zz9.99-"
     craplot.vlinfocr   AT 54 FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP
     "INTEGRADOS: "     AT  9
     craplot.qtcompln   AT 22 FORMAT "zzz,zz9-"
     craplot.vlcompdb   AT 32 FORMAT "zzz,zzz,zzz,zz9.99-"
     craplot.vlcompcr   AT 54 FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP(1)
     "REJEITADOS: "     AT  9
     rel_qtdifeln       AT 22 FORMAT "zzz,zz9-"
     rel_vldifedb       AT 32 FORMAT "zzz,zzz,zzz,zz9.99-"
     rel_vldifecr       AT 54 FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP(2)
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_totais.

ASSIGN glb_cdprogra = "crps290".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

{ includes/cabrel132_1.i }

/*  Acessa dados da cooperativa  */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop   THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " + 
                            glb_cdprogra + "' --> '" + glb_dscritic +
                            " >> log/proc_batch.log").
         RETURN.
     END.

FOR EACH crablot WHERE crablot.cdcooper  = glb_cdcooper   AND
                       crablot.dtmvtopg >  glb_dtmvtolt   AND
                       crablot.dtmvtopg <= glb_dtmvtopr   AND
                      (crablot.tplotmov  = 19              OR
                       crablot.tplotmov  = 20) 
                       NO-LOCK BY crablot.nrdolote:

    TRANS_1:

    FOR EACH craplau WHERE craplau.cdcooper  = glb_cdcooper       AND
                           craplau.dtmvtolt  = crablot.dtmvtolt   AND
                           craplau.cdagenci  = crablot.cdagenci   AND
                           craplau.cdbccxlt  = crablot.cdbccxlt   AND
                           craplau.nrdolote  = crablot.nrdolote   AND
                           craplau.insitlau  = 1                  AND
                           craplau.dsorigem <> "CAIXA "           AND
                           craplau.dsorigem <> "INTERNET"         AND
                           craplau.dsorigem <> "TAA"              AND
                           craplau.dsorigem <> "PG555"            AND
                           craplau.dsorigem <> "CARTAOBB"         AND
                           craplau.dsorigem <> "BLOQJUD"          AND
                           craplau.dsorigem <> "DAUT BANCOOB"
                           USE-INDEX craplau3 EXCLUSIVE-LOCK
                           TRANSACTION ON ERROR UNDO TRANS_1, RETURN:

        aux_nrdconta = craplau.nrdconta. /* Conta Cheque */ 

        DO WHILE TRUE:

           FIND crapass WHERE crapass.cdcooper = glb_cdcooper   AND
                              crapass.nrdconta = aux_nrdconta
                              USE-INDEX crapass1 NO-LOCK NO-ERROR.

           IF   NOT AVAILABLE crapass   THEN
                glb_cdcritic = 251.
           ELSE
           IF   crapass.dtelimin <> ? THEN
                glb_cdcritic = 410.
           ELSE
           IF   CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))   THEN
                glb_cdcritic = 695.
           ELSE
           IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN
                DO:
                    FIND craptrf WHERE craptrf.cdcooper = glb_cdcooper  AND
                                       craptrf.nrdconta = aux_nrdconta  AND
                                       craptrf.tptransa = 1
                                       NO-LOCK NO-ERROR.

                    IF   NOT AVAILABLE craptrf  THEN
                         glb_cdcritic = 95.
                    ELSE
                         DO:
                             aux_nrdconta = craptrf.nrsconta.
                             NEXT.
                         END.
                END.

           LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */

        /* limpar campos */
        ASSIGN aux_dtmvtolt = ?
               aux_cdagenci = 0
               aux_cdbccxlt = 0
               aux_nrdolote = 0
               aux_tplotmov = 0.

        IF   glb_cdcritic > 0   THEN
             DO:
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " + 
                                    glb_cdprogra + "' --> '" + glb_dscritic +
                                    " CONTA = " + 
                                    STRING(aux_nrdconta,"zzzz,zzz,9") +
                                    " >> log/proc_message.log").                
                 
                 IF crablot.tplotmov = 19 THEN
                    ASSIGN aux_nrdolote = 4500.
                 ELSE 
                    ASSIGN aux_nrdolote = 4600.

                 DO WHILE TRUE:

                     FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                                        craplot.dtmvtolt = glb_dtmvtopr   AND
                                        craplot.cdagenci = 1              AND
                                        craplot.cdbccxlt = 100            AND
                                        craplot.nrdolote = aux_nrdolote
                                        USE-INDEX craplot1
                                        EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                        
                     IF  NOT AVAILABLE craplot    THEN
                         IF   LOCKED craplot   THEN
                              DO:
                                 PAUSE 1 NO-MESSAGE.
                                  NEXT.
                             END.
                         ELSE
                             DO:
                                 CREATE craplot.
                                 ASSIGN craplot.dtmvtolt = glb_dtmvtopr
                                        craplot.cdagenci = 1
                                        craplot.cdbccxlt = 100
                                        craplot.nrdolote = aux_nrdolote
                                        craplot.tplotmov = 1
                                        craplot.cdcooper = glb_cdcooper.
                                VALIDATE craplot.
                             END.                             
                     LEAVE.
                 END.  /*  Fim do DO WHILE TRUE  */                 
                 
                 ASSIGN craplau.insitlau = 3
                        craplau.dtdebito = glb_dtmvtopr
                        craplau.cdcritic = glb_cdcritic
                        aux_nrcustod     = 0
                        aux_dtmvtolt = craplot.dtmvtolt
                        aux_cdagenci = craplot.cdagenci
                        aux_cdbccxlt = craplot.cdbccxlt
                        aux_nrdolote = craplot.nrdolote
                        aux_tplotmov = craplot.tplotmov.
                            
                 RUN proc_rejeitados.
                 
                 ASSIGN glb_cdcritic = 0.
                                    
                 NEXT TRANS_1.
             END.
        
        IF   crablot.tplotmov = 19   THEN
             RUN proc_trata_custodia.
        ELSE
        IF   crablot.tplotmov = 20   THEN
             RUN proc_trata_titulo.
        ELSE
             NEXT.

    END.  /*  Fim do FOR EACH e da transacao -- Leitura do craplau  */

END.  /*  Fim do FOR EACH  --  Leitura dos lotes  */



FIND FIRST tt-cheques-contas-altoVale NO-LOCK NO-ERROR.

IF   AVAIL tt-cheques-contas-altoVale THEN
     RUN pi_processamento_tco.


/*DO:
    RUN sistema/generico/procedures/b1wgen0012.p PERSISTENT SET h-b1wgen0012.

    RUN gerar_compel_altoVale IN h-b1wgen0012 (INPUT glb_dtmvtopr,
                                               INPUT 1,
                                               INPUT 1,
                                               INPUT 999,
                                               INPUT glb_cdoperad,
                                        INPUT TABLE tt-cheques-contas-altoVale,
                                              OUTPUT aux_cdcritic,
                                              OUTPUT aux_qtarquiv,
                                              OUTPUT aux_totregis,
                                              OUTPUT aux_vlrtotal).

    DELETE PROCEDURE h-b1wgen0012.
END. */

    
/*  Emite resumo das integracoes de titulos e custodia do dia  */

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel132_1.

FOR EACH craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                       craplot.dtmvtolt = glb_dtmvtopr   AND
                      (craplot.nrdolote = 4500           OR
                       craplot.nrdolote = 4600)          NO-LOCK:

    ASSIGN rel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
           rel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
           rel_vldifecr = craplot.vlcompcr - craplot.vlinfocr

           rel_dsintegr = IF craplot.nrdolote = 4500
                             THEN "CHEQUES EM CUSTODIA " + 
                                  CAPS(crapcop.nmrescop)
                             ELSE "TITULOS COMPENSAVEIS"
                             
           aux_regexist = TRUE.

    DISPLAY STREAM str_1
            rel_dsintegr
            craplot.dtmvtolt  craplot.cdagenci  craplot.cdbccxlt
            craplot.nrdolote  craplot.tplotmov  craplot.dtmvtopg
            WITH FRAME f_integracao.

    FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper       AND
                           craprej.dtmvtolt = craplot.dtmvtolt   AND
                           craprej.cdagenci = craplot.cdagenci   AND
                           craprej.cdbccxlt = craplot.cdbccxlt   AND
                           craprej.nrdolote = craplot.nrdolote   AND
                          (craprej.tpintegr = 19                 OR
                           craprej.tpintegr = 20) 
                           NO-LOCK BREAK BY craprej.dtmvtolt
                                            BY craprej.cdagenci
                                               BY craprej.cdbccxlt
                                                  BY craprej.nrdolote
                                                     BY craprej.tpintegr
                                                        BY craprej.nrseqdig:

        IF   glb_cdcritic <> craprej.cdcritic   THEN
             DO:
                 glb_cdcritic = craprej.cdcritic.

                 RUN fontes/critic.p.

                 IF   CAN-DO("257,287",STRING(craprej.cdcritic)) THEN
                      glb_dscritic = "* " + glb_dscritic.
             END.

        IF   craprej.tpintegr = 19   THEN
             rel_dshistor = TRIM(STRING(craprej.nraplica,"zzzz,zzz,9")) + 
                            " ==> " + TRIM(craprej.cdpesqbb) + " " + 
                            STRING(craprej.vllanmto,"zzzz,zz9.99") +
                            " --> " + glb_dscritic.
        ELSE
        IF   craprej.tpintegr = 20   THEN
             rel_dshistor = TRIM(craprej.cdpesqbb) + " " + 
                            STRING(craprej.vllanmto,"zzzz,zz9.99") +
                            " --> " + glb_dscritic.
        ELSE
             rel_dshistor = TRIM(craprej.cdpesqbb) + " " + 
                            STRING(craprej.vllanmto,"zzzz,zz9.99") +
                            " --> " + glb_dscritic.
             
        DISPLAY STREAM str_1 rel_dshistor WITH FRAME f_rejeitados.

        DOWN STREAM str_1 WITH FRAME f_rejeitados.

        IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
             DO:
                 PAGE STREAM str_1.

                 DISPLAY STREAM str_1
                         rel_dsintegr
                         craplot.dtmvtolt  craplot.cdagenci  craplot.cdbccxlt
                         craplot.nrdolote  craplot.tplotmov  craplot.dtmvtopg
                         WITH FRAME f_integracao.
             END.

    END.   /*  Fim do FOR EACH  --  Leitura dos rejeitados  */

    IF   LINE-COUNTER(str_1) > 76   THEN
         DO:
             PAGE STREAM str_1.

             DISPLAY STREAM str_1
                     rel_dsintegr
                     craplot.dtmvtolt  craplot.cdagenci  craplot.cdbccxlt
                     craplot.nrdolote  craplot.tplotmov  craplot.dtmvtopg
                     WITH FRAME f_integracao.
         END.

    DISPLAY STREAM str_1
            craplot.qtinfoln  craplot.vlinfodb
            craplot.vlinfocr  craplot.qtcompln
            craplot.vlcompdb  craplot.vlcompcr
            rel_qtdifeln      rel_vldifedb
            rel_vldifecr
            WITH FRAME f_totais.

END.  /*  Fim do FOR EACH  --  Leitura dos lotes integrados  */

IF   NOT aux_regexist   THEN
     DISPLAY STREAM str_1
             SKIP(1)
             "** NENHUM LANCAMENTO NO DIA **"
             WITH NO-BOX FRAME f_msg.

OUTPUT STREAM str_1 CLOSE.
                     
ASSIGN glb_nrcopias = 2
       glb_nmformul = ""
       glb_nmarqimp = aux_nmarqimp.

IF   aux_regexist   THEN
     RUN fontes/imprim.p.

RUN fontes/fimprg.p.
                       
/* .......................................................................... */

PROCEDURE proc_trata_custodia:

    DEF VAR aux_cdcopant AS INTE NO-UNDO.

    /* armazena a cooperativa anterior no caso de verificar a tco */
    IF   glb_cdcooper = 1 THEN
         ASSIGN aux_cdcopant = 2.
    ELSE
    IF   glb_cdcooper = 16 THEN
         ASSIGN aux_cdcopant = 1.

    ASSIGN ind_dtmvtolt = DATE(INT(SUBSTRING(craplau.cdseqtel,04,02)),
                               INT(SUBSTRING(craplau.cdseqtel,01,02)),
                               INT(SUBSTRING(craplau.cdseqtel,07,04)))
                               
           ind_cdagenci = INT(SUBSTRING(craplau.cdseqtel,12,03))
           ind_cdbccxlt = INT(SUBSTRING(craplau.cdseqtel,16,03))
           ind_nrdolote = INT(SUBSTRING(craplau.cdseqtel,20,06))
           ind_cdcmpchq = INT(SUBSTRING(craplau.cdseqtel,27,03))
           ind_cdbanchq = INT(SUBSTRING(craplau.cdseqtel,31,03))
           ind_cdagechq = INT(SUBSTRING(craplau.cdseqtel,35,04))
           ind_nrctachq = INT(SUBSTRING(craplau.cdseqtel,40,08))
           ind_nrcheque = INT(SUBSTRING(craplau.cdseqtel,49,06)).
           
    DO WHILE TRUE:

       FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                          craplot.dtmvtolt = glb_dtmvtopr   AND
                          craplot.cdagenci = 1              AND
                          craplot.cdbccxlt = 100            AND
                          craplot.nrdolote = 4500     
                          USE-INDEX craplot1
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE craplot    THEN
            IF   LOCKED craplot   THEN
                 DO:
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
            ELSE
                 DO:
                     CREATE craplot.
                     ASSIGN craplot.dtmvtolt = glb_dtmvtopr
                            craplot.cdagenci = 1
                            craplot.cdbccxlt = 100             
                            craplot.nrdolote = 4500
                            craplot.tplotmov = 1
                            craplot.cdcooper = glb_cdcooper.
                     VALIDATE craplot.
                 END.

       LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    ASSIGN aux_dtmvtolt = craplot.dtmvtolt
           aux_cdagenci = craplot.cdagenci
           aux_cdbccxlt = craplot.cdbccxlt
           aux_nrdolote = craplot.nrdolote
           aux_tplotmov = craplot.tplotmov.

    DO WHILE TRUE:

       FIND crapcst WHERE crapcst.cdcooper = glb_cdcooper   AND
                          crapcst.dtmvtolt = ind_dtmvtolt   AND
                          crapcst.cdagenci = ind_cdagenci   AND
                          crapcst.cdbccxlt = ind_cdbccxlt   AND
                          crapcst.nrdolote = ind_nrdolote   AND
                          crapcst.cdcmpchq = ind_cdcmpchq   AND
                          crapcst.cdbanchq = ind_cdbanchq   AND
                          crapcst.cdagechq = ind_cdagechq   AND
                          crapcst.nrctachq = ind_nrctachq   AND
                          crapcst.nrcheque = ind_nrcheque
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                          
       IF   NOT AVAILABLE crapcst   THEN
            IF   LOCKED crapcst   THEN
                 DO:
                     PAUSE 2 NO-MESSAGE.
                     NEXT.
                 END.
            ELSE
                 DO:
                     ASSIGN glb_cdcritic     = 680
                            aux_nrcustod     = 0
                            craplau.insitlau = 3
                            craplau.dtdebito = craplot.dtmvtolt
                            craplau.cdcritic = glb_cdcritic.
                            
                     RUN proc_rejeitados.

                     ASSIGN glb_cdcritic = 0.

                     /* Sair da PROCEDURE e ir para o proximo registro */
                     RETURN.
                 END.

       aux_nrcustod = crapcst.nrdconta.
       
       LEAVE.
    
    END.  /*  Fim do DO WHILE TRUE  */

    ASSIGN glb_cdcritic = 0
           aux_flgentra = TRUE.

    IF   craplau.cdhistor <> 21   AND 
         craplau.cdhistor <> 26   THEN
         ASSIGN glb_cdcritic = 245.
    ELSE 
         DO:
             RELEASE craptco.

             FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper      AND
                                crapfdc.cdbanchq = crapcst.cdbanchq  AND
                                crapfdc.cdagechq = crapcst.cdagechq  AND
                                crapfdc.nrctachq = crapcst.nrctachq  AND
                                crapfdc.nrcheque = crapcst.nrcheque 
                                USE-INDEX crapfdc1 EXCLUSIVE-LOCK NO-ERROR.

             IF   NOT AVAILABLE crapfdc   THEN
                  DO:
                      /* Verifica se eh conta migrada */
                      FIND craptco WHERE 
                           craptco.cdcopant = aux_cdcopant          AND
                           craptco.nrctaant = INT(crapcst.nrctachq) AND
                           craptco.tpctatrf = 1                     AND
                           craptco.flgativo = TRUE
                           NO-LOCK NO-ERROR.
                  
                      IF    AVAILABLE craptco THEN
                            DO:
                                FIND crapfdc WHERE 
                                     crapfdc.cdcooper = craptco.cdcopant  AND
                                     crapfdc.cdbanchq = crapcst.cdbanchq  AND
                                     crapfdc.cdagechq = crapcst.cdagechq  AND
                                     crapfdc.nrctachq = craptco.nrctaant  AND
                                     crapfdc.nrcheque = crapcst.nrcheque 
                                     USE-INDEX crapfdc1 EXCLUSIVE-LOCK
                                     NO-ERROR.
                            END.
                  END.
            
             IF   AVAILABLE crapfdc THEN     
                  DO:
                      IF   crapfdc.dtemschq = ?   THEN
                           glb_cdcritic = 108.
                      ELSE 
                      IF   crapfdc.tpcheque = 2 THEN 
                           glb_cdcritic = 646.
                      ELSE
                      IF   crapfdc.dtretchq = ?   THEN
                           glb_cdcritic = 109.
                      ELSE
                      IF   CAN-DO("5,6,7",STRING(crapfdc.incheque))   THEN
                           glb_cdcritic = 97.
                      ELSE
                      IF   crapfdc.incheque = 8   THEN
                           glb_cdcritic = 320.
                      ELSE
                      IF   crapfdc.tpcheque = 3   AND /* cheque salario */
                           crapfdc.incheque = 1   THEN
                           glb_cdcritic = 96.
                      ELSE     
                      IF   crapfdc.tpcheque = 3   AND /* cheque salario */
                           crapfdc.vlcheque <> craplau.vllanaut   THEN
                           glb_cdcritic = 269.
                  
                  END.
             ELSE
                  glb_cdcritic = 108.
         END.
    
    IF   glb_cdcritic = 0   THEN
         IF   CAN-FIND(craplcm WHERE craplcm.cdcooper = glb_cdcooper      AND
                                     craplcm.dtmvtolt = glb_dtmvtopr      AND
                                     craplcm.cdagenci = craplot.cdagenci  AND
                                     craplcm.cdbccxlt = craplot.cdbccxlt  AND
                                     craplcm.nrdolote = craplot.nrdolote  AND
                                     craplcm.nrdctabb = craplau.nrdctabb  AND
                                     craplcm.nrdocmto = craplau.nrdocmto
                                     USE-INDEX craplcm1)   THEN
              glb_cdcritic = 92.
         ELSE
         IF   craplau.cdhistor = 26   THEN
              DO:
                  IF   crapfdc.incheque = 2   THEN
                       glb_cdcritic = 287.
              END.
         ELSE
         IF   craplau.cdhistor = 21 THEN
              IF   crapfdc.incheque = 2   THEN
                   glb_cdcritic = 257.
              ELSE
              IF   crapfdc.incheque = 1   THEN
                   glb_cdcritic = 96.
    
    IF   glb_cdcritic > 0   THEN
         DO:
             RUN proc_rejeitados.
             
             IF  CAN-DO("257,287",STRING(glb_cdcritic))   THEN
                 ASSIGN aux_flgentra = TRUE.
             ELSE
                 ASSIGN aux_flgentra = FALSE.
         END.
    
    IF   aux_flgentra    THEN
         DO:
             /* Verifica se eh conta migrada */
             IF   AVAIL craptco THEN
                  DO:
                      IF   glb_cdcooper     = 1     AND
                           crapcst.nrdconta = 85448 THEN
                           ASSIGN craplau.dtdebito = craplot.dtmvtolt
                                  craplau.cdcritic = glb_cdcritic
                                  craplau.insitlau = 3
                                  crapcst.insitchq = 4.
                      ELSE
                           DO:
                               CREATE tt-cheques-contas-altoVale.
                               ASSIGN tt-cheques-contas-altoVale.cdcooper =
                                                    craptco.cdcooper

                                      /* Debita da conta cheque */ 
                                      tt-cheques-contas-altoVale.nrdconta =
                                                    craptco.nrdconta
                                      
                                      tt-cheques-contas-altoVale.nrdctabb = 
                                                    craplau.nrdctabb
                                      tt-cheques-contas-altoVale.nrdctitg = 
                                                    craplau.nrdctitg
                                      tt-cheques-contas-altoVale.cdhistor = 
                                                    craplau.cdhistor
                                      tt-cheques-contas-altoVale.vllanmto = 
                                                    craplau.vllanaut
                                      tt-cheques-contas-altoVale.cdbanchq = 
                                                    crapfdc.cdbanchq
                                      tt-cheques-contas-altoVale.cdagechq = 
                                                    crapfdc.cdagechq
                                      tt-cheques-contas-altoVale.nrctachq = 
                                                    crapfdc.nrctachq
                                      tt-cheques-contas-altoVale.nrdocmto = 
                                                    craplau.nrdocmto.
                
                               ASSIGN craplau.dtdebito = craplot.dtmvtolt
                                      craplau.insitlau = 2
                                      crapcst.insitchq = 4.

                               IF   craplau.cdhistor = 26   THEN
                                    ASSIGN crapfdc.incheque = crapfdc.incheque
                                                              + 5
                                           crapfdc.dtliqchq = glb_dtmvtopr
                                           crapfdc.vlcheque = craplau.vllanaut.
                               ELSE
                               IF   craplau.cdhistor = 21 THEN
                                    ASSIGN crapfdc.incheque = crapfdc.incheque 
                                                              + 5
                                           crapfdc.dtliqchq = glb_dtmvtopr
                                           crapfdc.vlcheque = craplau.vllanaut.
                           END.                
                  END.
             ELSE
                  DO:
                      CREATE craplcm.
                      ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
                             craplcm.dtrefere = craplot.dtmvtolt
                             craplcm.cdagenci = craplot.cdagenci
                             craplcm.cdbccxlt = craplot.cdbccxlt
                             craplcm.nrdolote = craplot.nrdolote
                             craplcm.nrdconta = aux_nrdconta
                             craplcm.nrdctabb = craplau.nrdctabb
                             craplcm.nrdctitg = craplau.nrdctitg
                             craplcm.nrdocmto = craplau.nrdocmto
                             craplcm.cdhistor = craplau.cdhistor
                             craplcm.vllanmto = craplau.vllanaut
                             craplcm.nrseqdig = craplot.nrseqdig + 1
                             craplcm.cdcooper = glb_cdcooper
                             craplcm.cdbanchq = crapfdc.cdbanchq
                             craplcm.cdagechq = crapfdc.cdagechq
                             craplcm.nrctachq = crapfdc.nrctachq
                    
                             craplcm.cdpesqbb = STRING(craplau.dtmvtolt,
                                              "99/99/9999")            + "-" +
                                       STRING(craplau.cdagenci,"999")  + "-" +
                                       STRING(craplau.cdbccxlt,"999")  + "-" +
                                       STRING(craplau.nrdolote,"999999") + "-" +
                                       STRING(craplau.nrseqdig,"99999")

                             craplot.qtinfoln = craplot.qtinfoln + 1
                             craplot.qtcompln = craplot.qtcompln + 1
                             craplot.vlinfodb = craplot.vlinfodb +
                                                craplau.vllanaut
                             craplot.vlcompdb = craplot.vlcompdb +
                                                craplau.vllanaut        
                             craplot.nrseqdig = craplcm.nrseqdig

                             craplau.dtdebito = craplot.dtmvtolt
                             craplau.insitlau = 2
                    
                             crapcst.insitchq = 4.
                                          /*  CHQ. OK - prg. 287~   */
                      VALIDATE craplcm.

                      IF   craplau.cdhistor = 26   THEN
                           ASSIGN crapfdc.incheque = crapfdc.incheque + 5
                                  crapfdc.dtliqchq = glb_dtmvtopr
                                  crapfdc.vlcheque = craplau.vllanaut.
                      ELSE
                      IF   craplau.cdhistor = 21 THEN
                           ASSIGN crapfdc.incheque = crapfdc.incheque + 5
                                  crapfdc.dtliqchq = glb_dtmvtopr
                                  crapfdc.vlcheque = craplau.vllanaut.
                  END.
         END.
    ELSE
         ASSIGN craplau.insitlau = 3
                craplau.dtdebito = craplot.dtmvtolt
                craplau.cdcritic = glb_cdcritic
                crapcst.insitchq = 3. /*  Processado com erro  */
                
   /* Limpar critica */
   ASSIGN glb_cdcritic = 0.

END PROCEDURE.

PROCEDURE proc_trata_titulo:

    ASSIGN ind_dtmvtolt = DATE(INT(SUBSTRING(craplau.cdseqtel,04,02)),
                               INT(SUBSTRING(craplau.cdseqtel,01,02)),
                               INT(SUBSTRING(craplau.cdseqtel,07,04)))

           ind_cdagenci = INT(SUBSTRING(craplau.cdseqtel,12,03))
           ind_cdbccxlt = INT(SUBSTRING(craplau.cdseqtel,16,03))
           ind_nrdolote = INT(SUBSTRING(craplau.cdseqtel,20,06))
                               
           ind_dscodbar = SUBSTRING(craplau.cdseqtel,27,44).

    DO WHILE TRUE:

       FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND 
                          craplot.dtmvtolt = glb_dtmvtopr   AND
                          craplot.cdagenci = 1              AND
                          craplot.cdbccxlt = 100            AND
                          craplot.nrdolote = 4600     
                          USE-INDEX craplot1
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE craplot    THEN
            IF   LOCKED craplot   THEN
                 DO:
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
            ELSE
                 DO:
                     CREATE craplot.
                     ASSIGN craplot.dtmvtolt = glb_dtmvtopr
                            craplot.cdagenci = 1
                            craplot.cdbccxlt = 100             
                            craplot.nrdolote = 4600
                            craplot.tplotmov = 1
                            craplot.cdcooper = glb_cdcooper.
                 END.

       LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    ASSIGN aux_dtmvtolt = craplot.dtmvtolt
           aux_cdagenci = craplot.cdagenci
           aux_cdbccxlt = craplot.cdbccxlt
           aux_nrdolote = craplot.nrdolote
           aux_tplotmov = craplot.tplotmov.

    DO WHILE TRUE:
    
       FIND craptit WHERE craptit.cdcooper = glb_cdcooper   AND
                          craptit.dtmvtolt = ind_dtmvtolt   AND
                          craptit.cdagenci = ind_cdagenci   AND
                          craptit.cdbccxlt = ind_cdbccxlt   AND
                          craptit.nrdolote = ind_nrdolote   AND
                          craptit.dscodbar = ind_dscodbar
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                          
       IF   NOT AVAILABLE craptit   THEN
            IF   LOCKED craptit   THEN
                 DO:
                     PAUSE 2 NO-MESSAGE.
                     NEXT.
                 END.
            ELSE
                 DO:
                     ASSIGN glb_cdcritic     = 681
                            craplau.insitlau = 3
                            craplau.dtdebito = craplot.dtmvtolt
                            craplau.cdcritic = glb_cdcritic.
                            
                     RUN proc_rejeitados.

                     ASSIGN glb_cdcritic = 0.

                     /* Sair da PROCEDURE e ir para o proximo registro */
                     RETURN.
                 END.

       LEAVE.
       
    END.  /*  Fim do DO WHILE TRUE  */

    CREATE craplcm.
    ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
           craplcm.cdagenci = craplot.cdagenci
           craplcm.cdbccxlt = craplot.cdbccxlt
           craplcm.nrdolote = craplot.nrdolote
           craplcm.nrdconta = aux_nrdconta
           craplcm.nrdctabb = aux_nrdconta
           craplcm.nrdctitg = STRING(aux_nrdconta,"99999999")
           craplcm.nrdocmto = craplau.nrdocmto
           craplcm.cdhistor = craplau.cdhistor
           craplcm.vllanmto = craplau.vllanaut
           craplcm.nrseqdig = craplot.nrseqdig + 1
           craplcm.cdcooper = glb_cdcooper

           craplcm.cdpesqbb = STRING(craplau.dtmvtolt,"99/99/9999") + "-" +
                              STRING(craplau.cdagenci,"999")        + "-" +
                              STRING(craplau.cdbccxlt,"999")        + "-" +
                              STRING(craplau.nrdolote,"999999")     + "-" +
                              STRING(craplau.nrseqdig,"99999")

           craplot.qtinfoln = craplot.qtinfoln + 1
           craplot.qtcompln = craplot.qtcompln + 1
           craplot.vlinfodb = craplot.vlinfodb + craplau.vllanaut
           craplot.vlcompdb = craplot.vlcompdb + craplau.vllanaut
           craplot.nrseqdig = craplcm.nrseqdig

           craplau.dtdebito = craplot.dtmvtolt
           craplau.insitlau = 2
           
           craptit.insittit = 2.
    VALIDATE craplcm.
    VALIDATE craplot.
    
END PROCEDURE.

PROCEDURE proc_rejeitados:

    CREATE craprej.
    ASSIGN craprej.dtmvtolt = aux_dtmvtolt
           craprej.cdagenci = aux_cdagenci
           craprej.cdbccxlt = aux_cdbccxlt
           craprej.nrdolote = aux_nrdolote
           craprej.tplotmov = aux_tplotmov
           craprej.cdhistor = craplau.cdhistor
           craprej.nraplica = aux_nrcustod
           craprej.nrdconta = aux_nrdconta
           craprej.nrdctabb = craplau.nrdctabb
           craprej.nrdctitg = craplau.nrdctitg
           craprej.nrseqdig = craplau.nrseqdig
           craprej.nrdocmto = craplau.nrdocmto
           craprej.vllanmto = craplau.vllanaut
           craprej.cdpesqbb = craplau.cdseqtel
           craprej.cdcritic = glb_cdcritic
           craprej.tpintegr = crablot.tplotmov
           craprej.cdcooper = glb_cdcooper.

    VALIDATE craprej.
END PROCEDURE.


PROCEDURE pi_processamento_tco:

    DEF VAR aux_contareg AS INT    INIT 0                             NO-UNDO.
    DEF VAR aux_nrlotetc AS INT                                       NO-UNDO.
    DEF VAR aux_nrlottco AS INT                                       NO-UNDO.
    DEF VAR aux_nrdocmt2 AS INT                                       NO-UNDO.
    DEF VAR aux_nrdocmto AS INT                                       NO-UNDO.

    ASSIGN glb_cdcritic = 0.

    FOR EACH tt-cheques-contas-altoVale NO-LOCK:

        ASSIGN aux_contareg = aux_contareg + 1
               aux_nrlotetc = 4500.

        IF   aux_contareg = 1 THEN 
             DO:
                 DO WHILE TRUE:
               
                    IF   CAN-FIND(craplot WHERE 
                                  craplot.cdcooper =
                                      tt-cheques-contas-altoVale.cdcooper AND
                                  craplot.dtmvtolt = glb_dtmvtopr         AND
                                  craplot.cdagenci = 1                    AND
                                  craplot.cdbccxlt = 100                  AND
                                  craplot.nrdolote = aux_nrlotetc
                                  USE-INDEX craplot1) THEN
                         aux_nrlotetc = aux_nrlotetc + 1.
                    ELSE
                         LEAVE.
      
                 END.  /*  Fim do DO WHILE TRUE  */
    
                 ASSIGN aux_nrlottco = aux_nrlotetc.
    
                 CREATE craplot.
                 ASSIGN craplot.cdcooper = tt-cheques-contas-altoVale.cdcooper
                        craplot.dtmvtolt = glb_dtmvtopr
                        craplot.cdagenci = 1
                        craplot.cdbccxlt = 100
                        craplot.nrdolote = aux_nrlottco
                        craplot.tplotmov = 1.
             END.
        ELSE
             DO:
                 FIND craplot WHERE craplot.cdcooper = 
                                     tt-cheques-contas-altoVale.cdcooper  AND
                                    craplot.dtmvtolt = glb_dtmvtopr       AND
                                    craplot.cdagenci = 1                  AND
                                    craplot.cdbccxlt = 100                AND
                                    craplot.nrdolote = aux_nrlottco
                                    USE-INDEX craplot1 NO-ERROR.
    
                 IF   NOT AVAILABLE craplot THEN 
                      DO:
                          glb_cdcritic = 60.
                          RUN fontes/critic.p.
                          UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                            " - " + glb_cdprogra + "' --> '" +
                                            glb_dscritic + " Lote: " +
                                            STRING(aux_nrlottco) + 
                                            " >> log/proc_batch.log").
                          NEXT.
                      END.
             END.

       aux_nrdocmt2 = tt-cheques-contas-altoVale.nrdocmto.
       
       DO WHILE TRUE:
    
          IF   CAN-FIND(craplcm WHERE craplcm.cdcooper = craplot.cdcooper   AND
                                      craplcm.dtmvtolt = craplot.dtmvtolt   AND
                                      craplcm.cdagenci = craplot.cdagenci   AND
                                      craplcm.cdbccxlt = craplot.cdbccxlt   AND
                                      craplcm.nrdolote = craplot.nrdolote   AND
                                      craplcm.nrdctabb = 
                                        tt-cheques-contas-altoVale.nrdctabb AND                                      craplcm.nrdocmto = aux_nrdocmt2
                                      USE-INDEX craplcm1)               THEN
               aux_nrdocmt2 = (aux_nrdocmt2 + 1000000).
          ELSE
               LEAVE.
          
       END.  /*  Fim do DO WHILE TRUE  */
    
       ASSIGN aux_nrdocmto = aux_nrdocmt2.
       
       CREATE craplcm.
       ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
              craplcm.dtrefere = craplot.dtmvtolt
              craplcm.cdagenci = craplot.cdagenci
              craplcm.cdbccxlt = craplot.cdbccxlt
              craplcm.nrdolote = craplot.nrdolote
              craplcm.nrdconta = tt-cheques-contas-altoVale.nrdconta
              craplcm.nrdctabb = tt-cheques-contas-altoVale.nrdctabb
              craplcm.nrdctitg = tt-cheques-contas-altoVale.nrdctitg
              craplcm.nrdocmto = aux_nrdocmto
              craplcm.cdhistor = tt-cheques-contas-altoVale.cdhistor
              craplcm.vllanmto = tt-cheques-contas-altoVale.vllanmto
              craplcm.nrseqdig = craplot.nrseqdig + 1
              craplcm.cdcooper = tt-cheques-contas-altoVale.cdcooper
              craplcm.cdbanchq = tt-cheques-contas-altoVale.cdbanchq
              craplcm.cdagechq = tt-cheques-contas-altoVale.cdagechq
              craplcm.nrctachq = tt-cheques-contas-altoVale.nrctachq
       
              craplcm.cdpesqbb = "LANCAMENTO DE CONTA MIGRADA"

              craplot.qtinfoln = craplot.qtinfoln + 1
              craplot.qtcompln = craplot.qtcompln + 1
              craplot.vlinfodb = craplot.vlinfodb + 
                                      tt-cheques-contas-altoVale.vllanmto
              craplot.vlcompdb = craplot.vlcompdb + 
                                      tt-cheques-contas-altoVale.vllanmto
              craplot.nrseqdig = craplcm.nrseqdig.
    
       VALIDATE craplot.
       VALIDATE craplcm.

    END. /** FIM do FOR EACH tt-chqtco **/

END PROCEDURE.

/* .......................................................................... */
