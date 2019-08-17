/* ..........................................................................

   Programa: Fontes/crps449.p  
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Ze Eduardo/Mirtes/Julio
   Data    : Maio/2005.                         Ultima atualizacao: 13/07/2018

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atender a solicitacao 
               Gerar arquivo de arrecadacao unico para todas as cooperativas,
               conforme convenios cadastrados.
               Emite relatorio 387
               Solicitacao 1. Ordem 6.
   
   Alteracoes : 23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                             crapcop.cdcooper = glb_cdcooper (Diego).

               13/01/2006 - Tratamento para email's em branco (Julio)

               15/02/2006 - Alteracao da senha dos arquivos Casa Feliz (Julio)
               
               17/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               27/11/2006 - Acertar envio de email pela BO b1wgen0011 (David).
               
               01/06/2007 - Incluido possibilidade de envio de arquivo para
                            Accestage (Elton).
                            
               21/08/2007 - Tarifa para pagamento faturas pac 90(Guilherme).
               
               02/06/2010 - Alteraçao do campo "pkzip25" para "zipcecred.pl" 
                           (Vitor).
                           
               04/06/2010 - Tratamento para PAC 91 - TAA (Elton).

               23/01/2012 - Tratamento para Unificacao Arq. Convenios
                            (Guilherme/Supero)
               
               12/04/2012 - Tratamento para faturas de DARE e GNRE do convenio 
                            SEFAZ (Elton).
                            
               30/05/2012 - Somente gera arquivo sem movimento se convenio 
                            estiver ativo;
                          - Acerto no registro "Z" do arquivo quando nao existe
                            movimento de faturas (Elton).
                            
               02/07/2012 - Substituido 'gncoper' por 'crapcop' (Tiago).    
               
               03/07/2012 - Alterado nomeclatura do relatório gerado incluindo 
                            código do convenio (Guilherme Maba). 
               
               09/09/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               10/01/2014 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)
                            
               27/11/2014 - Tratamento convenio TPA. (Fabricio)
               
               28/11/2014 - Implementacao Van E-Sales (utilizacao inicial pela
                            Oi). (Chamado 192004) - (Fabricio)
                            
               07/04/2015 - Transferido Logs para o proc_message ao inves de
                            proc_batch, deixando apenas qdo nao encontrar 
                            cooperativa (SD273503 - Tiago).
                            
               08/05/2015 - Tratamento PREVISUL procedure 
                            efetua_geracao_arquivos_debitos. 
                            (Chamado 283473) - (Fabricio)
                            
               23/09/2015 - Tratamento para o convenio Unifique Schroeder 
                            procedure efetua_geracao_arquivos_debitos
                            (Lucas Ranghetti #297623)
                                                        
               24/03/2016 - Exclusao do relatório 387.
                            (RKAM - Gisele Campos Neves #421009) 
                            
               12/04/2016 - Correcao exclusao relatorio 387 (Lucas Ranghetti/Fabricio)  
               
                           23/06/2016 - P333.1 - Devoluçao de arquivos com tipo de envio 
                                        6 - WebService (Marcos)                          

               15/06/2016 - Adicnioar ux2dos para a Van E-sales (Lucas Ranghetti #469980)
               
               14/10/2016 - Adicionar ordecacao para o registro "B" tpdcontr = 3, listar 
                            primeiro os cancelados (Lucas Ranghetti #506030)
                            
               08/11/2017 - Alterar para gravar a versao do layout de debito dinamicamente no 
                            header do arquivo (Lucas Ranghetti #789879)
                            
               13/07/2018 - Remover parte do programa onde buscava registro que iria alimentar
                            o relatorio antigo, hoje ja nao existe mais relatório.
                            (Lucas Ranghetti PRB0040176)
............................................................................. */

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

DEF        VAR b1wgen0011       AS HANDLE                            NO-UNDO.

DEF        VAR aux_nmmesano AS CHAR    EXTENT 12 INIT
                                       [" JANEIRO ","FEVEREIRO",
                                        "  MARCO  ","  ABRIL  ",
                                        "  MAIO   ","  JUNHO  ",
                                        " JULHO   "," AGOSTO  ",
                                        "SETEMBRO "," OUTUBRO ",
                                        "NOVEMBRO ","DEZEMBRO "]     NO-UNDO.

DEF  VAR aux_nmarqdat    AS CHAR     FORMAT "x(20)"                 NO-UNDO.
DEF  VAR aux_nmarqped    AS CHAR     FORMAT "x(20)"                 NO-UNDO.
DEF  VAR aux_dtmvtolt    AS CHAR                                    NO-UNDO.
DEF  VAR aux_dtmvtopr    AS CHAR                                    NO-UNDO.
DEF  VAR aux_dtproxim    AS DATE                                    NO-UNDO.
DEF  VAR aux_anomovto    AS CHAR     FORMAT "x(05)"                 NO-UNDO.
DEF  VAR aux_diamovto    AS INT      FORMAT "99"                    NO-UNDO.
DEF  VAR aux_mesmovto    AS CHAR     FORMAT "x(09)"                 NO-UNDO.
DEF  VAR aux_vltarifa    AS DECIMAL                                 NO-UNDO.
DEF  VAR aux_dtproces    AS DATE                                    NO-UNDO.
DEF  VAR aux_nmdirdes    AS CHAR                                    NO-UNDO.

DEF VAR aux_qtpalavr AS INTE.
DEF VAR aux_contapal AS INTE.

DEF  VAR  aux_nmempcov   AS CHAR     FORMAT "x(20)"                 NO-UNDO.
DEF  VAR  aux_nrconven   AS CHAR     FORMAT "x(20)"                 NO-UNDO.
DEF  VAR  aux_nrseqarq   AS INT      FORMAT "999999"                NO-UNDO.
DEF  VAR  aux_flgfirst   AS LOGICAL                                 NO-UNDO.
DEF  VAR  aux_flaglast   AS LOGICAL                                 NO-UNDO.
DEF  VAR  aux_nrseqdig   AS INTEGER                                 NO-UNDO.
DEF  VAR  aux_nmarqrel   AS CHAR                                    NO-UNDO.

DEF  VAR  tot_vlfatura   AS DECIMAL                                 NO-UNDO.
DEF  VAR  aux_nrsequen   AS CHAR                                    NO-UNDO.
DEF  VAR  aux_nroentries AS INTE                                    NO-UNDO.
DEF  VAR  aux_dsdemail   AS CHAR                                    NO-UNDO.
DEF  VAR  aux_dsemail2   AS CHAR                                    NO-UNDO.

DEF  VAR  rel_nmrescop   AS CHAR     EXTENT 2                       NO-UNDO.
DEF  VAR  aux_nmdbanco   AS CHAR                                    NO-UNDO.
DEF  VAR  aux_nrdbanco   AS INT   FORMAT "999"                      NO-UNDO.

DEF  VAR  aux_dtanteri   AS DATE                                    NO-UNDO.
DEF  VAR  aux_nmcidade   AS CHAR                                    NO-UNDO.
DEF  VAR  aux_nmempres   AS CHAR  FORMAT "x(20)"                    NO-UNDO.
DEF  VAR  aux_nrbranco   AS INT                                     NO-UNDO.

DEF  VAR  aux_contador    AS INT                                    NO-UNDO.
DEF  VAR  aux_contatip    AS INT                                    NO-UNDO.
DEF  VAR  aux_cdpestit    AS CHAR                                   NO-UNDO.
DEF  VAR  tot_vlorpago    AS DECIMAL                                NO-UNDO.
DEF  VAR  tot_vltitulo    AS DECIMAL                                NO-UNDO.

DEF  VAR  rel_vllanmto    AS DECIMAL                                NO-UNDO.

DEF  VAR  aux_exisdare    AS LOGICAL                                NO-UNDO. 
DEF  VAR  aux_exisgnre    AS LOGICAL                                NO-UNDO. 

DEF  BUFFER gbconve     FOR gnconve.
DEF  BUFFER crabcop     FOR crapcop.

DEF  STREAM str_2.  /* Para arquivo auxiliar */

ASSIGN glb_cdprogra = "crps449"
       glb_cdempres = 11
       glb_flgbatch = false
       glb_cdcooper = 3.

RUN fontes/iniprg.p.
/*
IF   glb_cdcritic > 0 THEN
     RETURN.
*/
glb_cdcooper = 3.

FIND crabcop WHERE crabcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crabcop   THEN
     DO:
         ASSIGN glb_cdcritic = 057.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                            " - " + glb_cdprogra + "' --> '" + glb_dscritic +
                            " >> log/proc_batch.log").
         RETURN.
     END.

ASSIGN aux_nmcidade = TRIM(crabcop.nmcidade).

glb_dtmvtolt = 06/11/2019.
glb_dtmvtopr = 06/12/2019.

aux_dtproxim = glb_dtmvtopr + 1.

DO WHILE TRUE:          /*  Procura pela proxima data */

   IF   NOT CAN-DO("1,7",STRING(WEEKDAY(aux_dtproxim))) AND
        NOT CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper AND
                                   crapfer.dtferiad = aux_dtproxim)  THEN
        LEAVE.

   aux_dtproxim = aux_dtproxim + 1.

END.  /*  Fim do DO WHILE TRUE  */

ASSIGN aux_dtmvtolt = STRING(YEAR(glb_dtmvtolt),"9999") +
                      STRING(MONTH(glb_dtmvtolt),"99")  +
                      STRING(DAY(glb_dtmvtolt),"99")

       aux_dtmvtopr = STRING(YEAR(aux_dtproxim),"9999") +
                      STRING(MONTH(aux_dtproxim),"99")  +
                      STRING(DAY(aux_dtproxim),"99")

       aux_diamovto = DAY(aux_dtproxim)
       aux_mesmovto = aux_nmmesano[MONTH(aux_dtproxim)]
       aux_anomovto = STRING(YEAR(aux_dtproxim),"9999") + ".".



ASSIGN aux_dtanteri = glb_dtmvtolt - 5. 

DO aux_contatip = 1 TO 3:
/* 1-Caixa / 2-Debito / 3-Autoriz. Debito */

    ASSIGN  aux_flgfirst = FALSE
            aux_exisdare = FALSE
            aux_exisgnre = FALSE. 

    IF  aux_contatip = 1 OR 
        aux_contatip = 2 THEN
        DO:        
    FOR EACH gncvuni WHERE NOT gncvuni.flgproce
                       AND gncvuni.tpdcontr = aux_contatip
                     BREAK BY gncvuni.cdconven 
                           BY gncvuni.cdcooper:
        
        IF   FIRST-OF(gncvuni.cdconven) THEN
             DO:
                 FIND gnconve WHERE gnconve.cdconven = gncvuni.cdconven
                                    NO-LOCK NO-ERROR.
        
                 IF   AVAILABLE gnconve   THEN
                      DO:
                          ASSIGN aux_nmempres = TRIM(gnconve.nmempres)
                                 aux_nrbranco = 10 - 
                                               ROUND(LENGTH(aux_nmempres) / 2,0)
                                 aux_nmempres = FILL(" ", aux_nrbranco) + 
                                                aux_nmempres                   
                                 aux_flgfirst = TRUE
                                 aux_nrseqdig = 0
                                 tot_vlfatura = 0.
           
                          glb_dscritic = "Executando Convenio - " + 
                                         STRING(aux_nmempres).
            
                          UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999") 
                                             + " - " + STRING(TIME,"HH:MM:SS")   
                                             + " - " + glb_cdprogra + "' --> '"  
                                             + glb_dscritic + " >> log/proc_message.log").
                      END. /* IF AVAILABLE gnconve */
    
                 ASSIGN aux_flaglast = FALSE.

                 /** Verifica se existem guias da SEFAZ **/
                 IF   gncvuni.cdconven = 59 THEN     /** DARE **/
                      DO:
                         ASSIGN aux_exisdare = TRUE.
                      END.
                 ELSE 
                 IF   gncvuni.cdconven = 60 THEN    /** GNRE **/
                      DO:
                          ASSIGN aux_exisgnre = TRUE.
                      END.                       
             
             END. /* IF FIRST-OF... */
    
        IF   FIRST-OF(gncvuni.cdcooper)   THEN
             DO:
                 FIND crapcop WHERE crapcop.cdcooper = gncvuni.cdcooper
                                    NO-LOCK NO-ERROR.
        
                 IF   NOT AVAILABLE crapcop   THEN
                      DO:
                          glb_cdcritic = 651.
                          RUN fontes/critic.p.
                          UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")
                                             + " - " + STRING(TIME,"HH:MM:SS") 
                                             + " - " + glb_cdprogra + "' --> '" 
                                             + glb_dscritic + " >> log/proc_message.log").
                          UNDO, RETURN.                   
                      END. /* IF AVAILABLE crapcop */
             END.
             
        IF   LAST-OF(gncvuni.cdconven)   THEN     
             ASSIGN aux_flaglast = TRUE.
             
        CASE gncvuni.tpdcontr:
            WHEN 1 THEN RUN efetua_geracao_arquivos.             /* Caixa */
            WHEN 2 THEN RUN efetua_geracao_arquivos_debitos.     /* Deb.Autom. */
                END CASE.
            
            END. /* FOR EACH gncvuni */
        END.
    ELSE
        DO:
            /* Listar primeiro os cancelamentos para o registro "B" tpdcontr = 3 
               Posicao (150,1)  1 - cancelamento / 2 - Inclusao */
            FOR EACH gncvuni WHERE NOT gncvuni.flgproce
                               AND gncvuni.tpdcontr = aux_contatip
                             BREAK BY gncvuni.cdconven 
                                   BY SUBSTRING(gncvuni.dsmovtos,150,1)
                                   BY gncvuni.cdcooper:
                
                IF   FIRST-OF(gncvuni.cdconven) THEN
                     DO:
                         FIND gnconve WHERE gnconve.cdconven = gncvuni.cdconven
                                            NO-LOCK NO-ERROR.
                
                         IF   AVAILABLE gnconve   THEN
                              DO:
                                  ASSIGN aux_nmempres = TRIM(gnconve.nmempres)
                                         aux_nrbranco = 10 - 
                                                       ROUND(LENGTH(aux_nmempres) / 2,0)
                                         aux_nmempres = FILL(" ", aux_nrbranco) + 
                                                        aux_nmempres                   
                                         aux_flgfirst = TRUE
                                         aux_nrseqdig = 0
                                         tot_vlfatura = 0.
                   
                                  glb_dscritic = "Executando Convenio - " + 
                                                 STRING(aux_nmempres).
                    
                                  UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999") 
                                                     + " - " + STRING(TIME,"HH:MM:SS")   
                                                     + " - " + glb_cdprogra + "' --> '"  
                                                     + glb_dscritic + " >> log/proc_message.log").
                              END. /* IF AVAILABLE gnconve */
            
                         ASSIGN aux_flaglast = FALSE.

                         /** Verifica se existem guias da SEFAZ **/
                         IF   gncvuni.cdconven = 59 THEN     /** DARE **/
                              DO:
                                 ASSIGN aux_exisdare = TRUE.
                              END.
                         ELSE 
                         IF   gncvuni.cdconven = 60 THEN    /** GNRE **/
                              DO:
                                  ASSIGN aux_exisgnre = TRUE.
                              END.                       
                     
                     END. /* IF FIRST-OF... */
            
                IF   FIRST-OF(gncvuni.cdcooper)   THEN
                     DO:
                         FIND crapcop WHERE crapcop.cdcooper = gncvuni.cdcooper
                                            NO-LOCK NO-ERROR.
                
                         IF   NOT AVAILABLE crapcop   THEN
                              DO:
                                  glb_cdcritic = 651.
                                  RUN fontes/critic.p.
                                  UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")
                                                     + " - " + STRING(TIME,"HH:MM:SS") 
                                                     + " - " + glb_cdprogra + "' --> '" 
                                                     + glb_dscritic + " >> log/proc_message.log").
                                  UNDO, RETURN.                   
                              END. /* IF AVAILABLE crapcop */
                     END.
                     
                IF   LAST-OF(gncvuni.cdconven)   THEN     
                     ASSIGN aux_flaglast = TRUE.
                     
                CASE gncvuni.tpdcontr:                    
            WHEN 3 THEN RUN efetua_geracao_arquivos_autorizacao. /* Autoriz. Debito */
        END CASE.
    
    END. /* FOR EACH gncvuni */
        END.
    
    IF  aux_contatip = 1        AND
        aux_exisdare = FALSE    THEN
        DO:
            RUN gera_arquivo_sem_movimento (INPUT 59).
        END.

    IF  aux_contatip = 1        AND
        aux_exisgnre = FALSE   THEN
        DO:
            RUN gera_arquivo_sem_movimento (INPUT 60).
        END.
    
END. /* FIM do DO aux_contatip = 1 ... */

RUN fontes/fimprg.p.

/*--- PROCEDURES INTERNAS ---*/

PROCEDURE efetua_geracao_arquivos:

   IF   aux_flgfirst THEN
        DO:
            RUN nomeia_arquivos.
                
            OUTPUT STREAM str_2 TO VALUE(aux_nmarqped). 

            ASSIGN aux_nmempcov = gnconve.nmempres.

            PUT STREAM str_2  "A2"   aux_nrconven FORMAT "99999999"
                              "            "
                              aux_nmempcov  FORMAT "x(20)" 
                              aux_nrdbanco  FORMAT "999" 
                              aux_nmdbanco  FORMAT "x(20)"
                              aux_dtmvtolt  FORMAT "x(08)" 
                              aux_nrseqarq  FORMAT "999999"
                              "03ARRECADACAO CAIXA" 
                              "                              "
                              "                      " SKIP.

            aux_flgfirst = FALSE.
        END.

   ASSIGN aux_nrseqdig = aux_nrseqdig + 1
          rel_vllanmto = DECI(SUBSTR(gncvuni.dsmovtos, 82, 12)) / 100
          tot_vlfatura = tot_vlfatura + rel_vllanmto.          

   PUT STREAM str_2 SUBSTR(gncvuni.dsmovtos, 1, 100) FORMAT "x(100)"  
                    aux_nrseqdig FORMAT "99999999"         
                    SUBSTR(gncvuni.dsmovtos, 109, 42) FORMAT "x(42)" SKIP.
                    
   ASSIGN gncvuni.flgproce = TRUE.                 
                
   IF   aux_flaglast THEN
        DO:
            PUT STREAM str_2
                 "Z" STRING(aux_nrseqdig + 2, "999999") FORMAT "x(06)"
                     STRING(tot_vlfatura * 100, "99999999999999999") 
                     FORMAT "x(17)"
                     "                                        "
                     "                                        "
                     "                                              " SKIP.

            OUTPUT STREAM str_2 CLOSE.

            RUN atualiza_controle ('G').

        END.  /* Fim do flaglast */
  
END PROCEDURE.

/* ......................................................................... */

PROCEDURE obtem_atualiza_sequencia:

    DO TRANSACTION:

        /* Verificar arquivo controle - se existir nao somar seq. */

        DO WHILE TRUE:

           FIND gbconve WHERE RECID(gbconve) = RECID(gnconve)
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF   NOT AVAILABLE gbconve   THEN
                IF   LOCKED gbconve  THEN
                     DO:
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                ELSE
                     DO:
                         glb_cdcritic = 151.
                         RUN fontes/critic.p.
                         UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999")
                                           + " - " + STRING(TIME,"HH:MM:SS") 
                                           + " - " + glb_cdprogra + "' --> '" 
                                           + glb_dscritic + " >> log/proc_message.log").
                         UNDO, RETURN.
                      END.
           LEAVE.

        END. /* do while true */  


        CASE aux_contatip: 
            WHEN 1 THEN DO: /* CAIXA */
                ASSIGN aux_nrseqarq     = gbconve.nrseqcxa
                       gbconve.nrseqcxa = gbconve.nrseqcxa + 1.
    
                CREATE gncontr.
                ASSIGN gncontr.cdcooper = 3
                       gncontr.tpdcontr = 1
                       gncontr.cdconven = gnconve.cdconven 
                       gncontr.dtmvtolt = glb_dtmvtolt 
                       gncontr.nrsequen = aux_nrseqarq.
            END.

            WHEN 2 THEN DO: /* Deb Autom. */
                ASSIGN aux_nrseqarq     = gbconve.nrseqatu
                       gbconve.nrseqatu = gbconve.nrseqatu + 1.
    
                CREATE gncontr.
                ASSIGN gncontr.cdcooper = 3
                       gncontr.tpdcontr = 4
                       gncontr.cdconven = gnconve.cdconven 
                       gncontr.dtmvtolt = glb_dtmvtopr 
                       gncontr.nrsequen = aux_nrseqarq.
            END.

            WHEN 3 THEN DO: /* Autoriz. Debito */
                ASSIGN aux_nrseqarq     = gbconve.nrseqatu
                       gbconve.nrseqatu = gbconve.nrseqatu + 1.
    
                CREATE gncontr.
                ASSIGN gncontr.cdcooper = 3
                       gncontr.tpdcontr = 2
                       gncontr.cdconven = gnconve.cdconven 
                       gncontr.dtmvtolt = glb_dtmvtolt 
                       gncontr.nrsequen = aux_nrseqarq.
            END.

        END CASE.
        
        VALIDATE gncontr.
        RELEASE gbconve.

    END.

END PROCEDURE.         

/* ......................................................................... */

PROCEDURE atualiza_controle:

   DEF INPUT PARAM par_tpdcontr  AS CHAR  NO-UNDO.

   IF  gnconve.tpdenvio = 1   OR   
       gnconve.tpdenvio = 4   OR /* Email */
       gnconve.tpdenvio = 2 THEN /* E-Sales */
       DO:
           RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT
           SET b1wgen0011.
           
           /* ux2dos, converter arquivo para dos/windows */
           RUN converte_arquivo IN b1wgen0011 (INPUT glb_cdcooper,
                                               INPUT aux_nmarqped,
                                               INPUT aux_nmarqdat).
                                               

   IF  gnconve.tpdenvio = 2 THEN /* E-Sales */
       DO:
          ASSIGN glb_cdcritic = 696.
                  /* copiar arquivo convertido para o connect/esales */
                  UNIX SILENT VALUE("cp " + "converte/" + aux_nmarqdat + " /usr/connect/esales/envia/").                  
               END.   
           ELSE
               ASSIGN glb_cdcritic = 657.        /* Intranet - tpdenvio = 1 */
       END.

   IF  gnconve.tpdenvio = 3 THEN /* Nexxera */
       DO:
          ASSIGN glb_cdcritic = 748.
                 
          UNIX SILENT VALUE("cp " + aux_nmarqped  + " /usr/nexxera/envia/").
       END.                 
   
   IF  gnconve.tpdenvio = 5 THEN  /* Accestage */
       DO:
          ASSIGN glb_cdcritic = 905.
              
          UNIX SILENT VALUE("cp " + aux_nmarqped + " salvar").
       END.
   ELSE
       UNIX SILENT VALUE("mv " + aux_nmarqped + " salvar 2> /dev/null").
  
   IF  gnconve.tpdenvio = 6 THEN  /* WebServices */
       DO:
          
          ASSIGN glb_cdcritic = 982.
                  
                  { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} } 
                     
          /* Efetuar a chamada a rotina Oracle  */
          RUN STORED-PROCEDURE pc_armazena_arquivo_conven
              aux_handproc = PROC-HANDLE NO-ERROR (INPUT gnconve.cdconven,
                                                   INPUT glb_dtmvtolt,
                                                   INPUT par_tpdcontr,
                                                                                                   INPUT 0, /* Nao retornado ainda */
                                                   INPUT '/usr/coop/' + crabcop.dsdircop + '/salvar', 
                                                   INPUT aux_nmarqdat,
                                                   OUTPUT 0, 
                                                   OUTPUT "").
          
          /* Fechar o procedimento para buscarmos o resultado */ 
          CLOSE STORED-PROC pc_armazena_arquivo_conven
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

          { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} } 
          
          /* Busca possíveis erros */
          IF pc_armazena_arquivo_conven.pr_cdretorn <> 202 THEN
             DO:
                UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999")
                                 + " - " + STRING(TIME,"HH:MM:SS") 
                                 + " - " + glb_cdprogra + "' --> '" 
                                 + pc_armazena_arquivo_conven.pr_dsmsgret + " - Convenio: "
                                 + STRING(gncvcop.cdconven) + " >> log/proc_message.log").
             END.
       END.
   
   RUN fontes/critic.p.
   
   UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") 
                     + " - " + STRING(TIME,"HH:MM:SS") 
                     + " - " + glb_cdprogra + " >> log/proc_message.log").                

   IF  (gnconve.tpdenvio > 1 AND  gnconve.tpdenvio < 4) OR  
       (gnconve.tpdenvio = 5) OR (gnconve.tpdenvio = 6) THEN  
       DO:
          UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999")
                            + " - " + STRING(TIME,"HH:MM:SS") 
                            + " - " + glb_cdprogra + "' --> '" 
                            + glb_dscritic + " "  + aux_nmarqdat 
                            + " -  Arrecadacao Cx. - " 
                            + gnconve.nmempres + ": _________" 
                            + " >> log/proc_message.log").
       END.
   ELSE
       DO:           
           /* Se Caixa(1) ou Debito(2), muda email */
           IF  gncvuni.tpdcontr = 1 THEN
               aux_dsemail2 = gnconve.dsendcxa.
           ELSE
               aux_dsemail2 = gnconve.dsenddeb.


           ASSIGN aux_nroentries = NUM-ENTRIES(aux_dsemail2)
                  aux_contador   = 1.

           DO WHILE aux_contador LE aux_nroentries:

              ASSIGN aux_dsdemail = TRIM(ENTRY(aux_contador,   
                                               aux_dsemail2)).

              IF   TRIM(aux_dsdemail) = ""   THEN
                   DO:
                       aux_contador = aux_contador + 1.
                       NEXT.
                   END.

              IF   gnconve.tpdenvio = 1   THEN
                   RUN enviar_email IN b1wgen0011
                                        (INPUT glb_cdcooper,
                                         INPUT glb_cdprogra,
                                         INPUT aux_dsdemail,
                                         INPUT "ARQUIVO DE ARRECADACAO DA " +
                                               crabcop.nmrescop,
                                         INPUT aux_nmarqdat,
                                         INPUT false).
              ELSE
              IF   gnconve.tpdenvio = 4   THEN
                   RUN enviar_email IN b1wgen0011
                                        (INPUT glb_cdcooper,
                                         INPUT glb_cdprogra,
                                         INPUT aux_dsdemail,
                                         INPUT "ARQUIVO DE ARRECADACAO DA " +
                                               crabcop.nmrescop,
                                         INPUT aux_nmarqdat + ".zip",
                                         INPUT true).
                
              ASSIGN aux_contador = aux_contador + 1.
           END.     

           DELETE PROCEDURE b1wgen0011.
       END.

   UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999")
                     + " - " + STRING(TIME,"HH:MM:SS") 
                     + " - " + glb_cdprogra + " >> log/proc_message.log").
              
   DO TRANSACTION:

       DO WHILE TRUE:

          FIND crapres WHERE crapres.cdcooper = glb_cdcooper AND
                             crapres.cdprogra = glb_cdprogra
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF   NOT AVAILABLE crapres   THEN
               IF   LOCKED crapres   THEN
                    DO:
                       PAUSE 1 NO-MESSAGE.
                       NEXT.
                    END.
               ELSE
                    DO:
                       glb_cdcritic = 151.
                       RUN fontes/critic.p.
                       UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999")
                                         + " - " + STRING(TIME,"HH:MM:SS") 
                                         + " - " + glb_cdprogra + "' --> '" 
                                         + glb_dscritic + " >> log/proc_message.log").
                       UNDO, RETURN.
                    END.
               LEAVE.
                    
        END.
                    
        ASSIGN crapres.nrdconta = 999.
   
   END.  /*  Fim da Transacao  */
     
END PROCEDURE. 

/* ......................................................................... */

PROCEDURE nomeia_arquivos:

    DEF VAR aux_nmarquiv   AS CHAR                            NO-UNDO.


    CASE aux_contatip: 
        WHEN 1 THEN DO:    /* Arrec.Caixa */
            aux_nmarquiv = gnconve.nmarqcxa.
    
            FIND gncontr WHERE
                 gncontr.cdcooper = 3                    AND
                 gncontr.tpdcontr = 1                    AND /* Arrec.Caixa */
                 gncontr.cdconven = gnconve.cdconven     AND
                 gncontr.dtmvtolt = glb_dtmvtolt NO-ERROR.
        
            IF  AVAIL gncontr THEN
                ASSIGN aux_nrseqarq = gncontr.nrsequen.               
            ELSE 
                RUN obtem_atualiza_sequencia.
        END.

        WHEN 2 THEN DO:    /* Arrec.Deb.Autom. */
            aux_nmarquiv = gnconve.nmarqdeb.
    
            FIND gncontr WHERE
                 gncontr.cdcooper = 3                    AND
                 gncontr.tpdcontr = 4                    AND /* Arrec.Deb.Autom. */
                 gncontr.cdconven = gnconve.cdconven     AND
                 gncontr.dtmvtolt = glb_dtmvtolt NO-ERROR.
        
            IF  AVAIL gncontr THEN
                ASSIGN aux_nrseqarq = gncontr.nrsequen.               
            ELSE 
                RUN obtem_atualiza_sequencia.
        END.

        WHEN 3 THEN DO: /* Arrec.Autoriz Deb.*/
            aux_nmarquiv = gnconve.nmarqatu.
    
            FIND gncontr WHERE
                 gncontr.cdcooper = 3                    AND
                 gncontr.tpdcontr = 2                    AND /* Autoriz Deb.*/
                 gncontr.cdconven = gnconve.cdconven     AND
                 gncontr.dtmvtolt = glb_dtmvtolt NO-ERROR.
        
            IF  AVAIL gncontr THEN
                ASSIGN aux_nrseqarq = gncontr.nrsequen.               
            ELSE 
                RUN obtem_atualiza_sequencia.
        END.

    END CASE.



   ASSIGN aux_nmdbanco = crabcop.nmrescop 
          aux_nrdbanco = gnconve.cddbanco
          aux_nrconven = gnconve.nrcnvfbr
          aux_nmempcov = gnconve.nmempres.
          
   ASSIGN  aux_nrsequen = STRING(aux_nrseqarq,"999999").

   ASSIGN  aux_nmarqdat = TRIM(SUBSTR(aux_nmarquiv,1,4))  +
                           STRING(MONTH(glb_dtmvtolt),"99")   +
                           STRING(DAY(glb_dtmvtolt),"99")     +  "." +
                           SUBSTR(aux_nrsequen,4,3) .

   IF  SUBSTR(aux_nmarquiv,5,2)  = "MM" AND
       SUBSTR(aux_nmarquiv,7,2)  = "DD" AND
       SUBSTR(aux_nmarquiv,10,3) = "TXT" THEN 
       ASSIGN  aux_nmarqdat = TRIM(SUBSTR(aux_nmarquiv,1,4)) +
                              STRING(MONTH(glb_dtmvtolt),"99")    +
                              STRING(DAY(glb_dtmvtolt),"99")     + ".txt".
  
   IF  SUBSTR(aux_nmarquiv,5,2)  = "DD" AND
       SUBSTR(aux_nmarquiv,7,2)  = "MM" AND
       SUBSTR(aux_nmarquiv,10,3) = "RET" THEN 
       ASSIGN  aux_nmarqdat = TRIM(SUBSTR(aux_nmarquiv,1,4)) +
                              STRING(DAY(glb_dtmvtolt),"99")     +
                              STRING(MONTH(glb_dtmvtolt),"99")   + ".ret".
 
   IF  SUBSTR(aux_nmarquiv,5,2)  = "CP" AND   /* Cooperativa */
       SUBSTR(aux_nmarquiv,7,2)  = "MM" AND
       SUBSTR(aux_nmarquiv,9,2)  = "DD" AND
       SUBSTR(aux_nmarquiv,12,3) = "SEQ" THEN 
       ASSIGN  aux_nmarqdat = TRIM(SUBSTR(aux_nmarquiv,1,4)) +
                              STRING(gnconve.cdcooper,"99")      +
                              STRING(MONTH(glb_dtmvtolt),"99")   +
                              STRING(DAY(glb_dtmvtolt),"99")     +
                              "." +  SUBSTR(aux_nrsequen,4,3).
                                    
   IF  SUBSTR(aux_nmarquiv,4,1)  = "C" AND
       SUBSTR(aux_nmarquiv,5,4)  = "SEQU" AND
       SUBSTR(aux_nmarquiv,10,3) = "RET" THEN 
       ASSIGN  aux_nmarqdat = TRIM(SUBSTR(aux_nmarquiv,1,3)) +
                              STRING(gnconve.cdcooper,"9")       +
                              SUBSTR(aux_nrsequen,3,4) + "."     +
                              "ret".
         
    ASSIGN  aux_nmarqped = "arq/" + aux_nmarqdat.
       
END PROCEDURE.

/* ......................................................................... */

PROCEDURE efetua_geracao_arquivos_debitos:

   IF   aux_flgfirst THEN
        DO:
            RUN nomeia_arquivos.
                
            OUTPUT STREAM str_2 TO VALUE(aux_nmarqped). 

            ASSIGN aux_nmempcov = gnconve.nmempres.

            PUT STREAM str_2 "A2"  
                       aux_nrconven  FORMAT "99999999999999999999"
                       aux_nmempcov  FORMAT "x(20)" 
                       aux_nrdbanco  FORMAT "999"
                       aux_nmdbanco  FORMAT "x(20)"
                       aux_dtmvtolt  FORMAT "x(08)"
                       aux_nrseqarq  FORMAT "999999"
                       gnconve.nrlayout FORMAT "99"
                       "DEBITO AUTOMATICO" 
                       FILL(" ",52) FORMAT "x(52)" SKIP.

            aux_flgfirst = FALSE.
        END.

   ASSIGN aux_nrseqdig = aux_nrseqdig + 1
          rel_vllanmto = DECI(SUBSTR(gncvuni.dsmovtos, 53, 15)) / 100
          tot_vlfatura = tot_vlfatura + rel_vllanmto.
          
          
   PUT STREAM str_2 gncvuni.dsmovtos  FORMAT "x(150)" SKIP.
                    
   ASSIGN gncvuni.flgproce = TRUE.                 
                
   IF   aux_flaglast THEN
        DO:
            PUT STREAM str_2
                 "Z" STRING(aux_nrseqdig + 2, "999999") FORMAT "x(06)"
                     STRING(tot_vlfatura * 100, "99999999999999999") 
                     FORMAT "x(17)"
                     "                                        "
                     "                                        "
                     "                                              " SKIP.

            OUTPUT STREAM str_2 CLOSE.

            RUN atualiza_controle ('F').

        END.  /* Fim do flaglast */

END PROCEDURE.

/* ......................................................................... */

PROCEDURE efetua_geracao_arquivos_autorizacao:

   IF   aux_flgfirst THEN
        DO:
            RUN nomeia_arquivos.
                
            OUTPUT STREAM str_2 TO VALUE(aux_nmarqped). 

            ASSIGN aux_nmempcov = gnconve.nmempres.

            PUT STREAM str_2 "A2"  
                       aux_nrconven  FORMAT "99999999999999999999"
                       aux_nmempcov  FORMAT "x(20)" 
                       aux_nrdbanco  FORMAT "999"
                       aux_nmdbanco  FORMAT "x(20)"
                       aux_dtmvtolt  FORMAT "x(08)"
                       aux_nrseqarq  FORMAT "999999"
                       gnconve.nrlayout FORMAT "99"
                       "DEBITO AUTOMATICO"
                       FILL(" ",52) FORMAT "x(52)" SKIP.

            aux_flgfirst = FALSE.
        END.

   
   ASSIGN aux_vltarifa = 0. /* Autorizacao nao tem tarifa */

   ASSIGN aux_nrseqdig = aux_nrseqdig + 1
          rel_vllanmto = DECI(SUBSTR(gncvuni.dsmovtos, 53, 15)) / 100
          tot_vlfatura = tot_vlfatura + rel_vllanmto.          
          
   PUT STREAM str_2 gncvuni.dsmovtos  FORMAT "x(150)" SKIP.
                    
   ASSIGN gncvuni.flgproce = TRUE.                 
                
   IF   aux_flaglast THEN
        DO:
            PUT STREAM str_2
                 "Z" STRING(aux_nrseqdig + 2, "999999") FORMAT "x(06)"
                     STRING(tot_vlfatura * 100, "99999999999999999") 
                     FORMAT "x(17)"
                     "                                        "
                     "                                        "
                     "                                              " SKIP.

            OUTPUT STREAM str_2 CLOSE.

            RUN atualiza_controle ('B').

        END.  /* Fim do flaglast */

END PROCEDURE.


PROCEDURE gera_arquivo_sem_movimento:

    DEF INPUT PARAM par_cdconven  AS INTE     NO-UNDO.

    FIND gnconve WHERE gnconve.cdconven = par_cdconven  AND
                       gnconve.flgativo = TRUE          NO-LOCK NO-ERROR.

    IF  AVAIL gnconve THEN
        DO:
            RUN nomeia_arquivos.
            
            OUTPUT STREAM str_2 TO VALUE(aux_nmarqped). 
            
            PUT STREAM str_2  "A2"   aux_nrconven FORMAT "99999999"
                              "            "
                              aux_nmempcov  FORMAT "x(20)" 
                              aux_nrdbanco  FORMAT "999" 
                              aux_nmdbanco  FORMAT "x(20)"
                              aux_dtmvtolt  FORMAT "x(08)" 
                              aux_nrseqarq  FORMAT "999999"
                              "03ARRECADACAO CAIXA" 
                              "                              "
                              "                      " SKIP.
            
            PUT STREAM str_2
                     "Z000002"
                     "00000000000000000"
                     "                                        "
                     "                                        "
                     "                                              " SKIP.
        
            OUTPUT STREAM str_2 CLOSE.
        
            RUN atualiza_controle ('G').
        END.

END PROCEDURE.


/* ......................................................................... */
