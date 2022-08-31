DECLARE
  --
  vr_dtmvtolt_gncptit DATE := to_date('29/08/2022', 'DD/MM/YYYY');
  vr_nmarquiv_gncptit VARCHAR2(20) := '29999829_REP.RET';
  vr_cdprogra VARCHAR2(100) := 'crps538_compefora_20220829';
  --
  vr_idprglog_principal NUMBER := 0;
  vr_stprogra PLS_INTEGER;
  vr_infimsol PLS_INTEGER;
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  --
  PROCEDURE pc_crps538_20220829(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo Cooperativa
                               ,pr_cdagenci IN crapage.cdagenci%TYPE --> Codigo Agencia 
                               ,pr_idparale IN crappar.idparale%TYPE --> Indicador de processoparalelo
                               ,pr_flgresta IN PLS_INTEGER --> Flag padrão para utilização de restart
                               ,pr_nmtelant IN VARCHAR2 --> Nome tela anterior
                               ,pr_stprogra OUT PLS_INTEGER --> Saida de termino da execucao
                               ,pr_infimsol OUT PLS_INTEGER --> Saida de termino da solicitacao
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da Critica
                               ,pr_dscritic OUT VARCHAR2 --> Descricao da Critica
                                ) IS

BEGIN

  /* .............................................................................
  
  Programa: PC_CRPS538                      Antigo: Fontes/CRPS538.p
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Guilherme / Supero
  Data    : Novembro/2009.                   Ultima atualizacao: 26/07/2022
  
  Dados referentes ao programa:
  
  Frequencia: Diario (Batch).
  Objetivo  : Integrar arquivos de TITULOS da Nossa Remessa - Conciliacao.
  
              'EMPRESTIMO'         - COBEMP
              'ACORDOS'            - Acordo
              'DESCONTO DE TITULO' - COBTIT
  
  Alteracoes: 27/05/2010 - Alterar a data utilizada no FIND para a data que
                           esta no HEADER do arquivo e incluir um resumo ao
                           fim do relatorio de Rejeitados, Integrados e
                           Recebidos (Guilherme/Supero)
  
              28/05/2010 - Quando encontrar o registro Trailer dar LEAVE
                           e sair do laco de importacao do arquivo(Guilherme).
  
              04/06/2010 - Acertos Gerais (Ze).
  
              16/06/2010 - Inclusao do campo gncptit.dtliquid (Ze).
  
              28/06/2010 - Alteracao na Busca (FIND LAST) ate verificacao na
                           BO (Ze).
  
              06/07/2010 - Incluso Validacao para COMPEFORA (Jonatas/Supero)
  
              26/08/2010 - Incluida importacao diferenciada quando CECRED,
                           gerando relatorio 574 do que nao foi importado nas
                           cooperativas (Guilherme/Supero)
  
              13/09/2010 - Acerto p/ gerar relatorio no diretorio rlnsv
                           (Vitor)
  
              12/05/2011 - Tratamento para liquidaçao da cobrança registrada
                         - Definido explicitamente cada bloco de transacao para
                           conseguir efetuar o comando DDA para JD (Guilherme).
  
              22/06/2011 - Validar a data do arquivo pelo dtmvtolt e nao pelo
                           dtmvtoan (Guilherme).
  
              24/06/2011 - Gravar banco/agencia origem do pagamento (Rafael).
  
              11/07/2011 - Quando nao encontrar titulo nas cooperativas singulares
                           gerar registros no relatorio(Guilherme).
  
              13/07/2011 - Incluir baixa automatica por decurso de prazo
                           (Guilherme).
  
              02/08/2011 - Criacao da procedure gera_relatorio_605, que gera
                           o crrl605, para conciliacao dos dados da
                           Sua Remessa(085). Fabricio
  
              16/09/2011 - Ajustes gera_relatorio_605. Separar liquidacoes
                           pela COOP e COMPE. (Rafael).
  
              03/10/2011 - Criticar titulos baixados p/ protesto e
                           pagos a menor (941 e 940). (Rafael).
  
              03/11/2011 - Ajuste calculo de titulos pagos em atraso (Rafael)
  
              17/11/2011 - Executar liquidacao intrabancaria DDA dos titulos
                           pagos na compe 085. (Rafael)
                         - Mostrar no relatorio 605 qdo ocorrer liquidacao
                           de um boleto baixado (943). (Rafael)
                         - Alterado prazo de envio para protesto de titulos
                           vencidos. (Rafael)
  
              08/12/2011 - Utilizado data de pagto do arquivo para realizar
                           calculo de juros/multa. (Rafael)
  
              23/12/2011 - Alteraçoes para substiuir o campo 'TARIFAS' por
                           'TARIFAS COOP'. (Lucas)
  
              18/01/2012 - Utilizar vlr de abatimento no calculo do título
                           mesmo vencido. (Rafael)
  
              13/03/2012 - Alterado prazos de decurso de prazo de titulos
                           em virtude do novo catalogo da CIP 3.05. (Rafael)
                         - Valor de abatimento deve ser aplicado antes do
                           calculo de juros/multa. (Rafael)
  
              22/03/2012 - Procedure para gerar rel. 618 (CAC). (Lucas)
  
              23/03/2012 - Importar todos arqs 2*.REM - ref CAF (Guilherme)
  
              10/04/2012 - Aumento de posicoes na variavel com o no. de
                           arquivos, para 9999 arquivos (Guilherme).
  
              18/04/2012 - Identificar pagamento DDA ao processar COB615,
                           cdtipdoc = 140 e 144 (DDA INF e DDA VLB). (Rafael)
  
              14/05/2012 - Tratamento liq de titulos apos baixa.
                         - Criado critica 947 - Liq de boleto pago. (Rafael)
  
              10/08/2012 - Ajuste na rotina de liquidacao de titulos
                           descontados da cob. registrada. (Rafael)
  
              21/08/2012 - Incluido nrseqdig no campo gncptit.hrtransa para
                           evitar chave duplicada de titulo pago. (Rafael)
  
              29/08/2012 - Removido inclusao na gncptit ref. a liq de boleto
                           pago. Estava mostrando valor duplicado no
                           relatorio 533 na central. (Rafael)
  
              23/11/2012 - Ajustes para títulos migrados da Viacredi para
                           Alto Vale (Gabriel).
  
              04/12/2012 - Nao processar arquivos 2*.REM que nao sejam
                           COB605. (Rafael)
  
              12/03/2013 - Conforme circular INFO-CIP 009/2013, foi extinto
                           TD 44 e 144 do pagto de titulos. (Rafael)
  
              14/03/2013 - Substituir nmrescop por dsdircop ao gerar
                           relatorio 618. (Rafael)
  
              07/05/2013 - Projeto Melhorias da Cobranca - processar titulos
                           da cobranca 085 - sem registro. (Rafael)
                         - Utilizado ROUND nas rotinas de cálculo de juros
                           e multa. (Rafael)
  
              31/07/2013 - Incluso processo para geracao log com base tabela
                           crapcol. (Daniel)
  
              26/09/2013 - Incluso parametro tt-lat-consolidada nas chamadas
                           de instrucoes da b1wgen0088. Incluso processo de
                           cobranca tarifa consolidadas (Daniel).
  
              11/11/2013 - Nova forma de chamar as agências, de PAC agora
                           a escrita será PA (Guilherme Gielow)
  
              15/11/2013 - Novos ajustes no processamento "COMPEFORA" (Rafael).
  
              25/11/2013 - Conversao Progress -> Oracle - Alisson (AMcom)
  
              17/12/2013 - Ajustado leituras crapcob e incluso format no
                           display do campo crapret.nrdocmto (Daniel).
  
              20/12/2013 - Ajuste no processo de convenios migrados para
                           outras cooperativas. (Rafael)
                         - Removido tratamento de convenios ativos, pois
                           todo convenio deve ser tratado. (Rafael)
                         - Ajuste na data de geracao do arquivo de retorno
                           ao cooperado. (Rafael)
  
              07/05/2014 - Ajustado processo tratamento critica, evitando
                           que leitura seja abortada (Daniel)
  
              21/05/2014 - Ajustado chamadas dos relatorios para que
                           gerem com o cdrelato correto (Odirlei-AMcom)
  
              27/05/2014 - Ajustado para baixar por decurso de prazo os titulos DDA de
                           22 para 59 dias (Tiago SD138818).
  
              06/06/2014 - Ajuste para remoção da mensagem (592 - Bloqueto nao
                           encontrado, 009 - Associado nao cadastrado).
                           Solicitado através do chamado 146138 (Carlos Rafael Tanholi)
  
              10/06/2014 - Ajuste para remoção da mensagem: "Instrucao de protesto nao
                           efetuada, conforme chamado: 144932 02/04/2014 - Jéssica (DB1).
  
              25/06/2014 - #171395 Reincluídos os cdcritic 592 e 009, comentados no ajuste
                           de 6/6/14, pois eles são utilizados no relatório (Carlos)
  
              27/06/2014 - Ajuste no tratamento de erro na rotina de protesto automatico
                           e baixa por decurso de prazo. (Rafael)
  
              21/07/2014 - #171395 Reincluída a mensagem de crítica de associado não
                           encontrado (9) (Carlos)
  
              30/07/2014 - Ajuste na montagem do nome do sacado para usar a gene0007.fn_caract_controle
                           já que estava permitindo caracteres de controle o que invalidava o XML
                           (Marcos-Supero)
  
              09/09/2014 - Ajustes ref. ao Projeto 03-Float (Liberacao em Out/2014) (Rafael)
  
              25/09/2014 - Incluso TRIM nos to_number feitos nas leituras de valores do arquivo,
                           para evitar erro quando a informação for nula, preenchida no arquivo
                           com espaços em branco (Renato - Supero)
  
              23/10/2014 - Ajustes na geração do xml do relatorio para fechar corretamente a tag <float>
                           (Odirlei/Amcom)
  
              05/11/2014 - Ajuste na rotina pc_verifica_vencto. Tratamento para banco/agencias
                           nao localizadas no CAF. (SD 217445 - Rafael).
  
              07/11/2014 - Ajustes identificanos na validação para incorporação da concredi/credimilsul
                           (Odirlei/Amcom)
  
              04/12/2014 - Ajuste de Performance. Retirada a função interna para uso da
                           gene0002.pc_escreve_xml. Retirado o cursor cr_craptab para usar a função
                           tabe0001.fn_busca_dstextab (Alisson-AMcom)
  
              11/12/2014 - Retirado tratamento de verificação se existe crapcob de contas migradas,
                           pois já existe uma validação de que se não existe a cobrança o crapcob é gerado
                           para convenios impressos pelo software(Odirlei/AMcom)
  
              12/12/2014 - Se o convenio for incorporacao/migracao e o cooperado nao for encontrado na
                           cooperativa, entao processar o proximo registro. (Rafael - SD 233200)
  
              30/12/2014 - Alterado procedimento pc_gera_relatorio_686, para incluir no relatorio
                           o bloco de saldo pendente SD214269(Odirlei-AMcom)
  
              23/01/2015 - Correção em cursores com ORDER BY progress_recid para forçar o
                           índice utilizado pelo Progress (Dionathan)
  
              13/02/2015 - Alterado para não mostrar as criticas de protesto e
                           baixa por decurso no log, e sim salvar no log de cobrança
                           que apresentará na tela COBRAN SD250588.
                           E Ajustes para enviar por email as criticas de Tarifa para a
                           area responsavel SD242639 (Odirlei-AMcom)
  
              19/02/2015 - Alterar os comites do fonte, para que sejam executados apenas ao final do processamento
                           dos arquivos, pois houveram problemas no processamento do batch neste dia. (Renato - Supero)
  
              26/02/2015 - Ajustes para tratar o envio de e-mail de erros de tarifas para a cobrança.
                           Alinha com o Rafael Cechet, que caso não sejam encontrados os cadastros dos
                           e-mails, o mesmo seria enviado para cobrança@cecred.coop.br.
                           Também foi feito a tratativa para que em caso de erro no envio, o programa
                           gere um aviso no log com a mensagem de erro e continue o programa sem abortar (Renato - Supero)
  
              08/05/2015 - Adicionado campo data de emissao no relatorio 605. SD 257997 (Kelvin)
                           
              11/06/2015 - Incluido ocorrencias 76 e 77 no processo de liquidaçao ref. ao 
                           projeto 219 - Cooperativa/EE (Daniel)
                         - Ajustes no relatorio 686 referente ao movimento do Float (Rafael)
  
              31/08/2015 - Projeto para tratamento dos programas que geram 
                           criticas que necessitam de lancamentos manuais 
                           pela contabilidade. (Jaison/Marcos-Supero)
  
              10/09/2015 - Ajuste para corrigir o tratamento de erro, apos a chamada das rotinas 
                           pc_proc_liquid_apos_baixa/pc_processa_liquidacao, para retornar o
                           erro corretamente no proc_batch.log
                           (Adriano)
  
              06/10/2015 - Ajustes referente ao Projeto 210 - Pagto de emprestimo c/ boleto (Rafael)
  
              23/11/2015 - Ajustes no posicionamento do processamento das liquidacoes dos boletos
                           de emprestimo ref ao projeto 210. (Rafael)
                           
              26/11/2015 - Ajuste no posicionamento do processamento das liquidacoes 
                           intrabancarias DDA para nao ocorrer erros no processamento das liquidacoes
                           de emprestimo. (Rafael)
                           
              01/12/2015 - Ajuste para definir a data corretamente antes de chamar a rotina             
                           PAGA0001.pc_gera_arq_cooperado SD364513 (Odirlei-AMcom)
                           
              08/12/2015 - Ajuste nas mensagens de log do sistema (proc_message.log). (Rafael)               
  
              28/12/2015 - Ajuste no pagamento de emprestimo, pela COMPEFORA. (James)
              
              12/01/2016 - Enviar e-mail para a area processual de credito 
                           quando ocorrer COMPEFORA. (Rafael)
  
              20/01/2016 - Ajustar a chamada da procedure migrada da package PAGA0001
                           para COBR0007 (Douglas - Importacao de Arquivo CNAB)
  
              03/02/2016 - Ajustar gravacao do relatorio 523 para o utilizar o indice
                           ao inves do contador, pois esta sobrescrevendo o relatorio
                         - Ajustar limite de data de protesto quando a tela for COMPEFORA
                          (Douglas - Chamado 391061)
  
              23/02/2016 - Alterados os 59 dias fixos para Decurso de Prazofoi para 
                           buscar esta informação do Convênio Contratado. 
                           Projeto 213 - Reciprocidade (Lombardi)
              
              26/02/2015 - Campo Float retirado do cabecalho do relatório e passado para a 
                           tabela de detalhes de contas. Projeto 213 - Reciprocidade (Lombardi)
  
        
              29/02/2016 - Inicializar as variaveis totalizadoras para cada contador
                           (Douglas - Chamado 394368)
  
              12/04/2016 - Ajustado a data de movimento para a baixa de titulo
                           (Douglas - Chamado 424571)
                           
              09/05/2016 - Tratamento para não liquidar boletos de convenios bloqueados
                           PRJ318 - Nova Plataforma de cobrança (Odirlei-AMcom)      
                                  
              22/09/2016 - Ajuste nos cursores e alteração da lógica para obtenção de títulos (Rodrigo)
              
              30/09/2016 - Alterações referentes ao projeto 302 - Sistema de acordos
                           (Renato Darosci - Supero)
                        
              10/10/2016 - Alteração do diretório para geração de arquivo contábil.
                           P308 (Ricardo Linhares).
  
              11/10/2016 - Ajustes referente ao processo de REPROC do arquivo COB615 (Renato Darosci)
              
              18/11/2016 - Realizado ajuste para tratar os emprestimos e acordos ao rodar    
                           arquivos de REPROC (Renato Darosci)   
  
              15/12/2016 - Ajustes projeto 340 - Nova plataforma de cobrança.
                           (Odirlei - AMcom)             
  
              10/02/2017 - P340 - Ajustes emergenciais antes da liberação programada de 21/02/17
                         - Ajustado pasta micros/<cooperativa>/abbc;
                         - Ajustado cláusula where dos cursores cr_devolucao; (Rafael)
  
              15/02/2017 - Ajustes referente ao Prj.307 Automatização Arquivos Contábeis Ayllos (Jean Michel)
  
              22/02/2017 - Incluido novamente relatório 618 - CAC (Renato);
                         - Ajustado valor do pagto na rotina de devolução (Rafael);
                         - Ajustado data de movimento no arquivo de devolução (Rafael);
                         
              24/02/2017 - Ajustado relatório 618 em função do novo layout COB615 (Rafael);
  
              15/03/2017 - Removido a inicialição da variavel de multa e juros após inclusão do boleto na
                           PL Table do relatório 618. Estava sendo zerado de forma incorreta, fazendo com 
                           que o boleto tivesse o valor de multa/juros pago zerado (Douglas - Chamado 624683)
  
              17/03/2017 - Ajustes devolução. PRJ340 - NPC (Odirlei-AMcom)
  
              22/03/2017 - Alteração SILOC - Gerar registro na gncpdvc após inserir 
                           o registro na tabela tbcobran_devolucao (Renato Darosci)
                           
              07/04/2017 - #642531 Tratamento do tail para pegar/validar os dados da última linha
                           do arquivo corretamente (Carlos)
  
              12/04/2017 - Cooperado importou o boleto corretamente e imprimiu atraves do software proprio
                           porém na impressão ele utilizou o numero da conta sem o digito verificador e todos 
                           os pagamentos estao sendo rejeitados (Douglas - Chamado 650122)
  
              12/04/2017 - Ajuste para incluir a diferença entre o valor pago e o valor do boleto atualizado
                           com multa e juros, no campo de juros pago. Boleto foi pago com valor maior
                           que o calculado pelo sistema, porem grava apenas a diferença dos valores no campo
                           de juros pago, dessa forma vai gravar o valor correto de juros pago.
                           (Douglas - Chamado 635796)
                           
              17/04/2017 - Adicionar NVL no campo cddbanco para o armazanamento do nome do relatorio 
                           crrl618 (Lucas Ranghetti #620567)
                           
              02/05/2017 - Entrega 02 - Prj.307 Automatização Arquivos Contábeis Ayllos (Jonatas-Supero)                            
  
              21/06/2017 - Alterado mensagens de LOG da crapcol #696421 (Tiago/Rodrigo).
  
              12/07/2017 - #712635 Inclusão tabela crapcco nos cursores cr_cde e cr_boletos_pagos_acordos 
                           para otimização (Carlos)
                           
              11/08/2017 - Retirada as rotinas PAG0001.pc_gera_arq_cooperado
                                              ,pc_gera_relatorio_574
                                              ,pc_gera_relatorio_686
                                              ,pc_gerar_arq_devolucao
                                               e criado um novo programa para contempla-lás
                           Geração de Log no padrão
                           Tratada exceptios others
                           (Belli - Envolti Chamado 714566)
                           
              28/07/2017 - Ajustes para Comandar baixa efetiva de boletos pagos no dia fora da cooperativo.
                           PRJ340 - NPC (Odirlei-AMcom) 
           
              01/08/2017 - Ajuste para incluir a diferença entre o valor pago e o valor do boleto
                           atualizado com multa e juros no campo de juros pago.
                           Esse ajuste foi feito no change set 11141 e liberado em 05/2017, porém
                           o change set 11744 que foi liberado em 06/2017 matou a alteração.
                           Implementação da procedure pc_grava_log para gerar log dos registros
                           que apresentaram critica no loop de processamento das linhas
                           do arquivo. (SD#726081-AJFink)
  
              01/09/2017 - SD737676 - Para evitar duplicidade devido o Matera mudar
                           o nome do arquivo apos processamento, iremos gerar o arquivo
                           _Criticas com o sufixo do crrl gerado por este (Marcos-Supero)
  
              26/09/2017 - Ajuste para validar o valor e a data de vencimento do título
                           somente quando estiver fora do período de convivência da NPC.
                           Títulos estavam sendo devolvidos com a crítica 63.
                           (SD#764044-AJFink)
  
              08/12/2017 - Inclusão de chamada da npcb0002.pc_libera_sessao_sqlserver_npc
                           (SD#791193 - AJFink)
                          
              03/01/2018 - Ajustar a chamada da fn_valid_periodo_conviv pois o 
                           periodo de convivencia será tratado por faixa de valores
                          (Douglas - Chamado 823963)
  
              04/01/2018 - #824283 Verificação de parâmetro para saber se o programa aborta o
                           processo caso não encontre arquivos de retorno (Carlos)
  
              26/01/2018 - Adicionar validação para carregar a data em que boleto pode ser pago
                           (Douglas - Chamado 824706)
  
              14/02/2018 - Retirar regra de devolução do título pelo motivo 63
                           (código de barras em desacordo com as especificacoes).
                           CIP alterou as regras e o fator de vencimento e valor não
                           fazem mais parte dos campos validados. (SD#847687 - AJFink)
  
              22/02/2018 - Inclusão de controle de paralelismo por Agencia (PA) quando solicitado.
                         - Visando performance, Roda somente no processo Noturno
                         - Ajuste no tramamento do arquivo do ABBC - Projeto Ligeirinho (AMcom-Mario)
               - Funcinalidade:
                 - 1. Sem paralelismo: - a quantidade de JOBS para a cdcooper deve ser 0;
                                       - Ativar o programa normalmente.
                 - 2. Com Paralelismo: - a quantidade de JOBS para o cdcooper deve ser > 0;
                                       - ativar o programa normalmente. Roda com PA = 0;
                                       - Cria 1 JOB para cada PA e Ativa/executa os JOBS dos PA's;
                                       - Aguarda todos os JOB's concluirem;
                                       - Consolida todos os PA's lendo os movimentos gerados na tabeça _WRK.
                                       - Em seguida, ativa as rotinas de cobrança, emprestimos e geração dos Relatórios;
                 - JOB Paralelismo: - é ativado pelo programa em CRPS538 em execução.
                                    - processa os registros do arquivo somente do PA passado pelo parâmetro.
                                    - Processa os arquivos .RET e cobrança.
                                    - gera os movimentos para consolidação em tabela _WRK. 
                   
              15/03/2018 - Ajustar os padrões:
                         - Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                         - Eliminando mensagens de erro e informação gravadas fixas
                           (Belli - Envolti - Chamado 801483) 
  
              03/04/2018 - ajuste no tratamento de restart do paralelismo;
                           ajuste no tratamento de erro na exception others (AMcom-Mario)
                           
              27/04/2018 - ao chamar DSCT0001 informar a agencia do PA do Associado referente ao paralelismo (AMcom-Mario).
                   
              01/06/2018 - rename da tabela tbepr_cobranca para tbrecup_cobranca  a ideia é deixar a tabela genérica.
                           ( Daniel Zimmermann - Cecred )
                         - Belli ajustou em e-mail repassado por Carlos Weinhold no dia 05/06/2018             
       
              18/06/2018 - Adicionado o procedimento dsct0003.pc_processa_liquidacao_cobtit para efetuar baixa de titulos gerados
                           pela COBTIT (Paulo Penteado (GFT))
  
              11/07/2018 - Incluir log de verificação da quantidade de tarifas a serem lançadas.
                           Ajuste no cursor cr_lcm_consolidada com to_number do cdhistor.
                           Alteração na ordem de commit e encerra_paralelo. INC0018458 (AJFink)
                   
              03/10/2018 - Variavel idx modificada para idxErro
                           Para não entrar em conflito com a variavel idx do loop de arquivos.
                           (Belli - Envolti - Chamado INC0024883)
  
              11/12/2018 - Alterado logica na validação do cooperado no paralelismo, caso a conta não exista, devemos devolver.
                           Anteriormente, estava dando o Continue, isto fazia com que o boleto não saisse no crrl574.
                           Alcemir Mout's - INC0020305.
                          
              07/01/2019 - Alterações nas regras de devolucao da ABBC, alterado conforme 
                           instrucoes da requisicao. Chamado SCTASK0023401 - Gabriel (Mouts).         
                                    
              31/01/2019 - Adicionado parametro para indicar finalizacao do job (Luis Fernando - GFT)                         
  
              21/03/2019 - A diaria chega um espaço e se executar por fora com nulo  
                           fixar uma descrição para evitar subrotina mudem a logica  
                           (Belli - Envolti - Chamado REQ0037942)
  
              03/06/2019 - Corrigido problema com devolução de titulo que tinha como critica 966, 965
                           cdcritic sendo apagado quando não deveria (Tiago)
                     
              02/10/2019 - Incluido tratamento para erro de titulo ja ultrapassado limite para pagar em cartorio,
                           quando retornar erro, ira realizar a devolucao; Alterado o informa_acesso por set_modulo
                           evitando Alter Session a todo momento (Renan - Supero - INC0014962)
  
              06/03/2020 - O campo deve ser utilizado como um boolean, com zero para false, e um para true.
                           Existem registros que estão sendo inseridos como null.
                           Gabriel Fronza Marcos (Mouts).
  
              09/09/2020 - ritm0090004 correção da query de agências e controle do paralelismo (tbgen_batch_controle).
                           Em casos onde os registros de controle não fossem criados, a consulta de agências não 
                           retornaria as agências ainda não processadas ao reprocessar o programa (Carlos)
  
              30/09/2020 - Não gerar a crítica 965 se houver homologação da API realizada pelo cooperado - RITM0083681 (Jose Dill - Mouts)
  
              22/10/2020 - Ajustar processamento da conciliação da NR para suportar COMPEFORA - PRB0043060 (PTASK0010194) (AJFink)

              18/11/2020 - Gerar devolução para as situações 1464,1294. PRB0043811 (Jose Dill - Mouts)

              19/02/2021 - Ajustar o problema de pendencia contabil devido devolução do motivo 77 - Boleto em cartório ou protestado. PRB0044174 (Jose Dill - Mouts)

              29/12/2021 - Retirar a procedure pc_cria_job_baixa_efetiva - PRJ0023522 (Mouts - Jose Dill)     
              
              15/07/2022 - Realizar devolução de pagamentos já liquidados e atualizar motivos de devolução (códigos) conforme tabela da CIP - PRJ0024441 (Mouts - Jose Dill)                        

              26/07/2022 - Melhoria na rotina pc_integra_cobranca_registrada do programa crps538, otimizando os cursores dos convênios ativos, melhoria de código 
                           e inclusão de logs para medição de performance (Carlos)
                           
  .............................................................................*/

  DECLARE
  
    /* Tipos e registros da pc_CRPS538 */
  
    TYPE typ_reg_crapcco IS RECORD(
       cdcooper crapcco.cdcooper%TYPE
      ,cdagenci crapcco.cdagenci%TYPE
      ,cdbccxlt crapcco.cdbccxlt%TYPE
      ,nrdolote crapcco.nrdolote%TYPE
      ,nrconven crapcco.nrconven%TYPE
      ,flgativo crapcco.flgativo%TYPE
      ,cddbanco crapcco.cddbanco%TYPE
      ,nrdctabb crapcco.nrdctabb%TYPE
      ,dsorgarq crapcco.dsorgarq%TYPE
      ,flgregis crapcco.flgregis%TYPE
      ,cdcopant crapcco.cdcooper%TYPE
      ,dsorgant crapcco.dsorgarq%TYPE);
  
    TYPE typ_reg_conv_arq IS RECORD(
       cdcooper crapcop.cdcooper%TYPE
      ,dtmvtolt crapdat.dtmvtolt%TYPE
      ,cdagenci crapage.cdagenci%TYPE
      ,cdbccxlt craplot.cdbccxlt%TYPE
      ,nrdolote craplot.nrdolote%TYPE
      ,nrconven crapcco.nrconven%TYPE);
  
    TYPE typ_reg_craptco IS RECORD(
       cdcooper craptco.cdcooper%TYPE
      ,nrdconta craptco.nrdconta%TYPE
      ,cdcopant craptco.cdcopant%TYPE
      ,nrctaant craptco.nrctaant%TYPE);
  
    --Definicao dos tipos de tabelas
    TYPE typ_tab_craptco IS TABLE OF typ_reg_craptco INDEX BY PLS_INTEGER;
    TYPE typ_tab_crapcco IS TABLE OF typ_reg_crapcco INDEX BY VARCHAR2(20);
    TYPE typ_tab_conv_arq IS TABLE OF typ_reg_conv_arq INDEX BY VARCHAR2(20);
    TYPE typ_tab_crapmot IS TABLE OF crapmot.dsmotivo%TYPE INDEX BY VARCHAR2(17);

    --
    /* ------------------------------------------------------------ */
    /* -- Contantes Globais --------------------------------------- */
    /* ------------------------------------------------------------ */
    --
    ct_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS538';
    ct_cdoperad CONSTANT VARCHAR2(100) := '1';
    --

    vr_typ_craprej_array TYP_CRAPREJ_ARRAY := TYP_CRAPREJ_ARRAY();
  
    --Definicao das tabelas de memoria
    vr_tab_crapcco  typ_tab_crapcco;
    vr_tab_craptco  typ_tab_craptco;
    vr_tab_conv_arq typ_tab_conv_arq;
    vr_tab_crapmot  typ_tab_crapmot;
  
    --Tabela para receber arquivos lidos no unix
    vr_tab_nmarqtel GENE0002.typ_split;
    --Tabela de lancamentos para consolidar
    vr_tab_lcm_consolidada PAGA0001.typ_tab_lcm_consolidada;
    vr_tab_lat_consolidada PAGA0001.typ_tab_lat_consolidada;
  
    -- Retirada variavel pertencente a rotina PAGA0001.pc_gera_arq_cooperado - Chamado 714566 - 11/08/2017
    ---vr_tab_arq_cobranca    PAGA0001.typ_tab_arq_cobranca;
  
    --Tabela de Titulos
    vr_tab_titulos   PAGA0001.typ_tab_titulos;
    vr_tab_descontar PAGA0001.typ_tab_titulos;
    --Tabela de Memoria de erro
    vr_tab_erro  GENE0001.typ_tab_erro;
    vr_tab_erro2 GENE0001.typ_tab_erro;
  
    vr_idprglog tbgen_prglog.idprglog%TYPE := 0;
  
    -- Variaveis de controle com arquivo processado - Chamado 714566 - 11/08/2017
    vr_intemarq BOOLEAN; --> Nome tela anterior
  
    -- ID para o paralelismo
    vr_idparale INTEGER;
    -- Qtde parametrizada de Jobs
    vr_qtdjobs NUMBER;
    -- Job name dos processos criados
    vr_jobname VARCHAR2(30);
    -- Bloco PLSQL para chamar a execução paralela do pc_crps750
    vr_dsplsql VARCHAR2(4000);
  
    -- Inclui 0 na inicialização conf Mario - 15/03/2018 - Chamado 801483
    --Código de controle retornado pela rotina gene0001.pc_grava_batch_controle
    vr_idcontrole tbgen_batch_controle.idcontrole%TYPE := 0;
  
    -- Variaveis TBGEN - 15/03/2018 - Chamado 801483       
    vr_tpocorre tbgen_prglog_ocorrencia.tpocorrencia%TYPE;
    vr_cdcricid tbgen_prglog_ocorrencia.cdcriticidade%TYPE;
  
    -- Variavel para modificar o parametro quando chegar nulo - 21/03/2019 - REQ0037942
    vr_nmtelant VARCHAR2(30);
  
    /* Cursores da rotina CRPS538 */
  
    -- Agências por cooperativa com clientes
    CURSOR cr_crapass_age(pr_cdcooper IN crapass.cdcooper%TYPE
                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                         ,pr_cdprogra IN tbgen_batch_controle.cdprogra%TYPE) IS
      SELECT DISTINCT cdagenci
        FROM crapass crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND NOT EXISTS (SELECT 1
                FROM tbgen_batch_controle
               WHERE tbgen_batch_controle.cdcooper = pr_cdcooper
                 AND tbgen_batch_controle.cdprogra = pr_cdprogra
                 AND tbgen_batch_controle.tpagrupador = 1
                 AND tbgen_batch_controle.cdagrupador = crapass.cdagenci
                 AND tbgen_batch_controle.insituacao = 2
                 AND tbgen_batch_controle.dtmvtolt = pr_dtmvtolt)
       ORDER BY cdagenci;
  
    -- Agências com erro
    CURSOR cr_crapass_err(pr_cdcooper IN crapass.cdcooper%TYPE
                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                         ,pr_cdprogra IN tbgen_batch_controle.cdprogra%TYPE) IS
      SELECT DISTINCT cdagenci
        FROM crapass crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND EXISTS (SELECT 1
                FROM tbgen_batch_controle
               WHERE tbgen_batch_controle.cdcooper = pr_cdcooper
                 AND tbgen_batch_controle.cdprogra = pr_cdprogra
                 AND tbgen_batch_controle.tpagrupador = 1
                 AND tbgen_batch_controle.cdagrupador = crapass.cdagenci
                 AND tbgen_batch_controle.insituacao = 1
                 AND tbgen_batch_controle.dtmvtolt = pr_dtmvtolt)
       ORDER BY cdagenci;
  
    -- Excluido cr_erro pelo motivo que não é utilizado conf. Mario - 15/03/2018 - Chamado 801483              
  
    -- Selecionar os dados da Cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cop.cdcooper
            ,cop.nmrescop
            ,cop.nrtelura
            ,cop.cdbcoctl
            ,cop.cdagectl
            ,cop.dsdircop
            ,cop.nrctactl
            ,cop.cdagedbb
            ,cop.cdageitg
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
  
    --Selecionar associados
    CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdctitg
            ,crapass.nrdconta
            ,crapass.cdsitdtl
            ,crapass.dtelimin
            ,crapass.cdagenci
            ,crapass.inpessoa
        FROM crapass crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
  
    --Selecionar informacoes log cobranca
    CURSOR cr_crapcol(pr_cdcooper IN crapcol.cdcooper%TYPE
                     ,pr_cdoperad IN crapcol.cdoperad%TYPE
                     ,pr_datailog IN crapcol.dtaltera%TYPE
                     ,pr_dataflog IN crapcol.dtaltera%TYPE
                     ,pr_horailog IN crapcol.hrtransa%TYPE
                     ,pr_horaflog IN crapcol.hrtransa%TYPE) IS
      SELECT crapcol.dslogtit
        FROM crapcol
       WHERE crapcol.cdcooper = pr_cdcooper
         AND crapcol.cdoperad = pr_cdoperad
         AND crapcol.dtaltera BETWEEN pr_datailog AND pr_dataflog
         AND crapcol.hrtransa BETWEEN pr_horailog AND pr_horaflog;
  
    --Selecionar todas as cooperativas
    CURSOR cr_crapcop_lista IS
      SELECT crapcop.cdcooper
        FROM crapcop;
  
    --Selecionar todos os convenios
    CURSOR cr_crapcco IS
      SELECT crapcco.nrconven
            ,crapcco.flgativo
            ,crapcco.dsorgarq
            ,crapcco.cdcooper
            ,crapcco.cddbanco
            ,crapcco.nrdctabb
            ,crapcco.cdagenci
            ,crapcco.cdbccxlt
            ,crapcco.nrdolote
            ,crapcco.flgregis
        FROM crapcco;
  
    --Selecionar as contas migradas
    CURSOR cr_craptco(pr_cdcooper IN craptco.cdcooper%TYPE) IS
      SELECT craptco.nrctaant
            ,craptco.cdcopant
            ,craptco.cdcooper
            ,craptco.nrdconta
        FROM craptco
       WHERE craptco.cdcopant = pr_cdcooper
         AND craptco.tpctatrf = 1
         AND craptco.flgativo = 1; /*TRUE*/
  
    --Selecionar Borderos Cobranca
    CURSOR cr_crapcob(pr_cdcooper IN crapcob.cdcooper%TYPE
                     ,pr_cdbandoc IN crapcco.cddbanco%TYPE
                     ,pr_nrdctabb IN crapcco.nrdctabb%TYPE
                     ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                     ,pr_nrdconta IN crapcob.nrdconta%TYPE
                     ,pr_nrdocmto IN crapcob.nrdocmto%TYPE) IS
      SELECT crapcob.cdcooper
            ,crapcob.flgregis
            ,crapcob.incobran
            ,crapcob.insitcrt
            ,crapcob.cdtitprt
            ,crapcob.nrdconta
            ,crapcob.nrinssac
            ,crapcob.dsdoccop
            ,crapcob.dtvencto
            ,crapcob.vltitulo
            ,crapcob.vldescto
            ,crapcob.vlabatim
            ,crapcob.cdmensag
            ,crapcob.tpdmulta
            ,crapcob.tpjurmor
            ,crapcob.nrcnvcob
            ,crapcob.nrdocmto
            ,crapcob.vlrmulta
            ,crapcob.vljurdia
            ,crapcob.indpagto
            ,crapcob.dtmvtolt
            ,crapcob.rowid
            ,crapcob.inemiten
            ,crapcob.nrctremp
            ,crapcob.vldpagto
            ,crapcob.inserasa
            ,crapcob.dtvctori
            ,crapcob.nrdctabb
            ,crapcob.nrctasac
            ,crapcob.inpagdiv
            ,crapcob.vlminimo
        FROM crapcob
       WHERE crapcob.cdcooper = pr_cdcooper
         AND crapcob.cdbandoc = pr_cdbandoc
         AND crapcob.nrdctabb = pr_nrdctabb
         AND crapcob.nrcnvcob = pr_nrcnvcob
         AND crapcob.nrdconta = pr_nrdconta
         AND crapcob.nrdocmto = pr_nrdocmto;
    rw_crapcob cr_crapcob%ROWTYPE;
    rw_crabcob cr_crapcob%ROWTYPE;
  
    --Selecionar Informacoes do Sacado
    CURSOR cr_crapsab(pr_cdcooper IN crapsab.cdcooper%TYPE
                     ,pr_nrdconta IN crapsab.nrdconta%TYPE
                     ,pr_nrinssac IN crapsab.nrinssac%TYPE) IS
      SELECT crapsab.cdcooper
            ,crapsab.nrdconta
            ,crapsab.nrinssac
            ,crapsab.nmdsacad
        FROM crapsab
       WHERE crapsab.cdcooper = pr_cdcooper
         AND crapsab.nrdconta = pr_nrdconta
         AND crapsab.nrinssac = pr_nrinssac;
    rw_crapsab cr_crapsab%ROWTYPE;
  
    --Selecionar informacoes convenios ativos
    CURSOR cr_crapcco_ativo(pr_cdcooper IN crapcco.cdcooper%TYPE
                           ,pr_cddbanco IN crapcco.cddbanco%TYPE) IS
      SELECT CRAPCCO.CDCOOPER,
             CRAPCCO.NRCONVEN,
             CRAPCCO.NRDCTABB,
             CRAPCCO.CDDBANCO,
             CRAPCCO.CDAGENCI,
             CRAPCCO.CDBCCXLT,
             CRAPCCO.NRDOLOTE,
             CRAPCCO.DSORGARQ
        FROM CRAPCCO
       WHERE CRAPCCO.CDCOOPER = PR_CDCOOPER
         AND CRAPCCO.CDDBANCO = PR_CDDBANCO
         AND CRAPCCO.FLGREGIS = 1;
  
    --Utilizado no paralelismo
    --Selecionar informacoes convenios ativos
    CURSOR cr_crapcco_ativo_age(pr_cdcooper IN crapcco.cdcooper%TYPE
                               ,pr_cddbanco IN crapcco.cddbanco%TYPE
                               ,pr_cdagenci IN crapass.cdagenci%TYPE) IS
      SELECT DISTINCT crapcco.cdcooper
                     ,crapcco.nrconven
                     ,crapcco.nrdctabb
                     ,crapcco.cddbanco
                     ,ass.cdagenci --crapcco.cdagenci  --alterado Paralelismo
                     ,crapcco.cdbccxlt
                     ,crapcco.nrdolote
                     ,crapcco.dsorgarq
        FROM crapcco
            ,crapceb ceb
            ,crapass ass
       WHERE crapcco.cdcooper = pr_cdcooper
         AND crapcco.cddbanco = pr_cddbanco
         AND crapcco.flgregis = 1
         AND crapcco.dsorgarq IN ('EMPRESTIMO', 'ACORDO', 'DESCONTO DE TITULO') --3 registros
         AND ceb.cdcooper = crapcco.cdcooper
         AND ceb.nrconven = crapcco.nrconven
         AND ass.cdcooper = ceb.cdcooper
         AND ass.nrdconta = ceb.nrdconta
         AND ass.cdagenci = decode(pr_cdagenci, 0, ass.cdagenci, pr_cdagenci);
  
    --Selecionar Informacoes Bancos
    CURSOR cr_crapban(pr_cdbccxlt IN crapban.cdbccxlt%TYPE) IS
      SELECT crapban.nmextbcc
        FROM crapban
       WHERE crapban.cdbccxlt = pr_cdbccxlt;
  
    --Selecionar Motivos
    CURSOR cr_crapmot(pr_cdcooper IN crapmot.cdcooper%TYPE) IS
      SELECT crapmot.cddbanco
            ,crapmot.cdocorre
            ,crapmot.tpocorre
            ,crapmot.cdmotivo
            ,crapmot.dsmotivo
        FROM crapmot
       WHERE crapmot.cdcooper = pr_cdcooper;
  
    --Selecionar informacoes convenio 'IMPRESSO PELO SOFTWARE'
    CURSOR cr_cco_impresso(pr_nrconven IN crapcco.nrconven%TYPE) IS
      SELECT crapcco.cdcooper
            ,crapcco.dsorgarq
        FROM crapcco
       WHERE crapcco.cdcooper > 0
         AND crapcco.nrconven = pr_nrconven
         AND crapcco.dsorgarq = 'IMPRESSO PELO SOFTWARE';
    rw_cco_impresso cr_cco_impresso%ROWTYPE;
  
    -- buscar dados do convenio de cobranca cadastrado
    CURSOR cr_crapceb(pr_cdcooper IN crapceb.cdcooper%TYPE
                     ,pr_nrdconta IN crapceb.nrdconta%TYPE
                     ,pr_nrconven IN crapceb.nrconven%TYPE) IS
      SELECT ceb.flgcebhm
            ,ceb.insitceb
            ,ceb.flgapihm
        FROM crapceb ceb
       WHERE ceb.cdcooper = pr_cdcooper
         AND ceb.nrdconta = pr_nrdconta
         AND ceb.nrconven = pr_nrconven;
    rw_crapceb cr_crapceb%ROWTYPE;
  
    -- buscar boletos de contrato pagos na cobranca para serem regularizados
    CURSOR cr_cde(pr_cdcooper IN crapret.cdcooper%TYPE
                 ,pr_nrcnvcob IN crapret.nrcnvcob%TYPE
                 ,pr_dtocorre IN crapret.dtocorre%TYPE
                 ,pr_cdagenci IN crapass.cdagenci%TYPE) IS
      SELECT ass.cdagenci
            ,cde.cdcooper
            ,cde.nrdconta
            ,cde.nrctremp
            ,cde.nrcnvcob
            ,cde.nrboleto
            ,cde.tpparcela
            ,cob.dsdoccop
            ,cob.dtvencto
            ,cob.vltitulo
            ,ret.vlrpagto
            ,ret.flcredit
            ,cob.rowid cob_rowid
        FROM crapret          ret
            ,crapcob          cob
            ,tbrecup_cobranca cde
            ,crapass          ass
            ,crapcco          cco
       WHERE ret.cdcooper = pr_cdcooper
         AND ret.nrcnvcob = pr_nrcnvcob
         AND ret.dtocorre = pr_dtocorre
         AND ret.cdocorre IN (6, 76) -- liquidacao normal COO/CEE
         AND cob.cdcooper = ret.cdcooper
         AND cob.nrcnvcob = ret.nrcnvcob
         AND cob.nrdconta = ret.nrdconta
         AND cob.nrdocmto = ret.nrdocmto
         AND cco.cdcooper = cde.cdcooper
         AND cco.nrconven = cde.nrcnvcob
         AND cob.nrctremp > 0
         AND cde.tpproduto = 0
         AND cde.cdcooper = cob.cdcooper
         AND cde.nrdconta_cob = cob.nrdconta
         AND cde.nrcnvcob = cob.nrcnvcob
         AND cde.nrboleto = cob.nrdocmto
         AND cob.cdbandoc = cco.cddbanco
         AND cob.nrdctabb = cco.nrdctabb
         AND ass.cdcooper = cde.cdcooper
         AND ass.nrdconta = cde.nrdconta
            --Inclusão do controle de paralelismo
         AND ass.cdagenci = decode(pr_cdagenci, 0, ass.cdagenci, pr_cdagenci)

           AND cob.ROWID IN (
            SELECT cob.rowid idrowid_cob
              FROM crapcob cob
                  ,(SELECT (SELECT ceb.cdcooper
                              FROM crapceb ceb
                             WHERE ceb.nrconven = to_number(substr(tit.dscodbar, 20, 6))
                               AND ceb.nrdconta = to_number(substr(tit.dscodbar, 26, 8))) cdcooper
                          ,to_number(substr(tit.dscodbar, 20, 6)) nrcnvcob
                          ,to_number(substr(tit.dscodbar, 26, 8)) nrdconta
                          ,to_number(substr(tit.dscodbar, 34, 9)) nrdocmto
                      FROM gncptit tit
                     WHERE tit.cdcooper = pr_cdcooper
                       AND tit.dtmvtolt = vr_dtmvtolt_gncptit
                       AND tit.cdbandst = 85
                       AND tit.nmarquiv = vr_nmarquiv_gncptit) a
             WHERE cob.nrdocmto = a.nrdocmto
               AND cob.nrdconta = a.nrdconta
               AND cob.nrcnvcob = a.nrcnvcob
               AND cob.cdcooper = a.cdcooper
               AND cob.incobran = 5)

       ORDER BY cde.nrdconta
               ,cde.nrctremp;
    rw_cde cr_cde%ROWTYPE;
  
    -- buscar boletos da COBTIT pagos na cobranca para serem regularizados
    CURSOR cr_tit(pr_cdcooper IN crapret.cdcooper%TYPE
                 ,pr_nrcnvcob IN crapret.nrcnvcob%TYPE
                 ,pr_dtocorre IN crapret.dtocorre%TYPE
                 ,pr_cdagenci IN crapass.cdagenci%TYPE) IS
    -- Desconto de Titulos COBTIT
      SELECT ass.cdagenci
            ,cde.cdcooper
            ,cde.nrdconta_cob nrdconta
            ,cde.nrctremp
            ,cde.nrcnvcob
            ,cde.nrboleto
            ,cde.tpparcela
            ,cob.dsdoccop
            ,cob.dtvencto
            ,cob.vltitulo
            ,ret.vlrpagto
            ,ret.flcredit
            ,cob.rowid        cob_rowid
            ,cob.indpagto
            ,cob.nrctasac
        FROM crapret          ret
            ,crapcob          cob
            ,tbrecup_cobranca cde
            ,crapass          ass
            ,crapcco          cco
       WHERE ret.cdcooper = pr_cdcooper
         AND ret.nrcnvcob = pr_nrcnvcob
         AND ret.dtocorre = pr_dtocorre
         AND ret.cdocorre IN (6, 76) -- liquidacao normal COO/CEE
         AND cob.cdcooper = ret.cdcooper
         AND cob.nrcnvcob = ret.nrcnvcob
         AND cob.nrdconta = ret.nrdconta
         AND cob.nrdocmto = ret.nrdocmto
         AND cco.cdcooper = cde.cdcooper
         AND cco.nrconven = cde.nrcnvcob
         AND nvl(cob.nrctremp, 0) = 0
         AND cde.tpproduto = 3 -- COBTIT
         AND cde.cdcooper = cob.cdcooper
         AND cde.nrdconta_cob = cob.nrdconta
         AND cde.nrcnvcob = cob.nrcnvcob
         AND cde.nrboleto = cob.nrdocmto
         AND cob.cdbandoc = cco.cddbanco
         AND cob.nrdctabb = cco.nrdctabb
         AND ass.cdcooper = cde.cdcooper
         AND ass.nrdconta = cde.nrdconta
            --Inclusão do controle de paralelismo
         AND ass.cdagenci = decode(pr_cdagenci, 0, ass.cdagenci, pr_cdagenci)

           AND cob.ROWID IN (
            SELECT cob.rowid idrowid_cob
              FROM crapcob cob
                  ,(SELECT (SELECT ceb.cdcooper
                              FROM crapceb ceb
                             WHERE ceb.nrconven = to_number(substr(tit.dscodbar, 20, 6))
                               AND ceb.nrdconta = to_number(substr(tit.dscodbar, 26, 8))) cdcooper
                          ,to_number(substr(tit.dscodbar, 20, 6)) nrcnvcob
                          ,to_number(substr(tit.dscodbar, 26, 8)) nrdconta
                          ,to_number(substr(tit.dscodbar, 34, 9)) nrdocmto
                      FROM gncptit tit
                     WHERE tit.cdcooper = pr_cdcooper
                       AND tit.dtmvtolt = vr_dtmvtolt_gncptit
                       AND tit.cdbandst = 85
                       AND tit.nmarquiv = vr_nmarquiv_gncptit) a
             WHERE cob.nrdocmto = a.nrdocmto
               AND cob.nrdconta = a.nrdconta
               AND cob.nrcnvcob = a.nrcnvcob
               AND cob.cdcooper = a.cdcooper
               AND cob.incobran = 5)

       ORDER BY cde.nrdconta
               ,cde.nrctremp;
  
    -- Buscar boletos dos acordos pagos na cobranca para serem regularizados
    CURSOR cr_boletos_pagos_acordos(pr_cdcooper IN crapret.cdcooper%TYPE
                                   ,pr_nrcnvcob IN crapret.nrcnvcob%TYPE
                                   ,pr_dtocorre IN crapret.dtocorre%TYPE) IS
      SELECT aco.cdcooper
            ,aco.nrdconta
            ,acp.nracordo
            ,acp.nrparcela
            ,acp.nrconvenio
            ,acp.nrboleto
            ,cob.dsdoccop
            ,cob.dtvencto
            ,cob.vltitulo
            ,ret.vlrpagto
            ,ret.flcredit
            ,cob.rowid cob_rowid
        FROM crapret                ret
            ,crapcob                cob
            ,tbrecup_acordo_parcela acp
            ,tbrecup_acordo         aco
            ,crapcco                cco
       WHERE ret.cdcooper = pr_cdcooper
         AND ret.nrcnvcob = pr_nrcnvcob
         AND ret.dtocorre = pr_dtocorre
         AND ret.cdocorre IN (6, 76) -- liquidacao normal COO/CEE
            
         AND cob.cdcooper = ret.cdcooper
         AND cob.nrcnvcob = ret.nrcnvcob
         AND cob.nrdconta = ret.nrdconta
         AND cob.nrdocmto = ret.nrdocmto
            
         AND aco.cdcooper = cob.cdcooper
         AND acp.nrdconta_cob = cob.nrdconta
         AND acp.nrconvenio = cob.nrcnvcob
         AND acp.nrboleto = cob.nrdocmto
            
         AND cco.cdcooper = ret.cdcooper
         AND cco.nrconven = ret.nrcnvcob
         AND cob.cdbandoc = cco.cddbanco
         AND cob.nrdctabb = cco.nrdctabb

           AND cob.ROWID IN (
            SELECT cob.rowid idrowid_cob
              FROM crapcob cob
                  ,(SELECT (SELECT ceb.cdcooper
                              FROM crapceb ceb
                             WHERE ceb.nrconven = to_number(substr(tit.dscodbar, 20, 6))
                               AND ceb.nrdconta = to_number(substr(tit.dscodbar, 26, 8))) cdcooper
                          ,to_number(substr(tit.dscodbar, 20, 6)) nrcnvcob
                          ,to_number(substr(tit.dscodbar, 26, 8)) nrdconta
                          ,to_number(substr(tit.dscodbar, 34, 9)) nrdocmto
                      FROM gncptit tit
                     WHERE tit.cdcooper = pr_cdcooper
                       AND tit.dtmvtolt = vr_dtmvtolt_gncptit
                       AND tit.cdbandst = 85
                       AND tit.nmarquiv = vr_nmarquiv_gncptit) a
             WHERE cob.nrdocmto = a.nrdocmto
               AND cob.nrdconta = a.nrdconta
               AND cob.nrcnvcob = a.nrcnvcob
               AND cob.cdcooper = a.cdcooper
               AND cob.incobran = 5)
              
         AND aco.nracordo = acp.nracordo;
  
    -- Busca dados para relatório 618
    CURSOR cr_crap618(pr_cdcooper    IN NUMBER
                     ,pr_dtmvtolt    IN DATE
                     ,PR_cdprograma  IN VARCHAR2
                     ,pr_dsrelatorio IN VARCHAR2) IS
      SELECT cdcooper
            ,cdprograma
            ,dsrelatorio
            ,dtmvtolt
            ,cdagenci
            ,dsdoccop
            ,dtvencto
            ,vltitulo
            ,vldpagto
            ,dscritic
            ,DSXML
            ,to_number(substr(dbms_lob.substr(dsxml, 4000, 1), 001, 03)) cdbanpag
            ,substr(dbms_lob.substr(dsxml, 4000, 1), 004, 08) dsbanage
            ,to_number(substr(dbms_lob.substr(dsxml, 4000, 1), 012, 15)) nrcpfcnj
            ,substr(dbms_lob.substr(dsxml, 4000, 1), 027, 50) nmsacado
            ,substr(dbms_lob.substr(dsxml, 4000, 1), 077, 50) dscodbar
            ,to_number(substr(dbms_lob.substr(dsxml, 4000, 1), 127, 20)) vljurmul
            ,to_number(substr(dbms_lob.substr(dsxml, 4000, 1), 147, 20)) vlrpagto
            ,to_number(substr(dbms_lob.substr(dsxml, 4000, 1), 167, 20)) vlrdifer
            ,to_number(substr(dbms_lob.substr(dsxml, 4000, 1), 187, 20)) vldescar
            ,dschave
        FROM TBGEN_BATCH_RELATORIO_WRK
       WHERE cdcooper = pr_cdcooper
         AND cdprograma = PR_cdprograma
         AND dsrelatorio = pr_dsrelatorio
         AND TO_CHAR(dtmvtolt, 'YYYYMMDD') = TO_CHAR(pr_dtmvtolt, 'YYYYMMDD')
       ORDER BY cdbanpag
               ,dschave
               ,cdagenci;
  
    -- Busca dados para relatório 706
    CURSOR cr_crap706(pr_cdcooper    IN NUMBER
                     ,pr_dtmvtolt    IN DATE
                     ,PR_cdprograma  IN VARCHAR2
                     ,pr_dsrelatorio IN VARCHAR2) IS
      SELECT cdcooper
            ,cdprograma
            ,dsrelatorio
            ,dtmvtolt
            ,cdagenci
            ,nrdconta
            ,nrcnvcob
            ,nrdocmto
            ,nrctremp
            ,dsdoccop
            ,tpparcel
            ,dtvencto
            ,vltitulo
            ,vldpagto
            ,dscritic
            ,dschave
        FROM TBGEN_BATCH_RELATORIO_WRK
       WHERE cdcooper = pr_cdcooper
         AND cdprograma = PR_cdprograma
         AND dsrelatorio = pr_dsrelatorio
         AND TO_CHAR(dtmvtolt, 'YYYYMMDD') = TO_CHAR(pr_dtmvtolt, 'YYYYMMDD')
       ORDER BY dschave
               ,nrdconta;
  
    -- Busca Comandos SHELL do UNIX
    CURSOR cr_crapcom(pr_cdcooper    IN NUMBER
                     ,PR_cdprograma  IN VARCHAR2
                     ,pr_dsrelatorio IN VARCHAR2
                     ,pr_dtmvtolt    IN DATE) IS
      SELECT DISTINCT dscritic
        FROM TBGEN_BATCH_RELATORIO_WRK
       WHERE cdcooper = pr_cdcooper
         AND cdprograma = PR_cdprograma
         AND dsrelatorio = pr_dsrelatorio
         AND dtmvtolt = pr_dtmvtolt;
  
    -- Busca dados para craprej
    CURSOR cr_craprej(pr_cdcooper    IN NUMBER
                     ,PR_cdprograma  IN VARCHAR2
                     ,pr_dsrelatorio IN VARCHAR2
                     ,pr_dtmvtolt    IN DATE) IS
      SELECT cdcooper
            ,cdprograma
            ,dsrelatorio
            ,dtmvtolt
            ,cdagenci
            ,nrdconta    nrdconta
            ,nrcnvcob    nrseqdig
            ,nrdocmto    nrdocmto
            ,nrctremp    cdbccxlt
            ,tpparcel    cdcritic
            ,vltitulo    vllanmto
            ,dscritic    cdpesqbb
        FROM TBGEN_BATCH_RELATORIO_WRK
       WHERE cdcooper = pr_cdcooper
         AND cdprograma = PR_cdprograma
         AND dsrelatorio = pr_dsrelatorio
         AND TO_CHAR(dtmvtolt, 'YYYYMMDD') = TO_CHAR(pr_dtmvtolt, 'YYYYMMDD')
       ORDER BY nrcnvcob
               ,nrdconta
               ,nrdocmto;
  
    -- Busca dados para typ_reg_lcm_consolidada
    CURSOR cr_lcm_consolidada(pr_cdcooper    IN NUMBER
                             ,PR_cdprograma  IN VARCHAR2
                             ,pr_dsrelatorio IN VARCHAR2
                             ,pr_dtmvtolt    IN DATE) IS
      SELECT cdcooper
            ,cdprograma
            ,dsrelatorio
            ,dtmvtolt
            ,cdagenci
            ,nrdconta nrdconta
            ,nrcnvcob nrconven
            ,nrdocmto nrdocmto
            ,nrctremp nrctremp
            ,tpparcel cdocorre
            ,vltitulo vllancto
            ,dscritic cdpesqbb
            ,to_number(substr(dbms_lob.substr(dsxml, 4000, 1), 01, 10)) cdhistor --INC0018458
            ,substr(dbms_lob.substr(dsxml, 4000, 1), 11, 15) qtdregis
            ,substr(dbms_lob.substr(dsxml, 4000, 1), 26, 15) cdfvlcop
            ,substr(dbms_lob.substr(dsxml, 4000, 1), 41, 1000) tplancto
            ,dschave
        FROM TBGEN_BATCH_RELATORIO_WRK
       WHERE cdcooper = pr_cdcooper
         AND cdprograma = PR_cdprograma
         AND dsrelatorio = pr_dsrelatorio
         AND TO_CHAR(dtmvtolt, 'YYYYMMDD') = TO_CHAR(pr_dtmvtolt, 'YYYYMMDD')
       ORDER BY dschave
               ,cdagenci;
  
    --Registro do tipo calendario
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    rw_craprej craprej%ROWTYPE;
  
    --Variaveis Locais
    vr_comando         VARCHAR2(1000);
    vr_typ_saida       VARCHAR2(1000);
    vr_flgbatch        INTEGER;
    vr_nmarqret        VARCHAR2(100);
    vr_nmorigem        VARCHAR2(100);
    vr_dtleiarq        VARCHAR2(10);
    vr_dtarquiv        VARCHAR2(10);
    vr_dstipcob        VARCHAR2(6);
    vr_dtleiaux        VARCHAR2(8);
    vr_setlinha        VARCHAR2(1000);
    vr_caminho_puro    VARCHAR2(1000);
    vr_caminho_rl      VARCHAR2(1000);
    vr_caminho_integra VARCHAR2(1000);
    vr_caminho_salvar  VARCHAR2(1000);
    vr_caminho_rl_3    VARCHAR2(1000);
    vr_flgpgdda        INTEGER;
  
    vr_nrcnvcob INTEGER;
    vr_nrdconta INTEGER;
    vr_nrdocmto INTEGER;
    vr_cdmotdev INTEGER;
    vr_dtmvtolt DATE;
    vr_dtmvtaux DATE;
  
    -- Retirada variavel pertencente a rotina COBR0007.pc_inst_protestar - Chamado 714566 - 11/08/2017 
    vr_dtdpagto DATE;
    vr_vlliquid NUMBER;
    vr_vldescar NUMBER;
    vr_dstextab VARCHAR2(1000);
    vr_nmarqimp VARCHAR2(100);
    vr_vltotpag NUMBER := 0;
  
    -- Parametros de pagamentos divergentes
    vr_tolerancia          NUMBER;
    vr_resto               NUMBER;
    vr_resto_positivo      NUMBER;
    vr_flgmenor            BOOLEAN := FALSE;
    vr_flgmaior            BOOLEAN := FALSE;
    vr_permite_divergencia BOOLEAN := FALSE;
  
    vr_tot_reg   NUMBER := 0;
    vr_tot_paerr NUMBER := 0;
  
    vr_nmdestin     VARCHAR2(100);
    vr_cdtipdoc     VARCHAR2(100);
    vr_listadir     VARCHAR2(4000);
    vr_datailog     DATE;
    vr_dataflog     DATE;
    vr_horailog     INTEGER;
    vr_horaflog     INTEGER;
    vr_vlrmincac    NUMBER;
    vr_dtrefere     DATE;
    vr_dtcredit     DATE;
    vr_email_tarif  VARCHAR2(1000);
    vr_descorpo     VARCHAR2(3900);
    vr_flamenor     BOOLEAN := FALSE;
    vr_cdtipreg     NUMBER;
    vr_dscodbar_ori VARCHAR2(60);
    vr_vltitulo     crapcob.vltitulo%TYPE;
    vr_nrispbif_rec crapban.nrispbif%TYPE;
    vr_nrispbif_fav crapban.nrispbif%TYPE;
  
    vr_fcrapcob BOOLEAN;
    vr_nrseqarq INTEGER;
    vr_tpcaptur INTEGER;
    vr_tpdocmto INTEGER;
  
    -- Variáveis relacionadas ao processo de REPROC
    vr_inreproc BOOLEAN := FALSE;
    vr_dsarqrep VARCHAR2(100);
    vr_dsreproc VARCHAR2(5);
    vr_qterro   NUMBER := 0;
  
    --Variaveis para retorno de erro
    vr_des_erro  VARCHAR2(3);
    vr_cdcritic  INTEGER := 0;
    vr_dscritic  VARCHAR2(4000);
    vr_cdcritic2 INTEGER := 0;
    vr_dscritic2 VARCHAR2(4000);
  
    --Variaveis de Excecao
    vr_exc_final   EXCEPTION;
    vr_exc_saida   EXCEPTION;
    vr_exc_fimprg  EXCEPTION;
    vr_exc_saida_2 EXCEPTION;
  
    --Variaveis utilizadas nos indices
    vr_index_desc     VARCHAR2(20);
    vr_index_titulo   VARCHAR2(20);
    vr_index_erro     PLS_INTEGER;
    vr_index_crapcco  VARCHAR2(20);
    vr_index_conv_arq VARCHAR2(20);
    vr_index_rel618   NUMBER(15);
    vr_index_rel706   NUMBER(15);
    vr_index_comando  NUMBER(15);
    vr_index_crapmot  VARCHAR2(17);
    vr_index_cratrej  VARCHAR2(20);
    vr_index_cratlcm  VARCHAR2(60);
    -- Variavel para armazenar as informacoes em XML
    vr_des_xml CLOB;
    vr_dstexto VARCHAR2(32700);
    --Variaveis de Arquivo
    vr_input_file utl_file.file_type;
  
    --Variaveis relatorios
    vr_cdbanpag NUMBER(05);
    vr_dsbanage VARCHAR2(100);
    vr_dscodbar VARCHAR2(100);
    vr_nrcpfcnj NUMBER;
    vr_nmsacado VARCHAR2(100);
    vr_vljurmul NUMBER;
    vr_vlrpagto NUMBER;
    vr_vlrdifer NUMBER;
  
    vr_aux_cdocorre NUMBER;
  
    vr_fgdevpro VARCHAR2(01):= 'N';
  
    FUNCTION fn_buscar_param(pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_cdacesso IN VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
      RETURN tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                       ,pr_nmsistem => 'CRED'
                                       ,pr_tptabela => 'GENERI'
                                       ,pr_cdempres => 0
                                       ,pr_cdacesso => pr_cdacesso
                                       ,pr_tpregist => 0);
    END fn_buscar_param;
  
    -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483
    --Armazena em tabela workingo em funcao do paralelismo
    PROCEDURE pc_insere_tbgen_batch_rel_wrk(pr_cdcooper    IN tbgen_batch_relatorio_wrk.cdcooper%TYPE
                                           ,pr_CDPROGRAMA  IN tbgen_batch_relatorio_wrk.CDPROGRAMA%TYPE
                                           ,pr_DSRELATORIO IN tbgen_batch_relatorio_wrk.DSRELATORIO%TYPE
                                           ,pr_dtmvtolt    IN tbgen_batch_relatorio_wrk.dtmvtolt%TYPE
                                           ,pr_cdagenci    IN tbgen_batch_relatorio_wrk.cdagenci%TYPE
                                           ,pr_DSCHAVE     IN tbgen_batch_relatorio_wrk.DSCHAVE%TYPE
                                           ,pr_NRDCONTA    IN tbgen_batch_relatorio_wrk.NRDCONTA%TYPE
                                           ,pr_NRCNVCOB    IN tbgen_batch_relatorio_wrk.NRCNVCOB%TYPE
                                           ,pr_NRDOCMTO    IN tbgen_batch_relatorio_wrk.NRDOCMTO%TYPE
                                           ,pr_NRCTREMP    IN tbgen_batch_relatorio_wrk.NRCTREMP%TYPE
                                           ,pr_DSDOCCOP    IN tbgen_batch_relatorio_wrk.DSDOCCOP%TYPE
                                           ,pr_TPPARCEL    IN tbgen_batch_relatorio_wrk.TPPARCEL%TYPE
                                           ,pr_DTVENCTO    IN tbgen_batch_relatorio_wrk.DTVENCTO%TYPE
                                           ,pr_VLTITULO    IN tbgen_batch_relatorio_wrk.VLTITULO%TYPE
                                           ,pr_VLDPAGTO    IN tbgen_batch_relatorio_wrk.VLDPAGTO%TYPE
                                           ,pr_DSXML       IN tbgen_batch_relatorio_wrk.DSXML%TYPE
                                           ,pr_dscrient    IN tbgen_batch_relatorio_wrk.dscritic%TYPE
                                           ,pr_cdcrisai    OUT INTEGER
                                           ,pr_dscrisai    OUT VARCHAR2) IS
    
    BEGIN
    
      BEGIN
        -- Inclusao do nome do modulo logado - 15/03/2018 - Chamado 801483
        GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra ||
                                            '.pc_insere_tbgen_batch_rel_wrk'
                              ,pr_action => NULL);
        --Inicializa retorno
        pr_cdcrisai := NULL;
        pr_dscrisai := NULL;
        -- criar registro de lote na tabela Wrk
        INSERT INTO tbgen_batch_relatorio_wrk
          (CDCOOPER
          ,CDPROGRAMA
          ,DSRELATORIO
          ,DTMVTOLT
          ,CDAGENCI
          ,DSCHAVE
          ,NRDCONTA
          ,NRCNVCOB
          ,NRDOCMTO
          ,NRCTREMP
          ,DSDOCCOP
          ,TPPARCEL
          ,DTVENCTO
          ,VLTITULO
          ,VLDPAGTO
          ,DSCRITIC
          ,DSXML)
        VALUES
          (pr_CDCOOPER
          ,pr_CDPROGRAMA
          ,pr_DSRELATORIO
          ,pr_DTMVTOLT
          ,pr_CDAGENCI
          ,pr_DSCHAVE
          ,pr_NRDCONTA
          ,pr_NRCNVCOB
          ,pr_NRDOCMTO
          ,pr_NRCTREMP
          ,pr_DSDOCCOP
          ,pr_TPPARCEL
          ,pr_DTVENCTO
          ,pr_VLTITULO
          ,pr_VLDPAGTO
          ,pr_dscrient
          ,pr_DSXML);
      
        -- Inclusao do nome do modulo logado - 15/03/2018 - Chamado 801483
        GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
      
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 15/03/2018 - Chamado 801483
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          -- se ocorreu algum erro durante a criacao
          -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483 
          pr_cdcrisai := 1034;
          pr_dscrisai := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcrisai) ||
                         ' tbgen_batch_rel_wrk(1):' || ' cdcooper:' || pr_cdcooper ||
                         ', cdprograma:' || pr_cdprograma || ', dsrelatorio:' || pr_dsrelatorio ||
                         ', dtmvtolt:' || pr_dtmvtolt || ', cdagenci:' || pr_cdagenci ||
                         ', dschaver:' || pr_dschave || ', nrdconta:' || pr_nrdconta ||
                         ', nrcnvcob:' || pr_nrcnvcob || ', nrdocmto:' || pr_nrdocmto ||
                         ', nrctremp:' || pr_nrctremp || ', dsdoccop:' || pr_dsdoccop ||
                         ', tpparcelo:' || pr_tpparcel || ', dtvencto:' || pr_dtvencto ||
                         ', vltitulo:' || pr_vltitulo || ', vldpagto:' || pr_vldpagto ||
                         ', dscritic:' || pr_dscrient || '. ' || SQLERRM;
          ROLLBACK;
      END;
    END pc_insere_tbgen_batch_rel_wrk;
  
    -- Excluido pc_verifica_vencto_titulo - 15/03/2018 - Chamado 801483  
  
    PROCEDURE pc_verifica_vencto(pr_cdcooper IN INTEGER --Codigo da cooperativa
                                ,pr_dtmvtolt IN DATE --Data para verificacao
                                ,pr_cddbanco IN INTEGER --Codigo do Banco
                                ,pr_cdagenci IN INTEGER --Codigo da Agencia
                                ,pr_dtboleto IN DATE --Data do Titulo
                                ,pr_flgvenci OUT BOOLEAN --Indicador titulo vencido
                                ,pr_cdcritic OUT INTEGER --Codigo do erro
                                ,pr_dscritic OUT VARCHAR2) IS --Descricao do erro
      ---------------------------------------------------------------------------------------------------------------
      -- Objetivo  : Procedure para verificar se a data de pagto do titulo eh feriado
      --             em funcao do banco/agencia do local de pagamento
      ---------------------------------------------------------------------------------------------------------------
    BEGIN
      DECLARE
        --Cursores Locais
      
        /* Busca dos dados da cooperativa */
        CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
          SELECT crapcop.cdcooper
                ,crapcop.nmrescop
                ,crapcop.nmextcop
                ,crapcop.nrtelura
                ,crapcop.dsdircop
                ,crapcop.cdbcoctl
                ,crapcop.cdagectl
                ,crapcop.flgoppag
                ,crapcop.flgopstr
                ,crapcop.inioppag
                ,crapcop.fimoppag
                ,crapcop.iniopstr
                ,crapcop.fimopstr
            FROM crapcop
           WHERE crapcop.cdcooper = pr_cdcooper;
        rw_crapcop cr_crapcop%ROWTYPE;
      
        --Selecionar informacoes dos bancos
        CURSOR cr_crapban(pr_cdbccxlt IN crapban.cdbccxlt%TYPE) IS
          SELECT crapban.nmresbcc
                ,crapban.nmextbcc
                ,crapban.cdbccxlt
            FROM crapban
           WHERE crapban.cdbccxlt = pr_cdbccxlt;
        rw_crapban cr_crapban%ROWTYPE;
      
        --Selecionar Informacoes das Agencias
        CURSOR cr_crapagb(pr_cddbanco IN crapagb.cddbanco%TYPE
                         ,pr_cdageban IN crapage.cdagepac%TYPE) IS
          SELECT crapagb.cddbanco
                ,crapagb.cdcidade
                ,crapagb.cdsitagb
            FROM crapagb
           WHERE crapagb.cddbanco = pr_cddbanco
             AND crapagb.cdageban = pr_cdageban;
        rw_crapagb cr_crapagb%ROWTYPE;
      
        /* Verifica a cidade da agencia */
        CURSOR cr_crapcaf(pr_cdcidade IN crapagb.cdcidade%TYPE) IS
          SELECT crapcaf.cdcidade
            FROM crapcaf
           WHERE crapcaf.cdcidade = pr_cdcidade;
        rw_crapcaf cr_crapcaf%ROWTYPE;
      
        --Selecionar feriados sistema financeiro
        CURSOR cr_crapfsf(pr_cdcidade IN crapfsf.cdcidade%TYPE
                         ,pr_dtferiad IN crapfsf.dtferiad%TYPE) IS
          SELECT crapfsf.dtferiad
            FROM crapfsf
           WHERE crapfsf.cdcidade = pr_cdcidade
             AND crapfsf.dtferiad = pr_dtferiad;
        rw_crapfsf cr_crapfsf%ROWTYPE;
      
        --Variaveis Locais
        vr_proxutil  DATE;
        vr_dtferiado DATE;
        vr_erro_caf  BOOLEAN := FALSE;
      
        --Variaveis de Erro
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic VARCHAR2(4000);
        --Variaveis Excecao
        vr_exc_erro EXCEPTION;
        --Tipo de Dados para cursor cooperativa
      BEGIN
        -- Inclusao do nome do modulo logado - 15/03/2018 - Chamado 801483
        GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra || '.pc_verifica_vencto'
                              ,pr_action => NULL);
      
        --Inicializar variaveis retorno
        pr_cdcritic := NULL;
        pr_dscritic := NULL;
      
        IF pr_dtboleto IS NULL THEN
          -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483 
          --Mensagem erro
          vr_cdcritic := 1127; -- Data de vencimento nao pode ser nulo
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      
        -- busca a maxima data em que o boleto pode ser pago sem ser considerado vencido
        -- considerando somente feriados nacionais e último dia útil do ano (SD#824706)
        vr_proxutil := npcb0001.fn_titulo_vencimento_pagamento(pr_cdcooper => pr_cdcooper
                                                              ,pr_dtvencto => pr_dtboleto);
        -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
        GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
        --Flag vencida
        pr_flgvenci := FALSE;
      
        /* Verifica a cooperativa */
        OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
        FETCH cr_crapcop
          INTO rw_crapcop;
        --Se nao encontrou
        IF cr_crapcop%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapcop;
          vr_erro_caf := TRUE;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapcop;
      
        /* Busca o registro do banco */
        OPEN cr_crapban(pr_cdbccxlt => pr_cddbanco);
        --Posicionar no proximo registro
        FETCH cr_crapban
          INTO rw_crapban;
      
        IF cr_crapban%NOTFOUND THEN
          vr_erro_caf := TRUE;
        END IF;
      
        --Fechar Cursor
        CLOSE cr_crapban;
      
        IF NOT vr_erro_caf THEN
          --Selecionar Agencias
          OPEN cr_crapagb(pr_cddbanco => rw_crapban.cdbccxlt, pr_cdageban => pr_cdagenci);
          --Posicionar no primeiro registro
          FETCH cr_crapagb
            INTO rw_crapagb;
        
          IF cr_crapagb%NOTFOUND THEN
            --Fechar Cursor
            vr_erro_caf := TRUE;
          END IF;
        
          --Fechar Cursor
          CLOSE cr_crapagb;
        END IF;
      
        IF NOT vr_erro_caf THEN
          /* Verifica a cidade da agencia */
          OPEN cr_crapcaf(pr_cdcidade => rw_crapagb.cdcidade);
          --Posicionar no proximo registro
          FETCH cr_crapcaf
            INTO rw_crapcaf;
        
          --Se nao encontrar
          IF cr_crapcaf%NOTFOUND THEN
            vr_erro_caf := TRUE;
          END IF;
        
          --Fechar Cursor
          CLOSE cr_crapcaf;
        END IF;
      
        --Loop procurando por feriados
        WHILE TRUE
        LOOP
          --Verificar se o dia eh feriado
          vr_dtferiado := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                     ,pr_dtmvtolt => vr_proxutil
                                                     ,pr_tipo     => 'P');
          -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
          GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
          IF NOT vr_erro_caf THEN
            --Selecionar feriados sistema financeiro
            OPEN cr_crapfsf(pr_cdcidade => rw_crapcaf.cdcidade, pr_dtferiad => vr_dtferiado);
            --Posicionar no proximo registro
            FETCH cr_crapfsf
              INTO rw_crapfsf;
            --Se nao encontrar
            IF cr_crapfsf%FOUND THEN
              --Vencida recebe false
              vr_proxutil := vr_proxutil + 1;
            ELSE
              EXIT;
            END IF;
            --Fechar Cursor
            CLOSE cr_crapfsf;
          ELSE
            EXIT;
          END IF;
        END LOOP;
      
        --Se a data do vencimento maior ou igual a data de movimento
        IF vr_dtferiado >= pr_dtmvtolt THEN
          pr_flgvenci := FALSE;
        ELSE
          --Vencida recebe true
          pr_flgvenci := TRUE;
        END IF;
      
        -- Inclusao do nome do modulo logado - 15/03/2018 - Chamado 801483
        GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
      
      EXCEPTION
        -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483  
        WHEN vr_exc_erro THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic || ' pr_cdcooper:' || pr_cdcooper || ', pr_dtmvtolt:' ||
                         pr_dtmvtolt || ', pr_cddbanco:' || pr_cddbanco || ', pr_dtboleto:' ||
                         TRUNC(pr_dtboleto);
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          pr_cdcritic := 9999;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                         'CRPS538.pc_verifica_vencto' || '. ' || SQLERRM || '. pr_cdcooper:' ||
                         pr_cdcooper || ', pr_dtmvtolt:' || pr_dtmvtolt || ', pr_cddbanco:' ||
                         pr_cddbanco || ', pr_dtboleto:' || TRUNC(pr_dtboleto);
      END;
    END pc_verifica_vencto;
  
    -- Retirada a rotina fn_lista_motivos e criado um novo programa para contempla-lá
    -- Chamado 714566 - 11/08/2017 
  
    -- Retirada a rotina pc_gera_relatorio_686 e criado um novo programa para contempla-lá
    -- Chamado 714566 - 11/08/2017  
  
    -- Retirada a rotina pc_gera_relatorio_574 e criado um novo programa para contempla-lá
    -- Chamado 714566 - 11/08/2017  
  
    -- Retirada a rotina pc_gera_relatorio_605 e criado um novo programa para contempla-lá
    -- Chamado 714566 - 11/08/2017  
  
    --Gerar Relatorio 618
    PROCEDURE pc_gera_relatorio_618(pr_cdcooper IN crapcop.cdcooper%TYPE
                                   ,pr_dtmvtolt IN DATE
                                   ,pr_cdcritic OUT INTEGER
                                   ,pr_dscritic OUT VARCHAR2) IS
      vr_cdbanpag_qbr NUMBER(10);
      --Variaveis Excecao  - 15/03/2018 - Chamado 801483
      vr_exc_erro EXCEPTION;
    BEGIN
      -- Inclusao do nome do modulo logado - 15/03/2018 - Chamado 801483
      GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra || '.pc_gera_relatorio_618'
                            ,pr_action => NULL);
      --Inicializar variaveis erro
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
    
      --Inicializa controle de queque do arquivo de relatório
      vr_cdbanpag_qbr := 0;
    
      --Percorrer toda a tabela do relatório
      vr_index_rel618 := 0;
      FOR rw_crap618 IN cr_crap618(pr_cdcooper    => pr_cdcooper
                                  ,pr_dtmvtolt    => pr_dtmvtolt
                                  ,pr_cdprograma  => ct_cdprogra
                                  ,pr_dsrelatorio => 'REL618')
      LOOP
      
        -- Proximo indice
        vr_index_rel618 := vr_index_rel618 + 1;
      
        -- Campos da tabela de trabalho
        vr_cdbanpag := rw_crap618.cdbanpag;
        vr_dsbanage := rw_crap618.dsbanage;
        vr_nrcpfcnj := rw_crap618.nrcpfcnj;
        vr_nmsacado := rw_crap618.nmsacado;
        vr_dscodbar := rw_crap618.dscodbar;
        vr_vljurmul := rw_crap618.vljurmul;
        vr_vlrpagto := rw_crap618.vlrpagto;
        vr_vlrdifer := rw_crap618.vlrdifer;
        vr_vldescar := rw_crap618.vldescar;
      
        --Finaliza quebra de relatório
        IF vr_cdbanpag_qbr > 0 AND vr_cdbanpag_qbr <> vr_cdbanpag THEN
        
          --Buscar relatorio RL da Cecred
          vr_caminho_rl_3 := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                  ,pr_cdcooper => 3
                                                  ,pr_nmsubdir => 'rl');
          -- Finalizar tag XML
          gene0002.pc_escreve_xml(vr_des_xml, vr_dstexto, '</dados></crrl618>', TRUE);
          -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
          GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
          -- Efetuar solicitacao de geracao de relatorio crrl618 --
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                                     ,pr_cdprogra  => ct_cdprogra --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                     ,pr_dsxml     => vr_des_xml --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/crrl618/dados/dado' --> No base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl618.jasper' --> Arquivo de layout do iReport
                                     ,pr_dsparams  => 'PR_NMORIGEM##' || vr_nmorigem ||
                                                      '@@PR_NMDESTIN##' || vr_nmdestin ||
                                                      '@@PR_DTRELATO##' ||
                                                      to_char(rw_crapdat.dtmvtolt, 'DD/MM/YYYY') --> Campo Origem e Destino no Cabecalho
                                     ,pr_dsarqsaid => vr_caminho_rl || '/' || vr_nmarqimp --> Arquivo final
                                     ,pr_qtcoluna  => 234 --> 234 colunas
                                     ,pr_sqcabrel  => 1 --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                     ,pr_cdrelato  => 618 --> Codigo do Relatorio
                                     ,pr_flg_impri => 'S' --> Chamar a impress?o (Imprim.p)
                                     ,pr_nmformul  => '234dh' --> Nome do formul?rio para impress?o
                                     ,pr_nrcopias  => 1 --> N?mero de c?pias
                                     ,pr_flg_gerar => 'N' --> gerar PDF
                                     ,pr_dspathcop => vr_caminho_rl_3 --> Lista sep. por ';' de diretórios a copiar o relatório
                                     ,pr_des_erro  => vr_dscritic); --> Sa?da com erro
          -- Testar se houve erro
          IF vr_dscritic IS NOT NULL THEN
            --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
            vr_cdcritic := 1197;
            vr_dscritic := vr_dscritic || ' - gene0002.pc_solicita_relato';
            -- Gerar excecao
            RAISE vr_exc_erro;
          END IF;
          -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
          GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
          -- Liberando a memoria alocada pro CLOB
          dbms_lob.close(vr_des_xml);
          dbms_lob.freetemporary(vr_des_xml);
          vr_dstexto := NULL;
        END IF;
      
        -- Inicializa primeira quebra
        IF vr_cdbanpag_qbr = 0 THEN
          vr_cdbanpag_qbr := rw_crap618.cdbanpag;
        END IF;
      
        -- Gera quebra de relatorio
        IF vr_index_rel618 = 1 OR vr_cdbanpag_qbr <> vr_cdbanpag THEN
        
          -- Controle de quebra
          vr_cdbanpag_qbr := vr_cdbanpag;
        
          -- Inicializar o CLOB
          dbms_lob.createtemporary(vr_des_xml, TRUE);
          dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
          vr_dstexto := NULL;
          -- Quando for REPROC deve montar o nome do arquivo de forma diferenciada, 
          -- para evitar sobrepor arquivos de outras execuções
          IF vr_inreproc THEN
            -- Nome arquivo impressao
            vr_nmarqimp := 'crrl618_' || rw_crapcop.dsdircop || '_' ||
                           gene0002.fn_mask(vr_cdbanpag, '999') || '_REP_' ||
                           GENE0002.fn_busca_time || '.lst';
          ELSE
            --Nome arquivo Impressao
            vr_nmarqimp := 'crrl618_' || rw_crapcop.dsdircop || '_' ||
                           LTRIM(gene0002.fn_mask(vr_cdbanpag, '999')) || '.lst';
          END IF;
          --Descricao da Origem
          vr_nmorigem := gene0002.fn_mask(rw_crapcop.cdbcoctl, '999') || ' - ' ||
                         rw_crapcop.nmrescop || ' - AGENCIA: ' ||
                         gene0002.fn_mask(rw_crapcop.cdagectl, '9999');
          -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
          GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
          --Descricao do Destino
          vr_nmdestin := 'COBRANCA';
          --Selecionar Bancos
          OPEN cr_crapban(pr_cdbccxlt => vr_cdbanpag); --(cddbanco);
          FETCH cr_crapban
            INTO vr_nmdestin;
          CLOSE cr_crapban;
          -- Inicilizar as informacoes do XML
          gene0002.pc_escreve_xml(vr_des_xml
                                 ,vr_dstexto
                                 ,'<?xml version="1.0" encoding="utf-8"?><crrl618><dados>');
        END IF;
      
        --Montar tag saldo contabil para arquivo XML
        gene0002.pc_escreve_xml(vr_des_xml
                               ,vr_dstexto
                               ,'<dado>
                  <bancoage>' || vr_dsbanage ||
                                '</bancoage>
                  <nrcpfcnj>' ||
                                gene0002.fn_mask(vr_nrcpfcnj, 'zzzzzzzzzzzzzz9') ||
                                '</nrcpfcnj>
                  <nmsacado>' ||
                                gene0007.fn_caract_controle(substr(vr_nmsacado, 1, 30)) ||
                                '</nmsacado>
                  <dscodbar>' || substr(vr_dscodbar, 1, 43) ||
                                '</dscodbar>
                  <nrdocmto>' ||
                                LTRIM(substr(rw_crap618.dsdoccop, 1, 15)) ||
                                '</nrdocmto>
                  <dtvencto>' ||
                                to_char(rw_crap618.dtvencto, 'DD/MM/YY') ||
                                '</dtvencto>
                  <vldocmto>' ||
                                to_char(rw_crap618.vltitulo, 'fm999g999g999g990d00') ||
                                '</vldocmto>
                  <vldesaba>' ||
                                to_char(rw_crap618.vldpagto, 'fm999g999g990d00') ||
                                '</vldesaba>
                  <vljurmul>' ||
                                to_char(vr_vljurmul, 'fm999g999g990d00') ||
                                '</vljurmul>
                  <vlrpagto>' ||
                                to_char(vr_vlrpagto, 'fm999g999g990d00') ||
                                '</vlrpagto>
                  <vlrdifer>' ||
                                to_char(vr_vlrdifer, 'fm999g999g990d00') ||
                                '</vlrdifer>
                  <vldescar>' ||
                                to_char(vr_vldescar, 'fm999g999g990d00') || '</vldescar>
               </dado>');
        -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
        GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
      END LOOP;
    
      --Ultimo registro do banco
      IF vr_index_rel618 > 0 THEN
        --Buscar relatorio RL da Cecred
        vr_caminho_rl_3 := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                ,pr_cdcooper => 3
                                                ,pr_nmsubdir => 'rl');
        -- Finalizar tag XML
        gene0002.pc_escreve_xml(vr_des_xml, vr_dstexto, '</dados></crrl618>', TRUE);
        -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
        GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
        -- Efetuar solicitacao de geracao de relatorio crrl618 --
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                                   ,pr_cdprogra  => ct_cdprogra --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                   ,pr_dsxml     => vr_des_xml --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/crrl618/dados/dado' --> No base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl618.jasper' --> Arquivo de layout do iReport
                                   ,pr_dsparams  => 'PR_NMORIGEM##' || vr_nmorigem ||
                                                    '@@PR_NMDESTIN##' || vr_nmdestin ||
                                                    '@@PR_DTRELATO##' ||
                                                    to_char(rw_crapdat.dtmvtolt, 'DD/MM/YYYY') --> Campo Origem e Destino no Cabecalho
                                   ,pr_dsarqsaid => vr_caminho_rl || '/' || vr_nmarqimp --> Arquivo final
                                   ,pr_qtcoluna  => 234 --> 234 colunas
                                   ,pr_sqcabrel  => 1 --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                   ,pr_cdrelato  => 618 --> Codigo do Relatorio
                                   ,pr_flg_impri => 'S' --> Chamar a impress?o (Imprim.p)
                                   ,pr_nmformul  => '234dh' --> Nome do formul?rio para impress?o
                                   ,pr_nrcopias  => 1 --> N?mero de c?pias
                                   ,pr_flg_gerar => 'N' --> gerar PDF
                                   ,pr_dspathcop => vr_caminho_rl_3 --> Lista sep. por ';' de diretórios a copiar o relatório
                                   ,pr_des_erro  => vr_dscritic); --> Sa?da com erro
        -- Testar se houve erro
        IF vr_dscritic IS NOT NULL THEN
          --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
          vr_cdcritic := 1197;
          vr_dscritic := vr_dscritic || ' - gene0002.pc_solicita_relato(2)';
          -- Gerar excecao
          RAISE vr_exc_erro;
        END IF;
        -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
        GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
        -- Liberando a memoria alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
        vr_dstexto := NULL;
      END IF;
    
    EXCEPTION
      -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483  
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic || ' pr_cdcooper:' || pr_cdcooper || ', pr_dtmvtolt:' ||
                       pr_dtmvtolt || ', pc_gera_relatorio_618';
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
        --Variavel de erro recebe critica ocorrida
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                       'CRPS538.pc_gera_relatorio_618' || '. ' || SQLERRM || '. pr_cdcooper:' ||
                       pr_cdcooper || ', pr_dtmvtolt:' || pr_dtmvtolt;
    END pc_gera_relatorio_618;
  
    -- Gerar Relatorio 706 - Pagto de Contrato com Boleto
    PROCEDURE pc_gera_relatorio_706(pr_cdcooper IN crapcop.cdcooper%TYPE
                                   ,pr_dtmvtolt IN DATE
                                   ,pr_cdcritic OUT INTEGER
                                   ,pr_dscritic OUT VARCHAR2) IS
      --Variaveis Excecao  - 15/03/2018 - Chamado 801483
      vr_exc_erro EXCEPTION;
    BEGIN
      -- Inclusao do nome do modulo logado - 15/03/2018 - Chamado 801483
      GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra || '.pc_gera_relatorio_706'
                            ,pr_action => NULL);
      --Inicializar variaveis erro
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
    
      --Percorrer toda a tabela do relatório
      vr_index_rel706 := 0;
      FOR rw_crap706 IN cr_crap706(pr_cdcooper    => pr_cdcooper
                                  ,pr_dtmvtolt    => pr_dtmvtolt
                                  ,pr_cdprograma  => ct_cdprogra
                                  ,pr_dsrelatorio => 'REL706')
      LOOP
      
        vr_index_rel706 := vr_index_rel706 + 1;
      
        --Primeiro registro do banco
        IF vr_index_rel706 = 1 THEN
        
          -- Inicializar o CLOB
          dbms_lob.createtemporary(vr_des_xml, TRUE);
          dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
          vr_dstexto := NULL;
        
          -- Quando for REPROC deve montar o nome do arquivo de forma diferenciada, 
          -- para evitar sobrepor arquivos de outras execuções
          IF vr_inreproc THEN
            -- Nome arquivo impressao
            vr_nmarqimp := 'crrl706_REP_' || GENE0002.fn_busca_time || '.lst';
          ELSE
            -- Nome arquivo Impressao
            vr_nmarqimp := 'crrl706.lst';
          END IF;
        
          --Descricao da Origem
          vr_nmorigem := '';
        
          --Descricao do Destino
          vr_nmdestin := 'CREDITO';
        
          -- Inicilizar as informacoes do XML
          gene0002.pc_escreve_xml(vr_des_xml
                                 ,vr_dstexto
                                 ,'<?xml version="1.0" encoding="utf-8"?><crrl706>');
        END IF;
      
        --Montar tag saldo contabil para arquivo XML
        gene0002.pc_escreve_xml(vr_des_xml
                               ,vr_dstexto
                               ,'<dados>
                  <cdagenci>' || rw_crap706.cdagenci ||
                                '</cdagenci>
                  <nrdconta>' || rw_crap706.nrdconta ||
                                '</nrdconta>
                  <nrcnvcob>' || rw_crap706.nrcnvcob ||
                                '</nrcnvcob>
                  <nrdocmto>' || rw_crap706.nrdocmto ||
                                '</nrdocmto>
                  <nrctremp>' || rw_crap706.nrctremp ||
                                '</nrctremp>
                  <tpparepr>' || CASE rw_crap706.tpparcel WHEN 1 THEN
                                'NORMAL' WHEN 2 THEN 'ATRASO' WHEN 3 THEN 'PARCIAL' WHEN 4 THEN
                                'QUITACAO' END || '</tpparepr>
                  <dtvencto>' ||
                                to_char(rw_crap706.dtvencto, 'DD/MM/YY') ||
                                '</dtvencto>
                  <vltitulo>' ||
                                to_char(rw_crap706.vltitulo, 'fm999g999g999g990d00') ||
                                '</vltitulo>
                  <vldpagto>' ||
                                to_char(rw_crap706.vldpagto, 'fm999g999g990d00') ||
                                '</vldpagto>
                  <dscritic>' || rw_crap706.dscritic ||
                                '</dscritic>
               </dados>');
      END LOOP;
      -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
      GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
    
      --Ultimo registro
      IF vr_index_rel706 > 0 THEN
      
        -- Finalizar tag XML
        gene0002.pc_escreve_xml(vr_des_xml, vr_dstexto, '</crrl706>', TRUE);
        -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
        GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
      
        -- Efetuar solicitacao de geracao de relatorio crrl706 --
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper --> Cooperativa conectada
                                   ,pr_cdprogra  => ct_cdprogra --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                   ,pr_dsxml     => vr_des_xml --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/crrl706/dados' --> No base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl706.jasper' --> Arquivo de layout do iReport
                                   ,pr_dsparams  => NULL -- 'PR_NMORIGEM##'||vr_nmorigem||'@@PR_NMDESTIN##'||vr_nmdestin||'@@PR_DTRELATO##'||to_char(rw_crapdat.dtmvtolt,'DD/MM/YYYY')  --> Campo Origem e Destino no Cabecalho
                                   ,pr_dsarqsaid => vr_caminho_rl || '/' || vr_nmarqimp --> Arquivo final
                                   ,pr_qtcoluna  => 132 --> 234 colunas
                                   ,pr_sqcabrel  => 1 --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                   ,pr_cdrelato  => 706 --> Codigo do Relatorio
                                   ,pr_flg_impri => 'S' --> Chamar a impress?o (Imprim.p)
                                   ,pr_nmformul  => '132col' --> Nome do formul?rio para impress?o
                                   ,pr_nrcopias  => 1 --> N?mero de c?pias
                                   ,pr_flg_gerar => 'N' --> gerar PDF
                                   ,pr_des_erro  => vr_dscritic); --> Saida com erro
        -- Testar se houve erro
        IF vr_dscritic IS NOT NULL THEN
          --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
          vr_cdcritic := 1197;
          vr_dscritic := vr_dscritic || ' - gene0002.pc_solicita_relato';
          -- Gerar excecao
          RAISE vr_exc_erro;
        END IF;
        -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
        GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
      
        -- Liberando a memoria alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
        vr_dstexto := NULL;
      END IF;
    
    EXCEPTION
      -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483  
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic || ' pr_cdcooper:' || pr_cdcooper || ', pr_dtmvtolt:' ||
                       pr_dtmvtolt || ', pc_gera_relatorio_706';
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
        -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483 
        --Variavel de erro recebe critica ocorrida
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                       'CRPS538.pc_gera_relatorio_706' || '. ' || SQLERRM || '. pr_cdcooper:' ||
                       pr_cdcooper || ', pr_dtmvtolt:' || pr_dtmvtolt;
    END pc_gera_relatorio_706;
  
    -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483 
    --> Procedimento para grava registro de devolucao
    PROCEDURE pc_grava_devolucao(pr_cdcooper IN tbcobran_devolucao.cdcooper%TYPE --> codigo da cooperativa
                                ,pr_dtmvtolt IN tbcobran_devolucao.dtmvtolt%TYPE --> data do movimento
                                ,pr_dtmvtopr IN tbcobran_devolucao.dtmvtolt%TYPE --> data do próximo movimento 
                                ,pr_nrseqarq IN tbcobran_devolucao.nrseqarq%TYPE --> numero sequencial do arquivo da devolucao (cob615)
                                ,pr_dscodbar IN tbcobran_devolucao.dscodbar%TYPE --> codigo de barras
                                ,pr_nrispbif IN tbcobran_devolucao.nrispbif%TYPE --> numero do ispb recebedora
                                ,pr_vlliquid IN tbcobran_devolucao.vlliquid%TYPE --> valor de liquidacao do titulo
                                ,pr_dtocorre IN tbcobran_devolucao.dtocorre%TYPE --> data da ocorrencia da devolucao
                                ,pr_nrdconta IN tbcobran_devolucao.nrdconta%TYPE --> numero da conta do cooperado
                                ,pr_nrcnvcob IN tbcobran_devolucao.nrcnvcob%TYPE --> numero do convenio de cobranca do cooperado
                                ,pr_nrdocmto IN tbcobran_devolucao.nrdocmto%TYPE --> numero do boleto de cobranca
                                ,pr_cdmotdev IN tbcobran_devolucao.cdmotdev%TYPE --> codigo do motivo da devolucao
                                ,pr_tpcaptur IN tbcobran_devolucao.tpcaptura%TYPE --> tipo de captura (cob615)
                                ,pr_tpdocmto IN tbcobran_devolucao.tpdocmto%TYPE --> codigo do tipo de documento (cob615)
                                ,pr_cdagerem IN tbcobran_devolucao.cdagerem%TYPE --> codigo da agencia do remetente (cob615)
                                ,pr_dslinarq IN tbcobran_devolucao.dslinarq%TYPE --> 
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                ,pr_dscritic OUT VARCHAR2) IS
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      -- Inclusao do nome do modulo logado - 15/03/2018 - Chamado 801483
      GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra || '.pc_grava_devolucao'
                            ,pr_action => NULL);
      BEGIN
        INSERT INTO tbcobran_devolucao
          (cdcooper
          ,dtmvtolt
          ,nrseqarq
          ,dscodbar
          ,nrispbif
          ,vlliquid
          ,dtocorre
          ,nrdconta
          ,nrcnvcob
          ,nrdocmto
          ,cdmotdev
          ,tpcaptura
          ,tpdocmto
          ,cdagerem
          ,dslinarq
          ,flgenvia)
        VALUES
          (pr_cdcooper
          , --> cdcooper
           pr_dtmvtolt
          , --> dtmvtolt
           pr_nrseqarq
          , --> nrseqarq
           pr_dscodbar
          , --> dscodbar
           pr_nrispbif
          , --> nrispbif
           pr_vlliquid
          , --> vlliquid
           pr_dtocorre
          , --> dtocorre
           pr_nrdconta
          , --> nrdconta
           pr_nrcnvcob
          , --> nrcnvcob
           pr_nrdocmto
          , --> nrdocmto
           pr_cdmotdev
          , --> cdmotdev
           pr_tpcaptur
          , --> tpcaptur
           pr_tpdocmto
          , --> tpdocmto
           pr_cdagerem
          , --> cdagerem
           pr_dslinarq
          , --> dslinarq
           0); --> flgenvia          
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          vr_cdcritic := 1034;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         ' tbcobran_devolucao(2):' || ' cdcooper:' || pr_cdcooper || ', dtmvtolt:' ||
                         pr_dtmvtolt || ', nrseqarq:' || pr_nrseqarq || ', dscodbar:' ||
                         pr_dscodbar || ', nrispbif:' || pr_nrispbif || ', vlliquid:' ||
                         pr_vlliquid || ', dtocorre:' || pr_dtocorre || ', nrdconta:' ||
                         pr_nrdconta || ', nrcnvcob:' || pr_nrcnvcob || ', nrdocmto:' ||
                         pr_nrdocmto || ', cdmotdev:' || pr_cdmotdev || ', tpcaptur:' ||
                         pr_tpcaptur || ', tpdocmto:' || pr_tpdocmto || ', cdagerem:' ||
                         pr_cdagerem || ', dslinarq:' || pr_dslinarq || ', flgenvia:' || '0' || '. ' ||
                         SQLERRM;
          RAISE vr_exc_erro;
      END;
    
      BEGIN
        INSERT INTO gncpdvc
          (cdcooper
          ,dtmvtolt
          ,nmarquiv
          ,nrseqarq
          ,dscodbar
          ,nrispbif
          ,vlliquid
          ,dtocorre
          ,nrdconta
          ,nrcnvcob
          ,nrdocmto
          ,cdmotdev
          ,tpcaptura
          ,tpdocmto
          ,cdagerem
          ,flgconci
          ,flgpcctl
          ,dslinarq)
        VALUES
          (pr_cdcooper -- cdcooper
          ,pr_dtmvtopr -- dtmvtolt  -> PRÓXIMO MOVIMENTO <-
          ,' ' -- nmarquiv
          ,pr_nrseqarq -- nrseqarq
          ,pr_dscodbar -- dscodbar
          ,pr_nrispbif -- nrispbif
          ,pr_vlliquid -- vlliquid
          ,pr_dtocorre -- dtocorre
          ,pr_nrdconta -- nrdconta
          ,pr_nrcnvcob -- nrcnvcob
          ,pr_nrdocmto -- nrdocmto
          ,pr_cdmotdev -- cdmotdev
          ,pr_tpcaptur -- tpcaptura
          ,pr_tpdocmto -- tpdocmto
          ,pr_cdagerem -- cdagerem
          ,0 -- flgconci
          ,0 -- flgpcctl
          ,NULL); -- dslinarq         
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          vr_cdcritic := 1034;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' gncpdvc(3):' ||
                         ' cdcooper:' || pr_cdcooper || ', dtmvtolt:' || pr_dtmvtopr ||
                         ', nmarquiv:' || ' ' || ', nrseqarq:' || pr_nrseqarq || ', dscodbar:' ||
                         pr_dscodbar || ', nrispbif:' || pr_nrispbif || ', vlliquid:' ||
                         pr_vlliquid || ', dtocorre:' || pr_dtocorre || ', nrdconta:' ||
                         pr_nrdconta || ', nrcnvcob:' || pr_nrcnvcob || ', nrdocmto:' ||
                         pr_nrdocmto || ', cdmotdev:' || pr_cdmotdev || ', tpcaptur:' ||
                         pr_tpcaptur || ', tpdocmto:' || pr_tpdocmto || ', cdagerem:' ||
                         pr_cdagerem || ', flgconci:' || '0' || ', flgpcctl:' || '0' ||
                         ', dslinarq:' || 'NULL' || '. ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                       'CRPS538.pc_grava_devolucao' || '. ' || SQLERRM;
    END pc_grava_devolucao;
  
    -- Retirada a rotina pc_gerar_arq_devolucao e criado um novo programa para contempla-lá
    -- Chamado 714566 - 11/08/2017  
  
    --Procedimento para gravar dados na tabela memoria cratrej
    PROCEDURE pc_gera_cratrej(pr_craprej IN craprej%ROWTYPE) IS
      vr_cdcrtica crapcri.cdcritic%TYPE;
    BEGIN
    
      -- Inclusao do nome do modulo logado - 15/03/2018 - Chamado 801483
      GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra || '.pc_gera_cratrej'
                            ,pr_action => NULL);
      BEGIN
        --Retirado em funcao do paralelismo
        --Gravar dados na tabela memoria
        --vr_typ_craprej_array(vr_index_cratrej) := TYP_CRAPREJ()
      
        --Gravar dados na tabela work
        -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483 
        pc_insere_tbgen_batch_rel_wrk(pr_cdcooper    => pr_craprej.cdcooper
                                     ,pr_CDPROGRAMA  => ct_cdprogra
                                     ,pr_DSRELATORIO => 'CRAPREJ'
                                     ,pr_dtmvtolt    => pr_craprej.dtmvtolt
                                     ,pr_cdagenci    => pr_craprej.cdagenci
                                     ,pr_DSCHAVE     => NULL
                                     ,pr_NRDCONTA    => pr_craprej.nrdconta
                                     ,pr_NRCNVCOB    => pr_craprej.nrseqdig
                                     ,pr_NRDOCMTO    => pr_craprej.nrdocmto
                                     ,pr_NRCTREMP    => pr_craprej.cdbccxlt
                                     ,pr_DSDOCCOP    => NULL
                                     ,pr_TPPARCEL    => pr_craprej.cdcritic
                                     ,pr_DTVENCTO    => NULL
                                     ,pr_VLTITULO    => pr_craprej.vllanmto
                                     ,pr_VLDPAGTO    => NULL
                                     ,pr_DSXML       => NULL
                                     ,pr_dscrient    => pr_craprej.cdpesqbb
                                     ,pr_cdcrisai    => vr_cdcrtica
                                     ,pr_dscrisai    => vr_dscritic);
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483  
          vr_cdcritic := 9999;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         'CRPS538.pc_gera_cratrej' || '. ' || SQLERRM;
          -- Excluido RAISE vr_exc_saida - 15/03/2018 - Chamado 801483  
      END;
    END pc_gera_cratrej;
  
    --Procedimento para gravar dados na tabela memoria cratrej
    PROCEDURE pc_carga_cratrej IS
    BEGIN
      -- Refeita procedure - Chamado 714566 - 11/08/2017 
      DECLARE
        vr_index_cratrej NUMBER(20) := 0;
      BEGIN
        -- Inclusao do nome do modulo logado - 15/03/2018 - Chamado 801483
        GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra || '.pc_carga_cratrej'
                              ,pr_action => NULL);
        --Percorrer toda a tabela do relatório
        FOR rw_craprej IN cr_craprej(pr_cdcooper    => pr_cdcooper
                                    ,pr_cdprograma  => ct_cdprogra
                                    ,pr_dsrelatorio => 'CRAPREJ'
                                    ,pr_dtmvtolt    => rw_crapdat.dtmvtolt)
        LOOP
        
          --Montar Indice
          vr_index_cratrej := vr_index_cratrej + 1;
          --Gravar dados na tabela memoria
          vr_typ_craprej_array.EXTEND;
          vr_typ_craprej_array(vr_index_cratrej) := TYP_CRAPREJ(rw_craprej.dtmvtolt
                                                               ,rw_craprej.cdagenci
                                                               ,rw_craprej.vllanmto
                                                               ,rw_craprej.nrseqdig
                                                               ,rw_craprej.cdpesqbb
                                                               ,rw_craprej.cdcritic
                                                               ,rw_craprej.cdcooper
                                                               ,rw_craprej.nrdconta
                                                               ,rw_craprej.cdbccxlt
                                                               ,rw_craprej.nrdocmto);
        END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483 
          --Variavel de erro recebe critica ocorrida
          vr_cdcritic := 9999;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         'CRPS538.pc_carga_cratrej' || '. ' || SQLERRM;
          -- Excluido RAISE vr_exc_saida - 15/03/2018 - Chamado 801483
      END;
    END pc_carga_cratrej;
  
    --Procedimento para gravar dados na tabela banco a partir da tabela memoria tab_lcm_consolidada
    -- A versão em produção recebe esse erros em vr_cdcritic e não joga no pr_cdcritic - 15/03/2018 - Chamado 801483
    PROCEDURE pc_gera_tab_lcm_consolidada(pr_cdcritic            OUT INTEGER --Codigo Critica
                                         ,pr_dscritic            OUT VARCHAR2 --Descricao Critica
                                         ,pr_tab_lcm_consolidada IN PAGA0001.typ_tab_lcm_consolidada) IS
      --Tabela lancamentos consolidada
      vr_dschave2 VARCHAR2(200);
      -- Excecoes - 15/03/2018 - Chamado 801483                   
      vr_exc_erro EXCEPTION;
    BEGIN
      -- Inclusao do nome do modulo logado - 15/03/2018 - Chamado 801483
      GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra || '.pc_gera_tab_lcm_consolidada'
                            ,pr_action => NULL);
      BEGIN
        pr_cdcritic := NULL;
        pr_dscritic := NULL;
      
        -- Ajusta o parametro com a regra de evitar o nulo - 21/03/2019 - REQ0037942
        IF vr_nmtelant = 'COMPEFORA' THEN
          vr_dtmvtaux := rw_crapdat.dtmvtoan;
        ELSE
          vr_dtmvtaux := rw_crapdat.dtmvtolt;
        END IF;
      
        --Percorrer todos os lancamentos
        vr_index_cratlcm := pr_tab_lcm_consolidada.FIRST;
      
        WHILE vr_index_cratlcm IS NOT NULL
        LOOP
        
          --Gravar dados na tabela work
          IF nvl(pr_tab_lcm_consolidada(vr_index_cratlcm).nrctremp, 0) > 0 THEN
            vr_dschave2 := LPad(pr_tab_lcm_consolidada(vr_index_cratlcm).cdcooper, 3, '0') ||
                           LPad(pr_tab_lcm_consolidada(vr_index_cratlcm).nrdconta, 10, '0') ||
                           LPad(pr_tab_lcm_consolidada(vr_index_cratlcm).nrconven, 7, '0') ||
                           LPad(pr_tab_lcm_consolidada(vr_index_cratlcm).cdocorre, 5, '0') ||
                           LPad(pr_tab_lcm_consolidada(vr_index_cratlcm).cdhistor, 5, '0') ||
                           Lpad(pr_tab_lcm_consolidada(vr_index_cratlcm).nrdocmto, 10);
          ELSE
            vr_dschave2 := LPad(pr_tab_lcm_consolidada(vr_index_cratlcm).cdcooper, 3, '0') ||
                           LPad(pr_tab_lcm_consolidada(vr_index_cratlcm).nrdconta, 10, '0') ||
                           LPad(pr_tab_lcm_consolidada(vr_index_cratlcm).nrconven, 7, '0') ||
                           LPad(pr_tab_lcm_consolidada(vr_index_cratlcm).cdocorre, 5, '0') ||
                           LPad(pr_tab_lcm_consolidada(vr_index_cratlcm).cdhistor, 5, '0');
          END IF;
        
          -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483               
          pc_insere_tbgen_batch_rel_wrk(pr_cdcooper    => pr_cdcooper
                                       ,pr_CDPROGRAMA  => ct_cdprogra
                                       ,pr_DSRELATORIO => 'TYP_TAB_LCM_CONSOLIDADA'
                                       ,pr_dtmvtolt    => vr_dtmvtaux
                                       ,pr_cdagenci    => pr_cdagenci
                                       ,pr_DSCHAVE     => vr_dschave2
                                       ,pr_NRDCONTA    => pr_tab_lcm_consolidada(vr_index_cratlcm).nrdconta
                                       ,pr_NRCNVCOB    => pr_tab_lcm_consolidada(vr_index_cratlcm).nrconven
                                       ,pr_NRDOCMTO    => pr_tab_lcm_consolidada(vr_index_cratlcm).nrdocmto
                                       ,pr_NRCTREMP    => pr_tab_lcm_consolidada(vr_index_cratlcm).nrctremp
                                       ,pr_DSDOCCOP    => NULL
                                       ,pr_TPPARCEL    => pr_tab_lcm_consolidada(vr_index_cratlcm).cdocorre
                                       ,pr_DTVENCTO    => NULL
                                       ,pr_VLTITULO    => pr_tab_lcm_consolidada(vr_index_cratlcm).vllancto
                                       ,pr_VLDPAGTO    => NULL
                                       ,pr_DSXML       => TO_CHAR(pr_tab_lcm_consolidada(vr_index_cratlcm).cdhistor
                                                                 ,'fm0000000000') ||
                                                          TO_CHAR(nvl(pr_tab_lcm_consolidada(vr_index_cratlcm).qtdregis
                                                                     ,0)
                                                                 ,'fm000000000000000') ||
                                                          TO_CHAR(nvl(pr_tab_lcm_consolidada(vr_index_cratlcm).cdfvlcop
                                                                     ,0)
                                                                 ,'fm000000000000000') || pr_tab_lcm_consolidada(vr_index_cratlcm).tplancto
                                       ,pr_dscrient    => pr_tab_lcm_consolidada(vr_index_cratlcm).cdpesqbb
                                       ,pr_cdcrisai    => vr_cdcritic
                                       ,pr_dscrisai    => vr_dscritic);
          IF NVL(vr_cdcritic, 0) > 0 THEN
            RAISE vr_exc_erro;
          END IF;
        
          --Buscar proximo registro
          vr_index_cratlcm := pr_tab_lcm_consolidada.NEXT(vr_index_cratlcm);
        END LOOP;
      
      EXCEPTION
        -- Ajuste mensagem - 15/03/2018 - Chamado 801483
        WHEN vr_exc_erro THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 15/03/2018 - Chamado 801483
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          pr_cdcritic := 9999;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                         'CRPS538.pc_gera_tab_lcm_consolidada' || '. ' || SQLERRM;
          -- Excluido RAISE vr_exc_saida - 15/03/2018 - Chamado 801483
      END;
    END pc_gera_tab_lcm_consolidada;
  
    --Procedimento para gravar dados na tabela memoria 
    PROCEDURE pc_carga_tab_lcm_consolidada(pr_cdcritic            OUT INTEGER --Codigo Critica
                                          ,pr_dscritic            OUT VARCHAR2 --Descricao Critica
                                          ,pr_tab_lcm_consolidada IN OUT PAGA0001.typ_tab_lcm_consolidada) IS
    BEGIN
      -- Inclusao do nome do modulo logado - 15/03/2018 - Chamado 801483
      GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra || '.pc_carga_tab_lcm_consolidada'
                            ,pr_action => NULL);
      --Inicializar variaveis retorno
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
    
      -- Ajusta o parametro com a regra de evitar o nulo - 21/03/2019 - REQ0037942
      IF vr_nmtelant = 'COMPEFORA' THEN
        vr_dtmvtaux := rw_crapdat.dtmvtoan;
      ELSE
        vr_dtmvtaux := rw_crapdat.dtmvtolt;
      END IF;
    
      BEGIN
        --Percorrer todos os lancamentos da tabela do working
        FOR rw_lcm_consolidada IN cr_lcm_consolidada(pr_cdcooper    => pr_cdcooper
                                                    ,pr_cdprograma  => ct_cdprogra
                                                    ,pr_dsrelatorio => 'TYP_TAB_LCM_CONSOLIDADA'
                                                    ,pr_dtmvtolt    => vr_dtmvtaux)
        LOOP
        
          --Montar Indice
          IF nvl(rw_lcm_consolidada.nrdocmto, 0) > 0 THEN
            vr_index_cratlcm := LPad(rw_lcm_consolidada.cdcooper, 3, '0') ||
                                LPad(rw_lcm_consolidada.nrdconta, 10, '0') ||
                                LPad(rw_lcm_consolidada.nrconven, 7, '0') ||
                                LPad(rw_lcm_consolidada.cdocorre, 5, '0') ||
                                LPad(rw_lcm_consolidada.cdhistor, 5, '0') ||
                                Lpad(rw_lcm_consolidada.nrdocmto, 10);
          ELSE
            vr_index_cratlcm := LPad(rw_lcm_consolidada.cdcooper, 3, '0') ||
                                LPad(rw_lcm_consolidada.nrdconta, 10, '0') ||
                                LPad(rw_lcm_consolidada.nrconven, 7, '0') ||
                                LPad(rw_lcm_consolidada.cdocorre, 5, '0') ||
                                Lpad(rw_lcm_consolidada.cdhistor, 5, '0');
          END IF;
        
          --Criar registro tabela lancamentos consolidada
          pr_tab_lcm_consolidada(vr_index_cratlcm).cdcooper := rw_lcm_consolidada.cdcooper;
          pr_tab_lcm_consolidada(vr_index_cratlcm).nrdconta := rw_lcm_consolidada.nrdconta;
          pr_tab_lcm_consolidada(vr_index_cratlcm).nrconven := rw_lcm_consolidada.nrconven;
          pr_tab_lcm_consolidada(vr_index_cratlcm).cdocorre := rw_lcm_consolidada.cdocorre;
          pr_tab_lcm_consolidada(vr_index_cratlcm).cdhistor := rw_lcm_consolidada.cdhistor;
          pr_tab_lcm_consolidada(vr_index_cratlcm).tplancto := rw_lcm_consolidada.tplancto;
          pr_tab_lcm_consolidada(vr_index_cratlcm).vllancto := rw_lcm_consolidada.vllancto;
          pr_tab_lcm_consolidada(vr_index_cratlcm).qtdregis := rw_lcm_consolidada.qtdregis;
          pr_tab_lcm_consolidada(vr_index_cratlcm).cdfvlcop := rw_lcm_consolidada.cdfvlcop;
          pr_tab_lcm_consolidada(vr_index_cratlcm).cdpesqbb := rw_lcm_consolidada.cdpesqbb;
          pr_tab_lcm_consolidada(vr_index_cratlcm).nrctremp := rw_lcm_consolidada.nrctremp;
          pr_tab_lcm_consolidada(vr_index_cratlcm).nrdocmto := rw_lcm_consolidada.nrdocmto;
        
        END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          -- Ajuste mensagem - 15/03/2018 - Chamado 801483 
          pr_cdcritic := 9999;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                         'CRPS538.pc_gera_tab_lcm_consolidada' || '. ' || SQLERRM;
          -- Excluido RAISE vr_exc_saida - 15/03/2018 - Chamado 801483
      END;
    END pc_carga_tab_lcm_consolidada;
  
    -------------------------------------------------
    -- Procedimento para Integrar Cobrança Registrada
    -------------------------------------------------
    PROCEDURE pc_integra_cobranca_registrada(pr_cdcritic OUT INTEGER
                                            ,pr_dscritic OUT VARCHAR2) IS
      --
      ct_cdprocedure CONSTANT tbgen_prglog.cdprograma%TYPE := 'pc_integra_cobranca_registrada';
      vr_module_name VARCHAR2(100) := NULL;
      vr_action_name VARCHAR2(100) := NULL;
      --
      --Variaveis Locais
      vr_email_compefora BOOLEAN := FALSE;
      vr_email_proc_cred VARCHAR2(1000);
      --Excecoes
      vr_exc_proximo EXCEPTION;
      vr_exc_saida   EXCEPTION;
      --
      vr_qtde_convenio NUMBER;
      vr_idx_convenio NUMBER;
      --
      CURSOR cr_crapcob_compefora(pr_cdcooper crapcob.cdcooper%TYPE
                                 ,pr_dtcredit crapret.dtcredit%TYPE
                                 ,pr_nrcnvcob crapcob.nrcnvcob%TYPE) IS
        SELECT cob.rowid idrowid_cob
          FROM crapcob cob
              ,crapret ret
              ,(SELECT (SELECT ceb.cdcooper
                          FROM crapceb ceb
                         WHERE ceb.nrconven = to_number(substr(tit.dscodbar, 20, 6))
                           AND ceb.nrdconta = to_number(substr(tit.dscodbar, 26, 8))) cdcooper
                      ,to_number(substr(tit.dscodbar, 20, 6)) nrcnvcob
                      ,to_number(substr(tit.dscodbar, 26, 8)) nrdconta
                      ,to_number(substr(tit.dscodbar, 34, 9)) nrdocmto
                  FROM gncptit tit
                 WHERE tit.cdcooper = pr_cdcooper
                   AND tit.dtmvtolt = vr_dtmvtolt_gncptit
                   AND tit.cdbandst = 85
                   AND tit.nmarquiv = vr_nmarquiv_gncptit) a
         WHERE cob.nrdocmto = a.nrdocmto
           AND cob.nrdconta = a.nrdconta
           AND cob.nrcnvcob = a.nrcnvcob
           AND cob.cdcooper = a.cdcooper
           AND cob.cdcooper = ret.cdcooper
           AND cob.nrdconta = ret.nrdconta
           AND cob.nrcnvcob = ret.nrcnvcob
           AND cob.nrdocmto = ret.nrdocmto
           AND ret.dtcredit = pr_dtcredit
           AND ret.flcredit = 0  -- Lançamento não creditado
           AND ret.cdocorre IN (6,17,76,77)
           AND cob.incobran = 5
           AND cob.cdcooper = pr_cdcooper
           AND cob.nrcnvcob = pr_nrcnvcob;
      --
    BEGIN
      --
      cobr0014.gerarLogInicio(pr_cdcooper      => pr_cdcooper
                             ,pr_cdagenci      => pr_cdagenci
                             ,pr_cdprogra      => 'PC_' || ct_cdprogra
                             ,pr_cdprocedure   => ct_cdprocedure
                             ,pr_idprglog      => vr_idprglog
                             ,pr_dscomplemento => NULL
                             ,pr_module_name   => vr_module_name
                             ,pr_action_name   => vr_action_name);
      --
      BEGIN
        --Inicializar variaveis erro
        pr_cdcritic := NULL;
        pr_dscritic := NULL;
      
        -- Rotina Paralelismo 4A - Processo Principal do JOB ou Sem Paralelismo
        --                       - Processar pc_integra_registro_cobranca
        IF (rw_crapdat.inproces > 2 -- Processo Batch
           AND pr_cdagenci = 0 -- Sem Paralelismo
           AND vr_qtdjobs > 0) -- Paralelismo
           OR (vr_qtdjobs = 0) -- Não Paralelismo
           OR (rw_crapdat.inproces <= 2) THEN
          -- Processo On Line/Agendado
        
          --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
          -- Log Cobranca Processamento 1,2 
          vr_cdcritic := 1201;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         ' - 06 Cobranca 1,2 - ' || pr_cdagenci;
          cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_cdprogra => ct_cdprogra
                                ,pr_idprglog => vr_idprglog
                                ,pr_dstiplog => 'O'
                                ,pr_tpocorre => 4
                                ,pr_dscritic => vr_dscritic
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_cdcricid => 0);
          vr_cdcritic := NULL;
          vr_dscritic := NULL;
        
          /**************************************************************/
          /*************TRATAMENTO P/ COBRANCA REGISTRADA****************/
          --
          vr_qtde_convenio := 0;
          vr_idx_convenio := 0;
          BEGIN
            --
            SELECT COUNT(1) INTO vr_qtde_convenio
              FROM crapcco
             WHERE crapcco.cdcooper = rw_crapcop.cdcooper
               AND crapcco.cddbanco = rw_crapcop.cdbcoctl
               AND crapcco.flgregis = 1;
            --
            pc_log_programa(pr_dstiplog      => 'O' -- Ocorrência
                           ,pr_cdprograma    => vr_cdprogra
                           ,pr_cdcooper      => 3
                           ,pr_tpexecucao    => 0
                           ,pr_tpocorrencia  => 4
                           ,pr_cdcriticidade => 0
                           ,pr_cdmensagem    => 0
                           ,pr_dsmensagem    => '1 - total de convenios: '||LPAD(vr_qtde_convenio,6,0)
                           ,pr_idprglog      => vr_idprglog_principal);
            --
          EXCEPTION
            WHEN OTHERS THEN
              SISTEMA.excecaoInterna('INC0212924');
          END;
          --
        
          -- Ajusta o parametro com a regra de evitar o nulo - 21/03/2019 - REQ0037942
          --Verificar nome da tela
          IF vr_nmtelant = 'COMPEFORA' THEN
            vr_dtmvtaux := rw_crapdat.dtmvtoan;
            --Data Pagamento
            vr_dtdpagto := rw_crapdat.dtmvtoan;
            --Dia Anterior
            vr_dtcredit := rw_crapdat.dtmvtoan;
          ELSE
            vr_dtmvtaux := rw_crapdat.dtmvtolt;
            --Data Pagamento
            vr_dtdpagto := rw_crapdat.dtmvtolt;
            --Data Atual
            vr_dtcredit := rw_crapdat.dtmvtolt;
          END IF;
        
          -- 1o processamento
          vr_cdcritic := 1201;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         ' - 1o processamento - Inicio - ' || pr_cdagenci;
          cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_cdprogra => ct_cdprogra
                                ,pr_idprglog => vr_idprglog
                                ,pr_dstiplog => 'O'
                                ,pr_tpocorre => 4
                                ,pr_dscritic => vr_dscritic
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_cdcricid => 0);
          vr_cdcritic := NULL;
          vr_dscritic := NULL;
          /* Busca todos os convenios da IF CECRED que foram gerados pela internet */
          FOR rw_crapcco IN cr_crapcco_ativo(pr_cdcooper => rw_crapcop.cdcooper
                                            ,pr_cddbanco => rw_crapcop.cdbcoctl)
          LOOP
          
            /************************************************************
             Realizar lançamentos dos creditos do movimento D-0
            *************************************************************/
            --
            BEGIN
              --
              vr_idx_convenio := vr_idx_convenio + 1;
              --
              pc_log_programa(pr_dstiplog      => 'O' -- Ocorrência
                             ,pr_cdprograma    => vr_cdprogra
                             ,pr_cdcooper      => 3
                             ,pr_tpexecucao    => 0
                             ,pr_tpocorrencia  => 4
                             ,pr_cdcriticidade => 0
                             ,pr_cdmensagem    => 0
                             ,pr_dsmensagem    => '1 - idx convenio atual: '||LPAD(vr_idx_convenio,6,0)||'/'||LPAD(vr_qtde_convenio,6,0)
                             ,pr_idprglog      => vr_idprglog_principal);
              --
            EXCEPTION
              WHEN OTHERS THEN
                SISTEMA.excecaoInterna('INC0212924');
            END;
            --
            vr_tab_lcm_consolidada.delete;

            FOR rw_crapcob_compefora IN cr_crapcob_compefora(pr_cdcooper => rw_crapcco.cdcooper
                                                          ,pr_dtcredit => vr_dtcredit
                                                          ,pr_nrcnvcob => rw_crapcco.nrconven) LOOP

              -- Ajusta o parametro com a regra de evitar o nulo - 21/03/2019 - REQ0037942           
              PAGA0001.pc_valores_a_creditar(pr_cdcooper            => rw_crapcco.cdcooper
                                            ,pr_nrcnvcob            => rw_crapcco.nrconven
                                            ,pr_dtmvtolt            => rw_crapdat.dtmvtolt
                                            ,pr_dtcredit            => vr_dtcredit
                                            ,pr_idtabcob            => rw_crapcob_compefora.idrowid_cob
                                            ,pr_nmtelant            => vr_nmtelant
                                            ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada --Tabela lancamentos consolidada
                                            ,pr_cdprogra            => ct_cdprogra --Nome Programa
                                            ,pr_cdcritic            => vr_cdcritic --Codigo da Critica
                                            ,pr_dscritic            => vr_dscritic); --Descricao da critica
            
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_saida;
              END IF;
            END LOOP;

            -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
            GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
          
          
            PAGA0001.pc_realiza_lancto_cooperado(pr_cdcooper            => rw_crapcco.cdcooper --Codigo Cooperativa
                                                ,pr_dtmvtolt            => rw_crapdat.dtmvtolt --Data Movimento
                                                ,pr_cdagenci            => rw_crapcco.cdagenci --Codigo Agencia
                                                ,pr_cdbccxlt            => rw_crapcco.cdbccxlt --Codigo banco caixa
                                                ,pr_nrdolote            => rw_crapcco.nrdolote --Numero do Lote
                                                ,pr_cdpesqbb            => rw_crapcco.nrconven --Codigo Convenio
                                                ,pr_cdcritic            => vr_cdcritic --Codigo Critica
                                                ,pr_dscritic            => vr_dscritic --Descricao Critica
                                                ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada); --Tabela Lancamentos
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;
            -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
            GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
          
          END LOOP;
        
          vr_cdcritic := 1201;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         ' - 1o processamento - Fim - ' || pr_cdagenci;
          cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_cdprogra => ct_cdprogra
                                ,pr_idprglog => vr_idprglog
                                ,pr_dstiplog => 'O'
                                ,pr_tpocorre => 4
                                ,pr_dscritic => vr_dscritic
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_cdcricid => 0);
          vr_cdcritic := NULL;
          vr_dscritic := NULL;

          --> Comandar baixa efetiva de boletos pagos no dia fora da cooperativo(interbancaria)
          COBR0010.pc_gera_baixa_eft_interbca(pr_cdcooper => pr_cdcooper
                                             , --> Cooperativa
                                              pr_dtmvtolt => vr_dtmvtaux
                                             , --> Data
                                              pr_cdcritic => vr_cdcritic
                                             , --> Codigo da Critica
                                              pr_dscritic => vr_dscritic); --> Descricao Critica
          
          --> Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --> Levantar Excecao
            RAISE vr_exc_saida;
          END IF;
          -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
          GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
        END IF; -- Fim Paralelismo 4A    
      
        -- Rotina Paralelismo 4B - Processa quando Principal ou Sem Paralelismo
        --                       - Selecionar Agencias(PA)
        IF (rw_crapdat.inproces > 2 -- 1-on line, 2-agenda, >2-Batch
           AND pr_cdagenci = 0 -- 0-Não Paralelismo, >0-Paralelismo
           AND vr_qtdjobs > 0) -- 0-Não Paralelismo, >0-Paralelismo 
           OR (vr_qtdjobs = 0) -- Não Paralelismo
           OR (rw_crapdat.inproces <= 2) THEN
          -- Processo On Line/Agendado
        
          --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
          -- Log Cobranca processamento 3
          vr_cdcritic := 1201;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         ' - 06 Cobranca 3 - ' || pr_cdagenci || ' - ' || rw_crapcop.cdbcoctl;
          cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_cdprogra => ct_cdprogra
                                ,pr_idprglog => vr_idprglog
                                ,pr_dstiplog => 'O'
                                ,pr_tpocorre => 4
                                ,pr_dscritic => vr_dscritic
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_cdcricid => 0);
          vr_cdcritic := NULL;
          vr_dscritic := NULL;
          
          --
          vr_qtde_convenio := 0;
          vr_idx_convenio := 0;
          BEGIN
            --
            SELECT COUNT(1) INTO vr_qtde_convenio
              FROM (SELECT DISTINCT crapcco.cdcooper
                                   ,crapcco.nrconven
                                   ,crapcco.nrdctabb
                                   ,crapcco.cddbanco
                                   ,ass.cdagenci
                                   ,crapcco.cdbccxlt
                                   ,crapcco.nrdolote
                                   ,crapcco.dsorgarq
                      FROM crapcco
                          ,crapceb ceb
                          ,crapass ass
                     WHERE crapcco.cdcooper = rw_crapcop.cdcooper
                       AND crapcco.cddbanco = rw_crapcop.cdbcoctl
                       AND crapcco.flgregis = 1
                       AND crapcco.dsorgarq IN ('EMPRESTIMO', 'ACORDO', 'DESCONTO DE TITULO')
                       AND ceb.cdcooper = crapcco.cdcooper
                       AND ceb.nrconven = crapcco.nrconven
                       AND ass.cdcooper = ceb.cdcooper
                       AND ass.nrdconta = ceb.nrdconta
                       AND ass.cdagenci = decode(pr_cdagenci, 0, ass.cdagenci, pr_cdagenci));
            --
            pc_log_programa(pr_dstiplog      => 'O' -- Ocorrência
                           ,pr_cdprograma    => vr_cdprogra
                           ,pr_cdcooper      => 3
                           ,pr_tpexecucao    => 0
                           ,pr_tpocorrencia  => 4
                           ,pr_cdcriticidade => 0
                           ,pr_cdmensagem    => 0
                           ,pr_dsmensagem    => '3 - total de convenios: '||LPAD(vr_qtde_convenio,6,0)
                           ,pr_idprglog      => vr_idprglog_principal);
            --
          EXCEPTION
            WHEN OTHERS THEN
              SISTEMA.excecaoInterna('INC0212924');
          END;

            /************************************************************
             Realizar lançamentos dos creditos do movimento D-0
            *************************************************************/
          
            -- Ajusta o parametro com a regra de evitar o nulo - 21/03/2019 - REQ0037942             
            -- Determinar a data do pagamento
            IF vr_nmtelant = 'COMPEFORA' THEN
              --Dia Anterior
              vr_dtcredit := rw_crapdat.dtmvtoan;
              vr_dtmvtaux := rw_crapdat.dtmvtoan;
            ELSE
              --Data Atual
              vr_dtcredit := rw_crapdat.dtmvtolt;
              vr_dtmvtaux := rw_crapdat.dtmvtolt;
            END IF;
          
          -- 3o processamento
          vr_cdcritic := 1201;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         ' - 3o processamento - Inicio - ' || pr_cdagenci;
          cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_cdprogra => ct_cdprogra
                                ,pr_idprglog => vr_idprglog
                                ,pr_dstiplog => 'O'
                                ,pr_tpocorre => 4
                                ,pr_dscritic => vr_dscritic
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_cdcricid => 0);
          vr_cdcritic := NULL;
          vr_dscritic := NULL;

          /* Busca todos os convenios da IF CECRED que foram gerados pela internet */
          FOR rw_crapcco IN cr_crapcco_ativo_age(pr_cdcooper => rw_crapcop.cdcooper
                                                ,pr_cddbanco => rw_crapcop.cdbcoctl
                                                ,pr_cdagenci => pr_cdagenci)
          LOOP
            --
            BEGIN
              --
              vr_idx_convenio := vr_idx_convenio + 1;
              --
              pc_log_programa(pr_dstiplog      => 'O' -- Ocorrência
                             ,pr_cdprograma    => vr_cdprogra
                             ,pr_cdcooper      => 3
                             ,pr_tpexecucao    => 0
                             ,pr_tpocorrencia  => 4
                             ,pr_cdcriticidade => 0
                             ,pr_cdmensagem    => 0
                             ,pr_dsmensagem    => '3 - idx convenio atual: '||LPAD(vr_idx_convenio,6,0)||'/'||LPAD(vr_qtde_convenio,6,0)
                             ,pr_idprglog      => vr_idprglog_principal);
              --
            EXCEPTION
              WHEN OTHERS THEN
                SISTEMA.excecaoInterna('INC0212924');
            END;
            --

            IF rw_crapcco.dsorgarq = 'EMPRESTIMO' THEN
            
              FOR rw_cde IN cr_cde(pr_cdcooper => rw_crapcco.cdcooper
                                  ,pr_nrcnvcob => rw_crapcco.nrconven
                                  ,pr_dtocorre => vr_dtcredit
                                  ,pr_cdagenci => pr_cdagenci)
              LOOP
                -- Ajusta o parametro com a regra de evitar o nulo - 21/03/2019 - REQ0037942           
                IF vr_nmtelant = 'COMPEFORA' AND NOT vr_email_compefora THEN
                
                  vr_email_proc_cred := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                 ,pr_cdcooper => pr_cdcooper
                                                                 ,pr_cdacesso => 'EMAIL_PROCESSUAL_CREDITO');
                
                  -- Se não encontrar e-mail cadastrado no parametro, deve mandar 
                  -- para o e-mail do processual de credito
                  IF vr_email_proc_cred IS NULL THEN
                    vr_email_proc_cred := 'processualdecredito@ailos.coop.br';
                  END IF;
                
                  /* Envio do arquivo detalhado via e-mail */
                  gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                            ,pr_cdprogra        => ct_cdprogra
                                            ,pr_des_destino     => vr_email_proc_cred
                                            ,pr_des_assunto     => 'Pagtos de emprestimos com boleto (COMPEFORA) - ' ||
                                                                   rw_crapcop.nmrescop
                                            ,pr_des_corpo       => 'Favor verificar pagtos de emprestimos com boleto atraves dos relatorios do BI.'
                                            ,pr_des_anexo       => NULL
                                            ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                            ,pr_flg_remete_coop => 'N' --> Se o envio será do e-mail da Cooperativa
                                            ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                            ,pr_des_erro        => vr_dscritic);
                  -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483 
                  IF vr_dscritic IS NOT NULL THEN
                    cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                          ,pr_cdagenci => pr_cdagenci
                                          ,pr_cdprogra => ct_cdprogra
                                          ,pr_idprglog => vr_idprglog
                                          ,pr_dstiplog => 'E'
                                          ,pr_tpocorre => 2
                                          ,pr_dscritic => vr_dscritic
                                          ,pr_cdcritic => 1197
                                          ,pr_cdcricid => 2);
                  END IF;
                  -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
                  GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
                
                  vr_email_compefora := TRUE;
                END IF;
              
                -- se o pagto do boleto foi creditado, entao pagar o contrato                     
                IF rw_cde.flcredit = 1 THEN
                  -- Excluido BEGIN e EXCEPTION exclusivo da PCK - 15/03/2018 - Chamado 801483 
                  -- Ajusta o parametro com a regra de evitar o nulo - 21/03/2019 - REQ0037942
                  EMPR0007.pc_pagar_epr_cobranca(pr_cdcooper => rw_cde.cdcooper
                                                ,pr_nrdconta => rw_cde.nrdconta
                                                ,pr_nrctremp => rw_cde.nrctremp
                                                ,pr_nrcnvcob => rw_cde.nrcnvcob
                                                ,pr_nrdocmto => rw_cde.nrboleto
                                                ,pr_vldpagto => rw_cde.vlrpagto
                                                ,pr_idorigem => 7 -- 7) Batch
                                                ,pr_nmtelant => vr_nmtelant
                                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                ,pr_cdoperad => '1'
                                                ,pr_cdcritic => vr_cdcritic
                                                ,pr_dscritic => vr_dscritic);
                  -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483 
                  IF vr_dscritic IS NOT NULL THEN
                    cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                          ,pr_cdagenci => pr_cdagenci
                                          ,pr_cdprogra => ct_cdprogra
                                          ,pr_idprglog => vr_idprglog
                                          ,pr_dstiplog => 'E'
                                          ,pr_tpocorre => 2
                                          ,pr_dscritic => vr_dscritic
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_cdcricid => 2);
                  END IF;
                  -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
                  GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
                ELSE
                  vr_cdcritic := 0;
                  vr_dscritic := 'Boleto nao creditado';
                END IF;
              
                -- se ocorreu alguma critica de pagto de emprestimo, registrar no boleto
                IF vr_dscritic IS NOT NULL THEN
                  PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_cde.cob_rowid --ROWID da Cobranca
                                               ,pr_cdoperad => 'PAGAEPR' --Operador
                                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data movimento
                                               ,pr_dsmensag => 'Erro: ' ||
                                                               substr(vr_dscritic, 1, 100) --Descricao Mensagem
                                               ,pr_des_erro => vr_des_erro --Indicador erro
                                               ,pr_dscritic => vr_dscritic2); --Descricao erro
                ELSE
                  -- Ajusta o parametro com a regra de evitar o nulo - 21/03/2019 - REQ0037942
                  PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_cde.cob_rowid --ROWID da Cobranca
                                               ,pr_cdoperad => ct_cdoperad --Operador
                                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data movimento
                                               ,pr_dsmensag => 'Pagto realizado ref ao contrato ' ||
                                                               to_char(rw_cde.nrctremp) || (CASE
                                                                 WHEN TRIM(vr_nmtelant) IS NULL THEN
                                                                  ' '
                                                                 ELSE
                                                                  ' - ' || vr_nmtelant || ' '
                                                               END) --Descricao Mensagem
                                               ,pr_des_erro => vr_des_erro --Indicador erro
                                               ,pr_dscritic => vr_dscritic2); --Descricao erro                                                  
                END IF;
                -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
                GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
              
                --Atribui descricao da critica
                IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
                  vr_dscritic := 'Erro: ' || substr(nvl(vr_dscritic, ' '), 1, 90);
                ELSE
                  vr_dscritic := 'OK';
                END IF;
              
                --Retirado carga da tabela de memória rel706
              
                -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483 
                --Gravar dados na tabela work
                /* Alimenta o rel. 706 */
                pc_insere_tbgen_batch_rel_wrk(pr_cdcooper    => rw_cde.cdcooper
                                             ,pr_CDPROGRAMA  => ct_cdprogra
                                             ,pr_DSRELATORIO => 'REL706'
                                             ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                             ,pr_cdagenci    => rw_cde.cdagenci
                                             ,pr_DSCHAVE     => to_char(rw_cde.cdcooper, 'fm000') ||
                                                                to_char(rw_cde.cdagenci, 'fm00000') ||
                                                                to_char(rw_cde.nrdconta
                                                                       ,'fm00000000') ||
                                                                to_char(rw_cde.nrcnvcob
                                                                       ,'fm0000000') ||
                                                                to_char(rw_cde.nrboleto
                                                                       ,'fm000000000')
                                             ,pr_NRDCONTA    => nvl(rw_cde.nrdconta, 0)
                                             ,pr_NRCNVCOB    => rw_cde.nrcnvcob
                                             ,pr_NRDOCMTO    => rw_cde.nrboleto
                                             ,pr_NRCTREMP    => rw_cde.nrctremp
                                             ,pr_DSDOCCOP    => rw_cde.dsdoccop
                                             ,pr_TPPARCEL    => nvl(rw_cde.tpparcela, 0)
                                             ,pr_DTVENCTO    => rw_cde.dtvencto
                                             ,pr_VLTITULO    => rw_cde.vltitulo
                                             ,pr_VLDPAGTO    => rw_cde.vlrpagto
                                             ,pr_DSXML       => NULL
                                             ,pr_dscrient    => vr_dscritic
                                             ,pr_cdcrisai    => vr_cdcritic
                                             ,pr_dscrisai    => vr_dscritic);
                IF NVL(vr_cdcritic, 0) > 0 THEN
                  RAISE vr_exc_saida;
                END IF;
              
                vr_cdcritic := NULL;
                vr_dscritic := NULL;
              END LOOP;
            
            ELSIF rw_crapcco.dsorgarq = 'ACORDO' THEN
              -- Percorrer boletos dos acordos pagos na cobranca para serem regularizados
              FOR rw_boletos_pagos_acordos IN cr_boletos_pagos_acordos(pr_cdcooper => rw_crapcco.cdcooper
                                                                      ,pr_nrcnvcob => rw_crapcco.nrconven
                                                                      ,pr_dtocorre => vr_dtcredit)
              LOOP
              
                -- Excluido BEGIN e EXCEPTION - 15/03/2018 - Chamado 801483
                -- O Log especifico da PAGA só comporta 350 posições e a descrição do erro pode ir até 4000                                                                    
                -- Ajusta o parametro com a regra de evitar o nulo - 21/03/2019 - REQ0037942                                                                                   
                -- Efetuar o pagamento do acordo
                RECP0001.pc_pagar_contrato_acordo(pr_nracordo => rw_boletos_pagos_acordos.nracordo
                                                 ,pr_nrparcel => rw_boletos_pagos_acordos.nrparcela
                                                 ,pr_vlparcel => rw_boletos_pagos_acordos.vlrpagto
                                                 ,pr_cdoperad => 1 -- usuário master
                                                 ,pr_idorigem => 1 -- Ayllos
                                                 ,pr_nmtelant => vr_nmtelant
                                                 ,pr_vltotpag => vr_vltotpag
                                                 ,pr_cdcritic => vr_cdcritic
                                                 ,pr_dscritic => vr_dscritic);
              
                -- Se retornar erro
                IF vr_dscritic IS NOT NULL THEN
                  RAISE vr_exc_saida;
                END IF;
                -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
                GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
              
                -- Excluida chamada de Log especifico para erro - 15/03/2018 - Chamado 801483
                -- Ajusta o parametro com a regra de evitar o nulo - 21/03/2019 - REQ0037942                 
                -- Agora vai cair na TBGEN geral
                PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_boletos_pagos_acordos.cob_rowid --ROWID da Cobranca
                                             ,pr_cdoperad => ct_cdoperad --Operador
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data movimento
                                             ,pr_dsmensag => 'Pagto realizado ref ao acordo ' ||
                                                             to_char(rw_boletos_pagos_acordos.nracordo) || (CASE
                                                               WHEN TRIM(vr_nmtelant) IS NULL THEN
                                                                ' '
                                                               ELSE
                                                                ' - ' || vr_nmtelant || ' '
                                                             END) --Descricao Mensagem
                                             ,pr_des_erro => vr_des_erro --Indicador erro
                                             ,pr_dscritic => vr_dscritic2); --Descricao erro
                -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
                GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
              
              END LOOP;
            
            ELSIF rw_crapcco.dsorgarq = 'DESCONTO DE TITULO' THEN
            
              FOR rw_tit IN cr_tit(pr_cdcooper => rw_crapcco.cdcooper
                                  ,pr_nrcnvcob => rw_crapcco.nrconven
                                  ,pr_dtocorre => vr_dtcredit
                                  ,pr_cdagenci => pr_cdagenci)
              LOOP
                -- Ajusta o parametro com a regra de evitar o nulo - 21/03/2019 - REQ0037942    
                IF vr_nmtelant = 'COMPEFORA' AND NOT vr_email_compefora THEN
                
                  vr_email_proc_cred := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                 ,pr_cdcooper => pr_cdcooper
                                                                 ,pr_cdacesso => 'EMAIL_PROCESSUAL_CREDITO');
                
                  -- Se não encontrar e-mail cadastrado no parametro, deve mandar 
                  -- para o e-mail do processual de credito
                  IF vr_email_proc_cred IS NULL THEN
                    vr_email_proc_cred := 'processualdecredito@ailos.coop.br';
                  END IF;
                
                  /* Envio do arquivo detalhado via e-mail */
                  gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                            ,pr_cdprogra        => ct_cdprogra
                                            ,pr_des_destino     => vr_email_proc_cred
                                            ,pr_des_assunto     => 'Pagtos de títulos com boleto (COMPEFORA) - ' ||
                                                                   rw_crapcop.nmrescop
                                            ,pr_des_corpo       => 'Favor verificar pagtos de títulos com boleto atraves dos relatorios do BI.'
                                            ,pr_des_anexo       => NULL
                                            ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                            ,pr_flg_remete_coop => 'N' --> Se o envio será do e-mail da Cooperativa
                                            ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                            ,pr_des_erro        => vr_dscritic);
                
                  vr_email_compefora := TRUE;
                END IF;
              
                -- se o pagto do boleto foi creditado, entao pagar o contrato                     
                IF rw_tit.flcredit = 1 THEN
                  BEGIN
                    dsct0003.pc_processa_liquidacao_cobtit(pr_cdcooper => rw_tit.cdcooper
                                                          ,pr_nrdconta => rw_tit.nrdconta
                                                          ,pr_nrcnvcob => rw_tit.nrcnvcob
                                                          ,pr_nrctasac => rw_tit.nrctasac
                                                          ,pr_nrdocmto => rw_tit.nrboleto
                                                          ,pr_vlpagmto => rw_tit.vlrpagto
                                                          ,pr_indpagto => rw_tit.indpagto
                                                          ,pr_cdoperad => '1'
                                                          ,pr_cdagenci => 0
                                                          ,pr_nrdcaixa => 0
                                                          ,pr_idorigem => 7 -- Batch
                                                          ,pr_cdcritic => vr_cdcritic
                                                          ,pr_dscritic => vr_dscritic);
                  
                    IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                      --RAISE vr_exc_sair; agora o tratamento de erro é com o raise saida
                      RAISE vr_exc_saida;
                    END IF;
                  
                  EXCEPTION
                    WHEN OTHERS THEN
                      -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
                      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                      -- Erro
                      vr_cdcritic := 0;
                      vr_dscritic := 'Erro nao tratado - ' || SQLERRM;
                  END;
                ELSE
                  vr_cdcritic := 0;
                  vr_dscritic := 'Boleto nao creditado';
                END IF;
              
                -- se ocorreu alguma critica de pagto de emprestimo, registrar no boleto
                IF vr_dscritic IS NOT NULL THEN
                  paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_tit.cob_rowid --ROWID da Cobranca
                                               ,pr_cdoperad => 'PAGATIT' --Operador
                                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data movimento
                                               ,pr_dsmensag => 'Erro: ' ||
                                                               substr(vr_dscritic, 1, 100) --Descricao Mensagem
                                               ,pr_des_erro => vr_des_erro --Indicador erro
                                               ,pr_dscritic => vr_dscritic2); --Descricao erro
                ELSE
                  -- Ajusta o parametro com a regra de evitar o nulo - 21/03/2019 - REQ0037942  
                  paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_tit.cob_rowid --ROWID da Cobranca
                                               ,pr_cdoperad => ct_cdoperad --Operador
                                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data movimento
                                               ,pr_dsmensag => 'Pagto realizado ref ao contrato ' ||
                                                               to_char(rw_tit.nrboleto) || (CASE
                                                                 WHEN TRIM(vr_nmtelant) IS NULL THEN
                                                                  ' '
                                                                 ELSE
                                                                  ' - ' || vr_nmtelant || ' '
                                                               END) --Descricao Mensagem
                                               ,pr_des_erro => vr_des_erro --Indicador erro
                                               ,pr_dscritic => vr_dscritic2); --Descricao erro                                                  
                END IF;
              
                --Atribui descricao da critica
                IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
                  vr_dscritic := 'Erro: ' || substr(nvl(vr_dscritic, ' '), 1, 90);
                ELSE
                  vr_dscritic := 'OK';
                END IF;
              
                vr_cdcritic := NULL;
                vr_dscritic := NULL;
              END LOOP;
            END IF;
          END LOOP;
        
          vr_cdcritic := 1201;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         ' - 3o processamento - Fim - ' || pr_cdagenci;
          cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_cdprogra => ct_cdprogra
                                ,pr_idprglog => vr_idprglog
                                ,pr_dstiplog => 'O'
                                ,pr_tpocorre => 4
                                ,pr_dscritic => vr_dscritic
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_cdcricid => 0);
          vr_cdcritic := NULL;
          vr_dscritic := NULL;

        END IF; -- Fim Paralelismo 4B    
      
        /*  RETIRADO O PROCESSAMENTO DE LIQUIDAÇÃO INTRABANCÁRIA (Renato Darosci - 11/10/2016)
        
        /*************TRATAMENTO P/ COBRANCA REGISTRADA****************/
        /**************************************************************/
      
        -- Retirada chamada da rotina pc_gera_relatorio_574 e criado um novo programa para contempla-lá
        -- Chamado 714566 - 11/08/2017 
      
        -- Retirada chamada da rotina pc_gera_relatorio_605 e criado um novo programa para contempla-lá
        -- Chamado 714566 - 11/08/2017  
      
        -- Retirada chamada da rotina pc_gera_relatorio_686 e criado um novo programa para contempla-lá
        -- Chamado 714566 - 11/08/2017
      
        -- Retirada chamada da rotina pc_gera_relatorio_618
        -- foi deslocada para após a chamada pc_integra_cecred - 03.01.2018
      
        -- Retirada chamada da rotina pc_gera_relatorio_706
        -- foi deslocada para após a chamada pc_integra_cecred - 03.01.2018
      
        -- Retirada chamada da rotina pc_gerar_arq_devolucao e criado um novo programa para contempla-lá
        -- Chamado 714566 - 11/08/2017
      
      EXCEPTION
        -- Excluido vr_exc_final - 15/03/2018 - Chamado 801483
        WHEN vr_exc_saida THEN
          -- Ajuste mensagem - 15/03/2018 - Chamado 801483 
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          -- Ajuste mensagem - 15/03/2018 - Chamado 801483 
          pr_cdcritic := 9999;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                         'CRPS538.pc_integra_cobranca_registrada' || '. ' || SQLERRM;
      END;
      --
      cobr0014.gerarLogFim(pr_cdcooper      => pr_cdcooper
                          ,pr_cdagenci      => pr_cdagenci
                          ,pr_cdprogra      => ct_cdprogra
                          ,pr_cdprocedure   => ct_cdprocedure
                          ,pr_idprglog      => vr_idprglog
                          ,pr_dscomplemento => NULL
                          ,pr_module_name   => vr_module_name
                          ,pr_action_name   => vr_action_name);
      --
    END pc_integra_cobranca_registrada;
  
    -----------------------------------------
    -- Procedimento incluir na tabela gncptit
    -- Ajuste - 15/03/2018 - Chamado 801483  
    -----------------------------------------
    PROCEDURE pc_insert_gncptit(pr_nrdispar IN VARCHAR2
                               ,pr_idx      IN NUMBER
                               ,pr_cdtipreg IN gncptit.cdtipreg%TYPE
                               ,pr_flgconci IN gncptit.flgconci%TYPE
                               ,pr_flgpcctl IN gncptit.flgpcctl%TYPE
                               ,pr_cdcritic IN gncptit.cdcritic%TYPE
                               ,pr_flgpgdda IN gncptit.flgpgdda%TYPE
                               ,pr_nrispbds IN gncptit.nrispbds%TYPE
                               ,pr_cdcriret OUT INTEGER
                               ,pr_dscritic OUT VARCHAR2) IS
      -- Criacao da tabela generica gncptit - utilizada na conciliacao
    BEGIN
      -- Inclusao do nome do modulo logado - 15/03/2018 - Chamado 801483
      GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra || '.pc_insert_gncptit'
                            ,pr_action => NULL);
      pr_cdcriret := NULL;
      pr_dscritic := NULL;
      INSERT INTO gncptit
        (gncptit.cdcooper
        ,gncptit.cdagenci
        ,gncptit.dtmvtolt
        ,gncptit.dtliquid
        ,gncptit.cdbandst
        ,gncptit.cddmoeda
        ,gncptit.nrdvcdbr
        ,gncptit.dscodbar
        ,gncptit.tpcaptur
        ,gncptit.cdagectl
        ,gncptit.nrdolote
        ,gncptit.nrseqdig
        ,gncptit.vldpagto
        ,gncptit.tpdocmto
        ,gncptit.nrseqarq
        ,gncptit.nmarquiv
        ,gncptit.cdoperad
        ,gncptit.hrtransa
        ,gncptit.vltitulo
        ,gncptit.cdtipreg
        ,gncptit.flgconci
        ,gncptit.flgpcctl
        ,gncptit.cdcritic
        ,gncptit.cdmotdev
        ,gncptit.cdfatven
        ,gncptit.flgpgdda
        ,gncptit.nrispbds)
      VALUES
        (pr_cdcooper
        ,0
        ,vr_dtmvtolt
        ,rw_crapdat.dtmvtolt
        ,to_number(TRIM(SUBSTR(vr_setlinha, 1, 3)))
        ,to_number(TRIM(SUBSTR(vr_setlinha, 4, 1)))
        ,to_number(TRIM(SUBSTR(vr_setlinha, 5, 1)))
        ,SUBSTR(vr_setlinha, 01, 44)
        ,to_number(TRIM(SUBSTR(vr_setlinha, 50, 1)))
        ,to_number(TRIM(SUBSTR(vr_setlinha, 57, 4)))
        ,to_number(TRIM(SUBSTR(vr_setlinha, 61, 6)))
        ,to_number(TRIM(SUBSTR(vr_setlinha, 68, 3)))
        ,to_number(TRIM(SUBSTR(vr_setlinha, 85, 12))) / 100
        ,to_number(TRIM(SUBSTR(vr_setlinha, 45, 2)))
        ,to_number(TRIM(SUBSTR(vr_setlinha, 151, 10)))
        ,vr_tab_nmarqtel(pr_idx)
        ,ct_cdoperad
        ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 151, 10)))
        ,to_number(TRIM(SUBSTR(vr_setlinha, 10, 10))) / 100
        ,pr_cdtipreg
        ,pr_flgconci
        ,pr_flgpcctl
        ,pr_cdcritic
        ,0
        ,to_number(TRIM(SUBSTR(vr_setlinha, 6, 4)))
        ,NVL(pr_flgpgdda, 0)
        ,NVL(pr_nrispbds, 0));
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log 
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
        -- Mensagem
        pr_cdcriret := 1034;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcriret) || ' gncptit(4):' ||
                       ' nrdispar:' || pr_nrdispar || ', cdcooper:' || pr_cdcooper || ', cdagenci:' || '0' ||
                       ', dtmvtolt:' || vr_dtarquiv || ', dtliquid:' || rw_crapdat.dtmvtolt ||
                       ', cdbandst:' || to_number(TRIM(SUBSTR(vr_setlinha, 1, 3))) || ', cddmoeda:' ||
                       to_number(TRIM(SUBSTR(vr_setlinha, 4, 1))) || ', nrdvcdbr:' ||
                       to_number(TRIM(SUBSTR(vr_setlinha, 5, 1))) || ', dscodbar:' ||
                       SUBSTR(vr_setlinha, 01, 44) || ', tpcaptur:' ||
                       to_number(TRIM(SUBSTR(vr_setlinha, 50, 1))) || ', cdagectl:' ||
                       to_number(TRIM(SUBSTR(vr_setlinha, 57, 4))) || ', nrdolote:' ||
                       to_number(TRIM(SUBSTR(vr_setlinha, 61, 6))) || ', nrseqdig:' ||
                       to_number(TRIM(SUBSTR(vr_setlinha, 68, 3))) || ', vldpagto:' ||
                       to_number(TRIM(SUBSTR(vr_setlinha, 85, 12))) || '/ 100 ' || ', tpdocmto:' ||
                       to_number(TRIM(SUBSTR(vr_setlinha, 45, 2))) || ', nrseqarq:' ||
                       to_number(TRIM(SUBSTR(vr_setlinha, 151, 10))) || ', nmarquiv:' ||
                       vr_tab_nmarqtel(pr_idx) || ', cdoperad:' || ct_cdoperad || ', hrtransa:' ||
                       TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 151, 10))) || ', vltitulo:' ||
                       to_number(TRIM(SUBSTR(vr_setlinha, 10, 10))) || ' / 100 ' || ', cdtipreg:' ||
                       pr_cdtipreg || ', flgconci:' || pr_flgconci || ', flgpcctl:' || pr_flgpcctl ||
                       ', cdcritic:' || pr_cdcritic || ', cdmotdev:' || '0' || ', cdfatven:' ||
                       to_number(TRIM(SUBSTR(vr_setlinha, 6, 4))) || ', flgpgdda:' || pr_flgpgdda ||
                       ', nrispbds:' || pr_nrispbds || '. ' || SQLERRM;
    END pc_insert_gncptit;
  
    -----------------------------------------
    -- Procedimento para Integrar Cecred
    -----------------------------------------
    PROCEDURE pc_integra_cecred(pr_cdcritic OUT INTEGER
                               ,pr_dscritic OUT VARCHAR2) IS
      --
      ct_cdprocedure CONSTANT tbgen_prglog.cdprograma%TYPE := 'pc_integra_cecred';
      vr_module_name VARCHAR2(100) := NULL;
      vr_action_name VARCHAR2(100) := NULL;
      --
      --Cursores Locais
      CURSOR cr_crabcco(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrconven IN crapcco.nrconven%TYPE) IS
        SELECT crapcco.cdcooper
              ,crapcco.nrconven
              ,crapcco.nrdctabb
              ,crapcco.cddbanco
              ,COUNT(*) OVER(PARTITION BY crapcco.nrconven) qtdreg
          FROM crapcco
         WHERE crapcco.cdcooper <> pr_cdcooper
           AND crapcco.nrconven = pr_nrconven;
      rw_crabcco cr_crabcco%ROWTYPE;
    
      --Selecionar Convenio
      CURSOR cr_crabcco2(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrconven IN crapcco.nrconven%TYPE) IS
        SELECT crapcco.cdcooper
              ,crapcco.nrconven
              ,crapcco.nrdctabb
              ,crapcco.cddbanco
              ,COUNT(*) OVER(PARTITION BY crapcco.nrconven) qtdreg
          FROM crapcco
         WHERE crapcco.cdcooper = pr_cdcooper
           AND crapcco.nrconven = pr_nrconven;
    
      --Selecionar Transferencias de Contas
      CURSOR cr_craptco_ant(pr_cdcooper IN craptco.cdcooper%TYPE
                           ,pr_cdcopant IN craptco.cdcopant%TYPE
                           ,pr_nrctaant IN craptco.nrctaant%TYPE
                           ,pr_tpctatrf IN craptco.tpctatrf%TYPE
                           ,pr_flgativo IN craptco.flgativo%TYPE) IS
        SELECT craptco.nrdconta
          FROM craptco
         WHERE craptco.cdcooper = pr_cdcooper
           AND craptco.cdcopant = pr_cdcopant
           AND craptco.nrctaant = pr_nrctaant
           AND craptco.tpctatrf = pr_tpctatrf
           AND craptco.flgativo = pr_flgativo;
      rw_craptco cr_craptco_ant%ROWTYPE;
    
      -- verificar se o boleto foi processado na singular
      -- Cursor não utlizado e excluido cr_ret_sing - Chamado 714566 - 11/08/2017
    
      --> Buscar codigo do banco
      CURSOR cr_crapban(pr_nrispbif crapban.nrispbif%TYPE) IS
        SELECT ban.cdbccxlt
          FROM crapban ban
         WHERE ban.nrispbif = pr_nrispbif;
      -- buscar registro de devolucao
    
      CURSOR cr_devolucao(pr_cdcooper tbcobran_devolucao.cdcooper%TYPE
                         ,pr_dtmvtolt tbcobran_devolucao.dtmvtolt%TYPE
                         ,pr_dscodbar tbcobran_devolucao.dscodbar%TYPE
                         ,pr_nrseqarq tbcobran_devolucao.nrseqarq%TYPE
                         ,pr_nrispbif tbcobran_devolucao.nrispbif%TYPE) IS
        SELECT 1
          FROM tbcobran_devolucao d
         WHERE d.cdcooper = pr_cdcooper
           AND d.dtmvtolt = pr_dtmvtolt
           AND TRIM(d.dscodbar) = TRIM(pr_dscodbar)
           AND d.nrseqarq = pr_nrseqarq
           AND d.nrispbif = pr_nrispbif;
      rw_devolucao cr_devolucao%ROWTYPE;
    
      -- cursor para buscar apenas pela conta 
      CURSOR cr_crapass_conta(pr_nrdconta IN crapass.cdcooper%TYPE) IS
        SELECT 1
          FROM crapass ass
         WHERE ass.cdcooper <> 3
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass_conta cr_crapass_conta%ROWTYPE;
    
      ---vr_flgproc_sing INTEGER;
    
      --Variaveis Locais
      vr_flgtitcp BOOLEAN;
      vr_dsmotivo VARCHAR2(100);
      vr_vldescto NUMBER;
      vr_vlabatim NUMBER;
      vr_vlrjuros NUMBER;
      vr_vlrmulta NUMBER;
      vr_vlfatura NUMBER;
      vr_nrretcoo VARCHAR2(100);
      vr_flgrejei BOOLEAN;
      vr_flgvenci BOOLEAN;
      vr_lgdetail BOOLEAN;
      vr_flgerro  BOOLEAN;
      vr_cdbanpag INTEGER;
      vr_cdagepag INTEGER;
      vr_liqaposb BOOLEAN;
      
      vr_crapass  BOOLEAN;
      vr_crapsab  BOOLEAN;
      vr_crapceb  BOOLEAN;
      vr_dstextab craptab.dstextab%TYPE;
      vr_cdagepar crapass.cdagenci%TYPE; -- agencia paralelismo
      --Excecoes
      vr_exc_proximo EXCEPTION;
      vr_exc_sair    EXCEPTION;
      -- Retorno do insert da prc de insert da tabela gncptit - 15/03/2018 - Chamado 801483  
      vr_cdcrignc crapcri.cdcritic%TYPE;
    BEGIN
      --
      cobr0014.gerarLogInicio(pr_cdcooper      => pr_cdcooper
                             ,pr_cdagenci      => pr_cdagenci
                             ,pr_cdprogra      => 'PC_' || ct_cdprogra
                             ,pr_cdprocedure   => ct_cdprocedure
                             ,pr_idprglog      => vr_idprglog
                             ,pr_dscomplemento => NULL
                             ,pr_module_name   => vr_module_name
                             ,pr_action_name   => vr_action_name);
      --
      BEGIN
        --Inicializar variaveis erro
        pr_cdcritic := NULL;
        pr_dscritic := NULL;
      
        /* Remove os arquivos ".q" caso existam */
        vr_comando := 'rm ' || vr_caminho_integra || '/' || REPLACE(vr_nmarqret, '%', '*') ||
                      '.q 2> /dev/null';
      
        --Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);
        --Se ocorreu erro dar RAISE
        /*IF vr_typ_saida = 'ERR' THEN
          vr_dscritic:= 'Não foi possível executar comando unix. '||vr_comando;
          RAISE vr_exc_saida;
        END IF;*/ -- Nao dar erro se os arquivos nao existem
      
        --Listar arquivos no diretorio
        gene0001.pc_lista_arquivos(pr_path     => vr_caminho_integra
                                  ,pr_pesq     => vr_nmarqret
                                  ,pr_listarq  => vr_listadir
                                  ,pr_des_erro => vr_dscritic);
        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;
      
        --Montar vetor com nomes dos arquivos
        vr_tab_nmarqtel := GENE0002.fn_quebra_string(pr_string => vr_listadir);
      
        --Se nao encontrou arquivos
        IF vr_tab_nmarqtel.COUNT <= 0 THEN
          -- Montar mensagem de critica
          vr_cdcritic := 182;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' - caminho:' ||
                         vr_caminho_integra || ', nome:' || vr_nmarqret;
          -- Excluido pc_controla_log_batch, agora fica no final da rotina - 15/03/2018 - Chamado 801483 
          --Levantar Excecao pois nao tem arquivo para processar
          IF nvl(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                          ,pr_cdcooper => 0
                                          ,pr_cdacesso => 'FL_CRPS538_ABORTAR')
                ,'S') = 'S' THEN
            RAISE vr_exc_saida;
          ELSE
            RAISE vr_exc_final;
          END IF;
        END IF;
        /*  Fim da verificacao se deve executar  */
      
        -- Se for execução pela COMPEFORA, deve criticar caso seja encontrado 
        -- mais de um arquivo para processamento, de forma a evitar que um arquivo 
        -- Ajusta o parametro com a regra de evitar o nulo - 21/03/2019 - REQ0037942  
        -- normal e um REPROC sejam reprocessados juntos  ( Renato Darosci - Supero)
        IF vr_nmtelant = 'COMPEFORA' THEN
          -- Se encontrou mais de um arquivos
          IF vr_tab_nmarqtel.COUNT > 1 THEN
            -- Montar mensagem de critica
            vr_cdcritic := 442; -- Mais de um arquivo encontrado para processamento
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                           ' - Arquivo: integra/' || vr_nmarqret;
            -- Excluido pc_controla_log_batch - 15/03/2018 - Chamado 801483 
            --Levantar excecao pois nesse caso deveria ter apenas um arquivo para processar
            RAISE vr_exc_final;
          END IF;
        END IF;
      
        -- Buscar parametro de valor mínimo
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => 'VLRMINCAC'
                                                 ,pr_tpregist => 0);
        --Se nao encontrou
        IF vr_dstextab IS NULL THEN
          vr_vlrmincac := 0;
        ELSE
          vr_vlrmincac := to_number(vr_dstextab) / 100;
        END IF;
      
        --Percorrer todos os arquivos
        FOR idx IN 1 .. vr_tab_nmarqtel.COUNT
        LOOP
        
          --Inicializar variaveis
          vr_lgdetail := FALSE;
          vr_cdcritic := 0;
          vr_inreproc := FALSE;
        
          /* Verificar o Header */
          -- Comando para listar a primeira linha do arquivo
          vr_comando := 'head -1 ' || vr_caminho_integra || '/' || vr_tab_nmarqtel(idx);
        
          --Executar o comando no unix
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => vr_comando
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_setlinha);
          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
            --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
            vr_cdcritic := 1114; --Nao foi possivel executar comando unix
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' ' ||
                           vr_comando;
            RAISE vr_exc_saida_2;
          END IF;
        
          --Montar Tipo Cobranca
          vr_dstipcob := SUBSTR(vr_setlinha, 48, 6);
          --Montar Data Arquivo
          vr_dtleiaux := SUBSTR(vr_setlinha, 66, 8);
        
          /* Verifica a primeira linha do arquivo importado */
          IF SUBSTR(vr_setlinha, 1, 10) <> '0000000000' THEN
            vr_cdcritic := 468;
          ELSIF vr_dstipcob <> 'COB615' THEN
            vr_cdcritic := 181;
          ELSIF vr_dtleiaux <> vr_dtleiarq THEN
            vr_cdcritic := 789;
          END IF;
        
          --Se ocorreu algum erro na validacao
          IF vr_cdcritic <> 0 THEN
            --Buscar descricao da critica
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            -- Incluido controle de Log - Chamado 714566 - 11/08/2017 
            --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
            cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => pr_cdagenci
                                  ,pr_cdprogra => ct_cdprogra
                                  ,pr_idprglog => vr_idprglog
                                  ,pr_dstiplog => 'E'
                                  ,pr_tpocorre => 1
                                  ,pr_dscritic => vr_dscritic || ' - Arquivo: integra/' ||
                                                  vr_tab_nmarqtel(idx) || ', vr_dtleiaux:' ||
                                                  vr_dtleiaux || ', vr_dtleiarq:' || vr_dtleiarq
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_cdcricid => 0);
            --Zerar variavel critica
            vr_cdcritic := 0;
            --Ir para proximo arquivo
            CONTINUE;
          END IF;
        
          -- Verificar se o arquivo é um REPROC  (Renato Darosci - 11/10/2016)
          IF TRIM(SUBSTR(vr_setlinha, 99, 3)) = 'REP' THEN
            -- Indica que o arquivo é de reprocessamento
            vr_inreproc := TRUE;
          END IF;
        
          --Escrever mensagem de integracao no log
          vr_cdcritic := 219;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          -- Incluido controle de Log - Chamado 714566 - 11/08/2017 
          --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
          cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_cdprogra => ct_cdprogra
                                ,pr_idprglog => vr_idprglog
                                ,pr_dstiplog => 'O'
                                ,pr_tpocorre => 4
                                ,pr_dscritic => vr_dscritic || ' - Arquivo: integra/' ||
                                                vr_tab_nmarqtel(idx)
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_cdcricid => 0);
          --Zerar variavel critica
          vr_cdcritic := 0;
        
          /* Nao ocorreu erro nas validacoes, abrir o arquivo e processar as linhas */
        
          --Abrir o arquivo de dados
          gene0001.pc_abre_arquivo(pr_nmdireto => vr_caminho_integra --> Diretorio do arquivo
                                  ,pr_nmarquiv => vr_tab_nmarqtel(idx) --> Nome do arquivo
                                  ,pr_tipabert => 'R' --> Modo de abertura (R,W,A)
                                  ,pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                  ,pr_des_erro => vr_dscritic); --> Erro
          IF vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_saida_2;
          ELSE
            BEGIN
              -- Ler a primeira linha. A mesma deve ser ignorada
              gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                          ,pr_des_text => vr_setlinha); --> Texto lido
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                --Chegou ao final arquivo, sair do loop
                EXIT;
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                -- Ajuste mensagem - 15/03/2018 - Chamado 801483 
                vr_cdcritic := 1053;
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                               '(1) caminho=' || vr_caminho_integra || ', nmarqtel=' ||
                               vr_tab_nmarqtel(idx) || '. ' || SQLERRM;
                RAISE vr_exc_saida_2;
            END;
          END IF;
        
          vr_tab_lcm_consolidada.delete;
        
          --Criar savepoint para rollback
          -- SAVEPOINT save_trans;
          --Percorrer todas as linhas do arquivo
        
          -- verificar se é a primeira agencia que esta sendo executada
          -- será usado prox. da linha 3853
          OPEN cr_crapass_age(pr_cdcooper, TO_DATE(vr_dtleiarq, 'YYYYMMDD'), ct_cdprogra);
          FETCH cr_crapass_age
            INTO vr_cdagepar;
          CLOSE cr_crapass_age;
        
          LOOP
            BEGIN
              BEGIN
                -- Le os dados do arquivo e coloca na variavel vr_setlinha
                gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                            ,pr_des_text => vr_setlinha); --> Texto lido
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  --Chegou ao final arquivo, sair do loop
                  EXIT;
                WHEN OTHERS THEN
                  -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
                  CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                  -- Ajuste mensagem - 15/03/2018 - Chamado 801483 
                  vr_cdcritic := 1053;
                  vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                                 '(2) caminho=' || vr_caminho_integra || ', nmarqtel=' ||
                                 vr_tab_nmarqtel(idx) || '. ' || SQLERRM;
                  RAISE vr_exc_sair;
              END;
            
              /* Trailer do lote do arquivo - Quanto encontrar a sequencia 
              especifica, deve ignorar a linha ( Renato Darosci - 11/10/2016) */
              IF SUBSTR(vr_setlinha, 1, 31) = '      9999999999999999999999999' THEN
                CONTINUE; -- Passa para o processamento da Próxima linha do arquivo
              END IF;
            
              /* Trailer - Se encontrar essa seq., terminou o arquivo */
              IF SUBSTR(vr_setlinha, 1, 10) = '9999999999' THEN
                EXIT;
              END IF;
            
              -- marca que houve processo - Chamado 714566 - 11/08/2017
              vr_intemarq := TRUE;
            
              --Atribuir variaveis do registro lido
              BEGIN
                vr_flgerro      := FALSE;
                vr_lgdetail     := TRUE;
                vr_dscodbar_ori := SUBSTR(vr_setlinha, 1, 44);
              
                vr_dtmvtolt := TO_DATE(TRIM(SUBSTR(vr_setlinha, 71, 8)), 'YYYYMMDD');
                vr_vlliquid := TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 85, 12))) / 100;
                vr_nrcnvcob := TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 20, 6)));
                vr_nrdconta := TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 26, 8)));
                vr_nrdocmto := TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 34, 9)));
                vr_liqaposb := FALSE;
                vr_vltitulo := to_number(TRIM(SUBSTR(vr_setlinha, 10, 10))) / 100;
              
                -- Cooperado importou o boleto corretamente e imprimiu atraves do software proprio
                -- porém na impressão ele utilizou o numero da conta sem o digito verificador
                -- e todos os pagamentos estao sendo rejeitados
                -- Chamado 650122
                IF pr_cdcooper = 10 AND -- Credicomin
                   vr_nrdconta = 5814 AND -- Numero da Conta sem o digito (utilizado pelo cooperado na impressao)
                   vr_nrcnvcob = 109061 THEN
                  -- Convenio Impresso pelo Software
                  -- Ajustar numero da conta para o cooperado
                  vr_nrdconta := 58149;
                END IF;
              
                --ISPB da recebedora
                vr_nrispbif_rec := SUBSTR(vr_setlinha, 132, 8);
              
                --ISPB da favorecida
                vr_nrispbif_fav := SUBSTR(vr_setlinha, 140, 8);
              
                vr_nrseqarq := TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 151, 10)));
                vr_tpcaptur := to_number(TRIM(SUBSTR(vr_setlinha, 50, 1)));
                vr_tpdocmto := to_number(TRIM(SUBSTR(vr_setlinha, 148, 3)));
                vr_cdagepag := to_number(TRIM(SUBSTR(vr_setlinha, 57, 4)));
              
              EXCEPTION
                WHEN OTHERS THEN
                  -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
                  CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                  vr_flgerro := TRUE;
              END;

              IF NOT (vr_nmtelant = 'COMPEFORA') THEN
                -- Rotina Paralelismo 3A - Processa quando JOB
                --                       - Selecionar Agencias(PA)
                IF rw_crapdat.inproces > 2 -- 1-on line, 2-agenda, >2-Batch
                   AND pr_cdagenci > 0 -- 0-Não Paralelismo, >0-Paralelismo
                   AND vr_qtdjobs > 0 THEN
                  -- 0-Não Paralelismo, >0-Paralelismo 
                
                  --Seleciona a Agencia do Associado
                  OPEN cr_crapass(pr_cdcooper => pr_cdcooper, pr_nrdconta => vr_nrdconta);
                  FETCH cr_crapass
                    INTO rw_crapass;
                  --Indicar se encontrou ou nao
                  vr_crapass := cr_crapass%FOUND;
                  --Fechar Cursor
                  CLOSE cr_crapass;
                  --Se encontrou associado
                  IF vr_crapass THEN
                    --Considera movimento da agencia no JOB do paralelismo em execução. 
                    IF rw_crapass.cdagenci <> pr_cdagenci THEN
                      CONTINUE; -- Passa para o processamento da Próxima linha do arquivo
                    END IF;
                  ELSE
                  
                    vr_index_crapcco := lpad(rw_crapcop.cdcooper, 10, '0') ||
                                        lpad(vr_nrcnvcob, 10, '0');
                  
                    -- Se nao existir convenio na cooperativa singular ignora linha, 
                    -- pois este convenio é de outra cooperativa singular.                   
                    -- Validação do convenio que não existe no sistema é feito 
                    -- por volta da linha 4130.
                    IF NOT vr_tab_crapcco.EXISTS(vr_index_crapcco) THEN
                      --Proxima linha
                      RAISE vr_exc_proximo;
                    ELSE
                    
                      -- se a agencia vr_cdagepar for igual a primeira agencia encontrada no cursor
                      -- cr_crapass_age, significa que e a primeira agencia a ser executada no paralelismo
                      -- desta forma devemos prosguir para verificar possível devoluçao do boleto
                    
                      IF vr_cdagepar <> pr_cdagenci THEN
                        -- pular para a próxima linha
                        -- pois não é a primeira agencia a ser executada no paralelismo
                        RAISE vr_exc_proximo;
                      END IF;
                    
                      OPEN cr_crapass_conta(pr_nrdconta => vr_nrdconta);
                      FETCH cr_crapass_conta
                        INTO rw_crapass_conta;
                    
                      IF cr_crapass_conta%FOUND THEN
                        CLOSE cr_crapass_conta;
                        RAISE vr_exc_proximo;
                      END IF;
                    
                      CLOSE cr_crapass_conta;
                    
                      --VALIDAR SE O BOLETO JÁ FOI REJEITADO
                    
                      OPEN cr_devolucao(pr_cdcooper => pr_cdcooper
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                       ,pr_dscodbar => vr_dscodbar_ori
                                       ,pr_nrseqarq => vr_nrseqarq
                                       ,pr_nrispbif => vr_nrispbif_rec);
                      FETCH cr_devolucao
                        INTO rw_devolucao;
                    
                      IF cr_devolucao%FOUND THEN
                        CLOSE cr_devolucao;
                        --Proxima linha
                        RAISE vr_exc_proximo;
                      END IF;
                    
                      CLOSE cr_devolucao;
                    
                      -- rejeitar boleto, pois significa que não é uma conta valida
                      vr_flgrejei := TRUE;
                    
                      --Escrever crítica no relatório
                      vr_cdcritic := 9;
                    
                      pc_insert_gncptit(pr_nrdispar => 14 -- Numero sequencial do dispare da prc 
                                       ,pr_idx      => idx
                                       ,pr_cdtipreg => 3 /* Sua Remessa - Erro */
                                       ,pr_flgconci => 1 /* registro conciliado */
                                       ,pr_flgpcctl => 0 /* processou na central */
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_flgpgdda => NULL
                                       ,pr_nrispbds => vr_nrispbif_rec
                                       ,pr_cdcriret => vr_cdcrignc
                                       ,pr_dscritic => vr_dscritic);
                    
                      IF NVL(vr_cdcrignc, 0) > 0 THEN
                        vr_cdcritic := vr_cdcrignc;
                        RAISE vr_exc_sair;
                      END IF;
                    
                      /* create craprej */
                      BEGIN
                        INSERT INTO craprej
                          (craprej.dtmvtolt
                          ,craprej.cdagenci
                          ,craprej.vllanmto
                          ,craprej.nrseqdig
                          ,craprej.cdpesqbb
                          ,craprej.cdcritic
                          ,craprej.cdcooper
                          ,craprej.nrdconta
                          ,craprej.cdbccxlt
                          ,craprej.nrdocmto)
                        VALUES
                          (rw_crapdat.dtmvtolt
                          ,vr_cdagepag
                          ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 85, 12))) / 100
                          ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 151, 10)))
                          ,vr_setlinha
                          ,vr_cdcritic
                          ,pr_cdcooper
                          ,vr_nrdconta
                          ,vr_cdbanpag
                          ,vr_nrdocmto)
                        RETURNING craprej.dtmvtolt, craprej.cdagenci, craprej.vllanmto, craprej.nrseqdig, craprej.cdpesqbb, craprej.cdcritic, craprej.cdcooper, craprej.nrdconta, craprej.cdbccxlt, craprej.nrdocmto INTO rw_craprej.dtmvtolt, rw_craprej.cdagenci, rw_craprej.vllanmto, rw_craprej.nrseqdig, rw_craprej.cdpesqbb, rw_craprej.cdcritic, rw_craprej.cdcooper, rw_craprej.nrdconta, rw_craprej.cdbccxlt, rw_craprej.nrdocmto;
                      EXCEPTION
                        WHEN OTHERS THEN
                          -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
                          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                          vr_cdcritic := 0;
                          vr_dscritic := 'Erro ao inserir na tabela craprej. ' || SQLERRM;
                          --Levantar Excecao
                          RAISE vr_exc_sair;
                      END;
                    
                      --Atualizar tabela memoria cratrej
                      pc_gera_cratrej(rw_craprej);
                    
                      --> Gerar Devolucao
                      vr_cdmotdev := 73; --> 73 - Beneficiário sem contrato de cobrança com a instituição financeira Destinatária
                      --> Procedimento para grava registro de devolucao
                      pc_grava_devolucao(pr_cdcooper => rw_crapcop.cdcooper --> codigo da cooperativa
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> data do movimento
                                        ,pr_dtmvtopr => rw_crapdat.dtmvtopr --> data do próximo movimento
                                        ,pr_nrseqarq => vr_nrseqarq --> numero sequencial do arquivo da devolucao (cob615)
                                        ,pr_dscodbar => vr_dscodbar_ori --> codigo de barras
                                        ,pr_nrispbif => vr_nrispbif_rec --> numero do ispb recebedora
                                        ,pr_vlliquid => vr_vlliquid --> valor de liquidacao do titulo
                                        ,pr_dtocorre => vr_dtmvtolt --> data da ocorrencia da devolucao
                                        ,pr_nrdconta => vr_nrdconta --> numero da conta do cooperado
                                        ,pr_nrcnvcob => vr_nrcnvcob --> numero do convenio de cobranca do cooperado
                                        ,pr_nrdocmto => vr_nrdocmto --> numero do boleto de cobranca
                                        ,pr_cdmotdev => vr_cdmotdev --> codigo do motivo da devolucao
                                        ,pr_tpcaptur => vr_tpcaptur --> tipo de captura (cob615)
                                        ,pr_tpdocmto => vr_tpdocmto --> codigo do tipo de documento (cob615)
                                        ,pr_cdagerem => vr_cdagepag --> codigo da agencia do remetente (cob615)
                                        ,pr_dslinarq => vr_setlinha
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                    
                      IF TRIM(vr_dscritic) IS NOT NULL THEN
                        RAISE vr_exc_sair;
                      END IF;
                    
                      --Inicializar variavel erro
                      vr_cdcritic := 0;
                      --Pular proxima linha arquivo
                      RAISE vr_exc_proximo;
                    
                    END IF;
                  END IF;
                END IF; --Fim Paralelismo 3A
              END IF; -- NOT COMPEFORA
            
              --> Buscar codigo do banco recebedor
              vr_cdbanpag := NULL;
              OPEN cr_crapban(pr_nrispbif => vr_nrispbif_rec);
              FETCH cr_crapban
                INTO vr_cdbanpag;
              CLOSE cr_crapban;
            
              -- Totaliza quantidade de registros processados no processo
              vr_tot_reg := vr_tot_reg + 1;
            
              /* Quando cecred validar se o título e de uma singular
              caso contrario cria temp-table do relatorio de titulos rejeitados */
              IF pr_cdcooper = 3 THEN
                --Se ocorreu erro
                IF vr_flgerro THEN
                  --Marcar como rejeitado
                  vr_flgrejei := TRUE;
                  --Escrever mensagem de integracao no log
                  vr_cdcritic := 843;
                  vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                  -- Incluido controle de Log - Chamado 714566 - 11/08/2017 
                  --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
                  cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                        ,pr_cdagenci => pr_cdagenci
                                        ,pr_cdprogra => ct_cdprogra
                                        ,pr_idprglog => vr_idprglog
                                        ,pr_dstiplog => 'E'
                                        ,pr_tpocorre => 1
                                        ,pr_dscritic => vr_dscritic || ' - Linha: ' ||
                                                        SUBSTR(vr_setlinha, 151, 10) ||
                                                        ' - Arquivo: integra/' ||
                                                        vr_tab_nmarqtel(idx)
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_cdcricid => 0);
                
                  -- Criacao da tabela generica gncptit - utilizada na conciliacao 
                  -- Ajuste - 15/03/2018 - Chamado 801483
                  pc_insert_gncptit(pr_nrdispar => 1 -- Numero sequencial do dispare da prc 
                                   ,pr_idx      => idx
                                   ,pr_cdtipreg => 3 /* Sua Remessa - Erro */
                                   ,pr_flgconci => 1 /* registro conciliado */
                                   ,pr_flgpcctl => 1 /* processou na central */
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_flgpgdda => NULL
                                   ,pr_nrispbds => vr_nrispbif_rec
                                   ,pr_cdcriret => vr_cdcrignc
                                   ,pr_dscritic => vr_dscritic);
                
                  IF NVL(vr_cdcrignc, 0) > 0 THEN
                    vr_cdcritic := vr_cdcrignc;
                    RAISE vr_exc_sair;
                  END IF;
                
                  --Inicializar variavel erro
                  vr_cdcritic := 0;
                  --Proxima Linha Arquivo
                  RAISE vr_exc_proximo;
                END IF; --vr_flgerro
                /* verifica se é de um convenio na cooperativa singular */
                vr_flgtitcp := FALSE;
                FOR rw_crapcop_lista IN cr_crapcop_lista
                LOOP
                  --Montar Indice para acesso tabela memoria convenio
                  vr_index_crapcco := lpad(rw_crapcop_lista.cdcooper, 10, '0') ||
                                      lpad(vr_nrcnvcob, 10, '0');
                  vr_flgtitcp      := vr_tab_crapcco.EXISTS(vr_index_crapcco);
                  --Sair do loop quando encontrar
                  IF vr_flgtitcp THEN
                    EXIT;
                  END IF;
                END LOOP;
                --Se nao encontrou
                IF NOT vr_flgtitcp THEN
                
                  -- Criacao da tabela generica gncptit - utilizada na conciliacao 
                  -- Ajuste - 15/03/2018 - Chamado 801483
                  pc_insert_gncptit(pr_nrdispar => 2 -- Numero sequencial do dispare da prc 
                                   ,pr_idx      => idx
                                   ,pr_cdtipreg => 3 /* Sua Remessa - Erro */
                                   ,pr_flgconci => 1 /* registro conciliado */
                                   ,pr_flgpcctl => 1 /* processou na central */
                                   ,pr_cdcritic => 796
                                   ,pr_flgpgdda => NULL
                                   ,pr_nrispbds => vr_nrispbif_rec
                                   ,pr_cdcriret => vr_cdcrignc
                                   ,pr_dscritic => vr_dscritic);
                
                  IF NVL(vr_cdcrignc, 0) > 0 THEN
                    vr_cdcritic := vr_cdcrignc;
                    RAISE vr_exc_sair;
                  END IF;
                
                  --> Gerar Devolucao
                  vr_cdmotdev := 73; --> 73 - Beneficiário sem contrato de cobrança com a instituição financeira Destinatária                

                  --> Procedimento para grava registro de devolucao
                  pc_grava_devolucao(pr_cdcooper => rw_crapcop.cdcooper --> codigo da cooperativa
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> data do movimento
                                    ,pr_dtmvtopr => rw_crapdat.dtmvtopr --> data do próximo movimento
                                    ,pr_nrseqarq => vr_nrseqarq --> numero sequencial do arquivo da devolucao (cob615)
                                    ,pr_dscodbar => vr_dscodbar_ori --> codigo de barras
                                    ,pr_nrispbif => vr_nrispbif_rec --> numero do ispb recebedora
                                    ,pr_vlliquid => vr_vlliquid --> valor de liquidacao do titulo
                                    ,pr_dtocorre => vr_dtmvtolt --> data da ocorrencia da devolucao
                                    ,pr_nrdconta => vr_nrdconta --> numero da conta do cooperado
                                    ,pr_nrcnvcob => vr_nrcnvcob --> numero do convenio de cobranca do cooperado
                                    ,pr_nrdocmto => vr_nrdocmto --> numero do boleto de cobranca
                                    ,pr_cdmotdev => vr_cdmotdev --> codigo do motivo da devolucao
                                    ,pr_tpcaptur => vr_tpcaptur --> tipo de captura (cob615)
                                    ,pr_tpdocmto => vr_tpdocmto --> codigo do tipo de documento (cob615)
                                    ,pr_cdagerem => vr_cdagepag --> codigo da agencia do remetente (cob615)
                                    ,pr_dslinarq => vr_setlinha
                                    ,pr_cdcritic => vr_cdcritic -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483 
                                    ,pr_dscritic => vr_dscritic);
                  IF TRIM(vr_dscritic) IS NOT NULL THEN
                    RAISE vr_exc_sair;
                  END IF;
                
                  --Inicializar variavel erro
                  vr_cdcritic := 0;
                
                  --Marcar como rejeitado
                  vr_flgrejei := TRUE;
                
                END IF;
              END IF; --pr_cdcooper = 3
              --Se ocorreu erro na conversao de alguma informacao
              IF vr_flgerro THEN
                --Proxima linha
                RAISE vr_exc_proximo;
              END IF;
            
              /**************************************************************/
              /*************TRATAMENTO P/ COBRANCA REGISTRADA****************/
              vr_index_crapcco := lpad(rw_crapcop.cdcooper, 10, '0') || lpad(vr_nrcnvcob, 10, '0');
              --Se nao existir convenio ignora linha
              IF NOT vr_tab_crapcco.EXISTS(vr_index_crapcco) THEN
                --Proxima linha
                RAISE vr_exc_proximo;
              END IF;
            
              --Verificar se foi migrado
              IF vr_tab_crapcco(vr_index_crapcco).cddbanco = rw_crapcop.cdbcoctl THEN
                /* Se for Viacredi, verificar se eh cooperado migrado */
                --Verificar se eh uma conta migrada
                IF vr_tab_craptco.EXISTS(vr_nrdconta) THEN
                  --Inicializar variavel erro
                  vr_cdcritic := 0;
                
                  -- verificar se o convenio do cooperado migrado possui convenio de cobranca
                  -- na cooperativa destino
                  OPEN cr_crapceb(pr_cdcooper => vr_tab_craptco(vr_nrdconta).cdcooper
                                 ,pr_nrdconta => vr_tab_craptco(vr_nrdconta).nrdconta
                                 ,pr_nrconven => vr_nrcnvcob);
                  FETCH cr_crapceb
                    INTO rw_crapceb;
                  --Indicar se encontrou ou nao
                  vr_crapceb := cr_crapceb%FOUND;
                  --Fechar Cursor
                  CLOSE cr_crapceb;
                
                  IF vr_crapceb = TRUE THEN
                    --Proxima linha
                    RAISE vr_exc_proximo;
                  ELSE
                  
                    vr_flgrejei := TRUE;
                  
                    --Escrever crítica no relatório
                    vr_cdcritic := 966;
                  
                    -- Criacao da tabela generica gncptit - utilizada na conciliacao 
                    -- Ajuste - 15/03/2018 - Chamado 801483
                    pc_insert_gncptit(pr_nrdispar => 3 -- Numero sequencial do dispare da prc 
                                     ,pr_idx      => idx
                                     ,pr_cdtipreg => 3 /* Sua Remessa - Erro */
                                     ,pr_flgconci => 1 /* registro conciliado */
                                     ,pr_flgpcctl => 0 /* processou na central */
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_flgpgdda => NULL
                                     ,pr_nrispbds => vr_nrispbif_rec
                                     ,pr_cdcriret => vr_cdcrignc
                                     ,pr_dscritic => vr_dscritic);
                  
                    IF NVL(vr_cdcrignc, 0) > 0 THEN
                      vr_cdcritic := vr_cdcrignc;
                      RAISE vr_exc_sair;
                    END IF;

                    /* create craprej */
                    BEGIN
                      INSERT INTO craprej
                        (craprej.dtmvtolt
                        ,craprej.cdagenci
                        ,craprej.vllanmto
                        ,craprej.nrseqdig
                        ,craprej.cdpesqbb
                        ,craprej.cdcritic
                        ,craprej.cdcooper
                        ,craprej.nrdconta
                        ,craprej.cdbccxlt
                        ,craprej.nrdocmto)
                      VALUES
                        (rw_crapdat.dtmvtolt
                        ,vr_cdagepag
                        ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 85, 12))) / 100
                        ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 151, 10)))
                        ,vr_setlinha
                        ,vr_cdcritic
                        ,pr_cdcooper
                        ,vr_nrdconta
                        ,vr_cdbanpag
                        ,vr_nrdocmto)
                      RETURNING craprej.dtmvtolt, craprej.cdagenci, craprej.vllanmto, craprej.nrseqdig, craprej.cdpesqbb, craprej.cdcritic, craprej.cdcooper, craprej.nrdconta, craprej.cdbccxlt, craprej.nrdocmto INTO rw_craprej.dtmvtolt, rw_craprej.cdagenci, rw_craprej.vllanmto, rw_craprej.nrseqdig, rw_craprej.cdpesqbb, rw_craprej.cdcritic, rw_craprej.cdcooper, rw_craprej.nrdconta, rw_craprej.cdbccxlt, rw_craprej.nrdocmto;
                    EXCEPTION
                      WHEN OTHERS THEN
                        -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
                        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                        -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483 
                        vr_cdcritic := 1034;
                        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                                       ' craprej(5):' || ' dtmvtolt:' || rw_crapdat.dtmvtolt ||
                                       ', cdagenci:' || vr_cdagepag || ', vllanmto:' ||
                                       TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 85, 12))) || ' / 100 ' ||
                                       ', nrseqdig:' ||
                                       TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 151, 10))) ||
                                       ', cdpesqbb:' || vr_setlinha || ', cdcritic:' || vr_cdcritic ||
                                       ', cdcooper:' || pr_cdcooper || ', nrdconta:' || vr_nrdconta ||
                                       ', cdbccxlt:' || vr_cdbanpag || ', nrdocmto:' || vr_nrdocmto || '. ' ||
                                       SQLERRM;
                        --Levantar Excecao
                        RAISE vr_exc_sair;
                    END;
                  
                    --Atualizar tabela memoria cratrej
                    pc_gera_cratrej(rw_craprej);
                    -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483                                            
                    IF TRIM(vr_dscritic) IS NOT NULL THEN
                      RAISE vr_exc_sair;
                    END IF;
                  
                    --> Gerar Devolucao
                    vr_cdmotdev := 73; --> 73 - Beneficiário sem contrato de cobrança com a instituição financeira Destinatária

                    --> Procedimento para grava registro de devolucao
                    pc_grava_devolucao(pr_cdcooper => rw_crapcop.cdcooper --> codigo da cooperativa
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> data do movimento
                                      ,pr_dtmvtopr => rw_crapdat.dtmvtopr --> data do próximo movimento
                                      ,pr_nrseqarq => vr_nrseqarq --> numero sequencial do arquivo da devolucao (cob615)
                                      ,pr_dscodbar => vr_dscodbar_ori --> codigo de barras
                                      ,pr_nrispbif => vr_nrispbif_rec --> numero do ispb recebedora
                                      ,pr_vlliquid => vr_vlliquid --> valor de liquidacao do titulo
                                      ,pr_dtocorre => vr_dtmvtolt --> data da ocorrencia da devolucao
                                      ,pr_nrdconta => vr_nrdconta --> numero da conta do cooperado
                                      ,pr_nrcnvcob => vr_nrcnvcob --> numero do convenio de cobranca do cooperado
                                      ,pr_nrdocmto => vr_nrdocmto --> numero do boleto de cobranca
                                      ,pr_cdmotdev => vr_cdmotdev --> codigo do motivo da devolucao
                                      ,pr_tpcaptur => vr_tpcaptur --> tipo de captura (cob615)
                                      ,pr_tpdocmto => vr_tpdocmto --> codigo do tipo de documento (cob615)
                                      ,pr_cdagerem => vr_cdagepag --> codigo da agencia do remetente (cob615)
                                      ,pr_dslinarq => vr_setlinha
                                      ,pr_cdcritic => vr_cdcritic -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483
                                      ,pr_dscritic => vr_dscritic);
                    IF TRIM(vr_dscritic) IS NOT NULL THEN
                      RAISE vr_exc_sair;
                    END IF;
                  
                    --Inicializar variavel erro
                    vr_cdcritic := 0;
                  
                    --Proxima linha
                    RAISE vr_exc_proximo;
                  
                  END IF;
                  
                END IF;
                --Se for Migracao
                IF UPPER(TRIM(vr_tab_crapcco(vr_index_crapcco).dsorgarq)) IN
                   ('MIGRACAO', 'INCORPORACAO') THEN
                  --Selecionar Convenio
                  OPEN cr_crabcco(pr_cdcooper => pr_cdcooper, pr_nrconven => vr_nrcnvcob);
                  FETCH cr_crabcco
                    INTO rw_crabcco;
                  --Se Encontrou
                  IF cr_crabcco%FOUND AND rw_crabcco.qtdreg = 1 THEN
                    CLOSE cr_crabcco;
                    --Selecionar Transferencias de Contas
                    OPEN cr_craptco_ant(pr_cdcooper => pr_cdcooper
                                       ,pr_cdcopant => rw_crabcco.cdcooper
                                       ,pr_nrctaant => vr_nrdconta
                                       ,pr_tpctatrf => 1
                                       ,pr_flgativo => 1);
                    FETCH cr_craptco_ant
                      INTO rw_craptco;
                    --Se encontrou
                    IF cr_craptco_ant%FOUND THEN
                      vr_nrdconta := rw_craptco.nrdconta;
                    ELSE
                      --Fechar Cursor
                      IF cr_craptco_ant%ISOPEN THEN
                        CLOSE cr_craptco_ant;
                      END IF;
                      -- o convenio for incorporacao/migracao e o
                      -- cooperado nao for encontrado na cooperativa, pular
                      -- para o proximo registro
                      RAISE vr_exc_proximo;
                    END IF;
                    --Fechar Cursor
                    IF cr_craptco_ant%ISOPEN THEN
                      CLOSE cr_craptco_ant;
                    END IF;
                  END IF;
                  --Fechar Cursor
                  IF cr_crabcco%ISOPEN THEN
                    CLOSE cr_crabcco;
                  END IF;
                END IF;
              
                --Selecionar Associado
                OPEN cr_crapass(pr_cdcooper => rw_crapcop.cdcooper, pr_nrdconta => vr_nrdconta);
                FETCH cr_crapass
                  INTO rw_crapass;
                --Indicar se encontrou ou nao
                vr_crapass := cr_crapass%FOUND;
                --Fechar Cursor
                CLOSE cr_crapass;
              
                --Se nao encontrou associado
                IF NOT vr_crapass THEN
                  vr_flgrejei := TRUE;
                
                  --Escrever crítica no relatório
                  vr_cdcritic := 9;
                
                  -- Criacao da tabela generica gncptit - utilizada na conciliacao 
                  -- Ajuste - 15/03/2018 - Chamado 801483
                  pc_insert_gncptit(pr_nrdispar => 4 -- Numero sequencial do dispare da prc 
                                   ,pr_idx      => idx
                                   ,pr_cdtipreg => 3 /* Sua Remessa - Erro */
                                   ,pr_flgconci => 1 /* registro conciliado */
                                   ,pr_flgpcctl => 0 /* processou na central */
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_flgpgdda => NULL
                                   ,pr_nrispbds => vr_nrispbif_rec
                                   ,pr_cdcriret => vr_cdcrignc
                                   ,pr_dscritic => vr_dscritic);
                
                  IF NVL(vr_cdcrignc, 0) > 0 THEN
                    vr_cdcritic := vr_cdcrignc;
                    RAISE vr_exc_sair;
                  END IF;
                
                  /* create craprej */
                  BEGIN
                    INSERT INTO craprej
                      (craprej.dtmvtolt
                      ,craprej.cdagenci
                      ,craprej.vllanmto
                      ,craprej.nrseqdig
                      ,craprej.cdpesqbb
                      ,craprej.cdcritic
                      ,craprej.cdcooper
                      ,craprej.nrdconta
                      ,craprej.cdbccxlt
                      ,craprej.nrdocmto)
                    VALUES
                      (rw_crapdat.dtmvtolt
                      ,vr_cdagepag
                      ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 85, 12))) / 100
                      ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 151, 10)))
                      ,vr_setlinha
                      ,vr_cdcritic
                      ,pr_cdcooper
                      ,vr_nrdconta
                      ,vr_cdbanpag
                      ,vr_nrdocmto)
                    RETURNING craprej.dtmvtolt, craprej.cdagenci, craprej.vllanmto, craprej.nrseqdig, craprej.cdpesqbb, craprej.cdcritic, craprej.cdcooper, craprej.nrdconta, craprej.cdbccxlt, craprej.nrdocmto INTO rw_craprej.dtmvtolt, rw_craprej.cdagenci, rw_craprej.vllanmto, rw_craprej.nrseqdig, rw_craprej.cdpesqbb, rw_craprej.cdcritic, rw_craprej.cdcooper, rw_craprej.nrdconta, rw_craprej.cdbccxlt, rw_craprej.nrdocmto;
                  EXCEPTION
                    WHEN OTHERS THEN
                      -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
                      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                      -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483 
                      vr_cdcritic := 1034;
                      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                                     ' craprej(6):' || ' dtmvtolt:' || rw_crapdat.dtmvtolt ||
                                     ', cdagenci:' || vr_cdagepag || ', vllanmto:' ||
                                     TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 85, 12))) || ' / 100 ' ||
                                     ', nrseqdig:' || TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 151, 10))) ||
                                     ', cdpesqbb:' || vr_setlinha || ', cdcritic:' || vr_cdcritic ||
                                     ', cdcooper:' || pr_cdcooper || ', nrdconta:' || vr_nrdconta ||
                                     ', cdbccxlt:' || vr_cdbanpag || ', nrdocmto:' || vr_nrdocmto || '. ' ||
                                     SQLERRM;
                      --Levantar Excecao
                      RAISE vr_exc_sair;
                  END;
                
                  --Atualizar tabela memoria cratrej
                  pc_gera_cratrej(rw_craprej);
                  -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483                                            
                  IF TRIM(vr_dscritic) IS NOT NULL THEN
                    RAISE vr_exc_sair;
                  END IF;
                
                  --> Gerar Devolucao
                  vr_cdmotdev := 73; --> 73 - Beneficiário sem contrato de cobrança com a instituição financeira Destinatária

                  --> Procedimento para grava registro de devolucao
                  pc_grava_devolucao(pr_cdcooper => rw_crapcop.cdcooper --> codigo da cooperativa
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> data do movimento
                                    ,pr_dtmvtopr => rw_crapdat.dtmvtopr --> data do próximo movimento
                                    ,pr_nrseqarq => vr_nrseqarq --> numero sequencial do arquivo da devolucao (cob615)
                                    ,pr_dscodbar => vr_dscodbar_ori --> codigo de barras
                                    ,pr_nrispbif => vr_nrispbif_rec --> numero do ispb recebedora
                                    ,pr_vlliquid => vr_vlliquid --> valor de liquidacao do titulo
                                    ,pr_dtocorre => vr_dtmvtolt --> data da ocorrencia da devolucao
                                    ,pr_nrdconta => vr_nrdconta --> numero da conta do cooperado
                                    ,pr_nrcnvcob => vr_nrcnvcob --> numero do convenio de cobranca do cooperado
                                    ,pr_nrdocmto => vr_nrdocmto --> numero do boleto de cobranca
                                    ,pr_cdmotdev => vr_cdmotdev --> codigo do motivo da devolucao
                                    ,pr_tpcaptur => vr_tpcaptur --> tipo de captura (cob615)
                                    ,pr_tpdocmto => vr_tpdocmto --> codigo do tipo de documento (cob615)
                                    ,pr_cdagerem => vr_cdagepag --> codigo da agencia do remetente (cob615)
                                    ,pr_dslinarq => vr_setlinha
                                    ,pr_cdcritic => vr_cdcritic -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483
                                    ,pr_dscritic => vr_dscritic);
                  IF TRIM(vr_dscritic) IS NOT NULL THEN
                    RAISE vr_exc_sair;
                  END IF;
                
                  --Inicializar variavel erro
                  vr_cdcritic := 0;
                  --Pular proxima linha arquivo
                  RAISE vr_exc_proximo;
                END IF; --vr_tab_crapass
              
                -- verificar se o convenio do cooperado está cadastrado
                OPEN cr_crapceb(pr_cdcooper => rw_crapcop.cdcooper
                               ,pr_nrdconta => vr_nrdconta
                               ,pr_nrconven => vr_nrcnvcob);
                FETCH cr_crapceb
                  INTO rw_crapceb;
                --Indicar se encontrou ou nao
                vr_crapceb := cr_crapceb%FOUND;
                --Fechar Cursor
                CLOSE cr_crapceb;
              
                IF NOT vr_crapceb THEN
                  -- cooperado sem convenio cadastrado
                  vr_cdcritic := 966;
                ELSE
                  /*RITM0083681*/
                  IF (rw_crapceb.flgcebhm = 0 AND rw_crapceb.flgapihm = 0) AND
                     (vr_tab_crapcco(vr_index_crapcco).dsorgarq = 'IMPRESSO PELO SOFTWARE' OR
                      vr_tab_crapcco(vr_index_crapcco).dsorgant = 'IMPRESSO PELO SOFTWARE') THEN
                    -- Convenio do cooperado nao homologado
                    vr_cdcritic := 965;
                  END IF;
                
                  -- Verificar se o Convenio do cooperado está bloqueado
                  IF rw_crapceb.insitceb = 4 THEN
                    -- bloqueado
                    vr_cdcritic := 980; --> 980 - Convenio do cooperado bloqueado
                  END IF;
                END IF;
              
                -- verificar se ocorreu alguma das criticas acima (965 ou 966)
                IF vr_cdcritic > 0 THEN
                
                  vr_flgrejei := TRUE;
                
                  -- Criacao da tabela generica gncptit - utilizada na conciliacao 
                  -- Ajuste - 15/03/2018 - Chamado 801483
                  pc_insert_gncptit(pr_nrdispar => 5 -- Numero sequencial do dispare da prc 
                                   ,pr_idx      => idx
                                   ,pr_cdtipreg => 3 /* Sua Remessa - Erro */
                                   ,pr_flgconci => 1 /* registro conciliado */
                                   ,pr_flgpcctl => 0 /* processou na central */
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_flgpgdda => NULL
                                   ,pr_nrispbds => vr_nrispbif_rec
                                   ,pr_cdcriret => vr_cdcrignc
                                   ,pr_dscritic => vr_dscritic);
                
                  IF NVL(vr_cdcrignc, 0) > 0 THEN
                    vr_cdcritic := vr_cdcrignc;
                    RAISE vr_exc_sair;
                  END IF;
                
                  /* create craprej */
                  BEGIN
                    INSERT INTO craprej
                      (craprej.dtmvtolt
                      ,craprej.cdagenci
                      ,craprej.vllanmto
                      ,craprej.nrseqdig
                      ,craprej.cdpesqbb
                      ,craprej.cdcritic
                      ,craprej.cdcooper
                      ,craprej.nrdconta
                      ,craprej.cdbccxlt
                      ,craprej.nrdocmto)
                    VALUES
                      (rw_crapdat.dtmvtolt
                      ,vr_cdagepag
                      ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 85, 12))) / 100
                      ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 151, 10)))
                      ,vr_setlinha
                      ,vr_cdcritic
                      ,pr_cdcooper
                      ,vr_nrdconta
                      ,vr_cdbanpag
                      ,vr_nrdocmto)
                    RETURNING craprej.dtmvtolt, craprej.cdagenci, craprej.vllanmto, craprej.nrseqdig, craprej.cdpesqbb, craprej.cdcritic, craprej.cdcooper, craprej.nrdconta, craprej.cdbccxlt, craprej.nrdocmto INTO rw_craprej.dtmvtolt, rw_craprej.cdagenci, rw_craprej.vllanmto, rw_craprej.nrseqdig, rw_craprej.cdpesqbb, rw_craprej.cdcritic, rw_craprej.cdcooper, rw_craprej.nrdconta, rw_craprej.cdbccxlt, rw_craprej.nrdocmto;
                  EXCEPTION
                    WHEN OTHERS THEN
                      -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
                      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                      -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483 
                      vr_cdcritic := 1034;
                      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                                     ' craprej(7):' || ' dtmvtolt:' || rw_crapdat.dtmvtolt ||
                                     ', cdagenci:' || vr_cdagepag || ', vllanmto:' ||
                                     TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 85, 12))) || ' / 100 ' ||
                                     ', nrseqdig:' || TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 151, 10))) ||
                                     ', cdpesqbb:' || vr_setlinha || ', cdcritic:' || vr_cdcritic ||
                                     ', cdcooper:' || pr_cdcooper || ', nrdconta:' || vr_nrdconta ||
                                     ', cdbccxlt:' || vr_cdbanpag || ', nrdocmto:' || vr_nrdocmto || '. ' ||
                                     SQLERRM;
                      --Levantar Excecao
                      RAISE vr_exc_sair;
                  END;
                
                  --Atualizar tabela memoria cratrej
                  pc_gera_cratrej(rw_craprej);
                  -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483                                            
                  IF TRIM(vr_dscritic) IS NOT NULL THEN
                    RAISE vr_exc_sair;
                  END IF;
                
                  IF vr_cdcritic IN (965, 966, 980) THEN
                    CASE vr_cdcritic
                      WHEN 965 THEN
                        vr_cdmotdev := 83; --> Boleto Inexistente na Base
                      WHEN 966 THEN
                        vr_cdmotdev := 83; --> Boleto Inexistente na Base
                      WHEN 980 THEN
                        vr_cdmotdev := 53; --> Apresentação indevida
                    END CASE;
                  
                    --> Procedimento para grava registro de devolucao
                    pc_grava_devolucao(pr_cdcooper => rw_crapcop.cdcooper --> codigo da cooperativa
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> data do movimento
                                      ,pr_dtmvtopr => rw_crapdat.dtmvtopr --> data do próximo movimento
                                      ,pr_nrseqarq => vr_nrseqarq --> numero sequencial do arquivo da devolucao (cob615)
                                      ,pr_dscodbar => vr_dscodbar_ori --> codigo de barras
                                      ,pr_nrispbif => vr_nrispbif_rec --> numero do ispb recebedora
                                      ,pr_vlliquid => vr_vlliquid --> valor de liquidacao do titulo
                                      ,pr_dtocorre => vr_dtmvtolt --> data da ocorrencia da devolucao
                                      ,pr_nrdconta => vr_nrdconta --> numero da conta do cooperado
                                      ,pr_nrcnvcob => vr_nrcnvcob --> numero do convenio de cobranca do cooperado
                                      ,pr_nrdocmto => vr_nrdocmto --> numero do boleto de cobranca
                                      ,pr_cdmotdev => vr_cdmotdev --> codigo do motivo da devolucao
                                      ,pr_tpcaptur => vr_tpcaptur --> tipo de captura (cob615)
                                      ,pr_tpdocmto => vr_tpdocmto --> codigo do tipo de documento (cob615)
                                      ,pr_cdagerem => vr_cdagepag --> codigo da agencia do remetente (cob615)
                                      ,pr_dslinarq => vr_setlinha
                                      ,pr_cdcritic => vr_cdcritic -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483
                                      ,pr_dscritic => vr_dscritic);
                    IF TRIM(vr_dscritic) IS NOT NULL THEN
                      RAISE vr_exc_sair;
                    END IF;
                  
                  END IF;
                
                  --Inicializar variavel erro
                  vr_cdcritic := 0;
                  --Pular proxima linha arquivo
                  RAISE vr_exc_proximo;
                END IF; --vr_crapaceb
              
                --limpar registro
                rw_crapcob := NULL;
              
                /* Validar se registro esta disponivel para pagto */
                OPEN cr_crapcob(pr_cdcooper => rw_crapcop.cdcooper
                               ,pr_cdbandoc => vr_tab_crapcco(vr_index_crapcco).cddbanco
                               ,pr_nrdctabb => vr_tab_crapcco(vr_index_crapcco).nrdctabb
                               ,pr_nrcnvcob => vr_nrcnvcob
                               ,pr_nrdconta => vr_nrdconta
                               ,pr_nrdocmto => vr_nrdocmto);
                FETCH cr_crapcob
                  INTO rw_crapcob;
                vr_fcrapcob := cr_crapcob%FOUND;
                CLOSE cr_crapcob;
              
                --Se nao encontrou
                IF vr_fcrapcob = FALSE AND
                   nvl(vr_tab_crapcco(vr_index_crapcco).dsorgarq, ' ') <> 'IMPRESSO PELO SOFTWARE' AND
                   nvl(vr_tab_crapcco(vr_index_crapcco).dsorgant, ' ') <> 'IMPRESSO PELO SOFTWARE' THEN
                
                  --Escrever mensagem de integracao no log
                  vr_flgrejei := TRUE;
                  vr_cdcritic := 592;
                
                  -- Criacao da tabela generica gncptit - utilizada na conciliacao 
                  -- Ajuste - 15/03/2018 - Chamado 801483
                  pc_insert_gncptit(pr_nrdispar => 6 -- Numero sequencial do dispare da prc 
                                   ,pr_idx      => idx
                                   ,pr_cdtipreg => 3 /* Sua Remessa - Erro */
                                   ,pr_flgconci => 1 /* registro conciliado */
                                   ,pr_flgpcctl => 0 /* processou na central */
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_flgpgdda => NULL
                                   ,pr_nrispbds => vr_nrispbif_rec
                                   ,pr_cdcriret => vr_cdcrignc
                                   ,pr_dscritic => vr_dscritic);
                
                  IF NVL(vr_cdcrignc, 0) > 0 THEN
                    vr_cdcritic := vr_cdcrignc;
                    RAISE vr_exc_sair;
                  END IF;
                
                  /* create craprej */
                  BEGIN
                    INSERT INTO craprej
                      (craprej.dtmvtolt
                      ,craprej.cdagenci
                      ,craprej.vllanmto
                      ,craprej.nrseqdig
                      ,craprej.cdpesqbb
                      ,craprej.cdcritic
                      ,craprej.cdcooper
                      ,craprej.nrdconta
                      ,craprej.cdbccxlt
                      ,craprej.nrdocmto)
                    VALUES
                      (rw_crapdat.dtmvtolt
                      ,vr_cdagepag
                      ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 85, 12))) / 100
                      ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 151, 10)))
                      ,vr_setlinha
                      ,vr_cdcritic
                      ,pr_cdcooper
                      ,vr_nrdconta
                      ,vr_cdbanpag
                      ,vr_nrdocmto)
                    RETURNING craprej.dtmvtolt, craprej.cdagenci, craprej.vllanmto, craprej.nrseqdig, craprej.cdpesqbb, craprej.cdcritic, craprej.cdcooper, craprej.nrdconta, craprej.cdbccxlt, craprej.nrdocmto INTO rw_craprej.dtmvtolt, rw_craprej.cdagenci, rw_craprej.vllanmto, rw_craprej.nrseqdig, rw_craprej.cdpesqbb, rw_craprej.cdcritic, rw_craprej.cdcooper, rw_craprej.nrdconta, rw_craprej.cdbccxlt, rw_craprej.nrdocmto;
                  EXCEPTION
                    WHEN OTHERS THEN
                      -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
                      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                      -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483 
                      vr_cdcritic := 1034;
                      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                                     ' craprej(8):' || ' dtmvtolt:' || rw_crapdat.dtmvtolt ||
                                     ', cdagenci:' || vr_cdagepag || ', vllanmto:' ||
                                     TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 85, 12))) || ' / 100 ' ||
                                     ', nrseqdig:' || TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 151, 10))) ||
                                     ', cdpesqbb:' || vr_setlinha || ', cdcritic:' || vr_cdcritic ||
                                     ', cdcooper:' || pr_cdcooper || ', nrdconta:' || vr_nrdconta ||
                                     ', cdbccxlt:' || vr_cdbanpag || ', nrdocmto:' || vr_nrdocmto || '. ' ||
                                     SQLERRM;
                      --Levantar Excecao
                      RAISE vr_exc_sair;
                  END;
                
                  --Atualizar tabela memoria cratrej
                  pc_gera_cratrej(rw_craprej);
                  -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483                                            
                  IF TRIM(vr_dscritic) IS NOT NULL THEN
                    RAISE vr_exc_sair;
                  END IF;
                
                  vr_cdmotdev := 83; --> Boleto Inexistente na Base
                
                  --> Procedimento para grava registro de devolucao
                  pc_grava_devolucao(pr_cdcooper => rw_crapcop.cdcooper --> codigo da cooperativa
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> data do movimento
                                    ,pr_dtmvtopr => rw_crapdat.dtmvtopr --> data do próximo movimento
                                    ,pr_nrseqarq => vr_nrseqarq --> numero sequencial do arquivo da devolucao (cob615)
                                    ,pr_dscodbar => vr_dscodbar_ori --> codigo de barras
                                    ,pr_nrispbif => vr_nrispbif_rec --> numero do ispb recebedora
                                    ,pr_vlliquid => vr_vlliquid --> valor de liquidacao do titulo
                                    ,pr_dtocorre => vr_dtmvtolt --> data da ocorrencia da devolucao
                                    ,pr_nrdconta => vr_nrdconta --> numero da conta do cooperado
                                    ,pr_nrcnvcob => vr_nrcnvcob --> numero do convenio de cobranca do cooperado
                                    ,pr_nrdocmto => vr_nrdocmto --> numero do boleto de cobranca
                                    ,pr_cdmotdev => vr_cdmotdev --> codigo do motivo da devolucao
                                    ,pr_tpcaptur => vr_tpcaptur --> tipo de captura (cob615)
                                    ,pr_tpdocmto => vr_tpdocmto --> codigo do tipo de documento (cob615)
                                    ,pr_cdagerem => vr_cdagepag --> codigo da agencia do remetente (cob615)
                                    ,pr_dslinarq => vr_setlinha
                                    ,pr_cdcritic => vr_cdcritic -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483
                                    ,pr_dscritic => vr_dscritic);
                  IF TRIM(vr_dscritic) IS NOT NULL THEN
                    RAISE vr_exc_sair;
                  END IF;
                
                  --Inicializar variavel erro
                  vr_cdcritic := 0;
                  --Pular proxima linha arquivo
                  RAISE vr_exc_proximo;
                END IF;
              
                --Se nao encontrou titulo do convenio 'IMPRESSO PELO SOFTWARE', então criar um título novo
                IF vr_fcrapcob = FALSE AND
                   (nvl(vr_tab_crapcco(vr_index_crapcco).dsorgarq, ' ') = 'IMPRESSO PELO SOFTWARE' OR
                   nvl(vr_tab_crapcco(vr_index_crapcco).dsorgant, ' ') = 'IMPRESSO PELO SOFTWARE') THEN
                
                  BEGIN
                    INSERT INTO crapcob
                      (cdcooper
                      ,nrdconta
                      ,nrcnvcob
                      ,nrdocmto
                      ,nrdctabb
                      ,cdbandoc
                      ,dtmvtolt
                      ,dtvencto
                      ,vltitulo
                      ,incobran
                      ,flgregis
                      ,vlabatim
                      ,vldescto
                      ,tpdmulta
                      ,tpjurmor
                      ,dsdoccop
                      ,flgdprot
                      ,dsinform
                      ,nrnosnum)
                    VALUES
                      (rw_crapcop.cdcooper
                      ,vr_nrdconta
                      ,vr_nrcnvcob
                      ,vr_nrdocmto
                      ,vr_tab_crapcco(vr_index_crapcco).nrdctabb
                      ,vr_tab_crapcco(vr_index_crapcco).cddbanco
                      ,rw_crapdat.dtmvtolt
                      ,rw_crapdat.dtmvtolt
                      ,TO_NUMBER(SUBSTR(vr_setlinha, 85, 12)) / 100
                      ,0 -- incobran
                      ,vr_tab_crapcco(vr_index_crapcco).flgregis
                      ,0 -- vlabatim
                      ,0 -- vldescto
                      ,3 -- tpdmulta
                      ,3 -- tpjurmor
                      ,to_char(vr_nrdocmto) -- dscodcop
                      ,0
                      ,'LIQAPOSBX' || substr(vr_setlinha, 1, 44)
                      ,TRIM(SUBSTR(vr_setlinha, 26, 17)));
                  EXCEPTION
                    WHEN OTHERS THEN
                      -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
                      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                      -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483 
                      vr_cdcritic := 1034;
                      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                                     ' crapcob(9):' || ' cdcooper:' || rw_crapcop.cdcooper ||
                                     ', nrdconta:' || vr_nrdconta || ', nrcnvcob:' || vr_nrcnvcob ||
                                     ', nrdocmto:' || vr_nrdocmto || ', nrdctabb:' || vr_tab_crapcco(vr_index_crapcco).nrdctabb ||
                                     ', cdbandoc:' || vr_tab_crapcco(vr_index_crapcco).cddbanco ||
                                     ', dtmvtolt:' || rw_crapdat.dtmvtolt || ', dtvencto:' ||
                                     rw_crapdat.dtmvtolt || ', vltitulo:' ||
                                     TO_NUMBER(SUBSTR(vr_setlinha, 85, 12)) || ' / 100 ' ||
                                     ', incobran:' || '0' || ', flgregis:' || vr_tab_crapcco(vr_index_crapcco).flgregis ||
                                     ', vlabatim:' || '0' || ', vldescto:' || '0' || ', tpdmulta:' || '3' ||
                                     ', tpjurmor:' || '3' || ', dsdoccop:' || to_char(vr_nrdocmto) ||
                                     ', flgdprot:' || '0' || ', dsinform:' || 'LIQAPOSBX' ||
                                     substr(vr_setlinha, 1, 44) || ', nrnosnum:' ||
                                     TRIM(SUBSTR(vr_setlinha, 26, 17)) || '. ' || SQLERRM;
                      --Levantar Excecao
                      RAISE vr_exc_sair;
                  END;
                
                  IF cr_crapcob%ISOPEN THEN
                    CLOSE cr_crapcob;
                  END IF;
                
                  /* Validar se registro esta disponivel para pagto */
                  OPEN cr_crapcob(pr_cdcooper => rw_crapcop.cdcooper
                                 ,pr_cdbandoc => vr_tab_crapcco(vr_index_crapcco).cddbanco
                                 ,pr_nrdctabb => vr_tab_crapcco(vr_index_crapcco).nrdctabb
                                 ,pr_nrcnvcob => vr_nrcnvcob
                                 ,pr_nrdconta => vr_nrdconta
                                 ,pr_nrdocmto => vr_nrdocmto);
                  FETCH cr_crapcob
                    INTO rw_crapcob;
                  -- liquidacao após baixa ou liquidação de título não registrado
                  vr_liqaposb := TRUE;
                END IF;
              
                --Fechar Cursor
                IF cr_crapcob%ISOPEN THEN
                  CLOSE cr_crapcob;
                END IF;
              
                --> Devolução de Pagamento Fraudado
                IF rw_crapcob.incobran = 2 THEN
                
                  -- Criacao da tabela generica gncptit - utilizada na conciliacao 
                  -- Ajuste - 15/03/2018 - Chamado 801483
                  pc_insert_gncptit(pr_nrdispar => 7 -- Numero sequencial do dispare da prc 
                                   ,pr_idx      => idx
                                   ,pr_cdtipreg => 3 /* Sua Remessa - Erro */
                                   ,pr_flgconci => 1 /* registro conciliado */
                                   ,pr_flgpcctl => 0 /* processou na central */
                                   ,pr_cdcritic => 980 /* Boleto bloqueado */
                                   ,pr_flgpgdda => NULL
                                   ,pr_nrispbds => vr_nrispbif_rec
                                   ,pr_cdcriret => vr_cdcrignc
                                   ,pr_dscritic => vr_dscritic);
                
                  IF NVL(vr_cdcrignc, 0) > 0 THEN
                    vr_cdcritic := vr_cdcrignc;
                    RAISE vr_exc_sair;
                  END IF;
                
                  vr_cdmotdev := 72; --> 72 - Devolução de Pagamento Fraudado
                
                  --> Procedimento para grava registro de devolucao
                  pc_grava_devolucao(pr_cdcooper => rw_crapcop.cdcooper --> codigo da cooperativa
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> data do movimento
                                    ,pr_dtmvtopr => rw_crapdat.dtmvtopr --> data do próximo movimento
                                    ,pr_nrseqarq => vr_nrseqarq --> numero sequencial do arquivo da devolucao (cob615)
                                    ,pr_dscodbar => vr_dscodbar_ori --> codigo de barras
                                    ,pr_nrispbif => vr_nrispbif_rec --> numero do ispb recebedora
                                    ,pr_vlliquid => vr_vlliquid --> valor de liquidacao do titulo
                                    ,pr_dtocorre => vr_dtmvtolt --> data da ocorrencia da devolucao
                                    ,pr_nrdconta => vr_nrdconta --> numero da conta do cooperado
                                    ,pr_nrcnvcob => vr_nrcnvcob --> numero do convenio de cobranca do cooperado
                                    ,pr_nrdocmto => vr_nrdocmto --> numero do boleto de cobranca
                                    ,pr_cdmotdev => vr_cdmotdev --> codigo do motivo da devolucao
                                    ,pr_tpcaptur => vr_tpcaptur --> tipo de captura (cob615)
                                    ,pr_tpdocmto => vr_tpdocmto --> codigo do tipo de documento (cob615)
                                    ,pr_cdagerem => vr_cdagepag --> codigo da agencia do remetente (cob615)
                                    ,pr_dslinarq => vr_setlinha
                                    ,pr_cdcritic => vr_cdcritic -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483
                                    ,pr_dscritic => vr_dscritic);
                  IF TRIM(vr_dscritic) IS NOT NULL THEN
                    RAISE vr_exc_sair;
                  END IF;
                  --> processar proximo registro
                  RAISE vr_exc_proximo;
                
                END IF;
              
                -- se o boleto de emprestimo ja foi pago ou baixado, será devolvido no crrl574
                IF rw_crapcob.incobran IN (3, 5) AND
                   vr_tab_crapcco(vr_index_crapcco).dsorgarq IN ('EMPRESTIMO', 'ACORDO', 'DESCONTO DE TITULO') THEN
                
                  -- Criacao da tabela generica gncptit - utilizada na conciliacao 
                  -- Ajuste - 15/03/2018 - Chamado 801483
                  pc_insert_gncptit(pr_nrdispar => 8 -- Numero sequencial do dispare da prc 
                                   ,pr_idx      => idx
                                   ,pr_cdtipreg => 5 /* Sua Remessa - Erro */
                                   ,pr_flgconci => 1 /* registro conciliado */
                                   ,pr_flgpcctl => 0 /* processou na central */
                                   ,pr_cdcritic => 969 /* integrado c/ erro - boleto de emprestimo nao processado */
                                   ,pr_flgpgdda => NULL
                                   ,pr_nrispbds => vr_nrispbif_rec
                                   ,pr_cdcriret => vr_cdcrignc
                                   ,pr_dscritic => vr_dscritic);
                
                  IF NVL(vr_cdcrignc, 0) > 0 THEN
                    vr_cdcritic := vr_cdcrignc;
                    RAISE vr_exc_sair;
                  END IF;
                
                  --> Gerar Devolucao
                  vr_cdmotdev := 53; --> 53 - Apresentação indevida
                
                  --> Procedimento para grava registro de devolucao
                  pc_grava_devolucao(pr_cdcooper => rw_crapcop.cdcooper --> codigo da cooperativa
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> data do movimento
                                    ,pr_dtmvtopr => rw_crapdat.dtmvtopr --> data do próximo movimento
                                    ,pr_nrseqarq => vr_nrseqarq --> numero sequencial do arquivo da devolucao (cob615)
                                    ,pr_dscodbar => vr_dscodbar_ori --> codigo de barras
                                    ,pr_nrispbif => vr_nrispbif_rec --> numero do ispb recebedora
                                    ,pr_vlliquid => vr_vlliquid --> valor de liquidacao do titulo
                                    ,pr_dtocorre => vr_dtmvtolt --> data da ocorrencia da devolucao
                                    ,pr_nrdconta => vr_nrdconta --> numero da conta do cooperado
                                    ,pr_nrcnvcob => vr_nrcnvcob --> numero do convenio de cobranca do cooperado
                                    ,pr_nrdocmto => vr_nrdocmto --> numero do boleto de cobranca
                                    ,pr_cdmotdev => vr_cdmotdev --> codigo do motivo da devolucao
                                    ,pr_tpcaptur => vr_tpcaptur --> tipo de captura (cob615)
                                    ,pr_tpdocmto => vr_tpdocmto --> codigo do tipo de documento (cob615)
                                    ,pr_cdagerem => vr_cdagepag --> codigo da agencia do remetente (cob615)
                                    ,pr_dslinarq => vr_setlinha
                                    ,pr_cdcritic => vr_cdcritic -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483
                                    ,pr_dscritic => vr_dscritic);
                  IF TRIM(vr_dscritic) IS NOT NULL THEN
                    RAISE vr_exc_sair;
                  END IF;
                
                  RAISE vr_exc_proximo;
                END IF;
              
                /* Aceita titulos em aberto e baixado. Títulos já pagos, são devolvidos */
                IF rw_crapcob.incobran = 5 THEN
                  --Rejeitado
                  vr_flgrejei := TRUE;
                  /* Repasse em Duplicidade pela IF Recebedora */
                  vr_cdcritic := 1514;
                  --                  
                  pc_insert_gncptit(pr_nrdispar => 13 -- Numero sequencial do dispare da prc 
                                   ,pr_idx      => idx
                                   ,pr_cdtipreg => 3 /* Sua Remessa - Erro */
                                   ,pr_flgconci => 1 /* registro conciliado */
                                   ,pr_flgpcctl => 0 /* processou na central */
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_flgpgdda => NULL
                                   ,pr_nrispbds => vr_nrispbif_rec
                                   ,pr_cdcriret => vr_cdcrignc
                                   ,pr_dscritic => vr_dscritic);  
                  IF NVL(vr_cdcrignc, 0) > 0 THEN
                    vr_cdcritic := vr_cdcrignc;
                    RAISE vr_exc_sair;
                  END IF;                                                   
                  --
                  BEGIN
                    INSERT INTO craprej
                      (craprej.dtmvtolt
                      ,craprej.cdagenci
                      ,craprej.vllanmto
                      ,craprej.nrseqdig
                      ,craprej.cdpesqbb
                      ,craprej.cdcritic
                      ,craprej.cdcooper
                      ,craprej.nrdconta
                      ,craprej.cdbccxlt
                      ,craprej.nrdocmto)
                    VALUES
                      (rw_crapdat.dtmvtolt
                      ,vr_cdagepag
                      ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 85, 12))) / 100
                      ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 151, 10)))
                      ,vr_setlinha
                      ,vr_cdcritic
                      ,pr_cdcooper
                      ,vr_nrdconta
                      ,vr_cdbanpag
                      ,vr_nrdocmto)
                    RETURNING craprej.dtmvtolt, craprej.cdagenci, craprej.vllanmto, craprej.nrseqdig, craprej.cdpesqbb, craprej.cdcritic, craprej.cdcooper, craprej.nrdconta, craprej.cdbccxlt, craprej.nrdocmto INTO rw_craprej.dtmvtolt, rw_craprej.cdagenci, rw_craprej.vllanmto, rw_craprej.nrseqdig, rw_craprej.cdpesqbb, rw_craprej.cdcritic, rw_craprej.cdcooper, rw_craprej.nrdconta, rw_craprej.cdbccxlt, rw_craprej.nrdocmto;
                  EXCEPTION
                    WHEN OTHERS THEN
                      --
                      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                      --
                      vr_cdcritic := 1034;
                      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                                     ' craprej(10):' || ' dtmvtolt:' || rw_crapdat.dtmvtolt ||
                                     ', cdagenci:' || vr_cdagepag || ', vllanmto:' ||
                                     TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 85, 12))) || ' / 100 ' ||
                                     ', nrseqdig:' || TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 151, 10))) ||
                                     ', cdpesqbb:' || vr_setlinha || ', cdcritic:' || vr_cdcritic ||
                                     ', cdcooper:' || pr_cdcooper || ', nrdconta:' || vr_nrdconta ||
                                     ', cdbccxlt:' || vr_cdbanpag || ', nrdocmto:' || vr_nrdocmto || '. ' ||
                                     SQLERRM;
                      --
                      RAISE vr_exc_sair;
                  END;
                  --
                  pc_gera_cratrej(rw_craprej);
                  --
                  IF TRIM(vr_dscritic) IS NOT NULL THEN
                    RAISE vr_exc_sair;
                  END IF;
                  --
                  vr_cdmotdev := 68; -- Repasse em Duplicidade pela IF Recebedora
                  --
                  pc_grava_devolucao(pr_cdcooper => rw_crapcop.cdcooper --> codigo da cooperativa
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> data do movimento
                                    ,pr_dtmvtopr => rw_crapdat.dtmvtopr --> data do próximo movimento
                                    ,pr_nrseqarq => vr_nrseqarq --> numero sequencial do arquivo da devolucao (cob615)
                                    ,pr_dscodbar => vr_dscodbar_ori --> codigo de barras
                                    ,pr_nrispbif => vr_nrispbif_rec --> numero do ispb recebedora
                                    ,pr_vlliquid => vr_vlliquid --> valor de liquidacao do titulo
                                    ,pr_dtocorre => vr_dtmvtolt --> data da ocorrencia da devolucao
                                    ,pr_nrdconta => vr_nrdconta --> numero da conta do cooperado
                                    ,pr_nrcnvcob => vr_nrcnvcob --> numero do convenio de cobranca do cooperado
                                    ,pr_nrdocmto => vr_nrdocmto --> numero do boleto de cobranca
                                    ,pr_cdmotdev => vr_cdmotdev --> codigo do motivo da devolucao
                                    ,pr_tpcaptur => vr_tpcaptur --> tipo de captura (cob615)
                                    ,pr_tpdocmto => vr_tpdocmto --> codigo do tipo de documento (cob615)
                                    ,pr_cdagerem => vr_cdagepag --> codigo da agencia do remetente (cob615)
                                    ,pr_dslinarq => vr_setlinha
                                    ,pr_cdcritic => vr_cdcritic -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483
                                    ,pr_dscritic => vr_dscritic);
                  IF TRIM(vr_dscritic) IS NOT NULL THEN
                    RAISE vr_exc_sair;
                  END IF;
                
                  vr_cdcritic := 0;
                  
                  RAISE vr_exc_proximo;
                 
                END IF;
                /* se titulo baixado p/ protesto (941) ou baixado (943), criticar... */
                IF nvl(rw_crapcob.flgregis, 0) = 1 AND rw_crapcob.incobran = 3 AND
                   rw_crapcob.insitcrt IN (0, 1) THEN
                  /* flg para realizar liquidacao apos baixa */
                  vr_liqaposb := TRUE;
                  IF rw_crapcob.insitcrt = 1 THEN
                  
                    vr_cdcritic := 941;
                    /* se existir informacao do titulo enviado p/ protesto */
                    IF TRIM(rw_crapcob.cdtitprt) IS NOT NULL THEN
                      --Inicializar Valor Despesas
                    
                      --Selecionar Convenio
                      OPEN cr_crabcco2(pr_cdcooper => gene0002.fn_busca_entrada(1
                                                                               ,rw_crapcob.cdtitprt
                                                                               ,';')
                                      ,pr_nrconven => gene0002.fn_busca_entrada(3
                                                                               ,rw_crapcob.cdtitprt
                                                                               ,';'));
                      FETCH cr_crabcco2
                        INTO rw_crabcco;
                      --Se Encontrou Convenio
                      IF cr_crabcco2%FOUND AND rw_crabcco.qtdreg = 1 THEN
                        --Fechar Cursor
                        CLOSE cr_crabcco2;
                        --Encontrar Cobrancas
                        OPEN cr_crapcob(pr_cdcooper => gene0002.fn_busca_entrada(1
                                                                                ,rw_crapcob.cdtitprt
                                                                                ,';')
                                       ,pr_nrdconta => gene0002.fn_busca_entrada(2
                                                                                ,rw_crapcob.cdtitprt
                                                                                ,';')
                                       ,pr_nrcnvcob => gene0002.fn_busca_entrada(3
                                                                                ,rw_crapcob.cdtitprt
                                                                                ,';')
                                       ,pr_nrdocmto => gene0002.fn_busca_entrada(4
                                                                                ,rw_crapcob.cdtitprt
                                                                                ,';')
                                       ,pr_nrdctabb => rw_crabcco.nrdctabb
                                       ,pr_cdbandoc => rw_crabcco.cddbanco);
                        FETCH cr_crapcob
                          INTO rw_crabcob;
                        --Se encontrou
                        IF cr_crapcob%FOUND THEN
                          --Fechar Cursor
                          CLOSE cr_crapcob;
                          -- Ajusta o parametro com a regra de evitar o nulo - 21/03/2019 - REQ0037942  
                          --Determinar a data para sustar
                          IF vr_nmtelant = 'COMPEFORA' THEN
                            vr_dtmvtaux := rw_crapdat.dtmvtolt;
                          ELSE
                            vr_dtmvtaux := rw_crapdat.dtmvtopr;
                          END IF;
                          /* Sustar a baixa */
                          COBR0007.pc_inst_sustar_baixar(pr_cdcooper            => rw_crabcob.cdcooper --Codigo Cooperativa
                                                        ,pr_nrdconta            => rw_crabcob.nrdconta --Numero da Conta
                                                        ,pr_nrcnvcob            => rw_crabcob.nrcnvcob --Numero Convenio
                                                        ,pr_nrdocmto            => rw_crabcob.nrdocmto --Numero Documento
                                                        ,pr_dtmvtolt            => vr_dtmvtaux --Data pagamento
                                                        ,pr_cdoperad            => ct_cdoperad --Operador
                                                        ,pr_nrremass            => 0 --Numero Remessa
                                                        ,pr_tab_lat_consolidada => vr_tab_lat_consolidada
                                                        ,pr_cdcritic            => vr_cdcritic2
                                                        ,pr_dscritic            => vr_dscritic2);
                        
                          --Se ocorreu erro
                          IF vr_cdcritic2 IS NOT NULL OR vr_dscritic2 IS NOT NULL THEN
                            --  vr_cdcritic:= vr_cdcritic2;
                            --  vr_dscritic:= vr_dscritic2;
                            --Levantar Excecao
                            --  RAISE vr_exc_sair;
                            NULL;
                          END IF;
                          /* Gerar LOG 085*/
                          PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --ROWID da Cobranca
                                                       ,pr_cdoperad => ct_cdoperad --Operador
                                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data movimento
                                                       ,pr_dsmensag => 'Liquidacao apos baixa' --Descricao Mensagem
                                                       ,pr_des_erro => vr_des_erro --Indicador erro
                                                       ,pr_dscritic => vr_dscritic2); --Descricao erro
                          --Se ocorreu erro
                          IF vr_des_erro = 'NOK' THEN
                            -- Ajuste Mensagem - 15/03/2018 - Chamado 801483 
                            vr_cdcritic := 1197;
                            vr_dscritic := vr_dscritic2 || ' - PAGA0001.pc_cria_log_cobranca';
                            --Levantar Excecao
                            RAISE vr_exc_sair;
                          END IF;
                          /* Gerar LOG 001 [BB]*/
                          PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crabcob.rowid --ROWID da Cobranca
                                                       ,pr_cdoperad => ct_cdoperad --Operador
                                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data movimento
                                                       ,pr_dsmensag => 'Liquidacao do boleto no convenio 085' --Descricao Mensagem
                                                       ,pr_des_erro => vr_des_erro --Indicador erro
                                                       ,pr_dscritic => vr_dscritic2); --Descricao erro
                          --Se ocorreu erro
                          IF vr_des_erro = 'NOK' THEN
                            -- Ajuste Mensagem - 15/03/2018 - Chamado 801483 
                            vr_cdcritic := 1197;
                            vr_dscritic := vr_dscritic2 || ' - PAGA0001.pc_cria_log_cobranca';
                            --Levantar Excecao
                            RAISE vr_exc_sair;
                          END IF;
                        
                        END IF; --cr_crapcob%FOUND
                        --Fechar Cursor
                        IF cr_crapcob%ISOPEN THEN
                          CLOSE cr_crapcob;
                        END IF;
                      END IF; --cr_crabcco%FOUND
                      --Fechar Cursor
                      IF cr_crabcco2%ISOPEN THEN
                        CLOSE cr_crabcco2;
                      END IF;
                    
                      --Se valor despesa > 0 e
                      --se valor despeza > que Valor Minimo CAC
                      IF nvl(vr_vldescar, 0) > 0 AND nvl(vr_vldescar, 0) >= vr_vlrmincac THEN
                        --Selecionar nome sacado
                        OPEN cr_crapsab(pr_cdcooper => rw_crapcob.cdcooper
                                       ,pr_nrdconta => rw_crapcob.nrdconta
                                       ,pr_nrinssac => rw_crapcob.nrinssac);
                        FETCH cr_crapsab
                          INTO rw_crapsab;
                        --Indicar se encontrou ou nao
                        vr_crapsab := cr_crapsab%FOUND;
                        --Fechar Cursor
                        CLOSE cr_crapsab;
                        --Se nao encontrou
                        IF NOT vr_crapsab THEN
                          rw_crapsab.nmdsacad := NULL;
                        END IF;
                      
                        -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483 
                        /* Alimenta o rel. 618 */
                        --Gravar dados na tabela work  
                        pc_insere_tbgen_batch_rel_wrk(pr_cdcooper    => rw_crapcob.cdcooper
                                                     ,pr_CDPROGRAMA  => ct_cdprogra
                                                     ,pr_DSRELATORIO => 'REL618'
                                                     ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                                     ,pr_cdagenci    => vr_cdagepag
                                                     ,pr_DSCHAVE     => lpad(to_char(vr_cdbanpag
                                                                                    ,'fm000')
                                                                            ,10
                                                                            ,'0') ||
                                                                        rpad(TRIM(rw_crapsab.nmdsacad)
                                                                            ,50
                                                                            ,'#') ||
                                                                        lpad(to_char(rw_crabcob.vltitulo * 100)
                                                                            ,25
                                                                            ,'0')
                                                     ,pr_NRDCONTA    => NULL
                                                     ,pr_NRCNVCOB    => NULL
                                                     ,pr_NRDOCMTO    => NULL
                                                     ,pr_NRCTREMP    => NULL
                                                     ,pr_DSDOCCOP    => rw_crabcob.dsdoccop
                                                     ,pr_TPPARCEL    => NULL
                                                     ,pr_DTVENCTO    => rw_crabcob.dtvencto
                                                     ,pr_VLTITULO    => rw_crabcob.vltitulo
                                                     ,pr_VLDPAGTO    => TRUNC((nvl(rw_crabcob.vldescto
                                                                                  ,0) +
                                                                              nvl(rw_crabcob.vlabatim
                                                                                  ,0))
                                                                             ,2)
                                                     ,pr_DSXML       => TO_CHAR(vr_cdbanpag
                                                                               ,'fm000') ||
                                                                        to_char(vr_cdbanpag
                                                                               ,'fm000') || '/' ||
                                                                        to_char(vr_cdagepag
                                                                               ,'fm0000') ||
                                                                        to_char(nvl(rw_crabcob.nrinssac
                                                                                   ,0)
                                                                               ,'fm000000000000000') ||
                                                                        rpad(rw_crapsab.nmdsacad
                                                                            ,50) ||
                                                                        rpad(SUBSTR(vr_setlinha
                                                                                   ,01
                                                                                   ,44)
                                                                            ,50) ||
                                                                        to_char(TRUNC(nvl(vr_vlrjuros
                                                                                         ,0) +
                                                                                      nvl(vr_vlrmulta
                                                                                         ,0)
                                                                                     ,2)
                                                                               ,'fm000000000000000D0000') ||
                                                                        to_char(TO_NUMBER(TRIM(SUBSTR(vr_setlinha
                                                                                                     ,85
                                                                                                     ,12))) / 100
                                                                               ,'fm000000000000000D0000') ||
                                                                        to_char(0
                                                                               ,'fm00000000000000000D00') ||
                                                                        to_char(vr_vldescar
                                                                               ,'fm00000000000000000D00') ||
                                                                        to_char(rw_crapass.inpessoa
                                                                               ,'fm00000')
                                                     ,pr_dscrient    => NULL
                                                     ,pr_cdcrisai    => vr_cdcritic
                                                     ,pr_dscrisai    => vr_dscritic);
                        IF NVL(vr_cdcritic, 0) > 0 THEN
                          RAISE vr_exc_saida;
                        END IF;
                      
                      END IF; -- vr_vldescar > 0
                    END IF; --rw_crapcob.cdtitprt IS NOT NULL
                  ELSIF rw_crapcob.insitcrt = 0 THEN
                    vr_cdcritic := 943;
                    /* Gerar LOG 085 */
                    IF nvl(rw_crapcob.flgregis, 0) = 1 THEN
                      --Criar log Cobranca
                      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --ROWID da Cobranca
                                                   ,pr_cdoperad => ct_cdoperad --Operador
                                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data movimento
                                                   ,pr_dsmensag => 'Liquidacao apos baixa' --Descricao Mensagem
                                                   ,pr_des_erro => vr_des_erro --Indicador erro
                                                   ,pr_dscritic => vr_dscritic2); --Descricao erro
                      --Se ocorreu erro
                      IF vr_des_erro = 'NOK' THEN
                        -- Ajuste Mensagem - 15/03/2018 - Chamado 801483 
                        vr_cdcritic := 1197;
                        vr_dscritic := vr_dscritic2 || ' - PAGA0001.pc_cria_log_cobranca';
                        --Levantar Excecao
                        RAISE vr_exc_sair;
                      END IF;
                    END IF;
                  END IF; --rw_crapcob.insitcrt = 1
                  --Buscar descricao critica
                  vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                  /* create craprej */
                  BEGIN
                    INSERT INTO craprej
                      (craprej.dtmvtolt
                      ,craprej.cdagenci
                      ,craprej.vllanmto
                      ,craprej.nrseqdig
                      ,craprej.cdpesqbb
                      ,craprej.cdcritic
                      ,craprej.cdcooper
                      ,craprej.nrdconta
                      ,craprej.cdbccxlt
                      ,craprej.nrdocmto)
                    VALUES
                      (rw_crapdat.dtmvtolt
                      ,vr_cdagepag
                      ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 85, 12))) / 100
                      ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 151, 10)))
                      ,vr_setlinha
                      ,vr_cdcritic
                      ,pr_cdcooper
                      ,vr_nrdconta
                      ,vr_cdbanpag
                      ,vr_nrdocmto)
                    RETURNING craprej.dtmvtolt, craprej.cdagenci, craprej.vllanmto, craprej.nrseqdig, craprej.cdpesqbb, craprej.cdcritic, craprej.cdcooper, craprej.nrdconta, craprej.cdbccxlt, craprej.nrdocmto INTO rw_craprej.dtmvtolt, rw_craprej.cdagenci, rw_craprej.vllanmto, rw_craprej.nrseqdig, rw_craprej.cdpesqbb, rw_craprej.cdcritic, rw_craprej.cdcooper, rw_craprej.nrdconta, rw_craprej.cdbccxlt, rw_craprej.nrdocmto;
                  EXCEPTION
                    WHEN OTHERS THEN
                      -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
                      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                      -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483 
                      vr_cdcritic := 1034;
                      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                                     ' craprej(11):' || ' dtmvtolt:' || rw_crapdat.dtmvtolt ||
                                     ', cdagenci:' || vr_cdagepag || ', vllanmto:' ||
                                     TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 85, 12))) || ' / 100 ' ||
                                     ', nrseqdig:' || TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 151, 10))) ||
                                     ', cdpesqbb:' || vr_setlinha || ', cdcritic:' || vr_cdcritic ||
                                     ', cdcooper:' || pr_cdcooper || ', nrdconta:' || vr_nrdconta ||
                                     ', cdbccxlt:' || vr_cdbanpag || ', nrdocmto:' || vr_nrdocmto || '. ' ||
                                     SQLERRM;
                      --Levantar Excecao
                      RAISE vr_exc_sair;
                  END;
                  --Atualizar tabela memoria cratrej
                  pc_gera_cratrej(rw_craprej);
                  -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483                                            
                  IF TRIM(vr_dscritic) IS NOT NULL THEN
                    RAISE vr_exc_sair;
                  END IF;
                
                  --Inicializar variaveis erro
                  vr_cdcritic := 0;
                  vr_dscritic := NULL;
                END IF; --protesto (941 e 943)
                /* Este mesmo calculo eh usado na b2crap14, caso alterar aqui
                nao esquecer de alterar la tambem */
                /* variaveis de calculo cobranca registrada */
                vr_vlrjuros := 0;
                vr_vlrmulta := 0;
                vr_vldescto := 0;
                vr_vlabatim := rw_crapcob.vlabatim;
                vr_vlfatura := rw_crapcob.vltitulo;
              
                -- Excluido pc_verifica_vencto_titulo - 15/03/2018 - Chamado 801483 
              
                -- Ajusta o parametro com a regra de evitar o nulo - 21/03/2019 - REQ0037942                   
                IF vr_nmtelant = 'COMPEFORA' THEN
                  vr_dtrefere := rw_crapdat.dtmvtoan;
                ELSE
                  vr_dtrefere := rw_crapdat.dtmvtolt;
                END IF;
              
                --Verificar Vencimento Titulo
                pc_verifica_vencto(pr_cdcooper => rw_crapcop.cdcooper --Codigo da cooperativa
                                  ,pr_dtmvtolt => vr_dtrefere --Data para verificacao
                                  ,pr_cddbanco => vr_cdbanpag --Codigo do Banco
                                  ,pr_cdagenci => vr_cdagepag --Codigo da Agencia
                                  ,pr_dtboleto => rw_crapcob.dtvencto --Data do Titulo
                                  ,pr_flgvenci => vr_flgvenci --Indicador titulo vencido
                                  ,pr_cdcritic => vr_cdcritic --Codigo do erro
                                  ,pr_dscritic => vr_dscritic); --Descricao do erro
              
                --Se ocorreu erro
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  /* nao criticar possiveis problemas do calculo de vencimento */
                  -- Gravar no Log o problema ignorado - 15/03/2018 - Chamado 801483             
                  cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                        ,pr_cdagenci => pr_cdagenci
                                        ,pr_cdprogra => ct_cdprogra
                                        ,pr_idprglog => vr_idprglog
                                        ,pr_dstiplog => 'E'
                                        ,pr_tpocorre => 2
                                        ,pr_dscritic => vr_dscritic
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_cdcricid => 2);
                  vr_cdcritic := NULL;
                  vr_dscritic := NULL;
                END IF;
              
                /* calculo de abatimento deve ser antes da aplicacao de juros e multa */
                IF nvl(vr_vlabatim, 0) > 0 THEN
                  --Diminuir valor do abatimento na fatura
                  vr_vlfatura := nvl(vr_vlfatura, 0) - nvl(vr_vlabatim, 0);
                END IF;
                /* trata o desconto se concede apos o vencimento */
                IF rw_crapcob.cdmensag = 2 THEN
                  --Valor desconto recebe valor bordero cobranca
                  vr_vldescto := rw_crapcob.vldescto;
                  --Diminuir valor dodesconto na fatura
                  vr_vlfatura := nvl(vr_vlfatura, 0) - nvl(vr_vldescto, 0);
                END IF;
                /* verifica se o titulo esta vencido */
                IF vr_flgvenci THEN
                  --
                  /*calculo do juro, multa e valor do título com juros e multa*/
                  cxon0014.pc_calcula_vlr_titulo_vencido(pr_vltitulo      => vr_vlfatura
                                                        ,pr_tpdmulta      => rw_crapcob.tpdmulta
                                                        ,pr_vlrmulta      => rw_crapcob.vlrmulta
                                                        ,pr_tpjurmor      => rw_crapcob.tpjurmor
                                                        ,pr_vljurdia      => rw_crapcob.vljurdia
                                                        ,pr_qtdiavenc     => (vr_dtmvtolt -
                                                                             rw_crapcob.dtvencto)
                                                        ,pr_vlfatura      => vr_vlfatura
                                                        ,pr_vlrmulta_calc => vr_vlrmulta
                                                        ,pr_vlrjuros_calc => vr_vlrjuros
                                                        ,pr_dscritic      => vr_dscritic);
                  --
                  IF TRIM(vr_dscritic) IS NOT NULL THEN
                    --Levantar Excecao
                    RAISE vr_exc_sair;
                  END IF;
                  --
                ELSE
                  /* se concede apos vencto, ja calculou */
                  IF rw_crapcob.cdmensag <> 2 THEN
                    --Valor desconto
                    vr_vldescto := nvl(rw_crapcob.vldescto, 0);
                    --Diminuir o desconto da fatura
                    vr_vlfatura := nvl(vr_vlfatura, 0) - nvl(vr_vldescto, 0);
                  END IF;
                END IF; --vr_flgvenci
              
                /* se pagou valor menor ou vencido e é do convenio EMPRESTIMO ou Desconto de Titulo */
                IF (TRUNC(vr_vlliquid, 2) < TRUNC(vr_vlfatura, 2) OR vr_flgvenci) AND
                   vr_tab_crapcco(vr_index_crapcco).dsorgarq IN ('EMPRESTIMO', 'DESCONTO DE TITULO') THEN
                
                  -- Criacao da tabela generica gncptit - utilizada na conciliacao 
                  -- Ajuste - 15/03/2018 - Chamado 801483
                  pc_insert_gncptit(pr_nrdispar => 9 -- Numero sequencial do dispare da prc 
                                   ,pr_idx      => idx
                                   ,pr_cdtipreg => 5 /* Sua Remessa - Erro */
                                   ,pr_flgconci => 1 /* registro conciliado */
                                   ,pr_flgpcctl => 0 /* processou na central */
                                   ,pr_cdcritic => 969 /* integrado c/ erro - boleto de emprestimo nao processado */
                                   ,pr_flgpgdda => NULL
                                   ,pr_nrispbds => vr_nrispbif_rec
                                   ,pr_cdcriret => vr_cdcrignc
                                   ,pr_dscritic => vr_dscritic);
                
                  IF NVL(vr_cdcrignc, 0) > 0 THEN
                    vr_cdcritic := vr_cdcrignc;
                    RAISE vr_exc_sair;
                  END IF;
                
                  --> Gerar Devolucao
                  vr_cdmotdev := 82; --> Boleto divergente da base
                
                  --> Procedimento para grava registro de devolucao
                  pc_grava_devolucao(pr_cdcooper => rw_crapcop.cdcooper --> codigo da cooperativa
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> data do movimento
                                    ,pr_dtmvtopr => rw_crapdat.dtmvtopr --> data do próximo movimento
                                    ,pr_nrseqarq => vr_nrseqarq --> numero sequencial do arquivo da devolucao (cob615)
                                    ,pr_dscodbar => vr_dscodbar_ori --> codigo de barras
                                    ,pr_nrispbif => vr_nrispbif_rec --> numero do ispb recebedora
                                    ,pr_vlliquid => vr_vlliquid --> valor de liquidacao do titulo
                                    ,pr_dtocorre => vr_dtmvtolt --> data da ocorrencia da devolucao
                                    ,pr_nrdconta => vr_nrdconta --> numero da conta do cooperado
                                    ,pr_nrcnvcob => vr_nrcnvcob --> numero do convenio de cobranca do cooperado
                                    ,pr_nrdocmto => vr_nrdocmto --> numero do boleto de cobranca
                                    ,pr_cdmotdev => vr_cdmotdev --> codigo do motivo da devolucao
                                    ,pr_tpcaptur => vr_tpcaptur --> tipo de captura (cob615)
                                    ,pr_tpdocmto => vr_tpdocmto --> codigo do tipo de documento (cob615)
                                    ,pr_cdagerem => vr_cdagepag --> codigo da agencia do remetente (cob615)
                                    ,pr_dslinarq => vr_setlinha
                                    ,pr_cdcritic => vr_cdcritic -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483
                                    ,pr_dscritic => vr_dscritic);
                  IF TRIM(vr_dscritic) IS NOT NULL THEN
                    RAISE vr_exc_sair;
                  END IF;
                
                  -- pular para o proximo registro - devolvido em arquivo
                  RAISE vr_exc_proximo;
                  -- Se pagou valor a menor e é ACORDO
                ELSIF TRUNC(vr_vlliquid, 2) < TRUNC(vr_vlfatura, 2) AND
                      vr_tab_crapcco(vr_index_crapcco).dsorgarq = 'ACORDO' THEN
                
                  -- Criacao da tabela generica gncptit - utilizada na conciliacao 
                  -- Ajuste - 15/03/2018 - Chamado 801483
                  pc_insert_gncptit(pr_nrdispar => 10 -- Numero sequencial do dispare da prc 
                                   ,pr_idx      => idx
                                   ,pr_cdtipreg => 5 /* Sua Remessa - Erro */
                                   ,pr_flgconci => 1 /* registro conciliado */
                                   ,pr_flgpcctl => 0 /* processou na central */
                                   ,pr_cdcritic => 969 /* integrado c/ erro - boleto de emprestimo nao processado */
                                   ,pr_flgpgdda => NULL
                                   ,pr_nrispbds => vr_nrispbif_rec
                                   ,pr_cdcriret => vr_cdcrignc
                                   ,pr_dscritic => vr_dscritic);
                
                  IF NVL(vr_cdcrignc, 0) > 0 THEN
                    vr_cdcritic := vr_cdcrignc;
                    RAISE vr_exc_sair;
                  END IF;
                
                  --> Gerar Devolucao
                  vr_cdmotdev := 82; --> Boleto divergente da base
                
                  --> Procedimento para grava registro de devolucao
                  pc_grava_devolucao(pr_cdcooper => rw_crapcop.cdcooper --> codigo da cooperativa
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> data do movimento
                                    ,pr_dtmvtopr => rw_crapdat.dtmvtopr --> data do próximo movimento
                                    ,pr_nrseqarq => vr_nrseqarq --> numero sequencial do arquivo da devolucao (cob615)
                                    ,pr_dscodbar => vr_dscodbar_ori --> codigo de barras
                                    ,pr_nrispbif => vr_nrispbif_rec --> numero do ispb recebedora
                                    ,pr_vlliquid => vr_vlliquid --> valor de liquidacao do titulo
                                    ,pr_dtocorre => vr_dtmvtolt --> data da ocorrencia da devolucao
                                    ,pr_nrdconta => vr_nrdconta --> numero da conta do cooperado
                                    ,pr_nrcnvcob => vr_nrcnvcob --> numero do convenio de cobranca do cooperado
                                    ,pr_nrdocmto => vr_nrdocmto --> numero do boleto de cobranca
                                    ,pr_cdmotdev => vr_cdmotdev --> codigo do motivo da devolucao
                                    ,pr_tpcaptur => vr_tpcaptur --> tipo de captura (cob615)
                                    ,pr_tpdocmto => vr_tpdocmto --> codigo do tipo de documento (cob615)
                                    ,pr_cdagerem => vr_cdagepag --> codigo da agencia do remetente (cob615)
                                    ,pr_dslinarq => vr_setlinha
                                    ,pr_cdcritic => vr_cdcritic -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483
                                    ,pr_dscritic => vr_dscritic);
                  IF TRIM(vr_dscritic) IS NOT NULL THEN
                    RAISE vr_exc_sair;
                  END IF;
                
                  -- pular para o proximo registro - devolvido em arquivo
                  RAISE vr_exc_proximo;
                END IF;
              
                -- Devolver pagamentos divergentes (SIT_PAG_DIVERGENTE: 1 = ATIVO, 2 = INATIVO)
                IF (NVL(fn_buscar_param(pr_cdcooper, 'SIT_PAG_DIVERGENTE'), 2) = 1) THEN
                  -- Resto da diferença entre vlfatura e vlliquid
                  vr_resto := TRUNC(vr_vlliquid, 2) - TRUNC(vr_vlfatura, 2);
                  -- vr_resto diferente de zero
                  IF (NVL(vr_resto, 0) <> 0) AND (NOT vr_liqaposb) THEN
                    -- Pagamento com valor divergente
                    vr_cdcritic := 940;
                    -- Buscar descricao critica
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                  
                    -- create craprej
                    BEGIN
                      INSERT INTO craprej
                        (craprej.dtmvtolt
                        ,craprej.cdagenci
                        ,craprej.vllanmto
                        ,craprej.nrseqdig
                        ,craprej.cdpesqbb
                        ,craprej.cdcritic
                        ,craprej.cdcooper
                        ,craprej.nrdconta
                        ,craprej.cdbccxlt
                        ,craprej.nrdocmto)
                      VALUES
                        (rw_crapdat.dtmvtolt
                        ,vr_cdagepag
                        ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 85, 12))) / 100
                        ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 151, 10)))
                        ,vr_setlinha
                        ,vr_cdcritic
                        ,pr_cdcooper
                        ,vr_nrdconta
                        ,vr_cdbanpag
                        ,vr_nrdocmto)
                      RETURNING craprej.dtmvtolt, craprej.cdagenci, craprej.vllanmto, craprej.nrseqdig, craprej.cdpesqbb, craprej.cdcritic, craprej.cdcooper, craprej.nrdconta, craprej.cdbccxlt, craprej.nrdocmto INTO rw_craprej.dtmvtolt, rw_craprej.cdagenci, rw_craprej.vllanmto, rw_craprej.nrseqdig, rw_craprej.cdpesqbb, rw_craprej.cdcritic, rw_craprej.cdcooper, rw_craprej.nrdconta, rw_craprej.cdbccxlt, rw_craprej.nrdocmto;
                    EXCEPTION
                      WHEN OTHERS THEN
                        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                        vr_cdcritic := 1034;
                        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                                       ' craprej(15):' || ' dtmvtolt:' || rw_crapdat.dtmvtolt ||
                                       ', cdagenci:' || vr_cdagepag || ', vllanmto:' ||
                                       TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 85, 12))) || ' / 100 ' ||
                                       ', nrseqdig:' ||
                                       TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 151, 10))) ||
                                       ', cdpesqbb:' || vr_setlinha || ', cdcritic:' || vr_cdcritic ||
                                       ', cdcooper:' || pr_cdcooper || ', nrdconta:' || vr_nrdconta ||
                                       ', cdbccxlt:' || vr_cdbanpag || ', nrdocmto:' || vr_nrdocmto || '. ' ||
                                       SQLERRM;
                        --Levantar Excecao
                        RAISE vr_exc_sair;
                    END;
                  
                    --Atualizar tabela memoria cratrej
                    pc_gera_cratrej(rw_craprej);
                    IF TRIM(vr_dscritic) IS NOT NULL THEN
                      RAISE vr_exc_sair;
                    END IF;
                  
                  END IF; -- Fim - vr_resto diferente de zero
                
                  -- Busca valor de tolerância
                  vr_tolerancia := TRUNC(NVL(fn_buscar_param(pr_cdcooper, 'VL_TOLERANCIA'), 0), 2);
                  -- Se for percentual, calcula o valor final (TIP_TOLERANCIA: 1 = VALOR, 2 = PERCENTUAL)
                  IF (NVL(fn_buscar_param(pr_cdcooper, 'TIP_TOLERANCIA'), 1) = 2) THEN
                    vr_tolerancia := TRUNC((TRUNC(vr_vlfatura, 2) * TRUNC((vr_tolerancia / 100), 2))
                                          ,2);
                  END IF;
                
                  -- Flags maior e menor
                  vr_flgmenor       := FALSE;
                  vr_flgmaior       := FALSE;
                  vr_resto_positivo := vr_resto;
                  IF (vr_resto < 0) THEN
                    vr_resto_positivo := vr_resto * -1;
                  END IF;
                  IF (vr_resto_positivo > vr_tolerancia) THEN
                    vr_flgmenor := (vr_resto < 0) AND
                                   (NVL(fn_buscar_param(pr_cdcooper, 'PAG_A_MENOR'), 0) = 1);
                    vr_flgmaior := (vr_resto > 0) AND
                                   (NVL(fn_buscar_param(pr_cdcooper, 'PAG_A_MAIOR'), 0) = 1);
                  END IF;
                
                  -- Se deve devolver maior ou menor
                  IF (vr_flgmenor OR vr_flgmaior) THEN
                    -- Verificar boleto configurado como divergente
                    vr_permite_divergencia := FALSE;
                    IF rw_crapcob.inpagdiv > 0 THEN
                      vr_permite_divergencia :=  -- permite qualquer valor
                       ((rw_crapcob.inpagdiv = 2)
                                                -- permite qualquer valor desde que nao seja menor que o definido
                                                OR (rw_crapcob.inpagdiv = 1 AND
                                                rw_crapcob.vlminimo <= TRUNC(vr_vlliquid, 2)));
                    END IF;
                    -- Ignorar boleto configurado como divergente
                    IF NOT vr_permite_divergencia THEN
                      -- Rejeitado
                      vr_flgrejei := TRUE;
                    
                      -- Criacao da tabela generica gncptit - utilizada na conciliacao 
                      pc_insert_gncptit(pr_nrdispar => 15 -- Numero sequencial do dispare da prc
                                       ,pr_idx      => idx
                                       ,pr_cdtipreg => 3 /* Sua Remessa - Erro */
                                       ,pr_flgconci => 1 /* registro conciliado */
                                       ,pr_flgpcctl => 0 /* processou na central */
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_flgpgdda => NULL
                                       ,pr_nrispbds => vr_nrispbif_rec
                                       ,pr_cdcriret => vr_cdcrignc
                                       ,pr_dscritic => vr_dscritic);
                    
                      IF NVL(vr_cdcrignc, 0) > 0 THEN
                        vr_cdcritic := vr_cdcrignc;
                        RAISE vr_exc_sair;
                      END IF;
                    
                      --Criar log Cobranca
                      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid --ROWID da Cobranca
                                                   ,pr_cdoperad => ct_cdoperad --Operador
                                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data movimento
                                                   ,pr_dsmensag => --Descricao Mensagem
                                                     'Pagamento de R$ ' ||
                                                     TRIM(TO_CHAR(TRUNC(vr_vlliquid, 2)
                                                                 ,'999G999G990d00')) ||
                                                     ' devolvido por diferença na liquidação. Valor correto seria R$ ' ||
                                                     TRIM(TO_CHAR(TRUNC(vr_vlfatura, 2)
                                                                 ,'999G999G990d00'))
                                                   ,pr_des_erro => vr_des_erro --Indicador erro
                                                   ,pr_dscritic => vr_dscritic); --Descricao erro
                      --Se ocorreu erro
                      IF vr_des_erro = 'NOK' THEN
                        --Levantar Excecao
                        RAISE vr_exc_sair;
                      END IF;
                    
                      --> Gerar Devolucao
                      vr_cdmotdev := 82; -- Boleto divergente da base
                    
                      --> Procedimento para grava registro de devolucao
                      pc_grava_devolucao(pr_cdcooper => rw_crapcop.cdcooper --> codigo da cooperativa
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> data do movimento
                                        ,pr_dtmvtopr => rw_crapdat.dtmvtopr --> data do próximo movimento
                                        ,pr_nrseqarq => vr_nrseqarq --> numero sequencial do arquivo da devolucao (cob615)
                                        ,pr_dscodbar => vr_dscodbar_ori --> codigo de barras
                                        ,pr_nrispbif => vr_nrispbif_rec --> numero do ispb recebedora
                                        ,pr_vlliquid => vr_vlliquid --> valor de liquidacao do titulo
                                        ,pr_dtocorre => vr_dtmvtolt --> data da ocorrencia da devolucao
                                        ,pr_nrdconta => vr_nrdconta --> numero da conta do cooperado
                                        ,pr_nrcnvcob => vr_nrcnvcob --> numero do convenio de cobranca do cooperado
                                        ,pr_nrdocmto => vr_nrdocmto --> numero do boleto de cobranca
                                        ,pr_cdmotdev => vr_cdmotdev --> codigo do motivo da devolucao
                                        ,pr_tpcaptur => vr_tpcaptur --> tipo de captura (cob615)
                                        ,pr_tpdocmto => vr_tpdocmto --> codigo do tipo de documento (cob615)
                                        ,pr_cdagerem => vr_cdagepag --> codigo da agencia do remetente (cob615)
                                        ,pr_dslinarq => vr_setlinha
                                        ,pr_cdcritic => vr_cdcritic -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483
                                        ,pr_dscritic => vr_dscritic);
                      IF TRIM(vr_dscritic) IS NOT NULL THEN
                        RAISE vr_exc_sair;
                      END IF;
                    
                      RAISE vr_exc_proximo;
                    
                    END IF; -- Fim - Ignorar boleto configurado como divergente
                  END IF; -- Fim - Se deve devolver maior ou menor
                
                ELSE
                  /* se pagou valor menor do que deveria, joga critica no log */
                  IF TRUNC(vr_vlliquid, 2) < TRUNC(vr_vlfatura, 2) AND NOT vr_liqaposb THEN
                    vr_cdcritic := 940;
                    --Buscar descricao critica
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                    /* create craprej */
                    BEGIN
                      INSERT INTO craprej
                        (craprej.dtmvtolt
                        ,craprej.cdagenci
                        ,craprej.vllanmto
                        ,craprej.nrseqdig
                        ,craprej.cdpesqbb
                        ,craprej.cdcritic
                        ,craprej.cdcooper
                        ,craprej.nrdconta
                        ,craprej.cdbccxlt
                        ,craprej.nrdocmto)
                      VALUES
                        (rw_crapdat.dtmvtolt
                        ,vr_cdagepag
                        ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 85, 12))) / 100
                        ,TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 151, 10)))
                        ,vr_setlinha
                        ,vr_cdcritic
                        ,pr_cdcooper
                        ,vr_nrdconta
                        ,vr_cdbanpag
                        ,vr_nrdocmto)
                      RETURNING craprej.dtmvtolt, craprej.cdagenci, craprej.vllanmto, craprej.nrseqdig, craprej.cdpesqbb, craprej.cdcritic, craprej.cdcooper, craprej.nrdconta, craprej.cdbccxlt, craprej.nrdocmto INTO rw_craprej.dtmvtolt, rw_craprej.cdagenci, rw_craprej.vllanmto, rw_craprej.nrseqdig, rw_craprej.cdpesqbb, rw_craprej.cdcritic, rw_craprej.cdcooper, rw_craprej.nrdconta, rw_craprej.cdbccxlt, rw_craprej.nrdocmto;
                    EXCEPTION
                      WHEN OTHERS THEN
                        -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
                        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                        -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483 
                        vr_cdcritic := 1034;
                        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                                       ' craprej(12):' || ' dtmvtolt:' || rw_crapdat.dtmvtolt ||
                                       ', cdagenci:' || vr_cdagepag || ', vllanmto:' ||
                                       TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 85, 12))) || ' / 100 ' ||
                                       ', nrseqdig:' ||
                                       TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 151, 10))) ||
                                       ', cdpesqbb:' || vr_setlinha || ', cdcritic:' || vr_cdcritic ||
                                       ', cdcooper:' || pr_cdcooper || ', nrdconta:' || vr_nrdconta ||
                                       ', cdbccxlt:' || vr_cdbanpag || ', nrdocmto:' || vr_nrdocmto || '. ' ||
                                       SQLERRM;
                        --Levantar Excecao
                        RAISE vr_exc_sair;
                    END;
                  
                    --Atualizar tabela memoria cratrej
                    pc_gera_cratrej(rw_craprej);
                    -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483                                            
                    IF TRIM(vr_dscritic) IS NOT NULL THEN
                      RAISE vr_exc_sair;
                    END IF;
                  
                    --Selecionar nome sacado
                    OPEN cr_crapsab(pr_cdcooper => rw_crapcob.cdcooper
                                   ,pr_nrdconta => rw_crapcob.nrdconta
                                   ,pr_nrinssac => rw_crapcob.nrinssac);
                    FETCH cr_crapsab
                      INTO rw_crapsab;
                    --Indicar se encontrou ou nao
                    vr_crapsab := cr_crapsab%FOUND;
                    --Fechar Cursor
                    CLOSE cr_crapsab;
                    --Se nao encontrou
                    IF NOT vr_crapsab THEN
                      rw_crapsab.nmdsacad := NULL;
                    END IF;
                  
                    IF (TRUNC(vr_vlfatura, 2) - TRUNC(vr_vlliquid, 2)) >= vr_vlrmincac THEN
                      -- Calcula a diferenca
                      vr_vlrdifer := TRUNC(nvl(rw_crapcob.vltitulo, 0) -
                                           TRUNC(nvl(rw_crapcob.vldescto, 0) +
                                                 nvl(rw_crapcob.vlabatim, 0)
                                                ,2) +
                                           TRUNC(nvl(vr_vlrjuros, 0) + nvl(vr_vlrmulta, 0), 2) -
                                           nvl(TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 85, 12))) / 100
                                              ,0)
                                          ,2);
                    
                      -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483 
                      /* Alimenta o rel. 618 */
                      --Gravar dados na tabela work
                      pc_insere_tbgen_batch_rel_wrk(pr_cdcooper    => rw_crapcob.cdcooper
                                                   ,pr_CDPROGRAMA  => ct_cdprogra
                                                   ,pr_DSRELATORIO => 'REL618'
                                                   ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                                   ,pr_cdagenci    => vr_cdagepag
                                                   ,pr_DSCHAVE     => lpad(to_char(vr_cdbanpag
                                                                                  ,'fm000')
                                                                          ,10
                                                                          ,'0') ||
                                                                      rpad(TRIM(rw_crapsab.nmdsacad)
                                                                          ,50
                                                                          ,'#') ||
                                                                      lpad(to_char(rw_crapcob.vltitulo * 100)
                                                                          ,25
                                                                          ,'0')
                                                   ,pr_NRDCONTA    => NULL
                                                   ,pr_NRCNVCOB    => NULL
                                                   ,pr_NRDOCMTO    => NULL
                                                   ,pr_NRCTREMP    => NULL
                                                   ,pr_DSDOCCOP    => rw_crapcob.dsdoccop
                                                   ,pr_TPPARCEL    => NULL
                                                   ,pr_DTVENCTO    => rw_crapcob.dtvencto
                                                   ,pr_VLTITULO    => rw_crapcob.vltitulo
                                                   ,pr_VLDPAGTO    => TRUNC((nvl(rw_crapcob.vldescto
                                                                                ,0) +
                                                                            nvl(rw_crapcob.vlabatim
                                                                                ,0))
                                                                           ,2)
                                                   ,pr_DSXML       => TO_CHAR(vr_cdbanpag, 'fm000') ||
                                                                      to_char(vr_cdbanpag, 'fm000') || '/' ||
                                                                      to_char(vr_cdagepag, 'fm0000') ||
                                                                      to_char(nvl(rw_crapcob.nrinssac
                                                                                 ,0)
                                                                             ,'fm000000000000000') ||
                                                                      rpad(rw_crapsab.nmdsacad, 50) ||
                                                                      rpad(SUBSTR(vr_setlinha
                                                                                 ,01
                                                                                 ,44)
                                                                          ,50) ||
                                                                      to_char(TRUNC(nvl(vr_vlrjuros
                                                                                       ,0) +
                                                                                    nvl(vr_vlrmulta
                                                                                       ,0)
                                                                                   ,2)
                                                                             ,'fm000000000000000D0000') ||
                                                                      to_char(TO_NUMBER(TRIM(SUBSTR(vr_setlinha
                                                                                                   ,85
                                                                                                   ,12))) / 100
                                                                             ,'fm000000000000000D0000') ||
                                                                      to_char(vr_vlrdifer
                                                                             ,'fm00000000000000000D00') ||
                                                                      to_char(0
                                                                             ,'fm00000000000000000D00') ||
                                                                      to_char(rw_crapass.inpessoa
                                                                             ,'fm00000')
                                                   ,pr_dscrient    => NULL
                                                   ,pr_cdcrisai    => vr_cdcritic
                                                   ,pr_dscrisai    => vr_dscritic);
                      IF NVL(vr_cdcritic, 0) > 0 THEN
                        RAISE vr_exc_sair;
                      END IF;
                    END IF;
                  END IF;
                END IF;
              
                IF TRUNC(vr_vlliquid, 2) > TRUNC(vr_vlfatura, 2) THEN
                  --Juros recebe valor liquidacao menos o valor fatura
                  vr_vlrjuros := nvl(vr_vlrjuros, 0) + (nvl(vr_vlliquid, 0) - nvl(vr_vlfatura, 0));
                END IF;
              
                --Determinar o tipo de liquidacao
                CASE SUBSTR(vr_setlinha, 50, 1)
                  WHEN '1' THEN
                    vr_dsmotivo := '03'; /*Liquidaçao no Guiche de Caixa*/
                  WHEN '2' THEN
                    vr_dsmotivo := '32'; /*Liquidaçao Terminal de Auto-Atendimento*/
                  WHEN '3' THEN
                    vr_dsmotivo := '33'; /*Liquidaçao na Internet (Home banking)*/
                  WHEN '5' THEN
                    vr_dsmotivo := '31'; /*Liquidaçao Banco Correspondente*/
                  WHEN '6' THEN
                    vr_dsmotivo := '37'; /*Liquidaçao por Telefone*/
                  WHEN '7' THEN
                    vr_dsmotivo := '06'; /*Liquidaçao Arquivo Eletronico*/
                  ELSE
                    NULL;
                END CASE;
                /* buscar banco/agencia origem do pagamento (Rafael) */
                BEGIN
                  vr_cdagepag := TO_NUMBER(TRIM(SUBSTR(vr_setlinha, 57, 4)));
                EXCEPTION
                  WHEN OTHERS THEN
                    -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
                    CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                    vr_cdbanpag := rw_crapcop.cdbcoctl;
                    vr_cdagepag := rw_crapcop.cdagectl;
                END;
                -- Ajusta o parametro com a regra de evitar o nulo - 21/03/2019 - REQ0037942  
                --Verificar nome da tela
                IF vr_nmtelant = 'COMPEFORA' THEN
                  vr_dtmvtaux := rw_crapdat.dtmvtoan;
                ELSE
                  vr_dtmvtaux := rw_crapdat.dtmvtolt;
                END IF;
              
                -- Flag para verificar pagamento a menor
                vr_flamenor := (TRUNC(vr_vlliquid, 2) < TRUNC(vr_vlfatura, 2) AND NOT vr_liqaposb);
              
                /* se nao for liquidacao de titulo já pago, entao liq normal */
                IF NOT vr_liqaposb THEN
                
                  IF rw_crapcob.inemiten = 3 THEN
                    vr_aux_cdocorre := 76;
                  ELSE
                    vr_aux_cdocorre := 6;
                  END IF;
                
                  -- Ajusta o parametro com a regra de evitar o nulo - 21/03/2019 - REQ0037942                   
                  --Processar liquidacao
                  PAGA0001.pc_processa_liquidacao(pr_idtabcob            => rw_crapcob.rowid --Rowid da Cobranca
                                                 ,pr_nrnosnum            => 0 --Nosso Numero
                                                 ,pr_nrispbpg            => vr_nrispbif_rec --Numero ISPB do pagador
                                                 ,pr_cdbanpag            => vr_cdbanpag --Codigo banco pagamento
                                                 ,pr_cdagepag            => vr_cdagepag --Codigo Agencia pagamento
                                                 ,pr_vltitulo            => nvl(rw_crapcob.vltitulo
                                                                               ,0) --Valor do titulo
                                                 ,pr_vlliquid            => 0 --Valor Liquidacao
                                                 ,pr_vlrpagto            => nvl(vr_vlliquid, 0) --Valor pagamento
                                                 ,pr_vlabatim            => 0 --Valor abatimento
                                                 ,pr_vldescto            => nvl(vr_vldescto, 0) +
                                                                            nvl(vr_vlabatim, 0) --Valor desconto
                                                 ,pr_vlrjuros            => nvl(vr_vlrjuros, 0) +
                                                                            nvl(vr_vlrmulta, 0) --Valor juros
                                                 ,pr_vloutdeb            => 0 --Valor saida debito
                                                 ,pr_vloutcre            => 0 --Valor saida credito
                                                 ,pr_dtocorre            => vr_dtmvtolt --Data Ocorrencia
                                                 ,pr_dtcredit            => rw_crapdat.dtmvtolt --Data Credito
                                                 ,pr_cdocorre            => vr_aux_cdocorre --Codigo Ocorrencia
                                                 ,pr_dsmotivo            => vr_dsmotivo --Descricao Motivo
                                                 ,pr_dtmvtolt            => vr_dtmvtaux --Data movimento
                                                 ,pr_cdoperad            => '1' --Codigo Operador
                                                 ,pr_indpagto            => rw_crapcob.indpagto --Indicador pagamento -- 0-COMPE 1-Caixa On-Line 3-Internet 4-TAA 
                                                 ,pr_ret_nrremret        => vr_nrretcoo --Numero remetente
                                                 ,pr_nmtelant            => vr_nmtelant --Verificar COMPEFORA                                                   
                                                 ,pr_cdcritic            => vr_cdcritic --Codigo Critica
                                                 ,pr_dscritic            => vr_dscritic --Descricao Critica
                                                 ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada --Tabela lancamentos consolidada
                                                 ,pr_tab_descontar       => vr_tab_descontar); --Tabela de titulos
                ELSE
                
                  IF rw_crapcob.inemiten = 3 THEN
                    vr_aux_cdocorre := 77;
                  ELSE
                    vr_aux_cdocorre := 17;
                  END IF;
                
                  --Processar Liquidacao apos baixa
                  PAGA0001.pc_proc_liquid_apos_baixa(pr_idtabcob            => rw_crapcob.rowid --Rowid da Cobranca
                                                    ,pr_nrnosnum            => 0 --Nosso Numero
                                                    ,pr_nrispbpg            => vr_nrispbif_rec --Numero ISPB do pagador
                                                    ,pr_cdbanpag            => vr_cdbanpag --Codigo banco pagamento
                                                    ,pr_cdagepag            => vr_cdagepag --Codigo Agencia pagamento
                                                    ,pr_vltitulo            => nvl(rw_crapcob.vltitulo
                                                                                  ,0) --Valor do titulo
                                                    ,pr_vlliquid            => 0 --Valor Liquidacao
                                                    ,pr_vlrpagto            => nvl(vr_vlliquid, 0) --Valor pagamento
                                                    ,pr_vlabatim            => 0 --Valor abatimento
                                                    ,pr_vldescto            => nvl(vr_vldescto, 0) +
                                                                               nvl(vr_vlabatim, 0) --Valor desconto
                                                    ,pr_vlrjuros            => 0 --Valor juros
                                                    ,pr_vloutdeb            => 0 --Valor saida debito
                                                    ,pr_vloutcre            => 0 --Valor saida credito
                                                    ,pr_dtocorre            => vr_dtmvtolt --Data Ocorrencia
                                                    ,pr_dtcredit            => rw_crapdat.dtmvtolt --Data Credito
                                                    ,pr_cdocorre            => vr_aux_cdocorre --Codigo Ocorrencia
                                                    ,pr_dsmotivo            => vr_dsmotivo --Descricao Motivo
                                                    ,pr_dtmvtolt            => vr_dtmvtaux --Data movimento
                                                    ,pr_cdoperad            => '1' --Codigo Operador
                                                    ,pr_indpagto            => rw_crapcob.indpagto --Indicador pagamento -- 0-COMPE 1-Caixa On-Line 3-Internet 4-TAA 
                                                    ,pr_ret_nrremret        => vr_nrretcoo --Numero remetente
                                                    ,pr_cdcritic            => vr_cdcritic --Codigo Critica
                                                    ,pr_dscritic            => vr_dscritic --Descricao Critica
                                                    ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada); --Tabela lancamentos consolidada
                END IF;
              
                --Se ocorreu erro
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                
                  -- Verifica se houve erro por passar do prazo de liquidar no cartorio
                  --
                  vr_fgdevpro:= 'N';
                  --

                  IF vr_cdcritic in(1462,1464,1294) THEN 
                      vr_cdmotdev:= 77; --Boleto em cartorio ou protestado
                      vr_fgdevpro:= 'S';
                  END IF;
                
                  --Marcar como rejeitado
                  vr_flgrejei := TRUE;
                  -- Tratado descrição na busca critica - Chamado 714566 - 11/08/2017
                  --monta mensagem de erro
                  vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic
                                                          ,pr_dscritic => vr_dscritic);
                
                  -- Incluido controle de Log - Chamado 714566 - 11/08/2017 
                  --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
                  cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                        ,pr_cdagenci => pr_cdagenci
                                        ,pr_cdprogra => ct_cdprogra
                                        ,pr_idprglog => vr_idprglog
                                        ,pr_dstiplog => 'E'
                                        ,pr_tpocorre => 1
                                        ,pr_dscritic => vr_dscritic || ' - Linha: ' ||
                                                        SUBSTR(vr_setlinha, 151, 10) ||
                                                        ' - Arquivo: integra/' ||
                                                        vr_tab_nmarqtel(idx)
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_cdcricid => 0);
                
                  -- Incluir a regra para processamento do acordo - Renato Darosci - 30/09/2016
                  IF nvl(rw_crapcob.nrctremp, 0) > 0 THEN
                    vr_cdtipreg := 5;
                  ELSIF vr_tab_crapcco(vr_index_crapcco).dsorgarq = 'ACORDO' THEN
                    vr_cdtipreg := 5;
                  ELSE
                    vr_cdtipreg := 3;
                  END IF;
                
                  -- Criacao da tabela generica gncptit - utilizada na conciliacao 
                  -- Ajuste - 15/03/2018 - Chamado 801483
                  pc_insert_gncptit(pr_nrdispar => 11 -- Numero sequencial do dispare da prc 
                                   ,pr_idx      => idx
                                   ,pr_cdtipreg => vr_cdtipreg /* Sua Remessa - Erro */
                                   ,pr_flgconci => 1 /* registro conciliado */
                                   ,pr_flgpcctl => 1 /* processou na central */
                                   ,pr_cdcritic => vr_cdcritic /* integrado c/ erro */
                                   ,pr_flgpgdda => NULL
                                   ,pr_nrispbds => vr_nrispbif_rec
                                   ,pr_cdcriret => vr_cdcrignc
                                   ,pr_dscritic => vr_dscritic);
                
                  IF NVL(vr_cdcrignc, 0) > 0 THEN
                    vr_cdcritic := vr_cdcrignc;
                    RAISE vr_exc_sair;
                  END IF;
                  --
                  IF vr_fgdevpro = 'S' THEN
                    --> Procedimento para grava registro de devolucao
                    pc_grava_devolucao(pr_cdcooper => rw_crapcop.cdcooper --> codigo da cooperativa
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> data do movimento
                                      ,pr_dtmvtopr => rw_crapdat.dtmvtopr --> data do proximo movimento
                                      ,pr_nrseqarq => vr_nrseqarq --> numero sequencial do arquivo da devolucao (cob615)
                                      ,pr_dscodbar => vr_dscodbar_ori --> codigo de barras
                                      ,pr_nrispbif => vr_nrispbif_rec --> numero do ispb recebedora
                                      ,pr_vlliquid => vr_vlliquid --> valor de liquidacao do titulo
                                      ,pr_dtocorre => vr_dtmvtolt --> data da ocorrencia da devolucao
                                      ,pr_nrdconta => vr_nrdconta --> numero da conta do cooperado
                                      ,pr_nrcnvcob => vr_nrcnvcob --> numero do convenio de cobranca do cooperado
                                      ,pr_nrdocmto => vr_nrdocmto --> numero do boleto de cobranca
                                      ,pr_cdmotdev => vr_cdmotdev --> codigo do motivo da devolucao
                                      ,pr_tpcaptur => vr_tpcaptur --> tipo de captura (cob615)
                                      ,pr_tpdocmto => vr_tpdocmto --> codigo do tipo de documento (cob615)
                                      ,pr_cdagerem => vr_cdagepag --> codigo da agencia do remetente (cob615)
                                      ,pr_dslinarq => vr_setlinha
                                      ,pr_cdcritic => vr_cdcritic -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483
                                      ,pr_dscritic => vr_dscritic);
                
                  END IF;                  
                  --Inicializar variavel erro
                  vr_cdcritic := 0;
                  --Proxima Linha Arquivo
                  RAISE vr_exc_proximo;
                END IF;
              
                /* controle para lancamento consolidado na conta corrente */
                vr_index_conv_arq := lpad(rw_crapcop.cdcooper, 10, '0') ||
                                     lpad(vr_nrcnvcob, 10, '0');
                --Se nao existir na tabela memória
                IF NOT vr_tab_conv_arq.EXISTS(vr_index_conv_arq) THEN
                  vr_tab_conv_arq(vr_index_conv_arq).cdcooper := vr_tab_crapcco(vr_index_conv_arq).cdcooper;
                  vr_tab_conv_arq(vr_index_conv_arq).dtmvtolt := rw_crapdat.dtmvtolt;
                  vr_tab_conv_arq(vr_index_conv_arq).cdagenci := vr_tab_crapcco(vr_index_conv_arq).cdagenci;
                  vr_tab_conv_arq(vr_index_conv_arq).cdbccxlt := vr_tab_crapcco(vr_index_conv_arq).cdbccxlt;
                  vr_tab_conv_arq(vr_index_conv_arq).nrdolote := vr_tab_crapcco(vr_index_conv_arq).nrdolote;
                  vr_tab_conv_arq(vr_index_conv_arq).nrconven := vr_tab_crapcco(vr_index_conv_arq).nrconven;
                END IF;
              
                --Atribuir tipo documento
                vr_cdtipdoc := SUBSTR(vr_setlinha, 148, 3);
              
                -- Incluir a regra para processamento do acordo - Renato Darosci - 30/09/2016
                IF nvl(rw_crapcob.nrctremp, 0) > 0 THEN
                  vr_cdtipreg := 5;
                ELSIF vr_tab_crapcco(vr_index_crapcco).dsorgarq = 'ACORDO' THEN
                  vr_cdtipreg := 5;
                ELSE
                  vr_cdtipreg := 4;
                END IF;
              
                --Tipo documento
                IF vr_cdtipdoc IN (140, 144) THEN
                  vr_flgpgdda := 1;
                ELSE
                  vr_flgpgdda := 0;
                END IF;
              
                -- Criacao da tabela generica gncptit - utilizada na conciliacao 
                -- Ajuste - 15/03/2018 - Chamado 801483
                pc_insert_gncptit(pr_nrdispar => 12 -- Numero sequencial do dispare da prc 
                                 ,pr_idx      => idx
                                 ,pr_cdtipreg => vr_cdtipreg /* Sua Remessa - Erro */
                                 ,pr_flgconci => 1 /* registro conciliado */
                                 ,pr_flgpcctl => 0 /* processou na central */
                                 ,pr_cdcritic => 0 /* integrado coop */
                                 ,pr_flgpgdda => vr_flgpgdda
                                 ,pr_nrispbds => vr_nrispbif_rec
                                 ,pr_cdcriret => vr_cdcrignc
                                 ,pr_dscritic => vr_dscritic);
              
                IF NVL(vr_cdcrignc, 0) > 0 THEN
                  vr_cdcritic := vr_cdcrignc;
                  RAISE vr_exc_sair;
                END IF;
              
              END IF; /* final tratamento para cobranca registrada */
            EXCEPTION
              WHEN vr_exc_proximo THEN
                NULL;
              WHEN vr_exc_sair THEN
                -- Incluido controle de Log 
                --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
                cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                      ,pr_cdagenci => pr_cdagenci
                                      ,pr_cdprogra => ct_cdprogra
                                      ,pr_idprglog => vr_idprglog
                                      ,pr_dstiplog => 'O'
                                      ,pr_tpocorre => 4
                                      ,pr_dscritic => vr_dscritic
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_cdcricid => 0);
                --Desfazer transacao
                --ROLLBACK TO save_trans;
                --Sair Loop
                --EXIT;
                NULL;
              WHEN vr_exc_saida_2 THEN
                --Desfazer transacao
                ROLLBACK;
                --Sair Loop
                EXIT;
            END;
          END LOOP; --Fim Linhas Arquivo
        
          /* realiza liquidacao dos titulos descontados (se houver) */
          --Limpar tabela titulos
          vr_tab_titulos.DELETE;
          --Montar indice para acesso a tabela descontar
          vr_index_desc := vr_tab_descontar.FIRST;
          WHILE vr_index_desc IS NOT NULL
          LOOP
          
            --Adicionar na tabela de titulo os descontados
            vr_index_titulo := lpad(vr_tab_descontar(vr_index_desc).nrdconta, 10, '0') ||
                               lpad(vr_tab_titulos.count + 1, 10, '0');
            vr_tab_titulos(vr_index_titulo) := vr_tab_descontar(vr_index_desc);
          
            --Se for ultimo registro da conta
            IF vr_index_desc = vr_tab_descontar.LAST OR
               (vr_tab_descontar(vr_index_desc).nrdconta <> vr_tab_descontar(vr_tab_descontar.NEXT(vr_index_desc)).nrdconta) THEN
              --Limpar tabela erro
              vr_tab_erro2.DELETE;
              -- Ajusta o parametro com a regra de evitar o nulo - 21/03/2019 - REQ0037942  
              --Verificar nome da tela
              IF vr_nmtelant = 'COMPEFORA' THEN
                vr_dtmvtaux := rw_crapdat.dtmvtoan;
              ELSE
                vr_dtmvtaux := rw_crapdat.dtmvtolt;
              END IF;
            
              --Efetuar a baixa do titulo
              DSCT0001.pc_efetua_baixa_titulo(pr_cdcooper    => pr_cdcooper --Codigo Cooperativa
                                             ,pr_cdagenci    => pr_cdagenci --Codigo Agencia    -- Ligeirinho alderado de 0 p/ Agencia do PA
                                             ,pr_nrdcaixa    => 0 --Numero Caixa
                                             ,pr_cdoperad    => 0 --Codigo operador
                                             ,pr_dtmvtolt    => rw_crapdat.dtmvtolt --Data Movimento
                                             ,pr_idorigem    => 1 --AYLLOS--       --Identificador Origem pagamento
                                             ,pr_nrdconta    => vr_tab_descontar(vr_index_desc).nrdconta --Numero da conta
                                             ,pr_indbaixa    => 1 --Indicador Baixa /* 1-Pagamento 2- Vencimento */
                                             ,pr_dtintegr    => vr_dtmvtaux -- Data de integração do pagamento
                                             ,pr_tab_titulos => vr_tab_titulos --Titulos a serem baixados
                                             ,pr_cdcritic    => vr_cdcritic --Codigo Critica
                                             ,pr_dscritic    => vr_dscritic --Descricao Critica
                                             ,pr_tab_erro    => vr_tab_erro2); --Tabela erros
              --Se ocorreu erro
              IF vr_tab_erro2.Count > 0 THEN
                -- Variavel idx modificada para idxErro - 03/10/2018 - Chamado INC0024883
                -- Para não entrar em conflito com a variavel idx do loop de arquivos.
                FOR idxErro IN vr_tab_erro2.FIRST .. vr_tab_erro2.LAST
                LOOP
                  --Buscar proxima sequencia de erro
                  vr_index_erro := vr_tab_erro.COUNT + 1;
                  vr_tab_erro(vr_index_erro) := vr_tab_erro2(idxErro);
                  -- Excluido btch0001.pc_gera_log_batch - 15/03/2018 - Chamado 801483
                  -- Incluido controle de Log - 15/03/2018 - Chamado 801483 
                  cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                        ,pr_cdagenci => pr_cdagenci
                                        ,pr_cdprogra => ct_cdprogra
                                        ,pr_idprglog => vr_idprglog
                                        ,pr_dstiplog => 'E'
                                        ,pr_tpocorre => 1
                                        ,pr_dscritic => vr_tab_erro2(idxErro).dscritic
                                                      || ' - Arquivo: integra/' ||
                                                         vr_tab_nmarqtel(idx)
                                        ,pr_cdcritic => 1197
                                        ,pr_cdcricid => 0);
                END LOOP;
              END IF;
              --Limpar tabela titulos
              vr_tab_titulos.DELETE;
            END IF;
            --Proximo registro da tabela descontados
            vr_index_desc := vr_tab_descontar.NEXT(vr_index_desc);
          END LOOP; --vr_tab_descontar
        
          --Se processou
          IF vr_lgdetail THEN
            -- Verifica se é um arquivo REPROC, e neste caso renomeia o arquivo que vai ser gravado 
            -- na pasta salvar, evitando dessa forma que o arquivo anterior seja sobrescrito
            IF vr_inreproc THEN
              -- Montar o nome do arquivo de REPROC
              vr_dsarqrep := SUBSTR(vr_tab_nmarqtel(idx)
                                   ,0
                                   ,(INSTR(vr_tab_nmarqtel(idx), '.', -1) - 1)) -- Nome do arquivo
                             || '_REP_' || GENE0002.fn_busca_time -- Sufixo: REP + Time
                             || SUBSTR(vr_tab_nmarqtel(idx), INSTR(vr_tab_nmarqtel(idx), '.', -1)); -- Extensão do arquivo
              /*  Move arquivo integrado para o diretorio salvar  */
              vr_comando := 'mv ' || vr_caminho_integra || '/' || vr_tab_nmarqtel(idx) || ' ' ||
                            vr_caminho_salvar || '/' || vr_dsarqrep;
            ELSE
              --Move Arquivo diretorio salvar
              vr_comando := 'mv ' || vr_caminho_integra || '/' || vr_tab_nmarqtel(idx) || ' ' ||
                            vr_caminho_salvar || ' 2> /dev/null';
            END IF;
          
            /* Não deve mais executar o comando neste momento!!!
            --Executar o comando no unix
            GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                 ,pr_des_comando => vr_comando
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_dscritic);
            --Se ocorreu erro dar RAISE
            IF vr_typ_saida = 'ERR' THEN
              vr_dscritic:= 'Não foi possível executar comando unix. '||vr_comando;
              RAISE vr_exc_saida;
            END IF;*/
          ELSE
            --Excluir arquivo do integra
            vr_comando := 'rm ' || vr_caminho_integra || '/' || vr_tab_nmarqtel(idx) ||
                          ' 2> /dev/null';
          
          END IF;
        
          -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483 
          -- Guardar o comando para ser executado ao término da execução
          -- Gravar dados na tabela work
          pc_insere_tbgen_batch_rel_wrk(pr_cdcooper    => pr_cdcooper
                                       ,pr_CDPROGRAMA  => ct_cdprogra
                                       ,pr_DSRELATORIO => 'COMANDO'
                                       ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                       ,pr_cdagenci    => pr_cdagenci
                                       ,pr_DSCHAVE     => NULL
                                       ,pr_NRDCONTA    => NULL
                                       ,pr_NRCNVCOB    => NULL
                                       ,pr_NRDOCMTO    => NULL
                                       ,pr_NRCTREMP    => NULL
                                       ,pr_DSDOCCOP    => NULL
                                       ,pr_TPPARCEL    => NULL
                                       ,pr_DTVENCTO    => NULL
                                       ,pr_VLTITULO    => NULL
                                       ,pr_VLDPAGTO    => NULL
                                       ,pr_DSXML       => NULL
                                       ,pr_dscrient    => vr_comando
                                       ,pr_cdcrisai    => vr_cdcritic
                                       ,pr_dscrisai    => vr_dscritic);
          IF NVL(vr_cdcritic, 0) > 0 THEN
            RAISE vr_exc_saida;
          END IF;
        
          -- Como o arquivo ja foi processado, efetua o commit
          -- ***** COMMIT; *** Não deve efetuar o comite neste ponto, pois o mesmo deve
          -- ser executado apenas ao término de todo processamento
        
          --Se houve rejeitado
          IF vr_flgrejei THEN
            vr_cdcritic := 191;
          ELSE
            vr_cdcritic := 190;
          END IF;
          --Buscar descricao da critica
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          --Se houve rejeitado
          IF vr_flgrejei THEN
            -- Incluido controle de Log - Chamado 714566 - 11/08/2017 
            --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
            cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => pr_cdagenci
                                  ,pr_cdprogra => ct_cdprogra
                                  ,pr_idprglog => vr_idprglog
                                  ,pr_dstiplog => 'E'
                                  ,pr_tpocorre => 1
                                  ,pr_dscritic => vr_dscritic || ' - Arquivo: integra/' ||
                                                  vr_tab_nmarqtel(idx)
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_cdcricid => 0);
          ELSE
            -- Incluido controle de Log - Chamado 714566 - 11/08/2017 
            --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
            cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => pr_cdagenci
                                  ,pr_cdprogra => ct_cdprogra
                                  ,pr_idprglog => vr_idprglog
                                  ,pr_dstiplog => 'O'
                                  ,pr_tpocorre => 4
                                  ,pr_dscritic => vr_dscritic || ' - Arquivo: integra/' ||
                                                  vr_tab_nmarqtel(idx)
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_cdcricid => 0);
          END IF;
        END LOOP; --Contador arquivos
      
        /**************************************************************/
        /*************TRATAMENTO P/ COBRANCA REGISTRADA****************/
      
        IF NOT (vr_nmtelant = 'COMPEFORA') THEN
          -- Rotina Paralelismo 3A - Executar Processo JOB
          --                       - Copiar TYPE Consolidado (Tabela) para tabela WRK no Banco
          IF rw_crapdat.inproces > 2 -- Processo Batch
             AND pr_cdagenci > 0 -- Paralelismo
             AND vr_qtdjobs > 0 THEN
            -- Paralelismo
          
            -- Cada Agência gera dados consolidados. Ao final consolida todas as agências.         
            pc_gera_tab_lcm_consolidada(pr_cdcritic            => vr_cdcritic --Codigo Critica
                                       ,pr_dscritic            => vr_dscritic --Descricao Critica
                                       ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada); --Tabela lancamentos consolidada
          
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;
          END IF; --Fim Paralelismo 3A
        END IF; -- NOT COMPEFORA
      
      EXCEPTION
        WHEN vr_exc_final THEN
          -- Ajuste Log - 15/03/2018 - Chamado 801483 
          cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_cdprogra => ct_cdprogra
                                ,pr_idprglog => vr_idprglog
                                ,pr_dstiplog => 'O'
                                ,pr_tpocorre => 4
                                ,pr_dscritic => vr_dscritic || ' - pc_integra_cecred'
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_cdcricid => 0);
          -- Nao tem arquivo para processar ou foi encontrado mais de um arquivo
          pr_cdcritic := NULL;
          pr_dscritic := NULL;
        WHEN vr_exc_saida THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483  
          -- Efetuar retorno do erro nao tratado
          pr_cdcritic := 9999;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                         'CRPS538.pc_integra_cecred' || '. ' || SQLERRM;
      END;
      --
      cobr0014.gerarLogFim(pr_cdcooper      => pr_cdcooper
                          ,pr_cdagenci      => pr_cdagenci
                          ,pr_cdprogra      => ct_cdprogra
                          ,pr_cdprocedure   => ct_cdprocedure
                          ,pr_idprglog      => vr_idprglog
                          ,pr_dscomplemento => NULL
                          ,pr_module_name   => vr_module_name
                          ,pr_action_name   => vr_action_name);
      --
    END pc_integra_cecred;
  
    -- pc_cria_job - Chamado 714566 29/08/2017
    PROCEDURE pc_cria_job(pr_cdcooper_prog IN crapcop.cdcooper%TYPE
                         ,pr_qtminuto      IN NUMBER
                         ,pr_cdcritic      OUT INTEGER
                         ,pr_dscritic      OUT VARCHAR2) IS
      vr_jobname      VARCHAR2(100);
      vr_qtparametros PLS_INTEGER := 1;
    BEGIN
      -- Inclusao do nome do modulo logado - 15/03/2018 - Chamado 801483
      GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra || '.pc_cria_job'
                            ,pr_action => NULL);
    
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
      vr_jobname  := 'JBCOBRAN_PRBA_' || pr_cdcooper_prog || '_' || '$';
    
      --Caso o job não possuir intervalo, significa que é um job paralelo.
      -- que será executado e destruido.
      -- para isso devemos garantir que o nome não se repita
      vr_jobname := dbms_scheduler.generate_job_name(vr_jobname);
      dbms_scheduler.create_job(job_name            => vr_jobname
                               ,job_type            => 'STORED_PROCEDURE'
                               ,job_action          => 'CECRED.PC_CRPS538_1'
                               ,enabled             => FALSE
                               ,number_of_arguments => 5
                               ,start_date          => (SYSDATE + (pr_qtminuto / 1440)) --> Horario da execução
                               ,repeat_interval     => NULL --> apenas uma vez
                                );
      vr_qtparametros := 1;
      dbms_scheduler.set_job_anydata_value(job_name          => vr_jobname
                                          ,argument_position => vr_qtparametros
                                          ,argument_value    => anydata.ConvertNumber(pr_cdcooper_prog));
      vr_qtparametros := 2;
      -- Ajusta o parametro com a regra de evitar o nulo - 21/03/2019 - REQ0037942  
      dbms_scheduler.set_job_anydata_value(job_name          => vr_jobname
                                          ,argument_position => vr_qtparametros
                                          ,argument_value    => anydata.ConvertVarchar2(vr_nmtelant));
      IF vr_inreproc THEN
        vr_dsreproc := 'true';
      ELSE
        vr_dsreproc := 'false';
      END IF;
      vr_qtparametros := 3;
      dbms_scheduler.set_job_anydata_value(job_name          => vr_jobname
                                          ,argument_position => vr_qtparametros
                                          ,argument_value    => anydata.ConvertVarchar2(vr_dsreproc));
      vr_qtparametros := 4;
      dbms_scheduler.set_job_anydata_value(job_name          => vr_jobname
                                          ,argument_position => vr_qtparametros
                                          ,argument_value    => anydata.ConvertVarchar2(vr_tab_nmarqtel(1)));
      vr_qtparametros := 5;
      dbms_scheduler.set_job_anydata_value(job_name          => vr_jobname
                                          ,argument_position => vr_qtparametros
                                          ,argument_value    => anydata.ConvertCollection(vr_typ_craprej_array));
    
      dbms_scheduler.enable(NAME => vr_jobname);
    
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log  
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
        -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483  
        -- Efetuar retorno do erro nao tratado
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                       'CRPS538.pc_cria_job' || '. ' || SQLERRM;
    END pc_cria_job;
  
    -- pc_verifica_ja_executou
    PROCEDURE pc_verifica_ja_executou(pr_dtprocess IN DATE
                                     ,pr_cdcritic  OUT INTEGER
                                     ,pr_dscritic  OUT VARCHAR2) IS
      vr_flultexe INTEGER := NULL;
      vr_qtdexec  INTEGER := NULL;
      vr_cdcritic PLS_INTEGER := NULL;
      vr_dscritic VARCHAR2(4000) := NULL;
    BEGIN
      -- Inclusao do nome do modulo logado - 15/03/2018 - Chamado 801483
      GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra || '.pc_verifica_ja_executou'
                            ,pr_action => NULL);
      -- Verificar a execução
      CECRED.gene0001.pc_controle_exec(pr_cdcooper => pr_cdcooper --> Código da coopertiva
                                      ,pr_cdtipope => 'I' --> Tipo de operacao I-incrementar e C-Consultar
                                      ,pr_dtmvtolt => pr_dtprocess --> Data do movimento
                                      ,pr_cdprogra => ct_cdprogra --> Codigo do programa
                                      ,pr_flultexe => vr_flultexe --> Retorna se é a ultima execução do procedimento
                                      ,pr_qtdexec  => vr_qtdexec --> Retorna a quantidade
                                      ,pr_cdcritic => vr_cdcritic --> Codigo da critica de erro
                                      ,pr_dscritic => vr_dscritic); --> descrição do erro se ocorrer    
      --Trata retorno
      IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483
        IF NVL(vr_cdcritic, 0) = 0 THEN
          vr_cdcritic := 1197; -- Rotina sem codigo de critica na assinatura
          vr_dscritic := vr_dscritic || ' - gene0001.pc_controle_exec';
        END IF;
        RAISE vr_exc_saida;
      END IF;
      -- Retorna nome do modulo logado
      GENE0001.pc_set_modulo(pr_module => ct_cdprogra, pr_action => NULL);
    EXCEPTION
      -- apenas repassar as criticas
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
        -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483  
        -- Efetuar retorno do erro nao tratado
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                       'CRPS538.pc_verifica_ja_executou' || '. ' || SQLERRM;
    END pc_verifica_ja_executou;
  
    -----------------------------------------
    -- Inicio Bloco Principal pc_CRPS538
    -----------------------------------------
  BEGIN
    --
    DECLARE
      --
      ct_cdprocedure CONSTANT tbgen_prglog.cdprograma%TYPE := 'geral';
      vr_module_name VARCHAR2(100) := NULL;
      vr_action_name VARCHAR2(100) := NULL;
      vr_idprocesso  NUMBER(1) := 0; --0=normal;1=compefora
      --
    BEGIN
      --
      dbms_application_info.read_module(module_name => vr_module_name
                                       ,action_name => vr_action_name);
      gene0001.pc_informa_acesso(pr_module => 'PC_' || UPPER(ct_cdprogra), pr_action => NULL);
      --
      cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                            ,pr_cdagenci => pr_cdagenci
                            ,pr_cdprogra => ct_cdprogra
                            ,pr_idprglog => vr_idprglog
                            ,pr_dstiplog => 'I'
                            ,pr_tpocorre => 4
                            ,pr_dscritic => NULL
                            ,pr_cdcritic => NULL
                            ,pr_cdcricid => NULL);
      --
      cobr0014.gerarLogInicio(pr_cdcooper      => pr_cdcooper
                             ,pr_cdagenci      => pr_cdagenci
                             ,pr_cdprogra      => 'PC_' || ct_cdprogra
                             ,pr_cdprocedure   => ct_cdprocedure
                             ,pr_idprglog      => vr_idprglog
                             ,pr_dscomplemento => NULL
                             ,pr_module_name   => vr_module_name
                             ,pr_action_name   => vr_action_name);
      --
      BEGIN
        --Limpar parametros saida
        pr_cdcritic := NULL;
        pr_dscritic := NULL;
      
        --Inicializar variaveis  - Chamado 714566 - 11/08/2017        
        vr_intemarq := FALSE;
      
        -- Caso chegar nulo fixar uma descrição para evitar subrotina mudem a logica - 21/03/2019 - REQ0037942
        IF pr_nmtelant IS NULL THEN
          vr_nmtelant := 'CRPS538';
        ELSE
          vr_nmtelant := pr_nmtelant;
        END IF;
      
        -- Verifica se a cooperativa esta cadastrada
        OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
        FETCH cr_crapcop
          INTO rw_crapcop;
        -- Se nao encontrar
        IF cr_crapcop%NOTFOUND THEN
          -- Fechar o cursor pois havera raise
          CLOSE cr_crapcop;
          -- Montar mensagem de critica
          vr_cdcritic := 651;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_saida;
        ELSE
          -- Apenas fechar o cursor
          CLOSE cr_crapcop;
        END IF;
      
        -- Verifica se a data esta cadastrada
        OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH BTCH0001.cr_crapdat
          INTO rw_crapdat;
        -- Se nao encontrar
        IF BTCH0001.cr_crapdat%NOTFOUND THEN
          -- Fechar o cursor pois havera raise
          CLOSE BTCH0001.cr_crapdat;
          -- Montar mensagem de critica
          vr_cdcritic := 1;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_saida;
        ELSE
          -- Apenas fechar o cursor
          CLOSE BTCH0001.cr_crapdat;
        END IF;
      
        --Determinar batch = false
        vr_flgbatch := 0;
        vr_datailog := SYSDATE;
        vr_horailog := GENE0002.fn_busca_time;
      
        --Carregar tabela memoria convenios
        FOR rw_crapcco IN cr_crapcco
        LOOP
          vr_index_crapcco := lpad(rw_crapcco.cdcooper, 10, '0') ||
                              lpad(rw_crapcco.nrconven, 10, '0');
          vr_tab_crapcco(vr_index_crapcco).nrconven := rw_crapcco.nrconven;
          vr_tab_crapcco(vr_index_crapcco).cdcooper := rw_crapcco.cdcooper;
          vr_tab_crapcco(vr_index_crapcco).cdagenci := rw_crapcco.cdagenci;
          vr_tab_crapcco(vr_index_crapcco).cdbccxlt := rw_crapcco.cdbccxlt;
          vr_tab_crapcco(vr_index_crapcco).nrdolote := rw_crapcco.nrdolote;
          vr_tab_crapcco(vr_index_crapcco).flgativo := rw_crapcco.flgativo;
          vr_tab_crapcco(vr_index_crapcco).cddbanco := rw_crapcco.cddbanco;
          vr_tab_crapcco(vr_index_crapcco).nrdctabb := rw_crapcco.nrdctabb;
          vr_tab_crapcco(vr_index_crapcco).dsorgarq := rw_crapcco.dsorgarq;
          vr_tab_crapcco(vr_index_crapcco).flgregis := rw_crapcco.flgregis;
          vr_tab_crapcco(vr_index_crapcco).cdcopant := NULL;
          vr_tab_crapcco(vr_index_crapcco).dsorgant := NULL;
        
          IF rw_crapcco.dsorgarq IN ('MIGRACAO', 'INCORPORACAO') THEN
            -- verificar se o convenio migrado é 'IMPRESSO PELO SOFTWARE'
            OPEN cr_cco_impresso(pr_nrconven => rw_crapcco.nrconven);
            FETCH cr_cco_impresso
              INTO rw_cco_impresso;
            IF cr_cco_impresso%FOUND THEN
              vr_tab_crapcco(vr_index_crapcco).cdcopant := rw_cco_impresso.cdcooper;
              vr_tab_crapcco(vr_index_crapcco).dsorgant := rw_cco_impresso.dsorgarq;
            END IF;
            IF cr_cco_impresso%ISOPEN THEN
              CLOSE cr_cco_impresso;
            END IF;
          END IF;
        
        END LOOP;
      
        --Carregar tabela memoria contas migradas
        FOR rw_craptco IN cr_craptco(pr_cdcooper => pr_cdcooper)
        LOOP
          vr_tab_craptco(rw_craptco.nrctaant).cdcooper := rw_craptco.cdcooper;
          vr_tab_craptco(rw_craptco.nrctaant).nrdconta := rw_craptco.nrdconta;
          vr_tab_craptco(rw_craptco.nrctaant).cdcopant := rw_craptco.cdcopant;
          vr_tab_craptco(rw_craptco.nrctaant).nrctaant := rw_craptco.nrctaant;
        END LOOP;
      
        --Carregar tabela memoria de motivos
        FOR rw_crapmot IN cr_crapmot(pr_cdcooper => pr_cdcooper)
        LOOP
          --Montar Indice para tabela
          vr_index_crapmot := lpad(rw_crapmot.cddbanco, 5, '0') ||
                              lpad(rw_crapmot.cdocorre, 5, '0') ||
                              lpad(rw_crapmot.tpocorre, 5, '0') ||
                              lpad(rw_crapmot.cdmotivo, 2, '0');
          vr_tab_crapmot(vr_index_crapmot) := rw_crapmot.dsmotivo;
        END LOOP;
      
        /* Le tabela Parametros */
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => 'EXECUTAABBC'
                                                 ,pr_tpregist => 0);
      
        --Se encontrou
        IF TRIM(vr_dstextab) IS NOT NULL THEN
          IF UPPER(vr_dstextab) != 'SIM' THEN
            --Levantar Excecao Fimprg
            RAISE vr_exc_fimprg;
          END IF;
        ELSE
          --Levantar Excecao Fimprg
          RAISE vr_exc_fimprg;
        END IF;
        -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
        GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
      
        --Filtro arquivo retorno
        vr_nmarqret := '29999%.RET'; /* Sua REMESSA e erros enviados */
      
        -- Retorna módulo e ação logado - Chamado 714566 - 11/08/2017
        GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
      
        --Buscar Diretorio Integracao da Cooperativa
        vr_caminho_puro    := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                   ,pr_cdcooper => pr_cdcooper
                                                   ,pr_nmsubdir => NULL);
        vr_caminho_integra := vr_caminho_puro || '/integra';
      
        -- Buscar o diretorio padrao da cooperativa conectada
        vr_caminho_salvar := vr_caminho_puro || '/salvar';
      
        -- Buscar o diretorio padrao da cooperativa conectada
        vr_caminho_rl := vr_caminho_puro || '/rl';
      
        -- Ajusta o parametro com a regra de evitar o nulo - 21/03/2019 - REQ0037942  
        IF vr_nmtelant = 'COMPEFORA' THEN
          --Data leitura arquivo
          vr_dtleiarq   := to_char(rw_crapdat.dtmvtoan, 'YYYYMMDD');
          vr_idprocesso := 1;
        ELSE
          --Data leitura arquivo
          vr_dtleiarq := to_char(rw_crapdat.dtmvtolt, 'YYYYMMDD');
        END IF;
      
        -- Buscar quantidade parametrizada de Jobs - 03/01/2018
        vr_qtdjobs := gene0001.fn_retorna_qt_paralelo(pr_cdcooper --pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da coopertiva
                                                     ,ct_cdprogra); --pr_cdprogra  IN crapprg.cdprogra%TYPE --> Código do programa
      
      IF NOT (vr_nmtelant = 'COMPEFORA') THEN
        -- Rotina Paralelismo 1 - Processar quando não utiliza JOB ou é Executor Principal do Paralelismo
        --                      - Efetuar primeiras Validações
        --                      - Executar integracao todas cooperativas
        IF (rw_crapdat.inproces > 2 --  >2 Processo Batch
           AND pr_cdagenci = 0 --  0=execução normal  >0 Paralelismo
           AND vr_qtdjobs > 0) --  0=execução normar  >0 Paralelismo (Executor Principal)
           OR (rw_crapdat.inproces <= 2) --  1=On Line  2=Agendado             (Não utiliza JOB)
           OR (vr_qtdjobs) = 0 THEN
          --  0=execução normar  >0 Paralelismo (Nãp utiliza JOB)
        
          -- Log controle processo
          --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
          vr_cdcritic := 1201;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' - 02 inicio - ' ||
                         pr_cdagenci;
          cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_cdprogra => ct_cdprogra
                                ,pr_idprglog => vr_idprglog
                                ,pr_dstiplog => 'O'
                                ,pr_tpocorre => 4
                                ,pr_dscritic => vr_dscritic
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_cdcricid => 0);
          vr_cdcritic := NULL;
          vr_dscritic := NULL;
        
          -- Validacoes iniciais do programa
          BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                                   ,pr_flgbatch => vr_flgbatch
                                   ,pr_cdprogra => ct_cdprogra
                                   ,pr_infimsol => pr_infimsol
                                   ,pr_cdcritic => vr_cdcritic);
        
          --Se retornou critica aborta programa
          IF vr_cdcritic <> 0 THEN
            --Descricao do erro recebe mensagam da critica
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            -- Excluido pc_controla_log_batch - 15/03/2018 - Chamado 801483 
            --Sair do programa
            RAISE vr_exc_saida;
          END IF;
          -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
          GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
        
          -- Verifica se programa já executou
          pc_verifica_ja_executou(pr_dtprocess => TO_DATE(vr_dtleiarq, 'YYYYMMDD')
                                 ,pr_cdcritic  => vr_cdcritic
                                 ,pr_dscritic  => vr_dscritic);
        
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_saida;
          END IF;
        
          -- Excluido o Log pelo motivo que coloquei no inicio da rotina - 15/03/2018 - Chamado 801483                                        
          -- Excluida condição IF vr_idparale = 0, ficou perdida conforme Mario - 15/03/2018 - Chamado 801483 
        
          -- Verifica se algum job paralelo executou com erro
          vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper
                                                       ,pr_cdprogra    => ct_cdprogra
                                                       ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                                       ,pr_tpagrupador => 1
                                                       ,pr_nrexecucao  => 1);
        
          --Limpa tabelas de Work Consolidadas
          IF vr_qterro = 0 THEN
            -- quando não Restart    
            BEGIN
              DELETE TBGEN_BATCH_RELATORIO_WRK
               WHERE cdcooper = pr_cdcooper
                 AND cdprograma = ct_cdprogra
                 AND TO_CHAR(dtmvtolt, 'YYYYMMDD') = TO_CHAR(rw_crapdat.dtmvtolt, 'YYYYMMDD');
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log
                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                -- Ajuste Mensagem - 15/03/2018 - Chamado 801483 
                vr_cdcritic := 1037;
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                               ' TBGEN_BATCH_RELATORIO_WRK(2):' || ' cdcooper:' || pr_cdcooper ||
                               ', cdprograma:' || ct_cdprogra || ', dtmvtolt:' ||
                               TO_CHAR(rw_crapdat.dtmvtolt, 'YYYYMMDD') || '. ' || SQLERRM;
                -- Inclusão do Raise - Mario - 15/03/2018 - Chamado 801483       
                --Levantar Excecao
                RAISE vr_exc_saida;
            END;
          END IF;
        
          --Se nao for Cecred
          IF pr_cdcooper <> 3 THEN
            --Conciliar os arquivos da NOSSA REMESSA
            paga0006.conciliarNossaRemessaCobranca(pr_cdcooper   => pr_cdcooper
                                                  ,pr_cdagenci   => pr_cdagenci
                                                  ,pr_idprglog   => vr_idprglog
                                                  ,pr_idprocesso => vr_idprocesso
                                                  ,pr_cdcritic   => vr_cdcritic
                                                  ,pr_dscritic   => vr_dscritic);
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;
          END IF;
        END IF; --Fim Paralelismo 1;
      
        -- Rotina Paralelismo 2 - Processo do Executor Principal do Paralelismo
        --                      - Selecionar Agencias para o Processo JOB, 
        --                      - Cria JOBS Paralelos e controle encerramento destes JOBS
        IF rw_crapdat.inproces > 2 -- Processo Batch
           AND pr_cdagenci = 0 -- Execução sem paralelismo
           AND vr_qtdjobs > 0 THEN
          -- Execução do paralelismo
          --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
          vr_cdcritic := 1201;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' - ' ||
                         vr_caminho_integra || ' - 03 Controla JOBS - ' || pr_cdagenci;
          cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_cdprogra => ct_cdprogra
                                ,pr_idprglog => vr_idprglog
                                ,pr_dstiplog => 'O'
                                ,pr_tpocorre => 4
                                ,pr_dscritic => vr_dscritic
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_cdcricid => 0);
          vr_cdcritic := NULL;
          vr_dscritic := NULL;
        
          --Listar arquivos no diretorio
          gene0001.pc_lista_arquivos(pr_path     => vr_caminho_integra
                                    ,pr_pesq     => vr_nmarqret
                                    ,pr_listarq  => vr_listadir
                                    ,pr_des_erro => vr_dscritic);
          --Se ocorreu erro
          IF vr_dscritic IS NOT NULL THEN
            --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483
            vr_cdcritic := 1197; -- Rotina sem codigo de critica na assinatura
            --Levantar Excecao
            RAISE vr_exc_saida;
          END IF;
          -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
          GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
        
          --Montar vetor com nomes dos arquivos
          vr_tab_nmarqtel := GENE0002.fn_quebra_string(pr_string => vr_listadir);
        
          --Gerar o ID para o paralelismo
          vr_idparale := gene0001.fn_gera_ID_paralelo;
        
          -- Retorna as agências, com poupança programada
          FOR rw_crapass_age IN cr_crapass_age(pr_cdcooper
                                              ,TO_DATE(vr_dtleiarq, 'YYYYMMDD')
                                              ,ct_cdprogra)
          LOOP
          
            -- Montar o prefixo do código do programa para o jobname
            vr_jobname := 'crps538_' || rw_crapass_age.cdagenci || '$';
          
            -- pr_dscritic para vr_dscritic - 15/03/2018 - Chamado 801483   
            -- Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
            -- Cadastra o programa paralelo
            gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                      ,pr_idprogra => LPAD(rw_crapass_age.cdagenci, 3, '0') --> Utiliza a agência como id programa
                                      ,pr_des_erro => vr_dscritic);
          
            -- Testar saida com erro
            IF vr_dscritic IS NOT NULL THEN
              vr_cdcritic := 1197; -- Rotina sem codigo de critica na assinatura
              -- Levantar exceçao
              RAISE vr_exc_saida;
            END IF;
            -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
            GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
          
            -- Montar o bloco PLSQL que será executado
            -- Ou seja, executaremos a geração dos dados
            -- para a agência atual atraves de Job no banco
            vr_dsplsql := 'DECLARE' || chr(13) || --
                          '  wpr_stprogra NUMBER;' || chr(13) || --
                          '  wpr_infimsol NUMBER;' || chr(13) || --
                          '  wpr_cdcritic NUMBER;' || chr(13) || --
                          '  wpr_dscritic VARCHAR2(1500);' || chr(13) || --
                          'BEGIN' || chr(13) || --
                          '  CECRED.pc_crps538( ' || pr_cdcooper || ',' || rw_crapass_age.cdagenci || ',' ||
                          vr_idparale || ', 0, NULL,' ||
                          ' wpr_stprogra, wpr_infimsol, wpr_cdcritic, wpr_dscritic);' || chr(13) || --
                          'END;'; --  
          
            -- Faz a chamada ao programa paralelo atraves de JOB
            gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper --> Código da cooperativa
                                  ,pr_cdprogra => ct_cdprogra --> Código do programa
                                  ,pr_dsplsql  => vr_dsplsql --> Bloco PLSQL a executar
                                  ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                                  ,pr_interva  => NULL --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                                  ,pr_jobname  => vr_jobname --> Nome randomico criado
                                  ,pr_des_erro => vr_dscritic);
          
            -- Testar saida com erro
            IF vr_dscritic IS NOT NULL THEN
              -- Levantar exceçao
              RAISE vr_exc_saida;
            END IF;
            -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
            GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
          
            -- Chama rotina que irá pausar este processo controlador
            -- caso tenhamos excedido a quantidade de JOBS em execuçao
            gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                        ,pr_qtdproce => vr_qtdjobs --> Máximo de 10 jobs neste processo
                                        ,pr_des_erro => vr_dscritic);
            -- Testar saida com erro
            IF vr_dscritic IS NOT NULL THEN
              -- Levantar exceçao
              RAISE vr_exc_saida;
            END IF;
            -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
            GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
          END LOOP;
        
          -- Chama rotina de aguardo agora passando 0, para esperarmos
          -- até que todos os Jobs tenha finalizado seu processamento
          gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                      ,pr_qtdproce => 0
                                      ,pr_des_erro => vr_dscritic);
          -- Testar saida com erro
          IF vr_dscritic IS NOT NULL THEN
            -- Levantar exceçao
            RAISE vr_exc_saida;
          END IF;
          -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
          GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
        
          -- Retorna quantidade de PA/gências c/erro para finalizar com erro a rotina principal - 15/03/2018 - Chamado 801483 
          vr_tot_paerr := 0;
          FOR rw_crapass_err IN cr_crapass_err(pr_cdcooper
                                              ,TO_DATE(vr_dtleiarq, 'YYYYMMDD')
                                              ,ct_cdprogra)
          LOOP
            vr_tot_paerr := vr_tot_paerr + 1;
            EXIT;
          END LOOP;
        
          -- Se retornar registros deu erro em algum ou alguns Jobs
          IF vr_tot_paerr > 0 THEN
            vr_cdcritic := 1201;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                           ' - 99 Paralelo com critica';
            --Levantar Excecao
            RAISE vr_exc_saida;
          END IF;
        
          -- Excluido cr_erro/controle de restart pelo motivo que não é utilizado e confirmei com o Mario - 15/03/2018 - Chamado 801483
        
          -- Copia tabela WRK do Banco para TYPE Consolidado (Tabela)
          -- Cada Agência gera dados consolidados.                             
          pc_carga_tab_lcm_consolidada(pr_cdcritic            => vr_cdcritic --Codigo Critica
                                      ,pr_dscritic            => vr_dscritic --Descricao Critica
                                      ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada); --Tabela lancamentos consolidada
        
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_saida;
          END IF;
        END IF;
      END IF; -- NOT COMPEFORA
      
        -- Rotina Paralelismo 3 - Processar quando JOB ou Não Paralelismmo
        --                      - Executar Integracao Cecred
        --                      - executar Cobranca (Emprestimo/Acordo)
        IF (rw_crapdat.inproces > 2 -- Processo Batch
           AND pr_cdagenci > 0 -- Agencia
           AND vr_qtdjobs > 0) -- Quantidade de jobs simultaneos
           OR (vr_qtdjobs = 0) -- ou não utiliza JOB
           OR (rw_crapdat.inproces <= 2) THEN
          -- ou processo On Line/Agendado    
        
          -- Buscar informações da poupança programada

        IF NOT (vr_nmtelant = 'COMPEFORA') THEN
        
          -- Controla execucao dos JOBS
          IF (rw_crapdat.inproces > 2 -- Processo Batch
             AND pr_cdagenci > 0 -- Agencia
             AND vr_qtdjobs > 0) THEN
            -- Quantidade de jobs simultaneos
          
            -- Grava controle de batch por agência
            gene0001.pc_grava_batch_controle(pr_cdcooper --pr_cdcooper    IN tbgen_batch_controle.cdcooper%TYPE    -- Codigo da Cooperativa
                                            ,ct_cdprogra --pr_cdprogra    IN tbgen_batch_controle.cdprogra%TYPE    -- Codigo do Programa
                                            ,TO_DATE(vr_dtleiarq, 'YYYYMMDD') --pr_dtmvtolt    IN tbgen_batch_controle.dtmvtolt%TYPE    -- Data de Movimento
                                            ,1 --pr_tpagrupador IN tbgen_batch_controle.tpagrupador%TYPE -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                            ,pr_cdagenci --pr_cdagrupador IN tbgen_batch_controle.cdagrupador%TYPE -- Codigo do agrupador conforme (tpagrupador)
                                            ,NULL --pr_cdrestart   IN tbgen_batch_controle.cdrestart%TYPE   -- Controle do registro de restart em caso de erro na execucao
                                            ,1 --pr_nrexecucao  IN tbgen_batch_controle.nrexecucao%TYPE  -- Numero de identificacao da execucao do programa
                                            ,vr_idcontrole --pr_idcontrole OUT tbgen_batch_controle.idcontrole%TYPE  -- ID de Controle
                                            ,vr_cdcritic --pr_cdcritic   OUT crapcri.cdcritic%TYPE                 -- Codigo da critica
                                            ,vr_dscritic --pr_dscritic   OUT crapcri.dscritic%TYPE
                                             );
            -- Ligado tratamento de critica conf Mario - 15/03/2018 - Chamado 801483           
            -- Testar saida com erro
            IF vr_dscritic IS NOT NULL THEN
              -- Levantar exceçao
              RAISE vr_exc_saida;
            END IF;
          
            -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
            GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
          
            -- Excluido o pc_log_programa pelo motivo que coloquei no inicio da rotina - 15/03/2018 - Chamado 801483  
            --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
          
          END IF;

        END IF; -- NOT COMPEFORA
        
          --Executar Integracao Cecred  ***************
          pc_integra_cecred(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic);
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_saida;
          END IF;
        
          -- Log Quantidade de registros processados
          --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
          vr_cdcritic := 1201;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         ' - 05 Total registros processados PA ' || pr_cdagenci || ' ..: ' ||
                         vr_tot_reg;
          cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_cdprogra => ct_cdprogra
                                ,pr_idprglog => vr_idprglog
                                ,pr_dstiplog => 'O'
                                ,pr_tpocorre => 4
                                ,pr_dscritic => vr_dscritic
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_cdcricid => 0);
          vr_cdcritic := NULL;
          vr_dscritic := NULL;
        
          --Executar Integracao Cobrança Registrada *****************
          pc_integra_cobranca_registrada(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic);
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_saida;
          END IF;
        
          -- Incluido controle de Log - Chamado 714566 - 11/08/2017 
          vr_cdcritic := 1201;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         ' - 10 Inicio Lancamento Tarifas. PA ' || pr_cdagenci;
          --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
          cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_cdprogra => ct_cdprogra
                                ,pr_idprglog => vr_idprglog
                                ,pr_dstiplog => 'O'
                                ,pr_tpocorre => 4
                                ,pr_dscritic => vr_dscritic
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_cdcricid => 0);
          vr_cdcritic := NULL;
          vr_dscritic := NULL;
        
          -- Lancamento Tarifas
          PAGA0001.pc_efetua_lancto_tarifas_lat(pr_cdcooper            => pr_cdcooper --Codigo Cooperativa
                                               ,pr_dtmvtolt            => rw_crapdat.dtmvtolt --Data Movimento
                                               ,pr_tab_lat_consolidada => vr_tab_lat_consolidada --Tabela Lancamentos
                                               ,pr_cdcritic            => vr_cdcritic --Codigo Erro
                                               ,pr_dscritic            => vr_dscritic); --Descricao Erro
        
          --Se Ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_saida;
          END IF;
          -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
          GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
        
          -- Incluido controle de Log - Chamado 714566 - 11/08/2017 
          --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
          vr_cdcritic := 1201;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         ' - 11 Fim Lancamento Tarifas. PA ' || pr_cdagenci;
          cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_cdprogra => ct_cdprogra
                                ,pr_idprglog => vr_idprglog
                                ,pr_dstiplog => 'O'
                                ,pr_tpocorre => 4
                                ,pr_dscritic => vr_dscritic
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_cdcricid => 0);
          vr_cdcritic := NULL;
          vr_dscritic := NULL;
        
          -- Excluido o pc_log_programa pelo motivo que coloquei no fim da rotina - 15/03/2018 - Chamado 801483
        END IF; -- Fim Paralelismo 3
      
      IF NOT (vr_nmtelant = 'COMPEFORA') THEN

        --Executar Integracao Cobrança Resigstrada ******************
      
        -- Rotina Paralelismo 4 - Processo Principal JOB - Objetiva tratar o Credito Cooperado
        --                      - Processar pc_integra_registro_cobranca
        IF (rw_crapdat.inproces > 2 -- Processo Batch
           AND pr_cdagenci = 0 -- Não Paralelismo
           AND vr_qtdjobs > 0) THEN
          -- Paralelismo
        
          -- Log Inicio Cobranca
          --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
          vr_cdcritic := 1201;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         ' - 06 Cobranca (Principal) AG= ' || pr_cdagenci;
          cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_cdprogra => ct_cdprogra
                                ,pr_idprglog => vr_idprglog
                                ,pr_dstiplog => 'O'
                                ,pr_tpocorre => 4
                                ,pr_dscritic => vr_dscritic
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_cdcricid => 0);
          vr_cdcritic := NULL;
          vr_dscritic := NULL;
        
          --Executar Integracao Cobrança Registrada *****************
          pc_integra_cobranca_registrada(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic);
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_saida;
          END IF;
        END IF; -- Fim Paralelismo 4

      END IF; -- NOT COMPEFORA
      
        -- Incluir nome do modulo logado
        GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
      
        -- Rotina Paralelismo 5 - Processar Executor Principal do Paralelismo ou não Processo JOB
        --                      - Gerar Relatórios 618, 706
        --                      - Processar PAGA0001.pc_efetua_lancto_tarifas_lat
        --                      - Gerar e-mail das inconsistências
        --                      - Ativar Comandos para salvamento do Arquivo ABBC
        IF (rw_crapdat.inproces > 2 -- Processo Batch
           AND pr_cdagenci = 0 -- Não Paralelismo
           AND vr_qtdjobs > 0) -- Paralelismo
           OR (rw_crapdat.inproces <= 2) -- Não Paralelismo
           OR (vr_qtdjobs = 0) THEN
          -- Não Paralelismo
        
          -- Incluido controle de Log - Chamado 714566 - 11/08/2017 
          --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
          vr_cdcritic := 1201;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         ' - 12 Inicio Geracao Log CRAPCOL';
          cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_cdprogra => ct_cdprogra
                                ,pr_idprglog => vr_idprglog
                                ,pr_dstiplog => 'O'
                                ,pr_tpocorre => 4
                                ,pr_dscritic => vr_dscritic
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_cdcricid => 0);
          vr_cdcritic := NULL;
          vr_dscritic := NULL;
        
          --Montar data e hora para log
          vr_dataflog := SYSDATE;
          vr_horaflog := GENE0002.fn_busca_time;
          vr_descorpo := NULL;
        
          --Escrever Criticas no LOG
          FOR rw_crapcol IN cr_crapcol(pr_cdcooper => pr_cdcooper
                                      ,pr_cdoperad => 'TARIFA'
                                      ,pr_datailog => vr_datailog
                                      ,pr_dataflog => vr_dataflog
                                      ,pr_horailog => vr_horailog
                                      ,pr_horaflog => vr_horaflog)
          LOOP
          
            -- Tratamento para que se estourar o tamanho da mensagem não aborte o processo
            -- e envia as informações montadas até o momento, visto que muitas das informações se repetem
            BEGIN
              vr_descorpo := vr_descorpo || to_char(SYSDATE, 'hh24:mi:ss') || ' - ' || ct_cdprogra ||
                             ' --> ' || rw_crapcol.dslogtit || '<br>';
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log
                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            END;
          END LOOP;
        
          -- se encontrou alguma critica envia por email para a area responsavel
          IF vr_descorpo IS NOT NULL THEN
            vr_email_tarif := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                       ,pr_cdcooper => pr_cdcooper
                                                       ,pr_cdacesso => 'EMAIL_TARIF');
          
            -- Se não encontrar e-mail cadastrado no parametro, deve mandar 
            -- para o e-mail da cobrança da CECRED ( Renato - Supero )
            IF vr_email_tarif IS NULL THEN
              vr_email_tarif := 'cobranca@ailos.coop.br';
            END IF;
          
            /* Envio do arquivo detalhado via e-mail */
            gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                      ,pr_cdprogra        => ct_cdprogra
                                      ,pr_des_destino     => vr_email_tarif
                                      ,pr_des_assunto     => 'Erros log de tarifas (' ||
                                                             rw_crapcop.nmrescop || ')'
                                      ,pr_des_corpo       => 'Segue a lista de criticas de Tarifa (' ||
                                                             ct_cdprogra || '): <br><br>' ||
                                                             vr_descorpo
                                      ,pr_des_anexo       => NULL
                                      ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                      ,pr_flg_remete_coop => 'N' --> Se o envio será do e-mail da Cooperativa
                                      ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                      ,pr_des_erro        => vr_dscritic);
            -- Se ocorrer erro 
            IF vr_dscritic IS NOT NULL THEN
              -- Incluido controle de Log - Chamado 714566 - 11/08/2017 
              --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483
              vr_cdcritic := 1197; -- Rotina sem codigo de critica na assinatura
              vr_dscritic := vr_dscritic || ' - gene0003.pc_solicita_email';
              cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => pr_cdagenci
                                    ,pr_cdprogra => ct_cdprogra
                                    ,pr_idprglog => vr_idprglog
                                    ,pr_dstiplog => 'E'
                                    ,pr_tpocorre => 1
                                    ,pr_dscritic => vr_dscritic
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_cdcricid => 0);
              -- Limpar a mensagem de erro
              vr_cdcritic := NULL;
              vr_dscritic := NULL;
            END IF;
          END IF;
          -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
          GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
        
          -- Incluido controle de Log - Chamado 714566 - 11/08/2017 
          --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
          vr_cdcritic := 1201;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         ' - 13 Fim Geracao Log CRAPCOL';
          cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_cdprogra => ct_cdprogra
                                ,pr_idprglog => vr_idprglog
                                ,pr_dstiplog => 'O'
                                ,pr_tpocorre => 4
                                ,pr_dscritic => vr_dscritic
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_cdcricid => 0);
          vr_cdcritic := NULL;
          vr_dscritic := NULL;
        
          -- Retorna quantidade de PA (agências) com erro para reprocesso
          vr_tot_paerr := 0;
          FOR rw_crapass_err IN cr_crapass_err(pr_cdcooper
                                              ,TO_DATE(vr_dtleiarq, 'YYYYMMDD')
                                              ,ct_cdprogra)
          LOOP
            vr_tot_paerr := vr_tot_paerr + 1;
          END LOOP;
        
          -- Segue o processamento caso não existam PA's com erro
          IF vr_tot_paerr = 0 THEN
          
            --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
            vr_cdcritic := 1201;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                           ' - 14 Relatórios: ' || pr_cdagenci;
            cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => pr_cdagenci
                                  ,pr_cdprogra => ct_cdprogra
                                  ,pr_idprglog => vr_idprglog
                                  ,pr_dstiplog => 'O'
                                  ,pr_tpocorre => 4
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_cdcricid => 0);
            vr_cdcritic := NULL;
            vr_dscritic := NULL;
          
            --Se existem dados no relatorio 618
            --Gerar relatorio 618
            pc_gera_relatorio_618(pr_cdcooper => pr_cdcooper
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
          
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;
          
            --Alterado local da rotina - 03.01.2018
            --Gerar relatorio 706
            pc_gera_relatorio_706(pr_cdcooper => pr_cdcooper
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;
          
            -- Processa comandos do UNIX
            FOR rw_crapcom IN cr_crapcom(pr_cdcooper    => pr_cdcooper
                                        ,pr_cdprograma  => ct_cdprogra
                                        ,pr_dsrelatorio => 'COMANDO'
                                        ,pr_dtmvtolt    => rw_crapdat.dtmvtolt)
            LOOP
              IF cr_crapcom%FOUND THEN
                -- Obtem o comando unix
                vr_comando := rw_crapcom.dscritic;
              
                -- marca que houve processo - Chamado 714566 - 11/08/2017
                vr_intemarq := TRUE;
              END IF;
            
              -- Log Visualizar comando unix
              --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
              vr_cdcritic := 1201;
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                             ' - 15 Comando: ' || vr_index_comando || ' => ' || vr_comando;
              cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => pr_cdagenci
                                    ,pr_cdprogra => ct_cdprogra
                                    ,pr_idprglog => vr_idprglog
                                    ,pr_dstiplog => 'O'
                                    ,pr_tpocorre => 4
                                    ,pr_dscritic => vr_dscritic
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_cdcricid => 0);
              vr_cdcritic := NULL;
              vr_dscritic := NULL;
            
              BEGIN
                -- Executar o comando no unix
                GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                     ,pr_des_comando => vr_comando
                                     ,pr_typ_saida   => vr_typ_saida
                                     ,pr_des_saida   => vr_dscritic);
                -- Se ocorreu erro
                IF vr_typ_saida = 'ERR' THEN
                  --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
                  vr_cdcritic := 1114; --Nao foi possivel executar comando unix
                  vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' ' ||
                                 vr_comando;
                  cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                        ,pr_cdagenci => pr_cdagenci
                                        ,pr_cdprogra => ct_cdprogra
                                        ,pr_idprglog => vr_idprglog
                                        ,pr_dstiplog => 'E'
                                        ,pr_tpocorre => 1
                                        ,pr_dscritic => vr_dscritic
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_cdcricid => 0);
                  -- Limpar variável de erro
                  vr_cdcritic := NULL;
                  vr_dscritic := NULL;
                END IF;
              EXCEPTION
                WHEN OTHERS THEN
                  -- No caso de erro de programa gravar tabela especifica de log
                  CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
              END;
            END LOOP;
          END IF; -- vr_tot_paerr
        END IF; -- Fim Paralelismo 5
      
      IF NOT (vr_nmtelant = 'COMPEFORA') THEN

        --
        -- Rotina Paralelismo 6 - Executar Processo JOB
        --                      - Finaliza o Paralismo do JOB Arquivo ABBC
        IF rw_crapdat.inproces > 2 -- Processo Batch
           AND pr_cdagenci > 0 -- Paralelismo
           AND vr_qtdjobs > 0 THEN
          -- Paralelismo
        
          -- Atualiza finalização do batch na tabela de controle 
          IF vr_idcontrole <> 0 THEN
            gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole --ID de Controle
                                               ,pr_cdcritic   => vr_cdcritic --Codigo da critica
                                               ,pr_dscritic   => vr_dscritic);
            -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483 
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;
            -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
            GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
          END IF;
          -- Incluido controle de Log fim programa - Chamado 714566 - 11/08/2017 
          --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
          vr_cdcritic := 1201;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         ' - 16 Fim crps538 - ' || pr_cdagenci;
          cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_cdprogra => ct_cdprogra
                                ,pr_idprglog => vr_idprglog
                                ,pr_dstiplog => 'O'
                                ,pr_tpocorre => 4
                                ,pr_dscritic => vr_dscritic
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_cdcricid => 0);
          vr_cdcritic := NULL;
          vr_dscritic := NULL;
        
          --Salvar informacoes no banco de dados
          COMMIT;
          --Finaliza sessão aberta com SQL SERVER
          npcb0002.pc_libera_sessao_sqlserver_npc('PC_CRPS538_1');
          -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483 
          --INC0018458
          GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
        
          -- Encerrar o job do processamento paralelo dessa agência
          gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                      ,pr_idprogra => LPAD(pr_cdagenci, 3, '0')
                                      ,pr_des_erro => vr_dscritic);
          -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483 
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_saida;
          END IF;
          -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
          GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
        
        END IF; -- Fim Paralelismo 6

      END IF; -- NOT COMPEFORA
      
        -- Rotina Paralelismo 7 - Executar principal ou Não Paralelismo
        --                      - Preparar a tabela CRATREJ para chamada do CRPS538_1
        IF (rw_crapdat.inproces > 2 -- Processo Batch
           AND pr_cdagenci = 0 -- Não Paralelismo
           AND vr_qtdjobs > 0) -- Paralelismo
           OR (rw_crapdat.inproces <= 2) -- Processo On Line/Agendado
           OR (vr_qtdjobs = 0) THEN
          -- Não Paralelismo

        IF NOT (vr_nmtelant = 'COMPEFORA') THEN
        
          -- Processo OK, devemos chamar a fimprg
          btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                   ,pr_cdprogra => ct_cdprogra
                                   ,pr_infimsol => pr_infimsol
                                   ,pr_stprogra => pr_stprogra);
        
          IF vr_idcontrole <> 0 THEN
            -- Atualiza finalização do batch na tabela de controle 
            gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole --ID de Controle
                                               ,pr_cdcritic   => vr_cdcritic --Codigo da critica
                                               ,pr_dscritic   => vr_dscritic);
            -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483 
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;
            -- Retorna nome do modulo logado - 15/03/2018 - Chamado 801483
            GENE0001.pc_set_modulo(pr_module => 'PC_' || ct_cdprogra, pr_action => NULL);
          END IF;

        END IF; -- NOT COMPEFORA
        
          -- Excluido o pc_log_programa pelo motivo que coloquei no fim da rotina - 15/03/2018 - Chamado 801483
        
          --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
          vr_cdcritic := 1201;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         ' - 17 Fim crps538 ' || pr_cdagenci;
          cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_cdprogra => ct_cdprogra
                                ,pr_idprglog => vr_idprglog
                                ,pr_dstiplog => 'O'
                                ,pr_tpocorre => 4
                                ,pr_dscritic => vr_dscritic
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_cdcricid => 0);
          vr_cdcritic := NULL;
          vr_dscritic := NULL;
        
          --Salvar informacoes no banco de dados
          COMMIT;
          --Finaliza sessão aberta com SQL SERVER
          npcb0002.pc_libera_sessao_sqlserver_npc('PC_CRPS538_2');
        
          -- Segue processamento saoso não possua PA's com erro.
          IF vr_tot_paerr = 0 THEN

          IF NOT (vr_nmtelant = 'COMPEFORA') THEN
          
            -- Controle para disparar parte desmembrada 1 - Chamado 714566 - 11/08/2017               
            -- tem arquivo para processar
            IF vr_intemarq THEN
              --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
              vr_cdcritic := 1201;
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                             ' - 18 Carga cratrej - Chamada crps538_1.';
              cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => pr_cdagenci
                                    ,pr_cdprogra => ct_cdprogra
                                    ,pr_idprglog => vr_idprglog
                                    ,pr_dstiplog => 'O'
                                    ,pr_tpocorre => 4
                                    ,pr_dscritic => vr_dscritic
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_cdcricid => 0);
              vr_cdcritic := NULL;
              vr_dscritic := NULL;
            
              --Atualizar tabela memoria cratrej (Copia WRK para TYPE)
              pc_carga_cratrej;
              -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483 
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_saida;
              END IF;
            
              pc_cria_job(pr_cdcooper_prog => pr_cdcooper
                         ,pr_qtminuto      => 4
                         ,pr_cdcritic      => vr_cdcritic
                         ,pr_dscritic      => vr_dscritic);
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_saida;
              END IF;
            END IF; -- tem arquivo para processar  
          
            --Limpa tabela de Work
            BEGIN
              DELETE TBGEN_BATCH_RELATORIO_WRK
               WHERE cdcooper = pr_cdcooper
                 AND cdprograma = ct_cdprogra
                 AND dtmvtolt < trunc(SYSDATE - 7);
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log
                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                -- Ajuste Mensagem - 15/03/2018 - Chamado 801483 
                vr_cdcritic := 1037;
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                               ' TBGEN_BATCH_RELATORIO_WRK(3):' || ' cdcooper:' || pr_cdcooper ||
                               ', cdprograma:' || ct_cdprogra || ', dtmvtolt: < ' || TRUNC(SYSDATE) ||
                               ' - 7 ) ' || '. ' || SQLERRM;
                -- Inclusão do Raise - Mario - 15/03/2018 - Chamado 801483       
                --Levantar Excecao
                RAISE vr_exc_saida;
            END;

          END IF; -- NOT COMPEFORA
          
            --Salvar informacoes no banco de dados
            COMMIT;
            --Finaliza sessão aberta com SQL SERVER
            npcb0002.pc_libera_sessao_sqlserver_npc('PC_CRPS538_3');
          
          END IF;
        
          IF NOT (vr_nmtelant = 'COMPEFORA') THEN

            vr_cdcritic := 1201;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                           ' - 19 Cria job para envio de baixa efetiva.';
            cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => pr_cdagenci
                                  ,pr_cdprogra => ct_cdprogra
                                  ,pr_idprglog => vr_idprglog
                                  ,pr_dstiplog => 'O'
                                  ,pr_tpocorre => 4
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_cdcricid => 0);
            vr_cdcritic := NULL;
            vr_dscritic := NULL;
          
          COBRANCA.gerarJobRemessaBaixaEfetiva(pr_cdcooper => pr_cdcooper
                                                 ,pr_qtminuto => 1
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
          
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;

          END IF; -- NOT COMPEFORA
          
        END IF; --Fim Paralelismo 7
      
      EXCEPTION
        WHEN vr_exc_fimprg THEN
          -- Buscar a descricao da critica
          vr_cdcritic := nvl(vr_cdcritic, 0);
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
          -- Se foi gerada critica para envio ao log
          IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
            -- Incluido controle de Log - Chamado 714566 - 11/08/2017 
            --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
            cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => pr_cdagenci
                                  ,pr_cdprogra => ct_cdprogra
                                  ,pr_idprglog => vr_idprglog
                                  ,pr_dstiplog => 'E'
                                  ,pr_tpocorre => 1
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_cdcricid => 0);
          END IF;

        IF NOT (vr_nmtelant = 'COMPEFORA') THEN

          -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
          IF rw_crapdat.inproces > 2 AND pr_cdagenci > 0 AND vr_qtdjobs > 0 THEN
          
            -- Processo JOB
            --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
            vr_dscritic := vr_dscritic || ' - Saida vr_exc_fimprg';
            cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => pr_cdagenci
                                  ,pr_cdprogra => ct_cdprogra
                                  ,pr_idprglog => vr_idprglog
                                  ,pr_dstiplog => 'O'
                                  ,pr_tpocorre => 4
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_cdcricid => 0);
            vr_cdcritic := NULL;
            vr_dscritic := NULL;
          
            -- Encerrar o job do processamento paralelo dessa agência
            gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                        ,pr_idprogra => LPAD(pr_cdagenci, 3, '0')
                                        ,pr_des_erro => vr_dscritic);
          ELSE
            btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                     ,pr_cdprogra => ct_cdprogra
                                     ,pr_infimsol => pr_infimsol
                                     ,pr_stprogra => pr_stprogra);
          END IF;

        END IF; -- NOT COMPEFORA
        
          --Limpar parametros
          pr_cdcritic := 0;
          pr_dscritic := NULL;
          -- Efetuar commit pois gravaremos o que foi processado ate entao
          COMMIT;
          --Finaliza sessão aberta com SQL SERVER
          npcb0002.pc_libera_sessao_sqlserver_npc('PC_CRPS538_4');
        
        WHEN vr_exc_saida THEN
          -- Devolvemos codigo e critica encontradas
          pr_cdcritic := nvl(vr_cdcritic, 0);
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic, vr_dscritic);
          IF pr_cdcritic IN (9999, 1034, 1035, 1037) THEN
            vr_tpocorre := 2;
            vr_cdcricid := 2;
          ELSE
            vr_tpocorre := 1;
            vr_cdcricid := 0;
          END IF;
        
          ROLLBACK;
        
          -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
          IF rw_crapdat.inproces > 2 AND pr_cdagenci > 0 AND vr_qtdjobs > 0 THEN
            -- Processo JOB           
            --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
            vr_dscritic := vr_dscritic || ' - Saida 1';
            cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => pr_cdagenci
                                  ,pr_cdprogra => ct_cdprogra
                                  ,pr_idprglog => vr_idprglog
                                  ,pr_dstiplog => 'E'
                                  ,pr_tpocorre => vr_tpocorre
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_cdcricid => vr_cdcricid);
            vr_cdcritic := NULL;
            vr_dscritic := NULL;
          
            -- Excluido o pc_log_programa pelo motivo que coloquei observação - 15/03/2018 - Chamado 801483               
          
            -- Encerrar o job do processamento paralelo dessa agência
            gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                        ,pr_idprogra => LPAD(pr_cdagenci, 3, '0')
                                        ,pr_des_erro => vr_dscritic);
          
            COMMIT;
            --Finaliza sessão aberta com SQL SERVER
            npcb0002.pc_libera_sessao_sqlserver_npc('PC_CRPS538_5');
          
            -- Incluido Raise para deixar o JOB com erro - 15/03/2018 - Chamado 801483
            RAISE_APPLICATION_ERROR(-20001, pr_cdcritic || ' - ' || pr_dscritic);
          ELSE
            --Ajuste mensagem de erro - 15/03/2018 - Chamado 801483 
            vr_dscritic := vr_dscritic || ' - Saida 2';
            cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => pr_cdagenci
                                  ,pr_cdprogra => ct_cdprogra
                                  ,pr_idprglog => vr_idprglog
                                  ,pr_dstiplog => 'E'
                                  ,pr_tpocorre => vr_tpocorre
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_cdcricid => vr_cdcricid);
            vr_cdcritic := NULL;
            vr_dscritic := NULL;

          IF NOT (vr_nmtelant = 'COMPEFORA') THEN
          
            btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                     ,pr_cdprogra => ct_cdprogra
                                     ,pr_infimsol => pr_infimsol
                                     ,pr_stprogra => pr_stprogra);

          END IF; -- NOT COMPEFORA
          
            COMMIT;
            --Finaliza sessão aberta com SQL SERVER
            npcb0002.pc_libera_sessao_sqlserver_npc('PC_CRPS538_5');
          END IF;
        
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - Chamado 714566 - 11/08/2017 
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          -- Ajuste Mensagem e Log - 15/03/2018 - Chamado 801483  
          -- Efetuar retorno do erro nao tratado
          pr_cdcritic := 9999;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) || 'CRPS538' || '. ' ||
                         SQLERRM;
          cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_cdprogra => ct_cdprogra
                                ,pr_idprglog => vr_idprglog
                                ,pr_dstiplog => 'E'
                                ,pr_tpocorre => 2
                                ,pr_dscritic => pr_dscritic
                                ,pr_cdcritic => pr_cdcritic
                                ,pr_cdcricid => 2);
        
          ROLLBACK;
        
          --Finaliza sessão aberta com SQL SERVER
          npcb0002.pc_libera_sessao_sqlserver_npc('PC_CRPS538_6');
	  
	IF NOT (vr_nmtelant = 'COMPEFORA') THEN
        
          -- Incluido paralelismo para não o 538 separador não entrar em Loop - 15/03/2018 - Chamado 801483
          -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
          IF rw_crapdat.inproces > 2 AND pr_cdagenci > 0 AND vr_qtdjobs > 0 THEN
            -- Processo JOB                         
          
            -- Encerrar o job do processamento paralelo dessa agência
            gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                        ,pr_idprogra => LPAD(pr_cdagenci, 3, '0')
                                        ,pr_des_erro => vr_dscritic);
          
            -- Incluido Raise para deixar o JOB com erro - 15/03/2018 - Chamado 801483
            RAISE_APPLICATION_ERROR(-20001, pr_cdcritic || ' - ' || pr_dscritic);
          END IF;

	END IF; -- NOT COMPEFORA

      END;
      --
      cobr0014.gerarLogFim(pr_cdcooper      => pr_cdcooper
                          ,pr_cdagenci      => pr_cdagenci
                          ,pr_cdprogra      => ct_cdprogra
                          ,pr_cdprocedure   => ct_cdprocedure
                          ,pr_idprglog      => vr_idprglog
                          ,pr_dscomplemento => NULL
                          ,pr_module_name   => vr_module_name
                          ,pr_action_name   => vr_action_name);
      --
      cobr0014.gerarLogBatch(pr_cdcooper => pr_cdcooper
                            ,pr_cdagenci => pr_cdagenci
                            ,pr_cdprogra => ct_cdprogra
                            ,pr_idprglog => vr_idprglog
                            ,pr_dstiplog => 'F'
                            ,pr_tpocorre => 4
                            ,pr_dscritic => NULL
                            ,pr_cdcritic => NULL
                            ,pr_cdcricid => NULL);
      --
      gene0001.pc_set_modulo(pr_module => vr_module_name, pr_action => vr_action_name);
      --
    END;
    --
  END;
  --
END pc_crps538_20220829;
  --
BEGIN
  --
  pc_log_programa(pr_dstiplog   => 'I'
                 ,pr_cdprograma => vr_cdprogra
                 ,pr_cdcooper   => 3
                 ,pr_tpexecucao => 0
                 ,pr_idprglog   => vr_idprglog_principal);
  --
  FOR rw_crapcop IN (SELECT cop.cdcooper
                           ,cop.nmrescop
                       FROM crapcop cop
                      WHERE 1 = 1
                        AND cop.cdcooper <> 3
                        AND cop.flgativo = 1
                        AND cop.cdcooper in (1, 2, 6, 7, 11)
                      ORDER BY cop.cdcooper DESC) LOOP
    --
    pc_log_programa(pr_dstiplog      => 'O' -- Ocorrência
                   ,pr_cdprograma    => vr_cdprogra
                   ,pr_cdcooper      => 3
                   ,pr_tpexecucao    => 0
                   ,pr_tpocorrencia  => 4
                   ,pr_cdcriticidade => 0
                   ,pr_cdmensagem    => 0
                   ,pr_dsmensagem    => 'Iniciando o processamento da cooperativa '||rw_crapcop.cdcooper||' - '||rw_crapcop.nmrescop
                   ,pr_idprglog      => vr_idprglog_principal);
    --
    vr_stprogra := 0;
    vr_infimsol := 0;
    vr_cdcritic := 0;
    vr_dscritic := '';
    --
    pc_crps538_20220829(pr_cdcooper => rw_crapcop.cdcooper,
                        pr_cdagenci => 0,
                        pr_idparale => 0,
                        pr_flgresta => 0,
                        pr_nmtelant => 'COMPEFORA',
                        pr_stprogra => vr_stprogra,
                        pr_infimsol => vr_infimsol,
                        pr_cdcritic => vr_cdcritic,
                        pr_dscritic => vr_dscritic);
    --
    IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      pc_log_programa(pr_dstiplog      => 'E'
                     ,pr_cdprograma    => vr_cdprogra
                     ,pr_cdcooper      => 3
                     ,pr_tpexecucao    => 0
                     ,pr_tpocorrencia  => 3
                     ,pr_cdcriticidade => 0
                     ,pr_cdmensagem    => vr_cdcritic
                     ,pr_dsmensagem    => vr_dscritic||' '||rw_crapcop.cdcooper||' - '||rw_crapcop.nmrescop
                     ,pr_idprglog      => vr_idprglog_principal);
      CONTINUE;
    END IF;
    --
    pc_log_programa(pr_dstiplog      => 'O' -- Ocorrência
                   ,pr_cdprograma    => vr_cdprogra
                   ,pr_cdcooper      => 3
                   ,pr_tpexecucao    => 0
                   ,pr_tpocorrencia  => 4
                   ,pr_cdcriticidade => 0
                   ,pr_cdmensagem    => 0
                   ,pr_dsmensagem    => 'Finalizado o processamento da cooperativa '||rw_crapcop.cdcooper||' - '||rw_crapcop.nmrescop
                   ,pr_idprglog      => vr_idprglog_principal);
    --
  END LOOP;
  --
  pc_log_programa(pr_dstiplog   => 'F'
                 ,pr_cdprograma => vr_cdprogra
                 ,pr_cdcooper   => 3
                 ,pr_tpexecucao => 0
                 ,pr_flgsucesso => 1
                 ,pr_idprglog   => vr_idprglog_principal);
  --
END;
