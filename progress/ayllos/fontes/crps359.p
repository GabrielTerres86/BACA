/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps359.p                | pc_crps359                        |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/












/* ..........................................................................

   Programa: Fontes/crps359.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Mirtes
   Data    : Outubro/2003                      Ultima atualizacao: 11/07/2019

   Dados referentes ao programa:

   Frequencia: Diario
   Objetivo  : Controlar a primeira cadeia de execucao
               Roda apos o viracash (meia-noite).
                             
               28/10/2003 - Eliminar rel. arq/pmg*(Mirtes).

               10/12/2003 - Eliminar DEB*.ret SAMAE JARAGUA (Julio).

               16/12/2003 - Se nao existir sol.82 cancelar processo(Mirtes).

               12/04/2004 - Conectar/Desconectar Banco Generico(Mirtes).

               13/05/2004 - Inclusao banco gener no comando mbpro (Julio)

               20/08/2004 - Alterado o parametro -s de 24 para 40 (default do
                            progress) Edson.

               05/01/2005 - Excluir arquivos .ret no inicio do programa
                            (Edson).

               28/06/2005 - Incluir na cadeia apenas os programas que estiverem
                            com crapprg.inlibprg = 1 (Julio)

               15/08/2005 - Capturar codigo da cooperativa da variavel de 
                            ambiente CDCOOPER (Edson).
                            
               02/01/2006 - Acerto no numeracao do lote NUMLOTECBB (Ze).

               25/01/2006 - Monitoramento da cadeia paralela (Edson).
               
               30/01/2006 - Cria arquivo controles/crps359.ok para monito-
                            ramento do script/vcash_nn (Edson).

               29/03/2006 - Reforma geral do programa (Edson).

               09/05/2006 - Nao gerar mais os arquivos procferNNN. Serao
                            gerados a partir de agora pelo crps000.p (Edson).
                   
               21/06/2006 - Incluida eliminacao de registro da tabela crapsdv
                            (David).

               04/07/2006 - Receber os logs dos caixas eletronicos (Edson).
                
               09/11/2006 - Eliminar arq.diretorio converte(Mirtes). 

               21/11/2006 - Buscar os arquivos de log dos caixas eletronicos
                            atraves do script BuscaArquivoPC.sh (Edson).
                            
               24/11/2006 - Utilizar o arquivo PROC_cron.pf na chamada
                            dos programas paralelos (Edson).

               03/07/2007 - Chamar os programas paralelos atraves do script
                            cecred_mbpro, este script esta preparado para 
                            evitar o cancelamento do programa quando houver
                            estouro de mascara no display (Edson).

               03/07/2007 - Exclusao dos arquivos transmitidos ao Bancoob
                            (Edson/Mirtes).
                            
               21/11/2007 - Limpeza da craptab ARQRETINSS que controla os
                            sequenciais de arquivos ao BANCOOB-INSS (Evandro).

               05/12/2007 - Limpeza das tabelas de controle de horarios para
                            envio de arquivos (David).

               11/02/2008 - Gravar craptab "HRPGTOINSS" (Evandro).
               
               28/02/2008 - Limpeza do controle de sequenciais das guias GPS
                            do BANCOOB-INSS craptab = "ARQRETINSS";
                          - Limpeza (mensalmente) da craptab "GPSAGEBCOB"
                           (Evandro).
                           
               16/04/2008 - Acerto na craptab "HRTRDOCTOS" (Diego).

               12/06/2008 - Verificar registro de cooperados sem saldo(Mirtes).
               
               24/06/2008 - Correcao na atualizacao da craptab HTTRTITULO
                            (David).
                            
               01/08/2008 - Verificar se as coop. sing. finalizaram o processo
                            para inicio do processo da CECRED.
                            Envio de email para operador avisando o inicio do
                            processo da CECRED 
                            Tratamento para a CECRED do .procfer (Ze).
                            
               16/09/2008 - Remover arquivo de taxas utilizado pelo programa
                            crps417 (Diego).
                            
               11/11/2008 - Para o Processo da CECRED verificar se as coop. 
                            filiadas finalizaram o processo (Ze).
                            
               09/03/2009 - Incluir parametro no prog. 514 - Acerto (Ze).
               
               08/06/2009 - Efetuado acerto na inicializacao do numero de lote
                            nas TAB'S  NUMLOTEFOL, NUMLOTECOT e NUMLOTEEMP
                            (Diego).
                            
               02/10/2009 - Aumento do campo nrterfin (Diego).
               
               24/03/2010 - Deleta tabela crapscd (Elton);
                          - Criar nome logico "bdgener" na chamada dos 
                            programas em background e remocao do "-s"
                            (Evandro/Julio).
                            
               19/05/2010 - Comentado o tratamento do crps514 pois ele foi
                            inserido na cadeia da CECRED 
                            (Guilherme/Mirtes/Magui/Ze).
                            
               15/06/2010 - Somente baixar log dos cashs com sistema
                            antigo. Para o sistema TAA, fara o download
                            direto na CRON (Evandro).
                            
               25/06/2010 - Excluir os contratos gerados para a tela
                            IMPROP apos 10 dias da criacao (Gabriel).
                    
               02/09/2010 - Inserir tratamento para nao eliminar crapscd
                            no ultimo dia do mes. Tarefa 34577 (Henrique).
                            
               15/07/2011 - Retirada a conexão com o banco Gener (Fernando).
               
               30/09/2011 - Alterar diretorio spool para
                            /usr/coop/sistema/siscaixa/web/spool (Fernando). 
                            
               28/01/2013 - Alimentar variavel glb_nmmodora (Guilherme).
               
               03/07/2013 - Tratamento para nao excluir o crapass (Ze).
                                                    
               08/10/2013 - Removida verificação de saldo. Removida 
                            chamada para crps655 e registro de logs do 
                            Corvu (Douglas Pagel).
                            
               22/02/2017 - #601794 Inclusão de log de início e fim das 
			                      execuções (Carlos)
                      
               03/05/2017 - #601794 Inclusao dos parametros de criacao de 
                            chamado (Carlos)
							
			   10/05/2018 - Geração do registro no cadastro tbgen
			                quando um programa para a cadeia e de quando o programa he reiniciado
							( Belli - Envolti - Chamado REQ0013442)

               24/05/2018 - feito tratamento no lote emprestimo condiginado, para 
			                quando tiver 7 e 4 digitos, atualizar corretamente o lote. Alcemir (Mout's) (SCTASK0015071).
							             
               11/07/2019 - Alterado a posiçao do log do inicio do processo batch noturno
                            e criado mais alguns logs para feedback do processo do 359
                            (Tiago - PRB0041925)
............................................................................. */

DEF STREAM str_mp.      /*  Stream para monitoramento do programas paralelos  */

DEF STREAM str_1.       /* Listar os contratos de emprestimos no /log */
DEF STREAM str_2.       /* Stream para controle de feriados  */

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }
{ includes/gg0000.i }

/*  .... Define a quantidade de programas que rodam na cadeia paralela .....  */

DEF            VAR aux_cdprgpar AS CHAR    FORMAT "x(10)" EXTENT 15  NO-UNDO.

DEF            VAR aux_qtparale AS INT     INIT 15                   NO-UNDO.
DEF            VAR aux_contapar AS INT                               NO-UNDO.
DEF            VAR aux_mtpidprg AS INT     EXTENT 15                 NO-UNDO.

/*  ......................................................................... */

DEF            VAR aux_cadeiaex AS CHAR    FORMAT "x(2000)" INIT ""  NO-UNDO.
DEF            VAR aux_lscadeia AS CHAR    FORMAT "x(1500)"          NO-UNDO.
DEF            VAR aux_lsprogra AS CHAR    FORMAT "x(80)"            NO-UNDO.
DEF            VAR aux_nmdobjet AS CHAR    FORMAT "x(20)"            NO-UNDO.
DEF            VAR aux_nmcobjet AS CHAR    FORMAT "x(80)"            NO-UNDO.
DEF            VAR aux_cdprogra AS CHAR    FORMAT "x(20)"            NO-UNDO.
DEF            VAR aux_dspidprg AS CHAR                              NO-UNDO.
DEF            VAR aux_mensagem AS CHAR  FORMAT "X(30)" NO-UNDO.     
DEF            VAR aux_nmarqv   AS CHAR                              NO-UNDO.

DEF            VAR aux_nrposprg AS INT     FORMAT "zz9" INIT 1       NO-UNDO.
DEF            VAR aux_qtprgpar AS INT                               NO-UNDO.
DEF            VAR aux_nrpidprg AS INT                               NO-UNDO.
DEF            VAR aux_nrmonpid AS INT                               NO-UNDO.
DEF            VAR aux_contador AS INT                               NO-UNDO.
DEF            VAR aux_nrinides AS INT                               NO-UNDO.
DEF            VAR aux_qtdias   AS INT                               NO-UNDO.
DEF            VAR aux_qtcont   AS INT                               NO-UNDO.
DEF            VAR aux_solic82  AS INT   INIT 0 NO-UNDO.

DEF            VAR aux_flgerrcp AS LOGICAL                           NO-UNDO.
DEF            VAR aux_flgcadpl AS LOGICAL                           NO-UNDO.
DEF            VAR aux_flgrepro AS LOGICAL                           NO-UNDO.

DEF            VAR aux_dtmvtolt AS DATE                              NO-UNDO.
DEF            VAR aux_dtlogant AS DATE                              NO-UNDO.
DEF            VAR aux_flgarqui AS LOGICAL                           NO-UNDO.
DEF            VAR aux_nmarquiv AS CHAR                              NO-UNDO.
DEF            VAR aux_flgproce AS LOGICAL                           NO-UNDO.

DEF            VAR h-b1wgen0011 AS HANDLE                            NO-UNDO.

DEF BUFFER crabass FOR crapass.

/* Variaveis para geração do registro no cadastro tbgen quando um programa para a cadeia, chd REQ0013442, 10/05/2018 */
DEF VAR aux_cdcrimsg      AS INTE                                   NO-UNDO.
DEF VAR aux_dscrimsg      AS CHAR                                   NO-UNDO. 

/* Variaveis para geração do registro no cadastro tbgen quando um programa para a cadeia, chd REQ0013442, 10/05/2018 */
DEF            VAR aux_injareex AS CHAR                              NO-UNDO. 

ASSIGN aux_injareex = "N". /* INDICANDO QUE AINDA NAO REXECUTOU O PROCESSO */

ASSIGN glb_cdprogra = "crps359".
     /*  glb_nmmodora = glb_cdprogra.  Comentado Temporariamente */

/* --- Conectar Banco Generico --*/

IF   NOT f_conectagener() THEN
     DO:   /* Conecta Bancos Generico */
         glb_cdcritic = 791.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " + 
                           glb_cdprogra + "' --> '"  + glb_dscritic + 
                           " Generico " + " >> log/proc_batch.log").
         QUIT.
     END.

/*  Captura codigo da cooperativa da variavel de ambiente CDCOOPER .......... */

glb_cdcooper = INT(OS-GETENV("CDCOOPER")).

IF   glb_cdcooper = ?   THEN
     glb_cdcooper = 0.

/*  Verifica se a cooperativa esta cadastrada ............................... */
   
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

/*  Le data do sistema  */

DO TRANSACTION ON ERROR UNDO, RETURN.

   DO WHILE TRUE:

      FIND FIRST crapdat WHERE crapdat.cdcooper = glb_cdcooper
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF   NOT AVAILABLE crapdat   THEN
           IF   LOCKED crapdat   THEN
                DO:
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
           ELSE
                glb_cdcritic = 1.
      ELSE
           IF   crapdat.inproces = 2   THEN
                ASSIGN glb_cdcritic = 0
                       glb_dtmvtolt = crapdat.dtmvtolt
                       aux_dtlogant = crapdat.dtmvtoan
                       aux_flgrepro = FALSE
                       crapdat.inproces = 6.
           ELSE
                IF   crapdat.inproces = 1   THEN
                     ASSIGN glb_cdcritic = 141
                            glb_dtmvtolt = crapdat.dtmvtolt
                            aux_dtlogant = crapdat.dtmvtoan
                            aux_flgrepro = FALSE.
                ELSE
                     IF  crapdat.inproces = 6 THEN
                         ASSIGN glb_cdcritic = 0
                                glb_dtmvtolt = crapdat.dtmvtolt
                                aux_dtlogant = crapdat.dtmvtoan
                                aux_flgrepro = TRUE.
                     ELSE
                         ASSIGN glb_cdcritic = 771 /* PROCESSO JA RODOU */
                                glb_dtmvtolt = crapdat.dtmvtolt
                                aux_dtlogant = crapdat.dtmvtoan
                                aux_flgrepro = FALSE.
                                
      LEAVE.

   END.

   /*  Inicia log do processo .................................................. */
   
   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                     (IF aux_flgrepro
                         THEN " Reinicio do processo batch NOTURNO referente "
                         ELSE " Inicio do processo batch NOTURNO referente ") +
                     (IF glb_dtmvtolt <> ?
                         THEN STRING(glb_dtmvtolt,"99/99/9999")
                         ELSE "'*** Sistema sem data! ***'") +
                     " em " + STRING(TODAY,"99/99/9999") + 
                     " da " + STRING(crapcop.nmrescop,"x(20)") +
                     " >> log/proc_batch.log").


   /* Testa se o viracash rodou */
   IF   crapdat.dtmvtopr <> crapdat.dtmvtocd THEN
        glb_cdcritic = 747. 

   /*  Inicializa os numeros de lotes para integracao de folha de pagto  */
   IF   NOT aux_flgrepro       AND
        glb_cdcritic     = 0   THEN
   DO:     
        
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                          glb_cdprogra + "' --> '" + "Inicializa numeros de lotes para integracao folha de pagto >> log/proc_batch.log").
        
        FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "GENERI"       AND
                               craptab.cdempres = 0              AND
                               craptab.cdacesso BEGINS "NUMLOTE":

            IF   craptab.cdacesso <> "NUMLOTECBB"  AND 
                 craptab.cdacesso <> "NUMLOTEBCO"  AND
                 craptab.cdacesso <> "NUMLOTECEF"  THEN
                 DO:
                     IF  craptab.cdacesso = "NUMLOTEFOL" OR
                         craptab.cdacesso = "NUMLOTECOT" OR
                         craptab.cdacesso = "NUMLOTEEMP"  THEN
                         DO:

                            CASE LENGTH(craptab.dstextab):
                                WHEN 5 THEN
                                    ASSIGN craptab.dstextab =
                                       SUBSTRING(craptab.dstextab,1,4) + "0".	
                                WHEN 6 THEN  
                                    ASSIGN craptab.dstextab =
                                        SUBSTRING(craptab.dstextab,1,5) + "0".
                                WHEN 7 THEN  
                                    ASSIGN craptab.dstextab =
                                       SUBSTRING(craptab.dstextab,1,6) + "0".
								OTHERWISE
									ASSIGN craptab.dstextab =
                                        SUBSTRING(craptab.dstextab,1,3) + "0".
                            END CASE.
                         END.
                     ELSE
                          ASSIGN craptab.dstextab =
                                 SUBSTRING(craptab.dstextab,1,3) + "0".
                 
                 END.

        END.
        
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
               glb_cdprogra + "' --> '" + "Fim inicializa numeros de lotes para integracao folha de pagto >> log/proc_batch.log").                 
   
   END.
   
   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                  glb_cdprogra + "' --> '" + "Inicio limpeza da sequencia dos arquivos enviados ao BANCOOB INSS >> log/proc_batch.log").
   
   
   /* Limpa a sequencia dos arquivos enviados ao BANCOOB-INSS */
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "GENERI"       AND
                      craptab.cdempres = 0              AND
                      craptab.cdacesso = "ARQRETINSS"   AND
                      craptab.tpregist = 0
                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
   
   IF  AVAILABLE craptab  THEN
       ASSIGN craptab.dstextab = "".
       
   
   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                  glb_cdprogra + "' --> '" + "Fim limpeza da sequencia dos arquivos enviados ao BANCOOB INSS >> log/proc_batch.log").
   
   
   
   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                  glb_cdprogra + "' --> '" + "Inicio limpeza da sequencia dos arquivos das guias GPS enviados ao BANCOOB INSS >> log/proc_batch.log").
   
   /* Limpa a sequencia dos arquivos das guias GPS enviados ao BANCOOB-INSS */
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "GENERI"       AND
                      craptab.cdempres = 0              AND
                      craptab.cdacesso = "ARQRETINSS"   AND
                      craptab.tpregist = 99
                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
   
   IF  AVAILABLE craptab  THEN
       ASSIGN craptab.dstextab = "1".
       

   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                  glb_cdprogra + "' --> '" + "Fim limpeza da sequencia dos arquivos das guias GPS enviados ao BANCOOB INSS >> log/proc_batch.log").
   


   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                  glb_cdprogra + "' --> '" + "Inicio limpeza do controle de pagamentos agendados de guis GPS BANCOOB >> log/proc_batch.log").
   
   /* Limpeza do controle de pagamentos agendados de guias GPS-BANCOOB */
   IF   MONTH(glb_dtmvtolt) <> MONTH(glb_dtmvtopr)   THEN
        FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "GENERI"       AND
                               craptab.cdempres = 0              AND
                               craptab.cdacesso = "GPSAGEBCOB"
                               EXCLUSIVE-LOCK:
                               
            /* craptab.tpregist = 1-Fisico, 2-Juridico */
            ASSIGN SUBSTRING(craptab.dstextab,4,10) = "".               
        END.

   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                  glb_cdprogra + "' --> '" + "Fim limpeza do controle de pagamentos agendados de guis GPS BANCOOB >> log/proc_batch.log").
        

END.  /* Fim da transacao */

RELEASE crapdat.

IF   glb_cdcritic > 0   THEN
     DO:
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" + glb_dscritic +
                           " >> log/proc_batch.log").
         PAUSE 2 NO-MESSAGE.
         QUIT.
     END.

/*----------------------------------------------------------------------
  Retirado o processamento do crps514 pois ele foi inserido na cadeia da CECRED
  (Guilherme/Mirtes/Magui/Ze).
/*   Para o Processo da CECRED verificar se as coop. filiadas 
     finalizaram o processo */
IF   glb_cdcooper = 3 THEN
     DO:
         /* Alguma cooperativa filiada nao finalizou o processo */
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" +
                           "Aguardando as cooperativas finalizarem" +
                           " seus processos ... >> log/proc_batch.log").

         DO WHILE TRUE:

            RUN fontes/crps514.p (INPUT  glb_dtmvtolt,
                                  OUTPUT aux_flgproce).
         
            IF   aux_flgproce THEN
                 DO:
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                                        " - " + glb_cdprogra + "' --> '" +
                                 "Processos das cooperativas finalizado" +
                                 " >> log/proc_batch.log").
                     LEAVE.
                 END.
            ELSE     
                 PAUSE 60 NO-MESSAGE.
         END.
     END.
----------------------------------------------------------------------------*/ 

IF   NOT aux_flgrepro THEN
     RUN proc_remove_arquivos.

/*  Monta cadeia de execucao ................................................ */

FOR EACH crapord WHERE crapord.cdcooper = glb_cdcooper   AND
                       crapord.tpcadeia = 3 NO-LOCK:

    FOR EACH crapsol WHERE crapsol.cdcooper = crapord.cdcooper   AND
                           crapsol.nrsolici = crapord.nrsolici   AND
                           crapsol.dtrefere = glb_dtmvtolt       AND
                           crapsol.insitsol = 1
                           NO-LOCK:

        IF  crapsol.nrsolici = 82 THEN
            ASSIGN aux_solic82 =  1.
      
        FOR EACH crapprg WHERE crapprg.cdcooper = crapsol.cdcooper   AND
                               crapprg.nrsolici = crapsol.nrsolici   AND 
                               crapprg.inlibprg = 1
                               USE-INDEX crapprg2 NO-LOCK:

            IF   crapprg.inctrprg = 1   THEN
                 DO:
                     IF   crapprg.cdprogra = aux_cdprogra   THEN
                          NEXT.

                     ASSIGN aux_cadeiaex = aux_cadeiaex + crapprg.cdprogra +
                                           STRING(crapord.inexclus)
                            aux_cdprogra = crapprg.cdprogra

                            aux_lscadeia = aux_lscadeia +
                                           SUBSTRING(crapprg.cdprogra,5,3) +
                                           IF crapord.inexclus = 1
                                              THEN "e "
                                              ELSE "p ".
                 END.
            ELSE
                 IF   NOT aux_flgrepro   THEN
                      DO:
                          glb_cdcritic = 147.
                          RUN fontes/critic.p.
                          UNIX SILENT VALUE("echo " +
                                            STRING(TIME,"HH:MM:SS") + " - " +
                                            glb_cdprogra + "' --> '" +
                                            glb_dscritic + " - "     +
                                            crapprg.cdprogra +
                                            " >> log/proc_batch.log").
                          PAUSE 2 NO-MESSAGE.
                          QUIT.
                      END.
        
        END.  /*  Fim do FOR EACH -- Leitura do cadastro de programas  */

    END.  /*  Fim do FOR EACH -- Leitura do cadastro de solicitacoes  */

END.  /*  Fim do FOR EACH -- Leitura do cadastro de ordem de execucao  */

IF   crapcop.cdcooper <> 99 THEN
     DO:
         IF   aux_solic82 = 0  AND 
              NOT aux_flgrepro THEN
              DO:
                  ASSIGN aux_mensagem = "Solicitacao 82 Nao Encontrada"
                         glb_cdcritic = 141.

                  RUN fontes/critic.p.
                  UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                    glb_cdprogra + "' --> '" +
                                    glb_dscritic + aux_mensagem +
                                    " >> log/proc_batch.log").
                  PAUSE 2 NO-MESSAGE.
                  QUIT.
              END.
     END.

IF   NOT aux_flgrepro    AND
     aux_cadeiaex = ""   THEN
     DO:
         glb_cdcritic = 142.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " +
                           STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" +
                           glb_dscritic +
                           " >> log/proc_batch.log").
         PAUSE 2 NO-MESSAGE.
         QUIT.
     END.

/*  Lista cadeia do Processo NOTURNO no arquivo de log ...................... */

UNIX SILENT VALUE("echo " + "Cadeia de Execucao - processo batch NOTURNO " +
                  " >> log/proc_batch.log").

aux_nrinides = 1.

DO aux_contador = 1 TO 15:
  
   IF   TRIM(SUBSTRING(aux_lscadeia,aux_nrinides,75)) <> ""  THEN
        UNIX SILENT VALUE("echo " + 
                          SUBSTRING(aux_lscadeia,aux_nrinides,75) +  
                          " >> log/proc_batch.log").

   aux_nrinides = aux_nrinides + 75.
 
END.  /*  Fim do DO .. TO  */

PAUSE 2 NO-MESSAGE.

/*  Inicio da primeira cadeia exclusiva ..................................... */

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                  "Inicio Primeira Cadeia Exclusiva batch NOTURNO referente " +
                  STRING(glb_dtmvtolt,"99/99/9999") +
                  " >> log/proc_batch.log").

RUN proc_roda_exclusivo.

/*  Inicio da cadeia paralela ............................................... */

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                  "Inicio Cadeia Paralela batch NOTURNO referente " +
                  STRING(glb_dtmvtolt,"99/99/9999") +
                  " >> log/proc_batch.log").

RUN proc_roda_paralelo.

/*  Inicio da segunda cadeia exclusiva ...................................... */

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                  "Inicio Segunda Cadeia Exclusiva batch NOTURNO referente " +
                  STRING(glb_dtmvtolt,"99/99/9999") +
                  " >> log/proc_batch.log").

RUN proc_roda_exclusivo.

/*  Verifica se os programas executaram ..................................... */

glb_cdprogra = "crps359".

FOR EACH crapord WHERE crapord.cdcooper = glb_cdcooper   AND
                       crapord.tpcadeia = 3 NO-LOCK:

    FOR EACH crapsol WHERE crapsol.cdcooper = crapord.cdcooper   AND
                           crapsol.nrsolici = crapord.nrsolici   AND
                           crapsol.dtrefere = glb_dtmvtolt
                           NO-LOCK:

        FOR EACH crapprg WHERE crapprg.cdcooper = crapsol.cdcooper   AND
                               crapprg.nrsolici = crapsol.nrsolici   AND
                               crapprg.inlibprg = 1
                               USE-INDEX crapprg2 NO-LOCK:

            IF   crapprg.inctrprg = 2   THEN
                 NEXT.
            ELSE
                 DO:
                     glb_cdcritic = 148.
                     RUN fontes/critic.p.
                     UNIX SILENT VALUE("echo " +
                                       STRING(TIME,"HH:MM:SS") + " - " +
                                       glb_cdprogra + "' --> '" + glb_dscritic +
                                       "'('" + crapprg.cdprogra + "')'" +
                                       " >> log/proc_batch.log").
                     glb_stprogra = FALSE.
                 END.

        END.  /*  Fim do FOR EACH -- Leitura do cadastro de programas  */

    END.  /*  Fim do FOR EACH -- Leitura do cadastro de solicitacoes  */

END.  /*  Fim do FOR EACH -- Leitura do cadastro de ordem de execucao  */

IF   glb_cdcritic > 0   THEN
     DO:
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" +
                           glb_dscritic + " >> log/proc_batch.log").
         QUIT.
     END.

/*  Atualiza indicador de processo (inproces) para 7 .......................  */

glb_cdprogra = "crps359".

DO TRANSACTION ON ERROR UNDO, RETURN.

   DO WHILE TRUE:

      FIND FIRST crapdat WHERE crapdat.cdcooper = glb_cdcooper
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF   NOT AVAILABLE crapdat   THEN
           IF   LOCKED crapdat   THEN
                DO:
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
           ELSE
                glb_cdcritic = 1.
      ELSE
           ASSIGN glb_cdcritic = 0
                  crapdat.inproces = 7.

      LEAVE.

   END.

END.  /* Fim da transacao */

RELEASE crapdat.

DO TRANSACTION ON ERROR UNDO, RETURN:

   FOR EACH crapage WHERE crapage.cdcooper = glb_cdcooper NO-LOCK:
   
       /* Atualiza tabela de controle dos GPS .............................. */
       FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                          craptab.nmsistem = "CRED"         AND
                          craptab.tptabela = "GENERI"       AND
                          craptab.cdempres = 00             AND
                          craptab.cdacesso = "HRGUIASGPS"   AND
                          craptab.tpregist = crapage.cdagenci
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE craptab   THEN
            DO:
                CREATE craptab.
                ASSIGN craptab.cdcooper = glb_cdcooper
                       craptab.nmsistem = "CRED"  
                       craptab.tptabela = "GENERI"
                       craptab.cdempres = 00           
                       craptab.cdacesso = "HRGUIASGPS"  
                       craptab.tpregist = crapage.cdagenci
                       craptab.dstextab = "1 64800".
            END.
             
       craptab.dstextab = "0" + SUBSTRING(craptab.dstextab,2,10).
       RELEASE craptab.
        

       /* Atualiza tabela de controle dos titulos .......................... */
       FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                          craptab.nmsistem = "CRED"         AND
                          craptab.tptabela = "GENERI"       AND
                          craptab.cdempres = 00             AND
                          craptab.cdacesso = "HRTRTITULO"   AND
                          craptab.tpregist = crapage.cdagenci
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE craptab   THEN
            DO:
                CREATE craptab.
                ASSIGN craptab.cdcooper = glb_cdcooper
                       craptab.nmsistem = "CRED"  
                       craptab.tptabela = "GENERI"
                       craptab.cdempres = 00           
                       craptab.cdacesso = "HRTRTITULO"  
                       craptab.tpregist = crapage.cdagenci
                       craptab.dstextab = "1 64800 21600 NAO".
            END.
             
       craptab.dstextab = "0" + SUBSTRING(craptab.dstextab,2).
       
       RELEASE craptab.

       /* Atualiza a tabela de controle da comp eletronica ................. */
       FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                          craptab.nmsistem = "CRED"         AND
                          craptab.tptabela = "GENERI"       AND
                          craptab.cdempres = 00             AND
                          craptab.cdacesso = "HRTRCOMPEL"   AND
                          craptab.tpregist = crapage.cdagenci
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE craptab   THEN
            DO:
                CREATE craptab.
                ASSIGN craptab.cdcooper = glb_cdcooper
                       craptab.nmsistem = "CRED"  
                       craptab.tptabela = "GENERI"
                       craptab.cdempres = 00           
                       craptab.cdacesso = "HRTRCOMPEL"  
                       craptab.tpregist = crapage.cdagenci
                       craptab.dstextab = "0 58500".
            END.
        
       SUBSTRING(craptab.dstextab,1,1) = "0".
       RELEASE craptab.
       
       
       /* Atualiza a tabela de controle dos DOC'S e TED'S ............. */
       FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                          craptab.nmsistem = "CRED"         AND
                          craptab.tptabela = "GENERI"       AND
                          craptab.cdempres = 00             AND
                          craptab.cdacesso = "HRTRDOCTOS"   AND
                          craptab.tpregist = crapage.cdagenci
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE craptab   THEN
            DO:
                CREATE craptab.
                ASSIGN craptab.cdcooper = glb_cdcooper
                       craptab.nmsistem = "CRED"  
                       craptab.tptabela = "GENERI"
                       craptab.cdempres = 00           
                       craptab.cdacesso = "HRTRDOCTOS"  
                       craptab.tpregist = crapage.cdagenci
                       craptab.dstextab = "0 58500,DOC 0 54000,TED".
            END.
        
       SUBSTRING(craptab.dstextab,1,1)  = "0".
       SUBSTRING(craptab.dstextab,13,1) = "0".
       RELEASE craptab.
       

       /* Cria a tabela de horario para pagtos do INSS ..................... */
       FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                          craptab.nmsistem = "CRED"         AND
                          craptab.tptabela = "GENERI"       AND
                          craptab.cdempres = 00             AND
                          craptab.cdacesso = "HRPGTOINSS"   AND
                          craptab.tpregist = crapage.cdagenci
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE craptab   THEN
            DO:
                CREATE craptab.
                ASSIGN craptab.cdcooper = glb_cdcooper
                       craptab.nmsistem = "CRED"  
                       craptab.tptabela = "GENERI"
                       craptab.cdempres = 00           
                       craptab.cdacesso = "HRPGTOINSS"  
                       craptab.tpregist = crapage.cdagenci
                       craptab.dstextab = "0 58500".
            END.
        
       RELEASE craptab.

   END. /* for each crapage. */

END. /* fim do DO TRANSACTION */

IF   glb_cdcritic > 0   THEN
     DO:
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" + glb_dscritic +
                               " >> log/proc_batch.log").
         PAUSE 2 NO-MESSAGE.
         QUIT.
      END.

/*  Recebe o log dos caixas eletronicos ..................................... */

RUN proc_log_cashes.


/*  -------------------------------------------------------------------------
    NAO GERAR MAIS OS ARQUIVOS procferNNN - EDSON - 09/05/2006
    Serao gerados pelo crps000.p

/*  Gera arquivos Feriados(Nao rodar processo noturno - apenas cash) .......  */

FIND FIRST crapdat WHERE crapdat.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
 
ASSIGN aux_qtdias = crapdat.dtmvtopr - crapdat.dtmvtolt
       aux_qtcont = 1.

DO WHILE  aux_qtcont <=  aux_qtdias - 1.

   ASSIGN aux_nmarqv = "arquivos/.procfer" + STRING(aux_qtcont).
   OUTPUT STREAM str_2 TO VALUE(aux_nmarqv).
   OUTPUT STREAM str_2 CLOSE.
        
   ASSIGN aux_qtcont = aux_qtcont + 1.
    
END.  /*  Fim do DO WHILE TRUE  */
---------------------------------------------------------------------------   */

/*  Gera arquivo indicando final de processo - ok(Noturno) .................  */

UNIX SILENT > arquivos/.procnotok 2>/dev/null.

UNIX SILENT > controles/crps359.ok 2> /dev/null.    /*  Controle script  */

/*  Registra fim do processo BATCH NOTURNO .................................  */

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                  "Fim do processo batch NOTURNO referente " +
                  STRING(glb_dtmvtolt,"99/99/9999") +
                  " em " + STRING(TODAY,"99/99/9999") + 
                  " da " + STRING(crapcop.nmrescop,"x(20)") +
                  " >> log/proc_batch.log").

RUN p_desconectagener.   /* Desconectar Banco  Generico */

QUIT.

/* .......................................................................... */
/*                      ** P R O C E D U R E S **                             */
/* .......................................................................... */

PROCEDURE proc_roda_exclusivo:

    glb_cdprogra = "crps359".

    DO WHILE INTEGER(SUBSTRING(aux_cadeiaex,aux_nrposprg + 7,1)) = 1:

       glb_stprogra = FALSE.

       aux_nmdobjet = "fontes/" +
                      LC(SUBSTRING(aux_cadeiaex,aux_nrposprg,7) + ".p").
   
       aux_nmcobjet = SEARCH(aux_nmdobjet).

       IF   aux_nmcobjet <> ?   THEN
            DO:
                FIND FIRST crapprg WHERE 
                     crapprg.cdcooper = glb_cdcooper   AND
                     crapprg.cdprogra = LC(SUBSTR(aux_cadeiaex,aux_nrposprg,7))
                     NO-LOCK NO-ERROR.
                                     
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                  glb_cdprogra + "' --> '" +
                                  "Inicio da execucao: " +
                                  LC(SUBSTRING(aux_cadeiaex,aux_nrposprg,7)) +
                                  (IF AVAILABLE crapprg
                                   THEN " - '" + LC(crapprg.dsprogra[1]) + "'"  
                                   ELSE "") +
                                  " >> log/proc_batch.log").

                { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
                RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
                    (INPUT "PI",
                     INPUT SUBSTRING(aux_nmdobjet, 8),
                     input glb_cdcooper,
                     input 1, /* tpexecucao */
                     input 4, /* tpocorrencia */
                     input 0, /* cdcriticidade */
                     input 0, /* cdmensagem */
                     input "PI exclusivo noturno", /* dsmensagem */                                          
                     input 1,  /* flgsucesso */
                     INPUT "", /* nmarqlog */
                     input 0,  /* flabrechamado */
                     input "", /* texto_chamado */
                     input "", /* destinatario_email */
                     input 0,  /* flreincidente */
                     INPUT 0   /* idprglog */                     
                     ).
                CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
                { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
		   
				/* Geração do registro no cadastro tbgen quando um programa he reiniciado na cadeia, chd REQ0013442, 10/05/2018 */
				IF aux_flgrepro AND
                   aux_injareex = "N" THEN
                  DO:				
                     ASSIGN aux_injareex = "S". /* INDICANDO QUE AINDA NAO REXECUTOU O PROCESSO */

                     ASSIGN aux_cdcrimsg = 1231
                            aux_dscrimsg = "crapcri nao encontrada".	
							
                     FIND crapcri WHERE crapcri.cdcritic = aux_cdcrimsg
                                        NO-LOCK NO-ERROR.                            
                     IF AVAIL crapcri THEN
                       ASSIGN aux_dscrimsg = crapcri.dscritic. 
					   
                     { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
					 
                     RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
                    (input "O",                        /* Tipo do log: I - inicio, F - fim, O - ocorrencia */
                     input SUBSTRING(aux_nmdobjet, 8), /* Codigo do programa ou do job */
                     input glb_cdcooper,               /* Codigo da cooperativa */
                     input 1,  /* Tipo de execucao   0-Outro, 1-Batch, 2-Job, 3-Online  */
                     input 4,  /* tipo de ocorrencia 1-Erro de negocio, 2-Erro nao tratado, 3-Alerta, 4-Mensagem */
                     input 0,  /* Nivel criticidade  0-Baixa, 1-Media, 2-Alta, 3-Critica  */
                     input aux_cdcrimsg,
                     input aux_dscrimsg,                     
                     input 1,  /* Indicador de sucesso da execução */
                     input "", /* Nome do arquivo */
                     input 0,  /* Abre chamado sim/nao */
                     input "", /* Texto do chamado */
                     input "", /* Destinatario do email */
                     input 0,  /* Erro pode reincidir no prog em dias diferentes, devendo abrir chamado */
                     input 0   /* Identificador unico da tabela (sequence) */
					 ).
					 
                CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
					 
                { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
                  END.

                RUN VALUE("fontes/" +
                          LC(SUBSTRING(aux_cadeiaex,aux_nrposprg,7) + ".p")).

                { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
                RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
                    (INPUT "PF",
                     INPUT SUBSTRING(aux_nmdobjet, 8),
                     input glb_cdcooper,
                     input 1,
                     input 4,
                     input 0,
                     input 0,
                     input "PF exclusivo noturno",                     
                     input 1,  /* flgsucesso */
                     INPUT "", /* nmarqlog */
                     input 0,  /* flabrechamado */
                     input "", /* texto_chamado */
                     input "", /* destinatario_email */
                     input 0,  /* flreincidente */
                     INPUT 0).
                CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
                { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }


                IF   glb_stprogra   THEN
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '" + 
                                       "Execucao ok " +
                                       " >> log/proc_batch.log").
                ELSE
				
                DO:
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '" +
                                       "PROGRAMA COM ERRO" +
                                       " >> log/proc_batch.log").

					 /* Geração do registro no cadastro tbgen quando um programa para a cadeia, chd REQ0013442, 10/05/2018 */
						
                     ASSIGN aux_cdcrimsg = 1229
                            aux_dscrimsg = "crapcri nao encontrada".	
							
                     FIND crapcri WHERE crapcri.cdcritic = aux_cdcrimsg
                                        NO-LOCK NO-ERROR.                            
                     IF AVAIL crapcri THEN
                       ASSIGN aux_dscrimsg = crapcri.dscritic. 
					   
                     { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
					 
                     RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
                    (input "O",                        /* Tipo do log: I - inicio, F - fim, O - ocorrencia */
                     input SUBSTRING(aux_nmdobjet, 8), /* Codigo do programa ou do job */
                     input glb_cdcooper,               /* Codigo da cooperativa */
                     input 1,  /* Tipo de execucao   0-Outro, 1-Batch, 2-Job, 3-Online  */
                     input 4,  /* tipo de ocorrencia 1-Erro de negocio, 2-Erro nao tratado, 3-Alerta, 4-Mensagem */
                     input 0,  /* Nivel criticidade  0-Baixa, 1-Media, 2-Alta, 3-Critica  */
                     input aux_cdcrimsg,
                     input aux_dscrimsg,                     
                     input 1,  /* Indicador de sucesso da execução */
                     input "", /* Nome do arquivo */
                     input 0,  /* Abre chamado sim/nao */
                     input "", /* Texto do chamado */
                     input "", /* Destinatario do email */
                     input 0,  /* Erro pode reincidir no prog em dias diferentes, devendo abrir chamado */
                     input 0   /* Identificador unico da tabela (sequence) */
					 ).
					 
                     CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
					 
                     { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }	
                END.

                glb_cdprogra = "crps359".
            END.
       ELSE
            DO:
                glb_cdcritic = 153.
                RUN fontes/critic.p.
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                  glb_cdprogra + "' --> '" + aux_nmdobjet + 
                                  " - " +
                                  glb_dscritic + " >> log/proc_batch.log").
            END.

       IF   glb_stprogra    THEN
            aux_nrposprg = aux_nrposprg + 8.
       ELSE
            QUIT.
   
       PAUSE 2 NO-MESSAGE.
    
    END.  /*  Fim do DO WHILE TRUE  */

END PROCEDURE.

PROCEDURE proc_roda_paralelo:

    glb_cdprogra = "crps359".

    ASSIGN aux_qtprgpar = 0
           aux_cdprgpar = ""
           aux_flgerrcp = FALSE
           aux_flgcadpl = FALSE.

    DO WHILE INTEGER(SUBSTRING(aux_cadeiaex,aux_nrposprg + 7,1)) = 2:

       ASSIGN glb_stprogra = FALSE

              aux_nmdobjet = "fontes/" +
                             LC(SUBSTRING(aux_cadeiaex,aux_nrposprg,7) + ".p")

              aux_nmcobjet = SEARCH(aux_nmdobjet)
          
              aux_nrpidprg = 0.

       IF   aux_nmcobjet = ?   THEN
            DO:
                glb_cdcritic = 153.
                RUN fontes/critic.p.
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                   glb_cdprogra + "' --> '" + 
                                   "PROGRAMA COM ERRO: " +
                                   aux_nmdobjet + " - " +
                                   glb_dscritic + " >> log/proc_batch.log").

                ASSIGN aux_nrposprg = aux_nrposprg + 8
                       aux_flgerrcp = TRUE.
                
                NEXT.          /*  Executa proximo da lista  */
            END.
   
       FIND crapprg WHERE crapprg.cdcooper = glb_cdcooper   AND
                          crapprg.cdprogra = 
                              LC(SUBSTRING(aux_cadeiaex,aux_nrposprg,7))   AND
                          crapprg.nmsistem = "CRED"
                          USE-INDEX crapprg1 NO-LOCK NO-ERROR.
            
       IF   NOT AVAILABLE crapprg   THEN
            DO:
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                  glb_cdprogra + "' --> '" +
                                  "Inicio da execucao paralela: " +
                                  LC(SUBSTRING(aux_cadeiaex,aux_nrposprg,7)) +
                                  (IF AVAILABLE crapprg
                                     THEN " - '" + LC(crapprg.dsprogra[1]) + "'"
                                     ELSE "") +
                                  " >> log/proc_batch.log").

                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                  LC(SUBSTR(aux_cadeiaex,aux_nrposprg,7)) +
                                  "' --> '" + "PROGRAMA COM ERRO: " +
                                  "Registro no crapprg NAO ENCONTRADO" +
                                  " >> log/proc_batch.log").

                ASSIGN aux_nrposprg = aux_nrposprg + 8
                       aux_flgerrcp = TRUE.
                       
                NEXT.          /*  Executa proximo da lista  */
            END.

				/* Geração do registro no cadastro tbgen quando um programa he reiniciado na cadeia, chd REQ0013442, 10/05/2018 */
				IF aux_flgrepro AND
                   aux_injareex = "N" THEN
                  DO:				
                     ASSIGN aux_injareex = "S". /* INDICANDO QUE AINDA NAO REXECUTOU O PROCESSO */

                     ASSIGN aux_cdcrimsg = 1231
                            aux_dscrimsg = "crapcri nao encontrada".	
							
                     FIND crapcri WHERE crapcri.cdcritic = aux_cdcrimsg
                                        NO-LOCK NO-ERROR.                            
                     IF AVAIL crapcri THEN
                       ASSIGN aux_dscrimsg = crapcri.dscritic. 
					   
       { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }       
					 
       RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
                    (input "O",                        /* Tipo do log: I - inicio, F - fim, O - ocorrencia */
                     input "CRPS359.P",                  /* Codigo do programa ou do job */
                     input glb_cdcooper,               /* Codigo da cooperativa */
                     input 1,  /* Tipo de execucao   0-Outro, 1-Batch, 2-Job, 3-Online  */
                     input 4,  /* tipo de ocorrencia 1-Erro de negocio, 2-Erro nao tratado, 3-Alerta, 4-Mensagem */
                     input 0,  /* Nivel criticidade  0-Baixa, 1-Media, 2-Alta, 3-Critica  */
                     input aux_cdcrimsg,
                     input aux_dscrimsg,                     
                     input 1,  /* Indicador de sucesso da execução */
                     input "", /* Nome do arquivo */
                     input 0,  /* Abre chamado sim/nao */
                     input "", /* Texto do chamado */
                     input "", /* Destinatario do email */
                     input 0,  /* Erro pode reincidir no prog em dias diferentes, devendo abrir chamado */
                     input 0   /* Identificador unico da tabela (sequence) */
					 ).
					 
                     CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
					 
                     { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }	
                  END.

       { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }       
       RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
           (INPUT "PI",
            INPUT SUBSTRING(aux_nmdobjet, 8),
            input glb_cdcooper,
            input 1,
            input 4,
            input 0,
            input 0,
            input "PI paralelo noturno",
            input 1,
            INPUT "", /* nmarqlog */
            input 0,  /* flabrechamado */
            input "", /* texto_chamado */
            input "", /* destinatario_email */
            input 0,  /* flreincidente */
            INPUT 0).
       CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
       { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

       INPUT STREAM str_mp THROUGH VALUE
             ("cecred_mbpro" + 
              " -pf arquivos/PROC_cron.pf " +
              " -p fontes/" + LC(SUBSTR(aux_cadeiaex,aux_nrposprg,7) +
              ".p")) NO-ECHO.

       SET STREAM str_mp aux_dspidprg FORMAT "x(30)" WITH FRAME f_monproc.
            
       INPUT STREAM str_mp CLOSE.

       { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
       RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
           (INPUT "PF",
            INPUT SUBSTRING(aux_nmdobjet, 8),
            input glb_cdcooper,
            input 1,
            input 4,
            input 0,
            input 0,
            input "PF paralelo noturno",
            input 1,
            INPUT "", /* nmarqlog */
            input 0,  /* flabrechamado */
            input "", /* texto_chamado */
            input "", /* destinatario_email */
            input 0,  /* flreincidente */
            INPUT 0).
       CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
       { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

       ASSIGN aux_nrpidprg = INT(aux_dspidprg) NO-ERROR.

       IF   ERROR-STATUS:ERROR   THEN
            DO:
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                  " - " + glb_cdprogra + "' --> '" +
                                  "Inicio da execucao paralela: " +
                                  LC(SUBSTRING(aux_cadeiaex,aux_nrposprg,7)) +
                                  (IF AVAILABLE crapprg
                                     THEN " - '" + LC(crapprg.dsprogra[1]) + "'"
                                     ELSE "") +
                                  " >> log/proc_batch.log").
                              
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                  LC(SUBSTR(aux_cadeiaex,aux_nrposprg,7)) +
                                  "' --> '" + "PROGRAMA COM ERRO: " +
                                  "cecred_mbpro FALHOU" + 
                                  " >> log/proc_batch.log").

					 /* Geração do registro no cadastro tbgen quando um programa para a cadeia, chd REQ0013442, 10/05/2018 */
						
                     ASSIGN aux_cdcrimsg = 1278
                            aux_dscrimsg = "crapcri nao encontrada".	
							
                     FIND crapcri WHERE crapcri.cdcritic = aux_cdcrimsg
                                        NO-LOCK NO-ERROR.                            
                     IF AVAIL crapcri THEN
                       ASSIGN aux_dscrimsg = crapcri.dscritic. 
					   
                     { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
					 
                     RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
                    (input "O",                        /* Tipo do log: I - inicio, F - fim, O - ocorrencia */
                     input SUBSTR(aux_cadeiaex,aux_nrposprg,7), /* Codigo do programa ou do job */
                     input glb_cdcooper,               /* Codigo da cooperativa */
                     input 1,  /* Tipo de execucao   0-Outro, 1-Batch, 2-Job, 3-Online  */
                     input 4,  /* tipo de ocorrencia 1-Erro de negocio, 2-Erro nao tratado, 3-Alerta, 4-Mensagem */
                     input 0,  /* Nivel criticidade  0-Baixa, 1-Media, 2-Alta, 3-Critica  */
                     input aux_cdcrimsg,
                     input aux_dscrimsg,                     
                     input 1,  /* Indicador de sucesso da execução */
                     input "", /* Nome do arquivo */
                     input 0,  /* Abre chamado sim/nao */
                     input "", /* Texto do chamado */
                     input "", /* Destinatario do email */
                     input 0,  /* Erro pode reincidir no prog em dias diferentes, devendo abrir chamado */
                     input 0   /* Identificador unico da tabela (sequence) */
					 ).
					 
                     CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
					 
                     { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

                ASSIGN aux_nrposprg = aux_nrposprg + 8
                       aux_flgerrcp = TRUE.

                NEXT.          /*  Executa proximo da lista  */
            END.

       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                         glb_cdprogra + "' --> '" +
                         "Inicio da execucao paralela: " +
                         "PID = " + STRING(aux_nrpidprg) + ": " +
                         LC(SUBSTRING(aux_cadeiaex,aux_nrposprg,7)) +
                         (IF AVAILABLE crapprg
                             THEN " - '" + LC(crapprg.dsprogra[1]) + "'"  
                             ELSE "") + " >> log/proc_batch.log").

       aux_lsprogra = "".
   
       DO aux_contapar = 1 TO aux_qtparale:
   
          IF   aux_cdprgpar[aux_contapar] <> ""   THEN
               DO:
                   aux_lsprogra = aux_lsprogra + " fontes/" +
                                  aux_cdprgpar[aux_contapar] + ".p".
                   NEXT.
               END.

          ASSIGN aux_cdprgpar[aux_contapar] = 
                              SUBSTRING(aux_cadeiaex,aux_nrposprg,7)

                 aux_mtpidprg[aux_contapar] = aux_nrpidprg

                 aux_lsprogra = aux_lsprogra + " fontes/" +
                                aux_cdprgpar[aux_contapar] + ".p"
             
                 aux_flgcadpl = TRUE.               
       
          LEAVE.
   
       END.  /*  Fim do DO .. TO  */

       ASSIGN aux_qtprgpar = aux_qtprgpar + 1
              aux_nrposprg = aux_nrposprg + 8.

       DO WHILE aux_qtprgpar = aux_qtparale:

          RUN proc_espera_paralelos.
      
          PAUSE 2 NO-MESSAGE.

       END.  /*  Fim do DO WHILE  */

    END.  /*  Fim do DO WHILE TRUE  */

    IF   NOT aux_flgrepro   AND
         NOT aux_flgcadpl   THEN
         DO:
             aux_flgerrcp = TRUE.

             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                               glb_cdprogra + "' --> '" +
                               "ERRO: Nenhum programa da cadeia paralela " +
                               "foi executado." + " >> log/proc_batch.log").
         END.

    DO WHILE aux_qtprgpar > 0:      /* Espera os paralelos terminarem */

       RUN proc_espera_paralelos.
   
       PAUSE 2 NO-MESSAGE.

    END.  /*  Fim do DO WHILE  */

    IF   aux_flgerrcp   THEN
         DO:
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                               glb_cdprogra + "' --> '" +
                               "ERRO: Abortando processo NOTURNO" +
                               " >> log/proc_batch.log").

             UNIX SILENT VALUE("> controles/Proc_Noturno.Erro").

					 /* Geração do registro no cadastro tbgen quando um programa para a cadeia, chd REQ0013442, 10/05/2018 */
						
                     ASSIGN aux_cdcrimsg = 1229
                            aux_dscrimsg = "crapcri nao encontrada".	
							
                     FIND crapcri WHERE crapcri.cdcritic = aux_cdcrimsg
                                        NO-LOCK NO-ERROR.                            
                     IF AVAIL crapcri THEN
                       ASSIGN aux_dscrimsg = crapcri.dscritic. 
					   
                     { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
					 
                     RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
                    (input "O",                        /* Tipo do log: I - inicio, F - fim, O - ocorrencia */
                     input "CRPS359.P", /* Codigo do programa ou do job */
                     input glb_cdcooper,               /* Codigo da cooperativa */
                     input 1,  /* Tipo de execucao   0-Outro, 1-Batch, 2-Job, 3-Online  */
                     input 4,  /* tipo de ocorrencia 1-Erro de negocio, 2-Erro nao tratado, 3-Alerta, 4-Mensagem */
                     input 0,  /* Nivel criticidade  0-Baixa, 1-Media, 2-Alta, 3-Critica  */
                     input aux_cdcrimsg,
                     input aux_dscrimsg,                     
                     input 1,  /* Indicador de sucesso da execução */
                     input "", /* Nome do arquivo */
                     input 0,  /* Abre chamado sim/nao */
                     input "", /* Texto do chamado */
                     input "", /* Destinatario do email */
                     input 0,  /* Erro pode reincidir no prog em dias diferentes, devendo abrir chamado */
                     input 0   /* Identificador unico da tabela (sequence) */
					 ).
					 
                     CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
					 
                     { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }	

             QUIT.
         END.

END PROCEDURE.

PROCEDURE proc_espera_paralelos:
    
    DO aux_contapar = 1 TO aux_qtparale:

       IF   aux_mtpidprg[aux_contapar] = 0   THEN
            NEXT.
         
       INPUT STREAM str_mp THROUGH VALUE("ps -p " + 
                                         STRING(aux_mtpidprg[aux_contapar]) +
                                         " > /dev/null ; " +
                                         " echo $?") NO-ECHO.
                                           
       SET STREAM str_mp aux_nrmonpid.
         
       INPUT STREAM str_mp CLOSE.
         
       IF   aux_nrmonpid = 0   THEN
            NEXT.
 
       FIND crapprg WHERE crapprg.cdcooper = glb_cdcooper   AND
                          crapprg.cdprogra = aux_cdprgpar[aux_contapar]   AND
                          crapprg.nmsistem = "CRED"
                          USE-INDEX crapprg1 NO-LOCK NO-ERROR.

       IF   AVAILABLE crapprg   THEN
            IF   crapprg.inctrprg = 2   THEN
                 DO:
                     UNIX SILENT VALUE("echo " +
                                       STRING(TIME,"HH:MM:SS") + " - " +
                                       LC(aux_cdprgpar[aux_contapar]) + 
                                       "' --> '" + "Execucao ok " +
                                       " >> log/proc_batch.log").

                     ASSIGN aux_cdprgpar[aux_contapar] = ""
                            aux_mtpidprg[aux_contapar] = 0
                            aux_qtprgpar = aux_qtprgpar - 1.
                 END.
            ELSE
                 DO:
                     UNIX SILENT VALUE("echo " +
                                       STRING(TIME,"HH:MM:SS") + " - " +
                                       LC(aux_cdprgpar[aux_contapar]) + 
                                       "' --> '" + "PROGRAMA COM ERRO" +
                                       " >> log/proc_batch.log").
            
					 /* Geração do registro no cadastro tbgen quando um programa para a cadeia, chd REQ0013442, 10/05/2018 */
						
                     ASSIGN aux_cdcrimsg = 1278
                            aux_dscrimsg = "crapcri nao encontrada".	
							
                     FIND crapcri WHERE crapcri.cdcritic = aux_cdcrimsg
                                        NO-LOCK NO-ERROR.                            
                     IF AVAIL crapcri THEN
                       ASSIGN aux_dscrimsg = crapcri.dscritic. 
					   
                     { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
					 
                     RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
                    (input "O",                        /* Tipo do log: I - inicio, F - fim, O - ocorrencia */
                     input aux_cdprgpar[aux_contapar], /* Codigo do programa ou do job */
                     input glb_cdcooper,               /* Codigo da cooperativa */
                     input 1,  /* Tipo de execucao   0-Outro, 1-Batch, 2-Job, 3-Online  */
                     input 4,  /* tipo de ocorrencia 1-Erro de negocio, 2-Erro nao tratado, 3-Alerta, 4-Mensagem */
                     input 0,  /* Nivel criticidade  0-Baixa, 1-Media, 2-Alta, 3-Critica  */
                     input aux_cdcrimsg,
                     input aux_dscrimsg,                     
                     input 1,  /* Indicador de sucesso da execução */
                     input "", /* Nome do arquivo */
                     input 0,  /* Abre chamado sim/nao */
                     input "", /* Texto do chamado */
                     input "", /* Destinatario do email */
                     input 0,  /* Erro pode reincidir no prog em dias diferentes, devendo abrir chamado */
                     input 0   /* Identificador unico da tabela (sequence) */
					 ).
					 
                     CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
					 
                     { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }	
            
                     ASSIGN aux_cdprgpar[aux_contapar] = ""
                            aux_mtpidprg[aux_contapar] = 0
                            aux_qtprgpar = aux_qtprgpar - 1
                            aux_flgerrcp = TRUE.
                 END.

    END.  /*  Fim do DO .. TO  */
    
END PROCEDURE.

PROCEDURE proc_remove_arquivos:

    DEF VAR aux_nmrelato AS CHAR                    NO-UNDO.
    DEF VAR aux_nomedarq AS CHAR                    NO-UNDO.
    DEF VAR aux_dtmvtolt AS DATE                    NO-UNDO.


    ASSIGN aux_nmrelato = "crrl488,crrl517,crrl518,crrl519".

    DO aux_contador = 1 TO NUM-ENTRIES(aux_nmrelato):

        /* Lista todos os relatorios com*/
        INPUT STREAM str_1 THROUGH VALUE("ls log/" + 
                                         ENTRY(aux_contador,aux_nmrelato) +
                                         "*" + " 2>/dev/null") NO-ECHO.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            SET STREAM str_1 aux_nomedarq FORMAT "x(70)". 

            ASSIGN aux_nomedarq = REPLACE(aux_nomedarq,".lst","")
                   aux_dtmvtolt = DATE (ENTRY(6,aux_nomedarq,"_")). 
            
            /* Se arquivo foi gerado ha mais de 10 dias */
            IF   (glb_dtmvtolt - aux_dtmvtolt) > 10  THEN
                 DO:
                    UNIX SILENT VALUE ("rm " + aux_nomedarq + "*" + 
                                       " 2> /dev/null").
                 END.
        END.

    END. /* Para todos esses relatorios*/

    UNIX SILENT VALUE("rm " +
                      "rl/crrl*.lst rl/O*.lst arq/pd* arq/d0* arq/cot* "   +
                      "arq/emp* arq/2* rl/*.ex arq/cv* arq/btv* arq/sag* " +
                      "arq/cb* arq/pmb* arq/*embc*.txt "                   +
                      "/usr/coop/sistema/siscaixa/web/spool/*.ret "        +
                      "arq/*.ok arq/cm* arq/LDEV* arq/pmg* tmppdf/* "      +
                      "converte/* integra/Taxa_Aplic* "                    +
                      "2> /dev/null").
                      
    UNIX SILENT VALUE("rm " +
                      "/micros/" + crapcop.dsdircop + "/titulos/* "       +
                      "/micros/" + crapcop.dsdircop + "/pedido/* "        +
                      "/micros/" + crapcop.dsdircop + "/devolu/* "        +
                      "/micros/" + crapcop.dsdircop + "/interprint/* "    +
                      "/micros/" + crapcop.dsdircop + "/contab/*.bak "    +
                      "/micros/" + crapcop.dsdircop + "/prefeitura/* "    +
                      "2> /dev/null").

    UNIX SILENT VALUE("rm " +
                      "/micros/" + crapcop.dsdircop + "/e-mail/* "        +
                      "/micros/" + crapcop.dsdircop + "/bancoob/ch*.CBE " +
                      "/micros/" + crapcop.dsdircop + "/bancoob/dc*.CBE " +
                      "/micros/" + crapcop.dsdircop + "/bancoob/ti*.CBE " +
                      "/micros/" + crapcop.dsdircop + "/bancoob/dev*.rem " +
                      "/micros/" + crapcop.dsdircop + "/arrecada/*embc* " +
                      "2> /dev/null").

END PROCEDURE.

PROCEDURE proc_log_cashes:
    
    DEF VAR aux_dscomand AS CHAR NO-UNDO.
    
    FIND FIRST craptfn WHERE craptfn.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE craptfn   THEN
         RETURN.
         
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                      "Inicio da recepcao do log dos caixas eletronicos" +
                      " >> log/proc_batch.log").

    FOR EACH craptfn WHERE craptfn.cdcooper = glb_cdcooper   AND
                           craptfn.cdsitfin < 8              AND /* 8-desativado */ 
                           craptfn.flsistaa = NO    
                           NO-LOCK BY craptfn.cdagenci
                                     BY craptfn.nrterfin:

        aux_dscomand = "BuscaArquivoPC.sh "   +
                       craptfn.nmnarede + " " +
                       "LOGDIARIO$ " +
                       "ftp_cash " +
                       "ftpserver " +
                       "lg" + STRING(craptfn.nrterfin,"9999") + "_" +
                       STRING(YEAR(glb_dtmvtolt),"9999") +
                       STRING(MONTH(glb_dtmvtolt),"99") +
                       STRING(DAY(glb_dtmvtolt),"99") + ".log " +
                       STRING(craptfn.nrterfin,"9999") +
                       " 1>/dev/null 2>/dev/null".

        UNIX SILENT VALUE(aux_dscomand).
        
    END.  /*  Fim do FOR EACH  */

    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                      "Fim da recepcao do log dos caixas eletronicos" +
                      " >> log/proc_batch.log").

END PROCEDURE.

/* .......................................................................... */

