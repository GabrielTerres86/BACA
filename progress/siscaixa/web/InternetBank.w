&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-html 

/*------------------------------------------------------------------------------

   ATENCAO!!!
   
   EH NECESSARIO SALVAR E COMPILAR O PROGRAMA EM TODAS AS COOPERATIVAS APOS A
   LIBERACAO ( /usr/coop/......./siscaixa/web/InternetBank.w ),PARA ATUALIZAR 
   OS .r E OS .off DESTE PROGRAMA.
  
   Programa: siscaixa/web/InternetBank.w
   Sistema : Internet - aux_cdcooper de Credito
   Sigla   : CRED
   Autor   : Junior
   Data    : Julho/2004.                       Ultima atualizacao: 09/10/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Programa que gera os dados para o acesso a conta via Internet.
   
   Alteracoes:   27/09/2004 - Incluir operacao 10 - Extrato conta Investimento,
                              e dados no acesso rapido (numero da conta inv. e 
                              saldo da aux_nrdconta inv.). (Junior)
                              
                 05/10/2004 - Na operacao 10, listar primeiro os creditos e
                              depois os debitos, por data, para nao aparecer
                              saldos negativos (Junior).
                              
                 25/01/2005 - Incluir rotinas para calculo da aliquota do IR
                              sobre aplicacoes (Junior).
                              
                 28/01/2005 - Incluir valor da conta investimento no saldo de
                              c/c do Informe de Rendimentos IR pessoa fisica
                              (Junior).
                              
                 03/01/2005 - Acerto no extrato dos 5 e 15 ultimos dias 
                              (Junior/Mirtes).
                              
                 06/04/2005 - Incluir no Informe de rendimentos Pes. Fis o
                              valor do IR sobre Aplicacoes (Junior).
                              
                 30/05/2005 - Acerto no calculo do saldo do mes anterior, busca
                              valor do crapsda (Junior).
                              
                 03/06/2005 - Acerto no calculo do extrato dos ultimos 5 e 15
                              dias, controlando se rodou o crps008 (Junior).
                              
                 27/07/2005 - Alterar "Lancamentos Futuros", incluindo juros
                              cheque especial, multas de c/c (Junior).
                              
                 08/09/2005 - Incluir limite e saldo de desconto de cheques
                              (Junior).
                              
                 25/09/2005 - Reformulacao do programa, para inclusao de novos
                              servicos. Utilizacao de BO's para rotinas 
                              (Junior).

                 24/10/2005 - Inclusao das BO's de extrato de conta corrente,
                              extrato de emprestimos e lancamentos futuros
                              (Junior).
                              
                 15/11/2005 - Inclusao das BO's de RDCA e Poupanca Programada
                              (Junior)
                              
                 08/12/2005 - Inclusao da BO de Desconto de Cheques (Junior).
                 
                 09/01/2006 - Mostrar a data da liberacao de cheques no extrato
                              de aux_nrdconta corrente (Junior).
                              
                 12/01/2006 - Tratamento para nao mostrar o Informe de Rendi-
                              mentos Pessoa Fisica (Junior).
                              
                 18/01/2006 - Ajustes no calculo do Imposto de Renda (Junior).
                 
                 03/03/2006 - Em lancamentos futuros, fazer EMPTY TEMP-TABLE 
                              tt-saldo, e alterado chamada da BO b1wgen0002.p
                              na tabela tt-saldo para INPUT-OUTPUT (Junior).
                 
                 20/03/2006 - Incluir linha com valor total de lancamentos
                              futuros na operacao 9 (Junior).
                 
                 22/03/2006 - Incluir alteracoes na rotina de busca de
                              associado, TRANSACTION na rotina de RDCA e
                              totalizador de lancamentos futuros na operacao 9
                              (Junior).
                              
                 24/05/2006 - Incluir a variavel "aux_cdcooper" vinda do
                              ambiente web, para validacao do crapcop
                              (Junior).
                              
                 24/05/2006 - Incluido codigo da aux_cdcooper nas leituras
                              das tabelas (Diego).
                              
                 20/09/2006 - Inclusao de BO's para gerar boleto (David).

                 03/10/2006 - Inclusao de BO para carregar titulares (David).

                 27/11/2006 - Retornar o codigo do tipo de pessoa no XML pela
                              operacao 1 (David).

                 07/12/2006 - Inclusao de rotina para gerencimento de sacados
                              (David).

                 11/03/2007 - Retornar codigo da situcao da conta/ITG (David).
                 
                 12/03/2007 - Alterada rotina de consulta e geracao de boletos.
                              Inclusao de BO para carregar cheques pendentes
                              (David).

                 12/04/2007 - Incluir rotina de LOG para operacao de cheques
                              pendentes (David).

                 20/04/2007 - Incluir campo "Complemento" nas rotinas de
                              boletos de cobrana (David).

                 24/04/2007 - Incluir rotina para transferencia (David).
                 
                 15/05/2007 - Incluir rotina para visualizacao de holerites
                              (David).

                 08/08/2007 - Rotina para operacao 10 extrato C.I.(Guilherme).
                 
                 10/08/2007 - Incluida operacao 30 ref. listagem de convenios
                              aceitos para pagamento na Internet (Diego).
                              
                 25/09/2007 - Passar a data aux_dtmvtocd para as rotinas de
                              pagamento (Evandro).
                              
                 02/10/2007 - Tirado o QUIT quando a senha estiver incorreta
                              (Evandro).

                 09/10/2007 - Gerar log com data TODAY e nao dtmvtolt (David).

                 06/11/2007 - Operacoes para modulo de plano de capital (David).
                            - Tratamento para bloqueio de aux_cddsenha (David).

                 07/02/2008 - Reformular operacao de Cheques Pendentes (David)
                            - Nova procedure para BO b1wgen0002 (David)
                            - Criar fontes separados (InternetBankXX.p) para
                              operacoes que ainda nao possuem (David)

                 19/03/2008 - Criar operacao 36 e 37 - Arquivo de retorno de
                              cobranca (David).

                 02/05/2008 - Retornar vencimentos das poupancas na operacao 6 
                              (David).

                 09/04/2008 - Adaptacao para agendamento de pagamentos 
                            - Melhorias nas rotinas de cobranca (David).
                            - Fone de ctato e hr limite de cancelamento
                              para instrucao de estorno(Guilherme).

                 31/07/2008 - Retornar campo nrseqaut na operacao 25 (David).

                 01/09/2008 - Novas variaveis para rotina 17 (David).

                 11/09/2008 - Pegar parametro nro_convenio na operacao 40
                              (David).

                 29/09/2008 - Retornar valores de desconto de titulos na 
                              operacao 1 (David).

                 12/11/2008 - Adaptacao para novo acesso a conta para pessoas
                              juridicas (David).
                              
                 12/02/2009 - Incluir operacao para extrato de tarifas (David).
                 
                 19/02/2009 - Melhorias no servico de cobranca (David).
                 
                 20/04/2009 - Permitir escolha do ano referente ao IR, rotina
                              de informe de rendimentos (David).

                 28/05/2009 - Novo parametro "cdcartei" para a rotina de 
                              geracao de boletos (David).
                              
                 19/06/2009 - Incluido parametro nrctremp na chamada da operacao
                              3 para validar o contrato de emprestimo(Guilherme)
                 
                 27/07/2009 - Alteracoes do Projeto de Transferencia para 
                              Credito de Salario (David).

                 06/10/2009 - Melhorias na operacao 12 (David).
                 
                 16/12/2009 - Nova consulta de cheques na operacao 21 (David).
                 
                 05/03/2010 - Alteracoes na rotina 17. Adaptacao da b1wgen0006
                              para rotina de POUP.PROGRAMADA (David).
                              
                 22/04/2010 - Retornar flag indicando se cooperado possui
                              cartao bradesco (David).             
                              
                 24/05/2010 - Ajustar rotinas do modulo MEU CADASTRO para as
                              alteracoes do projeto tela CONTAS (David).
                              
                 04/08/2010 - Melhoria para paginacao do extrato (David).
                 
                 23/08/2010 - Receber ip do usuario para controle de acesso
                              (David).
                              
                 07/12/2010 - Tratamento para Projeto DDA (David).
                 
                 21/12/2010 - Melhoria nas operacoes 15 e 16 (David).

                 16/03/2011 - Novos parametros para InternetBank4.p
                              (Guilherme/Supero)
                 
                 12/04/2011 - Criado operacao 63 (consultar sacado elet.),
                              Criado operacao 64 (Adesao ao DDA), 
                              Criado operacao 65 (listar Tit. Bloq. (DDA)) 
                              (Jorge).
                              
                 29/04/2011 - Criado operacao 66 (intrucoes de titulos)
                              (Jorge).
                 
                 24/05/2011 - Criado operacao 67 (pesquisa endereco por cep)
                              (Jorge).
                              
                 05/07/2011 - Incluidos novos parametros na chamada do 
                              InterbetBank45 (Henrique).
                            - Alterado tipo de de parametro aux_flgregis de 
                              LOGI para INTE (Jorge).
                              
                 15/07/2011 - Adicionado param de entrada em op.59, flgregis
                              (Jorge).

                 01/08/2011 - Criado operacao 68 e 70 (Extrato Cecred Visa)
                              (Guilherme/Supero).
                              
                 31/08/2011 - Criado operacao 69 (importacao de cobrancas)
                              (Jorge).
                              
                 04/10/2011 - Adicionado parametros novos da operacao 25.(Jorge)
                            - Adicionado parametros novos da operacao 38.(Jorge)
                            
                 06/10/2011 - Parametro cpf operador na operacao 22 e 27 
                            - Criado operacao 73 (Transacoes pendentes)
                            - Criado operacao 74 (Exclusao Trans. pendentes)
                            - Criado operacao 75 (Efetivacao Trans. pendentes)
                              (Guilherme).
                              
                 18/10/2011 - Criado operacao 71 (Servico de Mensagens). (Jorge)
                 
                 25/11/2011 - Incluir parametros na operacao 1, 2 e 18 com dados  
                              da origem da solicitacao (IP usuario) (David).
                              
                 22/12/2011 - Incluir parâmetro [aux_dtmvtolt] na chamada do
                              InternetBank70.p (Lucas).
                              
                 17/01/2012 - Incluir operacao 76 e 77 (Guilherme).
                 
                 09/03/2012 - Adicionar parametro aux_dtmvtoan em op 1. (Jorge)
                 
                 14/03/2012 - Adicionado xml_operacao25.cdbcoctl e
                              xml_operacao25.cdagectl na procedure
                              proc_operacao25. (Fabricio)

                 14/05/2012 - Projeto TED Internet (David).

                 03/07/2012 - Incluir tipo de emprestimo na operacao 13
                              (Gabriel)  

                 08/07/2012 - Passar parametros operador como CHAR (Guilherme)

                 06/08/2012 - Incluir operacao 81 (Guilherme/Supero)
                 
                 21/08/2012 - Ajuste validacao senha (David).
                 
                 25/10/2012 - Incluir campo na validacao de senha (David).
                 
                 07/11/2012 - Implementar letras de seguranca (David).              
                 
                 05/04/2013 - Inclusão de saída dos campos da Temp-Table 
                              xml_operacao30 para horário dos convenios (Lucas).
                 
                 25/04/2013 - Ajuste em operacao 66, ajustado parametro de 
                              entrada de cdtpinsc para inpessoa e adcionado
                              parametro de entrada vldescto.
                              Adicionado parametro de entrada aux_tpinstru
                              em operacao 20.(Jorge)
                              
                 22/07/2013 - Ajustes transferencia intercooperativa (Lucas). 
                 
                 24/07/2013 - 2a fase do Projeto de Credito. (Gabriel).    
                 
                 11/11/2013 - Apresentar operacao no log do webspeed (David).
                 
                 25/02/2014 - Removido proc_operacao35. (Fabricio)
                 
                 24/03/2014 - Implementar log de sessao para Oracle (David).
                 
                 07/05/2014 - Ajustes referente ao projeto captação:
                             - Incluido a proc_operacao83
                             - Incluido a proc_operacao84
                             - Incluido a proc_operacao85
                             - Incluido a proc_operacao86
                             - Incluido a proc_operacao88
                             - Incluido a proc_operacao89
                             (Adriano).
                             
                 30/06/2014 - Incluir operacao 87 (Chamado 161848) 
                             (Jonata - RKAM).            
                 
                 06/08/2014 - Incluir operacao 91 agendamentos
                              de aplicacoes e resgates (Tiago/Gielow)
                              
                 11/08/2014 - Incluir a operacao 90 - Credito Pre-aprovado
                              (James)
                              
                 13/08/2014 - Incluir a operacao 92 - Buscar as parcela 
                              do Credito Pre-aprovado (James)
                              
                 18/08/2014 - Incluir a operacao 93 - Imprimir o extrato de
                              contratacao do produto credito automatico 
                              (James)
                              
                 18/08/2014 - Inlusão do parâmetro aux_dshistor na operação
                              22 (Vanessa)   
                              
                 18/08/2014 - Incluir a operacao 94 - Buscar tabela com qtd
                              dias de carencia (Tiago).  
                              
                 19/08/2014 - Incluir a operacao 95 - Buscar resumo das aplicacoes
                              com os valores de imposto de renda.(Douglas - 
                              Projeto Captação Internet 2014/2).
                              
                 20/08/2014 - Incluido a operacao 96 (Adriano).
                 
                 21/08/2014 - Incluido a operacao 98 - Buscar convenios aceitos
                              (cod. barras c/ debito automatico) -
                              Debito Automatico Facil.
                              (Chamado 184458) - (Fabricio).

                 22/08/2014 - Incluido a operacao 97 - Inclusao de agedamentos
                              aplicacao e resgate (Tiago / Gielow).
                              
                 25/08/2014 - Incluido a operacao 99 - Cadastrar autorizacao de
                              debito - Debito Automatico Facil. (Fabricio)
                              
                 25/08/2014 - Incluido a operacao 100 - Gravar os dados 
                              do projeto pre-aprovado. (James)
                              
                 26/08/2014 - Incluido a operacao 101 - Verificar aceite do
                              Pagto Titulos por Arquivo (Guilherme/SUPERO)
                              
                 27/08/2014 - Incluido a operacao 103 - Consulta extrato de
                              TED e TEC - Chamado 161899 (Jonathan/RKAM)                         
                 
                 28/08/2014 - Incluir a operacao 104 - Validar valor de limite
                              para resgate pela internet.(Douglas - 
                              Projeto Captação Internet 2014/2).
                              
                 28/08/2014 - Incluido a operacao 105 - Buscar autorizacoes de
                              de debito cadastradas - Debito Automatico Facil.
                              (Fabricio)
                      
                 29/08/2014 - Incluido operacao 106 - Validar inclusao de novo
                              agendamento e Operacao 107 - Soma da data de 
                              vencimento (Tiago/Gielow Projeto Captacao).
                              
                 05/09/2014 - Incluido a operacao 110 - Validar/Cadastrar/
                              Excluir suspensao de autorizacao de debito - 
                              Debito Automatico Facil. (Fabricio)
                              
                 08/09/2014 - Incluido a operacao 111 - Buscar autorizacoes de
                              de debito suspensas - Debito Automatico Facil.
                              (Fabricio)
                              
                 08/09/2014 - Incluido a operacao 112 - Efetuar cancelamento
                              de agendamento de aplicacao e resgate
                              (Tiago/Gielow).
                              
                 09/09/2014 - Incluido a operacao 113 - Buscar lancamentos 
                              agendados e efetivados - Debito Automatico Facil.
                              (Fabricio).
                 
                 10/09/2014 - Incluido a operacao 114 - Efetuar cancelamento
                              de detalhe de agendamento de aplicacao e resgate
                              (Tiago/Gielow).
                              
                              Retornar o campo flgpreap na operacao 13. (James)
                              
                            - Incluido a operacao 115 - Bloquear/Desbloquear
                              lancamento de debito agendado - 
                              Debito Automatico Facil. (Fabricio)
                 
                 11/09/2014 - Pagto Titulos por Arquivo
                              Incluido a operacao 102 - Listar retornos
                              Incluido a operacao 117 - Gerar arquivo retorno
                              Incluido a operacao 120 - Buscar Termos Servico
                              (Guilherme/SUPERO)
                               
                            - Incluido a operacao 118 - Listar protocolos de
                              operacoes do Debito Automatico Facil. (Fabricio)
                              
                 12/09/2014 - Incluido a operacao 119 - Cancelar varios
                              agendamentos (Tiago/Gielow).
                 
                 15/09/2014 - Incluido a operacao 116 - Cadastrar resgate de 
                              aplicação (Douglas - Projeto Captação Internet 2014/2).
                              
                 17/09/2014 - Incluido a operacao 121 - Consultar a quantidade
                              max de meses para agendamento de aplicacao
                              (Tiago/Gielow).
                              
                 18/09/2014 - Ajustes na operacao 9 Chamado: 161874 (Jonathan/RKAM). 
                              
                 22/09/2014 - Remover o parametro aux_dtresgat da operacao 116.
                              (Douglas - Projeto Captação Internet 2014/2)
                              
                 25/09/2014 - Listagem de cooperativa ativas - Projeto Mobile
                              (Guilherme).
                              
                 29/09/2014 - Incluido a operacao 123 - 
                              Calcula as taxas do credito pre-aprovado(James).
                            - Incluido a operacao 124 -
                              Carregar Menu (Guilherme).
                 
                 07/10/2014 - Incluido operacao 125 - Tiago Projeto captacao
                              
                 14/10/2014 - Adicionado a operação 126 - Validação autorização
                              Mobile (Guilherme).
                              
                 23/10/2014 - Quando for chamado o InternetBank99.p, deve ser
                              passado como parametro aux_dtmvtocd e nao
                              aux_dtmvtolt. (Debito Facil - Fabricio)
                              
                 28/10/2014 - Incluido novo parametro para operacao 97
                              qtd de dias max de vencto para agendamento
                              (Tiago).
                              
                 28/10/2014 - Ajuste no envio dos parametros das procedures
                              do pre-aprovado, para enviar o operador 1.
                              (James)
                 
                 03/11/2014 - Adicionado parametros de paginacao em operacao 73.
                              (Jorge/Elton - SD 197579).
                              
                 07/11/2014 - Ajuste flgcript (Guilherme)
                              
                 18/11/2014 - Inclusao do parametro "nrcpfope" na chamada da
                              procedure "proc_operacao90, 92, 100" do 
                              "InternetBank90.p, 92, 100". 
                              (Jaison)
                              
                 20/11/2014 - Verifica o tipo de pessoa (Mobile) (Guilherme).
                 
                 24/11/2014 - Retornar o campo cdorigem na operacao 13. (James)
                 
                 16/12/2014 - Melhorias Cadastro de Favorecidos TED - Inclusao
                              de novo parametro na operacao 80
                             (André Santos - SUPERO)
                             
                 22/12/2014 - Inclusão da operacao 128, consulta de agencia (Vanessa)
                 
                 29/12/2014 - Inclusão param aux_cdhistor, aux_vllanmto e aux_nrdocmto
                               em operacao 103.
                              (Jorge/Elton) - SD 229245
                 
                 23/01/2015 - Ajustar a operacao 20 para gravar as informacoes
                              de email e celular do pagador.
                              (Projeto Boleto por E-mail - Douglas)
                              
                 16/02/2015 - Melhorias InternetBanking - Novas Operacoes
                              129,130, 131 e 132 - Desconto de Cheque/Titulos
                              (Andre Santos - SUPERO)
                              
                 12/03/2015 - Adicionado operacao 133 que gera o log para boletos
                              que não foram enviados por e-mail
                              (Projeto Boleto por E-mail - Douglas)

                 08/04/2015 - Ajustado operacao 4 para emitir boletos no formato de 
                              carnê (Projeto Boleto Formato Carnê - Douglas)
                              
                 15/04/2015 - Inclusão da operacao 134, consulta de bancos pelo ISPB e
                              inclusão do parametro aux_cdispbif na operação 80 (Vanessa)
                              
                 20/04/2015 - Inclusão da operacao 137, verificacao de mensagem de
                              atraso em operacao de credito. (Jorge/Rodrigo)             
                 
                 03/06/2015 - Adição do campo inpessoa no xml da operacao 11 (Dionathan)
                 
                 12/06/2015 - Adicionado operacao 138 para buscar as parcelas
                              do carnê para reimpressão
                              (Projeto Boleto Formato Carnê - Douglas)

                 18/06/2015 - Alterado proc_operacao117 para ler temptable recebida
                              e retornar xml SD294550 (Odirlei-AMcom)
                                                          
                 22/06/2015 - Adição das operações 135 e 136 para utilização no Mobile.
                              (Dionathan)
                             
                 26/06/2015 - Adicionado operação 139 para gerenciar as requisições
                              da tela de Folha de pagamento ( Renato - Supero )

                 09/07/2015 - Ajustar operação 138 para utilizar a temp table
                              de xml_operacao (Douglas - Chamado 303663)
                                                          
                 03/06/2015 - Adição da variavel flmobile para identificar que origem da
                              chamada da operação é do Mobile (Dionathan)
                              
                 22/07/2015 - Adicionado operação 140 e 141 para buscar os dados
                              ( Andre - Supero )
                                                          
                 05/08/2015 - Adicionado operação  e 143 para cadastrar um empregado
                              ( Lombardi )
                              
                 11/08/2015 - Adicionado operação 144 para validar os dados FOLHAIB
                              ( Vanessa )
                              
                 14/08/2015 - Adicionado operação 145 para cadastrar um empregado
                              ( Lombardi )
                  
                 14/08/2015 - Adicionado operação 146 para validar os dados FOLHAIB
                              ( Vanessa ) 
                  
                 17/08/2015 - Adicionado operação 147 para validar os dados FOLHAIB
                              ( Lombardi )
                              
                 19/08/2015 - Adicionado operação 149 para inserir os dados FOLHAIB
                              ( Jaison )
                              
                 19/08/2015 - Adicionado operação 150 para inserir os dados FOLHAIB
                              ( Vanessa )
                              
                 21/08/2015 - Adicionado operação 151 para consultar os dados FOLHAIB
                              ( Vanessa )

                 21/08/2015 - Adicionado operação 152 para manipulacao das mensagens 
                              via IBank. Projeto GPS (Carlos Rafael Tanholi) 
                
                 31/08/2015 - Adicionar operação 153 para ser utilizado pela tela 
                              do GPS no IB ( Renato Darosci - Supero )
                              
                 17/09/2015 - Adicionado operacao 154,155,156,158,159 para pagamento via 
                              InternetBank (Daniel)
                              
                 05/10/2015 - Incluido a operacao 157 - Inscricao no EAD
                              (Jonathan - RKAM).    

			     27/01/2016 - Incluido operacoes 160 e 161 para o Projeto 255.
							  (Reinert)
                              
                 12/11/2015 - Armazenar data selecionada no app mobile para 
                              transferencia com debito Nesta Data.
                              Solucao temporaria para item 1. do chamado 356737. 
                              (David).
                              
                 20/11/2015 - Ajuste na operacao 14 incluso novo campo cdorigem.
                              (Daniel)
                              
                 10/12/2015 - Adicionado parametro idseqttl na operacao 141.
                              (Reinert)
                              
                 10/12/2015 - Adicionado parametro de entrada para operacao 100.
                              (Jorge/David) Proj. 131 Assinatura Multipla
                              
                 21/12/2015 - Validação da assinatura eletrônica do cooperado na
                              para cancelamento e resgate de aplicação - Mobile
                              (Dionathan)	 

                 09/12/2015 - Ajustado chamada da procedure InternetBank59.p, incluso novo
                              parametro inserasa (Daniel/Andrino)
                      
                 15/12/2015 - Inlcusao da operacao 162, para gerar o relatorio
                              de extrato juros/encargos 
                              (Jonathan - RKAM M273).
                              
                 13/01/2016 - Inclusao da operacao 163, reprovacao de transacoes
                              dos operadores de internet, Prj. 131 (Jean Michel).                  
   
                 15/02/2016 - Inclusao de parametro CPF operador para as operacoes
				                      141, 142, 147, 149 e 150 (Marcos-Supero)

                 01/03/2016 - Retirado a passagem do parametro par_dsiduser
                              na chamada da rotina 162 (Adriano).        

				 28/03/2016 - Inclusao do parametro aux_nripuser na chamada da rotina 
				              na chamada da rotina InternetBank22 PRJ118 (Odirlei-AMcom)			  						  						                  
                          
				 30/03/2016 - Ajuste para receber o valor dsiduser e passa-lo para
                              as operacoes 81, 162 (Adriano).
				               		          
                 20/01/2016 - Inlcusao da operacao 164, para gerar o relatorio
                              do CET relacionado ao pré-aprovado contratado através das 
                              plataformas de autoatendimento. E alteracao do retorno
                              da operacao 13 com o novo campo recidepr.
                              (Carlos Rafael Tanholi - Prj 216 - Pré-aprovado fase 2)								                                    
				 11/03/2016 - Inclusao da operacao 166 para buscar as permissoes
				              dos itens do menu do mobile. Projeto 286_3 - Mobile
                              (Lombardi)   

				16/03/2016 - Inclusão da validação da assinatura do cooperado na
                              operação 100 quando não existir criptografia na senha,
                              frase e letras - Mobile (Dionathan)
                 
				29/03/2016 - Inclusão da operacao 168 para retornar as informações
                              de telefone e horários do SAC e da Ouvidoria - Mobile
                              (Dionathan)
                                                                    
                15/04/2016 - Inclusao da operacao 165 e 167 referente as telas de 
						      Pacote de Tarifas para o Projeto 218. (Reinert)
                              
				04/05/2016 - Ajuste para devolver o campo cdageban na chamada da rotina
							 proc_operacao38
							 (Adriano - M117).

			    05/05/2016 - Retirado o passagem do parametro aux_lsvlapag na rotina 22
							(Adriano - M117).

				16/05/2016 - Inclusao do parametro aux_flmobile na rotina 38 
                            (Carlos)
                     
                25/05/2016 - Inclusao do parametro aux_nripuser na rotina 22 
                             (Carlos)

                30/05/2016 - Alteraçoes Oferta DEBAUT Sicredi (Lucas Lunelli - [PROJ320])
                                                                    
                26/07/2016 - Inclusao da operacao 187, pagamento de DARF/DAS,
							 Prj. 338 (Jean Michel).

                 14/07/2016 - M325 Informe de Rendimentos - Novos parametros
                              operacao7. (Guilherme/SUPERO)
				 04/08/2016 - Adicionado tratamento para envio de arquivos de 
							  cobranca por e-mail nas operacoes 36 e 59. (Reinert)

				 17/08/2016 - Adição da coluna nomconta e remoção da tabela
							  xml_operacao11 para utilizacao da tabela generica
							  na operacao 11.
							  PRJ286.5 - Cecred Mobile (Dionathan)
                 22/08/2016 - Adicao do parametro par_indlogin nas operacoes 2 e 18
							  PRJ286.5 - Cecred Mobile (Dionathan)
          
		         21/09/2016 -  P169 Integralização de cotas no IB
                                adição das funções 176 e 177 (Ricardo Linhares)   

		         03/10/2016 - Ajustes referente a melhoria M271 (Operacao 174, 175, 186). (Kelvin)
                    
                 19/12/2016 - Usado 178 e 179 para Custodia de Cheque e Desconto
                             de Cheque. Liberados 180 a 185 para novo projetos.
                             Projeto 300 (Lombardi)
                              
                              
                 11/10/2016 - Ajustes para permitir Aviso cobrança por SMS.
                              operacao4 e 66 - PRJ319 - SMS Cobrança(Odirlei-AMcom)       
                              
                 26/10/2016 - Inclusao da operacao 189 - Servico de SMS de cobranca
                              PRJ319 - SMS Cobrança(Odirlei-AMcom)  
         
                 22/12/2016 - PRJ340 - Nova Plataforma de Cobranca - Fase II. 
                              (Jaison/Cechet)

                 21/02/2017 - Usado 181 para Recarga de Celular de Cheque.
                            - Inclusao dos parametros par_cdtiptra na rotina 39. Projeto 321 (Lombardi)
					 
                 22/02/2017 - Ajustes para correçao de crítica de pagamento DARF/DAS (P.349.2)
                            - Criada op 180 (P.349.2)
                            - Alteraçoes para composiçao de comprovante DARF/DAS Modelo Sicredi
                            (Lucas Lunelli)
                              
                 17/03/2017 - Ajustes operacao 189 - Servico de SMS de cobranca
                              PRJ319.2 - SMS Cobrança(Odirlei-AMcom)    
				 13/03/2017 - Adicionando paginacao na tela de folha, conforme 
			        	      solicitado no chamado 626091 (Kelvin). 
                 17/03/2017 - Incluido IP da transacao na proc_operacao75.
                            PRJ335 - OFSAA (Odirlei-AMcom)

				 04/05/2017 - Alterado parametro dtmvtolt para dtmvtocd na operacao 176 - 
							  Integralizacao de cotas. (Reinert)
                              
                              
                 21/03/2017 - Segunda fase projeto Boleto SMS
                              PRJ319.2 - SMS Cobrança(Ricardo Linhares)                             
                              
                 09/08/2017 - Adicioando as seguintes operacoes
                              - 204 buscar os dados do convenio para upload do arquivo de pagamento
                              - 205 gravar LOG de validaçao do upload do arquivo de pagamento
                              - 210 consultar LOG de validaçao do upload do arquivo de pagamento
                              - 211 consultar titulos agendados através do arquivo de pagamento
                              - 212 cancelar agendamento de pagamento feito por arquivo de pagamento
                              - 213 relatório de titulos agendados através do arquivo de pagamento
                            (Douglas - Melhoria 271.3)

				 25/08/2017 - Adiçao das operaçoes relacionadas ao envio de Notificaçoes
                              (Operaçoes 206,207,208,209,214) - (Pablao)

				 06/09/2017 - Alterações na chamada de pagamento GPS.
							  (P.356.2 - Ricardo Linhares)
							  
                 13/10/2017 - Criação da variável aux_cdcanal - (Pablao)
                              
                 25/10/2017 -  Ajustes diversos para projeto de DDA Mobile
                               PRJ356.4 - DDA (Ricardo Linhares)

                 21/08/2017 - Inclusao dos campos qtdiacal e vlrdtaxa na
                              proc_operacao14. (Jaison/James - PRJ298)

                 06/10/2017 - Incluir operacao 182 (David).
                 
                 09/10/2017 - Ajustes de retorno na operacao 31 (David)

------------------------------------------------------------------------------*/

/*----------------------------------------------------------------*/
/*           This .W file was created with AppBuilder.                  */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Preprocessor Definitions ---                                         */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR h-b1wgencrypt AS HANDLE                                        NO-UNDO.

DEF VAR aux_nrctatrf LIKE crapcti.nrctatrf                             NO-UNDO.
DEF VAR aux_cdagectl AS   INTE                                         NO-UNDO.         

DEF VAR aux_cddsenha AS CHAR                                           NO-UNDO.
DEF VAR aux_cdsennew AS CHAR                                           NO-UNDO.
DEF VAR aux_cdsenrep AS CHAR                                           NO-UNDO.
DEF VAR aux_dssenweb AS CHAR                                           NO-UNDO.
DEF VAR aux_dssennew AS CHAR                                           NO-UNDO.
DEF VAR aux_dssenrep AS CHAR                                           NO-UNDO.
DEF VAR aux_dssenlet AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdsacad AS CHAR                                           NO-UNDO.
DEF VAR aux_dsendsac AS CHAR                                           NO-UNDO.
DEF VAR aux_nmbaisac AS CHAR                                           NO-UNDO.
DEF VAR aux_nmcidsac AS CHAR                                           NO-UNDO.
DEF VAR aux_cdufsaca AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdavali AS CHAR                                           NO-UNDO.
DEF VAR aux_nrinssac AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdinstr AS CHAR                                           NO-UNDO.
DEF VAR aux_complend AS CHAR                                           NO-UNDO.
DEF VAR aux_dsmsgerr AS CHAR                                           NO-UNDO.
DEF VAR aux_tgfimprg AS CHAR                                           NO-UNDO.
DEF VAR aux_cdbarras AS CHAR                                           NO-UNDO.
DEF VAR aux_sftcdbar AS CHAR                                           NO-UNDO.
DEF VAR aux_qtcheque AS CHAR                                           NO-UNDO.
DEF VAR aux_qtcordem AS CHAR                                           NO-UNDO.
DEF VAR aux_dscedent AS CHAR                                           NO-UNDO.
DEF VAR aux_cdctrlcs AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdoccop AS CHAR                                           NO-UNDO.
DEF VAR aux_dsurlace AS CHAR                                           NO-UNDO.
DEF VAR aux_desdacao AS CHAR                                           NO-UNDO.
DEF VAR aux_nmoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdemail AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdcargo AS CHAR                                           NO-UNDO.
DEF VAR aux_cdditens AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS CHAR                                           NO-UNDO.
DEF VAR aux_dsitmexc AS CHAR                                           NO-UNDO.
DEF VAR aux_dsendere AS CHAR                                           NO-UNDO.
DEF VAR aux_nmbairro AS CHAR                                           NO-UNDO.
DEF VAR aux_nmcidade AS CHAR                                           NO-UNDO.
DEF VAR aux_cdufende AS CHAR                                           NO-UNDO.
DEF VAR aux_tpdodado AS CHAR                                           NO-UNDO.
DEF VAR aux_lsdfrenv AS CHAR                                           NO-UNDO.
DEF VAR aux_lsperiod AS CHAR                                           NO-UNDO.
DEF VAR aux_lsseqinc AS CHAR                                           NO-UNDO.
DEF VAR aux_dsinform AS CHAR                                           NO-UNDO.
DEF VAR aux_dtinicio AS CHAR                                           NO-UNDO.
DEF VAR aux_lsdatagd AS CHAR                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nripuser AS CHAR                                           NO-UNDO.
DEF VAR aux_dsinserr AS CHAR                                           NO-UNDO.
DEF VAR aux_cddbloco AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigip AS CHAR                                           NO-UNDO.
DEF VAR aux_nmtitula AS CHAR                                           NO-UNDO.
DEF VAR aux_nmtitpes AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransf AS CHAR                                           NO-UNDO.
DEF VAR aux_dshistor AS CHAR                                           NO-UNDO.
DEF VAR aux_detdocto AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdocmto AS CHAR                                           NO-UNDO.
DEF VAR aux_lisrowid AS CHAR                                           NO-UNDO.
DEF VAR aux_idleitur AS INTE                                           NO-UNDO.
DEF VAR aux_dsarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdireto AS CHAR                                           NO-UNDO.
DEF VAR aux_xmldados AS CHAR                                           NO-UNDO.
DEF VAR aux_dssessao AS CHAR                                           NO-UNDO.
DEF VAR aux_dspdfrel AS LONGCHAR                                       NO-UNDO.
DEF VAR aux_dtcompet AS CHAR                                           NO-UNDO.
DEF VAR aux_dtcmptde AS CHAR                                           NO-UNDO.
DEF VAR aux_dtcmpate AS CHAR                                           NO-UNDO.
DEF VAR aux_dsidenti AS CHAR                                           NO-UNDO.
DEF VAR aux_dtvencim AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdatdeb AS CHAR                                           NO-UNDO.           
DEF VAR aux_cdoperadora AS INT                                         NO-UNDO. 
DEF VAR aux_cdproduto   AS INT                                         NO-UNDO.
DEF VAR aux_nrddd       AS INT                                         NO-UNDO.
DEF VAR aux_nrcelular   AS INT                                         NO-UNDO.
DEF VAR aux_nmcontato   AS CHAR                                        NO-UNDO.
DEF VAR aux_flgfavori   AS INT                                         NO-UNDO.
DEF VAR aux_vlrecarga   AS DECI                                        NO-UNDO.
DEF VAR aux_cdopcaodt   AS INT                                         NO-UNDO.
DEF VAR aux_dtrecarga   AS DATE                                        NO-UNDO.

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_inproces AS INTE                                           NO-UNDO.
DEF VAR aux_cdhistor AS INTE                                           NO-UNDO.
DEF VAR aux_idmotivo AS INTE                                           NO-UNDO.
DEF VAR aux_operacao AS INTE                                           NO-UNDO.
DEF VAR aux_nrctremp AS INTE                                           NO-UNDO.
DEF VAR aux_nrctasac AS INTE                                           NO-UNDO.
DEF VAR aux_nraplica AS INTE                                           NO-UNDO.
DEF VAR aux_nrctrrpp AS INTE                                           NO-UNDO.
DEF VAR aux_nrcepsac AS INTE                                           NO-UNDO.
DEF VAR aux_cdtpinsc AS INTE                                           NO-UNDO.
DEF VAR aux_cdtpinav AS INTE                                           NO-UNDO.
DEF VAR aux_nrcnvcob AS INTE                                           NO-UNDO.
DEF VAR aux_nrconven AS INTE                                           NO-UNDO.
DEF VAR aux_intipmvt AS INTE                                           NO-UNDO.
DEF VAR aux_nrseqarq AS INTE                                           NO-UNDO.
DEF VAR aux_dscheque AS CHAR                                           NO-UNDO.
DEF VAR aux_dtlibchq AS CHAR                                           NO-UNDO.
DEF VAR aux_dtcapchq AS CHAR                                           NO-UNDO.
DEF VAR aux_vlcheque AS CHAR                                           NO-UNDO.
DEF VAR aux_dtcustod AS CHAR                                           NO-UNDO.
DEF VAR aux_intipchq AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdocmc7 AS CHAR                                           NO-UNDO.
DEF VAR aux_nrremess AS CHAR                                           NO-UNDO.
DEF VAR aux_dsemiten AS CHAR                                           NO-UNDO.
DEF VAR aux_indordem AS INTE                                           NO-UNDO.
DEF VAR aux_indlogin AS INTE                                           NO-UNDO.
DEF VAR aux_idrotina AS INTE                                           NO-UNDO.
DEF VAR aux_qttitulo AS INTE                                           NO-UNDO.
DEF VAR aux_cdmensag AS INTE                                           NO-UNDO.
DEF VAR aux_nrendsac AS INTE                                           NO-UNDO.
DEF VAR aux_intipapl AS INTE                                           NO-UNDO.
DEF VAR aux_vldfrase AS INTE                                           NO-UNDO.
DEF VAR aux_inaceblq AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_nrdigfat AS INTE                                           NO-UNDO.
DEF VAR aux_nrctacob AS INTE                                           NO-UNDO.
DEF VAR aux_insittit AS INTE                                           NO-UNDO.
DEF VAR aux_intitcop AS INTE                                           NO-UNDO.
DEF VAR aux_nrdctabb AS INTE                                           NO-UNDO.
DEF VAR aux_qtpremax AS INTE                                           NO-UNDO.
DEF VAR aux_flcadast AS INTE                                           NO-UNDO.
DEF VAR aux_idagenda AS INTE                                           NO-UNDO.
DEF VAR aux_insitlau AS INTE                                           NO-UNDO.
DEF VAR aux_nrdocmto AS INTE                                           NO-UNDO.
DEF VAR aux_idtpdpag AS INTE                                           NO-UNDO.
DEF VAR aux_idsituac AS INTE                                           NO-UNDO.
DEF VAR aux_indtrans AS INTE                                           NO-UNDO.
DEF VAR aux_nrendere AS INTE                                           NO-UNDO.
DEF VAR aux_nrcepend AS INTE                                           NO-UNDO.
DEF VAR aux_nrcxapst AS INTE                                           NO-UNDO.
DEF VAR aux_cdseqinc AS INTE                                           NO-UNDO.
DEF VAR aux_tpendass AS INTE                                           NO-UNDO.
DEF VAR aux_cdseqtfc AS INTE                                           NO-UNDO.
DEF VAR aux_tptelefo AS INTE                                           NO-UNDO.
DEF VAR aux_nrdddtfc AS INTE                                           NO-UNDO.
DEF VAR aux_cdopetfn AS INTE                                           NO-UNDO.
DEF VAR aux_cdperiod AS INTE                                           NO-UNDO.
DEF VAR aux_cdgrprel AS INTE                                           NO-UNDO.
DEF VAR aux_cdprogra AS INTE                                           NO-UNDO.
DEF VAR aux_cdrelato AS INTE                                           NO-UNDO.
DEF VAR aux_cddfrenv AS INTE                                           NO-UNDO.
DEF VAR aux_anorefer AS INTE                                           NO-UNDO.
DEF VAR aux_tpinform AS INTE                                           NO-UNDO.
DEF VAR aux_nrperiod AS INTE                                           NO-UNDO.
DEF VAR aux_cdsitsac AS INTE                                           NO-UNDO.
DEF VAR aux_cddespec AS INTE                                           NO-UNDO.
DEF VAR aux_cdtpvcto AS INTE                                           NO-UNDO.
DEF VAR aux_qtdiavct AS INTE                                           NO-UNDO.
DEF VAR aux_vldsacad AS INTE                                           NO-UNDO.
DEF VAR aux_idrelato AS INTE                                           NO-UNDO.
DEF VAR aux_cdcartei AS INTE                                           NO-UNDO.
DEF VAR aux_intipcta AS INTE                                           NO-UNDO.
DEF VAR aux_ddagenda AS INTE                                           NO-UNDO.
DEF VAR aux_qtmesagd AS INTE                                           NO-UNDO.
DEF VAR aux_cdtiptra AS INTE                                           NO-UNDO.
DEF VAR aux_idconchq AS INTE                                           NO-UNDO.
DEF VAR aux_inirgext AS INTE                                           NO-UNDO.
DEF VAR aux_inirgchq AS INTE                                           NO-UNDO.
DEF VAR aux_inirgdep AS INTE                                           NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.
DEF VAR aux_nritmini AS INTE                                           NO-UNDO.
DEF VAR aux_nritmfin AS INTE                                           NO-UNDO.
DEF VAR aux_idordena AS INTE                                           NO-UNDO.
DEF VAR aux_cdocorre AS INTE                                           NO-UNDO.
DEF VAR aux_nrdoapto AS INTE                                           NO-UNDO.
DEF VAR aux_insittra AS INTE                                           NO-UNDO.
DEF VAR aux_nrdmensg AS INTE                                           NO-UNDO.
DEF VAR aux_iddopcao AS INTE                                           NO-UNDO.
DEF VAR aux_iddmensg AS INTE                                           NO-UNDO.
DEF VAR aux_indvalid AS INTE                                           NO-UNDO.
DEF VAR aux_cddbanco AS INTE                                           NO-UNDO.
DEF VAR aux_cdageban AS INTE                                           NO-UNDO.
DEF VAR aux_intipdif AS INTE                                           NO-UNDO.
DEF VAR aux_insitcta AS INTE                                           NO-UNDO.
DEF VAR aux_tpoperac AS INTE                                           NO-UNDO.
DEF VAR aux_cdfinali AS INTE                                           NO-UNDO.
DEF VAR aux_tppeslst AS INTE                                           NO-UNDO.
DEF VAR aux_tpinstru AS INTE                                           NO-UNDO.
DEF VAR aux_cdtippro AS INTE                                           NO-UNDO.
DEF VAR aux_cdbandoc AS INTE                                           NO-UNDO.
DEF VAR aux_cdtiplog AS INTE                                           NO-UNDO.
DEF VAR aux_tpemitir AS INTE                                           NO-UNDO.
DEF VAR aux_nrdiavct AS INTE                                           NO-UNDO.
DEF VAR aux_flsolest AS INTE                                           NO-UNDO.
DEF VAR aux_idopdebi AS INTE                                           NO-UNDO.
DEF VAR aux_flgravar AS INTE                                           NO-UNDO.
DEF VAR aux_idvalida AS INTE                                           NO-UNDO.
DEF VAR aux_tpdpagto AS INTE                                           NO-UNDO.
DEF VAR aux_cdpagmto AS INTE                                           NO-UNDO.
DEF VAR aux_idfisjur AS INTE                                           NO-UNDO.
DEF VAR aux_gravafav AS INTE										   NO-UNDO.
DEF VAR aux_tpdaguia AS INTE										   NO-UNDO.
DEF VAR aux_iddspscp AS INTE                                           NO-UNDO.

DEF VAR aux_dsretorn AS CHAR                                           NO-UNDO.
DEF VAR aux_dtdiadeb AS CHAR                                           NO-UNDO.
DEF VAR aux_tpvalida AS CHAR                                           NO-UNDO.
DEF VAR aux_dstpcons AS CHAR                                           NO-UNDO.
DEF VAR aux_dsprotoc AS CHAR                                           NO-UNDO.
DEF VAR aux_idtipapl AS CHAR                                           NO-UNDO.

DEF VAR aux_nrcpfapr AS DECI                                           NO-UNDO.
DEF VAR aux_vltitulo AS DECI                                           NO-UNDO.
DEF VAR aux_nrinsava AS DECI                                           NO-UNDO.
DEF VAR aux_nrcpfcgc AS DECI                                           NO-UNDO.
DEF VAR aux_nrcpfdrf AS CHAR                                           NO-UNDO.
DEF VAR str_nrcpfope AS CHAR                                           NO-UNDO.
DEF VAR aux_vldescto AS DECI                                           NO-UNDO.
DEF VAR aux_inidocto AS DECI                                           NO-UNDO.
DEF VAR aux_fimdocto AS DECI                                           NO-UNDO.
DEF VAR aux_vllanmto AS DECI                                           NO-UNDO.
DEF VAR aux_lindigi1 AS DECI                                           NO-UNDO.
DEF VAR aux_lindigi2 AS DECI                                           NO-UNDO.
DEF VAR aux_lindigi3 AS DECI                                           NO-UNDO.
DEF VAR aux_lindigi4 AS DECI                                           NO-UNDO.
DEF VAR aux_lindigi5 AS DECI                                           NO-UNDO.
DEF VAR aux_vlpagame AS DECI                                           NO-UNDO.
DEF VAR aux_cdseqfat AS DECI                                           NO-UNDO.
DEF VAR aux_nrboleto AS DECI                                           NO-UNDO.
DEF VAR aux_vlprepla AS DECI                                           NO-UNDO.
DEF VAR aux_nrtelefo AS DECI                                           NO-UNDO.
DEF VAR aux_vlabatim AS DECI                                           NO-UNDO.
DEF VAR aux_idtitdda AS DECI                                           NO-UNDO.
DEF VAR aux_nrcelsac AS DECI                                           NO-UNDO.
DEF VAR aux_vltarapr AS DECI                                           NO-UNDO.
DEF VAR aux_vldoinss AS DECI                                           NO-UNDO.
DEF VAR aux_vloutent AS DECI                                           NO-UNDO.
DEF VAR aux_vlatmjur AS DECI                                           NO-UNDO.
DEF VAR aux_vlrtotal AS DECI                                           NO-UNDO.
DEF VAR aux_txmensal AS DECI                                           NO-UNDO.
DEF VAR aux_vlrtarif AS DECI                                           NO-UNDO.
DEF VAR aux_vltaxiof AS DECI                                           NO-UNDO.
DEF VAR aux_vltariof AS DECI                                           NO-UNDO.
DEF VAR aux_vllbolet LIKE crapopi.vllbolet                             NO-UNDO.
DEF VAR aux_vllimtrf LIKE crapopi.vllimtrf                             NO-UNDO.
DEF VAR aux_vllimted LIKE crapopi.vllimted                             NO-UNDO.
DEF VAR aux_vllimvrb LIKE crapopi.vllimvrb                             NO-UNDO.
DEF VAR aux_vllimflp LIKE crapopi.vllimflp                             NO-UNDO.
DEF VAR aux_nrcpfpre LIKE crapopi.nrcpfope                             NO-UNDO.
DEF VAR aux_geraflux AS INTE										   NO-UNDO.

DEF VAR aux_dtmvtolt AS DATE                                           NO-UNDO.
DEF VAR aux_dtmvtopr AS DATE                                           NO-UNDO.
DEF VAR aux_dtmvtocd AS DATE                                           NO-UNDO.
DEF VAR aux_dtmvtoan AS DATE                                           NO-UNDO.
DEF VAR aux_dtvencto AS DATE                                           NO-UNDO.
DEF VAR aux_inivecto AS DATE                                           NO-UNDO.
DEF VAR aux_fimvecto AS DATE                                           NO-UNDO.
DEF VAR aux_inipagto AS DATE                                           NO-UNDO.
DEF VAR aux_fimpagto AS DATE                                           NO-UNDO.
DEF VAR aux_iniemiss AS DATE                                           NO-UNDO.
DEF VAR aux_fimemiss AS DATE                                           NO-UNDO.
DEF VAR aux_dtdpagto AS DATE                                           NO-UNDO.
DEF VAR aux_dtiniper AS DATE                                           NO-UNDO.
DEF VAR aux_dtfimper AS DATE                                           NO-UNDO.
DEF VAR aux_nrctrlim AS INT                                            NO-UNDO.
DEF VAR aux_insithcc AS INT                                            NO-UNDO.
DEF VAR aux_insitbdc AS INT                                            NO-UNDO.
DEF VAR aux_dtmvtopg AS DATE                                           NO-UNDO.
DEF VAR aux_dtmvtage AS DATE                                           NO-UNDO.
DEF VAR aux_dtdocmto AS DATE                                           NO-UNDO.
DEF VAR aux_dtlibera AS DATE                                           NO-UNDO.
DEF VAR aux_dtcredit AS DATE                                           NO-UNDO.
DEF VAR aux_dtdebito AS DATE                                           NO-UNDO.


DEF VAR aux_flgpagto AS LOGI                                           NO-UNDO.
DEF VAR aux_flgexecu AS LOGI                                           NO-UNDO.
DEF VAR aux_flgsitop AS LOGI                                           NO-UNDO.
DEF VAR aux_flgtpenc AS LOGI                                           NO-UNDO.
DEF VAR aux_flgvalid AS LOGI                                           NO-UNDO.
DEF VAR aux_flglsext AS LOGI                                           NO-UNDO.
DEF VAR aux_flglschq AS LOGI                                           NO-UNDO.
DEF VAR aux_flglsdep AS LOGI                                           NO-UNDO.
DEF VAR aux_flglsfut AS LOGI                                           NO-UNDO.
DEF VAR aux_flgerlog AS LOGI                                           NO-UNDO.
DEF VAR aux_flvalarq AS LOGI                                           NO-UNDO.
DEF VAR aux_flgpesqu AS LOGI                                           NO-UNDO.
DEF VAR aux_vldshlet AS LOGI                                           NO-UNDO.
DEF VAR aux_flgcript AS LOGI                                           NO-UNDO.
DEF VAR aux_flmobile AS LOGI                                           NO-UNDO.
DEF VAR aux_cdcanal  AS INTE                                           NO-UNDO.
DEF VAR aux_tpcptdoc AS INTE                                           NO-UNDO.

/** Parametros de Cobranca Registrada **/
DEF VAR aux_flgdprot AS LOGI                                           NO-UNDO.
DEF VAR aux_qtdiaprt AS INTE                                           NO-UNDO.
DEF VAR aux_indiaprt AS INTE                                           NO-UNDO.
DEF VAR aux_inemiten AS INTE                                           NO-UNDO.
DEF VAR aux_vlrmulta AS DECI                                           NO-UNDO.
DEF VAR aux_vljurdia AS DECI                                           NO-UNDO.
DEF VAR aux_flgaceit AS LOGI                                           NO-UNDO.
DEF VAR aux_flgregis AS INTE                                           NO-UNDO.
DEF VAR aux_tpjurmor AS INTE                                           NO-UNDO.
DEF VAR aux_tpdmulta AS INTE                                           NO-UNDO.

DEF VAR aux_nrcpfope LIKE crapopi.nrcpfope                             NO-UNDO.
DEF VAR aux_cpfopelg LIKE crapopi.nrcpfope                             NO-UNDO.
DEF VAR aux_nmrescop LIKE crapcop.nmrescop                             NO-UNDO.

DEF VAR aux_cdtransa LIKE tbgen_trans_pend.cdtransacao_pendente        NO-UNDO.
DEF VAR aux_cdsitaar LIKE crapaar.cdsitaar                             NO-UNDO.

DEF VAR aux_nrcrcard AS DECI                                           NO-UNDO.
DEF VAR aux_dtvctini AS DATE                                           NO-UNDO.
DEF VAR aux_dtvctfim AS DATE                                           NO-UNDO.

DEF VAR aux_vlapagar AS DECI                                           NO-UNDO.
DEF VAR aux_versaldo AS INTE                                           NO-UNDO.

DEF VAR aux_dtrefini AS DATE                                           NO-UNDO.
DEF VAR aux_dtreffim AS DATE                                           NO-UNDO.
DEF VAR aux_tprelato AS INTE                                           NO-UNDO.

DEF VAR aux_cdtipcor AS INTE                                           NO-UNDO.
DEF VAR aux_vlcorfix AS DECI                                           NO-UNDO.
DEF VAR aux_flcancel AS LOGI                                           NO-UNDO.

DEF VAR aux_vlaplica LIKE craprda.vlaplica                             NO-UNDO.
DEF VAR aux_tpaplica LIKE craprda.tpaplica                             NO-UNDO.
DEF VAR aux_vllimcre LIKE crapass.vllimcre                             NO-UNDO.
DEF VAR aux_qtdiaapl AS INT                                            NO-UNDO.
DEF VAR aux_dtresgat AS DATE                                           NO-UNDO.
DEF VAR aux_qtdiacar AS INT                                            NO-UNDO.
DEF VAR aux_qtdiaven AS INTE                                           NO-UNDO.
DEF VAR aux_cdperapl AS INT                                            NO-UNDO.
DEF VAR aux_nrdocpro AS CHAR                                           NO-UNDO.
DEF VAR aux_idcontrato AS INT                                          NO-UNDO.
DEF VAR aux_idpacote AS INT                                            NO-UNDO.
DEF VAR aux_tpnommis AS INT                                            NO-UNDO.
DEF VAR aux_nmemisms AS CHAR                                           NO-UNDO.

/*parametros agendamento de aplicacao resgate*/
DEF VAR aux_flgtipar AS INTE                                           NO-UNDO.
DEF VAR aux_flgtipin AS INTE                                           NO-UNDO.
DEF VAR aux_nrctraar AS INTE                                           NO-UNDO.
DEF VAR aux_dtiniage AS DATE                                           NO-UNDO.
DEF VAR aux_dtfimage AS DATE                                           NO-UNDO.
DEF VAR aux_vlparaar AS DECI                                           NO-UNDO.
DEF VAR aux_qtmesaar AS INTE                                           NO-UNDO.
DEF VAR aux_dtiniaar AS DATE                                           NO-UNDO.
DEF VAR aux_dtdiaaar AS INTE                                           NO-UNDO.
DEF VAR aux_detagend AS CHAR                                           NO-UNDO.
DEF VAR aux_flgacsms AS CHAR                                           NO-UNDO.

/*parametros agendamento busca qtd dias carencia*/
DEF VAR aux_flavalid AS INTE                                           NO-UNDO.
DEF VAR aux_flaerlog AS INTE                                           NO-UNDO.

/*parametros credito pre-aprovado*/
DEF VAR aux_vllimdis AS DECI                                           NO-UNDO.
DEF VAR aux_vlemprst LIKE crapepr.vlemprst                             NO-UNDO.
DEF VAR aux_percetop AS DECI                                           NO-UNDO.
DEF VAR aux_qtpreemp LIKE crapepr.qtpreemp                             NO-UNDO.
DEF VAR aux_vlpreemp LIKE crapepr.vlpreemp                             NO-UNDO.
DEF VAR aux_diapagto AS INTE                                           NO-UNDO.
DEF VAR aux_flgprevi AS LOG                                            NO-UNDO.
DEF VAR aux_vlparepr AS DECI                                           NO-UNDO.
DEF VAR aux_nrparepr AS INTE                                           NO-UNDO.

/* parametros para o resumo do resgate
   As aplicações e o valor são passados separados por ";" */
DEF VAR aux_dsaplica AS CHAR                                           NO-UNDO.
DEF VAR aux_vlresgat AS CHAR                                           NO-UNDO.
/* Dados do boleto separados por "|" e os boletos por ";" */
DEF VAR aux_dsboleto AS CHAR                                           NO-UNDO.
DEF VAR aux_tpdaacao AS INTE                                           NO-UNDO.
DEF VAR aux_flgpgtib AS INTE                                           NO-UNDO.

DEF VAR aux_cdsegmto AS INTE                                           NO-UNDO.
DEF VAR aux_cdempcon AS INTE                                           NO-UNDO.
DEF VAR aux_idconsum AS DECI                                           NO-UNDO.
DEF VAR aux_flglimit AS LOGI                                           NO-UNDO.
DEF VAR aux_vlmaxdeb AS DECI                                           NO-UNDO.
DEF VAR aux_dshisext AS CHAR                                           NO-UNDO.
DEF VAR aux_cdhisdeb AS INTE                                           NO-UNDO.
DEF VAR aux_dtinisus AS DATE                                           NO-UNDO.
DEF VAR aux_nrborder AS INTE                                           NO-UNDO.
DEF VAR aux_dtfimsus AS DATE                                           NO-UNDO.

DEF VAR aux_dtiniitr AS DATE                                           NO-UNDO.
DEF VAR aux_dtfinitr AS DATE                                           NO-UNDO.
    
/** PArametros para Pagamento Titulo Lote */
DEF VAR aux_nrcnvpag AS INTE                                           NO-UNDO.
DEF VAR aux_cdarqvid AS CHAR                                           NO-UNDO.
DEF VAR xml_operacao AS CHAR   /** Vem do Oracle **/                   NO-UNDO.
DEF VAR aux_nrremret AS INT                                            NO-UNDO.
DEF VAR aux_tpdtermo AS INT                                            NO-UNDO.
DEF VAR aux_confirma AS INT                                            NO-UNDO.
DEF VAR aux_flmensag AS INT                                            NO-UNDO.

DEF VAR aux_msgofatr AS CHAR                                           NO-UNDO.
DEF VAR xml_cdempcon AS CHAR                                           NO-UNDO.
DEF VAR xml_cdsegmto AS CHAR                                           NO-UNDO.
DEF VAR xml_dsprotoc AS CHAR                                           NO-UNDO.

/*Parametros para a operacao 142 */

DEF VAR aux_nrdctemp AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcpfemp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_dtadmiss AS CHAR                                           NO-UNDO.
DEF VAR aux_dstelefo AS CHAR                                           NO-UNDO.
DEF VAR aux_nrregger AS CHAR                                           NO-UNDO.
DEF VAR aux_nrodopis AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdactps AS CHAR                                           NO-UNDO.
DEF VAR aux_altera   AS CHAR                                           NO-UNDO.
DEF VAR aux_idtpcont AS CHAR                                           NO-UNDO.

DEF VAR aux_cdempres AS INT                                            NO-UNDO.
DEF VAR aux_nrseqpag AS INT                                            NO-UNDO.
DEF VAR aux_dtrefere AS CHAR                                           NO-UNDO.
DEF VAR aux_idtipfol AS INT                                            NO-UNDO.

/* Parametro para procedure de Favorecidos a TED */
DEF VAR aux_rowidcti AS CHAR                                           NO-UNDO.
DEF VAR aux_flexclui AS CHAR                                           NO-UNDO.
DEF VAR aux_cdispbif AS INT                                            NO-UNDO. 

/* Parametros para o tratamento de mensagens do IBank */
DEF VAR aux_rowidmsg AS CHAR                                           NO-UNDO.
DEF VAR aux_tipoacao AS CHAR                                           NO-UNDO.

/* Parametros para o tratamento de Inscricao no EAD */
DEF VAR aux_cdcadead AS INT                                            NO-UNDO.
DEF VAR aux_invclopj AS INT                                            NO-UNDO.
DEF VAR aux_nmextptp AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcpfptp AS DECI                                           NO-UNDO.
DEF VAR aux_dsemlptp AS CHAR                                           NO-UNDO.
DEF VAR aux_nrfonptp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmlogptp AS CHAR                                           NO-UNDO.


DEF VAR aux_ordempgo AS CHAR                                           NO-UNDO.
DEF VAR aux_qtdprepr AS INT                                            NO-UNDO.
DEF VAR aux_listapar AS CHAR                                           NO-UNDO.
DEF VAR aux_tipopgto AS INT                                            NO-UNDO.
DEF VAR aux_dtexerci AS CHAR                                           NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                           NO-UNDO.

DEF VAR aux_inserasa AS INT                                            NO-UNDO. 
DEF VAR aux_instatussms  AS INT                                        NO-UNDO. 

DEF VAR aux_flserasa AS LOG                                            NO-UNDO.
DEF VAR aux_qtdianeg AS INT                                            NO-UNDO.

DEF VAR aux_inenvcip AS INT                                            NO-UNDO.

/* Aviso SMS */
DEF VAR aux_inavisms AS INT                                            NO-UNDO.
DEF VAR aux_insmsant AS INT                                            NO-UNDO.
DEF VAR aux_insmsvct AS INT                                            NO-UNDO.
DEF VAR aux_insmspos AS INT                                            NO-UNDO.

/* NPC */
DEF VAR aux_flgregon AS INT                                            NO-UNDO.
DEF VAR aux_inpagdiv AS INT                                            NO-UNDO.
DEF VAR aux_vlminimo AS DECI                                           NO-UNDO.


DEF VAR aux_idapurac AS INTE                                           NO-UNDO.

/* Operacao 160/161 */
DEF VAR aux_nrrecben AS DECI                                           NO-UNDO.
DEF VAR aux_dtmescom AS CHAR                                           NO-UNDO.
/* variaveis InternetBank164 */
DEF VAR aux_recidepr AS INT                                            NO-UNDO.
DEF VAR aux_dtcalcul AS DATE                                           NO-UNDO.
DEF VAR aux_flgentra AS LOGI                                           NO-UNDO.
DEF VAR aux_flgentrv AS LOGI                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO. 
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.

/* Operacao 165/167/170/172 */
DEF VAR aux_nrctapac AS INTE                                           NO-UNDO.
DEF VAR aux_cdpacote AS INTE										   NO-UNDO.
DEF VAR aux_dspacote AS CHAR										   NO-UNDO.
DEF VAR aux_diadebit AS INTE										   NO-UNDO.
DEF VAR aux_dtinivig AS CHAR										   NO-UNDO.
DEF VAR aux_vlpcttar AS CHAR                                           NO-UNDO.
DEF VAR aux_vlpacote AS DECI                                           NO-UNDO.
DEF VAR aux_inconsul AS INTE										   NO-UNDO.

/* Operacoes DARF */
DEF VAR aux_dtapurac AS DATE                                           NO-UNDO.
DEF VAR aux_cdtribut AS CHAR                                           NO-UNDO.
DEF VAR aux_idefetiv AS INTE                                           NO-UNDO.
DEF VAR aux_vlrecbru AS DECI                                           NO-UNDO.
DEF VAR aux_vlpercen AS DECI                                           NO-UNDO.
DEF VAR aux_vlprinci AS DECI                                           NO-UNDO.
DEF VAR aux_vlrjuros AS DECI                                           NO-UNDO.
DEF VAR aux_dsexthis AS CHAR                                           NO-UNDO.
DEF VAR aux_dtapagar AS DATE                                           NO-UNDO.
DEF VAR aux_dsnomfon AS CHAR                                           NO-UNDO.
DEF VAR aux_tpcaptur AS INTE                                           NO-UNDO.
DEF VAR aux_tpleitor AS INTE                                           NO-UNDO.
DEF VAR aux_nrrefere AS DECI                                           NO-UNDO.
DEF VAR aux_idrazfan AS INTE										   NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE										   NO-UNDO.
DEF VAR aux_titulo1  AS DECI										   NO-UNDO.
DEF VAR aux_titulo2  AS DECI										   NO-UNDO.
DEF VAR aux_titulo3  AS DECI								           NO-UNDO.
DEF VAR aux_titulo4  AS DECI								 		   NO-UNDO.
DEF VAR aux_titulo5  AS DECI				 						   NO-UNDO.
DEF VAR aux_codigo_barras AS CHAR      								   NO-UNDO.
DEF VAR aux_tppacote AS INTE                                            NO-UNDO.

/* Operacao 62 */
DEF VAR aux_dssittit AS CHAR NO-UNDO.
DEF VAR aux_cdsittit AS INTE NO-UNDO.

/* Operacoes de Notificacoes */
DEF VAR aux_cdnotificacao AS INT64                                     NO-UNDO.
DEF VAR aux_pesquisa      AS CHAR                                      NO-UNDO.
DEF VAR aux_reginicial    AS INTE                                      NO-UNDO.
DEF VAR aux_qtdregistros  AS INTE                                      NO-UNDO.
DEF VAR aux_dispositivomobileid AS CHAR                                NO-UNDO.
DEF VAR aux_recbpush      AS INTE                                      NO-UNDO.
DEF VAR aux_chavedsp      AS CHAR                                      NO-UNDO.
DEF VAR aux_lstconfg      AS CHAR                                      NO-UNDO.

/*  Operacao 176/177 */
DEF VAR aux_vintegra AS DECIMAL										   NO-UNDO.

/* Operacao 153 */
DEF VAR aux_indtpaga AS INTE NO-UNDO.
DEF VAR aux_vlrlote AS DECI NO-UNDO.			

/* Operacao 205 */
DEF VAR aux_cdoperad AS CHAR                         NO-UNDO.
DEF VAR aux_dsmsglog AS CHAR                         NO-UNDO.
DEF VAR aux_cdprograma AS CHAR                       NO-UNDO.

/* Operacao 210 */
DEF VAR aux_dtinilog AS DATE                         NO-UNDO.
DEF VAR aux_dtfimlog AS DATE                         NO-UNDO.

/* Operacao 211 */ 
DEF VAR aux_idstatus AS INT                          NO-UNDO.
DEF VAR aux_tpdata   AS INT                          NO-UNDO.
DEF VAR aux_nmbenefi AS CHAR                         NO-UNDO.

/* Operacao 212 */
DEF VAR aux_dsagdcan AS LONGCHAR                     NO-UNDO.						   

/* Operacao 193 */
/* Operacao 194 */
/* Operacao 195 */
/* Operacao 196 */
/* Operacao 197 */
DEF VAR aux_cdorigem AS INTE               NO-UNDO.
DEF VAR aux_cdtipmod AS INTE               NO-UNDO.
DEF VAR aux_dsorigem AS CHAR               NO-UNDO.
DEF VAR aux_dttransa AS DATE               NO-UNDO.
DEF VAR aux_idlancto LIKE craplau.idlancto NO-UNDO.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE InternetBank.html

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 60.6 BY 14.14.

/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Web-Object
   Allow: Query
   Frames: 1
   Add Fields to: Neither
   Editing: Special-Events-Only
   Events: web.output,web.input
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 14.14
         WIDTH              = 60.6.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB w-html 
/* *********************** Included-Libraries ************************* */

{src/web2/html-map.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w-html
  VISIBLE,,RUN-PERSISTENT                                               */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-html 


/* ************************  Main Code Block  ************************* */

/* Standard Main Block that runs adm-create-objects, initializeObject 
 * and process-web-request.
 * The bulk of the web processing is in the Procedure process-web-request
 * elsewhere in this Web object.
 */
{src/web2/template/hmapmain.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects w-html  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE htmOffsets w-html  _WEB-HTM-OFFSETS
PROCEDURE htmOffsets :
/*------------------------------------------------------------------------------
  Purpose:     Runs procedure to associate each HTML field with its
               corresponding widget name and handle.
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/
  RUN readOffsets ("{&WEB-FILE}":U).
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE outputHeader w-html 
PROCEDURE outputHeader :
/*------------------------------------------------------------------------
  Purpose:     Output the MIME header, and any "cookie" information needed 
               by this procedure.  
  Parameters:  <none>
  Notes:       In the event that this Web object is state-aware, this is 
               a good place to set the WebState and WebTimeout attributes.
------------------------------------------------------------------------*/

  /* To make this a state-aware Web object, pass in the timeout period
   * (in minutes) before running outputContentType.  If you supply a 
   * timeout period greater than 0, the Web object becomes state-aware 
   * and the following happens:
   *
   *   - 4GL variables webState and webTimeout are set
   *   - a cookie is created for the broker to id the client on the return trip
   *   - a cookie is created to id the correct procedure on the return trip
   *
   * If you supply a timeout period less than 1, the following happens:
   *
   *   - 4GL variables webState and webTimeout are set to an empty string
   *   - a cookie is killed for the broker to id the client on the return trip
   *   - a cookie is killed to id the correct procedure on the return trip
   *
   * For example, set the timeout period to 5 minutes.
   *
   *   setWebState (5.0).
   */
    
  /* Output additional cookie information here before running outputContentType.
   *   For more information about the Netscape Cookie Specification, see
   *   http://home.netscape.com/newsref/std/cookie_spec.html  
   *   
   *   Name         - name of the cookie
   *   Value        - value of the cookie
   *   Expires date - Date to expire (optional). See TODAY function.
   *   Expires time - Time to expire (optional). See TIME function.
   *   Path         - Override default URL path (optional)
   *   Domain       - Override default domain (optional)
   *   Secure       - "secure" or unknown (optional)
   * 
   *   The following example sets custNum=23 and expires tomorrow at (about)
   *   the same time but only for secure (https) connections.
   *      
   *   RUN SetCookie IN web-utilities-hdl 
   *     ("custNum":U, "23":U, TODAY + 1, TIME, ?, ?, "secure":U).
   */ 
  output-content-type ("text/html":U).
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE process-web-request w-html 
PROCEDURE process-web-request :
/*------------------------------------------------------------------------
  Purpose:     Process the web request.
  Notes:       
------------------------------------------------------------------------*/
     
  /* STEP 0 -
   * Output the MIME header and set up the object as state-less or state-aware. 
   * This is required if any HTML is to be returned to the browser. 
   *
   * NOTE: Move 'RUN outputHeader.' to the GET section below if you are going
   * to simulate another Web request by running a Web Object from this
   * procedure.  Running outputHeader precludes setting any additional cookie
   * information.   
  RUN outputHeader.
   */ 
  
  /* Describe whether to receive FORM input for all the fields.  For example,
   * check particular input fields (using GetField in web-utilities-hdl). 
   * Here we look at REQUEST_METHOD. 
   */
  IF REQUEST_METHOD = "POST":U THEN DO:
    /* STEP 1 -
     * Copy HTML input field values to the Progress form buffer. */
    RUN inputFields.
    
    /* STEP 2 -
     * Open the database or SDO query and and fetch the first record. */ 
    RUN findRecords.
    
    /* STEP 3 -    
     * AssignFields will save the data in the frame.
     * (it automatically upgrades the lock to exclusive while doing the update)
     * 
     *  If a new record needs to be created set AddMode to true before 
        running assignFields.  
     *     setAddMode(TRUE).   
     * RUN assignFields. */

    /* STEP 4 -
     * Decide what HTML to return to the user. Choose STEP 4.1 to simulate
     * another Web request -OR- STEP 4.2 to return the original form (the
     * default action).
     *
     * STEP 4.1 -
     * To simulate another Web request, change the REQUEST_METHOD to GET
     * and RUN the Web object here.  For example,
     *
     *  ASSIGN REQUEST_METHOD = "GET":U.
     *  RUN run-web-object IN web-utilities-hdl ("myobject.w":U).
     */
     
    /* STEP 4.2 -
     * To return the form again, set data values, display them, and output 
     * them to the WEB stream.  
     *
     * STEP 4.2a -
     * Set any values that need to be set, then display them. */
    RUN displayFields.
   
    /* STEP 4.2b -
     * Enable objects that should be enabled. */
    RUN enableFields.

    /* STEP 4.2c -
     * OUTPUT the Progress form buffer to the WEB stream. */
    RUN outputFields.
    
  END. /* Form has been submitted. */
 
  /* REQUEST-METHOD = GET */ 
  ELSE DO:
       
    /* This is the first time that the form has been called. Just return the
     * form.  Move 'RUN outputHeader.' here if you are going to simulate
     * another Web request. */ 
    RUN outputHeader.
                    
    /* STEP 1 -
     * Open the database or SDO query and and fetch the first record. */ 
    RUN findRecords.
    
    /* Return the form again. Set data values, display them, and output them
     * to the WEB stream.  
     *
     * STEP 2a -
     * Set any values that need to be set, then display them. */

    ASSIGN aux_cdcooper = INTE(GET-VALUE("cdcooper"))
           aux_nrdconta = INTE(GET-VALUE("nrdconta"))
           aux_idseqttl = INTE(GET-VALUE("idseqttl"))
           aux_cddsenha = GET-VALUE("cddsenha")
           aux_dssenweb = GET-VALUE("dssenweb")
           aux_operacao = INTE(GET-VALUE("operacao"))
           aux_nrcpfope = IF  aux_operacao = 43  THEN 
                              0
                          ELSE
                              DECI(GET-VALUE("nrcpfope"))
           aux_nripuser = GET-VALUE("nripuser").

        /** Se parametro flmobile nao foi informado, considerar que a requisicao
        não originou do mobile **/
    IF  GET-VALUE("flmobile") <> "yes"  AND 
        GET-VALUE("flmobile") <> "no"   THEN
        ASSIGN aux_flmobile = NO.
    ELSE
        ASSIGN aux_flmobile = LOGICAL(GET-VALUE("flmobile")).

	/* Obtém o canal a partir do flmobile */
	ASSIGN aux_cdcanal = INTE(STRING(aux_flmobile,"10/3")).

    /** Se parametro flgcript nao foi informado, considerar que a requisicao
        utilizou criptografia nas senhas **/
    IF  GET-VALUE("flgcript") <> "yes"  AND 
        GET-VALUE("flgcript") <> "no"   THEN
        ASSIGN aux_flgcript = YES.
    ELSE
        ASSIGN aux_flgcript = LOGICAL(GET-VALUE("flgcript")).

    MESSAGE "Operacao:" aux_operacao "Coop:" aux_cdcooper 
            "Conta:" aux_nrdconta "Titular:" aux_idseqttl "Cript:" aux_flgcript.

    { sistema/generico/includes/PLSQL_grava_operacao_InternetBank.i 
                                            &dboraayl={&scd_dboraayl} }

    /*** CABECALHO DO XML ***/
    {&out} "<?xml version='1.0' encoding='ISO-8859-1' ?><CECRED>".
    
    ASSIGN aux_dsmsgerr = ""
           aux_tgfimprg = "</CECRED>".
    
    IF  aux_operacao = 122  THEN /* Listagem de cooperativas ativas (Mobile) */
        RUN proc_operacao122.
    ELSE
    IF  aux_operacao = 124  THEN /* Carrega menu de servicos (Mobile) */
        RUN proc_operacao124.
    ELSE
    IF  aux_operacao = 127  THEN /* Verifica o tipo de pessoa (Mobile) */
        RUN proc_operacao127.
    ELSE
    DO:
        FIND FIRST crapdat WHERE crapdat.cdcooper = aux_cdcooper NO-LOCK NO-ERROR.
    
        IF  AVAILABLE crapdat  THEN
            ASSIGN aux_dtmvtolt = crapdat.dtmvtolt
                   aux_dtmvtocd = crapdat.dtmvtocd
                   aux_dtmvtopr = crapdat.dtmvtopr
                   aux_dtmvtoan = crapdat.dtmvtoan
                   aux_inproces = crapdat.inproces.
        ELSE
            DO:
                aux_dsmsgerr = "<dsmsgerr>" + "Sistema sem data de movimento!" + 
                               STRING(aux_cdcooper) + "</dsmsgerr>".
                
                {&out} aux_dsmsgerr aux_tgfimprg.
                
                LEAVE.
            END.
             
        FIND crapcop WHERE crapcop.cdcooper = aux_cdcooper NO-LOCK NO-ERROR.
        
        IF  AVAILABLE crapcop  THEN
            ASSIGN aux_cdcooper = crapcop.cdcooper
                   aux_nmrescop = crapcop.nmrescop.
        ELSE  
            DO:
                aux_dsmsgerr = "<dsmsgerr>" + "Codigo da cooperativa invalido!" + 
                               "</dsmsgerr>".
                
                {&out} aux_dsmsgerr aux_tgfimprg.
                
                LEAVE.
            END.
        
        IF  aux_flgcript  THEN /** Utiliza criptografia **/
            DO:
                RUN sistema/generico/procedures/b1wgencrypt.p PERSISTENT 
                    SET h-b1wgencrypt (INPUT aux_nrdconta).
            
                ASSIGN aux_cddsenha = DYNAMIC-FUNCTION("decriptar" IN h-b1wgencrypt,
                                                       INPUT aux_cddsenha,
                                                       INPUT aux_nrdconta).
                
                ASSIGN aux_dssenweb = DYNAMIC-FUNCTION("decriptar" IN h-b1wgencrypt,
                                                       INPUT aux_dssenweb,
                                                       INPUT aux_nrdconta).
            
                IF  TRIM(aux_dssenlet) <> ""  THEN
                    ASSIGN aux_dssenlet = DYNAMIC-FUNCTION("decriptar" IN h-b1wgencrypt,
                                                           INPUT aux_dssenlet,
                                                           INPUT aux_nrdconta).
            
                DELETE PROCEDURE h-b1wgencrypt.
            END.
        
        FIND crapass WHERE crapass.cdcooper = aux_cdcooper AND
                           crapass.nrdconta = aux_nrdconta NO-LOCK NO-ERROR.
    
        IF  NOT AVAILABLE crapass  THEN
            DO:
                aux_dsmsgerr = "<dsmsgerr>" + "Conta nao habilitada! " +
                               "</dsmsgerr>".
                
                {&out} aux_dsmsgerr aux_tgfimprg.
             
                LEAVE.
            END.
        
        IF  GET-VALUE("aux_flgexecu") <> ""  THEN
            ASSIGN aux_flgexecu = LOGICAL(GET-VALUE("aux_flgexecu")).

        IF  GET-VALUE("aux_flmensag") <> ""  THEN
            ASSIGN aux_flmensag = INT(GET-VALUE("aux_flmensag")).
        
        IF GET-VALUE("aux_idefetiv") <> "" THEN
            ASSIGN aux_idefetiv = INTE(GET-VALUE("aux_idefetiv")).

        IF  GET-VALUE("flcadast") <> ""  THEN
            ASSIGN aux_flcadast = INT(GET-VALUE("flcadast")).
            
        IF  GET-VALUE("aux_indvalid") <> ""  THEN    
            ASSIGN aux_indvalid = INTE(GET-VALUE("aux_indvalid")).    
            
        IF  GET-VALUE("tpoperac") <> ""  THEN
            ASSIGN aux_tpoperac = INT(GET-VALUE("tpoperac")).

        /* Verificar senha e frase */
        IF  aux_flgcript AND NOT CAN-DO("2,11,18",STRING(aux_operacao))  OR /** Utiliza criptografia **/
           (
               NOT aux_flgcript AND 
               ( 
                 (
                  /** Nao utiliza criptografia se for confirmacao de pagamento **/
                  CAN-DO("27",STRING(aux_operacao)) 
               ) OR
               (
                  /** Nao utiliza criptografia se for confirmacao de transferencia/TED **/
                  CAN-DO("22",STRING(aux_operacao)) AND aux_flgexecu 
               ) OR
               (
                  /** Nao utiliza criptografia se for aprovacao de transacao pendente **/
                  CAN-DO("75",STRING(aux_operacao)) AND aux_indvalid = 1 
               ) OR               
               (
                  /** Nao utiliza criptografia se for cancelamento de aplicacao **/
                  CAN-DO("85",STRING(aux_operacao))
               ) OR
               (
                  /** Nao utiliza criptografia se for confirmacao de resgate de aplicacao **/
                  CAN-DO("116",STRING(aux_operacao)) AND aux_flmensag = 0
               ) OR
               (
                  /** Nao utiliza criptografia se for contratacao de pre-aprovado **/
                  CAN-DO("100",STRING(aux_operacao))
               ) OR
               (
                  /** Nao utiliza criptografia se for contratacao de pre-aprovado **/
                  CAN-DO("115",STRING(aux_operacao))
               ) OR
               (
                  /** Nao utiliza criptografia se for pagamento de GPS **/
                  CAN-DO("153",STRING(aux_operacao)) AND (aux_tpoperac = 3 OR aux_tpoperac = 5)
               ) OR
               (
                  /** Nao utiliza criptografia se for pagamento de emprestimo **/
                  CAN-DO("158",STRING(aux_operacao))
               ) OR
               (
                  /** Nao utiliza criptografia se for reprovacao de transacao pendente **/
                  CAN-DO("163",STRING(aux_operacao))
               ) OR
               (
                  /** Nao utiliza criptografia se for pagamento de DARF e DAS **/
                  CAN-DO("188",STRING(aux_operacao)) AND aux_idefetiv = 1
               ) OR
               (
                  /** Nao utiliza criptografia se for confirmação de recarga de celular **/
                  CAN-DO("181",STRING(aux_operacao)) AND INT(GET-VALUE("aux_operacao")) = 6
               ) OR
               (
                  /** Nao utiliza criptografia se for cadastro de debito automatico **/
                  CAN-DO("99",STRING(aux_operacao)) AND aux_flcadast = 1
               ) OR
               (
                  /** Nao utiliza criptografia se for pagamento de FGTS e DAE **/
                  CAN-DO("199",STRING(aux_operacao)) AND aux_idefetiv = 1
               )
               )
           )
             THEN 
        DO:
            RUN proc_operacao2.

            IF   RETURN-VALUE = "NOK"   THEN
                 LEAVE.
        END.
        
        /**********************************************************************/
        /************   Verifica qual operacao deve ser executada   ***********/    
        /**********************************************************************/
    
        IF  aux_operacao = 1  THEN /* Lista Saldo Gerais do Cooperado */
            RUN proc_operacao1.
        ELSE
        IF  aux_operacao = 2  THEN /* Validar Frase e Senha do InternetBank */
            DO:

                RUN proc_operacao2.
                
                IF   RETURN-VALUE = "NOK"   THEN
                     LEAVE.
                
                {&out} aux_tgfimprg.
            END.
        ELSE     
        IF  aux_operacao = 3  THEN /* Informacoes para Geracao de Boleto Bancario */
            RUN proc_operacao3. 
        ELSE
        IF  aux_operacao = 4  THEN /* Gerar Boleto e Dados para Impressao */
            RUN proc_operacao4. 
        ELSE        
        IF  aux_operacao = 5  THEN /* Listar Boletos para Consulta e Re-Impressao */
            RUN proc_operacao5.
        ELSE        
        IF  aux_operacao = 6 THEN /* Listar Saldos de Poupanca Programada */
            RUN proc_operacao6.
        ELSE
        IF  aux_operacao = 7 THEN /* Leitura do Informe de Rendimentos */
            RUN proc_operacao7.
        ELSE
        IF  aux_operacao = 8 THEN /* Leitura dos Saldos Medios do Semestre */
            RUN proc_operacao8.
        ELSE
        IF  aux_operacao = 9 THEN /* Extrato Lancamentos Futuros */
            RUN proc_operacao9.
        ELSE    
        IF  aux_operacao = 10  THEN /* Extrato Conta Investimento */
            RUN proc_operacao10.
        ELSE
        IF  aux_operacao = 11  THEN /* Carrega Titulares para a Conta On-Line */
            RUN proc_operacao11.
        ELSE        
        IF  aux_operacao = 12  THEN /* Extrato da Conta Corrente */
            RUN proc_operacao12.    
        ELSE
        IF  aux_operacao = 13 THEN /* Consulta de Emprestimos */
            RUN proc_operacao13.
        ELSE
        IF  aux_operacao = 14 THEN /* Gerar Extrato de Emprestimo */
            RUN proc_operacao14.
        ELSE    
        IF  aux_operacao = 15  THEN /* Leitura dos Saldos de Aplicacao RDCA e RDC */
            RUN proc_operacao15.
        ELSE
        IF  aux_operacao = 16  THEN /* Gerar Extrato de Aplicacoes RDCA e RDC */
            RUN proc_operacao16.
        ELSE
        IF  aux_operacao = 17  THEN /* Extrato de Poupanca Programada */
            RUN proc_operacao17.
        ELSE
        IF  aux_operacao = 18  THEN /* Cadastrar/Alterar Chave para Conta On-Line */
            RUN proc_operacao18.
        ELSE
        IF  aux_operacao = 19  THEN /* Carregar Dados de Sacado para Boleto */
            RUN proc_operacao19.            
        ELSE
        IF  aux_operacao = 20  THEN /* Gerenciamento de Sacados - Gravar/Alterar */
            RUN proc_operacao20.
        ELSE
        IF  aux_operacao = 21  THEN /* Selecao de Cheques Pendentes */
            RUN proc_operacao21.
        ELSE
        IF  aux_operacao = 22  THEN /* Validar e Efetuar Transferencia */
            RUN proc_operacao22.
        ELSE    
        IF  aux_operacao = 23  THEN /* Listar Contas Destino para Transferencia */
            RUN proc_operacao23.
        ELSE    
        IF  aux_operacao = 24  THEN /* Lista Holerites */
            RUN proc_operacao24.
        ELSE
        IF  aux_operacao = 25  THEN /* Lista Protocolos */
            RUN proc_operacao25.
        ELSE    
        IF  aux_operacao = 26  THEN /* Valida Pagamento On-Line */
            RUN proc_operacao26.
        ELSE
        IF  aux_operacao = 27  THEN /* Efetua Pagamento On-Line */
            RUN proc_operacao27.
        ELSE    
        IF  aux_operacao = 28  THEN /* Verifica Limite para Pagamento On-Line */
            RUN proc_operacao28.
        ELSE
        IF  aux_operacao = 29  THEN /* Extrato de Capital */
            RUN proc_operacao29.
        ELSE 
        IF  aux_operacao = 30  THEN /* Listar Convenios */ 
            RUN proc_operacao30.
        ELSE
        IF  aux_operacao = 31  THEN /* Obter Novo Plano de Capital */
            RUN proc_operacao31.
        ELSE
        IF  aux_operacao = 32  THEN /* Cadastrar Novo Plano de Capital */
            RUN proc_operacao32.
        ELSE
        IF  aux_operacao = 33  THEN /* Excluir Novo Plano de Capital */
            RUN proc_operacao33.
        ELSE
        IF  aux_operacao = 34  THEN /* Imprime Protocolo do Novo Plano de Capital */
            RUN proc_operacao34.
        ELSE
        IF  aux_operacao = 36  THEN /* Gerar Arquivo de Retorno de Cobranca */
            RUN proc_operacao36.
        ELSE
        IF  aux_operacao = 37  THEN /* Retornar Convenios de Cobranca do Socio */
            RUN proc_operacao37.
        ELSE
        IF  aux_operacao = 38  THEN /* Consulta de Agendamentos de Pagamento */
            RUN proc_operacao38.
        ELSE
        IF  aux_operacao = 39  THEN /* Cancelar Agendamentos */
            RUN proc_operacao39.
        ELSE
        IF  aux_operacao = 40  THEN /* Baixa ou Exclusao de Boleto */
            RUN proc_operacao40.
        ELSE
        IF  aux_operacao = 41  THEN /* Permissoes do Menu */
            RUN proc_operacao41.
        ELSE
        IF  aux_operacao = 42  THEN /* Itens do Menu e Operadores da Conta */
            RUN proc_operacao42.
        ELSE
        IF  aux_operacao = 43  THEN /* Gerenciar Operadores da Conta */
            RUN proc_operacao43.
        ELSE
        IF  aux_operacao = 44  THEN /* Dados do Titular para Modulo Meu Cadastro */
            RUN proc_operacao44.
        ELSE
        IF  aux_operacao = 45  THEN /* Alterar Endereco do Titular - Meu Cadastro */
            RUN proc_operacao45.
        ELSE
        IF  aux_operacao = 46  THEN /* Obter Dados de Telefone - Meu Cadastro */
            RUN proc_operacao46.
        ELSE
        IF  aux_operacao = 47  THEN /* Obter Dados de E-mail - Meu Cadastro */
            RUN proc_operacao47.
        ELSE
        IF  aux_operacao = 48  THEN /* Gerenciar E-mail - Meu Cadastro */
            RUN proc_operacao48.
        ELSE
        IF  aux_operacao = 49  THEN /* Gerenciar Telefone - Meu Cadastro */
            RUN proc_operacao49.
        ELSE
        IF  aux_operacao = 50  THEN /* Consultar Envio de Informativos */
            RUN proc_operacao50.
        ELSE
        IF  aux_operacao = 51  THEN /* Lista de Recebimento de Informativos */
            RUN proc_operacao51.
        ELSE
        IF  aux_operacao = 52  THEN /* Excluir Informativo */
            RUN proc_operacao52.
        ELSE
        IF  aux_operacao = 53  THEN /* Obtem Dados para Alterar Informativo */
            RUN proc_operacao53.
        ELSE
        IF  aux_operacao = 54  THEN /* Alterar Informativo */
            RUN proc_operacao54.
        ELSE
        IF  aux_operacao = 55  THEN /* Obtem Dados para Incluir Informativo */
            RUN proc_operacao55.
        ELSE
        IF  aux_operacao = 56  THEN /* Incluir Informativo */
            RUN proc_operacao56.   
        ELSE
        IF  aux_operacao = 57  THEN /* Extrato de tarifas */
            RUN proc_operacao57.
        ELSE
        IF  aux_operacao = 58  THEN /* Cadastro de instrucoes para boletos */
            RUN proc_operacao58.
        ELSE
        IF  aux_operacao = 59  THEN /* Relatorios de Cobranca */
            RUN proc_operacao59.
        ELSE
        IF  aux_operacao = 60  THEN /* Custodia de Cheques */
            RUN proc_operacao60.
        ELSE
        IF  aux_operacao = 61  THEN /* Resumo Custodia de Cheques */
            RUN proc_operacao61.
        ELSE
        IF  aux_operacao = 62  THEN /* Listar Titulos do Sacado (DDA) */
            RUN proc_operacao62.
        ELSE
        IF  aux_operacao = 63  THEN /* Consultar Sacado Eletronico (DDA) */
            RUN proc_operacao63.
        ELSE
        IF  aux_operacao = 64  THEN /* Adesao ao DDA (DDA) */
            RUN proc_operacao64.
        ELSE
        IF  aux_operacao = 65  THEN /* Listar Titulos Bloqueados (DDA) */
            RUN proc_operacao65.
        ELSE
        IF  aux_operacao = 66  THEN /* Intrucoes do Titulo */
            RUN proc_operacao66.
        ELSE
        IF  aux_operacao = 67  THEN /* Pesquisa de endereco pelo CEP */
            RUN proc_operacao67.
        ELSE
        IF  aux_operacao = 68  THEN /* Extrato Cecred Visa */
            RUN proc_operacao68.
        ELSE
        IF  aux_operacao = 69  THEN /* Inportacao de cobrancas */
            RUN proc_operacao69.
        ELSE
        IF  aux_operacao = 70  THEN /* Extrato Cecred Visa - Periodos */
            RUN proc_operacao70.
        ELSE
        IF  aux_operacao = 71  THEN /* Servico de Mensagens */
            RUN proc_operacao71.
        ELSE
        IF  aux_operacao = 73  THEN /* Transacoes Pendentes - Operador */
            RUN proc_operacao73.
        ELSE
        IF  aux_operacao = 74  THEN /* Exclusao Trans Pendentes - Operad */
            RUN proc_operacao74.
        ELSE
        IF  aux_operacao = 75  THEN /* Efetivacao Trans Pendentes - Oper */
            RUN proc_operacao75.
        ELSE
        IF  aux_operacao = 76  THEN /* Verificar titular letras seguranca - TAA */
            RUN proc_operacao76.
        ELSE
        IF  aux_operacao = 77  THEN /* Cadastrar letras seguranca - TAA */
            RUN proc_operacao77.
        ELSE
        IF  aux_operacao = 78  THEN /* Acesso a tela de transferencias */
            RUN proc_operacao78.
        ELSE
        IF  aux_operacao = 79  THEN /* Acesso a tela de Cadastro de Favorecidos */
            RUN proc_operacao79.
        ELSE
        IF  aux_operacao = 80  THEN /* Validar Cadastro de Favorecidos */
            RUN proc_operacao80.
        ELSE
        IF  aux_operacao = 81  THEN /* Relatorio Demonstrativo Aplicacoes */
            RUN proc_operacao81.
        ELSE
        IF  aux_operacao = 82  THEN
            RUN proc_operacao82.
        ELSE
           IF aux_operacao = 83 THEN /* Traz tabela de rendiemntos*/
              RUN proc_operacao83.
        ELSE
           IF aux_operacao = 84 THEN /*Valida os dados da aplicacao e grava*/
              RUN proc_operacao84.
        ELSE
           IF aux_operacao = 85 THEN /*Cancela aplicacao*/
              RUN proc_operacao85.
        ELSE
           IF aux_operacao = 86 THEN /*Calcula a data de permanencia para resgate*/
              RUN proc_operacao86.
        ELSE
           IF aux_operacao = 87 THEN /* Ativa/ Desativa um beneficiario de TED */
              RUN proc_operacao87.
        ELSE
           IF aux_operacao = 88 THEN /* Busca protocolo gerado na inclusao da aplicacao */
              RUN proc_operacao88.
        ELSE
           IF aux_operacao = 89 THEN /*Valida saldo */
              RUN proc_operacao89.
        ELSE
           IF aux_operacao = 90 THEN /* Credito pre-aprovado */
              RUN proc_operacao90.
        ELSE 
           IF aux_operacao = 91 THEN /*Consulta agendamento aplicacao resgate*/
              RUN proc_operacao91.
        ELSE 
           IF aux_operacao = 92 THEN /*Buscar parcelas credito pre-aprovado*/
              RUN proc_operacao92.
        ELSE 
           IF aux_operacao = 93 THEN /*Imprimir o extrato de contratacao*/
              RUN proc_operacao93.
        ELSE
           IF aux_operacao = 94 THEN /*Retorna dados da qtd de dias de carencia da crapttx.*/
              RUN proc_operacao94.
        ELSE
           IF aux_operacao = 95 THEN /*Resumo do resgate da aplicacao*/
              RUN proc_operacao95.
        ELSE
           IF aux_operacao = 96 THEN /*Valida o horario limite de inicio/fim*/
              RUN proc_operacao96.
        ELSE
           IF aux_operacao = 97 THEN /* Inclusao de agendamentos aplicacao resgate*/
              RUN proc_operacao97.
        ELSE
           IF aux_operacao = 98 THEN /* Buscar convenios aceitos */
              RUN proc_operacao98.
        ELSE
           IF aux_operacao = 99 THEN /*Cadastrar autorizacao de debito - Deb.Facil*/
              RUN proc_operacao99.
        ELSE
           IF aux_operacao = 100 THEN /*Gravar os dados do pre-aprovado*/
              RUN proc_operacao100.
        ELSE
           IF aux_operacao = 101 THEN /* Pagto Titulos por Arquivo - Verifica Aceite */
              RUN proc_operacao101.
        ELSE
           IF aux_operacao = 102 THEN /* Pagto Titulos por Arquivo - Listar Arquivos Retorno */
              RUN proc_operacao102.
        ELSE
           IF aux_operacao = 103 THEN /*Consulta extrato TED, TEC, DOC e Transferencia*/
              RUN proc_operacao103.
        ELSE
           IF aux_operacao = 104 THEN /* Valida valor de resgate */
              RUN proc_operacao104.
        ELSE
           IF aux_operacao = 105 THEN /* Buscar autorizacoes de debito cadastradas*/
              RUN proc_operacao105.
        ELSE
           IF aux_operacao = 106 THEN /* validar inclusao agendamento*/
              RUN proc_operacao106.
        ELSE
           IF aux_operacao = 107 THEN /* Somar data vencimento */
              RUN proc_operacao107.
        ELSE
           IF aux_operacao = 108 THEN /* Buscar detalhes do agendamento */
              RUN proc_operacao108.
        ELSE
           IF aux_operacao = 109 THEN /* Buscar intervalo entre duas datas*/
              RUN proc_operacao109.
        ELSE
           IF aux_operacao = 110 THEN /*Validar/Cadastrar/Excluir suspensao de autorizacao de debito*/
              RUN proc_operacao110.
        ELSE
           IF aux_operacao = 111 THEN /* Buscar autorizacoes de debito suspensas */
              RUN proc_operacao111.
        ELSE
           IF aux_operacao = 112 THEN /* Efetuar cancelamento de agendamento */
              RUN proc_operacao112.
        ELSE
           IF aux_operacao = 113 THEN /*Buscar lancamentos agendados e efetivados*/
              RUN proc_operacao113.
        ELSE
           IF aux_operacao = 114 THEN /* Efetuar cancelamento de agendamento */
              RUN proc_operacao114.
        ELSE
           IF aux_operacao = 115 THEN /*Bloquear/Desbloquear lancamento de debito agendado*/
              RUN proc_operacao115.
        ELSE
          IF aux_operacao = 116 THEN /* Incluir Resgate de Aplicação */
             RUN proc_operacao116.
        ELSE
           IF aux_operacao = 117 THEN /* Pagto Titulos por Arquivo - Gerar arquivo retorno */
              RUN proc_operacao117.
        ELSE
           IF aux_operacao = 118 THEN /*Listar protocolos de operacoes do Debito Facil*/
              RUN proc_operacao118.
        ELSE
           IF aux_operacao = 119 THEN /*Cancelar varios agendamentos*/
              RUN proc_operacao119.
        ELSE
           IF aux_operacao = 120 THEN /* Pagto Titulos por Arquivo - Buscar Termos Servico */
              RUN proc_operacao120.
        ELSE
           IF aux_operacao = 121 THEN /*Qtd max de meses para agendamento*/
              RUN proc_operacao121.
        ELSE
           IF aux_operacao = 122 THEN /* Busca cooperativas - MobileBank */
              .
        ELSE
           IF aux_operacao = 123 THEN /* Calcula as taxas do credito pre-aprovado */
              RUN proc_operacao123.
        ELSE
           IF  aux_operacao = 124  THEN /* Carrega menu de servicos (Mobile) */
               .
        ELSE
           IF  aux_operacao = 125  THEN /* Pega data do proximo movimento */
               RUN proc_operacao125.
        ELSE
           IF  aux_operacao = 126  THEN /* Valida autorização de transação Mobile */
               RUN proc_operacao126.
        ELSE
           IF  aux_operacao = 127  THEN /* Verifica o tipo de pessoa Mobile */
               .
        ELSE
            IF  aux_operacao = 128  THEN /* Verifica Agencias cadastradas */
                RUN proc_operacao128.
        ELSE
            IF  aux_operacao = 129  THEN /* Verifica Desconto de Cheque */
                RUN proc_operacao129.
        ELSE
            IF  aux_operacao = 130  THEN /* Verifica Desconto de Titulo */
                RUN proc_operacao130.
        ELSE
            IF  aux_operacao = 131  THEN /* Verifica Desconto de Cheque */
                RUN proc_operacao131.
        ELSE
            IF  aux_operacao = 132  THEN /* Verifica Desconto de Titulo */
                RUN proc_operacao132.
        ELSE
            IF  aux_operacao = 133  THEN /* Gera log boletos não enviados por e-mail */
                RUN proc_operacao133.
        ELSE
            IF  aux_operacao = 134  THEN /* Busca os Bancos pelo ISPB */
                RUN proc_operacao134.
        ELSE
            IF  aux_operacao = 135  THEN /* Consulta de Comprovantes Recebidos */
                RUN proc_operacao135.
        ELSE
            IF  aux_operacao = 136  THEN /* Consulta de convenios e horarios para transações no mobile */
                RUN proc_operacao136.
        ELSE
            IF  aux_operacao = 137  THEN /* Busca de mensagem de atraso em operacao de credito */
                RUN proc_operacao137.
        ELSE
            IF  aux_operacao = 138  THEN /* Busca parcelas para reimprimir carnê */
                RUN proc_operacao138.
        ELSE
            IF  aux_operacao = 139  THEN /* Trata da chamada das rotinas da tela de Folha de pagamento */
                RUN proc_operacao139.
        ELSE
            IF  aux_operacao = 140  THEN /* Trata da chamada das rotinas da tela de Folha de pagamento */
                RUN proc_operacao140.
        ELSE
            IF  aux_operacao = 141  THEN /* Trata da chamada das rotinas da tela de Folha de pagamento */
                RUN proc_operacao141.
        ELSE
            IF  aux_operacao = 142  THEN /* Trata da chamada das rotinas da tela de Folha de pagamento */
                RUN proc_operacao142.
        ELSE
            IF  aux_operacao = 143  THEN /* Trata da chamada das rotinas da tela de Folha de pagamento */
                RUN proc_operacao143.
        ELSE
            IF  aux_operacao = 144  THEN /* Trata da chamada das rotinas da tela de Folha de pagamento */
                RUN proc_operacao144.
        ELSE
            IF  aux_operacao = 145  THEN /* Trata da chamada das rotinas da tela de Folha de pagamento */
                RUN proc_operacao145.
         ELSE
            IF  aux_operacao = 146  THEN /* Trata da chamada das rotinas da tela de Folha de pagamento */
                RUN proc_operacao146.
         ELSE
            IF  aux_operacao = 147  THEN /* Trata da chamada das rotinas da tela de Folha de pagamento */
                RUN proc_operacao147.
         ELSE
            IF  aux_operacao = 148  THEN /* Trata da chamada das rotinas da tela de Reciprocidade */
                RUN proc_operacao148.
        ELSE
            IF  aux_operacao = 149  THEN /* Trata da chamada das rotinas da tela de Folha de pagamento */
                RUN proc_operacao149.
         ELSE
            IF  aux_operacao = 150  THEN /* Trata da chamada das rotinas da tela de Folha de pagamento */
                RUN proc_operacao150.
         ELSE
            IF  aux_operacao = 151  THEN /* Trata da chamada das rotinas da tela de Folha de pagamento */
                RUN proc_operacao151.
         ELSE
            IF  aux_operacao = 152  THEN /* Trata da chamada das rotinas de mensagens do internet bank */
                RUN proc_operacao152.
         ELSE
            IF  aux_operacao = 153  THEN /* Trata da chamada das rotinas da tela do GPS */
                RUN proc_operacao153.
         ELSE
            IF  aux_operacao = 154  THEN /* Trata da chamada das rotinas do Pagamento de Contratos */
                RUN proc_operacao154.
         ELSE
            IF  aux_operacao = 155  THEN /* Trata da chamada das rotinas do Pagamento de Contratos */
                RUN proc_operacao155.
         ELSE
            IF  aux_operacao = 156  THEN /* Trata da chamada das rotinas do Pagamento de Contratos */
                RUN proc_operacao156.
         ELSE
            IF  aux_operacao = 157 THEN /* Trata da chamada das rotinas do Pagamento de Contratos */
                RUN proc_operacao157.
        ELSE
            IF  aux_operacao = 158 THEN /* Trata da chamada das rotinas do Pagamento de Contratos */
                RUN proc_operacao158.
        ELSE
            IF  aux_operacao = 159 THEN /* Trata da chamada das rotinas do Pagamento de Contratos */
                RUN proc_operacao159.
        ELSE
            IF  aux_operacao = 160 THEN /* Trata da chamada das rotinas de Demonstrativo de INSS */
                RUN proc_operacao160.
        ELSE
            IF  aux_operacao = 161 THEN /* Trata da chamada das rotinas de Demonstrativo de INSS */
                RUN proc_operacao161.
        ELSE
            IF  aux_operacao = 162 THEN /* Extrato operacoes de credito */
                RUN proc_operacao162.
        ELSE
            IF  aux_operacao = 163 THEN /* Reprovar Transacao Pendente */
                RUN proc_operacao163.
        ELSE
            IF  aux_operacao = 164 THEN /* Impressao do CET Credito Pré-aprovado */
                RUN proc_operacao164.
        ELSE
            IF  aux_operacao = 165 THEN /* Buscar pacote de tarifas */
                RUN proc_operacao165.
        ELSE
            IF  aux_operacao = 166 THEN /* Consultar permissoes dos itens do menu mobile */
                RUN proc_operacao166. 
        ELSE
            IF  aux_operacao = 167 THEN /* Aderir pacote de tarifas */
                RUN proc_operacao167.
        ELSE
            IF  aux_operacao = 168 THEN /* Consultar telefone e horários do SAC e Ouvidoria */
                RUN proc_operacao168.
        ELSE
            IF  aux_operacao = 170 THEN /* Termo pacote de tarifas */
                RUN proc_operacao170. 
        ELSE
            IF  aux_operacao = 171 THEN /* Busca motivos exclusao DEBAUT */
                RUN proc_operacao171.               
        ELSE
            IF  aux_operacao = 172 THEN /* Termo pacote de tarifas PDF */
                RUN proc_operacao172.
        ELSE
            IF  aux_operacao = 173 THEN /* Busca motivos exclusao DEBAUT */
                RUN proc_operacao173. 
        ELSE
            IF  aux_operacao = 174 THEN /* Busca configurações para nome da emissão */
                RUN proc_operacao174.
        ELSE
            IF  aux_operacao = 175 THEN /* Grava configurações de nome da emissão */
                RUN proc_operacao175.
        ELSE
            IF  aux_operacao = 176 THEN /* Integralizar cotas de capital */
                RUN proc_operacao176. 
        ELSE
            IF  aux_operacao = 177 THEN     /* Cancelar integralização */
                RUN proc_operacao177. 	
        ELSE
            IF  aux_operacao = 178 THEN /* Mantem Custodia de Cheques. */
                RUN proc_operacao178. 
        ELSE
            IF  aux_operacao = 179 THEN /* Mantem Desconto de Cheques. */
                RUN proc_operacao179. 
        ELSE
            IF  aux_operacao = 180 THEN /* Calcula data útil para agendamento */
                RUN proc_operacao180.
        ELSE
            IF  aux_operacao = 181 THEN /* Mantem Recarga de Celular. */
                RUN proc_operacao181.
        ELSE
            IF  aux_operacao = 182 THEN /* Consultar informacoes gerais da conta */
                RUN proc_operacao182.
        ELSE
            IF  aux_operacao = 186 THEN /* Retorna valor atualizado de titulos vencidos */
                RUN proc_operacao186.
        ELSE
            IF  aux_operacao = 187 THEN /* Consulta Horario Limite de DARF/DAS */
                RUN proc_operacao187.   
        ELSE
            IF  aux_operacao = 188 THEN /* Operar pagamento de DARF/DAS */
                RUN proc_operacao188.
        ELSE
            IF  aux_operacao = 189 THEN /* Carrega dados Servico SMS Cobranca */
                RUN proc_operacao189. 
        ELSE
            IF  aux_operacao = 191 THEN /* Solicitar Emprestimo */
                RUN proc_operacao191. 
        ELSE
            IF  aux_operacao = 192 THEN /* Ler Mensagens de Confirmacao para Prepostos */
                RUN proc_operacao192. 
        ELSE
            IF  aux_operacao = 193 THEN /* Listar Comprovantes  */
                RUN proc_operacao193.                 
        ELSE
            IF  aux_operacao = 194 THEN /* Detalhes Comprovante  */
                RUN proc_operacao194.
        ELSE
            IF  aux_operacao = 195 THEN /* Listar Agendamentos  */
                RUN proc_operacao195.                
        ELSE
            IF  aux_operacao = 196 THEN /* Detalhar Agendamento  */
                RUN proc_operacao196. 
        ELSE
            IF  aux_operacao = 197 THEN /* Detalhar Comprovante Recebido  */
                RUN proc_operacao197.  
        ELSE
            IF  aux_operacao = 199 THEN /* Operar pagamento de tributos */
                RUN proc_operacao199.                        
        ELSE
            IF  aux_operacao = 204 THEN /* Carregar os dados do upload do arquivo de pagamento */
                RUN proc_operacao204.         
        ELSE
            IF  aux_operacao = 205 THEN /* Gravar a validaçao do upload do arquivo de pagamento */
                RUN proc_operacao205. 
        ELSE
            IF  aux_operacao = 210 THEN /* Consultar o LOG de upload do arquivo de pagamento */
                RUN proc_operacao210. 
        ELSE
            IF  aux_operacao = 211 THEN /* Consultar os titulos agendados pelo arquivo de pagamento */
                RUN proc_operacao211. 
        ELSE
            IF  aux_operacao = 212 THEN /* Cancelar agendamento de pagamento feito por arquivo de pagamento*/
                RUN proc_operacao212. 
        ELSE
            IF  aux_operacao = 213 THEN /* Relatorio dos titulos agendados pelo arquivo de pagamento */
                RUN proc_operacao213. 
        ELSE
            IF  aux_operacao = 206 THEN /* Consultar lista de notificacoes */
                RUN proc_operacao206. 
        ELSE
            IF  aux_operacao = 207 THEN /* Obter detalhes da notificacao */
                RUN proc_operacao207. 
        ELSE
            IF  aux_operacao = 208 THEN /* Carregar configuracoes de recebimento de push */
                RUN proc_operacao208. 
        ELSE
            IF  aux_operacao = 209 THEN /* Alterar configuracoes de recebimento de push */
                RUN proc_operacao209.
        ELSE
            IF  aux_operacao = 214 THEN /* Obter quantidade de notificações não visualizadas do cooperado */
                RUN proc_operacao214.
    END.
/*....................................................................*/
    
    RUN displayFields.
    
    /* STEP 2b -
     * Enable objects that should be enabled. */
    RUN enableFields.
    /*
    /* STEP 2c -
     * OUTPUT the Progress from buffer to the WEB stream. */
    RUN outputFields.
    */
  END. 
  
  /* Show error messages. */
  IF AnyMessage() THEN 
  DO:
     /* ShowDataMessage may return a Progress column name. This means you
      * can use the function as a parameter to HTMLSetFocus instead of 
      * calling it directly.  The first parameter is the form name.   
      *
      * HTMLSetFocus("document.DetailForm",ShowDataMessages()). */
     ShowDataMessages().
  END.
 
END PROCEDURE.

/*............................................................................*/


/*......................... PROCEDURES DAS OPERACOES .........................*/

PROCEDURE proc_operacao1:

    /* ATENCAO: Parametro aux_dsorigip eh alimentado na operacao 2 */

    ASSIGN aux_indlogin = INTE(GET-VALUE("indlogin"))
           aux_dtiniper = DATE(GET-VALUE("dtiniper")).

    RUN sistema/internet/fontes/InternetBank1.p (INPUT aux_cdcooper,
                                                 INPUT aux_nrdconta,
                                                 INPUT aux_idseqttl,
                                                 INPUT aux_nrcpfope,
                                                 INPUT aux_dtmvtolt,
                                                 INPUT aux_dtmvtopr,
                                                 INPUT aux_dtmvtocd,
                                                 INPUT aux_inproces,
                                                 INPUT aux_indlogin,
                                                 INPUT aux_dtiniper,
                                                 INPUT aux_nripuser,
                                                 INPUT aux_dsorigip,
                                                 INPUT aux_dtmvtoan,
                                                 INPUT aux_flmobile,
                                                OUTPUT aux_dsmsgerr,
                                                OUTPUT TABLE xml_operacao).
                                                 
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr aux_tgfimprg.
            
            RETURN "NOK".
        END.

    FIND FIRST xml_operacao NO-LOCK NO-ERROR.
    
    IF  AVAILABLE xml_operacao  THEN
        {&out} xml_operacao.dslinxml.
               
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao2:
    
    ASSIGN aux_vldfrase = INTE(GET-VALUE("vldfrase"))
           aux_dssenlet = GET-VALUE("dssenlet")   
           aux_vldshlet = LOGICAL(GET-VALUE("vldshlet"))
           aux_inaceblq = INTE(GET-VALUE("inaceblq"))
           aux_dsorigip = GET-VALUE("dsorigip")
           aux_indlogin = INTE(GET-VALUE("indlogin")).

    IF  aux_vldshlet  THEN
        DO:
            IF  aux_flgcript  THEN /** Utiliza criptografia **/
                DO:
                    RUN sistema/generico/procedures/b1wgencrypt.p PERSISTENT 
                        SET h-b1wgencrypt (INPUT aux_nrdconta).
            
                    ASSIGN aux_dssenlet = DYNAMIC-FUNCTION("decriptar" IN h-b1wgencrypt,
                                                           INPUT aux_dssenlet,
                                                           INPUT aux_nrdconta).
        
                    DELETE PROCEDURE h-b1wgencrypt.
                END.
        END.

    RUN sistema/internet/fontes/InternetBank2.p (INPUT aux_cdcooper,
                                                 INPUT aux_nrdconta,
                                                 INPUT aux_idseqttl,
                                                 INPUT aux_nrcpfope,
                                                 INPUT aux_cddsenha,
                                                 INPUT aux_dssenweb,
                                                 INPUT aux_dssenlet,
                                                 INPUT aux_vldshlet,
                                                 INPUT aux_vldfrase,
                                                 INPUT aux_inaceblq,
                                                 INPUT aux_nripuser,
                                                 INPUT aux_dsorigip,
                                                 INPUT aux_flmobile,
                                                 INPUT IF NOT aux_flgcript THEN aux_indlogin ELSE 0,
                                                OUTPUT aux_dsmsgerr,
												OUTPUT TABLE xml_operacao).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr aux_tgfimprg.
            
            RETURN "NOK".
        END.
	ELSE
	    FOR EACH xml_operacao NO-LOCK:

            {&out} xml_operacao.dslinxml. 
                
        END.	

    RETURN "OK".
        
END PROCEDURE.

PROCEDURE proc_operacao3:

    ASSIGN aux_vldsacad = INTE(GET-VALUE("vldsacad"))
           aux_nrctremp = INTE(GET-VALUE("nrctremp"))
           aux_nrctasac = INTE(GET-VALUE("nrctasac")).
    
    RUN sistema/internet/fontes/InternetBank3.p (INPUT aux_cdcooper,
                                                 INPUT aux_nrdconta,
                                                 INPUT aux_idseqttl,
                                                 INPUT aux_dtmvtolt,
                                                 INPUT aux_vldsacad,
                                                 INPUT aux_nrctremp,
                                                 INPUT aux_nrctasac,
                                                OUTPUT aux_dsmsgerr,
                                                OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    ELSE
        FOR EACH xml_operacao NO-LOCK:
    
            {&out} xml_operacao.dslinxml. 
                
        END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao4:

    ASSIGN aux_dtmvtolt = DATE(GET-VALUE("dtmvtolt"))
           aux_nrinssac = GET-VALUE("nrinssac") 
           aux_nmdavali = GET-VALUE("nmdavali")            
           aux_cdtpinav = INTE(GET-VALUE("cdtpinav")) 
           aux_nrinsava = DECI(GET-VALUE("nrinsava"))
           aux_nrcnvcob = INTE(GET-VALUE("nrconven"))
           aux_vltitulo = DECI(GET-VALUE("vltitulo"))
           aux_cddespec = INTE(GET-VALUE("cddespec"))
           aux_cdcartei = INTE(GET-VALUE("cdcartei"))
           aux_dtdocmto = DATE(GET-VALUE("dtdocmto"))
           aux_dtvencto = DATE(GET-VALUE("dtvencto"))
           aux_vldescto = DECI(GET-VALUE("vldescto"))
           aux_vlabatim = DECI(GET-VALUE("vlabatim"))
           aux_qttitulo = INTE(GET-VALUE("qttitulo"))
           aux_cdtpvcto = INTE(GET-VALUE("cdtpvcto"))
           aux_qtdiavct = INTE(GET-VALUE("qtdiavct"))
           aux_cdmensag = INTE(GET-VALUE("cdmensag"))
           aux_dsdoccop = GET-VALUE("dsdoccop")
           aux_dsdinstr = GET-VALUE("dsdinstr")
           aux_dsinform = GET-VALUE("dsinform")
           aux_nrctremp = INTEGER(GET-VALUE("nrctremp"))

           /* Campos para Cobranca Registrada */
           aux_flgdprot = IF INTE(GET-VALUE("flgdprot")) = 1 THEN TRUE ELSE FALSE
           aux_qtdiaprt = INTE(GET-VALUE("qtdiaprt"))
           aux_indiaprt = INTE(GET-VALUE("indiaprt"))
           aux_inemiten = INTE(GET-VALUE("inemiten"))
           aux_vlrmulta = DECI(GET-VALUE("vlrmulta"))
           aux_vljurdia = DECI(GET-VALUE("vljurdia"))
           aux_flgaceit = IF INTE(GET-VALUE("flgaceit")) = 1 THEN TRUE ELSE FALSE
           aux_flgregis = INTE(GET-VALUE("flgregis"))
           aux_tpjurmor = INTE(GET-VALUE("tpjurmor"))
           aux_tpdmulta = INTE(GET-VALUE("tpdmulta"))

           /* Identifica o tipo de emissão (1 - Boleto / 2 - Carnê)*/
           aux_tpemitir = INTE(GET-VALUE("tpemitir"))
           aux_nrdiavct = INTE(GET-VALUE("nrdiavct"))


           /* Serasa */
           aux_flserasa = IF INTE(GET-VALUE("cvserasa")) = 1 THEN TRUE ELSE FALSE
           aux_qtdianeg = INTE(GET-VALUE("qtdianeg"))
    
           aux_inenvcip = INTE(GET-VALUE("inenvcip"))

           /* Aviso SMS */ 
           aux_inavisms = INTE(GET-VALUE("inavisms"))
           aux_insmsant = INTE(GET-VALUE("insmsant"))
           aux_insmsvct = INTE(GET-VALUE("insmsvct"))
           aux_insmspos = INTE(GET-VALUE("insmspos"))
           
           /* NPC */
           aux_flgregon = INTE(GET-VALUE("flgregon"))
           aux_inpagdiv = INTE(GET-VALUE("inpagdiv"))
           aux_vlminimo = DECI(GET-VALUE("vlminimo"))
           
           /* Configuracao do nome de emissao */
           aux_idrazfan = INTE(GET-VALUE("aux_idrazfan")).
    
    RUN sistema/internet/fontes/InternetBank4.p (INPUT aux_cdcooper,
                                                 INPUT aux_nrdconta,
                                                 INPUT aux_idseqttl,
                                                 INPUT aux_dtmvtolt,
                                                 INPUT aux_nrinssac,
                                                 INPUT aux_nmdavali,
                                                 INPUT aux_cdtpinav,
                                                 INPUT aux_nrinsava,
                                                 INPUT aux_nrcnvcob,
                                                 INPUT aux_dsdoccop,
                                                 INPUT aux_vltitulo,
                                                 INPUT aux_cddespec,
                                                 INPUT aux_cdcartei,
                                                 INPUT aux_nrctremp,
                                                 INPUT aux_dtdocmto,
                                                 INPUT aux_dtvencto,
                                                 INPUT aux_vldescto,
                                                 INPUT aux_vlabatim,
                                                 INPUT aux_qttitulo,
                                                 INPUT aux_cdtpvcto,
                                                 INPUT aux_qtdiavct,
                                                 INPUT aux_cdmensag,
                                                 INPUT aux_dsdinstr,
                                                 INPUT aux_dsinform,

                                                 INPUT aux_flgdprot,
                                                 INPUT aux_qtdiaprt,
                                                 INPUT aux_indiaprt,
                                                 INPUT aux_inemiten,
                                                 INPUT aux_vlrmulta,
                                                 INPUT aux_vljurdia,
                                                 INPUT aux_flgaceit,
                                                 INPUT (IF aux_flgregis = 1
                                                        THEN TRUE ELSE FALSE),
                                                 INPUT aux_tpjurmor,
                                                 INPUT aux_tpdmulta,

                                                 INPUT aux_tpemitir,
                                                 INPUT aux_nrdiavct,
                                                 INPUT aux_flserasa,
                                                 INPUT aux_qtdianeg,


                                                 /* Aviso SMS */ 
                                                 INPUT aux_inavisms,
                                                 INPUT aux_insmsant,
                                                 INPUT aux_insmsvct,
                                                 INPUT aux_insmspos,
                                                  
                                                 /* NPC */
                                                 INPUT aux_flgregon,
                                                 INPUT aux_inpagdiv,
                                                 INPUT aux_vlminimo,
                                                 
                                                 INPUT aux_idrazfan,
                                                  
                                                OUTPUT aux_dsmsgerr,
                                                OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK: 

            {&out} xml_operacao.dslinxml.
 
        END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao5:

    ASSIGN aux_indordem = INTE(GET-VALUE("indordem"))
           aux_nmdsacad = TRIM(GET-VALUE("nmdsacad"))
           aux_idsituac = INTE(GET-VALUE("idsituac"))
           aux_nrregist = INTE(GET-VALUE("nrregist"))
           aux_nriniseq = INTE(GET-VALUE("nriniseq"))
           aux_inidocto = DECI(GET-VALUE("inidocto"))
           aux_fimdocto = DECI(GET-VALUE("fimdocto"))
           aux_inivecto = DATE(GET-VALUE("inivecto"))
           aux_fimvecto = DATE(GET-VALUE("fimvecto"))
           aux_inipagto = DATE(GET-VALUE("inipagto"))
           aux_fimpagto = DATE(GET-VALUE("fimpagto"))
           aux_iniemiss = DATE(GET-VALUE("iniemiss"))
           aux_fimemiss = DATE(GET-VALUE("fimemiss"))
           aux_flgregis = INTE(GET-VALUE("flgregis"))
           aux_dsdoccop = TRIM(GET-VALUE("dsdoccop")).

    RUN sistema/internet/fontes/InternetBank5.p (INPUT aux_cdcooper,
                                                 INPUT aux_nrdconta,
                                                 INPUT aux_idseqttl,
                                                 INPUT aux_indordem,
                                                 INPUT aux_nmdsacad,
                                                 INPUT aux_idsituac,
                                                 INPUT aux_nrregist,
                                                 INPUT aux_nriniseq,
                                                 INPUT aux_inidocto,
                                                 INPUT aux_fimdocto,
                                                 INPUT aux_inivecto,
                                                 INPUT aux_fimvecto,
                                                 INPUT aux_inipagto,
                                                 INPUT aux_fimpagto,
                                                 INPUT aux_iniemiss,
                                                 INPUT aux_fimemiss,
                                                 INPUT aux_flgregis,
                                                 INPUT aux_dsdoccop,
                                                OUTPUT aux_dsmsgerr,
                                                OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    ELSE
        FOR EACH xml_operacao NO-LOCK: 

            {&out} xml_operacao.dslinxml.
            
        END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao6:

    RUN sistema/internet/fontes/InternetBank6.p (INPUT aux_cdcooper,
                                                 INPUT aux_nrdconta,
                                                 INPUT aux_idseqttl,
                                                 INPUT aux_dtmvtolt,
                                                 INPUT aux_dtmvtopr,
                                                 INPUT aux_inproces,
                                                OUTPUT aux_dsmsgerr,
                                                OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    ELSE
        FOR EACH xml_operacao NO-LOCK: 

            {&out} xml_operacao.dslinxml.
               
        END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao7:

    ASSIGN aux_anorefer = INTE(GET-VALUE("anorefer"))
           aux_tpinform = INTE(GET-VALUE("tpinform"))
           aux_nrperiod = INTE(GET-VALUE("nrperiod")).

    RUN sistema/internet/fontes/InternetBank7.p 
                                                (INPUT aux_cdcooper,
                                                 INPUT aux_nrdconta,
                                                 INPUT aux_idseqttl,
                                                 INPUT aux_dtmvtolt,
                                                 INPUT aux_anorefer,
                                                 INPUT aux_tpinform,
                                                 INPUT aux_nrperiod,
                                                OUTPUT aux_dsmsgerr,
                                                OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    ELSE
        DO:
            FIND FIRST xml_operacao NO-LOCK NO-ERROR.
     
            IF  AVAILABLE xml_operacao  THEN
                {&out} xml_operacao.dslinxml. 
        END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao8:

    RUN sistema/internet/fontes/InternetBank8.p 
                                                (INPUT aux_cdcooper,
                                                 INPUT aux_nrdconta,
                                                 INPUT aux_idseqttl,
                                                OUTPUT aux_dsmsgerr,
                                                OUTPUT TABLE xml_operacao8).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr aux_tgfimprg. 
            RETURN.
        END.

    FIND FIRST xml_operacao8 NO-LOCK NO-ERROR.
    
    IF  AVAILABLE xml_operacao8  THEN
        {&out} xml_operacao8.dscabini
               xml_operacao8.nmmesmd1
               xml_operacao8.vlsldmd1
               xml_operacao8.nmmesmd2
               xml_operacao8.vlsldmd2
               xml_operacao8.nmmesmd3
               xml_operacao8.vlsldmd3
               xml_operacao8.nmmesmd4
               xml_operacao8.vlsldmd4
               xml_operacao8.nmmesmd5
               xml_operacao8.vlsldmd5
               xml_operacao8.nmmesmd6
               xml_operacao8.vlsldmd6
               xml_operacao8.dscabfim.
               
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao9:

    DEF VAR aux_indebcre AS CHAR                                           NO-UNDO.

    ASSIGN aux_dtiniper = DATE(GET-VALUE("aux_dtiniper"))
           aux_dtfimper = DATE(GET-VALUE("aux_dtfimper"))
           aux_indebcre = GET-VALUE("aux_indebcre").

    RUN sistema/internet/fontes/InternetBank9.p 
                                                (INPUT aux_cdcooper,
                                                 INPUT aux_nrdconta,
                                                 INPUT aux_idseqttl,
                                                 INPUT aux_dtiniper,
                                                 INPUT aux_dtfimper,
                                                 INPUT aux_indebcre,
                                                OUTPUT aux_dsmsgerr,
                                                OUTPUT TABLE xml_operacao9).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr aux_tgfimprg. 
            RETURN.
        END.

    FOR EACH xml_operacao9 NO-LOCK: 

        {&out} xml_operacao9.dscabini 
               xml_operacao9.dtmvtolt 
               xml_operacao9.dshistor 
               xml_operacao9.nrdocmto 
               xml_operacao9.indebcre 
               xml_operacao9.vllanmto 
               xml_operacao9.dscabfim. 
    
    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao10:

    ASSIGN aux_dtiniper = DATE(GET-VALUE("aux_dtiniper"))
           aux_dtfimper = DATE(GET-VALUE("aux_dtfimper")).

    RUN sistema/internet/fontes/InternetBank10.p 
                                                (INPUT aux_cdcooper,
                                                 INPUT aux_nrdconta,
                                                 INPUT aux_idseqttl,
                                                 INPUT 07/20/2007,
                                                 INPUT aux_dtiniper,
                                                 INPUT aux_dtfimper,
                                                OUTPUT aux_dsmsgerr,
                                                OUTPUT TABLE xml_operacao10).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr aux_tgfimprg. 
            RETURN.
        END.

    FOR EACH xml_operacao10 NO-LOCK: 

        {&out} xml_operacao10.dscabini 
               xml_operacao10.dtmvtolt 
               xml_operacao10.dshistor 
               xml_operacao10.nrdocmto 
               xml_operacao10.indebcre 
               xml_operacao10.vllanmto 
               xml_operacao10.vlsldtot 
               xml_operacao10.dscabfim. 
    
    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao11:

    RUN sistema/internet/fontes/InternetBank11.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_flmobile,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr aux_tgfimprg. 
            RETURN.
        END.

    FOR EACH xml_operacao NO-LOCK: 

        {&out} xml_operacao.dslinxml.
                
    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao12:

    ASSIGN aux_dtiniper = DATE(GET-VALUE("aux_dtiniper"))
           aux_dtfimper = DATE(GET-VALUE("aux_dtfimper"))
           aux_inirgext = INTE(GET-VALUE("aux_inirgext"))
           aux_inirgchq = INTE(GET-VALUE("aux_inirgchq"))
           aux_inirgdep = INTE(GET-VALUE("aux_inirgdep"))
           aux_nrregist = INTE(GET-VALUE("aux_qtregpag"))
           aux_flglsext = LOGICAL(GET-VALUE("aux_flglsext"))
           aux_flglschq = LOGICAL(GET-VALUE("aux_flglschq"))
           aux_flglsdep = LOGICAL(GET-VALUE("aux_flglsdep"))
           aux_flglsfut = LOGICAL(GET-VALUE("aux_flglsfut")).
           
    RUN sistema/internet/fontes/InternetBank12.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtiniper,
                                                  INPUT aux_dtfimper,
                                                  INPUT aux_inirgext,
                                                  INPUT aux_inirgchq,
                                                  INPUT aux_inirgdep,
                                                  INPUT aux_nrregist,
                                                  INPUT aux_flglsext,
                                                  INPUT aux_flglschq,
                                                  INPUT aux_flglsdep,
                                                  INPUT aux_flglsfut,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK: 
        
            {&out} xml_operacao.dslinxml. 
               
        END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao13:

    RUN sistema/internet/fontes/InternetBank13.p 
                                                (INPUT aux_cdcooper,
                                                 INPUT aux_nrdconta,
                                                 INPUT aux_idseqttl,
                                                 INPUT aux_dtmvtolt,
                                                 INPUT aux_dtmvtopr,
                                                 INPUT aux_inproces,
                                                OUTPUT aux_dsmsgerr,
                                                OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr aux_tgfimprg. 
            RETURN.
        END.

    FOR EACH xml_operacao NO-LOCK: 

        {&out} xml_operacao.dslinxml.

    END.
                
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao14:

    ASSIGN aux_dtiniper = DATE(GET-VALUE("aux_dtiniper"))
           aux_dtfimper = DATE(GET-VALUE("aux_dtfimper"))
           aux_nrctremp = INTE(GET-VALUE("nrdoempr")).
           
    RUN sistema/internet/fontes/InternetBank14.p 
                                                (INPUT aux_cdcooper,
                                                 INPUT aux_nrdconta,
                                                 INPUT aux_idseqttl,
                                                 INPUT aux_dtmvtolt,
                                                 INPUT aux_dtmvtopr,
                                                 INPUT aux_inproces,
                                                 INPUT aux_dtiniper,
                                                 INPUT aux_dtfimper,
                                                 INPUT aux_nrctremp,
                                                OUTPUT aux_dsmsgerr,
                                                OUTPUT TABLE xml_operacao14a,
                                                OUTPUT TABLE xml_operacao14b).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr aux_tgfimprg. 
            RETURN.
        END.

    FIND FIRST xml_operacao14a NO-LOCK NO-ERROR. 

    IF  AVAILABLE xml_operacao14a  THEN
        {&out} xml_operacao14a.dscabini
               xml_operacao14a.dtmvtolt 
               xml_operacao14a.nrctremp
               xml_operacao14a.vlemprst
               xml_operacao14a.qtpreemp
               xml_operacao14a.qtprecal 
               xml_operacao14a.vlpreemp 
               xml_operacao14a.vlsdeved 
               xml_operacao14a.dslcremp
               xml_operacao14a.dsfinemp
               xml_operacao14a.nmprimtl
               xml_operacao14a.qtpreres
               xml_operacao14a.dsprodut
               xml_operacao14a.cddlinha
               xml_operacao14a.dsdlinha
               xml_operacao14a.cdfinali
               xml_operacao14a.dsfinali
               xml_operacao14a.tpemprst
               xml_operacao14a.dscabfim.
               
    FOR EACH xml_operacao14b NO-LOCK: 

        {&out} xml_operacao14b.dscabini 
               xml_operacao14b.dtmvtolt 
               xml_operacao14b.dshistor
               xml_operacao14b.nrdocmto 
               xml_operacao14b.vllanmto 
               xml_operacao14b.indebcre
               xml_operacao14b.vldsaldo
               xml_operacao14b.nrparepr 
               xml_operacao14b.vldebito
               xml_operacao14b.vlcredit
               xml_operacao14b.cdorigem
               xml_operacao14b.qtdiacal
               xml_operacao14b.vlrdtaxa
               xml_operacao14b.dscabfim.

    END.
                
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao15:

    ASSIGN aux_intipapl = INTE(GET-VALUE("tipo_aplicacao")).
    
    RUN sistema/internet/fontes/InternetBank15.p (INPUT aux_cdcooper,
                                                  INPUT 90, /*cdagenci*/
                                                  INPUT 900, /*nrdcaixa*/
                                                  INPUT "996",
                                                  INPUT 3, /*idorigem*/
                                                  INPUT "INTERNETBANK",
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtolt,
                                                  INPUT aux_intipapl,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).
                                                 
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.
                   
        END. 
        
    {&out} aux_tgfimprg.        

END PROCEDURE.

PROCEDURE proc_operacao16:

    ASSIGN aux_nraplica = INTE(GET-VALUE("nraplica"))
           aux_intipapl = INTE(GET-VALUE("tipo_aplicacao")).

    RUN sistema/internet/fontes/InternetBank16.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtolt,
                                                  INPUT aux_nraplica,
                                                  INPUT aux_intipapl,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).
                                                 
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.
                   
        END. 
        
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao17:

    ASSIGN aux_nrctrrpp = INTE(GET-VALUE("nrctrrpp"))
           aux_dtiniper = DATE(GET-VALUE("aux_dtiniper"))
           aux_dtfimper = DATE(GET-VALUE("aux_dtfimper")).

    RUN sistema/internet/fontes/InternetBank17.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtiniper,
                                                  INPUT aux_dtfimper,
                                                  INPUT aux_nrctrrpp,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    ELSE
        FOR EACH xml_operacao NO-LOCK: 
    
            {&out} xml_operacao.dslinxml.
                    
        END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao18:

    ASSIGN aux_vldfrase = INTE(GET-VALUE("vldfrase"))
           aux_inaceblq = INTE(GET-VALUE("inaceblq"))
           aux_cdsennew = GET-VALUE("cdsennew")
           aux_cdsenrep = GET-VALUE("cdsenrep")
           aux_dssennew = GET-VALUE("dssennew")
           aux_dssenrep = GET-VALUE("dssenrep")
           aux_dsorigip = GET-VALUE("dsorigip")
           aux_indlogin = INTE(GET-VALUE("indlogin")).

    IF  aux_flgcript  THEN /** Utiliza criptografia **/
        DO:
            RUN sistema/generico/procedures/b1wgencrypt.p PERSISTENT 
                    SET h-b1wgencrypt (INPUT aux_nrdconta).
            
            ASSIGN aux_cdsennew = DYNAMIC-FUNCTION("decriptar" IN h-b1wgencrypt,
                                                   INPUT aux_cdsennew,
                                                   INPUT aux_nrdconta).
        
            ASSIGN aux_cdsenrep = DYNAMIC-FUNCTION("decriptar" IN h-b1wgencrypt,
                                                   INPUT aux_cdsenrep,
                                                   INPUT aux_nrdconta).
        
            ASSIGN aux_dssennew = DYNAMIC-FUNCTION("decriptar" IN h-b1wgencrypt,
                                                   INPUT aux_dssennew,
                                                   INPUT aux_nrdconta).
        
            ASSIGN aux_dssenrep = DYNAMIC-FUNCTION("decriptar" IN h-b1wgencrypt,
                                                   INPUT aux_dssenrep,
                                                   INPUT aux_nrdconta).
        
            DELETE PROCEDURE h-b1wgencrypt.
        END.

    RUN sistema/internet/fontes/InternetBank18.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_nrcpfope,
                                                  INPUT aux_cddsenha,
                                                  INPUT aux_cdsennew,
                                                  INPUT aux_cdsenrep,
                                                  INPUT aux_dssenweb,
                                                  INPUT aux_dssennew,
                                                  INPUT aux_dssenrep,
                                                  INPUT aux_vldfrase,
                                                  INPUT aux_inaceblq,
                                                  INPUT aux_nripuser,
                                                  INPUT aux_dsorigip,
                                                  INPUT aux_flmobile,
                                                  INPUT IF NOT aux_flgcript THEN aux_indlogin ELSE 0,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).
                
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr aux_tgfimprg.
            
            RETURN "NOK".
        END.
	ELSE
	    FOR EACH xml_operacao NO-LOCK:
    
            {&out} xml_operacao.dslinxml. 
                
        END.
            
    {&out} aux_tgfimprg.

	RETURN "OK".

END PROCEDURE.

PROCEDURE proc_operacao19:

    ASSIGN aux_nrcpfcgc = DECI(GET-VALUE("nrcpfcgc"))
           aux_nmdsacad = GET-VALUE("nmdsacad")
           aux_flgvalid = LOGICAL(GET-VALUE("flgvalid")).
                   
    RUN sistema/internet/fontes/InternetBank19.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_nrcpfcgc,
                                                  INPUT aux_nmdsacad,
                                                  INPUT aux_flgvalid,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    ELSE
        FOR EACH xml_operacao NO-LOCK:
    
            {&out} xml_operacao.dslinxml.
        
        END.
            
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao20:

    ASSIGN aux_nmdsacad = GET-VALUE("sacado")
           aux_cdtpinsc = INTE(GET-VALUE("tpins_sacado")) 
           aux_nrinssac = GET-VALUE("nrins_sacado") 
           aux_dsendsac = GET-VALUE("endereco")
           aux_nrendsac = INTE(GET-VALUE("nro_endereco"))
           aux_complend = GET-VALUE("complemento")
           aux_nmbaisac = GET-VALUE("bairro")
           aux_nrcepsac = INTE(GET-VALUE("cep"))
           aux_nmcidsac = GET-VALUE("cidade")
           aux_cdufsaca = GET-VALUE("estado")
           aux_idrotina = INTE(GET-VALUE("rotina"))
           aux_cdsitsac = INTE(GET-VALUE("situacao"))
           aux_tpinstru = INTE(GET-VALUE("tpinstru"))
           aux_dsdemail = GET-VALUE("dsdemail")
           aux_nrcelsac = DECI(GET-VALUE("nrcelsac")). 
                   
    RUN sistema/internet/fontes/InternetBank20.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_nmdsacad,
                                                  INPUT aux_cdtpinsc,
                                                  INPUT DECI(aux_nrinssac),
                                                  INPUT aux_dsendsac,
                                                  INPUT aux_nrendsac,
                                                  INPUT aux_complend,
                                                  INPUT aux_nmbaisac,
                                                  INPUT aux_nrcepsac,
                                                  INPUT aux_nmcidsac,
                                                  INPUT aux_cdufsaca,
                                                  INPUT aux_cdsitsac,
                                                  INPUT aux_dtmvtolt,
                                                  INPUT aux_idrotina,
                                                  INPUT aux_tpinstru,
                                                  INPUT aux_dsdemail,
                                                  INPUT aux_nrcelsac,
                                                 OUTPUT aux_dsmsgerr).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao21:

    ASSIGN aux_idconchq = INTE(GET-VALUE("idconchq"))
           aux_dtiniper = DATE(GET-VALUE("dtiniper"))
           aux_dtfimper = DATE(GET-VALUE("dtfimper"))
           aux_nriniseq = INTE(GET-VALUE("nriniseq"))
           aux_nrregist = INTE(GET-VALUE("nrregist")).

    RUN sistema/internet/fontes/InternetBank21.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_idconchq,
                                                  INPUT aux_dtiniper,
                                                  INPUT aux_dtfimper,
                                                  INPUT aux_nriniseq,
                                                  INPUT aux_nrregist,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).
                                          
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
            
            {&out} xml_operacao.dslinxml. 
            
        END.
        
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao22:

    ASSIGN aux_tpoperac = INTE(GET-VALUE("aux_tpoperac"))
           aux_cdtiptra = INTE(GET-VALUE("aux_cdtiptra"))
           aux_cddbanco = INTE(GET-VALUE("aux_cddbanco"))
           aux_cdispbif = INTE(GET-VALUE("aux_cdispbif"))
           aux_cdageban = INTE(GET-VALUE("aux_cdageban"))
           aux_nrctatrf = DECI(GET-VALUE("aux_nrctatrf"))
           aux_nmtitula = GET-VALUE("aux_nmtitula")
           aux_nrcpfcgc = DECI(GET-VALUE("aux_nrcpfcgc"))
           aux_inpessoa = INTE(GET-VALUE("aux_inpessoa"))
           aux_intipcta = INTE(GET-VALUE("aux_intipcta"))
           aux_idagenda = INTE(GET-VALUE("aux_idagenda"))
           aux_dtmvtopg = IF  aux_idagenda = 1  OR   /** Pagto data corrente **/
                              aux_idagenda = 3  THEN /** Agendam. recorrente **/
                              aux_dtmvtocd
                          ELSE
                              DATE(GET-VALUE("aux_dtmvtopg"))
           aux_vllanmto = DECI(GET-VALUE("aux_vllanmto"))
           aux_cdfinali = INTE(GET-VALUE("aux_cdfinali"))
           aux_dstransf = GET-VALUE("aux_dstransf")
           aux_ddagenda = INTE(GET-VALUE("aux_ddagenda"))
           aux_qtmesagd = INTE(GET-VALUE("aux_qtmesagd"))
           aux_dtinicio = GET-VALUE("aux_dtinicio")
           aux_lsdatagd = GET-VALUE("aux_lsdatagd")
           aux_dshistor = GET-VALUE("aux_dshistor")
		   aux_gravafav = INTE(GET-VALUE("aux_gravafav")).

	IF  LENGTH(aux_dtinicio) = 10 THEN
	    ASSIGN aux_dtinicio = SUBSTR(aux_dtinicio,4).

    IF  GET-VALUE("aux_flgexecu") <> ""  THEN
        ASSIGN aux_flgexecu = LOGICAL(GET-VALUE("aux_flgexecu")).

    /* Condicao temporaria ate que seja corrigido o problema 1. do chamado
       356737 dentro do app mobile */
    IF  aux_flmobile       AND   /* App Mobile                 */
        aux_tpoperac <> 4  AND   /* Somente Transferencias     */
        NOT aux_flgexecu   AND   /* Validacao da Transferencia */
        aux_idagenda = 1   THEN  /* Debito Nesta Data          */
        ASSIGN aux_dshistor = TRIM(GET-VALUE("aux_dtmvtopg")).
    
    RUN sistema/internet/fontes/InternetBank22.p (INPUT aux_cdcooper,
                                                  INPUT aux_nmrescop,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_nrcpfope,
                                                  INPUT aux_dtmvtocd,
                                                  INPUT aux_tpoperac,
                                                  INPUT aux_cdtiptra,
                                                  INPUT aux_cddbanco,
                                                  INPUT aux_cdispbif,
                                                  INPUT aux_cdageban,
                                                  INPUT aux_nrctatrf,
                                                  INPUT aux_nmtitula,
                                                  INPUT aux_nrcpfcgc,
                                                  INPUT aux_inpessoa,
                                                  INPUT aux_intipcta,
                                                  INPUT aux_idagenda,
                                                  INPUT aux_dtmvtopg,
                                                  INPUT aux_vllanmto,
                                                  INPUT aux_cdfinali,
                                                  INPUT aux_dstransf,
                                                  INPUT aux_ddagenda,
                                                  INPUT aux_qtmesagd,
                                                  INPUT aux_dtinicio,
                                                  INPUT aux_lsdatagd,
                                                  INPUT aux_flgexecu,
                                                  INPUT aux_gravafav,
                                                  INPUT aux_dshistor,
                                                  INPUT aux_flmobile,
												  INPUT aux_nripuser,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).
           
    IF  aux_dsmsgerr = ""  THEN
        FOR EACH xml_operacao NO-LOCK:
        
                {&out} xml_operacao.dslinxml.

        END.
    ELSE
        {&out} aux_dsmsgerr.
        
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao23:

    ASSIGN aux_tppeslst = INTE(GET-VALUE("aux_tppeslst"))
           aux_tpoperac = INTE(GET-VALUE("aux_tpoperac"))
           aux_intipdif = INTE(GET-VALUE("aux_intipdif"))
           aux_nmtitpes = GET-VALUE("aux_nmtitpes")
           aux_flgpesqu = LOGICAL(GET-VALUE("aux_flgpesqu")).

    RUN sistema/internet/fontes/InternetBank23.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtocd,
                                                  INPUT aux_tppeslst,
                                                  INPUT aux_tpoperac,
                                                  INPUT aux_intipdif,
                                                  INPUT aux_nrcpfope,
                                                  INPUT aux_nmtitpes,
                                                  INPUT aux_flgpesqu,
                                                  INPUT aux_flmobile,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).
                    
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.
                           
        END.
        
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao24:

    RUN sistema/internet/fontes/InternetBank24.p 
                                                (INPUT aux_cdcooper,
                                                 INPUT aux_nrdconta,
                                                 INPUT aux_idseqttl,
                                                 INPUT aux_dtmvtolt,
                                                OUTPUT aux_dsmsgerr,
                                                OUTPUT TABLE xml_operacao24). 
                    
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao24 NO-LOCK:
                
            {&out} xml_operacao24.dscabini 
                   xml_operacao24.dtrefere
                   xml_operacao24.dsdpagto 
                   xml_operacao24.dsholeri                 
                   xml_operacao24.idtipfol
                   xml_operacao24.nrdrowid
                   xml_operacao24.dscabfim.

        END.
                
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao25:

    ASSIGN aux_dtiniper = DATE(GET-VALUE("aux_dtinipro"))
           aux_dtfimper = DATE(GET-VALUE("aux_dtfimpro"))
           aux_dsprotoc = GET-VALUE("aux_dsprotoc")
           aux_nriniseq = INTE(GET-VALUE("aux_iniconta"))
           aux_nrregist = INTE(GET-VALUE("aux_nrregist")).

    RUN sistema/internet/fontes/InternetBank25.p 
                                                (INPUT aux_cdcooper,
                                                 INPUT aux_nrdconta,
                                                 INPUT aux_idseqttl,
                                                 INPUT aux_dtmvtolt,
                                                 INPUT aux_dtiniper,
                                                 INPUT aux_dtfimper,
                                                 INPUT aux_dsprotoc,
                                                 INPUT aux_nriniseq,
                                                 INPUT aux_nrregist,
                                                OUTPUT aux_dsmsgerr,
                                                OUTPUT TABLE xml_operacao25).
                                                 
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr aux_tgfimprg.
            RETURN.
        END.
        
    {&out} "<PROTOCOLOS>".
    
    FOR EACH xml_operacao25 NO-LOCK:

        {&out} xml_operacao25.dscabini xml_operacao25.dtmvtolt
               xml_operacao25.dttransa xml_operacao25.hrautent 
               xml_operacao25.vldocmto xml_operacao25.nrdocmto 
               xml_operacao25.dsinfor1 xml_operacao25.dsinfor2 
               xml_operacao25.dsinfor3 xml_operacao25.dsprotoc 
               xml_operacao25.qttotreg xml_operacao25.cdtippro
               xml_operacao25.dscedent xml_operacao25.cdagenda
               xml_operacao25.nrseqaut xml_operacao25.nmprepos
               xml_operacao25.nrcpfpre xml_operacao25.nmoperad
               xml_operacao25.nrcpfope xml_operacao25.cdbcoctl
               xml_operacao25.cdagectl xml_operacao25.cdagesic
               xml_operacao25.dscabfim.
    
    END.
    
    {&out} "</PROTOCOLOS>" aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao26:

    ASSIGN aux_idtitdda = DECI(GET-VALUE("aux_idtitdda"))
           aux_idtpdpag = INTE(GET-VALUE("aux_idtpdpag"))
           aux_lindigi1 = DECI(GET-VALUE("aux_lindigi1"))
           aux_lindigi2 = DECI(GET-VALUE("aux_lindigi2"))
           aux_lindigi3 = DECI(GET-VALUE("aux_lindigi3"))
           aux_lindigi4 = DECI(GET-VALUE("aux_lindigi4"))
           aux_lindigi5 = DECI(GET-VALUE("aux_lindigi5"))
           aux_cdbarras = GET-VALUE("aux_cdbarras")
           aux_vllanmto = DECI(GET-VALUE("aux_vllanmto"))
           aux_idagenda = INTE(GET-VALUE("aux_idagenda"))
           aux_dscedent = GET-VALUE("aux_dscedent")
           aux_dtmvtopg = IF  aux_idagenda = 1  THEN /** Pagto data corrente **/
                              aux_dtmvtocd
                          ELSE
                              DATE(GET-VALUE("aux_dtmvtopg"))
           aux_cdctrlcs = GET-VALUE("aux_cdctrlcs")
           aux_vlapagar = DECI(GET-VALUE("aux_vlapagar")).
    
    RUN sistema/internet/fontes/InternetBank26.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtocd,
                                                  INPUT aux_idtitdda,
                                                  INPUT aux_idtpdpag,
                                                  INPUT aux_lindigi1,
                                                  INPUT aux_lindigi2,
                                                  INPUT aux_lindigi3,
                                                  INPUT aux_lindigi4,
                                                  INPUT aux_lindigi5,
                                                  INPUT aux_cdbarras,   
                                                  INPUT aux_vllanmto,
                                                  INPUT aux_idagenda,
                                                  INPUT aux_dtmvtopg,
                                                  INPUT aux_dscedent,
                                                  INPUT aux_nrcpfope,
                                                  INPUT aux_flmobile,
                                                  INPUT aux_cdctrlcs,
                                                  INPUT aux_vlapagar,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao26).
    
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        DO:
            FIND FIRST xml_operacao26 NO-LOCK NO-ERROR.
    
            IF  AVAILABLE xml_operacao26  THEN
                {&out} xml_operacao26.dscabini xml_operacao26.lindigi1 
                       xml_operacao26.lindigi2 xml_operacao26.lindigi3 
                       xml_operacao26.lindigi4 xml_operacao26.lindigi5 
                       xml_operacao26.cdbarras xml_operacao26.nmconban 
                       xml_operacao26.dtmvtopg xml_operacao26.vlrdocum 
                       xml_operacao26.cdseqfat xml_operacao26.nrdigfat 
                       xml_operacao26.nrcnvcob xml_operacao26.nrboleto 
                       xml_operacao26.nrctacob xml_operacao26.insittit 
                       xml_operacao26.intitcop xml_operacao26.nrdctabb 
                       xml_operacao26.dttransa xml_operacao26.dscabfim.
        END.

    {&out} aux_tgfimprg.
    
END PROCEDURE.

PROCEDURE proc_operacao27:

    ASSIGN aux_idtitdda = DECI(GET-VALUE("aux_idtitdda"))
           aux_idagenda = INTE(GET-VALUE("aux_idagenda"))
           aux_idtpdpag = INTE(GET-VALUE("aux_idtpdpag"))
           aux_lindigi1 = DECI(GET-VALUE("aux_lindigi1"))
           aux_lindigi2 = DECI(GET-VALUE("aux_lindigi2"))
           aux_lindigi3 = DECI(GET-VALUE("aux_lindigi3"))
           aux_lindigi4 = DECI(GET-VALUE("aux_lindigi4"))
           aux_lindigi5 = DECI(GET-VALUE("aux_lindigi5"))
           aux_cdbarras = GET-VALUE("aux_cdbarras")
           aux_dscedent = GET-VALUE("aux_dscedent")
           aux_dtmvtopg = DATE(GET-VALUE("aux_dtmvtopg"))
           aux_vllanmto = DECI(GET-VALUE("aux_vllanmto"))
           aux_dtvencto = DATE(GET-VALUE("aux_dtvencto"))
           aux_vlpagame = DECI(GET-VALUE("aux_vlpagame"))
           aux_cdseqfat = DECI(GET-VALUE("aux_cdseqfat"))
           aux_nrdigfat = INTE(GET-VALUE("aux_nrdigfat"))
           aux_nrcnvcob = DECI(GET-VALUE("aux_nrcnvcob"))
           aux_nrboleto = DECI(GET-VALUE("aux_nrboleto"))
           aux_nrctacob = INTE(GET-VALUE("aux_nrctacob"))
           aux_insittit = INTE(GET-VALUE("aux_insittit"))
           aux_intitcop = INTE(GET-VALUE("aux_intitcop"))
           aux_nrdctabb = INTE(GET-VALUE("aux_nrdctabb"))
           aux_vlapagar = DECI(GET-VALUE("aux_vlapagar"))
           aux_versaldo = INTE(GET-VALUE("aux_versaldo"))
           aux_tpcptdoc = INTE(GET-VALUE("aux_tpcptdoc"))
           aux_cdctrlcs = GET-VALUE("aux_cdctrlcs").

    RUN sistema/internet/fontes/InternetBank27.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtocd,
                                                  INPUT aux_idtitdda,
                                                  INPUT aux_idagenda,
                                                  INPUT aux_idtpdpag,
                                                  INPUT aux_lindigi1,
                                                  INPUT aux_lindigi2,
                                                  INPUT aux_lindigi3, 
                                                  INPUT aux_lindigi4,
                                                  INPUT aux_lindigi5,
                                                  INPUT aux_cdbarras,
                                                  INPUT aux_dscedent, 
                                                  INPUT aux_dtmvtopg,
                                                  INPUT aux_dtvencto,
                                                  INPUT aux_vllanmto,
                                                  INPUT aux_vlpagame, 
                                                  INPUT aux_cdseqfat, 
                                                  INPUT aux_nrdigfat,
                                                  INPUT aux_nrcnvcob,
                                                  INPUT aux_nrboleto,
                                                  INPUT aux_nrctacob,
                                                  INPUT aux_insittit,
                                                  INPUT aux_intitcop, 
                                                  INPUT aux_nrdctabb,
                                                  INPUT aux_nrcpfope,
                                                  INPUT aux_vlapagar,
                                                  INPUT aux_versaldo,
                                                  INPUT aux_flmobile,
                                                  INPUT aux_tpcptdoc,
                                                  INPUT aux_cdctrlcs,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT aux_msgofatr,
                                                 OUTPUT xml_cdempcon,
                                                 OUTPUT xml_cdsegmto,
                                                 OUTPUT xml_dsprotoc).
                                                 
    {&out} aux_dsmsgerr aux_msgofatr xml_cdempcon xml_cdsegmto xml_dsprotoc aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao28:

    RUN sistema/internet/fontes/InternetBank28.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtocd,
                                                  INPUT aux_nrcpfope,
                                                  INPUT aux_flmobile,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr aux_tgfimprg.
            RETURN.
        END.

    FOR EACH xml_operacao NO-LOCK:
    
        {&out} xml_operacao.dslinxml.
        
    END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao29:
    
    ASSIGN aux_dtiniper = DATE(GET-VALUE("aux_dtiniper"))
           aux_dtfimper = DATE(GET-VALUE("aux_dtfimper")).

    RUN sistema/internet/fontes/InternetBank29.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtolt,
                                                  INPUT aux_dtiniper,
                                                  INPUT aux_dtfimper,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr aux_tgfimprg. 
            RETURN.
        END.

    FOR EACH xml_operacao NO-LOCK: 

        {&out} xml_operacao.dslinxml. 

    END.

    {&out} aux_tgfimprg.

END PROCEDURE.


PROCEDURE proc_operacao30:

    RUN sistema/internet/fontes/InternetBank30.p 
                                         (INPUT aux_cdcooper,
                                          INPUT aux_nrdconta,
                                          INPUT aux_idseqttl,
                                          INPUT aux_dtmvtolt,
                                          INPUT aux_flmobile,
                                         OUTPUT aux_dsmsgerr,
                                         OUTPUT TABLE xml_operacao30).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr aux_tgfimprg. 
            RETURN.
        END.

    FOR EACH xml_operacao30 NO-LOCK: 

        {&out} xml_operacao30.dscabini 
               xml_operacao30.nmextcon 
               xml_operacao30.hhoraini 
               xml_operacao30.hhorafim 
               xml_operacao30.hhoracan 
               xml_operacao30.dscabfim. 
    
    END.

    {&out} aux_tgfimprg.
    
END PROCEDURE.

PROCEDURE proc_operacao31:

    RUN sistema/internet/fontes/InternetBank31.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtocd,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 

    FOR EACH xml_operacao NO-LOCK: 

      {&out} xml_operacao.dslinxml.
      
    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao32:

    ASSIGN aux_vlprepla = DECI(GET-VALUE("aux_vlprepla"))
           aux_cdtipcor = INTE(GET-VALUE("aux_cdtipcor"))
           aux_vlcorfix = DECI(GET-VALUE("aux_vlcorfix"))
           aux_flgpagto = IF  GET-VALUE("aux_flgpagto") = "Folha"  THEN
                              TRUE
                          ELSE
                              FALSE
           aux_qtpremax = INTE(GET-VALUE("aux_qtpremax"))
           aux_dtdpagto = DATE(GET-VALUE("aux_dtdpagto"))
           aux_flcadast = INTE(GET-VALUE("aux_flcadast"))
           aux_flcancel = IF GET-VALUE("aux_flcancel") = "yes" THEN
                              TRUE
                          ELSE
                              FALSE.

    RUN sistema/internet/fontes/InternetBank32.p 
                                         (INPUT aux_cdcooper,
                                          INPUT aux_nrdconta,
                                          INPUT aux_idseqttl,
                                          INPUT aux_dtmvtocd,
                                          INPUT aux_vlprepla,
                                          INPUT aux_cdtipcor,
                                          INPUT aux_vlcorfix,
                                          INPUT aux_flgpagto,
                                          INPUT aux_qtpremax,
                                          INPUT aux_dtdpagto,
                                          INPUT aux_flcadast,
                                          INPUT aux_flcancel,
                                         OUTPUT aux_dsmsgerr).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr. 
        END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao33:

    RUN sistema/internet/fontes/InternetBank33.p 
                                         (INPUT aux_cdcooper,
                                          INPUT aux_nrdconta,
                                          INPUT aux_idseqttl,
                                         OUTPUT aux_dsmsgerr).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr. 
        END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao34:

    RUN sistema/internet/fontes/InternetBank34.p 
                                         (INPUT aux_cdcooper,
                                          INPUT aux_nrdconta,
                                          INPUT aux_idseqttl,
                                         OUTPUT aux_dsmsgerr,
                                         OUTPUT TABLE xml_operacao34).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr. 
        END.

    FIND FIRST xml_operacao34 NO-LOCK NO-ERROR.
    
    IF  AVAILABLE xml_operacao34  THEN
        {&out} xml_operacao34.dscabini xml_operacao34.cdtippto
               xml_operacao34.dtmvtolt xml_operacao34.dttransa
               xml_operacao34.hrautent xml_operacao34.vldocmto
               xml_operacao34.nrdocmto xml_operacao34.dsinfor1
               xml_operacao34.dsinfor2 xml_operacao34.dsinfor3
               xml_operacao34.dsprotoc xml_operacao34.dscabfim.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao36:

    ASSIGN aux_dtiniper = DATE(GET-VALUE("aux_dtiniper"))
           aux_dtfimper = DATE(GET-VALUE("aux_dtfimper"))
           aux_nrcnvcob = INTE(GET-VALUE("aux_nrcnvcob")).

    RUN sistema/internet/fontes/InternetBank36.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtiniper,
                                                  INPUT aux_dtfimper,
                                                  INPUT aux_nrcnvcob,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao36).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        DO:
          IF TRIM(aux_dsmsgerr) <> "" THEN
             {&out} aux_dsmsgerr.

        FOR EACH xml_operacao36 NO-LOCK:
        
            {&out} xml_operacao36.dscabini
                   xml_operacao36.cdseqlin
                   xml_operacao36.dsdlinha
                   xml_operacao36.dscabfim.

        END.  
        END.
        
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao37:

    RUN sistema/internet/fontes/InternetBank37.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                 OUTPUT TABLE xml_operacao37).

    FOR EACH xml_operacao37 NO-LOCK:
        
        {&out} xml_operacao37.dscabini
               xml_operacao37.nrcnvcob
               xml_operacao37.dscabfim.

    END.
        
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao38:

    ASSIGN aux_dtiniper = DATE(GET-VALUE("aux_dtageini"))
           aux_dtfimper = DATE(GET-VALUE("aux_dtagefim"))
           aux_insitlau = INTE(GET-VALUE("aux_insitlau"))
           aux_nriniseq = INTE(GET-VALUE("aux_iniconta"))
           aux_nrregist = INTE(GET-VALUE("aux_nrregist")).

    RUN sistema/internet/fontes/InternetBank38.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtocd,
                                                  INPUT aux_dtiniper,
                                                  INPUT aux_dtfimper,
                                                  INPUT aux_insitlau,
                                                  INPUT aux_nriniseq,
                                                  INPUT aux_nrregist,
                                                  INPUT aux_flmobile,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao38).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao38 NO-LOCK:
        
            {&out} xml_operacao38.dscabini
                   xml_operacao38.nmprimtl
                   xml_operacao38.dtmvtage
                   xml_operacao38.dtmvtopg
                   xml_operacao38.vllanaut
                   xml_operacao38.dttransa
                   xml_operacao38.hrtransa
                   xml_operacao38.nrdocmto
                   xml_operacao38.dssitlau
                   xml_operacao38.dslindig
                   xml_operacao38.dscedent
                   xml_operacao38.dtvencto
                   xml_operacao38.nrctadst
                   xml_operacao38.cdtiptra
                   xml_operacao38.dstiptra
                   xml_operacao38.incancel
                   xml_operacao38.qttotage
                   xml_operacao38.nmprepos
                   xml_operacao38.nrcpfpre
                   xml_operacao38.nmoperad
                   xml_operacao38.nrcpfope
                   xml_operacao38.dsageban 
				   xml_operacao38.cdageban
                   
                   /* DARF/DAS */
                   xml_operacao38.tpcaptur
                   xml_operacao38.dstipcat
                   xml_operacao38.dsidpgto
                   xml_operacao38.dsnomfon
                   xml_operacao38.vlprinci
                   xml_operacao38.vlrmulta
                   xml_operacao38.vlrjuros
                   xml_operacao38.vlrtotal
                   xml_operacao38.vlrrecbr
                   xml_operacao38.vlrperce
                   xml_operacao38.cdreceit
                   xml_operacao38.nrrefere                   
				   xml_operacao38.dtagenda
                   xml_operacao38.dtperiod
                   xml_operacao38.dtvendrf
                   xml_operacao38.nrcpfcgc                   
                   
                   /*Recarga de Celular */
                   xml_operacao38.nrddd
                   xml_operacao38.nrcelular 
                   xml_operacao38.nmoperadora 
                   
                   /* GPS */
                   xml_operacao38.gpscddpagto
                   xml_operacao38.gpsdscompet
                   xml_operacao38.gpscdidenti
                   xml_operacao38.gpsvlrdinss
                   xml_operacao38.gpsvlrouent
                   xml_operacao38.gpsvlrjuros
                   
                   xml_operacao38.dscabfim.
				   
        END.
        
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao39:

    ASSIGN aux_dtmvtage = DATE(GET-VALUE("aux_dtmvtage"))
           aux_nrdocmto = INTE(GET-VALUE("aux_nrdocmto"))
           aux_cdtiptra = INTE(GET-VALUE("aux_cdtiptra"))
           aux_idlancto = DECI(GET-VALUE("aux_idlancto")).

    RUN sistema/internet/fontes/InternetBank39.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtocd,
                                                  INPUT aux_dtmvtage,
                                                  INPUT aux_nrdocmto,
                                                  INPUT aux_idlancto,
                                                  INPUT aux_flmobile,
                                                  INPUT aux_cdtiptra,
                                                  INPUT aux_nrcpfope,
                                                 OUTPUT aux_dsmsgerr).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao40:

    ASSIGN aux_indtrans = INTE(GET-VALUE("indtrans"))
           aux_nrcnvcob = INTE(GET-VALUE("nrconven"))
           aux_nrdocmto = INTE(GET-VALUE("nrdocmto")).

    RUN sistema/internet/fontes/InternetBank40.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtocd,
                                                  INPUT aux_indtrans,
                                                  INPUT aux_nrcnvcob,
                                                  INPUT aux_nrdocmto,
                                                 OUTPUT aux_dsmsgerr).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao41:

    ASSIGN aux_dsurlace = GET-VALUE("dsurlace").
    
    RUN sistema/internet/fontes/InternetBank41.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_nrcpfope,
                                                  INPUT aux_dsurlace,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.

        END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao42:

    RUN sistema/internet/fontes/InternetBank42.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        DO:
            FOR EACH xml_operacao NO-LOCK: 
    
                {&out} xml_operacao.dslinxml. 
                
            END.
        END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao43:

    ASSIGN aux_desdacao = GET-VALUE("desdacao")
           aux_nmoperad = GET-VALUE("nmoperad")
           aux_nrcpfope = DECI(GET-VALUE("nrcpfope"))
           aux_dsdemail = GET-VALUE("dsdemail")
           aux_dsdcargo = GET-VALUE("dsdcargo")
           aux_flgsitop = LOGICAL(GET-VALUE("flgsitop"))
           aux_cdditens = GET-VALUE("cdditens")
		   aux_geraflux = INTE(GET-VALUE("geraflux"))
           aux_vllbolet = DEC(GET-VALUE("vllbolet"))
           aux_vllimtrf = DEC(GET-VALUE("vllimtrf"))
           aux_vllimted = DEC(GET-VALUE("vllimted"))
           aux_vllimvrb = DEC(GET-VALUE("vllimvrb"))
           aux_vllimflp = DEC(GET-VALUE("vllimflp")).

    RUN sistema/internet/fontes/InternetBank43.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_nrcpfope,
                                                  INPUT aux_desdacao,
                                                  INPUT aux_nmoperad,
                                                  INPUT aux_dsdemail,
                                                  INPUT aux_dsdcargo,
                                                  INPUT aux_flgsitop,
												  INPUT aux_geraflux,
                                                  INPUT aux_cdditens,
                                                  INPUT aux_vllbolet,
                                                  INPUT aux_vllimtrf,
                                                  INPUT aux_vllimted,
                                                  INPUT aux_vllimvrb,
                                                  INPUT aux_vllimflp,
                                                 OUTPUT aux_dsmsgerr).

    {&out} aux_dsmsgerr aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao44:

    RUN sistema/internet/fontes/InternetBank44.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
            
            {&out} xml_operacao.dslinxml.
            
        END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao45:

    ASSIGN aux_flgtpenc = LOGICAL(GET-VALUE("flgtpenc"))
           aux_dsendere = GET-VALUE("dsendere")
           aux_nrendere = INTE(GET-VALUE("nrendere"))
           aux_complend = GET-VALUE("complend")
           aux_nrdoapto = INTE(GET-VALUE("nrdoapto")) 
           aux_cddbloco = GET-VALUE("cddbloco")       
           aux_nrcepend = INTE(GET-VALUE("nrcepend"))
           aux_nrcxapst = INTE(GET-VALUE("nrcxapst"))
           aux_nmbairro = GET-VALUE("nmbairro")
           aux_nmcidade = GET-VALUE("nmcidade")
           aux_cdufende = GET-VALUE("cdufende")
           aux_cdseqinc = INTE(GET-VALUE("cdseqinc"))
           aux_tpendass = INTE(GET-VALUE("tpendass")).
           
    RUN sistema/internet/fontes/InternetBank45.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_flgtpenc,
                                                  INPUT aux_dsendere,
                                                  INPUT aux_nrendere,
                                                  INPUT aux_complend,
                                                  INPUT aux_nrdoapto,
                                                  INPUT aux_cddbloco,
                                                  INPUT aux_nrcepend,
                                                  INPUT aux_nrcxapst,
                                                  INPUT aux_nmbairro,
                                                  INPUT aux_nmcidade,
                                                  INPUT aux_cdufende,
                                                  INPUT aux_cdseqinc,
                                                  INPUT aux_tpendass,
                                                 OUTPUT aux_dsmsgerr).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao46:

    ASSIGN aux_cddopcao = GET-VALUE("cddopcao")
           aux_nrdrowid = GET-VALUE("nrdrowid").

    RUN sistema/internet/fontes/InternetBank46.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_cddopcao,
                                                  INPUT aux_nrdrowid,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.

        END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao47:

    ASSIGN aux_cddopcao = GET-VALUE("cddopcao")
           aux_nrdrowid = GET-VALUE("nrdrowid").

    RUN sistema/internet/fontes/InternetBank47.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_cddopcao,
                                                  INPUT aux_nrdrowid,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.

        END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao48:

    ASSIGN aux_cddopcao = GET-VALUE("cddopcao")
           aux_dsdemail = GET-VALUE("dsdemail")
           aux_nrdrowid = GET-VALUE("nrdrowid").

    RUN sistema/internet/fontes/InternetBank48.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtocd,
                                                  INPUT aux_cddopcao,
                                                  INPUT aux_dsdemail,
                                                  INPUT aux_nrdrowid,
                                                 OUTPUT aux_dsmsgerr).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao49:

    ASSIGN aux_cddopcao = GET-VALUE("cddopcao")
           aux_tptelefo = INTE(GET-VALUE("tptelefo"))
           aux_nrdddtfc = INTE(GET-VALUE("nrdddtfc"))
           aux_nrtelefo = DECI(GET-VALUE("nrtelefo"))
           aux_cdopetfn = INTE(GET-VALUE("cdopetfn"))
           aux_nrdrowid = GET-VALUE("nrdrowid").

    RUN sistema/internet/fontes/InternetBank49.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtocd,
                                                  INPUT aux_cddopcao,
                                                  INPUT aux_nrdrowid,
                                                  INPUT aux_tptelefo,
                                                  INPUT aux_nrdddtfc,
                                                  INPUT aux_nrtelefo,
                                                  INPUT aux_cdopetfn,
                                                 OUTPUT aux_dsmsgerr).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao50:

    ASSIGN aux_dtiniper = DATE(GET-VALUE("dtiniper"))
           aux_dtfimper = DATE(GET-VALUE("dtfimper"))
           aux_nriniseq = INTE(GET-VALUE("iniconta"))
           aux_nrregist = INTE(GET-VALUE("nrregist")).

    RUN sistema/internet/fontes/InternetBank50.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtiniper,
                                                  INPUT aux_dtfimper,
                                                  INPUT aux_nriniseq,
                                                  INPUT aux_nrregist,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.

        END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao51:

    RUN sistema/internet/fontes/InternetBank51.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.

        END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao52:

    ASSIGN aux_nrdrowid = GET-VALUE("nrdrowid").

    RUN sistema/internet/fontes/InternetBank52.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_nrdrowid,
                                                 OUTPUT aux_dsmsgerr).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao53:

    ASSIGN aux_nrdrowid = GET-VALUE("nrdrowid").

    RUN sistema/internet/fontes/InternetBank53.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_nrdrowid,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.

        END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao54:

    ASSIGN aux_nrdrowid = GET-VALUE("nrdrowid")
           aux_cdperiod = INTE(GET-VALUE("cdperiod"))
           aux_cdseqinc = INTE(GET-VALUE("cdseqinc")).
           
    RUN sistema/internet/fontes/InternetBank54.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_nrdrowid,
                                                  INPUT aux_cdperiod,
                                                  INPUT aux_cdseqinc,
                                                 OUTPUT aux_dsmsgerr).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao55:

    ASSIGN aux_cdgrprel = INTE(GET-VALUE("cdgrprel"))
           aux_cdrelato = INTE(GET-VALUE("cdrelato"))
           aux_cddfrenv = INTE(GET-VALUE("cddfrenv")).
           
    RUN sistema/internet/fontes/InternetBank55.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_cdgrprel,
                                                  INPUT aux_cdrelato,
                                                  INPUT aux_cddfrenv,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.

        END.
        
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao56:

    ASSIGN aux_cdprogra = INTE(GET-VALUE("cdprogra"))
           aux_cdrelato = INTE(GET-VALUE("cdrelato"))
           aux_lsdfrenv = GET-VALUE("lsdfrenv")
           aux_lsperiod = GET-VALUE("lsperiod")
           aux_lsseqinc = GET-VALUE("lsseqinc").
           
    RUN sistema/internet/fontes/InternetBank56.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_cdprogra,
                                                  INPUT aux_cdrelato,
                                                  INPUT aux_lsdfrenv,
                                                  INPUT aux_lsperiod,
                                                  INPUT aux_lsseqinc,
                                                 OUTPUT aux_dsmsgerr).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao57:
    
    ASSIGN aux_anorefer = INTE(GET-VALUE("anorefer")).

    RUN sistema/internet/fontes/InternetBank57.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_anorefer,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK: 

            {&out} xml_operacao.dslinxml.

        END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao58:

    ASSIGN aux_dsdinstr = GET-VALUE("dsdinstr").
    
    RUN sistema/internet/fontes/InternetBank58.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dsdinstr,
                                                 OUTPUT aux_dsmsgerr).
                                                 
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
        
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao59:

    ASSIGN aux_idrelato = INTE(GET-VALUE("idrelato"))
           aux_indordem = INTE(GET-VALUE("indordem"))
           aux_nrcpfcgc = DECI(GET-VALUE("nrinssac"))
           aux_idsituac = INTE(GET-VALUE("idsituac"))
           aux_inivecto = DATE(GET-VALUE("inivecto"))
           aux_fimvecto = DATE(GET-VALUE("fimvecto"))
           aux_inipagto = DATE(GET-VALUE("inipagto"))
           aux_fimpagto = DATE(GET-VALUE("fimpagto"))
           aux_iniemiss = DATE(GET-VALUE("iniemiss"))
           aux_fimemiss = DATE(GET-VALUE("fimemiss"))
           aux_flgregis = INTE(GET-VALUE("flgregis"))
           aux_inserasa = INTE(GET-VALUE("inserasa"))
           aux_instatussms = INTE(GET-VALUE("instatussms"))
           aux_tppacote = INTE(GET-VALUE("tppacote")).

    RUN sistema/internet/fontes/InternetBank59.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_idrelato,
                                                  INPUT aux_indordem,
                                                  INPUT aux_nrcpfcgc,
                                                  INPUT aux_idsituac,
                                                  INPUT aux_inivecto,
                                                  INPUT aux_fimvecto,
                                                  INPUT aux_inipagto,
                                                  INPUT aux_fimpagto,
                                                  INPUT aux_iniemiss,
                                                  INPUT aux_fimemiss,
                                                  INPUT (IF aux_flgregis = 1
                                                         THEN TRUE ELSE FALSE),
                                                  INPUT aux_inserasa,
                                                  INPUT aux_instatussms,
                                                  INPUT aux_tppacote,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    ELSE
    DO: 
        IF TRIM(aux_dsmsgerr) <> "" THEN
           {&out} aux_dsmsgerr.
             
        FOR EACH xml_operacao NO-LOCK: 

            {&out} xml_operacao.dslinxml.
        
        END.
    END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao60:

    ASSIGN aux_dtlibera = DATE(GET-VALUE("dtlibera"))
           aux_nriniseq = INTE(GET-VALUE("nriniseq"))
           aux_nrregist = INTE(GET-VALUE("nrregist")).

    RUN sistema/internet/fontes/InternetBank60.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtlibera,
                                                  INPUT aux_nriniseq,
                                                  INPUT aux_nrregist,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    ELSE
        FOR EACH xml_operacao NO-LOCK: 

            {&out} xml_operacao.dslinxml.
        
        END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao61:

    ASSIGN aux_dtiniper = DATE(GET-VALUE("dtiniper"))
           aux_dtfimper = DATE(GET-VALUE("dtfimper")).

    RUN sistema/internet/fontes/InternetBank61.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtiniper,
                                                  INPUT aux_dtfimper,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    ELSE
        FOR EACH xml_operacao NO-LOCK: 

            {&out} xml_operacao.dslinxml.
        
        END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao62:

    ASSIGN aux_dtiniper = DATE(GET-VALUE("dtvenini"))
           aux_dtfimper = DATE(GET-VALUE("dtvenfin"))
           aux_nritmini = INTE(GET-VALUE("nritmini"))
           aux_nritmfin = INTE(GET-VALUE("nritmfin"))
           aux_idordena = INTE(GET-VALUE("idordena"))
           aux_inpessoa = INTE(GET-VALUE("inpessoa"))
           aux_dssittit = GET-VALUE("sittitul")
           aux_flgerlog = LOGICAL(GET-VALUE("flgerlog")).

    IF aux_dssittit = "" THEN
      ASSIGN aux_cdsittit = 0.
    ELSE
      ASSIGN aux_cdsittit = INTE(aux_dssittit).

    RUN sistema/internet/fontes/InternetBank62.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_inpessoa,
                                                  INPUT aux_dtmvtocd,
                                                  INPUT aux_dtiniper,
                                                  INPUT aux_dtfimper,
                                                  INPUT aux_nritmini,
                                                  INPUT aux_nritmfin,
                                                  INPUT aux_idordena,
                                                  INPUT aux_flgerlog,
                                                  INPUT aux_cdsittit,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    
    FOR EACH xml_operacao NO-LOCK: 

        {&out} xml_operacao.dslinxml.
    
    END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao63:
    
    
    
    RUN sistema/internet/fontes/InternetBank63.p (INPUT aux_cdcooper,
                                                  INPUT 90,
                                                  INPUT 900,
                                                  INPUT "996",
                                                  INPUT "INTERNETBANK",
                                                  INPUT 3,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtolt,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    
    FOR EACH xml_operacao NO-LOCK: 

        {&out} xml_operacao.dslinxml.
    
    END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.


PROCEDURE proc_operacao64:

    RUN sistema/internet/fontes/InternetBank64.p (INPUT aux_cdcooper,
                                                  INPUT 90,
                                                  INPUT 900,
                                                  INPUT "996",
                                                  INPUT "INTERNETBANK",
                                                  INPUT 3,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtolt,
                                                  INPUT INTE(aux_flmobile),
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    
    FOR EACH xml_operacao NO-LOCK: 

        {&out} xml_operacao.dslinxml.
    
    END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao65:

    ASSIGN aux_dtiniper = DATE(GET-VALUE("dtvenini"))
           aux_dtfimper = DATE(GET-VALUE("dtvenfin"))
           aux_idordena = INTE(GET-VALUE("idordena"))
           aux_inpessoa = INTE(GET-VALUE("inpessoa"))
           aux_flgerlog = LOGICAL(GET-VALUE("flgerlog")).

    RUN sistema/internet/fontes/InternetBank65.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_inpessoa,
                                                  INPUT aux_dtmvtocd,
                                                  INPUT aux_dtiniper,
                                                  INPUT aux_dtfimper,
                                                  INPUT aux_idordena,
                                                  INPUT aux_flgerlog,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    
    FOR EACH xml_operacao NO-LOCK: 

        {&out} xml_operacao.dslinxml.
    
    END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao66:

    ASSIGN aux_nrcnvcob = INTE(GET-VALUE("nrcnvcob"))
           aux_nrdocmto = INTE(GET-VALUE("nrdocmto"))
           aux_cdocorre = INTE(GET-VALUE("cdocorre"))
           aux_dtvencto = DATE(GET-VALUE("dtvencto"))
           aux_vlabatim = DECI(GET-VALUE("vlabatim"))
           aux_cdtpinsc = INTE(GET-VALUE("inpessoa"))
           aux_vldescto = DECI(GET-VALUE("vldescto"))
           aux_inavisms = INTE(GET-VALUE("inavisms")).

    RUN sistema/internet/fontes/InternetBank66.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_nrcnvcob,
                                                  INPUT aux_nrdocmto,
                                                  INPUT aux_cdocorre,
                                                  INPUT aux_dtmvtocd,
                                                  INPUT "996", /* op. internet */
                                                  INPUT aux_dtvencto,
                                                  INPUT aux_vlabatim,
                                                  INPUT aux_cdtpinsc,
                                                  INPUT aux_vldescto,
                                                  INPUT aux_inavisms,
                                                 OUTPUT aux_dsinserr).

    {&out} aux_dsinserr. 
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao67:

    ASSIGN aux_nrcepend = INTE(GET-VALUE("nrcepend"))
           aux_dsendere = GET-VALUE("dsendere")
           aux_cdufende = GET-VALUE("cdufende")
           aux_nmcidade = GET-VALUE("nmcidade")
           aux_nrregist = INTE(GET-VALUE("nrregist"))
           aux_nriniseq = INTE(GET-VALUE("nriniseq")).

    RUN sistema/internet/fontes/InternetBank67.p (INPUT aux_nrcepend,
                                                  INPUT aux_dsendere,
                                                  INPUT aux_nmcidade,
                                                  INPUT aux_cdufende,
                                                  INPUT aux_nrregist,
                                                  INPUT aux_nriniseq,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    
    FOR EACH xml_operacao NO-LOCK: 

        {&out} xml_operacao.dslinxml.
    
    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao68:

    ASSIGN aux_nrcrcard = DECI(GET-VALUE("aux_nrcrcard"))
           aux_dtvctini = DATE(GET-VALUE("aux_dtiniper"))
           aux_dtvctfim = DATE(GET-VALUE("aux_dtfimper")).

    RUN sistema/internet/fontes/InternetBank68.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_nrcrcard,
                                                  INPUT aux_dtvctini,
                                                  INPUT aux_dtvctfim,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    
    FOR EACH xml_operacao NO-LOCK: 

        {&out} xml_operacao.dslinxml.
    
    END.

    {&out} aux_tgfimprg.

END PROCEDURE.


PROCEDURE proc_operacao69:

    ASSIGN aux_nmarquiv = GET-VALUE("nmarquiv")
           aux_flvalarq = LOGICAL(GET-VALUE("flvalarq")).

    RUN sistema/internet/fontes/InternetBank69.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_nmarquiv,
                                                  INPUT 3, /* origem */
                                                  INPUT aux_dtmvtolt,
                                                  INPUT "996", /* operador */
                                                  INPUT "INTERNETBANK",
                                                  INPUT aux_flvalarq,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    
    FOR EACH xml_operacao NO-LOCK: 

        {&out} xml_operacao.dslinxml.
    
    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao70:


    RUN sistema/internet/fontes/InternetBank70.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_dtmvtolt,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    
    FOR EACH xml_operacao NO-LOCK: 

        {&out} xml_operacao.dslinxml.
    
    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao71:

    ASSIGN aux_nrdmensg = INTE(GET-VALUE("aux_nrdmensg"))
           aux_iddopcao = INTE(GET-VALUE("aux_iddopcao"))
           aux_iddmensg = INTE(GET-VALUE("aux_iddmensg"))
           aux_nrregist = INTE(GET-VALUE("aux_nrregist"))
           aux_nriniseq = INTE(GET-VALUE("aux_nriniseq")).

    RUN sistema/internet/fontes/InternetBank71.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_nrdmensg,
                                                  INPUT aux_iddopcao,
                                                  INPUT aux_iddmensg,
                                                  INPUT aux_nrregist,
                                                  INPUT aux_nriniseq,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).
           
    IF  aux_dsmsgerr = ""  THEN
        FOR EACH xml_operacao NO-LOCK:
            {&out} xml_operacao.dslinxml.
        END.
    ELSE
        {&out} aux_dsmsgerr.
        
    {&out} aux_tgfimprg.
END PROCEDURE.


PROCEDURE proc_operacao73:

    ASSIGN aux_dtiniper = DATE(GET-VALUE("aux_dtageini"))
           aux_dtfimper = DATE(GET-VALUE("aux_dtagefim"))
           aux_insittra = INTE(GET-VALUE("aux_insittra"))
           aux_cpfopelg = DECI(GET-VALUE("aux_cpfopelg"))
           aux_nrregist = INTE(GET-VALUE("aux_nrregist"))
           aux_nriniseq = INTE(GET-VALUE("aux_nriniseq"))
           aux_cdtransa = INTE(GET-VALUE("aux_cdtransa")).

    RUN sistema/internet/fontes/InternetBank73.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_nrcpfope,
                                                  INPUT aux_cpfopelg,
                                                  INPUT 90, /* pac */
                                                  INPUT aux_dtmvtocd,
                                                  INPUT 3, /* origem */
                                                  INPUT aux_cdtransa,
                                                  INPUT aux_insittra,
                                                  INPUT aux_dtiniper,
                                                  INPUT aux_dtfimper,
                                                  INPUT aux_nrregist,
                                                  INPUT aux_nriniseq,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).
           
    IF  aux_dsmsgerr = ""  THEN
        FOR EACH xml_operacao NO-LOCK:
            {&out} xml_operacao.dslinxml.
        END.
    ELSE
        {&out} aux_dsmsgerr.
        
    {&out} aux_tgfimprg.
END PROCEDURE.

PROCEDURE proc_operacao74:

    ASSIGN aux_cdditens = GET-VALUE("aux_cdditens").

    RUN sistema/internet/fontes/InternetBank74.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT 900, /* caixa */
                                                  INPUT 90, /* pac */
                                                  INPUT "996", /* operador */
                                                  INPUT aux_dtmvtocd,
                                                  INPUT 3, /* origem */
                                                  INPUT "INTERNETBANK",
                                                  INPUT aux_cdditens,
                                                  INPUT aux_nrcpfope,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).
           
    IF  aux_dsmsgerr = ""  THEN
        FOR EACH xml_operacao NO-LOCK:
            {&out} xml_operacao.dslinxml.
        END.
    ELSE
        {&out} aux_dsmsgerr.
        
    {&out} aux_tgfimprg.
END PROCEDURE.

PROCEDURE proc_operacao75:

    ASSIGN aux_cdditens = GET-VALUE("aux_cdditens").

    RUN sistema/internet/fontes/InternetBank75.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT 900, /* caixa */
                                                  INPUT 90, /* pac */
                                                  INPUT "996", /* operador */
                                                  INPUT aux_dtmvtocd,
                                                  INPUT 3, /* origem */
                                                  INPUT "INTERNETBANK",
                                                  INPUT aux_cdditens,
                                                  INPUT aux_indvalid,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_nrcpfope,
                                                  INPUT aux_nripuser,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  aux_dsmsgerr = ""  THEN
        FOR EACH xml_operacao NO-LOCK:
            {&out} xml_operacao.dslinxml.
        END.
    ELSE
        {&out} aux_dsmsgerr.
        
    {&out} aux_tgfimprg.
END PROCEDURE.

PROCEDURE proc_operacao76:

    RUN sistema/internet/fontes/InternetBank76.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT 0, /* caixa */
                                                  INPUT 90, /* pac */
                                                  INPUT "996", /* operador */
                                                  INPUT aux_dtmvtocd,
                                                  INPUT 3, /* origem */
                                                  INPUT "INTERNETBANK",
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  aux_dsmsgerr = ""  THEN
        FOR EACH xml_operacao NO-LOCK:
            {&out} xml_operacao.dslinxml.
        END.
    ELSE
        {&out} aux_dsmsgerr.
        
    {&out} aux_tgfimprg.
END PROCEDURE.

PROCEDURE proc_operacao77:

    RUN sistema/internet/fontes/InternetBank77.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT 0, /* caixa */
                                                  INPUT 90, /* pac */
                                                  INPUT "996", /* operador */
                                                  INPUT aux_dtmvtocd,
                                                  INPUT 3, /* origem */
                                                  INPUT "INTERNETBANK",
                                                  INPUT GET-VALUE("aux_dssennov"),
                                                  INPUT GET-VALUE("aux_dssencon"),
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).


    FOR EACH xml_operacao NO-LOCK:
        {&out} xml_operacao.dslinxml.
    END.

    {&out} aux_dsmsgerr.
        
    {&out} aux_tgfimprg.
END PROCEDURE.

PROCEDURE proc_operacao78:

    RUN sistema/internet/fontes/InternetBank78.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
            {&out} xml_operacao.dslinxml.
        END.
        
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao79:

    RUN sistema/internet/fontes/InternetBank79.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_nrcpfope,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
            {&out} xml_operacao.dslinxml.
        END.
        
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao80: 

    ASSIGN aux_cddbanco = INTE(GET-VALUE("aux_cddbanco"))
           aux_cdispbif = INTE(GET-VALUE("aux_cdispbif"))
           aux_cdageban = INTE(GET-VALUE("aux_cdageban"))
           aux_nrctatrf = DECI(GET-VALUE("aux_nrctatrf"))
           aux_intipdif = INTE(GET-VALUE("aux_intipdif"))
           aux_intipcta = INTE(GET-VALUE("aux_intipcta"))
           aux_inpessoa = INTE(GET-VALUE("aux_inpessoa"))
           aux_nmtitula = GET-VALUE("aux_nmtitula")
           aux_nrcpfcgc = DECI(GET-VALUE("aux_nrcpfcgc"))
           aux_insitcta = INTE(GET-VALUE("aux_insitcta"))
           aux_flgexecu = LOGICAL(GET-VALUE("aux_flgexecu")).
           aux_rowidcti = GET-VALUE("aux_rowidcti").
           aux_flexclui = GET-VALUE("aux_flregist").

    IF  NOT aux_flgcript AND aux_flgexecu AND aux_rowidcti = ""  THEN /* Nao possui criptografia no front e autenticacao e realizada junto com a propria operacao*/
        DO:
            RUN proc_operacao2.

            IF   RETURN-VALUE = "NOK"   THEN
                 RETURN "NOK".
        END.           

    RUN sistema/internet/fontes/InternetBank80.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtolt,
                                                  INPUT aux_nrcpfope,
                                                  INPUT aux_cddbanco,
                                                  INPUT aux_cdispbif,
                                                  INPUT aux_cdageban,
                                                  INPUT aux_nrctatrf,
                                                  INPUT aux_intipdif,
                                                  INPUT aux_intipcta,
                                                  INPUT aux_inpessoa,
                                                  INPUT aux_nmtitula,
                                                  INPUT aux_nrcpfcgc,
                                                  INPUT aux_insitcta,
                                                  INPUT aux_flgexecu,
                                                  INPUT aux_rowidcti,
                                                  INPUT aux_flexclui,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:

            {&out} xml_operacao.dslinxml.

        END.
        
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao81:

    ASSIGN aux_dtrefini = DATE(GET-VALUE("aux_dtrefini"))
           aux_dtreffim = DATE(GET-VALUE("aux_dtreffim"))
           aux_tprelato = INTE(GET-VALUE("aux_tprelato"))
		   aux_dsiduser = GET-VALUE("aux_dsiduser").

    RUN sistema/internet/fontes/InternetBank81.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtrefini,
                                                  INPUT aux_dtreffim,
                                                  INPUT aux_tprelato,
                                                  INPUT aux_dtmvtolt,
												  INPUT aux_dsiduser,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    
    FOR EACH xml_operacao NO-LOCK: 

        {&out} xml_operacao.dslinxml.
    
    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao82:

    ASSIGN aux_cdagectl = INTE(GET-VALUE("aux_cdagectl"))
           aux_nrctatrf = INTE(GET-VALUE("aux_nrctatrf"))
           aux_cdtiptra = INTE(GET-VALUE("aux_cdtiptra")).            

    RUN sistema/internet/fontes/InternetBank82.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_cdagectl,
                                                  INPUT aux_nrctatrf,
                                                  INPUT aux_dtmvtolt,
                                                  INPUT aux_cdtiptra,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    
    FOR EACH xml_operacao NO-LOCK: 

        {&out} xml_operacao.dslinxml.
    
    END.

    {&out} aux_tgfimprg.    

END PROCEDURE.

PROCEDURE proc_operacao83:

    ASSIGN aux_vlaplica = DEC(GET-VALUE("vlaplica"))
           aux_tpaplica = INTE(GET-VALUE("tpaplica")).
                       
    RUN sistema/internet/fontes/InternetBank83.p (INPUT aux_cdcooper,
                                                  INPUT 90, /*cdagenci*/
                                                  INPUT 900, /*nrdcaixa*/
                                                  INPUT "996", /*cdoperad*/
                                                  INPUT "INTERNETBANK",
                                                  INPUT 3, /*idorigem*/
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtolt,
                                                  INPUT aux_vlaplica,
                                                  INPUT aux_tpaplica,
                                                  INPUT 0, /*qtdiaapl*/
                                                  INPUT 0, /*qtdiacar*/
                                                  INPUT 0, /*flgvalid*/
                                                  INPUT 1, /*flgerlog*/
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).
    
    IF  RETURN-VALUE <> "OK"  THEN
       {&out} aux_dsmsgerr. 
    
    FOR EACH xml_operacao NO-LOCK: 
        
        {&out} xml_operacao.dslinxml.
    
    END.
                            
    {&out} aux_tgfimprg.    

END PROCEDURE.


PROCEDURE proc_operacao84:

    ASSIGN aux_cddopcao = GET-VALUE("cddopcao")
           aux_vlaplica = DEC(GET-VALUE("vlaplica"))
           aux_nraplica = INT(GET-VALUE("nraplica"))
           aux_tpaplica = INTE(GET-VALUE("tpaplica"))
           aux_qtdiaapl = INTE(GET-VALUE("qtdiaapl"))
           aux_dtresgat = DATE(GET-VALUE("dtresgat"))
           aux_qtdiacar = INTE(GET-VALUE("qtdiacar"))
           aux_cdperapl = INTE(GET-VALUE("cdperapl"))
           aux_flgvalid = LOGICAL(GET-VALUE("flgvalid")).
           
    IF  GET-VALUE("idtipapl") <> '' THEN
        aux_idtipapl = GET-VALUE("idtipapl").
    ELSE
        aux_idtipapl = 'A'.           

    RUN sistema/internet/fontes/InternetBank84.p (INPUT aux_cdcooper,
                                                  INPUT 90, /*cdagenci*/
                                                  INPUT 900, /*nrdcaixa*/
                                                  INPUT "996", /*cdoperad*/
                                                  INPUT "INTERNETBANK",
                                                  INPUT 3, /*idorigem*/
                                                  INPUT aux_inproces,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtolt,
                                                  INPUT aux_dtmvtopr,
                                                  INPUT aux_cddopcao,
                                                  INPUT aux_vlaplica,
                                                  INPUT aux_tpaplica,
                                                  INPUT aux_nraplica,
                                                  INPUT aux_qtdiaapl,
                                                  INPUT aux_dtresgat,
                                                  INPUT aux_qtdiacar,
                                                  INPUT aux_cdperapl,
                                                  INPUT 0, /*Nao debitar da CI*/
                                                  INPUT 1, /*Gera log*/
                                                  INPUT aux_flgvalid,
                                                  INPUT aux_idtipapl,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).
    
    IF  RETURN-VALUE <> "OK"  THEN
       {&out} aux_dsmsgerr. 
    
    FOR EACH xml_operacao NO-LOCK: 
        
        {&out} xml_operacao.dslinxml.
    
    END.
                            
    {&out} aux_tgfimprg.    

END PROCEDURE.

PROCEDURE proc_operacao85:

    ASSIGN aux_nraplica = INT(GET-VALUE("nraplica")).
           
                       
    RUN sistema/internet/fontes/InternetBank85.p (INPUT aux_cdcooper,
                                                  INPUT 90, /*cdagenci*/
                                                  INPUT 900, /*nrdcaixa*/
                                                  INPUT "996", /*cdoperad*/
                                                  INPUT "INTERNETBANK",
                                                  INPUT 3, /*idorigem*/
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtolt,
                                                  INPUT aux_nraplica,
                                                  INPUT 1, /*Gera log*/
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).
    
    IF  RETURN-VALUE <> "OK"  THEN
       {&out} aux_dsmsgerr. 
    
    FOR EACH xml_operacao NO-LOCK: 
        
        {&out} xml_operacao.dslinxml.
    
    END.
                            
    {&out} aux_tgfimprg.    

END PROCEDURE.

PROCEDURE proc_operacao86:

    ASSIGN aux_tpaplica = INT(GET-VALUE("tpaplica"))
           aux_dtvencto = DATE(GET-VALUE("dtvencto"))
           aux_qtdiacar= INT(GET-VALUE("qtdiacar")).
           
    RUN sistema/internet/fontes/InternetBank86.p (INPUT aux_cdcooper,
                                                  INPUT 90, /*cdagenci*/
                                                  INPUT 900, /*nrdcaixa*/
                                                  INPUT "996", /*cdoperad*/
                                                  INPUT "INTERNETBANK",
                                                  INPUT 3, /*idorigem*/
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_tpaplica,
                                                  INPUT aux_dtmvtolt,
                                                  INPUT TRUE, /*Gera log*/
                                                  INPUT 0, /*qtdiaapl*/
                                                  INPUT aux_qtdiacar,
                                                  INPUT aux_dtvencto,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).
    
    IF  RETURN-VALUE <> "OK"  THEN
       {&out} aux_dsmsgerr. 
    
    FOR EACH xml_operacao NO-LOCK: 
        
        {&out} xml_operacao.dslinxml.
    
    END.
                            
    {&out} aux_tgfimprg.    

END PROCEDURE.

PROCEDURE proc_operacao87:

     ASSIGN aux_nmtitula = GET-VALUE("nmtitula")
            aux_nrcpfcgc = DECI(GET-VALUE("nrcpfcgc"))
            aux_inpessoa = INT(GET-VALUE("inpessoa"))
            aux_intipcta = INT(GET-VALUE("intipcta"))
            aux_insitcta = INT(GET-VALUE("insitcta"))
            aux_intipdif = INTE(GET-VALUE("intipdif"))
            aux_cddbanco = INTE(GET-VALUE("cddbanco"))
            aux_cdageban = INTE(GET-VALUE("cdageban"))
            aux_nrctatrf = DECI(GET-VALUE("nrctatrf")).         

    RUN sistema/internet/fontes/InternetBank87.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtolt,
                                                  INPUT aux_nmtitula,
                                                  INPUT aux_nrcpfcgc,
                                                  INPUT aux_inpessoa,
                                                  INPUT aux_intipcta,
                                                  INPUT aux_insitcta,
                                                  INPUT aux_intipdif,
                                                  INPUT aux_cddbanco,
                                                  INPUT aux_cdageban,
                                                  INPUT aux_nrctatrf,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).
    
    IF  RETURN-VALUE <> "OK"  THEN
       {&out} aux_dsmsgerr. 
    
    FOR EACH xml_operacao NO-LOCK: 
        
        {&out} xml_operacao.dslinxml.
    
    END.
                            
    {&out} aux_tgfimprg.   

END PROCEDURE.


PROCEDURE proc_operacao88:

    DEF VAR aux_dtmvtpro AS DATE NO-UNDO.

     ASSIGN aux_cdtippro = INT(GET-VALUE("cdtippro"))
            aux_nrdocpro = GET-VALUE("nrdocmto").         

    IF GET-VALUE('dtmvtpro') <> '' THEN
	   aux_dtmvtpro = DATE(GET-VALUE('dtmvtpro')).
	ELSE
	   aux_dtmvtpro = aux_dtmvtolt.			

    RUN sistema/internet/fontes/InternetBank88.p (INPUT aux_cdcooper,
                                                  INPUT 90, /*cdagenci*/
                                                  INPUT 900, /*nrdcaixa*/
                                                  INPUT "996", /*cdoperad*/
                                                  INPUT "INTERNETBANK",
                                                  INPUT 3, /*idorigem*/
                                                  INPUT aux_dtmvtpro,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_cdtippro,
                                                  INPUT aux_nrdocpro,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao88).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr aux_tgfimprg.
            RETURN.
        END.
        
    {&out} "<PROTOCOLOS>".
    
    FOR EACH xml_operacao88 NO-LOCK:

        {&out} xml_operacao88.dscabini 
               xml_operacao88.cdtippro   
               xml_operacao88.dtmvtolt
               xml_operacao88.dttransa 
               xml_operacao88.hrautent 
               xml_operacao88.vldocmto 
               xml_operacao88.nrdocmto 
               xml_operacao88.nrseqaut
               xml_operacao88.dsinfor1 
               xml_operacao88.dsinfor2 
               xml_operacao88.dsinfor3 
               xml_operacao88.dsprotoc 
               xml_operacao88.dscedent 
               xml_operacao88.flgagend
               xml_operacao88.nmprepos
               xml_operacao88.nrcpfpre 
               xml_operacao88.nmoperad
               xml_operacao88.nrcpfope 
               xml_operacao88.cdbcoctl
               xml_operacao88.cdagectl 
               xml_operacao88.cdagesic
               xml_operacao88.dscabfim.
    
    END.
    
    {&out} "</PROTOCOLOS>" aux_tgfimprg.

END PROCEDURE.


PROCEDURE proc_operacao89:

    ASSIGN aux_vlaplica = DEC(GET-VALUE("vlaplica"))
           aux_vllimcre = crapass.vllimcre.
                       
    RUN sistema/internet/fontes/InternetBank89.p (INPUT aux_cdcooper,
                                                  INPUT 90, /*cdagenci*/
                                                  INPUT 900, /*nrdcaixa*/
                                                  INPUT "996", /*cdoperad*/
                                                  INPUT "INTERNETBANK",
                                                  INPUT 3, /*idorigem*/
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtolt,
                                                  INPUT aux_vlaplica,
                                                  INPUT aux_vllimcre,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).
    
    IF  RETURN-VALUE <> "OK"  THEN
       {&out} aux_dsmsgerr. 
    
    FOR EACH xml_operacao NO-LOCK: 
        
        {&out} xml_operacao.dslinxml.
    
    END.
                            
    {&out} aux_tgfimprg.    

END PROCEDURE.

/* Credito pre aprovado */
PROCEDURE proc_operacao90:
    
    RUN sistema/internet/fontes/InternetBank90.p (INPUT aux_cdcooper,
                                                  INPUT 90,    /*cdagenci*/
                                                  INPUT 900,   /*nrdcaixa*/
                                                  INPUT 1,     /*cdoperad*/
                                                  INPUT "INTERNETBANK",
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_nrcpfope,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
            {&out} xml_operacao.dslinxml.
        END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

/*agendamentos*/
PROCEDURE proc_operacao91:
    
    ASSIGN aux_flgtipar = INTE(GET-VALUE("flgtipar"))
           aux_nrctraar = INTE(GET-VALUE("nrctraar"))
           aux_cdsitaar = INTE(GET-VALUE("cdsitaar")).
    
    RUN sistema/internet/fontes/InternetBank91.p (INPUT aux_cdcooper,
                                                  INPUT aux_flgtipar,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_nrctraar,
                                                  INPUT aux_cdsitaar,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).
                                                 
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.
                   
        END. 
    
    {&out} aux_tgfimprg.        

END PROCEDURE.

/*buscar as parcelas do credito pre-aprovado*/
PROCEDURE proc_operacao92:
    
    ASSIGN aux_vlemprst = DEC(GET-VALUE("vlemprst"))
           aux_diapagto = INTE(GET-VALUE("diapagto")).

    RUN sistema/internet/fontes/InternetBank92.p (INPUT aux_cdcooper,
                                                  INPUT 90, /*cdagenci*/
                                                  INPUT 900, /*nrdcaixa*/
                                                  INPUT 1,   /*cdoperad*/
                                                  INPUT "INTERNETBANK",
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtolt,
                                                  INPUT aux_vlemprst,
                                                  INPUT aux_diapagto,
                                                  INPUT aux_nrcpfope,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).
    
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.
                   
        END. 
    
    {&out} aux_tgfimprg.        

END PROCEDURE.

/*imprime o extrato de contratacao do produto credito automatico */
PROCEDURE proc_operacao93:
    
    ASSIGN aux_nrctremp = INTE(GET-VALUE("nrctremp"))
           aux_vlemprst = DEC(GET-VALUE("vlemprst"))
           aux_txmensal = DEC(GET-VALUE("txmensal"))
           aux_qtpreemp = INTE(GET-VALUE("qtpreemp"))
           aux_vlpreemp = DEC(GET-VALUE("vlpreemp"))
           aux_percetop = DEC(GET-VALUE("percetop"))
           aux_vlrtarif = DEC(GET-VALUE("vlrtarif")) 
           aux_dtdpagto = DATE(GET-VALUE("dtdpagto"))
           aux_vltaxiof = DECI(GET-VALUE("vltaxiof"))
           aux_vltariof = DECI(GET-VALUE("vltariof"))
           aux_flgprevi = LOGICAL(GET-VALUE("flgprevi")).

    RUN sistema/internet/fontes/InternetBank93.p (INPUT aux_cdcooper,
                                                  INPUT 90,  /*cdagenci*/
                                                  INPUT 900, /*nrdcaixa*/
                                                  INPUT 1,   /*cdoperad*/
                                                  INPUT "INTERNETBANK",
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtolt,
                                                  INPUT aux_nrctremp,
                                                  INPUT aux_vlemprst,
                                                  INPUT aux_txmensal,
                                                  INPUT aux_qtpreemp,
                                                  INPUT aux_vlpreemp,
                                                  INPUT aux_percetop,
                                                  INPUT aux_vlrtarif,
                                                  INPUT aux_dtdpagto,
                                                  INPUT aux_vltaxiof,
                                                  INPUT aux_vltariof,
                                                  INPUT aux_flgprevi,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).
    
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.
                   
        END. 
    
    {&out} aux_tgfimprg.        

END PROCEDURE.

/*agendamentos / tabela de carencia*/
PROCEDURE proc_operacao94:
    
    ASSIGN aux_tpaplica = INTE(GET-VALUE("tpaplica"))
           aux_qtdiaapl = INTE(GET-VALUE("qtdiaapl"))
           aux_qtdiacar = INTE(GET-VALUE("qtdiacar"))
           aux_flavalid = INTE(GET-VALUE("flgvalid"))
           aux_flaerlog = INTE(GET-VALUE("flgerlog")).

    RUN sistema/internet/fontes/InternetBank94.p (INPUT aux_cdcooper,
                                                  INPUT 90, /*cdagenci*/
                                                  INPUT 900, /*nrdcaixa*/
                                                  INPUT "966", /*cdoperad*/
                                                  INPUT "INTERNETBANK", /*nmdatela*/
                                                  INPUT 3, /*idorigem*/
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtolt,
                                                  INPUT aux_tpaplica,
                                                  INPUT aux_qtdiaapl,
                                                  INPUT aux_qtdiacar,
                                                  INPUT aux_flavalid,
                                                  INPUT aux_flaerlog,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).
                                                 
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.
                   
        END. 
    
    {&out} aux_tgfimprg.        

END PROCEDURE.

/* resumo do resgate de aplicações */
PROCEDURE proc_operacao95:
    
    ASSIGN aux_dsaplica = GET-VALUE("dsaplica")
           aux_vlresgat = GET-VALUE("vlresgat").

    RUN sistema/internet/fontes/InternetBank95.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtolt,
                                                  INPUT aux_dsaplica,
                                                  INPUT aux_vlresgat,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).


    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.
                   
        END. 
        
    {&out} aux_tgfimprg.        

END PROCEDURE.

PROCEDURE proc_operacao96:

    ASSIGN aux_idvalida = INTE(GET-VALUE("tpvalida")).
    
    RUN sistema/internet/fontes/InternetBank96.p (INPUT aux_cdcooper,
                                                  INPUT 90, /*cdagenci*/
                                                  INPUT 900, /*nrdcaixa*/
                                                  INPUT "996", /*cdoperad*/
                                                  INPUT "INTERNETBANK",
                                                  INPUT 3, /*idorigem*/
                                                  INPUT aux_idvalida,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).
    
    IF  RETURN-VALUE <> "OK"  THEN
       {&out} aux_dsmsgerr. 
    
    FOR EACH xml_operacao NO-LOCK: 
        
        {&out} xml_operacao.dslinxml.
    
    END.
                            
    {&out} aux_tgfimprg.    

END PROCEDURE.

PROCEDURE proc_operacao97:

    ASSIGN aux_flgtipar = INTEGER(GET-VALUE("flgtipar"))
           aux_vlparaar = DECIMAL(GET-VALUE("vlparaar"))
           aux_flgtipin = INTEGER(GET-VALUE("flgtipin"))
           aux_qtdiacar = INTEGER(GET-VALUE("qtdiacar"))
           aux_qtmesaar = INTEGER(GET-VALUE("qtmesaar"))
           aux_dtiniaar = DATE(GET-VALUE("dtiniaar"))
           aux_dtdiaaar = INTEGER(GET-VALUE("dtdiaaar"))
           aux_dtvencto = DATE(GET-VALUE("dtvencto"))
           aux_qtdiaven = INTEGER(GET-VALUE("qtdiaven")).

    IF  NOT aux_flgcript AND aux_flgtipar = 1 THEN /* Nao possui criptografia no front e autenticacao e realizada junto com a propria operacao*/
        DO:
            RUN proc_operacao2.

            IF   RETURN-VALUE = "NOK"   THEN
                 RETURN "NOK".
        END.

    RUN sistema/internet/fontes/InternetBank97.p (INPUT aux_cdcooper,
                                                  INPUT aux_flgtipar,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_vlparaar,
                                                  INPUT aux_flgtipin,
                                                  INPUT aux_qtdiacar,
                                                  INPUT aux_qtmesaar,
                                                  INPUT aux_dtiniaar,
                                                  INPUT aux_dtdiaaar,
                                                  INPUT aux_dtvencto,
                                                  INPUT aux_qtdiaven,
                                                  INPUT "996",
                                                  INPUT "INTERNETBANK",
                                                  INPUT 3, /*idorigem*/
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF RETURN-VALUE <> "OK" THEN
        {&out} aux_dsmsgerr.

    FOR EACH xml_operacao NO-LOCK:

        {&out} xml_operacao.dslinxml.

    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao98:

    RUN sistema/internet/fontes/InternetBank98.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF RETURN-VALUE <> "OK" THEN
        {&out} aux_dsmsgerr.

    FOR EACH xml_operacao NO-LOCK:

        {&out} xml_operacao.dslinxml.

    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao99:

    ASSIGN aux_cdsegmto = INTE(GET-VALUE("cdsegmto"))
           aux_cdempcon = INTE(GET-VALUE("cdempcon"))
           aux_idconsum = DECI(GET-VALUE("idconsum"))
           aux_flglimit = IF INTE(GET-VALUE("flglimit")) = 1 THEN
                              TRUE
                          ELSE
                              FALSE
           aux_vlmaxdeb = DECI(GET-VALUE("vlmaxdeb"))
           aux_dshisext = GET-VALUE("dshisext")
           aux_cdhisdeb = INTE(GET-VALUE("cdhisdeb"))
           aux_flcadast = INTE(GET-VALUE("flcadast"))
           aux_cdhistor = INTE(GET-VALUE("cdhistor"))
           aux_idmotivo = INTE(GET-VALUE("idmotivo")).

    RUN sistema/internet/fontes/InternetBank99.p 
                                         (INPUT aux_cdcooper,
                                          INPUT aux_nrdconta,
                                          INPUT aux_idseqttl,
                                          INPUT aux_dtmvtocd,
                                          INPUT aux_cdsegmto,
                                          INPUT aux_cdempcon,
                                          INPUT aux_idconsum,
                                          INPUT aux_flglimit,
                                          INPUT aux_vlmaxdeb,
                                          INPUT aux_dshisext,
                                          INPUT aux_cdhisdeb,
                                          INPUT aux_flcadast,
                                          INPUT aux_cdhistor,
                                          INPUT aux_idmotivo,
                                         OUTPUT aux_dsmsgerr,
                                         OUTPUT TABLE xml_operacao).

    IF RETURN-VALUE <> "OK" THEN
            {&out} aux_dsmsgerr. 

    FOR EACH xml_operacao NO-LOCK:

        {&out} xml_operacao.dslinxml.

        END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao100:

    ASSIGN aux_qtpreemp = INTE(GET-VALUE("qtpreemp"))
           aux_vlpreemp = DEC(GET-VALUE("vlpreemp"))
           aux_vlemprst = DEC(GET-VALUE("vlemprst"))
           aux_dtdpagto = DATE(GET-VALUE("dtdpagto"))
           aux_percetop = DEC(GET-VALUE("percetop"))
           aux_txmensal = DEC(GET-VALUE("txmensal"))
           aux_vlrtarif = DEC(GET-VALUE("vlrtarif"))
           aux_vltaxiof = DEC(GET-VALUE("vltaxiof"))
           aux_vltariof = DEC(GET-VALUE("vltariof")).

    RUN sistema/internet/fontes/InternetBank100.p(INPUT aux_cdcooper,
                                                  INPUT 90,  /*cdagenci*/
                                                  INPUT 900, /*nrdcaixa*/
                                                  INPUT 1,   /*cdoperad*/
                                                  INPUT "INTERNETBANK",
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtolt,
                                                  INPUT aux_dtmvtopr,
                                                  INPUT aux_qtpreemp,
                                                  INPUT aux_vlpreemp,
                                                  INPUT aux_vlemprst,
                                                  INPUT aux_dtdpagto,
                                                  INPUT aux_percetop,
                                                  INPUT aux_nrcpfope,
                                                  INPUT aux_txmensal,
                                                  INPUT aux_vlrtarif,
                                                  INPUT aux_vltaxiof,
                                                  INPUT aux_vltariof,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).
    
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.
                   
        END. 
    
    {&out} aux_tgfimprg.        

END PROCEDURE.


PROCEDURE proc_operacao101:

    aux_nrcnvpag = INTE(GET-VALUE("aux_nrcnvpag")).

    RUN sistema/internet/fontes/InternetBank101.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_nrcnvpag,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF RETURN-VALUE <> "OK" THEN
        {&out} aux_dsmsgerr.

    FOR EACH xml_operacao NO-LOCK:

        {&out} xml_operacao.dslinxml.

    END.

    {&out} aux_tgfimprg.

END PROCEDURE.


PROCEDURE proc_operacao102:

    aux_nrcnvpag = INTE(GET-VALUE("aux_nrcnvpag")).
    aux_dtiniper = DATE(GET-VALUE("aux_dtiniper")).
    aux_dtfimper = DATE(GET-VALUE("aux_dtfimper")).

    RUN sistema/internet/fontes/InternetBank102.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_nrcnvpag,
                                                   INPUT aux_dtiniper,
                                                   INPUT aux_dtfimper,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT xml_operacao).

    IF RETURN-VALUE <> "OK" THEN
        {&out} aux_dsmsgerr.


    /** Ja retorna do Oracle um XML... */
    {&out} xml_operacao.

    {&out} aux_tgfimprg.

END PROCEDURE.


PROCEDURE proc_operacao103:

    DEF VAR aux_nrsequen AS   INTE                                       NO-UNDO.
    DEF VAR aux_qtregpag AS   INTE                                       NO-UNDO.
    DEF VAR aux_cdhistor AS   INTE                                       NO-UNDO.
    DEF VAR aux_nrdocmto AS   INTE                                       NO-UNDO.

    ASSIGN aux_nrsequen = INTE(GET-VALUE("aux_nrsequen"))
           aux_dtiniper = DATE(GET-VALUE("aux_dtiniper"))
           aux_dtfimper = DATE(GET-VALUE("aux_dtfimper"))
           aux_qtregpag = INTE(GET-VALUE("aux_qtregpag"))
           aux_cdhistor = INTE(GET-VALUE("aux_cdhistor"))
           aux_vllanmto = DECI(GET-VALUE("aux_vllanmto"))
           aux_nrdocmto = INTE(GET-VALUE("aux_nrdocmto")).
    
    RUN sistema/internet/fontes/InternetBank103.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_nrsequen,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_dtiniper,
                                                   INPUT aux_dtfimper,
                                                   INPUT aux_qtregpag,
                                                   INPUT aux_cdhistor,
                                                   INPUT aux_vllanmto,
                                                   INPUT aux_nrdocmto,
                                                   OUTPUT aux_dsmsgerr,
                                                   OUTPUT TABLE xml_operacao).

    IF RETURN-VALUE <> "OK" THEN
        {&out} aux_dsmsgerr.

    FOR EACH xml_operacao NO-LOCK:

        {&out} xml_operacao.dslinxml.

    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

/* Validação para o valor de resgate da aplicação, para que não seja
   maior que o valor configurado */
PROCEDURE proc_operacao104:

    ASSIGN aux_vlaplica = DEC(GET-VALUE("vlresgat")).
                       
    RUN sistema/internet/fontes/InternetBank104.p (INPUT aux_cdcooper,
                                                  INPUT 90, /*cdagenci*/
                                                  INPUT 900, /*nrdcaixa*/
                                                  INPUT "996", /*cdoperad*/
                                                  INPUT "INTERNETBANK",
                                                  INPUT 3, /*idorigem*/
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_dtmvtolt,
                                                  INPUT aux_vlaplica,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    
    IF  RETURN-VALUE <> "OK"  THEN
       {&out} aux_dsmsgerr. 
    
    FOR EACH xml_operacao NO-LOCK: 
        
        {&out} xml_operacao.dslinxml.
    
    END.
                            
    {&out} aux_tgfimprg.    

END PROCEDURE.

PROCEDURE proc_operacao105:

    ASSIGN aux_cddopcao = GET-VALUE("cddopcao").

    RUN sistema/internet/fontes/InternetBank105.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_dtmvtolt,
                                                   INPUT aux_cddopcao,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF RETURN-VALUE <> "OK" THEN
        {&out} aux_dsmsgerr.

    FOR EACH xml_operacao NO-LOCK:

        {&out} xml_operacao.dslinxml.

    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao106:

    ASSIGN aux_flgtipar = INTEGER(GET-VALUE("flgtipar"))
           aux_vlparaar = DECIMAL(GET-VALUE("vlparaar"))
           aux_flgtipin = INTEGER(GET-VALUE("flgtipin"))
           aux_qtdiacar = INTEGER(GET-VALUE("qtdiacar"))
           aux_qtmesaar = INTEGER(GET-VALUE("qtmesaar"))
           aux_dtiniaar = DATE(GET-VALUE("dtiniaar"))
           aux_dtdiaaar = INTEGER(GET-VALUE("dtdiaaar"))
           aux_dtvencto = DATE(GET-VALUE("dtvencto")).

    RUN sistema/internet/fontes/InternetBank106.p (INPUT aux_cdcooper,
                                                   INPUT aux_flgtipar,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_vlparaar,
                                                   INPUT aux_flgtipin,
                                                   INPUT aux_qtdiacar,
                                                   INPUT aux_qtmesaar,
                                                   INPUT aux_dtiniaar,
                                                   INPUT aux_dtdiaaar,
                                                   INPUT aux_dtvencto,
                                                   INPUT "996",
                                                   INPUT "INTERNETBANK",
                                                   INPUT 3, /*idorigem*/
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF RETURN-VALUE <> "OK" THEN
        {&out} aux_dsmsgerr.

    FOR EACH xml_operacao NO-LOCK:

        {&out} xml_operacao.dslinxml.

    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao107:

    ASSIGN aux_flgtipar = INTEGER(GET-VALUE("flgtipar"))
           aux_qtdiacar = INTEGER(GET-VALUE("qtdiacar"))
           aux_dtiniaar = DATE(GET-VALUE("dtiniaar")).

    RUN sistema/internet/fontes/InternetBank107.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_qtdiacar,
                                                   INPUT aux_dtiniaar,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF RETURN-VALUE <> "OK" THEN
        {&out} aux_dsmsgerr.

    FOR EACH xml_operacao NO-LOCK:

        {&out} xml_operacao.dslinxml.

    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao108:

    ASSIGN aux_flgtipar = INTEGER(GET-VALUE("flgtipar"))
           aux_nrdocmto = INTEGER(GET-VALUE("nrdocmto")).

    RUN sistema/internet/fontes/InternetBank108.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_flgtipar,
                                                   INPUT aux_nrdocmto,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF RETURN-VALUE <> "OK" THEN
        {&out} aux_dsmsgerr.

    FOR EACH xml_operacao NO-LOCK:

        {&out} xml_operacao.dslinxml.

    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao109:

    ASSIGN aux_dtiniitr = DATE(GET-VALUE("dtiniitr"))
           aux_dtfinitr = DATE(GET-VALUE("dtfinitr")).

    RUN sistema/internet/fontes/InternetBank109.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_dtiniitr,
                                                   INPUT aux_dtfinitr,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF RETURN-VALUE <> "OK" THEN
        {&out} aux_dsmsgerr.

    FOR EACH xml_operacao NO-LOCK:

        {&out} xml_operacao.dslinxml.

    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao110:

    ASSIGN aux_cdsegmto = INTE(GET-VALUE("cdsegmto"))
           aux_cdempcon = INTE(GET-VALUE("cdempcon"))
           aux_idconsum = DECI(GET-VALUE("idconsum"))
           aux_dtinisus = DATE(GET-VALUE("dtinisus"))
           aux_dtfimsus = DATE(GET-VALUE("dtfimsus"))
           aux_flcadast = INTE(GET-VALUE("flcadast"))
		   aux_cdhistor = INTE(GET-VALUE("cdhistor")).

    RUN sistema/internet/fontes/InternetBank110.p 
                                         (INPUT aux_cdcooper,
                                          INPUT aux_nrdconta,
                                          INPUT aux_idseqttl,
                                          INPUT aux_dtmvtolt,
                                          INPUT aux_cdsegmto,
                                          INPUT aux_cdempcon,
                                          INPUT aux_idconsum,
                                          INPUT aux_dtinisus,
                                          INPUT aux_dtfimsus,
                                          INPUT aux_flcadast,
										  INPUT aux_cdhistor,
                                         OUTPUT aux_dsmsgerr).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr. 
        END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao111:

    ASSIGN aux_cddopcao = GET-VALUE("cddopcao").

    RUN sistema/internet/fontes/InternetBank111.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_dtmvtolt,
                                                   INPUT aux_cddopcao,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF RETURN-VALUE <> "OK" THEN
        {&out} aux_dsmsgerr.

    FOR EACH xml_operacao NO-LOCK:

        {&out} xml_operacao.dslinxml.

    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao112:

    ASSIGN aux_nrctraar = INTEGER(GET-VALUE("nrctraar")).

    IF  NOT aux_flgcript THEN /* Nao possui criptografia no front e autenticacao e realizada junto com a propria operacao*/
        DO:
            RUN proc_operacao2.

            IF   RETURN-VALUE = "NOK"   THEN
                 RETURN "NOK".
        END. 

    RUN sistema/internet/fontes/InternetBank112.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_nrctraar,
                                                   INPUT "996",
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF RETURN-VALUE <> "OK" THEN
        {&out} aux_dsmsgerr.

    FOR EACH xml_operacao NO-LOCK:

        {&out} xml_operacao.dslinxml.

    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao113:

    ASSIGN aux_dtiniper = DATE(GET-VALUE("dtiniper"))
           aux_dtfimper = DATE(GET-VALUE("dtfimper"))
           aux_cddopcao = GET-VALUE("cddopcao").

    RUN sistema/internet/fontes/InternetBank113.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_dtmvtolt,
                                                   INPUT aux_dtiniper,
                                                   INPUT aux_dtfimper,
                                                   INPUT aux_cddopcao,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF RETURN-VALUE <> "OK" THEN
        {&out} aux_dsmsgerr.

    FOR EACH xml_operacao NO-LOCK:

        {&out} xml_operacao.dslinxml.

    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao114:

    ASSIGN aux_flgtipar = INTEGER(GET-VALUE("flgtipar"))
           aux_detdocto = GET-VALUE("nrdocmto").

    RUN sistema/internet/fontes/InternetBank114.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_flgtipar,
                                                   INPUT aux_detdocto,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF RETURN-VALUE <> "OK" THEN
        {&out} aux_dsmsgerr.

    FOR EACH xml_operacao NO-LOCK:

        {&out} xml_operacao.dslinxml.

    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao115:

    ASSIGN aux_dtmvtopg = DATE(GET-VALUE("dtmvtopg"))
           aux_idconsum = DECI(GET-VALUE("nrdocmto"))
           aux_cdhisdeb = INTE(GET-VALUE("cdhistor"))
           aux_flcadast = INTE(GET-VALUE("flcadast")).

    RUN sistema/internet/fontes/InternetBank115.p 
                                         (INPUT aux_cdcooper,
                                          INPUT aux_nrdconta,
                                          INPUT aux_idseqttl,
                                          INPUT aux_dtmvtolt,
                                          INPUT aux_dtmvtopg,
                                          INPUT aux_idconsum,
                                          INPUT aux_cdhisdeb,
                                          INPUT aux_flcadast,
                                         OUTPUT aux_dsmsgerr,
                                         OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr. 
        END.

    FOR EACH xml_operacao NO-LOCK:

        {&out} xml_operacao.dslinxml.

    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

/* gravar o resgate de aplicações */
PROCEDURE proc_operacao116:
    
    ASSIGN aux_dsaplica = GET-VALUE("aux_dsaplica")
           aux_flmensag = INT(GET-VALUE("aux_flmensag")).

    RUN sistema/internet/fontes/InternetBank116.p (INPUT aux_cdcooper,
                                                   INPUT 90, /*cdagenci*/
                                                   INPUT 900, /*nrdcaixa*/
                                                   INPUT "996", /*cdoperad*/
                                                   INPUT "INTERNETBANK", /*nmdatela*/
                                                   INPUT 3, /*idorigem*/
                                                   INPUT aux_inproces,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_dtmvtolt,
                                                   INPUT aux_dtmvtopr,
                                                   INPUT LOGICAL(aux_flmensag),
                                                   INPUT TRUE,  /*flgerlog*/
                                                   INPUT FALSE, /*flgctain - Resgate para conta investimento */ 
                                                   INPUT "RESGAT", /*cdprogra*/
                                                   INPUT aux_dsaplica, /*Aplicacoes do resgate*/
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.
                   
        END. 

    {&out} aux_tgfimprg.        

END PROCEDURE.


PROCEDURE proc_operacao117:

    aux_nrcnvpag = INTE(GET-VALUE("aux_nrcnvpag")).
    aux_nrremret = INTE(GET-VALUE("aux_nrremret")).

    RUN sistema/internet/fontes/InternetBank117.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_nrcnvpag,
                                                   INPUT aux_nrremret,
                                                   INPUT aux_dtmvtolt,
                                                   INPUT 3, /*idorigem*/
                                                  OUTPUT aux_nmarquiv,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF RETURN-VALUE <> "OK" THEN
        {&out} aux_dsmsgerr.

    /** Ja retorna do Oracle um XML... */
    FOR EACH xml_operacao NO-LOCK:

        {&out} xml_operacao.dslinxml.

    END.

    {&out} aux_tgfimprg.

END PROCEDURE.


PROCEDURE proc_operacao118:

    ASSIGN aux_dtiniper = DATE(GET-VALUE("aux_dtinipro"))
           aux_dtfimper = DATE(GET-VALUE("aux_dtfimpro"))
           aux_nriniseq = INTE(GET-VALUE("aux_iniconta"))
           aux_nrregist = INTE(GET-VALUE("aux_nrregist")).

    RUN sistema/internet/fontes/InternetBank118.p 
                                                (INPUT aux_cdcooper,
                                                 INPUT aux_nrdconta,
                                                 INPUT aux_idseqttl,
                                                 INPUT aux_dtmvtolt,
                                                 INPUT aux_dtiniper,
                                                 INPUT aux_dtfimper,
                                                 INPUT aux_nriniseq,
                                                 INPUT aux_nrregist,
                                                OUTPUT aux_dsmsgerr,
                                                OUTPUT TABLE xml_operacao25).
                                                 
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr aux_tgfimprg.
            RETURN.
        END.
        
    {&out} "<PROTOCOLOS>".
    
    FOR EACH xml_operacao25 NO-LOCK:

        {&out} xml_operacao25.dscabini xml_operacao25.dtmvtolt
               xml_operacao25.dttransa xml_operacao25.hrautent 
               xml_operacao25.vldocmto xml_operacao25.nrdocmto 
               xml_operacao25.dsinfor1 xml_operacao25.dsinfor2 
               xml_operacao25.dsinfor3 xml_operacao25.dsprotoc 
               xml_operacao25.qttotreg xml_operacao25.cdtippro
               xml_operacao25.dscedent xml_operacao25.cdagenda
               xml_operacao25.nrseqaut xml_operacao25.nmprepos
               xml_operacao25.nrcpfpre xml_operacao25.nmoperad
               xml_operacao25.nrcpfope xml_operacao25.cdbcoctl
               xml_operacao25.cdagectl xml_operacao25.dscabfim.
    
    END.
    
    {&out} "</PROTOCOLOS>" aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao119:

    ASSIGN aux_detagend = GET-VALUE("detagend").

    IF  NOT aux_flgcript THEN /* Nao possui criptografia no front e autenticacao e realizada junto com a propria operacao*/
        DO:
            RUN proc_operacao2.

            IF   RETURN-VALUE = "NOK"   THEN
                 RETURN "NOK".
        END. 

    RUN sistema/internet/fontes/InternetBank119.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_detagend,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF RETURN-VALUE <> "OK" THEN
        {&out} aux_dsmsgerr.

    FOR EACH xml_operacao NO-LOCK:

        {&out} xml_operacao.dslinxml.

    END.

    {&out} aux_tgfimprg.

END PROCEDURE.


PROCEDURE proc_operacao120:

    ASSIGN aux_nrcnvpag = INTE(GET-VALUE("aux_nrcnvpag"))
           aux_tpdtermo = INTE(GET-VALUE("aux_tpdtermo"))
           aux_confirma = INTE(GET-VALUE("aux_confirma")).

    RUN sistema/internet/fontes/InternetBank120.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_nrcnvpag,
                                                   INPUT aux_tpdtermo,
                                                   INPUT aux_confirma,
                                                   INPUT aux_dtmvtolt,
                                                   INPUT "996", /** cdoperad */
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT xml_operacao).
                                                                              
    IF RETURN-VALUE <> "OK" THEN                                              
        {&out} aux_dsmsgerr.

    /** Ja retorna do Oracle um XML... */
    {&out} xml_operacao.

    {&out} aux_tgfimprg.

END PROCEDURE.


PROCEDURE proc_operacao121:
                          
    ASSIGN aux_cdagenci = INTEGER(GET-VALUE("cdagenci")).

    RUN sistema/internet/fontes/InternetBank121.p (INPUT aux_cdcooper,
                                                   INPUT aux_cdagenci,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_nrdconta,
                                                   OUTPUT aux_dsmsgerr,
                                                   OUTPUT TABLE xml_operacao).
 
    IF RETURN-VALUE <> "OK" THEN
        {&out} aux_dsmsgerr.

    FOR EACH xml_operacao NO-LOCK:

        {&out} xml_operacao.dslinxml.

    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

/* Buscar lista de cooperativas ativas  */
PROCEDURE proc_operacao122:

    RUN sistema/internet/fontes/InternetBank122.p (OUTPUT TABLE xml_operacao).

    FOR EACH xml_operacao NO-LOCK:
                 
        {&out} xml_operacao.dslinxml.

    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

/* Calcula as taxas do credito pre-aprovado */
PROCEDURE proc_operacao123:
    
    ASSIGN aux_vlemprst = DEC(GET-VALUE("vlemprst"))
           aux_vlparepr = DEC(GET-VALUE("vlparepr"))
           aux_nrparepr = INTE(GET-VALUE("nrparepr"))
           aux_dtvencto = DATE(GET-VALUE("dtvencto")).

    RUN sistema/internet/fontes/InternetBank123.p (INPUT aux_cdcooper,
                                                   INPUT 90,  /*cdagenci*/
                                                   INPUT 900, /*nrdcaixa*/
                                                   INPUT 1,   /*cdoperad*/
                                                   INPUT "INTERNETBANK",
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_dtmvtolt,
                                                   INPUT aux_vlemprst,
                                                   INPUT aux_vlparepr,
                                                   INPUT aux_nrparepr,
                                                   INPUT aux_dtvencto,
                                                   OUTPUT aux_dsmsgerr,
                                                   OUTPUT TABLE xml_operacao).
    
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.
                   
        END. 
    
    {&out} aux_tgfimprg.        

END PROCEDURE.

/* Carregar Menu de Servicos do Mobile Bank */
PROCEDURE proc_operacao124:

    RUN sistema/internet/fontes/InternetBank124.p (OUTPUT TABLE xml_operacao).

    FOR EACH xml_operacao NO-LOCK:
                 
        {&out} xml_operacao.dslinxml.

    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao125:

    RUN sistema/internet/fontes/InternetBank125.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF RETURN-VALUE <> "OK" THEN
        {&out} aux_dsmsgerr.

    FOR EACH xml_operacao NO-LOCK:

        {&out} xml_operacao.dslinxml.

    END.

    {&out} aux_tgfimprg.
        
END PROCEDURE.        

/* Valida autorização de transação Mobile */
PROCEDURE proc_operacao126:
    
    ASSIGN aux_nrcpfcgc = DECI(GET-VALUE("nrcpfcgc"))
           aux_dssenlet = GET-VALUE("dssenlet")   
           aux_vldshlet = LOGICAL(GET-VALUE("vldshlet"))
           aux_inaceblq = INTE(GET-VALUE("inaceblq"))
           aux_dsorigip = GET-VALUE("dsorigip").

    IF  aux_vldshlet  THEN
        DO:
            IF  aux_flgcript  THEN /** Utiliza criptografia **/
                DO:
                    RUN sistema/generico/procedures/b1wgencrypt.p PERSISTENT 
                        SET h-b1wgencrypt (INPUT aux_nrdconta).
            
                    ASSIGN aux_dssenlet = DYNAMIC-FUNCTION("decriptar" IN h-b1wgencrypt,
                                                           INPUT aux_dssenlet,
                                                           INPUT aux_nrdconta).
        
                    DELETE PROCEDURE h-b1wgencrypt.
                END.
        END.

    RUN sistema/internet/fontes/InternetBank126.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_nrcpfcgc, 
                                                   INPUT aux_dssenlet,
                                                   INPUT aux_cddsenha,
                                                   INPUT aux_vldshlet,
                                                   INPUT aux_inaceblq,
                                                   INPUT aux_nripuser,
                                                   INPUT aux_dsorigip,
                                                   INPUT aux_flmobile,
                                                  OUTPUT aux_dsmsgerr).
    
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.

   {&out} aux_tgfimprg.
        
END PROCEDURE.

/* Verificao do tipo de conta (Mobile) */
PROCEDURE proc_operacao127:

    RUN sistema/internet/fontes/InternetBank127.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr aux_tgfimprg. 
            RETURN.
        END.

    FOR EACH xml_operacao NO-LOCK: 

        {&out} xml_operacao.dslinxml.
    
    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao128:

     ASSIGN aux_cddbanco = INTE(GET-VALUE("aux_cddbanco"))
            aux_cdageban = INTE(GET-VALUE("aux_cdageban"))
            aux_cdcooper = INTE(GET-VALUE("aux_cdcooper")).
           
    RUN sistema/internet/fontes/InternetBank128.p (INPUT aux_cdcooper,
                                                   INPUT aux_cddbanco,
                                                   INPUT aux_cdageban,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).
    
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:

            {&out} xml_operacao.dslinxml.

        END.
        
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao129:

    ASSIGN aux_dtmvtolt = DATE(GET-VALUE("dtmvtolt"))
           aux_dtiniper = DATE(GET-VALUE("dtiniper"))
           aux_dtfimper = DATE(GET-VALUE("dtfimper"))
           aux_flgregis = INTE(GET-VALUE("flgregis")).

    RUN sistema/internet/fontes/InternetBank129.p (INPUT aux_cdcooper,
                                                   INPUT aux_dtmvtolt,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_dtiniper,
                                                   INPUT aux_dtfimper,
                                                   INPUT (IF aux_flgregis = 1
                                                          THEN TRUE ELSE FALSE),
                                                   OUTPUT aux_dsmsgerr,
                                                   OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    ELSE
        FOR EACH xml_operacao NO-LOCK: 

            {&out} xml_operacao.dslinxml.
        
        END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao130:

    ASSIGN aux_dtmvtolt = DATE(GET-VALUE("dtmvtolt"))
           aux_dtiniper = DATE(GET-VALUE("dtiniper"))
           aux_dtfimper = DATE(GET-VALUE("dtfimper"))
           aux_flgregis = INTE(GET-VALUE("flgregis")).

    RUN sistema/internet/fontes/InternetBank130.p (INPUT aux_cdcooper,
                                                   INPUT aux_dtmvtolt,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_dtiniper,
                                                   INPUT aux_dtfimper,
                                                   INPUT (IF aux_flgregis = 1
                                                          THEN TRUE ELSE FALSE),
                                                   OUTPUT aux_dsmsgerr,
                                                   OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    ELSE
        FOR EACH xml_operacao NO-LOCK: 

            {&out} xml_operacao.dslinxml.
        
        END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao131:

    ASSIGN aux_nrborder = INTE(GET-VALUE("nrborder"))
           aux_dtmvtolt = DATE(GET-VALUE("dtmvtolt"))
           aux_nriniseq = INTE(GET-VALUE("nriniseq"))
           aux_nrregist = INTE(GET-VALUE("nrregist")).

    RUN sistema/internet/fontes/InternetBank131.p (INPUT aux_cdcooper,
                                                   INPUT aux_dtmvtolt,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_nrborder,
                                                   INPUT aux_nriniseq,
                                                   INPUT aux_nrregist,
                                                   OUTPUT aux_dsmsgerr,
                                                   OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    ELSE
        FOR EACH xml_operacao NO-LOCK: 

            {&out} xml_operacao.dslinxml.
        
        END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao132:

    ASSIGN aux_nrborder = INTE(GET-VALUE("nrborder"))
           aux_dtmvtolt = DATE(GET-VALUE("dtmvtolt"))
           aux_nriniseq = INTE(GET-VALUE("nriniseq"))
           aux_nrregist = INTE(GET-VALUE("nrregist")).

    RUN sistema/internet/fontes/InternetBank132.p (INPUT aux_cdcooper,
                                                   INPUT aux_dtmvtolt,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_nrborder,
                                                   INPUT aux_nriniseq,
                                                   INPUT aux_nrregist,
                                                   OUTPUT aux_dsmsgerr,
                                                   OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    ELSE
        FOR EACH xml_operacao NO-LOCK: 

            {&out} xml_operacao.dslinxml.
        
        END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao133:

    /* O número do documento vem separado por ";" */
    ASSIGN aux_cdbandoc = INTE(GET-VALUE("cdbandoc"))
           aux_nrdctabb = INTE(GET-VALUE("nrdctabb"))
           aux_nrcnvcob = INTE(GET-VALUE("nrcnvcob"))
           aux_dsdocmto = GET-VALUE("nrdocmto")
           aux_dsdemail = GET-VALUE("dsdemail")
           aux_cdtiplog = INTE(GET-VALUE("cdtipolog")).

    RUN sistema/internet/fontes/InternetBank133.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_cdbandoc,
                                                   INPUT aux_nrdctabb,
                                                   INPUT aux_nrcnvcob,
                                                   INPUT aux_dsdocmto,
                                                   INPUT aux_dsdemail,
                                                   INPUT aux_cdtiplog,
                                                  OUTPUT aux_dsmsgerr).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.

    {&out} aux_tgfimprg.
END PROCEDURE.

PROCEDURE proc_operacao134:

     ASSIGN aux_cdispbif = INTE(GET-VALUE("aux_cdispbif"))
            aux_cdcooper = INTE(GET-VALUE("aux_cdcooper")).
         
    RUN sistema/internet/fontes/InternetBank134.p (INPUT aux_cdcooper,
                                                   INPUT aux_cdispbif,
                                                   OUTPUT aux_dsmsgerr,
                                                   OUTPUT TABLE xml_operacao).
    
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:

            {&out} xml_operacao.dslinxml.

        END.
        
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao135:

    DEF VAR aux_nrsequen AS   INTE                                       NO-UNDO.
    DEF VAR aux_qtregpag AS   INTE                                       NO-UNDO.

    ASSIGN aux_nrsequen = INTE(GET-VALUE("aux_nrsequen"))
           aux_dtiniper = DATE(GET-VALUE("aux_dtiniper"))
           aux_dtfimper = DATE(GET-VALUE("aux_dtfimper"))
           aux_qtregpag = INTE(GET-VALUE("aux_qtregpag")).
    
    RUN sistema/internet/fontes/InternetBank135.p (INPUT aux_cdcooper,
                                                                                                   INPUT aux_nrdconta,
                                                                                                   INPUT aux_nrsequen,
                                                                                                   INPUT aux_dtiniper,
                                                                                                   INPUT aux_dtfimper,
                                                                                                   INPUT aux_qtregpag,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF RETURN-VALUE <> "OK" THEN
        {&out} aux_dsmsgerr.

    FOR EACH xml_operacao NO-LOCK:

        {&out} xml_operacao.dslinxml.

    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao136:

    RUN sistema/internet/fontes/InternetBank136.p (INPUT aux_cdcooper,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF RETURN-VALUE <> "OK" THEN
        {&out} aux_dsmsgerr.

    FOR EACH xml_operacao NO-LOCK:

        {&out} xml_operacao.dslinxml.

    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao137:

    RUN sistema/internet/fontes/InternetBank137.p(INPUT aux_cdcooper,
                                                  INPUT 90,  /* cdagenci */
                                                  INPUT 900, /* nrdcaixa */
                                                  INPUT "996", /* cdoperad */
                                                  INPUT "INTERNETBANK",
                                                  INPUT 3,   /* idorigem */
                                                  INPUT "",  /* cdprogra */
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                 OUTPUT aux_dsmsgerr). 
                    
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
                
    {&out} aux_tgfimprg.

END PROCEDURE.


PROCEDURE proc_operacao138:

    aux_dsboleto = GET-VALUE("aux_dsboleto").
    
    RUN sistema/internet/fontes/InternetBank138.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_dsboleto,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF RETURN-VALUE <> "OK" THEN
        {&out} aux_dsmsgerr.

    /** Ja retorna do Oracle um XML... */
    FOR EACH xml_operacao NO-LOCK: 

        {&out} xml_operacao.dslinxml.

    END.
    

    {&out} aux_tgfimprg.

END PROCEDURE.


PROCEDURE proc_operacao139:
                    
    aux_tpdaacao = INTE(GET-VALUE("aux_tpdaacao")).
    
    RUN sistema/internet/fontes/InternetBank139.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_tpdaacao,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT aux_flgpgtib).

    IF RETURN-VALUE <> "OK" THEN
        {&out} aux_dsmsgerr.

    /** Retorna o indicador */
    {&out} aux_flgpgtib.

    {&out} aux_tgfimprg.

END PROCEDURE.


PROCEDURE proc_operacao140:

    ASSIGN aux_dtiniper = DATE(GET-VALUE("dtiniper"))
           aux_dtfimper = DATE(GET-VALUE("dtfimper"))
		   aux_nrregist = INTEGER(GET-VALUE("nrregist"))
           aux_nriniseq = INTEGER(GET-VALUE("nriniseq")).

    RUN sistema/internet/fontes/InternetBank140.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_dtiniper,
                                                   INPUT aux_dtfimper,
												   INPUT aux_nrregist,
												   INPUT aux_nriniseq,												   
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    ELSE
        FOR EACH xml_operacao NO-LOCK:
            {&out} xml_operacao.dslinxml.
        END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.


PROCEDURE proc_operacao141:

    ASSIGN aux_lisrowid = STRING(GET-VALUE("lisrowid"))
           aux_tpoperac = INTE(GET-VALUE("tpoperac"))
           aux_nrcpfapr = DECI(GET-VALUE("nrcpfapr"))
           aux_flsolest = INTE(GET-VALUE("flsolest"))
           aux_dsarquiv = GET-VALUE("dsarquiv")
           aux_dsdireto = GET-VALUE("dsdireto")
           aux_idopdebi = INTE(GET-VALUE("idopdebi"))
           aux_dtcredit = DATE(GET-VALUE("dtcredit"))
           aux_dtdebito = DATE(GET-VALUE("dtdebito"))
           aux_flgravar = INTE(GET-VALUE("flgravar"))
           aux_vltarapr = DECI(GET-VALUE("vltarapr"))
           aux_xmldados = GET-VALUE("xmldados")
           aux_dssessao = GET-VALUE("dssessao")
           aux_dtmvtolt = DATE(GET-VALUE("dtmvtolt")).

    RUN sistema/internet/fontes/InternetBank141.p (INPUT aux_cdcooper,
                                                   INPUT aux_dtmvtolt,
                                                   INPUT aux_lisrowid,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_nrcpfapr,
                                                   INPUT aux_flsolest,
                                                   INPUT aux_dsarquiv,
                                                   INPUT aux_dsdireto,
                                                   INPUT aux_tpoperac,
                                                   INPUT aux_idopdebi,
                                                   INPUT aux_dtcredit,
                                                   INPUT aux_dtdebito,
                                                   INPUT aux_flgravar,
                                                   INPUT aux_vltarapr,
                                                   INPUT aux_xmldados,
                                                   INPUT aux_dssessao,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).
    IF  RETURN-VALUE = "NOK"  THEN DO:

        {&out} aux_dsmsgerr.

        FIND FIRST xml_operacao NO-LOCK NO-ERROR.
        IF  AVAIL xml_operacao THEN DO:
            {&out} xml_operacao.dslinxml.
        END.
        
            
    END.        
    ELSE
        FOR EACH xml_operacao NO-LOCK: 
            {&out} xml_operacao.dslinxml.
        END.

    {&out} aux_tgfimprg.

END PROCEDURE.


PROCEDURE proc_operacao142:

    ASSIGN aux_nrdctemp = STRING(GET-VALUE("nrdctemp"))
           aux_nrcpfemp = STRING(GET-VALUE("nrcpfemp"))
           aux_nmprimtl = STRING(GET-VALUE("nmprimtl"))
           aux_dsdcargo = STRING(GET-VALUE("dsdcargo"))
           aux_dtadmiss = STRING(GET-VALUE("dtadmiss"))
           aux_dstelefo = STRING(GET-VALUE("dstelefo"))
           aux_dsdemail = STRING(GET-VALUE("dsdemail"))
           aux_nrregger = STRING(GET-VALUE("nrregger"))
           aux_nrodopis = STRING(GET-VALUE("nrodopis"))
           aux_nrdactps = STRING(GET-VALUE("nrdactps"))
           aux_altera   = STRING(GET-VALUE("altera"))
		   aux_nrcpfope = DECI(GET-VALUE("nrcpfope")).

    RUN sistema/internet/fontes/InternetBank142.p (INPUT aux_nrdctemp,
                                                   INPUT aux_nrcpfemp,
                                                   INPUT aux_nmprimtl,
                                                   INPUT aux_dsdcargo,
                                                   INPUT aux_dtadmiss,
                                                   INPUT aux_dstelefo,
                                                   INPUT aux_dsdemail,
                                                   INPUT aux_nrregger,
                                                   INPUT aux_nrodopis,
                                                   INPUT aux_nrdactps,
                                                   INPUT aux_altera,
                                                   INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_nrcpfope,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).
    
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
            {&out} xml_operacao.dslinxml.
        END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao143:

    RUN sistema/internet/fontes/InternetBank143.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_dtmvtolt,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    ELSE
        FOR EACH xml_operacao NO-LOCK:
            {&out} xml_operacao.dslinxml.
        END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao144:

      
    ASSIGN aux_lisrowid = STRING(GET-VALUE("aux_lisrowid")).
    
    RUN sistema/internet/fontes/InternetBank144.p (INPUT aux_lisrowid,
                                                   OUTPUT aux_dsmsgerr,
                                                   OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    ELSE
        FOR EACH xml_operacao NO-LOCK:
            {&out} xml_operacao.dslinxml.
        END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao145:

    ASSIGN aux_nrdctemp = STRING(GET-VALUE("nrdctemp"))
           aux_nrcpfemp = STRING(GET-VALUE("nrcpfemp")).

    RUN sistema/internet/fontes/InternetBank145.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdctemp,
                                                   INPUT aux_nrcpfemp, 
                                                   OUTPUT aux_dsmsgerr,
                                                   OUTPUT aux_nmprimtl).

    IF  RETURN-VALUE = "NOK"  THEN
    DO:
        {&out} aux_dsmsgerr. 
    END.
    ELSE
        {&out} aux_nmprimtl.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao146:

    ASSIGN aux_nmarquiv = STRING(GET-VALUE("aux_nmarquiv"))
           aux_dsdireto = STRING(GET-VALUE("aux_dsdireto"))
           aux_nrseqpag = INT(GET-VALUE("aux_nrseqpag")).
           
          RUN sistema/internet/fontes/InternetBank146.p (INPUT aux_cdcooper,
                                                          INPUT aux_nrdconta,
                                                          INPUT aux_nmarquiv,
                                                          INPUT aux_dsdireto,
                                                          INPUT aux_nrseqpag,
                                                          OUTPUT aux_dsmsgerr,
                                                          OUTPUT TABLE xml_operacao).
                                                        
    IF RETURN-VALUE = "NOK"  THEN
      {&out} aux_dsmsgerr. 
    ELSE 
      DO: 
        FOR EACH xml_operacao NO-LOCK:
          {&out} xml_operacao.dslinxml. 
        END.       
      END.
    
    {&out} aux_tgfimprg.   

END PROCEDURE.

PROCEDURE proc_operacao147:

    ASSIGN aux_nrdctemp = STRING(GET-VALUE("nrdctemp"))
           aux_nrcpfemp = STRING(GET-VALUE("nrcpfemp"))
           aux_cdempres =    INT(GET-VALUE("cdempres"))
           aux_idtpcont = STRING(GET-VALUE("idtpcont"))
		   aux_nrcpfope =   DECI(GET-VALUE("nrcpfope")).

    RUN sistema/internet/fontes/InternetBank147.p (INPUT aux_nrdctemp,
                                                   INPUT aux_nrcpfemp,
                                                   INPUT aux_cdempres,
                                                   INPUT aux_idtpcont,
                                                   INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_nrcpfope,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    ELSE
        {&out} aux_nmprimtl.
    
    {&out} aux_tgfimprg.

END PROCEDURE.


PROCEDURE proc_operacao148:

    ASSIGN aux_tpoperac = INTE(GET-VALUE("tpoperac"))
           aux_idapurac = INTE(GET-VALUE("idapurac")).

    RUN sistema/internet/fontes/InternetBank148.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_tpoperac,
                                                   INPUT aux_idapurac,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK: 
            {&out} xml_operacao.dslinxml.
        END.

    {&out} aux_tgfimprg.

END PROCEDURE.


PROCEDURE proc_operacao149:

    ASSIGN aux_dtiniper = DATE(GET-VALUE("dtiniper"))
           aux_dtfimper = DATE(GET-VALUE("dtfimper"))
           aux_insittit = INTE(GET-VALUE("insituac"))
           aux_dsinform = STRING(GET-VALUE("tpemissa"))
           aux_nrctatrf = INTE(GET-VALUE("nrctalfp"))
		   aux_nrcpfope = DECI(GET-VALUE("nrcpfope")).

    RUN sistema/internet/fontes/InternetBank149.p (INPUT aux_cdcooper,
                                                   INPUT aux_dtmvtolt,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_nrcpfope,
                                                   INPUT aux_dtiniper,
                                                   INPUT aux_dtfimper,
                                                   INPUT aux_insittit,
                                                   INPUT aux_dsinform,
                                                   INPUT aux_nrctatrf,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT aux_nmarquiv).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    ELSE
        {&out} aux_nmarquiv.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao150:

    ASSIGN  aux_nmarquiv = STRING(GET-VALUE("aux_nmarquiv"))
            aux_nrseqpag =    INT(GET-VALUE("aux_nrseqpag"))
            aux_cdempres =    INT(GET-VALUE("aux_cdempres"))
            aux_dtrefere = STRING(GET-VALUE("aux_dtrefere"))			
		    aux_nrcpfope =   DECI(GET-VALUE("aux_nrcpfope")).
  
    RUN sistema/internet/fontes/InternetBank150.p (INPUT aux_cdcooper,
                                                  INPUT aux_cdempres,
                                                  INPUT aux_nrcpfope,
                                                  INPUT aux_nrseqpag,
                                                  INPUT aux_nmarquiv,
                                                  INPUT aux_dtrefere,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).
    
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
            {&out} xml_operacao.dslinxml.
        END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao151:

    ASSIGN  aux_nrdconta =    INT(GET-VALUE("aux_nrdconta"))
            aux_lisrowid = STRING(GET-VALUE("aux_lisrowid"))
            aux_idtipfol =    INT(GET-VALUE("aux_idtipfol")).
    
  
   RUN sistema/internet/fontes/InternetBank151.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idtipfol,
                                                  INPUT aux_lisrowid,                                                 
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).
                                                  
  
    
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
            {&out} xml_operacao.dslinxml.
             
        END.

    {&out} aux_tgfimprg.

END PROCEDURE.


PROCEDURE proc_operacao152:

    ASSIGN  aux_nrdconta = INTE(GET-VALUE("aux_nrdconta"))
            aux_cdcooper = INTE(GET-VALUE("aux_cdcooper"))
            aux_dtmvtolt = DATE(GET-VALUE("aux_dtmvtolt"))
            aux_rowidmsg = STRING(GET-VALUE("aux_rowidmsg"))
            aux_tipoacao = STRING(GET-VALUE("aux_tipoacao")).
    
  
   RUN sistema/internet/fontes/InternetBank152.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_dtmvtolt,  
                                                  INPUT aux_rowidmsg,
                                                  INPUT aux_tipoacao,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).
                                                  
  
    
   IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
            {&out} xml_operacao.dslinxml.
        END.

    {&out} aux_tgfimprg.


END PROCEDURE.

PROCEDURE proc_operacao153:

    ASSIGN aux_nrcpfope = DECI(  GET-VALUE("nrcpfope"))
           aux_idseqttl = INTE(  GET-VALUE("idseqttl")) 
           aux_lisrowid = STRING(GET-VALUE("dsdrowid"))
           aux_tpoperac = INTE(  GET-VALUE("tpoperac"))
           aux_tpdpagto = INTE(  GET-VALUE("tpdpagto"))
           aux_sftcdbar = STRING(GET-VALUE("sftcdbar"))
           aux_cdbarras = STRING(GET-VALUE("cdbarras"))           
           aux_cdpagmto = INTE(  GET-VALUE("cdpagmto"))
           aux_dtcompet = STRING(GET-VALUE("dtcompet"))
           aux_dsidenti = STRING(GET-VALUE("dsidenti"))
           aux_vldoinss = DECI(  GET-VALUE("vldoinss"))
           aux_vloutent = DECI(  GET-VALUE("vloutent"))
           aux_vlatmjur = DECI(  GET-VALUE("vlatmjur"))
           aux_vlrtotal = DECI(  GET-VALUE("vlrtotal"))
           aux_dtvencim = STRING(GET-VALUE("dtvencim"))
           aux_idfisjur = INTE(  GET-VALUE("idfisjur"))
           aux_idleitur = INTE(  GET-VALUE("idleitur"))
           aux_dtdiadeb = STRING(GET-VALUE("dtdebito"))
           aux_tpvalida = STRING(GET-VALUE("tpvalida"))
           aux_dshistor = STRING(GET-VALUE("dshistor"))
           aux_indtpaga = INTE(  GET-VALUE("indtpaga"))
           aux_vlrlote  = DECI(  GET-VALUE("vlrlote")).           

    RUN sistema/internet/fontes/InternetBank153.p (INPUT aux_cdcooper,
                                                   INPUT aux_dtmvtolt,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_nrcpfope,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_lisrowid,
                                                   INPUT aux_tpoperac,
                                                   INPUT aux_tpdpagto,
                                                   INPUT aux_sftcdbar,
                                                   INPUT aux_cdbarras,
                                                   INPUT aux_cdpagmto,
                                                   INPUT aux_dtcompet,
                                                   INPUT aux_dsidenti,
                                                   INPUT aux_vldoinss,
                                                   INPUT aux_vloutent,
                                                   INPUT aux_vlatmjur,
                                                   INPUT aux_vlrtotal,
                                                   INPUT aux_dtvencim,
                                                   INPUT aux_idfisjur,
                                                   INPUT aux_idleitur,
                                                   INPUT aux_dtdiadeb,
                                                   INPUT aux_tpvalida,
                                                   INPUT aux_flmobile,
                                                   INPUT aux_dshistor,
                                                   INPUT aux_indtpaga,
                                                   INPUT aux_vlrlote,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
            {&out} xml_operacao.dslinxml.
        END.

   {&out} aux_tgfimprg.
END PROCEDURE.


PROCEDURE proc_operacao154:
    
    RUN sistema/internet/fontes/InternetBank154.p (INPUT aux_cdcooper,
                                                   INPUT 90,    /*cdagenci*/
                                                   INPUT 900,   /*nrdcaixa*/
                                                   INPUT 1,     /*cdoperad*/
                                                   INPUT "INTERNETBANK",
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_nrcpfope,
                                                   INPUT aux_dtmvtolt,
                                                   INPUT aux_dtmvtopr,
                                                   INPUT aux_inproces,
                                                   OUTPUT aux_dsmsgerr,
                                                   OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
            {&out} xml_operacao.dslinxml.
        END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao155:

    aux_nrctremp = INT(GET-VALUE("nrctremp")).
    
    RUN sistema/internet/fontes/InternetBank155.p (INPUT aux_cdcooper,
                                                   INPUT 90,    /*cdagenci*/
                                                   INPUT 900,   /*nrdcaixa*/
                                                   INPUT 1,     /*cdoperad*/
                                                   INPUT "INTERNETBANK",
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_nrcpfope,
                                                   INPUT aux_nrctremp,
                                                   INPUT aux_dtmvtolt,
                                                   INPUT aux_dtmvtoan,
                                                   OUTPUT aux_dsmsgerr,
                                                   OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
            {&out} xml_operacao.dslinxml.
        END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao156:

    aux_nrctremp = INT(GET-VALUE("nrctremp")).
    aux_listapar = GET-VALUE("listapar").
    aux_tipopgto = INT(GET-VALUE("tipopgto")).
    
    RUN sistema/internet/fontes/InternetBank156.p (INPUT aux_cdcooper,
                                                   INPUT 90,    /*cdagenci*/
                                                   INPUT 900,   /*nrdcaixa*/
                                                   INPUT 1,     /*cdoperad*/
                                                   INPUT "INTERNETBANK",
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_nrcpfope,
                                                   INPUT aux_nrctremp,
                                                   INPUT aux_dtmvtolt,
                                                   INPUT aux_dtmvtoan,
                                                   INPUT aux_dtmvtocd,
                                                   INPUT aux_listapar, 
                                                   INPUT aux_tipopgto,                                                  
                                                   OUTPUT aux_dsmsgerr,
                                                   OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
            {&out} xml_operacao.dslinxml.
        END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao157:

    ASSIGN aux_cddopcao = STRING(GET-VALUE("aux_cddopcao"))
           aux_cdcadead = INT(GET-VALUE("aux_cdcadead"))
           aux_cdcooper = INT(GET-VALUE("aux_cdcooper"))
           aux_nrdconta = INT(GET-VALUE("aux_nrdconta"))
           aux_inpessoa = INT(GET-VALUE("aux_inpessoa"))
           aux_invclopj = INT(GET-VALUE("aux_invclopj"))
           aux_idseqttl = INT(GET-VALUE("aux_idseqttl"))
           aux_nmextptp = STRING(GET-VALUE("aux_nmextptp"))
           aux_nrcpfptp = DECI(GET-VALUE("aux_nrcpfptp"))
           aux_dsemlptp = STRING(GET-VALUE("aux_dsemlptp"))
           aux_nrfonptp = STRING(GET-VALUE("aux_nrfonptp"))
           aux_nmlogptp = STRING(GET-VALUE("aux_nmlogptp")).
    
    RUN sistema/internet/fontes/InternetBank157.p (INPUT aux_cddopcao,
                                                   INPUT aux_cdcadead,
                                                   INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_inpessoa,
                                                   INPUT aux_invclopj,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_nmextptp,
                                                   INPUT aux_nrcpfptp,
                                                   INPUT aux_dsemlptp,
                                                   INPUT aux_nrfonptp,
                                                   INPUT aux_nmlogptp,
                                                   OUTPUT aux_dsmsgerr,
                                                   OUTPUT TABLE xml_operacao).
                                                   

                                            
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
            {&out} xml_operacao.dslinxml.
        END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao158:

    aux_nrctremp = INT(GET-VALUE("nrctremp")).
    aux_ordempgo = GET-VALUE("ordempgo").
    aux_qtdprepr = INT(GET-VALUE("qtdprepr")).
    aux_listapar = GET-VALUE("listapar").
    aux_tipopgto = INT(GET-VALUE("tipopgto")).
    
    RUN sistema/internet/fontes/InternetBank158.p (INPUT aux_cdcooper,
                                                   INPUT 90,    /*cdagenci*/
                                                   INPUT 900,   /*nrdcaixa*/
                                                   INPUT 1,     /*cdoperad*/
                                                   INPUT "INTERNETBANK",
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_nrcpfope,
                                                   INPUT aux_nrctremp,
                                                   INPUT aux_dtmvtolt,
                                                   INPUT aux_dtmvtoan,
                                                   INPUT aux_ordempgo,
                                                   INPUT aux_qtdprepr,
                                                   INPUT aux_listapar, 
                                                   INPUT aux_tipopgto,
                                                   INPUT aux_flmobile,
                                                   OUTPUT aux_dsmsgerr,
                                                   OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
            {&out} xml_operacao.dslinxml.
        END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

/*imprime declaracao pagamento internet bank */
PROCEDURE proc_operacao159:
    
    ASSIGN aux_nrctremp = INTE(GET-VALUE("nrctremp")).
                                                     
    RUN sistema/internet/fontes/InternetBank159.p (INPUT aux_cdcooper,
                                                   INPUT 90,  /*cdagenci*/
                                                   INPUT 900, /*nrdcaixa*/
                                                   INPUT 1,   /*cdoperad*/
                                                   INPUT "INTERNETBANK",
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_dtmvtolt,
                                                   INPUT aux_nrctremp,
                                                   OUTPUT aux_dsmsgerr,
                                                   OUTPUT TABLE xml_operacao).
    
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.
                   
        END. 
    {&out} aux_tgfimprg.        

END PROCEDURE.

PROCEDURE proc_operacao160:

    ASSIGN aux_nrrecben = DECI(GET-VALUE("nrrecben"))
           aux_dtmescom = GET-VALUE("dtmescom").

    RUN sistema/internet/fontes/InternetBank160.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_nrrecben,
                                                   INPUT aux_dtmescom,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.
                   
        END. 

    {&out} aux_tgfimprg.        

END PROCEDURE.

/*............................................................................*/

PROCEDURE proc_operacao161:

    ASSIGN aux_nrrecben = DECI(GET-VALUE("nrrecben"))
           aux_dtmescom = GET-VALUE("dtmescom").

    RUN sistema/internet/fontes/InternetBank161.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_nrrecben,
                                                   INPUT aux_dtmescom,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.
                   
        END. 

    {&out} aux_tgfimprg.        

END PROCEDURE.


/*Gera o extrato de juros e encargos */
PROCEDURE proc_operacao162:
    
    ASSIGN aux_dtexerci = GET-VALUE("aux_dtexerci")
	       aux_dsiduser = GET-VALUE("aux_dsiduser").

    RUN sistema/internet/fontes/InternetBank162.p (INPUT aux_cdcooper,
                                                   INPUT 90,  /*cdagenci*/
                                                   INPUT 900, /*nrdcaixa*/
                                                   INPUT 1,   /*cdoperad*/
                                                   INPUT "INTERNETBANK",
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_dtmvtolt,
                                                   INPUT aux_dtexerci,
												   INPUT aux_dsiduser,											   
                                                   OUTPUT aux_dsmsgerr,
                                                   OUTPUT TABLE xml_operacao).
    
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.
                   
        END. 
    {&out} aux_tgfimprg.        

END PROCEDURE.

/* Reprovacao de transacoes dos operadores de internet */
PROCEDURE proc_operacao163:
    
    ASSIGN aux_cdditens = GET-VALUE("aux_cdditens").

    RUN sistema/internet/fontes/InternetBank163.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT 900, /*nrdcaixa*/
                                                   INPUT 90,  /*cdagenci*/
                                                   INPUT 1,   /*cdoperad*/
                                                   INPUT aux_dtmvtolt,
                                                   INPUT 3,   /*Origem*/
                                                   INPUT "INTERNETBANK",
                                                   INPUT aux_cdditens,
                                                   INPUT aux_nrcpfope,   /* nrcpfope */
                                                   INPUT aux_idseqttl,
                                                   OUTPUT aux_dsmsgerr,
                                                   OUTPUT TABLE xml_operacao).
   IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.
                   
        END. 
    {&out} aux_tgfimprg.        

END PROCEDURE.

PROCEDURE proc_operacao164:


	ASSIGN aux_recidepr = INT(GET-VALUE("aux_recidepr"))
		   aux_dsiduser = STRING(GET-VALUE("aux_dsiduser"))
		   aux_dtcalcul = DATE(GET-VALUE("aux_dtcalcul"))
		   aux_flgentra = LOGICAL(GET-VALUE("aux_flgentra"))
		   aux_flgentrv = LOGICAL(GET-VALUE("aux_flgentrv"))
		   aux_nmarqimp = STRING(GET-VALUE("aux_nmarqimp"))
		   aux_nmarqpdf = STRING(GET-VALUE("aux_nmarqpdf"))
       aux_iddspscp = INTE(GET-VALUE("aux_iddspscp")).

	RUN sistema/internet/fontes/InternetBank164.p (INPUT aux_cdcooper,
												 INPUT 90,             /*par_cdagenci*/
												 INPUT 900,            /*par_nrdcaixa*/
												 INPUT 996,            /*par_cdoperad*/
												 INPUT "INTERNETBANK", /*par_nmdatela*/
												 INPUT 3,              /*par_idorigem*/
												 INPUT aux_nrdconta,
												 INPUT aux_idseqttl,
												 INPUT aux_dtmvtolt,
												 INPUT aux_dtmvtopr,
												 INPUT TRUE,           /*par_flgerlog*/
												 INPUT aux_recidepr,
												 INPUT 6, /*CET*/      /*par_idimpres*/
												 INPUT FALSE,          /*par_flgescra*/
												 INPUT 0,              /*par_nrpagina*/
												 INPUT FALSE,          /*par_flgemail*/
												 INPUT aux_dsiduser,
												 INPUT aux_dtcalcul,
												 INPUT aux_inproces,
												 INPUT 1,              /*par_promsini*/
												 INPUT IF aux_iddspscp = 1 THEN "INTERNETBANK" ELSE "", /* Parametro criado para permitir a utilizacao da operacao no piloto do novo IB */
												 INPUT FALSE,          /*par_flgentra*/                         
                        OUTPUT aux_dsmsgerr,
                        OUTPUT TABLE xml_operacao).
                        
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.
                   
        END. 
    {&out} aux_tgfimprg.        

END PROCEDURE.

    
/* Buscar pacote de tarifas do cooperado */
PROCEDURE proc_operacao165:

  ASSIGN aux_inpessoa = INTE(GET-VALUE("aux_inpessoa"))
		 aux_inconsul = INTE(GET-VALUE("aux_inconsul")).

	RUN sistema/internet/fontes/InternetBank165.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
												   INPUT aux_inpessoa,
												   INPUT aux_inconsul,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.

        END.

    {&out} aux_tgfimprg.

END PROCEDURE.

/* Consulta de permissões do menu mobile */
PROCEDURE proc_operacao166:

    RUN sistema/internet/fontes/InternetBank166.p (INPUT aux_cdcooper,
												 INPUT aux_nrdconta,
												 INPUT aux_idseqttl,
                                                   INPUT aux_nrcpfope,
												OUTPUT aux_dsmsgerr,
												OUTPUT TABLE xml_operacao).

	IF  RETURN-VALUE = "NOK"  THEN
	  {&out} aux_dsmsgerr.
	ELSE
	  FOR EACH xml_operacao NO-LOCK:
	  
		  {&out} xml_operacao.dslinxml.
				 
	  END. 

    {&out} aux_tgfimprg.

END PROCEDURE.

/* Retornar as informações de telefone e horários do SAC e da Ouvidoria */
PROCEDURE proc_operacao168:
    
    RUN sistema/internet/fontes/InternetBank168.p (INPUT aux_cdcooper,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.

        END.

    {&out} aux_tgfimprg.

END PROCEDURE.

/* Inserir pacote de tarifas do cooperado */
PROCEDURE proc_operacao167:

	ASSIGN aux_cdpacote = INTE(GET-VALUE("aux_cdpacote"))
		   aux_diadebit = INTE(GET-VALUE("aux_diadebit"))
		   aux_dtinivig = GET-VALUE("aux_dtinivig")
		   aux_vlpacote = DECI(GET-VALUE("aux_vlpacote")).

  IF  NOT aux_flgcript  THEN /* Nao possui criptografia no front e autenticacao e realizada junto com a propria operacao*/
      DO:
          RUN proc_operacao2.
          
          IF   RETURN-VALUE = "NOK"   THEN
               RETURN "NOK".
      END.

	RUN sistema/internet/fontes/InternetBank167.p (INPUT aux_cdcooper,
                                                 INPUT aux_nrdconta,
                                                 INPUT aux_nrcpfope,
                                                 INPUT aux_idseqttl,
                                                 INPUT aux_cdpacote,
                                                 INPUT aux_dtinivig,
                                                 INPUT aux_diadebit,												   
                                                 INPUT aux_vlpacote,
                                                OUTPUT aux_dsmsgerr,
                                                OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.
                   
        END. 

    {&out} aux_tgfimprg.        

END PROCEDURE.

/* Buscar dados do termo de adesao do pacote de tarifas */
PROCEDURE proc_operacao170:	

	RUN sistema/internet/fontes/InternetBank170.p (INPUT aux_cdcooper,
                                                 INPUT aux_nrdconta,
                                                 INPUT aux_idseqttl,
                                                 INPUT 90,
                                                 INPUT 900,
                                                 INPUT "1",
                                                 INPUT "IB170",
                                                 INPUT 3,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.
                   
        END. 

    {&out} aux_tgfimprg.        

END PROCEDURE.

/* Busca motivos da exclusao do DEBAUT */
PROCEDURE proc_operacao171:

    RUN sistema/internet/fontes/InternetBank171.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT 900, /*nrdcaixa*/
                                                   INPUT 90,  /*cdagenci*/
                                                   INPUT 1,   /*cdoperad*/
                                                   INPUT 3,   /*Origem*/
                                                   INPUT "INTERNETBANK",
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    ELSE
        FOR EACH xml_operacao NO-LOCK: 
    
            {&out} xml_operacao.dslinxml.
                    
        END.

    {&out} aux_tgfimprg.

END PROCEDURE.


/* Buscar dados do termo de adesao do pacote de tarifas */
PROCEDURE proc_operacao172:	

	ASSIGN aux_cdpacote = INTE(GET-VALUE("aux_cdpacote"))
           aux_dspacote = GET-VALUE("aux_nmpacote")
		   aux_dtdiadeb = GET-VALUE("aux_dtdiadeb")
		   aux_dtinivig = GET-VALUE("aux_dtinivig")
		   aux_vlpcttar = GET-VALUE("aux_vlpcttar").

	RUN sistema/internet/fontes/InternetBank172.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
												   INPUT 3,
                                                   INPUT aux_cdpacote,
                                                   INPUT aux_dspacote,
                                                   INPUT aux_dtinivig,
                                                   INPUT aux_dtdiadeb,
												   INPUT aux_vlpcttar,
                                                   OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.
                   
        END. 

    {&out} aux_tgfimprg.        

END PROCEDURE.

/* Operaçoes SMS (DEBAUT) */
PROCEDURE proc_operacao173:	

	ASSIGN aux_cddopcao = GET-VALUE("cddopcao")
         aux_flgacsms = GET-VALUE("flgacsms")
         aux_nrdddtfc = DECI(GET-VALUE("nrdddtfc"))
         aux_nrtelefo = DECI(GET-VALUE("nrtelefo")).

  IF  NOT aux_flgcript AND (aux_cddopcao = "A" OR aux_cddopcao = "E")  THEN /* Nao possui criptografia no front e autenticao e realizada junto com a propria operacao*/
      DO:
          RUN proc_operacao2.

          IF   RETURN-VALUE = "NOK"   THEN
               RETURN "NOK".
      END.

	RUN sistema/internet/fontes/InternetBank173.p (INPUT aux_cdcooper,
                                                 INPUT aux_nrdconta,
                                                 INPUT aux_idseqttl,
                                                 INPUT aux_cddopcao,
                                                 INPUT aux_dtmvtolt,
                                                 INPUT aux_flgacsms,
                                                 INPUT aux_nrdddtfc,
                                                 INPUT aux_nrtelefo,
                                                OUTPUT aux_dsmsgerr,
                                                OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
        
            {&out} xml_operacao.dslinxml.
                   
        END. 

    {&out} aux_tgfimprg.        

END PROCEDURE.

/* Operação de configurações */
PROCEDURE proc_operacao174:	

	RUN sistema/internet/fontes/InternetBank174.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).
    
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
    FOR EACH xml_operacao NO-LOCK:
    
        {&out} xml_operacao.dslinxml.
        
    END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

/* Grava configurações */
PROCEDURE proc_operacao175:	
    ASSIGN aux_idrazfan = INTE(GET-VALUE("aux_idrazfan")).
        
	RUN sistema/internet/fontes/InternetBank175.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
												   INPUT aux_idrazfan,
                                                  OUTPUT aux_dsmsgerr).
                                                 
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
   
    {&out} aux_tgfimprg.  

END PROCEDURE.

/* Integralizar as cotas de capital */
PROCEDURE proc_operacao176:
    
    ASSIGN aux_vintegra = DECIMAL(GET-VALUE("vlintegr")).
    
    RUN sistema/internet/fontes/InternetBank176.p (INPUT aux_cdcooper,
                           												 INPUT 90,             /* par_cdagenci */
                                                   INPUT 900,            /* par_nrdcaixa */
                                                   INPUT 996,            /* par_cdoperad */
                                                   INPUT "INTERNETBANK", /* par_nmdatela */
                                                   INPUT 3,              /* par_idorigem */
                                                   INPUT aux_nrdconta,   /* par_nrdconta */
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_dtmvtocd,
                                                   INPUT aux_vintegra,   /* valor integralizacao */
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
                          ELSE
        FOR EACH xml_operacao NO-LOCK:
            {&out} xml_operacao.dslinxml.
        END.
    {&out} aux_tgfimprg.

END PROCEDURE.

/* Cancelar integralizacao de cotas de capital */
PROCEDURE proc_operacao177:

    IF  NOT aux_flgcript  THEN /* Nao possui criptografia no front e autenticacao e realizada junto com a propria operacao*/
        DO:
            RUN proc_operacao2.

            IF   RETURN-VALUE = "NOK"   THEN
                 RETURN "NOK".
        END.
    
    ASSIGN aux_nrdrowid = GET-VALUE("nrdrowid").    
                              
    RUN sistema/internet/fontes/InternetBank177.p (INPUT aux_cdcooper,
                           												 INPUT 90,             /* par_cdagenci */
                                                   INPUT 900,            /* par_nrdcaixa */
                                                   INPUT 996,            /* par_cdoperad */
                                                   INPUT "INTERNETBANK", /* par_nmdatela */
                                                   INPUT 3,              /* par_idorigem */
                                                   INPUT aux_nrdconta,   /* par_nrdconta */
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_dtmvtolt,
                                                   INPUT aux_nrdrowid,   /* id do lancamento a ser excluído */
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao). 
                                                  
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
        FOR EACH xml_operacao NO-LOCK:
            {&out} xml_operacao.dslinxml.
        END.
    {&out} aux_tgfimprg.

END PROCEDURE.

/* Custodia de Cheque. */
PROCEDURE proc_operacao178:        

          ASSIGN aux_operacao =  INT(GET-VALUE("aux_operacao"))
                 aux_dtiniper = DATE(GET-VALUE("aux_dtiniper"))
                 aux_dtfimper = DATE(GET-VALUE("aux_dtfimper"))
                 aux_insithcc =  INT(GET-VALUE("aux_insithcc"))
                 aux_nrconven =  INT(GET-VALUE("aux_nrconven"))
                 aux_intipmvt =  INT(GET-VALUE("aux_intipmvt"))
                 aux_nrremret =  INT(GET-VALUE("aux_nrremret"))
                 aux_nrseqarq =  INT(GET-VALUE("aux_nrseqarq"))
                 aux_dscheque =      GET-VALUE("aux_dscheque")
                 aux_dsemiten =      GET-VALUE("aux_dsemiten")
                 aux_dtlibchq =      GET-VALUE("aux_dtlibera")
                 aux_dtcapchq =      GET-VALUE("aux_dtdcaptu")
                 aux_vlcheque =      GET-VALUE("aux_vlcheque")
                 aux_dsdocmc7 =      GET-VALUE("aux_dsdocmc7")
                 aux_nriniseq =  INT(GET-VALUE("aux_nriniseq"))
                 aux_nrregist =  INT(GET-VALUE("aux_nrregist")).
                              
    IF  NOT aux_flgcript AND aux_operacao = 6 THEN /* Nao possui criptografia no front e autenticacao e realizada junto com a propria operacao*/
        DO:
            RUN proc_operacao2.

            IF   RETURN-VALUE = "NOK"   THEN
                 RETURN "NOK".
        END.           
                              
    RUN sistema/internet/fontes/InternetBank178.p (INPUT aux_operacao,
                                                   INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_dtiniper,
                                                   INPUT aux_dtfimper,
                                                   INPUT aux_insithcc,
                                                   INPUT aux_nrconven,
                                                   INPUT aux_intipmvt,
                                                   INPUT aux_nrremret,
                                                   INPUT aux_nrseqarq,
                                                   INPUT aux_dscheque,
                                                   INPUT aux_dsemiten,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_dtlibchq,
                                                   INPUT aux_dtcapchq,
                                                   INPUT aux_vlcheque,
                                                   INPUT aux_dsdocmc7,
                                                   INPUT aux_nriniseq,
                                                   INPUT aux_nrregist,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao). 
                                                  
    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    ELSE
        FOR EACH xml_operacao NO-LOCK: 

        {&out} xml_operacao.dslinxml.
    
        END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

/* Desconto de Cheque. */
PROCEDURE proc_operacao179:

          ASSIGN aux_operacao =  INT(GET-VALUE("aux_operacao"))
                 aux_dtiniper = DATE(GET-VALUE("aux_dtiniper"))
                 aux_dtfimper = DATE(GET-VALUE("aux_dtfimper"))
                 aux_insitbdc =  INT(GET-VALUE("aux_insitbdc"))
                 aux_nriniseq =  INT(GET-VALUE("aux_nriniseq"))
                 aux_nrregist =  INT(GET-VALUE("aux_nrregist"))
                 aux_nrctrlim =  INT(GET-VALUE("aux_nrctrlim"))
                 aux_nrborder =  INT(GET-VALUE("aux_nrborder"))
                 aux_dtlibchq =     (GET-VALUE("aux_dtlibera"))
                 aux_dtcapchq =     (GET-VALUE("aux_dtdcaptu"))
                 aux_vlcheque =     (GET-VALUE("aux_vlcheque"))
                 aux_dtcustod =     (GET-VALUE("aux_dtcustod"))
                 aux_intipchq =     (GET-VALUE("aux_intipchq"))
                 aux_dsdocmc7 =     (GET-VALUE("aux_dsdocmc7"))
                 aux_nrremess =     (GET-VALUE("aux_nrremret"))
                 aux_iddspscp = INTE(GET-VALUE("aux_iddspscp")).
    
    IF  NOT aux_flgcript AND aux_operacao = 5 THEN /* Nao possui criptografia no front e autenticacao e realizada junto com a propria operacao*/
        DO:
            RUN proc_operacao2.

            IF   RETURN-VALUE = "NOK"   THEN
                 RETURN "NOK".
        END.       
    
    RUN sistema/internet/fontes/InternetBank179.p (INPUT aux_operacao, 
                                                   INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_nrcpfope,
                                                   INPUT aux_dtiniper,
                                                   INPUT aux_dtfimper,
                                                   INPUT aux_insitbdc,
                                                   INPUT aux_nriniseq,
                                                   INPUT aux_nrregist,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_nrctrlim,
                                                   INPUT aux_nrborder,
                                                   INPUT aux_dtlibchq,
                                                   INPUT aux_dtcapchq,
                                                   INPUT aux_vlcheque,
                                                   INPUT aux_dtcustod,
                                                   INPUT aux_intipchq,
                                                   INPUT aux_dsdocmc7,
                                                   INPUT aux_nrremess,
                                                   INPUT aux_iddspscp,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    ELSE
    FOR EACH xml_operacao NO-LOCK: 
      
        {&out} xml_operacao.dslinxml.
        
        END.
    {&out} aux_tgfimprg.

END PROCEDURE.

/* Calculo de Data Útil para Agendamento */
PROCEDURE proc_operacao180:

    ASSIGN  aux_dtmvtolt = DATE(GET-VALUE("dtmvtolt"))
            aux_dstpcons = STRING(GET-VALUE("dstpcons")).
                              
    RUN sistema/internet/fontes/InternetBank180.p (INPUT aux_cdcooper,
                                                   INPUT aux_dtmvtolt,
                                                   INPUT aux_dstpcons,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao). 
                                                  
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr aux_tgfimprg.
            RETURN.
    END.
    
    FIND FIRST xml_operacao NO-LOCK NO-ERROR.

    IF  AVAILABLE xml_operacao  THEN
        {&out} xml_operacao.dslinxml.
    
    {&out} aux_tgfimprg.      

END PROCEDURE.  

/* Recarga de Celular. */
PROCEDURE proc_operacao181:        

    ASSIGN aux_operacao    = INT(GET-VALUE("aux_operacao"))
           aux_cdoperadora = INT(GET-VALUE("aux_cdoperadora"))
           aux_cdproduto   = INT(GET-VALUE("aux_cdproduto"))
           aux_nrddd       = INT(GET-VALUE("aux_nrddd"))            
           aux_nrcelular   = INT(GET-VALUE("aux_nrcelular"))
           aux_nmcontato   = GET-VALUE("aux_nmcontato")
           aux_flgfavori   = INT(GET-VALUE("aux_flgfavori"))
           aux_vlrecarga   = DECI(GET-VALUE("aux_vlrecarga"))          
           aux_cdopcaodt   = INT(GET-VALUE("aux_cddopcao"))
           aux_qtmesagd    = INT(GET-VALUE("aux_qtdmeses"))
           aux_dtrecarga   = DATE(GET-VALUE("aux_dtrecarga")).
    
    RUN sistema/internet/fontes/InternetBank181.p (INPUT aux_operacao,
                                                   INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_cdoperadora,
                                                   INPUT aux_cdproduto,
                                                   INPUT aux_nrddd,
                                                   INPUT aux_nrcelular,
                                                   INPUT aux_nmcontato,
                                                   INPUT aux_flgfavori,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_nrcpfope,
                                                   INPUT aux_vlrecarga,
                                                   INPUT aux_cdopcaodt,
                                                   INPUT aux_dtrecarga,
                                                   INPUT aux_qtmesagd,
													   INPUT aux_flmobile,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    ELSE
    FOR EACH xml_operacao NO-LOCK: 
      
        {&out} xml_operacao.dslinxml.
        
    END.
    
    {&out} aux_tgfimprg.      

END PROCEDURE.               

PROCEDURE proc_operacao182:        
       
    RUN sistema/internet/fontes/InternetBank182.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_nrcpfope,
                                                   INPUT aux_dtmvtocd,                                                   
                                                   INPUT aux_flmobile,                                                   
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr. 
    ELSE
    FOR EACH xml_operacao NO-LOCK: 
      
        {&out} xml_operacao.dslinxml.
        
    END.
    
    {&out} aux_tgfimprg.      

END PROCEDURE.               

/* Operação para buscar valor do titulo vencido */
PROCEDURE proc_operacao186:
	
    DEF VAR aux_inmobile  AS INTE     NO-UNDO.

    ASSIGN aux_idseqttl		 = INTE(GET-VALUE("aux_idseqttl"))
	       aux_cdagenci		 = INTE(GET-VALUE("aux_cdagenci"))
	       aux_nrdcaixa		 = INTE(GET-VALUE("aux_nrdcaixa"))
	       aux_titulo1 		 = DECI(GET-VALUE("aux_titulo1"))
	       aux_titulo2 		 = DECI(GET-VALUE("aux_titulo2"))
	       aux_titulo3 		 = DECI(GET-VALUE("aux_titulo3"))
	       aux_titulo4 		 = DECI(GET-VALUE("aux_titulo4"))
	       aux_titulo5       = DECI(GET-VALUE("aux_titulo5"))
	       aux_codigo_barras = GET-VALUE("aux_codigo_barras").
			
    IF aux_flmobile THEN
       ASSIGN aux_inmobile = 1.
    ELSE
       ASSIGN aux_inmobile = 0.

	RUN sistema/internet/fontes/InternetBank186.p (INPUT aux_cdcooper,
	                                               INPUT aux_nrdconta,
	                                               INPUT aux_idseqttl,
                                                   INPUT aux_cdagenci,
												   INPUT aux_nrdcaixa,
                                                   INPUT aux_inmobile,
												   INPUT aux_titulo1,
												   INPUT aux_titulo2,
												   INPUT aux_titulo3,
												   INPUT aux_titulo4,
												   INPUT aux_titulo5,
												   INPUT aux_codigo_barras,
                                                   INPUT "996",
                                                   INPUT 3,
                                                  OUTPUT aux_dsmsgerr,
												  OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
    FOR EACH xml_operacao NO-LOCK:
    
        {&out} xml_operacao.dslinxml.
        
    END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

/* Consulta Horario Limite DARF/DAS */
PROCEDURE proc_operacao187:

	ASSIGN aux_tpdaguia = INTE(GET-VALUE("tpdaguia")).

    RUN sistema/internet/fontes/InternetBank187.p (INPUT aux_cdcooper,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_idseqttl,
                                                  INPUT aux_nrcpfope,
												  INPUT aux_dtmvtolt,
												  INPUT aux_tpdaguia, /* 1- DARF | 2 - DAS */
                                                  INPUT aux_flmobile,
                                                 OUTPUT aux_dsmsgerr,
                                                 OUTPUT TABLE xml_operacao).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr aux_tgfimprg.
            RETURN.
        END.

    FOR EACH xml_operacao NO-LOCK:
    
        {&out} xml_operacao.dslinxml.
        
    END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

/* Servico de SMS Cobranca */
PROCEDURE proc_operacao189:	
  
  ASSIGN aux_cddopcao   = GET-VALUE("cddopcao")
         aux_tpnommis   = INTE(GET-VALUE("tpnommis"))
         aux_nmemisms   = GET-VALUE("nmemisms")
         aux_idcontrato = INTE(GET-VALUE("idcontrato"))
         aux_idpacote   = INTE(GET-VALUE("idpacote")).
  
  IF  NOT aux_flgcript AND (aux_cddopcao = "A" OR aux_cddopcao = "CA") THEN /* Nao possui criptografia no front e autenticacao e realizada junto com a propria operacao*/
      DO:
          RUN proc_operacao2.
          
          IF   RETURN-VALUE = "NOK"   THEN
               RETURN "NOK".
      END.    
  
	RUN sistema/internet/fontes/InternetBank189.p (INPUT aux_cdcooper,
                                                 INPUT aux_nrdconta,
                                                 INPUT aux_idseqttl,
                                                 INPUT aux_nrcpfope,
                                                 INPUT aux_cddopcao,
                                                 INPUT aux_idcontrato,
                                                 INPUT aux_idpacote,
                                                 INPUT aux_tpnommis,
                                                 INPUT aux_nmemisms,
                                                 INPUT 1,
                                                 INPUT 100,
                                                OUTPUT aux_dsmsgerr,
                                                OUTPUT TABLE xml_operacao).

    IF  RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
    FOR EACH xml_operacao NO-LOCK:
    
        {&out} xml_operacao.dslinxml.
        
    END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

/* Operar pagamentos de DARF/DAS */
PROCEDURE proc_operacao188:

    ASSIGN  aux_dtapurac = DATE(GET-VALUE("aux_dtapurac"))
            aux_tpcaptur = INTE(GET-VALUE("aux_tpcaptur"))
            aux_nrcpfdrf = GET-VALUE("aux_nrcpfcgc")
            aux_nrrefere = DECI(GET-VALUE("aux_nrrefere"))
            aux_dtvencto = DATE(GET-VALUE("aux_dtvencto"))
            aux_cdtribut = GET-VALUE("aux_cdtribut")
            aux_vlrecbru = DECI(GET-VALUE("aux_vlrecbru"))
            aux_vlpercen = DECI(GET-VALUE("aux_vlpercen"))
            aux_vlprinci = DECI(GET-VALUE("aux_vlprinci"))
            aux_vlrmulta = DECI(GET-VALUE("aux_vlrmulta"))
            aux_vlrjuros = DECI(GET-VALUE("aux_vlrjuros"))
            aux_vlrtotal = DECI(GET-VALUE("aux_vlrtotal"))
            aux_dsexthis = GET-VALUE("aux_dsexthis")
            aux_idagenda = INTE(GET-VALUE("aux_idagenda"))
            aux_vlapagar = DECI(GET-VALUE("aux_vlapagar"))
            aux_cdbarras = GET-VALUE("aux_cdbarras")
            aux_lindigi1 = DECI(GET-VALUE("aux_lindigi1"))
            aux_lindigi2 = DECI(GET-VALUE("aux_lindigi2"))
            aux_lindigi3 = DECI(GET-VALUE("aux_lindigi3"))
            aux_lindigi4 = DECI(GET-VALUE("aux_lindigi4"))            
            aux_idefetiv = INTE(GET-VALUE("aux_idefetiv"))
            aux_dsnomfon = GET-VALUE("aux_dsnomfon")
            aux_tpleitor = INTE(GET-VALUE("aux_tpleitor"))
            aux_versaldo = INTE(GET-VALUE("aux_versaldo"))
            aux_tpdaguia = INTE(GET-VALUE("aux_tpdaguia"))
            aux_dtmvtopg = IF  aux_idagenda = 1  THEN /** Pagto data corrente **/
                              aux_dtmvtocd
                          ELSE
                              DATE(GET-VALUE("aux_dtmvtopg")).
                              
    RUN sistema/internet/fontes/InternetBank188.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_nrcpfope,
                                                   INPUT aux_dtmvtopg,
                                                   INPUT 3, /* internet */
                                                   INPUT aux_flmobile,
                                                   INPUT aux_idefetiv,
                                                   INPUT aux_tpdaguia, /* DARF/DAS */
                                                   INPUT aux_tpcaptur,
                                                   INPUT aux_lindigi1,
                                                   INPUT aux_lindigi2,
                                                   INPUT aux_lindigi3,
                                                   INPUT aux_lindigi4,
                                                   INPUT aux_cdbarras,
                                                   INPUT aux_dsexthis,
                                                   INPUT aux_vlrtotal,
                                                   INPUT aux_dsnomfon,
                                                   INPUT aux_dtapurac,
                                                   INPUT aux_nrcpfdrf,
                                                   INPUT aux_cdtribut,
                                                   INPUT aux_nrrefere,
                                                   INPUT aux_dtvencto,
                                                   INPUT aux_vlprinci,
                                                   INPUT aux_vlrmulta,
                                                   INPUT aux_vlrjuros,
                                                   INPUT aux_vlrecbru,
                                                   INPUT aux_vlpercen,
                                                   INPUT aux_idagenda,
                                                   INPUT aux_vlapagar,
                                                   INPUT aux_versaldo,
                                                   INPUT aux_tpleitor,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao). 
                                                  
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr aux_tgfimprg.
            RETURN.
        END.

    FOR EACH xml_operacao NO-LOCK:
    
        {&out} xml_operacao.dslinxml.
        
    END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

/* Solicitar Emprestimo */
PROCEDURE proc_operacao191:

    DEF VAR aux_dsmensag AS CHAR NO-UNDO.
	
    ASSIGN aux_dsdemail = GET-VALUE("aux_dsdemail")
           aux_qtpreemp = INTE(GET-VALUE("aux_qtparcel"))
           aux_vlemprst = DECI(GET-VALUE("aux_vlemprst"))
           aux_dsmensag = GET-VALUE("aux_dsmensag").

    RUN sistema/internet/fontes/InternetBank191.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_dsdemail,
                                                   INPUT aux_vlemprst,
                                                   INPUT aux_qtpreemp,
                                                   INPUT aux_dsmensag,
                                                   INPUT IF aux_flmobile THEN 10 ELSE 3,
                                                  OUTPUT aux_dsmsgerr). 
                                                  
    {&out} aux_dsmsgerr aux_tgfimprg.

END PROCEDURE.

/** Listar mensagems de aprovacao para Prepostos **/
PROCEDURE proc_operacao192:
        
    ASSIGN aux_nrcpfpre = DECI(GET-VALUE("aux_nrcpfpre"))
                   str_nrcpfope = STRING(GET-VALUE("str_nrcpfope"))
                   aux_iddopcao = INTE(GET-VALUE("aux_iddopcao")).
        
        /* salvar confirmacao */
        IF aux_iddopcao = 1 THEN
                DO:

                        RUN sistema/internet/fontes/InternetBank192.p (INPUT aux_cdcooper,
                                                                                                                   INPUT aux_nrdconta,
                                                                                                                   INPUT aux_nrcpfpre,
                                                                                                                   INPUT str_nrcpfope,
                                                                                                                   INPUT 1,
                                                                                                                   OUTPUT aux_dsmsgerr,
                                                                                                                   OUTPUT TABLE xml_operacao).
                                                  
                        IF  RETURN-VALUE = "NOK"  THEN
                                {&out} aux_dsmsgerr. 
                        ELSE
                                FOR EACH xml_operacao NO-LOCK:
                        
                                        {&out} xml_operacao.dslinxml. 
                                                
                                END.

                        {&out} aux_tgfimprg.
                END.
                
        /* listar confirmacao */
        ELSE
                DO:
                        RUN sistema/internet/fontes/InternetBank192.p (INPUT aux_cdcooper,
                                                                                                                   INPUT aux_nrdconta,
                                                                                                                   INPUT aux_nrcpfpre,
                                                                                                                   INPUT "",
                                                                                                                   INPUT 2,
                                                                                                                   OUTPUT aux_dsmsgerr,
                                                                                                                   OUTPUT TABLE xml_operacao).
                                                  
                        IF  RETURN-VALUE = "NOK"  THEN
                                {&out} aux_dsmsgerr. 
                        ELSE
                                FOR EACH xml_operacao NO-LOCK:
                        
                                        {&out} xml_operacao.dslinxml. 
                                                
                                END.

                        {&out} aux_tgfimprg.
                END.

END PROCEDURE.

PROCEDURE proc_operacao204:

    RUN sistema/internet/fontes/InternetBank204.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_dtmvtocd,
                                                   INPUT aux_nrcpfope,
                                                   INPUT aux_flmobile,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr aux_tgfimprg.
            RETURN.
        END.

    FOR EACH xml_operacao NO-LOCK:
    
        {&out} xml_operacao.dslinxml.
                                                
    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao205:

    ASSIGN aux_nrconven = INTE(GET-VALUE("aux_nrconven"))
           aux_nrremret = INTE(GET-VALUE("aux_nrremret"))
           aux_cdoperad = GET-VALUE("aux_cdoperad") 
           aux_nmoperad = GET-VALUE("aux_nmoperad") 
           aux_cdprograma = GET-VALUE("aux_cdprogra") 
           aux_nmarquiv = GET-VALUE("aux_nmarquiv") 
           aux_dsmsglog = GET-VALUE("aux_dsmsglog").

    RUN sistema/internet/fontes/InternetBank205.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_nrconven,
                                                   INPUT aux_nrremret,
                                                   INPUT aux_cdoperad,
                                                   INPUT aux_nmoperad,
                                                   INPUT aux_cdprograma,
                                                   INPUT aux_nmarquiv,
                                                   INPUT aux_dsmsglog,
                                                  OUTPUT aux_dsmsgerr).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr aux_tgfimprg.
            RETURN.
        END.

    {&out} aux_tgfimprg.    

END PROCEDURE.

/* Listar Comprovantes */
PROCEDURE proc_operacao193:	
  
  ASSIGN aux_dtiniper = DATE(GET-VALUE("dtinipro"))
         aux_dtfimper = DATE(GET-VALUE("dtfimpro"))
         aux_nriniseq = INTE(GET-VALUE("iniconta"))
         aux_nrregist = INTE(GET-VALUE("nrregist"))
         aux_cdorigem = INTE(GET-VALUE("cdorigem"))
         aux_cdtipmod = INTE(GET-VALUE("cdtipmod")).
  
	RUN sistema/internet/fontes/InternetBank193.p ( INPUT aux_cdcooper,
                                                    INPUT aux_nrdconta,
                                                    INPUT aux_dtiniper,
                                                    INPUT aux_dtfimper,
                                                    INPUT aux_nriniseq,
                                                    INPUT aux_nrregist,
                                                    INPUT aux_cdorigem,
                                                    INPUT aux_cdtipmod,
                                                   OUTPUT aux_dsmsgerr,
                                                   OUTPUT TABLE xml_operacao).

    IF RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
      FOR EACH xml_operacao NO-LOCK:
        {&out} xml_operacao.dslinxml.
    END.
    {&out} aux_tgfimprg.

END PROCEDURE.

/* Detalhes Comprovantes */
PROCEDURE proc_operacao194:	
  
  ASSIGN aux_cdtippro = INTE(GET-VALUE("cdtippro"))         
         aux_dsprotoc = GET-VALUE("dsprotoc")
         aux_cdorigem = INTE(GET-VALUE("cdorigem")).
  
	RUN sistema/internet/fontes/InternetBank194.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_dsprotoc,
                                                   INPUT aux_cdorigem,
                                                   INPUT aux_cdtippro,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).

    IF RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
      FOR EACH xml_operacao NO-LOCK:
        {&out} xml_operacao.dslinxml.
    END.
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao210:

    ASSIGN aux_nrconven = INTE(GET-VALUE("aux_nrconven"))
           aux_dtinilog = DATE(GET-VALUE("aux_dtinilog"))
           aux_dtfimlog = DATE(GET-VALUE("aux_dtfimlog"))
           aux_nmarquiv = ?
           aux_nrremret = ?.
           
    /* Somente carregar o numero de remessa se o mesmo foi informado */
    IF  GET-VALUE("aux_nrremret") <> ""  THEN 
        ASSIGN aux_nrremret = INTE(GET-VALUE("aux_nrremret")).
    
    /* Somente carregar o nome do arquivo se o mesmo foi informado */
    IF  GET-VALUE("aux_nmarquiv") <> ""  THEN 
        ASSIGN aux_nmarquiv = GET-VALUE("aux_nmarquiv") .

    RUN sistema/internet/fontes/InternetBank210.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_nrconven,
                                                   INPUT aux_nrremret,
                                                   INPUT aux_nmarquiv,
                                                   INPUT aux_dtinilog,
                                                   INPUT aux_dtfimlog,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr aux_tgfimprg.
            RETURN.
        END.

    FOR EACH xml_operacao NO-LOCK:
    
        {&out} xml_operacao.dslinxml.
        
    END.
    {&out} aux_tgfimprg.

END PROCEDURE.

/* Listar Agendamentos */
PROCEDURE proc_operacao195:	
  
  ASSIGN aux_dtiniper = DATE(GET-VALUE("dtageini"))
         aux_dtfimper = DATE(GET-VALUE("dtagefim"))
         aux_insitlau = INTE(GET-VALUE("insitlau"))         
         aux_nriniseq = INTE(GET-VALUE("iniconta"))
         aux_nrregist = INTE(GET-VALUE("nrregist"))
         aux_dsorigem = GET-VALUE("dsorigem")
         aux_cdtipmod = INTE(GET-VALUE("cdtipmod")).
  
	RUN sistema/internet/fontes/InternetBank195.p ( INPUT aux_cdcooper,
                                                    INPUT aux_nrdconta,
                                                    INPUT aux_dsorigem,
                                                    INPUT aux_dtiniper,
                                                    INPUT aux_dtfimper,
                                                    INPUT aux_insitlau,
                                                    INPUT aux_nriniseq,
                                                    INPUT aux_nrregist,
                                                    INPUT aux_cdtipmod,
                                                   OUTPUT aux_dsmsgerr,
                                                   OUTPUT TABLE xml_operacao).

    IF RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
      FOR EACH xml_operacao NO-LOCK:
        {&out} xml_operacao.dslinxml.
    END.
    {&out} aux_tgfimprg.

END PROCEDURE.

/* Detalhe Agendamento */
PROCEDURE proc_operacao196:	
  
  ASSIGN aux_cdtiptra = INTE(GET-VALUE("cdtiptra"))
         aux_idlancto = INTE(GET-VALUE("idlancto")).
 
	RUN sistema/internet/fontes/InternetBank196.p (INPUT aux_cdtiptra,
                                                 INPUT aux_idlancto,                                                
                                                OUTPUT TABLE xml_operacao).

    
    FOR EACH xml_operacao NO-LOCK:
      {&out} xml_operacao.dslinxml.
    END.
    {&out} aux_tgfimprg.

END PROCEDURE.

/* Detalhes Comprovantes Recebidos */
PROCEDURE proc_operacao197:	
  
  ASSIGN aux_cdtippro = INTE(GET-VALUE("cdtippro"))         
         aux_nrdocmto = INTE(GET-VALUE("nrdocmto"))
         aux_cdhistor = INTE(GET-VALUE("cdhistor"))
         aux_dttransa = DATE(GET-VALUE("dttransa"))
         aux_cdorigem = INTE(GET-VALUE("cdorigem")).
  
	RUN sistema/internet/fontes/InternetBank197.p (INPUT aux_cdcooper,
                                                 INPUT aux_nrdconta,
                                                 INPUT aux_cdorigem,
                                                 INPUT aux_cdtippro,
                                                 INPUT aux_nrdocmto,
                                                 INPUT aux_cdhistor,
                                                 INPUT aux_dttransa,                                                 
                                                OUTPUT aux_dsmsgerr,
                                                OUTPUT TABLE xml_operacao).

    IF RETURN-VALUE = "NOK"  THEN
        {&out} aux_dsmsgerr.
    ELSE
      FOR EACH xml_operacao NO-LOCK:
        {&out} xml_operacao.dslinxml.
    END.
    {&out} aux_tgfimprg.

END PROCEDURE.

/* Operar pagamentos de Tributos (FGTS/DAE) */
PROCEDURE proc_operacao199:

    ASSIGN  aux_dtapurac = DATE(GET-VALUE("aux_dtapurac"))
            aux_tpcaptur = INTE(GET-VALUE("aux_tpcaptur"))
            aux_nrcpfdrf = GET-VALUE("aux_nrcpfcgc")
            aux_nrrefere = DECI(GET-VALUE("aux_nrrefere"))
            aux_dtvencto = DATE(GET-VALUE("aux_dtvencto"))
            aux_cdtribut = GET-VALUE("aux_cdtribut")
            aux_vlrecbru = DECI(GET-VALUE("aux_vlrecbru"))
            aux_vlpercen = DECI(GET-VALUE("aux_vlpercen"))
            aux_vlprinci = DECI(GET-VALUE("aux_vlprinci"))
            aux_vlrmulta = DECI(GET-VALUE("aux_vlrmulta"))
            aux_vlrjuros = DECI(GET-VALUE("aux_vlrjuros"))
            aux_vlrtotal = DECI(GET-VALUE("aux_vlrtotal"))
            aux_dsexthis = GET-VALUE("aux_dsexthis")
            aux_idagenda = INTE(GET-VALUE("aux_idagenda"))
            aux_vlapagar = DECI(GET-VALUE("aux_vlapagar"))
            aux_cdbarras = GET-VALUE("aux_cdbarras")
            aux_lindigi1 = DECI(GET-VALUE("aux_lindigi1"))
            aux_lindigi2 = DECI(GET-VALUE("aux_lindigi2"))
            aux_lindigi3 = DECI(GET-VALUE("aux_lindigi3"))
            aux_lindigi4 = DECI(GET-VALUE("aux_lindigi4"))            
            aux_idefetiv = INTE(GET-VALUE("aux_idefetiv"))
            aux_dsnomfon = GET-VALUE("aux_dsnomfon")
            aux_tpleitor = INTE(GET-VALUE("aux_tpleitor"))
            aux_versaldo = INTE(GET-VALUE("aux_versaldo"))
            aux_tpdaguia = INTE(GET-VALUE("aux_tpdaguia"))
            aux_dtmvtopg = IF  aux_idagenda = 1  THEN /** Pagto data corrente **/
                              aux_dtmvtocd
                          ELSE
                              DATE(GET-VALUE("aux_dtmvtopg")).
                              
    RUN sistema/internet/fontes/InternetBank199.p (INPUT aux_cdcooper,                    
                                                   INPUT aux_nrdconta,                    
                                                   INPUT aux_idseqttl,                    
                                                   INPUT aux_nrcpfope,      
                                                   INPUT 3, /* internet */                
                                                   INPUT aux_flmobile,                    
                                                   INPUT aux_idefetiv,                    
                                                   INPUT aux_tpdaguia,                    
                                                   INPUT aux_tpcaptur,                    
                                                   INPUT aux_lindigi1,                    
                                                   INPUT aux_lindigi2,                    
                                                   INPUT aux_lindigi3,                    
                                                   INPUT aux_lindigi4,                    
                                                   INPUT aux_cdbarras,                    
                                                   INPUT aux_dsexthis,                    
                                                   INPUT aux_vlrtotal,                    
                                                   INPUT aux_dtapurac,                    
                                                   INPUT aux_nrcpfdrf,                    
                                                   INPUT aux_cdtribut,                    
                                                   INPUT aux_dtmvtopg,                    
                                                   INPUT aux_dtvencto,                    
                                                   INPUT aux_idagenda,                    
                                                   INPUT aux_vlapagar,                    
                                                   INPUT aux_versaldo,                    
                                                   INPUT aux_tpleitor,                    
                                                   INPUT aux_nrrefere,                    
                                                  OUTPUT aux_dsmsgerr,                                                   
                                                  OUTPUT TABLE xml_operacao).
                                                  
                                                   
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr aux_tgfimprg.
            RETURN.
        END.

    FOR EACH xml_operacao NO-LOCK:
    
        {&out} xml_operacao.dslinxml.
        
        END.
    {&out} aux_tgfimprg.

END PROCEDURE.

PROCEDURE proc_operacao211:

    ASSIGN aux_idstatus = INTE(GET-VALUE("aux_idstatus"))
           aux_tpdata   = INTE(GET-VALUE("aux_tpdata"))
           aux_nriniseq = INTE(GET-VALUE("aux_iniconta"))
           aux_nrregist = INTE(GET-VALUE("aux_nrregist"))
           aux_nrremret = ?
           aux_nmarquiv = ?
           aux_nmbenefi = ?
           aux_cdbarras = ?
           aux_dtiniper = ?
           aux_dtfimper = ?.

    /* Somente carregar o numero de remessa se o mesmo foi informado */
    IF  GET-VALUE("aux_nrremess") <> ""  THEN 
        ASSIGN aux_nrremret = INTE(GET-VALUE("aux_nrremess")).
    
    /* Somente carregar o nome do arquivo se o mesmo foi informado */
    IF  GET-VALUE("aux_nmarquiv") <> ""  THEN 
        ASSIGN aux_nmarquiv = GET-VALUE("aux_nmarquiv").
    
    /* Somente carregar o nome do beneficiario se o mesmo foi informado */
    IF  GET-VALUE("aux_nmbenefi") <> ""  THEN 
        ASSIGN aux_nmbenefi = GET-VALUE("aux_nmbenefi").
    
    /* Somente carregar codigo de barras se o mesmo foi informado */
    IF  GET-VALUE("aux_cdbarras") <> ""  THEN 
        ASSIGN aux_cdbarras = GET-VALUE("aux_cdbarras").
        
    /* Somente carregar de inicio do periodo se o mesmo foi informado */
    IF  GET-VALUE("aux_dtiniper") <> ""  THEN 
        ASSIGN aux_dtiniper = DATE(GET-VALUE("aux_dtiniper")).
        
    /* Somente carregar data de fim do periodo se o mesmo foi informado */
    IF  GET-VALUE("aux_dtfimper") <> ""  THEN 
        ASSIGN aux_dtfimper = DATE(GET-VALUE("aux_dtfimper")).
    
    RUN sistema/internet/fontes/InternetBank211.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_nrremret,
                                                   INPUT aux_nmarquiv,
                                                   INPUT aux_nmbenefi,
                                                   INPUT aux_cdbarras,
                                                   INPUT aux_idstatus,
                                                   INPUT aux_tpdata,
                                                   INPUT aux_dtiniper,
                                                   INPUT aux_dtfimper,
                                                   INPUT aux_nriniseq,
                                                   INPUT aux_nrregist,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr aux_tgfimprg.
            RETURN.
        END.

    FOR EACH xml_operacao NO-LOCK:
    
        {&out} xml_operacao.dslinxml.
        
    END.
    
    {&out} aux_tgfimprg.
END PROCEDURE.

PROCEDURE proc_operacao212:

    ASSIGN aux_dsagdcan = GET-VALUE("aux_dsagdcan").

    RUN sistema/internet/fontes/InternetBank212.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_dtmvtolt,
                                                   INPUT aux_dsagdcan,
                                                  OUTPUT aux_dsmsgerr).
                                                  
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            {&out} aux_dsmsgerr.
        END.
    
    {&out} aux_tgfimprg.
END PROCEDURE.

PROCEDURE proc_operacao213:

    ASSIGN aux_idstatus = INTE(GET-VALUE("aux_idstatus"))
           aux_tpdata   = INTE(GET-VALUE("aux_tpdata"))
           aux_tprelato = INTE(GET-VALUE("aux_tprelato"))
           aux_iddspscp = INTE(GET-VALUE("aux_iddspscp"))
           aux_nrremret = ?
           aux_nmarquiv = ?
           aux_nmbenefi = ?
           aux_cdbarras = ?
           aux_dtiniper = ?
           aux_dtfimper = ?.

    /* Somente carregar o numero de remessa se o mesmo foi informado */
    IF  GET-VALUE("aux_nrremess") <> ""  THEN 
        ASSIGN aux_nrremret = INTE(GET-VALUE("aux_nrremess")).
    
    /* Somente carregar o nome do arquivo se o mesmo foi informado */
    IF  GET-VALUE("aux_nmarquiv") <> ""  THEN 
        ASSIGN aux_nmarquiv = GET-VALUE("aux_nmarquiv").
    
    /* Somente carregar o nome do beneficiario se o mesmo foi informado */
    IF  GET-VALUE("aux_nmbenefi") <> ""  THEN 
        ASSIGN aux_nmbenefi = GET-VALUE("aux_nmbenefi").
    
    /* Somente carregar codigo de barras se o mesmo foi informado */
    IF  GET-VALUE("aux_cdbarras") <> ""  THEN 
        ASSIGN aux_cdbarras = GET-VALUE("aux_cdbarras").
        
    /* Somente carregar de inicio do periodo se o mesmo foi informado */
    IF  GET-VALUE("aux_dtiniper") <> ""  THEN 
        ASSIGN aux_dtiniper = DATE(GET-VALUE("aux_dtiniper")).
        
    /* Somente carregar data de fim do periodo se o mesmo foi informado */
    IF  GET-VALUE("aux_dtfimper") <> ""  THEN 
        ASSIGN aux_dtfimper = DATE(GET-VALUE("aux_dtfimper")).
    
    RUN sistema/internet/fontes/InternetBank213.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_nrremret,
                                                   INPUT aux_nmarquiv,
                                                   INPUT aux_nmbenefi,
                                                   INPUT aux_cdbarras,
                                                   INPUT aux_idstatus,
                                                   INPUT aux_tpdata,
                                                   INPUT aux_dtiniper,
                                                   INPUT aux_dtfimper,
                                                   INPUT aux_tprelato,
                                                   INPUT aux_iddspscp,
                                                  OUTPUT aux_dsmsgerr,
                                                  OUTPUT TABLE xml_operacao).
                                                  
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
    {&out} aux_dsmsgerr aux_tgfimprg.
            RETURN.
        END.

    FOR EACH xml_operacao NO-LOCK:
    
        {&out} xml_operacao.dslinxml.
        
    END.

    {&out} aux_tgfimprg.
END PROCEDURE.

/* Consultar notificacoes */
PROCEDURE proc_operacao206:

    ASSIGN aux_pesquisa  	 = STRING(GET-VALUE("aux_pesquisa"))
           aux_reginicial    = INTE(GET-VALUE("aux_reginicial"))
           aux_qtdregistros  = INTE(GET-VALUE("aux_qtdregistros")).
    
    RUN sistema/internet/fontes/InternetBank206.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_pesquisa,
                                                   INPUT aux_reginicial,
                                                   INPUT aux_qtdregistros,
												   INPUT aux_cdcanal,
                                                   OUTPUT TABLE xml_operacao).
                                                   
    FOR EACH xml_operacao NO-LOCK:
        {&out} xml_operacao.dslinxml.
    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

/* Obter detalhes da notificacao */
PROCEDURE proc_operacao207:

    ASSIGN aux_cdnotificacao = INT64(GET-VALUE("aux_cdnotificacao")).
    
    RUN sistema/internet/fontes/InternetBank207.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_cdnotificacao,
												   INPUT aux_cdcanal,
                                                   OUTPUT TABLE xml_operacao).
                                                   
    FOR EACH xml_operacao NO-LOCK:
        {&out} xml_operacao.dslinxml.
    END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

/* Carregar configuracoes de recebimento de push */
PROCEDURE proc_operacao208:
    
    RUN sistema/internet/fontes/InternetBank208.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
												   INPUT aux_cdcanal,
                                                   OUTPUT TABLE xml_operacao).
                                                   
    FOR EACH xml_operacao NO-LOCK:
        {&out} xml_operacao.dslinxml.
    END.
    
    {&out} aux_tgfimprg.
    
END PROCEDURE.

/* Alterar configuracoes de recebimento de push */
PROCEDURE proc_operacao209:

    ASSIGN aux_dispositivomobileid = STRING(GET-VALUE("aux_dispositivomobileid"))
           aux_recbpush      = INTE(GET-VALUE("aux_recbpush"))
           aux_chavedsp      = STRING(GET-VALUE("aux_chavedsp"))
           aux_lstconfg      = STRING(GET-VALUE("aux_lstconfg")).
    
    RUN sistema/internet/fontes/InternetBank209.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
                                                   INPUT aux_dispositivomobileid,
                                                   INPUT aux_recbpush,
                                                   INPUT aux_chavedsp,
                                                   INPUT aux_lstconfg,
												   INPUT aux_cdcanal,
                                                   OUTPUT TABLE xml_operacao).
                                                   
    FOR EACH xml_operacao NO-LOCK:
        {&out} xml_operacao.dslinxml.
    END.
    
    {&out} aux_tgfimprg.

END PROCEDURE.

/* Obter quantidade de notificações não visualizadas do cooperado */
PROCEDURE proc_operacao214:
        
    RUN sistema/internet/fontes/InternetBank214.p (INPUT aux_cdcooper,
                                                   INPUT aux_nrdconta,
                                                   INPUT aux_idseqttl,
												   INPUT aux_cdcanal,
                                                   OUTPUT TABLE xml_operacao).
                                                   
    FOR EACH xml_operacao NO-LOCK:
        {&out} xml_operacao.dslinxml.
    END.

    {&out} aux_tgfimprg.

END PROCEDURE.

/*............................................................................*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

