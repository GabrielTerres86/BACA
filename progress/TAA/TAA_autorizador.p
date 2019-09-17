/* .............................................................................

  Programa: TAA_autorizador.p

  Objetivo: Receber, processar e devolver as mensagens XML do
            sistema TAA.
   
     Autor: Evandro
    
      Data: Janeiro/2010                        Ultima alteracao: 08/05/2019
    
Alteracoes: 30/06/2010 - Retirar telefone da ouvidoria (Evandro).

            30/07/2010 - Ajuste para limpeza da BO utilizada (Evandro).
            
            23/08/2010 - Tratamento para XML muito extenso (Evandro).
            
            06/09/2010 - Corrigido campo utilizado para exibir o saldo
                         das aplicacoes;
                       - Adicionado controle de estatistico de uso
                         conforme sistema antigo (Evandro).
                         
            01/10/2010 - Adaptação das mensagens XML para permitir uso
                         compartilhado do TAA (Evandro).
                         
            14/10/2010 - Inclusao dos parametros para cooperativa/pac/taa 
                         nas procedures paga_convenio e paga_titulo (Vitor).
                         
            05/11/2010 - Inclusao de parametros ref. TAA compartilhado na
                         procedure gera-tarifa-extrato (Diego).
                         
            16/12/2010 - Nao permitir pagto de titulos/convenios no ultimo
                         dia util do ano (Evandro).
                         
            29/12/2010 - Corrigida contagem de extratos de C/C emitidos;
                       - Passar o horario do servidor para validar tela de
                         pagamentos (Evandro).
                         
            03/03/2011 - Adicionados controles de REBOOT e UPDATE (Evandro).
            
            24/03/2011 - Alterado devido as rotinas de agendamento de 
                         pagamento (Henrique).
            
            28/03/2011 - Utilizar o nro do TAA para contar os extratos de
                         C/C emitidos (Evandro).
              
            06/04/2011 - Alterado devido as rotinas de agendamento de 
                         transferencia (Henrique).
                         
            01/05/2011 - Inclusao de novas rotinas utilizadas pelo TAA (Henrique)
            
            26/05/2011 - Alteracoes para cobranca regisrada (Guilherme).
              
            05/08/2011 - Receber o protocolo e repassar ao TAA.
                         Incluir operacao 35 e 36. (Gabriel)
                         
            27/10/2011 - Parametros Operadores na paga_convenio, paga_titulo e
                         executa_transferencia (Guilherme).
                         
            19/12/2011 - Adicionada validacao da data de nascimento (Evandro).
            
            20/12/2011 - Adicionada senha com letras aleatorias e Incluido
                         parametro CPF operador PJ (Evandro).
                         
            09/03/2012 - Adicionado os campos cdbcoctl e cdagectl ao xml,
                         na procedure verifica_comprovantes. (Fabricio)
                         
            22/03/2012 - Adicionado parametro para agendamento de titulo DDA
                         na b1wgen0016.p (Evandro).
                         
            20/06/2012 - Ajustados parametros para transferencia (Evandro).
            
            11/07/2012 - Adicionada validação para não permitir agendamentos
                         com vencimento para último dia útil do ano (Lucas).
                         
            10/10/2012 - Tratamento para novo campo da 'craphis' de descrição
                         do histórico em extratos (Lucas) [Projeto Tarifas].
                         
            28/11/2012 - Tratamento para evitar agendamentos de contas
                         migradas - tabela craptco - TAA (Evandro).
                         
            28/12/2012 - Corrigida busca de data do ultimo dia do ano para
                         nao considerar o feriado do dia 31 (Evandro).
                         
            17/01/2013 - Adicionado parametro para procedure busca_associado
                         (Evandro).
                         
            05/02/2013 - Prova de Vida para o INSS (Evandro).
            
            11/04/2013 - Transferencia intercooperativa (Gabriel).
            
            24/05/2013 - Alterado processo de busca valor tarifa extrato e 
                         retidado parametro tarifar na procedure 
                         gera-tarifa-extrato. (Daniel)
                         
            31/05/2013 - Alterado procedure obtem_tarifa_extrato, incluso novo
                         processo para buscar valor tarifa usando b1wgen0153 e
                         incluso processo para verificar se tarifa sera isenta
                         usando chamada para verifica-tarifacao-extrato da 
                         b1wgen0001 (Daniel).
            
            18/07/2013 - Incluido procedure retorna_valor_blqjud que  busca
                         valor bloqueado judicialmente (Lucas R.).
                         
            02/09/2013 - Email de monitoracao na transferencia (Evandro).
            
            11/09/2013 - Adicionado email da multitask na monitoracao
                         (Evandro).
                         
            13/09/2013 - Enviar e-mail de transferencia para monitoracao apenas
                         se for maior de 500,00 (Evandro).
                         
            25/09/2013 - Alterada rotina de email para monitoracao de
                         terceiros conforme solicitacao da equipe de
                         seguranca (Evandro).                         
                         
            04/10/2013 - Tratamento para Migracao da Acredicoop e retirada do
                         e-mail para a multitask (Evandro).
            
            07/10/2013 - Ajuste na verificacao do agendamento recorrente (31), 
                         passando TRUE para parametro par_flgagend na procedure
                         verifica_transferencia da BO b1wgen0025 (David).
                       
            10/10/2013 - Incluido parametro cdprogra nas procedures da 
                         b1wgen0153 que carregam dados de tarifas (Tiago).
                          
            30/10/2013 - Adicionado operacao 40, bloq. saque. 
                         Criado proc. status_saque(Jorge).
                         
            11/12/2013 - Adicionar PA no assunto dos emails de monitoracao;
                       - Enviar e-mail de monitoracao para as cooperativas
                         Viacredi, Alto Vale, Acredicoop, Concredi e
                         Credifoz (Evandro).
                      
            12/12/2013 - Ajustado o valor de e-mails para 300,00 e adicionados
                         dados do TAA no assunto (Evandro).
                         
            17/12/2013 - Para troca de senha, chamar BO 32 (Evandro).
            
            24/03/2014 - Implementar log de sessao para Oracle (David).
            
            29/05/2014 - Ajuste na monitoracao da transferencia para enviar
                         e-mail independente do valor (Adriano).
                         
            03/06/2014 - Incluido mais cooperativas para envio de e-mail
                         para monitoracao. (Adriano).              
                         
            25/07/2014 - Retornar servidor que recebeu requisicao no XML de
                         resposta (David).    
                         
            03/09/2014 - Criação das operações 41, 42, 43, 44  para
                         Projeto de Débito Fácil (Lucas Lunelli - Out/2014).
                         
            09/09/2014 - Incluido a operacao 45. (James)
            
            17/09/2014 - Incluido a operacao 46. (James)
            
            17/09/2014 - Incluido a operacao 47. (James)
            
            18/09/2014 - Incluido a operacao 48. (James)
            
            22/09/2014 - Incluido a operacao 49. (James)
            
            23/09/2014 - Adicionado parametros de saida aux_msgofatr e
                         aux_cdempcon na chamada da procedure paga_convenio.
                         (Debito Automatico Facil) - (Fabricio)
                         
            29/09/2014 - Incluido a operacao 50. (James)
            
			30/09/2014 - Substituida a chamada da procedure consulta-aplicacoes 
						 da BO b1wgen0004 pela procedure pc_lista_aplicacoes_car 
						 da package APLI0005. 
						 (Carlos Rafael Tanholi - Projeto CAPTACAO)						

            22/10/2014 - Efetuado ajustes deposito intercoop. (Reinert)
            
            23/10/2014 - Correção para procedures relativas ao Débito Faácil
                         trabalharem com dtmvtocd. (Lunelli)
                
		    25/10/2014 - Novos filtros para envio de e-mail de monitoracao
                        (Chamado 198702) (Jonata-RKAM).  
         
            27/10/2014 - Ajuste no envio de parametros da operacao 48.(James)
            
                         Ajuste para armazenar a sequencia do titular.(James)
	
			28/10/2014 - Adicionada procedure obtem_sequencial_deposito. (Reinert)
            
            06/11/2014 - Acertado operador 996 para operações de Déb. Automático
                         (Lucas Lunelli)

            18/11/2014 - Inclusao do parametro "nrcpfope" na chamada da
                         procedure "busca_dados" da "b1wgen0188". (Jaison)
                         
            23/12/2014 - Ajuste no envio de parametro para o pre-aprovado
                         (James)             
                         
            19/01/2015 - Permitir informar o cedente nos convenios
                         (Chamado 235532). (Jonata - RKAM)             
                         
            04/02/2015 - Ajuste na monitoracao de saque + transferencia
                         (Jonata-RKAM).              
                         
            26/02/2015 - Alterado para mostrar saldo dos novos produtos de 
                         captacao. (Reinert)

            09/03/2015 - Ajuste na monitoracao de saque + transferencia 
                         (Kelvin)
                         
            16/03/2015 - Inclusao do buffer da tabela crapdat, para buscar
                         as datas da cooperativa do cartao logado no TAA.
                         (James)
                         
            06/04/2015 - Criado operacao 52 verifica_emprst_atraso.
                         (Jorge/Rodrigo).        
                         
            28/05/2015 - Alterada a origem do TAA na consulta de protocolos para 4.
						 (Dionathan)     
                         
            06/07/2015 - Foi ajustando em algumas situacoes a passagem de parametro
                         que informava dtmvtolt para dtmvtocd. SD 303100 (Kelvin)    
                         
            20/08/2015 - Adicionado procedure que retorna informações de SAC e OUVIDORIA 
                         para os comprovantes (Lucas Lunelli - Melhoria 83 [SD 279180])    
                         
            20/08/2015 - Incluido a leitura do parametro tpcptdoc nas operacoes 
                         26 - pagamento converio e 29 - pagamento titulo 
                         Melhoria 21 SD278322 (Odirlei-AMcom)
                         
            15/09/2015 - Alterações para logar valores de saldo e limite em validação de 
                         operações de saque (Lunelli SD 306183).
                         
            27/08/2015 - Projeto Integracoes cartao CECRED. (James)                                               
            
            25/11/2015 - Ajustado a procedure obtem_saldo_limite para que os valores
                         de saldo do cooperado sejam buscados na obtem-saldo-dia
                         convertida em Oracle (Douglas - Chamado 285228)
                         
            22/12/2015 - Efetuado ajustes para o projeto 131. (Reinert)

            24/03/2016 - Adicionados parâmetros para geraçao de LOG
                         (Lucas Lunelli - PROJ290 Cartao CECRED no CaixaOnline)

			28/03/2016 - Ajuste para alimentar corretamente o retorno de erro
					     na rotina efetua_transferencia
						(Adriano).

            28/01/2016 - Procedimentos para tratamento de banners no TAA
                         (Lucas Lunelli  - PRJ261 – Pré-Aprovado fase II)
						 
			06/05/2016 - Desabilitar log do XML das requisicoes (David).
						
	        25/04/2016 - Incluido a passagem de novo parametro na rotina
						 cancelar-agendamento
						 (Adriano - M117).

            12/05/2016 - Chamando rotinas convertidas pc_cadastrar_agendamento e
                         pc_agendamento_recorrente (Carlos - M117)


            24/05/2016 - Ajuste para retirar parametros de saída na chamada da rotina responsável
			             pelo cadastro de agendamentos
			 		     (Adriano - M117).
			
            05/04/2016 - Incluida procedure pc_verifica_pacote_tarifas,
                         Prj 218, na procedure obtem_tarifa_extrato (Jean Michel).

            30/05/2016 - Alteraçoes Oferta DEBAUT Sicredi (Lucas Lunelli - [PROJ320])

            20/07/2016 - Inclusao dos parametros pr_cdfinali, pr_dstransf e pr_dshistor 
                         na rotina pc_cadastrar_agendamento e pc_agendamento_recorrente (Carlos)

            02/08/2016 - Tratada procedure 'obtem_tarifa_extrato' para nao validar
                         extratos isentos da cooperativa quando o cooperado possuir
                         o servico "extrato" no pacote de tarifas (Diego).

			      07/10/2016 - Ajustes referente a melhoria M271. (Kelvin)

            04/11/2016 - M172 - Atualizacao Telefone - Nova operacao 65/66/67
                         (Guilherme/SUPERO)

            08/11/2016 - Alteracoes referentes a melhoria 165 - Lancamentos Futuros. 
                         Lenilson (Mouts)

            22/11/2016 - Inclusao do parametro pr_iptransa na chamada da rotina 
                         pc_cadastrar_agendamento.
                         PRJ335 - Analise de Fraude (Odirlei-AMcom ) 
                         
            19/01/2017 - Ajuste na validação de agendamentos/pagamentos no último
                         dia do ano (Rodrigo - SD 587328)
            02/02/2017 - #566765 Mudanca do tipo da variavel xml_resp de char para 
                         longchar (Carlos)

            03/03/2017 - Alterado para tratar Projeto 321 - Recarga de celular.
                         (Reinert)

			19/05/2017 - Necessaria inclusao de novo parametro na chamada da
			             procedure lista_protocolos para Recarga de Celular
						 (Diego).
						 
            25/07/2017 - #712156 Melhoria 274, criação da rotina verifica_notas_cem,
                         operacao 75, para verificar se o TAA utiliza notas de cem 
						 (Carlos)
                         
            13/10/2017 - #765295 Criada a rotina busca_convenio_nome, operacao 
                         76, para logar o nome do convenio (Carlos)

            09/11/2017 - Ajuste na rotina lancamentos-futuros para retornar no XML os valores
                         totais que sao calculados na bo03
                         Heitor (Mouts) - Chamado 689749

            29/11/2017 - Inclusao do valor de bloqueio em garantia. 
                         PRJ404 - Garantia.(Odirlei-AMcom)                 

            16/04/2018 - Ajustes para o novo sistema do caixa eletronico 
                         PRJ363 - Douglas Quisinski

            21/05/2018 - Inclusao de parametros devido a analise de fraude.
                         PRJ381 - Antifraude(Odirlei-AMcom)
                      
			26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).
			   
            18/06/2018 - Retornar o complemento na consulta de extrato
                         (Douglas - Prj 467)
			            
            15/08/2018 - Inclusão da operação 200 - URA
                         (Everton - Mouts - Projeto 427)
			            
			03/10/2018 - Corrigir validação do aux_token na validação de senha no saque
			             e na alteração de senha (Douglas - Prj 363)
			            
            03/10/2018 - Na validação de senha foi separado o canal para enviar TAA (4) ou URA(6),
                         para que seja possivel zerar a quantidade de senha incorreta quando
                         estiver sendo executado pela URA (Douglas - Prj 427 URA)
                         
            17/12/2018 - Ajuste no tratamento de erro na consulta de dados do ECO (Douglas - SCTASK0039027)

		    08/05/2019 - Ajustar parametros na chamada da rotina 
                         pc_cadastrar_agendamento (Renato - Supero - P485)
						 
			24/02/2019 - P442 - Passar vazio em campos da aprovacao 
                            quando somente previa (Marcos-Envolti)
............................................................................. */

CREATE WIDGET-POOL.

/* Include para usar os comandos para WEB */
{src/web2/wrap-cgi.i}

/* Includes com a temp-table cratpro */
{ sistema/generico/includes/bo_algoritmo_seguranca.i }

/* Variaveis ambiente oracle */
{ sistema/generico/includes/var_oracle.i }

/* Configura a saída como XML */
OUTPUT-CONTENT-TYPE ("text/xml":U).

/* Para tratar XML */
DEFINE VARIABLE xDoc         AS HANDLE                      NO-UNDO.  
DEFINE VARIABLE xRoot        AS HANDLE                      NO-UNDO. 
DEFINE VARIABLE xRoot2       AS HANDLE                      NO-UNDO. 
DEFINE VARIABLE xField       AS HANDLE                      NO-UNDO.
DEFINE VARIABLE xText        AS HANDLE                      NO-UNDO.
DEFINE VARIABLE ponteiro_xml AS MEMPTR                      NO-UNDO.
                                                            
/* LOG */                                                   
DEFINE STREAM str_1.                                        
DEFINE VARIABLE aux_nmarqlog AS CHARACTER                   NO-UNDO.
DEFINE VARIABLE aux_flglogar AS LOGICAL         INIT NO     NO-UNDO.
DEFINE VARIABLE aux_tpdsaldo AS INTEGER                     NO-UNDO.
                                                            
/* uso comum */                                             
DEFINE VARIABLE aux_operacao AS INTEGER                     NO-UNDO.
DEFINE VARIABLE aux_cdcritic AS INT                         NO-UNDO. /* cod critica */
DEFINE VARIABLE aux_dscritic AS CHARACTER                   NO-UNDO.                                                            


/* dados do associado nas operacoes */                     
DEFINE VARIABLE aux_cdcooper AS INT                         NO-UNDO. /* cooperativa */
DEFINE VARIABLE par_nrdconta AS INT                         NO-UNDO. /* numero da conta */
DEFINE VARIABLE par_cdagectl AS INT                         NO-UNDO. /* agencia da cooperativa */
DEFINE VARIABLE aux_dscartao AS CHARACTER                   NO-UNDO. /* cartao lido */                                                           
DEFINE VARIABLE aux_nrcartao AS DEC                         NO-UNDO. /* cartao ja tratado */
DEFINE VARIABLE aux_nrdconta AS INT                         NO-UNDO. /* conta/dv */
DEFINE VARIABLE aux_inpessoa AS INT                         NO-UNDO. /* indicador fisica/juridica */
DEFINE VARIABLE aux_dssencar AS CHARACTER                   NO-UNDO. /* senha codificada */
DEFINE VARIABLE aux_idsenlet AS LOGICAL                     NO-UNDO. /* indicador se possui senha de letras */
DEFINE VARIABLE aux_dsdgrup1 AS CHARACTER                   NO-UNDO. /* senha de letras - grupo 1 */
DEFINE VARIABLE aux_dsdgrup2 AS CHARACTER                   NO-UNDO. /* senha de letras - grupo 2 */
DEFINE VARIABLE aux_dsdgrup3 AS CHARACTER                   NO-UNDO. /* senha de letras - grupo 3 */
DEFINE VARIABLE aux_dtnascto AS CHARACTER                   NO-UNDO. /* data de nascimento/cnpj codificados */
DEFINE VARIABLE aux_nrtelsac AS CHARACTER                   NO-UNDO. /* numero SAC cooperativa */
DEFINE VARIABLE aux_nrtelouv AS CHARACTER                   NO-UNDO. /* numero ouvidoria cooperativa */
DEFINE VARIABLE aux_nrtransf AS INT                         NO-UNDO. /* conta/dv transf. */
DEFINE VARIABLE aux_vltransf AS DEC                         NO-UNDO. /* valor transf. */
DEFINE VARIABLE aux_dttransf AS DATE                        NO-UNDO. /* data da transferencia */
DEFINE VARIABLE aux_dtiniext AS DATE                        NO-UNDO. /* inicio do extrato */
DEFINE VARIABLE aux_dtfimext AS DATE                        NO-UNDO. /* fim do extrato */
DEFINE VARIABLE aux_vltarifa AS DEC                         NO-UNDO. /* tarifa do extrato */
DEFINE VARIABLE aux_inisenta AS INT                         NO-UNDO. /* isencao da tarifa de extrato */
DEFINE VARIABLE aux_nrsequni AS INT                         NO-UNDO. /* sequencial unico */
DEFINE VARIABLE aux_nrseqenv AS INT                         NO-UNDO. /* sequencial do envelope */
DEFINE VARIABLE aux_nrseqenl AS INT                         NO-UNDO. /* sequencial do envelope (crapenl) */
DEFINE VARIABLE aux_nrdocmto AS INT                         NO-UNDO. /* documento do envelope */
DEFINE VARIABLE aux_nrctafav AS INT                         NO-UNDO. /* conta/dv do favorecido (deposito) */
DEFINE VARIABLE aux_vldininf AS DEC                         NO-UNDO. /* valor informado em dinheiro */
DEFINE VARIABLE aux_vlchqinf AS DEC                         NO-UNDO. /* valor informado em cheque */
DEFINE VARIABLE aux_vldsaque AS DEC                         NO-UNDO. /* valor do saque */
DEFINE VARIABLE aux_hrtransa AS INT                         NO-UNDO. /* horario da transacao */
DEFINE VARIABLE aux_flagenda AS LOGICAL                     NO-UNDO. /* flag de agendamento */
DEFINE VARIABLE aux_dtinitra AS DATE                        NO-UNDO. /* data de inicio da transferencia mensal */
DEFINE VARIABLE aux_qtdmeses AS INTEGER                     NO-UNDO. /* quantidade de meses do agendamento mensal */
DEFINE VARIABLE aux_lsdataqd AS CHAR                        NO-UNDO. /* lista de datas - agendamento recorrente */
DEFINE VARIABLE aux_dtinipro AS DATE                        NO-UNDO. /* Periodo inicial para comprovantes */
DEFINE VARIABLE aux_dtfimpro AS DATE                        NO-UNDO. /* Periodo final para comprovantes */
DEFINE VARIABLE aux_tpextrat AS INTE                        NO-UNDO. /* Tipo de extrato */
DEFINE VARIABLE aux_dsprefix AS CHAR  INIT ""               NO-UNDO. /* Prefixo para geracao do estatistico */
DEFINE VARIABLE aux_cdagetra AS INTE                        NO-UNDO. /* Agencia do coop */
DEFINE VARIABLE aux_tpoperac AS INTE                        NO-UNDO. /* Tipo Operacao */
DEFINE VARIABLE aux_tpusucar AS INTE                        NO-UNDO. /* Tipo de usuario do cartao.*/
DEFINE VARIABLE aux_idtipcar AS INTE                        NO-UNDO. /* Tipo do cartao.*/
DEFINE VARIABLE aux_nrrecben AS DECI                        NO-UNDO. /* Numero de recebimento do beneficiario do inss */
DEFINE VARIABLE aux_dtcompet AS CHAR                        NO-UNDO. /* Mes de competencia do demonstrativo do inss */
DEFINE VARIABLE aux_nrremete AS INT                         NO-UNDO. /* conta/dv remetente. */
DEFINE VARIABLE aux_cdagerem AS INTE                        NO-UNDO. /* Agencia remetente. */


/* para validacao de pendencias de saque */
DEFINE VARIABLE aux_dtmvtolt AS DATE                        NO-UNDO. /* data do movimento */

/* dados do servidor */
DEFINE VARIABLE aux_hostname AS CHAR                        NO-UNDO. /* nome do servidor  */

/* dados do terminal */
DEFINE VARIABLE aux_cdoperad AS CHAR                        NO-UNDO. /* operador */
DEFINE VARIABLE aux_qtnotaK7 AS INTEGER     EXTENT 5        NO-UNDO. /* qtd. notas nos cassetes */
DEFINE VARIABLE aux_vlnotaK7 AS DECIMAL     EXTENT 5        NO-UNDO. /* valor notas nos cassetes */
DEFINE VARIABLE aux_tprecolh AS INTEGER                     NO-UNDO. /* tipo de recolhimento */
DEFINE VARIABLE aux_vldsdini AS DECIMAL                     NO-UNDO. /* saldo inicial */
DEFINE VARIABLE aux_vldmovto AS DECIMAL                     NO-UNDO. /* valor dos movimentos - saques */
DEFINE VARIABLE aux_vldsdfin AS DECIMAL                     NO-UNDO. /* saldo final */
DEFINE VARIABLE aux_hrininot AS INT                         NO-UNDO. /* inicio saque noturno */
DEFINE VARIABLE aux_hrfimnot AS INT                         NO-UNDO. /* fim saque noturno */
DEFINE VARIABLE aux_vlsaqnot AS DEC                         NO-UNDO. /* valor saque noturno */
DEFINE VARIABLE aux_nrtempor AS INT                         NO-UNDO. /* temporizador */
DEFINE VARIABLE aux_flgblsaq AS LOGICAL                     NO-UNDO. /* bloq. de saque */
DEFINE VARIABLE aux_flgntcem AS LOGICAL                     NO-UNDO. /* usa notas de cem reais */

/* para validacoes de titulos e convenios */
DEFINE VARIABLE aux_cdbarra1 AS CHAR                        NO-UNDO.
DEFINE VARIABLE aux_cdbarra2 AS CHAR                        NO-UNDO.
DEFINE VARIABLE aux_cdbarra3 AS CHAR                        NO-UNDO.
DEFINE VARIABLE aux_cdbarra4 AS CHAR                        NO-UNDO.
DEFINE VARIABLE aux_cdbarra5 AS CHAR                        NO-UNDO.
DEFINE VARIABLE aux_dscodbar AS CHAR                        NO-UNDO.
DEFINE VARIABLE aux_vldpagto AS DEC                         NO-UNDO.
DEFINE VARIABLE aux_datpagto AS DATE                        NO-UNDO.
DEFINE VARIABLE aux_dtvencto AS DATE                        NO-UNDO.
DEFINE VARIABLE aux_cdempcon AS INTE                        NO-UNDO.
DEFINE VARIABLE aux_cdsegmto AS INTE                        NO-UNDO.
DEFINE VARIABLE aux_flgdbaut AS LOGI   INIT FALSE           NO-UNDO.
DEFINE VARIABLE aux_dtautori AS DATE                        NO-UNDO.
DEFINE VARIABLE aux_vlrmaxdb AS DECI                        NO-UNDO.
DEFINE VARIABLE aux_cdrefere AS DECI                        NO-UNDO.
DEFINE VARIABLE aux_idmotivo AS INTE                        NO-UNDO.
DEFINE VARIABLE aux_cdhistor AS INTE                        NO-UNDO.
DEFINE VARIABLE aux_tpcptdoc AS INTE                        NO-UNDO. /* 1=leitora 2=Linha digitavel*/ 
DEFINE VARIABLE aux_nrdddtfc AS DECI   INIT 0               NO-UNDO.
DEFINE VARIABLE aux_nrtelefo AS DECI   INIT 0               NO-UNDO.
DEFINE VARIABLE aux_tptelefo AS INT                         NO-UNDO.
DEFINE VARIABLE aux_flgacsms AS INTE                        NO-UNDO.
DEFINE VARIABLE aux_dsmsgsms AS CHAR                        NO-UNDO.
DEFINE VARIABLE aux_cdctrlcs AS CHAR                        NO-UNDO.
DEFINE VARIABLE aux_flgsitrc AS INTEGER                     NO-UNDO.


/* TOKEN  para validar autenticidade da senha */
DEFINE VARIABLE aux_token    AS CHAR                        NO-UNDO.
DEFINE VARIABLE aux_idtaanew AS INTE INIT 0                 NO-UNDO.
DEFINE VARIABLE aux_idopeexe AS CHAR                        NO-UNDO.
DEFINE VARIABLE aux_tpintera AS CHAR                        NO-UNDO.

/* Projeto ECO */
DEFINE VARIABLE aux_nrcpfcgc AS DECIMAL                     NO-UNDO.
DEFINE VARIABLE aux_tpconben AS INTE                        NO-UNDO.
DEFINE VARIABLE aux_cdorgins AS INTE                        NO-UNDO.
/* Projeto ECO */


/* para exclusao de agendamentos */
DEFINE VARIABLE aux_dtmvtopg AS DATE                        NO-UNDO.

/* Usada na listagem dos comprovantes */
DEFINE TEMP-TABLE tt-cratpro LIKE cratpro.

/* Usada para exibir os beneficiarios do inss */
DEFINE TEMP-TABLE tt-dcb NO-UNDO
       FIELD nrrecben AS DECI  /* Numero do recebimento do beneficiario    */
       FIELD nmbenefi AS CHAR  /* Nome do beneficiario*/
       FIELD dtcompet AS CHAR  /* Data de competencia */
       FIELD vlliquid AS DECI. /* Valor liquido */

/* Usada para exibir os beneficiarios do inss */
DEFINE TEMP-TABLE tt-demonst-dcb NO-UNDO
       FIELD nmemisso AS CHAR /* Nome do emissor */
       FIELD cnpjemis AS DECI /* CNPJ emissor */
       FIELD nmbenefi AS CHAR /* Nome do beneficiario*/
       FIELD dtcompet AS CHAR /* Data de competencia */
       FIELD nrrecben AS DECI /* Numero do recebimento do beneficiario    */
       FIELD nrnitins AS DECI /* Numero NIT */
       FIELD cdorgins AS INTE /* Codigo identificador do orgao pagador junto ao INSS*/
       FIELD nmrescop AS CHAR /* Nome da Cooperativa */
       FIELD vlliquid AS DECI. /* Valor liquido */

/* Usada para exibir os lancamentos do beneficiario do inss */
DEFINE TEMP-TABLE tt-demonst-ldcb NO-UNDO
       FIELD cdrubric AS INTE /* Codigo da rubrica */
       FIELD dsrubric AS CHAR /* Descricao da rubrica */
       FIELD vlrubric AS DECI. /* Valor da rubrica */

/* Usada para exibir os telefones favoritos para recarga */
DEFINE TEMP-TABLE tt-favoritos-recarga NO-UNDO
       FIELD nrddd     AS INTE  /* DDD */
       FIELD nrcelular AS DECI  /* Nr. Celular */
       FIELD nmcontato AS CHAR  /* Nome contato */
       FIELD cdseqfav  AS DECI. /* Cód. sequencia favoritos */       

/* Usada para exibir as operadoras para recarga */
DEFINE TEMP-TABLE tt-operadoras-recarga NO-UNDO
       FIELD cdoperadora AS INTE  /* Cod. operadora */
       FIELD nmoperadora AS CHAR  /* Nome operadora */
       FIELD cdproduto   AS INTE  /* Cod. produto   */
       FIELD nmproduto   AS CHAR. /* Nome produto */
       
/* Usada para exibir os valores pre-fixados para recarga */
DEFINE TEMP-TABLE tt-valores-recarga NO-UNDO
       FIELD vlrecarga AS DECIMAL.  /* Valor de recarga */
       
/* Usada para exibir os beneficios de inss */
DEFINE TEMP-TABLE tt-beneficios-inss NO-UNDO
       FIELD nrrecben AS DECIMAL.  /* Numero do beneficio */
       
/* Usada para listar os dados dos comprovantes */
DEFINE TEMP-TABLE tt-dados-comprovante-eco NO-UNDO
       FIELD linha AS CHAR.  /* Linhas do comprovante */

/* Recarga de celular */
DEFINE VARIABLE aux_cdoperadora AS INTE                     NO-UNDO.
DEFINE VARIABLE aux_cdproduto   AS INTE                     NO-UNDO.
DEFINE VARIABLE aux_vlrecarga   AS DECI                     NO-UNDO.
DEFINE VARIABLE aux_nrdddtel    AS INTE                     NO-UNDO.
DEFINE VARIABLE aux_nrcelular   AS INTE                     NO-UNDO.
DEFINE VARIABLE aux_dtrecarga   AS CHAR                     NO-UNDO.
DEFINE VARIABLE aux_qtmesagd    AS INTE                     NO-UNDO.
DEFINE VARIABLE aux_cddopcao    AS INTE                     NO-UNDO.
DEFINE VARIABLE aux_lsdatagd    AS CHAR                     NO-UNDO.

/* Operacao 63 */
DEFINE VARIABLE aux_titulo1 AS DECI                         NO-UNDO.
DEFINE VARIABLE aux_titulo2 AS DECI                         NO-UNDO.
DEFINE VARIABLE aux_titulo3 AS DECI                         NO-UNDO.
DEFINE VARIABLE aux_titulo4 AS DECI                         NO-UNDO.
DEFINE VARIABLE aux_titulo5 AS DECI                         NO-UNDO.
DEFINE VARIABLE aux_codigo_barras AS CHAR                   NO-UNDO.

/* Usado no pre-aprovado */
DEFINE VARIABLE aux_vlemprst AS DECI                        NO-UNDO.
DEFINE VARIABLE aux_txmensal AS DECI                        NO-UNDO.
DEFINE VARIABLE aux_qtpreemp AS INTE                        NO-UNDO.
DEFINE VARIABLE aux_diapagto AS INTE                        NO-UNDO.
DEFINE VARIABLE aux_vlpreemp AS DECI                        NO-UNDO.
DEFINE VARIABLE aux_percetop AS DECI                        NO-UNDO.
DEFINE VARIABLE aux_dtdpagto AS DATE                        NO-UNDO.
DEFINE VARIABLE aux_dtmvtopr AS DATE                        NO-UNDO.
DEFINE VARIABLE aux_vlparepr AS DECI                        NO-UNDO.
DEFINE VARIABLE aux_nrparepr AS INTE                        NO-UNDO.
DEFINE VARIABLE aux_vltaxiof AS DECI                        NO-UNDO.
DEFINE VARIABLE aux_vltariof AS DECI                        NO-UNDO.
DEFINE VARIABLE aux_vlrtarif AS DECI                        NO-UNDO.

DEF STREAM str_2.
DEF BUFFER crabdat FOR crapdat.

/* BOs */
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/b1wgen0003tt.i }
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0006tt.i }
{ sistema/generico/includes/b1wgen0015tt.i }
{ sistema/generico/includes/b1wgen0016tt.i }
{ sistema/generico/includes/b1wgen0019tt.i }
{ sistema/generico/includes/b1wgen0031tt.i }
{ sistema/generico/includes/b1wgen0032tt.i }
{ sistema/generico/includes/b1wgen0059tt.i }
{ sistema/generico/includes/b1wgen0092tt.i }
{ sistema/generico/includes/b1wgen0188tt.i }
{ sistema/generico/includes/b1wgen9998tt.i }

DEFINE VARIABLE h-b1wgen0001             AS HANDLE   NO-UNDO.
DEFINE VARIABLE h-b1wgen0003             AS HANDLE   NO-UNDO.
DEFINE VARIABLE h-b1wgen0004             AS HANDLE   NO-UNDO.
DEFINE VARIABLE h-b1wgen0006             AS HANDLE   NO-UNDO.
DEFINE VARIABLE h-b1wgen0015             AS HANDLE   NO-UNDO.
DEFINE VARIABLE h-b1wgen0016             AS HANDLE   NO-UNDO.
DEFINE VARIABLE h-b1wgen0019             AS HANDLE   NO-UNDO.
DEFINE VARIABLE h-b1wgen0025             AS HANDLE   NO-UNDO.
DEFINE VARIABLE h-b1wgen0028             AS HANDLE   NO-UNDO.
DEFINE VARIABLE h-b1wgen0031             AS HANDLE   NO-UNDO.
DEFINE VARIABLE h-b1wgen0032             AS HANDLE   NO-UNDO.
DEFINE VARIABLE h-b1wgen0059             AS HANDLE   NO-UNDO.
DEFINE VARIABLE h-b1wgen0070             AS HANDLE   NO-UNDO.
DEFINE VARIABLE h-b1wgen0092             AS HANDLE   NO-UNDO.
DEFINE VARIABLE h-b1wgen0123             AS HANDLE   NO-UNDO.
DEFINE VARIABLE h-b1wgen0155             AS HANDLE   NO-UNDO.
DEFINE VARIABLE h-b1wgen0188             AS HANDLE   NO-UNDO.
DEFINE VARIABLE h-b1wgen9998             AS HANDLE   NO-UNDO.
DEFINE VARIABLE h-b1wgen9999             AS HANDLE   NO-UNDO. 
DEFINE VARIABLE h-b1wgen0112             AS HANDLE   NO-UNDO.


DEFINE VARIABLE h-bo_algoritmo_seguranca AS HANDLE   NO-UNDO.

ASSIGN aux_hostname = OS-GETENV("HOST")
       aux_nmarqlog = "log/TAA/TAA_autorizador_" + 
                      STRING(YEAR(TODAY),"9999") +
                      STRING(MONTH(TODAY),"99")  +
                      STRING(DAY(TODAY),"99")    + ".log".

/* log desabilitado OUTPUT STREAM str_1 TO VALUE(aux_nmarqlog) APPEND. */


CREATE X-DOCUMENT xDoc.
CREATE X-NODEREF  xRoot.
CREATE X-NODEREF  xRoot2.
CREATE X-NODEREF  xField.
CREATE X-NODEREF  xText.


/* Recebe a requisicao */
REQUISICAO:
DO:
    DEFINE VARIABLE xml_req      AS CHAR     NO-UNDO.
    DEFINE VARIABLE aux_contador AS INTEGER  NO-UNDO.

    /* Restaura a requisicao HTML que nao usa " ", "=" */
    ASSIGN xml_req = GET-VALUE("xml")
           xml_req = REPLACE(xml_req,"%20"," ")
           xml_req = REPLACE(xml_req,"%3D","=").

    /* log - desabilitado 
    PUT STREAM str_1 UNFORMATTED
        STRING(TODAY,"99/99/9999") + " - " +
        STRING(TIME,"HH:MM:SS")    + " - " +
        "REQUISICAO: " + xml_req SKIP. */

    IF   xml_req = ""   THEN
         DO:
             aux_dscritic = "XML em Branco.".
             LEAVE REQUISICAO.
         END.

    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1.
    PUT-STRING(ponteiro_xml,1) = xml_req.

    xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE).
    xDoc:GET-DOCUMENT-ELEMENT(xRoot).

    IF   xRoot:NAME <> "TAA"   THEN
         DO:
             aux_dscritic = "XML Inválido.".
             LEAVE REQUISICAO.
         END.
    
    DO  aux_contador = 1 TO xRoot:NUM-CHILDREN:

        xRoot:GET-CHILD(xField,aux_contador).

        IF   xField:SUBTYPE <> "ELEMENT"   THEN
             NEXT.

        xField:GET-CHILD(xText,1).

        /* Validacao dos parametros de configuracao */
        IF  xField:NAME = "OPERACAO"   THEN
            aux_operacao = INT(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "CDCOPTFN"   THEN
             DO:
                 FIND crapcop WHERE crapcop.cdcooper = INT(xText:NODE-VALUE) NO-LOCK NO-ERROR.
                 FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper      NO-LOCK NO-ERROR.
                 NEXT.
             END.
        ELSE
        IF   xField:NAME = "CDAGETFN"   THEN
             DO:
                 FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper   AND
                                    crapage.cdagenci = INT(xText:NODE-VALUE)
                                    NO-LOCK NO-ERROR.
                 NEXT.
             END.
        ELSE
        IF   xField:NAME = "NRTERFIN"   THEN
             DO:
                 FIND craptfn WHERE craptfn.cdcooper = crapcop.cdcooper   AND
                                    craptfn.nrterfin = INT(xText:NODE-VALUE)
                                    NO-LOCK NO-ERROR.
                 NEXT.
             END.

        IF   (NOT AVAIL crapcop   OR
             NOT AVAIL crapdat   OR
             NOT AVAIL crapage   OR
             NOT AVAIL craptfn) AND aux_operacao <> 200   THEN
             DO:
                 aux_dscritic = "Parâmetros Inválidos.".
                 LEAVE REQUISICAO.
             END.
        
        
        /* Operacoes e campos do XML recebido */
        IF  xField:NAME = "OPERACAO"   THEN
            aux_operacao = INT(xText:NODE-VALUE).
        ELSE
        IF  xField:NAME = "DSCARTAO"   THEN
            ASSIGN aux_dscartao = xText:NODE-VALUE.
        ELSE
        IF  xField:NAME = "CDCOOPER"   THEN
            aux_cdcooper = INT(xText:NODE-VALUE).
        ELSE
        IF  xField:NAME = "NRDCONTA"   THEN
            par_nrdconta = INT(xText:NODE-VALUE).
        ELSE
        IF  xField:NAME = "CDAGECTL"   THEN
            par_cdagectl = INT(xText:NODE-VALUE).
        ELSE
        IF  xField:NAME = "NRCARTAO"   THEN
            DO:
                ASSIGN aux_nrcartao = DEC(xText:NODE-VALUE).
                
                /* Busca o numero da conta de acordo com o cartao inserido */
                RUN busca_numero_conta(INPUT aux_nrcartao,
                                       OUTPUT aux_nrdconta,
                                       OUTPUT aux_dscritic).
                
                IF RETURN-VALUE <> "OK" THEN
                   DO:
                       IF aux_dscritic = "" THEN
                          ASSIGN aux_dscritic = "Erro ao buscar o numero da conta".
                       
                       LEAVE REQUISICAO.
                   END.    
            END.        
        ELSE
        IF  xField:NAME = "CDOPERAD"   THEN
            aux_cdoperad = xText:NODE-VALUE.
        ELSE
        IF   xField:NAME = "DSSENCAR"   THEN
             aux_dssencar = xText:NODE-VALUE.
        ELSE
        IF   xField:NAME = "DTNASCTO"   THEN
             aux_dtnascto = xText:NODE-VALUE.
        ELSE
        IF   xField:NAME = "NRTRANSF"   THEN
             aux_nrtransf = INT(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "VLTRANSF"   THEN
             aux_vltransf = DEC(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "DTTRANSF"   THEN
             aux_dttransf = DATE(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "DTINIEXT"   THEN
             aux_dtiniext = DATE(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "DTFIMEXT"   THEN
             aux_dtfimext = DATE(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "INISENTA"   THEN
             aux_inisenta = INT(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME BEGINS "QTNOTK7"  THEN
             DO:
                 IF  xField:NAME = "QTNOTK7A"  THEN
                     aux_qtnotaK7[1] = INT(xText:NODE-VALUE).
                 ELSE
                 IF  xField:NAME = "QTNOTK7B"  THEN
                     aux_qtnotaK7[2] = INT(xText:NODE-VALUE).
                 ELSE
                 IF  xField:NAME = "QTNOTK7C"  THEN
                     aux_qtnotaK7[3] = INT(xText:NODE-VALUE).
                 ELSE
                 IF  xField:NAME = "QTNOTK7D"  THEN
                     aux_qtnotaK7[4] = INT(xText:NODE-VALUE).
                 ELSE
                 IF  xField:NAME = "QTNOTK7R"  THEN
                     aux_qtnotaK7[5] = INT(xText:NODE-VALUE).
             END.
        ELSE
        IF   xField:NAME BEGINS "VLNOTK7"  THEN
             DO:
                 IF  xField:NAME = "VLNOTK7A"  THEN
                     aux_vlnotaK7[1] = INT(xText:NODE-VALUE).
                 ELSE
                 IF  xField:NAME = "VLNOTK7B"  THEN
                     aux_vlnotaK7[2] = INT(xText:NODE-VALUE).
                 ELSE
                 IF  xField:NAME = "VLNOTK7C"  THEN
                     aux_vlnotaK7[3] = INT(xText:NODE-VALUE).
                 ELSE
                 IF  xField:NAME = "VLNOTK7D"  THEN
                     aux_vlnotaK7[4] = INT(xText:NODE-VALUE).
                 ELSE
                 IF  xField:NAME = "VLNOTK7R"  THEN
                     aux_vlnotaK7[5] = INT(xText:NODE-VALUE).
             END.
        ELSE
        IF   xField:NAME = "TPRECOLH"  THEN
             aux_tprecolh = INT(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "NRSEQUNI"  THEN
             aux_nrsequni = INT(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "NRSEQENV"  THEN
             aux_nrseqenv = INT(xText:NODE-VALUE).  /* NSU da coop. destino*/     
        ELSE
        IF   xField:NAME = "NRSEQENL"  THEN
             aux_nrseqenl = INT(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "NRDOCMTO"  THEN
             aux_nrdocmto = INT(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "NRCTAFAV"  THEN
             aux_nrctafav = INT(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "VLDININF"  THEN
             aux_vldininf = DEC(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "VLCHQINF"  THEN
             aux_vlchqinf = DEC(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "VLDSDINI"  THEN
             aux_vldsdini = DEC(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "VLDMOVTO"  THEN
             aux_vldmovto = DEC(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "VLDSDFIN"  THEN
             aux_vldsdfin = DEC(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "VLDSAQUE"   THEN
             aux_vldsaque = DEC(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "HRTRANSA"   THEN
             aux_hrtransa = INT(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "DTMVTOLT"   THEN
             aux_dtmvtolt = DATE(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME BEGINS "CDBARRA"  AND
             xText:NODE-VALUE <> ?         THEN
             DO:
                 IF  xField:NAME = "CDBARRA1"  THEN
                     aux_cdbarra1 = xText:NODE-VALUE.
                 ELSE
                 IF  xField:NAME = "CDBARRA2"  THEN
                     aux_cdbarra2 = xText:NODE-VALUE.
                 ELSE
                 IF  xField:NAME = "CDBARRA3"  THEN
                     aux_cdbarra3 = xText:NODE-VALUE.
                 ELSE
                 IF  xField:NAME = "CDBARRA4"  THEN
                     aux_cdbarra4 = xText:NODE-VALUE.
                 ELSE
                 IF  xField:NAME = "CDBARRA5"  THEN
                     aux_cdbarra5 = xText:NODE-VALUE.
             END.            
        ELSE
        IF   xField:NAME = "DSCODBAR"  THEN
             aux_dscodbar = xText:NODE-VALUE.
        ELSE
        IF   xField:NAME = "VLDPAGTO"  THEN
             aux_vldpagto = DEC(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "DATPAGTO" THEN
            aux_datpagto = DATE(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "DTVENCTO" THEN
            aux_dtvencto = DATE(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "TPCPTDOC" THEN
            aux_tpcptdoc = INT(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "CDEMPCON" THEN
            aux_cdempcon = INTE(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "CDSEGMTO" THEN
            aux_cdsegmto = INTE(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "DTAUTORI" THEN
            aux_dtautori = DATE(xText:NODE-VALUE).
        ELSE
        IF    xField:NAME = "FLAGENDA" THEN
              aux_flagenda = LOGICAL(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "HRININOT"  THEN
             aux_hrininot = INT(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "HRFIMNOT"  THEN
             aux_hrfimnot = INT(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "VLSAQNOT"  THEN
             aux_vlsaqnot = DEC(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "NRTEMPOR"  THEN
             aux_nrtempor = INT(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "VLRMAXDB"  THEN
             aux_vlrmaxdb = DECI(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "CDREFERE"  THEN
             aux_cdrefere = DECI(xText:NODE-VALUE).        
        ELSE
        IF   xField:NAME = "IDMOTIVO"  THEN
             aux_idmotivo = INTE(xText:NODE-VALUE).        
        ELSE
        IF   xField:NAME = "CDHISTOR"  THEN
             aux_cdhistor = INTE(xText:NODE-VALUE).        
        ELSE        
        /* Utilizado na versao 1 do TAA, deve ser removido apos todas as maquinas
           migrarem para versao 2, que usa tpdsaldo */
        IF   xField:NAME = "FLGLOGAR"  THEN
             aux_flglogar = LOGICAL(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "TPDSALDO"  THEN
             aux_tpdsaldo = INT(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "DTINITRA"  THEN
             aux_dtinitra = DATE(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "QTDMESES"  THEN
             aux_qtdmeses = INT(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "LSDATAQD"  THEN
             aux_lsdataqd = xText:NODE-VALUE.
        ELSE
        IF   xField:NAME = "DTMVTOPG"  THEN
             aux_dtmvtopg = DATE(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "DTINIPRO"   THEN
             aux_dtinipro = DATE(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "DTFIMPRO"   THEN
             aux_dtfimpro = DATE(xText:NODE-VALUE). 
        ELSE
        IF   xField:NAME = "TPEXTRAT"   THEN
             aux_tpextrat = INTE(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "DSPREFIX"   THEN
             aux_dsprefix = xText:NODE-VALUE.
        ELSE
        IF   xField:NAME = "DSDGRUP1"   THEN
             aux_dsdgrup1 = xText:NODE-VALUE.
        ELSE
        IF   xField:NAME = "DSDGRUP2"   THEN
             aux_dsdgrup2 = xText:NODE-VALUE.
        ELSE
        IF   xField:NAME = "DSDGRUP3"   THEN
             aux_dsdgrup3 = xText:NODE-VALUE.
        ELSE
        IF   xField:NAME = "CDAGETRA"   THEN
             aux_cdagetra = INTE (xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "TPOPERAC"   THEN
             aux_tpoperac = INTE (xText:NODE-VALUE) .
        ELSE
        IF   xField:NAME = "VLEMPRST"   THEN
             aux_vlemprst = DECI(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "DIAPAGTO"   THEN
             aux_diapagto = INTE(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "TXMENSAL"   THEN
             aux_txmensal = DECI(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "QTPREEMP"   THEN
             aux_qtpreemp = INTE(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "VLPREEMP"   THEN
             aux_vlpreemp = DECI(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "PERCETOP"   THEN
             aux_percetop = DECI(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "VLTARIFA"   THEN
             aux_vltarifa = DECI(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "DTDPAGTO"   THEN
             aux_dtdpagto = DATE(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "DTMVTOPR"   THEN
             aux_dtmvtopr = DATE(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "VLPAREPR"   THEN
             aux_vlparepr = DECI(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "NRPAREPR"   THEN
             aux_nrparepr = INTE(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "VLTAXIOF"   THEN
             aux_vltaxiof = DECI(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "VLTARIOF"   THEN
             aux_vltariof = DECI(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "TPUSUCAR"   THEN
             aux_tpusucar = INTE(xText:NODE-VALUE).
         ELSE
        IF   xField:NAME = "IDTIPCAR"   THEN
             aux_idtipcar = INTE(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "NRRECBEN"   THEN
             aux_nrrecben = DECI(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "DTCOMPET"   THEN
             aux_dtcompet = xText:NODE-VALUE.
        ELSE
        IF   xField:NAME = "VLRTARIF"   THEN
             aux_vlrtarif = DECI(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "NRDDD" THEN
             aux_nrdddtfc = DECI(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "NRTELEFO" THEN
             aux_nrtelefo = DECI(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "TPTELEFO" THEN
             aux_tptelefo = INTE(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "FLGACSMS" THEN
             aux_flgacsms = INTE(xText:NODE-VALUE).
		ELSE
		IF   xField:NAME = "TITULO1" THEN
             aux_titulo1 = DECI(xText:NODE-VALUE).
		ELSE
		IF   xField:NAME = "TITULO2" THEN
             aux_titulo2 = DECI(xText:NODE-VALUE).
		ELSE
		IF   xField:NAME = "TITULO3" THEN
             aux_titulo3 = DECI(xText:NODE-VALUE).
		ELSE
		IF   xField:NAME = "TITULO4" THEN
             aux_titulo4 = DECI(xText:NODE-VALUE).
		ELSE
		IF   xField:NAME = "TITULO5" THEN
             aux_titulo5 = DECI(xText:NODE-VALUE).
		ELSE
		IF   xField:NAME = "CODIGO_BARRAS" THEN
             aux_codigo_barras = STRING(xText:NODE-VALUE).
        ELSE
		IF   xField:NAME = "NRCTLNPC" THEN
        DO:
             aux_cdctrlcs = STRING(xText:NODE-VALUE). 
             IF aux_cdctrlcs = ? THEN    
                aux_cdctrlcs = "".
        END.         
		ELSE
        IF   xField:NAME = "FLGSITRC" THEN
             aux_flgsitrc = INTE(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "CDOPERADORA" THEN
             aux_cdoperadora = INTE(xText:NODE-VALUE).             
        ELSE
        IF   xField:NAME = "CDPRODUTO" THEN
             aux_cdproduto = INTE(xText:NODE-VALUE).             
        ELSE
        IF   xField:NAME = "VLRECARGA" THEN
             aux_vlrecarga = DECI(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "NRDDDTEL" THEN
             aux_nrdddtel = INTE(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "NRCELULAR" THEN
             aux_nrcelular = DECI(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "DTRECARGA" THEN
             aux_dtrecarga = xText:NODE-VALUE.
        ELSE
        IF   xField:NAME = "QTMESAGD" THEN
             aux_qtmesagd = INTE(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "CDDOPCAO" THEN
             aux_cddopcao = INTE(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "LSDATAGD" THEN
             aux_lsdatagd = xText:NODE-VALUE.
        ELSE
        /* Projeto 363 - Novo ATM - Inicio */
        IF   xField:NAME = "TOKEN" THEN
             aux_token = xText:NODE-VALUE.
        ELSE
        IF   xField:NAME = "IDTAANEW" THEN
             aux_idtaanew = INTE(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "IDOPEEXE" THEN
             aux_idopeexe = xText:NODE-VALUE.
        ELSE
        IF   xField:NAME = "TPINTERA" THEN
             aux_tpintera = xText:NODE-VALUE.
        /* Projeto 363 - Novo ATM - Fim */
        /* Projeto ECO */ 
        ELSE
        IF   xField:NAME = "TPCONBEN" THEN
             aux_tpconben = INTE(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "NRRECBEN" THEN
             aux_nrrecben = INTE(xText:NODE-VALUE).
        ELSE
        IF   xField:NAME = "CDORGINS" THEN
             aux_cdorgins = INTE(xText:NODE-VALUE).
        /* Projeto ECO */ 
		ELSE
        IF  xField:NAME = "NRREMETE"   THEN
            aux_nrremete = INTE(xText:NODE-VALUE).
        ELSE
        IF  xField:NAME = "CDAGEREM"   THEN
            aux_cdagerem = INTE(xText:NODE-VALUE).

    END.

    IF   aux_operacao = 0   THEN
         aux_dscritic = "XML Inválido.".

END. /* Fim da REQUISICAO */

        
SET-SIZE(ponteiro_xml) = 0.

DELETE OBJECT xDoc.
DELETE OBJECT xRoot.
DELETE OBJECT xRoot2.
DELETE OBJECT xField.
DELETE OBJECT xText.

{ sistema/generico/includes/PLSQL_grava_operacao_TAA.i 
                                            &dboraayl={&scd_dboraayl} }

/* Gera a resposta */
RESPOSTA:
DO:
/*  Usada apenas para o log (desabilitado) */
/*  DEFINE VARIABLE xml_resp     AS LONGCHAR   NO-UNDO. */

    CREATE X-DOCUMENT xDoc.
    CREATE X-NODEREF  xRoot.
    CREATE X-NODEREF  xRoot2.
    CREATE X-NODEREF  xField.
    CREATE X-NODEREF  xText.

    xDoc:CREATE-NODE(xRoot,"TAA","ELEMENT").
    xRoot:SET-ATTRIBUTE("HOSTNAME",aux_hostname).
    xDoc:APPEND-CHILD(xRoot).

    DO  WHILE TRUE:

        IF   aux_dscritic <> ""   THEN
             DO:

                 /* ---------- */
                 xDoc:CREATE-NODE(xField,"DSCRITIC","ELEMENT").
                 xRoot:APPEND-CHILD(xField).
                 xDoc:CREATE-NODE(xText,"","TEXT").
                 xText:NODE-VALUE = aux_dscritic.
                 xField:APPEND-CHILD(xText).
          IF aux_operacao = 200 THEN
            DO:
              /* ---------- */
              xDoc:CREATE-NODE(xField,"CDCRITIC","ELEMENT").
              xRoot:APPEND-CHILD(xField).
              xDoc:CREATE-NODE(xText,"","TEXT").
              xText:NODE-VALUE = STRING(aux_cdcritic).
              xField:APPEND-CHILD(xText).
              
             END.
             
             END.
        ELSE
        IF   aux_operacao = 9999    THEN
             DO:
                 RUN verifica_autorizacao.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 9998    THEN
             DO:
                 RUN confirma_reboot.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 9997    THEN
             DO:
                 RUN confirma_update.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 1  THEN
             DO:
                 RUN verifica_cartao.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 2 OR aux_operacao = 200 THEN
             DO:
                 RUN valida_senha.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 3  THEN
             DO:
                 RUN busca_associado.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 4  THEN
             DO:
                 RUN altera_senha.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 5  THEN
             DO:
                 RUN obtem_saldo_limite.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 6  THEN
             DO:
                 RUN obtem_extrato_conta.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 7  THEN
             DO:
                 RUN obtem_tarifa_extrato.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 8  THEN
             DO:
                 RUN obtem_extrato_aplicacoes.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 9  THEN
             DO:
                 RUN efetua_abertura.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 10  THEN
             DO:
                 RUN efetua_fechamento.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 11  THEN
             DO:
                 RUN efetua_suprimento.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 12  THEN
             DO:
                 RUN efetua_recolhimento.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 13  THEN
             DO:
                 RUN obtem_nsu.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 14  THEN
             DO:
                 RUN entrega_envelope.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 15  THEN
             DO:
                 RUN vira_data.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 16  THEN
             DO:
                 RUN busca_operador.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 17  THEN
             DO:
                 RUN efetua_configuracao.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 18  THEN
             DO:
                 RUN verifica_transferencia.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 19  THEN
             DO:
                 RUN efetua_transferencia.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 20  THEN
             DO:
                 RUN verifica_saque.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 21  THEN
             DO:
                 RUN efetua_saque.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 22  THEN
             DO:
                 RUN confere_saque.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 23  THEN
             DO:
                 RUN atualiza_saldo.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 24  THEN
             DO:
                 RUN horario_deposito.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 25  THEN
             DO:
                 RUN verifica_titulo.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 26  THEN
             DO:
                 RUN paga_titulo.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 27  THEN
             DO:
                 RUN horario_pagamento.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 28  THEN
             DO:
                 RUN verifica_convenio.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 29  THEN
             DO:
                 RUN paga_convenio.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 30  THEN
             DO:
                 RUN atualiza_noturno_temporizador.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 31  THEN
             DO:
                 RUN verifica_agendamento_mensal.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 32  THEN
             DO:
                 RUN efetua_agendamento_mensal.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 33  THEN
             DO:
                 RUN obtem_agendamentos.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 34  THEN
             DO:
                 RUN exclui_agendamentos.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 35   THEN
             DO:
                 RUN verifica_comprovantes.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 36   THEN
             DO:
                 RUN gera_estatistico.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 37   THEN
             DO:
                 RUN valida_senha_letras.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.      
        ELSE
        IF   aux_operacao = 38   THEN
             DO:
                 RUN carrega_cooperativas.

                 IF   RETURN-VALUE = "NOK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 39   THEN
             DO:
                 RUN retorna_valor_blqjud.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 40   THEN
             DO:
                 RUN status_saque.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 41   THEN
             DO:          
                 RUN obtem-autorizacoes-debito.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 42   THEN
             DO:
                 RUN inclui-autorizacao-debito.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.             
        ELSE
        IF   aux_operacao = 43   THEN
             DO:
                 RUN exclui-autorizacao-debito.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 44   THEN
             DO:               
                 RUN busca-convenios-codbarras.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 45   THEN
             DO:               
                 RUN busca-saldo-pre-aprovado.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 46   THEN
             DO:               
                 RUN valida-dados-pre-aprovado.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 47   THEN
             DO:               
                 RUN busca-parcelas-pre-aprovado.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 48   THEN
             DO:               
                 RUN busca-extrato-pre-aprovado.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 49   THEN
             DO:               
                 RUN grava-dados-pre-aprovado.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 50   THEN
             DO:               
                 RUN obtem-taxas-pre-aprovado.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 51   THEN
             DO:               
                 RUN obtem_sequencial_deposito.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 52   THEN
             DO:               
                 RUN verifica_emprst_atraso.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 53   THEN
             DO:               
                 RUN obtem-informacoes-comprovante.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 54   THEN
             DO:               
                 RUN lanca-tarifa-extrato.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 55   THEN
             DO:               
                 RUN busca-beneficiarios-inss.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 56   THEN
             DO:               
                 RUN busca_demonstrativo_inss.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.  
        ELSE
        IF   aux_operacao = 57   THEN
             DO:               
                 RUN verifica-banner.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.          
        ELSE
        IF   aux_operacao = 58   THEN
             DO:               
                 RUN altera-telefone-sms-debaut.
             
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 59   THEN
             DO:               
                 RUN obtem-telefone-sms-debaut.

                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 60   THEN
             DO:               
                 RUN exclui-telefone-sms-debaut.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 61   THEN
             DO:               
                 RUN busca-motivos-exclusao-debaut.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 62   THEN
             DO:               
                 RUN alterar-autorizacao-debito.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
             
        ELSE
		IF   aux_operacao = 63   THEN
             DO:               
                 RUN calcula_valor_titulo.
             
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE 
        IF   aux_operacao = 64   THEN
             DO:               
                 RUN lancamentos-futuros.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
	    ELSE
        IF  aux_operacao = 65  THEN DO:

            RUN atualizacao-telefone.

            IF  RETURN-VALUE <> "OK"   THEN
                NEXT.
        END.
        ELSE
        IF  aux_operacao = 66  THEN DO:

            RUN verifica-atualizacao-telefone.

            IF  RETURN-VALUE <> "OK"   THEN
                NEXT.
        END.
        ELSE
        IF  aux_operacao = 67  THEN DO:

            RUN atualizacao-data-telefone.

            IF  RETURN-VALUE <> "OK"   THEN
                NEXT.
        END.


		ELSE
        IF   aux_operacao = 68   THEN
             DO:               
                 RUN verifica_opcao_recarga.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 69   THEN
             DO:               
                 RUN obtem_favoritos_recarga.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 70   THEN
             DO:               
                 RUN obtem_operadoras_recarga.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.             
        ELSE
        IF   aux_operacao = 71   THEN
             DO:               
                 RUN obtem_valores_recarga.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.             
        ELSE
        IF   aux_operacao = 72   THEN
             DO:               
                 RUN verifica_recarga.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 73   THEN
             DO:               
                 RUN efetua_recarga.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 74   THEN
             DO:               
                 RUN exclui_agendamentos_recarga.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
	      ELSE
        IF   aux_operacao = 75   THEN
             DO:
                 RUN verifica_notas_cem.

                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
	      ELSE
        IF   aux_operacao = 76   THEN
             DO:
                 RUN busca_convenio_nome.

                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 77   THEN
             DO:
                 RUN verifica_opcao_benef_inss.

                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 78   THEN
             DO:
                 RUN listar_beneficios_inss.

                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
		ELSE
        IF   aux_operacao = 79   THEN
             DO:
                 RUN consultar_eco.

                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.

	    ELSE
        IF   aux_operacao = 80   THEN
             DO:
                 RUN busca_modalidade.

                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        ELSE
        IF   aux_operacao = 81   THEN
             DO:
                 RUN valida_modalidade_transferencia.

                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
		ELSE
        /* Inicio P485 */
        IF   aux_operacao = 82   THEN
             DO:
                 RUN verifica_modalidade_conta.

                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.
        /* Fim P485 */
        ELSE
        IF   aux_operacao = 83 THEN
             DO:
                 RUN verifica_conta_monitorada.
                 
                 IF   RETURN-VALUE <> "OK"   THEN
                      NEXT.
             END.

        LEAVE.
    END.


    /* log -> nao usa quebra de linha */
    xDoc:SAVE("MEMPTR",ponteiro_xml).
/*  Usada apenas para o log (desabilitado) */
/*  xml_resp = GET-STRING(ponteiro_xml,1) NO-ERROR. */
/*  COPY-LOB FROM ponteiro_xml TO xml_resp CONVERT SOURCE CODEPAGE "UTF-8" NO-ERROR. */

    /* verifica se o XML é muito extenso, e importa somente 32K */
/*  IF  ERROR-STATUS:ERROR  THEN
        xml_resp = GET-STRING(ponteiro_xml,32000).

    ASSIGN xml_resp = REPLACE(xml_resp,CHR(10),"")
           xml_resp = REPLACE(xml_resp,CHR(13),"").
*/
    SET-SIZE(ponteiro_xml) = 0.

    /* log desabilitado 
    PUT STREAM str_1 UNFORMATTED
        STRING(TODAY,"99/99/9999") + " - " +
        STRING(TIME,"HH:MM:SS")    + " - " +
        "RESPOSTA: " + xml_resp SKIP. */

    xDoc:SAVE("STREAM","WEBSTREAM").

    DELETE OBJECT xDoc.
    DELETE OBJECT xRoot.
    DELETE OBJECT xRoot2.
    DELETE OBJECT xField.
    DELETE OBJECT xText.
END.

/* log desabilitado OUTPUT STREAM str_1 CLOSE. */




PROCEDURE verifica_autorizacao:

    DEFINE VARIABLE aux_agctltfn    AS INT          NO-UNDO.

    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.
                                                                                     
    RUN verifica_autorizacao IN h-b1wgen0025 ( INPUT crapcop.cdcooper,
                                               INPUT craptfn.nrterfin,
                                              OUTPUT aux_dscritic).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            DELETE PROCEDURE h-b1wgen0025.
            RETURN "NOK".
        END.


    /* agencia da cooperativa do TAA */
    RUN verifica_agencia_central IN h-b1wgen0025 ( INPUT crapcop.cdcooper,
                                                  OUTPUT aux_agctltfn).

    DELETE PROCEDURE h-b1wgen0025.


    /* controle de versao do TAA */
    FIND craptab WHERE craptab.cdcooper = 3             AND
                       craptab.nmsistem = "CRED"        AND
                       craptab.tptabela = "AUTOMA"      AND
                       craptab.cdempres = 0             AND
                       craptab.cdacesso = "DSVERTAA"    AND
                       craptab.tpregist = 1             NO-LOCK NO-ERROR.




    /* ---------- */
    xDoc:CREATE-NODE(xField,"AUTORIZACAO","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).


    /* ---------- */
    xDoc:CREATE-NODE(xField,"NMCOPTFN","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = crapcop.nmrescop.
    xField:APPEND-CHILD(xText).


    /* ---------- */
    xDoc:CREATE-NODE(xField,"AGCTLTFN","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_agctltfn).
    xField:APPEND-CHILD(xText).


    /* ---------- */
    xDoc:CREATE-NODE(xField,"DTMVTOAN","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(crapdat.dtmvtoan,"99/99/9999").
    xField:APPEND-CHILD(xText).


    /* ---------- */
    xDoc:CREATE-NODE(xField,"DTMVTOLT","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(crapdat.dtmvtolt,"99/99/9999").
    xField:APPEND-CHILD(xText).


    /* ---------- */
    xDoc:CREATE-NODE(xField,"DTMVTOPR","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(crapdat.dtmvtopr,"99/99/9999").
    xField:APPEND-CHILD(xText).


    /* ---------- */
    xDoc:CREATE-NODE(xField,"DTMVTOCD","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(crapdat.dtmvtocd,"99/99/9999").
    xField:APPEND-CHILD(xText).


    /* Informa se deve fazer reboot */
    IF  craptfn.inreboot = 1  THEN
        DO:
            /* ---------- */
            xDoc:CREATE-NODE(xField,"REBOOT","ELEMENT").
            xRoot:APPEND-CHILD(xField).
    
            xDoc:CREATE-NODE(xText,"","TEXT").
            xText:NODE-VALUE = "YES".
            xField:APPEND-CHILD(xText).
        END.


    /* Informa se deve fazer atualizar o sistema */
    IF  AVAILABLE craptab                     AND
        craptfn.dsvertaa <> craptab.dstextab  AND
        craptfn.flupdate  = YES               THEN
        DO:
            /* ---------- */
            xDoc:CREATE-NODE(xField,"UPDATE","ELEMENT").
            xRoot:APPEND-CHILD(xField).
    
            xDoc:CREATE-NODE(xText,"","TEXT").
            xText:NODE-VALUE = "YES".
            xField:APPEND-CHILD(xText).
        END.

    RETURN "OK".
END PROCEDURE.
/* Fim 9999 - verifica_autorizacao */






PROCEDURE confirma_reboot:

    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.
                                                                                     
    RUN confirma_reboot IN h-b1wgen0025 ( INPUT crapcop.cdcooper,
                                          INPUT craptfn.nrterfin,
                                         OUTPUT aux_dscritic).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            DELETE PROCEDURE h-b1wgen0025.
            RETURN "NOK".
        END.

    /* ---------- */
    xDoc:CREATE-NODE(xField,"REBOOT","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    RETURN "OK".
END PROCEDURE.
/* Fim 9998 - confirma_reboot */





PROCEDURE confirma_update:

    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.
                                                                                     
    RUN confirma_update IN h-b1wgen0025 ( INPUT crapcop.cdcooper,
                                          INPUT craptfn.nrterfin,
                                         OUTPUT aux_dscritic).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            DELETE PROCEDURE h-b1wgen0025.
            RETURN "NOK".
        END.

    /* ---------- */
    xDoc:CREATE-NODE(xField,"UPDATE","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    RETURN "OK".
END PROCEDURE.
/* Fim 9998 - confirma_update */





PROCEDURE verifica_cartao:

    DEFINE VARIABLE aux_nrcpfcgc AS DECIMAL INIT 0 NO-UNDO.
    
    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.
                                                                                     
    RUN verifica_cartao IN h-b1wgen0025(       INPUT crapcop.cdcooper, /* Coop do TAA */
                                               INPUT craptfn.nrterfin, /* Nro do TAA */
                                               INPUT aux_dscartao, 
                                               INPUT crapdat.dtmvtocd,
                                              OUTPUT aux_nrdconta,
                                              OUTPUT aux_cdcooper,
                                              OUTPUT aux_nrcartao,
                                              OUTPUT aux_inpessoa,
                                              OUTPUT aux_idsenlet,
                                              OUTPUT aux_tpusucar,
                                              OUTPUT aux_idtipcar,
                                              OUTPUT aux_dscritic).

    DELETE PROCEDURE h-b1wgen0025.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".

    /* Projeto 363 - Novo ATM */
    /* Verificar o tipo de pessoa para identificar o CPF / CNPJ */
    IF aux_inpessoa = 1 THEN
    DO:
        /* Pessoa Fisica, buscar o CPF do TITULAR */ 
        FIND FIRST crapttl
             WHERE crapttl.cdcooper = aux_cdcooper
               AND crapttl.nrdconta = aux_nrdconta
               AND crapttl.idseqttl = aux_tpusucar
              NO-LOCK NO-ERROR.

        /* Verificar se foi encontrado o titular */ 
        IF AVAILABLE crapttl THEN
            ASSIGN aux_nrcpfcgc = crapttl.nrcpfcgc.
    END.
        ELSE
        DO:
            /* Pessoa Juridica, buscar o CNPJ da conta */ 
            FIND FIRST crapass 
                 WHERE crapass.cdcooper = aux_cdcooper
                   AND crapass.nrdconta = aux_nrdconta
                  NO-LOCK NO-ERROR.

            /* Verificar se foi encontrado a conta */ 
            IF AVAILABLE crapass THEN
                ASSIGN aux_nrcpfcgc = crapass.nrcpfcgc.
        END.


    /* ---------- */
    xDoc:CREATE-NODE(xField,"CDCOOPER","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_cdcooper).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"NRDCONTA","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_nrdconta).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"NRCARTAO","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_nrcartao).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"INPESSOA","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_inpessoa).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"IDSENLET","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_idsenlet).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"TPUSUCAR","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_tpusucar).
    xField:APPEND-CHILD(xText).
    
    /* ---------- */
    xDoc:CREATE-NODE(xField,"IDTIPCAR","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_idtipcar).
    xField:APPEND-CHILD(xText).  
    

    /* ---------- */
    xDoc:CREATE-NODE(xField,"NRCPFCGC","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_nrcpfcgc).
    xField:APPEND-CHILD(xText).  

    RETURN "OK".
    
END PROCEDURE.
/* Fim 1 - verifica_cartao */

PROCEDURE valida_senha:

    DEF VAR aux_token AS CHAR NO-UNDO.
    DEF VAR aux_idorigem AS INTE NO-UNDO.

    /* Verificar se a rotina está sendo chamada pelo sistema NOVO */
    IF aux_idtaanew = 1 THEN
    DO:
        /* Se for o sistema novo a senha será enviada aberta, e devemos criptografar */
        ASSIGN aux_dssencar = ENCODE(aux_dssencar).
    END.

    /* Toda operacao do TAA é com origem no TAA, por isso por default o valor é 4 */
    ASSIGN aux_idorigem = 4.
    /* Operacao 200 é utilizada apenas na URA, com isso vamos alterar a origem  para 6.*/
    IF aux_operacao = 200 THEN
        ASSIGN aux_idorigem = 6.


    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.
                                                                                     
    RUN valida_senha IN h-b1wgen0025( INPUT aux_cdcooper, 
                                      INPUT aux_nrdconta,
                                      INPUT aux_nrcartao,
                                      INPUT aux_dssencar,
                                      INPUT aux_dtnascto,
                                      INPUT aux_idtipcar,
                                      INPUT aux_idorigem,
                                     OUTPUT aux_cdcritic,
                                     OUTPUT aux_dscritic).

    DELETE PROCEDURE h-b1wgen0025.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".

    /* 
      Se nao ocorreu erro na validacao de senha devera se criado um TOKEN
      esse TOKEN sera validado em outras rotinas TA para garantir que a senha eh valida
    */ 

    /* Verificar se a rotina está sendo chamada pelo sistema NOVO */
    IF aux_idtaanew = 1 THEN
    DO:
        /* Somente o sistema novo terá a geracao do TOKEN */

        /* 
          Foram criados os seguintes parametros para na mensageria, que serao enviados gravados nessa nova tabela
          aux_idopeexe -> ID da Operacao que está sendo executado (Ex: "IB027","TA037","IB181")
          aux_tpintera -> Tipo de Interacao (O IB181 , além de outros, que possuim mais de uma operacao mas sempre sao chamados pelo mesmo codigo)
        */ 

        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        
        /* Efetuar a chamada a rotina Oracle */ 
         RUN STORED-PROCEDURE pc_cria_autenticacao_cartao
         aux_handproc = PROC-HANDLE NO-ERROR 
                  ( INPUT aux_cdcooper  /* pr_cdcooper --> Codigo da cooperativa */
                   ,INPUT aux_nrdconta  /* pr_nrdconta --> Número da Conta do associado */
                   ,INPUT STRING(aux_nrcartao)  /* pr_nrcartao --> Número do cartao do associado */
                   ,INPUT aux_idopeexe  /* pr_cdoperacao  --> ID da Operaçao que está sendo executado (Ex: "IB027","TA037","IB181") */
                   ,INPUT aux_tpintera  /* pr_tpinteracao --> Tipo de Interaçao (O IB181 , além de outros, que possuim mais de uma operacao mas sempre sao chamados pelo mesmo codigo) */
                   /* --------- OUT --------- */
                   ,OUTPUT ""           /* pr_token    --> Token gerado na transaçao */
                   ,OUTPUT "" ).        /* pr_dscritic --> Descriçao da critica).  */
                   
         /* Fechar o procedimento para buscarmos o resultado */ 
          CLOSE STORED-PROC pc_cria_autenticacao_cartao
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.  
                            
         { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
      
        ASSIGN aux_token = pc_cria_autenticacao_cartao.pr_token
                      WHEN pc_cria_autenticacao_cartao.pr_token <> ?.
        ASSIGN aux_dscritic = pc_cria_autenticacao_cartao.pr_dscritic
                      WHEN pc_cria_autenticacao_cartao.pr_dscritic <> ?.  

        IF  aux_dscritic <> "" THEN
            DO:
               RETURN "NOK".
            END.        
    END.


    /* ---------- */
    xDoc:CREATE-NODE(xField,"SENHA","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    /* Devolver o TOKEN que geramos */
    IF aux_token <> ? AND aux_token <> "" THEN
    DO:
        xDoc:CREATE-NODE(xField,"TOKEN","ELEMENT").
        xRoot:APPEND-CHILD(xField).
        
        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = aux_token.
        xField:APPEND-CHILD(xText).
    END.

    RETURN "OK".
END PROCEDURE.
/* Fim 2 - valida_senha */







PROCEDURE busca_associado:
    
    DEFINE VARIABLE aux_cdagectl    AS INT                      NO-UNDO.
    DEFINE VARIABLE aux_nmrescop    AS CHAR                     NO-UNDO.
    DEFINE VARIABLE aux_nmtitula    AS CHAR     EXTENT 2        NO-UNDO.
    DEFINE VARIABLE aux_flgmigra    AS LOGICAL                  NO-UNDO.
    DEFINE VARIABLE aux_flgdinss    AS LOGICAL  INIT NO         NO-UNDO.
    DEFINE VARIABLE aux_flgbinss    AS LOGICAL  INIT NO         NO-UNDO.    


    IF   aux_cdagetra <> 0   THEN
         DO:
             FIND crapcop WHERE crapcop.cdagectl = aux_cdagetra
                                NO-LOCK NO-ERROR.

             IF   AVAIL crapcop   THEN
                  ASSIGN aux_cdcooper = crapcop.cdcooper.
         END.

    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.
                                                                                     
    RUN busca_associado IN h-b1wgen0025( INPUT aux_cdcooper, 
                                         INPUT aux_nrtransf,
                                        OUTPUT aux_cdagectl,
                                        OUTPUT aux_nmrescop,
                                        OUTPUT aux_nmtitula,
                                        OUTPUT aux_flgmigra,
                                        OUTPUT aux_dscritic).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            DELETE PROCEDURE h-b1wgen0025.
            RETURN "NOK".
        END.

    RUN verifica_prova_vida_inss IN h-b1wgen0025( INPUT aux_cdcooper,
                                                  INPUT aux_nrtransf,
                                                 OUTPUT aux_flgdinss,
                                                 OUTPUT aux_flgbinss,
                                                 OUTPUT aux_dscritic).

    DELETE PROCEDURE h-b1wgen0025.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".

   
    /* ---------- */
    xDoc:CREATE-NODE(xField,"CDAGECTL","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_cdagectl).
    xField:APPEND-CHILD(xText).


    /* ---------- */
    xDoc:CREATE-NODE(xField,"NMRESCOP","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_nmrescop).
    xField:APPEND-CHILD(xText).
    

    /* ---------- */
    xDoc:CREATE-NODE(xField,"NMTITULA1","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = aux_nmtitula[1].
    xField:APPEND-CHILD(xText).


    IF  aux_nmtitula[2] <> ""  THEN
        DO:
            /* ---------- */
            xDoc:CREATE-NODE(xField,"NMTITULA2","ELEMENT").
            xRoot:APPEND-CHILD(xField).
            
            xDoc:CREATE-NODE(xText,"","TEXT").
            xText:NODE-VALUE = aux_nmtitula[2].
            xField:APPEND-CHILD(xText).
        END.


    /* ---------- */
    xDoc:CREATE-NODE(xField,"FLGMIGRA","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_flgmigra).
    xField:APPEND-CHILD(xText).

            
    /* ---------- */
    IF  aux_flgbinss  THEN
        DO:
            xDoc:CREATE-NODE(xField,"FLGBINSS","ELEMENT").
            xRoot:APPEND-CHILD(xField).
            
            xDoc:CREATE-NODE(xText,"","TEXT").
            xText:NODE-VALUE = "yes".
            xField:APPEND-CHILD(xText).
        END.

    RETURN "OK".
END PROCEDURE.
/* Fim 3 - busca_associado */






PROCEDURE altera_senha:

    /* Verificar se a rotina está sendo chamada pelo sistema NOVO */
    IF aux_token <> "" AND aux_token <> ? THEN
    DO:

        /* autenticidade da senha de letras, vamos verificar se o TOKEN eh valido  */
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        
        /* Efetuar a chamada a rotina Oracle */ 
         RUN STORED-PROCEDURE pc_busca_autenticacao_cartao
         aux_handproc = PROC-HANDLE NO-ERROR 
                  ( INPUT aux_cdcooper  /* pr_cdcooper --> Codigo da cooperativa */
                   ,INPUT aux_nrdconta  /* pr_nrdconta --> Número da Conta do associado */
                   ,INPUT aux_token     /* pr_token    --> Token gerado na transaçao */
                   /* --------- OUT --------- */
                   ,OUTPUT "" ).        /* pr_dscritic --> Descriçao da critica).  */
                   
         /* Fechar o procedimento para buscarmos o resultado */ 
          CLOSE STORED-PROC pc_busca_autenticacao_cartao
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.  
                            
         { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
      
        ASSIGN aux_dscritic = pc_busca_autenticacao_cartao.pr_dscritic
                      WHEN pc_busca_autenticacao_cartao.pr_dscritic <> ?.  

        IF  aux_dscritic <> "" THEN
            DO:
               RETURN "NOK".
            END. 
    
        /* Se for o sistema novo a senha será enviada aberta, e devemos criptografar */
        ASSIGN aux_dssencar = ENCODE(aux_dssencar).
    END.

    /* Cartao Magnetico */
    IF aux_idtipcar = 1 THEN
       DO:
           RUN sistema/generico/procedures/b1wgen0032.p PERSISTENT SET h-b1wgen0032.

           RUN alterar-senha-cartao-magnetico IN h-b1wgen0032
                                              (INPUT aux_cdcooper, /* Cooperativa */
                                               INPUT 0,            /* PA */ 
                                               INPUT 0,            /* Caixa */
                                               INPUT "996",        /* Operador */
                                               INPUT "TAA",        /* Tela */
                                               INPUT 4,            /* Origem - TAA */
                                               INPUT aux_nrdconta, /* Conta */
                                               INPUT 1,            /* Titular */
                                               INPUT aux_dtmvtolt, /* Data */
                                               INPUT aux_nrcartao, /* Cartao */
                                               INPUT "",           /* Senha Atual */
                                               INPUT aux_dssencar, /* Nova Senha - Criptografada */
                                               INPUT "",           /* Confirmacao de Senha */
                                               INPUT YES,          /* LOG */
                                               OUTPUT TABLE tt-erro).

           DELETE PROCEDURE h-b1wgen0032.

           IF  RETURN-VALUE = "NOK"  THEN
               DO:
                   FIND FIRST tt-erro NO-LOCK NO-ERROR.
                   
                   IF  AVAILABLE tt-erro  THEN
                       aux_dscritic = tt-erro.dscritic.
                   ELSE
                       aux_dscritic = "Problemas na BO 32".

                   RETURN "NOK".
               END. 
               
       END. /* END IF aux_idtipcar = 1 THEN */
    ELSE
    /* Cartao de Credito */
    IF aux_idtipcar = 2 THEN
       DO:
           IF NOT VALID-HANDLE(h-b1wgen0025) THEN
              RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.
                                                                      
           RUN alterar-senha-cartao-credito IN h-b1wgen0025(INPUT aux_cdcooper,
                                                            INPUT aux_nrdconta,
                                                            INPUT aux_nrcartao,
                                                            INPUT aux_dtmvtolt,                                                            
                                                            INPUT aux_dssencar,
                                                            OUTPUT aux_dscritic).
                                            
           IF RETURN-VALUE <> "OK" THEN
              DO:
                  IF VALID-HANDLE(h-b1wgen0025) THEN
                     DELETE PROCEDURE h-b1wgen0025.
             
                  IF aux_dscritic = "" THEN
                     ASSIGN aux_dscritic = "Problemas na BO 25.".
                    
                  RETURN "NOK".
              END.
                  
           IF VALID-HANDLE(h-b1wgen0025) THEN
              DELETE PROCEDURE h-b1wgen0025.       
       
       END. /* END IF aux_idtipcar = 2 THEN */
    ELSE    
       DO:
           ASSIGN aux_dscritic = "Tipo de cartao invalido.".
           RETURN "NOK".
       END.

    /* ---------- */
    xDoc:CREATE-NODE(xField,"SENHA","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    RETURN "OK".
    
END PROCEDURE.
/* Fim 4 - altera_senha */

PROCEDURE obtem_saldo_limite:

    DEF VAR vr_cdcritic         AS INTE                         NO-UNDO.
    DEF VAR vr_dscritic         AS CHAR                         NO-UNDO.
    DEF VAR aux_idastcjt        AS INTE                         NO-UNDO.
    DEF VAR aux_cdcritic        AS INTE                         NO-UNDO.

    /* se deve logar a operacao */
    IF  aux_flglogar      OR
        aux_tpdsaldo > 0  THEN
        DO:
            RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.

                /* Impressao de saldo */
            IF  aux_tpdsaldo = 2  THEN
                RUN gera_estatistico IN h-b1wgen0025 (INPUT crapcop.cdcooper, /* Coop do TAA */
                                                      INPUT craptfn.nrterfin, /* Nro do TAA */
                                                      INPUT "SD",             /* Prefixo TAA versao 1 */
                                                      INPUT aux_cdcooper,     /* Coop do Associado */
                                                      INPUT aux_nrdconta,     /* Conta do Associado */
                                                      INPUT 11).              /* Impressao de Saldo */
            ELSE
                /* Consulta de saldo */
                RUN gera_estatistico IN h-b1wgen0025 (INPUT crapcop.cdcooper, /* Coop do TAA */
                                                      INPUT craptfn.nrterfin, /* Nro do TAA */
                                                      INPUT "SD",             /* Prefixo TAA versao 1 */
                                                      INPUT aux_cdcooper,     /* Coop do Associado */
                                                      INPUT aux_nrdconta,     /* Conta do Associado */
                                                      INPUT 10).              /* Consulta de Saldo */
            
            DELETE PROCEDURE h-b1wgen0025.
        END.

    /* SE FOR INCLUSA NOVA CONSULTA NESTA OPERACAO, 
    O PROGRAMA programa tempo_execucao_taa.p DEVE SER AJUSTADO! */

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    

     RUN STORED-PROCEDURE pc_verifica_rep_assinatura
         aux_handproc = PROC-HANDLE NO-ERROR
                                 (INPUT aux_cdcooper, /* Cooperativa */
                                  INPUT aux_nrdconta, /* Nr. da conta */
                                  INPUT 1,   /* Sequencia de titular */
                                  INPUT 4,   /* Origem - TAA */
                                  OUTPUT 0,  /* Codigo 1 exige Ass. Conj. */
                                  OUTPUT 0,  /* CPF do Rep. Legal */
                                  OUTPUT "", /* Nome do Rep. Legal */
                                  OUTPUT 0,  /* Cartao Magnetico conjunta, 0 nao, 1 sim */
                                  OUTPUT 0,  /* Codigo do erro */
                                  OUTPUT ""). /* Descricao do erro */

     CLOSE STORED-PROC pc_verifica_rep_assinatura
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

     { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

     ASSIGN aux_idastcjt = 0
            aux_cdcritic = 0
            aux_dscritic = ""           
            aux_idastcjt = pc_verifica_rep_assinatura.pr_idastcjt
                               WHEN pc_verifica_rep_assinatura.pr_idastcjt <> ?
            aux_cdcritic = pc_verifica_rep_assinatura.pr_cdcritic
                               WHEN pc_verifica_rep_assinatura.pr_cdcritic <> ?
            aux_dscritic = pc_verifica_rep_assinatura.pr_dscritic
                               WHEN pc_verifica_rep_assinatura.pr_dscritic <> ?.           

     IF  aux_cdcritic <> 0   OR
         aux_dscritic <> ""  THEN
         DO:
             IF  aux_dscritic = "" THEN
                ASSIGN aux_dscritic =  "Nao foi possivel verificar assinatura conjunta.".

             RETURN "NOK".
         END.

    /* SALDOS */
    TRANS_SALDO:
    DO TRANSACTION ON ERROR UNDO, LEAVE:
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
    
        /* Utilizar o tipo de busca A, para carregar do dia anterior
           (U=Nao usa data, I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1) */ 
        RUN STORED-PROCEDURE pc_obtem_saldo_dia_prog
                aux_handproc = PROC-HANDLE NO-ERROR
                                        (INPUT aux_cdcooper,
                                         INPUT 91,
                                         INPUT 999, /* nrdcaixa */
                                         INPUT "996", 
                                         INPUT aux_nrdconta,
                                         INPUT crapdat.dtmvtocd,
                                         INPUT "A", /* Tipo Busca */
                                         OUTPUT 0,
                                         OUTPUT "").
                                         
        CLOSE STORED-PROC pc_obtem_saldo_dia_prog
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
            
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
            
        ASSIGN vr_cdcritic = 0
               vr_dscritic = ""
               vr_cdcritic = pc_obtem_saldo_dia_prog.pr_cdcritic 
                              WHEN pc_obtem_saldo_dia_prog.pr_cdcritic <> ?
               vr_dscritic = pc_obtem_saldo_dia_prog.pr_dscritic
                              WHEN pc_obtem_saldo_dia_prog.pr_dscritic <> ?. 
    
        IF vr_cdcritic <> 0  OR 
           vr_dscritic <> "" THEN
            DO: 
                IF  vr_dscritic = "" THEN
                    ASSIGN aux_dscritic =  "Nao foi possivel carregar os saldos.".
                    
                aux_dscritic = tt-erro.dscritic.
                RETURN "NOK".
            END.
          
        FIND FIRST wt_saldos NO-LOCK NO-ERROR.
        IF  NOT AVAILABLE wt_saldos  THEN
        DO:
            aux_dscritic = "Saldo não encontrado.".
            RETURN "NOK".
        END.
    END.

    /* LIMITE */
    RUN sistema/generico/procedures/b1wgen0019.p PERSISTENT SET h-b1wgen0019.

    /* SE FOR INCLUSO NOVO PARAMETRO, 
    O PROGRAMA programa tempo_execucao_taa.p DEVE SER AJUSTADO! */
    RUN obtem-valor-limite IN h-b1wgen0019 (INPUT aux_cdcooper,
                                            INPUT 91,           /* PAC */
                                            INPUT 999,          /* Caixa */
                                            INPUT "996",        /* Operador */
                                            INPUT "TAA",        /* Tela */
                                            INPUT 4,            /* Origem - TAA */
                                            INPUT aux_nrdconta,
                                            INPUT 1,            /* Titular */
                                            INPUT TRUE,         /* Log */
                                           OUTPUT TABLE tt-limite-credito,
                                           OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0019.


    FIND FIRST tt-erro NO-LOCK NO-ERROR.

    IF  AVAILABLE tt-erro  THEN
        DO:
            aux_dscritic = tt-erro.dscritic.
            RETURN "NOK".
        END.


    FIND FIRST tt-limite-credito NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE tt-limite-credito  THEN
        DO:
            aux_dscritic = "Limite não encontrado.".
            RETURN "NOK".
        END.



    /* LANCAMENTOS FUTUROS */
    RUN sistema/generico/procedures/b1wgen0003.p PERSISTENT SET h-b1wgen0003.

    /* SE FOR INCLUSO NOVO PARAMETRO, 
    O PROGRAMA programa tempo_execucao_taa.p DEVE SER AJUSTADO! */
    RUN consulta-lancamento IN h-b1wgen0003 (INPUT  aux_cdcooper,
                                             INPUT  91,             /* PAC */
                                             INPUT  999,            /* Caixa */
                                             INPUT  "996",          /* Operador */
                                             INPUT  aux_nrdconta,
                                             INPUT  4,              /* Origem - TAA */
                                             INPUT  1,              /* Titular */
                                             INPUT  "TAL",          /* Tela */
                                             INPUT  TRUE,           /* Log */
                                             OUTPUT TABLE tt-totais-futuros,
                                             OUTPUT TABLE tt-erro,
                                             OUTPUT TABLE tt-lancamento_futuro).

    DELETE PROCEDURE h-b1wgen0003.
                     
    FIND FIRST tt-erro NO-LOCK NO-ERROR.

    IF  AVAILABLE tt-erro  THEN
        DO:
            aux_dscritic = tt-erro.dscritic.
            RETURN "NOK".
        END.

    FIND FIRST tt-totais-futuros NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE tt-totais-futuros  THEN
        DO:
            aux_dscritic = "Lançamentos não encontrados.".
            RETURN "NOK".
        END.
                            
                            


    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLSDDISP","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(wt_saldos.vlsddisp).
    xField:APPEND-CHILD(xText).


    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLLAUTOM","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(tt-totais-futuros.VLLAUDEB).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLLAUCRE","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(tt-totais-futuros.VLLAUCRE).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLSDBLOQ","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(wt_saldos.vlsdbloq).
    xField:APPEND-CHILD(xText).


    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLBLQTAA","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(wt_saldos.vlblqtaa).
    xField:APPEND-CHILD(xText).


    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLSDBLPR","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(wt_saldos.vlsdblpr).
    xField:APPEND-CHILD(xText).


    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLSDBLFP","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(wt_saldos.vlsdblfp).
    xField:APPEND-CHILD(xText).


    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLSDCHSL","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(wt_saldos.vlsdchsl).
    xField:APPEND-CHILD(xText).


    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLLIMCRE","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(tt-limite-credito.vllimcre).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"IDASTCJT","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_idastcjt).
    xField:APPEND-CHILD(xText).    

    RETURN "OK".
END PROCEDURE.
/* Fim 5 - obtem_saldo */


PROCEDURE obtem_extrato_conta:
    DEF VAR aux_dsextrat AS CHAR NO-UNDO.
    /* EXTRATOS */
    RUN sistema/generico/procedures/b1wgen0001.p PERSISTENT SET h-b1wgen0001.

    RUN consulta-extrato IN h-b1wgen0001 (INPUT aux_cdcooper,
                                          INPUT 91,             /* PAC */
                                          INPUT 999,           /* Caixa */
                                          INPUT "996",         /* Operador */
                                          INPUT aux_nrdconta,
                                          INPUT aux_dtiniext,
                                          INPUT aux_dtfimext,
                                          INPUT 4,             /* Origem - TAA */
                                          INPUT 1,             /* Titular */
                                          INPUT "TAA",         /* Tela */
                                          INPUT TRUE,          /* Log */
                                         OUTPUT TABLE tt-erro,
                                         OUTPUT TABLE tt-extrato_conta).

    


    FIND FIRST tt-extrato_conta NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE tt-extrato_conta  THEN
        DO:
            DELETE PROCEDURE h-b1wgen0001.

            aux_dscritic = "Lançamentos não encontrados.".
            RETURN "NOK".
        END.



    /* controle antigo do sistema anterior para estatistico de extratos */
    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.

    /* Extrato Corrente - Atual */
    IF  MONTH(aux_dtiniext) = MONTH(TODAY)  THEN
        RUN gera_estatistico IN h-b1wgen0025 (INPUT crapcop.cdcooper, /* Coop do TAA */
                                              INPUT craptfn.nrterfin, /* Nro do TAA */
                                              INPUT "EC",             /* Prefixo */
                                              INPUT aux_cdcooper,     /* Coop do Associado */
                                              INPUT aux_nrdconta,     /* Conta do Associado */
                                              INPUT 1).               /* Extrato C/C */
    ELSE
    /* Extrato Anterior */
        RUN gera_estatistico IN h-b1wgen0025 (INPUT crapcop.cdcooper, /* Coop do TAA */
                                              INPUT craptfn.nrterfin, /* Nro do TAA */
                                              INPUT "EA",             /* Prefixo */
                                              INPUT aux_cdcooper,     /* Coop do Associado */
                                              INPUT aux_nrdconta,     /* Conta do Associado */
                                              INPUT 1).               /* Extrato C/C */

    DELETE PROCEDURE h-b1wgen0025.

    /* Insenta o extrato de tarifa por ser solicitação de Extrato EM TELA (aux_inisenta = 2)
       NOTA: o parâmetro 'inisenta' não está em uso na procedure 'gera-tarifa-extrato' */
    IF  aux_inisenta <> 2 THEN
        DO:
            /* se trouxe lancamentos, gera registro na crapext */
            RUN gera-tarifa-extrato IN h-b1wgen0001  (INPUT aux_cdcooper, 
                                                      INPUT 91,            /* PAC */
                                                      INPUT 999,           /* Caixa */
                                                      INPUT "996",         /* Operador */
                                                      INPUT "TAA",         /* Tela */
                                                      INPUT 4,             /* Origem - TAA */
                                                      INPUT aux_nrdconta, 
                                                      INPUT 1,             /* Titularidade */
                                                      INPUT aux_dtiniext, 
                                                /*    INPUT aux_inisenta,  /* 0-Nao Isenta  1-Isenta */ */
                                                      INPUT 1,             /* Ind. Processo - 1 On-Line */
                                                      INPUT YES,           /* Tarifar */ 
                                                      INPUT YES,           /* LOG */
                                                      INPUT crapcop.cdcooper, /* Coop do TAA */
                                                      INPUT crapage.cdagenci, /* PAC do TAA */ 
                                                      INPUT craptfn.nrterfin, /* Nro do TAA */
                                                     OUTPUT TABLE tt-msg-confirma,
                                                     OUTPUT TABLE tt-erro).
        
            DELETE PROCEDURE h-b1wgen0001.
        
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
              
                    IF  AVAIL tt-erro  THEN
                        aux_dscritic = STRING(aux_cdcooper) + " - " + STRING(aux_nrdconta) + " - " + tt-erro.dscritic.

                    RETURN "NOK".
                END.
        END. /* Insenção de Tarifa por Extrato EM TELA */

    FOR EACH tt-extrato_conta NO-LOCK
             BY tt-extrato_conta.dtmvtolt
               BY tt-extrato_conta.nrsequen:

        IF LENGTH(TRIM(tt-extrato_conta.dscomple)) > 0 THEN
            ASSIGN aux_dsextrat = tt-extrato_conta.dsextrat + " - " + tt-extrato_conta.dscomple.
        ELSE
            ASSIGN aux_dsextrat = tt-extrato_conta.dsextrat.
        
        /* ---------- */
        xDoc:CREATE-NODE(xField,"DDMVTOLT","ELEMENT").
        xRoot:APPEND-CHILD(xField).
        
        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(DAY(tt-extrato_conta.dtmvtolt),"99").
        xField:APPEND-CHILD(xText).


        /* ---------- */
        xDoc:CREATE-NODE(xField,"DSHISTOR","ELEMENT").
        xRoot:APPEND-CHILD(xField).
        
        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = tt-extrato_conta.dshistor.
        xField:APPEND-CHILD(xText).

        /* ---------- */
        xDoc:CREATE-NODE(xField,"DSEXTRAT","ELEMENT").
        xRoot:APPEND-CHILD(xField).
        
        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = aux_dsextrat.                                
        xField:APPEND-CHILD(xText).

        /* ---------- */
        xDoc:CREATE-NODE(xField,"NRDOCMTO","ELEMENT").
        xRoot:APPEND-CHILD(xField).
        
        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = IF  tt-extrato_conta.nrdocmto = ""  THEN "-"
                           ELSE tt-extrato_conta.nrdocmto.
        xField:APPEND-CHILD(xText).


        /* ---------- */
        xDoc:CREATE-NODE(xField,"INDEBCRE","ELEMENT").
        xRoot:APPEND-CHILD(xField).
        
        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = IF  tt-extrato_conta.indebcre = ""  THEN "-"
                           ELSE tt-extrato_conta.indebcre.
        xField:APPEND-CHILD(xText).


        /* ---------- */
        xDoc:CREATE-NODE(xField,"VLLANMTO","ELEMENT").
        xRoot:APPEND-CHILD(xField).
        
        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-extrato_conta.vllanmto).
        xField:APPEND-CHILD(xText).

    END.


    RETURN "OK".
END PROCEDURE.
/* Fim 6 - obtem_extrato_conta */



PROCEDURE obtem_tarifa_extrato:

    DEFINE VARIABLE tab_vltarifa    AS DECIMAL      NO-UNDO.
    DEFINE VARIABLE tab_qtextper    AS DECIMAL      NO-UNDO.

    DEFINE VARIABLE h-b1wgen0153    AS HANDLE       NO-UNDO.
    DEFINE VARIABLE h-b1wgen0001    AS HANDLE       NO-UNDO.

    DEFINE VARIABLE aux_cdbattar    AS CHAR         NO-UNDO.
    DEFINE VARIABLE aux_cdhisest    AS INTE         NO-UNDO.
    DEFINE VARIABLE aux_dtdivulg    AS DATE         NO-UNDO.
    DEFINE VARIABLE aux_dtvigenc    AS DATE         NO-UNDO.
    DEFINE VARIABLE aux_vllanaut    AS DECIMAL      NO-UNDO.
    DEFINE VARIABLE aux_cdhistor    AS INTE         NO-UNDO.
    DEFINE VARIABLE aux_cdfvlcop    AS INTE         NO-UNDO.
    DEFINE VARIABLE aux_dsconteu    AS CHAR         NO-UNDO.

    DEFINE VARIABLE aux_inisenta    AS INTE         NO-UNDO. 
    DEFINE VARIABLE aux_qtopdisp    AS INTE         NO-UNDO.
    DEFINE VARIABLE aux_cdcritic    AS INTE         NO-UNDO.
    DEFINE VARIABLE aux_tpservic    AS INTE         NO-UNDO.
    DEFINE VARIABLE aux_dscritic    AS CHAR         NO-UNDO.
    DEFINE VARIABLE aux_flservic    AS INTEGER      NO-UNDO.

    ASSIGN  tab_vltarifa = 0
            tab_qtextper = 0
            aux_inisenta = 0.

    FIND crapass WHERE crapass.cdcooper = aux_cdcooper      AND
                       crapass.nrdconta = aux_nrdconta
                       NO-LOCK NO-ERROR .

    /* Verifica qual tarifa deve ser cobrada com base tipo pessoa e se mensal ou periodo */
    IF aux_dtiniext < ( aux_dtmvtolt - 30 ) THEN /* Periodo */
        DO:
            ASSIGN aux_tpservic = 9.
            IF crapass.inpessoa = 1 THEN /* Fisica */
                ASSIGN aux_cdbattar = "EXTPETAAPF".
            ELSE
                ASSIGN aux_cdbattar = "EXTPETAAPJ".
        END.
    ELSE /* Mensal */
        DO:
            ASSIGN aux_tpservic = 7.
            IF crapass.inpessoa = 1 THEN /* Fisica */
                ASSIGN aux_cdbattar = "EXTMETAAPF".
            ELSE
                ASSIGN aux_cdbattar = "EXTMETAAPJ".
        END.


    IF NOT VALID-HANDLE(h-b1wgen0153) THEN
        RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT SET h-b1wgen0153.

    /*  Busca valor da tarifa extrato */
    RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                    (INPUT aux_cdcooper,
                                    INPUT aux_cdbattar,
                                    INPUT 1,             /* vllanmto */
                                    INPUT "TAA",         /* cdprogra */
                                    OUTPUT aux_cdhistor,
                                    OUTPUT aux_cdhisest,
                                    OUTPUT aux_vllanaut,
                                    OUTPUT aux_dtdivulg,
                                    OUTPUT aux_dtvigenc,
                                    OUTPUT aux_cdfvlcop,
                                    OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0153) THEN
           DELETE PROCEDURE h-b1wgen0153. 

    IF aux_vllanaut > 0 THEN
        ASSIGN  tab_vltarifa = aux_vllanaut.

    IF NOT VALID-HANDLE(h-b1wgen0153) THEN
        RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT SET h-b1wgen0153.
    
    /*  Busca quantidade limite de extratos por mes livres de tarifacao*/
    RUN carrega_par_tarifa_vigente IN h-b1wgen0153
                                (INPUT aux_cdcooper,
                                INPUT "EXTMESISEN",
                                OUTPUT aux_dsconteu,
                                OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0153) THEN
           DELETE PROCEDURE h-b1wgen0153.


    ASSIGN  tab_qtextper = INTE(aux_dsconteu).

    IF tab_qtextper > 0 THEN
    DO:

        /* VERIFICACAO PACOTE DE TARIFAS */
        { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
        RUN STORED-PROCEDURE pc_verifica_pacote_tarifas
            aux_handproc = PROC-HANDLE NO-ERROR
                                    (INPUT aux_cdcooper,  /* Código da Cooperativa */
                                     INPUT aux_nrdconta,  /* Numero da Conta */
                                     INPUT 4,  /* Origem */
                                     INPUT aux_tpservic,   /* Tipo de Servico */
                                     OUTPUT 0,            /* Flag de Pacote */
                                     OUTPUT 0,            /* Flag de Sevico */
                                     OUTPUT 0,            /* Quantidade de Operacoes Disponiveis */
                                     OUTPUT 0,            /* Código da crítica */
                                     OUTPUT "").          /* Descrição da crítica */ 
        
        CLOSE STORED-PROC pc_verifica_pacote_tarifas
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
        { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN aux_cdcritic = 0
               aux_dscritic = ""
               aux_cdcritic = pc_verifica_pacote_tarifas.pr_cdcritic 
                              WHEN pc_verifica_pacote_tarifas.pr_cdcritic <> ?
               aux_dscritic = pc_verifica_pacote_tarifas.pr_dscritic
                              WHEN pc_verifica_pacote_tarifas.pr_dscritic <> ?.
        
        IF aux_cdcritic <> 0   OR
           aux_dscritic <> ""  THEN
             DO:
                 RETURN "NOK".
             END.
                                                   
        ASSIGN /* retorna qtd. de extratos isentos que ainda possui disponivel no pacote de tarifas */
               aux_qtopdisp = pc_verifica_pacote_tarifas.pr_qtopdisp
               /* retorna pr_flservic = 1 quando existir o servico "extrato" no pacote */
               aux_flservic = pc_verifica_pacote_tarifas.pr_flservic.

        IF aux_qtopdisp > 0 THEN
            DO:
              ASSIGN tab_vltarifa = 0.
              RETURN "OK".
            END.
          
        /*FIM VERIFICACAO TARIFAS DE SAQUE*/
    
        /* Quando o cooperado NAO possuir o servico "extrato" contemplado no pacote de tarifas,
           devera validar a qtd. de extratos isentos oferecidos pela cooperativa(parametro). 
           Caso contrario, o cooperado tera direito apenas a qtd. disponibilizada no pacote */
        IF   aux_flservic = 0 THEN
             DO:
                /* Verifica se isento da tarifacao do extrato */
        IF NOT VALID-HANDLE(h-b1wgen0001) THEN
            RUN sistema/generico/procedures/b1wgen0001.p PERSISTENT SET h-b1wgen0001.

        /* Verifica se isento da tarifacao do extrato */
        RUN verifica-tarifacao-extrato IN h-b1wgen0001
                                        (INPUT  aux_cdcooper,
                                         INPUT  aux_nrdconta,
                                         INPUT  aux_dtmvtolt,
                                         INPUT  aux_dtiniext,
                                         OUTPUT aux_inisenta,
                                         OUTPUT TABLE tt-erro).
    
        IF  VALID-HANDLE(h-b1wgen0001) THEN
               DELETE PROCEDURE h-b1wgen0001.
             END.
   
        IF  aux_inisenta = 1  THEN
            tab_vltarifa = 0.

    END.

/* 

    /* TARIFA DE EXTRATOS */
    FIND craptab WHERE craptab.cdcooper = aux_cdcooper   AND
                       craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "USUARI"       AND
                       craptab.cdempres = 11             AND
                       craptab.cdacesso = "TRFAEXTRCC"   AND
                       craptab.tpregist = 002            NO-LOCK NO-ERROR.

    IF  AVAILABLE craptab   THEN
        ASSIGN tab_vltarifa = DECIMAL(SUBSTR(craptab.dstextab,01,12))
               tab_qtextper = INTEGER(SUBSTR(craptab.dstextab,14,03)).

*/
/*

    IF  tab_vltarifa > 0 THEN
        FOR EACH crapext WHERE crapext.cdcooper = aux_cdcooper                       AND
                               /* data que emitiu o extrato */
                               crapext.dtreffim >= DATE(MONTH(crapdat.dtmvtolt),01,
                                                         YEAR(crapdat.dtmvtolt))     AND
                               crapext.nrdconta = aux_nrdconta                       AND
                               crapext.tpextrat = 1 /* C/C */                        AND
                               crapext.nrterfin <> 0 /* Emitido em TAA */            AND
                              (crapext.insitext = 1  /* Nao Processado */    OR
                               crapext.insitext = 5) /* Processado */                 NO-LOCK:

            ASSIGN tab_qtextper = tab_qtextper - 1.
        END.


    IF  tab_qtextper > 0  THEN
        tab_vltarifa = 0.
*/

    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLTARIFA","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(tab_vltarifa).
    xField:APPEND-CHILD(xText).


    RETURN "OK".
END PROCEDURE.
/* Fim 7 - obtem_tarifa_extrato */









PROCEDURE obtem_extrato_aplicacoes:

    DEFINE VARIABLE aux_flgexist     AS LOGICAL     INIT NO     NO-UNDO.
    DEFINE VARIABLE aux_vlsldrpp     AS DECIMAL                 NO-UNDO.        
     
    /* EXTRATOS */
    RUN sistema/generico/procedures/b1wgen0004.p PERSISTENT SET h-b1wgen0004. /* Aplicações */
    RUN sistema/generico/procedures/b1wgen0006.p PERSISTENT SET h-b1wgen0006. /* Poup. Programada */

    /* Aplicações RDCA */
    RUN consulta-aplicacoes IN h-b1wgen0004
                                   (INPUT aux_cdcooper,
                                    INPUT 1,             /* PAC */
                                    INPUT 999,           /* Caixa */
                                    INPUT "996",         /* Operador */
                                    INPUT aux_nrdconta,
                                    INPUT 0,             /* Nro da Aplicacao 0-Todas */
                                    INPUT 1,             /* Tipo RDCA */
                                    INPUT aux_dtiniext,
                                    INPUT aux_dtfimext,
                                    INPUT "TAA",         /* Programa */
                                    INPUT 4,             /* Origem - TAA */
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-saldo-rdca).


    FOR EACH tt-saldo-rdca NO-LOCK:

        aux_flgexist = YES.

        /* ---------- */
        xDoc:CREATE-NODE(xField,"DSAPLICA","ELEMENT").
        xRoot:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = "RDCA".
        xField:APPEND-CHILD(xText).


        /* ---------- */
        xDoc:CREATE-NODE(xField,"DDMVTOLT","ELEMENT").
        xRoot:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(DAY(tt-saldo-rdca.dtmvtolt),"99").
        xField:APPEND-CHILD(xText).


        /* ---------- */
        xDoc:CREATE-NODE(xField,"DSHISTOR","ELEMENT").
        xRoot:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = tt-saldo-rdca.dshistor.
        xField:APPEND-CHILD(xText).


        /* ---------- */
        xDoc:CREATE-NODE(xField,"NRDOCMTO","ELEMENT").
        xRoot:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = tt-saldo-rdca.nrdocmto.
        xField:APPEND-CHILD(xText).


        /* ---------- */
        xDoc:CREATE-NODE(xField,"VLLANMTO","ELEMENT").
        xRoot:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-saldo-rdca.sldresga).
        xField:APPEND-CHILD(xText).
    END.


    /* Aplicações RDC */
    RUN consulta-aplicacoes IN h-b1wgen0004
                                   (INPUT aux_cdcooper,
                                    INPUT 1,             /* PAC */
                                    INPUT 999,           /* Caixa */
                                    INPUT "996",         /* Operador */
                                    INPUT aux_nrdconta,
                                    INPUT 0,             /* Nro da Aplicacao 0-Todas */
                                    INPUT 2,             /* Tipo RDC */
                                    INPUT aux_dtiniext,
                                    INPUT aux_dtfimext,
                                    INPUT "TAA",         /* Programa */
                                    INPUT 4,             /* Origem - TAA */
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-saldo-rdca).

    FOR EACH tt-saldo-rdca NO-LOCK:

        aux_flgexist = YES.

        /* ---------- */
        xDoc:CREATE-NODE(xField,"DSAPLICA","ELEMENT").
        xRoot:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = "RDC".
        xField:APPEND-CHILD(xText).

        /* ---------- */
        xDoc:CREATE-NODE(xField,"DTVENCTO","ELEMENT").
        xRoot:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-saldo-rdca.dtvencto).
        xField:APPEND-CHILD(xText).

        /* ---------- */
        xDoc:CREATE-NODE(xField,"DSHISTOR","ELEMENT").
        xRoot:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = tt-saldo-rdca.dshistor.
        xField:APPEND-CHILD(xText).

        /* ---------- */
        xDoc:CREATE-NODE(xField,"NRDOCMTO","ELEMENT").
        xRoot:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = tt-saldo-rdca.nrdocmto.
        xField:APPEND-CHILD(xText).

        /* ---------- */
        xDoc:CREATE-NODE(xField,"VLLANMTO","ELEMENT").
        xRoot:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-saldo-rdca.sldresga).
        xField:APPEND-CHILD(xText).

    END.
     
    RUN busca_aplicacao_car(INPUT aux_cdcooper,
                            INPUT aux_nrdconta,
                            INPUT aux_dtiniext,
                            OUTPUT TABLE tt-saldo-rdca).

    FOR EACH tt-saldo-rdca NO-LOCK:

        aux_flgexist = YES.

        /* ---------- */
        xDoc:CREATE-NODE(xField,"DSAPLICA","ELEMENT").
        xRoot:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        IF tt-saldo-rdca.idtipapl = "1" THEN
           xText:NODE-VALUE = "PRE-FIXADA".
        ELSE
           xText:NODE-VALUE = "POS-FIXADA".
        xField:APPEND-CHILD(xText).

        /* ---------- */
        xDoc:CREATE-NODE(xField,"DTVENCTO","ELEMENT").
        xRoot:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-saldo-rdca.dtvencto).
        xField:APPEND-CHILD(xText).

        /* ---------- */
        xDoc:CREATE-NODE(xField,"DSHISTOR","ELEMENT").
        xRoot:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = tt-saldo-rdca.dsaplica.
        xField:APPEND-CHILD(xText).

        /* ---------- */
        xDoc:CREATE-NODE(xField,"NRDOCMTO","ELEMENT").
        xRoot:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-saldo-rdca.nraplica).
        xField:APPEND-CHILD(xText).

        /* ---------- */
        xDoc:CREATE-NODE(xField,"VLLANMTO","ELEMENT").
        xRoot:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-saldo-rdca.sldresga).
        xField:APPEND-CHILD(xText).

    END.
  
    /* Poupanca Programada */
    RUN consulta-poupanca IN h-b1wgen0006
                                   (INPUT aux_cdcooper,
                                    INPUT 1,             /* PAC */
                                    INPUT 999,           /* Caixa */
                                    INPUT "996",         /* Operador */
                                    INPUT "TAA",         /* Tela */
                                    INPUT 4,             /* Origem - TAA */
                                    INPUT aux_nrdconta,
                                    INPUT 1,             /* Titularidade */
                                    INPUT 0,             /* Nro da Poupança 0-Todas */
                                    INPUT aux_dtiniext,
                                    INPUT aux_dtfimext,
                                    INPUT 1,             /* Processo: 1-On Line */
                                    INPUT "TAA",         /* Programa */
                                    INPUT YES,           /* Log */
                                    OUTPUT aux_vlsldrpp, /* Saldo */
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-dados-rpp).


    FOR EACH tt-dados-rpp NO-LOCK:

        aux_flgexist = YES.

        /* ---------- */
        xDoc:CREATE-NODE(xField,"DSAPLICA","ELEMENT").
        xRoot:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = "POUP.PROGRAMADA".
        xField:APPEND-CHILD(xText).


        /* ---------- */
        xDoc:CREATE-NODE(xField,"DDMVTOLT","ELEMENT").
        xRoot:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(DAY(tt-dados-rpp.dtinirpp),"99").
        xField:APPEND-CHILD(xText).


        /* ---------- */
        xDoc:CREATE-NODE(xField,"DSSITRPP","ELEMENT").
        xRoot:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = tt-dados-rpp.dssitrpp.
        xField:APPEND-CHILD(xText).


        /* ---------- */
        xDoc:CREATE-NODE(xField,"VLPRERPP","ELEMENT").
        xRoot:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-dados-rpp.vlprerpp).
        xField:APPEND-CHILD(xText).


        /* ---------- */
        xDoc:CREATE-NODE(xField,"VLLANMTO","ELEMENT").
        xRoot:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-dados-rpp.vlsdrdpp).
        xField:APPEND-CHILD(xText).

    END.


    DELETE PROCEDURE h-b1wgen0004.
    DELETE PROCEDURE h-b1wgen0006.

    IF  NOT aux_flgexist  THEN
        DO:
            aux_dscritic = "Lançamentos não encontrados.".
            RETURN "NOK".
        END.
    ELSE
        DO:
            /* somente contabiliza o extrato se houve lancamentos */
            RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.
        
            RUN gera_estatistico IN h-b1wgen0025 (INPUT crapcop.cdcooper, /* Coop do TAA */
                                                  INPUT craptfn.nrterfin, /* Nro do TAA */
                                                  INPUT "EP",             /* Prefixo */
                                                  INPUT aux_cdcooper,     /* Coop do Associado */
                                                  INPUT aux_nrdconta,     /* Conta do Associado */
                                                  INPUT 12).              /* Extrato de Aplicacoes */
            
            DELETE PROCEDURE h-b1wgen0025.
        END.

    RETURN "OK".
END PROCEDURE.
/* Fim 8 - obtem_extrato_aplicacoes */



PROCEDURE efetua_abertura:

    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.

    RUN altera_situacao IN h-b1wgen0025 ( INPUT crapcop.cdcooper,
                                          INPUT craptfn.nrterfin,
                                          INPUT "1", /* Abertura */
                                          INPUT aux_cdoperad,
                                          INPUT crapdat.dtmvtocd,
                                          INPUT 0,   /* Valor */
                                         OUTPUT aux_dscritic).
    DELETE PROCEDURE h-b1wgen0025.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".


    /* ---------- */
    xDoc:CREATE-NODE(xField,"ABERTURA","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    RETURN "OK".
END PROCEDURE.
/* Fim 9 - efetua_abertura */





PROCEDURE efetua_fechamento:

    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.

    RUN altera_situacao IN h-b1wgen0025 ( INPUT crapcop.cdcooper,
                                          INPUT craptfn.nrterfin,
                                          INPUT "2", /* Fechamento */
                                          INPUT aux_cdoperad,
                                          INPUT crapdat.dtmvtocd,
                                          INPUT 0, /* Valor */
                                         OUTPUT aux_dscritic).
    DELETE PROCEDURE h-b1wgen0025.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".


    /* ---------- */
    xDoc:CREATE-NODE(xField,"FECHAMENTO","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    RETURN "OK".
END PROCEDURE.
/* Fim 10 - efetua_fechamento */




PROCEDURE efetua_suprimento:

    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.

    RUN efetua_suprimento IN h-b1wgen0025 ( INPUT crapcop.cdcooper,
                                            INPUT craptfn.nrterfin,
                                            INPUT aux_cdoperad,
                                            INPUT aux_qtnotaK7,
                                            INPUT aux_vlnotaK7,
                                           OUTPUT aux_dscritic).

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            DELETE PROCEDURE h-b1wgen0025.
            RETURN "NOK".
        END.


    RUN altera_situacao IN h-b1wgen0025 ( INPUT crapcop.cdcooper,
                                          INPUT craptfn.nrterfin,
                                          INPUT "4", /* Suprimento */
                                          INPUT aux_cdoperad,
                                          INPUT crapdat.dtmvtocd,
                                                /* Valor suprido */
                                          INPUT ((aux_qtnotaK7[1] * aux_vlnotaK7[1]) +
                                                 (aux_qtnotaK7[2] * aux_vlnotaK7[2]) +
                                                 (aux_qtnotaK7[3] * aux_vlnotaK7[3]) +
                                                 (aux_qtnotaK7[4] * aux_vlnotaK7[4])),
                                         OUTPUT aux_dscritic).
    DELETE PROCEDURE h-b1wgen0025.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".


    /* ---------- */
    xDoc:CREATE-NODE(xField,"SUPRIMENTO","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    RETURN "OK".
END PROCEDURE.
/* Fim 11 - efetua_suprimento */





PROCEDURE efetua_recolhimento:

    DEFINE VARIABLE aux_vlrecolh    AS DEC                  NO-UNDO.

    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.

    RUN efetua_recolhimento IN h-b1wgen0025 ( INPUT crapcop.cdcooper,
                                              INPUT craptfn.nrterfin,
                                              INPUT aux_cdoperad,
                                              INPUT aux_tprecolh,
                                             OUTPUT aux_vlrecolh,
                                             OUTPUT aux_dscritic).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            DELETE PROCEDURE h-b1wgen0025.
            RETURN "NOK".
        END.


    /* Recolhimento de numerários */
    IF  aux_tprecolh = 1  THEN
        RUN altera_situacao IN h-b1wgen0025 ( INPUT crapcop.cdcooper,
                                              INPUT craptfn.nrterfin,
                                              INPUT "5", /* Recolhimento */
                                              INPUT aux_cdoperad,
                                              INPUT crapdat.dtmvtocd,
                                              INPUT aux_vlrecolh, /* Valor */
                                             OUTPUT aux_dscritic).

    DELETE PROCEDURE h-b1wgen0025.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".


    /* ---------- */
    xDoc:CREATE-NODE(xField,"RECOLHIMENTO","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    RETURN "OK".
END PROCEDURE.
/* Fim 12 - efetua_recolhimento */






PROCEDURE obtem_nsu:

    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.

    RUN obtem_nsu IN h-b1wgen0025 ( INPUT aux_cdcooper,
                                   OUTPUT aux_nrsequni,
                                   OUTPUT aux_dscritic).

    DELETE PROCEDURE h-b1wgen0025.
    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".


    /* ---------- */
    xDoc:CREATE-NODE(xField,"NRSEQUNI","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_nrsequni).
    xField:APPEND-CHILD(xText).

    RETURN "OK".
END PROCEDURE.
/* Fim 13 - obtem_nsu */

PROCEDURE obtem_sequencial_deposito:    
    
    DEF VAR aux_cdcopdst AS INTE                                NO-UNDO.

    DEF VAR aux_cdagectl AS INTE                                NO-UNDO.
    
    IF par_cdagectl <> ? AND
       par_cdagectl <> 0 THEN
        ASSIGN aux_cdagectl = par_cdagectl.
    ELSE 
        ASSIGN aux_cdagectl = aux_cdcooper.

    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.
    
    /* Variavel aux_cdcooper terá o codigo da agencia da cooperativa de destino */
    FIND crapcop WHERE crapcop.cdagectl =  aux_cdagectl NO-LOCK NO-ERROR.
    IF NOT AVAILABLE crapcop THEN
    DO:
        ASSIGN aux_dscritic = "Cooperativa de destino nao encontrada".
        RETURN "NOK".
    END.
    
    ASSIGN aux_cdcopdst = crapcop.cdcooper.

    /* Busca NSU na coop. de destino */ 
    RUN obtem_nsu IN h-b1wgen0025 ( INPUT aux_cdcopdst, 
                                   OUTPUT aux_nrsequni,
                                   OUTPUT aux_dscritic).

    IF  RETURN-VALUE = "NOK"  THEN
    DO:
        DELETE PROCEDURE h-b1wgen0025.
        RETURN "NOK".
    END.        

    /* Busca Sequencial unico geral */ 
    RUN obtem_sequencial_deposito IN h-b1wgen0025 (OUTPUT aux_nrseqenl,
                                                   OUTPUT aux_dscritic).    
    
    DELETE PROCEDURE h-b1wgen0025.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".

    /* ---------- */
    xDoc:CREATE-NODE(xField,"NRSEQUNI","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_nrsequni).
    xField:APPEND-CHILD(xText).
    /* ---------- */
    xDoc:CREATE-NODE(xField,"NRSEQENL","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_nrseqenl).
    xField:APPEND-CHILD(xText).
    /* ---------- */
    xDoc:CREATE-NODE(xField,"CDCOPDST","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_cdcopdst).
    xField:APPEND-CHILD(xText).

    RETURN "OK".

END PROCEDURE.
/* Fim 51 - obtem_sequencial_deposito */

PROCEDURE entrega_envelope:

    DEFINE VARIABLE aux_dsprotoc    AS CHAR             NO-UNDO.

    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.

    RUN entrega_envelope IN h-b1wgen0025 ( INPUT crapcop.cdcooper, /* Coop. Acolhedora */ 
                                           INPUT craptfn.nrterfin,
                                           INPUT aux_cdcooper,     /* Coop. Destino */ 
                                           INPUT aux_nrseqenv,     /* NSU coop. destino */ 
                                           INPUT aux_nrseqenl,     /* Seq. unico geral */ 
                                           INPUT aux_nrdocmto,
                                           INPUT crapdat.dtmvtocd,
                                           INPUT aux_nrctafav,
                                           INPUT aux_vldininf,
                                           INPUT aux_vlchqinf,
                                          OUTPUT aux_dsprotoc,
                                          OUTPUT aux_dscritic).

    DELETE PROCEDURE h-b1wgen0025.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".



    /* ---------- */
    xDoc:CREATE-NODE(xField,"ENVELOPE","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).


    IF  aux_dsprotoc <> ""  THEN
        DO:
            /* ---------- */
            xDoc:CREATE-NODE(xField,"PROTOCOLO","ELEMENT").
            xRoot:APPEND-CHILD(xField).
    
            xDoc:CREATE-NODE(xText,"","TEXT").
            xText:NODE-VALUE = aux_dsprotoc.
            xField:APPEND-CHILD(xText).
        END.

    RETURN "OK".
END PROCEDURE.
/* Fim 14 - entrega_envelope */







PROCEDURE vira_data:

    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.

    RUN vira_data IN h-b1wgen0025 ( INPUT crapcop.cdcooper,
                                    INPUT craptfn.nrterfin,
                                    INPUT aux_dtmvtolt,
                                    INPUT aux_vldsdini,
                                    INPUT aux_vldmovto,
                                    INPUT aux_vldsdfin,
                                   OUTPUT aux_dscritic).

    DELETE PROCEDURE h-b1wgen0025.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".

    
    /* ---------- */
    xDoc:CREATE-NODE(xField,"VIRADATA","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    RETURN "OK".
END PROCEDURE.
/* Fim 15 - vira_data */





PROCEDURE busca_operador:

    FIND crapope WHERE crapope.cdcooper = aux_cdcooper   AND
                       crapope.cdoperad = aux_cdoperad
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapope  THEN
        DO:
            aux_dscritic = "Operador não cadastrado.".
            RETURN "NOK".
        END.


    /* ---------- */
    xDoc:CREATE-NODE(xField,"NMOPERAD","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = crapope.nmoperad.
    xField:APPEND-CHILD(xText).

    RETURN "OK".
END PROCEDURE.
/* Fim 16 - busca_operador */





PROCEDURE efetua_configuracao:

    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.
                                                                                     
    RUN efetua_configuracao IN h-b1wgen0025 ( INPUT crapcop.cdcooper,
                                              INPUT craptfn.nrterfin,
                                             OUTPUT aux_dscritic).
    DELETE PROCEDURE h-b1wgen0025.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".      


    /* ---------- */
    xDoc:CREATE-NODE(xField,"CONFIGURACAO","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    RETURN "OK".
END PROCEDURE.
/* Fim 17 - efetua_configuracao */





PROCEDURE verifica_transferencia:

    DEFINE VARIABLE aux_cdcritic AS INTEGER                           NO-UNDO.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

	/* Efetuar a chamada a rotina Oracle */ 
	RUN STORED-PROCEDURE pc_valid_repre_legal_trans
		aux_handproc = PROC-HANDLE NO-ERROR (INPUT aux_cdcooper, /* Código da Cooperativa */
											 INPUT aux_nrdconta, /* Número da Conta */
											 INPUT 1,            /* Titular da Conta */
                                             INPUT 0,            
											OUTPUT 0,            /* Código da crítica */
											OUTPUT "").          /* Descrição da crítica */
	
	/* Fechar o procedimento para buscarmos o resultado */ 
	CLOSE STORED-PROC pc_valid_repre_legal_trans
		   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
	
	{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
	
	/* Busca possíveis erros */ 
	ASSIGN aux_cdcritic = 0
		   aux_dscritic = ""
		   aux_cdcritic = pc_valid_repre_legal_trans.pr_cdcritic 
						  WHEN pc_valid_repre_legal_trans.pr_cdcritic <> ?
		   aux_dscritic = pc_valid_repre_legal_trans.pr_dscritic 
						  WHEN pc_valid_repre_legal_trans.pr_dscritic <> ?.

    IF aux_dscritic <> "" THEN
        RETURN "NOK".

    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.

    RUN verifica_transferencia IN h-b1wgen0025 ( INPUT aux_cdcooper,
                                                 INPUT aux_nrdconta,
                                                 INPUT aux_cdagetra,
                                                 INPUT aux_nrtransf,
                                                 INPUT aux_vltransf,
                                                 INPUT aux_dttransf, 
                                                 INPUT aux_tpoperac,
                                                 INPUT aux_flagenda, 
                                                 INPUT crapdat.dtmvtocd,
                                                OUTPUT aux_dscritic).
    DELETE PROCEDURE h-b1wgen0025.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".      


    /* ---------- */
    xDoc:CREATE-NODE(xField,"TRANSFERENCIA","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    RETURN "OK".

END PROCEDURE.
/* Fim 18 - verifica_transferencia */



PROCEDURE efetua_transferencia:

    DEFINE VARIABLE aux_cdhiscre    AS INTEGER                      NO-UNDO.
    DEFINE VARIABLE aux_cdhisdeb    AS INTEGER                      NO-UNDO.
    DEFINE VARIABLE aux_dstransa    AS CHAR                         NO-UNDO.
    DEFINE VARIABLE aux_nrdocdeb    LIKE craplcm.nrdocmto           NO-UNDO.
    DEFINE VARIABLE aux_nrdoccre    LIKE craplcm.nrdocmto           NO-UNDO.
    DEFINE VARIABLE aux_cdlantar    LIKE craplat.cdlantar           NO-UNDO.
    DEFINE VARIABLE aux_dsprotoc    AS CHAR                         NO-UNDO.
    DEFINE VARIABLE aux_cdcoptfn    AS INTE                         NO-UNDO.
    DEFINE VARIABLE aux_cdagetfn    AS INTE                         NO-UNDO.
    DEFINE VARIABLE aux_nrterfin    AS INTE                         NO-UNDO.
    DEFINE VARIABLE aux_cddbanco    AS INTE                         NO-UNDO.
    DEFINE VARIABLE aux_idastcjt    AS INTE                         NO-UNDO.
    DEFINE VARIABLE aux_flcartma    AS INTE                         NO-UNDO.
    DEFINE VARIABLE aux_nrcpfrep    AS DECI                         NO-UNDO.

    /* Para monitoracao, e-mails */
    DEFINE VARIABLE     aux_dsdemail    AS CHAR                     NO-UNDO.
    DEFINE VARIABLE     aux_dsassunt    AS CHAR                     NO-UNDO.
    DEFINE VARIABLE     aux_dsdcorpo    AS CHAR                     NO-UNDO.

    DEFINE VARIABLE     h-b1wgen0011    AS HANDLE                   NO-UNDO.

    DEFINE VARIABLE aux_cdcritic    AS INTEGER                      NO-UNDO.    
    DEFINE VARIABLE aux_msgofatr    AS CHAR                         NO-UNDO.

    DEFINE BUFFER crabass FOR crapass.
    DEFINE BUFFER crabcop FOR crapcop.

    ASSIGN aux_cdcoptfn = crapcop.cdcooper
           aux_cdagetfn = crapage.cdagenci
           aux_nrterfin = craptfn.nrterfin.


    /* Cooperativa Destino */
    FIND crabcop WHERE crabcop.cdagectl = aux_cdagetra NO-LOCK NO-ERROR.

    IF   AVAIL crabcop THEN
         ASSIGN aux_cddbanco = crabcop.cdbcoctl.
 
   { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    
        
    RUN STORED-PROCEDURE pc_verifica_rep_assinatura
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT aux_cdcooper, /* Cooperativa */
                                 INPUT aux_nrdconta, /* Nr. da conta */
                                 INPUT 1,   /* Sequencia de titular */
                                 INPUT 4,   /* Origem - TAA */
                                 OUTPUT 0,  /* Codigo 1 exige Ass. Conj. */
                                 OUTPUT 0,  /* CPF do Rep. Legal */
                                 OUTPUT "", /* Nome do Rep. Legal */
                                 OUTPUT 0,  /* Cartao Magnetico conjunta, 0 nao, 1 sim */
                                 OUTPUT 0,  /* Codigo do erro */
                                 OUTPUT ""). /* Descricao do erro */
    
    CLOSE STORED-PROC pc_verifica_rep_assinatura
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_idastcjt = 0
           aux_cdcritic = 0
           aux_dscritic = ""           
           aux_flcartma = 0
           aux_nrcpfrep = 0
           aux_idastcjt = pc_verifica_rep_assinatura.pr_idastcjt
                              WHEN pc_verifica_rep_assinatura.pr_idastcjt <> ?
           aux_flcartma = pc_verifica_rep_assinatura.pr_flcartma
                              WHEN pc_verifica_rep_assinatura.pr_flcartma <> ?
           aux_nrcpfrep = pc_verifica_rep_assinatura.pr_nrcpfcgc
                              WHEN pc_verifica_rep_assinatura.pr_nrcpfcgc <> ?
           aux_cdcritic = pc_verifica_rep_assinatura.pr_cdcritic
                              WHEN pc_verifica_rep_assinatura.pr_cdcritic <> ?
           aux_dscritic = pc_verifica_rep_assinatura.pr_dscritic
                              WHEN pc_verifica_rep_assinatura.pr_dscritic <> ?.           
      
    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
        DO:
            IF  aux_dscritic = "" THEN
               ASSIGN aux_dscritic =  "Nao foi possivel verificar assinatura conjunta.".
            
            RETURN "NOK".
        END.

    IF  aux_idastcjt = 1 THEN
        DO:
            { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    

            RUN STORED-PROCEDURE pc_cria_trans_pend_transf
             aux_handproc = PROC-HANDLE NO-ERROR
                                     (INPUT aux_tpoperac, /* Tipo da transacao */
                                      INPUT 91,           /* Codigo do PA */
                                      INPUT 900,          /* Numero do caixa */
                                      INPUT "996",        /* Operador */
                                      INPUT "TAA",        /* Nome da tela */
                                      INPUT 4,            /* Id origem */
                                      INPUT 1,            /* Titular */
                                      INPUT IF aux_flcartma = 1 THEN 0 ELSE aux_nrcpfrep, /* CPF do operador juridico */
                                      INPUT IF aux_flcartma = 1 THEN aux_nrcpfrep ELSE 0, /* CPF do representante legal */
                                      INPUT crapcop.cdcooper, /* Cooperativa do terminal */
                                      INPUT crapage.cdagenci, /* Agencia do terminal */
                                      INPUT craptfn.nrterfin, /* Numero do terminal */
                                      INPUT crapdat.dtmvtocd, /* Data de movimento */
                                      INPUT aux_cdcooper, /* Cooperativa */
                                      INPUT aux_nrdconta, /* Nr. da conta */
                                      INPUT aux_vltransf, /* Valor do lancamento */
                                      INPUT aux_dttransf, /* Data da transferencia */
                                      INPUT IF aux_flagenda THEN 2 ELSE 1, /* Indicador de agendamento */
                                      INPUT aux_cdagetra, /* Agencia destino */
                                      INPUT aux_nrtransf, /* Conta de destino */
                                      INPUT "",
                                      INPUT aux_idastcjt,
                                      INPUT 0,
                                      INPUT aux_idtipcar,
                                      INPUT aux_nrcartao,
                                      OUTPUT 0,  /* Codigo do erro */
                                      OUTPUT ""). /* Descricao do erro */
            
            CLOSE STORED-PROC pc_cria_trans_pend_transf
               aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
            
            { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
            
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = ""           
                   aux_cdcritic = pc_cria_trans_pend_transf.pr_cdcritic 
                                      WHEN pc_cria_trans_pend_transf.pr_cdcritic <> ?
                   aux_dscritic = pc_cria_trans_pend_transf.pr_dscritic
                                      WHEN pc_cria_trans_pend_transf.pr_dscritic <> ?.           
            
            IF  aux_cdcritic <> 0   OR
                aux_dscritic <> ""  THEN
                DO:
                    IF  aux_dscritic = "" THEN
                       ASSIGN aux_dscritic =  "Nao foi possivel efetuar transferencia.".
                
                    RETURN "NOK".
                END.                
              
        END.
    ELSE
        DO:
            RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.
        
            IF   aux_tpoperac = 1   THEN /* Transf. IntraCooperativa */
                 DO:
                      RUN verifica-historico-transferencia  IN h-b1wgen0015 
                        (INPUT aux_cdcooper,
                         INPUT aux_nrdconta,
                         INPUT aux_nrtransf,
                         INPUT 4, /* Origem - TAA         */
                         INPUT 1, /* Transferencia Normal */
                        OUTPUT aux_cdhiscre,
                        OUTPUT aux_cdhisdeb).         
                 END.
            ELSE 
            IF   aux_tpoperac = 5   THEN /* Transf. Intercooperativa */
                 ASSIGN aux_cdhisdeb = 1009.
        
            IF  aux_flagenda THEN
                DO:
        
                    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

                    RUN STORED-PROCEDURE pc_cadastrar_agendamento
                        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT aux_cdcooper,     
                                 INPUT 91,           /* par_cdagenci */
                                 INPUT 900,          /* par_nrdcaixa */
                                 INPUT "996",        /* par_cdoperad */
                                 INPUT aux_nrdconta,                   
                                 INPUT 1,            /* par_idseqttl */
                                 INPUT crapdat.dtmvtocd,                        
                                 /* Projeto 363 - Novo ATM */
                                 INPUT 4,            /* par_cdorigem */
                                 INPUT "TAA",        /* par_dsorigem */
                                 INPUT "TAA",        /* par_nmdatela */
                                 INPUT aux_tpoperac, /* par_cdtiptra */
                                 INPUT 0,            /* par_idtpdpag */
                                 INPUT "",           /* par_dscedent */
                                 INPUT "",           /* par_dscodbar */
                                 INPUT 0, /* par_lindigi1 */
                                 INPUT 0, /* par_lindigi2 */
                                 INPUT 0, /* par_lindigi3 */
                                 INPUT 0, /* par_lindigi4 */
                                 INPUT 0, /* par_lindigi5 */
                                 INPUT aux_cdhisdeb,
                                 INPUT aux_dttransf,
                                 INPUT aux_vltransf,
                                 INPUT ?,            /* Data de vencimento */
                                 INPUT aux_cddbanco, 
                                 INPUT aux_cdagetra,
                                 INPUT aux_nrtransf,
                                 INPUT aux_cdcoptfn,
                                 INPUT aux_cdagetfn,
                                 INPUT aux_nrterfin,
                                 INPUT 0,            /* par_nrcpfope */
                                 INPUT "0",          /* par_idtitdda */
                                 INPUT 0,            /* par_cdtrapen */
                                 INPUT 0,
                                 INPUT 0,             /* DDA */
                                 INPUT 0,                                 
                                 INPUT 0,   /* cdfinali */
                                 INPUT ' ', /* dstransf */
                                 INPUT ' ', /* dshistor */
                                 INPUT "",  /* pr_iptransa */
                                 INPUT "",  /* Numero controle consulta npc */   
                                 INPUT '', /* par_iddispos */
                                 INPUT 0,  /* pr_nrridlfp */
                                 
                                OUTPUT 0, 
                                OUTPUT "",  /* pr_dstransa */
                                OUTPUT "",
                                OUTPUT 0,
                                OUTPUT "",                         
                                OUTPUT ""). 
        
                    CLOSE STORED-PROC pc_cadastrar_agendamento
                          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        
                    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

                    ASSIGN aux_dstransa = pc_cadastrar_agendamento.pr_dstransa
                                     WHEN pc_cadastrar_agendamento.pr_dstransa <> ?                        
                           aux_dscritic = pc_cadastrar_agendamento.pr_dscritic
                                     WHEN pc_cadastrar_agendamento.pr_dscritic <> ?
                           aux_msgofatr = pc_cadastrar_agendamento.pr_msgofatr
                                     WHEN pc_cadastrar_agendamento.pr_msgofatr <> ?
                           aux_cdempcon = INT(pc_cadastrar_agendamento.pr_cdempcon)
                                     WHEN pc_cadastrar_agendamento.pr_cdempcon <> ?
                           aux_cdsegmto = INT(pc_cadastrar_agendamento.pr_cdsegmto)
                                     WHEN pc_cadastrar_agendamento.pr_cdsegmto <> ?.
                END.
            ELSE
                DO:
                    IF   aux_tpoperac = 1  THEN /* IntraCooperativa */
                         DO:
                             /* procedure com customizacoes para o novo sistema do TAA e poder manter
                             a estrutura usada pelo sistema da foton */
                         
                             RUN executa_transferencia IN h-b1wgen0015
                                       (INPUT aux_cdcooper,              /* cooperativa do associado - origem */
                                        INPUT crapdat.dtmvtolt,          /* data atual */
                                        INPUT crapdat.dtmvtocd,          /* data do TAA */
                                        INPUT 91,                        /* pac */
                                        INPUT 11,                        /* banco/caixa */
                                        INPUT 11900,                     /* lote */
                                        INPUT 900,                       /* caixa */
                                        INPUT aux_nrdconta,              /* conta do associado - origem */
                                        INPUT 1,                         /* titularidade */
                                        INPUT aux_nrsequni,              /* documento - NSU */
                                        INPUT aux_cdhiscre,              /* historico credito */
                                        INPUT aux_cdhisdeb,              /* historico debito */
                                        INPUT aux_vltransf,              /* valor */
                                        INPUT "996",                     /* operador */
                                        INPUT aux_nrtransf,              /* conta destino - mesma coop */
                                        INPUT FALSE,                     /* nao agendar */
                                        INPUT aux_cdcoptfn,              /* CDCOPTFN */
                                        INPUT aux_cdagetfn,              /* CDAGETFN */                       
                                        INPUT aux_nrterfin,              /* nro do terminal */
                                        INPUT "",                        /* Trilha do Cartao */
                                        INPUT 4,                         /* Origem 4 - TAA */
                                        /*operadores*/
                                        INPUT 0,
                                        INPUT 0,
                                        INPUT aux_idtipcar,
                                        INPUT aux_nrcartao,
                                        OUTPUT aux_dstransa,
                                        OUTPUT aux_dscritic,
                                        OUTPUT aux_nrdocdeb,
                                        OUTPUT aux_nrdoccre,
                                        OUTPUT aux_dsprotoc).
                         END.
                    ELSE     /* InterCooperativa */
                         DO:
                             RUN executa-transferencia-intercooperativa IN h-b1wgen0015
                                                         (INPUT aux_cdcooper,
                                                          INPUT 91,    /* cdagenci */
                                                          INPUT 900,   /* nrdcaixa */
                                                          INPUT "996", /* cdoperad */
                                                          INPUT 4,     /* idorigem */
                                                          INPUT crapdat.dtmvtocd,
                                                          INPUT 1,     /* idagenda */
                                                          INPUT aux_nrdconta,
                                                          INPUT 1,     /* idseqttl */
                                                          INPUT 0,     /* nrcpfope */
                                                          INPUT aux_cddbanco,
                                                          INPUT aux_cdagetra,
                                                          INPUT aux_nrtransf,
                                                          INPUT aux_vltransf,
                                                          INPUT aux_nrsequni,
                                                          INPUT aux_cdcoptfn,
                                                          INPUT aux_nrterfin,
                                                          INPUT 0,
                                                          INPUT aux_idtipcar,
                                                          INPUT aux_nrcartao,
                                                         OUTPUT aux_dsprotoc,
                                                         OUTPUT aux_dscritic,
                                                         OUTPUT aux_nrdocmto,
                                                         OUTPUT aux_nrdoccre,
                                                         OUTPUT aux_cdlantar).
                         END.     
                END.
        
            DELETE PROCEDURE h-b1wgen0015.
        
            IF  RETURN-VALUE  = "NOK"  OR
                aux_dscritic <> ""     THEN
                RETURN "NOK".      
        END.

    /* ---------- */
    xDoc:CREATE-NODE(xField,"TRANSFERENCIA","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    IF    aux_dsprotoc <> ""   THEN
          DO:
              xDoc:CREATE-NODE(xField,"PROTOCOLO","ELEMENT").
              xRoot:APPEND-CHILD(xField).
              
              xDoc:CREATE-NODE(xText,"","TEXT").
              xText:NODE-VALUE = aux_dsprotoc.
              xField:APPEND-CHILD(xText).
          END.

    xDoc:CREATE-NODE(xField,"IDASTCJT","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_idastcjt).
    xField:APPEND-CHILD(xText).

    /* E-mail de monitoracao para transferencias apos saques - Somente em algumas */
    IF  CAN-DO("1,2,4,5,6,7,8,9,10,11,12,13,16",STRING(aux_cdcooper))   THEN
        DO:
            FIND LAST craplcm WHERE craplcm.cdcooper  = aux_cdcooper      AND
                                    craplcm.nrdconta  = aux_nrdconta      AND
                                    craplcm.dtmvtolt  = crapdat.dtmvtocd  AND
                                    craplcm.cdhistor  = 316               NO-LOCK NO-ERROR.
            
            FIND crapcop WHERE crapcop.cdcooper = aux_cdcooper NO-LOCK NO-ERROR.

            /* Considerar valor saque inicial e valor transferencia inicial */
            IF  AVAILABLE craplcm                      AND 
                crapcop.vlinisaq <= craplcm.vllanmto   AND
                crapcop.vlinitrf <= aux_vltransf       THEN
                DO:
                    FIND craptfn WHERE craptfn.cdcooper = aux_cdcoptfn AND
                                       craptfn.nrterfin = aux_nrterfin NO-LOCK NO-ERROR.
    
                    FIND crapage WHERE crapage.cdcooper = craptfn.cdcooper AND
                                       crapage.cdagenci = craptfn.cdagenci NO-LOCK NO-ERROR.
    
                    FIND crapass WHERE crapass.cdcooper = aux_cdcooper AND
                                       crapass.nrdconta = aux_nrdconta NO-LOCK NO-ERROR.

                    ASSIGN aux_dsassunt = crapcop.nmrescop + " - Saque e Transferencia" + " - PA " + STRING(craptfn.cdagenci) +
                                          " - " + crapage.nmcidade + " - " + STRING(craptfn.nrterfin) + " - " +
                                          craptfn.nmterfin
    
                           aux_dsdemail = "prevencaodefraudes@ailos.coop.br"
    
                           aux_dsdcorpo = "PA: " + STRING(craptfn.cdagenci) + " - " + crapage.nmresage + "\n\n" + 
                                          "Conta: " + STRING(aux_nrdconta) + "\n".
    
                    IF  crapass.inpessoa = 1  THEN
                        DO:
                            /* pega todos os titulares */
                            FOR EACH crapttl WHERE crapttl.cdcooper = crapass.cdcooper  AND
                                                   crapttl.nrdconta = crapass.nrdconta  NO-LOCK:
    
                                aux_dsdcorpo = aux_dsdcorpo +
                                               "Titular " + STRING(crapttl.idseqttl) + ": " +
                                               crapttl.nmextttl + "\n".
                            END.
                        END.
                    ELSE
                        DO:
                            /* pega o nome da empresa e os procuradores/representantes */
                            FIND crapjur WHERE crapjur.cdcooper = crapass.cdcooper  AND
                                               crapjur.nrdconta = crapass.nrdconta  NO-LOCK NO-ERROR.
    
                            aux_dsdcorpo = aux_dsdcorpo +
                                           "Empresa: " + crapjur.nmextttl + "\n\n" +
                                           "Procuradores/Representantes: " + "\n".
    
                            FOR EACH crapavt WHERE crapavt.cdcooper = crapass.cdcooper     AND
                                                   crapavt.tpctrato = 6 /* procurador */   AND
                                                   crapavt.nrdconta = crapass.nrdconta     NO-LOCK:
    
                                IF  crapavt.nrdctato <> 0  THEN
                                    DO:
                                        FIND crabass WHERE crabass.cdcooper = crapavt.cdcooper AND
                                                           crabass.nrdconta = crapavt.nrdctato NO-LOCK.
    
                                        aux_dsdcorpo = aux_dsdcorpo +
                                                       crabass.nmprimtl + "\n".
                                    END.
                                ELSE
                                    aux_dsdcorpo = aux_dsdcorpo +
                                                   crapavt.nmdavali + "\n".
                            END.
                        END.
    
                    aux_dsdcorpo = aux_dsdcorpo + "\nFones:\n".
    
                    FOR EACH craptfc WHERE craptfc.cdcooper = aux_cdcooper  AND
                                           craptfc.nrdconta = aux_nrdconta  NO-LOCK:
    
                        aux_dsdcorpo = aux_dsdcorpo + 
                                       "(" + STRING(craptfc.nrdddtfc) + ") " + STRING(craptfc.nrtelefo) + "\n".
                    END.
    
                    aux_dsdcorpo = aux_dsdcorpo +
                                   "\nValor do Saque Anterior: R$ " + STRING(craplcm.vllanmto,"zzz,zz9.99") +
                                   "\nValor da Transferencia: R$ " + STRING(aux_vltransf,"zzz,zz9.99").
    
                    RUN sistema/generico/procedures/b1wgen0011.p
                        PERSISTENT SET h-b1wgen0011.

                    RUN enviar_email_completo IN h-b1wgen0011 
                        (INPUT aux_cdcooper,
                         INPUT "TAA_autorizador",
                         INPUT "prevencaodefraudes@ailos.coop.br",
                         INPUT aux_dsdemail,
                         INPUT aux_dsassunt,
                         INPUT "",
                         INPUT "",
                         INPUT aux_dsdcorpo,
                         INPUT FALSE).

                    DELETE PROCEDURE h-b1wgen0011.

                END.
        END.
    /* E-mail de monitoracao para transferencias apos saques */

    
    RETURN "OK".

END PROCEDURE.
/* Fim 19 - efetura_transferencia */
                              

PROCEDURE verifica_saque:

    DEFINE VARIABLE aux_dssaqmax    AS CHAR             NO-UNDO.
    DEFINE VARIABLE aux_vlsddisp    AS DECI             NO-UNDO.
    DEFINE VARIABLE aux_vllimcre    AS DECI             NO-UNDO.
    DEFINE VARIABLE aux_flgcompr    AS LOGICAL          NO-UNDO.

    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.

    RUN verifica_saque IN h-b1wgen0025 ( INPUT crapcop.cdcooper, /* COOP do TAA       */
                                         INPUT craptfn.nrterfin, /* NRO do TAA        */
                                         INPUT aux_cdcooper,     /* COOP do Associado */
                                         INPUT aux_nrdconta,     
                                         INPUT aux_nrcartao,
                                         INPUT aux_vldsaque,
                                         INPUT crapdat.dtmvtocd,
                                        OUTPUT aux_dssaqmax,
                                        OUTPUT aux_vlsddisp,
                                        OUTPUT aux_vllimcre,
                                        OUTPUT aux_flgcompr,
                                        OUTPUT aux_dscritic).
    DELETE PROCEDURE h-b1wgen0025.

    IF  RETURN-VALUE  = "NOK"  THEN
        DO:
            IF  aux_dssaqmax <> ""  THEN
                DO:
                    /* ---------- */
                    xDoc:CREATE-NODE(xField,"DSSAQMAX","ELEMENT").
                    xRoot:APPEND-CHILD(xField).

                    xDoc:CREATE-NODE(xText,"","TEXT").
                    xText:NODE-VALUE = aux_dssaqmax.
                    xField:APPEND-CHILD(xText).
                END.

            RETURN "NOK".      
        END.


    /* ---------- */
    xDoc:CREATE-NODE(xField,"SAQUE","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"COMPROVANTE","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_flgcompr,"YES/NO").
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLSDDISP","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_vlsddisp).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLLIMCRE","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_vllimcre).
    xField:APPEND-CHILD(xText).

    RETURN "OK".

END PROCEDURE.
/* Fim 20 - verifica_saque */



PROCEDURE efetua_saque:

    /* Verificar se a rotina está sendo chamada pelo sistema NOVO */
    IF aux_token <> "" AND aux_token <> ? THEN
    DO:
        /* autenticidade da senha de letras, vamos verificar se o TOKEN eh valido  */
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        
        /* Efetuar a chamada a rotina Oracle */ 
         RUN STORED-PROCEDURE pc_busca_autenticacao_cartao
         aux_handproc = PROC-HANDLE NO-ERROR 
                  ( INPUT aux_cdcooper  /* pr_cdcooper --> Codigo da cooperativa */
                   ,INPUT aux_nrdconta  /* pr_nrdconta --> Número da Conta do associado */
                   ,INPUT aux_token     /* pr_token    --> Token gerado na transaçao */
                   /* --------- OUT --------- */
                   ,OUTPUT "" ).        /* pr_dscritic --> Descriçao da critica).  */
                   
         /* Fechar o procedimento para buscarmos o resultado */ 
          CLOSE STORED-PROC pc_busca_autenticacao_cartao
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.  
                            
         { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
      
        ASSIGN aux_dscritic = pc_busca_autenticacao_cartao.pr_dscritic
                      WHEN pc_busca_autenticacao_cartao.pr_dscritic <> ?.  

        IF  aux_dscritic <> "" THEN
            DO:
               RETURN "NOK".
            END.   
            
    END.

    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.

    RUN efetua_saque IN h-b1wgen0025 ( INPUT aux_cdcooper,
                                       INPUT aux_nrdconta,
                                       INPUT aux_nrcartao,
                                       INPUT aux_vldsaque,
                                       INPUT crapdat.dtmvtocd,
                                       INPUT aux_nrsequni,
                                       INPUT aux_hrtransa,
                                       INPUT crapcop.cdcooper,
                                       INPUT craptfn.cdagenci,
                                       INPUT craptfn.nrterfin,
                                      OUTPUT aux_dscritic).

    DELETE PROCEDURE h-b1wgen0025.

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            IF TRIM(aux_dscritic) = "" THEN
               ASSIGN aux_dscritic = "Nao foi possivel efetuar o saque.".
               
            RETURN "NOK".
        END.

    /* ---------- */
    xDoc:CREATE-NODE(xField,"SAQUE","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    RETURN "OK".

END PROCEDURE.
/* Fim 21 - efetua_saque */





PROCEDURE confere_saque:

    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.

    RUN confere_saque IN h-b1wgen0025 ( INPUT crapcop.cdcooper, /* Coop do TAA */
                                        INPUT craptfn.cdagenci, /* PAC do TAA */
                                        INPUT craptfn.nrterfin, /* NRO do TAA */
                                        INPUT aux_cdcooper,
                                        INPUT aux_nrdconta,
                                        INPUT aux_nrcartao,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_nrsequni,
                                        INPUT aux_vldsaque,
                                       OUTPUT aux_dscritic).

    DELETE PROCEDURE h-b1wgen0025.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".      


    /* ---------- */
    xDoc:CREATE-NODE(xField,"ESTORNO","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    RETURN "OK".

END PROCEDURE.
/* Fim 22 - confere_saque */




PROCEDURE atualiza_saldo:

    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.

    RUN atualiza_saldo IN h-b1wgen0025 ( INPUT crapcop.cdcooper,
                                         INPUT craptfn.nrterfin,
                                         INPUT aux_qtnotaK7,
                                         INPUT aux_vlnotaK7[5],
                                        OUTPUT aux_dscritic).

    DELETE PROCEDURE h-b1wgen0025.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".


    /* ---------- */
    xDoc:CREATE-NODE(xField,"SALDO","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    RETURN "OK".
END PROCEDURE.
/* Fim 23 - atualiza_saldo */





PROCEDURE horario_deposito:

    DEFINE VARIABLE aux_flghorar    AS LOGICAL          NO-UNDO.
    
    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.

    RUN horario_deposito IN h-b1wgen0025 ( INPUT crapcop.cdcooper,
                                           INPUT craptfn.nrterfin,
                                          OUTPUT aux_flghorar,
                                          OUTPUT aux_dscritic).

    DELETE PROCEDURE h-b1wgen0025.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".


    /* ---------- */
    xDoc:CREATE-NODE(xField,"HRDEPOSITO","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_flghorar,"YES/NO").
    xField:APPEND-CHILD(xText).

    RETURN "OK".
END PROCEDURE.
/* Fim 24 - horario_deposito */








PROCEDURE verifica_titulo:

    DEFINE VARIABLE     aux_nmconban    AS CHAR             NO-UNDO. 
    DEFINE VARIABLE     aux_vlrdocum    AS DEC              NO-UNDO.
    DEFINE VARIABLE     aux_dtdifere    AS LOGICAL          NO-UNDO.
    DEFINE VARIABLE     aux_vldifere    AS LOGICAL          NO-UNDO.
    DEFINE VARIABLE     aux_nrctacob    AS INTE             NO-UNDO.
    DEFINE VARIABLE     aux_insittit    AS INTE             NO-UNDO.
    DEFINE VARIABLE     aux_intitcop    AS INTE             NO-UNDO.
    DEFINE VARIABLE     aux_nrcnvcob    AS DECI             NO-UNDO.
    DEFINE VARIABLE     aux_nrboleto    AS DECI             NO-UNDO.
    DEFINE VARIABLE     aux_nrdctabb    AS INTE             NO-UNDO.
    DEFINE VARIABLE     aux_dstrans1    AS CHAR             NO-UNDO.
    DEFINE VARIABLE     aux_idagenda    AS INTE             NO-UNDO.

    DEFINE VARIABLE     aux_dtultdia    AS DATE             NO-UNDO.

    DEFINE VARIABLE     aux_datavenc    AS DATE             NO-UNDO.

    DEFINE VARIABLE     aux_cdcritic    AS INTEGER          NO-UNDO.

    /* cobranca registrada */
    DEF VAR par_cobregis AS LOGICAL                  NO-UNDO.
    DEF VAR par_msgalert AS CHARACTER                NO-UNDO.
    DEF VAR par_vlrjuros AS DECIMAL                  NO-UNDO.
    DEF VAR par_vlrmulta AS DECIMAL                  NO-UNDO.
    DEF VAR par_vldescto AS DECIMAL                  NO-UNDO.
    DEF VAR par_vlabatim AS DECIMAL                  NO-UNDO.
    DEF VAR par_vloutdeb AS DECIMAL                  NO-UNDO.
    DEF VAR par_vloutcre AS DECIMAL                  NO-UNDO.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

	/* Efetuar a chamada a rotina Oracle */ 
	RUN STORED-PROCEDURE pc_valid_repre_legal_trans
		aux_handproc = PROC-HANDLE NO-ERROR (INPUT aux_cdcooper, /* Código da Cooperativa */
											 INPUT aux_nrdconta, /* Número da Conta */
											 INPUT 1,            /* Titular da Conta */
                                             INPUT 0,
											OUTPUT 0,            /* Código da crítica */
											OUTPUT "").          /* Descrição da crítica */
	
	/* Fechar o procedimento para buscarmos o resultado */ 
	CLOSE STORED-PROC pc_valid_repre_legal_trans
		   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
	
	{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
	
	/* Busca possíveis erros */ 
	ASSIGN aux_cdcritic = 0
		   aux_dscritic = ""
		   aux_cdcritic = pc_valid_repre_legal_trans.pr_cdcritic 
						  WHEN pc_valid_repre_legal_trans.pr_cdcritic <> ?
		   aux_dscritic = pc_valid_repre_legal_trans.pr_dscritic 
						  WHEN pc_valid_repre_legal_trans.pr_dscritic <> ?.

    IF aux_dscritic <> "" THEN
        RETURN "NOK".
      
    /** Não permite operações para o último dia útil do ano **/
    ASSIGN aux_dtultdia = DATE(12,31,YEAR(crapdat.dtmvtocd)).
    RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.

    RUN retorna-dia-util IN h-b1wgen0015 (INPUT aux_cdcooper,
                                          INPUT FALSE, /** Feriado  **/
                                          INPUT TRUE,  /** Anterior **/
                                          INPUT-OUTPUT aux_dtultdia).
    DELETE PROCEDURE h-b1wgen0015.

    /* valida se eh ultimo dia util do ano e nao deixa efetuar pagto */
    IF  aux_datpagto = aux_dtultdia THEN
        DO:
            aux_dscritic = "Pagamento não permitido para essa data.".
            RETURN "NOK".
        END.
        
    IF  aux_flagenda THEN
        aux_idagenda = 2.
    ELSE 
        aux_idagenda = 1.


    RUN sistema/generico/procedures/b1wgen0016.p PERSISTENT SET h-b1wgen0016.
            
    IF  VALID-HANDLE(h-b1wgen0016)  THEN    
        DO:
            
            RUN verifica_titulo IN h-b1wgen0016 
                                (INPUT        aux_cdcooper,
                                 INPUT        aux_nrdconta,
                                 INPUT        1,            /* titularidade */
                                 INPUT        aux_idagenda, /* agendamento  */
                                 INPUT-OUTPUT aux_cdbarra1,
                                 INPUT-OUTPUT aux_cdbarra2,
                                 INPUT-OUTPUT aux_cdbarra3,
                                 INPUT-OUTPUT aux_cdbarra4,
                                 INPUT-OUTPUT aux_cdbarra5,
                                 INPUT-OUTPUT aux_dscodbar,
                                 INPUT        aux_vldpagto,  /* valor do pagamento */
                                 INPUT        aux_datpagto,  /* data agendamento */
                                 INPUT        4,             /* origem TAA */
                                 INPUT        1, /* nao validar */
                                 INPUT aux_cdctrlcs, /* Numero controle consulta npc */   
                                       OUTPUT aux_nmconban,
                                       OUTPUT aux_vlrdocum,  /* valor do titulo */
                                       OUTPUT aux_dtdifere, 
                                       OUTPUT aux_vldifere, 
                                       OUTPUT aux_nrctacob,
                                       OUTPUT aux_insittit,
                                       OUTPUT aux_intitcop,
                                       OUTPUT aux_nrcnvcob,
                                       OUTPUT aux_nrboleto,
                                       OUTPUT aux_nrdctabb,
                                       OUTPUT aux_dstrans1,
                                       OUTPUT aux_dscritic,
                                       /* cob reg */
                                       OUTPUT par_cobregis,
                                       OUTPUT par_msgalert,
                                       OUTPUT par_vlrjuros,
                                       OUTPUT par_vlrmulta,
                                       OUTPUT par_vldescto,
                                       OUTPUT par_vlabatim,
                                       OUTPUT par_vloutdeb,
                                       OUTPUT par_vloutcre).
            
            DELETE PROCEDURE h-b1wgen0016.
        END.


    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".


   IF INT(SUBSTRING(aux_cdbarra5,1,4)) <> 0 THEN DO:

         RUN calcula_data_vencimento ( INPUT crapdat.dtmvtocd,
                                       INPUT INT(SUBSTRING(aux_cdbarra5,1,4)),
                                       OUTPUT aux_datavenc).         

   END.


    /* ---------- */
    xDoc:CREATE-NODE(xField,"NMDBANCO","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = aux_nmconban.
    xField:APPEND-CHILD(xText).


    /* ---------- */
    xDoc:CREATE-NODE(xField,"DSLINDIG","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(DEC(aux_cdbarra1),"99999,99999")   + " " +
                       STRING(DEC(aux_cdbarra2),"99999,999999")  + " " +
                       STRING(DEC(aux_cdbarra3),"99999,999999")  + " " + 
                       STRING(DEC(aux_cdbarra4),"9")             + " " + 
                       STRING(DEC(aux_cdbarra5),"99999999999999").

    xField:APPEND-CHILD(xText).


    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLRDOCUM","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_vlrdocum).
    xField:APPEND-CHILD(xText).


    /* ---------- */
    IF INT(SUBSTRING(aux_cdbarra5,1,4)) <> 0 THEN DO:

        xDoc:CREATE-NODE(xField,"DATAVENC","ELEMENT").
        xRoot:APPEND-CHILD(xField).
        
        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(aux_datavenc,"99/99/9999").
        xField:APPEND-CHILD(xText).

    END.


    RETURN "OK".
END PROCEDURE.
/* Fim 25 - verifica_titulo */






PROCEDURE paga_titulo:

    DEFINE VARIABLE     aux_nmconban    AS CHAR             NO-UNDO. 
    DEFINE VARIABLE     aux_vlrdocum    AS DEC              NO-UNDO.
    DEFINE VARIABLE     aux_dtdifere    AS LOGICAL          NO-UNDO.
    DEFINE VARIABLE     aux_vldifere    AS LOGICAL          NO-UNDO.
    DEFINE VARIABLE     aux_nrctacob    AS INTE             NO-UNDO.
    DEFINE VARIABLE     aux_insittit    AS INTE             NO-UNDO.
    DEFINE VARIABLE     aux_intitcop    AS INTE             NO-UNDO.
    DEFINE VARIABLE     aux_nrcnvcob    AS DECI             NO-UNDO.
    DEFINE VARIABLE     aux_nrboleto    AS DECI             NO-UNDO.
    DEFINE VARIABLE     aux_nrdctabb    AS INTE             NO-UNDO.
    DEFINE VARIABLE     aux_dstrans1    AS CHAR             NO-UNDO.
    DEFINE VARIABLE     aux_dsprotoc    AS CHAR             NO-UNDO.
    DEFINE VARIABLE     aux_cdbcoctl    AS CHAR             NO-UNDO.
    DEFINE VARIABLE     aux_cdagectl    AS CHAR             NO-UNDO.
    DEFINE VARIABLE     aux_cdcoptfn    AS INTE             NO-UNDO.
    DEFINE VARIABLE     aux_cdagetfn    AS INTE             NO-UNDO.
    DEFINE VARIABLE     aux_nrterfin    AS INTE             NO-UNDO.
    DEFINE VARIABLE     aux_idagenda    AS INTE             NO-UNDO.
    DEFINE VARIABLE     aux_dtultdia    AS DATE             NO-UNDO.
    DEFINE VARIABLE     aux_idastcjt    AS INT              NO-UNDO.
    DEFINE VARIABLE     aux_flcartma    AS INT              NO-UNDO.
    DEFINE VARIABLE     aux_nrcpfrep    AS DECI             NO-UNDO.
    DEFINE VARIABLE     aux_cdcritic    AS INT              NO-UNDO.
    DEFINE VARIABLE     aux_lindigit    AS CHAR             NO-UNDO.
    DEFINE VARIABLE     aux_msgofatr    AS CHAR             NO-UNDO.

    /* cobranca registrada */
    DEF VAR par_cobregis AS LOGICAL                  NO-UNDO.
    DEF VAR par_msgalert AS CHARACTER                NO-UNDO.
    DEF VAR par_vlrjuros AS DECIMAL                  NO-UNDO.
    DEF VAR par_vlrmulta AS DECIMAL                  NO-UNDO.
    DEF VAR par_vldescto AS DECIMAL                  NO-UNDO.
    DEF VAR par_vlabatim AS DECIMAL                  NO-UNDO.
    DEF VAR par_vloutdeb AS DECIMAL                  NO-UNDO.
    DEF VAR par_vloutcre AS DECIMAL                  NO-UNDO.

    ASSIGN aux_cdcoptfn = crapcop.cdcooper
           aux_cdagetfn = crapage.cdagenci
           aux_nrterfin = craptfn.nrterfin.

    IF  aux_flagenda THEN
        aux_idagenda = 2.
    ELSE 
        aux_idagenda = 1.

    RUN sistema/generico/procedures/b1wgen0016.p PERSISTENT SET h-b1wgen0016.
            
    IF  VALID-HANDLE(h-b1wgen0016)  THEN    
        DO:
            RUN verifica_titulo IN h-b1wgen0016 
                                (INPUT        aux_cdcooper,
                                 INPUT        aux_nrdconta,
                                 INPUT        1,            /* titularidade */
                                 INPUT        aux_idagenda, /* agendamento  */
                                 INPUT-OUTPUT aux_cdbarra1,
                                 INPUT-OUTPUT aux_cdbarra2,
                                 INPUT-OUTPUT aux_cdbarra3,
                                 INPUT-OUTPUT aux_cdbarra4,
                                 INPUT-OUTPUT aux_cdbarra5,
                                 INPUT-OUTPUT aux_dscodbar,
                                 INPUT        aux_vldpagto,  /* valor do pagamento */
                                 INPUT        aux_datpagto,  /* data agendamento */
                                 INPUT        4,             /* origem TAA */
                                 INPUT        1, /* nao validar */
                                 INPUT aux_cdctrlcs, /* Numero controle consulta npc */   
                                       OUTPUT aux_nmconban,
                                       OUTPUT aux_vlrdocum,  /* valor do titulo */
                                       OUTPUT aux_dtdifere, 
                                       OUTPUT aux_vldifere, 
                                       OUTPUT aux_nrctacob,
                                       OUTPUT aux_insittit,
                                       OUTPUT aux_intitcop,
                                       OUTPUT aux_nrcnvcob,
                                       OUTPUT aux_nrboleto,
                                       OUTPUT aux_nrdctabb,
                                       OUTPUT aux_dstrans1,
                                       OUTPUT aux_dscritic,
                                       /* cob reg */
                                       OUTPUT par_cobregis,
                                       OUTPUT par_msgalert,
                                       OUTPUT par_vlrjuros,
                                       OUTPUT par_vlrmulta,
                                       OUTPUT par_vldescto,
                                       OUTPUT par_vlabatim,
                                       OUTPUT par_vloutdeb,
                                       OUTPUT par_vloutcre).

            IF  RETURN-VALUE = "OK"  THEN
                DO:
                    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    
        
                    RUN STORED-PROCEDURE pc_verifica_rep_assinatura
                        aux_handproc = PROC-HANDLE NO-ERROR
                                                (INPUT aux_cdcooper, /* Cooperativa */
                                                 INPUT aux_nrdconta, /* Nr. da conta */
                                                 INPUT 1,   /* Sequencia de titular */
                                                 INPUT 4,   /* Origem - TAA */
                                                 OUTPUT 0,  /* Codigo 1 exige Ass. Conj. */
                                                 OUTPUT 0,  /* CPF do Rep. Legal */
                                                 OUTPUT "", /* Nome do Rep. Legal */
                                                 OUTPUT 0,  /* Cartao Magnetico conjunta, 0 nao, 1 sim */
                                                 OUTPUT 0,  /* Codigo do erro */
                                                 OUTPUT ""). /* Descricao do erro */
                    
                    CLOSE STORED-PROC pc_verifica_rep_assinatura
                          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                    
                    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
                    
                    ASSIGN aux_idastcjt = 0
                           aux_cdcritic = 0
                           aux_dscritic = ""           
                           aux_flcartma = 0
                           aux_nrcpfrep = 0
                           aux_idastcjt = pc_verifica_rep_assinatura.pr_idastcjt
                                              WHEN pc_verifica_rep_assinatura.pr_idastcjt <> ?
                           aux_flcartma = pc_verifica_rep_assinatura.pr_flcartma
                                              WHEN pc_verifica_rep_assinatura.pr_flcartma <> ?
                           aux_nrcpfrep = pc_verifica_rep_assinatura.pr_nrcpfcgc
                                              WHEN pc_verifica_rep_assinatura.pr_nrcpfcgc <> ?
                           aux_cdcritic = pc_verifica_rep_assinatura.pr_cdcritic
                                              WHEN pc_verifica_rep_assinatura.pr_cdcritic <> ?
                           aux_dscritic = pc_verifica_rep_assinatura.pr_dscritic
                                              WHEN pc_verifica_rep_assinatura.pr_dscritic <> ?.           
                    
                    IF  aux_cdcritic <> 0   OR
                        aux_dscritic <> ""  THEN
                        DO:
                            IF  aux_dscritic = "" THEN
                               ASSIGN aux_dscritic =  "Nao foi possivel verificar assinatura conjunta.".
                    
                            RETURN "NOK".
                        END.
                    
                    
                    IF  aux_idastcjt = 0 THEN
                        DO:                    
                            IF  NOT aux_flagenda THEN
                                DO:
                                    RUN paga_titulo IN h-b1wgen0016 
                                                    (INPUT aux_cdcooper,
                                                     INPUT aux_nrdconta,
                                                     INPUT 1,            /* titularidade */
                                                     INPUT aux_cdbarra1,
                                                     INPUT aux_cdbarra2,
                                                     INPUT aux_cdbarra3,
                                                     INPUT aux_cdbarra4,
                                                     INPUT aux_cdbarra5,
                                                     INPUT aux_dscodbar,
                                                     INPUT "Pagto TAA",
                                                     INPUT aux_vldpagto, /* valor do pagamento */
                                                     INPUT aux_vlrdocum, /* valor do titulo */
                                                     INPUT aux_nrctacob,    
                                                     INPUT aux_insittit,
                                                     INPUT aux_intitcop,
                                                     INPUT aux_nrcnvcob,
                                                     INPUT aux_nrboleto,
                                                     INPUT aux_nrdctabb,
                                                     INPUT 0,            /* Titulo DDA */ 
                                                     INPUT aux_flagenda, /* flag agendamento */
                                                     INPUT 4,            /* origem TAA */
                                                     INPUT aux_cdcoptfn,
                                                     INPUT aux_cdagetfn,
                                                     INPUT aux_nrterfin,
                                                     INPUT par_vlrjuros, 
                                                     INPUT par_vlrmulta, 
                                                     INPUT par_vldescto, 
                                                     INPUT par_vlabatim, 
                                                     INPUT par_vloutdeb, 
                                                     INPUT par_vloutcre,
                                                     INPUT 0,
                                                     INPUT aux_tpcptdoc,
                                                     INPUT aux_cdctrlcs, /* Numero controle consulta npc */   
                                                     INPUT 0,  /* par_flmobile */
                                                     INPUT '', /* par_iptransa */
                                                     INPUT '', /* par_iddispos */
                                                    OUTPUT aux_dstrans1,
                                                    OUTPUT aux_dscritic,
                                                    OUTPUT aux_dsprotoc,
                                                    OUTPUT aux_cdbcoctl,
                                                    OUTPUT aux_cdagectl).
                                END.
                            ELSE
                                DO:
                                
                                  { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

                                  RUN STORED-PROCEDURE pc_cadastrar_agendamento
                                      aux_handproc = PROC-HANDLE NO-ERROR
                                                  (INPUT aux_cdcooper,     
                                                    INPUT 91,           /* par_cdagenci */
                                                    INPUT 900,          /* par_nrdcaixa */
                                                    INPUT "996",        /* par_cdoperad */
                                                   INPUT aux_nrdconta,                   
                                                    INPUT 1,            /* par_idseqttl */
                                                   INPUT crapdat.dtmvtocd,                        
                                                   /* Projeto 363 - Novo ATM */
                                                   INPUT 4,            /* par_cdorigem */
                                                    INPUT "TAA",        /* par_dsorigem */
                                                   INPUT "TAA",        /* par_nmdatela */
                                                    INPUT 2,            /* par_cdtiptra */
                                                    INPUT 2,            /* par_idtpdpag */
                                                    INPUT aux_nmconban, /* par_dscedent */
                                                    INPUT aux_dscodbar,           /* par_dscodbar */
                                                    INPUT deci(aux_cdbarra1), /* par_lindigi1 */
                                                    INPUT deci(aux_cdbarra2), /* par_lindigi2 */
                                                    INPUT deci(aux_cdbarra3), /* par_lindigi3 */
                                                    INPUT deci(aux_cdbarra4), /* par_lindigi4 */
                                                    INPUT deci(aux_cdbarra5), /* par_lindigi5 */
                                                    INPUT 856,          /* aux_cdhisdeb */
                                                   INPUT aux_datpagto,                      
                                                   INPUT aux_vldpagto,                      
                                                    INPUT aux_dtvencto, /* Data de vencimento */
                                                   INPUT 0, /* cddbanco */
                                                   INPUT 0, /* cdageban */
                                                   INPUT 0,             /* Conta destino */                        
                                                   INPUT aux_cdcoptfn,
                                                   INPUT aux_cdagetfn,
                                                   INPUT aux_nrterfin,
                                                    INPUT 0,            /* par_nrcpfope */
                                                    INPUT "0",          /* par_idtitdda */
                                                    INPUT 0,            /* par_cdtrapen */
                                                   INPUT 0,
                                                   INPUT 0,
                                                   INPUT 0,
                                                   INPUT 0,   /* cdfinali */
                                                   INPUT ' ', /* dstransf */
                                                   INPUT ' ', /* dshistor */
                                                   INPUT "",   /* pr_iptransa */
                                                   INPUT aux_cdctrlcs, /* Numero controle consulta npc */   
                                                   INPUT '', /* pr_iddispos */
                                                   INPUT 0,  /* pr_nrridlfp */
                                                   
                                                  OUTPUT 0,
                                                   OUTPUT "",  /* pr_dstransa */
                                                   OUTPUT "",
                                                   OUTPUT 0,
                                                   OUTPUT "",                         
                                                   OUTPUT "").    /* pr_dscritic */
                                                                                         
                                  CLOSE STORED-PROC pc_cadastrar_agendamento
                                        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                                  
                                  { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
                                                                                         
                                  ASSIGN aux_dstrans1 = pc_cadastrar_agendamento.pr_dstransa
                                                   WHEN pc_cadastrar_agendamento.pr_dstransa <> ?
                                         aux_dscritic = pc_cadastrar_agendamento.pr_dscritic
                                                   WHEN pc_cadastrar_agendamento.pr_dscritic <> ?
                                         aux_msgofatr = pc_cadastrar_agendamento.pr_msgofatr
                                                   WHEN pc_cadastrar_agendamento.pr_msgofatr <> ?
                                         aux_cdempcon = INT(pc_cadastrar_agendamento.pr_cdempcon)
                                                   WHEN pc_cadastrar_agendamento.pr_cdempcon <> ?
                                         aux_cdsegmto = INT(pc_cadastrar_agendamento.pr_cdsegmto)
                                                   WHEN pc_cadastrar_agendamento.pr_cdsegmto <> ?.                                                                                         
                                END.                                                     
                        END.
                    ELSE                                                                     
                        DO:
                            ASSIGN aux_lindigit = STRING(DEC(aux_cdbarra1),"99999,99999")   + " " +
                                                  STRING(DEC(aux_cdbarra2),"99999,999999")  + " " +
                                                  STRING(DEC(aux_cdbarra3),"99999,999999")  + " " + 
                                                  STRING(DEC(aux_cdbarra4),"9")             + " " + 
                                                  STRING(DEC(aux_cdbarra5),"99999999999999").  /* Linha digitavel */
        
                            { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    
        
                            RUN STORED-PROCEDURE pc_cria_trans_pend_pagto
                             aux_handproc = PROC-HANDLE NO-ERROR
                                                     (INPUT 91,           /* Codigo do PA */
                                                      INPUT 900,          /* Numero do caixa */
                                                      INPUT "996",        /* Operador */
                                                      INPUT "TAA",        /* Nome da tela */
                                                      INPUT 4,            /* Id origem */
                                                      INPUT 1,            /* Titular */
                                                      INPUT IF aux_flcartma = 1 THEN 0 ELSE aux_nrcpfrep, /* CPF do operador juridico */
                                                      INPUT IF aux_flcartma = 1 THEN aux_nrcpfrep ELSE 0, /* CPF do representante legal */
                                                      INPUT crapcop.cdcooper, /* Cooperativa do terminal */
                                                      INPUT crapage.cdagenci, /* Agencia do terminal */
                                                      INPUT craptfn.nrterfin, /* Numero do terminal */
                                                      INPUT crapdat.dtmvtocd, /* Data de movimento */
                                                      INPUT aux_cdcooper, /* Cooperativa */
                                                      INPUT aux_nrdconta, /* Nr. da conta */
                                                      INPUT 2,             /* Titulo */                                
                                                      INPUT aux_vldpagto, /* Valor do pagamento */
                                                      INPUT aux_datpagto, /* Data do pagamento */
                                                      INPUT aux_idagenda, /* Indica se o pagamento foi agendado (1 – Online / 2 – Agendamento) */
                                                      INPUT "Pagto TAA",  /* Cedente */
                                                      INPUT aux_dscodbar, /* Descricao do codigo de barras */
                                                      INPUT aux_lindigit, /* Linha digitavel */
                                                      INPUT aux_vlrdocum, /* Valor documento */
                                                      INPUT aux_dtvencto, /* Data de vencimento */
                                                      INPUT aux_tpcptdoc, /* Tipo de captura do documento */
                                                      INPUT 0,            /* Identificador do titulo no DDA */
                                                      INPUT aux_idastcjt, /* Indicador de assinatura conjunta */
                                                      INPUT aux_cdctrlcs, /* Numero controle consulta npc */   
                                                      OUTPUT 0,  /* Codigo do erro */
                                                      OUTPUT ""). /* Descricao do erro */
                    
                            CLOSE STORED-PROC pc_cria_trans_pend_pagto
                               aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                    
                            { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
                    
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = ""           
                                   aux_cdcritic = pc_cria_trans_pend_pagto.pr_cdcritic 
                                                      WHEN pc_cria_trans_pend_pagto.pr_cdcritic <> ?
                                   aux_dscritic = pc_cria_trans_pend_pagto.pr_dscritic
                                                      WHEN pc_cria_trans_pend_pagto.pr_dscritic <> ?.           
                    
                            IF  aux_cdcritic <> 0   OR
                                aux_dscritic <> ""  THEN
                                DO:
                                    IF  aux_dscritic = "" THEN
                                       ASSIGN aux_dscritic =  "Nao foi possivel efetuar pagamento de titulo.".
                    
                                    RETURN "NOK".
                                END.                
        
                        END.
                END.
            DELETE PROCEDURE h-b1wgen0016.                              
        END.


    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".



    /* ---------- */
    xDoc:CREATE-NODE(xField,"PAGAMENTO","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"IDASTCJT","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_idastcjt).
    xField:APPEND-CHILD(xText).

    IF  NOT aux_flagenda THEN
        DO:
            /* ---------- */
            IF  aux_dsprotoc <> ""  THEN
                DO:
                    xDoc:CREATE-NODE(xField,"PROTOCOLO","ELEMENT").
                    xRoot:APPEND-CHILD(xField).
                    
                    xDoc:CREATE-NODE(xText,"","TEXT").
                    xText:NODE-VALUE = aux_dsprotoc.
                    xField:APPEND-CHILD(xText).
                END.
            /* ---------- */

            /* ---------- */
            IF  aux_cdbcoctl <> ""  THEN
                DO:
                    xDoc:CREATE-NODE(xField,"CDBCOCTL","ELEMENT").
                    xRoot:APPEND-CHILD(xField).
                    
                    xDoc:CREATE-NODE(xText,"","TEXT").
                    xText:NODE-VALUE = aux_cdbcoctl.
                    xField:APPEND-CHILD(xText).
                END.
            /* ---------- */

            /* ---------- */
            IF  aux_cdagectl <> ""  THEN
                DO:
                    xDoc:CREATE-NODE(xField,"CDAGECTL","ELEMENT").
                    xRoot:APPEND-CHILD(xField).
        
                    xDoc:CREATE-NODE(xText,"","TEXT").
                    xText:NODE-VALUE = aux_cdagectl.
                    xField:APPEND-CHILD(xText).
                END.
            /* ---------- */
        END.
    


    RETURN "OK".
END PROCEDURE.
/* Fim 26 - paga_titulo */



PROCEDURE horario_pagamento:

    DEFINE VARIABLE aux_hrinipag    AS INT              NO-UNDO.
    DEFINE VARIABLE aux_hrfimpag    AS INT              NO-UNDO.
    

    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.

    RUN horario_pagamento IN h-b1wgen0025 ( INPUT crapcop.cdcooper,
                                            INPUT craptfn.nrterfin,
                                           OUTPUT aux_hrinipag,
                                           OUTPUT aux_hrfimpag,
                                           OUTPUT aux_dscritic).

    DELETE PROCEDURE h-b1wgen0025.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".


    /* ---------- */
    xDoc:CREATE-NODE(xField,"HRINIPAG","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_hrinipag).
    xField:APPEND-CHILD(xText).

    
    /* ---------- */
    xDoc:CREATE-NODE(xField,"HRFIMPAG","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_hrfimpag).
    xField:APPEND-CHILD(xText).


    /* ---------- */
    xDoc:CREATE-NODE(xField,"HRSERVID","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(TIME).
    xField:APPEND-CHILD(xText).
    
    
    RETURN "OK".
END PROCEDURE.
/* Fim 27 - horario_pagamento */




PROCEDURE verifica_convenio:

    DEFINE VARIABLE     aux_dtvencto    AS DATE             NO-UNDO.
    DEFINE VARIABLE     aux_nmconven    AS CHAR             NO-UNDO.
    DEFINE VARIABLE     aux_cdseqfat    AS DEC              NO-UNDO.
    DEFINE VARIABLE     aux_vlfatura    AS DEC              NO-UNDO.
    DEFINE VARIABLE     aux_nrdigfat    AS INT              NO-UNDO.
    DEFINE VARIABLE     aux_indvalid    AS INT              NO-UNDO.
    DEFINE VARIABLE     aux_dstransa    AS CHAR             NO-UNDO.
    DEFINE VARIABLE     aux_idagenda    AS INT              NO-UNDO.

    DEFINE VARIABLE     aux_dtultdia    AS DATE             NO-UNDO.

    DEFINE VARIABLE     aux_cdcritic    AS INTEGER          NO-UNDO.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

	/* Efetuar a chamada a rotina Oracle */ 
	RUN STORED-PROCEDURE pc_valid_repre_legal_trans
		aux_handproc = PROC-HANDLE NO-ERROR (INPUT aux_cdcooper, /* Código da Cooperativa */
											 INPUT aux_nrdconta, /* Número da Conta */
											 INPUT 1,            /* Titular da Conta */
                                             INPUT 0,
											OUTPUT 0,            /* Código da crítica */
											OUTPUT "").          /* Descrição da crítica */
	
	/* Fechar o procedimento para buscarmos o resultado */ 
	CLOSE STORED-PROC pc_valid_repre_legal_trans
		   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
	
	{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
	
	/* Busca possíveis erros */ 
	ASSIGN aux_cdcritic = 0
		   aux_dscritic = ""
		   aux_cdcritic = pc_valid_repre_legal_trans.pr_cdcritic 
						  WHEN pc_valid_repre_legal_trans.pr_cdcritic <> ?
		   aux_dscritic = pc_valid_repre_legal_trans.pr_dscritic 
						  WHEN pc_valid_repre_legal_trans.pr_dscritic <> ?.
    
    IF aux_dscritic <> "" THEN
        RETURN "NOK".

    /** Não permite operações para o último dia útil do ano **/
    ASSIGN aux_dtultdia = DATE(12,31,YEAR(crapdat.dtmvtocd)).
    RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.

    RUN retorna-dia-util IN h-b1wgen0015 (INPUT aux_cdcooper,
                                          INPUT FALSE, /** Feriado  **/
                                          INPUT TRUE,  /** Anterior **/
                                          INPUT-OUTPUT aux_dtultdia).
    DELETE PROCEDURE h-b1wgen0015.

    /* valida se eh ultimo dia util do ano e nao deixa efetuar pagto */
    IF  aux_datpagto = aux_dtultdia THEN
        DO:
            aux_dscritic = "Pagamento não permitido para essa data.".
            RETURN "NOK".
        END.

    IF  aux_flagenda THEN
        aux_idagenda = 2.
    ELSE
        aux_idagenda = 1.




    IF  aux_flgdbaut THEN
        ASSIGN aux_indvalid = 3.
    ELSE
        ASSIGN aux_indvalid = 1.  /* nao validar */

    RUN sistema/generico/procedures/b1wgen0016.p PERSISTENT SET h-b1wgen0016.
            
    IF  VALID-HANDLE(h-b1wgen0016)  THEN    
        DO:
            RUN verifica_convenio IN h-b1wgen0016 
                                (INPUT        aux_cdcooper,
                                 INPUT        aux_nrdconta,
                                 INPUT        1,             /* titularidade */
                                 INPUT        aux_idagenda,  /* agendamento */
                                 INPUT-OUTPUT aux_cdbarra1,
                                 INPUT-OUTPUT aux_cdbarra2,
                                 INPUT-OUTPUT aux_cdbarra3,
                                 INPUT-OUTPUT aux_cdbarra4,
                                 INPUT-OUTPUT aux_dscodbar,
                                 INPUT-OUTPUT aux_dtvencto,  /* vencimento */
                                 INPUT-OUTPUT aux_vldpagto,  /* valor do pagamento */
                                 INPUT        aux_datpagto,  /* data agendamento */
                                 INPUT        4,             /* origem TAA */
                                 INPUT        aux_indvalid,
                                       OUTPUT aux_nmconven,
                                       OUTPUT aux_cdseqfat,
                                       OUTPUT aux_vlfatura, 
                                       OUTPUT aux_nrdigfat, 
                                       OUTPUT aux_dstransa,
                                       OUTPUT aux_dscritic).

            DELETE PROCEDURE h-b1wgen0016.
        END.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".

    IF  aux_flgdbaut THEN
        RETURN "OK".


    /* ---------- */
    xDoc:CREATE-NODE(xField,"NMCONVEN","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = aux_nmconven.
    xField:APPEND-CHILD(xText).


    /* ---------- */
    xDoc:CREATE-NODE(xField,"DSLINDIG","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(DEC(aux_cdbarra1),"99999999999,9") + " " +
                       STRING(DEC(aux_cdbarra2),"99999999999,9") + " " +
                       STRING(DEC(aux_cdbarra3),"99999999999,9") + " " + 
                       STRING(DEC(aux_cdbarra4),"99999999999,9").
    xField:APPEND-CHILD(xText).

    RETURN "OK".
END PROCEDURE.
/* Fim 28 - verifica_convenio */



PROCEDURE paga_convenio:
                                           
    DEFINE VARIABLE     aux_dtvencto    AS DATE             NO-UNDO.
    DEFINE VARIABLE     aux_nmconven    AS CHAR             NO-UNDO.
    DEFINE VARIABLE     aux_cdseqfat    AS DEC              NO-UNDO.
    DEFINE VARIABLE     aux_vlfatura    AS DEC              NO-UNDO.
    DEFINE VARIABLE     aux_nrdigfat    AS INT              NO-UNDO.
    DEFINE VARIABLE     aux_dstransa    AS CHAR             NO-UNDO.
    DEFINE VARIABLE     aux_dsprotoc    AS CHAR             NO-UNDO.
    DEFINE VARIABLE     aux_cdbcoctl    AS CHAR             NO-UNDO.
    DEFINE VARIABLE     aux_cdagectl    AS CHAR             NO-UNDO.
    DEFINE VARIABLE     aux_cdcoptfn    AS INTE             NO-UNDO.
    DEFINE VARIABLE     aux_cdagetfn    AS INTE             NO-UNDO.
    DEFINE VARIABLE     aux_nrterfin    AS INTE             NO-UNDO.
    DEFINE VARIABLE     aux_idagenda    AS INT              NO-UNDO.
    DEFINE VARIABLE     aux_dtultdia    AS DATE             NO-UNDO.
    DEFINE VARIABLE     aux_idastcjt    AS INT              NO-UNDO.
    DEFINE VARIABLE     aux_flcartma    AS INT              NO-UNDO.
    DEFINE VARIABLE     aux_nrcpfrep    AS DECI             NO-UNDO.
    DEFINE VARIABLE     aux_cdcritic    AS INT              NO-UNDO.
    DEFINE VARIABLE     aux_lindigit    AS CHAR             NO-UNDO.

    DEFINE VARIABLE     aux_msgofatr    AS CHAR             NO-UNDO.
    
    ASSIGN aux_cdcoptfn = crapcop.cdcooper
           aux_cdagetfn = crapage.cdagenci
           aux_nrterfin = craptfn.nrterfin.

    RUN sistema/generico/procedures/b1wgen0016.p PERSISTENT SET h-b1wgen0016.
            
    IF aux_flagenda THEN
        aux_idagenda = 2.
    ELSE
        aux_idagenda = 1.
    
    IF  VALID-HANDLE(h-b1wgen0016)  THEN    
        DO:
            RUN verifica_convenio IN h-b1wgen0016 
                                (INPUT        aux_cdcooper,
                                 INPUT        aux_nrdconta,
                                 INPUT        1,            /* titularidade */
                                 INPUT        aux_idagenda, /* agendamento  */
                                 INPUT-OUTPUT aux_cdbarra1,
                                 INPUT-OUTPUT aux_cdbarra2,
                                 INPUT-OUTPUT aux_cdbarra3,
                                 INPUT-OUTPUT aux_cdbarra4,
                                 INPUT-OUTPUT aux_dscodbar,
                                 INPUT-OUTPUT aux_dtvencto,  /* vencimento */
                                 INPUT-OUTPUT aux_vldpagto,  /* valor do pagamento */
                                 INPUT        aux_datpagto,  /* data agendamento */
                                 INPUT        4,             /* origem TAA */
                                 INPUT        1, /* nao validar */
                                       OUTPUT aux_nmconven,
                                       OUTPUT aux_cdseqfat,
                                       OUTPUT aux_vlfatura, 
                                       OUTPUT aux_nrdigfat, 
                                       OUTPUT aux_dstransa,
                                       OUTPUT aux_dscritic).


            IF  RETURN-VALUE = "OK"  THEN
                DO:
                    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    
    
                    RUN STORED-PROCEDURE pc_verifica_rep_assinatura
                        aux_handproc = PROC-HANDLE NO-ERROR
                                                (INPUT aux_cdcooper, /* Cooperativa */
                                                 INPUT aux_nrdconta, /* Nr. da conta */
                                                 INPUT 1,   /* Sequencia de titular */
                                                 INPUT 4,   /* Origem - TAA */
                                                 OUTPUT 0,  /* Codigo 1 exige Ass. Conj. */
                                                 OUTPUT 0,  /* CPF do Rep. Legal */
                                                 OUTPUT "", /* Nome do Rep. Legal */
                                                 OUTPUT 0,  /* Cartao Magnetico conjunta, 0 nao, 1 sim */
                                                 OUTPUT 0,  /* Codigo do erro */
                                                 OUTPUT ""). /* Descricao do erro */
                    
                    CLOSE STORED-PROC pc_verifica_rep_assinatura
                          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                    
                    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
                    
                    ASSIGN aux_idastcjt = 0
                           aux_cdcritic = 0
                           aux_dscritic = ""           
                           aux_flcartma = 0
                           aux_nrcpfrep = 0
                           aux_idastcjt = pc_verifica_rep_assinatura.pr_idastcjt
                                              WHEN pc_verifica_rep_assinatura.pr_idastcjt <> ?
                           aux_flcartma = pc_verifica_rep_assinatura.pr_flcartma
                                              WHEN pc_verifica_rep_assinatura.pr_flcartma <> ?
                           aux_nrcpfrep = pc_verifica_rep_assinatura.pr_nrcpfcgc
                                              WHEN pc_verifica_rep_assinatura.pr_nrcpfcgc <> ?
                           aux_cdcritic = pc_verifica_rep_assinatura.pr_cdcritic
                                              WHEN pc_verifica_rep_assinatura.pr_cdcritic <> ?
                           aux_dscritic = pc_verifica_rep_assinatura.pr_dscritic
                                              WHEN pc_verifica_rep_assinatura.pr_dscritic <> ?.           
                    
                    IF  aux_cdcritic <> 0   OR
                        aux_dscritic <> ""  THEN
                        DO:
                            IF  aux_dscritic = "" THEN
                               ASSIGN aux_dscritic =  "Nao foi possivel verificar assinatura conjunta.".
                    
                            RETURN "NOK".
                        END.
    
    
                    IF  aux_idastcjt = 0 THEN
                        DO:
                            IF  NOT aux_flagenda THEN
                                DO:
                                    RUN paga_convenio IN h-b1wgen0016
                                                    ( INPUT aux_cdcooper,
                                                      INPUT aux_nrdconta,
                                                      INPUT 1, /* titularidade */
                                                      INPUT aux_dscodbar,
                                                      INPUT "",
                                                      INPUT aux_cdseqfat,
                                                      INPUT aux_vldpagto,
                                                      INPUT aux_nrdigfat,
                                                      INPUT NO, /* nao agendar */
                                                      INPUT 4,  /* origem TAA */
                                                      INPUT aux_cdcoptfn,
                                                      INPUT aux_cdagetfn,
                                                      INPUT aux_nrterfin,
                                                      INPUT 0, /* nrcpfope */
                                                      INPUT aux_tpcptdoc,
                                                      INPUT 0,  /* par_flmobile */
                                                      INPUT '', /* par_iptransa */
                                                      INPUT '', /* par_iddispos */                                                     
                                                     OUTPUT aux_dstransa,
                                                     OUTPUT aux_dscritic,
                                                     OUTPUT aux_dsprotoc,
                                                     OUTPUT aux_cdbcoctl,
                                                     OUTPUT aux_cdagectl,
                                                     OUTPUT aux_msgofatr,
                                                     OUTPUT aux_cdempcon,
                                                     OUTPUT aux_cdsegmto).
                                END.
                            ELSE
                                DO:
                                  
                                  { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

                                  RUN STORED-PROCEDURE pc_cadastrar_agendamento
                                      aux_handproc = PROC-HANDLE NO-ERROR
                                                 (INPUT aux_cdcooper,     
                                                  INPUT 91,           /* par_cdagenci */
                                                  INPUT 900,          /* par_nrdcaixa */
                                                  INPUT "996",        /* par_cdoperad */
                                                  INPUT aux_nrdconta,                   
                                                  INPUT 1,            /* par_idseqttl */
                                                  INPUT crapdat.dtmvtocd,                        
                                                  /* Projeto 363 - Novo ATM */
                                                  INPUT 4,            /* par_cdorigem */
                                                  INPUT "TAA",        /* par_dsorigem */
                                                  INPUT "TAA",        /* par_nmdatela */
                                                  INPUT 2,            /* par_cdtiptra */
                                                  INPUT 1,            /* par_idtpdpag */
                                                  INPUT aux_nmconven, /* par_dscedent */
                                                  INPUT aux_dscodbar, /* par_dscodbar */
                                                  INPUT deci(aux_cdbarra1), /* par_lindigi1 */
                                                  INPUT deci(aux_cdbarra2), /* par_lindigi2 */
                                                  INPUT deci(aux_cdbarra3), /* par_lindigi3 */
                                                  INPUT deci(aux_cdbarra4), /* par_lindigi4 */
                                                  INPUT deci(aux_cdbarra5), /* par_lindigi5 */
                                                  INPUT 856,
                                                  INPUT aux_datpagto,                      
                                                  INPUT aux_vldpagto,                      
                                                  INPUT aux_dtvencto, /* Data de vencimento */
                                                  INPUT 0,            /* aux_cddbanco */
                                                  INPUT 0,            /* aux_cdagetra */
                                                  INPUT 0,            /* aux_nrtransf */
                                                  INPUT aux_cdcoptfn,
                                                  INPUT aux_cdagetfn,
                                                  INPUT aux_nrterfin,
                                                  INPUT 0,            /* par_nrcpfope */
                                                  INPUT "0",          /* par_idtitdda */
                                                  INPUT 0,            /* par_cdtrapen */
                                                  INPUT 0,
                                                  INPUT 0,
                                                  INPUT 0,
                                                  INPUT 0,   /* cdfinali */
                                                  INPUT ' ', /* dstransf */
                                                  INPUT ' ', /* dshistor */
                                                  INPUT '',  /* pr_iptransa */
                                                  INPUT '',  /* Numero controle consulta npc */   
                                                  INPUT '', /* par_iddispos */
                                                  INPUT 0,  /* pr_nrridlfp */
                                                  
                                                 OUTPUT 0, 
                                                 OUTPUT "",  /* pr_dstransa */
                                                 OUTPUT "",
                                                 OUTPUT 0,
                                                 OUTPUT "",                         
                                                 OUTPUT "").   /* pr_dscritic */
            
                                  CLOSE STORED-PROC pc_cadastrar_agendamento
                                        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
            
                                  { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
            
                                  ASSIGN aux_dstransa = pc_cadastrar_agendamento.pr_dstransa
                                                   WHEN pc_cadastrar_agendamento.pr_dstransa <> ?                        
                                         aux_dscritic = pc_cadastrar_agendamento.pr_dscritic
                                                   WHEN pc_cadastrar_agendamento.pr_dscritic <> ?
                                         aux_msgofatr = pc_cadastrar_agendamento.pr_msgofatr
                                                   WHEN pc_cadastrar_agendamento.pr_msgofatr <> ?
                                         aux_cdempcon = INT(pc_cadastrar_agendamento.pr_cdempcon)
                                                   WHEN pc_cadastrar_agendamento.pr_cdempcon <> ?
                                         aux_cdsegmto = INT(pc_cadastrar_agendamento.pr_cdsegmto)
                                                   WHEN pc_cadastrar_agendamento.pr_cdsegmto <> ?.                                                   
                                END.
                        END.
                    ELSE
                        DO:
                            ASSIGN aux_lindigit = STRING(DEC(aux_cdbarra1),"99999999999,9") + " " +
                                                  STRING(DEC(aux_cdbarra2),"99999999999,9") + " " +
                                                  STRING(DEC(aux_cdbarra3),"99999999999,9") + " " + 
                                                  STRING(DEC(aux_cdbarra4),"99999999999,9").  /* Linha digitavel */

                            { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    
        
                             RUN STORED-PROCEDURE pc_cria_trans_pend_pagto
                              aux_handproc = PROC-HANDLE NO-ERROR
                                                      (INPUT 91,           /* Codigo do PA */
                                                       INPUT 900,          /* Numero do caixa */
                                                       INPUT "996",        /* Operador */
                                                       INPUT "TAA",        /* Nome da tela */
                                                       INPUT 4,            /* Id origem */
                                                       INPUT 1,            /* Titular */
                                                       INPUT IF aux_flcartma = 1 THEN 0 ELSE aux_nrcpfrep, /* CPF do operador juridico */
                                                       INPUT IF aux_flcartma = 1 THEN aux_nrcpfrep ELSE 0, /* CPF do representante legal */
                                                       INPUT crapcop.cdcooper, /* Cooperativa do terminal */
                                                       INPUT crapage.cdagenci, /* Agencia do terminal */
                                                       INPUT craptfn.nrterfin, /* Numero do terminal */
                                                       INPUT crapdat.dtmvtocd, /* Data de movimento */
                                                       INPUT aux_cdcooper, /* Cooperativa */
                                                       INPUT aux_nrdconta, /* Nr. da conta */
                                                       INPUT 1,             /* Convenio */                                
                                                       INPUT aux_vldpagto, /* Valor do pagamento */
                                                       INPUT aux_datpagto, /* Data do pagamento */
                                                       INPUT aux_idagenda, /* Indica se o pagamento foi agendado (1 – Online / 2 – Agendamento) */
                                                       INPUT aux_nmconven, /* Cedente */
                                                       INPUT aux_dscodbar, /* Descricao do codigo de barras */
                                                       INPUT aux_lindigit, /* Linha digitavel */
                                                       INPUT aux_vlfatura, /* Valor documento */
                                                       INPUT aux_dtvencto, /* Data de vencimento */
                                                       INPUT aux_tpcptdoc, /* Tipo de captura do documento */
                                                       INPUT 0,            /* Identificador do titulo no DDA */
                                                       INPUT aux_idastcjt, /* Indicador de assinatura conjunta */
                                                       INPUT "",           /* Numero controle consulta npc */   
                                                       OUTPUT 0,  /* Codigo do erro */
                                                       OUTPUT ""). /* Descricao do erro */
                    
                             CLOSE STORED-PROC pc_cria_trans_pend_pagto
                                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                    
                             { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
                    
                             ASSIGN aux_cdcritic = 0
                                    aux_dscritic = ""           
                                    aux_cdcritic = pc_cria_trans_pend_pagto.pr_cdcritic 
                                                       WHEN pc_cria_trans_pend_pagto.pr_cdcritic <> ?
                                    aux_dscritic = pc_cria_trans_pend_pagto.pr_dscritic
                                                       WHEN pc_cria_trans_pend_pagto.pr_dscritic <> ?.           
                    
                             IF  aux_cdcritic <> 0   OR
                                 aux_dscritic <> ""  THEN
                                 DO:
                                     IF  aux_dscritic = "" THEN
                                        ASSIGN aux_dscritic =  "Nao foi possivel efetuar pagamento de convenio.".
                    
                                     RETURN "NOK".
                                 END.                
                        END.
                END.
            DELETE PROCEDURE h-b1wgen0016.
        END.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".

    /* ---------- */
    xDoc:CREATE-NODE(xField,"PAGAMENTO","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"IDASTCJT","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_idastcjt).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    IF  NOT aux_flagenda THEN 
        DO:
            /* ---------- */
            IF  aux_dsprotoc <> ""  THEN
                DO:
                    xDoc:CREATE-NODE(xField,"PROTOCOLO","ELEMENT").
                    xRoot:APPEND-CHILD(xField).
                    
                    xDoc:CREATE-NODE(xText,"","TEXT").
                    xText:NODE-VALUE = aux_dsprotoc.
                    xField:APPEND-CHILD(xText).
                END.
            /* ---------- */

            /* ---------- */
            IF  aux_cdbcoctl <> ""  THEN
                DO:
                    xDoc:CREATE-NODE(xField,"CDBCOCTL","ELEMENT").
                    xRoot:APPEND-CHILD(xField).
                    
                    xDoc:CREATE-NODE(xText,"","TEXT").
                    xText:NODE-VALUE = aux_cdbcoctl.
                    xField:APPEND-CHILD(xText).
                END.
            /* ---------- */

            /* ---------- */
            IF  aux_cdagectl <> ""  THEN
                DO:
                    xDoc:CREATE-NODE(xField,"CDAGECTL","ELEMENT").
                    xRoot:APPEND-CHILD(xField).
        
                    xDoc:CREATE-NODE(xText,"","TEXT").
                    xText:NODE-VALUE = aux_cdagectl.
                    xField:APPEND-CHILD(xText).
                END.
            /* ---------- */
        END.

    RETURN "OK".
END PROCEDURE.
/* Fim 29 - paga_convenio */




PROCEDURE atualiza_noturno_temporizador:

    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.

    RUN atualiza_noturno_temporizador IN h-b1wgen0025 ( INPUT crapcop.cdcooper,
                                                        INPUT craptfn.nrterfin,
                                                        INPUT aux_cdoperad,
                                                        INPUT aux_hrininot,
                                                        INPUT aux_hrfimnot,
                                                        INPUT aux_vlsaqnot,
                                                        INPUT aux_nrtempor,
                                                       OUTPUT aux_dscritic).

    DELETE PROCEDURE h-b1wgen0025.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".


    /* ---------- */
    xDoc:CREATE-NODE(xField,"NOTURNO","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).
    
    RETURN "OK".
END PROCEDURE.
/* Fim 30 - atualiza_noturno_temporizador */


PROCEDURE verifica_agendamento_mensal:

    DEFINE VARIABLE aux_dstransa AS CHARACTER                       NO-UNDO.
    DEFINE VARIABLE aux_mesanotr AS CHARACTER                       NO-UNDO.
    DEFINE VARIABLE aux_cddbanco AS INTE                            NO-UNDO.
    DEFINE VARIABLE aux_cdcritic AS INTEGER                         NO-UNDO.

    DEF    BUFFER crabcop FOR crapcop.        

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

	/* Efetuar a chamada a rotina Oracle */ 
	RUN STORED-PROCEDURE pc_valid_repre_legal_trans
		aux_handproc = PROC-HANDLE NO-ERROR (INPUT aux_cdcooper, /* Código da Cooperativa */
											 INPUT aux_nrdconta, /* Número da Conta */
											 INPUT 1,            /* Titular da Conta */
                                             INPUT 0,
											OUTPUT 0,            /* Código da crítica */
											OUTPUT "").          /* Descrição da crítica */
	
	/* Fechar o procedimento para buscarmos o resultado */ 
	CLOSE STORED-PROC pc_valid_repre_legal_trans
		   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
	
	{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
	
	/* Busca possíveis erros */ 
	ASSIGN aux_cdcritic = 0
		   aux_dscritic = ""
		   aux_cdcritic = pc_valid_repre_legal_trans.pr_cdcritic 
						  WHEN pc_valid_repre_legal_trans.pr_cdcritic <> ?
		   aux_dscritic = pc_valid_repre_legal_trans.pr_dscritic 
						  WHEN pc_valid_repre_legal_trans.pr_dscritic <> ?.

    IF aux_dscritic <> "" THEN
        RETURN "NOK".
    
    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.

    RUN verifica_transferencia IN h-b1wgen0025 ( INPUT aux_cdcooper,
                                                 INPUT aux_nrdconta,
                                                 INPUT aux_cdagetra,
                                                 INPUT aux_nrtransf,
                                                 INPUT aux_vltransf,
                                                 INPUT aux_dttransf, 
                                                 INPUT aux_tpoperac,
                                                 INPUT TRUE, 
                                                 INPUT crapdat.dtmvtocd,
                                                OUTPUT aux_dscritic).
    DELETE PROCEDURE h-b1wgen0025.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".  

    /* Cooperativa Destino */
    FIND crabcop WHERE crabcop.cdagectl = aux_cdagetra NO-LOCK NO-ERROR.

    IF   AVAIL crabcop   THEN
         ASSIGN aux_cddbanco = crabcop.cdbcoctl.

    ASSIGN aux_mesanotr = STRING(MONTH(aux_dtinitra),"99") + "/" +
                          STRING(YEAR(aux_dtinitra),"9999").

    RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.
                                                          
    RUN verifica_agendamento_recorrente IN h-b1wgen0015 
                                     (INPUT aux_cdcooper,
                                      INPUT 91,         /** PAC           **/
                                      INPUT 900,        /** CAIXA         **/
                                      INPUT aux_nrdconta,
                                      INPUT 1,          /** TITULAR       **/
                                      INPUT crapdat.dtmvtocd,
                                      INPUT DAY(aux_dtinitra),
                                      INPUT aux_qtdmeses,
                                      INPUT aux_mesanotr, /* Mes e ano iniciais*/
                                      INPUT aux_vltransf,
                                      INPUT aux_cddbanco,
                                      INPUT aux_cdagetra,
                                      INPUT aux_nrtransf,
                                      INPUT 3,          /** TRANSFERENCIA    **/
                                      INPUT "",         /** Datas Calculadas **/
                                      INPUT "996",      /** OPERADOR         **/                                      
                                      INPUT aux_tpoperac, 
                                      INPUT "TAA",      /** ORIGEM           **/    
                                      INPUT 0,          /** CPF operador PJ  **/
                                      INPUT "", /* Agendamento recorrente */
                                     OUTPUT aux_dstransa,
                                     OUTPUT aux_dscritic,
                                     OUTPUT TABLE tt-agenda-recorrente).

    DELETE PROCEDURE h-b1wgen0015.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".

    FOR EACH tt-agenda-recorrente 
       WHERE tt-agenda-recorrente.flgtrans = TRUE NO-LOCK:

        ASSIGN aux_lsdataqd = IF  aux_lsdataqd = ""  THEN
                                  STRING(tt-agenda-recorrente.dtmvtopg,
                                         "99/99/9999")
                              ELSE
                                  aux_lsdataqd + "," +
                                  STRING(tt-agenda-recorrente.dtmvtopg,
                                         "99/99/9999").

    END.


    /* ---------- */
    xDoc:CREATE-NODE(xField,"TRANSFERENCIA","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"LSDATAQD","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = aux_lsdataqd.
    xField:APPEND-CHILD(xText).
    
    RETURN "OK".

END PROCEDURE. /* Fim 31 - verifica_agendamento_mensal */

PROCEDURE efetua_agendamento_mensal:
    
    DEFINE VARIABLE aux_dstransa AS CHARACTER                       NO-UNDO.
    DEFINE VARIABLE aux_cdhiscre AS INTEGER                         NO-UNDO.
    DEFINE VARIABLE aux_cdhisdeb AS INTEGER                         NO-UNDO.
    DEFINE VARIABLE aux_cdcoptfn AS INTEGER                         NO-UNDO.
    DEFINE VARIABLE aux_cdagetfn AS INTEGER                         NO-UNDO.
    DEFINE VARIABLE aux_nrterfin AS INTEGER                         NO-UNDO.
    DEFINE VARIABLE aux_cddbanco    AS INTE                         NO-UNDO.
    DEFINE VARIABLE aux_idastcjt    AS INTE                         NO-UNDO.
    DEFINE VARIABLE aux_cdcritic AS INTEGER                         NO-UNDO.
    DEFINE VARIABLE aux_flcartma    AS INTE                         NO-UNDO.
    DEFINE VARIABLE aux_nrcpfrep    AS DECI                         NO-UNDO.

    DEF    BUFFER crabcop FOR crapcop.

    ASSIGN aux_cdcoptfn = crapcop.cdcooper
           aux_cdagetfn = crapage.cdagenci
           aux_nrterfin = craptfn.nrterfin.                       

    /* Cooperativa Destino */
    FIND crabcop WHERE crabcop.cdagectl = aux_cdagetra NO-LOCK NO-ERROR.

    IF   AVAIL crabcop   THEN
         aux_cddbanco = crabcop.cdbcoctl.

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    

     RUN STORED-PROCEDURE pc_verifica_rep_assinatura
         aux_handproc = PROC-HANDLE NO-ERROR
                                 (INPUT aux_cdcooper, /* Cooperativa */
                                  INPUT aux_nrdconta, /* Nr. da conta */
                                  INPUT 1,   /* Sequencia de titular */
                                  INPUT 4,   /* Origem - TAA */
                                  OUTPUT 0,  /* Codigo 1 exige Ass. Conj. */
                                  OUTPUT 0,  /* CPF do Rep. Legal */
                                  OUTPUT "", /* Nome do Rep. Legal */
                                  OUTPUT 0,  /* Cartao Magnetico conjunta, 0 nao, 1 sim */
                                  OUTPUT 0,  /* Codigo do erro */
                                  OUTPUT ""). /* Descricao do erro */
    
     CLOSE STORED-PROC pc_verifica_rep_assinatura
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
     { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
    
     ASSIGN aux_idastcjt = 0
            aux_cdcritic = 0
            aux_dscritic = ""           
            aux_flcartma = 0
            aux_nrcpfrep = 0
            aux_idastcjt = pc_verifica_rep_assinatura.pr_idastcjt
                               WHEN pc_verifica_rep_assinatura.pr_idastcjt <> ?
            aux_flcartma = pc_verifica_rep_assinatura.pr_flcartma
                               WHEN pc_verifica_rep_assinatura.pr_flcartma <> ?
            aux_nrcpfrep = pc_verifica_rep_assinatura.pr_nrcpfcgc
                               WHEN pc_verifica_rep_assinatura.pr_nrcpfcgc <> ?
            aux_cdcritic = pc_verifica_rep_assinatura.pr_cdcritic
                               WHEN pc_verifica_rep_assinatura.pr_cdcritic <> ?
            aux_dscritic = pc_verifica_rep_assinatura.pr_dscritic
                               WHEN pc_verifica_rep_assinatura.pr_dscritic <> ?.           
    
     IF  aux_cdcritic <> 0   OR
         aux_dscritic <> ""  THEN
         DO:
             IF  aux_dscritic = "" THEN
                ASSIGN aux_dscritic =  "Nao foi possivel verificar assinatura conjunta.".
    
             RETURN "NOK".
         END.
    
     IF  aux_idastcjt = 1 THEN
         DO:
             { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    
        
             RUN STORED-PROCEDURE pc_cria_trans_pend_transf
              aux_handproc = PROC-HANDLE NO-ERROR
                                      (INPUT aux_tpoperac, /* Tipo da transacao */
                                       INPUT 91,           /* Codigo do PA */
                                       INPUT 900,          /* Numero do caixa */
                                       INPUT "996",        /* Operador */
                                       INPUT "TAA",        /* Nome da tela */
                                       INPUT 4,            /* Id origem */
                                       INPUT 1,            /* Titular */
                                       INPUT IF aux_flcartma = 1 THEN 0 ELSE aux_nrcpfrep, /* CPF do operador juridico */
                                       INPUT IF aux_flcartma = 1 THEN aux_nrcpfrep ELSE 0, /* CPF do representante legal */
                                       INPUT crapcop.cdcooper, /* Cooperativa do terminal */
                                       INPUT crapage.cdagenci, /* Agencia do terminal */
                                       INPUT craptfn.nrterfin, /* Numero do terminal */
                                       INPUT crapdat.dtmvtocd, /* Data de movimento */
                                       INPUT aux_cdcooper, /* Cooperativa */
                                       INPUT aux_nrdconta, /* Nr. da conta */
                                       INPUT aux_vltransf, /* Valor do lancamento */
                                       INPUT aux_dttransf, /* Data da transferencia */
                                       INPUT 2, /* Indicador de agendamento */
                                       INPUT aux_cdagetra, /* Agencia destino */
                                       INPUT aux_nrtransf, /* Conta de destino */
                                       INPUT aux_lsdataqd,
                                       INPUT aux_idastcjt,
                                       INPUT 0,
                                       INPUT aux_idtipcar,
                                       INPUT aux_nrcartao,
                                       OUTPUT 0,  /* Codigo do erro */
                                       OUTPUT ""). /* Descricao do erro */
    
             CLOSE STORED-PROC pc_cria_trans_pend_transf
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
             { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
    
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = ""           
                    aux_cdcritic = pc_cria_trans_pend_transf.pr_cdcritic 
                                       WHEN pc_cria_trans_pend_transf.pr_cdcritic <> ?
                    aux_dscritic = pc_cria_trans_pend_transf.pr_dscritic
                                       WHEN pc_cria_trans_pend_transf.pr_dscritic <> ?.           
    
             IF  aux_cdcritic <> 0   OR
                 aux_dscritic <> ""  THEN
                 DO:
                     IF  aux_dscritic = "" THEN
                        ASSIGN aux_dscritic =  "Nao foi possivel efetuar transferencia.".
    
                     RETURN "NOK".
                 END.                
    
         END.
     ELSE
         DO:
            RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.
        
            IF   aux_tpoperac = 5   THEN /* Transf. intercoop. */
                 ASSIGN aux_cdhisdeb = 1009. 
            ELSE /* Transf. Intracooperativa */
                 RUN verifica-historico-transferencia IN h-b1wgen0015
                                                     (INPUT aux_cdcooper,
                                                      INPUT aux_nrdconta,
                                                      INPUT aux_nrtransf,
                                                      INPUT 4, /* Origem - TAA         */ 
                                                      INPUT 1, /* Transferencia Normal */ 
                                                     OUTPUT aux_cdhiscre,
                                                     OUTPUT aux_cdhisdeb).
                
            DELETE PROCEDURE h-b1wgen0015.
        
            
            
            { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
            
            RUN STORED-PROCEDURE pc_agendamento_recorrente
                aux_handproc = PROC-HANDLE NO-ERROR
                                                (INPUT aux_cdcooper,
                                    INPUT 91,                           
                                    INPUT 900,          /* par_nrdcaixa */
                                    INPUT "996",        /* par_cdoperad */
                                                 INPUT aux_nrdconta,
                                                 INPUT 1,
                                                 INPUT crapdat.dtmvtocd,
                                    INPUT 4, /* cdorigem */
                                    INPUT "TAA",                        
                                    INPUT "TAA", /* nmprogra */ 
                                    INPUT aux_lsdataqd,                 
                                                 INPUT aux_cdhisdeb,
                                                 INPUT aux_vltransf,
                                                 INPUT aux_cddbanco,
                                                 INPUT aux_cdagetra,
                                                 INPUT aux_nrtransf, 
                                    INPUT aux_tpoperac,                 
                                    INPUT aux_cdcoptfn,                 
                                    INPUT aux_cdagetfn,                 
                                    INPUT aux_nrterfin,                 
                                    INPUT 0,             
                                    INPUT aux_idtipcar,  
                                    INPUT aux_nrcartao,  
                                    INPUT 0,   /* cdfinali */
                                    INPUT ' ', /* dstransf */
                                    INPUT ' ', /* dshistor */
                                    INPUT '',  /* iptransa */
                                    INPUT '',  /* iddispos */ 
                                    OUTPUT "",  /* pr_dslancto */ 
                                    OUTPUT "",  /* pr_dstransa */        
                                    OUTPUT "",  /* pr_cdcritic */        
                                    OUTPUT ""). /* pr_dscritic */        

            CLOSE STORED-PROC pc_agendamento_recorrente
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
            
            { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

            ASSIGN aux_dstransa = pc_agendamento_recorrente.pr_dstransa
                             WHEN pc_agendamento_recorrente.pr_dstransa <> ?
                   aux_dscritic = pc_agendamento_recorrente.pr_dscritic
                             WHEN pc_agendamento_recorrente.pr_dscritic <> ?.
            
         END.
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".

    /* ---------- */
    xDoc:CREATE-NODE(xField,"TRANSFERENCIA","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"IDASTCJT","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_idastcjt).
    xField:APPEND-CHILD(xText).
    
    RETURN "OK".

END PROCEDURE. /* Fim 32 - efetua_agendamento_mensal */


PROCEDURE obtem_agendamentos:

    DEFINE VARIABLE aux_dstransa AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE aux_qttotage AS INTEGER     NO-UNDO.

    DEFINE VARIABLE aux_cdcoptfn AS INTEGER                         NO-UNDO.
    DEFINE VARIABLE aux_cdagetfn AS INTEGER                         NO-UNDO.
    DEFINE VARIABLE aux_nrterfin AS INTEGER                         NO-UNDO.
    
    /* Variaveis para o XML */ 
    DEF VAR xDoc_ora            AS HANDLE   NO-UNDO.   
    DEF VAR xRoot_ora           AS HANDLE   NO-UNDO.  
    DEF VAR xRoot_ora2          AS HANDLE   NO-UNDO.  
    DEF VAR xField_ora          AS HANDLE   NO-UNDO. 
    DEF VAR xText_ora           AS HANDLE   NO-UNDO. 
    DEF VAR aux_cont_raiz   	  AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont        	  AS INTEGER  NO-UNDO. 
    DEF VAR ponteiro_xml_ora    AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req_ora         AS LONGCHAR NO-UNDO.
    
    ASSIGN aux_cdcoptfn = crapcop.cdcooper
           aux_cdagetfn = crapage.cdagenci
           aux_nrterfin = craptfn.nrterfin.
    
    RUN sistema/generico/procedures/b1wgen0016.p PERSISTENT SET h-b1wgen0016.

    RUN obtem-agendamentos IN h-b1wgen0016 
                                        (INPUT  aux_cdcooper,
                                         INPUT  91,           /** PAC      **/
                                         INPUT  900,          /** CAIXA    **/
                                         INPUT  aux_nrdconta,
                                         INPUT  "TAA",
                                         INPUT  aux_dtmvtolt,
                                         INPUT  ?,           /** DATA INICIAL **/
                                         INPUT  ?,           /** DATA FINAL   **/
                                         INPUT  1,           /**  PENDENTE    **/
                                         INPUT  0,           /** QTDE JA LISTADOS      **/
                                         INPUT  100,        /** QTDE LISTADOS EM TELA **/
                                         OUTPUT aux_dstransa,
                                         OUTPUT aux_dscritic,
                                         OUTPUT aux_qttotage,
                                         OUTPUT TABLE tt-dados-agendamento).

    DELETE PROCEDURE h-b1wgen0016.
    
    IF  aux_dscritic <> "" OR RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_obtem_agendamentos_recarga aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT aux_cdcooper 
                         ,INPUT aux_nrdconta 
                         ,INPUT 4   /* TAA */
                         ,INPUT 1   /* Agendamento */
                         ,INPUT ?
                         ,INPUT ?
                         ,OUTPUT "" 
                         ,OUTPUT 0
                         ,OUTPUT "").
                         

    CLOSE STORED-PROC pc_obtem_agendamentos_recarga aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dscritic = ""
           aux_dscritic = pc_obtem_agendamentos_recarga.pr_dscritic 
                          WHEN pc_obtem_agendamentos_recarga.pr_dscritic <> ?
           xml_req_ora  = pc_obtem_agendamentos_recarga.pr_clobxml. 
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF  aux_dscritic <> "" THEN 
        RETURN "NOK".
    
    CREATE X-DOCUMENT xDoc_ora.
    CREATE X-NODEREF  xRoot_ora.
    CREATE X-NODEREF  xRoot_ora2.
    CREATE X-NODEREF  xField_ora.
    CREATE X-NODEREF  xText_ora.
    
    SET-SIZE(ponteiro_xml_ora) = LENGTH(xml_req_ora) + 1.
    PUT-STRING(ponteiro_xml_ora,1) = xml_req_ora.

    xDoc_ora:LOAD("MEMPTR",ponteiro_xml_ora,FALSE).
    xDoc_ora:GET-DOCUMENT-ELEMENT(xRoot_ora).
    
    DO aux_cont_raiz = 1 TO xRoot_ora:NUM-CHILDREN: 

      xRoot_ora:GET-CHILD(xRoot_ora2,aux_cont_raiz) NO-ERROR.
                
      IF xRoot_ora2:SUBTYPE <> "ELEMENT" THEN 
        NEXT. 
                    
      IF xRoot_ora2:NUM-CHILDREN > 0 THEN
        CREATE tt-dados-agendamento.

      DO aux_cont = 1 TO xRoot_ora2:NUM-CHILDREN:
                                      
        xRoot_ora2:GET-CHILD(xField_ora,aux_cont) NO-ERROR. 

        IF xField_ora:SUBTYPE <> "ELEMENT" THEN 
           NEXT.

        xField_ora:GET-CHILD(xText_ora,1) NO-ERROR. 

        /* Se nao vier conteudo na TAG */ 
        IF ERROR-STATUS:ERROR             OR  
           ERROR-STATUS:NUM-MESSAGES > 0  THEN
           NEXT.
        
        ASSIGN tt-dados-agendamento.dtmvtopg    = DATE(xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "dtrecarga".
        ASSIGN tt-dados-agendamento.nrdocmto    = INTE(xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "idoperacao".
        ASSIGN tt-dados-agendamento.dtmvtage    = DATE(xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "dttransa".
        ASSIGN tt-dados-agendamento.dttransa    = DATE(xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "dttransa".
        ASSIGN tt-dados-agendamento.hrtransa    = INTE(xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "hrtransa".
        ASSIGN tt-dados-agendamento.vllanaut    = DECI(xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "vlrecarga".
        ASSIGN tt-dados-agendamento.nrddd       = INTE(xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "nrddd".
        ASSIGN tt-dados-agendamento.nrcelular   =      xText_ora:NODE-VALUE  WHEN xField_ora:NAME = "nrcelular".
        ASSIGN tt-dados-agendamento.nmoperadora =      xText_ora:NODE-VALUE  WHEN xField_ora:NAME = "nmoperadora".
        ASSIGN tt-dados-agendamento.dssitlau    =      xText_ora:NODE-VALUE  WHEN xField_ora:NAME = "dssit_operacao".
        ASSIGN tt-dados-agendamento.incancel    = INTE(xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "incancel".
        
      END.
      
      ASSIGN tt-dados-agendamento.cdtiptra = 11.
      ASSIGN tt-dados-agendamento.dstiptra = "Recarga de celular".
      
      aux_qttotage = aux_qttotage + 1.
      
    END.  
    
    SET-SIZE(ponteiro_xml_ora) = 0.

    DELETE OBJECT xDoc_ora.
    DELETE OBJECT xRoot_ora.
    DELETE OBJECT xRoot_ora2.
    DELETE OBJECT xField_ora.
    DELETE OBJECT xText_ora.

    IF aux_qttotage > 0 THEN
        DO:
            RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.

            RUN gera_estatistico IN h-b1wgen0025 (INPUT aux_cdcoptfn, /* Coop do TAA */
                                                  INPUT aux_nrterfin, /* Nro do TAA */
                                                  INPUT "",           /* Prefixo TAA versao 1 */
                                                  INPUT aux_cdcooper, /* Coop do Associado */
                                                  INPUT aux_nrdconta, /* Conta do Associado */
                                                  INPUT 13).          /* Consulta de Agendamento */
            DELETE PROCEDURE h-b1wgen0025.


        END.
        
    FOR EACH tt-dados-agendamento NO-LOCK BREAK BY tt-dados-agendamento.dtmvtopg
                                                BY tt-dados-agendamento.nrdocmto:


        IF  FIRST-OF(tt-dados-agendamento.nrdocmto) THEN
            DO:
                /* Nao apresentaremos os agendamentos de FGTS e DAE no TAA */
                IF tt-dados-agendamento.cdtiptra = 12 OR
                   tt-dados-agendamento.cdtiptra = 13  THEN
                   NEXT.            
                   
                /* CHAVE DO AGENDAMENTO */
                xDoc:CREATE-NODE(xRoot2,"AGENDAMENTO","ELEMENT").
                xRoot2:SET-ATTRIBUTE("DTMVTOPG",STRING(tt-dados-agendamento.dtmvtopg)).
                xRoot2:SET-ATTRIBUTE("NRDOCMTO",STRING(tt-dados-agendamento.nrdocmto)).
                xRoot:APPEND-CHILD(xRoot2).

                /* DEMAIS INFORMACOES DO AGENDAMENTO */
                xDoc:CREATE-NODE(xField ,"DTMVTOLT","ELEMENT").
                xRoot2:APPEND-CHILD(xField).

                xDoc:CREATE-NODE(xText,"","TEXT").
                xText:NODE-VALUE = STRING(tt-dados-agendamento.dtmvtage).
                xField:APPEND-CHILD(xText).
                
                /* ---------- */
                xDoc:CREATE-NODE(xField ,"VLLANAUT","ELEMENT").
                xRoot2:APPEND-CHILD(xField).

                xDoc:CREATE-NODE(xText,"","TEXT").
                xText:NODE-VALUE = STRING(tt-dados-agendamento.vllanaut).
                xField:APPEND-CHILD(xText).

                 /* ---------- */
                xDoc:CREATE-NODE(xField ,"CDTIPTRA","ELEMENT").
                xRoot2:APPEND-CHILD(xField).

                xDoc:CREATE-NODE(xText,"","TEXT").
                xText:NODE-VALUE = STRING(tt-dados-agendamento.cdtiptra).
                xField:APPEND-CHILD(xText).
                
                /* ---------- */
                xDoc:CREATE-NODE(xField ,"DSTIPTRA","ELEMENT").
                xRoot2:APPEND-CHILD(xField).

                xDoc:CREATE-NODE(xText,"","TEXT").
                xText:NODE-VALUE = tt-dados-agendamento.dstiptra.
                xField:APPEND-CHILD(xText).
                                           
                /* ---------- */
                xDoc:CREATE-NODE(xField ,"DSSITLAU","ELEMENT").
                xRoot2:APPEND-CHILD(xField).

                xDoc:CREATE-NODE(xText,"","TEXT").
                xText:NODE-VALUE = tt-dados-agendamento.dssitlau.
                xField:APPEND-CHILD(xText).

                
                IF  tt-dados-agendamento.cdtiptra = 1 OR 
                    tt-dados-agendamento.cdtiptra = 3 OR 
                    tt-dados-agendamento.cdtiptra = 5 THEN
                    DO:
                        /* ---------- */
                        xDoc:CREATE-NODE(xField ,"DSAGENDA","ELEMENT").
                        xRoot2:APPEND-CHILD(xField).
                        
                        xDoc:CREATE-NODE(xText,"","TEXT").
                        xText:NODE-VALUE = tt-dados-agendamento.nrctadst.
                        xField:APPEND-CHILD(xText). 

                        IF  tt-dados-agendamento.cdtiptra = 1 OR 
                            tt-dados-agendamento.cdtiptra = 5 THEN  
                            DO:
                                xDoc:CREATE-NODE(xField ,"DSAGEBAN","ELEMENT").
                                xRoot2:APPEND-CHILD(xField).
                                
                                xDoc:CREATE-NODE(xText,"","TEXT").
                                xText:NODE-VALUE = tt-dados-agendamento.dsageban.
                                xField:APPEND-CHILD(xText). 
                            END.       
                    END.
                ELSE IF tt-dados-agendamento.cdtiptra = 11 THEN
                    DO:
                        /* ---------- */
                        xDoc:CREATE-NODE(xField ,"DSAGENDA","ELEMENT").
                        xRoot2:APPEND-CHILD(xField).
                        
                        xDoc:CREATE-NODE(xText,"","TEXT").
                        xText:NODE-VALUE = "(" + STRING(tt-dados-agendamento.nrddd) + ") " 
                                         +  tt-dados-agendamento.nrcelular + " - "
                                         +  tt-dados-agendamento.nmoperadora.
                        xField:APPEND-CHILD(xText). 
                        
                        /* ---------- */
                        xDoc:CREATE-NODE(xField ,"NMOPERADORA","ELEMENT").
                        xRoot2:APPEND-CHILD(xField).
                        
                        xDoc:CREATE-NODE(xText,"","TEXT").
                        xText:NODE-VALUE = tt-dados-agendamento.nmoperadora.
                        xField:APPEND-CHILD(xText).
                        
                        /* ---------- */
                        xDoc:CREATE-NODE(xField ,"DSTELEFO","ELEMENT").
                        xRoot2:APPEND-CHILD(xField).
                        
                        xDoc:CREATE-NODE(xText,"","TEXT").
                        xText:NODE-VALUE = "(" + STRING(tt-dados-agendamento.nrddd) + ") " 
                                           +  tt-dados-agendamento.nrcelular.
                        xField:APPEND-CHILD(xText).                        
                        
                    END.
                ELSE
                    DO:
                        /* ---------- */
                        xDoc:CREATE-NODE(xField ,"DSAGENDA","ELEMENT").
                        xRoot2:APPEND-CHILD(xField).
                        
                        xDoc:CREATE-NODE(xText,"","TEXT").
                        xText:NODE-VALUE = tt-dados-agendamento.dscedent.
                        xField:APPEND-CHILD(xText).

                        /* ---------- */
                        xDoc:CREATE-NODE(xField ,"DSLINDIG","ELEMENT").
                        xRoot2:APPEND-CHILD(xField).
                        
                        xDoc:CREATE-NODE(xText,"","TEXT").
                        xText:NODE-VALUE = tt-dados-agendamento.dslindig.
                        xField:APPEND-CHILD(xText).
                    END.
            END.

    END.

END PROCEDURE. /* Fim 33 - obtem_agendamentos */

/* .......................................................................... */

PROCEDURE exclui_agendamentos:

    DEFINE VARIABLE aux_dstransa AS CHARACTER                       NO-UNDO.

    DEFINE VARIABLE aux_cdcoptfn AS INTEGER                         NO-UNDO.
    DEFINE VARIABLE aux_cdagetfn AS INTEGER                         NO-UNDO.
    DEFINE VARIABLE aux_nrterfin AS INTEGER                         NO-UNDO.
    
    ASSIGN aux_cdcoptfn = crapcop.cdcooper
           aux_cdagetfn = crapage.cdagenci
           aux_nrterfin = craptfn.nrterfin.


    RUN sistema/generico/procedures/b1wgen0016.p PERSISTENT SET h-b1wgen0016.

    RUN cancelar-agendamento IN h-b1wgen0016 (INPUT  aux_cdcooper,
                                              INPUT  91,    /* AGENCIA  */
                                              INPUT  900,   /* CAIXA    */
                                              INPUT  "996", /* OPERADOR */
                                              INPUT  aux_nrdconta,
                                              INPUT  1,     /* Titular  */
                                              INPUT  aux_dtmvtopg,
                                              INPUT  "TAA", /* Origem   */
                                              INPUT  aux_dtmvtolt,
                                              INPUT  aux_nrdocmto,
                                              INPUT  0, /* Idlancto */
											  INPUT  "TAA", /*Nome da tela*/
                                              INPUT  0, /*par_nrcpfope*/
                                              OUTPUT aux_dstransa,
                                              OUTPUT aux_dscritic).

    DELETE PROCEDURE h-b1wgen0016.

    IF  aux_dscritic = "" THEN
        DO:
            /* Cria registro na crapext */
            RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.

            RUN gera_estatistico IN h-b1wgen0025 (INPUT aux_cdcoptfn, /* Coop do TAA */
                                                  INPUT aux_nrterfin, /* Nro do TAA */
                                                  INPUT "",           /* Prefixo TAA versao 1 */
                                                  INPUT aux_cdcooper, /* Coop do Associado */
                                                  INPUT aux_nrdconta, /* Conta do Associado */
                                                  INPUT 14).          /* Exclusão de Agendamento */
            DELETE PROCEDURE h-b1wgen0025.
        END.
     ELSE
         RETURN "NOK".

    /* ---------- */
    xDoc:CREATE-NODE(xField,"EXCLUSAO","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    RETURN "OK".

END PROCEDURE.


PROCEDURE verifica_comprovantes:

    DEFINE VAR aux_dstransa AS CHAR                                    NO-UNDO.
    DEFINE VAR aux_qttotreg AS INTE                                    NO-UNDO.
    DEFINE VAR aux_dstransf AS CHAR                                    NO-UNDO.

    DEFINE VAR aux_nmopetel AS CHAR                                    NO-UNDO.
    DEFINE VAR aux_dstelefo AS CHAR                                    NO-UNDO.
    DEFINE VAR aux_dsnsuope AS CHAR                                    NO-UNDO.
    DEFINE VAR aux_dspagador AS CHAR                                   NO-UNDO.    
    DEFINE VAR aux_dtvenctit AS CHAR                                   NO-UNDO.    
    DEFINE VAR aux_vlrtitulo AS CHAR                                   NO-UNDO.    
    DEFINE VAR aux_vlrjurmul AS CHAR                                   NO-UNDO.    
    DEFINE VAR aux_vlrdscaba AS CHAR                                   NO-UNDO.    
    DEFINE VAR aux_nrcpfcgc_benef AS CHAR                              NO-UNDO.
    DEFINE VAR aux_nrcpfcgc_pagad AS CHAR                              NO-UNDO.    

    EMPTY TEMP-TABLE tt-cratpro.


    RUN sistema/generico/procedures/bo_algoritmo_seguranca.p 
        PERSISTENT SET h-bo_algoritmo_seguranca.

    /* Trazer os Tipos 'Transferencia' */
    RUN lista_protocolos IN h-bo_algoritmo_seguranca
                                     (INPUT aux_cdcooper,
                                      INPUT aux_nrdconta,
                                      INPUT aux_dtinipro,
                                      INPUT aux_dtfimpro,
                                      INPUT "",
                                      INPUT 0,
                                      INPUT 50, /* Ate 50 registros */
                                      INPUT 1,  /* Tipo Transferencia*/
                                      INPUT 4,  /* TAA */
                                     OUTPUT aux_dstransa,
                                     OUTPUT aux_dscritic,
                                     OUTPUT aux_qttotreg,
                                     OUTPUT TABLE cratpro).

    DELETE PROCEDURE h-bo_algoritmo_seguranca.

    /* Copiar para a tt-cratpro */
    TEMP-TABLE tt-cratpro:COPY-TEMP-TABLE (TEMP-TABLE cratpro:HANDLE,TRUE).

    RUN sistema/generico/procedures/bo_algoritmo_seguranca.p 
                 PERSISTENT SET h-bo_algoritmo_seguranca.
          
    RUN lista_protocolos IN h-bo_algoritmo_seguranca
                                     (INPUT aux_cdcooper,
                                      INPUT aux_nrdconta,
                                      INPUT aux_dtinipro,
                                      INPUT aux_dtfimpro,
                                      INPUT "",
                                      INPUT 0,
                                      INPUT 50, /* Ate 50 registros */
                                      INPUT 6,  /* Tipo Pagamento */
                                      INPUT 4,  /* TAA */
                                     OUTPUT aux_dstransa,
                                     OUTPUT aux_dscritic,
                                     OUTPUT aux_qttotreg,
                                     OUTPUT TABLE cratpro).
 
    DELETE PROCEDURE h-bo_algoritmo_seguranca.

    /* Copiar para a tt-cratpro */
    TEMP-TABLE tt-cratpro:COPY-TEMP-TABLE (TEMP-TABLE cratpro:HANDLE,TRUE).
           
    RUN sistema/generico/procedures/bo_algoritmo_seguranca.p 
        PERSISTENT SET h-bo_algoritmo_seguranca.

    /* Trazer os Tipos 'Recarga de celular' */
    RUN lista_protocolos IN h-bo_algoritmo_seguranca
                                     (INPUT aux_cdcooper,
                                      INPUT aux_nrdconta,
                                      INPUT aux_dtinipro,
                                      INPUT aux_dtfimpro,
									  INPUT "",
                                      INPUT 0,
                                      INPUT 50, /* Ate 50 registros */
                                      INPUT 20, /* Recarga de celular*/
                                      INPUT 4,  /* TAA */
                                     OUTPUT aux_dstransa,
                                     OUTPUT aux_dscritic,
                                     OUTPUT aux_qttotreg,
                                     OUTPUT TABLE cratpro).

    DELETE PROCEDURE h-bo_algoritmo_seguranca.

    /* Copiar para a tt-cratpro */
    TEMP-TABLE tt-cratpro:COPY-TEMP-TABLE (TEMP-TABLE cratpro:HANDLE,TRUE).
                      
    FOR EACH tt-cratpro NO-LOCK:
           
        /* CHAVE DO COMPROVANTE */
        xDoc:CREATE-NODE(xRoot2,"COMPROVANTE","ELEMENT").
        xRoot:APPEND-CHILD(xRoot2).


        /* Data */
        xDoc:CREATE-NODE(xField,"DTMVTOLT","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-cratpro.dtmvtolt).
        xField:APPEND-CHILD(xText).
          
        /* Descricao*/
        xDoc:CREATE-NODE(xField,"DSCEDENT","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").

        IF   tt-cratpro.cdtippro = 1   OR
             tt-cratpro.cdtippro = 5   THEN
             DO:
                 xText:NODE-VALUE = SUBSTR (ENTRY(3,tt-cratpro.dsinform[2],"#"),1,4) + 
                                    "/" + TRIM (tt-cratpro.dscedent).
                 xField:APPEND-CHILD(xText).

                 /* Agencia destino */
                 xDoc:CREATE-NODE(xField,"DSAGECTL","ELEMENT").
                 xRoot2:APPEND-CHILD(xField).
                
                 xDoc:CREATE-NODE(xText,"","TEXT").
                 xText:NODE-VALUE = ENTRY(3,tt-cratpro.dsinform[2],"#").
                 xField:APPEND-CHILD(xText).
             END.
        ELSE
             DO:
                 xText:NODE-VALUE = tt-cratpro.dscedent.
                    xField:APPEND-CHILD(xText).
             END.
            
        /* Valor */
        xDoc:CREATE-NODE(xField,"VLDOCMTO","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-cratpro.vldocmto).
        xField:APPEND-CHILD(xText).

        /* Tipo de Pagamento*/
        xDoc:CREATE-NODE(xField,"DSINFORM","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = tt-cratpro.dsinform[1].
        xField:APPEND-CHILD(xText).

        /* Protocolo */
        xDoc:CREATE-NODE(xField,"DSPROTOC","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = tt-cratpro.dsprotoc.                               
        xField:APPEND-CHILD(xText).

        /* Linha Digitavel */
        IF   NUM-ENTRIES(tt-cratpro.dsinform[3],"#") >= 2  THEN
             IF   TRIM(ENTRY(2,tt-cratpro.dsinform[3],"#")) <> ""   THEN
                  DO:
                      xDoc:CREATE-NODE(xField,"LNDIGITA","ELEMENT").
                      xRoot2:APPEND-CHILD(xField).
                     
                      xDoc:CREATE-NODE(xText,"","TEXT").
                      xText:NODE-VALUE = 
                          TRIM(ENTRY(2,tt-cratpro.dsinform[3],"#")) NO-ERROR.
                                
                      xField:APPEND-CHILD(xText). 
                  END.   

        IF    tt-cratpro.cdtippro = 1  OR 
              tt-cratpro.cdtippro = 5  THEN /* Transferencia */
              DO:                              
                  /* Conta transferencia */
                  ASSIGN aux_dstransf = 
                      REPLACE(ENTRY(2,tt-cratpro.dsinform[2],"#"),".","").
                                                 
                  xDoc:CREATE-NODE(xField,"NRTRANSF","ELEMENT").
                  xRoot2:APPEND-CHILD(xField).

                  xDoc:CREATE-NODE(xText,"","TEXT").
                  xText:NODE-VALUE =  
                    REPLACE( SUBSTR(aux_dstransf,19,INDEX(aux_dstransf," - ") - 19),"-","").
                               
                  xField:APPEND-CHILD(xText).
                 
                  /* Nome conta acima - Primeiros 23 caracteres */
                  xDoc:CREATE-NODE(xField,"NMTRANS1","ELEMENT").
                  xRoot2:APPEND-CHILD(xField).

                  xDoc:CREATE-NODE(xText,"","TEXT").
                  xText:NODE-VALUE = 
                      SUBSTR(aux_dstransf,INDEX(aux_dstransf," - ") + 3,23).
                               
                  xField:APPEND-CHILD(xText).

                  IF    SUBSTR(aux_dstransf,INDEX(aux_dstransf," - ") + 26) <> ""   THEN
                        DO:
                            /* Nome conta acima - Ultimos caracteres */
                            xDoc:CREATE-NODE(xField,"NMTRANS2","ELEMENT").
                            xRoot2:APPEND-CHILD(xField).
                          
                            xDoc:CREATE-NODE(xText,"","TEXT").
                            xText:NODE-VALUE = 
                                SUBSTR(aux_dstransf,INDEX(aux_dstransf," - ") + 26).
                                         
                            xField:APPEND-CHILD(xText).                         
                        END.
              END.
         ELSE   
         IF   tt-cratpro.cdtippro = 6   THEN /* Pagamento */
              DO:
                  /* Banco / Convenio */  
                  ASSIGN aux_dstransf = TRIM(ENTRY(2,tt-cratpro.dsinform[2],"#")). 
              
                  xDoc:CREATE-NODE(xField,"TPDPAGTO","ELEMENT").
                  xRoot2:APPEND-CHILD(xField).

                  xDoc:CREATE-NODE(xText,"","TEXT").
                  xText:NODE-VALUE = aux_dstransf.
                               
                  xField:APPEND-CHILD(xText).
                                    
                IF TRIM(ENTRY(3,tt-cratpro.dsinform[3],"#")) <> "" THEN 
                DO:
                  ASSIGN aux_dspagador      = TRIM(ENTRY(4,tt-cratpro.dsinform[3],"#")). /* nome do pagador do boleto */
                  ASSIGN aux_nrcpfcgc_pagad = TRIM(ENTRY(5,tt-cratpro.dsinform[3],"#")). /* nome do pagador do boleto */
                  ASSIGN aux_dtvenctit      = TRIM(ENTRY(6,tt-cratpro.dsinform[3],"#")). /* vencimento do titulo */
                  ASSIGN aux_vlrtitulo      = TRIM(ENTRY(7,tt-cratpro.dsinform[3],"#")). /* valor do titulo */
                  ASSIGN aux_vlrjurmul      = TRIM(ENTRY(8,tt-cratpro.dsinform[3],"#")). /* valor de juros + multa */
                  ASSIGN aux_vlrdscaba      = TRIM(ENTRY(9,tt-cratpro.dsinform[3],"#")). /* valor de desconto + abatimento */
                  ASSIGN aux_nrcpfcgc_benef = TRIM(ENTRY(10,tt-cratpro.dsinform[3],"#")). /* CPF/CNPJ do beneficiario	*/
                  
                  
                  
                  xDoc:CREATE-NODE(xField,"DSPAGADOR","ELEMENT").
                  xRoot2:APPEND-CHILD(xField).

                  xDoc:CREATE-NODE(xText,"","TEXT").
                  xText:NODE-VALUE = aux_dspagador.
                               
                  xField:APPEND-CHILD(xText).
                  
                  xDoc:CREATE-NODE(xField,"NRCPFCGC_PAGAD","ELEMENT").
                  xRoot2:APPEND-CHILD(xField).

                  xDoc:CREATE-NODE(xText,"","TEXT").
                  xText:NODE-VALUE = aux_nrcpfcgc_pagad.
                               
                  xField:APPEND-CHILD(xText).                  
                  
                  xDoc:CREATE-NODE(xField,"DTVENCTIT","ELEMENT").
                  xRoot2:APPEND-CHILD(xField).

                  xDoc:CREATE-NODE(xText,"","TEXT").
                  xText:NODE-VALUE = aux_dtvenctit.
                               
                  xField:APPEND-CHILD(xText).
                  
                  xDoc:CREATE-NODE(xField,"VLRTITULO","ELEMENT").
                  xRoot2:APPEND-CHILD(xField).

                  xDoc:CREATE-NODE(xText,"","TEXT").
                  xText:NODE-VALUE = aux_vlrtitulo.
                               
                  xField:APPEND-CHILD(xText).
                  
                  xDoc:CREATE-NODE(xField,"VLRJURMUL","ELEMENT").
                  xRoot2:APPEND-CHILD(xField).

                  xDoc:CREATE-NODE(xText,"","TEXT").
                  xText:NODE-VALUE = aux_vlrjurmul.
                               
                  xField:APPEND-CHILD(xText).
                  
                  xDoc:CREATE-NODE(xField,"VLRDSCABA","ELEMENT").
                  xRoot2:APPEND-CHILD(xField).

                  xDoc:CREATE-NODE(xText,"","TEXT").
                  xText:NODE-VALUE = aux_vlrdscaba.
                               
                  xField:APPEND-CHILD(xText).
                  
                  xDoc:CREATE-NODE(xField,"NRCPFCGC_BENEF","ELEMENT").
                  xRoot2:APPEND-CHILD(xField).

                  xDoc:CREATE-NODE(xText,"","TEXT").
                  xText:NODE-VALUE = aux_nrcpfcgc_benef.
                               
                  xField:APPEND-CHILD(xText).
                                    
              END.         

              END.         

          /* Banco 085 */
          xDoc:CREATE-NODE(xField,"CDBCOCTL","ELEMENT").
          xRoot2:APPEND-CHILD(xField).

          xDoc:CREATE-NODE(xText,"","TEXT").
          xText:NODE-VALUE = STRING(tt-cratpro.cdbcoctl).
          xField:APPEND-CHILD(xText).

          /* Agencia da cooperativa */
          xDoc:CREATE-NODE(xField,"CDAGECTL","ELEMENT").
          xRoot2:APPEND-CHILD(xField).

          xDoc:CREATE-NODE(xText,"","TEXT").
          xText:NODE-VALUE = STRING(tt-cratpro.cdagectl).
          xField:APPEND-CHILD(xText).

          IF   tt-cratpro.cdtippro = 20  THEN /* Recarga de celular */
               DO:
                  ASSIGN aux_nmopetel = ENTRY(2,tt-cratpro.dsinform[2],"#")
                         aux_dstelefo = ENTRY(3,tt-cratpro.dsinform[2],"#")
                         aux_dsnsuope = ENTRY(5,tt-cratpro.dsinform[2],"#").
                         
                  /* Nome operadora */
                  xDoc:CREATE-NODE(xField,"NMOPETEL","ELEMENT").
                  xRoot2:APPEND-CHILD(xField).

                  xDoc:CREATE-NODE(xText,"","TEXT").
                  xText:NODE-VALUE = aux_nmopetel.
                  xField:APPEND-CHILD(xText).                         
                  
                  /* Telefone */
                  xDoc:CREATE-NODE(xField,"NRTELEFO","ELEMENT").
                  xRoot2:APPEND-CHILD(xField).

                  xDoc:CREATE-NODE(xText,"","TEXT").
                  xText:NODE-VALUE = aux_dstelefo.
                  xField:APPEND-CHILD(xText).                         
                  
                  /* Telefone */
                  xDoc:CREATE-NODE(xField,"DSNSUOPE","ELEMENT").
                  xRoot2:APPEND-CHILD(xField).

                  xDoc:CREATE-NODE(xText,"","TEXT").
                  xText:NODE-VALUE = aux_dsnsuope.
                  xField:APPEND-CHILD(xText).         
	           END.                
    END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE gera_estatistico:
    
    DEFINE VARIABLE aux_cdcoptfn    AS INTE                         NO-UNDO.


    ASSIGN aux_cdcoptfn = crapcop.cdcooper.
    
    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.

    RUN gera_estatistico IN h-b1wgen0025 (INPUT aux_cdcoptfn,
                                          INPUT craptfn.nrterfin,
                                          INPUT aux_dsprefix, /* Sera recebido por parametro no novo caixa eletronico */
                                          INPUT aux_cdcooper,
                                          INPUT aux_nrdconta,
                                          INPUT aux_tpextrat).

    DELETE PROCEDURE h-b1wgen0025.

    /* ---------- */
    xDoc:CREATE-NODE(xField,"ESTATISTICO","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    RETURN "OK".

END PROCEDURE.


PROCEDURE valida_senha_letras:

    /* Antes de validar a autenticidade da senha de letras, vamos verificar se o TOKEN eh valido */

    /* Verificar se a rotina está sendo chamada pelo sistema NOVO */
    IF aux_token <> "" AND aux_token <> ? THEN
    DO:
        /* autenticidade da senha de letras, vamos verificar se o TOKEN eh valido  */
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        
        /* Efetuar a chamada a rotina Oracle */ 
         RUN STORED-PROCEDURE pc_busca_autenticacao_cartao
         aux_handproc = PROC-HANDLE NO-ERROR 
                  ( INPUT aux_cdcooper  /* pr_cdcooper --> Codigo da cooperativa */
                   ,INPUT aux_nrdconta  /* pr_nrdconta --> Número da Conta do associado */
                   ,INPUT aux_token     /* pr_token    --> Token gerado na transaçao */
                   /* --------- OUT --------- */
                   ,OUTPUT "" ).        /* pr_dscritic --> Descriçao da critica).  */
                   
         /* Fechar o procedimento para buscarmos o resultado */ 
          CLOSE STORED-PROC pc_busca_autenticacao_cartao
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.  
                            
         { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
      
        ASSIGN aux_dscritic = pc_busca_autenticacao_cartao.pr_dscritic
                      WHEN pc_busca_autenticacao_cartao.pr_dscritic <> ?.  

        IF  aux_dscritic <> "" THEN
            DO:
               RETURN "NOK".
            END.   
            
        /* Se for o sistema novo a senha será enviada aberta, e devemos criptografar */
        ASSIGN aux_dsdgrup1 = ENCODE(ENTRY(1,aux_dsdgrup1,"-")) + "-" + 
                              ENCODE(ENTRY(2,aux_dsdgrup1,"-")) + "-" +
                              ENCODE(ENTRY(3,aux_dsdgrup1,"-")).
                              
        ASSIGN aux_dsdgrup2 = ENCODE(ENTRY(1,aux_dsdgrup2,"-")) + "-" + 
                              ENCODE(ENTRY(2,aux_dsdgrup2,"-")) + "-" +
                              ENCODE(ENTRY(3,aux_dsdgrup2,"-")).        

        ASSIGN aux_dsdgrup3 = ENCODE(ENTRY(1,aux_dsdgrup3,"-")) + "-" + 
                              ENCODE(ENTRY(2,aux_dsdgrup3,"-")) + "-" +
                              ENCODE(ENTRY(3,aux_dsdgrup3,"-")).
    END.
    
    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.
                                                                                     
    RUN valida_senha_letras IN h-b1wgen0025( INPUT aux_cdcooper, 
                                             INPUT aux_nrdconta,
                                             INPUT aux_nrcartao,
                                             INPUT aux_dsdgrup1,
                                             INPUT aux_dsdgrup2,
                                             INPUT aux_dsdgrup3,
                                             INPUT aux_idtipcar,
                                            OUTPUT aux_dscritic).

    DELETE PROCEDURE h-b1wgen0025.

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".



    /* ---------- */
    xDoc:CREATE-NODE(xField,"SENHA","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).


    RETURN "OK".
END PROCEDURE.
/* Fim 37 - valida_senha_letras */


PROCEDURE carrega_cooperativas:

    DEFINE VARIABLE aux_qtregist AS INTE                            NO-UNDO.

    RUN sistema/generico/procedures/b1wgen0059.p PERSISTENT SET h-b1wgen0059.

    RUN busca-crapcop IN h-b1wgen0059 (INPUT 0,
                                       INPUT "",
                                       INPUT 99999,
                                       INPUT 0,
                                       OUTPUT aux_qtregist,
                                       OUTPUT TABLE tt-crapcop).
    DELETE PROCEDURE h-b1wgen0059.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            aux_dscritic = "Erro ao carregar as cooperativas".
            RETURN "NOK".
        END.

    FOR EACH tt-crapcop NO-LOCK:

        xDoc:CREATE-NODE(xRoot2,"COOPERATIVAS","ELEMENT").
        xRoot:APPEND-CHILD(xRoot2).

        /* DEMAIS INFORMACOES DA COOPERATIVA */
        xDoc:CREATE-NODE(xField ,"CDAGECTL","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-crapcop.cdagectl).
        xField:APPEND-CHILD(xText).
        
        /* ---------- */
        xDoc:CREATE-NODE(xField ,"NMRESCOP","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-crapcop.nmrescop).
        xField:APPEND-CHILD(xText).

    END.

    RETURN "OK".

END PROCEDURE.



PROCEDURE retorna_valor_blqjud:

    DEFINE VARIABLE aux_vlblqjud AS DECIMAL                           NO-UNDO.
	DEFINE VARIABLE tot_vlblqjud AS DECIMAL                           NO-UNDO.
    DEFINE VARIABLE aux_vlresblq AS DECIMAL                           NO-UNDO.    
    DEFINE VARIABLE aux_vlsldrpp AS DECIMAL                           NO-UNDO.    
    DEFINE VARIABLE aux_cdmodali AS INTEGER                           NO-UNDO.    
    DEFINE VARIABLE aux_cdcritic AS INTEGER                           NO-UNDO.
    DEFINE VARIABLE aux_dscritic AS CHARACTER                         NO-UNDO.
    DEFINE VARIABLE aux_vlblqapl_gar  AS DECI                         NO-UNDO.
    DEFINE VARIABLE aux_vlblqpou_gar  AS DECI                         NO-UNDO.

	
	/* Variaveis para o XML */ 
    DEF VAR xDoc_ora            AS HANDLE   NO-UNDO.   
    DEF VAR xRoot_ora           AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2_ora          AS HANDLE   NO-UNDO.  
    DEF VAR xField_ora          AS HANDLE   NO-UNDO. 
    DEF VAR xText_ora           AS HANDLE   NO-UNDO. 
    DEF VAR aux_cont_raiz   	AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont        	AS INTEGER  NO-UNDO. 
    DEF VAR ponteiro_xml_ora    AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req_ora         AS LONGCHAR NO-UNDO.

	ASSIGN tot_vlblqjud = 0.
	
    EMPTY TEMP-TABLE tt-saldo-rdca.

    /* Inicializando objetos para leitura do XML */ 
	CREATE X-DOCUMENT xDoc_ora.    /* Vai conter o XML completo */ 
	CREATE X-NODEREF  xRoot_ora.   /* Vai conter a tag DADOS em diante */ 
	CREATE X-NODEREF  xRoot2_ora.  /* Vai conter a tag INF em diante */ 
	CREATE X-NODEREF  xField_ora.  /* Vai conter os campos dentro da tag INF */ 
	CREATE X-NODEREF  xText_ora.   /* Vai conter o texto que existe dentro da tag xField */ 
	
	{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
	
	/* Efetuar a chamada a rotina Oracle */ 
	RUN STORED-PROCEDURE pc_lista_aplicacoes_car
		aux_handproc = PROC-HANDLE NO-ERROR (INPUT aux_cdcooper, /* Código da Cooperativa */
											 INPUT "996", 		 /* Código do Operador */
											 INPUT "TAA", 		 /* Nome da Tela */
											 INPUT 4,            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
											 INPUT 900,          /* Numero do Caixa */
											 INPUT aux_nrdconta, /* Número da Conta */
											 INPUT 1,            /* Titular da Conta */
											 INPUT 91,           /* Codigo da Agencia */
											 INPUT "TAA", 		 /* Codigo do Programa */
											 INPUT 0,            /* Número da Aplicação - Parâmetro Opcional */
											 INPUT 0,            /* Código do Produto – Parâmetro Opcional */ 
											 INPUT crapdat.dtmvtolt, /* Data de Movimento */
											 INPUT 0,            /* Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas) */
											 INPUT 0,            /* Identificador de Log (0 – Não / 1 – Sim) */ 																 
											OUTPUT ?,            /* XML com informações de LOG */
											OUTPUT 0,            /* Código da crítica */
											OUTPUT "").          /* Descrição da crítica */
	
	/* Fechar o procedimento para buscarmos o resultado */ 
	CLOSE STORED-PROC pc_lista_aplicacoes_car
		   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
	
	{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
	
	/* Busca possíveis erros */ 
	ASSIGN aux_cdcritic = 0
		   aux_dscritic = ""
		   aux_cdcritic = pc_lista_aplicacoes_car.pr_cdcritic 
						  WHEN pc_lista_aplicacoes_car.pr_cdcritic <> ?
		   aux_dscritic = pc_lista_aplicacoes_car.pr_dscritic 
						  WHEN pc_lista_aplicacoes_car.pr_dscritic <> ?.
	
	IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
    	DO: 
            /* Buscar o XML na tabela de retorno da procedure Progress */ 
        	ASSIGN xml_req_ora = pc_lista_aplicacoes_car.pr_clobxmlc. 
        	
        	/* Efetuar a leitura do XML*/ 
        	SET-SIZE(ponteiro_xml_ora) = LENGTH(xml_req_ora) + 1. 
        	PUT-STRING(ponteiro_xml_ora,1) = xml_req_ora. 
        	
        	IF  ponteiro_xml_ora <> ? THEN
        		DO:
        		    xDoc_ora:LOAD("MEMPTR",ponteiro_xml_ora,FALSE). 
        			xDoc_ora:GET-DOCUMENT-ELEMENT(xRoot_ora).
        	
        			DO  aux_cont_raiz = 1 TO xRoot_ora:NUM-CHILDREN: 
        	
        			    xRoot_ora:GET-CHILD(xRoot2_ora,aux_cont_raiz).
        	
        				IF  xRoot2_ora:SUBTYPE <> "ELEMENT" THEN 
        				    NEXT. 
        	
        			    IF  xRoot2_ora:NUM-CHILDREN > 0 THEN
        				    CREATE tt-saldo-rdca.
        	
        				DO aux_cont = 1 TO xRoot2_ora:NUM-CHILDREN:
        	
        				    xRoot2_ora:GET-CHILD(xField_ora,aux_cont).
        	
        					IF  xField_ora:SUBTYPE <> "ELEMENT" THEN 
        					    NEXT. 
        	
        					xField_ora:GET-CHILD(xText_ora,1).
        					 
        					ASSIGN tt-saldo-rdca.sldresga = DEC (xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "sldresga".
        					ASSIGN tt-saldo-rdca.dssitapl =      xText_ora:NODE-VALUE  WHEN xField_ora:NAME = "dssitapl".
        	
        				END. 
        	
        			END.
        	
        			SET-SIZE(ponteiro_xml_ora) = 0. 
        		END.
        	
        	DELETE OBJECT xDoc_ora. 
        	DELETE OBJECT xRoot_ora. 
        	DELETE OBJECT xRoot2_ora. 
        	DELETE OBJECT xField_ora. 
        	DELETE OBJECT xText_ora.
        END.

    FIND FIRST tt-saldo-rdca NO-LOCK NO-ERROR.

    IF  AVAIL tt-saldo-rdca THEN
        DO:
            ASSIGN aux_cdmodali = 2 /* APLICACAO */                   
			       aux_vlblqjud = 0
                   aux_vlresblq = 0.
				   
			/*** Busca Saldo Bloqueado Judicialmente ***/
			RUN sistema/generico/procedures/b1wgen0155.p PERSISTENT SET h-b1wgen0155.
			
			RUN retorna-valor-blqjud IN h-b1wgen0155(INPUT aux_cdcooper,
													 INPUT aux_nrdconta,
													 INPUT 0, /* fixo - nrcpfcgc */
													 INPUT 0, /* fixo - cdtipmov */
													 INPUT aux_cdmodali, /*APL/POUP.PRG*/
													 INPUT crapdat.dtmvtolt,
													 OUTPUT aux_vlblqjud,
													 OUTPUT aux_vlresblq).

			IF  VALID-HANDLE(h-b1wgen0155) THEN
				DELETE PROCEDURE h-b1wgen0155.
				
			ASSIGN tot_vlblqjud = tot_vlblqjud + aux_vlblqjud.
        END.											
		
    RUN sistema/generico/procedures/b1wgen0006.p PERSISTENT SET h-b1wgen0006. /* Poup. Programada */

    /* Poupanca Programada */
    RUN consulta-poupanca IN h-b1wgen0006
                                   (INPUT aux_cdcooper,
                                    INPUT 1,             /* PAC */
                                    INPUT 999,           /* Caixa */
                                    INPUT "996",         /* Operador */
                                    INPUT "TAA",         /* Tela */
                                    INPUT 4,             /* Origem - TAA */
                                    INPUT aux_nrdconta,
                                    INPUT 1,             /* Titularidade */
                                    INPUT 0,             /* Nro da Poupança 0-Todas */
                                    INPUT aux_dtiniext,
                                    INPUT aux_dtfimext,
                                    INPUT 1,             /* Processo: 1-On Line */
                                    INPUT "TAA",         /* Programa */
                                    INPUT YES,           /* Log */
                                    OUTPUT aux_vlsldrpp, /* Saldo */
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-dados-rpp).

    DELETE PROCEDURE h-b1wgen0006.      	

    FIND FIRST tt-dados-rpp NO-LOCK NO-ERROR.

    IF  AVAIL tt-dados-rpp THEN
        DO:
            ASSIGN aux_cdmodali = 3 /* POUP. PROGRAMADA */				   
			       aux_vlblqjud = 0
                   aux_vlresblq = 0.
				   
			/*** Busca Saldo Bloqueado Judicialmente ***/
			RUN sistema/generico/procedures/b1wgen0155.p PERSISTENT SET h-b1wgen0155.
			
			RUN retorna-valor-blqjud IN h-b1wgen0155(INPUT aux_cdcooper,
													 INPUT aux_nrdconta,
													 INPUT 0, /* fixo - nrcpfcgc */
													 INPUT 0, /* fixo - cdtipmov */
													 INPUT aux_cdmodali, /*APL/POUP.PRG*/
													 INPUT crapdat.dtmvtolt,
													 OUTPUT aux_vlblqjud,
													 OUTPUT aux_vlresblq).

			IF  VALID-HANDLE(h-b1wgen0155) THEN
				DELETE PROCEDURE h-b1wgen0155.
				
			ASSIGN tot_vlblqjud = tot_vlblqjud + aux_vlblqjud.
        END.
  
      ASSIGN aux_vlblqapl_gar = 0
             aux_vlblqpou_gar = 0.
      
      /*** Busca Saldo Bloqueado Garantia ***/
      IF  NOT VALID-HANDLE(h-b1wgen0112) THEN
          RUN sistema/generico/procedures/b1wgen0112.p 
              PERSISTENT SET h-b1wgen0112.
            
      RUN calcula_bloq_garantia IN h-b1wgen0112
                             ( INPUT aux_cdcooper,
                               INPUT aux_nrdconta,                                             
                              OUTPUT aux_vlblqapl_gar,
                              OUTPUT aux_vlblqpou_gar,
                              OUTPUT aux_dscritic).
                              
      IF  VALID-HANDLE(h-b1wgen0112) THEN
      DELETE PROCEDURE h-b1wgen0112.  
  
    /*---------------*/
    xDoc:CREATE-NODE(xField,"VLBLQJUD","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(tot_vlblqjud).
    xField:APPEND-CHILD(xText).

    /*---------------*/
    xDoc:CREATE-NODE(xField,"VLBLQAPL_GAR","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_vlblqapl_gar).
    xField:APPEND-CHILD(xText).
    
    /*---------------*/
    xDoc:CREATE-NODE(xField,"VLBLQPOU_GAR","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_vlblqpou_gar).
    xField:APPEND-CHILD(xText).

    RETURN "OK".

END PROCEDURE.
/* valor_bloqueado_judicialmente */


PROCEDURE status_saque:

    RUN sistema/generico/procedures/b1wgen0123.p PERSISTENT SET h-b1wgen0123.
    
    RUN status_saque IN h-b1wgen0123(INPUT crapcop.cdcooper, 
                                     INPUT craptfn.nrterfin,
                                    OUTPUT aux_flgblsaq).

    DELETE PROCEDURE h-b1wgen0123.
    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".

    /* ---------- */
    xDoc:CREATE-NODE(xField,"FLGBLSAQ","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_flgblsaq).
    xField:APPEND-CHILD(xText).


    RETURN "OK".

END PROCEDURE.
/* Fim 40 - status_saque */
    
PROCEDURE obtem-autorizacoes-debito:

    EMPTY TEMP-TABLE tt-autorizacoes-cadastradas.

    RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

    RUN busca_autorizacoes_cadastradas IN h-b1wgen0092 (INPUT aux_cdcooper,
          INPUT aux_nrdconta, 
          INPUT aux_dtmvtolt,
          INPUT "C",
                                                       OUTPUT TABLE tt-autorizacoes-cadastradas).
    DELETE PROCEDURE h-b1wgen0092.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-erro  THEN
                aux_dscritic = tt-erro.dscritic.
            ELSE
                aux_dscritic = "Problemas na BO 92".

            RETURN "NOK".
        END.  
    
    IF  NOT TEMP-TABLE tt-autorizacoes-cadastradas:HAS-RECORDS THEN
        DO:
            ASSIGN aux_dscritic = "Nao há Débitos Automáticos cadastrados.".
                    RETURN "NOK".
                END.    

    FOR EACH tt-autorizacoes-cadastradas NO-LOCK:

        xDoc:CREATE-NODE(xRoot2,"AUTORIZACOES","ELEMENT").
        xRoot:APPEND-CHILD(xRoot2).
        
        /* Nome da Empresa */
        xDoc:CREATE-NODE(xField,"NMEMPRES","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-autorizacoes-cadastradas.nmextcon).
        xField:APPEND-CHILD(xText).

        /* Histórico */
        xDoc:CREATE-NODE(xField,"CDHISTOR","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-autorizacoes-cadastradas.cdhistor).
        xField:APPEND-CHILD(xText).

        /* Código da Empresa  */
        xDoc:CREATE-NODE(xField,"CDEMPCON","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-autorizacoes-cadastradas.cdempcon).
        xField:APPEND-CHILD(xText).

        /* Segmento da Empresa  */
        xDoc:CREATE-NODE(xField,"CDSEGMTO","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-autorizacoes-cadastradas.cdsegmto).
        xField:APPEND-CHILD(xText).

        /* Identificação */
        xDoc:CREATE-NODE(xField,"CDREFERE","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-autorizacoes-cadastradas.cdrefere).
        xField:APPEND-CHILD(xText).

        /* Descrição do Valor Limite Max. prar Débito */
        xDoc:CREATE-NODE(xField,"DESMAXDB","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-autorizacoes-cadastradas.vlmaxdeb, "zzz,zz9.99").
        xField:APPEND-CHILD(xText).

        /* Valor Limite Max. prar Débito */
        xDoc:CREATE-NODE(xField,"VLRMAXDB","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-autorizacoes-cadastradas.vlmaxdeb).
        xField:APPEND-CHILD(xText).

        /* Habilitado para alteraçao */
        xDoc:CREATE-NODE(xField,"INALTERA","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-autorizacoes-cadastradas.inaltera, "S/N").
        xField:APPEND-CHILD(xText).

    END.

    RETURN "OK".

END PROCEDURE.
/* Fim 41 - obtem-autorizacoes-debito */

PROCEDURE inclui-autorizacao-debito:

    DEF     VAR     aux_nmextcon    AS      CHAR.
    DEF     VAR     aux_cdbarras    AS      CHAR.
    DEF     VAR     loc_cdempcon    AS      INTE.
    DEF     VAR     loc_cdsegmto    AS      INTE.
    DEF     VAR     aux_nmdcampo    AS      CHAR.
    DEF     VAR     aux_nmprimtl    AS      CHAR.
    DEF     VAR     aux_nmfatret    AS      CHAR.
   
    ASSIGN aux_cdbarras = SUBSTR(aux_cdbarra1, 1 ,11) + aux_cdbarra2.

    IF  aux_dscodbar <> "" THEN
        ASSIGN loc_cdempcon  = INT(SUBSTR(aux_dscodbar,16,4)) 
               loc_cdsegmto  = INT(SUBSTR(aux_dscodbar,2,1)). 
    ELSE
        ASSIGN loc_cdempcon = INT(SUBSTR(aux_cdbarras,16,4))
               loc_cdsegmto = INT(SUBSTR(aux_cdbarras,2,1)).

    RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

    RUN busca_convenios_codbarras IN h-b1wgen0092 (INPUT aux_cdcooper,
                                                   INPUT loc_cdempcon, 
                                                   INPUT loc_cdsegmto,
                                                   OUTPUT TABLE tt-convenios-codbarras).

    DELETE PROCEDURE h-b1wgen0092.

    FIND FIRST tt-convenios-codbarras WHERE tt-convenios-codbarras.cdempcon = loc_cdempcon
                                        AND tt-convenios-codbarras.cdsegmto = loc_cdsegmto
                                            NO-LOCK NO-ERROR.
    
    IF  RETURN-VALUE = "NOK" OR NOT AVAIL tt-convenios-codbarras  THEN
        DO:
            ASSIGN aux_dscritic = "Convenio nao encontrado.".
            RETURN "NOK".
        END.
    
    RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

    RUN valida-dados IN h-b1wgen0092
        ( INPUT aux_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT "996", 
          INPUT "TAA", 
          INPUT 4,            
          INPUT aux_nrdconta, 
          INPUT 1, 
          INPUT YES,
          INPUT "I",
          INPUT tt-convenios-codbarras.cdhistor,
          INPUT aux_cdrefere,
          INPUT crapdat.dtmvtocd,
          INPUT ?,
          INPUT ?, /*dtlimite*/
          INPUT crapdat.dtmvtolt,
          INPUT ?,
         OUTPUT aux_nmdcampo,
         OUTPUT aux_nmprimtl,
         OUTPUT TABLE tt-erro ) .

    DELETE PROCEDURE h-b1wgen0092.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-erro  THEN
                aux_dscritic = tt-erro.dscritic.
            ELSE
                aux_dscritic = "Problemas na BO 92".

            RETURN "NOK".
        END.

    RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

    RUN grava-dados IN h-b1wgen0092
        ( INPUT aux_cdcooper,                     /*  par_cdcooper   */
          INPUT 0,                                /*  par_cdagenci   */
          INPUT 0,                                /*  par_nrdcaixa   */
          INPUT "996",                            /*  par_cdoperad   */
          INPUT "TAA",                            /*  par_nmdatela   */
          INPUT 4,                                /*  par_idorigem   */
          INPUT aux_nrdconta,                     /*  par_nrdconta   */
          INPUT 1,                                /*  par_idseqttl   */
          INPUT YES,                              /*  par_flgerlog   */
          INPUT crapdat.dtmvtolt,                 /*  par_dtmvtolt   */
          INPUT "I",                              /*  par_cddopcao   */         
          INPUT tt-convenios-codbarras.cdhistor,  /*  par_cdhistor   */
          INPUT aux_cdrefere,                     /*  par_cdrefere   */
          INPUT 0,                                /*  par_cddddtel   */
          INPUT crapdat.dtmvtocd,                 /*  par_dtiniatr   */
          INPUT ?,                                /*  par_dtfimatr   */
          INPUT ?,                                /*  par_dtultdeb   */
          INPUT ?,                                /*  par_dtvencto   */
          INPUT "",                               /*  par_nmfatura   */
          INPUT aux_vlrmaxdb,                     /*  par_vlrmaxdb   */
          INPUT STRING(tt-convenios-codbarras.flgcnvsi, "S/N"),
          INPUT loc_cdempcon,                     
          INPUT loc_cdsegmto,                     
          INPUT "N",                              
          INPUT aux_cdbarra1,                     
          INPUT aux_cdbarra2,                     
          INPUT aux_cdbarra3,                     
          INPUT aux_cdbarra4,                     
          INPUT aux_dscodbar,                     
         OUTPUT aux_nmfatret,                     
         OUTPUT TABLE tt-erro).    
         
    DELETE PROCEDURE h-b1wgen0092.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-erro  THEN
                aux_dscritic = tt-erro.dscritic.
            ELSE
                aux_dscritic = "Problemas na BO 92".

            RETURN "NOK".
        END.  

    xDoc:CREATE-NODE(xField,"INCLUSAO","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    RETURN "OK".

END PROCEDURE.
/* Fim 42 - inclui-autorizacao-debito */

PROCEDURE exclui-autorizacao-debito:

    DEF     VAR     aux_nmdcampo    AS      CHAR.
    DEF     VAR     aux_nmprimtl    AS      CHAR.
    DEF     VAR     aux_nmfatret    AS      CHAR.

    RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

    RUN exclui_autorizacao IN h-b1wgen0092 (INPUT aux_cdcooper,
                                            INPUT 0,  /* cdagenci */
                                            INPUT 0,  /* nrdcaixa */
                                            INPUT "996", /* cdoperad */
                                            INPUT "TAA", /* nmdatela */
                                            INPUT 4, /* idorigem */
                                            INPUT aux_nrdconta,
                                            INPUT crapdat.dtmvtolt,
                                            INPUT aux_cdsegmto,                     
                                            INPUT aux_cdempcon,                     
                                            INPUT aux_cdrefere,
                                            INPUT aux_cdhistor,
                                            INPUT aux_idmotivo,                                                
                                            INPUT 1,
                                            INPUT TRUE,
         OUTPUT TABLE tt-erro).    
         
    DELETE PROCEDURE h-b1wgen0092.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-erro  THEN
                aux_dscritic = tt-erro.dscritic.
            ELSE
                aux_dscritic = "Problemas na BO 92".

            RETURN "NOK".
        END.  

    xDoc:CREATE-NODE(xField,"EXCLUSAO","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    RETURN "OK".
     
END PROCEDURE.
/* Fim 43 - exclui-autorizacao-debito */ 
 

PROCEDURE busca-convenios-codbarras:

    DEF     VAR     aux_nmextcon    AS      CHAR.
    DEF     VAR     aux_cdbarras    AS      CHAR.
    DEF     VAR     aux_cdempcon    AS      INTE.
    DEF     VAR     aux_cdsegmto    AS      INTE.

    ASSIGN aux_cdbarras = SUBSTR(aux_cdbarra1, 1 ,11) + aux_cdbarra2.

    ASSIGN aux_flgdbaut = TRUE.

    RUN verifica_convenio.
    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".

    IF  aux_dscodbar <> "" THEN
        ASSIGN aux_cdempcon  = INT(SUBSTR(aux_dscodbar,16,4)) 
               aux_cdsegmto  = INT(SUBSTR(aux_dscodbar,2,1)). 
    ELSE
        ASSIGN aux_cdempcon = INT(SUBSTR(aux_cdbarras,16,4))
               aux_cdsegmto = INT(SUBSTR(aux_cdbarras,2,1)).

    RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

    RUN busca_convenios_codbarras IN h-b1wgen0092 (INPUT aux_cdcooper,
                                                   INPUT aux_cdempcon,
                                                   INPUT aux_cdsegmto,
                                                   OUTPUT TABLE tt-convenios-codbarras).

    DELETE PROCEDURE h-b1wgen0092.

    FIND FIRST tt-convenios-codbarras WHERE tt-convenios-codbarras.cdempcon = aux_cdempcon 
                                        AND tt-convenios-codbarras.cdsegmto = aux_cdsegmto
                                            NO-LOCK NO-ERROR.
    
    IF  AVAIL tt-convenios-codbarras THEN
        ASSIGN aux_nmextcon = tt-convenios-codbarras.nmextcon.
    ELSE
        DO:
            ASSIGN aux_dscritic = "Convenio não aceito.".
            RETURN "NOK".
        END.

    IF  aux_dscritic = "" THEN
        DO:
            /* ---------- */
            xDoc:CREATE-NODE(xField,"NMEXTCON","ELEMENT").
            xRoot:APPEND-CHILD(xField).
        
            xDoc:CREATE-NODE(xText,"","TEXT").
            xText:NODE-VALUE = aux_nmextcon.
            xField:APPEND-CHILD(xText).

            /* ---------- */
            xDoc:CREATE-NODE(xField,"FLGOFATR","ELEMENT").
            xRoot:APPEND-CHILD(xField).
        
            xDoc:CREATE-NODE(xText,"","TEXT").
            xText:NODE-VALUE = STRING(crapcop.flgofatr, "S/N").
            xField:APPEND-CHILD(xText).
        END.
    
    RETURN "OK".

END PROCEDURE.
/* Fim 44 - busca-convenios-codbarras */ 

PROCEDURE busca-saldo-pre-aprovado:

    RUN sistema/generico/procedures/b1wgen0188.p PERSISTENT SET h-b1wgen0188.
    
    RUN busca_dados IN h-b1wgen0188(INPUT aux_cdcooper, 
                                    INPUT 91,    /* par_cdagenci */
                                    INPUT 999,   /* par_nrdcaixa */
                                    INPUT 1,     /* par_cdoperad */
                                    INPUT "TAA", /* par_nmdatela */
                                    INPUT 4,     /* par_cdorigem */
                                    INPUT aux_nrdconta,
                                    INPUT aux_tpusucar, /* par_idseqttl */
                                    INPUT 0,     /* par_nrcpfope */
                                    OUTPUT TABLE tt-dados-cpa,
                                    OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0188.

    FIND tt-dados-cpa NO-LOCK NO-ERROR.
    IF NOT AVAIL tt-dados-cpa THEN
       RETURN "OK".

    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLDISCRD","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(tt-dados-cpa.vldiscrd).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"TXMENSAL","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(tt-dados-cpa.txmensal).
    xField:APPEND-CHILD(xText).

    RETURN "OK".

END PROCEDURE.
/* Fim 45 - busca-saldo-pre-aprovado */ 

PROCEDURE valida-dados-pre-aprovado:

    DEF VAR aux_cdcritic AS INTE                            NO-UNDO.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

    /* Efetuar a chamada a rotina Oracle */ 
    RUN STORED-PROCEDURE pc_valid_repre_legal_trans
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT aux_cdcooper, /* Código da Cooperativa */
                                             INPUT aux_nrdconta, /* Número da Conta */
                                             INPUT 1,            /* Titular da Conta */
                                             INPUT 0,            
                                            OUTPUT 0,            /* Código da crítica */
                                            OUTPUT "").          /* Descrição da crítica */
    
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_valid_repre_legal_trans
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
    
    /* Busca possíveis erros */ 
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_valid_repre_legal_trans.pr_cdcritic 
                          WHEN pc_valid_repre_legal_trans.pr_cdcritic <> ?
           aux_dscritic = pc_valid_repre_legal_trans.pr_dscritic 
                          WHEN pc_valid_repre_legal_trans.pr_dscritic <> ?.

    IF aux_dscritic <> "" THEN
        RETURN "NOK".

    RUN sistema/generico/procedures/b1wgen0188.p PERSISTENT SET h-b1wgen0188.
    
    /* Valida os dados informados em tela */
    RUN valida_dados IN h-b1wgen0188(INPUT aux_cdcooper, 
                                     INPUT 91,    /* par_cdagenci */
                                     INPUT 999,   /* par_nrdcaixa */
                                     INPUT 1,     /* par_cdoperad */
                                     INPUT "TAA", /* par_nmdatela */
                                     INPUT 4,     /* par_cdorigem */
                                     INPUT aux_nrdconta,
                                     INPUT aux_tpusucar, /* par_idseqttl */
                                     INPUT aux_vlemprst,
                                     INPUT aux_diapagto,
                                     INPUT 0,     /* par_nrcpfope */
                                     OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0188.

    IF RETURN-VALUE <> "OK" THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.
           IF AVAIL tt-erro AND tt-erro.dscritic <> "" THEN
              ASSIGN aux_dscritic = tt-erro.dscritic.
           ELSE
              ASSIGN aux_dscritic = "Nao foi possivel concluir sua "     +
                                    "solicitacao. Dirija-se a um Posto " +
                                    "de Atendimento".
           RETURN "NOK".

       END. /* END IF RETURN-VALUE <> "OK" THEN */
    
    xDoc:CREATE-NODE(xField,"VALIDACAO","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    RETURN "OK".

END PROCEDURE.
/* Fim 46 - valida-dados-pre-aprovado */ 

PROCEDURE busca-parcelas-pre-aprovado:

    FIND crabdat WHERE crabdat.cdcooper = aux_cdcooper NO-LOCK NO-ERROR.
    IF NOT AVAIL crabdat THEN
       DO:
           ASSIGN aux_dscritic = "Parametros Invalidos.".
           RETURN "NOK".

       END. /* END IF NOT AVAIL crabdat THEN */

    RUN sistema/generico/procedures/b1wgen0188.p PERSISTENT SET h-b1wgen0188.
    
    /* Calcula as parcelas do emprestimo */
    RUN calcula_parcelas_emprestimo 
        IN h-b1wgen0188 (INPUT aux_cdcooper,
                         INPUT 91,    /* par_cdagenci */
                         INPUT 999,   /* par_nrdcaixa */
                         INPUT 1,     /* par_cdoperad */
                         INPUT "TAA", /* par_nmdatela */
                         INPUT 4,     /* par_cdorigem */
                         INPUT aux_nrdconta,
                         INPUT aux_tpusucar, /* par_idseqttl */
                         INPUT crabdat.dtmvtolt,
                         INPUT aux_vlemprst,
                         INPUT aux_diapagto,
                         OUTPUT TABLE tt-parcelas-cpa,
                         OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0188.

    IF RETURN-VALUE <> "OK" THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.
           IF AVAIL tt-erro AND tt-erro.dscritic <> "" THEN
              ASSIGN aux_dscritic = tt-erro.dscritic.
           ELSE
              ASSIGN aux_dscritic = "Nao foi possivel concluir sua solicitacao." +
                                    "Dirija-se a um Posto de Atendimento".

           RETURN "NOK".

       END. /* END IF RETURN-VALUE <> "OK" THEN */

    FOR EACH tt-parcelas-cpa WHERE tt-parcelas-cpa.flgdispo = TRUE NO-LOCK:

        xDoc:CREATE-NODE(xRoot2,"PARCELAS","ELEMENT").
        xRoot:APPEND-CHILD(xRoot2).
        
        /* Numero da parcela */
        xDoc:CREATE-NODE(xField,"NRPAREPR","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-parcelas-cpa.nrparepr).
        xField:APPEND-CHILD(xText).

        /* Valor da parcela */
        xDoc:CREATE-NODE(xField,"VLPAREPR","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-parcelas-cpa.vlparepr,"zzz,zzz,zz9.99").
        xField:APPEND-CHILD(xText).

        /* Data de Vencimento */
        xDoc:CREATE-NODE(xField,"DTVENCTO","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-parcelas-cpa.dtvencto).
        xField:APPEND-CHILD(xText).

        /* Flag se a parcela estara disponivel para selecao */
        xDoc:CREATE-NODE(xField,"FLGDISPO","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-parcelas-cpa.flgdispo).
        xField:APPEND-CHILD(xText).

    END. /* END FOR EACH tt-parcelas-cpa NO-LOCK: */

    RETURN "OK".

END PROCEDURE.
/* Fim 47 - busca-parcelas-pre-aprovado */ 

PROCEDURE busca-extrato-pre-aprovado:

    DEF VAR aux_setlinha AS CHAR    FORMAT "x(200)"                  NO-UNDO.
    DEF VAR aux_conteudo AS CHAR                                     NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                     NO-UNDO.

    FIND crabdat WHERE crabdat.cdcooper = aux_cdcooper NO-LOCK NO-ERROR.
    IF NOT AVAIL crabdat THEN
       DO:
           ASSIGN aux_dscritic = "Parametros Invalidos.".
           RETURN "NOK".

       END. /* END IF RETURN-VALUE <> "OK" THEN */

    RUN sistema/generico/procedures/b1wgen0188.p PERSISTENT SET h-b1wgen0188.

    RUN imprime_previa_demonstrativo 
        IN h-b1wgen0188(INPUT aux_cdcooper,
                        INPUT 91,    /* par_cdagenci */
                        INPUT 999,   /* par_nrdcaixa */
                        INPUT 1,     /* par_cdoperad */
                        INPUT "TAA", /* par_nmdatela */
                        INPUT 4,     /* par_cdorigem */
                        INPUT aux_nrdconta,
                        INPUT aux_tpusucar, /* par_idseqttl */
                        INPUT crabdat.dtmvtolt,
                        INPUT 0,     /* par_nrctremp */
                        INPUT aux_vlemprst,
                        INPUT aux_txmensal,
                        INPUT aux_qtpreemp,
                        INPUT aux_vlpreemp,
                        INPUT aux_percetop,
                        INPUT aux_vltarifa,
                        INPUT aux_dtdpagto,
                        INPUT aux_vltaxiof,
                        INPUT aux_vltariof,
                        INPUT ?,
                        INPUT 0,
                        OUTPUT aux_nmarqimp,
                        OUTPUT TABLE tt-erro).
    
    DELETE PROCEDURE h-b1wgen0188.
         
    IF RETURN-VALUE <> "OK" THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.
           IF AVAIL tt-erro AND tt-erro.dscritic <> "" THEN
              ASSIGN aux_dscritic = tt-erro.dscritic.
           ELSE
              ASSIGN aux_dscritic = "Nao foi possivel concluir sua solicitacao." +
                                    "Dirija-se a um Posto de Atendimento".

           RETURN "NOK".

       END. /* END IF RETURN-VALUE <> "OK" THEN */
    
    /* Le o arquivo formatado */
    INPUT STREAM str_2 FROM VALUE(aux_nmarqimp) NO-ECHO.
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       IMPORT STREAM str_2 UNFORMATTED aux_setlinha.

       ASSIGN aux_conteudo = aux_conteudo + aux_setlinha.

       IF aux_setlinha = "" THEN
          ASSIGN aux_conteudo = aux_conteudo + CHR(13).

    END.   /*  Fim do DO WHILE TRUE  */ 
    INPUT STREAM str_2 CLOSE.

    /* Conteudo do relatorio */
    xDoc:CREATE-NODE(xField,"CONTEUDO","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_conteudo).
    xField:APPEND-CHILD(xText).

    RETURN "OK".

END PROCEDURE.
/* Fim 48 - busca-extrato-pre-aprovado */ 

PROCEDURE grava-dados-pre-aprovado:

    DEF VAR nov_nrctremp AS INTE                                     NO-UNDO.
    DEF VAR aux_flcartma    AS INTE                         NO-UNDO.
    DEF VAR aux_nrcpfrep    AS DECI                         NO-UNDO.
    DEF VAR aux_idastcjt    AS INTE                         NO-UNDO.
    DEF VAR aux_cdcritic    AS INTE                         NO-UNDO.

    FIND crabdat WHERE crabdat.cdcooper = aux_cdcooper NO-LOCK NO-ERROR.
    IF NOT AVAIL crabdat THEN
       DO:
           ASSIGN aux_dscritic = "Parametros Invalidos.".
           RETURN "NOK".

       END. /* END IF RETURN-VALUE <> "OK" THEN */

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
    
    /* Efetuar a chamada a rotina Oracle */ 
    RUN STORED-PROCEDURE pc_valid_repre_legal_trans
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT aux_cdcooper, /* Código da Cooperativa */
                                             INPUT aux_nrdconta, /* Número da Conta */
                                             INPUT 1,            /* Titular da Conta */
                                             INPUT 0,            
                                            OUTPUT 0,            /* Código da crítica */
                                            OUTPUT "").          /* Descrição da crítica */
    
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_valid_repre_legal_trans
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
    
    /* Busca possíveis erros */ 
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_valid_repre_legal_trans.pr_cdcritic 
                          WHEN pc_valid_repre_legal_trans.pr_cdcritic <> ?
           aux_dscritic = pc_valid_repre_legal_trans.pr_dscritic 
                          WHEN pc_valid_repre_legal_trans.pr_dscritic <> ?.
    
    IF  aux_cdcritic <> 0  OR
        aux_dscritic <> ""  THEN
        DO:
            IF  aux_dscritic = "" THEN
               ASSIGN aux_dscritic =  "Nao foi possivel verificar assinatura conjunta.".
    
            RETURN "NOK".
        END.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

    RUN STORED-PROCEDURE pc_verifica_rep_assinatura
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT aux_cdcooper, /* Cooperativa */
                                 INPUT aux_nrdconta, /* Nr. da conta */
                                 INPUT 1,   /* Sequencia de titular */
                                 INPUT 4,   /* Origem - TAA */
                                 OUTPUT 0,  /* Codigo 1 exige Ass. Conj. */
                                 OUTPUT 0,  /* CPF do Rep. Legal */
                                 OUTPUT "", /* Nome do Rep. Legal */
                                 OUTPUT 0,  /* Cartao Magnetico conjunta, 0 nao, 1 sim */
                                 OUTPUT 0,  /* Codigo do erro */
                                 OUTPUT ""). /* Descricao do erro */
    
    CLOSE STORED-PROC pc_verifica_rep_assinatura
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN aux_idastcjt = 0
           aux_cdcritic = 0
           aux_dscritic = ""           
           aux_flcartma = 0
           aux_nrcpfrep = 0
           aux_idastcjt = pc_verifica_rep_assinatura.pr_idastcjt
                              WHEN pc_verifica_rep_assinatura.pr_idastcjt <> ?
           aux_flcartma = pc_verifica_rep_assinatura.pr_flcartma
                              WHEN pc_verifica_rep_assinatura.pr_flcartma <> ?
           aux_nrcpfrep = pc_verifica_rep_assinatura.pr_nrcpfcgc
                              WHEN pc_verifica_rep_assinatura.pr_nrcpfcgc <> ?
           aux_cdcritic = pc_verifica_rep_assinatura.pr_cdcritic
                              WHEN pc_verifica_rep_assinatura.pr_cdcritic <> ?
           aux_dscritic = pc_verifica_rep_assinatura.pr_dscritic
                              WHEN pc_verifica_rep_assinatura.pr_dscritic <> ?.           
    
    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
        DO:
            IF  aux_dscritic = "" THEN
               ASSIGN aux_dscritic =  "Nao foi possivel verificar assinatura conjunta.".
    
            RETURN "NOK".
        END.

    IF  aux_idastcjt = 1 THEN
        DO:
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
            /*Procedure de criacao de transacao de credito pré-ap,rovado*/
            RUN STORED-PROCEDURE pc_cria_trans_pend_credito
            aux_handproc = PROC-HANDLE NO-ERROR
                                    (INPUT 91,           /* Codigo do PA */
                                     INPUT 900,          /* Numero do caixa */
                                     INPUT "996",        /* Operador */
                                     INPUT "TAA",        /* Nome da tela */
                                     INPUT 4,            /* Id origem */
                                     INPUT 1,            /* Titular */
                                     INPUT IF aux_flcartma = 1 THEN 0 ELSE aux_nrcpfrep, /* CPF do operador juridico */
                                     INPUT IF aux_flcartma = 1 THEN aux_nrcpfrep ELSE 0, /* CPF do representante legal */
                                     INPUT crapcop.cdcooper, /* Cooperativa do terminal */
                                     INPUT crapage.cdagenci, /* Agencia do terminal */
                                     INPUT craptfn.nrterfin, /* Numero do terminal */
                                     INPUT crapdat.dtmvtolt, /* Data de movimento */
                                     INPUT aux_cdcooper, /* Cooperativa */
                                     INPUT aux_nrdconta, /* Nr. da conta */
                                     INPUT aux_vlemprst, /* Valor do emprestimo */
                                     INPUT aux_qtpreemp, /* Numero de parcelas                     */
                                     INPUT aux_vlpreemp, /* Valor da parcela                       */
                                     INPUT aux_dtdpagto, /* Data de vencimento da primeira parcela */
                                     INPUT aux_percetop, /* Valor percentual do CET                */
                                     INPUT aux_vlrtarif, /* Valor da tarifa do emprestimo    */
                                     INPUT aux_txmensal, /* Valor da taxa mensal de juros    */
                                     INPUT aux_vltariof, /* Valor de IOF                     */
                                     INPUT aux_vltaxiof, /* Valor percentual do IOF          */
                                     INPUT aux_idastcjt, /* Indicador de Assinatura Conjunta */
                                     OUTPUT 0,  /* Codigo do erro */
                                     OUTPUT ""). /* Descricao do erro */
            
            CLOSE STORED-PROC pc_cria_trans_pend_credito
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.                

            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

            /* Busca possíveis erros */ 
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = ""
                   aux_cdcritic = pc_cria_trans_pend_credito.pr_cdcritic 
                                  WHEN pc_cria_trans_pend_credito.pr_cdcritic <> ?
                   aux_dscritic = pc_cria_trans_pend_credito.pr_dscritic 
                                  WHEN pc_cria_trans_pend_credito.pr_dscritic <> ?.
            
            IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
                DO:
                    IF  aux_dscritic = "" THEN
                       ASSIGN aux_dscritic =  "Nao foi possivel contratar o credito pre-aprovado.".
            
                    RETURN "NOK".
                END.

        END.
    ELSE
        DO:        
            RUN sistema/generico/procedures/b1wgen0188.p PERSISTENT SET h-b1wgen0188.
        
            RUN grava_dados IN h-b1wgen0188(INPUT aux_cdcooper,
                                            INPUT 91,    /* par_cdagenci */
                                            INPUT 999,   /* par_nrdcaixa */
                                            INPUT 1,     /* par_cdoperad */
                                            INPUT "TAA", /* par_nmdatela */
                                            INPUT 4,     /* par_cdorigem */
                                            INPUT aux_nrdconta,
                                            INPUT aux_tpusucar, /* par_idseqttl */
                                            INPUT crabdat.dtmvtolt,
                                            INPUT crabdat.dtmvtopr,
                                            INPUT aux_qtpreemp,
                                            INPUT aux_vlpreemp,
                                            INPUT aux_vlemprst,
                                            INPUT aux_dtdpagto,
                                            INPUT aux_percetop,
                                            INPUT crapcop.cdcooper,
                                            INPUT crapage.cdagenci,
                                            INPUT craptfn.nrterfin,
                                            INPUT 0,     /* par_nrcpfope */
                                            OUTPUT nov_nrctremp,
                                            OUTPUT TABLE tt-erro).
        
            DELETE PROCEDURE h-b1wgen0188.
                 
            IF RETURN-VALUE <> "OK" THEN
               DO:
                   FIND FIRST tt-erro NO-LOCK NO-ERROR.
                   IF AVAIL tt-erro AND tt-erro.dscritic <> "" THEN
                      ASSIGN aux_dscritic = tt-erro.dscritic.
                   ELSE
                      ASSIGN aux_dscritic = "Nao foi possivel concluir sua solicitacao." +
                                            "Dirija-se a um Posto de Atendimento".
        
                   RETURN "NOK".
        
               END. /* END IF RETURN-VALUE <> "OK" THEN */
        END.

    xDoc:CREATE-NODE(xField,"GRAVACAO","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"IDASTCJT","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_idastcjt).
    xField:APPEND-CHILD(xText).    

    RETURN "OK".

END PROCEDURE.
/* Fim 49 - grava-dados-pre-aprovado */ 

PROCEDURE obtem-taxas-pre-aprovado:

    DEF VAR aux_vlrtarif AS DECI                                     NO-UNDO.
    DEF VAR aux_percetop AS DECI                                     NO-UNDO.
    DEF VAR aux_vltaxiof AS DECI                                     NO-UNDO.
    DEF VAR aux_vltariof AS DECI                                     NO-UNDO.    
    DEF VAR aux_vlliquid AS DECI                                     NO-UNDO.

    FIND crabdat WHERE crabdat.cdcooper = aux_cdcooper NO-LOCK NO-ERROR.
    IF NOT AVAIL crabdat THEN
       DO:
           ASSIGN aux_dscritic = "Parametros Invalidos.".
           RETURN "NOK".

       END. /* END IF RETURN-VALUE <> "OK" THEN */

    RUN sistema/generico/procedures/b1wgen0188.p PERSISTENT SET h-b1wgen0188.

    RUN calcula_taxa_emprestimo IN h-b1wgen0188(INPUT aux_cdcooper,
                                                INPUT 91,    /* par_cdagenci */
                                                INPUT 999,   /* par_nrdcaixa */
                                                INPUT 1,     /* par_cdoperad */
                                                INPUT "TAA", /* par_nmdatela */
                                                INPUT 4,     /* par_cdorigem */
                                                INPUT aux_nrdconta,
                                                INPUT crabdat.dtmvtolt,
                                                INPUT aux_vlemprst,
                                                INPUT aux_vlparepr,
                                                INPUT aux_nrparepr,
                                                INPUT aux_dtvencto,
                                                OUTPUT aux_vlrtarif,
                                                OUTPUT aux_percetop,
                                                OUTPUT aux_vltaxiof,
                                                OUTPUT aux_vltariof,                                                
                                                OUTPUT aux_vlliquid,
                                                OUTPUT TABLE tt-erro).
    DELETE PROCEDURE h-b1wgen0188.
         
    IF RETURN-VALUE <> "OK" THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.
           IF AVAIL tt-erro AND tt-erro.dscritic <> "" THEN
              ASSIGN aux_dscritic = tt-erro.dscritic.
           ELSE
              ASSIGN aux_dscritic = "Nao foi possivel concluir sua solicitacao." +
                                    "Dirija-se a um Posto de Atendimento".

           RETURN "NOK".

       END. /* END IF RETURN-VALUE <> "OK" THEN */
    
    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLRTARIF","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_vlrtarif).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"PERCETOP","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_percetop).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLTAXIOF","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_vltaxiof).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLTARIOF","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_vltariof).
    xField:APPEND-CHILD(xText).
    
    /* ---------- */    
    xDoc:CREATE-NODE(xField,"VLLIQUID","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_vlliquid).
    xField:APPEND-CHILD(xText).

    RETURN "OK".

END PROCEDURE.
/* Fim 50 - obtem-taxas-pre-aprovado */ 

PROCEDURE calcula_data_vencimento:

    DEF INPUT  PARAM p-dtmvtolt         LIKE crapdat.dtmvtolt           NO-UNDO.
    DEF INPUT  PARAM p-de-campo         AS INTE                         NO-UNDO.
    DEF OUTPUT PARAM p-dtvencto         AS DATE                         NO-UNDO.
   
    DEF VAR aux_fatordia AS INTE                                        NO-UNDO.
    DEF VAR aux_fator    AS INTE                                        NO-UNDO.
    DEF VAR aux_dtvencto AS DATE                                        NO-UNDO.   

    DEF VAR aux_situacao AS INTE                                        NO-UNDO.
    DEF VAR aux_contador AS INTE                                        NO-UNDO.

    DEF VAR p-cod-erro   AS INTE                                        NO-UNDO.
    DEF VAR p-desc-erro  AS CHAR                                        NO-UNDO.
    

    /* 0 - Fora Ranger 
       1 - A Vencer 
       2 - Vencida       */
    ASSIGN aux_situacao = 0. 


    /* Calcular Fator do Dia */
    ASSIGN aux_fatordia = p-dtmvtolt - DATE("07/10/1997").
    
    IF aux_fatordia > 9999 THEN DO:
    
        IF ( aux_fatordia MODULO 9000 ) < 1000 THEN
            aux_fatordia = ( aux_fatordia MODULO 9000 )  + 9000.
        ELSE
            aux_fatordia = ( aux_fatordia MODULO 9000 ).
    
    END.


    /* Verifica se esta A Vencer  */
    aux_fator = aux_fatordia.
    
    DO aux_contador=0 TO 5500:
    
        IF p-de-campo = aux_fator THEN DO:
            aux_situacao = 1. /* A Vencer */
            LEAVE.
        END.
    
        IF aux_fator > 9999 THEN
            aux_fator = 1000.
        ELSE
            aux_fator = aux_fator + 1.
    
    END.

    /* Verifica se esta Vencido */
    aux_fator = aux_fatordia - 1.
    
    IF aux_fator < 1000 THEN
         aux_fator = aux_fator + 9000.
    
    IF aux_situacao = 0 THEN DO:
    
        DO aux_contador=0 TO 3000:
    
            IF p-de-campo = aux_fator THEN DO:
                aux_situacao = 2. /* Vencido */
                LEAVE.
            END.
    
            IF aux_fator < 1000 THEN
                aux_fator = aux_fator + 9000.
            ELSE
                aux_fator = aux_fator - 1.
    
        END.
    
    END.
    
    IF aux_situacao = 0  THEN DO:

        ASSIGN p-cod-erro  = 0           
               p-desc-erro = "Boleto fora do ranger permitido!".

        RETURN "NOK".
    END.
    ELSE
        IF aux_situacao = 1 THEN DO:  /* A Vencer */
            IF aux_fatordia > p-de-campo THEN
                ASSIGN aux_dtvencto = p-dtmvtolt + ( p-de-campo - 1000 + (9999 - aux_fatordia + 1 ) ).
            ELSE
                ASSIGN aux_dtvencto = p-dtmvtolt + ( p-de-campo - aux_fatordia).
            END.
        ELSE DO:   /* Vencido */
             IF aux_fatordia > p-de-campo THEN
                ASSIGN aux_dtvencto = p-dtmvtolt + ( p-de-campo - aux_fatordia).
             ELSE
                ASSIGN aux_dtvencto = p-dtmvtolt + ( p-de-campo - aux_fatordia - 9000 ).
        END.

    ASSIGN p-dtvencto = aux_dtvencto.

    RETURN "OK".
END.
/* Fim calcula_data_vencimento */


PROCEDURE busca_aplicacao_car:

    DEF INPUT PARAM par_cdcooper AS INTE                        NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS DECI                        NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                        NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-saldo-rdca.

    DEFINE VARIABLE aux_cdcritic AS INTEGER                     NO-UNDO.
    DEFINE VARIABLE aux_dscritic AS CHAR                        NO-UNDO.

    /* Variaveis para o XML */ 
    DEF VAR xDoc_ora            AS HANDLE   NO-UNDO.   
    DEF VAR xRoot_ora           AS HANDLE   NO-UNDO.  
    DEF VAR xRoot_ora2          AS HANDLE   NO-UNDO.  
    DEF VAR xField_ora          AS HANDLE   NO-UNDO. 
    DEF VAR xText_ora           AS HANDLE   NO-UNDO. 
    DEF VAR aux_cont_raiz   	AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont        	AS INTEGER  NO-UNDO. 
    DEF VAR ponteiro_xml_ora    AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req_ora         AS LONGCHAR NO-UNDO.	

    /*reinert*/
    /********NOVA CONSULTA APLICACOOES*********/
    /** Saldo das aplicacoes **/
    
    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc_ora.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot_ora.   /* Vai conter a tag raiz em diante */ 
    CREATE X-NODEREF  xRoot_ora2.  /* Vai conter a tag aplicacao em diante */ 
    CREATE X-NODEREF  xField_ora.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText_ora.   /* Vai conter o texto que existe dentro da tag xField_ora */ 
    
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} } 
    

    /* Efetuar a chamada a rotina Oracle */
    RUN STORED-PROCEDURE pc_busca_aplicacoes_car
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper     /* Código da Cooperativa*/
                                        ,INPUT "996"            /* Código do Operador*/
                                        ,INPUT "TAA"            /* Nome da Tela*/
                                        ,INPUT 4                /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA*/
                                        ,INPUT par_nrdconta     /* Número da Conta  */
                                        ,INPUT 1                /* Titular da Conta */
                                        ,INPUT 0                /* Número da Aplicação - Parâmetro Opcional*/
                                        ,INPUT 0                /* Código do Produto – Parâmetro Opcional */
                                        ,INPUT par_dtmvtolt     /* Data de Movimento*/
                                        ,INPUT 0                /* Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas) */
                                        ,INPUT 0                /* Identificador de Log (0 – Não / 1 – Sim) */
                                        ,OUTPUT ?               /* XML com informações de LOG*/
                                        ,OUTPUT 0               /* Código da crítica */
                                        ,OUTPUT "").            /* Descrição da crítica */

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_busca_aplicacoes_car
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }                                                             

    /* Busca possíveis erros */ 
	ASSIGN aux_cdcritic = 0
		   aux_dscritic = ""
		   aux_cdcritic = pc_busca_aplicacoes_car.pr_cdcritic 
						  WHEN pc_busca_aplicacoes_car.pr_cdcritic <> ?
		   aux_dscritic = pc_busca_aplicacoes_car.pr_dscritic 
						  WHEN pc_busca_aplicacoes_car.pr_dscritic <> ?.
	  
	IF aux_cdcritic <> 0 OR
	   aux_dscritic <> "" THEN
	  DO:
		 CREATE tt-erro.
		 ASSIGN tt-erro.cdcritic = aux_cdcritic
				tt-erro.dscritic = aux_dscritic.

		 RETURN "NOK".
	
	  END.

	EMPTY TEMP-TABLE tt-saldo-rdca.

    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req_ora = pc_busca_aplicacoes_car.pr_clobxmlc.


    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml_ora) = LENGTH(xml_req_ora) + 1. 
    PUT-STRING(ponteiro_xml_ora,1) = xml_req_ora. 
     
    xDoc_ora:LOAD("MEMPTR",ponteiro_xml_ora,FALSE). 
    xDoc_ora:GET-DOCUMENT-ELEMENT(xRoot_ora).
    
    DO  aux_cont_raiz = 1 TO xRoot_ora:NUM-CHILDREN: 
    
        xRoot_ora:GET-CHILD(xRoot_ora2,aux_cont_raiz).
    
        IF xRoot_ora2:SUBTYPE <> "ELEMENT"   THEN 
         NEXT. 
    
            IF xRoot_ora2:NUM-CHILDREN > 0 THEN
                CREATE tt-saldo-rdca.
    
            DO aux_cont = 1 TO xRoot_ora2:NUM-CHILDREN:
            
                xRoot_ora2:GET-CHILD(xField_ora,aux_cont).
                    
                IF xField_ora:SUBTYPE <> "ELEMENT" THEN 
                    NEXT. 
                
                xField_ora:GET-CHILD(xText_ora,1).            
    
                ASSIGN tt-saldo-rdca.dtmvtolt = DATE(xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "dtmvtolt"
                       tt-saldo-rdca.dtvencto = DATE(xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "dtvencto"
                       tt-saldo-rdca.nraplica = INT (xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "nraplica"
                       tt-saldo-rdca.dsaplica = xText_ora:NODE-VALUE WHEN xField_ora:NAME = "dsnomenc"
                       tt-saldo-rdca.idtipapl = xText_ora:NODE-VALUE WHEN xField_ora:NAME = "idtippro"
                       tt-saldo-rdca.sldresga = DECI(xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "vlsldrgt".
            END.            
    END.                

    SET-SIZE(ponteiro_xml_ora) = 0. 
 
    DELETE OBJECT xDoc_ora. 
    DELETE OBJECT xRoot_ora. 
    DELETE OBJECT xRoot_ora2. 
    DELETE OBJECT xField_ora. 
    DELETE OBJECT xText_ora.
                
    /*******FIM CONSULTA APLICACAOES**********/


END PROCEDURE.

PROCEDURE verifica_emprst_atraso:

    DEFINE VARIABLE aux_cdcritic AS INTEGER                           NO-UNDO.
    DEFINE VARIABLE aux_dscritic AS CHARACTER                         NO-UNDO.
    
    FIND crabdat WHERE crabdat.cdcooper = aux_cdcooper NO-LOCK NO-ERROR.
    IF NOT AVAIL crabdat THEN
    DO:
        ASSIGN aux_dscritic = "Parametros Invalidos.".
        RETURN "NOK".

    END. /* END IF RETURN-VALUE <> "OK" THEN */

    IF  NOT VALID-HANDLE(h-b1wgen0031) THEN
        RUN sistema/generico/procedures/b1wgen0031.p
            PERSISTENT SET h-b1wgen0031.

    RUN obtem-msg-credito-atraso IN h-b1wgen0031
        ( INPUT aux_cdcooper,
          INPUT 91,             /* nragenci */
          INPUT 999,            /* nrdcaixa */
          INPUT 1,              /* cdoperad */
          INPUT "TAA",          /* nmdatela */
          INPUT 4,              /* TAA      */
          INPUT "TAA",          /* cdprogra */
          INPUT aux_nrtransf,   /* nrdconta */
          INPUT 1,              /* idseqttl */
         OUTPUT aux_cdcritic,
         OUTPUT aux_dscritic).

    DELETE PROCEDURE h-b1wgen0031.
    
    IF   aux_dscritic <> ""   THEN
    DO:
         xDoc:CREATE-NODE(xField,"DSCRITIC","ELEMENT").
         xRoot:APPEND-CHILD(xField).

         xDoc:CREATE-NODE(xText,"","TEXT").
         xText:NODE-VALUE = aux_dscritic.
         xField:APPEND-CHILD(xText).
    END.

    IF aux_cdcritic <> 0 THEN
    DO:
        xDoc:CREATE-NODE(xField,"CDCRITIC","ELEMENT").
        xRoot:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(aux_cdcritic).
        xField:APPEND-CHILD(xText).
    END.

    RETURN "OK".

END PROCEDURE.
/* Fim verifica_emprst_atraso */ 

/* 53 - obtem-informacoes-comprovante */
PROCEDURE obtem-informacoes-comprovante:

    RUN sistema/generico/procedures/b1wgen9998.p PERSISTENT SET h-b1wgen9998.

    RUN obtem-sac-ouvidoria-coop IN h-b1wgen9998 (INPUT crapcop.cdcooper,
                                                  INPUT 91,    /* par_cdagenci */
                                                  INPUT 999,   /* par_nrdcaixa */
                                                  INPUT "996", /* par_cdoperad */
                                                 OUTPUT aux_nrtelsac,
                                                 OUTPUT aux_nrtelouv,
                                                 OUTPUT TABLE tt-erro).
    DELETE PROCEDURE h-b1wgen9998.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro  THEN
                aux_dscritic = tt-erro.dscritic.
            ELSE
                aux_dscritic = "Problemas ao obter informacoes do comprovante".

            RETURN "NOK".
        END.  

    xDoc:CREATE-NODE(xField,"NRTELSAC","ELEMENT").
    xRoot:APPEND-CHILD(xField).
     
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_nrtelsac).
    xField:APPEND-CHILD(xText).

    xDoc:CREATE-NODE(xField,"NRTELOUV","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_nrtelouv).
    xField:APPEND-CHILD(xText).

    RETURN "OK".

END PROCEDURE.
/* Fim 53 - obtem-informacoes-comprovante */

PROCEDURE lanca-tarifa-extrato:

    /* Lança tarifa de extrato (utilizado para opção de Extrato EM TELA) */
    RUN sistema/generico/procedures/b1wgen0001.p PERSISTENT SET h-b1wgen0001.

    RUN gera-tarifa-extrato IN h-b1wgen0001  (INPUT aux_cdcooper, 
                                              INPUT 91,            /* PAC */
                                              INPUT 999,           /* Caixa */
                                              INPUT "996",         /* Operador */
                                              INPUT "TAA",         /* Tela */
                                              INPUT 4,             /* Origem - TAA */
                                              INPUT aux_nrdconta, 
                                              INPUT 1,             /* Titularidade */
                                              INPUT aux_dtiniext, 
                                              INPUT 1,             /* Ind. Processo - 1 On-Line */
                                              INPUT YES,           /* Tarifar */ 
                                              INPUT YES,           /* LOG */
                                              INPUT crapcop.cdcooper, /* Coop do TAA */
                                              INPUT crapage.cdagenci, /* PAC do TAA */ 
                                              INPUT craptfn.nrterfin, /* Nro do TAA */
                                             OUTPUT TABLE tt-msg-confirma,
                                             OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0001.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  AVAIL tt-erro  THEN
                aux_dscritic = STRING(aux_cdcooper) + " - " + STRING(aux_nrdconta) + " - " + tt-erro.dscritic.

            RETURN "NOK".
        END.

    RETURN "OK".
END PROCEDURE.
/* Fim 54 - lanca-tarifa-extrato */

PROCEDURE busca-beneficiarios-inss:

    DEF VAR aux_dsxmlout        AS CHAR     NO-UNDO.
    DEF VAR aux_cdcritic        AS INTE     NO-UNDO.

    /* Variaveis para o XML */ 
    DEF VAR xDoc_ora            AS HANDLE   NO-UNDO.   
    DEF VAR xRoot_ora           AS HANDLE   NO-UNDO.  
    DEF VAR xRoot_ora2          AS HANDLE   NO-UNDO.  
    DEF VAR xField_ora          AS HANDLE   NO-UNDO. 
    DEF VAR xText_ora           AS HANDLE   NO-UNDO. 
    DEF VAR aux_cont_raiz   	AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont        	AS INTEGER  NO-UNDO. 
    DEF VAR ponteiro_xml_ora    AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req_ora         AS LONGCHAR NO-UNDO.

    EMPTY TEMP-TABLE tt-dcb.
    
    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc_ora.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot_ora.   /* Vai conter a tag raiz em diante */ 
    CREATE X-NODEREF  xRoot_ora2.  /* Vai conter a tag beneficiarios em diante */ 
    CREATE X-NODEREF  xField_ora.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText_ora.   /* Vai conter o texto que existe dentro da tag xField_ora */ 

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_carrega_dados_beneficio_car 
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT aux_cdcooper,
                          INPUT aux_nrdconta,
                          INPUT aux_nrrecben,
                          INPUT aux_dtcompet,
                          OUTPUT ?,
                          OUTPUT 0,
                          OUTPUT "").

    CLOSE STORED-PROC pc_carrega_dados_beneficio_car 
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

    ASSIGN aux_dsxmlout = ""
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_carrega_dados_beneficio_car.pr_cdcritic
                          WHEN pc_carrega_dados_beneficio_car.pr_cdcritic <> ?
           aux_dscritic = pc_carrega_dados_beneficio_car.pr_dscritic
                          WHEN pc_carrega_dados_beneficio_car.pr_dscritic <> ?
           aux_dsxmlout = pc_carrega_dados_beneficio_car.pr_clobxmlc
                          WHEN pc_carrega_dados_beneficio_car.pr_clobxmlc <> ?.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN DO: 

        IF  aux_dscritic = "" THEN DO:
            FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                       NO-LOCK NO-ERROR.

            IF  AVAIL crapcri THEN
                ASSIGN aux_dscritic = crapcri.dscritic.
            ELSE
                ASSIGN aux_dscritic =  "Nao foi possivel buscar os beneficiarios".
        END.
        
    END.

    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req_ora = aux_dsxmlout.

    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml_ora) = LENGTH(xml_req_ora) + 1. 
    PUT-STRING(ponteiro_xml_ora,1) = xml_req_ora. 
     
    xDoc_ora:LOAD("MEMPTR",ponteiro_xml_ora,FALSE). 
    xDoc_ora:GET-DOCUMENT-ELEMENT(xRoot_ora).
    
    DO  aux_cont_raiz = 1 TO xRoot_ora:NUM-CHILDREN: 
    
        xRoot_ora:GET-CHILD(xRoot_ora2,aux_cont_raiz).
    
        IF xRoot_ora2:SUBTYPE <> "ELEMENT"   THEN 
         NEXT.    
    
            IF xRoot_ora2:NUM-CHILDREN > 0 THEN
                CREATE tt-dcb.

            DO aux_cont = 1 TO xRoot_ora2:NUM-CHILDREN:
            
                xRoot_ora2:GET-CHILD(xField_ora,aux_cont).
                    
                IF xField_ora:SUBTYPE <> "ELEMENT" THEN 
                    NEXT. 
                
                xField_ora:GET-CHILD(xText_ora,1).            
    
                ASSIGN tt-dcb.nrrecben = DECI(xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "nrrecben"
                       tt-dcb.dtcompet = xText_ora:NODE-VALUE WHEN xField_ora:NAME = "dtcompet"
                       tt-dcb.nmbenefi = xText_ora:NODE-VALUE WHEN xField_ora:NAME = "nmbenefi"
                       tt-dcb.vlliquid = DECI(xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "vlliquido".
            END.            
    END.                

    SET-SIZE(ponteiro_xml_ora) = 0. 
 
    DELETE OBJECT xDoc_ora. 
    DELETE OBJECT xRoot_ora. 
    DELETE OBJECT xRoot_ora2. 
    DELETE OBJECT xField_ora. 
    DELETE OBJECT xText_ora.
                
    /* Se retornou crítica */
    IF  aux_dscritic <> ""   THEN
        DO:
             xDoc:CREATE-NODE(xField,"DSCRITIC","ELEMENT").
             xRoot:APPEND-CHILD(xField).
        
             xDoc:CREATE-NODE(xText,"","TEXT").
             xText:NODE-VALUE = aux_dscritic.
             xField:APPEND-CHILD(xText).
        END.


    FOR EACH tt-dcb:    

        xDoc:CREATE-NODE(xRoot2,"BENEFICIARIOS","ELEMENT").
        xRoot:APPEND-CHILD(xRoot2).
        
        /* ---------- */
        xDoc:CREATE-NODE(xField,"NRRECBEN","ELEMENT").
        xRoot2:APPEND-CHILD(xField).
    
        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-dcb.nrrecben).
        xField:APPEND-CHILD(xText).
    
        /* ---------- */
        xDoc:CREATE-NODE(xField,"DTCOMPET","ELEMENT").
        xRoot2:APPEND-CHILD(xField).
    
        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-dcb.dtcompet).
        xField:APPEND-CHILD(xText).
    
        /* ---------- */
        xDoc:CREATE-NODE(xField,"NMBENEFI","ELEMENT").
        xRoot2:APPEND-CHILD(xField).
    
        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-dcb.nmbenefi).
        xField:APPEND-CHILD(xText).
    
        /* ---------- */
        xDoc:CREATE-NODE(xField,"VLLIQUID","ELEMENT").
        xRoot2:APPEND-CHILD(xField).
    
        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-dcb.vlliquid).
        xField:APPEND-CHILD(xText).

    END.

    RETURN "OK".

END PROCEDURE.
/* Fim 55 - busca-beneficiarios-inss */

PROCEDURE busca_demonstrativo_inss:

    DEF VAR aux_dsxmlout        AS CHAR     NO-UNDO.
    DEF VAR aux_cdcritic        AS INTE     NO-UNDO.

    /* Variaveis para o XML */ 
    DEF VAR xDoc_ora            AS HANDLE   NO-UNDO.   
    DEF VAR xRoot_ora           AS HANDLE   NO-UNDO.  
    DEF VAR xRoot_ora2          AS HANDLE   NO-UNDO.  
    DEF VAR xRoot_ora3          AS HANDLE   NO-UNDO.
    DEF VAR xField_ora          AS HANDLE   NO-UNDO. 
    DEF VAR xText_ora           AS HANDLE   NO-UNDO. 
    DEF VAR aux_cont_raiz   	AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont        	AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont2       	AS INTEGER  NO-UNDO. 
    DEF VAR ponteiro_xml_ora    AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req_ora         AS LONGCHAR NO-UNDO.

    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc_ora.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot_ora.   /* Vai conter a tag raiz em diante */ 
    CREATE X-NODEREF  xRoot_ora2.  /* Vai conter a tag beneficiario/lancamentos em diante */ 
    CREATE X-NODEREF  xRoot_ora3.  /* Vai conter a tag lancamentos em diante */
    CREATE X-NODEREF  xField_ora.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText_ora.   /* Vai conter o texto que existe dentro da tag xField_ora */ 

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_carrega_demonst_benef 
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT aux_cdcooper,
                          INPUT aux_nrdconta,
                          INPUT aux_nrrecben,
                          INPUT aux_dtcompet,
                          OUTPUT "",
                          OUTPUT 0,
                          OUTPUT "").
                                                     
    CLOSE STORED-PROC pc_carrega_demonst_benef
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
    
    ASSIGN aux_dsxmlout = ""
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_carrega_demonst_benef.pr_cdcritic
                          WHEN pc_carrega_demonst_benef.pr_cdcritic <> ?
           aux_dscritic = pc_carrega_demonst_benef.pr_dscritic
                          WHEN pc_carrega_demonst_benef.pr_dscritic <> ?
           aux_dsxmlout = pc_carrega_demonst_benef.pr_clobxmlc
                          WHEN pc_carrega_demonst_benef.pr_clobxmlc <> ?.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN DO: 
    
        IF  aux_dscritic = "" THEN DO:
            FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                       NO-LOCK NO-ERROR.
    
            IF  AVAIL crapcri THEN
                ASSIGN aux_dscritic = crapcri.dscritic.
            ELSE
                ASSIGN aux_dscritic =  "Nao foi possivel apresentar o demonstrativo".
        END.
   
    END.

    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req_ora = aux_dsxmlout.

    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml_ora) = LENGTH(xml_req_ora) + 1. 
    PUT-STRING(ponteiro_xml_ora,1) = xml_req_ora. 
     
    xDoc_ora:LOAD("MEMPTR",ponteiro_xml_ora,FALSE). 
    xDoc_ora:GET-DOCUMENT-ELEMENT(xRoot_ora).
    
    DO  aux_cont_raiz = 1 TO xRoot_ora:NUM-CHILDREN: 
    
        xRoot_ora:GET-CHILD(xRoot_ora2,aux_cont_raiz).
    
        IF xRoot_ora2:SUBTYPE <> "ELEMENT"   THEN 
         NEXT.                    

        IF  xRoot_ora2:NAME = "beneficiario" THEN
            DO:
                CREATE tt-demonst-dcb.

                DO aux_cont = 1 TO xRoot_ora2:NUM-CHILDREN:
                
                    xRoot_ora2:GET-CHILD(xField_ora,aux_cont).
                        
                    IF xField_ora:SUBTYPE <> "ELEMENT" THEN 
                        NEXT. 
                    
                    xField_ora:GET-CHILD(xText_ora,1).            
        
                    ASSIGN tt-demonst-dcb.nmemisso = xText_ora:NODE-VALUE WHEN xField_ora:NAME = "nmemissor"
                           tt-demonst-dcb.cnpjemis = DECI(xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "nrcnpj_emissor"
                           tt-demonst-dcb.nmbenefi = xText_ora:NODE-VALUE WHEN xField_ora:NAME = "nmbenefi"
                           tt-demonst-dcb.dtcompet = xText_ora:NODE-VALUE WHEN xField_ora:NAME = "dtcompet"
                           tt-demonst-dcb.nrrecben = DECI(xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "nrrecben"
                           tt-demonst-dcb.nrnitins = DECI(xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "nrnitins"
                           tt-demonst-dcb.cdorgins = INTE(xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "cdorgins"
                           tt-demonst-dcb.nmrescop = xText_ora:NODE-VALUE WHEN xField_ora:NAME = "nmrescop"
                           tt-demonst-dcb.vlliquid = DECI(xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "vlliquido".
                END.            
            END.
        ELSE
            DO:
                DO aux_cont = 1 TO xRoot_ora2:NUM-CHILDREN:
            
                    xRoot_ora2:GET-CHILD(xRoot_ora3,aux_cont).
                                       
                    IF xRoot_ora3:SUBTYPE <> "ELEMENT" THEN
                       NEXT.                       
    
                    IF xRoot_ora3:NUM-CHILDREN > 0 THEN
                        CREATE tt-demonst-ldcb.

                    DO aux_cont2 = 1 TO xRoot_ora3:NUM-CHILDREN:
    
                        xRoot_ora3:GET-CHILD(xField_ora,aux_cont2).
                        
                        IF xField_ora:SUBTYPE <> "ELEMENT" THEN
                           NEXT.
                        
                        xField_ora:GET-CHILD(xText_ora,1).
    
                        ASSIGN tt-demonst-ldcb.cdrubric = INTE(xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "cdrubric"
                               tt-demonst-ldcb.dsrubric = xText_ora:NODE-VALUE WHEN xField_ora:NAME = "dsrubric"
                               tt-demonst-ldcb.vlrubric = DECI(xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "vlrubric".
                    END.
                    
                END.

            END.
    END.                

    SET-SIZE(ponteiro_xml_ora) = 0. 
 
    DELETE OBJECT xDoc_ora. 
    DELETE OBJECT xRoot_ora. 
    DELETE OBJECT xRoot_ora2. 
    DELETE OBJECT xRoot_ora3. 
    DELETE OBJECT xField_ora. 
    DELETE OBJECT xText_ora.
                
    /* Se retornou crítica */
    IF  aux_dscritic <> ""   THEN
        DO:
             xDoc:CREATE-NODE(xField,"DSCRITIC","ELEMENT").
             xRoot:APPEND-CHILD(xField).
        
             xDoc:CREATE-NODE(xText,"","TEXT").
             xText:NODE-VALUE = aux_dscritic.
             xField:APPEND-CHILD(xText).
        END.

    FOR EACH tt-demonst-dcb:    

        xDoc:CREATE-NODE(xRoot2,"BENEFICIARIOS","ELEMENT").
        xRoot:APPEND-CHILD(xRoot2).

        /* ---------- */
        xDoc:CREATE-NODE(xField,"NMEMISSOR","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-demonst-dcb.nmemisso).
        xField:APPEND-CHILD(xText).

        /* ---------- */
        xDoc:CREATE-NODE(xField,"CNPJEMIS","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-demonst-dcb.cnpjemis).
        xField:APPEND-CHILD(xText).

        /* ---------- */
        xDoc:CREATE-NODE(xField,"NMBENEFI","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-demonst-dcb.nmbenefi).
        xField:APPEND-CHILD(xText).        
        
        /* ---------- */
        xDoc:CREATE-NODE(xField,"NRRECBEN","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-demonst-dcb.nrrecben).
        xField:APPEND-CHILD(xText).

        /* ---------- */
        xDoc:CREATE-NODE(xField,"DTCOMPET","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-demonst-dcb.dtcompet).
        xField:APPEND-CHILD(xText).

        /* ---------- */
        xDoc:CREATE-NODE(xField,"NRNITINS","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-demonst-dcb.nrnitins).
        xField:APPEND-CHILD(xText).

        /* ---------- */
        xDoc:CREATE-NODE(xField,"CDORGINS","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-demonst-dcb.cdorgins).
        xField:APPEND-CHILD(xText).

        /* ---------- */
        xDoc:CREATE-NODE(xField,"VLLIQUID","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-demonst-dcb.vlliquid).
        xField:APPEND-CHILD(xText).

        /* ---------- */
        xDoc:CREATE-NODE(xField,"NMRESCOP","ELEMENT").
        xRoot2:APPEND-CHILD(xField).

        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-demonst-dcb.nmrescop).
        xField:APPEND-CHILD(xText).

        FOR EACH tt-demonst-ldcb:    

            xDoc:CREATE-NODE(xRoot2,"LANCAMENTOS","ELEMENT").
            xRoot:APPEND-CHILD(xRoot2).

            /* ---------- */
            xDoc:CREATE-NODE(xField,"CDRUBRIC","ELEMENT").
            xRoot2:APPEND-CHILD(xField).
    
            xDoc:CREATE-NODE(xText,"","TEXT").
            xText:NODE-VALUE = STRING(tt-demonst-ldcb.cdrubric).
            xField:APPEND-CHILD(xText).
    
            /* ---------- */
            xDoc:CREATE-NODE(xField,"DSRUBRIC","ELEMENT").
            xRoot2:APPEND-CHILD(xField).
    
            xDoc:CREATE-NODE(xText,"","TEXT").
            xText:NODE-VALUE = STRING(tt-demonst-ldcb.dsrubric).
            xField:APPEND-CHILD(xText).
    
            /* ---------- */
            xDoc:CREATE-NODE(xField,"VLRUBRIC","ELEMENT").
            xRoot2:APPEND-CHILD(xField).
    
            xDoc:CREATE-NODE(xText,"","TEXT").
            xText:NODE-VALUE = STRING(tt-demonst-ldcb.vlrubric).
            xField:APPEND-CHILD(xText).        

        END.

    END.

END PROCEDURE.
/* Fim 56 - busca_demonstrativo_inss */

PROCEDURE busca_numero_conta:

    DEFINE INPUT  PARAM par_nrcrcard AS DEC                           NO-UNDO.
    DEFINE OUTPUT PARAM par_nrdconta AS INT                           NO-UNDO.
    DEFINE OUTPUT PARAM par_dscritic AS CHAR                          NO-UNDO.

    IF NOT VALID-HANDLE(h-b1wgen0025) THEN
       RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.
                                                                                     
    RUN busca_numero_conta IN h-b1wgen0025(INPUT par_nrcrcard,
                                           OUTPUT par_nrdconta,
                                           OUTPUT par_dscritic).
                                                   
    IF RETURN-VALUE <> "OK" THEN
       DO:
           IF VALID-HANDLE(h-b1wgen0025) THEN
              DELETE PROCEDURE h-b1wgen0025.
       
           IF par_dscritic = "" THEN
              ASSIGN par_dscritic = "Erro de leitura.".
              
           RETURN "NOK".
       END.
            
    IF VALID-HANDLE(h-b1wgen0025) THEN
       DELETE PROCEDURE h-b1wgen0025.
            
    RETURN "OK".

END PROCEDURE.



/* 57 - verifica-banner */
PROCEDURE verifica-banner:

    DEFINE VARIABLE aux_flgdinss    AS LOGICAL  INIT NO         NO-UNDO.
    DEFINE VARIABLE aux_flgbinss    AS LOGICAL  INIT NO         NO-UNDO.
    DEFINE VARIABLE aux_flgdobnr    AS LOGICAL  INIT NO         NO-UNDO.
    DEFINE VARIABLE aux_idbanner    AS CHAR                     NO-UNDO.
    
    DEFINE VARIABLE tmp_nrdconta    AS INTEGER                  NO-UNDO.
    
    ASSIGN tmp_nrdconta = 0.
    
    IF aux_nrdconta <> 0 AND aux_nrdconta <> ? THEN
        ASSIGN tmp_nrdconta = aux_nrdconta.
    ELSE 
        IF par_nrdconta <> 0 AND par_nrdconta <> ? THEN
            ASSIGN tmp_nrdconta = par_nrdconta.
    
    IF tmp_nrdconta = 0 THEN
    DO:
        ASSIGN aux_dscritic = "Erro ao buscar o numero da conta".
        RETURN "NOK".
    END.
        
    ASSIGN aux_idbanner = "".

    /* Verifica exibição banner Prova de Vida INSS */
    RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.

    RUN verifica_prova_vida_inss IN h-b1wgen0025( INPUT aux_cdcooper,
                                                  INPUT tmp_nrdconta,
                                                 OUTPUT aux_flgdinss,
                                                 OUTPUT aux_flgbinss,
                                                 OUTPUT aux_dscritic).

    DELETE PROCEDURE h-b1wgen0025.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  AVAILABLE tt-erro  THEN
                aux_dscritic = tt-erro.dscritic.
            ELSE
                aux_dscritic = "Problemas ao verificar exibicao banner".
    
            RETURN "NOK".
        END.

    /* Verifica exibição banner Pré-Aprovado */
    RUN sistema/generico/procedures/b1wgen0188.p PERSISTENT SET h-b1wgen0188.

    RUN verifica_mostra_banner_taa IN h-b1wgen0188 (INPUT aux_cdcooper, 
                                                    INPUT 91,    /* par_cdagenci */
                                                    INPUT 999,   /* par_nrdcaixa */
                                                    INPUT 1,     /* par_cdoperad */
                                                    INPUT "TAA", /* par_nmdatela */
                                                    INPUT 4,     /* par_cdorigem */
                                                    INPUT crapdat.dtmvtolt,
                                                    INPUT tmp_nrdconta,
                                                    INPUT aux_tpusucar, /* par_idseqttl */
                                                    INPUT 0,     /* par_nrcpfope */
                                                    OUTPUT aux_flgdobnr,
                                                    OUTPUT TABLE tt-erro).
    DELETE PROCEDURE h-b1wgen0188.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro  THEN
                aux_dscritic = tt-erro.dscritic.
            ELSE
                aux_dscritic = "Problemas ao verificar exibicao banner".

            RETURN "NOK".
        END.
    
    IF  aux_flgdinss  THEN /* (Prova de vida) */
        DO:
            /* Quando houver Prova de Vida, será o único banner a ser 
               exibido devido à sua natureza crítica como alerta */
            ASSIGN aux_idbanner = "1".
        END.
    ELSE
        DO:
            IF  aux_flgdobnr THEN /* (Pré-Aprovado) */
                DO:
                    IF  aux_idbanner = "" THEN
                        ASSIGN aux_idbanner = "2".
                    ELSE
                        ASSIGN aux_idbanner = aux_idbanner + "," + "2".
                END.
        END.

    IF  aux_idbanner <> "" THEN
        DO:
            /* ---------- */
            xDoc:CREATE-NODE(xField,"IDBANNER","ELEMENT").
            xRoot:APPEND-CHILD(xField).
            
            xDoc:CREATE-NODE(xText,"","TEXT").
            xText:NODE-VALUE = aux_idbanner.
            xField:APPEND-CHILD(xText).
        END.

    RETURN "OK".

END PROCEDURE.
/* Fim 57 - verifica-banner */

/* 58 - altera-telefone-sms-debaut */
PROCEDURE altera-telefone-sms-debaut:

    RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

    RUN sms-cooperado-debaut IN h-b1wgen0092 (INPUT crapcop.cdcooper,
                                              INPUT 91,             /* par_cdagenci */
                                              INPUT 999,            /* par_nrdcaixa */
                                              INPUT "996",          /* par_cdoperad */
                                              INPUT "TAA",          /* par_nmdatela */
                                              INPUT 4,              /* par_idorigem */
                                              INPUT "A",            /* par_cddopcao */
                                              INPUT aux_nrdconta,
                                              INPUT aux_tpusucar,   /* par_idseqttl */
                                              INPUT TRUE,           /* par_flgerlog */
                                              INPUT crapdat.dtmvtolt,
                                              INPUT TRUE,           /* par_flgacsms */
                                              INPUT-OUTPUT aux_nrdddtfc,
                                              INPUT-OUTPUT aux_nrtelefo,
                                                    OUTPUT aux_dsmsgsms,
                                             OUTPUT TABLE tt-erro).
    DELETE PROCEDURE h-b1wgen0092.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro  THEN
                aux_dscritic = tt-erro.dscritic.
            ELSE
                aux_dscritic = "Problemas ao obter telefone para envio de SMS.".

            RETURN "NOK".
        END.  

    xDoc:CREATE-NODE(xField,"DSMSGSMS","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_dsmsgsms).
    xField:APPEND-CHILD(xText).

    RETURN "OK".

END PROCEDURE.
/* Fim 58 - altera-telefone-sms-debaut */

/* 59 - obtem-telefone-sms-debaut */
PROCEDURE obtem-telefone-sms-debaut:

    IF  NOT VALID-HANDLE(h-b1wgen0092) THEN
        RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

    RUN sms-cooperado-debaut IN h-b1wgen0092 (INPUT crapcop.cdcooper,
                                              INPUT 91,           /* par_cdagenci */
                                              INPUT 999,          /* par_nrdcaixa */
                                              INPUT "996",        /* par_cdoperad */
                                              INPUT "TAA",        /* par_nmdatela */
                                              INPUT 4,            /* par_idorigem */
                                              INPUT "C",          /* par_cddopcao */
                                              INPUT aux_nrdconta,
                                              INPUT aux_tpusucar, /* par_idseqttl */
                                              INPUT FALSE,        /* par_flgerlog */
                                              INPUT crapdat.dtmvtolt,
                                              INPUT FALSE,        /* par_flgacsms */
                                              INPUT-OUTPUT aux_nrdddtfc,
                                              INPUT-OUTPUT aux_nrtelefo,
                                                    OUTPUT aux_dsmsgsms,
                                             OUTPUT TABLE tt-erro).
    DELETE PROCEDURE h-b1wgen0092.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro  THEN
                aux_dscritic = tt-erro.dscritic.
            ELSE
                aux_dscritic = "Problemas ao obter telefone para envio de SMS.".

            RETURN "NOK".
        END.  

    xDoc:CREATE-NODE(xField,"NRDDD","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_nrdddtfc).
    xField:APPEND-CHILD(xText).

    xDoc:CREATE-NODE(xField,"NRTELEFO","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_nrtelefo).
    xField:APPEND-CHILD(xText).

    xDoc:CREATE-NODE(xField,"DSMSGSMS","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_dsmsgsms).
    xField:APPEND-CHILD(xText).

    RETURN "OK".

END PROCEDURE.
/* Fim 59 - obtem-telefone-sms-debaut */

/* 60 - exclui-telefone-sms-debaut */
PROCEDURE exclui-telefone-sms-debaut:

    RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

    RUN sms-cooperado-debaut IN h-b1wgen0092 (INPUT crapcop.cdcooper,
                                              INPUT 91,             /* par_cdagenci */
                                              INPUT 999,            /* par_nrdcaixa */
                                              INPUT "996",          /* par_cdoperad */
                                              INPUT "TAA",          /* par_nmdatela */
                                              INPUT 4,              /* par_idorigem */
                                              INPUT "E",            /* par_cddopcao */
                                              INPUT aux_nrdconta,
                                              INPUT aux_tpusucar,   /* par_idseqttl */
                                              INPUT TRUE,           /* par_flgerlog */
                                              INPUT crapdat.dtmvtolt,
                                              INPUT FALSE,          /* par_flgacsms */
                                              INPUT-OUTPUT aux_nrdddtfc,
                                              INPUT-OUTPUT aux_nrtelefo,
                                                    OUTPUT aux_dsmsgsms,
                                             OUTPUT TABLE tt-erro).
    DELETE PROCEDURE h-b1wgen0092.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro  THEN
                aux_dscritic = tt-erro.dscritic.
            ELSE
                aux_dscritic = "Problemas ao obter telefone para envio de SMS.".

            RETURN "NOK".
        END.  

    RETURN "OK".

END PROCEDURE.
/* Fim 60 - exclui-telefone-sms-debaut */

/* 61 - busca-motivos-exclusao-debaut */
PROCEDURE busca-motivos-exclusao-debaut:

    DEFINE VARIABLE aux_flgdinss    AS LOGICAL  INIT NO         NO-UNDO.
    DEFINE VARIABLE aux_flgbinss    AS LOGICAL  INIT NO         NO-UNDO.
    DEFINE VARIABLE aux_flgdobnr    AS LOGICAL  INIT NO         NO-UNDO.
    DEFINE VARIABLE aux_idbanner    AS CHAR                     NO-UNDO.

    IF  NOT VALID-HANDLE(h-b1wgen0092) THEN
        RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.
        
    RUN obtem-motivos-cancelamento-debaut IN h-b1wgen0092(INPUT aux_cdcooper,
                                                          INPUT 91,    /* par_cdagenci */
                                                          INPUT 999,   /* par_nrdcaixa */
                                                          INPUT 1,     /* par_cdoperad */
                                                          INPUT "TAA", /* par_nmdatela */
                                                          INPUT 4,     /* par_cdorigem */
                                                          INPUT aux_nrdconta,
                                                          INPUT crapdat.dtmvtolt,
                                                         OUTPUT TABLE tt-motivos-cancel-debaut,
                                                         OUTPUT TABLE tt-erro).
    IF  VALID-HANDLE(h-b1wgen0092) THEN
        DELETE PROCEDURE h-b1wgen0092.
                     
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  AVAILABLE tt-erro  THEN
                aux_dscritic = tt-erro.dscritic.
            ELSE
                aux_dscritic = "Erro na obtencao dos motivos de cancelamento (DEBAUT)".
    
            RETURN "NOK".
        END.
        
    FOR EACH tt-motivos-cancel-debaut NO-LOCK:
    
        xDoc:CREATE-NODE(xRoot2,"MOTIVOS","ELEMENT").
        xRoot:APPEND-CHILD(xRoot2).
        /* ---------- */
        xDoc:CREATE-NODE(xField,"IDMOTIVO","ELEMENT").
        xRoot2:APPEND-CHILD(xField).
        
        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(tt-motivos-cancel-debaut.idmotivo).
        xField:APPEND-CHILD(xText).
        
        /* ---------- */
        xDoc:CREATE-NODE(xField,"DSMOTIVO","ELEMENT").
        xRoot2:APPEND-CHILD(xField).
        
        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = TRIM(tt-motivos-cancel-debaut.dsmotivo).
        xField:APPEND-CHILD(xText).
                                 
    END. /** Fim do FOR EACH tt-motivos-cancel-debaut **/

    RETURN "OK".

END PROCEDURE.
/* Fim 61 - busca-motivos-exclusao-debaut */

/* 62 - alterar-autorizacao-debito */
PROCEDURE alterar-autorizacao-debito:

    RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

    RUN altera_autorizacao IN h-b1wgen0092 (INPUT aux_cdcooper,
                                            INPUT 0,  /* cdagenci */
                                            INPUT 0, /* nrdcaixa */
                                            INPUT "996", /* cdoperad */
                                            INPUT "TAA", /* nmdatela */
                                            INPUT 4, /* idorigem */
                                            INPUT aux_nrdconta,
                                            INPUT crapdat.dtmvtolt,
                                            INPUT aux_cdrefere,
                                            INPUT aux_cdhistor,
                                            INPUT aux_vlrmaxdb,
                                            INPUT "",                                                
                                            INPUT aux_tpusucar,
                                            INPUT TRUE,
                                           OUTPUT TABLE tt-erro).
    DELETE PROCEDURE h-b1wgen0092.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro  THEN
                aux_dscritic = tt-erro.dscritic.
            ELSE
                aux_dscritic = "Problemas na BO 92".

            RETURN "NOK".
        END.  

    xDoc:CREATE-NODE(xField,"ALTERACAO","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    RETURN "OK".

END PROCEDURE.
/* Fim 62 - alterar-autorizacao-debito */

/*Inicio 63 - calcula_valor_titulo*/
PROCEDURE calcula_valor_titulo:

    DEF VAR aux_vlfatura                AS DECI         NO-UNDO.
	DEF VAR aux_vlrjuros                AS DECI         NO-UNDO.
	DEF VAR aux_vlrmulta                AS DECI         NO-UNDO.
	DEF VAR aux_fltitven                AS INTE         NO-UNDO.
    DEF VAR aux_dtvencto                AS CHAR         NO-UNDO.	
    DEF VAR aux_flblqval                AS INTE         NO-UNDO.
													   
    DEF VAR aux_tppesbenf               AS CHAR         NO-UNDO.
    DEF VAR aux_inpesbnf                AS INTE         NO-UNDO.
    DEF VAR aux_nrdocbnf                AS DECI         NO-UNDO.
    DEF VAR aux_nmbenefi                AS CHAR         NO-UNDO.
    DEF VAR aux_cdctrlcs                AS CHAR         NO-UNDO.
	DEF VAR aux_des_erro                AS CHAR         NO-UNDO.
	DEF VAR aux_dscritic                AS CHAR         NO-UNDO.
	
	/*REMOVER*/
	DEFINE VARIABLE ponteiro_xml AS MEMPTR      NO-UNDO.
	
	/* Variaveis para o XML */ 
    DEF VAR xDoc_ora            AS HANDLE   NO-UNDO.   
    DEF VAR xRoot_ora           AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2_ora          AS HANDLE   NO-UNDO.  
    DEF VAR xField_ora          AS HANDLE   NO-UNDO. 
    DEF VAR xText_ora           AS HANDLE   NO-UNDO. 
    DEF VAR aux_cont_raiz   	AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont        	AS INTEGER  NO-UNDO. 
    DEF VAR ponteiro_xml_ora    AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req_ora         AS LONGCHAR NO-UNDO.
	
    /* Inicializando objetos para leitura do XML */ 
	CREATE X-DOCUMENT xDoc_ora.    /* Vai conter o XML completo */ 
	CREATE X-NODEREF  xRoot_ora.   /* Vai conter a tag DADOS em diante */ 
	CREATE X-NODEREF  xRoot2_ora.  /* Vai conter a tag INF em diante */ 
	CREATE X-NODEREF  xField_ora.  /* Vai conter os campos dentro da tag INF */ 
	CREATE X-NODEREF  xText_ora.   /* Vai conter o texto que existe dentro da tag xField */ 
	
	{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

  RUN STORED-PROCEDURE pc_consultar_valor_titulo
      aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT aux_cdcooper       /* Cooperativa             */
                         ,INPUT aux_nrdconta       /* Número da conta         */
                         ,INPUT 91                 /* Agencia                 */
                         ,INPUT 900       /* Número do caixa         */
                         ,INPUT 1                  /* Titular da conta        */
                         ,INPUT 0                  /* Indicador origem Mobile */
                         ,INPUT aux_titulo1
                         ,INPUT aux_titulo2
                         ,INPUT aux_titulo3
                         ,INPUT aux_titulo4
                         ,INPUT aux_titulo5
                         ,INPUT aux_codigo_barras /* Codigo de Barras */
                         ,INPUT "996"      /* Código do operador */
                         ,INPUT 4                 /* idorigem */ 
                         /* OUTPUT */
                         ,OUTPUT 0       /* pr_nrdocbenf    -- Documento do beneficiário emitente */
                         ,OUTPUT ""      /* pr_tppesbenf    -- Tipo de pessoa beneficiaria */
                         ,OUTPUT ""      /* pr_dsbenefic    -- Descriçao do beneficiário emitente */
                         ,OUTPUT 0       /* pr_vlrtitulo    -- Valor do título */
                         ,OUTPUT 0       /* pr_vlrjuros     -- Valor dos Juros */
                         ,OUTPUT 0       /* pr_vlrmulta	    -- Valor da multa */
                         ,OUTPUT 0       /* pr_vlrdescto	  -- Valor do desconto */
                         ,OUTPUT ""      /* pr_nrctrlcs     -- Numero do controle da consulta */
                         ,OUTPUT 0       /* pr_flblq_valor  -- Flag para bloquear o valor de pagamento */
                         ,OUTPUT 0       /* pr_fltitven     -- Flag indicador de titulo vencido */
                         ,OUTPUT ""      /* pr_dtvencto  Márcio Mouts -RITM0011951*/					 						 
                         ,OUTPUT ""      /* pr_des_erro     -- Indicador erro OK/NOK */
                         ,OUTPUT 0       /* pr_cdcritic     -- Código do erro  */
                         ,OUTPUT "").    /* pr_dscritic     -- Descricao do erro  */
    
  CLOSE STORED-PROC pc_consultar_valor_titulo aux_statproc = PROC-STATUS
        WHERE PROC-HANDLE = aux_handproc.
  
	/*RUN STORED-PROCEDURE pc_retorna_vlr_tit_vencto
	  aux_handproc = PROC-HANDLE NO-ERROR
						 (INPUT aux_cdcooper,
						  INPUT aux_nrdconta,
						  INPUT 1,
						  INPUT 63,
						  INPUT 1,
						  INPUT aux_titulo1,
						  INPUT aux_titulo2,
						  INPUT aux_titulo3,
						  INPUT aux_titulo4,
						  INPUT aux_titulo5,
						  INPUT aux_codigo_barras,
						  OUTPUT 0,
						  OUTPUT 0,
						  OUTPUT 0,
						  OUTPUT 0,
						  OUTPUT "",
						  OUTPUT "").
	
	/* Fechar o procedimento para buscarmos o resultado */ 
	CLOSE STORED-PROC pc_retorna_vlr_tit_vencto
		   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
	*/
	
	{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
	
	/* Busca possíveis erros */ 
	ASSIGN aux_des_erro = ""
           aux_dscritic = ""
           aux_vlfatura = 0
           aux_vlrjuros = 0
           aux_vlrmulta = 0
           aux_fltitven = 0
		   aux_dtvencto = ""		   
           aux_flblqval = 0.
  ASSIGN aux_tppesbenf = ""
         aux_nrdocbnf = 0
         aux_nmbenefi = ""
         aux_cdctrlcs = "".
  ASSIGN aux_vlfatura = pc_consultar_valor_titulo.pr_vlrtitulo
                        WHEN pc_consultar_valor_titulo.pr_vlrtitulo <> ?        
         aux_vlrjuros = pc_consultar_valor_titulo.pr_vlrjuros
                        WHEN pc_consultar_valor_titulo.pr_vlrjuros <> ?
         aux_vlrmulta = pc_consultar_valor_titulo.pr_vlrmulta
                        WHEN pc_consultar_valor_titulo.pr_vlrmulta <> ?
         aux_fltitven = pc_consultar_valor_titulo.pr_fltitven
                        WHEN pc_consultar_valor_titulo.pr_fltitven <> ?
         aux_dtvencto = pc_consultar_valor_titulo.pr_dtvencto
                        WHEN pc_consultar_valor_titulo.pr_dtvencto <> ?
         aux_flblqval = pc_consultar_valor_titulo.pr_flblq_valor
                        WHEN pc_consultar_valor_titulo.pr_flblq_valor <> ?.
  ASSIGN aux_tppesbenf = pc_consultar_valor_titulo.pr_tppesbenf
                        WHEN pc_consultar_valor_titulo.pr_tppesbenf <> ?
         aux_nrdocbnf = pc_consultar_valor_titulo.pr_nrdocbenf
                        WHEN pc_consultar_valor_titulo.pr_nrdocbenf <> ?
         aux_nmbenefi = pc_consultar_valor_titulo.pr_dsbenefic
                        WHEN pc_consultar_valor_titulo.pr_dsbenefic <> ?
         aux_cdctrlcs = pc_consultar_valor_titulo.pr_cdctrlcs
                        WHEN pc_consultar_valor_titulo.pr_cdctrlcs <> ?               
         aux_des_erro = pc_consultar_valor_titulo.pr_des_erro
                        WHEN pc_consultar_valor_titulo.pr_des_erro <> ?
         aux_dscritic = pc_consultar_valor_titulo.pr_dscritic
                        WHEN pc_consultar_valor_titulo.pr_dscritic <> ?.
  
	/*ASSIGN aux_des_erro = ""
           aux_dscritic = ""
           aux_vlfatura = 0
           aux_vlrjuros = 0
           aux_vlrmulta = 0
           aux_fltitven = 0
           aux_vlfatura = pc_retorna_vlr_tit_vencto.pr_vlfatura
                          WHEN pc_retorna_vlr_tit_vencto.pr_vlfatura <> ?        
           aux_vlrjuros = pc_retorna_vlr_tit_vencto.pr_vlrjuros
                          WHEN pc_retorna_vlr_tit_vencto.pr_vlrjuros <> ?
           aux_vlrmulta = pc_retorna_vlr_tit_vencto.pr_vlrmulta
                          WHEN pc_retorna_vlr_tit_vencto.pr_vlrmulta <> ?
           aux_fltitven = pc_retorna_vlr_tit_vencto.pr_fltitven
                          WHEN pc_retorna_vlr_tit_vencto.pr_fltitven <> ?
           aux_des_erro = pc_retorna_vlr_tit_vencto.pr_des_erro
                          WHEN pc_retorna_vlr_tit_vencto.pr_des_erro <> ?
           aux_dscritic = pc_retorna_vlr_tit_vencto.pr_dscritic
                          WHEN pc_retorna_vlr_tit_vencto.pr_dscritic <> ?.*/
	
	
	/*---------------*/
    xDoc:CREATE-NODE(xField,"VLFATURA","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_vlfatura,'zzz,zzz,z99.99').
    xField:APPEND-CHILD(xText).
	
    /*---------------*/
    xDoc:CREATE-NODE(xField,"VLRJUROS","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_vlrjuros).
    xField:APPEND-CHILD(xText).
	
    /*---------------*/
    xDoc:CREATE-NODE(xField,"VLRMULTA","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_vlrmulta).
    xField:APPEND-CHILD(xText).

    /*---------------*/
    xDoc:CREATE-NODE(xField,"FLTITVEN","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_fltitven).
    xField:APPEND-CHILD(xText).

    /*---------------*/
    xDoc:CREATE-NODE(xField,"FLBLQVAL","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_flblqval).
    xField:APPEND-CHILD(xText).

    /*---------------*/
    IF aux_tppesbenf = 'F' THEN
      aux_inpesbnf = 1.  
    ELSE
      aux_inpesbnf = 2.  
    
    xDoc:CREATE-NODE(xField,"INPESBNF","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_inpesbnf).
    xField:APPEND-CHILD(xText). 
    
    /*---------------*/    
    xDoc:CREATE-NODE(xField,"NRDOCBNF","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_nrdocbnf).
    xField:APPEND-CHILD(xText). 
    
    /*---------------*/    
    
    IF aux_nmbenefi <> ?  AND 
       aux_nmbenefi <> "" THEN
    DO:   
      xDoc:CREATE-NODE(xField,"NMBENEFI","ELEMENT").
      xRoot:APPEND-CHILD(xField).
    
      xDoc:CREATE-NODE(xText,"","TEXT").
      xText:NODE-VALUE = STRING(aux_nmbenefi).
      xField:APPEND-CHILD(xText).
    END.

    /*---------------*/             
    IF aux_cdctrlcs <> ?  AND 
       aux_cdctrlcs <> "" THEN
    DO: 
      xDoc:CREATE-NODE(xField,"NRCRLNPC","ELEMENT").
      xRoot:APPEND-CHILD(xField).

      xDoc:CREATE-NODE(xText,"","TEXT").
      xText:NODE-VALUE = STRING(aux_cdctrlcs).
      xField:APPEND-CHILD(xText).
    END.

    /*---------------*/
    xDoc:CREATE-NODE(xField,"DES_ERRO","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_des_erro).
    xField:APPEND-CHILD(xText).	
	
    IF TRIM(aux_dscritic) <> "" AND 
	   aux_des_erro <> "OK" THEN
	   DO:
	      /*---------------*/
 		  xDoc:CREATE-NODE(xField,"DSCRITIC","ELEMENT").
		  xRoot:APPEND-CHILD(xField).
		
		  xDoc:CREATE-NODE(xText,"","TEXT").
	      xText:NODE-VALUE = STRING(aux_dscritic).
		  xField:APPEND-CHILD(xText).
	   END.
    
    RETURN "OK".

END PROCEDURE.

/*64 - Consulta de lançamentos Futuros*/
PROCEDURE lancamentos-futuros:
   DEFINE VARIABLE aux_vlldeb    AS DECIMAL                     NO-UNDO.
   DEFINE VARIABLE aux_vllcre    AS DECIMAL                     NO-UNDO.
/* LANCAMENTOS FUTUROS */
    RUN sistema/generico/procedures/b1wgen0003.p PERSISTENT SET h-b1wgen0003.

    /* SE FOR INCLUSO NOVO PARAMETRO, 
    O PROGRAMA programa tempo_execucao_taa.p DEVE SER AJUSTADO! */
    RUN consulta-lancto-car IN h-b1wgen0003(INPUT aux_cdcooper,
                                            INPUT 91,
                                            INPUT 999,
                                            INPUT "996",
                                            INPUT aux_nrdconta,
                                            INPUT 4,
                                            INPUT 1,
                                            INPUT "TAL",
                                            INPUT 1,
                                            INPUT DATE(aux_dtiniext),  /* DTINIPER */
                                            INPUT DATE(aux_dtfimext),  /* DTFIMPER */
                                            INPUT "", /* INDEBCRE */
                                           OUTPUT TABLE tt-totais-futuros, 
                                           OUTPUT TABLE tt-erro,
                                           OUTPUT TABLE tt-lancamento_futuro).                                                  
    
    DELETE PROCEDURE h-b1wgen0003.

    FIND FIRST tt-erro NO-LOCK NO-ERROR.

    IF  AVAILABLE tt-erro  THEN
        DO:
            aux_dscritic = tt-erro.dscritic.
            RETURN "NOK".
        END.

    FIND FIRST tt-totais-futuros NO-LOCK NO-ERROR.
    IF  NOT AVAILABLE tt-totais-futuros  THEN
        DO:
            aux_dscritic = "Lançamentos não encontrados.".
            RETURN "NOK".
        END.

    FOR EACH tt-lancamento_futuro NO-LOCK
             BY tt-lancamento_futuro.dtmvtolt:

    /* ---------- */
    xDoc:CREATE-NODE(xField,"DTMVTOLT","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(tt-lancamento_futuro.dtmvtolt).
    xField:APPEND-CHILD(xText).
    /* ---------- */
    xDoc:CREATE-NODE(xField,"DSHISTOR","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(tt-lancamento_futuro.dshistor).
    xField:APPEND-CHILD(xText).

    /* ----------*/
    xDoc:CREATE-NODE(xField,"NRDOCMTO","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(tt-lancamento_futuro.nrdocmto).
    xField:APPEND-CHILD(xText).

    /* ---------- */
    xDoc:CREATE-NODE(xField,"INDEBCRE","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(tt-lancamento_futuro.indebcre).
    xField:APPEND-CHILD(xText).
    
    /* ---------- */
    xDoc:CREATE-NODE(xField,"VLLANMTO","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(tt-lancamento_futuro.vllanmto).
    xField:APPEND-CHILD(xText).
    
    END.
    
    /* ---------- */
    xDoc:CREATE-NODE(xField,"vllautom","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(tt-totais-futuros.vllautom).
    xField:APPEND-CHILD(xText).
    
    /* ---------- */
    xDoc:CREATE-NODE(xField,"vllaudeb","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(tt-totais-futuros.vllaudeb).
    xField:APPEND-CHILD(xText).
	
	  /* ---------- */
    xDoc:CREATE-NODE(xField,"vllaucre","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(tt-totais-futuros.vllaucre).
    xField:APPEND-CHILD(xText).
       
      
    RETURN "OK".
END PROCEDURE.
/*Fim 63 - calcula_valor_titulo*/

/* 65 - atualizacao-telefone */
PROCEDURE atualizacao-telefone:

    DEF VAR aux_msgatcad AS CHAR                                       NO-UNDO.
    DEF VAR aux_chavealt AS CHAR                                       NO-UNDO.
    DEF VAR aux_msgrvcad AS CHAR                                       NO-UNDO.
    DEF VAR aux_tpatlcad AS INTE                                       NO-UNDO.

    RUN sistema/generico/procedures/b1wgen0070.p PERSISTENT SET h-b1wgen0070.

    RUN validar-telefone IN h-b1wgen0070
                        (INPUT aux_cdcooper,
                         INPUT 91,             /** PAC      **/
                         INPUT 999,            /** Caixa    **/
                         INPUT "996",          /** Operador **/
                         INPUT "TAA",          /** Tela     **/
                         INPUT 4,              /** Origem   **/
                         INPUT aux_nrdconta,
                         INPUT 1,              /** Seq Titular  **/
                         INPUT "I",
                         INPUT TO-ROWID(""),
                         INPUT aux_tptelefo,
                         INPUT aux_nrdddtfc,
                         INPUT aux_nrtelefo,
                         INPUT 0,              /** Ramal     **/
                         INPUT "",             /** Setor     **/
                         INPUT "",             /** Contato   **/
                         INPUT 0,              /** Operadora **/
                         INPUT TRUE,
                         INPUT 0,     /** Conta replicadora **/
                        OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN DO:

        DELETE PROCEDURE h-b1wgen0070.

        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE
            aux_dscritic = "Problemas na BO 70 (1)".

        RETURN "NOK".
    END.


    /** SE DEU SUCESSO NA VALIDACAO, SEGUE COM A GRAVACAO DO TELEFONE **/
    RUN gerenciar-telefone IN h-b1wgen0070
                          (INPUT aux_cdcooper,
                           INPUT 91,             /** PAC          **/
                           INPUT 999,            /** Caixa        **/
                           INPUT "996",          /** Operador     **/
                           INPUT "TAA",          /** Tela         **/
                           INPUT 4,              /** Origem       **/
                           INPUT aux_nrdconta,
                           INPUT 1,              /** Seq. Titular **/
                           INPUT "I",
                           INPUT aux_dtmvtolt,
                           INPUT TO-ROWID(""),
                           INPUT aux_tptelefo,
                           INPUT aux_nrdddtfc,
                           INPUT aux_nrtelefo,
                           INPUT 0,              /** Ramal        **/
                           INPUT "",             /** Setor        **/
                           INPUT "",             /** Contato      **/
                           INPUT 0,              /** Operadora Cel**/
                           INPUT "T",            /** Sis.Alteracao (A=Ayllos, I=Internet, P=Progrid, T=TAA, C=Caixa Online) **/
                           INPUT TRUE,           /** Logar        **/
                           INPUT 1,              /** Situacao     **/
                           INPUT 1,              /** Origem  (1-Cooperado/2-Cooperativa/3-Terceiros) **/
                          OUTPUT aux_tpatlcad,
                          OUTPUT aux_msgatcad,
                          OUTPUT aux_chavealt,
                          OUTPUT aux_msgrvcad,
                          OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN DO:

        DELETE PROCEDURE h-b1wgen0070.

        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF  AVAILABLE tt-erro  THEN
            aux_dscritic = tt-erro.dscritic.
        ELSE
            aux_dscritic = "Problemas na BO 70 (2)".

        RETURN "NOK".
    END.

    xDoc:CREATE-NODE(xField,"ALTERACAO","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    RETURN "OK".

END PROCEDURE.
/* Fim 65 - atualizacao-telefone */

/* 66 - verifica-atualizacao-telefone */
PROCEDURE verifica-atualizacao-telefone:

    DEF VAR aux_atualiza    AS CHAR             NO-UNDO.
    DEF VAR aux_nrdofone    AS CHAR             NO-UNDO.
    DEF VAR aux_cdcritic    AS INTEGER          NO-UNDO.
    DEF VAR aux_dscritic    AS CHAR             NO-UNDO.
    DEF VAR aux_qtmeatel    AS INTE             NO-UNDO.

   { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_verifica_atualiz_fone
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT aux_cdcooper, /* Cooperativa */
                                 INPUT aux_nrdconta, /* Nr. da conta */
                                 INPUT 1,    /* Sequencia de titular */
                                 OUTPUT 0,   /* cdcritic */
                                 OUTPUT "",  /* dscritic */
                                 OUTPUT "",  /* Atualiza SIM/NAO */
                                 OUTPUT "",  /* Nr do Fone       */
                                 OUTPUT 0).  /* Qtde meses Atualizacao */

    CLOSE STORED-PROC pc_verifica_atualiz_fone
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_atualiza = ""
           aux_nrdofone = ""
           aux_qtmeatel = 0
           aux_atualiza = pc_verifica_atualiz_fone.pr_atualiza
                              WHEN pc_verifica_atualiz_fone.pr_atualiza <> ?
           aux_nrdofone = pc_verifica_atualiz_fone.pr_dsnrfone
                              WHEN pc_verifica_atualiz_fone.pr_dsnrfone <> ?
           aux_cdcritic = pc_verifica_atualiz_fone.pr_cdcritic
                              WHEN pc_verifica_atualiz_fone.pr_cdcritic <> ?
           aux_dscritic = pc_verifica_atualiz_fone.pr_dscritic
                              WHEN pc_verifica_atualiz_fone.pr_dscritic <> ?
           aux_qtmeatel = pc_verifica_atualiz_fone.pr_qtmeatel
                              WHEN pc_verifica_atualiz_fone.pr_qtmeatel <> ?
                              .

    IF  aux_cdcritic <> 0
    OR  aux_dscritic <> ""  THEN DO:
        IF  aux_dscritic = "" THEN
            ASSIGN aux_dscritic = "Nao foi possivel verificar atualizacao " +
                                  "telefo
                                  ne".
            RETURN "NOK".
        END.

    /** OBS.: AQUI, QUANDO A STRING ESTA VAZIA, OCORRE ERRO NO XML
              LA NO TAA. ATRIBUIDO "FONE" PARA NAO SER NULO/BRANCO.
              TRATAR TAMBEM ONDE SERA CHAMADA A PROCEDURE */
    IF aux_nrdofone = "" THEN
        aux_nrdofone = "FONE".

    xDoc:CREATE-NODE(xField,"ATUALIZA","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_atualiza).
    xField:APPEND-CHILD(xText).

    xDoc:CREATE-NODE(xField,"NRTELEFO","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_nrdofone).
    xField:APPEND-CHILD(xText).

    RETURN "OK".

END PROCEDURE.
/* Fim 66 - verifica-atualizacao-telefone */

/* 67 - atualizacao-data-telefone */
PROCEDURE atualizacao-data-telefone:

    DEF VAR aux_cdcritic    AS INTEGER          NO-UNDO.
    DEF VAR aux_dscritic    AS CHAR             NO-UNDO.

   { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_atualiz_data_manut_fone
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT aux_cdcooper, /* Cooperativa */
                                 INPUT aux_nrdconta, /* Nr. da conta */
                                 OUTPUT 0,   /* cdcritic */
                                 OUTPUT ""). /* dscritic */

    CLOSE STORED-PROC pc_atualiz_data_manut_fone
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_atualiz_data_manut_fone.pr_cdcritic
                              WHEN pc_atualiz_data_manut_fone.pr_cdcritic <> ?
           aux_dscritic = pc_atualiz_data_manut_fone.pr_dscritic
                              WHEN pc_atualiz_data_manut_fone.pr_dscritic <> ?.

    IF  aux_cdcritic <> 0
    OR  aux_dscritic <> ""  THEN DO:
        IF  aux_dscritic = "" THEN
            ASSIGN aux_dscritic = "Nao foi possivel efetuar atualizacao " +
                                  "data telefone".
            RETURN "NOK".
        END.

    xDoc:CREATE-NODE(xField,"ATUALIZA","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).


    RETURN "OK".

END PROCEDURE.
/* Fim 67 - atualizacao-data-telefone */

/*Operacao 68 - verifica_opcao_recarga*/
PROCEDURE verifica_opcao_recarga:

  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

	RUN STORED-PROCEDURE pc_situacao_canal_recarga
	  aux_handproc = PROC-HANDLE NO-ERROR
						 (INPUT aux_cdcooper, /* Cooperativa*/
						  INPUT 4,            /* Id origem (4-TAA)*/
						  OUTPUT 0,           /* Flag situacao recarga (0-INATIVO/1-ATIVO) */
						  OUTPUT 0,           /* Código da crítica.*/
						  OUTPUT "").         /* Desc. da crítica */
	
	/* Fechar o procedimento para buscarmos o resultado */ 
	CLOSE STORED-PROC pc_situacao_canal_recarga
		   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
	
	{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
	
	/* Busca parametros retornados */ 
	ASSIGN aux_flgsitrc = 0
           aux_dscritic = ""
           aux_flgsitrc = pc_situacao_canal_recarga.pr_flgsitrc
                          WHEN pc_situacao_canal_recarga.pr_flgsitrc <> ?
           aux_dscritic = pc_situacao_canal_recarga.pr_dscritic
                          WHEN pc_situacao_canal_recarga.pr_dscritic <> ?.
	
  IF aux_dscritic <> "" THEN
    RETURN "NOK".
    
  /* ---------- */
  xDoc:CREATE-NODE(xField,"FLGSITRC","ELEMENT").
  xRoot:APPEND-CHILD(xField).
  
  xDoc:CREATE-NODE(xText,"","TEXT").
  xText:NODE-VALUE = STRING(aux_flgsitrc).
  xField:APPEND-CHILD(xText).
  
END PROCEDURE.
/* Fim 68 - verifica_opcao_recarga*/

PROCEDURE obtem_favoritos_recarga:

  DEF VAR aux_dsxmlout        AS CHAR     NO-UNDO.

  /* Variaveis para o XML */ 
  DEF VAR xDoc_ora            AS HANDLE   NO-UNDO.   
  DEF VAR xRoot_ora           AS HANDLE   NO-UNDO.  
  DEF VAR xRoot_ora2          AS HANDLE   NO-UNDO.  
  DEF VAR xField_ora          AS HANDLE   NO-UNDO. 
  DEF VAR xText_ora           AS HANDLE   NO-UNDO. 
  DEF VAR aux_cont_raiz   	  AS INTEGER  NO-UNDO. 
  DEF VAR aux_cont        	  AS INTEGER  NO-UNDO. 
  DEF VAR ponteiro_xml_ora    AS MEMPTR   NO-UNDO. 
  DEF VAR xml_req_ora         AS LONGCHAR NO-UNDO.

  /* Inicializando objetos para leitura do XML */ 
  CREATE X-DOCUMENT xDoc_ora.    /* Vai conter o XML completo */ 
  CREATE X-NODEREF  xRoot_ora.   /* Vai conter a tag raiz em diante */ 
  CREATE X-NODEREF  xRoot_ora2.  /* Vai conter a tag favorito em diante */ 
  CREATE X-NODEREF  xField_ora.  /* Vai conter os campos dentro da tag INF */ 
  CREATE X-NODEREF  xText_ora.   /* Vai conter o texto que existe dentro da tag xField_ora */ 

  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

	RUN STORED-PROCEDURE pc_obtem_favoritos_recarga
	  aux_handproc = PROC-HANDLE NO-ERROR
						 (INPUT aux_cdcooper, /* Cooperativa*/
						  INPUT aux_nrdconta, /* Nr. da conta*/
						  OUTPUT ?,           /* CLOB com os favoritos */
						  OUTPUT 0,           /* Código da crítica.*/
						  OUTPUT "").         /* Desc. da crítica */
	
	/* Fechar o procedimento para buscarmos o resultado */ 
	CLOSE STORED-PROC pc_obtem_favoritos_recarga
		   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
	
	{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
	
  ASSIGN aux_dsxmlout = ""
         aux_dscritic = ""
         aux_dscritic = pc_obtem_favoritos_recarga.pr_dscritic
                        WHEN pc_obtem_favoritos_recarga.pr_dscritic <> ?
         aux_dsxmlout = pc_obtem_favoritos_recarga.pr_telfavor
                        WHEN pc_obtem_favoritos_recarga.pr_telfavor <> ?.
  
  /* Buscar o XML na tabela de retorno da procedure Progress */ 
  ASSIGN xml_req_ora = aux_dsxmlout.

  /* Efetuar a leitura do XML*/ 
  SET-SIZE(ponteiro_xml_ora) = LENGTH(xml_req_ora) + 1. 
  PUT-STRING(ponteiro_xml_ora,1) = xml_req_ora. 
   
  xDoc_ora:LOAD("MEMPTR",ponteiro_xml_ora,FALSE). 
  xDoc_ora:GET-DOCUMENT-ELEMENT(xRoot_ora).
  
  DO  aux_cont_raiz = 1 TO xRoot_ora:NUM-CHILDREN: 
  
      xRoot_ora:GET-CHILD(xRoot_ora2,aux_cont_raiz).
  
      IF xRoot_ora2:SUBTYPE <> "ELEMENT"   THEN 
       NEXT.                    

      IF  xRoot_ora2:NAME = "FAVORITO" THEN
          DO:
              CREATE tt-favoritos-recarga.

              DO aux_cont = 1 TO xRoot_ora2:NUM-CHILDREN:
              
                  xRoot_ora2:GET-CHILD(xField_ora,aux_cont).
                      
                  IF xField_ora:SUBTYPE <> "ELEMENT" THEN 
                      NEXT. 
                  
                  xField_ora:GET-CHILD(xText_ora,1).            
      
                  ASSIGN tt-favoritos-recarga.nrddd     = INTE(xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "nrddd"
                         tt-favoritos-recarga.nrcelular = DECI(xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "nrcelular"
                         tt-favoritos-recarga.nmcontato =      xText_ora:NODE-VALUE  WHEN xField_ora:NAME = "nmcontato"
                         tt-favoritos-recarga.cdseqfav  = DECI(xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "cdseq_favorito".
              END.            
          END.
  END.                

  SET-SIZE(ponteiro_xml_ora) = 0. 

  DELETE OBJECT xDoc_ora. 
  DELETE OBJECT xRoot_ora. 
  DELETE OBJECT xRoot_ora2. 
  DELETE OBJECT xField_ora. 
  DELETE OBJECT xText_ora.
              
  /* Se retornou crítica */
  IF  aux_dscritic <> ""   THEN
      DO:
           xDoc:CREATE-NODE(xField,"DSCRITIC","ELEMENT").
           xRoot:APPEND-CHILD(xField).
      
           xDoc:CREATE-NODE(xText,"","TEXT").
           xText:NODE-VALUE = aux_dscritic.
           xField:APPEND-CHILD(xText).
      END.

  FOR EACH tt-favoritos-recarga:    
          
      xDoc:CREATE-NODE(xRoot2,"FAVORITO","ELEMENT").
      xRoot:APPEND-CHILD(xRoot2).

      /* ---------- */
      xDoc:CREATE-NODE(xField,"NRDDD","ELEMENT").
      xRoot2:APPEND-CHILD(xField).

      xDoc:CREATE-NODE(xText,"","TEXT").
      xText:NODE-VALUE = STRING(tt-favoritos-recarga.nrddd).
      xField:APPEND-CHILD(xText).
      
      /* ---------- */
      xDoc:CREATE-NODE(xField,"NRCELULAR","ELEMENT").
      xRoot2:APPEND-CHILD(xField).

      xDoc:CREATE-NODE(xText,"","TEXT").
      xText:NODE-VALUE = STRING(tt-favoritos-recarga.nrcelular).
      xField:APPEND-CHILD(xText).        

      /* ---------- */
      xDoc:CREATE-NODE(xField,"NMCONTATO","ELEMENT").
      xRoot2:APPEND-CHILD(xField).

      xDoc:CREATE-NODE(xText,"","TEXT").
      xText:NODE-VALUE = tt-favoritos-recarga.nmcontato.
      xField:APPEND-CHILD(xText).
      
      /* ---------- */
      xDoc:CREATE-NODE(xField,"CDSEQFAV","ELEMENT").
      xRoot2:APPEND-CHILD(xField).

      xDoc:CREATE-NODE(xText,"","TEXT").
      xText:NODE-VALUE = STRING(tt-favoritos-recarga.cdseqfav).
      xField:APPEND-CHILD(xText).        
      
  END.

END PROCEDURE.

PROCEDURE obtem_operadoras_recarga:

  DEF VAR aux_dsxmlout        AS CHAR     NO-UNDO.

  /* Variaveis para o XML */ 
  DEF VAR xDoc_ora            AS HANDLE   NO-UNDO.   
  DEF VAR xRoot_ora           AS HANDLE   NO-UNDO.  
  DEF VAR xRoot_ora2          AS HANDLE   NO-UNDO.  
  DEF VAR xField_ora          AS HANDLE   NO-UNDO. 
  DEF VAR xText_ora           AS HANDLE   NO-UNDO. 
  DEF VAR aux_cont_raiz   	  AS INTEGER  NO-UNDO. 
  DEF VAR aux_cont        	  AS INTEGER  NO-UNDO. 
  DEF VAR ponteiro_xml_ora    AS MEMPTR   NO-UNDO. 
  DEF VAR xml_req_ora         AS LONGCHAR NO-UNDO.

  /* Inicializando objetos para leitura do XML */ 
  CREATE X-DOCUMENT xDoc_ora.    /* Vai conter o XML completo */ 
  CREATE X-NODEREF  xRoot_ora.   /* Vai conter a tag raiz em diante */ 
  CREATE X-NODEREF  xRoot_ora2.  /* Vai conter a tag favorito em diante */ 
  CREATE X-NODEREF  xField_ora.  /* Vai conter os campos dentro da tag INF */ 
  CREATE X-NODEREF  xText_ora.   /* Vai conter o texto que existe dentro da tag xField_ora */ 

  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

	RUN STORED-PROCEDURE pc_obtem_operadoras_recarga
	  aux_handproc = PROC-HANDLE NO-ERROR
						 (OUTPUT ?,           /* CLOB com os favoritos */
						  OUTPUT 0,           /* Código da crítica.*/
						  OUTPUT "").         /* Desc. da crítica */
	
	/* Fechar o procedimento para buscarmos o resultado */ 
	CLOSE STORED-PROC pc_obtem_operadoras_recarga
		   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
	
	{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
	
  ASSIGN aux_dsxmlout = ""
         aux_dscritic = ""
         aux_dscritic = pc_obtem_operadoras_recarga.pr_dscritic
                        WHEN pc_obtem_operadoras_recarga.pr_dscritic <> ?
         aux_dsxmlout = pc_obtem_operadoras_recarga.pr_clobxml
                        WHEN pc_obtem_operadoras_recarga.pr_clobxml <> ?.
  
  /* Buscar o XML na tabela de retorno da procedure Progress */ 
  ASSIGN xml_req_ora = aux_dsxmlout.

  /* Efetuar a leitura do XML*/ 
  SET-SIZE(ponteiro_xml_ora) = LENGTH(xml_req_ora) + 1. 
  PUT-STRING(ponteiro_xml_ora,1) = xml_req_ora. 
   
  xDoc_ora:LOAD("MEMPTR",ponteiro_xml_ora,FALSE). 
  xDoc_ora:GET-DOCUMENT-ELEMENT(xRoot_ora).
  
  DO  aux_cont_raiz = 1 TO xRoot_ora:NUM-CHILDREN: 
  
      xRoot_ora:GET-CHILD(xRoot_ora2,aux_cont_raiz).
  
      IF xRoot_ora2:SUBTYPE <> "ELEMENT"   THEN 
       NEXT.                    

      IF  xRoot_ora2:NAME = "PRODUTO" THEN
          DO:
              CREATE tt-operadoras-recarga.

              DO aux_cont = 1 TO xRoot_ora2:NUM-CHILDREN:
              
                  xRoot_ora2:GET-CHILD(xField_ora,aux_cont).
                      
                  IF xField_ora:SUBTYPE <> "ELEMENT" THEN 
                      NEXT. 
                  
                  xField_ora:GET-CHILD(xText_ora,1).            
      
                  ASSIGN tt-operadoras-recarga.cdoperadora = INTE(xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "cdoperadora"
                         tt-operadoras-recarga.nmoperadora = xText_ora:NODE-VALUE  WHEN xField_ora:NAME = "nmoperadora"
                         tt-operadoras-recarga.cdproduto = DECI(xText_ora:NODE-VALUE) WHEN xField_ora:NAME = "cdproduto"
                         tt-operadoras-recarga.nmproduto = xText_ora:NODE-VALUE  WHEN xField_ora:NAME = "nmproduto".
              END.            
          END.
  END.                

  SET-SIZE(ponteiro_xml_ora) = 0. 

  DELETE OBJECT xDoc_ora. 
  DELETE OBJECT xRoot_ora. 
  DELETE OBJECT xRoot_ora2. 
  DELETE OBJECT xField_ora. 
  DELETE OBJECT xText_ora.
              
  /* Se retornou crítica */
  IF  aux_dscritic <> ""   THEN
      DO:
           xDoc:CREATE-NODE(xField,"DSCRITIC","ELEMENT").
           xRoot:APPEND-CHILD(xField).
      
           xDoc:CREATE-NODE(xText,"","TEXT").
           xText:NODE-VALUE = aux_dscritic.
           xField:APPEND-CHILD(xText).
      END.

  FOR EACH tt-operadoras-recarga:    
          
      xDoc:CREATE-NODE(xRoot2,"PRODUTO","ELEMENT").
      xRoot:APPEND-CHILD(xRoot2).

      /* ---------- */
      xDoc:CREATE-NODE(xField,"CDOPERADORA","ELEMENT").
      xRoot2:APPEND-CHILD(xField).

      xDoc:CREATE-NODE(xText,"","TEXT").
      xText:NODE-VALUE = STRING(tt-operadoras-recarga.cdoperadora).
      xField:APPEND-CHILD(xText).

      /* ---------- */
      xDoc:CREATE-NODE(xField,"NMOPERADORA","ELEMENT").
      xRoot2:APPEND-CHILD(xField).

      xDoc:CREATE-NODE(xText,"","TEXT").
      xText:NODE-VALUE = tt-operadoras-recarga.nmoperadora.
      xField:APPEND-CHILD(xText).
      
      /* ---------- */
      xDoc:CREATE-NODE(xField,"CDPRODUTO","ELEMENT").
      xRoot2:APPEND-CHILD(xField).

      xDoc:CREATE-NODE(xText,"","TEXT").
      xText:NODE-VALUE = STRING(tt-operadoras-recarga.cdproduto).
      xField:APPEND-CHILD(xText).        

      /* ---------- */
      xDoc:CREATE-NODE(xField,"NMPRODUTO","ELEMENT").
      xRoot2:APPEND-CHILD(xField).

      xDoc:CREATE-NODE(xText,"","TEXT").
      xText:NODE-VALUE = tt-operadoras-recarga.nmproduto.
      xField:APPEND-CHILD(xText).
            
  END.

END PROCEDURE.

PROCEDURE obtem_valores_recarga:

  DEF VAR aux_dsxmlout        AS CHAR     NO-UNDO.

  /* Variaveis para o XML */ 
  DEF VAR xDoc_ora            AS HANDLE   NO-UNDO.   
  DEF VAR xRoot_ora           AS HANDLE   NO-UNDO.  
  DEF VAR xRoot_ora2          AS HANDLE   NO-UNDO.  
  DEF VAR xField_ora          AS HANDLE   NO-UNDO. 
  DEF VAR xText_ora           AS HANDLE   NO-UNDO. 
  DEF VAR aux_cont_raiz   	  AS INTEGER  NO-UNDO. 
  DEF VAR aux_cont        	  AS INTEGER  NO-UNDO. 
  DEF VAR ponteiro_xml_ora    AS MEMPTR   NO-UNDO. 
  DEF VAR xml_req_ora         AS LONGCHAR NO-UNDO.

  /* Inicializando objetos para leitura do XML */ 
  CREATE X-DOCUMENT xDoc_ora.    /* Vai conter o XML completo */ 
  CREATE X-NODEREF  xRoot_ora.   /* Vai conter a tag raiz em diante */ 
  CREATE X-NODEREF  xRoot_ora2.  /* Vai conter a tag favorito em diante */ 
  CREATE X-NODEREF  xField_ora.  /* Vai conter os campos dentro da tag INF */ 
  CREATE X-NODEREF  xText_ora.   /* Vai conter o texto que existe dentro da tag xField_ora */ 

  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

	RUN STORED-PROCEDURE pc_obtem_valores_recarga
	  aux_handproc = PROC-HANDLE NO-ERROR
						 (INPUT aux_cdoperadora, /* Cod. operadora */
              INPUT aux_cdproduto,   /* Cod. produto */
              OUTPUT ?,           /* CLOB com os favoritos */
						  OUTPUT 0,           /* Código da crítica.*/
						  OUTPUT "").         /* Desc. da crítica */
	
	/* Fechar o procedimento para buscarmos o resultado */ 
	CLOSE STORED-PROC pc_obtem_valores_recarga
		   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
	
	{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
	
  ASSIGN aux_dsxmlout = ""
         aux_dscritic = ""
         aux_dscritic = pc_obtem_valores_recarga.pr_dscritic
                        WHEN pc_obtem_valores_recarga.pr_dscritic <> ?
         aux_dsxmlout = pc_obtem_valores_recarga.pr_clobxml
                        WHEN pc_obtem_valores_recarga.pr_clobxml <> ?.
  
  /* Buscar o XML na tabela de retorno da procedure Progress */ 
  ASSIGN xml_req_ora = aux_dsxmlout.

  /* Efetuar a leitura do XML*/ 
  SET-SIZE(ponteiro_xml_ora) = LENGTH(xml_req_ora) + 1. 
  PUT-STRING(ponteiro_xml_ora,1) = xml_req_ora. 
   
  xDoc_ora:LOAD("MEMPTR",ponteiro_xml_ora,FALSE). 
  xDoc_ora:GET-DOCUMENT-ELEMENT(xRoot_ora).
  
  DO  aux_cont_raiz = 1 TO xRoot_ora:NUM-CHILDREN: 
  
      xRoot_ora:GET-CHILD(xRoot_ora2,aux_cont_raiz).
  
      IF xRoot_ora2:SUBTYPE <> "ELEMENT"   THEN 
       NEXT.                    

      IF  xRoot_ora2:NAME = "VALORES" THEN
          DO:              

              DO aux_cont = 1 TO xRoot_ora2:NUM-CHILDREN:
              
                  xRoot_ora2:GET-CHILD(xField_ora,aux_cont).
                      
                  IF xField_ora:SUBTYPE <> "ELEMENT" THEN 
                      NEXT. 
             
                  xField_ora:GET-CHILD(xText_ora,1).            
                  
                  CREATE tt-valores-recarga.
                  ASSIGN tt-valores-recarga.vlrecarga = DECIMAL(xText_ora:NODE-VALUE).

              END.            
          END.
  END.                

  SET-SIZE(ponteiro_xml_ora) = 0. 

  DELETE OBJECT xDoc_ora. 
  DELETE OBJECT xRoot_ora. 
  DELETE OBJECT xRoot_ora2. 
  DELETE OBJECT xField_ora. 
  DELETE OBJECT xText_ora.
              
  /* Se retornou crítica */
  IF  aux_dscritic <> ""   THEN
      DO:
           xDoc:CREATE-NODE(xField,"DSCRITIC","ELEMENT").
           xRoot:APPEND-CHILD(xField).
      
           xDoc:CREATE-NODE(xText,"","TEXT").
           xText:NODE-VALUE = aux_dscritic.
           xField:APPEND-CHILD(xText).
      END.

  FOR EACH tt-valores-recarga:    
          
      xDoc:CREATE-NODE(xRoot2,"VALOR","ELEMENT").
      xRoot:APPEND-CHILD(xRoot2).

      /* ---------- */
      xDoc:CREATE-NODE(xField,"VLRECARGA","ELEMENT").
      xRoot2:APPEND-CHILD(xField).

      xDoc:CREATE-NODE(xText,"","TEXT").
      xText:NODE-VALUE = STRING(tt-valores-recarga.vlrecarga).
      xField:APPEND-CHILD(xText).
            
  END.

END PROCEDURE.

PROCEDURE verifica_recarga:

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

	RUN STORED-PROCEDURE pc_valida_recarga
	  aux_handproc = PROC-HANDLE NO-ERROR
						 (INPUT aux_cdcooper,  /* Cooperativa*/
						  INPUT aux_nrdconta,  /* Nr. da conta */
						  INPUT 0,             /* CPF Operador da conta */
						  INPUT 1,             /* Titular da conta */
						  INPUT aux_nrdddtel,  /* DDD */
						  INPUT aux_nrcelular, /* Nr. do celular */
						  INPUT aux_vlrecarga, /* Valor de recarga */
						  INPUT DATE(aux_dtrecarga), /* Data de recarga */
						  INPUT aux_qtmesagd,  /* Quantidade de mes agendamento (Somente opcao 3)*/
						  INPUT aux_cddopcao,  /* Opcao: 1-Data atual / 2-Data futura / 3-Agendamento mensal */              
						  INPUT 4,             /* Id origem (4-TAA)*/
                        INPUT 91,            /* Agencia de Origem */ 
                        INPUT 900,           /* Caixa de Origem */ 
                        INPUT "TAA",         /* Programa que chamou */ 
						  OUTPUT "",           /* Lista de datas para agendamento recorrente */
						  OUTPUT 0,            /* Código da crítica.*/
						  OUTPUT "").          /* Desc. da crítica */
	
	/* Fechar o procedimento para buscarmos o resultado */ 
	CLOSE STORED-PROC pc_valida_recarga
		   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
	
	{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
	
	/* Busca parametros retornados */ 
	ASSIGN aux_lsdatagd = ""
         aux_dscritic = ""
         aux_lsdatagd = pc_valida_recarga.pr_lsdatagd
                        WHEN pc_valida_recarga.pr_lsdatagd <> ?
         aux_dscritic = pc_valida_recarga.pr_dscritic
                        WHEN pc_valida_recarga.pr_dscritic <> ?.
	
  /* Se retornou crítica */
  IF  aux_dscritic <> ""   THEN
      DO:
           xDoc:CREATE-NODE(xField,"DSCRITIC","ELEMENT").
           xRoot:APPEND-CHILD(xField).
      
           xDoc:CREATE-NODE(xText,"","TEXT").
           xText:NODE-VALUE = aux_dscritic.
           xField:APPEND-CHILD(xText).
      END.
      
  IF  aux_lsdatagd <> "" THEN
      DO:
        /* ---------- */
        xDoc:CREATE-NODE(xField,"LSDATAGD","ELEMENT").
        xRoot:APPEND-CHILD(xField).
        
        xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = STRING(aux_lsdatagd).
        xField:APPEND-CHILD(xText).
      END.

END PROCEDURE.
    
PROCEDURE efetua_recarga:

  DEFINE VARIABLE aux_cdcoptfn    AS INTE                         NO-UNDO.
  DEFINE VARIABLE aux_cdagetfn    AS INTE                         NO-UNDO.
  DEFINE VARIABLE aux_nrterfin    AS INTE                         NO-UNDO.
  DEFINE VARIABLE aux_idastcjt    AS INTE                         NO-UNDO.
  DEFINE VARIABLE aux_dsprotoc    AS CHAR                         NO-UNDO.
  DEFINE VARIABLE aux_dsnsuope    AS CHAR                         NO-UNDO.

  ASSIGN aux_cdcoptfn = crapcop.cdcooper
         aux_cdagetfn = crapage.cdagenci
         aux_nrterfin = craptfn.nrterfin.
  
{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

	RUN STORED-PROCEDURE pc_manter_recarga
	  aux_handproc = PROC-HANDLE NO-ERROR
						 (INPUT aux_cdcooper,        /* Cooperativa*/
              INPUT aux_nrdconta,        /* Nr. da conta */
              INPUT 1,                   /* Titular da conta */
              INPUT 0,                   /* CPF Operador da conta */
              INPUT aux_vlrecarga,       /* Valor da recarga */
              INPUT DATE(aux_dtrecarga), /* Data de recarga */              
              INPUT aux_lsdatagd,        /* Lista de datas para agendamento de recarga */
              INPUT aux_cddopcao,        /* Opcao: 1-Data atual / 2-Data futura / 3-Agendamento mensal */                            
              INPUT aux_nrdddtel,        /* DDD */
              INPUT aux_nrcelular,       /* Nr. do celular */
              INPUT aux_cdoperadora,     /* Cod. operadora */
              INPUT aux_cdproduto,       /* Cod. produto */
              INPUT aux_cdcoptfn,        /* Cooperativa terminal financeiro */
              INPUT aux_cdagetfn,        /* Agencia terminal financeiro */
              INPUT aux_nrterfin,        /* Nr. terminal financeiro */
              INPUT aux_nrcartao,        /* Nr. cartao */
              INPUT aux_nrsequni,        /* Nr. sequencial unico */
						  INPUT 4,             /* Id origem (4-TAA)*/
                        INPUT 91,            /* Agencia de Origem */ 
                        INPUT 900,           /* Caixa de Origem */ 
                        INPUT "TAA",         /* Programa que chamou */ 
              INPUT 0,             /* Indicador de aprovacao de transacao pendente */
						  INPUT 0,             /* Indicador de operacao (transacao pendente) */
			  INPUT 0,             /* Indicador se origem é mobile (Não) */
                        OUTPUT "",           /* ID dos lançamentos de agendamento de recarga */ 
              OUTPUT 0,            /* Indicador de assinatura conjunta */
              OUTPUT "",           /* Protocolo */
              OUTPUT "",           /* NSU Operadora */
						  OUTPUT 0,            /* Código da crítica.*/
						  OUTPUT "").          /* Desc. da crítica */
	
	/* Fechar o procedimento para buscarmos o resultado */ 
	CLOSE STORED-PROC pc_manter_recarga
		   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
	
	{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
	
	/* Busca parametros retornados */ 
	ASSIGN aux_idastcjt = 0
         aux_dscritic = ""
         aux_dsprotoc = ""
         aux_dsnsuope = ""
         aux_idastcjt = pc_manter_recarga.pr_idastcjt
                        WHEN pc_manter_recarga.pr_idastcjt <> ?
         aux_dsprotoc = pc_manter_recarga.pr_dsprotoc
                        WHEN pc_manter_recarga.pr_dsprotoc <> ?
         aux_dsnsuope = pc_manter_recarga.pr_dsnsuope
                        WHEN pc_manter_recarga.pr_dsnsuope <> ?
         aux_dscritic = pc_manter_recarga.pr_dscritic
                        WHEN pc_manter_recarga.pr_dscritic <> ?.
	
  /* Se retornou crítica */
  IF  aux_dscritic <> ""   THEN
      DO:
           xDoc:CREATE-NODE(xField,"DSCRITIC","ELEMENT").
           xRoot:APPEND-CHILD(xField).
      
           xDoc:CREATE-NODE(xText,"","TEXT").
           xText:NODE-VALUE = aux_dscritic.
           xField:APPEND-CHILD(xText).
      END.
      
  /* ---------- */
  xDoc:CREATE-NODE(xField,"IDASTCJT","ELEMENT").
  xRoot:APPEND-CHILD(xField).
  
  xDoc:CREATE-NODE(xText,"","TEXT").
  xText:NODE-VALUE = STRING(aux_idastcjt).
  xField:APPEND-CHILD(xText).
  
  IF  aux_dsprotoc <> ""   THEN
      DO:
          xDoc:CREATE-NODE(xField,"PROTOCOLO","ELEMENT").
          xRoot:APPEND-CHILD(xField).
          
          xDoc:CREATE-NODE(xText,"","TEXT").
          xText:NODE-VALUE = aux_dsprotoc.
          xField:APPEND-CHILD(xText).
      END.
      
  IF  aux_dsnsuope <> ""   THEN
      DO:
          xDoc:CREATE-NODE(xField,"DSNSUOPE","ELEMENT").
          xRoot:APPEND-CHILD(xField).
          
          xDoc:CREATE-NODE(xText,"","TEXT").
          xText:NODE-VALUE = aux_dsnsuope.
          xField:APPEND-CHILD(xText).
      END.      

END PROCEDURE.

PROCEDURE exclui_agendamentos_recarga:

    DEFINE VARIABLE aux_cdcoptfn AS INTEGER                         NO-UNDO.
    DEFINE VARIABLE aux_cdagetfn AS INTEGER                         NO-UNDO.
    DEFINE VARIABLE aux_nrterfin AS INTEGER                         NO-UNDO.
    
    ASSIGN aux_cdcoptfn = crapcop.cdcooper
           aux_cdagetfn = crapage.cdagenci
           aux_nrterfin = craptfn.nrterfin.


    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_cancela_agendamento_recarga aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT aux_cdcooper 
                         ,INPUT aux_nrdconta 
                         ,INPUT 1
                         ,INPUT 4   /* TAA */
                         ,INPUT aux_nrdocmto
                         ,INPUT "TAA" /* Projeto 363 - Novo ATM */ 
                         ,OUTPUT 0
                         ,OUTPUT "").
                         

    CLOSE STORED-PROC pc_cancela_agendamento_recarga aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dscritic = ""
           aux_dscritic = pc_cancela_agendamento_recarga.pr_dscritic 
                          WHEN pc_cancela_agendamento_recarga.pr_dscritic <> ?.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF  aux_dscritic = "" THEN
        DO:
            /* Cria registro na crapext */
            RUN sistema/generico/procedures/b1wgen0025.p PERSISTENT SET h-b1wgen0025.

            RUN gera_estatistico IN h-b1wgen0025 (INPUT aux_cdcoptfn, /* Coop do TAA */
                                                  INPUT aux_nrterfin, /* Nro do TAA */
                                                  INPUT "",           /* Prefixo TAA versao 1 */
                                                  INPUT aux_cdcooper, /* Coop do Associado */
                                                  INPUT aux_nrdconta, /* Conta do Associado */
                                                  INPUT 14).          /* Exclusão de Agendamento */
            DELETE PROCEDURE h-b1wgen0025.
        END.
     ELSE
         RETURN "NOK".

    /* ---------- */
    xDoc:CREATE-NODE(xField,"EXCLUSAO","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = "OK".
    xField:APPEND-CHILD(xText).

    RETURN "OK".

END PROCEDURE.

/* Operacao 75 */
PROCEDURE verifica_notas_cem:

    RUN sistema/generico/procedures/b1wgen0123.p PERSISTENT SET h-b1wgen0123.
    
    RUN verifica_notas_cem IN h-b1wgen0123(INPUT crapcop.cdcooper, 
                                           INPUT craptfn.nrterfin,
                                           OUTPUT aux_flgntcem).
    DELETE PROCEDURE h-b1wgen0123.
    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".

    /* ---------- */
    xDoc:CREATE-NODE(xField,"FLGNTCEM","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_flgntcem).
    xField:APPEND-CHILD(xText).


    RETURN "OK".

END PROCEDURE.
/* Fim 75 - verifica notas cem */


/* Operacao 76 */
PROCEDURE busca_convenio_nome:
    DEF     VAR     aux_nmextcon    AS      CHAR.
    DEF     VAR     aux_cdbarras    AS      CHAR.
    DEF     VAR     aux_cdempcon    AS      INTE.
    DEF     VAR     aux_cdsegmto    AS      INTE.

    DEF     VAR     aux_nmempcon    AS      CHAR.

    ASSIGN aux_cdbarras = SUBSTR(aux_cdbarra1, 1 ,11) + aux_cdbarra2.

    IF  aux_dscodbar <> "" THEN
        ASSIGN aux_cdempcon  = INT(SUBSTR(aux_dscodbar,16,4)) 
               aux_cdsegmto  = INT(SUBSTR(aux_dscodbar,2,1)). 
    ELSE
        ASSIGN aux_cdempcon = INT(SUBSTR(aux_cdbarras,16,4))
               aux_cdsegmto = INT(SUBSTR(aux_cdbarras,2,1)).

    RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

    RUN busca_convenio_nome IN h-b1wgen0092 (INPUT aux_cdcooper,
                                             INPUT aux_cdempcon,
                                             INPUT aux_cdsegmto,
                                             OUTPUT aux_nmempcon).
    DELETE PROCEDURE h-b1wgen0092.
      
    IF aux_nmempcon = "" THEN
    DO:
        ASSIGN aux_dscritic = "Convenio não encontrado.".

        RETURN "NOK".    
    END.

    IF  aux_dscritic = "" THEN
        DO:
            /* ---------- */
            xDoc:CREATE-NODE(xField,"NMEXTCON","ELEMENT").
            xRoot:APPEND-CHILD(xField).
        
            xDoc:CREATE-NODE(xText,"","TEXT").
            xText:NODE-VALUE = aux_nmempcon.
            xField:APPEND-CHILD(xText).

        END.
    
    RETURN "OK".
END PROCEDURE.
/* Fim 76 */

/*Operacao 77 - verifica_opcao_benef_inss */
PROCEDURE verifica_opcao_benef_inss:

  DEF VAR aux_flgsitbi AS INTE NO-UNDO.
  DEF VAR aux_habilita_consulta_eco AS CHAR NO-UNDO.
    
  ASSIGN aux_flgsitbi = 0
         aux_habilita_consulta_eco = "0". /* Inicia Desabilitado */
  
  { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

  RUN STORED-PROCEDURE pc_param_sistema aux_handproc = PROC-HANDLE
                     (INPUT "CRED",                    /* pr_nmsistem */
                      INPUT 0,                         /* pr_cdcooper */
                      INPUT "HABILITAR_CONSULTA_ECO",  /* pr_cdacesso */
                      OUTPUT ""                        /* pr_dsvlrprm */
                      ).

  CLOSE STORED-PROCEDURE pc_param_sistema WHERE PROC-HANDLE = aux_handproc.
  { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }


  ASSIGN aux_habilita_consulta_eco = "0"
         aux_habilita_consulta_eco = pc_param_sistema.pr_dsvlrprm
                                       WHEN pc_param_sistema.pr_dsvlrprm <> ?.

  
  IF aux_habilita_consulta_eco = "1" THEN
  DO:
      /* Localizar o Cooperado */   
      FIND crapass WHERE crapass.cdcooper = aux_cdcooper
                     AND crapass.nrdconta = aux_nrdconta
                   NO-LOCK NO-ERROR .

      /* Se encontrou o cooperado, busca os beneficios */
      IF AVAILABLE crapass THEN
      DO:
           /* Somente Pessoa Fisica possui beneficio */
          IF crapass.inpessoa = 1 THEN
          DO:
              /* Buscar o CPF do titular*/ 
              FIND FIRST crapttl
                 WHERE crapttl.cdcooper = crapass.cdcooper
                   AND crapttl.nrdconta = crapass.nrdconta
                   AND crapttl.idseqttl = aux_tpusucar
                  NO-LOCK NO-ERROR.

              IF AVAILABLE crapttl THEN
         DO:
                  /* Busca todos os beneficios do cpf em questao */
                  FOR EACH crapdbi WHERE crapdbi.nrcpfcgc = crapttl.nrcpfcgc
                  NO-LOCK:
                  
                      /* Verificar se  a conta em questao recebeu o beneficio */
                      FIND FIRST craplcm WHERE craplcm.cdcooper = crapass.cdcooper 
                                           AND craplcm.nrdconta = crapass.nrdconta
                                           AND craplcm.cdhistor = 1399
                                           AND craplcm.dtmvtolt <= crapdat.dtmvtolt
                                           AND craplcm.dtmvtolt >= (crapdat.dtmvtolt - 90)
                                           /*Buscar cdpesqbb até o primeiro ';' que é o NB(numero do beneficio)*/
                                           AND DEC(ENTRY(1,craplcm.cdpesqbb, ";")) = crapdbi.nrrecben
                                NO-LOCK NO-ERROR.

                      IF AVAILABLE craplcm THEN
                              ASSIGN aux_flgsitbi = 1.
                  END.
              END.
          END.
      END.
         END.
         
  /* ---------- */
  xDoc:CREATE-NODE(xField,"FLGSITBI","ELEMENT").
  xRoot:APPEND-CHILD(xField).
  
  xDoc:CREATE-NODE(xText,"","TEXT").
  xText:NODE-VALUE = STRING(aux_flgsitbi).
  xField:APPEND-CHILD(xText).
  
  RETURN "OK".
  
END PROCEDURE.
/* Fim Operacao 77 - verifica_opcao_benef_inss */

/*Operacao 78 - listar_beneficios_inss */
PROCEDURE listar_beneficios_inss:

  /* Localizar o Cooperado */   
  FIND crapass WHERE crapass.cdcooper = aux_cdcooper
                 AND crapass.nrdconta = aux_nrdconta
               NO-LOCK NO-ERROR .

  /* Se encontrou o cooperado, busca os beneficios */
  IF AVAILABLE crapass THEN
  DO:
       /* Somente Pessoa Fisica possui beneficio */
      IF crapass.inpessoa = 1 THEN
        DO:
          /* Localizar o Cooperado */   
          FIND crapage WHERE crapage.cdcooper = crapass.cdcooper
                         AND crapage.cdagenci = crapass.cdagenci
                       NO-LOCK NO-ERROR .
          
          /* Buscar o CPF do titular*/ 
          FIND FIRST crapttl
             WHERE crapttl.cdcooper = crapass.cdcooper
               AND crapttl.nrdconta = crapass.nrdconta
               AND crapttl.idseqttl = aux_tpusucar
              NO-LOCK NO-ERROR.
                               
          IF AVAILABLE crapttl THEN
          DO:
              /* Busca todos os beneficios do cpf em questao */
              FOR EACH crapdbi WHERE crapdbi.nrcpfcgc = crapttl.nrcpfcgc
              NO-LOCK:

                  /* Verificar se  a conta em questao recebeu o beneficio */
                  FIND FIRST craplcm WHERE craplcm.cdcooper = crapass.cdcooper 
                                       AND craplcm.nrdconta = crapass.nrdconta
                                       AND craplcm.cdhistor = 1399
                                       AND craplcm.dtmvtolt <= crapdat.dtmvtolt
                                       AND craplcm.dtmvtolt >= (crapdat.dtmvtolt - 90)
                                       /*Buscar cdpesqbb até o primeiro ';' que é o NB(numero do beneficio)*/
                                       AND DEC(ENTRY(1,craplcm.cdpesqbb, ";")) = crapdbi.nrrecben
                                       NO-LOCK NO-ERROR.
          
                  IF AVAILABLE craplcm THEN
                  DO:
                      CREATE tt-beneficios-inss.
                      ASSIGN tt-beneficios-inss.nrrecben = crapdbi.nrrecben.
                  END.
              END.
          END.
      END.
  END.
          
  FOR EACH tt-beneficios-inss NO-LOCK:

      xDoc:CREATE-NODE(xRoot2,"BENEFICIO","ELEMENT").
      xRoot:APPEND-CHILD(xRoot2).
        
      /* ---------- */
      xDoc:CREATE-NODE(xField,"NRRECBEN","ELEMENT").
      xRoot2:APPEND-CHILD(xField).

      xDoc:CREATE-NODE(xText,"","TEXT").
      xText:NODE-VALUE = STRING(tt-beneficios-inss.nrrecben).
      xField:APPEND-CHILD(xText). 
   
    /* ---------- */
      xDoc:CREATE-NODE(xField,"CDORGINS","ELEMENT").
      xRoot2:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
      xText:NODE-VALUE = STRING(crapage.cdorgins).
    xField:APPEND-CHILD(xText).
  END.

    RETURN "OK".
  
END PROCEDURE.
/* Fim Operacao 78 - listar_beneficios_inss */

/*Operacao 79 - consultar_eco */
PROCEDURE consultar_eco:

    DEFINE VARIABLE aux_cdcoptfn AS INTEGER                         NO-UNDO.
    DEFINE VARIABLE aux_cdagetfn AS INTEGER                         NO-UNDO.
    DEFINE VARIABLE aux_nrterfin AS INTEGER                         NO-UNDO.
    DEFINE VARIABLE aux_habilita_consulta_eco AS CHAR               NO-UNDO.

    DEF VAR aux_dserror          AS CHAR                            NO-UNDO.

    /* Variaveis para o XML */ 
    DEF VAR xDoc_ora            AS HANDLE   NO-UNDO.   
    DEF VAR xRoot_ora           AS HANDLE   NO-UNDO.  
    DEF VAR xRoot_ora2          AS HANDLE   NO-UNDO.  
    DEF VAR xField_ora          AS HANDLE   NO-UNDO. 
    DEF VAR xText_ora           AS HANDLE   NO-UNDO. 
    DEF VAR aux_cont_raiz   	  AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont        	  AS INTEGER  NO-UNDO. 
    DEF VAR ponteiro_xml_ora    AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req_ora         AS LONGCHAR NO-UNDO.
    
    ASSIGN aux_cdcoptfn = crapcop.cdcooper
           aux_cdagetfn = crapage.cdagenci
           aux_nrterfin = craptfn.nrterfin.

    ASSIGN aux_habilita_consulta_eco = "0". /* Inicia Desabilitado */
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_param_sistema aux_handproc = PROC-HANDLE
                       (INPUT "CRED",                    /* pr_nmsistem */
                        INPUT 0,                         /* pr_cdcooper */
                        INPUT "HABILITAR_CONSULTA_ECO",  /* pr_cdacesso */
                        OUTPUT ""                        /* pr_dsvlrprm */
                        ).

    CLOSE STORED-PROCEDURE pc_param_sistema WHERE PROC-HANDLE = aux_handproc.
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }


    ASSIGN aux_habilita_consulta_eco = "0"
           aux_habilita_consulta_eco = pc_param_sistema.pr_dsvlrprm
                                         WHEN pc_param_sistema.pr_dsvlrprm <> ?.

    /* Verificar se a opcao de consulta do ECO esta desabilitada */
    IF aux_habilita_consulta_eco = "0" THEN
         DO:
        ASSIGN aux_dscritic = "A CONSULTA AOS DADOS DE EMPRESTIMO CONSIGNADO ONLINE " + 
                              "ESTA DESATIVADA NO MOMENTO".

        RETURN "NOK".    
         END.
         

    /* Tipo de comprovante 1 == Extrato Emprestimo Consignado */ 
    IF aux_tpconben = 1 THEN
        DO:
          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
          
        RUN STORED-PROCEDURE pc_extrato_emprestimo_inss aux_handproc = PROC-HANDLE NO-ERROR
                             (INPUT aux_cdcooper  /* Cooperativa */ 
                             ,INPUT aux_nrdconta  /* Conta */
                             ,INPUT aux_cdorgins  /* Orgao Pagador */
                             ,INPUT aux_nrrecben  /* Numero do Beneficio */ 
                             ,INPUT aux_cdcoptfn /* Coop Terminal */ 
                             ,INPUT aux_cdagetfn /* PA Terminal */
                             ,INPUT aux_nrterfin /* Numero Terminal */ 
                             ,OUTPUT "" /* XML de retorno */ 
                             ,OUTPUT ""). /* mensagem de erro */
                               

        CLOSE STORED-PROC pc_extrato_emprestimo_inss aux_statproc = PROC-STATUS 
               WHERE PROC-HANDLE = aux_handproc.
          
        ASSIGN aux_dserror = ""
               aux_dserror = pc_extrato_emprestimo_inss.pr_dsderror
                      WHEN pc_extrato_emprestimo_inss.pr_dsderror <> ?.  
               xml_req_ora  = pc_extrato_emprestimo_inss.pr_retorno. 
          
          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    END.

    /* Tipo de comprovante 2 == Margem Consignavel */ 
    IF aux_tpconben = 2 THEN
    DO:
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        RUN STORED-PROCEDURE pc_margem_consignavel_inss aux_handproc = PROC-HANDLE NO-ERROR
                             (INPUT aux_cdcooper  /* Cooperativa */ 
                             ,INPUT aux_nrdconta  /* Conta */
                             ,INPUT aux_cdorgins  /* Orgao Pagador */
                             ,INPUT aux_nrrecben  /* Numero do Beneficio */ 
                             ,INPUT aux_cdcoptfn /* Coop Terminal */ 
                             ,INPUT aux_cdagetfn /* PA Terminal */
                             ,INPUT aux_nrterfin /* Numero Terminal */ 
                             ,OUTPUT "" /* XML de retorno */ 
                             ,OUTPUT ""). /* mensagem de erro */


        CLOSE STORED-PROC pc_margem_consignavel_inss aux_statproc = PROC-STATUS 
             WHERE PROC-HANDLE = aux_handproc.

        ASSIGN aux_dserror = ""
               aux_dserror = pc_margem_consignavel_inss.pr_dsderror
                      WHEN pc_margem_consignavel_inss.pr_dsderror <> ?.  
               xml_req_ora  = pc_margem_consignavel_inss.pr_retorno. 

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    END.

    IF  aux_dserror <> "" THEN
                      DO:
           ASSIGN aux_dscritic = aux_dserror.
           RETURN "NOK".
        END.

    CREATE X-DOCUMENT xDoc_ora.
    CREATE X-NODEREF  xRoot_ora.
    CREATE X-NODEREF  xRoot_ora2.
    CREATE X-NODEREF  xField_ora.
    CREATE X-NODEREF  xText_ora.
    
    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml_ora) = LENGTH(xml_req_ora) + 1. 
    PUT-STRING(ponteiro_xml_ora,1) = xml_req_ora. 
   
    xDoc_ora:LOAD("MEMPTR",ponteiro_xml_ora,FALSE). 
    xDoc_ora:GET-DOCUMENT-ELEMENT(xRoot_ora).

    DO  aux_cont_raiz = 1 TO xRoot_ora:NUM-CHILDREN: 

        xRoot_ora:GET-CHILD(xRoot_ora2,aux_cont_raiz).

        IF xRoot_ora2:SUBTYPE <> "ELEMENT"   THEN 
         NEXT.                    

        IF  xRoot_ora2:NAME = "comprovante" THEN
            DO:
           
                DO aux_cont = 1 TO xRoot_ora2:NUM-CHILDREN:
    
                    xRoot_ora2:GET-CHILD(xField_ora,aux_cont).
                         
                    IF xField_ora:SUBTYPE <> "ELEMENT" THEN 
                        NEXT. 

                    xField_ora:GET-CHILD(xText_ora,1).            
    
                    CREATE tt-dados-comprovante-eco.
                    ASSIGN tt-dados-comprovante-eco.linha = xText_ora:NODE-VALUE.
                END.            
            END.
    END.                
    
    SET-SIZE(ponteiro_xml_ora) = 0. 
    
    DELETE OBJECT xDoc_ora. 
    DELETE OBJECT xRoot_ora. 
    DELETE OBJECT xRoot_ora2. 
    DELETE OBJECT xField_ora. 
    DELETE OBJECT xText_ora.

    /* Percorrer todas as linhas do comprovante */
    FOR EACH tt-dados-comprovante-eco NO-LOCK:
    /* ---------- */
        xDoc:CREATE-NODE(xField,"LINHA","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
        xText:NODE-VALUE = tt-dados-comprovante-eco.linha.
    xField:APPEND-CHILD(xText).
    END.

    RETURN "OK".

END PROCEDURE.
/* Fim Operacao 79 - consultar_eco */

PROCEDURE busca_modalidade:
    DEFINE VARIABLE aux_cdmodali AS INTEGER                        NO-UNDO.


    IF   aux_cdagetra <> 0   THEN
         DO:
             FIND crapcop WHERE crapcop.cdagectl = aux_cdagetra
                                NO-LOCK NO-ERROR.

             IF   AVAIL crapcop   THEN
                  ASSIGN aux_cdcooper = crapcop.cdcooper.
         END.
         
    FIND FIRST crapass WHERE crapass.cdcooper = aux_cdcooper  AND
                             crapass.nrdconta = aux_nrtransf NO-LOCK NO-ERROR.

    IF   AVAIL crapass   THEN
        DO:
          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
          
          RUN STORED-PROCEDURE pc_busca_modalidade_tipo aux_handproc = PROC-HANDLE NO-ERROR
                               (INPUT crapass.inpessoa 
                               ,INPUT crapass.cdtipcta
                               ,OUTPUT 0
                               ,OUTPUT ""
                               ,OUTPUT "").
                               

          CLOSE STORED-PROC pc_busca_modalidade_tipo aux_statproc = PROC-STATUS 
               WHERE PROC-HANDLE = aux_handproc.
          
          ASSIGN aux_dscritic = ""
                 aux_cdmodali = 0
                 aux_dscritic = pc_busca_modalidade_tipo.pr_dscritic 
                                WHEN pc_busca_modalidade_tipo.pr_dscritic <> ?
                 aux_cdmodali = pc_busca_modalidade_tipo.pr_cdmodalidade_tipo 
                                WHEN pc_busca_modalidade_tipo.pr_cdmodalidade_tipo <> ?.
          
          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

          IF  aux_dscritic <> ""  THEN
              RETURN "NOK".
        
        END.

   
    /* ---------- */
    xDoc:CREATE-NODE(xField,"CDMODALI","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_cdmodali).
    xField:APPEND-CHILD(xText).

    RETURN "OK".
END PROCEDURE.
/* Fim 80 - busca_modalidade */

PROCEDURE valida_modalidade_transferencia:
    DEFINE VARIABLE aux_cdmodali AS INTEGER                        NO-UNDO.    
    DEFINE VARIABLE p_nrcpfemp   AS CHAR                           NO-UNDO.
    DEFINE VARIABLE p_flgdeconta AS INTEGER                        NO-UNDO.

    ASSIGN p_flgdeconta = 0.

    IF   aux_cdagetra <> 0   THEN
         DO:
             FIND crapcop WHERE crapcop.cdagectl = aux_cdagetra
                                NO-LOCK NO-ERROR.

             IF   AVAIL crapcop   THEN
                  ASSIGN aux_cdcooper = crapcop.cdcooper.
         END.
         
    FIND FIRST crapass WHERE crapass.cdcooper = aux_cdcooper  AND
                             crapass.nrdconta = aux_nrtransf NO-LOCK NO-ERROR.

    IF   AVAIL crapass   THEN
        DO:
          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
          
          RUN STORED-PROCEDURE pc_busca_modalidade_tipo aux_handproc = PROC-HANDLE NO-ERROR
                               (INPUT crapass.inpessoa 
                               ,INPUT crapass.cdtipcta
                               ,OUTPUT 0
                               ,OUTPUT ""
                               ,OUTPUT "").
                               

          CLOSE STORED-PROC pc_busca_modalidade_tipo aux_statproc = PROC-STATUS 
               WHERE PROC-HANDLE = aux_handproc.
          
          ASSIGN aux_dscritic = ""
                 aux_cdmodali = 0
                 aux_dscritic = pc_busca_modalidade_tipo.pr_dscritic 
                                WHEN pc_busca_modalidade_tipo.pr_dscritic <> ?
                 aux_cdmodali = pc_busca_modalidade_tipo.pr_cdmodalidade_tipo 
                                WHEN pc_busca_modalidade_tipo.pr_cdmodalidade_tipo <> ?.
          
          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

          IF  aux_dscritic <> ""  THEN
              RETURN "NOK".

          IF aux_cdmodali = 2 THEN
            DO:
              FIND FIRST crapttl WHERE crapttl.cdcooper = crapcop.cdcooper
                                   AND crapttl.nrdconta = crapass.nrdconta
                                   AND crapttl.idseqttl = 1    /* Dados do Primeiro Titular */
                                   USE-INDEX crapttl1 NO-LOCK NO-ERROR.

              IF  AVAIL crapttl THEN
                  ASSIGN p_nrcpfemp = STRING(crapttl.nrcpfemp).

              FIND FIRST crapass WHERE crapass.cdcooper = aux_cdagerem  AND
                                       crapass.nrdconta = aux_nrremete NO-LOCK NO-ERROR.

              IF   AVAIL crapass   THEN
                  DO:
                    IF STRING(crapass.nrcpfcgc) <> p_nrcpfemp THEN
                      DO:
                        ASSIGN p_flgdeconta = 1.
                      END.
                  END.
            END.
        END.

   
    /* ---------- */
    xDoc:CREATE-NODE(xField,"FLGDECONTA","ELEMENT").
    xRoot:APPEND-CHILD(xField).

    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(p_flgdeconta).
    xField:APPEND-CHILD(xText).

    RETURN "OK".
END PROCEDURE.
/* Fim 81 - valida_modalidade_transferencia */

/* Inicio 82 - P485 - INICIO */
PROCEDURE verifica_modalidade_conta:

    DEFINE VARIABLE aux_cdmodali AS INTE NO-UNDO.
           
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_busca_modalidade_conta aux_handproc = PROC-HANDLE NO-ERROR
                  (INPUT  aux_cdcooper 
                  ,INPUT  aux_nrdconta 
                  ,OUTPUT 0
                  ,OUTPUT ""
                  ,OUTPUT "").
                         

    CLOSE STORED-PROC pc_busca_modalidade_conta aux_statproc = PROC-STATUS 
         WHERE PROC-HANDLE = aux_handproc.
    
    ASSIGN aux_dscritic = ""
           aux_cdmodali = 0
           aux_dscritic = pc_busca_modalidade_conta.pr_dscritic 
                          WHEN pc_busca_modalidade_conta.pr_dscritic <> ?
           aux_cdmodali = pc_busca_modalidade_conta.pr_cdmodalidade_tipo 
                          WHEN pc_busca_modalidade_conta.pr_cdmodalidade_tipo <> ?.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    /* Se retornou crítica */
    IF  aux_dscritic <> "" THEN
      DO:
           RETURN "NOK".
      END.

    /* ---------- */
    xDoc:CREATE-NODE(xField,"CDMODALI","ELEMENT").
    xRoot:APPEND-CHILD(xField).
    
    xDoc:CREATE-NODE(xText,"","TEXT").
    xText:NODE-VALUE = STRING(aux_cdmodali).
    xField:APPEND-CHILD(xText).

    RETURN "OK".

END PROCEDURE.
/* Inicio 82 - P485 - FIM */

/* Operacao 83 - verifica_conta_monitorada */
PROCEDURE verifica_conta_monitorada:

  DEF VAR aux_flgctmon AS INTE                                  NO-UNDO.

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_verifica_conta_bloqueio
  aux_handproc = PROC-HANDLE NO-ERROR
                     (INPUT aux_cdcooper, 
                      INPUT aux_nrdconta,
                      OUTPUT 0,
                      OUTPUT 0,
                      OUTPUT "").
                     
CLOSE STORED-PROC pc_verifica_conta_bloqueio aux_statproc = PROC-STATUS
      WHERE PROC-HANDLE = aux_handproc.

ASSIGN aux_flgctmon = 0       
       aux_cdcritic = 0
       aux_dscritic = ""
       aux_flgctmon = pc_verifica_conta_bloqueio.pr_id_conta_monitorada
                      WHEN pc_verifica_conta_bloqueio.pr_id_conta_monitorada <> ?
       aux_cdcritic = pc_verifica_conta_bloqueio.pr_cdcritic
                      WHEN pc_verifica_conta_bloqueio.pr_cdcritic <> ?
       aux_dscritic = pc_verifica_conta_bloqueio.pr_dscritic
                      WHEN pc_verifica_conta_bloqueio.pr_dscritic <> ?.      

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

  IF aux_dscritic <> "" THEN
    RETURN "NOK".
    
  /* ---------- */
  xDoc:CREATE-NODE(xField,"FLGCTMON","ELEMENT").
  xRoot:APPEND-CHILD(xField).
  
  
  xDoc:CREATE-NODE(xText,"","TEXT").
  xText:NODE-VALUE = STRING(aux_flgctmon).
  xField:APPEND-CHILD(xText).


END PROCEDURE.
/* Fim Operacao 83 - verifica_conta_monitorada */


/* .......................................................................... */

