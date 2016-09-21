/* ..........................................................................

   Programa: Fontes/crps417.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Mirtes
   Data    : Novembro/2004                   Ultima atualizacao: 22/11/2013.

   Dados referentes ao programa:

   Frequencia: Diario
   Objetivo  : Se processo nao solicitado, solicitar(se nao houver criticas)
               Roda olhando a data de verificacao do processo cadastrada na
               CADCOP.


   Alteracao : 14/03/2005 - Registrar log, se processo nao solicitado(Mirtes)
   
               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                                
               17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.  
                    
               14/07/2006 - Criar  arq.diretorio/micros/controle/corvu(Mirtes)
              
               07/11/2006 - Atribuicao para glb_dtultdia e glb_dtultdma (Julio)
               
               24/08/2007 - Execucao do programa no horario definido na CADCOP
                          - Em caso de criticas enviar email para Multitask
                            (David).

               09/10/2007 - Colocar criticas do processo no corpo do e-mail.
                            Retirado o anexo (David).

               13/11/2007 - Enviar copia de e-mail para CPD e Mirtes (David).

               08/04/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)
                            
               21/08/2008 - Criar automaticamente taxas RDC (Diego).
               
               14/04/2009 - Alterar campo dsnotifi para ser tratrado como
                            EXTENT 6 (Fernando).
                            
               30/04/2009 - Solicitar processo se w_criticas.cdsitexc <> 0 
                            e hora limite para envio maior que hora atual - 
                            enviar e-mail para Suporte Operacional.
                            (Fernando).
                            
               06/07/2009 - Solicitar processo caso w_criticas.cdsitexc = 6 -   
                            Conta dos emprestimos atrelados a emissao de boletos
                            nao esta zerada (Fernando).

               26/08/2009 - Substituicao do campo banco/agencia da COMPE, 
                            para o banco/agencia COMPE de CHEQUE/DOC/TITULO
                            (Sidnei - Precise).                           
                            
               18/09/2009 - Acerto na mensagem de monitoramento para Multitask
                            (Diego).
                      
               15/10/2009 - Incluido tratamento para Banco CECRED -
                            crapcop.cdbcoctl (Guilherme - Precise)
               
               16/10/2009 - Envia para o email margarete@cecred.coop.br as 
                            mesmas informacoes enviadas para o email 
                            mirtes@cecred.coop.br (Elton).           
                           
               17/03/2010 - Move os arquivos do diretorio compbb para o 
                            diretorio compbbnproc e remove arquivos do diretorio 
                            controles quando o processo for solicitado;
                          - Incluido email compe@cecred.coop.br para recebimento
                            das criticas do processo (Elton).
                           
               25/05/2010 - Incluir e_mail do Pinotti (Magui).
               
               16/09/2010 - Incluido parametro glb_cdcooper nas chamadas da 
                            procedure limpa_arquivos_proces (Elton).
                            
               23/09/2010 - Utilizar o nome do diretorio da cooperativa nos
                            arquivos ".ctr" (Evandro).

               17/03/2011 - Enviar e_mail para o suporte (Magui).
               
               24/10/2011 - Criar o arquivo procfer para a Cecred e alteracao
                            do email margarete@cecred para eduardo, david e
                            diego (ZE).
                        
               01/08/2012 - Ajuste do format no campo nmrescop (David Kruger).
               
               22/11/2013 - Substituido endereço de e-mail 
                            operacao_fln@multitasknet.com.br para 
                            noc@multitask.com.br (Daniele). 
                            
/*----------------------------------------------------------------------------*/

                            
GPS BANCOOB: craptab.cdcooper = 0  /* w_criticas.cdsitexc = 1 */
             craptab.nmsistem = "CRED"
             craptab.tptabela = "GENERI"
             craptab.cdempres = 0
             craptab.cdacesso = "HRTRGPSBAN"
             craptab.tpregist = 1
             craptab.dstextab = "64800" (envio ate 18:00)

GPS BB: craptab.cdcooper = 0  /* w_criticas.cdsitexc = 1 */
        craptab.nmsistem = "CRED"
        craptab.tptabela = "GENERI"
        craptab.cdempres = 0
        craptab.cdacesso = "HRTRGPSBB"
        craptab.tpregist = 1
        craptab.dstextab = "64800" (envio ate 18:00)

TITULOS BANCOOB: craptab.cdcooper = 0 /* w_criticas.cdsitexc = 2 */
                 craptab.nmsistem = "CRED"
                 craptab.tptabela = "GENERI"
                 craptab.cdempres = 0
                 craptab.cdacesso = "HRTRTITBAN"
                 craptab.tpregist = 1
                 craptab.dstextab = "75600" (envio ate 21:00)

TITULOS BB: craptab.cdcooper = 0  /* w_criticas.cdsitexc = 2 */
            craptab.nmsistem = "CRED"
            craptab.tptabela = "GENERI"
            craptab.cdempres = 0
            craptab.cdacesso = "HRTRTITBB"
            craptab.tpregist = 1
            craptab.dstextab = "68400" (envio ate 19:00)
            
TITULOS CECRED: craptab.cdcooper = 0 /* w_criticas.cdsitexc = 2 */
                craptab.nmsistem = "CRED"
                craptab.tptabela = "GENERI"
                craptab.cdempres = 0
                craptab.cdacesso = "HRTRTITCCE"
                craptab.tpregist = 1
                craptab.dstextab = "75600" (envio ate 21:00)



CHEQUES BANCOOB: craptab.cdcooper = 0  /* w_criticas.cdsitexc = 3 */
                 craptab.nmsistem = "CRED"
                 craptab.tptabela = "GENERI"
                 craptab.cdempres = 0
                 craptab.cdacesso = "HRCOMPEBAN"
                 craptab.tpregist = 1
                 craptab.dstextab = "68400" (envio ate 19:00)

CHEQUES BB: craptab.cdcooper = 0 /* w_criticas.cdsitexc = 3 */
            craptab.nmsistem = "CRED"
            craptab.tptabela = "GENERI"
            craptab.cdempres = 0
            craptab.cdacesso = "HRCOMPEBB"
            craptab.tpregist = 1
            craptab.dstextab = "59400" (envio ate 16:30)

CHEQUES CECRED: craptab.cdcooper = 0  /* w_criticas.cdsitexc = 3 */
                craptab.nmsistem = "CRED"
                craptab.tptabela = "GENERI"
                craptab.cdempres = 0
                craptab.cdacesso = "HRCOMPECCE"
                craptab.tpregist = 1
                craptab.dstextab = "68400" (envio ate 19:00)



DOCS/TEDS BANCOOB: craptab.cdcooper = 0  /* w_criticas.cdsitexc = 4 */                            craptab.nmsistem = "CRED"
                   craptab.tptabela = "GENERI"
                   craptab.cdempres = 0
                   craptab.cdacesso = "HRTRDOCBAN"
                   craptab.tpregist = 1
                   craptab.dstextab = "64800" (envio ate 18:00)

DOCS/TEDS BB: craptab.cdcooper = 0 /* w_criticas.cdsitexc = 4 */
              craptab.nmsistem = "CRED"
              craptab.tptabela = "GENERI"
              craptab.cdempres = 0
              craptab.cdacesso = "HRTRDOCBB"
              craptab.tpregist = 1
              craptab.dstextab = "54000" (envio ate 15:00)
                            
DOCS/TEDS CECRED: craptab.cdcooper = 0  /* w_criticas.cdsitexc = 4 */
                  craptab.nmsistem = "CRED"
                  craptab.tptabela = "GENERI"
                  craptab.cdempres = 0
                  craptab.cdacesso = "HRTRDOCCCE"
                  craptab.tpregist = 1
                  craptab.dstextab = "64800" (envio ate 18:00)



INSS BANCOOB: craptab.cdcooper = 0  /* w_criticas.cdsitexc = 5 */
              craptab.nmsistem = "CRED"
              craptab.tptabela = "GENERI"
              craptab.cdempres = 0
              craptab.cdacesso = "HRINSSBAN"
              craptab.tpregist = 1
              craptab.dstextab = "64800" (envio ate 18:00)
 ........................................................................... */

{ includes/var_online.i "NEW"}
{ includes/var_proces.i "NEW"}

DEF VAR aux_nmarqv   AS CHAR                                           NO-UNDO.
DEF VAR des_criticas AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqtax AS CHAR                                           NO-UNDO.
DEF VAR aux_setlinha AS CHAR                                           NO-UNDO.
DEF VAR aux_valortax AS DEC                                            NO-UNDO.
DEF VAR aux_txprodia AS DEC DECIMALS 8 FORMAT "z9.999999"              NO-UNDO.

DEF VAR aux_flgsolpr AS LOG          INIT TRUE                         NO-UNDO.

DEF   VAR b1wgen0011   AS HANDLE                                       NO-UNDO.
DEF   VAR h-b1wgen9998 AS HANDLE                                       NO-UNDO.

DEF STREAM str_1.
DEF STREAM str_3. /* arquivo anexo para enviar via email */

ASSIGN glb_cdprogra = "crps417".

glb_cdcooper = INT(OS-GETENV("CDCOOPER")).

/* Busca dados da cooperativa */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:

         RUN cria_proc_417.         
         
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         QUIT.
    END.
                           
/*** Controle de horario para execucao ***/
IF  TIME < crapcop.hrproces OR TIME > crapcop.hrfinprc  THEN
    DO:
        /*================
        RUN cria_proc_417.
       
        glb_cdcritic = 687.
        RUN fontes/critic.p.
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          glb_dscritic + " >> log/proc_batch.log").
        ================*/
        
        QUIT.
    END.      
                             
/*--- Solicitar Processo (Caso  nao solicitado e sem  criticas) -----------*/

FIND FIRST crapdat WHERE crapdat.cdcooper = glb_cdcooper  NO-LOCK NO-ERROR.
IF  NOT AVAIL crapdat  THEN 
    DO:
       
       RUN cria_proc_417.
       
       glb_cdcritic = 1.
       RUN fontes/critic.p.
       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                         " - " + glb_cdprogra + "' --> '"  +
                         glb_dscritic + " >> log/proc_batch.log").
       QUIT.
    END.

/* Controle Corvu */
IF  glb_cdcooper <> 3  THEN
    DO:
       UNIX SILENT VALUE(" > /micros/controle/corvu/" +
                         LC(crapcop.dsdircop) + ".ctr" 
                         + " 2> /dev/null").                              

       IF  MONTH(crapdat.dtmvtopr) <> MONTH(crapdat.dtmvtolt)   THEN
           DO:
              UNIX SILENT VALUE(" > /micros/controle/corvu/" + "mensal.ok"
                   + " 2> /dev/null").
           END.
    END.
 
IF  crapdat.inproces = 1  THEN
    DO:

       ASSIGN glb_dtmvtolt = crapdat.dtmvtolt
              glb_dtmvtopr = crapdat.dtmvtopr
              glb_dtmvtoan = crapdat.dtmvtoan
              glb_inproces = crapdat.inproces
              glb_qtdiaute = crapdat.qtdiaute
              glb_cdcooper = crapcop.cdcooper
              
              glb_dtultdma = crapdat.dtmvtolt - DAY(crapdat.dtmvtolt)
         
              glb_dtultdia = ((DATE(MONTH(glb_dtmvtolt),28,YEAR(glb_dtmvtolt)) +
                                      4) - DAY(DATE(MONTH(glb_dtmvtolt),28,
                                                    YEAR(glb_dtmvtolt)) + 4)).

       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                         " -  Processo Solicitado Automatico - CRPS417 "  +
                         " >> log/proc_batch.log").

       EMPTY TEMP-TABLE w_criticas.
       
       RUN fontes/gera_criticas_proces.p (INPUT " ",
                                          OUTPUT aux_nrsequen,
                                          OUTPUT TABLE w_criticas).  
                 
       IF  aux_nrsequen = 0  THEN
           DO:  
              RUN fontes/proces1.p.  /* Solicita o processo */  
              
              IF  glb_cdcritic <> 0 THEN
                  DO:
                      
                      RUN cria_proc_417.
                      
                      RUN fontes/critic.p.
                      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                        " - " + glb_cdprogra + "' --> '"  +
                                        glb_dscritic +
                                        " >> log/proc_batch.log"). 
                      QUIT.
                  END. 
                
              /** Move arquivos dos diretorios controles e compbb **/
              RUN sistema/generico/procedures/b1wgen9998.p 
                                              PERSISTEN SET h-b1wgen9998.
              
              RUN limpa_arquivos_proces IN h-b1wgen9998 
                                          (INPUT glb_cdcooper, 
                                           INPUT glb_cdprogra,
                                           INPUT glb_dtmvtolt).
              DELETE PROCEDURE h-b1wgen9998.

           END.
       ELSE
           DO:
              FIND FIRST w_criticas WHERE w_criticas.cdsitexc = 0 NO-LOCK
                                          NO-ERROR.
                                          
              IF  AVAILABLE w_criticas  THEN
                  DO:
                     RUN cria_proc_417.

                     /*** Envia e-mail com as criticas ***/
                     RUN envia_erro_proces(INPUT FALSE).
                     QUIT.
                  END.     
/*----------------------------------------------------------------------------*/              
              /*** Se cdsitexc = 6, a conta dos emprestimos com emissao de 
                   boletos nao esta zerada, sendo assim deve-se solicitar o 
                   processo e enviar e-mail informando o ocorrido ***/
              FOR EACH w_criticas WHERE w_criticas.cdsitexc <> 6  NO-LOCK:
                  
                  IF  CAN-DO("2,3,4", STRING(w_criticas.cdsitexc))  THEN
                      FIND crapage WHERE crapage.cdcooper = glb_cdcooper AND
                                         crapage.cdagenci = w_criticas.cdagenci
                                         NO-LOCK NO-ERROR.

                  CASE w_criticas.cdsitexc:
                       
                       /*** Falta envio GPS ***/
                       WHEN 1 THEN 
                            CASE INT(SUBSTR(STRING(crapcop.cdcrdarr),1,3)):
                                WHEN 756 THEN
                                    RUN lim_envio (INPUT "HRTRGPSBAN").
                                WHEN 1   THEN
                                    RUN lim_envio (INPUT "HRTRGPSBB").
                            END CASE.

                       /*** Falta envio de Titulos ***/
                       WHEN 2 THEN
                            CASE crapage.cdbantit:
                                WHEN 756 THEN
                                    RUN lim_envio ("HRTRTITBAN").
                                WHEN 1   THEN
                                    RUN lim_envio ("HRTRTITBB").
                                WHEN crapcop.cdbcoctl THEN
                                    RUN lim_envio ("HRTRTITCCE").
                            END CASE.

                       /*** Falta envio de Cheques ***/
                       WHEN 3 THEN
                            CASE crapage.cdbanchq:
                                WHEN 756 THEN
                                    RUN lim_envio ("HRCOMPEBAN").
                                WHEN 1   THEN
                                    RUN lim_envio ("HRCOMPEBB").
                                WHEN crapcop.cdbcoctl THEN
                                    RUN lim_envio ("HRCOMPECCE").
                            END CASE.

                       /*** Falta envio de Docs/Teds ***/
                       WHEN 4 THEN
                            CASE crapage.cdbandoc:
                                WHEN 756 THEN
                                    RUN lim_envio ("HRTRDOCBAN").
                                WHEN 1   THEN
                                    RUN lim_envio ("HRTRDOCBB").
                                WHEN crapcop.cdbcoctl THEN
                                    RUN lim_envio ("HRTRDOCCCE").
                            END CASE. 

                       /*** Falta envio INSS ***/
                       WHEN 5 THEN RUN lim_envio ("HRINSSBAN").
                  END CASE.
              END.
/*----------------------------------------------------------------------------*/

              /*** Testa se processo pode ser solicitado ***/
              IF  aux_flgsolpr  THEN
                  DO:
                    RUN envia_erro_proces(INPUT TRUE).

                    RUN fontes/proces1.p.  /* Solicita o processo */

                    IF  glb_cdcritic <> 0 THEN
                        DO:
                                
                           RUN cria_proc_417.
                                                      
                           RUN fontes/critic.p.
                           UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                             " - " + glb_cdprogra + "' --> '"  +
                                             glb_dscritic +
                                             " >> log/proc_batch.log").
                           QUIT.
                        END.
                    
                    /** Move arquivos dos diretorios controles e compbb **/
                    RUN sistema/generico/procedures/b1wgen9998.p 
                                                    PERSISTEN SET h-b1wgen9998.
                    
                    RUN limpa_arquivos_proces IN h-b1wgen9998 
                                                (INPUT glb_cdcooper,
                                                 INPUT glb_cdprogra,
                                                 INPUT glb_dtmvtolt).
                    DELETE PROCEDURE h-b1wgen9998.

                  END.
              ELSE
                  RUN envia_erro_proces(INPUT FALSE). 
           END.             
    END.

RUN cria_proc_417.

RUN cria_procfer_cecred.


/*............................................................................*/


PROCEDURE cria_procfer_cecred:

  DEF VAR aux_qtdias AS INT                                          NO-UNDO.
  DEF VAR aux_qtcont AS INT                                          NO-UNDO.
  DEF VAR aux_nmarqv AS CHAR                                         NO-UNDO.

  
  /*  Cria arquivos de controle de fim-de-semana/feriados ............... */
      
  /*  Cria SOMENTE PARA A CECRED, para as demais continua a criar no crps000.p.
      Nao ira criar o procfer para SABADO e DOMINGO. Somente para FERIADOS.
      A CECRED nao executa o processo no sabado e domingo. Na crontab esta
      configurado para segunda a sexta.
      Com isso nao sera mais necessario excluir os arquivos procfer na
      segunda-feira e tera um tratamento correto para os feriados */
  
  IF   glb_cdcooper = 3 THEN  /* Somente para a CECRED */
       DO:
           ASSIGN aux_qtdias = glb_dtmvtopr - glb_dtmvtolt
                  aux_qtcont = 1.
          
           DO WHILE aux_qtcont <= (aux_qtdias - 1):
               
              IF   WEEKDAY(glb_dtmvtolt + aux_qtcont) <> 7 AND   /* Sabado */
                   WEEKDAY(glb_dtmvtolt + aux_qtcont) <> 1 THEN  /* Domingo */
                   DO:
                       /* Cria o arquivo somente para Feriados */
                       
                       aux_nmarqv = "arquivos/.procfer" + STRING(aux_qtcont).
                  
                       UNIX SILENT VALUE("> " + aux_nmarqv).
                   END.
          
              aux_qtcont = aux_qtcont + 1.
          
           END.  /*  Fim do DO WHILE  */
       END.
       
END PROCEDURE.


PROCEDURE cria_proc_417.

  ASSIGN aux_nmarqv = "arquivos/proc417ok".
  OUTPUT STREAM str_1 TO VALUE(aux_nmarqv).
  OUTPUT STREAM str_1 CLOSE.

END PROCEDURE.

PROCEDURE lim_envio:

DEF  INPUT   PARAMETER par_cdacesso AS  CHAR                         NO-UNDO.

  FIND craptab WHERE craptab.cdcooper = 0             AND
                     craptab.nmsistem = "CRED"        AND
                     craptab.tptabela = "GENERI"      AND
                     craptab.cdempres = 0             AND
                     craptab.cdacesso = par_cdacesso  AND
                     craptab.tpregist = 1             NO-LOCK NO-ERROR.
                       
  IF   TIME < INT(craptab.dstextab)   THEN
       ASSIGN aux_flgsolpr = FALSE.

END PROCEDURE.

PROCEDURE envia_erro_proces:
     
DEF  INPUT   PARAMETER aux_flgenvio  AS LOGI                         NO-UNDO.
DEF  VAR     aux_dssolici            AS CHAR                         NO-UNDO.


  /* criar arquivo anexo para email */
  ASSIGN aux_nmarqimp = "arq/" + glb_cdprogra +
                        "_ANEXO" + STRING(TIME).
                                            
  OUTPUT STREAM str_3 TO VALUE(aux_nmarqimp).

  IF   aux_flgenvio  THEN
       DO:
          ASSIGN aux_dssolici = "*** PROCESSO SOLICITADO ***".
         
          PUT STREAM str_3
                   crapcop.nmrescop FORMAT "x(20)"
                   SKIP(1)
                   aux_dssolici FORMAT "x(32)"
                   SKIP(1)
                   "CRITICAS DO PROCESSO"
                   SKIP.
       END.
  ELSE
       DO:              
          ASSIGN aux_dssolici = "*** PROCESSO NAO SOLICITADO ***".
           
          PUT STREAM str_3
                     crapcop.nmrescop FORMAT "x(20)"
                     SKIP(1)
                     crapcop.dsnotifi[1] FORMAT "x(70)"  SKIP
                     crapcop.dsnotifi[2] FORMAT "x(70)"  SKIP
                     crapcop.dsnotifi[3] FORMAT "x(70)"  SKIP
                     crapcop.dsnotifi[4] FORMAT "x(70)"  SKIP
                     crapcop.dsnotifi[5] FORMAT "x(70)"  SKIP
                     crapcop.dsnotifi[6] FORMAT "x(70)"
                     SKIP(1)
                     aux_dssolici FORMAT "x(32)"
                     SKIP(1)
                     "CRITICAS DO PROCESSO"
                     SKIP.
       END.
       
  FOR EACH w_criticas NO-LOCK BY w_criticas.nrsequen:
      PUT STREAM str_3
                 STRING(w_criticas.nrsequen,"99999")
                                     FORMAT "x(05)"
                 w_criticas.dscritic FORMAT "x(70)"
                 SKIP.
  END.
                                                                  
  OUTPUT STREAM str_3 CLOSE.
       
  /* Move para diretorio converte para utilizar na BO */
  UNIX SILENT VALUE
              ("cp " + aux_nmarqimp + " /usr/coop/" +
               crapcop.dsdircop + "/converte" +
               " 2> /dev/null").
     
  /* envio de email */
  RUN sistema/generico/procedures/b1wgen0011.p
  PERSISTENT SET b1wgen0011.

  IF  aux_flgenvio  THEN    
      RUN enviar_email IN b1wgen0011(INPUT glb_cdcooper,
                                     INPUT glb_cdprogra,
                                     INPUT "suporte.operacional@cecred.coop.br,"
                                           + "compe@cecred.coop.br,"
                                           + "eduardo@cecred.coop.br,"
                                           + "david.kistner@cecred.coop.br,"
                                           + "diego@cecred.coop.br",                                     INPUT "'CONTROLE PROCESSO   ' ",
                                     INPUT SUBSTRING(aux_nmarqimp, 5),
                                     INPUT FALSE).
   ELSE
      RUN enviar_email IN b1wgen0011(INPUT glb_cdcooper,
                                     INPUT glb_cdprogra,
                                     INPUT "noc@multitask.com.br,"  +
                                           "luiz@multitasknet.com.br," +
                                           "pinotti@multitasknet.com.br," +
                                           "cpd@cecred.coop.br," +
                                           "compe@cecred.coop.br," + 
                                     "suporte.operacional@cecred.coop.br," +
                                           "mirtes@cecred.coop.br," +
                                           "eduardo@cecred.coop.br," +
                                           "david.kistner@cecred.coop.br," +
                                           "diego@cecred.coop.br", 
                                     INPUT "'CONTROLE PROCESSO   ' ",
                                     INPUT SUBSTRING(aux_nmarqimp, 5),
                                     INPUT FALSE).

  DELETE PROCEDURE b1wgen0011.

  /* remover arquivo criado de anexo */
  UNIX SILENT VALUE("rm " + aux_nmarqimp +
                    " 2>/dev/null").
END PROCEDURE.

