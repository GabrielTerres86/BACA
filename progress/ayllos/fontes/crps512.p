/* ............................................................................

   Programa: Fontes/crps512.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Maio/2008.                       Ultima atualizacao: 05/12/2016.

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Integrar arquivos do BANCOOB.
               Emite relatorio 486.
               Rodar na cadeia da Cecred.

   Alteracoes: 05/09/2008 - Ajuste nas Colunas Debito e Credito do rel. (Ze).

               14/10/2008 - Ajuste nas Colunas Debito e Credito do Rel. (Ze).

               19/03/2009 - Ajuste para unificacao dos bancos de dados
                            (Evandro).

               11/08/2010 - Arruamdo erro no relatorio 486. Quando o arquivo
                            de integracao eh importado manualmente, a ultima
                            linha do arquivo não era tratada, ao invés,
                            a penultima linha era tratada novamente gerando
                            duplicidade (Adriano).

               02/12/2010 - Realizado correcao de linhas em branco ao final
                            do arquivo, para nao abortar a execucao (Adriano).

               22/06/2012 - Substituido gncoper por crapcop (Tiago).  

               28/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Andre Euzebio - Supero).   

               13/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)      

               29/09/2014 - Incluso tratamento para incorporacao cooperativa 
                            Concred pela Viacredi (Daniel).

               05/12/2016 - Incorporacao Transulcred (Guilherme/SUPERO)

............................................................................. */

DEF STREAM str_1.   
DEF STREAM str_2.   /* Relatorio */ 

{ includes/var_batch.i } 

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

DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.
DEF        VAR aux_setlinha AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT     INIT 756                      NO-UNDO.
DEF        VAR aux_tplotmov AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_nrdolote AS INT                                   NO-UNDO.
DEF        VAR aux_flgintce AS LOGICAL                               NO-UNDO.
DEF        VAR aux_dtrefere AS DATE                                  NO-UNDO.
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_nrdocmto AS INT                                   NO-UNDO.
DEF        VAR aux_nrdocmt2 AS INT                                   NO-UNDO.
DEF        VAR aux_vllandeb AS CHAR                                  NO-UNDO.
DEF        VAR aux_vllancre AS CHAR                                  NO-UNDO.

DEF BUFFER crabcop FOR crapcop.

DEF TEMP-TABLE w-processa                                            NO-UNDO
    FIELD cdlanmto  AS INTEGER
    FIELD cdsituac  AS INTEGER  /* 1 - Integrado, 2 - Rejeitado */ 
    FIELD nrdconta  AS INTEGER
    FIELD nmprimtl  AS CHAR
    FIELD dtmvtolt  AS DATE
    FIELD dtrefere  AS DATE
    FIELD tplanmto  AS CHAR     /* Debito, Credito */      
    FIELD dshistor  AS CHAR
    FIELD dscritic  AS CHAR
    FIELD vllanmto  AS DEC
    FIELD vllandeb  AS DEC
    FIELD vllancre  AS DEC
    FIELD cdagecop  AS INT 
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
     w-processa.dtrefere   FORMAT "99/99/9999"        
     w-processa.dshistor   FORMAT "x(17)"             
     w-processa.cdlanmto   FORMAT "zzzz,zzz9"          
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

FORM SKIP(1)
     "LANCAMENTOS REJEITADOS:"
     SKIP(1)
     WITH NO-BOX SIDE-LABELS DOWN WIDTH 132 FRAME f_cab_rejeitados.
     
FORM w-processa.cdagecop   FORMAT "zzz9"               LABEL "DOCUMENTO"   " "
     w-processa.dtmvtolt   FORMAT "99/99/9999"         LABEL "DATA MOVIM." " "
     w-processa.tplanmto   FORMAT "x(01)"              LABEL "D/C"         " "
     w-processa.vllanmto   FORMAT "zzz,zzz,zzz,zz9.99" LABEL "VALOR"       " "
     w-processa.dscritic   FORMAT "x(62)"              LABEL "CRITICA"     " "
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
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_total_arquivo.


ASSIGN glb_cdprogra = "crps512"
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


ASSIGN aux_nmarquiv = "integra/2011-EXTD2011_" + 
                           STRING(YEAR(glb_dtmvtolt),"9999") +
                           STRING(MONTH(glb_dtmvtolt),"99") +
                           STRING(DAY(glb_dtmvtolt),"99") + ".TXT"
       aux_flgfirst = TRUE.

IF   SEARCH(aux_nmarquiv) = ? THEN
     DO:
         glb_cdcritic = 182.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                            glb_cdprogra + "' --> '" + glb_dscritic +
                            " >> log/proc_batch.log").
         RETURN.
END.
ELSE
     DO:  /*  Verifica a data do arquivo em todos os registros  */
     
         ASSIGN aux_regexist = TRUE.
 
         INPUT STREAM str_1 FROM VALUE(aux_nmarquiv) NO-ECHO.

         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            IMPORT STREAM str_1 UNFORMATTED aux_setlinha.

            ASSIGN aux_dtrefere = DATE(SUBSTR(aux_setlinha,26,2) + "/" + 
                                       SUBSTR(aux_setlinha,24,2) + "/" + 
                                       SUBSTR(aux_setlinha,20,4)).
            
            IF   aux_setlinha <> ""           AND 
                 aux_dtrefere <> glb_dtmvtolt THEN
                 DO:
                     ASSIGN aux_regexist = FALSE.
                     LEAVE.
            END.
         END.  
         
         INPUT STREAM str_1 CLOSE.
         
         IF   NOT aux_regexist THEN
              DO:
                  glb_cdcritic = 789.
                  RUN fontes/critic.p.
                  UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                    glb_cdprogra + "' --> '" + glb_dscritic +
                                    " >> log/proc_batch.log").
                  
                  /* Troca o nome para err */
                  UNIX SILENT VALUE("mv " + aux_nmarquiv + 
                                    " integra/err-2011-EXTD2011_" + 
                                    STRING(YEAR(glb_dtmvtolt),"9999") +
                                    STRING(MONTH(glb_dtmvtolt),"99") +
                                    STRING(DAY(glb_dtmvtolt),"99")
                                    + ".TXT").
                  RETURN.              
         END.
END.
     

INPUT STREAM str_1 FROM VALUE(aux_nmarquiv) NO-ECHO.

TRANS_1:
    
DO TRANSACTION ON ERROR UNDO TRANS_1, RETURN:

   DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

      SET STREAM str_1 aux_setlinha FORMAT "x(45)".
              
      IF   aux_setlinha = "" THEN
           NEXT.

      /*  Verifica se eh Agencia da CECRED  */ 
      IF   INT(SUBSTR(aux_setlinha,1,4)) <> crabcop.cdagebcb  THEN
           DO:
               RUN cria_rejeitado 
                   (INPUT "Codigo de Agencia nao pertence a CECRED.").
                
               NEXT.
           END.
   
      /*  Verifica Agencia da Conta Centralizadora  */
      IF   INT(SUBSTR(aux_setlinha,16,4)) = crabcop.cdagebcb  THEN
           DO:
               RUN cria_rejeitado 
                   (INPUT "Codigo de Agencia da Conta " + 
                       "Centralizadora pertence a CECRED.").
               NEXT.
           END.

      /* Verifica cooperativa atraves do Codigo da Agencia */
      FIND FIRST crapcop WHERE crapcop.cdagebcb = INT(SUBSTR(aux_setlinha,16,4))
           NO-LOCK NO-ERROR.
   
      IF   NOT AVAIL crapcop  THEN
           DO:
               RUN cria_rejeitado 
                   (INPUT "Codigo de Agencia da Conta Centralizadora nao " +
                          "encontrado.").
               NEXT.
           END.

      IF  crapcop.cdcooper = 4 THEN DO:  /* CONCREDI */

          /* Verifica cooperativa atraves do Codigo da Agencia */
          FIND FIRST crapcop WHERE crapcop.cdcooper = 1
             NO-LOCK NO-ERROR.

          IF  NOT AVAIL crapcop  THEN DO:
              RUN cria_rejeitado 
                   (INPUT "Codigo de Agencia da Conta Centralizadora nao " +
                          "encontrado.").
              NEXT.
          END.
      END.
      ELSE
      IF  crapcop.cdcooper = 15 THEN DO:  /* CREDIMILSUL */
 
          /* Verifica cooperativa atraves do Codigo da Agencia */
          FIND FIRST crapcop WHERE crapcop.cdcooper = 13
             NO-LOCK NO-ERROR.
       
          IF  NOT AVAIL crapcop  THEN DO:
              RUN cria_rejeitado 
                  (INPUT "Codigo de Agencia da Conta Centralizadora nao " +
                         "encontrado.").
              NEXT.
          END.
      END.
      ELSE
      IF  crapcop.cdcooper = 17 THEN DO:  /* TRANSULCRED */

          /* Verifica cooperativa atraves do Codigo da Agencia */
          FIND FIRST crapcop WHERE crapcop.cdcooper = 9
               NO-LOCK NO-ERROR.
       
          IF  NOT AVAIL crapcop  THEN DO:
              RUN cria_rejeitado 
                  (INPUT "Codigo de Agencia da Conta Centralizadora nao " +
                         "encontrado.").
              NEXT.
          END.
      END.



      ASSIGN aux_flgintce = FALSE
             aux_nrdocmto = INT(SUBSTR(aux_setlinha,16,4)).

      /* Varre Contas Centralizadoras desta Agencia(cooperativa) */ 
      FOR EACH gnctace
         WHERE gnctace.cdcooper = crapcop.cdcooper
           AND gnctace.cddbanco = aux_cdbccxlt      NO-LOCK:

          IF  INT(SUBSTR(STRING(gnctace.cdageban,"zzzz9"),1,4)) =               crapcop.cdagebcb THEN DO:

              IF  gnctace.flgintce THEN DO:
                  aux_flgintce = TRUE.
                  LEAVE.
              END.
          END.
      END.
   
      IF  NOT aux_flgintce  THEN DO:
          RUN cria_rejeitado
              (INPUT "Conta nao habilitada para integralizacao.").

          NEXT.
      END.
   
      FIND crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                         crapass.nrdconta = crapcop.nrctactl NO-LOCK NO-ERROR.
   
      IF   NOT AVAIL crapass  THEN
           DO:
               RUN cria_rejeitado 
                   (INPUT "Conta/dv nao cadastrada na Cooperativa.").
                                
               NEXT.
           END.
   
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

                  IF CAN-FIND(craplot WHERE craplot.cdcooper = glb_cdcooper AND
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
   
      ASSIGN aux_nrdocmt2 = aux_nrdocmto.
                        
      DO WHILE TRUE:

         FIND craplcm WHERE craplcm.cdcooper = glb_cdcooper      AND
                            craplcm.dtmvtolt = craplot.dtmvtolt  AND
                            craplcm.cdagenci = craplot.cdagenci  AND
                            craplcm.cdbccxlt = craplot.cdbccxlt  AND
                            craplcm.nrdolote = craplot.nrdolote  AND
                            craplcm.nrdctabb = crapcop.nrctactl  AND
                            craplcm.nrdocmto = aux_nrdocmt2     
                            USE-INDEX craplcm1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   AVAILABLE craplcm THEN
              aux_nrdocmt2 = (aux_nrdocmt2 + 10000).
         ELSE
              LEAVE.
          
      END.  /*  Fim do DO WHILE TRUE  */

      ASSIGN aux_nrdocmto = aux_nrdocmt2.
      
        
      CREATE craplcm.
      ASSIGN craplcm.cdcooper = glb_cdcooper 
             craplcm.nrdconta = crapcop.nrctactl
             craplcm.nrdctabb = crapcop.nrctactl
             craplcm.dtmvtolt = craplot.dtmvtolt
             craplcm.dtrefere = craplot.dtmvtolt
             craplcm.cdagenci = craplot.cdagenci
             craplcm.cdbccxlt = craplot.cdbccxlt
             craplcm.nrdolote = craplot.nrdolote
             craplcm.nrdocmto = aux_nrdocmto
             craplcm.cdhistor = IF   SUBSTR(aux_setlinha,28,1) = "D" THEN
                                     545
                                ELSE 544
             craplcm.vllanmto = DEC(SUBSTR(aux_setlinha,29,17)) / 100
             craplcm.nrseqdig = craplot.nrseqdig + 1.
      VALIDATE craplcm.

      ASSIGN craplot.qtinfoln = craplot.qtinfoln + 1
             craplot.qtcompln = craplot.qtcompln + 1
             craplot.nrseqdig = craplcm.nrseqdig.
             
      

             /****  Valores Invertidos ****/

             IF   SUBSTR(aux_setlinha,28,1) = "D" THEN
                  ASSIGN craplot.vlinfocr = craplot.vlinfocr + craplcm.vllanmto
                         craplot.vlcompcr = craplot.vlcompcr + craplcm.vllanmto.
             ELSE 
                  ASSIGN craplot.vlinfodb = craplot.vlinfodb + craplcm.vllanmto
                         craplot.vlcompdb = craplot.vlcompdb + craplcm.vllanmto.

       RUN cria_integrado.
    
      
   END. /* DO WHILE TRUE */
   
END. /* DO TRANSACTION */

        
INPUT STREAM str_1 CLOSE.

/* Renameia o arquivo antes de salva-lo  */
aux_nmarquiv = "integra/2011-EXTD2011_" + 
                        STRING(YEAR(glb_dtmvtolt),"9999") +
                        STRING(MONTH(glb_dtmvtolt),"99") +
                        STRING(DAY(glb_dtmvtolt),"99") + 
                        ".TXT".
                           
/* Move arquivo para o diretorio salvar */
UNIX SILENT VALUE ("mv " + aux_nmarquiv + " salvar").
                            
/* GERAR RELATORIO */

ASSIGN aux_nmarqimp    = "rl/crrl486.lst"
       glb_cdrelato[2] = 486.
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
                                  w-processa.cdlanmto  aux_vllandeb
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
             DISPLAY STREAM str_2 w-processa.cdagecop  w-processa.dtmvtolt
                                  w-processa.tplanmto  w-processa.vllanmto
                                  w-processa.dscritic  WITH FRAME f_rejeitados.
              
             DOWN STREAM str_2 WITH FRAME f_rejeitados.

             ASSIGN tot_rejeitad = tot_rejeitad + 1
                    vlr_rejeitad = vlr_rejeitad + w-processa.vllanmto.
         END.
         
    ASSIGN tot_recebido = tot_recebido + 1
           vlr_recebido = vlr_recebido + w-processa.vllanmto.
                              
END.

DISPLAY STREAM str_2 tot_recebido tot_integrad tot_rejeitad
                     vlr_recebido vlr_integrad vlr_rejeitad
                     WITH FRAME f_total_arquivo.

OUTPUT STREAM str_2 CLOSE.
                            
ASSIGN glb_nrcopias = 1
       glb_nmformul = "132col"
       glb_nmarqimp = aux_nmarqimp.
           
RUN fontes/imprim.p.
                   
RUN fontes/fimprg.p.
 

PROCEDURE cria_integrado:

   FIND craphis WHERE craphis.cdcooper = glb_cdcooper   AND
                      craphis.cdhistor = IF SUBSTR(aux_setlinha,28,1) = "D"
                                            THEN  545
                                         ELSE 544
                      NO-LOCK NO-ERROR.
                                         
   CREATE w-processa.
   ASSIGN w-processa.cdlanmto = aux_nrdocmto
          w-processa.cdsituac = 1
          w-processa.nrdconta = crapcop.nrctactl
          w-processa.nmprimtl = crapass.nmprimtl
          w-processa.dtrefere = DATE(SUBSTR(aux_setlinha,12,2) + "/" + 
                                     SUBSTR(aux_setlinha,10,2) + "/" + 
                                     SUBSTR(aux_setlinha,06,4))
          w-processa.dshistor = STRING(craphis.cdhistor) + "-" +
                                craphis.dshistor
          w-processa.vllanmto = DEC(SUBSTR(aux_setlinha,29,17)) / 100
           
          /****  Valores Invertidos ****/
          w-processa.tplanmto = IF   SUBSTR(aux_setlinha,28,1) = "D" THEN
                                     "C"
                                ELSE "D"
          w-processa.vllancre = IF   SUBSTRING(aux_setlinha,28,1) = "D" THEN
                                     DEC(SUBSTR(aux_setlinha,29,17)) / 100
                                ELSE 0
          w-processa.vllandeb = IF   SUBSTRING(aux_setlinha,28,1) = "C" THEN
                                     DEC(SUBSTR(aux_setlinha,29,17)) / 100
                                ELSE 0.
END.


PROCEDURE cria_rejeitado:

   DEF INPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
   
   CREATE w-processa.
   ASSIGN w-processa.cdlanmto = aux_nrdocmto
          w-processa.cdsituac = 2
          w-processa.dtrefere = DATE(SUBSTR(aux_setlinha,26,2) + "/" + 
                                     SUBSTR(aux_setlinha,24,2) + "/" + 
                                     SUBSTR(aux_setlinha,20,4))
          w-processa.cdagecop = INT(SUBSTR(aux_setlinha,16,4))
          w-processa.dtmvtolt = DATE(SUBSTR(aux_setlinha,12,2) + "/" + 
                                     SUBSTR(aux_setlinha,10,2) + "/" + 
                                     SUBSTR(aux_setlinha,6,4))
          w-processa.vllanmto = DEC(SUBSTRING(aux_setlinha,29,17)) / 100
          w-processa.dscritic = par_dscritic
          
          /****  Valores Invertidos ****/
          w-processa.tplanmto = IF   SUBSTR(aux_setlinha,28,1) = "D" THEN
                                     "C"
                                ELSE "D"

          w-processa.nrdconta = 0
          w-processa.vllandeb = 0
          w-processa.vllancre = 0.
          
END PROCEDURE.

/* ......................................................................... */
