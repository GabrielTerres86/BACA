/* ............................................................................

   Programa: Fontes/crps513.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Junho/2008.                       Ultima atualizacao: 19/09/2017.

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Integrar arquivos do Banco do Brasil.
               Emite relatorio 487.
               Rodar na cadeia da Cecred.

   Alteracoes: 27/08/2008 - Incluir tratamento de Integrar Transferencia (Ze).

               05/11/2008 - Alteracao para atender as agencias diferentes da
                            3420 (Ze).

               19/03/2009 - Ajuste para unificacao dos bancos de dados
                            (Evandro).

               22/06/2012 - Substituido gncoper por crapcop (Tiago).   

               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).

               13/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)

               29/09/2014 - Incluso tratamento para incorporacao cooperativa 
                            Concred pela Viacredi (Daniel).

               05/12/2016 - Incorporacao Transulcred (Guilherme/SUPERO)

               19/09/2017 - Alteracao da Agencia do Banco do Brasil. (Jaison/Elton - M459)

............................................................................ */

{ includes/var_batch.i }

DEF STREAM str_1.   
DEF STREAM str_2.
DEF STREAM str_3.

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.
DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.
                                     
DEF        VAR tot_recebido AS INT                                   NO-UNDO.
DEF        VAR vlr_recebido AS DEC                                   NO-UNDO.
DEF        VAR tot_integrad AS INT                                   NO-UNDO.
DEF        VAR vlr_integrad AS DEC                                   NO-UNDO.
DEF        VAR tot_rejeitad AS INT                                   NO-UNDO.
DEF        VAR vlr_rejeitad AS DEC                                   NO-UNDO.

DEF        VAR sub_vllandeb AS DEC                                   NO-UNDO.
DEF        VAR sub_vllancre AS DEC                                   NO-UNDO.
DEF        VAR tot_vllandeb AS DEC                                   NO-UNDO.
DEF        VAR tot_vllancre AS DEC                                   NO-UNDO.

DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_setlinha AS CHAR                                  NO-UNDO.
DEF        VAR aux_dsdlinha AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_tplotmov AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_nrdolote AS INT                                   NO-UNDO.
DEF        VAR aux_dtmvtolt AS DATE                                  NO-UNDO.
DEF        VAR aux_vllanmto AS DECIMAL                               NO-UNDO.
DEF        VAR aux_cdlanmto AS INT                                   NO-UNDO.
DEF        VAR aux_nrdocmto AS INT                                   NO-UNDO.
DEF        VAR aux_nrdocmt2 AS INT                                   NO-UNDO.
DEF        VAR aux_indebcre AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrdconta AS INT                                   NO-UNDO.
DEF        VAR aux_nrdctabb AS INT                                   NO-UNDO.
DEF        VAR aux_cdconven AS INT                                   NO-UNDO.
DEF        VAR aux_dshistor AS CHAR                                  NO-UNDO.
DEF        VAR aux_lshistor AS CHAR                                  NO-UNDO.
DEF        VAR aux_lshsttrf AS CHAR                                  NO-UNDO.
DEF        VAR aux_dtrefere AS CHAR                                  NO-UNDO.
DEF        VAR aux_vllandeb AS CHAR                                  NO-UNDO.
DEF        VAR aux_vllancre AS CHAR                                  NO-UNDO.

DEF BUFFER crabcop FOR crapcop. 

DEF TEMP-TABLE w-processa                                            NO-UNDO
    FIELD cdlanmto  AS INTEGER
    FIELD cdsituac  AS INTEGER  /* 1 - Integrado, 2 - Rejeitado */ 
    FIELD nrdconta  AS INTEGER
    FIELD nmprimtl  AS CHAR
    FIELD nrdctabb  AS INTEGER
    FIELD dtmvtolt  AS DATE
    FIELD dtrefere  AS CHAR
    FIELD tplanmto  AS CHAR     /* Debito, Credito */      
    FIELD indebcre  AS CHAR
    FIELD dshistor  AS CHAR
    FIELD dscritic  AS CHAR
    FIELD vllanmto  AS DEC
    FIELD vllandeb  AS DEC
    FIELD vllancre  AS DEC
    FIELD nrdocmto  AS INT
    INDEX w-processa1 AS PRIMARY cdlanmto.


FORM "ARQUIVO: " aux_nmarquiv   FORMAT "x(30)"
     SKIP(1)
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_arquivo.

FORM SKIP(1)
     "LANCAMENTOS INTEGRADOS:"
     SKIP(1)
     "DATA: "           glb_dtmvtolt  FORMAT "99/99/9999"  
     "  PA: "           aux_cdagenci  FORMAT "zz9"
     "  BANCO/CAIXA: "  aux_cdbccxlt  FORMAT "zz9"
     "  LOTE: "         aux_nrdolote  FORMAT "zzz,zz9"
     "  TIPO: "         aux_tplotmov  FORMAT "zz9"
     SKIP(2)
     "CONTA/DV"                         AT 03
     "NOME"                             AT 12
     "DATA REF."                        AT 43
     "HISTORICO"                        AT 54
     "DOCUMENTO"                        AT 72
     "VALOR DEBITO"                     AT 88
     "VALOR CREDITO"                    AT 106 SKIP
     "----------"                       AT 01
     "------------------------------"   AT 12
     "----------"                       AT 43
     "-----------------"                AT 54
     "---------"                        AT 72
     "------------------"               AT 82
     "------------------"               AT 101
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_cab_integrados.

FORM w-processa.nrdconta   FORMAT "zzzz,zzz,9"        
     w-processa.nmprimtl   FORMAT "x(30)"             
     w-processa.dtrefere   FORMAT "x(10)"        
     w-processa.dshistor   FORMAT "x(17)"             
     w-processa.nrdocmto   FORMAT "zzz,zzzz9"          
     aux_vllandeb          FORMAT "x(18)"
     aux_vllancre          FORMAT "x(18)"
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_integrados.

FORM "------------------"                          AT 82
     "------------------"                          AT 101 SKIP
     sub_vllandeb   FORMAT "zzz,zzz,zzz,zz9.99"    AT 082
     sub_vllancre   FORMAT "zzz,zzz,zzz,zz9.99"    AT 101 SKIP(1)
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_total_lancamento.

FORM "TOTAL GERAL"                                 AT 66
     tot_vllandeb   FORMAT "zzz,zzz,zzz,zz9.99"    AT 082
     tot_vllancre   FORMAT "zzz,zzz,zzz,zz9.99"    AT 101 SKIP(1)
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_totalgeral_lancamento.

FORM SKIP(2)
     "LANCAMENTOS REJEITADOS:"
     SKIP(1)
     WITH NO-BOX SIDE-LABELS DOWN WIDTH 132 FRAME f_cab_rejeitados.
     
FORM w-processa.dshistor   FORMAT "x(25)"              LABEL "HISTORICO BB"
     w-processa.indebcre   FORMAT "x"                  LABEL "D/C"
     w-processa.nrdctabb   FORMAT "zz,zzz,zzz,zzz,9"   LABEL "CONTA BASE"
     w-processa.nrdocmto   FORMAT "zzz,zzzz9"          LABEL "DOCUMENTO"
     w-processa.dtrefere   FORMAT "x(10)"              LABEL "DATA REF."
     w-processa.vllanmto   FORMAT "zzz,zzz,zzz,zz9.99" LABEL "VALOR"
     w-processa.dscritic   FORMAT "x(40)"              LABEL "CRITICA"
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_rejeitados.

FORM SKIP(2)
     "RECEBIDOS         INTEGRADOS         REJEITADOS"   AT 24   SKIP
     "   REGISTROS:"    
     tot_recebido   FORMAT "zzz,zz9"                     AT 26
     tot_integrad   FORMAT "zzz,zz9"                     AT 45
     tot_rejeitad   FORMAT "zzz,zz9"                     AT 64   SKIP
     vlr_recebido   FORMAT "zzz,zzz,zzz,zz9.99"          AT 15
     vlr_integrad   FORMAT "zzz,zzz,zzz,zz9.99"          AT 34
     vlr_rejeitad   FORMAT "zzz,zzz,zzz,zz9.99"          AT 53
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_totais.


ASSIGN glb_cdprogra = "crps513".
       glb_flgbatch = FALSE.
       
RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.
          
/* Busca dados da cooperativa */

FIND crabcop WHERE crabcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crabcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         RETURN.
     END.


/*  Le tabela com o codigo do convenio do Banco do Brasil com a Coop.  */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "GENERI"       AND
                   craptab.cdempres = 0              AND
                   craptab.cdacesso = "COMPEARQBB"   AND
                   craptab.tpregist = 346 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 55.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                             glb_cdprogra + "' --> '" + glb_dscritic +
                             "(COMPEARQBB) >> log/proc_batch.log").

         RETURN.
     END.
ELSE
     ASSIGN aux_cdconven = INT(SUBSTR(craptab.dstextab,1,9)).


/*  Lista dos Historicos para Integracao  */

ASSIGN aux_lshistor = "0144,0229,0729,0870"
       aux_lshsttrf = "0470".

ASSIGN aux_flgfirst = TRUE
       aux_nmarquiv = "compbb/deb558*" + 
                      STRING(glb_dtmvtolt,"999999") + "*" + 
                      STRING(aux_cdconven,"999999999") + "*".
        

/*  Verifica se existe arquivo a ser integrado  */

INPUT STREAM str_1 THROUGH VALUE("ls " + aux_nmarquiv) NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_1 aux_setlinha FORMAT "x(70)" WITH NO-BOX NO-LABELS.

   INPUT STREAM str_2 THROUGH VALUE("tail -1 " + aux_setlinha) NO-ECHO.
      
   SET STREAM str_2 aux_dsdlinha FORMAT "x(70)" 
                    WITH NO-BOX NO-LABELS FRAME f_ls.

   IF   SUBSTR(aux_dsdlinha,01,01) <> "9" THEN
        glb_cdcritic = 258.
           
   INPUT STREAM str_2 CLOSE.
   
   IF   glb_cdcritic = 0 THEN
        DO:
            /*  Verifica o HEADER do arquivo */
                          
            ASSIGN aux_nmarquiv = aux_setlinha
                   aux_setlinha = "".
            
            INPUT STREAM str_3 FROM VALUE(aux_nmarquiv) NO-ECHO.
            
            IMPORT STREAM str_3 UNFORMATTED aux_setlinha.
            
            IF   SUBSTRING(aux_setlinha,01,01) <> "0" THEN
                 glb_cdcritic = 181.
            
            IF   SUBSTRING(aux_setlinha,38,09) <> 
                 STRING(aux_cdconven,"999999999") THEN
                 glb_cdcritic = 563.
        
            ASSIGN aux_dtmvtolt = DATE(INT(SUBSTRING(aux_setlinha,184,2)),
                                       INT(SUBSTRING(aux_setlinha,182,2)),
                                       INT(SUBSTRING(aux_setlinha,186,4))).

            IF   aux_dtmvtolt <> glb_dtmvtolt  THEN
                 glb_cdcritic = 789.

            INPUT STREAM str_3 CLOSE.     
        END.
    END.  
         
INPUT STREAM str_1 CLOSE.
         
IF   SEARCH(aux_nmarquiv) = ? THEN
     glb_cdcritic = 182.

IF   glb_cdcritic <> 0 THEN
     DO:    
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                            glb_cdprogra + "' --> '" + glb_dscritic +
                            "' --> '" + aux_nmarquiv +
                            " >> log/proc_batch.log").
         RETURN.
     END.



INPUT STREAM str_1 FROM VALUE(aux_nmarquiv) NO-ECHO.

TRANS_1:

DO TRANSACTION ON ERROR UNDO TRANS_1, RETURN:

   DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
                             
      IMPORT STREAM str_1 UNFORMATTED aux_setlinha.

      IF   SUBSTRING(aux_setlinha,1,1) <> "1"  THEN
           NEXT.          
           
      /* Despreza quando nao for Registro de Lancamento */ 
      IF   SUBSTRING(aux_setlinha,42,1) <> "1"  THEN
           NEXT.
      
      ASSIGN aux_cdlanmto = INT(SUBSTRING(aux_setlinha,195,6))
             aux_nrdctabb = IF SUBSTRING(aux_setlinha,41,01) = 'X' 
                            THEN INT(SUBSTRING(aux_setlinha,33,08) + "0")
                            ELSE INT(SUBSTRING(aux_setlinha,33,09))
             aux_dshistor = TRIM(SUBSTRING(aux_setlinha,46,29))
             aux_nrdocmto = INT(SUBSTRING(aux_setlinha,75,6))
             aux_vllanmto = DECIMAL(SUBSTRING(aux_setlinha,87,18)) / 100
             aux_indebcre = IF   INT(SUBSTRING(aux_setlinha,43,3)) > 100  AND
                                 INT(SUBSTRING(aux_setlinha,43,3)) < 200  THEN
                                 "D"
                            ELSE "C"
             aux_dtrefere = IF INT(SUBSTRING(aux_setlinha,174,8)) > 0
                            THEN STRING(DATE(INT(SUBSTR(aux_setlinha,176,2)),
                                 INT(SUBSTRING(aux_setlinha,174,2)),
                                 INT(SUBSTRING(aux_setlinha,178,4))),
                                               "99.99.9999")
                            ELSE "".               
      
      IF   NOT CAN-DO(aux_lshistor,SUBSTR(aux_dshistor,01,04))  THEN           
           DO:
               IF   NOT CAN-DO(aux_lshsttrf,SUBSTR(aux_dshistor,01,04))  THEN
                    DO:
                        RUN cria_rejeitado(INPUT "Historico nao processado.").
                        NEXT.           
                    END.
           END.   
   
      /*  Calcula do digito verificador do numero do documento ............ */
      
      glb_nrcalcul = INT(STRING(aux_nrdocmto,"999999") + "0").
 
      RUN fontes/digfun.p.
                  
      aux_nrdocmto = glb_nrcalcul.

      
      /* Verifica se existe Conta Centralizadora 
        (Nao devem existir Contas Centralizadoras com mesmo Numero) */ 
     
      FIND FIRST gnctace WHERE gnctace.cddbanco = aux_cdbccxlt      AND
                               gnctace.nrctacen = aux_nrdocmto
                               NO-LOCK NO-ERROR.
                         
      IF   NOT AVAIL gnctace  THEN
           DO:
               RUN cria_rejeitado 
                   (INPUT "Conta Centralizadora nao cadastrada.").
                
               NEXT.           
           END.
      ELSE
           DO:
               IF   NOT gnctace.flgintce  THEN   /* Nao Centraliza */
                    DO:
                        RUN cria_rejeitado
                            (INPUT "Conta nao habilitada para integralizacao.").
                            
                        NEXT.
                    END.
           END.

      /* Tratamento para incorporacao */
      IF  gnctace.cdcooper = 4 THEN  /* CONCREDI */
          /* Busca Numero da Conta na CECRED (cadastrado na crapass) */ 
          FIND FIRST crapcop
               WHERE crapcop.cdcooper = 1 NO-LOCK NO-ERROR.
      ELSE
      IF  gnctace.cdcooper = 15 THEN /* CREDIMILSUL */
          /* Busca Numero da Conta na CECRED (cadastrado na crapass) */ 
          FIND FIRST crapcop
               WHERE crapcop.cdcooper = 13 NO-LOCK NO-ERROR.
      ELSE
      IF  gnctace.cdcooper = 17 THEN /* TRANSULCRED */
          /* Busca Numero da Conta na CECRED (cadastrado na crapass) */ 
          FIND FIRST crapcop
               WHERE crapcop.cdcooper = 9 NO-LOCK NO-ERROR.
      ELSE
          /* Busca Numero da Conta na CECRED (cadastrado na crapass) */ 
          FIND FIRST crapcop
               WHERE crapcop.cdcooper = gnctace.cdcooper
             NO-LOCK NO-ERROR.

      IF  NOT AVAILABLE crapcop THEN DO:
          glb_cdcritic = 651.
          RUN fontes/critic.p.
          UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                             glb_cdprogra +  "' --> '" + glb_dscritic + 
                             " >> log/proc_batch.log").
          UNDO TRANS_1, RETURN.
      END.

      ASSIGN aux_nrdconta = crapcop.nrctactl.

      FIND crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                         crapass.nrdconta = crapcop.nrctactl NO-LOCK NO-ERROR.

      IF   NOT AVAIL crapass  THEN
           DO:
               RUN cria_rejeitado
                   (INPUT "Conta/dv nao cadastrada na Cooperativa.").

               NEXT.
      END.
      
      IF   aux_nrdctabb <> 50482 AND aux_nrdctabb <>  2050480 THEN
           DO:
               RUN cria_rejeitado 
                  (INPUT "Somente lancamento da conta 5.048.2 ou 205.048.0").
               NEXT.           
      END.

      IF   gnctace.cdcooper = 3 THEN   /* Central */     
           DO:
               RUN cria_rejeitado 
                   (INPUT "Para este hist. Conta CECRED nao integrado.").
               NEXT.           
      END.


      IF   CAN-DO(aux_lshsttrf,SUBSTR(aux_dshistor,01,04))  THEN
           DO:
               /* gnctace.flgintrf criado para distinguir das contas de 
                  repasse de convenios que utilizam o mesmo historico */
               
               IF   NOT gnctace.flgintrf  THEN   /* Nao Centraliza */
                    DO:
                        RUN cria_rejeitado
                           (INPUT "Conta nao habilitada para hist. de transf.").
                        NEXT.
                    END.

               IF   aux_indebcre <> "D" THEN   
                    DO:
                        RUN cria_rejeitado
                           (INPUT "Somente para lancamentos de Debito.").
                        NEXT.
                    END.                    
      END.

      
      /* Criar Lote no primeiro Lancamento */ 
      IF   aux_flgfirst  THEN
           DO:
               DO WHILE TRUE:
           
                  FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                     craptab.nmsistem = "CRED"       AND
                                     craptab.tptabela = "GENERI"     AND
                                     craptab.cdempres = 00           AND
                                     craptab.cdacesso = "NUMLOTEBCO" AND
                                     craptab.tpregist = 001
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF   NOT AVAILABLE craptab THEN
                       IF   LOCKED craptab THEN
                            DO:
                                PAUSE 2 NO-MESSAGE.
                                NEXT.
                       END.
                       ELSE
                            DO:
                                glb_cdcritic = 472.
                                RUN fontes/critic.p.
                                UNIX SILENT VALUE ("echo " +
                                                   STRING(TIME,"HH:MM:SS") +
                                                   " - " + glb_cdprogra + 
                                                   "' --> '" + glb_dscritic + 
                                                   " >> log/proc_batch.log").
                                UNDO TRANS_1, RETURN.
                       END.
                  LEAVE.
               END.    /*  Fim do DO WHILE TRUE  */
   
               ASSIGN aux_nrdolote = INT(craptab.dstextab) + 1.
            
               DO WHILE TRUE:

                  IF   CAN-FIND(craplot WHERE 
                                craplot.cdcooper = glb_cdcooper AND
                                craplot.dtmvtolt = glb_dtmvtolt AND
                                craplot.cdagenci = aux_cdagenci AND
                                craplot.cdbccxlt = aux_cdbccxlt AND
                                craplot.nrdolote = aux_nrdolote
                                USE-INDEX craplot1) THEN
                       ASSIGN aux_nrdolote = aux_nrdolote + 1.
                  ELSE
                       LEAVE.
                       
               END.  /*  Fim do DO WHILE TRUE  */
                                          
               CREATE craplot.
               ASSIGN craplot.cdcooper = glb_cdcooper
                      craplot.dtmvtolt = glb_dtmvtolt
                      craplot.cdagenci = aux_cdagenci
                      craplot.cdbccxlt = aux_cdbccxlt
                      craplot.nrdolote = aux_nrdolote
                      craplot.tplotmov = aux_tplotmov
               
               /* Atualiza registro na craptab */ 
               craptab.dstextab = STRING(aux_nrdolote).
               VALIDATE craplot.

               ASSIGN aux_flgfirst = FALSE.
               
               RELEASE craptab.
      END.           
    
      FIND craplot WHERE craplot.cdcooper = glb_cdcooper AND
                         craplot.dtmvtolt = glb_dtmvtolt AND
                         craplot.cdagenci = aux_cdagenci AND
                         craplot.cdbccxlt = aux_cdbccxlt AND
                         craplot.nrdolote = aux_nrdolote
                         USE-INDEX craplot1 EXCLUSIVE-LOCK NO-ERROR.
        
      /* Verifica se possui outro lancamento com o mesmo nro documento */
   
      ASSIGN aux_nrdocmto = INT(SUBSTRING(aux_setlinha,75,6))
             aux_nrdocmt2 = aux_nrdocmto.
                        
      DO WHILE TRUE:

         FIND craplcm WHERE craplcm.cdcooper = glb_cdcooper      AND
                            craplcm.dtmvtolt = craplot.dtmvtolt  AND
                            craplcm.cdagenci = craplot.cdagenci  AND
                            craplcm.cdbccxlt = craplot.cdbccxlt  AND
                            craplcm.nrdolote = craplot.nrdolote  AND
                            craplcm.nrdctabb = aux_nrdctabb      AND
                            craplcm.nrdocmto = aux_nrdocmt2     
                            USE-INDEX craplcm1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   AVAILABLE craplcm THEN
              aux_nrdocmt2 = (aux_nrdocmt2 + 100000).
         ELSE
              LEAVE.
          
      END.  /*  Fim do DO WHILE TRUE  */

      ASSIGN aux_nrdocmto = aux_nrdocmt2.
      

      /* Grava as informacoes */
      
      CREATE craplcm.
      ASSIGN craplcm.cdcooper = glb_cdcooper 
             craplcm.nrdconta = aux_nrdconta
             craplcm.nrdctabb = aux_nrdctabb
             craplcm.dtmvtolt = craplot.dtmvtolt
             craplcm.dtrefere = craplot.dtmvtolt
             craplcm.cdagenci = craplot.cdagenci
             craplcm.cdbccxlt = craplot.cdbccxlt
             craplcm.nrdolote = craplot.nrdolote
             craplcm.nrdocmto = aux_nrdocmto
             craplcm.cdhistor = IF   aux_indebcre = "D" THEN
                                     446
                                ELSE 440
             craplcm.vllanmto = aux_vllanmto
             craplcm.nrseqdig = craplot.nrseqdig + 1.
      VALIDATE craplcm.

      ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
             craplot.qtcompln = craplot.qtcompln + 1
             craplot.nrseqdig = craplcm.nrseqdig.


             IF   aux_indebcre = "D" THEN
                  ASSIGN craplot.vlinfodb = craplot.vlinfodb + craplcm.vllanmto
                         craplot.vlcompdb = craplot.vlcompdb + craplcm.vllanmto.
             ELSE 
                  ASSIGN craplot.vlinfocr = craplot.vlinfocr + craplcm.vllanmto
                         craplot.vlcompcr = craplot.vlcompcr + craplcm.vllanmto.

      RUN cria_integrado.
      
   END. /* DO WHILE TRUE */
  

END. /* DO TRANSACTION */

        
INPUT STREAM str_1 CLOSE.

/* renameia o arquivo antes de salva-lo  */
UNIX SILENT VALUE ("mv " + aux_nmarquiv + " integra/deb558_513_" +
                           STRING(YEAR(glb_dtmvtolt),"9999") +
                           STRING(MONTH(glb_dtmvtolt),"99") +
                           STRING(DAY(glb_dtmvtolt),"99") + ".bb").

/* move arquivo para o diretorio salvar */
UNIX SILENT VALUE ("mv integra/deb558_513_" + 
                   STRING(YEAR(glb_dtmvtolt),"9999") +
                   STRING(MONTH(glb_dtmvtolt),"99") +
                   STRING(DAY(glb_dtmvtolt),"99") + ".bb salvar").

/* GERAR RELATORIO */

ASSIGN aux_nmarqimp    = "rl/crrl487.lst"
       glb_cdrelato[2] = 487.
       glb_cdempres    = 11.
       
{ includes/cabrel132_2.i }

OUTPUT STREAM str_2 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

VIEW STREAM str_2 FRAME f_cabrel132_2.

DISPLAY STREAM str_2 aux_nmarquiv WITH FRAME f_arquivo.
                           
FOR EACH w-processa BREAK BY w-processa.cdsituac
                          BY w-processa.nrdconta
                          BY w-processa.vllancre
                          BY w-processa.vllandeb:
                            
    IF   FIRST-OF(w-processa.cdsituac)  THEN
         DO:
             IF   w-processa.cdsituac = 1  THEN   /* Integrado */
                  DISPLAY STREAM str_2 glb_dtmvtolt aux_cdagenci aux_cdbccxlt
                                       aux_nrdolote aux_tplotmov
                                       WITH FRAME f_cab_integrados.
             ELSE  /* Rejeitado */ 
                  DISPLAY STREAM str_2 WITH FRAME f_cab_rejeitados.
    END.

    IF   w-processa.cdsituac = 1  THEN   
         DO:
             IF   w-processa.vllandeb > 0 THEN
                  ASSIGN aux_vllandeb = STRING(w-processa.vllandeb,
                                                   "zzz,zzz,zzz,zz9.99").
             ELSE
                  ASSIGN aux_vllandeb = "".

             IF   w-processa.vllancre > 0 THEN
                  ASSIGN aux_vllancre = STRING(w-processa.vllancre,
                                                   "zzz,zzz,zzz,zz9.99").
             ELSE
                  aux_vllancre = "".
             
             DISPLAY STREAM str_2 w-processa.nrdconta  w-processa.nmprimtl 
                                  w-processa.dtrefere  w-processa.dshistor 
                                  w-processa.nrdocmto  aux_vllandeb
                                  aux_vllancre         WITH FRAME f_integrados.
                                  
             DOWN STREAM str_2 WITH FRAME f_integrados.

             ASSIGN tot_integrad = tot_integrad + 1
                    vlr_integrad = vlr_integrad + w-processa.vllanmto.
                    
             IF   w-processa.tplanmto = "D" THEN
                  ASSIGN sub_vllandeb = sub_vllandeb + w-processa.vllanmto
                         tot_vllandeb = tot_vllandeb + w-processa.vllanmto.
             ELSE            
                  ASSIGN sub_vllancre = sub_vllancre + w-processa.vllanmto
                         tot_vllancre = tot_vllancre + w-processa.vllanmto.

             
             IF   LAST-OF(w-processa.nrdconta) THEN
                  DO:
                      DISPLAY STREAM str_2 sub_vllandeb sub_vllancre
                                           WITH FRAME f_total_lancamento.

                      ASSIGN sub_vllancre = 0
                             sub_vllandeb = 0.
             END.
                  
             IF   LAST-OF(w-processa.cdsituac) THEN
                  DO:
                      DISPLAY STREAM str_2 tot_vllandeb tot_vllancre
                                           WITH FRAME f_totalgeral_lancamento.

                      ASSIGN tot_vllancre = 0
                             tot_vllandeb = 0.
             END.
    END.
    ELSE
         DO:
             DISPLAY STREAM str_2 w-processa.dshistor w-processa.indebcre
                                  w-processa.nrdctabb w-processa.nrdocmto
                                  w-processa.dtrefere w-processa.vllanmto 
                                  w-processa.dscritic WITH FRAME f_rejeitados.
              
             DOWN STREAM str_2 WITH FRAME f_rejeitados.

             ASSIGN tot_rejeitad = tot_rejeitad + 1
                    vlr_rejeitad = vlr_rejeitad + w-processa.vllanmto.
    END.
         
    ASSIGN tot_recebido = tot_recebido + 1
           vlr_recebido = vlr_recebido + w-processa.vllanmto.
                              
END.

DISPLAY STREAM str_2 tot_recebido tot_integrad tot_rejeitad
                     vlr_recebido vlr_integrad vlr_rejeitad
                     WITH FRAME f_totais.

OUTPUT STREAM str_2 CLOSE.

ASSIGN glb_nrcopias = 1
       glb_nmformul = "132col"
       glb_nmarqimp = aux_nmarqimp.
              
RUN fontes/imprim.p.

RUN fontes/fimprg.p.

PROCEDURE cria_integrado:

   FIND craphis WHERE craphis.cdcooper = glb_cdcooper   AND
                      craphis.cdhistor = IF    aux_indebcre= "D"  THEN   
                                              446
                                         ELSE 440
                      NO-LOCK NO-ERROR.
   CREATE w-processa.
   ASSIGN w-processa.cdlanmto = aux_cdlanmto
          w-processa.cdsituac = 1
          w-processa.nrdconta = aux_nrdconta
          w-processa.nmprimtl = crapass.nmprimtl
          w-processa.nrdctabb = aux_nrdctabb
          w-processa.dshistor = STRING(craphis.cdhistor) + "-" +
                                craphis.dshistor
          w-processa.tplanmto = aux_indebcre
          w-processa.vllanmto = aux_vllanmto
          w-processa.nrdocmto = aux_nrdocmto
          w-processa.dtrefere = aux_dtrefere
          w-processa.vllandeb = IF   aux_indebcre = "D" THEN
                                     aux_vllanmto
                                ELSE 0
          w-processa.vllancre = IF   aux_indebcre = "C" THEN
                                     aux_vllanmto
                                ELSE 0.

END PROCEDURE.


PROCEDURE cria_rejeitado:

   DEF INPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
   
   CREATE w-processa.
   ASSIGN w-processa.cdlanmto = aux_cdlanmto
          w-processa.cdsituac = 2
          w-processa.nrdctabb = aux_nrdctabb
          w-processa.dtmvtolt = aux_dtmvtolt
          w-processa.tplanmto = aux_indebcre
          w-processa.vllanmto = aux_vllanmto
          w-processa.nrdocmto = aux_nrdocmto
          w-processa.dshistor = aux_dshistor
          w-processa.indebcre = aux_indebcre
          w-processa.dscritic = par_dscritic.
          
END PROCEDURE.

/* ......................................................................... */
