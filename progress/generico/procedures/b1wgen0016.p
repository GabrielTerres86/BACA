/******************************************************************************

                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +------------------------------------+--------------------------------------+
  | Rotina Progress                    | Rotina Oracle PLSQL                  |
  +------------------------------------+--------------------------------------+
  | b1wgen0016.p                       | PAGA0001                             |
  | debita-agendamento-transferencia   | PAGA0001.pc_debita_agendto_transf    |
  | debita-agendamento-pagamento       | PAGA0001.pc_debita_agendto_pagto     |
  | atualiza_transacoes_nao_efetivadas | PAGA0001.pc_atualiza_trans_nao_efetiv|
  | verifica_titulo                    | PAGA0001.pc_verifica_titulo          |
  | paga_titulo                        | PAGA0001.pc_paga_titulo              |
  | verifica_convenio                  | PAGA0001.pc_verifica_convenio        |
  | paga_convenio                      | PAGA0001.pc_paga_convenio            |
  | verifica-dias-tolerancia-sicredi | PAGA0001.pc_verifica_dias_toler_sicredi|
  | verifica_sit_transacao             | PAGA0001.pc_verifica_sit_transacao   |
  | cria_transacao_operador            | CADA0002.pc_cria_transacao_operador  |
  | cria_transacao_operador_registro   | CADA0002.pc_cria_transacao_ope_reg   |
  | cadastrar-agendamento              | PAGA0002.pc_cadastrar_agendamento    |
  | agendamento-recorrente             | PAGA0002.pc_agendamento_recorrente   |
  | obtem-agendamentos                 | PAGA0002.pc_obtem_agendamentos       |
  | parametros-cancelamento            | PAGA0002.pc_parametros_cancelamento  |
  | estorna_convenio                   | PAGA0004.pc_estorna_convenio         |
  | estorna_titulo                     | PAGA0004.pc_estorna_titulo           |
  +------------------------------------+--------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/*.....................................................................................................

    Programa: b1wgen0016.p
    Autor   : Evandro/David
    Data    : Abril/2006                     Ultima Atualizacao: 08/05/2019
    
    Dados referentes ao programa:

    Objetivo  : BO para controlar o pagamento de convenios (faturas) e de
                titulos.             

    Alteracoes: 22/08/2007 - Incluida procedure de Convenios Aceitos (Diego).

                16/11/2007 - Alterar param para BO que gera protocolo (David).

                11/12/2007 - Tratamento para Transpocred na procedure 
                             "pagamentos_liberados" (David).

                28/12/2007 - Tratamento para contas juridicas (David).

                27/02/2008 - Armazenar o codigo de barras no protocolo (David).
                
                28/04/2008 - Adicionado estorno de titulos e faturas (Evandro).

                09/04/2008 - Adaptacao para agendamento de pagamentos (David).

                31/07/2008 - Incluir parametro na procedure gera protocolo
                             (David).
                             
                20/05/2009 - Alterar tratamento para verificacao de registros
                             que estao com EXCLUSIVE-LOCK (David).    
                                      
                06/08/2009 - Alteracoes do Projeto de Transferencia para 
                             Credito de Salario (David).

                10/08/2009 - Validar faturas com mesmo sequencial no cadastro 
                             de agendamento (David).
                             
                22/04/2010 - Alterar indice craplau4 por craplau2 na consulta
                             de agendamentos (David).
                             
                27/05/2010 - Receber a origem via parametro para possibilitar
                             o uso via TAA, o pagamento do TAA foi criado
                             como tipo 6 nos protocolos (Evandro).
                             
                24/06/2010 - Ajuste no recebimento da origem 4 para
                             tratamento do TAA e mensagem de erro na
                             verificacao da fatura (Evandro).
                             
                24/09/2010 - Bloquear agendamentos para o PAC 5 da Creditextil,
                             referente a sobreposicao de PACs (David).
                           
                20/10/2010 - Incluidos parametros nas procedures paga_titulo e 
                             paga_convenio para compartilhamento com TAA
                             (Vitor).  
                             
                01/05/2011 - Ajustes para a utilizacao das rotinas de 
                             agendamento pelo TAA (Henrique).
                             
                02/05/2011 - Incluso parametro pagamento por cheque na 
                             gera-titulos-iptu 
                           - Incluso parametros cobranca registrada na 
                             retorna-valores-titulo-iptu e gera-titulos-iptu  
                           - Incluso parametros cobranca registrada na
                             verifica_titulo e paga_titulo (Guilherme).
                             
                09/06/2011 - Correcao nos debitos TAA (Evandro).
                
                08/07/2011 - Chamada para procedure liquidacao-intrabancaria-dda
                             dentro da procedure paga_titulo (Elton).
                             
                21/07/2011 - Acerto no controle de erros para TAA (Evandro).
                
                05/08/2011 - Ajuste de parametros na executa transferencia.
                             Incluir no protocolo: a cooperativa , agencia e 
                             terminal (Gabriel).   
                             
                17/08/2011 - Ajuste na condicao para geracao do movimento na
                             tabela crapmvi (David).
                             
                04/10/2011 - Adicionado parametros de nome e cpf do preposto
                             e operador em procedure obtem-agendamentos (Jorge).
                             
                05/10/2011 - CPF operador na verifica_operacao 
                           - Incluir procedure cria_transacao_operador 
                           - Incluir procedure cria_transacao_operador_registro
                           - Incluir procedure busca_transacoes
                           - Incluir procedure exclui_transacoes
                           - Incluir procedure efetiva_transacoes
                           - Incluir procedure atualiza_transacoes_nao_efetivadas
                             (Guilherme).
                             
                08/03/2012 - Incluido parametro de titulos DDA nas rotinas de 
                             agendamento/pagamento. (Rafael)
                           - Incluido rotina de baixa-operacional nos pagamentos
                             de titulos DDA. (Rafael)
                             
                09/03/2012 - Adicionado os campos cdbcoctl e cdagectl.(Fabricio)
                             
                20/03/2012 - Removido rotina baixa-operacional nos pagamentos.
                             A baixa operacional ficou dentro da rotina de 
                             atualizacao do dda na b1wgen0079. (Rafael)
                             
                24/04/2012 - Ajuste na condicao para pagtos de titulos na
                             procedure pagamentos_liberados (David).  
                             
                11/05/2012 - Projeto TED Internet (David).
                
                19/06/2012 - Alteracao na leitura da craptco (David Kruger).
                
                19/10/2012 - Envio de email para pagamento de titulo com
                             valor acima de 1.000,00 (David Kistner).
                             
                08/11/2012 - Tratamento para Viacredi Alto Vale (David).
                
                28/11/2012 - Ajuste Migracao Alto Vale (David).
                
                03/01/2013 - Ajuste nos filtros da monitoracao de pagamento de 
                             titulo (David).
                             
                08/02/2013 - Incluso chamada do procedimento retorna-valores-fatura da
                             BO b1crap15.p no procedimento estorna_convenio e incluso 
                             tratamento para criticas (Daniel).
                             
                07/03/2013 - Alterar e-mail monitoracao pagtos (David). 
                            
                18/04/2013 - Tratamento para Convenios SICREDI (Lucas)
                
                18/04/2013 - Transferencia InterCooperativa (Gabriel).                
                
                27/04/2013 - Tratamento para convenios Sicredi (Elton).
                
                30/04/2013 - Alterar valor minimo para monitoracao de pagtos
                             em 1000,00, exceto Viacredi e Alto Vale (David).
                             
                20/05/2013 - Novo param. procedure 'grava-autenticacao-internet'
                            (Lucas).
                
                10/06/2013 - Alteraçao funçao enviar_email_completo para
                             nova versao (Jean Michel).
                           - Projeto VR Boletos - inclusao do parametro DDA/CNPJ
                             do cedente na rotina de pagto de titulos. (Rafael)
                           
                18/06/2013 - Alteracao em valores de parametro de envio de 
                             email para monitoracao de fralde. (Jorge)         
                             
                17/07/2013 - Alterada a procedure 'obtem-agendamentos' e 
                             'debita-agendamento-transferencia' para correçao de
                             transferencia intercooperativa (Lucas).
                
                19/07/2013 - Softdesk 77129 Alterada a procedure 
                             debita-agendamento-pagamento; Quando a situaçao do 
                             agendamento é setada para "Nao Efetivado", 
                             verificar se o agendamento é DDA 
                             (craplau.idtitdda > 0), e entao tornar o título DDA 
                             para "Em Aberto". (Carlos)
                             
                21/08/2013 - Adicionado proc. consultar_parmon, alterar_parmon e
                             log-tela-parmon.
                             Adicionado include de b1wgen0119tt.i
                             Alterado proc. paga_titulo, inclusao dos parametros
                             cadastrados via tela PARMON. (Jorge)
                             
                27/09/2013 - Ajustar bloqueio de agendamentos para migracao
                             Acredi-Viacredi (David).
                             
                30/10/2013 - Alterar corpo do email de monitoracao conforme
                             chamado 102876 (David).
                
                12/11/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (Guilherme Gielow)      
                            
                27/11/2013 - Ajuste no e-mail de monitoracao (David).
                
                19/12/2013 - Adicionado validate para as tabelas craptoj,
                             craplot, craplau (Tiago).
                             
                24/03/2013 - Retirar FIND FIRST desnecessarios. 
                             Retirar tratamento de sequencia na craptoj.
                             (Gabriel).             
                             
                02/04/2014 - Ajuste monitoracao pagamentos, verificando se o
                             IP do pagamento eh igual ao IP dos ultimos 3
                             acessos (David).
                             
                09/05/2014 - Ajustado as procedures paga_titulo e paga_convenio
                             fixado valor nrdolote e cdbccxlt na criacao CRAPLCM
                             (Daniel).
                             
                10/06/2014 - Ajuste em proc. debita-agendamento-transferencia
                             para passar parametro tpoperac correto. 
                             (Jorge/Thiago) - Emergencial.                    

                15/07/2014 - Adicionado proc. verifica_situacao_transacao 
                             para validar se existem transacoes que possuem 
                             status pendente e serao atualizadas.
                             (Douglas - Chamado 178989)
                             
                13/08/2014 - Inclusao do parametro par_dshistor na verifica-dados-ted
                             em funçao da Obrigatoriedade do campo Histórico para 
                             TED/DOC com Finalidade "Outros" (Vanessa)
                             
                07/08/2014 - Nao sera configurada data limite para agendamentos 
                             provenientes de conta migrada da Concredi e
                             Credimilsul (David).
                             
                19/08/2014 - Alterado forma de execuçao da procedure b2crap14
                             gera-titulos-iptu para procedure Oracle package
                             CXON0014.pc_gera_titulos_iptu_prog. 
                             (Rafael). Liberaçao Outubro/2014
                            
                22/08/2014 - Alterado forma de execuçao da procedure b2crap14
                             retorna-valores-titulo-iptu para procedure Oracle 
                             package CXON0014.pc_retorna_vlr_titulo_iptu. 
                             (Rafael). Liberaçao Outubro/2014
                             
                03/09/2014 - Alteraçao na verifica_convenio para apenas validar
                             código de barras caso seja inclusao de Débito
                             Automático (Lucas Lunelli - Projeto Débito Fácil)
                             Liberaçao Outubro/2014.
                             
                19/09/2014 - Adicionado parametros de saida par_msgofatr e
                             par_cdempcon na procedure paga_convenio.
                             (Debito Automatico Facil) - (Fabricio)
                             
                16/10/2014 - (Chamado 161844) Tratamento para caso nao seja dia util
                             nao mais bloquear o agendamento, apenas buscar proximo 
                             dia util(Tiago Castro - RKAM).
                             
                22/10/2014 - Incluir novos campos na tela PARMON. Chamado 198702
                             (Jonata-RKAM).
                             
                04/11/2014 - Ajuste para implementar paginacao em proc.
                             busca_transacoes.
                             (Jorge/Elton - SD 197579)
                             
                09/12/2014 - Ajuste na procedure paga_convenio para somente
                             ofertar cadastro no Debito Automatico Facil se
                             efetivamente a empresa possuir o convenio de
                             debito automatico ativo.
                             (Chamado 228407) - (Fabricio)
                            
                11/12/2014 - Conversão da fn_sequence para procedure para não
                             gerar cursores abertos no Oracle. (Dionathan)
                             
                19/01/2015 - Permitir informar o cedente nos convenios
                            (Chamado 235532). (Jonata - RKAM)
                            
                21/01/2015 - Remover validação que verifica se eh cobranca 
                             registrada da cooperativa na paga_titulo
                             (Douglas - Chamado 228302)
                             
                02/02/2015 - Adicionado informacoes de operador que agendou e IP
                             no email enviado para verificacao de fraude.
                             (Jorge/Elton) - SD 238239
                             
                27/02/2015 - Ajuste em proc. efetua_transacoes, botado o Transaction
                             dentro do loop de pagamentos ao invez de realizar por 
                             fora. Cada pagamento será uma transacao.
                             (Jorge/Elton) - SD 248228   
                             
                06/03/2015 - Correção da passagem de valor para temp-table 
                             "tt-dados-agendamen" onde estava sendo passado
                             nulo e na leitura dele para montar o xml acabava
                             atrapalhando a montagem. (SD - 248540 Kelvin)
                             
                01/04/2015 - Ajuste na descricao do convenio (Jonata-RKAM).    
                
                08/04/2015 - Incluso tratamento para evitar LOCK da tabela craplot
                             (Daniel/Rodrigo)          

                10/04/2015 - Alterado o tratamento de RETURN-VALUE de = "NOK" para <> "OK"
                             na estorna_convenio.  (Jean (RKAM) - SD 269757 )          

                14/05/2015 - Alterado o tratamento de RETURN-VALUE de = "NOK" 
                             para <> "OK" na estorna_titulo e tbm inclusao de
                             LENGTH(TRIM(par_dsprotoc)) = 0 nas procedures 
                             estorna_titulo e estorna_convenio. 
                             (Jaison/Elton - SD: 280398)
                
                07/07/2015 - Adicionado valor para o parametro par_cdispbif da 
                             b1wgen0015 (Douglas)
                             
                03/08/2015 - Ajuste para retirar o caminho absoluto na 
                             chamada dos fontes
                             (Adriano - SD 314469).

                05/08/2015 - Adicionar parametros para gravação do campo 
                             craptoj.idtitdda (Douglas - Chamado 291387)
  
                17/08/2015 - Incluir validacao para a data limite para agendamentos
                             nas procedures verifica_convenio e verifica_titulo
                             (Lucas Ranghetti #312614 ).    
                             
                23/09/2015 - Inclusao dos parametros tpcptdoc nas chamadas das rotinas
                             paga_titulo e paga_convenio SD337839 (Odirlei-Amcom)

                30/09/2015 - Remover as procedures debita-agendamento-transferencia
                             e debita-agendamento-pagamento que estão convertidas 
                             em Oracle, e nenhum fonte utiliza mais essas procedures.
                             Removidas na versão 1042 do fonte.
                             (Douglas - Chamado 285228 obtem-saldo-dia)
                             
                20/10/2015 - Incluir procedure gera_arquivo_log_ted para gerar log
                             caso haja o return seja <> "OK" (Lucas ranghetti/Elton #343312)
                             
                27/10/2015 - Alteracao na obtem-agendamentos para contemplar os
                             Agendamentos GPS feitos no CAIXA (Guilherme/SUPERO)
                             
                11/11/2015 - Tratamento no calculo de digito para comprovante
                            (TIAGO)  
				
                19/11/2015 - As procedures paga_convenio e paga_titulo foram
                             ajustadas para não registrar dados do preposto na 
                             geração do comprovante, PRJ. Ass. Conjunta. (Jean Michel)
                
                27/11/2015 - Na procedure convenios_aceitos, incluir mensagem
                             na hora de estorno para os convenios Secretaria de 
                             Estado da Fazenda SEFAZ (GNRE e DARE) e Samae Brusque
                             (Lucas Ranghetti #354764)

                01/12/2015 - Alterada a obtem-agendamento para tratar GPS, sem
                             permitir excluir o agendamento (Guilherme/SUPERO)

                03/12/2015 - Removida as procedures cria_transacao_operador e
                             cria_transacao_operador_registro, Prj. Ass. Conjunta.
                             (Jean Michel).
                             
                04/12/2015 - Prj 131. Ajustadas procedures verifica_convenio,
                             verifica_titulo e paga_titulo para utilizar a nova 
                             estrutura de aprovação conjunta. (Reinert)
                             
                10/12/2015 - Inclusao da procedure aprova_trans_pend para
                             Prj. Assinatura Conjunta (Jean Michel).
                             
                16/12/2015 - Ajustes para ajustar procedimento para expirar 
                             transacoes pendentes. (Jorge/David) - Proj. 131
                15/01/2015 - Retirada da proc. verifica_sit_transacao,
                              busca_transacoes, exclui_transacoes,
                              altera_situacao_transacao 
                              conforme Proj. 131. (Jorge/David)
							  
                25/02/2016 - Remover a utilizacao da tabela crapcti e utilizar
				             os campos tbspb_trans_pend quando disponiveis 
							 (Marcos-Supero)

				15/04/2016 - Feito ajustes para o projeto 218. (Reinert)

				01/03/2016 - Ajustar envio de parametro na procedure de 
				             envio de TED na aprovacao de transacoes 
							 pendentes (David).

			   07/03/2016 - Adicionado RELEASE da craplot para retirar o lock da tabela
				            apos utilizada.
                          - Incluido log para leitura da craplot nos pagamentos 
                            (Lucas Ranghetti/Fabricio)

               24/03/2016 - Adicionados parâmetros para geraçao de LOG
                            (Lucas Lunelli - PROJ290 Cartao CECRED no CaixaOnline)

			   25/04/2016 - Ajustes para que a rotina de cancelamento de agendamentos
					        possa ser utilizada pela tela AGENET
							(Adriano - M117).
		
			   04/05/2016 - Ajustes na rotina obtem-agendamentos para encontrar corretamente
						    o banco e agencia para agendamentos de TED
							(Adriano - M117)

			   06/05/2016 - Ajuste realizados:
							-> Pegar o numero da conta destino corretamente;
							-> Retirar as rotinas agendamento-recorrente, cadastrar-agendamento
							   pois elas já estão convertidas e os fontes que as chamaão foram ajustados
							   para utilizar a sua respectiva conversão
						    (Adriano - M117).
	
	          19/05/2016 - Ajustes realizados:
					       -> Realizado a inclusao da rotina cadastrar-agendamento;
						   -> Incluido aprovação de agendamento de TED para assintura conjunta						   
						   (Adriano - M117).

			  24/05/2016 - Ajuste para retirar parametros de saída na chamada da rotina responsável
			               pelo cadastro de agendamentos
						   (Adriano - M117).

              24/05/2016 - Ajuste da rotina b1wgen0016.consultar_parmon alterar_parmon e log-tela-parmon
                           com flag de monitoracao de agendamento de TED (Carlos)
	
			  31/05/2016 - Ajuste na rotina de cancelamento de agendamentos para validar corremente
						   o periodo limite para cancelamento de TED.
						   (Adriano).

                30/05/2016 - Alteraçoes Oferta DEBAUT Sicredi (Lucas Lunelli - [PROJ320])
               
              29/06/2016 - Ajustado procedure aprova-trans_pend para que as variaveis de critica
                           sejam limpas a cada registro processado para que quando ocorrer uma 
                           critica ela nao pare o processamento do proximo registro
                           (Douglas - Chamado 462368)

              01/07/2016 - Adicionar o idtitdda no arquivo de LOG (Douglas - Chamado 462368)
              
              04/07/2016 - Ajustado para que o parametro par_idtitdda seja passado como STRING
                           na chamada da procedure pc_cadastrar_agendamento
                           (Douglas - Chamado 462368)
                           
              20/07/2016 - Inclusao dos parametros pr_cdfinali, pr_dstransf e pr_dshistor 
                           na rotina pc_cadastrar_agendamento (Carlos)

			  21/07/2016 - Ajuste para utilizar campos corretos na rotina aprova_trans_pend para o  
						   tipo de transacao TED
						  (Adriano).
			  
			  28/07/2016 - #483548 Merge da PROD. Correcao de cpf passado para procedure 
                           pc_verifica_operacao_prog nas operacoes de transferencias (Carlos)
			
              04/08/2016 - Conversao das procedures obtem-agendamentos, parametros-cancelamento p/
						   PLSQL e ajustes na aprova_trans_pend, Pjr. 338 (Jean Michel).

              01/09/2016 - Alteracao da procedure aprova_trans_pend para aprovacao de
						   transacoes com quantidade minima de assinaturas, SD 514239 (Jean Michel).
        
              19/09/2016 - Alteraçoes pagamento/agendamento de DARF/DAS pelo InternetBanking (Projeto 338 - Lucas Lunelli)

			  06/09/2016 - Ajuste no horario de permissao de cancelamento de agendamento de TED
						   (Adriano - SD 509480).
                           
              15/09/2016 - Caso for agendamento de GPS alterar aux_incancel para passar 3 (Lucas Ranghetti #501845)
			               
              26/09/2016 - Ajuste para enviar mais de um email para monitoracao de fraude
                           qdo o corpo do email ultrapassar 25 titulos pois estava
                           acarretando em problemas no IB (Tiago/Elton SD 521667).             
						   
              19/12/2016 - Inclusao da aprovacao de Desconto de Cheque. Projeto 300 (Lombardi).
              
28/11/2016 - Incluido tratamento de transaçoes pendentes 16 e 17.
PRJ319 - SMS Cobrança (Odirlei - AMcom)

			  22/11/2016 - Inclusao do parametro pr_iptransa na chamada da rotina pc_cadastrar_agendamento.
                           PRJ335 - Analise de Fraude (Odirlei-AMcom ) 
 
			  07/12/2016 - P341-Automatização BACENJUD - Alterar o uso da descrição do
                           departamento passando a considerar o código (Renato Darosci)           

              29/12/2016 - Tratamento Nova Plataforma de cobrança PRJ340 - NPC (Odirlei-AMcom)  

              07/02/2017 - Alterado procedures paga_titulo e verifica_titulo para chamar 
                           suas respectivas rotinas convertidas oracle.
                           PRJ340 - NPC (Odirlei-AMcom)   

			  22/02/2017 - Ajustes para correçao de crítica de 
                           pagamento DARF/DAS (Lucas Lunelli - P.349.2)  
              
              17/03/2017 - Incluido campos na chamada da rotina pc_gera_contrato_sms.
                           PRJ319.2 - SMS Cobrança (Odirlei - AMcom)             
              
              12/04/2017 - Incluido tratamento de transaçoes pendentes 13. 
                           PRJ319 - Recarga de Celular (Lombardi)

              20/04/2017 - Ajustes da NPC para o processo de pagamento com multiplas 
                           assitaturas (Renato Darosci - P340)  
              
              02/06/2017 - Ajustes referentes ao Novo Catalogo do SPB(Lucas Ranghetti #668207)

              14/06/2017 - Incluido comando TRUNC para cortar o valor de iof em 2 casas
                           decimais, estava falhando comparacao devido ao arredondamento.
                           Heitor (Mouts) - Chamado 688338

			  31/07/2017 - Alterado parametro par_cdcltrcs de INTEGER para CHAR. (Rafael)

              04/09/2017 - Permitir estorno de boletos pagos pelo DDA. (Rafael/Ademir)

              05/09/2017 - Ajuste no numero do lote de estorno de pagto de títulos para 11900. (Rafael)
              
              11/09/2017 - Adicionado campos para consulta de agendamento de GPS
                           xml_operacao38 (Projeto 356.2  - Ricardo Linhares).
                           
              14/09/2017 - Adicionar no campo nrrefere como String (Lucas Ranghetti #756034)
			  
              11/09/2017 - Adicionado campos para consulta de agendamento de GPS
                           xml_operacao38 (Projeto 356.2  - Ricardo Linhares).

              26/09/2017 - Alterar as rotinas verifica_convenio e paga_convenio para que chamem as 
                           respectivas rotinas convertidas em Oracle (Lucas Ranghetti #759781)
                           
              24/11/2017 - Forcar que o tipo de operacao seja 2 na chamada da pc_verifica_operacao_prog
                           quando for aprovar transacao pendente de GPS (David).
                           
			  
              21/09/2017 - Ajustar procedure convenios_aceitos para indicar os convenios que podem
                           ser cadastrados para debito automatico (David).
                           
              27/11/2017 - Encontrar agendamento para cancelamento atraves do parametro idlancto (David)
						   
              12/12/2017 - Alterar campo flgcnvsi por tparrecd.
                           PRJ406-FGTS (Odirlei-AMcom)
              
              
              07/12/2018 - Adicionar a opcao de regaste de custodia, opcao 18
                           (Rafael Monteiro - MoutS)

              28/02/2018 - Alterar procedure convenios_aceitos para retornar o nome resumido mais amigavel, 
                           conforme acontece na b1wgen0092.busca_convenios_codbarras. (Anderson - P285)
						  
              21/03/2018 - Validar corretamente o retorno de critica na paga_titulo (Lucas Ranghetti INC0010520)

              05/04/2018 - Validar horario da DEBSIC ao aprovar agendamento de pagamento/darf-das
			               nas transacoes pendentes (Lucas Ranghetti INC0011214)

			  23/04/2018 - Conversao das rotinas de estorno e 
                           inclusao dos parametros para geracao da analise de fraude
                           PRJ381 - Antifraude (Odirlei-AMcom)

              20/05/2018 - Adicionado tratamento com a tabela tbdsct_trans_pend (Paulo Penteado GFT)

              05/02/2019 - Alterada rotina cadastrar-agendamento para passar o parametro do codigo de controle 
                           da consulta na cip corretamente (Tiago PRB0040595)

              10/12/2018 - Tratar novos tbgen_trans_pend.tptransacao
                           20 /* Contrato */
                           Projeto 470 - Marcelo Telleas Coelho

              08/05/2019 - Ajustar parametros na chamada da pc_cadastrar_agendamento (Renato - Supero - P485)
              20/02/2019 - Adicionado tratamento para contratacao de emprestimo opçao 20. 
                          (PRJ438 Douglas / AMcom).
                          
              07/03/2019 - Inclusao registro de assinatura na aprovacao de transacao de emprestimo.
                           (PRJ438 Douglas / AMcom).
              
              25/05/2019 - Ajuste na utilizacao do PLSQL_altera_session_, para quando nao for 
                           um bloco transactio utilizar a include que inclui este bloco.
                           PRJ438 - Agilidade de credito (Odirlei)          
              

              10/06/2019 - Ajustes para atender o TED Judicial. Tratamento do tipo de transacao novo (22 - Ted Judicial).
                           Jose Dill - Mouts (P475 - REQ39)
 .....................................................................................................*/
{ sistema/internet/includes/var_ibank.i }


{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0015tt.i }
{ sistema/generico/includes/b1wgen0016tt.i }
{ sistema/generico/includes/b1wgen0081tt.i }
{ sistema/generico/includes/b1wgen0119tt.i }
{ sistema/generico/includes/b1wgen0188tt.i  }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

{ sistema/internet/includes/b1wnet0002tt.i }

DEF TEMP-TABLE crataut NO-UNDO LIKE crapaut.
DEF TEMP-TABLE cratlot NO-UNDO LIKE craplot.
DEF TEMP-TABLE cratlcm NO-UNDO LIKE craplcm.
DEF TEMP-TABLE cratmvi NO-UNDO LIKE crapmvi.

/* TEMP-TABLES PARA O PRJ. ASSINATURA CONJUNTA */
DEF TEMP-TABLE tt-tbgen_trans_pend NO-UNDO LIKE tbgen_trans_pend
    FIELD idordem_efetivacao AS INT
    FIELD idmovimento_conta AS INT.

DEF TEMP-TABLE tt-tbpagto_trans_pend  NO-UNDO LIKE tbpagto_trans_pend.
DEF TEMP-TABLE tt-tbspb_trans_pend    NO-UNDO LIKE tbspb_trans_pend.
DEF TEMP-TABLE tt-tbtransf_trans_pend NO-UNDO LIKE tbtransf_trans_pend.
DEF TEMP-TABLE tt-tbepr_trans_pend    NO-UNDO LIKE tbepr_trans_pend.
DEF TEMP-TABLE tt-tbcapt_trans_pend   NO-UNDO LIKE tbcapt_trans_pend.
DEF TEMP-TABLE tt-tbconv_trans_pend   NO-UNDO LIKE tbconv_trans_pend.
DEF TEMP-TABLE tt-tbfolha_trans_pend  NO-UNDO LIKE tbfolha_trans_pend.
DEF TEMP-TABLE tt-tbtarif_pacote_trans_pend NO-UNDO LIKE tbtarif_pacote_trans_pend.
DEF TEMP-TABLE tt-tbcobran_sms_trans_pend  NO-UNDO LIKE tbcobran_sms_trans_pend.
DEF TEMP-TABLE tt-tbdscc_trans_pend   NO-UNDO LIKE tbdscc_trans_pend.  
DEF TEMP-TABLE tt-tbrecarga_trans_pend        NO-UNDO LIKE tbrecarga_trans_pend.
DEF TEMP-TABLE tt-pagtos-mon NO-UNDO
    FIELD nrsequen AS INTE
    FIELD dslinhas AS CHAR.
DEF TEMP-TABLE tt-tbdsct_trans_pend         NO-UNDO LIKE tbdsct_trans_pend.

DEF VAR glb_dsprotoc   AS CHAR                                      NO-UNDO.

DEF VAR aux_tab_limite AS LONGCHAR                                  NO-UNDO.
DEF VAR xml_dsmsgerr   AS CHAR                                      NO-UNDO.

FUNCTION IdentificaMovCC RETURNS INTEGER
     (INPUT par_tptransacao   AS INTEGER,
      INPUT par_idagendamento AS INTEGER,
      INPUT par_tpoperacao    AS INTEGER) FORWARD.

PROCEDURE verifica_convenio:

    DEF INPUT         PARAM par_cdcooper LIKE crapcop.cdcooper      NO-UNDO.
    DEF INPUT         PARAM par_nrdconta LIKE crapttl.nrdconta      NO-UNDO.
    DEF INPUT         PARAM par_idseqttl LIKE crapttl.idseqttl      NO-UNDO.
    DEF INPUT         PARAM par_idagenda AS INTE                    NO-UNDO.
    DEF INPUT-OUTPUT  PARAM par_lindigi1 AS DECI                    NO-UNDO.
    DEF INPUT-OUTPUT  PARAM par_lindigi2 AS DECI                    NO-UNDO.
    DEF INPUT-OUTPUT  PARAM par_lindigi3 AS DECI                    NO-UNDO.
    DEF INPUT-OUTPUT  PARAM par_lindigi4 AS DECI                    NO-UNDO.
    DEF INPUT-OUTPUT  PARAM par_cdbarras AS CHAR                    NO-UNDO.
    DEF INPUT-OUTPUT  PARAM par_dtvencto AS DATE                    NO-UNDO.
    DEF INPUT-OUTPUT  PARAM par_vllanmto AS DECI                    NO-UNDO.
    DEF INPUT         PARAM par_dtagenda AS DATE                    NO-UNDO.
    DEF INPUT         PARAM par_idorigem AS INT                     NO-UNDO.
    DEF INPUT         PARAM par_indvalid AS INT                     NO-UNDO.
    DEF OUTPUT        PARAM par_nmextcon AS CHAR                    NO-UNDO.
    DEF OUTPUT        PARAM par_cdseqfat AS DECI                    NO-UNDO.
    DEF OUTPUT        PARAM par_vlfatura AS DECI                    NO-UNDO.
    DEF OUTPUT        PARAM par_nrdigfat AS INTE                    NO-UNDO.
    DEF OUTPUT        PARAM par_dstransa AS CHAR                    NO-UNDO.
    DEF OUTPUT        PARAM par_dscritic LIKE crapcri.dscritic      NO-UNDO.

    DEF VAR aux_cdcritic                 AS INTE                    NO-UNDO.

    /* Utilizar a procedure Oracle PAGA0001.pc_verifica_convenio_prog */
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_verifica_convenio_prog
        aux_handproc = PROC-HANDLE NO-ERROR
                         ( INPUT par_cdcooper /* Codigo da cooperativa */
                         , INPUT par_nrdconta /* Numero da conta */
                         , INPUT par_idseqttl /* Sequencial titular */
                         , INPUT par_idagenda /* Indicador agendamento */
                         , INPUT-OUTPUT par_lindigi1 /* Linha digitavel 1 */
                         , INPUT-OUTPUT par_lindigi2 /* Linha digitavel 2 */
                         , INPUT-OUTPUT par_lindigi3 /* Linha digitavel 3 */
                         , INPUT-OUTPUT par_lindigi4 /* Linha digitavel 4 */
                         , INPUT-OUTPUT par_cdbarras /* Codigo de Barras */
                         , INPUT-OUTPUT par_dtvencto /* Data Vencimento */
                         , INPUT-OUTPUT par_vllanmto /* Valor Lancamento */
                         , INPUT par_dtagenda /* Data agendamento */
                         , INPUT par_idorigem /* Indicador de origem */
                         , INPUT par_indvalid /* Indicador se ja foi feito */
                         ,OUTPUT ""   /* Nome do banco */
                         ,OUTPUT ""   /* Codigo Sequencial fatura */
                         ,OUTPUT 0    /* Valor fatura */
                         ,OUTPUT 0    /* Numero Digito Fatura */
                         ,OUTPUT ""   /* Descricao transacao */
                         ,OUTPUT 0    /* Codigo da critica */
                         ,OUTPUT ""). /* Descricao critica */

    CLOSE STORED-PROC pc_verifica_convenio_prog
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                
    ASSIGN par_nmextcon = ""
           par_cdseqfat = 0
           par_vlfatura = 0
           par_nrdigfat = 0
           par_dstransa = ""
           aux_cdcritic = 0
           par_dscritic = ""
                
           par_lindigi1 =  DECI(pc_verifica_convenio_prog.pr_lindigi1) /* IN OUT */
           par_lindigi2 =  DECI(pc_verifica_convenio_prog.pr_lindigi2) /* IN OUT */
           par_lindigi3 =  DECI(pc_verifica_convenio_prog.pr_lindigi3) /* IN OUT */
           par_lindigi4 =  DECI(pc_verifica_convenio_prog.pr_lindigi4) /* IN OUT */
           par_cdbarras =  pc_verifica_convenio_prog.pr_cdbarras       /* IN OUT */ 
           par_dtvencto =  DATE(pc_verifica_convenio_prog.pr_dtvencto) /* IN OUT */
           par_vllanmto =  DECI(pc_verifica_convenio_prog.pr_vllanmto) /* IN OUT */
                
           par_nmextcon = pc_verifica_convenio_prog.pr_nmextcon
                          WHEN pc_verifica_convenio_prog.pr_nmextcon <> ?
           par_cdseqfat = DECI(pc_verifica_convenio_prog.pr_cdseqfat)
                          WHEN pc_verifica_convenio_prog.pr_cdseqfat <> ?
           par_vlfatura = DECI(pc_verifica_convenio_prog.pr_vlfatura)
                          WHEN pc_verifica_convenio_prog.pr_vlfatura <> ?
           par_nrdigfat = INT(pc_verifica_convenio_prog.pr_nrdigfat)
                          WHEN pc_verifica_convenio_prog.pr_nrdigfat <> ?
           par_dstransa = pc_verifica_convenio_prog.pr_dstransa
                          WHEN pc_verifica_convenio_prog.pr_dstransa <> ?
           aux_cdcritic = INT(pc_verifica_convenio_prog.pr_cdcritic)
                          WHEN pc_verifica_convenio_prog.pr_cdcritic <> ?
           par_dscritic = pc_verifica_convenio_prog.pr_dscritic
                          WHEN pc_verifica_convenio_prog.pr_dscritic <> ?.
                

    /* Se houveram criticas, retorno NOK */
    IF  aux_cdcritic > 0 OR par_dscritic <> "" THEN
                        RETURN "NOK".
    
    RETURN "OK".

END PROCEDURE.

/******************************************************************************/
/**    Procedure para atualizar o registro de transacao para nao efetivado   **/
/******************************************************************************/
PROCEDURE atualiza_transacoes_nao_efetivadas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.


    DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
    DEF VAR aux_dssgproc AS CHAR                                    NO-UNDO.
    DEF VAR aux_dstransa AS CHAR                                    NO-UNDO.
    
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
    
    RUN STORED-PROCEDURE pc_atualiza_trans_nao_efetiv
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_nrdconta,
                          INPUT par_cdagenci,
                          INPUT par_dtmvtolt,
                         OUTPUT "",  /* pr_dstransa */
                         OUTPUT  0,  /* pr_cdcritic */
                         OUTPUT ""). /* pr_dscritic */

    CLOSE STORED-PROC pc_atualiza_trans_nao_efetiv
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
    
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           par_dscritic = ""
           aux_dstransa = ""                        
           aux_dstransa = pc_atualiza_trans_nao_efetiv.pr_dstransa
                          WHEN pc_atualiza_trans_nao_efetiv.pr_dstransa <> ?
           aux_cdcritic = pc_atualiza_trans_nao_efetiv.pr_cdcritic 
                          WHEN pc_atualiza_trans_nao_efetiv.pr_cdcritic <> ?
           par_dscritic = pc_atualiza_trans_nao_efetiv.pr_dscritic 
                          WHEN pc_atualiza_trans_nao_efetiv.pr_dscritic <> ?.

    IF  aux_cdcritic > 0 OR par_dscritic <> "" THEN
        DO:
        IF aux_cdcritic > 0 THEN
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 900,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT par_dscritic).
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

/* procedure de auxilio a efetiva_transacoes */
PROCEDURE proc_cria_critica_transacao_oper:

    DEFINE INPUT  PARAMETER par_nrdrowid AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_aprovada AS LOGICAL     NO-UNDO.
	DEFINE INPUT  PARAMETER par_indvalid AS INTE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dscritic AS CHARACTER   NO-UNDO.

    DEF BUFFER crabcop FOR crapcop.
    DEF BUFFER crabass FOR crapass.

    DEF VAR aux_nmtitdst AS CHAR NO-UNDO.
    DEF VAR aux_nmabrevi AS CHAR NO-UNDO.
    DEF VAR aux_dtdebito AS CHAR NO-UNDO.
    DEF VAR aux_vllantra AS DEC  NO-UNDO.
    DEF VAR aux_dscedent AS CHAR NO-UNDO.
    DEF VAR aux_dstptran AS CHAR NO-UNDO INIT "APLICACAO".
    DEF VAR aux_sldresga AS DEC  NO-UNDO.
    DEF VAR aux_dstiptra AS CHAR  NO-UNDO.
    DEF VAR aux_vltotbdc AS DECI NO-UNDO.					   
    DEF VAR aux_resposta AS CHAR NO-UNDO.
    DEF VAR aux_vltotbdt AS DECI NO-UNDO.
    
    DEF VAR h-b1wgen9999 AS HANDLE NO-UNDO.
    DEF VAR h-b1wgen0081 AS HANDLE NO-UNDO.
        
    /* Variáveis utilizadas para receber clob da rotina no oracle */
    DEF VAR xDoc          AS HANDLE   NO-UNDO.   
    DEF VAR xRoot         AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
    DEF VAR xField        AS HANDLE   NO-UNDO. 
    DEF VAR xText         AS HANDLE   NO-UNDO. 

    DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
        
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR NO-UNDO.
        
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
       
    IF  VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            FIND tbgen_trans_pend WHERE ROWID(tbgen_trans_pend) = TO-ROWID(par_nrdrowid) NO-LOCK NO-ERROR.

            IF  AVAILABLE tbgen_trans_pend  THEN
            DO:
                IF  tbgen_trans_pend.tptransacao = 1  OR    /** Trans. intracoop. **/
                    tbgen_trans_pend.tptransacao = 5  OR    /** Trans. intercoop. **/
                    tbgen_trans_pend.tptransacao = 3  THEN  /** CREDITO SALARIO   **/
                    DO:
                        FIND tbtransf_trans_pend 
                            WHERE tbtransf_trans_pend.cdtransacao_pendente = tbgen_trans_pend.cdtransacao_pendente
                            NO-LOCK NO-ERROR NO-WAIT.
            
                        ASSIGN aux_dtdebito = (IF tbtransf_trans_pend.idagendamento = 1 THEN "Nesta Data" ELSE STRING(tbtransf_trans_pend.dtdebito,"99/99/9999"))
                               aux_vllantra = tbtransf_trans_pend.vltransferencia.

                        FIND crabcop WHERE crabcop.cdagectl = tbtransf_trans_pend.cdagencia_coop_destino
                                       NO-LOCK NO-ERROR.

                        IF  AVAIL crabcop THEN 
                        DO:
                            FIND crabass WHERE 
                                 crabass.cdcooper = crabcop.cdcooper     AND
                                     crabass.nrdconta = INTE(tbtransf_trans_pend.nrconta_destino)
                                 NO-LOCK NO-ERROR.
                            END.
                                
                        ASSIGN aux_nmabrevi = "".
        
                            IF  AVAIL crabass  THEN
                                DO:
                                    IF  LENGTH(crabass.nmprimtl) > 20  THEN
                                    ASSIGN aux_nmabrevi = "-" + SUBSTR(crabass.nmprimtl,1,20).
                                    ELSE
                                
                                        ASSIGN aux_nmabrevi = "-" + crabass.nmprimtl.
                                END.

                        ASSIGN aux_dscedent = STRING(tbtransf_trans_pend.cdagencia_coop_destino) + 
                                              "/" +  
                                              TRIM(STRING(tbtransf_trans_pend.nrconta_destino))
                               aux_dscedent = aux_dscedent + aux_nmabrevi.
                END.                
            ELSE
                    IF  tbgen_trans_pend.tptransacao = 4  
                     OR tbgen_trans_pend.tptransacao = 22 /*REQ39*/
                                                          THEN /** TED **/ 
                DO: 

                        FIND tbspb_trans_pend 
                            WHERE tbspb_trans_pend.cdtransacao_pendente = tbgen_trans_pend.cdtransacao_pendente
                            NO-LOCK NO-ERROR NO-WAIT.

                        ASSIGN aux_dtdebito = (IF tbspb_trans_pend.idagendamento = 1 THEN "Nesta Data" ELSE STRING(tbspb_trans_pend.dtdebito,"99/99/9999"))
                               aux_vllantra = tbspb_trans_pend.vlted.

                        ASSIGN aux_nmtitdst = tbspb_trans_pend.nmtitula_favorecido.
                        
                    IF  LENGTH(aux_nmtitdst) > 20  THEN
                            ASSIGN aux_nmabrevi = "-" + SUBSTR(aux_nmtitdst,1,20).
                    ELSE
                        ASSIGN aux_nmabrevi = "-" + aux_nmtitdst.

                        ASSIGN aux_dscedent = TRIM(STRING(tbspb_trans_pend.nrconta_favorecido, 
                                               "zzzzzzzzzzzz,9"))
                               aux_dscedent = aux_dscedent + aux_nmabrevi.
                END.
            ELSE
                    IF  tbgen_trans_pend.tptransacao = 2  THEN /** PAGAMENTO **/ 
                DO:      
                        FIND tbpagto_trans_pend 
                            WHERE tbpagto_trans_pend.cdtransacao_pendente = tbgen_trans_pend.cdtransacao_pendente
                            NO-LOCK NO-ERROR NO-WAIT.

                        ASSIGN aux_dtdebito = (IF tbpagto_trans_pend.idagendamento = 1 THEN "Nesta Data" ELSE STRING(tbpagto_trans_pend.dtdebito,"99/99/9999"))
                               aux_vllantra = tbpagto_trans_pend.vlpagamento
                               aux_dscedent = tbpagto_trans_pend.dscedente.

                END.
                ELSE
                    IF  tbgen_trans_pend.tptransacao = 6  THEN /** PRE APROVADO **/ 
    DO:
                        FIND tbepr_trans_pend 
                            WHERE tbepr_trans_pend.cdtransacao_pendente = tbgen_trans_pend.cdtransacao_pendente
                            NO-LOCK NO-ERROR NO-WAIT.

                        ASSIGN aux_dtdebito = "Nesta Data"
                               aux_vllantra = tbepr_trans_pend.vlemprestimo
                               aux_dscedent = "CREDITO PRE-APROVADO - " + STRING(tbepr_trans_pend.nrparcelas) + " vezes de R$ " + STRING(tbepr_trans_pend.vlparcela).
    END.
    ELSE
                    IF  tbgen_trans_pend.tptransacao = 7  THEN /** APLICACAO **/ 
    DO:
                        FIND tbcapt_trans_pend 
                            WHERE tbcapt_trans_pend.cdtransacao_pendente = tbgen_trans_pend.cdtransacao_pendente
                            NO-LOCK NO-ERROR NO-WAIT.

                        IF  tbcapt_trans_pend.tpoperacao = 1 THEN /* Cancelamento Aplicacao */
            DO:
                                FIND craprda WHERE craprda.cdcooper = tbcapt_trans_pend.cdcooper
                                               AND craprda.nrdconta = tbcapt_trans_pend.nrdconta 
                                               AND craprda.nraplica = tbcapt_trans_pend.nraplicacao NO-LOCK NO-ERROR NO-WAIT.

                                IF  AVAIL craprda  THEN
                                    ASSIGN aux_vllantra = craprda.vlaplica
                                           aux_dtdebito = "Nesta Data"
                                           aux_dscedent = "CANCELAMENTO APLICACAO NR. " + STRING(tbcapt_trans_pend.nraplicacao)
                                           aux_dstptran = "Cancelamento Aplicacao".
    END.
                            ELSE 
                            IF  tbcapt_trans_pend.tpoperacao = 2 THEN /* Resgate */
                    DO:
                                FOR FIRST crapdat FIELDS(dtmvtolt) WHERE crapdat.cdcooper = tbcapt_trans_pend.cdcooper NO-LOCK. END.
    
                                /* Inicializando objetos para leitura do XML */ 
                                CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
                                CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
                                CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
                                CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
                                CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
               
                                { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} } 

                                /* Efetuar a chamada a rotina Oracle */ 
                                RUN STORED-PROCEDURE pc_lista_aplicacoes_car
                                 aux_handproc = PROC-HANDLE NO-ERROR (INPUT tbcapt_trans_pend.cdcooper,    /* Código da Cooperativa */
                                                                      INPUT "996",                         /* Código do Operador */
                                                                      INPUT "INTERNETBANK",                /* Nome da Tela */
                                                                      INPUT 3,                             /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                                                      INPUT 900,                           /* Numero do Caixa */
                                                                      INPUT tbcapt_trans_pend.nrdconta,    /* Número da Conta */
                                                                      INPUT 1,                             /* Titular da Conta */
                                                                      INPUT 1,                             /* Codigo da Agencia */
                                                                      INPUT "INTERNETBANK",                /* Codigo do Programa */
                                                                      INPUT tbcapt_trans_pend.nraplicacao, /* Número da Aplicação - Parâmetro Opcional */
                                                                      INPUT 0,                             /* Código do Produto – Parâmetro Opcional */ 
                                                                      INPUT crapdat.dtmvtolt,              /* Data de Movimento */
                                                                      INPUT 5,                             /* Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas) */
                                                                      INPUT 1,                             /* Identificador de Log (0 – Não / 1 – Sim) */                                                                                                                                  
                                                                     OUTPUT ?,                             /* XML com informações de LOG */
                                                                     OUTPUT 0,                             /* Código da crítica */
                                                                     OUTPUT "").                           /* Descrição da crítica */

                                /* Fechar o procedimento para buscarmos o resultado */ 
                                CLOSE STORED-PROC pc_lista_aplicacoes_car
                                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                                { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} } 

                                EMPTY TEMP-TABLE tt-saldo-rdca.

                                /* Buscar o XML na tabela de retorno da procedure Progress */ 
                                ASSIGN xml_req = pc_lista_aplicacoes_car.pr_clobxmlc. 

                                /* Efetuar a leitura do XML*/ 
                                SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
                                PUT-STRING(ponteiro_xml,1) = xml_req. 

                                    IF  ponteiro_xml <> ? THEN
        DO:
                                        xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
                                        xDoc:GET-DOCUMENT-ELEMENT(xRoot).
                
                                        DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN:
                                           xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
                               
                                                IF  xRoot2:SUBTYPE <> "ELEMENT" THEN 
                                            NEXT. 

                                                IF  xRoot2:NUM-CHILDREN > 0 THEN               
                                               CREATE tt-saldo-rdca.     
        
                                           DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                                             xRoot2:GET-CHILD(xField,aux_cont).
        
                                             IF xField:SUBTYPE <> "ELEMENT" THEN 
                NEXT.

                                             xField:GET-CHILD(xText,1).

                                             ASSIGN tt-saldo-rdca.sldresga = DECI(xText:NODE-VALUE) WHEN xField:NAME = "sldresga".
            
                                             VALIDATE tt-saldo-rdca.
            END.
             
        END.
    
                                        SET-SIZE(ponteiro_xml) = 0.
    END.

                                FOR FIRST tt-saldo-rdca FIELDS(sldresga) NO-LOCK. END.
            
                                    IF  AVAIL tt-saldo-rdca THEN
                                    ASSIGN aux_sldresga = DEC(tt-saldo-rdca.sldresga).
            ELSE
                                    ASSIGN aux_sldresga = 0.
        
                                ASSIGN aux_vllantra = DEC(IF tbcapt_trans_pend.tpresgate = 1 THEN tbcapt_trans_pend.vlresgate ELSE aux_sldresga)
                                       aux_dtdebito = "Nesta Data"
                                       aux_dscedent = "RESGATE " + (IF tbcapt_trans_pend.tpresgate = 1 THEN "PARCIAL" ELSE "TOTAL") + " NA APLICACAO NR. " + STRING(tbcapt_trans_pend.nraplicacao)
                                       aux_dstptran = "Resgate de Aplicacao".
                END.
                            ELSE 
                            IF  tbcapt_trans_pend.tpoperacao = 3 THEN /* Agendamento Resgate */
        DO:
                                IF  tbcapt_trans_pend.idperiodo_agendamento = 0 THEN
                                    ASSIGN aux_dtdebito = STRING(tbcapt_trans_pend.dtinicio_agendamento,"99/99/9999").                    
        ELSE
            DO:        
                                        ASSIGN aux_dtdebito = STRING(DATE(MONTH(crapdat.dtmvtolt), tbcapt_trans_pend.nrdia_agendamento, YEAR(crapdat.dtmvtolt)),"99/99/9999").

                                        IF  DATE(aux_dtdebito) <= crapdat.dtmvtolt  THEN 
                                            ASSIGN aux_dtdebito = STRING(DATE(MONTH(ADD-INTERVAL(crapdat.dtmvtolt, 1, "MONTHS")), tbcapt_trans_pend.nrdia_agendamento, YEAR(ADD-INTERVAL(crapdat.dtmvtolt, 1, "MONTHS"))),"99/99/9999").
                                            END.
                                
                                ASSIGN aux_vllantra = tbcapt_trans_pend.vlresgate
                                       aux_dscedent = "RESGATE COM AGENDAMENTO " + (IF tbcapt_trans_pend.idperiodo_agendamento = 0 THEN "UNICO" ELSE "MENSAL")
                                       aux_dstptran = "Agendamento de Resgate".
                                    END.
                            ELSE 
                            IF  tbcapt_trans_pend.tpoperacao = 4 OR tbcapt_trans_pend.tpoperacao = 22 THEN /* Cancelamento Agendamento */ /*REQ39*/
                                    DO:
                                EMPTY TEMP-TABLE tt-agendamento.
    
                                IF NOT VALID-HANDLE(h-b1wgen0081)  THEN
                                    RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.
                    
                                RUN consulta-agendamento IN h-b1wgen0081(INPUT tbcapt_trans_pend.cdcooper,
                                                                         INPUT 90,
                                                                         INPUT 900,
                                                                         INPUT "996",
                                                                         INPUT tbcapt_trans_pend.nrdconta,
                                                                         INPUT 0,
                                                                         INPUT tbcapt_trans_pend.nrdocto_agendamento,
                                                                         INPUT 2,
                                                                             INPUT 0,
                                                                         INPUT "INTERNETBANK",    
                                                                         INPUT 3,
                                                                        OUTPUT TABLE tt-erro,
                                                                        OUTPUT TABLE tt-agendamento).
    
                                DELETE PROCEDURE h-b1wgen0081.
    
                                FIND FIRST tt-agendamento NO-LOCK NO-ERROR NO-WAIT.

                                IF  AVAIL tt-agendamento THEN
        DO:
                                        ASSIGN aux_dtdebito = STRING(tt-agendamento.dtiniaar,"99/99/9999").
                               
                                            IF  tt-agendamento.flgtipar = FALSE THEN /* Aplicacao */
                				            ASSIGN aux_dscedent = "CANCELAR APLICACAO COM AGENDAMENTO " + (IF tt-agendamento.flgtipin = FALSE THEN "UNICO" ELSE "MENSAL")
                				                   aux_dstptran = "Cancelamento Agendamento Aplicacao".
                			            ELSE /* Resgate */
                				            ASSIGN aux_dscedent = "CANCELAR RESGATE COM AGENDAMENTO " + (IF tt-agendamento.flgtipin = FALSE THEN "UNICO" ELSE "MENSAL")
                				                   aux_dstptran = "Cancelamento Agendamento Resgate".
                
                                        ASSIGN aux_vllantra = tt-agendamento.vlparaar.
        END.
    END.
                            ELSE 
                            IF  tbcapt_trans_pend.tpoperacao = 5 THEN /* Cancelamento Item Agendamento */
            DO:
                                EMPTY TEMP-TABLE tt-agen-det.

                                IF NOT VALID-HANDLE(h-b1wgen0081)  THEN
                                    RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.

                                RUN consulta-agendamento-det IN h-b1wgen0081(INPUT tbcapt_trans_pend.cdcooper,
                                                                             INPUT 90,                        
                                                                             INPUT 900,
                                                                             INPUT "996",
                                                                             INPUT tbcapt_trans_pend.nrdconta,
                                                                             INPUT 0,
                                                                             INPUT tbcapt_trans_pend.tpagendamento,
                                                                             INPUT INT(SUBSTR(STRING(tbcapt_trans_pend.nrdocto_agendamento),6,10)),
                                                                            OUTPUT TABLE tt-erro,
                                                                            OUTPUT TABLE tt-agen-det).
        
                                DELETE PROCEDURE h-b1wgen0081.

                                FOR EACH tt-agen-det NO-LOCK:

                                    IF  DECI(tt-agen-det.nrdocmto) <> tbcapt_trans_pend.nrdocto_agendamento THEN
                NEXT.

                                    ASSIGN aux_dtdebito = STRING(tt-agen-det.dtmvtopg,"99/99/9999")
                                           aux_vllantra = tt-agen-det.vllanaut.
                                                
                                    IF  tbcapt_trans_pend.tpagendamento = 0 THEN
                                        ASSIGN aux_dstptran = "Cancelamento Agendamento Aplicacao"
                                               aux_dscedent = "CANCELAR AGENDAMENTO APLICACAO".
                    ELSE
                                        ASSIGN aux_dstptran = "Cancelamento Agendamento Resgate"
                                               aux_dscedent = "CANCELAR AGENDAMENTO RESGATE".
    
                LEAVE.
               
                            END.
                                END.
                        END.
                    ELSE
                    IF  tbgen_trans_pend.tptransacao = 8  THEN /** DEBITO AUTOMATICO **/ 
                                DO:
                        FIND tbconv_trans_pend
                            WHERE tbconv_trans_pend.cdtransacao_pendente = tbgen_trans_pend.cdtransacao_pendente
                            NO-LOCK NO-ERROR NO-WAIT.

                
                        IF  tbconv_trans_pend.tpoperacao = 1  THEN
                            FOR FIRST crapcon WHERE crapcon.cdcooper = tbconv_trans_pend.cdcooper 
                                                AND crapcon.cdsegmto = tbconv_trans_pend.cdsegmento_conven 
                                                AND crapcon.cdempcon = tbconv_trans_pend.cdconven NO-LOCK. END.
                                                   ELSE
                        DO:
                                FOR FIRST crapatr WHERE crapatr.cdcooper = tbconv_trans_pend.cdcooper 
                                                    AND crapatr.nrdconta = tbconv_trans_pend.nrdconta 
                                                    AND crapatr.cdhistor = tbconv_trans_pend.cdhist_convenio 
                                                    AND crapatr.cdrefere = tbconv_trans_pend.nrdocumento_fatura
                                                    AND crapatr.tpautori <> 0 NO-LOCK. END.
                                                 
                                IF  AVAIL crapatr  THEN
                                DO:
                                        FOR FIRST crapcon WHERE crapcon.cdcooper = crapatr.cdcooper 
                                                            AND crapcon.cdsegmto = crapatr.cdsegmto 
                                                            AND crapcon.cdempcon = crapatr.cdempcon NO-LOCK. END.
        
                                        FOR FIRST craplau WHERE craplau.cdcooper = crapatr.cdcooper 
                                                            AND craplau.nrdconta = crapatr.nrdconta 
                                                            AND craplau.cdhistor = crapatr.cdhistor 
                                                            AND craplau.nrdocmto = crapatr.cdrefere
                                                            AND craplau.dtmvtopg = tbconv_trans_pend.dtdebito_fatura
                                                            AND craplau.insitlau = 1 NO-LOCK. END.
                        END.
                    END.

                        ASSIGN aux_dtdebito = (IF tbconv_trans_pend.tpoperacao = 1 THEN "Nesta Data" ELSE STRING(tbconv_trans_pend.dtdebito_fatura,"99/99/9999"))
                               aux_vllantra = (IF tbconv_trans_pend.tpoperacao = 1 OR NOT AVAIL craplau THEN 0 ELSE craplau.vllanaut)
                               aux_dscedent = (IF tbconv_trans_pend.tpoperacao = 2 THEN "BLOQUEIO" ELSE IF tbconv_trans_pend.tpoperacao = 3 THEN "DESBLOQUEIO" ELSE "") + " DEBITO AUTOMATICO " + (IF AVAIL crapcon THEN " - " + crapcon.nmrescon ELSE "").
                                END.
                    ELSE 
                    IF  tbgen_trans_pend.tptransacao = 9  THEN /** FOLHA DE PAGAMENTO **/ 
                         DO:
                        FIND tbfolha_trans_pend 
                            WHERE tbfolha_trans_pend.cdtransacao_pendente = tbgen_trans_pend.cdtransacao_pendente
                            NO-LOCK NO-ERROR NO-WAIT.
                                    
                        ASSIGN aux_dtdebito = STRING(tbfolha_trans_pend.dtdebito,"99/99/9999")
                               aux_vllantra = tbfolha_trans_pend.vlfolha
                               aux_dscedent = "FOLHA DE PAGAMENTO".
                                        END.
                ELSE
                    IF  tbgen_trans_pend.tptransacao = 10  THEN /** PACOTE DE TARIFAS **/ 
                    DO:
                        FIND tbtarif_pacote_trans_pend 
                            WHERE tbtarif_pacote_trans_pend.cdtransacao_pendente = tbgen_trans_pend.cdtransacao_pendente
                            NO-LOCK NO-ERROR NO-WAIT.
                
                        
                        ASSIGN aux_dtdebito = "Mes atual"
                               aux_vllantra = tbtarif_pacote_trans_pend.vlpacote
                               aux_dscedent = "SERVICOS COOPERATIVOS".
                    END.
                    ELSE 
                    IF  tbgen_trans_pend.tptransacao = 11 THEN /* DARF-DAS */
					DO:                    
                    FIND tt-tbpagto_darf_das_trans_pend WHERE tt-tbpagto_darf_das_trans_pend.cdtransacao_pendente = tbgen_trans_pend.cdtransacao_pendente NO-LOCK NO-ERROR NO-WAIT.
                            
                    ASSIGN aux_dtdebito = (IF tt-tbpagto_darf_das_trans_pend.idagendamento = 1 THEN "Nesta Data" ELSE STRING(tt-tbpagto_darf_das_trans_pend.dtdebito,"99/99/9999"))
						   aux_vllantra = tt-tbpagto_darf_das_trans_pend.vlpagamento.
                           
                            IF  TRIM(tt-tbpagto_darf_das_trans_pend.dsidentif_pagto) <> ? AND
					   TRIM(tt-tbpagto_darf_das_trans_pend.dsidentif_pagto) <> "" THEN 
                      ASSIGN aux_dscedent = TRIM(tt-tbpagto_darf_das_trans_pend.dsidentif_pagto).
                            ELSE 
                                DO: 
                                    IF  tt-tbpagto_darf_das_trans_pend.tppagamento = 1 THEN
                        ASSIGN aux_dscedent = "Pagamento de DARF".
                                    ELSE 
                                    IF tt-tbpagto_darf_das_trans_pend.tppagamento = 2 THEN
                        ASSIGN aux_dscedent = "Pagamento de DAS".
                    END.
                  END. /* FIM DARF/DAS */
                  
              ELSE IF tbgen_trans_pend.tptransacao = 14 OR /* FGTS */
                      tbgen_trans_pend.tptransacao = 15 THEN /* DAE */
					      DO:                    
                    FIND tt-tbpagto_tributos_trans_pend 
                   WHERE tt-tbpagto_tributos_trans_pend.cdtransacao_pendente = tbgen_trans_pend.cdtransacao_pendente 
                         NO-LOCK NO-ERROR NO-WAIT.
                            
                    ASSIGN aux_dtdebito = (IF tt-tbpagto_tributos_trans_pend.idagendamento = 1 THEN "Nesta Data" 
                                           ELSE STRING(tt-tbpagto_tributos_trans_pend.dtdebito,"99/99/9999"))
						               aux_vllantra = tt-tbpagto_tributos_trans_pend.vlpagamento.
                           
                    IF TRIM(tt-tbpagto_tributos_trans_pend.dsidenti_pagto) <> ? AND
					               TRIM(tt-tbpagto_tributos_trans_pend.dsidenti_pagto) <> "" THEN 
                      ASSIGN aux_dscedent = TRIM(tt-tbpagto_tributos_trans_pend.dsidenti_pagto).
                    ELSE DO: 
                      IF tt-tbpagto_tributos_trans_pend.tppagamento = 3 THEN
                        ASSIGN aux_dscedent = "Pagamento de FGTS".
                      ELSE IF tt-tbpagto_tributos_trans_pend.tppagamento = 4 THEN
                        ASSIGN aux_dscedent = "Pagamento de DAE".
                    END.
                  END. /* FIM FGTS/DAE */  
                  
                            ELSE
                    IF  tbgen_trans_pend.tptransacao = 16  OR /** CONTRATO SMS **/
                            tbgen_trans_pend.tptransacao = 17  THEN
                            DO:
                              FIND tbcobran_sms_trans_pend
                              WHERE  tbcobran_sms_trans_pend.cdtransacao_pendente = tbgen_trans_pend.cdtransacao_pendente
                              NO-LOCK NO-ERROR NO-WAIT.
                              
                              ASSIGN aux_dtdebito = "Nesta Data"
                              aux_dscedent = "SMS INDIVIDUAL"
                              aux_vllantra = tbcobran_sms_trans_pend.vlservico.
                              
                            IF  tbgen_trans_pend.tptransacao = 16 THEN
                              ASSIGN aux_dstptran = "Adesao Serviço SMS de Cobrança".
                              ELSE
                              ASSIGN aux_dstptran = "Cancelamento do Serviço SMS de Cobrança".
                              END.

                    IF  tbgen_trans_pend.tptransacao = 2 THEN /* Pagamento */
                  /*aux_dstiptra= (IF tbpagto_trans_pend.tppagamento = 1 THEN "Pagamento de Convenio" ELSE "Pagamento de Boletos Diversos").*/
                        IF  tbpagto_trans_pend.tppagamento = 1 THEN
                  DO:
                    ASSIGN aux_dstiptra = "Pagamento de Convenio".
                  END.
                        ELSE 
                        IF  tbpagto_trans_pend.tppagamento = 2 THEN
                  DO:
                    ASSIGN aux_dstiptra = "Pagamento de Boletos Diversos".
                  END.
                ELSE
                  DO:
                    ASSIGN aux_dstiptra = "GPS".
                  END.
                ELSE
                    IF  tbgen_trans_pend.tptransacao = 3 THEN
                    aux_dstiptra = "Credito de Salario".
                ELSE
                    IF  tbgen_trans_pend.tptransacao = 4 
                    OR  tbgen_trans_pend.tptransacao = 22 /*REQ39*/
                    THEN
                    aux_dstiptra = "TED".
            ELSE
                    IF  tbgen_trans_pend.tptransacao = 1 OR
                 tbgen_trans_pend.tptransacao = 5 THEN
                    aux_dstiptra = "Transferencia".
                    ELSE
                    IF  tbgen_trans_pend.tptransacao = 6 THEN
                    aux_dstiptra = "Credito Pre-Aprovado".
                    ELSE
                    IF  tbgen_trans_pend.tptransacao = 7 THEN
                 aux_dstiptra = aux_dstptran.
                ELSE
                    IF  tbgen_trans_pend.tptransacao = 8 THEN
                    aux_dstiptra = (IF tbconv_trans_pend.tpoperacao = 1 THEN "Autorizacao" ELSE (IF tbconv_trans_pend.tpoperacao = 2 THEN "Bloqueio" ELSE "Desbloqueio")) + " Debito Automatico".
            ELSE
                    IF  tbgen_trans_pend.tptransacao = 9 THEN
                    aux_dstiptra = "Folha de Pagamento".
                                                          ELSE
                    IF  tbgen_trans_pend.tptransacao = 10  THEN /** PACOTE DE TARIFAS **/ 
                    aux_dstiptra = "Servicos Cooperativos".                    
                                                          ELSE
                IF tbgen_trans_pend.tptransacao = 11 THEN
                    DO:
                            IF  tt-tbpagto_darf_das_trans_pend.tppagamento = 1 THEN 
                            aux_dstiptra = "Pagamento de DARF".
                            ELSE 
                            IF tt-tbpagto_darf_das_trans_pend.tppagamento = 2 THEN
                            aux_dstiptra = "Pagamento de DAS".
                    END.
                ELSE   
                    IF  tbgen_trans_pend.tptransacao = 12 THEN
                    DO:
                        FOR EACH  tbdscc_trans_pend 
                            WHERE  tbdscc_trans_pend.cdtransacao_pendente = tbgen_trans_pend.cdtransacao_pendente NO-LOCK:
                          ASSIGN aux_vltotbdc = aux_vltotbdc + tbdscc_trans_pend.vlcheque.
                            END.
                          
                        ASSIGN aux_dtdebito = "Nesta Data"
                               aux_vllantra = aux_vltotbdc
                               aux_dscedent = "Bordero de Desconto de Cheques"
                               aux_dstptran = "Bordero de Desconto de Cheques"
                               aux_dstiptra = "Desconto de Cheque".
                    END.
                ELSE
                    IF  tbgen_trans_pend.tptransacao = 13 THEN
                    DO:
                        FIND tbrecarga_operacao WHERE  tbrecarga_operacao.idoperacao = tt-tbrecarga_trans_pend.idoperacao NO-LOCK NO-ERROR NO-WAIT.
                        
                        { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
                             
                        RUN STORED-PROCEDURE pc_busca_recarga_prog aux_handproc = PROC-HANDLE NO-ERROR
                                             (INPUT tt-tbrecarga_trans_pend.idoperacao
                                             ,OUTPUT ""
                                             ,OUTPUT 0
                                             ,OUTPUT "").
                        CLOSE STORED-PROC pc_busca_recarga_prog 
                            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
             
                        ASSIGN aux_resposta = ""
                               aux_resposta = pc_busca_recarga_prog.pr_resposta
                                              WHEN pc_busca_recarga_prog.pr_resposta <> ?.
                        
                        { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
                        
                        ASSIGN aux_dtdebito = (IF tt-tbrecarga_trans_pend.tprecarga = 1 THEN "Nesta Data" ELSE
                                               STRING(tbrecarga_operacao.dtrecarga,"99/99/9999"))
                               aux_vllantra = tbrecarga_operacao.vlrecarga
                               aux_dstptran = aux_resposta
                               aux_dscedent = aux_resposta
                        	   aux_dstiptra = "Recarga de Celular".
                    END.
                    ELSE 
                    IF  tbgen_trans_pend.tptransacao = 16 THEN /*OK*/
                              aux_dstiptra = "Adesao SMS Cobrança".
                    ELSE 
                    IF  tbgen_trans_pend.tptransacao = 17 THEN /*OK*/
                              aux_dstiptra = "Cancelamento SMS Cobrança".
                    ELSE 
                    IF tbgen_trans_pend.tptransacao = 18 THEN
                      DO:
                        aux_dstiptra = "Resgate de cheque em custodia".
                        aux_dscedent = "Resgate de cheque em custodia".
                        /*aux_vllantra = 10.*/
                      END.
                    ELSE
                IF tbgen_trans_pend.tptransacao = 19 THEN /*Bordero Desconto Titulo*/
                    DO:
                        FOR EACH  tbdsct_trans_pend WHERE tbdsct_trans_pend.cdtransacao_pendente = tbgen_trans_pend.cdtransacao_pendente NO-LOCK:
                            ASSIGN aux_vltotbdt = aux_vltotbdt + tbdsct_trans_pend.vltitulo.
                        END.

                        ASSIGN aux_dtdebito = "Nesta Data"
                               aux_vllantra = aux_vltotbdt
                               aux_dscedent = "Bordero de Desconto de Titulos"
                               aux_dstptran = "Bordero de Desconto de Titulos"
                               aux_dstiptra = "Desconto de Titulos".
                     
                    END.
                    ELSE
                IF  tbgen_trans_pend.tptransacao = 21  THEN /** EMPRESTIMO **/ 
                  DO:
                    /* Efetuar a chamada a rotina Oracle */ 
                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                    
                    RUN STORED-PROCEDURE pc_ret_trans_pend_prop
                      aux_handproc = PROC-HANDLE NO-ERROR (INPUT tbgen_trans_pend.cdcooper,            /* Código da Cooperativa */
                                                           INPUT "996",                                 /* Código do Operador */
                                                           INPUT "INTERNETBANK",                        /* Nome da Tela */
                                                           INPUT 1,                                     /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                                           INPUT tbgen_trans_pend.nrdconta,            /* Número da Conta */
                                                           INPUT 1,                                     /* Titular da Conta */
                                                           INPUT STRING(tbgen_trans_pend.cdtransacao_pendente), /* Codigo da Transacao */
                                                          OUTPUT 0,                                     /* Código da crítica */
                                                          OUTPUT "",                                    /* Descriçao da crítica */
                                                          OUTPUT 0,                                     /* Código da proposta de emprestimo */
                                                          OUTPUT 0).                                    /* Valor da proposta de emprestimo */

                    /* Fechar o procedimento para buscarmos o resultado */ 
                    CLOSE STORED-PROC pc_ret_trans_pend_prop
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

                    ASSIGN aux_dtdebito = "Nesta Data"
                           aux_vllantra = pc_ret_trans_pend_prop.pr_vlemprst 
                                          WHEN pc_ret_trans_pend_prop.pr_vlemprst <> ?
                           aux_dscedent = "PROPOSTA DE EMPRESTIMO " + STRING(pc_ret_trans_pend_prop.pr_nrctremp)
                           aux_dstiptra = "Credito Emprestimo".
                  END.

                ELSE
                    aux_dstiptra = "Transacao".
                
                CREATE tt-criticas_transacoes_oper.
                    ASSIGN tt-criticas_transacoes_oper.cdtiptra = tbgen_trans_pend.tptransacao
                           tt-criticas_transacoes_oper.dtcritic = aux_dtdebito                           
                       tt-criticas_transacoes_oper.nrdrowid = par_nrdrowid
                       tt-criticas_transacoes_oper.vllantra = aux_vllantra
                       tt-criticas_transacoes_oper.dscedent = aux_dscedent
                       tt-criticas_transacoes_oper.dstiptra = aux_dstiptra
                   tt-criticas_transacoes_oper.flgtrans = par_aprovada
                       tt-criticas_transacoes_oper.dscritic = par_dscritic
					   tt-criticas_transacoes_oper.cdtransa = tbgen_trans_pend.cdtransacao_pendente
                           tt-criticas_transacoes_oper.dsprotoc = IF  par_indvalid = 1     AND 
                                                                      par_aprovada = TRUE  THEN 
                                                                    glb_dsprotoc 
                                                                  ELSE 
                                                                      "".
    END.

            DELETE PROCEDURE h-b1wgen9999.
    END.

END PROCEDURE.

PROCEDURE paga_convenio:
    
    DEF INPUT  PARAM par_cdcooper         AS INTE                    NO-UNDO.
    DEF INPUT  PARAM par_nrdconta         LIKE crapttl.nrdconta      NO-UNDO.
    DEF INPUT  PARAM par_idseqttl         LIKE crapttl.idseqttl      NO-UNDO.
    DEF INPUT  PARAM par_cdbarras         AS CHAR                    NO-UNDO.
    DEF INPUT  PARAM par_dscedent         AS CHAR                    NO-UNDO.
    DEF INPUT  PARAM par_cdseqfat         AS DECI                    NO-UNDO.
    DEF INPUT  PARAM par_vlfatura         AS DECI                    NO-UNDO.
    DEF INPUT  PARAM par_nrdigfat         AS INTE                    NO-UNDO.
    DEF INPUT  PARAM par_flgagend         AS LOGI                    NO-UNDO.
    DEF INPUT  PARAM par_idorigem         AS INT                     NO-UNDO.
    DEF INPUT  PARAM par_cdcoptfn         AS INTE                    NO-UNDO. /**/
    DEF INPUT  PARAM par_cdagetfn         AS INTE                    NO-UNDO. /**/
    DEF INPUT  PARAM par_nrterfin         AS INTE                    NO-UNDO. /**/

    DEF INPUT  PARAM par_nrcpfope         AS DECI                    NO-UNDO. /**/
    /* Tipo de captura 1-leitora 2- linha digitavel*/
    DEF INPUT  PARAM par_tpcptdoc         AS INTE                     NO-UNDO. 
    DEF INPUT  PARAM par_flmobile         AS LOGICAL                  NO-UNDO. 
    DEF INPUT  PARAM par_iptransa         AS CHAR                    NO-UNDO.
    DEF INPUT  PARAM par_iddispos         AS CHAR                    NO-UNDO.
    
    DEF OUTPUT PARAM par_dstransa         AS CHAR                    NO-UNDO.
    DEF OUTPUT PARAM par_dscritic         LIKE crapcri.dscritic      NO-UNDO.
    DEF OUTPUT PARAM par_dsprotoc         LIKE crappro.dsprotoc      NO-UNDO.
    DEF OUTPUT PARAM par_cdbcoctl         AS CHAR                    NO-UNDO.
    DEF OUTPUT PARAM par_cdagectl         AS CHAR                    NO-UNDO.
    DEF OUTPUT PARAM par_msgofatr         AS CHAR                    NO-UNDO.
    DEF OUTPUT PARAM par_cdempcon         AS INTE                    NO-UNDO.
    DEF OUTPUT PARAM par_cdsegmto         AS CHAR                    NO-UNDO.
 
    DEF VAR          aux_cdcritic         AS INTE                    NO-UNDO.
                                   
    /* Utilizar a procedure Oracle PAGA0001.pc_paga_convenio_prog */
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
             
    RUN STORED-PROCEDURE pc_paga_convenio_prog
        aux_handproc = PROC-HANDLE NO-ERROR
                        ( INPUT par_cdcooper /* Codigo da cooperativa*/
                        , INPUT par_nrdconta /* Numero da conta */
                        , INPUT par_idseqttl /* Sequencial titular */ 
                        , INPUT par_cdbarras /* Codigo de Barras*/
                        , INPUT par_dscedent /* descriçao do cedente */
                        , INPUT STRING(par_cdseqfat) /* Codigo Sequencial fatura */
                        , INPUT par_vlfatura /* Valor fatura */
                        , INPUT par_nrdigfat /* Numero Digito Fatura */
                        , INPUT (IF par_flgagend THEN 1 ELSE 0) /* Flag agendado */
                        , INPUT par_idorigem /* Indicador de origem */
                        , INPUT par_cdcoptfn /* Codigo cooperativa transacao */
                        , INPUT par_cdagetfn /* Codigo Agencia transacao */
                        , INPUT par_nrterfin /* Numero terminal financeiro */
                        , INPUT par_nrcpfope /* Numero cpf operador */
                        , INPUT INT(par_flmobile) /* flgmobile */                       
                        , INPUT par_iptransa
                        , INPUT par_iddispos
                        ,OUTPUT ""   /* Descricao transacao */
                        ,OUTPUT ""   /* Descricao Protocolo */
                        ,OUTPUT ""   /* Codigo Banco Centralizador*/
                        ,OUTPUT ""   /* Codigo Agencia Centralizadora */
                        ,OUTPUT 0    /* Codigo da critica*/
                        ,OUTPUT ""   /* Descricao critica */
                        ,OUTPUT ""   /* Mensagem ofertar debito automatico */
                        ,OUTPUT 0    /* Codigo da Empresa do Convenio */
                        ,OUTPUT ""). /* Segmento da Empresa do Convenio */

    CLOSE STORED-PROC pc_paga_convenio_prog
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN par_dstransa = ""
           par_dsprotoc = ""
           par_cdbcoctl = ""
           par_cdagectl = ""
           par_msgofatr = ""
               par_cdempcon = 0
           par_cdsegmto = ""
           aux_cdcritic = 0
           par_dscritic = ""

           par_dstransa = pc_paga_convenio_prog.pr_dstransa
                          WHEN pc_paga_convenio_prog.pr_dstransa <> ?
           par_dsprotoc = pc_paga_convenio_prog.pr_dsprotoc
                          WHEN pc_paga_convenio_prog.pr_dsprotoc <> ?
           par_cdbcoctl = pc_paga_convenio_prog.pr_cdbcoctl
                          WHEN pc_paga_convenio_prog.pr_cdbcoctl <> ?
           par_cdagectl = pc_paga_convenio_prog.pr_cdagectl
                          WHEN pc_paga_convenio_prog.pr_cdagectl <> ?
           par_msgofatr = pc_paga_convenio_prog.pr_msgofatr
                          WHEN pc_paga_convenio_prog.pr_msgofatr <> ?
           par_cdempcon = pc_paga_convenio_prog.pr_cdempcon
                          WHEN pc_paga_convenio_prog.pr_cdempcon <> ?
           par_cdsegmto = pc_paga_convenio_prog.pr_cdsegmto
                          WHEN pc_paga_convenio_prog.pr_cdsegmto <> ?
           aux_cdcritic = pc_paga_convenio_prog.pr_cdcritic
                          WHEN pc_paga_convenio_prog.pr_cdcritic <> ?
           par_dscritic = pc_paga_convenio_prog.pr_dscritic
                          WHEN pc_paga_convenio_prog.pr_dscritic <> ?.
                     
    /* Se houveram criticas, retorno NOK */
    IF  aux_cdcritic > 0 OR par_dscritic <> "" THEN
             RETURN "NOK".
             
    RETURN "OK".

END PROCEDURE.


PROCEDURE convenios_aceitos:

    DEF INPUT  PARAM par_cdcooper AS INTE                                  NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-convenios_aceitos.

    DEF VAR aux_hhsicini AS CHAR                                           NO-UNDO.
    DEF VAR aux_hhsicfim AS CHAR                                           NO-UNDO.
    DEF VAR aux_hhsiccan AS CHAR                                           NO-UNDO.
    DEF VAR aux_hrtitini AS CHAR                                           NO-UNDO.
    DEF VAR aux_hrtitfim AS CHAR                                           NO-UNDO.
    DEF VAR aux_hrcancel AS CHAR                                           NO-UNDO.
    DEF VAR aux_dssegmto AS CHAR EXTENT 8                                  NO-UNDO.
    DEF VAR aux_fldebaut AS LOGI                                           NO-UNDO.
    DEF VAR aux_cdhisdeb LIKE crapcon.cdhistor                             NO-UNDO.
    DEF VAR aux_hhini_bancoob AS CHAR                                      NO-UNDO.
    DEF VAR aux_hhfim_bancoob AS CHAR                                      NO-UNDO.
    DEF VAR aux_hhcan_bancoob AS CHAR                                      NO-UNDO.
	DEF VAR aux_nmempcon AS CHAR NO-UNDO.
    
    
    EMPTY TEMP-TABLE tt-convenios_aceitos.
    
    ASSIGN aux_dssegmto[1] = "Prefeituras"
           aux_dssegmto[2] = "Saneamento"
           aux_dssegmto[3] = "Energia Elétrica e Gás"
           aux_dssegmto[4] = "Telecomunicaçoes"
           aux_dssegmto[5] = "Órgaos Governamentais"
           aux_dssegmto[6] = "Órgaos Identificados pelo CNPJ"
           aux_dssegmto[7] = "Multas de Trânsito"
           aux_dssegmto[8] = "Uso Exclusivo do Banco".

    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "GENERI"     AND
                       craptab.cdempres = 00           AND
                       craptab.cdacesso = "HRPGSICRED" AND
                       craptab.tpregist = 90           /* internet */ 
                       NO-LOCK NO-ERROR.

    IF AVAILABLE craptab  THEN
       ASSIGN aux_hhsicini = STRING(INT(ENTRY(1,craptab.dstextab," ")),"HH:MM")
              aux_hhsicfim = STRING(INT(ENTRY(2,craptab.dstextab," ")),"HH:MM")
              aux_hhsiccan = STRING(INT(ENTRY(3,craptab.dstextab," ")),"HH:MM").

    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "GENERI"     AND
                       craptab.cdempres = 00           AND
                       craptab.cdacesso = "HRPGBANCOOB" AND
                       craptab.tpregist = 90           /* internet */ 
                       NO-LOCK NO-ERROR.

    IF AVAILABLE craptab  THEN
       ASSIGN aux_hhini_bancoob = STRING(INT(ENTRY(1,craptab.dstextab," ")),"HH:MM")
              aux_hhfim_bancoob = STRING(INT(ENTRY(2,craptab.dstextab," ")),"HH:MM")
              aux_hhcan_bancoob = STRING(INT(ENTRY(3,craptab.dstextab," ")),"HH:MM"). 

    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "GENERI"     AND
                       craptab.cdempres = 00           AND
                       craptab.cdacesso = "HRTRTITULO" AND
                       craptab.tpregist = 90           /* internet */
                       NO-LOCK NO-ERROR.

    IF  AVAILABLE craptab  THEN
        ASSIGN aux_hrtitini = STRING(INT(ENTRY(3,craptab.dstextab," ")),"HH:MM")
               aux_hrtitfim = STRING(INT(ENTRY(2,craptab.dstextab," ")),"HH:MM").

    FIND crapage WHERE crapage.cdcooper = par_cdcooper AND
                       crapage.cdagenci = 90 /* internet */
                       NO-LOCK NO-ERROR NO-WAIT.

    IF  AVAILABLE crapage  THEN
        ASSIGN aux_hrcancel = SUBSTR(STRING(crapage.hrcancel,"HH:MM"),1,2)
                      + ":" + SUBSTR(STRING(crapage.hrcancel,"HH:MM"),4,2).
    
    FOR EACH crapcon NO-LOCK WHERE crapcon.cdcooper = par_cdcooper  AND
                                   crapcon.flginter = TRUE 
                                   BY crapcon.nmextcon:
								   
        ASSIGN aux_cdhisdeb = crapcon.cdhistor
               aux_nmempcon = crapcon.nmrescon.

        /* Sicredi */  
        IF  crapcon.tparrecd = 1 THEN
            DO:		    				
                FIND FIRST crapscn WHERE (crapscn.cdempcon = crapcon.cdempcon          AND
                                          crapscn.cdempcon <> 0)                       AND
                                          crapscn.cdsegmto = STRING(crapcon.cdsegmto)  AND
                                          crapscn.dsoparre = 'E'                       AND
                                         (crapscn.cddmoden = 'A'                       OR
                                          crapscn.cddmoden = 'C') NO-LOCK NO-ERROR.
                IF  NOT AVAIL crapscn THEN
                    ASSIGN aux_fldebaut = NO.
                ELSE
                    DO:
                    ASSIGN aux_fldebaut = YES.
                        IF(crapscn.dsnomres <> "") then
                           ASSIGN aux_nmempcon = crapscn.dsnomres.
                        ELSE
                           ASSIGN aux_nmempcon = crapscn.dsnomcnv.
                    END.
            END.
        /* Cecred */    
        ELSE IF  crapcon.tparrecd = 3 THEN
            DO:                 
                FIND FIRST gnconve WHERE (gnconve.cdhiscxa = crapcon.cdhistor AND
                                          gnconve.flgativo = TRUE             AND
                                          gnconve.nmarqatu <> ""              AND
                                          gnconve.cdhisdeb <> 0)              OR 
                                         (gnconve.cdconven = 87               AND
                                          gnconve.flgativo = TRUE             AND
                                          gnconve.nmarqatu <> ""              AND
                                          gnconve.cdhisdeb <> 0               AND 
                                          crapcon.cdempcon = 1058)            OR
                                         (gnconve.cdconven = 108              AND
                                          gnconve.flgativo = TRUE             AND
                                          gnconve.nmarqatu <> ""              AND
                                          gnconve.cdhisdeb <> 0               AND 
                                          crapcon.cdempcon = 1085)                            
                                          NO-LOCK NO-ERROR.                           

                IF  NOT AVAILABLE gnconve  THEN
                    ASSIGN aux_fldebaut = NO.
                ELSE 
                    DO:
                    ASSIGN aux_fldebaut = YES
                           aux_cdhisdeb = gnconve.cdhisdeb.					
                               
                        IF gnconve.cdconven <> 87  AND
                           gnconve.cdconven <> 108 THEN
                           ASSIGN aux_nmempcon = gnconve.nmempres.
                    END.
            END.								   
        /* Bancoob */    
        ELSE IF  crapcon.tparrecd = 2 THEN
            DO:
              /* Nao possui deb.aut.*/
              ASSIGN aux_fldebaut = NO
                     aux_cdhisdeb = 0.
            END.
    
        CREATE tt-convenios_aceitos.
        ASSIGN tt-convenios_aceitos.nmextcon = crapcon.nmextcon
               tt-convenios_aceitos.nmrescon = aux_nmempcon
               tt-convenios_aceitos.cdempcon = crapcon.cdempcon 
               tt-convenios_aceitos.cdsegmto = crapcon.cdsegmto
               tt-convenios_aceitos.dssegmto = aux_dssegmto[crapcon.cdsegmto]
               tt-convenios_aceitos.fldebaut = aux_fldebaut
               tt-convenios_aceitos.cdhisdeb = aux_cdhisdeb.

        /* Sicredi */ 
        IF crapcon.tparrecd = 1 THEN
        DO:
           ASSIGN tt-convenios_aceitos.hhoraini = aux_hhsicini
                  tt-convenios_aceitos.hhorafim = aux_hhsicfim.
        END.   
        /* Cecred */
        ELSE IF crapcon.tparrecd = 3 THEN
        DO:
           ASSIGN tt-convenios_aceitos.hhoraini = aux_hrtitini
                  tt-convenios_aceitos.hhorafim = aux_hrtitfim.
        END.  
        /* Bancoob */
        ELSE IF crapcon.tparrecd = 2 THEN
        DO:
           ASSIGN tt-convenios_aceitos.hhoraini = aux_hhini_bancoob
                  tt-convenios_aceitos.hhorafim = aux_hhfim_bancoob.
        END.
        
        

        IF (((crapcon.cdempcon = 24 OR  crapcon.cdempcon = 98) AND 
              crapcon.cdsegmto = 5) OR (crapcon.cdempcon = 119 AND 
              crapcon.cdsegmto = 2)) THEN 
            tt-convenios_aceitos.hhoracan = "Estorno não permitido para este convênio".
        ELSE
        DO:
            /* Sicredi */ 
            IF crapcon.tparrecd = 1 THEN
            DO:
               ASSIGN tt-convenios_aceitos.hhoracan = aux_hhsiccan.
            END.   
            /* Cecred */
            ELSE IF crapcon.tparrecd = 3 THEN
            DO:
               ASSIGN tt-convenios_aceitos.hhoracan = aux_hrcancel.
            END.  
            /* Bancoob */
            ELSE IF crapcon.tparrecd = 2 THEN
            DO:
               ASSIGN tt-convenios_aceitos.hhoracan = aux_hhcan_bancoob.
            END.
        END.    

    END. 

END PROCEDURE.


PROCEDURE verifica_titulo:

    DEF INPUT        PARAM par_cdcooper LIKE crapcop.cdcooper       NO-UNDO.
    DEF INPUT        PARAM par_nrdconta LIKE crapttl.nrdconta       NO-UNDO.
    DEF INPUT        PARAM par_idseqttl LIKE crapttl.idseqttl       NO-UNDO.
    DEF INPUT        PARAM par_idagenda AS INTE                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_lindigi1 AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_lindigi2 AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_lindigi3 AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_lindigi4 AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_lindigi5 AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_cdbarras AS CHAR                     NO-UNDO.
    DEF INPUT        PARAM par_vllanmto AS DECI                     NO-UNDO.
    DEF INPUT        PARAM par_dtagenda AS DATE                     NO-UNDO.
    DEF INPUT        PARAM par_idorigem AS INT                      NO-UNDO.    
    DEF INPUT        PARAM par_indvalid AS INT                      NO-UNDO.
    DEF INPUT        PARAM par_cdctlnpc AS CHAR                     NO-UNDO. /* Numero controle consulta npc */   
    DEF OUTPUT       PARAM par_nmextbcc AS CHAR                     NO-UNDO.
    DEF OUTPUT       PARAM par_vlfatura AS DECI                     NO-UNDO.
    DEF OUTPUT       PARAM par_dtdifere AS LOGI                     NO-UNDO. 
    DEF OUTPUT       PARAM par_vldifere AS LOGI                     NO-UNDO. 
    DEF OUTPUT       PARAM par_nrctacob AS INTE                     NO-UNDO.    
    DEF OUTPUT       PARAM par_insittit AS INTE                     NO-UNDO.
    DEF OUTPUT       PARAM par_intitcop AS INTE                     NO-UNDO.
    DEF OUTPUT       PARAM par_nrcnvcob AS DECI                     NO-UNDO.
    DEF OUTPUT       PARAM par_nrboleto AS DECI                     NO-UNDO.
    DEF OUTPUT       PARAM par_nrdctabb AS INTE                     NO-UNDO.
    DEF OUTPUT       PARAM par_dstransa AS CHAR                     NO-UNDO.
    DEF OUTPUT       PARAM par_dscritic LIKE crapcri.dscritic       NO-UNDO.
    /* parametro de cobranca registrada */
    DEF OUTPUT       PARAM par_cobregis AS LOGICAL                  NO-UNDO.
    DEF OUTPUT       PARAM par_msgalert AS CHARACTER                NO-UNDO.
    DEF OUTPUT       PARAM par_vlrjuros AS DECIMAL                  NO-UNDO.
    DEF OUTPUT       PARAM par_vlrmulta AS DECIMAL                  NO-UNDO.
    DEF OUTPUT       PARAM par_vldescto AS DECIMAL                  NO-UNDO.
    DEF OUTPUT       PARAM par_vlabatim AS DECIMAL                  NO-UNDO.
    DEF OUTPUT       PARAM par_vloutdeb AS DECIMAL                  NO-UNDO.
    DEF OUTPUT       PARAM par_vloutcre AS DECIMAL                  NO-UNDO.
    
    DEF VAR h_b2crap14   AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0025 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0015 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_cdbccxlt AS INTE                                    NO-UNDO.
    DEF VAR aux_cdagenci AS INT                                     NO-UNDO.
    DEF VAR aux_flgretor AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgpgdda AS LOGI  INIT FALSE                        NO-UNDO.

    DEFINE VARIABLE aux_dtmvtopg AS DATE        NO-UNDO.
    DEF VAR aux_cdcritic  AS INTE               NO-UNDO.
    DEF VAR aux_dtdifere  AS INTE               NO-UNDO.
    DEF VAR aux_vldifere  AS INTE               NO-UNDO.
    DEF VAR aux_cobregis  AS INTE               NO-UNDO.
    DEF VAR aux_dtdialim                 AS DATE                    NO-UNDO.
    
    /* IF temporario ate o projeto do TED estar ok - Rafael */
    IF par_idagenda = 3 THEN 
       ASSIGN par_idagenda = 1
              aux_flgpgdda = TRUE.
    
    /* tratamento para TAA */
    IF  par_idorigem = 4  THEN
        aux_cdagenci = 91.
    ELSE
        aux_cdagenci = 90.
    
    IF  par_idagenda = 2 THEN
        DO:
            IF  par_idorigem = 4  THEN
                DO:
                    RUN sistema/generico/procedures/b1wgen0025.p
                                      PERSISTENT SET h-b1wgen0025.
                    
                    RUN calcula_dia_util IN h-b1wgen0025(INPUT  par_cdcooper,
                                                         INPUT  par_dtagenda,
                                                         OUTPUT aux_flgretor).
                    
                    IF  NOT aux_flgretor THEN
                        DO:
                            ASSIGN par_dscritic = "Data do agendamento deve ser um dia útil.".                                         
                            RETURN "NOK".        
                        END.
                    
                    DELETE PROCEDURE h-b1wgen0025.
                    
                    FIND crapage WHERE crapage.cdcooper = par_cdcooper AND
                                       crapage.cdagenci = aux_cdagenci
                                       NO-LOCK NO-ERROR.
                                               
                    IF  NOT AVAILABLE crapage  THEN
                        DO:
                            ASSIGN par_dscritic = "PA nao cadastrado.".
                            RETURN "NOK".
                        END.
                    
                    ASSIGN aux_dtdialim = aux_datdodia + crapage.qtddaglf. 

                    IF  NOT VALID-HANDLE(h-b1wgen0025) THEN
                        RUN sistema/generico/procedures/b1wgen0025.p
                            PERSISTENT SET h-b1wgen0025.

                    agenda:
                    DO  WHILE TRUE:

                        RUN calcula_dia_util IN h-b1wgen0025(INPUT  par_cdcooper,
                                                             INPUT  aux_dtdialim,
                                                             OUTPUT aux_flgretor).
                        
                        IF  NOT aux_flgretor THEN
                            DO:
                                ASSIGN aux_dtdialim = aux_dtdialim - 1.
                                NEXT agenda.
                            END.

                        LEAVE agenda.
                    END.

                    IF  VALID-HANDLE(h-b1wgen0025) THEN
                        DELETE PROCEDURE h-b1wgen0025.

                    IF  par_dtagenda > aux_dtdialim  THEN
                        DO:                          
                            ASSIGN par_dscritic = "A data limite para efetuar" +
                                                  " agendamentos é " +
                                                  STRING(aux_dtdialim,"99/99/9999") +
                                                  ".".
                            RETURN "NOK".                      
                        END.     
                END.                
        END.

    ASSIGN par_dstransa = "Verificacao de titulos para " + 
                          (IF  par_idagenda = 1  THEN
                               ""
                           ELSE
                               "agendamento de ") +
                          "pagamento".

    /** Verificar se a conta pertence a um PAC migrado **/
    FIND craptco WHERE craptco.cdcopant = par_cdcooper AND
                       craptco.nrctaant = par_nrdconta AND
                       craptco.tpctatrf = 1            
                       NO-LOCK NO-ERROR.

    IF  AVAILABLE craptco  AND 
        par_idagenda = 2   THEN  /** Agendamento **/
        DO:
            /** Bloquear agendamentos para conta migrada **/
            IF  aux_datdodia >= 12/25/2013  AND
                craptco.cdcopant <> 4       AND  /* Exceto Concredi */
                craptco.cdcopant <> 15      AND  /* Exceto Credimilsul */
                craptco.cdcopant <> 17      THEN /* Exceto Transulcred */
                DO:
                    ASSIGN par_dscritic = "Operacao de agendamento bloqueada." +
                                          " Entre em contato com seu PA.".
                    RETURN "NOK".
                END.
        END.
                          
    IF  par_idagenda = 1  THEN                          
        ASSIGN par_dtagenda = ?.
                                                  
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapcop  THEN
        DO:
            par_dscritic = "Cooperativa nao cadastrada.".
            RETURN "NOK".
        END.
    
    /*DO  TRANSACTION ON ERROR UNDO, RETURN "NOK":*/

         { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
         
   RUN STORED-PROCEDURE pc_verifica_titulo_prog
             aux_handproc = PROC-HANDLE NO-ERROR
                    
        ( INPUT crapcop.cdcooper    /* pr_cdcooper --Codigo da cooperativa */
         ,INPUT par_nrdconta        /* pr_nrdconta --Numero da conta       */
         ,INPUT par_idseqttl        /* pr_idseqttl --Sequencial titular    */
         ,INPUT par_idagenda        /* pr_idagenda --Indicador agendamento */
         ,INPUT-OUTPUT par_lindigi1 /* pr_lindigi1 --Linha digitavel 1     */
         ,INPUT-OUTPUT par_lindigi2 /* pr_lindigi2 --Linha digitavel 2     */
         ,INPUT-OUTPUT par_lindigi3 /* pr_lindigi3 --Linha digitavel 3     */ 
         ,INPUT-OUTPUT par_lindigi4 /* pr_lindigi4 --Linha digitavel 4     */
         ,INPUT-OUTPUT par_lindigi5 /* pr_lindigi5 --Linha digitavel 5     */
         ,INPUT-OUTPUT par_cdbarras /* pr_cdbarras --Codigo de Barras      */
         ,INPUT par_vllanmto        /* pr_vllanmto --Valor Lancamento      */
         ,INPUT par_dtagenda        /* pr_dtagenda --Data agendamento      */
         ,INPUT par_idorigem        /* pr_idorigem --Indicador de origem   */ 
         ,INPUT par_indvalid        /* pr_indvalid --Indicador se ja foi feito */
         ,INPUT par_cdctlnpc        /* pr_cdctrlcs --> Numero de controle da consulta no NPC */
                    
         ,OUTPUT ""                 /* pr_nmextbcc --Nome do banco */
         ,OUTPUT 0                  /* pr_vlfatura --Valor fatura */
         ,OUTPUT ?                  /* pr_dtdifere --Indicador data diferente */
         ,OUTPUT 0                  /* pr_vldifere --Indicador valor diferente */
         ,OUTPUT 0                  /* pr_nrctacob --Numero Conta Cobranca     */
         ,OUTPUT 0                  /* pr_insittit --Indicador Situacao Titulo */
         ,OUTPUT 0                  /* pr_intitcop --Indicador Titulo Cooperativa */
         ,OUTPUT 0                  /* pr_nrcnvcob --Numero Convenio Cobranca */
         ,OUTPUT 0                  /* pr_nrboleto --Numero Boleto            */
         ,OUTPUT 0                  /* pr_nrdctabb --Numero conta             */
         ,OUTPUT ""                 /* pr_dstransa --Descricao transacao      */
          /* parametro de cobranca registrada       */
         ,OUTPUT 0                  /* pr_cobregis --Cobranca Registrada      */
         ,OUTPUT ""                 /* pr_msgalert --mensagem alerta          */ 
         ,OUTPUT 0                  /* pr_vlrjuros --Valor Juros              */ 
         ,OUTPUT 0                  /* pr_vlrmulta --Valor Multa              */ 
         ,OUTPUT 0                  /* pr_vldescto --Valor desconto           */
         ,OUTPUT 0                  /* pr_vlabatim --Valor Abatimento         */
         ,OUTPUT 0                  /* pr_vloutdeb --Valor saida debito       */
         ,OUTPUT 0                  /* pr_vloutcre --Valor saida credito      */
          /* parametros de erro                     */
         ,OUTPUT 0                  /* pr_cdcritic --Codigo da critica        */
         ,OUTPUT "").               /* pr_dscritic --Descricao critica        */ 
                    
                    
   CLOSE STORED-PROC pc_verifica_titulo_prog
               aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

  ASSIGN par_lindigi1 = pc_verifica_titulo_prog.pr_lindigi1 /* IN OUT NUMBER      -- FORMAT "99999,99999" */
         par_lindigi2 = pc_verifica_titulo_prog.pr_lindigi2 /* IN OUT NUMBER      -- FORMAT "99999,999999"  */
         par_lindigi3 = pc_verifica_titulo_prog.pr_lindigi3 /* IN OUT NUMBER      -- FORMAT "99999,999999"  */
         par_lindigi4 = pc_verifica_titulo_prog.pr_lindigi4 /* IN OUT NUMBER      -- FORMAT "9"            */
         par_lindigi5 = pc_verifica_titulo_prog.pr_lindigi5 /* IN OUT NUMBER      -- FORMAT "zz,zzz,zzz,zzz999" */
         par_cdbarras = pc_verifica_titulo_prog.pr_cdbarras /* IN OUT VARCHAR2    --Codigo de Barras */
               
         par_nmextbcc = pc_verifica_titulo_prog.pr_nmextbcc  /* pr_nmextbcc --Nome do banco */
         par_vlfatura = pc_verifica_titulo_prog.pr_vlfatura  /* pr_vlfatura --Valor fatura */
         aux_dtdifere = pc_verifica_titulo_prog.pr_dtdifere  /* pr_dtdifere --Indicador data diferente */
         aux_vldifere = pc_verifica_titulo_prog.pr_vldifere  /* pr_vldifere --Indicador valor diferente */
         par_nrctacob = pc_verifica_titulo_prog.pr_nrctacob  /* pr_nrctacob --Numero Conta Cobranca     */
         par_insittit = pc_verifica_titulo_prog.pr_insittit  /* pr_insittit --Indicador Situacao Titulo */
         par_intitcop = pc_verifica_titulo_prog.pr_intitcop  /* pr_intitcop --Indicador Titulo Cooperativa */
         par_nrcnvcob = pc_verifica_titulo_prog.pr_nrcnvcob  /* pr_nrcnvcob --Numero Convenio Cobranca */
         par_nrboleto = pc_verifica_titulo_prog.pr_nrboleto  /* pr_nrboleto --Numero Boleto            */
         par_nrdctabb = pc_verifica_titulo_prog.pr_nrdctabb  /* pr_nrdctabb --Numero conta             */
         par_dstransa = pc_verifica_titulo_prog.pr_dstransa  /* pr_dstransa --Descricao transacao      */
        
         aux_cobregis = pc_verifica_titulo_prog.pr_cobregis   /* pr_cobregis --Cobranca Registrada      */
         par_msgalert = pc_verifica_titulo_prog.pr_msgalert   /* pr_msgalert --mensagem alerta          */
         par_vlrjuros = pc_verifica_titulo_prog.pr_vlrjuros   /* pr_vlrjuros --Valor Juros              */
         par_vlrmulta = pc_verifica_titulo_prog.pr_vlrmulta   /* pr_vlrmulta --Valor Multa              */
         par_vldescto = pc_verifica_titulo_prog.pr_vldescto   /* pr_vldescto --Valor desconto           */
         par_vlabatim = pc_verifica_titulo_prog.pr_vlabatim   /* pr_vlabatim --Valor Abatimento         */
         par_vloutdeb = pc_verifica_titulo_prog.pr_vloutdeb   /* pr_vloutdeb --Valor saida debito       */
         par_vloutcre = pc_verifica_titulo_prog.pr_vloutcre   /* pr_vloutcre --Valor saida credito      */
               
               aux_cdcritic = 0
               par_dscritic = ""
         aux_cdcritic = pc_verifica_titulo_prog.pr_cdcritic 
                        WHEN pc_verifica_titulo_prog.pr_cdcritic <> ?
         par_dscritic = pc_verifica_titulo_prog.pr_dscritic 
                        WHEN pc_verifica_titulo_prog.pr_dscritic <> ?.
        

    /* Verificar se retornou critica */
    IF  aux_cdcritic > 0 OR
        par_dscritic <> ""  THEN
        DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT 90,
                            INPUT 900,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT par_dscritic).

                END.
            
    IF par_dscritic <> "" THEN
                DO:                    
                    RETURN "NOK".
                END.
        
    ASSIGN par_dtdifere = FALSE
           par_vldifere = FALSE
           par_cobregis = FALSE.
         
    IF aux_dtdifere = 1 THEN
      ASSIGN par_dtdifere = TRUE.
                                          
    IF aux_vldifere = 1 THEN
      ASSIGN par_vldifere = TRUE.

    IF aux_cobregis  = 1 THEN  
      ASSIGN par_cobregis = TRUE.
        
    RETURN "OK". 

END PROCEDURE.


PROCEDURE paga_titulo:
    
    DEF INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_nrdconta LIKE crapttl.nrdconta             NO-UNDO.
    DEF INPUT  PARAM par_idseqttl LIKE crapttl.idseqttl             NO-UNDO.
    DEF INPUT  PARAM par_lindigi1 AS DECI                           NO-UNDO.
    DEF INPUT  PARAM par_lindigi2 AS DECI                           NO-UNDO.
    DEF INPUT  PARAM par_lindigi3 AS DECI                           NO-UNDO.
    DEF INPUT  PARAM par_lindigi4 AS DECI                           NO-UNDO.
    DEF INPUT  PARAM par_lindigi5 AS DECI                           NO-UNDO.
    DEF INPUT  PARAM par_cdbarras AS CHAR                           NO-UNDO.
    DEF INPUT  PARAM par_dscedent AS CHAR                           NO-UNDO.
    DEF INPUT  PARAM par_vllanmto AS DECI                           NO-UNDO.
    DEF INPUT  PARAM par_vlfatura AS DECI                           NO-UNDO.
    DEF INPUT  PARAM par_nrctacob AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_insittit AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_intitcop AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_nrcnvcob AS DECI                           NO-UNDO.
    DEF INPUT  PARAM par_nrboleto AS DECI                           NO-UNDO.
    DEF INPUT  PARAM par_nrdctabb AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_idtitdda AS DECI                           NO-UNDO.
    DEF INPUT  PARAM par_flgagend AS LOGI                           NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INT                            NO-UNDO.
    DEF INPUT  PARAM par_cdcoptfn AS INT                            NO-UNDO. /**/ 
    DEF INPUT  PARAM par_cdagetfn AS INT                            NO-UNDO. /**/ 
    DEF INPUT  PARAM par_nrterfin AS INT                            NO-UNDO. /**/ 
    /* parametro de cobranca registrada */
    DEF INPUT  PARAM par_vlrjuros AS DECIMAL                        NO-UNDO.
    DEF INPUT  PARAM par_vlrmulta AS DECIMAL                        NO-UNDO.
    DEF INPUT  PARAM par_vldescto AS DECIMAL                        NO-UNDO.
    DEF INPUT  PARAM par_vlabatim AS DECIMAL                        NO-UNDO.
    DEF INPUT  PARAM par_vloutdeb AS DECIMAL                        NO-UNDO.
    DEF INPUT  PARAM par_vloutcre AS DECIMAL                        NO-UNDO.

    DEF INPUT  PARAM par_nrcpfope AS DECIMAL                        NO-UNDO.
    /* Tipo de captura 1-leitora 2- linha digitavel*/
    DEF INPUT  PARAM par_tpcptdoc AS INTE                           NO-UNDO. 
    /* Numero controle consulta npc */   
    DEF INPUT  PARAM par_cdctlnpc AS CHAR                           NO-UNDO. 
    DEF INPUT  PARAM par_flmobile AS LOGICAL                        NO-UNDO. 
    DEF INPUT  PARAM par_iptransa AS CHAR                           NO-UNDO.
    DEF INPUT  PARAM par_iddispos AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM par_dstransa AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic LIKE crapcri.dscritic             NO-UNDO.
    DEF OUTPUT PARAM par_dsprotoc LIKE crappro.dsprotoc             NO-UNDO.
    DEF OUTPUT PARAM par_cdbcoctl AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cdagectl AS CHAR                           NO-UNDO.

 
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_contadip AS INTE                                    NO-UNDO.
    DEF VAR aux_cdhistor AS INTE                                    NO-UNDO.
    DEF VAR aux_cdhisdeb AS INTE                                    NO-UNDO.
    DEF VAR aux_sequenci AS INTE                                    NO-UNDO.
    DEF VAR aux_cdbccxlt AS INTE                                    NO-UNDO.
    DEF VAR aux_nrcnvbol AS INTE                                    NO-UNDO.
    DEF VAR aux_nrctabol AS INTE                                    NO-UNDO.
    DEF VAR aux_nrboleto AS INTE                                    NO-UNDO.
    DEF VAR aux_cdagenci AS INTE                                    NO-UNDO.
    DEF VAR aux_nrcnvco1 AS INTE                                    NO-UNDO.
    DEF VAR aux_nrcnvco2 AS INTE                                    NO-UNDO.

    DEF VAR aux_flgpagto AS DECI                                    NO-UNDO.
    DEF VAR aux_flgemail AS LOGI                                    NO-UNDO.
    DEF VAR aux_flsenlet AS LOGI                                    NO-UNDO.

    DEF VAR aux_nrdocmto AS DECI                                    NO-UNDO.
    DEF VAR aux_vlpagtos AS DECI                                    NO-UNDO.

    DEF VAR aux_dslitera AS CHAR                                    NO-UNDO.
    DEF VAR aux_lindigit AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsinfor1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsinfor2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsinfor3 AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmextttl AS CHAR                                    NO-UNDO.
    DEF VAR aux_conteudo AS CHAR                                    NO-UNDO.
    DEF VAR aux_dspagtos AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdipant AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdipatu AS CHAR                                    NO-UNDO.

    DEF VAR aux_nrautdoc LIKE craplcm.nrautdoc                      NO-UNDO.

    DEF VAR aux_nrdrecid AS RECID                                   NO-UNDO.

    DEF VAR aux_rowidcob                  AS ROWID                  NO-UNDO.
    DEF VAR aux_recidcob                  AS INT64                  NO-UNDO.
    DEF VAR aux_indpagto                  AS INTE                   NO-UNDO.
    DEF VAR ret_dsinserr                  AS CHAR                   NO-UNDO.
    DEF VAR aux_flgerlog                  AS CHAR                   NO-UNDO.  
	  DEF VAR aux_des_log                   AS CHAR                   NO-UNDO.
    
    DEF VAR h-b1wgen0153                  AS HANDLE                 NO-UNDO.
    DEF VAR h_b1crap00                    AS HANDLE                 NO-UNDO.
    DEF VAR h_b2crap14                    AS HANDLE                 NO-UNDO.
    DEF VAR h-b1crapaut                   AS HANDLE                 NO-UNDO.
    DEF VAR h-b1craplcm                   AS HANDLE                 NO-UNDO.
    DEF VAR h-b1craplot                   AS HANDLE                 NO-UNDO.
    DEF VAR h-b1crapmvi                   AS HANDLE                 NO-UNDO.
    DEF VAR h-bo_algoritmo_seguranca      AS HANDLE                 NO-UNDO.
    DEF VAR h-b1wgen0011                  AS HANDLE                 NO-UNDO.
    DEF VAR h-b1wgen0032                  AS HANDLE                 NO-UNDO.
    DEF VAR h-b1wgen0079                  AS HANDLE                 NO-UNDO.
    DEF VAR h-b1wgen0088                  AS HANDLE                 NO-UNDO.

    DEFINE VARIABLE aux_nrcpfpre AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE aux_nmprepos AS CHARACTER   NO-UNDO.

    DEFINE VARIABLE aux_nrsequen AS INTEGER     NO-UNDO.

    DEFINE BUFFER cra2ass FOR crapass.
    DEFINE BUFFER crabavt FOR crapavt.

    DEF VAR aux_dstransa AS CHARACTER   NO-UNDO.
    DEF VAR aux_cdcritic AS INTEGER     NO-UNDO.
    DEF VAR aux_dscritic AS CHARACTER   NO-UNDO.
    
    /* tratamento para TAA */
    IF  par_idorigem = 4  THEN
        ASSIGN aux_cdagenci = 91
               aux_cdhisdeb = 856.
    ELSE
        ASSIGN aux_cdagenci = 90
               aux_cdhisdeb = 508.

    /* Data do sistema */
    FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
        
    par_dstransa = "Pagamento de titulo".

    FOR FIRST crapcop FIELDS (cdcooper nmrescop cdbcoctl cdagectl
                              vlinimon vllmonip)
        WHERE crapcop.cdcooper = par_cdcooper NO-LOCK.
    END.
    
    IF   NOT AVAILABLE crapcop   THEN
         DO:
             par_dscritic = "Cooperativa nao cadastrada.".
             RETURN "NOK".
         END.
    
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
                       
    IF   NOT AVAILABLE crapass   THEN
         DO:
             par_dscritic = "Associado nao cadastrado.".
             RETURN "NOK".
         END.

    ASSIGN par_cdbcoctl = STRING(crapcop.cdbcoctl,"999")
           par_cdagectl = STRING(crapcop.cdagectl,"9999").

    VALIDATE crapcob.
    
    /*TITULO:
    DO  TRANSACTION ON ERROR UNDO TITULO, RETURN "NOK":    */

        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

     RUN STORED-PROCEDURE pc_paga_titulo
             aux_handproc = PROC-HANDLE NO-ERROR
              ( INPUT par_cdcooper /* pr_cdcooper --Codigo da cooperativa            */
               ,INPUT par_nrdconta /* pr_nrdconta --Numero da conta                  */
               ,INPUT par_idseqttl /* pr_idseqttl --Sequencial titular               */
               ,INPUT par_lindigi1 /* pr_lindigi1 --Linha digitavel 1                */
               ,INPUT par_lindigi2 /* pr_lindigi2 --Linha digitavel 2                */
               ,INPUT par_lindigi3 /* pr_lindigi3 --Linha digitavel 3                */
               ,INPUT par_lindigi4 /* pr_lindigi4 --Linha digitavel 4                */
               ,INPUT par_lindigi5 /* pr_lindigi5 --Linha digitavel 5                */
               ,INPUT par_cdbarras /* pr_cdbarras --Codigo de Barras                 */
               ,INPUT par_dscedent /* pr_dscedent --Descricao do Cedente             */
               ,INPUT par_vllanmto /* pr_vllanmto --Valor Lancamento                 */
               ,INPUT par_vlfatura /* pr_vlfatura --Valor fatura                     */
               ,INPUT par_nrctacob /* pr_nrctacob --Numero Conta Cobranca            */
               ,INPUT par_insittit /* pr_insittit --Indicador Situacao Titulo        */
               ,INPUT par_intitcop /* pr_intitcop --Indicador Titulo Cooperativa     */
               ,INPUT par_nrcnvcob /* pr_nrcnvcob --Numero Convenio Cobranca         */
               ,INPUT-OUTPUT par_nrboleto /* pr_nrboleto --Numero Boleto                    */
               ,INPUT par_nrdctabb /* pr_nrdctabb --Numero conta                     */
               ,INPUT par_idtitdda /* pr_idtitdda --Indicador titulo DDA             */
               ,INPUT IF par_flgagend = TRUE THEN 1
                      ELSE 0       /* pr_flgagend --Flag agendado                    */
               ,INPUT par_idorigem /* pr_idorigem --Indicador de origem              */
               ,INPUT par_cdcoptfn /* pr_cdcoptfn --Codigo cooperativa transacao     */
               ,INPUT par_cdagetfn /* pr_cdagetfn --Codigo Agencia transacao         */
               ,INPUT par_nrterfin /* pr_nrterfin --Numero terminal financeiro       */
               /* parametro de cobranca registrada                      */
               ,INPUT par_vlrjuros /* pr_vlrjuros --Valor Juros                      */
               ,INPUT par_vlrmulta /* pr_vlrmulta --Valor Multa                      */
               ,INPUT par_vldescto /* pr_vldescto --Valor desconto                   */
               ,INPUT par_vlabatim /* pr_vlabatim --Valor Abatimento                 */
               ,INPUT par_vloutdeb /* pr_vloutdeb --Valor saida debito               */
               ,INPUT par_vloutcre /* pr_vloutcre --Valor saida credito              */
               ,INPUT par_nrcpfope /* pr_nrcpfope --Numero cpf operador              */
               ,INPUT par_tpcptdoc /* pr_tpcptdoc -- Tp captura (1=Leitora, 2=Lindig */
               ,INPUT par_cdctlnpc /* pr_cdctrlcs -- Nr controle da consulta no NPC  */
               ,INPUT INT(par_flmobile) /* Identificador de origem mobile */ 
               ,INPUT par_iptransa /* IP da transacao */
               ,INPUT par_iddispos /* identificador do dispositivo */
               
               ,OUTPUT ""   /*pr_dstransa --Descricao transacao              */
               ,OUTPUT ""   /*pr_dsprotoc --Descricao Protocolo              */ 
               ,OUTPUT ""    /*pr_cdbcoctl --Codigo Banco Centralizador       */
               ,OUTPUT ""    /*pr_cdagectl --Codigo Agencia Centralizadora    */                   
               ,OUTPUT 0    /*pr_cdcritic --Codigo da critica                */
               ,OUTPUT ""). /*pr_dscritic --Descricao critica                */

         
     CLOSE STORED-PROC pc_paga_titulo
               aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

    ASSIGN aux_cdcritic = 0
               par_dscritic = ""
           par_dstransa = ""    
           par_dsprotoc = ""    
           par_cdbcoctl = ""
           par_cdagectl = ""
           par_dstransa = pc_paga_titulo.pr_dstransa             /*pr_dstransa --Descricao transacao           */
                          WHEN pc_paga_titulo.pr_dstransa <> ?           
           par_dsprotoc = pc_paga_titulo.pr_dsprotoc             /*pr_dsprotoc ~ --Descricao Protocolo         */ 
                          WHEN pc_paga_titulo.pr_dsprotoc <> ?   
           par_cdbcoctl = pc_paga_titulo.pr_cdbcoctl             /*pr_cdbcoctl --Codigo Banco Centralizador    */
                          WHEN pc_paga_titulo.pr_cdbcoctl <> ?   
           par_cdagectl = pc_paga_titulo.pr_cdagectl             /*pr_cdagectl --Codigo Agencia Centralizadora */
                          WHEN pc_paga_titulo.pr_cdagectl <> ?   
           aux_cdcritic = pc_paga_titulo.pr_cdcritic             /*pr_cdcritic --Codigo da critica             */
                          WHEN pc_paga_titulo.pr_cdcritic <> ?   
           par_dscritic = pc_paga_titulo.pr_dscritic             /*pr_dscritic --Descricao critica             */
                          WHEN pc_paga_titulo.pr_dscritic <> ?.       
        
    /* Verificar se retornou critica */
    IF  aux_cdcritic > 0 OR par_dscritic <> "" THEN
        RETURN "NOK".
                                      
        
    RETURN "OK".

END PROCEDURE.


PROCEDURE pagamentos_liberados:

    DEF INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_flgconve AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM par_flgtitul AS LOGI                           NO-UNDO.
    
    ASSIGN par_flgconve = TRUE
           par_flgtitul = TRUE.

    FIND FIRST crapcon WHERE crapcon.cdcooper = par_cdcooper AND
                             crapcon.flginter = TRUE         NO-LOCK NO-ERROR.
                             
    IF  NOT AVAILABLE crapcon  THEN                         
        ASSIGN par_flgconve = FALSE.                   
                
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
                           
    IF  NOT AVAILABLE crapcop  OR 
        crapcop.cdbcoctl = 0   OR
        crapcop.cdagectl = 0   THEN
        ASSIGN par_flgtitul = FALSE.
        
    RETURN "OK".
    
END PROCEDURE.

PROCEDURE cadastrar-agendamento:

    DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci LIKE crapage.cdagenci             NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa LIKE craplot.nrdcaixa             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad LIKE crapope.cdoperad             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta             NO-UNDO.
    DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt             NO-UNDO.
    /* Projeto 363 - Novo ATM */
    DEF  INPUT PARAM par_idorigem AS   INTE                         NO-UNDO.
    DEF  INPUT PARAM par_dsorigem LIKE craplau.dsorigem             NO-UNDO.
    DEF  INPUT PARAM par_nmprogra AS   CHAR                         NO-UNDO.
    DEF  INPUT PARAM par_cdtiptra LIKE craplau.cdtiptra             NO-UNDO.
    DEF  INPUT PARAM par_idtpdpag AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dscedent LIKE craplau.dscedent             NO-UNDO.
    DEF  INPUT PARAM par_dscodbar LIKE craplau.dscodbar             NO-UNDO.
    DEF  INPUT PARAM par_lindigi1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_lindigi2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_lindigi3 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_lindigi4 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_lindigi5 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdhistor LIKE craplau.cdhistor             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopg LIKE craplau.dtmvtopg             NO-UNDO.
    DEF  INPUT PARAM par_vllanaut LIKE craplau.vllanaut             NO-UNDO.
    DEF  INPUT PARAM par_dtvencto LIKE craplau.dtvencto             NO-UNDO.
    DEF  INPUT PARAM par_cddbanco LIKE craplau.cddbanco             NO-UNDO.
    DEF  INPUT PARAM par_cdageban LIKE craplau.cdageban             NO-UNDO.
    DEF  INPUT PARAM par_nrctadst LIKE craplau.nrctadst             NO-UNDO.
    DEF  INPUT PARAM par_cdcoptfn LIKE craplau.cdcoptfn             NO-UNDO.
    DEF  INPUT PARAM par_cdagetfn LIKE craplau.cdagetfn             NO-UNDO.
    DEF  INPUT PARAM par_nrterfin LIKE craplau.nrterfin             NO-UNDO.
    DEF  INPUT PARAM par_nrcpfope LIKE craplau.nrcpfope             NO-UNDO.
    DEF  INPUT PARAM par_idtitdda LIKE craplau.idtitdda             NO-UNDO.
    DEF  INPUT PARAM par_cdtrapen AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idtipcar AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcartao AS DECI                           NO-UNDO.

    DEF  INPUT PARAM par_cdfinali AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dstransf AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dshistor AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_iptransa AS CHAR                           NO-UNDO.
	  DEF  INPUT PARAM par_cdctrlcs AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flmobile AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_iddispos AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_msgofatr AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cdempcon AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_cdsegmto AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dstransa AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.


    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_cadastrar_agendamento
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,  
                          INPUT par_cdoperad,
                          INPUT par_nrdconta,
                          INPUT par_idseqttl,                          
                          INPUT par_dtmvtolt,
                          /* Projeto 363 - Novo ATM */
                          INPUT par_idorigem,
                          INPUT par_dsorigem,
                          INPUT par_nmprogra,
                          INPUT par_cdtiptra,
                          INPUT par_idtpdpag,
                          INPUT par_dscedent,
                          INPUT par_dscodbar,
                          INPUT par_lindigi1,
                          INPUT par_lindigi2,
                          INPUT par_lindigi3,
                          INPUT par_lindigi4,
                          INPUT par_lindigi5,                          
                          INPUT par_cdhistor,
                          INPUT par_dtmvtopg,
                          INPUT par_vllanaut,
                          INPUT par_dtvencto,
                          INPUT par_cddbanco,
                          INPUT par_cdageban,
                          INPUT par_nrctadst,                          
                          INPUT par_cdcoptfn,
                          INPUT par_cdagetfn,
                          INPUT par_nrterfin,
                          INPUT par_nrcpfope,
                          INPUT STRING(par_idtitdda),
                          INPUT par_cdtrapen,
                          INPUT INT(par_flmobile),
                          INPUT par_idtipcar,
                          INPUT par_nrcartao,
                          INPUT par_cdfinali,
                          INPUT par_dstransf,
                          INPUT par_dshistor,
                          INPUT par_iptransa,  /* pr_iptransa */
						              INPUT par_cdctrlcs, /* pr_cdctrlcs*/
                          INPUT par_iddispos,
                          INPUT 0, /* pr_nrridlfp */
                         OUTPUT 0, /* pr_idlancto */
                         OUTPUT "",  /* pr_dstransa */                         
                         OUTPUT "",
                         OUTPUT 0,
                         OUTPUT "",                         
                         OUTPUT "").   /* pr_dscritic */

    CLOSE STORED-PROC pc_cadastrar_agendamento
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    ASSIGN par_dstransa = pc_cadastrar_agendamento.pr_dstransa
                     WHEN pc_cadastrar_agendamento.pr_dstransa <> ?        
           par_dscritic = pc_cadastrar_agendamento.pr_dscritic
                     WHEN pc_cadastrar_agendamento.pr_dscritic <> ?
           par_msgofatr = pc_cadastrar_agendamento.pr_msgofatr
                     WHEN pc_cadastrar_agendamento.pr_msgofatr <> ?
           par_cdempcon = INT(pc_cadastrar_agendamento.pr_cdempcon)
                     WHEN pc_cadastrar_agendamento.pr_cdempcon <> ?
           par_cdsegmto = pc_cadastrar_agendamento.pr_cdsegmto
                     WHEN pc_cadastrar_agendamento.pr_cdsegmto <> ?.
        

        IF  par_dscritic <> ""  THEN
    RETURN "NOK".    

    RETURN "OK".
    
END PROCEDURE.


PROCEDURE obtem-agendamentos:

    DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci LIKE crapage.cdagenci             NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa LIKE craplot.nrdcaixa             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta LIKE crapass.nrdconta             NO-UNDO.
    DEF  INPUT PARAM par_dsorigem LIKE craplau.dsorigem             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt             NO-UNDO.
    DEF  INPUT PARAM par_dtageini LIKE craplau.dtmvtopg             NO-UNDO.
    DEF  INPUT PARAM par_dtagefim LIKE craplau.dtmvtopg             NO-UNDO.
    DEF  INPUT PARAM par_insitlau LIKE craplau.insitlau             NO-UNDO.
    DEF  INPUT PARAM par_iniconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_dstransa AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_qttotage AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-dados-agendamento.
    
    DEF VAR aux_cdcritic AS INTE          NO-UNDO.
    DEF VAR aux_dscritic AS CHAR          NO-UNDO.
      
    /* Variaveis para o XML */ 
    DEF VAR xDoc          AS HANDLE   NO-UNDO.
    DEF VAR xRoot         AS HANDLE   NO-UNDO.
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.
    DEF VAR xField        AS HANDLE   NO-UNDO.
    DEF VAR xText         AS HANDLE   NO-UNDO.
    DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO.
    DEF VAR aux_cont      AS INTEGER  NO-UNDO.
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO.
    DEF VAR xml_req       AS LONGCHAR NO-UNDO.
    
    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} } 
    
    /* Efetuar a chamada a rotina Oracle */     
    RUN STORED-PROCEDURE pc_obtem_agendamentos_car
      aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Código da Cooperativa */
                                           INPUT par_cdagenci, /* Código do PA */
                                           INPUT par_nrdcaixa, /* Numero do Caixa */
                                           INPUT par_nrdconta, /* Numero da Conta */
                                           INPUT par_dsorigem, /* Descricao da Origem */
                                           INPUT par_dtmvtolt, /* Data de Movimentacao Atual */
                                           INPUT par_dtageini, /* Data de Agendamento Inicial */
                                           INPUT par_dtagefim, /* Data de Agendamento Final */
                                           INPUT par_insitlau, /* Situacao do Lancamento */
                                           INPUT par_iniconta, /* Numero de Registros da Tela */
                                           INPUT par_nrregist, /* Numero da Registros */                                           
                                          OUTPUT "",           /* Descricao da Transacao */ 
                                          OUTPUT 0,            /*Quantidade Total de Agendamentos*/ 
                                          OUTPUT ?,            /* XML com informaçoes de LOG */
                                          OUTPUT 0,            /* Código da crítica */
                                          OUTPUT "").          /* Descriçao da crítica */
    
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_obtem_agendamentos_car
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} } 
    
    /* Busca possíveis erros */ 
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           par_qttotage = INTE(pc_obtem_agendamentos_car.pr_qttotage)
                          WHEN pc_obtem_agendamentos_car.pr_qttotage <> ?
           aux_cdcritic = INTE(pc_obtem_agendamentos_car.pr_cdcritic)
                          WHEN pc_obtem_agendamentos_car.pr_cdcritic <> ?
           aux_dscritic = pc_obtem_agendamentos_car.pr_dscritic 
                          WHEN pc_obtem_agendamentos_car.pr_dscritic <> ?
                          .
                       
    IF aux_cdcritic <> 0 OR
       aux_dscritic <> "" THEN
        DO:
        ASSIGN par_dscritic = aux_dscritic.
                             
        RETURN "NOK".
                    END.
                    
    EMPTY TEMP-TABLE tt-dados-agendamento. 
                  
    /*Leitura do XML de retorno da proc para criacao dos registros na tt-dados-agendamento */
    ASSIGN xml_req = pc_obtem_agendamentos_car.pr_clobxmlc. 

    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 

    IF ponteiro_xml <> ? THEN
                        DO:
        xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
        xDoc:GET-DOCUMENT-ELEMENT(xRoot) NO-ERROR.

        DO aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
									
          xRoot:GET-CHILD(xRoot2,aux_cont_raiz) NO-ERROR.
							
          IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
            NEXT. 

          IF xRoot2:NUM-CHILDREN > 0 THEN
            CREATE tt-dados-agendamento.

          DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                    
            xRoot2:GET-CHILD(xField,aux_cont) NO-ERROR. 
                        
            IF xField:SUBTYPE <> "ELEMENT" THEN 
                             NEXT.

            xField:GET-CHILD(xText,1) NO-ERROR. 

            /* Se nao vier conteudo na TAG */ 
            IF ERROR-STATUS:ERROR             OR  
               ERROR-STATUS:NUM-MESSAGES > 0  THEN
                             NEXT.

            ASSIGN tt-dados-agendamento.dttransa = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dttransa".
            ASSIGN tt-dados-agendamento.dssitlau =      xText:NODE-VALUE  WHEN xField:NAME = "dssitlau".
            ASSIGN tt-dados-agendamento.dslindig =      xText:NODE-VALUE  WHEN xField:NAME = "dslindig".
            ASSIGN tt-dados-agendamento.dscedent =      xText:NODE-VALUE  WHEN xField:NAME = "dscedent".
            ASSIGN tt-dados-agendamento.dsageban =      xText:NODE-VALUE  WHEN xField:NAME = "dsageban".
            ASSIGN tt-dados-agendamento.nrctadst =      xText:NODE-VALUE  WHEN xField:NAME = "nrctadst".
            ASSIGN tt-dados-agendamento.nmprimtl =      xText:NODE-VALUE  WHEN xField:NAME = "nmprimtl".
            ASSIGN tt-dados-agendamento.nmprepos =      xText:NODE-VALUE  WHEN xField:NAME = "nmprepos".
            ASSIGN tt-dados-agendamento.nmoperad =      xText:NODE-VALUE  WHEN xField:NAME = "nmoperad".
            ASSIGN tt-dados-agendamento.idtitdda =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "idtitdda".
            ASSIGN tt-dados-agendamento.tpcaptur =  INT(xText:NODE-VALUE) WHEN xField:NAME = "tpcaptur".
            ASSIGN tt-dados-agendamento.dstipcat =      xText:NODE-VALUE  WHEN xField:NAME = "dstipcat".
            ASSIGN tt-dados-agendamento.dsidpgto =      xText:NODE-VALUE  WHEN xField:NAME = "dsidpgto".
            ASSIGN tt-dados-agendamento.dsnomfon =      xText:NODE-VALUE  WHEN xField:NAME = "dsnomfon".
            ASSIGN tt-dados-agendamento.vllanaut =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "vllanaut".
            ASSIGN tt-dados-agendamento.vlprinci =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "vlprinci".
            ASSIGN tt-dados-agendamento.vlrmulta =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "vlrmulta".
            ASSIGN tt-dados-agendamento.vlrjuros =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "vlrjuros".
            ASSIGN tt-dados-agendamento.vlrtotal =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "vlrtotal".
            ASSIGN tt-dados-agendamento.vlrrecbr =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "vlrrecbr".
            ASSIGN tt-dados-agendamento.vlrperce =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "vlrperce".
            ASSIGN tt-dados-agendamento.nrcpfpre =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "nrcpfpre".
            ASSIGN tt-dados-agendamento.nrcpfope =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "nrcpfope".                    
            ASSIGN tt-dados-agendamento.hrtransa =  INT(xText:NODE-VALUE) WHEN xField:NAME = "hrtransa".
            ASSIGN tt-dados-agendamento.nrdocmto =  INT(xText:NODE-VALUE) WHEN xField:NAME = "nrdocmto".
            ASSIGN tt-dados-agendamento.incancel =  INT(xText:NODE-VALUE) WHEN xField:NAME = "incancel".
            ASSIGN tt-dados-agendamento.cdreceit =  INT(xText:NODE-VALUE) WHEN xField:NAME = "cdreceit".
            ASSIGN tt-dados-agendamento.nrrefere =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "nrrefere".
            ASSIGN tt-dados-agendamento.cdageban =      xText:NODE-VALUE  WHEN xField:NAME = "cdageban".
            ASSIGN tt-dados-agendamento.cdtiptra =  INT(xText:NODE-VALUE) WHEN xField:NAME = "cdtiptra".
            ASSIGN tt-dados-agendamento.dstiptra =      xText:NODE-VALUE  WHEN xField:NAME = "dstiptra".        
            ASSIGN tt-dados-agendamento.dtmvtage = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtmvtage".
            ASSIGN tt-dados-agendamento.dtmvtopg = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtmvtopg".
            ASSIGN tt-dados-agendamento.dtvencto = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtvencto".
            ASSIGN tt-dados-agendamento.dtagenda = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtagenda".
            ASSIGN tt-dados-agendamento.dtperiod = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtperiod".
            ASSIGN tt-dados-agendamento.dtvendrf = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtvendrf".
            ASSIGN tt-dados-agendamento.nrcpfcgc =     (xText:NODE-VALUE) WHEN xField:NAME = "nrcpfcgc".
            ASSIGN tt-dados-agendamento.gpscddpagto = DEC(xText:NODE-VALUE) WHEN xField:NAME = "gps_cddpagto".
            ASSIGN tt-dados-agendamento.gpsdscompet =    (xText:NODE-VALUE) WHEN xField:NAME = "gps_dscompet".
            ASSIGN tt-dados-agendamento.gpscdidenti = DEC(xText:NODE-VALUE) WHEN xField:NAME = "gps_cdidenti".
            ASSIGN tt-dados-agendamento.gpsvlrdinss = DEC(xText:NODE-VALUE) WHEN xField:NAME = "gps_vlrdinss".
            ASSIGN tt-dados-agendamento.gpsvlrouent = DEC(xText:NODE-VALUE) WHEN xField:NAME = "gps_vlrouent".
            ASSIGN tt-dados-agendamento.gpsvlrjuros = DEC(xText:NODE-VALUE) WHEN xField:NAME = "gps_vlrjuros". 
                                     
                    END.
						 
					  END.

        SET-SIZE(ponteiro_xml) = 0.
                      
                  END.

    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.

    RETURN "OK".

END PROCEDURE.

PROCEDURE cancelar-agendamento:

    DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci LIKE crapage.cdagenci             NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa LIKE craplot.nrdcaixa             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad LIKE crapope.cdoperad             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta             NO-UNDO.
    DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt             NO-UNDO.
    DEF  INPUT PARAM par_dsorigem LIKE craplau.dsorigem             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtage LIKE craplau.dtmvtolt             NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto LIKE craplau.nrdocmto             NO-UNDO.
    DEF  INPUT PARAM par_idlancto LIKE craplau.idlancto             NO-UNDO.
    
    DEF  INPUT PARAM par_nmdatela AS CHAR						                NO-UNDO.
    DEF  INPUT PARAM par_nrcpfope AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM par_dstransa AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    
    DEF VAR aux_nrdocdeb AS DECI                                    NO-UNDO.
    DEF VAR aux_nrdoccre AS DECI                                    NO-UNDO.
    DEF VAR aux_cdlantar LIKE craplat.cdlantar                      NO-UNDO.

    DEF VAR aux_cdseqfat AS DECI                                    NO-UNDO.
    DEF VAR aux_vlfatura AS DECI                                    NO-UNDO.
    DEF VAR aux_vldpagto AS DECI                                    NO-UNDO.
    
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    DEF VAR aux_flagiptu AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_dssgproc AS CHAR                                    NO-UNDO.
    DEF VAR aux_dstransa AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsprotoc AS CHAR                                    NO-UNDO.
    DEF VAR aux_dscodbar AS CHAR                                    NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdolote AS INTE                                    NO-UNDO.
    DEF VAR aux_incancel AS INTE                                    NO-UNDO.
    DEF VAR aux_hrfimcan AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdigfat AS INTE                                    NO-UNDO. 
    DEF VAR aux_cdhiscre AS INTE                                    NO-UNDO.
    DEF VAR aux_cdhisdeb AS INTE                                    NO-UNDO.
    DEF VAR aux_idorigem AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdrowid AS ROWID                                   NO-UNDO.
	DEF VAR aux_insitlau LIKE craplau.insitlau					    NO-UNDO.
    DEF VAR aux_msgretor AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.

    DEF VAR h-b1wgen0015 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1crap15   AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0079 AS HANDLE                                  NO-UNDO.
    
    ASSIGN par_dstransa = "Cancelar agendamento de pagamentos, transferencias e TED"
           aux_flgtrans = FALSE
           aux_nrdolote = 11000 + par_nrdcaixa.

                        
    IF  par_dsorigem = "INTERNET" THEN
        aux_idorigem = 3.
    ELSE
    IF  par_dsorigem = "TAA" THEN
        aux_idorigem = 4.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN par_dscritic = "Cooperativa nao cadastrada.".
            RETURN "NOK".
        END.
      
    /** Obtem parametros para condicoes de cancelamento **/
    RUN parametros-cancelamento (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT aux_datdodia,
                                OUTPUT aux_hrfimcan,
                                OUTPUT aux_dssgproc,
                                OUTPUT par_dscritic).
                             
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".
    
	IF par_nmdatela = "AGENET" THEN
	   DO:
	      FIND crapope WHERE crapope.cdcooper = par_cdcooper  AND
							 crapope.cdoperad = par_cdoperad
							 NO-LOCK NO-ERROR.
        
		  IF NOT AVAIL crapope THEN
			 DO:
				 ASSIGN par_dscritic = "Nao foi possivel " +
						  			   "encontrar o operador.".
                 RETURN "NOK".

			 END.
		  ELSE 
		  IF crapope.nvoperad <> 2 AND
		     crapope.nvoperad <> 3 THEN
			 DO:
			    ASSIGN par_dscritic = "Cancelamento somente permitido por " + 
									  "coordenadores/gerentes.".
                RETURN "NOK".
		     END.

	   END.

    TRANSACAO:
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
    
        DO aux_contador = 1 TO 10:
            
            ASSIGN par_dscritic = "".
        
            IF  par_idlancto <> 0  THEN
                FIND craplau WHERE craplau.idlancto = par_idlancto 
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            ELSE
                FIND craplau WHERE craplau.cdcooper = par_cdcooper AND
                                   craplau.nrdconta = par_nrdconta AND
                                   craplau.dtmvtolt = par_dtmvtage AND
                                   craplau.cdagenci = par_cdagenci AND
                                   craplau.cdbccxlt = 100          AND
                                   craplau.nrdolote = aux_nrdolote AND
                                   craplau.nrdocmto = par_nrdocmto AND
                                   craplau.dsorigem = par_dsorigem 
                                   USE-INDEX craplau1
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
               
            IF  NOT AVAILABLE craplau  THEN
                DO: 
                    IF  LOCKED craplau  THEN
                        DO:
                            ASSIGN par_dscritic = "Registro do agendamento " +
                                                  "esta sendo alterado. " +
                                                  "Tente novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        ASSIGN par_dscritic = "Agendamento nao cadastrado.".
                END.
        
            LEAVE.
            
        END. /** Fim do DO ... TO **/
        
        IF  par_dscritic <> ""  THEN
            UNDO TRANSACAO, LEAVE TRANSACAO.
			
        /** Verifica se agendamento esta pendente **/
        IF  craplau.insitlau <> 1                                           AND
            NOT (craplau.insitlau = 2 AND craplau.dtmvtopg > aux_datdodia)  THEN
            DO:
                ASSIGN par_dscritic = "Para cancelar, o agendamento deve " +
                                      "estar PENDENTE.".
                UNDO TRANSACAO, LEAVE TRANSACAO.                      
            END.
            
      /* Se for agendamento de gps */
        IF craplau.cdtiptra = 2 AND craplau.nrseqagp > 0 THEN DO:
        
            IF craplau.insitlau <> 1 THEN DO:
                ASSIGN par_dscritic = "Para cancelar, o agendamento deve estar PENDENTE.".
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.        
            
                       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

            RUN STORED-PROCEDURE pc_gps_agmto_desativar_car aux_handproc = PROC-HANDLE NO-ERROR
                                 (INPUT par_cdcooper,         /* pr_cdcooper */
                                  INPUT par_nrdconta,         /* pr_nrdconta */
                                  INPUT craplau.nrseqagp,     /* pr_nrseqagp */
                                  INPUT 3,                    /* pr_idorigem */
                                  INPUT "996",                /* pr_cdoperad */
                                  INPUT "INTERNETBANK",       /* pr_nmdatela */
                                  INPUT 1,                    /* pr_flmobile */
                                  OUTPUT "").                 /* pr_dscritic */

              CLOSE STORED-PROC pc_gps_agmto_desativar_car aux_statproc = PROC-STATUS
                    WHERE PROC-HANDLE = aux_handproc.

              ASSIGN par_dscritic = pc_gps_agmto_desativar_car.pr_dscritic
                                    WHEN pc_gps_agmto_desativar_car.pr_dscritic <> ?.
           
              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

              IF par_dscritic <> "" THEN DO:
                UNDO TRANSACAO, LEAVE TRANSACAO.                  
              END.
        
        END.  /* se for TED */
        ELSE IF craplau.cdtiptra = 4 OR craplau.cdtiptra = 22 THEN /*REQ39*/
        DO: 
           /*Somente pode ser permitido cancela-lo se o mesmo AINDA ESTA
             COM O STATUS DE "EFETIVADO". */
            IF craplau.insitlau <> 1 THEN
            DO:
                ASSIGN par_dscritic = "Para cancelar, o agendamento deve " + 
                                      "estar PENDENTE.".
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

			FIND FIRST crapprm WHERE crapprm.cdcooper = par_cdcooper AND
							 		 crapprm.nmsistem = 'CRED'       AND
							 		 crapprm.cdacesso = 'HORARIO_CANCELAMENTO_TED'
							 		 NO-LOCK NO-ERROR.

		    IF  NOT AVAILABLE crapprm THEN
		  	    DO:
			 	   ASSIGN par_dscritic = "Nao foi encontrado horario limite para " +
					 					 "cancelamento de TED.".

				   UNDO TRANSACAO, LEAVE TRANSACAO.
									
			    END.
            
            /*O cancelamento de TED dever ser permitido somente ate as 8:30 (Horario
			  parametrizado atraves da tabela crapprm) pois o programa pr_crps705 
			  (Responsavel pelo debito de agendamentos de TED) sera iniciado as 8:40.
              Qualquer mudanca na condicao abaixo devera ser previamente discutida com
              a equipe do financeiro (Juliana), do canais de atendimento (Jefferson),
			  Seguranca Corporativa (Maicon) e de sistemas (Adriano, Rosangela).*/
            IF (craplau.dtmvtopg = aux_datdodia AND
                TIME > INT(crapprm.dsvlrprm))        THEN
            DO:
			  ASSIGN par_dscritic = "Cancelamento permitido apenas ate " + STRING(INT(crapprm.dsvlrprm),"HH:MM") + "hrs.".
              UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        END.
        /*397*/
        /*validar o limite operador, antes de realizar a reprovacao do agendamento*/
        IF par_nrcpfope > 0 THEN 
          DO:
		            
            /* Procedimento do internetbank pc_verifica_limite_ope_prog */
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                            
            RUN STORED-PROCEDURE pc_verifica_limite_ope_canc aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper
                                ,INPUT par_nrdconta
                                ,INPUT par_idseqttl
                                ,INPUT par_nrcpfope
                                ,INPUT par_cdoperad
                                ,INPUT craplau.vllanaut 
                                ,INPUT craplau.cdtiptra 
                                ,INPUT craplau.dtmvtopg
                                ,INPUT "INTERNET"
                                ,OUTPUT ""
                                ,OUTPUT 0
                                ,OUTPUT "").
                  
            CLOSE STORED-PROC pc_verifica_limite_ope_canc
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl}}

            ASSIGN aux_dscritic   = ""
                   aux_dscritic   = pc_verifica_limite_ope_canc.pr_dscritic 
                                    WHEN pc_verifica_limite_ope_canc.pr_dscritic <> ?
                   aux_msgretor   = pc_verifica_limite_ope_canc.pr_msgretor
                                    WHEN pc_verifica_limite_ope_canc.pr_msgretor <> ?.
                                    
            IF aux_msgretor <> "OK" THEN 
            DO:
              ASSIGN par_dscritic = aux_msgretor.
              UNDO TRANSACAO, LEAVE TRANSACAO.
              

            END.

            /* Verificar se retornou critica */
            IF aux_dscritic <> "" THEN 
             DO:
              UNDO TRANSACAO, LEAVE TRANSACAO.
            END. 
        END.
        /**/
		            
        /* Alterar status de transacao para reprovada */
        IF craplau.cdtrapen > 0 THEN
            DO:
        
                DO aux_contador = 1 TO 10:
                
                    ASSIGN par_dscritic = "".
                
                    FIND tbgen_trans_pend WHERE tbgen_trans_pend.cdtransacao_pendente = craplau.cdtrapen EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                       
                    IF  NOT AVAILABLE tbgen_trans_pend  THEN
                        DO:
                            IF  LOCKED tbgen_trans_pend  THEN
                                DO:
                                    ASSIGN par_dscritic = "Registro de transacao esta sendo alterado. " +
                                                          "Tente novamente.".
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                            ELSE
                                ASSIGN par_dscritic = "Registro de transacao nao cadastrado.".
                        END.
                
                    LEAVE.
                    
                END. /** Fim do DO ... TO **/
                
                ASSIGN tbgen_trans_pend.idsituacao_transacao = 6 /* Reprovada */
                       tbgen_trans_pend.dtalteracao_situacao = TODAY.
                
            END.

        /** Verifica horario para cancelar e parametro do segundo processo **/
        IF  craplau.dtmvtopg = aux_datdodia  AND
           (TIME > aux_hrfimcan              OR
            aux_dssgproc = "NAO")            THEN
            DO:
                ASSIGN par_dscritic = "Sem permissao para excluir o " +
                                      "agendamento no momento.".
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
       
        /** Estornar registros ja criados referente ao debito **/
        IF  craplau.insitlau = 2  THEN
            DO: 
                /** Transf. Intracoop. **/
                IF  craplau.cdtiptra = 1  OR    /** Normal          **/
                    craplau.cdtiptra = 3  THEN  /** Credito Salario **/
                    DO:
                        ASSIGN aux_nrdocdeb = DECI(SUBSTR(craplau.dscedent,
                                                          15,11))
                               aux_nrdoccre = DECI(SUBSTR(craplau.dscedent,
                                                          44,11)).
                        
                        RUN sistema/generico/procedures/b1wgen0015.p
                            PERSISTENT SET h-b1wgen0015.

                        IF  NOT VALID-HANDLE(h-b1wgen0015)  THEN
                            DO:
                                par_dscritic = "Handle invalido para BO " +
                                               "b1wgen0015.".
                                UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.

                        RUN verifica-historico-transferencia IN h-b1wgen0015
                                                      (INPUT par_cdcooper,
                                                       INPUT craplau.nrdconta,
                                                       INPUT craplau.nrctadst,
                                                       INPUT aux_idorigem,
                                                       INPUT craplau.cdtiptra,
                                                      OUTPUT aux_cdhiscre,
                                                      OUTPUT aux_cdhisdeb).   

                        RUN estorna-transferencia IN h-b1wgen0015 
                                                       (INPUT par_cdcooper,
                                                        INPUT craplau.nrdconta,
                                                        INPUT craplau.idseqttl,
                                                        INPUT par_dtmvtolt,
                                                        INPUT par_cdagenci,
                                                        INPUT par_nrdcaixa,
                                                        INPUT craplau.nrctadst,
                                                        INPUT aux_cdhisdeb,
                                                        INPUT aux_cdhiscre,
                                                        INPUT aux_nrdocdeb,
                                                        INPUT aux_nrdoccre,
                                                        INPUT par_cdoperad,
                                                       OUTPUT aux_dstransa,
                                                       OUTPUT par_dscritic,
                                                       OUTPUT aux_dsprotoc).

                        DELETE PROCEDURE h-b1wgen0015.

                        IF  RETURN-VALUE = "NOK"  THEN
                            UNDO TRANSACAO, LEAVE TRANSACAO.    
                    END.
                ELSE
                IF  craplau.cdtiptra = 2  THEN /** Pagamento **/
                    DO:
                        IF  LENGTH(craplau.dslindig) = 54  THEN /** Titulo   **/
                            DO:
                                RUN estorna_titulo (INPUT par_cdcooper,
                                                    INPUT craplau.cdagenci,
                                                    INPUT craplau.dtmvtolt,
                                                    INPUT craplau.nrdconta,
                                                    INPUT craplau.idseqttl, 
                                                    INPUT craplau.dscodbar,  
                                                    INPUT craplau.dscedent, 
                                                    INPUT craplau.vllanaut,  
                                                    INPUT par_cdoperad,
                                                    INPUT aux_idorigem, 
                                                    INPUT craplau.cdctrlcs,
                                                   OUTPUT aux_dstransa, 
                                                   OUTPUT par_dscritic, 
                                                   OUTPUT aux_dsprotoc). 

                                IF  RETURN-VALUE = "NOK"  THEN
                                    UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.
                        ELSE
                        IF  LENGTH(craplau.dslindig) = 55  THEN /** Convenio **/
                            DO:
                                RUN dbo/b1crap15.p PERSISTENT SET h-b1crap15.
    
                                IF  NOT VALID-HANDLE(h-b1crap15)  THEN
                                    DO:
                                        par_dscritic = "Handle invalido para " +
                                                       "BO b1crap15.".
                                        UNDO TRANSACAO, LEAVE TRANSACAO.
                                    END.

                                ASSIGN aux_dscodbar = craplau.dscodbar.

                                RUN retorna-valores-fatura IN h-b1crap15
                                              (INPUT        crapcop.nmrescop,
                                               INPUT        par_cdoperad,
                                               INPUT        par_cdagenci,
                                               INPUT        par_nrdcaixa,
                                               INPUT        0,
                                               INPUT        0,
                                               INPUT        0,
                                               INPUT        0,
                                               INPUT-OUTPUT aux_dscodbar,
                                                     OUTPUT aux_cdseqfat,
                                                     OUTPUT aux_vldpagto,
                                                     OUTPUT aux_vlfatura,
                                                     OUTPUT aux_nrdigfat,
                                                     OUTPUT aux_flagiptu).

                                DELETE PROCEDURE h-b1crap15.

                                IF  RETURN-VALUE = "NOK"  THEN
                                    DO:
                                        FIND FIRST craperr WHERE 
                                            craperr.cdcooper = par_cdcooper AND
                                            craperr.cdagenci = par_cdagenci AND
                                            craperr.nrdcaixa = 
                                                    INT(STRING(par_nrdconta) +
                                                        STRING(par_idseqttl))
                                            NO-LOCK NO-ERROR.
                                      
                                        IF  AVAILABLE craperr  THEN
                                            par_dscritic = craperr.dscritic.
                                        ELSE
                                            par_dscritic = "Erro na verificacao"
                                                           + " da fatura.".
                  
                                        UNDO TRANSACAO, LEAVE TRANSACAO.
                                    END.

                                RUN estorna_convenio (INPUT par_cdcooper,
                                                      INPUT craplau.nrdconta,
                                                      INPUT craplau.idseqttl,
                                                      INPUT aux_dscodbar,
                                                      INPUT craplau.dscedent,
                                                      INPUT aux_cdseqfat,
                                                      INPUT aux_vldpagto,
                                                      INPUT par_cdoperad,
                                                      INPUT aux_idorigem,
                                                     OUTPUT aux_dstransa,
                                                     OUTPUT par_dscritic,
                                                     OUTPUT aux_dsprotoc).
                                                     
                                IF  RETURN-VALUE = "NOK"  THEN
                                    UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.
                    END.
                ELSE
                IF  craplau.cdtiptra = 5   THEN /* Transf. Intercoop. */
                    DO:
                        ASSIGN aux_nrdocdeb = DECI(SUBSTR(craplau.dscedent,
                                                          15,11))
                               aux_nrdoccre = DECI(SUBSTR(craplau.dscedent,
                                                          44,11))
                               aux_cdlantar = DECI(SUBSTR(craplau.dscedent,
                                                          71,11)).

                        RUN sistema/generico/procedures/b1wgen0015.p
                            PERSISTENT SET h-b1wgen0015.

                        IF  NOT VALID-HANDLE(h-b1wgen0015)  THEN
                            DO:
                                par_dscritic = "Handle invalido para BO " +
                                               "b1wgen0015.".
                                UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.
                        
                        RUN estorna-transferencia-intercooperativa 
                            IN h-b1wgen0015 (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT craplau.nrdconta,
                                             INPUT craplau.idseqttl,
                                             INPUT par_dtmvtolt,
                                             INPUT aux_idorigem,
                                             INPUT craplau.cdageban,
                                             INPUT craplau.nrctadst,
                                             INPUT craplau.vllanaut,
                                             INPUT aux_nrdocdeb,
                                             INPUT aux_nrdoccre,
                                             INPUT aux_cdlantar,
                                             INPUT par_cdoperad,
                                            OUTPUT aux_dstransa, 
                                            OUTPUT par_dscritic, 
                                            OUTPUT aux_dsprotoc).

                        DELETE PROCEDURE h-b1wgen0015.

                        IF  RETURN-VALUE <> "OK"  THEN
                            UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.
            END.
         
        /** Atualiza situacao do agendamento para cancelado **/    
        ASSIGN aux_insitlau     = craplau.insitlau
			   craplau.insitlau = 3
               craplau.dtdebito = craplau.dtmvtopg. 

        ASSIGN aux_flgtrans = TRUE.    
    
    END. /** Fim do DO TRANSACTION - TRANSACAO **/

    IF  NOT aux_flgtrans  THEN
        DO:
            IF  par_dscritic = ""  THEN
                ASSIGN par_dscritic = "Nao foi possivel cancelar o " +
                                      "agendamento.".
            
            RETURN "NOK".
        END.

    IF craplau.idtitdda > 0  THEN
        DO:  
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

            /* Efetuar a chamada a rotina Oracle */ 
            RUN STORED-PROCEDURE pc_atualz_situac_titulo_sacado
              aux_handproc = PROC-HANDLE NO-ERROR ( INPUT par_cdcooper         /* Codigo da Cooperativa */
                                                   ,INPUT par_cdagenci         /* Codigo da Agencia */
                                                   ,INPUT 900                  /* Numero do Caixa */
                                                   ,INPUT "996"                /* Codigo Operador Caixa */
                                                   ,INPUT "INTERNETBANK"       /* Nome da tela */
                                                   ,INPUT 3 /* Internet */     /* Indicador Origem */
                                                   ,INPUT par_nrdconta         /* Numero da Conta */
                                                   ,INPUT par_idseqttl         /* Sequencial do titular */
                                                   ,INPUT STRING(craplau.idtitdda)     ~ /* Indicador Titulo DDA */
                                                   ,INPUT 1  /* em aberto */   /* Situacao Titulo */
                                                   ,INPUT 0                    /* Gerar Log(1-Sim 0-Nao) */
                                                   ,INPUT par_dtmvtolt          /* data de movimento */
                                                   ,INPUT craplau.dscodbar      /* Codigo de barra  */
                                                   ,INPUT craplau.cdctrlcs      /* Identificador da consulta  */
                                                   ,OUTPUT 0                    /* Codigo da critica  */
                                                   ,OUTPUT "" ).                /* Descriçao da critica  */

            /* Fechar o procedimento para buscarmos o resultado */ 
            CLOSE STORED-PROC pc_atualz_situac_titulo_sacado
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
              
            /* Busca possíveis erros */ 
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = ""
                     aux_cdcritic = pc_atualz_situac_titulo_sacado.pr_cdcritic 
                                    WHEN pc_atualz_situac_titulo_sacado.pr_cdcritic <> ?
                     aux_dscritic = pc_atualz_situac_titulo_sacado.pr_dscritic 
                                    WHEN pc_atualz_situac_titulo_sacado.pr_dscritic <> ?.
                                    
                                    
              IF aux_cdcritic <> 0 OR
                 aux_dscritic <> "" THEN
                DO:
                    ASSIGN par_dscritic = aux_dscritic.                          
                    RETURN "NOK".            
                END.                   
        END.
   
	/* Se for agendamento de TED*/
    IF craplau.cdtiptra = 4 OR craplau.cdtiptra = 22 THEN /*REQ39*/
       DO:
	      RUN proc_gerar_log (INPUT par_cdcooper,
                              INPUT par_cdoperad,
                              INPUT "Agendamento de TED cancelado com sucesso.",
                              INPUT par_dsorigem,
                              INPUT par_dstransa,
                              INPUT 1, /*Efetuado com sucesso*/
                              INPUT par_idseqttl,
                              INPUT par_nmdatela,
                              INPUT par_nrdconta,
                              OUTPUT aux_nrdrowid).
								   
		  RUN proc_gerar_log_item (INPUT aux_nrdrowid,
							       INPUT "insitlau",
							       INPUT aux_insitlau,
							       INPUT STRING(craplau.insitlau)).            

	   END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE estorna_convenio:

    DEF INPUT  PARAM par_cdcooper         AS INTE                    NO-UNDO.
    DEF INPUT  PARAM par_nrdconta         LIKE crapttl.nrdconta      NO-UNDO.
    DEF INPUT  PARAM par_idseqttl         LIKE crapttl.idseqttl      NO-UNDO.
    DEF INPUT  PARAM par_cdbarras         AS CHAR                    NO-UNDO.
    DEF INPUT  PARAM par_dscedent         AS CHAR                    NO-UNDO.
    DEF INPUT  PARAM par_cdseqfat         AS DECI                    NO-UNDO.
    DEF INPUT  PARAM par_vlfatura         AS DECI                    NO-UNDO.
    DEF INPUT  PARAM par_cdoperad         LIKE crapope.cdoperad      NO-UNDO.
    DEF INPUT  PARAM par_idorigem         AS INT                     NO-UNDO.
    DEF OUTPUT PARAM par_dstransa         AS CHAR                    NO-UNDO.
    DEF OUTPUT PARAM par_dscritic         LIKE crapcri.dscritic      NO-UNDO.
    DEF OUTPUT PARAM par_dsprotoc         LIKE crappro.dsprotoc      NO-UNDO.

    DEF VAR aux_dscritic                  AS CHAR                     NO-UNDO.

    DO  TRANSACTION ON ERROR UNDO, RETURN "NOK":
	  
      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

      /* Efetuar a chamada a rotina Oracle */ 
      RUN STORED-PROCEDURE pc_estorna_convenio
        aux_handproc = PROC-HANDLE NO-ERROR ( INPUT par_cdcooper  /* pr_cdcooper  --> Codigo da cooperativa */
                                             ,INPUT par_nrdconta  /* pr_nrdconta  --> Numero da conta */
                                             ,INPUT par_idseqttl  /* pr_idseqttl  --> Sequencial titular */
                                             ,INPUT par_cdbarras  /* pr_cdbarras  --> Codigo de barras */
                                             ,INPUT par_dscedent  /* pr_dscedent  --> Cedente */
                                             ,INPUT STRING(par_cdseqfat)  /* pr_cdseqfat  --> sequencial da fatura */
                                             ,INPUT par_vlfatura  /* pr_vlfatura  --> Valor da fatura */
                                             ,INPUT par_cdoperad  /* pr_cdoperad  --> Codigo do operador */
                                             ,INPUT par_idorigem  /* pr_idorigem  --> Id de origem da operaçao */
                                             ,OUTPUT ""           /* pr_dstransa  --> Retorna Descriçao da transaçao */
                                             ,OUTPUT ""           /* pr_dscritic  --> Retorna critica */
                                             ,OUTPUT ""   ).         /* pr_dsprot~ oc  --> Retorna protocolo */

      /* Fechar o procedimento para buscarmos o resultado */ 
      CLOSE STORED-PROC pc_estorna_convenio
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
        
      /* Busca possíveis erros */ 
      ASSIGN aux_dscritic = ""
             aux_dscritic = pc_estorna_convenio.pr_dscritic 
                            WHEN pc_estorna_convenio.pr_dscritic <> ?.
                              
                              
      IF aux_dscritic <> "" THEN
        DO:
            ASSIGN par_dscritic = aux_dscritic.                          
            UNDO, RETURN "NOK".
        END.                   

      /* Busca possíveis erros */ 
      ASSIGN par_dstransa = ""
             par_dsprotoc = ""
             par_dstransa = pc_estorna_convenio.pr_dstransa 
                            WHEN pc_estorna_convenio.pr_dstransa <> ?
             par_dsprotoc = pc_estorna_convenio.pr_dsprotoc 
                            WHEN pc_estorna_convenio.pr_dsprotoc <> ?.

      
    	   
      END. /* fim DO TRANSACTION */
    
    RETURN "OK".

END PROCEDURE.


PROCEDURE estorna_titulo:

    DEF INPUT  PARAM par_cdcooper         AS INTE                    NO-UNDO.
    DEF INPUT  PARAM par_cdagenci         LIKE crapage.cdagenci      NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt         LIKE crapdat.dtmvtolt      NO-UNDO.
    DEF INPUT  PARAM par_nrdconta         LIKE crapttl.nrdconta      NO-UNDO.
    DEF INPUT  PARAM par_idseqttl         LIKE crapttl.idseqttl      NO-UNDO.
    DEF INPUT  PARAM par_cdbarras         AS CHAR                    NO-UNDO.
    DEF INPUT  PARAM par_dscedent         AS CHAR                    NO-UNDO.
    DEF INPUT  PARAM par_vlfatura         AS DECI                    NO-UNDO.
    DEF INPUT  PARAM par_cdoperad         LIKE crapope.cdoperad      NO-UNDO.
    DEF INPUT  PARAM par_idorigem         AS INT                     NO-UNDO.
    DEF INPUT  PARAM par_cdctrbxo         AS CHAR                    NO-UNDO.
    DEF INPUT  PARAM par_nrdident         LIKE craptit.nrdident      NO-UNDO.
    
    DEF OUTPUT PARAM par_dstransa         AS CHAR                    NO-UNDO.
    DEF OUTPUT PARAM par_dscritic         LIKE crapcri.dscritic      NO-UNDO.
    DEF OUTPUT PARAM par_dsprotoc         LIKE crappro.dsprotoc      NO-UNDO.

    DEF VAR aux_dscritic                  AS CHAR                    NO-UNDO.
    
    DO  TRANSACTION ON ERROR UNDO, RETURN "NOK":
	  
      { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

      /* Efetuar a chamada a rotina Oracle */ 
      RUN STORED-PROCEDURE pc_estorna_titulo
        aux_handproc = PROC-HANDLE NO-ERROR ( INPUT par_cdcooper /* pr_cdcooper --> Codigo da cooperativa */
                                             ,INPUT par_cdagenci /* pr_cdagenci --> Codigo da agencia */
                                             ,INPUT par_dtmvtolt /* pr_dtmvtolt --> Data de movimento */
                                             ,INPUT par_nrdconta /* pr_nrdconta --> Numero da conta */
                                             ,INPUT par_idseqttl /* pr_idseqttl --> Sequencial titular */
                                             ,INPUT par_cdbarras /* pr_cdbarras --> Codigo de barras */
                                             ,INPUT par_dscedent /* pr_dscedent --> Cedente */
                                             ,INPUT par_vlfatura /* pr_vlfatura --> Valor da fatura */
                                             ,INPUT par_cdoperad /* pr_cdoperad --> Codigo do operador */
                                             ,INPUT par_idorigem /* pr_idorigem --> Id de origem da operaçao */
                                             ,INPUT par_cdctrbxo /* pr_cdctrbxo --> Codigo de controle de baixa */
                                             ,INPUT STRING(par_nrdident) /* pr_nrdident --> Identificador do titulo NPC */
                                             
                                             ,OUTPUT ""           /* pr_dstransa  --> Retorna Descriçao da transaçao */
                                             ,OUTPUT ""           /* pr_dscritic  --> Retorna critica */
                                             ,OUTPUT ""   ).      /* pr_dsprotoc  --> Retorna protocolo */

      /* Fechar o procedimento para buscarmos o resultado */ 
      CLOSE STORED-PROC pc_estorna_titulo
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

      { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
        
      /* Busca possíveis erros */ 
      ASSIGN aux_dscritic = ""
             aux_dscritic = pc_estorna_titulo.pr_dscritic 
                            WHEN pc_estorna_titulo.pr_dscritic <> ?.
                              
                              
      IF aux_dscritic <> "" THEN
        DO:
            ASSIGN par_dscritic = aux_dscritic.                          
            UNDO, RETURN "NOK".
        END.                   

      /* Busca possíveis erros */ 
      ASSIGN par_dstransa = ""
             par_dsprotoc = ""
             par_dstransa = pc_estorna_titulo.pr_dstransa 
                            WHEN pc_estorna_titulo.pr_dstransa <> ?
             par_dsprotoc = pc_estorna_titulo.pr_dsprotoc 
                            WHEN pc_estorna_titulo.pr_dsprotoc <> ?.
    	   
      END. /* fim DO TRANSACTION */
    
    RETURN "OK".

END PROCEDURE.


/*............................ PROCEDURES INTERNAS ...........................*/

PROCEDURE verifica-dias-tolerancia-sicredi:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtagenda AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdbarras AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    
    DEF VAR          aux_dttolera AS DATE                           NO-UNDO.
    DEF VAR          aux_contador AS INTE                           NO-UNDO.

    /* Procura cod. da empresa do convenio SICREDI em cada campo de Num. do Cod. Barras */
    FIND FIRST crapscn WHERE crapscn.cdempcon  = INTE(SUBSTR(par_cdbarras,16,4)) AND
                      STRING(crapscn.cdsegmto) = SUBSTR(par_cdbarras,2 ,1)
                                                 NO-LOCK NO-ERROR NO-WAIT.

    IF  NOT AVAIL crapscn THEN
        DO:
            FIND FIRST crapscn WHERE crapscn.cdempco2  = INTE(SUBSTR(par_cdbarras,16,4)) AND
                              STRING(crapscn.cdsegmto) = SUBSTR(par_cdbarras,2 ,1)
                                                         NO-LOCK NO-ERROR NO-WAIT.
            IF  NOT AVAIL crapscn THEN
                DO:
                    FIND FIRST crapscn WHERE crapscn.cdempco3  = INTE(SUBSTR(par_cdbarras,16,4)) AND
                                      STRING(crapscn.cdsegmto) = SUBSTR(par_cdbarras,2 ,1)
                                                                 NO-LOCK NO-ERROR NO-WAIT.
                    IF  NOT AVAIL crapscn THEN
                        DO:
                            FIND FIRST crapscn WHERE crapscn.cdempco4  = INTE(SUBSTR(par_cdbarras,16,4)) AND
                                              STRING(crapscn.cdsegmto) = SUBSTR(par_cdbarras,2 ,1)
                                                                         NO-LOCK NO-ERROR NO-WAIT.
                            IF  NOT AVAIL crapscn THEN
                                DO:
                                    FIND FIRST crapscn WHERE crapscn.cdempco5  = INTE(SUBSTR(par_cdbarras,16,4)) AND
                                                      STRING(crapscn.cdsegmto) = SUBSTR(par_cdbarras,2 ,1)
                                                                                 NO-LOCK NO-ERROR NO-WAIT.
                                    IF  NOT AVAIL crapscn THEN
                                        DO:
                                            ASSIGN par_dscritic = "Documento nao aceito. Procure seu Posto de Atendimento para maiores informacoes.".
                                            RETURN "NOK".
                                        END.
                                END.
                        END.
                END.
        END.

    /* Validaçao referente aos dias de tolerancia */
    IF (crapscn.nrtolera <> 99) THEN /* Se nao for tolerancia ilimitada */
        DO:
            DATE(STRING(SUBSTR(par_cdbarras,26,2),"99"  )  + "/" +
                 STRING(SUBSTR(par_cdbarras,24,2),"99"  )  + "/" +
                 STRING(SUBSTR(par_cdbarras,20,4),"9999")) NO-ERROR.
           
            IF  NOT ERROR-STATUS:ERROR THEN /* Verifica se nao houve erro na conversao para data */
                DO:
                    /* Calcula Limite da Data de Tolerancia dependendo se forem dias Úteis ou Corridos */
                    ASSIGN aux_dttolera = DATE(STRING(SUBSTR(par_cdbarras,26,2),"99"  )  + "/" +
                                               STRING(SUBSTR(par_cdbarras,24,2),"99"  )  + "/" +
                                               STRING(SUBSTR(par_cdbarras,20,4),"9999"))
                           aux_contador = 1.

                    IF  crapscn.dsdiatol = "U" THEN /* Dias úteis */
                        DO:
                            DO WHILE TRUE:
               
                                ASSIGN aux_dttolera = aux_dttolera + 1.
               
                                IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dttolera)))              OR
                                     CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper   AND
                                                            crapfer.dtferiad = aux_dttolera)  THEN
                                     NEXT.
               
                                IF  aux_contador = crapscn.nrtolera THEN
                                    LEAVE.
               
                                ASSIGN aux_contador = aux_contador + 1.
               
                            END.
                        END.
                    ELSE  /* Dias corridos */
                        DO:
                            ASSIGN aux_dttolera = aux_dttolera + crapscn.nrtolera.
               
                            DO WHILE TRUE:
               
                                IF   NOT CAN-DO("1,7",STRING(WEEKDAY(aux_dttolera))) AND
                                     NOT CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper   AND
                                                                crapfer.dtferiad = aux_dttolera)  THEN
                                     LEAVE.
                            
                                ASSIGN aux_dttolera = aux_dttolera + 1.
                            
                            END.
                        END.

                    IF  par_dtagenda > aux_dttolera THEN
                        DO:
                            ASSIGN par_dscritic = "Nao e possivel efetuar agendamento apos o vencimento da fatura.".
                            RETURN "NOK".
                        END.
                END.
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE parametros-cancelamento:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_hrfimcan AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dssgproc AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    
    TRANS_TAB:
    DO TRANSACTION ON ENDKEY UNDO TRANS_TAB, LEAVE TRANS_TAB
                   ON ERROR  UNDO TRANS_TAB, LEAVE TRANS_TAB
                   ON STOP   UNDO TRANS_TAB, LEAVE TRANS_TAB:

    /** Verifica horario limite para pagamentos via internet **/
    DO aux_contador = 1 TO 10:
    
        FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                           craptab.nmsistem = "CRED"       AND
                           craptab.tptabela = "GENERI"     AND
                           craptab.cdempres = 00           AND
                           craptab.cdacesso = "HRTRTITULO" AND
                           craptab.tpregist = par_cdagenci
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAILABLE craptab  THEN
            DO:
                IF  LOCKED craptab  THEN
                    DO:
                        ASSIGN par_dscritic = "Tabela HRTRTITULO sendo " +
                                              "alterada. Tente novamente.".
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    ASSIGN par_dscritic = "Tabela HRTRTITULO nao " +
                                          "cadastrada.".
            END.
        ELSE
            ASSIGN par_dscritic = "".
            
        LEAVE.
            
    END. /** Fim do DO ... TO **/
                
    END.

    IF  par_dscritic <> ""  THEN
        RETURN "NOK".
                
    /** Indica se deve rodar segundo processo para debitos de agendamentos **/
    ASSIGN par_dssgproc = SUBSTR(craptab.dstextab,15,3).
    
    /** Horario limite para cancelamento no dia do agendamento **/
    IF  CAN-DO("1,7",STRING(WEEKDAY(par_dtmvtolt)))              OR
        CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper   AND
                               crapfer.dtferiad = par_dtmvtolt)  THEN
        ASSIGN par_hrfimcan = 86400. /** 00:00 horas **/
    ELSE
        ASSIGN par_hrfimcan = INTE(SUBSTR(craptab.dstextab,3,5)).

    RETURN "OK".
    
END PROCEDURE.

PROCEDURE consultar_parmon:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdcoptel AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-parmon.
    DEF OUTPUT PARAM TABLE FOR tt-crapcop.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-parmon.
    EMPTY TEMP-TABLE tt-crapcop.
    EMPTY TEMP-TABLE tt-erro.

    DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.

    DEF VAR h-b1wgen0119 AS HANDLE                                  NO-UNDO.
    
    FIND crapope WHERE crapope.cdcooper = par_cdcooper  AND
                       crapope.cdoperad = par_cdoperad
                       NO-LOCK NO-ERROR.
        
    IF  NOT AVAIL crapope THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Nao foi possivel " +
                                  "encontrar o operador.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,  /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

     IF   crapope.cddepart <> 20   AND   /* TI */
          crapope.cddepart <> 15  THEN   /* SEGURANCA */
          DO:
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = "Acesso nao autorizado.".

              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,            /** Sequencia **/
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).
              RETURN "NOK".
          END.

    FIND crapcop WHERE crapcop.cdcooper = INTEGER(par_cdcoptel) 
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapcop THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Cooperativa nao encontrada".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_cdoperad,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".

        END.
   
    CREATE tt-parmon.
    ASSIGN tt-parmon.vlinimon = crapcop.vlinimon
           tt-parmon.vllmonip = crapcop.vllmonip    
           tt-parmon.vlinisaq = crapcop.vlinisaq 
           tt-parmon.vlinitrf = crapcop.vlinitrf
           tt-parmon.vlsaqind = crapcop.vlsaqind
           tt-parmon.insaqlim = crapcop.insaqlim
           tt-parmon.inaleblq = crapcop.inaleblq    
           tt-parmon.vlmnlmtd = crapcop.vlmnlmtd
           tt-parmon.vlinited = crapcop.vlinited
           tt-parmon.flmstted = crapcop.flmstted
           tt-parmon.flnvfted = crapcop.flnvfted
           tt-parmon.flmobted = crapcop.flmobted
           tt-parmon.dsestted = crapcop.dsestted
           tt-parmon.flmntage = crapcop.flmntage.
 
    IF  par_cdcooper = 3 THEN
        DO:
            IF  NOT VALID-HANDLE(h-b1wgen0119) THEN
                RUN sistema/generico/procedures/b1wgen0119.p 
                PERSISTENT SET h-b1wgen0119.
                                     
            RUN busca_cooperativas IN h-b1wgen0119(INPUT par_cdcooper,
                                                  OUTPUT TABLE tt-crapcop,
                                                  OUTPUT TABLE tt-erro).
            IF RETURN-VALUE <> "OK" THEN
                RETURN "NOK".        
        END.                                  

    RETURN "OK".
    
END PROCEDURE.



PROCEDURE alterar_parmon:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vlinimon AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vllmonip AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlinisaq AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlinitrf AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlsaqind AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_insaqlim AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inaleblq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdcoptel AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vlmnlmtd AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlinited AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flmstted AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flnvfted AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flmobted AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dsestted AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flmntage AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.    
    DEF VAR aux_vliniant AS DECI                                    NO-UNDO.
    DEF VAR aux_vldipant AS DECI                                    NO-UNDO.    
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_allcoope AS LOGICAL                                 NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
    
    FIND crapope WHERE crapope.cdcooper = par_cdcooper  AND
                       crapope.cdoperad = par_cdoperad
                       NO-LOCK NO-ERROR.
        
    IF  NOT AVAIL crapope THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Nao foi possivel " +
                                  "encontrar o operador.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,  /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

     IF   crapope.cddepart <> 20  AND   /* TI        */
          crapope.cddepart <> 15 THEN   /* SEGURANCA */
          DO:
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = "Acesso nao autorizado.".

              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,            /** Sequencia **/
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).
              RETURN "NOK".
          END.

    DO  aux_contador = 1 TO NUM-ENTRIES(par_cdcoptel,"|"):
        IF  INTEGER(ENTRY(aux_contador,par_cdcoptel,"|")) = 0 THEN
        DO:    
            ASSIGN aux_allcoope = TRUE.
            LEAVE.
        END.
    END.

        IF  aux_allcoope THEN
            DO:
            DO WHILE TRUE:
                        
                FOR EACH crapcop WHERE crapcop.flgativo = TRUE EXCLUSIVE-LOCK:
                    
                    RUN log-tela-parmon(INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_cdoperad,
                                        INPUT crapcop.nmrescop,
                                        INPUT crapcop.vlinimon,
                                        INPUT par_vlinimon,
                                        INPUT crapcop.vllmonip,
                                        INPUT par_vllmonip,
                                        INPUT crapcop.vlinisaq,
                                        INPUT par_vlinisaq,
                                        INPUT crapcop.vlinitrf,
                                        INPUT par_vlinitrf,
                                        INPUT crapcop.vlsaqind,
                                        INPUT par_vlsaqind,
                                        INPUT crapcop.insaqlim,
                                        INPUT par_insaqlim,
                                        INPUT crapcop.inaleblq,
                                        INPUT par_inaleblq,
                                        INPUT crapcop.vlmnlmtd,
                                        INPUT par_vlmnlmtd,
                                        INPUT crapcop.vlinited,
                                        INPUT par_vlinited,
                                        INPUT crapcop.flmstted,
                                        INPUT par_flmstted,
                                        INPUT crapcop.flnvfted,
                                        INPUT par_flnvfted,
                                        INPUT crapcop.flmobted,
                                        INPUT par_flmobted,
                                        INPUT crapcop.dsestted,
                                        INPUT par_dsestted,
                                        INPUT crapcop.flmntage,
                                        INPUT par_flmntage).

                    ASSIGN crapcop.vlinimon = par_vlinimon
                           crapcop.vllmonip = par_vllmonip
                           crapcop.vlinisaq = par_vlinisaq
                           crapcop.vlinitrf = par_vlinitrf
                           crapcop.vlsaqind = par_vlsaqind
                           crapcop.insaqlim = par_insaqlim
                           crapcop.inaleblq = par_inaleblq
                           crapcop.vlmnlmtd = par_vlmnlmtd
                           crapcop.vlinited = par_vlinited
                           crapcop.flmstted = par_flmstted
                           crapcop.flnvfted = par_flnvfted
                           crapcop.flmobted = par_flmobted
                           crapcop.dsestted = par_dsestted
                           crapcop.flmntage = par_flmntage.
                    
                END.
                
                FIND CURRENT crapcop NO-LOCK NO-ERROR.
                
                RELEASE crapcop.
               LEAVE.
    
            END.
    
            END.
        
        ELSE
       TRANS_COP:
       DO TRANSACTION ON ERROR  UNDO TRANS_COP, LEAVE TRANS_COP
                      ON QUIT   UNDO TRANS_COP, LEAVE TRANS_COP
                      ON STOP   UNDO TRANS_COP, LEAVE TRANS_COP
                      ON ENDKEY UNDO TRANS_COP, LEAVE TRANS_COP:

            DO aux_contador = 1 TO NUM-ENTRIES(par_cdcoptel,"|"):

                 FIND crapcop WHERE 
                      crapcop.cdcooper = INTE(ENTRY(aux_contador,par_cdcoptel,"|")) 
                      EXCLUSIVE-LOCK NO-ERROR.
             
                 IF  NOT AVAIL crapcop THEN
                 DO:
                     ASSIGN aux_cdcritic = 0
                            aux_dscritic = "Cooperativa nao encontrada".
             
                 UNDO TRANS_COP, LEAVE TRANS_COP.
                 
                 END.        
             
                 RUN log-tela-parmon(INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_cdoperad,
                                     INPUT crapcop.nmrescop,
                                     INPUT crapcop.vlinimon,
                                     INPUT par_vlinimon,
                                     INPUT crapcop.vllmonip,
                                     INPUT par_vllmonip,
                                     INPUT crapcop.vlinisaq,
                                     INPUT par_vlinisaq,
                                     INPUT crapcop.vlinitrf,
                                     INPUT par_vlinitrf,
                                     INPUT crapcop.vlsaqind,
                                     INPUT par_vlsaqind,
                                     INPUT crapcop.insaqlim,
                                     INPUT par_insaqlim,
                                     INPUT crapcop.inaleblq,
                                     INPUT par_inaleblq,
                                     INPUT crapcop.vlmnlmtd,
                                     INPUT par_vlmnlmtd,
                                     INPUT crapcop.vlinited,
                                     INPUT par_vlinited,
                                     INPUT crapcop.flmstted,
                                     INPUT par_flmstted,
                                     INPUT crapcop.flnvfted,
                                     INPUT par_flnvfted,
                                     INPUT crapcop.flmobted,
                                     INPUT par_flmobted,
                                     INPUT crapcop.dsestted,
                                     INPUT par_dsestted,
                                     INPUT crapcop.flmntage,
                                     INPUT par_flmntage).
                                  
                 ASSIGN crapcop.vlinimon = par_vlinimon
                        crapcop.vllmonip = par_vllmonip
                        crapcop.vlinisaq = par_vlinisaq
                        crapcop.vlinitrf = par_vlinitrf
                        crapcop.vlsaqind = par_vlsaqind
                        crapcop.insaqlim = par_insaqlim
                        crapcop.inaleblq = par_inaleblq
                        crapcop.vlmnlmtd = par_vlmnlmtd
                        crapcop.vlinited = par_vlinited
                        crapcop.flmstted = par_flmstted
                        crapcop.flnvfted = par_flnvfted
                        crapcop.flmobted = par_flmobted
                        crapcop.dsestted = par_dsestted
                        crapcop.flmntage = par_flmntage.
                
                 FIND CURRENT crapcop NO-LOCK NO-ERROR.
                
                 RELEASE crapcop.
      
            END.

    END.

    IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
       DO:
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_cdoperad,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).

          RETURN "NOK".

    END.

    RETURN "OK".
    
END PROCEDURE.


PROCEDURE log-tela-parmon:
   
    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_nmrescop AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_vlinimo1 AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_vlinimo2 AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_vllmoni1 AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_vllmoni2 AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_vlinisa1 AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_vlinisa2 AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_vlinitr1 AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_vlinitr2 AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_vlsaqin1 AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_vlsaqin2 AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_insaqli1 AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_insaqli2 AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_inalebl1 AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_inalebl2 AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_vlmnlmt1 AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_vlmnlmt2 AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_vlinite1 AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_vlinite2 AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_flmstte1 AS LOGI                            NO-UNDO.
    DEF INPUT PARAM par_flmstte2 AS LOGI                            NO-UNDO.
    DEF INPUT PARAM par_flnvfte1 AS LOGI                            NO-UNDO.
    DEF INPUT PARAM par_flnvfte2 AS LOGI                            NO-UNDO.
    DEF INPUT PARAM par_flmobte1 AS LOGI                            NO-UNDO.
    DEF INPUT PARAM par_flmobte2 AS LOGI                            NO-UNDO.
    DEF INPUT PARAM par_dsestte1 AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_dsestte2 AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_flmntag1 AS LOGI                            NO-UNDO.
    DEF INPUT PARAM par_flmntag2 AS LOGI                            NO-UNDO.
                                                               
    DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.

    DEF BUFFER crabcop FOR crapcop.

    FIND crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK.     
    
    IF  NOT AVAIL crabcop THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Cooperativa nao encontrada".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_cdoperad,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                    INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.    

    IF   par_vlinimo1 <> par_vlinimo2   THEN
         RUN gerar_log_parmon (INPUT par_cdoperad,
                               INPUT par_nmrescop,
                               INPUT "Valor Inicial Monitoracao:",
                               INPUT STRING(par_vlinimo1,"zzz,zzz,zz9.99"),
                               INPUT STRING(par_vlinimo2,"zzz,zzz,zz9.99"),
                               INPUT crabcop.dsdircop).

    IF   par_vllmoni1 <> par_vllmoni2   THEN
         RUN gerar_log_parmon (INPUT par_cdoperad,
                               INPUT par_nmrescop,
                               INPUT "Valor Limite Monitoracao IP:",
                               INPUT STRING(par_vllmoni1,"zzz,zzz,zz9.99"),
                               INPUT STRING(par_vllmoni2,"zzz,zzz,zz9.99"),
                               INPUT crabcop.dsdircop).   

    IF   par_vlinisa1 <> par_vlinisa2   THEN
         RUN gerar_log_parmon (INPUT par_cdoperad,
                               INPUT par_nmrescop,
                               INPUT "Valor inicial do saque (Saque + Transferencia):",
                               INPUT STRING(par_vlinisa1,"zzz,zzz,zz9.99"),
                               INPUT STRING(par_vlinisa2,"zzz,zzz,zz9.99"),
                               INPUT crabcop.dsdircop).  

    IF   par_vlinitr1 <> par_vlinitr2   THEN
         RUN gerar_log_parmon (INPUT par_cdoperad,
                               INPUT par_nmrescop,
                               INPUT "Valor inicial da transferencia:",
                               INPUT STRING(par_vlinitr1,"zzz,zzz,zz9.99"),
                               INPUT STRING(par_vlinitr2,"zzz,zzz,zz9.99"),
                               INPUT crabcop.dsdircop). 

    IF   par_vlsaqin1 <> par_vlsaqin2   THEN
         RUN gerar_log_parmon (INPUT par_cdoperad,
                               INPUT par_nmrescop,
                               INPUT "Valor inicial do saque (Individual):",
                               INPUT STRING(par_vlsaqin1,"zzz,zzz,zz9.99"),
                               INPUT STRING(par_vlsaqin2,"zzz,zzz,zz9.99"),
                               INPUT crabcop.dsdircop).  

    IF   par_insaqli1 <> par_insaqli2   THEN
         RUN gerar_log_parmon (INPUT par_cdoperad,
                               INPUT par_nmrescop,
                               INPUT "Saque deve ser o limite da conta:",
                               INPUT STRING(LOGICAL(par_insaqli1),"Sim/Nao"),
                               INPUT STRING(LOGICAL(par_insaqli2),"Sim/Nao"),
                               INPUT crabcop.dsdircop). 

    IF   par_inalebl1 <> par_inalebl2   THEN
         RUN gerar_log_parmon (INPUT par_cdoperad,
                               INPUT par_nmrescop,
                               INPUT "Alertar cartao bloqueado:",
                               INPUT STRING(LOGICAL(par_inalebl1),"Sim/Nao"),
                               INPUT STRING(LOGICAL(par_inalebl2),"Sim/Nao"),
                               INPUT crabcop.dsdircop). 

    IF   par_vlmnlmt1 <> par_vlmnlmt2   THEN
         RUN gerar_log_parmon (INPUT par_cdoperad,
                               INPUT par_nmrescop,
                               INPUT "Limite TED superior a:",
                               INPUT STRING(par_vlmnlmt1,"zzz,zzz,zz9.99"),
                               INPUT STRING(par_vlmnlmt2,"zzz,zzz,zz9.99"),
                               INPUT crabcop.dsdircop).

    IF   par_vlinite1 <> par_vlinite2   THEN
         RUN gerar_log_parmon (INPUT par_cdoperad,
                               INPUT par_nmrescop,
                               INPUT "Valor minimo de TED:",
                               INPUT STRING(par_vlinite1,"zzz,zzz,zz9.99"),
                               INPUT STRING(par_vlinite2,"zzz,zzz,zz9.99"),
                               INPUT crabcop.dsdircop).

    IF   par_flmstte1 <> par_flmstte2   THEN
         RUN gerar_log_parmon (INPUT par_cdoperad,
                               INPUT par_nmrescop,
                               INPUT "Saque deve ser o limite da conta:",
                               INPUT STRING(LOGICAL(par_flmstte1),"Sim/Nao"),
                               INPUT STRING(LOGICAL(par_flmstte2),"Sim/Nao"),
                               INPUT crabcop.dsdircop).

    IF   par_flnvfte1 <> par_flnvfte2   THEN
         RUN gerar_log_parmon (INPUT par_cdoperad,
                               INPUT par_nmrescop,
                               INPUT "Monitorar somente novos favorecidos:",
                               INPUT STRING(LOGICAL(par_flnvfte1),"Sim/Nao"),
                               INPUT STRING(LOGICAL(par_flnvfte2),"Sim/Nao"),
                               INPUT crabcop.dsdircop).

    IF   par_flmobte1 <> par_flmobte2   THEN
         RUN gerar_log_parmon (INPUT par_cdoperad,
                               INPUT par_nmrescop,
                               INPUT "Monitoramento Mobile:",
                               INPUT STRING(LOGICAL(par_flmobte1),"Sim/Nao"),
                               INPUT STRING(LOGICAL(par_flmobte2),"Sim/Nao"),
                               INPUT crabcop.dsdircop).

    IF   par_dsestte1 <> par_dsestte2   THEN
         RUN gerar_log_parmon (INPUT par_cdoperad,
                               INPUT par_nmrescop,
                               INPUT "UFs monitoradas:",
                               INPUT par_dsestte1,
                               INPUT par_dsestte2,
                               INPUT crabcop.dsdircop).

    IF   par_flmntag1 <> par_flmntag2   THEN
         RUN gerar_log_parmon (INPUT par_cdoperad,
                               INPUT par_nmrescop,
                               INPUT "Monitoramento de agendamento de TED:",
                               INPUT STRING(LOGICAL(par_flmntag1),"Sim/Nao"),
                               INPUT STRING(LOGICAL(par_flmntag2),"Sim/Nao"),
                               INPUT crabcop.dsdircop).

    RETURN "OK".
                         
END PROCEDURE.

PROCEDURE gerar_log_parmon:

    DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_nmrescop AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_dsdcampo AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_vldantes AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_vldepois AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_dsdircop AS CHAR                            NO-UNDO.

    UNIX SILENT VALUE("echo '" + STRING(TODAY,"99/99/9999")       +
                       " " + STRING(TIME,"HH:MM:SS") + " --> "    +
                       " - Operador: "  + par_cdoperad            +
                       " da Cooperativa: " + par_nmrescop         +
                       " - Tela: PARMON"                          +
                       " - Ambiente: WEB"                         +
                       " alterou o campo "   + par_dsdcampo       +
                       " de "   + TRIM(par_vldantes)              +                  
                       " para " + TRIM(par_vldepois)              +                 
                       ".' >> /usr/coop/" + par_dsdircop          + 
                       "/log/parmon.log").

    RETURN "OK".

END PROCEDURE.

/* Gerar log referente as criticas de teds */
PROCEDURE gera_arquivo_log_ted:

    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nmrotina AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_nomedabo AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS DECI                               NO-UNDO.
    DEF INPUT PARAM par_nrcpfope AS DECI                               NO-UNDO.
    DEF INPUT PARAM par_cddbanco AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdageban AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrctadst AS DECI                               NO-UNDO.
    DEF INPUT PARAM par_nmtitula AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_nrcpfcgc AS DECI                               NO-UNDO.
    DEF INPUT PARAM par_inpessoa AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_intipcta AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_vllantra AS DECI                               NO-UNDO.
    DEF INPUT PARAM par_dstransf AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_cdfinali AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrispbif AS DECI                               NO-UNDO.    
    DEF INPUT PARAM par_dscritic AS CHAR                               NO-UNDO.                                  

    DEF VAR aux_nmarquiv AS CHAR                                       NO-UNDO.

    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper
                             NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapcop THEN
        RETURN "NOK".

    ASSIGN aux_nmarquiv = "/usr/coop/" + STRING(crapcop.dsdircop) + "/log/" +
                          "criticas_ted.log".

    UNIX SILENT VALUE ("echo " + '"' + STRING(TODAY,"99/99/9999") + " - " +
           STRING(TIME,"HH:MM:SS") + " - " + STRING(par_nmrotina) + "  "  + 
           STRING(par_nomedabo) + " --> " + " dscritic: " + STRING(par_dscritic) +
           ", dtmvtolt: " + STRING(par_dtmvtolt,"99/99/9999")     +
           ", vllantra: " + STRING(par_vllantra,"zzz,zzz,zz9.99") +
           ", nrdconta: " + STRING(par_nrdconta,"zzzzzz,zz9,9")   +
           ", nrcpfope: " + STRING(par_nrcpfope)                  +
           ", cddbanco: " + STRING(par_cddbanco,"zzzz9")          +
           ", cdageban: " + STRING(par_cdageban,"zzzzz9")         +
           ", nrctadst: " + STRING(par_nrctadst,"zzzzzzzzzzzzzzzz,zz9,9") +
           ", nmtitula: " + STRING(par_nmtitula)                  +
           ", nrcpfcgc: " + STRING(par_nrcpfcgc)                  +
           ", inpessoa: " + STRING(par_inpessoa)                  +
           ", intipcta: " + STRING(par_intipcta)                  +
           ", dstransf: " + STRING(par_dstransf)                  +
           ", cdfinali: " + STRING(par_cdfinali)                  +
           ", nrispbif: " + STRING(par_nrispbif)                  +
           '"' + " >> " + aux_nmarquiv). 

   RETURN "OK".

END PROCEDURE.

/*............................................................................*/
PROCEDURE busca_darf_das:
  DEF  INPUT PARAMETER par_cdcooper AS INTE    NO-UNDO.
  DEF  INPUT PARAMETER par_cdoperad AS CHAR    NO-UNDO.
  DEF  INPUT PARAMETER par_nmdatela AS CHAR    NO-UNDO.
  DEF  INPUT PARAMETER par_nrdconta AS INTEGER NO-UNDO.  
  DEF  INPUT PARAMETER par_cdtrapen AS CHAR    NO-UNDO.
  DEF OUTPUT PARAMETER par_qtdregis AS INTEGER NO-UNDO.
  DEF OUTPUT PARAMETER par_cdcritic AS INTEGER NO-UNDO.
  DEF OUTPUT PARAMETER par_dscritic AS CHAR    NO-UNDO.
        
  DEF VAR aux_cdcritic AS INTE          NO-UNDO.
  DEF VAR aux_dscritic AS CHAR          NO-UNDO.
    
  /* Variaveis para o XML */ 
  DEF VAR xDoc          AS HANDLE   NO-UNDO.   
  DEF VAR xRoot         AS HANDLE   NO-UNDO.  
  DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
  DEF VAR xField        AS HANDLE   NO-UNDO. 
  DEF VAR xText         AS HANDLE   NO-UNDO. 
  DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
  DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
  DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
  DEF VAR xml_req       AS LONGCHAR NO-UNDO.

  /* Inicializando objetos para leitura do XML */ 
  CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
  CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
  CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
  CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
  CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
                  
  { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} } 

  /* Efetuar a chamada a rotina Oracle */ 
  RUN STORED-PROCEDURE pc_busca_darf_das_car
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Código da Cooperativa */
                                         INPUT par_cdoperad, /* Código do Operador */
                                         INPUT par_nmdatela, /* Nome da Tela */
                                         INPUT 1,            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                         INPUT par_nrdconta, /* Número da Conta */
                                         INPUT 1,            /* Titular da Conta */
                                         INPUT par_cdtrapen, /* Codigo da Transacao */
                                        OUTPUT ?,            /* XML com informaçoes de LOG */
                                        OUTPUT 0,            /* Código da crítica */
                                        OUTPUT "").          /* Descriçao da crítica */

  /* Fechar o procedimento para buscarmos o resultado */ 
  CLOSE STORED-PROC pc_busca_darf_das_car
    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

  { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} } 
    
  /* Busca possíveis erros */ 
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_busca_darf_das_car.pr_cdcritic 
                          WHEN pc_busca_darf_das_car.pr_cdcritic <> ?
           aux_dscritic = pc_busca_darf_das_car.pr_dscritic 
                          WHEN pc_busca_darf_das_car.pr_dscritic <> ?.

    IF aux_cdcritic <> 0 OR
       aux_dscritic <> "" THEN
        DO:
          ASSIGN par_cdcritic = aux_cdcritic
                 par_dscritic = aux_dscritic.
                
          RETURN "NOK".            
        END.

    EMPTY TEMP-TABLE tt-tbpagto_darf_das_trans_pend.
    
    /*Leitura do XML de retorno da proc e criacao dos registros na tt-saldo-rdca
    para visualizacao dos registros na tela */
    
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_busca_darf_das_car.pr_clobxmlc. 
    
    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 
       
    IF ponteiro_xml <> ? THEN
      DO:
        xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
        xDoc:GET-DOCUMENT-ELEMENT(xRoot).
        
        DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
        
          xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
        
          IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
            NEXT. 
        
          IF xRoot2:NUM-CHILDREN > 0 THEN
            DO:
              CREATE tt-tbpagto_darf_das_trans_pend.
              ASSIGN par_qtdregis = par_qtdregis + 1.
            END.
        
          DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                    
            xRoot2:GET-CHILD(xField,aux_cont).
                
            IF xField:SUBTYPE <> "ELEMENT" THEN 
              NEXT. 
            
            xField:GET-CHILD(xText,1).
            ASSIGN tt-tbpagto_darf_das_trans_pend.cdtransacao_pendente =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "cdtransacao_pendente".
            ASSIGN tt-tbpagto_darf_das_trans_pend.cdcooper             =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "cdcooper".
            ASSIGN tt-tbpagto_darf_das_trans_pend.nrdconta             =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "nrdconta".
            ASSIGN tt-tbpagto_darf_das_trans_pend.tppagamento          =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "tppagamento".
            ASSIGN tt-tbpagto_darf_das_trans_pend.tpcaptura            =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "tpcaptura".
            ASSIGN tt-tbpagto_darf_das_trans_pend.dsidentif_pagto      =      xText:NODE-VALUE  WHEN xField:NAME = "dsidentif_pagto".
            ASSIGN tt-tbpagto_darf_das_trans_pend.dsnome_fone          =      xText:NODE-VALUE  WHEN xField:NAME = "dsnome_fone".
            ASSIGN tt-tbpagto_darf_das_trans_pend.dscod_barras         =      xText:NODE-VALUE  WHEN xField:NAME = "dscod_barras".
            ASSIGN tt-tbpagto_darf_das_trans_pend.dslinha_digitavel    =      xText:NODE-VALUE  WHEN xField:NAME = "dslinha_digitavel".
            ASSIGN tt-tbpagto_darf_das_trans_pend.dtapuracao           = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtapuracao".
            ASSIGN tt-tbpagto_darf_das_trans_pend.nrcpfcgc             =     (xText:NODE-VALUE) WHEN xField:NAME = "nrcpfcgc".
            ASSIGN tt-tbpagto_darf_das_trans_pend.cdtributo            =     (xText:NODE-VALUE) WHEN xField:NAME = "cdtributo".
            ASSIGN tt-tbpagto_darf_das_trans_pend.nrrefere             =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "nrrefere".
            ASSIGN tt-tbpagto_darf_das_trans_pend.vlprincipal          =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "vlprincipal".
            ASSIGN tt-tbpagto_darf_das_trans_pend.vlmulta              =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "vlmulta".
            ASSIGN tt-tbpagto_darf_das_trans_pend.vljuros              =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "vljuros".
            ASSIGN tt-tbpagto_darf_das_trans_pend.vlreceita_bruta      =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "vlreceita_bruta".
            ASSIGN tt-tbpagto_darf_das_trans_pend.vlpercentual         =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "vlpercentual".
            ASSIGN tt-tbpagto_darf_das_trans_pend.dtvencto             = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtvencto".
            ASSIGN tt-tbpagto_darf_das_trans_pend.tpleitura_docto      =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "tpleitura_docto".
            ASSIGN tt-tbpagto_darf_das_trans_pend.vlpagamento          =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "vlpagamento".
            ASSIGN tt-tbpagto_darf_das_trans_pend.dtdebito             = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtdebito".
            ASSIGN tt-tbpagto_darf_das_trans_pend.idagendamento        =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "idagendamento".
            ASSIGN tt-tbpagto_darf_das_trans_pend.idrowid              =      xText:NODE-VALUE  WHEN xField:NAME = "idrowid".    
            
          END.                
        END.
        
        SET-SIZE(ponteiro_xml) = 0. 
      END.
    
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.
    
    RETURN "OK".
    
END PROCEDURE.

/*............................................................................*/
PROCEDURE busca_trans_pend_trib:
  DEF  INPUT PARAMETER par_cdcooper AS INTE    NO-UNDO.
  DEF  INPUT PARAMETER par_cdoperad AS CHAR    NO-UNDO.
  DEF  INPUT PARAMETER par_nmdatela AS CHAR    NO-UNDO.
  DEF  INPUT PARAMETER par_nrdconta AS INTEGER NO-UNDO.  
  DEF  INPUT PARAMETER par_cdtrapen AS CHAR    NO-UNDO.
  DEF OUTPUT PARAMETER par_qtdregis AS INTEGER NO-UNDO.
  DEF OUTPUT PARAMETER par_cdcritic AS INTEGER NO-UNDO.
  DEF OUTPUT PARAMETER par_dscritic AS CHAR    NO-UNDO.
        
  DEF VAR aux_cdcritic AS INTE          NO-UNDO.
  DEF VAR aux_dscritic AS CHAR          NO-UNDO.
    
  /* Variaveis para o XML */ 
  DEF VAR xDoc          AS HANDLE   NO-UNDO.   
  DEF VAR xRoot         AS HANDLE   NO-UNDO.  
  DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
  DEF VAR xField        AS HANDLE   NO-UNDO. 
  DEF VAR xText         AS HANDLE   NO-UNDO. 
  DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
  DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
  DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
  DEF VAR xml_req       AS LONGCHAR NO-UNDO.

  /* Inicializando objetos para leitura do XML */ 
  CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
  CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
  CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
  CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
  CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
                  
  { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} } 

  /* Efetuar a chamada a rotina Oracle */ 
  RUN STORED-PROCEDURE pc_ret_trans_pend_trib_car
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Código da Cooperativa */
                                         INPUT par_cdoperad, /* Código do Operador */
                                         INPUT par_nmdatela, /* Nome da Tela */
                                         INPUT 1,            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                         INPUT par_nrdconta, /* Número da Conta */
                                         INPUT 1,            /* Titular da Conta */
                                         INPUT par_cdtrapen, /* Codigo da Transacao */
                                        OUTPUT ?,            /* XML com informaçoes de LOG */
                                        OUTPUT 0,            /* Código da crítica */
                                        OUTPUT "").          /* Descriçao da crítica */

  /* Fechar o procedimento para buscarmos o resultado */ 
  CLOSE STORED-PROC pc_ret_trans_pend_trib_car
    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

  { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} } 
    
  /* Busca possíveis erros */ 
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_ret_trans_pend_trib_car.pr_cdcritic 
                          WHEN pc_ret_trans_pend_trib_car.pr_cdcritic <> ?
           aux_dscritic = pc_ret_trans_pend_trib_car.pr_dscritic 
                          WHEN pc_ret_trans_pend_trib_car.pr_dscritic <> ?.

    IF aux_cdcritic <> 0 OR
       aux_dscritic <> "" THEN
        DO:
          ASSIGN par_cdcritic = aux_cdcritic
                 par_dscritic = aux_dscritic.
                
          RETURN "NOK".            
        END.

    EMPTY TEMP-TABLE tt-tbpagto_tributos_trans_pend.
    
    /*Leitura do XML de retorno da proc e criacao dos registros na tt-saldo-rdca
    para visualizacao dos registros na tela */
    
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_ret_trans_pend_trib_car.pr_clobxmlc. 
    
    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 
       
    IF ponteiro_xml <> ? THEN
      DO:
        xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
        xDoc:GET-DOCUMENT-ELEMENT(xRoot).
        
        DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
        
          xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
        
          IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
            NEXT. 
        
          IF xRoot2:NUM-CHILDREN > 0 THEN
            DO:
              CREATE tt-tbpagto_tributos_trans_pend.
              ASSIGN par_qtdregis = par_qtdregis + 1.
          END.                
        
          DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                    
            xRoot2:GET-CHILD(xField,aux_cont).
                
            IF xField:SUBTYPE <> "ELEMENT" THEN 
              NEXT. 

            xField:GET-CHILD(xText,1).
            ASSIGN tt-tbpagto_tributos_trans_pend.cdtransacao_pendente =  DEC(xText:NODE-VALUE) WHEN xField:NAME  = "cdtransacao_pendente".
            ASSIGN tt-tbpagto_tributos_trans_pend.cdcooper             =  DEC(xText:NODE-VALUE) WHEN xField:NAME  = "cdcooper".
            ASSIGN tt-tbpagto_tributos_trans_pend.nrdconta             =  DEC(xText:NODE-VALUE) WHEN xField:NAME  = "nrdconta".
            ASSIGN tt-tbpagto_tributos_trans_pend.tppagamento          =  DEC(xText:NODE-VALUE) WHEN xField:NAME  = "tppagamento".
            ASSIGN tt-tbpagto_tributos_trans_pend.dscod_barras         =  TRIM(xText:NODE-VALUE) WHEN xField:NAME = "dscod_barras".
            ASSIGN tt-tbpagto_tributos_trans_pend.dslinha_digitavel    =  TRIM(xText:NODE-VALUE) WHEN xField:NAME = "dslinha_digitavel".
            ASSIGN tt-tbpagto_tributos_trans_pend.nridentificacao      =  TRIM(xText:NODE-VALUE) WHEN xField:NAME = "nridentificacao".
            ASSIGN tt-tbpagto_tributos_trans_pend.cdtributo            =  TRIM(xText:NODE-VALUE) WHEN xField:NAME = "cdtributo".
            ASSIGN tt-tbpagto_tributos_trans_pend.dtvalidade           =  DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtvalidade".
            ASSIGN tt-tbpagto_tributos_trans_pend.dtcompetencia        =  DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtcompetencia".
            ASSIGN tt-tbpagto_tributos_trans_pend.nrseqgrde            =  DEC(xText:NODE-VALUE) WHEN xField:NAME  = "nrseqgrde".
            ASSIGN tt-tbpagto_tributos_trans_pend.nridentificador      =  TRIM(xText:NODE-VALUE) WHEN xField:NAME = "nridentificador".
            ASSIGN tt-tbpagto_tributos_trans_pend.dsidenti_pagto       =  TRIM(xText:NODE-VALUE) WHEN xField:NAME = "dsidenti_pagto".
            ASSIGN tt-tbpagto_tributos_trans_pend.vlpagamento          =  DEC(xText:NODE-VALUE) WHEN xField:NAME  = "vlpagamento".
            ASSIGN tt-tbpagto_tributos_trans_pend.dtdebito             =  DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtdebito".
            ASSIGN tt-tbpagto_tributos_trans_pend.idagendamento        =  INT(xText:NODE-VALUE) WHEN xField:NAME  = "idagendamento".  
            
        END.
        END.
        
        SET-SIZE(ponteiro_xml) = 0. 
      END.
    
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.
    
    RETURN "OK".
    
END PROCEDURE.

/*............................................................................*/
/* Projeto 470 - Marcelo Telles Coelho */
PROCEDURE busca_trans_pend_ctd:
  DEF  INPUT PARAMETER par_cdcooper AS INTE    NO-UNDO.
  DEF  INPUT PARAMETER par_cdoperad AS CHAR    NO-UNDO.
  DEF  INPUT PARAMETER par_nmdatela AS CHAR    NO-UNDO.
  DEF  INPUT PARAMETER par_nrdconta AS INTEGER NO-UNDO.  
  DEF  INPUT PARAMETER par_cdtrapen AS CHAR    NO-UNDO.
  DEF OUTPUT PARAMETER par_qtdregis AS INTEGER NO-UNDO.
  DEF OUTPUT PARAMETER par_cdcritic AS INTEGER NO-UNDO.
  DEF OUTPUT PARAMETER par_dscritic AS CHAR    NO-UNDO.
        
  DEF VAR aux_cdcritic AS INTE          NO-UNDO.
  DEF VAR aux_dscritic AS CHAR          NO-UNDO.
    
  /* Variaveis para o XML */ 
  DEF VAR xDoc          AS HANDLE   NO-UNDO.   
  DEF VAR xRoot         AS HANDLE   NO-UNDO.  
  DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
  DEF VAR xField        AS HANDLE   NO-UNDO. 
  DEF VAR xText         AS HANDLE   NO-UNDO. 
  DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
  DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
  DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
  DEF VAR xml_req       AS LONGCHAR NO-UNDO.

  /* Inicializando objetos para leitura do XML */ 
  CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
  CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
  CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
  CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
  CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
                  
  { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} } 

  /* Efetuar a chamada a rotina Oracle */ 
  RUN STORED-PROCEDURE pc_ret_trans_pend_ctd_car
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Código da Cooperativa */
                                         INPUT par_cdoperad, /* Código do Operador */
                                         INPUT par_nmdatela, /* Nome da Tela */
                                         INPUT 1,            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                         INPUT par_nrdconta, /* Número da Conta */
                                         INPUT 1,            /* Titular da Conta */
                                         INPUT par_cdtrapen, /* Codigo da Transacao */
                                        OUTPUT ?,            /* XML com informaçoes de LOG */
                                        OUTPUT 0,            /* Código da crítica */
                                        OUTPUT "").          /* Descriçao da crítica */

  /* Fechar o procedimento para buscarmos o resultado */ 
  CLOSE STORED-PROC pc_ret_trans_pend_ctd_car
    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

  { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} } 
    
  /* Busca possíveis erros */ 
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_ret_trans_pend_ctd_car.pr_cdcritic 
                          WHEN pc_ret_trans_pend_ctd_car.pr_cdcritic <> ?
           aux_dscritic = pc_ret_trans_pend_ctd_car.pr_dscritic 
                          WHEN pc_ret_trans_pend_ctd_car.pr_dscritic <> ?.

    IF aux_cdcritic <> 0 OR
       aux_dscritic <> "" THEN
        DO:
          ASSIGN par_cdcritic = aux_cdcritic
                 par_dscritic = aux_dscritic.
                
          RETURN "NOK".            
        END.

    EMPTY TEMP-TABLE tt-tbctd_trans_pend. /* Projeto 470 - Marcelo Telleas Coelho */

    /*Leitura do XML de retorno da proc e criacao dos registros na tt-saldo-rdca
    para visualizacao dos registros na tela */
    
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_ret_trans_pend_ctd_car.pr_clobxmlc. 
    
    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 
       
    IF ponteiro_xml <> ? THEN
      DO:
        xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
        xDoc:GET-DOCUMENT-ELEMENT(xRoot).
        
        DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
        
          xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
        
          IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
            NEXT. 
        
          IF xRoot2:NUM-CHILDREN > 0 THEN
            DO:
              CREATE tt-tbctd_trans_pend.
              ASSIGN par_qtdregis = par_qtdregis + 1.
            END.                
          
            DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                      
              xRoot2:GET-CHILD(xField,aux_cont).
                  
              IF xField:SUBTYPE <> "ELEMENT" THEN 
                NEXT. 

              xField:GET-CHILD(xText,1).
              ASSIGN tt-tbctd_trans_pend.cdtransacao_pendente =  DEC(xText:NODE-VALUE) WHEN xField:NAME  = "cdtransacao_pendente".
              ASSIGN tt-tbctd_trans_pend.cdcooper             =  DEC(xText:NODE-VALUE) WHEN xField:NAME  = "cdcooper".
              ASSIGN tt-tbctd_trans_pend.nrdconta             =  DEC(xText:NODE-VALUE) WHEN xField:NAME  = "nrdconta".
              ASSIGN tt-tbctd_trans_pend.tpcontrato           =  DEC(xText:NODE-VALUE) WHEN xField:NAME  = "tpcontrato".
              ASSIGN tt-tbctd_trans_pend.nrcontrato           =  DEC(xText:NODE-VALUE) WHEN xField:NAME  = "nrcontrato".
              ASSIGN tt-tbctd_trans_pend.vlcontrato           =  DEC(xText:NODE-VALUE) WHEN xField:NAME  = "vlcontrato".
              ASSIGN tt-tbctd_trans_pend.dhcontrato           =  DATE(xText:NODE-VALUE) WHEN xField:NAME = "dhcontrato".
              
          END.
        END.
        
        SET-SIZE(ponteiro_xml) = 0. 
      END.
    
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.
    
    RETURN "OK".
    
END PROCEDURE.
/* Fim Projeto 470 */

/******************************************************************************/
/*Procedure para aprovar uma transacao feita pelo operador da conta*/
/******************************************************************************/
PROCEDURE aprova_trans_pend:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cdditens AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_indvalid AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfope AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_iptransa AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flmobile AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_iddispos AS CHAR                           NO-UNDO.
   
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-criticas_transacoes_oper.
    DEF OUTPUT PARAM par_flgaviso AS LOGICAL                        NO-UNDO.
    
    DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_msgretor AS CHAR                                    NO-UNDO.    
    DEF VAR aux_dsorigem AS CHAR                                    NO-UNDO.
    DEF VAR aux_dstransa AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdrowid AS ROWID                                   NO-UNDO.
    DEF VAR aux_auxditem AS CHAR                                    NO-UNDO.
    DEF VAR aux_cddoitem AS DECI                                    NO-UNDO.
    DEF VAR aux_conttran AS INTE                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    
    DEF VAR aux_vlronlin AS DECI                                    NO-UNDO.
    DEF VAR aux_vlrdatag AS DECI                                    NO-UNDO.
    
    DEF VAR aux_vltarifa AS DECI                                    NO-UNDO.
    DEF VAR aux_cdhistor AS INTE                                    NO-UNDO.
    DEF VAR aux_cdhisest AS INTE                                    NO-UNDO.
    DEF VAR aux_cdfvlcop AS INTE                                    NO-UNDO.
    DEF VAR aux_mensagem AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsprotoc AS CHAR                                    NO-UNDO.
    
    DEF VAR aux_cdhiscre AS INTE                                    NO-UNDO.
    DEF VAR aux_cdhisdeb AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdocmto AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdoccre AS INTE                                    NO-UNDO.
    DEF VAR aux_cdlantar AS INTE                                    NO-UNDO.

    DEF VAR aux_nmconban AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdseqfat AS DECI                                    NO-UNDO.
    DEF VAR aux_cdseqdrf AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrcpfrep AS DECI                                    NO-UNDO.
    DEF VAR aux_vlrdocum AS DECI                                    NO-UNDO.
    DEF VAR aux_nrdigfat AS INTE                                    NO-UNDO.
    DEF VAR aux_cdbcoctl AS INTE                                    NO-UNDO.

    DEF VAR aux_cdagectl AS INTE                                    NO-UNDO.
    DEF VAR aux_msgofatr AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdempcon AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdsegmto AS CHAR                                    NO-UNDO.

    DEF VAR aux_nrdocdeb AS INTE                                    NO-UNDO.
    
    DEF VAR aux_lindigi1 AS DECI                                    NO-UNDO.
    DEF VAR aux_lindigi2 AS DECI                                    NO-UNDO.
    DEF VAR aux_lindigi3 AS DECI                                    NO-UNDO.
    DEF VAR aux_lindigi4 AS DECI                                    NO-UNDO.
    DEF VAR aux_lindigi5 AS DECI                                    NO-UNDO.
    
    DEF VAR aux_dtvencto AS DATE                                    NO-UNDO.
    DEF VAR aux_vllantra AS DECI                                    NO-UNDO.
	DEF VAR aux_cdbarras AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrctacob AS INTE                                    NO-UNDO.
    DEF VAR aux_insittit AS INTE                                    NO-UNDO.

    DEF VAR aux_intitcop AS INTE                                    NO-UNDO.
    DEF VAR aux_nrcnvcob AS DECI                                    NO-UNDO.
    DEF VAR aux_nrboleto AS DECI                                    NO-UNDO.
    DEF VAR aux_nrdctabb AS INTE                                    NO-UNDO.

    DEF VAR aux_vlrjuros AS DECI                                    NO-UNDO.
    DEF VAR aux_vlrmulta AS DECI                                    NO-UNDO.
    DEF VAR aux_vldescto AS DECI                                    NO-UNDO.
    DEF VAR aux_vlabatim AS DECI                                    NO-UNDO.
    DEF VAR aux_vloutdeb AS DECI                                    NO-UNDO.
    DEF VAR aux_vloutcre AS DECI                                    NO-UNDO.

    DEF VAR aux_vlrtarif AS DECI                                    NO-UNDO.
    DEF VAR aux_percetop AS DECI                                    NO-UNDO.
    DEF VAR aux_vltaxiof AS DECI                                    NO-UNDO.
    DEF VAR aux_vltariof AS DECI                                    NO-UNDO.
	DEF VAR aux_vlliquid AS DECI                                    NO-UNDO.
    DEF VAR aux_nrctremp AS INTE                                    NO-UNDO.
    DEF VAR aux_vlemprst AS DECI                                    NO-UNDO.

    DEF VAR aux_hrlimini AS INTE                                    NO-UNDO.
    DEF VAR aux_hrlimfim AS INTE                                    NO-UNDO.
    DEF VAR aux_idestour AS INTE                                    NO-UNDO.

    DEF VAR aux_nmdcampo AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmprimtl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmfatret AS CHAR                                    NO-UNDO.
    DEF VAR aux_rowidpag AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsalerta AS CHAR                                    NO-UNDO.
    DEF VAR aux_des_reto AS CHAR                                    NO-UNDO.

    DEF VAR aux_nmextbcc AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlfatura AS DECI                                    NO-UNDO.
    DEF VAR aux_dtdifere AS LOGI                                    NO-UNDO. 
    DEF VAR aux_vldifere AS LOGI                                    NO-UNDO.
    DEF VAR aux_cobregis AS LOGI                                    NO-UNDO.
    DEF VAR aux_msgalert AS CHAR                                    NO-UNDO.
																							DEF VAR aux_dsretorn AS CHAR                                    NO-UNDO.
    DEF VAR aux_qtminast AS INTE                                    NO-UNDO.
    DEF VAR aux_contapro AS INTE                                    NO-UNDO.    
        
    DEF VAR aux_flagdarf AS LOGICAL                                 NO-UNDO.
    DEF VAR aux_trandarf AS CHAR                                    NO-UNDO.
    DEF VAR aux_qtdregis AS INT                                     NO-UNDO.
    
    DEF VAR aux_flagtrib AS LOGICAL                                 NO-UNDO.
    DEF VAR aux_trantrib AS CHAR                                    NO-UNDO.
    
    DEF VAR aux_flagctd  AS LOGICAL                                 NO-UNDO. /* Projeto 470 */
    DEF VAR aux_tranctd  AS CHAR                                    NO-UNDO. /* Projeto 470 */
    DEF VAR aux_flgfinal_ctd AS CHAR                                NO-UNDO. /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */

    
    DEF VAR aux_vldocmto AS DECIMAL                                 NO-UNDO.
            
	DEF VAR aux_dtlibera AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtdcaptu AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlcheque AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdocmc7 AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrremret AS CHAR                                    NO-UNDO.
    DEF VAR aux_vltotbdc AS DECIMAL                                 NO-UNDO.
    DEF VAR aux_flgtbdsc AS LOGICAL                                 NO-UNDO.

    DEF VAR aux_cdbandoc_bdt AS LONGCHAR                            NO-UNDO.
    DEF VAR aux_nrdctabb_bdt AS LONGCHAR                            NO-UNDO.
    DEF VAR aux_nrcnvcob_bdt AS LONGCHAR                            NO-UNDO.
    DEF VAR aux_nrdocmto_bdt AS LONGCHAR                            NO-UNDO.
    DEF VAR aux_vltotbdt     AS DECIMAL                             NO-UNDO.
    DEF VAR aux_flgtbdst     AS LOGICAL                             NO-UNDO.

    
    /* Variaveis para o XML */ 
    DEF VAR vr_xml        AS LONGCHAR.
    DEF VAR xDoc          AS HANDLE                                 NO-UNDO.   
    DEF VAR xRoot         AS HANDLE                                 NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE                                 NO-UNDO.  
    DEF VAR xField        AS HANDLE                                 NO-UNDO. 
    DEF VAR xText         AS HANDLE                                 NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER                                NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER                                NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR                                 NO-UNDO. 

    DEF VAR h-b1wgen0015 AS HANDLE NO-UNDO.
    DEF VAR h-b1wgen0081 AS HANDLE NO-UNDO.
    DEF VAR h-b1wgen0092 AS HANDLE NO-UNDO.
    DEF VAR h-b1wgen0188 AS HANDLE NO-UNDO.
    DEF VAR h-b1crap20   AS HANDLE NO-UNDO.
    DEF VAR h-b1crap22   AS HANDLE NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-criticas_transacoes_oper.
    EMPTY TEMP-TABLE tt-vlrdat.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_dstransa = "Aprovacao de Transacoes Pendentes"
           aux_flagdarf = FALSE
           aux_flagtrib = FALSE.


    IF par_nrcpfope > 0 THEN 
    DO:
      ASSIGN aux_cdcritic = 0 
             aux_dscritic = "Operador nao pode aprovar transacoes pendentes.".
                      
      RUN gera_erro (INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT 1,            /** Sequencia **/
                     INPUT aux_cdcritic,
                     INPUT-OUTPUT aux_dscritic).
                                     
      IF par_flgerlog THEN
      DO:
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT FALSE,
                            INPUT 1,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).
      END.
    RETURN "NOK".    
        /*FOR FIRST crapass FIELDS(idastcjt qtminast) NO-LOCK WHERE crapass.cdcooper = par_cdcooper
                                                     AND crapass.nrdconta = par_nrdconta. END.

        IF NOT AVAIL crapass THEN
            DO:
                ASSIGN aux_cdcritic = 9 
                       aux_dscritic = "".
                    
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                   
                IF par_flgerlog THEN
                    DO:
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT 1,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).
                    END.
                
                RETURN "NOK".
            END.             

         ASSIGN aux_qtminast = crapass.qtminast
                aux_nrcpfrep = par_nrcpfope.*/
    END.
    /*ELSE 
      DO:*/
    FOR FIRST crapass FIELDS(idastcjt qtminast) NO-LOCK WHERE crapass.cdcooper = par_cdcooper
                                                 AND crapass.nrdconta = par_nrdconta. END.

    IF NOT AVAIL crapass THEN
        DO:
            ASSIGN aux_cdcritic = 9 
                   aux_dscritic = "".
                
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                               
            IF par_flgerlog THEN
                DO:
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT 1,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
                END.
            
            RETURN "NOK".
        END.             

	ASSIGN aux_qtminast = crapass.qtminast.

    FOR FIRST crapsnh FIELDS(nrcpfcgc) NO-LOCK WHERE crapsnh.cdcooper = par_cdcooper
                                                 AND crapsnh.nrdconta = par_nrdconta
                                                 AND crapsnh.idseqttl = par_idseqttl
                                                 AND crapsnh.tpdsenha = 1. END.

    IF NOT AVAIL crapsnh THEN
        DO:
            ASSIGN aux_cdcritic = 0 
                   aux_dscritic = "Registro de senha inexistente.".
                
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                               
            IF par_flgerlog THEN
                DO:
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT 1,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
                END.
            
            RETURN "NOK".
        END.            

    ASSIGN aux_nrcpfrep = crapsnh.nrcpfcgc.

    IF crapass.idastcjt = 1 THEN
        DO:
            RUN pc_valid_repre_legal_trans(INPUT par_cdcooper
                                          ,INPUT par_nrdconta
                                          ,INPUT par_nrdcaixa
                                          ,INPUT par_cdagenci
                                          ,INPUT par_cdoperad
                                          ,INPUT par_dtmvtolt
                                          ,INPUT par_idorigem
                                          ,INPUT par_nmdatela
                                          ,INPUT par_idseqttl
                                          ,INPUT 1
                                          ,INPUT TRUE
                                          ,OUTPUT aux_cdcritic
                                          ,OUTPUT aux_dscritic).
            IF RETURN-VALUE <> "OK" THEN
                DO:
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).

                    IF par_flgerlog THEN
                        DO:
                            RUN proc_gerar_log (INPUT par_cdcooper,
                                                INPUT par_cdoperad,
                                                INPUT aux_dscritic,
                                                INPUT aux_dsorigem,
                                                INPUT aux_dstransa,
                                                INPUT FALSE,
                                                INPUT 1,
                                                INPUT par_nmdatela,
                                                INPUT par_nrdconta,
                                               OUTPUT aux_nrdrowid).
                        END.
                    
                    RETURN "NOK".
                END.
        END.
    ELSE
        DO:
            FOR FIRST crapavt FIELDS(cdcooper) NO-LOCK WHERE crapavt.cdcooper = crapsnh.cdcooper
                                                         AND crapavt.nrdconta = crapsnh.nrdconta
                                                         AND crapavt.tpctrato = 6
                                                         AND crapavt.nrcpfcgc = crapsnh.nrcpfcgc. END.

            IF NOT AVAIL crapavt THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Necessario habilitar um preposto. \nEntre em contato com seu PA".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).

                    IF par_flgerlog THEN
                        DO:
                            RUN proc_gerar_log (INPUT par_cdcooper,
                                                INPUT par_cdoperad,
                                                INPUT aux_dscritic,
                                                INPUT aux_dsorigem,
                                                INPUT aux_dstransa,
                                                INPUT FALSE,
                                                INPUT 1,
                                                INPUT par_nmdatela,
                                                INPUT par_nrdconta,
                                               OUTPUT aux_nrdrowid).
                        END.
                    
                    RETURN "NOK".
                END.
        END.
      /*END.*/

    EMPTY TEMP-TABLE tt-tbgen_trans_pend.
    EMPTY TEMP-TABLE tt-tbtransf_trans_pend.
    EMPTY TEMP-TABLE tt-tbspb_trans_pend.
    EMPTY TEMP-TABLE tt-tbpagto_trans_pend.
    EMPTY TEMP-TABLE tt-tbepr_trans_pend.
    EMPTY TEMP-TABLE tt-tbcapt_trans_pend.
    EMPTY TEMP-TABLE tt-tbconv_trans_pend.
    EMPTY TEMP-TABLE tt-tbfolha_trans_pend.
    EMPTY TEMP-TABLE tt-tbtarif_pacote_trans_pend.
    EMPTY TEMP-TABLE tt-tbpagto_darf_das_trans_pend.
    EMPTY TEMP-TABLE tt-tbrecarga_trans_pend.
                                                                                                  EMPTY TEMP-TABLE tt-tbcobran_sms_trans_pend.
    EMPTY TEMP-TABLE tt-tbdscc_trans_pend.
    EMPTY TEMP-TABLE tt-tbdsct_trans_pend.
    EMPTY TEMP-TABLE tt-tbepr_trans_pend_prop.
    
    DO aux_contador = 1 TO NUM-ENTRIES(par_cdditens,"/"):
        
        ASSIGN aux_auxditem = ENTRY(aux_contador,par_cdditens,"/")
               aux_auxditem = ENTRY(1,aux_auxditem,"|")
               aux_cddoitem = DECI(ENTRY(3,aux_auxditem,",")).
        
        FOR FIRST tbgen_trans_pend WHERE tbgen_trans_pend.cdtransacao_pendente = aux_cddoitem NO-LOCK. END.
        
        IF AVAIL tbgen_trans_pend THEN
            DO:
                CREATE tt-tbgen_trans_pend.
                BUFFER-COPY tbgen_trans_pend TO tt-tbgen_trans_pend.

                ASSIGN tt-tbgen_trans_pend.idordem_efetivacao = aux_contador.

                IF tbgen_trans_pend.tptransacao = 1 OR   /* Transf.Intracoop */
                   tbgen_trans_pend.tptransacao = 3 OR   /* Crédito Salário  */
                   tbgen_trans_pend.tptransacao = 5 THEN /* Transf.Intercoop */
                    DO:
                        FOR FIRST tbtransf_trans_pend WHERE tbtransf_trans_pend.cdtransacao_pendente = aux_cddoitem NO-LOCK. END.
        
                        IF AVAIL tbtransf_trans_pend THEN
                            DO:
                                CREATE tt-tbtransf_trans_pend.
                                BUFFER-COPY tbtransf_trans_pend TO tt-tbtransf_trans_pend. 

                                ASSIGN tt-tbgen_trans_pend.idmovimento_conta  = IdentificaMovCC(tbgen_trans_pend.tptransacao,
                                                                                                tbtransf_trans_pend.idagendamento,0).
                            END.
                        ELSE
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Registro de Lancamento Inexistente.".
                        
                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,            /** Sequencia **/
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).
                                
                                IF par_flgerlog THEN
                                    DO:
                                        RUN proc_gerar_log (INPUT par_cdcooper,
                                                            INPUT par_cdoperad,
                                                            INPUT aux_dscritic,
                                                            INPUT aux_dsorigem,
                                                            INPUT aux_dstransa,
                                                            INPUT FALSE,
                                                            INPUT 1,
                                                            INPUT par_nmdatela,
                                                            INPUT par_nrdconta,
                                                           OUTPUT aux_nrdrowid).
                                    END.
                                
                                RETURN "NOK".
                            END.
                    END.
                ELSE IF tbgen_trans_pend.tptransacao = 4 
                     OR tbgen_trans_pend.tptransacao = 22 /*REQ39*/
                     THEN /* TED */
                    DO:
                        FOR FIRST tbspb_trans_pend WHERE tbspb_trans_pend.cdtransacao_pendente = aux_cddoitem NO-LOCK. END.
        
                        IF AVAIL tbspb_trans_pend THEN
                            DO:
                                CREATE tt-tbspb_trans_pend.
                                BUFFER-COPY tbspb_trans_pend TO tt-tbspb_trans_pend. 

                                ASSIGN tt-tbgen_trans_pend.idmovimento_conta  = IdentificaMovCC(tbgen_trans_pend.tptransacao,
                                                                                                tt-tbspb_trans_pend.idagendamento,0).
                            END.
                        ELSE
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Registro de TED Inexistente.".
                        
                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,            /** Sequencia **/
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).
                                
                                IF par_flgerlog THEN
                                    DO:
                                        RUN proc_gerar_log (INPUT par_cdcooper,
                                                            INPUT par_cdoperad,
                                                            INPUT aux_dscritic,
                                                            INPUT aux_dsorigem,
                                                            INPUT aux_dstransa,
                                                            INPUT FALSE,
                                                            INPUT 1,
                                                            INPUT par_nmdatela,
                                                            INPUT par_nrdconta,
                                                           OUTPUT aux_nrdrowid).
                                    END.
                                
                                RETURN "NOK".
                            END.
                    END.
                ELSE IF tbgen_trans_pend.tptransacao = 2 THEN /* Pagamentos */
                    DO:
                        FOR FIRST tbpagto_trans_pend WHERE tbpagto_trans_pend.cdtransacao_pendente = aux_cddoitem NO-LOCK. END.
        
                        IF AVAIL tbpagto_trans_pend THEN
                            DO:
                                CREATE tt-tbpagto_trans_pend.
                                BUFFER-COPY tbpagto_trans_pend TO tt-tbpagto_trans_pend. 

                                ASSIGN tt-tbgen_trans_pend.idmovimento_conta  = IdentificaMovCC(tbgen_trans_pend.tptransacao,
                                                                                                tbpagto_trans_pend.idagendamento,0).
                            END.
                        ELSE
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Registro de Pagamento Inexistente.".
                        
                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,            /** Sequencia **/
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).
                                
                                IF par_flgerlog THEN
                                    DO:
                                        RUN proc_gerar_log (INPUT par_cdcooper,
                                                            INPUT par_cdoperad,
                                                            INPUT aux_dscritic,
                                                            INPUT aux_dsorigem,
                                                            INPUT aux_dstransa,
                                                            INPUT FALSE,
                                                            INPUT 1,
                                                            INPUT par_nmdatela,
                                                            INPUT par_nrdconta,
                                                           OUTPUT aux_nrdrowid).
                                    END.
                                
                                RETURN "NOK".
                            END.
                                
                        /* Se for agendamento de pagamentos */
                        IF  tbpagto_trans_pend.idagendamento = 2 THEN
                            DO:
                                FIND FIRST crapcon WHERE crapcon.cdcooper = par_cdcooper 
                                                     AND crapcon.cdsegmto = INT(SUBSTRING(tbpagto_trans_pend.dscodigo_barras,2,1))
                                                     AND crapcon.cdempcon = INT(SUBSTRING(tbpagto_trans_pend.dscodigo_barras,16,4))
                                                     NO-LOCK NO-ERROR.
                                             
                                IF  AVAILABLE crapcon THEN
                                    DO:
                                       /* Validar somente para convenios sicredi */
                                       IF  crapcon.tparrecd = 1 THEN /* SICREDI */ 
                                           DO:
                                              /* Verificar horario de inicio da DEBSIC */
                                              FIND FIRST craphec WHERE craphec.cdcooper = par_cdcooper 
                                                                   AND craphec.cdprogra = "DEBSIC"
                                                                   NO-LOCK NO-ERROR.
                                                                   
                                              IF  AVAILABLE craphec THEN
                                                  DO:
                                                      /*  Aceitar ate o horario de inicio da DEBSIC */
                                                      IF  TIME >= craphec.hriniexe AND
                                                          tbpagto_trans_pend.dtdebito = par_dtmvtolt THEN
                                                          DO:
                                                             ASSIGN aux_cdcritic = 0
                                                                    aux_dscritic = "Horario esgotado para pagamentos.".
                                              
                                                             RUN gera_erro (INPUT par_cdcooper,
                                                                            INPUT par_cdagenci,
                                                                            INPUT par_nrdcaixa,
                                                                            INPUT 1,            /** Sequencia **/
                                                                            INPUT aux_cdcritic,
                                                                            INPUT-OUTPUT aux_dscritic).
                                                              
                                                              IF  par_flgerlog THEN
                                                                  DO:
                                                                      RUN proc_gerar_log (INPUT par_cdcooper,
                                                                                          INPUT par_cdoperad,
                                                                                          INPUT aux_dscritic,
                                                                                          INPUT aux_dsorigem,
                                                                                          INPUT aux_dstransa,
                                                                                          INPUT FALSE,
                                                                                          INPUT 1,
                                                                                          INPUT par_nmdatela,
                                                                                          INPUT par_nrdconta,
                                                                                         OUTPUT aux_nrdrowid).
                                                                  END.
                                RETURN "NOK".
                            END.
                                                  END.
                                           END.
                                    END.  
                            END.
                                                                      
                    END.
                ELSE IF tbgen_trans_pend.tptransacao = 6 THEN /* Pré-Aprovado */
                    DO:
                        FOR FIRST tbepr_trans_pend WHERE tbepr_trans_pend.cdtransacao_pendente = aux_cddoitem NO-LOCK. END.
        
                        IF AVAIL tbepr_trans_pend THEN
                            DO:
                                CREATE tt-tbepr_trans_pend.
                                BUFFER-COPY tbepr_trans_pend TO tt-tbepr_trans_pend. 

                                ASSIGN tt-tbgen_trans_pend.idmovimento_conta  = IdentificaMovCC(tbgen_trans_pend.tptransacao,1,0).
                            END.
                        ELSE
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Registro de Pre-Aprovado Inexistente.".
                        
                                RUN gera_erro (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT 1,            /** Sequencia **/
                                              INPUT aux_cdcritic,
                                              INPUT-OUTPUT aux_dscritic).
                                
                                IF par_flgerlog THEN
                                    DO:
                                        RUN proc_gerar_log (INPUT par_cdcooper,
                                                            INPUT par_cdoperad,
                                                            INPUT aux_dscritic,
                                                            INPUT aux_dsorigem,
                                                            INPUT aux_dstransa,
                                                            INPUT FALSE,
                                                            INPUT 1,
                                                            INPUT par_nmdatela,
                                                            INPUT par_nrdconta,
                                                           OUTPUT aux_nrdrowid).
                                    END.
                                
                                RETURN "NOK".
                            END.
                    END.
                ELSE IF tbgen_trans_pend.tptransacao = 7 THEN /* Aplicações */
                    DO:
                        FOR FIRST tbcapt_trans_pend WHERE tbcapt_trans_pend.cdtransacao_pendente = aux_cddoitem NO-LOCK. END.
        
                        IF AVAIL tbcapt_trans_pend THEN
                            DO:
                                CREATE tt-tbcapt_trans_pend.
                                BUFFER-COPY tbcapt_trans_pend TO tt-tbcapt_trans_pend. 
                                
                                ASSIGN tt-tbgen_trans_pend.idmovimento_conta  = IdentificaMovCC(tbgen_trans_pend.tptransacao,
                                                                                                1,tbcapt_trans_pend.tpoperacao).
                            END.
                        ELSE
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Registro de Aplicacao Inexistente.".
                        
                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,            /** Sequencia **/
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).
                                
                                IF par_flgerlog THEN
                                    DO:
                                        RUN proc_gerar_log (INPUT par_cdcooper,
                                                            INPUT par_cdoperad,
                                                            INPUT aux_dscritic,
                                                            INPUT aux_dsorigem,
                                                            INPUT aux_dstransa,
                                                            INPUT FALSE,
                                                            INPUT 1,
                                                            INPUT par_nmdatela,
                                                            INPUT par_nrdconta,
                                                           OUTPUT aux_nrdrowid).
                                    END.
                                
                                RETURN "NOK".
                            END.
                    END.
                ELSE IF tbgen_trans_pend.tptransacao = 8 THEN /* Débito Automático */
                    DO:
                        FOR FIRST tbconv_trans_pend WHERE tbconv_trans_pend.cdtransacao_pendente = aux_cddoitem NO-LOCK. END.
        
                        IF AVAIL tbconv_trans_pend THEN
                            DO:
                                CREATE tt-tbconv_trans_pend.
                                BUFFER-COPY tbconv_trans_pend TO tt-tbconv_trans_pend. 

                                ASSIGN tt-tbgen_trans_pend.idmovimento_conta  = IdentificaMovCC(tbgen_trans_pend.tptransacao,
                                                                                                1,tbconv_trans_pend.tpoperacao).
                            END.
                        ELSE
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Registro de Debito Automatico Inexistente.".
                        
                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,            /** Sequencia **/
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).
                                
                                IF par_flgerlog  THEN
                                    DO:
                                        RUN proc_gerar_log (INPUT par_cdcooper,
                                                            INPUT par_cdoperad,
                                                            INPUT aux_dscritic,
                                                            INPUT aux_dsorigem,
                                                            INPUT aux_dstransa,
                                                            INPUT FALSE,
                                                            INPUT 1,
                                                            INPUT par_nmdatela,
                                                            INPUT par_nrdconta,
                                                           OUTPUT aux_nrdrowid).
                                    END.
                                
                                RETURN "NOK".
                            END.
                    END.
                ELSE IF tbgen_trans_pend.tptransacao = 9 THEN /* Folha de Pagamento */
                    DO:
                        FOR FIRST tbfolha_trans_pend WHERE tbfolha_trans_pend.cdtransacao_pendente = aux_cddoitem NO-LOCK. END.
        
                        IF AVAIL tbfolha_trans_pend THEN
                            DO:
                                CREATE tt-tbfolha_trans_pend.
                                BUFFER-COPY tbfolha_trans_pend TO tt-tbfolha_trans_pend. 

                                ASSIGN tt-tbgen_trans_pend.idmovimento_conta  = IdentificaMovCC(tbgen_trans_pend.tptransacao,1,0).
                            END.
                        ELSE
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Registro de Folha de Pagamento Inexistente.".
                        
                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,            /** Sequencia **/
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).
                                
                                IF par_flgerlog THEN
                                    DO:
                                        RUN proc_gerar_log (INPUT par_cdcooper,
                                                            INPUT par_cdoperad,
                                                            INPUT aux_dscritic,
                                                            INPUT aux_dsorigem,
                                                            INPUT aux_dstransa,
                                                            INPUT FALSE,
                                                            INPUT 1,
                                                            INPUT par_nmdatela,
                                                            INPUT par_nrdconta,
                                                           OUTPUT aux_nrdrowid).
                                    END.
                                
                                RETURN "NOK".
                            END.
                    END.
				ELSE IF tbgen_trans_pend.tptransacao = 10 THEN /* Pacote de Tarifas */
                    DO:
                        FOR FIRST tbtarif_pacote_trans_pend WHERE tbtarif_pacote_trans_pend.cdtransacao_pendente = aux_cddoitem NO-LOCK. END.
        
                        IF AVAIL tbtarif_pacote_trans_pend THEN
                            DO:
                                CREATE tt-tbtarif_pacote_trans_pend.
                                BUFFER-COPY tbtarif_pacote_trans_pend TO tt-tbtarif_pacote_trans_pend. 

                                ASSIGN tt-tbgen_trans_pend.idmovimento_conta  = IdentificaMovCC(tbgen_trans_pend.tptransacao,1,0).
                            END.                                                                                                                                
                                                                                                                          
                        ELSE
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Registro de Servicos Cooperativos Pendente Inexistente.".
                        
                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,            /** Sequencia **/
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).
                                
                                IF par_flgerlog THEN
                                    DO:
                                        RUN proc_gerar_log (INPUT par_cdcooper,
                                                            INPUT par_cdoperad,
                                                            INPUT aux_dscritic,
                                                            INPUT aux_dsorigem,
                                                            INPUT aux_dstransa,
                                                            INPUT FALSE,
                                                            INPUT 1,
                                                            INPUT par_nmdatela,
                                                            INPUT par_nrdconta,
                                                           OUTPUT aux_nrdrowid).
                                    END.

                                RETURN "NOK".
                            END.
                    END.
                ELSE IF tbgen_trans_pend.tptransacao = 11 THEN /* DARF-DAS */
                  DO:
                    ASSIGN tt-tbgen_trans_pend.idmovimento_conta = IdentificaMovCC(tbgen_trans_pend.tptransacao,1,0)
                           aux_flagdarf = TRUE.
                    
                    IF aux_trandarf <> ? THEN
                      ASSIGN aux_trandarf = aux_trandarf + ";".
                      
                    ASSIGN aux_trandarf = aux_trandarf + STRING(aux_cddoitem).
                    
                  END.				  
				ELSE IF tbgen_trans_pend.tptransacao = 14 OR  /* FGTS */ 
                tbgen_trans_pend.tptransacao = 15 THEN /* DAE */
          DO:
            ASSIGN tt-tbgen_trans_pend.idmovimento_conta = IdentificaMovCC(tbgen_trans_pend.tptransacao,1,0)
                   aux_flagtrib = TRUE.
            
            IF aux_trantrib <> ? THEN
              ASSIGN aux_trantrib = aux_trantrib + ";".
              
            ASSIGN aux_trantrib = aux_trantrib + STRING(aux_cddoitem).
            
                  END.				  
          
				/* Contrato SMS */
				ELSE IF tbgen_trans_pend.tptransacao = 16 OR
				        tbgen_trans_pend.tptransacao = 17 THEN
				DO:
					FOR FIRST tbcobran_sms_trans_pend WHERE tbcobran_sms_trans_pend.cdtransacao_pendente = aux_cddoitem NO-LOCK. END.
                                                                                                                            
					IF AVAIL tbcobran_sms_trans_pend THEN
					DO:
						CREATE tt-tbcobran_sms_trans_pend.
						BUFFER-COPY tbcobran_sms_trans_pend TO tt-tbcobran_sms_trans_pend.
                                                                                                                              
                          ASSIGN tt-tbgen_trans_pend.idmovimento_conta  = IdentificaMovCC(tbgen_trans_pend.tptransacao,1,0).
                                END.
                          END.
                ELSE IF tbgen_trans_pend.tptransacao = 12 THEN /* Desconto de Cheque */
                  DO:
                      EMPTY TEMP-TABLE tt-tbdscc_trans_pend.
                      
                      aux_flgtbdsc = FALSE.
                      
                      FOR EACH tbdscc_trans_pend WHERE tbdscc_trans_pend.cdtransacao_pendente = aux_cddoitem NO-LOCK:
                          CREATE tt-tbdscc_trans_pend.
                          BUFFER-COPY tbdscc_trans_pend TO tt-tbdscc_trans_pend.
                          aux_flgtbdsc = TRUE.
                      END.
                      
                      IF aux_flgtbdsc THEN
						ASSIGN tt-tbgen_trans_pend.idmovimento_conta  = IdentificaMovCC(tbgen_trans_pend.tptransacao,1,0).
                      ELSE 
                          DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Registro de Borderô de Desconto Pendente Inexistente.".
                    
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,            /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                            
                            IF par_flgerlog THEN
                              DO:
                                  RUN proc_gerar_log (INPUT par_cdcooper,
                                                      INPUT par_cdoperad,
                                                      INPUT aux_dscritic,
                                                      INPUT aux_dsorigem,
                                                      INPUT aux_dstransa,
                                                      INPUT FALSE,
                                                      INPUT 1,
                                                      INPUT par_nmdatela,
                                                      INPUT par_nrdconta,
                                                     OUTPUT aux_nrdrowid).
                                END.
                
                            RETURN "NOK".
                          END.
                  END.
              ELSE IF tbgen_trans_pend.tptransacao = 13 THEN /* Recarga de Celular */
                  DO:
                      
                      FOR FIRST tbrecarga_trans_pend WHERE tbrecarga_trans_pend.cdtransacao_pendente = aux_cddoitem NO-LOCK. END.
        
                      IF AVAIL tbrecarga_trans_pend THEN
                          DO:
                              CREATE tt-tbrecarga_trans_pend.
                              BUFFER-COPY tbrecarga_trans_pend TO tt-tbrecarga_trans_pend. 
        
                              ASSIGN tt-tbgen_trans_pend.idmovimento_conta  = IdentificaMovCC(tbgen_trans_pend.tptransacao,tbrecarga_trans_pend.tprecarga,0).
					END.
                       ELSE
                          DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Registro de Recarga de celular Inexistente.".
                    
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,            /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                            
                            IF par_flgerlog THEN
                              DO:
                                  RUN proc_gerar_log (INPUT par_cdcooper,
                                                      INPUT par_cdoperad,
                                                      INPUT aux_dscritic,
                                                      INPUT aux_dsorigem,
                                                      INPUT aux_dstransa,
                                                      INPUT FALSE,
                                                      INPUT 1,
                                                      INPUT par_nmdatela,
                                                      INPUT par_nrdconta,
                                                     OUTPUT aux_nrdrowid).
        END.        
                
                            RETURN "NOK".
                          END.                   
                  END.   
       
                ELSE IF tbgen_trans_pend.tptransacao = 19 THEN /*Bordero Desconto Titulo*/
                  DO:
                      EMPTY TEMP-TABLE tt-tbdsct_trans_pend.
                      
                      aux_flgtbdst = FALSE.
                      
                      FOR EACH tbdsct_trans_pend WHERE tbdsct_trans_pend.cdtransacao_pendente = aux_cddoitem NO-LOCK:
                          CREATE tt-tbdsct_trans_pend.
                          BUFFER-COPY tbdsct_trans_pend TO tt-tbdsct_trans_pend.
                          aux_flgtbdst = TRUE.
                      END.
                      
                      IF aux_flgtbdst THEN
                          ASSIGN tt-tbgen_trans_pend.idmovimento_conta  = IdentificaMovCC(tbgen_trans_pend.tptransacao,1,0).
                      ELSE 
                          DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Registro de Bordero de Desconto de Titulos Pendente Inexistente.".
                    
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,            /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                            
                            IF par_flgerlog THEN
                              DO:
                                  RUN proc_gerar_log (INPUT par_cdcooper,
                                                      INPUT par_cdoperad,
                                                      INPUT aux_dscritic,
                                                      INPUT aux_dsorigem,
                                                      INPUT aux_dstransa,
                                                      INPUT FALSE,
                                                      INPUT 1,
                                                      INPUT par_nmdatela,
                                                      INPUT par_nrdconta,
                                                     OUTPUT aux_nrdrowid).
                                END.
                
                            RETURN "NOK".
                          END.
                  END.  
/* Projeto 470 - Marcelo Telles Coelho */
            ELSE IF tbgen_trans_pend.tptransacao = 20 /* Contrato */
                 THEN
                DO:
                  ASSIGN tt-tbgen_trans_pend.idmovimento_conta = IdentificaMovCC(tbgen_trans_pend.tptransacao,1,0)
                  aux_flagctd = TRUE.
            
                  IF aux_tranctd <> ? THEN
                    ASSIGN aux_tranctd = aux_tranctd + ";".
              
                  ASSIGN aux_tranctd = aux_tranctd + STRING(aux_cddoitem).
            
                END.
            /* Fim Projeto 470 */     
                  
                ELSE IF tbgen_trans_pend.tptransacao = 21 THEN /* Contrataçao Emprestimo */
                    DO:
                        /* Efetuar a chamada a rotina Oracle */ 
                        { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
                        
                        RUN STORED-PROCEDURE pc_ret_trans_pend_prop
                          aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Código da Cooperativa */
                                                               INPUT par_cdoperad, /* Código do Operador */
                                                               INPUT par_nmdatela, /* Nome da Tela */
                                                               INPUT 1,            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                                               INPUT par_nrdconta, /* Número da Conta */
                                                               INPUT 1,            /* Titular da Conta */
                                                               INPUT STRING(aux_cddoitem), /* Codigo da Transacao */
                                                              OUTPUT 0,            /* Código da crítica */
                                                              OUTPUT "",           /* Descriçao da crítica */
                                                              OUTPUT 0,            /* Código da proposta de emprestimo */
                                                              OUTPUT 0).           /* Código da proposta de emprestimo */

                        /* Fechar o procedimento para buscarmos o resultado */ 
                        CLOSE STORED-PROC pc_ret_trans_pend_prop
                        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                        
                        /* Busca possíveis erros */ 
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = ""
                               aux_nrctremp = 0
                               aux_cdcritic = pc_ret_trans_pend_prop.pr_cdcritic 
                                              WHEN pc_ret_trans_pend_prop.pr_cdcritic <> ?
                               aux_dscritic = pc_ret_trans_pend_prop.pr_dscritic 
                                              WHEN pc_ret_trans_pend_prop.pr_dscritic <> ?
                               aux_nrctremp = pc_ret_trans_pend_prop.pr_nrctremp 
                                              WHEN pc_ret_trans_pend_prop.pr_nrctremp <> ?
                               aux_vlemprst = pc_ret_trans_pend_prop.pr_vlemprst 
                                              WHEN pc_ret_trans_pend_prop.pr_vlemprst <> ?.

                        { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }   
                        
                        IF aux_nrctremp > 0 THEN
                            DO:
                                CREATE tt-tbepr_trans_pend_prop.
                                ASSIGN tt-tbepr_trans_pend_prop.nrctremp = aux_nrctremp.
                                ASSIGN tt-tbepr_trans_pend_prop.vlemprst = ROUND(aux_vlemprst,2).

                                ASSIGN tt-tbgen_trans_pend.idmovimento_conta  = IdentificaMovCC(tbgen_trans_pend.tptransacao,1,0).
                            END.
                        ELSE
                            DO:
                                IF aux_dscritic = "" THEN
                                  DO:
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = "Registro de Proposta Inexistente.".
                                  END.
                        
                                RUN gera_erro (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT 1,            /** Sequencia **/
                                              INPUT aux_cdcritic,
                                              INPUT-OUTPUT aux_dscritic).
                                
                                IF par_flgerlog THEN
                                    DO:
                                        RUN proc_gerar_log (INPUT par_cdcooper,
                                                            INPUT par_cdoperad,
                                                            INPUT aux_dscritic,
                                                            INPUT aux_dsorigem,
                                                            INPUT aux_dstransa,
                                                            INPUT FALSE,
                                                            INPUT 1,
                                                            INPUT par_nmdatela,
                                                            INPUT par_nrdconta,
                                                           OUTPUT aux_nrdrowid).
                                    END.
                                
                                RETURN "NOK".
                            END.
                  END.
                    
                           
            END. /*IF AVAILABLE tbgen_trans_pend THEN*/
             
    END. /*DO aux_contador = 1 */
    
    /* Verifica se existem transacoes referentes a DARF/DAS */
    IF aux_flagdarf THEN
      DO:
        RUN busca_darf_das(INPUT par_cdcooper,
                           INPUT par_cdoperad,
                           INPUT par_nmdatela,
                           INPUT par_nrdconta,
                           INPUT aux_trandarf,
                          OUTPUT aux_qtdregis, 
                          OUTPUT aux_cdcritic,
                          OUTPUT aux_dscritic).
                          
        IF RETURN-VALUE <> "OK" OR aux_qtdregis = 0 THEN
          DO:
            IF aux_qtdregis = 0 THEN
              DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Registro de Folha de Pagamento Inexistente.".
              END.
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF par_flgerlog THEN
              DO:
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT 1,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
            END.        
            
            RETURN "NOK".
    END.
      END. /* FIM IF aux_flagdarf */


    /* Verifica se existem transacoes de tributos */
    IF aux_flagtrib THEN
      DO:
        RUN busca_trans_pend_trib
                          (INPUT par_cdcooper,
                           INPUT par_cdoperad,
                           INPUT par_nmdatela,
                           INPUT par_nrdconta,
                           INPUT aux_trantrib,
                          OUTPUT aux_qtdregis, 
                          OUTPUT aux_cdcritic,
                          OUTPUT aux_dscritic).
                          
        IF RETURN-VALUE <> "OK" OR aux_qtdregis = 0 THEN
          DO:
            IF aux_qtdregis = 0 THEN
              DO:
                ASSIGN aux_cdcritic = 0.
                
                IF tbgen_trans_pend.tptransacao = 14 THEN 
                  ASSIGN aux_dscritic = "Registro de pagamentos de FGTS Inexistente.".
                ELSE IF tbgen_trans_pend.tptransacao = 15 THEN
                  ASSIGN aux_dscritic = "Registro de pagamentos de DAE Inexistente.".
                  
              END.
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF par_flgerlog THEN
              DO:
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT 1,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
            END.        
            
            RETURN "NOK".
        END.
      END. /* FIM IF aux_flagtrib */

    /* Verifica se existem transacoes de contrato */
    /* Projeto 470 - Marcelo Telles Coelho */
    IF aux_flagctd THEN
      DO:
        RUN busca_trans_pend_ctd
                          (INPUT par_cdcooper,
                           INPUT par_cdoperad,
                           INPUT par_nmdatela,
                           INPUT par_nrdconta,
                           INPUT aux_tranctd,
                          OUTPUT aux_qtdregis, 
                          OUTPUT aux_cdcritic,
                          OUTPUT aux_dscritic).
                          
        IF RETURN-VALUE <> "OK" OR aux_qtdregis = 0 THEN
          DO:
            IF aux_qtdregis = 0 THEN
              DO:
                ASSIGN aux_cdcritic = 0.
                
                ASSIGN aux_dscritic = "Registro de Contrato Inexistente.".
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                IF par_flgerlog THEN
                  DO:
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT 1,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
                  END.        
            
                RETURN "NOK".
              END.
          END.
      END. /* FIM IF aux_flagctd */
      /* Fim Projeto 470 */


    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR NO-WAIT.

    FOR EACH tt-tbgen_trans_pend NO-LOCK BY tt-tbgen_trans_pend.idmovimento_conta
                                         BY tt-tbgen_trans_pend.idordem_efetivacao:

        TRANSACAO:                         
        DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
                
                ASSIGN aux_conttran = 0
                       aux_cdcritic = 0
                       aux_dscritic = ""
                       glb_dsprotoc = "". 
                
                /* LOCK DO REGISTRO PAI */
                FOR FIRST tbgen_trans_pend WHERE tbgen_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente EXCLUSIVE-LOCK. END.

                IF NOT AVAIL tbgen_trans_pend THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Registro de Transacao Inexistente.".
                        
                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                INPUT par_cdoperad,
                                                INPUT aux_dscritic,
                                                INPUT aux_dsorigem,
                                                INPUT aux_dstransa,
                                                INPUT FALSE,
                                                INPUT par_nmdatela,
                                                INPUT par_nrdconta,
                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                INPUT FALSE,
                                                INPUT par_indvalid,
                                                INPUT ?,
                                                INPUT 0,
                                                INPUT 0).
                        
                        IF par_indvalid = 1 THEN
                            ASSIGN par_flgaviso = TRUE.

                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.

                    FOR FIRST tbgen_aprova_trans_pend FIELDS(idsituacao_aprov) 
                        WHERE tbgen_aprova_trans_pend.cdtransacao_pendente    = tt-tbgen_trans_pend.cdtransacao_pendente
                          AND tbgen_aprova_trans_pend.nrcpf_responsavel_aprov = aux_nrcpfrep NO-LOCK. END.
            
                    IF NOT AVAIL tbgen_aprova_trans_pend OR tbgen_aprova_trans_pend.idsituacao_aprov = 2  THEN
                        DO:
                            
                           ASSIGN aux_cdcritic = 0
                                  aux_dscritic = "Transacao ja foi aprovada pelo representante legal.".
                
                            RUN gera_erro_transacao(INPUT par_cdcooper,
                                                    INPUT par_cdoperad,
                                                    INPUT aux_dscritic,
                                                    INPUT aux_dsorigem,
                                                    INPUT aux_dstransa,
                                                    INPUT FALSE,
                                                    INPUT par_nmdatela,
                                                    INPUT par_nrdconta,
                                                    INPUT STRING(ROWID(tbgen_trans_pend)),
                                                    INPUT FALSE,
                                                    INPUT par_indvalid,
                                                    INPUT ?,
                                                    INPUT 0,
                                                    INPUT 0).
                            
                            IF par_indvalid = 1 THEN
                                ASSIGN par_flgaviso = TRUE.

                            UNDO TRANSACAO, LEAVE TRANSACAO.
                            
                        END.
                
                /* Verifica quantidade de transacoes pendentes */
                FOR EACH tbgen_aprova_trans_pend 
                   WHERE tbgen_aprova_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente
                     AND tbgen_aprova_trans_pend.idsituacao_aprov = 1 NO-LOCK: 
                    
                    ASSIGN aux_conttran = aux_conttran + 1.

                END.

				IF aux_conttran > 1 THEN
					DO:
						ASSIGN aux_contapro = 0. /* TOTAL APROVAÇÕES REALIZADAS */

						/* Verifica quantidade de transacoes aprovadas */
						FOR EACH tbgen_aprova_trans_pend 
						   WHERE tbgen_aprova_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente
							 AND tbgen_aprova_trans_pend.idsituacao_aprov = 2 NO-LOCK: 
                    
							ASSIGN aux_contapro = aux_contapro + 1. /* TOTAL APROVAÇÕES REALIZADAS */

						END.

						IF (aux_qtminast - aux_contapro) = 1 THEN
							DO:
								ASSIGN aux_conttran = 1.
							END.

                                        END.
                                
          IF aux_conttran = 1 THEN
            DO:
              /* Procedimento do internetbank pc_valida_apv_master */
              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

              RUN STORED-PROCEDURE pc_valida_apv_master
                  aux_handproc = PROC-HANDLE NO-ERROR      
                   (INPUT  par_cdcooper
                   ,INPUT  par_nrdconta
                   ,INPUT  aux_nrcpfrep
                   ,INPUT  tt-tbgen_trans_pend.cdtransacao_pendente
                   ,OUTPUT 0
                   ,OUTPUT 0                     /* --> Retorno pr_cdcritic            */
                   ,OUTPUT "").
              
              IF  ERROR-STATUS:ERROR  THEN DO:
                DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
                  ASSIGN aux_msgerora = aux_msgerora + 
                  ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
                END.

                ASSIGN aux_dscritic = "pc_valida_apv_master --> "  +
                                      "Erro ao executar Stored Procedure: " +
                                      aux_msgerora.      
                ASSIGN xml_dsmsgerr = "<dsmsgerr>" + 
                                      "Erro inesperado. Nao foi possivel efetuar a verificacao." + 
                                      " Tente novamente ou contacte seu PA" +
                                      "</dsmsgerr>".                        
                RUN proc_geracao_log.
                  RETURN "NOK".
                           
					END.
				
              CLOSE STORED-PROC pc_valida_apv_master
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl}}

              ASSIGN aux_conttran   = pc_valida_apv_master.pr_conttran 
                                      WHEN pc_valida_apv_master.pr_conttran <> ?
                     aux_dscritic   = pc_valida_apv_master.pr_dscritic 
                                      WHEN pc_valida_apv_master.pr_dscritic <> ? .                               

              /* Verificar se retornou critica */
              IF aux_dscritic <> "" THEN
                DO:
                  /* Gerar log das teds com erro */
                  RUN gera_erro_transacao(INPUT par_cdcooper,
                                          INPUT par_cdoperad,
                                          INPUT aux_dscritic,
                                          INPUT aux_dsorigem,
                                          INPUT aux_dstransa,
                                          INPUT FALSE,
                                          INPUT par_nmdatela,
                                          INPUT par_nrdconta,
                                          INPUT STRING(ROWID(tbgen_trans_pend)),
                                          INPUT FALSE,
                                          INPUT par_indvalid,
                                          INPUT TODAY,
                                          INPUT 0,
                                          INPUT aux_conttran).

                 IF par_indvalid = 1 THEN
                   ASSIGN par_flgaviso = TRUE.
                          
                 UNDO TRANSACAO, LEAVE TRANSACAO.
                 END.
            END.
             
                IF  aux_conttran = 1 AND par_indvalid = 0 THEN
                    DO:
                        RUN pc_valores_online(INPUT tt-tbgen_trans_pend.tptransacao,
                                              INPUT tt-tbgen_trans_pend.cdtransacao_pendente).
                    END.
                
                IF CAN-DO("1,3,5",STRING(tt-tbgen_trans_pend.tptransacao)) THEN /* Transf.Intracoop,Crédito Salário,Transf.Intercoop */
                    DO:
                        ASSIGN aux_vltarifa = 0
                               aux_cdhistor = 0
                               aux_cdhisest = 0
                               aux_cdfvlcop = 0.

                        FOR FIRST tt-tbtransf_trans_pend WHERE tt-tbtransf_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK. END.

                        FOR FIRST crapcop FIELDS(cdbcoctl) NO-LOCK 
                                    WHERE crapcop.cdagectl = tt-tbtransf_trans_pend.cdagencia_coop_destino. END.

                        IF tt-tbgen_trans_pend.tptransacao = 5 THEN
                            DO:
                                IF NOT VALID-HANDLE(h-b1crap22) THEN
                                    RUN dbo/b1crap22.p PERSISTENT SET h-b1crap22.
                                
                                RUN tarifa-transf-intercooperativa IN h-b1crap22(INPUT par_cdcooper,
                                                                                 INPUT par_cdagenci,
                                                                                 INPUT par_nrdconta,
                                                                                 INPUT tt-tbtransf_trans_pend.vltransferencia,
                                                                                OUTPUT aux_vltarifa,
                                                                                OUTPUT aux_cdhistor,
                                                                                OUTPUT aux_cdhisest,
                                                                                OUTPUT aux_cdfvlcop,
                                                                                OUTPUT aux_dscritic).
                                IF VALID-HANDLE(h-b1crap22) THEN
                                    DELETE PROCEDURE h-b1crap22.
                                
                                IF RETURN-VALUE <> "OK" THEN
                                    DO: 
                                        /* Gerar log das teds com erro */
                                        RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                 INPUT "tarifa-transf-intercooperativa",
                                                                 INPUT "b1crap22",
                                                                 INPUT par_dtmvtolt,
                                                                 INPUT par_nrdconta,
                                                                 INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                 INPUT crapcop.cdbcoctl, /* cddbanco */
                                                                 INPUT tt-tbtransf_trans_pend.cdagencia_coop_destino, /* ag. destino */
                                                                 INPUT tt-tbtransf_trans_pend.nrconta_destino, /* conta destino */
                                                                 INPUT "", /* nome titular */
                                                                 INPUT 0, /* cpf favorecido */
                                                                 INPUT 0, /* inpessoa favorecido */
                                                                 INPUT 0, /* intipcta favorecido */
                                                                 INPUT tt-tbtransf_trans_pend.vltransferencia,
                                                                 INPUT "",
                                                                 INPUT tt-tbgen_trans_pend.tptransacao,
                                                                 INPUT 0,
                                                                 INPUT aux_dscritic).
                                        
                                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                INPUT par_cdoperad,
                                                                INPUT aux_dscritic,
                                                                INPUT aux_dsorigem,
                                                                INPUT aux_dstransa,
                                                                INPUT FALSE,
                                                                INPUT par_nmdatela,
                                                                INPUT par_nrdconta,
                                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                INPUT FALSE,
                                                                INPUT par_indvalid,
                                                                INPUT tt-tbtransf_trans_pend.dtdebito,
                                                                INPUT tt-tbtransf_trans_pend.vltransferencia,
                                                                INPUT aux_conttran).
                                        
                                        IF par_indvalid = 1 THEN
                                            ASSIGN par_flgaviso = TRUE.
            
                                        UNDO TRANSACAO, LEAVE TRANSACAO.

                                    END.             
                                
                                
                            END.
                        
                        /* VALIDACAO */    
                        IF NOT VALID-HANDLE(h-b1wgen0015) THEN
                            RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.

                        FIND FIRST tt-vlrdat WHERE tt-vlrdat.dattrans = tt-tbtransf_trans_pend.dtdebito NO-LOCK NO-ERROR NO-WAIT.                                                


                        /* Procedimento do internetbank pc_verifica_operacao_prog */
                        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                        RUN STORED-PROCEDURE pc_verifica_operacao_prog
                            aux_handproc = PROC-HANDLE NO-ERROR      
                              (INPUT  par_cdcooper
                              ,INPUT  par_cdagenci
                              ,INPUT  par_nrdcaixa
                              ,INPUT  par_nrdconta
                              ,INPUT  par_idseqttl        
                              ,INPUT  par_dtmvtolt
                              ,INPUT  tt-tbtransf_trans_pend.idagendamento
                              ,INPUT  tt-tbtransf_trans_pend.dtdebito
                              ,INPUT  IF  par_indvalid = 0 AND aux_conttran = 1 AND AVAIL (tt-vlrdat) THEN 
                                        tt-vlrdat.vlronlin
                                      ELSE
                                        tt-tbtransf_trans_pend.vltransferencia /* Valor da Transferencia */ /* par_vllanmto */
                              ,INPUT  crapcop.cdbcoctl /* par_cddbanco */
                              ,INPUT  tt-tbtransf_trans_pend.cdagencia_coop_destino /* par_cdageban */
                              ,INPUT  tt-tbtransf_trans_pend.nrconta_destino /* par_nrctatrf */
                              ,INPUT  tt-tbgen_trans_pend.tptransacao /* par_cdtiptra */
                              ,INPUT  par_cdoperad /* par_cdoperad */
                              ,INPUT  IF tt-tbgen_trans_pend.tptransacao = 3 THEN 1 ELSE tt-tbgen_trans_pend.tptransacao /* Credito Salario JDM */ /* par_tpoperac */
                              ,INPUT  1 /* par_flgvalid*/
                              ,INPUT  aux_dsorigem /* par_dsorigem */
                              ,INPUT  par_nrcpfope
                              ,INPUT  1      /* par_flgctrag */
                              ,INPUT  ""        /* par_nmdatela */
                              ,OUTPUT aux_dstransa
                              ,OUTPUT ""                     /* --> Retorno XML pr_tab_limite      */
                              ,OUTPUT ""                     /* --> Retorno XML pr_tab_internet    */
                              ,OUTPUT 0                     /* --> Retorno pr_cdcritic            */
                              ,OUTPUT "").                  /* --> Retorno pr_dscritic (OK ou NOK)*/

                        IF  ERROR-STATUS:ERROR  THEN DO:
                            DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
                                ASSIGN aux_msgerora = aux_msgerora + 
                                                      ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
                            END.
                                
                            ASSIGN aux_dscritic = "pc_verifica_operacao_prog --> "  +
                                                  "Erro ao executar Stored Procedure: " +
                                                  aux_msgerora.      
                            ASSIGN xml_dsmsgerr = "<dsmsgerr>" + 
                                                       "Erro inesperado. Nao foi possivel efetuar a verificacao." + 
                                                       " Tente novamente ou contacte seu PA" +
                                                  "</dsmsgerr>".                        
                            RUN proc_geracao_log.
                            RETURN "NOK".
                            
                        END. 

                        CLOSE STORED-PROC pc_verifica_operacao_prog
                              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl}}

                        ASSIGN aux_dscritic   = pc_verifica_operacao_prog.pr_dscritic 
                                                WHEN pc_verifica_operacao_prog.pr_dscritic <> ?                               
                               aux_tab_limite = pc_verifica_operacao_prog.pr_tab_limite 
                                                WHEN pc_verifica_operacao_prog.pr_tab_limite <> ? .

                        /* Verificar se retornou critica */
                        IF aux_dscritic <> "" THEN
                        DO:
                          /* Gerar log das teds com erro */
                          RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                   INPUT "verifica_operacao",
                                                   INPUT "b1wgen0015",
                                                   INPUT par_dtmvtolt,
                                                   INPUT par_nrdconta,
                                                   INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                   INPUT crapcop.cdbcoctl, /* cddbanco */
                                                   INPUT tt-tbtransf_trans_pend.cdagencia_coop_destino, /* ag. destino */
                                                   INPUT tt-tbtransf_trans_pend.nrconta_destino, /* conta destino */
                                                   INPUT "", /* nome titular */
                                                   INPUT 0, /* cpf favorecido */
                                                   INPUT 0, /* inpessoa favorecido */
                                                   INPUT 0, /* intipcta favorecido */
                                                   INPUT tt-tbtransf_trans_pend.vltransferencia,
                                                   INPUT "",
                                                   INPUT tt-tbgen_trans_pend.tptransacao,
                                                   INPUT 0,
                                                   INPUT aux_dscritic).
                                                          
                          RUN gera_erro_transacao(INPUT par_cdcooper,
                                                  INPUT par_cdoperad,
                                                  INPUT aux_dscritic,
                                                  INPUT aux_dsorigem,
                                                  INPUT aux_dstransa,
                                                  INPUT FALSE,
                                                  INPUT par_nmdatela,
                                                  INPUT par_nrdconta,
                                                  INPUT STRING(ROWID(tbgen_trans_pend)),
                                                  INPUT FALSE,
                                                  INPUT par_indvalid,
                                                  INPUT tt-tbtransf_trans_pend.dtdebito,
                                                  INPUT tt-tbtransf_trans_pend.vltransferencia,
                                                  INPUT aux_conttran).

                          IF par_indvalid = 1 THEN
                              ASSIGN par_flgaviso = TRUE.
                          
                          UNDO TRANSACAO, LEAVE TRANSACAO.
                        END.
                        
                        
                        IF aux_conttran = 1 AND par_indvalid = 0 THEN
                            DO:
                                FIND FIRST tt-vlrdat WHERE tt-vlrdat.dattrans = tt-tbtransf_trans_pend.dtdebito EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin + aux_vltarifa.
                            END.
                        
                        RUN verifica-historico-transferencia IN h-b1wgen0015(INPUT par_cdcooper,
                                                                             INPUT par_nrdconta,
                                                                             INPUT tt-tbtransf_trans_pend.nrconta_destino,
                                                                             INPUT par_idorigem,
                                                                             INPUT tt-tbgen_trans_pend.tptransacao,
                                                                            OUTPUT aux_cdhiscre,
                                                                            OUTPUT aux_cdhisdeb).

                        IF  RETURN-VALUE <> "OK"  THEN
                            DO:
                                IF VALID-HANDLE(h-b1wgen0015)  THEN
                                    DELETE PROCEDURE h-b1wgen0015.

                                /* Gerar log das teds com erro */
                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                         INPUT "verifica-historico-transferencia",
                                                         INPUT "b1wgen0015",
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_nrdconta,
                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                         INPUT crapcop.cdbcoctl, /* cddbanco */
                                                         INPUT tt-tbtransf_trans_pend.cdagencia_coop_destino, /* ag. destino */
                                                         INPUT tt-tbtransf_trans_pend.nrconta_destino, /* conta destino */
                                                         INPUT "", /* nome titular */
                                                         INPUT 0, /* cpf favorecido */
                                                         INPUT 0, /* inpessoa favorecido */
                                                         INPUT 0, /* intipcta favorecido */
                                                         INPUT tt-tbtransf_trans_pend.vltransferencia,
                                                         INPUT "",
                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                         INPUT 0,
                                                         INPUT aux_dscritic).
                                
                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                        INPUT par_cdoperad,
                                                        INPUT aux_dscritic,
                                                        INPUT aux_dsorigem,
                                                        INPUT aux_dstransa,
                                                        INPUT FALSE,
                                                        INPUT par_nmdatela,
                                                        INPUT par_nrdconta,
                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                        INPUT FALSE,
                                                        INPUT par_indvalid,
                                                        INPUT tt-tbtransf_trans_pend.dtdebito,
                                                        INPUT tt-tbtransf_trans_pend.vltransferencia,
                                                        INPUT aux_conttran).
                                
                                IF par_indvalid = 1 THEN
                                    ASSIGN par_flgaviso = TRUE.
                                
                                UNDO TRANSACAO, LEAVE TRANSACAO.
                                
                            END.

                        /* EFETIVACAO */    
                        IF aux_conttran = 1 AND par_indvalid = 1 THEN
                            DO:
                                /* INTRA / CREDITO SALARIO */
                                IF tt-tbgen_trans_pend.tptransacao = 1 OR   /* Transf.Intracoop */
                                   tt-tbgen_trans_pend.tptransacao = 3 THEN /* Crédito Salário  */
                	                DO:
                                        IF tt-tbtransf_trans_pend.idagendamento = 1 THEN
                                            DO: 
                                                RUN executa_transferencia IN h-b1wgen0015(INPUT par_cdcooper,
                                                                                          INPUT par_dtmvtolt,
                                                                                          INPUT par_dtmvtolt, 
                                                                                          INPUT par_cdagenci,
                                                                                          INPUT 11,
                                                                                          INPUT 11900,
                                                                                          INPUT par_nrdcaixa,
                                                                                          INPUT par_nrdconta,
                                                                                          INPUT 1,
                                                                                          INPUT par_nrdcaixa,
                                                                                          INPUT aux_cdhiscre,
                                                                                          INPUT aux_cdhisdeb,
                                                                                          INPUT tt-tbtransf_trans_pend.vltransferencia,
                                                                                          INPUT par_cdoperad,
                                                                                          INPUT tt-tbtransf_trans_pend.nrconta_destino,
                                                                                          INPUT FALSE,
                                                                                          INPUT 0, /* CDCOPTFN */
                                                                                          INPUT 0, /* CDAGETFN */
                                                                                          INPUT 0, /* NRTERFIN */
                                                                                          INPUT "",
                                                                                          INPUT par_idorigem,
                                                                                          INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                                          INPUT tt-tbtransf_trans_pend.indmobile,
                                                                                          INPUT tt-tbtransf_trans_pend.indtipo_cartao,
                                                                                          INPUT tt-tbtransf_trans_pend.nrcartao,
                                                                                         OUTPUT aux_dstransa,
                                                                                         OUTPUT aux_dscritic,
                                                                                         OUTPUT aux_nrdocdeb,
                                                                                         OUTPUT aux_nrdoccre,
                                                                                         OUTPUT glb_dsprotoc).
    
                                                IF  RETURN-VALUE <> "OK"  THEN
                                                    DO:
                                                        IF VALID-HANDLE(h-b1wgen0015) THEN
                                                            DELETE PROCEDURE h-b1wgen0015.
                        
                                                        /* Gerar log das teds com erro */
                                                        RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                                 INPUT "executa_transferencia",
                                                                                 INPUT "b1wgen0015",
                                                                                 INPUT par_dtmvtolt,
                                                                                 INPUT par_nrdconta,
                                                                                 INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                                 INPUT crapcop.cdbcoctl, /* cddbanco */
                                                                                 INPUT tt-tbtransf_trans_pend.cdagencia_coop_destino, /* ag. destino */
                                                                                 INPUT tt-tbtransf_trans_pend.nrconta_destino, /* conta destino */
                                                                                 INPUT "", /* nome titular */
                                                                                 INPUT 0, /* cpf favorecido */
                                                                                 INPUT 0, /* inpessoa favorecido */
                                                                                 INPUT 0, /* intipcta favorecido */
                                                                                 INPUT tt-tbtransf_trans_pend.vltransferencia,
                                                                                 INPUT "",
                                                                                 INPUT tt-tbgen_trans_pend.tptransacao,
                                                                                 INPUT 0,
                                                                                 INPUT aux_dscritic).
                                                        
                                                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                                INPUT par_cdoperad,
                                                                                INPUT aux_dscritic,
                                                                                INPUT aux_dsorigem,
                                                                                INPUT aux_dstransa,
                                                                                INPUT FALSE,
                                                                                INPUT par_nmdatela,
                                                                                INPUT par_nrdconta,
                                                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                                INPUT FALSE,
                                                                                INPUT par_indvalid,
                                                                                INPUT tt-tbtransf_trans_pend.dtdebito,
                                                                                INPUT tt-tbtransf_trans_pend.vltransferencia,
                                                                                INPUT aux_conttran).
                                                                                                           
                                                        IF  par_indvalid = 1  THEN
                                                            ASSIGN par_flgaviso = TRUE.
                            
                                                        UNDO TRANSACAO, LEAVE TRANSACAO.
                                                    END.
                                            END.
                                        ELSE /* Agendamento Intracooperativa */
                                            DO:     
                                                RUN cadastrar-agendamento(INPUT par_cdcooper,
                                                                          INPUT par_cdagenci,         /** PAC      **/
                                                                          INPUT par_nrdcaixa,        /** CAIXA    **/
                                                                          INPUT par_cdoperad,      /** OPERADOR **/
                                                                          INPUT par_nrdconta,
                                                                          INPUT par_idseqttl,
                                                                          INPUT par_dtmvtolt,
                                                                          /* Projeto 363 - Novo ATM */ 
                                                                          INPUT par_idorigem,
                                                                          INPUT aux_dsorigem,
                                                                          INPUT par_nmdatela,
                                                                          INPUT tt-tbgen_trans_pend.tptransacao, /** PAGAMENTO/TRANSF **/
                                                                          INPUT 0,
                                                                          INPUT '',
                                                                          INPUT '',
                                                                          INPUT 0,
                                                                          INPUT 0,
                                                                          INPUT 0,
                                                                          INPUT 0,
                                                                          INPUT 0,
                                                                          INPUT aux_cdhisdeb,
                                                                          INPUT tt-tbtransf_trans_pend.dtdebito,
                                                                          INPUT tt-tbtransf_trans_pend.vltransferencia,
                                                                          INPUT ?,
                                                                          INPUT crapcop.cdbcoctl,
                                                                          INPUT tt-tbtransf_trans_pend.cdagencia_coop_destino,
                                                                          INPUT tt-tbtransf_trans_pend.nrconta_destino, 
                                                                          INPUT 0,            /** CDCOPTFN **/
                                                                          INPUT 0,            /** CDAGETFN **/
                                                                          INPUT 0,            /** NRTERFIN **/
                                                                          INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                          INPUT 0, /** IDTITDDA **/
                                                                          INPUT tt-tbgen_trans_pend.cdtransacao_pendente,
                                                                          INPUT tt-tbtransf_trans_pend.indtipo_cartao,
                                                                          INPUT tt-tbtransf_trans_pend.nrcartao,
                                                                          INPUT 0,   /* cdfinali */
                                                                          INPUT ' ', /* dstransf */
                                                                          INPUT ' ', /* dshistor */                                                           
                                                                          INPUT par_iptransa,
																		                                      INPUT ' ', /* par_cdctrlcs */
                                                                          INPUT par_flmobile,
                                                                          INPUT par_iddispos,
                                                                          
                                                                         OUTPUT aux_msgofatr,
                                                                         OUTPUT aux_cdempcon,
                                                                         OUTPUT aux_cdsegmto,
                                                                         OUTPUT aux_dstransa, 
                                                                         OUTPUT aux_dscritic).
                                                
                                                IF  RETURN-VALUE <> "OK"  THEN
                                                    DO:
                                                        /* Gerar log das teds com erro */
                                                        RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                                 INPUT "cadastrar-agendamento",
                                                                                 INPUT "b1wgen0015",
                                                                                 INPUT par_dtmvtolt,
                                                                                 INPUT par_nrdconta,
                                                                                 INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                                 INPUT crapcop.cdbcoctl, /* cddbanco */
                                                                                 INPUT tt-tbtransf_trans_pend.cdagencia_coop_destino, /* ag. destino */
                                                                                 INPUT tt-tbtransf_trans_pend.nrconta_destino, /* conta destino */
                                                                                 INPUT "", /* nome titular */
                                                                                 INPUT 0, /* cpf favorecido */
                                                                                 INPUT 0, /* inpessoa favorecido */
                                                                                 INPUT 0, /* intipcta favorecido */
                                                                                 INPUT tt-tbtransf_trans_pend.vltransferencia,
                                                                                 INPUT "",
                                                                                 INPUT tt-tbgen_trans_pend.tptransacao,
                                                                                 INPUT 0,
                                                                                 INPUT aux_dscritic).
                                                        
                                                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                                INPUT par_cdoperad,
                                                                                INPUT aux_dscritic,
                                                                                INPUT aux_dsorigem,
                                                                                INPUT aux_dstransa,
                                                                                INPUT FALSE,
                                                                                INPUT par_nmdatela,
                                                                                INPUT par_nrdconta,
                                                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                                INPUT FALSE,
                                                                                INPUT par_indvalid,
                                                                                INPUT tt-tbtransf_trans_pend.dtdebito,
                                                                                INPUT tt-tbtransf_trans_pend.vltransferencia,
                                                                                INPUT aux_conttran).
                                                        
                                                        IF par_indvalid = 1 THEN
                                                            ASSIGN par_flgaviso = TRUE.
                                    
                                                        UNDO TRANSACAO, LEAVE TRANSACAO.
                                                    END.
                                                
                                            END.
                                    END.
                                ELSE /* Transferência Intercooperativa */
                                    DO:
                                        IF tt-tbtransf_trans_pend.idagendamento = 1 THEN
                                            DO:
                                                RUN executa-transferencia-intercooperativa IN h-b1wgen0015 (INPUT par_cdcooper,
                                                                                                            INPUT par_cdagenci,
                                                                                                            INPUT par_nrdcaixa,
                                                                                                            INPUT par_cdoperad,
                                                                                                            INPUT par_idorigem,
                                                                                                            INPUT par_dtmvtolt,
                                                                                                            INPUT tt-tbtransf_trans_pend.idagendamento,
                                                                                                            INPUT par_nrdconta,
                                                                                                            INPUT par_idseqttl,
                                                                                                            INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                                                            INPUT crapcop.cdbcoctl,
                                                                                                            INPUT tt-tbtransf_trans_pend.cdagencia_coop_destino,
                                                                                                            INPUT tt-tbtransf_trans_pend.nrconta_destino,
                                                                                                            INPUT tt-tbtransf_trans_pend.vltransferencia,
                                                                                                            INPUT 0, /* nrsequni */
                                                                                                            INPUT 0, /* cdcoptfn */
                                                                                                            INPUT 0, /* nrterfin */
                                                                                                            INPUT tt-tbtransf_trans_pend.indmobile,
                                                                                                            INPUT tt-tbtransf_trans_pend.indtipo_cartao,
                                                                                                            INPUT tt-tbtransf_trans_pend.nrcartao,
                                                                                                           OUTPUT glb_dsprotoc,
                                                                                                           OUTPUT aux_dscritic,
                                                                                                           OUTPUT aux_nrdocmto, /* Docmto Debt. */
                                                                                                           OUTPUT aux_nrdoccre, /* Docmto Cred. */
                                                                                                           OUTPUT aux_cdlantar).
                                    
                                                IF RETURN-VALUE <> "OK" THEN
                                                    DO:
                                                        IF VALID-HANDLE(h-b1wgen0015) THEN
                                                            DELETE PROCEDURE h-b1wgen0015.
                                                    
                                                        /* Gerar log das teds com erro */
                                                        RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                                 INPUT "executa-transferencia-intercooperativa",
                                                                                 INPUT "b1wgen0015",
                                                                                 INPUT par_dtmvtolt,
                                                                                 INPUT par_nrdconta,
                                                                                 INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                                 INPUT crapcop.cdbcoctl, /* cddbanco */
                                                                                 INPUT tt-tbtransf_trans_pend.cdagencia_coop_destino, /* ag. destino */
                                                                                 INPUT tt-tbtransf_trans_pend.nrconta_destino, /* conta destino */
                                                                                 INPUT "", /* nome titular */
                                                                                 INPUT 0, /* cpf favorecido */
                                                                                 INPUT 0, /* inpessoa favorecido */
                                                                                 INPUT 0, /* intipcta favorecido */
                                                                                 INPUT tt-tbtransf_trans_pend.vltransferencia,
                                                                                 INPUT "",
                                                                                 INPUT tt-tbgen_trans_pend.tptransacao,
                                                                                 INPUT 0,
                                                                                 INPUT aux_dscritic).
            
                                                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                                INPUT par_cdoperad,
                                                                                INPUT aux_dscritic,
                                                                                INPUT aux_dsorigem,
                                                                                INPUT aux_dstransa,
                                                                                INPUT FALSE,
                                                                                INPUT par_nmdatela,
                                                                                INPUT par_nrdconta,
                                                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                                INPUT FALSE,
                                                                                INPUT par_indvalid,
                                                                                INPUT tt-tbtransf_trans_pend.dtdebito,
                                                                                INPUT tt-tbtransf_trans_pend.vltransferencia,
                                                                                INPUT aux_conttran).
                                                    
                                                        IF par_indvalid = 1  THEN
                                                            ASSIGN par_flgaviso = TRUE.
                                                    
                                                        UNDO TRANSACAO, LEAVE TRANSACAO.
                                                    END.
                                            END.
                                        ELSE
                                            DO:
                                                RUN cadastrar-agendamento(INPUT par_cdcooper,
                                                                          INPUT par_cdagenci,
                                                                          INPUT par_nrdcaixa,
                                                                          INPUT par_cdoperad,
                                                                          INPUT par_nrdconta,
                                                                          INPUT par_idseqttl,
                                                                          INPUT par_dtmvtolt,
                                                                          /* Projeto 363 - Novo ATM */ 
                                                                          INPUT par_idorigem,
                                                                          INPUT aux_dsorigem,
                                                                          INPUT par_nmdatela,
                                                                          INPUT tt-tbgen_trans_pend.tptransacao, /** PAGAMENTO/TRANSF **/
                                                                          INPUT 0,
                                                                          INPUT '',
                                                                          INPUT '',
                                                                          INPUT 0,
                                                                          INPUT 0,
                                                                          INPUT 0,
                                                                          INPUT 0,
                                                                          INPUT 0,
                                                                          INPUT 1009,
                                                                          INPUT tt-tbtransf_trans_pend.dtdebito,
                                                                          INPUT tt-tbtransf_trans_pend.vltransferencia,
                                                                          INPUT ?,
                                                                          INPUT crapcop.cdbcoctl,
                                                                          INPUT tt-tbtransf_trans_pend.cdagencia_coop_destino,
                                                                          INPUT tt-tbtransf_trans_pend.nrconta_destino, 
                                                                          INPUT 0,            /** CDCOPTFN **/
                                                                          INPUT 0,            /** CDAGETFN **/
                                                                          INPUT 0,            /** NRTERFIN **/
                                                                          INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                          INPUT 0, /** IDTITDDA **/
                                                                          INPUT tt-tbgen_trans_pend.cdtransacao_pendente,
                                                                          INPUT tt-tbtransf_trans_pend.indtipo_cartao,
                                                                          INPUT tt-tbtransf_trans_pend.nrcartao,
                                                                          INPUT 0,   /* cdfinali */
                                                                          INPUT ' ', /* dstransf */
                                                                          INPUT ' ', /* dshistor */
                                                                          INPUT par_iptransa,
                                                                          INPUT ' ', /* par_cdctrlcs */
                                                                          INPUT par_flmobile,
                                                                          INPUT par_iddispos,
                                                                          
                                                                         OUTPUT aux_msgofatr,
                                                                         OUTPUT aux_cdempcon,
                                                                         OUTPUT aux_cdsegmto,
                                                                         OUTPUT aux_dstransa, 
                                                                         OUTPUT aux_dscritic).
                                                
                                                IF  RETURN-VALUE <> "OK"  THEN
                                                    DO:
                                                        /* Gerar log das teds com erro */
                                                        RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                                 INPUT "cadastrar-agendamento",
                                                                                 INPUT "b1wgen0016",
                                                                                 INPUT par_dtmvtolt,
                                                                                 INPUT par_nrdconta,
                                                                                 INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                                 INPUT crapcop.cdbcoctl, /* cddbanco */
                                                                                 INPUT tt-tbtransf_trans_pend.cdagencia_coop_destino, /* ag. destino */
                                                                                 INPUT tt-tbtransf_trans_pend.nrconta_destino, /* conta destino */
                                                                                 INPUT "", /* nome titular */
                                                                                 INPUT 0, /* cpf favorecido */
                                                                                 INPUT 0, /* inpessoa favorecido */
                                                                                 INPUT 0, /* intipcta favorecido */
                                                                                 INPUT tt-tbtransf_trans_pend.vltransferencia,
                                                                                 INPUT "",
                                                                                 INPUT tt-tbgen_trans_pend.tptransacao,
                                                                                 INPUT 0,
                                                                                 INPUT aux_dscritic).
                                                        
                                                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                                INPUT par_cdoperad,
                                                                                INPUT aux_dscritic,
                                                                                INPUT aux_dsorigem,
                                                                                INPUT aux_dstransa,
                                                                                INPUT FALSE,
                                                                                INPUT par_nmdatela,
                                                                                INPUT par_nrdconta,
                                                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                                INPUT FALSE,
                                                                                INPUT par_indvalid,
                                                                                INPUT tt-tbtransf_trans_pend.dtdebito,
                                                                                INPUT tt-tbtransf_trans_pend.vltransferencia,
                                                                                INPUT aux_conttran).
                                                                                            
                                                        IF par_indvalid = 1 THEN
                                                            ASSIGN par_flgaviso = TRUE.
                                    
                                                        UNDO TRANSACAO, LEAVE TRANSACAO.
                                                    END.
                                            END.
                                    END.
                            END.
                        
                        IF VALID-HANDLE(h-b1wgen0015) THEN
                            DELETE PROCEDURE h-b1wgen0015.

                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                INPUT par_cdoperad,
                                                INPUT aux_dscritic,
                                                INPUT aux_dsorigem,
                                                INPUT aux_dstransa,
                                                INPUT FALSE,
                                                INPUT par_nmdatela,
                                                INPUT par_nrdconta,
                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                INPUT TRUE,
                                                INPUT par_indvalid,
                                                INPUT tt-tbtransf_trans_pend.dtdebito,
                                                INPUT tt-tbtransf_trans_pend.vltransferencia,
                                                INPUT aux_conttran).
                                                    
                	END.
                ELSE IF tt-tbgen_trans_pend.tptransacao = 4 
                     OR tt-tbgen_trans_pend.tptransacao = 22 /*REQ39*/
                     THEN /* TED */
                	DO:
                        ASSIGN aux_vltarifa = 0.

                        FOR FIRST tt-tbspb_trans_pend WHERE tt-tbspb_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK. END.
                        
                        /* VALIDACAO */    
                        IF NOT VALID-HANDLE(h-b1wgen0015)  THEN
                            RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.
                        
                        FIND FIRST tt-vlrdat WHERE tt-vlrdat.dattrans = tt-tbspb_trans_pend.dtdebito NO-LOCK NO-ERROR NO-WAIT.

                        /* Procedimento do internetbank pc_verifica_operacao_prog */
                        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                        RUN STORED-PROCEDURE pc_verifica_operacao_prog
                            aux_handproc = PROC-HANDLE NO-ERROR      
                              (INPUT  par_cdcooper
                              ,INPUT  par_cdagenci
                              ,INPUT  par_nrdcaixa
                              ,INPUT  par_nrdconta
                              ,INPUT  par_idseqttl        
                              ,INPUT  par_dtmvtolt
                              ,INPUT  tt-tbspb_trans_pend.idagendamento
                              ,INPUT  tt-tbspb_trans_pend.dtdebito
                              ,INPUT  IF par_indvalid = 0 AND aux_conttran = 1 AND AVAIL (tt-vlrdat) THEN 
                                          tt-vlrdat.vlronlin
                                      ELSE
                                          tt-tbspb_trans_pend.vlted        /* Valor do TED */                              
                              ,INPUT  tt-tbspb_trans_pend.cdbanco_favorecido /* par_cddbanco */
                              ,INPUT  tt-tbspb_trans_pend.cdagencia_favorecido /* par_cdageban */
                              ,INPUT  tt-tbspb_trans_pend.nrconta_favorecido /* par_nrctatrf */
                              ,INPUT  tt-tbgen_trans_pend.tptransacao /* par_cdtiptra */
                              ,INPUT  par_cdoperad /* par_cdoperad */
                              ,INPUT  tt-tbgen_trans_pend.tptransacao /* par_tpoperac */
                              ,INPUT  1 /* par_flgvalid*/
                              ,INPUT  aux_dsorigem /* par_dsorigem */
                              ,INPUT  par_nrcpfope 
                              ,INPUT  1      /* par_flgctrag */
                              ,INPUT  ""        /* par_nmdatela */
                              ,OUTPUT aux_dstransa
                              ,OUTPUT ""                     /* --> Retorno XML pr_tab_limite      */
                              ,OUTPUT ""                     /* --> Retorno XML pr_tab_internet    */
                              ,OUTPUT 0                     /* --> Retorno pr_cdcritic            */
                              ,OUTPUT "").                  /* --> Retorno pr_dscritic (OK ou NOK)*/

                        IF  ERROR-STATUS:ERROR  THEN DO:
                            DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
                                ASSIGN aux_msgerora = aux_msgerora + 
                                                      ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
                            END.
                                
                            ASSIGN aux_dscritic = "pc_verifica_operacao_prog --> "  +
                                                  "Erro ao executar Stored Procedure: " +
                                                  aux_msgerora.      
                            ASSIGN xml_dsmsgerr = "<dsmsgerr>" + 
                                                       "Erro inesperado. Nao foi possivel efetuar a verificacao." + 
                                                       " Tente novamente ou contacte seu PA" +
                                                  "</dsmsgerr>".                        
                            RUN proc_geracao_log.
                            RETURN "NOK".
                            
                        END. 

                        CLOSE STORED-PROC pc_verifica_operacao_prog
                              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl}}

                        ASSIGN aux_dscritic   = pc_verifica_operacao_prog.pr_dscritic 
                                                WHEN pc_verifica_operacao_prog.pr_dscritic <> ?                               
                               aux_tab_limite = pc_verifica_operacao_prog.pr_tab_limite 
                                                WHEN pc_verifica_operacao_prog.pr_tab_limite <> ? .


                        /* Verificar se retornou critica */
                        IF aux_dscritic <> "" THEN
                        DO:
                            /* Gerar log das teds com erro */
                            RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                     INPUT "verifica_operacao",
                                                     INPUT "b1wgen0016",
                                                     INPUT par_dtmvtolt,
                                                     INPUT par_nrdconta,
                                                     INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                     INPUT tt-tbspb_trans_pend.cdbanco_favorecido, /* cddbanco */
                                                     INPUT tt-tbspb_trans_pend.cdagencia_favorecido, /* ag. destino */
                                                     INPUT tt-tbspb_trans_pend.nrconta_favorecido, /* conta destino */
                                                     INPUT "", /* nome titular */
                                                     INPUT 0, /* cpf favorecido */
                                                     INPUT 0, /* inpessoa favorecido */
                                                     INPUT 0, /* intipcta favorecido */
                                                     INPUT tt-tbspb_trans_pend.vlted,
                                                     INPUT tt-tbspb_trans_pend.dshistorico,
                                                     INPUT tt-tbgen_trans_pend.tptransacao,
                                                     INPUT tt-tbspb_trans_pend.nrispb_banco_favorecido,
                                                     INPUT aux_dscritic).
                            
                            RUN gera_erro_transacao(INPUT par_cdcooper,
                                                    INPUT par_cdoperad,
                                                    INPUT aux_dscritic,
                                                    INPUT aux_dsorigem,
                                                    INPUT aux_dstransa,
                                                    INPUT FALSE,
                                                    INPUT par_nmdatela,
                                                    INPUT par_nrdconta,
                                                    INPUT STRING(ROWID(tbgen_trans_pend)),
                                                    INPUT FALSE,
                                                    INPUT par_indvalid,
                                                    INPUT tt-tbspb_trans_pend.dtdebito,
                                                    INPUT tt-tbspb_trans_pend.vlted,
                                                    INPUT aux_conttran).
                                        
                            IF par_indvalid = 1 THEN
                                ASSIGN par_flgaviso = TRUE.
        
                            UNDO TRANSACAO, LEAVE TRANSACAO.
                        END.



                        IF NOT VALID-HANDLE(h-b1crap20) THEN
                            RUN dbo/b1crap20.p PERSISTENT SET h-b1crap20.

                        RUN busca-tarifa-ted IN h-b1crap20(INPUT par_cdcooper,
                                                           INPUT par_cdagenci,
                                                           INPUT par_nrdconta,
                                                           INPUT tt-tbspb_trans_pend.vlted,
                                                          OUTPUT aux_vltarifa,
                                                          OUTPUT aux_cdhistor,
                                                          OUTPUT aux_cdhisest,
                                                          OUTPUT aux_cdfvlcop,
                                                          OUTPUT aux_mensagem).
                        
                        IF  RETURN-VALUE <> "OK"  THEN
                            DO:
                                IF VALID-HANDLE(h-b1wgen0015)  THEN
                                    DELETE PROCEDURE h-b1wgen0015.

                                IF VALID-HANDLE(h-b1crap20) THEN
                                    DELETE PROCEDURE h-b1crap20.

                                /* Gerar log das teds com erro */
                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                         INPUT "busca-tarifa-ted",
                                                         INPUT "h-b1crap20",
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_nrdconta,
                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                         INPUT tt-tbspb_trans_pend.cdbanco_favorecido, /* cddbanco */
                                                         INPUT tt-tbspb_trans_pend.cdagencia_favorecido, /* ag. destino */
                                                         INPUT tt-tbspb_trans_pend.nrconta_favorecido, /* conta destino */
                                                         INPUT "", /* nome titular */
                                                         INPUT 0, /* cpf favorecido */
                                                         INPUT 0, /* inpessoa favorecido */
                                                         INPUT 0, /* intipcta favorecido */
                                                         INPUT tt-tbspb_trans_pend.vlted,
                                                         INPUT tt-tbspb_trans_pend.dshistorico,
                                                         INPUT tt-tbspb_trans_pend.cdfinalidade,
                                                         INPUT tt-tbspb_trans_pend.nrispb_banco_favorecido,
                                                         INPUT aux_dscritic).
                                
                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                        INPUT par_cdoperad,
                                                        INPUT aux_dscritic,
                                                        INPUT aux_dsorigem,
                                                        INPUT aux_dstransa,
                                                        INPUT FALSE,
                                                        INPUT par_nmdatela,
                                                        INPUT par_nrdconta,
                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                        INPUT FALSE,
                                                        INPUT par_indvalid,
                                                        INPUT tt-tbspb_trans_pend.dtdebito,
                                                        INPUT tt-tbspb_trans_pend.vlted,
                                                        INPUT aux_conttran).
            
                                IF par_indvalid = 1 THEN
                                    ASSIGN par_flgaviso = TRUE.
            
                                UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.

                        IF VALID-HANDLE(h-b1crap20) THEN
                            DELETE PROCEDURE h-b1crap20.
                        
                        /* VALIDACAO */    
                        IF NOT VALID-HANDLE(h-b1wgen0015)  THEN
                            RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.

                        RUN verifica-dados-ted IN h-b1wgen0015(INPUT par_cdcooper,
                                                               INPUT par_cdagenci,
                                                               INPUT par_nrdcaixa,
                                                               INPUT par_idorigem,
                                                               INPUT par_nrdconta,
                                                               INPUT par_idseqttl,
                                                               INPUT tt-tbspb_trans_pend.cdbanco_favorecido,
                                                               INPUT tt-tbspb_trans_pend.cdagencia_favorecido,
                                                               INPUT tt-tbspb_trans_pend.nrconta_favorecido,
                                                               INPUT tt-tbspb_trans_pend.nmtitula_favorecido,
                                                               INPUT tt-tbspb_trans_pend.nrcpfcnpj_favorecido,
                                                               INPUT tt-tbspb_trans_pend.tppessoa_favorecido,
                                                               INPUT tt-tbspb_trans_pend.tpconta_favorecido,
                                                               INPUT tt-tbspb_trans_pend.vlted,
                                                               INPUT tt-tbspb_trans_pend.cdfinalidade,
                                                               INPUT tt-tbspb_trans_pend.dshistorico,
                                                               INPUT tt-tbspb_trans_pend.nrispb_banco_favorecido,
                                                               INPUT tt-tbspb_trans_pend.idagenda,
                                                               INPUT tt-tbgen_trans_pend.tptransacao, /*REQ39*/
                                                              OUTPUT aux_dstransa,
                                                              OUTPUT aux_dscritic).

                        IF RETURN-VALUE <> "OK"  THEN
                            DO: 
                                IF VALID-HANDLE(h-b1wgen0015)  THEN
                                    DELETE PROCEDURE h-b1wgen0015.

                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                         INPUT "verifica-dados-ted",
                                                         INPUT "b1wgen0015",
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_nrdconta,
                                                         INPUT par_nrcpfope,
                                                         INPUT tt-tbspb_trans_pend.cdbanco_favorecido,
                                                         INPUT tt-tbspb_trans_pend.cdagencia_favorecido,
                                                         INPUT tt-tbspb_trans_pend.nrconta_favorecido,
                                                         INPUT tt-tbspb_trans_pend.nmtitula_favorecido,
                                                         INPUT tt-tbspb_trans_pend.nrcpfcnpj_favorecido,
                                                         INPUT tt-tbspb_trans_pend.tppessoa_favorecido,
                                                         INPUT tt-tbspb_trans_pend.tpconta_favorecido,
                                                         INPUT tt-tbspb_trans_pend.vlted,
                                                         INPUT tt-tbspb_trans_pend.dshistorico,
                                                         INPUT tt-tbspb_trans_pend.cdfinalidade,
                                                         INPUT tt-tbspb_trans_pend.nrispb_banco_favorecido,
                                                         INPUT aux_dscritic).
    
                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                        INPUT par_cdoperad,
                                                        INPUT aux_dscritic,
                                                        INPUT aux_dsorigem,
                                                        INPUT aux_dstransa,
                                                        INPUT FALSE,
                                                        INPUT par_nmdatela,
                                                        INPUT par_nrdconta,
                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                        INPUT FALSE,
                                                        INPUT par_indvalid,
                                                        INPUT tt-tbspb_trans_pend.dtdebito,
                                                        INPUT tt-tbspb_trans_pend.vlted,
                                                        INPUT aux_conttran).
                                                                
                                IF par_indvalid = 1 THEN
                                    ASSIGN par_flgaviso = TRUE.
        
                                UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.

					    IF aux_conttran = 1 AND par_indvalid = 1 THEN
						   DO:
						      /* Confirmando a efetivacao */
						      IF tt-tbspb_trans_pend.idagendamento = 1 THEN
							     DO:
								    /* VALIDACAO */    
									IF NOT VALID-HANDLE(h-b1wgen0015)  THEN
										RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.

									RUN executa-envio-ted IN h-b1wgen0015 (INPUT par_cdcooper,
																		   INPUT par_cdagenci, 
																		   INPUT par_nrdcaixa, 
																		   INPUT par_cdoperad, 
																		   INPUT par_idorigem, 
																		   INPUT par_dtmvtolt,
																		   INPUT par_nrdconta,
																		   INPUT par_idseqttl,
																		   INPUT tt-tbgen_trans_pend.nrcpf_operador,
																		   INPUT tt-tbspb_trans_pend.cdbanco_favorecido,
																		   INPUT tt-tbspb_trans_pend.cdagencia_favorecido,
																		   INPUT tt-tbspb_trans_pend.nrconta_favorecido,
																		   INPUT tt-tbspb_trans_pend.nmtitula_favorecido,
																		   INPUT tt-tbspb_trans_pend.nrcpfcnpj_favorecido,
																		   INPUT tt-tbspb_trans_pend.tppessoa_favorecido,
																		   INPUT tt-tbspb_trans_pend.tpconta_favorecido,
																		   INPUT tt-tbspb_trans_pend.vlted,
																		   INPUT tt-tbspb_trans_pend.dscodigo_identificador,
																		   INPUT tt-tbspb_trans_pend.cdfinalidade,
																		   INPUT tt-tbspb_trans_pend.dshistorico,
																		   INPUT tt-tbspb_trans_pend.nrispb_banco_favorecido,
																		   INPUT INT(par_flmobile), /* flgmobile */
																		   INPUT tt-tbspb_trans_pend.idagendamento,
                                       INPUT par_iptransa,
                                       INPUT aux_dstransa,
                                       INPUT par_iddispos,
                                                          
                                      OUTPUT glb_dsprotoc,
																		  OUTPUT aux_dscritic,
																		  OUTPUT TABLE tt-protocolo-ted).
                                                 
									IF  RETURN-VALUE <> "OK"  THEN
										DO:
											IF VALID-HANDLE(h-b1wgen0015) THEN
												DELETE PROCEDURE h-b1wgen0015.
                                                                                     
											/* Gerar log das teds com erro */
											RUN gera_arquivo_log_ted(INPUT par_cdcooper,
																	 INPUT "executa-envio-ted",
																	 INPUT "b1wgen0015",
																	 INPUT par_dtmvtolt,
																	 INPUT par_nrdconta,
																	 INPUT tt-tbgen_trans_pend.nrcpf_operador,
																	 INPUT tt-tbspb_trans_pend.cdbanco_favorecido,
																	 INPUT tt-tbspb_trans_pend.cdagencia_favorecido,
																	 INPUT tt-tbspb_trans_pend.nrconta_favorecido,
																	 INPUT tt-tbspb_trans_pend.nmtitula_favorecido,
																	 INPUT tt-tbspb_trans_pend.nrcpfcnpj_favorecido,
																	 INPUT tt-tbspb_trans_pend.tppessoa_favorecido,
																	 INPUT tt-tbspb_trans_pend.tpconta_favorecido,
																	 INPUT tt-tbspb_trans_pend.vlted,
																	 INPUT tt-tbspb_trans_pend.dshistorico,
																	 INPUT tt-tbspb_trans_pend.cdfinalidade,
																	 INPUT tt-tbspb_trans_pend.nrispb_banco_favorecido,
																	 INPUT aux_dscritic).
        
											RUN gera_erro_transacao(INPUT par_cdcooper,
															INPUT par_cdoperad,
															INPUT aux_dscritic,
															INPUT aux_dsorigem,
															INPUT aux_dstransa,
															INPUT FALSE,
															INPUT par_nmdatela,
															INPUT par_nrdconta,
															INPUT STRING(ROWID(tbgen_trans_pend)),
															INPUT FALSE,
															INPUT par_indvalid,
															INPUT TODAY,
															INPUT 0,
															INPUT aux_conttran).
            
											IF par_indvalid = 1 THEN
												ASSIGN par_flgaviso = TRUE.

											UNDO TRANSACAO, LEAVE TRANSACAO.
										END. 

				
								 END.
							  ELSE
							     DO:
								     RUN cadastrar-agendamento(INPUT par_cdcooper,
                                                               INPUT par_cdagenci,         /** PAC      **/
                                                               INPUT par_nrdcaixa,        /** CAIXA    **/
                                                               INPUT par_cdoperad,      /** OPERADOR **/
                                                               INPUT par_nrdconta,
                                                               INPUT par_idseqttl,
                                                               INPUT par_dtmvtolt,
                                                               /* Projeto 363 - Novo ATM */ 
                                                               INPUT par_idorigem,
                                                               INPUT aux_dsorigem,
                                                               INPUT par_nmdatela,
                                                               INPUT tt-tbgen_trans_pend.tptransacao, /** PAGAMENTO/TRANSF **/
                                                               INPUT 0,
                                                               INPUT '',
                                                               INPUT '',
                                                               INPUT 0,
                                                               INPUT 0,
                                                               INPUT 0,
                                                               INPUT 0,
                                                               INPUT 0,
                                                               INPUT 555,
                                                               INPUT tt-tbspb_trans_pend.dtdebito,
                                                               INPUT tt-tbspb_trans_pend.vlted,
                                                               INPUT ?,
                                                               INPUT tt-tbspb_trans_pend.cdbanco_favorecido,
                                                               INPUT tt-tbspb_trans_pend.cdagencia_favorecido,
                                                               INPUT tt-tbspb_trans_pend.nrconta_favorecido, 
                                                               INPUT 0,            /** CDCOPTFN **/
                                                               INPUT 0,            /** CDAGETFN **/
                                                               INPUT 0,            /** NRTERFIN **/
                                                               INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                               INPUT 0, /** IDTITDDA **/
                                                               INPUT tt-tbspb_trans_pend.cdtransacao_pendente,
                                                               INPUT 0,
                                                               INPUT 0,
                                              
                                                               INPUT tt-tbspb_trans_pend.cdfinalidade,
                                                               INPUT tt-tbspb_trans_pend.dscodigo_identificador,
                                                               INPUT tt-tbspb_trans_pend.dshistorico,                                                               
                                                               INPUT par_iptransa,
                                                               INPUT '', /**par_cdctrlcs*/
                                                               INPUT par_flmobile,
                                                               INPUT par_iddispos,
                                                                               
                                                              OUTPUT aux_msgofatr,
                                                              OUTPUT aux_cdempcon,
                                                              OUTPUT aux_cdsegmto,
                                                              OUTPUT aux_dstransa, 
                                                              OUTPUT aux_dscritic).
                                     
                                     IF  RETURN-VALUE <> "OK"  THEN
                                         DO:
                                             /* Gerar log das teds com erro */
                                             RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                      INPUT "cadastrar-agendamento",
                                                                      INPUT "b1wgen0015",
                                                                      INPUT par_dtmvtolt,
                                                                      INPUT par_nrdconta,
                                                                      INPUT tt-tbgen_trans_pend.nrcpf_operador,
																		INPUT tt-tbspb_trans_pend.cdbanco_favorecido,
																		INPUT tt-tbspb_trans_pend.cdagencia_favorecido,
																		INPUT tt-tbspb_trans_pend.nrconta_favorecido,
																		INPUT tt-tbspb_trans_pend.nmtitula_favorecido,
																		INPUT tt-tbspb_trans_pend.nrcpfcnpj_favorecido,
																		INPUT tt-tbspb_trans_pend.tppessoa_favorecido,
																		INPUT tt-tbspb_trans_pend.tpconta_favorecido,
																		INPUT tt-tbspb_trans_pend.vlted,
																		INPUT tt-tbspb_trans_pend.dshistorico,
																		INPUT tt-tbspb_trans_pend.cdfinalidade,
																		INPUT tt-tbspb_trans_pend.nrispb_banco_favorecido,
                                                                      INPUT aux_dscritic).
                                             
                                             RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                     INPUT par_cdoperad,
                                                                     INPUT aux_dscritic,
                                                                     INPUT aux_dsorigem,
                                                                     INPUT aux_dstransa,
                                                                     INPUT FALSE,
                                                                     INPUT par_nmdatela,
                                                                     INPUT par_nrdconta,
                                                                     INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                     INPUT FALSE,
                                                                     INPUT par_indvalid,
                                                                     INPUT tt-tbspb_trans_pend.dtdebito,
                                                                     INPUT tt-tbspb_trans_pend.vlted,
                                                                     INPUT aux_conttran).
                                             
                                             IF par_indvalid = 1 THEN
                                                 ASSIGN par_flgaviso = TRUE.
                                    
                                             UNDO TRANSACAO, LEAVE TRANSACAO.
                                         END.

								 END.

						   END.

                        IF aux_conttran = 1 AND par_indvalid = 0 THEN
                            DO:
                                FIND FIRST tt-vlrdat WHERE tt-vlrdat.dattrans = tt-tbspb_trans_pend.dtdebito EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin + aux_vltarifa.
                            END.

                        IF VALID-HANDLE(h-b1wgen0015) THEN
                            DELETE PROCEDURE h-b1wgen0015.
                            
                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                INPUT par_cdoperad,
                                                INPUT aux_dscritic,
                                                INPUT aux_dsorigem,
                                                INPUT aux_dstransa,
                                                INPUT FALSE,
                                                INPUT par_nmdatela,
                                                INPUT par_nrdconta,
                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                INPUT TRUE,
                                                INPUT par_indvalid,
                                                INPUT tt-tbspb_trans_pend.dtdebito,
                                                INPUT tt-tbspb_trans_pend.vlted,
                                                INPUT aux_conttran).
                                                
                	END.
                ELSE IF tt-tbgen_trans_pend.tptransacao = 2 THEN /* Pagamentos */
                	DO: 
                        
                        FOR FIRST tt-tbpagto_trans_pend WHERE tt-tbpagto_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK. END.

                        FIND FIRST tt-vlrdat WHERE tt-vlrdat.dattrans = tt-tbpagto_trans_pend.dtdebito NO-LOCK NO-ERROR NO-WAIT.


                        /* Procedimento do internetbank pc_verifica_operacao_prog */
                        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                        RUN STORED-PROCEDURE pc_verifica_operacao_prog
                            aux_handproc = PROC-HANDLE NO-ERROR      
                              (INPUT  par_cdcooper
                              ,INPUT  par_cdagenci
                              ,INPUT  par_nrdcaixa
                              ,INPUT  par_nrdconta
                              ,INPUT  par_idseqttl        
                              ,INPUT  par_dtmvtolt
                              ,INPUT  tt-tbpagto_trans_pend.idagendamento
                              ,INPUT  tt-tbpagto_trans_pend.dtdebito
                              ,INPUT  IF par_indvalid = 0 AND aux_conttran = 1 AND AVAIL tt-vlrdat THEN 
                                        tt-vlrdat.vlronlin /* Valor Total Composto */
                                      ELSE 
                                        tt-tbpagto_trans_pend.vlpagamento                              
                              ,INPUT  0 /* par_cddbanco */
                              ,INPUT  0 /* par_cdageban */
                              ,INPUT  0 /* par_nrctatrf */
                              ,INPUT  0 /* par_cdtiptra */
                              ,INPUT  par_cdoperad /* par_cdoperad */
                              ,INPUT  IF tt-tbpagto_trans_pend.vlpagamento >= 250000 AND tt-tbpagto_trans_pend.tppagamento <> 3 THEN 
                                        6  /* VR-Boleto */
                                      ELSE
                                        2  /* PAGAMENTO     */ /* par_tpoperac */
                              ,INPUT  1                        /* par_flgvalid*/
                              ,INPUT  aux_dsorigem             /* par_dsorigem */
                              ,INPUT  par_nrcpfope
                              ,INPUT  1         /* par_flgctrag */
                              ,INPUT  ""        /* par_nmdatela */
                              ,OUTPUT aux_dstransa
                              ,OUTPUT ""        /* --> Retorno XML pr_tab_limite      */
                              ,OUTPUT ""        /* --> Retorno XML pr_tab_internet    */
                              ,OUTPUT 0         /* --> Retorno pr_cdcritic            */
                              ,OUTPUT "").      /* --> Retorno pr_dscritic (OK ou NOK)*/

                        IF  ERROR-STATUS:ERROR  THEN DO:
                            DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
                                ASSIGN aux_msgerora = aux_msgerora + 
                                                      ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
                            END.
                                
                            ASSIGN aux_dscritic = "pc_verifica_operacao_prog --> "  +
                                                  "Erro ao executar Stored Procedure: " +
                                                  aux_msgerora.      
                            ASSIGN xml_dsmsgerr = "<dsmsgerr>" + 
                                                       "Erro inesperado. Nao foi possivel efetuar a verificacao." + 
                                                       " Tente novamente ou contacte seu PA" +
                                                  "</dsmsgerr>".                        
                            RUN proc_geracao_log.
                            RETURN "NOK".
                            
                        END. 

                        CLOSE STORED-PROC pc_verifica_operacao_prog
                              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl}}

                        ASSIGN aux_dscritic   = pc_verifica_operacao_prog.pr_dscritic 
                                                WHEN pc_verifica_operacao_prog.pr_dscritic <> ?                               
                               aux_tab_limite = pc_verifica_operacao_prog.pr_tab_limite 
                                                WHEN pc_verifica_operacao_prog.pr_tab_limite <> ? .                      

                        /* Verificar se retornou critica */
                        IF aux_dscritic <> "" THEN
                            DO:                                                                             
                                /* Gerar log das teds com erro */
                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                         INPUT "verifica_operacao",
                                                         INPUT "b1wgen0015",
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_nrdconta,
                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                         INPUT 0,
                                                         INPUT 0,
                                                         INPUT 0,
                                                         INPUT "",
                                                         INPUT 0,
                                                         INPUT 0,
                                                         INPUT 0,
                                                         INPUT tt-tbpagto_trans_pend.vlpagamento,
                                                         INPUT "",
                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                         INPUT 0,
                                                         INPUT aux_dscritic).
    
                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                        INPUT par_cdoperad,
                                                        INPUT aux_dscritic,
                                                        INPUT aux_dsorigem,
                                                        INPUT aux_dstransa,
                                                        INPUT FALSE,
                                                        INPUT par_nmdatela,
                                                        INPUT par_nrdconta,
                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                        INPUT FALSE,
                                                        INPUT par_indvalid,
                                                        INPUT tt-tbpagto_trans_pend.dtdebito,
                                                        INPUT tt-tbpagto_trans_pend.vlpagamento,
                                                        INPUT aux_conttran).
    
                                IF par_indvalid = 1 THEN
                                    ASSIGN par_flgaviso = TRUE.
    
                                UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.
                            
                        IF tt-tbpagto_trans_pend.tppagamento = 3 THEN /*GPS*/
                        DO:
                                                    
                          IF par_indvalid = 1 AND aux_conttran = 1 THEN
                          DO:

                            /* Procedimento do internetbank pc_gps_pgt_aprovado */
                            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                              RUN STORED-PROCEDURE pc_gps_pgt_aprovado aux_handproc = PROC-HANDLE NO-ERROR
                                                  (INPUT par_cdcooper,
                                                   INPUT par_nrdconta,
                                                   INPUT tt-tbgen_trans_pend.cdtransacao_pendente,
                                                   INPUT tt-tbpagto_trans_pend.idagendamento,
                                                   INPUT INT(par_flmobile),
                                                   INPUT par_iptransa,
                                                   INPUT par_iddispos,                                                   
                                                   OUTPUT 0,
                                                   OUTPUT "").
                             CLOSE STORED-PROC pc_gps_pgt_aprovado
                              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                             ASSIGN aux_dscritic = ""
                                    aux_dscritic = pc_gps_pgt_aprovado.pr_dscritic1
                                                  WHEN pc_gps_pgt_aprovado.pr_dscritic1 <> ?.
                          
                           { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl}}
                             /* Verificar se retornou critica */
                            IF aux_dscritic <> "" THEN
                            DO:        
                               
                              /* Gerar log das teds com erro */
                              RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                       INPUT "pc_gps_pgt_aprovado",
                                                       INPUT "b1wgen0016",
                                                       INPUT par_dtmvtolt,
                                                       INPUT par_nrdconta,
                                                       INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                       INPUT 0,
                                                       INPUT 0,
                                                       INPUT 0,
                                                       INPUT "",
                                                       INPUT 0,
                                                       INPUT 0,
                                                       INPUT 0,
                                                       INPUT tt-tbpagto_trans_pend.vlpagamento,
                                                       INPUT "",
                                                       INPUT tt-tbgen_trans_pend.tptransacao,
                                                       INPUT 0,
                                                       INPUT aux_dscritic).
    
                               RUN gera_erro_transacao(INPUT par_cdcooper,
                                                       INPUT par_cdoperad,
                                                       INPUT aux_dscritic,
                                                       INPUT aux_dsorigem,
                                                       INPUT aux_dstransa,
                                                       INPUT FALSE,
                                                       INPUT par_nmdatela,
                                                       INPUT par_nrdconta,
                                                       INPUT STRING(ROWID(tbgen_trans_pend)),
                                                       INPUT FALSE,
                                                       INPUT par_indvalid,
                                                       INPUT tt-tbpagto_trans_pend.dtdebito,
                                                       INPUT tt-tbpagto_trans_pend.vlpagamento,
                                                       INPUT aux_conttran).
  
                              IF par_indvalid = 1 THEN
                                  ASSIGN par_flgaviso = TRUE.
  
                              UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.
                          END.
                            

                          IF par_indvalid = 0 AND aux_conttran = 1 THEN
                          DO:
                                                      
                            /* Procedimento do internetbank pc_gps_verificar_lancamento */
                            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                              RUN STORED-PROCEDURE pc_gps_verificar_lancamento aux_handproc = PROC-HANDLE NO-ERROR
                                                  (INPUT par_cdcooper,
                                                   INPUT par_nrdconta,
                                                   INPUT par_dtmvtolt,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT tt-tbgen_trans_pend.cdtransacao_pendente,
                                                   INPUT "",
                                                   INPUT 0,
                                                   INPUT "",
                                                   INPUT 0,
                                                   OUTPUT 0,
                                                   OUTPUT "").
                              CLOSE STORED-PROC pc_gps_verificar_lancamento
                                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                                
                            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl}}
                            
                              ASSIGN aux_dscritic = ""
                                     aux_dscritic = pc_gps_verificar_lancamento.pr_dscritic
                                                   WHEN pc_gps_verificar_lancamento.pr_dscritic <> ?.
                            
                            /* Verificar se retornou critica */
                            IF aux_dscritic <> "" THEN
                            DO:        
                               
                              /* Gerar log das teds com erro */
                              RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                       INPUT "pc_gps_verificar_lancamento",
                                                       INPUT "b1wgen0016",
                                                       INPUT par_dtmvtolt,
                                                       INPUT par_nrdconta,
                                                       INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                       INPUT 0,
                                                       INPUT 0,
                                                       INPUT 0,
                                                       INPUT "",
                                                       INPUT 0,
                                                       INPUT 0,
                                                       INPUT 0,
                                                       INPUT tt-tbpagto_trans_pend.vlpagamento,
                                                       INPUT "",
                                                       INPUT tt-tbgen_trans_pend.tptransacao,
                                                       INPUT 0,
                                                       INPUT aux_dscritic).
    
                              RUN gera_erro_transacao(INPUT par_cdcooper,
                                                      INPUT par_cdoperad,
                                                      INPUT aux_dscritic,
                                                      INPUT aux_dsorigem,
                                                      INPUT aux_dstransa,
                                                      INPUT FALSE,
                                                      INPUT par_nmdatela,
                                                      INPUT par_nrdconta,
                                                      INPUT STRING(ROWID(tbgen_trans_pend)),
                                                      INPUT FALSE,
                                                      INPUT par_indvalid,
                                                      INPUT tt-tbpagto_trans_pend.dtdebito,
                                                      INPUT tt-tbpagto_trans_pend.vlpagamento,
                                                      INPUT aux_conttran).
  
                              UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.
                          END.



                        END.
                            
                        IF tt-tbpagto_trans_pend.tppagamento = 1 THEN
                            DO:
                                ASSIGN aux_lindigi1 = DECI(SUBSTR(tt-tbpagto_trans_pend.dslinha_digitavel,1,11) + 
                                                           SUBSTR(tt-tbpagto_trans_pend.dslinha_digitavel,13,1))
                                       aux_lindigi2 = DECI(SUBSTR(tt-tbpagto_trans_pend.dslinha_digitavel,15,11) + 
                                                           SUBSTR(tt-tbpagto_trans_pend.dslinha_digitavel,27,1))
                                       aux_lindigi3 = DECI(SUBSTR(tt-tbpagto_trans_pend.dslinha_digitavel,29,11) + 
                                                           SUBSTR(tt-tbpagto_trans_pend.dslinha_digitavel,41,1))
                                       aux_lindigi4 = DECI(SUBSTR(tt-tbpagto_trans_pend.dslinha_digitavel,43,11) + 
                                                           SUBSTR(tt-tbpagto_trans_pend.dslinha_digitavel,55,1))
                                       aux_dtvencto = tt-tbpagto_trans_pend.dtvencimento
                                       aux_vllantra = tt-tbpagto_trans_pend.vlpagamento
                                       aux_cdbarras = tt-tbpagto_trans_pend.dscodigo_barras.

                                RUN verifica_convenio(INPUT par_cdcooper,
                                                      INPUT par_nrdconta,
                                                      INPUT par_idseqttl,
                                                      INPUT tt-tbpagto_trans_pend.idagendamento,
                                                      INPUT-OUTPUT aux_lindigi1,
                                                      INPUT-OUTPUT aux_lindigi2,
                                                      INPUT-OUTPUT aux_lindigi3,
                                                      INPUT-OUTPUT aux_lindigi4,
                                                      INPUT-OUTPUT aux_cdbarras,
                                                      INPUT-OUTPUT aux_dtvencto,
                                                      INPUT-OUTPUT aux_vllantra,
                                                      INPUT        tt-tbpagto_trans_pend.dtdebito,
                                                      INPUT        par_idorigem, /* INTERNET */
                                                      INPUT 1, /* nao validar */
                                                     OUTPUT aux_nmconban,
                                                     OUTPUT aux_cdseqfat,
                                                     OUTPUT aux_vlrdocum,
                                                     OUTPUT aux_nrdigfat,
                                                     OUTPUT aux_dstransa,
                                                     OUTPUT aux_dscritic).
            
                                IF RETURN-VALUE <> "OK"  THEN
                                    DO: 
                                        RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                 INPUT "verifica_convenio",
                                                                 INPUT "b1wgen0016",
                                                                 INPUT par_dtmvtolt,
                                                                 INPUT par_nrdconta,
                                                                 INPUT par_nrcpfope,
                                                                 INPUT 0, /* cddbanco */
                                                                 INPUT 0, /* ag. destino */
                                                                 INPUT 0, /* conta destino */
                                                                 INPUT "", /* nome titular */
                                                                 INPUT 0, /* cpf favorecido */
                                                                 INPUT 0, /* inpessoa favorecido */
                                                                 INPUT 0, /* intipcta favorecido */
                                                                 INPUT tt-tbpagto_trans_pend.vlpagamento,
                                                                 INPUT tt-tbpagto_trans_pend.dtdebito,
                                                                 INPUT tt-tbgen_trans_pend.tptransacao,
                                                                 INPUT 0, /* nrispbif */
                                                                 INPUT aux_dscritic).
            
                                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                INPUT par_cdoperad,
                                                                INPUT aux_dscritic,
                                                                INPUT aux_dsorigem,
                                                                INPUT aux_dstransa,
                                                                INPUT FALSE,
                                                                INPUT par_nmdatela,
                                                                INPUT par_nrdconta,
                                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                INPUT FALSE,
                                                                INPUT par_indvalid,
                                                                INPUT tt-tbpagto_trans_pend.dtdebito,
                                                                INPUT tt-tbpagto_trans_pend.vlpagamento,
                                                                INPUT aux_conttran).
        
                                        IF par_indvalid = 1  THEN
                                            ASSIGN par_flgaviso = TRUE.
            
                                        UNDO TRANSACAO, LEAVE TRANSACAO.
                                    END.
                                
                                IF par_indvalid = 1 AND aux_conttran = 1 AND
                                   tt-tbpagto_trans_pend.idagendamento = 1 THEN /* pagamento na data */
                                    DO:
                                        RUN paga_convenio (INPUT par_cdcooper,
                                                           INPUT par_nrdconta,
                                                           INPUT par_idseqttl,
                                                           INPUT tt-tbpagto_trans_pend.dscodigo_barras,
                                                           INPUT tt-tbpagto_trans_pend.dscedente,
                                                           INPUT aux_cdseqfat,
                                                           INPUT tt-tbpagto_trans_pend.vlpagamento,
                                                           INPUT aux_nrdigfat,
                                                           INPUT FALSE,
                                                           INPUT par_idorigem,
                                                           INPUT 0,
                                                           INPUT 0,
                                                           INPUT 0,
                                                           INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                           INPUT tt-tbpagto_trans_pend.tpcaptura, /* tpcptdoc */
                                                           INPUT par_flmobile,
                                                           INPUT par_iptransa,
                                                           INPUT par_iddispos,                                                             
                                                          OUTPUT aux_dstransa,
                                                          OUTPUT aux_dscritic,
                                                          OUTPUT glb_dsprotoc,
                                                          OUTPUT aux_cdbcoctl,
                                                          OUTPUT aux_cdagectl,
                                                          OUTPUT aux_msgofatr,
                                                          OUTPUT aux_cdempcon,
                                                          OUTPUT aux_cdsegmto).
        
                                        IF RETURN-VALUE <> "OK"  THEN
                                            DO:
                                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                         INPUT "paga_convenio",
                                                                         INPUT "b1wgen0016",
                                                                         INPUT par_dtmvtolt,
                                                                         INPUT par_nrdconta,
                                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                         INPUT 0, /* cddbanco */
                                                                         INPUT 0, /* ag. destino */
                                                                         INPUT 0, /* conta destino */
                                                                         INPUT "", /* nome titular */
                                                                         INPUT 0, /* cpf favorecido */
                                                                         INPUT 0, /* inpessoa favorecido */
                                                                         INPUT 0, /* intipcta favorecido */
                                                                         INPUT tt-tbpagto_trans_pend.vlpagamento,
                                                                         INPUT tt-tbpagto_trans_pend.dscedente,
                                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                                         INPUT 0, /* nrispbif */
                                                                         INPUT aux_dscritic).
                
                                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                        INPUT par_cdoperad,
                                                                        INPUT aux_dscritic,
                                                                        INPUT aux_dsorigem,
                                                                        INPUT aux_dstransa,
                                                                        INPUT FALSE,
                                                                        INPUT par_nmdatela,
                                                                        INPUT par_nrdconta,
                                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                        INPUT FALSE,
                                                                        INPUT par_indvalid,
                                                                        INPUT tt-tbpagto_trans_pend.dtdebito,
                                                                        INPUT tt-tbpagto_trans_pend.vlpagamento,
                                                                        INPUT aux_conttran).
        
                                                IF par_indvalid = 1 THEN
                                                    ASSIGN par_flgaviso = TRUE.
                
                                                UNDO TRANSACAO, LEAVE TRANSACAO.
                                            END.
                                    END.
                                
                                IF par_indvalid = 1 AND aux_conttran = 1 AND
                                   tt-tbpagto_trans_pend.idagendamento = 2 THEN /* Agendamento */
                                    DO:
                                        RUN cadastrar-agendamento(INPUT par_cdcooper,
                                                                  INPUT par_cdagenci,         /** PAC      **/
                                                                  INPUT par_nrdcaixa,        /** CAIXA    **/
                                                                  INPUT par_cdoperad,      /** OPERADOR **/
                                                                  INPUT par_nrdconta,
                                                                  INPUT par_idseqttl,
                                                                  INPUT par_dtmvtolt,
                                                                  /* Projeto 363 - Novo ATM */ 
                                                                  INPUT par_idorigem,
                                                                  INPUT aux_dsorigem,
                                                                  INPUT par_nmdatela,
                                                                  INPUT tt-tbgen_trans_pend.tptransacao, /** PAGAMENTO/TRANSF **/
                                                                  INPUT 1,
                                                                  INPUT tt-tbpagto_trans_pend.dscedente,
                                                                  INPUT tt-tbpagto_trans_pend.dscodigo_barras,
                                                                  INPUT DECI(SUBSTR(tt-tbpagto_trans_pend.dslinha_digitavel,1,11) + 
                                                                             SUBSTR(tt-tbpagto_trans_pend.dslinha_digitavel,13,1)),
                                                                  INPUT DECI(SUBSTR(tt-tbpagto_trans_pend.dslinha_digitavel,15,11) + 
                                                                             SUBSTR(tt-tbpagto_trans_pend.dslinha_digitavel,27,1)),
                                                                  INPUT DECI(SUBSTR(tt-tbpagto_trans_pend.dslinha_digitavel,29,11) + 
                                                                             SUBSTR(tt-tbpagto_trans_pend.dslinha_digitavel,41,1)),
                                                                  INPUT DECI(SUBSTR(tt-tbpagto_trans_pend.dslinha_digitavel,43,11) + 
                                                                             SUBSTR(tt-tbpagto_trans_pend.dslinha_digitavel,55,1)),
                                                                  INPUT 0,
                                                                  INPUT 508,
                                                                  INPUT tt-tbpagto_trans_pend.dtdebito,
                                                                  INPUT tt-tbpagto_trans_pend.vlpagamento,
                                                                  INPUT tt-tbpagto_trans_pend.dtvencimento,
                                                                  INPUT 0,
                                                                  INPUT 0,
                                                                  INPUT 0, 
                                                                  INPUT 0,            /** CDCOPTFN **/
                                                                  INPUT 0,            /** CDAGETFN **/
                                                                  INPUT 0,            /** NRTERFIN **/
                                                                  INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                  INPUT tt-tbpagto_trans_pend.idtitulo_dda, /** IDTITDDA **/
                                                                  INPUT tt-tbgen_trans_pend.cdtransacao_pendente,
                                                                  INPUT 0,
                                                                  INPUT 0,
                                                                  INPUT 0,   /* cdfinali */
                                                                  INPUT ' ', /* dstransf */
                                                                  INPUT ' ', /* dshistor */
                                                                  INPUT par_iptransa,
                                                                  INPUT tt-tbpagto_trans_pend.cdctrlcs, /*par_cdctrlcs*/
                                                                  INPUT par_flmobile,
                                                                  INPUT par_iddispos,   
                                                                  
                                                                 OUTPUT aux_msgofatr,
                                                                 OUTPUT aux_cdempcon,
                                                                 OUTPUT aux_cdsegmto,
                                                                 OUTPUT aux_dstransa, 
                                                                 OUTPUT aux_dscritic).
                                            
                                        IF RETURN-VALUE <> "OK" THEN
                                            DO: 
                                                /* Gerar log das teds com erro */
                                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                         INPUT "cadastrar-agendamento",
                                                                         INPUT "b1wgen0016",
                                                                         INPUT par_dtmvtolt,
                                                                         INPUT par_nrdconta,
                                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                         INPUT 0, /* cddbanco */
                                                                         INPUT 0, /* ag. destino */
                                                                         INPUT 0, /* conta destino */
                                                                         INPUT "", /* nome titular */
                                                                         INPUT 0, /* cpf favorecido */
                                                                         INPUT 0, /* inpessoa favorecido */
                                                                         INPUT 0, /* intipcta favorecido */
                                                                         INPUT tt-tbpagto_trans_pend.vlpagamento,
                                                                         INPUT tt-tbpagto_trans_pend.dscedente,
                                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                                         /* Passar o idtitulo_dda, pois o nrispbif estava sendo passsado com 0
                                                                            Logar o IDTITDDA para identificar o titulo que está sendo pago */
                                                                         INPUT tt-tbpagto_trans_pend.idtitulo_dda, /* nrispbif */
                                                                         INPUT aux_dscritic).
                                                
                                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                        INPUT par_cdoperad,
                                                                        INPUT aux_dscritic,
                                                                        INPUT aux_dsorigem,
                                                                        INPUT aux_dstransa,
                                                                        INPUT FALSE,
                                                                        INPUT par_nmdatela,
                                                                        INPUT par_nrdconta,
                                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                        INPUT FALSE,
                                                                        INPUT par_indvalid,
                                                                        INPUT tt-tbpagto_trans_pend.dtdebito,
                                                                        INPUT tt-tbpagto_trans_pend.vlpagamento,
                                                                        INPUT aux_conttran).
                            
                                                IF  par_indvalid = 1  THEN
                                                    ASSIGN par_flgaviso = TRUE.
                            
                                                UNDO TRANSACAO, LEAVE TRANSACAO.
                                            END.
                                        
                                    END.
                            END.            
                            
                        IF tt-tbpagto_trans_pend.tppagamento = 2 THEN
                            DO:
                                ASSIGN aux_lindigi1 = DECI(REPLACE(ENTRY(1,tt-tbpagto_trans_pend.dslinha_digitavel," "),".",""))
                                       aux_lindigi2 = DECI(REPLACE(ENTRY(2,tt-tbpagto_trans_pend.dslinha_digitavel," "),".",""))
                                       aux_lindigi3 = DECI(REPLACE(ENTRY(3,tt-tbpagto_trans_pend.dslinha_digitavel," "),".",""))
                                       aux_lindigi4 = DECI(REPLACE(ENTRY(4,tt-tbpagto_trans_pend.dslinha_digitavel," "),".",""))
                                       aux_lindigi5 = DECI(REPLACE(ENTRY(5,tt-tbpagto_trans_pend.dslinha_digitavel," "),".",""))
                                       aux_vllantra = tt-tbpagto_trans_pend.vlpagamento
                                       aux_cdbarras = tt-tbpagto_trans_pend.dscodigo_barras.

                                RUN verifica_titulo  (INPUT par_cdcooper,
                                                      INPUT par_nrdconta,
                                                      INPUT par_idseqttl,
                                                      INPUT tt-tbpagto_trans_pend.idagendamento,
                                                      INPUT-OUTPUT aux_lindigi1,
                                                      INPUT-OUTPUT aux_lindigi2,
                                                      INPUT-OUTPUT aux_lindigi3,
                                                      INPUT-OUTPUT aux_lindigi4,
                                                      INPUT-OUTPUT aux_lindigi5,
                                                      INPUT-OUTPUT aux_cdbarras,
                                                      INPUT aux_vllantra,
                                                      INPUT tt-tbpagto_trans_pend.dtdebito,
                                                      INPUT par_idorigem, /* INTERNET */
                                                      INPUT 1, /* nao validar */
                                                      INPUT tt-tbpagto_trans_pend.cdctrlcs,
                                                     OUTPUT aux_nmextbcc,
                                                     OUTPUT aux_vlfatura,
                                                     OUTPUT aux_dtdifere, 
                                                     OUTPUT aux_vldifere, 
                                                     OUTPUT aux_nrctacob,    
                                                     OUTPUT aux_insittit,
                                                     OUTPUT aux_intitcop,
                                                     OUTPUT aux_nrcnvcob,
                                                     OUTPUT aux_nrboleto,
                                                     OUTPUT aux_nrdctabb,
                                                     OUTPUT aux_dstransa,
                                                     OUTPUT aux_dscritic,
                                                     OUTPUT aux_cobregis,
                                                     OUTPUT aux_msgalert,
                                                     OUTPUT aux_vlrjuros,
                                                     OUTPUT aux_vlrmulta,
                                                     OUTPUT aux_vldescto,
                                                     OUTPUT aux_vlabatim,
                                                     OUTPUT aux_vloutdeb,
                                                     OUTPUT aux_vloutcre).
            
                                IF RETURN-VALUE <> "OK"  THEN
                                    DO: 
                                        RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                 INPUT "verifica_titulo",
                                                                 INPUT "b1wgen0016",
                                                                 INPUT par_dtmvtolt,
                                                                 INPUT par_nrdconta,
                                                                 INPUT par_nrcpfope,
                                                                 INPUT 0, /* cddbanco */
                                                                 INPUT 0, /* ag. destino */
                                                                 INPUT 0, /* conta destino */
                                                                 INPUT "", /* nome titular */
                                                                 INPUT 0, /* cpf favorecido */
                                                                 INPUT 0, /* inpessoa favorecido */
                                                                 INPUT 0, /* intipcta favorecido */
                                                                 INPUT tt-tbpagto_trans_pend.vlpagamento,
                                                                 INPUT tt-tbpagto_trans_pend.dtdebito,
                                                                 INPUT tt-tbgen_trans_pend.tptransacao,
                                                                 INPUT 0, /* nrispbif */
                                                                 INPUT aux_dscritic).
            
                                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                INPUT par_cdoperad,
                                                                INPUT aux_dscritic,
                                                                INPUT aux_dsorigem,
                                                                INPUT aux_dstransa,
                                                                INPUT FALSE,
                                                                INPUT par_nmdatela,
                                                                INPUT par_nrdconta,
                                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                INPUT FALSE,
                                                                INPUT par_indvalid,
                                                                INPUT tt-tbpagto_trans_pend.dtdebito,
                                                                INPUT tt-tbpagto_trans_pend.vlpagamento,
                                                                INPUT aux_conttran).
        
                                        IF par_indvalid = 1  THEN
                                            ASSIGN par_flgaviso = TRUE.
            
                                        UNDO TRANSACAO, LEAVE TRANSACAO.
                                    END.
                                
                                IF par_indvalid = 1 AND aux_conttran = 1 AND
                                   tt-tbpagto_trans_pend.idagendamento = 1 THEN /* Agendamento */
                                    DO:
                                        RUN paga_titulo (INPUT par_cdcooper,
                                                         INPUT par_nrdconta,
                                                         INPUT par_idseqttl,
                                                         INPUT DECI(REPLACE(ENTRY(1,tt-tbpagto_trans_pend.dslinha_digitavel," "),".","")),
                                                         INPUT DECI(REPLACE(ENTRY(2,tt-tbpagto_trans_pend.dslinha_digitavel," "),".","")),
                                                         INPUT DECI(REPLACE(ENTRY(3,tt-tbpagto_trans_pend.dslinha_digitavel," "),".","")),
                                                         INPUT DECI(REPLACE(ENTRY(4,tt-tbpagto_trans_pend.dslinha_digitavel," "),".","")),
                                                         INPUT DECI(REPLACE(ENTRY(5,tt-tbpagto_trans_pend.dslinha_digitavel," "),".","")),
                                                         INPUT tt-tbpagto_trans_pend.dscodigo_barras,
                                                         INPUT tt-tbpagto_trans_pend.dscedente,
                                                         INPUT tt-tbpagto_trans_pend.vlpagamento,
                                                         INPUT tt-tbpagto_trans_pend.vlpagamento,
                                                         INPUT aux_nrctacob,    
                                                         INPUT aux_insittit,
                                                         INPUT aux_intitcop,
                                                         INPUT aux_nrcnvcob,
                                                         INPUT aux_nrboleto,
                                                         INPUT aux_nrdctabb,
                                                         INPUT tt-tbpagto_trans_pend.idtitulo_dda, /* Nao eh DDA */
                                                         INPUT FALSE,
                                                         INPUT par_idorigem,
                                                         INPUT 0,
                                                         INPUT 0,
                                                         INPUT 0,
                                                         /* cob reg */
                                                         INPUT aux_vlrjuros,
                                                         INPUT aux_vlrmulta,
                                                         INPUT aux_vldescto,
                                                         INPUT aux_vlabatim,
                                                         INPUT aux_vloutdeb,
                                                         INPUT aux_vloutcre,
                                                         /*operadores*/
                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,/* tpcptdoc */
                                                         INPUT tt-tbpagto_trans_pend.tpcaptura,
                                                         INPUT tt-tbpagto_trans_pend.cdctrlcs, /* par_cdctlnpc */                                                         
                                                         INPUT par_flmobile,
                                                         INPUT par_iptransa,                                                         
                                                         INPUT par_iddispos,   
                                                         
                                                        OUTPUT aux_dstransa,
                                                        OUTPUT aux_dscritic,
                                                        OUTPUT glb_dsprotoc,
                                                        OUTPUT aux_cdbcoctl,
                                                        OUTPUT aux_cdagectl).
    
                                        IF  RETURN-VALUE <> "OK"  THEN
                                            DO: 
                                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                         INPUT "paga_titulo",
                                                                         INPUT "b1wgen0016",
                                                                         INPUT par_dtmvtolt,
                                                                         INPUT par_nrdconta,
                                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                         INPUT 0, /* cddbanco */
                                                                         INPUT 0, /* ag. destino */
                                                                         INPUT 0, /* conta destino */
                                                                         INPUT "", /* nome titular */
                                                                         INPUT 0, /* cpf favorecido */
                                                                         INPUT 0, /* inpessoa favorecido */
                                                                         INPUT 0, /* intipcta favorecido */
                                                                         INPUT tt-tbpagto_trans_pend.vlpagamento,
                                                                         INPUT tt-tbpagto_trans_pend.dscedente,
                                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                                         INPUT 0, /* nrispbif */
                                                                         INPUT aux_dscritic).
                                                
                                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                        INPUT par_cdoperad,
                                                                        INPUT aux_dscritic,
                                                                        INPUT aux_dsorigem,
                                                                        INPUT aux_dstransa,
                                                                        INPUT FALSE,
                                                                        INPUT par_nmdatela,
                                                                        INPUT par_nrdconta,
                                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                        INPUT FALSE,
                                                                        INPUT par_indvalid,
                                                                        INPUT tt-tbpagto_trans_pend.dtdebito,
                                                                        INPUT tt-tbpagto_trans_pend.vlpagamento,
                                                                        INPUT aux_conttran).
                
                                                IF par_indvalid = 1 THEN
                                                    ASSIGN par_flgaviso = TRUE.
                
                                                UNDO TRANSACAO, LEAVE TRANSACAO.
                                            END.
                                    END.

                                IF par_indvalid = 1 AND aux_conttran = 1 AND
                                   tt-tbpagto_trans_pend.idagendamento = 2 THEN /* Agendamento */
                                    DO:
                                        RUN cadastrar-agendamento(INPUT par_cdcooper,       
                                                                  INPUT par_cdagenci,         /** PAC      **/
                                                                  INPUT par_nrdcaixa,        /** CAIXA    **/
                                                                  INPUT par_cdoperad,      /** OPERADOR **/
                                                                  INPUT par_nrdconta,
                                                                  INPUT par_idseqttl,
                                                                  INPUT par_dtmvtolt,
                                                                  /* Projeto 363 - Novo ATM */ 
                                                                  INPUT par_idorigem,
                                                                  INPUT aux_dsorigem,
                                                                  INPUT par_nmdatela,
                                                                  INPUT tt-tbgen_trans_pend.tptransacao, /** PAGAMENTO/TRANSF **/
                                                                  INPUT 2,
                                                                  INPUT tt-tbpagto_trans_pend.dscedente,
                                                                  INPUT tt-tbpagto_trans_pend.dscodigo_barras,
                                                                  INPUT DECI(REPLACE(ENTRY(1,tt-tbpagto_trans_pend.dslinha_digitavel," "),".","")),
                                                                  INPUT DECI(REPLACE(ENTRY(2,tt-tbpagto_trans_pend.dslinha_digitavel," "),".","")),
                                                                  INPUT DECI(REPLACE(ENTRY(3,tt-tbpagto_trans_pend.dslinha_digitavel," "),".","")),
                                                                  INPUT DECI(REPLACE(ENTRY(4,tt-tbpagto_trans_pend.dslinha_digitavel," "),".","")),
                                                                  INPUT DECI(REPLACE(ENTRY(5,tt-tbpagto_trans_pend.dslinha_digitavel," "),".","")),
                                                                  INPUT 508,
                                                                  INPUT tt-tbpagto_trans_pend.dtdebito,
                                                                  INPUT tt-tbpagto_trans_pend.vlpagamento,
                                                                  INPUT tt-tbpagto_trans_pend.dtvencimento,
                                                                  INPUT 0,
                                                                  INPUT 0,
                                                                  INPUT 0, 
                                                                  INPUT 0,            /** CDCOPTFN **/
                                                                  INPUT 0,            /** CDAGETFN **/
                                                                  INPUT 0,            /** NRTERFIN **/
                                                                  INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                  INPUT tt-tbpagto_trans_pend.idtitulo_dda, /** IDTITDDA **/
                                                                  INPUT tt-tbgen_trans_pend.cdtransacao_pendente,
                                                                  INPUT 0,
                                                                  INPUT 0,
                                                                  INPUT 0,   /* cdfinali */
                                                                  INPUT ' ', /* dstransf */
                                                                  INPUT ' ', /* dshistor */
                                                                  INPUT par_iptransa,
                                                                  INPUT tt-tbpagto_trans_pend.cdctrlcs,
                                                                  INPUT par_flmobile,
                                                                  INPUT par_iddispos,   
                                                                 OUTPUT aux_msgofatr,
                                                                 OUTPUT aux_cdempcon,
                                                                 OUTPUT aux_cdsegmto,
                                                                 OUTPUT aux_dstransa, 
                                                                 OUTPUT aux_dscritic).
                                            
                                        IF RETURN-VALUE <> "OK" THEN
                                            DO:
                                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                         INPUT "cadastrar-agendamento",
                                                                         INPUT "b1wgen0016",
                                                                         INPUT par_dtmvtolt,
                                                                         INPUT par_nrdconta,
                                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                         INPUT 0, /* cddbanco */
                                                                         INPUT 0, /* ag. destino */
                                                                         INPUT 0, /* conta destino */
                                                                         INPUT "", /* nome titular */
                                                                         INPUT 0, /* cpf favorecido */
                                                                         INPUT 0, /* inpessoa favorecido */
                                                                         INPUT 0, /* intipcta favorecido */
                                                                         INPUT tt-tbpagto_trans_pend.vlpagamento,
                                                                         INPUT tt-tbpagto_trans_pend.dscedente,
                                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                                         /* Passar o idtitulo_dda, pois o nrispbif estava sendo passsado com 0
                                                                            Logar o IDTITDDA para identificar o titulo que está sendo pago */
                                                                         INPUT tt-tbpagto_trans_pend.idtitulo_dda, /* nrispbif */
                                                                         INPUT aux_dscritic).
                                                
                                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                        INPUT par_cdoperad,
                                                                        INPUT aux_dscritic,
                                                                        INPUT aux_dsorigem,
                                                                        INPUT aux_dstransa,
                                                                        INPUT FALSE,
                                                                        INPUT par_nmdatela,
                                                                        INPUT par_nrdconta,
                                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                        INPUT FALSE,
                                                                        INPUT par_indvalid,
                                                                        INPUT tt-tbpagto_trans_pend.dtdebito,
                                                                        INPUT tt-tbpagto_trans_pend.vlpagamento,
                                                                        INPUT aux_conttran).
        
                                                IF  par_indvalid = 1  THEN
                                                    ASSIGN par_flgaviso = TRUE.
                            
                                                UNDO TRANSACAO, LEAVE TRANSACAO.
                                            END.
        
                                    END.
                            END.

                        IF VALID-HANDLE(h-b1wgen0015) THEN
                            DELETE PROCEDURE h-b1wgen0015. 
                            
                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                INPUT par_cdoperad,
                                                INPUT aux_dscritic,
                                                INPUT aux_dsorigem,
                                                INPUT aux_dstransa,
                                                INPUT FALSE,
                                                INPUT par_nmdatela,
                                                INPUT par_nrdconta,
                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                INPUT TRUE,
                                                INPUT par_indvalid,
                                                INPUT tt-tbpagto_trans_pend.dtdebito,
                                                INPUT tt-tbpagto_trans_pend.vlpagamento,
                                                INPUT aux_conttran).
                            
                	END.
                ELSE IF tt-tbgen_trans_pend.tptransacao = 6 THEN /* Pré-Aprovado */
                	DO:
                        FOR FIRST tt-tbepr_trans_pend WHERE tt-tbepr_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK. END.
                        
                        IF NOT VALID-HANDLE(h-b1wgen0188) THEN
                            RUN sistema/generico/procedures/b1wgen0188.p PERSISTENT SET h-b1wgen0188.
                            
                        RUN busca_dados IN h-b1wgen0188(INPUT par_cdcooper,
                                                        INPUT par_cdagenci,
                                                        INPUT par_nrdcaixa,
                                                        INPUT par_cdoperad,
                                                        INPUT par_nmdatela,
                                                        INPUT par_idorigem,
                                                        INPUT par_nrdconta,
                                                        INPUT 1,
                                                        INPUT par_nrcpfope,
                                                       OUTPUT TABLE tt-dados-cpa,
                                                       OUTPUT TABLE tt-erro).
                        IF RETURN-VALUE <> "OK" THEN
                            DO:
                                IF VALID-HANDLE(h-b1wgen0188) THEN
                                    DELETE PROCEDURE h-b1wgen0188.

                                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                                IF  AVAILABLE tt-erro  THEN
                                    ASSIGN aux_dscritic = tt-erro.dscritic.
                                ELSE
                                    ASSIGN aux_dscritic = "Falha na consulta de dados.".
                                
                                /* Gerar log das teds com erro */
                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                         INPUT "busca_dados",
                                                         INPUT "b1wgen0188",
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_nrdconta,
                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                         INPUT 0, /* cddbanco */
                                                         INPUT 0, /* ag. destino */
                                                         INPUT 0, /* conta destino */
                                                         INPUT "", /* nome titular */
                                                         INPUT 0, /* cpf favorecido */
                                                         INPUT 0, /* inpessoa favorecido */
                                                         INPUT 0, /* intipcta favorecido */
                                                         INPUT tt-tbepr_trans_pend.vlemprestimo,
                                                         INPUT "",
                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                         INPUT 0, /* nrispbif */
                                                         INPUT aux_dscritic).
                                
                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                        INPUT par_cdoperad,
                                                        INPUT aux_dscritic,
                                                        INPUT aux_dsorigem,
                                                        INPUT aux_dstransa,
                                                        INPUT FALSE,
                                                        INPUT par_nmdatela,
                                                        INPUT par_nrdconta,
                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                        INPUT FALSE,
                                                        INPUT par_indvalid,
                                                        INPUT tt-tbgen_trans_pend.dtmvtolt,
                                                        INPUT tt-tbepr_trans_pend.vlemprestimo,
                                                        INPUT aux_conttran).
                                
                                IF  par_indvalid = 1  THEN
                                    ASSIGN par_flgaviso = TRUE.
            
                                UNDO TRANSACAO, LEAVE TRANSACAO.
                                
                            END.
                                
                        FOR FIRST tt-dados-cpa NO-LOCK. END.
                        
                        IF NOT AVAIL tt-dados-cpa OR tt-dados-cpa.txmensal <> tt-tbepr_trans_pend.vltaxa_mensal THEN
                            DO:
                                IF VALID-HANDLE(h-b1wgen0188) THEN
                                    DELETE PROCEDURE h-b1wgen0188.

                                ASSIGN aux_dscritic = "1 - As condicoes do credito pre-aprovado nao estao mais disponiveis para contratacao.".

                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                         INPUT "tt-dados-cpa",
                                                         INPUT "b1wgen0016",
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_nrdconta,
                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                         INPUT 0, /* cddbanco */
                                                         INPUT 0, /* ag. destino */
                                                         INPUT 0, /* conta destino */
                                                         INPUT "", /* nome titular */
                                                         INPUT 0, /* cpf favorecido */
                                                         INPUT 0, /* inpessoa favorecido */
                                                         INPUT 0, /* intipcta favorecido */
                                                         INPUT tt-tbepr_trans_pend.vlemprestimo,
                                                         INPUT "",
                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                         INPUT 0, /* nrispbif */
                                                         INPUT aux_dscritic).
                                
                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                        INPUT par_cdoperad,
                                                        INPUT aux_dscritic,
                                                        INPUT aux_dsorigem,
                                                        INPUT aux_dstransa,
                                                        INPUT FALSE,
                                                        INPUT par_nmdatela,
                                                        INPUT par_nrdconta,
                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                        INPUT FALSE,
                                                        INPUT par_indvalid,
                                                        INPUT tt-tbgen_trans_pend.dtmvtolt,
                                                        INPUT tt-tbepr_trans_pend.vlemprestimo,
                                                        INPUT aux_conttran).
            
                                IF  par_indvalid = 1  THEN
                                    ASSIGN par_flgaviso = TRUE.
            
                                UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.
               
                        IF NOT VALID-HANDLE(h-b1wgen0188) THEN
                            RUN sistema/generico/procedures/b1wgen0188.p PERSISTENT SET h-b1wgen0188.

                        RUN valida_dados IN h-b1wgen0188(INPUT par_cdcooper,
                                                         INPUT par_cdagenci,
                                                         INPUT par_nrdcaixa,
                                                         INPUT par_cdoperad,
                                                         INPUT par_nmdatela,
                                                         INPUT par_idorigem,
                                                         INPUT par_nrdconta,
                                                         INPUT 1,
                                                         INPUT tt-tbepr_trans_pend.vlemprestimo,
                                                         INPUT DAY(tt-tbepr_trans_pend.dtprimeiro_vencto),
                                                         INPUT par_nrcpfope,
                                                        OUTPUT TABLE tt-erro).

                        IF RETURN-VALUE <> "OK" THEN
                            DO:
                                IF VALID-HANDLE(h-b1wgen0188) THEN
                                    DELETE PROCEDURE h-b1wgen0188.

                                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                                IF  AVAILABLE tt-erro  THEN
                                    ASSIGN aux_dscritic = tt-erro.dscritic.
                                ELSE
                                    ASSIGN aux_dscritic = "Falha na validacao de dados(b1wgen0188).".
                                
                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                         INPUT "valida_dados",
                                                         INPUT "b1wgen0188",
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_nrdconta,
                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                         INPUT 0, /* cddbanco */
                                                         INPUT 0, /* ag. destino */
                                                         INPUT 0, /* conta destino */
                                                         INPUT "", /* nome titular */
                                                         INPUT 0, /* cpf favorecido */
                                                         INPUT 0, /* inpessoa favorecido */
                                                         INPUT 0, /* intipcta favorecido */
                                                         INPUT tt-tbepr_trans_pend.vlemprestimo,
                                                         INPUT "",
                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                         INPUT 0, /* nrispbif */
                                                         INPUT aux_dscritic).
                                
                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                        INPUT par_cdoperad,
                                                        INPUT aux_dscritic,
                                                        INPUT aux_dsorigem,
                                                        INPUT aux_dstransa,
                                                        INPUT FALSE,
                                                        INPUT par_nmdatela,
                                                        INPUT par_nrdconta,
                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                        INPUT FALSE,
                                                        INPUT par_indvalid,
                                                        INPUT tt-tbgen_trans_pend.dtmvtolt,
                                                        INPUT tt-tbepr_trans_pend.vlemprestimo,
                                                        INPUT aux_conttran).
                               
                                IF  par_indvalid = 1  THEN
                                    ASSIGN par_flgaviso = TRUE.
            
                                UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.

                        IF NOT VALID-HANDLE(h-b1wgen0188) THEN
                            RUN sistema/generico/procedures/b1wgen0188.p PERSISTENT SET h-b1wgen0188.

                        RUN calcula_parcelas_emprestimo IN h-b1wgen0188(INPUT par_cdcooper,
                                                                        INPUT par_cdagenci,
                                                                        INPUT par_nrdcaixa,
                                                                        INPUT par_cdoperad,
                                                                        INPUT par_nmdatela,
                                                                        INPUT par_idorigem,
                                                                        INPUT par_nrdconta,
                                                                        INPUT 1,
                                                                        INPUT par_dtmvtolt,
                                                                        INPUT tt-tbepr_trans_pend.vlemprestimo,
                                                                        INPUT DAY(tt-tbepr_trans_pend.dtprimeiro_vencto),
                                                                       OUTPUT TABLE tt-parcelas-cpa,
                                                                       OUTPUT TABLE tt-erro).

                        IF RETURN-VALUE <> "OK" THEN
                            DO:
                                IF VALID-HANDLE(h-b1wgen0188) THEN
                                    DELETE PROCEDURE h-b1wgen0188.

                                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                                IF  AVAILABLE tt-erro  THEN
                                    ASSIGN aux_dscritic = tt-erro.dscritic.
                                ELSE
                                    ASSIGN aux_dscritic = "Falha no calculo de parcelas de emprestimos.".
                                
                                /* Gerar log das teds com erro */
                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                         INPUT "calcula_parcelas_emprestimo",
                                                         INPUT "b1wgen0188",
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_nrdconta,
                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                         INPUT 0, /* cddbanco */
                                                         INPUT 0, /* ag. destino */
                                                         INPUT 0, /* conta destino */
                                                         INPUT "", /* nome titular */
                                                         INPUT 0, /* cpf favorecido */
                                                         INPUT 0, /* inpessoa favorecido */
                                                         INPUT 0, /* intipcta favorecido */
                                                         INPUT tt-tbepr_trans_pend.vlemprestimo,
                                                         INPUT "",
                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                         INPUT 0, /* nrispbif */
                                                         INPUT aux_dscritic).
                                
                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                        INPUT par_cdoperad,
                                                        INPUT aux_dscritic,
                                                        INPUT aux_dsorigem,
                                                        INPUT aux_dstransa,
                                                        INPUT FALSE,
                                                        INPUT par_nmdatela,
                                                        INPUT par_nrdconta,
                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                        INPUT FALSE,
                                                        INPUT par_indvalid,
                                                        INPUT tt-tbgen_trans_pend.dtmvtolt,
                                                        INPUT tt-tbepr_trans_pend.vlemprestimo,
                                                        INPUT aux_conttran).
            
                                IF  par_indvalid = 1  THEN
                                    ASSIGN par_flgaviso = TRUE.
            
                                UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.

                        FOR FIRST tt-parcelas-cpa WHERE tt-parcelas-cpa.nrparepr = tt-tbepr_trans_pend.nrparcelas
                                                    AND ROUND(tt-parcelas-cpa.vlparepr,2) = tt-tbepr_trans_pend.vlparcela
                                                    AND tt-parcelas-cpa.dtvencto = tt-tbepr_trans_pend.dtprimeiro_vencto
                                                    AND tt-parcelas-cpa.flgdispo = TRUE NO-LOCK: END.

                        IF NOT AVAIL tt-parcelas-cpa THEN
                            DO:
                                IF VALID-HANDLE(h-b1wgen0188) THEN
                                    DELETE PROCEDURE h-b1wgen0188.

                                ASSIGN aux_dscritic = "2 - As condicoes do credito pre-aprovado nao estao mais disponiveis para contratacao.".

                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                         INPUT "tt-parcelas-cpa",
                                                         INPUT "b1wgen0016",
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_nrdconta,
                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                         INPUT 0, /* cddbanco */
                                                         INPUT 0, /* ag. destino */
                                                         INPUT 0, /* conta destino */
                                                         INPUT "", /* nome titular */
                                                         INPUT 0, /* cpf favorecido */
                                                         INPUT 0, /* inpessoa favorecido */
                                                         INPUT 0, /* intipcta favorecido */
                                                         INPUT tt-tbepr_trans_pend.vlemprestimo,
                                                         INPUT "",
                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                         INPUT 0, /* nrispbif */
                                                         INPUT aux_dscritic).
                                
                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                        INPUT par_cdoperad,
                                                        INPUT aux_dscritic,
                                                        INPUT aux_dsorigem,
                                                        INPUT aux_dstransa,
                                                        INPUT FALSE,
                                                        INPUT par_nmdatela,
                                                        INPUT par_nrdconta,
                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                        INPUT FALSE,
                                                        INPUT par_indvalid,
                                                        INPUT tt-tbgen_trans_pend.dtmvtolt,
                                                        INPUT tt-tbepr_trans_pend.vlemprestimo,
                                                        INPUT aux_conttran).
            
                                IF  par_indvalid = 1  THEN
                                    ASSIGN par_flgaviso = TRUE.
            
                                UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.
                       
                        IF NOT VALID-HANDLE(h-b1wgen0188) THEN
                            RUN sistema/generico/procedures/b1wgen0188.p PERSISTENT SET h-b1wgen0188.

                        RUN calcula_taxa_emprestimo IN h-b1wgen0188(INPUT par_cdcooper,
                                                                    INPUT par_cdagenci,
                                                                    INPUT par_nrdcaixa,
                                                                    INPUT par_cdoperad,
                                                                    INPUT par_nmdatela,
                                                                    INPUT par_idorigem,
                                                                    INPUT par_nrdconta,
                                                                    INPUT par_dtmvtolt,
                                                                    INPUT tt-tbepr_trans_pend.vlemprestimo,
                                                                    INPUT tt-tbepr_trans_pend.vlparcela,
                                                                    INPUT tt-tbepr_trans_pend.nrparcelas,
                                                                    INPUT tt-tbepr_trans_pend.dtprimeiro_vencto,
                                                                   OUTPUT aux_vlrtarif,
                                                                   OUTPUT aux_percetop,
                                                                   OUTPUT aux_vltaxiof,
                                                                   OUTPUT aux_vltariof,
																   OUTPUT aux_vlliquid,
                                                                   OUTPUT TABLE tt-erro).

                        IF RETURN-VALUE <> "OK" THEN
                            DO:
                                IF VALID-HANDLE(h-b1wgen0188) THEN
                                    DELETE PROCEDURE h-b1wgen0188.

                                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                                IF  AVAILABLE tt-erro  THEN
                                    ASSIGN aux_dscritic = tt-erro.dscritic.
                                ELSE
                                    ASSIGN aux_dscritic = "Falha no calculo de taxas de emprestimos.".
                                
                                /* Gerar log das teds com erro */
                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                         INPUT "calcula_taxa_emprestimo",
                                                         INPUT "b1wgen0188",
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_nrdconta,
                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                         INPUT 0, /* cddbanco */
                                                         INPUT 0, /* ag. destino */
                                                         INPUT 0, /* conta destino */
                                                         INPUT "", /* nome titular */
                                                         INPUT 0, /* cpf favorecido */
                                                         INPUT 0, /* inpessoa favorecido */
                                                         INPUT 0, /* intipcta favorecido */
                                                         INPUT tt-tbepr_trans_pend.vlemprestimo,
                                                         INPUT "",
                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                         INPUT 0, /* nrispbif */
                                                         INPUT aux_dscritic).
                                
                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                        INPUT par_cdoperad,
                                                        INPUT aux_dscritic,
                                                        INPUT aux_dsorigem,
                                                        INPUT aux_dstransa,
                                                        INPUT FALSE,
                                                        INPUT par_nmdatela,
                                                        INPUT par_nrdconta,
                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                        INPUT FALSE,
                                                        INPUT par_indvalid,
                                                        INPUT tt-tbgen_trans_pend.dtmvtolt,
                                                        INPUT tt-tbepr_trans_pend.vlemprestimo,
                                                        INPUT aux_conttran).
            
                                IF  par_indvalid = 1  THEN
                                    ASSIGN par_flgaviso = TRUE.
            
                                UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.

                        IF aux_vlrtarif <> tt-tbepr_trans_pend.vltarifa         OR
                           aux_percetop <> tt-tbepr_trans_pend.vlpercentual_cet OR
                           aux_vltaxiof <> tt-tbepr_trans_pend.vlpercentual_iof OR
                           trunc(aux_vltariof,2) <> tt-tbepr_trans_pend.vliof   THEN
                            DO:
                                IF VALID-HANDLE(h-b1wgen0188) THEN
                                    DELETE PROCEDURE h-b1wgen0188.

                                ASSIGN aux_dscritic = "3 - As condicoes do credito pre-aprovado nao estao mais disponiveis para contratacao.".

                                /* Gerar log das teds com erro */
                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                         INPUT "tarifas divergentes",
                                                         INPUT "b1wgen0016",
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_nrdconta,
                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                         INPUT 0, /* cddbanco */
                                                         INPUT 0, /* ag. destino */
                                                         INPUT 0, /* conta destino */
                                                         INPUT "", /* nome titular */
                                                         INPUT 0, /* cpf favorecido */
                                                         INPUT 0, /* inpessoa favorecido */
                                                         INPUT 0, /* intipcta favorecido */
                                                         INPUT tt-tbepr_trans_pend.vlemprestimo,
                                                         INPUT "",
                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                         INPUT 0, /* nrispbif */
                                                         INPUT aux_dscritic).
                                
                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                        INPUT par_cdoperad,
                                                        INPUT aux_dscritic,
                                                        INPUT aux_dsorigem,
                                                        INPUT aux_dstransa,
                                                        INPUT FALSE,
                                                        INPUT par_nmdatela,
                                                        INPUT par_nrdconta,
                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                        INPUT FALSE,
                                                        INPUT par_indvalid,
                                                        INPUT tt-tbgen_trans_pend.dtmvtolt,
                                                        INPUT tt-tbepr_trans_pend.vlemprestimo,
                                                        INPUT aux_conttran).
            
                                IF  par_indvalid = 1  THEN
                                    ASSIGN par_flgaviso = TRUE.
            
                                UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.
                    
                        IF par_indvalid = 1 AND aux_conttran = 1 THEN
                            DO: 
                                IF NOT VALID-HANDLE(h-b1wgen0188) THEN
                                    RUN sistema/generico/procedures/b1wgen0188.p PERSISTENT SET h-b1wgen0188.

                                RUN grava_dados IN h-b1wgen0188(INPUT par_cdcooper,
                                                                INPUT par_cdagenci,
                                                                INPUT par_nrdcaixa,
                                                                INPUT par_cdoperad,
                                                                INPUT par_nmdatela,
                                                                INPUT par_idorigem,
                                                                INPUT par_nrdconta,
                                                                INPUT 1,
                                                                INPUT par_dtmvtolt,
                                                                INPUT crapdat.dtmvtopr,
                                                                INPUT tt-tbepr_trans_pend.nrparcelas,
                                                                INPUT tt-tbepr_trans_pend.vlparcela,
                                                                INPUT tt-tbepr_trans_pend.vlemprestimo,
                                                                INPUT tt-tbepr_trans_pend.dtprimeiro_vencto,
                                                                INPUT tt-tbepr_trans_pend.vlpercentual_cet,
                                                                INPUT 0,
                                                                INPUT 0,
                                                                INPUT 0,
                                                                INPUT par_nrcpfope,
                                                               OUTPUT aux_nrctremp,
                                                               OUTPUT TABLE tt-erro).
                                IF RETURN-VALUE <> "OK" THEN
                                    DO:
                                        IF VALID-HANDLE(h-b1wgen0188) THEN
                                            DELETE PROCEDURE h-b1wgen0188.
        
                                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
                                        IF  AVAILABLE tt-erro  THEN
                                            ASSIGN aux_dscritic = tt-erro.dscritic.
                                        ELSE
                                            ASSIGN aux_dscritic = "Falha na gravacao de dados de emprestimos.".
                                        
                                        RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                 INPUT "grava_dados",
                                                                 INPUT "b1wgen0188",
                                                                 INPUT par_dtmvtolt,
                                                                 INPUT par_nrdconta,
                                                                 INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                 INPUT 0, /* cddbanco */
                                                                 INPUT 0, /* ag. destino */
                                                                 INPUT 0, /* conta destino */
                                                                 INPUT "", /* nome titular */
                                                                 INPUT 0, /* cpf favorecido */
                                                                 INPUT 0, /* inpessoa favorecido */
                                                                 INPUT 0, /* intipcta favorecido */
                                                                 INPUT tt-tbepr_trans_pend.vlemprestimo,
                                                                 INPUT "",
                                                                 INPUT tt-tbgen_trans_pend.tptransacao,
                                                                 INPUT 0, /* nrispbif */
                                                                 INPUT aux_dscritic).
                                        
                                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                INPUT par_cdoperad,
                                                                INPUT aux_dscritic,
                                                                INPUT aux_dsorigem,
                                                                INPUT aux_dstransa,
                                                                INPUT FALSE,
                                                                INPUT par_nmdatela,
                                                                INPUT par_nrdconta,
                                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                INPUT FALSE,
                                                                INPUT par_indvalid,
                                                                INPUT tt-tbgen_trans_pend.dtmvtolt,
                                                                INPUT tt-tbepr_trans_pend.vlemprestimo,
                                                                INPUT aux_conttran).
                    
                                        IF  par_indvalid = 1  THEN
                                            ASSIGN par_flgaviso = TRUE.
                    
                                        UNDO TRANSACAO, LEAVE TRANSACAO. 
                                    END.
                                
                                IF VALID-HANDLE(h-b1wgen0188) THEN
                                    DELETE PROCEDURE h-b1wgen0188.

                            END.

                        IF  VALID-HANDLE(h-b1wgen0188) THEN
                            DELETE PROCEDURE h-b1wgen0188.
                        
                        IF  par_indvalid = 0 AND aux_conttran = 1 THEN
                            DO:
                                FIND FIRST tt-vlrdat WHERE tt-vlrdat.dattrans = tt-tbgen_trans_pend.dtmvtolt EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin + tt-tbepr_trans_pend.vliof + tt-tbepr_trans_pend.vltarifa.
                            END.
                            
                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                INPUT par_cdoperad,
                                                INPUT aux_dscritic,
                                                INPUT aux_dsorigem,
                                                INPUT aux_dstransa,
                                                INPUT FALSE,
                                                INPUT par_nmdatela,
                                                INPUT par_nrdconta,
                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                INPUT TRUE,
                                                INPUT par_indvalid,
                                                INPUT tt-tbgen_trans_pend.dtmvtolt,
                                                INPUT tt-tbepr_trans_pend.vlemprestimo,
                                                INPUT aux_conttran).
                	END.
                ELSE IF tt-tbgen_trans_pend.tptransacao = 7 THEN /* Aplicações */
                	DO:
                        FOR FIRST tt-tbcapt_trans_pend WHERE tt-tbcapt_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK. END.
                        
                        /* Efetivar Cancelamento Aplicação */
                        IF CAN-DO("1,2,3,4",STRING(tt-tbcapt_trans_pend.tpoperacao)) THEN
                            DO:
                                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                                    RUN STORED-PROCEDURE pc_horario_limite aux_handproc = PROC-HANDLE NO-ERROR
                                                         (INPUT par_cdcooper
                                                         ,INPUT par_cdagenci
                                                         ,INPUT par_nrdcaixa
                                                         ,INPUT par_cdoperad
                                                         ,INPUT par_nmdatela
                                                         ,INPUT par_idorigem
                                                         ,1
                                                         ,OUTPUT 0
                                                         ,OUTPUT 0
                                                         ,OUTPUT 0
                                                         ,OUTPUT 0
                                                         ,OUTPUT "").

                                CLOSE STORED-PROC pc_horario_limite aux_statproc = PROC-STATUS
                                      WHERE PROC-HANDLE = aux_handproc.
                            
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = ""
                                       aux_hrlimini = 0
                                       aux_hrlimfim = 0
                                       aux_hrlimini = INT(pc_horario_limite.pr_hrlimini)
                                                      WHEN pc_horario_limite.pr_hrlimini <> ?
                                       aux_hrlimfim = pc_horario_limite.pr_hrlimfim
                                                      WHEN pc_horario_limite.pr_hrlimfim <> ?
                                       aux_cdcritic = INT(pc_horario_limite.pr_cdcritic)
                                                      WHEN pc_horario_limite.pr_cdcritic <> ?
                                       aux_dscritic = pc_horario_limite.pr_dscritic
                                                      WHEN pc_horario_limite.pr_dscritic <> ?.
                                       
                                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                            
                                IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                                    DO:
                                        RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                 INPUT "pc_horario_limite",
                                                                 INPUT "b1wgen0016",
                                                                 INPUT par_dtmvtolt,
                                                                 INPUT par_nrdconta,
                                                                 INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                 INPUT 0, /* cddbanco */
                                                                 INPUT 0, /* ag. destino */
                                                                 INPUT 0, /* conta destino */
                                                                 INPUT "", /* nome titular */
                                                                 INPUT 0, /* cpf favorecido */
                                                                 INPUT 0, /* inpessoa favorecido */
                                                                 INPUT 0, /* intipcta favorecido */
                                                                 INPUT tt-tbcapt_trans_pend.vlresgate,
                                                                 INPUT "",
                                                                 INPUT tt-tbgen_trans_pend.tptransacao,
                                                                 INPUT 0, /* nrispbif */
                                                                 INPUT aux_dscritic).
                                        
                                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                INPUT par_cdoperad,
                                                                INPUT aux_dscritic,
                                                                INPUT aux_dsorigem,
                                                                INPUT aux_dstransa,
                                                                INPUT FALSE,
                                                                INPUT par_nmdatela,
                                                                INPUT par_nrdconta,
                                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                INPUT FALSE,
                                                                INPUT par_indvalid,
                                                                INPUT tt-tbgen_trans_pend.dtmvtolt,
                                                                INPUT tt-tbcapt_trans_pend.vlresgate,
                                                                INPUT aux_conttran).
                    
                                        IF  par_indvalid = 1  THEN
                                            ASSIGN par_flgaviso = TRUE.
                    
                                        UNDO TRANSACAO, LEAVE TRANSACAO.
                                    END.
                            END.
                        IF CAN-DO("1",STRING(tt-tbcapt_trans_pend.tpoperacao)) THEN
                            DO:
                                
                                /* pc_validar_nova_aplicacao */        
                                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                                    
                                RUN STORED-PROCEDURE pc_validar_nova_aplic_wt
                                  aux_handproc = PROC-HANDLE NO-ERROR
                                                          (INPUT par_cdcooper,
                                                           INPUT par_cdagenci,
                                                           INPUT par_nrdcaixa,
                                                           INPUT par_cdoperad,
                                                           INPUT par_nmdatela,
                                                           INPUT par_idorigem,
                                                           INPUT crapdat.inproces,
                                                           INPUT par_nrdconta,
                                                           INPUT par_idseqttl,
                                                           INPUT par_dtmvtolt,
                                                           INPUT crapdat.dtmvtopr,
                                                           INPUT "E",
                                                           INPUT 0,
                                                           INPUT tt-tbcapt_trans_pend.nraplicacao,
                                                           INPUT 0,
                                                           INPUT ?,
                                                           INPUT 0,
                                                           INPUT 0,
                                                           INPUT 0,
                                                           INPUT 0,
                                                           INPUT 0,
                                                           OUTPUT "",                             
                                                           OUTPUT 0,
                                                           OUTPUT "").
                                
                                CLOSE STORED-PROC pc_validar_nova_aplic_wt
                                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                                
                                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                                
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = ""
                                       aux_cdcritic = pc_validar_nova_aplic_wt.pr_cdcritic 
                                                      WHEN pc_validar_nova_aplic_wt.pr_cdcritic <> ?
                                       aux_dscritic = pc_validar_nova_aplic_wt.pr_dscritic
                                                      WHEN pc_validar_nova_aplic_wt.pr_dscritic <> ?. 
                                
                                IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                                    DO:
                                        RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                 INPUT "pc_validar_nova_aplic_wt",
                                                                 INPUT "b1wgen0016",
                                                                 INPUT par_dtmvtolt,
                                                                 INPUT par_nrdconta,
                                                                 INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                 INPUT 0, /* cddbanco */
                                                                 INPUT 0, /* ag. destino */
                                                                 INPUT 0, /* conta destino */
                                                                 INPUT "", /* nome titular */
                                                                 INPUT 0, /* cpf favorecido */
                                                                 INPUT 0, /* inpessoa favorecido */
                                                                 INPUT 0, /* intipcta favorecido */
                                                                 INPUT tt-tbcapt_trans_pend.vlresgate,
                                                                 INPUT "",
                                                                 INPUT tt-tbgen_trans_pend.tptransacao,
                                                                 INPUT 0, /* nrispbif */
                                                                 INPUT aux_dscritic).
                                        
                                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                INPUT par_cdoperad,
                                                                INPUT aux_dscritic,
                                                                INPUT aux_dsorigem,
                                                                INPUT aux_dstransa,
                                                                INPUT FALSE,
                                                                INPUT par_nmdatela,
                                                                INPUT par_nrdconta,
                                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                INPUT FALSE,
                                                                INPUT par_indvalid,
                                                                INPUT tt-tbgen_trans_pend.dtmvtolt,
                                                                INPUT tt-tbcapt_trans_pend.vlresgate,
                                                                INPUT aux_conttran).
                    
                                        IF par_indvalid = 1 THEN
                                            ASSIGN par_flgaviso = TRUE.
                    
                                        UNDO TRANSACAO, LEAVE TRANSACAO.
                                    END.    

                                /* Efetivacao */
                                IF par_indvalid = 1 AND aux_conttran = 1 THEN
                                    DO:
                                        
                                        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

                                        RUN STORED-PROCEDURE pc_excluir_nova_aplicacao
                                            aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper,
                                                                                INPUT par_cdagenci,
                                                                                INPUT par_nrdcaixa,
                                                                                INPUT par_cdoperad,
                                                                                INPUT par_nmdatela,
                                                                                INPUT par_idorigem,
                                                                                INPUT par_nrdconta,
                                                                                INPUT par_idseqttl,
                                                                                INPUT par_dtmvtolt,
                                                                                INPUT tt-tbcapt_trans_pend.nraplicacao,
                                                                                INPUT 1,
                                                                               OUTPUT 0,
                                                                               OUTPUT "").
                                        
                                        CLOSE STORED-PROC pc_excluir_nova_aplicacao
                                            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                                        
                                        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                                        
                                        ASSIGN aux_cdcritic = 0
                                               aux_dscritic = ""
                                               aux_cdcritic = pc_excluir_nova_aplicacao.pr_cdcritic 
                                                                WHEN pc_excluir_nova_aplicacao.pr_cdcritic <> ?
                                               aux_dscritic = pc_excluir_nova_aplicacao.pr_dscritic
                                                                WHEN pc_excluir_nova_aplicacao.pr_dscritic <> ?.
                                        
                                        IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                                            DO:
                                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                         INPUT "pc_excluir_nova_aplicacao",
                                                                         INPUT "b1wgen0016",
                                                                         INPUT par_dtmvtolt,
                                                                         INPUT par_nrdconta,
                                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                         INPUT 0, /* cddbanco */
                                                                         INPUT 0, /* ag. destino */
                                                                         INPUT 0, /* conta destino */
                                                                         INPUT "", /* nome titular */
                                                                         INPUT 0, /* cpf favorecido */
                                                                         INPUT 0, /* inpessoa favorecido */
                                                                         INPUT 0, /* intipcta favorecido */
                                                                         INPUT tt-tbcapt_trans_pend.vlresgate,
                                                                         INPUT "",
                                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                                         INPUT 0, /* nrispbif */
                                                                         INPUT aux_dscritic).
                                                
                                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                        INPUT par_cdoperad,
                                                                        INPUT aux_dscritic,
                                                                        INPUT aux_dsorigem,
                                                                        INPUT aux_dstransa,
                                                                        INPUT FALSE,
                                                                        INPUT par_nmdatela,
                                                                        INPUT par_nrdconta,
                                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                        INPUT FALSE,
                                                                        INPUT par_indvalid,
                                                                        INPUT tt-tbgen_trans_pend.dtmvtolt,
                                                                        INPUT tt-tbcapt_trans_pend.vlresgate,
                                                                        INPUT aux_conttran).
                            
                                                IF par_indvalid = 1 THEN
                                                    ASSIGN par_flgaviso = TRUE.
                            
                                                UNDO TRANSACAO, LEAVE TRANSACAO.
                                            END.
                                    END. /* Fim Efetivacao */

                            END. /* Fim efetivar Cancelamento Aplicação */
                        ELSE IF CAN-DO("2",STRING(tt-tbcapt_trans_pend.tpoperacao)) THEN /* Efetivar resgate aplicacao */
                            DO:
                                
                                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
                                
                                RUN STORED-PROCEDURE pc_valida_limite_internet
                                    aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper
                                                                       ,INPUT par_cdagenci
                                                                       ,INPUT par_nrdcaixa
                                                                       ,INPUT par_cdoperad
                                                                       ,INPUT par_nmdatela
                                                                       ,INPUT par_idorigem
                                                                       ,INPUT par_nrdconta
                                                                       ,INPUT par_idseqttl
                                                                       ,INPUT tt-tbcapt_trans_pend.vlresgate
                                                                       ,INPUT "R"
                                                                      ,OUTPUT 0
                                                                      ,OUTPUT "").
                                
                                CLOSE STORED-PROC pc_valida_limite_internet
                                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                                
                                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                                
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = ""
                                       aux_cdcritic = pc_valida_limite_internet.pr_cdcritic 
                                                        WHEN pc_valida_limite_internet.pr_cdcritic <> ?
                                       aux_dscritic = pc_valida_limite_internet.pr_dscritic
                                                        WHEN pc_valida_limite_internet.pr_dscritic <> ?.
                                
                                IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                                    DO:
                                        RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                 INPUT "pc_valida_limite_internet",
                                                                 INPUT "b1wgen0016",
                                                                 INPUT par_dtmvtolt,
                                                                 INPUT par_nrdconta,
                                                                 INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                 INPUT 0, /* cddbanco */
                                                                 INPUT 0, /* ag. destino */
                                                                 INPUT 0, /* conta destino */
                                                                 INPUT "", /* nome titular */
                                                                 INPUT 0, /* cpf favorecido */
                                                                 INPUT 0, /* inpessoa favorecido */
                                                                 INPUT 0, /* intipcta favorecido */
                                                                 INPUT tt-tbcapt_trans_pend.vlresgate,
                                                                 INPUT "",
                                                                 INPUT tt-tbgen_trans_pend.tptransacao,
                                                                 INPUT 0, /* nrispbif */
                                                                 INPUT aux_dscritic).
                                        
                                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                INPUT par_cdoperad,
                                                                INPUT aux_dscritic,
                                                                INPUT aux_dsorigem,
                                                                INPUT aux_dstransa,
                                                                INPUT FALSE,
                                                                INPUT par_nmdatela,
                                                                INPUT par_nrdconta,
                                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                INPUT FALSE,
                                                                INPUT par_indvalid,
                                                                INPUT tt-tbgen_trans_pend.dtmvtolt,
                                                                INPUT tt-tbcapt_trans_pend.vlresgate,
                                                                INPUT aux_conttran).
                    
                                        IF par_indvalid = 1 THEN
                                            ASSIGN par_flgaviso = TRUE.
                    
                                        UNDO TRANSACAO, LEAVE TRANSACAO.
                                    END.
                                
                                IF tt-tbcapt_trans_pend.tpaplicacao = "A" THEN
                                    DO:
                                        IF NOT VALID-HANDLE(h-b1wgen0081)  THEN
                                            RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.

                                        RUN cadastrar-resgate-aplicacao IN h-b1wgen0081(INPUT par_cdcooper
                                                                                       ,INPUT par_cdagenci
                                                                                       ,INPUT par_nrdcaixa
                                                                                       ,INPUT par_cdoperad
                                                                                       ,INPUT par_nmdatela
                                                                                       ,INPUT par_idorigem
                                                                                       ,INPUT par_nrdconta
                                                                                       ,INPUT par_idseqttl
                                                                                       ,INPUT tt-tbcapt_trans_pend.nraplicacao
                                                                                       ,INPUT IF tt-tbcapt_trans_pend.tpresgate = 1 THEN "P" ELSE "T"
                                                                                       ,INPUT tt-tbcapt_trans_pend.vlresgate
                                                                                       ,INPUT tt-tbgen_trans_pend.dtmvtolt
                                                                                       ,INPUT 0
                                                                                       ,INPUT par_dtmvtolt
                                                                                       ,INPUT crapdat.dtmvtopr
                                                                                       ,INPUT "RESGAT"
                                                                                       ,INPUT 1
                                                                                       ,INPUT 0
                                                                                       ,INPUT ""
                                                                                       ,INPUT ""
                                                                                      ,OUTPUT aux_nrdocmto
                                                                                      ,OUTPUT TABLE tt-msg-confirma
                                                                                      ,OUTPUT TABLE tt-erro).
                                            
                                        IF RETURN-VALUE <> "OK" THEN
                                            DO:
                                                IF VALID-HANDLE(h-b1wgen0081) THEN
                                                    DELETE PROCEDURE h-b1wgen0081.
                
                                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                                                IF  AVAILABLE tt-erro  THEN
                                                    ASSIGN aux_dscritic = tt-erro.dscritic.
                                                ELSE
                                                    ASSIGN aux_dscritic = "Falha ao cadastrar resgate de aplicacao.".
                                                
                                                /* Gerar log das teds com erro */
                                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                         INPUT "cadastrar-resgate-aplicacao",
                                                                         INPUT "b1wgen0081",
                                                                         INPUT par_dtmvtolt,
                                                                         INPUT par_nrdconta,
                                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                         INPUT 0, /* cddbanco */
                                                                         INPUT 0, /* ag. destino */
                                                                         INPUT 0, /* conta destino */
                                                                         INPUT "", /* nome titular */
                                                                         INPUT 0, /* cpf favorecido */
                                                                         INPUT 0, /* inpessoa favorecido */
                                                                         INPUT 0, /* intipcta favorecido */
                                                                         INPUT tt-tbcapt_trans_pend.vlresgate,
                                                                         INPUT "",
                                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                                         INPUT 0, /* nrispbif */
                                                                         INPUT aux_dscritic).
                                                
                                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                        INPUT par_cdoperad,
                                                                        INPUT aux_dscritic,
                                                                        INPUT aux_dsorigem,
                                                                        INPUT aux_dstransa,
                                                                        INPUT FALSE,
                                                                        INPUT par_nmdatela,
                                                                        INPUT par_nrdconta,
                                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                        INPUT FALSE,
                                                                        INPUT par_indvalid,
                                                                        INPUT tt-tbgen_trans_pend.dtmvtolt,
                                                                        INPUT tt-tbcapt_trans_pend.vlresgate,
                                                                        INPUT aux_conttran).
                            
                                                IF  par_indvalid = 1  THEN
                                                    ASSIGN par_flgaviso = TRUE.
                            
                                                UNDO TRANSACAO, LEAVE TRANSACAO. 
                                            END.

                                        IF VALID-HANDLE(h-b1wgen0081) THEN
                                            DELETE PROCEDURE h-b1wgen0081. 

                                    END.
                                ELSE IF tt-tbcapt_trans_pend.tpaplicacao = "N" THEN
                                    DO:
                                        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
                                        
                                        /* Efetuar a chamada a rotina Oracle */ 
                                        RUN STORED-PROCEDURE pc_val_solicit_resg
                                           aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,                          /* Código da Cooperativa */
                                                                                INPUT par_cdoperad,                          /* Código do Operador */
                                                                                INPUT par_nmdatela,                          /* Nome da Tela */
                                                                                INPUT par_idorigem,                          /* Identificador de Origem (1-AYLLOS/2-CAIXA/3-INTERNET/4-TAA/5-AYLLOS WEB/6-URA) */
                                                                                INPUT par_nrdconta,                          /* Número da Conta */
                                                                                INPUT par_idseqttl,                          /* Titular da Conta */
                                                                                INPUT tt-tbcapt_trans_pend.nraplicacao,         /* Número da Aplicação */
                                                                                INPUT tt-tbcapt_trans_pend.cdproduto_aplicacao, /* Código do Produto */
                                                                                INPUT tt-tbgen_trans_pend.dtmvtolt,             /* Data do Resgate (Data informada em tela) */
                                                                                INPUT tt-tbcapt_trans_pend.vlresgate,           /* Valor do Resgate (Valor informado em tela) */
                                                                                INPUT tt-tbcapt_trans_pend.tpresgate,           /* Tipo do Resgate (Tipo informado em tela, 1 – Parcial / 2 – Total) */
                                                                                INPUT 0,                                     /* Resgate na Conta Investimento (Identificador informado em tela, 0 – Não) */
                                                                                INPUT 1,                                     /* Identificador de validação do bloqueio judicial (0 – Não / 1 – Sim) */
                                                                                INPUT 0,                                     /* Identificador de Log (Fixo no código, 0 – Não / 1 - Sim) */
                                                                                INPUT '',                                    /* Operador */
                                                                                INPUT '',                                    /* Senha */
                                                                                INPUT 0,                                     /* Validar senha */
                                                                               OUTPUT 0,                                     /* Código da crítica */
                                                                               OUTPUT "").                                   /* Descricao da Critica */
                                        
                                        /* Fechar o procedimento para buscarmos o resultado */ 
                                        CLOSE STORED-PROC pc_val_solicit_resg
                                              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                                        
                                        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
                                        
                                        /* Busca possíveis erros */ 
                                        ASSIGN aux_cdcritic = 0
                                               aux_dscritic = ""
                                               aux_cdcritic = pc_val_solicit_resg.pr_cdcritic 
                                                              WHEN pc_val_solicit_resg.pr_cdcritic <> ?
                                               aux_dscritic = pc_val_solicit_resg.pr_dscritic 
                                                              WHEN pc_val_solicit_resg.pr_dscritic <> ?.
                                        
                                        IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                                            DO:
                                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                         INPUT "pc_val_solicit_resg",
                                                                         INPUT "b1wgen0016",
                                                                         INPUT par_dtmvtolt,
                                                                         INPUT par_nrdconta,
                                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                         INPUT 0, /* cddbanco */
                                                                         INPUT 0, /* ag. destino */
                                                                         INPUT 0, /* conta destino */
                                                                         INPUT "", /* nome titular */
                                                                         INPUT 0, /* cpf favorecido */
                                                                         INPUT 0, /* inpessoa favorecido */
                                                                         INPUT 0, /* intipcta favorecido */
                                                                         INPUT tt-tbcapt_trans_pend.vlresgate,
                                                                         INPUT "",
                                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                                         INPUT 0, /* nrispbif */
                                                                         INPUT aux_dscritic).
                                                
                                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                        INPUT par_cdoperad,
                                                                        INPUT aux_dscritic,
                                                                        INPUT aux_dsorigem,
                                                                        INPUT aux_dstransa,
                                                                        INPUT FALSE,
                                                                        INPUT par_nmdatela,
                                                                        INPUT par_nrdconta,
                                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                        INPUT FALSE,
                                                                        INPUT par_indvalid,
                                                                        INPUT tt-tbgen_trans_pend.dtmvtolt,
                                                                        INPUT tt-tbcapt_trans_pend.vlresgate,
                                                                        INPUT aux_conttran).
                            
                                                IF par_indvalid = 1 THEN
                                                    ASSIGN par_flgaviso = TRUE.
                            
                                                UNDO TRANSACAO, LEAVE TRANSACAO.
                                            END.
                                    END.
                                     
                                IF par_indvalid = 1 AND aux_conttran = 1 THEN
                                    DO:
                                        IF tt-tbcapt_trans_pend.tpaplicacao = "A" THEN
                                            DO: 
                                                IF NOT VALID-HANDLE(h-b1wgen0081)  THEN
                                                    RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.
                                                                                                   
                                                RUN cadastrar-resgate-aplicacao IN h-b1wgen0081(INPUT par_cdcooper
                                                                                               ,INPUT par_cdagenci
                                                                                               ,INPUT par_nrdcaixa
                                                                                               ,INPUT par_cdoperad
                                                                                               ,INPUT par_nmdatela
                                                                                               ,INPUT par_idorigem
                                                                                               ,INPUT par_nrdconta
                                                                                               ,INPUT par_idseqttl
                                                                                               ,INPUT tt-tbcapt_trans_pend.nraplicacao
                                                                                               ,INPUT IF tt-tbcapt_trans_pend.tpresgate = 1 THEN "P" ELSE "T"
                                                                                               ,INPUT tt-tbcapt_trans_pend.vlresgate
                                                                                               ,INPUT tt-tbgen_trans_pend.dtmvtolt
                                                                                               ,INPUT 0
                                                                                               ,INPUT par_dtmvtolt
                                                                                               ,INPUT crapdat.dtmvtopr
                                                                                               ,INPUT "RESGAT"
                                                                                               ,INPUT 0
                                                                                               ,INPUT 0
                                                                                               ,INPUT ""
                                                                                               ,INPUT ""
                                                                                              ,OUTPUT aux_nrdocmto
                                                                                              ,OUTPUT TABLE tt-msg-confirma
                                                                                              ,OUTPUT TABLE tt-erro).
                                                IF RETURN-VALUE <> "OK" THEN
                                                    DO:
                                                        IF VALID-HANDLE(h-b1wgen0081) THEN
                                                            DELETE PROCEDURE h-b1wgen0081.
                        
                                                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        
                                                        IF  AVAILABLE tt-erro  THEN
                                                            ASSIGN aux_dscritic = tt-erro.dscritic.
                                                        ELSE
                                                            ASSIGN aux_dscritic = "Falha ao efetivar cadastro de resgate aplicacao.".
                                                        
                                                        RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                                 INPUT "cadastrar-resgate-aplicacao",
                                                                                 INPUT "b1wgen0081",
                                                                                 INPUT par_dtmvtolt,
                                                                                 INPUT par_nrdconta,
                                                                                 INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                                 INPUT 0, /* cddbanco */
                                                                                 INPUT 0, /* ag. destino */
                                                                                 INPUT 0, /* conta destino */
                                                                                 INPUT "", /* nome titular */
                                                                                 INPUT 0, /* cpf favorecido */
                                                                                 INPUT 0, /* inpessoa favorecido */
                                                                                 INPUT 0, /* intipcta favorecido */
                                                                                 INPUT tt-tbcapt_trans_pend.vlresgate,
                                                                                 INPUT "",
                                                                                 INPUT tt-tbgen_trans_pend.tptransacao,
                                                                                 INPUT 0, /* nrispbif */
                                                                                 INPUT aux_dscritic).
                                                        
                                                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                                INPUT par_cdoperad,
                                                                                INPUT aux_dscritic,
                                                                                INPUT aux_dsorigem,
                                                                                INPUT aux_dstransa,
                                                                                INPUT FALSE,
                                                                                INPUT par_nmdatela,
                                                                                INPUT par_nrdconta,
                                                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                                INPUT FALSE,
                                                                                INPUT par_indvalid,
                                                                                INPUT tt-tbgen_trans_pend.dtmvtolt,
                                                                                INPUT tt-tbcapt_trans_pend.vlresgate,
                                                                                INPUT aux_conttran).
                                    
                                                        IF  par_indvalid = 1  THEN
                                                            ASSIGN par_flgaviso = TRUE.
                                    
                                                        UNDO TRANSACAO, LEAVE TRANSACAO. 
                                                    END.

                                                IF VALID-HANDLE(h-b1wgen0081) THEN
                                                    DELETE PROCEDURE h-b1wgen0081. 
                                                
                                            END.
                                        ELSE IF tt-tbcapt_trans_pend.tpaplicacao = "N" THEN
                                            DO: 
                                                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
                 
                                                /* Efetuar a chamada a rotina Oracle */ 
                                                RUN STORED-PROCEDURE pc_solicita_resgate
                                                   aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,                          /* Código da Cooperativa */
                                                                                        INPUT par_cdoperad,                          /* Código do Operador */
                                                                                        INPUT par_nmdatela,                          /* Nome da Tela */
                                                                                        INPUT par_idorigem,                          /* Identificador de Origem (1-AYLLOS/2-CAIXA/3-INTERNET/4-TAA/5-AYLLOS WEB/6-URA) */
                                                                                        INPUT par_nrdconta,                          /* Número da Conta */
                                                                                        INPUT par_idseqttl,                          /* Titular da Conta */
                                                                                        INPUT tt-tbcapt_trans_pend.nraplicacao,         /* Número da Aplicação */
                                                                                        INPUT tt-tbcapt_trans_pend.cdproduto_aplicacao, /* Código do Produto */
                                                                                        INPUT tt-tbgen_trans_pend.dtmvtolt,             /* Data do Resgate (Data informada em tela) */
                                                                                        INPUT tt-tbcapt_trans_pend.vlresgate,           /* Valor do Resgate (Valor informado em tela) */
                                                                                        INPUT tt-tbcapt_trans_pend.tpresgate,           /* Tipo do Resgate (Tipo informado em tela,1–Parcial/2–Total) */
                                                                                        INPUT 0,                                     /* Resgate na Conta Investimento (Identificador informado em tela,0– Não) */
                                                                                        INPUT 0,                                     /* Identificador de Log (Fixo no código,0–Não/1-Sim) */
                                                                                        INPUT "",
                                                                                        INPUT "",
                                                                                        INPUT 0,
                                                                                       OUTPUT 0,                                     /* Código da crítica */
                                                                                       OUTPUT "").  
                                                
                                                /* Fechar o procedimento para buscarmos o resultado */ 
                                                CLOSE STORED-PROC pc_solicita_resgate
                                                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                                                
                                                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
                                                
                                                /* Busca possíveis erros */ 
                                                ASSIGN aux_cdcritic = 0
                                                       aux_dscritic = ""
                                                       aux_cdcritic = pc_solicita_resgate.pr_cdcritic 
                                                                      WHEN pc_solicita_resgate.pr_cdcritic <> ?
                                                       aux_dscritic = pc_solicita_resgate.pr_dscritic 
                                                                      WHEN pc_solicita_resgate.pr_dscritic <> ?.
                                                
                                                IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                                                    DO:
                                                        RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                                 INPUT "pc_solicita_resgate",
                                                                                 INPUT "b1wgen0016",
                                                                                 INPUT par_dtmvtolt,
                                                                                 INPUT par_nrdconta,
                                                                                 INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                                 INPUT 0, /* cddbanco */
                                                                                 INPUT 0, /* ag. destino */
                                                                                 INPUT 0, /* conta destino */
                                                                                 INPUT "", /* nome titular */
                                                                                 INPUT 0, /* cpf favorecido */
                                                                                 INPUT 0, /* inpessoa favorecido */
                                                                                 INPUT 0, /* intipcta favorecido */
                                                                                 INPUT tt-tbcapt_trans_pend.vlresgate,
                                                                                 INPUT "",
                                                                                 INPUT tt-tbgen_trans_pend.tptransacao,
                                                                                 INPUT 0, /* nrispbif */
                                                                                 INPUT aux_dscritic).
                                                        
                                                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                                INPUT par_cdoperad,
                                                                                INPUT aux_dscritic,
                                                                                INPUT aux_dsorigem,
                                                                                INPUT aux_dstransa,
                                                                                INPUT FALSE,
                                                                                INPUT par_nmdatela,
                                                                                INPUT par_nrdconta,
                                                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                                INPUT FALSE,
                                                                                INPUT par_indvalid,
                                                                                INPUT tt-tbgen_trans_pend.dtmvtolt,
                                                                                INPUT tt-tbcapt_trans_pend.vlresgate,
                                                                                INPUT aux_conttran).
                                    
                                                        IF par_indvalid = 1 THEN
                                                            ASSIGN par_flgaviso = TRUE.
                                    
                                                        UNDO TRANSACAO, LEAVE TRANSACAO.
                                                    END.
                                            END.
                                    END.
                                     
                            END. /* Fim Efetivar resgate aplicacao */
                        ELSE IF CAN-DO("3",STRING(tt-tbcapt_trans_pend.tpoperacao)) THEN /* Efetivar Agendamento Resgate */
                            DO:
                                
                                /* PROCEDIMENTO 2 validar-novo-agendamento da BO b1wgen0081 */
                                IF NOT VALID-HANDLE(h-b1wgen0081)  THEN
                                    RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.
                                
                                RUN validar-novo-agendamento IN h-b1wgen0081(INPUT par_cdcooper,
                                                                             INPUT 1,
                                                                             INPUT par_nrdconta,
                                                                             INPUT par_idseqttl,
                                                                             INPUT tt-tbcapt_trans_pend.vlresgate,
                                                                             INPUT tt-tbcapt_trans_pend.idperiodo_agendamento,
                                                                             INPUT 0,
                                                                             INPUT tt-tbcapt_trans_pend.qtmeses_agendamento,
                                                                             INPUT tt-tbcapt_trans_pend.dtinicio_agendamento,
                                                                             INPUT tt-tbcapt_trans_pend.nrdia_agendamento,
                                                                             INPUT ?,
                                                                             INPUT par_cdoperad,
                                                                             INPUT par_nmdatela,
                                                                             INPUT par_idorigem,
                                                                            OUTPUT TABLE tt-erro).
                                IF RETURN-VALUE <> "OK" THEN
                                    DO:
                                        IF VALID-HANDLE(h-b1wgen0081) THEN
                                            DELETE PROCEDURE h-b1wgen0081.
        
                                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
                                        IF  AVAILABLE tt-erro  THEN
                                            ASSIGN aux_dscritic = tt-erro.dscritic.
                                        ELSE
                                            ASSIGN aux_dscritic = "Falha ao efetivar cadastro de resgate aplicacao.".
                                        
                                        /* Gerar log das teds com erro */
                                        RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                 INPUT "validar-novo-agendamento",
                                                                 INPUT "b1wgen0016",
                                                                 INPUT par_dtmvtolt,
                                                                 INPUT par_nrdconta,
                                                                 INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                 INPUT 0, /* cddbanco */
                                                                 INPUT 0, /* ag. destino */
                                                                 INPUT 0, /* conta destino */
                                                                 INPUT "", /* nome titular */
                                                                 INPUT 0, /* cpf favorecido */
                                                                 INPUT 0, /* inpessoa favorecido */
                                                                 INPUT 0, /* intipcta favorecido */
                                                                 INPUT tt-tbcapt_trans_pend.vlresgate,
                                                                 INPUT "",
                                                                 INPUT tt-tbgen_trans_pend.tptransacao,
                                                                 INPUT 0, /* nrispbif */
                                                                 INPUT aux_dscritic).
                                        
                                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                INPUT par_cdoperad,
                                                                INPUT aux_dscritic,
                                                                INPUT aux_dsorigem,
                                                                INPUT aux_dstransa,
                                                                INPUT FALSE,
                                                                INPUT par_nmdatela,
                                                                INPUT par_nrdconta,
                                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                INPUT FALSE,
                                                                INPUT par_indvalid,
                                                                INPUT tt-tbgen_trans_pend.dtmvtolt,
                                                                INPUT tt-tbcapt_trans_pend.vlresgate,
                                                                INPUT aux_conttran).
                    
                                        IF  par_indvalid = 1  THEN
                                            ASSIGN par_flgaviso = TRUE.
                    
                                        UNDO TRANSACAO, LEAVE TRANSACAO. 
                                    END.

                                IF VALID-HANDLE(h-b1wgen0081) THEN
                                    DELETE PROCEDURE h-b1wgen0081.

                                IF par_indvalid = 1 AND aux_conttran = 1 THEN
                                    DO:
                                        /* PROCEDIMENTO 3 incluir-novo-agendamento da BO b1wgen0081 */
                                        IF NOT VALID-HANDLE(h-b1wgen0081)  THEN
                                            RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.
                                        
                                        RUN incluir-novo-agendamento IN h-b1wgen0081(INPUT par_cdcooper,
                                                                                     INPUT tt-tbcapt_trans_pend.tpagendamento,
                                                                                     INPUT par_nrdconta,
                                                                                     INPUT par_idseqttl,
                                                                                     INPUT tt-tbcapt_trans_pend.vlresgate,
                                                                                     INPUT tt-tbcapt_trans_pend.idperiodo_agendamento,
                                                                                     INPUT 0,
                                                                                     INPUT tt-tbcapt_trans_pend.qtmeses_agendamento,
                                                                                     INPUT tt-tbcapt_trans_pend.dtinicio_agendamento,
                                                                                     INPUT tt-tbcapt_trans_pend.nrdia_agendamento,
                                                                                     INPUT ?,
                                                                                     INPUT 0,
                                                                                     INPUT par_cdoperad,
                                                                                     INPUT par_nmdatela,
                                                                                     INPUT par_idorigem,
                                                                                    OUTPUT TABLE tt-erro).

                                        IF RETURN-VALUE <> "OK" THEN
                                            DO:
                                                IF VALID-HANDLE(h-b1wgen0081) THEN
                                                    DELETE PROCEDURE h-b1wgen0081.
                
                                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                                                IF  AVAILABLE tt-erro  THEN
                                                    ASSIGN aux_dscritic = tt-erro.dscritic.
                                                ELSE
                                                    ASSIGN aux_dscritic = "Falha ao incluir novo agendamento.".
                                                
                                                /* Gerar log das teds com erro */
                                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                         INPUT "incluir-novo-agendamento",
                                                                         INPUT "b1wgen0081",
                                                                         INPUT par_dtmvtolt,
                                                                         INPUT par_nrdconta,
                                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                         INPUT 0, /* cddbanco */
                                                                         INPUT 0, /* ag. destino */
                                                                         INPUT 0, /* conta destino */
                                                                         INPUT "", /* nome titular */
                                                                         INPUT 0, /* cpf favorecido */
                                                                         INPUT 0, /* inpessoa favorecido */
                                                                         INPUT 0, /* intipcta favorecido */
                                                                         INPUT tt-tbcapt_trans_pend.vlresgate,
                                                                         INPUT "",
                                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                                         INPUT 0, /* nrispbif */
                                                                         INPUT aux_dscritic).
                                                
                                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                        INPUT par_cdoperad,
                                                                        INPUT aux_dscritic,
                                                                        INPUT aux_dsorigem,
                                                                        INPUT aux_dstransa,
                                                                        INPUT FALSE,
                                                                        INPUT par_nmdatela,
                                                                        INPUT par_nrdconta,
                                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                        INPUT FALSE,
                                                                        INPUT par_indvalid,
                                                                        INPUT tt-tbgen_trans_pend.dtmvtolt,
                                                                        INPUT tt-tbcapt_trans_pend.vlresgate,
                                                                        INPUT aux_conttran).
                            
                                                IF  par_indvalid = 1  THEN
                                                    ASSIGN par_flgaviso = TRUE.
                            
                                                UNDO TRANSACAO, LEAVE TRANSACAO. 
                                            END.
                                        
                                        IF VALID-HANDLE(h-b1wgen0081) THEN
                                            DELETE PROCEDURE h-b1wgen0081.
                                        
                                    END.
                            END. /* Fim Efetivar Agendamento Resgate*/
                        ELSE IF CAN-DO("4",STRING(tt-tbcapt_trans_pend.tpoperacao)) THEN /* Efetivar Cancelamento Agendamento */
                            DO:
                                /* Efetivação */
                                IF par_indvalid = 1 AND aux_conttran = 1 THEN
                                    DO:
                                        IF NOT VALID-HANDLE(h-b1wgen0081)  THEN
                                            RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.
                                        
                                        /* PROCEDIMENTO 2 excluir-agendamento da BO b1wgen0081 */
                                        RUN excluir-agendamento IN h-b1wgen0081(INPUT par_cdcooper,
                                                                                INPUT par_nrdconta,
                                                                                INPUT par_idseqttl,
                                                                                INPUT tt-tbcapt_trans_pend.nrdocto_agendamento,
                                                                                INPUT par_cdoperad,
                                                                               OUTPUT TABLE tt-erro).
                                        
                                        IF RETURN-VALUE <> "OK" THEN
                                            DO:
                                                IF VALID-HANDLE(h-b1wgen0081) THEN
                                                    DELETE PROCEDURE h-b1wgen0081.
                                                
                                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                                
                                                IF  AVAILABLE tt-erro  THEN
                                                    ASSIGN aux_dscritic = tt-erro.dscritic.
                                                ELSE
                                                    ASSIGN aux_dscritic = "Falha ao excluir agendamento.".
                                                
                                                /* Gerar log das teds com erro */
                                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                         INPUT "excluir-agendamento",
                                                                         INPUT "b1wgen0081",
                                                                         INPUT par_dtmvtolt,
                                                                         INPUT par_nrdconta,
                                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                         INPUT 0, /* cddbanco */
                                                                         INPUT 0, /* ag. destino */
                                                                         INPUT 0, /* conta destino */
                                                                         INPUT "", /* nome titular */
                                                                         INPUT 0, /* cpf favorecido */
                                                                         INPUT 0, /* inpessoa favorecido */
                                                                         INPUT 0, /* intipcta favorecido */
                                                                         INPUT tt-tbcapt_trans_pend.vlresgate,
                                                                         INPUT "",
                                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                                         INPUT 0, /* nrispbif */
                                                                         INPUT aux_dscritic).
                                                
                                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                        INPUT par_cdoperad,
                                                                        INPUT aux_dscritic,
                                                                        INPUT aux_dsorigem,
                                                                        INPUT aux_dstransa,
                                                                        INPUT FALSE,
                                                                        INPUT par_nmdatela,
                                                                        INPUT par_nrdconta,
                                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                        INPUT FALSE,
                                                                        INPUT par_indvalid,
                                                                        INPUT tt-tbgen_trans_pend.dtmvtolt,
                                                                        INPUT tt-tbcapt_trans_pend.vlresgate,
                                                                        INPUT aux_conttran).
                                                
                                                IF  par_indvalid = 1  THEN
                                                    ASSIGN par_flgaviso = TRUE.
                            
                                                UNDO TRANSACAO, LEAVE TRANSACAO. 
                                            END.
                                        
                                        IF VALID-HANDLE(h-b1wgen0081) THEN
                                            DELETE PROCEDURE h-b1wgen0081.
                                        
                                    END.
                            END. /* Fim Efetivar Cancelamento Agendamento */
                        ELSE IF CAN-DO("5",STRING(tt-tbcapt_trans_pend.tpoperacao)) THEN /* Efetivar Cancelamento Agendamento DET*/
                            DO:
                                /* Efetivação */
                                IF par_indvalid = 1 AND aux_conttran = 1 THEN
                                    DO:
                                        IF NOT VALID-HANDLE(h-b1wgen0081)  THEN
                                            RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.

                                        /* PROCEDIMENTO 2 excluir-agendamento-det da BO b1wgen0081 */
                                        RUN excluir-agendamento-det IN h-b1wgen0081(INPUT par_cdcooper,
                                                                                    INPUT par_nrdconta,
                                                                                    INPUT par_idseqttl,
                                                                                    INPUT tt-tbcapt_trans_pend.tpagendamento,
                                                                                    INPUT tt-tbcapt_trans_pend.nrdocto_agendamento,
                                                                                   OUTPUT TABLE tt-erro).

                                        IF RETURN-VALUE <> "OK" THEN
                                            DO:
                                                IF VALID-HANDLE(h-b1wgen0081) THEN
                                                    DELETE PROCEDURE h-b1wgen0081.
                
                                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                                                IF  AVAILABLE tt-erro  THEN
                                                    ASSIGN aux_dscritic = tt-erro.dscritic.
                                                ELSE
                                                    ASSIGN aux_dscritic = "Falha ao excluir agendamento(DET).".
                                                
                                                /* Gerar log das teds com erro */
                                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                         INPUT "excluir-agendamento-det",
                                                                         INPUT "b1wgen0081",
                                                                         INPUT par_dtmvtolt,
                                                                         INPUT par_nrdconta,
                                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                         INPUT 0, /* cddbanco */
                                                                         INPUT 0, /* ag. destino */
                                                                         INPUT 0, /* conta destino */
                                                                         INPUT "", /* nome titular */
                                                                         INPUT 0, /* cpf favorecido */
                                                                         INPUT 0, /* inpessoa favorecido */
                                                                         INPUT 0, /* intipcta favorecido */
                                                                         INPUT tt-tbcapt_trans_pend.vlresgate,
                                                                         INPUT "",
                                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                                         INPUT 0, /* nrispbif */
                                                                         INPUT aux_dscritic).
                                                
                                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                        INPUT par_cdoperad,
                                                                        INPUT aux_dscritic,
                                                                        INPUT aux_dsorigem,
                                                                        INPUT aux_dstransa,
                                                                        INPUT FALSE,
                                                                        INPUT par_nmdatela,
                                                                        INPUT par_nrdconta,
                                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                        INPUT FALSE,
                                                                        INPUT par_indvalid,
                                                                        INPUT tt-tbgen_trans_pend.dtmvtolt,
                                                                        INPUT tt-tbcapt_trans_pend.vlresgate,
                                                                        INPUT aux_conttran).
                            
                                                IF  par_indvalid = 1  THEN
                                                    ASSIGN par_flgaviso = TRUE.
                            
                                                UNDO TRANSACAO, LEAVE TRANSACAO. 
                                            END.

                                        IF VALID-HANDLE(h-b1wgen0081) THEN
                                            DELETE PROCEDURE h-b1wgen0081.
                                        
                                    END.
                            END. /* Fim Efetivar Cancelamento Agendamento DET*/
 
                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                INPUT par_cdoperad,
                                                INPUT aux_dscritic,
                                                INPUT aux_dsorigem,
                                                INPUT aux_dstransa,
                                                INPUT FALSE,
                                                INPUT par_nmdatela,
                                                INPUT par_nrdconta,
                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                INPUT TRUE,
                                                INPUT par_indvalid,
                                                INPUT tt-tbgen_trans_pend.dtmvtolt,
                                                INPUT tt-tbcapt_trans_pend.vlresgate,
                                                INPUT aux_conttran).
                	END.
                ELSE IF tt-tbgen_trans_pend.tptransacao = 8 THEN /* Débito Automático */
                	DO:
                        FOR FIRST tt-tbconv_trans_pend WHERE tt-tbconv_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK. END.
                            
                        /* Validação */
                        FOR FIRST crapass FIELDS(inpessoa) WHERE crapass.cdcooper = par_cdcooper AND crapass.nrdconta = par_nrdconta NO-LOCK. END.
                        
                        IF NOT VALID-HANDLE(h-b1wgen0015) THEN
                            RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET h-b1wgen0015.

                        RUN horario_operacao IN h-b1wgen0015(INPUT par_cdcooper,
                                                             INPUT par_cdagenci,
                                                             INPUT 11,
                                                             INPUT crapass.inpessoa,
                                                            OUTPUT aux_dscritic,
                                                            OUTPUT TABLE tt-limite).

                        IF VALID-HANDLE(h-b1wgen0015) THEN
                            DELETE PROCEDURE h-b1wgen0015.

                        IF RETURN-VALUE <> "OK" THEN
                            DO:
                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                         INPUT "horario_operacao",
                                                         INPUT "b1wgen0015",
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_nrdconta,
                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                         INPUT 0, /* cddbanco */
                                                         INPUT 0, /* ag. destino */
                                                         INPUT 0, /* conta destino */
                                                         INPUT "", /* nome titular */
                                                         INPUT 0, /* cpf favorecido */
                                                         INPUT 0, /* inpessoa favorecido */
                                                         INPUT 0, /* intipcta favorecido */
                                                         INPUT tt-tbconv_trans_pend.vlmaximo_debito,
                                                         INPUT "",
                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                         INPUT 0, /* nrispbif */
                                                         INPUT aux_dscritic).
                                
                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                        INPUT par_cdoperad,
                                                        INPUT aux_dscritic,
                                                        INPUT aux_dsorigem,
                                                        INPUT aux_dstransa,
                                                        INPUT FALSE,
                                                        INPUT par_nmdatela,
                                                        INPUT par_nrdconta,
                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                        INPUT FALSE,
                                                        INPUT par_indvalid,
                                                        INPUT tt-tbconv_trans_pend.dtdebito_fatura,
                                                        INPUT tt-tbconv_trans_pend.vlmaximo_debito,
                                                        INPUT aux_conttran).
            
                                IF par_indvalid = 1 THEN
                                    ASSIGN par_flgaviso = TRUE.
            
                                UNDO TRANSACAO, LEAVE TRANSACAO. 
                            END.
                        ELSE
                            DO:
                                FIND FIRST tt-limite NO-LOCK NO-ERROR NO-WAIT.

                                IF AVAIL tt-limite THEN
                                    DO:
                                        IF tt-limite.idesthor = 1 THEN
                                            DO:
                                                ASSIGN aux_dscritic = "Horario esgotado para realizar operacao de Debito Automatico Facil.". 

                                                /* Gerar log das teds com erro */
                                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                         INPUT "tt-limite.idesthor = 1",
                                                                         INPUT "b1wgen0016",
                                                                         INPUT par_dtmvtolt,
                                                                         INPUT par_nrdconta,
                                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                         INPUT 0, /* cddbanco */
                                                                         INPUT 0, /* ag. destino */
                                                                         INPUT 0, /* conta destino */
                                                                         INPUT "", /* nome titular */
                                                                         INPUT 0, /* cpf favorecido */
                                                                         INPUT 0, /* inpessoa favorecido */
                                                                         INPUT 0, /* intipcta favorecido */
                                                                         INPUT tt-tbconv_trans_pend.vlmaximo_debito,
                                                                         INPUT "",
                                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                                         INPUT 0, /* nrispbif */
                                                                         INPUT aux_dscritic).
                                                
                                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                        INPUT par_cdoperad,
                                                                        INPUT aux_dscritic,
                                                                        INPUT aux_dsorigem,
                                                                        INPUT aux_dstransa,
                                                                        INPUT FALSE,
                                                                        INPUT par_nmdatela,
                                                                        INPUT par_nrdconta,
                                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                        INPUT FALSE,
                                                                        INPUT par_indvalid,
                                                                        INPUT tt-tbconv_trans_pend.dtdebito_fatura,
                                                                        INPUT tt-tbconv_trans_pend.vlmaximo_debito,
                                                                        INPUT aux_conttran).
                            
                                                IF  par_indvalid = 1  THEN
                                                    ASSIGN par_flgaviso = TRUE.
                            
                                                UNDO TRANSACAO, LEAVE TRANSACAO.

                                            END.
                                    END.
                            END.

                        IF VALID-HANDLE(h-b1wgen0015) THEN
                            DELETE PROCEDURE h-b1wgen0015.
                            
                        IF tt-tbconv_trans_pend.tpoperacao = 1 THEN /* Efetivação Cadastro Autorização Débito Automático */
                            DO:
                                /* Validação */
                                IF NOT VALID-HANDLE(h-b1wgen0092) THEN
                                    RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.

                                /* Validacao */
                                RUN valida-dados IN h-b1wgen0092 (INPUT par_cdcooper,
                                                                  INPUT par_cdagenci,
                                                                  INPUT par_nrdcaixa,
                                                                  INPUT par_cdoperad,
                                                                  INPUT par_nmdatela,
                                                                  INPUT par_idorigem,
                                                                  INPUT par_nrdconta,
                                                                  INPUT par_idseqttl,
                                                                  INPUT 0,
                                                                  INPUT "I",
                                                                  INPUT tt-tbconv_trans_pend.cdhist_convenio,
                                                                  INPUT tt-tbconv_trans_pend.iddebito_automatico,
                                                                  INPUT par_dtmvtolt,
                                                                  INPUT ?,
                                                                  INPUT ?,
                                                                  INPUT par_dtmvtolt,
                                                                  INPUT par_dtmvtolt,
                                                                 OUTPUT aux_nmdcampo,
                                                                 OUTPUT aux_nmprimtl,
                                                                 OUTPUT TABLE tt-erro).

                                IF RETURN-VALUE <> "OK" THEN
                                    DO:
                                        IF VALID-HANDLE(h-b1wgen0092) THEN
                                            DELETE PROCEDURE h-b1wgen0092.
        
                                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
                                        IF  AVAILABLE tt-erro  THEN
                                            ASSIGN aux_dscritic = tt-erro.dscritic.
                                        ELSE
                                            ASSIGN aux_dscritic = "Falha na validacao de dados.".
                                        
                                        /* Gerar log das teds com erro */
                                        RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                 INPUT "valida-dados",
                                                                 INPUT "b1wgen0092",
                                                                 INPUT par_dtmvtolt,
                                                                 INPUT par_nrdconta,
                                                                 INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                 INPUT 0, /* cddbanco */
                                                                 INPUT 0, /* ag. destino */
                                                                 INPUT 0, /* conta destino */
                                                                 INPUT "", /* nome titular */
                                                                 INPUT 0, /* cpf favorecido */
                                                                 INPUT 0, /* inpessoa favorecido */
                                                                 INPUT 0, /* intipcta favorecido */
                                                                 INPUT tt-tbconv_trans_pend.vlmaximo_debito,
                                                                 INPUT "",
                                                                 INPUT tt-tbgen_trans_pend.tptransacao,
                                                                 INPUT 0, /* nrispbif */
                                                                 INPUT aux_dscritic).
                                        
                                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                INPUT par_cdoperad,
                                                                INPUT aux_dscritic,
                                                                INPUT aux_dsorigem,
                                                                INPUT aux_dstransa,
                                                                INPUT FALSE,
                                                                INPUT par_nmdatela,
                                                                INPUT par_nrdconta,
                                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                INPUT FALSE,
                                                                INPUT par_indvalid,
                                                                INPUT tt-tbconv_trans_pend.dtdebito_fatura,
                                                                INPUT tt-tbconv_trans_pend.vlmaximo_debito,
                                                                INPUT aux_conttran).
                    
                                        IF  par_indvalid = 1  THEN
                                            ASSIGN par_flgaviso = TRUE.
                    
                                        UNDO TRANSACAO, LEAVE TRANSACAO. 
                                    END.
                                IF VALID-HANDLE(h-b1wgen0092) THEN
                                    DELETE PROCEDURE h-b1wgen0092.

                                /* Efetivação */
                                IF par_indvalid = 1 AND aux_conttran = 1 THEN
                                    DO:
                                        IF NOT VALID-HANDLE(h-b1wgen0092) THEN
                                            RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.
                                            
                                        /* Gravacao */
                                        RUN grava-dados IN h-b1wgen0092 (INPUT par_cdcooper,
                                                                         INPUT par_cdagenci,
                                                                         INPUT par_nrdcaixa,
                                                                         INPUT par_cdoperad,
                                                                         INPUT par_nmdatela,
                                                                         INPUT par_idorigem,
                                                                         INPUT par_nrdconta,
                                                                         INPUT par_idseqttl,
                                                                         INPUT 1,
                                                                         INPUT par_dtmvtolt,
                                                                         INPUT "I",
                                                                         INPUT tt-tbconv_trans_pend.cdhist_convenio,
                                                                         INPUT tt-tbconv_trans_pend.iddebito_automatico,
                                                                         INPUT 0,
                                                                         INPUT par_dtmvtolt,
                                                                         INPUT ?,
                                                                         INPUT ?,
                                                                         INPUT 0,
                                                                         INPUT tt-tbconv_trans_pend.dshist_debito,
                                                                         INPUT tt-tbconv_trans_pend.vlmaximo_debito,
                                                                         INPUT "",
                                                                         INPUT tt-tbconv_trans_pend.cdconven,
                                                                         INPUT tt-tbconv_trans_pend.cdsegmento_conven,
                                                                         INPUT "",
                                                                         INPUT "",
                                                                         INPUT "",
                                                                         INPUT "",
                                                                         INPUT "",
                                                                         INPUT "",
                                                                        OUTPUT aux_nmfatret,
                                                                        OUTPUT TABLE tt-erro).
                                        
                                        IF RETURN-VALUE <> "OK" THEN
                                            DO:
                                                IF VALID-HANDLE(h-b1wgen0092) THEN
                                                    DELETE PROCEDURE h-b1wgen0092.
                
                                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                                                IF  AVAILABLE tt-erro  THEN
                                                    ASSIGN aux_dscritic = tt-erro.dscritic.
                                                ELSE
                                                    ASSIGN aux_dscritic = "Falha na gravacao de dados.".
                                                
                                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                         INPUT "grava-dados",
                                                                         INPUT "b1wgen0092",
                                                                         INPUT par_dtmvtolt,
                                                                         INPUT par_nrdconta,
                                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                         INPUT 0, /* cddbanco */
                                                                         INPUT 0, /* ag. destino */
                                                                         INPUT 0, /* conta destino */
                                                                         INPUT "", /* nome titular */
                                                                         INPUT 0, /* cpf favorecido */
                                                                         INPUT 0, /* inpessoa favorecido */
                                                                         INPUT 0, /* intipcta favorecido */
                                                                         INPUT tt-tbconv_trans_pend.vlmaximo_debito,
                                                                         INPUT "",
                                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                                         INPUT 0, /* nrispbif */
                                                                         INPUT aux_dscritic).
                                                
                                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                        INPUT par_cdoperad,
                                                                        INPUT aux_dscritic,
                                                                        INPUT aux_dsorigem,
                                                                        INPUT aux_dstransa,
                                                                        INPUT FALSE,
                                                                        INPUT par_nmdatela,
                                                                        INPUT par_nrdconta,
                                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                        INPUT FALSE,
                                                                        INPUT par_indvalid,
                                                                        INPUT tt-tbconv_trans_pend.dtdebito_fatura,
                                                                        INPUT tt-tbconv_trans_pend.vlmaximo_debito,
                                                                        INPUT aux_conttran).
                            
                                                IF  par_indvalid = 1  THEN
                                                    ASSIGN par_flgaviso = TRUE.
                            
                                                UNDO TRANSACAO, LEAVE TRANSACAO. 
                                            END.
                                        IF VALID-HANDLE(h-b1wgen0092) THEN
                                            DELETE PROCEDURE h-b1wgen0092.
                                    END.
                            END.
                        ELSE IF CAN-DO("2,3",STRING(tt-tbconv_trans_pend.tpoperacao)) THEN /* Efetivação Bloqueio Lançamento Débito Automático | Efetivação Desbloqueio Lançamento Débito Automático */
                            DO:
                                /* Efetivação */
                                IF par_indvalid = 1 AND aux_conttran = 1 THEN
                                    DO:
                                        IF NOT VALID-HANDLE(h-b1wgen0092) THEN
                                            RUN sistema/generico/procedures/b1wgen0092.p PERSISTENT SET h-b1wgen0092.
                                      
                                        IF  tt-tbconv_trans_pend.tpoperacao = 2  THEN
                                            DO:
                                                RUN bloqueia_lancamento IN h-b1wgen0092 (INPUT par_cdcooper,
                                                                                         INPUT par_nrdconta,
                                                                                         INPUT par_dtmvtolt,
                                                                                         INPUT tt-tbconv_trans_pend.dtdebito_fatura,
                                                                                         INPUT tt-tbconv_trans_pend.nrdocumento_fatura,
                                                                                         INPUT tt-tbconv_trans_pend.cdhist_convenio,
                                                                                         INPUT par_cdoperad,
                                                                                         INPUT par_nmdatela,
                                                                                         INPUT par_idorigem,
                                                                                         INPUT TRUE, /* par_flgerlog */
                                                                                        OUTPUT TABLE tt-erro).
                                                IF  RETURN-VALUE <> "OK" THEN
                                                    DO:
                                                        IF VALID-HANDLE(h-b1wgen0092) THEN
                                                            DELETE PROCEDURE h-b1wgen0092.
                        
                                                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        
                                                        IF  AVAILABLE tt-erro  THEN
                                                            ASSIGN aux_dscritic = tt-erro.dscritic.
                                                        ELSE
                                                            ASSIGN aux_dscritic = "Falha ao bloquear lancamento.".
                                                        
                                                        RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                                 INPUT "bloqueia_lancamento",
                                                                                 INPUT "b1wgen0092",
                                                                                 INPUT par_dtmvtolt,
                                                                                 INPUT par_nrdconta,
                                                                                 INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                                 INPUT 0, /* cddbanco */
                                                                                 INPUT 0, /* ag. destino */
                                                                                 INPUT 0, /* conta destino */
                                                                                 INPUT "", /* nome titular */
                                                                                 INPUT 0, /* cpf favorecido */
                                                                                 INPUT 0, /* inpessoa favorecido */
                                                                                 INPUT 0, /* intipcta favorecido */
                                                                                 INPUT tt-tbconv_trans_pend.dtdebito_fatura,
                                                                                 INPUT "",
                                                                                 INPUT tt-tbgen_trans_pend.tptransacao,
                                                                                 INPUT 0, /* nrispbif */
                                                                                 INPUT aux_dscritic).
                                                        
                                                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                                INPUT par_cdoperad,
                                                                                INPUT aux_dscritic,
                                                                                INPUT aux_dsorigem,
                                                                                INPUT aux_dstransa,
                                                                                INPUT FALSE,
                                                                                INPUT par_nmdatela,
                                                                                INPUT par_nrdconta,
                                                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                                INPUT FALSE,
                                                                                INPUT par_indvalid,
                                                                                INPUT tt-tbconv_trans_pend.dtdebito_fatura,
                                                                                INPUT tt-tbconv_trans_pend.vlmaximo_debito,
                                                                                INPUT aux_conttran).
                                    
                                                        IF  par_indvalid = 1  THEN
                                                            ASSIGN par_flgaviso = TRUE.
                                    
                                                        UNDO TRANSACAO, LEAVE TRANSACAO. 
                                                    END.
                                            END.
                                        ELSE
                                            DO:
                                                RUN desbloqueia_lancamento IN h-b1wgen0092 (INPUT par_cdcooper,
                                                                                            INPUT par_nrdconta,
                                                                                            INPUT par_dtmvtolt,
                                                                                            INPUT tt-tbconv_trans_pend.dtdebito_fatura,
                                                                                            INPUT tt-tbconv_trans_pend.nrdocumento_fatura,
                                                                                            INPUT tt-tbconv_trans_pend.cdhist_convenio,
                                                                                            INPUT par_cdoperad,
                                                                                            INPUT par_nmdatela,
                                                                                            INPUT par_idorigem,
                                                                                            INPUT TRUE, /* par_flgerlog */
                                                                                           OUTPUT TABLE tt-erro).
                                                IF  RETURN-VALUE <> "OK" THEN
                                                    DO:
                                                        IF VALID-HANDLE(h-b1wgen0092) THEN
                                                            DELETE PROCEDURE h-b1wgen0092.
                        
                                                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                        
                                                        IF  AVAILABLE tt-erro  THEN
                                                            ASSIGN aux_dscritic = tt-erro.dscritic.
                                                        ELSE
                                                            ASSIGN aux_dscritic = "Falha ao desbloquear lancamento.".
                                                        
                                                        RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                                 INPUT "desbloqueia_lancamento",
                                                                                 INPUT "b1wgen0092",
                                                                                 INPUT par_dtmvtolt,
                                                                                 INPUT par_nrdconta,
                                                                                 INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                                 INPUT 0, /* cddbanco */
                                                                                 INPUT 0, /* ag. destino */
                                                                                 INPUT 0, /* conta destino */
                                                                                 INPUT "", /* nome titular */
                                                                                 INPUT 0, /* cpf favorecido */
                                                                                 INPUT 0, /* inpessoa favorecido */
                                                                                 INPUT 0, /* intipcta favorecido */
                                                                                 INPUT tt-tbconv_trans_pend.dtdebito_fatura,
                                                                                 INPUT "",
                                                                                 INPUT tt-tbgen_trans_pend.tptransacao,
                                                                                 INPUT 0, /* nrispbif */
                                                                                 INPUT aux_dscritic).
                                                        
                                                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                                INPUT par_cdoperad,
                                                                                INPUT aux_dscritic,
                                                                                INPUT aux_dsorigem,
                                                                                INPUT aux_dstransa,
                                                                                INPUT FALSE,
                                                                                INPUT par_nmdatela,
                                                                                INPUT par_nrdconta,
                                                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                                INPUT FALSE,
                                                                                INPUT par_indvalid,
                                                                                INPUT tt-tbconv_trans_pend.dtdebito_fatura,
                                                                                INPUT tt-tbconv_trans_pend.vlmaximo_debito,
                                                                                INPUT aux_conttran).
                                    
                                                        IF  par_indvalid = 1  THEN
                                                            ASSIGN par_flgaviso = TRUE.
                                    
                                                        UNDO TRANSACAO, LEAVE TRANSACAO. 
                                                    END.
                                            END.

                                        IF VALID-HANDLE(h-b1wgen0092) THEN
                                            DELETE PROCEDURE h-b1wgen0092.
                                    END.
                            END.
                        
                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                INPUT par_cdoperad,
                                                INPUT aux_dscritic,
                                                INPUT aux_dsorigem,
                                                INPUT aux_dstransa,
                                                INPUT FALSE,
                                                INPUT par_nmdatela,
                                                INPUT par_nrdconta,
                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                INPUT TRUE,
                                                INPUT par_indvalid,
                                                INPUT tt-tbconv_trans_pend.dtdebito_fatura,
                                                INPUT tt-tbconv_trans_pend.vlmaximo_debito,
                                                INPUT aux_conttran).

                	END.
                ELSE IF tt-tbgen_trans_pend.tptransacao = 9 THEN /* Folha de Pagamento */
                	DO: 
                        FOR FIRST tt-tbfolha_trans_pend WHERE tt-tbfolha_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK. END.
                                                    
                        /* Validação */
                        FOR FIRST crappfp WHERE crappfp.cdcooper = tt-tbfolha_trans_pend.cdcooper
                                            AND crappfp.cdempres = tt-tbfolha_trans_pend.cdempres
                                            AND crappfp.nrseqpag = tt-tbfolha_trans_pend.nrsequencia_folha NO-LOCK. END.

                        IF NOT AVAIL crappfp THEN
                            DO:
                                ASSIGN aux_dscritic = "Registro nao encontrado(CRAPPFP).".
                                        
                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                         INPUT "crappfp",
                                                         INPUT "b1wgen0016",
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_nrdconta,
                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                         INPUT 0, /* cddbanco */
                                                         INPUT 0, /* ag. destino */
                                                         INPUT 0, /* conta destino */
                                                         INPUT "", /* nome titular */
                                                         INPUT 0, /* cpf favorecido */
                                                         INPUT 0, /* inpessoa favorecido */
                                                         INPUT 0, /* intipcta favorecido */
                                                         INPUT tt-tbfolha_trans_pend.vlfolha,
                                                         INPUT "",
                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                         INPUT 0, /* nrispbif */
                                                         INPUT aux_dscritic).
                                
                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                        INPUT par_cdoperad,
                                                        INPUT aux_dscritic,
                                                        INPUT aux_dsorigem,
                                                        INPUT aux_dstransa,
                                                        INPUT FALSE,
                                                        INPUT par_nmdatela,
                                                        INPUT par_nrdconta,
                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                        INPUT FALSE,
                                                        INPUT par_indvalid,
                                                        INPUT tt-tbfolha_trans_pend.dtdebito,
                                                        INPUT tt-tbfolha_trans_pend.vlfolha,
                                                        INPUT aux_conttran).
            
                                IF  par_indvalid = 1  THEN
                                    ASSIGN par_flgaviso = TRUE.
            
                                UNDO TRANSACAO, LEAVE TRANSACAO.  
                            END.

                        IF crappfp.idsitapr = 2 THEN /* Em Estouro */
                           ASSIGN aux_idestour = 1.
                        ELSE
                           ASSIGN aux_idestour = 0.

                        IF crappfp.vllctpag <> tt-tbfolha_trans_pend.vlfolha        OR
                           crappfp.qtlctpag <> tt-tbfolha_trans_pend.nrlanctos      OR 
                           crappfp.dtdebito <> tt-tbfolha_trans_pend.dtdebito       OR                           
                           crappfp.vltarapr <> tt-tbfolha_trans_pend.vltarifa       OR
                           crappfp.idopdebi <> tt-tbfolha_trans_pend.idopcao_debito THEN
                            DO:
                                ASSIGN aux_dscritic = "A parametrizacao do pagamento foi alterada.".
                                        
                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                         INPUT "Parametros de pagamentos",
                                                         INPUT "b1wgen0016",
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_nrdconta,
                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                         INPUT 0, /* cddbanco */
                                                         INPUT 0, /* ag. destino */
                                                         INPUT 0, /* conta destino */
                                                         INPUT "", /* nome titular */
                                                         INPUT 0, /* cpf favorecido */
                                                         INPUT 0, /* inpessoa favorecido */
                                                         INPUT 0, /* intipcta favorecido */
                                                         INPUT tt-tbfolha_trans_pend.vlfolha,
                                                         INPUT "",
                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                         INPUT 0, /* nrispbif */
                                                         INPUT aux_dscritic).

                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                        INPUT par_cdoperad,
                                                        INPUT aux_dscritic,
                                                        INPUT aux_dsorigem,
                                                        INPUT aux_dstransa,
                                                        INPUT FALSE,
                                                        INPUT par_nmdatela,
                                                        INPUT par_nrdconta,
                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                        INPUT FALSE,
                                                        INPUT par_indvalid,
                                                        INPUT tt-tbfolha_trans_pend.dtdebito,
                                                        INPUT tt-tbfolha_trans_pend.vlfolha,
                                                        INPUT aux_conttran).
            
                                IF  par_indvalid = 1  THEN
                                    ASSIGN par_flgaviso = TRUE.
            
                                UNDO TRANSACAO, LEAVE TRANSACAO. 
                            END.

                        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
         
                        /* Efetuar a chamada a rotina Oracle */ 
                        RUN STORED-PROCEDURE pc_obtem_rowid_folha
                           aux_handproc = PROC-HANDLE NO-ERROR (INPUT tt-tbfolha_trans_pend.cdcooper,          /* Código da Cooperativa */
                                                                INPUT tt-tbfolha_trans_pend.cdempres,          /* Código do Operador */
                                                                INPUT tt-tbfolha_trans_pend.nrsequencia_folha, /* Nome da Tela */
                                                               OUTPUT "",                                       /* ROWID da folha de pagamento */
                                                               OUTPUT 0,                                       /* Código da crítica */
                                                               OUTPUT "").                                     /* Descricao da critica */
                        
                        /* Fechar o procedimento para buscarmos o resultado */ 
                        CLOSE STORED-PROC pc_obtem_rowid_folha
                              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                        
                        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
                        
                        /* Busca possíveis erros */ 
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = ""
                               aux_rowidpag = ""
                               aux_rowidpag = pc_obtem_rowid_folha.pr_rowidpag 
                                              WHEN pc_obtem_rowid_folha.pr_rowidpag <> ?
                               aux_cdcritic = pc_obtem_rowid_folha.pr_cdcritic 
                                              WHEN pc_obtem_rowid_folha.pr_cdcritic <> ?
                               aux_dscritic = pc_obtem_rowid_folha.pr_dscritic 
                                              WHEN pc_obtem_rowid_folha.pr_dscritic <> ?.
                        
                        IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                            DO:
                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                         INPUT "pc_obtem_rowid_folha",
                                                         INPUT "b1wgen0016",
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_nrdconta,
                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                         INPUT 0, /* cddbanco */
                                                         INPUT 0, /* ag. destino */
                                                         INPUT 0, /* conta destino */
                                                         INPUT "", /* nome titular */
                                                         INPUT 0, /* cpf favorecido */
                                                         INPUT 0, /* inpessoa favorecido */
                                                         INPUT 0, /* intipcta favorecido */
                                                         INPUT tt-tbfolha_trans_pend.vlfolha,
                                                         INPUT "",
                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                         INPUT 0, /* nrispbif */
                                                         INPUT aux_dscritic).

                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                        INPUT par_cdoperad,
                                                        INPUT aux_dscritic,
                                                        INPUT aux_dsorigem,
                                                        INPUT aux_dstransa,
                                                        INPUT FALSE,
                                                        INPUT par_nmdatela,
                                                        INPUT par_nrdconta,
                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                        INPUT FALSE,
                                                        INPUT par_indvalid,
                                                        INPUT tt-tbfolha_trans_pend.dtdebito,
                                                        INPUT tt-tbfolha_trans_pend.vlfolha,
                                                        INPUT aux_conttran).
            
                                IF par_indvalid = 1 THEN
                                    ASSIGN par_flgaviso = TRUE.
            
                                UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.
                        
                        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                        RUN STORED-PROCEDURE pc_valida_pagto_ib aux_handproc = PROC-HANDLE NO-ERROR
                                             (INPUT par_cdcooper,
                                              INPUT par_nrdconta,
                                              INPUT par_dtmvtolt,
                                              INPUT aux_rowidpag,
                                              INPUT IF aux_conttran = 1 THEN 1 ELSE 0,
                                              INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                              OUTPUT "",
                                              OUTPUT "",
                                              OUTPUT "").

                        CLOSE STORED-PROC pc_valida_pagto_ib aux_statproc = PROC-STATUS
                              WHERE PROC-HANDLE = aux_handproc.
                    
                        ASSIGN aux_des_reto = ""
                               aux_dscritic = ""
                               aux_des_reto = pc_valida_pagto_ib.pr_des_reto
                                              WHEN pc_valida_pagto_ib.pr_des_reto <> ?
                               aux_dscritic = pc_valida_pagto_ib.pr_dscritic
                                              WHEN pc_valida_pagto_ib.pr_dscritic <> ?.
                    
                        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                    
                        IF tt-tbfolha_trans_pend.idestouro = 1 AND 
                           aux_des_reto <> "OK" THEN
                            DO: 
                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                         INPUT "pc_valida_pagto_ib",
                                                         INPUT "b1wgen0016",
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_nrdconta,
                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                         INPUT 0, /* cddbanco */
                                                         INPUT 0, /* ag. destino */
                                                         INPUT 0, /* conta destino */
                                                         INPUT "", /* nome titular */
                                                         INPUT 0, /* cpf favorecido */
                                                         INPUT 0, /* inpessoa favorecido */
                                                         INPUT 0, /* intipcta favorecido */
                                                         INPUT tt-tbfolha_trans_pend.vlfolha,
                                                         INPUT "",
                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                         INPUT 0, /* nrispbif */
                                                         INPUT aux_dscritic).

                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                        INPUT par_cdoperad,
                                                        INPUT aux_dscritic,
                                                        INPUT aux_dsorigem,
                                                        INPUT aux_dstransa,
                                                        INPUT FALSE,
                                                        INPUT par_nmdatela,
                                                        INPUT par_nrdconta,
                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                        INPUT FALSE,
                                                        INPUT par_indvalid,
                                                        INPUT tt-tbfolha_trans_pend.dtdebito,
                                                        INPUT tt-tbfolha_trans_pend.vlfolha,
                                                        INPUT aux_conttran).
            
                                IF par_indvalid = 1 THEN
                                    ASSIGN par_flgaviso = TRUE.
            
                                UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.
                        ELSE IF tt-tbfolha_trans_pend.idestouro = 0 AND 
                                (aux_des_reto <> "OK" OR aux_dscritic <> "") THEN
                            DO:
                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                         INPUT "pc_valida_pagto_ib",
                                                         INPUT "b1wgen0016",
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_nrdconta,
                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                         INPUT 0, /* cddbanco */
                                                         INPUT 0, /* ag. destino */
                                                         INPUT 0, /* conta destino */
                                                         INPUT "", /* nome titular */
                                                         INPUT 0, /* cpf favorecido */
                                                         INPUT 0, /* inpessoa favorecido */
                                                         INPUT 0, /* intipcta favorecido */
                                                         INPUT tt-tbfolha_trans_pend.vlfolha,
                                                         INPUT "",
                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                         INPUT 0, /* nrispbif */
                                                         INPUT aux_dscritic).

                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                        INPUT par_cdoperad,
                                                        INPUT aux_dscritic,
                                                        INPUT aux_dsorigem,
                                                        INPUT aux_dstransa,
                                                        INPUT FALSE,
                                                        INPUT par_nmdatela,
                                                        INPUT par_nrdconta,
                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                        INPUT FALSE,
                                                        INPUT par_indvalid,
                                                        INPUT tt-tbfolha_trans_pend.dtdebito,
                                                        INPUT tt-tbfolha_trans_pend.vlfolha,
                                                        INPUT aux_conttran).
            
                                IF par_indvalid = 1 THEN
                                    ASSIGN par_flgaviso = TRUE.
            
                                UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.           
                        
                        /* Efetivação */
                        IF par_indvalid = 1 AND aux_conttran = 1 THEN
                            DO:
                                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
                 
                                /* Efetuar a chamada a rotina Oracle */ 
                                RUN STORED-PROCEDURE pc_obtem_rowid_folha
                                   aux_handproc = PROC-HANDLE NO-ERROR (INPUT tt-tbfolha_trans_pend.cdcooper,          /* Código da Cooperativa */
                                                                        INPUT tt-tbfolha_trans_pend.cdempres,          /* Código do Operador */
                                                                        INPUT tt-tbfolha_trans_pend.nrsequencia_folha, /* Nome da Tela */
                                                                       OUTPUT "",                                       /* ROWID da folha de pagamento */
                                                                       OUTPUT 0,                                       /* Código da crítica */
                                                                       OUTPUT "").                                     /* Descricao da critica */
                                
                                /* Fechar o procedimento para buscarmos o resultado */ 
                                CLOSE STORED-PROC pc_obtem_rowid_folha
                                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                                
                                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
                                
                                /* Busca possíveis erros */ 
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = ""
                                       aux_rowidpag = ""
                                       aux_rowidpag = pc_obtem_rowid_folha.pr_rowidpag 
                                                      WHEN pc_obtem_rowid_folha.pr_rowidpag <> ?
                                       aux_cdcritic = pc_obtem_rowid_folha.pr_cdcritic 
                                                      WHEN pc_obtem_rowid_folha.pr_cdcritic <> ?
                                       aux_dscritic = pc_obtem_rowid_folha.pr_dscritic 
                                                      WHEN pc_obtem_rowid_folha.pr_dscritic <> ?.
                                
                                IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                                    DO:
                                        RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                 INPUT "pc_obtem_rowid_folha",
                                                                 INPUT "b1wgen0016",
                                                                 INPUT par_dtmvtolt,
                                                                 INPUT par_nrdconta,
                                                                 INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                 INPUT 0, /* cddbanco */
                                                                 INPUT 0, /* ag. destino */
                                                                 INPUT 0, /* conta destino */
                                                                 INPUT "", /* nome titular */
                                                                 INPUT 0, /* cpf favorecido */
                                                                 INPUT 0, /* inpessoa favorecido */
                                                                 INPUT 0, /* intipcta favorecido */
                                                                 INPUT tt-tbfolha_trans_pend.vlfolha,
                                                                 INPUT "",
                                                                 INPUT tt-tbgen_trans_pend.tptransacao,
                                                                 INPUT 0, /* nrispbif */
                                                                 INPUT aux_dscritic).

                                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                INPUT par_cdoperad,
                                                                INPUT aux_dscritic,
                                                                INPUT aux_dsorigem,
                                                                INPUT aux_dstransa,
                                                                INPUT FALSE,
                                                                INPUT par_nmdatela,
                                                                INPUT par_nrdconta,
                                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                INPUT FALSE,
                                                                INPUT par_indvalid,
                                                                INPUT tt-tbfolha_trans_pend.dtdebito,
                                                                INPUT tt-tbfolha_trans_pend.vlfolha,
                                                                INPUT aux_conttran).
                    
                                        IF par_indvalid = 1 THEN
                                            ASSIGN par_flgaviso = TRUE.
                    
                                        UNDO TRANSACAO, LEAVE TRANSACAO.
                                    END.
                                
                                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
                 
                                /* Efetuar a chamada a rotina Oracle */ 
                                RUN STORED-PROCEDURE pc_aprovar_pagto_ib
                                   aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                                       ,INPUT par_nrdconta
                                                                       ,INPUT par_dtmvtolt
                                                                       ,INPUT tt-tbgen_trans_pend.nrcpf_operador
                                                                       ,INPUT tt-tbfolha_trans_pend.idestouro
                                                                       ,INPUT aux_rowidpag
                                                                      ,OUTPUT ""
                                                                      ,OUTPUT ""
                                                                      ,OUTPUT "").
                                
                                /* Fechar o procedimento para buscarmos o resultado */ 
                                CLOSE STORED-PROC pc_aprovar_pagto_ib
                                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                                
                                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                                
                                /* Busca possíveis erros */ 
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = ""
                                       aux_des_reto = ""
                                       aux_des_reto = pc_aprovar_pagto_ib.pr_des_reto
                                                      WHEN pc_aprovar_pagto_ib.pr_des_reto <> ?
                                       aux_dsalerta = pc_aprovar_pagto_ib.pr_dsalerta 
                                                      WHEN pc_aprovar_pagto_ib.pr_dsalerta <> ?
                                       aux_dscritic = pc_aprovar_pagto_ib.pr_dscritic 
                                                      WHEN pc_aprovar_pagto_ib.pr_dscritic <> ?.
                                
                                IF aux_cdcritic > 0 OR aux_dscritic <> "" OR aux_des_reto <> "OK" THEN
                                    DO:
                                        RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                                 INPUT "pc_aprovar_pagto_ib",
                                                                 INPUT "b1wgen0016",
                                                                 INPUT par_dtmvtolt,
                                                                 INPUT par_nrdconta,
                                                                 INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                                 INPUT 0, /* cddbanco */
                                                                 INPUT 0, /* ag. destino */
                                                                 INPUT 0, /* conta destino */
                                                                 INPUT "", /* nome titular */
                                                                 INPUT 0, /* cpf favorecido */
                                                                 INPUT 0, /* inpessoa favorecido */
                                                                 INPUT 0, /* intipcta favorecido */
                                                                 INPUT tt-tbfolha_trans_pend.vlfolha,
                                                                 INPUT "",
                                                                 INPUT tt-tbgen_trans_pend.tptransacao,
                                                                 INPUT 0, /* nrispbif */
                                                                 INPUT aux_dscritic).

                                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                INPUT par_cdoperad,
                                                                INPUT aux_dscritic,
                                                                INPUT aux_dsorigem,
                                                                INPUT aux_dstransa,
                                                                INPUT FALSE,
                                                                INPUT par_nmdatela,
                                                                INPUT par_nrdconta,
                                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                INPUT FALSE,
                                                                INPUT par_indvalid,
                                                                INPUT tt-tbfolha_trans_pend.dtdebito,
                                                                INPUT tt-tbfolha_trans_pend.vlfolha,
                                                                INPUT aux_conttran).
                    
                                        IF par_indvalid = 1 THEN
                                            ASSIGN par_flgaviso = TRUE.
                    
                                        UNDO TRANSACAO, LEAVE TRANSACAO.
                                    END.
                            END.        
                        
                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                INPUT par_cdoperad,
                                                INPUT aux_dscritic,
                                                INPUT aux_dsorigem,
                                                INPUT aux_dstransa,
                                                INPUT FALSE,
                                                INPUT par_nmdatela,
                                                INPUT par_nrdconta,
                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                INPUT TRUE,
                                                INPUT par_indvalid,
                                                INPUT tt-tbfolha_trans_pend.dtdebito,
                                                INPUT tt-tbfolha_trans_pend.vlfolha,
                                                INPUT aux_conttran).
                	END.
                ELSE IF tt-tbgen_trans_pend.tptransacao = 10 THEN /* Pacote de Tarifas */
                	DO: 
                        FOR FIRST tt-tbtarif_pacote_trans_pend WHERE tt-tbtarif_pacote_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK. END.
                        
                        /* Efetivação */
                        IF  par_indvalid = 1 AND aux_conttran = 1 THEN
                            DO:
                                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                                RUN STORED-PROCEDURE pc_insere_pacote_conta
                                    aux_handproc = PROC-HANDLE NO-ERROR
                                                     (INPUT par_cdcooper,
                                                      INPUT par_nrdconta,
                                 					  INPUT par_nrcpfope,
                                					  INPUT par_idseqttl,
                                					  INPUT tt-tbtarif_pacote_trans_pend.cdpacote,
                                					  INPUT tt-tbtarif_pacote_trans_pend.dtinicio_vigencia,
                                                      INPUT tt-tbtarif_pacote_trans_pend.nrdiadebito,
                                                      INPUT tt-tbtarif_pacote_trans_pend.vlpacote,
                                                      INPUT tt-tbtarif_pacote_trans_pend.cdtransacao_pendente,
                                					  INPUT 2,
													  INPUT 1,
                                                      OUTPUT "",
                                                      OUTPUT 0,
                                                      OUTPUT "").
                                
                                CLOSE STORED-PROC pc_insere_pacote_conta 
                                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
                     
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = ""
                                       aux_cdcritic = pc_insere_pacote_conta.pr_cdcritic
                                                      WHEN pc_insere_pacote_conta.pr_cdcritic <> ?
                                       aux_dscritic = pc_insere_pacote_conta.pr_dscritic
                                                      WHEN pc_insere_pacote_conta.pr_dscritic <> ?.
                                       
                                
                                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                                
                                IF  aux_cdcritic <> 0   OR
                                    aux_dscritic <> ""  THEN DO: 
                                
                                    IF  aux_dscritic = "" THEN DO:
                                        FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                                                   NO-LOCK NO-ERROR.
                                
                                        IF  AVAIL crapcri THEN
                                            ASSIGN aux_dscritic = crapcri.dscritic.
                                        ELSE
                                            ASSIGN aux_dscritic =  "Nao foi possivel incluir o servico".
                                    END.
                     
                                    RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                             INPUT "pc_insere_pacote_conta",
                                                             INPUT "b1wgen0016",
                                                             INPUT par_dtmvtolt,
                                                             INPUT par_nrdconta,
                                                             INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                             INPUT 0, /* cddbanco */
                                                             INPUT 0, /* ag. destino */
                                                             INPUT 0, /* conta destino */
                                                             INPUT "", /* nome titular */
                                                             INPUT 0, /* cpf favorecido */
                                                             INPUT 0, /* inpessoa favorecido */
                                                             INPUT 0, /* intipcta favorecido */
                                                             INPUT tt-tbtarif_pacote_trans_pend.vlpacote,
                                                             INPUT "",
                                                             INPUT tt-tbgen_trans_pend.tptransacao,
                                                             INPUT 0, /* nrispbif */
                                                             INPUT aux_dscritic).

                                    RUN gera_erro_transacao(INPUT par_cdcooper,
                                                            INPUT par_cdoperad,
                                                            INPUT aux_dscritic,
                                                            INPUT aux_dsorigem,
                                                            INPUT aux_dstransa,
                                                            INPUT FALSE,
                                                            INPUT par_nmdatela,
                                                            INPUT par_nrdconta,
                                                            INPUT STRING(ROWID(tbgen_trans_pend)),
                                                            INPUT FALSE,
                                                            INPUT par_indvalid,
                                                            INPUT DATE(1, MONTH(TODAY), YEAR(TODAY)),
                                                            INPUT tt-tbtarif_pacote_trans_pend.vlpacote,
                                                            INPUT aux_conttran).
                
                IF par_indvalid = 1 THEN
                                        ASSIGN par_flgaviso = TRUE.
                
                                    UNDO TRANSACAO, LEAVE TRANSACAO.
                                    
                                END.

                            END.

                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                INPUT par_cdoperad,
                                                INPUT aux_dscritic,
                                                INPUT aux_dsorigem,
                                                INPUT aux_dstransa,
                                                INPUT FALSE,
                                                INPUT par_nmdatela,
                                                INPUT par_nrdconta,
                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                INPUT TRUE,
                                                INPUT par_indvalid,
                                                INPUT DATE(1, MONTH(TODAY), YEAR(TODAY)),
                                                INPUT tt-tbtarif_pacote_trans_pend.vlpacote,
                                                INPUT aux_conttran).
                    END.
                                /* Contrato SMS */
                                ELSE IF tt-tbgen_trans_pend.tptransacao = 16 OR
                                tt-tbgen_trans_pend.tptransacao = 17 THEN
                                DO:
                                FOR FIRST tt-tbcobran_sms_trans_pend WHERE tt-tbcobran_sms_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK. END.
                                                                                                                                                                  
                                                                                                                                                                  
                                    /** ADESAO **/
                                    IF tt-tbgen_trans_pend.tptransacao = 16 THEN
                                    DO:
                                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                                                                                                                                                                    
                                    RUN STORED-PROCEDURE pc_gera_contrato_sms
                                    aux_handproc = PROC-HANDLE NO-ERROR
                                    ( INPUT par_cdcooper   /* pr_cdcooper  */
                                    ,INPUT par_nrdconta   /* pr_nrdconta  */
                                    ,INPUT par_idseqttl   /* pr_idseqttl  */
                                    ,INPUT 3              /* pr_idorigem  */
                                    ,INPUT '996'          /* pr_cdoperad  */
                                    ,INPUT 'INTERNETBANK' /* pr_nmdatela  */
                                    ,INPUT par_nrcpfope   /* pr_nrcpfope  */
                                    /* se for efetivacao e o ultima aprovacao, mandar 1 */
                                    ,INPUT IF par_indvalid = 1 AND
                                    aux_conttran = 1 THEN 1
                                    ELSE  3        /* pr_inaprpen */
                                    ,tt-tbcobran_sms_trans_pend.idpacote /* pr_idpacote */
                                    ,1                    /* pr_tpnmemis */
                                    ,""                   /* pr_nmemissa */
                                    
                                    ,OUTPUT 0              /* pr_idcontrato */
                                    ,OUTPUT ""             /* pr_dsretorn */
                                    ,OUTPUT 0
                                    ,OUTPUT "").           /* par_dscritic */
                                                                                                                                                                    
                                    CLOSE STORED-PROC pc_gera_contrato_sms
                                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                                                                                                                                                                    
                                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                                                                                                                                                                    
                                    ASSIGN aux_dscritic = ""
                                    aux_dsretorn = ""
                                    aux_cdcritic = 0
                                    aux_dsretorn = pc_gera_contrato_sms.pr_dsretorn
                                    WHEN pc_gera_contrato_sms.pr_dsretorn <> ?
                                    aux_cdcritic = pc_gera_contrato_sms.pr_cdcritic
                                    WHEN pc_gera_contrato_sms.pr_cdcritic <> ?
                                    aux_dscritic = pc_gera_contrato_sms.pr_dscritic
                                    WHEN pc_gera_contrato_sms.pr_dscritic <> ?.
                                    END.
                                                                                                                                                                  
                                    /** Cancelamento **/
                                    ELSE IF tt-tbgen_trans_pend.tptransacao = 17  THEN
                                    DO:
                                    /* Cancelar contrato de servico de SMS de cobranca */
                                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                                                                                                                                                                    
                                    RUN STORED-PROCEDURE pc_cancel_contrato_sms
                                    aux_handproc = PROC-HANDLE NO-ERROR
                                    ( INPUT par_cdcooper     /* pr_cdcooper  */
                                    ,INPUT par_nrdconta     /* pr_nrdconta  */
                                    ,INPUT par_idseqttl     /* pr_idseqttl  */
                                    ,INPUT 0                /* pr_idcontrato*/
                                    ,INPUT 3                /* pr_idorigem  */
                                    ,INPUT '996'            /* pr_cdoperad  */
                                    ,INPUT 'INTERNETBANK'   /* pr_nmdatela  */
                                    ,INPUT par_nrcpfope     /* pr_nrcpfope  */
                                    /* se for efetivacao e o ultima aprovacao, mandar 1 */
                                    ,INPUT IF par_indvalid = 1 AND
                                    aux_conttran = 1 THEN 1
                                    ELSE  3        /* pr_inaprpen */
                                    ,OUTPUT ""               /* pr_dsretorn  */
                                    ,OUTPUT 0
                                    ,OUTPUT "").             /* par_dscritic */
                                                                                                                                                                    
                                    CLOSE STORED-PROC pc_cancel_contrato_sms
                                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                                                                                                                                                                    
                                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                                                                                                                                                                    
                                    ASSIGN aux_dscritic = ""
                                    aux_dsretorn = ""
                                    aux_cdcritic = 0
                                    aux_dsretorn = pc_cancel_contrato_sms.pr_dsretorn
                                    WHEN pc_cancel_contrato_sms.pr_dsretorn <> ?
                                    aux_cdcritic = pc_cancel_contrato_sms.pr_cdcritic
                                    WHEN pc_cancel_contrato_sms.pr_cdcritic <> ?
                                    aux_dscritic = pc_cancel_contrato_sms.pr_dscritic
                                    WHEN pc_cancel_contrato_sms.pr_dscritic <> ?.
                                    END.
                                                                                                                                                                  
                                    IF  aux_cdcritic <> 0   OR
                                    aux_dscritic <> ""  THEN DO:
                                    IF  aux_dscritic = "" THEN DO:
                                        FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                        NO-LOCK NO-ERROR.
                                                                                                                                                                      
                                        IF  AVAIL crapcri THEN
                                        ASSIGN aux_dscritic = crapcri.dscritic.
                                        ELSE
                                        ASSIGN aux_dscritic =  "Nao foi possivel incluir o servico".
                                    END.
                                                                                                                                                                    
                                    RUN gera_erro_transacao(INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                    INPUT STRING(ROWID(tbgen_trans_pend)),
                                    INPUT FALSE,
                                    INPUT par_indvalid,
                                    INPUT DATE(1, MONTH(TODAY), YEAR(TODAY)),
                                    INPUT tt-tbcobran_sms_trans_pend.vlservico,
                                    INPUT aux_conttran).
                                                                                                                                                                    
                                    IF par_indvalid = 1 THEN
                                    ASSIGN par_flgaviso = TRUE.
                                                                                                                                                                    
                                    UNDO TRANSACAO, LEAVE TRANSACAO.
                                    END. /* fim IF critica THEN*/
                                                                                                                                                                  
                                    /* Log de Sucesso*/
                                    RUN gera_erro_transacao(INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                    INPUT STRING(ROWID(tbgen_trans_pend)),
                                    INPUT TRUE,
                                    INPUT par_indvalid,
                                    INPUT DATE(1, MONTH(TODAY), YEAR(TODAY)),
                                    INPUT tt-tbcobran_sms_trans_pend.vlservico,
                                    INPUT aux_conttran).
                                                                                                                                                                  
                                END.
                 ELSE IF tt-tbgen_trans_pend.tptransacao = 11 THEN /* Pagamento DARF/DAS */
                  DO: 
                    FOR FIRST tt-tbpagto_darf_das_trans_pend WHERE tt-tbpagto_darf_das_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK. END.
                    
                    FIND FIRST tt-vlrdat WHERE tt-vlrdat.dattrans = tt-tbpagto_darf_das_trans_pend.dtdebito NO-LOCK NO-ERROR NO-WAIT.

                    /* Procedimento do internetbank pc_verifica_operacao_prog */
                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                    RUN STORED-PROCEDURE pc_verifica_operacao_prog
                        aux_handproc = PROC-HANDLE NO-ERROR      
                          (INPUT  par_cdcooper
                          ,INPUT  par_cdagenci
                          ,INPUT  par_nrdcaixa
                          ,INPUT  par_nrdconta
                          ,INPUT  par_idseqttl        
                          ,INPUT  par_dtmvtolt
                          ,INPUT  tt-tbpagto_darf_das_trans_pend.idagendamento
                          ,INPUT  tt-tbpagto_darf_das_trans_pend.dtdebito
                          ,INPUT  (IF par_indvalid = 0 AND aux_conttran = 1 AND AVAIL tt-vlrdat THEN 
                                    tt-vlrdat.vlronlin /* Valor Total Composto */
                                  ELSE tt-tbpagto_darf_das_trans_pend.vlpagamento)
                          ,INPUT  0            /* par_cddbanco */
                          ,INPUT  0            /* par_cdageban */
                          ,INPUT  0            /* par_nrctatrf */
                          ,INPUT  10           /* par_cdtiptra - DARF/DAS */
                          ,INPUT  par_cdoperad /* par_cdoperad */
                          ,INPUT  10           /* par_tpoperac - DARF/DAS */
                          ,INPUT  1            /* par_flgvalid*/
                          ,INPUT  aux_dsorigem /* par_dsorigem */
                          ,INPUT  0
                          ,INPUT  1            /* par_flgctrag */
                          ,INPUT  ""           /* par_nmdatela */
                          ,OUTPUT aux_dstransa
                          ,OUTPUT ""           /* --> Retorno XML pr_tab_limite      */
                          ,OUTPUT ""           /* --> Retorno XML pr_tab_internet    */
                          ,OUTPUT 0            /* --> Retorno pr_cdcritic            */
                          ,OUTPUT "").         /* --> Retorno pr_dscritic (OK ou NOK)*/
                                            
                    IF  ERROR-STATUS:ERROR  THEN DO:
                        DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
                            ASSIGN aux_msgerora = aux_msgerora + 
                                                  ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
                        END.
                                                                         
                        ASSIGN aux_dscritic = "pc_verifica_operacao_prog --> "  +
                                              "Erro ao executar Stored Procedure: " +
                                              aux_msgerora.      
                        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + 
                                                   "Erro inesperado. Nao foi possivel efetuar a verificacao." + 
                                                   " Tente novamente ou contacte seu PA" +
                                              "</dsmsgerr>".                        
                        RUN proc_geracao_log.
                        RETURN "NOK".
                        
                    END. 

                    CLOSE STORED-PROC pc_verifica_operacao_prog
                          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl}}

                    ASSIGN aux_dscritic   = pc_verifica_operacao_prog.pr_dscritic 
                                            WHEN pc_verifica_operacao_prog.pr_dscritic <> ?                               
                           aux_tab_limite = pc_verifica_operacao_prog.pr_tab_limite 
                                            WHEN pc_verifica_operacao_prog.pr_tab_limite <> ? .                      
                                            
                    /* Verificar se retornou critica */
                    IF aux_dscritic <> "" THEN
                      DO:
                        /* Gerar log das teds com erro */
                        RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                 INPUT "verifica_operacao",
                                                 INPUT "b1wgen0015",
                                                 INPUT par_dtmvtolt,
                                                 INPUT par_nrdconta,
                                                 INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                 INPUT 0,
                                                 INPUT 0,
                                                 INPUT 0,
                                                 INPUT "",
                                                 INPUT 0,
                                                 INPUT 0,
                                                 INPUT 0,
                                                 INPUT tt-tbpagto_darf_das_trans_pend.vlpagamento,
                                                 INPUT "",
                                                 INPUT tt-tbgen_trans_pend.tptransacao,
                                                 INPUT 0,
                                                 INPUT aux_dscritic).

                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                INPUT par_cdoperad,
                                                INPUT aux_dscritic,
                                                INPUT aux_dsorigem,
                                                INPUT aux_dstransa,
                                                INPUT FALSE,
                                                INPUT par_nmdatela,
                                                INPUT par_nrdconta,
                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                INPUT FALSE,
                                                INPUT par_indvalid,
                                                INPUT tt-tbpagto_darf_das_trans_pend.dtdebito,
                                                INPUT tt-tbpagto_darf_das_trans_pend.vlpagamento,
                                                INPUT aux_conttran).

                        IF par_indvalid = 1 THEN
                          ASSIGN par_flgaviso = TRUE.

                        UNDO TRANSACAO, LEAVE TRANSACAO.
                      END.
                    
                    ASSIGN aux_lindigi1 = DECI(SUBSTR(tt-tbpagto_darf_das_trans_pend.dslinha_digitavel,1,11)  + 
                                               SUBSTR(tt-tbpagto_darf_das_trans_pend.dslinha_digitavel,13,1))
                           aux_lindigi2 = DECI(SUBSTR(tt-tbpagto_darf_das_trans_pend.dslinha_digitavel,15,11) + 
                                               SUBSTR(tt-tbpagto_darf_das_trans_pend.dslinha_digitavel,27,1))
                           aux_lindigi3 = DECI(SUBSTR(tt-tbpagto_darf_das_trans_pend.dslinha_digitavel,29,11) + 
                                               SUBSTR(tt-tbpagto_darf_das_trans_pend.dslinha_digitavel,41,1))
                           aux_lindigi4 = DECI(SUBSTR(tt-tbpagto_darf_das_trans_pend.dslinha_digitavel,43,11) + 
                                               SUBSTR(tt-tbpagto_darf_das_trans_pend.dslinha_digitavel,55,1)).
                      
                    /* Procedimento do internetbank pc_verifica_operacao_prog */
                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                    RUN STORED-PROCEDURE pc_verifica_tributos
                      aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper,                                   /* Código da cooperativa */
                                                          INPUT par_nrdconta,                                   /* Número da conta */
                                                          INPUT par_idseqttl,                                   /* Sequencial de titularidade */
                                                          INPUT par_idorigem,                                   /* Canal de origem da operaçao */
                                                          INPUT tt-tbpagto_darf_das_trans_pend.tppagamento,     /* Tipo da guia (1 – DARF / 2 – DAS) */
                                                          INPUT tt-tbpagto_darf_das_trans_pend.tpcaptura,       /* Tipo de captura da guia (1-Código Barras / 2-Manual) */
                                                          INPUT aux_lindigi1,                                   /* Primeiro campo da linha digitável da guia */
                                                          INPUT aux_lindigi2,                                   /* Segundo campo da linha digitável da guia */
                                                          INPUT aux_lindigi3,                                   /* Terceiro campo da linha digitável da guia */
                                                          INPUT aux_lindigi4,                                   /* Quarto campo da linha digitável da guia */
                                                          INPUT tt-tbpagto_darf_das_trans_pend.dscod_barras,    /* Código de barras da guia */
                                                          INPUT tt-tbpagto_darf_das_trans_pend.vlpagamento,     /* Valor total do pagamento da guia */
                                                          INPUT tt-tbpagto_darf_das_trans_pend.dtapuracao ,      /* Período de apuraçao da guia */
                                                          INPUT tt-tbpagto_darf_das_trans_pend.nrcpfcgc ,        /* CPF/CNPJ da guia */
                                                          INPUT tt-tbpagto_darf_das_trans_pend.cdtributo ,       /* Código de tributaçao da guia */
                                                          INPUT STRING(tt-tbpagto_darf_das_trans_pend.nrrefere), /* Número de referencia da guia */
                                                          INPUT tt-tbpagto_darf_das_trans_pend.dtvencto,        /* Data de vencimento da guia */
                                                          INPUT tt-tbpagto_darf_das_trans_pend.vlprincipal,     /* Valor principal da guia */
                                                          INPUT tt-tbpagto_darf_das_trans_pend.vlmulta,         /* Valor da multa da guia */
                                                          INPUT tt-tbpagto_darf_das_trans_pend.vljuros,         /* Valor dos juros da guia */
                                                          INPUT tt-tbpagto_darf_das_trans_pend.vlreceita_bruta, /* Valor da receita bruta acumulada da guia */
                                                          INPUT tt-tbpagto_darf_das_trans_pend.vlpercentual,    /* Valor do percentual da guia */
                                                          INPUT tt-tbpagto_darf_das_trans_pend.idagendamento,   /* Indicador de agendamento (1-Nesta Data/2-Agendamento */
                                                          INPUT tt-tbpagto_darf_das_trans_pend.dtdebito,        /* Data de agendamento */
                                                          INPUT 0,                                    /* Indicador de controle de validaçoes (1-Operaçao Online/2-Operaçao Batch) */
                                                          INPUT 0,                                    /* Indicador mobile */
                                                         OUTPUT "",                                              /* Código sequencial da guia */
                                                         OUTPUT 0,                                              /* Digito do Faturamento */
                                                         OUTPUT 0,                                              /* Valor da guia */
                                                         OUTPUT 0,                                              /* Código do erro */
                                                         OUTPUT ?).                                             /* Descriçao do erro */
                                        
                    /* Fechar o procedimento para buscarmos o resultado */ 
                    CLOSE STORED-PROC pc_verifica_tributos
                          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                    
                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                    
                    /* Busca possíveis erros */ 
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = ""
                           aux_cdcritic = pc_verifica_tributos.pr_cdcritic 
                                          WHEN pc_verifica_tributos.pr_dscritic <> ?
                           aux_dscritic = pc_verifica_tributos.pr_dscritic 
                                          WHEN pc_verifica_tributos.pr_dscritic <> ?
                           aux_cdseqdrf = pc_verifica_tributos.pr_cdseqfat
                           aux_vldocmto = pc_verifica_tributos.pr_vldocmto
                           aux_nrdigfat = pc_verifica_tributos.pr_nrdigfat.
                    
                    IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                      DO:
                        RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                 INPUT "pc_verifica_tributos",
                                                 INPUT "b1wgen0016",
                                                 INPUT par_dtmvtolt,
                                                 INPUT par_nrdconta,
                                                 INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                 INPUT 0, /* cddbanco */
                                                 INPUT 0, /* ag. destino */
                                                 INPUT 0, /* conta destino */
                                                 INPUT "", /* nome titular */
                                                 INPUT 0, /* cpf favorecido */
                                                 INPUT 0, /* inpessoa favorecido */
                                                 INPUT 0, /* intipcta favorecido */
                                                 INPUT tt-tbpagto_darf_das_trans_pend.vlpagamento,
                                                 INPUT "",
                                                 INPUT tt-tbgen_trans_pend.tptransacao,
                                                 INPUT 0, /* nrispbif */
                                                 INPUT aux_dscritic).

                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                INPUT par_cdoperad,
                                                INPUT aux_dscritic,
                                                INPUT aux_dsorigem,
                                                INPUT aux_dstransa,
                                                INPUT FALSE,
                                                INPUT par_nmdatela,
                                                INPUT par_nrdconta,
                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                INPUT FALSE,
                                                INPUT par_indvalid,
                                                INPUT tt-tbpagto_darf_das_trans_pend.dtdebito,
                                                INPUT tt-tbpagto_darf_das_trans_pend.vlpagamento,
                                                INPUT aux_conttran).
    
                        IF par_indvalid = 1 THEN
                            ASSIGN par_flgaviso = TRUE.
    
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                      END.
                               
                  /* Se for agendamento de DARF-DAS */
                  IF  tt-tbpagto_darf_das_trans_pend.idagendamento = 2 THEN
                      DO: 
                          /* Verificar horario de inicio da DEBSIC */
                          FIND FIRST craphec WHERE craphec.cdcooper = par_cdcooper 
                                               AND craphec.cdprogra = "DEBSIC"
                                               NO-LOCK NO-ERROR.
                                               
                          IF  AVAILABLE craphec THEN
                              DO:
                                  /*  Aceitar ate o horario de inicio da DEBSIC */
                                  IF  TIME >= craphec.hriniexe AND 
                                      tt-tbpagto_darf_das_trans_pend.dtdebito = par_dtmvtolt THEN
                                      DO:
                                         ASSIGN aux_cdcritic = 0
                                                aux_dscritic = "Horario esgotado para pagamentos.".
                          
                                         RUN gera_erro (INPUT par_cdcooper,
                                                        INPUT par_cdagenci,
                                                        INPUT par_nrdcaixa,
                                                        INPUT 1,            /** Sequencia **/
                                                        INPUT aux_cdcritic,
                                                        INPUT-OUTPUT aux_dscritic).
                                          
                                          IF  par_flgerlog THEN
                                              DO:
                                                  RUN proc_gerar_log (INPUT par_cdcooper,
                                                                      INPUT par_cdoperad,
                                                                      INPUT aux_dscritic,
                                                                      INPUT aux_dsorigem,
                                                                      INPUT aux_dstransa,
                                                                      INPUT FALSE,
                                                                      INPUT 1,
                                                                      INPUT par_nmdatela,
                                                                      INPUT par_nrdconta,
                                                                     OUTPUT aux_nrdrowid).
                                              END.
                                  RETURN "NOK".
                                      END.
                              END.
                      END.
                               
                    /* Efetivaçao */ 
                    IF par_indvalid = 1 AND aux_conttran = 1 THEN
                      DO:

                        IF tt-tbpagto_darf_das_trans_pend.idagendamento = 1 THEN
                          DO:
                           
                            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                           
                            RUN STORED-PROCEDURE pc_paga_tributos
                              aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper,                                   /* Código da cooperativa */
                                                                  INPUT par_nrdconta,                                   /* Número da conta */
                                                                  INPUT par_idseqttl,                                   /* Sequencial de titularidade */
                                                                  INPUT tt-tbgen_trans_pend.nrcpf_operador,             /* CPF do operador PJ */
                                                                  INPUT par_idorigem,                                   /* Canal de origem da operaçao */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.tppagamento,     /* Tipo da guia (1 – DARF / 2 – DAS) */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.tpcaptura,       /* Tipo de captura da guia (1 – Código Barras / 2 – Manual) */
                                                                  INPUT aux_cdseqdrf,
                                                                  INPUT aux_nrdigfat,
                                                                  INPUT aux_lindigi1,                                   /* Primeiro campo da linha digitável da guia */
                                                                  INPUT aux_lindigi2,                                   /* Segundo campo da linha digitável da guia */
                                                                  INPUT aux_lindigi3,                                   /* Terceiro campo da linha digitável da guia */
                                                                  INPUT aux_lindigi4,                                   /* Quarto campo da linha digitável da guia */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.dscod_barras,    /* Código de barras da guia */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.dsidentif_pagto, /* Descriçao da identificaçao do pagamento */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.vlpagamento,     /* Valor total do pagamento da guia */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.dsnome_fone,        /* Nome e telefone da guia */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.dtapuracao,      /* Período de apuraçao da guia */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.nrcpfcgc,        /* CPF/CNPJ da guia */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.cdtributo,       /* Código de tributaçao da guia */
                                                                  INPUT STRING(tt-tbpagto_darf_das_trans_pend.nrrefere), /* Número de referencia da guia */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.dtvencto,        /* Data de vencimento da guia */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.vlprincipal,     /* Valor principal da guia */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.vlmulta,         /* Valor da multa da guia */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.vljuros,         /* Valor dos juros da guia */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.vlreceita_bruta, /* Valor da receita bruta acumulada da guia */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.vlpercentual,    /* Valor do percentual da guia */
                                                                  INPUT aux_vldocmto,
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.idagendamento,   /* Indicador de agendamento (1 – Nesta Data / 2 – Agendamento) */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.tpleitura_docto,       /* Indicador de captura através de leitora de código de barras (1 – Leitora / 2 – Manual) */
                                                                  INPUT 0, /* pr_flgagend */
                                                                  INPUT INT(par_flmobile),
                                                                  INPUT par_iptransa,
                                                                  INPUT par_iddispos,   
                                                                  
                                                                 OUTPUT "",                                   /* Descricao do protocolo */
                                                                 OUTPUT 0,                                              /* Código do erro */
                                                                 OUTPUT ?).                                             /* Descriçao do erro */ 
                                                        
                            /* Fechar o procedimento para buscarmos o resultado */ 
                            CLOSE STORED-PROC pc_paga_tributos aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                            
                            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                            
                            /* Busca possíveis erros */ 
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = ""
                                   glb_dsprotoc = pc_paga_tributos.pr_dsprotoc 
                                                  WHEN pc_paga_tributos.pr_dsprotoc <> ?
                                   aux_cdcritic = pc_paga_tributos.pr_cdcritic 
                                                  WHEN pc_paga_tributos.pr_dscritic <> ?
                                   aux_dscritic = pc_paga_tributos.pr_dscritic 
                                                  WHEN pc_paga_tributos.pr_dscritic <> ?.
                            
                            IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                              DO:
                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                         INPUT "pc_paga_tributos",
                                                         INPUT "b1wgen0016",
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_nrdconta,
                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                         INPUT 0, /* cddbanco */
                                                         INPUT 0, /* ag. destino */
                                                         INPUT 0, /* conta destino */
                                                         INPUT "", /* nome titular */
                                                         INPUT 0, /* cpf favorecido */
                                                         INPUT 0, /* inpessoa favorecido */
                                                         INPUT 0, /* intipcta favorecido */
                                                         INPUT tt-tbpagto_darf_das_trans_pend.vlpagamento,
                                                         INPUT "",
                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                         INPUT 0, /* nrispbif */
                                                         INPUT aux_dscritic).

                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                        INPUT par_cdoperad,
                                                        INPUT aux_dscritic,
                                                        INPUT aux_dsorigem,
                                                        INPUT aux_dstransa,
                                                        INPUT FALSE,
                                                        INPUT par_nmdatela,
                                                        INPUT par_nrdconta,
                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                        INPUT FALSE,
                                                        INPUT par_indvalid,
                                                        INPUT tt-tbpagto_darf_das_trans_pend.dtdebito,
                                                        INPUT tt-tbpagto_darf_das_trans_pend.vlpagamento,
                                                        INPUT aux_conttran).
            
                                IF par_indvalid = 1 THEN
                                    ASSIGN par_flgaviso = TRUE.
            
                                UNDO TRANSACAO, LEAVE TRANSACAO.
                              END.
                          END.
                        ELSE IF tt-tbpagto_darf_das_trans_pend.idagendamento = 2 THEN
                          DO:
                            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                            
                            RUN STORED-PROCEDURE pc_cria_agend_tributos
                              aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper,  /* Código da cooperativa */
                                                                  INPUT par_nrdconta,  /* Número da conta */
                                                                  INPUT par_idseqttl,  /* Sequencial de titularidade */
                                                                  INPUT par_cdagenci,  /* PA */
                                                                  INPUT par_nrdcaixa,  /* Numero do caixa */
                                                                  INPUT par_cdoperad,  /* Codigo do operador */
                                                                  INPUT tt-tbgen_trans_pend.nrcpf_operador,  /* CPF do operador PJ */
                                                                  INPUT par_idorigem,  /* Canal de origem da operaçao */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.tppagamento,  /* Tipo da guia (1 – DARF / 2 – DAS) */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.tpcaptura,  /* Tipo de captura da guia (1 – Código Barras / 2 – Manual) */
                                                                  INPUT 508, /* Historico */
                                                                  INPUT aux_lindigi1,  /* Primeiro campo da linha digitável da guia*/
                                                                  INPUT aux_lindigi2,  /* Segundo campo da linha digitável da guia */
                                                                  INPUT aux_lindigi3,  /* Terceiro campo da linha digitável da guia */
                                                                  INPUT aux_lindigi4,  /* Quarto campo da linha digitável da guia*/
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.dscod_barras,  /* Código de barras da guia */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.dsidentif_pagto,  /* Descriçao da identificaçao do pagamento */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.vlpagamento,  /* Valor total do pagamento da guia */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.dsnome_fone,  /* Nome e telefone da guia */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.dtapuracao,  /* Período de apuraçao da guia */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.nrcpfcgc,  /* CPF/CNPJ da guia */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.cdtributo,  /* Código de tributaçao da guia */
                                                                  INPUT STRING(tt-tbpagto_darf_das_trans_pend.nrrefere), /* Número de referencia da guia */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.dtvencto,  /* Data de vencimento da guia */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.vlprincipal,  /* Valor principal da guia */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.vlmulta,  /* Valor da multa da guia */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.vljuros,  /* Valor dos juros da guia */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.vlreceita_bruta,  /* Valor da receita bruta acumulada da guia */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.vlpercentual,  /* Valor do percentual da guia */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.dtdebito,  /* Data de agendamento */
                                                                  INPUT tt-tbgen_trans_pend.cdtransacao_pendente,  /* Código de sequencial da transaçao pendente */
                                                                  INPUT tt-tbpagto_darf_das_trans_pend.tpleitura_docto, /* Indicador de captura através de leitora de código de barras (1 – Leitora / 2 – Manual) */
                                                                  INPUT INT(par_flmobile),
                                                                  INPUT par_iptransa,
                                                                  INPUT par_iddispos,   
                                                                 OUTPUT "",                                   /* Descricao do protocolo */
                                                                 OUTPUT 0,  /* Código do erro */
                                                                 OUTPUT ?). /* Descriçao do erro */
                              
                            IF ERROR-STATUS:ERROR THEN DO:
                              DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
                                  ASSIGN aux_msgerora = aux_msgerora + 
                                                        ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
                              END.
                                                                               
                              ASSIGN aux_dscritic = "pc_cria_agend_tributos --> "  +
                                                    "Erro ao executar Stored Procedure: " +
                                                    aux_msgerora.      
                              ASSIGN xml_dsmsgerr = "<dsmsgerr>" + 
                                                         "Erro inesperado. Nao foi possivel efetuar a verificacao." + 
                                                         " Tente novamente ou contate seu PA" +
                                                    "</dsmsgerr>".                        
                              RUN proc_geracao_log.
                              RETURN "NOK".
                              
                            END.
                            
                            /* Fechar o procedimento para buscarmos o resultado */ 
                            CLOSE STORED-PROC pc_cria_agend_tributos
                                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                            
                           { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                            
                            /* Busca possíveis erros */ 
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = ""
                                   glb_dsprotoc = pc_cria_agend_tributos.pr_dsprotoc 
                                                  WHEN pc_cria_agend_tributos.pr_dsprotoc <> ?
                                   aux_cdcritic = pc_cria_agend_tributos.pr_cdcritic 
                                                  WHEN pc_cria_agend_tributos.pr_dscritic <> ?
                                   aux_dscritic = pc_cria_agend_tributos.pr_dscritic 
                                                  WHEN pc_cria_agend_tributos.pr_dscritic <> ?.
                            
                            IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                              DO:
                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                         INPUT "pc_cria_agend_tributos",
                                                         INPUT "b1wgen0016",
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_nrdconta,
                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                         INPUT 0, /* cddbanco */
                                                         INPUT 0, /* ag. destino */
                                                         INPUT 0, /* conta destino */
                                                         INPUT "", /* nome titular */
                                                         INPUT 0, /* cpf favorecido */
                                                         INPUT 0, /* inpessoa favorecido */
                                                         INPUT 0, /* intipcta favorecido */
                                                         INPUT tt-tbpagto_darf_das_trans_pend.vlpagamento,
                                                         INPUT "",
                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                         INPUT 0, /* nrispbif */
                                                         INPUT aux_dscritic).

                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                        INPUT par_cdoperad,
                                                        INPUT aux_dscritic,
                                                        INPUT aux_dsorigem,
                                                        INPUT aux_dstransa,
                                                        INPUT FALSE,
                                                        INPUT par_nmdatela,
                                                        INPUT par_nrdconta,
                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                        INPUT FALSE,
                                                        INPUT par_indvalid,
                                                        INPUT tt-tbpagto_darf_das_trans_pend.dtdebito,
                                                        INPUT tt-tbpagto_darf_das_trans_pend.vlpagamento,
                                                        INPUT aux_conttran).
            
                                IF par_indvalid = 1 THEN
                                    ASSIGN par_flgaviso = TRUE.
            
                                UNDO TRANSACAO, LEAVE TRANSACAO.
                              END. /*IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN*/

                          END. /* ELSE IF tt-tbpagto_darf_das_trans_pend.idagendamento = 2 THEN */
                      
                      END. /* EFETIVACAO */
                      
                    RUN gera_erro_transacao(INPUT par_cdcooper,
                                              INPUT par_cdoperad,
                                              INPUT aux_dscritic,
                                              INPUT aux_dsorigem,
                                              INPUT aux_dstransa,
                                              INPUT FALSE,
                                              INPUT par_nmdatela,
                                              INPUT par_nrdconta,
                                              INPUT STRING(ROWID(tbgen_trans_pend)),
                                              INPUT TRUE,
                                              INPUT par_indvalid,
                                              INPUT tt-tbpagto_darf_das_trans_pend.dtdebito,
                                              INPUT tt-tbpagto_darf_das_trans_pend.vlpagamento,
                                              INPUT aux_conttran).
                                                
                  
                  END. /* = 11 */
                  ELSE IF tt-tbgen_trans_pend.tptransacao = 12 THEN /* Desconto de Cheque */
                DO: 
                           
                           ASSIGN aux_dtlibera = ""
                                  aux_dtdcaptu = ""
                                  aux_vlcheque = ""
                                  aux_dsdocmc7 = ""
                                  aux_nrremret = "".
                               
                            FOR EACH tt-tbdscc_trans_pend WHERE tt-tbdscc_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK:
                     
                              IF aux_dsdocmc7 <> "" THEN
                                DO:
                                  ASSIGN aux_dtlibera = aux_dtlibera + "_"
                                         aux_dtdcaptu = aux_dtdcaptu + "_"
                                         aux_vlcheque = aux_vlcheque + "_"
                                         aux_dsdocmc7 = aux_dsdocmc7 + "_"
                                         aux_nrremret = aux_nrremret + "_".
                                END.
                              
                        ASSIGN aux_dtlibera = aux_dtlibera + STRING(DAY(tt-tbdscc_trans_pend.dtlibera),"99") +  "/" + 
                                                             STRING(MONTH(tt-tbdscc_trans_pend.dtlibera),"99") + "/" + 
                                                             STRING(YEAR(tt-tbdscc_trans_pend.dtlibera),"9999")
                               aux_dtdcaptu = aux_dtdcaptu + STRING(DAY(tt-tbdscc_trans_pend.dtemissa),"99") +  "/" + 
                                                             STRING(MONTH(tt-tbdscc_trans_pend.dtemissa),"99") + "/" + 
                                                             STRING(YEAR(tt-tbdscc_trans_pend.dtemissa),"9999")
                                     aux_vlcheque = aux_vlcheque + STRING(tt-tbdscc_trans_pend.vlcheque)
                                     aux_dsdocmc7 = aux_dsdocmc7 + STRING(tt-tbdscc_trans_pend.dsdocmc7)
                                     aux_nrremret = aux_nrremret + STRING(tt-tbdscc_trans_pend.nrremret)
                                     aux_vltotbdc = aux_vltotbdc + tt-tbdscc_trans_pend.vlcheque.
                            END.
                            
                            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                            RUN STORED-PROCEDURE pc_verifica_ass_multi_ib aux_handproc = PROC-HANDLE NO-ERROR
                                                 (INPUT par_cdcooper
                                                 ,INPUT par_nrdconta
                                                 ,INPUT par_idseqttl
                                                 ,INPUT 0
                                                 ,INPUT aux_dtlibera
                                                 ,INPUT aux_dtdcaptu
                                                 ,INPUT aux_vlcheque
                                                 ,INPUT ''
                                                 ,INPUT ''
                                                 ,INPUT aux_dsdocmc7
                                                 ,INPUT aux_nrremret
                                         ,INPUT IF par_indvalid = 1 AND 
                                                 aux_conttran = 1 THEN 1 
                                              ELSE  3        /* pr_aprvpend */
                                                 ,OUTPUT ""
                                                 ,OUTPUT "").
                            
                            CLOSE STORED-PROC pc_verifica_ass_multi_ib 
                                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
                         
                            ASSIGN aux_dscritic = ""
                                   aux_dscritic = pc_verifica_ass_multi_ib.pr_dscritic
                                                  WHEN pc_verifica_ass_multi_ib.pr_dscritic <> ?.
                            
                            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                            
                            IF  aux_dscritic <> ""  THEN DO: 
                                
                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                        INPUT par_cdoperad,
                                                        INPUT aux_dscritic,
                                                        INPUT aux_dsorigem,
                                                        INPUT aux_dstransa,
                                                        INPUT FALSE,
                                                        INPUT par_nmdatela,
                                                        INPUT par_nrdconta,
                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                        INPUT FALSE,
                                                        INPUT par_indvalid,
                                                        INPUT DATE(1, MONTH(TODAY), YEAR(TODAY)),
                                                        INPUT aux_vltotbdc,
                                                        INPUT aux_conttran).
                    
                IF par_indvalid = 1 THEN
                                    ASSIGN par_flgaviso = TRUE.
                    
                                UNDO TRANSACAO, LEAVE TRANSACAO.
                                
                            END.
                            
                            RUN gera_erro_transacao(INPUT par_cdcooper,
                                                    INPUT par_cdoperad,
                                                    INPUT aux_dscritic,
                                                    INPUT aux_dsorigem,
                                                    INPUT aux_dstransa,
                                                    INPUT FALSE,
                                                    INPUT par_nmdatela,
                                                    INPUT par_nrdconta,
                                                    INPUT STRING(ROWID(tbgen_trans_pend)),
                                                    INPUT TRUE,
                                                    INPUT par_indvalid,
                                                    INPUT DATE(1, MONTH(TODAY), YEAR(TODAY)),
                                                    INPUT aux_vltotbdc,
                                                    INPUT aux_conttran).
                     
                END. /* = 12 */    

                ELSE IF tt-tbgen_trans_pend.tptransacao = 13 THEN /* Recarga de Celular */
                        DO: 
                        FOR FIRST tt-tbrecarga_trans_pend WHERE tt-tbrecarga_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK. END.
                        
                                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                             
                                RUN STORED-PROCEDURE pc_confirma_recarga_ib aux_handproc = PROC-HANDLE NO-ERROR
                                                     (INPUT par_cdcooper
                                                     ,INPUT par_nrdconta
                                                     ,INPUT par_idseqttl
                                                     ,INPUT tt-tbgen_trans_pend.nrcpf_operador
                                                     ,INPUT 0
                                                     ,INPUT 0
                                                     ,INPUT ""
                                                     ,INPUT 0
                                                     ,INPUT 0
                                                     ,INPUT 0
                                                     ,INPUT 0
                                                     ,INPUT tt-tbrecarga_trans_pend.tprecarga
                                                     ,INPUT ?
                                                     ,INPUT 0
                                                     ,INPUT tt-tbrecarga_trans_pend.idoperacao
                                                     ,INPUT IF par_indvalid = 1 AND 
                                                               aux_conttran = 1 THEN 1 
                                                            ELSE  3        /* pr_aprvpend */
                                                     ,INPUT 0
                                                     /* Projeto 363 - Novo ATM */ 
                                                     ,INPUT 3 /* pr_idorigem */
                                                     ,INPUT 90 /* pr_cdagenci */
                                                     ,INPUT 900 /*pr_nrdcaixa */
                                                     ,INPUT "INTERNETBANK" /*pr_nmprogra */
                                                     ,INPUT 0 /*pr_cdcoptfn  */
                                                     ,INPUT 0 /*pr_cdagetfn */
                                                     ,INPUT 0 /*pr_nrterfin */
                                                     ,INPUT 0 /*pr_nrcartao */
                                                     ,OUTPUT "" /*pr_xml_idlancto */
                                                     ,OUTPUT ""
                                                     ,OUTPUT 0
                                                     ,OUTPUT "").
                                CLOSE STORED-PROC pc_confirma_recarga_ib 
                                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
                     
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = ""
                                       aux_cdcritic = pc_confirma_recarga_ib.pr_cdcritic
                                                      WHEN pc_confirma_recarga_ib.pr_cdcritic <> ?
                                       aux_dscritic = pc_confirma_recarga_ib.pr_dscritic
                                                      WHEN pc_confirma_recarga_ib.pr_dscritic <> ?.
                                       
                                
                                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                              
                                IF  aux_cdcritic <> 0   OR
                                    aux_dscritic <> ""  THEN DO: 
                                
                                    IF  aux_dscritic = "" THEN DO:
                                        FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                                                   NO-LOCK NO-ERROR.
                                
                                        IF  AVAIL crapcri THEN
                                            ASSIGN aux_dscritic = crapcri.dscritic.
                                        ELSE
                                            ASSIGN aux_dscritic =  "Nao foi possivel incluir o servico".
                                    END.
                     
                                    RUN gera_erro_transacao(INPUT par_cdcooper,
                                                            INPUT par_cdoperad,
                                                            INPUT aux_dscritic,
                                                            INPUT aux_dsorigem,
                                                            INPUT aux_dstransa,
                                                            INPUT FALSE,
                                                            INPUT par_nmdatela,
                                                            INPUT par_nrdconta,
                                                            INPUT STRING(ROWID(tbgen_trans_pend)),
                                                            INPUT FALSE,
                                                            INPUT par_indvalid,
                                                            INPUT DATE(1, MONTH(TODAY), YEAR(TODAY)),
                                                            INPUT 0, /*tt-tbtarif_pacote_trans_pend.vlpacote,*/
                                                            INPUT aux_conttran).
                
                                    IF par_indvalid = 1 THEN
                                        ASSIGN par_flgaviso = TRUE.
                
                                    UNDO TRANSACAO, LEAVE TRANSACAO.

                            END.

                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                INPUT par_cdoperad,
                                                INPUT aux_dscritic,
                                                INPUT aux_dsorigem,
                                                INPUT aux_dstransa,
                                                INPUT FALSE,
                                                INPUT par_nmdatela,
                                                INPUT par_nrdconta,
                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                INPUT TRUE,
                                                INPUT par_indvalid,
                                                INPUT DATE(1, MONTH(TODAY), YEAR(TODAY)),
                                                INPUT 0, /*tt-tbtarif_pacote_trans_pend.vlpacote,*/
                                                INPUT aux_conttran).
                    END. /* 13 */                
 
                ELSE IF tt-tbgen_trans_pend.tptransacao = 14 OR  /* FGTS */
                        tt-tbgen_trans_pend.tptransacao = 15 THEN /* DAE */
                  DO: 
                    FOR FIRST tt-tbpagto_tributos_trans_pend 
                        WHERE tt-tbpagto_tributos_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK.
                    END.
                    
                    FIND FIRST tt-vlrdat WHERE tt-vlrdat.dattrans = tt-tbpagto_tributos_trans_pend.dtdebito NO-LOCK NO-ERROR NO-WAIT.

                    /* Procedimento do internetbank pc_verifica_operacao_prog */
                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                    RUN STORED-PROCEDURE pc_verifica_operacao_prog
                        aux_handproc = PROC-HANDLE NO-ERROR      
                          (INPUT  par_cdcooper
                          ,INPUT  par_cdagenci
                          ,INPUT  par_nrdcaixa
                          ,INPUT  par_nrdconta
                          ,INPUT  par_idseqttl        
                          ,INPUT  par_dtmvtolt
                          ,INPUT  tt-tbpagto_tributos_trans_pend.idagendamento
                          ,INPUT  tt-tbpagto_tributos_trans_pend.dtdebito
                          ,INPUT  (IF par_indvalid = 0 AND aux_conttran = 1 AND AVAIL tt-vlrdat THEN 
                                    tt-vlrdat.vlronlin /* Valor Total Composto */
                                  ELSE tt-tbpagto_tributos_trans_pend.vlpagamento)
                          ,INPUT  0            /* par_cddbanco */
                          ,INPUT  0            /* par_cdageban */
                          ,INPUT  0            /* par_nrctatrf */
                          ,INPUT  (IF tt-tbgen_trans_pend.tptransacao = 14 THEN 12    /* FGTS */
                                   ELSE (IF tt-tbgen_trans_pend.tptransacao = 15 THEN 13 else 12 )) /* par_cdtiptra - DAE */
                          ,INPUT  par_cdoperad /* par_cdoperad */
                          ,INPUT  (IF tt-tbgen_trans_pend.tptransacao = 14 THEN 12    /* FGTS */
                                   ELSE (IF tt-tbgen_trans_pend.tptransacao = 15 THEN 13 else 12)) /* par_tpoperac - DAE */ 
                          ,INPUT  1            /* par_flgvalid*/
                          ,INPUT  aux_dsorigem /* par_dsorigem */
                          ,INPUT  0
                          ,INPUT  1            /* par_flgctrag */
                          ,INPUT  ""           /* par_nmdatela */
                          ,OUTPUT aux_dstransa
                          ,OUTPUT ""           /* --> Retorno XML pr_tab_limite      */
                          ,OUTPUT ""           /* --> Retorno XML pr_tab_internet    */
                          ,OUTPUT 0            /* --> Retorno pr_cdcritic            */
                          ,OUTPUT "").         /* --> Retorno pr_dscritic (OK ou NOK)*/
                                            
                    IF  ERROR-STATUS:ERROR  THEN DO:
                        DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
                            ASSIGN aux_msgerora = aux_msgerora + 
                                                  ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
                        END.
                                                                         
                        ASSIGN aux_dscritic = "pc_verifica_operacao_prog --> "  +
                                              "Erro ao executar Stored Procedure: " +
                                              aux_msgerora.      
                        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + 
                                                   "Erro inesperado. Nao foi possivel efetuar a verificacao." + 
                                                   " Tente novamente ou contacte seu PA" +
                                              "</dsmsgerr>".                        
                        RUN proc_geracao_log.
                        RETURN "NOK".
                        
                    END. 

                    CLOSE STORED-PROC pc_verifica_operacao_prog
                          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl}}

                    ASSIGN aux_dscritic   = pc_verifica_operacao_prog.pr_dscritic 
                                            WHEN pc_verifica_operacao_prog.pr_dscritic <> ?                               
                           aux_tab_limite = pc_verifica_operacao_prog.pr_tab_limite 
                                            WHEN pc_verifica_operacao_prog.pr_tab_limite <> ? .                      
                                            
                    /* Verificar se retornou critica */
                    IF aux_dscritic <> "" THEN
                      DO:
                        /* Gerar log das teds com erro */
                        RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                 INPUT "verifica_operacao",
                                                 INPUT "b1wgen0015",
                                                 INPUT par_dtmvtolt,
                                                 INPUT par_nrdconta,
                                                 INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                 INPUT 0,
                                                 INPUT 0,
                                                 INPUT 0,
                                                 INPUT "",
                                                 INPUT 0,
                                                 INPUT 0,
                                                 INPUT 0,
                                                 INPUT tt-tbpagto_tributos_trans_pend.vlpagamento,
                                                 INPUT "",
                                                 INPUT tt-tbgen_trans_pend.tptransacao,
                                                 INPUT 0,
                                                 INPUT aux_dscritic).

                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                INPUT par_cdoperad,
                                                INPUT aux_dscritic,
                                                INPUT aux_dsorigem,
                                                INPUT aux_dstransa,
                                                INPUT FALSE,
                                                INPUT par_nmdatela,
                                                INPUT par_nrdconta,
                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                INPUT FALSE,
                                                INPUT par_indvalid,
                                                INPUT tt-tbpagto_tributos_trans_pend.dtdebito,
                                                INPUT tt-tbpagto_tributos_trans_pend.vlpagamento,
                                                INPUT aux_conttran).

                        IF par_indvalid = 1 THEN
                          ASSIGN par_flgaviso = TRUE.

                        UNDO TRANSACAO, LEAVE TRANSACAO.
                      END.
                    
                    ASSIGN aux_lindigi1 = DECI(SUBSTR(tt-tbpagto_tributos_trans_pend.dslinha_digitavel,1,11)  + 
                                               SUBSTR(tt-tbpagto_tributos_trans_pend.dslinha_digitavel,13,1))
                           aux_lindigi2 = DECI(SUBSTR(tt-tbpagto_tributos_trans_pend.dslinha_digitavel,15,11) + 
                                               SUBSTR(tt-tbpagto_tributos_trans_pend.dslinha_digitavel,27,1))
                           aux_lindigi3 = DECI(SUBSTR(tt-tbpagto_tributos_trans_pend.dslinha_digitavel,29,11) + 
                                               SUBSTR(tt-tbpagto_tributos_trans_pend.dslinha_digitavel,41,1))
                           aux_lindigi4 = DECI(SUBSTR(tt-tbpagto_tributos_trans_pend.dslinha_digitavel,43,11) + 
                                               SUBSTR(tt-tbpagto_tributos_trans_pend.dslinha_digitavel,55,1)).
                      
                    /* Procedimento do internetbank pc_verifica_operacao_prog */
                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                    RUN STORED-PROCEDURE pc_verifica_tributos
                      aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper,                                   /* Código da cooperativa */
                                                          INPUT par_nrdconta,                                   /* Número da conta */
                                                          INPUT par_idseqttl,                                   /* Sequencial de titularidade */
                                                          INPUT par_idorigem,                                   /* Canal de origem da operaçao */
                                                          INPUT tt-tbpagto_tributos_trans_pend.tppagamento,     /* Tipo da guia (1 – DARF, 2 – DAS, 3-FGTS, 4-DAE) */
                                                          INPUT 1,                                              /* Tipo de captura da guia (1-Código Barras / 2-Manual) */
                                                          INPUT aux_lindigi1,                                   /* Primeiro campo da linha digitável da guia */
                                                          INPUT aux_lindigi2,                                   /* Segundo campo da linha digitável da guia */
                                                          INPUT aux_lindigi3,                                   /* Terceiro campo da linha digitável da guia */
                                                          INPUT aux_lindigi4,                                   /* Quarto campo da linha digitável da guia */
                                                          INPUT tt-tbpagto_tributos_trans_pend.dscod_barras,    /* Código de barras da guia */
                                                          INPUT tt-tbpagto_tributos_trans_pend.vlpagamento,     /* Valor total do pagamento da guia */
                                                          INPUT tt-tbpagto_tributos_trans_pend.dtcompetencia ,  /* Período de apuraçao da guia */
                                                          INPUT tt-tbpagto_tributos_trans_pend.nridentificacao, /* CPF/CNPJ da guia */
                                                          INPUT tt-tbpagto_tributos_trans_pend.cdtributo ,       /* Código de tributaçao da guia */
                                                          INPUT STRING(tt-tbpagto_tributos_trans_pend.nridentificador), /* Número de referencia da guia */
                                                          INPUT tt-tbpagto_tributos_trans_pend.dtvalidade,        /* Data de vencimento da guia */
                                                          INPUT tt-tbpagto_tributos_trans_pend.vlpagamento,     /* Valor principal da guia */
                                                          INPUT 0,                                              /* Valor da multa da guia */
                                                          INPUT 0,                                              /* Valor dos juros da guia */
                                                          INPUT 0,                                              /* Valor da receita bruta acumulada da guia */
                                                          INPUT 0,                                              /* Valor do percentual da guia */
                                                          INPUT tt-tbpagto_tributos_trans_pend.idagendamento,   /* Indicador de agendamento (1-Nesta Data/2-Agendamento */
                                                          INPUT tt-tbpagto_tributos_trans_pend.dtdebito,        /* Data de agendamento */
                                                          INPUT 0,                                              /* Indicador de controle de validaçoes (1-Operaçao Online/2-Operaçao Batch) */
                                                          INPUT 0,                                              /* Indicador mobile */
                                                         OUTPUT "",                                             /* Código sequencial da guia */
                                                         OUTPUT 0,                                              /* Digito do Faturamento */
                                                         OUTPUT 0,                                              /* Valor da guia */
                                                         OUTPUT 0,                                              /* Código do erro */
                                                         OUTPUT ?).                                             /* Descriçao do erro */
                                        
                    /* Fechar o procedimento para buscarmos o resultado */ 
                    CLOSE STORED-PROC pc_verifica_tributos
                          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                    
                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                    
                    /* Busca possíveis erros */ 
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = ""
                           aux_cdcritic = pc_verifica_tributos.pr_cdcritic 
                                          WHEN pc_verifica_tributos.pr_dscritic <> ?
                           aux_dscritic = pc_verifica_tributos.pr_dscritic 
                                          WHEN pc_verifica_tributos.pr_dscritic <> ?
                           aux_cdseqdrf = pc_verifica_tributos.pr_cdseqfat
                           aux_vldocmto = pc_verifica_tributos.pr_vldocmto
                           aux_nrdigfat = pc_verifica_tributos.pr_nrdigfat.
                    
                    IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                      DO:
                        RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                 INPUT "pc_verifica_tributos",
                                                 INPUT "b1wgen0016",
                                                 INPUT par_dtmvtolt,
                                                 INPUT par_nrdconta,
                                                 INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                 INPUT 0, /* cddbanco */
                                                 INPUT 0, /* ag. destino */
                                                 INPUT 0, /* conta destino */
                                                 INPUT "", /* nome titular */
                                                 INPUT 0, /* cpf favorecido */
                                                 INPUT 0, /* inpessoa favorecido */
                                                 INPUT 0, /* intipcta favorecido */
                                                 INPUT tt-tbpagto_tributos_trans_pend.vlpagamento,
                                                 INPUT "",
                                                 INPUT tt-tbgen_trans_pend.tptransacao,
                                                 INPUT 0, /* nrispbif */
                                                 INPUT aux_dscritic).

                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                INPUT par_cdoperad,
                                                INPUT aux_dscritic,
                                                INPUT aux_dsorigem,
                                                INPUT aux_dstransa,
                                                INPUT FALSE,
                                                INPUT par_nmdatela,
                                                INPUT par_nrdconta,
                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                INPUT FALSE,
                                                INPUT par_indvalid,
                                                INPUT tt-tbpagto_tributos_trans_pend.dtdebito,
                                                INPUT tt-tbpagto_tributos_trans_pend.vlpagamento,
                                                INPUT aux_conttran).
    
                IF par_indvalid = 1 THEN
                            ASSIGN par_flgaviso = TRUE.
    
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                      END.
                               
                    /* Efetivaçao */ 
                    IF par_indvalid = 1 AND aux_conttran = 1 THEN
                      DO:

                        IF tt-tbpagto_tributos_trans_pend.idagendamento = 1 THEN
                    DO: 
                           
                            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                           
                            RUN STORED-PROCEDURE pc_paga_tributos
                              aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper,                                   /* Código da cooperativa */
                                                                  INPUT par_nrdconta,                                   /* Número da conta */
                                                                  INPUT par_idseqttl,                                   /* Sequencial de titularidade */
                                                                  INPUT tt-tbgen_trans_pend.nrcpf_operador,             /* CPF do operador PJ */
                                                                  INPUT par_idorigem,                                   /* Canal de origem da operaçao */
                                                                  INPUT tt-tbpagto_tributos_trans_pend.tppagamento,     /* Tipo da guia (1 – DARF / 2 – DAS / 3-FGTS / 4-DAE ) */
                                                                  INPUT 1,                                              /* Tipo de captura da guia (1 – Código Barras / 2 – Manual) */
                                                                  INPUT aux_cdseqdrf,
                                                                  INPUT aux_nrdigfat,
                                                                  INPUT aux_lindigi1,                                   /* Primeiro campo da linha digitável da guia */
                                                                  INPUT aux_lindigi2,                                   /* Segundo campo da linha digitável da guia */
                                                                  INPUT aux_lindigi3,                                   /* Terceiro campo da linha digitável da guia */
                                                                  INPUT aux_lindigi4,                                   /* Quarto campo da linha digitável da guia */
                                                                  INPUT tt-tbpagto_tributos_trans_pend.dscod_barras,    /* Código de barras da guia */
                                                                  INPUT tt-tbpagto_tributos_trans_pend.dsidenti_pagto, /* Descriçao da identificaçao do pagamento */
                                                                  INPUT tt-tbpagto_tributos_trans_pend.vlpagamento,     /* Valor total do pagamento da guia */
                                                                  INPUT "",     /* Nome e telefone da guia */
                                                                  INPUT tt-tbpagto_tributos_trans_pend.dtcompetencia,      /* Período de apuraçao da guia */
                                                                  INPUT tt-tbpagto_tributos_trans_pend.nridentificacao,        /* CPF/CNPJ da guia */
                                                                  INPUT tt-tbpagto_tributos_trans_pend.cdtributo,       /* Código de tributaçao da guia */
                                                                  INPUT STRING(tt-tbpagto_tributos_trans_pend.nridentificador), /* Número de referencia da guia */
                                                                  INPUT tt-tbpagto_tributos_trans_pend.dtvalidade,        /* Data de vencimento da guia */
                                                                  INPUT tt-tbpagto_tributos_trans_pend.vlpagamento,     /* Valor principal da guia */
                                                                  INPUT 0,                                              /* Valor da multa da guia */
                                                                  INPUT 0,                                              /* Valor dos juros da guia */
                                                                  INPUT 0,                                              /* Valor da receita bruta acumulada da guia */
                                                                  INPUT 0,                                              /* Valor do percentual da guia */
                                                                  INPUT aux_vldocmto,
                                                                  INPUT tt-tbpagto_tributos_trans_pend.idagendamento,   /* Indicador de agendamento (1 – Nesta Data / 2 – Agendamento) */
                                                                  INPUT 2,       /* Indicador de captura através de leitora de código de barras (1 – Leitora / 2 – Manual) */
                                                                  INPUT 0, /* pr_flgagend */
                                                                  INPUT INT(par_flmobile),
                                                                  INPUT par_iptransa,
                                                                  INPUT par_iddispos,   
                                                                  
                                                                 OUTPUT "",                                   /* Descricao do protocolo */
                                                                 OUTPUT 0,                                              /* Código do erro */
                                                                 OUTPUT ?).                                             /* Descriçao do erro */ 
                                                        
                            /* Fechar o procedimento para buscarmos o resultado */ 
                            CLOSE STORED-PROC pc_paga_tributos aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                            
                            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                            
                            /* Busca possíveis erros */ 
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = ""
                                   glb_dsprotoc = pc_paga_tributos.pr_dsprotoc 
                                                  WHEN pc_paga_tributos.pr_dsprotoc <> ?
                                   aux_cdcritic = pc_paga_tributos.pr_cdcritic 
                                                  WHEN pc_paga_tributos.pr_dscritic <> ?
                                   aux_dscritic = pc_paga_tributos.pr_dscritic 
                                                  WHEN pc_paga_tributos.pr_dscritic <> ?.
                            
                            IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                              DO:
                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                         INPUT "pc_paga_tributos",
                                                         INPUT "b1wgen0016",
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_nrdconta,
                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                         INPUT 0, /* cddbanco */
                                                         INPUT 0, /* ag. destino */
                                                         INPUT 0, /* conta destino */
                                                         INPUT "", /* nome titular */
                                                         INPUT 0, /* cpf favorecido */
                                                         INPUT 0, /* inpessoa favorecido */
                                                         INPUT 0, /* intipcta favorecido */
                                                         INPUT tt-tbpagto_tributos_trans_pend.vlpagamento,
                                                         INPUT "",
                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                         INPUT 0, /* nrispbif */
                                                         INPUT aux_dscritic).

                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                        INPUT par_cdoperad,
                                                        INPUT aux_dscritic,
                                                        INPUT aux_dsorigem,
                                                        INPUT aux_dstransa,
                                                        INPUT FALSE,
                                                        INPUT par_nmdatela,
                                                        INPUT par_nrdconta,
                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                        INPUT FALSE,
                                                        INPUT par_indvalid,
                                                        INPUT tt-tbpagto_tributos_trans_pend.dtdebito,
                                                        INPUT tt-tbpagto_tributos_trans_pend.vlpagamento,
                                                        INPUT aux_conttran).
            
                                IF par_indvalid = 1 THEN
                                    ASSIGN par_flgaviso = TRUE.
            
                                UNDO TRANSACAO, LEAVE TRANSACAO.
                              END.
                          END.
                        ELSE IF tt-tbpagto_tributos_trans_pend.idagendamento = 2 THEN
                          DO:
                            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                            
                            RUN STORED-PROCEDURE pc_cria_agend_tributos
                              aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper,  /* Código da cooperativa */
                                                                  INPUT par_nrdconta,  /* Número da conta */
                                                                  INPUT par_idseqttl,  /* Sequencial de titularidade */
                                                                  INPUT par_cdagenci,  /* PA */
                                                                  INPUT par_nrdcaixa,  /* Numero do caixa */
                                                                  INPUT par_cdoperad,  /* Codigo do operador */
                                                                  INPUT tt-tbgen_trans_pend.nrcpf_operador,  /* CPF do operador PJ */
                                                                  INPUT par_idorigem,  /* Canal de origem da operaçao */
                                                                  INPUT tt-tbpagto_tributos_trans_pend.tppagamento,  /* Tipo da guia (1 – DARF / 2 – DAS) */
                                                                  INPUT 1,             /* Tipo de captura da guia (1 – Código Barras / 2 – Manual) */
                                                                  INPUT 508, /* Historico */
                                                                  INPUT aux_lindigi1,  /* Primeiro campo da linha digitável da guia*/
                                                                  INPUT aux_lindigi2,  /* Segundo campo da linha digitável da guia */
                                                                  INPUT aux_lindigi3,  /* Terceiro campo da linha digitável da guia */
                                                                  INPUT aux_lindigi4,  /* Quarto campo da linha digitável da guia*/
                                                                  INPUT tt-tbpagto_tributos_trans_pend.dscod_barras,  /* Código de barras da guia */
                                                                  INPUT tt-tbpagto_tributos_trans_pend.dsidenti_pagto,  /* Descriçao da identificaçao do pagamento */
                                                                  INPUT tt-tbpagto_tributos_trans_pend.vlpagamento,  /* Valor total do pagamento da guia */
                                                                  INPUT "",  /* Nome e telefone da guia */
                                                                  INPUT tt-tbpagto_tributos_trans_pend.dtcompetencia,  /* Período de apuraçao da guia */
                                                                  INPUT tt-tbpagto_tributos_trans_pend.nridentificacao,  /* CPF/CNPJ da guia */
                                                                  INPUT tt-tbpagto_tributos_trans_pend.cdtributo,  /* Código de tributaçao da guia */
                                                                  INPUT STRING(tt-tbpagto_tributos_trans_pend.nridentificador), /* Número de referencia da guia */
                                                                  INPUT tt-tbpagto_tributos_trans_pend.dtvalidade,   /* Data de vencimento da guia */
                                                                  INPUT tt-tbpagto_tributos_trans_pend.vlpagamento,  /* Valor principal da guia */
                                                                  INPUT 0,                                           /* Valor da multa da guia */
                                                                  INPUT 0,                                           /* Valor dos juros da guia */
                                                                  INPUT 0,                                           /* Valor da receita bruta acumulada da guia */
                                                                  INPUT 0,                                           /* Valor do percentual da guia */
                                                                  INPUT tt-tbpagto_tributos_trans_pend.dtdebito,  /* Data de agendamento */
                                                                  INPUT tt-tbgen_trans_pend.cdtransacao_pendente,  /* Código de sequencial da transaçao pendente */
                                                                  INPUT 2, /* Indicador de captura através de leitora de código de barras (1 – Leitora / 2 – Manual) */
                                                                  INPUT INT(par_flmobile),
                                                                  INPUT par_iptransa,
                                                                  INPUT par_iddispos,
                                                                 OUTPUT "",                                   /* Descricao do protocolo */
                                                                 OUTPUT 0,  /* Código do erro */
                                                                 OUTPUT ?). /* Descriçao do erro */
                              
                            IF ERROR-STATUS:ERROR THEN DO:
                              DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
                                  ASSIGN aux_msgerora = aux_msgerora + 
                                                        ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
                              END.
                                                                               
                              ASSIGN aux_dscritic = "pc_cria_agend_tributos --> "  +
                                                    "Erro ao executar Stored Procedure: " +
                                                    aux_msgerora.      
                              ASSIGN xml_dsmsgerr = "<dsmsgerr>" + 
                                                         "Erro inesperado. Nao foi possivel efetuar a verificacao." + 
                                                         " Tente novamente ou contate seu PA" +
                                                    "</dsmsgerr>".                        
                              RUN proc_geracao_log.
                              RETURN "NOK".
                              
                            END.
                            
                            /* Fechar o procedimento para buscarmos o resultado */ 
                            CLOSE STORED-PROC pc_cria_agend_tributos
                                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                            
                           { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                            
                            /* Busca possíveis erros */ 
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = ""
                                   glb_dsprotoc = pc_cria_agend_tributos.pr_dsprotoc 
                                                  WHEN pc_cria_agend_tributos.pr_dsprotoc <> ?
                                   aux_cdcritic = pc_cria_agend_tributos.pr_cdcritic 
                                                  WHEN pc_cria_agend_tributos.pr_dscritic <> ?
                                   aux_dscritic = pc_cria_agend_tributos.pr_dscritic 
                                                  WHEN pc_cria_agend_tributos.pr_dscritic <> ?.
                            
                            IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                              DO:
                                RUN gera_arquivo_log_ted(INPUT par_cdcooper,
                                                         INPUT "pc_cria_agend_tributos",
                                                         INPUT "b1wgen0016",
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_nrdconta,
                                                         INPUT tt-tbgen_trans_pend.nrcpf_operador,
                                                         INPUT 0, /* cddbanco */
                                                         INPUT 0, /* ag. destino */
                                                         INPUT 0, /* conta destino */
                                                         INPUT "", /* nome titular */
                                                         INPUT 0, /* cpf favorecido */
                                                         INPUT 0, /* inpessoa favorecido */
                                                         INPUT 0, /* intipcta favorecido */
                                                         INPUT tt-tbpagto_tributos_trans_pend.vlpagamento,
                                                         INPUT "",
                                                         INPUT tt-tbgen_trans_pend.tptransacao,
                                                         INPUT 0, /* nrispbif */
                                                         INPUT aux_dscritic).

                                RUN gera_erro_transacao(INPUT par_cdcooper,
                                                        INPUT par_cdoperad,
                                                        INPUT aux_dscritic,
                                                        INPUT aux_dsorigem,
                                                        INPUT aux_dstransa,
                                                        INPUT FALSE,
                                                        INPUT par_nmdatela,
                                                        INPUT par_nrdconta,
                                                        INPUT STRING(ROWID(tbgen_trans_pend)),
                                                        INPUT FALSE,
                                                        INPUT par_indvalid,
                                                        INPUT tt-tbpagto_tributos_trans_pend.dtdebito,
                                                        INPUT tt-tbpagto_tributos_trans_pend.vlpagamento,
                                                        INPUT aux_conttran).
            
                                IF par_indvalid = 1 THEN
                                    ASSIGN par_flgaviso = TRUE.
            
                                UNDO TRANSACAO, LEAVE TRANSACAO.
                              END. /*IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN*/

                          END. /* ELSE IF tt-tbpagto_tributos_trans_pend.idagendamento = 2 THEN */
                      
                      END. /* EFETIVACAO */
                      
                    RUN gera_erro_transacao(INPUT par_cdcooper,
                                              INPUT par_cdoperad,
                                              INPUT aux_dscritic,
                                              INPUT aux_dsorigem,
                                              INPUT aux_dstransa,
                                              INPUT FALSE,
                                              INPUT par_nmdatela,
                                              INPUT par_nrdconta,
                                              INPUT STRING(ROWID(tbgen_trans_pend)),
                                              INPUT TRUE,
                                              INPUT par_indvalid,
                                              INPUT tt-tbpagto_tributos_trans_pend.dtdebito,
                                              INPUT tt-tbpagto_tributos_trans_pend.vlpagamento,
                                              INPUT aux_conttran).
                                                
                  
                  END. /* = 14,15 */

               ELSE IF tt-tbgen_trans_pend.tptransacao = 18 THEN /*  cheque em custodia */
                  DO: /*Inicio 18*/
                    /*Se ultimo aprovador e se a tela eh a de confirmacao faca*/
                    IF par_indvalid = 1 AND aux_conttran = 1 THEN
                      DO:
                        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                                                 
                        RUN STORED-PROCEDURE pc_efetua_resgate_cst_prog aux_handproc = PROC-HANDLE NO-ERROR
                                             (INPUT tt-tbgen_trans_pend.cdtransacao_pendente
                                             ,INPUT par_cdcooper
                                             ,INPUT par_nrdconta
                                             ,INPUT par_cdoperad
                                             ,OUTPUT 0
                                             ,OUTPUT "").
                        CLOSE STORED-PROC pc_efetua_resgate_cst_prog 
                            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
                        
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = ""
                               aux_cdcritic = pc_efetua_resgate_cst_prog.pr_cdcritic
                                              WHEN pc_efetua_resgate_cst_prog.pr_cdcritic <> ?
                               aux_dscritic = pc_efetua_resgate_cst_prog.pr_dscritic
                                              WHEN pc_efetua_resgate_cst_prog.pr_dscritic <> ?.
                        
                        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                                                  
                        IF  aux_cdcritic <> 0   OR
                            aux_dscritic <> ""  THEN 
                          DO: 
                            IF  aux_dscritic = "" THEN 
                              DO:
                                FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                                NO-LOCK NO-ERROR.
                                IF AVAIL crapcri THEN
                                  ASSIGN aux_dscritic = crapcri.dscritic.
                                ELSE
                                  ASSIGN aux_dscritic =  "Nao foi possivel executar a rotina resgate custodia".
                              END.
                            
                            RUN gera_erro_transacao(INPUT par_cdcooper,
                                                    INPUT par_cdoperad,
                                                    INPUT aux_dscritic,
                                                    INPUT aux_dsorigem,
                                                    INPUT aux_dstransa,
                                                    INPUT FALSE,
                                                    INPUT par_nmdatela,
                                                    INPUT par_nrdconta,
                                                    INPUT STRING(ROWID(tbgen_trans_pend)),
                                                    INPUT FALSE,
                                                    INPUT par_indvalid,
                                                    INPUT DATE(1, MONTH(TODAY), YEAR(TODAY)),
                                                    INPUT 0, /*tt-tbtarif_pacote_trans_pend.vlpacote,*/
                                                    INPUT aux_conttran).
                                         
                            IF par_indvalid = 1 THEN
                              ASSIGN par_flgaviso = TRUE.
                                    
                            UNDO TRANSACAO, LEAVE TRANSACAO.
                          
                          END.
                          
                          
                          
                      END. /*FIM IF  par_indvalid = 1 AND aux_conttran = 1 */                                        
                    
                    RUN gera_erro_transacao(INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                            INPUT STRING(ROWID(tbgen_trans_pend)),
                                            INPUT TRUE,
                                            INPUT par_indvalid,
                                            INPUT DATE(1, MONTH(TODAY), YEAR(TODAY)),
                                            INPUT 0,
                                            INPUT aux_conttran).                                                                 
                      
                      
                        
                  END. /*FIM 18*/                  
                  

            ELSE IF tt-tbgen_trans_pend.tptransacao = 19 THEN /*Bordero Desconto Titulo*/
                    DO: 
                        ASSIGN aux_cdbandoc_bdt = ""
                               aux_nrdctabb_bdt = ""
                               aux_nrcnvcob_bdt = ""
                               aux_nrdocmto_bdt = "".
                               
                        FOR EACH tt-tbdsct_trans_pend WHERE tt-tbdsct_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK:
                            
                            IF aux_nrdocmto_bdt <> "" THEN
                               DO:
                                  ASSIGN aux_cdbandoc_bdt = aux_cdbandoc_bdt + "|"
                                         aux_nrdctabb_bdt = aux_nrdctabb_bdt + "|"
                                         aux_nrcnvcob_bdt = aux_nrcnvcob_bdt + "|"
                                         aux_nrdocmto_bdt = aux_nrdocmto_bdt + "|".
                               END.
                              
                            ASSIGN aux_cdbandoc_bdt = aux_cdbandoc_bdt + STRING(tt-tbdsct_trans_pend.cdbandoc)
                                   aux_nrdctabb_bdt = aux_nrdctabb_bdt + STRING(tt-tbdsct_trans_pend.nrdctabb)
                                   aux_nrcnvcob_bdt = aux_nrcnvcob_bdt + STRING(tt-tbdsct_trans_pend.nrcnvcob)
                                   aux_nrdocmto_bdt = aux_nrdocmto_bdt + STRING(tt-tbdsct_trans_pend.nrdocmto).
                        END.

                        IF par_indvalid = 1 AND aux_conttran = 1 THEN
                           DO:
                               { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                               RUN STORED-PROCEDURE pc_finalizar_bordero_dscto_tit aux_handproc = PROC-HANDLE NO-ERROR
                                                     (INPUT par_cdcooper
                                                     ,INPUT par_nrdconta
                                                     ,INPUT par_idseqttl
                                                     ,INPUT 0
                                                     ,INPUT aux_cdbandoc_bdt
                                                     ,INPUT aux_nrdctabb_bdt
                                                     ,INPUT aux_nrcnvcob_bdt
                                                     ,INPUT aux_nrdocmto_bdt
                                                     ,OUTPUT ""
                                                     ,OUTPUT "").
                                
                               CLOSE STORED-PROC pc_finalizar_bordero_dscto_tit aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.  

                               ASSIGN aux_dscritic = ""
                                      aux_dscritic = pc_finalizar_bordero_dscto_tit.pr_dscritic
                                                     WHEN pc_finalizar_bordero_dscto_tit.pr_dscritic <> ?.

                               { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                                
                               IF  aux_dscritic <> ""  THEN DO: 
                                    
                                   RUN gera_erro_transacao(INPUT par_cdcooper,
                                                           INPUT par_cdoperad,
                                                           INPUT aux_dscritic,
                                                           INPUT aux_dsorigem,
                                                           INPUT aux_dstransa,
                                                           INPUT FALSE,
                                                           INPUT par_nmdatela,
                                                           INPUT par_nrdconta,
                                                           INPUT STRING(ROWID(tbgen_trans_pend)),
                                                           INPUT FALSE,
                                                           INPUT par_indvalid,
                                                           INPUT DATE(1, MONTH(TODAY), YEAR(TODAY)),
                                                           INPUT aux_vltotbdc,
                                                           INPUT aux_conttran).
                        
                IF par_indvalid = 1 THEN
                                       ASSIGN par_flgaviso = TRUE.
                        
                                   UNDO TRANSACAO, LEAVE TRANSACAO.
                                    
                               END.
                           END.
                                
                       RUN gera_erro_transacao(INPUT par_cdcooper,
                                               INPUT par_cdoperad,
                                               INPUT aux_dscritic,
                                               INPUT aux_dsorigem,
                                               INPUT aux_dstransa,
                                               INPUT FALSE,
                                               INPUT par_nmdatela,
                                               INPUT par_nrdconta,
                                               INPUT STRING(ROWID(tbgen_trans_pend)),
                                               INPUT TRUE,
                                               INPUT par_indvalid,
                                               INPUT DATE(1, MONTH(TODAY), YEAR(TODAY)),
                                               INPUT aux_vltotbdc,
                                               INPUT aux_conttran).
                END. /* = 19 */   
/* Projeto 470 - Marcelo Telles Coelho */
                ELSE IF tt-tbgen_trans_pend.tptransacao = 20 /* Contrato */
                     THEN
                    DO: 
                    /*Se ultimo aprovador e se a tela eh a de confirmacao faca*/
                    IF par_indvalid = 1 AND aux_conttran = 1 THEN
                      DO:
                        FOR FIRST tt-tbctd_trans_pend 
                            WHERE tt-tbctd_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK.
                        END.
                        /* Identificar se é a aprovaçao final*/
                        /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
                        ASSIGN aux_flgfinal_ctd = "S".
                      END. /* IF par_indvalid = 1 AND aux_conttran = 1 THEN */
                      RUN gera_erro_transacao(INPUT par_cdcooper,
                                              INPUT par_cdoperad,
                                              INPUT aux_dscritic,
                                              INPUT aux_dsorigem,
                                              INPUT aux_dstransa,
                                              INPUT FALSE,
                                              INPUT par_nmdatela,
                                              INPUT par_nrdconta,
                                              INPUT STRING(ROWID(tbgen_trans_pend)),
                                              INPUT TRUE,
                                              INPUT par_indvalid,
                                              INPUT DATE(1, MONTH(TODAY), YEAR(TODAY)),
                                              INPUT 0, /*tt-tbtarif_pacote_trans_pend.vlpacote,*/
                                              INPUT aux_conttran).
                    END.
                    /* Fim Projeto 470 */                

                
                ELSE IF tt-tbgen_trans_pend.tptransacao = 21 THEN /*Contratacao Emprestimo*/
                    DO:
                        IF par_indvalid = 1 THEN
                            DO: /*Busca numero do contrato e gera assinatura*/
                                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                                RUN STORED-PROCEDURE pc_ret_trans_pend_prop
                                aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Código da Cooperativa */
                                                                     INPUT par_cdoperad, /* Código do Operador */
                                                                     INPUT par_nmdatela, /* Nome da Tela */
                                                                     INPUT 1,            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                                                     INPUT par_nrdconta, /* Número da Conta */
                                                                     INPUT 1,            /* Titular da Conta */
                                                                     INPUT STRING(tt-tbgen_trans_pend.cdtransacao_pendente), /* Codigo da Transacao */
                                                                    OUTPUT 0,            /* Código da crítica */
                                                                    OUTPUT "",           /* Descriçao da crítica */
                                                                    OUTPUT 0,            /* Código da proposta de emprestimo */
                                                                    OUTPUT 0).           /* Código da proposta de emprestimo */

                                  
                                CLOSE STORED-PROC pc_ret_trans_pend_prop 
                                       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.  

                                 /* Busca possíveis erros */ 
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = ""
                                       aux_nrctremp = 0
                                       aux_cdcritic = pc_ret_trans_pend_prop.pr_cdcritic 
                                                      WHEN pc_ret_trans_pend_prop.pr_cdcritic <> ?
                                       aux_dscritic = pc_ret_trans_pend_prop.pr_dscritic 
                                                      WHEN pc_ret_trans_pend_prop.pr_dscritic <> ?
                                       aux_nrctremp = pc_ret_trans_pend_prop.pr_nrctremp 
                                                      WHEN pc_ret_trans_pend_prop.pr_nrctremp <> ?
                                       aux_vlemprst = pc_ret_trans_pend_prop.pr_vlemprst 
                                                      WHEN pc_ret_trans_pend_prop.pr_vlemprst <> ?.

                                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                                  
                                IF  aux_dscritic <> ""  THEN 
                                    DO: 
                                          
                                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                INPUT par_cdoperad,
                                                                INPUT aux_dscritic,
                                                                INPUT aux_dsorigem,
                                                                INPUT aux_dstransa,
                                                                INPUT FALSE,
                                                                INPUT par_nmdatela,
                                                                INPUT par_nrdconta,
                                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                INPUT FALSE,
                                                                INPUT par_indvalid,
                                                                INPUT par_dtmvtolt,
                                                                INPUT aux_vlemprst,
                                                                INPUT aux_conttran).
                          
                                        IF par_indvalid = 1 THEN
                                            ASSIGN par_flgaviso = TRUE.
                              
                                        UNDO TRANSACAO, LEAVE TRANSACAO.
                                          
                                    END.
                                ELSE /*Sem erros na busca do contrato*/
                                    IF aux_nrctremp <> 0 THEN
                                        DO:
                                            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                                            /*Gera registro de assinatura do operador*/
                                            RUN STORED-PROCEDURE pc_assinatura_contrato
                                            aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Código da Cooperativa */
                                                                                 INPUT par_cdagenci, /* Código do Operador */
                                                                                 INPUT par_nrdconta, /* Número da Conta */
                                                                                 INPUT par_idseqttl, /* Titular */
                                                                                 INPUT par_dtmvtolt, /* Data de movimento*/
                                                                                 INPUT par_idorigem, /* Origem da solicitacao */
                                                                                 INPUT aux_nrctremp, /* Numero Contrato */
                                                                                 INPUT 1,            /* tipo de assinatura (1 socio/2 - cooperativa) */
                                                                                OUTPUT "",           /* Descricao do retorno */
                                                                                OUTPUT "").          /* Descricao da crítica */

                                              
                                            CLOSE STORED-PROC pc_assinatura_contrato 
                                                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.  

                                             /* Busca possíveis erros */ 
                                            ASSIGN aux_msgretor = ""
                                                   aux_dscritic = ""
                                                   aux_msgretor = pc_assinatura_contrato.pr_des_reto 
                                                                  WHEN pc_assinatura_contrato.pr_des_reto <> ?
                                                   aux_dscritic = pc_assinatura_contrato.pr_dscritic 
                                                                  WHEN pc_assinatura_contrato.pr_dscritic <> ?.

                                            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                                              
                                            IF  aux_msgretor <> "OK"  THEN 
                                                DO: 
                                                      
                                                    RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                            INPUT par_cdoperad,
                                                                            INPUT aux_dscritic,
                                                                            INPUT aux_dsorigem,
                                                                            INPUT aux_dstransa,
                                                                            INPUT FALSE,
                                                                            INPUT par_nmdatela,
                                                                            INPUT par_nrdconta,
                                                                            INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                            INPUT FALSE,
                                                                            INPUT par_indvalid,
                                                                            INPUT par_dtmvtolt,
                                                                            INPUT aux_vlemprst,
                                                                            INPUT aux_conttran).
                                      
                                                    IF par_indvalid = 1 THEN
                                                        ASSIGN par_flgaviso = TRUE.
                                          
                                                    UNDO TRANSACAO, LEAVE TRANSACAO.
                                                      
                                                END.
                                        END.
                            END.
                        
                        IF par_indvalid = 1 AND aux_conttran = 1 THEN
                           DO:
                                
                              IF aux_nrctremp <> 0 THEN
                                DO:
                                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                                    RUN STORED-PROCEDURE pc_solicita_contrata_PROG
                                      aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, 
                                                                           INPUT par_nrdconta, 
                                                                           INPUT aux_nrctremp, 
                                                                           INPUT par_cdoperad, 
                                                                           INPUT STRING(par_nrcpfope), 
                                                                           INPUT par_iptransa, 
                                                                           INPUT par_iddispos, 
                                                                           INPUT par_cdagenci, 
                                                                           INPUT par_nrdcaixa, 
                                                                           INPUT par_idorigem, 
                                                                          OUTPUT "",           
                                                                          OUTPUT ?).           

                                
                                    CLOSE STORED-PROC pc_solicita_contrata_PROG 
                                          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                                
                                    ASSIGN aux_msgretor = pc_solicita_contrata_PROG.pr_des_reto 
                                                          WHEN pc_solicita_contrata_PROG.pr_des_reto <> ?
                                                 vr_xml = pc_solicita_contrata_PROG.pr_retorno 
                                                          WHEN pc_solicita_contrata_PROG.pr_retorno <> ?.
                                                          
                                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                                    IF aux_msgretor <> "OK" THEN 
                                      DO:  
                                          /* Efetuar a leitura do XML*/ 
   
                                          SET-SIZE(ponteiro_xml) = LENGTH(vr_xml) + 1. 

                                          PUT-STRING(ponteiro_xml,1) = vr_xml. 

                                          /* Inicializando objetos para leitura do XML */ 
                                          CREATE X-DOCUMENT xDoc.    
                                          CREATE X-NODEREF  xRoot.   
                                          CREATE X-NODEREF  xRoot2.  
                                          CREATE X-NODEREF  xField.  
                                          CREATE X-NODEREF  xText.   

                                          IF ponteiro_xml <> ? THEN

                                              DO:
                                                  xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
                                                  xDoc:GET-DOCUMENT-ELEMENT(xRoot).

                                                  DO aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 

                                                      xRoot:GET-CHILD(xRoot2,aux_cont_raiz).

                                                      IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
                                                          NEXT. 

                                                      DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:

                                                          xRoot2:GET-CHILD(xField,aux_cont).

                                                          IF xField:SUBTYPE <> "ELEMENT" THEN 
                                                              NEXT. 

                                                            xField:GET-CHILD(xText,1) NO-ERROR.
                                                            ASSIGN aux_dscritic = xText:NODE-VALUE        WHEN xField:NAME = "Erro" NO-ERROR.
                                                            
                                                      END.
                                                                
                                                  END.

                                                  SET-SIZE(ponteiro_xml) = 0. 

                                              END.

                                          /*Elimina os objetos criados*/
                                          DELETE OBJECT xDoc. 
                                          DELETE OBJECT xRoot. 
                                          DELETE OBJECT xRoot2. 
                                          DELETE OBJECT xField. 
                                          DELETE OBJECT xText.
                                      
                                          IF aux_dscritic = "" THEN
                                          DO:
                                              ASSIGN aux_dscritic = "Erro ao efetuar a contratacao do emprestimo".
                                          END.
                                                                                    
                                          RUN gera_erro_transacao(INPUT par_cdcooper,
                                                           INPUT par_cdoperad,
                                                           INPUT aux_dscritic,
                                                           INPUT aux_dsorigem,
                                                           INPUT aux_dstransa,
                                                           INPUT FALSE,
                                                           INPUT par_nmdatela,
                                                           INPUT par_nrdconta,
                                                           INPUT STRING(ROWID(tbgen_trans_pend)),
                                                           INPUT FALSE,
                                                           INPUT par_indvalid,
                                                           INPUT par_dtmvtolt,
                                                           INPUT aux_vlemprst,
                                                           INPUT aux_conttran).
                        
                                          IF par_indvalid = 1 THEN
                                            ASSIGN par_flgaviso = TRUE.
                                    
                                            UNDO TRANSACAO, LEAVE TRANSACAO.
                                                
                                           END.
                                          
                                      END.
                                
                                
                                
                                END.
                                
                       RUN gera_erro_transacao(INPUT par_cdcooper,
                                               INPUT par_cdoperad,
                                               INPUT aux_dscritic,
                                               INPUT aux_dsorigem,
                                               INPUT aux_dstransa,
                                               INPUT FALSE,
                                               INPUT par_nmdatela,
                                               INPUT par_nrdconta,
                                               INPUT STRING(ROWID(tbgen_trans_pend)),
                                               INPUT TRUE,
                                               INPUT par_indvalid,
                                               INPUT DATE(1, MONTH(TODAY), YEAR(TODAY)),
                                               INPUT aux_vlemprst,
                                               INPUT aux_conttran).
                    END. /* = 21 */ 
                  
                IF par_indvalid = 1 THEN
                    DO: 
                        FOR FIRST tbgen_aprova_trans_pend WHERE tbgen_aprova_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente
                                                            AND tbgen_aprova_trans_pend.nrcpf_responsavel_aprov = aux_nrcpfrep EXCLUSIVE-LOCK:
                    
                            ASSIGN tbgen_aprova_trans_pend.idsituacao_aprov = 2
                                   tbgen_aprova_trans_pend.dtalteracao_situacao = DATE(STRING(TODAY,"99/99/9999"))
                                   tbgen_aprova_trans_pend.hralteracao_situacao = TIME.

                            VALIDATE tbgen_aprova_trans_pend.
                        END.

                        FOR FIRST tbgen_trans_pend WHERE tbgen_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente EXCLUSIVE-LOCK. END.

                        ASSIGN tbgen_trans_pend.idsituacao_transacao = IF aux_conttran = 1 THEN 2 /* Aprovada */ ELSE 5 /* Parcialmente Aprovada */
                               tbgen_trans_pend.dtalteracao_situacao = DATE(STRING(TODAY,"99/99/9999")).


                        VALIDATE tbgen_trans_pend.
                        
                        /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
                           Atualizar o protocolo gerado para o tptransacao = 20 -- Contrato */
                        IF tt-tbgen_trans_pend.tptransacao = 20 /* Contrato */
                        THEN
                          DO:
                            { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

                            RUN STORED-PROCEDURE pc_atualiza_protocolo_ctd aux_handproc = PROC-HANDLE NO-ERROR
                                                         (INPUT tt-tbctd_trans_pend.cdtransacao_pendente
                                                         ,INPUT aux_nrcpfrep
                                                         ,INPUT aux_flgfinal_ctd
                                                         ,OUTPUT "").
                            CLOSE STORED-PROC pc_atualiza_protocolo_ctd 
                            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
                     
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = ""
                                 aux_dscritic = pc_atualiza_protocolo_ctd.pr_dscritic
                            WHEN pc_atualiza_protocolo_ctd.pr_dscritic <> ?.
                                       
                                
                            { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
                             
                            IF  aux_cdcritic <> 0   OR
                                aux_dscritic <> ""  THEN
                                DO: 
                                    IF  aux_dscritic = "" THEN 
                                        DO:
                                            FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                                            NO-LOCK NO-ERROR.
                                    
                                            IF  AVAIL crapcri THEN
                                                ASSIGN aux_dscritic = crapcri.dscritic.
                                            ELSE
                                                ASSIGN aux_dscritic =  "Nao foi possivel incluir o servico".
                    END.
                     
                                        RUN gera_erro_transacao(INPUT par_cdcooper,
                                                                INPUT par_cdoperad,
                                                                INPUT aux_dscritic,
                                                                INPUT aux_dsorigem,
                                                                INPUT aux_dstransa,
                                                                INPUT FALSE,
                                                                INPUT par_nmdatela,
                                                                INPUT par_nrdconta,
                                                                INPUT STRING(ROWID(tbgen_trans_pend)),
                                                                INPUT FALSE,
                                                                INPUT par_indvalid,
                                                                INPUT DATE(1, MONTH(TODAY), YEAR(TODAY)),
                                                                INPUT 0, /*tt-tbtarif_pacote_trans_pend.vlpacote,*/
                                                                INPUT aux_conttran).
                
                                        IF par_indvalid = 1 THEN
                                            ASSIGN par_flgaviso = TRUE.
                
                                        UNDO TRANSACAO, LEAVE TRANSACAO.

                                END.
                          END. /* IF tt-tbgen_trans_pend.tptransacao = 20 */
                        /* Fim Pj470 - SM2 */
                    END.
        
        END. /* FIM TRANSACAO */

    END. /* FOR EACH*/

    IF  VALID-HANDLE(h-b1wgen0015)  THEN
        DELETE PROCEDURE h-b1wgen0015.
    
    IF  VALID-HANDLE(h-b1wgen0081)  THEN
        DELETE PROCEDURE h-b1wgen0081.
    
    IF  VALID-HANDLE(h-b1wgen0092)  THEN
        DELETE PROCEDURE h-b1wgen0092.
    
    IF  VALID-HANDLE(h-b1wgen0188)  THEN
        DELETE PROCEDURE h-b1wgen0188.
    
    IF  VALID-HANDLE(h-b1crap20)  THEN
        DELETE PROCEDURE h-b1crap20.

    IF  VALID-HANDLE(h-b1crap22)  THEN
        DELETE PROCEDURE h-b1crap22.

    ASSIGN aux_dstransa = "Aprovacao de Transacoes Pendentes".

    FOR EACH tt-criticas_transacoes_oper NO-LOCK:
      
        IF par_indvalid = 1 OR (par_indvalid = 0 AND tt-criticas_transacoes_oper.flgtrans = FALSE)THEN
            DO:
              
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT tt-criticas_transacoes_oper.dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT tt-criticas_transacoes_oper.flgtrans,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
            END.

        FIND tbgen_trans_pend WHERE ROWID(tbgen_trans_pend) = TO-ROWID(tt-criticas_transacoes_oper.nrdrowid) EXCLUSIVE-LOCK NO-ERROR.

        IF  AVAILABLE tbgen_trans_pend  THEN
            DO:
                IF tt-criticas_transacoes_oper.flgtrans = FALSE THEN
                    DO:
                        ASSIGN tbgen_trans_pend.dtcritic = TODAY
                               tbgen_trans_pend.dscritic = tt-criticas_transacoes_oper.dscritic.
                        VALIDATE tbgen_trans_pend.
                    END.

                IF par_indvalid = 1 OR (par_indvalid = 0 AND tt-criticas_transacoes_oper.flgtrans = FALSE)THEN
                    DO:
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Cod. Transacao Pendente",
                                             INPUT "",
                                             INPUT STRING(tbgen_trans_pend.cdtransacao_pendente)).
            
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Data do Movimento",
                                             INPUT "",
                                             INPUT STRING(tbgen_trans_pend.dtmvtolt,"99/99/9999")).
            
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "CPF do Operador",
                                             INPUT "",
                                             INPUT STRING(tbgen_trans_pend.nrcpf_operador)).
            
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Tipo de Transacao",
                                             INPUT "",
                                             INPUT STRING(tbgen_trans_pend.tptransacao)).
            
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Origem",
                                             INPUT "",
                                             INPUT STRING(tbgen_trans_pend.idorigem_transacao)).
            
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "hrregistro_transacao",
                                             INPUT "",
                                             INPUT STRING(tbgen_trans_pend.hrregistro_transacao)).
            
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Situacao",
                                             INPUT "",
                                             INPUT STRING(tbgen_trans_pend.idsituacao_transacao)).
                    
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Critica",
                                             INPUT "",
                                             INPUT STRING(tbgen_trans_pend.dtcritica,"99/99/9999")).
            
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Codigo do PA",
                                             INPUT "",
                                             INPUT STRING(tbgen_trans_pend.cdagetfn)).
            
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "Numero do Terminal",
                                             INPUT "",
                                             INPUT STRING(tbgen_trans_pend.nrterfin)).
                END.
            END.

    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE pc_valid_repre_legal_trans:
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flvldrep AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
        
    DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsorigem AS CHAR                                    NO-UNDO.
    DEF VAR aux_dstransa AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdrowid AS ROWID                                   NO-UNDO.
    
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_valid_repre_legal_trans
     aux_handproc = PROC-HANDLE NO-ERROR
     (INPUT par_cdcooper,
      INPUT par_nrdconta,
      INPUT par_idseqttl,
      INPUT par_flvldrep,
     OUTPUT 0, /* par_cdcritic */
     OUTPUT ""). /* par_dscritic */
     
    CLOSE STORED-PROC pc_valid_repre_legal_trans
       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} } 

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_valid_repre_legal_trans.pr_cdcritic 
                          WHEN pc_valid_repre_legal_trans.pr_cdcritic <> ?
           aux_dscritic = pc_valid_repre_legal_trans.pr_dscritic 
                          WHEN pc_valid_repre_legal_trans.pr_dscritic <> ?.

    IF  aux_cdcritic > 0 OR 
        aux_dscritic <> "" THEN
        DO:
            ASSIGN par_cdcritic = aux_cdcritic
                   par_dscritic = aux_dscritic. 

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE pc_valores_online:
    DEF  INPUT PARAM par_cdtptran AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdtransa AS INTE                           NO-UNDO.
    /* AUXILIAR */
    DEF VAR aux_vlcheque          AS DECI                           NO-UNDO.
    DEF VAR aux_vltitulo          AS DECI                           NO-UNDO.

    IF CAN-DO("1,3,5",STRING(tt-tbgen_trans_pend.tptransacao)) THEN /* Transf.Intracoop,Crédito Salário,Transf.Intercoop */
        DO:
            FOR FIRST tt-tbtransf_trans_pend FIELDS(dtdebito vltransferencia) WHERE tt-tbtransf_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK. END.
            
            FIND FIRST tt-vlrdat WHERE tt-vlrdat.dattrans = tt-tbtransf_trans_pend.dtdebito EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
            IF NOT AVAIL tt-vlrdat THEN
                DO:
                    CREATE tt-vlrdat.
                    ASSIGN tt-vlrdat.dattrans = tt-tbtransf_trans_pend.dtdebito.
                END.
                
                IF tt-tbgen_trans_pend.idmovimento_conta = 1 THEN /* Crédito */
                    ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin - tt-tbtransf_trans_pend.vltransferencia.
                ELSE IF tt-tbgen_trans_pend.idmovimento_conta = 2 THEN /* Débito */
                    ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin + tt-tbtransf_trans_pend.vltransferencia.
                ELSE IF tt-tbgen_trans_pend.idmovimento_conta = 3 THEN /* Agendamento */
                    ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin + tt-tbtransf_trans_pend.vltransferencia.
        END.
    ELSE IF tt-tbgen_trans_pend.tptransacao = 4 
         OR tt-tbgen_trans_pend.tptransacao = 22
         THEN /* TED */
        DO:
            FOR FIRST tt-tbspb_trans_pend WHERE tt-tbspb_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK. END.
            
            FIND FIRST tt-vlrdat WHERE tt-vlrdat.dattrans = tt-tbspb_trans_pend.dtdebito EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
            IF NOT AVAIL tt-vlrdat THEN
                DO:
                    CREATE tt-vlrdat.
                    ASSIGN tt-vlrdat.dattrans = tt-tbspb_trans_pend.dtdebito.
                END.
            
            IF tt-tbgen_trans_pend.idmovimento_conta = 1 THEN /* Crédito */
                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin - tt-tbspb_trans_pend.vlted.
            ELSE IF tt-tbgen_trans_pend.idmovimento_conta = 2 THEN /* Débito */
                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin + tt-tbspb_trans_pend.vlted.
            ELSE IF tt-tbgen_trans_pend.idmovimento_conta = 3 THEN /* Agendamento */
                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin + tt-tbspb_trans_pend.vlted.
    
        END.
    ELSE IF tt-tbgen_trans_pend.tptransacao = 2 THEN /* Pagamentos */
        DO:
            FOR FIRST tt-tbpagto_trans_pend WHERE tt-tbpagto_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK. END.
            
            FIND FIRST tt-vlrdat WHERE tt-vlrdat.dattrans = tt-tbpagto_trans_pend.dtdebito EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
            IF NOT AVAIL tt-vlrdat THEN
                DO:
                    CREATE tt-vlrdat.
                    ASSIGN tt-vlrdat.dattrans = tt-tbpagto_trans_pend.dtdebito.
                END.
            
            IF tt-tbgen_trans_pend.idmovimento_conta = 1 THEN /* Crédito */
                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin - tt-tbpagto_trans_pend.vlpagamento.
            ELSE IF tt-tbgen_trans_pend.idmovimento_conta = 2 THEN /* Débito */
                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin + tt-tbpagto_trans_pend.vlpagamento.
            ELSE IF tt-tbgen_trans_pend.idmovimento_conta = 3 THEN /* Agendamento */
                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin + tt-tbpagto_trans_pend.vlpagamento.
        END.
    ELSE IF tt-tbgen_trans_pend.tptransacao = 6 THEN /* Pré-Aprovado */
        DO:
            FOR FIRST tt-tbepr_trans_pend WHERE tt-tbepr_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK. END.
            
            FIND FIRST tt-vlrdat WHERE tt-vlrdat.dattrans = tt-tbgen_trans_pend.dtmvtolt EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
            IF NOT AVAIL tt-vlrdat THEN
                DO:
                    CREATE tt-vlrdat.
                    ASSIGN tt-vlrdat.dattrans = tt-tbgen_trans_pend.dtmvtolt.    
                END.
            
            IF tt-tbgen_trans_pend.idmovimento_conta = 1 THEN /* Crédito */
                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin - tt-tbepr_trans_pend.vlemprestimo.
            ELSE IF tt-tbgen_trans_pend.idmovimento_conta = 2 THEN /* Débito */
                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin + tt-tbepr_trans_pend.vlemprestimo.
            ELSE IF tt-tbgen_trans_pend.idmovimento_conta = 3 THEN /* Agendamento */
                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin + tt-tbepr_trans_pend.vlemprestimo.
    
        END.
    ELSE IF tt-tbgen_trans_pend.tptransacao = 7 THEN /* Aplicações */
        DO:
            FOR FIRST tt-tbcapt_trans_pend WHERE tt-tbcapt_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK. END.
            
            FIND FIRST tt-vlrdat WHERE tt-vlrdat.dattrans = tt-tbgen_trans_pend.dtmvtolt EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
            IF NOT AVAIL tt-vlrdat THEN
                DO:
                    CREATE tt-vlrdat.
                    ASSIGN tt-vlrdat.dattrans = tt-tbgen_trans_pend.dtmvtolt.
                END.
            
            IF tt-tbgen_trans_pend.idmovimento_conta = 1 THEN /* Crédito */
                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin - tt-tbcapt_trans_pend.vlresgate.
            ELSE IF tt-tbgen_trans_pend.idmovimento_conta = 2 THEN /* Débito */
                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin + tt-tbcapt_trans_pend.vlresgate.
            ELSE IF tt-tbgen_trans_pend.idmovimento_conta = 3 THEN /* Agendamento */
                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin + tt-tbcapt_trans_pend.vlresgate.
    
        END.
    ELSE IF tt-tbgen_trans_pend.tptransacao = 8 THEN /* Débito Automático */
        DO:
            FOR FIRST tt-tbconv_trans_pend WHERE tt-tbconv_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK. END.
            
            FIND FIRST tt-vlrdat WHERE tt-vlrdat.dattrans = tt-tbconv_trans_pend.dtdebito_fatura EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
            IF NOT AVAIL tt-vlrdat THEN
                DO:
                    CREATE tt-vlrdat.
                END.
    
            ASSIGN tt-vlrdat.dattrans = tt-tbconv_trans_pend.dtdebito_fatura.
    
            IF tt-tbgen_trans_pend.idmovimento_conta = 1 THEN /* Crédito */
                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin - tt-tbconv_trans_pend.vlmaximo_debito.
            ELSE IF tt-tbgen_trans_pend.idmovimento_conta = 2 THEN /* Débito */
                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin + tt-tbconv_trans_pend.vlmaximo_debito.
            ELSE IF tt-tbgen_trans_pend.idmovimento_conta = 3 THEN /* Agendamento */
                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin + tt-tbconv_trans_pend.vlmaximo_debito.
        END.
    ELSE IF tt-tbgen_trans_pend.tptransacao = 9 THEN /* Folha de Pagamento */
        DO:
            FOR FIRST tt-tbfolha_trans_pend WHERE tt-tbfolha_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK. END.
            
            FIND FIRST tt-vlrdat WHERE tt-vlrdat.dattrans = tt-tbfolha_trans_pend.dtdebito EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
            IF NOT AVAIL tt-vlrdat THEN
                DO:
                    CREATE tt-vlrdat.
                    ASSIGN tt-vlrdat.dattrans = tt-tbfolha_trans_pend.dtdebito.
                END.
            
            IF tt-tbgen_trans_pend.idmovimento_conta = 1 THEN /* Crédito */
                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin - tt-tbfolha_trans_pend.vlfolha.
            ELSE IF tt-tbgen_trans_pend.idmovimento_conta = 2 THEN /* Débito */
                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin + tt-tbfolha_trans_pend.vlfolha.
            ELSE IF tt-tbgen_trans_pend.idmovimento_conta = 3 THEN /* Agendamento */
                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin + tt-tbfolha_trans_pend.vlfolha.
        END.
    ELSE IF tt-tbgen_trans_pend.tptransacao = 10 THEN /* Pacote de tarifas */
        DO:
            FOR FIRST tt-tbtarif_pacote_trans_pend WHERE tt-tbtarif_pacote_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK. END.            
            
            FIND FIRST tt-vlrdat WHERE tt-vlrdat.dattrans = tt-tbtarif_pacote_trans_pend.dtinicio_vigencia EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
            IF NOT AVAIL tt-vlrdat THEN
                DO:
                    CREATE tt-vlrdat.
                    ASSIGN tt-vlrdat.dattrans = tt-tbgen_trans_pend.dtmvtolt.
                END.
            
            IF tt-tbgen_trans_pend.idmovimento_conta = 1 THEN /* Crédito */
                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin - tt-tbtarif_pacote_trans_pend.vlpacote.
            ELSE IF tt-tbgen_trans_pend.idmovimento_conta = 2 THEN /* Débito */
                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin + tt-tbtarif_pacote_trans_pend.vlpacote.
            ELSE IF tt-tbgen_trans_pend.idmovimento_conta = 3 THEN /* Agendamento */
                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin + tt-tbtarif_pacote_trans_pend.vlpacote.
        END.
ELSE IF tt-tbgen_trans_pend.tptransacao = 11 THEN /* Pagamentos DARF/DAS */
      DO:
          FOR FIRST tt-tbpagto_darf_das_trans_pend WHERE tt-tbpagto_darf_das_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK. END.
          
          FIND FIRST tt-vlrdat WHERE tt-vlrdat.dattrans = tt-tbpagto_darf_das_trans_pend.dtdebito EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF NOT AVAILABLE tt-vlrdat THEN
              DO:
                  CREATE tt-vlrdat.
                  ASSIGN tt-vlrdat.dattrans = tt-tbpagto_darf_das_trans_pend.dtdebito.
              END.
          
          IF tt-tbgen_trans_pend.idmovimento_conta = 1 THEN /* Crédito */
              ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin - tt-tbpagto_darf_das_trans_pend.vlpagamento.
          ELSE IF tt-tbgen_trans_pend.idmovimento_conta = 2 THEN /* Débito */
              ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin + tt-tbpagto_darf_das_trans_pend.vlpagamento.
          ELSE IF tt-tbgen_trans_pend.idmovimento_conta = 3 THEN /* Agendamento */
              ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin + tt-tbpagto_darf_das_trans_pend.vlpagamento.
      END.
	  
ELSE IF tt-tbgen_trans_pend.tptransacao = 14 OR    /*Pagamentos  FGTS */
        tt-tbgen_trans_pend.tptransacao = 15 THEN /* DAE */
      DO:
          FOR FIRST tt-tbpagto_tributos_trans_pend WHERE tt-tbpagto_tributos_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK. END.
          
          FIND FIRST tt-vlrdat WHERE tt-vlrdat.dattrans = tt-tbpagto_tributos_trans_pend.dtdebito EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF NOT AVAILABLE tt-vlrdat THEN
              DO:
                  CREATE tt-vlrdat.
                  ASSIGN tt-vlrdat.dattrans = tt-tbpagto_tributos_trans_pend.dtdebito.
              END.
          
          IF tt-tbgen_trans_pend.idmovimento_conta = 1 THEN /* Crédito */
              ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin - tt-tbpagto_tributos_trans_pend.vlpagamento.
          ELSE IF tt-tbgen_trans_pend.idmovimento_conta = 2 THEN /* Débito */
              ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin + tt-tbpagto_tributos_trans_pend.vlpagamento.
          ELSE IF tt-tbgen_trans_pend.idmovimento_conta = 3 THEN /* Agendamento */
              ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin + tt-tbpagto_tributos_trans_pend.vlpagamento.
      END.
      
	/* Contrato SMS */
ELSE IF tt-tbgen_trans_pend.tptransacao = 16 OR
        tt-tbgen_trans_pend.tptransacao = 17  THEN
    DO:
                                                                                                                                                                                    
	  FIND FIRST tt-vlrdat WHERE tt-vlrdat.dattrans = tt-tbgen_trans_pend.dtmvtolt EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                                                                                                                                                                    
	  IF NOT AVAIL tt-vlrdat THEN
	  DO:
			CREATE tt-vlrdat.
			ASSIGN tt-vlrdat.dattrans = tt-tbgen_trans_pend.dtmvtolt.
	
	  END.
	END.
    ELSE IF tt-tbgen_trans_pend.tptransacao = 12 THEN /* Desconto de Cheque */
      DO:
          FOR EACH tt-tbdscc_trans_pend WHERE tt-tbdscc_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK. 
          
             ASSIGN aux_vlcheque = aux_vlcheque + tt-tbdscc_trans_pend.vlcheque.
             
          END.
          
          FIND FIRST tt-vlrdat WHERE tt-vlrdat.dattrans = tt-tbgen_trans_pend.dtmvtolt EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF NOT AVAILABLE tt-vlrdat THEN
        DO:
          CREATE tt-vlrdat.
          ASSIGN tt-vlrdat.dattrans = tt-tbgen_trans_pend.dtmvtolt.
      
        END.
      END. 
    ELSE IF tt-tbgen_trans_pend.tptransacao = 19 THEN /*Bordero Desconto Titulo*/
      DO:
          FOR EACH tt-tbdsct_trans_pend WHERE tt-tbdsct_trans_pend.cdtransacao_pendente = tt-tbgen_trans_pend.cdtransacao_pendente NO-LOCK. 
          
             ASSIGN aux_vltitulo = aux_vltitulo + tt-tbdsct_trans_pend.vltitulo.
             
          END.
          
          FIND FIRST tt-vlrdat WHERE tt-vlrdat.dattrans = tt-tbgen_trans_pend.dtmvtolt EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF NOT AVAILABLE tt-vlrdat THEN
          DO:
             CREATE tt-vlrdat.
             ASSIGN tt-vlrdat.dattrans = tt-tbgen_trans_pend.dtmvtolt.
        END.
    END.      
END PROCEDURE.

PROCEDURE pc_estorno_aprova:
    DEF INPUT PARAM par_indvalid AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtransan AS DATE NO-UNDO.
    DEF INPUT PARAM par_vlrtrans AS DEC NO-UNDO.
    DEF INPUT PARAM par_conttran AS INT NO-UNDO.
        
    IF par_indvalid = 0 AND par_conttran = 1 THEN
        DO:
            FIND FIRST tt-vlrdat WHERE tt-vlrdat.dattrans = par_dtransan EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF tt-tbgen_trans_pend.idmovimento_conta = 1 THEN /* Crédito */
                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin + par_vlrtrans.
            ELSE IF tt-tbgen_trans_pend.idmovimento_conta = 2 THEN /* Débito */
                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin - par_vlrtrans.
            ELSE IF tt-tbgen_trans_pend.idmovimento_conta = 3 THEN /* Agendamento */
                ASSIGN tt-vlrdat.vlronlin = tt-vlrdat.vlronlin - par_vlrtrans.
        END.

END PROCEDURE.

FUNCTION IdentificaMovCC RETURNS INTEGER 
        (INPUT par_tptransacao   AS INTEGER,
         INPUT par_idagendamento AS INTEGER,
         INPUT par_tpoperacao    AS INTEGER):
    
    /* Quando operaçao for 13 (Recarga de Celular), nao deve ser considerado 
    no limite diário de operaçoes no IB (cairá automaticamente no RETURN 4) */
    IF par_idagendamento = 2 AND par_tptransacao <> 13 THEN
       RETURN 3. /* Agendamentos */
    ELSE
    IF par_tptransacao = 1 OR   /* Transferência Intracoop. */
       par_tptransacao = 2 OR   /* Pagamentos               */
       par_tptransacao = 3 OR   /* Crédito de Salário       */
       par_tptransacao = 4 OR   /* TED                      */
       par_tptransacao = 22 OR   /* TED JUDICIAL REQ39      */
       
       par_tptransacao = 5 OR   /* Transferencia Intercoop. */
       par_tptransacao = 11 OR  /* Pagamento DARF/DAS */
       par_tptransacao = 14 OR  /* Pagamento FGTS */
       par_tptransacao = 15 THEN /* Pagamento DAE */
       RETURN 2. /* Débitos */
    ELSE
    IF (par_tptransacao = 21) OR  /* Contratacao de emprestimo */
       (par_tptransacao = 6) OR   /* Crédito Pré-Aprovado        */
       (par_tptransacao = 7 AND 
        par_tpoperacao  = 1) OR   /* Cancelamento Nova Aplicação */
       (par_tptransacao = 7 AND 
        par_tpoperacao  = 2) THEN /* Resgate Aplicação           */
       RETURN 1. /* Créditos */
    ELSE
       RETURN 4. /* Sem Movimentação na CC */
END FUNCTION.

PROCEDURE gera_erro_transacao:

    DEF INPUT PARAM par_cdcooper AS INTEGER     NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHARACTER   NO-UNDO.
    DEF INPUT PARAM par_dscritic AS CHARACTER   NO-UNDO.
    DEF INPUT PARAM par_dsorigem AS CHARACTER   NO-UNDO.
    DEF INPUT PARAM par_dstransa AS CHARACTER   NO-UNDO.
    DEF INPUT PARAM par_flgtrans AS LOGICAL     NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHARACTER   NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTEGER     NO-UNDO.
    DEF INPUT PARAM par_nrdrowid AS CHARACTER   NO-UNDO.
    DEF INPUT PARAM par_aprovada AS LOGICAL     NO-UNDO.
    DEF INPUT PARAM par_indvalid AS INTE        NO-UNDO.
    DEF INPUT PARAM par_dtdebito AS DATE        NO-UNDO.
    DEF INPUT PARAM par_vlrtrans AS DEC         NO-UNDO.
    DEF INPUT PARAM par_conttran AS INT         NO-UNDO.                        

    IF  NOT par_aprovada AND par_vlrtrans <> 0 THEN
        RUN pc_estorno_aprova (INPUT par_indvalid,
                               INPUT par_dtdebito,
                               INPUT par_vlrtrans,
                               INPUT par_conttran).

    RUN proc_cria_critica_transacao_oper (INPUT par_nrdrowid,
                                          INPUT par_aprovada,
										  INPUT par_indvalid,
                                          INPUT par_dscritic).
    
    RETURN "OK".

END PROCEDURE.
                                                                                                                                                                                
