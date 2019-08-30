/* .............................................................................

   Programa: Fontes/landpvi.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/91.                     Ultima atualizacao: 01/02/2018

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela LANDPV.

   Alteracoes: 13/06/94 - Alterado para ler a tabela das contas convenio do
                          Banco do Brasil (Edson).

               17/08/94 - Alterado para nao aceitar os lancamentos com os his-
                          toricos 2 e 15 para associados demitidos no lotes de
                          emprestimo (Edson).

               30/08/94 - Alterado para nao aceitar os lancamentos para os asso-
                          ciados que tenham dtemilim (Deborah).

               29/09/94 - Alterado layout de tela e inclusao no campo Alinea
                          (Deborah/Edson).

               06/10/94 - Alterado para testar a alinea da tela contra o arquivo
                          crapali (Deborah).

               25/10/94 - Alterado para tratar o historico 78, do mesmo modo que
                          o 47 (Deborah).

               27/10/94 - Alterado para automatizar a devolucao dos cheques com
                          contra-ordem (Deborah).

               16/05/95 - Alterado para incluir o parametro aux_cdalinea para
                          a rotina geradev (Edson).

               26/06/95 - Alterado para verificar se os lancamentos a debito
                          tem autorizacao e soliticacao de geracao de aviso
                          (Edson).

               07/07/95 - Nao permitir lancamentos que tenham incheque = 8
                          (Odair).

               03/10/95 - Acerto na atualizacao da data do ultimo debito
                          (Deborah).

               25/10/96 - Alterado para diminuir tamanho do codigo r. (Odair)

               17/01/97 - Alterado para nao calcular mais o saldo de associados
                          demitidos (Deborah).

               24/01/97 - Alterado para tratar o historico 191 da mesma forma
                          que o 47 (Deborah).

               30/01/97 - Alterado para nao conferir o documento no historico
                          105 (Deborah).

               27/08/97 - Alterado para incluir o campo flgproce na criacao
                          do crapavs (Deborah).

               01/04/98 - Tratamento para milenio e troca para V8 (Magui).

               29/06/98 - Alterado para NAO tratar o historico 289 (Edson).
               
               19/08/98 - Nao permitir o lancamento de cheque salario (histo-
                          rico 26) se a conta base nao for do Banco do Brasil
                          (Deborah).
                          
               09/11/98 - Tratar situacao em prejuizo (Deborah).          
                
               18/12/98 - Tratar o historico 835 da mesma forma que o 818
                          (Deborah).

               09/06/1999 - Eliminar rotinas em desuso que precisavam de ajus-
                            tes para a CPMF (Deborah).

               23/06/1999 - Novos parametros para geradev.p (Odair)

               02/07/1999 - Tratar tpcheque e historico 340 (Odair)

               18/08/1999 - Tratar incheque = 6 (Deborah). 

               20/10/1999 - Acerto na critica 93 (Deborah).

               26/07/2000 - Tratar historicos de caixa e extra-caixa (Odair)

               24/10/2000 - Desmembrar a critica 95 conforme a situacao do
                            titular (Eduardo).

               05/05/2001 - Tratamento da compensacao eletronica (Magui).

               06/08/2001 - Tratar prejuizo da conta corrente (Magui).

               20/08/2001 - Tratar onze posicoes no numero do documento (Edson).

               24/08/2001 - Identificar depositos da cooperativa (Magui).
               
               06/09/2001 - Permitir alterar cheques digitados (Magui).
               
               17/09/2001 - Criar histor 21 quando 386 (Magui).

               28/12/2001 - Alterado para tratar a rotina ver_capital (Edson).

               21/01/2002 - Vincular historicos aos lancamentos (Magui).

               25/02/2002 - Permitir o lancamento do histor 127 (Debito de
                            capital com o capital zerado (Deborah)

               27/03/2002 - Criar histor 353 quando 428 (Magui).

               23/04/2002 - Corrigir rotina do estorno de deposito bloqueado
                            (Edson).

               27/03/2002 - Criar histor 393 quando 394 (Edson).
                            
               13/09/2002 - Alterado para tratar o boletim de caixa (Edson).

               01/10/2002 - Tratar liberacao de cheques (Magui).
               
               26/09/2002 - Tratar os historicos 351, 024 e 027 para mostrar
                            o cdpesqbb. (Ze Eduardo).

               03/12/2002 - Tratar historico 521 da mesma forma que o 21 
                            (Edson)

               04/12/2002 - Tratar historico 526 da mesma forma que o 26 
                            (Edson)

               13/02/2003 - Tratar historico 621 da mesma forma que o 21 
                            (Edson)

               11/03/2003 - Erro na nova numeracao do documento quando des-
                            membra o historico 3 e o 4 (Magui).

               14/03/2003 - Incluir tratamento para a CONCREDI (Magui).

               07/04/2003 - Incluir tratamento do histor 399 (Magui).

               09/04/2003 - Tratar devolucao parcial de depositos bloqueados
                            (Edson).
               
               06/08/2003 - Tratamento historico 156 (Julio).

               07/08/2003 - Incluir novo tratamento historico 350 (Magui).
               
               08/08/2003 - Incluir geracao do controle de movimentacao
                            em especie (Magui).

               22/08/2003 - Quando histor 386 criticar saldo (Magui).

               10/02/2004 - Efetuado controle por PA(tabelas horario 
                            compel/titulo) (Mirtes)

               06/04/2004 - Cooperativa 6 - Capital Minimo - Considerar
                            matricula (qdo menor que tabela)(Mirtes).
                            
               19/05/2004 - Criar historico 402 quando 451 (Edson).
                            

               15/06/2004 - Ajustes na criacao do historico 88 (Edson).
 
               30/07/2004 - Passado parametro quantidade prestacoes
                            calculadas(Mirtes)

               09/08/2004 - Se histor 88, atualizar crapepr.dtdpagto,
                            crapepr.indpagto (Magui).

               26/08/2004 - Tratamento da conta integracao (Magui).

               14/09/2004 - Tratamento Conta Investimento(Mirtes).

               14/09/2004 - Valida alinea na devolucao do cheque (Edson).
               
               30/09/2004 - Criar historico 349 quando 350 (Edson).

               08/06/2005 - Prever tipo de Conta 17 / 18(Mirtes).
               
               28/09/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
               
               09/11/2005 - Alterado para tratar novo indice no crapcor (Edson).
               
               14/11/2005 - Quando inclui docto zero dar erro (Magui).
               
               09/12/2005 - Cheque salario nao existe mais (Magui).
               
               21/12/2005 - Quando histor 23 exigir a nrdconta (Magui).

               23/12/2005 - Faltava atualizar campo aux_nrdconta (Magui).
                            Ajustes na criacao do crapdev (Edson).

               04/01/2006 - Tratar cheque TB para a conta integracao (Edson).
               
               10/01/2006 - Atualizado cod.cooperativa tabelas crapsli/
                            crapavs/craplcm/craplot/craplct/craplem/ 
                            crapdpb/crapchd(Mirtes)
               
               16/01/2006 - Permitir fazer lancamentos em associado excluido
                            mediante confirmacao (Evandro/Mirtes).

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

               13/02/2006 - Inclusao do parametro glb_cdcooper para as 
                            chamadas dos programas fontes/pedesenha.p e
                            fontes/testa_boletim.p - SQLWorks - Fernando.
                            
               13/02/2006 - Inclusao do parametro glb_cdcooper para a
                            chamada do programa fontes/testa_conta.p e  
                            SQLWorks - Andre

               18/05/2006 - Atualizar crapavs quando pagamento de emprestimo
                            vinculado a folha (Julio)
                            
               08/06/2006 - Incluido codigo do operador ao criar craplcm
                            (Diego).
                            
               10/07/2006 - Disponibilizar alinea zerada para o hist. 351 (Ze)
               
               14/07/2006 - Alterado para nao permitir lancamentos se conta
                            possuir data de eliminacao (Diego).
               
               23/08/2006 - Alterado para utilizacao do USE-INDEX(Diego)
                     
               28/08/2006 - Atualizacao do crapavs para o caso de pagamento
                            de emprestimo. Verificar se a folha referente ao 
                            mes atual ja entrou. (Julio)

               31/01/2007 - Desprezar cartoes magneticos vencidos (Magui).
               
               13/02/2007 - Efetuada alteracao para nova estrutura crapdev.
                            (Diego)
                            
               27/02/2007 - Ajustes para o Bancoob (Magui).

               16/03/2007 - Qdo histor 351 perguntar se o cheque e nosso ou
                            de outro banco (Magui)

               20/03/2007 - Ajuste na leitura do crapcor qdo 521 (Magui).
               
               13/04/2007 - Aumentar campo nrdocmto (Magui).

               17/04/2007 - Para o caso de pagamento de emprestimo vinculado
                            a folha, perguntar se deseja baixar o proximo aviso
                            pendente ou nao (Julio).

               24/05/2007 - Histor 428 nao pode quando preju (Magui)
               
               25/05/2007 - Histor 506 para reverter o 428 (Magui).
               
               06/06/2007 - Acerto na rotina de atualizacao do crapavs, para
                            o caso de estorno de emprestimos liquidados.
                            Tratamento para historico 506/507(Julio)

               22/08/2007 - Tratamento para lancamentos de emprestimos
                            vinculados a conta. Atualizacao do crapepr.dtdpagto
                            (Julio)

               24/09/2007 - Conversao de rotina ver_capital para BO 
                            (Sidnei/Precise)
                            
               04/10/2007 - Alterado o calculo para a data de pagamento do
                            emprestimo (Julio)
                            
               09/10/2007 - Ver se o cheque esta cancelado para o hist 23 (Ze).
               
               29/10/2007 - Acerto no historico 23 (Tarefa 13779) (Ze).
               
               31/10/2007 - Substituicao de procedure p_atualiza_dtdpagto para
                            includes/atualiza_epr.i (Julio)
                            
               28/03/2008 - Acerto na alinea 21 contra-ordem Trf 16293 (Ze)

               27/05/2008 - Nao atualizar data de pagamento quando qtmesdec
                            mes zeros (Magui).

               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS.   
                          - Kbase IT Solutions - Eduardo Silva.       

               12/08/2008 - Unificacao dos bancos, incluido cdcooper na busca da
                            tabela crabhis(Guilherme).             

               19/08/2008 - Permitir estorno de folha dentro do mesmo
                            mes de pagamento por fora e correcao do
                            cmc7 (Magui).            

               01/09/2008 - Alteracao CDEMPRES (Kbase).

               30/09/2008 - Tratamento para LOCK na craplot (David).

               02/03/2009 - Critica para o uso do historico 585 (Gabriel). 

               22/06/2009 - Nao permitir lancamentos nos emprestimos que
                            estejam atrelados a pagamento com boletos
                            (Fernando).
                          - Podera efetuar o pagamento mas somente se o boleto
                            estiver baixado, a situacao que o Fernando fez
                            apenas foi comentada. (Guilherme).

               13/10/2009 - Adaptacoes CAF
                            - Passar cheques somente 1 a 1
                            - Calcular data liberacao cheque pela b1wgen0044
                              (includes/proc_landpv.i)
                          - Adaptacoes projeto IF CECRED (Guilherme).

               02/02/2010 - Alteracao codigo historico (Kbase).

               19/05/2010 - Desativar Rating quando quitado o emprestimo
                           (Gabriel).

               11/08/2010 - Acerto na criacao do crapdev (Ze).            

               17/11/2010 - Bloqueio do hist. 47 e 191 para cheques vindos
                            da compe 085 (Ze).

               09/12/2010 - Tratamento para verificar se o cheque ja foi 
                            encaminhado para a compe - Truncagem (Ze).

               14/12/2010 - Inclusao de Transferencia de PA quando coop 2
                            (Guilherme/Supero)
                            
               19/01/2011 - Ajustes Gerais (Ze).

               26/01/2011 - Inclusao de tratamento na TCO quando banco 001
                            Conta ITG (Guilherme/Supero)
                            
               28/02/2011 - Inclusao da critica 934 para emprestimos onde
                            crapepr.dtmvtolt = glb_dtmvtolt (Vitor).
                            
                          - Nao permitir lancamento c/ valores maiores a
                            crapcot.vldcotas menos os históricos 930, quando
                            utilizados os históricos 354 e 451 (Vitor).
                            
                          - Tratamento p/ o historico 931 (Vitor).  
                          
               07/07/2011 - Nao tarifar alinea de devolucao 31 (Diego). 
               
               14/07/2011 - Nao permitir historicos 3 e 4 (Gabriel).  
               
               30/11/2011 - Tratar do prejuizo da c/c 85448 da Coop 2 (Ze)´.
               
               02/12/2011 - Nao chamar mais a tela CMESAQ (Gabriel).
               08/12/2011 - Sustacao Provisoria (Histor:1070) (Andre R./Supero)
               12/12/2011 - Critica para lancamento do historico 350 se periodo
                            no risco 'H' for menor do que 6 meses (Elton).
               29/12/2011 - Incluir includes da BO 104 so p/ compilar.
                            Incluir historico 1030. 
                           (Gabriel).             
               06/01/2012 - Criticar pagamento de emprestimo a maior com
                            historico 394 (Diego).
               15/02/2012 - Corrigido criacao do registro da craplct
                            historico 931 (Tiago).
                           
               05/03/2012 - Validacao do historico do novo emprestimo (Tiago).         
               
               18/04/2012 - Comentada critica para lancamento em prejuizo 
                            historico 350 (Elton).
                            
               18/06/2012 - Alteracao na leitura da craptco (David Kruger).
               
               06/08/2012 - Tratamento do lock da crablot (Gabriel).
               
               06/08/2012 - Adicionado parametro "codigo do programa" a chamada
                            da funcao geradev. (Fabricio)
                            
               26/09/2012 - Tratamento quando for cheque custodiado (Lucas R.)
               
               18/10/2012 - Tratamento para o historico 931 e chamada da
                            BO 140 (Tiago).            
                            
               05/11/2012 - Ajustar tratamento para coop migrada (Guilherme)
               
               26/02/2013 - Alterado para questionar o operador sobre devolver
                            o cheque com dados da TIC pela alinea 35.
                            (Fabricio)
                            
               17/04/2013 - Cast de decimal para inteiro na comparacao
                            craplem.nrctremp = crapavs.nrdocmto (linha 555-RTB).
                            O cast se faz necessario devido ao fato do campo
                            craplem.nrctremp ter sido adicionado num novo
                            indice criado na craplem(craplem5). (Fabricio)
                            
               24/04/2013 - Incluir verificacao de historico na crapfvl (Lucas R)
               
               02/08/2013 - Tratamento para o Bloqueio Judicial (Ze).
               
               23/08/2013 - Exclusao da alinea 29. (Fabricio)
               
               15/10/2013 - Bloqueio da inclusao dos historicos 127 e 451.
                            (Fabricio)
                                              
               12/12/2013 - Inclusao de VALIDATE crapavs, crapdev, craplcm, 
                            craplot, craplct, craplem, crapdpb e crapchd 
                            (Carlos)
                            
               20/12/2013 - Ajustes para migracao Acredi (Elton).
               
               20/01/2014 - Acerto na leitura da tabela crapfdc ref. conta 
                            migrada ACREDI (Diego).

               27/05/2014 - Ajustado o campo tel_nrdocmto, pois o mesmo estava 
                            vindo com 22 posicoes (Andrino - RKAM)
                            
               05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
               
               23/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                        
               29/10/2014 - Ajuste no exclusive-lock da tabela crapepr. (James)
               
               13/11/2014 - Removido display do campo tel_nrseqdig no frame 
                            f_landpv.
                            Motivo: Foi necessario voltar o tamanho do campo
                            de valor (tel_vllanmto) para o seu tamanho original.
                            (Chamado 175752) - (Fabricio)
                            
               02/12/2014 - Inclusao da chamada da solicita_baixa_automatica
                            (Guilherme/SUPERO)
                            
               23/12/2014 - Tratamento incorporacao - registro crapfdc deve
                            ser lido na nova cooperativa (Diego).
                            
               22/01/2015 - Ajustes Projeto BNDS (Daniel).
               
               26/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714)
                            
               05/03/2015 - #257407 Correcao para devolucao de cheques de
                            cooperativas incorporadas (Carlos)

               08/04/2015 - Caso for o banco 756, verificar tambem na crabcop
                            o cdagebcb (Lucas R. #269981)
                            
               29/05/2015 - #281435 Retirada a obrigatoriedade de encerrar a 
                            conta (critica 726) quando a mesma eh lancada para 
                            prejuizo (historico 350) (Carlos)
                            
               16/06/2015 - #281178 Para separar os lançamentos manuais ref. a 
                            cheque compensado e não integrado dos demais 
                            lançamentos, foi criado o historico 1873 com base 
                            no 521. Tratamento p hist 1873 igual ao tratamento 
                            do hist 521 (Carlos)

			         23/06/2015 - Adicionado tratamento para portabilidade de crédito.
                            (Reinert)
                            
               24/06/2015 - #298239 Criacao do log para inclusao de lancamento;
                            Correcao de validate craplot; Logando as criticas
                            da tela (Carlos)
                            
               08/10/2015 - Adicionado mais informacoes no log no momento do pagamento
                            das parcelas de emprestimo. SD 317004 (Kelvin)            
                            
               11/11/2015 - Removido tratamento para o historico 350. 
                            (Reinert/Oscar)
                            
               07/12/2015 - #367740 Criado o tratamento para o historico 1874 
                            assim como eh feito com o historico 1873 (Carlos)

			         15/12/2015 - Corrigido problema referente a descricrao da critica.
                            (Reinert)
                
               21/12/2015 - Utilizar a procedure convertida na bo 2175 para as 
                            validacoes de alinea, conforme revisao de alineas
                            e processo de devolucao de cheque (Douglas - Melhoria 100)

			         12/02/2016 - Ajustes decorrente a homologação do projeto M100
						                (Adriano).

               12/05/2016 - Mudanca para pegar saldo devedor da obtem-dados-emprestimos
                            na b1wgen0002 e nao mais da saldo_epr.p. Cobranca de Multa
                            e Juros de Mora. (Jaison/James)
                          
               11/08/2016 - Verificar o saldo disponivel para os lancamentos dos 
                            historicos(275, 428 e 394) (James)


			         24/08/2016 - Ajuste para passar corretamente o nome da tabela a se verificar o lock 
						                (Adriano - SD 511318 ).
							
               22/09/2016 - Incluido tratamento para verificacao de contrato de 
                            acordo, Prj. 302 (Jean Michel).
                            
			         21/10/2016 - Incluir o historico 384	na listagem dos historicos para verificacao do 
			                      saldo disponivel (Renato Darosci - SD542195).

               31/10/2016 - Bloquear os historicos 354 e 451 para a cooperativa Transulcred. (James)
							
               05/12/2016 - Incorporacao Transulcred (Guilherme/SUPERO)

               10/03/2017 - Incluir buffer craxlcm para efetuar busca do recid e armazenar na variavel
                            global glb_nrdrecid (Lucas Ranghetti #601012)
                            
               24/04/2017 - Nao considerar valores bloqueados na composicao do saldo disponivel
                            Heitor (Mouts) - Melhoria 440

               12/06/2017 - Nao deixar realizar lancamento do historico 1668 - Estorno de débito indevido               
                            na viacredi (Tiago/Fabricio #661260)

              11/07/2017 - Ajustes historico 354
                           (Demetrius Wolff MOUTS - Prj 364)

               10/08/2017 - Somente vamos exibir a critica 728 para casos em que o Tipo do 
                            cartao do titular nao for de um operador isso na leitura da crapcrm 
                            (Lucas Ranghetti #726238)

			  19/11/2017 - Ajustes para retirar o uso do historico 354
                           (Jonata RKAM - P364)

              01/02/2018 - Inserçao da verificaçao e solicitaçao de permissao de uso de saldo bloqueado em pagamento
                            de empréstimo
                           ( Lindon GFT )

			  02/02/2018 - Alteraçao do local de pesquisa do saldo bloqueado por solicitaçao do Sr. Daniel da tabela 
                           crapsld para (aux_vlsdbloq = tt-saldos.vlsdblpr + tt-saldos.vlsdblfp + tt-saldos.vlsdbloq.) 
                           a fim de pegar os valore de alteraçao do dia.
                           ( Lindon GFT )

               08/03/2018 - Substituidas verificacoes pelo campo "cdtipcta" fixos pelo código da modalidade e 
                            flag de conta integraçao. PRJ366 (Lombardi).
				 
               29/05/2018 - Alteraçao INSERT na craplcm pela chamada da rotina LANC0001
                            PRJ450 - Renato Cordeiro ( AMcom )         

               07/08/2019 - Valida número do documento como CHEQUE quando históricos 2991 e 2992 
                            (Renato Cordeiro - AMcom)
............................................................................. */
/*** Historico 351 aceita nossos cheques e de outros bancos ***/

{ sistema/generico/includes/b1wgen0104tt.i }
{ sistema/generico/includes/b1wgen0002tt.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

{ includes/var_online.i }
{ includes/var_landpv.i }
{ includes/var_cmedep.i "NEW" }

{ sistema/generico/includes/b1wgen0200tt.i } /*renato PJ450*/

DEF VAR h-b1wgen0200 AS HANDLE                                  NO-UNDO.

DEF VAR h-b1wgen0001 AS HANDLE                                  NO-UNDO.
DEF VAR h-b1wgen0043 AS HANDLE                                  NO-UNDO.
DEF VAR h-b1wgen0134 AS HANDLE                                  NO-UNDO.
DEF VAR h-b1wgen0140 AS HANDLE                                  NO-UNDO.
DEF VAR h-b1wgen0155 AS HANDLE                                  NO-UNDO.
DEF VAR h-b1wgen0171 AS HANDLE                                  NO-UNDO.
DEF VAR h-b1wgen0002 AS HANDLE                                  NO-UNDO.

DEF VAR tel_nrctatrf         AS INT                             NO-UNDO.
DEF VAR aux_cdlcrbol         AS INT                             NO-UNDO.
DEF VAR aux_dtrefere         AS DATE                            NO-UNDO.
DEF VAR aux_flchcoop         AS LOG FORMAT "Sim/Nao"            NO-UNDO.
DEF VAR aux_cdcopant         AS INT                             NO-UNDO.
DEF VAR aux_nrctaant         AS INT                             NO-UNDO.
DEF VAR aux_flctatco         AS LOG  INIT FALSE                 NO-UNDO.
DEF VAR aux_cdcoptco         AS INT                             NO-UNDO.
DEF VAR aux_nrctatco         AS INT                             NO-UNDO.
DEF VAR aux_vlr_arrasto      AS DEC                             NO-UNDO.
DEF VAR aux_dadosusr         AS CHAR                            NO-UNDO.
DEF VAR aux_sldesblo         AS DEC                             NO-UNDO.
DEF VAR aux_slcotnor         AS DEC                             NO-UNDO.
DEF VAR aux_devchqtic        AS LOG                             NO-UNDO.
DEF VAR aux_nrdrowid         AS ROWID                           NO-UNDO.
DEF VAR aux_qtregist         AS INT                             NO-UNDO.

DEF VAR aux_incrineg         AS INT                             NO-UNDO.
DEF VAR aux_cdcritic         AS INTE                            NO-UNDO.
DEF VAR aux_dscritic         AS CHAR                            NO-UNDO.

DEF VAR par_loginusr         AS CHAR                            NO-UNDO.
DEF VAR par_nmusuari         AS CHAR                            NO-UNDO.
DEF VAR par_dsdevice         AS CHAR                            NO-UNDO.
DEF VAR par_dtconnec         AS CHAR                            NO-UNDO.
DEF VAR par_numipusr         AS CHAR                            NO-UNDO.
DEF VAR aux_vlblqjud         AS DEC                             NO-UNDO.
DEF VAR aux_vlresblq         AS DEC                             NO-UNDO.
DEF VAR aux_flgativo         AS DEC                             NO-UNDO.
DEF VAR aux_cdmodali         AS INT                             NO-UNDO.
DEF VAR aux_idctaitg         AS INT                             NO-UNDO.
DEF VAR aux_des_erro         AS CHAR                            NO-UNDO.

DEF VAR h-b1wgen9999         AS HANDLE                          NO-UNDO.
DEF VAR h-b1wgen0175         AS HANDLE                          NO-UNDO.
        
DEF VAR vr_cdpesqbb AS CHAR  NO-UNDO.
DEF VAR vr_nrctachq AS INT   NO-UNDO.
DEF VAR vr_nrdctabb AS INT   NO-UNDO.
        
DEF BUFFER crabcop FOR crapcop.
DEF BUFFER craxlcm FOR craplcm.
DEF TEMP-TABLE tt-saldos LIKE wt_saldos.

{includes/atualiza_epr.i}

/*** Atualizar crapavs para o caso de lancamento p/ emprestimos vinc. folha */
PROCEDURE p_atualiza_avs:

   DEF VAR pro_dtrefavs AS DATE     NO-UNDO.   
   DEF VAR pro_vlpagmes AS DECIMAL  NO-UNDO.
   DEF VAR pro_cdpesqbb AS DECIMAL  NO-UNDO.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                       
      FIND craplcm WHERE craplcm.cdcooper = glb_cdcooper AND
                         craplcm.dtmvtolt = tel_dtmvtolt AND
                         craplcm.cdagenci = tel_cdagenci AND
                         craplcm.cdbccxlt = tel_cdbccxlt AND
                         craplcm.nrdolote = tel_nrdolote AND
                         craplcm.nrdconta = tel_nrdctabb AND
                         craplcm.nrdocmto = tel_nrdocmto AND
                         craplcm.cdhistor = tel_cdhistor USE-INDEX craplcm1
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF   NOT AVAILABLE craplcm   THEN
           DO:
              IF   LOCKED(craplcm)   THEN
                  DO:
                     ASSIGN glb_cdcritic = 341.
                     RUN fontes/critic.p.

                     MESSAGE glb_dscritic + " - (craplcm)".
                     PAUSE 1.
                     HIDE MESSAGE NO-PAUSE.
                      
                     UNIX SILENT VALUE(
                            "echo " + STRING(glb_dtmvtolt,"99/99/9999") + " - "  +
                            STRING(TIME,"HH:MM:SS")                              + 
                            " - INCLUSAO, p_atualiza_avs " + "'-->' "            +
                            glb_dscritic  + " - (craplcm)"                       +
                            " Operador: " + glb_cdoperad                         +
                            " Hst: "      + STRING(tel_cdhistor)                 +
                            " Conta: "    + TRIM(STRING(tel_nrdctabb,
                                                        "zz,zzz,zzz,z"))         + 
                            " Doc: "      + STRING(tel_nrdocmto)                 +
                            " Lote: "     + TRIM(STRING(tel_nrdolote,"zzz,zz9")) + 
                            " PA:  "      + STRING(tel_cdagenci,"999")           + 
                            " Banco/Caixa: " + STRING(tel_cdbccxlt,"999")        + 
                            " >> log/landpv.log").

                     ASSIGN glb_cdcritic = 0
					        glb_dscritic = "".
                     NEXT.
                  END.
           END.

      ASSIGN craplcm.cdpesqbb = craplcm.cdpesqbb + ";".
      
      LEAVE. 

   END.

   ASSIGN pro_cdpesqbb = 0.

   IF   CAN-FIND(crapfol WHERE crapfol.cdcooper = glb_cdcooper   AND
                               crapfol.nrdconta = tel_nrdctabb   AND
                               crapfol.dtrefere = glb_dtultdia NO-LOCK)  THEN
        ASSIGN pro_dtrefavs = glb_dtultdia.
   ELSE
        ASSIGN pro_dtrefavs = glb_dtultdma.

   IF   his_cdhistor = 88   OR   his_cdhistor = 507   THEN
        DO:
            TRANS_1: 
           
            FOR EACH crapavs WHERE crapavs.cdcooper =  glb_cdcooper AND
                                   crapavs.dtrefere >= pro_dtrefavs AND
                                   crapavs.nrdconta =  tel_nrdctabb AND
                                   crapavs.cdhistor =  108          AND
                                   crapavs.nrdocmto =  his_nrctremp AND
                                   crapavs.vldebito >  0            
                                   EXCLUSIVE-LOCK BY crapavs.dtrefere 
                                   DESCENDING:
            
                IF   crapavs.insitavs = 0   THEN
                     DO: 
                         IF CAN-FIND(crapfol WHERE 
                                     crapfol.cdcooper = crapavs.cdcooper   AND
                                     crapfol.cdempres = crapavs.cdempres   AND
                                     crapfol.dtrefere = crapavs.dtrefere   AND
                                     crapfol.nrdconta = crapavs.nrdconta)  THEN
                            DO:
                               ASSIGN glb_cdcritic = 692.
                               RUN fontes/critic.p.
                               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                  ASSIGN aux_confirma = "N".
                                  BELL.
                                  MESSAGE glb_dscritic "Confirma Operacao ?"
                                          UPDATE aux_confirma.
                                  LEAVE.        
                               END.
                                     
                               glb_cdcritic = 0. 
							   glb_dscritic = "". 

                               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                                    aux_confirma <> "S"              THEN
                                    DO:
                                       ASSIGN glb_cdcritic = 79.
                                       RETURN "NOK".
                                    END.
                            END. /* IF CAN-FIND(crapfol... */
                         
                         IF   tel_vllanmto > crapavs.vldebito   THEN
                              DO:
                                  ASSIGN glb_cdcritic = 877.
                                  RUN fontes/critic.p.
                                  BELL.
                                  MESSAGE glb_dscritic STRING(crapavs.vldebito, 
                                                              "zz,zzz,zz9.99"). 
                                  PAUSE.          
                                  HIDE MESSAGE NO-PAUSE.
                                  ASSIGN glb_cdcritic = 79.
                                  RETURN "NOK".
                              END.
                         ELSE
                              DO:
                                  ASSIGN crapavs.vldebito =
                                               crapavs.vldebito - tel_vllanmto
                                         pro_cdpesqbb     = tel_vllanmto.

                                  UNIX SILENT VALUE("echo " + 
                                       STRING(glb_dtmvtolt,"99/99/9999") + 
                                       " - " + STRING(TIME,"HH:MM:SS") +
                                       " - LANCAMENTO EMPRESTIMO ' --> '"  +
                                       " Operador: " + glb_cdoperad +
                                       " Hst: " + STRING(tel_cdhistor,"zzz9") +
                                       " Conta: " + 
                                       STRING(crapavs.nrdconta, "zzzz,zz9,9") +
                                       " Contrato: " + 
                                       STRING(his_nrctremp, "zzz,zzz,zz9") +
                                       " Valor: " + 
                                       STRING(tel_vllanmto, 
                                                       "zzz,zzz,zzz,zz9.99") +
                                       " PERGUNTA '->' " + glb_dscritic + 
                                       " Confirma Operacao'?' " +
                                       " Operador respondeu: SIM" +
                                       " >> log/landpv.log").
                              END.
                                              
                     END.  /* IF crapavs.insitavs = 0 */
                ELSE               
                     DO:
                        ASSIGN pro_vlpagmes = 0.
                        FOR EACH craplem WHERE 
                                     craplem.cdcooper = crapavs.cdcooper AND
                                     craplem.dtmvtolt > crapavs.dtrefere AND
                                     craplem.nrdconta = crapavs.nrdconta AND
                                     craplem.nrctremp = INT64(crapavs.nrdocmto)
                                     NO-LOCK:

                            IF   craplem.cdhistor = 91  OR /* Pagto LANDPV  */
                                 craplem.cdhistor = 95  OR /* Pagto crps120 */
                                 craplem.cdhistor = 393 OR /* Pagto Avalista */
                                 craplem.cdhistor = 353 THEN /* Transf. Cotas */
                                 ASSIGN pro_vlpagmes = pro_vlpagmes +
                                                            craplem.vllanmto.
                            ELSE
                            IF   craplem.cdhistor = 88  OR
                                 craplem.cdhistor = 507 THEN /*Est.Transf.Cot*/
                                 ASSIGN pro_vlpagmes = pro_vlpagmes -
                                                              craplem.vllanmto.
                        END. /* FOR EACH craplem... */
                        
                        IF crapavs.dtrefere > pro_dtrefavs  THEN
                           DO:
                              ASSIGN crapavs.vldebito = 0 
                                     crapavs.vlestdif = 0
                                     crapavs.insitavs = 0
                                     pro_cdpesqbb     = tel_vllanmto.
                              
                              NEXT.       
                           END.
                        ELSE
                        IF (pro_vlpagmes - tel_vllanmto) < crapavs.vllanmto THEN
                            DO:
                               ASSIGN glb_cdcritic = 877.
                               RUN fontes/critic.p.
                               BELL.
                               MESSAGE glb_dscritic 
                                       STRING(pro_vlpagmes - crapavs.vllanmto, 
                                              "zz,zzz,zz9.99"). 
                               PAUSE.          
                               HIDE MESSAGE NO-PAUSE.
                               ASSIGN glb_cdcritic = 79.
                               UNDO TRANS_1, RETURN "NOK".
                            END. 
                     END.
                 
                ASSIGN crapavs.vlestdif = crapavs.vldebito - crapavs.vllanmto
                       crapavs.insitavs = 
                                      IF crapavs.vllanmto <= crapavs.vldebito
                                         THEN 1
                                         ELSE 0
                       craplcm.cdpesqbb = craplcm.cdpesqbb +  
                                          STRING(pro_cdpesqbb, "zzzzzzzz9.99").
                                      
                RETURN "OK".
            
            END. /* FOR EACH crapavs.... */
            
            IF   tel_cdhistor = 317   AND
                 crapepr.flgpagto     AND
                 crapepr.qtmesdec    < 0  THEN
                 DO:
                     .
                 END.    
            ELSE DO:   
               ASSIGN glb_cdcritic = 877.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic STRING(0.0, "zz,zzz,zz9.99"). 
               PAUSE.          
               HIDE MESSAGE NO-PAUSE.
               ASSIGN glb_cdcritic = 79.
               RETURN "NOK".
           END.
        END.
   ELSE  
        FOR EACH crapavs WHERE crapavs.cdcooper =  glb_cdcooper AND
                               crapavs.dtrefere >= pro_dtrefavs AND
                               crapavs.nrdconta =  tel_nrdctabb AND
                               crapavs.cdhistor =  108          AND
                               crapavs.nrdocmto =  his_nrctremp AND
                               crapavs.insitavs =  0
                               EXCLUSIVE-LOCK BY crapavs.dtrefere:
                                      
            IF   NOT CAN-FIND(crapfol WHERE 
                                      crapfol.cdcooper = crapavs.cdcooper AND
                                      crapfol.dtrefere = crapavs.dtrefere AND
                                      crapfol.cdempres = crapavs.cdempres AND
                                      crapfol.nrdconta = crapavs.nrdconta) THEN
                 DO: 

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                       ASSIGN aux_confirma = "N".
                       BELL.
                       MESSAGE "Existe um aviso de debito para o"
                               "proximo credito de folha.".
                       MESSAGE "Voce deseja baixar este aviso com este"
                               "lancamento ?" UPDATE aux_confirma.
                       LEAVE.        

                    END.
                                     
                    ASSIGN glb_cdcritic = 0
					       glb_dscritic = "". 

                    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                         RETURN "NOK".
                    ELSE
                    IF   aux_confirma = "N"   THEN
                         RETURN "OK".
                    ELSE
                         DO:
                            IF   (crapavs.vldebito + tel_vllanmto) > 
                                                     crapavs.vllanmto   THEN
                                  pro_cdpesqbb = crapavs.vllanmto - 
                                                           crapavs.vldebito.
                            ELSE
                                  pro_cdpesqbb = tel_vllanmto.

                            ASSIGN crapavs.vldebito = 
                                           crapavs.vldebito + tel_vllanmto.
                                           
                            IF   crapavs.vldebito > crapavs.vllanmto THEN
                                 crapavs.vldebito = crapavs.vllanmto.
                                 
                            UNIX SILENT VALUE("echo " + 
                                  STRING(glb_dtmvtolt,"99/99/9999") + " - " +
                                  STRING(TIME,"HH:MM:SS") +
                                  " - LANCAMENTO EMPRESTIMO ' --> '"  +
                                  " Operador: " + glb_cdoperad +
                                  " Hst: " + STRING(tel_cdhistor,"zzz9") +
                                  " Conta: " + 
                                  STRING(crapavs.nrdconta, "zzzz,zz9,9") +
                                  " Contrato: " + 
                                  STRING(his_nrctremp, "zzz,zzz,zz9") +
                                  " Valor: " + 
                                  STRING(tel_vllanmto, "zzz,zzz,zzz,zz9.99") +
                                  " PERGUNTA '->' " +        
                                  "Existe um aviso de debito para o " +
                                  "proximo credito de folha. " +
                                  "Voce deseja baixar este aviso com " +
                                  "este lancamento'?' " + 
                                  "Operador respondeu: SIM" +
                                  " >> log/landpv.log").
                         END.
                 END.
            ELSE
            IF   tel_vllanmto > (crapavs.vllanmto - crapavs.vldebito) THEN
                 DO: 
                     ASSIGN glb_cdcritic = 875.
                                    
                     RUN fontes/critic.p.
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                        ASSIGN aux_confirma = "N".
                        BELL.
                        MESSAGE glb_dscritic "Confirma Operacao ?"
                                UPDATE aux_confirma.
                        LEAVE.        
                                
                     END.        

                     ASSIGN glb_cdcritic = 0
					        glb_dscritic = "". 

                     IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                          aux_confirma <> "S" THEN
                          DO:
                             ASSIGN glb_cdcritic = 79.
                             RETURN "NOK".
                          END.
                                                   
                     ASSIGN pro_cdpesqbb = crapavs.vllanmto - crapavs.vldebito
                            crapavs.vldebito = crapavs.vllanmto.
                 END. /*IF Valor lanmto > do que devido */
            ELSE
                 ASSIGN crapavs.vldebito = crapavs.vldebito + tel_vllanmto
                        pro_cdpesqbb     = tel_vllanmto.
                           
            ASSIGN crapavs.vlestdif = crapavs.vldebito - crapavs.vllanmto
                   crapavs.insitavs = IF crapavs.vllanmto <= crapavs.vldebito
                                           THEN 1
                                           ELSE 0
                   craplcm.cdpesqbb = craplcm.cdpesqbb +  
                                      STRING(pro_cdpesqbb, "zzzzzzzz9.99").
            
            RETURN "OK".                          
                                    
        END. /* FOR EACH crapavs... */
                                           
   RETURN "OK".
END PROCEDURE.


/*  Le tabela com o valor dos cheques maiores  */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "USUARI"      AND
                   craptab.cdempres = 11            AND
                   craptab.cdacesso = "MAIORESCHQ"  AND
                   craptab.tpregist = 1             NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     tab_vlchqmai = 1.
ELSE
     tab_vlchqmai = DECIMAL(SUBSTRING(craptab.dstextab,01,15)).

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         NEXT.
     END.
                           
FIND crapage WHERE crapage.cdcooper = crapcop.cdcooper AND
                   crapage.cdagenci = tel_cdagenci     NO-LOCK NO-ERROR.
IF   NOT AVAILABLE crapage   THEN   
     DO:
         glb_cdcritic = 962.
         NEXT.
     END.   

INICIO:
DO WHILE TRUE ON ERROR UNDO, NEXT.

   RUN fontes/inicia.p.
   PAUSE(0).
   ASSIGN aux_vlrdifer = 0 
          aux_nrsqcomp = 0   
          aux_mensagem = ""
          aux_flctatco = FALSE.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      CLEAR FRAME f_cmedep ALL.
      CLEAR FRAME f_compel ALL.
      CLEAR FRAME f_lanctos_compel ALL.
      HIDE  FRAME f_compel.
      HIDE  FRAME f_lanctos_compel.
      HIDE  FRAME f_autentica.
      HIDE  FRAME f_cmedep.
      HIDE  FRAME f_nrctremp.
      PAUSE(0).
      
      IF   glb_cdcritic <> 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
     
               IF  LENGTH(TRIM(glb_dscricpl)) > 0 THEN 
                   glb_dscritic = glb_dscritic + glb_dscricpl.
               
               MESSAGE glb_dscritic.

               /* logar criticas de uso */
               UNIX SILENT VALUE(
                    "echo " + STRING(glb_dtmvtolt,"99/99/9999") + " - " +
                    STRING(TIME,"HH:MM:SS")                             + 
                    " - CRITICA INCLUSAO " + "'     -->'"               +

                    " Operador: " + glb_cdoperad                        +

                    " PA:  "      + STRING(tel_cdagenci,"999")          + 
                    " Banco/Caixa: " + STRING(tel_cdbccxlt,"999")       +  
                    " Lote: "     + TRIM(STRING(tel_nrdolote,"zzz,zz9")) +

                    " Hst: "      + STRING(tel_cdhistor)                 +
                    " Conta: "    + TRIM(STRING(tel_nrdctabb,
                                             "zz,zzz,zzz,z"))            + 
                    " Bco: "      + STRING(tel_cdbaninf,"9999")          + 
                    " Age:  "     + STRING(tel_cdageinf,"9999")          + 
                    " Doc: "      + STRING(tel_nrdocmto)                 +
                    " Valor: "    + TRIM(STRING(tel_vllanmto,
                                             "zzzzzz,zzz,zz9.99"))       +
                    
                    " Contrato: " + STRING(tel_nrctremp)                 +

                    " Critica: "  + glb_dscritic                         +
                    " >> log/landpv.log").

               ASSIGN glb_cdcritic = 0
                      glb_dscritic = "".
           END.
      
      UPDATE tel_cdhistor tel_nrdctabb tel_cdbaninf tel_cdageinf tel_nrdocmto 
             tel_vllanmto tel_dtliblan tel_cdalinea WITH FRAME f_landpv
      
      EDITING:
              IF   FRAME-FIELD = "tel_cdhistor"   THEN
                    DO:
                        READKEY.
                        APPLY LASTKEY.
                    END.
               ELSE     
               IF   FRAME-FIELD = "tel_dtliblan"   THEN
                    IF CAN-DO("2,6,403,404",STRING(INPUT tel_cdhistor))   THEN
                       DO:
                           READKEY.
                           APPLY LASTKEY.
                       END.
                    ELSE
                         APPLY 13.
               ELSE
               IF   FRAME-FIELD = "tel_cdalinea"    THEN
                    IF   (INPUT tel_cdhistor = 24   OR
                          INPUT tel_cdhistor = 27   OR
                          INPUT tel_cdhistor = 47   OR
                          INPUT tel_cdhistor = 78   OR
                          INPUT tel_cdhistor = 156  OR
                          INPUT tel_cdhistor = 191  OR
                          INPUT tel_cdhistor = 351  OR
                          INPUT tel_cdhistor = 399) THEN
                         DO:
                             READKEY.
                             APPLY LASTKEY.
                         END.
                    ELSE
                         APPLY 13.
               ELSE
                    DO:
                        READKEY.
                        IF   FRAME-FIELD = "tel_vllanmto"   THEN
                             IF   LASTKEY =  KEYCODE(".")   THEN
                                  APPLY 44.
                             ELSE
                                  APPLY LASTKEY.
                        ELSE
                             APPLY LASTKEY.
                    END.

      END. /* Fim EDITING */

      RUN sistema/generico/procedures/b1wgen0134.p PERSISTENT SET h-b1wgen0134.
      
      RUN valida_historico IN h-b1wgen0134(INPUT tel_cdhistor).

      DELETE PROCEDURE h-b1wgen0134.
                                         
      IF   RETURN-VALUE = "OK" THEN
           DO:
               MESSAGE "Historico nao permitido.".
               PAUSE 3 NO-MESSAGE.
               NEXT.
           END.

      IF   glb_cdcooper = 17 AND CAN-DO("354,451",STRING(tel_cdhistor)) THEN
           DO:
               MESSAGE "Historico nao disponivel.".
               PAUSE 3 NO-MESSAGE.
               NEXT.
           END.
           
      IF   CAN-FIND(FIRST crapfvl WHERE crapfvl.cdhistor = tel_cdhistor 
                             NO-LOCK) OR
           CAN-FIND(FIRST crapfvl WHERE crapfvl.cdhisest = tel_cdhistor 
                             NO-LOCK) THEN
           DO: 
                MESSAGE "Historico nao permitido.".
                PAUSE 3 NO-MESSAGE.
                NEXT.
           END. 

      IF   tel_cdhistor = 585   THEN
           DO:
               MESSAGE "Para o historico 585 deve ser utilizado a LANDEB.".
               PAUSE 3 NO-MESSAGE.
               NEXT.
           END.
   
      /* 1668 - Estorno de débito indevido. */     
      IF  glb_cdcooper = 1 AND tel_cdhistor = 1668 THEN
          DO:
               MESSAGE "Historico nao permitido. Consulte a sede da cooperativa.".
               PAUSE 3 NO-MESSAGE.
               NEXT.
          END.
   
      IF   CAN-DO ("3,4",STRING(tel_cdhistor))   THEN
           DO:
               MESSAGE 
                   "Para o historico 3 e 4 deve ser utilizado o Caixa Online.".
               PAUSE 3 NO-MESSAGE.
               NEXT.
           END.

      /*  Formata conta integracao  */            
      RUN fontes/digbbx.p (INPUT  tel_nrdctabb,
                           OUTPUT glb_dsdctitg,
                           OUTPUT glb_stsnrcal).

      IF   tel_cdhistor = 483   THEN
           DO:
               FIND crapsli WHERE crapsli.cdcooper  = glb_cdcooper          AND
                                  crapsli.nrdconta  = tel_nrdctabb          AND
                            MONTH(crapsli.dtrefere) = MONTH(glb_dtmvtolt)   AND
                             YEAR(crapsli.dtrefere) = YEAR(glb_dtmvtolt)  
                                  NO-LOCK NO-ERROR.
      
               IF   (NOT AVAILABLE crapsli)                   OR
                    (crapsli.vlsddisp - tel_vllanmto < 0)     THEN
                    DO:
      
                        MESSAGE "ATENCAO! O saldo da CONTA DE INVESTIMENTO" 
                                "ficara NEGATIVO!"        VIEW-AS ALERT-BOX.
                                     
                        RUN fontes/pedesenha.p (INPUT glb_cdcooper,
                                                INPUT 2, 
                                                OUTPUT aut_flgsenha,
                                                OUTPUT aut_cdoperad).
                                                                                 
                        IF   aut_flgsenha    THEN
                             DO:
                                 UNIX SILENT VALUE("echo " + 
                                              STRING(glb_dtmvtolt,"99/99/9999")
                                              + " - " +
                                              STRING(TIME,"HH:MM:SS") +
                                              " - AUTORIZACAO - CONTA " + 
                                              "DE INVESTIMENTO" + 
                                              "' --> '" +
                                              " Operador: " + aut_cdoperad +
                                              " Conta: " +
                                              STRING(tel_nrdctabb,"zzzz,zzz,9")
                                              + " Valor: " +
                                              STRING(tel_vllanmto,
                                                     "zzz,zzz,zzz,zz9.99") +
                                              " >> log/landpv.log").
                             END.
                        ELSE
                             NEXT.
                    END.
           END.
            
      /*  Trata transferencia de valores entre contas-corrente - Edson  */
      IF   CAN-DO("104,302,1806",STRING(tel_cdhistor))   THEN
           DO:
               tel_nrctatrf = 0.
               
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  IF   glb_cdcritic > 0   THEN
                       DO:
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic.
                           glb_cdcritic = 0.
						   glb_dscritic = "".
                       END.
                  
                  UPDATE SKIP(1)
                         tel_nrctatrf FORMAT "zzzz,zzz,9"
                                      LABEL "  Conta do favorecido" " "
                         SKIP(1)
                         WITH ROW 15 CENTERED SIDE-LABELS OVERLAY 
                              TITLE COLOR NORMAL " Transferencia de valores "
                              FRAME f_trfval.
               
                  IF   tel_nrctatrf = 0              OR
                       tel_nrctatrf = tel_nrdctabb   THEN
                       DO:
                           glb_cdcritic = 127.
                           NEXT.
                       END.
                   
                  RUN fontes/testa_conta.p (INPUT  glb_cdcooper,
                                            INPUT  tel_nrdctabb,
                                            INPUT  tel_nrctatrf,
                                            INPUT  tel_cdhistor,
                                            OUTPUT glb_cdcritic).
               
                  IF   glb_cdcritic > 0   THEN
                       NEXT.
                  
                  LEAVE.
               
               END.  /*  Fim do DO WHILE TRUE  */

               HIDE FRAME f_trfval NO-PAUSE.
 
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                    glb_cdcritic > 0                     THEN
                    DO:
                        NEXT-PROMPT tel_cdhistor WITH FRAME f_landpv.
                        NEXT.
                    END.
           END.
           
      HIDE MESSAGE NO-PAUSE.
    
      ASSIGN aux_cdhistor = tel_cdhistor  aux_nrdctabb = tel_nrdctabb
             aux_nrdocmto = tel_nrdocmto  aux_vllanmto = tel_vllanmto
             aux_dtliblan = tel_dtliblan  aux_cdalinea = tel_cdalinea
             aux_vlsdchsl = 0             aux_vlsdbloq = 0
             aux_vlsdblpr = 0             aux_vlsdblfp = 0
             aux_nrtrfcta = 0             glb_cdcritic = 0
             tel_vlcompel = 0             tel_dsdocmc7 = ""
             tel_nrautdoc = 0             aux_flchcoop = NO
			 glb_dscritic = "".
      
      IF   tel_cdhistor <> ant_cdhistor OR
           tel_nrdctabb <> ant_nrdctabb OR
           tel_nrdocmto <> ant_nrdocmto THEN 
           DO:
               ASSIGN aux_vlttcomp = 0
                      aux_maischeq = 0.
               
               EMPTY TEMP-TABLE w-compel.
           END.
     
      ASSIGN ant_cdhistor = tel_cdhistor
             ant_nrdctabb = tel_nrdctabb
             ant_nrdocmto = tel_nrdocmto.
      
      IF   tel_cdhistor = 23   THEN
           DO:
               FIND crapass WHERE crapass.cdcooper = glb_cdcooper   AND
                                  crapass.nrdconta = tel_nrdctabb 
                                  NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE crapass   THEN
                    DO:
                        glb_cdcritic = 9.
                        NEXT-PROMPT tel_nrdctabb WITH FRAME f_landpv.
                        NEXT.
                    END.   
              ASSIGN aux_nrdconta = crapass.nrdconta.     
         END.
         
      FIND craphis WHERE
           craphis.cdcooper = glb_cdcooper AND
           craphis.cdhistor = tel_cdhistor NO-LOCK NO-ERROR.

      IF   NOT AVAILABLE craphis   THEN
           DO:
               glb_cdcritic = 93.
               NEXT-PROMPT tel_cdhistor WITH FRAME f_landpv.
               NEXT.
           END.
      ELSE
      IF   craphis.tplotmov <> 1   THEN
           DO:
               glb_cdcritic = 94.
               NEXT-PROMPT tel_cdhistor WITH FRAME f_landpv.
               NEXT.
           END.
      ELSE      
      IF   tel_cdhistor = 351  AND
           tel_cdalinea <> 0   THEN
           DO:
                IF   NOT CAN-FIND (crapali WHERE crapali.cdalinea = 
                                                 tel_cdalinea) THEN
                     DO:
                         glb_cdcritic = 412.
                         NEXT-PROMPT tel_cdalinea WITH FRAME f_landpv.
                         NEXT.
                     END.
           END.
       ELSE
       IF tel_cdhistor = 127 OR tel_cdhistor = 451 THEN
       DO:
           ASSIGN glb_cdcritic = 93.
           NEXT-PROMPT tel_cdhistor WITH FRAME f_landpv.
           NEXT.
       END.
                                
      IF   (tel_cdhistor = 24  OR tel_cdhistor = 27  OR tel_cdhistor = 47   OR
            tel_cdhistor = 78  OR tel_cdhistor = 156 OR tel_cdhistor = 191  OR 
            tel_cdhistor = 399) AND
           (tel_cdalinea > 999  OR
           NOT CAN-FIND (crapali WHERE crapali.cdalinea = tel_cdalinea)) THEN
           DO: 
               glb_cdcritic = 412.
               NEXT-PROMPT tel_cdalinea WITH FRAME f_landpv.
               NEXT.
           END.
      ELSE
      DO:
          IF   tel_cdhistor = 351  THEN
               DO:
                   IF   tel_cdalinea = 0    THEN
                        DO:
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                               aux_confirma = "N".
                               BELL.
                               MESSAGE "Devolucao com Alinea Zerada." +
                                       " Deseja continuar?"
                                       UPDATE aux_confirma.
                               glb_cdcritic = 0. 
							   glb_dscritic = "".
                               LEAVE.
                            END.

                            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                                 aux_confirma <> "S" THEN
                                 DO:
                                     glb_cdcritic = 79.
                                     NEXT-PROMPT tel_cdalinea 
                                                 WITH FRAME f_landpv.
                                     LEAVE.
                                 END.
                        END.

               END.
          
          IF   tel_cdhistor = 351   OR
               tel_cdhistor = 399   THEN
               /** Pergunta se o cheque e nosso ou de outro banco **/
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  aux_flchcoop = NO.
                  BELL.
                  MESSAGE "Cheque DEVOLVIDO e da COOPERATIVA?" 
                          UPDATE aux_flchcoop.
                  glb_cdcritic = 0. 
				  glb_dscritic = "".
                  LEAVE.
               END.
  
          ASSIGN glb_nrcalcul = tel_nrdctabb
                 aux_indebcre = craphis.indebcre
                 aux_inhistor = craphis.inhistor.

          RUN fontes/digfun.p.
          IF   NOT glb_stsnrcal   THEN
               DO:
                   glb_cdcritic = 8.
                   NEXT-PROMPT tel_nrdctabb WITH FRAME f_landpv.
                   NEXT.
               END.
          ELSE
          IF   tel_nrdocmto = 0   THEN
               DO:
                   glb_cdcritic = 22.
                   NEXT-PROMPT tel_nrdocmto WITH FRAME f_landpv.
                   NEXT.
               END.
          ELSE
          DO: 
              IF  (tel_cdhistor = 351 AND aux_flchcoop = YES) 
                   OR
                  (tel_cdhistor = 399 AND aux_flchcoop = YES) 
                   OR
                  (tel_cdhistor = 21  OR tel_cdhistor = 24    OR
                   tel_cdhistor = 27  OR tel_cdhistor = 47    OR
                   tel_cdhistor = 49  OR tel_cdhistor = 156   OR
                   tel_cdhistor = 191 OR tel_cdhistor = 521   OR
                   tel_cdhistor = 621 OR tel_cdhistor = 1873  OR
                   tel_cdhistor = 1874 OR tel_cdhistor = 2991 OR
                   tel_cdhistor = 2992)  THEN                   DO:
                       IF (tel_cdhistor = 2991 OR tel_cdhistor = 2992) THEN DO:
                         ASSIGN aux_nrdconta = tel_nrdctabb.
                       END.
                       ASSIGN glb_nrchqsdv = INT(SUBSTR(STRING(tel_nrdocmto,
                                                    "9999999"),1,6))
                              glb_nrchqcdv = tel_nrdocmto.
                        
                       FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper   AND
                                          crapfdc.cdbanchq = tel_cdbaninf   AND
                                          crapfdc.cdagechq = tel_cdageinf   AND
                                          crapfdc.nrctachq = tel_nrdctabb   AND
                                          crapfdc.nrcheque = glb_nrchqsdv
                                          USE-INDEX crapfdc1 NO-LOCK NO-ERROR.

                       IF   AVAILABLE crapfdc  THEN
                            DO:
                                /*  Verifica se esta cadastrado no TCO  */
                                FIND FIRST crabcop WHERE crabcop.cdagectl = tel_cdageinf 
                                     NO-LOCK NO-ERROR.
                                FIND craptco WHERE 
                                     craptco.cdcooper = glb_cdcooper AND
                                     (craptco.nrdconta = tel_nrdctabb OR craptco.nrctaant = tel_nrdctabb) AND
                                     craptco.tpctatrf = 1            AND
                                     craptco.flgativo = TRUE         AND
                                     craptco.cdcopant = crabcop.cdcooper
                                     NO-LOCK NO-ERROR.

                                aux_nrdconta = crapfdc.nrdconta.
                                
                                IF   crapfdc.tpcheque <> 1 THEN
                                     glb_cdcritic = 646.
                                ELSE
                                IF (tel_cdhistor = 2991 OR tel_cdhistor = 2992) AND
                                   (crapfdc.dtliqchq = ? OR crapfdc.dtemschq = ? OR crapfdc.dtretchq = ?) THEN
                                    glb_cdcritic = 108.
                            END.
                       ELSE
                            DO:  
                                /*  Verifica se esta cadastrado no TCO  */
                                /* TCO valido para Banco 756 e 85 */
                                FIND FIRST crabcop WHERE crabcop.cdagectl = tel_cdageinf 
                                                         NO-LOCK NO-ERROR.

                                IF  NOT AVAIL crabcop THEN
                                    FIND FIRST crabcop WHERE crabcop.cdagebcb = tel_cdageinf  
                                                             NO-LOCK NO-ERROR.

                                FIND craptco WHERE 
                                     craptco.cdcooper = glb_cdcooper AND
                                     (craptco.nrdconta = tel_nrdctabb OR craptco.nrctaant = tel_nrdctabb) AND
                                     craptco.tpctatrf = 1            AND
                                     craptco.flgativo = TRUE         AND
                                     craptco.cdcopant = crabcop.cdcooper
                                     NO-LOCK NO-ERROR.

                                IF  AVAILABLE craptco THEN
                                    DO:    
                                        /* Se for conta incorporada deve ler o
                                           registro crapfdc na coop. nova */

                          IF NOT (tel_cdhistor = 2991 OR tel_cdhistor = 2992) THEN DO:
                          IF  craptco.cdcopant = 4  OR
                              craptco.cdcopant = 15 OR
                              craptco.cdcopant = 17 THEN DO:

                              FIND FIRST crapfdc
                                   WHERE crapfdc.cdcooper = craptco.cdcooper
                                     AND crapfdc.cdbanchq = tel_cdbaninf
                                     AND crapfdc.cdagechq = tel_cdageinf
                                     AND crapfdc.nrctachq = craptco.nrctaant
                                     AND crapfdc.nrcheque = glb_nrchqsdv
                                                     USE-INDEX crapfdc1 NO-LOCK NO-ERROR.

                                                IF  AVAIL crapfdc THEN
                                                    DO:
                                                        aux_nrdconta = crapfdc.nrdconta.

                                                        IF  crapfdc.tpcheque <> 1 THEN
                                                            glb_cdcritic = 646.
                                                    END.
                                                ELSE            
                                                    glb_cdcritic = 108.   
                                            END.
                                        ELSE
                                            DO:  
                                                FIND crapfdc WHERE 
                                                     crapfdc.cdcooper = craptco.cdcopant AND
                                                     crapfdc.cdbanchq = tel_cdbaninf     AND
                                                     crapfdc.cdagechq = tel_cdageinf     AND
                                                     crapfdc.nrdconta = craptco.nrctaant AND
                                                     crapfdc.nrcheque = glb_nrchqsdv
                                                     USE-INDEX crapfdc2 NO-LOCK NO-ERROR.

                                                IF   AVAILABLE crapfdc THEN
                                                     DO:
                                                        IF  crapfdc.tpcheque <> 1 THEN
                                                            glb_cdcritic = 646.
                                                        ELSE
                                                            ASSIGN aux_flctatco = YES
                                                                   aux_nrdconta =
                                                                      craptco.nrdconta
                                                                   tel_nrdctabb = 
                                                                      craptco.nrctaant. 
                                                     END.
                                                ELSE          
                                                    glb_cdcritic = 108.
                                           
                                            END.
                                    END.
                                ELSE    
                                     DO:   
                                         /* Verifica Cta.ITG - TCO */
                                         FIND craptco WHERE
                                              craptco.cdcooper = glb_cdcooper AND
                                              craptco.tpctatrf = 1            AND
                                              craptco.flgativo = TRUE         AND
                                              craptco.nrdctitg = 
                                              STRING(tel_nrdctabb,"99999999")
                                              NO-LOCK NO-ERROR.

                                         IF   AVAILABLE craptco THEN
                                              DO: 
                                                  FIND crapfdc WHERE 
                                                       crapfdc.cdcooper = 
                                                          craptco.cdcopant AND
                                                       crapfdc.cdbanchq = 
                                                          tel_cdbaninf     AND
                                                       crapfdc.cdagechq = 
                                                          tel_cdageinf     AND
                                                       crapfdc.nrctachq = 
                                                          tel_nrdctabb     AND
                                                       crapfdc.nrcheque = 
                                                          glb_nrchqsdv
                                                  USE-INDEX crapfdc1 
                                                  NO-LOCK NO-ERROR.

                                                  IF AVAILABLE crapfdc THEN
                                                     DO:
                                                         IF  crapfdc.tpcheque 
                                                             <> 1 THEN
                                                             glb_cdcritic = 646.
                                                         ELSE
                                                           ASSIGN
                                                          aux_flctatco = YES
                                                          aux_nrdconta =
                                                              craptco.nrdconta.
                                                     END.
                                                  ELSE        
                                                      glb_cdcritic = 108. 
                                              END.
                                         ELSE                   
                                              glb_cdcritic = 108.  
                                              
                                     END.                
                            END.         
                          END.

                       IF   glb_cdcritic <> 0 THEN
                            DO:
                                NEXT-PROMPT tel_nrdocmto 
                                            WITH FRAME f_landpv.
                                NEXT.
                            END.
                            
                       IF   NOT aux_flctatco                AND
                            tel_cdbaninf = crapcop.cdbcoctl AND
                           (tel_cdhistor =  47              OR
                            tel_cdhistor = 191)             THEN
                            DO:
                                FIND LAST craplcm WHERE
                                     craplcm.cdcooper =  glb_cdcooper     AND
                                     craplcm.nrdconta =  tel_nrdctabb     AND
                                     craplcm.dtmvtolt >= glb_dtmvtoan     AND
                                     CAN-DO("524,572",
                                             STRING(craplcm.cdhistor))    AND
                                     craplcm.nrdocmto =  tel_nrdocmto
                                     USE-INDEX craplcm2 NO-LOCK NO-ERROR.

                                IF   AVAILABLE craplcm THEN
                                     DO:
                                         MESSAGE "Este lancamento somente " +
                                                 "podera ser realizado "    +
                                                 "pela tela DEVOLU.".
                                         PAUSE 20 NO-MESSAGE.
                                         glb_cdcritic = 79.
                                         NEXT-PROMPT tel_nrdocmto
                                         WITH FRAME f_landpv.
                                         NEXT.
                                     END.
                            END.
                       ELSE
                       IF tel_cdhistor = 2991 OR tel_cdhistor = 2992 THEN
                            DO:
                                FIND LAST craplcm WHERE
                                     craplcm.cdcooper =  glb_cdcooper     AND
                                     craplcm.nrdconta =  tel_nrdctabb     AND
                                     craplcm.nrdocmto =  tel_nrdocmto
                                     USE-INDEX craplcm2 NO-LOCK NO-ERROR.

                                IF   NOT AVAILABLE craplcm THEN
                                     DO:
                                        FIND LAST crapchd WHERE
                                             crapchd.cdcooper =  glb_cdcooper     AND
                                             crapchd.nrdconta =  tel_nrdctabb     AND
                                             crapchd.nrcheque =  tel_nrdocmto
                                             USE-INDEX crapchd2 NO-LOCK NO-ERROR.
                                        IF   NOT AVAILABLE crapchd THEN
                                          DO:
                                             MESSAGE "Cheque nao localizado.".
                                             PAUSE 20 NO-MESSAGE.
                                             glb_cdcritic = 244.
                                             NEXT-PROMPT tel_nrdocmto
                                             WITH FRAME f_landpv.
                                             NEXT.
                   END.
                                     END.
                            END.
                   END.
              ELSE
              IF   tel_cdhistor = 59  OR
                   tel_cdhistor = 77  OR
                   tel_cdhistor = 78  THEN     
                   DO:
                       ASSIGN glb_nrchqsdv =
                                  INT(SUBSTR(STRING(tel_nrdocmto,
                                                    "9999999"),1,6))
                              glb_nrchqcdv = tel_nrdocmto.
 
                       FIND crapfdc WHERE 
                            crapfdc.cdcooper = glb_cdcooper   AND
                            crapfdc.cdbanchq = tel_cdbaninf   AND
                            crapfdc.cdagechq = tel_cdageinf   AND
                            crapfdc.nrctachq = tel_nrdctabb   AND
                            crapfdc.nrcheque = glb_nrchqsdv
                            USE-INDEX crapfdc1 NO-LOCK NO-ERROR.

                            IF   NOT AVAILABLE crapfdc  THEN
                                 DO:
                                     glb_cdcritic = 108.
                                     NEXT-PROMPT tel_nrdocmto
                                                 WITH FRAME f_landpv.
                                     NEXT.
                                 END.

                            IF   crapfdc.tpcheque <> 2   THEN
                                 DO:
                                     glb_cdcritic = 93.
                                     NEXT-PROMPT tel_nrdocmto
                                                 WITH FRAME f_landpv.
                                     NEXT.
                                 END.
                                 
                            aux_nrdconta = crapfdc.nrdconta.
                   END.  
              ELSE
              IF   CAN-DO(aux_lsconta3,STRING(tel_nrdctabb))   AND
                  (tel_cdhistor = 26                           OR
                   tel_cdhistor = 526)                         THEN
                   DO:
                       ASSIGN glb_nrchqsdv = INT(SUBSTR(STRING(tel_nrdocmto,
                                                    "9999999"),1,6))
                              glb_nrchqcdv = tel_nrdocmto.
                       
                       FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper   AND
                                          crapfdc.cdbanchq = tel_cdbaninf   AND
                                          crapfdc.cdagechq = tel_cdageinf   AND
                                          crapfdc.nrctachq = tel_nrdctabb   AND 
                                          crapfdc.nrcheque = glb_nrchqsdv
                                          USE-INDEX crapfdc1 NO-LOCK NO-ERROR.
                       
                       IF   AVAILABLE crapfdc   THEN
                            IF   crapfdc.vlcheque = tel_vllanmto   THEN
                                 aux_nrdconta = crapfdc.nrdconta.
                            ELSE
                                 DO:
                                     glb_cdcritic = 91.
                                     NEXT-PROMPT tel_nrdocmto
                                                 WITH FRAME f_landpv.
                                     NEXT.
                                 END.
                       ELSE
                            DO:
                                glb_cdcritic = 286.
                                NEXT-PROMPT tel_nrdocmto WITH FRAME f_landpv.
                                NEXT.
                            END.
                   END.
              ELSE
              IF  (tel_cdhistor = 26 OR
                   tel_cdhistor = 526) AND
                   NOT CAN-DO(aux_lsconta3,STRING(tel_nrdctabb)) THEN
                   DO:
                        glb_cdcritic = 286.
                        NEXT-PROMPT tel_nrdctabb WITH FRAME f_landpv.
                        NEXT.
                   END.     
              ELSE
              DO:
                   aux_nrdconta = tel_nrdctabb.
              END.

              ant_nrdconta = aux_nrdconta.

              DO WHILE TRUE:

                 FIND crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                                    crapass.nrdconta = aux_nrdconta
                                    NO-LOCK NO-ERROR.
              
                 IF   NOT AVAILABLE crapass   THEN
                      DO:
                          glb_cdcritic = 9.
                          NEXT-PROMPT tel_nrdctabb WITH FRAME f_landpv.
                          LEAVE.
                      END.
                 ELSE
                 IF   crapass.dtelimin <> ? THEN
                      DO:     
                          glb_cdcritic = 410.
                          NEXT-PROMPT tel_nrdctabb WITH FRAME f_landpv.
                          LEAVE.                         
                      END.
                 ELSE
                 IF   CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN
                      DO:
                          FIND FIRST craptrf WHERE
                                     craptrf.cdcooper = glb_cdcooper      AND
                                     craptrf.nrdconta = crapass.nrdconta  AND
                                     craptrf.tptransa = 1 
                                     USE-INDEX craptrf1 NO-LOCK NO-ERROR.

                          IF   NOT AVAILABLE craptrf THEN
                               DO:
                                   glb_cdcritic = 95.
                                   NEXT-PROMPT tel_nrdctabb WITH FRAME f_landpv.
                                   LEAVE.
                               END.
                          ELSE
                               DO:
                                   ASSIGN aux_nrtrfcta = craptrf.nrsconta
                                          aux_nrdconta = craptrf.nrsconta.
                                   NEXT.
                               END.
                      END.

                 IF  glb_cdcritic = 0   THEN
                     DO:  
                         IF  tel_cdhistor <> 127 AND
                             glb_cdcooper <> 4 THEN
                             DO:   
                                 RUN sistema/generico/procedures/b1wgen0001.p
                                     PERSISTENT SET h-b1wgen0001.
      
                                 IF   VALID-HANDLE(h-b1wgen0001)   THEN
                                      DO:
                                          RUN ver_capital IN h-b1wgen0001
                                                         (INPUT  glb_cdcooper,
                                                          INPUT  aux_nrdconta,
                                                          INPUT  0, /*agencia*/
                                                          INPUT  0, /* caixa */
                                                          0,
                                                          INPUT  glb_dtmvtolt,
                                                          INPUT  "landpvi",
                                                          INPUT  1, /* AYLLOS */
                                                          OUTPUT TABLE tt-erro).

                                          /* Verifica se houve erro */
                                          FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                          
                                          IF   AVAILABLE tt-erro   THEN
                                               DO:
                                                   ASSIGN glb_cdcritic = tt-erro.cdcritic
                                                          glb_dscricpl = tt-erro.dscritic.
                                               END.
                                          
                                          DELETE PROCEDURE h-b1wgen0001.

                                          IF   glb_cdcritic > 0   THEN
                                               DO:
                                                    NEXT-PROMPT tel_nrdctabb 
                                                           WITH FRAME f_landpv.
                                                    LEAVE.
                                               END.
                             
                                      END.
                             END.
                 
                     END.

                 LEAVE.

              END.  /*  Fim do DO WHILE TRUE  */
              
              IF   glb_cdcritic = 0    THEN
                   IF   tel_cdhistor = 21   OR
                        tel_cdhistor = 47   OR
                        tel_cdhistor = 49   OR
                      ((tel_cdhistor = 26   OR
                        tel_cdhistor = 526) AND
                        CAN-DO(aux_lsconta3,STRING(tel_nrdctabb)))  OR
                        tel_cdhistor = 59   OR
                        tel_cdhistor = 77   OR
                        tel_cdhistor = 78   OR
                        tel_cdhistor = 101  OR
                 /*     tel_cdhistor = 105  OR  */
                        tel_cdhistor = 156  OR
                        tel_cdhistor = 191  OR
                        tel_cdhistor = 521  OR
                        tel_cdhistor = 621  OR
                        tel_cdhistor = 1873 OR
                        tel_cdhistor = 1874 THEN
                        DO:  
                            glb_nrcalcul = tel_nrdocmto.

                            RUN fontes/digfun.p.
                            IF   NOT glb_stsnrcal   THEN
                                 DO:
                                     glb_cdcritic = 8.
                                     NEXT-PROMPT tel_nrdocmto 
                                                 WITH FRAME f_landpv.
                                     NEXT.
                                 END.
                        END.
              ELSE
              IF   tel_cdhistor = 26   OR
                   tel_cdhistor = 526  THEN
                   DO:
                       glb_nrcalcul = DECIMAL("26" +
                                              STRING(tel_nrdocmto,"99999999")).

                       RUN fontes/digfun.p.
                       IF   NOT glb_stsnrcal   THEN
                            DO:
                                glb_cdcritic = 8.
                                NEXT-PROMPT tel_nrdocmto WITH FRAME f_landpv.
                                NEXT.
                            END.
                   END.
              
              RUN critica_dtliblan.

              /** Prejuizo de conta **/
              IF   tel_cdhistor = 350   THEN
                   DO:     
                       FIND LAST crapdpb WHERE
                                 crapdpb.cdcooper  = glb_cdcooper       AND
                                 crapdpb.nrdconta  = crapass.nrdconta   AND
                                 crapdpb.dtliblan >= glb_dtmvtolt       AND
                                 crapdpb.inlibera  = 1
                                 NO-LOCK NO-ERROR.
                                 
                       IF   AVAILABLE crapdpb   THEN 
                            DO:
                                glb_cdcritic = 725.
                                NEXT-PROMPT tel_cdhistor WITH FRAME f_landpv.
                                NEXT.
                            END.  
                       
                       ASSIGN aux_flgpreju = NO.
                       
                       FOR EACH crapepr WHERE
                                crapepr.cdcooper = glb_cdcooper      AND
                                crapepr.nrdconta = crapass.nrdconta  NO-LOCK:
                                
                           IF  crapepr.cdlcremp = 100   AND
                               crapepr.vlsdprej <> 0    THEN
                               DO:
                                   ASSIGN aux_flgpreju = YES.
                                   LEAVE.
                               END.
                       END.         
                       IF   NOT aux_flgpreju   THEN  
                            DO:
                                glb_cdcritic = 766.
                                NEXT-PROMPT tel_cdhistor WITH FRAME f_landpv.
                                NEXT.
                            END.
                   END.

              IF   glb_cdcritic = 0   THEN
                   IF   crapass.dtdemiss <> ?   THEN
                        IF   tel_cdhistor = 15   OR
                            (tel_cdbccxlt = 200   AND   tel_cdhistor = 2)   THEN
                             DO:
                                 glb_cdcritic = 75.
                                 NEXT-PROMPT tel_nrdctabb WITH FRAME f_landpv.
                                 NEXT.
                             END.
          END.

      END.
            
      IF   CAN-DO("2,3",STRING(craphis.tpctbcxa)) THEN
           DO:
               IF  tel_cdbccxlt <> 11 THEN
                   DO:
                       glb_cdcritic = 689.
                       NEXT-PROMPT tel_cdhistor WITH FRAME f_landpv.
                       NEXT.
                   END.    
           END.
      ELSE
           DO:
               IF  tel_cdbccxlt = 11 THEN
                   DO:
                       glb_cdcritic = 689.
                       NEXT-PROMPT tel_cdhistor WITH FRAME f_landpv.
                       NEXT.
                   END.    
           END.

      IF   craphis.indebcre = "C"   AND    glb_cdcritic = 0   THEN
           DO:
               
               { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

               RUN STORED-PROCEDURE pc_busca_modalidade_tipo
               aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.inpessoa, /* Tipo de pessoa */
                                                    INPUT crapass.cdtipcta, /* Tipo de conta */
                                                   OUTPUT 0,                /* Modalidade */
                                                   OUTPUT "",               /* Flag Erro */
                                                   OUTPUT "").              /* Descrição da crítica */

               CLOSE STORED-PROC pc_busca_modalidade_tipo
                     aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

               { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

               ASSIGN aux_cdmodali = 0
                      aux_des_erro = ""
                      aux_dscritic = ""
                      aux_cdmodali = pc_busca_modalidade_tipo.pr_cdmodalidade_tipo 
                                     WHEN pc_busca_modalidade_tipo.pr_cdmodalidade_tipo <> ?
                      aux_des_erro = pc_busca_modalidade_tipo.pr_des_erro 
                                     WHEN pc_busca_modalidade_tipo.pr_des_erro <> ?
                      aux_dscritic = pc_busca_modalidade_tipo.pr_dscritic
                                     WHEN pc_busca_modalidade_tipo.pr_dscritic <> ?.

               IF aux_des_erro = "NOK"  THEN
                   DO:
                      BELL.
                      ASSIGN glb_dscritic = aux_dscritic.
                      MESSAGE glb_dscritic.
                      LEAVE.
                   END.
               
               IF   aux_cdmodali = 3 THEN
                    DO:
                        BELL.

                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                           aux_confirma = "N".

                           MESSAGE "ATENCAO!!! Esta conta e' do tipo POUPANCA.".

                           glb_cdcritic = 78.
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE COLOR NORMAL glb_dscritic
                                                UPDATE aux_confirma.
                           glb_cdcritic = 0. 
                           glb_dscritic = "". 
                           LEAVE.

                        END.

                        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                             aux_confirma <> "S" THEN
                             DO:
                                 glb_cdcritic = 79.
                                 RUN fontes/critic.p.
                                 BELL.
                                 MESSAGE glb_dscritic.
                                 glb_cdcritic = 0.
								 glb_dscritic = "".
                                 UNDO INICIO, NEXT INICIO.
                             END.
                    END.
           END.

      /*** Verificar se docto existe */
      FIND crablcm WHERE crablcm.cdcooper = glb_cdcooper    AND
                         crablcm.dtmvtolt = tel_dtmvtolt    AND
                         crablcm.cdagenci = tel_cdagenci    AND
                         crablcm.cdbccxlt = tel_cdbccxlt    AND
                         crablcm.nrdolote = tel_nrdolote    AND
                         crablcm.nrdctabb = tel_nrdctabb    AND
                         crablcm.nrdocmto = tel_nrdocmto    
                         USE-INDEX craplcm1  NO-LOCK NO-ERROR.
                         
      IF   AVAILABLE crablcm   THEN
           DO:
               glb_cdcritic = 670.
               NEXT-PROMPT tel_nrdocmto WITH FRAME f_landpv.
               NEXT.
            END.
      RELEASE crablcm.               
      
      /*** Lancamento de emprestimos ***/
      IF   CAN-DO("275,317,394,428,506",STRING(tel_cdhistor))  THEN
           DO:
               ASSIGN tel_nrctremp = 0.
               RUN critica_contrato.
           END. 
      
      ASSIGN aux_vlcapmin = 0.
      
      IF   tel_cdhistor = 127   THEN
           DO:
               FIND FIRST crapmat WHERE crapmat.cdcooper = glb_cdcooper 
                                        NO-LOCK NO-ERROR.

               /*  Le tabela de valor minimo do capital  */

               FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                  craptab.nmsistem = "CRED"         AND
                                  craptab.tptabela = "USUARI"       AND
                                  craptab.cdempres = 11             AND
                                  craptab.cdacesso = "VLRUNIDCAP"   AND
                                  craptab.tpregist = 1
                                  NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE craptab   THEN
                    aux_vlcapmin = crapmat.vlcapini.
               ELSE
                    aux_vlcapmin = DECIMAL(craptab.dstextab).
              
           END.
      
      IF  glb_cdcritic = 0   AND   tel_cdalinea > 0   AND
          NOT CAN-DO("351,399",STRING(tel_cdhistor))  THEN
          DO:

              RUN sistema/generico/procedures/b1wgen0175.p PERSISTENT SET h-b1wgen0175.
    
              IF VALID-HANDLE(h-b1wgen0175) THEN
                  DO:
                      RUN valida-alinea IN h-b1wgen0175(INPUT glb_cdcooper,
                                                        INPUT crapass.nrdconta,
                                                        INPUT crapfdc.nrdctabb,
                                                        INPUT tel_nrdocmto,
                                                        INPUT tel_cdalinea,
                                                        INPUT glb_dtmvtolt,
                                                        INPUT crapfdc.cdtpdchq,
                                                       OUTPUT TABLE tt-erro).
    
                      DELETE PROCEDURE h-b1wgen0175.
    
                      IF RETURN-VALUE <> "OK" THEN 
                          DO:
                              FIND FIRST tt-erro NO-LOCK NO-ERROR.
                              IF AVAIL tt-erro THEN
                              DO:
                                  ASSIGN glb_cdcritic = tt-erro.cdcritic
                                         glb_dscritic = tt-erro.dscritic.
                              END.
                          END.
                  END.
          END.

      IF   glb_cdcritic > 0 OR glb_dscritic <> "" THEN
           DO:
               IF glb_cdcritic > 0 THEN
                   RUN fontes/critic.p.

               BELL.
               CLEAR FRAME f_landpv.
               ASSIGN glb_cddopcao = aux_cddopcao
                      tel_dtmvtolt = aux_dtmvtolt
                      tel_cdagenci = aux_cdagenci
                      tel_cdbccxlt = aux_cdbccxlt
                      tel_nrdolote = aux_nrdolote
                      tel_cdhistor = aux_cdhistor
                      tel_nrdctabb = aux_nrdctabb
                      tel_nrdocmto = aux_nrdocmto
                      tel_vllanmto = aux_vllanmto
                      tel_dtliblan = aux_dtliblan
                      tel_cdalinea = aux_cdalinea.

               DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                       tel_cdbccxlt tel_nrdolote tel_cdhistor tel_nrdctabb
                       tel_cdbaninf tel_cdageinf tel_nrdocmto tel_vllanmto 
                       tel_dtliblan tel_cdalinea WITH FRAME f_landpv.

               MESSAGE glb_dscritic.
               PAUSE(3) NO-MESSAGE.
               NEXT.
           END.
      
      IF   aux_nrtrfcta > 0 THEN
           DO:
               glb_cdcritic = 156.
               RUN fontes/critic.p.

               MESSAGE glb_dscritic STRING(ant_nrdconta,"zzzz,zzz,9")
                       "para o numero" STRING(aux_nrtrfcta,"zzzz,zzz,9").

               PAUSE(4).
               BELL.

               IF   NOT CAN-DO(aux_lscontas,STRING(tel_nrdctabb))   THEN
                    tel_nrdctabb = aux_nrtrfcta.

               aux_nrdconta = aux_nrtrfcta.
               glb_cdcritic = 0.
			   glb_dscritic = "".
           END.

      ASSIGN tel_nrautdoc = 0.

      IF   tel_cdbccxlt = 11   THEN
           DO:
               FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                                  craplot.dtmvtolt = tel_dtmvtolt   AND
                                  craplot.cdagenci = tel_cdagenci   AND
                                  craplot.cdbccxlt = tel_cdbccxlt   AND
                                  craplot.nrdolote = tel_nrdolote
                                  NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE craplot   THEN
                    DO:         
                        ASSIGN glb_cdcritic = 60.
                               aux_flgerros = TRUE.
                        LEAVE.
                    END.
               
               FIND craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                                  craptab.nmsistem = "CRED"           AND
                                  craptab.tptabela = "CAIXA"          AND
                                  craptab.cdempres = craplot.cdagenci AND
                                  craptab.cdacesso = "AUTOMA"         AND
                                  craptab.tpregist = craplot.nrdcaixa 
                                  NO-LOCK NO-ERROR.
                                  
               IF   AVAILABLE craptab   THEN
                    UPDATE tel_nrautdoc WITH FRAME f_autentica.

               HIDE FRAME f_autentica.
      
           END.
           
      /***** Tratamento da Compensacao Eletronica ***/
      IF   NOT CAN-DO("3,4,372,386",STRING(tel_cdhistor))   THEN
           LEAVE.
    
      IF   tel_vllanmto = aux_vlttcomp   THEN
           LEAVE.

      IF   tel_cdhistor <> 386   THEN
           DO:
               /*  Verifica o horario de corte  */
               
               FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                  craptab.nmsistem = "CRED"         AND
                                  craptab.tptabela = "GENERI"       AND
                                  craptab.cdempres = 0              AND
                                  craptab.cdacesso = "HRTRCOMPEL"   AND
                                  craptab.tpregist = tel_cdagenci 
                                  NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE craptab   THEN
                    DO:
                        glb_cdcritic = 676.
                        NEXT.
                    END.

               IF   INT(SUBSTR(craptab.dstextab,3,5)) <= TIME   THEN
                    DO:
                        glb_cdcritic = 676.
                        NEXT.
                    END.
               
               IF   INT(SUBSTR(craptab.dstextab,1,1)) <> 0   THEN
                    DO:
                        FIND craptab WHERE 
                             craptab.cdcooper = glb_cdcooper   AND
                             craptab.nmsistem = "CRED"         AND
                             craptab.tptabela = "GENERI"       AND
                             craptab.cdempres = 0              AND
                             craptab.cdacesso = "EXETRUNCAGEM" AND
                             craptab.tpregist = tel_cdagenci   
                             NO-LOCK NO-ERROR.
                   
                        IF   NOT AVAILABLE craptab THEN
                             DO:
                                 glb_cdcritic = 677.
                                 NEXT.
                             END.
                        ELSE
                             IF   craptab.dstextab = "NAO" THEN
                                  DO:
                                      glb_cdcritic = 677.
                                      NEXT.
                                  END.
                    END.
                 
           END.

      /*  Busca dados da cooperativa  */
      ASSIGN aux_cdagebcb = crapcop.cdagebcb
             tel_vlcompel = tel_vllanmto
             tel_dsdocmc7 = "".

      CLEAR FRAME f_regant ALL.
      HIDE FRAME f_regant NO-PAUSE.
        
      CMC-7:
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
         IF   glb_cdcritic <> 0   THEN
              DO:
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  ASSIGN glb_cdcritic = 0
				         glb_dscritic = "".
              END.    
          
         UPDATE tel_vlcompel WITH FRAME f_compel
            
         EDITING:
 
            READKEY.
                        
            IF   LASTKEY =  KEYCODE(".")   THEN
                 APPLY 44.
            ELSE
                 APPLY LASTKEY.
                           
         END.  /*  Fim do EDITING  */
         
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
            IF   glb_cdcritic <> 0 THEN
                 DO:
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     ASSIGN glb_cdcritic = 0
							glb_dscritic = ""
                            tel_dsdocmc7 = "".
                 END.
      
            ASSIGN aux_flgchqex = NO.
            
            UPDATE tel_dsdocmc7 WITH FRAME f_compel
         
            EDITING:
            
               READKEY.
       
               IF   NOT CAN-DO(aux_lsvalido,KEYLABEL(LASTKEY))   THEN
                    DO:
                        glb_cdcritic = 666.
                        NEXT.
                    END.
   
               IF   KEYLABEL(LASTKEY) = "G"   THEN
                    APPLY KEYCODE(":").
               ELSE
                    APPLY LASTKEY.
                         
            END.  /*  Fim do EDITING  */
         
            HIDE MESSAGE NO-PAUSE.
         
            IF   TRIM(tel_dsdocmc7) <> ""   THEN
                 DO:
                     
                     IF   LENGTH(tel_dsdocmc7) <> 34            OR
                          SUBSTRING(tel_dsdocmc7,01,1) <> "<"   OR
                          SUBSTRING(tel_dsdocmc7,10,1) <> "<"   OR
                          SUBSTRING(tel_dsdocmc7,21,1) <> ">"   OR
                          SUBSTRING(tel_dsdocmc7,34,1) <> ":"   THEN
                          DO:
                              glb_cdcritic = 666.
                              NEXT.
                          END.
        
                     RUN fontes/dig_cmc7.p (INPUT  tel_dsdocmc7,
                                            OUTPUT glb_nrcalcul,
                                            OUTPUT aux_lsdigctr).
                  
                     IF   glb_nrcalcul > 0                 OR
                          NUM-ENTRIES(aux_lsdigctr) <> 3   THEN
                          DO:
                              glb_cdcritic = 666.
                              NEXT.
                          END.
                     
                     FIND w-compel WHERE w-compel.dsdocmc7 = TRIM(tel_dsdocmc7)
                                   NO-ERROR.
                                   
                     IF   AVAILABLE w-compel   THEN
                          DO:
                              IF   tel_vlcompel < tab_vlchqmai   THEN
                                   aux_tpdmovto = 2.
                              ELSE
                                   aux_tpdmovto = 1.
 
                              ASSIGN aux_vlttcomp = aux_vlttcomp -
                                                    w-compel.vlcompel
                                     w-compel.vlcompel = tel_vlcompel
                                     w-compel.tpdmovto = aux_tpdmovto
                                     aux_flgchqex      = YES.
                          END.

                     RUN mostra_dados.
                     
                     IF   tel_cdhistor  = 3                AND
                          tel_cdcmpchq <> crapage.cdcomchq THEN
                          ASSIGN glb_cdcritic = 715.
                     ELSE
                     IF   tel_cdhistor = 4  AND
                          tel_cdcmpchq = crapage.cdcomchq   THEN
                          ASSIGN glb_cdcritic = 716.
                     ELSE 
                          DO:
                              FIND crapfdc WHERE 
                                   crapfdc.cdcooper = glb_cdcooper AND
                                   crapfdc.cdbanchq = tel_cdbanchq AND
                                   crapfdc.cdagechq = tel_cdagechq AND
                                   crapfdc.nrctachq = tel_nrctabdb AND
                                   crapfdc.nrcheque = tel_nrcheque
                                   NO-LOCK NO-ERROR.

                              IF   tel_cdhistor =  386   THEN
                                   DO:
                                       IF   NOT AVAILABLE crapfdc   THEN     
                                            ASSIGN glb_cdcritic = 93.
                                   END.
                              ELSE
                              IF   tel_cdhistor = 372   THEN
                                   DO: 
                                       IF  AVAILABLE crapfdc   THEN
                                            ASSIGN glb_cdcritic = 712.
                                   END.
                          END.
                     
                     IF   glb_cdcritic > 0   THEN
                          NEXT.

                 END.
            ELSE
                 DO: 
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                  
                        RUN fontes/cmc7.p (OUTPUT tel_dsdocmc7).
                        
                        IF   LENGTH(tel_dsdocmc7) <> 34   THEN
                             LEAVE.
                         
                        DISPLAY tel_dsdocmc7 WITH FRAME f_compel.
                     
                        FIND w-compel WHERE w-compel.dsdocmc7 = 
                                            TRIM(tel_dsdocmc7) NO-ERROR.
                                            
                        IF   AVAILABLE w-compel   THEN
                             DO:
                                 IF   tel_vlcompel < tab_vlchqmai   THEN
                                      aux_tpdmovto = 2.
                                 ELSE
                                      aux_tpdmovto = 1.
 
                                 ASSIGN aux_vlttcomp = aux_vlttcomp -
                                                           w-compel.vlcompel
                                        w-compel.vlcompel = tel_vlcompel
                                        w-compel.tpdmovto = aux_tpdmovto
                                        aux_flgchqex      = YES.
                             END.
                        RUN fontes/dig_cmc7.p (INPUT  tel_dsdocmc7,
                                               OUTPUT glb_nrcalcul,
                                               OUTPUT aux_lsdigctr).
                        
                        RUN mostra_dados.

                        IF   tel_cdhistor  = 3  AND
                             tel_cdcmpchq <> crapage.cdcomchq THEN
                             ASSIGN glb_cdcritic = 715.
                        ELSE
                        IF   tel_cdhistor  = 4  AND
                             tel_cdcmpchq = crapage.cdcomchq THEN
                             ASSIGN glb_cdcritic = 716.
                        ELSE DO:
                        FIND crapfdc WHERE crapfdc.cdcooper = glb_cdcooper AND
                                           crapfdc.cdbanchq = tel_cdbanchq AND
                                           crapfdc.cdagechq = tel_cdagechq AND
                                           crapfdc.nrctachq = tel_nrctabdb AND
                                           crapfdc.nrcheque = tel_nrcheque
                                           NO-LOCK NO-ERROR.

                        IF   tel_cdhistor =  386   THEN
                             DO:
                                 IF   NOT AVAILABLE crapfdc   THEN     
                                      ASSIGN glb_cdcritic = 93.
                             END.
                        ELSE
                        IF   tel_cdhistor = 372   THEN
                             DO: 
                                 IF  AVAILABLE crapfdc   THEN
                                      ASSIGN glb_cdcritic = 712.
                             END.
                        END.
                        IF   glb_cdcritic > 0   THEN
                             NEXT.

                        LEAVE.
                   
                     END.  /*  Fim do DO WHILE TRUE  */
                  
                     IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
                          NEXT.
                 END.

            IF   tel_cdhistor <> 386   THEN
                 DO: 
                     /*  Verifica o horario de corte  */

                     FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                        craptab.nmsistem = "CRED"         AND
                                        craptab.tptabela = "GENERI"       AND
                                        craptab.cdempres = 0              AND
                                        craptab.cdacesso = "HRTRCOMPEL"   AND
                                        craptab.tpregist = tel_cdagenci 
                                        NO-LOCK NO-ERROR.

                     IF   NOT AVAILABLE craptab   THEN
                          DO:
                              glb_cdcritic = 676.
                              NEXT.
                          END.

                     IF   INT(SUBSTR(craptab.dstextab,1,1)) <> 0   THEN
                          DO:
                              glb_cdcritic = 677.
                              NEXT.
                          END.
                 
                     IF   INT(SUBSTR(craptab.dstextab,3,5)) <= TIME   THEN
                          DO:
                              glb_cdcritic = 676.
                              NEXT.
                          END.
                 END.
            
            RUN ver_cheque.
            
            IF   glb_cdcritic > 0   THEN
                 NEXT.

            IF   CAN-DO("3,4,372",STRING(tel_cdhistor))   AND
                 aux_nrctcomp > 0                         THEN
                 DO:
                     glb_cdcritic = 712.
                     NEXT.
                 END.
            ELSE
                 IF   tel_cdhistor =  386   THEN
                      DO:
                          RUN verifica_saldo.
                          ASSIGN aux_confirma = "". 
                          IF   aux_flgctrsl   THEN
                               DO:
                                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                      ASSIGN aux_confirma = "S".
                                      BELL.
                                      MESSAGE COLOR NORMAL aux_mensagem 
                                                    UPDATE aux_confirma.  
                                      LEAVE.
                                   END.

                                   IF   aux_confirma = "N" THEN
                                        DO:
                                            ASSIGN glb_cdcritic = 172.
                                            NEXT.
                                        END.
                               END.
                      END.
 
            IF   tel_vlcompel < tab_vlchqmai   THEN
                 aux_tpdmovto = 2.
            ELSE
                 aux_tpdmovto = 1.

            /*  Verifica se ja existe o lancamento  */
            
            IF   CAN-FIND(crapchd WHERE 
                          crapchd.cdcooper = glb_cdcooper   AND
                          crapchd.dtmvtolt = tel_dtmvtolt   AND
                          crapchd.cdcmpchq = tel_cdcmpchq   AND
                          crapchd.cdbanchq = tel_cdbanchq   AND
                          crapchd.cdagechq = tel_cdagechq   AND
                          crapchd.nrctachq = (IF aux_nrctcomp > 0
                                                 THEN tel_nrctabdb
                                                 ELSE tel_nrctachq)   AND
                          crapchd.nrcheque = tel_nrcheque)  THEN
                 DO:
                     glb_cdcritic = 92.
                     NEXT.
                 END.
                 
            LEAVE.
         
         END.  /*  Fim do DO WHILE TRUE  */
         
         IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
              NEXT.
              
         FIND w-compel WHERE w-compel.dsdocmc7 = TRIM(tel_dsdocmc7) NO-ERROR.
         
         IF   NOT AVAILABLE w-compel   THEN
              DO:
                  CREATE w-compel.
                  ASSIGN aux_maischeq      = aux_maischeq + 1
                         aux_nrsqcomp      = aux_nrsqcomp + 1
                         w-compel.dsdocmc7 = tel_dsdocmc7
                         w-compel.cdcmpchq = tel_cdcmpchq
                         w-compel.cdbanchq = tel_cdbanchq
                         w-compel.cdagechq = tel_cdagechq
                         w-compel.nrddigc1 = tel_nrddigc1   
                         w-compel.nrctaaux = aux_nrctcomp
                         w-compel.nrctachq = tel_nrctachq
                         w-compel.nrctabdb = tel_nrctabdb
                         w-compel.nrddigc2 = tel_nrddigc2            
                         w-compel.nrcheque = tel_nrcheque      
                         w-compel.nrddigc3 = tel_nrddigc3            
                         w-compel.vlcompel = tel_vlcompel
                         w-compel.dtlibcom = tel_dtlibcom
                         w-compel.lsdigctr = aux_lsdigctr
                         w-compel.tpdmovto = aux_tpdmovto
                         w-compel.cdtipchq = INTE(SUBSTRING(tel_dsdocmc7,20,1))
                         w-compel.nrseqdig = aux_nrsqcomp.

                  ASSIGN w-compel.nrcheque = tel_nrcheque.
              END.
                         
         ASSIGN aux_vlttcomp = aux_vlttcomp + tel_vlcompel
                tel_dsdocmc7 = ""
                tel_vlcompel = 0.
         DISPLAY tel_vlcompel tel_dsdocmc7 WITH FRAME f_compel.       
         PAUSE(0).
              
         /* Com a adaptacao para o CAF passara a limitar somente 1 lancto */
         LEAVE.
                            
      END. /* Fim do DO WHILE TRUE CMC-7 */
        
      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
           DO:
               ASSIGN aux_vlttcomp = 0
                      aux_vlrdifer = 0 
                      glb_cdcritic = 0
					  glb_dscritic = "".
               
               HIDE MESSAGE NO-PAUSE.
               
               FOR EACH w-compel NO-LOCK:
                   ASSIGN aux_vlttcomp = aux_vlttcomp + w-compel.vlcompel.
               END.

               IF   aux_vlttcomp <> tel_vllanmto   THEN
                    DO:
                        ASSIGN aux_vlrdifer = (tel_vllanmto - aux_vlttcomp) 
                                aux_mensagem = "Calculado " +
                                  TRIM(STRING(aux_vlttcomp,"zzz,zzz,zz9.99")) +
                                          " Diferenca de " +
                                  TRIM(STRING(aux_vlrdifer,"zzz,zzz,zz9.99-"))
                                glb_cdcritic = 710.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        MESSAGE aux_mensagem.
                    
                        /*** Magui consulta o que ja foi digitado ***/
                        FIND FIRST w-compel NO-LOCK NO-ERROR.
                        
                        IF   AVAILABLE w-compel THEN
                             DO:
                                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                                    OPEN QUERY bwcompel-q 
                                         FOR EACH w-compel NO-LOCK 
                                                 BY w-compel.nrseqdig.
                                        
                                    ENABLE bwcompel-b 
                                           WITH FRAME f_consulta_wcompel.

                                    WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
              
                                 END.

                                 CLEAR FRAME f_consulta_wcompel ALL.
                                 HIDE FRAME f_consulta_wcompel NO-PAUSE.
   
                             END.

                        NEXT-PROMPT tel_vllanmto WITH FRAME f_landpv.
                        NEXT. 

                    END.
                
               LEAVE.
                    
           END.
      
      LEAVE.

   END.   /* Fim do DO WHILE TRUE */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO: /*   F4 OU FIM   */
            /** Magui abandonar se existe cheques **/
            ASSIGN aux_canclchq = "N"
                   glb_cdcritic = 0
				   glb_dscritic = "".
            FIND FIRST w-compel NO-LOCK NO-ERROR.
            
            IF   AVAILABLE w-compel   THEN 
                 DO:
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                        HIDE MESSAGE NO-PAUSE.
                        
                        glb_cdcritic = 732.
                        RUN fontes/critic.p.
                        MESSAGE COLOR NORMAL glb_dscritic.
                        
                        glb_cdcritic = 78.
                        RUN fontes/critic.p.

                        BELL.
                        MESSAGE COLOR NORMAL glb_dscritic 
                                             UPDATE aux_canclchq.
                        LEAVE.

                     END.
                     ASSIGN glb_cdcritic = 0.
                     IF   aux_canclchq = "N"   THEN 
                          DO:
                              NEXT-PROMPT tel_vllanmto WITH FRAME f_landpv.
                              NEXT.
                          END.    
                 END.

            RETURN.  /* Volta pedir a opcao para o operador */
        END.    

        /* Historicos de pagamento de emprestimo */
        IF CAN-DO("275,394,428,384",STRING(tel_cdhistor)) THEN
          DO:
         
              /* Procedure para buscar o saldo disponivel da conta */
              RUN obtem_saldo_dia_prog (INPUT glb_cdcooper,
                                        INPUT tel_cdagenci,
                                        INPUT tel_cdbccxlt,
                                        INPUT glb_cdoperad,
                                        INPUT tel_nrdctabb,
                                        INPUT glb_dtmvtolt,
                                        OUTPUT glb_cdcritic,
                                        OUTPUT glb_dscritic,
                                        OUTPUT TABLE tt-saldos).
                                   
              /* Condicao para verificar se houve erro */                          
              IF glb_cdcritic <> 0 OR glb_dscritic <> "" THEN
                 DO:
                     NEXT-PROMPT tel_cdhistor WITH FRAME f_landpv.
                     UNDO, NEXT INICIO.
                 END.

              /* Condicao para verifica se possui saldo disponivel */
              FIND FIRST tt-saldos NO-LOCK NO-ERROR.
              IF AVAILABLE tt-saldos THEN
                 DO:
						/* É atribuido ao saldo disponivel o valor da soma do saldo */
						/* disponivel  + saldo do cheque especial + o valor do limite de crédito*/
                     ASSIGN aux_vlsddisp = tt-saldos.vlsddisp +
                                           tt-saldos.vlsdchsl + 
                                           tt-saldos.vllimcre.
						ASSIGN aux_vlsdbloq = tt-saldos.vlsdblpr +
												tt-saldos.vlsdblfp + 
												tt-saldos.vlsdbloq.
					END. /*AVAILABLE tt-saldos THEN*/

                 
                 IF aux_indebcre = "D" THEN
                    DO:
					   /* Verifica se o valor de lançamento é maior que o saldo disponível (Saldo normal + valor do cheque */
                       /*  especial + valor do limite de crédito). */
                       IF tel_vllanmto > aux_vlsddisp THEN
                          DO:
							/* Verifica se o saldo bloqueado é maio que 0.*/
							IF  aux_vlsdbloq > 0 THEN
							  DO:
								/* Solicita a confirmaçao de utilizaçao do saldo bloqueado para o pagamento. */
								/* Se o valor bloqueado for maior que 0, solicita a senha para utilizaçao do valor */
								/* do saldo bloqueado para pagamento do débito. */
								DO:
								  /* Solicita a confirmaçao de pagamento mesmo ocorrendo o estouro da conta.*/
								  RUN fontes/confirma.p
									(INPUT "Deseja utilizar o valor do saldo bloqueado? S/N",
										OUTPUT aux_confirma).
								  IF aux_confirma <> "S" THEN
									UNDO, NEXT INICIO. 
								  ELSE 
									  DO:
										RUN fontes/pedesenha.p (INPUT glb_cdcooper,
										  INPUT 2, 
										  OUTPUT aut_flgsenha,
										  OUTPUT aut_cdoperad).
										/*Se nao for dada a autorizaçao ou a senha estiver errada é cancelado o pagamento*/
										IF NOT aut_flgsenha  THEN
										  UNDO, NEXT INICIO.
									  END. 
								END. /* aux_vlsdbloq <= tel_vllanmto */
							  END.
							  IF  (aux_vlsdbloq + aux_vlsddisp)< tel_vllanmto THEN
								DO:
								  /* Solicita a confirmaçao de pagamento mesmo ocorrendo o estouro da conta.*/
                            RUN fontes/confirma.p
                              (INPUT "Saldo Disp.: " + STRING(aux_vlsddisp,"zzz,zzz,zz9.99-")
                                      + ". Confirma estouro de conta? S/N",
                               OUTPUT aux_confirma).
                            
                            IF aux_confirma <> "S" THEN
                              UNDO, NEXT INICIO.
								END. /* aux_vlsdbloq <= tel_vllanmto */
						  END. /* tel_vllanmto >= aux_vlsddisp */             
					END. /* aux_indebcre = "D" */
        END. /* END IF  CAN-DO("275,394,428",STRING(tel_cdhistor)) */        
      

   DO TRANSACTION:

      DO aux_contador = 1 TO 10:

         ASSIGN aux_indevchq = 0
                aux_cdalinea = 0.

         FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                            craplot.dtmvtolt = tel_dtmvtolt   AND
                            craplot.cdagenci = tel_cdagenci   AND
                            craplot.cdbccxlt = tel_cdbccxlt   AND
                            craplot.nrdolote = tel_nrdolote
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAILABLE craplot   THEN
              IF   LOCKED craplot  THEN
                   DO:
                       ASSIGN glb_cdcritic = 84
                              aux_flgerros = TRUE.
                       PAUSE 1 NO-MESSAGE.
                       NEXT.
                   END.
              ELSE
                   DO: 
                       ASSIGN glb_cdcritic = 60
                              aux_flgerros = TRUE.
                       LEAVE.
                   END.
         ELSE
              ASSIGN glb_cdcritic = 0
					 glb_dscritic = ""
                     aux_flgerros = FALSE.
         
         LEAVE.
      
      END. /** Fim do DO .. TO **/

      IF   NOT aux_flgerros   THEN
           DO:
               IF   craplot.nrdcaixa > 0   THEN
                    DO:
                        RUN fontes/testa_boletim.p 
                                                   (INPUT  glb_cdcooper,      
                                                    INPUT  craplot.dtmvtolt,
                                                    INPUT  craplot.cdagenci,
                                                    INPUT  craplot.cdbccxlt,
                                                    INPUT  craplot.nrdolote,
                                                    INPUT  craplot.nrdcaixa,
                                                    INPUT  craplot.cdopecxa,
                                                    OUTPUT glb_cdcritic).
                                                    
                        IF   glb_cdcritic > 0   THEN
                             aux_flgerros = TRUE.
                    END.
           END.
      
      IF   NOT aux_flgerros   THEN
           DO:
               IF   craphis.inautori = 1   THEN
                    DO WHILE TRUE:

                       FIND crapatr WHERE
                            crapatr.cdcooper = glb_cdcooper      AND
                            crapatr.nrdconta = crapass.nrdcont   AND
                            crapatr.cdhistor = tel_cdhistor      AND
                            crapatr.cdrefere = tel_nrdocmto
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                       IF   NOT AVAILABLE crapatr   THEN
                            IF   LOCKED crapatr   THEN
                                 DO:
                                     PAUSE 1 NO-MESSAGE.
                                     NEXT.
                                 END.
                            ELSE
                                 ASSIGN glb_cdcritic = 446
                                        aux_flgerros = TRUE.
                       ELSE
                       IF   crapatr.dtfimatr <> ?   THEN
                            ASSIGN glb_cdcritic = 447
                                   aux_flgerros = TRUE.
                       ELSE
                       IF  (MONTH(crapatr.dtultdeb) <> MONTH(glb_dtmvtolt))   OR
                           ( YEAR(crapatr.dtultdeb) <>  YEAR(glb_dtmvtolt)) THEN
                             crapatr.dtultdeb = glb_dtmvtolt.

                       LEAVE.

                    END.  /*  Fim do DO WHILE TRUE */


               IF   NOT aux_flgerros   THEN
                    IF  craphis.inavisar = 1   THEN
                         IF   CAN-FIND(crapavs WHERE
                                       crapavs.cdcooper = glb_cdcooper     AND
                                       crapavs.dtmvtolt = glb_dtmvtolt     AND
                                       crapavs.cdempres = 0                AND
                                       crapavs.cdagenci = crapass.cdagenci AND
                                       crapavs.cdsecext = crapass.cdsecext AND
                                       crapavs.nrdconta = crapass.nrdconta AND
                                       crapavs.dtdebito = glb_dtmvtolt     AND
                                       crapavs.cdhistor = tel_cdhistor     AND
                                       crapavs.nrdocmto = tel_nrdocmto)    THEN
                              DO:
                                  ASSIGN glb_cdcritic = 22
                                         aux_flgerros = TRUE.

                                  NEXT-PROMPT tel_nrdocmto WITH FRAME f_landpv.
                                  NEXT.
                              END.
                         ELSE
                              DO:
                                  CREATE crapavs.
                                  ASSIGN crapavs.cdcooper = glb_cdcooper
                                         crapavs.cdagenci = crapass.cdagenci
                                         crapavs.cdempres = 0
                                         crapavs.cdhistor = tel_cdhistor
                                         crapavs.cdsecext = crapass.cdsecext
                                         crapavs.dtdebito = glb_dtmvtolt
                                         crapavs.dtmvtolt = glb_dtmvtolt
                                         crapavs.dtrefere = glb_dtmvtolt
                                         crapavs.insitavs = 0
                                         crapavs.nrdconta = crapass.nrdconta
                                         crapavs.nrdocmto = tel_nrdocmto
                                         crapavs.nrseqdig = craplot.nrseqdig + 1
                                         crapavs.tpdaviso = 2
                                         crapavs.vldebito = 0
                                         crapavs.vlestdif = 0
                                         crapavs.vllanmto = tel_vllanmto
                                         crapavs.flgproce = false.
                                  
                                  VALIDATE crapavs.

                              END.
           END.

      IF   NOT aux_flgerros   THEN
           IF   craplot.tplotmov <> 1   THEN
                glb_cdcritic = 100.
           ELSE
           DO:
              tel_nrseqdig = craplot.nrseqdig + 1.
               
               IF   tel_cdhistor = 21   OR
                    tel_cdhistor = 521  OR
                    tel_cdhistor = 621  OR
                    tel_cdhistor = 1873 OR
                    tel_cdhistor = 1874 THEN
                    DO:
                        ASSIGN glb_nrchqsdv = INT(SUBSTR(STRING(tel_nrdocmto,
                                                         "9999999"),1,6))
                               glb_nrchqcdv = tel_nrdocmto.

                        DO WHILE TRUE:

                           aux_flgerros = FALSE.
                                                         
                           FIND CURRENT crapfdc EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                           IF   NOT AVAILABLE crapfdc   THEN
                                IF   LOCKED crapfdc   THEN
                                     DO:
                                         PAUSE 1 NO-MESSAGE.
                                         NEXT.
                                     END.
                                ELSE
                                     DO:    
                                          ASSIGN glb_cdcritic = 108
                                                 aux_flgerros = TRUE.
                                          LEAVE.
                                     END.
                           LEAVE.

                        END.

                        IF   aux_flgerros   THEN
                             DO:
                                 NEXT-PROMPT tel_nrdocmto WITH FRAME f_landpv.
                                 NEXT.
                             END.    
                        ELSE
                        DO:
                            IF   crapfdc.dtemschq = ?   THEN
                                 DO:          
                                     glb_cdcritic = 108.
                                     NEXT-PROMPT tel_nrdocmto
                                                 WITH FRAME f_landpv.
                                     NEXT.
                                 END.
                            ELSE
                            
                            IF   crapfdc.dtretchq = ?   THEN
                                 DO:
                                     glb_cdcritic = 109.
                                     NEXT-PROMPT tel_nrdocmto
                                                 WITH FRAME f_landpv.
                                     NEXT.
                                 END.
                            ELSE
                            IF   CAN-DO("5,6,7",STRING(crapfdc.incheque))  THEN
                                 DO:
                                     glb_cdcritic = 97.
                                     NEXT-PROMPT tel_nrdocmto
                                                 WITH FRAME f_landpv.
                                     NEXT.
                                 END.
                            ELSE
                            IF   crapfdc.incheque = 8   THEN
                                 DO:
                                     glb_cdcritic = 320.
                                     NEXT-PROMPT tel_nrdocmto
                                                 WITH FRAME f_landpv.
                                     NEXT.
                                 END.
                            ELSE             
                            IF   crapfdc.cdbantic <> 0  OR 
                                 crapfdc.cdagetic <> 0  OR
                                 crapfdc.nrctatic <> 0  THEN
                                 DO:
                                      MESSAGE "Cheque " + 
                                              "Custodiado/Descontado" + 
                                              " em outra IF." SKIP 
                                              "Voce deseja devolver esse " +
                                              "cheque pela alinea 35?" 
                                              VIEW-AS ALERT-BOX 
                                              QUESTION BUTTONS YES-NO TITLE ""
                                              UPDATE aux_devchqtic.
                                        
                                      IF aux_devchqtic THEN
                                          ASSIGN glb_cdcritic = 0
												 glb_dscritic = ""
                                                 aux_cdalinea = 35
                                                 aux_indevchq = 1.

                                 END.
                            ELSE
                            IF  (crapfdc.incheque = 1  OR
                                 crapfdc.incheque = 2) THEN 
                                 DO:         
                                   FIND crapcor WHERE
                                        crapcor.cdcooper = crapfdc.cdcooper  AND
                                        crapcor.cdbanchq = tel_cdbaninf  AND
                                        crapcor.cdagechq = tel_cdageinf  AND
                                        crapcor.nrctachq = tel_nrdctabb  AND
                                        crapcor.nrcheque = glb_nrchqcdv  AND
                                        crapcor.flgativo = TRUE
                                        NO-LOCK NO-ERROR.
                                   
                                   IF   NOT AVAILABLE crapcor   THEN
                                        glb_cdcritic = 101.
                                   
                                   ELSE DO:
                                       FIND craphis WHERE
                                            craphis.cdcooper = crapfdc.cdcooper  AND
                                            craphis.cdhistor = crapcor.cdhistor
                                            NO-LOCK NO-ERROR.
                                   
                                       IF   NOT AVAILABLE craphis   THEN
                                            glb_dscritic = FILL("*",50).
                                       ELSE
                                            glb_dscritic = craphis.dshistor.
                                   
                                       BELL.
                                   
                                       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                   
                                          aux_confirma = "N".
                                   
                                          MESSAGE "Aviso de" crapcor.dtemscor
                                                  "->" glb_dscritic.
                                   
                                          glb_cdcritic = 78.
                                          RUN fontes/critic.p.
                                          BELL.
                                          MESSAGE COLOR NORMAL glb_dscritic
                                                  UPDATE aux_confirma.
                                          LEAVE.
                                   
                                       END.
                                   
                                       IF   KEYFUNCTION(LASTKEY) = "END-ERROR"
                                            OR aux_confirma <> "S" THEN
                                            DO:
                                                glb_cdcritic = 79.
                                                RUN fontes/critic.p.
                                                BELL.
                                                MESSAGE glb_dscritic.
                                                UNDO INICIO, NEXT INICIO.
                                            END.
                                       ELSE
                                          ASSIGN glb_cdcritic = 0
										         glb_dscritic = "".

                                       IF  crapfdc.incheque = 1   THEN
                                           aux_indevchq = 1.

                                       RUN sistema/generico/procedures/b1wgen0175.p PERSISTENT SET h-b1wgen0175.
    
                                       IF VALID-HANDLE(h-b1wgen0175) THEN
                                           DO:
                                               RUN valida-alinea-automatica IN h-b1wgen0175(INPUT glb_cdcooper,
                                                                                            INPUT crapass.nrdconta,
                                                                                            INPUT crapfdc.nrdctabb,
                                                                                            INPUT tel_nrdocmto,
                                                                                            INPUT crapcor.dtvalcor,
                                                                                            INPUT glb_dtmvtolt,
                                                                                            INPUT crapcor.cdhistor,
                                                                                            OUTPUT aux_cdalinea,
                                                                                            OUTPUT TABLE tt-erro).
                                   
                                               DELETE PROCEDURE h-b1wgen0175.
                                   
                                               IF RETURN-VALUE <> "OK" THEN 
                                                  DO:
                                                     FIND FIRST tt-erro NO-LOCK NO-ERROR.

                                                     IF AVAIL tt-erro THEN
                                                        DO:
                                                           ASSIGN glb_cdcritic = tt-erro.cdcritic
                                                                  glb_dscritic = tt-erro.dscritic.
                                                        END.
                                                  END.
                                           END.
                                   
                                   END. /* END do ELSE DO do IF Avail*/

                             END. /* END do IF incheque 1 e 2 */

                        END. /* fim else (sem erros) */
                        
               END.
               ELSE
               IF   
                    tel_cdhistor = 47   OR
                    tel_cdhistor = 49   OR
                    tel_cdhistor = 156  OR
                    tel_cdhistor = 191  THEN
                    DO:

                        glb_nrcalcul = tel_nrdocmto.
                        RUN fontes/numtal.p.

                        DO WHILE TRUE:

                           aux_flgerros = FALSE.
                                                        
                           FIND CURRENT crapfdc EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                           IF   NOT AVAILABLE crapfdc   THEN
                                IF   LOCKED crapfdc   THEN
                                     DO:
                                         PAUSE 1 NO-MESSAGE.
                                         NEXT.
                                     END.
                                ELSE
                                DO:
                                    ASSIGN glb_cdcritic = 108
                                           aux_flgerros = TRUE.
                                    LEAVE.
                                END.
                           LEAVE.
                        END.
                           
                        IF   aux_flgerros   THEN
                             DO:
                                 NEXT-PROMPT tel_nrdocmto WITH FRAME f_landpv.
                                 NEXT.
                             END.    
                        ELSE
                        DO:
                            IF   crapfdc.dtemschq = ?   THEN
                                 DO:
                                     glb_cdcritic = 108.
                                     NEXT-PROMPT tel_nrdocmto
                                                 WITH FRAME f_landpv.
                                     NEXT.
                                 END.
                            ELSE
                            IF   crapfdc.dtretchq = ?   THEN
                                 DO:
                                     glb_cdcritic = 109.
                                     NEXT-PROMPT tel_nrdocmto
                                                 WITH FRAME f_landpv.
                                     NEXT.
                                 END.
                            ELSE
                            IF   crapfdc.incheque = 5   OR
                                 crapfdc.incheque = 6   OR 
                                 crapfdc.incheque = 7   THEN
                                 ASSIGN crapfdc.incheque = crapfdc.incheque - 5
                                        crapfdc.dtliqchq = ?
                                        crapfdc.vlcheque = 0
                                        crapfdc.vldoipmf = 0
                                        crapfdc.cdbandep = 0
                                        crapfdc.cdagedep = 0
                                        crapfdc.nrctadep = 0.
                            ELSE
                            IF   crapfdc.incheque = 8   THEN
                                 DO:
                                     glb_cdcritic = 320.
                                     NEXT-PROMPT tel_nrdocmto
                                                 WITH FRAME f_landpv.
                                     NEXT.
                                 END.
                            ELSE
                                 DO:
                                     glb_cdcritic = 99.
                                     NEXT-PROMPT tel_nrdocmto
                                                 WITH FRAME f_landpv.
                                     NEXT.
                                 END.

                            IF   glb_cdcritic = 0   AND
                                (tel_cdhistor = 47  OR tel_cdhistor = 156 OR 
                                 tel_cdhistor = 191) THEN
                                 ASSIGN aux_indevchq = 2
                                        aux_cdalinea = tel_cdalinea.
                        END.
                    END.
               ELSE
               IF   tel_cdhistor = 59   AND
                    CAN-DO(aux_lsconta2,STRING(tel_nrdctabb))   THEN
                    DO:
                        ASSIGN glb_nrchqsdv = INT(SUBSTR(STRING(tel_nrdocmto,
                                                         "9999999"),1,6))
                               glb_nrchqcdv = tel_nrdocmto.
                        
                        DO WHILE TRUE:

                           aux_flgerros = FALSE.
                                                         
                           FIND CURRENT crapfdc EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                           IF   NOT AVAILABLE crapfdc   THEN
                                IF   LOCKED crapfdc   THEN
                                     DO:
                                         PAUSE 1 NO-MESSAGE.
                                         NEXT.
                                     END.
                                ELSE
                                     DO:
                                          ASSIGN glb_cdcritic = 108
                                                 aux_flgerros = TRUE.
                                          LEAVE.
                                     END.
                           LEAVE.

                        END.

                        IF   aux_flgerros   THEN
                             DO:
                                 NEXT-PROMPT tel_nrdocmto WITH FRAME f_landpv.
                                 NEXT.
                             END.    
                        ELSE
                        DO:
                            IF   crapfdc.dtemschq = ?   THEN
                                 DO:
                                     glb_cdcritic = 108.
                                     NEXT-PROMPT tel_nrdocmto
                                                 WITH FRAME f_landpv.
                                     NEXT.
                                 END.
                            ELSE
                            IF   crapfdc.dtretchq = ?   THEN
                                 DO:
                                     glb_cdcritic = 109.
                                     NEXT-PROMPT tel_nrdocmto
                                                 WITH FRAME f_landpv.
                                     NEXT.
                                 END.
                            ELSE
                            IF   CAN-DO("5,6,7",STRING(crapfdc.incheque))   THEN
                                 DO:
                                     glb_cdcritic = 97.
                                     NEXT-PROMPT tel_nrdocmto
                                                 WITH FRAME f_landpv.
                                     NEXT.
                                 END.
                            ELSE
                            IF   crapfdc.incheque = 8   THEN
                                 DO:
                                     glb_cdcritic = 320.
                                     NEXT-PROMPT tel_nrdocmto
                                                 WITH FRAME f_landpv.
                                     NEXT.
                                 END.
                            ELSE
                            IF   crapfdc.cdbantic <> 0  OR 
                                 crapfdc.cdagetic <> 0  OR
                                 crapfdc.nrctatic <> 0  THEN
                                 DO:
                                      MESSAGE "Cheque " + 
                                              "Custodiado/Descontado" + 
                                              " em outra IF." SKIP
                                              "Voce deseja devolver esse " +
                                              "cheque pela alinea 35?"
                                              VIEW-AS ALERT-BOX 
                                              QUESTION BUTTONS YES-NO TITLE ""
                                              UPDATE aux_devchqtic.
                                      
                                      IF aux_devchqtic THEN
                                          ASSIGN glb_cdcritic = 0
												 glb_dscritic = ""
                                                 aux_cdalinea = 35
                                                 aux_indevchq = 1.

                                 END.
                            ELSE
                            IF   crapfdc.incheque = 1 OR
                                 crapfdc.incheque = 2 THEN
                                 DO: 
                                     FIND crapcor WHERE
                                     crapcor.cdcooper = glb_cdcooper      AND
                                     crapcor.cdbanchq = crapfdc.cdbanchq  AND
                                     crapcor.cdagechq = crapfdc.cdagechq  AND
                                     crapcor.nrctachq = crapfdc.nrctachq  AND
                                     crapcor.nrcheque = glb_nrchqcdv      AND
                                     crapcor.flgativo = TRUE
                                     NO-LOCK NO-ERROR.

                                     IF   NOT AVAILABLE crapcor   THEN
                                          glb_cdcritic = 101.
                                     ELSE
                                     DO:
                                         FIND craphis WHERE
                                              craphis.cdcooper = glb_cdcooper AND
                                              craphis.cdhistor = crapcor.cdhistor
                                              NO-LOCK NO-ERROR.

                                         IF   NOT AVAILABLE craphis   THEN
                                              glb_dscritic = FILL("*",50).
                                         ELSE
                                              glb_dscritic = craphis.dshistor.

                                         BELL.
                                         
                                         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                            aux_confirma = "N".

                                            MESSAGE "Aviso de" crapcor.dtemscor
                                                    "->" glb_dscritic.

                                            glb_cdcritic = 78.
                                            RUN fontes/critic.p.
                                            BELL.
                                            MESSAGE COLOR NORMAL glb_dscritic
                                                    UPDATE aux_confirma.
                                            LEAVE.

                                         END.

                                         IF   KEYFUNCTION(LASTKEY) = "END-ERROR"
                                              OR aux_confirma <> "S" THEN
                                              DO:
                                                  glb_cdcritic = 79.
                                                  RUN fontes/critic.p.
                                                  BELL.
                                                  MESSAGE glb_dscritic.
                                                  UNDO INICIO, NEXT INICIO.
                                              END.
                                         ELSE
                                            ASSIGN glb_cdcritic = 0
												   glb_dscritic = "".

                                         IF   crapfdc.incheque = 1 THEN
                                              aux_indevchq = 3.

                                         RUN sistema/generico/procedures/b1wgen0175.p PERSISTENT SET h-b1wgen0175.
    
                                         IF VALID-HANDLE(h-b1wgen0175) THEN
                                             DO:
                                                 RUN valida-alinea-automatica IN h-b1wgen0175(INPUT glb_cdcooper,
                                                                                              INPUT crapass.nrdconta,
                                                                                              INPUT crapfdc.nrdctabb,
                                                                                              INPUT tel_nrdocmto,
                                                                                              INPUT crapcor.dtvalcor,
                                                                                              INPUT glb_dtmvtolt,
                                                                                              INPUT crapcor.cdhistor,
                                                                                              OUTPUT aux_cdalinea,
                                                                                              OUTPUT TABLE tt-erro).
                                         
                                                 DELETE PROCEDURE h-b1wgen0175.
                                         
                                                 IF RETURN-VALUE <> "OK" THEN 
                                                    DO:
                                                       FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                         
                                                       IF AVAIL tt-erro THEN
                                                          DO:
                                                             ASSIGN glb_cdcritic = tt-erro.cdcritic
                                                                    glb_dscritic = tt-erro.dscritic.
                                                          END.
                                                    END.
                                             END.

                                     END.
                                 END.
                        END.
                    END.
               ELSE
               IF   (tel_cdhistor = 77 OR tel_cdhistor = 78)    AND
                    CAN-DO(aux_lsconta2,STRING(tel_nrdctabb))   THEN
                    DO:
                        DO WHILE TRUE:

                           aux_flgerros = FALSE.
                                                         
                           FIND CURRENT crapfdc EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                           IF   NOT AVAILABLE crapfdc   THEN
                                IF   LOCKED crapfdc   THEN
                                     DO:
                                         PAUSE 1 NO-MESSAGE.
                                         NEXT.
                                     END.
                                ELSE
                                DO:
                                    ASSIGN glb_cdcritic = 108
                                           aux_flgerros = TRUE.
                                    LEAVE.
                                END.
                           LEAVE.
                        END.

                        IF   aux_flgerros   THEN
                             DO:
                                 NEXT-PROMPT tel_nrdocmto WITH FRAME f_landpv.
                                 NEXT.
                             END.    
                        ELSE
                        DO:
                            IF   crapfdc.dtemschq = ?   THEN
                                 DO:
                                     glb_cdcritic = 108.
                                     NEXT-PROMPT tel_nrdocmto
                                                 WITH FRAME f_landpv.
                                     NEXT.
                                 END.
                            ELSE
                            IF   crapfdc.dtretchq = ?   THEN
                                 DO:
                                     glb_cdcritic = 109.
                                     NEXT-PROMPT tel_nrdocmto
                                                 WITH FRAME f_landpv.
                                     NEXT.
                                 END.
                            ELSE
                            IF   crapfdc.incheque = 5   OR
                                 crapfdc.incheque = 6   OR
                                 crapfdc.incheque = 7   THEN
                                 ASSIGN crapfdc.incheque = crapfdc.incheque - 5
                                        crapfdc.dtliqchq = ?
                                        crapfdc.vlcheque = 0
                                        crapfdc.vldoipmf = 0
                                        crapfdc.cdbandep = 0
                                        crapfdc.cdagedep = 0
                                        crapfdc.nrctadep = 0.
                            ELSE
                            IF   crapfdc.incheque = 8   THEN
                                 DO:
                                     glb_cdcritic = 320.
                                     NEXT-PROMPT tel_nrdocmto
                                                 WITH FRAME f_landpv.
                                     NEXT.
                                 END.
                            ELSE
                                 DO:
                                     glb_cdcritic = 99.
                                     NEXT-PROMPT tel_nrdocmto
                                                 WITH FRAME f_landpv.
                                     NEXT.
                                 END.

                            IF   glb_cdcritic = 0   AND
                                 tel_cdhistor = 78  THEN
                                 ASSIGN aux_indevchq = 4
                                        aux_cdalinea = tel_cdalinea.
                        END.
                    END.
               ELSE
               IF  (tel_cdhistor = 26   OR
                    tel_cdhistor = 526) AND
                    CAN-DO(aux_lsconta3,STRING(tel_nrdctabb))   THEN
                    DO:
                        ASSIGN glb_nrchqsdv = INT(SUBSTR(STRING(tel_nrdocmto,
                                                         "9999999"),1,6))
                               glb_nrchqcdv = tel_nrdocmto.

                        DO WHILE TRUE:

                           aux_flgerros = FALSE.
                                                         
                           FIND CURRENT crapfdc EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                           IF   NOT AVAILABLE crapfdc   THEN
                                IF   LOCKED crapfdc   THEN
                                     DO:
                                         PAUSE 1 NO-MESSAGE.
                                         NEXT.
                                     END.
                                ELSE
                                     DO:
                                          ASSIGN glb_cdcritic = 286
                                                 aux_flgerros = TRUE.
                                          LEAVE.
                                     END.
                           LEAVE.

                        END.   /*  Fim do DO WHILE TRUE  */

                        IF   aux_flgerros   THEN
                             DO:
                                 NEXT-PROMPT tel_nrdocmto WITH FRAME f_landpv.
                                 NEXT.
                             END.    
                        ELSE
                        DO:
                            IF   CAN-DO("5,7",STRING(crapfdc.incheque))   THEN
                                 DO:
                                     glb_cdcritic = 97.
                                     NEXT-PROMPT tel_nrdocmto
                                                 WITH FRAME f_landpv.
                                     NEXT.
                                 END.
                            ELSE
                            IF   crapfdc.cdbantic <> 0  OR 
                                 crapfdc.cdagetic <> 0  OR
                                 crapfdc.nrctatic <> 0  THEN
                                 DO:
                                      MESSAGE "Cheque " + 
                                              "Custodiado/Descontado" + 
                                              " em outra IF." SKIP
                                              "Voce deseja devolver esse " +
                                              "cheque pela alinea 35?"
                                              VIEW-AS ALERT-BOX
                                              QUESTION BUTTONS YES-NO TITLE ""
                                              UPDATE aux_devchqtic.
                                      
                                      IF aux_devchqtic THEN
                                          ASSIGN glb_cdcritic = 0
											     glb_dscritic = ""
                                                 aux_cdalinea = 35
                                                 aux_indevchq = 1.

                                 END.
                            ELSE
                            IF   crapfdc.incheque = 1 THEN
                                 DO:  
                                     FIND crapcor WHERE
                                     crapcor.cdcooper = glb_cdcooper     AND
                                     crapcor.cdbanchq = crapfdc.cdbanchq AND
                                     crapcor.cdagechq = crapfdc.cdagechq AND
                                     crapcor.nrctachq = crapfdc.nrctachq AND
                                     crapcor.nrcheque = glb_nrchqcdv     AND
                                     crapcor.flgativo = TRUE
                                     NO-LOCK NO-ERROR.

                                     IF   NOT AVAILABLE crapcor   THEN
                                          glb_cdcritic = 101.
                                     ELSE
                                     DO:
                                         FIND craphis WHERE
                                              craphis.cdcooper = glb_cdcooper AND
                                              craphis.cdhistor = crapcor.cdhistor
                                              NO-LOCK NO-ERROR.

                                         IF   NOT AVAILABLE craphis   THEN
                                              glb_dscritic = FILL("*",50).
                                         ELSE 
                                              glb_dscritic = craphis.dshistor.
                                         
                                         BELL.
                                         MESSAGE "Contra-ordem de"
                                                 crapcor.dtemscor "->"
                                                 glb_dscritic.

                                         UNDO INICIO, NEXT INICIO.
                                     END.
                                 END.
                            ELSE
                            IF   crapfdc.incheque = 2   THEN
                                 DO:  
                                     FIND crapcor WHERE
                                     crapcor.cdcooper = glb_cdcooper     AND
                                     crapcor.cdbanchq = crapfdc.cdbanchq AND
                                     crapcor.cdagechq = crapfdc.cdagechq AND
                                     crapcor.nrctachq = crapfdc.nrctachq AND
                                     crapcor.nrcheque = glb_nrchqcdv     AND
                                     crapcor.flgativo = TRUE
                                     NO-LOCK NO-ERROR.

                                     IF   NOT AVAILABLE crapcor   THEN
                                          glb_cdcritic = 101.
                                     ELSE
                                     DO:
                                         FIND craphis WHERE
                                              craphis.cdcooper = glb_cdcooper AND
                                              craphis.cdhistor = crapcor.cdhistor
                                              NO-LOCK NO-ERROR.

                                         IF   NOT AVAILABLE craphis   THEN
                                              glb_dscritic = FILL("*",50).
                                         ELSE 
                                              glb_dscritic = craphis.dshistor.

                                         BELL.

                                         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                            aux_confirma = "N".

                                            MESSAGE "Aviso de" crapcor.dtemscor
                                                    "->" glb_dscritic.

                                            glb_cdcritic = 78.
                                            RUN fontes/critic.p.
                                            BELL.
                                            MESSAGE COLOR NORMAL glb_dscritic
                                                    UPDATE aux_confirma.
                                            LEAVE.

                                         END.

                                         IF   KEYFUNCTION(LASTKEY) = "END-ERROR"
                                              OR aux_confirma <> "S" THEN
                                              DO:
                                                  glb_cdcritic = 79.
                                                  RUN fontes/critic.p.
                                                  BELL.
                                                  MESSAGE glb_dscritic.
                                                  UNDO INICIO, NEXT INICIO.
                                              END.
                                         ELSE
                                              ASSIGN glb_cdcritic = 0
											         glb_dscritic = "".
                                     END.
                                 END.
                            ELSE
                            IF   crapfdc.incheque = 8   THEN
                                 DO:
                                     glb_cdcritic = 320.
                                     NEXT-PROMPT tel_nrdocmto
                                                 WITH FRAME f_landpv.
                                     NEXT.
                                 END.
                        END.

                        IF   glb_cdcritic = 0   THEN
                             DO:
                                 FIND crapsld WHERE
                                      crapsld.cdcooper = glb_cdcooper AND
                                      crapsld.nrdconta = aux_nrdconta
                                      NO-LOCK NO-ERROR.

                                 IF   NOT AVAILABLE crapsld   THEN
                                      glb_cdcritic = 10.
                                 ELSE
                                      DO:
                                          aux_vlsdchsl = crapsld.vlsdchsl.

                                          FOR EACH craplcm WHERE
                                                   craplcm.cdcooper = 
                                                           glb_cdcooper     AND
                                                   craplcm.nrdconta =
                                                           crapsld.nrdconta AND
                                                   craplcm.dtmvtolt = 
                                                           glb_dtmvtolt     AND
                                                   craplcm.cdhistor <> 289
                                                   USE-INDEX craplcm2 NO-LOCK:

                                             FIND craphis WHERE
                                                  craphis.cdcooper = glb_cdcooper AND
                                                  craphis.cdhistor = craplcm.cdhistor
                                                  NO-LOCK NO-ERROR.

                                             IF   NOT AVAILABLE craphis   THEN
                                                  DO:
                                                      glb_cdcritic = 80.
                                                      LEAVE.
                                                  END.

                                             IF   craphis.inhistor = 2   THEN
                                                  aux_vlsdchsl = aux_vlsdchsl +
                                                          craplcm.vllanmto.
                                             ELSE
                                             IF   craphis.inhistor = 12   THEN
                                                  aux_vlsdchsl = aux_vlsdchsl -
                                                          craplcm.vllanmto.
                                             ELSE
                                                  NEXT.
                                          END.

                                          IF   glb_cdcritic = 0   THEN
                                               IF    aux_vlsdchsl <
                                                         tel_vllanmto   THEN
                                                     glb_cdcritic = 135.
                                      END.
                             END.
                    END.
               ELSE
               IF   tel_cdhistor = 101   THEN
                    DO:
                        FIND craplcm WHERE craplcm.cdcooper = glb_cdcooper  AND
                                           craplcm.nrdconta = tel_nrdctabb  AND
                                           craplcm.dtmvtolt = glb_dtmvtolt  AND
                                           craplcm.cdhistor = 26            AND
                                           craplcm.nrdocmto = tel_nrdocmto
                                           USE-INDEX craplcm2 NO-LOCK NO-ERROR.

                        IF   NOT AVAILABLE craplcm    THEN 
                            glb_cdcritic = 99.
                        ELSE
                        IF   craplcm.vllanmto <> tel_vllanmto   THEN
                             glb_cdcritic = 91.

                    END.
               ELSE
               IF  tel_cdhistor = 1918 THEN /*CREDITO TED PORTABILIDADE*/
                   DO:

                        FIND tbepr_portabilidade WHERE tbepr_portabilidade.cdcooper = glb_cdcooper
                                                   AND tbepr_portabilidade.nrdconta = aux_nrdconta
                                                   AND tbepr_portabilidade.nrctremp = tel_nrctremp
                                                   AND tbepr_portabilidade.tpoperacao = 2 
                                                   EXCLUSIVE-LOCK NO-ERROR.

                        IF  AVAIL tbepr_portabilidade THEN
                            DO:
                                ASSIGN tbepr_portabilidade.dtliquidacao = glb_dtmvtolt.
                            END.
                        ELSE
                            DO:
                                ASSIGN glb_cdcritic = 0
                                       glb_dscritic = "Proposta de portabilidade nao encontrada.".
                            END.
                   END.
               IF   aux_inhistor = 12   THEN
                    DO:
                        FIND crapsld WHERE crapsld.cdcooper = glb_cdcooper AND
                                           crapsld.nrdconta = aux_nrdconta
                                           NO-LOCK NO-ERROR.

                        IF   NOT AVAILABLE crapsld   THEN
                             glb_cdcritic = 10.
                        ELSE
                             DO:
                                 aux_vlsdchsl = crapsld.vlsdchsl.

                                 FOR EACH craplcm WHERE
                                          craplcm.cdcooper = glb_cdcooper  AND
                                          craplcm.nrdconta = 
                                                  crapsld.nrdconta         AND
                                          craplcm.dtmvtolt = glb_dtmvtolt  AND
                                          craplcm.cdhistor <> 289
                                          USE-INDEX craplcm2 NO-LOCK:

                                      FIND craphis WHERE
                                           craphis.cdcooper = glb_cdcooper AND
                                           craphis.cdhistor = craplcm.cdhistor
                                           NO-LOCK NO-ERROR.

                                      IF   NOT AVAILABLE craphis   THEN
                                           DO:
                                               glb_cdcritic = 80.
                                               LEAVE.
                                           END.

                                      IF   craphis.inhistor = 2   THEN
                                           aux_vlsdchsl = aux_vlsdchsl +
                                                          craplcm.vllanmto.
                                      ELSE
                                      IF   craphis.inhistor = 12   THEN
                                           aux_vlsdchsl = aux_vlsdchsl -
                                                          craplcm.vllanmto.
                                      ELSE
                                           NEXT.
                                 END.

                                 IF   glb_cdcritic = 0   THEN
                                      IF    aux_vlsdchsl < tel_vllanmto   THEN
                                            glb_cdcritic = 135.
                             END.
                    END.
               ELSE
               IF   aux_inhistor >= 13   AND   aux_inhistor <= 15   THEN
                    DO:
                        DO WHILE TRUE:
                                                                  
                           FIND FIRST crapdpb WHERE
                                      crapdpb.cdcooper = glb_cdcooper   AND
                                      crapdpb.nrdconta = aux_nrdconta   AND
                                      crapdpb.nrdocmto = tel_nrdocmto   AND
                                      crapdpb.dtliblan > glb_dtmvtolt   AND
                                      crapdpb.inlibera = 1 
                                      USE-INDEX crapdpb2 EXCLUSIVE-LOCK
                                      NO-ERROR NO-WAIT.

                           IF   NOT AVAILABLE crapdpb   THEN
                                IF   LOCKED crapdpb   THEN
                                     DO:
                                         PAUSE 1 NO-MESSAGE.
                                         NEXT.
                                     END.
                                ELSE
                                     glb_cdcritic = 82.
                           ELSE
                                DO:
                                    IF   crapdpb.vllanmto < tel_vllanmto   THEN
                                         glb_cdcritic = 269.
                                    ELSE
                                    IF   crapdpb.inlibera = 2   THEN
                                         glb_cdcritic = 220.
                                END.

                           LEAVE.

                        END.  /*  Fim do DO WHILE TRUE  */

                        IF   glb_cdcritic > 0   THEN
                             DO:
                                 RUN fontes/critic.p.
                                 BELL.
                                 CLEAR FRAME f_landpv.
                                 ASSIGN glb_cddopcao = aux_cddopcao
                                        tel_dtmvtolt = aux_dtmvtolt
                                        tel_cdagenci = aux_cdagenci
                                        tel_cdbccxlt = aux_cdbccxlt
                                        tel_nrdolote = aux_nrdolote
                                        tel_cdhistor = aux_cdhistor
                                        tel_nrdctabb = aux_nrdctabb
                                        tel_nrdocmto = aux_nrdocmto
                                        tel_vllanmto = aux_vllanmto
                                        tel_dtliblan = aux_dtliblan
                                        tel_cdalinea = aux_cdalinea.

                                 DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                                         tel_cdbccxlt tel_nrdolote tel_cdhistor
                                         tel_nrdctabb tel_cdbaninf tel_cdageinf
                                         tel_nrdocmto tel_vllanmto tel_dtliblan
                                         tel_cdalinea WITH FRAME f_landpv.
                                 MESSAGE glb_dscritic.
                                 UNDO INICIO, NEXT INICIO.
                             END.

                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                           aux_confirma = "N".

                           glb_cdcritic = 78.
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE COLOR NORMAL glb_dscritic
                                                UPDATE aux_confirma.
                           LEAVE.

                        END.

                        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                             aux_confirma <> "S"   THEN
                             DO:
                                 glb_cdcritic = 79.
                                 RUN fontes/critic.p.
                                 BELL.
                                 MESSAGE glb_dscritic.
                                 UNDO INICIO, NEXT INICIO.
                             END.
                        ELSE
                             ASSIGN glb_cdcritic = 0
									glb_dscritic = "".

                        FIND crapsld WHERE crapsld.cdcooper = glb_cdcooper AND
                                           crapsld.nrdconta = aux_nrdconta
                                           NO-LOCK NO-ERROR.

                        IF   NOT AVAILABLE crapsld   THEN
                             glb_cdcritic = 10.
                        ELSE
                             DO:
                                 ASSIGN aux_vlsdbloq = crapsld.vlsdbloq
                                        aux_vlsdblpr = crapsld.vlsdblpr
                                        aux_vlsdblfp = crapsld.vlsdblfp.

                                 FOR EACH craplcm WHERE
                                          craplcm.cdcooper = glb_cdcooper  AND
                                          craplcm.nrdconta =
                                                  crapsld.nrdconta         AND
                                          craplcm.dtmvtolt = glb_dtmvtolt  AND
                                          craplcm.cdhistor <> 289
                                          USE-INDEX craplcm2 NO-LOCK:

                                      FIND craphis WHERE
                                           craphis.cdcooper = glb_cdcooper AND
                                           craphis.cdhistor = craplcm.cdhistor
                                           NO-LOCK NO-ERROR.

                                      IF   NOT AVAILABLE craphis   THEN
                                           DO:
                                               glb_cdcritic = 80.
                                               LEAVE.
                                           END.

                                      IF   craphis.inhistor = 3   THEN
                                           aux_vlsdbloq = aux_vlsdbloq +
                                                          craplcm.vllanmto.
                                      ELSE
                                      IF   craphis.inhistor = 4   THEN
                                           aux_vlsdblpr = aux_vlsdblpr +
                                                          craplcm.vllanmto.
                                      ELSE
                                      IF   craphis.inhistor = 5   THEN
                                           aux_vlsdblfp = aux_vlsdblfp +
                                                          craplcm.vllanmto.
                                      ELSE
                                      IF   craphis.inhistor = 13   THEN
                                           aux_vlsdbloq = aux_vlsdbloq -
                                                          craplcm.vllanmto.
                                      ELSE
                                      IF   craphis.inhistor = 14   THEN
                                           aux_vlsdblpr = aux_vlsdblpr -
                                                          craplcm.vllanmto.
                                      ELSE
                                      IF   craphis.inhistor = 15   THEN
                                           aux_vlsdblfp = aux_vlsdblfp -
                                                          craplcm.vllanmto.
                                      ELSE
                                           NEXT.
                                 END.

                                 IF   glb_cdcritic = 0   THEN
                                      IF   aux_inhistor = 13   THEN
                                           DO:
                                             IF aux_vlsdbloq < tel_vllanmto THEN
                                                glb_cdcritic = 136.
                                           END.
                                      ELSE
                                      IF   aux_inhistor = 14   THEN
                                           DO:
                                             IF aux_vlsdblpr < tel_vllanmto THEN
                                                glb_cdcritic = 136.
                                           END.
                                      ELSE
                                      IF   aux_inhistor = 15   THEN
                                           DO:
                                             IF aux_vlsdblfp < tel_vllanmto THEN
                                                glb_cdcritic = 136.
                                           END.
                             END.
                    END.
               
               IF   glb_cdcritic = 0   THEN
                    DO:  
                        FIND craplcm WHERE craplcm.cdcooper = glb_cdcooper AND
                                           craplcm.dtmvtolt = tel_dtmvtolt AND
                                           craplcm.cdagenci = tel_cdagenci AND
                                           craplcm.cdbccxlt = tel_cdbccxlt AND
                                           craplcm.nrdolote = tel_nrdolote AND
                                           craplcm.nrdctabb = tel_nrdctabb AND
                                           craplcm.nrdocmto = tel_nrdocmto
                                           USE-INDEX craplcm1 NO-LOCK NO-ERROR.

                        IF   AVAILABLE craplcm   THEN
                             DO:
                                 glb_cdcritic = 999.
                                 NEXT-PROMPT tel_nrdocmto WITH FRAME f_landpv.
                                 NEXT.
                             END.
                    END.
           END. 
          
      IF   glb_cdcritic = 0  AND
           aux_indevchq > 0  THEN
           DO:            
               IF   aux_flctatco = YES THEN 
                    DO: 
                        RUN pi_cria_dev (INPUT craptco.cdcopant,  /* Cooperativa */
                                         INPUT glb_dtmvtolt,
                                         INPUT crapfdc.cdbanchq,
                                         INPUT 1,
                                         INPUT craptco.nrctaant, /* Cta Coop 2*/
                                         INPUT tel_nrdocmto,
                                         INPUT IF   crapfdc.nrdctitg <> "" THEN
                                                    glb_dsdctitg
                                                ELSE "",
                                         INPUT tel_vllanmto,
                                         INPUT aux_cdalinea,
                                         INPUT IF  (aux_indevchq = 1  OR 
                                                    aux_indevchq = 2) THEN 
                                                    47
                                               ELSE 78,         
                                         INPUT glb_cdoperad,
                                         INPUT crapfdc.cdagechq,
                                         INPUT crapfdc.nrctachq,         
                                         OUTPUT glb_cdcritic).

                    END.
               ELSE 
                    DO:
                        /* Limpar variavel global */
                        glb_nrdrecid = 0.
                        
                        /*************************************************************************************
                         * Verifica se lançamento de devolução se refere a cheque de custodia/desconto e     *
                         * nesse caso grava a informação desse lançamento na glb_nrdrecid para que a         *
                         * informação do campo cdpesqbb da craplcm seja gravado no campo cdpesqui da crapdev *
                         *************************************************************************************/
                        FIND FIRST craxlcm WHERE craxlcm.cdcooper =  glb_cdcooper 
                                             AND craxlcm.dtmvtolt >= glb_dtmvtoan
                                             AND craxlcm.dtmvtolt <= glb_dtmvtolt
                                             AND craxlcm.nrdconta =  aux_nrdconta
                                             AND craxlcm.nrdocmto =  tel_nrdocmto
                                             AND craxlcm.vllanmto =  tel_vllanmto
                                             AND craxlcm.cdagenci =  1
                                             AND craxlcm.cdbccxlt =  100
                                             AND ((craxlcm.nrdolote = 4500 
                                             AND craxlcm.cdhistor = 21) 
                                              OR (craxlcm.nrdolote =  4501 
                                             AND craxlcm.cdhistor = 521))
                                             NO-LOCK NO-ERROR.
                                             
                        IF  AVAILABLE craxlcm THEN
                            glb_nrdrecid = RECID(craxlcm).
                            
                        RUN fontes/geradev.p 
                                (INPUT glb_cdcooper,
                                 INPUT glb_dtmvtolt,
                                 INPUT crapfdc.cdbanchq,
                                 INPUT aux_indevchq,
                                 INPUT aux_nrdconta,
                                 INPUT tel_nrdocmto, 
                                 INPUT IF crapfdc.nrdctitg <> "" THEN 
                                           glb_dsdctitg
                                       ELSE
                                           "",
                                 INPUT tel_vllanmto, 
                                 INPUT aux_cdalinea,
                                 INPUT IF (aux_indevchq = 1 OR 
                                           aux_indevchq = 2) 
                                          THEN 47
                                          ELSE 78,         
                                 INPUT glb_cdoperad,
                                 INPUT crapfdc.cdagechq,
                                 INPUT crapfdc.nrctachq,
                                 INPUT "landpvi",
                                 OUTPUT glb_cdcritic,
                                 OUTPUT glb_dscritic).
                         
                        IF  glb_cdcritic <> 0 OR glb_dscritic <> "" THEN
                        DO:
                            IF glb_dscritic = "" THEN
                               DO:
                                  RUN fontes/critic.p.
                                  BELL.
                               END.

                            MESSAGE glb_dscritic.
                            PAUSE(3) NO-MESSAGE.
                            ASSIGN glb_dscritic = "".
                            UNDO , NEXT INICIO.
                        END.

                        IF   LENGTH(STRING(tel_nrdocmto)) > 9   THEN
                             DO:
                                 MESSAGE "Numero do Documento maior" + 
                                         " do que o permitido.".
                                 PAUSE(3) NO-MESSAGE.
                                 UNDO , NEXT INICIO.
                             END.

                   /* criar registro no crapdev para aparecer na tela devolu e 
                      poder fazer exclusao atraves da tela lote, landpv odair */

                        IF   NOT CAN-FIND(crapdev WHERE 
                                 crapdev.cdcooper = glb_cdcooper       AND
                                 crapdev.cdbanchq = crapfdc.cdbanchq   AND
                                 crapdev.cdagechq = crapfdc.cdagechq   AND
                                 crapdev.nrctachq = crapfdc.nrctachq   AND
                                 crapdev.nrcheque = INTE(tel_nrdocmto) AND
                                 crapdev.cdhistor = IF (aux_indevchq = 1 OR 
                                                        aux_indevchq = 2) 
                                                        THEN 47
                                                        ELSE 78)  THEN
                             DO:  
                                 CREATE crapdev.
                                 ASSIGN crapdev.cdcooper = glb_cdcooper
                                        crapdev.dtmvtolt = glb_dtmvtolt
                                        crapdev.cdbccxlt = crapfdc.cdbanchq
                                        crapdev.nrdconta = aux_nrdconta
                                        crapdev.nrdctabb = tel_nrdctabb
                                        crapdev.nrdctitg = crapfdc.nrdctitg
                                        crapdev.nrcheque = tel_nrdocmto
                                        crapdev.vllanmto = tel_vllanmto
                                        crapdev.cdalinea = aux_cdalinea
                                        crapdev.cdoperad = glb_cdoperad
                                        crapdev.cdhistor = 
                                                   IF (aux_indevchq = 1 OR 
                                                      aux_indevchq = 2) 
                                                      THEN 47
                                                      ELSE 78
                                        crapdev.insitdev = 1   /* feito */
                                        crapdev.indctitg = IF crapass.nrdctitg =
                                                              glb_dsdctitg
                                                           THEN TRUE
                                                           ELSE FALSE
                                        crapdev.cdbanchq = crapfdc.cdbanchq
                                        crapdev.cdagechq = crapfdc.cdagechq
                                        crapdev.nrctachq = crapfdc.nrctachq.
                                 
                                 /* Se glb_nrdrecid for diferente de zero quer dizer que encontrou craxlcm */
                                 IF  glb_nrdrecid <> 0 AND AVAILABLE craxlcm THEN 
                                     ASSIGN crapdev.cdpesqui = craxlcm.cdpesqbb.
                                     
                                 VALIDATE crapdev.

                             END.                                            
                    END. /* END do IF conta TCO */
           END. /* END do IF glb_cdcritic = 0 */
                                 
      IF   glb_cdcritic > 0   OR 
          (glb_dscritic <> "" AND tel_cdhistor = 1918) THEN
           DO:
               IF   tel_cdhistor <> 1918  THEN
                    RUN fontes/critic.p.
                    
               BELL.
               CLEAR FRAME f_landpv.
               ASSIGN glb_cddopcao = aux_cddopcao
                      tel_dtmvtolt = aux_dtmvtolt
                      tel_cdagenci = aux_cdagenci
                      tel_cdbccxlt = aux_cdbccxlt
                      tel_nrdolote = aux_nrdolote
                      tel_cdhistor = aux_cdhistor
                      tel_nrdctabb = aux_nrdctabb
                      tel_nrdocmto = aux_nrdocmto
                      tel_vllanmto = aux_vllanmto
                      tel_dtliblan = aux_dtliblan
                      tel_cdalinea = aux_cdalinea.

               DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                       tel_cdbccxlt tel_nrdolote tel_cdhistor
                       tel_nrdctabb tel_cdbaninf tel_cdageinf
                       tel_nrdocmto tel_vllanmto tel_dtliblan
                       tel_cdalinea WITH FRAME f_landpv.
               MESSAGE glb_dscritic.
               ASSIGN glb_dscritic = "".
               PAUSE 2 NO-MESSAGE.
               UNDO, NEXT INICIO.
           END.

      IF   aux_maischeq = 0  THEN
           DO:

               IF  tel_cdhistor = 481 THEN /* Creditar na Conta de invest. */
                   DO:
                      RUN gera_lancamentos_craplci_credito.
                      
                      IF glb_cdcritic <> 0 THEN
                         UNDO , NEXT INICIO.
                   END.

               IF  tel_cdhistor = 483 THEN /* Debitar na Conta de invest. */
                   DO:
                      RUN gera_lancamentos_craplci_debito.
                      
                      IF glb_cdcritic <> 0 THEN
                         UNDO , NEXT INICIO.
                   END.

               IF   aux_flctatco THEN
                    DO:
                        IF   tel_cdbaninf = 1    AND
                             tel_cdageinf = 3420 THEN
                             aux_nrdctabb = tel_nrdctabb.
                        ELSE    
                             aux_nrdctabb = aux_nrdconta.
                    END.     
               ELSE 
                    aux_nrdctabb = tel_nrdctabb.

/*INICIO renato PJ450*/

             IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
                 RUN sistema/generico/procedures/b1wgen0200.p 
                     PERSISTENT SET h-b1wgen0200.

/* inicio chamada rotina nova de gravaçao do lançamento*/

             IF (tel_cdhistor = 24  OR 
                   tel_cdhistor = 27  OR
                   tel_cdhistor = 47  OR
                   tel_cdhistor = 78  OR
                   tel_cdhistor = 156 OR 
                   tel_cdhistor = 191 OR 
                   tel_cdhistor = 399) OR
                   (tel_cdhistor = 351  AND tel_cdalinea > 0) THEN vr_cdpesqbb = STRING(tel_cdalinea,"99").
             ELSE IF  tel_cdhistor = 275 OR
                        tel_cdhistor = 317 OR
                        tel_cdhistor = 3501 OR
                        tel_cdhistor = 394 OR
                        tel_cdhistor = 428 OR
                        tel_cdhistor = 506 THEN vr_cdpesqbb = STRING(his_nrctremp,"99,999,999").
             ELSE IF  tel_cdhistor = 104 OR
                        tel_cdhistor = 302 OR 
                        tel_cdhistor = 1806 THEN vr_cdpesqbb = STRING(tel_nrctatrf).
             ELSE vr_cdpesqbb = "".

             IF   AVAIL craptco AND tel_cdbaninf = 85  THEN
                  vr_nrctachq = craptco.nrctaant.
             ELSE vr_nrctachq = tel_nrdctabb.
             IF   AVAIL craptco AND tel_cdbaninf = 85  THEN
                  vr_nrdctabb = craptco.nrdconta.
             ELSE vr_nrdctabb = aux_nrdctabb.
                          
             RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
                         (INPUT tel_dtmvtolt                 /*par_dtmvtolt*/
                         ,INPUT tel_cdagenci                 /*par_cdagenci*/
                         ,INPUT tel_cdbccxlt                 /*par_cdbccxlt*/
                         ,INPUT tel_nrdolote                 /*par_nrdolote*/
                         ,INPUT aux_nrdconta                 /*par_nrdconta*/
                         ,INPUT tel_nrdocmto                 /*par_nrdocmto*/
                         ,INPUT tel_cdhistor                 /*par_cdhistor*/
                         ,INPUT tel_nrseqdig                 /*par_nrseqdig*/
                         ,INPUT tel_vllanmto                 /*par_vllanmto*/
                         ,INPUT vr_nrdctabb                  /*par_nrdctabb*/
                         ,INPUT vr_cdpesqbb                  /*par_cdpesqbb*/
                         ,INPUT 0                            /*par_vldoipmf*/
                         ,INPUT tel_nrautdoc                 /*par_nrautdoc*/
                         ,INPUT 0                            /*par_nrsequni*/
                         ,INPUT tel_cdbaninf                 /*par_cdbanchq*/
                         ,INPUT 0                            /*par_cdcmpchq*/
                         ,INPUT tel_cdageinf                 /*par_cdagechq*/
                         ,INPUT vr_nrctachq                  /*par_nrctachq*/
                         ,INPUT 0                            /*par_nrlotchq*/
                         ,INPUT 0                            /*par_sqlotchq*/
                         ,INPUT tel_dtmvtolt                 /*par_dtrefere*/
                         ,INPUT TIME                         /*par_hrtransa*/
                         ,INPUT glb_cdoperad                 /*par_cdoperad*/
                         ,INPUT ""                           /*par_dsidenti*/
                         ,INPUT glb_cdcooper                 /*par_cdcooper*/
                         ,INPUT crapass.nrdctitg             /*par_nrdctitg*/
                         ,INPUT ""                           /*par_dscedent*/
                         ,INPUT 0                            /*par_cdcoptfn*/
                         ,INPUT 0                            /*par_cdagetfn*/
                         ,INPUT 0                            /*par_nrterfin*/
                         ,INPUT 0                            /*par_nrparepr*/
                         ,INPUT 0                            /*par_nrseqava*/
                         ,INPUT 0                            /*par_nraplica*/
                         ,INPUT 0                            /*par_cdorigem*/
                         ,INPUT 0                            /*par_idlautom*/
                         ,INPUT 0                            /*par_inprolot */
                         ,INPUT 0                            /*par_tplotmov */
                         ,OUTPUT TABLE tt-ret-lancto
                         ,OUTPUT aux_incrineg
                         ,OUTPUT aux_cdcritic
                         ,OUTPUT aux_dscritic).
       
             IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
             DO:   
               IF aux_incrineg = 1 THEN
                 DO:
                   /* Tratativas de negocio */  
                   MESSAGE  aux_cdcritic  aux_dscritic  aux_incrineg VIEW-AS ALERT-BOX.     
                   PAUSE(3) NO-MESSAGE.
                   UNDO , NEXT INICIO.
                 END.
               ELSE
                 DO:
                   MESSAGE  aux_cdcritic  aux_dscritic  aux_incrineg VIEW-AS ALERT-BOX.     
                   PAUSE(3) NO-MESSAGE.
                   UNDO , NEXT INICIO.
                 END.
             END.

             ASSIGN /* RENATO PJ450*/
                craplot.nrseqdig = tel_nrseqdig
                craplot.qtcompln = craplot.qtcompln + 1.

             FIND FIRST tt-ret-lancto.
             
             FIND FIRST craplcm 
                WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm
                      NO-ERROR.
             IF NOT AVAILABLE craplcm THEN
                DO:
                   MESSAGE "Erro ao ler CRAPLCM=" tt-ret-lancto.recid_lcm.
                   PAUSE(3) NO-MESSAGE.
                   UNDO , NEXT INICIO.
                END.

             DELETE PROCEDURE h-b1wgen0200.       

/*FIM renato PJ450*/
/*
               CREATE craplcm.
               ASSIGN craplcm.cdcooper = glb_cdcooper
                      craplcm.cdoperad = glb_cdoperad
                      craplcm.dtmvtolt = tel_dtmvtolt 
                      craplcm.dtrefere = glb_dtmvtolt
                      craplcm.cdagenci = tel_cdagenci
                      craplcm.cdbccxlt = tel_cdbccxlt 
                      craplcm.nrdolote = tel_nrdolote
                      craplcm.nrdconta = aux_nrdconta

                      /* Quando for cheque de conta incorporada, a variavel
                         aux_nrdctabb permanecera com a nova conta, por isso eh
                         necessario este tratamento */
                      craplcm.nrdctabb = IF   AVAIL craptco AND 
                                              tel_cdbaninf = 85  THEN
                                              craptco.nrdconta
                                         ELSE aux_nrdctabb

                      craplcm.nrdctitg = crapass.nrdctitg
                      craplcm.nrdocmto = tel_nrdocmto
                      craplcm.vllanmto = tel_vllanmto 
                      craplcm.cdhistor = tel_cdhistor
                      craplcm.nrseqdig = tel_nrseqdig
                      craplcm.nrautdoc = tel_nrautdoc
                      craplcm.cdbanchq = tel_cdbaninf
                      craplcm.cdagechq = tel_cdageinf

                      /* Quando for cheque de conta incorporada, a variavel
                         tel_nrdctabb permanecera com a nova conta, por isso eh
                         necessario este tratamento */
                      craplcm.nrctachq = IF   AVAIL craptco AND 
                                              tel_cdbaninf = 85  THEN
                                              craptco.nrctaant
                                         ELSE tel_nrdctabb

                      craplcm.cdpesqbb = IF (tel_cdhistor = 24  OR
                                             tel_cdhistor = 27  OR
                                             tel_cdhistor = 47  OR
                                             tel_cdhistor = 78  OR
                                             tel_cdhistor = 156 OR 
                                             tel_cdhistor = 191 OR 
                                             tel_cdhistor = 399) OR
                                            (tel_cdhistor = 351  AND
                                             tel_cdalinea > 0) 
                                         THEN STRING(tel_cdalinea,"99")
                                         ELSE IF  tel_cdhistor = 275 OR
                                                  tel_cdhistor = 317 OR
                                                  tel_cdhistor = 3501 OR
                                                  tel_cdhistor = 394 OR
                                                  tel_cdhistor = 428 OR
                                                  tel_cdhistor = 506 THEN
                                               STRING(his_nrctremp,"99,999,999") 
                                         ELSE IF  tel_cdhistor = 104 OR
                                                  tel_cdhistor = 302 OR 
                                                  tel_cdhistor = 1806 THEN
                                                  STRING(tel_nrctatrf)
                                               ELSE ""

                      craplot.nrseqdig = tel_nrseqdig
                      craplot.qtcompln = craplot.qtcompln + 1.

               VALIDATE craplcm.
*/
               IF   aux_indebcre = "D"   THEN
                    craplot.vlcompdb = craplot.vlcompdb + tel_vllanmto.
               ELSE
               IF   aux_indebcre = "C"   THEN
                    craplot.vlcompcr = craplot.vlcompcr + tel_vllanmto.

               /** Log para lancamento de prejuizo **/
               IF  tel_cdhistor = 350 THEN 
                   RUN gera_log_prejuizo.
               
               IF tel_cdhistor = 275 THEN 
                   DO:
                       RUN proc_gerar_log (INPUT glb_cdcooper, 
                                           INPUT glb_cdoperad,
                                           INPUT "",
                                           INPUT "AIMARO",
                                           INPUT "Pag. Emp/Fin Nr " + STRING(tel_nrctremp) + " Deb. Conta",
                                           INPUT TRUE,
                                           INPUT 1,
                                           INPUT "LANDPV",
                                           INPUT aux_nrdconta,
                                          OUTPUT aux_nrdrowid).
                                           
                       RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                INPUT "vlpagpar", 
                                                INPUT STRING(tel_vllanmto),
                                                INPUT STRING(tel_vllanmto)).
                   END.

               IF tel_cdhistor = 108 THEN 
                   DO:
                       RUN proc_gerar_log (INPUT glb_cdcooper, 
                                           INPUT glb_cdoperad,
                                           INPUT "",
                                           INPUT "AIMARO",
                                           INPUT "Pag. Emp/Fin Nr Deb. Conta",
                                           INPUT TRUE,
                                           INPUT 1,
                                           INPUT "LANDPV",
                                           INPUT aux_nrdconta,
                                          OUTPUT aux_nrdrowid).
                                           
                       RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                INPUT "vlpagpar", 
                                                INPUT STRING(tel_vllanmto),
                                                INPUT STRING(tel_vllanmto)).
                   END.

           END.
      ELSE
           RUN libera_cheques.
      
      IF   tel_vllanmto >= aux_vlctrmve   THEN
           DO:
               IF   tel_cdhistor = 1   THEN
                    DO:    
                        RUN fontes/cmedepi.p.
                        FIND crapcme WHERE crapcme.cdcooper = glb_cdcooper AND
                                           crapcme.dtmvtolt = tel_dtmvtolt AND
                                           crapcme.cdagenci = tel_cdagenci AND
                                           crapcme.cdbccxlt = tel_cdbccxlt AND
                                           crapcme.nrdolote = tel_nrdolote AND
                                           crapcme.nrdctabb = tel_nrdctabb AND
                                           crapcme.nrdocmto = tel_nrdocmto   
                                           NO-LOCK NO-ERROR.
                                           
                        IF   NOT AVAILABLE crapcme   THEN 
                             DO:
                                 CLEAR FRAME f_cmedep ALL NO-PAUSE.
                                 HIDE FRAME f_cmedep NO-PAUSE.
                                 ASSIGN glb_cdcritic = 767.
                                 NEXT-PROMPT tel_cdhistor WITH FRAME f_landpv.
                                 UNDO, NEXT INICIO.
                             END.    
               
                        CLEAR FRAME f_cmedep ALL NO-PAUSE.
                        HIDE FRAME f_cmedep NO-PAUSE.
                    END.
               ELSE
               IF   tel_cdhistor = 21   OR
                    tel_cdhistor = 22   OR 
                    tel_cdhistor = 1030 THEN
                    DO:
                        MESSAGE "ATENCAO !!!" SKIP(1)
                 "Efetue o Controle de Movimentacao em Especie na tela CMESAQ."
                        VIEW-AS ALERT-BOX.
                    END.
           END.
  
      /*** Magui incluido em 21/01/2002 ***/
      IF   tel_cdhistor = 451   OR    /* credito de estorno de capital  */
           tel_cdhistor = 275   OR    /* pagto emprestimo */
           tel_cdhistor = 394   OR    /* pagto emprestimo pelo aval  */
           tel_cdhistor = 428   OR    /* pagto empr. c/cap */
           tel_cdhistor = 506   OR    /* estorno 428 */
           tel_cdhistor = 127   OR    /* debito de cotas  */
           tel_cdhistor = 104   OR    /* trf cc isenta */
           tel_cdhistor = 317   OR    /* Estorno pagto emprestimo  */
           tel_cdhistor = 3501  OR    /* Lancamento para prejuizo  */
           tel_cdhistor = 302   OR    /* trf cc NAO isenta  */
           tel_cdhistor = 1806  OR    /* PAGAMENTO PARCELA FINAME  */ 
           tel_cdhistor = 931 THEN    /*credito cotas proc*/
           DO:
               IF   tel_cdhistor = 451   THEN
                    ASSIGN his_cdhistor = 402
                           his_nrdolote = 10002
                           his_tplotmov = 2.
               ELSE 
               IF   tel_cdhistor = 275   THEN
                    ASSIGN his_cdhistor = 91
                           his_nrdolote = 10001
                           his_tplotmov = 5.
               ELSE     
               IF   tel_cdhistor = 394   THEN
                    ASSIGN his_cdhistor = 393
                           his_nrdolote = 10001
                           his_tplotmov = 5.
               ELSE     
               IF   tel_cdhistor = 428   THEN
                    ASSIGN his_cdhistor = 353
                           his_nrdolote = 10001
                           his_tplotmov = 5.
               ELSE
               IF   tel_cdhistor = 506   THEN
                    ASSIGN his_cdhistor = 507
                           his_nrdolote = 10001
                           his_tplotmov = 5.
               ELSE            
               IF   tel_cdhistor = 317   THEN
                    ASSIGN his_cdhistor = 88
                           his_nrdolote = 10001
                           his_tplotmov = 5.
               ELSE
               IF   tel_cdhistor = 350   THEN
                    ASSIGN his_cdhistor = 349
                           his_nrdolote = 10001
                           his_tplotmov = 5.
               ELSE
               IF   tel_cdhistor = 127   THEN
                    ASSIGN his_cdhistor = 61
                           his_nrdolote = 10002
                           his_tplotmov = 2.
               ELSE
               IF   tel_cdhistor = 104   OR
                    tel_cdhistor = 302   THEN
                    ASSIGN his_cdhistor = 303
                           his_nrdolote = 10003
                           his_tplotmov = 1.
               ELSE
               IF   tel_cdhistor = 931   THEN
                    ASSIGN his_cdhistor = 932
                           his_nrdolote = 10002
                           his_tplotmov = 2.
               ELSE
               IF   tel_cdhistor = 1806  THEN
                    ASSIGN his_cdhistor = 1807
                           his_nrdolote = 10003
                           his_tplotmov = 1.
                   
               FIND crabhis WHERE crabhis.cdcooper = glb_cdcooper AND
                                  crabhis.cdhistor = his_cdhistor
                                  NO-LOCK NO-ERROR.
               IF   NOT AVAILABLE crabhis   THEN
                    DO:
                        glb_cdcritic = 93.
                        NEXT-PROMPT tel_cdhistor WITH FRAME f_landpv.
                        UNDO, NEXT INICIO.
                    END.

               DO aux_contador = 1 TO 10:      
                  
                  FIND crablot WHERE crablot.cdcooper = glb_cdcooper   AND
                                     crablot.dtmvtolt = tel_dtmvtolt   AND
                                     crablot.cdagenci = 1              AND
                                     crablot.cdbccxlt = 100            AND
                                     crablot.nrdolote = his_nrdolote
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.    

                  IF   NOT AVAILABLE crablot   THEN
                       IF   LOCKED crablot   THEN
                            DO:
                                glb_cdcritic = 84.
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                       ELSE
                            DO:
                                glb_cdcritic = 0.
								glb_dscritic = "".
                                LEAVE.
                            END.

                  ASSIGN glb_cdcritic = 0 /*0*/
				         glb_dscritic = "".
                  LEAVE.

               END. /* End DO...TO */
               
               IF glb_cdcritic > 0 THEN
                  UNDO, NEXT INICIO.

               IF   glb_cdcritic <> 0   THEN
                    DO:
                        FIND crablot WHERE crablot.cdcooper = glb_cdcooper   AND
                                           crablot.dtmvtolt = tel_dtmvtolt   AND
                                           crablot.cdagenci = 1              AND
                                           crablot.cdbccxlt = 100            AND
                                           crablot.nrdolote = his_nrdolote
                                           NO-LOCK NO-ERROR.

                        glb_cdcritic = 0.
						glb_dscritic = "".
                        NEXT-PROMPT tel_cdhistor WITH FRAME f_landpv.
                        UNDO, NEXT INICIO.

                    END.
                        
               IF   NOT AVAILABLE crablot   THEN
                    DO:
                        CREATE crablot.
                        ASSIGN crablot.cdcooper = glb_cdcooper
                               crablot.dtmvtolt = tel_dtmvtolt
                               crablot.cdagenci = 1
                               crablot.cdbccxlt = 100
                               crablot.nrdolote = his_nrdolote
                               crablot.tplotmov = his_tplotmov
                               crablot.cdoperad = glb_cdoperad
                               crablot.cdhistor = 0.
                        VALIDATE crablot.

                    END.
               
               IF   tel_cdhistor = 104   OR
                    tel_cdhistor = 302   OR 
                    tel_cdhistor = 1806  THEN
                    DO: 
                        FIND craplcm WHERE craplcm.cdcooper = glb_cdcooper AND
                                           craplcm.dtmvtolt = tel_dtmvtolt AND
                                           craplcm.cdagenci = 1            AND
                                           craplcm.cdbccxlt = 100          AND
                                           craplcm.nrdolote = his_nrdolote AND
                                           craplcm.nrdctabb = tel_nrctatrf AND
                                           craplcm.nrdocmto = tel_nrdocmto
                                           USE-INDEX craplcm1 NO-LOCK NO-ERROR.
                        IF   AVAILABLE craplcm   THEN
                             DO:
                                 glb_cdcritic = 92.
                                 NEXT-PROMPT tel_cdhistor WITH FRAME f_landpv.
                                 UNDO, NEXT INICIO.
                             END.

            /*INICIO renato PJ450*/

                         IF  NOT VALID-HANDLE(h-b1wgen0200) THEN
                             RUN sistema/generico/procedures/b1wgen0200.p 
                                 PERSISTENT SET h-b1wgen0200.

            /* inicio chamada rotina nova de gravaçao do lançamento*/

                         vr_cdpesqbb = STRING(tel_nrdctabb).

                         IF   AVAIL craptco AND tel_cdbaninf = 85  THEN
                              vr_nrctachq = craptco.nrctaant.
                         ELSE vr_nrctachq = tel_nrdctabb.
                         IF   AVAIL craptco AND tel_cdbaninf = 85  THEN
                              vr_nrdctabb = craptco.nrdconta.
                         ELSE vr_nrdctabb = aux_nrdctabb.
                                      
                         RUN gerar_lancamento_conta_comple IN h-b1wgen0200 
                                     (INPUT tel_dtmvtolt           /*par_dtmvtolt*/
                                     ,INPUT 1                      /*par_cdagenci*/
                                     ,INPUT 100                    /*par_cdbccxlt*/
                                     ,INPUT his_nrdolote           /*par_nrdolote*/
                                     ,INPUT tel_nrctatrf           /*par_nrdconta*/
                                     ,INPUT tel_nrdocmto           /*par_nrdocmto*/
                                     ,INPUT his_cdhistor           /*par_cdhistor*/
                                     ,INPUT crablot.nrseqdig + 1   /*par_nrseqdig*/
                                     ,INPUT tel_vllanmto           /*par_vllanmto*/
                                     ,INPUT tel_nrctatrf           /*par_nrdctabb*/
                                     ,INPUT vr_cdpesqbb            /*par_cdpesqbb*/
                                     ,INPUT 0                      /*par_vldoipmf*/
                                     ,INPUT 0                      /*par_nrautdoc*/
                                     ,INPUT 0                      /*par_nrsequni*/
                                     ,INPUT 0                      /*par_cdbanchq*/
                                     ,INPUT 0                      /*par_cdcmpchq*/
                                     ,INPUT 0                      /*par_cdagechq*/
                                     ,INPUT 0                      /*par_nrctachq*/
                                     ,INPUT 0                      /*par_nrlotchq*/
                                     ,INPUT 0                      /*par_sqlotchq*/
                                     ,INPUT ""                     /*par_dtrefere*/
                                     ,INPUT ""                     /*par_hrtransa*/
                                     ,INPUT glb_cdoperad          /*par_cdoperad*/
                                     ,INPUT ""                    /*par_dsidenti*/
                                     ,INPUT glb_cdcooper          /*par_cdcooper*/
                 ,INPUT STRING(tel_nrctatrf,"99999999")           /*par_nrdctitg*/
                                     ,INPUT ""                           /*par_dscedent*/
                                     ,INPUT 0                            /*par_cdcoptfn*/
                                     ,INPUT 0                            /*par_cdagetfn*/
                                     ,INPUT 0                            /*par_nrterfin*/
                                     ,INPUT 0                            /*par_nrparepr*/
                                     ,INPUT 0                            /*par_nrseqava*/
                                     ,INPUT 0                            /*par_nraplica*/
                                     ,INPUT 0                            /*par_cdorigem*/
                                     ,INPUT 0                            /*par_idlautom*/
                                     ,INPUT 0                            /*par_inprolot */
                                     ,INPUT 0                            /*par_tplotmov */
                                     ,OUTPUT TABLE tt-ret-lancto
                                     ,OUTPUT aux_incrineg
                                     ,OUTPUT aux_cdcritic
                                     ,OUTPUT aux_dscritic).
            /*  ver com a Josi como tratar a crítica */               
                         IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                         DO:   
                           IF aux_incrineg = 1 THEN
                             DO:
                               /* Tratativas de negocio */  
                               MESSAGE  aux_cdcritic  aux_dscritic  aux_incrineg VIEW-AS ALERT-BOX.     
                               PAUSE(3) NO-MESSAGE.
                               UNDO , NEXT INICIO.
                             END.
                           ELSE
                             DO:
                               MESSAGE  aux_cdcritic  aux_dscritic  aux_incrineg VIEW-AS ALERT-BOX.     
                               PAUSE(3) NO-MESSAGE.
                               UNDO , NEXT INICIO.
                             END.
                         END.

                         FIND FIRST tt-ret-lancto.
                         DISP tt-ret-lancto.
                         
                         FIND FIRST craplcm 
                            WHERE RECID(craplcm) = tt-ret-lancto.recid_lcm
                                  NO-ERROR.
                         IF NOT AVAILABLE craplcm THEN
                            DO:
                               MESSAGE "Erro ao ler CRAPLCM=" tt-ret-lancto.recid_lcm.
                               PAUSE(3) NO-MESSAGE.
                               UNDO , NEXT INICIO.
                            END.

                         DELETE PROCEDURE h-b1wgen0200.       

/*FIM renato PJ450*/
/*
                        CREATE craplcm.
                        ASSIGN craplcm.cdcooper = glb_cdcooper
                               craplcm.cdoperad = glb_cdoperad
                               craplcm.dtmvtolt = tel_dtmvtolt
                               craplcm.cdagenci = 1
                               craplcm.cdbccxlt = 100
                               craplcm.nrdolote = his_nrdolote
                               craplcm.nrdconta = tel_nrctatrf
                               craplcm.nrdctabb = tel_nrctatrf
                               craplcm.nrdctitg = STRING(tel_nrctatrf,
                                                             "99999999")
                               craplcm.nrdocmto = tel_nrdocmto
                               craplcm.cdhistor = his_cdhistor
                               craplcm.nrseqdig = crablot.nrseqdig + 1
                               craplcm.vllanmto = tel_vllanmto
                               craplcm.cdpesqbb = STRING(tel_nrdctabb).
                        VALIDATE craplcm.*/

                    END.
               ELSE   
               IF   tel_cdhistor = 451   OR
                    tel_cdhistor = 127   THEN
                    DO: 
                        FIND craplct WHERE craplct.cdcooper = glb_cdcooper AND
                                           craplct.dtmvtolt = tel_dtmvtolt AND
                                           craplct.cdagenci = 1            AND
                                           craplct.cdbccxlt = 100          AND
                                           craplct.nrdolote = his_nrdolote AND
                                           craplct.nrdconta = tel_nrdctabb AND
                                           craplct.nrdocmto = tel_nrdocmto   
                                           NO-LOCK NO-ERROR.
                                           
                        IF   AVAILABLE craplct   THEN
                             DO:
                                 glb_cdcritic = 92.
                                 NEXT-PROMPT tel_cdhistor WITH FRAME f_landpv.
                                 UNDO, NEXT INICIO.
                             END.

                        IF  tel_cdhistor <> 127 THEN
                            DO: 
                                
                                RUN sistema/generico/procedures/b1wgen0140.p 
                                 PERSISTENT SET h-b1wgen0140.
    
                                RUN saldo_cotas_normal
                                    IN h-b1wgen0140(INPUT  glb_cdcooper,
                                                    INPUT  tel_nrdctabb,
                                                    OUTPUT aux_slcotnor).
    
                                DELETE PROCEDURE h-b1wgen0140.

                                /*** Busca Saldo Bloqueado Judicial ***/
                                RUN sistema/generico/procedures/b1wgen0155.p 
                                     PERSISTENT SET h-b1wgen0155.

                                RUN retorna-valor-blqjud IN h-b1wgen0155
                                    (INPUT glb_cdcooper,
                                     INPUT tel_nrdctabb,
                                     INPUT 0, /* fixo - nrcpfcgc */
                                     INPUT 3, /* Bloq. Capital   */
                                     INPUT 4, /* 4 - CAPITAL     */
                                     INPUT glb_dtmvtolt,
                                     OUTPUT aux_vlblqjud,
                                     OUTPUT aux_vlresblq).

                                DELETE PROCEDURE h-b1wgen0155.

                                
                                IF craplcm.vllanmto > (aux_slcotnor -
                                                       aux_vlblqjud) THEN
                                DO:
                                   MESSAGE "Valor acima do disponivel! " + 
                                           "Maximo de " + 
                                   TRIM(STRING
                                        ((aux_slcotnor - aux_vlblqjud)
                                        ,"zzz,zzz,zzz,zz9.99")).
                                   PAUSE(3) NO-MESSAGE.
                                   NEXT-PROMPT tel_vllanmto 
                                                WITH FRAME f_landpv.
                                    UNDO, NEXT INICIO.
                                END.
                                
                            END.
                         
                        CREATE craplct.
                        ASSIGN craplct.cdcooper = glb_cdcooper
                               craplct.dtmvtolt = tel_dtmvtolt
                               craplct.cdagenci = 1
                               craplct.cdbccxlt = 100
                               craplct.nrdolote = his_nrdolote
                               craplct.nrdconta = tel_nrdctabb
                               craplct.nrdocmto = tel_nrdocmto
                               craplct.cdhistor = his_cdhistor
                               craplct.nrseqdig = crablot.nrseqdig + 1
                               craplct.vllanmto = tel_vllanmto.
                        VALIDATE craplct.

                        DO aux_contador = 1 TO 10 :
                                         
                           FIND crapcot WHERE 
                                crapcot.cdcooper = glb_cdcooper     AND
                                crapcot.nrdconta = craplcm.nrdconta 
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                        
                           IF   NOT AVAILABLE crapcot   THEN
                                IF   LOCKED crapcot   THEN
                                     DO:
                                        glb_cdcritic = 77.
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT.
                                     END.
                                 ELSE
                                 DO:
                                    ASSIGN glb_cdcritic = 55.
                                    LEAVE.
                                 END.
                           ELSE
                               ASSIGN glb_cdcritic = 0
							          glb_dscritic = "".

                           LEAVE.
                           
                        END.  /*  Fim do DO WHILE TRUE   */

                        IF   glb_cdcritic > 0   THEN
                             UNDO, NEXT INICIO.
                                               
                        IF   crabhis.inhistor = 6   THEN
                             crapcot.vldcotas = crapcot.vldcotas + tel_vllanmto.
                        ELSE
                        IF   crabhis.inhistor = 16   THEN
                        DO:
                             IF   tel_vllanmto > crapcot.vldcotas   THEN
                                  DO:
                                       glb_cdcritic = 203.
                                       NEXT-PROMPT tel_cdhistor 
                                              WITH FRAME f_landpv.
                                       UNDO, NEXT INICIO.
                                  END.

             
                             RUN 

                             sistema/generico/procedures/b1wgen0001.p
                             PERSISTENT SET h-b1wgen0001.
      
                             IF   VALID-HANDLE(h-b1wgen0001)   THEN
                                  DO:
                                       RUN ver_capital IN h-b1wgen0001
                                                      (INPUT  glb_cdcooper,
                                                       INPUT  aux_nrdconta,
                                                       INPUT  0, /*agencia*/
                                                       INPUT  0, /* caixa */
                                                       tel_vllanmto,
                                                       INPUT  glb_dtmvtolt,
                                                       INPUT  "landpvi",
                                                       INPUT  1, /* AYLLOS */
                                                       OUTPUT TABLE tt-erro).
                                       /* Verifica se houve erro */
                                       FIND FIRST tt-erro  NO-LOCK NO-ERROR.
                                 
                                       IF   AVAILABLE tt-erro   THEN
                                            DO:
                                                ASSIGN glb_cdcritic = tt-erro.cdcritic
                                                       glb_dscricpl = tt-erro.dscritic.
                                            END.
                                 
                                       DELETE PROCEDURE h-b1wgen0001.
                                 
                                       IF   glb_cdcritic > 0   THEN
                                            DO:
                                                 NEXT-PROMPT tel_cdhistor 
                                                        WITH FRAME f_landpv.
                                                 UNDO, NEXT INICIO.
                                            END.
                                  END.
                                             
                             crapcot.vldcotas = crapcot.vldcotas - tel_vllanmto.
                        END.
							
                    END. /*FIM DO */
               ELSE
                   IF  tel_cdhistor = 931 THEN 
                       DO:
                          
                          FIND craplct WHERE craplct.cdcooper = glb_cdcooper AND
                                             craplct.dtmvtolt = tel_dtmvtolt AND
                                             craplct.cdagenci = 1            AND
                                             craplct.cdbccxlt = 100          AND
                                             craplct.nrdolote = his_nrdolote AND
                                             craplct.nrdconta = tel_nrdctabb AND
                                             craplct.nrdocmto = tel_nrdocmto   
                                             NO-LOCK NO-ERROR.
                                             
                          IF   AVAILABLE craplct   THEN
                               DO:
                                   glb_cdcritic = 92.
                                   NEXT-PROMPT tel_cdhistor WITH FRAME f_landpv.
                                   UNDO, NEXT INICIO.
                               END.

                          RUN sistema/generico/procedures/b1wgen0140.p 
                           PERSISTENT SET h-b1wgen0140.

                          RUN saldo_procap_desbloqueado
                              IN h-b1wgen0140(INPUT  glb_cdcooper,
                                              INPUT  tel_nrdctabb,
                                              OUTPUT aux_sldesblo).

                          DELETE PROCEDURE h-b1wgen0140.

                          IF  tel_vllanmto > aux_sldesblo THEN
                              DO:
                                ASSIGN glb_cdcritic = 952.
                                RUN fontes/critic.p.
                                BELL.
                                
                                MESSAGE glb_dscritic.
                                glb_cdcritic = 0.
								glb_dscritic = "".
                                PAUSE(3) NO-MESSAGE. 
                                NEXT-PROMPT tel_vllanmto 
                                       WITH FRAME f_landpv.
                                UNDO, NEXT INICIO.
                              END.

                          /*** Busca Saldo Bloqueado Judicial ***/
                          RUN sistema/generico/procedures/b1wgen0155.p 
                                     PERSISTENT SET h-b1wgen0155.

                          RUN retorna-valor-blqjud IN h-b1wgen0155
                                    (INPUT glb_cdcooper,
                                     INPUT tel_nrdctabb,
                                     INPUT 0, /* fixo - nrcpfcgc */
                                     INPUT 3, /* Bloq. Capital   */
                                     INPUT 4, /* 4 - CAPITAL     */
                                     INPUT glb_dtmvtolt,
                                     OUTPUT aux_vlblqjud,
                                     OUTPUT aux_vlresblq).

                          DELETE PROCEDURE h-b1wgen0155.

                          DO aux_contador = 1 TO 10 :                    

                             FIND crapcot WHERE                          
                                  crapcot.cdcooper = glb_cdcooper     AND
                                  crapcot.nrdconta = craplcm.nrdconta    
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.       

                             IF   NOT AVAILABLE crapcot   THEN           
                                  IF   LOCKED crapcot   THEN             
                                       DO:                               
                                           glb_cdcritic = 77.
                                           PAUSE 1 NO-MESSAGE.
                                           NEXT.
                                       END.                              
                                   ELSE                                  
                                   DO:                                   
                                      ASSIGN glb_cdcritic = 55.          
                                      LEAVE.                             
                                   END.                                  
                             ELSE                                        
                                 ASSIGN glb_cdcritic = 0
								        glb_dscritic = "".

                             LEAVE.                                      

                          END.  /*  Fim do DO WHILE TRUE   */ 

                          IF   glb_cdcritic > 0   THEN
                               UNDO, NEXT INICIO.

                          IF   (tel_vllanmto > crapcot.vldcotas - 
                                               aux_vlblqjud) THEN
                               DO:
                                   ASSIGN glb_cdcritic = 203.
                                   UNDO, NEXT INICIO.
                               END.
                          
                          
                          CREATE craplct.
                          ASSIGN craplct.cdcooper = glb_cdcooper
                                 craplct.dtmvtolt = tel_dtmvtolt
                                 craplct.cdagenci = 1
                                 craplct.cdbccxlt = 100
                                 craplct.nrdolote = his_nrdolote
                                 craplct.nrdconta = tel_nrdctabb
                                 craplct.nrdocmto = tel_nrdocmto
                                 craplct.cdhistor = his_cdhistor
                                 craplct.nrseqdig = crablot.nrseqdig + 1
                                 craplct.vllanmto = tel_vllanmto.
                          VALIDATE craplct.

                          ASSIGN crapcot.vldcotas = crapcot.vldcotas -
                                                    tel_vllanmto.
                         
                       END.
               ELSE              /*  Hst 275, 394, 428, 350 e 317 e 506  */                                                
                    DO:  
                        FIND craplem WHERE craplem.cdcooper = glb_cdcooper AND
                                           craplem.dtmvtolt = tel_dtmvtolt AND
                                           craplem.cdagenci = 1            AND
                                           craplem.cdbccxlt = 100          AND
                                           craplem.nrdolote = his_nrdolote AND
                                           craplem.nrdconta = tel_nrdctabb AND
                                           craplem.nrdocmto = tel_nrdocmto
                                           NO-LOCK NO-ERROR.
                             
                        IF   AVAILABLE craplem   THEN
                             DO:
                                 glb_cdcritic = 92.
                                 NEXT-PROMPT tel_cdhistor WITH FRAME f_landpv.
                                 UNDO, NEXT INICIO.
                             END.

                        /* Verificacao de contrato de acordo */  
                        
                          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                          /* Verifica se ha contratos de acordo */
                          RUN STORED-PROCEDURE pc_verifica_acordo_ativo
                            aux_handproc = PROC-HANDLE NO-ERROR (INPUT glb_cdcooper
                                                                ,INPUT tel_nrdctabb
                                                                ,INPUT his_nrctremp
																,INPUT 3
                                                                ,OUTPUT 0
                                                                ,OUTPUT 0
                                                                ,OUTPUT "").

                          CLOSE STORED-PROC pc_verifica_acordo_ativo
                                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                          ASSIGN glb_cdcritic = 0
                                 glb_dscritic = ""
                                 glb_cdcritic = INT(pc_verifica_acordo_ativo.pr_cdcritic) WHEN pc_verifica_acordo_ativo.pr_cdcritic <> ?
                                 glb_dscritic = pc_verifica_acordo_ativo.pr_dscritic WHEN pc_verifica_acordo_ativo.pr_dscritic <> ?
                                 aux_flgativo = INT(pc_verifica_acordo_ativo.pr_flgativo).
                          
                          IF glb_cdcritic > 0 THEN
                            DO:
                                RUN fontes/critic.p.
                                BELL.
                                MESSAGE glb_dscritic.
                                UNDO, NEXT INICIO.
                            END.
                          ELSE IF glb_dscritic <> ? AND glb_dscritic <> "" THEN
                            DO:
                              MESSAGE glb_dscritic.
                              ASSIGN glb_cdcritic = 0.
                              UNDO, NEXT INICIO.
                            END.
                            
                          IF aux_flgativo = 1 THEN
                            DO:
                              MESSAGE "Lancamento nao permitido, emprestimo em acordo.".
                              PAUSE 3 NO-MESSAGE.
                              UNDO, NEXT INICIO.
                            END.
                        /* Fim verificacao contrato acordo */
                        
                        IF  NOT VALID-HANDLE(h-b1wgen0002)  THEN
                            RUN sistema/generico/procedures/b1wgen0002.p
                            PERSISTENT SET h-b1wgen0002.

                        RUN obtem-dados-emprestimos IN h-b1wgen0002
                                ( INPUT glb_cdcooper, /** Cooperativa   **/
                                  INPUT tel_cdagenci, /** Agencia       **/
                                  INPUT tel_cdbccxlt, /** Caixa         **/
                                  INPUT glb_cdoperad, /** Operador      **/
                                  INPUT "landpv.p",   /** Nome da tela  **/
                                  INPUT 1,            /** Origem=Ayllos **/
                                  INPUT tel_nrdctabb, /** Num. da conta **/
                                  INPUT 1,            /** Sq.do titular **/
                                  INPUT glb_dtmvtolt, /** Data de Movto **/
                                  INPUT glb_dtmvtopr, /** Data de Movto **/
                                  INPUT ?,            /** Data de Calc. **/
                                  INPUT his_nrctremp, /** Nr.do Contrato**/
                                  INPUT "landpvi.p",  /** Tela atual    **/
                                  INPUT glb_inproces, /** Indic.Process.**/
                                  INPUT FALSE,        /** Gera log erro **/
                                  INPUT TRUE,         /** Flag Condic.C.**/
                                  INPUT 0, 			      /** nriniseq      **/
                                  INPUT 0, 		        /** nrregist      **/
                                 OUTPUT aux_qtregist,
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-dados-epr ).

                        IF  VALID-HANDLE(h-b1wgen0002) THEN
                            DELETE OBJECT h-b1wgen0002.

                        IF  RETURN-VALUE <> "OK"  THEN
                            DO:
                              FIND FIRST tt-erro NO-LOCK NO-ERROR.

                              IF  AVAILABLE tt-erro  THEN
                                  ASSIGN glb_dscritic = tt-erro.dscritic.
                              ELSE
                                  ASSIGN glb_dscritic = "Erro no carregamento"
                                                        + " de emprestimos.".

                              MESSAGE glb_dscritic.

                              NEXT-PROMPT tel_cdhistor 
                                          WITH FRAME f_landpv.
                              UNDO, NEXT INICIO.
                            END.

                        FIND FIRST tt-dados-epr NO-LOCK NO-ERROR.

                        IF   NOT AVAILABLE tt-dados-epr   THEN
                             DO:
                                 ASSIGN glb_dscritic = "Erro no carregamento"
                                                       + " de emprestimos.".

                                 NEXT-PROMPT tel_cdhistor 
                                             WITH FRAME f_landpv.
                                 UNDO, NEXT INICIO.
                             END.        
        
                        /* Se for debito e pagamento seja menor que data atual */
                        IF aux_indebcre = "D"                   AND
                           tt-dados-epr.dtdpagto < tel_dtmvtolt THEN
                           DO:
                               { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                               /* Efetuar a chamada a rotina Oracle */ 
                               RUN STORED-PROCEDURE pc_efetiva_pag_atraso_tr
                                 aux_handproc = PROC-HANDLE NO-ERROR (INPUT glb_cdcooper,          /* Cooperativa conectada */
                                                                      INPUT tel_cdagenci,          /* Codigo da agencia */
                                                                      INPUT tel_cdbccxlt,          /* Numero do caixa */
                                                                      INPUT glb_cdoperad,          /* Codigo do operador */
                                                                      INPUT "landpv.p",            /* Nome da tela */
                                                                      INPUT 1,                     /* Origem=Ayllos */
                                                                      INPUT tel_nrdctabb,          /* Conta do associado */
                                                                      INPUT his_nrctremp,          /* Numero Contrato */
                                                                      INPUT tt-dados-epr.vlpreapg, /* Valor a pagar */
                                                                      INPUT tt-dados-epr.qtmesdec, /* Quantidade de meses decorridos */
                                                                      INPUT tt-dados-epr.qtprecal, /* Quantidade de prestacoes calculadas */
                                                                      INPUT tel_vllanmto,          /* Valor de pagamento da parcela */
                                                                      INPUT ?,                     /* Valor Saldo Disponivel */
                                                                     OUTPUT 0,                     /* Historico da Multa */
                                                                     OUTPUT 0,                     /* Valor da Multa */
                                                                     OUTPUT 0,                     /* Historico Juros de Mora */
                                                                     OUTPUT 0,                     /* Valor Juros de Mora */
                                                                     OUTPUT 0,                     /* Codigo da critica  */
                                                                     OUTPUT "").                   /* Descricao da critica */
                                                               
                               /* Fechar o procedimento para buscarmos o resultado */ 
                               CLOSE STORED-PROC pc_efetiva_pag_atraso_tr
                                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                               { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                               ASSIGN aux_cdcritic = 0
                                      aux_dscritic = ""
                                      aux_cdcritic = pc_efetiva_pag_atraso_tr.pr_cdcritic
                                                        WHEN pc_efetiva_pag_atraso_tr.pr_cdcritic <> ?
                                      aux_dscritic = pc_efetiva_pag_atraso_tr.pr_dscritic
                                                        WHEN pc_efetiva_pag_atraso_tr.pr_dscritic <> ?.

                               IF   aux_cdcritic <> 0   OR
                                    aux_dscritic <> ""  THEN
                                    DO:
                                        ASSIGN glb_dscritic = aux_dscritic.

                                        NEXT-PROMPT tel_cdhistor 
                                                    WITH FRAME f_landpv.
                                        UNDO, NEXT INICIO.
                                    END.
                           END.
                          
                        ASSIGN his_vlsdeved = tt-dados-epr.vlsdeved.

                        IF  (tel_cdhistor = 275 OR tel_cdhistor = 394) AND
                             tel_vllanmto > his_vlsdeved   THEN
                             DO:
                                 ASSIGN glb_cdcritic = 91.
                                 NEXT-PROMPT tel_vllanmto
                                             WITH FRAME f_landpv.
                                 UNDO, NEXT INICIO.
                             END.
                                      
                        DO  aux_contador = 1 TO 10:

                            FIND crapepr WHERE 
                                 crapepr.cdcooper = glb_cdcooper AND
                                 crapepr.nrdconta = tel_nrdctabb AND
                                 crapepr.nrctremp = his_nrctremp   
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                            IF NOT AVAIL crapepr THEN
                               IF LOCKED crapepr THEN
                                  DO:
                                      glb_cdcritic = 371.
                                      PAUSE 1 NO-MESSAGE.
                                      NEXT.
                                  END.
                               ELSE
                                  DO: 
                                      glb_cdcritic = 356.
                                      NEXT-PROMPT tel_cdhistor
                                                  WITH FRAME f_landpv.
                                      UNDO, NEXT INICIO.
                                  END.

                            glb_cdcritic = 0.
							glb_dscritic = "".
                            LEAVE.

                        END. /* END DO  aux_contador = 1 TO 10: */

                        IF glb_cdcritic > 0 THEN
                           UNDO, NEXT INICIO.
                        
                        IF  crapepr.dtmvtolt = glb_dtmvtolt THEN
                            DO:
                               glb_cdcritic = 934.
                               NEXT-PROMPT tel_cdhistor 
                                             WITH FRAME f_landpv.
                                 UNDO, NEXT INICIO.
                            END.
                        
                        IF   crapepr.flgpagto   THEN
                             DO:
                                 RUN p_atualiza_avs.
                                 IF   RETURN-VALUE = "NOK"   THEN
                                      DO:
                                          NEXT-PROMPT tel_cdhistor 
                                                      WITH FRAME f_landpv.
                                          UNDO, NEXT INICIO.
                                      END.
                             END.
                        ELSE
                             IF   crapepr.qtmesdec > 0   THEN
                                  RUN p_atualiza_dtdpagto(INPUT TRUE,
                                                          INPUT tel_vllanmto).

                        CREATE craplem.
                        ASSIGN craplem.cdcooper = glb_cdcooper
                               craplem.dtmvtolt = tel_dtmvtolt
                               craplem.cdagenci = 1
                               craplem.cdbccxlt = 100
                               craplem.nrdolote = his_nrdolote
                               craplem.nrdconta = tel_nrdctabb
                               craplem.nrdocmto = tel_nrdocmto
                               craplem.cdhistor = his_cdhistor
                               craplem.nrctremp = his_nrctremp
                               craplem.nrseqdig = crablot.nrseqdig + 1
                               craplem.vllanmto = tel_vllanmto.
                        VALIDATE craplem.
                        
                        IF tel_cdhistor = 275 THEN 
                           DO:
                               RUN proc_gerar_log (INPUT glb_cdcooper, 
                                                   INPUT glb_cdoperad,
                                                   INPUT "",
                                                   INPUT "AIMARO",
                                                   INPUT "Pag. Emp/Fin Nr " + STRING(tel_nrctremp) + " Cred. Contrato",
                                                   INPUT TRUE,
                                                   INPUT 1,
                                                   INPUT "LANDPV",
                                                   INPUT aux_nrdconta,
                                                  OUTPUT aux_nrdrowid).
                                                   
                               RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                        INPUT "vlpagpar", 
                                                        INPUT STRING(tel_vllanmto),
                                                        INPUT STRING(tel_vllanmto)).
                           END.
                        
                        IF tel_cdhistor = 108 THEN 
                           DO:
                               RUN proc_gerar_log (INPUT glb_cdcooper, 
                                                   INPUT glb_cdoperad,
                                                   INPUT "",
                                                   INPUT "AIMARO",
                                                   INPUT "Pag. Emp/Fin Cred. Contrato",
                                                   INPUT TRUE,
                                                   INPUT 1,
                                                   INPUT "LANDPV",
                                                   INPUT aux_nrdconta,
                                                  OUTPUT aux_nrdrowid).
                                                   
                               RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                        INPUT "vlpagpar", 
                                                        INPUT STRING(tel_vllanmto),
                                                        INPUT STRING(tel_vllanmto)).
                           END.

                        IF   his_cdhistor = 88   OR
                             his_cdhistor = 507  THEN
                             ASSIGN crapepr.inliquid = 
                                    IF (his_vlsdeved + tel_vllanmto) > 0
                                        THEN 0
                                        ELSE 1.
                        ELSE
                             ASSIGN crapepr.inliquid = 
                                      IF (his_vlsdeved - tel_vllanmto) > 0
                                          THEN 0
                                          ELSE 1
                                    crapepr.dtultpag = tel_dtmvtolt.
                         
                        ASSIGN craplem.vlpreemp = crapepr.vlpreemp.

                        RUN sistema/generico/procedures/b1wgen0043.p
                                             PERSISTENT SET h-b1wgen0043.

                        /* Verifica se tem que ativar/desativar o Rating */
                        RUN verifica_contrato_rating IN h-b1wgen0043
                                                (INPUT glb_cdcooper,
                                                 INPUT 0,
                                                 INPUT 0,
                                                 INPUT glb_cdoperad,
                                                 INPUT glb_dtmvtolt,
                                                 INPUT glb_dtmvtopr,
                                                 INPUT crapepr.nrdconta,
                                                 INPUT 90, /* Emprestimo*/
                                                 INPUT crapepr.nrctremp,
                                                 INPUT 1,
                                                 INPUT 1,
                                                 INPUT glb_nmdatela,
                                                 INPUT glb_inproces,
                                                 INPUT FALSE,
                                                 OUTPUT TABLE tt-erro).

                        DELETE PROCEDURE h-b1wgen0043.

                        IF   RETURN-VALUE <> "OK"   THEN
                             DO:  
                                 FIND FIRST tt-erro NO-LOCK NO-ERROR.

                                 IF   AVAIL tt-erro   THEN
                                      MESSAGE tt-erro.dscritic.
                                 
                                 HIDE FRAME f_nrctremp.

                                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                     PAUSE 2 NO-MESSAGE.
                                     LEAVE.
                                 END.

                                 UNDO , NEXT INICIO.                                     
                        END.

                        /** GRAVAMES **/
                        IF  crapepr.inliquid = 1 /* Marcado para Liquidar e Sem prejuizo */
                        AND crapepr.inprejuz = 0 THEN DO:
                            RUN sistema/generico/procedures/b1wgen0171.p
                                PERSISTENT SET h-b1wgen0171.

                            RUN solicita_baixa_automatica  IN h-b1wgen0171
                                         (INPUT glb_cdcooper,
                                          INPUT crapepr.nrdconta,
                                          INPUT crapepr.nrctremp,
                                          INPUT glb_dtmvtolt,
                                          OUTPUT TABLE tt-erro).
            
                            DELETE PROCEDURE h-b1wgen0171.
                        END.
                             






                    END.
                      
               ASSIGN crablot.nrseqdig = crablot.nrseqdig + 1
                      crablot.qtcompln = crablot.qtcompln + 1
                      crablot.qtinfoln = crablot.qtinfoln + 1.
               
               IF   crabhis.indebcre = "D"   THEN
                    ASSIGN crablot.vlcompdb = crablot.vlcompdb + tel_vllanmto
                           crablot.vlinfodb = crablot.vlinfodb + tel_vllanmto.
               ELSE
               IF   crabhis.indebcre = "C"   THEN
                    ASSIGN crablot.vlcompcr = crablot.vlcompcr + tel_vllanmto
                           crablot.vlinfocr = crablot.vlinfocr + tel_vllanmto.
           END.
      /************************************/
      
      IF   (tel_cdhistor = 2      OR
            tel_cdhistor = 6      OR
            tel_cdhistor = 403    OR
            tel_cdhistor = 404)   AND
           CAN-DO("3,4,5",STRING(aux_inhistor))   THEN
           DO:
               CREATE crapdpb.
               ASSIGN crapdpb.cdcooper = glb_cdcooper
                      crapdpb.nrdconta = aux_nrdconta
                      crapdpb.dtliblan = tel_dtliblan
                      crapdpb.cdhistor = tel_cdhistor
                      crapdpb.nrdocmto = tel_nrdocmto
                      crapdpb.dtmvtolt = tel_dtmvtolt
                      crapdpb.cdagenci = tel_cdagenci
                      crapdpb.cdbccxlt = tel_cdbccxlt
                      crapdpb.nrdolote = tel_nrdolote
                      crapdpb.vllanmto = tel_vllanmto
                      crapdpb.inlibera = 1.
               VALIDATE crapdpb.

           END.
      ELSE
      IF   CAN-DO("13,14,15",STRING(aux_inhistor))   THEN
           DO:   
               IF   crapdpb.vllanmto = tel_vllanmto   THEN
                    crapdpb.inlibera = 2.
               ELSE
                    crapdpb.vllanmto = crapdpb.vllanmto - tel_vllanmto.
           END.
         
      IF   tel_cdhistor = 21   OR
           tel_cdhistor = 521  OR
           tel_cdhistor = 621  OR
           tel_cdhistor = 1873 OR
           tel_cdhistor = 1874 THEN 
           DO:
                IF  aux_flctatco = YES THEN
                    DO:
                        IF  crapfdc.cdcooper = craptco.cdcopant THEN /* ATUALIZA SE COOP 2 */
                            ASSIGN crapfdc.incheque = crapfdc.incheque + 5
                                   crapfdc.vlcheque = tel_vllanmto
                                   crapfdc.dtliqchq = glb_dtmvtolt.
                    END.
                ELSE /* CONTA TCO = NAO */
                     ASSIGN crapfdc.incheque = crapfdc.incheque + 5
                            crapfdc.vlcheque = tel_vllanmto
                            crapfdc.dtliqchq = glb_dtmvtolt.
                
           END.
      ELSE
      IF   tel_cdhistor = 59   AND
           CAN-DO(aux_lsconta2,STRING(tel_nrdctabb))   THEN
           ASSIGN crapfdc.incheque = crapfdc.incheque + 5
                  crapfdc.vlcheque = tel_vllanmto
                  crapfdc.dtliqchq = glb_dtmvtolt.
      ELSE
      IF  (tel_cdhistor = 26   OR
           tel_cdhistor = 526) AND
           CAN-DO(aux_lsconta3,STRING(tel_nrdctabb))   THEN
           ASSIGN crapfdc.incheque = (IF crapfdc.incheque = 0 
                                         THEN  5
                                         ELSE (IF crapfdc.incheque = 2 
                                                  THEN  7
                                                  ELSE 0))
                  crapfdc.dtliqchq = glb_dtmvtolt.

      /***** tratamento da Compensacao Eletronica *****/
      ASSIGN aux_nrseqlcm = tel_nrseqdig.     
      
      FIND FIRST w-compel NO-LOCK NO-ERROR.
      IF   AVAILABLE w-compel   THEN
           FIND crabhis WHERE crabhis.cdcooper = glb_cdcooper AND
                              crabhis.cdhistor = 21 NO-LOCK NO-ERROR.

      FOR EACH w-compel NO-LOCK:
        
          FIND crapchd WHERE crapchd.cdcooper = glb_cdcooper        AND
                             crapchd.dtmvtolt = tel_dtmvtolt        AND
                             crapchd.cdcmpchq = w-compel.cdcmpchq   AND
                             crapchd.cdbanchq = w-compel.cdbanchq   AND
                             crapchd.cdagechq = w-compel.cdagechq   AND
                             crapchd.nrctachq = w-compel.nrctachq   AND
                             crapchd.nrcheque = w-compel.nrcheque  
                             USE-INDEX crapchd1 NO-LOCK NO-ERROR.

          IF   AVAILABLE crapchd   THEN                   
               DO:
                   ASSIGN glb_cdcritic = 92.
                   NEXT-PROMPT tel_nrdocmto WITH FRAME f_landpv.
                   LEAVE.        
                 END.

          CREATE crapchd.
          ASSIGN crapchd.cdcooper = glb_cdcooper
                 crapchd.cdagechq = w-compel.cdagechq
                 crapchd.cdagenci = tel_cdagenci
                 crapchd.cdbanchq = w-compel.cdbanchq
                 crapchd.cdbccxlt = tel_cdbccxlt
                 crapchd.nrdocmto = IF  w-compel.nrdoclcm = 0 THEN aux_nrdocmto
                                    ELSE w-compel.nrdoclcm
                 crapchd.cdcmpchq = w-compel.cdcmpchq
                 crapchd.cdoperad = glb_cdoperad
                 crapchd.cdsitatu = 1
                 crapchd.dsdocmc7 = w-compel.dsdocmc7
                 crapchd.dtmvtolt = tel_dtmvtolt
                 crapchd.inchqcop = IF w-compel.nrctaaux > 0 THEN 1 ELSE 0
                 crapchd.insitchq = 0
                 crapchd.cdtipchq = w-compel.cdtipchq
                 crapchd.nrcheque = w-compel.nrcheque
                 crapchd.nrctachq = IF crapchd.inchqcop = 1
                                       THEN w-compel.nrctabdb
                                       ELSE w-compel.nrctachq
                 crapchd.nrdconta = aux_nrdconta
                   
                 crapchd.nrddigc1 = w-compel.nrddigc1
                 crapchd.nrddigc2 = w-compel.nrddigc2
                 crapchd.nrddigc3 = w-compel.nrddigc3
                   
                 crapchd.nrddigv1 = INT(ENTRY(1,w-compel.lsdigctr))
                 crapchd.nrddigv2 = INT(ENTRY(2,w-compel.lsdigctr))
                 crapchd.nrddigv3 = INT(ENTRY(3,w-compel.lsdigctr))
                  
                 crapchd.nrdolote = tel_nrdolote
                 crapchd.nrseqdig = w-compel.nrseqlcm                         
                 crapchd.nrterfin = 0
                 crapchd.tpdmovto = w-compel.tpdmovto
                 crapchd.vlcheque = w-compel.vlcompel.
          VALIDATE crapchd.

          IF   tel_cdhistor <> 386    THEN
               NEXT.
               
          /*** Magui criando lancamentos correspondentes ao historico 21 ***/
          CREATE crablcm.
          ASSIGN crablcm.cdcooper = glb_cdcooper
                 crablcm.cdoperad = glb_cdoperad
                 aux_nrseqlcm     = aux_nrseqlcm + 1
                 crablcm.dtmvtolt = tel_dtmvtolt 
                 crablcm.cdagenci = tel_cdagenci
                 crablcm.cdbccxlt = tel_cdbccxlt 
                 crablcm.nrdolote = tel_nrdolote
                 crablcm.nrdconta = w-compel.nrctaaux  
                 crablcm.nrdocmto = INT(STRING(w-compel.nrcheque,"999999") +
                                        STRING(w-compel.nrddigc3,"9"))
                 crablcm.vllanmto = w-compel.vlcompel  
                 crablcm.nrseqdig = aux_nrseqlcm
                 crablcm.nrdctabb = w-compel.nrctabdb
                 crablcm.cdpesqbb = ""
                 craplot.nrseqdig = craplot.nrseqdig + 1
                 craplot.qtcompln = craplot.qtcompln + 1
                 craplot.qtinfoln = craplot.qtinfoln + 1
                 craplot.vlcompdb = craplot.vlcompdb + w-compel.vlcompel
                 craplot.vlinfodb = craplot.vlinfodb + w-compel.vlcompel.
          VALIDATE crablcm.


          /*  Formata conta integracao  */
            
          RUN fontes/digbbx.p (INPUT  w-compel.nrctabdb,
                               OUTPUT glb_dsdctitg,
                               OUTPUT glb_stsnrcal).
                                                        
          FIND crabfdc WHERE crabfdc.cdcooper = glb_cdcooper      AND
                             crabfdc.cdbanchq = w-compel.cdbanchq AND
                             crabfdc.cdagechq = w-compel.cdagechq AND
                             crabfdc.nrctachq = w-compel.nrctabdb AND
                             crabfdc.nrcheque = w-compel.nrcheque
                             USE-INDEX crapfdc1 EXCLUSIVE-LOCK NO-ERROR.
                                                   
          IF   NOT AVAILABLE crabfdc  THEN
               DO: 
                   glb_cdcritic = 108.
                   NEXT-PROMPT tel_nrdocmto WITH FRAME f_landpv.
                   LEAVE.
               END.

          ASSIGN crabfdc.incheque = crabfdc.incheque + 5
                 crabfdc.dtliqchq = glb_dtmvtolt
                 crabfdc.vlcheque = w-compel.vlcompel
                 crabfdc.nrctadep = tel_nrdctabb.
            
          FIND crabass5 WHERE crabass5.cdcooper = glb_cdcooper    AND
                              crabass5.nrdconta = tel_nrdctabb
                              NO-LOCK NO-ERROR.
          
          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

          RUN STORED-PROCEDURE pc_busca_tipo_conta_itg
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT crabass5.inpessoa, /* Tipo de pessoa */
                                               INPUT crabass5.cdtipcta, /* Tipo de conta */
                                              OUTPUT 0,                /* Modalidade */
                                              OUTPUT "",               /* Flag Erro */
                                              OUTPUT "").              /* Descrição da crítica */

          CLOSE STORED-PROC pc_busca_tipo_conta_itg
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

          ASSIGN aux_idctaitg = 0
                 aux_des_erro = ""
                 aux_dscritic = ""
                 aux_idctaitg = pc_busca_tipo_conta_itg.pr_indconta_itg 
                                WHEN pc_busca_tipo_conta_itg.pr_indconta_itg <> ?
                 aux_des_erro = pc_busca_tipo_conta_itg.pr_des_erro 
                                WHEN pc_busca_tipo_conta_itg.pr_des_erro <> ?
                 aux_dscritic = pc_busca_tipo_conta_itg.pr_dscritic
                                WHEN pc_busca_tipo_conta_itg.pr_dscritic <> ?.

          IF aux_des_erro = "NOK"  THEN
               DO:
                 BELL.
                 ASSIGN glb_dscritic = aux_dscritic.
                 MESSAGE glb_dscritic.
                 LEAVE.
              END.
          
          IF aux_idctaitg = 0 THEN
               DO:
                       ASSIGN crabfdc.cdbandep = crapcop.cdbcoctl
                              crabfdc.cdagedep = crapcop.cdagectl.
               END.
          ELSE
               /* BANCO DO BRASIL - SEM DIGITO */
               ASSIGN crabfdc.cdbandep = 1
                      crabfdc.cdagedep = INT(SUBSTRING(
                                             STRING(crapcop.cdagedbb),1,
                                             LENGTH(STRING(crapcop.cdagedbb))
                                             - 1)).

          IF   crabfdc.tpcheque = 1   THEN
               ASSIGN crablcm.cdhistor = 21
                      crablcm.cdbanchq = crabfdc.cdbanchq
                      crablcm.cdagechq = crabfdc.cdagechq
                      crablcm.nrctachq = crabfdc.nrctachq.
          ELSE
               IF   crabfdc.tpcheque = 3   THEN
                    ASSIGN crablcm.cdhistor = 26.
               ELSE     
                    DO: 
                        glb_cdcritic = 999.
                        NEXT-PROMPT tel_nrdocmto WITH FRAME f_landpv.
                        LEAVE.
                    END. 
      END.

      CLEAR FRAME f_cmedep ALL NO-PAUSE.
      HIDE FRAME f_cmedep NO-PAUSE.
      
      EMPTY TEMP-TABLE w-compel.

       ASSIGN aux_vlrdifer = 0
              aux_vlttcomp = 0
              aux_nrsqcomp = 0
              aux_maischeq = 0
              aux_mensagem = "".
                   
      IF   glb_cdcritic > 0  THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               CLEAR FRAME f_landpv.
               ASSIGN glb_cddopcao = aux_cddopcao
                      tel_dtmvtolt = aux_dtmvtolt
                      tel_cdagenci = aux_cdagenci
                      tel_cdbccxlt = aux_cdbccxlt
                      tel_nrdolote = aux_nrdolote
                      tel_cdhistor = aux_cdhistor
                      tel_nrdctabb = aux_nrdctabb
                      tel_nrdocmto = aux_nrdocmto
                      tel_vllanmto = aux_vllanmto
                      tel_dtliblan = aux_dtliblan
                      tel_cdalinea = aux_cdalinea.

               DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                       tel_cdbccxlt tel_nrdolote tel_cdhistor
                       tel_nrdctabb tel_cdbaninf tel_cdageinf
                       tel_nrdocmto tel_vllanmto tel_dtliblan
                       tel_cdalinea WITH FRAME f_landpv.
               MESSAGE glb_dscritic.
               PAUSE 2 NO-MESSAGE.
               UNDO, NEXT INICIO.
           END. 
      /************************************************/
      ASSIGN tel_qtinfoln = craplot.qtinfoln   tel_qtcompln = craplot.qtcompln
             tel_vlinfodb = craplot.vlinfodb   tel_vlcompdb = craplot.vlcompdb
             tel_vlinfocr = craplot.vlinfocr   tel_vlcompcr = craplot.vlcompcr
             tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
             tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.
   
   END.   /* Fim da transacao */

   RUN gera_log_inclusao.

   RELEASE craplcm.
   RELEASE crapdpb.
   RELEASE crapfdc.
   RELEASE craplot.
   RELEASE crablot.
   
   IF   tel_qtdifeln = 0  AND  tel_vldifedb = 0  AND  tel_vldifecr = 0   THEN
        DO:
            RUN fontes/landpvr.p.          /* Mostra resumo de cheques */
           
            glb_nmdatela = "LOTE".
            RETURN.                        /* Volta ao landpv.p */
        END.
   ASSIGN tel_reganter[6] = tel_reganter[5]  tel_reganter[5] = tel_reganter[4]
          tel_reganter[4] = tel_reganter[3]  tel_reganter[3] = tel_reganter[2]
          tel_reganter[2] = tel_reganter[1]

          tel_reganter[1] = STRING(tel_cdhistor,"zzz9")               + " "  +
                            STRING(tel_nrdctabb,"zzzz,zzz,9")         + " "  +
                            STRING(tel_cdbaninf,"zz9")                + " "  +
                            STRING(tel_cdageinf,"zzz9")               + " "  +
                            STRING(tel_nrdocmto,"zzzzzzzzzzzzzzzzzzzzz9") + " "  +
                            STRING(tel_vllanmto,"zzz,zzz,zz9.99")     + " "  +

                            (IF tel_dtliblan = ? THEN "          "
                            ELSE STRING(tel_dtliblan,"99/99/9999")) + " " +

                            STRING(tel_cdalinea,"zz").

   ASSIGN tel_cdhistor = 0  tel_nrdctabb = 0  tel_nrdocmto = 0
          tel_vllanmto = 0  tel_dtliblan = ?  tel_cdalinea = 0
          tel_cdbaninf = 0  tel_cdageinf = 0
          tel_nrseqdig = tel_nrseqdig + 1.

   DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
           tel_qtcompln tel_vlcompdb tel_vlcompcr
           tel_qtdifeln tel_vldifedb tel_vldifecr
           tel_cdhistor tel_nrdctabb tel_nrdocmto
           tel_vllanmto tel_dtliblan tel_cdalinea
           tel_cdbaninf tel_cdageinf
           WITH FRAME f_landpv.

   HIDE FRAME f_lanctos.

   DISPLAY tel_reganter[1] tel_reganter[2] tel_reganter[3]
           tel_reganter[4] tel_reganter[5] tel_reganter[6]
           WITH FRAME f_regant.

END.  /*  Fim do DO WHILE TRUE  */

{ includes/proc_landpv.i }

{ includes/proc_conta_integracao.i }

/* .......................................................................... */

PROCEDURE gera_lancamentos_craplci_credito:
     
   /*  Gera lancamentos Conta Investimento  - Credito  */
   DO aux_contador = 1 TO 10:
                                                                    
       FIND crablot WHERE crablot.cdcooper = glb_cdcooper  AND
                          crablot.dtmvtolt = tel_dtmvtolt  AND
                          crablot.cdagenci = tel_cdagenci  AND
                          crablot.cdbccxlt = 100           AND
                          crablot.nrdolote = 10006         EXCLUSIVE-LOCK
                          NO-ERROR NO-WAIT.

       IF   NOT AVAIL  crablot   THEN
            IF  LOCKED crablot   THEN
                DO:
                    glb_cdcritic = 77.
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
            ELSE
                DO:
                   CREATE crablot.
                   ASSIGN crablot.cdcooper = glb_cdcooper
                          crablot.dtmvtolt = tel_dtmvtolt
                          crablot.cdagenci = tel_cdagenci
                          crablot.cdbccxlt = 100
                          crablot.nrdolote = 10006  
                          crablot.tplotmov = 29.
                END.
                ASSIGN glb_cdcritic = 0
				       glb_dscritic = "".
       LEAVE.
   END.  /*  Fim do DO...TO  */
   
   IF glb_cdcritic <> 0 THEN
      RETURN.

   CREATE craplci.
   ASSIGN craplci.cdcooper = glb_cdcooper
          craplci.dtmvtolt = crablot.dtmvtolt
          craplci.cdagenci = crablot.cdagenci
          craplci.cdbccxlt = crablot.cdbccxlt
          craplci.nrdolote = crablot.nrdolote
          craplci.nrdconta = aux_nrdconta
          craplci.nrdocmto = tel_nrdocmto
          craplci.cdhistor = 482
          craplci.vllanmto = tel_vllanmto 
          craplci.nrseqdig = crablot.nrseqdig + 1.

   ASSIGN crablot.qtinfoln = crablot.qtinfoln + 1
          crablot.qtcompln = crablot.qtcompln + 1
          crablot.vlinfocr = crablot.vlinfocr + tel_vllanmto
          crablot.vlcompcr = crablot.vlcompcr + tel_vllanmto
          crablot.nrseqdig = craplci.nrseqdig.

   /*--- Atualizar Saldo Conta Investimento */
   FIND crapsli WHERE crapsli.cdcooper  = glb_cdcooper          AND
                      crapsli.nrdconta  = aux_nrdconta          AND
                MONTH(crapsli.dtrefere) = MONTH(tel_dtmvtolt)   AND
                 YEAR(crapsli.dtrefere) = YEAR(tel_dtmvtolt) 
                      EXCLUSIVE-LOCK NO-ERROR.

   /*--- Colocar opcao de locked ---*/
   
   IF  NOT AVAIL crapsli THEN 
       DO:
          ASSIGN aux_dtrefere = 
               ((DATE(MONTH(tel_dtmvtolt),28,YEAR(tel_dtmvtolt)) + 4) -
                 DAY(DATE(MONTH(tel_dtmvtolt),28,
                YEAR(tel_dtmvtolt)) + 4)).
           
          CREATE crapsli.
          ASSIGN crapsli.cdcooper = glb_cdcooper
                 crapsli.dtrefere = aux_dtrefere
                 crapsli.nrdconta = aux_nrdconta.
       END.

   ASSIGN crapsli.vlsddisp = crapsli.vlsddisp +  tel_vllanmto.
   
   RELEASE crapsli.
   RELEASE craplci.
   RELEASE crablot.
        
END PROCEDURE.
 
/* .......................................................................... */

PROCEDURE gera_lancamentos_craplci_debito:
     
   /*  Gera lancamentos Conta Investimento  - Debito  */
   DO  aux_contador = 1 TO 10:
        
                          
       FIND crablot WHERE crablot.cdcooper = glb_cdcooper  AND
                          crablot.dtmvtolt = tel_dtmvtolt  AND
                          crablot.cdagenci = tel_cdagenci  AND
                          crablot.cdbccxlt = 100           AND
                          crablot.nrdolote = 10006         EXCLUSIVE-LOCK
                          NO-ERROR NO-WAIT.

       IF   NOT AVAIL  crablot   THEN
            IF  LOCKED crablot   THEN
                DO:
                    glb_cdcritic = 77.
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
            ELSE
                DO:
                   CREATE crablot.
                   ASSIGN crablot.cdcooper = glb_cdcooper
                          crablot.dtmvtolt = tel_dtmvtolt
                          crablot.cdagenci = tel_cdagenci
                          crablot.cdbccxlt = 100
                          crablot.nrdolote = 10006  
                          crablot.tplotmov = 29.
                END.
       ASSIGN glb_cdcritic = 0
	          glb_dscritic = "".
       LEAVE.
   END.  /*  Fim do DO...TO  */
   
   IF glb_cdcritic <> 0 THEN
      RETURN.

   CREATE craplci.
   ASSIGN craplci.cdcooper = glb_cdcooper
          craplci.dtmvtolt = crablot.dtmvtolt
          craplci.cdagenci = crablot.cdagenci
          craplci.cdbccxlt = crablot.cdbccxlt
          craplci.nrdolote = crablot.nrdolote
          craplci.nrdconta = aux_nrdconta
          craplci.nrdocmto = tel_nrdocmto
          craplci.cdhistor = 484
          craplci.vllanmto = tel_vllanmto 
          craplci.nrseqdig = crablot.nrseqdig + 1.
                              
   ASSIGN crablot.qtinfoln = crablot.qtinfoln + 1
          crablot.qtcompln = crablot.qtcompln + 1
          crablot.vlinfodb = crablot.vlinfodb + tel_vllanmto
          crablot.vlcompdb = crablot.vlcompdb + tel_vllanmto
          crablot.nrseqdig = craplci.nrseqdig.

   /*--- Atualizar Saldo Conta Investimento */
   FIND crapsli WHERE crapsli.cdcooper  = glb_cdcooper          AND
                      crapsli.nrdconta  = aux_nrdconta          AND
                MONTH(crapsli.dtrefere) = MONTH(tel_dtmvtolt)   AND
                 YEAR(crapsli.dtrefere)  = YEAR(tel_dtmvtolt) 
                      EXCLUSIVE-LOCK NO-ERROR.
        
   /*--- Colocar o locked ---*/     
   
   IF  NOT AVAIL crapsli THEN
       DO:
          ASSIGN aux_dtrefere = 
               ((DATE(MONTH(tel_dtmvtolt),28,YEAR(tel_dtmvtolt)) + 4) -
                 DAY(DATE(MONTH(tel_dtmvtolt),28,
                YEAR(glb_dtmvtolt)) + 4)).
           
          CREATE crapsli.
          ASSIGN crapsli.cdcooper = glb_cdcooper
                 crapsli.dtrefere = aux_dtrefere
                 crapsli.nrdconta = aux_nrdconta.
       END.

   ASSIGN crapsli.vlsddisp = crapsli.vlsddisp -  tel_vllanmto.

   RELEASE crapsli.
   RELEASE craplci.
   RELEASE crablot.

END PROCEDURE.
  
/* .......................................................................... */

PROCEDURE pi_cria_dev:

DEF INPUT  PARAM par_cdcooper AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt AS DATE                                NO-UNDO.
DEF INPUT  PARAM par_cdbccxlt AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_inchqdev AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrdconta AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrdocmto AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrdctitg AS CHAR                                NO-UNDO.
DEF INPUT  PARAM par_vllanmto AS DECIMAL                             NO-UNDO.
DEF INPUT  PARAM par_cdalinea AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_cdhistor AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_cdoperad AS CHAR                                NO-UNDO.
DEF INPUT  PARAM par_cdagechq LIKE crapfdc.cdagechq                  NO-UNDO.
DEF INPUT  PARAM par_nrctachq LIKE crapfdc.nrctachq                  NO-UNDO.
DEF OUTPUT PARAM par_cdcritic AS INT                                 NO-UNDO.


 IF  par_inchqdev = 1   THEN  /* cheque normal */
     DO:  
         IF   CAN-FIND(crapdev WHERE crapdev.cdcooper = par_cdcooper     AND
                                     crapdev.cdbanchq = crapcop.cdbcoctl AND
                                     crapdev.cdagechq = par_cdagechq     AND
                                     crapdev.nrctachq = par_nrctachq     AND
                                     crapdev.nrcheque = par_nrdocmto     AND
                                     crapdev.cdhistor = 46)              OR
              CAN-FIND(crapdev WHERE crapdev.cdcooper = par_cdcooper     AND
                                     crapdev.cdbanchq = crapcop.cdbcoctl AND
                                     crapdev.cdagechq = par_cdagechq     AND
                                     crapdev.nrctachq = par_nrctachq     AND
                                     crapdev.nrcheque = par_nrdocmto     AND
                                     crapdev.cdhistor = par_cdhistor)    THEN
              DO:      
                  par_cdcritic = 415.
                  RETURN.
              END.
         
         IF   (par_cdalinea > 40 AND par_cdalinea < 50) OR
              (par_cdalinea = 20)                       OR
              (par_cdalinea = 28)                       OR
              (par_cdalinea = 30)                       OR
              (par_cdalinea = 31)                       OR
              (par_cdalinea = 32)                       OR
              (par_cdalinea = 35)                       OR
              (par_cdalinea = 72)                       THEN
              .
         ELSE
              DO:               
                  CREATE crapdev.
                  ASSIGN crapdev.cdcooper = par_cdcooper
                         crapdev.dtmvtolt = par_dtmvtolt
                         crapdev.cdbccxlt = par_cdbccxlt
                         crapdev.nrdconta = par_nrdconta
                         crapdev.nrdctabb = par_nrctachq
                         crapdev.nrdctitg = par_nrdctitg
                         crapdev.nrcheque = par_nrdocmto
                         crapdev.vllanmto = par_vllanmto
                         crapdev.cdalinea = par_cdalinea
                         crapdev.cdoperad = par_cdoperad
                         crapdev.cdhistor = 46
                         crapdev.cdpesqui = "TCO"
                         crapdev.insitdev = 1
                         crapdev.cdbanchq = par_cdbccxlt
                         crapdev.cdagechq = par_cdagechq
                         crapdev.nrctachq = par_nrctachq.

                  IF   par_nrdctitg = ""   THEN   /* Nao eh conta-integracao */
                       crapdev.indctitg = FALSE.
                  ELSE
                       crapdev.indctitg = TRUE.

                  VALIDATE crapdev.

              END.
                       
         CREATE crapdev.
         ASSIGN crapdev.cdcooper = par_cdcooper
                crapdev.dtmvtolt = par_dtmvtolt
                crapdev.cdbccxlt = par_cdbccxlt
                crapdev.nrdconta = par_nrdconta
                crapdev.nrdctabb = par_nrctachq
                crapdev.nrdctitg = par_nrdctitg
                crapdev.nrcheque = par_nrdocmto
                crapdev.vllanmto = par_vllanmto
                crapdev.cdalinea = par_cdalinea
                crapdev.cdoperad = par_cdoperad
                crapdev.cdhistor = par_cdhistor
                crapdev.cdpesqui = "TCO"
                crapdev.insitdev = 1
                crapdev.cdbanchq = par_cdbccxlt
                crapdev.cdagechq = par_cdagechq
                crapdev.nrctachq = par_nrctachq.
                
         IF   par_nrdctitg = ""   THEN   /* Nao eh conta-integracao */
              crapdev.indctitg = FALSE.
         ELSE
              crapdev.indctitg = TRUE.
         
         VALIDATE crapdev.

     END.

 
END PROCEDURE.

PROCEDURE gera_log_prejuizo:

  UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " - " +
                STRING(TIME,"HH:MM:SS") + 
                " - INCLUSAO DE LANCAMENTO" + "'-->'" +
                " Operador: " + glb_cdoperad +
                " Hst: " + STRING(craplcm.cdhistor) +
                " Conta: " + TRIM(STRING(craplcm.nrdconta,
                                         "zz,zzz,zzz,z")) + 
                " Doc: " + STRING(craplcm.nrdocmto) +
                " Valor: " + TRIM(STRING(craplcm.vllanmto,
                                         "zzzzzz,zzz,zz9.99")) +
                " Lote: " + TRIM(STRING(craplcm.nrdolote,"zzz,zz9")) + 
                " PA:  " + STRING(craplcm.cdagenci,"999") + 
                " Banco/Caixa: " + STRING(craplcm.cdbccxlt,"999") + 
                " >> log/landpv.log").


END PROCEDURE.


PROCEDURE gera_log_inclusao:

  UNIX SILENT VALUE(
        "echo " + STRING(glb_dtmvtolt,"99/99/9999") + " - "      +
        STRING(TIME,"HH:MM:SS")                                  + 
        " - INCLUSAO DE LANCAMENTO" + "'-->'"                    +
        " Operador: " + glb_cdoperad                             +

        " PA:  "         + STRING(tel_cdagenci,"999")   + 
        " Banco/Caixa: " + STRING(tel_cdbccxlt,"999")   +  
        " Lote: "     + TRIM(STRING(craplcm.nrdolote,"zzz,zz9")) + 

        " Hst: "      + STRING(craplcm.cdhistor)                 +
        " Conta: "    + TRIM(STRING(craplcm.nrdconta,
                                 "zz,zzz,zzz,z"))                + 
        " Bco: "      + STRING(tel_cdbaninf,"999")               + 
        " Age: "      + STRING(tel_cdageinf,"999")               + 
        " Doc: "      + STRING(craplcm.nrdocmto)                 +
        " Valor: "    + TRIM(STRING(craplcm.vllanmto,
                                 "zzzzzz,zzz,zz9.99"))           +
        
        " Contrato: " + STRING(tel_nrctremp)                     +
        " >> log/landpv.log").
END PROCEDURE.

/* .......................................................................... */


