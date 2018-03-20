/* ..............................................................................

   Programa: Fontes/atenda.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Maio/94.                          Ultima atualizacao: 13/09/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela ATENDA -- Atendimento Geral do Associado.

   Alteracoes: 08/06/94 - Alterado para tratar a descricao da situacao de con-
                          ta 5.

               21/06/94 - Alterado para permitir utilizar a taxa do mes na li-
                          quidacao do emprestimo (Edson).

               28/07/94 - Alteracoes para o controle do recadastramento e
                          atualizacao do arquivo crapalt.

               09/09/94 - Alterado valor da moeda para 8 casas decimais
                          (Deborah).

               25/10/94 - Alterado para tratar o historico 78, do mesmo modo
                          que o 47 (Deborah).

               03/11/94 - Alterado para incluir a comparacao do codigo de his-
                          torico 46 atraves de uma variavel (Odair).

               16/11/94 - Alterado para incluir a media de saque s/bloqueado
                          (Deborah).

               02/03/95 - Alterado para criar sub-rotinas para os calculos de
                          saldo (Edson).

               22/03/95 - Alterado para nao mostrar o capital em moeda fixa
                          (Deborah).

               17/04/95 - Alterado para modificar o layout incluindo os campos
                          fator salarial, ramal e funcao (Odair).

               26/04/95 - Alterado para mostrar o valor aplicado no extrato de
                          RDCA (Odair).

               03/08/95 - Alterado para incluir rotina de impressao de extrato
                          de depositos a vista (Edson).

               09/10/95 - Alterado para colocar a data de admissao na empresa
                          (Deborah).

               17/01/96 - Alterado para exibir o CPF (Odair).

               04/03/96 - Alterado para colocar o turno e a naturalidade do
                          primeiro titular (Deborah).

               21/08/96 - Alterado para exibir o limite do cartao Credicard
                          (Edson).

               06/12/96 - Mostrar se o capital tem desconta em folha/conta
                          (Odair).

               18/12/96 - Alterado para incluir terceira columa de saldos
                          (Edson).

               07/01/97 - Alterado para tratar automacao dos planos de capital
                          (Edson).

               16/01/97 - Alterado para tratar a CPMF (Edson).

               06/03/97 - Tratar cancelamento de seguro (Odair).

               10/03/97 - Na impressao de extrato, verificar se ja foi solici-
                          tado extrato para o dia (Odair)

               11/03/97 - Tratar cartao de credito (Odair).

               29/08/97 - Tratar Folha (Odair).

               22/12/97 - Alterado para mostrar o saldo "folha" ate o dia 25
                          (Deborah).

               14/01/98 - Alterado para permitir consulta das informacoes
                          complementares dos emprestimos (Edson).

               16/02/98 - Alterar data final do CPMF (Odair)

               16/03/98 - Alterado para acrescentar o historico 282 ao 108
                          (Deborah).

               15/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               29/04/98 - Incluir a quantidade de talonarios retirados no
                          mes (Deborah).

               19/08/98 - Tratar cartao de credito VISA-BRADESCO (Odair)

               09/10/98 - Colocar mensagem para o ANIVERSARIO DO MARCOS
                          (Deborah).

               09/11/98 - Tratar situacao em prejuizo (Deborah).
               
               14/01/99 - Tratar cartao magnetico de conta-corrente (Edson).

               20/01/99 - Calcular IOF sobre os emprestimos que serao
                          liberados (Deborah).
                                  
               26/01/99 - Mostrar a base de calculo do IOF sobre c/c (Deborah).
               
               05/03/99 - Tratar contrato de cheque especial (Odair)

               20/05/1999 - Ajustes no layout (Deborah).  

               21/05/1999 - Ajustes no layout (Deborah). 

               07/06/1999 - Tratar CPMF (Deborah).

               23/08/1999 - Imprimir cheques pendentes (Edson).
               
               06/04/2000 - Tratar 2 proponente (Odair)
               
               10/08/2000 - Emitir mensagem quando o associado for fiador
                            de algum emprestimo em atraso (Edson).
                            
               05/10/2000 - Emitir mensagem quando o associado for devedor
                            de algum emprestimo em atraso (Eduardo).

               23/10/2000 - Desmembrar a critica 95 conforme a situacao
                            do titular (Eduardo).

               15/01/2001 - Substituir CCOH por COOP (Margarete/Planner).

               08/03/2001 - Rotina de mensagem para prestacoes de emprestimo
                            em atraso e colocada a secao de extrato na tela
                            (Deborah).

               03/07/2001 - Mostrar a quantidade de devolucoes e mensagem 
                            se houver emprestimo em prejuizo. (Jose/Deborah)
                            
               25/07/2001 - Resgate on-line de aplicacoes RDCA. (Eduardo)
               
               09/11/2001 - Criticar se limite de credito estiver vencido ha
                            mais de 180 dias (Junior).
                            
               24/01/2002 - Criticar se o associado estiver com CPF irregular
                            (Ze Eduardo).

               05/03/2002 - Preve pagto antecipado (Margarete).

               12/04/2002 - Tratar resgate on_line (Mag).

               24/04/2002 - Tratar impressao dos cheques depositados (Edson).
 
               06/05/2002 - Qdo pagto fim semana mensagem critica (Margarete)
               
               07/05/2002 - Quando o prejuizo foi pago, mostrar "liquidado"
                            na mensagem de prejuizo (Deborah).

               08/05/2002 - Qdo pagto em feriado mensagem critica (Margarete).

               29/07/2002 - Incluir novo cdsitdct (Margarete).

               07/08/2002 - Incluir opcao internet (Margarete).

               05/11/2002 - Mostrar mensagem de fiador em atraso se o contrato
                            estiver em prejuizo (Deborah).

               10/03/2003 - Tratar desconto de cheques (Edson).
 
               14/10/2003 - Corrigir critica 691 (Margarete).

               26/02/2004 - Mesmo com pagto antecipado cobrar a prestacao
                            do mes (Margarete).

               07/04/2004 - Nao mostrava mensagem do fiador (Margarete).
               
               28/04/2004 - Nao parava nas mensagens de limites (Margarete).
               
               28/04/2004 - Tratar parcelamento do capital inicial (Edson).
               
               29/06/2004 - Ler crapavl com tpdcontr = 1 (Emprestimo)(Mirtes) 
               
               02/09/2004 - Nao mostrar mensagem de emprestimo em atraso se for
                            do tipo consignacao (Julio)

               03/09/2004 - Tratar contas integracao (Margarete).

               06/09/2004 - Demonstrar saldo Conta Investimento(Mirtes). 

               03/11/2004 - Mostrar mensagem se o associado esta no CCF 
                            (Edson).

               09/11/2004 - Se fiador possuir emprestimo com vencto em  dia
                            nao util esta saindo mensagem de atraso(691)
                            Efetuado acerto.(Mirtes)

               16/12/2004 - Chamar rotina de pesquisa/zoom de associados
                            (Edson).

               16/12/2004 - Ajuste (Remodelagem) Tela ATENDA(Mirtes).

               09/03/2005 - Permitir acessar tela qdo glb_inproces >=3(Mirtes)
               
               18/03/2005 - Acertar rotina testa_fiador(MIrtes)

               23/03/2005 - Incluido campo inc_nrctremp(Mirtes)

               13/06/2005 - Mensagem quando o limite de desconto de cheques
                            estiver vencido (Evandro).
                            
               14/06/2005 - Acertado a procedure testa_fiador (Evandro).
               
               24/06/2005 - Na opcao DEP.VISTA  implementada rotina            
                            Saldos Anteriores; Alimentado campo cdcooper da    
                            tabela crapsol (Diego).
            
               27/06/2005 - Possibilitar pesquisa com mais de 2 meses(Mirtes).
               
               18/08/2005 - Na opcao DEP.VISTA acrescentado campo aux_dtafinal
                            a rotina Imprime Extrato, para esclher o periodo
                            do extrato (Diego).

               13/09/2005 - Zeradas variaves s_chextent/aux_nrctatos(Mirtes).
               
               30/09/2005 - Incluir critica de IMPRESSAO TERMO CI (Ze).

               04/10/2005 - Incluido flag(impressao termo CI)/Alterada
                            posicao mensagem(Mirtes).

               04/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).

               22/11/2005 - Nova situacao cpf - suspenso (Magui).

               14/12/2005 - Criada opcao "URA" (Diego).
                
               24/01/2006 - Unificacao dos bancos - SQLWorks - Luciane.
               
               06/02/2006 - Incluida a opcao de CONVENIOS (Evandro).
               
               10/02/2006 - Finalizacao do processo de Unificacao dos bancos
                            de dados - SQLWorks - Andre
                            
               13/02/2006 - Inclusao do parametro glb_cdcooper para a
                            chamada do programa ~fontes/zoom_associados.p 
                            SQLWorks - Andre

               08/05/2006 - Incluir OCORRENCIAS no lugar de CTR.ORDENS(Magui).
               
               13/06/2006 - Inclusao do campo Data SFN, e mensagem se   
                            existir cartao magnetico disponivel para entrega   
                            (David).
                            
               20/06/2006 - Incluido o comando ELSE na verificacao de
                            Data SFN, e apresentacao dos campos tel_qtddtdev
                            e tel_qtdevolu (David).
               
               07/07/2006 - Tratar campo nrdconta nas TEMP-TABLEs workepr e
                            workepr_saldo (Edson).

               27/07/2006 - Acerto na leitura da tabela crapsnh, com
                            idseqttl agora = 0, referente URA (Diego).
                            
               11/09/2006 - Alterado do novo Cadastro Pessoa Juridica. (Ze).
               
               19/09/2006 - Alterados os nomes das rotinas de acordo com o que
                            esta nos labels dos itens e permitir o uso do
                            F2-AJUDA;
                          - Informar se houve alteracao de endereco pela
                            internet (Evandro).
               
               26/09/2006 - Alterado campo tel_nrramfon para receber dados da
                            tabela de telefones craptfc (Elton).           
                              
               03/11/2006 - Tratamento para acesso a tela "ESTOUR", Consulta de
                            associado por Conta/ITG (David).
                           
               07/11/2006 - Utilizar a tabela crapsnh para o item INTERNET
                            (Evandro).
                            
               29/11/2006 - Criticar qdo tipo de conta for Individual e tiver
                            mais de um titular (Ze).
                            
               04/12/2006 - Subst. Funcao por Ocupacao/Conectar Generico (Ze).
               
               11/12/2006 - Verificar se eh Conta Salario - crapccs (Ze).
               
               11/01/2007 - Correcao na verificacao dos CONTATOS (Evandro).
               
               01/02/2007 - Mostrar telefone Comercial caso nao tenha Celular
                            ou telefone Residencial (Diego).

               02/02/2007 - Exclusao dos campos tel_vlbasiof, tel_vlcmecot,
                            tel_vlmoefix (Diego).
                            
               09/02/2007 - Incluido campo tel_vlmoefix (Diego).
               
               21/02/2007 - Incluida verificacao para impressao de Termo BANCOOB
                            (Diego).
                            
               21/03/2007 - Nao verificar as eh conta salario (Evandro).
               
               09/04/2007 - Trocado o termo "cheques pendentes" pelo termo
                            "cheques nao compensados" (Evandro).
                            
               11/04/2007 - Substituir craptab "LIMCHEQESP" pelo craplrt (Ze).

               16/04/2007 - Alterar sequencia de visualizacao dos telefones 
                            (David).

               15/05/2007 - Retirado o comentario para critica de contrato de
                            limite de credito vencido (Julio).

               21/05/2007 - Trocar termo "Saldo RDCA" para "Aplicacoes" (David).
               
               16/08/2007 - Alterado para preencher campo "Data SFN" com data 
                            de abertura de conta mais antiga na crapsfn (Elton).
              
               02/10/2007 - Alterada pesquisa tabela craplrt.(Mirtes)
                            Alterado o fonte qttalona.p, que alem do total de 
                            folhas de cheque em uso, vai contabilizar tambem o
                            total de folhas retiradas no mes (Julio)

               29/10/2007 - Incluidos campos "PAC", "Banco/Caixa" e "Lote" no
                            item CAPITAL (Diego).
               
               17/12/2007 - Entrar na rotina APLICACOES mesmo nao possuindo 
                            saldo de aplicacoes. Assim operadores podem fazer
                            simulacao de aplicacoes mesmo nao possuindo 
                            saldo(Guilherme).

               20/02/2008 - Mostar turno da crapttl.cdturnos, liberacao de
                            registro crapttl quando for pessoa juridica        
                            (Gabriel).
                            
               24/04/2008 - Verificacao para impressao do ctrato de poupanca
                            programada(Guilherme).
                            
               09/06/2008 - Incluir parametro inpessoa na chamada do 
                            fontes/carmag.p (Guilherme).
                            
               11/06/2008 - Utilizar BO b1wgen0003 no lugar do programa
                            "sld lau.p" para buscar informacoes de Lancamentos
                            Automaticcos (Sidnei - Precise).

               08/07/2008 - Utilizar BO b1wgen0026 no lugar do programa
                            "fontes/lis conve" para buscar informacoes de
                            convenios (Sidnei - Precise)
               
               09/07/2008 - Lautom mostrando 01/01/1099 no debito (Magui).
               
               22/07/2008 - Utilizar BO b1wgen0027 para exibir informacoes 
                            de ocorrencias (Sidnei - Precise)
                            
               05/08/2008 - Utilizar BO b1wgen0021 para exibir informacoes
                            de capital (Sidnei - Precise)
                            
               12/08/2008 - Utilizar BO b1wgen0020 para exibir informacoes
                            de conta investimento (Sidnei - Precise)           
                          - Corrigir procedure exibe_lanc_automaticos, pois nao
                            estava escondendo o browse corretamente (David).
                          - Corrigir ocupacao das pessoas juridicas (Gabriel).
                          - Adaptacao da tela para descto de titulos
                          - Corrigido rotina de capital, estava escondendo 
                            os frames de forma incorreta
                          - Alterado UF "SC" que estava fixo (Guilherme).

               07/11/2008 - Correcao na utilizacao das novas BO's utilizadas
                            na tela (David).
                            
               18/12/2008 - Corrigido parametro na chamada da procedure de 
                            impressao de capital (Guilherme).

               29/12/2008 - Usar includes/sititg.i para a situacao da
                            Conta Integracao (Gabriel).
                            
               13/01/2009 - Alteracao campo cdempres (Diego).

               05/03/2009 - Inclusao opcao Cash na rotina dep. vista (Fernando).
                
               28/04/2009 - Alimentar variavel aux_dsdrisco[10] = "H" (David).
               
               11/05/2009 - Alteracao CDOPERAD (Kbase).

               25/05/2009 - Incluido o item RELACIONAMENTO (Gabriel). 
               
               20/07/2009 - alterado program para rodar em modo batch e 
                            on-line - Precise - Paulo

               15/09/2009 - Incluir campos para informa o periodo de consulta
                            do extrato de capital (David).
                                       
               23/09/2009 - Incluir opcao para listar depositos identificados
                            na rotina DEP.VISTA (David). 
                            
               21/10/2009 - Adaptaçoes IF CECRED (Guilherme).
               
               11/11/2009 - Ajuste para o novo Termo de Adesao - retirar o 
                            antigo Termo CI e Termo BANCCOB (Fernando).
                            
               16/12/2009 - Alterado label (dd) por (ocor) no campo Estouros do 
                            item "OCORRENCIAS" (Elton).
                             
               31/05/2010 - Retirada procedure que obtem o risco do 
                            cooperado - Nao era utilizada (Gabriel)
                            
               18/08/2010 - Incluido os campos "Data do Risco" e "Dias no Risco"
                            no item Ocorrencias (Elton).
                            
               08/09/2010 - Utilizar novo programa depvista.p para a rotina
                            DEP.VISTA (David).
                
               22/09/2010 - Retirada a includes var_proepr que nao eh mais
                            necessaria e o find na crapemp (Gabriel).
                            
               07/10/2010 - Uso da BO 31. (Gabriel, DB1)
               
               21/10/2010 - Alteracoes para implementacao de limites de credito
                            com taxas diferenciadas:
                            - Alteracao da nomenclatura "CREDITO ROT" para
                              "LIMITE EMP". (Eder - GATI)
                              
               07/12/2010 - Retirar campo 'Ft.Salarial'. 
                            Incluir rotina Cobranca.
                            Utilizar o fontes/confirma para confirmacoes.
                            Retirar comentarios desnecessarios. (Gabriel).   
                            
               13/01/2011 - Criar browse para os telefones do cooperado
                            (Gabriel)
                            
               03/02/2011 - Retirado procedures testa_fiador, 
                            grava_tabela_fiador e testa_devedor (Gabriel/DB1)
                            
               11/02/2011 - Inserido no TERMO DE CANCELAMENTO DE CAPITAL a
                            instrucao para o cancelamento efetivo do mesmo.
                            (Fabricio)
                            
               04/03/2011 - Incluido campo "Risco Cooperado" na procedure
                            exibe_ocorrencias. (Fabricio)
                            
               09/03/2011 - Alterado FORMAT do campo tt-contra_ordem.dshistor 
                            para 50 posicoes (Diego).
                            
               27/07/2011 - Retirado verificacao de demissao do contato do 
                            cooperado, passado para BO b1wgen0031.p (Jorge)
                            
               04/10/2011 - Adicionado o parametro par_flgerlog na chamada da 
                            procedure extrato_cotas (Rogerius Militao - DB1)
                            
               13/01/2012 - Modificado a formatacao do campo tt-spc.nrctremp 
                            no display (Tiago).             
                            
               08/02/2012 - Incluir parametro em extrato_investimento (David)
               
               22/03/2012 - Movida procedure 'obtem-mensagens-alerta' para
                            nao excutar quando ATENDA for chamada em
                            background para validacao de tempos (Diego).
               
               04/10/2012 - Alterado impressao da conta investimento para
                            a b1wgen0112 (Lucas R.).
                            
               16/10/2012 - Nova chamada da procedure valida_operador_migrado
                            da b1wgen9998 para controle de contas e operadores
                            migrados (David Kruger).
                                         
              17/10/2012 - Incluir campos na tela ocorrencias dsdrisgp, incluir
                           frame para exibir participantes do grupo (Lucas R.) 
                           
              08/01/2013 - Correçao críticas genéricas (Lucas).
              
              06/02/2013 - Incluir chamada da procedure valida_restricao_operador
                           (Lucas R.).
                           
              20/05/2013 - Ajustes na opcao Prestacao para chamar novo fonte
                           sldbndes.p (Lucas R.)
                           
              30/07/2013 - Tratamento para permanecer com o foco na opcao
                           PRESTACOES apos LASTKEY = "END-ERROR" no frame
                           f_bndes_1. (Fabricio)
              
              26/08/2013 - Alterado para nao usar mais informaçoes de telefone 
                           da tabela CRAPASS para usar a CRAPTFC (Daniele).
                         - Substituir campo crapass.dsnatura pelo campo
                           crapttl.dsnatura (David).
                           
              01/10/2013 - Criado opcao para integralizacao e/ou estorno de
                           capital, no item CAPITAL. (Fabricio)
                           
              11/10/2013 - Adicionado o item Consorcio (SIM/NAO), que, quando
                           acessado, mostra a lista de consorcios ativos do
                           cooperado e os detalhes dos mesmos (Carlos)
                           
              30/10/2013 - Adicionado tratamento para que o programa permita
                           que a senha da ura senha também criada, nao apenas
                           alterada (Oliver - GATI).
              04/11/2013 - Nova forma de chamar as agencias, de PAC agora 
                           a escrita será PA (Guilherme Gielow)
                           
              28/11/2013 - Inclusao de VALIDATE crapsol (Carlos)
              
              31/01/2014 - Aumentado format dos campos tel_vintegra e
                           tt-lancamentos.vllanmto. (Fabricio)
                           
              25/02/2014 - Criado opcao para alterar o plano de capital.
                           Adicionado ao plano de capital o tipo de correcao
                           (pla_atualiza) a ser praticada sob o valor do plano.
                           (Fabricio)
                           
              08/04/2014 - Ajuste de whole index (Jean Michel).
              
              28/05/2014 - Concatena o numero do servidor no endereco do
                           terminal (Andrino-RKAM)
                           
              23/06/2014 - Inclusao da include b1wgen0138tt para uso da
                           temp-table tt-grupo ao invés da tt-ge-ocorrencias.
                           (Chamado 130880) - (Tiago Castro - RKAM)
                           
              03/07/2014 - Restricao de operador via conta ITG (Chamado 163002)
                           (Jonata-RKAM).                 
              16/08/2014 - Alteracao do texto do termo de Plano de Capital
                           (Guilherme/SUPERO)
                           
              25/08/2014 - Substituido chamada do fonte sldrda.p, para
                           obtem-dados-aplicacoes e pc_busca_saldos_aplicacoes,
                           para o projetode captacao. (Jean Michel)
              
              18/11/2014 - Adicionado format no campo tt-extrato_inv.vllanmto da 
                           exibe_conta_investimento (Douglas - Chamado 191418)
                           
              21/01/2015 - Inclusao do parametro aux_intpextr na chamada da funcao
                           Gera_Impressao para ser usado na pc_gera_impressao_car.
                           (Carlos Rafael Tanholi - Projeto Captacao)                            
              
              22/01/2015 - Alterado o formato do campo nrctremp para 8 
                           caracters (Kelvin - 233714)
                           
              27/08/2015 - Ajustado selecao de opcao em conta investimento.
                           (Jorge/Gielow) SD - 310965
                           
              25/11/2015 - Adicionado condicao para conta que exige assinatura conjunta
                           em "Situacao de acesso a conta via internet".
                           (Jorge/David) Projeto 131 - Multipla Assinatura PJ

		       	  13/09/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                     crapass, crapttl, crapjur (Adriano - P339).

		       	  06/03/2018 - Ajuste para buscar a descricao do tipo de conta do oracle. PRJ366 (Lombardi)

............................................................................. */

{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen0003tt.i }
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0020tt.i }
{ sistema/generico/includes/b1wgen0021tt.i }
{ sistema/generico/includes/b1wgen0026tt.i }
{ sistema/generico/includes/b1wgen0027tt.i }
{ sistema/generico/includes/b1wgen0030tt.i }
{ sistema/generico/includes/b1wgen0031tt.i }
{ sistema/generico/includes/b1wgen0147tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0138tt.i }

{ sistema/generico/includes/var_oracle.i }

{ includes/var_online.i}
{ includes/var_atenda.i "NEW" }
{ includes/ctremp.i "NEW" }
{ includes/var_cpmf.i }
{ includes/gg0000.i }  

DEF        VAR tab_diapagto AS INTE                                    NO-UNDO.
DEF        VAR tab_indpagto AS INTE                                    NO-UNDO.
DEF        VAR tab_dtcalcul AS DATE                                    NO-UNDO.
DEF        VAR tab_dtlimcal AS DATE                                    NO-UNDO.
DEF        VAR tab_flgfolha AS LOGI                                    NO-UNDO.
DEF        VAR tab_inusatab AS LOGI                                    NO-UNDO.

DEF        VAR inc_nrdconta AS INTE FORMAT "zzzz,zzz,9"                NO-UNDO.
DEF        VAR inc_dtcalcul AS DATE FORMAT "99/99/9999"                NO-UNDO.
DEF        VAR inc_nrctremp LIKE crapepr.nrctremp                      NO-UNDO.

DEF        VAR ant_vlsdeved AS DECI                                    NO-UNDO.

DEF        VAR aux_dtcalcul AS DATE                                    NO-UNDO.
DEF        VAR aux_dtultdia AS DATE                                    NO-UNDO.
DEF        VAR aux_dtrefere AS DATE                                    NO-UNDO.
DEF        VAR aux_dtinipag AS DATE                                    NO-UNDO.
DEF        VAR aux_dtabtcc2 AS DATE                                    NO-UNDO.
DEF        VAR aux_dtiniiof AS DATE FORMAT "99/99/9999"                NO-UNDO.
DEF        VAR aux_dtfimiof AS DATE FORMAT "99/99/9999"                NO-UNDO.
DEF        VAR aux_vldescto AS DECI                                    NO-UNDO.
DEF        VAR aux_vlprovis AS DECI                                    NO-UNDO.
DEF        VAR aux_vlalipmf AS DECI                                    NO-UNDO.
DEF        VAR aux_txiofepr AS DECI FORMAT "zzzzzzzz9,999999"          NO-UNDO.
DEF        VAR aux_empatr   AS INTE                                    NO-UNDO.
DEF        VAR aux_inconfir AS INTE                                    NO-UNDO.
DEF        VAR aux_qtfolhas AS INTE                                    NO-UNDO.
DEF        VAR aux_qttitula AS INTE                                    NO-UNDO.
DEF        VAR aux_conttitu AS INTE                                    NO-UNDO.
DEF        VAR aux_tptelefo AS CHAR                                    NO-UNDO.
DEF        VAR aux_fone     AS CHAR                                    NO-UNDO.
DEF        VAR aux_cdoperad AS CHAR                                    NO-UNDO.
DEF        VAR aux_dsprejuz AS CHAR                                    NO-UNDO.
DEF        VAR aux_confirma AS CHAR FORMAT "!"                         NO-UNDO.
DEF        VAR aux_regexist AS LOGI                                    NO-UNDO.
DEF        VAR aux_flgpreju AS LOGI                                    NO-UNDO.
DEF        VAR aux_erro     AS LOGI                                    NO-UNDO.
DEF        VAR aux_flgsenha AS LOGI                                    NO-UNDO.
DEF        VAR aux_flgdsair AS LOGI                                    NO-UNDO.
DEF        VAR aux_flgsair  AS LOGI                                    NO-UNDO.
DEF        VAR rel_nmrescop AS CHAR EXTENT 2                           NO-UNDO.
DEF        VAR aux_opmigrad AS LOGI                                    NO-UNDO.
DEF        VAR aux_dscritic AS CHAR                                    NO-UNDO.
DEF        VAR aux_vlparepr AS DEC                                     NO-UNDO.
DEF        VAR aux_vlsaldod AS DEC                                     NO-UNDO.
DEF        VAR aux_flgconso AS LOGI                                    NO-UNDO.
DEF        VAR aux_dstipcta AS CHAR                                    NO-UNDO.
DEF        VAR aux_des_erro AS CHAR                                    NO-UNDO.

DEF        VAR aux_vlsldrgt AS DEC                                     NO-UNDO.
DEF        VAR aux_vlsldtot AS DEC                                     NO-UNDO.
DEF        VAR aux_vlsldapl AS DEC                                     NO-UNDO.
DEF        VAR aux_cdcritic LIKE crapcri.cdcritic                      NO-UNDO.
DEF        VAR aux_nrdrowid AS ROWID                                   NO-UNDO.

DEF        VAR h-b1wgen0002 AS HANDLE                                  NO-UNDO.
DEF        VAR h-b1wgen0003 AS HANDLE                                  NO-UNDO.
DEF        VAR h-b1wgen0020 AS HANDLE                                  NO-UNDO.
DEF        VAR h-b1wgen0021 AS HANDLE                                  NO-UNDO.
DEF        VAR h-b1wgen0026 AS HANDLE                                  NO-UNDO.
DEF        VAR h-b1wgen0027 AS HANDLE                                  NO-UNDO.
DEF        VAR h-b1wgen0030 AS HANDLE                                  NO-UNDO.
DEF        VAR h-b1wgen0031 AS HANDLE                                  NO-UNDO.
DEF        VAR h-b1wgen0081 AS HANDLE                                  NO-UNDO.
DEF        VAR h-b1wgen0082 AS HANDLE                                  NO-UNDO.
DEF        VAR h-b1wgen0112 AS HANDLE                                  NO-UNDO.  
DEF        VAR h-b1wgen0162 AS HANDLE                                  NO-UNDO.
DEF        VAR h-b1wgen9998 AS HANDLE                                  NO-UNDO.
DEF        VAR h-b1wgen0147 AS HANDLE                                  NO-UNDO.

DEF        VAR tel_cooperat AS CHAR  FORMAT "x(11)" INIT "Cooperativa" NO-UNDO.
DEF        VAR tel_bndes AS CHAR FORMAT "x(5)"      INIT "BNDES"       NO-UNDO.

FORM SKIP(1)
     "   Selecione o Emprestimo desejado:    " AT 02
     SKIP(2)
     tel_cooperat AT 10
     tel_bndes    AT 25
     SKIP(1)
     WITH ROW 9 CENTERED NO-LABELS SIDE-LABELS OVERLAY FRAME f_bndes_1.

DEF BUFFER crabttl FOR crapttl.
DEF BUFFER crabepr FOR crapepr.

DEF TEMP-TABLE workspc           NO-UNDO
    FIELD nrctremp               LIKE crapspc.nrctremp
    FIELD dsorigem               AS CHAR FORMAT "X(06)" 
    FIELD dsidenti               AS CHAR FORMAT "x(16)"
    FIELD dtvencto               LIKE crapspc.dtvencto
    FIELD dtinclus               LIKE crapspc.dtinclus
    FIELD vldivida               LIKE crapspc.vldivida
    FIELD nrctrspc               LIKE crapspc.nrctrspc 
    FIELD dtdbaixa               LIKE crapspc.dtdbaixa. 

DEF TEMP-TABLE tt-lanc-estorno NO-UNDO LIKE tt-lancamentos.

DEF STREAM str_1.

IF (glb_conta_script > 0) THEN
DO:
    ASSIGN glb_nmdatela = "ATENDA"
           glb_cdprogra = "ATENDA"
           glb_nmsistem = "CRED"
           glb_cdoperad = "1"
           glb_dsdepart = "TI".
		   glb_cddepart = 20.
END.


ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       aux_dtrefcot = DATE(MONTH(glb_dtmvtolt),01,YEAR(glb_dtmvtolt))

       aux_nrmesant = IF MONTH(glb_dtmvtolt) = 1
                         THEN 12
                         ELSE MONTH(glb_dtmvtolt) - 1

       tel_dsmesatu = aux_nmmesano[MONTH(glb_dtmvtolt)]
       tel_dsmesant = aux_nmmesano[aux_nrmesant].

RUN fontes/inicia.p.

RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT SET h-b1wgen0002.

IF  NOT VALID-HANDLE(h-b1wgen0002)  THEN
    DO:
        glb_nmdatela = "MENU00".
    
        BELL.
        MESSAGE "Handle invalido para BO b1wgen0002.".
        IF (glb_conta_script = 0) THEN
            PAUSE 3 NO-MESSAGE.
        
        RETURN.
    END.

RUN sistema/generico/procedures/b1wgen0003.p PERSISTENT SET h-b1wgen0003.

IF  NOT VALID-HANDLE(h-b1wgen0003)  THEN
    DO:
        glb_nmdatela = "MENU00".
    
        BELL.
        MESSAGE "Handle invalido para BO b1wgen0003.".
        IF (glb_conta_script = 0) THEN
            PAUSE 3 NO-MESSAGE.
        
        RETURN.
    END.

RUN sistema/generico/procedures/b1wgen0020.p PERSISTENT SET h-b1wgen0020.

IF  NOT VALID-HANDLE(h-b1wgen0020)  THEN
    DO:
        glb_nmdatela = "MENU00".
    
        BELL.
        MESSAGE "Handle invalido para BO b1wgen0020.".
        IF (glb_conta_script = 0) THEN
            PAUSE 3 NO-MESSAGE.
        
        RETURN.
    END.
         
RUN sistema/generico/procedures/b1wgen0021.p PERSISTENT SET h-b1wgen0021.

IF  NOT VALID-HANDLE(h-b1wgen0021)  THEN
    DO:
        glb_nmdatela = "MENU00".
    
        BELL.
        MESSAGE "Handle invalido para BO b1wgen0021.".
        IF (glb_conta_script = 0) THEN
            PAUSE 3 NO-MESSAGE.
        
        RETURN.
    END.
            
RUN sistema/generico/procedures/b1wgen0026.p PERSISTENT SET h-b1wgen0026.

IF  NOT VALID-HANDLE(h-b1wgen0026)  THEN
    DO:
        glb_nmdatela = "MENU00".
    
        BELL.
        MESSAGE "Handle invalido para BO b1wgen0026.".
        IF (glb_conta_script = 0) THEN
            PAUSE 3 NO-MESSAGE.
        
        RETURN.
    END.
                
RUN sistema/generico/procedures/b1wgen0027.p PERSISTENT SET h-b1wgen0027.

IF  NOT VALID-HANDLE(h-b1wgen0027)  THEN
    DO:
        glb_nmdatela = "MENU00".
    
        BELL.
        MESSAGE "Handle invalido para BO b1wgen0027.".
        IF (glb_conta_script = 0) THEN
            PAUSE 3 NO-MESSAGE.
        
        RETURN.
    END.
                    
RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.

IF  NOT VALID-HANDLE(h-b1wgen0030)  THEN
    DO:
        glb_nmdatela = "MENU00".
    
        BELL.
        MESSAGE "Handle invalido para BO b1wgen0030.".
        IF (glb_conta_script = 0) THEN
            PAUSE 3 NO-MESSAGE.
        
        RETURN.
    END.    
    
RUN sistema/generico/procedures/b1wgen0112.p PERSISTENT SET h-b1wgen0112.
    
IF  NOT VALID-HANDLE(h-b1wgen0112) THEN
    DO:
        glb_nmdatela = "MENU00".
    
        BELL.
        MESSAGE "Handle invalido para BO b1wgen0112.".
        IF (glb_conta_script = 0) THEN
            PAUSE 3 NO-MESSAGE.
        
        RETURN.
    END.                    

RUN sistema/generico/procedures/b1wgen0147.p PERSISTEN SET h-b1wgen0147.

IF  NOT VALID-HANDLE(h-b1wgen0147) THEN
    DO:
        glb_nmdatela = "MENU00".
    
        BELL.
        MESSAGE "Handle invalido para BO b1wgen0147.".
        IF (glb_conta_script = 0) THEN
            PAUSE 3 NO-MESSAGE.
    
        RETURN.
    END.                    

VIEW FRAME f_moldura.
   
PAUSE 0.
    
DO WHILE TRUE:

    COLOR DISPLAY NORMAL tel_dsdopcao WITH FRAME f_atenda.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       IF (glb_conta_script = 0) THEN
       DO:
           UPDATE tel_nrdconta WITH FRAME f_atenda

           EDITING:
         
               aux_stimeout = 0.

               DO WHILE TRUE:

                   READKEY PAUSE 1.

                   IF   LASTKEY = -1   THEN
                   DO:
                       aux_stimeout = aux_stimeout + 1.

                       IF   aux_stimeout > glb_stimeout   THEN
                       DO:
                           DELETE PROCEDURE h-b1wgen0002.
                           DELETE PROCEDURE h-b1wgen0003.
                           DELETE PROCEDURE h-b1wgen0020.
                           DELETE PROCEDURE h-b1wgen0021.
                           DELETE PROCEDURE h-b1wgen0026.
                           DELETE PROCEDURE h-b1wgen0027.
                           DELETE PROCEDURE h-b1wgen0030.
                           DELETE PROCEDURE h-b1wgen0112.
                           DELETE PROCEDURE h-b1wgen0147.
                           QUIT.
                       END.    
               
                       NEXT.
                   END.

                   IF   LASTKEY = KEYCODE("F7") THEN
                   DO:
                       RUN fontes/zoom_associados.p (INPUT  glb_cdcooper,
                                                    OUTPUT tel_nrdconta).

                       IF   tel_nrdconta > 0   THEN
                       DO:
                           DISPLAY tel_nrdconta WITH FRAME f_atenda.
                           PAUSE 0.
                           APPLY "RETURN".
                       END.
                   END.
                   ELSE
                       APPLY LASTKEY.

                   LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

           END.  /*  Fim do EDITING  */
           
           IF NOT VALID-HANDLE(h-b1wgen9998) THEN
                RUN sistema/generico/procedures/b1wgen9998.p PERSISTENT SET h-b1wgen9998.

           /* Validacao de operado e conta migrada */
           RUN valida_operador_migrado IN h-b1wgen9998 (INPUT glb_cdoperad,
                                                        INPUT tel_nrdconta,
                                                        INPUT glb_cdcooper,
                                                        INPUT glb_cdagenci,
                                                        OUTPUT aux_opmigrad,
                                                        OUTPUT TABLE tt-erro).
                
           IF VALID-HANDLE(h-b1wgen9998) THEN
                DELETE PROCEDURE h-b1wgen9998.
              
           IF RETURN-VALUE <> "OK" THEN
              DO:
                 FIND FIRST tt-erro NO-LOCK NO-ERROR.
               
                 IF AVAIL tt-erro THEN
                    DO:
                        BELL.
                        MESSAGE tt-erro.dscritic.
                        PAUSE 3 NO-MESSAGE.
                        HIDE MESSAGE.
                        NEXT.
                    END.
              
              END.

           IF NOT VALID-HANDLE(h-b1wgen9998) THEN
              RUN sistema/generico/procedures/b1wgen9998.p
                   PERSISTENT SET h-b1wgen9998.

           RUN valida_restricao_operador IN h-b1wgen9998
                                         (INPUT glb_cdoperad,
                                          INPUT tel_nrdconta,
                                          INPUT "",
                                          INPUT glb_cdcooper,
                                         OUTPUT aux_dscritic).
            
           IF  VALID-HANDLE(h-b1wgen9998) THEN
               DELETE OBJECT h-b1wgen9998.
            
           IF RETURN-VALUE <> "OK" THEN
              DO:
                  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                      HIDE MESSAGE NO-PAUSE.
                      MESSAGE aux_dscritic.
                      PAUSE 3 NO-MESSAGE.

                      DELETE PROCEDURE h-b1wgen0002.
                      DELETE PROCEDURE h-b1wgen0003.
                      DELETE PROCEDURE h-b1wgen0020.
                      DELETE PROCEDURE h-b1wgen0021.
                      DELETE PROCEDURE h-b1wgen0026.
                      DELETE PROCEDURE h-b1wgen0027.
                      DELETE PROCEDURE h-b1wgen0030.
                      DELETE PROCEDURE h-b1wgen0112.
                      DELETE PROCEDURE h-b1wgen0147.
                      HIDE FRAME f_moldura.
                      HIDE FRAME f_atenda.
                      RETURN.
                  END.

              END.

       END.
       ELSE
       DO:
           ASSIGN tel_nrdconta = glb_conta_script.
           DISPLAY tel_nrdconta WITH FRAME f_atenda.
       END.
       
       IF   tel_nrdconta = 0   THEN
            DO:
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                
                    UPDATE tel_nrdctitg WITH FRAME f_atenda.
               
                    LEAVE.
                    
                END.
                    
                IF  KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
                    NEXT.
                    
                DO WHILE LENGTH(tel_nrdctitg) < 8:
                    
                    tel_nrdctitg = "0" + tel_nrdctitg.
                
                END.

                IF  NOT VALID-HANDLE(h-b1wgen9998) THEN
                    RUN sistema/generico/procedures/b1wgen9998.p
                        PERSISTENT SET h-b1wgen9998.

                RUN valida_restricao_operador IN h-b1wgen9998
                                         (INPUT glb_cdoperad,
                                          INPUT 0,
                                          INPUT tel_nrdctitg,
                                          INPUT glb_cdcooper,
                                         OUTPUT aux_dscritic).
            
                IF  VALID-HANDLE(h-b1wgen9998) THEN
                    DELETE OBJECT h-b1wgen9998.
            
                IF RETURN-VALUE <> "OK" THEN
                   DO:
                      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                          HIDE MESSAGE NO-PAUSE.
                          MESSAGE aux_dscritic.
                          PAUSE 3 NO-MESSAGE.
    
                          DELETE PROCEDURE h-b1wgen0002.
                          DELETE PROCEDURE h-b1wgen0003.
                          DELETE PROCEDURE h-b1wgen0020.
                          DELETE PROCEDURE h-b1wgen0021.
                          DELETE PROCEDURE h-b1wgen0026.
                          DELETE PROCEDURE h-b1wgen0027.
                          DELETE PROCEDURE h-b1wgen0030.
                          DELETE PROCEDURE h-b1wgen0112.
                          DELETE PROCEDURE h-b1wgen0147.
                          HIDE FRAME f_moldura.
                          HIDE FRAME f_atenda.
                          RETURN.
                      END.
                  END.
            END.

            IF   NOT CAN-FIND(crapmfx WHERE crapmfx.cdcooper = glb_cdcooper   AND
                                       crapmfx.dtmvtolt = glb_dtmvtolt   AND
                                       crapmfx.tpmoefix = 2)  THEN
            DO:
                glb_cdcritic = 140.
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic + ": " + tel_dsmoefix.
                CLEAR FRAME f_atenda NO-PAUSE.
                DISPLAY tel_nrdconta WITH FRAME f_atenda.
                NEXT.
            END.
                             
       LEAVE.
    END.
      
                                                                  
    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
         DO:
             RUN fontes/novatela.p.
               
             IF   glb_nmdatela <> "ATENDA"   THEN
                  DO:
                      DELETE PROCEDURE h-b1wgen0002.
                      DELETE PROCEDURE h-b1wgen0003.
                      DELETE PROCEDURE h-b1wgen0020.
                      DELETE PROCEDURE h-b1wgen0021.
                      DELETE PROCEDURE h-b1wgen0026.
                      DELETE PROCEDURE h-b1wgen0027.
                      DELETE PROCEDURE h-b1wgen0030.
                      DELETE PROCEDURE h-b1wgen0112.
                      DELETE PROCEDURE h-b1wgen0147.
                      HIDE FRAME f_moldura.
                      HIDE FRAME f_atenda.
                      RETURN.
                  END.
             ELSE
                  NEXT.
         END.
        
    IF   tel_nrdconta = 0   AND   tel_nrdctitg <> ""   THEN
         DO:
             FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                crapass.nrdctitg = tel_nrdctitg 
                                USE-INDEX crapass7 NO-LOCK NO-ERROR.
        
             IF   AVAILABLE crapass   THEN
                  tel_nrdconta = crapass.nrdconta.
             ELSE
                  glb_cdcritic = 9.
         END.
                 
    ASSIGN glb_cddopcao = "@"
           glb_nmrotina = "".
    
    RUN p_acesso.
    
    IF   glb_cdcritic < 0   THEN
         NEXT.
    
    ASSIGN aux_nrdconta = tel_nrdconta
           glb_nrcalcul = tel_nrdconta
           glb_cdcritic = 0.
    
    RUN fontes/digfun.p.
    
    IF   NOT glb_stsnrcal   THEN
         DO:
             glb_cdcritic = 8.
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             CLEAR FRAME f_atenda NO-PAUSE.
             DISPLAY tel_nrdconta WITH FRAME f_atenda.
             NEXT.
         END.
    
    FIND FIRST crapdat WHERE crapdat.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapdat   THEN
         DO:
             DELETE PROCEDURE h-b1wgen0002.
             DELETE PROCEDURE h-b1wgen0003.
             DELETE PROCEDURE h-b1wgen0020.
             DELETE PROCEDURE h-b1wgen0021.
             DELETE PROCEDURE h-b1wgen0026.
             DELETE PROCEDURE h-b1wgen0027.
             DELETE PROCEDURE h-b1wgen0030.
             DELETE PROCEDURE h-b1wgen0112.
             DELETE PROCEDURE h-b1wgen0147.
             QUIT.
         END.
              
    IF   tel_nrdconta <> 0   THEN
         DO:                  
             FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                crapass.nrdconta = tel_nrdconta 
                                NO-LOCK NO-ERROR.
            
             IF   NOT AVAILABLE crapass   THEN
                  DO:                 
                      glb_cdcritic = 9.
                      RUN fontes/critic.p.
                      BELL.
                      MESSAGE glb_dscritic.
                      CLEAR FRAME f_atenda.
                      DISPLAY tel_nrdconta WITH FRAME f_atenda.
                      NEXT.
                  END.
         END.         

    ASSIGN aux_tplimcre = crapass.tplimcre
           aux_vllimcre = crapass.vllimcre
           tel_nmtitula = TRIM(crapass.nmprimtl) .
            
    IF   crapass.nrdctitg = ""   THEN
         tel_nrdctitg = "00000000".
    ELSE
         tel_nrdctitg = crapass.nrdctitg.
         
    IF   crapass.inpessoa = 1 THEN
         DO: 
             FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper AND
                                crapttl.nrdconta = tel_nrdconta AND
                                crapttl.idseqttl = 1
                                NO-LOCK NO-ERROR.
                      
             IF   AVAILABLE crapttl   THEN
                  DO:
                      IF   f_conectagener() THEN
                           DO:
                               RUN fontes/ver_natocp.p(INPUT  crapttl.cdnatopc,
                                                       OUTPUT tel_dsnatopc).
                               RUN p_desconectagener.
                           END.
                      ELSE
                           tel_dsnatopc = STRING(crapass.dsproftl,"x(20)").
                           
                      ASSIGN aux_cdempres = crapttl.cdempres.
                  END. 
         END.
    ELSE
         DO:
             FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper AND
                                crapjur.nrdconta = crapass.nrdconta
                                NO-LOCK NO-ERROR.             

             IF   AVAILABLE crapjur   THEN
                  DO:
                      IF  f_conectagener()   THEN
                          DO:
                              RUN fontes/ver_tipocp.p(INPUT crapjur.natjurid,
                                                      OUTPUT tel_dsnatopc).
                              
                              RUN p_desconectagener.
                          END.
                      ELSE
                           tel_dsnatopc = STRING(crapass.dsproftl,"x(20)").
                           
                      ASSIGN aux_cdempres = crapjur.cdempres.
                  END.            
         END.
    
    { includes/sititg.i }     

    { includes/listafun.i } 

    { includes/cpmf.i }
            
    /*  Tabela com a taxa do IOF */
  
    FIND craptab WHERE craptab.cdcooper = glb_cdcooper       AND
                       craptab.nmsistem = "CRED"             AND
                       craptab.tptabela = "USUARI"           AND
                       craptab.cdempres = 11                 AND
                       craptab.cdacesso = "CTRIOFEMPR"       AND
                       craptab.tpregist = 1
                       USE-INDEX craptab1 NO-LOCK NO-ERROR.
      
    ASSIGN aux_dtiniiof = DATE(INT(SUBSTRING(craptab.dstextab,4,2)),
                               INT(SUBSTRING(craptab.dstextab,1,2)),
                               INT(SUBSTRING(craptab.dstextab,7,4)))
           aux_dtfimiof = DATE(INT(SUBSTRING(craptab.dstextab,15,2)),
                               INT(SUBSTRING(craptab.dstextab,12,2)),
                               INT(SUBSTRING(craptab.dstextab,18,4)))
           aux_txiofepr = DECIMAL(SUBSTR(craptab.dstextab,23,16)).

    IF   glb_dtmvtolt < aux_dtiniiof OR
         glb_dtmvtolt > aux_dtfimiof THEN
         aux_txiofepr = 0.
    
    /* Calcula quantidade de folhas de talao de cheques */

    RUN fontes/qttalona.p (INPUT glb_dtmvtolt,
                           OUTPUT aux_qtfolhas,
                           OUTPUT tel_qttalret).
      
    /*  Calculo do saldo de capital e verifica se tem planos de cotas  */
    RUN exibe_capital (INPUT FALSE).
    
    IF  RETURN-VALUE = "NOK"  THEN
        NEXT.

    ASSIGN glb_cdcritic = 0
           glb_dscritic = "".

    /*  Calculo do saldo em depositos a vista  */
    RUN fontes/slddpv.p (INPUT FALSE).
               
    IF   glb_cdcritic > 0   THEN
         DO:
             glb_cdcritic = 0.
             NEXT.
         END.        

    /*  Totaliza saldo das aplicacoes  */
    RUN fontes/sldapl.p (INPUT FALSE).

    IF   glb_cdcritic > 0   THEN
         DO:
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             glb_cdcritic = 0.
             NEXT.
         END.
    
    /** Saldo das aplicacoes **/
    IF NOT VALID-HANDLE(h-b1wgen0081) THEN
        RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.
   
    IF  VALID-HANDLE(h-b1wgen0081)  THEN
        DO:
            ASSIGN aux_vlsldtot = 0.

            
            RUN obtem-dados-aplicacoes IN h-b1wgen0081
                                      (INPUT glb_cdcooper,
                                       INPUT glb_cdagenci,
                                       INPUT 1,
                                       INPUT 1,
                                       INPUT glb_nmdatela,
                                       INPUT 1,
                                       INPUT tel_nrdconta,
                                       INPUT 1,
                                       INPUT 0,
                                       INPUT glb_nmdatela,
                                       INPUT FALSE,
                                       INPUT ?,
                                       INPUT ?,
                                       OUTPUT aux_vlsldtot,
                                       OUTPUT TABLE tt-saldo-rdca,
                                       OUTPUT TABLE tt-erro).
        
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    IF VALID-HANDLE(h-b1wgen0081) THEN
                        DELETE OBJECT h-b1wgen0081.
                    
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                 
                    IF  AVAILABLE tt-erro  THEN
                        MESSAGE tt-erro.dscritic.
                    ELSE
                        MESSAGE "Erro nos dados das aplicacoes.".
        
                    NEXT.
                END.
              

            ASSIGN aux_vlsldapl = aux_vlsldtot.
            
            IF VALID-HANDLE(h-b1wgen0081) THEN
                DELETE OBJECT h-b1wgen0081.
        END.
             
        DO TRANSACTION ON ERROR UNDO, RETRY:
         /*Busca Saldo Novas Aplicacoes*/
         
         { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
          RUN STORED-PROCEDURE pc_busca_saldo_aplicacoes
            aux_handproc = PROC-HANDLE NO-ERROR
                                    (INPUT glb_cdcooper, /* Código da Cooperativa */
                                     INPUT '1',            /* Código do Operador */
                                     INPUT glb_nmdatela, /* Nome da Tela */
                                     INPUT 1,            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                     INPUT tel_nrdconta, /* Número da Conta */
                                     INPUT 1,            /* Titular da Conta */
                                     INPUT 0,            /* Número da Aplicação / Parâmetro Opcional */
                                     INPUT glb_dtmvtolt, /* Data de Movimento */
                                     INPUT 0,            /* Código do Produto */
                                     INPUT 1,            /* Identificador de Bloqueio de Resgate (1 – Todas / 2 – Bloqueadas / 3 – Desbloqueadas) */
                                     INPUT 0,            /* Identificador de Log (0 – Não / 1 – Sim) */
                                    OUTPUT 0,            /* Saldo Total da Aplicação */
                                    OUTPUT 0,            /* Saldo Total para Resgate */
                                    OUTPUT 0,            /* Código da crítica */
                                    OUTPUT "").          /* Descrição da crítica */
          
          CLOSE STORED-PROC pc_busca_saldo_aplicacoes
                aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
          
          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

          ASSIGN aux_cdcritic = 0
                 aux_dscritic = ""
                 aux_vlsldtot = 0
                 aux_vlsldrgt = 0
                 aux_cdcritic = pc_busca_saldo_aplicacoes.pr_cdcritic 
                                 WHEN pc_busca_saldo_aplicacoes.pr_cdcritic <> ?
                 aux_dscritic = pc_busca_saldo_aplicacoes.pr_dscritic
                                 WHEN pc_busca_saldo_aplicacoes.pr_dscritic <> ?
                 aux_vlsldtot = pc_busca_saldo_aplicacoes.pr_vlsldtot
                                 WHEN pc_busca_saldo_aplicacoes.pr_vlsldtot <> ?
                 aux_vlsldrgt = pc_busca_saldo_aplicacoes.pr_vlsldrgt
                                 WHEN pc_busca_saldo_aplicacoes.pr_vlsldrgt <> ?.

          IF aux_cdcritic <> 0   OR
             aux_dscritic <> ""  THEN
             DO:
                 IF aux_dscritic = "" THEN
                    DO:
                       FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                          NO-LOCK NO-ERROR.
        
                       IF AVAIL crapcri THEN
                          ASSIGN aux_dscritic = crapcri.dscritic.
        
                    END.
        
                 CREATE tt-erro.
        
                 ASSIGN tt-erro.cdcritic = aux_cdcritic
                        tt-erro.dscritic = aux_dscritic.
          
                 RETURN "NOK".
                                
             END.
                                              
         ASSIGN aux_vltotrda = aux_vlsldrgt + aux_vlsldapl.
     END.
     /*Fim Busca Saldo Novas Aplicacoes*/

    /*  Totaliza saldo de emprestimos  */
    RUN fontes/sldepr.p (INPUT FALSE, 0).

    IF   glb_cdcritic > 0   OR
         glb_dscritic <> "" THEN
         DO:
             IF glb_cdcritic > 0 THEN
             RUN fontes/critic.p.

             BELL.
             MESSAGE glb_dscritic.
             glb_cdcritic = 0.
             NEXT.
         END. 

    /*  Totaliza saldo de poupanca programada  */
    
    RUN fontes/sldrpp.p (INPUT FALSE).

    IF   glb_cdcritic > 0   THEN
         DO:
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             glb_cdcritic = 0.
             NEXT.
         END.

    /*  Totaliza as prestacoes de seguro  */
  
    RUN fontes/sldseg.p (INPUT FALSE).
 
    IF   glb_cdcritic > 0   THEN
         DO:
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             glb_cdcritic = 0.
             NEXT.
         END.

    /* Totaliza os limites de cartao de credito */
 
    RUN fontes/sldccr.p (INPUT FALSE).

    IF   glb_cdcritic > 0   THEN
         DO:
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             glb_cdcritic = 0.
             NEXT.
         END.
         
   /*  Totaliza a quantidade de contra ordens  */
    RUN fontes/sldcor.p (INPUT FALSE).

    IF   glb_cdcritic > 0   THEN
         DO:
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             glb_cdcritic = 0.
             NEXT.
         END.

    /** Dados para a tela OCORRENCIAS **/
    ASSIGN tel_flgexoco  = ""
           aux_nrctatos = 0
           aux_vltotpre = 0
           aux_vltotemp = 0
           aux_vlparepr = 0
           aux_vlsaldod = 0.

           RUN exibe_ocorrencias.

    IF  RETURN-VALUE = "NOK"  THEN
        NEXT.
    
    /* busca informacoes de emprestimo e prestacoes (para nao utilizar
       mais a include "gera workepr.i") - sidnei */
    RUN saldo-devedor-epr IN h-b1wgen0002
                                   (INPUT glb_cdcooper,
                                    INPUT 0,             /* p-cod-agencia */
                                    INPUT 0,             /* p-nro-caixa   */
                                    INPUT glb_cdoperad,
                                    INPUT "ATENDA",
                                    INPUT 1,             /* Ayllos        */
                                    INPUT tel_nrdconta,
                                    INPUT 1,             /* par_idseqttl  */
                                    INPUT glb_dtmvtolt,
                                    INPUT glb_dtmvtopr,
                                    INPUT 0,             /* Contrato      */
                                    INPUT "ATENDA",
                                    INPUT glb_inproces,
                                    INPUT FALSE,         /* Nao Logar     */
                                   OUTPUT aux_vltotemp,  /* Tot Empestimo */
                                   OUTPUT aux_vltotpre,  /* Val Prestacao */
                                   OUTPUT aux_qtprecal,
                                   OUTPUT TABLE tt-erro).

           
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                     
            IF  AVAILABLE tt-erro  THEN
                ASSIGN glb_dscritic = tt-erro.dscritic.
            ELSE
                ASSIGN glb_dscritic = "Erro no carregamento de emprestimos.".

            BELL.
            MESSAGE glb_dscritic.
            
            NEXT.
        END.    
        
    /* Informacoes de emprestimo BNDES */
    RUN dados_bndes IN h-b1wgen0147
                   (INPUT glb_cdcooper,
                    INPUT tel_nrdconta,
                    OUTPUT aux_vlparepr, /*prestacao*/
                    OUTPUT aux_vlsaldod, /*total emprestimo*/
                    OUTPUT TABLE tt-saldo-devedor-bndes).

    IF  RETURN-VALUE <> "OK" THEN
        NEXT.

    /* adiciona valores bndes para emprestimo e prestacao */
    ASSIGN aux_vltotpre = aux_vltotpre + aux_vlparepr
           aux_vltotemp = aux_vltotemp + aux_vlsaldod. 

    /*  Totaliza a quantidade de cartoes magneticos de C/C  */
    RUN fontes/carmag.p (INPUT tel_nrdconta, 
                         INPUT crapass.inpessoa, /* inpessoa */
                         INPUT FALSE).

    IF   glb_cdcritic > 0   THEN
         DO:
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             glb_cdcritic = 0.
             NEXT.
         END.

    /*  Mostra lancamentos da LAUTOM - Buscar da BO 003 (Sidnei) */
    RUN consulta-lancamento IN h-b1wgen0003 (INPUT glb_cdcooper,
                                             INPUT 0,       /* p-cod-agencia */
                                             INPUT 0,       /* p-nro-caixa   */
                                             INPUT glb_cdoperad,
                                             INPUT tel_nrdconta,
                                             INPUT 1,       /* Ayllos        */
                                             INPUT 1,       /* par_idseqttl  */
                                             INPUT "ATENDA",
                                             INPUT FALSE,   /* Nao Logar     */
                                            OUTPUT TABLE tt-totais-futuros,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT TABLE tt-lancamento_futuro).
                                    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-erro  THEN
                ASSIGN glb_dscritic = tt-erro.dscritic.
            ELSE
                ASSIGN glb_dscritic = "Erro no carregamento de lancamentos " +
                                      "futuros.".
                                      
            BELL.
            MESSAGE glb_dscritic.
            
            NEXT.
        END.

    FIND FIRST tt-totais-futuros NO-LOCK NO-ERROR.

    IF  AVAILABLE tt-totais-futuros  THEN
        ASSIGN aux_vllautom = tel_vlstotal + tt-totais-futuros.vllautom.

    /*  Totaliza o montante de descontos em cheque e titulos e no geral  */
    ASSIGN aux_vltotdsc = 0
           aux_qttotdsc = 0
           aux_vldsctit = 0
           aux_qtdsctit = 0
           aux_vldscchq = 0
           aux_qtdscchq = 0.
    
    /* Valor total de Descontos */
    RUN busca_total_descontos IN h-b1wgen0030 (INPUT glb_cdcooper,
                                               INPUT 0,     /** agencia  **/
                                               INPUT 0,     /** caixa    **/
                                               INPUT glb_cdoperad,
                                               INPUT glb_dtmvtolt,
                                               INPUT tel_nrdconta,
                                               INPUT 1,     /** idseqttl **/
                                               INPUT 1,     /** origem   **/
                                               INPUT "ATENDA",
                                               INPUT FALSE, /** log      **/
                                              OUTPUT TABLE tt-tot_descontos).

    FIND FIRST tt-tot_descontos NO-LOCK NO-ERROR.

    IF  AVAILABLE tt-tot_descontos  THEN
        ASSIGN aux_vltotdsc = tt-tot_descontos.vltotdsc
               aux_qttotdsc = tt-tot_descontos.qttotdsc
               aux_vldsctit = tt-tot_descontos.vldsctit
               aux_qtdsctit = tt-tot_descontos.qtdsctit
               aux_vldscchq = tt-tot_descontos.vldscchq
               aux_qtdscchq = tt-tot_descontos.qtdscchq.

    /*** Situacao de acesso a conta via internet ***/
    IF crapass.idastcjt = 0 THEN DO:
        FIND crapsnh WHERE crapsnh.cdcooper = glb_cdcooper   AND
                           crapsnh.nrdconta = tel_nrdconta   AND
                           crapsnh.tpdsenha = 1 /*Internet*/ AND
                           crapsnh.idseqttl = 1 /*1o TIT*/   NO-LOCK NO-ERROR.
                           
        IF   AVAILABLE crapsnh   THEN
             DO:
                 IF   crapsnh.cdsitsnh = 0   THEN
                      aux_inhabweb = "      Inativa".
                 ELSE
                 IF   crapsnh.cdsitsnh = 1   THEN
                      aux_inhabweb = "        Ativa".
                 ELSE
                 IF   crapsnh.cdsitsnh = 2   THEN
                      aux_inhabweb = "    Bloqueada".
                 ELSE
                 IF   crapsnh.cdsitsnh = 3   THEN
                      aux_inhabweb = "    Cancelada".
             END.
        ELSE
             aux_inhabweb = "      Inativa".
    END.
    ELSE
    DO:
        aux_inhabweb = "      Inativa".
        FOR EACH crappod WHERE crappod.cdcooper = glb_cdcooper AND
                               crappod.nrdconta = tel_nrdconta AND
                               crappod.cddpoder = 10           AND
                               crappod.flgconju = TRUE         NO-LOCK:
            aux_inhabweb = "        Ativa".
            FOR FIRST crapsnh WHERE crapsnh.cdcooper = crappod.cdcooper AND
                                    crapsnh.nrdconta = crappod.nrdconta AND
                                    crapsnh.tpdsenha = 1                AND
                                    crapsnh.nrcpfcgc = crappod.nrcpfpro NO-LOCK: END.
            IF NOT AVAIL crapsnh OR crapsnh.cdsitsnh = 0 THEN DO:
                aux_inhabweb = "      Inativa".
                LEAVE.
            END.
            IF crapsnh.cdsitsnh = 2 THEN DO:
                aux_inhabweb = "    Bloqueada".
                LEAVE.
            END.
            IF crapsnh.cdsitsnh = 3 THEN DO:
                aux_inhabweb = "    Cancelada".
                LEAVE.
            END.
        END.
    END.
    
    /*** Verifica se usuario esta cadastrado na URA ***/
    FIND crapsnh WHERE crapsnh.cdcooper = glb_cdcooper   AND
                       crapsnh.nrdconta = tel_nrdconta   AND
                       crapsnh.tpdsenha = 2 /* ura */    AND
                       crapsnh.idseqttl = 0
                       NO-LOCK NO-ERROR.
                
    IF   NOT AVAILABLE crapsnh  THEN
         ASSIGN tel_flgcdura = "Inativa".
    ELSE
    IF   crapsnh.cdsitsnh = 1   THEN
         ASSIGN tel_flgcdura = "  Ativa".
    ELSE
         ASSIGN tel_flgcdura = "Inativa".

    /* para pegar o valor do saldo conta investimento */
    RUN exibe_conta_investimento (INPUT FALSE).
        
    IF  RETURN-VALUE = "NOK"  THEN
        NEXT.
        
    /* Pega os convenio ativos */
    aux_qtconven = 0.
    FOR EACH crapatr WHERE crapatr.cdcooper = glb_cdcooper   AND
                           crapatr.nrdconta = tel_nrdconta   AND
                           crapatr.dtfimatr = ?              NO-LOCK:
        aux_qtconven = aux_qtconven + 1.
    END.                           

    /* Retorna se o Cooperado possui cadastro de emissao bloqueto ativo*/
    RUN sistema/generico/procedures/b1wgen0082.p PERSISTENT SET h-b1wgen0082.

    aux_flgbloqt = DYNAMIC-FUNCTION ("verifica-cadastro-ativo" IN h-b1wgen0082,
                       
                        INPUT glb_cdcooper,
                        INPUT tel_nrdconta).

    DELETE PROCEDURE h-b1wgen0082.    

    /* Verifica se cooperado possui consorcio ativo */
    IF NOT VALID-HANDLE(h-b1wgen0162) THEN
        RUN sistema/generico/procedures/b1wgen0162.p PERSISTENT SET h-b1wgen0162.

    RUN indicativo_consorcio IN h-b1wgen0162 (INPUT glb_cdcooper, 
                                              INPUT tel_nrdconta,
                                              OUTPUT aux_flgconso).
    
    IF VALID-HANDLE(h-b1wgen0162) THEN
        DELETE OBJECT h-b1wgen0162.
    
    /* FIM. cooperado possui consorcio ativo? */

    /*  Monta descricao do menu de opcoes  */
    ASSIGN tel_dsdopcao[01] = "    CAPITAL:" +
                              STRING(tel_vlcaptal,"zzz,zzz,zz9.99-")

           tel_dsdopcao[02] = "EMPRESTIMOS:" +
                              STRING(aux_vltotemp,"zzz,zzz,zz9.99-")

           tel_dsdopcao[03] = " PRESTACOES:" +
                              STRING(aux_vltotpre,"zzz,zzz,zz9.99-")

           tel_dsdopcao[04] = " DEP. VISTA:" +
                              STRING(tel_vlstotal,"zzz,zzz,zz9.99-")

           tel_dsdopcao[05] =  IF   crapass.inpessoa = 1 THEN /*Pessoa Fisica*/
                                    "LIMITE CRED: " + 
                                    STRING(aux_vllimcre,"zz,zzz,zz9.99")
                               ELSE
                                    " LIMITE EMP: " + 
                                    STRING(aux_vllimcre,"zz,zzz,zz9.99")

           tel_dsdopcao[06] = " APLICACOES:" +
                              STRING(aux_vltotrda,"zzz,zzz,zz9.99-")

           tel_dsdopcao[07] = " POUP. PROG:" +
                              STRING(aux_vltotrpp,"zzz,zzz,zz9.99-")

           tel_dsdopcao[11] = "     SEGURO:" +
                              STRING(aux_vltotseg,"zzzzzz,zz9.99")

           tel_dsdopcao[10] = "CARTAO CRED:" +
                              STRING(aux_vltotccr,"zzzzzz,zz9.99")

           tel_dsdopcao[16] = "   INTERNET:" + aux_inhabweb 
 
           tel_dsdopcao[12] = "     LAUTOM:" +
                              STRING(aux_vllautom,"zz,zzz,zz9.99-")

           tel_dsdopcao[13] = "  MAGNETICO:" +
                              STRING(aux_qtcarmag,"      zzz,zz9")
                              
           tel_dsdopcao[14] = "FOLHAS CHEQ:" +
                              STRING(aux_qtfolhas,"      zzz,zz9")

           tel_dsdopcao[15] = "OCORRENCIAS:          " + tel_flgexoco

           tel_dsdopcao[9]  = "  DESCONTOS:" +
                              STRING(aux_vltotdsc,"zzzzzz,zz9.99-")
           
           tel_dsdopcao[8] = "  CONTA INV:" + 
                              STRING(aux_saldo_ci,"zzz,zzz,zz9.99-")
                              
           tel_dsdopcao[17] = " TELE ATEN:     " + tel_flgcdura   
           
           tel_dsdopcao[18] = " CONVENIOS:       " + 
                              STRING(aux_qtconven,"z,zz9")

           tel_dsdopcao[19] = "RELACION:" 

           tel_dsdopcao[20] = "COBRANCA:         " + 
                              STRING(aux_flgbloqt,"SIM/NAO")

           tel_dsdopcao[21] = "TELEFONE:"       
           
           tel_dsdopcao[22] = "CONSORCIO:         " + 
                              STRING(aux_flgconso,"SIM/NAO")

           tel_vledvmto     = crapass.vledvmto.

    ASSIGN aux_messalarial = MONTH(crapass.dtedvmto)
           aux_anosalarial = YEAR(crapass.dtedvmto).
                    
    IF   crapass.cdtipcta > 0   THEN
         DO:
            
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
             RUN STORED-PROCEDURE pc_descricao_tipo_conta
               aux_handproc = PROC-HANDLE NO-ERROR
                                       (INPUT crapass.inpessoa, /* Tipo de pessoa */
                                        INPUT crapass.cdtipcta, /* Tipo de conta */
                                       OUTPUT "",               /* Descrição do Tipo de conta */
                                       OUTPUT "",               /* Flag Erro */
                                       OUTPUT "").              /* Descrição da crítica */
             
             CLOSE STORED-PROC pc_descricao_tipo_conta
                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
             
             { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
     
             ASSIGN aux_dstipcta = ""
                    aux_des_erro = ""
                    aux_dscritic = ""
                    aux_dstipcta = pc_descricao_tipo_conta.pr_dstipo_conta 
                                    WHEN pc_descricao_tipo_conta.pr_dstipo_conta <> ?
                    aux_des_erro = pc_descricao_tipo_conta.pr_des_erro 
                                    WHEN pc_descricao_tipo_conta.pr_des_erro <> ?
                    aux_dscritic = pc_descricao_tipo_conta.pr_dscritic
                                    WHEN pc_descricao_tipo_conta.pr_dscritic <> ?.
     
             IF aux_des_erro = "NOK"  THEN
                DO:
                    glb_dscritic = aux_dscritic.
                    BELL.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                    NEXT.
                END.
             
             ASSIGN tel_dstipcta = STRING(crapass.cdtipcta,"z9") + " - " + aux_dstipcta.
             
         END.
    ELSE
         tel_dstipcta = STRING(crapass.cdtipcta,"z9").

    IF   crapass.inpessoa = 1 THEN
         ASSIGN tel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                tel_nrcpfcgc = STRING(tel_nrcpfcgc,"xxx.xxx.xxx-xx").
    ELSE
         ASSIGN tel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                tel_nrcpfcgc = STRING(tel_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").
  
    ASSIGN aux_qttitula = 0
           tel_nrramfon = "".

    IF  crapass.inpessoa = 1  THEN
        DO:
            ASSIGN aux_tptelefo = "1,2,3,4".

            FOR EACH crabttl WHERE crabttl.cdcooper = glb_cdcooper AND
                                   crabttl.nrdconta = tel_nrdconta NO-LOCK:
                ASSIGN aux_qttitula = aux_qttitula + 1.
            END.
        END.
    ELSE
        ASSIGN aux_tptelefo = "3,2,1,4"
               aux_qttitula = 1.

    

    TITULARES:
    DO aux_conttitu = 1 TO aux_qttitula:
    
        /*** Se pessoa fisica :  Residencial/Celular/Comercial/Contato ***/
        /*** Se pessoa juridica: Comercial/Celular/Residencial/Contato ***/
        TIPO:
        DO aux_contador = 1 TO 4: 

            FIND FIRST craptfc WHERE 
                       craptfc.cdcooper = glb_cdcooper       AND
                       craptfc.nrdconta = crapass.nrdconta   AND
                       craptfc.idseqttl = aux_conttitu       AND
                       craptfc.tptelefo = INTE(ENTRY(aux_contador,aux_tptelefo))  
                       NO-LOCK NO-ERROR.
            
             IF  AVAIL craptfc   THEN
                DO:
                   IF  craptfc.nrdddtfc <> 0  THEN
                       tel_nrramfon = "(" + STRING(craptfc.nrdddtfc) + ")".
                                      
                    ASSIGN tel_nrramfon = tel_nrramfon + STRING(craptfc.nrtelefo).
            
                    LEAVE TITULARES.

                END.
            
    

        END. /** Fim do DO ... TO - TIPO **/

    END. /** Fim do DO ... TO - TITULARES **/
    
   /* IF  tel_nrramfon = ""  THEN
        ASSIGN tel_nrramfon = STRING (craptfc.nrtelefo) .  dani*/

        
    tel_dssitdct = STRING(crapass.cdsitdct,"9") + " " +
                   IF crapass.cdsitdct = 1
                   THEN "NORMAL"
                   ELSE IF crapass.cdsitdct = 2
                        THEN "ENCERRADA P/ASSOCIADO"
                        ELSE IF crapass.cdsitdct = 3
                             THEN "ENCERRADA P/COOP"
                             ELSE IF crapass.cdsitdct = 4
                                  THEN "ENCERRADA P/DEMISSAO"
                                  ELSE IF crapass.cdsitdct = 5
                                       THEN "NAO APROVADA"
                                       ELSE
                                            IF crapass.cdsitdct = 6 
                                            THEN "NORMAL - SEM TALAO"
                                            ELSE
                                                IF crapass.cdsitdct = 9
                                                THEN "ENCERRADA P/OUTRO MOTIVO"
                                                ELSE "".

    /**** Magui passa para o item OCORRENCIAS  ****/
    /* Procurar registro de devolucoes de cheques */
    
    ASSIGN tel_qtdevolu = 0.
    FOR EACH crapneg WHERE crapneg.cdcooper = glb_cdcooper             AND
                           crapneg.nrdconta = tel_nrdconta             AND
                           crapneg.cdhisest = 1                        AND
                           CAN-DO("11,12,13",STRING(crapneg.cdobserv))
                           NO-LOCK USE-INDEX crapneg2:

        ASSIGN tel_qtdevolu = tel_qtdevolu + 1.
    END.
    
    /* Procura registro de recadastramento */

    FIND LAST crapalt WHERE crapalt.cdcooper = glb_cdcooper     AND
                            crapalt.nrdconta = crapass.nrdconta AND
                            crapalt.tpaltera = 1 NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE (crapalt) THEN
        tel_dtaltera = ?.
    ELSE
        tel_dtaltera = crapalt.dtaltera.
         
    ASSIGN aux_dtabtcc2 = ?.

    /* Data de abertura da conta mais antiga */
    FOR EACH crapsfn WHERE  crapsfn.cdcooper = glb_cdcooper     AND
                            crapsfn.nrcpfcgc = crapass.nrcpfcgc AND
                            crapsfn.tpregist = 1                NO-LOCK 
                            BY  crapsfn.dtabtcct DESCENDING:
    
        ASSIGN aux_dtabtcc2 = crapsfn.dtabtcct.
                            
    END.
    
    IF  aux_dtabtcc2 <> ? THEN
        aux_dtabtcct = STRING(DAY(aux_dtabtcc2),"99")   +
                       STRING(MONTH(aux_dtabtcc2),"99") +
                       STRING(YEAR(aux_dtabtcc2),"9999").
    ELSE
        aux_dtabtcct = "".
    
     
    /* Procura registro total de dias com conta devedora */ 
    FIND crapsld WHERE crapsld.cdcooper = glb_cdcooper AND
                       crapsld.nrdconta = tel_nrdconta
                       NO-LOCK NO-ERROR.
                       
    IF  AVAILABLE crapsld  THEN
        ASSIGN tel_qtddtdev = crapsld.qtddtdev
               tel_qtddsdev = crapsld.qtddsdev.
    ELSE
        ASSIGN tel_qtddtdev = 0
               tel_qtddsdev = 0.

    ASSIGN tel_dsnatura = IF  crapass.inpessoa = 1  AND 
                              AVAIL crapttl         THEN 
                              crapttl.dsnatura 
                          ELSE 
                              "".

    DISPLAY tel_nrdconta      crapass.nrmatric  crapass.cdagenci
            crapass.dtadmiss  crapass.indnivel  tel_nmtitula
            tel_dsnatopc      tel_nrramfon      tel_nrcpfcgc      
            tel_dstipcta      tel_dssitdct      aux_cdempres
            crapass.cdtipsfx  crapass.dtdemiss  tel_qtddtdev 
            tel_dtaltera      tel_qtdevolu
            tel_vlprepla      tel_dsdopcao
            tel_qtddsdev      crapass.cdsecext
            crapass.dtadmemp  tel_qttalret      tel_dsnatura
            "" WHEN NOT AVAIL crapttl @ crapttl.cdturnos
            crapttl.cdturnos WHEN AVAILABLE crapttl
            tel_nrdctitg 
            crapass.nrctainv
            aux_dtabtcct
            tel_dssititg WITH FRAME f_atenda.

    ASSIGN glb_cdcritic = 0.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
        /* Verifica se ha mensagens prioritarias. Nao exibir quando 
           atenda executado em background para validacao de tempos */
        IF (glb_conta_script = 0) THEN
        DO:                       
            /*Alteraçao: uso da BO 31 (Gabriel, DB1)*/
            RUN obtem-mensagens-alerta.

            IF  RETURN-VALUE <> "OK" THEN
                LEAVE.
                                      
            FIND FIRST crapobs WHERE crapobs.cdcooper = glb_cdcooper AND
                                     crapobs.nrdconta = tel_nrdconta 
                                     NO-LOCK NO-ERROR.

            IF  AVAILABLE crapobs  THEN
            DO:
                HIDE FRAME f_atenda NO-PAUSE.
             
                ASSIGN aux_flgsair = FALSE.
                
                RUN fontes/ver_anota.p (tel_nrdconta).

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                    ASSIGN aux_flgsair = TRUE.
                
                VIEW FRAME f_atenda.

                ASSIGN glb_cdcritic = 0.
            END.
        END.
        
        LEAVE.
        
    END. /** Fim do DO WHILE TRUE **/    
    
    IF  aux_flgsair  THEN
        .
    ELSE
    IF  glb_cdcritic > 0 OR KEY-FUNCTION(LASTKEY) = "END-ERROR"  OR
        aux_flgsair THEN
        DO:
            ASSIGN aux_flgsair = FALSE.
            NEXT.
        END.    

    /* Para Atenda executado em background para levantamento de tempos */
    IF (glb_conta_script <> 0) THEN
       LEAVE.
    
    /*  Pede a opcao desejada  */
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       glb_nmrotina = "".
       
       DISPLAY tel_dsdopcao WITH FRAME f_atenda.

       CHOOSE FIELD tel_dsdopcao
              HELP "Tecle <Entra> para maiores detalhes ou <Fim> para voltar."
              PAUSE 60 WITH FRAME f_atenda.

       IF   LASTKEY = -1   THEN
            LEAVE.

       HIDE MESSAGE NO-PAUSE.
                                       
       IF   FRAME-VALUE = tel_dsdopcao[1]   THEN
            DO:
                ASSIGN glb_cddopcao = "@"           
                       glb_nmrotina = "CAPITAL".
                       
                RUN p_acesso.
                
                IF   glb_cdcritic < 0 THEN
                     NEXT.
                
                IF   glb_inproces >= 3   THEN
                     DO:
                        glb_cdcritic = 138. 
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.

                HIDE MESSAGE NO-PAUSE.
                
                RUN exibe_capital (INPUT TRUE).

                IF  RETURN-VALUE = "NOK"  THEN
                    NEXT.
            END.
       ELSE
       IF   FRAME-VALUE = tel_dsdopcao[2]   THEN
            DO:           
                ASSIGN glb_cddopcao = "@"
                       glb_nmrotina = "EMPRESTIMOS".

                RUN p_acesso.
                
                IF   glb_cdcritic < 0   THEN
                     NEXT.
                
                
                RUN fontes/proepr.p (INPUT tel_nrdconta,
                                     INPUT aux_vltotemp).

                IF   glb_cdcritic > 0   THEN
                     DO:
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         glb_cdcritic = 0.
                         NEXT.
                     END.
                         
            END.
       ELSE
       IF   FRAME-VALUE = tel_dsdopcao[3]   THEN
            DO:
                ASSIGN glb_cddopcao = "@"
                       glb_nmrotina = "PRESTACOES".

                RUN p_acesso.
                
                IF   glb_cdcritic < 0   THEN
                     NEXT.

                DISP tel_cooperat tel_bndes WITH FRAME f_bndes_1.

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    CHOOSE FIELD tel_cooperat tel_bndes
                    HELP "Informacoes de emprestimos BNDES."
                    PAUSE 60 WITH FRAME f_bndes_1.

                    LEAVE.
                END.

                IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                    NEXT.

                IF FRAME-VALUE = tel_bndes THEN
                   RUN fontes/sldbndes.p.
                ELSE
                   RUN fontes/sldepr.p (INPUT TRUE, 0).

                HIDE FRAME f_bndes_1.

                IF   glb_cdcritic > 0   THEN
                     DO:
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         glb_cdcritic = 0.
                         NEXT.
                     END.
            END.
       ELSE
       IF   FRAME-VALUE = tel_dsdopcao[4]   THEN
            DO:
                ASSIGN glb_cddopcao = "@"
                       glb_nmrotina = "DEP. VISTA".
                
                RUN p_acesso.
                
                IF   glb_cdcritic < 0   THEN
                     NEXT.
 
                IF   glb_inproces >= 3   THEN
                     DO:
                        glb_cdcritic = 138. 
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.
                
                RUN fontes/depvista.p (INPUT tel_nrdconta).
            END.
       ELSE
       IF   FRAME-VALUE = tel_dsdopcao[5]   THEN
            DO:
                ASSIGN glb_cddopcao = "@"
                       glb_nmrotina = "LIMITE CRED".
                
                RUN p_acesso.
                
                IF   glb_cdcritic < 0   THEN
                     NEXT.

                IF   glb_inproces >= 3   THEN
                     DO:
                        glb_cdcritic = 138. 
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.

                RUN fontes/limite.p.
               
                IF   crapass.inpessoa = 1 THEN  /*  Pessoa Fisica  */
                     tel_dsdopcao[5] = "LIMITE CRED: " + 
                                       STRING(aux_vllimcre,"zz,zzz,zz9.99").
                ELSE
                     tel_dsdopcao[5] = " LIMITE EMP: " + 
                                       STRING(aux_vllimcre,"zz,zzz,zz9.99").
                            
                DISPLAY tel_dsdopcao[5] WITH FRAME f_atenda.
              
                DISPLAY tel_dstipcta  WITH FRAME f_atenda.
                               
            END.
       ELSE
       IF   FRAME-VALUE = tel_dsdopcao[6]   THEN
            DO:
                
                ASSIGN glb_cddopcao = "@"
                       glb_nmrotina = "APLICACOES".
                
                RUN p_acesso.
                
                IF   glb_cdcritic < 0   THEN
                     NEXT.

                 
                IF   glb_inproces >= 3   THEN
                     DO:
                        glb_cdcritic = 138. 
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.
                
                /* Guilherme - 17/12
                /07 */

                RUN fontes/rdcaresg.p.
                DISPLAY tel_dsdopcao[04]
                        tel_dsdopcao[06]
                        WITH FRAME f_atenda.

                IF   glb_cdcritic > 0   THEN
                     DO:
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.

                         glb_cdcritic = 0.
                         NEXT.
                     END.
                     
                /* atualizacao do campo Conta Investimento */     
                /* para pegar o valor do saldo conta investimento */
                ASSIGN aux_saldo_ci = 0.
                FIND crapsli WHERE crapsli.cdcooper  = glb_cdcooper         AND
                                   crapsli.nrdconta  = crapass.nrdconta     AND
                             MONTH(crapsli.dtrefere) = MONTH(glb_dtmvtolt)  AND
                              YEAR(crapsli.dtrefere) = YEAR(glb_dtmvtolt)
                                   NO-LOCK NO-ERROR.
                                   
                IF  AVAIL crapsli THEN
                    ASSIGN aux_saldo_ci = crapsli.vlsddisp.
        
                tel_dsdopcao[8] = "  CONTA INV:" + 
                              STRING(aux_saldo_ci,"zzz,zzz,zz9.99-").
                
                DISPLAY tel_dsdopcao[8] WITH FRAME f_atenda.
            END.
       ELSE
       IF   FRAME-VALUE = tel_dsdopcao[7]   THEN
            DO:
                ASSIGN glb_cddopcao = "@"
                       glb_nmrotina = "POUP. PROG".
                
                RUN p_acesso.
                
                IF   glb_cdcritic < 0   THEN
                     NEXT.
                 
                IF   glb_inproces >= 3   THEN
                     DO:
                        glb_cdcritic = 138. 
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.
                                
                IF   aux_vltotrpp >= 0    THEN
                     RUN fontes/sldrpp.p (INPUT TRUE).
                ELSE
                     glb_cdcritic = 345.

                IF   glb_cdcritic > 0   THEN
                     DO:
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.

                         glb_cdcritic = 0.
                         NEXT.
                     END.
            END.
       ELSE
       IF   FRAME-VALUE = tel_dsdopcao[11]   THEN
            DO:
                ASSIGN glb_cddopcao = "@"
                       glb_nmrotina = "SEGURO".
                
                RUN p_acesso.
                
                IF   glb_cdcritic < 0   THEN
                     NEXT.
                 
                IF   glb_inproces >= 3   THEN
                     DO:
                        glb_cdcritic = 138. 
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.
                
                IF   aux_qtsegass >= 0    THEN
                     DO:
                          RUN fontes/sldseg.p (INPUT TRUE).
                          tel_dsdopcao[11] = "     SEGURO:" +
                                STRING(aux_vltotseg,"zzzzzz,zz9.99").
                          DISPLAY tel_dsdopcao[11] WITH FRAME f_atenda.
                     END.
                ELSE
                     glb_cdcritic = 523.

                IF   glb_cdcritic > 0   THEN
                     DO:
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.

                         glb_cdcritic = 0.
                         NEXT.
                     END.
            END.
       ELSE
       IF   FRAME-VALUE = tel_dsdopcao[10]    THEN
            DO:
                ASSIGN glb_cddopcao = "@"
                       glb_nmrotina = "CARTAO CRED".
                
                RUN p_acesso.
                
                IF   glb_cdcritic < 0   THEN
                     NEXT.

                IF   glb_inproces >= 3   THEN
                     DO:
                        glb_cdcritic = 138. 
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.
                
                RUN fontes/sldccr.p (INPUT TRUE).

                tel_dsdopcao[10] = "CARTAO CRED:" +
                                   STRING(aux_vltotccr,"zzzzzz,zz9.99").

                DISPLAY tel_dsdopcao[10] WITH FRAME f_atenda.
            END.
       ELSE
       IF   FRAME-VALUE = tel_dsdopcao[16]   THEN
            DO:
                ASSIGN glb_cddopcao = "@"
                       glb_nmrotina = "INTERNET".
                
                RUN p_acesso.
                
                IF   glb_cdcritic < 0   THEN
                     NEXT.
                
                IF   glb_inproces >= 3   THEN
                     DO:
                        glb_cdcritic = 138. 
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.

                RUN fontes/internet.p.
                
                /*** Situacao de acesso a conta via internet ***/
                IF crapass.idastcjt = 0 THEN DO:
                    FIND crapsnh WHERE crapsnh.cdcooper = glb_cdcooper   AND
                                       crapsnh.nrdconta = tel_nrdconta   AND
                                       crapsnh.tpdsenha = 1 /*Internet*/ AND
                                       crapsnh.idseqttl = 1 /*1o TIT*/   
                                       NO-LOCK NO-ERROR.
                           
                    IF   AVAILABLE crapsnh   THEN
                         DO:
                             IF   crapsnh.cdsitsnh = 0   THEN
                                  aux_inhabweb = "      Inativa".
                             ELSE
                             IF   crapsnh.cdsitsnh = 1   THEN
                                  aux_inhabweb = "        Ativa".
                             ELSE
                             IF   crapsnh.cdsitsnh = 2   THEN
                                  aux_inhabweb = "    Bloqueada".
                             ELSE
                             IF   crapsnh.cdsitsnh = 3   THEN
                                  aux_inhabweb = "    Cancelada".
                         END.
                    ELSE
                         aux_inhabweb = "      Inativa".
                END.
                ELSE
                DO:
                    aux_inhabweb = "      Inativa".
                    FOR EACH crappod WHERE crappod.cdcooper = glb_cdcooper AND
                                          crappod.nrdconta = tel_nrdconta AND
                                          crappod.cddpoder = 10           AND
                                          crappod.flgconju = TRUE         NO-LOCK:
                      aux_inhabweb = "        Ativa".
                      FOR FIRST crapsnh WHERE crapsnh.cdcooper = crappod.cdcooper AND
                                              crapsnh.nrdconta = crappod.nrdconta AND
                                              crapsnh.tpdsenha = 1                AND
                                              crapsnh.nrcpfcgc = crappod.nrcpfpro NO-LOCK: END.
                      IF NOT AVAIL crapsnh OR crapsnh.cdsitsnh = 0 THEN DO:
                         aux_inhabweb = "      Inativa".
                         LEAVE.
                      END.
                      IF crapsnh.cdsitsnh = 2 THEN DO:
                         aux_inhabweb = "    Bloqueada".
                         LEAVE.
                      END.
                      IF crapsnh.cdsitsnh = 3 THEN DO:
                         aux_inhabweb = "    Cancelada".
                         LEAVE.
                      END.
                    END.
                END.
                
                tel_dsdopcao[16] = "   INTERNET:" + aux_inhabweb.
                            
                DISPLAY tel_dsdopcao[16] WITH FRAME f_atenda.
              
            END.
       ELSE 
       IF   FRAME-VALUE = tel_dsdopcao[12]    THEN
            DO:
                ASSIGN glb_cddopcao = "@"
                       glb_nmrotina = "LAUTOM".
                
                RUN p_acesso.
                
                IF   glb_cdcritic < 0   THEN
                     NEXT.

                 
                IF   glb_inproces >= 3   THEN
                     DO:
                        glb_cdcritic = 138. 
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.
                
                RUN exibe_lanc_automaticos.
            END.
       ELSE
       IF   FRAME-VALUE = tel_dsdopcao[13]    THEN
            DO:
                ASSIGN glb_cddopcao = "@"
                       glb_nmrotina = "MAGNETICO".
                
                RUN p_acesso.
                
                IF   glb_cdcritic < 0   THEN
                     NEXT.
                 
                IF   glb_inproces >= 3   THEN
                     DO:
                        glb_cdcritic = 138. 
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.
                                
                RUN fontes/carmag.p (INPUT tel_nrdconta, 
                                     INPUT crapass.inpessoa,
                                     INPUT TRUE).
      
                tel_dsdopcao[13] = "  MAGNETICO:" +
                                   STRING(aux_qtcarmag,"      zzz,zz9").
                                   
                DISPLAY tel_dsdopcao[13] WITH FRAME f_atenda.
            END.
       ELSE 
       IF   FRAME-VALUE = tel_dsdopcao[14]   THEN
            DO:
                ASSIGN glb_cddopcao = "@"
                       glb_nmrotina = "FOLHAS CHEQ".
                
                RUN p_acesso.
                
                IF   glb_cdcritic < 0   THEN
                     NEXT.

                 
                IF   glb_inproces >= 3   THEN
                     DO:
                        glb_cdcritic = 138. 
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.
                
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                   aux_confirma = "N".
                   
                   MESSAGE "Voce realmente deseja imprimir a relacao de"
                           "cheques nao compensados? S/N:" UPDATE aux_confirma.

                   LEAVE.

                END.  /*  Fim do DO WHILE TRUE  */

                IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                     aux_confirma <> "S"   THEN
                     DO:
                         HIDE MESSAGE NO-PAUSE.
                         MESSAGE "Operacao nao efetuada!".
                         NEXT.
                     END.
               
                DO TRANSACTION ON ERROR UNDO, RETRY:

                   CREATE crapsol.
                   ASSIGN crapsol.dtrefere = glb_dtmvtolt
                          crapsol.nrsolici = 79
                          crapsol.cdempres = 11
                          crapsol.nrseqsol = TIME
                          crapsol.cdcooper = glb_cdcooper.
                   VALIDATE crapsol.
                END. /*  Fim da transacao  */
                
                HIDE MESSAGE NO-PAUSE.
                
                MESSAGE "Aguarde...".
                
                RUN fontes/crps272.p (INPUT crapsol.nrseqsol, 
                                      INPUT tel_nrdconta).
                                      
                HIDE MESSAGE NO-PAUSE.
            END.
       ELSE
       IF   FRAME-VALUE = tel_dsdopcao[15]   THEN
            DO:
                ASSIGN glb_cddopcao = "@"
                       glb_nmrotina = "OCORRENCIAS".

                IF   glb_cdcritic < 0   THEN
                     NEXT.
                 
                IF   glb_inproces >= 3   THEN
                     DO:
                         glb_cdcritic = 138. 
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         glb_cdcritic = 0.
                         NEXT.
                     END.               

                RUN exibe_ocorrencias.
                
                IF   RETURN-VALUE = "NOK"  THEN
                     NEXT.
            END.
       ELSE
       IF   FRAME-VALUE = tel_dsdopcao[9]   THEN
            DO:    
                ASSIGN glb_cdcritic = 0.
                IF   glb_inproces >= 3   THEN
                     DO:
                        glb_cdcritic = 138. 
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.
                
                RUN fontes/descontos.p(OUTPUT aux_erro).
                
                IF  aux_erro  THEN
                    NEXT.
                    
                tel_dsdopcao[9]  = "  DESCONTOS:" +
                                   STRING(aux_vltotdsc,"zzzzzz,zz9.99-").
                                   
                DISPLAY tel_dsdopcao[9] WITH FRAME f_atenda.
                 
            END.
       ELSE
       IF   FRAME-VALUE = tel_dsdopcao[8]   THEN
            DO: 
                ASSIGN glb_cddopcao = "@"
                       glb_nmrotina = "CONTA INV".

                IF   glb_inproces >= 3   THEN
                     DO:
                        glb_cdcritic = 138. 
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.
                
            RUN exibe_conta_investimento (INPUT TRUE).

        
                IF  RETURN-VALUE = "NOK"  THEN
                    NEXT.
                    
                /* atualizar o campo "CONTA INV" */
                /*  Calculo do saldo em depositos a vista  */
                RUN fontes/slddpv.p (INPUT FALSE).
                IF   glb_cdcritic > 0   THEN
                     DO:
                        glb_cdcritic = 0.
                        NEXT.
                     END.

                /* para pegar o valor do saldo conta investimento */

                ASSIGN aux_saldo_ci = 0.
                
                FIND crapsli WHERE crapsli.cdcooper  = glb_cdcooper        AND
                                   crapsli.nrdconta  = crapass.nrdconta    AND
                             MONTH(crapsli.dtrefere) = MONTH(glb_dtmvtolt) AND
                              YEAR(crapsli.dtrefere) = YEAR(glb_dtmvtolt)
                                   NO-LOCK NO-ERROR.
                
                IF   AVAIL crapsli THEN
                     ASSIGN aux_saldo_ci = crapsli.vlsddisp.
        
                tel_dsdopcao[8] = "  CONTA INV:" + 
                              STRING(aux_saldo_ci,"zzz,zzz,zz9.99-").
                
                tel_dsdopcao[04] = " DEP. VISTA:" +
                              STRING(tel_vlstotal,"zzz,zzz,zz9.99-").
                
                DISPLAY tel_dsdopcao[4]
                        tel_dsdopcao[8] WITH FRAME f_atenda.
            END.
       ELSE 
       IF   FRAME-VALUE = tel_dsdopcao[17]   THEN
            DO:
                ASSIGN glb_cddopcao = "@"
                       glb_nmrotina = "TELE ATEN".
                
                RUN p_acesso.
                
                IF   glb_cdcritic < 0   THEN
                     NEXT.
                
                IF   glb_inproces >= 3   THEN
                     DO:
                        glb_cdcritic = 138. 
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.
                
                RUN fontes/cadura.p.
                
                FIND crapsnh WHERE crapsnh.cdcooper = glb_cdcooper   AND
                                   crapsnh.nrdconta = tel_nrdconta   AND
                                   crapsnh.tpdsenha = 2 /* Ura */    AND
                                   crapsnh.idseqttl = 0
                                   NO-LOCK NO-ERROR.
                
                IF   NOT AVAILABLE crapsnh  THEN
                     DO:
                         ASSIGN tel_flgcdura = "Inativa".
                     END.
                ELSE
                IF   crapsnh.cdsitsnh = 1   THEN    
                     ASSIGN tel_flgcdura = "  Ativa".
                ELSE
                     ASSIGN tel_flgcdura = "Inativa".
                     
                ASSIGN tel_dsdopcao[17] = " TELE ATEN:     " + tel_flgcdura.  
                DISPLAY tel_dsdopcao[17] WITH FRAME f_atenda.
            END.
       ELSE 
       IF   FRAME-VALUE = tel_dsdopcao[18]   THEN
            DO:
                ASSIGN glb_cddopcao = "@"
                       glb_nmrotina = "CONVENIOS".
                
                RUN p_acesso.
                
                IF   glb_cdcritic < 0   THEN
                     NEXT.
                
                IF   glb_inproces >= 3   THEN
                DO:
                    glb_cdcritic = 138. 
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                    NEXT.
                END.
                
                IF   aux_qtconven > 0   THEN
                     RUN exibe_convenios.
                ELSE
                     MESSAGE "Associado nao possui convenios ativos.".
                
                DISPLAY tel_dsdopcao[18] WITH FRAME f_atenda.
            END.
       ELSE
       IF   FRAME-VALUE = tel_dsdopcao[19]   THEN
            DO:
                ASSIGN glb_cddopcao = "@"
                       glb_nmrotina = "RELACIONAMENTO".
                       
                RUN p_acesso.
                       
                IF   glb_cdcritic < 0   THEN
                     NEXT.
            
                RUN fontes/sitpgd.p.
            END.
       ELSE 
       IF   FRAME-VALUE = tel_dsdopcao[20]   THEN
            DO:
                ASSIGN glb_cddopcao = "@"
                       glb_nmrotina = "COBRANCA".

                RUN p_acesso.

                IF    glb_cdcritic < 0   THEN
                      NEXT.

                RUN fontes/cobranca.p (INPUT tel_nrdconta).
            END.
       ELSE
       IF   FRAME-VALUE = tel_dsdopcao[21]   THEN
            DO:
                ASSIGN glb_cddopcao = "@"
                       glb_nmrotina = "TELEFONE".
 
                RUN p_acesso.

                IF   glb_cdcritic < 0   THEN
                     NEXT.

                RUN fontes/telefone.p (INPUT tel_nrdconta).
            END.
       ELSE
       IF   FRAME-VALUE = tel_dsdopcao[22]   THEN
            DO:
                ASSIGN glb_cddopcao = "@"
                       glb_nmrotina = "CONSORCIO".

                RUN p_acesso.

                IF   glb_cdcritic < 0   THEN
                     NEXT.
                
                RUN fontes/atd_consorcios.p(INPUT tel_nrdconta).

            END.
       ELSE
            DO:
                BELL.
                MESSAGE "Opcao invalida".
            END.

    END.  /*  Fim do DO WHILE TRUE  */
    
    RELEASE crapass.
    RELEASE crapcot.
    RELEASE crappla.

END.  /*  Fim do DO WHILE TRUE  */
PROCEDURE p_acesso:
    
    DEF VAR pro_flgfirst AS LOGICAL INIT TRUE NO-UNDO.
    
    DO WHILE TRUE:
       
       IF   NOT pro_flgfirst   THEN
       DO:
           glb_cdcritic = -1.
           RETURN.
       END.
       
       pro_flgfirst = FALSE.
       
       { includes/acesso.i }
       
       glb_cdcritic = 0.

       LEAVE.
    
    END.  /*  Fim do DO WHILE TRUE  */

END PROCEDURE.

PROCEDURE exibe_lanc_automaticos:

    /*** Definicoes do browse de lancamentos automaticos ***/
    DEF VAR aux_query AS CHAR                                       NO-UNDO.
    
    DEF QUERY q_lancaut FOR tt-lancamento_futuro
                                 FIELDS(tt-lancamento_futuro.dsmvtolt
                                        tt-lancamento_futuro.dshistor
                                        tt-lancamento_futuro.nrdocmto
                                        tt-lancamento_futuro.indebcre
                                        tt-lancamento_futuro.vllanmto).


    DEF BROWSE b_lancaut QUERY q_lancaut
        DISP tt-lancamento_futuro.dsmvtolt COLUMN-LABEL "   Data" 
                                           FORMAT "x(10)"
             tt-lancamento_futuro.dshistor COLUMN-LABEL "Historico"
                                           FORMAT "x(25)"
             tt-lancamento_futuro.nrdocmto COLUMN-LABEL " Documento"
                                           FORMAT "x(11)"
             tt-lancamento_futuro.indebcre COLUMN-LABEL "D/C"
                                           FORMAT " x "
             tt-lancamento_futuro.vllanmto COLUMN-LABEL "Valor"
                                           FORMAT "zzz,zzz,zzz,zz9.99-"
             WITH 9 DOWN WIDTH 78 TITLE " Lancamentos Automaticos " 
                                  SCROLLBAR-VERTICAL.

    DEF FRAME f_lancaut
              b_lancaut  
        HELP "Tecle <Entra> ou <Fim> para voltar"
        WITH NO-BOX CENTERED OVERLAY ROW 9.

    aux_query = "FOR EACH tt-lancamento_futuro
                          NO-LOCK BY tt-lancamento_futuro.dtmvtolt".
         
    QUERY q_lancaut:QUERY-CLOSE().
    QUERY q_lancaut:QUERY-PREPARE(aux_query).

    MESSAGE "Aguarde...".
    QUERY q_lancaut:QUERY-OPEN().
         
    HIDE MESSAGE NO-PAUSE.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE b_lancaut WITH FRAME f_lancaut.
        LEAVE.
         
    END.  /*  Fim do DO WHILE TRUE  */

    QUERY q_lancaut:QUERY-CLOSE().
    
    HIDE FRAME f_lancaut.

END PROCEDURE.

PROCEDURE exibe_convenios:

    DEF QUERY q_convenio FOR tt-conven,
                             craphis FIELDS (craphis.dsexthst).

    DEF BROWSE b_convenio QUERY q_convenio
        DISPLAY tt-conven.cdhistor COLUMN-LABEL "Cod." 
                                                FORMAT "z999"
                tt-conven.dsexthst COLUMN-LABEL "Descricao" 
                                                FORMAT "x(28)"
                tt-conven.dtiniatr COLUMN-LABEL "Autoriz."  
                                                FORMAT "99/99/9999"
                tt-conven.dtultdeb COLUMN-LABEL "Ult.Debito" 
                                                FORMAT "99/99/9999"
                tt-conven.cdrefere COLUMN-LABEL "Referencia" 
                                                FORMAT "zzzzzzzzzzzzzzzz9"
                WITH 7 DOWN WIDTH 76 CENTERED NO-BOX.
     
    FORM b_convenio HELP "Pressione F4/END para sair"
         WITH ROW 10 CENTERED OVERLAY FRAME f_convenio 
              TITLE " CONVENIOS / DEBITOS AUTOMATICOS ".         

    RUN lista_conven IN h-b1wgen0026 (INPUT glb_cdcooper,
                                      INPUT 0,        /* p-cod-agencia */
                                      INPUT 0,        /* p-nro-caixa   */
                                      INPUT glb_cdoperad,
                                      INPUT tel_nrdconta,
                                      INPUT 1,        /* Ayllos        */
                                      INPUT 1,        /* par_idseqttl  */
                                      INPUT "ATENDA",
                                      INPUT FALSE,    /* Nao Logar     */
                                     OUTPUT TABLE tt-conven,
                                     OUTPUT TABLE tt-totconven).
                                   
    OPEN QUERY q_convenio FOR EACH tt-conven WHERE 
                              tt-conven.cdcooper = glb_cdcooper      AND
                              tt-conven.nrdconta = tel_nrdconta    NO-LOCK,
                          FIRST craphis WHERE 
                                craphis.cdcooper = glb_cdcooper     AND
                                craphis.cdhistor = tt-conven.cdhistor  NO-LOCK
                                BY tt-conven.dtiniatr
                                   BY tt-conven.cdhistor.
     
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE b_convenio WITH FRAME f_convenio.     
        
        LEAVE.
    
    END.   

    CLOSE QUERY q_convenio.

    HIDE FRAME f_convenio NO-PAUSE.

END PROCEDURE.

PROCEDURE exibe_ocorrencias:

  DEF VAR tel_opempres AS CHAR INIT "Emprestimos"                 NO-UNDO.
  DEF VAR tel_opprejui AS CHAR INIT "Prejuizos"                   NO-UNDO.
  DEF VAR tel_opspc    AS CHAR INIT "SPC"                         NO-UNDO.
  DEF VAR tel_opctrord AS CHAR FORMAT "x(13)" 
                               INIT "Contra Ordens"               NO-UNDO. 
  DEF VAR tel_opestour AS CHAR INIT "Estouros"                    NO-UNDO.
  DEF VAR tel_grpecono AS CHAR INIT "Grupo Economico"             NO-UNDO.
  DEF VAR tel_dsinadim AS CHAR FORMAT "x(3)"                      NO-UNDO.
  DEF VAR tel_dslbacen AS CHAR FORMAT "x(3)"                      NO-UNDO.

  DEF VAR tel_flgpreju AS LOGI FORMAT "Sim/Nao"                   NO-UNDO.
  DEF VAR tel_flgjucta AS LOGI FORMAT "Sim/Nao"                   NO-UNDO.
  DEF VAR tel_flgeprat AS LOGI FORMAT "Sim/Nao"                   NO-UNDO.
  DEF VAR tel_dsdrisgp AS CHAR FORMAT "X(2)"                      NO-UNDO.
  DEF VAR tel_vlendivi AS DEC  FORMAT "zzz,zzz,zz9.99"            NO-UNDO.


  DEF VAR tel_cdagenci AS INTE                                    NO-UNDO.               
  DEF VAR tel_nrcgccpf AS INTE                                    NO-UNDO.
  DEF VAR aux_nrdgrupo AS INTE                                    NO-UNDO.
  DEF VAR aux_gergrupo AS CHAR                                    NO-UNDO.
  DEF VAR aux_dsdrisgp AS CHAR                                    NO-UNDO.
  DEF VAR aux_pertengp AS LOGI                                    NO-UNDO.
  DEF VAR h-b1wgen0138 AS HANDLE                                  NO-UNDO.

  DEF VAR aux_tpidenti AS CHAR EXTENT 4
                               INIT ["Dev1-","Dev2-",
                                     "Fia1-","Fia2-"]             NO-UNDO.

  DEF VAR tel_riscoCoop AS CHAR FORMAT "x(15)"                    NO-UNDO.

  FORM SKIP
      tt-ocorren.qtctrord AT  3 LABEL "Contra Ordens"
      tt-ocorren.qtdevolu AT 50 LABEL "Devolucoes"
      SKIP
      tt-ocorren.dtcnsspc AT  4 LABEL "Consulta SPC"  FORMAT "99/99/9999"
      SPACE(19)
      tt-ocorren.dtdsdsps       LABEL "No SPC p/COOP" FORMAT "99/99/9999"
      tt-ocorren.qtddsdev AT 4  LABEL " Credito Liq"
      "(dd)"             
      tt-ocorren.dtdsdclq       NO-LABEL              FORMAT "99/99/9999"
      SPACE(14)
      "Estouros:"       
      tt-ocorren.qtddtdev       NO-LABEL              FORMAT "zzz9"
      "(ocor)"  
      SPACE(6)
      SKIP 
      tel_dsinadim        AT  4 LABEL " Esta no SPC" 
      tel_dslbacen        AT 52 LABEL "  No CCF" 
      SKIP
      "        Emprestimos em Atraso:"  
      tel_flgeprat              NO-LABEL
      tel_riscoCoop       AT 45 LABEL "Risco Cooperado"
      tt-ocorren.indrisco AT 54 LABEL "Rating"
      SKIP
      tt-ocorren.nivrisco AT 55 LABEL "Risco"
      SKIP
      "    Prejuizos ==> Emprestimos:"
      tel_flgpreju       NO-LABEL
      tt-ocorren.dtdrisco AT 47 LABEL "Data do Risco" FORMAT "99/99/9999"
      SKIP
      "               Conta Corrente:"  
      tel_flgjucta       NO-LABEL            
      tt-ocorren.qtdiaris AT 47 LABEL "Dias no Risco"
      SKIP
      tt-ocorren.dsdrisgp AT 39 LABEL "Risco Grupo Economico"
      SKIP(1)
      tel_opctrord AT  1 NO-LABEL FORMAT "x(13)"          
          HELP "Lista cheques com contra ordens."
      tel_opempres AT 17 NO-LABEL FORMAT "x(11)"          
          HELP "Lista os emprestimos em atraso."
      tel_opprejui AT 31 NO-LABEL FORMAT "x(09)"          
          HELP "Lista os emprestimos em prejuizo."
      tel_opspc    AT 43 NO-LABEL FORMAT "x(03)"          
          HELP "Lista o cadastro no SPC."
      tel_opestour AT 49 NO-LABEL FORMAT "x(8)"      
          HELP "Lista estouros e devolucoes de cheques."
      tel_grpecono AT 60 NO-LABEL FORMAT "X(15)"
          HELP "Lista Grupo Economico."
      WITH ROW 8 OVERLAY SIDE-LABELS TITLE COLOR NORMAL " OCORRENCIAS "
           COLUMN 2 FRAME f_inadimpl.

  DEF QUERY q-contra-ordem FOR tt-contra_ordem.
  
  DEF BROWSE b-contra-ordem QUERY q-contra-ordem
      DISPLAY tt-contra_ordem.cdbanchq LABEL "Bco"       FORMAT "zz9"
              tt-contra_ordem.cdagechq LABEL "Age"       FORMAT "zzz9"
              tt-contra_ordem.nrctachq LABEL "Cta.Chq"   FORMAT "zzzz,zzz,9" 
              tt-contra_ordem.cdoperad LABEL "OPE"       FORMAT "x(10)"
              tt-contra_ordem.nrcheque LABEL "Cheque"
              tt-contra_ordem.dtemscor LABEL "Emissao"   FORMAT "99/99/99"
              tt-contra_ordem.dtmvtolt LABEL "Inclusao"  FORMAT "99/99/99"  
              tt-contra_ordem.dshistor LABEL "Historico" FORMAT "x(50)"
              WITH 9 DOWN WIDTH 80 NO-LABELS OVERLAY 
                   TITLE " Contra-Ordens nos Cheques ".

  FORM b-contra-ordem
       HELP "Use as SETAS para navegar <F4> para sair."
       WITH ROW 9 NO-LABELS NO-BOX CENTERED OVERLAY FRAME f-contra-ordem.

  /* ...... Opcao de Emprestimos ....... */
  DEF QUERY q-emprestimo FOR tt-emprestimos.

  DEF BROWSE b-emprestimo QUERY q-emprestimo
      DISPLAY SUBSTR(tt-emprestimos.cdpesqui,1,10) FORMAT "x(10)"     
                                                   LABEL "Data"
              tt-emprestimos.nrctremp              FORMAT "zz,zzz,zz9" 
                                                   LABEL "Contrato"
              tt-emprestimos.vlemprst              FORMAT "zz,zzz,zzz.99"
                                                   LABEL "Emprestado"
              tt-emprestimos.vlsdeved              FORMAT "zz,zzz,zzz.99"
                                                   LABEL "Saldo"
              tt-emprestimos.vlpreapg              LABEL "A Regularizar"
                                                   FORMAT "zz,zzz,zz9.99-"
              tt-emprestimos.dtultpag              LABEL "Ult.Pagmto"
              WITH 9 DOWN WIDTH 78 NO-LABELS OVERLAY TITLE "Emprestimos".

  FORM b-emprestimo
       HELP "Use as SETAS para navegar <F4> para sair."
       WITH ROW 9 NO-LABELS NO-BOX CENTERED OVERLAY FRAME f_browse_emprestimo.

  /* ...... Opcao de Prejuizo ....... */
  DEF QUERY q-prejuizo FOR tt-prejuizos.

  DEF BROWSE b-prejuizo QUERY q-prejuizo
      DISPLAY SUBSTR(tt-prejuizos.cdpesqui,1,10) FORMAT "x(10)"     
                                                 LABEL "Data"
              tt-prejuizos.nrctremp              FORMAT "zz,zzz,zz9" 
                                                 LABEL "Contrato"
              tt-prejuizos.dtprejuz              LABEL "Data Transferencia"
              tt-prejuizos.vlprejuz              LABEL "Valor do Prejuizo"
                                                 FORMAT "zz,zzz,zz9.99"
              tt-prejuizos.vlsdprej              FORMAT "zz,zzz,zz9.99"
                                                 LABEL "Saldo Devedor"
              WITH 9 DOWN WIDTH 78 NO-LABELS OVERLAY 
                   TITLE "Emprestimos em Prejuizo".

  FORM b-prejuizo
       HELP "Use as SETAS para navegar <F4> para sair."
       WITH ROW 9 NO-LABELS NO-BOX CENTERED OVERLAY FRAME f_browse_prejuizo.

  /* ...... Opcao de Estouro ....... */
  DEF QUERY q-estouro FOR tt-estouros.

  DEF BROWSE b-estouro QUERY q-estouro
      DISPLAY tt-estouros.nrseqdig FORMAT "zzzz9" LABEL "Seq."
              tt-estouros.dtiniest FORMAT "99/99/9999" LABEL "Inicio"
              tt-estouros.qtdiaest FORMAT "zzzz" LABEL "Dias"
              tt-estouros.cdhisest FORMAT "x(15)" LABEL "Historico"
              tt-estouros.vlestour FORMAT "z,zzz,zzz,zz9.99" 
                                   LABEL "Valor est/devol"
              tt-estouros.nrdctabb FORMAT "zzzz,zzz,z" LABEL "Conta base"
              tt-estouros.nrdocmto FORMAT "zzz,zzz,z" LABEL "Documento"
              tt-estouros.cdobserv FORMAT "x(2)" LABEL ""
              tt-estouros.dsobserv FORMAT "x(15)" LABEL "Observacoes"
              tt-estouros.vllimcre FORMAT "zzzzzz,zz9.99" 
                                   LABEL "Limite Credito"
              tt-estouros.dscodant FORMAT "x(10)" LABEL "De"
              tt-estouros.dscodatu FORMAT "x(10)" LABEL "Para"
              WITH 9 DOWN WIDTH 78 NO-LABELS OVERLAY TITLE "Estouros".

  FORM b-estouro
       HELP "Use as SETAS para visualizar outros campos <F4> para sair."
       WITH ROW 9 NO-LABELS NO-BOX CENTERED OVERLAY FRAME f_browse_estouro.

  /* ...... Opcao de SPC ....... */
  DEF QUERY q-spc FOR tt-spc.

  DEF BROWSE b-spc QUERY q-spc
      DISPLAY tt-spc.nrctremp                FORMAT "zz,zzz,zz9"
                                             LABEL "Contrato"
              tt-spc.dsorigem                FORMAT "x(06)" 
                                             LABEL "Origem"
              tt-spc.dsidenti                FORMAT "x(20)"
                                             LABEL "Identificacao"
              tt-spc.dtvencto                LABEL "Vencimento"
              tt-spc.dtinclus                LABEL "Inclusao"
              tt-spc.vldivida                LABEL "Valor"
                                             FORMAT "zzzzzz,zz9.99-" 
              WITH 6 DOWN  WIDTH 78 NO-LABELS OVERLAY 
                   TITLE "Contratos no SPC".

  FORM b-spc
       HELP "Use as SETAS para navegar <F4> para sair."
       WITH ROW 9 NO-LABELS NO-BOX CENTERED OVERLAY FRAME f_browse_spc.

  FORM 
       tt-spc.nrctrspc   LABEL "Contrato SPC"  FORMAT "x(40)"
       SKIP
       tt-spc.dtdbaixa   LABEL "Data da Baixa"
       WITH ROW 19 COLUMN 04 NO-BOX SIDE-LABELS OVERLAY WIDTH 75 
            FRAME f_detalhes.
  
  DEF QUERY q-grupo FOR tt-grupo.

  DEF BROWSE b-grupo QUERY q-grupo
      DISPLAY tt-grupo.cdagenci     FORMAT "zz9"
                                             LABEL "PA"
              tt-grupo.nrctasoc     FORMAT "zzzz,zzz,9"
                                             LABEL "Conta"
              tt-grupo.nrcpfcgc     FORMAT "zzz,zzz,zzz,zzz,z9"
                                             LABEL "CNPJ/CPF"
              SPACE(4)
              tt-grupo.dsdrisco     LABEL "Risco"
              SPACE(8)
              tt-grupo.vlendivi     FORMAT "zzzzzz,zz9.99-"
                                             LABEL "Endividamento"
              SPACE(8)
      WITH 5 DOWN WIDTH 74 NO-LABELS OVERLAY NO-BOX.

  FORM "Risco do Grupo:" AT 03
       tel_dsdrisgp
       "Endividamento do Grupo:" AT 36
       tel_vlendivi
       SKIP(1)
       b-grupo
       HELP "Use as SETAS para navegar <F4> para sair."
       WITH ROW 9 NO-LABELS CENTERED OVERLAY TITLE "GRUPO ECONOMICO" 
                                     FRAME f_browse_grupo.
  
  ON VALUE-CHANGED, ENTRY OF b-spc DO:
      
      IF  AVAILABLE tt-spc  THEN
          DISPLAY tt-spc.nrctrspc tt-spc.dtdbaixa WITH FRAME f_detalhes.
  
  END.
                                   
  RUN lista_ocorren IN h-b1wgen0027 (INPUT glb_cdcooper,
                                     INPUT 0,        /* p-cod-agencia */
                                     INPUT 0,        /* p-nro-caixa   */
                                     INPUT glb_cdoperad,
                                     INPUT tel_nrdconta,
                                     INPUT glb_dtmvtolt,
                                     INPUT glb_dtmvtopr,
                                     INPUT glb_inproces,
                                     INPUT 1,        /* Ayllos        */
                                     INPUT 1,        /* par_idseqttl  */
                                     INPUT "ATENDA",
                                     INPUT FALSE,    /* Nao Logar     */
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-ocorren).
                                  
  IF RETURN-VALUE = "NOK"  THEN
     DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
         IF  AVAILABLE tt-erro  THEN
             ASSIGN glb_dscritic = tt-erro.dscritic.
         ELSE
             ASSIGN glb_dscritic = "Erro no carregamento de ocorrencias.".
             
         BELL.
         MESSAGE glb_dscritic.
         
         RETURN "NOK".

     END.

  FIND FIRST tt-ocorren NO-LOCK NO-ERROR.
  
  IF AVAILABLE tt-ocorren  THEN 
     DO:
        IF tel_flgexoco = ""  THEN
           DO:
               IF tt-ocorren.flgocorr  THEN
                  ASSIGN tel_flgexoco = "Sim".
               ELSE
                  ASSIGN tel_flgexoco = "Nao".
           
               RETURN "OK".

           END.
                        
        ASSIGN tel_dsinadim = IF  tt-ocorren.flginadi  THEN
                                  "Sim" 
                              ELSE 
                                  "Nao"
               tel_dslbacen = IF  tt-ocorren.flglbace  THEN
                                  "Sim" 
                              ELSE 
                                  "Nao"
               tel_flgpreju = tt-ocorren.flgpreju
               tel_flgjucta = tt-ocorren.flgjucta
               tel_flgeprat = tt-ocorren.flgeprat
               tel_riscoCoop = tt-ocorren.inrisctl + " - " +
                               STRING(tt-ocorren.dtrisctl, "99/99/9999").
           
        
        DISPLAY tt-ocorren.qtctrord tt-ocorren.qtdevolu
                tt-ocorren.indrisco tt-ocorren.nivrisco
                tt-ocorren.dtdrisco WHEN tt-ocorren.nivrisco <> "A"
                tt-ocorren.qtdiaris WHEN tt-ocorren.nivrisco <> "A"
                tt-ocorren.dsdrisgp
                tt-ocorren.dtcnsspc tt-ocorren.dtdsdsps
                tt-ocorren.dtdsdclq tt-ocorren.qtddtdev
                tt-ocorren.qtddsdev tel_dsinadim
                tel_dslbacen        tel_flgpreju
                tel_flgjucta        tel_flgeprat 
                tel_opctrord        tel_opempres        
                tel_opprejui        tel_opspc           
                tel_opestour        tel_riscoCoop WHEN tel_riscoCoop <> ?
                tel_grpecono
                WITH FRAME f_inadimpl.
                        
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        
           CHOOSE FIELD tel_opctrord 
                        tel_opempres 
                        tel_opprejui 
                        tel_opspc    
                        tel_opestour 
                        tel_grpecono
                        WITH FRAME f_inadimpl.
                       
           HIDE MESSAGE NO-PAUSE.

           IF FRAME-VALUE = tel_opctrord AND tt-ocorren.qtctrord > 0  THEN
              DO:        
                  RUN lista_contra-ordem IN h-b1wgen0027
                                 (INPUT glb_cdcooper,
                                  INPUT 0,        /* p-cod-agencia */
                                  INPUT 0,        /* p-nro-caixa   */
                                  INPUT glb_cdoperad,
                                  INPUT tel_nrdconta,
                                  INPUT 1,        /* Ayllos        */
                                  INPUT 1,        /* par_idseqttl  */
                                  INPUT "ATENDA",
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-contra_ordem).
                              
                  IF  RETURN-VALUE = "NOK"  THEN
                      DO:
                          FIND FIRST tt-erro NO-LOCK NO-ERROR.
                          
                          IF  AVAILABLE tt-erro  THEN
                              glb_dscritic = tt-erro.dscritic.
                          ELSE
                              glb_dscritic = "Erro no carregamento de " +
                                             "contra-ordens.".
                                             
                          BELL.
                          MESSAGE glb_dscritic. 
                                            
                          NEXT.                  
                      END.
                  
                  FIND FIRST tt-contra_ordem NO-LOCK NO-ERROR.
                  
                  IF  AVAILABLE tt-contra_ordem  THEN
                      DO:                      
                          OPEN QUERY q-contra-ordem
                                     FOR EACH tt-contra_ordem NO-LOCK.

                          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                          
                              UPDATE b-contra-ordem
                                     WITH FRAME f-contra-ordem.

                              LEAVE. 

                          END.

                          CLOSE QUERY q-contra-ordem.
                          
                          HIDE FRAME f-contra-ordem NO-PAUSE.
                      END.
              END. 
           ELSE
           IF  FRAME-VALUE = tel_opempres AND tel_flgeprat  THEN
               DO:
                   RUN lista_emprestimos IN h-b1wgen0027
                                          (INPUT glb_cdcooper,
                                           INPUT 0,   /* p-cod-agencia */
                                           INPUT 0,   /* p-nro-caixa   */
                                           INPUT glb_cdoperad,
                                           INPUT tel_nrdconta,
                                           INPUT glb_dtmvtolt,
                                           INPUT glb_dtmvtopr,
                                           INPUT glb_inproces,
                                           INPUT 1,   /* Ayllos        */
                                           INPUT 1,   /* par_idseqttl  */
                                           INPUT "ATENDA",
                                          OUTPUT TABLE tt-erro,
                                          OUTPUT TABLE tt-emprestimos).
                                   
                   IF  RETURN-VALUE = "NOK"  THEN
                       DO:
                           FIND FIRST tt-erro NO-LOCK NO-ERROR.
                           
                           IF  AVAILABLE tt-erro  THEN
                               glb_dscritic = tt-erro.dscritic.
                           ELSE
                               glb_dscritic = "Erro no carregamento de " +
                                              "emprestimos.".
                       
                           BELL.
                           MESSAGE glb_dscritic.
                           
                           NEXT.
                       END.

                   FIND FIRST tt-emprestimos NO-LOCK NO-ERROR.
                   
                   IF  AVAILABLE tt-emprestimos  THEN
                       DO:
                           OPEN QUERY q-emprestimo
                                      FOR EACH tt-emprestimos NO-LOCK.

                           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                               
                               UPDATE b-emprestimo 
                                      WITH FRAME f_browse_emprestimo.

                               LEAVE.
             
                           END.
                       
                           CLOSE QUERY q-emprestimo.
                           
                           HIDE FRAME f_browse_emprestimo NO-PAUSE.

                       END.

               END.
           ELSE
           IF  FRAME-VALUE = tel_opprejui AND tel_flgpreju  THEN 
               DO: 
                   RUN lista_prejuizos IN h-b1wgen0027
                                          (INPUT glb_cdcooper,
                                           INPUT 0,    /* p-cod-agencia */
                                           INPUT 0,    /* p-nro-caixa   */
                                           INPUT glb_cdoperad,
                                           INPUT tel_nrdconta,
                                           INPUT glb_dtmvtolt,
                                           INPUT glb_dtmvtopr,
                                           INPUT glb_inproces,
                                           INPUT 1,    /* Ayllos        */
                                           INPUT 1,    /* par_idseqttl  */
                                           INPUT "ATENDA",
                                          OUTPUT TABLE tt-erro,
                                          OUTPUT TABLE tt-prejuizos).
                               
                   IF  RETURN-VALUE = "NOK"  THEN
                       DO:
                           FIND FIRST tt-erro NO-LOCK NO-ERROR.

                           IF  AVAILABLE tt-erro  THEN
                               glb_dscritic = tt-erro.dscritic.
                           ELSE
                               glb_dscritic = "Erro no carregamento de " +
                                              "prejuizos.".

                           BELL.
                           MESSAGE glb_dscritic.
                           
                           NEXT.

                       END.

                   FIND FIRST tt-prejuizos NO-LOCK NO-ERROR.
                   
                   IF  AVAILABLE tt-prejuizos  THEN
                       DO:                      
                           OPEN QUERY q-prejuizo 
                                      FOR EACH tt-prejuizos NO-LOCK.
                               
                           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                           
                               UPDATE b-prejuizo 
                                      WITH FRAME f_browse_prejuizo.
           
                               LEAVE.
                           
                           END.

                           CLOSE QUERY q-prejuizo.
                           
                           HIDE FRAME f_browse_prejuizo NO-PAUSE.

                       END.

               END.   
           ELSE
           IF  FRAME-VALUE = tel_opspc AND tel_dsinadim = "Sim"  THEN 
               DO:
                   RUN lista_spc IN h-b1wgen0027
                                          (INPUT glb_cdcooper,
                                           INPUT 0,    /* p-cod-agencia */
                                           INPUT 0,    /* p-nro-caixa   */
                                           INPUT glb_cdoperad,
                                           INPUT tel_nrdconta,
                                           INPUT 1,    /* Ayllos        */
                                           INPUT 1,    /* par_idseqttl  */
                                           INPUT "ATENDA",
                                          OUTPUT TABLE tt-erro,
                                          OUTPUT TABLE tt-spc).

                   IF  RETURN-VALUE = "NOK"  THEN
                       DO:
                           FIND FIRST tt-erro NO-LOCK NO-ERROR.
                           
                           IF  AVAILABLE tt-erro  THEN
                               glb_dscritic = tt-erro.dscritic.
                           ELSE
                               glb_dscritic = "Erro no carregamento de " +
                                              "dados do SPC.".
                                             
                           BELL.
                           MESSAGE glb_dscritic.
                                                   
                           NEXT.                        
                       END.
                   
                   FIND FIRST tt-spc NO-LOCK NO-ERROR.
                   
                   IF  AVAILABLE tt-spc  THEN
                       DO:
                           OPEN QUERY q-spc 
                                      FOR EACH tt-spc NO-LOCK.
                                 
                           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                           
                               UPDATE b-spc WITH FRAME f_browse_spc.

                               LEAVE.

                           END.
                       
                           CLOSE QUERY q-spc.
                           
                           HIDE FRAME f_browse_spc NO-PAUSE.
                       END.
               END.
           ELSE
           IF FRAME-VALUE = tel_opestour  THEN 
              DO:          
                  RUN lista_estouros IN h-b1wgen0027
                                    (INPUT glb_cdcooper,
                                     INPUT 0,    /* p-cod-agencia */
                                     INPUT 0,    /* p-nro-caixa   */
                                     INPUT glb_cdoperad,
                                     INPUT tel_nrdconta,
                                     INPUT 1,    /* Ayllos        */
                                     INPUT 1,    /* par_idseqttl  */
                                     INPUT "ATENDA",
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-estouros).
                              
                  IF RETURN-VALUE = "NOK"  THEN
                     DO:
                         FIND FIRST tt-erro NO-LOCK NO-ERROR.
                         
                         IF  AVAILABLE tt-erro  THEN
                             glb_dscritic = tt-erro.dscritic.
                         ELSE
                             glb_dscritic = "Erro no carregamento de " +
                                            "estouros.".
                                            
                         BELL.
                         MESSAGE glb_dscritic.
                         
                         NEXT.

                     END.

                  FIND FIRST tt-estouros NO-LOCK NO-ERROR.
                      
                  IF AVAILABLE tt-estouros  THEN
                     DO:
                         OPEN QUERY q-estouro FOR EACH tt-estouros NO-LOCK.
                               
                         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                             
                             UPDATE b-estouro
                                    WITH FRAME f_browse_estouro.

                             LEAVE.
                         
                         END.
                         
                         CLOSE QUERY q-estouro.
                         HIDE FRAME f_browse_estouro NO-PAUSE.

                     END.

              END.
           ELSE
           IF FRAME-VALUE = tel_grpecono THEN
              DO:
                 IF NOT VALID-HANDLE(h-b1wgen0138) THEN
                    RUN sistema/generico/procedures/b1wgen0138.p
                       PERSISTENT SET h-b1wgen0138.
               
                 ASSIGN aux_pertengp =  DYNAMIC-FUNCTION("busca_grupo" 
                                                      IN h-b1wgen0138,
                                                      INPUT glb_cdcooper, 
                                                      INPUT tel_nrdconta, 
                                                     OUTPUT aux_nrdgrupo,
                                                     OUTPUT aux_gergrupo, 
                                                     OUTPUT aux_dsdrisgp).

                 IF VALID-HANDLE(h-b1wgen0138) THEN
                    DELETE OBJECT h-b1wgen0138.

                 IF aux_gergrupo <> "" THEN
                    DO: 
                       MESSAGE aux_gergrupo.
                       HIDE MESSAGE.

                    END.

                 IF aux_pertengp THEN
                    DO:
                       IF NOT VALID-HANDLE(h-b1wgen0138) THEN
                          RUN sistema/generico/procedures/b1wgen0138.p
                              PERSISTENT SET h-b1wgen0138.

                       /* Procedure responsavel para calcular o endividamento 
                          do grupo */
                       RUN calc_endivid_grupo IN h-b1wgen0138
                                        (INPUT glb_cdcooper,
                                         INPUT glb_cdagenci, 
                                         INPUT 0, 
                                         INPUT glb_cdoperad, 
                                         INPUT glb_dtmvtolt, 
                                         INPUT glb_nmdatela, 
                                         INPUT 1, 
                                         INPUT aux_nrdgrupo, 
                                         INPUT TRUE, /*Consulta por conta*/
                                        OUTPUT tel_dsdrisgp, 
                                        OUTPUT tel_vlendivi,
                                        OUTPUT TABLE tt-grupo,
                                        OUTPUT TABLE tt-erro).
                       
                       IF VALID-HANDLE(h-b1wgen0138) THEN
                          DELETE OBJECT h-b1wgen0138.

                       IF RETURN-VALUE <> "OK"  THEN
                          DO:
                             FIND FIRST tt-erro NO-LOCK NO-ERROR.
                             
                             IF AVAILABLE tt-erro  THEN
                                ASSIGN glb_dscritic = tt-erro.dscritic.
                             ELSE
                                ASSIGN glb_dscritic = "Erro no carregamento " +
                                                      "do Grupo Economico.".
                                   
                             BELL.
                             MESSAGE glb_dscritic.
                             NEXT.
                                  
                          END.

                       IF TEMP-TABLE tt-grupo:HAS-RECORDS THEN
                          DO:
                              DISP tel_dsdrisgp
                                   tel_vlendivi
                                   WITH FRAME f_browse_grupo.
                              
                              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                              
                                 OPEN QUERY q-grupo 
                                      FOR EACH tt-grupo NO-LOCK
                                          WHERE tt-grupo.cdcooper = glb_cdcooper
                                               BY tt-grupo.cdagenci
                                                BY tt-grupo.nrctasoc.
                                                           
                                 UPDATE b-grupo
                                        WITH FRAME f_browse_grupo.
                      
                                 LEAVE.
                      
                              END.
                              
                              CLOSE QUERY q-grupo.
                              HIDE FRAME f_browse_grupo.
                          
                          END. 

                    END.


              END. /*END BOTAO tel_grpecono*/ 

        END. /** Fim do DO WHILE TRUE **/
        
        HIDE FRAME f_inadimpl NO-PAUSE.

     END.            

  RETURN "OK".
                
END PROCEDURE.

PROCEDURE exibe_capital:

    DEF  INPUT PARAM par_flgextra AS LOGI                             NO-UNDO.
  
    DEF VAR var_tipo     AS CHAR                                      NO-UNDO.
    DEF VAR tot_vlparcap AS DECI FORMAT "zzzz,zz9.99"                 NO-UNDO.
    DEF VAR aux_vlsldant AS DECI                                      NO-UNDO.
    DEF VAR aux_recid    AS RECID                                     NO-UNDO.
    DEF VAR aux_dtcancel AS DATE FORMAT "99/99/9999"                  NO-UNDO.
    DEF VAR tel_dtiniper AS DATE FORMAT "99/99/9999"                  NO-UNDO.
    DEF VAR tel_dtfimper AS DATE FORMAT "99/99/9999"                  NO-UNDO.
    DEF VAR pla_botao01  AS CHAR FORMAT "x(14)" INIT "Cancelar Plano" NO-UNDO.
    DEF VAR pla_botao02  AS CHAR FORMAT "x(13)" INIT "Novo Plano"     NO-UNDO.
    DEF VAR pla_botao03  AS CHAR FORMAT "x(14)" INIT "Imprimir Plano" NO-UNDO.
    DEF VAR pla_vlprepla AS DECI FORMAT "zzz,zzz,zz9.99"              NO-UNDO.
    DEF VAR pla_dtdpagto AS DATE FORMAT "99/99/9999"                  NO-UNDO.
    DEF VAR pla_flgpagto AS CHAR VIEW-AS COMBO-BOX LIST-ITEMS "Conta"
                                                            PFCOLOR 2 NO-UNDO.
    DEF VAR pla_qtpremax AS INTE FORMAT "zz9" INIT 999                NO-UNDO.

    DEF VAR tel_integra  AS CHAR FORMAT "X(14)" INIT "Integralizacao" NO-UNDO.

    DEF VAR tel_integrav AS CHAR FORMAT "X(18)" INIT "Integralizar Cotas"
                                                                      NO-UNDO.
    DEF VAR tel_estorna  AS CHAR FORMAT "X(24)" INIT "Estornar Integralizacao"
                                                                      NO-UNDO.

    DEF VAR tel_vintegra AS DECI FORMAT "zz,zzz,zz9.99"               NO-UNDO.
    DEF VAR aux_flgsaldo AS LOGI                                      NO-UNDO.

    DEF VAR aut_flgsenha AS LOGI                                      NO-UNDO.
    DEF VAR aut_cdoperad AS CHAR                                      NO-UNDO.

    DEF VAR aux_flgpagto AS LOGI                                      NO-UNDO.

    DEF VAR aux_cdtipcor AS INTE                                      NO-UNDO.
    
    DEF VAR pla_atualiza AS CHAR FORMAT "x(32)" VIEW-AS COMBO-BOX 
                                LIST-ITEMS   "Sem Correcao Cadastrada",
                                             "Correcao por Indice de Inflacao",
                                             "Correcao por Valor Fixo"
                                                            PFCOLOR 2 NO-UNDO.
    DEF VAR aux_dstipcor AS CHAR 
   INIT "Sem Correcao Cadastrada,Correcao por Indice de Inflacao,Correcao por Valor Fixo" NO-UNDO.
    DEF VAR pla_vlreajus AS DECI FORMAT "zz,zz9.99" INIT 0            NO-UNDO.
    DEF VAR pla_dtultatu AS DATE FORMAT "99/99/9999"                  NO-UNDO.
    DEF VAR pla_dtproatu AS DATE FORMAT "99/99/9999"                  NO-UNDO.
    
    DEF QUERY q-extrato FOR tt-extrato_cotas.
    DEF QUERY q-integralizacao FOR tt-lancamentos.
  
    DEF BROWSE b-extrato QUERY q-extrato   
        DISPLAY tt-extrato_cotas.dtmvtolt LABEL "   Data" 
                                          FORMAT "99/99/9999" 
                tt-extrato_cotas.dshistor LABEL "Historico"  
                                          FORMAT "x(25)"
                tt-extrato_cotas.nrdocmto LABEL " Documento" 
                                          FORMAT "zzz,zzz,zz9"
                tt-extrato_cotas.indebcre LABEL "D/C"        
                                          FORMAT " x " 
                tt-extrato_cotas.vllanmto LABEL "Valor"
                                          FORMAT "zzz,zzz,zzz,zz9.99-"
                WITH 7 DOWN WIDTH 76 NO-LABELS OVERLAY TITLE " Extrato ".

    FORM b-extrato   
         HELP "Use as SETAS para navegar <F4> para sair."
         WITH ROW 9 NO-LABELS NO-BOX CENTERED OVERLAY FRAME f_extrato.

    DEF QUERY q-subscricao FOR tt-subscricao.
    
    DEF BROWSE b-subscricao QUERY q-subscricao
        DISPLAY tt-subscricao.dtrefere LABEL "Referente"   FORMAT "99/99/9999"
                tt-subscricao.dtdebito LABEL "Debitado em" FORMAT "x(10)"
                tt-subscricao.vllanmto LABEL "Valor"       FORMAT "zzzz,zz9.99"
                tt-subscricao.vlparcap LABEL "Total Pago"  FORMAT "zzzz,zz9.99"
                WITH 6 DOWN WIDTH 50 NO-LABELS OVERLAY 
                     TITLE " Subscricao de Capital ".

    FORM b-subscricao
         HELP "Use as SETAS para navegar <F4> para sair."
         WITH ROW 9 NO-LABELS NO-BOX CENTERED OVERLAY FRAME f_browse_subscricao.

    FORM 
        tel_dtiniper AT 02 LABEL "Entre com o periodo desejado"
                     HELP "Entre com a data inicial do periodo."
        "a"
        tel_dtfimper NO-LABEL
                     HELP "Entre com a data final do periodo."
        WITH WIDTH 57 ROW 13 SIDE-LABELS CENTERED OVERLAY 
             FRAME f_periodo_extrato.
        
    FORM 
        SKIP(1)
        tt-dados-capital.vlcaptal AT  2 LABEL "Valor Total do Capital"
                                        FORMAT "zzz,zzz,zzz,zz9.99-"
        tt-dados-capital.nrctrpla AT 45 LABEL "Plano de Capital"
                                        FORMAT "zzz,zz9"
        SKIP(1)
        tt-dados-capital.vldcotas AT  9 LABEL "Valor das Cotas" 
                                        FORMAT "zzz,zzz,zzz,zz9.99-"
        tt-dados-capital.vlprepla AT 49 LABEL "Valor" FORMAT "zzz,zzz,zz9.99" 
        SKIP
        "Pagou:"     AT 49
        tt-dados-capital.qtprepag AT 67 NO-LABEL FORMAT "zzz"
        SKIP
        tt-dados-capital.dspagcap AT 05 NO-LABEL FORMAT "x(20)"
        "Contratacao:" AT 43
        tt-dados-capital.dtinipla AT 60 NO-LABEL FORMAT "99/99/9999"
        SKIP
        tt-dados-capital.vlmoefix AT  5 LABEL "Valor da Moeda Fixa"
                                        FORMAT "zzzzz,zz9.99999999"
        SKIP(1)
        "PA:"            AT 05
        tt-dados-capital.cdagenci  AT 10 NO-LABEL FORMAT "zz9"
        "Banco/Caixa:"    AT 18
        tt-dados-capital.cdbccxlt  AT 31 NO-LABEL FORMAT "zz9"
        "Lote:"           AT 39
        tt-dados-capital.nrdolote  AT 45 NO-LABEL FORMAT "zzz,zz9"
        SKIP(1)
        tel_dsparcap AT 05 NO-LABEL FORMAT "x(18)"
        tel_dsplanos AT 26 NO-LABEL FORMAT "x(16)"
        tel_extratos AT 45 NO-LABEL
        tel_integra  AT 55 NO-LABEL
        WITH ROW 9 CENTERED OVERLAY SIDE-LABELS TITLE " Capital " WIDTH 74
             FRAME f_capital.
          
    FORM SKIP(1)
        pla_vlprepla AT 12 LABEL "Valor do Plano"
                     HELP "Entre com o valor do plano."
        SKIP 
        pla_atualiza AT 04 LABEL "Atualizacao Automatica"
                 HELP "Selecione o tipo de atualizacao de reajuste de capital."
        SKIP
        pla_vlreajus AT 21 LABEL "Valor"
                     HELP "Entre com o valor do reajuste."
        SKIP 
        pla_flgpagto AT 16 LABEL "Debitar em"
                     HELP "Selecione o tipo de debito."
        SKIP 
        pla_qtpremax AT 05 LABEL "Quantidade Prestacoes" 
        HELP "Entre com a quantidade de prestacoes ou 999 para indeterminado." 
        SKIP (1)
        pla_dtdpagto AT 12 LABEL "Data de Inicio" FORMAT "99/99/9999"
                     HELP "Entre com o a data do primeiro pagamento."
        SKIP
        pla_dtultatu AT 03 LABEL "Data Ultima Atualizacao"  FORMAT "99/99/9999"
        SKIP
        pla_dtproatu AT 02 LABEL "Data Proxima Atualizacao" FORMAT "99/99/9999"
        SKIP(1)
        pla_botao01  AT 05 NO-LABEL
        pla_botao02  AT 27 NO-LABEL
        pla_botao03  AT 45 NO-LABEL
        SKIP(1)
        WITH ROW 5 CENTERED SIDE-LABELS OVERLAY WIDTH 66 FRAME f_plano
             TITLE COLOR NORMAL " Novo Plano de Capital ".

    FORM SKIP(1)
         "Selecione a opcao desejada:" AT 10
         SKIP(2)
         tel_integrav AT 02
         tel_estorna  AT 22
         SKIP(1)
         WITH ROW 10 CENTERED NO-LABELS SIDE-LABELS OVERLAY 
                                                    FRAME f_integralizacao.

    FORM SKIP(1)
         tel_vintegra LABEL "Valor da Integralizacao"
            VALIDATE(tel_vintegra > 0, "Valor invalido para integralizacao.")
         SKIP(1)
         WITH ROW 11 CENTERED SIDE-LABELS OVERLAY FRAME f_integraliza.

    DEF BROWSE b-integralizacao QUERY q-integralizacao
        DISP tt-lancamentos.nrdocmto COLUMN-LABEL "Documento" FORMAT "zzzzzzz9"
             tt-lancamentos.vllanmto COLUMN-LABEL "Valor"     FORMAT "zz,zzz,zz9.99"
        WITH 5 DOWN WIDTH 25 OVERLAY 
        TITLE "Estornar" MULTIPLE.

    FORM SKIP(1)
         b-integralizacao AT 01
         HELP "<ESPACO> Marcar/Desmarcar <F4> Retornar"
         WITH NO-BOX CENTERED OVERLAY ROW 11
         FRAME f_lanc_integralizados.

    ON RETURN OF pla_flgpagto DO:
        APPLY "TAB".
    END.

    ON TAB OF pla_flgpagto DO:

        IF pla_flgpagto:SCREEN-VALUE = "Folha" THEN
        DO:
            ASSIGN pla_dtdpagto = tt-novo-plano.dtfuturo.
            DISPLAY pla_dtdpagto WITH FRAME f_plano.
        END.
    END.

    ON RETURN OF pla_atualiza DO:

        IF pla_atualiza:SCREEN-VALUE <> "Correcao por Valor Fixo" THEN
        DO:
            ASSIGN pla_vlreajus = 0.
            HIDE FIELD pla_vlreajus.
        END.
    
        APPLY "GO".
    END.
  
    RUN obtem_dados_capital IN h-b1wgen0021 (INPUT glb_cdcooper,
                                             INPUT 0,     /* p-cod-agencia */
                                             INPUT 0,     /* p-nro-caixa   */
                                             INPUT glb_cdoperad,           
                                             INPUT "ATENDA",
                                             INPUT 1,     /* Ayllos        */
                                             INPUT tel_nrdconta,
                                             INPUT 1,     /* par_idseqttl  */
                                             INPUT glb_dtmvtolt,
                                             INPUT FALSE, /* log           */
                                            OUTPUT TABLE tt-dados-capital,
                                            OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-erro  THEN
                glb_dscritic = tt-erro.dscritic.
            ELSE
                glb_dscritic = "Erro no carregamento de dados do capital.".
                
            BELL.
            MESSAGE glb_dscritic.
            
            RETURN "NOK".
        END.
    
    FIND FIRST tt-dados-capital NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE tt-dados-capital  THEN
        DO:
            BELL.
            MESSAGE "Erro no carregamento de dados do capital.".
            
            RETURN "NOK".
        END.    
            
    IF  NOT par_flgextra  THEN
        DO:
            ASSIGN tel_vlcaptal = tt-dados-capital.vldcotas
                   tel_vlprepla = tt-dados-capital.vlprepla.

            RETURN "OK".
        END.
    
    DISPLAY tt-dados-capital.vlcaptal 
            tt-dados-capital.vldcotas 
            tt-dados-capital.nrctrpla
            tt-dados-capital.vlprepla
            tt-dados-capital.qtprepag 
            tt-dados-capital.vlmoefix 
            tt-dados-capital.dspagcap 
            tt-dados-capital.dtinipla
            tel_extratos 
            tel_dsplanos 
            tel_dsparcap 
            tel_integra
            tt-dados-capital.cdagenci
            tt-dados-capital.cdbccxlt
            tt-dados-capital.nrdolote 
            WITH FRAME f_capital.
 
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE.

        IF  glb_cdcritic > 0  THEN
            DO:
                RUN fontes/critic.p.
                glb_cdcritic = 0.
                
                BELL.
                MESSAGE glb_dscritic.
            END.

        CHOOSE FIELD tel_dsparcap tel_dsplanos tel_extratos tel_integra
                     WITH FRAME f_capital.

        HIDE MESSAGE NO-PAUSE.
        
        IF  FRAME-VALUE = tel_extratos  THEN  /* Extrato */
            DO:
                ASSIGN glb_cddopcao = "E"           
                       glb_nmrotina = "CAPITAL".
                        
                RUN p_acesso.
                
                IF  glb_cdcritic < 0  THEN
                    NEXT.
                     
                ASSIGN tel_dtiniper = ? 
                       tel_dtfimper = ?.
                       
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                       
                    UPDATE tel_dtiniper tel_dtfimper 
                           WITH FRAME f_periodo_extrato.
                                 
                    IF  tel_dtiniper = ?  THEN
                        tel_dtiniper = DATE(01,01,YEAR(glb_dtmvtolt)).
                        
                    IF  tel_dtfimper = ?  THEN
                        tel_dtfimper = glb_dtmvtolt.
                        
                    IF  YEAR(tel_dtiniper) < 2005  THEN
                        DO:
                            BELL.
                            MESSAGE "Data inicial nao pode ser inferior a"
                                    "01/01/2005.".
                            NEXT.
                        END.

                    IF  tel_dtiniper > tel_dtfimper  THEN
                        DO:
                            BELL.
                            MESSAGE "Data final nao pode ser inferior a data"
                                    "inicial.".
                            NEXT.
                        END.
                        
                    LEAVE.    
                        
                END. /** Fim do DO WHILE TRUE **/
                
                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                    DO:
                        HIDE FRAME f_periodo_extrato NO-PAUSE.
                        NEXT.
                    END.
                       
                MESSAGE "Aguarde, carregando extrato ...".
                       
                RUN extrato_cotas IN h-b1wgen0021
                                       (INPUT glb_cdcooper,
                                        INPUT 0,            /* p-cod-agencia */
                                        INPUT 0,            /* p-nro-caixa   */
                                        INPUT glb_cdoperad,
                                        INPUT "ATENDA",
                                        INPUT 1,            /* Ayllos        */
                                        INPUT tel_nrdconta,
                                        INPUT 1,            /* par_idseqttl  */
                                        INPUT glb_dtmvtolt,
                                        INPUT tel_dtiniper,
                                        INPUT tel_dtfimper,
                                        INPUT TRUE,
                                       OUTPUT aux_vlsldant,
                                       OUTPUT TABLE tt-extrato_cotas).
                                    
                HIDE FRAME f_periodo_extrato NO-PAUSE.
                
                HIDE MESSAGE NO-PAUSE.
                
                OPEN QUERY q-extrato FOR EACH tt-extrato_cotas NO-LOCK.
                                      
                IF  NUM-RESULTS("q-extrato") = 0  THEN
                    DO:
                        BELL.
                        MESSAGE "Nenhum lancamento encontrado.".
                        
                        CLOSE QUERY q-extrato.
                        
                        NEXT.
                    END.
                
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                
                    UPDATE b-extrato WITH FRAME f_extrato.
                                    
                    LEAVE.
                                    
                END.
                                
                CLOSE QUERY q-extrato.
                                
                HIDE FRAME f_extrato NO-PAUSE.
            END.
        ELSE
        IF  FRAME-VALUE = tel_dsplanos  THEN /* Plano de Capital */ 
            DO:
                ASSIGN glb_cddopcao = "P"
                       glb_nmrotina = "CAPITAL".

                RUN p_acesso.
                
                IF  glb_cdcritic < 0  THEN
                    NEXT.
                
                DO WHILE TRUE:

                    RUN obtem-novo-plano IN h-b1wgen0021
                                       (INPUT glb_cdcooper,
                                        INPUT 0, /* p-cod-agencia */
                                        INPUT 0, /* p-nro-caixa */
                                        INPUT 1, /* glb_cdoperad */
                                        INPUT "ATENDA",
                                        INPUT 1, /* Ayllos */
                                        INPUT tel_nrdconta,
                                        INPUT 1,        /* par_idseqttl */
                                        INPUT glb_dtmvtolt,
                                       OUTPUT TABLE tt-horario,
                                       OUTPUT TABLE tt-novo-plano,
                                       OUTPUT TABLE tt-erro).
                                
                    IF  RETURN-VALUE = "NOK"  THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                        
                            IF  AVAILABLE tt-erro THEN
                                glb_dscritic = tt-erro.dscritic.
                            ELSE
                                glb_dscritic = "Erro no carregamento de novo " +
                                               "plano.".

                            BELL.
                            MESSAGE glb_dscritic.
                                        
                            LEAVE.
                        END.

                    FIND FIRST tt-novo-plano NO-LOCK NO-ERROR.
                            
                    IF  NOT AVAILABLE tt-novo-plano  THEN
                        DO:
                            BELL.
                            MESSAGE "Erro ao carregar plano.".
                                        
                            LEAVE.
                        END.
                                                       
                    ASSIGN pla_vlprepla = tt-novo-plano.vlprepla
                           pla_qtpremax = tt-novo-plano.qtpremax
                           pla_dtdpagto = tt-novo-plano.dtdpagto.

                    IF ENTRY(1, tt-novo-plano.despagto, "," ) = "" THEN
                        ASSIGN pla_flgpagto:LIST-ITEMS = "Conta".
                    ELSE
                        ASSIGN pla_flgpagto:LIST-ITEMS = "Conta,Folha".
                    
                    ASSIGN pla_flgpagto = ENTRY(3, tt-novo-plano.despagto, ",").
                    
                    ASSIGN pla_flgpagto:SCREEN-VALUE = 
                                         ENTRY(3, tt-novo-plano.despagto, ",").

                    ASSIGN pla_atualiza = ENTRY(tt-novo-plano.cdtipcor + 1,
                                                aux_dstipcor, ",").

                    ASSIGN pla_atualiza:SCREEN-VALUE = 
                        ENTRY(tt-novo-plano.cdtipcor + 1, aux_dstipcor, ",").
                    
                    ASSIGN pla_vlreajus = tt-novo-plano.vlcorfix
                           pla_dtultatu = tt-novo-plano.dtultcor
                           pla_dtproatu = tt-novo-plano.dtprocor.

                    IF tt-novo-plano.flcancel THEN /* possui plano ativo */
                        ASSIGN pla_botao02  = "Alterar Plano".
                    ELSE
                        ASSIGN pla_botao02 = "Novo Plano".

                    HIDE FIELD pla_vlreajus.

                    DISPLAY pla_vlprepla
                            pla_atualiza
                            pla_flgpagto
                            pla_qtpremax
                            pla_dtdpagto
                            pla_dtultatu
                            pla_dtproatu
                            pla_botao01  
                            pla_botao02  
                            pla_botao03
                            WITH FRAME f_plano.

                    IF tt-novo-plano.cdtipcor = 2 THEN
                        DISPLAY pla_vlreajus WITH FRAME f_plano.
                                     
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    
                        IF  glb_cdcritic > 0  THEN
                            DO:
                                RUN fontes/critic.p.
                                BELL.
                                MESSAGE glb_dscritic.
                                glb_cdcritic = 0.
                            END.

                        CHOOSE FIELD pla_botao01  
                                     pla_botao02  
                                     pla_botao03
                                     WITH FRAME f_plano.
          
                        HIDE MESSAGE NO-PAUSE.
                        
                        IF  FRAME-VALUE = pla_botao01 THEN /* Cancelar */ 
                            DO:
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                    ASSIGN aux_confirma = "N"
                                           aux_dtcancel = 
                                                    tt-dados-capital.dtinipla.
                                       
                                    BELL.
                                    MESSAGE COLOR NORMAL 
                                            "Confirme o cancelamento do"
                                            "plano" tt-dados-capital.nrctrpla
                                            "efetuado em"
                                            aux_dtcancel "- (S/N):" 
                                            UPDATE aux_confirma.
                          
                                    LEAVE.
                                
                                END.  
                                    
                                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                                    aux_confirma <> "S"                 THEN
                                    DO:
                                        glb_cdcritic = 79.
                                        NEXT.
                                    END.
                                  
                                RUN impressao_plano_capital (INPUT "CANCELAR").
                                                                
                                LEAVE.
                            END.
                        ELSE      
                        IF  FRAME-VALUE = pla_botao02 THEN
                            DO:
                               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                    UPDATE pla_vlprepla
                                           pla_atualiza
                                           WITH FRAME f_plano.
                                         
                                    LEAVE.       

                                END.
                                     
                                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                                    LEAVE.

                                IF pla_atualiza:SCREEN-VALUE = 
                                                "Correcao por Valor Fixo" THEN
                                DO:
                                    ASSIGN aux_cdtipcor = 2.

                                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                                        UPDATE pla_vlreajus WITH FRAME f_plano.

                                        LEAVE.
                                    END.
                                END.
                                ELSE
                                IF pla_atualiza:SCREEN-VALUE = 
                                                "Sem Correcao Cadastrada" THEN
                                    ASSIGN aux_cdtipcor = 0.
                                ELSE
                                    ASSIGN aux_cdtipcor = 1.

                                IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                    LEAVE.

                                IF NOT tt-novo-plano.flcancel THEN
                                DO:
                                    UPDATE pla_flgpagto
                                           pla_qtpremax
                                           WITH FRAME f_plano.

                                    /* Se plano "Conta" permite alterar a data 
                                       do pagamento - se Cadastrar Novo Plano*/
                                    IF pla_flgpagto:SCREEN-VALUE = "Conta" THEN
                                    DO:
                                        pla_dtdpagto = glb_dtmvtolt.

                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                        
                                            UPDATE pla_dtdpagto
                                                   WITH FRAME f_plano.
                                            
                                            LEAVE.       
                                        
                                        END.

                                        IF  KEYFUNCTION(LASTKEY) = 
                                            "END-ERROR"  THEN
                                            LEAVE.
                                    END.
                                    ELSE
                                    DO:
                                        ASSIGN pla_dtdpagto = tt-novo-plano.dtfuturo.

                                        DISPLAY pla_dtdpagto WITH FRAME f_plano.
                                    END.
                                END.

                                RUN fontes/confirma.p (INPUT "",
                                                      OUTPUT aux_confirma).                

                                IF  aux_confirma <> "S"   THEN
                                DO:
                                    IF tt-novo-plano.cdtipcor <> 2 THEN
                                        HIDE FIELD pla_vlreajus.

                                    LEAVE.
                                END.

                                ASSIGN aux_flgpagto = 
                                    IF pla_flgpagto:SCREEN-VALUE = "Conta" THEN
                                        FALSE
                                    ELSE
                                        TRUE.

                                IF tt-novo-plano.flcancel THEN
                                    RUN altera-plano IN h-b1wgen0021 
                                              (INPUT glb_cdcooper, 
                                               INPUT crapass.cdagenci, 
                                               INPUT 0,       /* nrdcaixa */
                                               INPUT glb_cdoperad, 
                                               INPUT "ATENDA", 
                                               INPUT 1, /* Ayllos */
                                               INPUT tel_nrdconta, 
                                               INPUT 1,       /* idseqttl */ 
                                               INPUT glb_dtmvtolt,
                                               INPUT pla_vlprepla,
                                               INPUT aux_cdtipcor,
                                               INPUT pla_vlreajus,
                                               INPUT aux_flgpagto,
                                               INPUT pla_qtpremax,
                                               INPUT pla_dtdpagto,
                                              OUTPUT TABLE tt-erro).
                                ELSE
                                    RUN cria-plano IN h-b1wgen0021 
                                              (INPUT glb_cdcooper, 
                                               INPUT crapass.cdagenci, 
                                               INPUT 0,       /* nrdcaixa */
                                               INPUT glb_cdoperad, 
                                               INPUT "ATENDA", 
                                               INPUT 1, /* Ayllos */
                                               INPUT tel_nrdconta, 
                                               INPUT 1,       /* idseqttl */ 
                                               INPUT glb_dtmvtolt,
                                               INPUT pla_vlprepla,
                                               INPUT aux_cdtipcor,
                                               INPUT pla_vlreajus,
                                               INPUT aux_flgpagto,
                                               INPUT pla_qtpremax,
                                               INPUT pla_dtdpagto,
                                              OUTPUT TABLE tt-erro).
                                    
                                IF  RETURN-VALUE = "NOK"  THEN
                                    DO:
                                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                            
                                        IF  AVAILABLE tt-erro  THEN
                                            glb_dscritic = tt-erro.dscritic.
                                        ELSE
                                            glb_dscritic = "Erro no cadastro " +
                                                           "do novo plano.".
                                                           
                                        BELL.
                                        MESSAGE glb_dscritic.
                                            
                                        LEAVE.
                                    END.

                                RUN impressao_plano_capital (INPUT "IMPRIMIR").
                                     
                                LEAVE.
                            END.
                        ELSE
                        IF  FRAME-VALUE = pla_botao03 THEN /* Imprimir Plano */
                            RUN impressao_plano_capital (INPUT "IMPRIMIR").
                               
                    END. /* Fim do DO WHILE TRUE */
                            
                    IF  KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
                        DO:
                            HIDE FRAME f_plano.

                            LEAVE.
                        END.
                    
                END. /* Fim do DO WHILE TRUE */
            END.
        ELSE
        IF   FRAME-VALUE = tel_dsparcap   THEN
             DO:
                RUN proc-subscricao IN h-b1wgen0021
                                   (INPUT glb_cdcooper,
                                    INPUT 0, /* p-cod-agencia */
                                    INPUT 0, /* p-nro-caixa */
                                    INPUT glb_cdoperad,
                                    INPUT "ATENDA",
                                    INPUT 1, /* Ayllos */
                                    INPUT tel_nrdconta,
                                    INPUT 1,        /* par_idseqttl */
                                   OUTPUT TABLE tt-subscricao).
                
                OPEN QUERY q-subscricao FOR EACH tt-subscricao NO-LOCK.
                    
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                        
                    UPDATE b-subscricao WITH FRAME f_browse_subscricao.

                    LEAVE.
                
                END.
                
                CLOSE QUERY q-subscricao.
                
                HIDE FRAME f_browse_subscricao NO-PAUSE.
             END.
        ELSE
        IF   FRAME-VALUE = tel_integra THEN
             DO:
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    HIDE FRAME f_integraliza.
                    HIDE FRAME f_lanc_integralizados.

                    DISP tel_integrav
                         tel_estorna WITH FRAME f_integralizacao.
    
                    CHOOSE FIELD tel_integrav tel_estorna 
                                 WITH FRAME f_integralizacao.
    
                    IF FRAME-VALUE = tel_integrav THEN
                    DO: 
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        
                            ASSIGN tel_vintegra = 0
                                   aux_flgsaldo = FALSE.
    
                            UPDATE tel_vintegra WITH FRAME f_integraliza.
        
                            RUN fontes/confirma.p (INPUT "",
                                                  OUTPUT aux_confirma).                
        
                            IF aux_confirma <> "S" THEN
                                LEAVE.
                            
                            RUN integraliza_cotas IN h-b1wgen0021 
                                                            (INPUT glb_cdcooper,
                                                             INPUT 1,
                                                             INPUT 0,
                                                             INPUT glb_cdoperad,
                                                             INPUT "ATENDA",
                                                             INPUT 1,
                                                             INPUT tel_nrdconta,
                                                             INPUT glb_dtmvtolt,
                                                             INPUT tel_vintegra,
                                                      INPUT-OUTPUT aux_flgsaldo,
                                                            OUTPUT TABLE tt-erro).
    
                            IF RETURN-VALUE = "NOK" THEN
                            DO:
                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                                IF AVAIL tt-erro THEN
                                    ASSIGN glb_dscritic = tt-erro.dscritic.
                                ELSE
                                    ASSIGN glb_dscritic = "Nao foi possivel " +
                                                          "realizar a " +
                                                          "integralizacao".
    
                                BELL.
                                MESSAGE glb_dscritic.
    
                                LEAVE.
                            END.
    
                            IF aux_flgsaldo THEN
                            DO:
                                ASSIGN aux_confirma = "N".
    
                                MESSAGE "Saldo c/c insuficiente para esta " +
                                        "operacao. Confirma a operacao?"
                                        UPDATE aux_confirma.
    
                                IF aux_confirma <> "S" THEN
                                DO:
                                    MESSAGE "079 - Operacao nao efetuada.".
                                    NEXT.
                                END.

                                RUN fontes/pedesenha.p (INPUT glb_cdcooper,
                                                        INPUT 2,
                                                       OUTPUT aut_flgsenha,
                                                       OUTPUT aut_cdoperad).

                                IF NOT aut_flgsenha THEN
                                DO:
                                    MESSAGE "079 - Operacao nao efetuada.".
                                    NEXT.
                                END.
    
                                RUN integraliza_cotas IN h-b1wgen0021 
                                                            (INPUT glb_cdcooper,
                                                             INPUT 1,
                                                             INPUT 0,
                                                             INPUT glb_cdoperad,
                                                             INPUT "ATENDA",
                                                             INPUT 1,
                                                             INPUT tel_nrdconta,
                                                             INPUT glb_dtmvtolt,
                                                             INPUT tel_vintegra,
                                                      INPUT-OUTPUT aux_flgsaldo,
                                                            OUTPUT TABLE tt-erro).
    
                                IF RETURN-VALUE = "NOK" THEN
                                DO:
                                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                                    IF AVAIL tt-erro THEN
                                        ASSIGN glb_dscritic = tt-erro.dscritic.
                                    ELSE
                                        ASSIGN glb_dscritic = "Nao foi possivel " +
                                                              "realizar a " +
                                                              "integralizacao".
    
                                    BELL.
                                    MESSAGE glb_dscritic.
    
                                    LEAVE.
                                END.
                            END.
    
                            MESSAGE "Integralizacao realizada com sucesso.".
                            PAUSE 5 NO-MESSAGE.
                            HIDE MESSAGE NO-PAUSE.

                            LEAVE.
                        END.
                    END.
                    ELSE
                    IF FRAME-VALUE = tel_estorna THEN
                    DO:
                        RUN busca_integralizacoes IN h-b1wgen0021 
                                                        (INPUT glb_cdcooper,
                                                         INPUT 1,
                                                         INPUT 0,
                                                         INPUT glb_cdoperad,
                                                         INPUT "ATENDA",
                                                         INPUT 1,
                                                         INPUT tel_nrdconta,
                                                         INPUT glb_dtmvtolt,
                                                        OUTPUT TABLE 
                                                             tt-lancamentos,
                                                        OUTPUT TABLE tt-erro).

                        IF RETURN-VALUE = "NOK" THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.

                            IF AVAIL tt-erro THEN
                                ASSIGN glb_dscritic = tt-erro.dscritic.
                            ELSE
                                ASSIGN glb_dscritic = "Nao foi possivel "     +
                                                      "buscar os lancamentos" +
                                                      " de integralizacao".

                            BELL.
                            MESSAGE glb_dscritic.

                            LEAVE.
                        END.

                        OPEN QUERY q-integralizacao FOR EACH tt-lancamentos.

                        IF  NUM-RESULTS("q-integralizacao") = 0  THEN
                        DO:
                            BELL.
                            MESSAGE "Nenhum lancamento encontrado.".
                        
                            CLOSE QUERY q-integralizacao.
                        
                            NEXT.
                        END.

                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                            UPDATE b-integralizacao 
                                   WITH FRAME f_lanc_integralizados.

                            LEAVE.
                        END.
                        
                        IF b-integralizacao:NUM-SELECTED-ROWS = 0 THEN
                        DO:
                            CLOSE QUERY q-integralizacao.

                            MESSAGE "Nenhum lancamento selecionado.".
                            PAUSE 2 NO-MESSAGE.
                            NEXT.
                        END.

                        RUN fontes/confirma.p (INPUT "",
                                              OUTPUT aux_confirma).                
    
                        IF aux_confirma <> "S" THEN
                            NEXT.

                        RUN fontes/pedesenha.p (INPUT glb_cdcooper,
                                                INPUT 2,
                                               OUTPUT aut_flgsenha,
                                               OUTPUT aut_cdoperad).

                        IF NOT aut_flgsenha THEN
                        DO:
                            MESSAGE "079 - Operacao nao efetuada.".
                            NEXT.
                        END.

                        EMPTY TEMP-TABLE tt-lanc-estorno.

                        DO aux_contador = 1 TO b-integralizacao:NUM-SELECTED-ROWS:

                            b-integralizacao:FETCH-SELECTED-ROW(aux_contador).

                            FIND CURRENT tt-lancamentos.

                            IF  AVAIL tt-lancamentos THEN
                            DO:
                                CREATE tt-lanc-estorno.
                                ASSIGN tt-lanc-estorno.nrdocmto = 
                                                        tt-lancamentos.nrdocmto
                                       tt-lanc-estorno.vllanmto = 
                                                        tt-lancamentos.vllanmto.
                            END.
                        END.

                        RUN estorna_integralizacao IN h-b1wgen0021 
                                                        (INPUT glb_cdcooper,
                                                         INPUT 1,
                                                         INPUT 0,
                                                         INPUT glb_cdoperad,
                                                         INPUT "ATENDA",
                                                         INPUT 1,
                                                         INPUT tel_nrdconta,
                                                         INPUT glb_dtmvtolt,
                                                         INPUT TABLE 
                                                             tt-lanc-estorno,
                                                        OUTPUT TABLE tt-erro).

                        IF RETURN-VALUE = "NOK" THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.

                            IF AVAIL tt-erro THEN
                                ASSIGN glb_dscritic = tt-erro.dscritic.
                            ELSE
                                ASSIGN glb_dscritic = "Nao foi possivel " +
                                                      "estornar os lancamentos.".

                            BELL.
                            MESSAGE glb_dscritic.

                            LEAVE.
                        END.

                        MESSAGE "Lancamento(s) estornado(s) com sucesso.".
                        PAUSE 5 NO-MESSAGE.
                        HIDE MESSAGE NO-PAUSE.
                    END.
                END.
             END.
             
    END. /* Fim do DO WHILE TRUE */
        
    HIDE FRAME f_capital NO-PAUSE.

END PROCEDURE.

PROCEDURE impressao_plano_capital:

    DEF  INPUT PARAM par_tipo AS CHAR                               NO-UNDO.

    DEF VAR aux_nmendter AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                    NO-UNDO.

    DEF VAR rel_dsaniver AS CHAR                                    NO-UNDO.

    DEF VAR aux_dscomand AS CHAR                                    NO-UNDO.

    DEF VAR par_flgrodar AS LOGI INIT TRUE                          NO-UNDO.
    DEF VAR par_flgfirst AS LOGI INIT TRUE                          NO-UNDO.
    DEF VAR par_flgcance AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgescra AS LOGI                                    NO-UNDO.

    DEF VAR tel_dsimprim AS CHAR FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
    DEF VAR tel_dscancel AS CHAR FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.
    DEF VAR aux_dsprepla AS CHAR FORMAT "x(80)"                     NO-UNDO.

    DEF VAR rel_vlprepla AS DECI                                    NO-UNDO.

    DEF VAR aux_texto000 AS CHAR FORMAT "x(54)"                     NO-UNDO.
    DEF VAR aux_texto001 AS CHAR FORMAT "x(54)"                     NO-UNDO.
    DEF VAR aux_texto002 AS CHAR FORMAT "x(54)"                     NO-UNDO.
    DEF VAR aux_texto003 AS CHAR FORMAT "x(54)"                     NO-UNDO.
    DEF VAR aux_vlcorfix AS CHAR FORMAT "x(10)"                     NO-UNDO.

    FORM 
        SKIP(3)
        tt-autorizacao.nmextcop AT 18 FORMAT "x(50)" 
        SKIP
        tt-autorizacao.nrdocnpj AT 29 FORMAT "x(25)"
        SKIP(3)
        WITH NO-BOX NO-LABELS FRAME f_cooperativa.

    FORM 
        SKIP(3)
        tt-cancelamento.nmextcop AT 18 FORMAT "x(50)" 
        SKIP
        tt-cancelamento.nrdocnpj AT 29 FORMAT "x(25)"
        SKIP(3)
        WITH NO-BOX NO-LABELS FRAME f_cooperativa_cancel.

    FORM 
        "TERMO DE CANCELAMENTO DE DEBITO MENSAL PARA AUMENTO DE CAPITAL" AT 9
        SKIP
        "==============================================================" AT 9
        SKIP(3)
        crapass.nrdconta AT  2 FORMAT "zzzz,zzz,9" LABEL "Conta/dv"
        tt-cancelamento.nrcancel AT 27 FORMAT "zzz,zz9" LABEL "Numero do Plano"
        tt-cancelamento.vlcancel AT 57 FORMAT "zzzz,zzz,zz9.99" LABEL "Valor"
        SKIP(1)
        tt-cancelamento.nmprimtl AT  1 FORMAT "x(40)" LABEL "Associado"
        rel_dsaniver     AT 62 FORMAT "x(17)" NO-LABEL
        SKIP(4)
        "Solicito pela presente, o cancelamento da autorizacao de debito"
        "mensal em conta-" 
        SKIP
        "corrente para aumento de capital sob o numero"
        tt-cancelamento.nrctrpla FORMAT "zzz,zz9" ", efetuado em"
        tt-cancelamento.dtinipla FORMAT "99/99/9999" "."
        SKIP(3)
        WITH NO-BOX SIDE-LABELS NO-LABELS FRAME f_cancelamento.

    FORM 
        SKIP(5)
        tt-autorizacao.nmcidade FORMAT "X(15)" 
        SPACE(1) 
        tt-autorizacao.cdufdcop FORMAT "x(2)" SPACE(0) ","
        glb_dtmvtolt FORMAT "99/99/9999" "." 
        SKIP(5)
        "____________________________________  " AT 3
        "____________________________________"  SKIP
        tt-autorizacao.nmprimtl AT 3 FORMAT "x(36)" NO-LABEL
        tt-autorizacao.nmrescop[1] AT 42 FORMAT "x(36)" SKIP
        tt-autorizacao.nmrescop[2] AT 42 FORMAT "x(36)"
        WITH NO-BOX NO-LABELS FRAME f_assina.

    FORM 
        SKIP(5)
        tt-cancelamento.nmcidade FORMAT "X(15)" 
        SPACE(1) 
        tt-cancelamento.cdufdcop FORMAT "x(2)" SPACE(0) ","
        glb_dtmvtolt FORMAT "99/99/9999" "." 
        SKIP(5)
        "____________________________________  " AT 3
        "____________________________________"  SKIP
        tt-cancelamento.nmprimtl AT 3 FORMAT "x(36)" NO-LABEL
        tt-cancelamento.nmrescop AT 42 FORMAT "x(36)"
        WITH NO-BOX NO-LABELS FRAME f_assina_cancel.

    FORM 
        "AUTORIZACAO DE DEBITO EM CONTA-CORRENTE PARA AUMENTO DE CAPITAL" AT 9
        SKIP
        "===============================================================" AT 9
        SKIP(3)
        crapass.nrdconta AT  2 FORMAT "zzzz,zzz,9" LABEL "Conta/dv"
        tt-autorizacao.nrctrpla AT 27 FORMAT "zzz,zz9" LABEL "Numero do Plano"
        tt-autorizacao.vlprepla AT 57 FORMAT "zzzz,zzz,zz9.99" LABEL "Valor"
        SKIP(1)
        tt-autorizacao.nmprimtl AT  1 FORMAT "x(40)" LABEL "Associado"
        rel_dsaniver            AT 62 FORMAT "x(17)" NO-LABEL
        SKIP(4)
        "O associado acima qualificado  autoriza  a  realizacao do  debito mensal  em sua" SKIP 
        "conta  corrente  de  deposito  a  vista,  no  valor  de"
        "R$ "         AT 63
        rel_vlprepla  FORMAT "zzz,zzz,zz9.99" NO-LABEL  AT 67 SKIP
        aux_dsprepla         FORMAT "x(80)"          NO-LABEL        SKIP
        "a partir do mes de" tt-autorizacao.dsmesano FORMAT "x(9)" NO-LABEL
        ", para integralizacao de Cotas de CAPITAL."
        SKIP(4)
        WITH NO-BOX SIDE-LABELS NO-LABELS FRAME f_autoriza.

    FORM
        "Este valor sera reajustado apos o periodo de 12 meses, com base em:" SKIP
        aux_texto000 FORMAT "x(66)" NO-LABEL SKIP
        aux_texto001 FORMAT "x(54)" NO-LABEL SKIP(1)
        aux_texto002 FORMAT "x(54)" NO-LABEL SKIP(1)
        aux_texto003 FORMAT "x(54)" NO-LABEL SKIP(4)
        WITH NO-BOX SIDE-LABELS NO-LABELS FRAME f_reajuste.
        

    FORM 
        "A presente autorizacao, serve inclusive como instrumento legal de "
        "subscricao  e" SKIP
        "integralizacao de capital na Cooperativa de Credito, que se  dara "
        "concomitante-" SKIP
        "mente, no momento do debito em conta-corrente."
        SKIP(4)
        WITH NO-BOX FRAME f_legal.

    FORM 
        "O debito se dara sempre na data em que ocorrer o credito do"
        "salario, limitado ao" 
        SKIP
        "saldo liquido do mesmo."
        SKIP(4)
        WITH NO-BOX FRAME f_salario.

    FORM 
        "O debito sera efetuado desde que haja provisao de fundos na conta corrente."
        SKIP
        "Caso a data  estabelecida  para  debito cair no  sabado, domingo ou  feriado, o" SKIP
        "lancamento sera efetuado no primeiro dia util subsequente."
        SKIP(4)
        WITH NO-BOX FRAME f_saldo.

    FORM 
        "Aguarde... Imprimindo contrato!"
        WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

    INPUT THROUGH basename `tty` NO-ECHO.

    SET aux_nmendter WITH FRAME f_terminal.

    INPUT CLOSE.

    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

    ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex"
           rel_dsaniver = "".
    
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 66.

    /* Configura a impressora para 1/6" */
    PUT STREAM str_1 CONTROL "\0332\033x0\022" NULL.

    IF  par_tipo = "IMPRIMIR"  THEN
        DO:
            RUN autorizar-novo-plano IN h-b1wgen0021 
                        (INPUT glb_cdcooper,
                         INPUT 0,       /* agencia  */ 
                         INPUT 0,       /* nrdcaixa */
                         INPUT glb_cdoperad, 
                         INPUT "ATENDA", 
                         INPUT 1, /* Ayllos */
                         INPUT tel_nrdconta, 
                         INPUT 1,       /* idseqttl */ 
                        OUTPUT TABLE tt-erro,
                        OUTPUT TABLE tt-autorizacao).
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    OUTPUT STREAM str_1 CLOSE.
                    
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    
                    IF  AVAILABLE tt-erro  THEN
                        glb_dscritic = tt-erro.dscritic.
                    ELSE
                        glb_dscritic = "Erro no carregamento da impressao.".
                        
                    BELL.
                    MESSAGE glb_dscritic.
                    
                    RETURN "NOK".
                END.

            FIND FIRST tt-autorizacao NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-autorizacao  THEN
                DO:
                    IF tt-autorizacao.cdtipcor = 0 THEN
                        ASSIGN aux_texto000 = "(   ) Correcao monetaria pela variacao  do  IPCA (Indice  Nacional"
                               aux_texto001 = "      de Precos ao Consumidor Amplo);"
                               aux_texto002 = "(   ) Valor fixo;"
                               aux_texto003 = "( X ) Sem reajuste automatico de valor.".
                    ELSE
                    IF tt-autorizacao.cdtipcor = 1 THEN
                        ASSIGN aux_texto000 = "( X ) Correcao monetaria pela variacao  do  IPCA (Indice  Nacional"
                               aux_texto001 = "      de Precos ao Consumidor Amplo);"
                               aux_texto002 = "(   ) Valor fixo;"
                               aux_texto003 = "(   ) Sem reajuste automatico de valor.".
                    ELSE
                    DO:
                        IF INDEX(STRING(tt-autorizacao.vlcorfix), ",") > 0 THEN
                            ASSIGN aux_vlcorfix = STRING(tt-autorizacao.vlcorfix).
                        ELSE
                            ASSIGN aux_vlcorfix = STRING(tt-autorizacao.vlcorfix) +
                                                  ",00".

                        ASSIGN aux_texto000 = "(   ) Correcao monetaria pela variacao  do  IPCA (Indice  Nacional"
                               aux_texto001 = "      de Precos ao Consumidor Amplo);"
                               aux_texto002 = "( X ) Valor fixo de R$ " + aux_vlcorfix + ";"
                               aux_texto003 = "(   ) Sem reajuste automatico de valor.".
                    END.

                    DISPLAY STREAM str_1 
                                   tt-autorizacao.nmextcop
                                   tt-autorizacao.nrdocnpj
                                   WITH FRAME f_cooperativa.
         
                    IF  NOT tt-autorizacao.flgpagto  THEN
                        rel_dsaniver = "Dia do Debito: " +
                                       tt-autorizacao.diadebit.
                                          
                    ASSIGN rel_vlprepla = tt-autorizacao.vlprepla
                           aux_dsprepla = "(" + tt-autorizacao.dsprepla[1]
                                          + ")".
                    DISPLAY STREAM str_1                                     
                                   crapass.nrdconta  
                                   tt-autorizacao.nrctrpla
                                   tt-autorizacao.vlprepla
                                   tt-autorizacao.nmprimtl
                                   rel_dsaniver      
                                   rel_vlprepla
                                   aux_dsprepla
                                   tt-autorizacao.dsmesano
                                   WITH FRAME f_autoriza.

                    DISPLAY STREAM str_1
                                   aux_texto000
                                   aux_texto001
                                   aux_texto002
                                   aux_texto003
                                   WITH FRAME f_reajuste.

/*                      VIEW STREAM str_1 FRAME f_legal. */

                    IF  NOT tt-autorizacao.flgpagto  THEN
                        VIEW STREAM str_1 FRAME f_saldo.
                    ELSE
                        VIEW STREAM str_1 FRAME f_salario.

                    DISPLAY STREAM str_1
                                   tt-autorizacao.nmcidade
                                   tt-autorizacao.cdufdcop
                                   glb_dtmvtolt  
                                   tt-autorizacao.nmprimtl
                                   tt-autorizacao.nmrescop[1]
                                   tt-autorizacao.nmrescop[2]
                                   WITH FRAME f_assina.

                END.
        END.
    ELSE
    IF  par_tipo = "CANCELAR"  THEN
        DO:
            RUN cancelar-plano-atual IN h-b1wgen0021 
                    (INPUT glb_cdcooper,
                     INPUT 0,       /* agencia  */ 
                     INPUT 0,       /* nrdcaixa */
                     INPUT glb_cdoperad, 
                     INPUT "ATENDA", 
                     INPUT 1, /* Ayllos */
                     INPUT tel_nrdconta, 
                     INPUT 1,       /* idseqttl */ 
                     OUTPUT TABLE tt-erro,
                     OUTPUT TABLE tt-cancelamento).
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    OUTPUT STREAM str_1 CLOSE.
                    
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    
                    IF  AVAILABLE tt-erro  THEN
                        glb_dscritic = tt-erro.dscritic.
                    ELSE
                        glb_dscritic = "Erro no carregamento da impressao.".
                        
                    BELL.
                    MESSAGE glb_dscritic.
                
                    RETURN "NOK".
                END.
          
            FIND FIRST tt-cancelamento NO-LOCK NO-ERROR.
            
            IF  AVAILABLE tt-cancelamento  THEN
                DO:
                    DISPLAY STREAM str_1 
                                   tt-cancelamento.nmextcop
                                   tt-cancelamento.nrdocnpj
                                   WITH FRAME f_cooperativa_cancel.
 
                    DISPLAY STREAM str_1
                            crapass.nrdconta         tt-cancelamento.nrctrpla
                            tt-cancelamento.vlcancel tt-cancelamento.nmprimtl
                            rel_dsaniver             tt-cancelamento.nrcancel
                            tt-cancelamento.dtinipla
                            WITH FRAME f_cancelamento.
                 
                    DISPLAY STREAM str_1
                            tt-cancelamento.nmcidade
                            tt-cancelamento.cdufdcop
                            glb_dtmvtolt  tt-cancelamento.nmprimtl 
                            tt-cancelamento.nmrescop
                            WITH FRAME f_assina_cancel.
                END.
        END.

    OUTPUT STREAM str_1 CLOSE.

    VIEW FRAME f_aguarde.
    
    PAUSE 3 NO-MESSAGE.
    
    HIDE FRAME f_aguarde NO-PAUSE.

    { includes/impressao.i }

END PROCEDURE.

PROCEDURE exibe_conta_investimento:

    DEF INPUT PARAM par_flgextra AS LOGI                            NO-UNDO.
                                                                  
    DEF VAR aux_vlsldant AS DECI                                    NO-UNDO.
    DEF VAR aux_vlresgat AS DECI FORMAT "zzz,zzz,zzz,zz9.99"        NO-UNDO.
    
    DEF VAR aux_nrdocmto AS INTE FORMAT "zz,zzz,zz9"                NO-UNDO.

    DEF VAR aux_nmarqimp AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmendter AS CHAR FORMAT "x(20)"                     NO-UNDO.
    DEF VAR aux_dscomand AS CHAR                                    NO-UNDO.
        
    DEF VAR aux_flgescra AS LOGI                                    NO-UNDO.
    
    DEF VAR par_flgrodar AS LOGI                                    NO-UNDO.
    DEF VAR par_flgfirst AS LOGI                                    NO-UNDO.
    DEF VAR par_flgcance AS LOGI                                    NO-UNDO.

    DEF VAR rel_nrmodulo AS INTE FORMAT "9"                         NO-UNDO.
    
    DEF VAR rel_vldiario AS DECI                                    NO-UNDO.
    
    DEF VAR rel_dshistor AS CHAR                                    NO-UNDO.
    DEF VAR rel_nmrelato AS CHAR FORMAT "x(40)" EXTENT 5            NO-UNDO.
    DEF VAR rel_nmresemp AS CHAR FORMAT "x(15)"                     NO-UNDO.
    DEF VAR rel_nmmesref AS CHAR FORMAT "x(14)"                     NO-UNDO.
    DEF VAR rel_nmmodulo AS CHAR FORMAT "x(15)" EXTENT 5
                                 INIT ["DEP. A VISTA   ","CAPITAL        ",
                                       "EMPRESTIMOS    ","DIGITACAO      ",
                                       "GENERICO       "]           NO-UNDO.
    
    DEF VAR tel_dsimprim AS CHAR FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
    DEF VAR tel_dscancel AS CHAR FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                    NO-UNDO.

    /* tipo de extrato (1=Simplificado, 2=Detalhado) */
    DEF  VAR aux_intpextr AS INTE INIT 0                            NO-UNDO.

    DEF BUTTON btn-resgates     LABEL "Saque".
    DEF BUTTON btn-cancelamento LABEL "Cancelamento".
    DEF BUTTON btn-imprime      LABEL "Imprime Extrato".
    
    DEF QUERY q-lanctos FOR tt-extrato_inv.
                        
    DEF BROWSE b-lanctos QUERY q-lanctos
        DISPLAY tt-extrato_inv.dtmvtolt   LABEL "Data"       
                tt-extrato_inv.dshistor   LABEL "Historico"  FORMAT "x(28)"
                tt-extrato_inv.cdbloque   LABEL "S"          FORMAT "x(1)"
                tt-extrato_inv.nrdocmto   LABEL "Documento"  
                                                 FORMAT "zzzzzzzz9"
                tt-extrato_inv.indebcre   LABEL "D/C"
                tt-extrato_inv.vllanmto   LABEL "Valor"
                                                 FORMAT "zzzz,zzz,zz9.99-"
                WITH 5 DOWN WIDTH 78 CENTERED NO-LABELS OVERLAY
                       TITLE " Extrato Conta Investimento ".

    FORM 
         b-lanctos               HELP "Use as SETAS para navegar"
         SKIP
         btn-resgates     AT 10  HELP "Pressione ENTER para selecionar"
         btn-cancelamento AT 28  HELP "Pressione ENTER para selecionar"
         btn-imprime      AT 53  HELP "Pressione ENTER para selecionar"
         SKIP(1)
         WITH ROW 10 WIDTH 78 CENTERED NO-LABELS SIDE-LABELS OVERLAY 
              NO-BOX FRAME f_browse.
          
    FORM 
         SKIP(1)
         aux_vlresgat AT  5  LABEL "Valor do saque"
                             HELP  "Entre com o valor "
                             VALIDATE(aux_vlresgat > 0,"269 - Valor errado.")
         SKIP                   
         aux_nrdocmto AT 12  LABEL "Documento"
                             HELP  "Entre com o numero do documento"
         SKIP(1)
         WITH ROW 10 WIDTH 50 CENTERED SIDE-LABELS OVERLAY 
              TITLE COLOR NORMAL " Saque/Cancelamento " FRAME f_resg.
                                                                   
    FORM tt-extrato_inv.dtmvtolt AT   1 FORMAT "99/99/9999"   LABEL "DATA"
         tt-extrato_inv.dshistor AT  12 FORMAT "x(24)"        LABEL "HISTORICO"
         tt-extrato_inv.nrdocmto AT  37 FORMAT "zzzzzzzz9"    LABEL "DOCUMENTO"
         tt-extrato_inv.vllanmto AT  48 FORMAT "zzzzz,zz9.99" LABEL "VALOR"
         tt-extrato_inv.indebcre AT  61 FORMAT " x "          LABEL "D/C"
         tt-extrato_inv.vlsldtot AT  65 FORMAT "zzzz,zzz,zz9.99-"
                                        LABEL "          SALDO "
         WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_lanctos.
    
    ON CHOOSE OF btn-resgates IN FRAME f_browse DO:
    
        ASSIGN aux_vlresgat = 0.
       
        DO WHILE TRUE:          

            HIDE aux_nrdocmto IN FRAME f_resg.
            UPDATE aux_vlresgat WITH FRAME f_resg.
          
            ASSIGN aux_inconfir = 1.
          
            DO WHILE TRUE:
           
                EMPTY TEMP-TABLE tt-erro.
                EMPTY TEMP-TABLE tt-msg-confirma.
            
                RUN obtem-resgate IN h-b1wgen0020
                                          (INPUT glb_cdcooper,
                                           INPUT 0, /* p-cod-agencia */
                                           INPUT 0, /* p-nro-caixa */
                                           INPUT glb_cdoperad,
                                           INPUT "ATENDA",
                                           INPUT 1, /* Ayllos */
                                           INPUT tel_nrdconta,
                                           INPUT 1,     /* par_idseqttl */
                                           INPUT glb_dtmvtolt,
                                           INPUT aux_vlresgat,
                                           INPUT aux_inconfir,
                                          OUTPUT TABLE tt-erro,
                                          OUTPUT TABLE tt-msg-confirma).
    
                IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                   
                        IF  AVAILABLE tt-erro  THEN
                            glb_dscritic = tt-erro.dscritic.
                        ELSE
                            glb_dscritic = "Nao foi possivel efetuar o " +
                                          "resgate.".
                     
                        BELL.
                        MESSAGE glb_dscritic.
                     
                        LEAVE.
                    END.

                FIND FIRST tt-msg-confirma NO-LOCK NO-ERROR.
                 
                IF  AVAILABLE tt-msg-confirma  THEN
                    DO:
                        ASSIGN aux_confirma = "N".
                     
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                     
                            BELL.
                            MESSAGE tt-msg-confirma.dsmensag 
                                    UPDATE aux_confirma.

                            LEAVE.
                        
                        END.

                        IF  aux_confirma = "S"  THEN
                            DO:
                                RUN fontes/pedesenha.p (INPUT glb_cdcooper,
                                                        INPUT 2,
                                                       OUTPUT aux_flgsenha,
                                                       OUTPUT aux_cdoperad).
                         
                                IF  aux_flgsenha  THEN
                                    DO:
                                        ASSIGN aux_inconfir = 2.
                                        NEXT.
                                    END.
                            END.
                    END.

                LEAVE.
          
            END. /** Fim do DO WHILE TRUE **/
          
            LEAVE.
       
        END. /** Fim do DO WHILE TRUE **/ 
    END.
   
    ON CHOOSE OF btn-cancelamento IN FRAME f_browse DO:
    
        ASSIGN aux_nrdocmto = 0.
       
        DO WHILE TRUE: 
        
            HIDE aux_vlresgat IN FRAME f_resg.
            
            UPDATE aux_nrdocmto WITH FRAME f_resg.

            EMPTY TEMP-TABLE tt-erro.
          
            RUN obtem-cancelamento IN h-b1wgen0020
                                          (INPUT glb_cdcooper,
                                           INPUT 0, /* p-cod-agencia */
                                           INPUT 0, /* p-nro-caixa */
                                           INPUT glb_cdoperad,
                                           INPUT "ATENDA",
                                           INPUT 1, /* Ayllos */
                                           INPUT tel_nrdconta,
                                           INPUT 1,     /* par_idseqttl */
                                           INPUT glb_dtmvtolt,
                                           INPUT aux_nrdocmto,
                                          OUTPUT TABLE tt-erro).
    
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN glb_dscritic = tt-erro.dscritic.
                    ELSE
                        ASSIGN glb_dscritic = "Nao foi possivel efetuar o " +
                                              "cancelamento.".
             
                    BELL.
                    MESSAGE glb_dscritic.
                END.
          
            LEAVE.
        END.
    END.
   
    ON CHOOSE OF btn-imprime IN FRAME f_browse DO:
      
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            UPDATE aux_dtpesqui WITH FRAME f_mesref.
                                      
            IF  aux_dtpesqui = ?  THEN
                aux_dtpesqui = glb_dtmvtolt - DAY(glb_dtmvtolt) + 1.
            ELSE
            IF (MONTH(aux_dtpesqui) < aux_nrmesant  AND
                MONTH(aux_dtpesqui) <> 1)           OR
                aux_dtpesqui > glb_dtmvtolt         THEN
                DO:
                    glb_cdcritic = 13.
                    RUN fontes/critic.p.
                    glb_cdcritic = 0.
                    
                    BELL.
                    MESSAGE glb_dscritic.
                    
                    NEXT.
                END.

            LEAVE.

        END.

        HIDE FRAME f_mesref NO-PAUSE.

        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
            LEAVE.
     
        ASSIGN par_flgrodar = TRUE
               par_flgfirst = TRUE.
             
        INPUT THROUGH basename `tty` NO-ECHO.
            SET aux_nmendter WITH FRAME f_terminal.
        INPUT CLOSE.

        aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                              aux_nmendter.

        EMPTY TEMP-TABLE tt-erro.

        RUN Gera_Impressao IN h-b1wgen0112
                (INPUT glb_cdcooper, 
                 INPUT crapass.cdagenci, 
                 INPUT 0, 
                 INPUT 1, 
                 INPUT glb_nmdatela, 
                 INPUT glb_dtmvtolt, 
                 INPUT glb_dtmvtopr, 
                 INPUT glb_nmdatela, 
                 INPUT glb_inproces, 
                 INPUT glb_cdoperad, 
                 INPUT aux_nmendter, 
                 INPUT par_flgrodar, 
                 INPUT tel_nrdconta, 
                 INPUT 1, 
                 INPUT 7, 
                 INPUT aux_dtpesqui, 
                 INPUT TODAY, 
                 INPUT FALSE,                                               
                 INPUT 0,                                                   
                 INPUT 0,                                                   
                 INPUT 0,                                                   
                 INPUT 0,                                                   
                 INPUT 0,                                                   
                 INPUT TRUE,    
                 INPUT aux_intpextr,
                OUTPUT aux_nmarqimp,                                        
                OUTPUT aux_nmarqpdf,                                        
                OUTPUT TABLE tt-erro).                                      
                                                                            
        IF  RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
           
                IF  AVAILABLE tt-erro  THEN
                    glb_dscritic = tt-erro.dscritic.
                ELSE
                    glb_dscritic = "Nao foi possivel efetuar a " +
                                   "impressao.".
             
                BELL.
                MESSAGE glb_dscritic.
             
                LEAVE.
            END.

        { includes/impressao.i }
   
    END.

    IF  NOT par_flgextra THEN 
        DO:
            /*** Apenas para exibir total CI na tela principal do ATENDA ***/
            RUN obtem-saldo-investimento IN h-b1wgen0020
                                          (INPUT glb_cdcooper,
                                           INPUT 0, /* p-cod-agencia */
                                           INPUT 0, /* p-nro-caixa */
                                           INPUT glb_cdoperad,
                                           INPUT "ATENDA",
                                           INPUT 1, /* Ayllos */
                                           INPUT tel_nrdconta,
                                           INPUT 1,     /* par_idseqttl */
                                           INPUT glb_dtmvtolt,
                                           OUTPUT TABLE tt-saldo-investimento).
    
            FIND FIRST tt-saldo-investimento NO-LOCK NO-ERROR.
       
            IF  AVAILABLE tt-saldo-investimento  THEN
                ASSIGN aux_saldo_ci = tt-saldo-investimento.vlsldinv.
            ELSE
                ASSIGN aux_saldo_ci = 0.
        END.
    ELSE 
        DO:
            UPDATE aux_dtpesqui WITH FRAME f_data.
       
            IF  aux_dtpesqui = ?  THEN
                aux_dtpesqui = glb_dtmvtolt.
                      
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
                RUN extrato_investimento IN h-b1wgen0020
                                  (INPUT glb_cdcooper,
                                   INPUT 0, /* p-cod-agencia */
                                   INPUT 0, /* p-nro-caixa */
                                   INPUT glb_cdoperad,
                                   INPUT "ATENDA",
                                   INPUT 1, /* Ayllos */
                                   INPUT tel_nrdconta,
                                   INPUT 1,     /* par_idseqttl */
                                   INPUT aux_dtpesqui,
                                   INPUT DATE(1,1,9999), /* dt fim */
                                   INPUT TRUE,
                                  OUTPUT aux_vlsldant,
                                  OUTPUT TABLE tt-extrato_inv).
                                  
                OPEN QUERY q-lanctos FOR EACH tt-extrato_inv 
                                              BY tt-extrato_inv.dtmvtolt
                                                 BY tt-extrato_inv.nrdocmto
                                                    BY tt-extrato_inv.indebcre.
                
                ENABLE b-lanctos  btn-resgates  btn-cancelamento  
                       btn-imprime  WITH FRAME f_browse.
                
                APPLY "ENTRY" TO btn-resgates IN FRAME f_browse.

                WAIT-FOR CHOOSE OF btn-resgates       OR
                         CHOOSE OF btn-cancelamento   OR
                         CHOOSE OF btn-imprime.
            
            END.
        END.

        
END PROCEDURE.

PROCEDURE obtem-mensagens-alerta:

    IF  NOT VALID-HANDLE(h-b1wgen0031) THEN
        RUN sistema/generico/procedures/b1wgen0031.p
            PERSISTENT SET h-b1wgen0031.

    RUN obtem-mensagens-alerta IN h-b1wgen0031
        ( INPUT glb_cdcooper,
          INPUT 0,             /* nragenci */
          INPUT 0,             /* nrdcaixa */
          INPUT glb_cdoperad,
          INPUT "ATENDA",
          INPUT 1,             /* Ayllos   */
          INPUT tel_nrdconta,
          INPUT 1,             /* idseqttl */
          INPUT glb_dtmvtolt,
          INPUT glb_dtmvtopr,
          INPUT glb_dtmvtoan,
          INPUT glb_inproces,
         OUTPUT TABLE tt-erro,
         OUTPUT TABLE tt-mensagens-atenda ).

    IF VALID-HANDLE(h-b1wgen0031) THEN
        DELETE OBJECT h-b1wgen0031.
    
    IF  RETURN-VALUE <> "OK" THEN 
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN 
               DO:
                  MESSAGE tt-erro.dscritic.
                  RETURN "NOK".
               END.
        END.
     
    FOR EACH tt-mensagens-atenda BY tt-mensagens-atenda.nrsequen:

        MESSAGE tt-mensagens-atenda.dsmensag.

        READKEY.
        IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            NEXT.
    END.
    
    HIDE MESSAGE NO-PAUSE.
    
    

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/








