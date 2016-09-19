/* ..........................................................................

   Programa: Fontes/crps000.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Novembro/91.                    Ultima atualizacao: 03/03/2016

   Dados referentes ao programa:

   Frequencia: Diario (Batch)
   Objetivo  : Controlar o processo Batch.

   Alteracoes: 21/06/94 - Alterado para liberar a tabela de taxa de liquidacao
                          dos emprestimos apos o mensal.

               18/07/94 - Alterado o nome do arquivo de pedido de talonarios
                          que eh removido (Deborah).

               08/09/94 - Alterado para liberar a tabela de execucao da limpe-
                          za do cadastro apos o anual (Edson).

               18/11/94 - Alterado para liberar a tabela de execucao da limpeza
                          dos estouros (crapneg) quando for processo anual
                          (Deborah).

               25/01/95 - Alterado para liberar a tabela de execucao das fichas
                          de recadastramento dos admitidos quando for processo
                          mensal.

               24/05/95 - Alterado para no final do processo mensal tratar o
                          arquivo crapemp (Odair).

               16/11/95 - Alterado para tratar tpdebden no final do processo
                          mensal (Odair).

               21/03/96 - Alterado para passar Herco, Resima e Credito para
                          debito em conta (Deborah).

               25/03/96 - Alterado para passar Consumo, Associacao e Prayon
                          para debito em conta (Deborah).

               02/05/96 - Alterado para no final do processo mensal, tratar
                          crapemp (Odair).

               18/07/96 - Alterado para excluir os arquivos arq/telesc.*
                          arq/tel*, arq/deb*. (Odair).

               12/08/96 - Alterado para passar Administracao para debito em
                          conta (Deborah).

               20/08/96 - Alterado para remover somente arq/tel* (Deborah).

               23/08/96 - Acerto para nao remover os arquivos na inicializacao
                          se houver critica (Deborah).

               09/09/96 - Alterado para tratar as datas de aviso da empresa 1
                          (Deborah).

               01/10/96 - Alterado para gerar os avisos das empresas 09, 13 e
                          29 juntamente com os da 01 (Edson).

               30/10/96 - Alterado para tratar a tabela de controle de recepcao
                          de arquivos da Telesc (Deborah).

               18/11/96 - Alterado para zerar o indicador de integracao de folha
                          (Edson).

               18/12/96 - Alterado para tratar os avisos de debito de seguro
                          de casa (Edson).

               20/01/97 - Alterado para tratar Lojas Hering - debito em conta
                          dos descontos (Deborah).

               20/02/97 - Tratar no processo mensal o crapemp para o plano de
                          saude Hering (Odair).

               28/02/97 - Alterado para diminuir o prazo de consulta a PROCEDA
                          (Deborah).

               30/04/97 - Alterado para nao zerar o indicador de integracao de
                          folha de pagamento - foi movido para o crps078
                          (Edson).

               22/05/97 - Alterado para alimentar a tabela de execucao de con-
                          venios. (Deborah)

               02/06/97 - Alterado para eliminar tratamento de convenios de
                          dentistas (Deborah) e alterada o layout da cadeia
                          de execucao (Edson).

               04/07/97 - Alterado para liberar a tabela de execucao do
                          extrato quinzenal no final do mensal. (Deborah).

               10/07/97 - Tirar tratamento tpdebsau (Odair)

               19/08/97 - Alterado para remover arq/cas* (Odair)

               21/08/97 - Alterar data exesolcart (Odair)

               19/09/97 - Remover arquivos arq/cv* (Odair)

               17/04/98 - Tratamento para milenio e troca para V8 (Magui).

               29/06/98 - Remover arquivos arq/sam* (Odair)
               
               03/09/98 - Nao remover mais arquivos do arq de convenios (Odair)

               14/09/98 - Alterado para acerto do milenio (Edson).

               18/09/98 - Incluir a impressao do relatorio geral de atendi-
                          mento no processo mensal (Deborah).

               02/10/98 - Eliminar a mensagem do consulta a Proceda e 
                          mostrar no log se esta faltando cadastramento do
                          dolar de faturas Bradesco-Visa (Deborah).

               06/11/98 - Salvar o log dia anterior no salvar (Deborah).
               
               12/11/98 - Acerto na ultima alteracao (Deborah).

               18/11/98 - Remover os arquivos do diretorio interprint
                          (Deborah).

               02/12/98 - Tratar tabela de lotes para o Bancoob (Deborah).  
               
               22/12/98 - Remover os arquivos do diretorio bancoob
                          (Deborah).

               03/03/99 - Tratar empresas novas (Deborah).

               31/03/1999 - Acerto para empresa 6 (Deborah).

               16/04/1999 - Remover arquivos do diretorio /micros/pedido
                            (Deborah).

               10/05/1999 - Verificar se farol esta bloqueado (Deborah).

               16/06/1999 - Gerar arquivo com os programas que irao  no
                            processo (Edson).

               03/09/1999 - Remover o arquivo de devolucoes do dia anterior
                            (Deborah).

               29/12/1999 - Alterado para ler os dados da cooperativa no
                            crapcop e listar a descricao do programa no
                            log do processo Edson).

               10/01/2000 - Tratar diretorios diferentes no /micros (Deborah).
               
               17/01/2000 - Tratar tpdebcot e tpdebemp = 3 (Deborah).

               24/01/2000 - Tratar diretorios das devolucoes (Deborah).  

               14/02/2000 - Gerar pedido de impressao do extrato Bancoob  
                            (Deborah).
                            
               03/03/2000 - Gerar pedido de impressao p/laser dos relatorios
                            para arquivo mensal. (Deborah).

               19/04/2000 - Controle de programas paralelos (Edson).

               26/04/2000 - Remover arquivos (Odair)

               24/07/2000 - Tratar limpeza de requisicoes atendidas por
                            Bancoob ou B.Brasil (Odair)
               
               21/08/2000 - Tratar limpeza de requisicoes tipo 7 atendidas por
                            Bancoob (Magui)

               12/09/2000 - Remover arquivos da BTV e Samae Gaspar (Deborah). 
                 
               20/09/2000 - Tratar limpeza requisicoes especiais (Magui). 
                
               04/10/2000 - Gerar pedido de impressao independentes (Eduardo).
               
               30/10/2000 - Salvar e remover arquivos "cbr" (Eduardo).

               27/12/2000 - Alterado diretorio da Interprint para /micros
                            (Deborah).

               08/01/2001 - Remover o arquivo arq/iptu (Deborah).

               28/03/2001 - Remover o arquivo da Embratel. (Eduardo).

               04/05/2001 - Atualizar a tabela de controle da comp eletronica
                            (Deborah).

               24/05/2001 - Acerto na ultima alteracao para nao mudar o hora-
                            rio escfolhido (Deborah).

               15/06/2001 - Liberar a tabela de execucao da Central de Risco no
                            mensal (Deborah).

               02/10/2001 - Nao eliminar crapext,data nao expirou (Magui).
               
               18/02/2002 - Alterar ipt para pmb (remocao do arquivo) (Junior).
               
               21/02/2002 - Remover arquivo dos movimentos para Hering 
                            (756*.ok) (Junior).
               
               21/02/2002 - Remover arquivo de cartoes magneticos (Junior).
               
               21/02/2002 - Remover arquivo de saldos de emprestimos para 
                            Sisbacen (Junior). 

               01/03/2002 - Aumentar o display da cadeia (Deborah)

               15/04/2002 - Selecionar somente o tipode cadeia = 1 
                            (Ze Eduardo).

               06/05/2002 - Excluir o .limpezaok na virada do mes (Ze Eduardo).

               11/11/2002 - Testar se o script/viracash rodou (Deborah).  
               
               19/11/2002 - Colocar 3 programas na cadeia e diminuir o 
                            tempo de espera entre um paralelo e outro para 2
                            segundos (Deborah).
                            
               04/12/2002 - Melhorias na tela que mostra a cadeia do processo
                            (Junior).

               18/12/2002 - Limpar arquivos do spool do sistema caixa (Edson).
               
               20/02/2003 - Limpar os registros do BL do sistema caixa (Edson).

               23/03/2003 - Criacao da Tabela NUMLOTECEF para Concredi (Ze).

               15/05/2003 - Mostrar o nome dos programas sendo executados
                            na cadeia paralela (Edson).

               21/08/2003 - Na leitura do crapext, quando o tipo de extrato
                            for 1, a situacao for 5 e a data de referencia
                            for menor que a (data do movimento - 90), deletar
                            o registro (Fernando).
                            
               20/10/2003 - Alteracoes efetuadas devido ao processo
                            noturno - cdcooper <> 3(Mirtes).

               23/10/2003 - Atualizar craptrd.vltrapli (Magui).
               
               28/10/2003 - Eliminar rel. arq/pmg*(Mirtes).

               04/11/2003 - Listar Cadeia no LOG(Mirtes).
               
               10/12/2003 - Eliminar DEB*.ret SAMAE JARAGUA (Julio).

               15/01/2004 - Elimina crareq.(req.8) - Personalizacao Bloquetos
                            B.Brasil(Mirtes).

               11/02/2004 - Implementado controle horarios por PAC(Mirtes)

               12/04/2004 - Conectar/Desconectar Banco Generico(Mirtes)

               13/05/2004 - Tabela EXERESFAIX, EXESOLMOED em comentario 
                            Inclusao banco gener no comando mbpro (Julio)
                                    
               20/08/2004 - Alterado o parametro -s de 24 para 40 (default do
                            progress) Edson.
               
               27/09/2004 - Aumentado nro digitos nrctrrpp(Mirtes)

               18/10/2004 - Excluir requisicoes conta integracao (Magui).

               05/01/2005 - Criar arquivo de controle de execucao no fim do 
                            processo (Edson).

               20/04/2005 - Enviar email para CECRED para cadastrar dolar para
                            cobranca da fatura do cartao VISA VIACREDI (Edson).
                            
               09/05/2005 - Adicionado os e-mail's do Marcos Paulo e da 
                            Maristela no aviso para cadastramento do dolar
                            (Julio)
                            
               27/05/2005 - Atualizados campos cdcooper/dtultdia/dtultdma
                            (Mirtes)

               28/06/2005 - Alimentado campo cdcooper das tabelas craptab e 
                            craptrd (Diego).
                            
               28/06/2005 - Incluir na cadeia apenas os programas que estiverem
                            com crapprg.inlibprg = 1 (Julio)

               21/07/2005 - Chamada para o Script CriaPermissoesMTGED.sh no
                            final do processo. (Julio).

               15/08/2005 - Capturar codigo da cooperativa da variavel de 
                            ambiente CDCOOPER (Edson).
               
               18/10/2005 - Iniciar sequencia tabela Envio GPS(Mirtes)

               19/10/2005 - Acessar tabela crapadm com cod.cooperativa(Mirtes)
               
               31/10/2005 - Alterado para ser startado automaticamente(Mirtes)
               
               08/12/2005 - Zera tabela de controle CTRMVESCEN (Magui).
               
               22/12/2005 - Acerto no numeracao do lote NUMLOTECBB (Ze).

               30/03/2006 - Ajustado para executar via CRON (Mirtes/Edson).

               10/04/2006 - Reforma geral (Edson).

               09/05/2006 - Criar arquivos procferNNN para controle dos
                            processos via cron (Edson).

               16/05/2006 - Criar arquivos limpezaferNNN para controle do 
                            processo de limpeza (Edson).
                            
               06/06/2006 - Alimentando cdcooper da tabela crapfer (David).

               14/09/2006 - Atualizar crapmfx (Magui).

               04/10/2006 - Nao e necessario atualizar crapmfx (Magui).

               24/11/2006 - Utilizar o arquivo PROC_cron.pf na chamada
                            dos programas paralelos (Edson).

               29/11/2006 - Colocar 6 programas na cadeia paralela (Edson).

               17/01/2007 - Incluidos novos emails(Mirtes)

               05/02/2007 - Retirado a verificacao do cadastramento do dolar
                            para faturas Bradesco VISA (Julio).
 
               03/04/2007 - Atualizar a craptab horarios doc(Evandro).

               03/07/2007 - Chamar os programas paralelos atraves do script
                            cecred_mbpro, este script esta preparado para 
                            evitar o cancelamento do programa quando houver
                            estouro de mascara no display (Edson).

               04/10/2007 - Adicionar inclusao de horario final do processo na
                            craptab "HRTRTITULO" (David).

               05/12/2007 - Limpeza das tabelas de controle de horarios sera
                            efetuada no processo noturno (David).
                            
               12/02/2008 - Foram retirados os comentarios referente aos
                            registros craptab de horarios, incluidos no
                            programa crps359.p (Evandro).

               08/04/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)
                            
               12/06/2008 - Atualizar campo crapage.vercoban quando agencia
                            utilizar COBAN (Diego).
                            
               01/08/2008 - No termino do processo, enviar email para operador
                            Tratamento para a CECRED do .procfer (Ze).
                            
               15/09/2008 - Incluir email avisando o final do processo CECRED
                            confome tarefa 19280 (Ze).
                            
               14/11/2008 - Enviar email ao contador da cooperativa quando
                            o prazo final para envio do arquivo DIMOF estiver
                            chegando (apos dia 15 do mes de envio) (Guilherme).
                            
               08/12/2008 - Gerar o crrl999.lst e pdf (Guilherme).
               
               03/03/2009 - Antes de fazer a geracao do pdf alimentar o 
                            glb_dtmvtolt com a data do crapdat, pois eh alterado
                            na contagem de dias uteis no mes 
                          - Acerto no data de envio de e-mail no aviso de Fim
                            do processo (Guilherme).

               24/03/2009 -Incluido e_mail controle Cecred(Chamado98975) Mirtes 

               29/04/2009 - Incluido e_mail Ricardo(Mirtes)

               26/08/2009 - Efetuar quebra de pagina do log do processo antes
                            da geracao para PDF (Julio)
                            
               10/11/2009 - Enviar e-mail para Rosangela Boos, Suporte OP.,
                            Margarete e Mirtes informando que a mais de uma
                            semana nao é recebido arquivos de debito da 
                            Brasil Telecom crps000a.p (Guilherme).
                            
               18/02/2010 - Incluir e-mail vanderlei@cecred.coop.br para fim
                            do processo da Cecred (David).
                            
               29/03/2010 - Criar nome logico "bdgener" na chamada dos 
                            programas em background e remocao do "-s"
                            (Evandro/Julio).
                            
               06/04/2010 - Incluido destinatario jonas@cecred.coop.br 
                            no email de fim do processo (Elton).    
                            
               04/05/2010 - Retirar tratamento de exclusao da tabela 
                            de poupanças em estudo (Gabriel).
                            
               23/06/2010 - Limpar arquivos do spool do sistema TAA (Evandro).
               
               21/10/2010 - Nao deletar registros da tabela crapext referente
                            operacoes realizadas no TAA (Diego).
                            
               17/12/2010 - Somente eliminar extratos TAA isentos a mais de
                            90 dias (Evandro).
                            
               01/04/2011 - Incluidos nos tipo de extratos para serem ignorados
                            (Henrique).
                                                                   
               04/04/2011 - Incluir e_mail da compe e do suporte.operacional
                            para processo Cecred (Magui).

               22/06/2011 - Incluir e_mail allan@cecred.coop.br (Magui)
               
               15/07/2011 - Retirar conexão com o banco gener na chamada
                            dos programas (Fernando).
                            
               18/08/2011 - Nao excluir os agendamentos (Gabriel).             
               
               30/09/2011 - Alterar diretorio spool para
                            /usr/coop/sistema/siscaixa/web/spool (Fernando).
                            
               24/10/2011 - Alterar criacao do arquivo procfer. Nao criar para
                            a Cecred (Ze).
               07/02/2012 - Eliminar Contra-Ordem Provisoria(Guilherme/Supero)
               
               10/04/2012 - Ajuste na contra-ordem Provisoria (Ze).
               
               18/07/2012 - Ajuste do format no campo nmrescop (David Kruger).
               
               28/01/2013 - Alimentar variavel glb_nmmodora (Guilherme).
               
               29/05/2013 - Alteracao acima nao sera utilizado, temporariamente 
                            (Guilherme)
               
               29/05/2013 - Inserido limpeza da craptex quando a data de 
                            emissao for maior que 45 dias e retirado
                            a limpeza da crapext (Tiago).
                            
               10/06/2013 - Alteração função enviar_email_completo para
                            nova versão (Jean Michel).
                            
               06/09/2013 - Correcao na limpeza dos resgitros da craptex
                            (Tiago).
                            
               08/10/2013 - Transferido linhas de finalização e limpeza para
                            o crps659, mas mantido rotinas que trabalham com
                            arquivos fisicos (Douglas Pagel).         
                            
               27/11/2013 - Criar arquivo controles/Proc_Mensal para que o
                            script PROCDIA possa identificar que o processo
                            eh mensal 
                            Criar arquivos arquivos/Salva_Auditoria para
                            que o script PROCDIA possa executar o programa
                            crps400 (David).
                
               03/03/2016 - Alterar o envio de e-mail do FIM DO PROCESSO DA CECRED
			                de "jccosta@cecred.coop.br" para "cic@cecred.coop.br"
							(Douglas - Chamado 410956)

............................................................................ */

DEF STREAM str_mp.      /*  Stream para monitoramento do programas paralelos  */

DEF STREAM str_1.
DEF STREAM str_3. /* arquivo anexo para enviar via email */

DEF VAR b1wgen0011   AS HANDLE                                  NO-UNDO.
DEF VARIABLE aux_nmarqimp AS CHAR                               NO-UNDO.

{ includes/var_batch.i "NEW" }

{includes/gg0000.i}

/*  .... Define a quantidade de programas que rodam na cadeia paralela .....  */

DEF            VAR aux_cdprgpar AS CHAR    FORMAT "x(10)" EXTENT 15  NO-UNDO.
DEF            VAR aux_mtpidprg AS INT     EXTENT 15                 NO-UNDO.

DEF            VAR aux_qtparale AS INT     INIT 15                   NO-UNDO.
DEF            VAR aux_contapar AS INT                               NO-UNDO.

/*  ......................................................................... */

DEF            VAR aux_cadeiaex AS CHAR    FORMAT "x(2000)" INIT ""  NO-UNDO.
DEF            VAR aux_lscadeia AS CHAR    FORMAT "x(1500)"          NO-UNDO.
DEF            VAR aux_lsprogra AS CHAR    FORMAT "x(80)"            NO-UNDO.
DEF            VAR aux_nmcadeia AS CHAR                              NO-UNDO.
DEF            VAR aux_nmdobjet AS CHAR    FORMAT "x(20)"            NO-UNDO.
DEF            VAR aux_nmcobjet AS CHAR    FORMAT "x(80)"            NO-UNDO.
DEF            VAR aux_cdprogra AS CHAR    FORMAT "x(20)"            NO-UNDO.
DEF            VAR aux_nmarquiv AS CHAR    FORMAT "x(40)"            NO-UNDO.
DEF            VAR aux_nmdiasem AS CHAR                              NO-UNDO.
DEF            VAR aux_dspidprg AS CHAR                              NO-UNDO.
DEF            VAR aux_nmarqv   AS CHAR                              NO-UNDO.

DEF            VAR aux_nrposprg AS INT     FORMAT "zz9" INIT 1       NO-UNDO.
DEF            VAR aux_qtprgpar AS INT                               NO-UNDO.
DEF            VAR aux_qtdiasut AS INT                               NO-UNDO.
DEF            VAR aux_nrinides AS INT                               NO-UNDO.
DEF            VAR aux_nrpidprg AS INT                               NO-UNDO.
DEF            VAR aux_nrmonpid AS INT                               NO-UNDO.
DEF            VAR aux_contador AS INT                               NO-UNDO.
DEF            VAR aux_contavez AS INT                               NO-UNDO.
DEF            VAR aux_nrremess AS INT                               NO-UNDO.
DEF            VAR aux_qtdias   AS INT                               NO-UNDO.
DEF            VAR aux_qtcont   AS INT                               NO-UNDO.

DEF            VAR aux_dtmvtolt AS DATE                              NO-UNDO.
DEF            VAR aux_dtlimite AS DATE                              NO-UNDO.
DEF            VAR aux_dtavisos AS DATE                              NO-UNDO.
DEF            VAR aux_dtavs001 AS DATE                              NO-UNDO.
DEF            VAR aux_dtlogant AS DATE                              NO-UNDO.

DEF            VAR tab_qtdiaper AS DECIMAL FORMAT "999"              NO-UNDO.

DEF            VAR aux_flgerrcp AS LOGICAL                           NO-UNDO.
DEF            VAR aux_flgcadpl AS LOGICAL                           NO-UNDO.
DEF            VAR aux_flgrepro AS LOGICAL                           NO-UNDO.

DEF            VAR aux_vltrapli LIKE craptrd.vltrapli                NO-UNDO.

DEF            VAR aux_dtcalcul AS DATE                              NO-UNDO.
DEF            VAR aux_ultdiame AS DATE                              NO-UNDO.
DEF            VAR aux_conteudo AS CHAR                              NO-UNDO.
DEF            VAR aux_dias     AS INTE                              NO-UNDO.

DEF            VAR h-b1wgen0011 AS HANDLE                            NO-UNDO.
DEF            VAR aux_dsemlctr AS CHAR                              NO-UNDO.
DEF            VAR aux_nrcheque AS INT                               NO-UNDO.

/* .......................................................................... */

ASSIGN glb_cdprogra = "crps000"
       /*glb_nmmodora = glb_cdprogra Nao utilizado temporariamente*/
       aux_nmdiasem = "DOM,SEG,TER,QUA,QUI,SEX,SAB".

/* Conecta o Banco Generico ................................................. */

IF   NOT f_conectagener() THEN
     DO:
         glb_cdcritic = 791.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " + 
                           glb_cdprogra + "' --> '"  + glb_dscritic + 
                           " Generico " + " >> log/proc_batch.log").
         QUIT.
     END.

/*  Captura o nome do servidor da variavel de ambiente HOST ................. */

glb_hostname = OS-GETENV("HOST").

IF   glb_hostname = ?   OR
     glb_hostname = ""  THEN
     DO:
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " + 
                           glb_cdprogra + "' --> '"  + 
                           "ERRO: Variavel glb_hostname NAO inicializada." + 
                           " >> log/proc_batch.log").
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

ASSIGN aux_nmcadeia = " Cadeia de Execucao " + STRING(CAPS(crapcop.nmrescop),"X(20)") + " "
       glb_nmrescop = crapcop.nmrescop.

/*  Le data do sistema ...................................................... */

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

           IF   crapcop.cdcooper <> 333 THEN
                DO:
                    IF   crapdat.inproces = 7   THEN
                         ASSIGN glb_cdcritic = 0
                                glb_dtmvtolt = crapdat.dtmvtolt
                                aux_dtlogant = crapdat.dtmvtoan
                                aux_flgrepro = FALSE
                                crapdat.inproces = 3.
                    ELSE 
                         IF  crapdat.inproces = 1   THEN
                             ASSIGN glb_cdcritic = 141
                                    glb_dtmvtolt = crapdat.dtmvtolt
                                    aux_dtlogant = crapdat.dtmvtoan
                                    aux_flgrepro = FALSE.
                        ELSE
                             IF  crapdat.inproces = 6 OR
                                 crapdat.inproces = 2 THEN
                                 ASSIGN  glb_cdcritic = 772 
                                          /* Rodar batch noturno */
                                         glb_dtmvtolt = crapdat.dtmvtolt
                                         aux_dtlogant = crapdat.dtmvtoan
                                         aux_flgrepro = FALSE.
                            ELSE    
                                 ASSIGN glb_cdcritic = 0
                                        glb_dtmvtolt = crapdat.dtmvtolt
                                        aux_dtlogant = crapdat.dtmvtoan
                                        aux_flgrepro = TRUE.
                END.
           ELSE
                DO:
                    IF  crapdat.inproces = 2   THEN
                        ASSIGN glb_cdcritic = 0
                               glb_dtmvtolt = crapdat.dtmvtolt
                               aux_dtlogant = crapdat.dtmvtoan
                               aux_flgrepro = FALSE
                               crapdat.inproces = 3.
                    ELSE
                        IF  crapdat.inproces = 1   THEN
                            ASSIGN glb_cdcritic = 141
                                   glb_dtmvtolt = crapdat.dtmvtolt
                                   aux_dtlogant = crapdat.dtmvtoan
                                   aux_flgrepro = FALSE.
                         ELSE
                             ASSIGN glb_cdcritic = 0
                                    glb_dtmvtolt = crapdat.dtmvtolt
                                    aux_dtlogant = crapdat.dtmvtoan
                                    aux_flgrepro = TRUE.
                END.

      LEAVE.

   END.

   /* Verifica se o viracash rodou .......................................... */
   
   IF   crapdat.dtmvtopr <> crapdat.dtmvtocd THEN
        glb_cdcritic = 747. 

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

IF   NOT aux_flgrepro THEN
     OUTPUT STREAM str_1 TO VALUE("/micros/" + crapcop.dsdircop + 
                                  "/cpd/instrucao.txt").

/* Inicia log do processo diario ............................................ */

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                  (IF aux_flgrepro
                      THEN " Reinicio do processo batch referente "
                      ELSE " Inicio do processo batch referente ") +
                  (IF glb_dtmvtolt <> ?
                      THEN STRING(glb_dtmvtolt,"99/99/9999")
                      ELSE "'*** Sistema sem data! ***'") +
                  " em " + STRING(TODAY,"99/99/9999") + 
                  " da " + STRING(crapcop.nmrescop,"x(20)") +
                  " >> log/proc_batch.log").

/*  Monta cadeia de execucao ............................................... */

FOR EACH crapord WHERE crapord.cdcooper = glb_cdcooper   AND
                       crapord.tpcadeia = 1 NO-LOCK:

    FOR EACH crapsol WHERE crapsol.cdcooper = crapord.cdcooper   AND
                           crapsol.nrsolici = crapord.nrsolici   AND
                           crapsol.dtrefere = glb_dtmvtolt       AND
                           crapsol.insitsol = 1
                           NO-LOCK:

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
                                              
                     IF   NOT aux_flgrepro   THEN
                          PUT STREAM str_1 
                                     CAPS(crapprg.cdprogra) FORMAT "x(7)"
                                     SKIP.
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

IF   NOT aux_flgrepro   THEN
     DO:
         PUT STREAM str_1 "9999999" SKIP.
                    
         OUTPUT STREAM str_1 CLOSE.
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

/*  Lista cadeia do Processo DIARIO no arquivo de log ....................... */
   
UNIX SILENT VALUE("echo " + "Cadeia de Execucao - processo batch DIARIO " + 
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
                  "Inicio Primeira Cadeia Exclusiva batch DIARIO  referente " +
                  STRING(glb_dtmvtolt,"99/99/9999") +
                  " >> log/proc_batch.log").

RUN proc_roda_exclusivo.

glb_cdprogra = "crps000".

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
                  crapdat.inproces = 4.

      LEAVE.

   END.

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

/*  Inicio da cadeia paralela ............................................... */

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                  "Inicio Primeira Cadeia Paralela batch DIARIO  referente " +
                  STRING(glb_dtmvtolt,"99/99/9999") + 
                  " >> log/proc_batch.log").

RUN proc_roda_paralelo.

/*  Inicio da segunda cadeia exclusiva ...................................... */

glb_cdprogra = "crps000".

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                  "Inicio Segunda Cadeia Exclusiva batch DIARIO referente " +
                  STRING(glb_dtmvtolt,"99/99/9999") +
                  " >> log/proc_batch.log").

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
                  crapdat.inproces = 5.

      LEAVE.

   END.

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

RUN proc_roda_exclusivo.

/*  Verifica se os programas executaram ..................................... */

glb_cdprogra = "crps000".             /* Verifica se todos executaram */

FOR EACH crapord WHERE crapord.cdcooper = glb_cdcooper NO-LOCK:

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

ASSIGN glb_cdprogra = "crps000"
       glb_cdcritic = 0.

DO TRANSACTION ON ERROR UNDO, RETURN.

    /*  Muda a data do sistema ........................................... */

    DO WHILE TRUE:

        FIND FIRST crapdat WHERE crapdat.cdcooper = glb_cdcooper
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
        IF  NOT AVAILABLE crapdat   THEN
            IF  LOCKED crapdat   THEN
                DO:
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
            ELSE
                DO:
                    glb_cdcritic = 1.
                    LEAVE.
                END.
    
        ASSIGN crapdat.inctrfit = 0
               crapdat.inproces = 1
               crapdat.cdprgant = ""
               crapdat.dtmvtoan = crapdat.dtmvtolt
               crapdat.dtmvtolt = crapdat.dtmvtopr 
               crapdat.dtultdma = crapdat.dtmvtolt - DAY(crapdat.dtmvtolt)
               crapdat.dtultdia = ((DATE(MONTH(crapdat.dtmvtolt),28,
                                         YEAR(crapdat.dtmvtolt)) + 4) - 
                                         DAY(DATE(MONTH(crapdat.dtmvtolt),28,
                                                  YEAR(crapdat.dtmvtolt)) + 4)).

        /*  Procura pela proxima data de movimento .......................  */

        DO WHILE TRUE:         
            
            crapdat.dtmvtopr = crapdat.dtmvtopr + 1.
    
            IF  LOOKUP(STRING(WEEKDAY(crapdat.dtmvtopr)),"1,7") <> 0   THEN
                NEXT.
    
            IF  CAN-FIND(crapfer WHERE 
                         crapfer.cdcooper = glb_cdcooper       AND
                         crapfer.dtferiad = crapdat.dtmvtopr)  THEN
                NEXT.
    
            LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */

        /*  Obtem qtde de dias uteis do proximo mes ......................  */

        IF  MONTH(glb_dtmvtopr) <> MONTH(glb_dtmvtolt)  THEN
            DO:
                ASSIGN crapdat.qtdiaute = 0
                       aux_dtmvtolt     = DATE(MONTH(glb_dtmvtopr),01,
                                               YEAR(glb_dtmvtopr)).
           
                DO WHILE MONTH(glb_dtmvtopr) = MONTH(aux_dtmvtolt):
           
                   IF   LOOKUP(STRING(WEEKDAY(aux_dtmvtolt)),"1,7") <> 0 THEN
                        DO:
                            aux_dtmvtolt = aux_dtmvtolt + 1.
                            NEXT.
                        END.
           
                   IF   CAN-FIND(crapfer WHERE 
                                 crapfer.cdcooper = glb_cdcooper   AND
                                 crapfer.dtferiad = aux_dtmvtolt)  THEN
                        DO:
                            aux_dtmvtolt = aux_dtmvtolt + 1.
                            NEXT.
                        END.
           
                   ASSIGN crapdat.qtdiaute = crapdat.qtdiaute + 1
                          aux_dtmvtolt     = aux_dtmvtolt     + 1.
           
                END.
            END.

        LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

END. /* Fim da transacao */

IF   AVAIL crapdat  THEN
     FIND CURRENT crapdat NO-LOCK NO-ERROR.

IF   glb_cdcritic > 0   THEN
     DO:
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" + glb_dscritic +
                           " >> log/proc_batch.log").
         PAUSE 2 NO-MESSAGE.
         QUIT.
     END.

/*  Cria arquivos de controle de fim-de-semana/feriados ............... */

IF  glb_cdcooper <> 3 THEN
    DO:
        ASSIGN aux_qtdias = crapdat.dtmvtolt - crapdat.dtmvtoan
               aux_qtcont = 1.
     
        DO WHILE aux_qtcont <= (aux_qtdias - 1):
           
            aux_nmarqv = "arquivos/.procfer" + STRING(aux_qtcont).
            
            UNIX SILENT VALUE("> " + aux_nmarqv).
            
            aux_qtcont = aux_qtcont + 1.
     
        END.  /*  Fim do DO WHILE  */
    END.

/*  ------------------------------------------------------------------- */
/*  Rotinas mensais ................................................... */
/*  ------------------------------------------------------------------- */

IF  MONTH(crapdat.dtmvtolt) <> MONTH(glb_dtmvtolt)   THEN
    DO:    
        /* Cria arquivo de controle indicando que o processo eh mensal */
        /* Utilizado no script PROCDIA_unificado_cron.sh               */
        
        UNIX SILENT VALUE("> controles/Proc_Mensal 2>/dev/null").

        /* Remove o arquivos/.limpezaok para rodar o script limpeza .. */
        
        IF   SEARCH("arquivos/.limpezaok") <> ? THEN
             UNIX SILENT VALUE("rm arquivos/.limpezaok 2>/dev/null").
                   
        /*  Cria controle de feriados para o processo de limpeza ..... */
                   
        DO aux_contador = 1 to 15:
           
           IF   WEEKDAY(crapdat.dtmvtoan + aux_contador) = 2   THEN
                DO:
                    aux_contavez = aux_contavez + 1.
              
                    IF   CAN-FIND(crapfer WHERE 
                             crapfer.cdcooper = glb_cdcooper   AND
                             crapfer.dtferiad = (crapdat.dtmvtoan +
                                                    aux_contador))  THEN
                         
                         UNIX SILENT VALUE("> arquivos/" +
                                           ".limpezafer" +
                                           STRING(aux_contavez)).
                    ELSE
                         DO:
                             glb_dscritic = "A rotina de limpeza sera " +
                                            "executada em " +
                                            STRING(crapdat.dtmvtoan +
                                                   aux_contador,
                                                   "99/99/9999").
                                            
                             UNIX SILENT VALUE("echo " + 
                                       STRING(TIME,"HH:MM:SS") + " - " +
                                       glb_cdprogra + "' --> '" +
                                       glb_dscritic + 
                                       " >> log/proc_batch.log").

                             LEAVE.
                         END.
                END.

        END.  /*  Fim do DO .. TO  */
       

    END. /* Fim das Rotinas mensais */

/* Remove o arquivos/.procnotok para rodar o script proc-noturno .....  */
    
IF  SEARCH("arquivos/.procnotok") <> ? THEN
    UNIX SILENT VALUE("rm arquivos/.procnotok 2>/dev/null").

/*  Limpeza dos arquivos de controle das contas BB sem movimento no dia ..... */

aux_dtlimite = glb_dtmvtolt - 7.

INPUT THROUGH ls proc/0* 2> /dev/null NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   SET aux_nmarquiv FORMAT "x(40)" WITH NO-BOX NO-LABELS FRAME f_ls.

   aux_dtmvtolt = DATE(INTEGER(SUBSTRING(aux_nmarquiv,16,2)),
                       INTEGER(SUBSTRING(aux_nmarquiv,14,2)),
                       INTEGER(SUBSTRING(aux_nmarquiv,18,4))).

   IF   aux_dtmvtolt < aux_dtlimite   THEN
        UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").

END.  /*  Fim do DO WHILE TRUE  */

/*  Limpeza dos arquivos de controle de pedidos de talonarios ............... */

UNIX SILENT rm arq/ct* arq/da* 2> /dev/null.

/*  Copia arquivo dos pedidos de talonarios para o diretorio salvar ......... */

UNIX SILENT cp arq/pd* arq/cbr* salvar 2> /dev/null.

/*  Registra fim do processo BATCH .......................................... */

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                  " Fim do processo batch referente " +
                  STRING(crapdat.dtmvtoan,"99/99/9999") +
                  " em " + STRING(TODAY,"99/99/9999") + 
                  " da " + STRING(crapcop.nmrescop,"x(20)") +
                  " >> log/proc_batch.log").

UNIX SILENT VALUE("cat log/proc_batch.log | " +
                  "/usr/coop/sistema/script/quebra_pagina.pl > " + 
                  "rl/crrl999.lst 2> /dev/null").
        
ASSIGN glb_nrcopias = 1
       glb_nmformul = "132col"
       glb_nmarqimp = "rl/crrl999.lst".

RUN fontes/imprim.p.

/*  Gera arquivo indicando final de processo - ok(Diario) ..................  */

UNIX SILENT > arquivos/.procdiaok 2> /dev/null.     /*  Controle de execucao  */

UNIX SILENT > controles/crps000.ok 2> /dev/null.    /*  Controle script  */

IF   glb_cdcooper = 3 THEN
     DO:
         /* Salva relatorios para Auditoria - crps400 */
         IF   MONTH(glb_dtmvtolt) <> MONTH(glb_dtmvtopr)   OR
              MONTH(glb_dtmvtolt) <> MONTH(glb_dtmvtoan)   THEN
              UNIX SILENT VALUE("> arquivos/Salva_Auditoria 2>/dev/null").

         /* Envia e-mail para o Operador */
         RUN sistema/generico/procedures/b1wgen0011.p
                             PERSISTENT SET h-b1wgen0011.

         RUN enviar_email IN h-b1wgen0011 (INPUT glb_cdcooper,
                                           INPUT glb_cdprogra,
                                           INPUT "cpd@cecred.coop.br," +
                                                 "denis@cecred.coop.br," +
                                                 "cic@cecred.coop.br," +
                                                 "ricardo@cecred.coop.br," +
                                                 "allan@cecred.coop.br," +
                                                 "joice@cecred.coop.br," +
                                                 "compe@cecred.coop.br," +
                                                 "jonathan@cecred.coop.br," +
                                                 "vanderlei@cecred.coop.br," +
                                                 "karina@cecred.coop.br," +
                                                 "jonas@cecred.coop.br," + 
                                                 "suporte.operacional@cecred.coop.br," + 
                                                 "fernandapera@cecred.coop.br",
                                           INPUT "FIM DO PROCESSO " +
                                             "DA CECRED - REF:" +
                                             STRING(crapdat.dtmvtoan,
                                                    "99/99/9999"),
                                           INPUT "",
                                           INPUT FALSE).
                  
         DELETE PROCEDURE h-b1wgen0011.

         /* Limpa arquivos de spool do proximo movto do sistema TAA */
         UNIX SILENT VALUE("rm /usr/coop/sistema/TAA/spool/*" + 
                           ENTRY(WEEKDAY(crapdat.dtmvtolt),aux_nmdiasem) + 
                           "*.txt 2> /dev/null").

         /*  Limpa arquivos de spool do proximo movto do sistema caixa on-line ....... */
         UNIX SILENT VALUE("rm /usr/coop/sistema/siscaixa/web/spool/*" + 
                  ENTRY(WEEKDAY(crapdat.dtmvtolt),aux_nmdiasem) + 
                  "*.txt 2> /dev/null").
     END.

QUIT.     /* Encerra o processo batch */

/* .......................................................................... */
/*                      ** P R O C E D U R E S **                             */
/* .......................................................................... */

PROCEDURE proc_roda_exclusivo:

    glb_cdprogra = "crps000".

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

                RUN VALUE("fontes/" +
                          LC(SUBSTRING(aux_cadeiaex,aux_nrposprg,7) + ".p")).

                IF   glb_stprogra   THEN
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '" + 
                                       "Execucao ok " +
                                       " >> log/proc_batch.log").
                ELSE
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '" +
                                       "PROGRAMA COM ERRO" +
                                       " >> log/proc_batch.log").

                glb_cdprogra = "crps000".
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
   
       PAUSE 1 NO-MESSAGE.
    
    END.  /*  Fim do DO WHILE TRUE  */

END PROCEDURE.

PROCEDURE proc_roda_paralelo:

    glb_cdprogra = "crps000".

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

       INPUT STREAM str_mp THROUGH VALUE
             ("cecred_mbpro" + 
              " -pf arquivos/PROC_cron.pf " +
              " -p fontes/" + LC(SUBSTR(aux_cadeiaex,aux_nrposprg,7) +
              ".p")) NO-ECHO.

       SET STREAM str_mp aux_dspidprg FORMAT "x(30)" WITH FRAME f_monproc.
            
       INPUT STREAM str_mp CLOSE.

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
                               "ERRO: Abortando processo DIARIO" +
                               " >> log/proc_batch.log").

             UNIX SILENT VALUE("> controles/Proc_Diario.Erro").

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
            
                     ASSIGN aux_cdprgpar[aux_contapar] = ""
                            aux_mtpidprg[aux_contapar] = 0
                            aux_qtprgpar = aux_qtprgpar - 1
                            aux_flgerrcp = TRUE.
                 END.

    END.  /*  Fim do DO .. TO  */
    
END PROCEDURE.

PROCEDURE proc_remove_arquivos:

    UNIX SILENT VALUE("rm " +
                      "rl/crrl*.lst rl/O*.lst arq/pd* arq/d0* arq/cot* "   +
                      "arq/emp* arq/2* rl/*.ex arq/cv* arq/btv* arq/sag* " +
                      "arq/cb* arq/pmb* arq/*embc*.txt "                   + 
                      "/usr/coop/sistema/siscaixa/web/spool/*.ret "        +
                      "arq/*.ok arq/cm* arq/LDEV* arq/pmg* tmppdf/* "      +
                      "2> /dev/null").
                      
    UNIX SILENT VALUE("rm " +
                      "/micros/" + crapcop.dsdircop + "/titulos/* "       +
                      "/micros/" + crapcop.dsdircop + "/pedido/* "        +
                      "/micros/" + crapcop.dsdircop + "/devolu/* "        +
                      "/micros/" + crapcop.dsdircop + "/interprint/* "    +
                      "/micros/" + crapcop.dsdircop + "/contab/*.bak "    +
                      "/micros/" + crapcop.dsdircop + "/prefeitura/* "    +
                      "/micros/" + crapcop.dsdircop + "/e-mail/* "        +
                      "/micros/" + crapcop.dsdircop + "/arrecada/*embc* " +
                      "2> /dev/null").

END PROCEDURE.

PROCEDURE verifica_dolar:

   DEF VAR aux_dtdoltab AS DATE NO-UNDO.

   IF   glb_cdcooper <> 1   THEN            /*  Somente para a VIACREDI  */
        RETURN.
        
   aux_dtdoltab = ?.
   
   FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                          craptab.nmsistem = "CRED"         AND
                          craptab.tptabela = "USUARI"       AND
                          craptab.cdempres = 11             AND
                          craptab.cdacesso begins "DC"      AND
                          craptab.tpregist = 000            AND
                          DECIMAL(craptab.dstextab) = 0 NO-LOCK.
                                   
       aux_dtdoltab = DATE(INT(SUBSTRING(craptab.cdacesso,7,2)),
                           INT(SUBSTRING(craptab.cdacesso,9,2)),
                           INT(SUBSTRING(craptab.cdacesso,3,4))).
                                    
       LEAVE.
   
   END.  /*  Fim do FOR EACH  */
   
   IF   aux_dtdoltab <> ? THEN
        DO:
            /* criar arquivo anexo para email */
            ASSIGN aux_nmarqimp = "arq/" + glb_cdprogra + 
                                  "_ANEXO" + STRING(TIME).
        
            OUTPUT STREAM str_3 TO VALUE(aux_nmarqimp).
    
            PUT STREAM str_3 "FALTA CADASTRAR O VALOR DO DOLAR "
                             "DO DIA " + 
                             STRING(aux_dtdoltab,"99/99/9999") FORMAT "x(17)"
                             SKIP
                             ".UTILIZE A TELA DOLFAT PARA EFETUAR O "
                             "CADASTRAMENTO."
                             SKIP.
                                     
            OUTPUT STREAM str_3 CLOSE.
              
            /* Move para diretorio converte para utilizar na BO */
            UNIX SILENT VALUE
                       ("cp " + aux_nmarqimp + " /usr/coop/" +
                        crapcop.dsdircop + "/converte" +
                        " 2> /dev/null").
                     
            /* envio de email */ 
            RUN sistema/generico/procedures/b1wgen0011.p
                PERSISTENT SET b1wgen0011.
          
            RUN enviar_email IN b1wgen0011
                       (INPUT glb_cdcooper,
                        INPUT glb_cdprogra,
                        INPUT "tavares@cecred.coop.br " +
                              ",rosangela@cecred.coop.br " +
                              ",suzana@cecred.coop.br " +
                              ",willian@cecred.coop.br" ,
                        INPUT '"DOLAR PARA FATURA DO CARTAO VISA VIACREDI"',
                        INPUT SUBSTRING(aux_nmarqimp, 5),
                        INPUT FALSE).
                                 
            DELETE PROCEDURE b1wgen0011.

            /* remover arquivo criado de anexo */
            UNIX SILENT VALUE("rm " + aux_nmarqimp +
                              " 2>/dev/null").
        END.
        
END PROCEDURE.

/* .......................................................................... */
