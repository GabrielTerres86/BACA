CREATE OR REPLACE PROCEDURE CECRED.pc_crps249 (pr_cdcooper  IN craptab.cdcooper%TYPE  --> Cooperativa solicitada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag 0/1 para utilizar restart na chamada
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Código da Crítica
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto do erro/crítica
/* ..........................................................................

   Programa: pc_crps249 (antigo Fontes/crps249.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/98                     Ultima atualizacao: 16/01/2018

   Dados referentes ao programa:

   Frequencia: Diario. Exclusivo.

   Objetivo  : Atende a solicitacao 76.
               Gerar arquivo para contabilidade.
               Ordem do programa na solicitacao 1.

   Alteracoes: 12/03/1999 - Diminuir a quantidade de cdestrut (Odair)

               06/01/2000 - Buscar dados da cooperativa no crapcop (Edson).

               11/05/2000 - Ler lancamentos de custodia (Odair)

               13/07/2000 - Tratar custos de cheques (Odair)

               21/08/2000 - Tratar cheque salario Banccob (Deborah).

               15/09/2000 - Tratar os titulos compensaveis (Edson).

               11/01/2001 - Tratar IPTU, tipo de lote 21 (Deborah).

               22/01/2001 - Contabilizar receita dos lotes tipo 20 e 21
                            (Deborah).

               03/04/2001 - Contabilizar o boletim de caixa (Edson).

               24/04/2001 - Alterado o centro de custos para apenas 2 casas
                            (Edson).

               05/05/2001 - Contabilizar a comp. eletronica (Edson).

               21/05/2002 - Permitir qualquer dia para custodia(Margarete).

               12/05/2003 - Contabilizar o desconto de cheques (Edson).

               21/08/2003 - Acerto na contabilizacao da liberacao dos cheques
                            descontados (Edson).

               16/10/2003 - Alteracao na contabilizacao do desconto de cheque
                            (Julio).

               17/10/2003 - Tratar resgate no desconto de cheques (Edson).

               05/11/2003 - Ler historicos para buscar conta contabil (Edson).

               12/11/2003 - Tratar transferencia da custodia para o desconto de
                            cheques (Edson).

               11/12/2003 - Ajuste na contabilizacao do resgate de cheques
                            descontados (Edson).

               06/01/2004 - Ajuste na contabilizacao do resgate de cheques
                            descontados (Edson).

               12/01/2004 - Excluida a contabilizacao da tarifa sobre titulos
                            recebidos no caixa (Edson).

               11/02/2004 - Contabilizar o saldo dos limites de descontos de
                            cheques (Edson).

               20/02/2004 - Contabilizar Historicos(557-DOC/558-TED) - Arquivo
                            craptvl.Criado progr.crps249_4(Mirtes).

               30/03/2004 - Tratar o tipo de contabilizacao por caixa 6
                            (Edson).

               28/04/2004 - Tratar parcelamento do capital (Edson).

               12/05/2004 - Obter dados da tabela craphis para o Historico 130
                            - Prefeitura Municipal Blumenau(Mirtes).

               17/05/2004 - Alterar historico 130 para 373.

               09/06/2004 - Contabilizar a reversao da subscricao de capital
                            para planos dos demitidos (Edson).

               21/09/2004 - Tratar historicos da conta investimento (Edson).

               23/11/2004 - Tratar COBAN (Edson).

               02/12/2004 - Ajuste na contabilizacao do COBAN (Edson).

               09/02/2005 - Novos historicos Conta Investimento(647/648)(Mirtes)

               07/04/2005 - Ajuste na contabilizacao da REVERSAO da subscricao
                            de capital (Edson).

               28/06/2005 - Formato do campo craplcx.dsdcompl(Mirtes).

               09/08/2005 - Tratar lancamentos Tarifa CTITG (Ze Eduardo).

               26/08/2005 - Novo historico Pagto GPS(458)(Mirtes)

               21/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               28/09/2005 - Desconsiderar lancamentos de tarifa de
                            cheques cta integracao TESTE CREDCREA. (Ze).

               23/11/2005 - Ajustes no lancamentos de tarifas de cheques (Ze)

               02/01/2006 - Ajustes na contabilizacao da Baixa do saldo do
                            capital dos inativos no processo ANUAL (Edson).

               10/01/2006 - Tratar historico 459 - Recebimento INSS(Mirtes)

               25/01/2006 - Efetuar unico lancamento para CTA ITG (Ze).

               15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               22/03/2006 - Contabilizacao Bloquetos Viacredi (Mirtes).

               06/04/2006 - Acerto nos lancamentos gerenciais das tarifas (Ze).

               08/06/2006 - Desenvolver o Gerencial a Credito e a Debito (Ze).

               12/06/2006 - Acerto no historico 459 (Ze).

               22/06/2006 - Contabilizacao do orcamento no processo mensal
                            (Edson).

               14/07/2006 - Correcao na contabilizacao do orcamento (Edson).

               17/08/2006 - Correcao na contabilizacao do orcamento (Edson).

               30/08/2006 - Desprezar as tarifas de Cheque ref. cta. Base (Ze).

               18/10/2006 - Correcao na contabilizacao do orcamento (Edson).

               13/12/2006 - Contabilizar os lancamentos da Conta Salario (Ze).

               26/02/2007 - Contabilizar hist. 266 atraves da conta que esta
                            cadastrado na tela HISTOR  (Ze).

               02/04/2007 - Tratamento hst. 542 e 549 (Bancoob) e hst. 731 (Ze)

               09/07/2007 - Tratar tarifa para os historicos 547 e 546 (Ze).

               14/11/2007 - Incluir RDCPRE e RDCPOS no orcamento (Magui).

               07/12/2007 - Cancelado lancamento automatico de tarifa
                            Bancoob, historico 547 (Magui).

               21/01/2008 - Incluir os historicos do INSS - BANCOOB (Evandro).

               31/03/2008 - Inclusao do historico 582 para GUIAS GPS (Evandro).
                          - Nao utilizar mais o craphis.vltarifa usar a nova
                            estrutura de tarifas - crapthi(Guilherme)
                          - Inclusao de tarifas de pagamento de GPS (Guilherme).
                          - Nao gerar tarifas INSS com valor zerado (Evandro).

               20/06/2008 - Incluído a chave de acesso (craphis.cdcooper =
                            glb_cdcooper) no "find" da tabela CRAPHIS.
                          - Kbase IT Solutions - Paulo Ricardo Maciel.

               12/08/2008 - Conta 4236 para 4257 no orcamento poupanca (Magui).

               02/10/2008 - Falta virgula no 4257 do orcamento (Magui).

               03/10/2008 - Adaptacao para Desconto de Titulos (David).

               05/12/2008 - Considerar crapcdb.insitchq para cheque resgatados
                            no dia (Evandro).

               18/12/2008 - A pedido da contabilidade, separar desconto de
                            titulos pagos pelo sacado dos pagos pelo cedente
                            (Evandro).

               05/01/2009 - Lancar liquidacao de titulos descontados pagos pelo
                            sacado na data de pagamento e nao na data de
                            vencimento (melhoria para contabilidade) (Evandro).

               12/01/2009 - Efetuar os lancamentos de liquidacao do desconto de
                            titulos (quando o titulo for pago) com valor do
                            pagamento;
                          - Separar pagamentos de desconto de titulos efetuados
                            no CAIXA e atraves da COMPE (Evandro).

               13/01/2009 - Tratamento para feriado e fins de semana para o
                            desconto de titulos no caso de debito na conta do
                            cedente - idem crps517.p;
                          - Na apropriacao do desconto de titulos, deve ser
                            considerado o valor total, sem tirar o abatimento
                            (Evandro).

               23/01/2009 - Evitar duplicacao de lancamento de liquidacao de
                            desconto de titulos devido as datas calculadas nos
                            feriados e fins de semana (Evandro).

               28/01/2009 - Gerar registro de tarifas de cobranca de desconto
                            de titulos (Guilherme).

               10/02/2009 - Alterado a apropriacao para lancar na conta contabil
                            1644 o valor total sem tirar o abatimento.
                            craptdb.vltitulo - craptdb.vlliquid.
                            Comentario 1 na Tarefa: 22255
                          - Lancar liquidacao de titulos descontados pagos pelo
                            sacado via COMPE com D+1(Guilherme).

               10/02/2009 - Alterar a Conta a Credito do Historico 561 (Ze).

               26/02/2009 - Correcao no FIND crapcob: utilizar a chave. Estava
                            sem o convenio. (Guilherme).

               10/03/2009 - Se o titulo nao for pago nao soma os juros dos
                            proximos meses caso o titulo for pago soma somente
                            no mes - Desconto de Titulos - (Guilherme).

               30/03/2009 - Tratar titulos em Desconto pagos via internet como
                            CAIXA cob.indpagto = 3 cob.indpagto = 1
                            Tarefa 23393 - (Evandro/Guilherme).

               09/04/2009 - Ajuste no resgate de desconto de titulos
                            (Evandro/Guilherme).

               14/04/2009 - Ajustar os lanc. do hist. 561 - Tarefa 23664 (Ze).

               05/05/2009 - Utilizar glb_cdcooper no FIND do crapfer (David);
                          - Ajuste na apropriacao do desconto de titulos
                            (Evandro).

               13/05/2009 - Substituir a tab "ContaConve" pela gnctace (Ze).

               08/07/2009 - Se forem titulos resgatados nao soma os juros
                            restituidos na apropriacao final do mes,
                            pois eles ja foram lancados a debito
                            na 1644 no dia que o titulo eh resgatado(Guilherme).

               11/08/2009 - Incluir tarifa de Internet no craplft(Faturas) (Ze)

               28/08/2009 - Substituicao do campo banco/agencia da COMPE/TITULO
                            para o banco/agencia - (Sidnei - Precise);

                          - Tratar borderos de desconto de titulos que forem
                            liberados e liquidados no mesmo dia e nao
                            considerar a data de vencimento nos titulos em
                            aberto (sit=4) porque a liquidacao esta rodando
                            antes no processo batch (Evandro).

               29/09/2009 - Tratar titulos resgatados no mesmo dia da liberacao
                            para desconsidera-los (Evandro).

               15/10/2009 - Inclusao de tratamento para banco CECRED junto com
                            BB e Bancoob. (Guilherme - Precise)

               02/02/2010 - Alteracao codigo historico (Diego).

               25/05/2010 - Contab. TEC nossa IF, histor 827 (Magui).

               27/05/2010 - Contab. Titulos nossa IF, histor 824 (Magui).

               10/06/2010 - Incluido tratamento para pagamento atraves de TAA
                            (Elton).

               02/07/2010 - Tratar hist. 560, 561 e 562 - Gerencial (Ze).

               11/08/2010 - Tratar hist. 827 - Gerencial - Tarefa 34295 (Ze).

               20/08/2010 - Acumular o valor de desconto de titulos na crapprb,
                            separado por prazo. Tarefa 34547 (Henrique)

               12/09/2010 - Inserir novos prazos. (Henrique).

               01/11/2010 - Tratamento para separar Emprestimos X Financiamen.
                          - Incluido Saldos Financiados. (Irlan).

               11/11/2010 - Tratar historicos 918 e 920 referente TAA
                            compartilhado (Diego).

               12/11/2010 - Quando virada do ano nao usar crapcot.vlcapmes,
                            usar crapcot.vlcotant. Campo crapcot.vlcapmes
                            zerado no crps011 que roda antes (Magui).

               12/07/2011 - Ajuste nas contas contabeis do hist. 266
                            - Tarefa 41091 (Ze).

               19/07/2011 - Ajuste na contabilizacao dos hist. 971 e 977
                            - Tarefa 41181 e 41185 (Ze).

               22/07/2011 - Tratamento dos hist. 936,937,938,939,940,965,966 e
                            973 - Cobranca Registrada (Ze).

               25/08/2011 - Atualizar vlslfmes aqui quando ultimo dia do
                            mes para nao dar erro no orcado por Pac (Magui).
                            Criar orcado por Pac para o his 110 (Magui).
                            Orcado do desconto de cheques e de titulos
                            passar a usar o data do ultimo dia do mes (Magui).
                            Criar orcado por Pac para o his 930 (Magui).

               01/09/2011 - Tratamento do histórico 98 e 277
                            Juros e Estorno sobre EMPREST X FINANC (Irlan)

               12/09/2011 - Tratamento hist 971 - Cred. Cobr. BB (Rafael).

               21/09/2011 - Tratamento para Rotina 66 (LANCHQ) - Desprezar hist.
                            731 (Ze).

               04/11/2011 - Tratamento hist. 1018 ref. Transferencia
                            TEC SALARIO entre cooperativas (Diego).

               06/01/2012 - Tratamento hist. BB - Cob.Registrada - garantir
                            lancamentos > 0. (Rafael)

               16/05/2012 - Ajuste na contabilizacao dos hist. 1088 e 1089
                            ref a liquidacao apos baixa BB e CECRED. (Rafael)

               17/05/2012 - Gravacao da tabela crapopc, controle de desconto
                            e resgate de cheque e titulos (Tiago).

               02/10/2012 - Ajuste nos lanctos de titulos descontados da
                            cob. registrada (Rafael).

               31/12/2012 - Gerar lanctos contabeis ref ao acerto financeiro
                            entre as contas BB Viacredi e Alto Vale (Rafael).

               16/01/2013 - Ajuste no lancto de acerto financeiro BB por PAC
                            na Alto Vale ref. ao debito de tarifas (Rafael).

               05/03/2013 - Conversão Progress >> Oracle PL/Sql (Daniel - Supero)

               25/03/2013 - Tratamento para historico 1154 - Sicredi (Elton).

               23/04/2013 - Ajuste das tarifas de titulos descontados dos
                            títulos migrados (Rafael).

               26/04/2013 - Tratamento para faturas DPVAT - Sicredi (Elton).

               14/05/2013 - Tratamento para DARF's sem codigo de barras e
                            ajustes para convenios Sicredi (Elton).

               23/05/2013 - Implementação das últimas alterações na versão PL/SQL (Daniel - Supero)

               28/05/2013 - Ajustes no valor total das DARF's (Elton).

               07/06/2013 - Desprezar operacoes do BNDES no lancamento ref.
                            'FINANCIAMENTOS REALIZADOS' (Diego).

               11/06/2013 - Incluido NO-LOCK na leitura da craplft (Elton).

               13/06/2013 - Incluido o registro de TEDs rejeitadas (887); apos
                            TED conta salario (Carlos).

               05/07/2013 - Incluido historico 801 - TEC DEVOLVIDA (Diego).

               12/08/2013 - Utilizar data de lançamento (crapafi.dtlanmto)
                            ao contabilizar lançamentos do Acerto Financeiro BB
                            entre cooperativas migradas. (Rafael)

               23/08/2013 - Implementação das últimas alterações na versão PL/SQL (Daniel - Supero)

               11/10/2013 - Ajustas as alterações realizadas no PROGRESS após implementação
                            e ajuste dos padrões (Renato - Supero)

                          - Ajustado processo geracao arquivo contabilidade,
                            devido alteracao processo tarifa.
                            (Alteração Progress: Daniel - 21/08/2013)

                          - softdesk 82990 - Retirado do relatorio o calculo
                            de tarifas GPS Bancoob.
                            (Alteração Progress: Carlos - 23/08/2013)

                          - Ajuste no processo de debito tarifa com e sem registro.
                            (Alteração Progress: Carlos - 27/09/2013)

               18/02/2014 - Alterada critica "15 - Agencia nao cadas
                            "962 - PA nao cadastrado". (Gabriel)

               27/02/2014 - Ajuste no processo de debito tarifa com e sem registro
                            (Gabriel).

               27/02/2014 - Ajuste no processo de Acerto Financeiro BB entre
                            cooperativas migradas da Acredi->Viacredi (Gabriel)

               27/02/2014 - Ajuste no processo contabil de desconto de titulos
                            referente ao Acerto Financeiro BB entre coop.
                            migradas da Acredi->Viacredi (Gabriel)

               18/03/2014 - Ajustes nos indices dos totalizadores para evitar
                            no_data_found (Marcos-Supero)

               23/05/2014 - Ajustado para não multiplicar por 100 o valor na linha
                            que exibe os titulos migrados (Odirlei-AMcom)

               23/05/2014 - Incluido as colunas dtsdfmea e vlslfmea na CRAPRDA
                            (Andrino - RKAM)

               16/06/2014 - Alterado atribuicao da variavel vr_vltarifa
                            dentro da contabilizacao de despesa do Sicredi;
                            para: rw_crapcop.vltardrf.
                            (Chamado 146711) - (Fabricio)

               07/07/2014 - Retirado as colunas dtsdfmea e vlslfmea na CRAPRDA
                            (Andrino - RKAM)

               25/07/2014 - Ajuste na regra do curosr cr_crapcdb4(odirlei-AMcom)

               28/08/2014 - Projeto Float: criação dos cursores cr_craptit3,  cr_craptit4
                            cr_crapret3 e alteração nas rotinas (Vanessa)
						  
               01/10/2014 - Inclusao do nome da estrutura CRAPLAC na condicao
                            do campo craphis.nmestrut.

               03/10/2014 - Ajustes ref. ao projeto 198-Viacon (Rafael).

               23/10/2014 - Ajustado cursores da craptit, utilizando insittit = 0
                            devido ao problema de pagto na rotina CXON0014. (Rafael)

               29/10/2014 - Cancelamento noturno. Ajustes para permitir agencia com
                            3 digitos (Andrino-RKAM).

               03/11/2014 - Implementado provisão dos juros sobre cheque especial no
                            processo mensal, e no próximo dia útil após o mensal
                            deve ser lançada a reversão dos juros (Jean Michel).

               24/11/2014 - Retirado reversão dos juros (Jean Michel).

							 10/12/2014 - Correção para gerar linha gerencial 999 em contrapartida
							              da conta contábil (1621) do histórico 0277.
														(Lucas Lunelli - SD. 165821)

               16/12/2014 - Ajustes para gerar os lancamentos do historico 1019
                            (Debito Automatico Sicredi) da mesma forma que gerado
                            para o historico 1154; com excecao dos lancamentos que
                            estao separados apenas por empresa, sem separacao por PA.
                          - Ajustado tambem a contabilizacao da tarifa para o historico
                            1154, pois estava utilizando a tarifa de Debito Automatico para
                            contabilizar os lancamentos de arrecadacao no caixa.
                            (Chamado 228450) - (Fabrício)
							
			         23/01/2015 - Incluso tratamento FINAME (Daniel)					
                            
               03/02/2014 - Alteracoes na geracao do relatorio contabil para levar em conta os
                            novos produtos de captacao. 
                            (Carlos Rafael Tanholi - Novos Produtos de Captacao)
                            
               03/02/2014 - (Chamado 245712) Agencia com 3 dígitos não integrando no contábil
                            (Tiago Castro - RKAM).

               27/03/2015 - Incluir nrdocmto no cursor do cr_craplcm5, pois estava dando 
                            diferença contabil (Lucas Ranghetti #270081)
                            
               29/04/2015 - Proj. 186 - Separacao de informacoes em PF e PJ, dados
                            para contabilidade. Criando arquivo AAMMDD_OP_CRED.txt
                            (Andre Santos - SUPERO)

               15/07/2015 - Ajustar cursor cr_crapret3 para que sejam incluidos os
                            os 76 e 77 no cdocorre referente a liquidação de boletos 
                            do projeto de Cooperativa Emite e Expede.
                            (Douglas - Chamado 307240)

               25/08/2015 - Ajustar cursores cr_crapret3 e cr_craptit4 referente
                            ao pagamento de emprestimo c/ boleto - projeto 210. (Rafael)
			   
               23/09/2015 - Adicionado relatorio das contas que recebem o ajuste com 
                            historicos sem credito em conta, para o CRPS249. 
                            Projeto 214- projeto 214. (Lombardi)

               23/09/2015 - Incluindo calculo de pagamentos GPS.
                             (André Santos - SUPERO)
	                    
               05/10/2015 - #334784 Correção dos cursores cr_craplcm4 e cr_craplcm5, com
                            inclusão da cláusula craplcm.dtmvtolt = craplau.dtdebito.
                            Inclusão da cláusula craplcm.nrdocmto = craplau.nrdocmto no cursor
                            cr_craplcm4 (Carlos)
                            
               05/11/2015 - PRJ214 - Ajuste na conta contábil de debito quando convênio DPVAT 
                            (Marcos-Supero)
                            
               06/11/2015 - Comentado os filtros "vlslfmes > 0" devido a divergencias no relatório 
                            de Razão Contábil. (Renato - Supero)

               10/11/2015 - Incluso tratamento dos históricos de pagtos de boletos de emprestimo
                            -- 1998 - CREDITO PAGAMENTO CONTRATO INTEGRAL
                            -- 1999 - CREDITO PAGAMENTO CONTRATO ATRASO
                            -- 2000 - CREDITO QUITACAO DE EMPRESTIMO
                            -- 2001 - DEVOLUCAO BOLETO VENCIDO
                            -- 2002 - AJUSTE CONTRATO PROCESSO EM ATRASO
                            -- 2012 - AJUSTE BOLETO (EMPRESTIMO)
                            referente ao projeto 210 (Rafael).

               15/02/2016 - Utilizado procedure pc_escreve_xml da package gene0002
                            para criar o arquivo xml do relatório final. (Lombardi)
               
               23/02/2016 - Inclusao de consulta via GENE0001.fn_param_sistema para
                            historicos sem credito em conta corrente para o relatorio
                            crrl708(Jean Michel).
                                           
               22/03/2016 - Incluido bloco para Contabilizacao Despesa Sicredi
                            para GPS (Guilherme/SUPERO)

               04/05/2016 - GPS - Contabilização do PA 90 no PA da conta do cooperado
                            (Guilherme/SUPERO)

               27/05/2016 - GPS - SD459224 - Contabilização PA 90 apenas de despesas
                            Sicredi e não de pagamentos efetuados
                            Não considerar GPS agendados / Despesas apenas quando SICREDI
                            (Guilherme/SUPERO)
                            
               22/06/2016 - Inclusão dos históricos 1755, 1758 e 1937 referente
                            as recusas de TEC salário outros IF (Marcos-Supero)             
                            
			   23/08/2016 - Inclusão dos históricos de portabilidade (1915 e 1916) 
			                na leitura do cursor cr_crapepr. (Reinert)
							
			   28/09/2016 - Alteração do diretório para geração de arquivo contábil.
                            P308 (Ricardo Linhares).   

               13/10/2016 - Ajuste leitura CRAPTAB, incluso UPPER para utilizar index principal
			                (Daniel)
                            
               28/10/2016 - SD 489677 - Inclusao do flgativo na CRAPLGP (Guilherme/SUPERO)

			   09/11/2016 - Correcao para ganho em performance em cursores deste CRPS. 
							SD 549917 (Carlos Rafael Tanholi)

               16/11/2016 - Ajustar cursor cr_craplcm6 para efetuar a busca correta das 
                            Despesas Sicredi (Lucas Ranghetti #508130)
                     
			   30/11/2016 - Correção para buscar corretamente registro da crapstn
			                de acordo com o tipo de arrecadação (Lucas Lunelli - Projeto 338)
                      
               06/03/2017 - Alterações Projeto 307 - Automatização Arquivos Contábeis Ayllos
                            Inclusão de novos históricos e retirada de lançamentos de reversão (Jontas-Supero)
                     
               17/03/2017 - Ajustes referente ao projeto M338.1, não estourar a conta corrente com cobrança 
			                de juros e IOF de Limite de Crédito e Adiantamento a Depositante - Somente Lautom
							(Adriano - SD 632569).

							 21/03/2017 - Adicionado tratamento de recarga de celular no arquivo 
														contábil - PRJ321. (Reinert)
              
               23/03/2017 - Ajustes PRJ343 - Emprestimo cessao de credito(Odirlei-AMcom)
      
               13/04/2017 - Alterações Projeto 307 - Automatização Arquivos Contábeis Ayllos
                            Geração dos novos arquivos AAMMDD_PREJUIZO e AAMMDD_TARIFASBB para o Radar
                            e inclusão de novos históricos no arquivo OPCRED.
                            Inclusão de segregação de lançamentos de receita de recarga de celular (Jonatas-Supero)                           

               08/05/2017 - Detalhado no arquivo os registros de LIMITES CONCEDIDOS
                            PARA DESCONTO DE CHEQUES/TITULOS (Tiago/Thiago #611703).            
                            
               24/05/2017 - Ajuste para apresentar valores de provisão juros CH. especial de pessoa
                            juridica apenas se encontrar algum valor
                           (Adriano - SD 675239).

                            
               29/05/2017 - Alterado tamanho da variavel vr_indice para suportar
                            3 numeros (Tiago/Thiago).             

               19/06/2017 - Ajuste para enviar apenas cheques em desconto aprovados (insitana = 1)
                            PRJ300-Desconto de cheque(Odirlei-AMcom)
                            
               10/07/2017 - Ajuste na geração de lançamento contábil de receita de recarga de 
                            celular - SD 707484 - (Jonatas - Supero) 

               21/07/2017 - Ajuste na geracao das Entradas de cheques em custodia do dia para
 							incluir penas custodias nao descontadas (Daniel)

               26/07/2017 - Ajuste na geracao das informacoes de cheques em custodia para
 							incluir penas custodias nao descontadas (Daniel)

			   03/08/2017 - Ajuste nas consultas de recarga de celular para substituir o cálculo
                            da receita pela totalização do vlrepasse. (Lombardi)
                            
               15/08/2017 - Alterado histórico 1510 Normal.
                            Incluido histórico 1510 Microcrédito.
                            Alterado histórico 227 para 277 Microcrédito.
                            Alterado histórico 1072 PJ Destino 7080 para 7084 Microcrédito.
                            Ajustado indentacao da procedure pc_gera_arq_op_cred
                            (Rafael Faria - Supero)		

               01/09/2017 - SD737681 - Ajustes nos históricos do projeto 307 - Marcos(Supero)

               03/11/2017 - Melhorias performance, padronização
                            (Ana Volles - Envolti - Chamado 734422)
                            
               21/11/2017 - Incluir nrdocmto na clausula do cursor cr_craplcm6 pois
                            estava retornando registro duplicado caso a conta tivesse 
                            mais de um lançamento (Lucas Ranghetti #791432 )
                            
               15/01/2018 - Incluir tratamento para os históricos abaixo na geração arquivo
                            2277 - CREDITO PARCIAL PREJUIZO
                            2278 - CREDITO LIQUIDAÇÃO PREJUIZO
                           (Marcelo Telles Coelho - Mouts - 15/01/2018 - SD 818020)

			   16/01/2018 - Alteração no codigo da critica de 1033 para 1113 
                            pelo motivo que alguém criou em produção o codigo 1033 ...
                          - Troca de return por raise
                            (Belli - Envolti - Chamado 832035)
............................................................................ */

  --Melhorias performance - Chamado 734422
  type crapcdb_rec is record (vlcheque crapcdb.vlcheque%type,
                              vlliquid crapcdb.vlliquid%type,
                              nrdconta crapcdb.nrdconta%type,
                              nrborder crapcdb.nrborder%type,
                              cdagenci crapcdb.cdagenci%type,
                              nrcheque crapcdb.nrcheque%type,
                              inchqcop crapcdb.inchqcop%type);

  type tab_crapcdb_rec is table of crapcdb_rec index by binary_integer;
  rw_crapcdb tab_crapcdb_rec;

  -- Buscar os dados da cooperativa
  cursor cr_crapcop(pr_cdcooper in craptab.cdcooper%type) is
    select cdbcoctl,
           cdcrdarr,
           cdcrdins,
           dsdircop,
           nrctactl,
           nmrescop,
           vltardrf
      from crapcop
     where crapcop.cdcooper = pr_cdcooper;
  rw_crapcop    cr_crapcop%rowtype;

  rw_crapcop_2  cr_crapcop%rowtype;

  -- Buscar os históricos com código de histórico na contabilidade maior que zero
  -- e das estruturas listadas abaixo
  cursor cr_craphis (pr_cdcooper in craphis.cdcooper%TYPE) is
    select upper(craphis.nmestrut) nmestrut,
           craphis.cdhistor,
           craphis.tpctbcxa,
           craphis.tpctbccu,
           craphis.nrctacrd,
           craphis.nrctadeb
      from craphis
     where craphis.cdcooper = pr_cdcooper
       and craphis.cdhstctb > 0
       and craphis.cdhistor NOT IN (1154, -- Hist.Sicredi
                                    1019, -- Hist. Debito Automatico Sicredi
                                    1414) -- Hist. Gps inss convencional via sicredi
       and upper(craphis.nmestrut) in ('CRAPLCT',
                                       'CRAPLCM',
                                       'CRAPLEM',
                                       'CRAPLPP',
                                       'CRAPLAP',
                                       'CRAPLFT',
                                       'CRAPTVL',
                                       'CRAPLAC');
  rw_craphis    cr_craphis%rowtype;
  -- Buscar as tarifas do histórico
  cursor cr_crapthi (pr_cdcooper in crapthi.cdcooper%type,
                     pr_cdhistor in craphis.cdhistor%type,
                     pr_dsorigem in crapthi.dsorigem%type) is
    select vltarifa
      from crapthi
     where crapthi.cdcooper = pr_cdcooper
       and crapthi.cdhistor = pr_cdhistor
       and crapthi.dsorigem = pr_dsorigem;
  rw_crapthi    cr_crapthi%rowtype;
  -- Busca as agências da cooperativa
  cursor cr_crapage is
    select cdagenci,
           cdccuage,
           cdcxaage,
           tpagenci
      from crapage
     where cdcooper = pr_cdcooper
     order by cdagenci;
  -- Rejeitados na integração
  cursor cr_craprej (pr_cdcooper in craptab.cdcooper%type,
                     pr_cdprogra in crapprg.cdprogra%type,
                     pr_dtmvtolt in crapdat.dtmvtolt%type,
                     pr_nraplica IN NUMBER) IS
    select craphis.nrctacrd,
           craphis.nrctadeb,
           craprej.nrdctabb,
           craprej.dtrefere,
           craprej.cdagenci,
           craprej.vllanmto,
           craphis.cdhstctb,
           craphis.cdhistor,
           craphis.dsexthst,
           craphis.ingerdeb,
           craphis.ingercre,
           craphis.tpctbcxa,
           craprej.cdbccxlt,
           craprej.nraplica,
           craprej.vlsdapli
      from craprej,
           craphis
     where craprej.cdcooper = pr_cdcooper
       and craprej.cdpesqbb = pr_cdprogra
       and craprej.dtmvtolt = pr_dtmvtolt
       and craphis.cdcooper = craprej.cdcooper
       and craphis.cdhistor = craprej.cdhistor
       AND ((craprej.nraplica = pr_nraplica -- Buscar Total Geral (0-Geral/1-Total por PF/2-Total por PJ)
       AND  pr_nraplica = 0)
        OR (craprej.nraplica IN (1,2)
       AND   pr_nraplica > 0))
       AND trim(craprej.dshistor) is null
     order by craprej.cdhistor,
              craprej.nraplica,
              craprej.dtrefere,
              craprej.cdagenci,
              craprej.progress_recid;
  -- Busca parâmetro genérico cadastrado
  cursor cr_craptab (pr_cdcooper in craptab.cdcooper%type,
                     pr_cdempres in craptab.cdempres%type,
                     pr_tptabela in craptab.tptabela%type,
                     pr_nrdctabb in craptab.cdacesso%type,
                     pr_cdbccxlt in craptab.tpregist%type) is
    select dstextab
      from craptab
     where craptab.cdcooper        = pr_cdcooper
       and UPPER(craptab.nmsistem) = 'CRED'
       and UPPER(craptab.tptabela) = pr_tptabela
       and craptab.cdempres        = pr_cdempres
       and UPPER(craptab.cdacesso) = pr_nrdctabb
       and craptab.tpregist        = pr_cdbccxlt;
  rw_craptab    cr_craptab%rowtype;
  -- Rejeitados na integração
  cursor cr_craprej2 (pr_cdcooper in craptab.cdcooper%type,
                      pr_cdprogra in crapprg.cdprogra%type,
                      pr_dtmvtolt in crapdat.dtmvtolt%type,
                      pr_nraplica IN NUMBER) IS
    select crapthi.cdcooper,
           crapthi.cdhistor,
           upper(craprej.dtrefere) dtrefere,
           craprej.nrdctabb,
           craprej.cdagenci,
           craprej.nrseqdig,
           crapthi.vltarifa,
           craprej.nraplica,
           craprej.vlsdapli
      from craprej,
           crapthi
     where crapthi.cdcooper = pr_cdcooper
       and crapthi.vltarifa > 0
       and crapthi.dsorigem = 'AYLLOS'
       and craprej.cdcooper = crapthi.cdcooper
       and craprej.cdhistor = crapthi.cdhistor
       and craprej.cdpesqbb = pr_cdprogra
       and craprej.dtmvtolt = pr_dtmvtolt
       AND ((craprej.nraplica = pr_nraplica -- Buscar Total Geral (0-Geral/1-Total por PF/2-Total por PJ)
       AND  pr_nraplica = 0)
        OR (craprej.nraplica IN (1,2)
       AND   pr_nraplica > 0))
     order by crapthi.cdhistor,
              craprej.nraplica,
              craprej.nrdctabb,
              craprej.cdbccxlt,
              craprej.cdagenci,
              craprej.dtrefere;
  -- Histórico
  cursor cr_craphis2 (pr_cdcooper in crapthi.cdcooper%type,
                      pr_cdhistor in crapthi.cdhistor%type) is
    select cdhistor,
           cdhstctb,
           tpctbcxa,
           nrctatrd,
           nrctatrc,
           dsexthst,
           nrctacrd,
           nrctadeb,
           ingerdeb,
           ingercre,
           dshistor
      from craphis
     where craphis.cdcooper = pr_cdcooper
       and craphis.cdhistor = pr_cdhistor
     ORDER BY craphis.progress_recid;
  rw_craphis2     cr_craphis2%rowtype;
  -- Busca parâmetro genérico cadastrado
  cursor cr_craptab2 (pr_cdcooper in craptab.cdcooper%type,
                      pr_tptabela in craptab.tptabela%type,
                      pr_nrdctabb in craptab.cdacesso%type) is
    select dstextab
      from craptab
     where craptab.cdcooper        = pr_cdcooper
       and UPPER(craptab.tptabela) = pr_tptabela
       and UPPER(craptab.cdacesso) = pr_nrdctabb;
  -- Tarifa dos históricos
  cursor cr_crabthi (pr_cdcooper in crapthi.cdcooper%type,
                     pr_cdhistor in crapthi.cdhistor%type,
                     pr_dsorigem in crapthi.dsorigem%type) is
    select vltarifa
      from crapthi
     where crapthi.cdcooper = pr_cdcooper
       and crapthi.cdhistor = pr_cdhistor
       and crapthi.dsorigem = pr_dsorigem;
  rw_crabthi     cr_crabthi%rowtype;
  -- Subscrição de capital
  cursor cr_crapsdc (pr_cdcooper in craptab.cdcooper%type,
                     pr_dtmvtolt in crapdat.dtmvtolt%type,
                     pr_indebito in crapsdc.indebito%type) is
    select sum(vllanmto) vllanmto
      from crapsdc
     where crapsdc.cdcooper = pr_cdcooper
       and crapsdc.dtdebito = pr_dtmvtolt
       and crapsdc.indebito = nvl(pr_indebito, crapsdc.indebito);

  -- Subscrição de capital atual
  cursor cr_crapsdc_LT (pr_cdcooper in craptab.cdcooper%type,
                         pr_dtmvtolt in crapdat.dtmvtolt%type) is
    select sum(vllanmto) vllanmto
      from crapsdc
     where crapsdc.cdcooper = pr_cdcooper
       and crapsdc.dtmvtolt = pr_dtmvtolt;

  -- Entradas de cheques em custodia do dia
  cursor cr_crapcst (pr_cdcooper in craptab.cdcooper%type,
                     pr_dtmvtolt in crapdat.dtmvtolt%type) is
    select nrdconta,
           vlcheque
      from crapcst
     where crapcst.cdcooper = pr_cdcooper
       and crapcst.dtmvtolt = pr_dtmvtolt
	   and crapcst.nrborder = 0;
  -- Liberacao de cheques em custodia do dia
  cursor cr_crapcst2 (pr_cdcooper in craptab.cdcooper%type,
                      pr_dtmvtoan in crapcst.dtlibera%type,
                      pr_dtmvtolt in crapcst.dtlibera%type) is
    select /*+ index (crapcst crapcst##crapcst3)*/
           nrdconta,
           vlcheque
      from crapcst
     where crapcst.cdcooper = pr_cdcooper
       and crapcst.dtlibera > pr_dtmvtoan
       and crapcst.dtlibera <= pr_dtmvtolt
       and crapcst.dtdevolu is null
	   and crapcst.nrborder = 0;
  -- Resgates de cheques em custodia do dia / transf. para desconto de cheques
  cursor cr_crapcst3 (pr_cdcooper in craptab.cdcooper%type,
                      pr_dtmvtolt in crapdat.dtmvtolt%type) is
    select /*+ index (crapcst crapcst##crapcst6)*/
           nrdconta,
           vlcheque,
           insitchq
      from crapcst
     where crapcst.cdcooper = pr_cdcooper
       and crapcst.dtdevolu = pr_dtmvtolt
	   and crapcst.nrborder = 0;
  -- Títulos compensáveis
  cursor cr_craptit (pr_cdcooper in craptit.cdcooper%type,
                     pr_dtmvtolt in craptit.dtmvtolt%type,
                     pr_intitcop in craptit.intitcop%type)is
    select /*+ index (craptit craptit##craptit4)*/
           craptit.cdagenci,
           sum(craptit.vldpagto) vldpagto,
           count(*) qttottrf
      from craptit
     where craptit.cdcooper = pr_cdcooper
       and craptit.dtdpagto = pr_dtmvtolt
       and craptit.insittit in (0,2,4)
       and craptit.tpdocmto = 20
       and craptit.intitcop = pr_intitcop -- 0 = Outros Bancos; 1 = Cooperativa
     group by craptit.cdagenci
     order by craptit.cdagenci;
  -- Código do banco do titulo para uma agencia
  cursor cr_crapage2 (pr_cdcooper in crapage.cdcooper%type,
                      pr_cdagenci in crapage.cdagenci%type) is
    select cdbantit,
           cdbanchq
      from crapage
     where crapage.cdcooper = pr_cdcooper
       and crapage.cdagenci = pr_cdagenci;
  rw_crapage2     cr_crapage2%rowtype;
  -- Borderôs de desconto de cheques
  cursor cr_crapbdc (pr_cdcooper in crapbdc.cdcooper%type,
                     pr_dtmvtolt in crapbdc.dtlibbdc%type) is
    select nrborder
      from crapbdc
     where crapbdc.cdcooper = pr_cdcooper
       and crapbdc.dtlibbdc = pr_dtmvtolt
       and crapbdc.insitbdc = 3;
  -- Desconto de cheques
  cursor cr_crapcdb (pr_cdcooper in crapcdb.cdcooper%type,
                     pr_nrborder in crapcdb.nrborder%type) is
    select /*+ index (crapcdb crapcdb##crapcdb7)*/
           vlcheque,
           vlliquid,
           nrdconta,
           nrborder,
           cdagenci,
           nrcheque
      from crapcdb
     where crapcdb.cdcooper = pr_cdcooper
       and crapcdb.nrborder = pr_nrborder
       AND crapcdb.insitana = 1; --> apenas os aprovados
  -- Desconto de cheques
  cursor cr_crapcdb2 (pr_cdcooper in crapcdb.cdcooper%type,
                      pr_dtmvtoan in crapcdb.dtlibera%type,
                      pr_dtmvtolt in crapcdb.dtlibera%type) is
    select /*+ index (crapcdb crapcdb##crapcdb3)*/
           vlcheque,
           vlliquid,
           nrdconta,
           nrborder,
           cdagenci,
           nrcheque,
           inchqcop
      from crapcdb
     where crapcdb.cdcooper = pr_cdcooper
       and crapcdb.dtlibera > pr_dtmvtoan
       and crapcdb.dtlibera <= pr_dtmvtolt
       AND crapcdb.insitana = 1 --> apenas os aprovados
       and crapcdb.dtlibbdc is not null
       and crapcdb.dtdevolu is null;
  -- Desconto de cheques
  cursor cr_crapcdb3 (pr_cdcooper in crapcdb.cdcooper%type,
                      pr_dtdevolu in crapcdb.dtdevolu%type) is
    select /*+ index (crapcdb crapcdb##crapcdb6)*/
           vlcheque,
           vlliquid,
           nrdconta,
           nrborder,
           cdagenci,
           nrcheque,
           inchqcop,
           vlliqdev
      from crapcdb
     where crapcdb.cdcooper = pr_cdcooper
       and crapcdb.dtdevolu = pr_dtdevolu
       and crapcdb.insitana = 1 --> apenas os aprovados
       and crapcdb.insitchq = 1; -- Resgatado
  -- Borderô de desconto de títulos
  cursor cr_crapbdt (pr_cdcooper in crapbdt.cdcooper%type,
                     pr_dtmvtolt in crapbdt.dtlibbdt%type) is
    select nrdconta,
           nrborder,
           cdagenci
      from crapbdt
     where crapbdt.cdcooper = pr_cdcooper
       and crapbdt.dtlibbdt = pr_dtmvtolt
       and crapbdt.insitbdt in (3, 4); -- Liberado ou Liquidado
  -- Títulos do borderô
  cursor cr_craptdb (pr_cdcooper in craptdb.cdcooper%type,
                     pr_nrdconta in craptdb.nrdconta%type,
                     pr_nrborder in craptdb.nrborder%type) is
    select /*+index (craptdb craptdb##craptdb1)*/
           craptdb.nrdconta,
           craptdb.nrborder,
           craptdb.nrdocmto,
           craptdb.vltitulo,
           crapcob.flgregis,
           craptdb.vlliquid
      from crapcob,
           craptdb
     where craptdb.cdcooper = pr_cdcooper
       and craptdb.nrdconta = pr_nrdconta
       and craptdb.nrborder = pr_nrborder
       --and craptdb.insittit <> 1 -- Resgatado
       and crapcob.cdcooper = craptdb.cdcooper
       and crapcob.nrdconta = craptdb.nrdconta
       and crapcob.nrcnvcob = craptdb.nrcnvcob
       and crapcob.nrdocmto = craptdb.nrdocmto
       and crapcob.nrdctabb = craptdb.nrdctabb
	   and crapcob.cdbandoc = craptdb.cdbandoc;

  -- Títulos em desconto
  cursor cr_craptdb2 (pr_cdcooper in craptdb.cdcooper%type,
                      pr_dt_ini in craptdb.dtdpagto%type,
                      pr_dt_fim in craptdb.dtdpagto%type,
                      pr_cdbandoc in craptdb.cdbandoc%type) is
    select /*+ index (craptdb craptdb##craptdb2)*/
           craptdb.cdcooper,
           craptdb.cdbandoc,
           craptdb.nrdctabb,
           craptdb.nrcnvcob,
           craptdb.nrdconta,
           craptdb.nrdocmto,
           craptdb.nrborder,
           craptdb.vltitulo,
           craptdb.vlliquid,
           craptdb.vlliqres,
           craptdb.dtlibbdt,
           craptdb.dtvencto,
           craptdb.rowid
      from craptdb
     where craptdb.cdcooper = pr_cdcooper
       and craptdb.cdbandoc = nvl(pr_cdbandoc,craptdb.cdbandoc)
       and craptdb.dtdpagto > pr_dt_ini
       and craptdb.dtdpagto <= pr_dt_fim
       and craptdb.insittit = 2; -- Processados

  -- Verificar se o título é da migração
  cursor cr_crapcco (pr_cdcooper in crapcco.cdcooper%type,
                     pr_nrcnvcob in crapcco.nrconven%type) is
    select crapcco.dsorgarq
      from crapcco
     where crapcco.cdcooper = pr_cdcooper
       and crapcco.nrconven = pr_nrcnvcob;
  rw_crapcco     cr_crapcco%rowtype;
  -- Títulos em desconto
  cursor cr_craptdb3 (pr_cdcooper in craptdb.cdcooper%type,
                      pr_dtmvtolt in craptdb.dtdpagto%type) is
    select /*+ index (craptdb craptdb##craptdb2)*/
           craptdb.cdcooper,
           craptdb.cdbandoc,
           craptdb.nrdctabb,
           craptdb.nrcnvcob,
           craptdb.nrdconta,
           craptdb.nrdocmto,
           craptdb.nrborder,
           craptdb.vltitulo,
           craptdb.vlliquid,
           craptdb.vlliqres,
           craptdb.dtlibbdt,
           craptdb.dtvencto,
           craptdb.rowid
      from craptdb
     where craptdb.cdcooper = pr_cdcooper
       and craptdb.dtdpagto = pr_dtmvtolt
       and craptdb.insittit  = 2; -- Processado
  -- Títulos em desconto
  cursor cr_craptdb4 (pr_cdcooper in craptdb.cdcooper%TYPE
                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) is
    select craptdb.cdcooper,
           craptdb.cdbandoc,
           craptdb.nrdctabb,
           craptdb.nrcnvcob,
           craptdb.nrdconta,
           craptdb.nrdocmto,
           craptdb.nrborder,
           craptdb.vltitulo,
           craptdb.vlliquid,
           craptdb.vlliqres,
           craptdb.dtlibbdt,
           craptdb.dtvencto,
           craptdb.rowid
      from craptdb
     where craptdb.cdcooper = pr_cdcooper
       and craptdb.dtdebito = pr_dtmvtolt
       and craptdb.insittit = 3; -- Processado
  -- Títulos em desconto
  cursor cr_craptdb5 (pr_cdcooper in craptdb.cdcooper%type,
                      pr_dtmvtolt in craptdb.dtdpagto%type) is
    select /*+ index (craptdb craptdb##craptdb4)*/
           craptdb.cdcooper,
           craptdb.cdbandoc,
           craptdb.nrdctabb,
           craptdb.nrcnvcob,
           craptdb.nrdconta,
           craptdb.nrdocmto,
           craptdb.nrborder,
           craptdb.vltitulo,
           craptdb.vlliquid,
           craptdb.vlliqres,
           craptdb.dtlibbdt,
           craptdb.dtvencto,
           craptdb.rowid
      from craptdb
     where craptdb.cdcooper = pr_cdcooper
       and craptdb.dtresgat = pr_dtmvtolt
       and craptdb.dtlibbdt <> pr_dtmvtolt;
  -- Documentos do desconto de títulos
  cursor cr_crapcob (pr_cdcooper in craptdb.cdcooper%type,
                     pr_cdbandoc in craptdb.cdbandoc%type,
                     pr_nrdctabb in craptdb.nrdctabb%type,
                     pr_nrcnvcob in craptdb.nrcnvcob%type,
                     pr_nrdconta in craptdb.nrdconta%type,
                     pr_nrdocmto in craptdb.nrdocmto%type) is
    select indpagto,
           flgregis,
           vldpagto,
           nrdconta,
           vltitulo,
           nrcnvcob
      from crapcob
     where crapcob.cdcooper = pr_cdcooper
       and crapcob.cdbandoc = pr_cdbandoc
       and crapcob.nrdctabb = pr_nrdctabb
       and crapcob.nrcnvcob = pr_nrcnvcob
       and crapcob.nrdconta = pr_nrdconta
       and crapcob.nrdocmto = pr_nrdocmto;
  rw_crapcob     cr_crapcob%rowtype;
  -- Informações do associado
  cursor cr_crapass (pr_cdcooper in crapass.cdcooper%type,
                     pr_nrdconta in crapass.nrdconta%type) is
    select crapass.cdagenci,
           crapass.inpessoa,
           crapass.dtdemiss,
           crapage.insitage
      from crapass,
           crapage
     where crapass.cdcooper = crapage.cdcooper
       and crapass.cdagenci = crapage.cdagenci
       and crapass.cdcooper = pr_cdcooper
       and crapass.nrdconta = pr_nrdconta;
  rw_crapass     cr_crapass%rowtype;
  -- Borderôs de desconto de títulos
  cursor cr_crapbdt2 (pr_cdcooper in crapbdt.cdcooper%type,
                      pr_dtlibbdt in crapbdt.dtlibbdt%type,
                      pr_nrborder in crapbdt.nrborder%type,
                      pr_nrdconta in crapbdt.nrdconta%type) is
    select crapbdt.cdagenci
      from crapbdt
     where crapbdt.cdcooper = pr_cdcooper
       and crapbdt.dtlibbdt = pr_dtlibbdt
       and crapbdt.nrborder = pr_nrborder
       and crapbdt.nrdconta = pr_nrdconta;

  rw_crapbdt2     cr_crapbdt2%rowtype;
  -- Retorno de títulos bancários do banco do brasil
  cursor cr_crapret (pr_cdcooper in crapret.cdcooper%type,
                     pr_dtmvtolt in crapret.dtaltera%type) is
    select crapret.cdhistbb,
           sum(nvl(crapret.vltarcus, 0)) vltarcus,
           sum(sum(nvl(crapret.vltarcus, 0))) over (partition by crapret.cdhistbb) vltarcus_tot,
           sum(nvl(crapret.vloutdes, 0)) vloutdes,
           sum(sum(nvl(crapret.vloutdes, 0))) over (partition by crapret.cdhistbb) vloutdes_tot,
           crapass.cdagenci
      from crapass,
           crapret,
           crapcco
     where crapcco.cdcooper = pr_cdcooper
       AND crapcco.cddbanco = 1
       AND crapcco.flgregis = 1
       AND crapcco.dsorgarq NOT IN ('MIGRACAO','INCORPORACAO')
       AND crapret.cdcooper = crapcco.cdcooper
       AND crapret.nrcnvcob = crapcco.nrconven
       and crapret.dtocorre = pr_dtmvtolt
       and cdhistbb in (936, 937, 938, 939, 940, 965, 966, 973)
       and crapass.cdcooper = crapret.cdcooper
       and crapass.nrdconta = crapret.nrdconta
     group by crapret.cdhistbb,
              crapass.cdagenci
     order by crapret.cdhistbb,
              crapass.cdagenci;
  rw_crapret     cr_crapret%rowtype;
  -- Retorno de títulos bancários (associados não cadastrados)
  cursor cr_crapret2 (pr_cdcooper in crapret.cdcooper%type,
                      pr_dtmvtolt in crapret.dtaltera%type) is
    select crapret.rowid
      from crapret
          ,crapcco
     WHERE crapcco.cdcooper = pr_cdcooper
       AND crapcco.cddbanco = 1
       AND crapcco.flgregis = 1
       AND crapcco.dsorgarq NOT IN ('MIGRACAO','INCORPORACAO')
       AND crapret.cdcooper = crapcco.cdcooper
       AND crapret.nrcnvcob = crapcco.nrconven
       and crapret.dtocorre = pr_dtmvtolt
       and crapret.cdhistbb in (936, 937, 938, 939, 940, 965, 966, 973)
       -- Não existam associados
       and not exists (select 1
                         from crapass
                        where crapass.cdcooper = crapret.cdcooper
                          and crapass.nrdconta = crapret.nrdconta);
  -- Buscar acertos financeiros
  cursor cr_crapafi (pr_cdcooper in crapafi.cdcooper%type,
                     pr_dtmvtolt in crapafi.dtmvtolt%type) is
    select crapafi.cdcopdst,
           crapafi.cdhistor,
           sum(crapafi.vllanmto) vlafitot -- valor para crédito e débito, tratamento com IF dentro do loop
      from crapafi
     where crapafi.cdcooper = pr_cdcooper
       and crapafi.dtlanmto = pr_dtmvtolt
       and crapafi.cdhistor IN (266,971)  -- CREDITO DE COBRANCA BANCO DO BRASIL e CREDITO DE COBRANCA REGISTRADA B. BRASIL
  group by crapafi.cdcopdst
          ,crapafi.cdhistor;

  -- Buscar acertos financeiros e do associado por data , historico e conta bb
  cursor cr_crapafi2 (pr_cdcooper in crapafi.cdcooper%type,
                      pr_dtmvtolt in crapafi.dtmvtolt%type,
                      pr_cdhistor in crapafi.cdhistor%type,
                      pr_nrdctabb in crapafi.nrdctabb%type) is
    select crapafi.cdcopdst,
           crapafi.cdhistor,
           crapafi.vllanmto,  -- valor para crédito e débito, tratamento com IF dentro do loop
           crapass.cdagenci,
           Count(1) OVER (PARTITION BY crapafi.cdhistor) qtdreg,
           Row_Number() OVER (PARTITION BY crapafi.cdhistor ORDER BY crapafi.cdhistor) nrseqreg
     from crapafi,
          crapass
    where crapafi.cdcooper = pr_cdcooper
      and crapafi.dtlanmto = pr_dtmvtolt
      and crapafi.cdhistor = pr_cdhistor
      and crapafi.nrdctabb = pr_nrdctabb
      and crapass.cdcooper = crapafi.cdcooper
      and crapass.nrdconta = crapafi.nrctadst;

  -- Buscar acertos financeiros por data , historico e conta bb
  cursor cr_crapafi3 (pr_cdcooper in crapafi.cdcooper%type,
                      pr_dtmvtolt in crapafi.dtmvtolt%type,
                      pr_cdhistor in crapafi.cdhistor%type,
                      pr_nrdctabb in crapafi.nrdctabb%type) is
   select crapafi.cdcopdst,
          crapafi.cdhistor,
          sum(crapafi.vllanmto) vlafitot -- valor para crédito e débito, tratamento com IF dentro do loop
     from crapafi
    where crapafi.cdcooper = pr_cdcooper
      and crapafi.dtlanmto = pr_dtmvtolt
      and crapafi.cdhistor = pr_cdhistor
      and crapafi.nrdctabb = pr_nrdctabb
    group by crapafi.cdcopdst
            ,crapafi.cdhistor;

  -- IPTU
  cursor cr_craptit2 (pr_cdcooper in craptit.cdcooper%type,
                      pr_dtmvtolt in craptit.dtmvtolt%type) is
    select /*+ index (craptit craptit4##craptit4)*/
           craptit.cdagenci,
           sum(craptit.vldpagto) vldpagto,
           count(*) qttottrf
      from craptit
     where craptit.cdcooper = pr_cdcooper
       and craptit.dtdpagto = pr_dtmvtolt
       and craptit.insittit = 4
       and craptit.tpdocmto = 21
     group by craptit.cdagenci
     order by craptit.cdagenci;
  -- COBAN
  cursor cr_crapcbb (pr_cdcooper in crapcbb.cdcooper%type,
                     pr_dtmvtolt in crapcbb.dtmvtolt%type) is
    select crapcbb.cdagenci,
           sum(crapcbb.valorpag) valorpag,
           count(*) qttottrf
      from crapcbb
     where crapcbb.cdcooper = pr_cdcooper
       AND crapcbb.dtmvtolt = pr_dtmvtolt
       and crapcbb.flgrgatv = 1
       and crapcbb.tpdocmto < 3
     group by crapcbb.cdagenci
     order by crapcbb.cdagenci;
  -- COBAN - recebimento inss
  cursor cr_crapcbb2 (pr_cdcooper in crapcbb.cdcooper%type,
                      pr_dtmvtolt in crapcbb.dtmvtolt%type) is
    select crapcbb.cdagenci,
           sum(crapcbb.valorpag) valorpag,
           count(*) qttottrf
      from crapcbb
     where crapcbb.cdcooper = pr_cdcooper
       AND crapcbb.dtmvtolt = pr_dtmvtolt
       and crapcbb.flgrgatv = 1
       and crapcbb.tpdocmto = 3
     group by crapcbb.cdagenci
     order by crapcbb.cdagenci;
  -- Créditos pagos INSS
  cursor cr_craplpi (pr_cdcooper in craplpi.cdcooper%type,
                     pr_dtmvtolt in craplpi.dtmvtolt%type,
                     pr_cdagenci in craplpi.cdagenci%type) is
    select craplpi.tppagben,
           craplpi.vllanmto,
           craplpi.cdagenci
      from craplpi
     where craplpi.cdcooper = pr_cdcooper
       and craplpi.dtmvtolt = pr_dtmvtolt
       and craplpi.cdagenci = pr_cdagenci;
  -- Depósitos à vista
  cursor cr_craplcm (pr_cdcooper in craplcm.cdcooper%type,
                     pr_dtmvtolt in craplcm.dtmvtolt%type,
                     pr_cdagenci in craplcm.cdagenci%type) is
    select craplcm.cdagenci
      from craplcm
     where craplcm.cdcooper = pr_cdcooper
       and craplcm.dtmvtolt = pr_dtmvtolt
       and craplcm.cdagenci = pr_cdagenci
       and craplcm.cdhistor = 581; -- CREDITO DO BENEFICIO DO INSS

  -- Guias de previdência social
  cursor cr_gps_gerencial(pr_cdcooper in craplgp.cdcooper%type,
                     pr_dtmvtolt in craplgp.dtmvtolt%type) is
    select vlr.cdagenci,
           sum(vlr.vlrtotal) vlrtotal,
           count(*) qttottrf
      from ( select lgp.cdagenci
                   ,lgp.vlrtotal
              from craplgp lgp
             where lgp.cdcooper = pr_cdcooper
               and lgp.dtmvtolt = pr_dtmvtolt
               AND lgp.cdbccxlt = 11 -- GPS ANTIGO
          UNION ALL
            select lgp.cdagenci
                  ,lgp.vlrtotal
              from craplgp lgp
             where lgp.cdcooper = pr_cdcooper
               and lgp.dtmvtolt = pr_dtmvtolt
               AND lgp.cdbccxlt = 100 -- GPS NOVO
               AND lgp.flgpagto = 1   -- PAGO
               AND lgp.idsicred <> 0
               AND lgp.flgativo = 1
            ) vlr
     group by vlr.cdagenci
     order by vlr.cdagenci;
  -- Despesas SICREDI GPS
  cursor cr_gps_despesas (pr_cdcooper in craplgp.cdcooper%type,
                     pr_dtmvtolt in craplgp.dtmvtolt%type) is
    select tmp.cdagenci,
           sum(tmp.vlrtotal) vlrtotal,
           count(*) qttottrf
      from (SELECT lgp.vlrtotal
                  ,decode(lgp.cdagenci,
                          90, nvl(ass.cdagenci, lgp.cdagenci),
                          91, nvl(ass.cdagenci, lgp.cdagenci),
                          lgp.cdagenci) cdagenci
              FROM craplgp lgp, crapass ass
             WHERE lgp.cdcooper = pr_cdcooper
               AND lgp.dtmvtolt = pr_dtmvtolt
               AND lgp.idsicred <> 0
               AND lgp.flgativo = 1
               and lgp.cdcooper = ass.cdcooper (+)
               and lgp.nrctapag = ass.nrdconta (+)) tmp
     group by tmp.cdagenci
     order by tmp.cdagenci;

  -- Conta investimento
  cursor cr_craplci (pr_cdcooper in craplci.cdcooper%type,
                     pr_dtmvtolt in craplci.dtmvtolt%type) is
    select craplci.cdhistor,
           craplci.cdagenci,
           craplci.nrdconta,
           craplci.vllanmto
      from craplci
     where craplci.cdcooper = pr_cdcooper
       and craplci.dtmvtolt = pr_dtmvtolt
       and craplci.cdhistor in (485, 486, 487, 647, 648); -- Débitos e Créditos em investimentos
  -- Lançamentos extra-sistema para boletim de caixa
  cursor cr_craplcx (pr_cdcooper in craplcx.cdcooper%type,
                     pr_dtmvtolt in craplcx.dtmvtolt%type) is
    select /*+ index (craplcx craplcx##craplcx1)*/
           cdagenci,
           nrdcaixa,
           vldocmto,
           dsdcompl,
           cdhistor
      from craplcx
     where craplcx.cdcooper = pr_cdcooper
       and craplcx.dtmvtolt = pr_dtmvtolt
       and craplcx.cdhistor not in (718, 731, 2063, 2064); -- Custódia de cheques   -- Saque demitidos
  -- Saldo do terminal financeiro
  cursor cr_crapstf (pr_cdcooper in crapstf.cdcooper%type,
                     pr_dtmvtolt in crapstf.dtmvtolt%type) is
    select nrterfin,
           dtmvtolt
      from crapstf
     where crapstf.cdcooper = pr_cdcooper
       and crapstf.dtmvtolt = pr_dtmvtolt;
  -- Cadastro do terminal financeiro
  cursor cr_craptfn (pr_cdcooper in craptfn.cdcooper%type,
                     pr_nrterfin in craptfn.nrterfin%type) is
    select cdagenci,
           nrterfin
      from craptfn
     where craptfn.cdcooper = pr_cdcooper
       and craptfn.nrterfin = pr_nrterfin;
  rw_craptfn     cr_craptfn%rowtype;
  -- Log de operação do terminal financeiro
  cursor cr_craplfn (pr_cdcooper in craplfn.cdcooper%type,
                     pr_dtmvtolt in craplfn.dtmvtolt%type,
                     pr_nrterfin in craplfn.nrterfin%type) is
    select cdoperad,
           nrterfin,
           sum(decode(tpdtrans, 4, vltransa, 0)) vlsuprim,
           sum(decode(tpdtrans, 5, vltransa, 0)) vlrecolh
      from craplfn
     where craplfn.cdcooper = pr_cdcooper
       and craplfn.dtmvtolt = pr_dtmvtolt
       and craplfn.nrterfin = pr_nrterfin
     group by cdoperad,
              nrterfin
     ORDER BY MIN(craplfn.progress_recid); -- Renato Darosci - 18/10/2013
  -- Operador
  cursor cr_crapope (pr_cdcooper in crapope.cdcooper%type,
                     pr_cdoperad in crapope.cdoperad%type) is
    select nmoperad
      from crapope
     where crapope.cdcooper = pr_cdcooper
       and crapope.cdoperad = pr_cdoperad;
  rw_crapope     cr_crapope%rowtype;
  -- Contabilização da COMP ELETRONICA
  cursor cr_craplot (pr_cdcooper in craplot.cdcooper%type,
                     pr_dtmvtolt in craplot.dtmvtolt%type) is
    select /*+ index (crapchd crapchd##crapchd3)*/
           craplot.cdagenci,
           craplot.nrdcaixa,
           craplot.cdopecxa,
           sum(crapchd.vlcheque) vlcompel,
           count(*) qtcompel
      from crapchd,
           craplot
     where craplot.cdcooper = pr_cdcooper
       and craplot.dtmvtolt = pr_dtmvtolt
       and craplot.cdbccxlt in (11, 500)
       and craplot.tplotmov in (1, 23, 29)
       and crapchd.cdcooper = craplot.cdcooper
       and crapchd.dtmvtolt = craplot.dtmvtolt
       and crapchd.cdagenci = craplot.cdagenci
       and crapchd.cdbccxlt = craplot.cdbccxlt
       and crapchd.nrdolote = craplot.nrdolote
       and crapchd.inchqcop = 0
     group by craplot.cdagenci,
              craplot.nrdcaixa,
              craplot.cdopecxa
     order by craplot.cdagenci,
              craplot.nrdcaixa,
              craplot.cdopecxa;
  -- Transferência de salário para outra instituição
  cursor cr_craplcs (pr_cdcooper in craplcs.cdcooper%type,
                     pr_dtmvtolt in craplcs.dtmvtolt%type,
                     pr_cdhistor in craplcs.cdhistor%type) is
    select cdagenci,
           sum(vllanmto) vllanmto
      from craplcs
     where craplcs.cdcooper = pr_cdcooper
       and craplcs.dtmvtolt = pr_dtmvtolt
       and craplcs.cdhistor = pr_cdhistor
     group by cdagenci
     order by cdagenci;
  -- Transferência de salário para outra instituição
  cursor cr_craplcs2 (pr_cdcooper in craplcs.cdcooper%type,
                      pr_dtmvtolt in craplcs.dtmvtolt%type,
                      pr_cdhistor in craplcs.cdhistor%type) is
    select dtmvtolt,
           sum(vllanmto) vllanmto
      from craplcs
     where craplcs.cdcooper = pr_cdcooper
       and craplcs.dtmvtolt = pr_dtmvtolt
       and craplcs.cdhistor = pr_cdhistor
     group by dtmvtolt
     order by dtmvtolt;
  -- Depósitos à vista
  cursor cr_craplcm2 (pr_cdcooper in craplcm.cdcoptfn%type,
                      pr_dtmvtolt in craplcm.dtmvtolt%type,
                      pr_cdhistor in craplcm.cdhistor%type) is
    select cdagetfn,
           sum(vllanmto) vllanmto
      from craplcm
     where craplcm.cdcoptfn = pr_cdcooper
       and craplcm.dtmvtolt = pr_dtmvtolt
       and craplcm.cdhistor = pr_cdhistor
     group by cdagetfn
     order by cdagetfn;
	 
  -- Saque Cooperados Demitidos
  cursor cr_craplcm21 (pr_cdcooper in craplcm.cdcoptfn%type,
                       pr_dtmvtolt in craplcm.dtmvtolt%type) is
   select craplcx.cdagenci
         ,decode(craplcx.cdhistor,2065,decode(crapass.inpessoa,1,2063,2064)
                                      ,decode(crapass.inpessoa,1,2081,2082)) cdhistor
         ,sum(craplcx.vldocmto) vllanmto
     from craplcx
         ,crapass
    where craplcx.cdcooper = pr_cdcooper
      and craplcx.dtmvtolt = pr_dtmvtolt
      and craplcx.cdhistor in (2065,2083)
      and craplcx.cdcooper = crapass.cdcooper
      and craplcx.nrdconta = crapass.nrdconta
    group by craplcx.cdagenci
            ,decode(craplcx.cdhistor,2065,decode(crapass.inpessoa,1,2063,2064)
                                          ,decode(crapass.inpessoa,1,2081,2082))
    order by craplcx.cdagenci
            ,decode(craplcx.cdhistor,2065,decode(crapass.inpessoa,1,2063,2064)
                                          ,decode(crapass.inpessoa,1,2081,2082));

   -- FINAME BNDES
  CURSOR cr_craplcm7 (pr_cdcooper IN craplcm.cdcooper%TYPE,
                      pr_dtmvtolt IN craplcm.dtmvtolt%TYPE,
                      pr_cdhistor IN craplcm.cdhistor%TYPE) IS
    SELECT cdcooper,
           SUM(vllanmto) vllanmto
      FROM craplcm
     WHERE craplcm.cdcooper = pr_cdcooper
       AND craplcm.dtmvtolt = pr_dtmvtolt
       AND craplcm.cdhistor = pr_cdhistor
     GROUP BY cdcooper; 	 

	-- Buscar operadoras ativas
	CURSOR cr_operadora (pr_cdcooper IN craplcm.cdcooper%TYPE
	                    ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
                      ,pr_inpessoa IN crapass.inpessoa%TYPE) IS
	  SELECT tope.cdoperadora
		      ,topr.nmoperadora
					,topr.perreceita
          ,decode(pr_inpessoa,0,0,ass.inpessoa) inpessoa
          ,ass.cdagenci
          ,sum(vlrecarga) vlrecarga  
          ,(SUM(vlrecarga) - SUM(tope.vlrepasse)) vl_receita
		  FROM tbrecarga_operacao tope
			    ,tbrecarga_operadora topr
          ,crapass             ass
     WHERE tope.cdcooper = ass.cdcooper
       and tope.nrdconta = ass.nrdconta
       and tope.cdcooper = pr_cdcooper
		   AND tope.insit_operacao = 2
			 AND tope.dtdebito = pr_dtmvtolt
			 AND topr.cdoperadora = tope.cdoperadora
       AND ass.inpessoa = decode(pr_inpessoa,0,ass.inpessoa,pr_inpessoa)
			GROUP BY tope.cdoperadora
		          ,topr.nmoperadora
              ,topr.perreceita
              ,ass.cdagenci
              ,decode(pr_inpessoa,0,0,ass.inpessoa)
      order by ass.cdagenci;
		 		 
      
  CURSOR cr_recargas (pr_cdcooper    IN craplcm.cdcooper%TYPE
	                   ,pr_dtmvtolt    IN craplcm.dtmvtolt%TYPE
                     ,pr_inpessoa    IN crapass.inpessoa%TYPE) IS
                     
   SELECT cdagenci,
          inpessoa,
          sum(vl_receita) vl_receita
     FROM (SELECT tope.cdoperadora
                 ,topr.perreceita
                 ,decode(pr_inpessoa,0,0,ass.inpessoa) inpessoa
                 ,ass.cdagenci
                 ,(SUM(vlrecarga) - SUM(tope.vlrepasse)) vl_receita
		  FROM tbrecarga_operacao tope
                 ,tbrecarga_operadora topr
			    ,crapass ass
            WHERE tope.cdcooper       = ass.cdcooper
              and tope.nrdconta       = ass.nrdconta
              and tope.cdcooper       = pr_cdcooper
		   AND tope.insit_operacao = 2
              AND tope.dtdebito       = pr_dtmvtolt
              AND topr.cdoperadora    = tope.cdoperadora
              AND ass.inpessoa        = decode(pr_inpessoa,0,ass.inpessoa,pr_inpessoa)
             GROUP BY tope.cdoperadora
                     ,topr.perreceita
                     ,ass.cdagenci
                     ,decode(pr_inpessoa,0,0,ass.inpessoa)
             order by ass.cdagenci)
   GROUP BY cdagenci,
            inpessoa
   ORDER BY cdagenci;      
	
	-- Repasse recarga de celular
	CURSOR cr_craptvl_recarg (pr_cdcooper IN crapcop.cdcooper%TYPE
	                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
	  SELECT tvl.vldocrcb
		  FROM craptvl tvl
		 WHERE tvl.cdcooper = pr_cdcooper
		   AND tvl.dtmvtolt = pr_dtmvtolt
			 AND tvl.nrdolote = 600037
			 AND tvl.cdagenci = 1
			 AND tvl.cdbccxlt = 85
			 AND tvl.tpdoctrf = 3;
	rw_craptvl_recarg cr_craptvl_recarg%ROWTYPE;
	
  cursor cr_crapcon (pr_cdcooper in crapcon.cdcooper%type) is
    select crapcon.cdempcon,
           crapcon.cdsegmto,
           crapcon.cdhistor,
           crapcon.nmextcon
      from crapcon
     where crapcon.cdcooper = pr_cdcooper
       and crapcon.flgcnvsi = 1 -- Contem a situacao do convenio com o SICREDI (SIM/NAO).
     order by crapcon.progress_recid;
  rw_crapcon     cr_crapcon%rowtype;


  -- Convênio Sicredi
  cursor cr_crapscn (pr_cdempcon in crapcon.cdempcon%TYPE,
                     pr_cdsegmto IN crapcon.cdsegmto%TYPE) is
    select crapscn.cdempres
      from crapscn
     where crapscn.cdempcon = pr_cdempcon
       and crapscn.cdsegmto = pr_cdsegmto
       AND crapscn.dtencemp IS NULL
       AND crapscn.dsoparre <> 'E';
  rw_crapscn     cr_crapscn%rowtype;

  cursor cr_crapscn3 (pr_cdempcon in crapcon.cdempcon%TYPE,
                      pr_cdsegmto IN crapcon.cdsegmto%TYPE) is
    select crapscn.cdempres
      from crapscn
     where crapscn.cdempco2 = pr_cdempcon
       and crapscn.cdsegmto = pr_cdsegmto
       AND crapscn.dtencemp IS NULL
       AND crapscn.dsoparre <> 'E';

  -- Lançamento de faturas do convênio Sicredi
  cursor cr_craplft2 (pr_cdcooper in craplft.cdcooper%type,
                      pr_dtmvtolt in craplft.dtmvtolt%type,
                      pr_cdempcon in craplft.cdempcon%type,
                      pr_cdsegmto in craplft.cdsegmto%type,
                      pr_cdhistor in craplft.cdhistor%type,
                      pr_tpfatura in craplft.tpfatura%type,
                      pr_cdtr6106 number) is
    select decode(craplft.cdtribut,
                  6106, 'D0',
                  'A0') cdempres,
           craplft.cdagenci,
           lead (craplft.cdagenci,1) OVER (ORDER BY craplft.cdagenci) AS proxima_agencia,
           decode(craplft.cdagenci,
                  90, nvl(crapass.cdagenci, craplft.cdagenci),
                  91, nvl(crapass.cdagenci, craplft.cdagenci),
                  craplft.cdagenci) cdagenci_fatura,
           decode(craplft.tpfatura,
                  0, 0,
                  1) tpfatura, -- 0 para fatura, 1 para tributos
           count(craplft.vllanmto) qtlanmto,
           sum(craplft.vllanmto +
               craplft.vlrmulta +
               craplft.vlrjuros) vllanmto
      from crapass,
           craplft
     where craplft.cdcooper = pr_cdcooper
       and craplft.dtmvtolt = pr_dtmvtolt
       and craplft.cdempcon = pr_cdempcon
       and craplft.cdsegmto = pr_cdsegmto
       and craplft.cdhistor = pr_cdhistor
       and craplft.tpfatura = pr_tpfatura
       and ((pr_cdtr6106 = 0 and craplft.cdtribut <> 6106) or 
            (pr_cdtr6106 = 1 and craplft.cdtribut  = 6106))
       and crapass.cdcooper (+) = craplft.cdcooper
       and crapass.nrdconta (+) = craplft.nrdconta
     group by decode(craplft.cdtribut,
                     6106, 'D0',
                     'A0'),
              craplft.cdagenci,
              nvl(crapass.cdagenci, craplft.cdagenci),
              decode(craplft.tpfatura,
                     0, 0,
                     1)
     order by 1, 2, 3;
  -- Convênio Sicredi
  cursor cr_crapstn (pr_cdempres in crapstn.cdempres%type,
                     pr_tpdarrec in crapstn.tpmeiarr%type) is
    select crapstn.vltrfuni
      from crapstn
     where upper(crapstn.cdempres) = pr_cdempres
       and upper(crapstn.tpmeiarr) = pr_tpdarrec
	   AND crapstn.cdtransa = DECODE(crapstn.tpmeiarr, 
							  'D', DECODE(crapstn.cdempres, 'K0', '0XY', '147', '1CK', crapstn.cdtransa), 
							  crapstn.cdtransa);
  rw_crapstn     cr_crapstn%rowtype;
  -- Lançamento de faturas
  cursor cr_craplft (pr_cdcooper in craplft.cdcooper%type,
                     pr_dtmvtolt in craplft.dtmvtolt%type,
                     pr_cdempcon in craplft.cdempcon%type,
                     pr_cdsegmto in craplft.cdsegmto%type,
                     pr_cdhistor in craplft.cdhistor%type) is
    select craplft.cdempcon,
           craplft.cdsegmto,
           craplft.cdagenci,
           craplft.cdhistor,
           lead (craplft.cdagenci,1) OVER (ORDER BY craplft.cdagenci) AS proxima_agencia,
           decode(craplft.cdagenci,
                  90, nvl(crapass.cdagenci, craplft.cdagenci),
                  91, nvl(crapass.cdagenci, craplft.cdagenci),
                  craplft.cdagenci) cdagenci_fatura,
           decode(craplft.tpfatura,
                  0, 0,
                  1) tpfatura, -- 0 para fatura, 1 para tributos
           sum(craplft.vllanmto) vllanmto,
           count(*) qtlanmto
      from crapass,
           craplft
     where craplft.cdcooper = pr_cdcooper
       and craplft.dtmvtolt = pr_dtmvtolt
       and craplft.cdempcon = pr_cdempcon
       and craplft.cdsegmto = pr_cdsegmto
       and craplft.cdhistor = pr_cdhistor
       and crapass.cdcooper (+) = craplft.cdcooper
       and crapass.nrdconta (+) = craplft.nrdconta
     group by craplft.cdempcon,
              craplft.cdsegmto,
              craplft.cdagenci,
              craplft.cdhistor,
              nvl(crapass.cdagenci, craplft.cdagenci),
              decode(craplft.tpfatura,
                     0, 0,
                     1)
     order by craplft.cdempcon,
              craplft.cdsegmto,
              craplft.cdagenci;

  TYPE typ_cr_craplft IS TABLE OF cr_craplft%ROWTYPE index by binary_integer;
  rw_craplft  typ_cr_craplft;

  -- Convênio Sicredi
  cursor cr_crapscn2 (pr_cdempres in crapscn.cdempres%type) is
    select crapscn.cdempres,
           crapscn.dsnomcnv
      from crapscn
     where crapscn.cdempres = pr_cdempres;
  rw_crapscn2     cr_crapscn2%rowtype;

  -- Debito Automatico Sicredi
  CURSOR cr_craplcm4 (pr_cdcooper IN craplcm.cdcooper%TYPE,
                      pr_dtmvtolt IN craplcm.dtmvtolt%TYPE,
                      pr_cdhistor IN craplcm.cdhistor%TYPE) IS
    SELECT craplau.cdempres, crapscn.dsnomcnv, COUNT(*) qtlanmto, SUM(craplcm.vllanmto) vllanmto
      FROM craplcm, craplau, crapscn
      WHERE craplcm.cdcooper = craplau.cdcooper
        AND craplcm.nrdconta = craplau.nrdconta
        AND craplcm.cdhistor = craplau.cdhistor
        AND craplau.cdempres = crapscn.cdempres
        AND craplcm.nrdocmto = craplau.nrdocmto
        AND craplcm.cdcooper = pr_cdcooper
        AND craplcm.dtmvtolt = pr_dtmvtolt
        AND craplcm.dtmvtolt = craplau.dtdebito
        AND craplcm.cdhistor = pr_cdhistor
        AND crapscn.dtencemp IS NULL
        AND crapscn.dsoparre = 'E'
      GROUP BY craplau.cdempres,
               crapscn.dsnomcnv
      ORDER BY craplau.cdempres;
  rw_craplcm4 cr_craplcm4%ROWTYPE;
  -- Debito Automatico Sicredi (Tarifa)
  CURSOR cr_craplcm5 (pr_cdcooper IN craplcm.cdcooper%TYPE,
                      pr_dtmvtolt IN craplcm.dtmvtolt%TYPE,
                      pr_cdhistor IN craplcm.cdhistor%TYPE) IS
    SELECT crapass.cdagenci, craplau.cdempres, crapscn.dsnomcnv, COUNT(*) qtlanmto,
           SUM(craplcm.vllanmto) vllanmto
      FROM craplcm, craplau, crapscn, crapass
      WHERE craplcm.cdcooper = craplau.cdcooper
        AND craplcm.nrdconta = craplau.nrdconta
        AND craplcm.cdhistor = craplau.cdhistor
        AND craplau.cdempres = crapscn.cdempres
        AND craplcm.cdcooper = crapass.cdcooper
        AND craplcm.nrdconta = crapass.nrdconta
        AND craplcm.nrdocmto = craplau.nrdocmto
        AND craplcm.cdcooper = pr_cdcooper
        AND craplcm.dtmvtolt = pr_dtmvtolt
        AND craplcm.dtmvtolt = craplau.dtdebito
        AND craplcm.cdhistor = pr_cdhistor
        AND crapscn.dtencemp IS NULL
        AND crapscn.dsoparre = 'E'
      GROUP BY crapass.cdagenci,
               craplau.cdempres,
               crapscn.dsnomcnv
      ORDER BY craplau.cdempres,
               crapass.cdagenci;
  rw_craplcm5 cr_craplcm5%ROWTYPE;
  -- Despesa Sicredi (Debito Automatico)
  CURSOR cr_craplcm6 (pr_cdcooper IN craplcm.cdcooper%TYPE,
                      pr_dtmvtolt IN craplcm.dtmvtolt%TYPE,
                      pr_cdhistor IN craplcm.cdhistor%TYPE) IS
    SELECT crapass.cdagenci, COUNT(*) qtlanmto
      FROM craplcm, craplau, crapscn, crapass
      WHERE craplcm.cdcooper = craplau.cdcooper
        AND craplcm.nrdconta = craplau.nrdconta
        AND craplcm.cdhistor = craplau.cdhistor
        AND craplcm.nrdocmto = craplau.nrdocmto
        AND craplau.dtdebito = craplcm.dtmvtolt
        AND craplau.cdempres = UPPER(crapscn.cdempres)
        AND crapass.nrdconta = craplcm.nrdconta
        AND craplcm.nrdconta = crapass.nrdconta
        AND craplcm.cdcooper = crapass.cdcooper
        AND craplcm.cdcooper = pr_cdcooper
        AND craplcm.dtmvtolt = pr_dtmvtolt
        AND craplcm.cdhistor = pr_cdhistor
        AND crapscn.dtencemp IS NULL
        AND crapscn.dsoparre = 'E'
      GROUP BY crapass.cdagenci
      ORDER BY crapass.cdagenci;
  rw_craplcm6 cr_craplcm6%ROWTYPE;
  -- Tarifa Sicredi
  cursor cr_craprej3 (pr_cdcooper in craprej.cdcooper%type,
                      pr_cdprogra in craprej.cdpesqbb%type,
                      pr_dtmvtolt in craprej.dtmvtolt%type,
                      pr_nraplica IN NUMBER) IS
    select craprej.cdagenci,
           craprej.dtrefere,
           craprej.vllanmto,
           crapscn.cdempres,
           crapscn.dsnomcnv,
           craprej.nraplica,
           craprej.vlsdapli,
           craprej.cdhistor,
		   craprej.nrdocmto
      from crapscn,
           craprej
     where craprej.cdcooper = pr_cdcooper
       and craprej.cdpesqbb = pr_cdprogra
       and craprej.dtmvtolt = pr_dtmvtolt
       and crapscn.cdempres = craprej.dtrefere
       AND ((craprej.nraplica = pr_nraplica -- Buscar Total Geral (0-Geral/1-Total por PF/2-Total por PJ)
       AND  pr_nraplica = 0)
        OR (craprej.nraplica IN (1,2)
       AND   pr_nraplica > 0))
     order by nlssort(craprej.dtrefere, 'NLS_SORT=BINARY_AI'),
              craprej.nraplica,
              craprej.cdagenci;
  -- Tarifa para despesas Sicredi
  cursor cr_crapthi2 (pr_cdcooper in crapthi.cdcooper%type,
                      pr_cdhistor in crapthi.cdhistor%type) is
    select vltarifa
      from crapthi
     where crapthi.cdcooper = pr_cdcooper
       and crapthi.cdhistor = pr_cdhistor
       and crapthi.dsorigem = 'AYLLOS';
  rw_crapthi2     cr_crapthi2%rowtype;

  -- Buscar os históricos a serem processados
  CURSOR cr_histori(pr_cdcooper in crapcco.cdcooper%TYPE) IS
    SELECT crapfvl.cdhistor
          ,crapcco.nrdctabb
          ,crapcco.flgregis
          ,crapcco.dsorgarq
      FROM crapcco
          ,crapfco
          ,crapfvl
     WHERE crapcco.cdcooper = pr_cdcooper
       AND crapfco.cdcooper = crapcco.cdcooper
       AND crapfco.nrconven = crapcco.nrconven
       AND crapfco.flgvigen = 1 -- Fixo
       AND crapfvl.cdfaixav = crapfco.cdfaixav;
  -- Buscar contrato do BNDES
  CURSOR cr_crapebn(pr_cdcooper   crapebn.cdcooper%TYPE
                   ,pr_nrdconta   crapebn.nrdconta%TYPE
                   ,pr_nrctremp   crapebn.nrctremp%TYPE) IS
    SELECT 1
      FROM crapebn
     WHERE crapebn.cdcooper = pr_cdcooper
       AND crapebn.nrdconta = pr_nrdconta
       AND crapebn.nrctremp = pr_nrctremp;

  -- Títulos compensáveis
  CURSOR cr_craptit3 (pr_cdcooper IN craptit.cdcooper%TYPE,
                     pr_dtmvtolt IN craptit.dtmvtolt%TYPE) IS
    SELECT /*+ index (craptit craptit##craptit4)*/
           craptit.cdagenci,
           SUM(craptit.vldpagto) vldpagto,
           COUNT(*) qttottrf
      FROM craptit
     WHERE craptit.cdcooper = pr_cdcooper
       AND craptit.dtdpagto = pr_dtmvtolt
       AND craptit.insittit in (0,2,4)
       AND craptit.cdbandst <> 85
       AND craptit.tpdocmto = 20
       AND craptit.intitcop = 1  -- 0 = Outros Bancos; 1 = Cooperativa
     GROUP BY craptit.cdagenci
     ORDER BY craptit.cdagenci;

  -- TITULOS 085 PAGOS PELOS CAIXAS, INTERNET E CAIXA ONLINE COM FLOAT
  -- MOVIMENTA CONTA 4972
  CURSOR cr_craptit4 (pr_cdcooper IN craptit.cdcooper%TYPE,
                     pr_dtmvtolt IN craptit.dtmvtolt%TYPE) IS
    SELECT /*+ index (craptit craptit##craptit4)*/
           craptit.cdagenci,
           SUM(craptit.vldpagto) vldpagto,
           SUBSTR(craptit.dscodbar,20,6) nrconven,
           crapcco.dsorgarq,
           COUNT(*) qttottrf
      FROM craptit, crapcco
     WHERE craptit.cdcooper = pr_cdcooper
       AND craptit.dtdpagto = pr_dtmvtolt
       AND craptit.insittit in (0,2,4)
       AND craptit.cdbandst = 85
       AND craptit.tpdocmto = 20
       AND craptit.intitcop = 1  -- 0 = Outros Bancos; 1 = Cooperativa
       AND NOT EXISTS (SELECT 1 FROM craptdb
                        WHERE craptdb.cdcooper = craptit.cdcooper
                          AND craptdb.nrdconta = to_number(SUBSTR(craptit.dscodbar,26,8))
                          AND craptdb.nrcnvcob = to_number(SUBSTR(craptit.dscodbar,20,6))
                          AND craptdb.nrdocmto = to_number(SUBSTR(craptit.dscodbar,34,9))
                          AND craptdb.insittit = 2
                          AND craptdb.dtdpagto = pr_dtmvtolt)
       AND crapcco.cdcooper = craptit.cdcooper
       AND crapcco.nrconven = to_number(SUBSTR(craptit.dscodbar,20,6))
     GROUP BY craptit.cdagenci, SUBSTR(craptit.dscodbar,20,6), crapcco.dsorgarq
     ORDER BY craptit.cdagenci;

  -- TITULOS 085 PAGOS PELOS CAIXAS, INTERNET E CAIXA ONLINE - DESCONTADOS
  -- MOVIMENTA CONTA 4954
  CURSOR cr_craptit5 (pr_cdcooper IN craptit.cdcooper%TYPE,
                     pr_dtmvtolt IN craptit.dtmvtolt%TYPE) IS
    SELECT /*+ index (craptit craptit##craptit4)*/
           craptit.cdagenci,
           SUM(craptit.vldpagto) vldpagto,
           SUBSTR(craptit.dscodbar,20,6) nrconven,
           COUNT(*) qttottrf
      FROM craptit
     WHERE craptit.cdcooper = pr_cdcooper
       AND craptit.dtdpagto = pr_dtmvtolt
       AND craptit.insittit in (0,2,4)
       AND craptit.cdbandst = 85
       AND craptit.tpdocmto = 20
       AND craptit.intitcop = 1  -- 0 = Outros Bancos; 1 = Cooperativa
       AND EXISTS (SELECT 1 FROM craptdb
                    WHERE craptdb.cdcooper = craptit.cdcooper
                      AND craptdb.nrdconta = to_number(SUBSTR(craptit.dscodbar,26,8))
                      AND craptdb.nrcnvcob = to_number(SUBSTR(craptit.dscodbar,20,6))
                      AND craptdb.nrdocmto = to_number(SUBSTR(craptit.dscodbar,34,9))
                      AND craptdb.insittit = 2
                      AND craptdb.dtdpagto = pr_dtmvtolt)
     GROUP BY craptit.cdagenci, SUBSTR(craptit.dscodbar,20,6)
     ORDER BY craptit.cdagenci;

  -- Movimento dos títulos 085 pagos pela COMPE;
  CURSOR cr_crapret3 (pr_cdcooper in crapret.cdcooper%type,
                      pr_dtocorre in crapret.dtocorre%type) is
    SELECT ret.nrcnvcob,
           cco.dsorgarq,
           SUM(ret.vlrpagto) vlrpagto
      FROM crapcco cco, crapret ret, crapcop cop
     WHERE cco.cdcooper = pr_cdcooper
       AND cco.cddbanco = 85
       AND cop.cdcooper = pr_cdcooper
       AND ret.cdcooper = cco.cdcooper
       AND ret.nrcnvcob = cco.nrconven
       AND ret.dtocorre = pr_dtocorre
       AND ret.dtcredit IS NOT NULL
       AND ret.cdocorre in (6,17,76,77)
       AND ret.vlrpagto < 250000
       AND ((ret.cdbcorec = 85 AND ret.cdagerec <> cop.cdagectl) OR
            (ret.cdbcorec <> 85))
     GROUP BY ret.nrcnvcob, cco.dsorgarq;

  CURSOR cr_crapsld(pr_cdcooper IN crapcop.cdcooper%TYPE) IS

    SELECT
      LPAD(ass.cdagenci,3,'0') AS cdagenci
     ,SUM(sld.vljuresp)        AS vljuresp
    FROM
      crapsld sld JOIN crapass ass
        ON sld.cdcooper = ass.cdcooper
       AND sld.nrdconta = ass.nrdconta
    WHERE
      sld.cdcooper = pr_cdcooper
    GROUP BY
      ass.cdagenci
    ORDER BY
      ass.cdagenci;

  rw_crapsld cr_crapsld%ROWTYPE;

  CURSOR cr_crapsld_tot(pr_cdcooper IN crapcop.cdcooper%TYPE) IS

    SELECT
      NVL(SUM(sld.vljuresp),0) AS vljuresp
    FROM
      crapsld sld
    WHERE
      sld.cdcooper = pr_cdcooper;

  rw_crapsld_tot cr_crapsld_tot%ROWTYPE;
  
  CURSOR cr_crapsld_age(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT NVL(SUM(sld.vljuresp),0) AS vljuresp
          ,ass.cdagenci
          ,DECODE(ass.inpessoa,3,2,ass.inpessoa) inpessoa
      FROM crapsld sld
          ,crapass ass
     WHERE sld.cdcooper = ass.cdcooper
       AND sld.nrdconta = ass.nrdconta
       AND sld.cdcooper = pr_cdcooper
     GROUP BY ass.cdagenci
             ,DECODE(ass.inpessoa,3,2,ass.inpessoa)
     ORDER BY ass.cdagenci
             ,DECODE(ass.inpessoa,3,2,ass.inpessoa);

  -- cursor de consulta de produtos que possuem aplicacoes
  CURSOR cr_crapcpc IS
    SELECT crapcpc.cdprodut 
          ,crapcpc.nmprodut
          ,crapcpc.cdhsnrap
      FROM crapcpc;
  
  -- cursor de consulta de aplicacoes
  CURSOR cr_craprac(pr_cdcooper crapcop.cdcooper%TYPE
                   ,pr_cdprodut crapcpc.cdprodut%TYPE) IS
    SELECT craprac.vlslfmes, 
           craprac.nrdconta, 
           craprac.nraplica,
           craprac.idsaqtot
      FROM crapcpc, craprac 
     WHERE craprac.cdprodut = crapcpc.cdprodut
       AND craprac.cdcooper = pr_cdcooper 
       AND craprac.cdprodut = pr_cdprodut
       AND craprac.idcalorc = 0;
       
  CURSOR cr_crapepr (pr_cdcooper crapcop.cdcooper%TYPE
                    ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
    SELECT epr.nrdconta
          ,epr.nrctremp
          ,lem.vllanmto
          ,epr.cdlcremp
          ,lcr.cdhistor
          ,decode(epr.tpemprst,0,'TR','PP') tpprodut
          ,his.dshistor
      FROM crapepr epr
          ,craplem lem
          ,craplcr lcr
          ,craphis his
					,crapfin fin
     WHERE epr.cdcooper = lem.cdcooper
       AND epr.nrdconta = lem.nrdconta
       AND epr.nrctremp = lem.nrctremp
       AND epr.cdcooper = lcr.cdcooper
       AND epr.cdlcremp = lcr.cdlcremp
			 AND fin.cdcooper = epr.cdcooper
 			 AND fin.cdfinemp = epr.cdfinemp
       AND lem.cdcooper = pr_cdcooper
       AND ','|| GENE0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdcooper => pr_cdcooper, pr_cdacesso => 'HISTOR_SEM_CRED_CC') ||',' LIKE ('%,' || lem.cdhistor || ',%') --> Produtos atuais
       AND lcr.cdlcremp != 100      --> LInha 100 eh tratava separadamente
       AND lem.dtmvtolt = pr_dtmvtolt
       AND (lcr.flgcrcta = 0
			  OR (lcr.flgcrcta = 1 AND fin.tpfinali = 2)) --> Operações de portabilidade
       AND his.cdcooper = epr.cdcooper
       AND his.cdhistor = lcr.cdhistor
     ORDER BY epr.nrdconta,epr.nrctremp;

  CURSOR cr_craplcm_tot(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_cdhistor IN craplcm.cdhistor%TYPE
                       ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE) IS

    SELECT NVL(SUM(lcm.vllanmto),0) AS vllanmto
      FROM craplcm lcm
     WHERE lcm.cdcooper = pr_cdcooper
       AND lcm.dtmvtolt = pr_dtmvtolt
       AND lcm.cdhistor = pr_cdhistor;
  rw_craplcm_tot cr_craplcm_tot%ROWTYPE;
  
  CURSOR cr_craplcm8(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_cdhistor IN craplcm.cdhistor%TYPE
                   ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE) IS

    SELECT LPAD(ass.cdagenci,3,'0') AS cdagenci
          ,SUM(lcm.vllanmto)        AS vllanmto
      FROM craplcm lcm JOIN crapass ass
        ON lcm.cdcooper = ass.cdcooper
       AND lcm.nrdconta = ass.nrdconta
       AND lcm.cdhistor = pr_cdhistor
       AND lcm.dtmvtolt = pr_dtmvtolt
    WHERE lcm.cdcooper = pr_cdcooper
    GROUP BY ass.cdagenci
    ORDER BY ass.cdagenci;
  rw_craplcm8 cr_craplcm8%ROWTYPE;
  
  
  cursor cr_craprej4(pr_cdcooper in craptab.cdcooper%type,
                     pr_cdprogra in crapprg.cdprogra%type,
                     pr_dtmvtolt in crapdat.dtmvtolt%type,
                     pr_nraplica IN NUMBER) IS
    select craprej.cdagenci,
           case when craprej.cdhistor = 2094 then
                  2093
                when craprej.cdhistor = 2091 then
                  2090
                when craprej.cdhistor = 1544 then
                  1072
                when craprej.cdhistor = 1542 then
                  1070
                when craprej.cdhistor in (1510,1719) then
                  1710
                else
                  craprej.cdhistor
           end cdhistor,
           craprej.nraplica,
           craprej.dshistor,           
           sum(craprej.vlsdapli) vlsdapli
      from craprej
     where craprej.cdcooper = pr_cdcooper
       and craprej.cdpesqbb = pr_cdprogra
       and craprej.dtmvtolt = pr_dtmvtolt
       AND ((craprej.nraplica = pr_nraplica -- Buscar Total Geral (0-Geral/1-Total por PF/2-Total por PJ)
       AND  pr_nraplica = 0)
        OR (craprej.nraplica IN (1,2)
       AND   pr_nraplica > 0))
       AND trim(craprej.dshistor) is not null
     group by craprej.cdagenci,
           case when craprej.cdhistor = 2094 then
                  2093
                when craprej.cdhistor = 2091 then
                  2090
                when craprej.cdhistor = 1544 then
                  1072
                when craprej.cdhistor = 1542 then
                  1070
                when craprej.cdhistor in (1510,1719) then
                  1710
                else
                  craprej.cdhistor
           end,
           craprej.nraplica,
           craprej.dshistor
     HAVING SUM(craprej.vlsdapli)>0
     order by case when craprej.cdhistor = 2094 then
                  2093
                when craprej.cdhistor = 2091 then
                  2090
                when craprej.cdhistor = 1544 then
                  1072
                when craprej.cdhistor = 1542 then
                  1070
                when craprej.cdhistor in (1510,1719) then
                  1710
                else
                  craprej.cdhistor
              end,
              craprej.dshistor,
              craprej.nraplica,
              craprej.cdagenci;
  
  
  CURSOR cr_craplcm_age(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_cdhistor IN craplcm.cdhistor%TYPE
                       ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE) IS
      SELECT NVL(SUM(lcm.vllanmto),0) AS vllanmto
          ,ass.cdagenci
          ,DECODE(ass.inpessoa,3,2,ass.inpessoa) inpessoa
      FROM craplcm lcm
          ,crapass ass
     WHERE lcm.cdcooper = ass.cdcooper
       AND lcm.nrdconta = ass.nrdconta
       AND lcm.cdcooper = pr_cdcooper
       AND lcm.dtmvtolt = pr_dtmvtolt
       AND lcm.cdhistor = pr_cdhistor
     GROUP BY ass.cdagenci
             ,DECODE(ass.inpessoa,3,2,ass.inpessoa)
     ORDER BY ass.cdagenci
             ,DECODE(ass.inpessoa,3,2,ass.inpessoa);

  cursor cr_crapret4(pr_cdcooper in crapret.cdcooper%type
                    ,pr_dtmvtolt in crapret.dtaltera%type) is
    select decode(crapass.inpessoa,1,1,2) inpessoa,  -- 1 pessoa fisica, 2 pessoa juridica
           crapass.cdagenci,
           sum(nvl(crapret.vltarcus, 0)) + sum(nvl(crapret.vloutdes, 0)) vldespes
      from crapass,
           crapret,
           crapcco
     where crapcco.cdcooper = pr_cdcooper
       and crapret.dtocorre = pr_dtmvtolt     
       AND crapcco.cddbanco = 1
       AND crapcco.flgregis = 1
       AND crapcco.dsorgarq NOT IN ('MIGRACAO','INCORPORACAO')
       AND crapret.cdcooper = crapcco.cdcooper
       AND crapret.nrcnvcob = crapcco.nrconven
       and cdhistbb in (936, 937, 938, 939, 940, 965, 966, 973)
       and crapass.cdcooper = crapret.cdcooper
       and crapass.nrdconta = crapret.nrdconta
     group by decode(crapass.inpessoa,1,1,2),
              crapass.cdagenci
     order by decode(crapass.inpessoa,1,1,2),
              crapass.cdagenci;
              

  cursor cr_crapafi4(pr_cdcooper in crapafi.cdcooper%type
                    ,pr_dtmvtolt in crapafi.dtmvtolt%type
                    ,pr_cdhistor in crapafi.cdhistor%type
                    ,pr_nrdctabb in crapafi.nrdctabb%type) is      
    select decode(crapass.inpessoa,1,1,2) inpessoa,
           crapass.cdagenci,
           sum(crapafi.vllanmto) vllanmto     
      from crapafi,
           crapass
     where crapafi.cdcooper = pr_cdcooper
       and crapafi.dtlanmto = pr_dtmvtolt
       and crapafi.cdhistor = pr_cdhistor
       and crapafi.nrdctabb = pr_nrdctabb
       and crapass.cdcooper = crapafi.cdcooper
       and crapass.nrdconta = crapafi.nrctadst
    group by decode(crapass.inpessoa,1,1,2),
             crapass.cdagenci
    order by decode(crapass.inpessoa,1,1,2),
             crapass.cdagenci;
 
  --          
  cursor cr_craplcm9(pr_cdcooper in craplcm.cdcooper%type,
                     pr_dtmvtolt in craplcm.dtmvtolt%type,
                     pr_cdhistor in craplcm.cdhistor%type) is
    select crapass.cdagenci,
           decode(crapass.inpessoa,1,1,2) inpessoa,
           sum(to_number(nvl(trim(craplcm.dsidenti),0))) nrseqdig 
      from crapass,
           craplcm
     where craplcm.cdcooper = pr_cdcooper
       and craplcm.dtmvtolt = pr_dtmvtolt
       and craplcm.cdhistor = pr_cdhistor
       and crapass.cdcooper = craplcm.cdcooper
       and crapass.nrdconta = craplcm.nrdconta
    group by crapass.cdagenci,
             crapass.inpessoa
    order by crapass.inpessoa,
             crapass.cdagenci;
                          
             
             
  -- PL/Table contendo informações por agencia e segregadas em PF e PJ
  TYPE typ_pf_pj_op_cred IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
       
  -- PL/Table contendo informações por agencia e segregadas em PF e PJ
  TYPE typ_age_ope_cred is table of typ_pf_pj_op_cred INDEX BY PLS_INTEGER;
  
  -- PL/Table principal para gravar dados em AAMMDD_OP_CREDI.txt
  TYPE typ_arq_op_cred is table of typ_age_ope_cred INDEX BY PLS_INTEGER;
  
  -- Registro totais dos históricos para o relatório
  TYPE reg_tot_his_rel is record (cdhistor NUMBER(5)
                                 ,dshistor VARCHAR2(100)
                                 ,vllanmto NUMBER(25,2));
  
  -- PL/Table contendo informações totais dos históricos para o relatório
  TYPE typ_tot_his_rel is TABLE OF reg_tot_his_rel INDEX BY PLS_INTEGER;
  
  tb_tot_his_rel typ_tot_his_rel;
  
  -- Variaveis referencia de PL-Table
  vr_arq_op_cred   typ_arq_op_cred;
       
  -- PL/Table contendo informações das agências
  type typ_agencia is record (vr_qttottrf      number(10),
                              vr_qttarcmp      number(10),
                              vr_vlaprjur      crapljd.vldjuros%type,
                              vr_aprjursr      crapljt.vldjuros%type,
                              vr_aprjurcr      crapljt.vldjuros%type,
                              vr_vltarbcb      number(12,4),
                              vr_vltottar      crapthi.vltarifa%type,
                              vr_qttarpac      number(10),
                              vr_vltarpac      crapret.vloutdes%type,
                              vr_qttdbtot      number(10),
                              vr_vltagenc      craplcs.vllanmto%type,
                              vr_qttarpac_001  number(10),
                              vr_qttarpac_085  number(10));
  type typ_agencia2 is record (vr_cdccuage      crapage.cdccuage%type,
                               vr_cdcxaage      crapage.cdcxaage%type);

  type tyb_hist_cob is record (cdhistor number(10),
                               nrdctabb number(10),
                               flgregis number(1));

  TYPE typ_reg_limchq IS
    RECORD(cdagenci crapris.cdagenci%TYPE
          ,valor NUMBER(25,2));

  TYPE typ_tab_limchq IS
    TABLE OF typ_reg_limchq
      INDEX BY PLS_INTEGER;    

  vr_tab_limcon           typ_tab_limchq;

  -- Definição da tabela para armazenar os registros das agências
  type typ_tab_agencia is table of typ_agencia index by binary_integer;
  type typ_tab_agencia2 is table of typ_agencia2 index by binary_integer;
  type typ_tab_hist_cob is table of tyb_hist_cob index by varchar2(30);
  -- Instância da tabela. O índice será o código da agência.
  vr_tab_agencia         typ_tab_agencia;
  vr_tab_agencia2        typ_tab_agencia2;
  -- Instancia da tabela. o indice sera o historico e nr. da conta bb
  vr_tab_hist_cob        typ_tab_hist_cob;
  -- Variavel para leitura das pl/tables
  vr_indice_agencia      number(3);
  -- PL/Table que substitui a temp-table cratorc
  type typ_cratorc is record (vr_cdagenci  crapass.cdagenci%type,
                              vr_vllanmto  crapsdc.vllanmto%type);
  -- Definição da tabela
  type typ_tab_cratorc is table of typ_cratorc index by binary_integer;
  -- Instância da tabela. O índice é o código da agência.
  vr_tab_cratorc         typ_tab_cratorc;
  -- PL/Table que substitui a temp-table tt-faturas
  type typ_faturas is record (vr_tpfatura  number(1),
                              vr_cdagenci  number(3),
                              vr_qtlanmto  number(10));
  -- Definição da tabela
  type typ_tab_faturas is table of typ_faturas index by varchar2(4);
  -- Instância da tabela. O índice é o código da agência + tipo da fatura.
  vr_tab_faturas         typ_tab_faturas;

  
  
  -- Registro para inicializar dados por histórico
  TYPE typ_reg_historico
    IS RECORD (nrctaori_fis NUMBER          --> Conta Origem  PF
              ,nrctades_fis NUMBER          --> Conta Destino PJ
              ,dsrefere_fis VARCHAR2(500)   --> Descricao Historico
              ,nrctaori_jur NUMBER          --> Conta Origem  PF
              ,nrctades_jur NUMBER          --> Conta Destino PJ
              ,dsrefere_jur VARCHAR2(500)); --> Descricao Historico

  -- Pl-Table principal que indexa os registro historico
  TYPE typ_tab_historico
    IS TABLE OF typ_reg_historico
    INDEX BY BINARY_INTEGER;

  vr_tab_historico  typ_tab_historico;  
  
  -- Registro para inicializar dados de operações microcrédito por histórico
  TYPE typ_reg_historico_mic
    IS RECORD (nrctaori_fis NUMBER          --> Conta Origem  PF
              ,nrctades_fis NUMBER          --> Conta Destino PJ
              ,dsrefere_fis VARCHAR2(500)   --> Descricao Historico
              ,nrctaori_jur NUMBER          --> Conta Origem  PF
              ,nrctades_jur NUMBER          --> Conta Destino PJ
              ,dsrefere_jur VARCHAR2(500)); --> Descricao Historico

  -- Pl-Table principal que indexa os registro historico
  TYPE typ_tab_historico_mic
    IS TABLE OF typ_reg_historico_mic
    INDEX BY BINARY_INTEGER;

  vr_tab_historico_mic  typ_tab_historico_mic;   
  
  -- Pl-Table de acumulo valores por agência
  TYPE typ_tab_valores_ag
    IS TABLE OF VARCHAR2(32767)
    INDEX BY BINARY_INTEGER; 

  -- Variavel Pl-Table
  vr_tab_valores_ag typ_tab_valores_ag;
  
  -- Pl-Table de acumulo valores de despesa de cobrança por agência  e pessoa fisica
  TYPE typ_tab_vlr_age_fis IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  vr_tab_vlr_age_fis typ_tab_vlr_age_fis; 

  -- Pl-Table de acumulo valores de despesa de cobrança por agência  e pessoa juridica  
  TYPE typ_tab_vlr_age_jur IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  vr_tab_vlr_age_jur typ_tab_vlr_age_jur;     

  -- Pl-Table de acumulo valores de despesa de cobrança por tipo de pessoa
  TYPE typ_tab_vlr_descbr_pes IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  vr_tab_vlr_descbr_pes typ_tab_vlr_descbr_pes;
  
  
  -- Registro para inicializar dados por operadora de celular
  TYPE typ_reg_recarga_cel_ope
    IS RECORD (nmoperadora tbrecarga_operadora.nmoperadora%type,
               vlreceita   tbrecarga_operacao.vlrecarga%type);
               
  TYPE typ_tab_recarga_cel_ope IS TABLE OF typ_reg_recarga_cel_ope INDEX BY PLS_INTEGER;
  vr_tab_recarga_cel_ope typ_tab_recarga_cel_ope;
  
  TYPE typ_tab_receita_cel_pf IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  TYPE typ_tab_receita_cel_pj IS TABLE OF NUMBER INDEX BY PLS_INTEGER;  
  
  vr_tab_receita_cel_pf typ_tab_receita_cel_pf;
  vr_tab_receita_cel_pj typ_tab_receita_cel_pj;  
  

  -- Índice para a pl/table
  vr_indice_faturas      varchar2(4);
  vr_indice_hist_cob     varchar2(30);
  
  -- Código do programa
  vr_cdprogra            crapprg.cdprogra%type;
  -- Controle de critica
  vr_cdcritic            crapcri.cdcritic%type;
  vr_dscritic            VARCHAR2(4000);
  -- Data do movimento
  vr_dtmvtolt            crapdat.dtmvtolt%type;
  vr_dtmvtopr            crapdat.dtmvtopr%type;
  vr_dtmvtoan            crapdat.dtmvtoan%type;
  vr_dtultdia            crapdat.dtultdia%type;
  vr_dtultdma            crapdat.dtultdma%type;
  -- Variáveis para armazenar a lista de contas convênio
  vr_lscontas            varchar2(4000);
  vr_lsconta4            varchar2(4000);
  -- Variável auxiliar para o número da conta BB
  vr_rel_nrdctabb        number(10);
  -- Variável auxiliar para o número da conta Sicredi
  vr_nrctasic            number(4);
  -- Tratamento de erros
  vr_exc_fimprg          EXCEPTION;
  vr_exc_saida           EXCEPTION;
  vr_typ_said            VARCHAR2(4);
  -- Data do movimento no formato yymmdd
  vr_dtmvtolt_yymmdd     varchar2(6);
  -- Nome do diretório
  vr_nom_diretorio       varchar2(200);
  vr_dsdircop            varchar2(200);
  -- Nome do arquivo que será gerado

  vr_nmarqnov            VARCHAR2(50); -- nome do arquivo por cooperativa
  vr_nmarqdat            varchar2(50);
  vr_nmarqdat_ope_cred   varchar2(50);
  vr_nmarqdat_ope_cred_nov   varchar2(50); --nome arquivo ope_cred por cooperativa
  
  -- Arquivo texto
  vr_arquivo_txt         utl_file.file_type;

  -- Variáveis para processamento do cursor cr_craprda
  vr_cdagenci_index      NUMBER;
  -- Variáveis para processamento do cursor cr_craprej
  vr_nrctacrd            craphis.nrctacrd%type;
  vr_nrctadeb            craphis.nrctadeb%type;
  vr_cdestrut            varchar2(2);
  vr_nrdctabb            craptab.dstextab%type;
  -- Variáveis que controlam as quebras do arquivo
  vr_cdhistor            craphis.cdhistor%type;
  vr_dtrefere            craprej.dtrefere%type;
  vr_vldtotal            craprej.vllanmto%type;
  -- Variáveis para processamento do cursor cr_craprej2
  vr_nrctatrd            varchar2(5);
  vr_nrctatrc            varchar2(5);
  vr_vltarifa            crapthi.vltarifa%type;
  -- Variável para processamento do cursor craptit
  vr_vltitulo            craptit.vldpagto%type;
  -- Variáveis para processamento de cheques e títulos
  vr_vlcapsub            crapsdc.vllanmto%type;
  vr_vlcstcop            crapcst.vlcheque%type;
  vr_vlcstout            crapcst.vlcheque%type;
  vr_vlcdbcop            crapcst.vlcheque%type;
  vr_vlcdbban            crapcst.vlcheque%type;
  vr_vlcdbtot            crapcdb.vlcheque%type;
  vr_vlcdbjur            crapcdb.vlcheque%type;
  vr_qtcdbban            number(10);
  vr_vltdbtot            craptdb.vltitulo%type;
  vr_vltdbjur            craptdb.vltitulo%type;
  vr_tdbtotsr            craptdb.vltitulo%type;
  vr_tdbjursr            craptdb.vltitulo%type;
  vr_tdbtotcr            craptdb.vltitulo%type;
  vr_tdbjurcr            craptdb.vltitulo%type;
  vr_tdbtotcr_001        craptdb.vltitulo%type;
  vr_tdbtotcr_085        craptdb.vltitulo%type;
  vr_tdbjurcr_001        craptdb.vltitulo%type;
  vr_tdbjurcr_085        craptdb.vltitulo%type;
  vr_qtdtdbcr_001        number(10);
  vr_qtdtdbcr_085        number(10);
  vr_qtdtdbsr            number(10);
  vr_qttdbtot            number(10);
  -- Variáveis para uso na leitura e processamento dos cursores cr_crapafi e cr_crapafi2
  vr_vlafideb            number(20,2);
  -- Variável para controlar a quebra do cursor cr_crapret
  vr_cdhistbb            crapret.cdhistbb%type;
  vr_vltarpac            crapret.vloutdes%type;
  -- Variável para processamento de saques e estornos
  vr_vllanmto            craplcm.vllanmto%type;
  -- Variáveis globais utilizadas pelos procedimentos internos
  vr_flgctpas            boolean; -- PASSIVO
  vr_flgctred            boolean; -- REDUTORA
  vr_flgrvorc            boolean; -- REVERSAO
  vr_vltotorc            crapsdc.vllanmto%type;
  vr_vlstotal            crapsdc.vllanmto%type;
  vr_dshstorc            varchar2(100);
  vr_dshcporc            varchar2(100);
  vr_lsctaorc            varchar2(100);
  vr_vlcompel            crapcot.vlcotant%type;
  vr_tipocob             varchar2(100);
  -- Variável para geração do arquivo texto
  vr_linhadet            varchar2(200);
  vr_complinhadet        varchar2(50);
  --
  vr_vlpioneiro          number(10,2);
  vr_vlcartao            number(10,2);
  vr_vlrecibo            number(10,2);
  vr_vloutros            number(10,2);
  vr_flgpione            boolean;
  -- Convênio Sicredi
  vr_tpdarrec            varchar2(1);
  vr_vllanmto_fat        craplft.vllanmto%type;
  vr_qtlanmto_fat        number(10);
  vr_idtributo_6106      number(1);
  -- Auxiliar
  vr_incrapebn           NUMBER;
  
  -- Variaveis para relatorio
  vr_relatorio_epr       CLOB;
  vr_texto_relatorio     VARCHAR2(32767);
  vr_nom_direto          VARCHAR2(100);
  vr_nom_arquivo         VARCHAR2(100);
  vr_chave               PLS_INTEGER;
  
  -- Variavel recarga de celular
  vr_index               NUMBER;
  
  vr_nrctacre            rw_craphis.nrctacrd%TYPE;
  vr_cdagenci            NUMBER;
  vr_receita_cel_pf      NUMBER := 0;
  vr_receita_cel_pj      NUMBER := 0;
  
  --Váriaveis arquivo prejuizo
  vr_nmarqdat_prejuizo      VARCHAR2(100);
  vr_nmarqdat_prejuizo_nov  VARCHAR2(100);
  
  --Váriaveis arquivo tarifas cobranca bb  
  vr_nmarqdat_tarifasbb     VARCHAR2(100);
  vr_nmarqdat_tarifasbb_nov VARCHAR2(100);
  vr_contador               NUMBER := 0;
  --
  function fn_calcula_data (pr_cdcooper in craptab.cdcooper%type,
                            pr_dtmvtoan in date) return date is
    --
    -- No caso de feriado ou fim de semana, a data de vencimento é postergada
    -- para o proximo dia útil. Por isso, quando um título vence numa destas
    -- situações, ele não pode ser debitado automaticamente do cedente, como
    -- o exemplo abaixo:
    --
    -- Vencimento do título: 01/01/09 (feriado)
    --
    -- No dia 02/01/09, o titulo está vencido, mas ainda pode ser pago
    -- sem encargos, então ele somente pode ser debitado do cedente no
    -- processo do dia 03/01/09
    --
    vr_dtrefere    date;
  begin
    vr_dtrefere := gene0005.fn_valida_dia_util(pr_cdcooper,
                                               pr_dtmvtoan - 1,
                                               'A');
    -- Se teve fim de semana ou feriado antes de ontem
    if pr_dtmvtoan - vr_dtrefere > 1 then
      return vr_dtrefere;
    else
      return pr_dtmvtoan;
    end if;
  end;
  -- *********************************
  -- Função calc_dia_util_ao_ant => utilizar apli0001.fn_valida_dia_util, e
  -- passar no segundo parâmetro o valor de "vr_dtmvtoan - 1", e no terceiro
  -- parâmetro o valor "A", para indicar que quer buscar o dia útil anterior.
  -- *********************************
  --
  -- Função para verificar a última CONTACONVE cadastrada
  function fn_ultctaconve (pr_dstextab in varchar2) return varchar2 is
    vr_dstextab    varchar2(4000) := pr_dstextab;
  BEGIN
    if instr(pr_dstextab, ',', -1) = length(trim(pr_dstextab))   then
      vr_dstextab := substr(pr_dstextab, 1, length(trim(pr_dstextab)) - 1);
      vr_dstextab := substr(vr_dstextab, instr(vr_dstextab, ',', -1) + 1, 10);
    elsif instr(pr_dstextab, ',', -1) > 0 then
      vr_dstextab := substr(pr_dstextab, instr(pr_dstextab, ',', -1) + 1, 10);
    end if;
    return vr_dstextab;
  end;
  
  -- Grava no arquivo as informacoes por agencia
  PROCEDURE pc_set_linha(pr_cdarquiv IN NUMBER
                        ,pr_inpessoa IN NUMBER
                        ,pr_inputfile IN OUT NOCOPY UTL_FILE.file_type) IS       
  BEGIN
    -- Inclusão do módulo e ação logado - Chamado 734422 - 03/11/2017
    GENE0001.pc_set_modulo(pr_module => 'PC_CRPS249.pc_set_linha', pr_action => NULL);
    -- Gravas as informacoes de valores por agencia
    FOR vr_idx_agencia IN vr_arq_op_cred(pr_cdarquiv).FIRST..vr_arq_op_cred(pr_cdarquiv).LAST LOOP

       -- Verifica se existe a informacao de agencia
       IF vr_arq_op_cred(pr_cdarquiv).EXISTS(vr_idx_agencia) THEN
                    
          -- Nao considerar o registro 999 na linha
          IF vr_idx_agencia = 999 THEN
             CONTINUE;
          END IF;
               
          -- Verifica se existe a informacao de tipo de pessoa
          IF vr_arq_op_cred(pr_cdarquiv)(vr_idx_agencia).EXISTS(pr_inpessoa) THEN
             IF vr_arq_op_cred(pr_cdarquiv)(vr_idx_agencia)(pr_inpessoa) > 0 THEN
                -- Montar linha para gravar no arquivo
                gene0001.pc_escr_linha_arquivo(pr_utlfileh => pr_inputfile --> Handle do arquivo aberto
                                              ,pr_des_text => LPAD(vr_idx_agencia,3,0)||','
                                                     ||TRIM(TO_CHAR(vr_arq_op_cred(pr_cdarquiv)(vr_idx_agencia)(pr_inpessoa), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))); --> Texto para escrita
             END IF;
          END IF;
       END IF;
    END LOOP;       
  END;
         
  -- Retorna o cabecalho do arquivo AAMMDD_OPCRED.txt
  FUNCTION fn_set_cabecalho(pr_inlinha IN VARCHAR2
                           ,pr_dtarqmv IN DATE
                           ,pr_dtarqui IN DATE
                           ,pr_origem  IN NUMBER      --> Conta Origem
                           ,pr_destino IN NUMBER      --> Conta Destino
                           ,pr_vltotal IN NUMBER      --> Soma total de todas as agencias
                           ,pr_dsconta IN VARCHAR2)   --> Descricao da conta
                           RETURN VARCHAR2 IS
  BEGIN
    RETURN pr_inlinha --> Identificacao inicial da linha
        ||TO_CHAR(pr_dtarqmv,'YYMMDD')||',' --> Data AAMMDD do Arquivo
        ||TO_CHAR(pr_dtarqui,'DDMMYY')||',' --> Data DDMMAA
        ||pr_origem||','                    --> Conta Origem
        ||pr_destino||','                   --> Conta Destino
        ||TRIM(TO_CHAR(pr_vltotal,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','
        ||'5210'||','
        ||pr_dsconta;
  END;
       
  --
  -- Procedimento para inicialização da PL/Table de agência ao criar novo
  -- registro, garantindo que os campos terão valor zero, e não nulo.
  PROCEDURE pc_cria_agencia_pltable (pr_agencia   IN crapage.cdagenci%TYPE
                                    ,pr_cdarquiv  IN PLS_INTEGER) IS
  BEGIN
    -- Inclusão do módulo e ação logado - Chamado 734422 - 03/11/2017
    GENE0001.pc_set_modulo(pr_module => 'PC_CRPS249.pc_cria_agencia_pltable', pr_action => NULL);
    -- Se não há o registro da agencia na tabela de memória
    if not vr_tab_agencia.exists(pr_agencia) then
      vr_tab_agencia(pr_agencia).vr_qttottrf := 0;
      vr_tab_agencia(pr_agencia).vr_qttarcmp := 0;
      vr_tab_agencia(pr_agencia).vr_vlaprjur := 0;
      vr_tab_agencia(pr_agencia).vr_aprjursr := 0;
      vr_tab_agencia(pr_agencia).vr_aprjurcr := 0;
      vr_tab_agencia(pr_agencia).vr_vltarbcb := 0;
      vr_tab_agencia(pr_agencia).vr_vltottar := 0;
      vr_tab_agencia(pr_agencia).vr_qttarpac := 0;
      vr_tab_agencia(pr_agencia).vr_vltarpac := 0;
      vr_tab_agencia(pr_agencia).vr_qttdbtot := 0;
      vr_tab_agencia(pr_agencia).vr_vltagenc := 0;
      vr_tab_agencia(pr_agencia).vr_qttarpac_001 := 0;
      vr_tab_agencia(pr_agencia).vr_qttarpac_085 := 0;
    end if;
    -- Se não foi incluído na tabela de memória
    if not vr_tab_agencia2.exists(pr_agencia) then
      vr_tab_agencia2(pr_agencia).vr_cdccuage := 0;
      vr_tab_agencia2(pr_agencia).vr_cdcxaage := 0;
    end if;
    
    -- Se não foi passado o ID do arquivo
    IF pr_cdarquiv IS NOT NULL THEN
       -- Verifica se existe o codigo do arquivo
       IF NOT vr_arq_op_cred.EXISTS(pr_cdarquiv) THEN
          vr_arq_op_cred(pr_cdarquiv)(pr_agencia)(1) := 0; -- Pessoa Fisica
          vr_arq_op_cred(pr_cdarquiv)(pr_agencia)(2) := 0; -- Pessoa Juridica
       END IF;

       -- Inicializa informacoes da agencia - Dados para contabilidade
       IF NOT vr_arq_op_cred(pr_cdarquiv).EXISTS(pr_agencia) THEN
          vr_arq_op_cred(pr_cdarquiv)(pr_agencia)(1) := 0; -- Pessoa Fisica
          vr_arq_op_cred(pr_cdarquiv)(pr_agencia)(2) := 0; -- Pessoa Juridica
       END IF;
    END IF;
  end;

  -- Insere dados de operações contábeis
  procedure pc_grava_crapopc (pr_cdcooper in crapopc.cdcooper%type,
                              pr_dtrefere in crapopc.dtrefere%type,
                              pr_nrdconta in crapopc.nrdconta%type,
                              pr_tpregist in crapopc.tpregist%type,
                              pr_nrborder in crapopc.nrborder%type,
                              pr_cdagenci in crapopc.cdagenci%type,
                              pr_nrdocmto in crapopc.nrdocmto%type,
                              pr_vldocmto in crapopc.vldocmto%type,
                              pr_cdtipope in crapopc.cdtipope%type,
                              pr_cdprogra in crapopc.cdprogra%type) IS
  BEGIN
    -- Inclusão do módulo e ação logado - Chamado 734422 - 03/11/2017
    GENE0001.pc_set_modulo(pr_module => 'PC_CRPS249.pc_grava_crapopc', pr_action => NULL);

    -- Gravar Dados de Operacoes Contabeis
    INSERT INTO crapopc(cdcooper,
                        dtrefere,
                        nrdconta,
                        tpregist,
                        nrborder,
                        cdagenci,
                        nrdocmto,
                        vldocmto,
                        cdtipope,
                        cdprogra)
                values (pr_cdcooper,
                        pr_dtrefere,
                        pr_nrdconta,
                        pr_tpregist,
                        pr_nrborder,
                        pr_cdagenci,
                        pr_nrdocmto,
                        pr_vldocmto,
                        pr_cdtipope,
                        Lower(pr_cdprogra));
  EXCEPTION
    WHEN OTHERS THEN
      --Inclusão na tabela de erros Oracle - Chamado 734422
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);                                                             
      vr_cdcritic := 1034;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' crapopc para o cheque:'||pr_nrdocmto||
                     '. cdcooper:'||pr_cdcooper||', dtrefere:'||pr_dtrefere||
                     ', dconta:'||pr_nrdconta||', tpregist:'||pr_tpregist||
                     ', borderô:'||pr_nrborder||', agência:'||pr_cdagenci||
                     ', vldocmto:'||pr_vldocmto||', cdtipope:'||pr_cdtipope||
                     ', cdprogra:'||Lower(pr_cdprogra)||'. '||sqlerrm;
      RAISE vr_exc_saida;
  END;

	--Melhorias performance - Chamado 734422
  --Insere dados de operações contábeis
  procedure pc_grava_crapopc_bulk (pr_cdcooper in crapopc.cdcooper%type,
                              pr_dtrefere in crapopc.dtrefere%type,
                              rw_crapcdb  in tab_crapcdb_rec,
                              pr_tpregist in crapopc.tpregist%type,
                              pr_cdtipope in crapopc.cdtipope%type,
                              pr_cdprogra in crapopc.cdprogra%type) IS
  BEGIN
    -- Inclusão do módulo e ação logado - Chamado 734422 - 03/11/2017
    GENE0001.pc_set_modulo(pr_module => 'PC_CRPS249.pc_grava_crapopc_bulk', pr_action => NULL);

    forall i in 1 .. rw_crapcdb.count

    -- Gravar Dados de Operacoes Contabeis
    INSERT INTO crapopc(cdcooper,
                        dtrefere,
                        nrdconta,
                        tpregist,
                        nrborder,
                        cdagenci,
                        nrdocmto,
                        vldocmto,
                        cdtipope,
                        cdprogra)
                values (pr_cdcooper,
                        pr_dtrefere,
                        rw_crapcdb(i).nrdconta,
                        pr_tpregist,
                        rw_crapcdb(i).nrborder,
                        rw_crapcdb(i).cdagenci,
                        rw_crapcdb(i).nrcheque,
                        rw_crapcdb(i).vlcheque,
                        pr_cdtipope,
                        Lower(pr_cdprogra));
  EXCEPTION
    WHEN OTHERS THEN
      --Inclusão na tabela de erros Oracle - Chamado 734422
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);                                                             
      vr_cdcritic := 1034;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' crapopc '||'para o cheque:'||rw_crapcdb(rw_crapcdb.count).nrcheque||
                     ' cdcooper:'||pr_cdcooper||', dtrefere:'||pr_dtrefere||
                     ', nrdconta:'||rw_crapcdb(rw_crapcdb.count).nrdconta||', tpregist:'||pr_tpregist||
                     ', borderô:'||rw_crapcdb(rw_crapcdb.count).nrborder||', agência:'||rw_crapcdb(rw_crapcdb.count).cdagenci||
                     ', vldocmto:'||rw_crapcdb(rw_crapcdb.count).vlcheque||', cdtipope:'||pr_cdtipope||
                     ', cdprogra:'||Lower(pr_cdprogra)||'. '||sqlerrm;
      RAISE vr_exc_saida;
  END pc_grava_crapopc_bulk;

  -- Insere linhas de orçamento no arquivo
  procedure pc_proc_lista_orcamento is
    vr_ger_dsctaorc    varchar2(50);
    vr_pac_dsctaorc    varchar2(50);
    vr_dtmvto          date;
    vr_indice_agencia  crapass.cdagenci%type;
  BEGIN
    -- Inclusão do módulo e ação logado - Chamado 734422 - 03/11/2017
    GENE0001.pc_set_modulo(pr_module => 'PC_CRPS249.pc_proc_lista_orcamento', pr_action => NULL);
    -- Se o valor total for igual a zero
    if vr_vltotorc = 0 then
      return;
    end if;
    if vr_flgctpas then  -- PASSIVO
      if vr_flgctred then  -- REDUTORA
        if vr_flgrvorc then  -- REVERSAO
          vr_ger_dsctaorc := trim(vr_lsctaorc)||',';
          vr_pac_dsctaorc := ','||trim(vr_lsctaorc);
        else  -- DO DIA
          vr_ger_dsctaorc := ','||trim(vr_lsctaorc);
          vr_pac_dsctaorc := trim(vr_lsctaorc)||',';
        end if;
      else  -- NORMAL
        if vr_flgrvorc then  -- REVERSAO
          vr_ger_dsctaorc := ','||trim(vr_lsctaorc);
          vr_pac_dsctaorc := trim(vr_lsctaorc)||',';
        else  -- DO DIA
          vr_ger_dsctaorc := trim(vr_lsctaorc)||',';
          vr_pac_dsctaorc := ','||trim(vr_lsctaorc);
        end if;
      end if;
    else  -- ATIVO
      if vr_flgctred then  -- REDUTORA
        if vr_flgrvorc then  -- REVERSAO
          vr_ger_dsctaorc := ','||trim(vr_lsctaorc);
          vr_pac_dsctaorc := trim(vr_lsctaorc)||',';
        else  -- DO DIA
          vr_ger_dsctaorc := trim(vr_lsctaorc)||',';
          vr_pac_dsctaorc := ','||trim(vr_lsctaorc);
        end if;
      else  -- NORMAL
        if vr_flgrvorc then  -- REVERSAO
          vr_ger_dsctaorc := trim(vr_lsctaorc)||',';
          vr_pac_dsctaorc := ','||trim(vr_lsctaorc);
        else  -- DO DIA
          vr_ger_dsctaorc := ','||trim(vr_lsctaorc);
          vr_pac_dsctaorc := trim(vr_lsctaorc)||',';
        end if;
      end if;
    end if;
    -- Escolhe a data a utilizar
    if vr_flgrvorc then
      vr_dtmvto := vr_dtmvtopr;
    else
      vr_dtmvto := vr_dtmvtolt;
    end if;
    -- Inclui as informações no arquivo
    vr_linhadet := '99'||
                  trim(vr_dtmvtolt_yymmdd)||','||
                  trim(to_char(vr_dtmvto,'ddmmyy'))||
                  trim(vr_ger_dsctaorc)||
                  trim(to_char(vr_vltotorc, '99999999999990.00'))||
                  trim(vr_dshcporc)||
                  trim(vr_dshstorc);
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_linhadet := '999,'||trim(to_char(vr_vltotorc, '99999999999990.00'));
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_linhadet := '99'||
                  trim(vr_dtmvtolt_yymmdd)||','||
                  trim(to_char(vr_dtmvto,'ddmmyy'))||
                  trim(vr_pac_dsctaorc)||
                  trim(to_char(vr_vltotorc, '99999999999990.00'))||
                  trim(vr_dshcporc)||
                  trim(vr_dshstorc);
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    -- Inclui informações por PA
    vr_indice_agencia := vr_tab_cratorc.first;
    -- Percorre todas as agencias
    WHILE vr_indice_agencia IS NOT NULL LOOP
      -- Se o valor de lançamentos for diferente de zero
      if vr_tab_cratorc(vr_indice_agencia).vr_vllanmto <> 0 then
        vr_linhadet := to_char(vr_tab_cratorc(vr_indice_agencia).vr_cdagenci, 'fm000')||','||
                       trim(to_char(vr_tab_cratorc(vr_indice_agencia).vr_vllanmto, '99999999999990.00'));
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
      -- Próximo indice(agencia)
      vr_indice_agencia := vr_tab_cratorc.next(vr_indice_agencia);
    END LOOP;
  END;

  -- Busca o saldo diário dos associados e insere na pl/table, calculando a soma por agência
  procedure pc_proc_saldo_dep_vista (pr_cdcooper in crapsda.cdcooper%type,
                                     pr_nrdconta in crapsda.nrdconta%type,
                                     pr_dtmvtolt in crapsda.dtmvtolt%type,
                                     pr_cdagenci in crapass.cdagenci%type) IS
    --
    vr_tot_vlliquid       number(20,2):= 0;
    vr_tot_vlutiliz       number(20,2):= 0;
    vr_tot_vlsaqblq       number(20,2):= 0;
    vr_tot_vladiant       number(20,2):= 0;
    vr_tot_vlcrdliq       number(20,2):= 0;
    vr_ger_vlstotal       number(20,2):= 0;
    vr_ass_vlstotal       number(20,2):= 0;

    -- Saldo diário dos associados
    cursor cr_crapsda (pr_cdcooper in crapsda.cdcooper%type,
                       pr_nrdconta in crapsda.nrdconta%type,
                       pr_dtmvtolt in crapsda.dtmvtolt%type) is
      select nvl(crapsda.vlsddisp, 0) vlsddisp,
             nvl(crapsda.vlsdchsl, 0) vlsdchsl,
             nvl(crapsda.vlsdbloq, 0) vlsdbloq,
             nvl(crapsda.vlsdblpr, 0) vlsdblpr,
             nvl(crapsda.vlsdblfp, 0) vlsdblfp,
             nvl(crapsda.vlsdindi, 0) vlsdindi,
             nvl(crapsda.vllimcre, 0) vllimcre,
             crapsda.dtdsdclq
        from crapsda
       where crapsda.cdcooper = pr_cdcooper
         and crapsda.nrdconta = pr_nrdconta
         and crapsda.dtmvtolt = pr_dtmvtolt;
    rw_crapsda      cr_crapsda%rowtype;

  begin
    -- Inclusão do módulo e ação logado - Chamado 734422 - 03/11/2017
    GENE0001.pc_set_modulo(pr_module => 'PC_CRPS249.pc_proc_saldo_dep_vista', pr_action => NULL);
    -- Buscar o saldo diário dos associados
    open cr_crapsda (pr_cdcooper,
                     pr_nrdconta,
                     pr_dtmvtolt);
    fetch cr_crapsda into rw_crapsda;
    -- Se não encontrar
    if cr_crapsda%notfound then
      close cr_crapsda;
      RETURN; -- Retorna
    end if;
    close cr_crapsda;

    -- Calcula o saldo total do associado
    vr_ass_vlstotal := nvl(rw_crapsda.vlsddisp,0) + nvl(rw_crapsda.vlsdchsl,0) +
                       nvl(rw_crapsda.vlsdbloq,0) + nvl(rw_crapsda.vlsdblpr,0) +
                       nvl(rw_crapsda.vlsdblfp,0) + nvl(rw_crapsda.vlsdindi,0);
    -- Acumula o total líquido
    vr_tot_vlliquid := nvl(vr_tot_vlliquid,0) + nvl(vr_ass_vlstotal,0);

    -- Se a data em que foi passado para credito em liquidacao não é nula e é
    -- menor ou igual a data de referencia
    if rw_crapsda.dtdsdclq is not null and
       rw_crapsda.dtdsdclq <= pr_dtmvtolt then
      -- Se o valor total é negativo
      if vr_ass_vlstotal < 0 then
        vr_tot_vlcrdliq := nvl(vr_tot_vlcrdliq,0) + nvl(vr_ass_vlstotal,0) + nvl(rw_crapsda.vllimcre,0);
      else
        vr_tot_vlcrdliq := nvl(vr_tot_vlcrdliq,0) + nvl(vr_ass_vlstotal,0) - nvl(rw_crapsda.vllimcre,0);
      end if;
      --
      vr_tot_vlutiliz := nvl(vr_tot_vlutiliz,0) - rw_crapsda.vllimcre;
    end if;
    -- Acumula demais totais
    if (rw_crapsda.vlsddisp + rw_crapsda.vlsdchsl) < 0 then
      if (rw_crapsda.vlsddisp + rw_crapsda.vlsdchsl + rw_crapsda.vllimcre) > 0 then
        vr_tot_vlutiliz := nvl(vr_tot_vlutiliz,0) + (rw_crapsda.vlsddisp + rw_crapsda.vlsdchsl);
      elsif vr_ass_vlstotal + rw_crapsda.vllimcre > 0 then
        vr_tot_vlutiliz := nvl(vr_tot_vlutiliz,0) + (rw_crapsda.vllimcre * -1);
        vr_tot_vlsaqblq := nvl(vr_tot_vlsaqblq ,0)+ (rw_crapsda.vlsddisp + rw_crapsda.vlsdchsl + rw_crapsda.vllimcre);
      else
        if rw_crapsda.dtdsdclq is null then
          vr_tot_vlutiliz := nvl(vr_tot_vlutiliz,0) + (rw_crapsda.vllimcre * -1);
          vr_tot_vladiant := nvl(vr_tot_vladiant,0) + nvl(vr_ass_vlstotal,0) + rw_crapsda.vllimcre;
        end if;

        vr_tot_vlsaqblq := nvl(vr_tot_vlsaqblq,0) + ((rw_crapsda.vlsdbloq + rw_crapsda.vlsdblpr + rw_crapsda.vlsdblfp) * -1);

      end if;
    end if;
    --
    vr_tot_vlutiliz := nvl(vr_tot_vlutiliz,0) * -1;
    vr_tot_vlsaqblq := nvl(vr_tot_vlsaqblq,0) * -1;
    vr_tot_vladiant := nvl(vr_tot_vladiant,0) * -1;
    vr_tot_vlcrdliq := nvl(vr_tot_vlcrdliq,0) * -1;
    vr_ger_vlstotal := nvl(vr_tot_vlliquid,0) + nvl(vr_tot_vlutiliz,0) + nvl(vr_tot_vlsaqblq,0) +
                       nvl(vr_tot_vladiant,0) + nvl(vr_tot_vlcrdliq,0);
    --
    vr_tab_cratorc(pr_cdagenci).vr_cdagenci := pr_cdagenci;
    -- Se o valor geral for maior que zero
    if vr_ger_vlstotal > 0 THEN
      -- Guarda o valor no registro de memória
      vr_tab_cratorc(pr_cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(pr_cdagenci).vr_vllanmto, 0) + nvl(vr_ger_vlstotal,0);
      vr_vltotorc := nvl(vr_vltotorc, 0) + nvl(vr_ger_vlstotal,0);
    end if;
  end;
  --
  -- Alteracao tarefa 34547 (Henrique)
  -- Insere informações referentes ao prazo de retorno dos produtos CECRED
  procedure pc_proc_insere_crapprb (pr_dtmvtolt in crapprb.dtmvtolt%type,
                                    pr_cddprazo in crapprb.cddprazo%type,
                                    pr_vlretorn in crapprb.vlretorn%type) is
    vr_cddprazo    crapprb.cddprazo%type;
  BEGIN
    -- Inclusão do módulo e ação logado - Chamado 734422 - 03/11/2017
    GENE0001.pc_set_modulo(pr_module => 'PC_CRPS249.pc_proc_insere_crapprb', pr_action => NULL);
    -- Verifica o código de prazo conforme o parametro
    case pr_cddprazo
      when 1  then vr_cddprazo := 90;
      when 2  then vr_cddprazo := 180;
      when 3  then vr_cddprazo := 270;
      when 4  then vr_cddprazo := 360;
      when 5  then vr_cddprazo := 720;
      when 6  then vr_cddprazo := 1080;
      when 7  then vr_cddprazo := 1440;
      when 8  then vr_cddprazo := 1800;
      when 9  then vr_cddprazo := 2160;
      when 10 then vr_cddprazo := 2520;
      when 11 then vr_cddprazo := 2880;
      when 12 then vr_cddprazo := 3240;
      when 13 then vr_cddprazo := 3600;
      when 14 then vr_cddprazo := 3960;
      when 15 then vr_cddprazo := 4320;
      when 16 then vr_cddprazo := 4680;
      when 17 then vr_cddprazo := 5040;
      when 18 then vr_cddprazo := 5400;
      when 19 then vr_cddprazo := 5401;
    end case;
    --
    BEGIN
      -- Insere informacoes solicitadas pelo BNDES.
      insert into crapprb (cdcooper,
                           dtmvtolt,
                           cdorigem,
                           nrdconta,
                           cddprazo,
                           vlretorn)
      values (3,
              pr_dtmvtolt,
              4, -- cheque
              rw_crapcop.nrctactl,
              vr_cddprazo,
              pr_vlretorn);
    exception
      when dup_val_on_index then
        -- Mensagem igual à gerada pelo progress em caso de duplicação de chave
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt,
                                       '** Prazos retorno do BNDES ja'' existe com Codigo da Cooperativa 3 Data '||to_char(pr_dtmvtolt, 'dd/mm/yy')||
                                       ' Origem 4 conta/dv '||rw_crapcop.nrctactl||' Prazo '||vr_cddprazo||'. (132)');
      when others then
        --Inclusão na tabela de erros Oracle - Chamado 734422
        CECRED.pc_internal_exception(pr_cdcooper => 3);                                                             
        vr_cdcritic := 1034;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' crapprb. cdcooper:3, dtmvtolt: '||pr_dtmvtolt||
                       ', cdorigem:4, nrdconta:'||rw_crapcop.nrctactl||', cddprazo:'||vr_cddprazo||
                       ', vlretorn:'||pr_vlretorn||'. '||sqlerrm;
        raise vr_exc_saida;
    end;
  end;

  -- Procedimento mensal
  procedure pc_proc_cbl_mensal (pr_cdcooper in craptab.cdcooper%type) is
    -- Juros de descontos de cheques
    cursor cr_crapljd (pr_cdcooper in crapljd.cdcooper%type,
                       pr_dtrefere in crapljd.dtrefere%type) is
      select nrdconta,
             vldjuros
        from crapljd
       where crapljd.cdcooper = pr_cdcooper
         and crapljd.dtrefere = pr_dtrefere;
    -- Juros de descontos de títulos
    cursor cr_crapljt (pr_cdcooper in crapljt.cdcooper%type,
                       pr_dtrefere in crapljt.dtrefere%type) is
      select crapljt.cdcooper,
             crapljt.nrdconta,
             crapljt.nrborder,
             crapljt.cdbandoc,
             crapljt.nrdctabb,
             crapljt.nrcnvcob,
             crapljt.nrdocmto,
             crapljt.vldjuros,
             crapljt.vlrestit,
             crapljt.dtrefere,
             crapljt.rowid
        from crapljt
       where crapljt.cdcooper = pr_cdcooper
         and crapljt.dtrefere >= pr_dtrefere;
    -- Contratos de limite de crédito
    cursor cr_craplim (pr_cdcooper in craplim.cdcooper%type,
                       pr_tpctrlim in craplim.tpctrlim%type,
                       pr_insitlim in craplim.insitlim%type) is
      SELECT ass.cdagenci, lim.vllimite
        FROM craplim lim, crapass ass
       WHERE lim.cdcooper = ass.cdcooper
         AND lim.nrdconta = ass.nrdconta
         AND lim.cdcooper = pr_cdcooper
         AND lim.tpctrlim = pr_tpctrlim
         AND lim.insitlim = pr_insitlim
       ORDER BY lim.cdcooper, ass.cdagenci;
       
    -- Títulos de borderô
    cursor cr_craptdb6 (pr_cdcooper in craptdb.cdcooper%type,
                        pr_nrdconta in craptdb.nrdconta%type,
                        pr_nrborder in craptdb.nrborder%type,
                        pr_cdbandoc in craptdb.cdbandoc%type,
                        pr_nrdctabb in craptdb.nrdctabb%type,
                        pr_nrcnvcob in craptdb.nrcnvcob%type,
                        pr_nrdocmto in craptdb.nrdocmto%type,
                        pr_insittit in craptdb.insittit%type) is
      select craptdb.rowid,
             craptdb.cdcooper,
             craptdb.dtdpagto,
             craptdb.cdbandoc,
             craptdb.nrdctabb,
             craptdb.nrcnvcob,
             craptdb.nrdconta,
             craptdb.nrdocmto
        from craptdb
       where craptdb.cdcooper = pr_cdcooper
         and craptdb.nrdconta = pr_nrdconta
         and craptdb.nrborder = pr_nrborder
         and craptdb.cdbandoc = pr_cdbandoc
         and craptdb.nrdctabb = pr_nrdctabb
         and craptdb.nrcnvcob = pr_nrcnvcob
         and craptdb.nrdocmto = pr_nrdocmto
         and craptdb.insittit = pr_insittit;
    rw_craptdb6     cr_craptdb6%rowtype;
    -- Informações do associado
    cursor cr_crapass2 (pr_cdcooper in crapass.cdcooper%type) is
      select nrdconta
        from crapass
       where crapass.cdcooper = pr_cdcooper
         and crapass.dtdemiss is not null;
    rw_crapass2     cr_crapass2%rowtype;
    -- Informações de cotas e recursos
    cursor cr_crapcot (pr_cdcooper in crapcot.cdcooper%type,
                       pr_nrdconta in crapcot.nrdconta%type,
                       pr_dtmvtolt in date) is
      select crapcot.vlcotant,
             decode(to_char(pr_dtmvtolt, 'mm'),
                    '01', vlcapmes##1,  -- Janeiro
                    '02', vlcapmes##2,  -- Fevereiro
                    '03', vlcapmes##3,  -- Março
                    '04', vlcapmes##4,  -- Abril
                    '05', vlcapmes##5,  -- Maio
                    '06', vlcapmes##6,  -- Junho
                    '07', vlcapmes##7,  -- Julho
                    '08', vlcapmes##8,  -- Agosto
                    '09', vlcapmes##9,  -- Setembro
                    '10', vlcapmes##10, -- Outubro
                    '11', vlcapmes##11, -- Novembro
                    '12', vlcapmes##12) vlcapmes  -- Dezembro
        from crapcot
       where crapcot.cdcooper = pr_cdcooper
         and crapcot.nrdconta = pr_nrdconta;
    rw_crapcot     cr_crapcot%rowtype;
    -- Informações de cotas e recursos
    cursor cr_crapcot2 (pr_cdcooper in crapcot.cdcooper%type,
                        pr_dtmvtolt in date) is
      select crapcot.vlcotant,
             crapcot.nrdconta,
             decode(to_char(pr_dtmvtolt, 'mm'),
                    '01', vlcapmes##1,  -- Janeiro
                    '02', vlcapmes##2,  -- Fevereiro
                    '03', vlcapmes##3,  -- Março
                    '04', vlcapmes##4,  -- Abril
                    '05', vlcapmes##5,  -- Maio
                    '06', vlcapmes##6,  -- Junho
                    '07', vlcapmes##7,  -- Julho
                    '08', vlcapmes##8,  -- Agosto
                    '09', vlcapmes##9,  -- Setembro
                    '10', vlcapmes##10, -- Outubro
                    '11', vlcapmes##11, -- Novembro
                    '12', vlcapmes##12) vlcapmes  -- Dezembro
        from crapcot
       where crapcot.cdcooper = pr_cdcooper;
    -- Subscrição de capital realizado
    cursor cr_crapsdc2 (pr_cdcooper in crapsdc.cdcooper%type,
                        pr_nrdconta in crapsdc.nrdconta%type) is
      select /*+ index (crapsdc crapsdc##crapsdc2)*/
             vllanmto
        from crapsdc
       where crapsdc.cdcooper = pr_cdcooper
         and crapsdc.nrdconta = pr_nrdconta
         and crapsdc.dtdebito is null;
    -- Informações da central de risco
    cursor cr_crapris (pr_cdcooper in crapris.cdcooper%type,
                       pr_dtultdia in crapris.dtrefere%type,
                       pr_cdorigem in crapris.cdorigem%type,
                       pr_cdmodali in crapris.cdmodali%type,
                       pr_tpemprst IN crapepr.tpemprst%TYPE) is
      select crapris.cdcooper,
             crapris.nrdconta,
             crapris.dtrefere,
             crapris.innivris,
             crapris.cdmodali,
             crapris.nrctremp,
             crapris.nrseqctr,
             crapris.cdagenci,
             DECODE(crapass.inpessoa,3,2,crapass.inpessoa) inpessoa
        from crapris
            ,crapass        
       where crapris.cdcooper = crapass.cdcooper
         and crapris.nrdconta = crapass.nrdconta
         and crapris.cdcooper = pr_cdcooper
         and crapris.dtrefere = pr_dtultdia
         and crapris.cdorigem = pr_cdorigem
         and crapris.cdmodali = pr_cdmodali
         -- Busca informacoes da central de risco onde exista emprestimos. (D-05)
         AND EXISTS ( SELECT 1
                        FROM crapepr
                       WHERE crapepr.cdcooper = crapris.cdcooper
                         AND crapepr.nrdconta = crapris.nrdconta
                         AND crapepr.nrctremp = crapris.nrctremp
                         AND crapepr.tpemprst = pr_tpemprst)
         --> Deve ignorar emprestimos de cessao de credito                 
        AND NOT EXISTS (SELECT 1
                          FROM tbcrd_cessao_credito ces
                         WHERE ces.cdcooper = crapris.cdcooper
                           AND ces.nrdconta = crapris.nrdconta
                           AND ces.nrctremp = crapris.nrctremp);  
    -- Vencimento do risco
    cursor cr_crapvri (pr_cdcooper in crapris.cdcooper%type,
                       pr_nrdconta in crapris.nrdconta%type,
                       pr_dtrefere in crapris.dtrefere%type,
                       pr_innivris in crapris.innivris%type,
                       pr_cdmodali in crapris.cdmodali%type,
                       pr_nrctremp in crapris.nrctremp%type,
                       pr_nrseqctr in crapris.nrseqctr%type) is
      select crapvri.vldivida,
             crapvri.cdvencto
        from crapvri
       where crapvri.cdcooper = pr_cdcooper
         and crapvri.nrdconta = pr_nrdconta
         and crapvri.dtrefere = pr_dtrefere
         and crapvri.innivris = pr_innivris
         and crapvri.cdmodali = pr_cdmodali
         and crapvri.nrctremp = pr_nrctremp
         and crapvri.nrseqctr = pr_nrseqctr;
    -- Lançamentos de empréstimos
    cursor cr_craplem (pr_cdcooper in craplem.cdcooper%type,
                       pr_dtmvtolt in craplem.dtmvtolt%type) is
      select /*+ index (craplem craplem##craplem4)*/
             craplem.cdcooper,
             craplem.nrdconta,
             craplem.vllanmto
        from craplem
       where craplem.cdcooper = pr_cdcooper
         and craplem.dtmvtolt = pr_dtmvtolt
         and craplem.cdhistor = 120; -- SOBRAS DE EMPRESTIMOS
    -- Lançamentos em depósitos à vista
    cursor cr_craplcm3 (pr_cdcooper in craplcm.cdcooper%type,
                        pr_dtmvtolt in craplcm.dtmvtolt%type) is
      select /*+ index (craplcm craplcm##craplcm4)*/
             craplcm.nrdconta,
             craplcm.vllanmto
        from craplcm
       where craplcm.cdcooper = pr_cdcooper
         and craplcm.dtmvtolt = pr_dtmvtolt
         and craplcm.cdhistor in (2061,2062);
    -- Lançamentos de cotas/capital
    cursor cr_craplct (pr_cdcooper in craplcm.cdcooper%type,
                       pr_dtultdma in craplcm.dtmvtolt%type,
                       pr_dtmvtolt in craplcm.dtmvtolt%type,
                       pr_cdhistor in craplcm.cdhistor%type) is
      select craplct.nrdconta,
             craplct.vllanmto
        from craplct
       where craplct.cdcooper = pr_cdcooper
         and craplct.dtmvtolt > pr_dtultdma
         and craplct.dtmvtolt <= pr_dtmvtolt
         and craplct.cdhistor = pr_cdhistor;
    -- Saldos em Depositos a Vista para Pessoa Fisica
    cursor cr_crapass3 (pr_cdcooper in crapass.cdcooper%type,
                        pr_inpessoa in crapass.inpessoa%type) is
      select crapass.nrdconta,
             crapass.dtmvtolt,
             crapass.cdagenci
        from crapass
       where crapass.cdcooper = pr_cdcooper
         and crapass.dtelimin is null
         and crapass.inpessoa = pr_inpessoa;
    -- Saldos da conta investimento
    cursor cr_crapsli (pr_cdcooper in crapsli.cdcooper%type,
                       pr_dtultdia in crapsli.dtrefere%type) is
      select crapsli.nrdconta,
             crapsli.vlsddisp
        from crapsli
       where crapsli.cdcooper = pr_cdcooper
         and crapsli.dtrefere = pr_dtultdia;
    -- Desconto de cheques
    cursor cr_crapcdb4 (pr_cdcooper in crapcdb.cdcooper%type,
                        pr_dtmvtolt in crapcdb.dtlibera%type,
                        pr_dtmvtopr in crapcdb.dtlibera%type) is
      select /*+ index (crapcdb crapcdb##crapcdb3)*/
             crapcdb.nrdconta,
             sum(crapcdb.vlcheque) vlcheque
        from crapcdb
       where crapcdb.cdcooper = pr_cdcooper
         and crapcdb.dtlibera > pr_dtmvtolt
         and crapcdb.dtlibbdc < pr_dtmvtopr
         AND crapcdb.insitana = 1 --> Apenas aprovados
         and ( crapcdb.dtdevolu is null
               OR
              (crapcdb.dtdevolu is not null AND
               crapcdb.dtdevolu > pr_dtmvtolt)
              )
       group by crapcdb.nrdconta
       order by crapcdb.nrdconta;
    -- Provisão de receita com desconto de cheques
    cursor cr_crapljd2 (pr_cdcooper in crapljd.cdcooper%type,
                        pr_dtultdia in crapljd.dtrefere%type) is
      select crapljd.nrdconta,
             sum(crapljd.vldjuros) vldjuros
        from crapljd
       where crapljd.cdcooper = pr_cdcooper
         and crapljd.dtrefere > pr_dtultdia
       group by crapljd.nrdconta
       order by crapljd.nrdconta;
    -- Provisão de receita com desconto de cheques por agencia e tipo de pessoa
    CURSOR cr_crapljd_age(pr_cdcooper in crapljd.cdcooper%type,
                          pr_dtultdia in crapljd.dtrefere%type) IS
       SELECT SUM(crapljd.vldjuros) vldjuros
             ,crapass.cdagenci
             ,DECODE(crapass.inpessoa,3,2,crapass.inpessoa) inpessoa
         FROM crapljd
             ,crapass
        WHERE crapljd.cdcooper = crapass.cdcooper
          AND crapljd.nrdconta = crapass.nrdconta
          AND crapljd.cdcooper = pr_cdcooper
          AND crapljd.dtrefere > pr_dtultdia
        GROUP BY crapass.cdagenci
                ,DECODE(crapass.inpessoa,3,2,crapass.inpessoa);
    -- Desconto de títulos de borderô
    cursor cr_craptdb7 (pr_cdcooper in craptdb.cdcooper%type,
                        pr_insittit in craptdb.insittit%type) is
      select /*+ index (craptdb craptdb##craptdb2)*/
             craptdb.vltitulo,
             craptdb.dtvencto
        from craptdb
       where craptdb.cdcooper = pr_cdcooper
         and craptdb.insittit = pr_insittit;
    -- Desconto de Titulos
    cursor cr_craptdb8 (pr_cdcooper in craptdb.cdcooper%type,
                        pr_insittit in craptdb.insittit%type,
                        pr_flgregis in crapcob.flgregis%type) is
      select /*+ index (craptdb craptdb##craptdb2)*/
             crapass.cdagenci,
             sum(craptdb.vltitulo) vltitulo
        from crapass,
             crapcob,
             craptdb
       where craptdb.cdcooper = pr_cdcooper
         and craptdb.insittit = pr_insittit
         and crapcob.cdcooper = craptdb.cdcooper
         and crapcob.cdbandoc = craptdb.cdbandoc
         and crapcob.nrdctabb = craptdb.nrdctabb
         and crapcob.nrcnvcob = craptdb.nrcnvcob
         and crapcob.nrdconta = craptdb.nrdconta
         and crapcob.nrdocmto = craptdb.nrdocmto
         and crapcob.flgregis = pr_flgregis
         and crapass.cdcooper = crapcob.cdcooper
         and crapass.nrdconta = crapcob.nrdconta
       group by crapass.cdagenci
       order by crapass.cdagenci;
    -- Desconto de Titulos por agencia e tipo de pessoa
    CURSOR cr_craptdb_age(pr_cdcooper in craptdb.cdcooper%type,
                          pr_insittit in craptdb.insittit%type,
                          pr_flgregis in crapcob.flgregis%TYPE)IS
      SELECT SUM(craptdb.vltitulo) vltitulo
            ,crapass.cdagenci
            ,DECODE(crapass.inpessoa,3,2,crapass.inpessoa) inpessoa
        FROM crapcob
            ,craptdb
            ,crapass
       WHERE crapcob.cdcooper = crapass.cdcooper
         AND crapcob.nrdconta = crapass.nrdconta
         AND craptdb.cdcooper = crapass.cdcooper
         AND craptdb.nrdconta = crapass.nrdconta
         AND craptdb.cdcooper = crapcob.cdcooper
         AND craptdb.cdbandoc = crapcob.cdbandoc
         AND craptdb.nrdctabb = crapcob.nrdctabb
         AND craptdb.nrcnvcob = crapcob.nrcnvcob
         AND craptdb.nrdconta = crapcob.nrdconta
         AND craptdb.nrdocmto = crapcob.nrdocmto       
         AND craptdb.cdcooper = pr_cdcooper
         AND crapcob.flgregis = pr_flgregis
         AND craptdb.insittit = pr_insittit
       GROUP BY crapass.cdagenci
               ,DECODE(crapass.inpessoa,3,2,crapass.inpessoa);
    -- Provisao de Receita com Desconto de Titulos
    cursor cr_crapljt2 (pr_cdcooper in crapljt.cdcooper%type,
                        pr_dtultdia in crapljt.dtrefere%type,
                        pr_flgregis in crapcob.flgregis%type) is
      select crapljt.nrdconta,
             sum(crapljt.vldjuros) vldjuros
        from crapcob,
             crapljt
       where crapljt.cdcooper = pr_cdcooper
         and crapljt.dtrefere > pr_dtultdia
         and crapcob.cdcooper = crapljt.cdcooper
         and crapcob.cdbandoc = crapljt.cdbandoc
         and crapcob.nrdctabb = crapljt.nrdctabb
         and crapcob.nrcnvcob = crapljt.nrcnvcob
         and crapcob.nrdconta = crapljt.nrdconta
         and crapcob.nrdocmto = crapljt.nrdocmto
         and crapcob.flgregis = pr_flgregis
       group by crapljt.nrdconta
       order by crapljt.nrdconta;
    -- Provisao de Receita com Desconto de Titulos por Agencia e Tipo de Pessoa
    CURSOR cr_crapljt_age (pr_cdcooper IN crapljt.cdcooper%TYPE
                          ,pr_dtultdia IN crapljt.dtrefere%TYPE
                          ,pr_flgregis IN crapcob.flgregis%TYPE) IS
       SELECT SUM(crapljt.vldjuros) vldjuros
             ,crapass.cdagenci
             ,DECODE(crapass.inpessoa,3,2,crapass.inpessoa) inpessoa
         FROM crapcob,
              crapljt,
              crapass
        WHERE crapcob.cdcooper = crapljt.cdcooper
          AND crapcob.cdbandoc = crapljt.cdbandoc
          AND crapcob.nrdctabb = crapljt.nrdctabb
          AND crapcob.nrcnvcob = crapljt.nrcnvcob
          AND crapcob.nrdconta = crapljt.nrdconta
          AND crapcob.nrdocmto = crapljt.nrdocmto
          AND crapcob.cdcooper = crapass.cdcooper
          AND crapcob.nrdconta = crapass.nrdconta
          AND crapljt.cdcooper = crapass.cdcooper
          AND crapljt.nrdconta = crapass.nrdconta
          AND crapljt.cdcooper = pr_cdcooper
          and crapljt.dtrefere > pr_dtultdia
          AND crapcob.flgregis = pr_flgregis
       GROUP BY crapass.cdagenci
               ,DECODE(crapass.inpessoa,3,2,crapass.inpessoa)
       ORDER BY crapass.cdagenci;      

  	--Melhorias performance - Chamado 734422
    --Juncao dos cursores cr_craprda e cr_crapass
    -- Aplicação RDCA30, RDCA60, RDCPRE e Informações do associado
    cursor cr_craprda (pr_cdcooper in craprda.cdcooper%type,
                       pr_tpaplica in craprda.tpaplica%type) is
      select /*+ index (craprda craprda##craprda2)*/
             crapass.cdagenci cdagenci,
             sum(craprda.vlslfmes) vlslfmes
        from craprda, crapass
       where craprda.nrdconta = crapass.nrdconta
         and craprda.cdcooper = crapass.cdcooper
         and craprda.tpaplica = pr_tpaplica
         and crapass.cdcooper = pr_cdcooper
       group by crapass.cdagenci
       order by crapass.cdagenci;

    TYPE typ_cr_craprda IS TABLE OF cr_craprda%ROWTYPE index by binary_integer;
    rw_craprda typ_cr_craprda;
    --

    -- Desconto de cheques
    cursor cr_craprpp (pr_cdcooper in craprpp.cdcooper%type,
                       pr_dtslfmes in craprpp.dtslfmes%type) is
      select /*+ index (craprpp craprpp##craprpp1)*/
             craprpp.nrdconta,
             sum(craprpp.vlslfmes) vlslfmes
        from craprpp
       where craprpp.cdcooper = pr_cdcooper
         and craprpp.dtslfmes = pr_dtslfmes
         -- and craprpp.vlslfmes > 0 -- Comentado devido a erros no relatório de Razão Contábil (Renato-Supero-06/11/2015)
       group by craprpp.nrdconta
       order by craprpp.nrdconta;
    -- Subscrição de capital a realizar
    cursor cr_crapsdc3 (pr_cdcooper in crapsdc.cdcooper%type) is
      select /*+ index (crapsdc crapsdc##crapsdc2)*/
             nrdconta,
             vllanmto
        from crapsdc
       where crapsdc.cdcooper = pr_cdcooper
         and crapsdc.dtdebito is null;
    -- PL/Table utilizada para agrupar descontos de títulos
    type typ_acumltit is record (vr_vltitulo      craptdb.vltitulo%type);
    -- Definição da tabela para armazenar os registros agrupados
    type typ_tab_acumltit is table of typ_acumltit index by binary_integer;
    -- Instância da tabela.
    vr_tab_acumltit        typ_tab_acumltit;
    -- Índice da PL/Table
    vr_indice              number(3);
    -- Data de referência
    vr_dtrefere            date;

  BEGIN

    -- Inclusão do módulo e ação logado - Chamado 734422 - 03/11/2017
    GENE0001.pc_set_modulo(pr_module => 'PC_CRPS249.pc_proc_cbl_mensal', pr_action => NULL);

    -- Apropriacao da receita de desconto de cheques ..................
    vr_tab_agencia.delete;
    vr_dtrefere := last_day(vr_dtmvtolt);
    --
    pc_cria_agencia_pltable(999,15); -- 15 - APROPRIACAO RECEITA DE CHEQUE RECEBIDO PARA DESCONTO
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

    -- Buscar juros de descontos de cheques
    FOR rw_crapljd IN cr_crapljd (pr_cdcooper,
                                  vr_dtrefere) LOOP

      -- Buscar dados do associado
      OPEN cr_crapass (pr_cdcooper,
                       rw_crapljd.nrdconta);
        FETCH cr_crapass INTO rw_crapass;

        pc_cria_agencia_pltable(rw_crapass.cdagenci,15);        
        -- Incluir nome do módulo logado
        gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
        -- Separando as informacoes em PF e PJ
        IF rw_crapass.inpessoa = 1 THEN
           vr_arq_op_cred(15)(rw_crapass.cdagenci)(1) := vr_arq_op_cred(15)(rw_crapass.cdagenci)(1) + rw_crapljd.vldjuros;
           vr_arq_op_cred(15)(999)(1) := vr_arq_op_cred(15)(999)(1) + rw_crapljd.vldjuros;           
        ELSE
           vr_arq_op_cred(15)(rw_crapass.cdagenci)(2) := vr_arq_op_cred(15)(rw_crapass.cdagenci)(2) + rw_crapljd.vldjuros;
           vr_arq_op_cred(15)(999)(2) := vr_arq_op_cred(15)(999)(2) + rw_crapljd.vldjuros;
        END IF;
        --
        vr_tab_agencia(rw_crapass.cdagenci).vr_vlaprjur := vr_tab_agencia(rw_crapass.cdagenci).vr_vlaprjur + rw_crapljd.vldjuros;
        vr_tab_agencia(999).vr_vlaprjur := vr_tab_agencia(999).vr_vlaprjur + rw_crapljd.vldjuros;
      CLOSE cr_crapass;
    END LOOP;
    -- Cria registro de total de apropriacao de juros
    if nvl(vr_tab_agencia(999).vr_vlaprjur, 0) > 0 then
      vr_cdestrut := '55';
      -- Formar a linha de detalhes
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '1642,'||
                     '7131,'||
                     trim(to_char(vr_tab_agencia(999).vr_vlaprjur, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) APROPRIACAO RECEITA DE CHEQUE RECEBIDO PARA DESCONTO."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_tab_agencia(999).vr_vlaprjur, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      -- Cria lancamentos da apropriacao dos juros por pac
      vr_indice_agencia := vr_tab_agencia.first;
      -- Percorre todas as agencias
      while vr_indice_agencia <= 998 loop
        if vr_tab_agencia2(vr_indice_agencia).vr_cdccuage > 0 and
           vr_tab_agencia(vr_indice_agencia).vr_vlaprjur > 0 then
          vr_linhadet := to_char(vr_tab_agencia2(vr_indice_agencia).vr_cdccuage, 'fm000')||','||
                         trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_vlaprjur, '999999990.00'));
          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
        vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
      end loop;
    end if;
    -- Contabilizacao do saldo de limite de descontos de cheques ...........
    vr_tab_agencia(1).vr_vlaprjur := 0;
    vr_tab_limcon.DELETE;
    for rw_craplim in cr_craplim (pr_cdcooper,
                                  2, -- tpctrlim
                                  2  -- insitlim
                                   ) loop
      vr_tab_agencia(1).vr_vlaprjur := vr_tab_agencia(1).vr_vlaprjur + rw_craplim.vllimite;
      vr_tab_limcon(rw_craplim.cdagenci).cdagenci := rw_craplim.cdagenci;
      vr_tab_limcon(rw_craplim.cdagenci).valor := NVL(vr_tab_limcon(rw_craplim.cdagenci).valor,0) + rw_craplim.vllimite;      
    end loop;
    --
    if vr_tab_agencia(1).vr_vlaprjur > 0 then
      vr_cdestrut := '51';
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '3813,'||
                     '9184,'||
                     trim(to_char(vr_tab_agencia(1).vr_vlaprjur, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) LIMITES CONCEDIDOS PARA DESCONTO DE CHEQUES."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      
      -- Percorre todas as agencias e grava no arquivo
      vr_indice := vr_tab_limcon.first;
      WHILE vr_indice IS NOT NULL LOOP
        vr_linhadet := TRIM(to_char(vr_tab_limcon(vr_indice).cdagenci, '009')) || ',' ||
                       TRIM(to_char(vr_tab_limcon(vr_indice).valor, '99999999999990.00'));                       
        -- Grava a linha no arquivo
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);        -- Proximo registro               
        
        vr_indice := vr_tab_limcon.next(vr_indice);               
      END LOOP;
      
      -- Reversao
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtopr,'ddmmyy'))||','||
                     '9184,'||
                     '3813,'||
                     trim(to_char(vr_tab_agencia(1).vr_vlaprjur, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) LIMITES CONCEDIDOS PARA DESCONTO DE CHEQUES."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      
      -- Percorre todas as agencias e grava no arquivo
      vr_indice := vr_tab_limcon.first;
      WHILE vr_indice IS NOT NULL LOOP
        vr_linhadet := TRIM(to_char(vr_tab_limcon(vr_indice).cdagenci, '009')) || ',' ||
                       TRIM(to_char(vr_tab_limcon(vr_indice).valor, '99999999999990.00'));                       
        -- Grava a linha no arquivo
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);        -- Proximo registro               
        
        vr_indice := vr_tab_limcon.next(vr_indice);               
      END LOOP;
      
    end if;
    -- Apropriacao da receita de desconto de titulos ..................
    vr_tab_agencia.delete;
    vr_dtrefere := last_day(vr_dtmvtolt);
    --
    pc_cria_agencia_pltable(999,12); -- 12 - APROPRIACAO RECEITA DE TITULO RECEBIDO PARA DESCONTO S/ REGISTRO
    pc_cria_agencia_pltable(999,13); -- 13 - APROPRIACAO RECEITA DE TITULO RECEBIDO PARA DESCONTO C/ REGISTRO
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    -- Buscar os juros de descontos de títulos
    for rw_crapljt in cr_crapljt (pr_cdcooper,
                                  vr_dtrefere) loop
      open cr_crapass (pr_cdcooper,
                       rw_crapljt.nrdconta);
        fetch cr_crapass into rw_crapass;
      close cr_crapass;
      -- Borderô de desconto de títulos
      begin
        -- Busca titulos do Bordero de desconto de titulos
        open cr_craptdb6 (pr_cdcooper,
                          rw_crapljt.nrdconta,
                          rw_crapljt.nrborder,
                          rw_crapljt.cdbandoc,
                          rw_crapljt.nrdctabb,
                          rw_crapljt.nrcnvcob,
                          rw_crapljt.nrdocmto,
                          2);
          fetch cr_craptdb6 into rw_craptdb6;
          -- Verifica se o título foi pago, para descartar o registro
          if cr_craptdb6%found then
            if ((to_char(rw_craptdb6.dtdpagto, 'yyyy') = to_char(vr_dtrefere, 'yyyy') and
                 to_char(rw_craptdb6.dtdpagto, 'mm') < to_char(vr_dtrefere, 'mm')) or
                to_char(rw_craptdb6.dtdpagto, 'yyyy') < to_char(vr_dtrefere, 'yyyy')) then
              -- Se o titulo foi pago em meses anteriores ao vencimento (antecipado),
              -- nao contabiliza o juros que havia sido restituido
              close cr_craptdb6;
              continue;
            end if;
          elsif cr_craptdb6%notfound and
                rw_crapljt.dtrefere > vr_dtrefere then
            -- Se o titulo nao foi pago, somente contabiliza o juros do mes atual
            close cr_craptdb6;
            continue;
          end if;
        close cr_craptdb6;
      end;
      -- Se for um titulo resgatado nao soma os juros restituidos pois eles
      -- ja foram lancados a debito na 1644 no dia que o titulo eh resgatado
      begin
        -- Borderô de desconto de títulos
        open cr_craptdb6 (pr_cdcooper,
                          rw_crapljt.nrdconta,
                          rw_crapljt.nrborder,
                          rw_crapljt.cdbandoc,
                          rw_crapljt.nrdctabb,
                          rw_crapljt.nrcnvcob,
                          rw_crapljt.nrdocmto,
                          1);
          fetch cr_craptdb6 into rw_craptdb6;
          -- Se existe borderô, procura a cobrança do borderô
          -- Senão, procura a cobrança da apropriação da receita
          if cr_craptdb6%found then
            open cr_crapcob (rw_craptdb6.cdcooper,
                             rw_craptdb6.cdbandoc,
                             rw_craptdb6.nrdctabb,
                             rw_craptdb6.nrcnvcob,
                             rw_craptdb6.nrdconta,
                             rw_craptdb6.nrdocmto);
              fetch cr_crapcob into rw_crapcob;
              -- Se naum encontrar titulo em desconto
              if cr_crapcob%notfound then
                -- Alteração no codigo da critica de 1033 para 1113 - Chamado 832035 - 16/01/2018
                vr_cdcritic := 1113;
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' no crapcob - ROWID(craptdb) = '||to_char(rw_craptdb6.rowid);
                btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                          ,pr_ind_tipo_log  => 2 -- Erro de negócio
                                          ,pr_nmarqlog      => 'proc_batch.log'
                                          ,pr_tpexecucao    => 1 -- Job
                                          ,pr_cdcriticidade => 1 -- Medio
                                          ,pr_cdmensagem    => vr_cdcritic
                                          ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                              || vr_cdprogra || ' --> '|| vr_dscritic);
                close cr_craptdb6;
                close cr_crapcob;
                continue;
              end if;
            close cr_crapcob;
            --
            pc_cria_agencia_pltable(rw_crapass.cdagenci,12);
            pc_cria_agencia_pltable(rw_crapass.cdagenci,13);
            -- Incluir nome do módulo logado
            gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
            IF rw_crapcob.flgregis = 1 THEN

               -- Separando as informacoes por agencia e por tipo de pessoa
               IF rw_crapass.inpessoa = 1 THEN
                  vr_arq_op_cred(13)(rw_crapass.cdagenci)(1) := vr_arq_op_cred(13)(rw_crapass.cdagenci)(1) + rw_crapljt.vldjuros;
                  vr_arq_op_cred(13)(999)(1) := vr_arq_op_cred(13)(999)(1) + rw_crapljt.vldjuros;
               ELSE
                  vr_arq_op_cred(13)(rw_crapass.cdagenci)(2) := vr_arq_op_cred(13)(rw_crapass.cdagenci)(2) + rw_crapljt.vldjuros;
                  vr_arq_op_cred(13)(999)(2) := vr_arq_op_cred(13)(999)(2) + rw_crapljt.vldjuros;
               END IF;

               vr_tab_agencia(rw_crapass.cdagenci).vr_aprjurcr := vr_tab_agencia(rw_crapass.cdagenci).vr_aprjurcr + rw_crapljt.vldjuros;
               vr_tab_agencia(999).vr_aprjurcr := vr_tab_agencia(999).vr_aprjurcr + rw_crapljt.vldjuros;
            ELSE

               -- Separando as informacoes por agencia e por tipo de pessoa
               IF rw_crapass.inpessoa = 1 THEN
                  vr_arq_op_cred(12)(rw_crapass.cdagenci)(1) := vr_arq_op_cred(12)(rw_crapass.cdagenci)(1) + rw_crapljt.vldjuros;
                  vr_arq_op_cred(12)(999)(1) := vr_arq_op_cred(12)(999)(1) + rw_crapljt.vldjuros;
               ELSE
                  vr_arq_op_cred(12)(rw_crapass.cdagenci)(2) := vr_arq_op_cred(12)(rw_crapass.cdagenci)(2) + rw_crapljt.vldjuros;
                  vr_arq_op_cred(12)(999)(2) := vr_arq_op_cred(12)(999)(2) + rw_crapljt.vldjuros;
               END IF;

               vr_tab_agencia(rw_crapass.cdagenci).vr_aprjursr := vr_tab_agencia(rw_crapass.cdagenci).vr_aprjursr + rw_crapljt.vldjuros;
               vr_tab_agencia(999).vr_aprjursr := vr_tab_agencia(999).vr_aprjursr + rw_crapljt.vldjuros;
            END IF;
          ELSE
            -- Busca informações do cadastro de bloquetos de cobranca
            open cr_crapcob (rw_crapljt.cdcooper,
                             rw_crapljt.cdbandoc,
                             rw_crapljt.nrdctabb,
                             rw_crapljt.nrcnvcob,
                             rw_crapljt.nrdconta,
                             rw_crapljt.nrdocmto);
              fetch cr_crapcob into rw_crapcob;
              -- Se naum encontrar titulo em desconto
              if cr_crapcob%notfound then
                -- Alteração no codigo da critica de 1033 para 1113 - Chamado 832035 - 16/01/2018
                vr_cdcritic := 1113;
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' no crapcob - ROWID(crapljt) = '||to_char(rw_crapljt.rowid);
                btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                          ,pr_ind_tipo_log  => 2 -- Erro de Negócio
                                          ,pr_nmarqlog      => 'proc_batch.log'
                                          ,pr_tpexecucao    => 1 -- Job
                                          ,pr_cdcriticidade => 1 -- Medio
                                          ,pr_cdmensagem    => vr_cdcritic
                                          ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                              || vr_cdprogra || ' --> '|| vr_dscritic);
                close cr_craptdb6;
                close cr_crapcob;
                continue;
              end if;
            close cr_crapcob;
            --
            pc_cria_agencia_pltable(rw_crapass.cdagenci,12);
            pc_cria_agencia_pltable(rw_crapass.cdagenci,13);
            -- Incluir nome do módulo logado
            gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
            IF rw_crapcob.flgregis = 1 THEN

               -- Separando as informacoes por agencia e por tipo de pessoa
               IF rw_crapass.inpessoa = 1 THEN
                  vr_arq_op_cred(13)(rw_crapass.cdagenci)(1) := vr_arq_op_cred(13)(rw_crapass.cdagenci)(1) + rw_crapljt.vldjuros + rw_crapljt.vlrestit;
                  vr_arq_op_cred(13)(999)(1) := vr_arq_op_cred(13)(999)(1) + rw_crapljt.vldjuros + rw_crapljt.vlrestit;
               ELSE
                  vr_arq_op_cred(13)(rw_crapass.cdagenci)(2) := vr_arq_op_cred(13)(rw_crapass.cdagenci)(2) + rw_crapljt.vldjuros + + rw_crapljt.vlrestit;
                  vr_arq_op_cred(13)(999)(2) := vr_arq_op_cred(13)(999)(2) + rw_crapljt.vldjuros + rw_crapljt.vlrestit;
               END IF;

               vr_tab_agencia(rw_crapass.cdagenci).vr_aprjurcr := vr_tab_agencia(rw_crapass.cdagenci).vr_aprjurcr + rw_crapljt.vldjuros + rw_crapljt.vlrestit;
               vr_tab_agencia(999).vr_aprjurcr := vr_tab_agencia(999).vr_aprjurcr + rw_crapljt.vldjuros + rw_crapljt.vlrestit;
            ELSE

               -- Separando as informacoes por agencia e por tipo de pessoa
               IF rw_crapass.inpessoa = 1 THEN
                  vr_arq_op_cred(12)(rw_crapass.cdagenci)(1) := vr_arq_op_cred(12)(rw_crapass.cdagenci)(1) + rw_crapljt.vldjuros + rw_crapljt.vlrestit;
                  vr_arq_op_cred(12)(999)(1) := vr_arq_op_cred(12)(999)(1) + rw_crapljt.vldjuros + rw_crapljt.vlrestit;
               ELSE
                  vr_arq_op_cred(12)(rw_crapass.cdagenci)(2) := vr_arq_op_cred(12)(rw_crapass.cdagenci)(2) + rw_crapljt.vldjuros + rw_crapljt.vlrestit;
                  vr_arq_op_cred(12)(999)(2) := vr_arq_op_cred(12)(999)(2) + rw_crapljt.vldjuros + rw_crapljt.vlrestit;
               END IF;

               vr_tab_agencia(rw_crapass.cdagenci).vr_aprjursr := vr_tab_agencia(rw_crapass.cdagenci).vr_aprjursr + rw_crapljt.vldjuros + rw_crapljt.vlrestit;
               vr_tab_agencia(999).vr_aprjursr := vr_tab_agencia(999).vr_aprjursr + rw_crapljt.vldjuros + rw_crapljt.vlrestit;
            END IF;
          end if;
        close cr_craptdb6;
      end;
    end loop; -- Fim do loop na crapljt
    -- Cria registro de total de apropriacao de juros - sem registro
    if nvl(vr_tab_agencia(999).vr_aprjursr, 0) > 0 then
      vr_cdestrut := '55';
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '1644,'||
                     '7132,'||
                     trim(to_char(vr_tab_agencia(999).vr_aprjursr, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) APROPRIACAO RECEITA DE TITULO RECEBIDO PARA DESCONTO S/ REGISTRO."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_tab_agencia(999).vr_aprjursr, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      -- Cria lancamentos da apropriacao dos juros por pac
      vr_indice_agencia := vr_tab_agencia.first;
      while vr_indice_agencia <= 998 loop
        if vr_tab_agencia2(vr_indice_agencia).vr_cdccuage > 0 and
           vr_tab_agencia(vr_indice_agencia).vr_aprjursr > 0 then
          vr_linhadet := to_char(vr_tab_agencia2(vr_indice_agencia).vr_cdccuage, 'fm000')||','||
                         trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_aprjursr, '999999990.00'));
          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
        vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
      end loop;
    end if;
    -- Cria registro de total de apropriacao de juros - com registro
    if nvl(vr_tab_agencia(999).vr_aprjurcr, 0) > 0 then
      vr_cdestrut := '55';
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '1646,'||
                     '7132,'||
                     trim(to_char(vr_tab_agencia(999).vr_aprjurcr, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) APROPRIACAO RECEITA DE TITULO RECEBIDO PARA DESCONTO C/ REGISTRO."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_tab_agencia(999).vr_aprjurcr, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      -- Cria lancamentos da apropriacao dos juros por pac
      vr_indice_agencia := vr_tab_agencia.first;
      while vr_indice_agencia <= 998 loop
        if vr_tab_agencia2(vr_indice_agencia).vr_cdccuage > 0 and
           vr_tab_agencia(vr_indice_agencia).vr_aprjurcr > 0 then
          vr_linhadet := to_char(vr_tab_agencia2(vr_indice_agencia).vr_cdccuage, 'fm000')||','||
                         trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_aprjurcr, '999999990.00'));
          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
        vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
      end loop;
    end if;
    -- Contabilizacao do saldo de limite de descontos de titulos ...........
    vr_tab_agencia(1).vr_vlaprjur := 0;
    vr_tab_limcon.DELETE;    
    -- Buscar limites ativos
    for rw_craplim in cr_craplim (pr_cdcooper,
                                  3, -- tpctrlim
                                  2  -- insitlim
                                   ) loop
      vr_tab_agencia(1).vr_vlaprjur := vr_tab_agencia(1).vr_vlaprjur + rw_craplim.vllimite;
      vr_tab_limcon(rw_craplim.cdagenci).cdagenci := rw_craplim.cdagenci;
      vr_tab_limcon(rw_craplim.cdagenci).valor := NVL(vr_tab_limcon(rw_craplim.cdagenci).valor,0) + rw_craplim.vllimite;            
    end loop;
    --
    if vr_tab_agencia(1).vr_vlaprjur > 0 then
      vr_cdestrut := '51';
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '3815,'||
                     '9186,'||
                     trim(to_char(vr_tab_agencia(1).vr_vlaprjur, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) LIMITES CONCEDIDOS PARA DESCONTO DE TITULOS."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

      -- Percorre todas as agencias e grava no arquivo
      vr_indice := vr_tab_limcon.first;
      WHILE vr_indice IS NOT NULL LOOP
        vr_linhadet := TRIM(to_char(vr_tab_limcon(vr_indice).cdagenci, '009')) || ',' ||
                       TRIM(to_char(vr_tab_limcon(vr_indice).valor, '99999999999990.00'));                       
        -- Grava a linha no arquivo
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);        -- Proximo registro               
        
        vr_indice := vr_tab_limcon.next(vr_indice);               
      END LOOP;
      
      -- Reversao
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtopr,'ddmmyy'))||','||
                     '9186,'||
                     '3815,'||
                     trim(to_char(vr_tab_agencia(1).vr_vlaprjur, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) LIMITES CONCEDIDOS PARA DESCONTO DE TITULOS."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      
      -- Percorre todas as agencias e grava no arquivo
      vr_indice := vr_tab_limcon.first;
      WHILE vr_indice IS NOT NULL LOOP
        vr_linhadet := TRIM(to_char(vr_tab_limcon(vr_indice).cdagenci, '009')) || ',' ||
                       TRIM(to_char(vr_tab_limcon(vr_indice).valor, '99999999999990.00'));                       
        -- Grava a linha no arquivo
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);        -- Proximo registro               
        
        vr_indice := vr_tab_limcon.next(vr_indice);               
      END LOOP;
      
    end if;
/* Pj 364 - Suellen solicitou retirar
    -- Baixa do saldo do capital dos inativos ..............................
    vr_vlcompel := 0;
    for rw_crapass2 in cr_crapass2 (pr_cdcooper) loop
      open cr_crapcot (pr_cdcooper,
                       rw_crapass2.nrdconta,
                       vr_dtmvtolt);
        fetch cr_crapcot into rw_crapcot;
        if cr_crapcot%notfound then
          close cr_crapcot;
          continue;
        end if;
      close cr_crapcot;
      --
      if to_char(vr_dtmvtolt, 'yyyy') = to_char(vr_dtmvtopr, 'yyyy') then
        vr_vlcompel := vr_vlcompel + rw_crapcot.vlcapmes;
      else
        vr_vlcompel := vr_vlcompel + rw_crapcot.vlcotant;
      end if;
    end loop;  -- Fim do loop na crapass
    --
    if vr_vlcompel > 0 then
      vr_cdestrut := '51';
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '6112,'||
                     '4782,'||
                     trim(to_char(vr_vlcompel, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) CAPITAL DE ASSOCIADOS INATIVOS."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_vlcompel, '99999999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      -- Reversao
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtopr,'ddmmyy'))||','||
                     '4782,'||
                     '6112,'||
                     trim(to_char(vr_vlcompel, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) CAPITAL DE ASSOCIADOS INATIVOS."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_vlcompel, '99999999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
*/
    -- Contabilizacao para orcamento (Realizado)............................
    vr_cdcritic := 0;
    btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                              ,pr_ind_tipo_log  => 1 -- Informação
                              ,pr_nmarqlog      => 'proc_batch.log'
                              ,pr_tpexecucao    => 1 -- Job
                              ,pr_cdcriticidade => 0 -- Baixa
                              ,pr_cdmensagem    => vr_cdcritic
                              ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                  || vr_cdprogra || ' --> '
                                                  || 'Inicio da contabilizacao para o orcamento (realizado)');

    -- Capital .............................................................
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
    -- Percorrer informacoes referentes a cotas e recursos
    for rw_crapcot2 in cr_crapcot2 (pr_cdcooper,
                                    vr_dtmvtolt) LOOP
      -- Buscar informações do associado
      open cr_crapass (pr_cdcooper,
                       rw_crapcot2.nrdconta);
        fetch cr_crapass into rw_crapass;
      close cr_crapass;
      --
      if rw_crapass.dtdemiss is not null then
        continue;
      end if;
      --
      vr_tab_cratorc(rw_crapass.cdagenci).vr_cdagenci := rw_crapass.cdagenci;
      if to_char(vr_dtmvtolt, 'yyyy') = to_char(vr_dtmvtopr, 'yyyy') then
        vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto, 0) + rw_crapcot2.vlcapmes;
        vr_vltotorc := vr_vltotorc + rw_crapcot2.vlcapmes;
      else
        vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto, 0) + rw_crapcot2.vlcotant;
        vr_vltotorc := vr_vltotorc + rw_crapcot2.vlcotant;
      end if;
      --
      for rw_crapsdc2 in cr_crapsdc2 (pr_cdcooper,
                                      rw_crapcot2.nrdconta) loop
        vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto, 0) + rw_crapsdc2.vllanmto;
        vr_vltotorc := vr_vltotorc + rw_crapsdc2.vllanmto;
      end loop;
    end loop;
    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := true;  -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',6112,';
    vr_dshstorc := '"(crps249) CAPITAL REALIZADO."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := true;  -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',6112,';
    vr_dshstorc := '"(crps249) REVERSAO DO CAPITAL REALIZADO."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    -- Capital a realizar ..................................................
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
    --
    -- Buscar registros para subscricao do capital dos associados admitidos
    for rw_crapsdc3 in cr_crapsdc3 (pr_cdcooper) loop
      open cr_crapass (pr_cdcooper,
                       rw_crapsdc3.nrdconta);
        fetch cr_crapass into rw_crapass;
      close cr_crapass;
      --
      vr_tab_cratorc(rw_crapass.cdagenci).vr_cdagenci := rw_crapass.cdagenci;
      vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto, 0) + rw_crapsdc3.vllanmto;
      vr_vltotorc := vr_vltotorc + rw_crapsdc3.vllanmto;
    end loop;
    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := true;  -- Conta do PASSIVO
    vr_flgctred := true;  -- Redutora
    vr_lsctaorc := ',6122,';
    vr_dshstorc := '"(crps249) CAPITAL A REALIZAR."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := true;  -- Conta do PASSIVO
    vr_flgctred := true;  -- Redutora
    vr_lsctaorc := ',6122,';
    vr_dshstorc := '"(crps249) REVERSAO DO CAPITAL A REALIZAR."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    -- Emprestimos 0229 ....................................................
    pc_cria_agencia_pltable(999,3);
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
    -- Buscar dados do controle das informacoes da central de risco
    for rw_crapris in cr_crapris (pr_cdcooper,
                                  vr_dtultdia,
                                  3,
                                  299,
                                  0) loop
      vr_vlstotal := 0;
      -- Buscar o vencimento do risco
      for rw_crapvri in cr_crapvri (rw_crapris.cdcooper,
                                    rw_crapris.nrdconta,
                                    rw_crapris.dtrefere,
                                    rw_crapris.innivris,
                                    rw_crapris.cdmodali,
                                    rw_crapris.nrctremp,
                                    rw_crapris.nrseqctr) loop
        if rw_crapvri.cdvencto BETWEEN 110 AND 290 THEN
          vr_vlstotal := vr_vlstotal + rw_crapvri.vldivida;
        end if;
      end loop;
      --
      pc_cria_agencia_pltable(rw_crapris.cdagenci,3);
      -- Incluir nome do módulo logado
      gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
      -- Separando as informacoes por agencia e tipo de pessoa
      IF rw_crapris.inpessoa = 1 THEN
         vr_arq_op_cred(3)(rw_crapris.cdagenci)(1) := vr_arq_op_cred(3)(rw_crapris.cdagenci)(1) + vr_vlstotal;
         vr_arq_op_cred(3)(999)(1) := vr_arq_op_cred(3)(999)(1) + vr_vlstotal;
      ELSE
         vr_arq_op_cred(3)(rw_crapris.cdagenci)(2) := vr_arq_op_cred(3)(rw_crapris.cdagenci)(2) + vr_vlstotal;
         vr_arq_op_cred(3)(999)(2) := vr_arq_op_cred(3)(999)(2) + vr_vlstotal;
      END IF;
      --
      vr_tab_cratorc(rw_crapris.cdagenci).vr_cdagenci := rw_crapris.cdagenci;
      vr_tab_cratorc(rw_crapris.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapris.cdagenci).vr_vllanmto, 0) + vr_vlstotal;
      vr_vltotorc := vr_vltotorc + vr_vlstotal;
    end loop;
    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := false; -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',1621,';
    vr_dshstorc := '"(crps249) EMPRESTIMOS REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := false; -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',1621,';
    vr_dshstorc := '"(crps249) REVERSAO DOS EMPRESTIMOS REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    -- Financiamentos ......................................................
    pc_cria_agencia_pltable(999,4);
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
    -- Buscar o vencimento do risco
    for rw_crapris in cr_crapris (pr_cdcooper,
                                  vr_dtultdia,
                                  3,
                                  499,
                                  0) loop
      vr_vlstotal := 0;

      -- Se for modalidade 0499, deve desprezar contratos do BNDES
      OPEN  cr_crapebn(rw_crapris.cdcooper, rw_crapris.nrdconta, rw_crapris.nrctremp);
      FETCH cr_crapebn INTO vr_incrapebn;
      -- Se retorna algum registro
      IF cr_crapebn%FOUND THEN
        CLOSE cr_crapebn;
        CONTINUE;  /* Despreza contratos do BNDES */
      END IF;
      IF cr_crapebn%ISOPEN THEN
        CLOSE cr_crapebn;
      END IF;

      -- Buscar vencimento do risco
      for rw_crapvri in cr_crapvri (rw_crapris.cdcooper,
                                    rw_crapris.nrdconta,
                                    rw_crapris.dtrefere,
                                    rw_crapris.innivris,
                                    rw_crapris.cdmodali,
                                    rw_crapris.nrctremp,
                                    rw_crapris.nrseqctr) loop
        if rw_crapvri.cdvencto >= 110 and
           rw_crapvri.cdvencto <= 290 then
          vr_vlstotal := vr_vlstotal + rw_crapvri.vldivida;
        end if;
      end loop;
      --
      pc_cria_agencia_pltable(rw_crapris.cdagenci,4);
      -- Incluir nome do módulo logado
      gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
      -- Separando as informacoes por agencia e tipo de pessoa
      IF rw_crapris.inpessoa = 1 THEN
         vr_arq_op_cred(4)(rw_crapris.cdagenci)(1) := vr_arq_op_cred(4)(rw_crapris.cdagenci)(1) + vr_vlstotal;
         vr_arq_op_cred(4)(999)(1) := vr_arq_op_cred(4)(999)(1) + vr_vlstotal;
      ELSE
         vr_arq_op_cred(4)(rw_crapris.cdagenci)(2) := vr_arq_op_cred(4)(rw_crapris.cdagenci)(2) + vr_vlstotal;
         vr_arq_op_cred(4)(999)(2) := vr_arq_op_cred(4)(999)(2) + vr_vlstotal;
      END IF;
      --
      vr_tab_cratorc(rw_crapris.cdagenci).vr_cdagenci := rw_crapris.cdagenci;
      vr_tab_cratorc(rw_crapris.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapris.cdagenci).vr_vllanmto, 0) + vr_vlstotal;
      vr_vltotorc := vr_vltotorc + vr_vlstotal;
    end loop;
    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := false; -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',1662,';
    vr_dshstorc := '"(crps249) FINANCIAMENTOS REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := false; -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',1662,';
    vr_dshstorc := '"(crps249) REVERSAO DOS FINANCIAMENTOS REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    -- Saldo Financiamentos
    if vr_vltotorc > 0 then
      vr_linhadet := '99'||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '1662,'||
                     '1621,'||
                     trim(to_char(vr_vltotorc, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) SALDO FINANCIAMENTOS."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_vltotorc, '99999999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      -- Reversão
      vr_linhadet := '99'||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtopr,'ddmmyy'))||','||
                     '1621,'||
                     '1662,'||
                     trim(to_char(vr_vltotorc, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) REVERSAO SALDO FINANCIAMENTOS."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_vltotorc, '99999999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;

    /* Emprestimo - PREFIXADO .............................................. */
    pc_cria_agencia_pltable(999,5);
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
    FOR rw_crapris in cr_crapris (pr_cdcooper,
                                  vr_dtultdia,
                                  3,
                                  299,
                                  1) LOOP
      vr_vlstotal := 0;
      -- Percorrer vencimentos do risco
      FOR rw_crapvri IN cr_crapvri (rw_crapris.cdcooper,
                                    rw_crapris.nrdconta,
                                    rw_crapris.dtrefere,
                                    rw_crapris.innivris,
                                    rw_crapris.cdmodali,
                                    rw_crapris.nrctremp,
                                    rw_crapris.nrseqctr) loop
        IF rw_crapvri.cdvencto BETWEEN 110 AND 290 THEN
          vr_vlstotal := vr_vlstotal + rw_crapvri.vldivida;
        END IF;
      END LOOP;
      --
      pc_cria_agencia_pltable(rw_crapris.cdagenci,5);
      -- Incluir nome do módulo logado
      gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
      -- Separando as informacoes por agencia e tipo de pessoa
      IF rw_crapris.inpessoa = 1 THEN
         vr_arq_op_cred(5)(rw_crapris.cdagenci)(1) := vr_arq_op_cred(5)(rw_crapris.cdagenci)(1) + vr_vlstotal;
         vr_arq_op_cred(5)(999)(1) := vr_arq_op_cred(5)(999)(1) + vr_vlstotal;
      ELSE
         vr_arq_op_cred(5)(rw_crapris.cdagenci)(2) := vr_arq_op_cred(5)(rw_crapris.cdagenci)(2) + vr_vlstotal;
         vr_arq_op_cred(5)(999)(2) := vr_arq_op_cred(5)(999)(2) + vr_vlstotal;
      END IF;
      --
      vr_tab_cratorc(rw_crapris.cdagenci).vr_cdagenci := rw_crapris.cdagenci;
      vr_tab_cratorc(rw_crapris.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapris.cdagenci).vr_vllanmto, 0) + vr_vlstotal;
      vr_vltotorc := vr_vltotorc + vr_vlstotal;
    END LOOP;
    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := false; -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',1664,';
    vr_dshstorc := '"(crps249) EMPRESTIMOS PREFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := false; -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',1664,';
    vr_dshstorc := '"(crps249) REVERSAO DOS EMPRESTIMOS PREFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;

    /* Financiamentos - PREFIXADO .............................................. */
    pc_cria_agencia_pltable(999,6);
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
    -- Percorrer vencimentos do risco
    FOR rw_crapris in cr_crapris (pr_cdcooper,
                                  vr_dtultdia,
                                  3,
                                  499,
                                  1) LOOP

      -- Se for modalidade 0499, deve desprezar contratos do BNDES
      OPEN  cr_crapebn(rw_crapris.cdcooper, rw_crapris.nrdconta, rw_crapris.nrctremp);
      FETCH cr_crapebn INTO vr_incrapebn;
      -- Se retorna algum registro
      IF cr_crapebn%FOUND THEN
        CLOSE cr_crapebn;
        CONTINUE;  /* Despreza contratos do BNDES */
      END IF;
      IF cr_crapebn%ISOPEN THEN
        CLOSE cr_crapebn;
      END IF;

      vr_vlstotal := 0;
      -- Percorrer vencimentos do risco
      FOR rw_crapvri IN cr_crapvri (rw_crapris.cdcooper,
                                    rw_crapris.nrdconta,
                                    rw_crapris.dtrefere,
                                    rw_crapris.innivris,
                                    rw_crapris.cdmodali,
                                    rw_crapris.nrctremp,
                                    rw_crapris.nrseqctr) loop
        IF rw_crapvri.cdvencto BETWEEN 110 AND 290 THEN
          vr_vlstotal := vr_vlstotal + rw_crapvri.vldivida;
        END IF;
      END LOOP;
      pc_cria_agencia_pltable(rw_crapris.cdagenci,6);
      -- Incluir nome do módulo logado
      gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
      -- Separando as informacoes por agencia e tipo de pessoa
      IF rw_crapris.inpessoa = 1 THEN
         vr_arq_op_cred(6)(rw_crapris.cdagenci)(1) := vr_arq_op_cred(6)(rw_crapris.cdagenci)(1) + vr_vlstotal;
         vr_arq_op_cred(6)(999)(1) := vr_arq_op_cred(6)(999)(1) + vr_vlstotal;
      ELSE
         vr_arq_op_cred(6)(rw_crapris.cdagenci)(2) := vr_arq_op_cred(6)(rw_crapris.cdagenci)(2) + vr_vlstotal;
         vr_arq_op_cred(6)(999)(2) := vr_arq_op_cred(6)(999)(2) + vr_vlstotal;
      END IF;
      --
      vr_tab_cratorc(rw_crapris.cdagenci).vr_cdagenci := rw_crapris.cdagenci;
      vr_tab_cratorc(rw_crapris.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapris.cdagenci).vr_vllanmto, 0) + vr_vlstotal;
      vr_vltotorc := vr_vltotorc + vr_vlstotal;
    END LOOP;
    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := false; -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',1667,';
    vr_dshstorc := '"(crps249) FINANCIAMENTOS PREFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := false; -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',1667,';
    vr_dshstorc := '"(crps249) REVERSAO DOS FINANCIAMENTOS PREFIXADO REALIZADOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;

    -- Sobras de emprestimos ...............................................
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
    -- Percorrer lancamentos em emprestimos. (D-08)
    for rw_craplem in cr_craplem (pr_cdcooper,
                                  vr_dtmvtolt) loop
      -- Buscar dados do associado
      open cr_crapass (pr_cdcooper,
                       rw_craplem.nrdconta);
        fetch cr_crapass into rw_crapass;
      close cr_crapass;
      --
      vr_tab_cratorc(rw_crapass.cdagenci).vr_cdagenci := rw_crapass.cdagenci;
      vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto, 0) + rw_craplem.vllanmto;
      vr_vltotorc := vr_vltotorc + rw_craplem.vllanmto;
    end loop;
    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := true;  -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',4191,';
    vr_dshstorc := '"(crps249) SOBRAS DE EMPRESTIMOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := true;  -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',4191,';
    vr_dshstorc := '"(crps249) REVERSAO DAS SOBRAS DE EMPRESTIMOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    -- Exclusao de cooperados .............................................
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
    -- Percorrer lancamentos em depositos a vista
    for rw_craplcm3 in cr_craplcm3 (pr_cdcooper,
                                    vr_dtmvtolt) loop
      -- Dados do associado
      open cr_crapass (pr_cdcooper,
                       rw_craplcm3.nrdconta);
        fetch cr_crapass into rw_crapass;
      close cr_crapass;
      --
      vr_tab_cratorc(rw_crapass.cdagenci).vr_cdagenci := rw_crapass.cdagenci;
      vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto, 0) + rw_craplcm3.vllanmto;
      vr_vltotorc := vr_vltotorc + rw_craplcm3.vllanmto;
    end loop;
    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := true;  -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',4113,';
    vr_dshstorc := '"(crps249) DEBITO EXCLUSAO DISPONIVEL."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := true;  -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',4113,';
    vr_dshstorc := '"(crps249) REVERSAO DEBITO EXCLUSAO DISPONIVEL."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    
    -- Procapcred  .............................................
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
    -- Percorrer lancamentos de cotas/capital
    for rw_craplct in cr_craplct (pr_cdcooper,
                                  vr_dtultdma,
                                  vr_dtmvtolt,
                                  930) loop
      open cr_crapass (pr_cdcooper,
                       rw_craplct.nrdconta);
        fetch cr_crapass into rw_crapass;
      close cr_crapass;
      --
      vr_tab_cratorc(rw_crapass.cdagenci).vr_cdagenci := rw_crapass.cdagenci;
      vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto, 0) + rw_craplct.vllanmto;
      vr_vltotorc := vr_vltotorc + rw_craplct.vllanmto;
    end loop;
    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := true;  -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',6114,';
    vr_dshstorc := '"(crps249) PROCAPCRED."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := true;  -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',6114,';
    vr_dshstorc := '"(crps249) REVERSAO PROCAPCRED."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;

    vr_vltotorc := 0;

    -- Saldos em Depositos a Vista para Pessoa Fisica .....................
    for rw_crapass3 in cr_crapass3 (pr_cdcooper,
                                    1) loop

      pc_proc_saldo_dep_vista (pr_cdcooper,
                               rw_crapass3.nrdconta,
                               vr_dtmvtolt,
                               rw_crapass3.cdagenci);

    end loop;
    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := true;  -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',4112,';
    vr_dshstorc := '"(crps249) DEPOSITO A VISTA PESSOA FISICA."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := true;  -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',4112,';
    vr_dshstorc := '"(crps249) REVERSAO DO DEPOSITO A VISTA PESSOA FISICA."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;

    vr_vltotorc := 0;
    vr_tab_cratorc.delete;

    -- Saldos em Depositos a Vista para Pessoa Juridica ...................
    for rw_crapass3 in cr_crapass3 (pr_cdcooper,
                                    2) loop
      pc_proc_saldo_dep_vista (pr_cdcooper,
                               rw_crapass3.nrdconta,
                               vr_dtmvtolt,
                               rw_crapass3.cdagenci);
    end loop;
    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := true;  -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',4120,';
    vr_dshstorc := '"(crps249) DEPOSITO A VISTA PESSOA JURIDICA."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := true;  -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',4120,';
    vr_dshstorc := '"(crps249) REVERSAO DO DEPOSITO A VISTA PESSOA JURIDICA."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    -- Saldos em Contas Investimento .......................................
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
    for rw_crapsli in cr_crapsli (pr_cdcooper,
                                  vr_dtultdia) loop
      open cr_crapass (pr_cdcooper,
                       rw_crapsli.nrdconta);
        fetch cr_crapass into rw_crapass;
      close cr_crapass;
      --
      vr_tab_cratorc(rw_crapass.cdagenci).vr_cdagenci := rw_crapass.cdagenci;
      vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto, 0) + rw_crapsli.vlsddisp;
      vr_vltotorc := vr_vltotorc + rw_crapsli.vlsddisp;
    end loop;
    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := true;  -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',4292,';
    vr_dshstorc := '"(crps249) CONTA INVESTIMENTO."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := true;  -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',4292,';
    vr_dshstorc := '"(crps249) REVERSAO DA CONTA INVESTIMENTO."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    -- Desconto de Cheques .................................................
    pc_cria_agencia_pltable(999,2);
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
    for rw_crapcdb4 in cr_crapcdb4 (pr_cdcooper => pr_cdcooper,
                                    pr_dtmvtolt => vr_dtmvtolt,
                                    pr_dtmvtopr => vr_dtmvtopr
                                    ) loop
      open cr_crapass (pr_cdcooper,
                       rw_crapcdb4.nrdconta);
        fetch cr_crapass into rw_crapass;
      close cr_crapass;
      --
      pc_cria_agencia_pltable(rw_crapass.cdagenci,2);
      -- Incluir nome do módulo logado
      gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
      -- Separando as informacoes por agencia e tipo de pessoa
      IF rw_crapass.inpessoa = 1 THEN
         vr_arq_op_cred(2)(rw_crapass.cdagenci)(1) := vr_arq_op_cred(2)(rw_crapass.cdagenci)(1) + rw_crapcdb4.vlcheque;
         vr_arq_op_cred(2)(999)(1) := vr_arq_op_cred(2)(999)(1) + rw_crapcdb4.vlcheque;
      ELSE
         vr_arq_op_cred(2)(rw_crapass.cdagenci)(2) := vr_arq_op_cred(2)(rw_crapass.cdagenci)(2) + rw_crapcdb4.vlcheque;
         vr_arq_op_cred(2)(999)(2) := vr_arq_op_cred(2)(999)(2) + rw_crapcdb4.vlcheque;
      END IF;
      --
      vr_tab_cratorc(rw_crapass.cdagenci).vr_cdagenci := rw_crapass.cdagenci;
      vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto, 0) + rw_crapcdb4.vlcheque;
      vr_vltotorc := vr_vltotorc + rw_crapcdb4.vlcheque;
    end loop;
    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := false; -- Conta do ATIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',1641,';
    vr_dshstorc := '"(crps249) DESCONTO DE CHEQUE."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := false; -- Conta do ATIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',1641,';
    vr_dshstorc := '"(crps249) REVERSAO DO DESCONTO DE CHEQUES."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    -- Provisao de Receita com Desconto de Cheques .........................
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
    -- Percorre os lancamentos de juros de desconto de cheques
    for rw_crapljd2 in cr_crapljd2 (pr_cdcooper,
                                    vr_dtultdia) loop
      open cr_crapass (pr_cdcooper,
                       rw_crapljd2.nrdconta);
        fetch cr_crapass into rw_crapass;
      close cr_crapass;
      --
      vr_tab_cratorc(rw_crapass.cdagenci).vr_cdagenci := rw_crapass.cdagenci;
      vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto, 0) + rw_crapljd2.vldjuros;
      vr_vltotorc := vr_vltotorc + rw_crapljd2.vldjuros;
    end loop;
    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := false; -- Conta do ATIVO
    vr_flgctred := true;  -- Redutora
    vr_lsctaorc := ',1642,';
    vr_dshstorc := '"(crps249) RECEITA DE DESCONTO DE CHEQUE."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := false; -- Conta do ATIVO
    vr_flgctred := true;  -- Redutora
    vr_lsctaorc := ',1642,';
    vr_dshstorc := '"(crps249) REVERSAO DA RECEITA DE DESCONTO DE CHEQUE."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    -- RECEITA DE DESCONTO DE CHEQUE -- Dados para contabilidade
    -- Inicializa a Pl-Table
    vr_arq_op_cred(7)(999)(1) := 0; 
    vr_arq_op_cred(7)(999)(2) := 0;
    FOR rw_crapljd_age IN cr_crapljd_age(pr_cdcooper,
                                         vr_dtultdia) LOOP
       vr_arq_op_cred(7)(rw_crapljd_age.cdagenci)(rw_crapljd_age.inpessoa) := rw_crapljd_age.vldjuros;
       vr_arq_op_cred(7)(999)(rw_crapljd_age.inpessoa) := vr_arq_op_cred(7)(999)(rw_crapljd_age.inpessoa) + rw_crapljd_age.vldjuros;
    END LOOP;                                        
    -- Desconto de Titulos .................................................
    for rw_craptdb7 in cr_craptdb7 (pr_cdcooper,
                                    4) loop
      if to_char(vr_dtmvtolt, 'mm') <> to_char(vr_dtmvtopr, 'mm') then
        -- Alteracao tarefa 34547 (Henrique)
        -- Verifica se é o ultimo dia do mes
        if rw_craptdb7.dtvencto < vr_dtmvtolt + 90 then
          vr_indice := 1;
        elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 180 then
          vr_indice := 2;
        elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 270 then
          vr_indice := 3;
        elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 360 then
          vr_indice := 4;
        elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 720 then
          vr_indice := 5;
        elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 1080 then
          vr_indice := 6;
        elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 1440 then
          vr_indice := 7;
        elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 1800 then
          vr_indice := 8;
        elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 2160 then
          vr_indice := 9;
        elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 2520 then
          vr_indice := 10;
        elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 2880 then
          vr_indice := 11;
        elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 3240 then
          vr_indice := 12;
        elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 3600 then
          vr_indice := 13;
        elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 3960 then
          vr_indice := 14;
        elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 4320 then
          vr_indice := 15;
        elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 4680 then
          vr_indice := 16;
        elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 5040 then
          vr_indice := 17;
        elsif rw_craptdb7.dtvencto < vr_dtmvtolt + 5400 then
          vr_indice := 18;
        elsif rw_craptdb7.dtvencto >= vr_dtmvtolt + 5400 then
          vr_indice := 19;
        end if;
        -- Acumula de acordo com o índice
        if not vr_tab_acumltit.exists(vr_indice) then
          vr_tab_acumltit(vr_indice).vr_vltitulo := 0;
        end if;
        vr_tab_acumltit(vr_indice).vr_vltitulo := vr_tab_acumltit(vr_indice).vr_vltitulo + rw_craptdb7.vltitulo;
      end if;
    end loop;
    -- Leitura dos valores acumulados para incluir na crapprb
    vr_indice := vr_tab_acumltit.first;
    while vr_indice <= 19 loop
      if vr_tab_acumltit(vr_indice).vr_vltitulo > 0 then
        pc_proc_insere_crapprb(vr_dtmvtolt,
                            vr_indice,
                            vr_tab_acumltit(vr_indice).vr_vltitulo);
      end if;
      vr_indice := vr_tab_acumltit.next(vr_indice);
    end loop;
    -- Desconto de título sem registro
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
    for rw_craptdb8 in cr_craptdb8 (pr_cdcooper,
                                    4,
                                    0) loop
      vr_tab_cratorc(rw_craptdb8.cdagenci).vr_cdagenci := rw_craptdb8.cdagenci;
      vr_tab_cratorc(rw_craptdb8.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_craptdb8.cdagenci).vr_vllanmto, 0) + rw_craptdb8.vltitulo;
      vr_vltotorc := vr_vltotorc + rw_craptdb8.vltitulo;
    end loop;
    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := false; -- Conta do ATIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',1643,';
    vr_dshstorc := '"(crps249) DESCONTO DE TITULO S/ REGISTRO."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := false; -- Conta do ATIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',1643,';
    vr_dshstorc := '"(crps249) REVERSAO DO DESCONTO DE TITULOS S/ REGISTRO."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    -- DESCONTO DE TITULO S/ REGISTRO - Dados para contabilidade
    -- Inicializando a Pl-Table
    vr_arq_op_cred(8)(999)(1) := 0;
    vr_arq_op_cred(8)(999)(2) := 0;
    FOR rw_craptdb_age IN cr_craptdb_age(pr_cdcooper
                                        ,4
                                        ,0) LOOP
       vr_arq_op_cred(8)(rw_craptdb_age.cdagenci)(rw_craptdb_age.inpessoa) := rw_craptdb_age.vltitulo;
       vr_arq_op_cred(8)(999)(rw_craptdb_age.inpessoa) := vr_arq_op_cred(8)(999)(rw_craptdb_age.inpessoa) + rw_craptdb_age.vltitulo;
    END LOOP;    
    -- Desconto de título com registro
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
    for rw_craptdb8 in cr_craptdb8 (pr_cdcooper,
                                    4,
                                    1) loop
      vr_tab_cratorc(rw_craptdb8.cdagenci).vr_cdagenci := rw_craptdb8.cdagenci;
      vr_tab_cratorc(rw_craptdb8.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_craptdb8.cdagenci).vr_vllanmto, 0) + rw_craptdb8.vltitulo;
      vr_vltotorc := vr_vltotorc + rw_craptdb8.vltitulo;
    end loop;
    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := false; -- Conta do ATIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',1645,';
    vr_dshstorc := '"(crps249) DESCONTO DE TITULO C/ REGISTRO."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := false; -- Conta do ATIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',1645,';
    vr_dshstorc := '"(crps249) REVERSAO DO DESCONTO DE TITULOS C/ REGISTRO."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    -- DESCONTO DE TITULO C/ REGISTRO - Dados para contabilidade
    -- Inicializando a Pl-Table
    vr_arq_op_cred(9)(999)(1) := 0;
    vr_arq_op_cred(9)(999)(2) := 0;
    FOR rw_craptdb_age IN cr_craptdb_age(pr_cdcooper
                                        ,4
                                        ,1) LOOP
       vr_arq_op_cred(9)(rw_craptdb_age.cdagenci)(rw_craptdb_age.inpessoa) := rw_craptdb_age.vltitulo;
       vr_arq_op_cred(9)(999)(rw_craptdb_age.inpessoa) := vr_arq_op_cred(9)(999)(rw_craptdb_age.inpessoa) + rw_craptdb_age.vltitulo;
    END LOOP;     
    -- Provisao de Receita com Desconto de Titulos com registro ............
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
    for rw_crapljt2 in cr_crapljt2 (pr_cdcooper,
                                    vr_dtultdia,
                                    0) loop
      open cr_crapass (pr_cdcooper,
                       rw_crapljt2.nrdconta);
        fetch cr_crapass into rw_crapass;
      close cr_crapass;
      --
      vr_tab_cratorc(rw_crapass.cdagenci).vr_cdagenci := rw_crapass.cdagenci;
      vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto, 0) + rw_crapljt2.vldjuros;
      vr_vltotorc := vr_vltotorc + rw_crapljt2.vldjuros;
    end loop;
    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := false; -- Conta do ATIVO
    vr_flgctred := true;  -- Redutora
    vr_lsctaorc := ',1644,';
    vr_dshstorc := '"(crps249) RENDA DE DESCONTO DE TITULO S/ REGISTRO."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := false; -- Conta do ATIVO
    vr_flgctred := true;  -- Redutora
    vr_lsctaorc := ',1644,';
    vr_dshstorc := '"(crps249) REVERSAO DA RENDA DE DESCONTO DE TITULO S/ REGISTRO."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    -- Separacao por agencia e por tipo de pessoa -- Dados para contabilidade
    -- Inicializando a Pl-Table
    vr_arq_op_cred(10)(999)(1) := 0;
    vr_arq_op_cred(10)(999)(2) := 0;    
    FOR rw_crapljt_age IN cr_crapljt_age(pr_cdcooper,
                                         vr_dtultdia,
                                         0) LOOP
       -- 10 - RENDA DE DESCONTO DE TITULO S/ REGISTRO
       vr_arq_op_cred(10)(rw_crapljt_age.cdagenci)(rw_crapljt_age.inpessoa) := rw_crapljt_age.vldjuros;
       vr_arq_op_cred(10)(999)(rw_crapljt_age.inpessoa) := vr_arq_op_cred(10)(999)(rw_crapljt_age.inpessoa) + rw_crapljt_age.vldjuros;
    END LOOP;    
    -- Provisao de Receita com Desconto de Titulos .........................
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
    for rw_crapljt2 in cr_crapljt2 (pr_cdcooper,
                                    vr_dtultdia,
                                    1) loop
      open cr_crapass (pr_cdcooper,
                       rw_crapljt2.nrdconta);
        fetch cr_crapass into rw_crapass;
      close cr_crapass;
      --
      vr_tab_cratorc(rw_crapass.cdagenci).vr_cdagenci := rw_crapass.cdagenci;
      vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto, 0) + rw_crapljt2.vldjuros;
      vr_vltotorc := vr_vltotorc + rw_crapljt2.vldjuros;
    end loop;
    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := false; -- Conta do ATIVO
    vr_flgctred := true;  -- Redutora
    vr_lsctaorc := ',1646,';
    vr_dshstorc := '"(crps249) RENDA DE DESCONTO DE TITULO C/ REGISTRO."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento; 
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := false; -- Conta do ATIVO
    vr_flgctred := true;  -- Redutora
    vr_lsctaorc := ',1646,';
    vr_dshstorc := '"(crps249) REVERSAO DA RENDA DE DESCONTO DE TITULO C/ REGISTRO."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    -- Separacao por agencia e por tipo de pessoa -- Dados para contabilidade
    -- Inicializando a Pl-Table
    vr_arq_op_cred(11)(999)(1) := 0;
    vr_arq_op_cred(11)(999)(2) := 0;    
    FOR rw_crapljt_age IN cr_crapljt_age(pr_cdcooper,
                                         vr_dtultdia,
                                         1) LOOP
       -- 11 - RENDA DE DESCONTO DE TITULO S/ REGISTRO
       vr_arq_op_cred(11)(rw_crapljt_age.cdagenci)(rw_crapljt_age.inpessoa) := rw_crapljt_age.vldjuros;
       vr_arq_op_cred(11)(999)(rw_crapljt_age.inpessoa) := vr_arq_op_cred(11)(999)(rw_crapljt_age.inpessoa) + rw_crapljt_age.vldjuros;
    END LOOP;    
    -- Aplicacao RDCA30 ....................................................
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;

    --Junção cursores cr_craprda e cr_crapass - Chamado 734422, utilização bulk collection
    open cr_craprda(pr_cdcooper
                   ,3);
    loop
      --joga dados do cursor na variável de 5000 em 5000
      fetch cr_craprda bulk collect into rw_craprda limit 5000;

      --para cada linha de retorno na variável indexada de 5000 em 5000, faz os cálculos
      for i in 1..rw_craprda.count loop
        --guarda o indexador em variável para ficar mais claro
        vr_cdagenci_index := rw_craprda(i).cdagenci;
      --
        vr_tab_cratorc(vr_cdagenci_index).vr_cdagenci := vr_cdagenci_index;
        vr_tab_cratorc(vr_cdagenci_index).vr_vllanmto := nvl(vr_tab_cratorc(vr_cdagenci_index).vr_vllanmto, 0) + rw_craprda(i).vlslfmes;
        vr_vltotorc := vr_vltotorc + rw_craprda(i).vlslfmes;
    end loop;
      exit when cr_craprda%rowcount <= 5000;
    end loop;
    close cr_craprda;
    --
    
    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := true;  -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',4232,';
    vr_dshstorc := '"(crps249) DEPOSITOS RDCA30."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := true;  -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',4232,';
    vr_dshstorc := '"(crps249) REVERSAO DOS DEPOSITOS RDCA30."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    -- Aplicacao RDCA60 ....................................................
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;

    --Junção cursores cr_craprda e cr_crapass - Chamado 734422, utilização bulk collection
    open cr_craprda(pr_cdcooper
                   ,5);
    loop
      --joga dados do cursor na variável de 5000 em 5000
      fetch cr_craprda bulk collect into rw_craprda limit 5000;

      --para cada linha de retorno na variável indexada de 5000 em 5000, faz os cálculos
      for i in 1..rw_craprda.count loop
        --guarda o indexador em variável para ficar mais claro
        vr_cdagenci_index := rw_craprda(i).cdagenci;
      --
        vr_tab_cratorc(vr_cdagenci_index).vr_cdagenci := vr_cdagenci_index;
        vr_tab_cratorc(vr_cdagenci_index).vr_vllanmto := nvl(vr_tab_cratorc(vr_cdagenci_index).vr_vllanmto, 0) + rw_craprda(i).vlslfmes;
        vr_vltotorc := vr_vltotorc + rw_craprda(i).vlslfmes;
    end loop;
      exit when cr_craprda%rowcount <= 5000;
    end loop;
    close cr_craprda;
    --
    
    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := true;  -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',4237,';
    vr_dshstorc := '"(crps249) DEPOSITOS RDCA60."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := true;  -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',4237,';
    vr_dshstorc := '"(crps249) REVERSAO DOS DEPOSITOS RDCA60."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    -- Aplicacao RDCPRE ....................................................
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
    
    --Junção cursores cr_craprda e cr_crapass - Chamado 734422, utilização bulk collection
    open cr_craprda(pr_cdcooper
                   ,7);
    loop
      --joga dados do cursor na variável de 5000 em 5000
      fetch cr_craprda bulk collect into rw_craprda limit 5000;
 
      --para cada linha de retorno na variável indexada de 5000 em 5000, faz os cálculos
      for i in 1..rw_craprda.count loop
        --guarda o indexador em variável para ficar mais claro
        vr_cdagenci_index := rw_craprda(i).cdagenci;
      --
        vr_tab_cratorc(vr_cdagenci_index).vr_cdagenci := vr_cdagenci_index;
        vr_tab_cratorc(vr_cdagenci_index).vr_vllanmto := nvl(vr_tab_cratorc(vr_cdagenci_index).vr_vllanmto, 0) + rw_craprda(i).vlslfmes;
        vr_vltotorc := vr_vltotorc + rw_craprda(i).vlslfmes;
    end loop;
      exit when cr_craprda%rowcount <= 5000;
    end loop;
    close cr_craprda;
    --

    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := true;  -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',4253,';
    vr_dshstorc := '"(crps249) DEPOSITOS RDCPRE."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := true;  -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',4253,';
    vr_dshstorc := '"(crps249) REVERSAO DOS DEPOSITOS RDCPRE."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    -- Magui, no mensal precisamos limpar os campos craprda.vlslfmes de
    -- aplicacoes finalizadas pelo crps495 e craps481. Nao podemos zerar
    -- la quando e o ultimo dia do mes porque senao da erro no orcado por
    -- Pac
    begin
      update craprda
         set craprda.dtsdfmes = null,
             craprda.vlslfmes = 0
       where craprda.cdcooper = pr_cdcooper
         and craprda.tpaplica = 7
         and craprda.insaqtot = 1
         and craprda.vlslfmes <> 0;
    exception
      when others then
        --Inclusão na tabela de erros Oracle - Chamado 734422
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);                                                             
        vr_cdcritic := 1035;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' craprda para RDCPRE.'||
                       ' dtsdfmes = NULL, vlslfmes:0 com cdcooper:'||pr_cdcooper||
                       ', tpaplica:7, insaqtot:1, vlslfmes <> 0. '||sqlerrm;
        raise vr_exc_saida;
    end;
    -- Aplicacao RDCPOS ....................................................
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
    
    --Junção cursores cr_craprda e cr_crapass - Chamado 734422, utilização bulk collection
    open cr_craprda(pr_cdcooper
                   ,8);
    loop
      --joga dados do cursor na variável de 5000 em 5000
      fetch cr_craprda bulk collect into rw_craprda limit 5000;
 
      --para cada linha de retorno na variável indexada de 5000 em 5000, faz os cálculos
      for i in 1..rw_craprda.count loop
        --guarda o indexador em variável para ficar mais claro
        vr_cdagenci_index := rw_craprda(i).cdagenci;
      --
        vr_tab_cratorc(vr_cdagenci_index).vr_cdagenci := vr_cdagenci_index;
        vr_tab_cratorc(vr_cdagenci_index).vr_vllanmto := nvl(vr_tab_cratorc(vr_cdagenci_index).vr_vllanmto, 0) + rw_craprda(i).vlslfmes;
        vr_vltotorc := vr_vltotorc + rw_craprda(i).vlslfmes;
    end loop;
      exit when cr_craprda%rowcount <= 5000;
    end loop;
    close cr_craprda;
    --
    
    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := true;  -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',4254,';
    vr_dshstorc := '"(crps249) DEPOSITOS RDCPOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := true;  -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',4254,';
    vr_dshstorc := '"(crps249) REVERSAO DOS DEPOSITOS RDCPOS."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    -- Magui, no mensal precisamos limpar os campos craprda.vlslfmes de
    -- aplicacoes finalizadas pelo crps495 e craps481. Nao podemos zerar
    -- la quando e o ultimo dia do mes porque senao da erro no orcado por
    -- Pac
    BEGIN
      UPDATE craprda
         SET craprda.dtsdfmes = null,
             craprda.vlslfmes = 0
       WHERE craprda.cdcooper = pr_cdcooper
         AND craprda.tpaplica = 8
         AND craprda.insaqtot = 1
         AND craprda.vlslfmes <> 0;
    EXCEPTION
      WHEN OTHERS THEN
        --Inclusão na tabela de erros Oracle - Chamado 734422
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);                                                             
        vr_cdcritic := 1035;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' craprda para RDCPOS.'||
                       ' dtsdfmes = NULL, vlslfmes:0 com cdcooper:'||pr_cdcooper||
                       ', tpaplica:8, insaqtot:1, vlslfmes <> 0. '||sqlerrm;
        RAISE vr_exc_saida;
    END;
    -- Poupança Programada .................................................
    vr_tab_cratorc.delete;
    vr_vltotorc := 0;
    for rw_craprpp in cr_craprpp (pr_cdcooper,
                                  vr_dtmvtolt) loop
      open cr_crapass (pr_cdcooper,
                       rw_craprpp.nrdconta);
        fetch cr_crapass into rw_crapass;
      close cr_crapass;
      --
      vr_tab_cratorc(rw_crapass.cdagenci).vr_cdagenci := rw_crapass.cdagenci;
      vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto, 0) + rw_craprpp.vlslfmes;
      vr_vltotorc := vr_vltotorc + rw_craprpp.vlslfmes;
    end loop;
    --
    vr_flgrvorc := false; -- Lancamento do dia
    vr_flgctpas := true;  -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',4257,';
    vr_dshstorc := '"(crps249) DEPOSITOS POUPANCA PROGRAMADA."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
    vr_flgrvorc := true;  -- Lancamento de reversao
    vr_flgctpas := true;  -- Conta do PASSIVO
    vr_flgctred := false; -- Normal
    vr_lsctaorc := ',4257,';
    vr_dshstorc := '"(crps249) REVERSAO DOS DEPOSITOS POUPANCA PROGRAMADA."';
    vr_dshcporc := ',5210,';
    pc_proc_lista_orcamento;
    --
   
    -- Aplicacoes Novos Produtos de Captacao ...............................
    FOR rw_crapcpc in cr_crapcpc LOOP
      vr_tab_cratorc.delete;
      vr_vltotorc := 0; 

      -- Percorrer novas aplicacoes.
      FOR rw_craprac in cr_craprac(pr_cdcooper, rw_crapcpc.cdprodut) LOOP       
      
        OPEN cr_crapass (pr_cdcooper,rw_craprac.nrdconta);
        FETCH cr_crapass into rw_crapass;
        CLOSE cr_crapass;
        --
        vr_tab_cratorc(rw_crapass.cdagenci).vr_cdagenci := rw_crapass.cdagenci;
        vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto := nvl(vr_tab_cratorc(rw_crapass.cdagenci).vr_vllanmto, 0) + rw_craprac.vlslfmes;
        vr_vltotorc := vr_vltotorc + rw_craprac.vlslfmes;
        --
        OPEN  cr_craphis2(pr_cdcooper, rw_crapcpc.cdhsnrap);
        FETCH cr_craphis2 INTO rw_craphis2;
        IF cr_craphis2%FOUND THEN
           vr_nrctacre := rw_craphis2.nrctacrd;
        END IF;
        CLOSE cr_craphis2;
        
        -- Após o sistema registrar os valores de orçamento dos novos produtos de captação,
        -- seta o campo idcalorc para 1
        IF rw_craprac.idsaqtot > 0 THEN
          BEGIN
            UPDATE craprac
               SET craprac.idcalorc = 1
             WHERE craprac.cdcooper = pr_cdcooper
               AND craprac.nrdconta = rw_craprac.nrdconta
               AND craprac.nraplica = rw_craprac.nraplica;
          EXCEPTION
            WHEN OTHERS THEN
              --Inclusão na tabela de erros Oracle - Chamado 734422
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);                                                             
              vr_cdcritic := 1035;
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' craprac para '||rw_crapcpc.nmprodut||
                             ', idcalorc:1 com cdcooper:'||pr_cdcooper||', nrdconta:'||rw_craprac.nrdconta||
                             ', tpaplica:'||rw_craprac.nraplica||'. '||sqlerrm;

              RAISE vr_exc_saida;
          END;
        END IF;  
      END LOOP;     

      --
      vr_flgrvorc := false; -- Lancamento do dia
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',' || Lpad(vr_nrctacre,4,'0') || ',';
      vr_dshstorc := '"(crps249) DEPOSITOS ' || rw_crapcpc.nmprodut || '."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;
      --
      vr_flgrvorc := true;  -- Lancamento de reversao
      vr_flgctpas := true;  -- Conta do PASSIVO
      vr_flgctred := false; -- Normal
      vr_lsctaorc := ',' || Lpad(vr_nrctacre,4,'0') || ',';
      vr_dshstorc := '"(crps249) REVERSAO DOS DEPOSITOS ' || rw_crapcpc.nmprodut || '."';
      vr_dshcporc := ',5210,';
      pc_proc_lista_orcamento;  
      --
    END LOOP;
    
    --
    -- Contabilizacao para orcamento (Realizado)............................
    vr_cdcritic := 0;
    btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                              ,pr_ind_tipo_log  => 1 -- Informação
                              ,pr_nmarqlog      => 'proc_batch.log'
                              ,pr_tpexecucao    => 1 -- Job
                              ,pr_cdcriticidade => 0 -- Baixa
                              ,pr_cdmensagem    => vr_cdcritic
                              ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                  || vr_cdprogra || ' --> '
                                                  || 'Final da contabilizacao para o orcamento (realizado)');
  end;

  -- Geracao de Arquivo AAMMDD_OP_CRED.txt - Processo mensal
  PROCEDURE pc_gera_arq_op_cred (pr_dscritic OUT VARCHAR2) IS

     -- Variaveis
     vr_input_file     UTL_FILE.file_type;             --> Handle Utl File
     vr_setlinha       VARCHAR2(400);                  --> Linhas do arquivo
     vr_index          NUMBER := 0;
     vr_descricao      VARCHAR2(400); 
     vr_nrctaori       NUMBER; 
     vr_nrctades       NUMBER;      
     
     -- Constantes
     vr_dsprefix CONSTANT VARCHAR(20) := 'REVERSAO ';  --> Utilizado para o caso de reversao de contas

     -- Variavel de Exception
     vr_exc_erro EXCEPTION;
     
     
     -- Inicializa tabela de Historicos
     PROCEDURE pc_inicia_historico IS
     BEGIN
        -- Inclusão do módulo e ação logado - Chamado 734422 - 03/11/2017
        GENE0001.pc_set_modulo(pr_module => 'PC_CRPS249.pc_inicia_historico', pr_action => NULL);
        vr_tab_historico.DELETE;

        -- removido do trecho fixo de código para tabela de memoria
        vr_tab_historico(0098).nrctaori_fis := 7141;
        vr_tab_historico(0098).nrctades_fis := 7026;
        vr_tab_historico(0098).dsrefere_fis := 'JUROS SOBRE FINANCIAMENTOS - PESSOA FISICA';
        vr_tab_historico(0098).nrctaori_jur := 7141;
        vr_tab_historico(0098).nrctades_jur := 7027;
        vr_tab_historico(0098).dsrefere_jur := 'JUROS SOBRE FINANCIAMENTOS - PESSOA JURIDICA';

        -- removido do trecho fixo de código para tabela de memoria
        vr_tab_historico(0277).nrctaori_fis := 7026;
        vr_tab_historico(0277).nrctades_fis := 7141;
        vr_tab_historico(0277).dsrefere_fis := 'ESTORNO DE JUROS S/EMPRESTIMOS - PESSOA FISICA';
        vr_tab_historico(0277).nrctaori_jur := 7027;
        vr_tab_historico(0277).nrctades_jur := 7141;
        vr_tab_historico(0277).dsrefere_jur := 'ESTORNO DE JUROS S/EMPRESTIMOS - PESSOA JURIDICA';

        vr_tab_historico(0441).nrctaori_fis := 7116;
        vr_tab_historico(0441).nrctades_fis := 7010;
        vr_tab_historico(0441).dsrefere_fis := 'JUROS SOBRE EMPRESTIMOS EM ATRASO - PESSOA FISICA';
        vr_tab_historico(0441).nrctaori_jur := 7116;
        vr_tab_historico(0441).nrctades_jur := 7011;
        vr_tab_historico(0441).dsrefere_jur := 'JUROS SOBRE EMPRESTIMOS EM ATRASO - PESSOA JURIDICA';

        vr_tab_historico(0443).nrctaori_fis := 7116;
        vr_tab_historico(0443).nrctades_fis := 7010;
        vr_tab_historico(0443).dsrefere_fis := 'MULTA SOBRE EMPRESTIMOS EM ATRASO - PESSOA FISICA';
        vr_tab_historico(0443).nrctaori_jur := 7116;
        vr_tab_historico(0443).nrctades_jur := 7011;
        vr_tab_historico(0443).dsrefere_jur := 'MULTA SOBRE EMPRESTIMOS EM ATRASO - PESSOA JURIDICA';

        vr_tab_historico(1037).nrctaori_fis := 7122;
        vr_tab_historico(1037).nrctades_fis := 7016;
        vr_tab_historico(1037).dsrefere_fis := 'APROPRIACAO JUROS CONTRATO EMPR. TX. PRE-FIXADA - PESSOA FISICA';
        vr_tab_historico(1037).nrctaori_jur := 7122;
        vr_tab_historico(1037).nrctades_jur := 7017;
        vr_tab_historico(1037).dsrefere_jur := 'APROPRIACAO JUROS CONTRATO EMPR. TX. PRE-FIXADA - PESSOA JURIDICA';

        vr_tab_historico(1040).nrctaori_fis := 7122;
        vr_tab_historico(1040).nrctades_fis := 7016;
        vr_tab_historico(1040).dsrefere_fis := 'AJUSTE DB. JUROS CONTRATO EMPR. TX. PRE-FIXADA - PESSOA FISICA';
        vr_tab_historico(1040).nrctaori_jur := 7122;
        vr_tab_historico(1040).nrctades_jur := 7017;
        vr_tab_historico(1040).dsrefere_jur := 'AJUSTE DB. JUROS CONTRATO EMPR. TX. PRE-FIXADA - PESSOA JURIDICA';

        vr_tab_historico(1041).nrctaori_fis := 7016;
        vr_tab_historico(1041).nrctades_fis := 7122;
        vr_tab_historico(1041).dsrefere_fis := 'AJUSTE CR. JUROS CONTRATO EMPR. TX. PRE-FIXADA - PESSOA FISICA';
        vr_tab_historico(1041).nrctaori_jur := 7017;
        vr_tab_historico(1041).nrctades_jur := 7122;
        vr_tab_historico(1041).dsrefere_jur := 'AJUSTE CR. JUROS CONTRATO EMPR. TX. PRE-FIXADA - PESSOA JURIDICA';

        vr_tab_historico(1071).nrctaori_fis := 7123;
        vr_tab_historico(1071).nrctades_fis := 7018;
        vr_tab_historico(1071).dsrefere_fis := 'JUROS DE MORA CONTRATO EMPRESTIMO TX. PRE-FIXADA - PESSOA FISICA';
        vr_tab_historico(1071).nrctaori_jur := 7123;
        vr_tab_historico(1071).nrctades_jur := 7019;
        vr_tab_historico(1071).dsrefere_jur := 'JUROS DE MORA CONTRATO EMPRESTIMO TX. PRE-FIXADA - PESSOA JURIDICA';

        vr_tab_historico(1543).nrctaori_fis := 7123;
        vr_tab_historico(1543).nrctades_fis := 7018;
        vr_tab_historico(1543).dsrefere_fis := 'JURO MORA EMPRESTIMO PRE-FIXADO PAGO PELO AVALISTA - PESSOA FISICA';
        vr_tab_historico(1543).nrctaori_jur := 7123;
        vr_tab_historico(1543).nrctades_jur := 7019;
        vr_tab_historico(1543).dsrefere_jur := 'JURO MORA EMPRESTIMO PRE-FIXADO PAGO PELO AVALISTA - PESSOA JURIDICA';

        vr_tab_historico(1060).nrctaori_fis := 7124;
        vr_tab_historico(1060).nrctades_fis := 7020;
        vr_tab_historico(1060).dsrefere_fis := 'MULTA CONTRATO EMPRESTIMO TX. PRE-FIXADA - PESSOA FISICA';
        vr_tab_historico(1060).nrctaori_jur := 7124;
        vr_tab_historico(1060).nrctades_jur := 7021;
        vr_tab_historico(1060).dsrefere_jur := 'MULTA CONTRATO EMPRESTIMO TX. PRE-FIXADA - PESSOA JURIDICA';

        vr_tab_historico(1541).nrctaori_fis := 7124;
        vr_tab_historico(1541).nrctades_fis := 7020;
        vr_tab_historico(1541).dsrefere_fis := 'MULTA EMPRESTIMO PRE-FIXADO PAGO PELO AVALISTA - PESSOA FISICA';
        vr_tab_historico(1541).nrctaori_jur := 7124;
        vr_tab_historico(1541).nrctades_jur := 7021;
        vr_tab_historico(1541).dsrefere_jur := 'MULTA EMPRESTIMO PRE-FIXADO PAGO PELO AVALISTA - PESSOA JURIDICA';

        vr_tab_historico(0597).nrctaori_fis := 7024;
        vr_tab_historico(0597).nrctades_fis := 7132;
        vr_tab_historico(0597).dsrefere_fis := 'ABATIMENTO DE JUROS DE TITULO DESCONTADO PG ANTEC. - PESSOA FISICA';
        vr_tab_historico(0597).nrctaori_jur := 7025;
        vr_tab_historico(0597).nrctades_jur := 7132;
        vr_tab_historico(0597).dsrefere_jur := 'ABATIMENTO DE JUROS DE TITULO DESCONTADO PG ANTEC. - PESSOA JURIDICA';

        vr_tab_historico(1038).nrctaori_fis := 7135;
        vr_tab_historico(1038).nrctades_fis := 7028;
        vr_tab_historico(1038).dsrefere_fis := 'APROPR.JUROS CONTRATO FINANC. TX. PRE-FIXADA - PESSOA FISICA';
        vr_tab_historico(1038).nrctaori_jur := 7135;
        vr_tab_historico(1038).nrctades_jur := 7029;
        vr_tab_historico(1038).dsrefere_jur := 'APROPR.JUROS CONTRATO FINANC. TX. PRE-FIXADA - PESSOA JURIDICA';

        vr_tab_historico(1042).nrctaori_fis := 7028;
        vr_tab_historico(1042).nrctades_fis := 7135;
        vr_tab_historico(1042).dsrefere_fis := 'AJUSTE CR. JUROS CONTRATO FINANC. TX. PRE-FIXADA - PESSOA FISICA';
        vr_tab_historico(1042).nrctaori_jur := 7029;
        vr_tab_historico(1042).nrctades_jur := 7135;
        vr_tab_historico(1042).dsrefere_jur := 'AJUSTE CR. JUROS CONTRATO FINANC. TX. PRE-FIXADA - PESSOA JURIDICA';

        vr_tab_historico(1043).nrctaori_fis := 7135;
        vr_tab_historico(1043).nrctades_fis := 7028;
        vr_tab_historico(1043).dsrefere_fis := 'AJUSTE DB. JUROS CONTRATO FINANC. TX.PRE-FIXADA - PESSOA FISICA';
        vr_tab_historico(1043).nrctaori_jur := 7135;
        vr_tab_historico(1043).nrctades_jur := 7029;
        vr_tab_historico(1043).dsrefere_jur := 'AJUSTE DB. JUROS CONTRATO FINANC. TX.PRE-FIXADA - PESSOA JURIDICA';

        vr_tab_historico(1072).nrctaori_fis := 7136;
        vr_tab_historico(1072).nrctades_fis := 7030;
        vr_tab_historico(1072).dsrefere_fis := 'JUROS DE MORA CONTRATO FINANCIAMENTO TX.PRE-FIXADA - PESSOA FISICA';
        vr_tab_historico(1072).nrctaori_jur := 7136;
        vr_tab_historico(1072).nrctades_jur := 7031;
        vr_tab_historico(1072).dsrefere_jur := 'JUROS DE MORA CONTRATO FINANCIAMENTO TX.PRE-FIXADA - PESSOA JURIDICA';

        vr_tab_historico(1544).nrctaori_fis := 7136;
        vr_tab_historico(1544).nrctades_fis := 7030;
        vr_tab_historico(1544).dsrefere_fis := 'JURO MORA FINANCIAM. PRE-FIXADO PAGO PELO AVALISTA - PESSOA FISICA';
        vr_tab_historico(1544).nrctaori_jur := 7136;
        vr_tab_historico(1544).nrctades_jur := 7031;
        vr_tab_historico(1544).dsrefere_jur := 'JURO MORA FINANCIAM. PRE-FIXADO PAGO PELO AVALISTA - PESSOA JURIDICA';

        vr_tab_historico(1070).nrctaori_fis := 7138;
        vr_tab_historico(1070).nrctades_fis := 7032;
        vr_tab_historico(1070).dsrefere_fis := 'MULTA CONTRATO FINANCIAMENTO TX. PRE-FIXADA - PESSOA FISICA';
        vr_tab_historico(1070).nrctaori_jur := 7138;
        vr_tab_historico(1070).nrctades_jur := 7033;
        vr_tab_historico(1070).dsrefere_jur := 'MULTA CONTRATO FINANCIAMENTO TX. PRE-FIXADA - PESSOA JURIDICA';

        vr_tab_historico(1542).nrctaori_fis := 7138;
        vr_tab_historico(1542).nrctades_fis := 7032;
        vr_tab_historico(1542).dsrefere_fis := 'MULTA FINANCIAMENTO PRE-FIXADO PAGO PELO AVALISTA - PESSOA FISICA';
        vr_tab_historico(1542).nrctaori_jur := 7138;
        vr_tab_historico(1542).nrctades_jur := 7033;
        vr_tab_historico(1542).dsrefere_jur := 'MULTA FINANCIAMENTO PRE-FIXADO PAGO PELO AVALISTA - PESSOA JURIDICA';
     
        vr_tab_historico(1508).nrctaori_fis := 7018;
        vr_tab_historico(1508).nrctades_fis := 7123;
        vr_tab_historico(1508).dsrefere_fis := 'ESTORNO JUROS DE MORA CONTR. EMPR. TX. PRE-FIXADA - PESSOA FISICA';
        vr_tab_historico(1508).nrctaori_jur := 7019;
        vr_tab_historico(1508).nrctades_jur := 7123;
        vr_tab_historico(1508).dsrefere_jur := 'ESTORNO JUROS DE MORA CONTR. EMPR. TX. PRE-FIXADA - PESSOA JURIDICA';

        vr_tab_historico(1712).nrctaori_fis := 7018;
        vr_tab_historico(1712).nrctades_fis := 7123;
        vr_tab_historico(1712).dsrefere_fis := 'ESTORNO JUROS EMPRESTIMOS PRE-FIXADO - PESSOA FISICA';
        vr_tab_historico(1712).nrctaori_jur := 7019;
        vr_tab_historico(1712).nrctades_jur := 7123;
        vr_tab_historico(1712).dsrefere_jur := 'ESTORNO JUROS EMPRESTIMOS PRE-FIXADO - PESSOA JURIDICA';

        vr_tab_historico(1713).nrctaori_fis := 7030;
        vr_tab_historico(1713).nrctades_fis := 7136;
        vr_tab_historico(1713).dsrefere_fis := 'ESTORNO JUROS FINANCIAMENTO PRE-FIXADO - PESSOA FISICA';
        vr_tab_historico(1713).nrctaori_jur := 7031;
        vr_tab_historico(1713).nrctades_jur := 7136;
        vr_tab_historico(1713).dsrefere_jur := 'ESTORNO JUROS FINANCIAMENTO PRE-FIXADO - PESSOA JURIDICA';

        vr_tab_historico(1722).nrctaori_fis := 7030;
        vr_tab_historico(1722).nrctades_fis := 7136;
        vr_tab_historico(1722).dsrefere_fis := 'ESTORNO JUROS FINANCIAMENTO PRE-FIXADO PAGO PELO AVALISTA - PESSOA FISICA';
        vr_tab_historico(1722).nrctaori_jur := 7031;
        vr_tab_historico(1722).nrctades_jur := 7136;
        vr_tab_historico(1722).dsrefere_jur := 'ESTORNO JUROS FINANCIAMENTO PRE-FIXADO PAGO PELO AVALISTA - PESSOA JURIDICA';        

        vr_tab_historico(1721).nrctaori_fis := 7018;
        vr_tab_historico(1721).nrctades_fis := 7123;
        vr_tab_historico(1721).dsrefere_fis := 'ESTORNO JUROS EMPRESTIMO PRE-FIXADO AVAL - PESSOA FISICA';
        vr_tab_historico(1721).nrctaori_jur := 7019;
        vr_tab_historico(1721).nrctades_jur := 7123;
        vr_tab_historico(1721).dsrefere_jur := 'ESTORNO JUROS EMPRESTIMO PRE-FIXADO AVAL - PESSOA JURIDICA';     

        vr_tab_historico(1507).nrctaori_fis := 7020;
        vr_tab_historico(1507).nrctades_fis := 7124;
        vr_tab_historico(1507).dsrefere_fis := 'ESTORNO MULTA CONTRATO EMPRESTIMO TX. PRE-FIXADA - PESSOA FISICA';
        vr_tab_historico(1507).nrctaori_jur := 7021;
        vr_tab_historico(1507).nrctades_jur := 7124;
        vr_tab_historico(1507).dsrefere_jur := 'ESTORNO MULTA CONTRATO EMPRESTIMO TX. PRE-FIXADA - PESSOA JURIDICA';     

        vr_tab_historico(1709).nrctaori_fis := 7020;
        vr_tab_historico(1709).nrctades_fis := 7124;
        vr_tab_historico(1709).dsrefere_fis := 'ESTORNO MULTA EMPRESTIMO PRE-FIXADO - PESSOA FISICA';
        vr_tab_historico(1709).nrctaori_jur := 7021;
        vr_tab_historico(1709).nrctades_jur := 7124;
        vr_tab_historico(1709).dsrefere_jur := 'ESTORNO MULTA EMPRESTIMO PRE-FIXADO - PESSOA JURIDICA';     

        vr_tab_historico(1718).nrctaori_fis := 7020;
        vr_tab_historico(1718).nrctades_fis := 7124;
        vr_tab_historico(1718).dsrefere_fis := 'ESTORNO MULTA EMPRESTIMO PRE-FIXADO AVAL - PESSOA FISICA';
        vr_tab_historico(1718).nrctaori_jur := 7021;
        vr_tab_historico(1718).nrctades_jur := 7124;
        vr_tab_historico(1718).dsrefere_jur := 'ESTORNO MULTA EMPRESTIMO PRE-FIXADO AVAL - PESSOA JURIDICA';       

        vr_tab_historico(1710).nrctaori_fis := 7032;
        vr_tab_historico(1710).nrctades_fis := 7138;
        vr_tab_historico(1710).dsrefere_fis := 'ESTORNO MULTA FINANCIAMENTO PRE-FIXADO - PESSOA FISICA';
        vr_tab_historico(1710).nrctaori_jur := 7033;
        vr_tab_historico(1710).nrctades_jur := 7138;
        vr_tab_historico(1710).dsrefere_jur := 'ESTORNO MULTA FINANCIAMENTO PRE-FIXADO - PESSOA JURIDICA';    

        vr_tab_historico(37).nrctaori_fis := 7113;
        vr_tab_historico(37).nrctades_fis := 7012;
        vr_tab_historico(37).dsrefere_fis := 'TAXA SOBRE SALDO EM C/C NEGATIVO - PESSOA FISICA';
        vr_tab_historico(37).nrctaori_jur := 7113;
        vr_tab_historico(37).nrctades_jur := 7013;
        vr_tab_historico(37).dsrefere_jur := 'TAXA SOBRE SALDO EM C/C NEGATIVO - PESSOA JURIDICA';   

        vr_tab_historico(57).nrctaori_fis := 7113;
        vr_tab_historico(57).nrctades_fis := 7012;
        vr_tab_historico(57).dsrefere_fis := 'JUROS SOBRE SAQUE DE DEPOSITO BLOQUEADO - PESSOA FISICA';
        vr_tab_historico(57).nrctaori_jur := 7113;
        vr_tab_historico(57).nrctades_jur := 7013;
        vr_tab_historico(57).dsrefere_jur := 'JUROS SOBRE SAQUE DE DEPOSITO BLOQUEADO - PESSOA JURIDICA';          

        vr_tab_historico(1667).nrctaori_fis := 7012;
        vr_tab_historico(1667).nrctades_fis := 7113;
        vr_tab_historico(1667).dsrefere_fis := 'ESTORNO TAXA SOBRE SALDO EM C/C NEGATIVO - PESSOA FISICA';
        vr_tab_historico(1667).nrctaori_jur := 7013;
        vr_tab_historico(1667).nrctades_jur := 7113;
        vr_tab_historico(1667).dsrefere_jur := 'ESTORNO TAXA SOBRE SALDO EM C/C NEGATIVO - PESSOA JURIDICA';         

        vr_tab_historico(1682).nrctaori_fis := 7012;
        vr_tab_historico(1682).nrctades_fis := 7113;
        vr_tab_historico(1682).dsrefere_fis := 'ESTORNO DE JUROS SOBRE SAQUE DE DEPOSITO BLOQUEADO - PESSOA FISICA';
        vr_tab_historico(1682).nrctaori_jur := 7013;
        vr_tab_historico(1682).nrctades_jur := 7113;
        vr_tab_historico(1682).dsrefere_jur := 'ESTORNO DE JUROS SOBRE SAQUE DE DEPOSITO BLOQUEADO - PESSOA JURIDICA';

        vr_tab_historico(320).nrctaori_fis := 7014;
        vr_tab_historico(320).nrctades_fis := 7118;
        vr_tab_historico(320).dsrefere_fis := 'ESTORNO DE JUROS LIMITE DE CREDITO - PESSOA FISICA';
        vr_tab_historico(320).nrctaori_jur := 7015;
        vr_tab_historico(320).nrctades_jur := 7118;
        vr_tab_historico(320).dsrefere_jur := 'ESTORNO DE JUROS LIMITE DE CREDITO - PESSOA JURIDICA';

        vr_tab_historico(2084).nrctaori_fis := 7008;
        vr_tab_historico(2084).nrctades_fis := 7006;
        vr_tab_historico(2084).dsrefere_fis := 'MULTA CONTRATO EMPRESTIMO TX. POS-FIXADA - PESSOA FISICA';
        vr_tab_historico(2084).nrctaori_jur := 7008;
        vr_tab_historico(2084).nrctades_jur := 7007;
        vr_tab_historico(2084).dsrefere_jur := 'MULTA CONTRATO EMPRESTIMO TX. POS-FIXADA - PESSOA JURIDICA';

        vr_tab_historico(2085).nrctaori_fis := 7008;
        vr_tab_historico(2085).nrctades_fis := 7006;
        vr_tab_historico(2085).dsrefere_fis := 'MULTA EMPRESTIMO POS-FIXADO PAGO PELO AVALISTA - PESSOA FISICA';
        vr_tab_historico(2085).nrctaori_jur := 7008;
        vr_tab_historico(2085).nrctades_jur := 7007;
        vr_tab_historico(2085).dsrefere_jur := 'MULTA EMPRESTIMO POS-FIXADO PAGO PELO AVALISTA - PESSOA JURIDICA';

        vr_tab_historico(2087).nrctaori_fis := 7004;
        vr_tab_historico(2087).nrctades_fis := 7002;
        vr_tab_historico(2087).dsrefere_fis := 'JUROS DE MORA CONTRATO EMPRESTIMO TX. POS-FIXADA - PESSOA FISICA';
        vr_tab_historico(2087).nrctaori_jur := 7004;
        vr_tab_historico(2087).nrctades_jur := 7003;
        vr_tab_historico(2087).dsrefere_jur := 'JUROS DE MORA CONTRATO EMPRESTIMO TX. POS-FIXADA - PESSOA JURIDICA';

        vr_tab_historico(2088).nrctaori_fis := 7004;
        vr_tab_historico(2088).nrctades_fis := 7002;
        vr_tab_historico(2088).dsrefere_fis := 'JURO MORA EMPRESTIMO POS-FIXADO PAGO PELO AVALISTA - PESSOA FISICA';
        vr_tab_historico(2088).nrctaori_jur := 7004;
        vr_tab_historico(2088).nrctades_jur := 7003;
        vr_tab_historico(2088).dsrefere_jur := 'JURO MORA EMPRESTIMO POS-FIXADO PAGO PELO AVALISTA - PESSOA JURIDICA';

        vr_tab_historico(2090).nrctaori_fis := 7047;
        vr_tab_historico(2090).nrctades_fis := 7045;
        vr_tab_historico(2090).dsrefere_fis := 'MULTA CONTRATO FINANCIAMENTO TX. POS-FIXADA - PESSOA FISICA';
        vr_tab_historico(2090).nrctaori_jur := 7047;
        vr_tab_historico(2090).nrctades_jur := 7046;
        vr_tab_historico(2090).dsrefere_jur := 'MULTA CONTRATO FINANCIAMENTO TX. POS-FIXADA - PESSOA JURIDICA';

        vr_tab_historico(2091).nrctaori_fis := 7047;
        vr_tab_historico(2091).nrctades_fis := 7045;
        vr_tab_historico(2091).dsrefere_fis := 'MULTA FINANCIAMENTO POS-FIXADO PAGO PELO AVALISTA - PESSOA FISICA';
        vr_tab_historico(2091).nrctaori_jur := 7047;
        vr_tab_historico(2091).nrctades_jur := 7046;
        vr_tab_historico(2091).dsrefere_jur := 'MULTA FINANCIAMENTO POS-FIXADO PAGO PELO AVALISTA - PESSOA JURIDICA';

        vr_tab_historico(2093).nrctaori_fis := 7043;
        vr_tab_historico(2093).nrctades_fis := 7041;
        vr_tab_historico(2093).dsrefere_fis := 'JUROS DE MORA CONTRATO FINANCIAMENTO TX.POS-FIXADA - PESSOA FISICA';
        vr_tab_historico(2093).nrctaori_jur := 7043;
        vr_tab_historico(2093).nrctades_jur := 7042;
        vr_tab_historico(2093).dsrefere_jur := 'JUROS DE MORA CONTRATO FINANCIAMENTO TX.POS-FIXADA - PESSOA JURIDICA';

        vr_tab_historico(2094).nrctaori_fis := 7043;
        vr_tab_historico(2094).nrctades_fis := 7041;
        vr_tab_historico(2094).dsrefere_fis := 'JURO MORA FINANCIAM. POS-FIXADO PAGO PELO AVALISTA - PESSOA FISICA';
        vr_tab_historico(2094).nrctaori_jur := 7043;
        vr_tab_historico(2094).nrctades_jur := 7042;
        vr_tab_historico(2094).dsrefere_jur := 'JURO MORA FINANCIAM. POS-FIXADO PAGO PELO AVALISTA - PESSOA JURIDICA';
        
        vr_tab_historico(1510).nrctaori_fis := 7030;
        vr_tab_historico(1510).nrctades_fis := 7136;
        vr_tab_historico(1510).dsrefere_fis := 'ESTORNO JUROS DE MORA FINANCIAMENTO TX. PRE-FIXADA - PESSOA FISICA';
        vr_tab_historico(1510).nrctaori_jur := 7031;
        vr_tab_historico(1510).nrctades_jur := 7136;
        vr_tab_historico(1510).dsrefere_jur := 'ESTORNO JUROS DE MORA FINANCIAMENTO TX. PRE-FIXADA - PESSOA JURIDICA';

        vr_tab_historico(1719).nrctaori_fis := 7032;
        vr_tab_historico(1719).nrctades_fis := 7138;
        vr_tab_historico(1719).dsrefere_fis := 'ESTORNO MULTA FINANCIAMENTO PRE-FIXADO PAGO PELO AVALISTA - PESSOA FISICA';
        vr_tab_historico(1719).nrctaori_jur := 7033;
        vr_tab_historico(1719).nrctades_jur := 7138;
        vr_tab_historico(1719).dsrefere_jur := 'ESTORNO MULTA FINANCIAMENTO PRE-FIXADO PAGO PELO AVALISTA - PESSOA JURIDICA';

   END;  

          -- Inicializa tabela de Historicos
     PROCEDURE pc_inicia_historico_mic IS
     BEGIN
        -- Inclusão do módulo e ação logado - Chamado 734422 - 03/11/2017
        GENE0001.pc_set_modulo(pr_module => 'PC_CRPS249.pc_inicia_historico_mic', pr_action => NULL);
        vr_tab_historico_mic.DELETE;

        vr_tab_historico_mic(0098).nrctaori_fis := 7141;
        vr_tab_historico_mic(0098).nrctades_fis := 7071;
        vr_tab_historico_mic(0098).dsrefere_fis := 'AJUSTE DE SALDO REF. (CRPS249) JUROS CONTRATO MICROCREDITO PRICE TR (pr_origem) - PESSOA FISICA';
        vr_tab_historico_mic(0098).nrctaori_jur := 7141;
        vr_tab_historico_mic(0098).nrctades_jur := 7072;
        vr_tab_historico_mic(0098).dsrefere_jur := 'AJUSTE DE SALDO REF. (CRPS249) JUROS CONTRATO MICROCREDITO PRICE TR (pr_origem) - PESSOA JURIDICA';
                
        vr_tab_historico_mic(0277).nrctaori_fis := 7071;
        vr_tab_historico_mic(0277).nrctades_fis := 7141;
        vr_tab_historico_mic(0277).dsrefere_fis := 'ESTORNO AJUSTE DE SALDO REF. (CRPS249) JUROS CONTRATO MICROCREDITO PRICE TR (pr_origem) - PESSOA FISICA';
        vr_tab_historico_mic(0277).nrctaori_jur := 7072;
        vr_tab_historico_mic(0277).nrctades_jur := 7141;
        vr_tab_historico_mic(0277).dsrefere_jur := 'ESTORNO AJUSTE DE SALDO REF. (CRPS249) JUROS CONTRATO MICROCREDITO PRICE TR (pr_origem) - PESSOA JURIDICA';

        vr_tab_historico_mic(2093).nrctaori_fis := 7043;
        vr_tab_historico_mic(2093).nrctades_fis := 7074;
        vr_tab_historico_mic(2093).dsrefere_fis := 'AJUSTE DE SALDO REF. (CRPS249) JUROS DE MORA CONTRATO MICROCREDITO PRICE TR (pr_origem) - PESSOA FISICA';
        vr_tab_historico_mic(2093).nrctaori_jur := 7043;
        vr_tab_historico_mic(2093).nrctades_jur := 7075;
        vr_tab_historico_mic(2093).dsrefere_jur := 'AJUSTE DE SALDO REF. (CRPS249) JUROS DE MORA CONTRATO MICROCREDITO PRICE TR (pr_origem) - PESSOA JURIDICA';

        vr_tab_historico_mic(2090).nrctaori_fis := 7047;
        vr_tab_historico_mic(2090).nrctades_fis := 7077;
        vr_tab_historico_mic(2090).dsrefere_fis := 'AJUSTE DE SALDO REF. (CRPS249) MULTA CONTRATO MICROCREDITO PRICE TR (pr_origem) - PESSOA FISICA';
        vr_tab_historico_mic(2090).nrctaori_jur := 7047;
        vr_tab_historico_mic(2090).nrctades_jur := 7078;
        vr_tab_historico_mic(2090).dsrefere_jur := 'AJUSTE DE SALDO REF. (CRPS249) MULTA CONTRATO MICROCREDITO PRICE TR (pr_origem) - PESSOA JURIDICA';

        vr_tab_historico_mic(1038).nrctaori_fis := 7135;
        vr_tab_historico_mic(1038).nrctades_fis := 7080;
        vr_tab_historico_mic(1038).dsrefere_fis := 'AJUSTE DE SALDO REF. (CRPS249) JUROS CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA FISICA';
        vr_tab_historico_mic(1038).nrctaori_jur := 7135;
        vr_tab_historico_mic(1038).nrctades_jur := 7081;
        vr_tab_historico_mic(1038).dsrefere_jur := 'AJUSTE DE SALDO REF. (CRPS249) JUROS CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA JURIDICA';

        vr_tab_historico_mic(1072).nrctaori_fis := 7136;
        vr_tab_historico_mic(1072).nrctades_fis := 7083;
        vr_tab_historico_mic(1072).dsrefere_fis := 'AJUSTE DE SALDO REF. (CRPS249) JUROS DE MORA CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA FISICA';
        vr_tab_historico_mic(1072).nrctaori_jur := 7136;
        vr_tab_historico_mic(1072).nrctades_jur := 7084;
        vr_tab_historico_mic(1072).dsrefere_jur := 'AJUSTE DE SALDO REF. (CRPS249) JUROS DE MORA CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA JURIDICA';

        vr_tab_historico_mic(1713).nrctaori_fis := 7083;
        vr_tab_historico_mic(1713).nrctades_fis := 7136;
        vr_tab_historico_mic(1713).dsrefere_fis := 'ESTORNO AJUSTE DE SALDO REF. (CRPS249) JUROS DE MORA CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA FISICA';
        vr_tab_historico_mic(1713).nrctaori_jur := 7084;
        vr_tab_historico_mic(1713).nrctades_jur := 7136;
        vr_tab_historico_mic(1713).dsrefere_jur := 'ESTORNO AJUSTE DE SALDO REF. (CRPS249) JUROS DE MORA CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA JURIDICA';

        vr_tab_historico_mic(1722).nrctaori_fis := 7083;
        vr_tab_historico_mic(1722).nrctades_fis := 7136;
        vr_tab_historico_mic(1722).dsrefere_fis := 'ESTORNO AJUSTE DE SALDO REF. (CRPS249) JUROS DE MORA AVAL CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA FISICA';
        vr_tab_historico_mic(1722).nrctaori_jur := 7084;
        vr_tab_historico_mic(1722).nrctades_jur := 7136;
        vr_tab_historico_mic(1722).dsrefere_jur := 'ESTORNO AJUSTE DE SALDO REF. (CRPS249) JUROS DE MORA AVAL CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA JURIDICA';


        vr_tab_historico_mic(1070).nrctaori_fis := 7138;
        vr_tab_historico_mic(1070).nrctades_fis := 7086;
        vr_tab_historico_mic(1070).dsrefere_fis := 'AJUSTE DE SALDO REF. (CRPS249) MULTA CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA FISICA';
        vr_tab_historico_mic(1070).nrctaori_jur := 7138;
        vr_tab_historico_mic(1070).nrctades_jur := 7087;
        vr_tab_historico_mic(1070).dsrefere_jur := 'AJUSTE DE SALDO REF. (CRPS249) MULTA CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA JURIDICA';
           
        vr_tab_historico_mic(1710).nrctaori_fis := 7086;
        vr_tab_historico_mic(1710).nrctades_fis := 7138;
        vr_tab_historico_mic(1710).dsrefere_fis := 'ESTORNO AJUSTE DE SALDO REF. (CRPS249) MULTA CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA FISICA';
        vr_tab_historico_mic(1710).nrctaori_jur := 7087;
        vr_tab_historico_mic(1710).nrctades_jur := 7138;
        vr_tab_historico_mic(1710).dsrefere_jur := 'ESTORNO AJUSTE DE SALDO REF. (CRPS249) MULTA CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA JURIDICA';

        vr_tab_historico_mic(1510).nrctaori_fis := 7083;
        vr_tab_historico_mic(1510).nrctades_fis := 7136;
        vr_tab_historico_mic(1510).dsrefere_fis := 'AJUSTE DE SALDO REF. (CRPS249) ESTORNO JUROS DE MORA CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA FISICA';
        vr_tab_historico_mic(1510).nrctaori_jur := 7084;
        vr_tab_historico_mic(1510).nrctades_jur := 7136;
        vr_tab_historico_mic(1510).dsrefere_jur := 'AJUSTE DE SALDO REF. (CRPS249) ESTORNO JUROS DE MORA CONTRATO MICROCREDITO TX. PRE-FIXADA (pr_origem) - PESSOA JURIDICA';
     							 
   END;  

  BEGIN
    -- Inclusão do módulo e ação logado - Chamado 734422 - 03/11/2017
    GENE0001.pc_set_modulo(pr_module => 'PC_CRPS249.pc_gera_arq_op_cred', pr_action => NULL);

     -- Inicia Variavel
     pr_dscritic := NULL;
     
     -- Inicializa Pl-Table
     pc_inicia_historico;
     pc_inicia_historico_mic;     
     
     -- Nome do arquivo a ser gerado
     vr_nmarqdat_ope_cred := vr_dtmvtolt_yymmdd||'_OPCRED.txt';

     -- Tenta abrir o arquivo de log em modo gravacao
     gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio     --> Diretório do arquivo
                             ,pr_nmarquiv => vr_nmarqdat_ope_cred --> Nome do arquivo
                             ,pr_tipabert => 'W'                  --> Modo de abertura (R,W,A)
                             ,pr_utlfileh => vr_input_file        --> Handle do arquivo aberto
                             ,pr_des_erro => vr_dscritic);        --> Erro
     IF vr_dscritic IS NOT NULL THEN
        -- Levantar Excecao
        RAISE vr_exc_erro;
     END IF;
      
     --Este trecho gerar apenas uma vez por mês
     IF to_char(vr_dtmvtolt, 'mm') <> to_char(vr_dtmvtopr, 'mm') THEN
       IF vr_arq_op_cred(2)(999)(1) > 0 THEN
          -- Monta cabacalho - Arq 2 - DESCONTO DE CHEQUE - PESSOA FISICA
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtolt,btch0001.rw_crapdat.dtmvtolt,5536,1641,vr_arq_op_cred(2)(999)(1),'"DESCONTO DE CHEQUE - PESSOA FISICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
                                        
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 2   -- DESCONTO DE CHEQUE - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
          
          pc_set_linha(pr_cdarquiv => 2   -- DESCONTO DE CHEQUE - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
  
       END IF;

       IF vr_arq_op_cred(2)(999)(1) > 0 THEN
          -- Monta cabacalho - Arq 2 - DESCONTO DE CHEQUE - REVERSAO
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtopr,btch0001.rw_crapdat.dtmvtopr,1641,5536,vr_arq_op_cred(2)(999)(1),'"'||vr_dsprefix||'DESCONTO DE CHEQUE - PESSOA FISICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
                  
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 2   -- DESCONTO DE CHEQUE - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

          pc_set_linha(pr_cdarquiv => 2   -- DESCONTO DE CHEQUE - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;

       IF vr_arq_op_cred(2)(999)(2) > 0 THEN
          -- Monta cabacalho - Arq 2 - DESCONTO DE CHEQUE - PESSOA JURIDICA
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtolt,btch0001.rw_crapdat.dtmvtolt,5537,1641,vr_arq_op_cred(2)(999)(2),'"DESCONTO DE CHEQUE - PESSOA JURIDICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 2   -- DESCONTO DE CHEQUE - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
          
          pc_set_linha(pr_cdarquiv => 2   -- DESCONTO DE CHEQUE - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;

       IF vr_arq_op_cred(2)(999)(2) > 0 THEN
          -- Monta cabacalho - Arq 2 - DESCONTO DE CHEQUE - REVERSAO
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtopr,btch0001.rw_crapdat.dtmvtopr,1641,5537,vr_arq_op_cred(2)(999)(2),'"'||vr_dsprefix||'DESCONTO DE CHEQUE - PESSOA JURIDICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 2   -- DESCONTO DE CHEQUE - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

          pc_set_linha(pr_cdarquiv => 2   -- DESCONTO DE CHEQUE - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;

       IF vr_arq_op_cred(3)(999)(1) > 0 THEN
          -- Monta cabacalho - Arq 3 - EMPRESTIMOS REALIZADOS. - PESSOA FISICA
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtolt,btch0001.rw_crapdat.dtmvtolt,5504,1621,vr_arq_op_cred(3)(999)(1),'"EMPRESTIMOS PRICE TR REALIZADOS - PESSOA FISICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */                              
          pc_set_linha(pr_cdarquiv => 3   -- EMPRESTIMOS REALIZADOS. - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

          pc_set_linha(pr_cdarquiv => 3   -- EMPRESTIMOS REALIZADOS. - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;
                        
       IF vr_arq_op_cred(3)(999)(1) > 0 THEN
          -- Monta cabacalho - Arq 3 - EMPRESTIMOS REALIZADOS. - REVERSAO
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtopr,btch0001.rw_crapdat.dtmvtopr,1621,5504,vr_arq_op_cred(3)(999)(1),'"'||vr_dsprefix||'EMPRESTIMOS PRICE TR REALIZADOS - PESSOA FISICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

          /* Deve ser duplicado as linhas separadas por PA */                              
          pc_set_linha(pr_cdarquiv => 3   -- EMPRESTIMOS REALIZADOS. - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

          pc_set_linha(pr_cdarquiv => 3   -- EMPRESTIMOS REALIZADOS. - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
  
       END IF;

       IF vr_arq_op_cred(3)(999)(2) > 0 THEN
          -- Monta cabacalho - Arq 3 - EMPRESTIMOS REALIZADOS. - PESSOA JURIDICA
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtolt,btch0001.rw_crapdat.dtmvtolt,5505,1621,vr_arq_op_cred(3)(999)(2),'"EMPRESTIMOS REALIZADOS PRICE TR - PESSOA JURIDICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 3   -- EMPRESTIMOS REALIZADOS. - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

          pc_set_linha(pr_cdarquiv => 3   -- EMPRESTIMOS REALIZADOS. - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;

       IF vr_arq_op_cred(3)(999)(2) > 0 THEN
          -- Monta cabacalho - Arq 3 - EMPRESTIMOS REALIZADOS. - REVERSAO
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtopr,btch0001.rw_crapdat.dtmvtopr,1621,5505,vr_arq_op_cred(3)(999)(2),'"'||vr_dsprefix||'EMPRESTIMOS REALIZADOS PRICE TR - PESSOA JURIDICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita                                   
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 3   -- EMPRESTIMOS REALIZADOS. - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
          
          pc_set_linha(pr_cdarquiv => 3   -- EMPRESTIMOS REALIZADOS. - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;

       IF vr_arq_op_cred(4)(999)(1) > 0 THEN
          -- Monta cabacalho - Arq 4 - FINANCIAMENTOS REALIZADOS - PESSOA FISICA
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtolt,btch0001.rw_crapdat.dtmvtolt,5548,1662,vr_arq_op_cred(4)(999)(1),'"FINANCIAMENTOS PRICE TR REALIZADOS - PESSOA FISICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 4   -- FINANCIAMENTOS REALIZADOS - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
          
          pc_set_linha(pr_cdarquiv => 4   -- FINANCIAMENTOS REALIZADOS - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;
       
       IF vr_arq_op_cred(4)(999)(1) > 0 THEN
          -- Monta cabacalho - Arq 4 - FINANCIAMENTOS REALIZADOS - REVERSAO
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtopr,btch0001.rw_crapdat.dtmvtopr,1662,5548,vr_arq_op_cred(4)(999)(1),'"'||vr_dsprefix||'FINANCIAMENTOS PRICE TR REALIZADOS - PESSOA FISICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 4   -- FINANCIAMENTOS REALIZADOS - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

          pc_set_linha(pr_cdarquiv => 4   -- FINANCIAMENTOS REALIZADOS - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;
       
       IF vr_arq_op_cred(4)(999)(2) > 0 THEN
          -- Monta cabacalho - Arq 4 - FINANCIAMENTOS REALIZADOS - PESSOA JURIDICA
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtolt,btch0001.rw_crapdat.dtmvtolt,5549,1662,vr_arq_op_cred(4)(999)(2),'"FINANCIAMENTOS REALIZADOS PRICE TR - PESSOA JURIDICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 4   -- FINANCIAMENTOS REALIZADOS - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

          pc_set_linha(pr_cdarquiv => 4   -- FINANCIAMENTOS REALIZADOS - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;
       
       IF vr_arq_op_cred(4)(999)(2) > 0 THEN
          -- Monta cabacalho - Arq 4 - FINANCIAMENTOS REALIZADOS - REVERSAO
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtopr,btch0001.rw_crapdat.dtmvtopr,1662,5549,vr_arq_op_cred(4)(999)(2),'"'||vr_dsprefix||'FINANCIAMENTOS REALIZADOS PRICE TR - PESSOA JURIDICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 4   -- FINANCIAMENTOS REALIZADOS - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
                      
          pc_set_linha(pr_cdarquiv => 4   -- FINANCIAMENTOS REALIZADOS - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;
       
       IF vr_arq_op_cred(5)(999)(1) > 0 THEN
          -- Monta cabacalho - Arq 5 - EMPRESTIMOS PREFIXADO REALIZADOS - PESSOA FISICA
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtolt,btch0001.rw_crapdat.dtmvtolt,5516,1664,vr_arq_op_cred(5)(999)(1),'"EMPRESTIMOS PREFIXADO REALIZADOS - PESSOA FISICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 5   -- EMPRESTIMOS PREFIXADO REALIZADOS - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
          
          pc_set_linha(pr_cdarquiv => 5   -- EMPRESTIMOS PREFIXADO REALIZADOS - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;

       IF vr_arq_op_cred(5)(999)(1) > 0 THEN
          -- Monta cabacalho - Arq 5 - EMPRESTIMOS PREFIXADO REALIZADOS - REVERSAO
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtopr,btch0001.rw_crapdat.dtmvtopr,1664,5516,vr_arq_op_cred(5)(999)(1),'"'||vr_dsprefix||'EMPRESTIMOS PREFIXADO REALIZADOS - PESSOA FISICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 5   -- EMPRESTIMOS PREFIXADO REALIZADOS - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

          pc_set_linha(pr_cdarquiv => 5   -- EMPRESTIMOS PREFIXADO REALIZADOS - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;

       IF vr_arq_op_cred(5)(999)(2) > 0 THEN
          -- Monta cabacalho - Arq 5 - EMPRESTIMOS PREFIXADO REALIZADOS - PESSOA JURIDICA
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtolt,btch0001.rw_crapdat.dtmvtolt,5517,1664,vr_arq_op_cred(5)(999)(2),'"EMPRESTIMOS PREFIXADO REALIZADOS - PESSOA JURIDICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 5   -- EMPRESTIMOS PREFIXADO REALIZADOS - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

          pc_set_linha(pr_cdarquiv => 5   -- EMPRESTIMOS PREFIXADO REALIZADOS - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;
       
       IF vr_arq_op_cred(5)(999)(2) > 0 THEN
          -- Monta cabacalho - Arq 5 - EMPRESTIMOS PREFIXADO REALIZADOS - REVERSAO
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtopr,btch0001.rw_crapdat.dtmvtopr,1664,5517,vr_arq_op_cred(5)(999)(2),'"'||vr_dsprefix||'EMPRESTIMOS PREFIXADO REALIZADOS - PESSOA JURIDICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 5   -- EMPRESTIMOS PREFIXADO REALIZADOS - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

          pc_set_linha(pr_cdarquiv => 5   -- EMPRESTIMOS PREFIXADO REALIZADOS - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;

       IF vr_arq_op_cred(6)(999)(1) > 0 THEN
          -- Monta cabacalho - Arq 6 - FINANCIAMENTOS PREFIXADO REALIZADOS - PESSOA FISICA
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtolt,btch0001.rw_crapdat.dtmvtolt,5562,1667,vr_arq_op_cred(6)(999)(1),'"FINANCIAMENTOS PREFIXADO REALIZADOS - PESSOA FISICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 6   -- FINANCIAMENTOS PREFIXADO REALIZADOS - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
                      
          pc_set_linha(pr_cdarquiv => 6   -- FINANCIAMENTOS PREFIXADO REALIZADOS - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
       
       END IF;

       IF vr_arq_op_cred(6)(999)(1) > 0 THEN
          -- Monta cabacalho - Arq 6 - EMPRESTIMOS PREFIXADO REALIZADOS - REVERSAO
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtopr,btch0001.rw_crapdat.dtmvtopr,1667,5562,vr_arq_op_cred(6)(999)(1),'"'||vr_dsprefix||'FINANCIAMENTOS PREFIXADO REALIZADOS - PESSOA FISICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 6   -- FINANCIAMENTOS PREFIXADO REALIZADOS - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
                      
          pc_set_linha(pr_cdarquiv => 6   -- FINANCIAMENTOS PREFIXADO REALIZADOS - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;

       IF vr_arq_op_cred(6)(999)(2) > 0 THEN
          -- Monta cabacalho - Arq 6 - EMPRESTIMOS PREFIXADO REALIZADOS - PESSOA JURIDICA
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtolt,btch0001.rw_crapdat.dtmvtolt,5563,1667,vr_arq_op_cred(6)(999)(2),'"FINANCIAMENTOS PREFIXADO REALIZADOS - PESSOA JURIDICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 6   -- FINANCIAMENTOS PREFIXADO REALIZADOS - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
                      
          pc_set_linha(pr_cdarquiv => 6   -- FINANCIAMENTOS PREFIXADO REALIZADOS - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;

       IF vr_arq_op_cred(6)(999)(2) > 0 THEN
          -- Monta cabacalho - Arq 6 - EMPRESTIMOS PREFIXADO REALIZADOS - REVERSAO
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtopr,btch0001.rw_crapdat.dtmvtopr,1667,5563,vr_arq_op_cred(6)(999)(2),'"'||vr_dsprefix||'FINANCIAMENTOS PREFIXADO REALIZADOS - PESSOA JURIDICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 6   -- FINANCIAMENTOS PREFIXADO REALIZADOS - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
                      
          pc_set_linha(pr_cdarquiv => 6   -- FINANCIAMENTOS PREFIXADO REALIZADOS - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;

       IF vr_arq_op_cred(7)(999)(1) > 0 THEN
          -- Monta cabacalho - Arq 7 - RECEITA DE DESCONTO DE CHEQUE - PESSOA FISICA
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtolt,btch0001.rw_crapdat.dtmvtolt,1642,5538,vr_arq_op_cred(7)(999)(1),'"RECEITA DE DESCONTO DE CHEQUE - PESSOA FISICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 7   -- RECEITA DE DESCONTO DE CHEQUE - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

          pc_set_linha(pr_cdarquiv => 7   -- RECEITA DE DESCONTO DE CHEQUE - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;
       
       IF vr_arq_op_cred(7)(999)(1) > 0 THEN
          -- Monta cabacalho - Arq 7 - RECEITA DE DESCONTO DE CHEQUE - REVERSAO
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtopr,btch0001.rw_crapdat.dtmvtopr,5538,1642,vr_arq_op_cred(7)(999)(1),'"'||vr_dsprefix||'RECEITA DE DESCONTO DE CHEQUE - PESSOA FISICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 7   -- RECEITA DE DESCONTO DE CHEQUE - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
                      
          pc_set_linha(pr_cdarquiv => 7   -- RECEITA DE DESCONTO DE CHEQUE - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
       
       END IF; 

       IF vr_arq_op_cred(7)(999)(2) > 0 THEN
          -- Monta cabacalho - Arq 7 - RECEITA DE DESCONTO DE CHEQUE - PESSOA JURIDICA
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtolt,btch0001.rw_crapdat.dtmvtolt,1642,5539,vr_arq_op_cred(7)(999)(2),'"RECEITA DE DESCONTO DE CHEQUE - PESSOA JURIDICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 7   -- RECEITA DE DESCONTO DE CHEQUE - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
                      
          pc_set_linha(pr_cdarquiv => 7   -- RECEITA DE DESCONTO DE CHEQUE - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file);   
       END IF;

       IF vr_arq_op_cred(7)(999)(2) > 0 THEN
          -- Monta cabacalho - Arq 7 - RECEITA DE DESCONTO DE CHEQUE - REVERSAO
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtopr,btch0001.rw_crapdat.dtmvtopr,5539,1642,vr_arq_op_cred(7)(999)(2),'"'||vr_dsprefix||'RECEITA DE DESCONTO DE CHEQUE - PESSOA JURIDICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 7   -- RECEITA DE DESCONTO DE CHEQUE - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
                      
          pc_set_linha(pr_cdarquiv => 7   -- RECEITA DE DESCONTO DE CHEQUE - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;

       IF vr_arq_op_cred(8)(999)(1) > 0 THEN
          -- Monta cabacalho - Arq 8 - DESCONTO DE TITULO S/ REGISTRO - PESSOA FISICA
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtolt,btch0001.rw_crapdat.dtmvtolt,5540,1643,vr_arq_op_cred(8)(999)(1),'"DESCONTO DE TITULO S/ REGISTRO - PESSOA FISICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 8   -- DESCONTO DE TITULO S/ REGISTRO - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

          pc_set_linha(pr_cdarquiv => 8   -- DESCONTO DE TITULO S/ REGISTRO - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;

       IF vr_arq_op_cred(8)(999)(1) > 0 THEN
          -- Monta cabacalho - Arq 8 - DESCONTO DE TITULO S/ REGISTRO - REVERSAO
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtopr,btch0001.rw_crapdat.dtmvtopr,1643,5540,vr_arq_op_cred(8)(999)(1),'"'||vr_dsprefix||'DESCONTO DE TITULO S/ REGISTRO - PESSOA FISICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 8   -- DESCONTO DE TITULO S/ REGISTRO - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

          pc_set_linha(pr_cdarquiv => 8   -- DESCONTO DE TITULO S/ REGISTRO - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
       END IF;

       IF vr_arq_op_cred(8)(999)(2) > 0 THEN
          -- Monta cabacalho - Arq 8 - DESCONTO DE TITULO S/ REGISTRO - PESSOA JURIDICA
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtolt,btch0001.rw_crapdat.dtmvtolt,5541,1643,vr_arq_op_cred(8)(999)(2),'"DESCONTO DE TITULO S/ REGISTRO - PESSOA JURIDICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 8   -- DESCONTO DE TITULO S/ REGISTRO - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
          
          pc_set_linha(pr_cdarquiv => 8   -- DESCONTO DE TITULO S/ REGISTRO - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;

       IF vr_arq_op_cred(8)(999)(2) > 0 THEN
          -- Monta cabacalho - Arq 8 - DESCONTO DE TITULO S/ REGISTRO - REVERSAO
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtopr,btch0001.rw_crapdat.dtmvtopr,1643,5541,vr_arq_op_cred(8)(999)(2),'"'||vr_dsprefix||'DESCONTO DE TITULO S/ REGISTRO - PESSOA JURIDICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita                                                                      
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 8   -- DESCONTO DE TITULO S/ REGISTRO - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
                      
          pc_set_linha(pr_cdarquiv => 8   -- DESCONTO DE TITULO S/ REGISTRO - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
       
       END IF;

       IF vr_arq_op_cred(9)(999)(1) > 0 THEN
          -- Monta cabacalho - Arq 9 - DESCONTO DE TITULO C/ REGISTRO - PESSOA FISICA
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtolt,btch0001.rw_crapdat.dtmvtolt,5544,1645,vr_arq_op_cred(9)(999)(1),'"DESCONTO DE TITULO C/ REGISTRO - PESSOA FISICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 9   -- DESCONTO DE TITULO C/ REGISTRO - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
                      
          pc_set_linha(pr_cdarquiv => 9   -- DESCONTO DE TITULO C/ REGISTRO - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;

       IF vr_arq_op_cred(9)(999)(1) > 0 THEN
          -- Monta cabacalho - Arq 9 - DESCONTO DE TITULO C/ REGISTRO - REVERSAO
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtopr,btch0001.rw_crapdat.dtmvtopr,1645,5544,vr_arq_op_cred(9)(999)(1),'"'||vr_dsprefix||'DESCONTO DE TITULO C/ REGISTRO - PESSOA FISICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 9   -- DESCONTO DE TITULO C/ REGISTRO - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
                      
          pc_set_linha(pr_cdarquiv => 9   -- DESCONTO DE TITULO C/ REGISTRO - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;
       
       IF vr_arq_op_cred(9)(999)(2) > 0 THEN
          -- Monta cabacalho - Arq 9 - DESCONTO DE TITULO C/ REGISTRO - PESSOA JURIDICA
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtolt,btch0001.rw_crapdat.dtmvtolt,5545,1645,vr_arq_op_cred(9)(999)(2),'"DESCONTO DE TITULO C/ REGISTRO - PESSOA JURIDICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 9   -- DESCONTO DE TITULO C/ REGISTRO - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

          pc_set_linha(pr_cdarquiv => 9   -- DESCONTO DE TITULO C/ REGISTRO - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;
       
       IF vr_arq_op_cred(9)(999)(2) > 0 THEN
          -- Monta cabacalho - Arq 9 - DESCONTO DE TITULO C/ REGISTRO - REVERSAO
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtopr,btch0001.rw_crapdat.dtmvtopr,1645,5545,vr_arq_op_cred(9)(999)(2),'"'||vr_dsprefix||'DESCONTO DE TITULO C/ REGISTRO - PESSOA JURIDICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 9   -- DESCONTO DE TITULO C/ REGISTRO - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
                      
          pc_set_linha(pr_cdarquiv => 9   -- DESCONTO DE TITULO C/ REGISTRO - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;
       
       IF vr_arq_op_cred(10)(999)(1) > 0 THEN
          -- Monta cabacalho - Arq 10 - RENDA DE DESCONTO DE TITULO S/ REGISTRO - PESSOA FISICA
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtolt,btch0001.rw_crapdat.dtmvtolt,1644,5542,vr_arq_op_cred(10)(999)(1),'"RENDA DE DESCONTO DE TITULO S/ REGISTRO - PESSOA FISICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 10  -- RENDA DE DESCONTO DE TITULO S/ REGISTRO - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
                      
          pc_set_linha(pr_cdarquiv => 10  -- RENDA DE DESCONTO DE TITULO S/ REGISTRO - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;

       IF vr_arq_op_cred(10)(999)(1) > 0 THEN
          -- Monta cabacalho - Arq 10 - RENDA DE DESCONTO DE TITULO S/ REGISTRO - REVERSAO
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtopr,btch0001.rw_crapdat.dtmvtopr,5542,1644,vr_arq_op_cred(10)(999)(1),'"'||vr_dsprefix||'RENDA DE DESCONTO DE TITULO S/ REGISTRO - PESSOA FISICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */ 
          pc_set_linha(pr_cdarquiv => 10  -- RENDA DE DESCONTO DE TITULO S/ REGISTRO - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
                      
          pc_set_linha(pr_cdarquiv => 10  -- RENDA DE DESCONTO DE TITULO S/ REGISTRO - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;

       IF vr_arq_op_cred(10)(999)(2) > 0 THEN
          -- Monta cabacalho - Arq 10 - RENDA DE DESCONTO DE TITULO S/ REGISTRO - PESSOA JURIDICA
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtolt,btch0001.rw_crapdat.dtmvtolt,1644,5543,vr_arq_op_cred(10)(999)(2),'"RENDA DE DESCONTO DE TITULO S/ REGISTRO - PESSOA JURIDICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 10  -- RENDA DE DESCONTO DE TITULO S/ REGISTRO - PESSOA JURIDICA
                       ,pr_inpessoa => 2 -- Tipo de Pessoa
                       ,pr_inputfile => vr_input_file); 
                      
          pc_set_linha(pr_cdarquiv => 10  -- RENDA DE DESCONTO DE TITULO S/ REGISTRO - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;

       IF vr_arq_op_cred(10)(999)(2) > 0 THEN
          -- Monta cabacalho - Arq 10 - RENDA DE DESCONTO DE TITULO S/ REGISTRO - REVERSAO
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtopr,btch0001.rw_crapdat.dtmvtopr,5543,1644,vr_arq_op_cred(10)(999)(2),'"'||vr_dsprefix||'RENDA DE DESCONTO DE TITULO S/ REGISTRO - PESSOA JURIDICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 10  -- RENDA DE DESCONTO DE TITULO S/ REGISTRO - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

          pc_set_linha(pr_cdarquiv => 10  -- RENDA DE DESCONTO DE TITULO S/ REGISTRO - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;
     
       IF vr_arq_op_cred(11)(999)(1) > 0 THEN
          -- Monta cabacalho - Arq 11 - RENDA DE DESCONTO DE TITULO C/ REGISTRO - PESSOA FISICA
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtolt,btch0001.rw_crapdat.dtmvtolt,1646,5546,vr_arq_op_cred(11)(999)(1),'"RENDA DE DESCONTO DE TITULO C/ REGISTRO - PESSOA FISICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 11  -- RENDA DE DESCONTO DE TITULO C/ REGISTRO - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

          pc_set_linha(pr_cdarquiv => 11  -- RENDA DE DESCONTO DE TITULO C/ REGISTRO - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;

       IF vr_arq_op_cred(11)(999)(1) > 0 THEN
          -- Monta cabacalho - Arq 11 - RENDA DE DESCONTO DE TITULO C/ REGISTRO - REVERSAO
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtopr,btch0001.rw_crapdat.dtmvtopr,5546,1646,vr_arq_op_cred(11)(999)(1),'"'||vr_dsprefix||'RENDA DE DESCONTO DE TITULO C/ REGISTRO - PESSOA FISICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 11  -- RENDA DE DESCONTO DE TITULO C/ REGISTRO - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

          pc_set_linha(pr_cdarquiv => 11  -- RENDA DE DESCONTO DE TITULO C/ REGISTRO - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;

       IF vr_arq_op_cred(11)(999)(2) > 0 THEN
          -- Monta cabacalho - Arq 11 - RENDA DE DESCONTO DE TITULO C/ REGISTRO - PESSOA JURIDICA
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtolt,btch0001.rw_crapdat.dtmvtolt,1646,5547,vr_arq_op_cred(11)(999)(2),'"RENDA DE DESCONTO DE TITULO C/ REGISTRO - PESSOA JURIDICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 11  -- RENDA DE DESCONTO DE TITULO C/ REGISTRO - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

          pc_set_linha(pr_cdarquiv => 11  -- RENDA DE DESCONTO DE TITULO C/ REGISTRO - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;

       IF vr_arq_op_cred(11)(999)(2) > 0 THEN
          -- Monta cabacalho - Arq 11 - RENDA DE DESCONTO DE TITULO C/ REGISTRO - REVERSAO
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtopr,btch0001.rw_crapdat.dtmvtopr,5547,1646,vr_arq_op_cred(11)(999)(2),'"'||vr_dsprefix||'RENDA DE DESCONTO DE TITULO C/ REGISTRO - PESSOA JURIDICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita                                                                         
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 11  -- RENDA DE DESCONTO DE TITULO C/ REGISTRO - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

          pc_set_linha(pr_cdarquiv => 11  -- RENDA DE DESCONTO DE TITULO C/ REGISTRO - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

       END IF;

       IF vr_arq_op_cred(12)(999)(1) > 0 THEN
          -- Monta cabacalho - Arq 12 - APROPRIACAO RECEITA DE TITULO RECEBIDO PARA DESCONTO S/ REGISTRO - PESSOA FISICA
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtolt,btch0001.rw_crapdat.dtmvtolt,7132,7024,vr_arq_op_cred(12)(999)(1),'"APROPRIACAO RECEITA DE TITULO RECEBIDO PARA DESCONTO S/ REGISTRO - PESSOA FISICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 12  -- APROPRIACAO RECEITA DE TITULO RECEBIDO PARA DESCONTO S/ REGISTRO - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
          
          pc_set_linha(pr_cdarquiv => 12  -- APROPRIACAO RECEITA DE TITULO RECEBIDO PARA DESCONTO S/ REGISTRO - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 
          
       END IF;

       IF vr_arq_op_cred(12)(999)(2) > 0 THEN
          -- Monta cabacalho - Arq 12 - APROPRIACAO RECEITA DE TITULO RECEBIDO PARA DESCONTO S/ REGISTRO - PESSOA JURIDICA
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtolt,btch0001.rw_crapdat.dtmvtolt,7132,7025,vr_arq_op_cred(12)(999)(2),'"APROPRIACAO RECEITA DE TITULO RECEBIDO PARA DESCONTO S/ REGISTRO - PESSOA JURIDICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 12  -- APROPRIACAO RECEITA DE TITULO RECEBIDO PARA DESCONTO S/ REGISTRO - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 

          pc_set_linha(pr_cdarquiv => 12  -- APROPRIACAO RECEITA DE TITULO RECEBIDO PARA DESCONTO S/ REGISTRO - PESSOA JURIDICA
                      ,pr_inpessoa => 2 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 


       END IF;
       
       IF vr_arq_op_cred(13)(999)(1) > 0 THEN
          -- Monta cabacalho - Arq 13 - APROPRIACAO RECEITA DE TITULO RECEBIDO PARA DESCONTO C/ REGISTRO - PESSOA FISICA
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtolt,btch0001.rw_crapdat.dtmvtolt,7132,7024,vr_arq_op_cred(13)(999)(1),'"APROPRIACAO RECEITA DE TITULO RECEBIDO PARA DESCONTO C/ REGISTRO - PESSOA FISICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 13  -- APROPRIACAO RECEITA DE TITULO RECEBIDO PARA DESCONTO C/ REGISTRO - PESSOA FISICA
                    ,pr_inpessoa => 1 -- Tipo de Pessoa
                    ,pr_inputfile => vr_input_file); 
                    
          pc_set_linha(pr_cdarquiv => 13  -- APROPRIACAO RECEITA DE TITULO RECEBIDO PARA DESCONTO C/ REGISTRO - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                      ,pr_inputfile => vr_input_file); 


       END IF;
       
       IF vr_arq_op_cred(13)(999)(2) > 0 THEN
          -- Monta cabacalho - Arq 13 - APROPRIACAO RECEITA DE TITULO RECEBIDO PARA DESCONTO C/ REGISTRO - PESSOA JURIDICA
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtolt,btch0001.rw_crapdat.dtmvtolt,7132,7025,vr_arq_op_cred(13)(999)(2),'"APROPRIACAO RECEITA DE TITULO RECEBIDO PARA DESCONTO C/ REGISTRO - PESSOA JURIDICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 13  -- APROPRIACAO RECEITA DE TITULO RECEBIDO PARA DESCONTO C/ REGISTRO - PESSOA JURIDICA
                    ,pr_inpessoa => 2 -- Tipo de Pessoa
                    ,pr_inputfile => vr_input_file); 
                      
          pc_set_linha(pr_cdarquiv => 13  -- APROPRIACAO RECEITA DE TITULO RECEBIDO PARA DESCONTO C/ REGISTRO - PESSOA JURIDICA
                    ,pr_inpessoa => 2 -- Tipo de Pessoa
                    ,pr_inputfile => vr_input_file); 

       END IF;

       IF vr_arq_op_cred(15)(999)(1) > 0 THEN
          -- Monta cabacalho - Arq 15 - PROVISAO JUROS CH. ESPECIAL - PESSOA FISICA
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtolt,btch0001.rw_crapdat.dtmvtolt,7131,7022,vr_arq_op_cred(15)(999)(1),'"APROPRIACAO RECEITA DE CHEQUE RECEBIDO PARA DESCONTO - PESSOA FISICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita
          
          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 15  -- PROVISAO JUROS CH. ESPECIAL - PESSOA FISICA
                      ,pr_inpessoa => 1 -- Tipo de Pessoa
                     ,pr_inputfile => vr_input_file); 

          pc_set_linha(pr_cdarquiv => 15  -- PROVISAO JUROS CH. ESPECIAL - PESSOA FISICA
                      ,pr_inpessoa => 1
                      ,pr_inputfile => vr_input_file); -- Tipo de Pessoa

       END IF;
       
       IF vr_arq_op_cred(15)(999)(2) > 0 THEN
          -- Monta cabacalho - Arq 15 - PROVISAO JUROS CH. ESPECIAL - PESSOA JURIDICA
          vr_setlinha := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtolt,btch0001.rw_crapdat.dtmvtolt,7131,7023,vr_arq_op_cred(15)(999)(2),'"APROPRIACAO RECEITA DE CHEQUE RECEBIDO PARA DESCONTO - PESSOA JURIDICA"');
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto para escrita

          /* Deve ser duplicado as linhas separadas por PA */
          pc_set_linha(pr_cdarquiv => 15  -- PROVISAO JUROS CH. ESPECIAL - PESSOA JURIDICA
                      ,pr_inpessoa => 2
                      ,pr_inputfile => vr_input_file); -- Tipo de Pessoa

          pc_set_linha(pr_cdarquiv => 15  -- PROVISAO JUROS CH. ESPECIAL - PESSOA JURIDICA
                      ,pr_inpessoa => 2
                      ,pr_inputfile => vr_input_file); -- Tipo de Pessoa

       END IF;
     END IF; --Mensal

     vr_tab_valores_ag.DELETE;
     vr_index := 0;


     -- Leitura do Total de rejeitados na integração -- Pessoa Fisica
     FOR rw_craprej IN cr_craprej(pr_cdcooper,vr_cdprogra,vr_dtmvtolt,1) LOOP

        -- Historico para ESTORNO DE JUROS S/EMPR. E FINANC.
        IF rw_craprej.cdhistor = 0277 THEN

           IF UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'CRAPLEM' THEN /* EMPRESTIMO */
              -- Escrever no arquivo somente os registros que o valor for maior que zero
              IF rw_craprej.vlsdapli > 0 THEN
                 -- Monta o cabecalho da linha
                 IF rw_craprej.cdagenci = 0 THEN

                    -- Verifica se existe afrupamento por PA
                    IF vr_tab_valores_ag.COUNT() > 0 THEN
                      
                       -- escreve a linha duplicada
                       vr_index := vr_tab_valores_ag.FIRST;
                       WHILE vr_index IS NOT NULL LOOP

                          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                        ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita                   

                          vr_index := vr_tab_valores_ag.NEXT(vr_index);
                          
                       END LOOP;
                    
                       -- limpa a table de reveraso
                       vr_tab_valores_ag.DELETE;
                    END IF;

                    IF rw_craprej.nraplica = 1 THEN -- Pessoa Fisica
                       -- Linha de Cabecalho
                       vr_setlinha := fn_set_cabecalho('70'
                                                      ,btch0001.rw_crapdat.dtmvtolt
                                                      ,btch0001.rw_crapdat.dtmvtolt
                                                      ,7010
                                                      ,7116
                                                      ,rw_craprej.vlsdapli
                                                      ,'"ESTORNO DE JUROS S/EMPRESTIMOS - PESSOA FISICA"');
                       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                     ,pr_des_text => vr_setlinha); --> Texto para escrita

                    ELSE -- Pessoa Juridica
                       -- Linha de Cabecalho
                       vr_setlinha := fn_set_cabecalho('70'
                                                      ,btch0001.rw_crapdat.dtmvtolt
                                                      ,btch0001.rw_crapdat.dtmvtolt
                                                      ,7011
                                                      ,7116
                                                      ,rw_craprej.vlsdapli
                                                      ,'"ESTORNO DE JUROS S/EMPRESTIMOS - PESSOA JURIDICA"');
                       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                     ,pr_des_text => vr_setlinha); --> Texto para escrita

                    END IF;
                 ELSE -- Monta as linhas separadas por agencia
                    vr_index := vr_tab_valores_ag.COUNT()+1;
                    vr_tab_valores_ag(vr_index) := LPAD(rw_craprej.cdagenci,3,0)||','
                                                   ||TRIM(TO_CHAR(rw_craprej.vlsdapli,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));

                    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                  ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita
                 END IF;
              END IF;             
           END IF;

        ELSIF rw_craprej.cdhistor = 0098 THEN /* JUROS SOBRE EMPR. E FINANC */
           
           IF UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'CRAPLEM' THEN /* EMPRESTIMO */
              -- Escrever no arquivo somente os registros que o valor for maior que zero
              IF rw_craprej.vlsdapli > 0 THEN
                 -- Monta o cabecalho da linha
                 IF rw_craprej.cdagenci = 0 THEN

                    -- Verifica se existe agrupamento por PA
                    IF vr_tab_valores_ag.COUNT() > 0 THEN
                       
                       -- escreve a linha duplicada
                       vr_index := vr_tab_valores_ag.FIRST;
                       WHILE vr_index IS NOT NULL LOOP

                          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                        ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita                   

                          vr_index := vr_tab_valores_ag.NEXT(vr_index);
                       END LOOP;
                       
                       -- limpa a table de reveraso
                       vr_tab_valores_ag.DELETE;
                    END IF;

                    IF rw_craprej.nraplica = 1 THEN -- Pessoa Fisica
                       -- Linha de Cabecalho
                       vr_setlinha := fn_set_cabecalho('70'
                                                      ,btch0001.rw_crapdat.dtmvtolt
                                                      ,btch0001.rw_crapdat.dtmvtolt
                                                      ,7116
                                                      ,7010
                                                      ,rw_craprej.vlsdapli
                                                      ,'"JUROS SOBRE EMPRESTIMOS - PESSOA FISICA"');
                       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                     ,pr_des_text => vr_setlinha); --> Texto para escrita


                    ELSE -- Pessoa Juridica
                       -- Linha de Cabecalho
                       vr_setlinha := fn_set_cabecalho('70'
                                                      ,btch0001.rw_crapdat.dtmvtolt
                                                      ,btch0001.rw_crapdat.dtmvtolt
                                                      ,7116
                                                      ,7011
                                                      ,rw_craprej.vlsdapli
                                                      ,'"JUROS SOBRE EMPRESTIMOS - PESSOA JURIDICA"');
                       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                     ,pr_des_text => vr_setlinha); --> Texto para escrita


                    END IF;
                 ELSE -- Monta as linhas separadas por agencia
                    vr_index := vr_tab_valores_ag.COUNT()+1;
                    vr_tab_valores_ag(vr_index) := LPAD(rw_craprej.cdagenci,3,0)||','
                                                 ||TRIM(TO_CHAR(rw_craprej.vlsdapli,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));

                    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                  ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita
                 END IF;
              END IF;
           END IF;

        END IF;
           
        -- Verifica se existe o historico na PL-Table
        IF vr_tab_historico.EXISTS(rw_craprej.cdhistor) AND 
           rw_craprej.cdhistor NOT IN (98,277,2093,2094,2090,2091,1038,1072,1544,1713,1722,1070,1542,1710,1510,1719) THEN

              -- Escrever no arquivo somente os registros que o valor for maior que zero
              IF rw_craprej.vlsdapli > 0 THEN

              IF rw_craprej.cdagenci = 0 THEN -- Monta o cabecalho da linha
                    -- Verifica se existe agrupamento por PA
                    IF vr_tab_valores_ag.COUNT() > 0 THEN
                       
                       -- escreve a linha duplicada
                       vr_index := vr_tab_valores_ag.FIRST;
                       WHILE vr_index IS NOT NULL LOOP

                          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                        ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita                   

                          vr_index := vr_tab_valores_ag.NEXT(vr_index);
                       END LOOP;
                       
                       -- limpa a table de reveraso
                       vr_tab_valores_ag.DELETE;

                    END IF;

                    IF rw_craprej.nraplica = 1 THEN -- Pessoa Fisica
                       -- Linha de Cabecalho
                    vr_setlinha := fn_set_cabecalho('70'
                                                      ,btch0001.rw_crapdat.dtmvtolt
                                                   ,btch0001.rw_crapdat.dtmvtolt
                                                   ,vr_tab_historico(rw_craprej.cdhistor).nrctaori_fis
                                                   ,vr_tab_historico(rw_craprej.cdhistor).nrctades_fis
                                                      ,rw_craprej.vlsdapli
                                                   ,'"'||vr_tab_historico(rw_craprej.cdhistor).dsrefere_fis||'"');
                       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                     ,pr_des_text => vr_setlinha); --> Texto para escrita


                    ELSE -- Pessoa Juridica
                       -- Linha de Cabecalho
                    vr_setlinha := fn_set_cabecalho('70'
                                                      ,btch0001.rw_crapdat.dtmvtolt
                                                   ,btch0001.rw_crapdat.dtmvtolt
                                                   ,vr_tab_historico(rw_craprej.cdhistor).nrctaori_jur
                                                   ,vr_tab_historico(rw_craprej.cdhistor).nrctades_jur
                                                      ,rw_craprej.vlsdapli
                                                   ,'"'||vr_tab_historico(rw_craprej.cdhistor).dsrefere_jur||'"');
                       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                     ,pr_des_text => vr_setlinha); --> Texto para escrita

                    END IF;
                 ELSE -- Monta as linhas separadas por agencia
                    vr_index := vr_tab_valores_ag.COUNT()+1;
                    vr_tab_valores_ag(vr_index) := LPAD(rw_craprej.cdagenci,3,0)||','
                                                 ||TRIM(TO_CHAR(rw_craprej.vlsdapli,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));

                    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                  ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita
                 END IF;
           END IF;
        END IF;
     END LOOP;

     -- Quando for o ultimo historico, verifica se existe agrupamento por PA
     IF vr_tab_valores_ag.COUNT() > 0 THEN
                      
                       -- escreve a linha duplicada
                       vr_index := vr_tab_valores_ag.FIRST;
                       WHILE vr_index IS NOT NULL LOOP
                    
                          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                         ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita                   

           vr_index := vr_tab_valores_ag.NEXT(vr_index);
        END LOOP;
                       
              END IF;             
      
     vr_tab_valores_ag.DELETE;
     vr_index := 0;      
     
     --Separação lançamentos microcredito e operação normal.
     FOR rw_craprej IN cr_craprej4(pr_cdcooper,vr_cdprogra,vr_dtmvtolt,1) LOOP

       -- Escrever no arquivo somente os registros que estao nas tabelas de historico
       IF vr_tab_historico.exists(rw_craprej.cdhistor) or vr_tab_historico_mic.exists(rw_craprej.cdhistor) THEN

         IF rw_craprej.cdagenci = 0 THEN -- Monta o cabecalho da linha

                    -- Verifica se existe agrupamento por PA
                    IF vr_tab_valores_ag.COUNT() > 0 THEN
                      
                       -- escreve a linha duplicada
                       vr_index := vr_tab_valores_ag.FIRST;
                       WHILE vr_index IS NOT NULL LOOP

                          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                        ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita                   

                          vr_index := vr_tab_valores_ag.NEXT(vr_index);
                       END LOOP;
                    
                       -- limpa a table de reveraso
                       vr_tab_valores_ag.DELETE;

           END IF; -- fim if count()>0

                    IF rw_craprej.nraplica = 1 THEN -- Pessoa Fisica

              IF rw_craprej.dshistor = 'OPERACAO_NORMAL' THEN
                 -- Linha de Cabecalho
                 vr_setlinha := fn_set_cabecalho('70'
                                                ,btch0001.rw_crapdat.dtmvtolt
                                                ,btch0001.rw_crapdat.dtmvtolt
                                                ,vr_tab_historico(rw_craprej.cdhistor).nrctaori_fis
                                                ,vr_tab_historico(rw_craprej.cdhistor).nrctades_fis
                                                ,rw_craprej.vlsdapli
                                                ,'"'||vr_tab_historico(rw_craprej.cdhistor).dsrefere_fis||'"');
               ELSE
                       -- Linha de Cabecalho
                 vr_setlinha := fn_set_cabecalho('70'
                                                ,btch0001.rw_crapdat.dtmvtolt
                                                      ,btch0001.rw_crapdat.dtmvtolt
                                                ,vr_tab_historico_mic(rw_craprej.cdhistor).nrctaori_fis
                                                ,vr_tab_historico_mic(rw_craprej.cdhistor).nrctades_fis
                                                      ,rw_craprej.vlsdapli
                                                ,'"'||REPLACE(vr_tab_historico_mic(rw_craprej.cdhistor).dsrefere_fis,'pr_origem',rw_craprej.dshistor)||'"');
               END IF;

                       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                     ,pr_des_text => vr_setlinha); --> Texto para escrita


                    ELSE -- Pessoa Juridica
        
             IF rw_craprej.dshistor = 'OPERACAO_NORMAL' THEN
               --Linha de Cabecalho
               vr_setlinha := fn_set_cabecalho('70'
                                               ,btch0001.rw_crapdat.dtmvtolt
                                               ,btch0001.rw_crapdat.dtmvtolt
                                               ,vr_tab_historico(rw_craprej.cdhistor).nrctaori_jur
                                               ,vr_tab_historico(rw_craprej.cdhistor).nrctades_jur
                                               ,rw_craprej.vlsdapli
                                               ,'"'||vr_tab_historico(rw_craprej.cdhistor).dsrefere_jur||'"');
             ELSE
                       -- Linha de Cabecalho
                 vr_setlinha := fn_set_cabecalho('70'
                                                 ,btch0001.rw_crapdat.dtmvtolt
                                                      ,btch0001.rw_crapdat.dtmvtolt
                                                 ,vr_tab_historico_mic(rw_craprej.cdhistor).nrctaori_jur
                                                 ,vr_tab_historico_mic(rw_craprej.cdhistor).nrctades_jur
                                                      ,rw_craprej.vlsdapli
                                                 ,'"'||REPLACE(vr_tab_historico_mic(rw_craprej.cdhistor).dsrefere_jur,'pr_origem',rw_craprej.dshistor)||'"');
             END IF;

                       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                     ,pr_des_text => vr_setlinha); --> Texto para escrita
													           
		  
		  END IF; -- fim if tipo pessoa


                 ELSE -- Monta as linhas separadas por agencia
                    vr_index := vr_tab_valores_ag.COUNT()+1;
                    vr_tab_valores_ag(vr_index) := LPAD(rw_craprej.cdagenci,3,0)||','
                                                 ||TRIM(TO_CHAR(rw_craprej.vlsdapli,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));

                    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                  ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita
         END IF; -- fim monta cabecalho da linha

       END IF; -- validacao de historico

     END LOOP;
     
     -- Quando for o ultimo historico, verifica se existe agrupamento por PA
     IF vr_tab_valores_ag.COUNT() > 0 THEN
        
        -- escreve a linha duplicada
        vr_index := vr_tab_valores_ag.FIRST;
        WHILE vr_index IS NOT NULL LOOP

           gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                         ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita                   

           vr_index := vr_tab_valores_ag.NEXT(vr_index);
        END LOOP;
        
     END IF;
        
     vr_tab_valores_ag.DELETE;
     vr_index := 0;
     
     -- Leitura do Total de rejeitados na integração -- Pessoa Fisica
     FOR rw_craprej IN cr_craprej2(pr_cdcooper,vr_cdprogra,vr_dtmvtolt,1) LOOP

        -- Verifica se existe o historico na PL-Table
        IF vr_tab_historico.EXISTS(rw_craprej.cdhistor) THEN

           -- Escrever no arquivo somente os registros que o valor for maior que zero
           IF rw_craprej.vlsdapli > 0 THEN

              IF rw_craprej.cdagenci = 0 THEN -- Monta o cabecalho da linha

                 -- Verifica se existe agrupamento por PA
                 IF vr_tab_valores_ag.COUNT() > 0 THEN
                    
                    -- escreve a linha duplicada
                    vr_index := vr_tab_valores_ag.FIRST;
                    WHILE vr_index IS NOT NULL LOOP

                       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                     ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita                   

                       vr_index := vr_tab_valores_ag.NEXT(vr_index);
                    END LOOP;
                    
                    -- limpa a table de reveraso
                    vr_tab_valores_ag.DELETE;

                 ELSE
                 IF rw_craprej.nraplica = 1 THEN -- Pessoa Fisica
                    -- Linha de Cabecalho
                       vr_setlinha := fn_set_cabecalho('70'
                                                   ,btch0001.rw_crapdat.dtmvtolt
                                                      ,btch0001.rw_crapdat.dtmvtolt
                                                   ,vr_tab_historico(rw_craprej.cdhistor).nrctaori_fis
                                                   ,vr_tab_historico(rw_craprej.cdhistor).nrctades_fis
                                                   ,rw_craprej.vlsdapli
                                                   ,'"'||vr_tab_historico(rw_craprej.cdhistor).dsrefere_fis||'"');
                    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                  ,pr_des_text => vr_setlinha); --> Texto para escrita


                 ELSE -- Pessoa Juridica

                    -- Linha de Cabecalho
                       vr_setlinha := fn_set_cabecalho('70'
                                                   ,btch0001.rw_crapdat.dtmvtolt
                                                      ,btch0001.rw_crapdat.dtmvtolt
                                                   ,vr_tab_historico(rw_craprej.cdhistor).nrctaori_jur
                                                   ,vr_tab_historico(rw_craprej.cdhistor).nrctades_jur
                                                   ,rw_craprej.vlsdapli
                                                   ,'"'||vr_tab_historico(rw_craprej.cdhistor).dsrefere_jur||'"');
                    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                  ,pr_des_text => vr_setlinha); --> Texto para escrita

                    
                    END IF;
                    
                 END IF;
              ELSE -- Monta as linhas separadas por agencia
                 vr_index := vr_tab_valores_ag.COUNT()+1;
                 vr_tab_valores_ag(vr_index) := LPAD(rw_craprej.cdagenci,3,0)||','
                                              ||TRIM(TO_CHAR(rw_craprej.vlsdapli,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));

                 gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                               ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita
              END IF;
           END IF;
        END IF;
     END LOOP;
     
     -- Quando for o ultimo historico, Verifica se existe agrupamento por PA
     IF vr_tab_valores_ag.COUNT() > 0 THEN
        
        -- escreve a linha duplicada
        vr_index := vr_tab_valores_ag.FIRST;
        WHILE vr_index IS NOT NULL LOOP

           gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                         ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita                   

           vr_index := vr_tab_valores_ag.NEXT(vr_index);
        END LOOP;
        
     END IF;
     
     vr_tab_valores_ag.DELETE;
     vr_index := 0;
     
     -- Leitura do Total de rejeitados na integração -- Pessoa Fisica
     FOR rw_craprej IN cr_craprej3(pr_cdcooper,vr_cdprogra,vr_dtmvtolt,1) LOOP

        -- Verifica se existe o historico na PL-Table
        IF vr_tab_historico.EXISTS(rw_craprej.cdhistor) THEN
          
           -- Escrever no arquivo somente os registros que o valor for maior que zero
           IF rw_craprej.vlsdapli > 0 THEN

              IF rw_craprej.cdagenci = 0 THEN -- Monta o cabecalho da linha

                 -- Verifica se existe agrupamento por PA
                 IF vr_tab_valores_ag.COUNT() > 0 THEN
                   
                    -- escreve a linha duplicada
                    vr_index := vr_tab_valores_ag.FIRST;
                    WHILE vr_index IS NOT NULL LOOP

                       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                     ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita                   

                       vr_index := vr_tab_valores_ag.NEXT(vr_index);
                    END LOOP;
                 
                    -- limpa a table de reveraso
                    vr_tab_valores_ag.DELETE;

                 ELSE
                    IF rw_craprej.nraplica = 1 THEN -- Pessoa Fisica
                       -- Linha de Cabecalho
                       vr_setlinha := fn_set_cabecalho('70'
                                                      ,btch0001.rw_crapdat.dtmvtolt
                                                      ,btch0001.rw_crapdat.dtmvtolt
                                                      ,vr_tab_historico(rw_craprej.cdhistor).nrctaori_fis
                                                      ,vr_tab_historico(rw_craprej.cdhistor).nrctades_fis
                                                      ,rw_craprej.vlsdapli
                                                      ,'"'||vr_tab_historico(rw_craprej.cdhistor).dsrefere_fis||'"');
                       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                     ,pr_des_text => vr_setlinha); --> Texto para escrita
                    ELSE -- Pessoa Juridica

                       -- Linha de Cabecalho
                       vr_setlinha := fn_set_cabecalho('70'
                                                      ,btch0001.rw_crapdat.dtmvtolt
                                                      ,btch0001.rw_crapdat.dtmvtolt
                                                      ,vr_tab_historico(rw_craprej.cdhistor).nrctaori_jur
                                                      ,vr_tab_historico(rw_craprej.cdhistor).nrctades_jur
                                                      ,rw_craprej.vlsdapli
                                                      ,'"'||vr_tab_historico(rw_craprej.cdhistor).dsrefere_jur||'"');
                       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                     ,pr_des_text => vr_setlinha); --> Texto para escrita
                    END IF;
                    
                 END IF;
              ELSE -- Monta as linhas separadas por agencia
                 vr_index := vr_tab_valores_ag.COUNT()+1;
                 vr_tab_valores_ag(vr_index) := LPAD(rw_craprej.cdagenci,3,0)||','
                                              ||TRIM(TO_CHAR(rw_craprej.vlsdapli,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));

                 gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                               ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita
              END IF;
           END IF;
        END IF;
     END LOOP;
     
     -- Quando for o ultimo historico, Verifica se existe agrupamento por PA
     IF vr_tab_valores_ag.COUNT() > 0 THEN
     
        -- escreve a linha duplicada
        vr_index := vr_tab_valores_ag.FIRST;
        WHILE vr_index IS NOT NULL LOOP

           gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                         ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita                   

           vr_index := vr_tab_valores_ag.NEXT(vr_index);
        END LOOP;  
     END IF;
     
     vr_tab_valores_ag.DELETE;

     -- Fechar Arquivo
     BEGIN
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
     EXCEPTION
        WHEN OTHERS THEN
         --Inclusão na tabela de erros Oracle - Chamado 734422
         CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);                                                             
        -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
         vr_cdcritic := 1039;
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' <'||vr_nom_diretorio||'/'||vr_nmarqdat_ope_cred||'>: ' || SQLERRM;
        RAISE vr_exc_erro;
     END;
     
     -- Limpa Pl-Table
     vr_tab_historico.DELETE;
     vr_arq_op_cred.DELETE;
     
  EXCEPTION
     WHEN vr_exc_erro THEN
        NULL;
     WHEN OTHERS THEN
       --Inclusão na tabela de erros Oracle - Chamado 734422
       CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);                                                             
       vr_cdcritic := 1044;
       vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' AAMMDD_OP_CRED.txt. Erro: '|| SQLERRM;
  END;

  --
  PROCEDURE pc_gera_arq_prejuizo (pr_dscritic OUT VARCHAR2) IS

     -- Variaveis
     vr_input_file     UTL_FILE.file_type;             --> Handle Utl File
     vr_setlinha       VARCHAR2(400);                  --> Linhas do arquivo
     vr_index          NUMBER := 0;
     vr_aux_contador   number := 0;

     -- Variavel de Exception
     vr_exc_erro EXCEPTION;
     
     -- Inicializa tabela de Historicos
     PROCEDURE pc_inicia_historico_prejuizo IS
     BEGIN
        -- Inclusão do módulo e ação logado - Chamado 734422 - 03/11/2017
        GENE0001.pc_set_modulo(pr_module => 'PC_CRPS249.pc_inicia_historico_prejuizo', pr_action => NULL);
        vr_tab_historico.DELETE;

        vr_tab_historico(0349).nrctaori_fis := 8447;
        vr_tab_historico(0349).nrctades_fis := 8442;
        vr_tab_historico(0349).dsrefere_fis := 'EMPRESTIMO TRANSFERIDO PARA PREJUIZO - PESSOA FISICA';
        vr_tab_historico(0349).nrctaori_jur := 8448;
        vr_tab_historico(0349).nrctades_jur := 8442;
        vr_tab_historico(0349).dsrefere_jur := 'EMPRESTIMO TRANSFERIDO PARA PREJUIZO - PESSOA JURIDICA';

        vr_tab_historico(0350).nrctaori_fis := 8447;
        vr_tab_historico(0350).nrctades_fis := 8442;
        vr_tab_historico(0350).dsrefere_fis := 'SALDO DEVEDOR C/C TRANSFERIDO PARA PREJUIZO - PESSOA FISICA';
        vr_tab_historico(0350).nrctaori_jur := 8448;
        vr_tab_historico(0350).nrctades_jur := 8442;
        vr_tab_historico(0350).dsrefere_jur := 'SALDO DEVEDOR C/C TRANSFERIDO PARA PREJUIZO - PESSOA JURIDICA';

        vr_tab_historico(1731).nrctaori_fis := 8447;
        vr_tab_historico(1731).nrctades_fis := 8442;
        vr_tab_historico(1731).dsrefere_fis := 'EMPRESTIMO PRE FIXADO TRANSFERIDO PARA PREJUIZO - PESSOA FISICA';
        vr_tab_historico(1731).nrctaori_jur := 8448;
        vr_tab_historico(1731).nrctades_jur := 8442;
        vr_tab_historico(1731).dsrefere_jur := 'EMPRESTIMO PRE FIXADO TRANSFERIDO PARA PREJUIZO - PESSOA JURIDICA';
        
        vr_tab_historico(1732).nrctaori_fis := 8447;
        vr_tab_historico(1732).nrctades_fis := 8442;
        vr_tab_historico(1732).dsrefere_fis := 'FINANCIAMENTO PRE FIXADO TRANSFERIDO PARA PREJUIZO - PESSOA FISICA';
        vr_tab_historico(1732).nrctaori_jur := 8448;
        vr_tab_historico(1732).nrctades_jur := 8442;
        vr_tab_historico(1732).dsrefere_jur := 'FINANCIAMENTO PRE FIXADO TRANSFERIDO PARA PREJUIZO - PESSOA JURIDICA';        
        
     END;  

  BEGIN
     -- Inclusão do módulo e ação logado - Chamado 734422 - 03/11/2017
     GENE0001.pc_set_modulo(pr_module => 'PC_CRPS249.pc_gera_arq_prejuizo', pr_action => NULL);
     
     -- Inicia Variavel
     pr_dscritic := NULL;
        
     -- Inicializa Pl-Table
     pc_inicia_historico_prejuizo;
     
     -- Nome do arquivo a ser gerado
     vr_nmarqdat_prejuizo := vr_dtmvtolt_yymmdd||'_PREJUIZO.txt';
     
     vr_tab_valores_ag.DELETE;
     vr_index := 0;
     

     -- Leitura do Total de rejeitados na integração -- Pessoa Fisica
     FOR rw_craprej IN cr_craprej(pr_cdcooper,vr_cdprogra,vr_dtmvtolt,1) LOOP

        -- Verifica se existe o historico na PL-Table
        IF vr_tab_historico.EXISTS(rw_craprej.cdhistor) THEN
          
           -- Escrever no arquivo somente os registros que o valor for maior que zero
           IF rw_craprej.vlsdapli > 0 THEN

              IF rw_craprej.cdagenci = 0 THEN -- Monta o cabecalho da linha
                 -- Verifica se existe agrupamento por PA
                 IF vr_tab_valores_ag.COUNT() > 0 THEN
                 
                    -- escreve a linha duplicada
                    vr_index := vr_tab_valores_ag.FIRST;
                    WHILE vr_index IS NOT NULL LOOP

                       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                     ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita                   

                       vr_index := vr_tab_valores_ag.NEXT(vr_index);
                    END LOOP;  

                    -- limpa a table de reveraso
                    vr_tab_valores_ag.DELETE;

                 END IF;
                 
                 vr_aux_contador := vr_aux_contador +1;
                 
                 IF vr_aux_contador = 1 THEN
                    -- Tenta abrir o arquivo de log em modo gravacao
                    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio     --> Diretório do arquivo
                                            ,pr_nmarquiv => vr_nmarqdat_prejuizo --> Nome do arquivo
                                            ,pr_tipabert => 'W'                  --> Modo de abertura (R,W,A)
                                            ,pr_utlfileh => vr_input_file        --> Handle do arquivo aberto
                                            ,pr_des_erro => vr_dscritic);        --> Erro
                    IF vr_dscritic IS NOT NULL THEN
                       -- Levantar Excecao
                        RAISE vr_exc_erro;
                   END IF;  
                 END IF;
                  
                    IF rw_craprej.nraplica = 1 THEN -- Pessoa Fisica
                       -- Linha de Cabecalho
                    vr_setlinha := fn_set_cabecalho('50'
                                                      ,btch0001.rw_crapdat.dtmvtolt
                                                      ,btch0001.rw_crapdat.dtmvtolt
                                                      ,vr_tab_historico(rw_craprej.cdhistor).nrctaori_fis
                                                      ,vr_tab_historico(rw_craprej.cdhistor).nrctades_fis
                                                      ,rw_craprej.vlsdapli
                                                      ,'"'||vr_tab_historico(rw_craprej.cdhistor).dsrefere_fis||'"');
                       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                     ,pr_des_text => vr_setlinha); --> Texto para escrita


                    ELSE -- Pessoa Juridica
                       -- Linha de Cabecalho
                    vr_setlinha := fn_set_cabecalho('50'
                                                      ,btch0001.rw_crapdat.dtmvtolt
                                                      ,btch0001.rw_crapdat.dtmvtolt
                                                      ,vr_tab_historico(rw_craprej.cdhistor).nrctaori_jur
                                                      ,vr_tab_historico(rw_craprej.cdhistor).nrctades_jur
                                                      ,rw_craprej.vlsdapli
                                                      ,'"'||vr_tab_historico(rw_craprej.cdhistor).dsrefere_jur||'"');
                       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                     ,pr_des_text => vr_setlinha); --> Texto para escrita

                    END IF;
              ELSE -- Monta as linhas separadas por agencia
                 vr_index := vr_tab_valores_ag.COUNT()+1;
                 vr_tab_valores_ag(vr_index) := LPAD(rw_craprej.cdagenci,3,0)||','
                                          ||TRIM(TO_CHAR(rw_craprej.vlsdapli,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));

                 gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                               ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita
              END IF;
           END IF;
        END IF;
     END LOOP;
     
     -- Quando for o ultimo historico, verifica se existe agrupamento por PA
     IF vr_tab_valores_ag.COUNT() > 0 THEN
     
        -- escreve a linha duplicada
        vr_index := vr_tab_valores_ag.FIRST;
        WHILE vr_index IS NOT NULL LOOP
     
           gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                         ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita                   

           vr_index := vr_tab_valores_ag.NEXT(vr_index);
        END LOOP;
        
                    END IF;
                    
     vr_tab_valores_ag.DELETE;

     IF vr_aux_contador > 0 THEN
       -- Fechar Arquivo
       BEGIN
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
       EXCEPTION
          WHEN OTHERS THEN
          --Inclusão na tabela de erros Oracle - Chamado 734422
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);                                                             
          -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
          vr_cdcritic := 1039;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' <'||vr_nom_diretorio||'/'||vr_nmarqdat_prejuizo||'>: ' || SQLERRM;
          RAISE vr_exc_erro;
       END;
     
       vr_nmarqdat_prejuizo_nov := vr_dtmvtolt_yymmdd||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_PREJUIZO.txt';

       -- Copia o arquivo gerado para o diretório final convertendo para DOS
       gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarqdat_prejuizo||' > '||vr_dsdircop||'/'||vr_nmarqdat_prejuizo_nov||' 2>/dev/null',
                                   pr_typ_saida   => vr_typ_said,
                                   pr_des_saida   => vr_dscritic);
       -- Testar erro
       if vr_typ_said = 'ERR' then
         vr_cdcritic := 1040;
         gene0001.pc_print(gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_nmarqdat_prejuizo||': '||vr_dscritic);
       end if;   
       
                 END IF;
     
     -- Limpa Pl-Table
     vr_tab_historico.DELETE;
     
  EXCEPTION
     WHEN vr_exc_erro THEN
        NULL;
     WHEN OTHERS THEN
       --Inclusão na tabela de erros Oracle - Chamado 734422
       CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);                                                             
       vr_cdcritic := 1044;
       pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' AAMMDD_PREJUIZO.txt. Erro: '|| SQLERRM;
  END;

  PROCEDURE pc_gera_arq_tarifasbb (pr_dscritic OUT VARCHAR2) IS

     -- Variaveis
     vr_input_file     UTL_FILE.file_type;             --> Handle Utl File
     vr_setlinha       VARCHAR2(400);                  --> Linhas do arquivo
     vr_index          NUMBER := 0;
     vr_aux_contador   NUMBER := 0;

     -- Variavel de Exception
     vr_exc_erro EXCEPTION;
     
  BEGIN
     -- Inclusão do módulo e ação logado - Chamado 734422 - 03/11/2017
     GENE0001.pc_set_modulo(pr_module => 'PC_CRPS249.pc_gera_arq_tarifasbb', pr_action => NULL);
     
     -- Inicia Variavel
     pr_dscritic := NULL;

     -- Nome do arquivo a ser gerado
     vr_nmarqdat_tarifasbb := vr_dtmvtolt_yymmdd||'_TARIFASBB.txt';

     vr_tab_valores_ag.DELETE;
     vr_index := 0;
     

     -- Leitura do Total de rejeitados na integração -- Pessoa Fisica
     FOR rw_craprej IN cr_craprej(pr_cdcooper,vr_cdprogra,vr_dtmvtolt,1) LOOP

        -- Verifica se existe o historico na PL-Table
        IF rw_craprej.cdhistor IN (267,779,967,968,969,970,972,974,975,976,980,985,986,1223,1315,1317,
           1319,1320,1321,1323,1325,1327,1329,1331,1333,1335,1337,1535,2028,2029,2032,2033) THEN
          
           -- Escrever no arquivo somente os registros que o valor for maior que zero
           IF rw_craprej.vlsdapli > 0 THEN

              IF rw_craprej.cdagenci = 0 THEN -- Monta o cabecalho da linha
                 -- Verifica se existe agrupamento por PA
                 IF vr_tab_valores_ag.COUNT() > 0 THEN

                    -- escreve a linha duplicada
                    vr_index := vr_tab_valores_ag.FIRST;
                    WHILE vr_index IS NOT NULL LOOP

                       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                     ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita                   

                       vr_index := vr_tab_valores_ag.NEXT(vr_index);
                    END LOOP;
                 
                    -- limpa a table de reveraso
                    vr_tab_valores_ag.DELETE;

                 END IF;
                 
                 vr_aux_contador := vr_aux_contador +1;
                 
                 --
                 IF vr_aux_contador = 1 THEN
                    -- Tenta abrir o arquivo de log em modo gravacao
                    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio     --> Diretório do arquivo
                                            ,pr_nmarquiv => vr_nmarqdat_tarifasbb --> Nome do arquivo
                                            ,pr_tipabert => 'W'                  --> Modo de abertura (R,W,A)
                                            ,pr_utlfileh => vr_input_file        --> Handle do arquivo aberto
                                            ,pr_des_erro => vr_dscritic);        --> Erro
                    IF vr_dscritic IS NOT NULL THEN
                       -- Levantar Excecao
                        RAISE vr_exc_erro;
                   END IF;  
                 END IF;                 
                 --
                  
                 IF rw_craprej.nraplica = 1 THEN -- Pessoa Fisica
                    -- Linha de Cabecalho
                    vr_setlinha := fn_set_cabecalho('20'
                                                   ,btch0001.rw_crapdat.dtmvtolt
                                                   ,btch0001.rw_crapdat.dtmvtolt
                                                   ,7258
                                                   ,7048 
                                                   ,rw_craprej.vlsdapli
                                                   ,'"RECEITA COBRANCA BB - PESSOA FISICA"');
                       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                     ,pr_des_text => vr_setlinha); --> Texto para escrita
                    

                 ELSE -- Pessoa Juridica
                    -- Linha de Cabecalho
                    vr_setlinha := fn_set_cabecalho('20'
                                                   ,btch0001.rw_crapdat.dtmvtolt
                                                   ,btch0001.rw_crapdat.dtmvtolt
                                                   ,7258
                                                   ,7049
                                                   ,rw_craprej.vlsdapli
                                                   ,'"RECEITA COBRANCA BB - PESSOA JURIDICA"');
                    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                  ,pr_des_text => vr_setlinha); --> Texto para escrita

                    END IF;
              ELSE -- Monta as linhas separadas por agencia
                 vr_index := vr_tab_valores_ag.COUNT()+1;
                 vr_tab_valores_ag(vr_index) := LPAD(rw_craprej.cdagenci,3,0)||','
                                              ||TRIM(TO_CHAR(rw_craprej.vlsdapli,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));

                 gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                               ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita
              END IF;
           END IF;
                    
        ELSIF rw_craprej.cdhistor IN (1023,1316,1318,1322,1324,1326,1328,1330,1332,1334,1336,1338,2030,2031,2034,2035) THEN

           -- Escrever no arquivo somente os registros que o valor for maior que zero
           IF rw_craprej.vlsdapli > 0 THEN

              IF rw_craprej.cdagenci = 0 THEN -- Monta o cabecalho da linha
                 -- Verifica se existe agrupamento por PA
                 IF vr_tab_valores_ag.COUNT() > 0 THEN
                    
                    -- escreve a linha duplicada
                    vr_index := vr_tab_valores_ag.FIRST;
                    WHILE vr_index IS NOT NULL LOOP

                       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                     ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita                   

                       vr_index := vr_tab_valores_ag.NEXT(vr_index);
                    END LOOP;

                    -- limpa a table de reveraso
                    vr_tab_valores_ag.DELETE;

        END IF;
                 
                 vr_aux_contador := vr_aux_contador +1;
                 
                 IF vr_aux_contador = 1 THEN
                    -- Tenta abrir o arquivo de log em modo gravacao
                    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio     --> Diretório do arquivo
                                            ,pr_nmarquiv => vr_nmarqdat_tarifasbb --> Nome do arquivo
                                            ,pr_tipabert => 'W'                  --> Modo de abertura (R,W,A)
                                            ,pr_utlfileh => vr_input_file        --> Handle do arquivo aberto
                                            ,pr_des_erro => vr_dscritic);        --> Erro
                    IF vr_dscritic IS NOT NULL THEN
                       -- Levantar Excecao
                        RAISE vr_exc_erro;
                   END IF;  
                 END IF;                 
                  
                    IF rw_craprej.nraplica = 1 THEN -- Pessoa Fisica
                       -- Linha de Cabecalho
                    vr_setlinha := fn_set_cabecalho('20'
                                                      ,btch0001.rw_crapdat.dtmvtolt
                                                   ,btch0001.rw_crapdat.dtmvtolt
                                                   ,7048
                                                   ,7258 
                                                      ,rw_craprej.vlsdapli
                                                   ,'"ESTORNO RECEITA COBRANCA BB - PESSOA FISICA"');
                       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                     ,pr_des_text => vr_setlinha); --> Texto para escrita


                 ELSE -- Pessoa Juridica
                    -- Linha de Cabecalho
                    vr_setlinha := fn_set_cabecalho('20'
                                                   ,btch0001.rw_crapdat.dtmvtolt
                                                   ,btch0001.rw_crapdat.dtmvtolt
                                                   ,7049
                                                   ,7258
                                                   ,rw_craprej.vlsdapli
                                                   ,'"ESTORNO RECEITA COBRANCA BB - PESSOA JURIDICA"');
                    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                  ,pr_des_text => vr_setlinha); --> Texto para escrita

                 END IF;
              ELSE -- Monta as linhas separadas por agencia
                 vr_index := vr_tab_valores_ag.COUNT()+1;
                 vr_tab_valores_ag(vr_index) := LPAD(rw_craprej.cdagenci,3,0)||','
                                              ||TRIM(TO_CHAR(rw_craprej.vlsdapli,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));

                 gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                               ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita
              END IF;
           END IF;
        
        ELSIF rw_craprej.cdhistor = 1662 THEN

           -- Escrever no arquivo somente os registros que o valor for maior que zero
           IF rw_craprej.vlsdapli > 0 THEN

              IF rw_craprej.cdagenci = 0 THEN -- Monta o cabecalho da linha
                 -- Verifica se existe agrupamento por PA
                 IF vr_tab_valores_ag.COUNT() > 0 THEN
                    
                    -- escreve a linha duplicada
                    vr_index := vr_tab_valores_ag.FIRST;
                    WHILE vr_index IS NOT NULL LOOP

                       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                     ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita                   

                       vr_index := vr_tab_valores_ag.NEXT(vr_index);
                    END LOOP;

                    -- limpa a table de reveraso
                    vr_tab_valores_ag.DELETE;

        END IF;
                 
                 vr_aux_contador := vr_aux_contador +1;
                 
                 IF vr_aux_contador = 1 THEN
                    -- Tenta abrir o arquivo de log em modo gravacao
                    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio     --> Diretório do arquivo
                                            ,pr_nmarquiv => vr_nmarqdat_tarifasbb --> Nome do arquivo
                                            ,pr_tipabert => 'W'                  --> Modo de abertura (R,W,A)
                                            ,pr_utlfileh => vr_input_file        --> Handle do arquivo aberto
                                            ,pr_des_erro => vr_dscritic);        --> Erro
                    IF vr_dscritic IS NOT NULL THEN
                       -- Levantar Excecao
                        RAISE vr_exc_erro;
                   END IF;  
                 END IF;                 

                 IF rw_craprej.nraplica = 1 THEN -- Pessoa Fisica
                       -- Linha de Cabecalho
                    vr_setlinha := fn_set_cabecalho('20'
                                                   ,btch0001.rw_crapdat.dtmvtolt
                                                      ,btch0001.rw_crapdat.dtmvtolt
                                                   ,7053
                                                   ,7468 
                                                      ,rw_craprej.vlsdapli
                                                   ,'"RECEITA COBRANCA CECRED (MANUAL) - PESSOA FISICA"');
                       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                     ,pr_des_text => vr_setlinha); --> Texto para escrita


                 ELSE -- Pessoa Juridica
                    -- Linha de Cabecalho
                    vr_setlinha := fn_set_cabecalho('20'
                                                   ,btch0001.rw_crapdat.dtmvtolt
                                                   ,btch0001.rw_crapdat.dtmvtolt
                                                   ,7053
                                                   ,7343
                                                   ,rw_craprej.vlsdapli
                                                   ,'"RECEITA COBRANCA CECRED (MANUAL) - PESSOA JURIDICA"');
                    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                  ,pr_des_text => vr_setlinha); --> Texto para escrita
                    
                 END IF;
              ELSE -- Monta as linhas separadas por agencia
                 vr_index := vr_tab_valores_ag.COUNT()+1;
                 vr_tab_valores_ag(vr_index) := LPAD(rw_craprej.cdagenci,3,0)||','
                                          ||TRIM(TO_CHAR(rw_craprej.vlsdapli,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));

                 gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                               ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita
              END IF;
           END IF;
        END IF;
     END LOOP;
     
     -- Quando for o ultimo historico, verifica se existe agrupamento por PA
     IF vr_tab_valores_ag.COUNT() > 0 THEN
       
        -- escreve a linha duplicada
        vr_index := vr_tab_valores_ag.FIRST;
        WHILE vr_index IS NOT NULL LOOP

           gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                         ,pr_des_text => vr_tab_valores_ag(vr_index)); --> Texto para escrita                   

           vr_index := vr_tab_valores_ag.NEXT(vr_index);
        END LOOP;
        
     END IF;
     
     --
     FOR rw_craprej IN cr_crapret4(pr_cdcooper,vr_dtmvtolt) LOOP

       IF rw_craprej.inpessoa = 1 then

         IF vr_tab_vlr_age_fis.EXISTS(rw_craprej.cdagenci) THEN
           -- Soma os valores por agencia de pessoa fisica
           vr_tab_vlr_age_fis(rw_craprej.cdagenci) := vr_tab_vlr_age_fis(rw_craprej.cdagenci) +  rw_craprej.vldespes;
         
         ELSE
         -- Inicializa o array com o valor inicial de pessoa fisica
           vr_tab_vlr_age_fis(rw_craprej.cdagenci) := rw_craprej.vldespes;
         END IF;
         
      ELSE
        IF vr_tab_vlr_age_jur.EXISTS(rw_craprej.cdagenci) THEN
           -- Soma os valores por agencia de pessoa jurídica
           vr_tab_vlr_age_jur(rw_craprej.cdagenci) := vr_tab_vlr_age_jur(rw_craprej.cdagenci) + rw_craprej.vldespes;
         
         ELSE
         -- Inicializa o array com o valor inicial de pessoa fisica
           vr_tab_vlr_age_jur(rw_craprej.cdagenci) := rw_craprej.vldespes;
         END IF;

      END IF; 
      --Totalizar valores por tipo de pessoa
      IF vr_tab_vlr_descbr_pes.EXISTS(rw_craprej.inpessoa) THEN
        -- Soma os valores por tipo de pessoa
        vr_tab_vlr_descbr_pes(rw_craprej.inpessoa) := vr_tab_vlr_descbr_pes(rw_craprej.inpessoa) + rw_craprej.vldespes;
      ELSE
        -- Inicializa o array com o valor inicial de cada tipo de pessoa
        vr_tab_vlr_descbr_pes(rw_craprej.inpessoa) := rw_craprej.vldespes;
     END IF;
     
     END LOOP; 
     
     --
     FOR indpes IN 1..2 LOOP
       
       IF vr_tab_vlr_descbr_pes.EXISTS(indpes) THEN
         
         vr_aux_contador := vr_aux_contador +1;
                     
         IF vr_aux_contador = 1 THEN
            -- Tenta abrir o arquivo de log em modo gravacao
            gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio     --> Diretório do arquivo
                                    ,pr_nmarquiv => vr_nmarqdat_tarifasbb --> Nome do arquivo
                                    ,pr_tipabert => 'W'                  --> Modo de abertura (R,W,A)
                                    ,pr_utlfileh => vr_input_file        --> Handle do arquivo aberto
                                    ,pr_des_erro => vr_dscritic);        --> Erro
            IF vr_dscritic IS NOT NULL THEN
               -- Levantar Excecao
                RAISE vr_exc_erro;
           END IF;  
         END IF;       
       
         IF indpes = 1 THEN
           vr_setlinha := fn_set_cabecalho('20'
                                           ,btch0001.rw_crapdat.dtmvtolt
                                           ,btch0001.rw_crapdat.dtmvtolt
                                           ,8464
                                           ,8309
                                           ,vr_tab_vlr_descbr_pes(indpes)
                                           ,'"DESPESA COBRANCA BB - PESSOA FISICA"'); 
         ELSE
           vr_setlinha := fn_set_cabecalho('20'
                                           ,btch0001.rw_crapdat.dtmvtolt
                                           ,btch0001.rw_crapdat.dtmvtolt
                                           ,8465
                                           ,8309
                                           ,vr_tab_vlr_descbr_pes(indpes)
                                           ,'"DESPESA COBRANCA BB - PESSOA JURIDICA"');            
         END IF;  
         
         gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                       ,pr_des_text => vr_setlinha); --> Texto para escrita
         
         FOR repete IN 1..2 LOOP
           IF indpes = 1 THEN
             vr_index := vr_tab_vlr_age_fis.first;
             
             WHILE vr_index IS NOT NULL LOOP
               vr_setlinha := LPAD(vr_index,3,0)||','
                              ||TRIM(TO_CHAR(vr_tab_vlr_age_fis(vr_index),'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));

           gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita  
                                               
               vr_index := vr_tab_vlr_age_fis.next(vr_index);                   
             END LOOP; 
           ELSE
             vr_index := vr_tab_vlr_age_jur.first;
        
             WHILE vr_index IS NOT NULL LOOP
               vr_setlinha := LPAD(vr_index,3,0)||','
                              ||TRIM(TO_CHAR(vr_tab_vlr_age_jur(vr_index),'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));

               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita   
               
               vr_index := vr_tab_vlr_age_jur.next(vr_index);
               
             END LOOP;              
           END IF;  
        END LOOP;
     END IF;
     END LOOP;
     
     vr_tab_valores_ag.DELETE;
     vr_tab_vlr_descbr_pes.DELETE;
     vr_tab_vlr_age_fis.DELETE;
     vr_tab_vlr_age_jur.DELETE;

     IF vr_aux_contador > 0 THEN
     -- Fechar Arquivo
     BEGIN
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
     EXCEPTION
        WHEN OTHERS THEN
        --Inclusão na tabela de erros Oracle - Chamado 734422
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);                                                             
        -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
        vr_cdcritic := 1039;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' <'||vr_nom_diretorio||'/'||vr_nmarqdat_prejuizo||'>: ' || SQLERRM;
        RAISE vr_exc_erro;
     END;
     
       vr_nmarqdat_tarifasbb_nov := vr_dtmvtolt_yymmdd||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_TARIFASBB.txt';

       -- Copia o arquivo gerado para o diretório final convertendo para DOS
       gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarqdat_tarifasbb||' > '||vr_dsdircop||'/'||vr_nmarqdat_tarifasbb_nov||' 2>/dev/null',
                                   pr_typ_saida   => vr_typ_said,
                                   pr_des_saida   => vr_dscritic);
       -- Testar erro
       if vr_typ_said = 'ERR' then
         vr_cdcritic := 1040;
         gene0001.pc_print(gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_nmarqdat_tarifasbb||': '||vr_dscritic);
       end if;   
       
     END IF;     
     
     -- Limpa Pl-Table
     vr_tab_historico.DELETE;
     
  EXCEPTION
     WHEN vr_exc_erro THEN
        NULL;
     WHEN OTHERS THEN
       --Inclusão na tabela de erros Oracle - Chamado 734422
       CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);                                                             
       pr_dscritic := gene0001.fn_busca_critica(1050)||' AAMMDD_PREJUIZO.txt. Erro: '||SQLERRM;
  END;


  -------------------------------------
  -- Inicio Bloco Principal pc_crps249
  -------------------------------------

BEGIN

  -- Nome do programa
  vr_cdprogra := 'CRPS249';

   -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

  -- Validações iniciais do programa
  vr_cdcritic := 0;
  btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => vr_cdcritic);
  -- Se retornou algum erro
  if vr_cdcritic <> 0 then
    -- Envio centralizado de log de erro
    raise vr_exc_saida;
  end if;

  -- Buscar a data do movimento
  OPEN  btch0001.cr_crapdat(pr_cdcooper);
  FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  -- Carrega as variáveis
  vr_dtmvtolt := btch0001.rw_crapdat.dtmvtolt;
  vr_dtmvtopr := btch0001.rw_crapdat.dtmvtopr;
  vr_dtmvtoan := btch0001.rw_crapdat.dtmvtoan;

  vr_dtultdia := btch0001.rw_crapdat.dtultdia;
  vr_dtultdma := btch0001.rw_crapdat.dtultdma;

  -- Buscar os dados da cooperativa
  OPEN  cr_crapcop(pr_cdcooper);
  FETCH cr_crapcop INTO rw_crapcop;
  IF cr_crapcop%NOTFOUND THEN
    CLOSE cr_crapcop;
    vr_cdcritic := 651;
    RAISE vr_exc_saida;
  END IF;
  CLOSE cr_crapcop;
  --  Le tabela com as contas convenio do Banco do Brasil
  vr_lscontas := gene0005.fn_busca_conta_centralizadora(pr_cdcooper, 0);
  IF vr_lscontas IS NULL THEN
    vr_cdcritic := 393;
    RAISE vr_exc_saida;
  END IF;
  --
  vr_lsconta4 := gene0005.fn_busca_conta_centralizadora(pr_cdcooper, 4);
  IF vr_lsconta4 IS NULL THEN
    vr_cdcritic := 393;
    RAISE vr_exc_saida;
  ELSE
    vr_rel_nrdctabb := to_number(fn_ultctaconve(vr_lsconta4));
  END IF;

  -- Limpa PL/Tables
  vr_tab_agencia.delete;
  vr_tab_agencia2.delete;
  -- Busca informações no histórico
  for rw_craphis in cr_craphis (pr_cdcooper) LOOP
    
    -- Busca a tarifa
    open cr_crapthi(pr_cdcooper,
                    rw_craphis.cdhistor,
                    'AYLLOS');
      fetch cr_crapthi into rw_crapthi;
      if cr_crapthi%notfound then
        close cr_crapthi;
        vr_cdcritic := 1041;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' para histórico '||rw_craphis.cdhistor||' - crapthi';
        -- Gera a mensagem de erro no log e não prossegue a rotina.
        btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro de Negócio
                                  ,pr_nmarqlog      => 'proc_batch.log'
                                  ,pr_tpexecucao    => 1 -- Job
                                  ,pr_cdcriticidade => 1 -- Medio
                                  ,pr_cdmensagem    => vr_cdcritic
                                  ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                      ||vr_cdprogra||' --> '||vr_dscritic);
        -- Troca de return por raise - Chamado 832035 - 16/01/2018 
        --return;
        RAISE vr_exc_saida;                    
      end if;
    close cr_crapthi;
    --
    
    if rw_craphis.tpctbcxa > 3 then -- banco do brasil
      -- Incluir nome do módulo logado
      gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249_3', pr_action => vr_cdprogra);
      pc_crps249_3(pr_cdcooper,
                   vr_dtmvtolt,
                   rw_craphis.nmestrut,
                   rw_craphis.cdhistor,
                   vr_cdcritic,
                   vr_dscritic);
      -- Incluir nome do módulo logado
      gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    elsif rw_craphis.nmestrut = 'CRAPLFT' then
      -- Incluir nome do módulo logado
      gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249_2', pr_action => vr_cdprogra);
      pc_crps249_2(pr_cdcooper,
                   vr_dtmvtolt,
                   rw_craphis.nmestrut,
                   rw_craphis.cdhistor,
                   rw_craphis.tpctbcxa,
                   vr_cdcritic,
                   vr_dscritic);
      -- Incluir nome do módulo logado
      gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    elsif rw_craphis.nmestrut = 'CRAPTVL' then
      -- Incluir nome do módulo logado
      gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249_4', pr_action => vr_cdprogra);
      pc_crps249_4(pr_cdcooper,
                   vr_dtmvtolt,
                   rw_craphis.nmestrut,
                   rw_craphis.cdhistor,
                   rw_craphis.tpctbcxa,
                   vr_cdcritic,
                   vr_dscritic);
      -- Incluir nome do módulo logado
      gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    else
      -- Incluir nome do módulo logado
      gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249_1', pr_action => vr_cdprogra);
      pc_crps249_1(pr_cdcooper,
                   vr_dtmvtolt,
                   rw_craphis.nmestrut,
                   rw_craphis.cdhistor,
                   rw_craphis.tpctbcxa,
                   rw_craphis.tpctbccu,
                   rw_crapthi.vltarifa,
                   vr_cdcritic,
                   vr_dscritic);
      -- Incluir nome do módulo logado
      gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    end if;

    --
    if vr_dscritic is not null then
      RAISE vr_exc_saida;
    end if;
  end loop; -- Fim da leitura da craphis

  -- Formata a data para criar o nome do arquivo
  vr_dtmvtolt_yymmdd := to_char(vr_dtmvtolt, 'yymmdd');

  -- Leitura das agências e criação da PL/Table
  pc_cria_agencia_pltable(999,NULL);
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
  for rw_crapage in cr_crapage loop
    pc_cria_agencia_pltable(rw_crapage.cdagenci,NULL);
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    vr_tab_agencia2(rw_crapage.cdagenci).vr_cdccuage := rw_crapage.cdccuage;
    vr_tab_agencia2(rw_crapage.cdagenci).vr_cdcxaage := rw_crapage.cdcxaage;
  end loop;

  -- Busca do diretório onde ficará o arquivo
  vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                            pr_cdcooper => pr_cdcooper,
                                            pr_nmsubdir => 'contab');
                                            
  -- Busca o diretório final para copiar arquivos
  vr_dsdircop := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                          ,pr_cdcooper => 0
                                          ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');                                              
  -- Nome do arquivo a ser gerado
  vr_nmarqdat := vr_dtmvtolt_yymmdd||'.txt';

  -- Abre o arquivo para escrita
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio,    --> Diretório do arquivo
                           pr_nmarquiv => vr_nmarqdat,         --> Nome do arquivo
                           pr_tipabert => 'W',                 --> Modo de abertura (R,W,A)
                           pr_utlfileh => vr_arquivo_txt,      --> Handle do arquivo aberto
                           pr_des_erro => vr_dscritic);
  if vr_dscritic is not null then
    vr_cdcritic := 0;
    RAISE vr_exc_saida;
  end if;
  -- Inicialização das variáveis que controlam as quebras do arquivo
  vr_cdhistor := 0;
  vr_dtrefere := 'x';
  vr_vldtotal := 0;

  -- Leitura dos rejeitados na integração
  for rw_craprej in cr_craprej (pr_cdcooper,vr_cdprogra,vr_dtmvtolt,0) loop

    IF (vr_cdhistor <> rw_craprej.cdhistor AND
        vr_vldtotal > 0)                   OR
			 (vr_cdhistor = rw_craprej.cdhistor  AND
        vr_vldtotal > 0                    AND
				rw_craprej.cdagenci = 0)           THEN
      -- Incluir o total da quebra
      vr_linhadet := '999,'||trim(to_char(vr_vldtotal, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

      vr_vldtotal := 0;
    end if;
    -- Controle de quebra
    vr_cdhistor := rw_craprej.cdhistor;
    vr_dtrefere := rw_craprej.dtrefere;
    -- Inicialização de variáveis
    vr_linhadet := null;
    vr_cdestrut := null;
    vr_nrctacrd := rw_craprej.nrctacrd;
    vr_nrctadeb := rw_craprej.nrctadeb;
    --
    if UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'TARIFA' then
      continue; -- lancamentos tratados abaixo, no outro loop
    end if;
    -- De acordo com a tabela de origem, define parâmetros a serem utilizados
    if UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'CRAPLCT' then
      vr_cdestrut := '50';
    elsif UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'CRAPLEM' then
      vr_cdestrut := '50';
    elsif UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'CRAPLEM_499' then
      vr_cdestrut := '50';
      vr_nrctacrd := 7141;
    elsif UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'CRAPLEM_ESTFIN' then
      vr_cdestrut := '50';
      vr_nrctadeb := 7141;
    elsif UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'CRAPLPP' then
      vr_cdestrut := '50';
    elsif UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'CRAPLAP' then
      vr_cdestrut := '50';
    elsif UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'CRAPLCM' then
      vr_cdestrut := '50';
    elsif UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'CRAPLFT' then
      vr_cdestrut := '50';
    elsif UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'CRAPTVL' then
      vr_cdestrut := '50';
    elsif UPPER(NVL(rw_craprej.dtrefere, ' ')) = 'COMPBB' then
      vr_cdestrut := '51';
    end if;
    -- Salva informações no arquivo
    if rw_craprej.cdagenci = 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(vr_nrctadeb))||','||
                     trim(to_char(vr_nrctacrd))||','||
                     trim(to_char(rw_craprej.vllanmto, '99999999999990.00'))||','||
                     trim(to_char(rw_craprej.cdhstctb))||','||
                     '"('||trim(to_char(rw_craprej.cdhistor,'0000'))||
                     ') '||trim(rw_craprej.dsexthst)||'"';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

      --
      if rw_craprej.nrctadeb = 1101 then  -- Custodia
        vr_linhadet := '001,'||trim(to_char(rw_craprej.vllanmto, '999999990.00'));
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

      end if;
      --
      if rw_craprej.ingerdeb = 2 then
        vr_linhadet := '999,'||trim(to_char(rw_craprej.vllanmto, '999999990.00'));
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

      end if;
      --
      if rw_craprej.ingercre = 2 then
        vr_vldtotal := rw_craprej.vllanmto;
      end if;
    else
      if rw_craprej.ingercre = 3 or
         rw_craprej.ingerdeb = 3 then
        vr_linhadet := to_char(vr_tab_agencia2(rw_craprej.cdagenci).vr_cdccuage,'fm000')||','||
                        trim(to_char(rw_craprej.vllanmto, '999999990.00'));
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

      elsif rw_craprej.tpctbcxa > 0 then
        if rw_craprej.tpctbcxa = 2 then -- POR CAIXA DEBITO
          vr_linhadet := trim(vr_cdestrut)||
                         trim(vr_dtmvtolt_yymmdd)||','||
                         trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                         trim(to_char(vr_tab_agencia2(rw_craprej.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                         trim(to_char(vr_nrctacrd))||','||
                         trim(to_char(rw_craprej.vllanmto, '99999999999990.00'))||','||
                         trim(to_char(rw_craprej.cdhstctb))||','||
                         '"('||trim(to_char(rw_craprej.cdhistor,'0000'))||
                         ') '||trim(rw_craprej.dsexthst)||'"';
          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

          --
          vr_linhadet := to_char(rw_craprej.cdagenci,'fm000')||','||trim(to_char(rw_craprej.vllanmto, '999999990.00'));
          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

          --
          if rw_craprej.ingercre = 2 then
            vr_linhadet := '999,'||trim(to_char(rw_craprej.vllanmto, '999999990.00'));
            gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

          end if;
        end if;

        if rw_craprej.tpctbcxa = 3 then -- POR CAIXA CREDITO
          vr_linhadet := trim(vr_cdestrut)||
                         trim(vr_dtmvtolt_yymmdd)||','||
                         trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                         trim(to_char(vr_nrctadeb))||','||
                         trim(to_char(vr_tab_agencia2(rw_craprej.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                         trim(to_char(rw_craprej.vllanmto, '99999999999990.00'))||','||
                         trim(to_char(rw_craprej.cdhstctb))||','||
                         '"('||trim(to_char(rw_craprej.cdhistor,'0000'))||
                         ') '||trim(rw_craprej.dsexthst)||'"';
          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

          --
          if rw_craprej.ingerdeb = 2    then
            vr_linhadet := '999,'||trim(to_char(rw_craprej.vllanmto, '999999990.00'));
            gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

          end if;
          --
          vr_linhadet := to_char(rw_craprej.cdagenci,'fm000')||','||trim(to_char(rw_craprej.vllanmto, '999999990.00'));
          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

        end if;
        --
        if rw_craprej.tpctbcxa in (4, 6) then  -- POR BB A DEBITO
          vr_nrdctabb := null;
          --
          IF rw_craprej.cdhistor in (266, 971, 977, 1088, 1089, 1998, 1999, 2000, 2001, 2002, 2012, 2180
                                    ,2277 ,2278 -- Marcelo Telles Coelho - Mouts - 15/01/2018 - SD 818020
                                    ) then
             --  266 - cred. cobranca
             --  971 - cred cobr - BB
             --  977 - cred cobr - CECRED
             -- 1088 - liq apos baixa - BB
             -- 1089 - liq apos baixa - CECRED
             -- 1998 - CREDITO PAGAMENTO CONTRATO INTEGRAL
             -- 1999 - CREDITO PAGAMENTO CONTRATO ATRASO
             -- 2000 - CREDITO QUITACAO DE EMPRESTIMO
             -- 2001 - DEVOLUCAO BOLETO VENCIDO
             -- 2002 - AJUSTE CONTRATO PROCESSO EM ATRASO
             -- 2012 - AJUSTE BOLETO (EMPRESTIMO) 
			 -- 2180 - CRED.COB. ACORDO
             -- 2277 - CREDITO PARCIAL PREJUIZO
             -- 2278 - CREDITO LIQUIDAÇÃO PREJUIZO
            vr_nrdctabb := to_char(rw_craprej.nrctadeb);
          else
            open cr_craptab (pr_cdcooper,
                             11, --cdempres
                             'CONTAB', --tptabela
                             to_char(rw_craprej.nrdctabb),
                             rw_craprej.cdbccxlt);
              fetch cr_craptab into vr_nrdctabb;
            close cr_craptab;
          end if;
          --
          vr_linhadet := trim(vr_cdestrut)||
                         trim(vr_dtmvtolt_yymmdd)||','||
                         trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                         trim(vr_nrdctabb)||','||
                         trim(to_char(vr_nrctacrd))||','||
                         trim(to_char(rw_craprej.vllanmto, '99999999999990.00'))||','||
                         trim(to_char(rw_craprej.cdhstctb))||','||
                         '"('||trim(to_char(rw_craprej.cdhistor,'0000'))||
                         ') '||trim(rw_craprej.dsexthst)||'"';
          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

          --
          if rw_craprej.ingercre = 2 then
            vr_linhadet := '999,'||trim(to_char(rw_craprej.vllanmto, '999999990.00'));
            gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

          end if;
        end if;
        --
        if rw_craprej.tpctbcxa = 5 then  -- POR BB A CREDITO
          vr_nrdctabb := null;
          open cr_craptab (pr_cdcooper,
                           11, --cdempres
                           'CONTAB', --tptabela
                           to_char(rw_craprej.nrdctabb),
                           rw_craprej.cdbccxlt);
            fetch cr_craptab into vr_nrdctabb;
          close cr_craptab;
          --
          vr_linhadet := trim(vr_cdestrut)||
                         trim(vr_dtmvtolt_yymmdd)||','||
                         trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                         trim(to_char(vr_nrctadeb))||','||
                         trim(vr_nrdctabb)||','||
                         trim(to_char(rw_craprej.vllanmto, '99999999999990.00'))||','||
                         trim(to_char(rw_craprej.cdhstctb))||','||
                         '"('||trim(to_char(rw_craprej.cdhistor,'0000'))||
                         ') '||trim(rw_craprej.dsexthst)||'"';
          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

          --
          if rw_craprej.ingerdeb = 2 then
            vr_linhadet := '999,'||trim(to_char(rw_craprej.vllanmto, '999999990.00'));
            gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

          end if;
        end if;
      end if;
    end if;
  end loop;
  -- Incluir o total da última quebra
  if vr_vldtotal > 0 then
    vr_linhadet := '999,'||trim(to_char(vr_vldtotal, '999999990.00'));
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  end if;
  --
  vr_cdestrut := '55';
  -- Tratar quantidade de lancamentos para tarifa
  for rw_craprej2 in cr_craprej2 (pr_cdcooper,
                                  vr_cdprogra,
                                  vr_dtmvtolt
                                  ,0) loop
    --
    OPEN  cr_craphis2(rw_craprej2.cdcooper
                     ,rw_craprej2.cdhistor);
    FETCH cr_craphis2 INTO rw_craphis2;
    IF cr_craphis2%NOTFOUND THEN
      CLOSE cr_craphis2;
      vr_cdcritic := 526;
      vr_dscritic := rw_craprej2.cdhistor||' - '||gene0001.fn_busca_critica(vr_cdcritic);
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_craphis2;

    --
    IF rw_craphis2.tpctbcxa > 3 AND
       rw_craprej2.dtrefere <> 'TARIFA' THEN
      continue; -- lancamentos por conta banco do brasil
    END IF;
    -- Desconsiderar lancamentos de tarifa de cheques cta integracao
    if pr_cdcooper <> 3 then
      if rw_craphis2.cdhistor = 50 then
        if pr_cdcooper = 2 then
          -- Identifica se conta eh Integracao
          if vr_rel_nrdctabb = rw_craprej2.nrdctabb then
            continue;
          end if;
        else
          continue;  -- BB nao cobra mais a tarifa ref. cta base
        end if;
      end if;
    end if;
    --
    vr_linhadet := null;
    vr_nrctatrd := to_char(rw_craphis2.nrctatrd);
    vr_nrctatrc := to_char(rw_craphis2.nrctatrc);
    vr_vltarifa := 0;
    --
    if rw_craprej2.cdagenci = 0 then
      if rw_craprej2.dtrefere = 'TARIFA' then -- por conta BB
        vr_nrdctabb := null;
        --
        open cr_craptab2 (pr_cdcooper,
                          'CONTAB',
                          to_char(rw_craprej2.nrdctabb));
          fetch cr_craptab2 into vr_nrdctabb;
        close cr_craptab2;
        --
        if nvl(vr_nrdctabb, ' ') = ' ' then
          open cr_craptab2 (pr_cdcooper,
                            'CONTAB',
                            to_char(vr_rel_nrdctabb));
            fetch cr_craptab2 into vr_nrdctabb;
          close cr_craptab2;
        end if;
        --
        if rw_craphis2.cdhistor not in (266, 971, 977, 1088, 1089) then
          --  266 - cred. cobranca
          --  971 - cred cobr - BB
          --  977 - cred cobr - CECRED
          -- 1088 - liq apos baixa - BB
          -- 1089 - liq apos baixa - CECRED
          if rw_craphis2.tpctbcxa = 4 then
            vr_nrctatrd := vr_nrdctabb;
          elsif rw_craphis2.tpctbcxa = 5 then
            vr_nrctatrc := vr_nrdctabb;
          elsif rw_craphis2.tpctbcxa = 6 then
            vr_nrctatrc := vr_nrdctabb;
          end if;
        end if;
      end if;
      -- xpto
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(vr_nrctatrd))||','||
                     trim(to_char(vr_nrctatrc))||','||
                     trim(to_char(rw_craprej2.nrseqdig * rw_craprej2.vltarifa, '99999999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '"('||trim(to_char(rw_craprej2.cdhistor,'0000'))||
                     ') '||trim(rw_craphis2.dsexthst)||' (tarifa)"';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    else
      vr_vltarifa := rw_craprej2.vltarifa;
      --
      if rw_craprej2.cdagenci = 90 then -- Internet
        open cr_crabthi (pr_cdcooper,
                         rw_craprej2.cdhistor,
                         'INTERNET');
          fetch cr_crabthi into rw_crabthi;
          if cr_crabthi%found then
            vr_vltarifa := rw_crabthi.vltarifa;
          end if;
        close cr_crabthi;
      elsif rw_craprej2.cdagenci = 91 then -- TAA
        open cr_crabthi (pr_cdcooper,
                         rw_craprej2.cdhistor,
                         'CASH');
          fetch cr_crabthi into rw_crabthi;
          if cr_crabthi%found then
            vr_vltarifa := rw_crabthi.vltarifa;
          end if;
        close cr_crabthi;
      end if;
      --
      if rw_craphis2.tpctbcxa in (2,3) then
        vr_linhadet := trim(vr_cdestrut)||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       trim(to_char(vr_nrctatrd))||','||
                       trim(to_char(vr_nrctatrc))||','||
                       trim(to_char(rw_craprej2.nrseqdig * vr_vltarifa, '99999999999990.00'))||','||
                       trim(to_char(rw_craphis2.cdhstctb))||','||
                       '"('||trim(to_char(rw_craprej2.cdhistor,'0000'))||
                       ') '||trim(rw_craphis2.dsexthst)||' (tarifa)"';
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
      --
      vr_linhadet := to_char(vr_tab_agencia2(rw_craprej2.cdagenci).vr_cdccuage,'fm000')||','||trim(to_char(rw_craprej2.nrseqdig * vr_vltarifa, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      
      --Acumular valores de despesas de cobranca para geração de arquivo contábil
      if rw_craphis2.cdhistor = 266 and vr_contador = 0 then
        vr_contador := 1;
        for rw_craplcm9 in cr_craplcm9(pr_cdcooper,vr_dtmvtolt,rw_craphis2.cdhistor) loop
          if rw_craplcm9.inpessoa = 1 then
            
             if vr_tab_vlr_age_fis.EXISTS(rw_craplcm9.cdagenci) then
               -- Soma os valores por agencia de pessoa fisica
               vr_tab_vlr_age_fis(rw_craplcm9.cdagenci) := vr_tab_vlr_age_fis(rw_craplcm9.cdagenci) + (rw_craplcm9.nrseqdig * vr_vltarifa);
             else
             -- Inicializa o array com o valor inicial de pessoa fisica
               vr_tab_vlr_age_fis(rw_craplcm9.cdagenci) := rw_craplcm9.nrseqdig * vr_vltarifa;
    end if;
          else
            if vr_tab_vlr_age_jur.EXISTS(rw_craplcm9.cdagenci) then
               -- Soma os valores por agencia de pessoa jurídica
               vr_tab_vlr_age_jur(rw_craplcm9.cdagenci) := vr_tab_vlr_age_jur(rw_craplcm9.cdagenci) + (rw_craplcm9.nrseqdig * vr_vltarifa);
             else
             -- Inicializa o array com o valor inicial de pessoa fisica
               vr_tab_vlr_age_jur(rw_craplcm9.cdagenci) := rw_craplcm9.nrseqdig * vr_vltarifa;
             end if;
    end if;
          
          --Totalizar valores por tipo de pessoa
          if vr_tab_vlr_descbr_pes.EXISTS(rw_craplcm9.inpessoa) then
            -- Soma os valores por tipo de pessoa
            vr_tab_vlr_descbr_pes(rw_craplcm9.inpessoa) := vr_tab_vlr_descbr_pes(rw_craplcm9.inpessoa) +  (rw_craplcm9.nrseqdig * vr_vltarifa);
          else
            -- Inicializa o array com o valor inicial de cada tipo de pessoa
            vr_tab_vlr_descbr_pes(rw_craplcm9.inpessoa) := rw_craplcm9.nrseqdig * vr_vltarifa;
          end if;
  end loop;
      end if;
    end if;
  end loop;
  
  -- Convênio Sicredi
  OPEN cr_craphis2 (pr_cdcooper, 1154);
  FETCH cr_craphis2 INTO rw_craphis2;
  IF cr_craphis2%NOTFOUND THEN
    CLOSE cr_craphis2;
    vr_cdcritic := 526;
    vr_dscritic := '1154 - '||gene0001.fn_busca_critica(vr_cdcritic);
    RAISE vr_exc_saida;
  END IF;
  CLOSE cr_craphis2;
  --
  vr_nrctacrd := rw_craphis2.nrctacrd;
  vr_cdestrut := '50';

  -- Convênio Sicredi
  for rw_crapcon in cr_crapcon (pr_cdcooper) LOOP
    OPEN cr_crapscn(rw_crapcon.cdempcon, rw_crapcon.cdsegmto);
    FETCH cr_crapscn INTO rw_crapscn;
    IF cr_crapscn%NOTFOUND THEN
      CLOSE cr_crapscn;
      OPEN cr_crapscn3(rw_crapcon.cdempcon, rw_crapcon.cdsegmto);
      FETCH cr_crapscn3 INTO rw_crapscn;
      IF cr_crapscn3%NOTFOUND THEN
        CLOSE cr_crapscn3;
        continue;
      END IF;
      CLOSE cr_crapscn3;
    ELSE
      CLOSE cr_crapscn;
    END IF;
    
    -- Para DPVAT usar conta 4336
    IF rw_crapscn.cdempres = '85' THEN
      vr_nrctasic := 4336;
    ELSE
      vr_nrctasic := vr_nrctacrd;
    END IF;

    vr_vllanmto_fat := 0;
    vr_qtlanmto_fat := 0;
    open cr_craplft(pr_cdcooper,
                                  vr_dtmvtolt,
                                  rw_crapcon.cdempcon,
                                  rw_crapcon.cdsegmto,
                    rw_crapcon.cdhistor);
    loop
      --joga dados do cursor na variável de 5000 em 5000
      fetch cr_craplft bulk collect into rw_craplft limit 5000;

      --para cada linha de retorno na variável indexada de 5000 em 5000, faz os cálculos
      for i in 1..rw_craplft.count loop

      -- Incrementa o contador na pl/table de faturas
        vr_indice_faturas := to_char(rw_craplft(i).tpfatura, 'fm0')||to_char(rw_craplft(i).cdagenci_fatura, 'fm000');
        vr_tab_faturas(vr_indice_faturas).vr_tpfatura := rw_craplft(i).tpfatura;
        vr_tab_faturas(vr_indice_faturas).vr_cdagenci := rw_craplft(i).cdagenci_fatura;
        vr_tab_faturas(vr_indice_faturas).vr_qtlanmto := nvl(vr_tab_faturas(vr_indice_faturas).vr_qtlanmto, 0) + rw_craplft(i).qtlanmto;

      -- Faz a soma dos valores, pois é possível existir mais de uma fatura com agencia 90 ou 91
        vr_vllanmto_fat := vr_vllanmto_fat + rw_craplft(i).vllanmto;
        vr_qtlanmto_fat := vr_qtlanmto_fat + rw_craplft(i).qtlanmto;

      -- Tratamento para Tarifa
        if rw_craplft(i).cdagenci = 90 then
        vr_tpdarrec := 'D';
        elsif rw_craplft(i).cdagenci = 91 then
        vr_tpdarrec := 'A';
      else
        vr_tpdarrec := 'C';
      end if;
      -- Convênio Sicredi
      open cr_crapstn (rw_crapscn.cdempres,
                       vr_tpdarrec);
        fetch cr_crapstn into rw_crapstn;
      close cr_crapstn;
      --
      IF rw_crapstn.vltrfuni > 0 THEN

        BEGIN
          -- Inserir registro de rejeitados na integracao - D23
          INSERT INTO craprej (cdcooper,
                               cdagenci,
                               cdhistor,
                               dtmvtolt,
                               cdpesqbb,
                               nrseqdig,
                               vllanmto,
                               dtrefere,
                               nrdocmto)
          VALUES (pr_cdcooper,
                    rw_craplft(i).cdagenci,
                    rw_craplft(i).cdhistor,
                  vr_dtmvtolt,
                  vr_cdprogra,
                    rw_craplft(i).qtlanmto,
                    rw_craplft(i).qtlanmto * rw_crapstn.vltrfuni,
                  rw_crapscn.cdempres,
                    rw_craplft(i).cdagenci_fatura);
        EXCEPTION
          WHEN OTHERS THEN
              --Inclusão na tabela de erros Oracle - Chamado 734422
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);                                                             
              vr_cdcritic := 1034;
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' registros já processados na craprej. '||
                             ' cdcooper:'||pr_cdcooper||', cdagenci:'||rw_craplft(i).cdagenci||
                             ', cdhistor:'||rw_craplft(i).cdhistor||', dtmvtolt:'||vr_dtmvtolt||
                             ', cdpesqbb:'||vr_cdprogra||', nrseqdig:'||rw_craplft(i).qtlanmto||
                             ', vllanmto:'||rw_craplft(i).qtlanmto * rw_crapstn.vltrfuni||
                             ', dtrefere:'||rw_crapscn.cdempres||
                             ', nrdocmto:'||rw_craplft(i).cdagenci_fatura||'. '||sqlerrm;
            RAISE vr_exc_saida;
        END;
      END IF;
      -- Verifica se é a mesma agência e, se for, busca o próximo registro
        if rw_craplft(i).cdagenci = rw_craplft(i).proxima_agencia then
        continue;
      end if;
      --
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       trim(to_char(vr_tab_agencia2(rw_craplft(i).cdagenci).vr_cdcxaage, 'fm0000'))||','||
                     trim(to_char(vr_nrctasic))||','||
                     trim(to_char(vr_vllanmto_fat, '99999999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                     ') '||trim(rw_crapscn.cdempres)||' - '||
                     trim(rw_crapcon.nmextcon)||'"';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
        vr_linhadet := to_char(rw_craplft(i).cdagenci,'fm000')||','||trim(to_char(vr_vllanmto_fat, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_vllanmto_fat := 0;
      vr_qtlanmto_fat := 0;

      end loop;

      exit when cr_craplft%rowcount <= 5000;
    end loop;
    close cr_craplft;
    --
  END LOOP; --cr_crapcon

  -- DARF's sem código de barras - Sicredi
  -- Primeiro serão lidas as DARF's com código de tributo 6106
  vr_idtributo_6106 := 1;
  loop
    vr_vllanmto_fat := 0;
    vr_qtlanmto_fat := 0;
  for rw_craplft2 in cr_craplft2 (pr_cdcooper,
                                  vr_dtmvtolt,
                                  0,
                                  6,
                                  rw_craphis2.cdhistor,
                                    2,
                                    vr_idtributo_6106 -- DARF'S - .ARF
                                   ) loop
    -- Incrementa o contador na pl/table de faturas
    vr_indice_faturas := to_char(rw_craplft2.tpfatura, 'fm0')||to_char(rw_craplft2.cdagenci_fatura, 'fm000');
    vr_tab_faturas(vr_indice_faturas).vr_tpfatura := rw_craplft2.tpfatura;
    vr_tab_faturas(vr_indice_faturas).vr_cdagenci := rw_craplft2.cdagenci_fatura;
    vr_tab_faturas(vr_indice_faturas).vr_qtlanmto := nvl(vr_tab_faturas(vr_indice_faturas).vr_qtlanmto, 0) + rw_craplft2.qtlanmto;
      -- Faz a soma dos valores, pois é possível existir mais de uma fatura com agencia 90 ou 91
      vr_vllanmto_fat := vr_vllanmto_fat + rw_craplft2.vllanmto;
      vr_qtlanmto_fat := vr_qtlanmto_fat + rw_craplft2.qtlanmto;
    --
    open cr_crapscn2 (rw_craplft2.cdempres);
      fetch cr_crapscn2 into rw_crapscn2;
    close cr_crapscn2;
    -- Para DPVAT usar conta 4336
    IF rw_crapscn2.cdempres = '85' THEN
      vr_nrctasic := 4336;
    ELSE
      vr_nrctasic := vr_nrctacrd;
    END IF;
    -- Tratamento para Tarifa
    if rw_craplft2.cdagenci = 90 then
      vr_tpdarrec := 'D';
    elsif rw_craplft2.cdagenci = 91 then
      vr_tpdarrec := 'A';
    else
      vr_tpdarrec := 'C';
    end if;
    -- Convênio Sicredi
    open cr_crapstn (rw_crapscn2.cdempres,
                     vr_tpdarrec);
      fetch cr_crapstn into rw_crapstn;
    close cr_crapstn;
    --
    if rw_crapstn.vltrfuni > 0 then
      BEGIN
        -- Inserir registro de rejeitados na integracao - D23
        insert into craprej (cdcooper,
                             cdagenci,
                             cdhistor,
                             dtmvtolt,
                             cdpesqbb,
                             nrseqdig,
                             vllanmto,
                               dtrefere,
                               nrdocmto)
        values (pr_cdcooper,
                rw_craplft2.cdagenci,
                rw_craphis2.cdhistor,
                vr_dtmvtolt,
                vr_cdprogra,
                rw_craplft2.qtlanmto,
                rw_craplft2.qtlanmto * rw_crapstn.vltrfuni,
                  rw_crapscn2.cdempres,
                  rw_craplft2.cdagenci_fatura);
      exception
        when others then
          --Inclusão na tabela de erros Oracle - Chamado 734422
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);                                                             
          vr_cdcritic := 1034;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' registros já processados na craprej. '||
                         ' cdcooper:'||pr_cdcooper||', cdagenci:'||rw_craplft2.cdagenci||
                         ', cdhistor:'||rw_craphis2.cdhistor||', dtmvtolt:'||vr_dtmvtolt||
                         ', cdpesqbb:'||vr_cdprogra||', nrseqdig:'||rw_craplft2.qtlanmto||
                         ', vllanmto:'||rw_craplft2.qtlanmto * rw_crapstn.vltrfuni||
                         ', dtrefere:'||rw_crapscn2.cdempres||
                         ', nrdocmto:'||rw_craplft2.cdagenci_fatura||'. '||sqlerrm;
          raise vr_exc_saida;
      end;
    end if;
      -- Verifica se é a mesma agência e, se for, busca o próximo registro
      if rw_craplft2.cdagenci = rw_craplft2.proxima_agencia then
        continue;
      end if;
      --
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(vr_tab_agencia2(rw_craplft2.cdagenci).vr_cdcxaage,'fm0000'))||','||
                     trim(to_char(vr_nrctasic))||','||
                     trim(to_char(vr_vllanmto_fat, '99999999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                     ') '||trim(rw_crapscn2.cdempres)||' - '||
                     trim(rw_crapscn2.dsnomcnv)||'"';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := to_char(rw_craplft2.cdagenci,'fm000')||','||trim(to_char(vr_vllanmto_fat, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_vllanmto_fat := 0;
      vr_qtlanmto_fat := 0;
    end loop;
    
    -- Se já obteve DARF's com código de tributo 6106 e também demais códigos sai do loop
    if vr_idtributo_6106 = 0 then
       exit;
    end if;
    
    -- Ja leu DARF's com tributo 6106 e altera para ler DARF's dos demais tributos
    vr_idtributo_6106 := 0;
  end loop;

  -- Tarifa Sicredi
  vr_cdestrut := '55';
  for rw_craprej3 in cr_craprej3 (pr_cdcooper,
                                  vr_cdprogra,
                                  vr_dtmvtolt,
                                  0) loop
    -- Tabela crapsnc nao utiliza cdcooper
    open cr_crapscn2 (rw_craprej3.dtrefere);
      fetch cr_crapscn2 into rw_crapscn2;
    close cr_crapscn2;
    -- Para DPVAT usar conta 4336
    IF rw_crapscn2.cdempres = '85' THEN
      vr_nrctasic := 4336;
    ELSE
      vr_nrctasic := 4332;
    END IF;
    --
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   vr_nrctasic||','||
                   '7268,'||
                   trim(to_char(rw_craprej3.vllanmto, '99999999999990.00'))||','||
                   trim(to_char(rw_craphis2.cdhstctb))||','||
                   '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                   ') '||trim(rw_crapscn2.cdempres)||' - '||
                   trim(rw_crapscn2.dsnomcnv)||' (tarifa)"';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_linhadet := to_char(rw_craprej3.nrdocmto,'fm000')||','||trim(to_char(rw_craprej3.vllanmto, '999999990.00'));
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  end loop;


  -- Despesa Sicredi
  vr_indice_faturas := vr_tab_faturas.first;
  while vr_indice_faturas is not null loop
    if vr_tab_faturas(vr_indice_faturas).vr_tpfatura = 0 then
      -- Faturas
      open cr_crapthi2 (pr_cdcooper,
                        rw_craphis2.cdhistor);
        fetch cr_crapthi2 into rw_crapthi2;
        if cr_crapthi2%found then
          vr_linhadet := trim(vr_cdestrut)||
                         trim(vr_dtmvtolt_yymmdd)||','||
                         trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                         trim(to_char(rw_craphis2.nrctatrd))||','||
                         trim(to_char(rw_craphis2.nrctatrc))||','||
                         trim(to_char(vr_tab_faturas(vr_indice_faturas).vr_qtlanmto * rw_crapthi2.vltarifa, '99999999999990.00'))||','||
                         trim(to_char(rw_craphis2.cdhstctb))||','||
                         '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                         ') CONTABILIZACAO DESPESA SICREDI"';
          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
          --
          vr_linhadet := to_char(vr_tab_faturas(vr_indice_faturas).vr_cdagenci, 'fm000')||','||trim(to_char(vr_tab_faturas(vr_indice_faturas).vr_qtlanmto * rw_crapthi2.vltarifa, '999999990.00'));
          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
      close cr_crapthi2;
    else
      -- Tributos federais
      vr_vltarifa := rw_crapcop.vltardrf;
      --
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctatrd))||','||
                     trim(to_char(rw_craphis2.nrctatrc))||','||
                     trim(to_char(vr_tab_faturas(vr_indice_faturas).vr_qtlanmto * vr_vltarifa, '99999999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                     ') CONTABILIZACAO DESPESA SICREDI - DARF"';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := to_char(vr_tab_faturas(vr_indice_faturas).vr_cdagenci, 'fm000')||','||trim(to_char(vr_tab_faturas(vr_indice_faturas).vr_qtlanmto * vr_vltarifa, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
    vr_indice_faturas := vr_tab_faturas.next(vr_indice_faturas);
  end loop;
  --

  --*************************--
  -- Convênio Sicredi (debito automatico)
  OPEN cr_craphis2 (pr_cdcooper, 1019);
  FETCH cr_craphis2 INTO rw_craphis2;
  IF cr_craphis2%NOTFOUND THEN
    CLOSE cr_craphis2;
    vr_cdcritic := 526;
    vr_dscritic := '1019 - '||gene0001.fn_busca_critica(vr_cdcritic);
    RAISE vr_exc_saida;
  END IF;
  CLOSE cr_craphis2;
  --
  vr_nrctacrd := rw_craphis2.nrctacrd;
  vr_cdestrut := '50';
  
  -- Debito Automatico Sicredi
  FOR rw_craplcm4 IN cr_craplcm4 (pr_cdcooper,
                                  vr_dtmvtolt,
                                  rw_craphis2.cdhistor) LOOP

    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   trim(to_char(rw_craphis2.nrctadeb))||','||
                   trim(to_char(vr_nrctacrd))||','||
                   trim(to_char(rw_craplcm4.vllanmto, '99999999999990.00'))||','||
                   trim(to_char(rw_craphis2.cdhstctb))||','||
                   '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                   ') '||trim(rw_craplcm4.cdempres)|| ' - ' ||
                   TRIM(rw_craplcm4.dsnomcnv) || '"';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

    vr_linhadet := '999,' || TRIM(to_char(rw_craplcm4.vllanmto, '999999990.00'));
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

  END LOOP;
  
  -- Tarifa convênio Sicredi Debito Automatico
  FOR rw_craplcm5 IN cr_craplcm5 (pr_cdcooper,
                                  vr_dtmvtolt,
                                  rw_craphis2.cdhistor) LOOP
    OPEN cr_crapstn (rw_craplcm5.cdempres,
                     'E');
      fetch cr_crapstn into rw_crapstn;
    close cr_crapstn;

    -- Para DPVAT usar conta 4336
    IF rw_craplcm5.cdempres = '85' THEN
      vr_nrctasic := 4336;
    ELSE
      vr_nrctasic := 4332;
    END IF;
    --
    IF rw_crapstn.vltrfuni > 0 THEN
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     vr_nrctasic||','||
                     '7268,'||
                     trim(to_char(rw_craplcm5.qtlanmto * rw_crapstn.vltrfuni, '99999999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                   '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                   ') '||trim(rw_craplcm5.cdempres)|| ' - ' ||
                     TRIM(rw_craplcm5.dsnomcnv) ||
                     ' (tarifa)"';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;

    vr_linhadet := to_char(rw_craplcm5.cdagenci,'fm000')||','||trim(to_char(rw_craplcm5.qtlanmto * rw_crapstn.vltrfuni, '999999990.00'));
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

  END LOOP;

  -- Despesa Sicredi (Debito Automatico)
  FOR rw_craplcm6 IN cr_craplcm6 (pr_cdcooper,
                                  vr_dtmvtolt,
                                  rw_craphis2.cdhistor) LOOP

    open cr_crapthi2 (pr_cdcooper,
                      rw_craphis2.cdhistor);
        fetch cr_crapthi2 into rw_crapthi2;

    if cr_crapthi2%found then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctatrd))||','||
                     trim(to_char(rw_craphis2.nrctatrc))||','||
                     trim(to_char(rw_craplcm6.qtlanmto * rw_crapthi2.vltarifa, '99999999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                     ') CONTABILIZACAO DESPESA SICREDI"';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

      vr_linhadet := to_char(rw_craplcm6.cdagenci, 'fm000')||','||trim(to_char(rw_craplcm6.qtlanmto * rw_crapthi2.vltarifa, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;

    close cr_crapthi2;

  END LOOP;

  --*************************--
  vr_cdestrut := '51';
  -- Subscricao de capital para novos socios .................................
  vr_vlcapsub := 0;
  for rw_crapsdc in cr_crapsdc_LT (pr_cdcooper,
                                vr_dtmvtolt) loop
    vr_vlcapsub := vr_vlcapsub + rw_crapsdc.vllanmto;
  end loop;
  --
  if vr_vlcapsub > 0 then
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   '6122,'||
                   '6112,'||
                   trim(to_char(vr_vlcapsub, '99999999999990.00'))||','||
                   '5210,'||
                   '"(crps249) SUBSCRICAO INICIAL."';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_linhadet := '999,'||trim(to_char(vr_vlcapsub, '99999999999990.00'));
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  end if;
  -- Reversao da subscricao de capital para socios demitidos/cancelamentos
  vr_vlcapsub := 0;
  for rw_crapsdc in cr_crapsdc (pr_cdcooper,
                                vr_dtmvtolt,
                                2) loop
    vr_vlcapsub := vr_vlcapsub + rw_crapsdc.vllanmto;
  end loop;
  --
  if vr_vlcapsub > 0 then
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   '6112,'||
                   '6122,'||
                   trim(to_char(vr_vlcapsub, '99999999999990.00'))||','||
                   '5210,'||
                   '"(crps249) REVERSAO DA SUBSCRICAO INICIAL - DEMITIDOS/CANCELAMENTO"';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_linhadet := '999,'||trim(to_char(vr_vlcapsub, '99999999999990.00'));
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  end if;
  -- Cheques em custodia .....................................................
  -- Entradas de cheques em custodia do dia
  vr_vlcstcop := 0;
  vr_vlcstout := 0;
  for rw_crapcst in cr_crapcst (pr_cdcooper,
                                vr_dtmvtolt) loop
    if rw_crapcst.nrdconta = 85448 then
      vr_vlcstcop := vr_vlcstcop + rw_crapcst.vlcheque;
    else
      vr_vlcstout := vr_vlcstout + rw_crapcst.vlcheque;
    end if;
  end loop;
  --
  if vr_vlcstout > 0 then
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   '3482,'||
                   '9143,'||
                   trim(to_char(vr_vlcstout, '99999999999990.00'))||','||
                   '5210,'||
                   '"(crps249) CUSTODIA OUTROS ASSOCIADOS."';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  end if;
  --
  if vr_vlcstcop > 0 then
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   '3481,'||
                   '9142,'||
                   trim(to_char(vr_vlcstcop, '99999999999990.00'))||','||
                   '5210,'||
                   '"(crps249) CUSTODIA COOPER."';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  end if;
  -- Liberacao de cheques em custodia do dia
  vr_vlcstcop := 0;
  vr_vlcstout := 0;
  for rw_crapcst in cr_crapcst2 (pr_cdcooper,
                                 vr_dtmvtoan,
                                 vr_dtmvtolt) loop
    if rw_crapcst.nrdconta = 85448 then
      vr_vlcstcop := vr_vlcstcop + rw_crapcst.vlcheque;
    else
      vr_vlcstout := vr_vlcstout + rw_crapcst.vlcheque;
    end if;
  end loop;
  --
  if vr_vlcstout > 0 then
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   '9143,'||
                   '3482,'||
                   trim(to_char(vr_vlcstout, '99999999999990.00'))||','||
                   '5210,'||
                   '"(crps249) LIBERACAO CUSTODIA OUTROS ASSOCIADOS."';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  end if;
  --
  if vr_vlcstcop > 0 then
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   '9142,'||
                   '3481,'||
                   trim(to_char(vr_vlcstcop, '99999999999990.00'))||','||
                   '5210,'||
                   '"(crps249) LIBERACAO CUSTODIA COOPER."';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  end if;
  -- Resgates de cheques em custodia do dia / transf. para desconto de cheques
  vr_vlcstcop := 0;
  vr_vlcstout := 0;
  vr_vlcdbban := 0;
  vr_vlcdbcop := 0;

  for rw_crapcst in cr_crapcst3 (pr_cdcooper,
                                 vr_dtmvtolt) loop
    if rw_crapcst.insitchq = 5 then  -- Cheque descontado
      if rw_crapcst.nrdconta = 85448 then
        vr_vlcdbcop := vr_vlcdbcop + rw_crapcst.vlcheque;
      else
        vr_vlcdbban := vr_vlcdbban + rw_crapcst.vlcheque;
      end if;
    else
      if rw_crapcst.nrdconta = 85448 then
        vr_vlcstcop := vr_vlcstcop + rw_crapcst.vlcheque;
      else
        vr_vlcstout := vr_vlcstout + rw_crapcst.vlcheque;
      end if;
    end if;
  end loop;
  --
  if vr_vlcstout > 0 then
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   '9143,'||
                   '3482,'||
                   trim(to_char(vr_vlcstout, '99999999999990.00'))||','||
                   '5210,'||
                   '"(crps249) RESGATE CUSTODIA OUTROS ASSOCIADOS."';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  end if;
  --
  if vr_vlcstcop > 0 then
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   '9142,'||
                   '3481,'||
                   trim(to_char(vr_vlcstcop, '99999999999990.00'))||','||
                   '5210,'||
                   '"(crps249) RESGATE CUSTODIA COOPER."';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  end if;
  --
  if vr_vlcdbban > 0 then
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   '9143,'||
                   '3482,'||
                   trim(to_char(vr_vlcdbban, '99999999999990.00'))||','||
                   '5210,'||
                   '"(crps249) CUSTODIA TRANSFERIDA PARA DESCONTO."';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  end if;
  --
  if vr_vlcdbcop > 0 then
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   '9142,'||
                   '3481,'||
                   trim(to_char(vr_vlcdbcop, '99999999999990.00'))||','||
                   '5210,'||
                   '"(crps249) CUSTODIA TRANSFERIDA PARA DESCONTO."';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  end if;
  -- Titulos compensaveis ....................................................
  open cr_craptab (pr_cdcooper,
                   0, --cdempres
                   'GENERI', --tptabela
                   'TITCTARIFA', --cdacesso
                   1); --tpregist
    fetch cr_craptab into rw_craptab.dstextab;
    if cr_craptab%notfound then
      vr_vltarifa := 0;
    else
      vr_vltarifa := to_number(rw_craptab.dstextab);
    end if;
  close cr_craptab;
  --
  vr_tab_agencia.delete;
  pc_cria_agencia_pltable(999,NULL);
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
  for rw_craptit in cr_craptit (pr_cdcooper,
                                vr_dtmvtolt,
                                0) loop
    pc_cria_agencia_pltable(rw_craptit.cdagenci,NULL);
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    vr_vltitulo := rw_craptit.vldpagto;
    vr_tab_agencia(rw_craptit.cdagenci).vr_qttottrf := rw_craptit.qttottrf;
    vr_tab_agencia(999).vr_qttottrf := vr_tab_agencia(999).vr_qttottrf + rw_craptit.qttottrf;
    --
    open cr_crapage2(pr_cdcooper,
                     rw_craptit.cdagenci);
      fetch cr_crapage2 into rw_crapage2;
      if cr_crapage2%notfound then
        close cr_crapage2;
        vr_cdcritic := 962;
        RAISE vr_exc_saida;
      else
        if rw_crapage2.cdbantit = 1 then  -- Banco do Brasil
          vr_cdhistor := 713;
        elsif rw_crapage2.cdbantit = 756 then -- Bancoob
          vr_cdhistor := 546;
        elsif rw_crapage2.cdbantit = rw_crapcop.cdbcoctl then
          vr_cdhistor := 824;
        end if;
        --
        open cr_craphis2 (pr_cdcooper,
                          vr_cdhistor);
          fetch cr_craphis2 into rw_craphis2;
          if cr_craphis2%notfound then
            close cr_craphis2;
            vr_cdcritic := 526;
            vr_dscritic := vr_cdhistor||' - '||gene0001.fn_busca_critica(vr_cdcritic);
            raise vr_exc_saida;
          end if;
        close cr_craphis2;
      end if;
      --
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(vr_tab_agencia2(rw_craptit.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                     trim(to_char(rw_craphis2.nrctacrd,'0000'))||','||
                     trim(to_char(vr_vltitulo, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) NOSSA REMESSA."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := to_char(rw_craptit.cdagenci, 'fm000')||','||trim(to_char(vr_vltitulo, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    close cr_crapage2;
  end loop;  -- Fim do loop craptit

  -- TITULOS 085 PAGOS PELOS CAIXAS, INTERNET E CAIXA ONLINE COM FLOAT
  -- MOVIMENTA CONTA 4972
  -- MOVIMENTA CONTA 4957 - Boleto de emprestimo (Projeto 210)
  vr_tab_agencia.delete;
  pc_cria_agencia_pltable(999,NULL);
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

  FOR rw_craptit4 in cr_craptit4 (pr_cdcooper,
                                  vr_dtmvtolt) LOOP

    pc_cria_agencia_pltable(rw_craptit4.cdagenci,NULL);
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

    vr_vltitulo := rw_craptit4.vldpagto;
    vr_tab_agencia(rw_craptit4.cdagenci).vr_qttottrf := rw_craptit4.qttottrf;
    vr_tab_agencia(999).vr_qttottrf := vr_tab_agencia(999).vr_qttottrf + rw_craptit4.qttottrf;
    --
    IF rw_craptit4.dsorgarq <> 'EMPRESTIMO' THEN
      vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     TRIM(to_char(vr_tab_agencia2(rw_craptit4.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                     '4972,'|| -- Conta pendência da singular
                     TRIM(to_char(vr_vltitulo, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) SUA REMESSA - CONVENIO ' || rw_craptit4.nrconven || '"';
    ELSE
      vr_linhadet := TRIM(vr_cdestrut)||
                     TRIM(vr_dtmvtolt_yymmdd)||','||
                     TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     TRIM(to_char(vr_tab_agencia2(rw_craptit4.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                     '4957,'|| -- Conta pendência da singular
                     TRIM(to_char(vr_vltitulo, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) SUA REMESSA - CONVENIO EMPRESTIMO ' || rw_craptit4.nrconven || '"';      
    END IF;                     
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_linhadet := to_char(rw_craptit4.cdagenci, 'fm000')||','||TRIM(to_char(vr_vltitulo, '999999990.00'));
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

  END LOOP;  -- Fim do loop craptit4

  -- TITULOS 085 PAGOS PELOS CAIXAS, INTERNET E CAIXA ONLINE - DESCONTADOS
  -- MOVIMENTA CONTA 4954
  vr_tab_agencia.delete;
  pc_cria_agencia_pltable(999,NULL);
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

  FOR rw_craptit5 in cr_craptit5 (pr_cdcooper,
                                  vr_dtmvtolt) LOOP
    pc_cria_agencia_pltable(rw_craptit5.cdagenci,NULL);
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

    vr_vltitulo := rw_craptit5.vldpagto;
    vr_tab_agencia(rw_craptit5.cdagenci).vr_qttottrf := rw_craptit5.qttottrf;
    vr_tab_agencia(999).vr_qttottrf := vr_tab_agencia(999).vr_qttottrf + rw_craptit5.qttottrf;
    --
    vr_linhadet := TRIM(vr_cdestrut)||
                   TRIM(vr_dtmvtolt_yymmdd)||','||
                   TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   TRIM(to_char(vr_tab_agencia2(rw_craptit5.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                   '4954,'|| -- Conta pendência da singular
                   TRIM(to_char(vr_vltitulo, '99999999999990.00'))||','||
                   '5210,'||
                   '"(crps249) SUA REMESSA - CONVENIO ' || rw_craptit5.nrconven || '"';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_linhadet := to_char(rw_craptit5.cdagenci, 'fm000')||','||TRIM(to_char(vr_vltitulo, '999999990.00'));
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  END LOOP;  -- Fim do loop craptit5

  -----------------------------Titulos Cooperativa-----------------------
  open cr_craphis2 (pr_cdcooper,
                    751);
    fetch cr_craphis2 into rw_craphis2;
  close cr_craphis2;
  --
  open cr_craptab (pr_cdcooper,
                   0, --cdempres
                   'GENERI', --tptabela
                   'TITCTARIFA', --cdacesso
                   1); --tpregist
    fetch cr_craptab into rw_craptab.dstextab;
    if cr_craptab%notfound then
      vr_vltarifa := 0;
    else
      vr_vltarifa := to_number(rw_craptab.dstextab);
    end if;
  close cr_craptab;
  --
  vr_tab_agencia.delete;
  pc_cria_agencia_pltable(999,NULL);
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

  /*for rw_craptit in cr_craptit (pr_cdcooper,
                                vr_dtmvtolt,
                                1) loop
    pc_cria_agencia_pltable(rw_craptit.cdagenci,NULL);
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    vr_vltitulo := rw_craptit.vldpagto;
    vr_tab_agencia(rw_craptit.cdagenci).vr_qttottrf := rw_craptit.qttottrf;
    vr_tab_agencia(999).vr_qttottrf := vr_tab_agencia(999).vr_qttottrf + rw_craptit.qttottrf;
    --
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   trim(to_char(vr_tab_agencia2(rw_craptit.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                   trim(to_char(rw_craphis2.nrctacrd,'0000'))||','||
                   trim(to_char(vr_vltitulo, '99999999999990.00'))||','||
                   '1538,'||
                   '"(crps249) NOSSA REMESSA."';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_linhadet := to_char(rw_craptit.cdagenci, 'fm000')||','||trim(to_char(vr_vltitulo, '999999990.00'));
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  end loop;  -- Fim do loop craptit*/

  FOR rw_craptit3 in cr_craptit3 (pr_cdcooper,
                                  vr_dtmvtolt) LOOP
    pc_cria_agencia_pltable(rw_craptit3.cdagenci,NULL);
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

    vr_vltitulo := rw_craptit3.vldpagto;
    vr_tab_agencia(rw_craptit3.cdagenci).vr_qttottrf := rw_craptit3.qttottrf;
    vr_tab_agencia(999).vr_qttottrf := vr_tab_agencia(999).vr_qttottrf + rw_craptit3.qttottrf;
    --
    vr_linhadet := TRIM(vr_cdestrut)||
                   TRIM(vr_dtmvtolt_yymmdd)||','||
                   TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   TRIM(to_char(vr_tab_agencia2(rw_craptit3.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                   '4954,'||
                   TRIM(to_char(vr_vltitulo, '99999999999990.00'))||','||
                   '5210,'||
                   '"(crps249) NOSSA REMESSA."';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_linhadet := to_char(rw_craptit3.cdagenci, 'fm000')||','||trim(to_char(vr_vltitulo, '999999990.00'));
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  END LOOP;  -- Fim do loop craptit3

  -- Desconto de cheques .....................................................
  vr_cdestrut := '51';
  vr_vlcdbtot := 0;
  vr_vlcdbjur := 0;
  -- Entradas de desconto de cheques no dia
  for rw_crapbdc in cr_crapbdc (pr_cdcooper,
                                vr_dtmvtolt) loop
    for rw_crapcdb in cr_crapcdb (pr_cdcooper,
                                  rw_crapbdc.nrborder) loop
      vr_vlcdbtot := vr_vlcdbtot + rw_crapcdb.vlcheque;
      vr_vlcdbjur := vr_vlcdbjur + (rw_crapcdb.vlcheque - rw_crapcdb.vlliquid);
      -- Grava dados operacionais contábeis
      pc_grava_crapopc(pr_cdcooper,
                       vr_dtmvtolt,
                       rw_crapcdb.nrdconta,
                       1, -- tpregist = 1 desconto de cheques
                       rw_crapcdb.nrborder,
                       rw_crapcdb.cdagenci,
                       rw_crapcdb.nrcheque,
                       rw_crapcdb.vlcheque,
                       1, -- cdtipope = 1 cheque recebido para desconto
                       vr_cdprogra);

      -- Incluir nome do módulo logado
      gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    end loop;
  end loop;
  --
  if vr_vlcdbtot > 0 then
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   '1641,'||
                   '4954,'||
                   trim(to_char(vr_vlcdbtot, '99999999999990.00'))||','||
                   '5210,'||
                   '"(crps249) CHEQUE RECEBIDO PARA DESCONTO."';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_linhadet := '999,'||trim(to_char(vr_vlcdbtot, '99999999999990.00'));
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   '4954,'||
                   '1642,'||
                   trim(to_char(vr_vlcdbjur, '99999999999990.00'))||','||
                   '5210,'||
                   '"(crps249) RECEITA DE CHEQUE RECEBIDO PARA DESCONTO."';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_linhadet := '999,'||trim(to_char(vr_vlcdbjur, '99999999999990.00'));
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   '3483,'||
                   '9144,'||
                   trim(to_char(vr_vlcdbtot, '99999999999990.00'))||','||
                   '5210,'||
                   '"(crps249) CHEQUE RECEBIDO PARA DESCONTO."';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  end if;
  --
  vr_vlcdbban := 0;
  vr_qtcdbban := 0;
  vr_vlcdbcop := 0;
  -- Liberacao de cheques descontados do dia -- envio para a COMPE  ...........
  open cr_crapcdb2(pr_cdcooper,
                                 vr_dtmvtoan,
                   vr_dtmvtolt);
  loop
    fetch cr_crapcdb2 bulk collect into rw_crapcdb limit 5000;

    -- Grava dados operacionais contábeis
    pc_grava_crapopc_bulk(pr_cdcooper,
                     vr_dtmvtolt,
                     rw_crapcdb,
                     1, -- tpregist = 1 desconto de cheques
                     2, -- cdtipope = 2 liquidacao cheque recebido para desconto
                     vr_cdprogra);

    exit when cr_crapcdb2%rowcount <= 5000;

    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

  end loop;
  close cr_crapcdb2;
  --
  
  if vr_vlcdbban > 0 then  -- Cheques de outros bancos
    open cr_crapage2(pr_cdcooper,
                     1);
      fetch cr_crapage2 into rw_crapage2;
      if cr_crapage2%notfound then
        close cr_crapage2;
        vr_cdcritic := 962;
        raise vr_exc_saida;
      else
        if rw_crapage2.cdbanchq = 1 then  -- Banco do Brasil
          vr_cdhistor := 731;
          vr_qtcdbban := 0;
        elsif rw_crapage2.cdbanchq = 756 then -- Bancoob
          vr_cdhistor := 547;
        elsif rw_crapage2.cdbanchq = rw_crapcop.cdbcoctl then
          vr_cdhistor := 466;
        else
          vr_cdhistor := 0;
        end if;
        --
        open cr_craphis2 (pr_cdcooper,
                          vr_cdhistor);
          fetch cr_craphis2 into rw_craphis2;
          if cr_craphis2%notfound then
            close cr_craphis2;
            vr_cdcritic := 526;
            vr_dscritic := vr_cdhistor||' - '||gene0001.fn_busca_critica(vr_cdcritic);
            RAISE vr_exc_saida;
          end if;
        close cr_craphis2;
      end if;
      --
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctadeb,'0000'))||','||
                     '1641,'||
                     trim(to_char(vr_vlcdbban, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) LIQUIDACAO DE CHEQUE RECEBIDO PARA DESCONTO."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      if rw_craphis2.ingerdeb = 2 then
        vr_linhadet := '999,'||trim(to_char(vr_vlcdbban, '999999990.00'));
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
      vr_linhadet := '999,'||trim(to_char(vr_vlcdbban, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '9144,'||
                     '3483,'||
                     trim(to_char(vr_vlcdbban, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) LIQUIDACAO DE CHEQUE RECEBIDO PARA DESCONTO."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    close cr_crapage2;
  end if;
  -- Lancamento de Tarifa - CHEQUE DESCONTO BANCOOB ........................
  if vr_qtcdbban > 0 then  -- Cheques de outros bancos
    -- Busca a tarifa
    open cr_craphis2 (pr_cdcooper,
                      547);
      fetch cr_craphis2 into rw_craphis2;
      if cr_craphis2%notfound then
        close cr_craphis2;
        vr_cdcritic := 526;
        vr_dscritic := '547 - '||gene0001.fn_busca_critica(vr_cdcritic);
        raise vr_exc_saida;
      end if;
    close cr_craphis2;
    --
    open cr_crapthi(pr_cdcooper,
                    547,
                    'AYLLOS');
      fetch cr_crapthi into rw_crapthi;
      if cr_crapthi%notfound then
        close cr_crapthi;
        vr_cdcritic := 1041;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' para histórico 547 - crapthi';
        -- Gera a mensagem de erro no log e não prossegue a rotina.
        btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro de negócio
                                  ,pr_nmarqlog      => 'proc_batch.log'
                                  ,pr_tpexecucao    => 1 -- Job
                                  ,pr_cdcriticidade => 1 -- Medio
                                  ,pr_cdmensagem    => vr_cdcritic
                                  ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '|| vr_dscritic);
        -- Troca de return por raise - Chamado 832035 - 16/01/2018 
        --return;
        RAISE vr_exc_saida;                    
      end if;
    close cr_crapthi;
    --
    if rw_crapthi.vltarifa > 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctatrd))||','||
                     trim(to_char(rw_craphis2.nrctatrc))||','||
                     trim(to_char(vr_qtcdbban * rw_crapthi.vltarifa, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) LIQUIDACAO DE CHEQUE RECEBIDO PARA DESCONTO (tarifa)."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '001,'||trim(to_char(vr_qtcdbban * rw_crapthi.vltarifa, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
  end if;
  --
  if vr_vlcdbcop > 0 then  -- Cheques da Cooperativa
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   '4957,'||
                   '1641,'||
                   trim(to_char(vr_vlcdbcop, '99999999999990.00'))||','||
                   '5210,'||
                   '"(crps249) LIQUIDACAO DE CHEQUE RECEBIDO PARA DESCONTO."';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_linhadet := '999,'||trim(to_char(vr_vlcdbcop, '99999999999990.00'));
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   '9144,'||
                   '3483,'||
                   trim(to_char(vr_vlcdbcop, '99999999999990.00'))||','||
                   '5210,'||
                   '"(crps249) LIQUIDACAO DE CHEQUE RECEBIDO PARA DESCONTO."';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  end if;
  -- Resgate de cheques descontados no dia ..................................
  vr_vlcdbban := 0;
  vr_vlcdbcop := 0;
  --
  for rw_crapcdb in cr_crapcdb3 (pr_cdcooper,
                                 vr_dtmvtolt) loop
    vr_vlcdbban := vr_vlcdbban + rw_crapcdb.vlcheque;
    vr_vlcdbcop := vr_vlcdbcop + (rw_crapcdb.vlliqdev - rw_crapcdb.vlliquid);
    -- Grava dados operacionais contábeis
    pc_grava_crapopc(pr_cdcooper,
                     vr_dtmvtolt,
                     rw_crapcdb.nrdconta,
                     1, -- tpregist = 1 desconto de cheques
                     rw_crapcdb.nrborder,
                     rw_crapcdb.cdagenci,
                     rw_crapcdb.nrcheque,
                     rw_crapcdb.vlcheque,
                     3, -- cdtipope = 3 Resgate de cheque descontado
                     vr_cdprogra);
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
  end loop;
  --
  if vr_vlcdbban > 0 then  -- Valor do cheque descontado
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   '4954,'||
                   '1641,'||
                   trim(to_char(vr_vlcdbban, '99999999999990.00'))||','||
                   '5210,'||
                   '"(crps249) RESGATE DE CHEQUES RECEBIDOS PARA DESCONTO."';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_linhadet := '999,'||trim(to_char(vr_vlcdbban, '99999999999990.00'));
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   '9144,'||
                   '3483,'||
                   trim(to_char(vr_vlcdbban, '99999999999990.00'))||','||
                   '5210,'||
                   '"(crps249) RESGATE DE CHEQUES RECEBIDOS PARA DESCONTO."';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  end if;
  --
  if vr_vlcdbcop > 0 then

    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   '1642,'||
                   '4954,'||
                   trim(to_char(vr_vlcdbcop, '99999999999990.00'))||','||
                   '2425,'||
                   '"(crps249) RESGATE DE CHEQUES RECEBIDOS PARA DESCONTO."';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_linhadet := '999,'||trim(to_char(vr_vlcdbcop, '99999999999990.00'));
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  end if;
  -- Desconto de titulos ......................................................
  vr_cdestrut := '51';
  vr_vltdbtot := 0;
  vr_vltdbjur := 0;
  vr_tdbtotsr := 0;
  vr_tdbjursr := 0;
  vr_tdbtotcr := 0;
  vr_tdbjurcr := 0;
  -- Entradas de desconto de titulos no dia.
  -- Existem situacoes que o bordero eh liquidado no mesmo dia de sua liberacao,
  -- principalmente por pagamentos antecipados, porem pode ser liquidado com o
  -- resgate de titulos, neste caso os titulos resgatados nao sao considerados
  for rw_crapbdt in cr_crapbdt (pr_cdcooper,
                                vr_dtmvtolt) loop
    for rw_craptdb in cr_craptdb (pr_cdcooper,
                                  rw_crapbdt.nrdconta,
                                  rw_crapbdt.nrborder) loop
      vr_vltdbtot := vr_vltdbtot + rw_craptdb.vltitulo;
      vr_vltdbjur := vr_vltdbjur + (rw_craptdb.vltitulo - rw_craptdb.vlliquid);
      --
      if rw_craptdb.flgregis = 1 /* true */ then
        vr_tdbtotcr := vr_tdbtotcr + rw_craptdb.vltitulo;
        vr_tdbjurcr := vr_tdbjurcr + (rw_craptdb.vltitulo - rw_craptdb.vlliquid);
      else
        vr_tdbtotsr := vr_tdbtotsr + rw_craptdb.vltitulo;
        vr_tdbjursr := vr_tdbjursr + (rw_craptdb.vltitulo - rw_craptdb.vlliquid);
      end if;
      -- Grava dados operacionais contábeis
      pc_grava_crapopc(pr_cdcooper,
                       vr_dtmvtolt,
                       rw_craptdb.nrdconta,
                       2, -- tpregist = 2 desconto de titulo
                       rw_craptdb.nrborder,
                       rw_crapbdt.cdagenci,
                       rw_craptdb.nrdocmto,
                       rw_craptdb.vltitulo,
                       1, -- cdtipope = 1 titulo recebido pra desconto
                       vr_cdprogra);
      -- Incluir nome do módulo logado
      gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    end loop;
  end loop;
  --
  if vr_vltdbtot > 0 then
    -- total de titulos descontados sem registro
    if vr_tdbtotsr > 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '1643,'||
                     '4954,'||
                     trim(to_char(vr_tdbtotsr, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) TITULO RECEBIDO PARA DESCONTO S/ REGISTRO."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_tdbtotsr, '99999999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '4954,'||
                     '1644,'||
                     trim(to_char(vr_tdbjursr, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) RENDA DE TITULO RECEBIDO PARA DESCONTO S/ REGISTRO."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_tdbjursr, '99999999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
    -- total de titulos descontados com registro
    if vr_tdbtotcr > 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '1645,'||
                     '4954,'||
                     trim(to_char(vr_tdbtotcr, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) TITULO RECEBIDO PARA DESCONTO C/ REGISTRO."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_tdbtotcr, '99999999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '4954,'||
                     '1646,'||
                     trim(to_char(vr_tdbjurcr, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) RENDA DE TITULO RECEBIDO PARA DESCONTO C/ REGISTRO."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_tdbjurcr, '99999999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
  end if;
  --
  vr_vltdbtot := 0;
  vr_tdbtotsr := 0;
  vr_tdbjursr := 0;
  vr_tdbtotcr_001 := 0;
  vr_tdbtotcr_085 := 0;
  vr_tdbjurcr_001 := 0;
  vr_tdbjurcr_085 := 0;
  vr_qttdbtot := 0;
  vr_qtdtdbsr := 0;
  vr_dtrefere := gene0005.fn_valida_dia_util(pr_cdcooper,
                                             vr_dtmvtoan - 1,
                                             'A');
  -- Liberacao de titulos pagos no dia - Pagos pelo SACADO - via COMPE...
  -- Lancar a liquidacao de titulos recebidos via COMPE com D+1, sendo assim
  -- ele pega os titulos que foram pagos no ultimo dia anterior e lanca com a
  -- data atual - Pedido da contabilidade
  -- *** somente titulos do Banco do Brasil -> credito D+1 (Rafael) ***
  -- Obs.: a movimentacao contabil abaixo refere-se aos titulos descontados
  -- da cooperativa, com excecao dos titulos migrados. (Rafael)

  vr_tab_agencia.delete;
  for rw_craptdb in cr_craptdb2 (pr_cdcooper,
                                 vr_dtrefere,
                                 vr_dtmvtoan,
                                 1) loop
    open cr_crapcob (rw_craptdb.cdcooper,
                     rw_craptdb.cdbandoc,
                     rw_craptdb.nrdctabb,
                     rw_craptdb.nrcnvcob,
                     rw_craptdb.nrdconta,
                     rw_craptdb.nrdocmto);
      fetch cr_crapcob into rw_crapcob;
      -- Se não encontrar registros
      if cr_crapcob%notfound then
        close cr_crapcob; -- Fecha o cursor
        continue; -- Próximo registro
      end if;
    close cr_crapcob;
    -- Alteração no progress feita pelo Rafael Cechet, alterado no Oracle por Daniel (Supero)
    open cr_crapcco (pr_cdcooper,
                     rw_crapcob.nrcnvcob);
      fetch cr_crapcco into rw_crapcco;
      if cr_crapcco%notfound then
        CLOSE cr_crapcco;
        continue;
      end if;
    close cr_crapcco;

    if  rw_crapcco.dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN
      continue;
    end if;

    -- Fim da alteração
    -- Pago pela COMPE
    if rw_crapcob.indpagto = 0 then
      vr_vltdbtot := vr_vltdbtot + rw_crapcob.vldpagto;
      vr_qttdbtot := vr_qttdbtot + 1;
      -- Buscar a agência
      open cr_crapass (pr_cdcooper,
                       rw_crapcob.nrdconta);
        fetch cr_crapass into rw_crapass;
      close cr_crapass;
      -- Acumula valores
      pc_cria_agencia_pltable(rw_crapass.cdagenci,NULL);
      -- Incluir nome do módulo logado
      gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
      --
      if rw_crapcob.flgregis = 1 then -- true
        vr_tdbtotcr_001 := vr_tdbtotcr_001 + rw_crapcob.vldpagto;
        vr_tdbjurcr_001 := vr_tdbjurcr_001 + (rw_craptdb.vltitulo - rw_craptdb.vlliquid);
        vr_tab_agencia(rw_crapass.cdagenci).vr_qttarpac_001 := vr_tab_agencia(rw_crapass.cdagenci).vr_qttarpac_001 + 1;
        vr_qtdtdbcr_001 := vr_qtdtdbcr_001 + 1;
      else
        vr_tdbtotsr := vr_tdbtotsr + rw_crapcob.vldpagto;
        vr_tdbjursr := vr_tdbjursr + (rw_craptdb.vltitulo - rw_craptdb.vlliquid);
        if rw_crapcco.dsorgarq NOT IN ('MIGRACAO','INCORPORACAO') then -- IF incluído na alteração do Rafael Cechet
          vr_tab_agencia(rw_crapass.cdagenci).vr_qttarpac := vr_tab_agencia(rw_crapass.cdagenci).vr_qttarpac + 1;
          vr_qtdtdbsr := vr_qtdtdbsr + 1;
        end if;
      end if;
      --
      open cr_crapbdt2 (pr_cdcooper,
                        rw_craptdb.dtlibbdt,
                        rw_craptdb.nrborder,
                        rw_craptdb.nrdconta);
        fetch cr_crapbdt2 into rw_crapbdt2;
      close cr_crapbdt2;
      -- Grava dados operacionais contábeis
      pc_grava_crapopc(pr_cdcooper,
                    vr_dtmvtolt,
                    rw_craptdb.nrdconta,
                    2, -- tpregist = 2 desconto de titulo
                    rw_craptdb.nrborder,
                    rw_crapbdt2.cdagenci,
                    rw_craptdb.nrdocmto,
                    rw_crapcob.vldpagto,
                    2, -- cdtipope = 2 liquidacao de titulo recebido pra desconto
                    vr_cdprogra);
      -- Incluir nome do módulo logado
      gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    end if;
  end loop;
  --
  if vr_vltdbtot > 0 then
    if vr_tdbtotsr > 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '1172,'||
                     '1643,'||
                     trim(to_char(vr_tdbtotsr, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) LIQUIDACAO DE TITULO RECEBIDO PARA DESCONTO S/ REGISTRO."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_tdbtotsr, '99999999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      -- Busca a tarifa
      open cr_craphis2 (pr_cdcooper,
                        266);
        fetch cr_craphis2 into rw_craphis2;
        if cr_craphis2%notfound then
          close cr_craphis2;
          vr_cdcritic := 526;
          vr_dscritic := '266 - '||gene0001.fn_busca_critica(vr_cdcritic);
          raise vr_exc_saida;
        end if;
      close cr_craphis2;
      --
      open cr_crapthi(pr_cdcooper,
                      266,  -- CREDITO DE COBRANCA BANCO DO BRASIL
                      'AYLLOS');
        fetch cr_crapthi into rw_crapthi;
        if cr_crapthi%notfound then
          close cr_crapthi;
          vr_cdcritic := 1041;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' para histórico 266 - crapthi';
          -- Gera a mensagem de erro no log e não prossegue a rotina.
          btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                    ,pr_ind_tipo_log  => 2 -- Erro de negócio
                                    ,pr_nmarqlog      => 'proc_batch.log'
                                    ,pr_tpexecucao    => 1 -- Job
                                    ,pr_cdcriticidade => 1 -- Medio
                                    ,pr_cdmensagem    => vr_cdcritic
                                    ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '|| vr_dscritic);
          -- Troca de return por raise - Chamado 832035 - 16/01/2018 
          --return;
          RAISE vr_exc_saida;                    
        end if;
      close cr_crapthi;
      --
      vr_linhadet := '55'||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctatrd))||','||
                     trim(to_char(rw_craphis2.nrctatrc))||','||
                     trim(to_char(vr_qtdtdbsr * rw_crapthi.vltarifa, '99999999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                     ') '||trim(rw_craphis2.dsexthst)||' (tarifa)"';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      -- Cria lançamentos por agência
      vr_indice_agencia := vr_tab_agencia.first;
      while vr_indice_agencia <= 998 loop
        if vr_tab_agencia(vr_indice_agencia).vr_qttarpac > 0 then
          vr_linhadet := to_char(vr_indice_agencia, 'fm000')||','||
                         trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_qttarpac * rw_crapthi.vltarifa, '999999990.00'));
          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
        vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
      end loop;
    end if;
    --
    if vr_tdbtotcr_001 > 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '1257,'||
                     '1645,'||
                     trim(to_char(vr_tdbtotcr_001, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) LIQUIDACAO DE TITULO RECEBIDO PARA DESCONTO C/ REGISTRO VIA BANCO."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_tdbtotcr_001, '99999999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
  end if;

  --
  vr_tdbtotsr := 0;
  vr_qttdbtot := 0;
  vr_vltdbtot := 0;
  vr_tdbjursr := 0;
  vr_tdbtotcr_001 := 0;
  vr_tdbjurcr_001 := 0;
  vr_tdbtotcr_085 := 0;
  vr_tdbjurcr_085 := 0;


  vr_dtrefere := gene0005.fn_valida_dia_util(pr_cdcooper,
                                             vr_dtmvtoan - 1,
                                             'A');

 --  Liberacao de titulos pagos no dia - Pagos pelo SACADO - via COMPE...
 --  Lancar a liquidacao de titulos recebidos via COMPE com D+1, sendo assim
 --  ele pega os titulos que foram pagos no ultimo dia anterior e lanca com a
 --  data atual - Pedido da contabilidade
 --  *** somente titulos do Banco do Brasil -> credito D+1 (Rafael) ***
 for rw_craptdb in cr_craptdb2 (pr_cdcooper,
                                vr_dtrefere,
                                vr_dtmvtoan,
                                1) loop

   OPEN cr_crapcob (pr_cdcooper => rw_craptdb.cdcooper,
                    pr_cdbandoc => rw_craptdb.cdbandoc,
                    pr_nrdctabb => rw_craptdb.nrdctabb,
                    pr_nrcnvcob => rw_craptdb.nrcnvcob,
                    pr_nrdconta => rw_craptdb.nrdconta,
                    pr_nrdocmto => rw_craptdb.nrdocmto);

   FETCH cr_crapcob INTO rw_crapcob;

   IF  cr_crapcob%notfound  THEN
     CLOSE cr_crapcob;
     CONTINUE;
   END IF;

   CLOSE cr_crapcob;

   OPEN cr_crapcco (pr_cdcooper => pr_cdcooper,
                    pr_nrcnvcob => rw_crapcob.nrcnvcob);

   FETCH cr_crapcco INTO rw_crapcco;

   IF  cr_crapcco%notfound  THEN
     CLOSE cr_crapcco;
     CONTINUE;
   END IF;

   CLOSE cr_crapcco;

   IF rw_crapcco.dsorgarq NOT IN ('MIGRACAO','INCORPORACAO') THEN
     CONTINUE;
   END IF;

   --  Pago pela COMPE
   IF  rw_crapcob.indpagto = 0  THEN

     vr_vltdbtot := vr_vltdbtot + rw_crapcob.vldpagto;
     vr_qttdbtot := vr_qttdbtot + 1;

     -- Buscar a agência
     open cr_crapass (pr_cdcooper,
                      rw_crapcob.nrdconta);

     fetch cr_crapass into rw_crapass;

     close cr_crapass;

     -- Cobranca registrada
     IF  rw_crapcob.flgregis = 1   THEN
       vr_tdbtotcr_001 := vr_tdbtotcr_001 + rw_crapcob.vldpagto;
       vr_tdbjurcr_001 := vr_tdbjurcr_001 + (rw_craptdb.vltitulo - rw_craptdb.vlliquid);
       -- Acumula valores
       pc_cria_agencia_pltable(rw_crapass.cdagenci,NULL);
       -- Incluir nome do módulo logado
       gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
       vr_tab_agencia(rw_crapass.cdagenci).vr_qttarpac_001 := vr_tab_agencia(rw_crapass.cdagenci).vr_qttarpac_001 + 1;
       vr_qtdtdbcr_001 := vr_qtdtdbcr_001 + 1;
     ELSE
       vr_tdbtotsr := vr_tdbtotsr + rw_crapcob.vldpagto;
       vr_tdbjursr := vr_tdbjursr + (rw_craptdb.vltitulo - rw_craptdb.vlliquid);
     END IF;

     open cr_crapbdt2 (pr_cdcooper,
                       rw_craptdb.dtlibbdt,
                       rw_craptdb.nrborder,
                       rw_craptdb.nrdconta);

     fetch cr_crapbdt2 into rw_crapbdt2;

     close cr_crapbdt2;

     -- Grava dados operacionais contábeis
     pc_grava_crapopc(pr_cdcooper,
                      vr_dtmvtolt,
                      rw_craptdb.nrdconta,
                      2, -- tpregist = 2 desconto de titulo
                      rw_craptdb.nrborder,
                      rw_crapbdt2.cdagenci,
                      rw_craptdb.nrdocmto,
                      rw_crapcob.vldpagto,
                      2, -- cdtipope = 2 liquidacao de titulo recebido pra desconto
                      vr_cdprogra);
     -- Incluir nome do módulo logado
     gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
   END IF;

 end loop;  -- Fim loop craptdb

 if  vr_vltdbtot > 0  then

   if  vr_tdbtotsr > 0  then
     vr_linhadet := trim(vr_cdestrut)||
                    trim(vr_dtmvtolt_yymmdd)||','||
                    trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                    '1839,'||
                    '1643,'||
                    trim(to_char(vr_tdbtotsr, '99999999999990.00'))||','||
                    '5210,'||
                    '"(crps249) LIQUIDACAO DE TITULO MIGRADO RECEBIDO PARA DESCONTO S/ REGISTRO"';
     gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
     vr_linhadet := '999,'||trim(to_char(vr_tdbtotsr, '99999999999990.00'));
     gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
   end if;

   if vr_tdbtotcr_001 > 0  then
      vr_linhadet := trim(vr_cdestrut)||
                    trim(vr_dtmvtolt_yymmdd)||','||
                    trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                    '1839,'||
                    '1645,'||
                    trim(to_char(vr_tdbtotcr_001, '99999999999990.00'))||','||
                    '5210,'||
                    '"(crps249) LIQUIDACAO DE TITULO MIGRADO RECEBIDO PARA DESCONTO C/ REGISTRO VIA BANCO"';
     gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
     vr_linhadet := '999,'||trim(to_char(vr_tdbtotcr_001, '99999999999990.00'));
     gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
   end if;

 end if;

 vr_vltdbtot := 0;

  -- Liberacao de titulos pagos no dia - Pagos pelo SACADO - via COMPE...
  -- Lancar a liquidacao de titulos recebidos via COMPE com D+0, sendo assim
  -- ele pega os titulos que foram pagos no ultimo dia anterior e lanca com a
  -- data atual - Pedido da contabilidade
  -- *** somente titulos da compe 085 (Rafael) ***
  --
  vr_tab_agencia.delete;
  for rw_craptdb in cr_craptdb3 (pr_cdcooper,
                                 vr_dtmvtolt) loop
    open cr_crapcob (rw_craptdb.cdcooper,
                     85 /* cdbandoc */,
                     rw_craptdb.nrdctabb,
                     rw_craptdb.nrcnvcob,
                     rw_craptdb.nrdconta,
                     rw_craptdb.nrdocmto);
      fetch cr_crapcob into rw_crapcob;
      -- Se não encontrar registros
      if cr_crapcob%notfound then
        close cr_crapcob; -- Fecha o cursor
        continue; -- Próximo registro
      end if;
    close cr_crapcob;
    -- Pago pela COMPE
    if rw_crapcob.indpagto = 0 then
      vr_vltdbtot := vr_vltdbtot + rw_crapcob.vldpagto;
      vr_qttdbtot := vr_qttdbtot + 1;
      -- Buscar a agência
      open cr_crapass (pr_cdcooper,
                       rw_crapcob.nrdconta);
        fetch cr_crapass into rw_crapass;
      close cr_crapass;
      -- Acumula valores
      pc_cria_agencia_pltable(rw_crapass.cdagenci,NULL);
      -- Incluir nome do módulo logado
      gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
      --
      vr_tdbtotcr_085 := vr_tdbtotcr_085 + rw_crapcob.vldpagto;
      vr_tdbjurcr_085 := vr_tdbjurcr_085 + (rw_craptdb.vltitulo - rw_craptdb.vlliquid);
      vr_tab_agencia(rw_crapass.cdagenci).vr_qttarpac_085 := vr_tab_agencia(rw_crapass.cdagenci).vr_qttarpac_085 + 1;
      vr_qtdtdbcr_085 := vr_qtdtdbcr_085 + 1;
      --
      open cr_crapbdt2 (pr_cdcooper,
                        rw_craptdb.dtlibbdt,
                        rw_craptdb.nrborder,
                        rw_craptdb.nrdconta);
        fetch cr_crapbdt2 into rw_crapbdt2;
      close cr_crapbdt2;
      -- Grava dados operacionais contábeis
      pc_grava_crapopc(pr_cdcooper,
                    vr_dtmvtolt,
                    rw_craptdb.nrdconta,
                    2, -- tpregist = 2 desconto de titulo
                    rw_craptdb.nrborder,
                    rw_crapbdt2.cdagenci,
                    rw_craptdb.nrdocmto,
                    rw_crapcob.vldpagto,
                    2, -- cdtipope = 2 liquidacao de titulo recebido pra desconto
                    vr_cdprogra);
      -- Incluir nome do módulo logado
      gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    end if;
  end loop;
  --
  if vr_vltdbtot > 0 then
    if vr_tdbtotcr_085 > 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '1455,'||
                     '1645,'||
                     trim(to_char(vr_tdbtotcr_085, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) LIQUIDACAO DE TITULO RECEBIDO PARA DESCONTO C/ REGISTRO VIA COMPE."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_tdbtotcr_085, '99999999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
  end if;
  --
  vr_vltdbtot := 0;
  vr_tdbtotcr := 0;
  vr_tdbtotsr := 0;
  -- Liberacao de titulos pagos no dia -
  -- Pagos pelo SACADO - via CAIXA indpagto = 1
  -- INTERNET pac 90 indpagto = 3
  -- TAA pac 91 indpagto = 4
  --
  for rw_craptdb in cr_craptdb2 (pr_cdcooper,
                                 vr_dtmvtoan,
                                 vr_dtmvtolt,
                                 null) loop
    open cr_crapcob (rw_craptdb.cdcooper,
                     rw_craptdb.cdbandoc,
                     rw_craptdb.nrdctabb,
                     rw_craptdb.nrcnvcob,
                     rw_craptdb.nrdconta,
                     rw_craptdb.nrdocmto);
      fetch cr_crapcob into rw_crapcob;
      --
      if cr_crapcob%notfound then
        close cr_crapcob;
        -- Alteração no codigo da critica de 1033 para 1113 - Chamado 832035 - 16/01/2018
        vr_cdcritic := 1113;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' no crapcob - ROWID(craptdb) = '||rw_craptdb.rowid;
        btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro de negócio
                                  ,pr_nmarqlog      => 'proc_batch.log'
                                  ,pr_tpexecucao    => 1 -- Job
                                  ,pr_cdcriticidade => 1 -- Medio
                                  ,pr_cdmensagem    => vr_cdcritic
                                  ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '|| vr_dscritic);
        continue;
      end if;
    close cr_crapcob;
    -- Pago pelo CAIXA, pela INTERNET (pac 90) ou TAA (pac 91)
    if rw_crapcob.indpagto in (1, 3, 4) then
      vr_vltdbtot := vr_vltdbtot + rw_crapcob.vldpagto;
      if rw_crapcob.flgregis = 1 then -- true
        vr_tdbtotcr := vr_tdbtotcr + rw_crapcob.vldpagto;
      else
        vr_tdbtotsr := vr_tdbtotsr + rw_crapcob.vldpagto;
      end if;
      --
      open cr_crapbdt2 (pr_cdcooper,
                        rw_craptdb.dtlibbdt,
                        rw_craptdb.nrborder,
                        rw_craptdb.nrdconta);
        fetch cr_crapbdt2 into rw_crapbdt2;
      close cr_crapbdt2;
      -- Grava dados operacionais contábeis
      pc_grava_crapopc(pr_cdcooper,
                    vr_dtmvtolt,
                    rw_craptdb.nrdconta,
                    2, -- tpregist = 2 desconto de titulo
                    rw_craptdb.nrborder,
                    rw_crapbdt2.cdagenci,
                    rw_craptdb.nrdocmto,
                    rw_crapcob.vldpagto,
                    2, -- cdtipope = 2 liquidacao de titulo recebido pra desconto
                    vr_cdprogra);
      -- Incluir nome do módulo logado
      gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    end if;
  end loop;
  --
  if vr_vltdbtot > 0 then
    if vr_tdbtotsr > 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '4954,'||
                     '1643,'||
                     trim(to_char(vr_tdbtotsr, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) LIQUIDACAO DE TITULO RECEBIDO PARA DESCONTO S/ REGISTRO."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_tdbtotsr, '99999999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
    --
    if vr_tdbtotcr > 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '4954,'||
                     '1645,'||
                     trim(to_char(vr_tdbtotcr, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) LIQUIDACAO DE TITULO RECEBIDO PARA DESCONTO C/ REGISTRO."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_tdbtotcr, '99999999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
  end if;
  --
  vr_vltdbtot := 0;
  vr_tdbtotcr := 0;
  vr_tdbtotsr := 0;
  -- Liberacao de titulos vencidos - Pagos pelo CEDENTE .............
  vr_dtrefere := fn_calcula_data(pr_cdcooper,
                                 vr_dtmvtoan);
  for rw_craptdb in cr_craptdb4 (pr_cdcooper
                                ,btch0001.rw_crapdat.dtmvtolt) loop

    open cr_crapcob (rw_craptdb.cdcooper,
                     rw_craptdb.cdbandoc,
                     rw_craptdb.nrdctabb,
                     rw_craptdb.nrcnvcob,
                     rw_craptdb.nrdconta,
                     rw_craptdb.nrdocmto);
      fetch cr_crapcob into rw_crapcob;
      --
      if cr_crapcob%notfound then
        close cr_crapcob;
        -- Alteração no codigo da critica de 1033 para 1113 - Chamado 832035 - 16/01/2018
        vr_cdcritic := 1113;
        vr_dscritic := 'Pagos pelo cedente '||gene0001.fn_busca_critica(vr_cdcritic)||' no crapcob - ROWID(craptdb) = '||rw_craptdb.rowid;
        btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro de negócio
                                  ,pr_nmarqlog      => 'proc_batch.log'
                                  ,pr_tpexecucao    => 1 -- Job
                                  ,pr_cdcriticidade => 1 -- Medio
                                  ,pr_cdmensagem    => vr_cdcritic
                                  ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '|| vr_dscritic);
        continue;
      end if;
    close cr_crapcob;
    -- No caso de fim de semana e feriado, nao pega os titulos que ja foram
    -- pegos no dia anterior a ontem
    if vr_dtrefere <> vr_dtmvtoan and
       rw_craptdb.dtvencto = vr_dtrefere then
      continue;
    end if;
    --
    vr_vltdbtot := vr_vltdbtot + rw_crapcob.vltitulo;
    if rw_crapcob.flgregis = 1 then -- true
      vr_tdbtotcr := vr_tdbtotcr + rw_crapcob.vltitulo;
    else
      vr_tdbtotsr := vr_tdbtotsr + rw_crapcob.vltitulo;
    end if;
    --
    open cr_crapbdt2 (pr_cdcooper,
                      rw_craptdb.dtlibbdt,
                      rw_craptdb.nrborder,
                      rw_craptdb.nrdconta);
      fetch cr_crapbdt2 into rw_crapbdt2;
    close cr_crapbdt2;
    -- Grava dados operacionais contábeis
    pc_grava_crapopc(pr_cdcooper,
                  vr_dtmvtolt,
                  rw_craptdb.nrdconta,
                  2, -- tpregist = 2 desconto de titulo
                  rw_craptdb.nrborder,
                  rw_crapbdt2.cdagenci,
                  rw_craptdb.nrdocmto,
                  rw_crapcob.vltitulo,
                  2, -- cdtipope = 2 liquidacao de titulo recebido pra desconto
                  vr_cdprogra);
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
  end loop;
  --
  if vr_vltdbtot > 0 then
    if vr_tdbtotsr > 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '4957,'||
                     '1643,'||
                     trim(to_char(vr_tdbtotsr, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) DEBITO DE TITULO DESCONTADO VENCIDO E NAO PAGO S/ REGISTRO."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_tdbtotsr, '99999999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
    --
    if vr_tdbtotcr > 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '4957,'||
                     '1645,'||
                     trim(to_char(vr_tdbtotcr, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) DEBITO DE TITULO DESCONTADO VENCIDO E NAO PAGO C/ REGISTRO."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_tdbtotcr, '99999999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
  end if;
  --
  vr_vltdbtot := 0;
  vr_vltdbjur := 0;
  vr_tdbtotsr := 0;
  vr_tdbtotcr := 0;
  vr_tdbjursr := 0;
  vr_tdbjurcr := 0;
  -- Nao considera os resgates efetuados no mesmo dia da liberacao pois nao eh
  -- considerada entrada do titulo em desconto
  for rw_craptdb in cr_craptdb5 (pr_cdcooper,
                                 vr_dtmvtolt) loop
    open cr_crapcob (rw_craptdb.cdcooper,
                     rw_craptdb.cdbandoc,
                     rw_craptdb.nrdctabb,
                     rw_craptdb.nrcnvcob,
                     rw_craptdb.nrdconta,
                     rw_craptdb.nrdocmto);
      fetch cr_crapcob into rw_crapcob;
      --
      if cr_crapcob%notfound then
        close cr_crapcob;
        -- Alteração no codigo da critica de 1033 para 1113 - Chamado 832035 - 16/01/2018
        vr_cdcritic := 1113;
        vr_dscritic := 'Nao eh considerada '||gene0001.fn_busca_critica(vr_cdcritic)||' no crapcob - ROWID(craptdb) = '||rw_craptdb.rowid;
        btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro de negócio
                                  ,pr_nmarqlog      => 'proc_batch.log'
                                  ,pr_tpexecucao    => 1 -- Job
                                  ,pr_cdcriticidade => 1 -- Medio
                                  ,pr_cdmensagem    => vr_cdcritic
                                  ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '|| vr_dscritic);
        continue;
      end if;
    close cr_crapcob;
    --
    vr_vltdbtot := vr_vltdbtot + rw_craptdb.vltitulo;
    vr_vltdbjur := vr_vltdbjur + (rw_craptdb.vlliqres - rw_craptdb.vlliquid);
    --
    vr_vltdbtot := vr_vltdbtot + rw_crapcob.vltitulo;
    if rw_crapcob.flgregis = 1 /* true */ then
      vr_tdbtotcr := vr_tdbtotcr + rw_crapcob.vltitulo;
      vr_tdbjurcr := vr_tdbjurcr + (rw_craptdb.vlliqres - rw_craptdb.vlliquid);
    else
      vr_tdbtotsr := vr_tdbtotsr + rw_crapcob.vltitulo;
      vr_tdbjursr := vr_tdbjursr + (rw_craptdb.vlliqres - rw_craptdb.vlliquid);
    end if;
    --
    open cr_crapbdt2 (pr_cdcooper,
                      rw_craptdb.dtlibbdt,
                      rw_craptdb.nrborder,
                      rw_craptdb.nrdconta);
      fetch cr_crapbdt2 into rw_crapbdt2;
    close cr_crapbdt2;

    -- Grava dados operacionais contábeis
    pc_grava_crapopc(pr_cdcooper,
                  vr_dtmvtolt,
                  rw_craptdb.nrdconta,
                  2, -- tpregist = 2 desconto de titulo
                  rw_craptdb.nrborder,
                  rw_crapbdt2.cdagenci,
                  rw_craptdb.nrdocmto,
                  rw_crapcob.vltitulo,
                  3, -- cdtipope = 3 resgate de titulo recebido pra desconto
                  vr_cdprogra);
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
  end loop;
  --
  if vr_vltdbtot > 0 then
    if vr_tdbtotsr > 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '4954,'||
                     '1643,'||
                     trim(to_char(vr_tdbtotsr, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) RESGATE DE TITULO RECEBIDO PARA DESCONTO S/ REGISTRO."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_tdbtotsr, '99999999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
    --
    if vr_tdbtotcr > 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '4954,'||
                     '1645,'||
                     trim(to_char(vr_tdbtotcr, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) RESGATE DE TITULO RECEBIDO PARA DESCONTO C/ REGISTRO."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_tdbtotcr, '99999999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
  end if;
  --
  if vr_vltdbjur > 0 then
    if vr_tdbjursr > 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '1644,'||
                     '4954,'||
                     trim(to_char(vr_tdbjursr, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) RESGATE DE TITULO RECEBIDO PARA DESCONTO."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_tdbjursr, '99999999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
    --
    if vr_tdbjurcr > 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '1646,'||
                     '4954,'||
                     trim(to_char(vr_tdbjurcr, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) RESGATE DE TITULO RECEBIDO PARA DESCONTO."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := '999,'||trim(to_char(vr_tdbjurcr, '99999999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
  end if;
  -- COBRANCA REGISTRADA .....................................................
  vr_cdhistbb := 0;
  -- Incluir no arquivo as informações consistentes
  for rw_crapret in cr_crapret (pr_cdcooper,
                                vr_dtmvtolt) loop
    if rw_crapret.cdhistbb <> vr_cdhistbb and
       rw_crapret.vltarcus_tot + rw_crapret.vloutdes_tot > 0 then
      open cr_craphis2 (pr_cdcooper,
                        rw_crapret.cdhistbb);
        fetch cr_craphis2 into rw_craphis2;
        --
        vr_linhadet := '55'||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       trim(to_char(rw_craphis2.nrctadeb,'0000'))||','||
                       trim(to_char(rw_craphis2.nrctacrd,'0000'))||','||
                       trim(to_char(rw_crapret.vltarcus_tot + rw_crapret.vloutdes_tot, '99999999999990.00'))||','||
                       trim(to_char(rw_craphis2.cdhstctb))||','||
                       '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                       ') '||trim(rw_craphis2.dsexthst)||' (tarifa)"';
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      close cr_craphis2;
    end if;
    --
    if rw_crapret.vltarcus + rw_crapret.vloutdes > 0 then
      vr_linhadet := to_char(rw_crapret.cdagenci, 'fm000')||','||
                     trim(to_char(rw_crapret.vltarcus + rw_crapret.vloutdes, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
    --
    vr_cdhistbb := rw_crapret.cdhistbb;
  end loop;
  -- Gerar inconsistência para os registros de cobrança cujo associado não está cadastrado
  for rw_crapret2 in cr_crapret2 (pr_cdcooper,
                                  vr_dtmvtolt) loop
    -- busca a agência
    vr_cdcritic := 1042;
    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' na Cob. Registrada crapret - ROWID(crapret) = '||rw_crapret2.rowid;
    btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                              ,pr_ind_tipo_log  => 2 -- Erro de negócio
                              ,pr_nmarqlog      => 'proc_batch.log'
                              ,pr_tpexecucao    => 1 -- Job
                              ,pr_cdcriticidade => 1 -- Medio
                              ,pr_cdmensagem    => vr_cdcritic
                              ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                  || vr_cdprogra || ' --> '|| vr_dscritic);
  end loop;

  -- PROCESSAR LANÇAMENTOS DOS TITULOS 085 CREDITADOS AOS COOPERADOS
  -- MOVIMENTA CONTA 4957 - Boleto de emprestimo (Projeto 210)  
  for rw_crapret3 in cr_crapret3 (pr_cdcooper => pr_cdcooper,
                                  pr_dtocorre => vr_dtmvtolt) loop

    IF rw_crapret3.dsorgarq <> 'EMPRESTIMO' THEN
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '1455,'|| -- Cecred COMPE (D)
                     '4972,'|| -- Conta pendência da singular (C)
                     trim(to_char(rw_crapret3.vlrpagto, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) SUA REMESSA – CONVENIO ' || to_char(rw_crapret3.nrcnvcob) || '"';
    ELSE
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     '1455,'|| -- Cecred COMPE (D)
                     '4957,'|| -- Conta pendência da singular (C)
                     trim(to_char(rw_crapret3.vlrpagto, '99999999999990.00'))||','||
                     '5210,'||
                     '"(crps249) SUA REMESSA – CONVENIO EMPRESTIMO ' || to_char(rw_crapret3.nrcnvcob) || '"';      
    END IF;
    
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

  end loop;  -- Fim do loop crapret3

  --  ACERTO FINANCEIRO BB (entre singulares - migracao Alto Vale, Acredi) ............
  if pr_cdcooper = 1 or
     pr_cdcooper = 2 then
    for rw_crapafi in cr_crapafi (pr_cdcooper,
                                  vr_dtmvtolt) loop

      -- Se o valor dos lançamentos for maior que zero
      IF rw_crapafi.vlafitot > 0  THEN

        -- Obter coperativa de destino
        OPEN cr_crapcop (pr_cdcooper => rw_crapafi.cdcopdst);

        FETCH cr_crapcop INTO rw_crapcop_2;

        CLOSE cr_crapcop;

        IF rw_crapafi.cdhistor = 266 THEN
          -- credito de cobranca sem registro
          vr_linhadet := trim(vr_cdestrut)||
                         trim(vr_dtmvtolt_yymmdd)||','||
                         trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                         '1172,'||
                         '4990,'||
                         trim(to_char(rw_crapafi.vlafitot, '99999999999990.00'))||','||
                         '5210,'||
                         '"(crps249) VALORES A REPASSAR ' || rw_crapcop_2.nmrescop || ' - LIQUIDACAO COBRANCA S/REGISTRO."';
        ELSE
          -- credito de cobranca registrada
          vr_linhadet := trim(vr_cdestrut)||
                         trim(vr_dtmvtolt_yymmdd)||','||
                         trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                         '1257,'||
                         '4990,'||
                         trim(to_char(rw_crapafi.vlafitot, '99999999999990.00'))||','||
                         '5210,'||
                         '"(crps249) VALORES A REPASSAR VIACREDI AV - LIQUIDACAO COBRANCA C/REGISTRO."';
        END IF;

        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

      END IF;

    END LOOP;

    -- Limpar a PL / TABLE
    vr_tab_hist_cob.DELETE;

    -- Debito de Tarifa - Cobranca com e sem registro
    FOR rw_histori IN cr_histori (pr_cdcooper => pr_cdcooper) LOOP

      IF  rw_histori.dsorgarq NOT IN ('MIGRACAO','INCORPORACAO') THEN

        vr_indice_hist_cob := to_char(rw_histori.cdhistor,'00000') || to_char(rw_histori.nrdctabb,'000000000000') || to_char(rw_histori.flgregis);

        IF  NOT vr_tab_hist_cob.EXISTS(vr_indice_hist_cob)  THEN
          vr_tab_hist_cob(vr_indice_hist_cob).cdhistor := rw_histori.cdhistor;
          vr_tab_hist_cob(vr_indice_hist_cob).nrdctabb := rw_histori.nrdctabb;
          vr_tab_hist_cob(vr_indice_hist_cob).flgregis := rw_histori.flgregis;
        END IF;

      END IF;

    END LOOP;

    -- Percorrer a tabela com os debitos de tarifa de cobranca
    vr_indice_hist_cob := vr_tab_hist_cob.FIRST;

    LOOP

      EXIT WHEN vr_indice_hist_cob IS NULL;

      -- Debito de Tarifa - com e sem registro
      FOR rw_crapafi IN cr_crapafi3 (pr_cdcooper => pr_cdcooper,
                                     pr_dtmvtolt => vr_dtmvtolt,
                                     pr_cdhistor => vr_tab_hist_cob(vr_indice_hist_cob).cdhistor,
                                     pr_nrdctabb => vr_tab_hist_cob(vr_indice_hist_cob).nrdctabb) LOOP

        IF  rw_crapafi.vlafitot > 0  THEN
          -- Obter coperativa de destino
          OPEN cr_crapcop (pr_cdcooper => rw_crapafi.cdcopdst);

          FETCH cr_crapcop INTO rw_crapcop_2;

          CLOSE cr_crapcop;

          -- Cobranca com registro
          IF  vr_tab_hist_cob(vr_indice_hist_cob).flgregis = 1  THEN
            vr_linhadet := trim(vr_cdestrut)||
                           trim(vr_dtmvtolt_yymmdd)||','||
                           trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                           '1839,'||
                           '1257,'||
                           trim(to_char(rw_crapafi.vlafitot, '99999999999990.00'))||','||
                           '5210,'||
                           '"(crps249) VALORES A RECEBER ' || rw_crapcop_2.nmrescop ||' - ('||to_char(rw_crapafi.cdhistor)||') TARIFA COBRANCA C/REGISTRO."';
          ELSE
            -- debito de tarifa - cobranca sem registro
            vr_linhadet := trim(vr_cdestrut)||
                           trim(vr_dtmvtolt_yymmdd)||','||
                           trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                           '1839,'||
                           '1172,'||
                           trim(to_char(rw_crapafi.vlafitot, '99999999999990.00'))||','||
                           '5210,'||
                           '"(crps249) VALORES A RECEBER '|| rw_crapcop_2.nmrescop  ||
                           ' - ('||to_char(rw_crapafi.cdhistor)||')'||
                           ' - TARIFA COBRANCA S/REGISTRO."';
          END IF;
          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        END IF;

      END LOOP;
      vr_indice_hist_cob := vr_tab_hist_cob.NEXT(vr_indice_hist_cob);

    END LOOP;
  END IF;
  --
  if pr_cdcooper = 16  or
     pr_cdcooper = 1  then

    vr_cdhistor := 0;
    vr_vlafideb := 0;

    vr_tab_hist_cob.delete;
    vr_tab_agencia.delete;

    -- Debito de Tarifa - Cobranca com e sem Registro
    FOR rw_histori IN cr_histori (pr_cdcooper => pr_cdcooper) LOOP

      IF  rw_histori.dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN

        vr_indice_hist_cob := trim(to_char(rw_histori.cdhistor,'00000')) || trim(to_char(rw_histori.nrdctabb,'000000000000')) || trim(to_char(rw_histori.flgregis));

        IF  NOT vr_tab_hist_cob.EXISTS(vr_indice_hist_cob)  THEN
          vr_tab_hist_cob(vr_indice_hist_cob).cdhistor := rw_histori.cdhistor;
          vr_tab_hist_cob(vr_indice_hist_cob).nrdctabb := rw_histori.nrdctabb;
          vr_tab_hist_cob(vr_indice_hist_cob).flgregis := rw_histori.flgregis;
        END IF;

      END IF;

    END LOOP;

    -- Percorrer a tabela com os debitos de tarifa de cobranca
    vr_indice_hist_cob := vr_tab_hist_cob.FIRST;
    vr_tab_agencia.delete;

    LOOP

      EXIT WHEN vr_indice_hist_cob IS NULL;

      -- Debito de Tarifa - com e sem registro
      FOR rw_crapafi IN cr_crapafi2 (pr_cdcooper => pr_cdcooper,
                                     pr_dtmvtolt => vr_dtmvtolt,
                                     pr_cdhistor => vr_tab_hist_cob(vr_indice_hist_cob).cdhistor,
                                     pr_nrdctabb => vr_tab_hist_cob(vr_indice_hist_cob).nrdctabb) LOOP

        -- acumular os valores por historico
        vr_vlafideb := vr_vlafideb + rw_crapafi.vllanmto;

        -- acuuula por PA
        pc_cria_agencia_pltable(rw_crapafi.cdagenci,NULL);
        -- Incluir nome do módulo logado
        gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
        vr_tab_agencia(rw_crapafi.cdagenci).vr_vltarpac := vr_tab_agencia(rw_crapafi.cdagenci).vr_vltarpac + rw_crapafi.vllanmto;

        -- Se tem valor e for o ultimo do historico
        IF  rw_crapafi.qtdreg = rw_crapafi.nrseqreg  THEN
          IF  vr_vlafideb > 0  THEN
            -- Obter coperativa de destino
            OPEN cr_crapcop (pr_cdcooper => rw_crapafi.cdcopdst);

            FETCH cr_crapcop INTO rw_crapcop_2;

            CLOSE cr_crapcop;

            -- Cobranca com registro
            IF  vr_tab_hist_cob(vr_indice_hist_cob).flgregis = 1 THEN
               vr_tipocob := '(' || vr_tab_hist_cob(vr_indice_hist_cob).cdhistor || ') - TARIFA COBRANCA C/REGISTRO';
            ELSE
              -- Cobranca sem registro
               vr_tipocob := '(' || vr_tab_hist_cob(vr_indice_hist_cob).cdhistor || ') - TARIFA COBRANCA S/REGISTRO';
            END IF;

            -- Montar linha
            vr_linhadet := trim(vr_cdestrut) ||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       '8309,'||
                       '4990,'||
                       trim(to_char(vr_vlafideb, '99999999999990.00'))||','||
                       '5210,'||
                       '"(crps249) VALORES A REPASSAR ' || rw_crapcop_2.nmrescop  || ' - '||vr_tipocob||'."';

            gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

            vr_indice_agencia := vr_tab_agencia.first;
            while vr_indice_agencia <= 998 loop
              if vr_tab_agencia(vr_indice_agencia).vr_vltarpac > 0 then
                vr_linhadet := to_char(vr_indice_agencia, 'fm000')||','||
                               trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_vltarpac, '999999990.00'));
                gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
              end if;
              vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
            end loop;

            vr_vlafideb := 0;
          END IF;
          vr_tab_agencia.delete;
        END IF;

      END LOOP;

      FOR rw_crapafi4 IN cr_crapafi4(pr_cdcooper => pr_cdcooper,
                                     pr_dtmvtolt => vr_dtmvtolt,
                                     pr_cdhistor => vr_tab_hist_cob(vr_indice_hist_cob).cdhistor,
                                     pr_nrdctabb => vr_tab_hist_cob(vr_indice_hist_cob).nrdctabb) LOOP
        
        IF rw_crapafi4.inpessoa = 1 then

           IF vr_tab_vlr_age_fis.EXISTS(rw_crapafi4.cdagenci) THEN
             -- Soma os valores por agencia de pessoa fisica
             vr_tab_vlr_age_fis(rw_crapafi4.cdagenci) := vr_tab_vlr_age_fis(rw_crapafi4.cdagenci) + rw_crapafi4.vllanmto;
           
           ELSE
           -- Inicializa o array com o valor inicial de pessoa fisica
             vr_tab_vlr_age_fis(rw_crapafi4.cdagenci) := rw_crapafi4.vllanmto;
           END IF;
           
        ELSE
          IF vr_tab_vlr_age_jur.EXISTS(rw_crapafi4.cdagenci) THEN
             -- Soma os valores por agencia de pessoa jurídica
             vr_tab_vlr_age_jur(rw_crapafi4.cdagenci) := vr_tab_vlr_age_jur(rw_crapafi4.cdagenci) + rw_crapafi4.vllanmto;
           
           ELSE
           -- Inicializa o array com o valor inicial de pessoa fisica
             vr_tab_vlr_age_jur(rw_crapafi4.cdagenci) := rw_crapafi4.vllanmto;
           END IF;

        END IF;
         
        --Totalizar valores por tipo de pessoa
        IF vr_tab_vlr_descbr_pes.EXISTS(rw_crapafi4.inpessoa) THEN
          -- Soma os valores por tipo de pessoa
          vr_tab_vlr_descbr_pes(rw_crapafi4.inpessoa) := vr_tab_vlr_descbr_pes(rw_crapafi4.inpessoa) + rw_crapafi4.vllanmto;
        ELSE
          -- Inicializa o array com o valor inicial de cada tipo de pessoa
          vr_tab_vlr_descbr_pes(rw_crapafi4.inpessoa) := rw_crapafi4.vllanmto;
        END IF;
      END LOOP;


      vr_indice_hist_cob := vr_tab_hist_cob.NEXT(vr_indice_hist_cob);

    END LOOP;

  end if;

  -- IPTU ....................................................................
  vr_cdestrut := '51';
  -- Anterior -- 130
  -- Prefeitura Municipal Blumenau
  open cr_crapthi(pr_cdcooper,
                  373,
                  'AYLLOS');
    fetch cr_crapthi into rw_crapthi;
    if cr_crapthi%notfound then
      close cr_crapthi;
      vr_cdcritic := 1041;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' para histórico 373 - crapthi';
      raise vr_exc_saida;
    end if;
  close cr_crapthi;
  --
  vr_vltarifa := rw_crapthi.vltarifa;
  --
  open cr_craphis2 (pr_cdcooper,
                    373);
    fetch cr_craphis2 into rw_craphis2;
    if cr_craphis2%notfound then
      close cr_craphis2;
      vr_cdcritic := 526;
      vr_dscritic := '373 - '||gene0001.fn_busca_critica(vr_cdcritic);
      raise vr_exc_saida;
    end if;
  close cr_craphis2;
  --
  vr_tab_agencia.delete;
  pc_cria_agencia_pltable(999,NULL);
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
  for rw_craptit2 in cr_craptit2 (pr_cdcooper,
                                  vr_dtmvtolt) loop
    pc_cria_agencia_pltable(rw_craptit2.cdagenci,NULL);
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    vr_vltitulo := rw_craptit2.vldpagto;
    vr_tab_agencia(rw_craptit2.cdagenci).vr_qttottrf := rw_craptit2.qttottrf;
    vr_tab_agencia(999).vr_qttottrf := vr_tab_agencia(999).vr_qttottrf + rw_craptit2.qttottrf;
    --
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   trim(to_char(vr_tab_agencia2(rw_craptit2.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                   trim(to_char(rw_craphis2.nrctacrd))||','||
                   trim(to_char(vr_vltitulo, '99999999999990.00'))||','||
                   '5210,'||
                   '"(crps249) IPTU."';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_linhadet := '999,'||trim(to_char(vr_vltitulo, '999999990.00'));
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
  end loop;
  -- Cria registro de total de tarifa de iptu
  if nvl(vr_tab_agencia(999).vr_qttottrf, 0) > 0 then
    vr_linhadet := '55'||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   trim(to_char(rw_craphis2.nrctatrd))||','||
                   trim(to_char(rw_craphis2.nrctatrc))||','||
                   trim(to_char(vr_tab_agencia(999).vr_qttottrf, '99999999999990.00'))||','||
                   '5210,'||
                   '"RECEBIMENTO DE IPTU - LOTE 21 (tarifa)"';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    -- Cria lançamentos de tarifa de iptu por pac
    vr_indice_agencia := vr_tab_agencia.first;
    while vr_indice_agencia <= 998 loop
      if vr_tab_agencia2(vr_indice_agencia).vr_cdccuage > 0 and
         vr_tab_agencia(vr_indice_agencia).vr_qttottrf > 0 then
        vr_linhadet := to_char(vr_tab_agencia2(vr_indice_agencia).vr_cdccuage, 'fm000')||','||
                       trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_qttarpac * vr_vltarifa, '999999990.00'));
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
      vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
    end loop;
  end if;
  -- COBAN ...................................................................
  vr_tab_agencia.delete;
  vr_vltitulo := 0;
  vr_cdestrut := '51';
  --
  open cr_crapthi(pr_cdcooper,
                  750,
                  'AYLLOS');
    fetch cr_crapthi into rw_crapthi;
    if cr_crapthi%notfound then
      close cr_crapthi;
      vr_cdcritic := 1041;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' para histórico 750 - crapthi';
      raise vr_exc_saida;
    end if;
  close cr_crapthi;
  --
  open cr_craphis2 (pr_cdcooper,
                    750);
    fetch cr_craphis2 into rw_craphis2;
    if cr_craphis2%notfound then
      close cr_craphis2;
      vr_cdcritic := 526;
      vr_dscritic := '750 - '||gene0001.fn_busca_critica(vr_cdcritic);
      raise vr_exc_saida;
    end if;
  close cr_craphis2;
  --
  pc_cria_agencia_pltable(999,NULL);
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
  for rw_crapcbb in cr_crapcbb (pr_cdcooper,
                                vr_dtmvtolt) loop
    pc_cria_agencia_pltable(rw_crapcbb.cdagenci,NULL);
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    vr_vltitulo := rw_crapcbb.valorpag;
    vr_tab_agencia(rw_crapcbb.cdagenci).vr_qttottrf := rw_crapcbb.qttottrf;
    vr_tab_agencia(999).vr_qttottrf := vr_tab_agencia(999).vr_qttottrf + rw_crapcbb.qttottrf;
    --
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   trim(to_char(vr_tab_agencia2(rw_crapcbb.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                   trim(to_char(rw_craphis2.nrctacrd))||','||
                   trim(to_char(vr_vltitulo, '99999999999990.00'))||','||
                   trim(to_char(rw_craphis2.cdhstctb,'0000'))||','||
                   '"(crps249) COBAN."';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_linhadet := to_char(rw_crapcbb.cdagenci, 'fm000')||','||
                   trim(to_char(vr_vltitulo, '999999990.00'));
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  end loop;
  -- Cria registro de total de tarifa de coban
  if nvl(vr_tab_agencia(999).vr_qttottrf, 0) > 0 then
    vr_linhadet := '55'||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   trim(to_char(rw_craphis2.nrctatrd))||','||
                   trim(to_char(rw_craphis2.nrctatrc))||','||
                   trim(to_char(vr_tab_agencia(999).vr_qttottrf * rw_crapthi.vltarifa, '999999990.00'))||','||
                   trim(to_char(rw_craphis2.cdhstctb,'0000'))||','||
                   '"COBAN (tarifa)"';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    -- Cria lançamentos de tarifa de coban por pac
    vr_indice_agencia := vr_tab_agencia.first;
    while vr_indice_agencia <= 998 loop
      if vr_tab_agencia2(vr_indice_agencia).vr_cdccuage > 0 and
         vr_tab_agencia(vr_indice_agencia).vr_qttottrf > 0 then
        vr_linhadet := to_char(vr_tab_agencia2(vr_indice_agencia).vr_cdccuage, 'fm000')||','||
                       trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_qttottrf * rw_crapthi.vltarifa, '999999990.00'));
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
      vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
    end loop;
  end if;
  -- COBAN  - RECEBIMENTO INSS................................................
  vr_tab_agencia.delete;
  vr_vltitulo := 0;
  vr_cdestrut := '51';
  --
  open cr_crapthi(pr_cdcooper,
                  459,
                  'AYLLOS');
    fetch cr_crapthi into rw_crapthi;
    if cr_crapthi%notfound then
      close cr_crapthi;
      vr_cdcritic := 1041;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' para histórico 459 - crapthi';
      raise vr_exc_saida;
    end if;
  close cr_crapthi;
  --
  --
  open cr_craphis2 (pr_cdcooper,
                    459);
    fetch cr_craphis2 into rw_craphis2;
    if cr_craphis2%notfound then
      close cr_craphis2;
      vr_cdcritic := 526;
      vr_dscritic := '459 - '||gene0001.fn_busca_critica(vr_cdcritic);
      raise vr_exc_saida;
    end if;
  close cr_craphis2;
  --
  pc_cria_agencia_pltable(999,NULL);
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
  for rw_crapcbb in cr_crapcbb2 (pr_cdcooper,
                                 vr_dtmvtolt) loop
    pc_cria_agencia_pltable(rw_crapcbb.cdagenci,NULL);
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    vr_vltitulo := rw_crapcbb.valorpag;
    vr_tab_agencia(rw_crapcbb.cdagenci).vr_qttottrf := rw_crapcbb.qttottrf;
    vr_tab_agencia(999).vr_qttottrf := vr_tab_agencia(999).vr_qttottrf + rw_crapcbb.qttottrf;
    --
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   trim(to_char(rw_craphis2.nrctadeb))||','||
                   trim(to_char(vr_tab_agencia2(rw_crapcbb.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                   trim(to_char(vr_vltitulo, '99999999999990.00'))||','||
                   trim(to_char(rw_craphis2.cdhstctb,'0000'))||','||
                   '"(crps249) INSS COBAN."';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_linhadet := to_char(rw_crapcbb.cdagenci, 'fm000')||','||
                   trim(to_char(vr_vltitulo, '999999990.00'));
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  end loop;
  -- Cria registro de total de tarifa de coban
  if nvl(vr_tab_agencia(999).vr_qttottrf, 0) > 0 then
    vr_linhadet := '55'||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   trim(to_char(rw_craphis2.nrctatrd))||','||
                   trim(to_char(rw_craphis2.nrctatrc))||','||
                   trim(to_char(vr_tab_agencia(999).vr_qttottrf * rw_crapthi.vltarifa, '999999990.00'))||','||
                   trim(to_char(rw_craphis2.cdhstctb,'0000'))||','||
                   '"COBAN INSS (tarifa)"';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    -- Cria lançamentos de tarifa de coban por pac
    vr_indice_agencia := vr_tab_agencia.first;
    while vr_indice_agencia <= 998 loop
      if vr_tab_agencia2(vr_indice_agencia).vr_cdccuage > 0 and
         vr_tab_agencia(vr_indice_agencia).vr_qttottrf > 0 then
        vr_linhadet := to_char(vr_tab_agencia2(vr_indice_agencia).vr_cdccuage, 'fm000')||','||
                       trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_qttottrf * rw_crapthi.vltarifa, '999999990.00'));
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
      vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
    end loop;
  end if;
  -- BANCOOB - RECEBIMENTO INSS................................................
  vr_vlpioneiro := 0;
  vr_vlcartao := 0;
  vr_vlrecibo := 0;
  vr_vloutros := 0;
  vr_tab_agencia.delete;
  -- Valores das taxas a serem recebidas
  open cr_craptab (pr_cdcooper,
                   0, --cdempres
                   'GENERI', --tptabela
                   'TARINSBCOB', --cdacesso
                   0); --tpregist
    fetch cr_craptab into rw_craptab.dstextab;
    if cr_craptab%found then
      vr_vlpioneiro := to_number(substr(rw_craptab.dstextab, 1, 9));
      vr_vlcartao := to_number(substr(rw_craptab.dstextab, 11, 9));
      vr_vlrecibo := to_number(substr(rw_craptab.dstextab, 31, 9));
      vr_vloutros := to_number(substr(rw_craptab.dstextab, 21, 9));
    end if;
  close cr_craptab;
  --
  open cr_craphis2 (pr_cdcooper,
                    580); -- SAQUE DO BENEFICIO DO INSS
    fetch cr_craphis2 into rw_craphis2;
    if cr_craphis2%notfound then
      close cr_craphis2;
      vr_cdcritic := 526;
      vr_dscritic := '580 - '||gene0001.fn_busca_critica(vr_cdcritic);
      RAISE vr_exc_saida;
    end if;
  close cr_craphis2;
  --
  pc_cria_agencia_pltable(999,NULL);
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
  for rw_crapage in cr_crapage loop
    pc_cria_agencia_pltable(rw_crapage.cdagenci,NULL);
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    -- Verifica se eh PAC pioneiro
    if rw_crapage.tpagenci = 1   then
      vr_flgpione := true;
    else
      vr_flgpione := false;
    end if;
    -- Total de pagamentos do PAC
    vr_vltitulo := 0;
    -- Creditos pagos
    for rw_craplpi in cr_craplpi (pr_cdcooper,
                                  vr_dtmvtolt,
                                  rw_crapage.cdagenci) loop
      vr_vltitulo := vr_vltitulo + rw_craplpi.vllanmto;
      vr_tab_agencia(rw_crapage.cdagenci).vr_qttottrf := vr_tab_agencia(rw_crapage.cdagenci).vr_qttottrf + 1;
      vr_tab_agencia(999).vr_qttottrf := vr_tab_agencia(999).vr_qttottrf + 1;
      --
      if vr_flgpione then
        -- PAC pioneiro
        vr_tab_agencia(rw_crapage.cdagenci).vr_vltarbcb := vr_tab_agencia(rw_crapage.cdagenci).vr_vltarbcb + vr_vlpioneiro;
        vr_tab_agencia(999).vr_vltarbcb := vr_tab_agencia(999).vr_vltarbcb + vr_vlpioneiro;
      elsif rw_craplpi.tppagben = 1 then
        -- Pago com Cartao
        vr_tab_agencia(rw_crapage.cdagenci).vr_vltarbcb := vr_tab_agencia(rw_crapage.cdagenci).vr_vltarbcb + vr_vlcartao;
        vr_tab_agencia(999).vr_vltarbcb := vr_tab_agencia(999).vr_vltarbcb + vr_vlcartao;
      elsif rw_craplpi.tppagben = 2 then
        -- Pago com Recibo
        vr_tab_agencia(rw_crapage.cdagenci).vr_vltarbcb := vr_tab_agencia(rw_crapage.cdagenci).vr_vltarbcb + vr_vlrecibo;
        vr_tab_agencia(999).vr_vltarbcb := vr_tab_agencia(999).vr_vltarbcb + vr_vlcartao;
      end if;
    end loop;
    -- As tarifas de creditos em conta corrente sao contabilizadas aqui por
    -- causa da diferenciacao no caso de PAC PIONEIRO, por isso o campo
    -- craphis.vltarifa nao possui o valor da tarifa de credito em conta
    for rw_craplcm in cr_craplcm (pr_cdcooper,
                                  vr_dtmvtolt,
                                  rw_crapage.cdagenci) loop
      vr_tab_agencia(rw_crapage.cdagenci).vr_qttottrf := vr_tab_agencia(rw_crapage.cdagenci).vr_qttottrf + 1;
      vr_tab_agencia(999).vr_qttottrf := vr_tab_agencia(999).vr_qttottrf + 1;
      --
      if vr_flgpione then
        -- PAC pioneiro
        vr_tab_agencia(rw_crapage.cdagenci).vr_vltarbcb := vr_tab_agencia(rw_crapage.cdagenci).vr_vltarbcb + vr_vlpioneiro;
        vr_tab_agencia(999).vr_vltarbcb := vr_tab_agencia(999).vr_vltarbcb + vr_vlpioneiro;
      else
        -- Outros
        vr_tab_agencia(rw_crapage.cdagenci).vr_vltarbcb := vr_tab_agencia(rw_crapage.cdagenci).vr_vltarbcb + vr_vloutros;
        vr_tab_agencia(999).vr_vltarbcb := vr_tab_agencia(999).vr_vltarbcb + vr_vloutros;
      end if;
    end loop;
    -- Se o PAC teve lancamentos
    if vr_vltitulo > 0 then
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctadeb))||','||
                     trim(to_char(vr_tab_agencia2(rw_crapage.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                     trim(to_char(vr_vltitulo, '99999999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb,'0000'))||','||
                     '"(crps249)INSS BANCOOB."';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := to_char(rw_crapage.cdagenci, 'fm000')||','||
                     trim(to_char(vr_vltitulo, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
  end loop; -- Fim do FOR EACH crapage
  -- Cria registro de total de tarifa do bancoob
  if nvl(vr_tab_agencia(999).vr_qttottrf, 0) > 0 and
     nvl(vr_tab_agencia(999).vr_vltarbcb, 0) > 0 then
    vr_linhadet := '55'||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   trim(to_char(rw_craphis2.nrctatrd))||','||
                   trim(to_char(rw_craphis2.nrctatrc))||','||
                   trim(to_char(vr_tab_agencia(999).vr_vltarbcb, '999999990.00'))||','||
                   trim(to_char(rw_craphis2.cdhstctb,'0000'))||','||
                   '"INSS BANCOOB (tarifa)"';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    -- Cria lancamentos de tarifa de INSS BANCOOB por pac
    vr_indice_agencia := vr_tab_agencia.first;
    while vr_indice_agencia <= 998 loop
      if vr_tab_agencia2(vr_indice_agencia).vr_cdccuage > 0 and
         vr_tab_agencia(vr_indice_agencia).vr_qttottrf > 0 and
         vr_tab_agencia(vr_indice_agencia).vr_vltarbcb > 0 then
        vr_linhadet := to_char(vr_tab_agencia2(vr_indice_agencia).vr_cdccuage, 'fm000')||','||
                       trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_vltarbcb, '999999990.00'));
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
      vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
    end loop;
  end if;


  -- PAGAMENTO GUIAS PREVIDENCIA .............................................
  vr_tab_agencia.delete;
  vr_vltitulo := 0;
  vr_cdestrut := '51';
  -- Verifica se a cooperativa paga as guias GPS para o BB ou BANCOOB
  IF rw_crapcop.cdcrdins <> 0 THEN --SICREDI
     vr_cdhistor := 1414;
  ELSE
  if rw_crapcop.cdcrdarr = 0 then
    vr_cdhistor := 458;
  else
    vr_cdhistor := 582;
  end if;
  END IF;     
  --
  if vr_cdhistor = 582 then
    open cr_crapthi(pr_cdcooper,
                    vr_cdhistor,
                    'CAIXA');
      fetch cr_crapthi into rw_crapthi;
      if cr_crapthi%notfound then
        close cr_crapthi;
        vr_cdcritic := 1041;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' para histórico '||vr_cdhistor||' - crapthi';
        raise vr_exc_saida;
      end if;
    close cr_crapthi;
  end if;
  --
  if vr_cdhistor = 1414 then
    open cr_crapthi(pr_cdcooper,
                    vr_cdhistor,
                    'AYLLOS');
      fetch cr_crapthi into rw_crapthi;
      if cr_crapthi%notfound then
        close cr_crapthi;
        vr_cdcritic := 1041;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' para histórico '||vr_cdhistor||' - crapthi';
        raise vr_exc_saida;
      end if;
    close cr_crapthi;
  end if;
  --
  open cr_craphis2 (pr_cdcooper,
                    vr_cdhistor);
    fetch cr_craphis2 into rw_craphis2;
    if cr_craphis2%notfound then
      close cr_craphis2;
      vr_cdcritic := 526;
      vr_dscritic := vr_cdhistor||' - '||gene0001.fn_busca_critica(vr_cdcritic);
      raise vr_exc_saida;
    end if;
  close cr_craphis2;
  --

  for rw_gps_gerencial in cr_gps_gerencial (pr_cdcooper,
                                vr_dtmvtolt) loop
    --
    vr_vltitulo := rw_gps_gerencial.vlrtotal;
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   trim(to_char(vr_tab_agencia2(rw_gps_gerencial.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                   trim(to_char(rw_craphis2.nrctacrd))||','||
                   trim(to_char(vr_vltitulo, '99999999999990.00'))||','||
                   trim(to_char(rw_craphis2.cdhstctb,'0000'))||','||
                   '"(crps249) GPS.  "';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_linhadet := to_char(rw_gps_gerencial.cdagenci, 'fm000')||','||
                   trim(to_char(vr_vltitulo, '999999990.00'));
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  end loop;
  -- Despesa Sicredi - GPS (Apenas quando foi via 1414)
  if vr_cdhistor = 1414 THEN

    for rw_gps_despesas in cr_gps_despesas (pr_cdcooper,
                                            vr_dtmvtolt) loop
      --
      pc_cria_agencia_pltable(rw_gps_despesas.cdagenci,NULL);
      -- Incluir nome do módulo logado
      gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

      vr_tab_agencia(rw_gps_despesas.cdagenci).vr_qttottrf := rw_gps_despesas.qttottrf;
      vr_tab_agencia(rw_gps_despesas.cdagenci).vr_vltottar := rw_crapthi.vltarifa * rw_gps_despesas.qttottrf;

      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctatrd))||','||
                     trim(to_char(rw_craphis2.nrctatrc))||','||
                     trim(to_char(vr_tab_agencia(rw_gps_despesas.cdagenci).vr_vltottar, '99999999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '"('||trim(to_char(rw_craphis2.cdhistor,'0000'))||
                     ') CONTABILIZACAO DESPESA SICREDI - GPS"';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

      vr_linhadet := to_char(rw_gps_despesas.cdagenci, 'fm000')||','||trim(to_char(vr_tab_agencia(rw_gps_despesas.cdagenci).vr_vltottar, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    END LOOP;
  END IF;


  --  Cria os lancamentos da conta investimento  -  Edson
  for rw_craplci in cr_craplci (pr_cdcooper,
                                vr_dtmvtolt) loop
    open cr_craphis2 (pr_cdcooper,
                      rw_craplci.cdhistor);
      fetch cr_craphis2 into rw_craphis2;
      if cr_craphis2%notfound then
        close cr_craphis2;
        vr_cdcritic := 526;
        vr_dscritic := rw_craplci.cdhistor||' - '||gene0001.fn_busca_critica(vr_cdcritic);
        raise vr_exc_saida;
      end if;
    close cr_craphis2;
    --
    if rw_craplci.cdhistor = 487 then
      if rw_craphis2.tpctbcxa = 2 then -- POR CAIXA DEBITO
        vr_linhadet := '50'||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       trim(to_char(vr_tab_agencia2(rw_craplci.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                       trim(to_char(rw_craphis2.nrctacrd))||','||
                       trim(to_char(rw_craplci.vllanmto, '99999999999990.00'))||','||
                       trim(to_char(rw_craphis2.cdhstctb))||','||
                       '"CONTA '||trim(rw_craplci.nrdconta)||'"';
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := to_char(rw_craplci.cdagenci, 'fm000')||','||trim(to_char(rw_craplci.vllanmto, '999999990.00'));
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        if rw_craphis2.ingercre = 2 then
          vr_linhadet := '999,'||trim(to_char(rw_craplci.vllanmto, '999999990.00'));
          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
      elsif rw_craphis2.tpctbcxa = 3 then -- POR CAIXA CREDITO
        vr_linhadet := '50'||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       trim(to_char(rw_craphis2.nrctadeb))||','||
                       trim(to_char(vr_tab_agencia2(rw_craplci.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                       trim(to_char(rw_craplci.vllanmto, '99999999999990.00'))||','||
                       trim(to_char(rw_craphis2.cdhstctb))||','||
                       '"CONTA '||trim(rw_craplci.nrdconta)||'"';
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := to_char(rw_craplci.cdagenci, 'fm000')||','||trim(to_char(rw_craplci.vllanmto, '999999990.00'));
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        if rw_craphis2.ingerdeb = 2 then
          vr_linhadet := '999,'||trim(to_char(rw_craplci.vllanmto, '999999990.00'));
          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
      end if;
    else
      vr_linhadet := '50'||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctadeb))||','||
                     trim(to_char(rw_craphis2.nrctacrd))||','||
                     trim(to_char(rw_craplci.vllanmto, '99999999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '"CONTA '||trim(rw_craplci.nrdconta)||'"';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      if rw_craphis2.ingerdeb = 2 or
         rw_craphis2.ingercre = 2 then
        vr_linhadet := '999,'||trim(to_char(rw_craplci.vllanmto, '999999990.00'));
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
    end if;
  end loop;
  -- Cria os lancamentos do boletim de caixa  -  Edson
  for rw_craplcx in cr_craplcx (pr_cdcooper,
                                vr_dtmvtolt) loop
    open cr_craphis2 (pr_cdcooper,
                      rw_craplcx.cdhistor);
      fetch cr_craphis2 into rw_craphis2;
      if cr_craphis2%notfound then
        close cr_craphis2;
        vr_cdcritic := 526;
        vr_dscritic := rw_craplcx.cdhistor||' - '||gene0001.fn_busca_critica(vr_cdcritic);
        raise vr_exc_saida;
      end if;
    close cr_craphis2;
    --
    if rw_craphis2.tpctbcxa = 2 then -- POR CAIXA DEBITO
      vr_linhadet := '50'||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(vr_tab_agencia2(rw_craplcx.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                     trim(to_char(rw_craphis2.nrctacrd))||','||
                     trim(to_char(rw_craplcx.vldocmto, '99999999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '"CX. '||trim(to_char(rw_craplcx.nrdcaixa))||
                     ' ('||trim(to_char(rw_craplcx.cdhistor, '0000'))||
                     ') '||trim(rw_craphis2.dshistor)||
                     ' '||trim(substr(rw_craplcx.dsdcompl,1,79))||'"';
      if length(vr_linhadet) > 150 then
        vr_linhadet := substr(vr_linhadet, 1, 149)||'"';
      end if;
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      vr_linhadet := to_char(rw_craplcx.cdagenci, 'fm000')||','||trim(to_char(rw_craplcx.vldocmto, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      if rw_craphis2.ingercre = 2 then
        vr_linhadet := '999,'||trim(to_char(rw_craplcx.vldocmto, '999999990.00'));
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      elsif rw_craphis2.ingercre = 3 then
        vr_linhadet := to_char(rw_craplcx.cdagenci, 'fm000')||','||trim(to_char(rw_craplcx.vldocmto, '999999990.00'));
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
    elsif rw_craphis2.tpctbcxa = 3 then -- POR CAIXA CREDITO
      vr_linhadet := '50'||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctadeb))||','||
                     trim(to_char(vr_tab_agencia2(rw_craplcx.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                     trim(to_char(rw_craplcx.vldocmto, '99999999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '"CX. '||trim(to_char(rw_craplcx.nrdcaixa))||
                     ' ('||trim(to_char(rw_craplcx.cdhistor, '0000'))||
                     ') '||trim(rw_craphis2.dshistor)||
                     ' '||trim(substr(rw_craplcx.dsdcompl,1,79))||'"';
      if length(vr_linhadet) > 150 then
        vr_linhadet := substr(vr_linhadet, 1, 149)||'"';
      end if;
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      if rw_craphis2.ingerdeb = 2 then
        vr_linhadet := '999,'||trim(to_char(rw_craplcx.vldocmto, '999999990.00'));
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      elsif rw_craphis2.ingercre = 3 then
        vr_linhadet := to_char(rw_craplcx.cdagenci, 'fm000')||','||trim(to_char(rw_craplcx.vldocmto, '999999990.00'));
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
      --
      vr_linhadet := to_char(rw_craplcx.cdagenci, 'fm000')||','||trim(to_char(rw_craplcx.vldocmto, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
  end loop;
  -- Lancamentos dos cashes dispensers  -  Edson
  for rw_crapstf in cr_crapstf (pr_cdcooper,
                                vr_dtmvtolt) loop
    open cr_craptfn (pr_cdcooper,
                     rw_crapstf.nrterfin);
      fetch cr_craptfn into rw_craptfn;
    close cr_craptfn;
    -- Leitura do log de operacao do dia
    for rw_craplfn in cr_craplfn (pr_cdcooper,
                                  rw_crapstf.dtmvtolt,
                                  rw_crapstf.nrterfin) loop
      open cr_crapope (pr_cdcooper,
                       rw_craplfn.cdoperad);
        fetch cr_crapope into rw_crapope;
      close cr_crapope;
      -- Contabilizacao do SUPRIMENTO DO CASH
      if rw_craplfn.vlsuprim > 0 then
        open cr_craphis2 (pr_cdcooper,
                          705);
          fetch cr_craphis2 into rw_craphis2;
          if cr_craphis2%notfound then
            close cr_craphis2;
            vr_cdcritic := 526;
            vr_dscritic := '705 - '||gene0001.fn_busca_critica(vr_cdcritic);
            raise vr_exc_saida;
          end if;
        close cr_craphis2;
        --
        vr_linhadet := '50'||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       trim(to_char(vr_tab_agencia2(rw_craptfn.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                       trim(to_char(rw_craphis2.nrctacrd))||','||
                       trim(to_char(rw_craplfn.vlsuprim, '99999999999990.00'))||','||
                       trim(to_char(rw_craphis2.cdhstctb))||','||
                       '"CASH '||to_char(rw_craptfn.cdagenci)||
                       '/'||to_char(rw_craptfn.nrterfin)||
                       ' ('||trim(to_char(rw_craphis2.cdhistor, '0000'))||
                       ') '||trim(rw_craphis2.dshistor)||
                       ' EFETUADO POR '||rw_crapope.nmoperad||'"';
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        vr_linhadet := to_char(rw_craptfn.cdagenci, 'fm000')||','||trim(to_char(rw_craplfn.vlsuprim, '999999990.00'));
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        if rw_craphis2.ingercre = 2 then
          vr_linhadet := '999,'||trim(to_char(rw_craplfn.vlsuprim, '999999990.00'));
          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
      end if;
      -- Contabilizacao do RECOLHIMENTO DO CASH
      if rw_craplfn.vlrecolh > 0 then
        open cr_craphis2 (pr_cdcooper,
                          706);
          fetch cr_craphis2 into rw_craphis2;
          if cr_craphis2%notfound then
            close cr_craphis2;
            vr_cdcritic := 526;
            vr_dscritic := '706 - '||gene0001.fn_busca_critica(vr_cdcritic);
            raise vr_exc_saida;
          end if;
        close cr_craphis2;
        --
        vr_linhadet := '50'||
                       trim(vr_dtmvtolt_yymmdd)||','||
                       trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                       trim(to_char(rw_craphis2.nrctadeb))||','||
                       trim(to_char(vr_tab_agencia2(rw_craptfn.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                       trim(to_char(rw_craplfn.vlrecolh, '99999999999990.00'))||','||
                       trim(to_char(rw_craphis2.cdhstctb))||','||
                       '"CASH '||to_char(rw_craptfn.cdagenci)||
                       '/'||to_char(rw_craptfn.nrterfin)||
                       ' ('||trim(to_char(rw_craphis2.cdhistor, '0000'))||
                       ') '||trim(rw_craphis2.dshistor)||
                       ' EFETUADO POR '||rw_crapope.nmoperad||'"';
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        --
        if rw_craphis2.ingerdeb = 2 then
          vr_linhadet := '999,'||trim(to_char(rw_craplfn.vlrecolh, '999999990.00'));
          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
        --
        vr_linhadet := to_char(rw_craptfn.cdagenci, 'fm000')||','||trim(to_char(rw_craplfn.vlrecolh, '999999990.00'));
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
    end loop;
  end loop;
  -- Contabilizacao da COMP. ELETRONICA ..... (Edson 11/04/2001)..............
  for rw_craplot in cr_craplot (pr_cdcooper,
                                vr_dtmvtolt) loop
    if rw_craplot.vlcompel <> 0 then
      open cr_crapage2(pr_cdcooper,
                       rw_craplot.cdagenci);
        fetch cr_crapage2 into rw_crapage2;
        if cr_crapage2%notfound then
          close cr_crapage2;
          vr_cdcritic := 962;
          raise vr_exc_saida;
        else
          if rw_crapage2.cdbanchq = 1 then   -- Banco do Brasil
            vr_cdhistor := 731;
          elsif rw_crapage2.cdbanchq = 756 then -- Bancoob
            vr_cdhistor := 547;
          elsif rw_crapage2.cdbanchq = rw_crapcop.cdbcoctl then
            vr_cdhistor := 466;
          end if;
          --
          open cr_craphis2 (pr_cdcooper,
                            vr_cdhistor);
            fetch cr_craphis2 into rw_craphis2;
            if cr_craphis2%notfound then
              close cr_craphis2;
              vr_cdcritic := 526;
              vr_dscritic := vr_cdhistor||' - '||gene0001.fn_busca_critica(vr_cdcritic);
              raise vr_exc_saida;
            end if;
          close cr_craphis2;
        end if;
      close cr_crapage2;
      --
      vr_linhadet := '50'||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctadeb))||','||
                     trim(to_char(vr_tab_agencia2(rw_craplot.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                     trim(to_char(rw_craplot.vlcompel, '99999999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '"CX. '||to_char(rw_craplot.nrdcaixa)||
                     ' ('||trim(to_char(rw_craphis2.cdhistor, '0000'))||
                     ') '||trim(rw_craphis2.dshistor)||
                     ' - '||trim(to_char(rw_craplot.qtcompel, '999G990'))||'"';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      --
      if rw_craphis2.ingerdeb = 2 then
        vr_linhadet := '999,'||trim(to_char(rw_craplot.vlcompel, '999999990.00'));
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      end if;
      --
      vr_linhadet := to_char(rw_craplot.cdagenci, 'fm000')||','||trim(to_char(rw_craplot.vlcompel, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
  end loop;
  -- *****  Incluir lancamento de tarifa para o historico 547  *****
  vr_tab_agencia.delete;
  pc_cria_agencia_pltable(999,NULL);
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
  for rw_craplot in cr_craplot (pr_cdcooper,
                                vr_dtmvtolt) loop
    if rw_craplot.qtcompel > 0 then
      open cr_crapage2(pr_cdcooper,
                       rw_craplot.cdagenci);
        fetch cr_crapage2 into rw_crapage2;
        if cr_crapage2%notfound then
          close cr_crapage2;
          vr_cdcritic := 962;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          raise vr_exc_saida;
        else
          if rw_crapage2.cdbanchq = 756 then -- Bancoob
            pc_cria_agencia_pltable(rw_craplot.cdagenci,NULL);
            -- Incluir nome do módulo logado
            gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
            vr_tab_agencia(rw_craplot.cdagenci).vr_qttarcmp := vr_tab_agencia(rw_craplot.cdagenci).vr_qttarcmp + rw_craplot.qtcompel;
            vr_tab_agencia(999).vr_qttarcmp := vr_tab_agencia(999).vr_qttarcmp + rw_craplot.qtcompel;
          end if;
          --
        end if;
      close cr_crapage2;
    end if;
  end loop;
  -- Lancamento de Tarifa  -  CHEQUE CAIXA BANCOOB ........................
  if nvl(vr_tab_agencia(999).vr_qttarcmp, 0) > 0 then

    open cr_crapthi(pr_cdcooper,
                    547,
                    'AYLLOS');
      fetch cr_crapthi into rw_crapthi;
      if cr_crapthi%notfound then
        close cr_crapthi;
        vr_cdcritic := 1041;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' para histórico 547 - crapthi';
        raise vr_exc_saida;
      end if;
    close cr_crapthi;
    --
    open cr_craphis2 (pr_cdcooper,
                      547); -- CHEQUE BANCOOB (CAPTURA ELETRONICA)
      fetch cr_craphis2 into rw_craphis2;
      if cr_craphis2%notfound then
        close cr_craphis2;
        vr_cdcritic := 526;
        vr_dscritic := '547 - '||gene0001.fn_busca_critica(vr_cdcritic);
        raise vr_exc_saida;
      end if;
    close cr_craphis2;
    --
    if rw_crapthi.vltarifa > 0 then
      vr_cdestrut := '50';
      vr_linhadet := trim(vr_cdestrut)||
                     trim(vr_dtmvtolt_yymmdd)||','||
                     trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                     trim(to_char(rw_craphis2.nrctatrd))||','||
                     trim(to_char(rw_craphis2.nrctatrc))||','||
                     trim(to_char(rw_crapthi.vltarifa, '999999990.00'))||','||
                     trim(to_char(rw_craphis2.cdhstctb))||','||
                     '"('||trim(to_char(rw_craphis2.cdhistor, '0000'))||
                     ') '||trim(rw_craphis2.dshistor)||' - '||
                     trim(to_char(vr_tab_agencia(999).vr_qttarcmp, '999g990'))||' (tarifa)"';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      -- Indice da primeira agencia
      vr_indice_agencia := vr_tab_agencia.first;
      -- Percorrer todas as agencias
      while vr_indice_agencia <= 998 loop
        if vr_tab_agencia(vr_indice_agencia).vr_qttarcmp > 0 then
          vr_linhadet := to_char(vr_indice_agencia, 'fm000')||','||
                         trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_qttarcmp * rw_crapthi.vltarifa, '999999990.00'));
          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
        vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
      end loop;
    end if;
  end if;
  -- CONTA SALARIO - Recebimento do Credito via Arquivo ......................
  vr_cdhistor := 560;
  vr_vltitulo := 0;
  vr_tab_agencia.delete;
  --
  for rw_craplcs in cr_craplcs (pr_cdcooper,
                                vr_dtmvtolt,
                                vr_cdhistor) loop
    pc_cria_agencia_pltable(rw_craplcs.cdagenci,NULL);
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    vr_tab_agencia(rw_craplcs.cdagenci).vr_vltagenc := rw_craplcs.vllanmto;
    vr_vltitulo := vr_vltitulo + rw_craplcs.vllanmto;
  end loop;
  --
  if vr_vltitulo > 0 then
    open cr_craphis2 (pr_cdcooper,
                      vr_cdhistor);
      fetch cr_craphis2 into rw_craphis2;
      if cr_craphis2%notfound then
        close cr_craphis2;
        vr_cdcritic := 526;
        vr_dscritic := vr_cdhistor||' - '||gene0001.fn_busca_critica(vr_cdcritic);
        raise vr_exc_saida;
      end if;
    close cr_craphis2;
    vr_cdestrut := '50';
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   trim(to_char(rw_craphis2.nrctadeb))||','||
                   trim(to_char(rw_craphis2.nrctacrd))||','||
                   trim(to_char(vr_vltitulo, '999999990.00'))||','||
                   trim(to_char(rw_craphis2.cdhstctb))||','||
                   '"('||vr_cdhistor||') CREDITO DA FOLHA VIA ARQUIVO - CONTA SALARIO"';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_indice_agencia := vr_tab_agencia.first;
    while vr_indice_agencia <= 998 loop
      if vr_tab_agencia(vr_indice_agencia).vr_vltagenc <> 0 then
        if rw_craphis2.ingercre = 3 or
           rw_craphis2.ingerdeb = 3 then
          vr_linhadet := to_char(vr_indice_agencia, 'fm000')||','||
                         trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_vltagenc, '999999990.00'));
          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
      end if;
      vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
    end loop;
    --
    if rw_craphis2.ingercre = 2 or
       rw_craphis2.ingerdeb = 2 then
      vr_linhadet := '999,'||
                     trim(to_char(vr_vltitulo, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
  end if;
  -- CONTA SALARIO - Recebimento do Credito via Caixa On-Line ................
  vr_cdhistor := 561;
  --
  for rw_craplcs in cr_craplcs (pr_cdcooper,
                                vr_dtmvtolt,
                                vr_cdhistor) loop
    vr_vltitulo := rw_craplcs.vllanmto;
    --
    open cr_craphis2 (pr_cdcooper,
                      vr_cdhistor);
      fetch cr_craphis2 into rw_craphis2;
      if cr_craphis2%notfound then
        close cr_craphis2;
        vr_cdcritic := 526;
        vr_dscritic := vr_cdhistor||' - '||gene0001.fn_busca_critica(vr_cdcritic);
        raise vr_exc_saida;
      end if;
    close cr_craphis2;
    vr_cdestrut := '50';
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   trim(to_char(vr_tab_agencia2(rw_craplcs.cdagenci).vr_cdcxaage, 'fm0000'))||','||
                   trim(to_char(rw_craphis2.nrctacrd))||','||
                   trim(to_char(vr_vltitulo, '999999990.00'))||','||
                   trim(to_char(rw_craphis2.cdhstctb))||','||
                   '"('||vr_cdhistor||') CREDITO DA FOLHA VIA CAIXA ONLINE - CONTA SALARIO"';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    if rw_craphis2.ingercre = 3 or
       rw_craphis2.ingerdeb = 3 then
      vr_linhadet := to_char(rw_craplcs.cdagenci, 'fm000')||','||
                     trim(to_char(vr_vltitulo, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    elsif rw_craphis2.ingercre = 2 or
          rw_craphis2.ingerdeb = 2 then
      vr_linhadet := '999,'||
                     trim(to_char(vr_vltitulo, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
  end loop;
  -- CONTA SALARIO - Rejeção da mensagem de TEC Salário na cabine SPB ......................
  vr_cdhistor := 1755;
  vr_vltitulo := 0;
  vr_tab_agencia.delete;
  --
  for rw_craplcs in cr_craplcs (pr_cdcooper,
                                vr_dtmvtolt,
                                vr_cdhistor) loop
    pc_cria_agencia_pltable(rw_craplcs.cdagenci,NULL);
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    vr_tab_agencia(rw_craplcs.cdagenci).vr_vltagenc := rw_craplcs.vllanmto;
    vr_vltitulo := vr_vltitulo + rw_craplcs.vllanmto;
  end loop;
  --
  if vr_vltitulo > 0 then
    open cr_craphis2 (pr_cdcooper,
                      vr_cdhistor);
      fetch cr_craphis2 into rw_craphis2;
      if cr_craphis2%notfound then
        close cr_craphis2;
        vr_cdcritic := 526;
        vr_dscritic := vr_cdhistor||' - '||gene0001.fn_busca_critica(vr_cdcritic);
        raise vr_exc_saida;
      end if;
    close cr_craphis2;
    vr_cdestrut := '50';
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   trim(to_char(rw_craphis2.nrctadeb))||','||
                   trim(to_char(rw_craphis2.nrctacrd))||','||
                   trim(to_char(vr_vltitulo, '999999990.00'))||','||
                   trim(to_char(rw_craphis2.cdhstctb))||','||
                   '"('||vr_cdhistor||') REJEICAO/DEVOLUCAO CREDITO DA FOLHA - CONTA SALARIO"';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_indice_agencia := vr_tab_agencia.first;
    while vr_indice_agencia <= 998 loop
      if vr_tab_agencia(vr_indice_agencia).vr_vltagenc <> 0 then
        if rw_craphis2.ingercre = 3 or
           rw_craphis2.ingerdeb = 3 then
          vr_linhadet := to_char(vr_indice_agencia, 'fm000')||','||
                         trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_vltagenc, '999999990.00'));
          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
      end if;
      vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
    end loop;
    --
    if rw_craphis2.ingercre = 2 or
       rw_craphis2.ingerdeb = 2 then
      vr_linhadet := '999,'||
                     trim(to_char(vr_vltitulo, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
  end if;
  
  -- CONTA SALARIO - Envio de TED para o BAnco do BRAsil................
  vr_cdhistor := 562;
  vr_vltitulo := 0;
  vr_tab_agencia.delete;
  --
  for rw_craplcs in cr_craplcs (pr_cdcooper,
                                vr_dtmvtolt,
                                vr_cdhistor) loop
    pc_cria_agencia_pltable(rw_craplcs.cdagenci,NULL);
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    vr_tab_agencia(rw_craplcs.cdagenci).vr_vltagenc := rw_craplcs.vllanmto;
    vr_vltitulo := vr_vltitulo + rw_craplcs.vllanmto;
  end loop;
  --
  if vr_vltitulo > 0 then
    open cr_craphis2 (pr_cdcooper,
                      vr_cdhistor);
      fetch cr_craphis2 into rw_craphis2;
      if cr_craphis2%notfound then
        close cr_craphis2;
        vr_cdcritic := 526;
        vr_dscritic := vr_cdhistor||' - '||gene0001.fn_busca_critica(vr_cdcritic);
        raise vr_exc_saida;
      end if;
    close cr_craphis2;
    vr_cdestrut := '50';
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   trim(to_char(rw_craphis2.nrctadeb))||','||
                   trim(to_char(rw_craphis2.nrctacrd))||','||
                   trim(to_char(vr_vltitulo, '999999990.00'))||','||
                   trim(to_char(rw_craphis2.cdhstctb))||','||
                   '"('||vr_cdhistor||') ENVIO DE TED - CONTA SALARIO"';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_indice_agencia := vr_tab_agencia.first;
    while vr_indice_agencia <= 998 loop
      if vr_tab_agencia(vr_indice_agencia).vr_vltagenc <> 0 then
        if rw_craphis2.ingercre = 3 or
           rw_craphis2.ingerdeb = 3 then
          vr_linhadet := to_char(vr_indice_agencia, 'fm000')||','||
                         trim(to_char(vr_tab_agencia(vr_indice_agencia).vr_vltagenc, '999999990.00'));
          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
        end if;
      end if;
      vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
    end loop;
    --
    if rw_craphis2.ingercre = 2 or
       rw_craphis2.ingerdeb = 2 then
      vr_linhadet := '999,'||
                     trim(to_char(vr_vltitulo, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
  end if;
  -- CONTA SALARIO - Envio de TED para a nossa IF  ................
  vr_cdhistor := 827;
  vr_vltitulo := 0;
  --
  for rw_craplcs2 in cr_craplcs2 (pr_cdcooper,
                                  vr_dtmvtolt,
                                  vr_cdhistor) loop
    vr_vltitulo := rw_craplcs2.vllanmto;
    --
    open cr_craphis2 (pr_cdcooper,
                      vr_cdhistor);
      fetch cr_craphis2 into rw_craphis2;
      if cr_craphis2%notfound then
        close cr_craphis2;
        vr_cdcritic := 526;
        vr_dscritic := vr_cdhistor||' - '||gene0001.fn_busca_critica(vr_cdcritic);
        raise vr_exc_saida;
      end if;
    close cr_craphis2;
    --
    vr_cdestrut := '50';
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   trim(to_char(rw_craphis2.nrctadeb))||','||
                   trim(to_char(rw_craphis2.nrctacrd))||','||
                   trim(to_char(vr_vltitulo, '999999990.00'))||','||
                   trim(to_char(rw_craphis2.cdhstctb))||','||
                   '"('||vr_cdhistor||') ENVIO DE TED - CONTA SALARIO"';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    if rw_craphis2.ingercre = 2 or
       rw_craphis2.ingerdeb = 2 then
      vr_linhadet := '999,'||
                     trim(to_char(vr_vltitulo, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
  end loop;
  
  -- CONTA SALARIO - Re-Envio de TEC rejeitada na cabine do SPB  ................
  vr_cdhistor := 1758;
  vr_vltitulo := 0;
  --
  for rw_craplcs2 in cr_craplcs2 (pr_cdcooper,
                                  vr_dtmvtolt,
                                  vr_cdhistor) loop
    vr_vltitulo := rw_craplcs2.vllanmto;
    --
    open cr_craphis2 (pr_cdcooper,
                      vr_cdhistor);
      fetch cr_craphis2 into rw_craphis2;
      if cr_craphis2%notfound then
        close cr_craphis2;
        vr_cdcritic := 526;
        vr_dscritic := vr_cdhistor||' - '||gene0001.fn_busca_critica(vr_cdcritic);
        raise vr_exc_saida;
      end if;
    close cr_craphis2;
    --
    vr_cdestrut := '50';
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   trim(to_char(rw_craphis2.nrctadeb))||','||
                   trim(to_char(rw_craphis2.nrctacrd))||','||
                   trim(to_char(vr_vltitulo, '999999990.00'))||','||
                   trim(to_char(rw_craphis2.cdhstctb))||','||
                   '"('||vr_cdhistor||') RE-ENVIO DE TEC REJEITADA - CONTA SALARIO"';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    if rw_craphis2.ingercre = 2 or
       rw_craphis2.ingerdeb = 2 then
      vr_linhadet := '999,'||
                     trim(to_char(vr_vltitulo, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
  end loop;
  
  -- CONTA SALARIO - Devolucao de TEC Rejeitada na cabine do SPB  ................
  vr_cdhistor := 1937;
  vr_vltitulo := 0;
  --
  for rw_craplcs2 in cr_craplcs2 (pr_cdcooper,
                                  vr_dtmvtolt,
                                  vr_cdhistor) loop
    vr_vltitulo := rw_craplcs2.vllanmto;
    --
    open cr_craphis2 (pr_cdcooper,
                      vr_cdhistor);
      fetch cr_craphis2 into rw_craphis2;
      if cr_craphis2%notfound then
        close cr_craphis2;
        vr_cdcritic := 526;
        vr_dscritic := vr_cdhistor||' - '||gene0001.fn_busca_critica(vr_cdcritic);
        raise vr_exc_saida;
      end if;
    close cr_craphis2;
    --
    vr_cdestrut := '50';
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   trim(to_char(rw_craphis2.nrctadeb))||','||
                   trim(to_char(rw_craphis2.nrctacrd))||','||
                   trim(to_char(vr_vltitulo, '999999990.00'))||','||
                   trim(to_char(rw_craphis2.cdhstctb))||','||
                   '"('||vr_cdhistor||') DEVOLUCAO DE TEC REJEITADA - CONTA SALARIO"';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    if rw_craphis2.ingercre = 2 or
       rw_craphis2.ingerdeb = 2 then
      vr_linhadet := '999,'||
                     trim(to_char(vr_vltitulo, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
  end loop;  
  
  -- 887 - TEC REJEITADA ................
  vr_cdhistor := 887;
  vr_vltitulo := 0;
  --
  for rw_craplcs2 in cr_craplcs2 (pr_cdcooper,
                                  vr_dtmvtolt,
                                  vr_cdhistor) loop
    vr_vltitulo := rw_craplcs2.vllanmto;
    --
    open cr_craphis2 (pr_cdcooper,
                      vr_cdhistor);
      fetch cr_craphis2 into rw_craphis2;
      if cr_craphis2%notfound then
        close cr_craphis2;
        vr_cdcritic := 526;
        vr_dscritic := vr_cdhistor||' - '||gene0001.fn_busca_critica(vr_cdcritic);
        raise vr_exc_saida;
      end if;
    close cr_craphis2;
    --
    vr_cdestrut := '50';
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   trim(to_char(rw_craphis2.nrctadeb))||','||
                   trim(to_char(rw_craphis2.nrctacrd))||','||
                   trim(to_char(vr_vltitulo, '999999990.00'))||','||
                   trim(to_char(rw_craphis2.cdhstctb))||','||
                   '"('||vr_cdhistor||') ENVIO DE TEC - REJEITADA"';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    if rw_craphis2.ingercre = 2 or
       rw_craphis2.ingerdeb = 2 then
      vr_linhadet := '999,'||
                     trim(to_char(vr_vltitulo, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
  end loop;
  -- 801 - TEC DEVOLVIDA ................
  vr_cdhistor := 801;
  vr_vltitulo := 0;
  --
  for rw_craplcs2 in cr_craplcs2 (pr_cdcooper,
                                  vr_dtmvtolt,
                                  vr_cdhistor) loop
    vr_vltitulo := rw_craplcs2.vllanmto;
    --
    open cr_craphis2 (pr_cdcooper,
                      vr_cdhistor);
      fetch cr_craphis2 into rw_craphis2;
      if cr_craphis2%notfound then
        close cr_craphis2;
        vr_cdcritic := 526;
        vr_dscritic := vr_cdhistor||' - '||gene0001.fn_busca_critica(vr_cdcritic);
        raise vr_exc_saida;
      end if;
    close cr_craphis2;
    --
    vr_cdestrut := '50';
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   trim(to_char(rw_craphis2.nrctadeb))||','||
                   trim(to_char(rw_craphis2.nrctacrd))||','||
                   trim(to_char(vr_vltitulo, '999999990.00'))||','||
                   trim(to_char(rw_craphis2.cdhstctb))||','||
                   '"('||vr_cdhistor||') ENVIO DE TEC - DEVOLVIDA"';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    if rw_craphis2.ingercre = 2 or
       rw_craphis2.ingerdeb = 2 then
      vr_linhadet := '999,'||
                     trim(to_char(vr_vltitulo, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
  end loop;
  -- CONTA SALARIO - Transferencia TEC SALARIO entre cooperativas .........
  vr_cdhistor := 1018;
  vr_vltitulo := 0;
  --
  for rw_craplcs2 in cr_craplcs2 (pr_cdcooper,
                                  vr_dtmvtolt,
                                  vr_cdhistor) loop
    vr_vltitulo := rw_craplcs2.vllanmto;
    --
    open cr_craphis2 (pr_cdcooper,
                      vr_cdhistor);
      fetch cr_craphis2 into rw_craphis2;
      if cr_craphis2%notfound then
        close cr_craphis2;
        vr_cdcritic := 526;
        vr_dscritic := vr_cdhistor||' - '||gene0001.fn_busca_critica(vr_cdcritic);
        raise vr_exc_saida;
      end if;
    close cr_craphis2;
    --
    vr_cdestrut := '50';
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   trim(to_char(rw_craphis2.nrctadeb))||','||
                   trim(to_char(rw_craphis2.nrctacrd))||','||
                   trim(to_char(vr_vltitulo, '999999990.00'))||','||
                   trim(to_char(rw_craphis2.cdhstctb))||','||
                   '"('||vr_cdhistor||') TRANSF. ENTRE COOPERATIVAS - CONTA SALARIO"';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    if rw_craphis2.ingercre = 2 or
       rw_craphis2.ingerdeb = 2 then
      vr_linhadet := '999,'||
                     trim(to_char(vr_vltitulo, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;
  end loop;
  -- SAQUE TAA COMPARTILHADO OUTRA COOPERATIVA
  vr_cdhistor := 918;
  vr_vllanmto := 0;
  --
  for rw_craplcm in cr_craplcm2 (pr_cdcooper,
                                 vr_dtmvtolt,
                                 vr_cdhistor) loop
    vr_vllanmto := rw_craplcm.vllanmto;
    --
    vr_cdestrut := '50';
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   '1452,'||
                   trim(to_char(vr_tab_agencia2(rw_craplcm.cdagetfn).vr_cdcxaage, 'fm0000'))||','||
                   trim(to_char(vr_vllanmto, '999999990.00'))||','||
                   trim(to_char(rw_craphis2.cdhstctb))||','||
                   '(crps249) "SAQUE TAA COMPARTILHADO OUTRA COOP"';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_linhadet := to_char(rw_craplcm.cdagetfn, 'fm000')||','||
                   trim(to_char(vr_vllanmto, '999999990.00'));
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  end loop;
  -- ESTORNO SAQUE TAA COMPARTILHADO OUTRA COOPERATIVA
  vr_cdhistor := 920;
  vr_vllanmto := 0;
  --
  for rw_craplcm in cr_craplcm2 (pr_cdcooper,
                                 vr_dtmvtolt,
                                 vr_cdhistor) loop
    vr_vllanmto := rw_craplcm.vllanmto;
    --
    vr_cdestrut := '50';
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   trim(to_char(vr_tab_agencia2(rw_craplcm.cdagetfn).vr_cdcxaage, 'fm0000'))||','||
                   '1452,'||
                   trim(to_char(vr_vllanmto, '999999990.00'))||','||
                   trim(to_char(rw_craphis2.cdhstctb))||','||
                   '(crps249) "ESTORNO SAQUE TAA COMPARTILHADO OUTRA COOP"';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    vr_linhadet := to_char(rw_craplcm.cdagetfn, 'fm000')||','||
                   trim(to_char(vr_vllanmto, '999999990.00'));
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  end loop;
  
 -- DEMETRIUS
 -- SAQUE DE CAPITAL E DEPOSITOS DE COOPERADOS DEMITIDOS
  vr_vllanmto := 0;
  --
  for rw_craplcm in cr_craplcm21 (pr_cdcooper,
                                  vr_dtmvtolt)loop
    vr_vllanmto := rw_craplcm.vllanmto;
    --
    --
    open cr_craphis2 (pr_cdcooper,
                      rw_craplcm.cdhistor);
      fetch cr_craphis2 into rw_craphis2;
      if cr_craphis2%notfound then
        close cr_craphis2;
        vr_cdcritic := 526;
        vr_dscritic := rw_craplcm.cdhistor||' - '||gene0001.fn_busca_critica(526);
        raise vr_exc_saida;
      end if;
    close cr_craphis2;
    --
    vr_cdestrut := '50';
    if rw_craplcm.cdhistor = 2063 then
      vr_complinhadet := '"(2063) SAQUE DEPOSITO CONTA ENCERRADA PF"';
    elsif rw_craplcm.cdhistor = 2064 then
      vr_complinhadet := '"(2064) SAQUE DEPOSITO CONTA ENCERRADA PJ"';
    elsif rw_craplcm.cdhistor = 2081 then
      vr_complinhadet := '"(2081) SAQUE CAPITAL DISPONIVEL PF"';
    else
      vr_complinhadet := '"(2082) SAQUE CAPITAL DISPONIVEL PJ"';
    end if;
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   trim(to_char(rw_craphis2.nrctadeb))||','||
                   trim(to_char(rw_craphis2.nrctacrd))||','||
                   trim(to_char(vr_vllanmto, '999999990.00'))||','||
                   trim(to_char(rw_craphis2.cdhstctb))||','||
                   vr_complinhadet;
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    if rw_craplcm.cdhistor in (2063,2064) then
      vr_linhadet := to_char(rw_craplcm.cdagenci, 'fm000')||','||
                     trim(to_char(vr_vllanmto, '999999990.00'));
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    end if;     
  end loop;
  
  -- PROVISAO JUROS CHEQUE ESPECIAL
  vr_cdhistor := 38;
  vr_vllanmto := 0;
  OPEN cr_craplcm_tot(pr_cdcooper => pr_cdcooper
                     ,pr_cdhistor => vr_cdhistor
                     ,pr_dtmvtolt => vr_dtmvtolt);

  FETCH cr_craplcm_tot INTO rw_craplcm_tot;

  -- Fecha cursor
  CLOSE cr_craplcm_tot;

  IF rw_craplcm_tot.vllanmto > 0 THEN
    
  -- Cabecalho
  vr_cdestrut := 50;
  vr_linhadet := trim(vr_cdestrut)||
                 trim(to_char(vr_dtmvtoan,'yymmdd'))||','||
                 trim(to_char(vr_dtmvtoan,'ddmmyy'))||','||
                 '1802,'||
                 '7118,'||
                 TRIM(TO_CHAR(rw_craplcm_tot.vllanmto,'99999999999990.00')) || ',' ||
                   '5210,'||
                 '"(crps249) PROVISAO JUROS CH. ESPECIAL."';

  gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

  -- Leitura de lançamentos por PA
  OPEN cr_craplcm8(pr_cdcooper => pr_cdcooper
                  ,pr_cdhistor => vr_cdhistor
                  ,pr_dtmvtolt => vr_dtmvtolt);

  LOOP

    FETCH cr_craplcm8 INTO rw_craplcm8;

    -- Sai do loop quando chegar ao final dos registros da consulta
    EXIT WHEN cr_craplcm8%NOTFOUND;

    -- Escreve valor por PA no arquivo
    -- Colocada condicao pois estava gerando erro no RADAR
    IF rw_craplcm8.vllanmto <> 0 THEN
       gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, rw_craplcm8.cdagenci || ',' || TRIM(TO_CHAR(rw_craplcm8.vllanmto,'99999999999990.00')));
    END IF;

  END LOOP;

  -- Fecha cursor
  CLOSE cr_craplcm8;
        
        
  -- Inicializando a Pl-Table
  vr_arq_op_cred(14)(999)(1) := 0;
  vr_arq_op_cred(14)(999)(2) := 0;
        
  -- Separando as informacoes de PROVISAO JUROS CH. ESPECIAL por agencia e tipo de pessoa
  FOR rw_craplcm_age IN cr_craplcm_age(pr_cdcooper => pr_cdcooper
                                      ,pr_cdhistor => vr_cdhistor
                                      ,pr_dtmvtolt => vr_dtmvtolt) LOOP
                                            
     vr_arq_op_cred(14)(rw_craplcm_age.cdagenci)(rw_craplcm_age.inpessoa) := rw_craplcm_age.vllanmto;
     vr_arq_op_cred(14)(999)(rw_craplcm_age.inpessoa) := vr_arq_op_cred(14)(999)(rw_craplcm_age.inpessoa) + rw_craplcm_age.vllanmto;
        
  END LOOP; 
  
  IF vr_arq_op_cred(14)(999)(1) > 0 THEN
      -- Monta cabacalho - Arq 14 - PROVISAO JUROS CH. ESPECIAL - PESSOA FISICA
        vr_linhadet := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtoan,btch0001.rw_crapdat.dtmvtoan,7118,7014,vr_arq_op_cred(14)(999)(1),'"PROVISAO JUROS CH. ESPECIAL - PESSOA FISICA"');
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arquivo_txt --> Handle do arquivo aberto
                                    ,pr_des_text => vr_linhadet); --> Texto para escrita
        
      /* Deve ser duplicado as linhas separadas por PA */
      pc_set_linha(pr_cdarquiv => 14  -- PROVISAO JUROS CH. ESPECIAL - PESSOA FISICA
                  ,pr_inpessoa => 1
                  ,pr_inputfile => vr_arquivo_txt); -- Tipo de Pessoa
      -- Incluir nome do módulo logado
      gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

      pc_set_linha(pr_cdarquiv => 14  -- PROVISAO JUROS CH. ESPECIAL - PESSOA FISICA
                  ,pr_inpessoa => 1
                  ,pr_inputfile => vr_arquivo_txt); -- Tipo de Pessoa
      -- Incluir nome do módulo logado
      gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

   END IF;

     IF vr_arq_op_cred(14)(999)(2) > 0 THEN
      -- Monta cabacalho - Arq 14 - PROVISAO JUROS CH. ESPECIAL - PESSOA JURIDICA
        vr_linhadet := fn_set_cabecalho('70',btch0001.rw_crapdat.dtmvtoan,btch0001.rw_crapdat.dtmvtoan,7118,7015,vr_arq_op_cred(14)(999)(2),'"PROVISAO JUROS CH. ESPECIAL - PESSOA JURIDICA"');
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_arquivo_txt --> Handle do arquivo aberto
                                    ,pr_des_text => vr_linhadet); --> Texto para escrita
        
      /* Deve ser duplicado as linhas separadas por PA */
      pc_set_linha(pr_cdarquiv => 14  -- PROVISAO JUROS CH. ESPECIAL - PESSOA JURIDICA
                  ,pr_inpessoa => 2
                  ,pr_inputfile => vr_arquivo_txt); -- Tipo de Pessoa
      -- Incluir nome do módulo logado
      gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

      pc_set_linha(pr_cdarquiv => 14  -- PROVISAO JUROS CH. ESPECIAL - PESSOA JURIDICA
                  ,pr_inpessoa => 2
                  ,pr_inputfile => vr_arquivo_txt); -- Tipo de Pessoa
      -- Incluir nome do módulo logado
      gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

   END IF;
  
  END IF;
  -- LIBERACAO CONTRATO DE FINAME BNDES"
  vr_cdhistor := 1529;
  vr_vllanmto := 0;
  --
  FOR rw_craplcm IN cr_craplcm7 (pr_cdcooper,
                                 vr_dtmvtolt,
                                 vr_cdhistor) LOOP
                                 
    -- 50141211,111214,1632,4451,34000000.00,5210,"LIBERACAO CONTRATO DE FINAME BNDES"
    -- 999,34000000.00
    vr_vllanmto := rw_craplcm.vllanmto;
    --
    vr_cdestrut := '50';
    vr_linhadet := TRIM(vr_cdestrut)||
                   TRIM(vr_dtmvtolt_yymmdd)||','||
                   TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   '1432,'||
                   '4451,'||
                   TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                   '5210,'||
                   '"LIBERACAO CONTRATO DE FINAME BNDES"';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    --vr_linhadet := '999,'||
    --               TRIM(to_char(vr_vllanmto, '999999990.00'));
    --gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  END LOOP;
  
  -- ESTORNO LIBERACAO CONTRATO DE FINAME BNDES
  vr_cdhistor := 1530;
  vr_vllanmto := 0;
  --
  FOR rw_craplcm IN cr_craplcm7 (pr_cdcooper,
                                 vr_dtmvtolt,
                                 vr_cdhistor) LOOP
                                 
    -- 50141211,111214,4451,1632,15000000.00,5210,"ESTORNO LIBERACAO CONTRATO DE FINAME BNDES"
    -- 999,15000000.00
    vr_vllanmto := rw_craplcm.vllanmto;
    --
    vr_cdestrut := '50';
    vr_linhadet := TRIM(vr_cdestrut)||
                   TRIM(vr_dtmvtolt_yymmdd)||','||
                   TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   '4451,'||
                   '1432,'||
                   TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                   '5210,'||
                   '"ESTORNO LIBERACAO CONTRATO DE FINAME BNDES"';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --
    --vr_linhadet := '999,'||
    --               TRIM(to_char(vr_vllanmto, '999999990.00'));
    --gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  END LOOP;
  
  
  -- JUROS SOBRE CONTRATO DE FINAME BNDES
  vr_cdhistor := 1531;
  vr_vllanmto := 0;
  --
  FOR rw_craplcm IN cr_craplcm7 (pr_cdcooper,
                                 vr_dtmvtolt,
                                 vr_cdhistor) LOOP
                                 
    vr_vllanmto := rw_craplcm.vllanmto;
    --
    vr_cdestrut := '50';
    vr_linhadet := TRIM(vr_cdestrut)||
                   TRIM(vr_dtmvtolt_yymmdd)||','||
                   TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   '1432,'||
                   '1631,'||
                   TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                   '5210,'||
                   '"JUROS SOBRE CONTRATO DE FINAME BNDES"';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --Gerencial
    vr_linhadet := '999,'||
                   TRIM(to_char(vr_vllanmto, '999999990.00'));
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  END LOOP;
  
  -- ESTORNO DE JUROS SOBRE CONTRATO DE FINAME BNDES
  vr_cdhistor := 1532;
  vr_vllanmto := 0;
  --
  FOR rw_craplcm IN cr_craplcm7 (pr_cdcooper,
                                 vr_dtmvtolt,
                                 vr_cdhistor) LOOP
                                 
    vr_vllanmto := rw_craplcm.vllanmto;
    --
    vr_cdestrut := '50';
    vr_linhadet := TRIM(vr_cdestrut)||
                   TRIM(vr_dtmvtolt_yymmdd)||','||
                   TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   '1631,'||
                   '1432,'||
                   TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                   '5210,'||
                   '"ESTORNO DE JUROS SOBRE CONTRATO DE FINAME BNDES"';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --Gerencial
    vr_linhadet := '999,'||
                   TRIM(to_char(vr_vllanmto, '999999990.00'));
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  END LOOP;

  
  -- PAGAMENTO PARCELA FINAME
  vr_cdhistor := 1806;
  vr_vllanmto := 0;
  --
  FOR rw_craplcm IN cr_craplcm7 (pr_cdcooper,
                                 vr_dtmvtolt,
                                 vr_cdhistor) LOOP
                                 
    vr_vllanmto := rw_craplcm.vllanmto;
    --
    vr_cdestrut := '50';
    vr_linhadet := TRIM(vr_cdestrut)||
                   TRIM(vr_dtmvtolt_yymmdd)||','||
                   TRIM(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   '1631,'||
                   '1432,'||
                   TRIM(to_char(vr_vllanmto, '999999990.00'))||','||
                   '5210,'||
                   '"Ajuste ref. PAGAMENTO PARCELA DE VALOR PRINCIPAL - FINAME BNDES"';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    --Gerencial
    vr_linhadet := '001,'||
                  TRIM(to_char(vr_vllanmto, '999999990.00'));
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
  END LOOP;
  
  --  Fim da contabilizacao da COMP. ELETRONICA ...............................

	-- RECEITA RECARGA DE CELULAR ..............................................

  FOR inpes IN 1..2 LOOP
  FOR rw_operadora IN cr_operadora(pr_cdcooper => pr_cdcooper
                                    ,pr_dtmvtolt => vr_dtmvtolt
                                    ,pr_inpessoa => inpes) LOOP
																	
      IF rw_operadora.vl_receita > 0 THEN
        
        vr_index := rw_operadora.cdoperadora;
        
        if vr_tab_recarga_cel_ope.exists(vr_index) then
           vr_tab_recarga_cel_ope(vr_index).vlreceita :=  vr_tab_recarga_cel_ope(vr_index).vlreceita +  rw_operadora.vl_receita;
        else         
           vr_tab_recarga_cel_ope(vr_index).vlreceita :=  rw_operadora.vl_receita; 
           vr_tab_recarga_cel_ope(vr_index).nmoperadora := rw_operadora.nmoperadora;        
        end if;
        
        if rw_operadora.inpessoa = 1 then
          vr_receita_cel_pf := nvl(vr_receita_cel_pf,0) + rw_operadora.vl_receita;
        else
          vr_receita_cel_pj := nvl(vr_receita_cel_pj,0) + rw_operadora.vl_receita;
        end if;

      END IF;

    END LOOP;
  END LOOP;
  
  --
  
  vr_chave := vr_tab_recarga_cel_ope.first;
  WHILE vr_chave IS NOT NULL LOOP
    
			/* Linha 1 - Cabecalho*/
			vr_cdestrut := '55';
			vr_linhadet := trim(vr_cdestrut)||
										 trim(vr_dtmvtolt_yymmdd)||','||
										 trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
										 '4340,'|| 
										 '7543,'||
                    trim(to_char(vr_tab_recarga_cel_ope(vr_chave).vlreceita, '999999990.00'))||','||
										 '5210,'||
										 '"(crps249) RECEITA RECARGA DE CELULAR - ' ||
                    vr_tab_recarga_cel_ope(vr_chave).nmoperadora || '"';
		
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);	
      
    --
    --Gera gerencial por operadora
    FOR rw_operadora in cr_operadora(pr_cdcooper => pr_cdcooper
		                                ,pr_dtmvtolt => vr_dtmvtolt
                                    ,pr_inpessoa => 0) LOOP
      
      IF rw_operadora.cdoperadora = vr_chave THEN
        vr_linhadet := to_char(rw_operadora.cdagenci, 'fm000')|| ',' ||
                       trim(to_char(rw_operadora.vl_receita,'999999990.00'));
			
        gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
      END IF;
      
      --
    END LOOP;
    
    vr_chave := vr_tab_recarga_cel_ope.next(vr_chave);
    --
  END LOOP;
  
  vr_chave    := NULL;
	--
  IF vr_receita_cel_pf > 0 THEN

    /* Linha 1 - Cabecalho*/

    vr_cdestrut := '55';
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   '7543,'|| 
                   '7541,'||
                   trim(to_char(vr_receita_cel_pf, '999999990.00'))||','||
                   '5210,'||
                   '"RECEITA RECARGA DE CELULAR - PESSOA FISICA"';
			gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);																	
			
    FOR I IN 1..2 LOOP
    
      FOR rw_recargas in cr_recargas(pr_cdcooper => pr_cdcooper
																			 ,pr_dtmvtolt => vr_dtmvtolt
                                       ,pr_inpessoa => 1) LOOP

          vr_linhadet := to_char(rw_recargas.cdagenci, 'fm000')|| ',' ||
                         trim(to_char(rw_recargas.vl_receita,'999999990.00'));
				gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

			END LOOP;
			END LOOP;
    
		END IF;
  --
  IF vr_receita_cel_pj > 0 THEN

    /* Linha 1 - Cabecalho*/
    vr_cdestrut := '55';
    vr_linhadet := trim(vr_cdestrut)||
                   trim(vr_dtmvtolt_yymmdd)||','||
                   trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
                   '7543,'|| 
                   '7542,'||
                   trim(to_char(vr_receita_cel_pj, '999999990.00'))||','||
                   '5210,'||
                   '"RECEITA RECARGA DE CELULAR - PESSOA JURIDICA"';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
    
    FOR I IN 1..2 LOOP

      FOR rw_recargas in cr_recargas(pr_cdcooper => pr_cdcooper
		                                ,pr_dtmvtolt => vr_dtmvtolt
                                    ,pr_inpessoa => 2) LOOP

          vr_linhadet := to_char(rw_recargas.cdagenci, 'fm000')|| ',' ||
                         trim(to_char(rw_recargas.vl_receita,'999999990.00'));
          gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);

			END LOOP;

	END LOOP;
	
  END IF;
  -- Fim RECEITA RECARGA DE CELULAR ...........................................	

  IF pr_cdcooper = 3 THEN
		-- REPASSE RECARGA DE CELULAR .............................................
		OPEN cr_craptvl_recarg(pr_cdcooper => pr_cdcooper
		                      ,pr_dtmvtolt => vr_dtmvtolt);
	  FETCH cr_craptvl_recarg INTO rw_craptvl_recarg;

    IF cr_craptvl_recarg%FOUND THEN		
			vr_cdestrut := 50;
			vr_linhadet := trim(vr_cdestrut)||
										 trim(vr_dtmvtolt_yymmdd)||','||
										 trim(to_char(vr_dtmvtolt,'ddmmyy'))||','||
										 '4340,'|| 
										 '1425,'|| 
										 TRIM(TO_CHAR(nvl(rw_craptvl_recarg.vldocrcb, 0),'99999999999990.00')) || ','||
										 '5210,'||
										 '"(crps249) REPASSE RECARGA DE CELULAR"';
			gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
		END IF;
		-- Fechar cursor
		CLOSE cr_craptvl_recarg;
  END IF;
  --  Contabilizacao mensal ...................................................
  IF to_char(vr_dtmvtolt, 'mm') <> to_char(vr_dtmvtopr, 'mm') THEN

    pc_proc_cbl_mensal(pr_cdcooper);
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);

  END IF;
  
  -- Gera o arquivo AAMMDD_OPCRED.txt - Dados para contabilidade
  pc_gera_arq_op_cred (vr_dscritic);
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
    
  IF vr_dscritic IS NOT NULL THEN
     vr_cdcritic := 0;
     RAISE vr_exc_saida;
  END IF;
    
  vr_nmarqdat_ope_cred_nov := vr_dtmvtolt_yymmdd||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_OPCRED.txt';

  -- Copia o arquivo gerado para o diretório final convertendo para DOS
  gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarqdat_ope_cred||' > '||vr_dsdircop||'/'||vr_nmarqdat_ope_cred_nov||' 2>/dev/null',
                              pr_typ_saida   => vr_typ_said,
                              pr_des_saida   => vr_dscritic);
  -- Testar erro
  if vr_typ_said = 'ERR' then
     vr_cdcritic := 1040;
     gene0001.pc_print(gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_nmarqdat_ope_cred||': '||vr_dscritic);
  end if; 
  --Fim geração arquivo AAMMDD_OPCRED.txt
  
  --Gera arquivo AAMMDD_PREJUIZO.txt
  pc_gera_arq_prejuizo(vr_dscritic);
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
  
  IF vr_dscritic IS NOT NULL THEN
     vr_cdcritic := 0;
     RAISE vr_exc_saida;
  END IF;
  --Fim arquivo AAMMDD_PREJUIZO.txt
  
  --Gera arquivo AAMMDD_TARIFASBB.txt
  pc_gera_arq_tarifasbb(vr_dscritic);
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS249', pr_action => vr_cdprogra);
  
  IF vr_dscritic IS NOT NULL THEN
     vr_cdcritic := 0;
     RAISE vr_exc_saida;
  END IF;
  --Fim arquivo AAMMDD_TARIFASBB.txt
  
  
  -- Despesa Sicredi
  BEGIN
    DELETE FROM craprej
     WHERE craprej.cdcooper = pr_cdcooper
       AND craprej.cdpesqbb = vr_cdprogra
       AND craprej.dtmvtolt = vr_dtmvtolt;
  EXCEPTION
    WHEN OTHERS THEN
      --Inclusão na tabela de erros Oracle - Chamado 734422
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);                                                             
      vr_cdcritic := 1037;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' registros de despesa Sicredi: '||sqlerrm;
      RAISE vr_exc_saida;
  END;

  --  Fim da contabilizacao mensal ............................................
  gene0001.pc_fecha_arquivo(vr_arquivo_txt);

  vr_nmarqnov := vr_dtmvtolt_yymmdd||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'.txt';                        
                                                        
  -- Copia o arquivo gerado para o diretório final convertendo para DOS
  gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarqdat||' > '||vr_dsdircop||'/'||vr_nmarqnov||' 2>/dev/null',
                              pr_typ_saida   => vr_typ_said,
                              pr_des_saida   => vr_dscritic);
  -- Testar erro
  if vr_typ_said = 'ERR' then
     vr_cdcritic := 1040;
     gene0001.pc_print(gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_nmarqdat||': '||vr_dscritic);
  end if;

  -- Inicializa CLOB XML
  dbms_lob.createtemporary(vr_relatorio_epr, TRUE);
  dbms_lob.open(vr_relatorio_epr, dbms_lob.lob_readwrite);

  gene0002.pc_escreve_xml(vr_relatorio_epr,vr_texto_relatorio,
                         '<?xml version="1.0" encoding="utf-8"?><crrl708>');

  FOR rw_crapepr IN cr_crapepr(pr_cdcooper, vr_dtmvtolt) LOOP
    gene0002.pc_escreve_xml(vr_relatorio_epr,vr_texto_relatorio,
                        '<reg>' ||
                          '<nrdconta>' || gene0002.fn_mask_conta(rw_crapepr.nrdconta) || '</nrdconta>' ||
                          '<nrctremp>' || gene0002.fn_mask_contrato(rw_crapepr.nrctremp) || '</nrctremp>' ||
                          '<vllanmto>' || rw_crapepr.vllanmto || '</vllanmto>' ||
                          '<cdlcremp>' || rw_crapepr.cdlcremp || '</cdlcremp>' ||
                          '<cdhistor>' || rw_crapepr.cdhistor || '</cdhistor>' ||
                          '<tpprodut>' || rw_crapepr.tpprodut || '</tpprodut>' ||
    '</reg>');
    
    IF NOT tb_tot_his_rel.EXISTS(rw_crapepr.cdhistor) THEN
      tb_tot_his_rel(rw_crapepr.cdhistor).cdhistor := rw_crapepr.cdhistor;
      tb_tot_his_rel(rw_crapepr.cdhistor).dshistor := rw_crapepr.dshistor;
      tb_tot_his_rel(rw_crapepr.cdhistor).vllanmto := rw_crapepr.vllanmto;
    ELSE
      tb_tot_his_rel(rw_crapepr.cdhistor).vllanmto := tb_tot_his_rel(rw_crapepr.cdhistor).vllanmto + rw_crapepr.vllanmto;
    END IF;
  END LOOP;
  
  -- Percorre a lista de pagamentos
  vr_chave := tb_tot_his_rel.FIRST;
  WHILE vr_chave IS NOT NULL LOOP
    BEGIN
      gene0002.pc_escreve_xml(vr_relatorio_epr,vr_texto_relatorio,
                          '<total>' ||
                             '<cdhistor>' || tb_tot_his_rel(vr_chave).cdhistor || '</cdhistor>' ||
                             '<dshistor>' || tb_tot_his_rel(vr_chave).dshistor || '</dshistor>' ||
                             '<vllanmto>' || tb_tot_his_rel(vr_chave).vllanmto || '</vllanmto>' ||
      '</total>');
    END;
    vr_chave := tb_tot_his_rel.NEXT(vr_chave);
  END LOOP;
  
  gene0002.pc_escreve_xml(vr_relatorio_epr,vr_texto_relatorio,'</crrl708>',TRUE);
  
  -- Busca do diretorio base da cooperativa para a geração de arquivos
  vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C'           --> /usr/coop
				    			                      ,pr_cdcooper => pr_cdcooper   --> Cooperativa
			                                  ,pr_nmsubdir => 'rl');       --> Raiz
  -- Seta nome do arquivo
  vr_nom_arquivo := 'crrl708.lst';
   
  -- Solicitar impressao
  gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper      --> Cooperativa conectada
                             ,pr_cdprogra  => vr_cdprogra      --> Programa chamador
                             ,pr_dtmvtolt  => vr_dtmvtolt      --> Data do movimento atual
                             ,pr_dsxml     => vr_relatorio_epr --> Arquivo XML de dados
                             ,pr_dsxmlnode => '/crrl708'       --> No base do XML para leitura dos dados
                             ,pr_dsjasper  => 'crrl708.jasper' --> Arquivo de layout do iReport
                             ,pr_dsparams  => NULL             --> Enviar como parametro apenas a agencia
                             ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo --> Arquivo final com codigo da agencia
                             ,pr_qtcoluna  => 132              --> 132 colunas
                             ,pr_flg_impri => 'S'              --> Chamar a impressao (Imprim.p)
                             ,pr_flg_gerar => 'N'              --> gerar na hora
                             ,pr_nmformul  => '132col'         --> Nome do formulario para impress?o
                             ,pr_nrcopias  => 1                --> Numero de copias
                             ,pr_des_erro  => vr_dscritic);    --> Saida com erro
  
  -- Liberando a memoria alocada pro CLOB
  dbms_lob.close(vr_relatorio_epr);
  dbms_lob.freetemporary(vr_relatorio_epr);
  
  --Gerar arquivos contábeis de lançamentos centralizados para cada filiada.
  IF pr_cdcooper = 3 then
    BEGIN
      cont0001.pc_gera_arquivos_contabeis(to_date(to_char(vr_dtmvtolt,'dd/mm/rrrr'),'dd/mm/rrrr'),
                                          to_date(to_char(vr_dtmvtopr,'dd/mm/rrrr'),'dd/mm/rrrr'));
    EXCEPTION
      WHEN OTHERS THEN
        --Inclusão na tabela de erros Oracle - Chamado 734422
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);                                                             
        vr_cdcritic := 1043;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||sqlerrm;
        RAISE vr_exc_saida;        
    END; 
  END IF;                          
  
  -- Finalizar o programa
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  --
  COMMIT;
  --
EXCEPTION
  WHEN vr_exc_fimprg THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Se foi gerada critica para envio ao log
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log  => 2 -- Erro de negócio
                                ,pr_nmarqlog      => 'proc_batch.log'
                                ,pr_tpexecucao    => 1 -- Job
                                ,pr_cdcriticidade => 1 -- Medio
                                ,pr_cdmensagem    => vr_cdcritic
                                ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '
                                                    || vr_cdprogra || ' --> '|| vr_dscritic);
                                                 
    END IF;
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit pois gravaremos o que foi processo até então
    COMMIT;
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    -- Efetuar
    ROLLBACK;
  WHEN OTHERS THEN
    --Inclusão na tabela de erros Oracle - Chamado 734422
    CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);                                                             
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    ROLLBACK;
END PC_CRPS249;
/
