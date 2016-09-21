/* ..........................................................................

   Programa: includes/crps460_rej.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio       
   Data    : Janeiro/2006.                     Ultima atualizacao: 28/10/2009

   Dados referentes ao programa:

   Frequencia: Chamado pelo fontes/crps460.p
   Objetivo  : Gerar relatorio com rejeitados, relatorios 432 e 433
               Este trecho de codigo foi separado do fontes crps460.p para 
               com streams diferentes poder-se aproveitar as mesmas frames.
               
   Alteracoes: 17/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
   
               28/10/2009 - Retirado find do crapass pois esta no FOR EACH
                            (Guilherme)

............................................................................ */

IF   FIRST-OF(crapreq.cdagenci)   THEN
     DO:
         FIND crapage WHERE crapage.cdcooper = glb_cdcooper     AND
                            crapage.cdagenci = crapreq.cdagenci
                            NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE crapage   THEN
              ASSIGN rel_cdagenci = crapreq.cdagenci
                     rel_nmresage = FILL("*",15).
         ELSE
              ASSIGN rel_cdagenci = crapreq.cdagenci
                     rel_nmresage = crapage.nmresage.

         ASSIGN rel_nrseqage = 1
                rel_qttalage = 0
                rel_qttalrej = 0
                rel_dsrelato = "REQUISICOES NAO ATENDIDAS:"
                aux_flgfirst = TRUE.

         PAGE STREAM {&str_rej}.

         DISPLAY STREAM {&str_rej} rel_dsrelato WITH FRAME f_dsrelato.
         
         DISPLAY STREAM {&str_rej}  rel_cdagenci  rel_nmresage  
                               aux_nrpedido  rel_nrseqage
                               WITH FRAME f_agencia.
     END.

ASSIGN aux_regexist = TRUE
       glb_cdcritic = crapreq.cdcritic.

RUN fontes/critic.p.

IF   glb_cdcritic = 9   THEN
     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                       glb_cdprogra + "' --> '" + glb_dscritic +
                       " Conta = " + STRING(crapreq.nrdconta,
                                            "zzzz,zzz,9") +
                       " >> log/proc_batch.log").

IF   aux_regexist   THEN
     DO:
         ASSIGN rel_nmprimtl = crapass.nmprimtl
                rel_dtdemiss = crapass.dtdemiss.

         FIND craptip WHERE craptip.cdcooper = glb_cdcooper     AND
                            craptip.cdtipcta = crapass.cdtipcta
                            NO-LOCK NO-ERROR.

         IF   NOT AVAILABLE craptip   THEN
              rel_dstipcta = "".
         ELSE
              rel_dstipcta = STRING(crapass.cdtipcta,"99") + "-" +
                             craptip.dstipcta.

         IF   crapass.cdsitdct = 1   THEN
              rel_dssitdct = STRING(crapass.cdsitdct,"9") + "-" +
                             "NORMAL".
         ELSE
         IF   crapass.cdsitdct = 2   THEN
              rel_dssitdct = STRING(crapass.cdsitdct,"9") + "-" +
                             "ENC.P/ASSOCIADO".
         ELSE
         IF   crapass.cdsitdct = 3   THEN
              rel_dssitdct = STRING(crapass.cdsitdct,"9") + "-" +
                             "ENC. PELA COOP".
         ELSE
         IF   crapass.cdsitdct = 4   THEN
              rel_dssitdct = STRING(crapass.cdsitdct,"9") + "-" +
                             "ENC.P/DEMISSAO".
         ELSE
         IF   crapass.cdsitdct = 5   THEN
              rel_dssitdct = STRING(crapass.cdsitdct,"9") + "-" +
                             "NAO APROVADA".
         ELSE
         IF   crapass.cdsitdct = 6   THEN
              rel_dssitdct = STRING(crapass.cdsitdct,"9") + "-" +
                             "NORMAL S/TALAO".
         ELSE                    
         IF   crapass.cdsitdct = 9   THEN
              rel_dssitdct = STRING(crapass.cdsitdct,"9") + "-" +
                             "ENC.P/O MOTIVO".
         ELSE
              rel_dssitdct = "".
     END.
ELSE
     ASSIGN rel_dstipcta = ""
            rel_dssitdct = ""
            rel_nmprimtl = ""
            rel_dtdemiss = ?.

ASSIGN rel_nrdconta = crapreq.nrdconta
       rel_qtreqtal = crapreq.qtreqtal
       rel_qttalrej = rel_qttalrej + crapreq.qtreqtal
       rel_dscritic = glb_dscritic.

DISPLAY STREAM {&str_rej}
        rel_nrdconta  rel_nmprimtl  rel_dtdemiss
        rel_dstipcta  rel_dssitdct  rel_qtreqtal
        rel_dscritic  WITH FRAME f_rejeitados.

IF   LAST-OF(crapreq.cdagenci)   THEN
     DOWN 2 STREAM {&str_rej} WITH FRAME f_rejeitados.
ELSE
     DOWN STREAM {&str_rej} WITH FRAME f_rejeitados.

IF   LINE-COUNTER({&str_rej}) > PAGE-SIZE({&str_rej})  THEN
     DO:
         PAGE STREAM {&str_rej}.

         rel_nrseqage = rel_nrseqage + 1.

         DISPLAY STREAM {&str_rej} rel_dsrelato WITH FRAME f_dsrelato.
         
         DISPLAY STREAM {&str_rej}  rel_cdagenci  rel_nmresage  
                               aux_nrpedido  rel_nrseqage
                               WITH FRAME f_agencia.
     END.

IF   LAST-OF(crapreq.cdagenci)   THEN
     IF   LINE-COUNTER({&str_rej}) > 77   THEN
          DO:
              PAGE STREAM {&str_rej}.

              rel_nrseqage = rel_nrseqage + 1.

              DISPLAY STREAM {&str_rej}
                      rel_dsrelato WITH FRAME f_dsrelato.
                      
              DISPLAY STREAM {&str_rej}  rel_cdagenci  rel_nmresage  
                               aux_nrpedido  rel_nrseqage
                               WITH FRAME f_agencia.
          END.

/* ......................................................................... */
 
