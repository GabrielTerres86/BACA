CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS005(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa Solicitada
                                             ,pr_flgresta  IN PLS_INTEGER           --> Flag 0/1 para utilizar restart na chamada
                                             ,pr_cdagenci  IN PLS_INTEGER DEFAULT 0  --> Código da agência, utilizado no paralelismo
                                             ,pr_idparale  IN PLS_INTEGER DEFAULT 0  --> Identificador do job executando em paralelo.
                                             ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                             ,pr_dscritic OUT varchar2) IS          --> Texto de erro/critica encontrada
  BEGIN

  /* .............................................................................

   Programa: pc_crps005                       Antigo Fontes/crps005.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Novembro/91.                    Ultima atualizacao: 18/03/2019
   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 002
               Listar os relatorios de saldos.

   Alteracoes: 04/01/2000 - Nao gerar pedido de impressao (Deborah).
                            Alterado diretorio /micros.

               24/01/2000 - Tratar pedidos de impressao para a laser (Deborah).

               28/01/2000 - Gerar pedido do relatorio 225 para laser (Deborah).

               17/07/2000 - Alterar historicos contabeis (Odair)

               11/10/2000 - Alterar para 20 posicoes fone (Margarete/Planner).

               27/03/2001 - Desconsiderar o saldo bloqueado na listagem de
                            negativos dos funcionarios/conselheiros (Deborah).

               24/04/2001 - Alterado o centro de custos para apenas 2 casas
                            (Edson).

               06/06/2001 - Modificacao dos lancamentos de adiantamentos
                            a depositantes (Deborah).

               13/06/2002 - Modificar o tamanho do PAGE-SIZE de 84 p/ 80
                            (Ze Eduardo).

               07/03/2003 - Alterado relatorio 225 para 1 via (Deborah).

               22/07/2003 - Alterado para nao somar o limite de credito no
                            total do utilizado se estiver em CL (Deborah).

               12/08/2003 - Mudanca no calculo do utilizado (Deborah).

               12/09/2003 - No relatorio 030, foi adicionado o total por PAC
                            (Fernando).

               15/12/2003 - Alterado para nao gerar mais lancamentos
                            contabeis de Conta Corrente (Mirtes).

               06/01/2004 - Alterado resumo(rel.) composicao saldos(Mirtes)

               01/03/2004 - Alterado p/nao gerar lancamento Adiant.Depos(Mirtes)

               02/03/2004 - Alterado para qdo Saldos Cheques Admnistrativos
                            /Cheque Esp. zerados, nao gerar movto(Mirtes)

               22/04/2004 - Acrescentar mais uma via no rel. 225 (Eduardo)

               16/08/2004 - REFORMULACAO DE TODO O PROGRAMA (Ze Eduardo).

               09/09/2004 - Inclusao do campo "DD" no relatorio "crrl030"
                            (Julio)

               24/09/2004 - Inclusao do saldo da conta investimento (Evandro).

               29/09/2004 - Gravacao de dados na tabela gntotpl e gninfpl
                            do banco generico, para relatorios gerenciais
                            (Junior).

               01/10/2004 - Implementeado rel.372(Saldos Conta Investimento)
                            (Mirtes)

               16/11/2004 - Implementado o saldo do MICRO-CREDITO (Edson).

               02/12/2004 - Efetuar contabilizacao diferenciada para a CECRED
                            (Edson).

               06/12/2004 - Alteracao do arquivo para Contabilidade (Ze).

               17/02/2005 - Incluidos tipos de conta Integracao(12/13/14/15)
                                                           (Mirtes).

               21/02/2005 - Incluido PAC e totais por PAC no relatorio 55
                            (Edson).

               29/03/2005 - Rel. Ger.: Adicionar campo para armazenar valor de
                            cheque administrativo (Junior).

               11/04/2005 - Rel. Ger.: Gravacao de dados por PAC, substituindo
                            gravacao de dados por Cooperativa (Junior).

               22/04/2005 - Acerto na gravacao do campo gninfpl.vltotsdb, para
                            Relatorios Gerenciais (Junior).

               20/05/2005 - Mudado o crrl055 para gerar por PAC(Evandro).

               20/07/2005 - Script CriaPDF.sh nao respeitar o crapvia (Julio)

               11/08/2005 - Alterado para mostrar separadamnete no relatorio
                            225 os Estouros de contas com tipo de vinculo
                            diferente de Cooperado (Diego).

               16/08/2005 - Alterado para exibir no final do relatorio 225
                            o numero do PAC ao lado do nome (Diego).


               01/09/2005 - Somente calcular saldo emprestimo quando nao for
                            processo mensal(Mirtes)

               20/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               03/10/2005 - Alterado para imprimir apenas 1 copia do relatorio
                            225 para CredCrea (Diego).

               14/10/2005 - Alterado relatorio 225 para informar quando nao
                            houver registros na RELACAO DE ESTOUROS
                            (FUNCION./ESTAGIAR./CONSELH.)(Diego).
               19/10/2005 - Qdo relacao estouros funcionarios/estag/conselh.
                            assumir valor de referencia 0.01(Mirtes)

               24/11/2005 - Enviar para a CECRED relatorio crrl225.lst quando
                            houver estouro de conta dos funcionarios da CECRED
                            (Edson).

               09/12/2005 - Acrescentado listagem de saldos conta poupanca > 4
                            no relatorio crrl007 (Diego).

               28/03/2006 - Retirar a verificacao no crapvia, para copia dos
                            relatorios para o servidor Web (Junior).

               12/04/2006 - Alterado valor(parametro) dos SALDOS CONTA
                            POUPANCA da Viacredi, para buscar >= 15 (Diego).

               16/05/2006 - Alterado numero de vias dos relatorios crrl030 e
                            crrl225 para Viacredi (Diego).

               30/05/2006 - Alterado numero de vias do relatorio crrl225 para
                            Viacredi (Elton).

               31/05/2006 - Desenvolver o Gerencial a Credito e a Debito (Ze).

               06/06/2006 - Alimentar o campo cdcooper das tabelas:
                            craptab, crapage, crapass, crapsld, craplcm,
                            crapsli, crapepr (David).

               23/06/2006 - Incluido campo de observacao no relatorio crrl007.

               30/06/2006 - Ajustes para melhorar a performance na leitura do
                            crapsli (Edson).

               21/07/2006 - Incluido condicao glb_cdcooper <> 1 nas linhas 938
                            e 940 (David).

               16/04/2007 - Leitura da tabela craptfc para impressao de
                            telefones (David).

               28/08/2007 - Tratar historicos de micro creditos pelo novo campo
                            cdusolcr (Guilherme).

               04/09/2007 - Ler crapepr no inicio para nao desprezar contas
                            com micro credito (Magui).

               11/10/2007 - Mostrar total fisica e juridica por linha
                            e emprestimos atrasados a mais de um ano(Guilherme)

               06/12/2007 - Mostrar saldo atualizado na listagem dos
                            emprestimos atrasados a mais de um ano (Magui).

               28/12/2007 - Somente gerar relatorio geral crrl055_99 quando
                            existirem os relatorios por pac (David).

               02/01/2008 - Tratamento na geracao do relatorio geral
                            crrl055_99 (David).

               21/02/2008 - Mostrar turno da crapttl.cdturnos (Gabriel)
                          - Separar linhas de credito PNMPO (Evandro).

               18/03/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)

               17/06/2008 - Detalhamento das linhas PNMPO crrl006(Guilherme);
                          - Incluidas informacoes COMP DIA BB e COMP DIA
                            BANCOOB no relatorio crrl007 (Evandro).

               01/09/2008 - Alteracao CDEMPRES (Kbase).

               12/11/2008 - Melhoria de performance na craplcm (Evandro).

               02/09/2009 - Aumentar formato de vlcompbb e vlcmpbcb da tabela
                            crat007 para nao estourar (Gabriel).

               20/11/2009 - Considera linhas de micro-credito que contenham na
                            descricao "BNDES", como sendo PNMPO (Elton).

               03/03/2010 - Aumentar formato do geral do saldo total do
                            crrl007 (Gabriel)
                            Alterar a leitura da craplcm para os cheques
                            compensados do dia .

               16/03/2010 - Alterado para ordenar os saldos por origem do
                            recurso. (gati - Daniel)

               29/04/2010 - Alterado para incluir totais por origem do
                            recurso. (gati - Sandro)

               23/08/2010 - Inclusao cheques CECRED no campo OBS referente
                            ao saldo devedor (Ze).

               06/09/2010 - Gerar crapbnd com informacoes contidas no
                            relatorio crrl006. Tarefa 34668 (Henrique).

               04/01/2011 - Acertar atualizacao do crapbnd (Magui).

               20/01/2011 - Criado novo form f_titulo_saldisp (Adriano)

               28/01/2011 - Criar crapbnd quebrando por nrdconta (Guilherme).

               02/02/2011 - Alteracao do format dos campos de limite (Henrique)

               06/05/2011 - Nao criar quebra de conta do BNDES na CECRED pois
                            esta sendo criado nas singulares (Guilherme).

               06/05/2011 - Mudanca no layout do crrl007. Retirar os
                            comentarios desnecessarios (Gabriel)

               26/05/2011 - Ajuste na listagem do crrl007 (Gabriel)

               08/06/2011 - Ajuste na leitura da crapcst (Gabriel).

               19/07/2011 - Alterado para emissao 1 via relatorio 225(Mirtes)

               27/07/2011 - Desprezar lanc. do hist. 21 ou 26 e lote 4500 -
                            relatorio crrl007 - Tarefa 41352 (Ze).

               11/11/2011 - Alterações para gerar arquivo .txt com cópia do
                            relatório crrl007 em micros/viacredi/Tiago
                            (Oscar/Lucas).

               05/01/2012 - Renomeado arquivo "crrl005" para "slddev" (Tiago).

               13/01/2012 - Melhoria de desempenho (Gabriel).

               14/05/2012 - Incluido tratamento de LOCK na atualizacao do
                            registro da tabela crapbnd. (Fabricio)

               21/06/2012 - Substituido gncoper por crapcop (Tiago).

               23/11/2012 - Alterado para tratar o novo emprestimo no include
                            crps398.i incluido rotina para calculo de dias em
                            atraso. (Oscar)

               15/03/2013 - Removido email do Tavares e incluído emails do
                            Jose Carlos e Ricardo para recebimento do
                            relatorio 225. (Irlan)

               05/04/2013 - No relatorio crrl006_99 incluido form para listar
                            contratos que estao em atraso ate 59 dias.
                          - Incluir novo stream que gera arquivo em txt com
                            informacoes dos contratos (Lucas R.).

               31/05/2013 - Softdesk 66690 - incluída a geração do arquivo
                            slddev.txt para a creditextil (Carlos)

               08/07/2013 - Adicionar no relatório crrl006 o valor bloqueado judicialmente - Passig

               07/08/2013 - Adicionado geracao do arquivo slddev para coop 16
                            Altovale (Tiago).

               08/08/2013 - Alterado relatorio crrl006_99 para listar contratos
                            atrasados com mais de 59 dias (Tiago).

               23/08/2013 - Conversão Progress -> Oracle - Alisson (AMcom)

               25/09/2013 - Ajuste na chamada da GENE0002.pc_solicita_relato_arquivo
                            para passar pr_cdrelato => 005, do contrário ocorre erro
                            (Marcos-Supero)

               21/08/2013 - Incluido a chamada da procedure "atualiza_conta"
                            para todas as contas que entrarem em AD.
                            Alteração Progress: James  Ajuste Oracle: Renato - Supero

               22/08/2013 - Ajuste no relatorio 006 ref. a Bloq. Judicial.
                            Alteração Progress: Ze     Ajuste Oracle: Renato - Supero

               07/10/2013 - Alteração nos tratamentos de critica e saídas
                            de rotinas ( Renato - Supero )

               16/10/2013 - Alteração para gerar tags vazias quando não houverem
                            dados (Douglas Pagel).

               18/11/2013 - Ajustes após execução das validações( Renato - Supero )

               21/11/2013 - Incluir alterações realizadas no Progress ( Renato - Supero )
                          - Alterado para nao utlizar o telefone da crapass (Reinert).
                          - Nova forma de chamar asagências, de PAC agora a escrita
                            será PA (André Euzébio - Supero).
                          - Atribuido valor 0 no campo crapcyb.cdagenci (James)

               09/12/2013 - Incluir alterações realizadas no Progress ( Renato - Supero )
                          - Alterado totalizador de99 para 999 e impressao de
                            registros com PAs alem de 99. (Reinert)
                          - Ajuste para nao atualizar as flag de judicial e
                            vip no cyber. (James)

               17/12/2013 - Incluir alterações realizadas no Progress ( Renato - Supero )
                          - Ajustes de performance na leitura da tabela crapcst (Rodrigo)
                          - Ajustes no AD enviado para o CYBER não estava reativando alguns
                            contratos (Oscar).

               18/12/2013 - Adicionar >= na regra de envio para o CYBER.  (Oscar).

               06/01/2014 - Remover o campo crapass.nrfonres do fonte, pois o mesmo foi
                            excluído da tabela e remover o campo rw_crapass.nrramemp, pois
                            não está mais sendo utilizado ( Renato - Supero )

               21/01/2014 - Removida a extensão .lst do relatório crrl055_999 (Renato - Supero)

               17/02/2014 - Trocar Agencia por PA. (Gabriel)

               17/02/2014 - Remover a chamada da procedure "saldo_epr.p".
                            (Gabriel)

               17/02/2014 - Tratamento para contabilizar cheques custodiados
                            com data de liberacao em feriado ou final de
                            semana. (Gabriel)

               17/02/2014 - Ajuste no calculo da variavel "aux_vlstotal".(Gabriel)
               
               28/04/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                            posicoes (Tiago/Gielow SD137074).
     
               06/05/2014 - Alterado definição de data do ultimo dia do mes, utilizada 
                            na busca da tabela crapsli usar a data rw_crapdat.dtultdia 
                            inves da data do ultimo dia do mês anterior (Odirlei-AMcom)
                            
               22/05/2014 - Ajuste para converter (ux2dos) relatorio crrl225 
                            antes de envia-lo por email (Odirlei-AMcom)             
               
               27/10/2014 - Ajuste na conta contábil do Saldo Bloqueado para o arquivo
                             _1.txt (Marcos-Supero)
                             
               18/11/2014 - Melhorias de Performance. Foi removida a procedure interna
                            pc_escreve_xml e utilizada a existente na gene0002. Foi eliminado
                            o cursor da craptab e utilizada a função tabe0001.fn_busca_dstextab.
                            Foi alterada a forma de atualizar as tabelas crapbnd e gninfpl 
                            para uso do forall merge, evitando-se o update/insert item a item.
                            
               05/02/2015 - Foi ajustado o relatorio crrl006_999 para exibir os valores
                            bloqueados judicialmente de pessoas Fisica e Juridicas que
                            nao tem nenhum outro valor a nao ser o valor bloqueado
                            judicial. (Andre Santos - SUPERO)
               
               10/02/2015 - Removido o bloco de impressão das linhas referentes a 
                            "Saldo Limite Cheque Especial" - Projeto RISCO
                            (Guilherme/SUPERO)
                            
               17/06/2015 - #295005 Alterado o campo usado como filtro do tipo de linha de 
                            crédito, de dslcremp para dsorgrec (Carlos)
			         
               26/07/2016 - Ajustes referentes a Melhoria 69 - Devolucao automatica de cheques
                            (Lucas Ranghetti #484923)
                            
			   29/09/2016 - Alteração do diretório para geração de arquivo contábil.
                            P308 (Ricardo Linhares).
                            
               20/02/2017 - Ajuste no processo de emissão do relatório 006_999.
                            P307 (Ricardo Linhares).                            
                            
               26/04/2017 - Retirado a geração do arquivo microcredito_coop_59dias
                            (Tiago/Rodrigo #654647).
				
               26/07/2017 - 706774-Tratar relatórios para valores acima de 1 bilhão
                            (Andrey Formigari - Mouts)

               01/08/2017 - ajuste no relatorio 007 - inclusão de uma subdivisão 

               16/01/2018 - Alteração procedimento INSERT/UPDATE na tabela CRAPBND
                            Melhorias sustentação
                            Retirada exception vr_exc_fimprg, pois a mesma não é utilizada
                            (Ana - Envolti - Chamado 822997)

               01/02/2018 - Alteração para permitir paralelismo. Projeto Ligeirinho. (Josiane - AMcom)

               20/03/2018 - Substituida validacao "cdtipcta IN (6,7,17,18)" pelo "cdmodali = 3".
                            Substituida validacao "cdtipcta IN (2,4,9,11,13,15)" pela chamada
                            da procedure pc_permite_produto_tipo. (Josiane - AMcom)

               17/10/2018 - Liberacao primeiro pacote Projeto 421 - Melhorias nas
                            ferramentas contabeis e fiscais.
                            Heitor / Alcemir (Mouts)
                            
               18/03/2019 - PRB0040683 na rotina pc_consulta_poupanca e suas internas, feitos os tratamentos de erros para que
                            sejam identificados os possíveis pontos de correção; pular a aplicação quando a consulta for chamada
                            pelo batch (Carlos)

               25/04/2019 - INC0013948 As condições que verificam os dados do cursor cr_crapass para 
                            validar se existe investimento, não estava contemplando o tipo de 
                            pessoa 3 - Administrativa 
                            Aplicada condição de verificação para o valor 3 na validação do campo 
                            rw_crapass.inpessoa no cursor. (Jackson)
     ............................................................................. */

     DECLARE

       /* Tipos e registros da pc_crps005 */

       -- Definicao do tipo de registro de agencias
       TYPE typ_reg_crapage IS
       RECORD (cdagenci crapage.cdagenci%TYPE
              ,nmresage crapage.nmresage%TYPE);

       -- Definicao do tipo de registro de telefones
       TYPE typ_reg_craptfc IS
       RECORD (nrdddtfc craptfc.nrdddtfc%TYPE
              ,nrtelefo craptfc.nrtelefo%TYPE);

       -- Definicao do tipo de registro de titulares da conta
       TYPE typ_reg_crapttl IS
       RECORD (cdempres crapttl.cdempres%TYPE
              ,cdturnos crapttl.cdturnos%TYPE);

       -- Definicao do tipo de registro de saldo investimento
       TYPE typ_reg_crapsli IS
       RECORD (vlsddisp crapsli.vlsddisp%TYPE);

       -- Definicao do tipo de registro para tabela de saldo
       TYPE typ_reg_crapsld IS
       RECORD (vlsdbloq crapsld.vlsdbloq%TYPE
              ,vlsdblpr crapsld.vlsdblpr%TYPE
              ,vlsdblfp crapsld.vlsdblfp%TYPE
              ,vlsdchsl crapsld.vlsdchsl%TYPE
              ,vlsddisp crapsld.vlsddisp%TYPE
              ,vlipmfpg crapsld.vlipmfpg%TYPE
              ,vlipmfap crapsld.vlipmfap%TYPE
              ,dtdsdclq crapsld.dtdsdclq%TYPE
              ,qtddsdev crapsld.qtddsdev%TYPE
              ,vlblqjud crapsld.vlsddisp%TYPE
              ,vlblqprj crapsld.vlblqprj%TYPE
              ,vlsldtot NUMBER
              ,vr_rowid ROWID);

       -- Definicao do tipo de registro gn099
       TYPE typ_reg_gn099 IS
       RECORD (cdagenci crapass.cdagenci%TYPE        --Código da agencia
              ,vlsutili NUMBER                       --Total limite cheque especial
              ,vlsaqblq NUMBER                       --Total saque sobre deposito bloqueado
              ,vlsadian NUMBER                       --Total Adiantamento deposito
              ,vladiclq NUMBER);                     --Adiantamento deposito em conta corrente

       -- Definicao do tipo de registro gn006
       TYPE typ_reg_gn006 IS
       RECORD (cdagenci crapass.cdagenci%TYPE
              ,nrdconta crapass.nrdconta%TYPE
              ,vlstotal NUMBER);

       --Definicao do tipo de registro para relatorio crat372
       TYPE typ_reg_crat372 IS
       RECORD (cdagenci crapass.cdagenci%TYPE
              ,nrdconta crapass.nrdconta%TYPE
              ,cdempres craptab.cdempres%TYPE
              ,cdturnos crapass.cdturnos%TYPE
              ,vlsddisp crapsli.vlsddisp%TYPE
              ,nmprimtl crapass.nmprimtl%TYPE
              ,nrdofone VARCHAR2(100));

       --Definicao do tipo de registro para relatorio crat006
       TYPE typ_reg_crat006 IS
       RECORD (cdagenci crapass.cdagenci%TYPE
              ,nrdconta crapass.nrdconta%TYPE
              ,nmprimtl crapass.nmprimtl%TYPE
              ,vlsaqmax NUMBER
              ,vlsddisp NUMBER
              ,vllimcre NUMBER
              ,vlsdbltl NUMBER
              ,vlsdchsl NUMBER
              ,vlstotal NUMBER
              ,vlblqjud NUMBER
              ,dsdacstp VARCHAR2(11));

       --Definicao do tipo de registro para relatorio crat055
       TYPE typ_reg_crat055 IS
       RECORD (cdagenci crapass.cdagenci%TYPE
              ,nrdconta crapass.nrdconta%TYPE
              ,nmprimtl crapass.nmprimtl%TYPE
              ,vlsddisp NUMBER
              ,vllimcre NUMBER
              ,vlsdbltl NUMBER
              ,vlstotal NUMBER
              ,dsdacstp VARCHAR2(11)
              ,nrcpfcgc VARCHAR2(20)
              ,vlindice VARCHAR2(50)); -- projeto ligeirinho

       --Definicao do tipo de registro para relatorio crat030
       TYPE typ_reg_crat030 IS
       RECORD (cdagenci crapass.cdagenci%TYPE
              ,nrdconta crapass.nrdconta%TYPE
              ,nmprimtl crapass.nmprimtl%TYPE
              ,vlsddisp crapsld.vlsddisp%TYPE
              ,vllimcre crapass.vllimcre%TYPE
              ,vlsdchsl crapsld.vlsdchsl%TYPE
              ,dtdsdclq crapsld.dtdsdclq%TYPE
              ,qtddsdev crapsld.qtddsdev%TYPE
              ,vlstotal NUMBER
              ,vlsdbltl NUMBER);

       --Definicao do tipo de registro para relatorio crat071
       TYPE typ_reg_crat071 IS
       RECORD (cdagenci crapass.cdagenci%TYPE
              ,nrdconta crapass.nrdconta%TYPE
              ,cdempres craptab.cdempres%TYPE
              ,nmprimtl crapass.nmprimtl%TYPE
              ,vlsddisp crapsld.vlsddisp%TYPE
              ,cdturnos crapttl.cdturnos%TYPE
              ,vlstotal NUMBER
              ,dsdacstp VARCHAR2(11)
              ,nrdofone VARCHAR2(100));

       --Definicao do tipo de registro para relatorio crat007
       TYPE typ_reg_crat007 IS
       RECORD (cdagenci crapass.cdagenci%TYPE
              ,nrdconta crapass.nrdconta%TYPE
              ,nmprimtl crapass.nmprimtl%TYPE
              ,qtddsdev crapsld.qtddsdev%TYPE
              ,vlsddisp crapsld.vlsddisp%TYPE
              ,vllimcre crapass.vllimcre%TYPE
              ,nrdofone VARCHAR2(100)
              ,vlestour NUMBER
              ,vlsdbltl NUMBER
              ,qtcompbb NUMBER
              ,vlcompbb NUMBER
              ,qtcmpbcb NUMBER
              ,vlcmpbcb NUMBER
              ,qtcmpctl NUMBER
              ,vlcmpctl NUMBER
              ,qtcstdct NUMBER
              ,vlcstdct NUMBER
              ,flsldapl VARCHAR2(3)
              ,flgdevolu_autom VARCHAR2(3)
              ,qtdevolu INTEGER);

       --Definicao do tipo de registro para relatorio crat007_final
       TYPE typ_reg_crat007_final IS
       RECORD (nrdconta crapass.nrdconta%TYPE
              ,qtddsdev crapsld.qtddsdev%TYPE
              ,vlsddisp crapsld.vlsddisp%TYPE
              ,vllimcre crapass.vllimcre%TYPE
              ,nmprimtl crapass.nmprimtl%TYPE
              ,vlestour NUMBER
              ,vlsdbltl NUMBER
              ,qtcmptot NUMBER
              ,vlcmptot NUMBER
              ,qtcstdct NUMBER
              ,vlcstdct NUMBER
              ,flsldapl VARCHAR2(3)
              ,flgdevolu_autom VARCHAR2(3)
              ,qtdevolu INTEGER);

       --Definicao do tipo de registro para relatorio crat225
       TYPE typ_reg_crat225 IS
       RECORD (cdagenci crapass.cdagenci%TYPE
              ,nrdconta crapass.nrdconta%TYPE
              ,nmprimtl crapass.nmprimtl%TYPE
              ,cdempres craptab.cdempres%TYPE
              ,cdturnos crapttl.cdturnos%TYPE
              ,qtddsdev crapsld.qtddsdev%TYPE
              ,vlsddisp crapsld.vlsddisp%TYPE
              ,vllimcre crapass.vllimcre%TYPE
              ,nrdofone VARCHAR2(100)
              ,dsdacstp VARCHAR2(11)
              ,vlestour NUMBER
              ,vlsdbltl NUMBER
              ,vlstotal NUMBER);

       --Definicao do tipo de registro para relatorio crat226
       TYPE typ_reg_crat226 IS
       RECORD (cdagenci crapass.cdagenci%TYPE
              ,nrdconta crapass.nrdconta%TYPE
              ,nmprimtl crapass.nmprimtl%TYPE
              ,cdempres craptab.cdempres%TYPE
              ,qtddsdev crapsld.qtddsdev%TYPE
              ,vlsddisp crapsld.vlsddisp%TYPE
              ,vllimcre crapass.vllimcre%TYPE
              ,cdturnos crapttl.cdturnos%TYPE
              ,tpvincul VARCHAR2(2)
              ,dsdacstp VARCHAR2(11)
              ,vlestour NUMBER
              ,vlsdbltl NUMBER
              ,vlstotal NUMBER);

       --Definicao do tipo de registro para relatorio detalhes
       TYPE typ_reg_detalhes IS
       RECORD (cdagenci crapass.cdagenci%TYPE
              ,nrdconta crapass.nrdconta%TYPE
              ,nmprimtl crapass.nmprimtl%TYPE
              ,cdlcremp crapepr.cdlcremp%TYPE
              ,nrctremp crapepr.nrctremp%TYPE
              ,dtmvtolt crapepr.dtmvtolt%TYPE
              ,vlemprst crapepr.vlemprst%TYPE
              ,vlsdeved NUMBER);

       --Definicao do tipo de registro para relatorio emprestimos atrasados
       TYPE typ_reg_atrasados IS
       RECORD (cdagenci crapass.cdagenci%TYPE
              ,nrdconta crapass.nrdconta%TYPE
              ,cdlcremp crapepr.cdlcremp%TYPE
              ,nrctremp crapepr.nrctremp%TYPE
              ,dtultpag crapepr.dtmvtolt%TYPE
              ,vlsdeved NUMBER);

       --Definicao do tipo de registro para relatorio totais
       TYPE typ_reg_totais IS
       RECORD (cdlcremp crapepr.cdlcremp%TYPE
              ,tipo     craplcr.dsorgrec%TYPE
              ,vltttfis NUMBER
              ,vltttjur NUMBER);

       --Definicao do tipo de registro para tabela bndes
       TYPE typ_reg_bndes IS
       RECORD (nrdconta crapbnd.nrdconta%TYPE    --Conta Corrente
              ,vladtodp crapbnd.vladtodp%TYPE    --Adto Depositantes
              ,vlsaqblq crapbnd.vlsaqblq%TYPE    --Saq.Bloqueado
              ,vlchqesp crapbnd.vlchqesp%TYPE    --Tot.Chq.Espec
              ,vldepavs crapbnd.vldepavs%TYPE);  --Dep.Vista


       --Definicao do tipo de registro para  relatorio crat006 (contabilizar)
       -- Projeto ligeirinho
       TYPE typ_reg_contab IS
       RECORD (cdagenci      crapass.cdagenci%TYPE     --Conta Corrente
              ,con_vlsaqblq  number  --Saque S/ bloq
              ,con_vladiant  number  --Adiantamento depósito
              ,con_vlutiliz  number);--Utilizado

       -- Definicao do tipo de tabela para relatorio gn099
       TYPE typ_tab_gn099 IS
         TABLE OF typ_reg_gn099
         INDEX BY PLS_INTEGER;

       -- Definicao do tipo de tabela para relatorio gn006
       TYPE typ_tab_gn006 IS
         TABLE OF typ_reg_gn006
         INDEX BY PLS_INTEGER;

       --Definicao do tipo de tabela para relatorio crat372
       TYPE typ_tab_crat372 IS
         TABLE OF typ_reg_crat372
         INDEX BY VARCHAR2(15);

       --Definicao do tipo de tabela para relatorio crat006
       TYPE typ_tab_crat006 IS
         TABLE OF typ_reg_crat006
         INDEX BY VARCHAR2(15);

       --Definicao do tipo de tabela para relatorio crat055
       TYPE typ_tab_crat055 IS
         TABLE OF typ_reg_crat055
         INDEX BY VARCHAR2(25);

       --Definicao do tipo de tabela para relatorio crat030
       TYPE typ_tab_crat030 IS
         TABLE OF typ_reg_crat030
         INDEX BY VARCHAR2(15);

       --Definicao do tipo de tabela para relatorio crat071
       TYPE typ_tab_crat071 IS
         TABLE OF typ_reg_crat071
         INDEX BY VARCHAR2(15);

       --Definicao do tipo de tabela para relatorio crat007
       TYPE typ_tab_crat007 IS
         TABLE OF typ_reg_crat007
         INDEX BY VARCHAR2(20);

       --Definicao do tipo de tabela para relatorio crat007_final
       TYPE typ_tab_crat007_final IS
         TABLE OF typ_reg_crat007_final
         INDEX BY VARCHAR2(15);

       --Definicao do tipo de tabela para relatorio crat225
       TYPE typ_tab_crat225 IS
         TABLE OF typ_reg_crat225
         INDEX BY VARCHAR2(15);

     --Definicao do tipo de tabela para relatorio crat226
       TYPE typ_tab_crat226 IS
         TABLE OF typ_reg_crat226
         INDEX BY VARCHAR2(15);

     --Definicao do tipo de tabela para relatorio detalhes
       TYPE typ_tab_detalhes IS
         TABLE OF typ_reg_detalhes
         INDEX BY VARCHAR2(25);

     --Definicao do tipo de tabela para relatorio emprestimos atrasados
       TYPE typ_tab_atrasados IS
         TABLE OF typ_reg_atrasados
         INDEX BY VARCHAR2(50);

     --Definicao do tipo de tabela para relatorio totais
       TYPE typ_tab_totais IS
         TABLE OF typ_reg_totais
         INDEX BY VARCHAR2(45);

       --Definicao do tipo de tabela para bndes
       TYPE typ_tab_bndes IS
         TABLE OF typ_reg_bndes
         INDEX BY PLS_INTEGER;

       --Definicao do tipo de registro para os totalizadores
       TYPE typ_reg_tot IS
         TABLE OF NUMBER
         INDEX BY PLS_INTEGER;

       -- Definicao do tipo de tabela registro de agencias
       TYPE typ_tab_crapage IS
         TABLE OF typ_reg_crapage
         INDEX BY PLS_INTEGER;

                -- Definicao do tipo de tabela registro de telefones
       TYPE typ_tab_craptfc IS
         TABLE OF typ_reg_craptfc
         INDEX BY VARCHAR2(25);

       -- Definicao do tipo de tabela para titulares da conta
       TYPE typ_tab_crapttl IS
         TABLE OF typ_reg_crapttl
         INDEX BY VARCHAR2(20);

       -- Definicao do tipo de tabela para saldo investimento
       TYPE typ_tab_crapsli IS
         TABLE OF typ_reg_crapsli
         INDEX BY VARCHAR2(20);

       -- Definicao do tipo de tabela para associados
       TYPE typ_tab_crapass IS
         TABLE OF NUMBER
         INDEX BY PLS_INTEGER;

       -- Definicao do tipo de tabela para contra-ordens
       TYPE typ_tab_crapcor IS
         TABLE OF NUMBER
         INDEX BY VARCHAR2(20);

       -- Definicao do tipo de tabela para emprestimos
       TYPE typ_tab_crapepr IS
         TABLE OF NUMBER
         INDEX BY VARCHAR2(20);

       -- Definicao do tipo de tabela para saldos
       TYPE typ_tab_crapsld IS
         TABLE OF typ_reg_crapsld
         INDEX BY PLS_INTEGER;

       --Definicao do tipo de tabela para relatorio crat006 (contabilizar)
       -- Projeto ligeirinho
       TYPE typ_tab_contab IS
          TABLE OF typ_reg_contab
          INDEX BY VARCHAR2(25);

       /* Vetores de memória */
       vr_tab_tot_qtcstdct   typ_reg_tot; --Totalizador da quantidade em custodia
       vr_tab_tot_vlcstdct   typ_reg_tot; --Totalizador do valor em custodia
       vr_tab_tot_agnvllim   typ_reg_tot; --Totalizador do valor limite das agencias
       vr_tab_tot_agnsdstl   typ_reg_tot; --Totalizador do saldo total das agencias
       vr_tab_tot_agnsdchs   typ_reg_tot; --Totalizador do saldo cheque salario
       vr_tab_tot_agnsddis   typ_reg_tot; --Totalizador do saldo disponivel da agencia
       vr_tab_tot_agnsdbtl   typ_reg_tot; --Totalizador do saldo bloqueado da agencia
       vr_tab_tot_agnvlbjd   typ_reg_tot; --Totalizador do saldo bloqueado judicial da agencia
       vr_tab_lis_agnsddis   typ_reg_tot; --Listagem do saldo diponivel por agencia
       vr_tab_lis_agnsdbtl   typ_reg_tot; --Listagem do saldo bloqueado por agencia
       vr_tab_lis_agnsdstl   typ_reg_tot; --Listagem do saldo total por agencia
       vr_tab_lis_agnvllim   typ_reg_tot; --Listagem do valor limite por agencia
       vr_tab_lis_agnsdchs   typ_reg_tot; --Listagem do saldo disponivel da agencia

       vr_tab_gn099          typ_tab_gn099;
       vr_tab_gn006          typ_tab_gn006;
       vr_tab_crat372        typ_tab_crat372;
       vr_tab_crat006        typ_tab_crat006;
       vr_tab_crat055        typ_tab_crat055;
       vr_tab_crat030        typ_tab_crat030;
       vr_tab_crat071        typ_tab_crat071;
       vr_tab_crat007        typ_tab_crat007;
       vr_tab_crat007_final  typ_tab_crat007_final;
       vr_tab_crat225        typ_tab_crat225;
       vr_tab_crat226        typ_tab_crat226;
       vr_tab_detalhes       typ_tab_detalhes;
       vr_tab_atrasados      typ_tab_atrasados;
       vr_tab_totais         typ_tab_totais;
       vr_tab_totais_final   typ_tab_totais;
       vr_tab_cta_bndes      typ_tab_bndes;
       vr_tab_crapsld        typ_tab_crapsld;
       vr_tab_crapage        typ_tab_crapage;
       vr_tab_craptfc        typ_tab_craptfc;
       vr_tab_crapttl        typ_tab_crapttl;
       vr_tab_crapsli        typ_tab_crapsli;
       vr_tab_crapass        typ_tab_crapass;
       vr_tab_crapcor        typ_tab_crapcor;
       vr_tab_crapepr        typ_tab_crapepr;
       vr_tab_craplcm_cta    typ_tab_crapepr;
       vr_tab_dem_agpsdmax   typ_reg_tot;
       vr_tab_dem_agpsddis   typ_reg_tot;
       vr_tab_dem_agpvllim   typ_reg_tot;
       vr_tab_dem_agpsdbtl   typ_reg_tot;
       vr_tab_dem_agpsdchs   typ_reg_tot;
       vr_tab_dem_agpsdstl   typ_reg_tot;
       vr_tab_dem_agpvlbjd   typ_reg_tot;
       vr_tab_rel_agpsdmax   typ_reg_tot;
       vr_tab_rel_agpsddis   typ_reg_tot;
       vr_tab_rel_agpvllim   typ_reg_tot;
       vr_tab_rel_agpsdbtl   typ_reg_tot;
       vr_tab_rel_agpsdchs   typ_reg_tot;
       vr_tab_rel_agpsdstl   typ_reg_tot;
       vr_tab_rel_agnsdchs   typ_reg_tot;
       vr_tab_rel_vlsaqblq   typ_reg_tot;
       vr_tab_rel_vlbloque   typ_reg_tot;
       vr_tab_rel_vldisneg   typ_reg_tot;
       vr_tab_rel_vldispos   typ_reg_tot;
       vr_tab_rel_vlsutili   typ_reg_tot;
       vr_tab_rel_vlblqjud   typ_reg_tot;
       vr_tab_rel_vlsadian   typ_reg_tot;
       vr_tab_rel_vlsldliq   typ_reg_tot;
       vr_tab_rel_vladiclq   typ_reg_tot;
       vr_tab_rel_agnsddis   typ_reg_tot;
       vr_tab_rel_agnvllim   typ_reg_tot;
       vr_tab_rel_agnsdbtl   typ_reg_tot;
       vr_tab_rel_agnsdstl   typ_reg_tot;
       vr_tab_rel_agpsdbjd   typ_reg_tot;
       vr_tab_rel_agpvlbjd   typ_reg_tot;
       vr_tab_rel_vlcntinv   typ_reg_tot; -- P307 CONTA INVESTIMENTO
       -- Projeto ligeirinho         
       vr_tab_contab         typ_tab_contab;         

       /* Cursores da pc_crps005 */

       -- Selecionar os dados da Cooperativa
       CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
         SELECT cop.cdcooper
               ,cop.nmrescop
               ,cop.nrtelura
               ,cop.cdbcoctl
               ,cop.cdagectl
               ,cop.cdagebcb
               ,cop.cdageitg
               ,cop.dsdircop
               ,cop.nrctactl
         FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
       rw_crapcop cr_crapcop%ROWTYPE;

       -- Selecionar os dados da conta centralizadora da Cooperativa
       CURSOR cr_crapcop_conta (pr_nrdconta IN crapcop.nrctactl%TYPE) IS
         SELECT cop.cdcooper
         FROM crapcop cop
         WHERE cop.nrctactl = pr_nrdconta;
       rw_crapcop_conta cr_crapcop_conta%ROWTYPE;

       --Tipo de dado para receber as datas da tabela crapdat
       rw_crapdat btch0001.rw_crapdat%TYPE;

       --Selecionar informacoes dos limites de credito
       CURSOR cr_craplcr (pr_cdcooper IN craplcr.cdcooper%TYPE
                         ,pr_cdusolcr IN craplcr.cdusolcr%TYPE) IS
         SELECT craplcr.cdlcremp
               ,craplcr.dsorgrec
         FROM  craplcr craplcr
         WHERE craplcr.cdcooper = pr_cdcooper
         AND   craplcr.cdusolcr = pr_cdusolcr;
       rw_craplcr cr_craplcr%ROWTYPE;

       --Selecionar as agencias
       CURSOR cr_crapage (pr_cdcooper IN crapage.cdcooper%TYPE) IS
         SELECT crapage.cdagenci
               ,crapage.nmresage
         FROM crapage crapage
         WHERE crapage.cdcooper = pr_cdcooper
         --Inclusão de filtro por agência para tratar o paralelismo
         and crapage.cdagenci = decode(pr_cdagenci,0,crapage.cdagenci,pr_cdagenci)         
         ORDER BY crapage.cdagenci;


       -- Seleciona as agências para a submissão dos Jobs
       cursor cr_crapass_job (pr_cdcooper in craprpp.cdcooper%type,
                              pr_dtmvtolt in crapdat.dtmvtolt%type,
                              pr_cdprogra in tbgen_batch_controle.cdprogra%type,
                              pr_qterro   in number) is 
         select crapage.cdagenci
           from crapage
          where crapage.cdcooper  = pr_cdcooper
            and (pr_qterro = 0 or
                (pr_qterro > 0 and exists (select 1
                                             from tbgen_batch_controle
                                            where tbgen_batch_controle.cdcooper    = pr_cdcooper
                                              and tbgen_batch_controle.cdprogra    = pr_cdprogra
                                              and tbgen_batch_controle.tpagrupador = 1
                                              and tbgen_batch_controle.cdagrupador = crapage.cdagenci
                                              and tbgen_batch_controle.insituacao  = 1
                                              and tbgen_batch_controle.dtmvtolt    = pr_dtmvtolt)))
         order by crapage.cdagenci;
          

       --Selecionar informacoes dos associados e saldos das contas
       --O uso do partition by é para conseguir ordenar pelo saldo total decrescente
       CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                         ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
         SELECT  crapass.cdagenci
                ,crapass.nrdconta
                ,crapass.vllimcre
                ,crapass.tpextcta
                ,crapass.inpessoa
                ,SubStr(crapass.nmprimtl,1,35) nmprimtl
                ,crapass.dtdemiss
                ,crapass.cdsitdct
                ,crapass.cdtipcta
                ,crapass.nrcpfcgc
                ,crapass.nrdctitg
                ,crapass.tpvincul
                ,tpcta.cdmodalidade_tipo cdmodali
				,crapass.inprejuz
         FROM crapass crapass
             ,tbcc_tipo_conta tpcta
         WHERE  crapass.cdcooper = pr_cdcooper
         AND    crapass.cdagenci = pr_cdagenci
         AND    crapass.cdtipcta = tpcta.cdtipo_conta
         AND    crapass.inpessoa = tpcta.inpessoa;

       --Selecionar informacoes dos titulares da conta
       CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%TYPE
                         ,pr_idseqttl IN crapttl.idseqttl%TYPE
                         ,pr_cdagenci IN crapass.cdagenci%type) IS -- projeto ligeirinho
         SELECT crapttl.cdcooper
               ,crapttl.nrdconta
               ,crapttl.cdempres
               ,crapttl.cdturnos
         FROM crapttl crapttl,
              crapass crapass -- projeto ligeirinho
         WHERE crapttl.cdcooper = crapass.cdcooper 
         AND   crapttl.nrdconta = crapass.nrdconta
         AND   crapttl.cdcooper = pr_cdcooper
         AND   crapttl.idseqttl = pr_idseqttl
         --Inclusão de filtro por agência para tratar o paralelismo (projeto ligeirinho)
         AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci);
       
       rw_crapttl cr_crapttl%ROWTYPE;


       --Selecionar informacoes dos titulares da conta
       CURSOR cr_crapjur (pr_cdcooper IN crapjur.cdcooper%TYPE
                         ,pr_nrdconta IN crapjur.nrdconta%TYPE) IS
         SELECT crapjur.cdempres
         FROM crapjur crapjur
         WHERE crapjur.cdcooper = pr_cdcooper
         AND   crapjur.nrdconta = pr_nrdconta;

       --Selecionar informacoes dos saldos dos associados
       CURSOR cr_crapsld (pr_cdcooper IN crapsld.cdcooper%TYPE
                         ,pr_cdagenci IN crapass.cdagenci%TYPE) IS -- projeto ligeirinho) IS
         SELECT crapsld.cdcooper
               ,crapsld.nrdconta
               ,crapsld.vlsdbloq
               ,crapsld.vlsdblpr
               ,crapsld.vlsdblfp
               ,crapsld.vlsdchsl
               ,crapsld.vlsddisp
               ,crapsld.vlipmfpg
               ,crapsld.vlipmfap
               ,crapsld.dtdsdclq
               ,crapsld.qtddsdev
               ,crapsld.vlblqjud
               ,crapsld.rowid
               ,(nvl(crapsld.vlsdbloq,0) +
                 nvl(crapsld.vlsdblpr,0) +
                 nvl(crapsld.vlsdblfp,0) +
                 nvl(crapsld.vlsddisp,0) +
                 nvl(crapsld.vlsdchsl,0)) vlsldtot
               ,crapsld.vlblqprj
         FROM crapsld crapsld,
              crapass crapass -- projeto ligeirinho
         WHERE crapsld.cdcooper = crapass.cdcooper 
         AND   crapsld.nrdconta = crapass.nrdconta
         AND   crapsld.cdcooper = pr_cdcooper
         --Inclusão de filtro por agência para tratar o paralelismo (projeto ligeirinho)
         AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci);

       rw_crapsld cr_crapsld%ROWTYPE;

       --Selecionar informacoes dos lancamentos
       CURSOR cr_craplcm (pr_cdcooper IN craplcm.cdcooper%TYPE
                         ,pr_nrdconta IN craplcm.nrdconta%TYPE) IS
         SELECT craplcm.ROWID
         FROM craplcm craplcm
         WHERE craplcm.cdcooper = pr_cdcooper
         AND   craplcm.nrdconta = pr_nrdconta;
       rw_craplcm cr_craplcm%ROWTYPE;

       --Selecionar informacoes dos lancamentos de cheques
       CURSOR cr_craplcm_cheque (pr_cdcooper IN craplcm.cdcooper%TYPE
                                ,pr_nrdconta IN craplcm.nrdconta%TYPE
                                ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE) IS
         SELECT craplcm.ROWID
               ,craplcm.cdhistor
               ,craplcm.vllanmto
               ,craplcm.cdagenci
               ,craplcm.cdbccxlt
               ,craplcm.nrdolote
               ,craplcm.cdcooper
               ,craplcm.nrdconta
               ,craplcm.nrdocmto
         FROM craplcm craplcm
         WHERE craplcm.cdcooper = pr_cdcooper
         AND   craplcm.nrdconta = pr_nrdconta
         AND   craplcm.dtmvtolt = pr_dtmvtolt
         AND   craplcm.cdhistor IN (50,59,313,340,524,572,521,621,21,26);


       --Selecionar informacoes das contra-ordens
       CURSOR cr_crapcor (pr_cdcooper IN crapcor.cdcooper%TYPE
                         ,pr_flgativo IN crapcor.flgativo%TYPE
                         ,pr_cdagenci IN crapass.cdagenci%TYPE) IS -- projeto ligeirinho
         SELECT crapcor.nrdconta
         FROM crapcor crapcor,
              crapass crapass -- projeto ligeirinho
         WHERE crapcor.cdcooper = crapass.cdcooper 
         AND   crapcor.nrdconta = crapass.nrdconta
         AND   crapcor.cdcooper = pr_cdcooper
         AND   crapcor.flgativo = pr_flgativo
         --Inclusão de filtro por agência para tratar o paralelismo (projeto ligeirinho)
         AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci);

       --Selecionar informacoes de Custodia de Cheques
       CURSOR cr_crapcst (pr_cdcooper IN crapcst.cdcooper%TYPE
                         ,pr_dtmvtoan IN crapcst.dtlibera%TYPE
                         ,pr_dtmvtolt IN crapcst.dtlibera%TYPE
                         ,pr_nrctachq IN crapcst.nrctachq%TYPE
                         ,pr_ctpsqitg IN crapcst.nrctachq%TYPE
                         ,pr_cdagectl IN crapcst.cdagechq%TYPE
                         ,pr_cdagebcb IN crapcst.cdagechq%TYPE
                         ,pr_cdageitg IN crapcst.cdagechq%TYPE) IS
         SELECT crapcst.vlcheque
         FROM crapcst crapcst
         WHERE crapcst.cdcooper = pr_cdcooper
         AND   crapcst.dtlibera >= pr_dtmvtoan + 1
         AND   crapcst.dtlibera <= pr_dtmvtolt
         AND   crapcst.insitchq = 2
         AND   crapcst.dtdevolu IS NULL
         AND   crapcst.inchqcop = 1
         AND   ((crapcst.cdbanchq = 085 AND crapcst.nrctachq = pr_nrctachq AND crapcst.cdagechq = pr_cdagectl) OR
                (crapcst.cdbanchq = 756 AND crapcst.nrctachq = pr_nrctachq AND crapcst.cdagechq = pr_cdagebcb) OR
                (crapcst.cdbanchq = 001 AND crapcst.nrctachq = pr_ctpsqitg AND crapcst.cdagechq = pr_cdageitg));

       --Selecionar informacoes das contas investimento
       CURSOR cr_crapsli (pr_cdcooper IN crapsli.cdcooper%TYPE
                         ,pr_dtrefere IN crapsli.dtrefere%TYPE
                         ,pr_cdagenci IN crapass.cdagenci%TYPE) IS -- projeto ligeirinho
         SELECT  crapsli.nrdconta
                ,Nvl(crapsli.vlsddisp,0) vlsddisp
         FROM crapsli crapsli,
              crapass crapass -- projeto ligeirinho
         WHERE crapsli.cdcooper = crapass.cdcooper 
         AND   crapsli.nrdconta = crapass.nrdconta
         AND   crapsli.cdcooper = pr_cdcooper
         AND   crapsli.dtrefere = pr_dtrefere
         --Inclusão de filtro por agência para tratar o paralelismo (projeto ligeirinho)
         AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci);


       /* O select na craplcr é necessário para selecionar as linhas de credito
         sem usar o camando instr...
         --AND   INSTR(pr_listalcr,','||crapepr.cdlcremp||',') > 0; */
       --Selecionar informacoes dos emprestimos para tabela auxiliar
       CURSOR cr_crapepr_conta (pr_cdcooper IN crapepr.cdcooper%TYPE
                               ,pr_inliquid IN crapepr.inliquid%TYPE
                               ,pr_cdagenci IN crapass.cdagenci%TYPE) IS -- projeto ligeirinho
         SELECT crapepr.vlsdeved
               ,crapepr.nrdconta
               ,crapepr.nrctremp
               ,crapepr.cdlcremp
               ,crapepr.dtmvtolt
               ,crapepr.vlemprst
               ,crapepr.dtultpag
               ,crapepr.cdcooper
               ,crapepr.cdagenci
         FROM crapepr crapepr,
              crapass crapass -- projeto ligeirinho
         WHERE crapepr.cdcooper = crapass.cdcooper 
         AND   crapepr.nrdconta = crapass.nrdconta
         AND   crapepr.cdcooper = pr_cdcooper
         AND   crapepr.inliquid = pr_inliquid
         --Inclusão de filtro por agência para tratar o paralelismo (projeto ligeirinho)
         AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
         AND   EXISTS (SELECT 1 FROM craplcr
                       WHERE craplcr.cdcooper = crapepr.cdcooper
                       AND   craplcr.cdlcremp = crapepr.cdlcremp
                       AND   craplcr.cdusolcr = 1);

        /* O comando OVER é utilizado para determinar a quantidade de linhas de credito. Com essa informação
           é possivel determinar o primeiro e o ultimo registro de cada agencia simulando o FIRST e LAST do progress */
       --Selecionar informacoes dos emprestimos
       CURSOR cr_crapepr (pr_cdcooper IN crapepr.cdcooper%TYPE
                         ,pr_nrdconta IN crapepr.nrdconta%TYPE
                         ,pr_inliquid IN crapepr.inliquid%TYPE) IS
         SELECT crapepr.vlsdeved
               ,crapepr.nrdconta
               ,crapepr.nrctremp
               ,crapepr.cdlcremp
               ,crapepr.dtmvtolt
               ,crapepr.vlemprst
               ,crapepr.dtultpag
               ,crapepr.cdcooper
               ,crapepr.cdagenci
               ,crapepr.vlsdevat
               ,crapepr.tpemprst
               ,crapepr.qtlcalat
               ,crapepr.qtpcalat
               ,Count (1)
                  OVER (PARTITION BY crapepr.cdlcremp) qtemplcr
               ,ROW_NUMBER ()
                  OVER (PARTITION BY crapepr.cdlcremp ORDER BY crapepr.cdlcremp) nrseqlcr
         FROM craplcr,
              crapepr crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
         AND   crapepr.nrdconta = pr_nrdconta
         AND   crapepr.inliquid = pr_inliquid
         AND   craplcr.cdcooper = crapepr.cdcooper
         AND   craplcr.cdlcremp = crapepr.cdlcremp
         AND   craplcr.cdusolcr = 1;
       rw_crapepr cr_crapepr%ROWTYPE;

       --Selecionar informacoes dos limites de credito por contrato
       CURSOR cr_craplcr2 (pr_cdcooper IN craplcr.cdcooper%TYPE
                          ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
         SELECT Upper(craplcr.dsorgrec) dsorgrec
         FROM craplcr craplcr
         WHERE craplcr.cdcooper = pr_cdcooper
         AND   craplcr.cdlcremp = pr_cdlcremp
         ORDER BY craplcr.progress_recid ASC;
       rw_craplcr2   cr_craplcr2%ROWTYPE;

       --Selecionar informacoes dos telefones dos titulares das contas
       CURSOR cr_craptfc (pr_cdcooper IN craptfc.cdcooper%TYPE
                         ,pr_cdagenci IN crapass.cdagenci%TYPE) IS -- projeto ligeirinho)
         SELECT craptfc.cdcooper
               ,craptfc.nrdconta
               ,craptfc.tptelefo
               ,craptfc.nrdddtfc
               ,craptfc.nrtelefo
         FROM  craptfc craptfc,
               crapass crapass -- projeto ligeirinho
         WHERE craptfc.cdcooper = crapass.cdcooper 
         AND   craptfc.nrdconta = crapass.nrdconta
         AND   craptfc.cdcooper = pr_cdcooper
         --Inclusão de filtro por agência para tratar o paralelismo (projeto ligeirinho)
         AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
         ORDER BY craptfc.nrdconta
                 ,craptfc.tptelefo
                 ,craptfc.progress_recid DESC;
       rw_craptfc cr_craptfc%ROWTYPE;


       CURSOR cr_crapneg( pr_cdcooper IN crapcop.cdcooper%TYPE,
                          pr_nrdconta IN crapass.nrdconta%TYPE,
                          pr_nrdocmto IN crapneg.nrdocmto%TYPE,
                          pr_vlestour IN crapneg.vlestour%TYPE) IS
        SELECT 1 
          FROM crapneg       
         WHERE crapneg.cdcooper = pr_cdcooper
           AND crapneg.nrdconta = pr_nrdconta
           AND crapneg.cdhisest = 1
           AND crapneg.nrdocmto = pr_nrdocmto
           AND crapneg.vlestour = pr_vlestour;


       /* Variaveis Locais da pc_crps005 */

       --Tabelas de Memoria
       vr_tab_saldo_rdca  APLI0001.typ_tab_saldo_rdca;
       vr_tab_erro        gene0001.typ_tab_erro;
       -- TempTables para APLI0001.pc_consulta_poupanca
       vr_tab_conta_bloq APLI0001.typ_tab_ctablq;
       vr_tab_craplpp    APLI0001.typ_tab_craplpp;
       vr_tab_craplrg    APLI0001.typ_tab_craplpp;
       vr_tab_resgate    APLI0001.typ_tab_resgate;
       vr_tab_dados_rpp  APLI0001.typ_tab_dados_rpp;


       vr_vlsldapl NUMBER;
       vr_vlsldrgt NUMBER;
       vr_vlsldtot NUMBER;
       vr_vlsldppr NUMBER;
       vr_percenir NUMBER;
       vr_flgdevolu_autom INTEGER;
       vr_qtdevolu INTEGER;
       
       vr_index     NUMBER:= 0;
       vr_pessajur  NUMBER:= 0;
       vr_pessafis  NUMBER:= 0;
       vr_vltttjur  NUMBER:= 0;
       vr_vltttfis  NUMBER:= 0;
       vr_vltotfis  NUMBER:= 0;
       vr_vltotjur  NUMBER:= 0;
       vr_ttpnmpof  NUMBER:= 0;
       vr_ttpnmpoj  NUMBER:= 0;
       vr_vlbloque  NUMBER:= 0;
       vr_flgfuctl  BOOLEAN;
       vr_flgdemit  BOOLEAN;
       vr_flgnegat  BOOLEAN;
       vr_flgimprm  BOOLEAN;
       vr_inusatab  BOOLEAN;
       vr_flggv006  BOOLEAN;
       vr_vlsaqmax  NUMBER:= 0;
       vr_vlminpop  NUMBER:= 0;
       vr_cdempres  INTEGER:= 0;
       vr_vlsaldisp INTEGER:= 0;
       vr_listalcr  VARCHAR2(4000);
       vr_lispnmpo  VARCHAR2(4000);
       vr_vlstotal  NUMBER;
       vr_possuipr  VARCHAR2(1);

       -- Variaveis para include do calculo de dias includes/crp398.i
       vr_dias       INTEGER:= 0;
       vr_vlsdeved   NUMBER:= 0;
       vr_cdagenci   crapage.cdagenci%TYPE;
       vr_nmresage   crapage.nmresage%TYPE;
       vr_qtprecal   crapepr.qtprecal%TYPE;
       vr_nmprimtl   crapass.nmprimtl%TYPE;
       vr_dstextab   craptab.dstextab%TYPE;
       vr_des_reto  VARCHAR2(10);
       
       -- Variavies do proc_conta_integracao
       vr_ctpsqitg   craplcm.nrdctabb%TYPE;

       --Variaveis do ipmf
       vr_txcpmfcc  NUMBER:= 0;
       vr_txrdcpmf  NUMBER:= 0;
       vr_indabono  NUMBER:= 0;
       vr_dtinipmf  DATE;
       vr_dtfimpmf  DATE;
       vr_dtiniabo  DATE;


       --Variaveis de Datas
       vr_dtmvtolt  DATE;
       vr_dtmvtopr  DATE;
       vr_dtmvtoan  DATE;
       vr_dtultdia  DATE;

       --Variaveis para relatorios
       vr_tot_vlutiliz NUMBER:= 0;
       vr_tot_vlsaqblq NUMBER:= 0;
       vr_tot_vladiant NUMBER:= 0;
       vr_rel_vlmaidep NUMBER:= 0;
       vr_rel_vlsldneg NUMBER:= 0;
       vr_rel_vlsdbltl NUMBER:= 0;
       vr_rel_vlstotal NUMBER:= 0;
       vr_rel_vlstotal_006 NUMBER:= 0;
       vr_rel_vlsddisp_006 NUMBER:= 0;	   
       vr_rel_vlestour NUMBER:= 0;
       vr_rel_vlblqjud NUMBER:= 0;
       vr_rel_dslimite VARCHAR2(100);
       vr_rel_dsdacstp VARCHAR2(11);
       vr_rel_nrdofone VARCHAR2(400);
       vr_rel_nrcpfcgc VARCHAR2(20);

       --Variaveis de controle do programa
       vr_cdprogra    VARCHAR2(10);
       vr_cdcritic    NUMBER:= 0;
       vr_dscritic    VARCHAR2(4000);
       vr_des_erro    VARCHAR2(4000);
       vr_nom_arquivo VARCHAR2(100);
       vr_setlinha    VARCHAR2(400);
       vr_nom_direto  VARCHAR2(400);
       vr_dssuftot    CONSTANT crapprm.dsvlrprm%TYPE := gene0001.fn_param_sistema('CRED',pr_cdcooper,'SUFIXO_RELATO_TOTAL');

       --Variaveis de indice para as tabelas de memoria
       vr_index_crat007   VARCHAR2(20);
       vr_index_crat225   VARCHAR2(15);
       vr_index_crat226   VARCHAR2(15);
       vr_index_crat030   VARCHAR2(15);
       vr_index_crat006   VARCHAR2(15);
       vr_index_detalhe   VARCHAR2(25);
       vr_index_control   NUMBER;
       vr_index_atrasados VARCHAR2(35);
       vr_index_craptfc   VARCHAR2(25);
       vr_index_crapttl   VARCHAR2(20);
       vr_index_crapsli   VARCHAR2(20);
       vr_index_crapcor   VARCHAR2(20);
       vr_index_crapepr   VARCHAR2(20);
       vr_index_crapage   NUMBER:= 0;
       vr_index_crat055   VARCHAR2(25);
       vr_index_totais    VARCHAR2(45);
       vr_index_crat007_final VARCHAR2(15);

       -- Variável para armazenar as informações em XML
       vr_des_xml   CLOB;       
       vr_dstexto   VARCHAR2(32700);
       vr_des_chave VARCHAR2(400);

       --Variaveis de Excecao
       vr_exc_saida  EXCEPTION;
       vr_exc_fimprg EXCEPTION;
       vr_exc_pula   EXCEPTION;

       -- variáveis projeto ligeirinho
        vr_ds_xml               TBGEN_BATCH_RELATORIO_WRK.DSXML%TYPE;
        ds_character_separador  VARCHAR2(1):='#';
        vr_indice_crat030       VARCHAR2(50);
        vr_indice_crat225       VARCHAR2(50);
        vr_indice_crat226       VARCHAR2(50);
        vr_indice_crat006       VARCHAR2(50);
        vr_indice_crat372       VARCHAR2(50);
        vr_indice_crattotais    VARCHAR2(50);  
        
        -- Qtde parametrizada de Jobs
        vr_qtdjobs       number;
        -- Job name dos processos criados
        vr_jobname       varchar2(30);  
        -- ID para o paralelismo
        vr_idparale      integer;
        -- Bloco PLSQL para chamar a execução paralela do pc_crps750
        vr_dsplsql       varchar2(4000);  
        vr_inproces      crapdat.inproces%type;
        --Código de controle retornado pela rotina gene0001.pc_grava_batch_controle
        vr_idcontrole    tbgen_batch_controle.idcontrole%TYPE;  
        vr_idlog_ini_ger tbgen_prglog.idprglog%type;
        vr_idlog_ini_par tbgen_prglog.idprglog%type;    
        vr_tpexecucao    tbgen_prglog.tpexecucao%type; 
        vr_qterro        number := 0;
        
        
        


      --> Controla log proc_batch, atualizando parâmetros conforme tipo de ocorrência
      PROCEDURE pc_gera_log(pr_cdcooper      IN crapcop.cdcooper%TYPE,
                            pr_dstiplog      IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                            pr_dscritic      IN VARCHAR2 DEFAULT NULL,
                            pr_cdcriticidade IN tbgen_prglog_ocorrencia.cdcriticidade%type DEFAULT 0,
                            pr_cdmensagem    IN tbgen_prglog_ocorrencia.cdmensagem%type DEFAULT 0,
                            pr_ind_tipo_log  IN tbgen_prglog_ocorrencia.tpocorrencia%type DEFAULT 2) IS

        -----------------------------------------------------------------------------------------------------------
        --
        --  Programa : pc_gera_log
        --  Sistema  : Rotina para gravar logs em tabelas
        --  Sigla    : CRED
        --  Autor    : Ana Lúcia E. Volles - Envolti
        --  Data     : Janeiro/2018          Ultima atualizacao: 16/01/2018
        --  Chamado  : 822997
        --
        -- Dados referentes ao programa:
        -- Frequencia: Rotina executada em qualquer frequencia.
        -- Objetivo  : Controla gravação de log em tabelas.
        --
        -- Alteracoes:  
        --             
        ------------------------------------------------------------------------------------------------------------   
      BEGIN     
        --> Controlar geração de log de execução dos jobs
        --Como executa na cadeira, utiliza pc_gera_log_batch
        btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper                      
                                  ,pr_ind_tipo_log  => pr_ind_tipo_log
                                  ,pr_nmarqlog      => 'proc_batch.log'                 
                                  ,pr_dstiplog      => NVL(pr_dstiplog,'E')             
                                  ,pr_cdprograma    => vr_cdprogra                      
                                  ,pr_tpexecucao    => 1 -- batch                       
                                  ,pr_cdcriticidade => pr_cdcriticidade                      
                                  ,pr_cdmensagem    => pr_cdmensagem                      
                                  ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - ' 
                                                      || vr_cdprogra || ' --> '|| pr_dscritic);
      EXCEPTION  
        WHEN OTHERS THEN  
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
      END pc_gera_log;
      --

       --Funcao para concatenar os telefones da conta
       FUNCTION fn_concatena_fones (pr_cdcooper IN crapdat.cdcooper%TYPE
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE
                                   ,pr_inpessoa IN crapass.inpessoa%TYPE) RETURN VARCHAR2 IS

         /*Variaveis locais */
         vr_nrdofone VARCHAR2(100);
         vr_tptelefo INTEGER;
         vr_exc_erro EXCEPTION;

       BEGIN
          -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
          GENE0001.pc_set_modulo(pr_module => 'PC_CRPS005.fn_concatena_fones' ,pr_action => NULL);

         --Se for pessoa fisica
         IF pr_inpessoa = 1 THEN
           --Tipo do telefone residencial
           vr_tptelefo:= 1;
         ELSE
           --Tipo do telefone comercial
           vr_tptelefo:= 3;
         END IF;

         --Montar indice para selecionar telefone no vetor
         vr_index_craptfc:= LPad(pr_cdcooper,10,'0')||
                            LPad(pr_nrdconta,10,'0')||
                            LPad(vr_tptelefo,05,'0');

         --Verificar se o telefone existe no vetor
         IF vr_tab_craptfc.EXISTS(vr_index_craptfc) THEN
           --Concatenar telefones
           vr_nrdofone:= vr_tab_craptfc(vr_index_craptfc).nrdddtfc||vr_tab_craptfc(vr_index_craptfc).nrtelefo;
         END IF;

         --Montar indice para selecionar telefone celular
         vr_index_craptfc:= LPad(pr_cdcooper,10,'0')||
                            LPad(pr_nrdconta,10,'0')||
                            LPad(2,05,'0');

         --Verificar se o telefone celular existe
         IF vr_tab_craptfc.EXISTS(vr_index_craptfc) THEN
           --Se ja existirem telefones encontrados
           IF vr_nrdofone IS NOT NULL THEN
             --Concatenar uma barra no telefone
             vr_nrdofone:= vr_nrdofone||'/';
           END IF;
           --Concatenar telefones
           vr_nrdofone:= vr_nrdofone||vr_tab_craptfc(vr_index_craptfc).nrtelefo;

         END IF;

         --Se nao encontrou telefone
         IF vr_nrdofone IS NULL THEN
           --Se for pessoa fisica
           IF pr_inpessoa = 1 THEN
             --Tipo do telefone comercial
             vr_tptelefo:= 3;
           ELSE
             --Tipo de telefone residencial
             vr_tptelefo:= 1;
           END IF;

           --Montar indice para selecionar telefone no vetor
           vr_index_craptfc:= LPad(pr_cdcooper,10,'0')||
                              LPad(pr_nrdconta,10,'0')||
                              LPad(vr_tptelefo,05,'0');

           --Verificar se o telefone existe no vetor
           IF vr_tab_craptfc.EXISTS(vr_index_craptfc) THEN
             --Concatenar telefones
             vr_nrdofone:= vr_tab_craptfc(vr_index_craptfc).nrdddtfc||vr_tab_craptfc(vr_index_craptfc).nrtelefo;
           END IF;
         END IF;

         RETURN vr_nrdofone;

       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_cdcritic := 9999;
           vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'pc_crps005.fn_concatena_fones. ' ||sqlerrm;

           --Inclusão na tabela de erros Oracle - Chamado 822997
           CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);

           --Sair do programa
           RAISE vr_exc_erro;
       END;

       -- Função para totalizar valores da conta de Investimento
       FUNCTION fn_totalizar_conta_inves(pr_cdcooper IN crapcop.cdcooper%TYPE             
                                        ,pr_inpessoa IN crapass.inpessoa%TYPE) RETURN NUMBER IS

         vr_tot_conta NUMBER := 0;    
         vr_exc_erro EXCEPTION;            
         
         -- Sumariação da Conta Investimento P307
           CURSOR cr_crapsli2 (pr_cdcooper IN crapsli.cdcooper%TYPE
                              ,pr_inpessoa IN crapass.inpessoa%TYPE) IS
           SELECT ass.inpessoa
                 ,SUM(sli.vlsddisp) vlsddisp
             FROM crapsli sli
                 ,crapass ass
            WHERE ass.cdcooper = sli.cdcooper
              AND ass.nrdconta = sli.nrdconta
              AND ass.inpessoa = pr_inpessoa
              AND sli.cdcooper = pr_cdcooper
              AND sli.vlsddisp <> 0
              AND sli.dtrefere = rw_crapdat.dtultdia
         GROUP BY ass.inpessoa;
         rw_crapsli2 cr_crapsli2%ROWTYPE;                                                                                
                                                
         BEGIN
         -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
         GENE0001.pc_set_modulo(pr_module => 'PC_CRPS005.fn_totalizar_conta_inves' ,pr_action => NULL);
           
         OPEN cr_crapsli2 (pr_cdcooper => pr_cdcooper
                          ,pr_inpessoa => pr_inpessoa);
         FETCH cr_crapsli2 INTO rw_crapsli2;
         IF cr_crapsli2%FOUND THEN
           vr_tot_conta := rw_crapsli2.vlsddisp;
         END IF;
         CLOSE cr_crapsli2;
         
         RETURN vr_tot_conta;
         
       EXCEPTION
         WHEN OTHERS THEN
            vr_cdcritic := 9999;
            vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'pc_crps005.fn_totalizar_conta_inves. ' ||sqlerrm;

           --Inclusão na tabela de erros Oracle - Chamado 822997
           CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);

           RAISE vr_exc_erro;         
       END;          
       --
       
       --Procedure para gravar movimentos Ci
       PROCEDURE pc_grava_movimentos_ci (pr_cdcooper IN crapass.cdcooper%TYPE
                                        ,pr_cdagenci IN crapass.cdagenci%TYPE
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE
                                        ,pr_cdempres IN craptab.cdempres%TYPE
                                        ,pr_nmprimtl IN crapass.nmprimtl%TYPE
                                        ,pr_inpessoa IN crapass.inpessoa%TYPE
                                        ,pr_cdturnos IN crapttl.cdturnos%TYPE
                                        ,pr_des_erro OUT VARCHAR2) IS

         --Variaveis Locais
         vr_index_crat372 VARCHAR2(15);
         vr_nrdofone      VARCHAR2(400);

       BEGIN
         -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
         GENE0001.pc_set_modulo(pr_module => 'PC_CRPS005.pc_grava_movimentos_ci' ,pr_action => NULL);

         --Inicializar variavel de erro
         pr_des_erro:= NULL;

         --Montar indice para selecionar os saldos de investimento
         vr_index_crapsli:= LPad(pr_cdcooper,10,'0')||LPad(pr_nrdconta,10,'0');

         --Selecionar informacoes dos saldos de investimento
         --Se encontrou saldo e o valor disponivel é diferente zero
         IF vr_tab_crapsli.EXISTS(vr_index_crapsli) AND vr_tab_crapsli(vr_index_crapsli).vlsddisp <> 0 THEN

           --Concatenar os numeros de telefone
           vr_nrdofone:= fn_concatena_fones (pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_inpessoa => pr_inpessoa);

           --Encontrar proximo registro do vetor agencia:99999 + conta:9999999999
           vr_index_crat372:= lpad(pr_cdagenci,5,'0')||lpad(pr_nrdconta,10,'0');
           --Popular vetor de memória crat372
           vr_tab_crat372(vr_index_crat372).cdturnos:= pr_cdturnos;
           vr_tab_crat372(vr_index_crat372).cdagenci:= pr_cdagenci;
           vr_tab_crat372(vr_index_crat372).nrdconta:= pr_nrdconta;
           vr_tab_crat372(vr_index_crat372).cdempres:= pr_cdempres;
           vr_tab_crat372(vr_index_crat372).vlsddisp:= vr_tab_crapsli(vr_index_crapsli).vlsddisp;
           vr_tab_crat372(vr_index_crat372).nmprimtl:= pr_nmprimtl;
           vr_tab_crat372(vr_index_crat372).nrdofone:= vr_nrdofone;
         END IF;

       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
            vr_cdcritic := 9999;
            pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'pc_crps005.pc_grava_movimentos_ci. ' ||sqlerrm;

            --Inclusão na tabela de erros Oracle - Chamado 822997
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
       END;
       --

       --Procedure para criar registro na tabela temporaria crat071
       PROCEDURE pc_cria_crat071 (pr_cdagenci IN crapass.cdagenci%TYPE
                                 ,pr_nrdconta IN crapsld.nrdconta%TYPE
                                 ,pr_cdempres IN craptab.cdempres%TYPE
                                 ,pr_dsdacstp IN VARCHAR2
                                 ,pr_nrdofone IN VARCHAR2
                                 ,pr_vlsddisp IN NUMBER
                                 ,pr_vlstotal IN NUMBER
                                 ,pr_nmprimtl IN crapass.nmprimtl%TYPE
                                 ,pr_cdturnos IN crapttl.cdturnos%TYPE
                                 ,pr_des_erro OUT VARCHAR2) IS
         --Variaveis Locais
         vr_index_crat071 VARCHAR2(15);

       BEGIN
         -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
         GENE0001.pc_set_modulo(pr_module => 'PC_CRPS005.pc_cria_crat071' ,pr_action => NULL);

         --Inicializar variavel de erro
         pr_des_erro:= NULL;

         --Determinar indice para proximo registro  agencia:99999 + conta:9999999999
         vr_index_crat071:= lpad(pr_cdagenci,5,'0')||lpad(pr_nrdconta,10,'0');
         --Criar registro na crat071
         vr_tab_crat071(vr_index_crat071).cdagenci:= pr_cdagenci;
         vr_tab_crat071(vr_index_crat071).nrdconta:= pr_nrdconta;
         vr_tab_crat071(vr_index_crat071).nrdofone:= pr_nrdofone;
         vr_tab_crat071(vr_index_crat071).cdempres:= pr_cdempres;
         vr_tab_crat071(vr_index_crat071).dsdacstp:= pr_dsdacstp;
         vr_tab_crat071(vr_index_crat071).vlsddisp:= pr_vlsddisp;
         vr_tab_crat071(vr_index_crat071).nmprimtl:= pr_nmprimtl;
         vr_tab_crat071(vr_index_crat071).vlstotal:= pr_vlstotal;

         --Se o turno nao for nulo
         IF pr_cdturnos IS NOT NULL THEN
           vr_tab_crat071(vr_index_crat071).cdturnos:= pr_cdturnos;
         END IF;

       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_cdcritic := 9999;
           pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'pc_crps005.pc_cria_crat071. ' ||sqlerrm;

           --Inclusão na tabela de erros Oracle - Chamado 822997
           CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
       END;
       --

       --Procedure para limpar os dados das tabelas de memoria
       PROCEDURE pc_limpa_tabela IS

         vr_exc_erro  EXCEPTION;

       BEGIN
         -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
         GENE0001.pc_set_modulo(pr_module => 'PC_CRPS005.pc_limpa_tabela' ,pr_action => NULL);

         --Tabelas de memoria para melhora performance
         vr_tab_craptfc.DELETE;
         vr_tab_crapttl.DELETE;
         vr_tab_crapsli.DELETE;
         vr_tab_crapass.DELETE;
         vr_tab_crapcor.DELETE;
         vr_tab_crapepr.DELETE;
         vr_tab_crapage.DELETE;

         --Tabelas de memoria dos relatorios
         vr_tab_tot_qtcstdct.DELETE;
         vr_tab_tot_vlcstdct.DELETE;
         vr_tab_tot_agnvlbjd.DELETE;
         vr_tab_craplcm_cta.DELETE;
         vr_tab_gn099.DELETE;
         vr_tab_gn006.DELETE;
         vr_tab_crat372.DELETE;
         vr_tab_crat006.DELETE;
         vr_tab_crat055.DELETE;
         vr_tab_crat030.DELETE;
         vr_tab_crat071.DELETE;
         vr_tab_crat007.DELETE;
         vr_tab_crat225.DELETE;
         vr_tab_crat226.DELETE;
         vr_tab_crapsld.DELETE;
         vr_tab_detalhes.DELETE;
         vr_tab_atrasados.DELETE;
         vr_tab_totais.DELETE;
         vr_tab_totais_final.DELETE;
         vr_tab_cta_bndes.DELETE;
         vr_tab_dem_agpsdmax.DELETE;
         vr_tab_dem_agpsddis.DELETE;
         vr_tab_dem_agpvllim.DELETE;
         vr_tab_dem_agpsdbtl.DELETE;
         vr_tab_dem_agpsdchs.DELETE;
         vr_tab_dem_agpsdstl.DELETE;
         vr_tab_dem_agpvlbjd.DELETE;
         vr_tab_rel_agpsdmax.DELETE;
         vr_tab_rel_agpsddis.DELETE;
         vr_tab_rel_agpvllim.DELETE;
         vr_tab_rel_agpsdbtl.DELETE;
         vr_tab_rel_agpsdchs.DELETE;
         vr_tab_rel_agpsdstl.DELETE;
         vr_tab_rel_vlsaqblq.DELETE;
         vr_tab_rel_vlbloque.DELETE;
         vr_tab_rel_vldisneg.DELETE;
         vr_tab_rel_vldispos.DELETE;
         vr_tab_rel_vlsutili.DELETE;
         vr_tab_rel_vlblqjud.DELETE;
         vr_tab_rel_vlsadian.DELETE;
         vr_tab_rel_vladiclq.DELETE;
         vr_tab_rel_agnsddis.DELETE;
         vr_tab_rel_agnvllim.DELETE;
         vr_tab_rel_agnsdbtl.DELETE;
         vr_tab_rel_agnsdchs.DELETE;
         vr_tab_rel_agnsdstl.DELETE;
         vr_tab_rel_agpsdbjd.DELETE;
         vr_tab_rel_agpvlbjd.DELETE;
         vr_tab_contab.DELETE; -- projeto ligeirinho

       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_cdcritic := 9999;
           vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'pc_crps005.pc_limpa_tabela. ' ||sqlerrm;

           --Inclusão na tabela de erros Oracle - Chamado 822997
           CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);

           --Sair do programa
           RAISE vr_exc_erro;
       END;
       --

       --Inicializar tabelas de memoria por tipo de pessoa
       PROCEDURE pc_inicializa_tabela IS

         vr_exc_erro  EXCEPTION;

       BEGIN
         -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
         GENE0001.pc_set_modulo(pr_module => 'PC_CRPS005.pc_inicializa_tabela' ,pr_action => NULL);

         --Zerar as 4 primeiras posicoes dos vetores
         FOR idx IN 1..4 LOOP
           vr_tab_rel_agpsdmax(idx):= 0;
           vr_tab_rel_agpsddis(idx):= 0;
           vr_tab_rel_agpvllim(idx):= 0;
           vr_tab_rel_agpsdbtl(idx):= 0;
           vr_tab_rel_agpsdchs(idx):= 0;
           vr_tab_rel_agpsdstl(idx):= 0;
           vr_tab_rel_agnsdchs(idx):= 0;
           vr_tab_rel_vlsaqblq(idx):= 0;
           vr_tab_rel_vlbloque(idx):= 0;
           vr_tab_rel_vldisneg(idx):= 0;
           vr_tab_rel_vldispos(idx):= 0;
           vr_tab_rel_vlsutili(idx):= 0;
           vr_tab_rel_vlblqjud(idx):= 0;
           vr_tab_rel_vlsadian(idx):= 0;
           vr_tab_rel_vlsldliq(idx):= 0;
           vr_tab_rel_vladiclq(idx):= 0;
           vr_tab_rel_agnsddis(idx):= 0;
           vr_tab_rel_agnvllim(idx):= 0;
           vr_tab_rel_agnsdbtl(idx):= 0;
           vr_tab_rel_agnsdstl(idx):= 0;
           vr_tab_rel_agpsdbjd(idx):= 0;
           vr_tab_rel_agpvlbjd(idx):= 0;
         END LOOP;
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_cdcritic := 9999;
           vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'pc_crps005.pc_inicializa_tabela. ' ||sqlerrm;

           --Inclusão na tabela de erros Oracle - Chamado 822997
           CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);

           --Sair do programa
           RAISE vr_exc_erro;
       END;

       ----------------------------------------------
       -- Rotina para popular tabela de trabalho
       -- Projeto Ligeirinho
       ----------------------------------------------
       PROCEDURE pc_popular_tbgen_batch_rel_wrk (pr_cdcooper     in tbgen_batch_relatorio_wrk.cdcooper%type,
                                                 pr_nmtabmemoria in tbgen_batch_relatorio_wrk.cdprograma%type,
                                                 pr_dtmvtolt     in tbgen_batch_relatorio_wrk.dtmvtolt%type,
                                                 pr_dschave      in tbgen_batch_relatorio_wrk.dschave%type,
                                                 pr_dsxml        in tbgen_batch_relatorio_wrk.dsxml%type,
                                                 pr_des_erro     out varchar2) is
                                                 
                                                 
       begin
          insert into tbgen_batch_relatorio_wrk
              (cdcooper
              ,cdprograma 
              ,dsrelatorio
              ,dtmvtolt
              ,cdagenci
              ,nrdconta
              ,dschave
              ,dsxml) 
            values 
             (pr_cdcooper
             ,'CRPS005'
             ,pr_nmtabmemoria
             ,pr_dtmvtolt
             ,99999
             ,9999999999
             ,pr_dschave 
             ,pr_dsxml);
       
        commit;
       EXCEPTION
         WHEN OTHERS THEN
          --Montar mensagem de erro
          pr_des_erro:= 'Erro ao inserir na tabela tbgen_batch_relatorio_wrk. '||SQLERRM;
       END pc_popular_tbgen_batch_rel_wrk;

       ----------------------------------------------
       -- Rotina para limpar tabela de trabalho WRK
       -- Projeto Ligeirinho
       ----------------------------------------------
       PROCEDURE pc_limpa_tbgen_batch_rel_wrk (pr_cdcooper   in tbgen_batch_relatorio_wrk.cdcooper%type,
                                               pr_dtmvtolt   in tbgen_batch_relatorio_wrk.dtmvtolt%type,
                                               pr_des_erro  out varchar2) is
                                                 
                                                 
       begin
          delete tbgen_batch_relatorio_wrk
            where cdcooper   = pr_cdcooper
              and cdprograma = 'CRPS005'
              and dtmvtolt   = pr_dtmvtolt
              and cdagenci   = 99999
              and nrdconta   = 9999999999;
        commit;
       EXCEPTION
         WHEN OTHERS THEN
          --Montar mensagem de erro
          pr_des_erro:= 'Erro ao limpar na tabela tbgen_batch_relatorio_wrk. '||SQLERRM;
       END pc_limpa_tbgen_batch_rel_wrk;
       
       -------------------------------------------------------------
       -- Grava os dados da tabela de trabalho na tabela de memoria
       -- para serem utilizados pelos relatórios
       -- Projeto Ligeirinho 
       -------------------------------------------------------------
       PROCEDURE pc_grava_tab_men_geral (pr_cdcooper in tbgen_batch_relatorio_wrk.cdcooper%type,
                                         pr_dtmvtolt in tbgen_batch_relatorio_wrk.dtmvtolt%type,
                                         pr_des_erro out varchar2) IS
                                         
       -- cursores que lê a tabela WRK, de acordo com a tabela de memória a ser populada                                         
       cursor c_crapage2 is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) cdagenci,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,2) +1,instr(tab.dsxml,'#',1,3)-instr(tab.dsxml,'#',1,2)-1) nmresage,
              tab.dschave vr_indice
         from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                      wrk.dschave 
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_CRAPAGE'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;
               
       -- VR_TAB_CRAPTFC
       cursor c_craptfc is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) nrdddtfc,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,2) +1,instr(tab.dsxml,'#',1,3)-instr(tab.dsxml,'#',1,2)-1) nrtelefo,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,3) +1,instr(tab.dsxml,'#',1,4)-instr(tab.dsxml,'#',1,3)-1) vr_indice
         from (select  wrk.dschave dsxml
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_CRAPTFC'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;

       -- VR_TAB_CRAPTTL
       cursor c_crapttl is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) cdempres,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,2) +1,instr(tab.dsxml,'#',1,3)-instr(tab.dsxml,'#',1,2)-1) cdturnos,
              tab.dschave vr_indice
         from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                      wrk.dschave 
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_CRAPTTL'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;

       -- VR_TAB_CRAPSLI
       cursor c_crapsli is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vlsddisp,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,2) +1,instr(tab.dsxml,'#',1,3)-instr(tab.dsxml,'#',1,2)-1) vr_indice
         from (select wrk.dschave dsxml
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_CRAPSLI'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;
               
       -- VR_TAB_CRAPCOR
       cursor c_crapcor is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,2) +1,instr(tab.dsxml,'#',1,3)-instr(tab.dsxml,'#',1,2)-1) vr_indice
         from (select wrk.dschave dsxml
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_CRAPCOR'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;

       -- VR_TAB_CRAPEPR
       cursor c_crapepr is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,2) +1,instr(tab.dsxml,'#',1,3)-instr(tab.dsxml,'#',1,2)-1) vr_indice
         from (select wrk.dschave dsxml
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_CRAPEPR'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;


       -- VR_TAB_CRAPSLD
       cursor c_crapsld is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vlsdbloq,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,2) +1,instr(tab.dsxml,'#',1,3)-instr(tab.dsxml,'#',1,2)-1) vlsdblpr,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,3) +1,instr(tab.dsxml,'#',1,4)-instr(tab.dsxml,'#',1,3)-1) vlsdblfp,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,4) +1,instr(tab.dsxml,'#',1,5)-instr(tab.dsxml,'#',1,4)-1) vlsdchsl,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,5) +1,instr(tab.dsxml,'#',1,6)-instr(tab.dsxml,'#',1,5)-1) vlsddisp,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,6) +1,instr(tab.dsxml,'#',1,7)-instr(tab.dsxml,'#',1,6)-1) vlipmfpg,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,7) +1,instr(tab.dsxml,'#',1,8)-instr(tab.dsxml,'#',1,7)-1) vlipmfap,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,8) +1,instr(tab.dsxml,'#',1,9)-instr(tab.dsxml,'#',1,8)-1) dtdsdclq,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,9) +1,instr(tab.dsxml,'#',1,10)-instr(tab.dsxml,'#',1,9)-1) qtddsdev,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,10)+1,instr(tab.dsxml,'#',1,11)-instr(tab.dsxml,'#',1,10)-1) vlblqjud,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,11) +1,instr(tab.dsxml,'#',1,12)-instr(tab.dsxml,'#',1,11)-1) vlsldtot,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,12)+1,instr(tab.dsxml,'#',1,13)-instr(tab.dsxml,'#',1,12)-1) vr_rowid,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,13)+1,instr(tab.dsxml,'#',1,14)-instr(tab.dsxml,'#',1,13)-1) vr_vlblqprj,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,14)+1,instr(tab.dsxml,'#',1,15)-instr(tab.dsxml,'#',1,14)-1) vr_indice
         from (select wrk.dschave dsxml
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_CRAPSLD'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;

               
       --  VR_TAB_LIS_AGNSDBTL       
       cursor c_agnsdbtl is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
              tab.dschave vr_indice
         from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                      wrk.dschave 
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_LIS_AGNSDBTL'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;      

       -- Saldo total da agencia - VR_TAB_LIS_AGNSDSTL
       cursor c_agnsdstl is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
              tab.dschave vr_indice
         from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                      wrk.dschave 
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_LIS_AGNSDSTL'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab; 
          
       -- Total disponivel da agencia - VR_TAB_LIS_AGNSDDIS
       cursor c_agnsddis is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,2) +1,instr(tab.dsxml,'#',1,3)-instr(tab.dsxml,'#',1,2)-1) vr_indice
         from (select wrk.dschave dsxml
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_LIS_AGNSDDIS'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab; 
               
        -- Total do limite da agencia - VR_TAB_LIS_AGNVLLIM
       cursor c_agnvllim is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,2) +1,instr(tab.dsxml,'#',1,3)-instr(tab.dsxml,'#',1,2)-1) vr_indice
         from (select wrk.dschave dsxml
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_LIS_AGNVLLIM'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab; 

       -- VR_TAB_CONTAB
       cursor c_contab is
       select SUM(con_vlsaqblq ) con_vlsaqblq,
              SUM(con_vladiant) con_vladiant,
              SUM(con_vlutiliz) con_vlutiliz
         from (select substr(tab.dsxml,instr(tab.dsxml,'#',1,2) +1,instr(tab.dsxml,'#',1,3)-instr(tab.dsxml,'#',1,2)-1) con_vlsaqblq,
                      substr(tab.dsxml,instr(tab.dsxml,'#',1,3) +1,instr(tab.dsxml,'#',1,4)-instr(tab.dsxml,'#',1,3)-1) con_vladiant,
                      substr(tab.dsxml,instr(tab.dsxml,'#',1,4) +1,instr(tab.dsxml,'#',1,5)-instr(tab.dsxml,'#',1,4)-1) con_vlutiliz,
                      tab.dschave vr_indice
                 from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                              wrk.dschave 
                         from tbgen_batch_relatorio_wrk wrk
                        where wrk.cdcooper    = pr_cdcooper
                          and wrk.cdprograma  = 'CRPS005'
                          and wrk.dsrelatorio = 'VR_TAB_CONTAB'
                          and wrk.dtmvtolt    = pr_dtmvtolt
                          and wrk.cdagenci    = 99999
                          and wrk.nrdconta    = 9999999999
                          and wrk.dschave   <> '999'
                       ) tab
                );
                 

       BEGIN
         BEGIN
           -- Agencias
           FOR r_crapage2 IN c_crapage2  
           LOOP
               --Criar registro na crapage
               vr_tab_crapage(r_crapage2.vr_indice).cdagenci:= r_crapage2.cdagenci;
               vr_tab_crapage(r_crapage2.vr_indice).nmresage:= r_crapage2.nmresage;
           END LOOP;
                                   
           -- VR_TAB_CRAPTFC
           FOR r_craptfc IN c_craptfc  
           LOOP
               --Criar registro na vr_tab_craptfc
               vr_tab_craptfc(r_craptfc.vr_indice).nrdddtfc:= r_craptfc.nrdddtfc;
               vr_tab_craptfc(r_craptfc.vr_indice).nrtelefo:= r_craptfc.nrtelefo;
           END LOOP;

           -- VR_TAB_CRAPTTL
           FOR r_crapttl IN c_crapttl  
           LOOP
               --Criar registro na vr_tab_crapttl
               vr_tab_crapttl(r_crapttl.vr_indice).cdempres:= r_crapttl.cdempres;
               vr_tab_crapttl(r_crapttl.vr_indice).cdturnos:= r_crapttl.cdturnos;
           END LOOP;

           -- VR_TAB_CRAPSLI
           FOR r_crapsli IN c_crapsli  
           LOOP
               --Criar registro na vr_tab_crapsli
              vr_tab_crapsli(r_crapsli.vr_indice).vlsddisp:= r_crapsli.vlsddisp;
           END LOOP;
           
           -- VR_TAB_CRAPCOR
           FOR r_crapcor IN c_crapcor  
           LOOP
               --Criar registro na vr_tab_crapcor
               vr_tab_crapcor(r_crapcor.vr_indice):= r_crapcor.vr_total;
           END LOOP;

           -- VR_TAB_CRAPEPR
           FOR r_crapepr IN c_crapepr  
           LOOP
               --Criar registro na vr_tab_crapepr
               vr_tab_crapepr(r_crapepr.vr_indice):= r_crapepr.vr_total;
           END LOOP;

           -- vr_tab_crapsld
           FOR r_crapsld IN c_crapsld  
           LOOP
               --Criar registro na vr_tab_crapsld
               vr_tab_crapsld(r_crapsld.vr_indice).vlsdbloq := r_crapsld.vlsdbloq;
               vr_tab_crapsld(r_crapsld.vr_indice).vlsdblpr := r_crapsld.vlsdblpr;
               vr_tab_crapsld(r_crapsld.vr_indice).vlsdblfp := r_crapsld.vlsdblfp;
               vr_tab_crapsld(r_crapsld.vr_indice).vlsdchsl := r_crapsld.vlsdchsl;
               vr_tab_crapsld(r_crapsld.vr_indice).vlsddisp := r_crapsld.vlsddisp;
               vr_tab_crapsld(r_crapsld.vr_indice).vlipmfpg := r_crapsld.vlipmfpg;
               vr_tab_crapsld(r_crapsld.vr_indice).vlipmfap := r_crapsld.vlipmfap;
               vr_tab_crapsld(r_crapsld.vr_indice).dtdsdclq := r_crapsld.dtdsdclq;
               vr_tab_crapsld(r_crapsld.vr_indice).qtddsdev := r_crapsld.qtddsdev;
               vr_tab_crapsld(r_crapsld.vr_indice).vlblqjud := r_crapsld.vlblqjud;
               vr_tab_crapsld(r_crapsld.vr_indice).vlsldtot := r_crapsld.vlsldtot;
               vr_tab_crapsld(r_crapsld.vr_indice).vr_rowid := r_crapsld.vr_rowid;
               vr_tab_crapsld(r_crapsld.vr_indice).vlblqprj := r_crapsld.vr_vlblqprj;
               
           END LOOP;

           -- Total bloqueado da agencia - VR_TAB_LIS_AGNSDBTL
           FOR r_agnsdbtl IN c_agnsdbtl  
           LOOP
               --Criar registro na vr_tab_lis_agnsdbtl
               vr_tab_lis_agnsdbtl(r_agnsdbtl.vr_indice):= r_agnsdbtl.vr_total;
           END LOOP;
       
           -- Saldo total da agencia - VR_TAB_LIS_AGNSDSTL
           FOR r_agnsdstl IN c_agnsdstl  
           LOOP
               --Criar registro na vr_tab_lis_agnsdbtl
               vr_tab_lis_agnsdstl(r_agnsdstl.vr_indice):= r_agnsdstl.vr_total;
           END LOOP;
         
           -- Total disponivel da agencia - VR_TAB_LIS_AGNSDDIS
           FOR r_agnsddis IN c_agnsddis  
           LOOP
               --Criar registro na vr_tab_lis_agnsdbtl
               vr_tab_lis_agnsddis(r_agnsddis.vr_indice):= r_agnsddis.vr_total;
           END LOOP;
         
           -- Total do limite da agencia - VR_TAB_LIS_AGNVLLIM
           FOR r_agnvllim IN c_agnvllim  
           LOOP
               --Criar registro na vr_tab_lis_agnvllim
               vr_tab_lis_agnvllim(r_agnvllim.vr_indice):= r_agnvllim.vr_total;
           END LOOP;

           -- VR_TAB_CONTAB
           FOR r_contab IN c_contab  
           LOOP
               --Criar registro na vr_tab_contab
               vr_tab_contab(1).cdagenci:= 99999;
               vr_tab_contab(1).con_vlsaqblq:= r_contab.con_vlsaqblq;
               vr_tab_contab(1).con_vladiant:= r_contab.con_vladiant;
               vr_tab_contab(1).con_vlutiliz:= r_contab.con_vlutiliz;                              
           END LOOP;

         EXCEPTION
           WHEN OTHERS THEN
              pr_des_erro:= 'Erro pc_grava_tab_men_geral: '||sqlerrm;
         END;
       END pc_grava_tab_men_geral;
       
       
       -------------------------------------------------------------
       -- Grava os dados da tabela de trabalho na tabela de memoria
       -- Projeto Ligeirinho 
       -------------------------------------------------------------
       PROCEDURE pc_grava_tab_men_crrl055 (pr_cdcooper in tbgen_batch_relatorio_wrk.cdcooper%type,
                                           pr_dtmvtolt in tbgen_batch_relatorio_wrk.dtmvtolt%type,
                                           pr_des_erro out varchar2) IS
       cursor c_crrl0551 is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) cdagenci,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,2) +1,instr(tab.dsxml,'#',1,3)-instr(tab.dsxml,'#',1,2)-1) nrdconta,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,3) +1,instr(tab.dsxml,'#',1,4)-instr(tab.dsxml,'#',1,3)-1) nmprimtl,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,4) +1,instr(tab.dsxml,'#',1,5)-instr(tab.dsxml,'#',1,4)-1) vlsddisp,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,5) +1,instr(tab.dsxml,'#',1,6)-instr(tab.dsxml,'#',1,5)-1) vllimcre,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,6) +1,instr(tab.dsxml,'#',1,7)-instr(tab.dsxml,'#',1,6)-1) vlsdbltl,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,7) +1,instr(tab.dsxml,'#',1,8)-instr(tab.dsxml,'#',1,7)-1) vlstotal,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,8) +1,instr(tab.dsxml,'#',1,9)-instr(tab.dsxml,'#',1,8)-1) dsdacstp,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,9) +1,instr(tab.dsxml,'#',1,10)-instr(tab.dsxml,'#',1,9)-1) nrcpfcgc,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,10) +1,instr(tab.dsxml,'#',1,11)-instr(tab.dsxml,'#',1,10)-1) vr_indice
         from (select wrk.dschave dsxml 
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_CRAT055'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;
       BEGIN
         BEGIN
           FOR r_crrl0551 IN c_crrl0551  
           LOOP
               --Criar registro na crat055
               vr_tab_crat055(r_crrl0551.vr_indice).cdagenci:= r_crrl0551.cdagenci;
               vr_tab_crat055(r_crrl0551.vr_indice).nrdconta:= r_crrl0551.nrdconta;
               vr_tab_crat055(r_crrl0551.vr_indice).dsdacstp:= r_crrl0551.dsdacstp;
               vr_tab_crat055(r_crrl0551.vr_indice).nmprimtl:= r_crrl0551.nmprimtl;
               vr_tab_crat055(r_crrl0551.vr_indice).nrcpfcgc:= r_crrl0551.nrcpfcgc;
               vr_tab_crat055(r_crrl0551.vr_indice).vllimcre:= r_crrl0551.vllimcre;
               vr_tab_crat055(r_crrl0551.vr_indice).vlsddisp:= r_crrl0551.vlsddisp;
               vr_tab_crat055(r_crrl0551.vr_indice).vlsdbltl:= r_crrl0551.vlsdbltl;
               vr_tab_crat055(r_crrl0551.vr_indice).vlstotal:= r_crrl0551.vlstotal;
               vr_tab_crat055(r_crrl0551.vr_indice).vlindice:= r_crrl0551.vr_indice; 
           END LOOP;
         EXCEPTION
           WHEN OTHERS THEN
              pr_des_erro:= 'Erro pc_grava_tab_men_crrl055: '||sqlerrm;
         END;
       END pc_grava_tab_men_crrl055;

       -------------------------------------------------------------
       -- Grava os dados da tabela de trabalho na tabela de memoria
       -- Projeto Ligeirinho 
       -------------------------------------------------------------
       PROCEDURE pc_grava_tab_men_crrl030 (pr_cdcooper in tbgen_batch_relatorio_wrk.cdcooper%type,
                                           pr_dtmvtolt in tbgen_batch_relatorio_wrk.dtmvtolt%type,
                                           pr_des_erro out varchar2) IS
       -- VR_TAB_CRAT030                                           
       cursor c_crrl0301 is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) cdagenci,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,2) +1,instr(tab.dsxml,'#',1,3)-instr(tab.dsxml,'#',1,2)-1) nrdconta,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,3) +1,instr(tab.dsxml,'#',1,4)-instr(tab.dsxml,'#',1,3)-1) nmprimtl,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,4) +1,instr(tab.dsxml,'#',1,5)-instr(tab.dsxml,'#',1,4)-1) vlsddisp,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,5) +1,instr(tab.dsxml,'#',1,6)-instr(tab.dsxml,'#',1,5)-1) vllimcre,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,6) +1,instr(tab.dsxml,'#',1,7)-instr(tab.dsxml,'#',1,6)-1) vlsdchsl,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,7) +1,instr(tab.dsxml,'#',1,8)-instr(tab.dsxml,'#',1,7)-1) dtdsdclq,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,8) +1,instr(tab.dsxml,'#',1,9)-instr(tab.dsxml,'#',1,8)-1) qtddsdev,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,9) +1,instr(tab.dsxml,'#',1,10)-instr(tab.dsxml,'#',1,9)-1) vlstotal,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,10) +1,instr(tab.dsxml,'#',1,11)-instr(tab.dsxml,'#',1,10)-1) vlsdbltl,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,11) +1,instr(tab.dsxml,'#',1,12)-instr(tab.dsxml,'#',1,11)-1) vr_indice
         from (select wrk.dschave dsxml
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_CRAT030'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;
       BEGIN
         BEGIN
           FOR r_crrl0301 IN c_crrl0301  
           LOOP
               --Criar registro na crat030
               vr_tab_crat030(r_crrl0301.vr_indice).cdagenci:= r_crrl0301.cdagenci;
               vr_tab_crat030(r_crrl0301.vr_indice).nrdconta:= r_crrl0301.nrdconta;
               vr_tab_crat030(r_crrl0301.vr_indice).nmprimtl:= r_crrl0301.nmprimtl;
               vr_tab_crat030(r_crrl0301.vr_indice).vlsddisp:= r_crrl0301.vlsddisp;
               vr_tab_crat030(r_crrl0301.vr_indice).vllimcre:= r_crrl0301.vllimcre;
               vr_tab_crat030(r_crrl0301.vr_indice).vlsdchsl:= r_crrl0301.vlsdchsl;
               vr_tab_crat030(r_crrl0301.vr_indice).dtdsdclq:= r_crrl0301.dtdsdclq; 
               vr_tab_crat030(r_crrl0301.vr_indice).qtddsdev:= r_crrl0301.qtddsdev;
               vr_tab_crat030(r_crrl0301.vr_indice).vlstotal:= r_crrl0301.vlstotal;
               vr_tab_crat030(r_crrl0301.vr_indice).vlsdbltl:= r_crrl0301.vlsdbltl;
           END LOOP;
         EXCEPTION
           WHEN OTHERS THEN
              pr_des_erro:= 'Erro pc_grava_tab_men_crrl030: '||sqlerrm;
         END;
       END pc_grava_tab_men_crrl030;


       PROCEDURE pc_grava_tab_men_crrl225 (pr_cdcooper in tbgen_batch_relatorio_wrk.cdcooper%type,
                                           pr_dtmvtolt in tbgen_batch_relatorio_wrk.dtmvtolt%type,
                                           pr_des_erro out varchar2) IS
       -- VR_TAB_CRAT225                                         
       cursor c_crrl2251 is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) cdagenci,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,2) +1,instr(tab.dsxml,'#',1,3)-instr(tab.dsxml,'#',1,2)-1) nrdconta,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,3) +1,instr(tab.dsxml,'#',1,4)-instr(tab.dsxml,'#',1,3)-1) nmprimtl,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,4) +1,instr(tab.dsxml,'#',1,5)-instr(tab.dsxml,'#',1,4)-1) cdempres,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,5) +1,instr(tab.dsxml,'#',1,6)-instr(tab.dsxml,'#',1,5)-1) cdturnos,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,6) +1,instr(tab.dsxml,'#',1,7)-instr(tab.dsxml,'#',1,6)-1) qtddsdev,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,7) +1,instr(tab.dsxml,'#',1,8)-instr(tab.dsxml,'#',1,7)-1) vlsddisp,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,8) +1,instr(tab.dsxml,'#',1,9)-instr(tab.dsxml,'#',1,8)-1) vllimcre,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,9) +1,instr(tab.dsxml,'#',1,10)-instr(tab.dsxml,'#',1,9)-1) nrdofone,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,10) +1,instr(tab.dsxml,'#',1,11)-instr(tab.dsxml,'#',1,10)-1) dsdacstp,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,11) +1,instr(tab.dsxml,'#',1,12)-instr(tab.dsxml,'#',1,11)-1) vlestour,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,12) +1,instr(tab.dsxml,'#',1,13)-instr(tab.dsxml,'#',1,12)-1) vlsdbltl,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,13) +1,instr(tab.dsxml,'#',1,14)-instr(tab.dsxml,'#',1,13)-1) vlstotal,
              tab.dschave vr_indice
         from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                      wrk.dschave 
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_CRAT225'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;
       BEGIN
         BEGIN
           FOR r_crrl2251 IN c_crrl2251  
           LOOP
               --Criar registro na crat225
               vr_tab_crat225(r_crrl2251.vr_indice).cdagenci:= r_crrl2251.cdagenci;
               vr_tab_crat225(r_crrl2251.vr_indice).nrdconta:= r_crrl2251.nrdconta;
               vr_tab_crat225(r_crrl2251.vr_indice).nmprimtl:= r_crrl2251.nmprimtl;
               vr_tab_crat225(r_crrl2251.vr_indice).cdempres:= r_crrl2251.cdempres;
               vr_tab_crat225(r_crrl2251.vr_indice).cdturnos:= r_crrl2251.cdturnos;
               vr_tab_crat225(r_crrl2251.vr_indice).qtddsdev:= r_crrl2251.qtddsdev;
               vr_tab_crat225(r_crrl2251.vr_indice).vlsddisp:= r_crrl2251.vlsddisp; 
               vr_tab_crat225(r_crrl2251.vr_indice).vllimcre:= r_crrl2251.vllimcre;
               vr_tab_crat225(r_crrl2251.vr_indice).nrdofone:= r_crrl2251.nrdofone;
               vr_tab_crat225(r_crrl2251.vr_indice).dsdacstp:= r_crrl2251.dsdacstp;
               vr_tab_crat225(r_crrl2251.vr_indice).vlestour:= r_crrl2251.vlestour;
               vr_tab_crat225(r_crrl2251.vr_indice).vlsdbltl:= r_crrl2251.vlsdbltl;
               vr_tab_crat225(r_crrl2251.vr_indice).vlstotal:= r_crrl2251.vlstotal;                                             
           END LOOP;
         EXCEPTION
           WHEN OTHERS THEN
              pr_des_erro:= 'Erro pc_grava_tab_men_crrl225: '||sqlerrm;
         END;
       END pc_grava_tab_men_crrl225;

       PROCEDURE pc_grava_tab_men_crrl226 (pr_cdcooper in tbgen_batch_relatorio_wrk.cdcooper%type,
                                           pr_dtmvtolt in tbgen_batch_relatorio_wrk.dtmvtolt%type,
                                           pr_des_erro out varchar2) IS
       --  VR_TAB_CRAT226                                          
       cursor c_crrl2261 is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) cdagenci,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,2) +1,instr(tab.dsxml,'#',1,3)-instr(tab.dsxml,'#',1,2)-1) nrdconta,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,3) +1,instr(tab.dsxml,'#',1,4)-instr(tab.dsxml,'#',1,3)-1) nmprimtl,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,4) +1,instr(tab.dsxml,'#',1,5)-instr(tab.dsxml,'#',1,4)-1) cdempres,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,5) +1,instr(tab.dsxml,'#',1,6)-instr(tab.dsxml,'#',1,5)-1) qtddsdev,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,6) +1,instr(tab.dsxml,'#',1,7)-instr(tab.dsxml,'#',1,6)-1) vlsddisp,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,7) +1,instr(tab.dsxml,'#',1,8)-instr(tab.dsxml,'#',1,7)-1) vllimcre,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,8) +1,instr(tab.dsxml,'#',1,9)-instr(tab.dsxml,'#',1,8)-1) cdturnos,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,9) +1,instr(tab.dsxml,'#',1,10)-instr(tab.dsxml,'#',1,9)-1) tpvincul,              
              substr(tab.dsxml,instr(tab.dsxml,'#',1,10) +1,instr(tab.dsxml,'#',1,11)-instr(tab.dsxml,'#',1,10)-1) dsdacstp,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,11) +1,instr(tab.dsxml,'#',1,12)-instr(tab.dsxml,'#',1,11)-1) vlestour,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,12) +1,instr(tab.dsxml,'#',1,13)-instr(tab.dsxml,'#',1,12)-1) vlsdbltl,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,13) +1,instr(tab.dsxml,'#',1,14)-instr(tab.dsxml,'#',1,13)-1) vlstotal,
              tab.dschave vr_indice
         from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                      wrk.dschave 
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_CRAT226'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;
       BEGIN
         BEGIN
           FOR r_crrl2261 IN c_crrl2261  
           LOOP
               --Criar registro na crat226
               vr_tab_crat226(r_crrl2261.vr_indice).cdagenci:= r_crrl2261.cdagenci;
               vr_tab_crat226(r_crrl2261.vr_indice).nrdconta:= r_crrl2261.nrdconta;
               vr_tab_crat226(r_crrl2261.vr_indice).nmprimtl:= r_crrl2261.nmprimtl;
               vr_tab_crat226(r_crrl2261.vr_indice).cdempres:= r_crrl2261.cdempres;
               vr_tab_crat226(r_crrl2261.vr_indice).qtddsdev:= r_crrl2261.qtddsdev;
               vr_tab_crat226(r_crrl2261.vr_indice).vlsddisp:= r_crrl2261.vlsddisp; 
               vr_tab_crat226(r_crrl2261.vr_indice).vllimcre:= r_crrl2261.vllimcre;
               vr_tab_crat226(r_crrl2261.vr_indice).cdturnos:= r_crrl2261.cdturnos;
               vr_tab_crat226(r_crrl2261.vr_indice).tpvincul:= r_crrl2261.tpvincul;
               vr_tab_crat226(r_crrl2261.vr_indice).dsdacstp:= r_crrl2261.dsdacstp;
               vr_tab_crat226(r_crrl2261.vr_indice).vlestour:= r_crrl2261.vlestour;
               vr_tab_crat226(r_crrl2261.vr_indice).vlsdbltl:= r_crrl2261.vlsdbltl;
               vr_tab_crat226(r_crrl2261.vr_indice).vlstotal:= r_crrl2261.vlstotal;                                             
           END LOOP;
         EXCEPTION
           WHEN OTHERS THEN
              pr_des_erro:= 'Erro pc_grava_tab_men_crrl226: '||sqlerrm;
         END;
       END pc_grava_tab_men_crrl226;
       
       PROCEDURE pc_grava_tab_men_crrl007 (pr_cdcooper in tbgen_batch_relatorio_wrk.cdcooper%type,
                                           pr_dtmvtolt in tbgen_batch_relatorio_wrk.dtmvtolt%type,
                                           pr_des_erro out varchar2) IS
       --  VR_TAB_CRAT007                                          
       cursor c_crrl007 is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) cdagenci,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,2) +1,instr(tab.dsxml,'#',1,3)-instr(tab.dsxml,'#',1,2)-1) nrdconta,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,3) +1,instr(tab.dsxml,'#',1,4)-instr(tab.dsxml,'#',1,3)-1) nmprimtl,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,4) +1,instr(tab.dsxml,'#',1,5)-instr(tab.dsxml,'#',1,4)-1) qtddsdev,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,5) +1,instr(tab.dsxml,'#',1,6)-instr(tab.dsxml,'#',1,5)-1) vlsddisp,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,6) +1,instr(tab.dsxml,'#',1,7)-instr(tab.dsxml,'#',1,6)-1) vllimcre,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,7) +1,instr(tab.dsxml,'#',1,8)-instr(tab.dsxml,'#',1,7)-1) nrdofone,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,8) +1,instr(tab.dsxml,'#',1,9)-instr(tab.dsxml,'#',1,8)-1) vlestour,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,9) +1,instr(tab.dsxml,'#',1,10)-instr(tab.dsxml,'#',1,9)-1) vlsdbltl,                            
              substr(tab.dsxml,instr(tab.dsxml,'#',1,10) +1,instr(tab.dsxml,'#',1,11)-instr(tab.dsxml,'#',1,10)-1) qtcompbb,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,11) +1,instr(tab.dsxml,'#',1,12)-instr(tab.dsxml,'#',1,11)-1) vlcompbb,                            
              substr(tab.dsxml,instr(tab.dsxml,'#',1,12) +1,instr(tab.dsxml,'#',1,13)-instr(tab.dsxml,'#',1,12)-1) qtcmpbcb,                            
              substr(tab.dsxml,instr(tab.dsxml,'#',1,13) +1,instr(tab.dsxml,'#',1,14)-instr(tab.dsxml,'#',1,13)-1) vlcmpbcb,                            
              substr(tab.dsxml,instr(tab.dsxml,'#',1,14) +1,instr(tab.dsxml,'#',1,15)-instr(tab.dsxml,'#',1,14)-1) qtcmpctl,                            
              substr(tab.dsxml,instr(tab.dsxml,'#',1,15) +1,instr(tab.dsxml,'#',1,16)-instr(tab.dsxml,'#',1,15)-1) vlcmpctl,                            
              substr(tab.dsxml,instr(tab.dsxml,'#',1,16) +1,instr(tab.dsxml,'#',1,17)-instr(tab.dsxml,'#',1,16)-1) qtcstdct,                            
              substr(tab.dsxml,instr(tab.dsxml,'#',1,17) +1,instr(tab.dsxml,'#',1,18)-instr(tab.dsxml,'#',1,17)-1) vlcstdct,                            
              substr(tab.dsxml,instr(tab.dsxml,'#',1,18) +1,instr(tab.dsxml,'#',1,19)-instr(tab.dsxml,'#',1,18)-1) flsldapl,                            
              substr(tab.dsxml,instr(tab.dsxml,'#',1,19) +1,instr(tab.dsxml,'#',1,20)-instr(tab.dsxml,'#',1,19)-1) flgdevolu_autom,                            
              substr(tab.dsxml,instr(tab.dsxml,'#',1,20) +1,instr(tab.dsxml,'#',1,21)-instr(tab.dsxml,'#',1,20)-1) qtdevolu,                                                                                    
              tab.dschave vr_indice
         from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                      wrk.dschave 
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_CRAT007'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;
       
       --  VR_TAB_CRAT071 
       cursor c_crrl0071 is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) cdagenci,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,2) +1,instr(tab.dsxml,'#',1,3)-instr(tab.dsxml,'#',1,2)-1) nrdconta,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,3) +1,instr(tab.dsxml,'#',1,4)-instr(tab.dsxml,'#',1,3)-1) cdempres,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,4) +1,instr(tab.dsxml,'#',1,5)-instr(tab.dsxml,'#',1,4)-1) nmprimtl,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,5) +1,instr(tab.dsxml,'#',1,6)-instr(tab.dsxml,'#',1,5)-1) vlsddisp,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,6) +1,instr(tab.dsxml,'#',1,7)-instr(tab.dsxml,'#',1,6)-1) cdturnos,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,7) +1,instr(tab.dsxml,'#',1,8)-instr(tab.dsxml,'#',1,7)-1) vlstotal,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,8) +1,instr(tab.dsxml,'#',1,9)-instr(tab.dsxml,'#',1,8)-1) dsdacstp,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,9) +1,instr(tab.dsxml,'#',1,10)-instr(tab.dsxml,'#',1,9)-1) nrdofone,
              tab.dschave vr_indice
         from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                      wrk.dschave 
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_CRAT071'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;  
   
               
       -- VR_TAB_TOT_AGNSDDIS
       cursor c_agnsddis is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
              tab.dschave vr_indice
         from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                      wrk.dschave 
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_TOT_AGNSDDIS'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;        
               
       -- VR_TAB_TOT_AGNVLLIM
       cursor c_agnvllim is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
              tab.dschave vr_indice
         from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                      wrk.dschave 
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_TOT_AGNVLLIM'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;        
               
       -- VR_TAB_TOT_AGNSDBTL
       cursor c_agnsdbtl is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
              tab.dschave vr_indice
         from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                      wrk.dschave 
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_TOT_AGNSDBTL'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;     
                  
       -- VR_TAB_TOT_VLCSTDCT
       cursor c_vlcstdct is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
              tab.dschave vr_indice
         from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                      wrk.dschave 
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_TOT_VLCSTDCT'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;        

       --VR_TAB_TOT_QTCSTDCT
       cursor c_qtcstdct is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
              tab.dschave vr_indice
         from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                      wrk.dschave 
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_TOT_QTCSTDCT'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;       
         
       -- VR_TAB_REL_AGNSDDIS
       cursor c_ragnsddis is
       select sum(a.vr_total) vr_total, a.vr_indice
         from (select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
                      tab.dschave vr_indice
                 from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                              wrk.dschave 
                         from tbgen_batch_relatorio_wrk wrk
                        where wrk.cdcooper    = pr_cdcooper
                          and wrk.cdprograma  = 'CRPS005'
                          and wrk.dsrelatorio = 'VR_TAB_REL_AGNSDDIS'
                          and wrk.dtmvtolt    = pr_dtmvtolt
                          and wrk.cdagenci    = 99999
                          and wrk.nrdconta    = 9999999999
                         ) tab
                ) a
        group by  a.vr_indice;

       -- VR_TAB_REL_AGNVLLIM
       cursor c_ragnvllim is
       select sum(a.vr_total) vr_total, a.vr_indice
         from (select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
                      tab.dschave vr_indice
                 from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                              wrk.dschave 
                         from tbgen_batch_relatorio_wrk wrk
                        where wrk.cdcooper    = pr_cdcooper
                          and wrk.cdprograma  = 'CRPS005'
                          and wrk.dsrelatorio = 'VR_TAB_REL_AGNVLLIM'
                          and wrk.dtmvtolt    = pr_dtmvtolt
                          and wrk.cdagenci    = 99999
                          and wrk.nrdconta    = 9999999999
                         ) tab
                ) a
        group by  a.vr_indice;

       -- VR_TAB_REL_AGNSDBTL
       cursor c_ragnsdbtl is
       select sum(a.vr_total) vr_total, a.vr_indice
         from (select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
                      tab.dschave vr_indice
                 from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                              wrk.dschave 
                         from tbgen_batch_relatorio_wrk wrk
                        where wrk.cdcooper    = pr_cdcooper
                          and wrk.cdprograma  = 'CRPS005'
                          and wrk.dsrelatorio = 'VR_TAB_REL_AGNSDBTL'
                          and wrk.dtmvtolt    = pr_dtmvtolt
                          and wrk.cdagenci    = 99999
                          and wrk.nrdconta    = 9999999999
                         ) tab
                ) a
        group by  a.vr_indice;        
              
         BEGIN
           FOR r_crrl007 IN c_crrl007  
           LOOP
               --Criar registro na crat07
               vr_tab_crat007(r_crrl007.vr_indice).cdagenci:= r_crrl007.cdagenci;
               vr_tab_crat007(r_crrl007.vr_indice).nrdconta:= r_crrl007.nrdconta;
               vr_tab_crat007(r_crrl007.vr_indice).nmprimtl:= r_crrl007.nmprimtl;
               vr_tab_crat007(r_crrl007.vr_indice).qtddsdev:= r_crrl007.qtddsdev;
               vr_tab_crat007(r_crrl007.vr_indice).vlsddisp:= r_crrl007.vlsddisp;
               vr_tab_crat007(r_crrl007.vr_indice).vllimcre:= r_crrl007.vllimcre; 
               vr_tab_crat007(r_crrl007.vr_indice).nrdofone:= r_crrl007.nrdofone;
               vr_tab_crat007(r_crrl007.vr_indice).vlestour:= r_crrl007.vlestour;
               vr_tab_crat007(r_crrl007.vr_indice).vlsdbltl:= r_crrl007.vlsdbltl;
               vr_tab_crat007(r_crrl007.vr_indice).qtcompbb:= r_crrl007.qtcompbb;
               vr_tab_crat007(r_crrl007.vr_indice).vlcompbb:= r_crrl007.vlcompbb;
               vr_tab_crat007(r_crrl007.vr_indice).qtcmpbcb:= r_crrl007.qtcmpbcb;
               vr_tab_crat007(r_crrl007.vr_indice).vlcmpbcb:= r_crrl007.vlcmpbcb;                                             
               vr_tab_crat007(r_crrl007.vr_indice).qtcmpctl:= r_crrl007.qtcmpctl;                                             
               vr_tab_crat007(r_crrl007.vr_indice).vlcmpctl:= r_crrl007.vlcmpctl;                                             
               vr_tab_crat007(r_crrl007.vr_indice).qtcstdct:= r_crrl007.qtcstdct;                                             
               vr_tab_crat007(r_crrl007.vr_indice).vlcstdct:= r_crrl007.vlcstdct;                                             
               vr_tab_crat007(r_crrl007.vr_indice).flsldapl:= r_crrl007.flsldapl;                                             
               vr_tab_crat007(r_crrl007.vr_indice).flgdevolu_autom:= r_crrl007.flgdevolu_autom;                                             
               vr_tab_crat007(r_crrl007.vr_indice).qtdevolu:= r_crrl007.qtdevolu;                                             
           END LOOP;
           --
           
           -- VR_TAB_CRAT071
           FOR r_crrl0071 IN c_crrl0071  
           LOOP
               --Criar registro na crat071
               vr_tab_crat071(r_crrl0071.vr_indice).cdagenci:= r_crrl0071.cdagenci;
               vr_tab_crat071(r_crrl0071.vr_indice).nrdconta:= r_crrl0071.nrdconta;
               vr_tab_crat071(r_crrl0071.vr_indice).cdempres:= r_crrl0071.cdempres;
               vr_tab_crat071(r_crrl0071.vr_indice).nmprimtl:= r_crrl0071.nmprimtl;
               vr_tab_crat071(r_crrl0071.vr_indice).vlsddisp:= r_crrl0071.vlsddisp;
               vr_tab_crat071(r_crrl0071.vr_indice).cdturnos:= r_crrl0071.cdturnos; 
               vr_tab_crat071(r_crrl0071.vr_indice).vlstotal:= r_crrl0071.vlstotal;
               vr_tab_crat071(r_crrl0071.vr_indice).dsdacstp:= r_crrl0071.dsdacstp;
               vr_tab_crat071(r_crrl0071.vr_indice).nrdofone:= r_crrl0071.nrdofone;
           END LOOP;
           
           
            -- VR_TAB_TOT_AGNSDDIS
           FOR r_agnsddis IN c_agnsddis 
           LOOP
               --Criar registro na vr_tab_rel_vladiclq
               vr_tab_tot_agnsddis(r_agnsddis.vr_indice):= r_agnsddis.vr_total;
           END LOOP;
           
            -- VR_TAB_TOT_AGNVLLIM
           FOR r_agnvllim IN c_agnvllim
           LOOP
               --Criar registro na vr_tab_rel_vladiclq
               vr_tab_tot_agnvllim(r_agnvllim.vr_indice):= r_agnvllim.vr_total;
           END LOOP;

            -- VR_TAB_TOT_AGNSDBTL
           FOR r_agnsdbtl IN c_agnsdbtl
           LOOP
               --Criar registro na vr_tab_rel_vladiclq
               vr_tab_tot_agnsdbtl(r_agnsdbtl.vr_indice):= r_agnsdbtl.vr_total;
           END LOOP;

            -- VR_TAB_TOT_VLCSTDCT
           FOR r_vlcstdct IN c_vlcstdct
           LOOP
               --Criar registro na vr_tab_rel_vladiclq
               vr_tab_tot_vlcstdct(r_vlcstdct.vr_indice):= r_vlcstdct.vr_total;
           END LOOP;
           
           -- VR_TAB_TOT_QTCSTDCT
           FOR r_qtcstdct IN c_qtcstdct
           LOOP
               --Criar registro na vr_tab_rel_vladiclq
               vr_tab_tot_qtcstdct(r_qtcstdct.vr_indice):= r_qtcstdct.vr_total;
           END LOOP;
           
           -- VR_TAB_REL_AGNSDDIS
           FOR r_ragnsddis IN c_ragnsddis  
           LOOP
               --Criar registro na vr_tab_rel_vlcntinv
               vr_tab_rel_agnsddis(r_ragnsddis.vr_indice):= r_ragnsddis.vr_total;
           END LOOP;

           -- VR_TAB_REL_AGNVLLIM
           FOR r_ragnvllim IN c_ragnvllim  
           LOOP
               --Criar registro na vr_tab_rel_vlcntinv
               vr_tab_rel_agnvllim(r_ragnvllim.vr_indice):= r_ragnvllim.vr_total;
           END LOOP;

           -- VR_TAB_REL_AGNSDBTL
           FOR r_ragnsdbtl IN c_ragnsdbtl  
           LOOP
               --Criar registro na vr_tab_rel_vlcntinv
               vr_tab_rel_agnsdbtl(r_ragnsdbtl.vr_indice):= r_ragnsdbtl.vr_total;
           END LOOP;
                      
         EXCEPTION
           WHEN OTHERS THEN
              pr_des_erro:= 'Erro pc_grava_tab_men_crrl007 '||sqlerrm;
       END pc_grava_tab_men_crrl007;
       
       PROCEDURE pc_grava_tab_men_crrl006 (pr_cdcooper in tbgen_batch_relatorio_wrk.cdcooper%type,
                                           pr_dtmvtolt in tbgen_batch_relatorio_wrk.dtmvtolt%type,
                                           pr_des_erro out varchar2) IS
       -- VR_TAB_CRAT006                                           
       cursor c_crrl0061 is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) cdagenci,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,2) +1,instr(tab.dsxml,'#',1,3)-instr(tab.dsxml,'#',1,2)-1) nrdconta,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,3) +1,instr(tab.dsxml,'#',1,4)-instr(tab.dsxml,'#',1,3)-1) nmprimtl,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,4) +1,instr(tab.dsxml,'#',1,5)-instr(tab.dsxml,'#',1,4)-1) vlsaqmax,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,5) +1,instr(tab.dsxml,'#',1,6)-instr(tab.dsxml,'#',1,5)-1) vlsddisp,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,6) +1,instr(tab.dsxml,'#',1,7)-instr(tab.dsxml,'#',1,6)-1) vllimcre,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,7) +1,instr(tab.dsxml,'#',1,8)-instr(tab.dsxml,'#',1,7)-1) vlsdbltl,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,8) +1,instr(tab.dsxml,'#',1,9)-instr(tab.dsxml,'#',1,8)-1) vlsdchsl,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,9) +1,instr(tab.dsxml,'#',1,10)-instr(tab.dsxml,'#',1,9)-1) vlstotal,                            
              substr(tab.dsxml,instr(tab.dsxml,'#',1,10) +1,instr(tab.dsxml,'#',1,11)-instr(tab.dsxml,'#',1,10)-1) vlblqjud,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,11) +1,instr(tab.dsxml,'#',1,12)-instr(tab.dsxml,'#',1,11)-1) dsdacstp,                            
              substr(tab.dsxml,instr(tab.dsxml,'#',1,12) +1,instr(tab.dsxml,'#',1,13)-instr(tab.dsxml,'#',1,12)-1) vr_indice                            
         from (select wrk.dschave dsxml
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_CRAT006'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;
       -----------------------------------------
       -- DEM
       -----------------------------------------
       -- VR_TAB_DEM_AGPSDMAX
       cursor c_dagpsdmax is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
              tab.dschave vr_indice
         from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                      wrk.dschave 
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_DEM_AGPSDMAX'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;  

       -- VR_TAB_DEM_AGPSDDIS
       cursor c_dagpsddis is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
              tab.dschave vr_indice
         from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                      wrk.dschave 
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_DEM_AGPSDDIS'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;  

       -- VR_TAB_DEM_AGPVLLIM
       cursor c_dagpvllim is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
              tab.dschave vr_indice
         from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                      wrk.dschave 
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_DEM_AGPVLLIM'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;  

       -- VR_TAB_DEM_AGPSDBTL
       cursor c_dagpsdbtl is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
              tab.dschave vr_indice
         from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                      wrk.dschave 
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_DEM_AGPSDBTL'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;  

       -- VR_TAB_DEM_AGPSDCHS
       cursor c_dagpsdchs is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
              tab.dschave vr_indice
         from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                      wrk.dschave 
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_DEM_AGPSDCHS'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;  

       -- VR_TAB_DEM_AGPSDSTL
       cursor c_dagpsdstl is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
              tab.dschave vr_indice
         from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                      wrk.dschave 
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_DEM_AGPSDSTL'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;  

       -- VR_TAB_DEM_AGPVLBJD
       cursor c_dagpvlbjd is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
              tab.dschave vr_indice
         from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                      wrk.dschave 
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_DEM_AGPVLBJD'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;  

       -----------------------------------------
       -- REL
       -----------------------------------------
       -- VR_TAB_REL_AGPSDMAX
       cursor c_ragpsdmax is
       select sum(a.vr_total) vr_total, a.vr_indice
         from (select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
                      tab.dschave vr_indice
                 from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                              wrk.dschave 
                         from tbgen_batch_relatorio_wrk wrk
                        where wrk.cdcooper    = pr_cdcooper
                          and wrk.cdprograma  = 'CRPS005'
                          and wrk.dsrelatorio = 'VR_TAB_REL_AGPSDMAX'
                          and wrk.dtmvtolt    = pr_dtmvtolt
                          and wrk.cdagenci    = 99999
                          and wrk.nrdconta    = 9999999999
                         ) tab
                ) a
        group by  a.vr_indice;
               
       -- VR_TAB_REL_AGPSDDIS
       cursor c_ragpsddis is
       select sum(a.vr_total) vr_total, a.vr_indice
         from (select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
                      tab.dschave vr_indice
                 from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                              wrk.dschave 
                         from tbgen_batch_relatorio_wrk wrk
                        where wrk.cdcooper    = pr_cdcooper
                          and wrk.cdprograma  = 'CRPS005'
                          and wrk.dsrelatorio = 'VR_TAB_REL_AGPSDDIS'
                          and wrk.dtmvtolt    = pr_dtmvtolt
                          and wrk.cdagenci    = 99999
                          and wrk.nrdconta    = 9999999999
                         ) tab
                ) a
        group by  a.vr_indice;

       -- VR_TAB_REL_AGPVLLIM
       cursor c_ragpvllim is
       select sum(a.vr_total) vr_total, a.vr_indice
         from (select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
                      tab.dschave vr_indice
                 from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                              wrk.dschave 
                         from tbgen_batch_relatorio_wrk wrk
                        where wrk.cdcooper    = pr_cdcooper
                          and wrk.cdprograma  = 'CRPS005'
                          and wrk.dsrelatorio = 'VR_TAB_REL_AGPVLLIM'
                          and wrk.dtmvtolt    = pr_dtmvtolt
                          and wrk.cdagenci    = 99999
                          and wrk.nrdconta    = 9999999999
                       ) tab
                ) a
        group by  a.vr_indice;

       -- VR_TAB_REL_AGPSDBTL
       cursor c_ragpsdbtl is
       select sum(a.vr_total) vr_total, a.vr_indice
         from (select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
                      tab.dschave vr_indice
                 from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                              wrk.dschave 
                         from tbgen_batch_relatorio_wrk wrk
                        where wrk.cdcooper    = pr_cdcooper
                          and wrk.cdprograma  = 'CRPS005'
                          and wrk.dsrelatorio = 'VR_TAB_REL_AGPSDBTL'
                          and wrk.dtmvtolt    = pr_dtmvtolt
                          and wrk.cdagenci    = 99999
                          and wrk.nrdconta    = 9999999999
                       ) tab  
                ) a
        group by  a.vr_indice;

       -- VR_TAB_REL_AGPSDCHS
       cursor c_ragpsdchs is
       select sum(a.vr_total) vr_total, a.vr_indice
         from (select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
                      tab.dschave vr_indice
                 from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                              wrk.dschave 
                         from tbgen_batch_relatorio_wrk wrk
                        where wrk.cdcooper    = pr_cdcooper
                          and wrk.cdprograma  = 'CRPS005'
                          and wrk.dsrelatorio = 'VR_TAB_REL_AGPSDCHS'
                          and wrk.dtmvtolt    = pr_dtmvtolt
                          and wrk.cdagenci    = 99999
                          and wrk.nrdconta    = 9999999999
                       ) tab  
                ) a
        group by  a.vr_indice;

       -- VR_TAB_REL_AGPSDSTL
       cursor c_ragpsdstl is
       select sum(a.vr_total) vr_total, a.vr_indice
         from (select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
                      tab.dschave vr_indice
                 from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                              wrk.dschave 
                         from tbgen_batch_relatorio_wrk wrk
                        where wrk.cdcooper    = pr_cdcooper
                          and wrk.cdprograma  = 'CRPS005'
                          and wrk.dsrelatorio = 'VR_TAB_REL_AGPSDSTL'
                          and wrk.dtmvtolt    = pr_dtmvtolt
                          and wrk.cdagenci    = 99999
                          and wrk.nrdconta    = 9999999999
                       ) tab
                ) a
        group by  a.vr_indice;

       -- VR_TAB_REL_AGPSDBJD
       cursor c_ragpsdbjd is
       select sum(a.vr_total) vr_total, a.vr_indice
         from (select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
                      tab.dschave vr_indice
                 from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                              wrk.dschave 
                         from tbgen_batch_relatorio_wrk wrk
                        where wrk.cdcooper    = pr_cdcooper
                          and wrk.cdprograma  = 'CRPS005'
                          and wrk.dsrelatorio = 'VR_TAB_REL_AGPSDBJD'
                          and wrk.dtmvtolt    = pr_dtmvtolt
                          and wrk.cdagenci    = 99999
                          and wrk.nrdconta    = 9999999999
                       ) tab  
                ) a
        group by  a.vr_indice;
               

       -- VR_TAB_REL_VLSLDLIQ
       cursor c_rvlsldliq is
       select sum(a.vr_total) vr_total, a.vr_indice
         from (select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
                      tab.dschave vr_indice
                 from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                              wrk.dschave 
                         from tbgen_batch_relatorio_wrk wrk
                        where wrk.cdcooper    = pr_cdcooper
                          and wrk.cdprograma  = 'CRPS005'
                          and wrk.dsrelatorio = 'VR_TAB_REL_VLSLDLIQ'
                          and wrk.dtmvtolt    = pr_dtmvtolt
                          and wrk.cdagenci    = 99999
                          and wrk.nrdconta    = 9999999999
                       ) tab  
                ) a
        group by  a.vr_indice;

       -- VR_TAB_REL_VLSUTILI
       cursor c_rvlsutili is
       select sum(a.vr_total) vr_total, a.vr_indice
         from (select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
                      tab.dschave vr_indice
                 from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                              wrk.dschave 
                         from tbgen_batch_relatorio_wrk wrk
                        where wrk.cdcooper    = pr_cdcooper
                          and wrk.cdprograma  = 'CRPS005'
                          and wrk.dsrelatorio = 'VR_TAB_REL_VLSUTILI'
                          and wrk.dtmvtolt    = pr_dtmvtolt
                          and wrk.cdagenci    = 99999
                          and wrk.nrdconta    = 9999999999
                       ) tab
                ) a
        group by  a.vr_indice;
                        

       -- VR_TAB_REL_VLSAQBLQ
       cursor c_rvlsaqblq is
       select sum(a.vr_total) vr_total, a.vr_indice
         from (select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
                      tab.dschave vr_indice
                 from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                              wrk.dschave 
                         from tbgen_batch_relatorio_wrk wrk
                        where wrk.cdcooper    = pr_cdcooper
                          and wrk.cdprograma  = 'CRPS005'
                          and wrk.dsrelatorio = 'VR_TAB_REL_VLSAQBLQ'
                          and wrk.dtmvtolt    = pr_dtmvtolt
                          and wrk.cdagenci    = 99999
                          and wrk.nrdconta    = 9999999999
                       ) tab
                ) a
        group by  a.vr_indice;
                 

       -- VR_TAB_REL_VLSADIAN
       cursor c_rvlsadian is
       select sum(a.vr_total) vr_total, a.vr_indice
         from (select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
                      tab.dschave vr_indice
                 from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                              wrk.dschave 
                         from tbgen_batch_relatorio_wrk wrk
                        where wrk.cdcooper    = pr_cdcooper
                          and wrk.cdprograma  = 'CRPS005'
                          and wrk.dsrelatorio = 'VR_TAB_REL_VLSADIAN'
                          and wrk.dtmvtolt    = pr_dtmvtolt
                          and wrk.cdagenci    = 99999
                          and wrk.nrdconta    = 9999999999
                       ) tab
                ) a
        group by  a.vr_indice;
                         

       -- VR_TAB_REL_VLADICLQ
       cursor c_rvladiclq is
       select sum(a.vr_total) vr_total, a.vr_indice
         from (select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
                      tab.dschave vr_indice
                 from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                              wrk.dschave 
                         from tbgen_batch_relatorio_wrk wrk
                        where wrk.cdcooper    = pr_cdcooper
                          and wrk.cdprograma  = 'CRPS005'
                          and wrk.dsrelatorio = 'VR_TAB_REL_VLADICLQ'
                          and wrk.dtmvtolt    = pr_dtmvtolt
                          and wrk.cdagenci    = 99999
                          and wrk.nrdconta    = 9999999999
                       ) tab
                ) a
        group by  a.vr_indice;
                 
               
       -- VR_TAB_REL_VLCNTINV
       cursor c_rvlcntinv is
       select sum(a.vr_total) vr_total, a.vr_indice
         from (select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
                      tab.dschave vr_indice
                 from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                              wrk.dschave 
                         from tbgen_batch_relatorio_wrk wrk
                        where wrk.cdcooper    = pr_cdcooper
                          and wrk.cdprograma  = 'CRPS005'
                          and wrk.dsrelatorio = 'VR_TAB_REL_VLCNTINV'
                          and wrk.dtmvtolt    = pr_dtmvtolt
                          and wrk.cdagenci    = 99999
                          and wrk.nrdconta    = 9999999999
                       ) tab
                ) a
        group by  a.vr_indice;
        
       -- VR_TAB_REL_VLBLQJUD
       cursor c_vlblqjud is
       select sum(a.vr_total) vr_total, a.vr_indice
         from (select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) vr_total,
                      tab.dschave vr_indice
                 from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                              wrk.dschave 
                         from tbgen_batch_relatorio_wrk wrk
                        where wrk.cdcooper    = pr_cdcooper
                          and wrk.cdprograma  = 'CRPS005'
                          and wrk.dsrelatorio = 'VR_TAB_REL_VLBLQJUD'
                          and wrk.dtmvtolt    = pr_dtmvtolt
                          and wrk.cdagenci    = 99999
                          and wrk.nrdconta    = 9999999999
                       ) tab 
         ) a
        group by  a.vr_indice;                       
                       
       -- VR_TAB_TOTAIS                    
       -- VR_TAB_TOTAIS                    
       cursor c_totais is
       select sum(a.vltttfis) vltttfis,
              sum(a.vltttjur) vltttjur,
              a.cdlcremp,
              a.tipo,
              a.vr_indice
        from (select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) cdlcremp,
                     substr(tab.dsxml,instr(tab.dsxml,'#',1,2) +1,instr(tab.dsxml,'#',1,3)-instr(tab.dsxml,'#',1,2)-1) tipo,
                     substr(tab.dsxml,instr(tab.dsxml,'#',1,3) +1,instr(tab.dsxml,'#',1,4)-instr(tab.dsxml,'#',1,3)-1) vltttfis,
                     substr(tab.dsxml,instr(tab.dsxml,'#',1,4) +1,instr(tab.dsxml,'#',1,5)-instr(tab.dsxml,'#',1,4)-1) vltttjur,
                     tab.dschave vr_indice
                from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                             wrk.dschave 
                        from tbgen_batch_relatorio_wrk wrk
                       where wrk.cdcooper    = pr_cdcooper
                         and wrk.cdprograma  = 'CRPS005'
                         and wrk.dsrelatorio = 'VR_TAB_TOTAIS'
                         and wrk.dtmvtolt    = pr_dtmvtolt
                         and wrk.cdagenci    = 99999
                         and wrk.nrdconta    = 9999999999
                       ) tab
               )a
         group by  a.cdlcremp,
                   a.tipo,
                   a.vr_indice;


       -- VR_TAB_DETALHES                    
       cursor c_detalhes is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) cdagenci,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,2) +1,instr(tab.dsxml,'#',1,3)-instr(tab.dsxml,'#',1,2)-1) nrdconta,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,3) +1,instr(tab.dsxml,'#',1,4)-instr(tab.dsxml,'#',1,3)-1) nmprimtl,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,4) +1,instr(tab.dsxml,'#',1,5)-instr(tab.dsxml,'#',1,4)-1) cdlcremp,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,5) +1,instr(tab.dsxml,'#',1,6)-instr(tab.dsxml,'#',1,5)-1) nrctremp,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,6) +1,instr(tab.dsxml,'#',1,7)-instr(tab.dsxml,'#',1,6)-1) dtmvtolt,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,7) +1,instr(tab.dsxml,'#',1,8)-instr(tab.dsxml,'#',1,7)-1) vlemprst,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,8) +1,instr(tab.dsxml,'#',1,9)-instr(tab.dsxml,'#',1,8)-1) vlsdeved,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,9) +1,instr(tab.dsxml,'#',1,10)-instr(tab.dsxml,'#',1,9)-1) vr_indice
         from (select wrk.dschave dsxml
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_DETALHES'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;

       -- VR_TAB_ATRASADOS                    
       cursor c_atrasados is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) cdagenci,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,2) +1,instr(tab.dsxml,'#',1,3)-instr(tab.dsxml,'#',1,2)-1) nrdconta,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,3) +1,instr(tab.dsxml,'#',1,4)-instr(tab.dsxml,'#',1,3)-1) cdlcremp,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,4) +1,instr(tab.dsxml,'#',1,5)-instr(tab.dsxml,'#',1,4)-1) nrctremp,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,5) +1,instr(tab.dsxml,'#',1,6)-instr(tab.dsxml,'#',1,5)-1) dtultpag,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,6) +1,instr(tab.dsxml,'#',1,7)-instr(tab.dsxml,'#',1,6)-1) vlsdeved,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,7) +1,instr(tab.dsxml,'#',1,8)-instr(tab.dsxml,'#',1,7)-1) vr_indice
         from (select wrk.dschave dsxml
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_ATRASADOS'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;

       -- VR_TAB_GN006 
       cursor c_gn006 is
        select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) cdagenci,
               substr(tab.dsxml,instr(tab.dsxml,'#',1,2) +1,instr(tab.dsxml,'#',1,3)-instr(tab.dsxml,'#',1,2)-1) nrdconta,
               substr(tab.dsxml,instr(tab.dsxml,'#',1,3) +1,instr(tab.dsxml,'#',1,4)-instr(tab.dsxml,'#',1,3)-1) vlstotal,
               tab.dschave vr_indice
          from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                       wrk.dschave 
                  from tbgen_batch_relatorio_wrk wrk
                 where wrk.cdcooper    = pr_cdcooper
                   and wrk.cdprograma  = 'CRPS005'
                   and wrk.dsrelatorio = 'VR_TAB_GN006'
                   and wrk.dtmvtolt    = pr_dtmvtolt
                   and wrk.cdagenci    = 99999
                   and wrk.nrdconta    = 9999999999
                ) tab;               
       BEGIN
         BEGIN
           FOR r_crrl0061 IN c_crrl0061  
           LOOP
               --Criar registro na crat372
               vr_tab_crat006(r_crrl0061.vr_indice).cdagenci:= r_crrl0061.cdagenci;
               vr_tab_crat006(r_crrl0061.vr_indice).nrdconta:= r_crrl0061.nrdconta;
               vr_tab_crat006(r_crrl0061.vr_indice).nmprimtl:= r_crrl0061.nmprimtl;
               vr_tab_crat006(r_crrl0061.vr_indice).vlsaqmax:= r_crrl0061.vlsaqmax;
               vr_tab_crat006(r_crrl0061.vr_indice).vlsddisp:= r_crrl0061.vlsddisp;
               vr_tab_crat006(r_crrl0061.vr_indice).vllimcre:= r_crrl0061.vllimcre; 
               vr_tab_crat006(r_crrl0061.vr_indice).vlsdbltl:= r_crrl0061.vlsdbltl;
               vr_tab_crat006(r_crrl0061.vr_indice).vlsdchsl:= r_crrl0061.vlsdchsl;
               vr_tab_crat006(r_crrl0061.vr_indice).vlstotal:= r_crrl0061.vlstotal;
               vr_tab_crat006(r_crrl0061.vr_indice).vlblqjud:= r_crrl0061.vlblqjud;                                             
               vr_tab_crat006(r_crrl0061.vr_indice).dsdacstp:= r_crrl0061.dsdacstp;                                                            
           END LOOP;
           
           ------------------------------------------
           -- DEM
           ------------------------------------------
           -- VR_TAB_DEM_AGPSDMAX
           FOR r_dagpsdmax IN c_dagpsdmax  
           LOOP
               --Criar registro na vr_tab_dem_agpsdmax
               vr_tab_dem_agpsdmax(r_dagpsdmax.vr_indice):= r_dagpsdmax.vr_total;
           END LOOP;

           -- VR_TAB_DEM_AGPSDDIS
           FOR r_dagpsddis IN c_dagpsddis  
           LOOP
               --Criar registro na vr_tab_dem_agpvllim
               vr_tab_dem_agpsddis(r_dagpsddis.vr_indice):= r_dagpsddis.vr_total;
           END LOOP;

           -- VR_TAB_DEM_AGPVLLIM
           FOR r_dagpvllim IN c_dagpvllim  
           LOOP
               --Criar registro na vr_tab_dem_agpvllim
               vr_tab_dem_agpvllim(r_dagpvllim.vr_indice):= r_dagpvllim.vr_total;
           END LOOP;

           -- VR_TAB_DEM_AGPSDBTL
           FOR r_dagpsdbtl IN c_dagpsdbtl  
           LOOP
               --Criar registro na vr_tab_dem_agpsdbtl
               vr_tab_dem_agpsdbtl(r_dagpsdbtl.vr_indice):= r_dagpsdbtl.vr_total;
           END LOOP;

           -- VR_TAB_DEM_AGPSDCHS
           FOR r_dagpsdchs IN c_dagpsdchs  
           LOOP
               --Criar registro na vr_tab_dem_agpsdchs
               vr_tab_dem_agpsdchs(r_dagpsdchs.vr_indice):= r_dagpsdchs.vr_total;
           END LOOP;

           -- VR_TAB_DEM_AGPSDSTL
           FOR r_dagpsdstl IN c_dagpsdstl  
           LOOP
               --Criar registro na vr_tab_dem_agpsdstl
               vr_tab_dem_agpsdstl(r_dagpsdstl.vr_indice):= r_dagpsdstl.vr_total;
           END LOOP;

           -- VR_TAB_DEM_AGPVLBJD
           FOR r_dagpvlbjd IN c_dagpvlbjd  
           LOOP
               --Criar registro na vr_tab_dem_agpvlbjd
               vr_tab_dem_agpvlbjd(r_dagpvlbjd.vr_indice):= r_dagpvlbjd.vr_total;
           END LOOP;
          
           -------------------------------------
           -- REL
           -------------------------------------
           --VR_TAB_REL_AGPSDMAX
           FOR r_ragpsdmax IN c_ragpsdmax  
           LOOP
               --Criar registro na vr_tab_rel_agpsddis
               vr_tab_rel_agpsdmax(r_ragpsdmax.vr_indice):= r_ragpsdmax.vr_total;
           END LOOP;
           
           -- VR_TAB_REL_AGPSDDIS
           FOR r_ragpsddis IN c_ragpsddis  
           LOOP
               --Criar registro na vr_tab_rel_agpsddis
               vr_tab_rel_agpsddis(r_ragpsddis.vr_indice):= r_ragpsddis.vr_total;
           END LOOP;

           -- VR_TAB_REL_AGPVLLIM
           FOR r_ragpvllim IN c_ragpvllim  
           LOOP
               --Criar registro na vr_tab_rel_agpvllim
               vr_tab_rel_agpvllim(r_ragpvllim.vr_indice):= r_ragpvllim.vr_total;
           END LOOP;

           -- VR_TAB_REL_AGPSDBTL
           FOR r_ragpsdbtl IN c_ragpsdbtl  
           LOOP
               --Criar registro na vr_tab_rel_agpvllim
               vr_tab_rel_agpsdbtl(r_ragpsdbtl.vr_indice):= r_ragpsdbtl.vr_total;
           END LOOP;

           -- VR_TAB_REL_AGPSDCHS
           FOR r_ragpsdchs IN c_ragpsdchs  
           LOOP
               --Criar registro na vr_tab_rel_agpsdchs
               vr_tab_rel_agpsdchs(r_ragpsdchs.vr_indice):= r_ragpsdchs.vr_total;
           END LOOP;

           -- VR_TAB_REL_AGPSDSTL
           FOR r_ragpsdstl IN c_ragpsdstl  
           LOOP
               --Criar registro na vr_tab_rel_agpsdstl
               vr_tab_rel_agpsdstl(r_ragpsdstl.vr_indice):= r_ragpsdstl.vr_total;
           END LOOP;

           -- VR_TAB_REL_AGPSDBJD
           FOR r_ragpsdbjd IN c_ragpsdbjd
           LOOP
               --Criar registro na vr_tab_rel_agpsdbjd
               vr_tab_rel_agpsdbjd(r_ragpsdbjd.vr_indice):= r_ragpsdbjd.vr_total;
           END LOOP;

           -- VR_TAB_REL_VLSLDLIQ
           FOR r_rvlsldliq IN c_rvlsldliq  
           LOOP
               --Criar registro na vr_tab_rel_vlsldliq
               vr_tab_rel_vlsldliq(r_rvlsldliq.vr_indice):= r_rvlsldliq.vr_total;
           END LOOP;

           -- VR_TAB_REL_VLSUTILI
           FOR r_rvlsutili IN c_rvlsutili  
           LOOP
               --Criar registro na vr_tab_rel_vlsutili
               vr_tab_rel_vlsutili(r_rvlsutili.vr_indice):= r_rvlsutili.vr_total;
           END LOOP;

           -- VR_TAB_REL_VLSAQBLQ
           FOR r_rvlsaqblq IN c_rvlsaqblq  
           LOOP
               --Criar registro na vr_tab_rel_vlsaqblq
               vr_tab_rel_vlsaqblq(r_rvlsaqblq.vr_indice):= r_rvlsaqblq.vr_total;
           END LOOP;

           -- VR_TAB_REL_VLSADIAN
           FOR r_rvlsadian IN c_rvlsadian 
           LOOP
               --Criar registro na vr_tab_rel_vlsadian
               vr_tab_rel_vlsadian(r_rvlsadian.vr_indice):= r_rvlsadian.vr_total;
           END LOOP;

           -- VR_TAB_REL_VLADICLQ
           FOR r_rvladiclq IN c_rvladiclq 
           LOOP
               --Criar registro na vr_tab_rel_vladiclq
               vr_tab_rel_vladiclq(r_rvladiclq.vr_indice):= r_rvladiclq.vr_total;
           END LOOP;

           -- VR_TAB_REL_VLCNTINV
           FOR r_rvlcntinv IN c_rvlcntinv  
           LOOP
               --Criar registro na vr_tab_rel_vlcntinv
               vr_tab_rel_vlcntinv(r_rvlcntinv.vr_indice):= r_rvlcntinv.vr_total;
           END LOOP;

           -- VR_TAB_REL_VLBLQJUD
           FOR r_vlblqjud IN c_vlblqjud  
           LOOP
               --Criar registro na vr_tab_rel_vlcntinv
               vr_tab_rel_vlblqjud(r_vlblqjud.vr_indice):= r_vlblqjud.vr_total;
           END LOOP;

           -- VR_TAB_TOTAIS
           FOR r_totais IN c_totais  
           LOOP
               --Criar registro na vr_tab_totais
               vr_tab_totais(r_totais.vr_indice).cdlcremp:= r_totais.cdlcremp;
               vr_tab_totais(r_totais.vr_indice).tipo:= r_totais.tipo;
               vr_tab_totais(r_totais.vr_indice).vltttfis:= r_totais.vltttfis;
               vr_tab_totais(r_totais.vr_indice).vltttjur:= r_totais.vltttjur;                              
           END LOOP;

           -- VR_TAB_DETALHES
           FOR r_detalhes IN c_detalhes  
           LOOP
               --Criar registro na vr_tab_detalhes
               vr_tab_detalhes(r_detalhes.vr_indice).cdagenci:= r_detalhes.cdagenci;
               vr_tab_detalhes(r_detalhes.vr_indice).nrdconta:= r_detalhes.nrdconta;
               vr_tab_detalhes(r_detalhes.vr_indice).nmprimtl:= r_detalhes.nmprimtl;
               vr_tab_detalhes(r_detalhes.vr_indice).cdlcremp:= r_detalhes.cdlcremp;                              
               vr_tab_detalhes(r_detalhes.vr_indice).nrctremp:= r_detalhes.nrctremp;                              
               vr_tab_detalhes(r_detalhes.vr_indice).dtmvtolt:= r_detalhes.dtmvtolt;                                                            
               vr_tab_detalhes(r_detalhes.vr_indice).vlemprst:= r_detalhes.vlemprst;                                             
               vr_tab_detalhes(r_detalhes.vr_indice).vlsdeved:= r_detalhes.vlsdeved;                    
           END LOOP;

           -- VR_TAB_ATRASADOS
           FOR r_atrasados IN c_atrasados  
           LOOP
               --Criar registro na vr_tab_atrasados
               vr_tab_atrasados(r_atrasados.vr_indice).cdagenci:= r_atrasados.cdagenci;
               vr_tab_atrasados(r_atrasados.vr_indice).nrdconta:= r_atrasados.nrdconta;
               vr_tab_atrasados(r_atrasados.vr_indice).cdlcremp:= r_atrasados.cdlcremp;
               vr_tab_atrasados(r_atrasados.vr_indice).nrctremp:= r_atrasados.nrctremp;                              
               vr_tab_atrasados(r_atrasados.vr_indice).dtultpag:= r_atrasados.dtultpag;                              
               vr_tab_atrasados(r_atrasados.vr_indice).vlsdeved:= r_atrasados.vlsdeved;                                                            
           END LOOP;

           -- VR_TAB_GN006
           FOR r_gn006 IN c_gn006  
           LOOP
               --Criar registro na vr_tab_gn006
               vr_tab_gn006(r_gn006.vr_indice).cdagenci:= r_gn006.cdagenci;
               vr_tab_gn006(r_gn006.vr_indice).nrdconta:= r_gn006.nrdconta;
               vr_tab_gn006(r_gn006.vr_indice).vlstotal:= r_gn006.vlstotal;
           END LOOP;
    
         EXCEPTION
           WHEN OTHERS THEN
              pr_des_erro:= 'Erro pc_grava_tab_men_crrl006: '||sqlerrm;
         END;
       END pc_grava_tab_men_crrl006;
       
       
       PROCEDURE pc_grava_tab_men_crrl372 (pr_cdcooper in tbgen_batch_relatorio_wrk.cdcooper%type,
                                           pr_dtmvtolt in tbgen_batch_relatorio_wrk.dtmvtolt%type,
                                           pr_des_erro out varchar2) IS
           
       -- VR_TAB_CRAT372                                     
       cursor c_crrl3721 is
       select substr(tab.dsxml,instr(tab.dsxml,'#',1,1) +1,instr(tab.dsxml,'#',1,2)-instr(tab.dsxml,'#',1,1)-1) cdagenci,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,2) +1,instr(tab.dsxml,'#',1,3)-instr(tab.dsxml,'#',1,2)-1) nrdconta,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,3) +1,instr(tab.dsxml,'#',1,4)-instr(tab.dsxml,'#',1,3)-1) cdempres,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,4) +1,instr(tab.dsxml,'#',1,5)-instr(tab.dsxml,'#',1,4)-1) cdturnos,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,5) +1,instr(tab.dsxml,'#',1,6)-instr(tab.dsxml,'#',1,5)-1) vlsddisp,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,6) +1,instr(tab.dsxml,'#',1,7)-instr(tab.dsxml,'#',1,6)-1) nmprimtl,
              substr(tab.dsxml,instr(tab.dsxml,'#',1,7) +1,instr(tab.dsxml,'#',1,8)-instr(tab.dsxml,'#',1,7)-1) nrdofone,
              tab.dschave vr_indice
         from (select dbms_lob.substr(wrk.dsxml,4000,1) dsxml,
                      wrk.dschave 
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'CRPS005'
                  and wrk.dsrelatorio = 'VR_TAB_CRAT372'
                  and wrk.dtmvtolt    = pr_dtmvtolt
                  and wrk.cdagenci    = 99999
                  and wrk.nrdconta    = 9999999999
               ) tab;
       BEGIN
         BEGIN
           FOR r_crrl3721 IN c_crrl3721  
           LOOP
               --Criar registro na crat372
               vr_tab_crat372(r_crrl3721.vr_indice).cdagenci:= r_crrl3721.cdagenci;
               vr_tab_crat372(r_crrl3721.vr_indice).nrdconta:= r_crrl3721.nrdconta;
               vr_tab_crat372(r_crrl3721.vr_indice).cdempres:= r_crrl3721.cdempres;
               vr_tab_crat372(r_crrl3721.vr_indice).cdturnos:= r_crrl3721.cdturnos;
               vr_tab_crat372(r_crrl3721.vr_indice).vlsddisp:= r_crrl3721.vlsddisp;
               vr_tab_crat372(r_crrl3721.vr_indice).nmprimtl:= r_crrl3721.nmprimtl; 
               vr_tab_crat372(r_crrl3721.vr_indice).nrdofone:= r_crrl3721.nrdofone;
           END LOOP;
         EXCEPTION
           WHEN OTHERS THEN
              pr_des_erro:= 'Erro pc_grava_tab_men_crrl372: '||sqlerrm;
         END;
       END pc_grava_tab_men_crrl372;    
       
          
       ------------------------------------------------------------------
       -- Lê as tabelas de memoria e salva os dados na tabela de trabalho
       -- Projeto Ligeirinho
       ------------------------------------------------------------------
       PROCEDURE pc_grava_tab_wrk_geral (pr_des_erro out varchar2) IS
        -- Grava agencias - VR_TAB_CRAPAGE
        vr_indice varchar2(50);
        vr_exc_erro  exception;
       BEGIN
        vr_indice := vr_tab_crapage.first;
        while vr_indice is not null loop
           vr_ds_xml:= ds_character_separador||
                       vr_tab_crapage(vr_indice).cdagenci||ds_character_separador||
                       vr_tab_crapage(vr_indice).nmresage||ds_character_separador;
           
           pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                          pr_nmtabmemoria  => 'VR_TAB_CRAPAGE',
                                          pr_dtmvtolt      => vr_dtmvtolt,
                                          pr_dschave       => vr_indice,
                                          pr_dsxml         => vr_ds_xml,
                                          pr_des_erro      => vr_des_erro);
            if vr_des_erro is not null then
               vr_des_erro:= 'VR_TAB_CRAPAGE - '||vr_des_erro;
               raise vr_exc_erro;
            end if;                                            
            vr_indice:= vr_tab_crapage.next(vr_indice);
        end loop; -- vr_tab_cratpage
           
        -- VR_TAB_CRAPTFC 
        vr_indice := vr_tab_craptfc.first;
        while vr_indice is not null loop
           vr_ds_xml:= ds_character_separador||
                       vr_tab_craptfc(vr_indice).nrdddtfc||ds_character_separador||
                       vr_tab_craptfc(vr_indice).nrtelefo||ds_character_separador||
                       vr_indice||ds_character_separador;

           pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                          pr_nmtabmemoria  => 'VR_TAB_CRAPTFC',
                                          pr_dtmvtolt      => vr_dtmvtolt,
                                          pr_dschave       => vr_ds_xml,
                                          pr_dsxml         => null,
                                          pr_des_erro      => vr_des_erro);
            if vr_des_erro is not null then
               vr_des_erro:= 'VR_TAB_CRAPTFC - '||vr_des_erro;
               raise vr_exc_erro;
            end if;                                            
            vr_indice:= vr_tab_craptfc.next(vr_indice);
        end loop; -- vr_tab_craptfc
        
        -- VR_TAB_CRAPSLI 
        vr_indice := vr_tab_crapsli.first;
        while vr_indice is not null loop
           vr_ds_xml:= ds_character_separador||
                       vr_tab_crapsli(vr_indice).vlsddisp||ds_character_separador||
                       vr_indice||ds_character_separador;

           pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                          pr_nmtabmemoria  => 'VR_TAB_CRAPSLI',
                                          pr_dtmvtolt      => vr_dtmvtolt,
                                          pr_dschave       => vr_ds_xml,
                                          pr_dsxml         => null,
                                          pr_des_erro      => vr_des_erro);
            if vr_des_erro is not null then
               vr_des_erro:= 'VR_TAB_CRAPSLI - '||vr_des_erro;
               raise vr_exc_erro;
            end if;                                            
            vr_indice:= vr_tab_crapsli.next(vr_indice);
        end loop; -- vr_tab_crapsli
        
        -- VR_TAB_CRAPCOR 
        vr_indice := vr_tab_crapcor.first;
        while vr_indice is not null loop
           vr_ds_xml:= ds_character_separador||
                       vr_tab_crapcor(vr_indice)||ds_character_separador||
                       vr_indice||ds_character_separador;

           pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                          pr_nmtabmemoria  => 'VR_TAB_CRAPCOR',
                                          pr_dtmvtolt      => vr_dtmvtolt,
                                          pr_dschave       => vr_ds_xml,
                                          pr_dsxml         => null,
                                          pr_des_erro      => vr_des_erro);
            if vr_des_erro is not null then
               vr_des_erro:= 'vr_tab_crapcor - '||vr_des_erro;
               raise vr_exc_erro;
            end if;                                            
            vr_indice:= vr_tab_crapcor.next(vr_indice);
        end loop; -- vr_tab_crapcor

        -- VR_TAB_CRAPEPR 
        vr_indice := vr_tab_crapepr.first;
        while vr_indice is not null loop
           vr_ds_xml:= ds_character_separador||
                       vr_tab_crapepr(vr_indice)||ds_character_separador||
                       vr_indice||ds_character_separador;

           pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                          pr_nmtabmemoria  => 'VR_TAB_CRAPEPR',
                                          pr_dtmvtolt      => vr_dtmvtolt,
                                          pr_dschave       => vr_ds_xml,
                                          pr_dsxml         => null,
                                          pr_des_erro      => vr_des_erro);
            if vr_des_erro is not null then
               vr_des_erro:= 'VR_TAB_CRAPEPR - '||vr_des_erro;
               raise vr_exc_erro;
            end if;                                            
            vr_indice:= vr_tab_crapepr.next(vr_indice);
        end loop; -- vr_tab_crapepr
        
        -- VR_TAB_CRAPSLD 
        vr_indice := vr_tab_crapsld.first;
        while vr_indice is not null loop
           vr_ds_xml:= ds_character_separador||
                       vr_tab_crapsld(vr_indice).vlsdbloq||ds_character_separador||
                       vr_tab_crapsld(vr_indice).vlsdblpr||ds_character_separador||
                       vr_tab_crapsld(vr_indice).vlsdblfp||ds_character_separador||                                              
                       vr_tab_crapsld(vr_indice).vlsdchsl||ds_character_separador||
                       vr_tab_crapsld(vr_indice).vlsddisp||ds_character_separador||
                       vr_tab_crapsld(vr_indice).vlipmfpg||ds_character_separador||                                              
                       vr_tab_crapsld(vr_indice).vlipmfap||ds_character_separador||
                       vr_tab_crapsld(vr_indice).dtdsdclq||ds_character_separador||
                       vr_tab_crapsld(vr_indice).qtddsdev||ds_character_separador||                                              
                       vr_tab_crapsld(vr_indice).vlblqjud||ds_character_separador||                                              
                       vr_tab_crapsld(vr_indice).vlsldtot||ds_character_separador||                                              
                       vr_tab_crapsld(vr_indice).vr_rowid||ds_character_separador||
                       vr_tab_crapsld(vr_indice).vlblqprj||ds_character_separador||                       
                       vr_indice||ds_character_separador;                                            

                                          
           pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                          pr_nmtabmemoria  => 'VR_TAB_CRAPSLD',
                                          pr_dtmvtolt      => vr_dtmvtolt,
                                          pr_dschave       => vr_ds_xml,
                                          pr_dsxml         => NULL,
                                          pr_des_erro      => vr_des_erro);                                          
            if vr_des_erro is not null then
               vr_des_erro:= 'VR_TAB_CRAPSLD - '||vr_des_erro;
               raise vr_exc_erro;
            end if;                                            
            vr_indice:= vr_tab_crapsld.next(vr_indice);
        end loop; -- vr_tab_crapsld


        -- Total bloqueado da agencia - VR_TAB_LIS_AGNSDBTL
        vr_indice := vr_tab_lis_agnsdbtl.first;
        while vr_indice is not null loop
           vr_ds_xml:= ds_character_separador||
                       vr_tab_lis_agnsdbtl(vr_indice)||ds_character_separador||
                       vr_indice||ds_character_separador;
        
           pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                          pr_nmtabmemoria  => 'VR_TAB_LIS_AGNSDBTL',
                                          pr_dtmvtolt      => vr_dtmvtolt,
                                          pr_dschave       => vr_ds_xml,
                                          pr_dsxml         => null,
                                          pr_des_erro      => vr_des_erro);
           if vr_des_erro is not null then
              vr_des_erro:= 'VR_TAB_LIS_AGNSDBTL - '||vr_des_erro;
              raise vr_exc_erro;
           end if;                                            
           vr_indice:= vr_tab_lis_agnsdbtl.next(vr_indice);
         end loop;
        
        -- Saldo total da agencia - vr_tab_lis_agnsdstl
        vr_indice := vr_tab_lis_agnsdstl.first;
        while vr_indice is not null loop
           vr_ds_xml:= ds_character_separador||
                       vr_tab_lis_agnsdstl(vr_indice)||ds_character_separador;
        
           pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                          pr_nmtabmemoria  => 'VR_TAB_LIS_AGNSDSTL',
                                          pr_dtmvtolt      => vr_dtmvtolt,
                                          pr_dschave       => vr_indice,
                                          pr_dsxml         => vr_ds_xml,
                                          pr_des_erro      => vr_des_erro);
           if vr_des_erro is not null then
              vr_des_erro:= 'VR_TAB_LIS_AGNSDSTL - '||vr_des_erro;
              raise vr_exc_erro;
           end if;                                            
           vr_indice:= vr_tab_lis_agnsdstl.next(vr_indice);
         end loop;
         
         
         -- Total disponivel da agencia - vr_tab_lis_agnsddis
         vr_indice := vr_tab_lis_agnsddis.first;
         while vr_indice is not null loop
            vr_ds_xml:= ds_character_separador||
                        vr_tab_lis_agnsddis(vr_indice)||ds_character_separador||
                        vr_indice||ds_character_separador;
        
            pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                           pr_nmtabmemoria  => 'VR_TAB_LIS_AGNSDDIS',
                                           pr_dtmvtolt      => vr_dtmvtolt,
                                           pr_dschave       => vr_ds_xml,
                                           pr_dsxml         => null,
                                           pr_des_erro      => vr_des_erro);
           if vr_des_erro is not null then
              vr_des_erro:= 'VR_TAB_LIS_AGNSDDIS - '||vr_des_erro;
              raise vr_exc_erro;
           end if;                                            
            vr_indice:= vr_tab_lis_agnsddis.next(vr_indice);
         end loop;
         
         -- Total do limite da agencia - VR_TAB_LIS_AGNVLLIM
         vr_indice := vr_tab_lis_agnvllim.first;
         while vr_indice is not null loop
            vr_ds_xml:= ds_character_separador||
                        vr_tab_lis_agnvllim(vr_indice)||ds_character_separador||
                        vr_indice||ds_character_separador;
        
            pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                           pr_nmtabmemoria  => 'VR_TAB_LIS_AGNVLLIM',
                                           pr_dtmvtolt      => vr_dtmvtolt,
                                           pr_dschave       => vr_ds_xml,
                                           pr_dsxml         => null,
                                           pr_des_erro      => vr_des_erro);
            if vr_des_erro is not null then
               vr_des_erro:= 'VR_TAB_LIS_AGNVLLIM - '||vr_des_erro;
               raise vr_exc_erro;
            end if;                                            
            vr_indice:= vr_tab_lis_agnvllim.next(vr_indice);
         end loop;
         
        -- VR_TAB_CONTAB
        vr_indice := vr_tab_contab.first;
        while vr_indice is not null loop
           vr_ds_xml:= ds_character_separador||
                       vr_tab_contab(vr_indice).cdagenci||ds_character_separador||
                       vr_tab_contab(vr_indice).con_vlsaqblq||ds_character_separador||
                       vr_tab_contab(vr_indice).con_vladiant||ds_character_separador||
                       vr_tab_contab(vr_indice).con_vlutiliz||ds_character_separador;
           
           pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                          pr_nmtabmemoria  => 'VR_TAB_CONTAB',
                                          pr_dtmvtolt      => vr_dtmvtolt,
                                          pr_dschave       => vr_indice,
                                          pr_dsxml         => vr_ds_xml,
                                          pr_des_erro      => vr_des_erro);
            if vr_des_erro is not null then
               vr_des_erro:= 'VR_TAB_CONTAB - '||vr_des_erro;
               raise vr_exc_erro;
            end if;                                            
            vr_indice:= vr_tab_contab.next(vr_indice);
        end loop; -- vr_tab_contab  
        
       EXCEPTION
         WHEN vr_exc_erro THEN
            pr_des_erro:= vr_des_erro||' (pc_grava_tab_wrk_geral)';
         WHEN OTHERS THEN
            pr_des_erro:= 'Erro pc_grava_tab_wrk_geral: '||sqlerrm;
       END pc_grava_tab_wrk_geral;

       ------------------------------------------------------------------
       -- Lê as tabelas de memoria e salva os dados na tabela de trabalho
       -- Projeto Ligeirinho
       ------------------------------------------------------------------
       PROCEDURE pc_grava_tab_wrk_crrl055 (pr_des_erro out varchar2) IS
        -- VR_TAB_CRAT055
        vr_exc_erro  exception;  
        vr_indice    varchar2(50);      
       BEGIN
        vr_indice := vr_tab_crat055.first;
        while vr_indice is not null loop
           vr_ds_xml:= ds_character_separador||
                       vr_tab_crat055(vr_indice).cdagenci||ds_character_separador||
                       vr_tab_crat055(vr_indice).nrdconta||ds_character_separador||
                       vr_tab_crat055(vr_indice).nmprimtl||ds_character_separador||
                       vr_tab_crat055(vr_indice).vlsddisp||ds_character_separador||
                       vr_tab_crat055(vr_indice).vllimcre||ds_character_separador||
                       vr_tab_crat055(vr_indice).vlsdbltl||ds_character_separador||
                       vr_tab_crat055(vr_indice).vlstotal||ds_character_separador||
                       vr_tab_crat055(vr_indice).dsdacstp||ds_character_separador||
                       vr_tab_crat055(vr_indice).nrcpfcgc||ds_character_separador||
                       vr_indice||ds_character_separador;
                       
           pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                          pr_nmtabmemoria  => 'VR_TAB_CRAT055',
                                          pr_dtmvtolt      => vr_dtmvtolt,
                                          pr_dschave       => vr_ds_xml,
                                          pr_dsxml         => null,
                                          pr_des_erro      => vr_des_erro);
            if vr_des_erro is not null then
               vr_des_erro:= 'VR_TAB_CRAT055 - '||vr_des_erro;
               raise vr_exc_erro;
            end if;                                            
            vr_indice:= vr_tab_crat055.next(vr_indice);
        end loop; -- vr_tab_crat055
       EXCEPTION
         WHEN vr_exc_erro THEN
            pr_des_erro:= vr_des_erro||' (pc_grava_tab_wrk_crrl055)';
         WHEN OTHERS THEN
            pr_des_erro:= 'Erro PC_GRAVA_TAB_WRK_CRRL055: '||sqlerrm;
       END pc_grava_tab_wrk_crrl055;
       
       ------------------------------------------------------------------
       -- Lê as tabelas de memoria e salva os dados na tabela de trabalho
       -- Projeto Ligeirinho
       ------------------------------------------------------------------
       PROCEDURE pc_grava_tab_wrk_crrl030 (pr_des_erro out varchar2) IS
        -- VR_TAB_CRAT225
        vr_indice varchar2(50);
        vr_exc_erro  exception;        
       BEGIN
        vr_indice_crat030 := vr_tab_crat030.first;
        while vr_indice_crat030 is not null loop
           vr_indice:= lpad(vr_tab_crat030(vr_indice_crat030).cdagenci,5,'0')||lpad(vr_tab_crat030(vr_indice_crat030).nrdconta,10,'0');
           vr_ds_xml:= ds_character_separador||
                       vr_tab_crat030(vr_indice_crat030).cdagenci||ds_character_separador||
                       vr_tab_crat030(vr_indice_crat030).nrdconta||ds_character_separador||
                       vr_tab_crat030(vr_indice_crat030).nmprimtl||ds_character_separador||
                       vr_tab_crat030(vr_indice_crat030).vlsddisp||ds_character_separador||
                       vr_tab_crat030(vr_indice_crat030).vllimcre||ds_character_separador||
                       vr_tab_crat030(vr_indice_crat030).vlsdchsl||ds_character_separador||
                       vr_tab_crat030(vr_indice_crat030).dtdsdclq||ds_character_separador||
                       vr_tab_crat030(vr_indice_crat030).qtddsdev||ds_character_separador||
                       vr_tab_crat030(vr_indice_crat030).vlstotal||ds_character_separador||
                       vr_tab_crat030(vr_indice_crat030).vlsdbltl||ds_character_separador||
                       vr_indice||ds_character_separador;

           pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                          pr_nmtabmemoria  => 'VR_TAB_CRAT030',
                                          pr_dtmvtolt      => vr_dtmvtolt,
                                          pr_dschave       => vr_ds_xml,
                                          pr_dsxml         => null,
                                          pr_des_erro      => vr_des_erro);
            if vr_des_erro is not null then
               vr_des_erro:= 'VR_TAB_CRAT030 - '||vr_des_erro;
               raise vr_exc_erro;
            end if;                                            
            vr_indice_crat030:= vr_tab_crat030.next(vr_indice_crat030);
        end loop; -- vr_tab_crat030
       EXCEPTION
         WHEN vr_exc_erro THEN
            pr_des_erro:= vr_des_erro||' (pc_grava_tab_wrk_crrl030)';
         WHEN OTHERS THEN
            pr_des_erro:= 'Erro PC_GRAVA_TAB_WRK_CRRL030: '||sqlerrm;
       END pc_grava_tab_wrk_crrl030;
       
     
       PROCEDURE pc_grava_tab_wrk_crrl225 (pr_des_erro out varchar2) IS
       -- VR_TAB_CRAT225
       vr_indice varchar2(50);
       vr_exc_erro  exception;        
       BEGIN
        vr_indice_crat225 := vr_tab_crat225.first;
        while vr_indice_crat225 is not null loop
           vr_ds_xml:= ds_character_separador||
                       vr_tab_crat225(vr_indice_crat225).cdagenci||ds_character_separador||
                       vr_tab_crat225(vr_indice_crat225).nrdconta||ds_character_separador||
                       vr_tab_crat225(vr_indice_crat225).nmprimtl||ds_character_separador||
                       vr_tab_crat225(vr_indice_crat225).cdempres||ds_character_separador||
                       vr_tab_crat225(vr_indice_crat225).cdturnos||ds_character_separador||
                       vr_tab_crat225(vr_indice_crat225).qtddsdev||ds_character_separador||
                       vr_tab_crat225(vr_indice_crat225).vlsddisp||ds_character_separador||
                       vr_tab_crat225(vr_indice_crat225).vllimcre||ds_character_separador||
                       vr_tab_crat225(vr_indice_crat225).nrdofone||ds_character_separador||
                       vr_tab_crat225(vr_indice_crat225).dsdacstp||ds_character_separador||
                       vr_tab_crat225(vr_indice_crat225).vlestour||ds_character_separador||
                       vr_tab_crat225(vr_indice_crat225).vlsdbltl||ds_character_separador||
                       vr_tab_crat225(vr_indice_crat225).vlstotal||ds_character_separador;                                                                     
                       
           vr_indice:= lpad(vr_tab_crat225(vr_indice_crat225).cdagenci,5,'0')||lpad(vr_tab_crat225(vr_indice_crat225).nrdconta,10,'0');
           
           pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                          pr_nmtabmemoria  => 'VR_TAB_CRAT225',
                                          pr_dtmvtolt      => vr_dtmvtolt,
                                          pr_dschave       => vr_indice,
                                          pr_dsxml         => vr_ds_xml,
                                          pr_des_erro      => vr_des_erro);
            if vr_des_erro is not null then
               vr_des_erro:= 'VR_TAB_CRAT225 - '||vr_des_erro;
               raise vr_exc_erro;
            end if;                                            
                                          
            vr_indice_crat225:= vr_tab_crat225.next(vr_indice_crat225);
        end loop; -- vr_tab_crat225
       EXCEPTION
         WHEN vr_exc_erro THEN
            pr_des_erro:= vr_des_erro||' (pc_grava_tab_wrk_crrl225)';
         WHEN OTHERS THEN
            pr_des_erro:= 'Erro PC_GRAVA_TAB_WRK_CRRL225: '||sqlerrm;
       END pc_grava_tab_wrk_crrl225; 
       
      
       PROCEDURE pc_grava_tab_wrk_crrl226 (pr_des_erro out varchar2) IS
       -- VR_TAB_CRAT030
       vr_indice varchar2(50);
       vr_exc_erro  exception;      
       BEGIN
        vr_indice_crat226 := vr_tab_crat226.first;
        while vr_indice_crat226 is not null loop
           vr_ds_xml:= ds_character_separador||
                       vr_tab_crat226(vr_indice_crat226).cdagenci||ds_character_separador||
                       vr_tab_crat226(vr_indice_crat226).nrdconta||ds_character_separador||
                       vr_tab_crat226(vr_indice_crat226).nmprimtl||ds_character_separador||
                       vr_tab_crat226(vr_indice_crat226).cdempres||ds_character_separador||
                       vr_tab_crat226(vr_indice_crat226).qtddsdev||ds_character_separador||
                       vr_tab_crat226(vr_indice_crat226).vlsddisp||ds_character_separador||
                       vr_tab_crat226(vr_indice_crat226).vllimcre||ds_character_separador||
                       vr_tab_crat226(vr_indice_crat226).cdturnos||ds_character_separador||
                       vr_tab_crat226(vr_indice_crat226).tpvincul||ds_character_separador||
                       vr_tab_crat226(vr_indice_crat226).dsdacstp||ds_character_separador||
                       vr_tab_crat226(vr_indice_crat226).vlestour||ds_character_separador||
                       vr_tab_crat226(vr_indice_crat226).vlsdbltl||ds_character_separador||
                       vr_tab_crat226(vr_indice_crat226).vlstotal||ds_character_separador;                                                                     
                       
           vr_indice:= lpad(vr_tab_crat226(vr_indice_crat226).cdagenci,5,'0')||lpad(vr_tab_crat226(vr_indice_crat226).nrdconta,10,'0');
           
           pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                          pr_nmtabmemoria  => 'VR_TAB_CRAT226',
                                          pr_dtmvtolt      => vr_dtmvtolt,
                                          pr_dschave       => vr_indice,
                                          pr_dsxml         => vr_ds_xml,
                                          pr_des_erro      => vr_des_erro);
            if vr_des_erro is not null then
               vr_des_erro:= 'VR_TAB_CRAT226 - '||vr_des_erro;
               raise vr_exc_erro;
            end if;                                            
            vr_indice_crat226:= vr_tab_crat226.next(vr_indice_crat226);
        end loop; -- vr_tab_crat226
       EXCEPTION
         WHEN vr_exc_erro THEN
            pr_des_erro:= vr_des_erro||' (pc_grava_tab_wrk_crrl226)';
         WHEN OTHERS THEN
            pr_des_erro:= 'Erro PC_GRAVA_TAB_WRK_CRRL226: '||sqlerrm;
       END pc_grava_tab_wrk_crrl226; 
       
       PROCEDURE pc_grava_tab_wrk_crrl007 (pr_des_erro out varchar2) IS
        -- VR_TAB_CRAT007
        vr_indice    varchar2(50);
        vr_exc_erro  exception;
        
       BEGIN
         vr_indice := vr_tab_crat007.first;
         while vr_indice is not null loop
            vr_ds_xml:= ds_character_separador||
                        vr_tab_crat007(vr_indice).cdagenci||ds_character_separador||
                        vr_tab_crat007(vr_indice).nrdconta||ds_character_separador||
                        vr_tab_crat007(vr_indice).nmprimtl||ds_character_separador||
                        vr_tab_crat007(vr_indice).qtddsdev||ds_character_separador||
                        vr_tab_crat007(vr_indice).vlsddisp||ds_character_separador||
                        vr_tab_crat007(vr_indice).vllimcre||ds_character_separador||
                        vr_tab_crat007(vr_indice).nrdofone||ds_character_separador||
                        vr_tab_crat007(vr_indice).vlestour||ds_character_separador||
                        vr_tab_crat007(vr_indice).vlsdbltl||ds_character_separador||
                        vr_tab_crat007(vr_indice).qtcompbb||ds_character_separador||                      
                        vr_tab_crat007(vr_indice).vlcompbb||ds_character_separador||                     
                        vr_tab_crat007(vr_indice).qtcmpbcb||ds_character_separador||                                             
                        vr_tab_crat007(vr_indice).vlcmpbcb||ds_character_separador||                                            
                        vr_tab_crat007(vr_indice).qtcmpctl||ds_character_separador||                                            
                        vr_tab_crat007(vr_indice).vlcmpctl||ds_character_separador||                                            
                        vr_tab_crat007(vr_indice).qtcstdct||ds_character_separador||                                           
                        vr_tab_crat007(vr_indice).vlcstdct||ds_character_separador||                                                                    
                        vr_tab_crat007(vr_indice).flsldapl||ds_character_separador||
                        vr_tab_crat007(vr_indice).flgdevolu_autom||ds_character_separador||                        
                        vr_tab_crat007(vr_indice).qtdevolu||ds_character_separador;                       
                    
            pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                           pr_nmtabmemoria  => 'VR_TAB_CRAT007',
                                           pr_dtmvtolt      => vr_dtmvtolt,
                                           pr_dschave       => vr_indice,
                                           pr_dsxml         => vr_ds_xml,
                                           pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_CRAT007 - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_crat007.next(vr_indice);
         end loop; -- vr_tab_crat007
         
         -- VR_TAB_CRAT071
         vr_indice := vr_tab_crat071.first;
         while vr_indice is not null loop
            vr_ds_xml:= ds_character_separador||
                        vr_tab_crat071(vr_indice).cdagenci||ds_character_separador||
                        vr_tab_crat071(vr_indice).nrdconta||ds_character_separador||
                        vr_tab_crat071(vr_indice).cdempres||ds_character_separador||
                        vr_tab_crat071(vr_indice).nmprimtl||ds_character_separador||
                        vr_tab_crat071(vr_indice).vlsddisp||ds_character_separador||
                        vr_tab_crat071(vr_indice).cdturnos||ds_character_separador||
                        vr_tab_crat071(vr_indice).vlstotal||ds_character_separador||
                        vr_tab_crat071(vr_indice).dsdacstp||ds_character_separador||
                        vr_tab_crat071(vr_indice).nrdofone||ds_character_separador;

                    
            pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                           pr_nmtabmemoria  => 'VR_TAB_CRAT071',
                                           pr_dtmvtolt      => vr_dtmvtolt,
                                           pr_dschave       => vr_indice,
                                           pr_dsxml         => vr_ds_xml,
                                           pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_CRAT071 - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_crat071.next(vr_indice);
         end loop; -- vr_tab_crat071
         
         -- VR_TAB_TOT_AGNSDDIS
         vr_indice := vr_tab_tot_agnsddis.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_tot_agnsddis(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_TOT_AGNSDDIS',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_TOT_AGNSDDIS - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_tot_agnsddis.next(vr_indice);
         end loop;
         
         -- VR_TAB_TOT_AGNVLLIM
         vr_indice := vr_tab_tot_agnvllim.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_tot_agnvllim(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_TOT_AGNVLLIM',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_TOT_AGNVLLIM - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_tot_agnvllim.next(vr_indice);
         end loop;

         -- VR_TAB_TOT_AGNSDBTL
         vr_indice := vr_tab_tot_agnsdbtl.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_tot_agnsdbtl(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_TOT_AGNSDBTL',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_TOT_AGNSDBTL - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_tot_agnsdbtl.next(vr_indice);
         end loop;
         
         -- VR_TAB_TOT_VLCSTDCT
         vr_indice := vr_tab_tot_vlcstdct.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_tot_vlcstdct(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_TOT_VLCSTDCT',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_TOT_VLCSTDCT - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_tot_vlcstdct.next(vr_indice);
         end loop;

         -- VR_TAB_TOT_QTCSTDCT
         vr_indice := vr_tab_tot_qtcstdct.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_tot_qtcstdct(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_TOT_QTCSTDCT',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_TOT_QTCSTDCT - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_tot_qtcstdct.next(vr_indice);
         end loop;
         
          -- VR_TAB_REL_AGNSDDIS
         vr_indice := vr_tab_rel_agnsddis.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_rel_agnsddis(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_REL_AGNSDDIS',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_REL_AGNSDDIS - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_rel_agnsddis.next(vr_indice);
         end loop;
         
          -- VR_TAB_REL_AGNVLLIM
         vr_indice := vr_tab_rel_agnvllim.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_rel_agnvllim(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_REL_AGNVLLIM',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_REL_AGNVLLIM - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_rel_agnvllim.next(vr_indice);
         end loop;

          -- VR_TAB_REL_AGNSDBTL
         vr_indice := vr_tab_rel_agnsdbtl.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_rel_agnsdbtl(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_REL_AGNSDBTL',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_REL_AGNSDBTL - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_rel_agnsdbtl.next(vr_indice);
         end loop;

       EXCEPTION
         WHEN vr_exc_erro THEN
            pr_des_erro:= vr_des_erro||' (pc_grava_tab_wrk_crrl007)';
         WHEN OTHERS THEN
            pr_des_erro:= 'Erro PC_GRAVA_TAB_WRK_CRRL007: '||sqlerrm;
       END pc_grava_tab_wrk_crrl007; 

       PROCEDURE pc_grava_tab_wrk_crrl006 (pr_des_erro out varchar2) IS
        -- VR_TAB_CRAT006
        vr_indice    varchar2(50);
        vr_exc_erro  exception;
        
       BEGIN
         vr_indice_crat006 := vr_tab_crat006.first;
         while vr_indice_crat006 is not null loop
            vr_indice:= lpad(vr_tab_crat006(vr_indice_crat006).cdagenci,5,'0')||
                        lpad(vr_tab_crat006(vr_indice_crat006).nrdconta,10,'0');
            vr_ds_xml:= ds_character_separador||
                        vr_tab_crat006(vr_indice_crat006).cdagenci||ds_character_separador||
                        vr_tab_crat006(vr_indice_crat006).nrdconta||ds_character_separador||
                        vr_tab_crat006(vr_indice_crat006).nmprimtl||ds_character_separador||
                        vr_tab_crat006(vr_indice_crat006).vlsaqmax||ds_character_separador||
                        vr_tab_crat006(vr_indice_crat006).vlsddisp||ds_character_separador||
                        vr_tab_crat006(vr_indice_crat006).vllimcre||ds_character_separador||
                        vr_tab_crat006(vr_indice_crat006).vlsdbltl||ds_character_separador||
                        vr_tab_crat006(vr_indice_crat006).vlsdchsl||ds_character_separador||
                        vr_tab_crat006(vr_indice_crat006).vlstotal||ds_character_separador||
                        vr_tab_crat006(vr_indice_crat006).vlblqjud||ds_character_separador||                      
                        vr_tab_crat006(vr_indice_crat006).dsdacstp||ds_character_separador||
                        vr_indice||ds_character_separador;                    
                           
            pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                           pr_nmtabmemoria  => 'VR_TAB_CRAT006',
                                           pr_dtmvtolt      => vr_dtmvtolt,
                                           pr_dschave       => vr_ds_xml,
                                           pr_dsxml         => null,
                                           pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_CRAT006 - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice_crat006:= vr_tab_crat006.next(vr_indice_crat006);
         end loop; -- vr_tab_crat006
          
         ----------------------------------------------- 
         -- DEM
         -----------------------------------------------
         -- saque maximo da agencia - VR_TAB_DEM_AGPSDMAX
         vr_indice := vr_tab_dem_agpsdmax.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_dem_agpsdmax(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_DEM_AGPSDMAX',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_DEM_AGPSDMAX - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_dem_agpsdmax.next(vr_indice);
         end loop;

         -- valor limite da agencia - VR_TAB_DEM_AGPSDDIS
         vr_indice := vr_tab_dem_agpsddis.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_dem_agpsddis(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_DEM_AGPSDDIS',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_DEM_AGPSDDIS - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_dem_agpsddis.next(vr_indice);
         end loop;

         -- saldo disponivel da agencia - VR_TAB_DEM_AGPVLLIM
         vr_indice := vr_tab_dem_agpvllim.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_dem_agpvllim(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_DEM_AGPVLLIM',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_DEM_AGPVLLIM - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_dem_agpvllim.next(vr_indice);
         end loop;
   
         -- saldo bloqueado total da agencia - VR_TAB_DEM_AGPSDBTL
         vr_indice := vr_tab_dem_agpsdbtl.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_dem_agpsdbtl(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_DEM_AGPSDBTL',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_DEM_AGPSDBTL - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_dem_agpsdbtl.next(vr_indice);
         end loop;

         -- saldo cheque salario da agencia - VR_TAB_DEM_AGPSDCHS
         vr_indice := vr_tab_dem_agpsdchs.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_dem_agpsdchs(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_DEM_AGPSDCHS',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_DEM_AGPSDCHS - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_dem_agpsdchs.next(vr_indice);
         end loop;

         -- saldo total da agencia - VR_TAB_DEM_AGPSDSTL
         vr_indice := vr_tab_dem_agpsdstl.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_dem_agpsdstl(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_DEM_AGPSDSTL',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_DEM_AGPSDSTL - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_dem_agpsdstl.next(vr_indice);
         end loop;

         -- saldo bloqueado Judicialmente agencia - VR_TAB_DEM_AGPVLBJD
         vr_indice := vr_tab_dem_agpvlbjd.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_dem_agpvlbjd(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_DEM_AGPVLBJD',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_DEM_AGPVLBJD - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_dem_agpvlbjd.next(vr_indice);
         end loop;

         ---------------------------------------------------------
         -- REL
         ---------------------------------------------------------
         -- VR_TAB_REL_AGPSDMAX
         vr_indice := vr_tab_rel_agpsdmax.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_rel_agpsdmax(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_REL_AGPSDMAX',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_REL_AGPSDMAX - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_rel_agpsdmax.next(vr_indice);
         end loop;
         
         -- VR_TAB_REL_AGPSDDIS
         vr_indice := vr_tab_rel_agpsddis.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_rel_agpsddis(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_REL_AGPSDDIS',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_REL_AGPSDDIS - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_rel_agpsddis.next(vr_indice);
         end loop;

         -- VR_TAB_REL_AGPVLLIM
         vr_indice := vr_tab_rel_agpvllim.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_rel_agpvllim(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_REL_AGPVLLIM',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_REL_AGPVLLIM - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_rel_agpvllim.next(vr_indice);
         end loop;

         -- VR_TAB_REL_AGPSDBTL
         vr_indice := vr_tab_rel_agpsdbtl.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_rel_agpsdbtl(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_REL_AGPSDBTL',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_REL_AGPSDBTL - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_rel_agpsdbtl.next(vr_indice);
         end loop;

         -- VR_TAB_REL_AGPSDCHS
         vr_indice := vr_tab_rel_agpsdchs.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_rel_agpsdchs(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_REL_AGPSDCHS',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_REL_AGPSDCHS - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_rel_agpsdchs.next(vr_indice);
         end loop;

         -- VR_TAB_REL_AGPSDSTL
         vr_indice := vr_tab_rel_agpsdstl.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_rel_agpsdstl(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_REL_AGPSDSTL',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_REL_AGPSDSTL - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_rel_agpsdstl.next(vr_indice);
         end loop;

         -- VR_TAB_REL_AGPSDBJD
         vr_indice := vr_tab_rel_agpsdbjd.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_rel_agpsdbjd(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_REL_AGPSDBJD',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_REL_AGPSDBJD - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_rel_agpsdbjd.next(vr_indice);
         end loop;

         -- VR_TAB_REL_VLSLDLIQ
         vr_indice := vr_tab_rel_vlsldliq.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_rel_vlsldliq(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_REL_VLSLDLIQ',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_REL_VLSLDLIQ - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_rel_vlsldliq.next(vr_indice);
         end loop;

         -- VR_TAB_REL_VLSUTILI
         vr_indice := vr_tab_rel_vlsutili.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_rel_vlsutili(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_REL_VLSUTILI',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_REL_VLSUTILI - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_rel_vlsutili.next(vr_indice);
         end loop;

         -- VR_TAB_REL_VLSAQBLQ
         vr_indice := vr_tab_rel_vlsaqblq.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_rel_vlsaqblq(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_REL_VLSAQBLQ',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_REL_VLSAQBLQ - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_rel_vlsaqblq.next(vr_indice);
         end loop;

         -- VR_TAB_REL_VLSADIAN
         vr_indice := vr_tab_rel_vlsadian.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_rel_vlsadian(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_REL_VLSADIAN',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_REL_VLSADIAN - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_rel_vlsadian.next(vr_indice);
         end loop;

         -- VR_TAB_REL_VLADICLQ
         vr_indice := vr_tab_rel_vladiclq.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_rel_vladiclq(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_REL_VLADICLQ',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_REL_VLADICLQ - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_rel_vladiclq.next(vr_indice);
         end loop;

         -- VR_TAB_REL_VLCNTINV
         vr_indice := vr_tab_rel_vlcntinv.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_rel_vlcntinv(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_REL_VLCNTINV',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_REL_VLCNTINV - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_rel_vlcntinv.next(vr_indice);
         end loop;
         
         -- VR_TAB_REL_VLBLQJUD
         vr_indice := vr_tab_rel_vlblqjud.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_rel_vlblqjud(vr_indice)||ds_character_separador;
          
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_REL_VLBLQJUD',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_REL_VLBLQJUD - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_rel_vlblqjud.next(vr_indice);
         end loop;
         
         -- VR_TAB_TOTAIS
         vr_indice_crattotais := vr_tab_totais.first;
         while vr_indice_crattotais is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_totais(vr_indice_crattotais).cdlcremp||ds_character_separador||
                         vr_tab_totais(vr_indice_crattotais).tipo||ds_character_separador||
                         vr_tab_totais(vr_indice_crattotais).vltttfis||ds_character_separador||
                         vr_tab_totais(vr_indice_crattotais).vltttjur||ds_character_separador;
                                                                                     
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_TOTAIS',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_indice_crattotais,
                                            pr_dsxml         => vr_ds_xml,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_TOTAIS - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice_crattotais:= vr_tab_totais.next(vr_indice_crattotais);
         end loop;        

         -- VR_TAB_DETALHES
         vr_indice := vr_tab_detalhes.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_detalhes(vr_indice).cdagenci||ds_character_separador||
                         vr_tab_detalhes(vr_indice).nrdconta||ds_character_separador||
                         vr_tab_detalhes(vr_indice).nmprimtl||ds_character_separador||
                         vr_tab_detalhes(vr_indice).cdlcremp||ds_character_separador||
                         vr_tab_detalhes(vr_indice).nrctremp||ds_character_separador||
                         vr_tab_detalhes(vr_indice).dtmvtolt||ds_character_separador||
                         vr_tab_detalhes(vr_indice).vlemprst||ds_character_separador||
                         vr_tab_detalhes(vr_indice).vlsdeved||ds_character_separador||
                         vr_indice||ds_character_separador;
                                                                                     
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_DETALHES',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_ds_xml,
                                            pr_dsxml         => null,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_DETALHES - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_detalhes.next(vr_indice);
         end loop;   

         -- VR_TAB_ATRASADOS
         vr_indice := vr_tab_atrasados.first;
         while vr_indice is not null loop
             vr_ds_xml:= ds_character_separador||
                         vr_tab_atrasados(vr_indice).cdagenci||ds_character_separador||
                         vr_tab_atrasados(vr_indice).nrdconta||ds_character_separador||
                         vr_tab_atrasados(vr_indice).cdlcremp||ds_character_separador||
                         vr_tab_atrasados(vr_indice).nrctremp||ds_character_separador||
                         vr_tab_atrasados(vr_indice).dtultpag||ds_character_separador||
                         vr_tab_atrasados(vr_indice).vlsdeved||ds_character_separador||
                         vr_indice||ds_character_separador;
                                                                                     
             pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                            pr_nmtabmemoria  => 'VR_TAB_ATRASADOS',
                                            pr_dtmvtolt      => vr_dtmvtolt,
                                            pr_dschave       => vr_ds_xml,
                                            pr_dsxml         => null,
                                            pr_des_erro      => vr_des_erro);
             if vr_des_erro is not null then
                vr_des_erro:= 'VR_TAB_ATRASADOS - '||vr_des_erro;
                raise vr_exc_erro;
             end if;                                            
             vr_indice:= vr_tab_atrasados.next(vr_indice);
         end loop;   
         
        -- VR_TAB_GN006
        vr_indice := vr_tab_gn006.first;
        while vr_indice is not null loop
           vr_ds_xml:= ds_character_separador||
                       vr_tab_gn006(vr_indice).cdagenci||ds_character_separador||
                       vr_tab_gn006(vr_indice).nrdconta||ds_character_separador||
                       vr_tab_gn006(vr_indice).vlstotal||ds_character_separador;
           
           pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                          pr_nmtabmemoria  => 'VR_TAB_GN006',
                                          pr_dtmvtolt      => vr_dtmvtolt,
                                          pr_dschave       => vr_indice,
                                          pr_dsxml         => vr_ds_xml,
                                          pr_des_erro      => vr_des_erro);
            if vr_des_erro is not null then
               vr_des_erro:= 'VR_TAB_GN006 - '||vr_des_erro;
               raise vr_exc_erro;
            end if;                                            
            vr_indice:= vr_tab_gn006.next(vr_indice);
        end loop; -- vr_tab_gn006  
                  
       EXCEPTION
         WHEN vr_exc_erro THEN
            pr_des_erro:= vr_des_erro||' (pc_grava_tab_wrk_crrl006)';
         WHEN OTHERS THEN
            pr_des_erro:= 'Erro PC_GRAVA_TAB_WRK_CRRL006: '||sqlerrm;
       END pc_grava_tab_wrk_crrl006; 
       

       PROCEDURE pc_grava_tab_wrk_crrl372 (pr_des_erro out varchar2) IS
        -- VR_TAB_CRAT372
        vr_indice varchar2(50);
        vr_exc_erro  exception;      
       BEGIN
        vr_indice_crat372 := vr_tab_crat372.first;
        while vr_indice_crat372 is not null loop
           vr_ds_xml:= ds_character_separador||
                       vr_tab_crat372(vr_indice_crat372).cdagenci||ds_character_separador||
                       vr_tab_crat372(vr_indice_crat372).nrdconta||ds_character_separador||
                       vr_tab_crat372(vr_indice_crat372).cdempres||ds_character_separador||
                       vr_tab_crat372(vr_indice_crat372).cdturnos||ds_character_separador||
                       vr_tab_crat372(vr_indice_crat372).vlsddisp||ds_character_separador||
                       vr_tab_crat372(vr_indice_crat372).nmprimtl||ds_character_separador||
                       vr_tab_crat372(vr_indice_crat372).nrdofone||ds_character_separador;
                       
           vr_indice:= lpad(vr_tab_crat372(vr_indice_crat372).cdagenci,5,'0')||lpad(vr_tab_crat372(vr_indice_crat372).nrdconta,10,'0');
           
           pc_popular_tbgen_batch_rel_wrk(pr_cdcooper      => pr_cdcooper, 
                                          pr_nmtabmemoria  => 'VR_TAB_CRAT372',
                                          pr_dtmvtolt      => vr_dtmvtolt,
                                          pr_dschave       => vr_indice,
                                          pr_dsxml         => vr_ds_xml,
                                          pr_des_erro      => vr_des_erro);
            if vr_des_erro is not null then
               vr_des_erro:= 'VR_TAB_CRAT372 - '||vr_des_erro;
               raise vr_exc_erro;
            end if;                                            
            vr_indice_crat372:= vr_tab_crat372.next(vr_indice_crat372);
        end loop; -- vr_tab_crat226
       EXCEPTION
         WHEN vr_exc_erro THEN
            pr_des_erro:= vr_des_erro||' (pc_grava_tab_wrk_crrl372)';
         WHEN OTHERS THEN
            pr_des_erro:= 'Erro PC_GRAVA_TAB_WRK_CRRL372: '||sqlerrm;
       END pc_grava_tab_wrk_crrl372; 
                 
       
       --Geração do relatório de Maiores Depositantes (crrl055)
       PROCEDURE pc_imprime_crrl055 (pr_des_erro OUT VARCHAR2) IS

         --Variaveis para totalizador por pa
         vr_pac_agpsddis NUMBER:= 0; --Saldo disponivel
         vr_pac_agpvllim NUMBER:= 0; --Limite Credito
         vr_pac_agpsdbtl NUMBER:= 0; --Saldo Bloqueado Total
         vr_pac_agpsdstl NUMBER:= 0; --Saldo Total

         --Variavel de Exceção
         vr_exc_erro EXCEPTION;

       BEGIN
         -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
         GENE0001.pc_set_modulo(pr_module => 'PC_CRPS005.pc_imprime_crrl055' ,pr_action => NULL);

         --Inicializar variavel de erro
         pr_des_erro:= NULL;
         -- Busca do diretório base da cooperativa
         vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

         -- Nome base do arquivo é crrl055
         vr_nom_arquivo := 'crrl055';
         -- Processar todos os registros dos maiores depositantes
         vr_des_chave := vr_tab_crat055.FIRST;
         LOOP
           -- Sair quando a chave atual for null (chegou no final)
           EXIT WHEN vr_des_chave IS NULL;
           -- Se estivermos processando o primeiro registro do vetor ou mudou a agência
           IF vr_des_chave = vr_tab_crat055.FIRST OR vr_tab_crat055(vr_des_chave).cdagenci <> vr_tab_crat055(vr_tab_crat055.PRIOR(vr_des_chave)).cdagenci THEN
             --Zerar totais
             vr_pac_agpsddis:= 0;
             vr_pac_agpvllim:= 0;
             vr_pac_agpsdbtl:= 0;
             vr_pac_agpsdstl:= 0;
             -- Inicializar o CLOB
             dbms_lob.createtemporary(vr_des_xml, TRUE);
             dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
             vr_dstexto:= NULL;
             -- Inicilizar as informações do XML
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<?xml version="1.0" encoding="utf-8"?><crrl055>');
             -- Adicionar o nó da agência e já iniciar o de depositos
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<agencia cdagenci="'||vr_tab_crat055(vr_des_chave).cdagenci||'"><depositos>');
           END IF;

           --Verificar se o limite esta zerado e mandar nulo
           IF Nvl(vr_tab_crat055(vr_des_chave).vllimcre,0) = 0 THEN
             vr_tab_crat055(vr_des_chave).vllimcre:= NULL;
           END IF;

           --Montar tag da conta para arquivo XML
           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<conta id="'||vr_des_chave||'">
                         <nrdconta>'||LTrim(gene0002.fn_mask_conta(vr_tab_crat055(vr_des_chave).nrdconta))||'</nrdconta>
                         <dsdacstp>'||vr_tab_crat055(vr_des_chave).dsdacstp||'</dsdacstp>
                         <nmprimtl>'||SUBSTR(vr_tab_crat055(vr_des_chave).nmprimtl,0,35)||'</nmprimtl>
                         <nrcpfcgc>'||vr_tab_crat055(vr_des_chave).nrcpfcgc||'</nrcpfcgc>
                         <vlsddisp>'||to_char(vr_tab_crat055(vr_des_chave).vlsddisp,'fm99g999g999g990d00')||'</vlsddisp>
                         <vllimcre>'||to_char(vr_tab_crat055(vr_des_chave).vllimcre,'fm999999g999g999')||'</vllimcre>
                         <vlsdbltl>'||to_char(vr_tab_crat055(vr_des_chave).vlsdbltl,'fm999g999g990d00')||'</vlsdbltl>
                         <vlstotal>'||to_char(vr_tab_crat055(vr_des_chave).vlstotal,'fm99g999g999g990d00')||'</vlstotal>
                       </conta>');

           --Acumular os totais do PA
           vr_pac_agpsddis:= vr_pac_agpsddis + nvl(vr_tab_crat055(vr_des_chave).vlsddisp,0);
           vr_pac_agpvllim:= vr_pac_agpvllim + nvl(vr_tab_crat055(vr_des_chave).vllimcre,0);
           vr_pac_agpsdbtl:= vr_pac_agpsdbtl + nvl(vr_tab_crat055(vr_des_chave).vlsdbltl,0);
           vr_pac_agpsdstl:= vr_pac_agpsdstl + nvl(vr_tab_crat055(vr_des_chave).vlstotal,0);
           -- Se este for o ultimo registro do vetor, ou da agência
           IF vr_des_chave = vr_tab_crat055.LAST OR vr_tab_crat055(vr_des_chave).cdagenci <> vr_tab_crat055(vr_tab_crat055.NEXT(vr_des_chave)).cdagenci THEN
             -- Finalizar o agrupador de depositos e de Agencia e inicia totalizador do PA
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</depositos>');
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<total id="'||vr_des_chave||'">
                               <pac_agqtdcta>'||to_char(0,'fm999g990')||'</pac_agqtdcta>
                               <pac_agpsddis>'||to_char(vr_pac_agpsddis,'fm99g999g999g990d00')||'</pac_agpsddis>
                               <pac_agpvllim>'||to_char(vr_pac_agpvllim,'fm99999g999')||'</pac_agpvllim>
                               <pac_agpsdbtl>'||to_char(vr_pac_agpsdbtl,'fm999g999g990d00')||'</pac_agpsdbtl>
                               <pac_agpsdstl>'||to_char(vr_pac_agpsdstl,'fm9g999g999g990d00')||'</pac_agpsdstl>
                             </total>');
             -- Finalizar o agrupador de agencias
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</agencia></crrl055>',true);

             -- Efetuar solicitação de geração de relatório --
             gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                        ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                        ,pr_dtmvtolt  => vr_dtmvtolt         --> Data do movimento atual
                                        ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                        ,pr_dsxmlnode => '/crrl055/agencia/depositos/conta' --> Nó base do XML para leitura dos dados
                                        ,pr_dsjasper  => 'crrl055.jasper'    --> Arquivo de layout do iReport
                                        ,pr_dsparams  => 'PR_VLMAIDEP##'||To_Char(vr_rel_vlmaidep,'999g999g990d00') --> Enviar como parâmetro apenas o valor maior deposito
                                        ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'_'||to_char(vr_tab_crat055(vr_des_chave).cdagenci,'fm000')||'.lst' --> Arquivo final com código da agência
                                        ,pr_qtcoluna  => 132                 --> 132 colunas
                                        ,pr_sqcabrel  => 5                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                        ,pr_flg_impri => 'N'                 --> Chamar a impressão (Imprim.p)
                                        ,pr_nmformul  => '132dm'             --> Nome do formulário para impressão
                                        ,pr_nrcopias  => 1                   --> Número de cópias
                                        ,pr_flg_gerar => 'N'                 --> gerar PDF
                                        ,pr_des_erro  => vr_des_erro);       --> Saída com erro

             -- Testar se houve erro
             IF vr_des_erro IS NOT NULL THEN
               -- Gerar exceção
               RAISE vr_exc_erro;
             END IF;
             -- Liberando a memória alocada pro CLOB
             dbms_lob.close(vr_des_xml);
             dbms_lob.freetemporary(vr_des_xml);
             vr_dstexto:= NULL;
             --Zerar totais
             vr_pac_agpsddis:= 0;
             vr_pac_agpvllim:= 0;
             vr_pac_agpsdbtl:= 0;
             vr_pac_agpsdstl:= 0;
           END IF;
           -- Buscar o próximo registro da tabela
           vr_des_chave := vr_tab_crat055.NEXT(vr_des_chave);
         END LOOP;

         /* Gerar arquivo com todos os PAs */
         -- Nome base do arquivo
         vr_nom_arquivo := 'crrl055_'||vr_dssuftot;
         -- Inicializar o CLOB
         dbms_lob.createtemporary(vr_des_xml, TRUE);
         dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
         vr_dstexto:= NULL;
         -- Inicilizar as informações do XML
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<?xml version="1.0" encoding="utf-8"?><crrl055_99>');

         -- Processar todos os registros dos maiores depositantes
         vr_des_chave := vr_tab_crat055.FIRST;
         LOOP
           -- Sair quando a chave atual for null (chegou no final)
           EXIT WHEN vr_des_chave IS NULL;
           -- Se estivermos processando o primeiro registro do vetor ou mudou a agência
           IF vr_des_chave = vr_tab_crat055.FIRST OR vr_tab_crat055(vr_des_chave).cdagenci <> vr_tab_crat055(vr_tab_crat055.PRIOR(vr_des_chave)).cdagenci THEN
            -- Adicionar o nó da agência e já iniciar o de depositos
            gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<agencia cdagenci="'||vr_tab_crat055(vr_des_chave).cdagenci||'"><depositos>');
           END IF;

           --Verificar se o limite esta zerado e mandar nulo
           IF Nvl(vr_tab_crat055(vr_des_chave).vllimcre,0) = 0 THEN
             vr_tab_crat055(vr_des_chave).vllimcre:= NULL;
           END IF;

           --Montar tag da conta para arquivo XML
           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<conta id="'||vr_des_chave||'">
                         <nrdconta>'||LTrim(gene0002.fn_mask_conta(vr_tab_crat055(vr_des_chave).nrdconta))||'</nrdconta>
                         <dsdacstp>'||vr_tab_crat055(vr_des_chave).dsdacstp||'</dsdacstp>
                         <nmprimtl>'||vr_tab_crat055(vr_des_chave).nmprimtl||'</nmprimtl>
                         <nrcpfcgc>'||vr_tab_crat055(vr_des_chave).nrcpfcgc||'</nrcpfcgc>
                         <vlsddisp>'||to_char(vr_tab_crat055(vr_des_chave).vlsddisp,'fm99g999g999g990d00')||'</vlsddisp>
                         <vllimcre>'||to_char(vr_tab_crat055(vr_des_chave).vllimcre,'fm999999999999')||'</vllimcre>
                         <vlsdbltl>'||to_char(vr_tab_crat055(vr_des_chave).vlsdbltl,'fm999g999g990d00')||'</vlsdbltl>
                         <vlstotal>'||to_char(vr_tab_crat055(vr_des_chave).vlstotal,'fm99g999g999g990d00')||'</vlstotal>
                       </conta>');
           -- Se este for o ultimo registro do vetor, ou da agência
           IF vr_des_chave = vr_tab_crat055.LAST OR vr_tab_crat055(vr_des_chave).cdagenci <> vr_tab_crat055(vr_tab_crat055.NEXT(vr_des_chave)).cdagenci THEN
             -- Finalizar o agrupador de depositos e de Agencia e inicia totalizador do PA
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</depositos>');
             -- Finalizar o agrupador de agencias
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</agencia>');
           END IF;
           -- Buscar o próximo registro da tabela
           vr_des_chave := vr_tab_crat055.NEXT(vr_des_chave);
         END LOOP;
         --Finalizar tab relatorio
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</crrl055_99>',true);

         -- Efetuar solicitação de geração de relatório --
         gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                    ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                    ,pr_dtmvtolt  => vr_dtmvtolt         --> Data do movimento atual
                                    ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                    ,pr_dsxmlnode => '/crrl055_99' --> Nó base do XML para leitura dos dados
                                    ,pr_dsjasper  => 'crrl055_total.jasper'    --> Arquivo de layout do iReport
                                    ,pr_dsparams  => 'PR_VLMAIDEP##'||To_Char(vr_rel_vlmaidep,'999g999g990d00') --> Enviar como parâmetro apenas o valor maior deposito
                                    ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final
                                    ,pr_qtcoluna  => 132                 --> 132 colunas
                                    ,pr_sqcabrel  => 5                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                    ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                    ,pr_nmformul  => '132dm'             --> Nome do formulário para impressão
                                    ,pr_nrcopias  => 1                   --> Número de cópias
                                    ,pr_flg_gerar => 'N'                 --> gerar PDF
                                    ,pr_des_erro  => vr_des_erro);       --> Saída com erro

         -- Testar se houve erro
         IF vr_des_erro IS NOT NULL THEN
           -- Gerar exceção
           RAISE vr_exc_erro;
         END IF;
         -- Liberando a memória alocada pro CLOB
         dbms_lob.close(vr_des_xml);
         dbms_lob.freetemporary(vr_des_xml);
         vr_dstexto:= NULL;
       EXCEPTION
         WHEN vr_exc_erro THEN
           pr_des_erro:= vr_des_erro;
         WHEN OTHERS THEN
           vr_cdcritic := 1115;  --Erro ao imprimir relatório
           pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'crrl055. '||sqlerrm;

           --Inclusão na tabela de erros Oracle - Chamado 822997
           CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
       END;
       --

       --Geração do relatório de Creditos em Liquidacao (crrl030)
       PROCEDURE pc_imprime_crrl030 (pr_des_erro OUT VARCHAR2) IS

         --Variaveis locais
         vr_cdagenci NUMBER:=  0; --Numero da agencia
         vr_nrcopias INTEGER:= 0; --Numero de copias a serem impressas
         vr_qtdassoc INTEGER:= 0; --quantidade associados
         vr_agpsddis NUMBER:=  0; --saldo disponivel da agencia
         vr_agpvllim NUMBER:=  0; --valor limite da agencia
         vr_agpsdbtl NUMBER:=  0; --saldo bloqueado total da agencia
         vr_agpsdchs NUMBER:=  0; --saldo cheque salario da agencia
         vr_agpsdstl NUMBER:=  0; --saldo total da agencia

         --Variaveis para totalizador por pa
         vr_tab_pac_qtasspac_30  typ_reg_tot; --quantidade associados da agencia
         vr_tab_pac_vltotlim_30  typ_reg_tot; --valor limite da agencia
         vr_tab_pac_vlsddisp_30  typ_reg_tot; --saldo disponivel da agencia
         vr_tab_pac_vlsdbltl_30  typ_reg_tot; --saldo bloqueado total da agencia
         vr_tab_pac_vlsdchsl_30  typ_reg_tot; --saldo cheque salario da agencia
         vr_tab_pac_vlstotal_30  typ_reg_tot; --saldo total da agencia

         --Variavel de Exceção
         vr_exc_erro EXCEPTION;

       BEGIN
         -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
         GENE0001.pc_set_modulo(pr_module => 'PC_CRPS005.pc_imprime_crrl030' ,pr_action => NULL);

         --Inicializar variavel de erro
         pr_des_erro:= NULL;
         -- Busca do diretório base da cooperativa
         vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

         -- Nome base do arquivo é crrl030
         vr_nom_arquivo := 'crrl030';
         -- Processar todos os registros dos maiores depositantes
         vr_des_chave := vr_tab_crat030.FIRST;
         LOOP
           -- Sair quando a chave atual for null (chegou no final)
           EXIT WHEN vr_des_chave IS NULL;
           --Numero da agencia para indice do vetor
           vr_cdagenci:= vr_tab_crat030(vr_des_chave).cdagenci;
           -- Se estivermos processando o primeiro registro do vetor ou mudou a agência
           IF vr_des_chave = vr_tab_crat030.FIRST THEN
             -- Inicializar o CLOB
             dbms_lob.createtemporary(vr_des_xml, TRUE);
             dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
             vr_dstexto:= NULL;
             -- Inicilizar as informações do XML
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<?xml version="1.0" encoding="utf-8"?><crrl030><contas>');
           END IF;
           --Verificar se o valor do limite de credito é zero
           IF vr_tab_crat030(vr_des_chave).vllimcre = 0 THEN
             --Deixar o limite nulo para não imprimir no xml
             vr_tab_crat030(vr_des_chave).vllimcre:= null;
           END IF;
           --Escrever no xml as informacoes da conta
           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<conta id="'||vr_des_chave||'">
                         <nrdconta>'||LTrim(gene0002.fn_mask_conta(vr_tab_crat030(vr_des_chave).nrdconta))||'</nrdconta>
                         <cdagenci>'||vr_tab_crat030(vr_des_chave).cdagenci||'</cdagenci>
                         <qtddsdev>'||vr_tab_crat030(vr_des_chave).qtddsdev||'</qtddsdev>
                         <dtdsdclq>'||To_Char(vr_tab_crat030(vr_des_chave).dtdsdclq,'DD/MM/YYYY')||'</dtdsdclq>
                         <vlsddisp>'||to_char(vr_tab_crat030(vr_des_chave).vlsddisp,'fm999g999g990d00')||'</vlsddisp>
                         <vllimcre>'||to_char(vr_tab_crat030(vr_des_chave).vllimcre,'fm999g999g999')||'</vllimcre>
                         <nmprimtl>'||substr(vr_tab_crat030(vr_des_chave).nmprimtl,1,30)||'</nmprimtl>
                         <vlsdbltl>'||to_char(vr_tab_crat030(vr_des_chave).vlsdbltl,'fm999g999g990d00')||'</vlsdbltl>
                         <vlsdchsl>'||to_char(vr_tab_crat030(vr_des_chave).vlsdchsl,'fm999g999g990d00')||'</vlsdchsl>
                         <vlstotal>'||to_char(vr_tab_crat030(vr_des_chave).vlstotal,'fm999g999g990d00')||'</vlstotal>
                       </conta>');
           --Acumular os totais do PA
           vr_agpsddis:= nvl(vr_agpsddis,0) + Nvl(vr_tab_crat030(vr_des_chave).vlsddisp,0);
           vr_agpvllim:= nvl(vr_agpvllim,0) + Nvl(vr_tab_crat030(vr_des_chave).vllimcre,0);
           vr_agpsdbtl:= nvl(vr_agpsdbtl,0) + Nvl(vr_tab_crat030(vr_des_chave).vlsdbltl,0);
           vr_agpsdchs:= nvl(vr_agpsdchs,0) + Nvl(vr_tab_crat030(vr_des_chave).vlsdchsl,0);
           vr_agpsdstl:= nvl(vr_agpsdstl,0) + Nvl(vr_tab_crat030(vr_des_chave).vlstotal,0);
           vr_qtdassoc:= nvl(vr_qtdassoc,0) + 1;

           --Verificar se agencia existe no vetor
           IF NOT vr_tab_pac_qtasspac_30.EXISTS(vr_cdagenci) THEN
             --Criar valores no vetor
             vr_tab_pac_qtasspac_30(vr_cdagenci):= 1;
             vr_tab_pac_vltotlim_30(vr_cdagenci):= Nvl(vr_tab_crat030(vr_des_chave).vllimcre,0);
             vr_tab_pac_vlsddisp_30(vr_cdagenci):= Nvl(vr_tab_crat030(vr_des_chave).vlsddisp,0);
             vr_tab_pac_vlsdbltl_30(vr_cdagenci):= Nvl(vr_tab_crat030(vr_des_chave).vlsdbltl,0);
             vr_tab_pac_vlsdchsl_30(vr_cdagenci):= Nvl(vr_tab_crat030(vr_des_chave).vlsdchsl,0);
             vr_tab_pac_vlstotal_30(vr_cdagenci):= Nvl(vr_tab_crat030(vr_des_chave).vlstotal,0);
           ELSE
             --Acumular valores
             vr_tab_pac_qtasspac_30(vr_cdagenci):= vr_tab_pac_qtasspac_30(vr_cdagenci) + 1;
             vr_tab_pac_vltotlim_30(vr_cdagenci):= vr_tab_pac_vltotlim_30(vr_cdagenci) + Nvl(vr_tab_crat030(vr_des_chave).vllimcre,0);
             vr_tab_pac_vlsddisp_30(vr_cdagenci):= vr_tab_pac_vlsddisp_30(vr_cdagenci) + Nvl(vr_tab_crat030(vr_des_chave).vlsddisp,0);
             vr_tab_pac_vlsdbltl_30(vr_cdagenci):= vr_tab_pac_vlsdbltl_30(vr_cdagenci) + Nvl(vr_tab_crat030(vr_des_chave).vlsdbltl,0);
             vr_tab_pac_vlsdchsl_30(vr_cdagenci):= vr_tab_pac_vlsdchsl_30(vr_cdagenci) + Nvl(vr_tab_crat030(vr_des_chave).vlsdchsl,0);
             vr_tab_pac_vlstotal_30(vr_cdagenci):= vr_tab_pac_vlstotal_30(vr_cdagenci) + Nvl(vr_tab_crat030(vr_des_chave).vlstotal,0);
           END IF;
           -- Se este for o ultimo registro do vetor, ou da agência
           IF vr_des_chave = vr_tab_crat030.LAST THEN
             -- Finalizar o agrupador de contas e cria totalizador
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<total_contas id="1">
                             <tot_qtasspac>'||to_char(vr_qtdassoc,'fm999g990')||'</tot_qtasspac>
                             <tot_vltotlim>'||to_char(vr_agpvllim,'fm9999999g999')||'</tot_vltotlim>
                             <tot_vlsddisp>'||to_char(vr_agpsddis,'fm999999g990d00')||'</tot_vlsddisp>
                             <tot_vlsdbltl>'||to_char(vr_agpsdbtl,'fm9999999g990d00')||'</tot_vlsdbltl>
                              <tot_vlsdchsl>'||to_char(vr_agpsdchs,'fm9999999g990d00')||'</tot_vlsdchsl>
                             <tot_vlstotal>'||to_char(vr_agpsdstl,'fm9999999g990d00')||'</tot_vlstotal>');
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</total_contas></contas><agencias>');
             --Posicionar no primeiro registro
             vr_index_crapage:= vr_tab_crapage.FIRST;
             --Percorrer todas as agencias e imprimir informacoes
             LOOP
               --Sair quando nao tiver mais registros
               EXIT WHEN vr_index_crapage IS NULL;
               --Se existir a agencia no vetor
               IF vr_tab_pac_qtasspac_30.EXISTS(vr_tab_crapage(vr_index_crapage).cdagenci) THEN
                 gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<agencia id="'||vr_tab_crapage(vr_index_crapage).cdagenci||'">
                                 <pac_qtasspac>'||to_char(vr_tab_pac_qtasspac_30(vr_tab_crapage(vr_index_crapage).cdagenci),'fm999g990')||'</pac_qtasspac>
                                 <pac_vltotlim>'||to_char(vr_tab_pac_vltotlim_30(vr_tab_crapage(vr_index_crapage).cdagenci),'fm9999999g999')||'</pac_vltotlim>
                                 <pac_vlsddisp>'||to_char(vr_tab_pac_vlsddisp_30(vr_tab_crapage(vr_index_crapage).cdagenci),'fm999999g990d00')||'</pac_vlsddisp>
                                 <pac_vlsdbltl>'||to_char(vr_tab_pac_vlsdbltl_30(vr_tab_crapage(vr_index_crapage).cdagenci),'fm9999999g990d00')||'</pac_vlsdbltl>
                                 <pac_vlsdchsl>'||to_char(vr_tab_pac_vlsdchsl_30(vr_tab_crapage(vr_index_crapage).cdagenci),'fm9999999g990d00')||'</pac_vlsdchsl>
                                 <pac_vlstotal>'||to_char(vr_tab_pac_vlstotal_30(vr_tab_crapage(vr_index_crapage).cdagenci),'fm9999999g990d00')||'</pac_vlstotal>
                               </agencia>');
               END IF;
               -- Buscar o próximo registro da tabela
               vr_index_crapage := vr_tab_crapage.NEXT(vr_index_crapage);
             END LOOP;
             --Escrever informacoes do total da agencia
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<totais id="total">
                               <descrica>TOTAL</descrica>
                               <qtdassoc>'||to_char(vr_qtdassoc,'fm999g990')||'</qtdassoc>
                               <agpvllim>'||to_char(vr_agpvllim,'fm9999999g999')||'</agpvllim>
                               <agpsddis>'||to_char(vr_agpsddis,'fm999999g990d00')||'</agpsddis>
                               <agpsdbtl>'||to_char(vr_agpsdbtl,'fm9999999g990d00')||'</agpsdbtl>
                               <agpsdchs>'||to_char(vr_agpsdchs,'fm9999999g990d00')||'</agpsdchs>
                               <agpsdstl>'||to_char(vr_agpsdstl,'fm9999999g990d00')||'</agpsdstl>
                             </totais>');
             -- Finalizar o agrupador de Agencias e inicia totalizador do PA
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</agencias>');
             -- Finalizar o agrupador de agencias
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</crrl030>',true);

             --Se for Viacredi imprime 1 copia senao 3
             IF pr_cdcooper = 1 THEN
               vr_nrcopias:= 1;
             ELSE
               vr_nrcopias:= 3;
             END IF;

             -- Efetuar solicitação de geração de relatório --
             gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                        ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                        ,pr_dtmvtolt  => vr_dtmvtolt         --> Data do movimento atual
                                        ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                        ,pr_dsxmlnode => '/crrl030'          --> Nó base do XML para leitura dos dados
                                        ,pr_dsjasper  => 'crrl030.jasper'    --> Arquivo de layout do iReport
                                        ,pr_dsparams  => NULL                --> Nao tem parametros
                                        ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com código da agência
                                        ,pr_qtcoluna  => 132                 --> 132 colunas
                                        ,pr_sqcabrel  => 3                   --> Sequencia do Relatorio {includes/cabrel132_3.i}
                                        ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                        ,pr_nmformul  => '132dm'             --> Nome do formulário para impressão
                                        ,pr_nrcopias  => vr_nrcopias         --> Número de cópias
                                        ,pr_flg_gerar => 'N'                 --> gerar PDF
                                        ,pr_des_erro  => vr_des_erro);       --> Saída com erro

             -- Testar se houve erro
             IF vr_des_erro IS NOT NULL THEN
               -- Gerar exceção
               RAISE vr_exc_erro;
             END IF;
             -- Liberando a memória alocada pro CLOB
             dbms_lob.close(vr_des_xml);
             dbms_lob.freetemporary(vr_des_xml);
             vr_dstexto:= NULL;
           END IF;
           -- Buscar o próximo registro da tabela
           vr_des_chave := vr_tab_crat030.NEXT(vr_des_chave);
         END LOOP;
       EXCEPTION
         WHEN vr_exc_erro THEN
           pr_des_erro:= vr_des_erro;
         WHEN OTHERS THEN
           vr_cdcritic := 1115;  --Erro ao imprimir relatório
           pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'crrl030. '||sqlerrm;

           --Inclusão na tabela de erros Oracle - Chamado 822997
           CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
       END;
       --

       --Gerar relatorio Acompanhamento de Negativos
       PROCEDURE pc_imprime_crrl225 (pr_nmrescop IN crapcop.nmrescop%TYPE
                                    ,pr_flgfuctl IN BOOLEAN
                                    ,pr_des_erro OUT VARCHAR2) IS

         --Variaveis locais
         vr_cdagenci NUMBER:=  0; --Numero da agencia
         vr_nrcopias INTEGER:= 0; --Numero de copias a serem impressas

         vr_vltotlim NUMBER:=  0; --valor limite da agencia
         vr_vlsddisp NUMBER:=  0; --saldo disponivel da agencia
         vr_vlsdbltl NUMBER:=  0; --saldo bloqueado total da agencia
         vr_vlstotal NUMBER:=  0; --saldo total da agencia
         vr_nom_dircop VARCHAR2(100); --Diretorio principal da cooperativa

         --Variaveis de Email
         vr_email_dest VARCHAR2(400);

         --Variavel de Exceção
         vr_exc_erro EXCEPTION;

       BEGIN
         -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
         GENE0001.pc_set_modulo(pr_module => 'PC_CRPS005.pc_imprime_crrl225' ,pr_action => NULL);

         --Inicializar variavel de erro
         pr_des_erro:= NULL;
         -- Busca do diretório base da cooperativa
         vr_nom_dircop := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => null);

         vr_nom_direto := vr_nom_dircop||'/rl';--> Utilizaremos o rl

         -- Nome base do arquivo é crrl055
         vr_nom_arquivo := 'crrl225';
         -- Inicializar o CLOB
         dbms_lob.createtemporary(vr_des_xml, TRUE);
         dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
         vr_dstexto:= NULL;
         -- Inicilizar as informações do XML
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<?xml version="1.0" encoding="utf-8"?><crrl225><agencias>');

         -- Processar todos os registros dos maiores depositantes
         vr_des_chave := vr_tab_crat225.FIRST;
         WHILE vr_des_chave IS NOT NULL LOOP     --Sair quando a chave atual for null (chegou no final)
           --Atribuir código da agencia para variavel
           vr_cdagenci:= vr_tab_crat225(vr_des_chave).cdagenci;
           /* Verifica se os vetores possuem informacao senao imprime zero */
           --Total disponivel da agencia
           IF vr_tab_lis_agnsddis.EXISTS(vr_cdagenci) THEN
             vr_vlsddisp:= vr_tab_lis_agnsddis(vr_cdagenci);
           ELSE
              vr_vlsddisp:= 0;
           END IF;
           --Total do limite da agencia
           IF vr_tab_lis_agnvllim.EXISTS(vr_cdagenci) THEN
             vr_vltotlim:= vr_tab_lis_agnvllim(vr_cdagenci);
           ELSE
             vr_vltotlim:= 0;
           END IF;
           --Total bloqueado da agencia
           IF vr_tab_lis_agnsdbtl.EXISTS(vr_cdagenci) THEN
             vr_vlsdbltl:= vr_tab_lis_agnsdbtl(vr_cdagenci);
           ELSE
             vr_vlsdbltl:= 0;
           END IF;
           --Saldo total da agencia
           IF vr_tab_lis_agnsdstl.EXISTS(vr_cdagenci) THEN
             vr_vlstotal:= vr_tab_lis_agnsdstl(vr_cdagenci);
           ELSE
             vr_vlstotal:= 0;
           END IF;

           -- Se estivermos processando o primeiro registro do vetor ou mudou a agência
           IF vr_des_chave = vr_tab_crat225.FIRST OR vr_tab_crat225(vr_des_chave).cdagenci <> vr_tab_crat225(vr_tab_crat225.PRIOR(vr_des_chave)).cdagenci THEN

             --Verificar se a agencia existe
             IF vr_tab_crapage.EXISTS(vr_tab_crat225(vr_des_chave).cdagenci) THEN
               --Atribuir nome da agencia do cursor
               vr_nmresage:= vr_tab_crapage(vr_tab_crat225(vr_des_chave).cdagenci).nmresage;
             ELSE
               --Atribuir nome da agencia
               vr_nmresage:= 'PA NAO ENCONTRADO';
             END IF;

             --Escrever a tag de agencia com os totalizadores da mesma
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<agencia cdagenci="'||vr_tab_crat225(vr_des_chave).cdagenci||
                            '" nmresage="'|| vr_nmresage||
                            '" totvlsddisp="'||to_char(vr_vlsddisp,'fm99999g990d00')||
                            '" totvltotlim="'||to_char(vr_vltotlim,'fm99999g990')||
                            '" totvlsdbltl="'||to_char(vr_vlsdbltl,'fm99999g990d00')||
                            '" totvlstotal="'||to_char(vr_vlstotal,'fm99999g990d00')||
                            '"><contas>');
           END IF;

           --Verificar se o valor do limite de credito é zero
           IF vr_tab_crat225(vr_des_chave).vllimcre = 0 THEN
             --Deixar o limite nulo para não imprimir no xml
             vr_tab_crat225(vr_des_chave).vllimcre:= null;
           END IF;
           --Verificar se a quantidade de dias devedor é zero
           IF Nvl(vr_tab_crat225(vr_des_chave).qtddsdev,0) = 0 THEN
             --Deixar o limite nulo para não imprimir no xml
             vr_tab_crat225(vr_des_chave).qtddsdev:= null;
           END IF;

           --Escrever detalhe no xml
           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<conta id="'||vr_des_chave||'">
                         <cdagenci>'||vr_tab_crat225(vr_des_chave).cdagenci||'</cdagenci>
                         <nrdconta>'||LTrim(gene0002.fn_mask_conta(vr_tab_crat225(vr_des_chave).nrdconta))||'</nrdconta>
                         <nrdofone>'||vr_tab_crat225(vr_des_chave).nrdofone||'</nrdofone>
                         <cdempres>'||To_Char(vr_tab_crat225(vr_des_chave).cdempres,'fm00000')||'</cdempres>
                         <cdturnos>'||To_Char(vr_tab_crat225(vr_des_chave).cdturnos,'fm99')||'</cdturnos>
                         <dsdacstp>'||vr_tab_crat225(vr_des_chave).dsdacstp||'</dsdacstp>
                         <qtddsdev>'||vr_tab_crat225(vr_des_chave).qtddsdev||'</qtddsdev>
                         <vlsddisp>'||to_char(vr_tab_crat225(vr_des_chave).vlsddisp,'fm99999g999d00')||'</vlsddisp>
                         <vllimcre>'||to_char(vr_tab_crat225(vr_des_chave).vllimcre,'fm99999g999')||'</vllimcre>
                         <vlestour>'||to_char(vr_tab_crat225(vr_des_chave).vlestour,'fm99999g999d00')||'</vlestour>
                         <nmprimtl>'||vr_tab_crat225(vr_des_chave).nmprimtl||'</nmprimtl>
                         <vlsdbltl>'||to_char(vr_tab_crat225(vr_des_chave).vlsdbltl,'fm99999g999d00')||'</vlsdbltl>
                         <vlstotal>'||to_char(vr_tab_crat225(vr_des_chave).vlstotal,'fm9999g999d00')||'</vlstotal>
                       </conta>');
           -- Se este for o ultimo registro do vetor, ou da agência
           IF vr_des_chave = vr_tab_crat225.LAST OR vr_tab_crat225(vr_des_chave).cdagenci <> vr_tab_crat225(vr_tab_crat225.NEXT(vr_des_chave)).cdagenci THEN

             -- Finalizar o agrupador de depositos e de Agencia e inicia totalizador do PA
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</contas><total_pac>');
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<total id="'||vr_des_chave||'">
                               <tot_agnsddis>'||to_char(vr_vlsddisp,'fm99999g990d00')||'</tot_agnsddis>
                               <tot_agnvllim>'||to_char(vr_vltotlim,'fm99999g990')||'</tot_agnvllim>
                               <tot_agnsdbtl>'||to_char(vr_vlsdbltl,'fm99999g990d00')||'</tot_agnsdbtl>
                               <tot_agnsdstl>'||to_char(vr_vlstotal,'fm99999g990d00')||'</tot_agnsdstl>
                             </total></total_pac></agencia>');
           END IF;
           -- Buscar o próximo registro da tabela
           vr_des_chave := vr_tab_crat225.NEXT(vr_des_chave);
         END LOOP;
         -- Finalizar o agrupador de agencias e iniciar agrupador de estouros
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</agencias><estouros>');
         -- Processar todos os registros da relação de estouros
         vr_des_chave := vr_tab_crat226.FIRST;
         WHILE vr_des_chave IS NOT NULL LOOP  -- Sair quando a chave atual for null (chegou no final)
           -- Buscar o próximo registro da tabela
           --Verificar se o valor do limite de credito é zero
           IF vr_tab_crat226(vr_des_chave).vllimcre = 0 THEN
             --Deixar o limite nulo para não imprimir no xml
             vr_tab_crat226(vr_des_chave).vllimcre:= null;
           END IF;
           --Verificar se a quantidade de dias devedor é zero
           IF Nvl(vr_tab_crat226(vr_des_chave).qtddsdev,0) = 0 THEN
             --Deixar o limite nulo para não imprimir no xml
             vr_tab_crat226(vr_des_chave).qtddsdev:= null;
           END IF;


           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<estouro id="'||vr_des_chave||'">
                         <cdagenci>'||vr_tab_crat226(vr_des_chave).cdagenci||'</cdagenci>
                         <nrdconta>'||LTrim(gene0002.fn_mask_conta(vr_tab_crat226(vr_des_chave).nrdconta))||'</nrdconta>
                         <tpvincul>'||vr_tab_crat226(vr_des_chave).tpvincul||'</tpvincul>
                         <cdempres>'||To_Char(vr_tab_crat226(vr_des_chave).cdempres,'fm00000')||'</cdempres>
                         <cdturnos>'||To_Char(vr_tab_crat226(vr_des_chave).cdturnos,'fm99')||'</cdturnos>
                         <dsdacstp>'||vr_tab_crat226(vr_des_chave).dsdacstp||'</dsdacstp>
                         <qtddsdev>'||vr_tab_crat226(vr_des_chave).qtddsdev||'</qtddsdev>
                         <vlsddisp>'||to_char(vr_tab_crat226(vr_des_chave).vlsddisp,'fm99999g999d00')||'</vlsddisp>
                         <vllimcre>'||to_char(vr_tab_crat226(vr_des_chave).vllimcre,'fm99999g999')||'</vllimcre>
                         <vlestour>'||to_char(vr_tab_crat226(vr_des_chave).vlestour,'fm99999g999d00')||'</vlestour>
                         <nmprimtl>'||vr_tab_crat226(vr_des_chave).nmprimtl||'</nmprimtl>
                         <vlsdbltl>'||to_char(vr_tab_crat226(vr_des_chave).vlsdbltl,'fm99999g999d00')||'</vlsdbltl>
                         <vlstotal>'||to_char(vr_tab_crat226(vr_des_chave).vlstotal,'fm9999g999d00')||'</vlstotal>
                       </estouro>');

           vr_des_chave := vr_tab_crat226.NEXT(vr_des_chave);
         END LOOP;
         --FInalizar o agrupador do relatorio
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</estouros></crrl225>',true);

         --Se for Viacredi ou CredCrea imprime 1 copia senao 3
         IF pr_cdcooper IN (1,7) THEN
           vr_nrcopias:= 1;
         ELSE
           vr_nrcopias:= 3;
         END IF;

         --Efetuar solicitação do relatorio e Enviar email de usuario cecred com estouro
         IF pr_flgfuctl THEN
           --Recuperar emails de destino
           vr_email_dest:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRRL225_ESTOURO');
           --Verificar se nao existe email cadastrado
           IF vr_email_dest IS NULL THEN
             --Montar mensagem de erro
             vr_cdcritic := 1130;
             vr_des_erro:= gene0001.fn_busca_critica(vr_cdcritic)||'relatório estouro (crrl225).';
             --Levantar Exceção
             RAISE vr_exc_erro;
           END IF;

           gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                      ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                      ,pr_dtmvtolt  => vr_dtmvtolt         --> Data do movimento atual
                                      ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                      ,pr_dsxmlnode => '/crrl225'          --> Nó base do XML para leitura dos dados
                                      ,pr_dsjasper  => 'crrl225.jasper'    --> Arquivo de layout do iReport
                                      ,pr_dsparams  => 'PR_DSLIMITE##'||vr_rel_dslimite --> Enviar como parâmetro apenas o valor maior deposito
                                      ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com código da agência
                                      ,pr_qtcoluna  => 132                 --> 132 colunas
                                      ,pr_sqcabrel  => 4                   --> Sequencia do Relatorio {includes/cabrel132_4.i}
                                      ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                      ,pr_nmformul  => '132dm'             --> Nome do formulário para impressão
                                      ,pr_nrcopias  => vr_nrcopias         --> Número de cópias a imprimir
                                      ,pr_flg_gerar => 'N'                 --> gerar PDF
                                      ,pr_fldosmail => 'S'                 --> Flag para converter arquivo para dos antes de enviar email
                                      ,pr_dspathcop => vr_nom_dircop||'/converte/' --> Lista sep. por ';' de diretórios a copiar o relatório
                                      ,pr_dsmailcop => vr_email_dest       --> Lista sep. por ';' de emails para envio do relatório
                                      ,pr_dsassmail => 'FUNCIONARIOS DA AILOS COM ESTOURO DE CONTA NA '||Upper(pr_nmrescop)    --> Assunto do e-mail que enviará o relatório
                                      ,pr_dscormail => NULL                --> HTML corpo do email que enviará o relatório
                                      ,pr_des_erro  => vr_des_erro);       --> Saída com erro

           -- Testar se houve erro
           IF vr_des_erro IS NOT NULL THEN
             -- Gerar exceção
             RAISE vr_exc_erro;
           END IF;
           -- Liberando a memória alocada pro CLOB
           dbms_lob.close(vr_des_xml);
           dbms_lob.freetemporary(vr_des_xml);
           vr_dstexto:= NULL;
         ELSE

           -- Somente efetuar solicitação de geração de relatório --
           gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                      ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                      ,pr_dtmvtolt  => vr_dtmvtolt         --> Data do movimento atual
                                      ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                      ,pr_dsxmlnode => '/crrl225'         --> Nó base do XML para leitura dos dados
                                      ,pr_dsjasper  => 'crrl225.jasper'    --> Arquivo de layout do iReport
                                      ,pr_dsparams  => 'PR_DSLIMITE##'||vr_rel_dslimite --> Enviar como parâmetro apenas o valor maior deposito
                                      ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com código da agência
                                      ,pr_qtcoluna  => 132                 --> 132 colunas
                                      ,pr_sqcabrel  => 4                   --> Sequencia do Relatorio {includes/cabrel132_4.i}
                                      ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                      ,pr_nmformul  => '132dm'             --> Nome do formulário para impressão
                                      ,pr_nrcopias  => vr_nrcopias          --> Número de cópias a imprimir
                                      ,pr_flg_gerar => 'N'                 --> gerar na hora
                                      ,pr_dspathcop => vr_nom_dircop||'/converte/' --> Lista sep. por ';' de diretórios a copiar o relatório
                                      ,pr_des_erro  => vr_des_erro);       --> Saída com erro

           -- Testar se houve erro
           IF vr_des_erro IS NOT NULL THEN
             -- Gerar exceção
             RAISE vr_exc_erro;
           END IF;
           -- Liberando a memória alocada pro CLOB
           dbms_lob.close(vr_des_xml);
           dbms_lob.freetemporary(vr_des_xml);
           vr_dstexto:= NULL;
         END IF;

       EXCEPTION
         WHEN vr_exc_erro THEN
           pr_des_erro:= vr_des_erro;
         WHEN OTHERS THEN
           vr_cdcritic := 1115;  --Erro ao imprimir relatório
           pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'crrl225. '||sqlerrm;

           --Inclusão na tabela de erros Oracle - Chamado 822997
           CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
       END;
       --

       --Geração do relatório de Adiantamento a Depositantes (crrl007)
       PROCEDURE pc_imprime_crrl007 (pr_vlsaldisp IN NUMBER   --> Valor utilizado como parametro para conta poupança
                                    ,pr_des_erro OUT VARCHAR2) IS

         --Variaveis para totalizador por pa
         vr_vltotlim NUMBER:= 0; --Total limite
         vr_vlsddisp NUMBER:= 0; --Saldo Disponivel
         vr_vlsdbltl NUMBER:= 0; --Saldo Bloqueado Total
         vr_qtcmptot NUMBER:= 0; --Quantidade compensada total
         vr_vlcmptot NUMBER:= 0; --Valor compensado

         --Variaveis para Somatorio geral
         vr_tot_vlsddisp  NUMBER:= 0;
         vr_tot_vltotlim  NUMBER:= 0;
         vr_tot_vlsdbltl  NUMBER:= 0;
         vr_tot_qtcstdct  NUMBER:= 0;
         vr_tot_vlcstdct  NUMBER:= 0;

         --Variavel de Exceção
         vr_exc_erro EXCEPTION;

         --Variavel de Arquivo Texto
         vr_input_file utl_file.file_type;
         vr_typ_saida  VARCHAR2(3);
         vr_flgimpchq  VARCHAR2(1);
         vr_flgimpdiv  VARCHAR2(1);
         vr_flgimppou  VARCHAR2(1);
         vr_comando    VARCHAR2(100);
         vr_dircptxt   VARCHAR2(100);
         vr_nmarqtxt   VARCHAR2(100):= 'slddev.txt';

       BEGIN
         -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
         GENE0001.pc_set_modulo(pr_module => 'PC_CRPS005.pc_imprime_crrl007' ,pr_action => NULL);

         --Inicializar variavel de erro
         pr_des_erro:= NULL;
         
         /* Gerar arquivo txt para Tiago */

         --Busca o caminho padrao do arquivo no unix + /integra
         vr_nom_direto:= GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => 'rl');

         --Buscar diretorio para copiar arquivo slddev.txt por cooperativa
         --Na tabela está parametrizado qual o diretorio de cada cooperativa
         --Se nao encontrar parametro nao gera nem copia arquivo para diretorio
         vr_dircptxt := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DIR_COPIA_SLDDEV');

         --Se encontrou
         IF vr_dircptxt IS NOT NULL THEN
           -- Tenta abrir o arquivo de log em modo gravacao
           gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_direto  --> Diretório do arquivo
                                   ,pr_nmarquiv => vr_nmarqtxt    --> Nome do arquivo
                                   ,pr_tipabert => 'W'            --> Modo de abertura (R,W,A)
                                   ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                                   ,pr_des_erro => vr_des_erro);  --> Erro
           IF vr_des_erro IS NOT NULL THEN
             --Levantar Excecao
             RAISE vr_exc_erro;
           END IF;

           --Escrever o cabecalho no arquivo
           gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                         ,pr_des_text => 'CONTA/DV;TITULAR;TELEFONE;DD;DISPONIVEL;LIMITE;BLOQUEADO;ADIANT;'); --> Texto para escrita
         END IF;

         --Posicionar no primeiro registro
         vr_index_crapage:= vr_tab_crapage.FIRST;
         --Processar todas as agencias
         WHILE vr_index_crapage IS NOT NULL LOOP

            --Atribuir valores do vetor para o registro
            vr_cdagenci:= vr_tab_crapage(vr_index_crapage).cdagenci;
            vr_nmresage:= vr_tab_crapage(vr_index_crapage).nmresage;

           -- Nome base do arquivo é crrl007
           vr_nom_arquivo := 'crrl007_'||to_char(vr_cdagenci,'fm000');

           /* Verifica se os vetores possuem informacao senao imprime zero */
           --Total disponivel da agencia
           IF vr_tab_tot_agnsddis.EXISTS(vr_cdagenci) THEN
             vr_vlsddisp:= vr_tab_tot_agnsddis(vr_cdagenci);
           ELSE
             vr_vlsddisp:= 0;
           END IF;
           --Total do limite da agencia
           IF vr_tab_tot_agnvllim.EXISTS(vr_cdagenci) THEN
             vr_vltotlim:= vr_tab_tot_agnvllim(vr_cdagenci);
           ELSE
             vr_vltotlim:= 0;
           END IF;
           --Total bloqueado da agencia
           IF vr_tab_tot_agnsdbtl.EXISTS(vr_cdagenci) THEN
             vr_vlsdbltl:= vr_tab_tot_agnsdbtl(vr_cdagenci);
           ELSE
             vr_vlsdbltl:= 0;
           END IF;
           --Saldo total da agencia
           IF vr_tab_tot_qtcstdct.EXISTS(vr_cdagenci) THEN
             vr_qtcmptot:= vr_tab_tot_qtcstdct(vr_cdagenci);
           ELSE
             vr_qtcmptot:= 0;
           END IF;
           --Saldo total da agencia
           IF vr_tab_tot_vlcstdct.EXISTS(vr_cdagenci) THEN
             vr_vlcmptot:= vr_tab_tot_vlcstdct(vr_cdagenci);
           ELSE
             vr_vlcmptot:= 0;
           END IF;

           -- Inicializar o CLOB
           dbms_lob.createtemporary(vr_des_xml, TRUE);
           dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
           vr_dstexto:= NULL;
           -- Inicilizar as informações do XML
           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<?xml version="1.0" encoding="utf-8"?><crrl007>');
           -- Adicionar o nó da agência e já iniciar o de depositos
           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<agencia cdagenci="'||vr_cdagenci||
                                                 '" nmresage="'|| vr_nmresage||
                                                 '" tot_agnsddis="'||to_char(vr_vlsddisp,'fm99999g990d00')||
                                                 '" tot_agnvllim="'||to_char(vr_vltotlim,'fm99999g990')||
                                                 '" tot_agnsdbtl="'||to_char(vr_vlsdbltl,'fm99999g990d00')||
                                                 '" tot_qtcstdct="'||to_char(vr_qtcmptot,'fm9g999g990')||
                                                 '" tot_vlcstdct="'||to_char(vr_vlcmptot,'fm999g999g990d00')||
                                                 '" vlsaldisp="'||to_char(pr_vlsaldisp,'fm999g990d00')||
                                                 '"><cheques>');

           --Limpar tabela memoria crat007_final
           vr_tab_crat007_final.DELETE;

           -- Percorrer a tabela de memoria crat007 para popular a crat007_final ordenando pela agencia e conta
           vr_des_chave := vr_tab_crat007.FIRST;
           WHILE vr_des_chave IS NOT NULL LOOP
             --Se for a mesma agencia e compensação BB ou Bancoob ou Cecred ou quantidade Custodia <> 0
             IF vr_tab_crat007(vr_des_chave).cdagenci = vr_cdagenci AND
                (Nvl(vr_tab_crat007(vr_des_chave).qtcompbb,0) <> 0   OR
                 Nvl(vr_tab_crat007(vr_des_chave).qtcmpbcb,0) <> 0   OR
                 Nvl(vr_tab_crat007(vr_des_chave).qtcmpctl,0) <> 0   OR
                 Nvl(vr_tab_crat007(vr_des_chave).qtcstdct,0) <> 0) THEN

               --Zerar variaveis
               vr_qtcmptot:= 0;
               vr_vlcmptot:= 0;

               --Acumular quantidade de cheques compensados
               vr_qtcmptot:= Nvl(vr_tab_crat007(vr_des_chave).qtcompbb,0) +
                             Nvl(vr_tab_crat007(vr_des_chave).qtcmpbcb,0) +
                             Nvl(vr_tab_crat007(vr_des_chave).qtcmpctl,0);
               --Acumular valor total compensado
               vr_vlcmptot:= Nvl(vr_tab_crat007(vr_des_chave).vlcompbb,0) +
                             Nvl(vr_tab_crat007(vr_des_chave).vlcmpbcb,0) +
                             Nvl(vr_tab_crat007(vr_des_chave).vlcmpctl,0);

               --Popular tabela memoria crat007_final
               vr_index_crat007_final:= LPad(vr_cdagenci,5,'0')||LPad(vr_tab_crat007(vr_des_chave).nrdconta,10,'0');

               vr_tab_crat007_final(vr_index_crat007_final).nrdconta:= vr_tab_crat007(vr_des_chave).nrdconta;
               vr_tab_crat007_final(vr_index_crat007_final).qtddsdev:= vr_tab_crat007(vr_des_chave).qtddsdev;
               vr_tab_crat007_final(vr_index_crat007_final).vlsddisp:= vr_tab_crat007(vr_des_chave).vlsddisp;
               vr_tab_crat007_final(vr_index_crat007_final).vllimcre:= vr_tab_crat007(vr_des_chave).vllimcre;
               vr_tab_crat007_final(vr_index_crat007_final).vlestour:= vr_tab_crat007(vr_des_chave).vlestour;
               vr_tab_crat007_final(vr_index_crat007_final).nmprimtl:= vr_tab_crat007(vr_des_chave).nmprimtl;
               vr_tab_crat007_final(vr_index_crat007_final).vlsdbltl:= vr_tab_crat007(vr_des_chave).vlsdbltl;
               vr_tab_crat007_final(vr_index_crat007_final).qtcmptot:= vr_qtcmptot;
               vr_tab_crat007_final(vr_index_crat007_final).vlcmptot:= vr_vlcmptot;
               vr_tab_crat007_final(vr_index_crat007_final).qtcstdct:= vr_tab_crat007(vr_des_chave).qtcstdct;
               vr_tab_crat007_final(vr_index_crat007_final).vlcstdct:= vr_tab_crat007(vr_des_chave).vlcstdct;
               vr_tab_crat007_final(vr_index_crat007_final).flgdevolu_autom:= vr_tab_crat007(vr_des_chave).flgdevolu_autom;
               vr_tab_crat007_final(vr_index_crat007_final).qtdevolu:= vr_tab_crat007(vr_des_chave).qtdevolu;
               vr_tab_crat007_final(vr_index_crat007_final).flsldapl:= vr_tab_crat007(vr_des_chave).flsldapl;
             END IF;
             -- Buscar o próximo registro da tabela
             vr_des_chave := vr_tab_crat007.NEXT(vr_des_chave);
           END LOOP; --crat007

           -- Setar variavel para nao imprimir informacoes no relatorio caso nao existam
           vr_flgimpchq:= 'N';
           -- Processar todos os registros dos cheques ordenados por agencia e conta
           vr_des_chave := vr_tab_crat007_final.FIRST;
           WHILE vr_des_chave IS NOT NULL LOOP

             --Escrever as informacoes da conta no XML
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<cheque id="'||vr_des_chave||'">
                             <nrdconta>'||LTrim(gene0002.fn_mask_conta(vr_tab_crat007_final(vr_des_chave).nrdconta))||'</nrdconta>
                             <qtddsdev>'||vr_tab_crat007_final(vr_des_chave).qtddsdev||'</qtddsdev>
                             <vlsddisp>'||to_char(vr_tab_crat007_final(vr_des_chave).vlsddisp,'fm99999g990d00mi')||'</vlsddisp>
                             <vllimcre>'||to_char(vr_tab_crat007_final(vr_des_chave).vllimcre,'fm999999g999')||'</vllimcre>
                             <vlestour>'||to_char(vr_tab_crat007_final(vr_des_chave).vlestour,'fm99999g990d00')||'</vlestour>
                             <nmprimtl>'||substr(vr_tab_crat007_final(vr_des_chave).nmprimtl,1,20)||'</nmprimtl>
                             <vlsdbltl>'||to_char(vr_tab_crat007_final(vr_des_chave).vlsdbltl,'fm99999g990d00')||'</vlsdbltl>
                             <qtcmptot>'||to_char(vr_tab_crat007_final(vr_des_chave).qtcmptot,'fm9990')||'</qtcmptot>
                             <vlcmptot>'||to_char(vr_tab_crat007_final(vr_des_chave).vlcmptot,'fm999g990d00')||'</vlcmptot>
                             <qtcstdct>'||to_char(vr_tab_crat007_final(vr_des_chave).qtcstdct,'fm9990')||'</qtcstdct>
                             <vlcstdct>'||to_char(vr_tab_crat007_final(vr_des_chave).vlcstdct,'fm999g990d00')||'</vlcstdct>                             
                             <flgdevolu_autom>'||vr_tab_crat007_final(vr_des_chave).flgdevolu_autom||'</flgdevolu_autom>
                             <flsldapl>'||vr_tab_crat007_final(vr_des_chave).flsldapl||'</flsldapl>
                             <qtdevolu>'||to_char(vr_tab_crat007_final(vr_des_chave).qtdevolu,'fm999g990')||'</qtdevolu>
                           </cheque>');
             -- Atribuir true para parametro que imprime informacoes no relatorio
             vr_flgimpchq:= 'S';
             -- Buscar o próximo registro da tabela
             vr_des_chave := vr_tab_crat007_final.NEXT(vr_des_chave);
           END LOOP; --crat007_final
           -- Verifica se não houve registro de cheque
           if vr_flgimpchq = 'N' then
           -- Cria tag em branco para nao gerar erro na chamada do subreport
           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<cheque></cheque>');
           end if;
           -- Finalizar o agrupador de cheques e iniciar o agrupador dos diversos
           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</cheques><diversos>');

           -- Flag controle impressao
           vr_flgimpdiv:= 'N';
           -- Processar todos os registros dos diversos
           vr_des_chave := vr_tab_crat007.FIRST;
           WHILE vr_des_chave IS NOT NULL LOOP

             --Se for a mesma agencia e compensação BB ou Bancoob ou Cecred ou quantidade Custodia <> 0
             IF vr_tab_crat007(vr_des_chave).cdagenci = vr_cdagenci AND
                (Nvl(vr_tab_crat007(vr_des_chave).qtcompbb,0) = 0   AND
                 Nvl(vr_tab_crat007(vr_des_chave).qtcmpbcb,0) = 0   AND
                 Nvl(vr_tab_crat007(vr_des_chave).qtcmpctl,0) = 0   AND
                 Nvl(vr_tab_crat007(vr_des_chave).qtcstdct,0) = 0) THEN

               -- Flag controle impressao
               vr_flgimpdiv:= 'S';
               
               IF vr_tab_crat007(vr_des_chave).qtddsdev > 15   OR
                  vr_tab_crat007(vr_des_chave).vlestour > 500 THEN
               
               --Escrever as informacoes da conta no XML
               gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<diverso id="'||vr_des_chave||'">
                             <nrdconta>'||LTrim(gene0002.fn_mask_conta(vr_tab_crat007(vr_des_chave).nrdconta))||'</nrdconta>
                             <nmprimtl>'||substr(vr_tab_crat007(vr_des_chave).nmprimtl,1,29)||'</nmprimtl>
                             <nrdofone>'||vr_tab_crat007(vr_des_chave).nrdofone||'</nrdofone>
                             <qtddsdev>'||vr_tab_crat007(vr_des_chave).qtddsdev||'</qtddsdev>
                             <vlsddisp>'||to_char(vr_tab_crat007(vr_des_chave).vlsddisp,'fm99999g990d00mi')||'</vlsddisp>
                             <vllimcre>'||to_char(vr_tab_crat007(vr_des_chave).vllimcre,'fm999999g999')||'</vllimcre>
                             <vlestour>'||to_char(vr_tab_crat007(vr_des_chave).vlestour,'fm99999g990d00')||'</vlestour>
                             <vlsdbltl>'||to_char(vr_tab_crat007(vr_des_chave).vlsdbltl,'fm99999g990d00')||'</vlsdbltl>
                           </diverso>');

               ELSE

                   --Escrever as informacoes da conta no XML
                   gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<diverso2 id="'||vr_des_chave||'">
                                 <nrdconta>'||LTrim(gene0002.fn_mask_conta(vr_tab_crat007(vr_des_chave).nrdconta))||'</nrdconta>
                                 <nmprimtl>'||substr(vr_tab_crat007(vr_des_chave).nmprimtl,1,29)||'</nmprimtl>
                                 <nrdofone>'||vr_tab_crat007(vr_des_chave).nrdofone||'</nrdofone>
                                 <qtddsdev>'||vr_tab_crat007(vr_des_chave).qtddsdev||'</qtddsdev>
                                 <vlsddisp>'||to_char(vr_tab_crat007(vr_des_chave).vlsddisp,'fm99999g990d00mi')||'</vlsddisp>
                                 <vllimcre>'||to_char(vr_tab_crat007(vr_des_chave).vllimcre,'fm999999g999')||'</vllimcre>
                                 <vlestour>'||to_char(vr_tab_crat007(vr_des_chave).vlestour,'fm99999g990d00')||'</vlestour>
                                 <vlsdbltl>'||to_char(vr_tab_crat007(vr_des_chave).vlsdbltl,'fm99999g990d00')||'</vlsdbltl>
                               </diverso2>');
               END IF;
                             

               --Se for uma cooperativa que deve enviar arquivo
               IF vr_dircptxt IS NOT NULL THEN
                 --Montar mensagem para arquivo
                 vr_setlinha:= gene0002.fn_mask_conta(vr_tab_crat007(vr_des_chave).nrdconta)||';'||
                               vr_tab_crat007(vr_des_chave).nmprimtl||';'||
                               vr_tab_crat007(vr_des_chave).nrdofone||';'||
                               vr_tab_crat007(vr_des_chave).qtddsdev||';'||
                               to_char(vr_tab_crat007(vr_des_chave).vlsddisp,'fm99999g990d00')||';'||
                               to_char(vr_tab_crat007(vr_des_chave).vllimcre,'fm999999g999')||';'||
                               to_char(vr_tab_crat007(vr_des_chave).vlsdbltl,'fm99999g990d00')||';'||
                               to_char(vr_tab_crat007(vr_des_chave).vlestour,'fm99999g990d00')||';';
                 --Escrever as informacoes da conta no arquivo
                 gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                               ,pr_des_text => vr_setlinha); --> Texto para escrita
               END IF;
             END IF;
             -- Buscar o próximo registro da tabela
             vr_des_chave := vr_tab_crat007.NEXT(vr_des_chave);
           END LOOP; --crat007

           -- Verifica se nao houve registro de diversos.
           if vr_flgimpdiv = 'N' then
           -- Cria tag em branco para que não gere erro na chamada do subreport
           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<diverso></diverso>');
           end if;


           -- Finalizar o agrupador de diversos e iniciar o agrupador dos poupancas
           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</diversos><poupancas>');

           -- Flag controle impressao
           vr_flgimppou:= 'N';
           -- Processar todos os registros da tabela crat071
           vr_des_chave := vr_tab_crat071.FIRST;
           WHILE vr_des_chave IS NOT NULL LOOP

             --Se for a mesma agencia
             IF vr_tab_crat071(vr_des_chave).cdagenci = vr_cdagenci THEN

               -- Flag controle impressao
               vr_flgimppou:= 'S';
               --Escrever as informacoes da conta no XML
               gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<poupanca id="'||vr_des_chave||'">
                             <nrdconta>'||LTrim(gene0002.fn_mask_conta(vr_tab_crat071(vr_des_chave).nrdconta))||'</nrdconta>
                             <nmprimtl>'||vr_tab_crat071(vr_des_chave).nmprimtl||'</nmprimtl>
                             <nrdofone>'||vr_tab_crat071(vr_des_chave).nrdofone||'</nrdofone>
                             <cdempres>'||To_Char(vr_tab_crat071(vr_des_chave).cdempres,'fm00009')||'</cdempres>
                             <cdturnos>'||To_Char(vr_tab_crat071(vr_des_chave).cdturnos,'fm99')||'</cdturnos>
                             <dsdacstp>'||vr_tab_crat071(vr_des_chave).dsdacstp||'</dsdacstp>
                             <vlsddisp>'||to_char(vr_tab_crat071(vr_des_chave).vlsddisp,'fm99999g999d00')||'</vlsddisp>
                             <vlstotal>'||to_char(vr_tab_crat071(vr_des_chave).vlstotal,'fm9999g999d00')||'</vlstotal>
                           </poupanca>');
             END IF;
             -- Buscar o próximo registro da tabela
             vr_des_chave := vr_tab_crat071.NEXT(vr_des_chave);
           END LOOP; --crat071

           -- Verifica se nao houve registro de poupanca.
           if vr_flgimppou = 'N' then
             -- Cria tag em branco para que não gere erro na chamada do subreport
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<poupanca></poupanca>');
           end if;

           -- Finalizar todos os agrupadores
           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</poupancas></agencia></crrl007>',true);

           -- Imprimir arquivo somente se contiver informacoes
           IF vr_flgimpchq = 'S' OR vr_flgimpdiv = 'S' OR vr_flgimppou = 'S' THEN

             -- Efetuar solicitação de geração de relatório --
             gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                      ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                      ,pr_dtmvtolt  => vr_dtmvtolt         --> Data do movimento atual
                                      ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                      ,pr_dsxmlnode => '/crrl007' --> Nó base do XML para leitura dos dados
                                      ,pr_dsjasper  => 'crrl007.jasper'    --> Arquivo de layout do iReport
                                      ,pr_dsparams  =>   'PR_CDAGENCI##'||vr_cdagenci||'@@PR_NMRESAGE##'||vr_nmresage||'@@PR_VLREFERE##'||To_Char(vr_rel_vlsldneg,'999g990d00')||
                                                       '@@PR_FLIMPCHQ##'||vr_flgimpchq||'@@PR_DSLIMITE##'||trim(vr_rel_dslimite) --> Enviar como parâmetros a agencia e descricao
                                      ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com código da agência
                                      ,pr_qtcoluna  => 234                 --> 132 colunas
                                      ,pr_sqcabrel  => 2                   --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                      ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                      ,pr_nmformul  => '234dh'             --> Nome do formulário para impressão
                                      ,pr_nrcopias  => 1                   --> Número de cópias
                                      ,pr_flg_gerar => 'N'                --> gerar PDF TESTE RANGHETTI PADRAO 'N'
                                      ,pr_des_erro  => vr_des_erro);       --> Saída com erro

              -- Testar se houve erro
              IF vr_des_erro IS NOT NULL THEN
                -- Gerar exceção
                RAISE vr_exc_erro;
              END IF;
            END IF;
            -- Liberando a memória alocada pro CLOB
            dbms_lob.close(vr_des_xml);
            dbms_lob.freetemporary(vr_des_xml);
            vr_dstexto:= NULL;
            -- Buscar o próximo registro da tabela
            vr_index_crapage := vr_tab_crapage.NEXT(vr_index_crapage);
          END LOOP; --vr_tab_crapage


          --Se for uma cooperativa que deve enviar arquivo
          IF vr_dircptxt IS NOT NULL THEN
            BEGIN
              gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
            EXCEPTION
              WHEN OTHERS THEN
                -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
                vr_cdcritic := 1039;  --Erro ao fechar o arquivo
                vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||' <'||vr_nom_direto||'/'||vr_nmarqtxt||'>: ' || sqlerrm;

                --Inclusão na tabela de erros Oracle - Chamado 822997
                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                RAISE vr_exc_erro;
            END;

            --Copiar arquivo para o diretorio encontrado
            vr_comando:= 'cp '||vr_nom_direto||'/'||vr_nmarqtxt||' '||vr_dircptxt;
            --Executar o comando no unix
            GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                 ,pr_des_comando => vr_comando
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_des_erro);
            --Se ocorreu erro dar RAISE
            IF vr_typ_saida = 'ERR' THEN
              vr_cdcritic := 1114;
              vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_comando||' Erro: '||vr_des_erro;
              RAISE vr_exc_erro;
            END IF;

            -- Renato Darosci - 18/11/2013 - Ajustes: Incluir exclusão do arquivo
            -- Excluir o arquivo slddev após a cópia
            vr_comando:= 'rm -f '||vr_nom_direto||'/'||vr_nmarqtxt;
            -- Executar o comando no unix
           GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                 ,pr_des_comando => vr_comando
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_des_erro);
            --Se ocorreu erro dar RAISE
            IF vr_typ_saida = 'ERR' THEN
              vr_cdcritic := 1114;
              vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_comando||' Erro: '||vr_des_erro;
              RAISE vr_exc_erro;
            END IF;
            --
          END IF;

          /* Imprimir relatório */

         -- Nome base do arquivo é crrl007_999
         vr_nom_arquivo := 'crrl007_'||vr_dssuftot;

         -- Inicializar o CLOB
         dbms_lob.createtemporary(vr_des_xml, TRUE);
         dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
         vr_dstexto:= NULL;
         -- Inicilizar as informações do XML
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<?xml version="1.0" encoding="utf-8"?><crrl007_99><agencias totRegist="'||vr_tab_crapage.COUNT()||'">');

         --Posicionar no primeiro registro
         vr_index_crapage:= vr_tab_crapage.FIRST;
         --Processar todas as agencias
         WHILE vr_index_crapage IS NOT NULL LOOP

            --Atribuir valores do vetor para o registro
            vr_cdagenci:= vr_tab_crapage(vr_index_crapage).cdagenci;
            vr_nmresage:= vr_tab_crapage(vr_index_crapage).nmresage;

           /* Verifica se os vetores possuem informacao senao imprime zero */
           --Total disponivel da agencia
           IF vr_tab_tot_agnsddis.EXISTS(vr_cdagenci) THEN
             vr_vlsddisp:= vr_tab_tot_agnsddis(vr_cdagenci);
           ELSE
             vr_vlsddisp:= 0;
           END IF;
           --Total do limite da agencia
           IF vr_tab_tot_agnvllim.EXISTS(vr_cdagenci) THEN
             vr_vltotlim:= vr_tab_tot_agnvllim(vr_cdagenci);
           ELSE
             vr_vltotlim:= 0;
           END IF;
           --Total bloqueado da agencia
           IF vr_tab_tot_agnsdbtl.EXISTS(vr_cdagenci) THEN
             vr_vlsdbltl:= vr_tab_tot_agnsdbtl(vr_cdagenci);
           ELSE
             vr_vlsdbltl:= 0;
           END IF;
           --Saldo total da agencia
           IF vr_tab_tot_qtcstdct.EXISTS(vr_cdagenci) THEN
             vr_qtcmptot:= vr_tab_tot_qtcstdct(vr_cdagenci);
           ELSE
             vr_qtcmptot:= 0;
           END IF;
           --Valor Total em Custodia
           IF vr_tab_tot_vlcstdct.EXISTS(vr_cdagenci) THEN
             vr_vlcmptot:= vr_tab_tot_vlcstdct(vr_cdagenci);
           ELSE
             vr_vlcmptot:= 0;
           END IF;

           --Se estiver tudo zerado pula o registro
           IF vr_vlsddisp = 0  AND
              vr_vltotlim = 0  AND
              vr_vlsdbltl = 0  AND
              vr_qtcmptot = 0  AND
              vr_vlcmptot = 0  THEN
             --Ignorar registro
             NULL;
           ELSE
             --Acumular totais
             vr_tot_vlsddisp:= vr_tot_vlsddisp + vr_vlsddisp;
             vr_tot_vltotlim:= vr_tot_vltotlim + vr_vltotlim;
             vr_tot_vlsdbltl:= vr_tot_vlsdbltl + vr_vlsdbltl;
             vr_tot_qtcstdct:= vr_tot_qtcstdct + vr_qtcmptot;
             vr_tot_vlcstdct:= vr_tot_vlcstdct + vr_vlcmptot;

             --Escrever as informacoes da conta no XML
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<agencia id="'||vr_cdagenci||'" nmresage="'|| vr_nmresage||'">
                             <vlsddisp>'||to_char(vr_vlsddisp,'fm99g999g990d00mi')||'</vlsddisp>
                             <vllimcre>'||to_char(vr_vltotlim,'fm99g999g990d00')||'</vllimcre>
                             <vlsdbltl>'||to_char(vr_vlsdbltl,'fm99g999g990d00')||'</vlsdbltl>
                             <qtcmptot>'||to_char(vr_qtcmptot,'fm9990')||'</qtcmptot>
                             <vlcmptot>'||to_char(vr_vlcmptot,'fm999g990d00')||'</vlcmptot>
                           </agencia>');
           END IF;
           -- Buscar o próximo registro da tabela
           vr_index_crapage := vr_tab_crapage.NEXT(vr_index_crapage);
         END LOOP; --vr_tab_crapage

         -- Finaliza agrupador de agencia e inicia o de totais e total geral
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</agencias><totais><geral>');
         --Totais Gerais
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<g_vlsddisp>'||to_char(vr_tot_vlsddisp,'fm999g999g990d00mi')||'</g_vlsddisp>
                         <g_vllimcre>'||to_char(vr_tot_vltotlim,'fm999g999g999d00')||'</g_vllimcre>
                         <g_vlsdbltl>'||to_char(vr_tot_vlsdbltl,'fm999g999g990d00')||'</g_vlsdbltl>
                         <g_qtcmptot>'||to_char(vr_tot_qtcstdct,'fm999g990')||'</g_qtcmptot>
                         <g_vlcmptot>'||to_char(vr_tot_vlcstdct,'fm99g999g990d00')||'</g_vlcmptot>');
         --Finaliza agrupador de total geral e inicia o agrupador de pessoa fisica
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</geral><pf>');
         --Totais Pessoa Fisica
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<pf_vlsddisp>'||to_char(vr_tab_rel_agnsddis(1),'fm999g999g990d00mi')||'</pf_vlsddisp>
                         <pf_vllimcre>'||to_char(vr_tab_rel_agnvllim(1),'fm999g999g990d00')||'</pf_vllimcre>
                         <pf_vlsdbltl>'||to_char(vr_tab_rel_agnsdbtl(1),'fm999g999g990d00')||'</pf_vlsdbltl>');
         --Finaliza agrupador Totais Pessoa Fisica e Inica Pessoa Juridica
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</pf><pj>');
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<pj_vlsddisp>'||to_char(vr_tab_rel_agnsddis(2),'fm999g999g990d00mi')||'</pj_vlsddisp>
                         <pj_vllimcre>'||to_char(vr_tab_rel_agnvllim(2),'fm999g999g990d00')||'</pj_vllimcre>
                         <pj_vlsdbltl>'||to_char(vr_tab_rel_agnsdbtl(2),'fm999g999g990d00')||'</pj_vlsdbltl>');
         --Finaliza agrupador Totais Pessoa Juridica e Inica Cheque Administrativo
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</pj><cheque_adm>');
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<ca_vlsddisp>'||to_char(vr_tab_rel_agnsddis(3),'fm999g999g990d00mi')||'</ca_vlsddisp>
                         <ca_vllimcre>'||to_char(vr_tab_rel_agnvllim(3),'fm999g999g990d00')||'</ca_vllimcre>
                         <ca_vlsdbltl>'||to_char(vr_tab_rel_agnsdbtl(3),'fm999g999g990d00')||'</ca_vlsdbltl>');
         --Finaliza agrupador Cheque Administrativo e Inicia Liquidacao
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</cheque_adm><cred_liq>');
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<cl_vlsddisp>'||to_char(vr_tab_rel_agnsddis(4),'fm999g999g990d00mi')||'</cl_vlsddisp>
                         <cl_vllimcre>'||to_char(vr_tab_rel_agnvllim(4),'fm999g999g990d00')||'</cl_vllimcre>
                         <cl_vlsdbltl>'||to_char(vr_tab_rel_agnsdbtl(4),'fm999g999g990d00')||'</cl_vlsdbltl>');
         --Finaliza todos os agrupadores
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</cred_liq></totais></crrl007_99>',true);
         
         -- Efetuar solicitação de geração de relatório --
         gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                    ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                    ,pr_dtmvtolt  => vr_dtmvtolt         --> Data do movimento atual
                                    ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                    ,pr_dsxmlnode => '/crrl007_99/agencias/agencia' --> Nó base do XML para leitura dos dados
                                    ,pr_dsjasper  => 'crrl007_total.jasper'    --> Arquivo de layout do iReport
                                    ,pr_dsparams  => NULL                --> Sem parâmetros
                                    ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com código da agência
                                    ,pr_qtcoluna  => 132                 --> 132 colunas
                                    ,pr_sqcabrel  => 2                   --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                    ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                    ,pr_nmformul  => '132dm'             --> Nome do formulário para impressão
                                    ,pr_nrcopias  => 1                   --> Número de cópias
                                    ,pr_flg_gerar => 'N'                 --> gerar PDF
                                    ,pr_des_erro  => vr_des_erro);       --> Saída com erro

         -- Testar se houve erro
         IF vr_des_erro IS NOT NULL THEN
           -- Gerar exceção
           RAISE vr_exc_erro;
         END IF;
         -- Liberando a memória alocada pro CLOB
         dbms_lob.close(vr_des_xml);
         dbms_lob.freetemporary(vr_des_xml);
         vr_dstexto:= NULL;
       EXCEPTION
         WHEN vr_exc_erro THEN
           pr_des_erro:= vr_des_erro;
         WHEN OTHERS THEN
           vr_cdcritic := 1115;  --Erro ao imprimir relatório
           pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'crrl007. '||sqlerrm;

           --Inclusão na tabela de erros Oracle - Chamado 822997
           CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
       END;
       --

       --Gravação dos dados tabela crapbnd
       PROCEDURE pc_grava_crapbnd (pr_cdcooper     IN crapcop.cdcooper%TYPE   --> Código da Cooperativa
                                  ,pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE   --> Data do Movimento Atual
                                  ,pr_dtmvtopr     IN crapdat.dtmvtopr%TYPE   --> Data do Proximo Movimento
                                  ,pr_nrctactl     IN crapcop.nrctactl%TYPE   --> Numero da conta centralizadora
                                  ,pr_tot_vladiant IN NUMBER                  --> Valor adiantamento
                                  ,pr_tot_vlsaqblq IN NUMBER                  --> Valor Saque Bloqueado
                                  ,pr_rel_vltotal4 IN NUMBER                  --> Valor total limite utilizado
                                  ,pr_rel_vlsbtot4 IN NUMBER                  --> Valor total pessoa fisica
                                  ,pr_rel_vlsbtot5 IN NUMBER                  --> Valor total pessoa juridica
                                  ,pr_des_erro OUT VARCHAR2) IS               --> Variavel de Retorno de erro
         --Variavel de Excecao
         vr_exc_erro EXCEPTION;
         --Variavel para mensagem de erro
         vr_des_erro VARCHAR2(4000);

       BEGIN
         -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
         GENE0001.pc_set_modulo(pr_module => 'PC_CRPS005.pc_grava_crapbnd' ,pr_action => NULL);

         --Inicializa variavel de retorno de erro
         pr_des_erro:= NULL;
         --Se nao for cecred e for ultimo dia do mes
         IF pr_cdcooper <> 3 AND To_Char(pr_dtmvtolt,'MM') <> To_Char(pr_dtmvtopr,'MM') THEN
            --Chamado 822997 - inversão ordem comandos INSERT/UPDATE
           --Atualizar informacoes tabela bndes
           BEGIN
                 INSERT INTO crapbnd crapbnd (crapbnd.cdcooper
                                     ,crapbnd.dtmvtolt
                                     ,crapbnd.nrdconta
                                     ,crapbnd.vladtodp
                                     ,crapbnd.vlsaqblq
                                     ,crapbnd.vlchqesp
                                     ,crapbnd.vldepavs)
                 VALUES              (3 /* fixo */
                                     ,pr_dtmvtolt
                                     ,pr_nrctactl
                                     ,Abs(Nvl(pr_tot_vladiant,0))
                                     ,Abs(Nvl(pr_tot_vlsaqblq,0))
                                     ,Abs(Nvl(pr_rel_vltotal4,0))
                                     ,Nvl(pr_rel_vlsbtot4,0) + Nvl(pr_rel_vlsbtot5,0));

               EXCEPTION
              WHEN DUP_VAL_ON_INDEX THEN
                BEGIN
                  UPDATE crapbnd crapbnd 
                  SET    crapbnd.vladtodp = Abs(Nvl(pr_tot_vladiant,0))
                        ,crapbnd.vlsaqblq = Abs(Nvl(pr_tot_vlsaqblq,0))
                        ,crapbnd.vlchqesp = Abs(Nvl(pr_rel_vltotal4,0))
                        ,crapbnd.vldepavs = Nvl(pr_rel_vlsbtot4,0) + Nvl(pr_rel_vlsbtot5,0)
                  WHERE crapbnd.cdcooper = 3 /*fixo*/
                  AND   crapbnd.dtmvtolt = pr_dtmvtolt
                  AND   crapbnd.nrdconta = pr_nrctactl;
                EXCEPTION
                 WHEN OTHERS THEN
                   --Montar mensagem de erro
                    vr_cdcritic := 1035;
                    vr_des_erro:= gene0001.fn_busca_critica(vr_cdcritic)||' crapbnd: '||
                                  'vladtodp:'  ||Abs(Nvl(pr_tot_vladiant,0))||
                                  ', vlsaqblq:'||Abs(Nvl(pr_tot_vlsaqblq,0))||
                                  ', vlchqesp:'||Abs(Nvl(pr_rel_vltotal4,0))||
                                  ', vldepavs:'||Nvl(pr_rel_vlsbtot4,0) + Nvl(pr_rel_vlsbtot5,0)||
                                  ' com cdcooper: 3, dtmvtolt:'||pr_dtmvtolt||
                                  ', nrdconta:'||pr_nrctactl||'. '||sqlerrm;

                     --Inclusão na tabela de erros Oracle - Chamado 822997
                     CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                   --Levantar Excecao
                   RAISE vr_exc_erro;
               END;
             WHEN OTHERS THEN
               --Montar mensagem de erro
                  vr_cdcritic := 1034;
                  vr_des_erro:= gene0001.fn_busca_critica(vr_cdcritic)||' crapbnd: '||
                                'cdcooper: 3, dtmvtolt:'||pr_dtmvtolt||
                                ', nrdconta:'||pr_nrctactl||
                                ', vladtodp:'||Abs(Nvl(pr_tot_vladiant,0))||
                                ', vlsaqblq:'||Abs(Nvl(pr_tot_vlsaqblq,0))||
                                ', vlchqesp:'||Abs(Nvl(pr_rel_vltotal4,0))||
                                ', vldepavs:'||Nvl(pr_rel_vlsbtot4,0) + Nvl(pr_rel_vlsbtot5,0)||
                                '. '||sqlerrm;

                 --Inclusão na tabela de erros Oracle - Chamado 822997
                 CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
               --Levantar Excecao
               RAISE vr_exc_erro;
           END;
         END IF;
       EXCEPTION
         WHEN vr_exc_erro THEN
           pr_des_erro:= vr_des_erro;
         WHEN OTHERS THEN
           vr_cdcritic := 9999;
           pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'pc_crps005.pc_grava_crapbnd. ' ||sqlerrm;

           --Inclusão na tabela de erros Oracle - Chamado 822997
           CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
       END;
       --

       --Geração do relatório de Saldos dos associados (crrl006)
       PROCEDURE pc_imprime_crrl006 (pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE
                                    ,pr_dtmvtopr IN  crapdat.dtmvtopr%TYPE
                                    ,pr_nrctactl IN  crapcop.nrctactl%TYPE
                                    ,pr_des_erro OUT VARCHAR2) IS

         --Variaveis de Apoio para relatorio geral

         vr_rel_vlsaqmax NUMBER:= 0; --valor maximo saque
         vr_rel_vltotlim NUMBER:= 0; --valor limite credito
         vr_rel_vlsddisp NUMBER:= 0; --valor disponivel
         vr_rel_vlsdbltl NUMBER:= 0; --valor bloqueado total
         vr_rel_vlsdchsl NUMBER:= 0; --valor cheque salario
         vr_rel_vlstotal NUMBER:= 0; --valor total
         vr_pac_vlsaqmax NUMBER:= 0; --valor maximo saque
         vr_pac_vlsddisp NUMBER:= 0; --valor disponivel
         vr_pac_vltotlim NUMBER:= 0; --valor limite credito
         vr_pac_vlsdbltl NUMBER:= 0; --valor bloqueado total
         vr_pac_vlsdchsl NUMBER:= 0; --valor cheque salario
         vr_pac_vlstotal NUMBER:= 0; --valor total
         vr_pac_vlblqjud NUMBER:= 0; --valor Bloqueado Judicialmente
         vr_dem_agpsdmax NUMBER:= 0; --valor maximo saque
         vr_dem_agpsddis NUMBER:= 0; --valor disponivel
         vr_dem_agpvllim NUMBER:= 0; --valor limite credito
         vr_dem_agpsdbtl NUMBER:= 0; --valor bloqueado total
         vr_dem_agpsdchs NUMBER:= 0; --valor cheque salario
         vr_dem_agpsdstl NUMBER:= 0; --valor total
         vr_dem_agpvlbjd NUMBER:= 0; --valor bloqueado judicialmente

         --Variaveis dos totalizadores
         vr_tab_pac_vlsaqmax  typ_reg_tot; --saque maximo da agencia
         vr_tab_pac_vllimcre  typ_reg_tot; --valor limite da agencia
         vr_tab_pac_vlsddisp  typ_reg_tot; --saldo disponivel da agencia
         vr_tab_pac_vlsdbltl  typ_reg_tot; --saldo bloqueado total da agencia
         vr_tab_pac_vlsdchsl  typ_reg_tot; --saldo cheque salario da agencia
         vr_tab_pac_vlstotal  typ_reg_tot; --saldo total da agencia
         vr_tab_pac_vlblqjud  typ_reg_tot; --saldo bloqueado Judicialmente agencia

         --Variaveis para Composição de saldos
         vr_rel_vlsbtot1 NUMBER:= 0;
         vr_rel_vlsbtot2 NUMBER:= 0;
         vr_rel_vlsbtot3 NUMBER:= 0;
         vr_rel_vltotal3 NUMBER:= 0;
         vr_rel_vltotal4 NUMBER:= 0;
         vr_rel_vltotal5 NUMBER:= 0;
         vr_rel_vltotal6 NUMBER:= 0;
         vr_rel_vltotal7 NUMBER:= 0;
         vr_rel_vlsbtot4 NUMBER:= 0;
         vr_rel_vlsbtot5 NUMBER:= 0;
         vr_rel_vlsbtot6 NUMBER:= 0;
         vr_rel_vltotal8 NUMBER:= 0;
         vr_rel_vltotal9 NUMBER:= 0;
         vr_rel_vltotal10 NUMBER:= 0; -- P307 Total Conta Investimento
         vr_flgimp59     VARCHAR2(1);
         vr_con_dtmvtolt VARCHAR2(20);
         vr_con_dtmvtopr VARCHAR2(20);
         vr_titcabec     VARCHAR2(100);
         vr_nmarqsai     VARCHAR2(20);

         --Variaveis para totais das linhas nao PNMPO
         vr_rel_vltttlcr NUMBER:= 0;

         --Variaveis para os saldos medios
         vr_rel_dsparfin VARCHAR2(100);
         vr_rel_vlsmpmes NUMBER;
         vr_rel_vlsmnesp NUMBER;
         vr_rel_vlsmnmes NUMBER;
         vr_rel_vlsmnblq NUMBER;
         vr_rel_vltotatr NUMBER;

         --Variaveis de Controle de execucao
         vr_cdagenci     crapage.cdagenci%TYPE;
         vr_flgfirst     BOOLEAN:= TRUE;

         --Variavel de Exceção
         vr_exc_erro EXCEPTION;

         --Variavel de Arquivo Texto
         vr_input_file utl_file.file_type;
         vr_dsaux      VARCHAR2(100);
         vr_nmaux      VARCHAR2(100);
         vr_nom_direto VARCHAR2(100);
         vr_dircon VARCHAR2(100); -- diretório para contabilidade
         vr_arqcon VARCHAR2(100); -- arquivo para contabilidade

         vc_dircon CONSTANT VARCHAR(30) := 'arquivos_contabeis/ayllos'; 
         vc_cdacesso CONSTANT VARCHAR(24) := 'ROOT_SISTEMAS';
         vc_cdtodascooperativas INTEGER := 0;          
         
         vr_dscomando  varchar2(4000);
         vr_typ_saida  varchar2(100);
         vr_nom_direto_cop VARCHAR2(100);
         vr_dstextab   craptab.dstextab%TYPE;
         vr_nmarqtxt   VARCHAR2(100):= 'slddev.txt';

       BEGIN
         -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
         GENE0001.pc_set_modulo(pr_module => 'PC_CRPS005.pc_imprime_crrl006' ,pr_action => NULL);

         --Inicializar variavel de erro
         pr_des_erro:= NULL;

         /* Gerar arquivo txt para Tiago */

         --Busca o caminho padrao do arquivo no unix + /integra
         vr_nom_direto:= GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => 'rl');
         
         --Atribuir zero para variaveis de saldo médio
         vr_rel_vlsmpmes:= 0;
         vr_rel_vlsmnesp:= 0;
         vr_rel_vlsmnmes:= 0;
         vr_rel_vlsmnblq:= 0;

         --Leitura dos saldos medios acumulados no mes
         vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'SALDOMEDIO'
                                               ,pr_tpregist => 0);

         --Se encontrou
         IF vr_dstextab IS NOT NULL THEN
           --Atribuir valores encontrados no select
           vr_rel_vlsmpmes:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,01,16));
           vr_rel_vlsmnesp:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,18,16));
           vr_rel_vlsmnmes:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,35,16));
           vr_rel_vlsmnblq:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,52,16));
         END IF;

         --Se for o ultimo dia do mes
         IF To_Char(pr_dtmvtolt,'MM') <> To_Char(pr_dtmvtopr,'MM') THEN
           --Descrição do parametro financeiro recebe medias finais
           vr_rel_dsparfin:= 'MD. FINAIS';
         ELSE
           --Descrição do parametro financeiro recebe medias parciais
           vr_rel_dsparfin:= 'MD. PARCIAIS';
         END IF;

         --Zerar valor maximo saque
         vr_rel_vlsaqmax:= 0;
         --Zerar valor limite credito
         vr_rel_vltotlim:= 0;
         --Zerar valor disponivel
         vr_rel_vlsddisp:= 0;
         --Zerar valor bloqueado total
         vr_rel_vlsdbltl:= 0;
         --Zerar valor cheque salario
         vr_rel_vlsdchsl:= 0;
         --Zerar valor total
         vr_rel_vlstotal:= 0;

         -- Processar todos os registros dos cheques
         vr_des_chave := vr_tab_crat006.FIRST;
         WHILE vr_des_chave IS NOT NULL LOOP

           --Atribuir codigo da agencia do vetor para variavel
           vr_cdagenci:=  vr_tab_crat006(vr_des_chave).cdagenci;
           -- Se estivermos processando o primeiro registro do vetor ou mudou a agência
           IF vr_des_chave = vr_tab_crat006.FIRST OR vr_tab_crat006(vr_des_chave).cdagenci <> vr_tab_crat006(vr_tab_crat006.PRIOR(vr_des_chave)).cdagenci THEN
             --Marcar flag como primeiro registro
             vr_flgfirst:= TRUE;

             --Selecionar nome resumido da agencia
             IF vr_tab_crapage.EXISTS(vr_cdagenci) THEN
               --Atribuir nome da agencia para variavel
               vr_nmresage:= vr_tab_crapage(vr_cdagenci).nmresage;
             ELSE
               --Atribuir nome da agencia para variavel
               vr_nmresage:= 'PA NAO ENCONTRADO';
             END IF;

             -- Nome base do arquivo é crrl006
             vr_nom_arquivo := 'crrl006_'||to_char(vr_cdagenci,'fm000');

             -- Inicializar o CLOB
             dbms_lob.createtemporary(vr_des_xml, TRUE);
             dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
             vr_dstexto:= NULL;
             -- Inicilizar as informações do XML
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<?xml version="1.0" encoding="utf-8"?><crrl006>');
             -- Adicionar o nó da agência e já iniciar o de depositos
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<agencia cdagenci="'||vr_cdagenci||'" nmresage="'|| vr_nmresage ||'"><contas>');
           END IF;

           --Verificar se o valor do limite de credito é zero
           IF vr_tab_crat006(vr_des_chave).vllimcre = 0 THEN
             --Deixar o limite nulo para não imprimir no xml
             vr_tab_crat006(vr_des_chave).vllimcre:= null;
           END IF;
           --Verificar se o valor do saque máximo é zero
           IF vr_tab_crat006(vr_des_chave).vlsaqmax = 0 THEN
             --Deixar o saque maximo nulo para não imprimir no xml
             vr_tab_crat006(vr_des_chave).vlsaqmax:= null;
           END IF;

           --Desprezar valor do saque maximo se o mesmo for igual a zero ou negativo
           IF Nvl(vr_tab_crat006(vr_des_chave).vlsaqmax,0) <= 0 THEN
             vr_tab_crat006(vr_des_chave).vlsaqmax:= NULL;
           END IF;

           --Escrever no xml as informacoes da conta
           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<conta id="'||vr_des_chave||'">
                           <nrdconta>'||LTrim(gene0002.fn_mask_conta(vr_tab_crat006(vr_des_chave).nrdconta))||'</nrdconta>
                           <cdagenci>'||vr_cdagenci||'</cdagenci>
                           <dsdacstp>'||vr_tab_crat006(vr_des_chave).dsdacstp||'</dsdacstp>
                           <vlsaqmax>'||To_Char(vr_tab_crat006(vr_des_chave).vlsaqmax,'fm99g999g999g990d00')||'</vlsaqmax>
                           <vlsddisp>'||to_char(vr_tab_crat006(vr_des_chave).vlsddisp,'fm99g999g999g990d00')||'</vlsddisp>
                           <vllimcre>'||to_char(vr_tab_crat006(vr_des_chave).vllimcre,'fm999g999g999')||'</vllimcre>
                           <nmprimtl>'||substr(vr_tab_crat006(vr_des_chave).nmprimtl,1,20)||'</nmprimtl>
                           <vlsdbltl>'||to_char(vr_tab_crat006(vr_des_chave).vlsdbltl,'fm999g999g990d00')||'</vlsdbltl>
                           <vlsdchsl>'||to_char(vr_tab_crat006(vr_des_chave).vlsdchsl,'fm999g999g990d00')||'</vlsdchsl>
                           <vlstotal>'||to_char(vr_tab_crat006(vr_des_chave).vlstotal,'fm99g999g999g990d00')||'</vlstotal>
                           <vlblqjud>'||to_char(nvl(vr_tab_crat006(vr_des_chave).vlblqjud, 0),'fm999g999g990d00')||'</vlblqjud>
                         </conta>');
           --Se for o primeiro registro da agencia
           IF vr_flgfirst THEN
             --Marcar flag como primeiro registro já processado
             vr_flgfirst:= FALSE;
             --Inicializar vetor de totais por agencia
             vr_tab_pac_vlsaqmax(vr_cdagenci):= Nvl(vr_tab_crat006(vr_des_chave).vlsaqmax,0);
             vr_tab_pac_vllimcre(vr_cdagenci):= Nvl(vr_tab_crat006(vr_des_chave).vllimcre,0);
             vr_tab_pac_vlsddisp(vr_cdagenci):= Nvl(vr_tab_crat006(vr_des_chave).vlsddisp,0);
             vr_tab_pac_vlsdbltl(vr_cdagenci):= Nvl(vr_tab_crat006(vr_des_chave).vlsdbltl,0);
             vr_tab_pac_vlsdchsl(vr_cdagenci):= Nvl(vr_tab_crat006(vr_des_chave).vlsdchsl,0);
             vr_tab_pac_vlstotal(vr_cdagenci):= Nvl(vr_tab_crat006(vr_des_chave).vlstotal,0);
             vr_tab_pac_vlblqjud(vr_cdagenci):= Nvl(vr_tab_crat006(vr_des_chave).vlblqjud,0);
           ELSE
             --Acumular no vetor para totalizar por agencia
             vr_tab_pac_vlsaqmax(vr_cdagenci):= vr_tab_pac_vlsaqmax(vr_cdagenci) + Nvl(vr_tab_crat006(vr_des_chave).vlsaqmax,0);
             vr_tab_pac_vllimcre(vr_cdagenci):= vr_tab_pac_vllimcre(vr_cdagenci) + Nvl(vr_tab_crat006(vr_des_chave).vllimcre,0);
             vr_tab_pac_vlsddisp(vr_cdagenci):= vr_tab_pac_vlsddisp(vr_cdagenci) + Nvl(vr_tab_crat006(vr_des_chave).vlsddisp,0);
             vr_tab_pac_vlsdbltl(vr_cdagenci):= vr_tab_pac_vlsdbltl(vr_cdagenci) + Nvl(vr_tab_crat006(vr_des_chave).vlsdbltl,0);
             vr_tab_pac_vlsdchsl(vr_cdagenci):= vr_tab_pac_vlsdchsl(vr_cdagenci) + Nvl(vr_tab_crat006(vr_des_chave).vlsdchsl,0);
             vr_tab_pac_vlstotal(vr_cdagenci):= vr_tab_pac_vlstotal(vr_cdagenci) + Nvl(vr_tab_crat006(vr_des_chave).vlstotal,0);
             vr_tab_pac_vlblqjud(vr_cdagenci):= vr_tab_pac_vlblqjud(vr_cdagenci) + Nvl(vr_tab_crat006(vr_des_chave).vlblqjud,0);
           END IF;

           -- Se este for o ultimo registro do vetor, ou da agência
           IF vr_des_chave = vr_tab_crat006.LAST OR vr_tab_crat006(vr_des_chave).cdagenci <> vr_tab_crat006(vr_tab_crat006.NEXT(vr_des_chave)).cdagenci THEN

             -- Finalizar o agrupador de depositos e de Agencia e inicia totalizador do PAC
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</contas><tot_geral>');
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<total id="1">
                             <pac_vlsaqmax>'||to_char(vr_tab_pac_vlsaqmax(vr_cdagenci),'fm99g999g999g990d00')||'</pac_vlsaqmax>
                             <pac_vltotlim>'||to_char(vr_tab_pac_vllimcre(vr_cdagenci),'fm9999g999g990')||'</pac_vltotlim>
                             <pac_vlsddisp>'||to_char(vr_tab_pac_vlsddisp(vr_cdagenci),'fm99g999g999g990d00')||'</pac_vlsddisp>
                             <pac_vlsdbltl>'||to_char(vr_tab_pac_vlsdbltl(vr_cdagenci),'fm999g999g990d00')||'</pac_vlsdbltl>
                             <pac_vlsdchsl>'||to_char(vr_tab_pac_vlsdchsl(vr_cdagenci),'fm9999g999g990d00')||'</pac_vlsdchsl>
                             <pac_vlstotal>'||to_char(vr_tab_pac_vlstotal(vr_cdagenci),'fm99g999g999g990d00')||'</pac_vlstotal>
                             <pac_vlblqjud>'||to_char(vr_tab_pac_vlblqjud(vr_cdagenci),'fm99999g999g990d00')||'</pac_vlblqjud>
                           </total></tot_geral><tot_demit>');

             --Verificar se existe valor no vetor senao atribui zero
             IF NOT vr_tab_dem_agpsdmax.EXISTS(vr_cdagenci) THEN
               vr_tab_dem_agpsdmax(vr_cdagenci):= 0;
             END IF;
             IF NOT vr_tab_dem_agpvllim.EXISTS(vr_cdagenci) THEN
               vr_tab_dem_agpvllim(vr_cdagenci):= 0;
             END IF;
             IF NOT vr_tab_dem_agpsddis.EXISTS(vr_cdagenci) THEN
               vr_tab_dem_agpsddis(vr_cdagenci):= 0;
             END IF;
             IF NOT vr_tab_dem_agpsdbtl.EXISTS(vr_cdagenci) THEN
               vr_tab_dem_agpsdbtl(vr_cdagenci):= 0;
             END IF;
             IF NOT vr_tab_dem_agpsdchs.EXISTS(vr_cdagenci) THEN
               vr_tab_dem_agpsdchs(vr_cdagenci):= 0;
             END IF;
             IF NOT vr_tab_dem_agpsdstl.EXISTS(vr_cdagenci) THEN
               vr_tab_dem_agpsdstl(vr_cdagenci):= 0;
             END IF;
             IF NOT vr_tab_dem_agpvlbjd.EXISTS(vr_cdagenci) THEN
               vr_tab_dem_agpvlbjd(vr_cdagenci):= 0;
             END IF;

             --Escrever total demitidos no XML
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<demit id="2">
                             <dem_agpsdmax>'||to_char(vr_tab_dem_agpsdmax(vr_cdagenci),'fm99g999g999g990d00')||'</dem_agpsdmax>
                             <dem_agpvllim>'||to_char(vr_tab_dem_agpvllim(vr_cdagenci),'fm9999g999g990')||'</dem_agpvllim>
                             <dem_agpsddis>'||to_char(vr_tab_dem_agpsddis(vr_cdagenci),'fm99g999g999g990d00')||'</dem_agpsddis>
                             <dem_agpsdbtl>'||to_char(vr_tab_dem_agpsdbtl(vr_cdagenci),'fm999g999g990d00')||'</dem_agpsdbtl>
                             <dem_agpsdchs>'||to_char(vr_tab_dem_agpsdchs(vr_cdagenci),'fm9999g999g990d00')||'</dem_agpsdchs>
                             <dem_agpsdstl>'||to_char(vr_tab_dem_agpsdstl(vr_cdagenci),'fm99g999g999g990d00')||'</dem_agpsdstl>
                             <dem_agpvlbjd>'||to_char(vr_tab_dem_agpvlbjd(vr_cdagenci),'fm99999g999g990d00')||'</dem_agpvlbjd>
                           </demit></tot_demit></agencia></crrl006>',true);

             -- Efetuar solicitação de geração de relatório --
             gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                        ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                        ,pr_dtmvtolt  => vr_dtmvtolt         --> Data do movimento atual
                                        ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                        ,pr_dsxmlnode => '/crrl006/agencia/contas/conta' --> Nó base do XML para leitura dos dados
                                        ,pr_dsjasper  => 'crrl006.jasper'    --> Arquivo de layout do iReport
                                        ,pr_dsparams  => NULL                --> Sem parametros
                                        ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com código da agência
                                        ,pr_qtcoluna  => 132                 --> 132 colunas
                                        ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                        ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                        ,pr_nmformul  => NULL                --> Nome do formulário para impressão
                                        ,pr_nrcopias  => 1                   --> Número de cópias
                                        ,pr_flg_gerar => 'N'                 --> gerar PDF
                                        ,pr_des_erro  => vr_des_erro);       --> Saída com erro

             -- Testar se houve erro
             IF vr_des_erro IS NOT NULL THEN
               -- Gerar exceção
               RAISE vr_exc_erro;
             END IF;

             -- Liberando a memória alocada pro CLOB
             dbms_lob.close(vr_des_xml);
             dbms_lob.freetemporary(vr_des_xml);
             vr_dstexto:= NULL;
           END IF; --LAST
           -- Buscar o próximo registro da tabela
           vr_des_chave := vr_tab_crat006.NEXT(vr_des_chave);
         END LOOP;

         /*   Relatorio Final  (crrl006_999.lst) */

         -- Nome base do arquivo é crrl006_999
         vr_nom_arquivo := 'crrl006_'||vr_dssuftot;

         -- Inicializar o CLOB
         dbms_lob.createtemporary(vr_des_xml, TRUE);
         dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
         vr_dstexto:= NULL;
         -- Inicilizar as informações do XML
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<?xml version="1.0" encoding="utf-8"?><crrl006_99><agencias>');

         --Posicionar no primeiro registro
         vr_index_crapage:= vr_tab_crapage.FIRST;
         --Processar todas as agencias
         WHILE vr_index_crapage IS NOT NULL LOOP

           --Atribuir codigo da agencia para a variavel
           vr_cdagenci:= vr_tab_crapage(vr_index_crapage).cdagenci;
           --Atribuir nome da agencia para variavel
           vr_nmresage:= vr_tab_crapage(vr_index_crapage).nmresage;

           --Zerar variaveis de auxilio
           vr_pac_vlsaqmax:= 0;
           vr_pac_vlsddisp:= 0;
           vr_pac_vltotlim:= 0;
           vr_pac_vlsdbltl:= 0;
           vr_pac_vlsdchsl:= 0;
           vr_pac_vlstotal:= 0;
           vr_pac_vlblqjud:= 0;
           vr_dem_agpsdmax:= 0;
           vr_dem_agpsddis:= 0;
           vr_dem_agpvllim:= 0;
           vr_dem_agpsdbtl:= 0;
           vr_dem_agpsdchs:= 0;
           vr_dem_agpsdstl:= 0;
           vr_dem_agpvlbjd:= 0;

           /* Verifica se os vetores possuem informacao senao imprime zero */
           --Saque Maximo da agencia
           IF vr_tab_pac_vlsaqmax.EXISTS(vr_cdagenci) THEN
             vr_pac_vlsaqmax:= vr_tab_pac_vlsaqmax(vr_cdagenci);
           END IF;
           --Total disponivel da agencia
           IF vr_tab_pac_vlsddisp.EXISTS(vr_cdagenci) THEN
             vr_pac_vlsddisp:= vr_tab_pac_vlsddisp(vr_cdagenci);
           END IF;
           --Total do limite da agencia
           IF vr_tab_pac_vllimcre.EXISTS(vr_cdagenci) THEN
             vr_pac_vltotlim:= vr_tab_pac_vllimcre(vr_cdagenci);
           END IF;
           --Total bloqueado da agencia
           IF vr_tab_pac_vlsdbltl.EXISTS(vr_cdagenci) THEN
             vr_pac_vlsdbltl:= vr_tab_pac_vlsdbltl(vr_cdagenci);
           END IF;
           --Saldo total cheque salario
           IF vr_tab_pac_vlsdchsl.EXISTS(vr_cdagenci) THEN
             vr_pac_vlsdchsl:= vr_tab_pac_vlsdchsl(vr_cdagenci);
           END IF;
           --Valor Saldo Total
           IF vr_tab_pac_vlstotal.EXISTS(vr_cdagenci) THEN
             vr_pac_vlstotal:= vr_tab_pac_vlstotal(vr_cdagenci);
           END IF;
           --Valor Bloqueado Judicialmente
           IF vr_tab_pac_vlblqjud.EXISTS(vr_cdagenci) THEN
             vr_pac_vlblqjud:= vr_tab_pac_vlblqjud(vr_cdagenci);
           END IF;
           --Saque Maximo da agencia
           IF vr_tab_dem_agpsdmax.EXISTS(vr_cdagenci) THEN
             vr_dem_agpsdmax:= vr_tab_dem_agpsdmax(vr_cdagenci);
           END IF;
           --Total disponivel da agencia
           IF vr_tab_dem_agpsddis.EXISTS(vr_cdagenci) THEN
             vr_dem_agpsddis:= vr_tab_dem_agpsddis(vr_cdagenci);
           END IF;
           --Total do limite da agencia
           IF vr_tab_dem_agpvllim.EXISTS(vr_cdagenci) THEN
             vr_dem_agpvllim:= vr_tab_dem_agpvllim(vr_cdagenci);
           END IF;
           --Total bloqueado da agencia
           IF vr_tab_dem_agpsdbtl.EXISTS(vr_cdagenci) THEN
             vr_dem_agpsdbtl:= vr_tab_dem_agpsdbtl(vr_cdagenci);
           END IF;
           --Saldo total cheque salario
           IF vr_tab_dem_agpsdchs.EXISTS(vr_cdagenci) THEN
             vr_dem_agpsdchs:= vr_tab_dem_agpsdchs(vr_cdagenci);
           END IF;
           --Valor Saldo Total
           IF vr_tab_dem_agpsdstl.EXISTS(vr_cdagenci) THEN
             vr_dem_agpsdstl:= vr_tab_dem_agpsdstl(vr_cdagenci);
           END IF;
           --Valor Total Bloqueio Judicial
           IF vr_tab_dem_agpvlbjd.EXISTS(vr_cdagenci) THEN
             vr_dem_agpvlbjd:= vr_tab_dem_agpvlbjd(vr_cdagenci);
           END IF;

           --Se estiver tudo zerado pula o registro
           IF vr_pac_vlsaqmax = 0 AND
              vr_pac_vlsddisp = 0 AND
              vr_pac_vltotlim = 0 AND
              vr_pac_vlsdbltl = 0 AND
              vr_pac_vlsdchsl = 0 AND
              vr_pac_vlstotal = 0 AND
              vr_pac_vlblqjud = 0 AND
              vr_dem_agpsdmax = 0 AND
              vr_dem_agpsddis = 0 AND
              vr_dem_agpvllim = 0 AND
              vr_dem_agpsdbtl = 0 AND
              vr_dem_agpsdchs = 0 AND
              vr_dem_agpsdstl = 0 AND
              vr_dem_agpvlbjd = 0 THEN

             --Ignorar registro
             NULL;
           ELSE
             --Acumular totais do pac + demitidos
             vr_rel_vlsaqmax:= vr_rel_vlsaqmax + vr_pac_vlsaqmax + vr_dem_agpsdmax;
             vr_rel_vltotlim:= vr_rel_vltotlim + vr_pac_vltotlim + vr_dem_agpvllim;
             vr_rel_vlsddisp:= vr_rel_vlsddisp + vr_pac_vlsddisp + vr_dem_agpsddis;
             vr_rel_vlsdbltl:= vr_rel_vlsdbltl + vr_pac_vlsdbltl + vr_dem_agpsdbtl;
             vr_rel_vlsdchsl:= vr_rel_vlsdchsl + vr_pac_vlsdchsl + vr_dem_agpsdchs;
             vr_rel_vlstotal:= vr_rel_vlstotal + vr_pac_vlstotal + vr_dem_agpsdstl;
             vr_rel_vlblqjud:= vr_rel_vlblqjud + vr_pac_vlblqjud + vr_dem_agpvlbjd;

             --Escrever as informacoes da conta no XML
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<agencia id="'||vr_cdagenci||'" nmresage="'|| vr_nmresage||'">
                             <pac_vlsaqmax>'||to_char(vr_pac_vlsaqmax + vr_dem_agpsdmax,'fm99g999g999g990d00')||'</pac_vlsaqmax>
                             <pac_vlsddisp>'||to_char(vr_pac_vlsddisp + vr_dem_agpsddis,'fm99g999g999g990d00')||'</pac_vlsddisp>
                             <pac_vltotlim>'||to_char(vr_pac_vltotlim + vr_dem_agpvllim,'fm999999g999')||'</pac_vltotlim>
                             <pac_vlsdbltl>'||to_char(vr_pac_vlsdbltl + vr_dem_agpsdbtl,'fm9999g999g990d00')||'</pac_vlsdbltl>
                             <pac_vlsdchsl>'||to_char(vr_pac_vlsdchsl + vr_dem_agpsdchs,'fm9999g999g990d00')||'</pac_vlsdchsl>
                             <pac_vlstotal>'||to_char(vr_pac_vlstotal + vr_dem_agpsdstl,'fm99g999g999g990d00')||'</pac_vlstotal>
                             <pac_vlblqjud>'||to_char(vr_pac_vlblqjud + vr_dem_agpvlbjd,'fm9999g999g990d00')||'</pac_vlblqjud>
                           </agencia>');
           END IF;
           -- Buscar o próximo registro da tabela
           vr_index_crapage := vr_tab_crapage.NEXT(vr_index_crapage);
         END LOOP; --vr_tab_crapage

         -- Finaliza agrupador de agencia e inicia o de totais e total geral
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</agencias><totais><geral>');
         --Totais Gerais
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<g_vlsaqmax>'||to_char(vr_rel_vlsaqmax,'fm99g999g999g990d00')||'</g_vlsaqmax>
                         <g_vlsddisp>'||to_char(vr_rel_vlsddisp,'fm99g999g999g990d00')||'</g_vlsddisp>
                         <g_vltotlim>'||to_char(vr_rel_vltotlim,'fm999999g999')||'</g_vltotlim>
                         <g_vlsdbltl>'||to_char(vr_rel_vlsdbltl,'fm9999g999g990d00')||'</g_vlsdbltl>
                         <g_vlsdchsl>'||to_char(vr_rel_vlsdchsl,'fm9999g999g990d00')||'</g_vlsdchsl>
                         <g_vlstotal>'||to_char(vr_rel_vlstotal,'fm99g999g999g990d00')||'</g_vlstotal>
                         <g_vlblqjud>'||to_char(vr_rel_vlblqjud,'fm9999g999g990d00')||'</g_vlblqjud>');
         --Finaliza agrupador de total geral e inicia o agrupador de pessoa fisica
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</geral><pf>');
         --Totais Pessoa Fisica
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<pf_agpsdmax>'||to_char(vr_tab_rel_agpsdmax(1),'fm99g999g999g990d00')||'</pf_agpsdmax>
                         <pf_agpsddis>'||to_char(vr_tab_rel_agpsddis(1),'fm99g999g999g990d00')||'</pf_agpsddis>
                         <pf_agpvllim>'||to_char(vr_tab_rel_agpvllim(1),'fm999999g999')||'</pf_agpvllim>
                         <pf_agpsdbtl>'||to_char(vr_tab_rel_agpsdbtl(1),'fm9999g999g990d00')||'</pf_agpsdbtl>
                         <pf_agpsdchs>'||to_char(vr_tab_rel_agpsdchs(1),'fm9999g999g990d00')||'</pf_agpsdchs>
                         <pf_agpsdstl>'||to_char(vr_tab_rel_agpsdstl(1),'fm99g999g999g990d00')||'</pf_agpsdstl>
                         <pf_agpsdbjd>'||to_char(vr_tab_rel_agpsdbjd(1),'fm9999g999g990d00')||'</pf_agpsdbjd>');
         --Finaliza agrupador Totais Pessoa Fisica e Inica Pessoa Juridica
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</pf><pj>');
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<pj_agpsdmax>'||to_char(vr_tab_rel_agpsdmax(2),'fm99g999g999g990d00')||'</pj_agpsdmax>
                         <pj_agpsddis>'||to_char(vr_tab_rel_agpsddis(2),'fm99g999g999g990d00')||'</pj_agpsddis>
                         <pj_agpvllim>'||to_char(vr_tab_rel_agpvllim(2),'fm999999g999')||'</pj_agpvllim>
                         <pj_agpsdbtl>'||to_char(vr_tab_rel_agpsdbtl(2),'fm9999g999g990d00')||'</pj_agpsdbtl>
                         <pj_agpsdchs>'||to_char(vr_tab_rel_agpsdchs(2),'fm9999g999g990d00')||'</pj_agpsdchs>
                         <pj_agpsdstl>'||to_char(vr_tab_rel_agpsdstl(2),'fm99g999g999g990d00')||'</pj_agpsdstl>
                         <pj_agpsdbjd>'||to_char(vr_tab_rel_agpsdbjd(2),'fm9999g999g990d00')||'</pj_agpsdbjd>');
         --Finaliza agrupador Totais Pessoa Juridica e Inica Cheque Administrativo
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</pj><cheque_adm>');
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<ca_agpsdmax>'||to_char(vr_tab_rel_agpsdmax(3),'fm99g999g999g990d00')||'</ca_agpsdmax>
                         <ca_agpsddis>'||to_char(vr_tab_rel_agpsddis(3),'fm99g999g999g990d00')||'</ca_agpsddis>
                         <ca_agpvllim>'||to_char(vr_tab_rel_agpvllim(3),'fm999999g999')||'</ca_agpvllim>
                         <ca_agpsdbtl>'||to_char(vr_tab_rel_agpsdbtl(3),'fm9999g999g990d00')||'</ca_agpsdbtl>
                         <ca_agpsdchs>'||to_char(vr_tab_rel_agpsdchs(3),'fm9999g999g990d00')||'</ca_agpsdchs>
                         <ca_agpsdstl>'||to_char(vr_tab_rel_agpsdstl(3),'fm99g999g999g990d00')||'</ca_agpsdstl>
                         <ca_agpsdbjd>'||to_char(vr_tab_rel_agpsdbjd(3),'fm9999g999g990d00')||'</ca_agpsdbjd>');
         --Finaliza agrupador Cheque Administrativo e Inicia Liquidacao
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</cheque_adm><cred_liq>');
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<cl_agpsdmax>'||to_char(vr_tab_rel_agpsdmax(4),'fm99g999g999g990d00')||'</cl_agpsdmax>
                         <cl_agpsddis>'||to_char(vr_tab_rel_agpsddis(4),'fm99g999g999g990d00')||'</cl_agpsddis>
                         <cl_agpvllim>'||to_char(vr_tab_rel_agpvllim(4),'fm999999g999')||'</cl_agpvllim>
                         <cl_agpsdbtl>'||to_char(vr_tab_rel_agpsdbtl(4),'fm9999g999g990d00')||'</cl_agpsdbtl>
                         <cl_agpsdchs>'||to_char(vr_tab_rel_agpsdchs(4),'fm9999g999g990d00')||'</cl_agpsdchs>
                         <cl_agpsdstl>'||to_char(vr_tab_rel_agpsdstl(4),'fm99g999g999g990d00')||'</cl_agpsdstl>
                         <cl_agpsdbjd>'||to_char(vr_tab_rel_agpsdbjd(4),'fm9999g999g990d00')||'</cl_agpsdbjd>');
         --Finaliza agrupador Liquidacao e Inicia Medias
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</cred_liq><medias>');
         /*  Resumo dos saldos medios acumulados no mes  */
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<med_dsparfin>'||vr_rel_dsparfin||'</med_dsparfin>
                         <med_vlsmpmes>'||to_char(vr_rel_vlsmpmes,'fm999999999g990d00')||'</med_vlsmpmes>
                         <med_vlsmnesp>'||to_char(vr_rel_vlsmnesp,'fm999999999g990d00')||'</med_vlsmnesp>
                         <med_vlsmnmes>'||to_char(vr_rel_vlsmnmes,'fm999999999g990d00')||'</med_vlsmnmes>
                         <med_vlsmnblq>'||to_char(vr_rel_vlsmnblq,'fm999999999g990d00')||'</med_vlsmnblq>');
         --Finaliza agrupador Medias e Inicia Contabilizacao
         /*  Totais para contabilizacao  */

         -- Verifica se está executando ou não em paralelo 
         -- Se for execução em paralelo atualiza a tabela de memória
         -- Projeto ligeirinho
         if pr_idparale = 0 and
            pr_cdagenci = 0 and
            vr_inproces > 2 and
            vr_qtdjobs  > 0 then 
            vr_tot_vlsaqblq:=  vr_tab_contab(1).con_vlsaqblq;
            vr_tot_vladiant:=  vr_tab_contab(1).con_vladiant;
            vr_tot_vlutiliz:=  vr_tab_contab(1).con_vlutiliz;
         end if;
         -- Processar todos os registros dos contabilizado             
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</medias><contabilizacao>');
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<con_vlutiliz>'||to_char(vr_tot_vlutiliz,'fm999999999g990d00')||'</con_vlutiliz>
                         <con_vlsaqblq>'||to_char(vr_tot_vlsaqblq,'fm999999999g990d00')||'</con_vlsaqblq>
                         <con_vladiant>'||to_char(vr_tot_vladiant,'fm999999999g990d00')||'</con_vladiant>');
         --Finaliza agrupador Contabilizacao e inicia Composicao dos saldos
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</contabilizacao><saldos>');

         /*  Informacoes sobre a Composicao dos Saldos  */

         --Saldo Liquido Pessoa Fisica
         vr_rel_vlsbtot1:= vr_tab_rel_vlsldliq(1);
         --Saldo Liquido pessoa juridica
         vr_rel_vlsbtot2:= vr_tab_rel_vlsldliq(2);
         --Saldo Liquido Cheque Administrativo
         vr_rel_vlsbtot3:= vr_tab_rel_vlsldliq(3);
         --Soma do Saldo Liquido PF + PJ + Cheque Adm
         vr_rel_vltotal3:= Nvl(vr_rel_vlsbtot1,0) + Nvl(vr_rel_vlsbtot2,0) + Nvl(vr_rel_vlsbtot3,0);
         --Total Limite utilizado PF + PJ + Cheque Adm
         vr_rel_vltotal4:= (vr_tab_rel_vlsutili(1) * -1) + (vr_tab_rel_vlsutili(2) * -1) + (vr_tab_rel_vlsutili(3) * -1);
         --Total Bloqueado Judicialmente P307 - Não sumarizar no total geral
         vr_rel_vltotal9:= (vr_tab_rel_vlblqjud(1) * -1) + (vr_tab_rel_vlblqjud(2) * -1) + (vr_tab_rel_vlblqjud(3) * -1);
         --Total Saque Bloqueado PF + PJ + Cheque Adm.
         vr_rel_vltotal5:= (vr_tab_rel_vlsaqblq(1) * -1) + (vr_tab_rel_vlsaqblq(2) * -1) + (vr_tab_rel_vlsaqblq(3) * -1);
         --Total Adiantamento a Depositantes PF + PJ + Cheque Adm.
         vr_rel_vltotal6:= (vr_tab_rel_vlsadian(1) * -1) + (vr_tab_rel_vlsadian(2) * -1) + (vr_tab_rel_vlsadian(3) * -1);
         --Total Credito Liquidacao PF + PJ + Cheque Adm.
         vr_rel_vltotal7:= (vr_tab_rel_vladiclq(1) * -1) + (vr_tab_rel_vladiclq(2) * -1) + (vr_tab_rel_vladiclq(3) * -1);
         --P307 - Total Conta Investimento PF + PJ + Cheque Adm.
         vr_rel_vltotal10:= vr_tab_rel_vlcntinv(1) + vr_tab_rel_vlcntinv(2) + vr_tab_rel_vlcntinv(3);

         --Total Pessoa Fisica (Limite Utilizado + Saque Bloqueado + Adiant. Depositantes + Credito Liquid. + Conta Inves.)
         vr_rel_vlsbtot4:= Nvl(vr_rel_vlsbtot1,0) +
                                 (vr_tab_rel_vlsutili(1) * -1) +
                                 (vr_tab_rel_vlsaqblq(1) * -1) + /* nesta variavel somou o aux_vlbloque */
                                 (vr_tab_rel_vlsadian(1) * -1) + /* nesta variavel somou o aux_vlbloque */
                                 (vr_tab_rel_vladiclq(1) * -1) +
                                 (vr_tab_rel_vlcntinv(1));

         --Total Pessoa Juridica (Limite Utilizado + Saque Bloqueado + Adiant. Depositantes + Credito Liquid. + Conta Inves.)
         vr_rel_vlsbtot5:= Nvl(vr_rel_vlsbtot2,0) +
                                 (vr_tab_rel_vlsutili(2) * -1) +
                                 (vr_tab_rel_vlsaqblq(2) * -1) + /* nesta variavel somou o aux_vlbloque */
                                 (vr_tab_rel_vlsadian(2) * -1) + /* nesta variavel somou o aux_vlbloque */
                                 (vr_tab_rel_vladiclq(2) * -1) +
                                 (vr_tab_rel_vlcntinv(2));

         --Total Cheque Adm. (Limite Utilizado + Saque Bloqueado + Adiant. Depositantes + Credito Liquid. + Conta Inves.)
         vr_rel_vlsbtot6:= Nvl(vr_rel_vlsbtot3,0) +
                                 (vr_tab_rel_vlsutili(3) * -1) +
                                 (vr_tab_rel_vlsaqblq(3) * -1) +
                                 (vr_tab_rel_vlsadian(3) * -1) +
                                 (vr_tab_rel_vladiclq(3) * -1) +
                                 (vr_tab_rel_vlcntinv(3)); 
                                 
                                
         --Total Geral
         vr_rel_vltotal8:= Nvl(vr_rel_vlsbtot4,0) + Nvl(vr_rel_vlsbtot5,0) + Nvl(vr_rel_vlsbtot6,0);
         --Data Movimento para Contabilização
         vr_con_dtmvtolt:= '52'||To_Char(vr_dtmvtolt,'RRMMDD');
         --Data Proximo Movimento para Contabilização
         vr_con_dtmvtopr:= '52'||To_Char(vr_dtmvtopr,'RRMMDD');
         --Nome do arquivo da contabilização
         vr_nmarqsai:= To_Char(vr_dtmvtolt,'RRMMDD') ||'_1.txt';

         --Executar rotina insere dados tabela crapbnd
         pc_grava_crapbnd  (pr_cdcooper     => pr_cdcooper
                           ,pr_dtmvtolt     => pr_dtmvtolt
                           ,pr_dtmvtopr     => pr_dtmvtopr
                           ,pr_nrctactl     => pr_nrctactl
                           ,pr_tot_vladiant => vr_tot_vladiant
                           ,pr_tot_vlsaqblq => vr_tot_vlsaqblq
                           ,pr_rel_vltotal4 => vr_rel_vltotal4
                           ,pr_rel_vlsbtot4 => vr_rel_vlsbtot4
                           ,pr_rel_vlsbtot5 => vr_rel_vlsbtot5
                           ,pr_des_erro     => vr_des_erro);
         --Se ocorreu erro
         IF vr_des_erro IS NOT NULL THEN
           --Levantar Exceção
           RAISE vr_exc_erro;
         END IF;
         -- Incluir nome do módulo logado
         GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS005' ,pr_action => NULL);

         --Se o valor do saldo utilizado existir
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<slpf>'||to_char(vr_rel_vlsbtot1,'fm999g999g999g990d00')||'</slpf>
                         <slpj>'||to_char(vr_rel_vlsbtot2,'fm999g999g999g990d00')||'</slpj>
                         <slca>'||to_char(vr_rel_vlsbtot3,'fm999g999g999g990d00')||'</slca>
                         <sltot>'||to_char(vr_rel_vltotal3,'fm999g999g999g990d00')||'</sltot>
                         <limpf>'||to_char(vr_tab_rel_vlsutili(1)*-1,'fm999g999g999g990d00')||'</limpf>
                         <limpj>'||to_char(vr_tab_rel_vlsutili(2)*-1,'fm999g999g999g990d00')||'</limpj>
                         <limca>'||to_char(vr_tab_rel_vlsutili(3)*-1,'fm999g999g999g990d00')||'</limca>
                         <limtot>'||to_char(vr_rel_vltotal4,'fm999g999g999g990d00')||'</limtot>
                         <bjpf>'||to_char(vr_tab_rel_vlblqjud(1)*-1,'fm999g999g999g990d00')||'</bjpf>
                         <bjpj>'||to_char(vr_tab_rel_vlblqjud(2)*-1,'fm999g999g999g990d00')||'</bjpj>
                         <bjca>'||to_char(vr_tab_rel_vlblqjud(3)*-1,'fm999g999g999g990d00')||'</bjca>
                         <bjtot>'||to_char(vr_rel_vltotal9,'fm999g999g999g990d00')||'</bjtot>
                         <sbpf>'||to_char(vr_tab_rel_vlsaqblq(1)*-1,'fm999g999g999g990d00')||'</sbpf>
                         <sbpj>'||to_char(vr_tab_rel_vlsaqblq(2)*-1,'fm999g999g999g990d00')||'</sbpj>
                         <sbca>'||to_char(vr_tab_rel_vlsaqblq(3)*-1,'fm999g999g999g990d00')||'</sbca>
                         <sbtot>'||to_char(vr_rel_vltotal5,'fm999g999g999g990d00')||'</sbtot>
                         <adpf>'||to_char(vr_tab_rel_vlsadian(1)*-1,'fm999g999g999g990d00')||'</adpf>
                         <adpj>'||to_char(vr_tab_rel_vlsadian(2)*-1,'fm999g999g999g990d00')||'</adpj>
                         <adca>'||to_char(vr_tab_rel_vlsadian(3)*-1,'fm999g999g999g990d00')||'</adca>
                         <adtot>'||to_char(vr_rel_vltotal6,'fm999g999g999g990d00')||'</adtot>
                         <clpf>'||to_char(vr_tab_rel_vladiclq(1)*-1,'fm999g999g999g990d00')||'</clpf>
                         <clpj>'||to_char(vr_tab_rel_vladiclq(2)*-1,'fm999g999g999g990d00')||'</clpj>
                         <clca>'||to_char(vr_tab_rel_vladiclq(3)*-1,'fm999g999g999g990d00')||'</clca>
                         <cltot>'||to_char(vr_rel_vltotal7,'fm999g999g999g990d00')||'</cltot>
                         <ttpf>'||to_char(vr_rel_vlsbtot4,'fm999g999g999g990d00')||'</ttpf>
                         <ttpj>'||to_char(vr_rel_vlsbtot5,'fm999g999g999g990d00')||'</ttpj>
                         <ttca>'||to_char(vr_rel_vlsbtot6,'fm999g999g999g990d00')||'</ttca>
                         <ctivf>'||TO_CHAR(vr_tab_rel_vlcntinv(1),'fm999g999g999g990d00')||'</ctivf>
                         <ctivj>'||TO_CHAR(vr_tab_rel_vlcntinv(2),'fm999g999g999g990d00')||'</ctivj>
                         <ctiva>'||TO_CHAR(vr_tab_rel_vlcntinv(3),'fm999g999g999g990d00')||'</ctiva>                         
                         <ctivt>'||TO_CHAR(vr_rel_vltotal10,'fm999g999g999g990d00')||'</ctivt>
                         <tttot>'||TO_CHAR(vr_rel_vltotal8,'fm999g999g999g990d00')||'</tttot>');
         --Finaliza agrupador de saldos e inicia microcreditos
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</saldos><microcreditos>');

         -- Alimentar o vetor de totais final baseado no inicial ignorando os tipos PROPRIO
         vr_des_chave := vr_tab_totais.FIRST;
         WHILE vr_des_chave IS NOT NULL LOOP
           --Se o tipo do total for diferente PROPRIO entao grava
           IF Trim(vr_tab_totais(vr_des_chave).tipo) <> 'PROPRIO' THEN
             --Inserir a linha no novo vetor
             vr_tab_totais_final(vr_des_chave):= vr_tab_totais(vr_des_chave);
           END IF;
           -- Buscar o próximo registro da tabela
           vr_des_chave := vr_tab_totais.NEXT(vr_des_chave);
         END LOOP;

         -- Processar todos os registros de totais diferente de PROPRIO
         vr_des_chave := vr_tab_totais_final.FIRST;
         WHILE vr_des_chave IS NOT NULL LOOP

           -- Se estivermos processando o primeiro registro do vetor ou mudou a agência
           IF vr_des_chave = vr_tab_totais_final.FIRST OR vr_tab_totais_final(vr_des_chave).tipo <> vr_tab_totais_final(vr_tab_totais_final.PRIOR(vr_des_chave)).tipo THEN
             --Montar arquivo XML
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<micro tipo="'||vr_tab_totais_final(vr_des_chave).tipo||'">');
           END IF;
           --Total Linha Credito recebe total pessoa fisica + total pessoa juridica
           vr_rel_vltttlcr:= Nvl(vr_tab_totais_final(vr_des_chave).vltttfis,0) + Nvl(vr_tab_totais_final(vr_des_chave).vltttjur,0);


           --Montar arquivo XML
           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<micro_id id="'||vr_tab_totais_final(vr_des_chave).cdlcremp||'">
                           <linha>'||vr_tab_totais_final(vr_des_chave).cdlcremp||'</linha>
                           <vltttfis>'||to_char(vr_tab_totais_final(vr_des_chave).vltttfis,'fm999g999g999g990d00')||'</vltttfis>
                           <vltttjur>'||to_char(vr_tab_totais_final(vr_des_chave).vltttjur,'fm999g999g999g990d00')||'</vltttjur>
                           <vltttlcr>'||to_char(vr_rel_vltttlcr,'fm999g999g999g990d00')||'</vltttlcr></micro_id>');

           -- Se este for o ultimo registro do vetor, ou da agência
           IF vr_des_chave = vr_tab_totais_final.LAST OR vr_tab_totais_final(vr_des_chave).tipo <> vr_tab_totais_final(vr_tab_totais_final.NEXT(vr_des_chave)).tipo THEN
             --Montar arquivo XML com os totais
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</micro>');
             
           END IF;
           
           -- Buscar o próximo registro da tabela
           vr_des_chave := vr_tab_totais_final.NEXT(vr_des_chave);
         END LOOP;
         --Finaliza agrupador de Microcreditos e inicia agrupador de emprestimos
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</microcreditos><emprestimos>');

         --se data for menor que 01/07/2013 lista form antigo
         IF vr_dtmvtolt < To_Date('01/07/2013','DD/MM/YYYY') THEN

           --Atribuir 'N' para imprime 59
           vr_flgimp59:= 'N';

           --Atribuir valor para o titulo
           vr_titcabec:= 'EMPRESTIMOS ATRASADOS A MAIS DE UM ANO';

           /* Mostrar contas atrasadas a mais de um ano*/
           -- Processar todos os registros de atrasados
           vr_des_chave := vr_tab_atrasados.FIRST;
           WHILE vr_des_chave IS NOT NULL LOOP
             -- Se estivermos processando o primeiro registro do vetor ou mudou a agência
             IF vr_des_chave = vr_tab_atrasados.FIRST OR vr_tab_atrasados(vr_des_chave).cdlcremp <> vr_tab_atrasados(vr_tab_atrasados.PRIOR(vr_des_chave)).cdlcremp THEN
               --Montar arquivo XML
               gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<linha id="'||vr_tab_atrasados(vr_des_chave).cdlcremp||'">');
             END IF;

             --Montar arquivo XML
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<conta id="'||vr_tab_atrasados(vr_des_chave).nrdconta||'">
                           <cdagenci>'||vr_tab_atrasados(vr_des_chave).cdagenci||'</cdagenci>
                           <nrdconta>'||LTrim(gene0002.fn_mask_conta(vr_tab_atrasados(vr_des_chave).nrdconta))||'</nrdconta>
                           <nrctremp>'||To_Char(vr_tab_atrasados(vr_des_chave).nrctremp,'fm999g999g999')||'</nrctremp>
                           <cdlcremp>'||vr_tab_atrasados(vr_des_chave).cdlcremp||'</cdlcremp>
                           <vlsdeved>'||to_char(vr_tab_atrasados(vr_des_chave).vlsdeved,'fm999g999g999g990d00')||'</vlsdeved>
                           <dtultpag>'||to_char(vr_tab_atrasados(vr_des_chave).dtultpag,'DD/MM/YYYY')||'</dtultpag>
                           </conta>');

             -- Se este for o ultimo registro do vetor, ou da agência
             IF vr_des_chave = vr_tab_atrasados.LAST OR vr_tab_atrasados(vr_des_chave).cdlcremp <> vr_tab_atrasados(vr_tab_atrasados.NEXT(vr_des_chave)).cdlcremp THEN
               --Montar arquivo XML com os totais
               gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</linha>');
             END IF;
             -- Buscar o próximo registro da tabela
             vr_des_chave := vr_tab_atrasados.NEXT(vr_des_chave);
           END LOOP;
         ELSE
           --Atribuir 'S' para imprime 59
           vr_flgimp59:= 'S';

           --Atribuir valor para o titulo
           vr_titcabec:= 'EMPRESTIMOS ATRASADOS MAIOR QUE 90 DIAS'; -- PRJ Microcredito

           --Busca o caminho padrao do arquivo no unix /micros/financeiro/
           vr_nom_direto_cop:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'DIR_COPIA_CRRL006');

           --Se nao encontrou
           IF vr_nom_direto_cop IS NULL THEN
             vr_cdcritic := 1116;  --Erro ao buscar diretorio do arquivo
             vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||' '||sqlerrm;
             --Levantar Excecao
             RAISE vr_exc_erro;
           END IF;
           
           /* Mostrar contas atrasadas ate 59 dias */
           -- Processar todos os registros de atrasados
           vr_des_chave := vr_tab_atrasados.FIRST;
           WHILE vr_des_chave IS NOT NULL LOOP
             -- Se estivermos processando o primeiro registro do vetor ou mudou a agência
             IF vr_des_chave = vr_tab_atrasados.FIRST OR vr_tab_atrasados(vr_des_chave).cdlcremp <> vr_tab_atrasados(vr_tab_atrasados.PRIOR(vr_des_chave)).cdlcremp THEN
               --Montar arquivo XML
               gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<linha id="'||vr_tab_atrasados(vr_des_chave).cdlcremp||'">');
               vr_rel_vltotatr:= 0;
             END IF;
             --Acumular total por linha de credito
             vr_rel_vltotatr:= vr_rel_vltotatr + vr_tab_atrasados(vr_des_chave).vlsdeved;

             -- Se este for o ultimo registro do vetor, ou da agência
             IF vr_des_chave = vr_tab_atrasados.LAST OR vr_tab_atrasados(vr_des_chave).cdlcremp <> vr_tab_atrasados(vr_tab_atrasados.NEXT(vr_des_chave)).cdlcremp THEN
               --Montar arquivo XML
               gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<conta>
                             <cdlcremp>'||vr_tab_atrasados(vr_des_chave).cdlcremp||'</cdlcremp>
                             <vlsdeved>'||to_char(vr_rel_vltotatr,'fm999g999g999g990d00')||'</vlsdeved>
                             </conta>');
               --Montar arquivo XML com os totais
               gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</linha>');
             END IF;
             -- Buscar o próximo registro da tabela
             vr_des_chave := vr_tab_atrasados.NEXT(vr_des_chave);
           END LOOP;
         END IF;

         --Finaliza agrupador de emprestimos e inicia lista pnmpo
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</emprestimos><pnmpo>');

         /* Mostrar detalhes das linhas PNMPO */
         -- Processar todos os registros de detalhes pnmpo
         vr_des_chave := vr_tab_detalhes.FIRST;
         WHILE  vr_des_chave IS NOT NULL LOOP -- Sair quando a chave atual for null (chegou no final)
           
           -- Se estivermos processando o primeiro registro do vetor ou mudou a agência
           IF vr_des_chave = vr_tab_detalhes.FIRST OR vr_tab_detalhes(vr_des_chave).cdlcremp <> vr_tab_detalhes(vr_tab_detalhes.PRIOR(vr_des_chave)).cdlcremp THEN
             --Montar arquivo XML
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<linha id="'||vr_tab_detalhes(vr_des_chave).cdlcremp||'">');
           END IF;

           --Montar arquivo XML
           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<contrato id="'||vr_tab_detalhes(vr_des_chave).nrctremp||'">
                           <cdagenci>'||vr_tab_detalhes(vr_des_chave).cdagenci||'</cdagenci>
                           <nrdconta>'||LTrim(gene0002.fn_mask_conta(vr_tab_detalhes(vr_des_chave).nrdconta))||'</nrdconta>
                           <nrctremp>'||To_Char(vr_tab_detalhes(vr_des_chave).nrctremp,'fm999g999g999')||'</nrctremp>
                           <vlsdeved>'||to_char(vr_tab_detalhes(vr_des_chave).vlsdeved,'fm999g999g999g990d00')||'</vlsdeved>
                           <dtmvtolt>'||To_Char(vr_tab_detalhes(vr_des_chave).dtmvtolt,'DD/MM/YYYY')||'</dtmvtolt>
                           <nmprimtl>'||vr_tab_detalhes(vr_des_chave).nmprimtl||'</nmprimtl>
                           <vlemprst>'||to_char(vr_tab_detalhes(vr_des_chave).vlemprst,'fm999g999g999g990d00')||'</vlemprst></contrato>');

           -- Se este for o ultimo registro do vetor, ou da agência
           IF vr_des_chave = vr_tab_detalhes.LAST OR vr_tab_detalhes(vr_des_chave).cdlcremp <> vr_tab_detalhes(vr_tab_detalhes.NEXT(vr_des_chave)).cdlcremp THEN
             --Montar arquivo XML com os totais
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</linha>');
           END IF;
           -- Buscar o próximo registro da tabela
           vr_des_chave := vr_tab_detalhes.NEXT(vr_des_chave);
         END LOOP;
         --Finaliza o agrupamento de totais e o do relatorio
         gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</pnmpo></totais></crrl006_99>',true);

         -- Efetuar solicitação de geração de relatório --
         gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                    ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                    ,pr_dtmvtolt  => vr_dtmvtolt         --> Data do movimento atual
                                    ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                    ,pr_dsxmlnode => '/crrl006_99'       --> Nó base do XML para leitura dos dados
                                    ,pr_dsjasper  => 'crrl006_total.jasper' --> Arquivo de layout do iReport
                                    ,pr_dsparams  => 'PR_NMARQSAI##'||vr_nmarqsai||'@@PR_NMTITULO##'||vr_titcabec||'@@PR_FLGIMP59##'||vr_flgimp59  --> Enviar o nome do arquivo da contabilidade
                                    ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com código da agência
                                    ,pr_qtcoluna  => 132                 --> 132 colunas
                                    ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_1.i}
                                    ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                    ,pr_nmformul  => '132dm'             --> Nome do formulário para impressão
                                    ,pr_nrcopias  => 1                   --> Número de cópias
                                    ,pr_flg_gerar => 'N'                 --> gerar PDF
                                    ,pr_des_erro  => vr_des_erro);       --> Saída com erro

         -- Testar se houve erro
         IF vr_des_erro IS NOT NULL THEN
           -- Gerar exceção
           RAISE vr_exc_erro;
         END IF;

         -- Liberando a memória alocada pro CLOB
         dbms_lob.close(vr_des_xml);
         dbms_lob.freetemporary(vr_des_xml);
         vr_dstexto:= NULL;
         /*------------------- DADOS PARA CONTABILIDADE -------------------*/
         --Busca o caminho padrao do arquivo no unix + /integra
         vr_nom_direto:= GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => 'contab');

         --Determinar o nome do arquivo baseado no ano, mes e dia da data movimento
         vr_nmarqtxt:=  to_char(vr_dtmvtolt,'YYMMDD')||'_1.txt';

         -- Tenta abrir o arquivo de log em modo gravacao
         gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_direto  --> Diretório do arquivo
                                 ,pr_nmarquiv => vr_nmarqtxt    --> Nome do arquivo
                                 ,pr_tipabert => 'W'            --> Modo de abertura (R,W,A)
                                 ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                                 ,pr_des_erro => vr_des_erro);  --> Erro
         IF vr_des_erro IS NOT NULL THEN
           --Levantar Excecao
           RAISE vr_exc_erro;
         END IF;

         /*-------------   Saldo Pessoas Juridicas   -----------*/
         --Se o valor total das pessoas juridicas for > 0 e não for cecred
         IF vr_rel_vlsbtot5 > 0 AND pr_cdcooper <> 3 THEN

           --Montar descricao nome
           vr_nmaux:=  '(crps005) - SALDO PESSOAS JURIDICAS';

           --Montar mensagem para gravar no arquivo
           vr_setlinha:= trim(vr_con_dtmvtolt) || ',' ||
                         trim(To_Char(vr_dtmvtolt,'DDMMYY')) ||
                         ',4112,4120,' ||
                         REPLACE(trim(To_Char(vr_rel_vlsbtot5 - vr_tab_rel_vlcntinv(2),'fm999999999999990d00')),',','.')||
                         ',1434,'|| chr(34) || vr_nmaux ||chr(34);
           --Escrever o cabecalho no arquivo
           gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                         ,pr_des_text => vr_setlinha); --> Texto para escrita

           vr_setlinha:=  '999,' || REPLACE(trim(to_char(vr_rel_vlsbtot5 - vr_tab_rel_vlcntinv(2),'fm9999999999990d00')),',','.');
           --Escrever o cabecalho no arquivo
           gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                         ,pr_des_text => vr_setlinha); --> Texto para escrita

           --Escrever o cabecalho no arquivo
           gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                         ,pr_des_text => vr_setlinha); --> Texto para escrita

           --Montar mensagem para gravar no arquivo
           vr_setlinha:= trim(vr_con_dtmvtopr) || ',' ||
                         trim(To_Char(vr_dtmvtopr,'DDMMYY')) ||
                         ',4120,4112,' ||
                         REPLACE(trim(To_Char(vr_rel_vlsbtot5 - vr_tab_rel_vlcntinv(2),'fm999999999999990d00')),',','.')||
                         ',1434,'|| chr(34) || vr_nmaux ||chr(34);
           --Escrever o cabecalho no arquivo
           gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                         ,pr_des_text => vr_setlinha); --> Texto para escrita

           vr_setlinha:=  '999,' || REPLACE(trim(to_char(vr_rel_vlsbtot5 - vr_tab_rel_vlcntinv(2),'fm999999990d00')),',','.');
           --Escrever o cabecalho no arquivo
           gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                         ,pr_des_text => vr_setlinha); --> Texto para escrita
           --Escrever o cabecalho no arquivo
           gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                         ,pr_des_text => vr_setlinha); --> Texto para escrita

         END IF;

         /*-------------   Saldo Cheque Administrativo   -----------*/
         --Se o valor total do cheque adm. for > 0
         IF vr_rel_vlsbtot6 > 0 THEN
           --Se for cecred
           IF pr_cdcooper = 3 THEN
             --Alimentar Desricacao auxiliar
             vr_dsaux:= ',4451,4905,';
           ELSE
           --Alimentar Desricacao auxiliar
             vr_dsaux:= ',4112,4905,';
           END IF;

           --Montar descricao nome
           vr_nmaux:= '(crps005) SALDOS CHEQUES ADMINISTRATIVO';

           --Montar mensagem para gravar no arquivo
           vr_setlinha:= trim(vr_con_dtmvtolt) || ',' ||
                         trim(To_Char(vr_dtmvtolt,'DDMMYY')) ||
                         vr_dsaux ||
                         REPLACE(trim(To_Char(vr_rel_vlsbtot6 ,'fm999999999999990d00')),',','.')||
                         ',1434,'|| chr(34) || vr_nmaux ||chr(34);
           --Escrever o cabecalho no arquivo
           gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                         ,pr_des_text => vr_setlinha); --> Texto para escrita

           --Se nao for cecred
           IF pr_cdcooper <> 3 THEN
             vr_setlinha:=  '999,' || REPLACE(trim(to_char(vr_rel_vlsbtot6 ,'fm999999990d00')),',','.');
             --Escrever o cabecalho no arquivo
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita
           END IF;

           --Se for cecred
           IF pr_cdcooper = 3 THEN
             --Alimentar Desricacao auxiliar
             vr_dsaux:= ',4905,4451,';
           ELSE
           --Alimentar Desricacao auxiliar
             vr_dsaux:= ',4905,4112,';
           END IF;


           --Montar mensagem para gravar no arquivo
           vr_setlinha:= trim(vr_con_dtmvtopr) || ',' ||
                         trim(To_Char(vr_dtmvtopr,'DDMMYY')) ||
                         vr_dsaux ||
                         REPLACE(trim(To_Char(vr_rel_vlsbtot6 ,'fm999999999999990d00')),',','.')||
                         ',1434,'|| chr(34) || vr_nmaux ||chr(34);
           --Escrever o cabecalho no arquivo
           gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                         ,pr_des_text => vr_setlinha); --> Texto para escrita

           --Se nao for cecred
           IF pr_cdcooper <> 3 THEN
             vr_setlinha:=  '999,' || REPLACE(trim(to_char(vr_rel_vlsbtot6 ,'fm999999990d00')),',','.');
             --Escrever o cabecalho no arquivo
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita
           END IF;
         END IF;

         /*-------------   Saldo Limite Cheque Especial   -----------
         --Se o valor total do Limite Cheque Especial for > 0
         IF vr_rel_vltotlim > 0 THEN
           --Se for cecred
           IF pr_cdcooper = 3 THEN
             --Alimentar Desricacao auxiliar
             vr_dsaux:= ',3814,9185,';
             --Montar descricao nome
             vr_nmaux:= 'LIMITE TOTAL CREDITO ROTATIVO';
           ELSE
             --Alimentar Desricacao auxiliar
             vr_dsaux:= ',3811,9182,';
             --Montar descricao nome
             vr_nmaux:= 'LIMITE TOTAL CHEQUE ESPECIAL';
           END IF;
           --Montar mensagem para gravar no arquivo
           vr_setlinha:= trim(vr_con_dtmvtolt) || ',' ||
                         trim(To_Char(vr_dtmvtolt,'DDMMYY')) ||
                         vr_dsaux ||
                         REPLACE(trim(To_Char(vr_rel_vltotlim ,'fm999999999999990d00')),',','.')||
                         ',1434,'|| chr(34) || '(crps005) '|| vr_nmaux ||chr(34);
           --Escrever o cabecalho no arquivo
           gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                         ,pr_des_text => vr_setlinha); --> Texto para escrita

           --Se for cecred
           IF pr_cdcooper = 3 THEN
             --Alimentar Desricacao auxiliar
             vr_dsaux:= ',9185,3814,';
           ELSE
             --Alimentar Desricacao auxiliar
             vr_dsaux:= ',9182,3811,';
           END IF;

           --Montar mensagem para gravar no arquivo
           vr_setlinha:= trim(vr_con_dtmvtopr) || ',' ||
                         trim(To_Char(vr_dtmvtopr,'DDMMYY')) ||
                         vr_dsaux ||
                         REPLACE(trim(To_Char(vr_rel_vltotlim ,'fm999999999999990d00')),',','.')||
                         ',1434,'|| chr(34) || vr_nmaux ||chr(34);
           --Escrever o cabecalho no arquivo
           gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                         ,pr_des_text => vr_setlinha); --> Texto para escrita
         END IF;*/
         
         -- não gera as informações no ultimo dia do mês
         IF to_char(rw_crapdat.dtmvtolt,'MM') = to_char(rw_crapdat.dtmvtopr,'MM') THEN
           /* ------------  Saldo Cheque Especial Utilizado  ------------- */
           --Se o valor Saldo Cheque Especial Utilizado for > 0
           IF vr_rel_vltotal4 > 0 THEN
             --Se for cecred
             IF pr_cdcooper = 3 THEN
               --Alimentar Desricacao auxiliar
               vr_dsaux:= ',1631,4451,';
               --Montar descricao nome
               vr_nmaux:= '(crps005) SALDO CREDITO ROTATIVO UTILIZADO';
             ELSE
               --Alimentar Desricacao auxiliar
               vr_dsaux:= ',1622,4112,';
               --Montar descricao nome
               vr_nmaux:= '(crps005) SALDO CHEQUE ESP. UTILIZADO';
             END IF;
             --Montar mensagem para gravar no arquivo
             vr_setlinha:= trim(vr_con_dtmvtolt) || ',' ||
                           trim(To_Char(vr_dtmvtolt,'DDMMYY')) ||
                           vr_dsaux ||
                           REPLACE(trim(To_Char(vr_rel_vltotal4 ,'fm999999999999990d00')),',','.')||
                           ',1434,'|| chr(34) || vr_nmaux ||chr(34);
             --Escrever o cabecalho no arquivo
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita

             vr_setlinha:=  '999,' || REPLACE(trim(to_char(vr_rel_vltotal4 ,'fm999999990d00')),',','.');
             --Escrever o cabecalho no arquivo
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita
             --Se nao for cecred
             IF pr_cdcooper <> 3 THEN
               --Escrever no arquivo
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita
             END IF;


             --Se for cecred
             IF pr_cdcooper = 3 THEN
               --Alimentar Desricacao auxiliar
               vr_dsaux:= ',4451,1631,';
             ELSE
               --Alimentar Desricacao auxiliar
               vr_dsaux:= ',4112,1622,';
             END IF;

             --Montar mensagem para gravar no arquivo
             vr_setlinha:= trim(vr_con_dtmvtopr) || ',' ||
                           trim(To_Char(vr_dtmvtopr,'DDMMYY')) ||
                           vr_dsaux ||
                           REPLACE(trim(To_Char(vr_rel_vltotal4 ,'fm999999999999990d00')),',','.')||
                           ',1434,'|| chr(34) || vr_nmaux ||chr(34);
             --Escrever o cabecalho no arquivo
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita
             vr_setlinha:=  '999,' || REPLACE(trim(to_char(vr_rel_vltotal4 ,'fm999999990d00')),',','.');
             --Escrever o cabecalho no arquivo
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita
             --Se nao for cecred
             IF pr_cdcooper <> 3 THEN
               --Escrever no arquivo
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita
             END IF;
           END IF;

           /* ------------  Saque Sobre Depositos Bloqueados  ------------- */
           --Se o valor Saque Sobre Depositos Bloqueados for > 0
           IF vr_rel_vltotal5 > 0 THEN
             --Se for cecred
             IF pr_cdcooper = 3 THEN
               --Alimentar Desricacao auxiliar
               vr_dsaux:= ',1613,4451,';
             ELSE
             --Alimentar Desricacao auxiliar
               vr_dsaux:= ',1613,4112,';
             END IF;
             --Determinar a descricao
             vr_nmaux:= '(crps005) SAQUE SOBRE DEPOS. BLOQUEADO';

             --Montar mensagem para gravar no arquivo
             vr_setlinha:= trim(vr_con_dtmvtolt) || ',' ||
                           trim(To_Char(vr_dtmvtolt,'DDMMYY')) ||
                           vr_dsaux ||
                           REPLACE(trim(To_Char(vr_rel_vltotal5 ,'fm999999999999990d00')),',','.')||
                           ',1434,'|| chr(34) || vr_nmaux ||chr(34);
             --Escrever o cabecalho no arquivo
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita

             vr_setlinha:=  '999,' || REPLACE(trim(to_char(vr_rel_vltotal5 ,'fm999999990d00')),',','.');
             --Escrever o cabecalho no arquivo
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita

             --Se nao for cecred
             IF pr_cdcooper <> 3 THEN
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita
             END IF;

             --Se for cecred
             IF pr_cdcooper = 3 THEN
               --Alimentar Desricacao auxiliar
               vr_dsaux:= ',4451,1613,';
             ELSE
             --Alimentar Desricacao auxiliar
               vr_dsaux:= ',4112,1613,';
             END IF;

             --Montar mensagem para gravar no arquivo
             vr_setlinha:= trim(vr_con_dtmvtopr) || ',' ||
                           trim(To_Char(vr_dtmvtopr,'DDMMYY')) ||
                           vr_dsaux ||
                           REPLACE(trim(To_Char(vr_rel_vltotal5 ,'fm999999999999990d00')),',','.')||
                           ',1434,'|| chr(34) || vr_nmaux ||chr(34);
             --Escrever o cabecalho no arquivo
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita

             vr_setlinha:=  '999,' || REPLACE(trim(to_char(vr_rel_vltotal5 ,'fm999999990d00')),',','.');
             --Escrever o cabecalho no arquivo
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita

             --Se nao for cecred
             IF pr_cdcooper <> 3 THEN
               --Escrever o cabecalho no arquivo
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita
             END IF;
           END IF;

           /* ------------  Adiantamento a Depositantes  ------------- */
           --Se o valor Adiantamento a Depositantes for > 0
           IF vr_rel_vltotal6 > 0 THEN
             --Se for cecred
             IF pr_cdcooper = 3 THEN
               --Alimentar Desricacao auxiliar
               vr_dsaux:= ',1611,4451,';
             ELSE
             --Alimentar Desricacao auxiliar
               vr_dsaux:= ',1611,4112,';
             END IF;
             --Determinar a descricao
             vr_nmaux:= '(crps005) ADIANTAMENTO A DEPOSITANTES ';

             --Montar mensagem para gravar no arquivo
             vr_setlinha:= trim(vr_con_dtmvtolt) || ',' ||
                           trim(To_Char(vr_dtmvtolt,'DDMMYY')) ||
                           vr_dsaux ||
                           REPLACE(trim(To_Char(vr_rel_vltotal6,'fm999999999999990d00')),',','.')||
                           ',1434,'|| chr(34) || vr_nmaux ||chr(34);
             --Escrever o cabecalho no arquivo
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita

             vr_setlinha:=  '999,' || REPLACE(trim(to_char(vr_rel_vltotal6 ,'fm999999990d00')),',','.');
             --Escrever o cabecalho no arquivo
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita

             --Se nao for cecred
             IF pr_cdcooper <> 3 THEN
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita
             END IF;

             --Se for cecred
             IF pr_cdcooper = 3 THEN
               --Alimentar Desricacao auxiliar
               vr_dsaux:= ',4451,1611,';
             ELSE
             --Alimentar Desricacao auxiliar
               vr_dsaux:= ',4112,1611,';
             END IF;

             --Montar mensagem para gravar no arquivo
             vr_setlinha:= trim(vr_con_dtmvtopr) || ',' ||
                           trim(To_Char(vr_dtmvtopr,'DDMMYY')) ||
                           vr_dsaux ||
                           REPLACE(trim(To_Char(vr_rel_vltotal6 ,'fm999999999999990d00')),',','.')||
                           ',1434,'|| chr(34) || vr_nmaux ||chr(34);
             --Escrever o cabecalho no arquivo
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita

             vr_setlinha:=  '999,' || REPLACE(trim(to_char(vr_rel_vltotal6 ,'fm999999990d00')),',','.');
             --Escrever o cabecalho no arquivo
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita

             --Se nao for cecred
             IF pr_cdcooper <> 3 THEN
               --Escrever o cabecalho no arquivo
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita
             END IF;
           END IF;

           /* ------------  Adiantamento a Depositantes em CL  ------------ */
           --Se o valor Adiantamento a Depositantes em CL for > 0
           IF vr_rel_vltotal7 > 0 THEN
             --Se for cecred
             IF pr_cdcooper = 3 THEN
               --Alimentar Desricacao auxiliar
               vr_dsaux:= ',1611,4451,';
             ELSE
             --Alimentar Desricacao auxiliar
               vr_dsaux:= ',1611,4112,';
             END IF;

             --Determinar a descricao
             vr_nmaux:= '(crps005) ADIANTAMENTO A DEPOSITANTES ';
             --Montar mensagem para gravar no arquivo
             vr_setlinha:= trim(vr_con_dtmvtolt) || ',' ||
                           trim(To_Char(vr_dtmvtolt,'DDMMYY')) ||
                           vr_dsaux ||
                           REPLACE(trim(To_Char(vr_rel_vltotal7 ,'fm999999999999990d00')),',','.')||
                           ',1434,'|| chr(34) || vr_nmaux ||chr(34);
             --Escrever o cabecalho no arquivo
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita

             vr_setlinha:=  '999,' || REPLACE(trim(to_char(vr_rel_vltotal7 ,'fm999999990d00')),',','.');
             --Escrever o cabecalho no arquivo
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita

             --Se nao for cecred
             IF pr_cdcooper <> 3 THEN
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita
             END IF;

             --Se for cecred
             IF pr_cdcooper = 3 THEN
               --Alimentar Desricacao auxiliar
               vr_dsaux:= ',4451,1611,';
             ELSE
             --Alimentar Desricacao auxiliar
               vr_dsaux:= ',4112,1611,';
             END IF;

             --Montar mensagem para gravar no arquivo
             vr_setlinha:= trim(vr_con_dtmvtopr) || ',' ||
                           trim(To_Char(vr_dtmvtopr,'DDMMYY')) ||
                           vr_dsaux ||
                           REPLACE(trim(To_Char(vr_rel_vltotal7,'fm999999999999990d00')),',','.')||
                           ',1434,'|| chr(34) || vr_nmaux ||chr(34);
             --Escrever o cabecalho no arquivo
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita

             vr_setlinha:=  '999,' || REPLACE(trim(to_char(vr_rel_vltotal7,'fm999999990d00')),',','.');
             --Escrever o cabecalho no arquivo
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita

             --Se nao for cecred
             IF pr_cdcooper <> 3 THEN
               --Escrever o cabecalho no arquivo
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita
             END IF;
           END IF;

           /* ------------  Bloqueio judicial  ------------ */
           --Se o valor Bloqueio menor zero
           /* Prj421 - Nao deve mais gerar lancamentos contabeis de valores bloqueado judicialmente
              Removido a pedido da contabilidade pois esses lancamentos sao inuteis para eles, sendo
              revertidos diariamente
           IF vr_rel_vltotal9 < 0 THEN
             --Se for cecred
             IF pr_cdcooper = 3 THEN
               --Alimentar Desricacao auxiliar
               vr_dsaux:= ',1611,4451,';
             ELSE
             --Alimentar Desricacao auxiliar
               vr_dsaux:= ',1611,4112,';
             END IF;

             --Determinar a descricao
             vr_nmaux:= '(crps005) BLOQUEADO JUDICIALMENTE ';
             --Montar mensagem para gravar no arquivo
             vr_setlinha:= trim(vr_con_dtmvtolt) || ',' ||
                           trim(To_Char(vr_dtmvtolt,'DDMMYY')) ||
                           vr_dsaux ||
                           REPLACE(trim(To_Char((vr_rel_vltotal9 *-1) ,'fm999999999999990d00')),',','.')||
                           ',1434,'|| chr(34) || vr_nmaux ||chr(34);
             --Escrever o cabecalho no arquivo
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita

             vr_setlinha:=  '999,' || REPLACE(trim(to_char((vr_rel_vltotal9 *-1) ,'fm999999990d00')),',','.');
             --Escrever o cabecalho no arquivo
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita

             --Se nao for cecred
             IF pr_cdcooper <> 3 THEN
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita
             END IF;

             --Se for cecred
             IF pr_cdcooper = 3 THEN
               --Alimentar Desricacao auxiliar
               vr_dsaux:= ',4451,1611,';
             ELSE
             --Alimentar Desricacao auxiliar
               vr_dsaux:= ',4112,1611,';
             END IF;

             --Montar mensagem para gravar no arquivo
             vr_setlinha:= trim(vr_con_dtmvtopr) || ',' ||
                           trim(To_Char(vr_dtmvtopr,'DDMMYY')) ||
                           vr_dsaux ||
                           REPLACE(trim(To_Char((vr_rel_vltotal9 *-1) ,'fm999999999999990d00')),',','.')||
                           ',1434,'|| chr(34) || vr_nmaux ||chr(34);
             --Escrever o cabecalho no arquivo
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita

             vr_setlinha:=  '999,' || REPLACE(trim(to_char((vr_rel_vltotal9 *-1),'fm999999990d00')),',','.');
             --Escrever o cabecalho no arquivo
             gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto para escrita

             --Se nao for cecred
             IF pr_cdcooper <> 3 THEN
               --Escrever o cabecalho no arquivo
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita
             END IF;
           END IF;
           */
         END IF; -- Fim Mesmo Mês
           
         --Fechar Arquivo
         BEGIN
           gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
         EXCEPTION
           WHEN OTHERS THEN
             -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
             vr_cdcritic := 1039;
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' <'||vr_nom_direto||'/'||vr_nmarqtxt||'>: ' || sqlerrm;

             --Inclusão na tabela de erros Oracle - Chamado 822997
             CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
             RAISE vr_exc_erro;
         END;
         
         -- Busca o diretório para contabilidade
          vr_dircon := gene0001.fn_param_sistema('CRED', vc_cdtodascooperativas, vc_cdacesso);
          vr_dircon := vr_dircon || vc_dircon;
          vr_arqcon := to_char(vr_dtmvtolt,'YYMMDD')||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_1.txt';
         
         -- Ao final, converter o arquivo para DOS e enviá-lo a pasta micros/<dsdircop>/contab
         vr_dscomando := 'ux2dos '||vr_nom_direto||'/'||vr_nmarqtxt||' > '||
                                    vr_dircon||'/'||vr_arqcon||' 2>/dev/null';
         --Executar o comando no unix
         GENE0001.pc_OScommand(pr_typ_comando => 'S'
                              ,pr_des_comando => vr_dscomando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);
         --Se ocorreu erro dar RAISE
         IF vr_typ_saida = 'ERR' THEN
           vr_cdcritic := 1114;
           vr_dscritic := substr(gene0001.fn_busca_critica(vr_cdcritic), 1, 
                                 instr(gene0001.fn_busca_critica(vr_cdcritic), '.', -1)-1)||
                          ' de conversão: '||vr_dscomando||
                          '. Erro: '||vr_dscritic;

           RAISE vr_exc_erro;
         END IF;
         
         /* Gravacao de dados no banco GENERICO - Relatorios Gerenciais */
         BEGIN
           --Atualizar tabela
           UPDATE gntotpl SET gntotpl.vlchqadm = vr_rel_vlsbtot3
                             ,gntotpl.vltotlim = vr_rel_vltotal4
                             ,gntotpl.vltotsdb = vr_rel_vltotal5
                             ,gntotpl.vltotadd = vr_rel_vltotal6
                             ,gntotpl.vltotacl = vr_rel_vltotal7
           WHERE gntotpl.cdcooper = pr_cdcooper
           AND   gntotpl.dtmvtolt = vr_dtmvtolt;

           --Se nao atualizou nenhum registro
           IF SQL%ROWCOUNT = 0 THEN
             BEGIN
               INSERT INTO gntotpl (gntotpl.cdcooper
                                   ,gntotpl.dtmvtolt
                                   ,gntotpl.vlchqadm
                                   ,gntotpl.vltotlim
                                   ,gntotpl.vltotsdb
                                   ,gntotpl.vltotadd
                                   ,gntotpl.vltotacl)
               VALUES              (pr_cdcooper
                                   ,vr_dtmvtolt
                                   ,vr_rel_vlsbtot3
                                   ,vr_rel_vltotal4
                                   ,vr_rel_vltotal5
                                   ,vr_rel_vltotal6
                                   ,vr_rel_vltotal7);
             EXCEPTION
               WHEN OTHERS THEN
                  --Montar mensagem de erro
                  vr_cdcritic := 1034;
                  vr_des_erro:= gene0001.fn_busca_critica(vr_cdcritic)||' gntotpl: '||
                                'cdcooper:'  ||pr_cdcooper    ||
                                ', dtmvtolt:'||vr_dtmvtolt    ||
                                ', vlchqadm:'||vr_rel_vlsbtot3||
                                ', vltotlim:'||vr_rel_vltotal4||
                                ', vltotsdb:'||vr_rel_vltotal5||
                                ', vltotadd:'||vr_rel_vltotal6||
                                ', vltotacl:'||vr_rel_vltotal7||
                                '. '||sqlerrm;

                 --Inclusão na tabela de erros Oracle - Chamado 822997
                 CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                 --Levantar Exceção
                 RAISE vr_exc_erro;
             END;
           END IF;
         EXCEPTION
           WHEN vr_exc_erro THEN
             RAISE vr_exc_erro;
           WHEN OTHERS THEN
              --Montar mensagem de erro
              vr_cdcritic := 1035;
              vr_des_erro:= gene0001.fn_busca_critica(vr_cdcritic)||' gntotpl: '||
                            'vlchqadm:'     ||vr_rel_vlsbtot3||
                            ', vltotlim:'   ||vr_rel_vltotal4||
                            ', vltotsdb:'   ||vr_rel_vltotal5||
                            ', vltotadd:'   ||vr_rel_vltotal6||
                            ', vltotacl:'   ||vr_rel_vltotal7||
                            ' com cdcooper:'||pr_cdcooper||
                            ', dtmvtolt:'   ||vr_dtmvtolt||
                            '. '||sqlerrm;

             --Inclusão na tabela de erros Oracle - Chamado 822997
             CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
             --Levantar Exceção
             RAISE vr_exc_erro;
         END;

         /***   Gravacao dos saldos por agencia   ***/

         --Posicionar no primeiro registro
         vr_index_crapage:= vr_tab_crapage.FIRST;
         --Selecionar todas as agencias
         WHILE vr_index_crapage IS NOT NULL LOOP  --Sair quando nao tiver mais registros
           
           --Atribuir valores do vetor para o registro
           vr_cdagenci:= vr_tab_crapage(vr_index_crapage).cdagenci;
           vr_nmresage:= vr_tab_crapage(vr_index_crapage).nmresage;

           --Verificar se a agencia possui associados
           IF vr_tab_crapass.EXISTS(vr_cdagenci) THEN
             --Atualizar tabela gninfpl
             BEGIN
               --Verificar se a agencia existe no vetor
               IF vr_tab_pac_vlstotal.EXISTS(vr_cdagenci) THEN
                 --Vatiavel auxiliar recebe valor do vetor
                 vr_pac_vlstotal:= vr_tab_pac_vlstotal(vr_cdagenci);
               ELSE
                 vr_pac_vlstotal:= 0;
               END IF;
               --Atualizar tabela gninfpl
               UPDATE gninfpl SET gninfpl.vltotscc = vr_pac_vlstotal
               WHERE  gninfpl.cdcooper = pr_cdcooper
               AND    gninfpl.dtmvtolt = vr_dtmvtolt /* ? */
               AND    gninfpl.cdagenci = vr_cdagenci;
               --Se nao encontrou registro
               IF SQL%ROWCOUNT = 0 THEN
                 BEGIN
                   INSERT INTO gninfpl (gninfpl.cdcooper
                                       ,gninfpl.dtmvtolt
                                       ,gninfpl.cdagenci
                                       ,gninfpl.vltotscc)
                   VALUES              (pr_cdcooper
                                       ,vr_dtmvtolt
                                       ,vr_cdagenci
                                       ,vr_pac_vlstotal);

                 EXCEPTION
                 WHEN OTHERS THEN
                      --Montar mensagem de erro
                      vr_cdcritic := 1034;
                      vr_des_erro:= gene0001.fn_busca_critica(vr_cdcritic)||' gninfpl: '||
                                    'cdcooper:'  ||pr_cdcooper||
                                    ', dtmvtolt:'||vr_dtmvtolt||
                                    ', cdagenci:'||vr_cdagenci||
                                    ', vltotscc:'||vr_pac_vlstotal||
                                    '. '||sqlerrm;
                       --Inclusão na tabela de erros Oracle - Chamado 822997
                       CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                   --Levantar Exceção
                   RAISE vr_exc_erro;
                 END;
               END IF;
             EXCEPTION
               WHEN OTHERS THEN
                  vr_cdcritic := 1035;
                  vr_des_erro:= gene0001.fn_busca_critica(vr_cdcritic)||' gninfpl: '||
                                'vltotscc:'     ||vr_pac_vlstotal||
                                ' com cdcooper:'||pr_cdcooper||
                                ', dtmvtolt:'   ||vr_dtmvtolt||
                                ', cdagenci:'   ||vr_cdagenci||
                                '. '||sqlerrm;

                 --Inclusão na tabela de erros Oracle - Chamado 822997
                 CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                 --Levantar Exceção
                 RAISE vr_exc_erro;
             END;
           END IF;
           -- Buscar o próximo registro da tabela
           vr_index_crapage := vr_tab_crapage.NEXT(vr_index_crapage);
         END LOOP;

         --Se for Cecred
         IF pr_cdcooper = 3 THEN
           --Percorrer tabela memoria gn006
           FOR idx IN 1..vr_tab_gn006.Count LOOP
             --Verificar se a cooperativa existe
             OPEN cr_crapcop_conta (pr_nrdconta => vr_tab_gn006(idx).nrdconta);
             --Posicionar no primeiro registro
             FETCH cr_crapcop_conta INTO rw_crapcop_conta;
             --Se encontrou registro
             IF cr_crapcop_conta%FOUND THEN
               --Fechar Cursor
               CLOSE cr_crapcop_conta;

               --Atualizar tabela total gntotpl
               BEGIN
                 UPDATE gntotpl SET gntotpl.vltotscc = vr_tab_gn006(idx).vlstotal
                 WHERE  gntotpl.cdcooper = rw_crapcop_conta.cdcooper
                 AND    gntotpl.dtmvtolt = vr_dtmvtolt;
                 --Se nao atualizou nada
                 IF SQL%ROWCOUNT = 0 THEN
                   BEGIN
                     --Inserir na tabela gntotpl
                     INSERT INTO gntotpl (gntotpl.cdcooper
                                         ,gntotpl.dtmvtolt
                                         ,gntotpl.vltotscc)
                     VALUES              (rw_crapcop_conta.cdcooper
                                         ,vr_dtmvtolt
                                         ,vr_tab_gn006(idx).vlstotal);
                   EXCEPTION
                     WHEN OTHERS THEN
                        vr_cdcritic := 1034;
                        vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||' gntotpl: '||
                                       'cdcooper:'  ||rw_crapcop_conta.cdcooper||
                                       ', dtmvtolt:'||vr_dtmvtolt||
                                       ', vltotscc:'||vr_tab_gn006(idx).vlstotal||
                                       '. '||sqlerrm;
                       --Levantar Exceção
                       RAISE vr_exc_erro;
                   END;
                END IF;
               EXCEPTION
                 WHEN vr_exc_erro THEN
                   RAISE vr_exc_erro;
                 WHEN OTHERS THEN
                    vr_cdcritic := 1035;
                    vr_des_erro:= gene0001.fn_busca_critica(vr_cdcritic)||' gntotpl: '||
                                  'vltotscc:'     ||vr_tab_gn006(idx).vlstotal||
                                  ' com cdcooper:'||rw_crapcop_conta.cdcooper||
                                  ', dtmvtolt:'   ||vr_dtmvtolt||
                                  '. '||sqlerrm;
                   --Levantar Exceção
                   RAISE vr_exc_erro;
               END;
             ELSE
               --Fechar Cursor
               CLOSE cr_crapcop_conta;
             END IF;
           END LOOP;
         END IF;
       EXCEPTION
         WHEN vr_exc_erro THEN
           pr_des_erro:= vr_des_erro;
         WHEN OTHERS THEN
          vr_cdcritic := 1115;
          pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'crrl006. '||sqlerrm;
       END;
       --

       --Gerar relatorio Saldos Conta Investimento (crrl372)
       PROCEDURE pc_imprime_crrl372 (pr_des_erro OUT VARCHAR2) IS

         --Variaveis locais

         --Variavel de Exceção
         vr_exc_erro EXCEPTION;

       BEGIN
         -- Inclui nome do modulo logado - 16/01/2018 - Ch 822997
         GENE0001.pc_set_modulo(pr_module => 'PC_CRPS005.pc_imprime_crrl372' ,pr_action => NULL);

         --Inicializar variavel de erro
         pr_des_erro:= NULL;

         -- Busca do diretório base da cooperativa
         vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

         -- Processar todos os registros dos maiores depositantes
         vr_des_chave := vr_tab_crat372.FIRST;
         WHILE vr_des_chave IS NOT NULL LOOP
           --Atribuir código da agencia para variavel
           vr_cdagenci:= vr_tab_crat372(vr_des_chave).cdagenci;

           -- Se estivermos processando o primeiro registro do vetor ou mudou a agência
           IF vr_des_chave = vr_tab_crat372.FIRST OR vr_tab_crat372(vr_des_chave).cdagenci <> vr_tab_crat372(vr_tab_crat372.PRIOR(vr_des_chave)).cdagenci THEN
             -- Nome base do arquivo é crrl055
             vr_nom_arquivo := 'crrl372_'||To_Char(vr_cdagenci,'FM009');

             --Selecionar nome resumido da agencia
             IF vr_tab_crapage.EXISTS(vr_cdagenci) THEN
               --Atribuir nome da agencia para variavel
               vr_nmresage:= vr_tab_crapage(vr_cdagenci).nmresage;
             ELSE
               --Atribuir nome da agencia para variavel
               vr_nmresage:= 'PA NAO ENCONTRADO';
             END IF;

             -- Inicializar o CLOB
             dbms_lob.createtemporary(vr_des_xml, TRUE);
             dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
             vr_dstexto:= NULL;
             -- Inicilizar as informações do XML
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<?xml version="1.0" encoding="utf-8"?><crrl372><agencias>');
             --Escrever a tag de agencia com os totalizadores da mesma
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<agencia cdagenci="'||vr_cdagenci||'" nmresage="'|| vr_nmresage ||'"><contas>');
           END IF;

           --Escrever detalhe no xml
           gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<conta id="'||vr_des_chave||'">
                         <nrdconta>'||LTrim(gene0002.fn_mask_conta(vr_tab_crat372(vr_des_chave).nrdconta))||'</nrdconta>
                         <nrdofone>'||vr_tab_crat372(vr_des_chave).nrdofone||'</nrdofone>
                         <cdempres>'||To_Char(vr_tab_crat372(vr_des_chave).cdempres,'fm00009')||'</cdempres>
                         <cdturnos>'||To_Char(vr_tab_crat372(vr_des_chave).cdturnos,'fm99')||'</cdturnos>
                         <vlsddisp>'||to_char(vr_tab_crat372(vr_des_chave).vlsddisp,'fm99999g999d00')||'</vlsddisp>
                         <nmprimtl>'||SUBSTR(vr_tab_crat372(vr_des_chave).nmprimtl,0,20)||'</nmprimtl>
                         </conta>');
           -- Se este for o ultimo registro do vetor, ou da agência
           IF vr_des_chave = vr_tab_crat372.LAST OR vr_tab_crat372(vr_des_chave).cdagenci <> vr_tab_crat372(vr_tab_crat372.NEXT(vr_des_chave)).cdagenci THEN
             --FInalizar o agrupador do relatorio
             gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</contas></agencia></agencias></crrl372>',true);

             -- Efetuar solicitação de geração de relatório --
             gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                        ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                        ,pr_dtmvtolt  => vr_dtmvtolt         --> Data do movimento atual
                                        ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                        ,pr_dsxmlnode => '/crrl372/agencias/agencia/contas/conta' --> Nó base do XML para leitura dos dados
                                        ,pr_dsjasper  => 'crrl372.jasper'    --> Arquivo de layout do iReport
                                        ,pr_dsparams  => NULL                --> Sem parametros
                                        ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com código da agência
                                        ,pr_qtcoluna  => 132                 --> 132 colunas
                                        ,pr_sqcabrel  => NULL                --> Sequencia do Relatorio {includes/cabrel132_6.i}
                                        ,pr_cdrelato  => 372                 --> Código fixo para o relatório (nao busca pelo sqcabrel)
                                        ,pr_flg_impri => 'N'                 --> Chamar a impressão (Imprim.p)
                                        ,pr_nmformul  => '132dm'             --> Nome do formulário para impressão
                                        ,pr_nrcopias  => 1                   --> Número de cópias a imprimir
                                        ,pr_flg_gerar => 'N'                 --> gerar PDF
                                        ,pr_des_erro  => vr_des_erro);       --> Saída com erro

             -- Testar se houve erro
             IF vr_des_erro IS NOT NULL THEN
               -- Gerar exceção
               RAISE vr_exc_erro;
             END IF;
             -- Liberando a memória alocada pro CLOB
             dbms_lob.close(vr_des_xml);
             dbms_lob.freetemporary(vr_des_xml);
             vr_dstexto:= NULL;
           END IF;
           -- Buscar o próximo registro da tabela
           vr_des_chave := vr_tab_crat372.NEXT(vr_des_chave);
         END LOOP;
       EXCEPTION
         WHEN vr_exc_erro THEN
           pr_des_erro:= vr_des_erro;
         WHEN OTHERS THEN
          vr_cdcritic := 1115;
          pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'crrl372. '||sqlerrm;
       END;

     ---------------------------------------
     -- Inicio Bloco Principal pc_crps005
     ---------------------------------------
     BEGIN

       --Atribuir o nome do programa que está executando
       vr_cdprogra:= 'CRPS005';

       -- Incluir nome do módulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS005'
                                 ,pr_action => NULL);

       -- Verifica se a cooperativa esta cadastrada
       OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
       FETCH cr_crapcop INTO rw_crapcop;
       -- Se não encontrar
       IF cr_crapcop%NOTFOUND THEN
         -- Fechar o cursor pois haverá raise
         CLOSE cr_crapcop;
         -- Montar mensagem de critica
         vr_cdcritic:= 651;
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapcop;
       END IF;

       -- Verifica se a cooperativa esta cadastrada
       OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH btch0001.cr_crapdat INTO rw_crapdat;
       -- Se não encontrar
       IF btch0001.cr_crapdat%NOTFOUND THEN
         -- Fechar o cursor pois haverá raise
         CLOSE btch0001.cr_crapdat;
         -- Montar mensagem de critica
         vr_cdcritic:= 1;
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE btch0001.cr_crapdat;

         --Atribuir a data do movimento
         vr_dtmvtolt:= rw_crapdat.dtmvtolt;
         --Atribuir a proxima data do movimento
         vr_dtmvtopr:= rw_crapdat.dtmvtopr;
         --Atribuir a data do movimento anterior
         vr_dtmvtoan:= rw_crapdat.dtmvtoan;
         --Ultimo dia do mes anterior
         vr_dtultdia:= rw_crapdat.dtultdia;
         -- projeto ligeirinho
         vr_inproces:= rw_crapdat.inproces;
       END IF;


       -- Validações iniciais do programa
       BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                 ,pr_flgbatch => 1 -- Fixo
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_cdcritic => vr_cdcritic);

       --Se retornou critica aborta programa
       IF vr_cdcritic <> 0 THEN
         --Sair do programa
         RAISE vr_exc_saida;
       END IF;

       -- Procedimento padrão de busca de informações de CPMF
       gene0005.pc_busca_cpmf(pr_cdcooper  => pr_cdcooper
                             ,pr_dtmvtolt  => vr_dtmvtolt
                             ,pr_dtinipmf  => vr_dtinipmf
                             ,pr_dtfimpmf  => vr_dtfimpmf
                             ,pr_txcpmfcc  => vr_txcpmfcc
                             ,pr_txrdcpmf  => vr_txrdcpmf
                             ,pr_indabono  => vr_indabono
                             ,pr_dtiniabo  => vr_dtiniabo
                             ,pr_cdcritic  => vr_cdcritic
                             ,pr_dscritic  => vr_dscritic);
       -- Se retornou erro
       IF vr_dscritic IS NOT NULL THEN
         -- Encerra execução
         RAISE vr_exc_saida;
       END IF;

       --Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;
       -- Incluir nome do módulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS005' ,pr_action => NULL);

       --Inicializar totalizadores por tipo de pessoa
       pc_inicializa_tabela;
       -- Incluir nome do módulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS005' ,pr_action => NULL);

       --Leitura dos parametros para maiores depositantes
       vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'MAIORESDEP'
                                               ,pr_tpregist => 1);
       --Se nao encontrou entao
       IF vr_dstextab IS NULL THEN
         --Atribuir maior depositante o limite de 10.000
         vr_rel_vlmaidep:= 10000;
         --Atribuir limite saldo negativo
         vr_rel_vlsldneg:= 1000;
       ELSE
         --Atribuir maior depositante
         vr_rel_vlmaidep:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,1,15));
         --Atribuir limite saldo negativo
         vr_rel_vlsldneg:= GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,33,15));
         --Se maior depositante = 0
         IF vr_rel_vlmaidep = 0 THEN
           --Atribuir valor maior depositante
           vr_rel_vlmaidep:= 0.01;
         END IF;
       END IF;

       --Leitura dos parametros para verificar se usa tabela juros
       --no calculo do saldo dos emprestimos
       vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'TAXATABELA'
                                               ,pr_tpregist => 0);
       --Se nao encontrou entao
       IF vr_dstextab IS NULL THEN
         --Não utilizar tabela de juros
         vr_inusatab:= FALSE;
       ELSE
         --Se o valor do parametro = 0
         IF SUBSTR(vr_dstextab,1,1) = '0' THEN
           --Nao usar tabela de juros
           vr_inusatab:= FALSE;
         ELSE
           --Usar tabela de juros
           vr_inusatab:= TRUE;
         END IF;
       END IF;

       --Atribuir a descrição do valor de referencia
       vr_rel_dslimite:= To_Char(vr_rel_vlsldneg,'999G999G999G999D99');

       --Criar a lista de linha creditos - micro credito
       FOR rw_craplcr IN cr_craplcr (pr_cdcooper => pr_cdcooper
                                    ,pr_cdusolcr => 1) LOOP
         --Se for a primeira linha
         IF cr_craplcr%ROWCOUNT = 1 THEN
           --Inicializar lista de linhas de credito
           vr_listalcr:= ','||rw_craplcr.cdlcremp||',';
           vr_lispnmpo:= ',';
         ELSE
           --Concatenar lista de linhas de credito
           vr_listalcr:= vr_listalcr||rw_craplcr.cdlcremp||',';
         END IF;
         --Se a descrição for PNMPO ou BNDES
         IF InStr(Upper(rw_craplcr.dsorgrec),'PNMPO') > 0 OR InStr(Upper(rw_craplcr.dsorgrec),'BNDES') > 0 THEN
           --Concatenar lista de pnmpo
           vr_lispnmpo:= vr_lispnmpo ||rw_craplcr.cdlcremp||',';
         END IF;
       END LOOP;
       -----------------------------------------------------------
       -- Controle de paralelismo
       -- projeto ligeirinho
       ------------------------------------------------------------
       -- Buscar quantidade parametrizada de Jobs
       vr_qtdjobs := gene0001.fn_retorna_qt_paralelo(pr_cdcooper => pr_cdcooper --pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Código da coopertiva
                                                    ,pr_cdprogra => vr_cdprogra --pr_cdprogra  IN crapprg.cdprogra%TYPE    --> Código do programa
                                                     );   

        
       /* Paralelismo visando performance Rodar Somente no processo Noturno */
       if vr_inproces  > 2 and
          vr_qtdjobs   > 0 and 
          pr_cdagenci  = 0 then  

          -- Gerar o ID para o paralelismo
          vr_idparale := gene0001.fn_gera_id_paralelo;
            
          -- Se houver algum erro, o id vira zerado
          IF vr_idparale = 0 THEN
             -- Levantar exceção
             vr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_id_paralelo.';
             RAISE vr_exc_saida;
          END IF;

          --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
          pc_log_programa(pr_dstiplog   => 'I',    
                          pr_cdprograma => vr_cdprogra,           
                          pr_cdcooper   => pr_cdcooper, 
                          pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          pr_idprglog   => vr_idlog_ini_ger);

          
          -- Verifica se algum job paralelo executou com erro
          vr_qterro := 0;
          vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper,
                                                        pr_cdprogra    => vr_cdprogra,
                                                        pr_dtmvtolt    => vr_dtmvtolt,
                                                        pr_tpagrupador => 1,
                                                        pr_nrexecucao  => 1);    

          --Limpa a tabela WRK utilizada na geração dos relatórios 
          --quando o processo é executado em paralelo
          --somente quando não houver jobs com erro no inicio da execução.
          -- Projeto ligeirinho
          if pr_idparale = 0 and
             vr_qterro = 0 then
             pc_limpa_tbgen_batch_rel_wrk (pr_cdcooper  => pr_cdcooper,
                                           pr_dtmvtolt  => vr_dtmvtolt,
                                           pr_des_erro  => vr_dscritic);
              -- Testar saida com erro
              if vr_dscritic is not null then
                -- Levantar exceçao
                raise vr_exc_saida;
              end if;                                
          end if;
                                                  
          -- Retorna as agências
          for rw_crapass_job in cr_crapass_job (pr_cdcooper => pr_cdcooper
                                               ,pr_dtmvtolt => vr_dtmvtolt
                                               ,pr_cdprogra => vr_cdprogra
                                               ,pr_qterro   => vr_qterro) loop
                                                      
            -- Montar o prefixo do código do programa para o jobname
            vr_jobname := vr_cdprogra ||'_'|| rw_crapass_job.cdagenci || '$';  

            -- Cadastra o programa paralelo
            gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                      ,pr_idprogra => LPAD(rw_crapass_job.cdagenci,3,'0') --> Utiliza a agência como id programa
                                      ,pr_des_erro => vr_dscritic);
                                        
            -- Testar saida com erro
            if vr_dscritic is not null then
              -- Levantar exceçao
              raise vr_exc_saida;
            end if;     
            
            -- Montar o bloco PLSQL que será executado
            -- Ou seja, executaremos a geração dos dados
            -- para a agência atual atraves de Job no banco
            vr_dsplsql := 'DECLARE' || chr(13) || --
                          '  wpr_stprogra NUMBER;' || chr(13) || --
                          '  wpr_infimsol NUMBER;' || chr(13) || --
                          '  wpr_cdcritic NUMBER;' || chr(13) || --
                          '  wpr_dscritic VARCHAR2(1500);' || chr(13) || --
                          'BEGIN' || chr(13) || --
                          '  pc_crps005( '|| pr_cdcooper || ',' ||
                                             '0'||','||
                                             rw_crapass_job.cdagenci || ',' ||
                                             vr_idparale || ',' ||
                                             ' wpr_stprogra, wpr_infimsol, wpr_cdcritic, wpr_dscritic);' ||
                          chr(13) || --
                          'END;'; --  

             -- Faz a chamada ao programa paralelo atraves de JOB
             gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper  --> Código da cooperativa
                                   ,pr_cdprogra => vr_cdprogra  --> Código do programa
                                   ,pr_dsplsql  => vr_dsplsql   --> Bloco PLSQL a executar
                                   ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                                   ,pr_interva  => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                                   ,pr_jobname  => vr_jobname   --> Nome randomico criado
                                   ,pr_des_erro => vr_dscritic);    
                                 
             -- Testar saida com erro
             if vr_dscritic is not null then 
                -- Levantar exceçao
                raise vr_exc_saida;
             end if;
               
             -- Chama rotina que irá pausar este processo controlador
             -- caso tenhamos excedido a quantidade de JOBS em execuçao
             gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                         ,pr_qtdproce => vr_qtdjobs --> Máximo de 10 jobs neste processo
                                         ,pr_des_erro => vr_dscritic);
             -- Testar saida com erro
             if  vr_dscritic is not null then 
               -- Levantar exceçao
               raise vr_exc_saida;
             end if;                                 
          end loop;
          
          -- Chama rotina de aguardo agora passando 0, para esperarmos
          -- até que todos os Jobs tenha finalizado seu processamento
          gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                      ,pr_qtdproce => 0
                                      ,pr_des_erro => vr_dscritic);
                                        
          -- Testar saida com erro
          if  vr_dscritic is not null then 
            -- Levantar exceçao
            raise vr_exc_saida;
          end if;                                  
                                        

          -- Verifica se algum job paralelo executou com erro
          vr_qterro := 0;
          vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper,
                                                        pr_cdprogra    => vr_cdprogra,
                                                        pr_dtmvtolt    => vr_dtmvtolt,
                                                        pr_tpagrupador => 1,
                                                        pr_nrexecucao  => 1);

          if vr_qterro > 0 then 
            vr_cdcritic := 0;
            vr_dscritic := 'Paralelismo possui job executado com erro. Verificar na tabela tbgen_batch_controle e tbgen_prglog';
            raise vr_exc_saida;
          end if;      
      else
        if pr_cdagenci <> 0 then
          vr_tpexecucao := 2;
        else
          vr_tpexecucao := 1;
        end if; 
          
        -- Grava controle de batch por agência
        gene0001.pc_grava_batch_controle(pr_cdcooper    => pr_cdcooper               -- Codigo da Cooperativa
                                        ,pr_cdprogra    => vr_cdprogra               -- Codigo do Programa
                                        ,pr_dtmvtolt    => vr_dtmvtolt               -- Data de Movimento
                                        ,pr_tpagrupador => 1                         -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                        ,pr_cdagrupador => pr_cdagenci               -- Codigo do agrupador conforme (tpagrupador)
                                        ,pr_cdrestart   => null                      -- Controle do registro de restart em caso de erro na execucao
                                        ,pr_nrexecucao  => 1                         -- Numero de identificacao da execucao do programa
                                        ,pr_idcontrole  => vr_idcontrole             -- ID de Controle
                                        ,pr_cdcritic    => pr_cdcritic               -- Codigo da critica
                                        ,pr_dscritic    => vr_dscritic              
                                         );   
        -- Testar saida com erro
        if  vr_dscritic is not null then 
          -- Levantar exceçao
          raise vr_exc_saida;
        end if;                                         

        
        if pr_cdagenci = 0 and
           pr_idparale = 0 then
            --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
            pc_log_programa(pr_dstiplog   => 'I',    
                            pr_cdprograma => vr_cdprogra,           
                            pr_cdcooper   => pr_cdcooper, 
                            pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                            pr_idprglog   => vr_idlog_ini_ger);
        end if;                  
        
        --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
        pc_log_programa(pr_dstiplog   => 'I',    
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                        pr_cdcooper   => pr_cdcooper, 
                        pr_tpexecucao => vr_tpexecucao,     -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par); 
                            
        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Início - cursor cr_crapage. AGENCIA: '||pr_cdagenci||' - INPROCES: '||vr_inproces||' - Horário: '||to_char(sysdate,'dd/mm/yyyy hh24:mi:ss'),
                        PR_IDPRGLOG           => vr_idlog_ini_par);  

       ------------------------------------------------------
       -- Abrir o cursor das agencias e utilizar a agencia no 
       -- filtro dos cursores abaixo 
       -- parâmetro incluído nos cursores abaixo (pr_cdagenci)
       -- projeto ligeirinho
       -------------------------------------------------------
       FOR rw_crapage IN cr_crapage (pr_cdcooper => pr_cdcooper) LOOP
         --Carregar tabela de memoria de telefones
         FOR rw_craptfc IN cr_craptfc (pr_cdcooper => pr_cdcooper,
                                       pr_cdagenci => rw_crapage.cdagenci) LOOP 
           --Montar o indice para o vetor de telefone
           vr_index_craptfc:= LPad(rw_craptfc.cdcooper,10,'0')||
                              LPad(rw_craptfc.nrdconta,10,'0')||
                              LPad(rw_craptfc.tptelefo,05,'0');
           vr_tab_craptfc(vr_index_craptfc).nrdddtfc:=  rw_craptfc.nrdddtfc;
           vr_tab_craptfc(vr_index_craptfc).nrtelefo:=  rw_craptfc.nrtelefo;
         END LOOP;

         --Carregar tabela de memoria de titulares da conta
         FOR rw_crapttl IN cr_crapttl (pr_cdcooper => pr_cdcooper,
                                       pr_idseqttl => 1,
                                       pr_cdagenci => rw_crapage.cdagenci) LOOP
           --Montar o indice para o vetor de telefone
           vr_index_crapttl:= LPad(rw_crapttl.cdcooper,10,'0')||
                              LPad(rw_crapttl.nrdconta,10,'0');
           vr_tab_crapttl(vr_index_crapttl).cdempres:=  rw_crapttl.cdempres;
           vr_tab_crapttl(vr_index_crapttl).cdturnos:=  rw_crapttl.cdturnos;
         END LOOP;

         --Carregar tabela de memoria de saldos investimento
         FOR rw_crapsli IN cr_crapsli (pr_cdcooper => pr_cdcooper,
                                       pr_dtrefere => vr_dtultdia,
                                       pr_cdagenci => rw_crapage.cdagenci) LOOP
           --Montar indice para selecionar os saldos de investimento
           vr_index_crapsli:= LPad(pr_cdcooper,10,'0')||LPad(rw_crapsli.nrdconta,10,'0');
           vr_tab_crapsli(vr_index_crapsli).vlsddisp:= rw_crapsli.vlsddisp;
         END LOOP;

         --Carregar tabela de memoria de contra-ordens
         FOR rw_crapcor IN cr_crapcor (pr_cdcooper => pr_cdcooper,
                                       pr_flgativo => 1,
                                       pr_cdagenci => rw_crapage.cdagenci) LOOP
           --Montar indice para selecionar os saldos de investimento
           vr_index_crapcor:= LPad(pr_cdcooper,10,'0')||LPad(rw_crapcor.nrdconta,10,'0');
           vr_tab_crapcor(vr_index_crapcor):= rw_crapcor.nrdconta;
         END LOOP;

         --Carregar tabela de memoria de emprestimos
         FOR rw_crapepr_conta IN cr_crapepr_conta (pr_cdcooper => pr_cdcooper,
                                                   pr_inliquid => 0,
                                                   pr_cdagenci => rw_crapage.cdagenci) LOOP
           --Montar indice para selecionar os saldos de investimento
           vr_index_crapepr:= LPad(pr_cdcooper,10,'0')||LPad(rw_crapepr_conta.nrdconta,10,'0');
           vr_tab_crapepr(vr_index_crapepr):= rw_crapepr_conta.nrdconta;
         END LOOP;

         --Carregar tabela de memória de saldos das contas
         FOR rw_crapsld_1 IN cr_crapsld (pr_cdcooper => pr_cdcooper,
                                         pr_cdagenci => rw_crapage.cdagenci) LOOP
           vr_tab_crapsld(rw_crapsld_1.nrdconta).vlsdbloq:= rw_crapsld_1.vlsdbloq;
           vr_tab_crapsld(rw_crapsld_1.nrdconta).vlsdblpr:= rw_crapsld_1.vlsdblpr;
           vr_tab_crapsld(rw_crapsld_1.nrdconta).vlsdblfp:= rw_crapsld_1.vlsdblfp;
           vr_tab_crapsld(rw_crapsld_1.nrdconta).vlsdchsl:= rw_crapsld_1.vlsdchsl;
           vr_tab_crapsld(rw_crapsld_1.nrdconta).vlsddisp:= rw_crapsld_1.vlsddisp;
           vr_tab_crapsld(rw_crapsld_1.nrdconta).vlipmfpg:= rw_crapsld_1.vlipmfpg;
           vr_tab_crapsld(rw_crapsld_1.nrdconta).vlipmfap:= rw_crapsld_1.vlipmfap;
           vr_tab_crapsld(rw_crapsld_1.nrdconta).dtdsdclq:= rw_crapsld_1.dtdsdclq;
           vr_tab_crapsld(rw_crapsld_1.nrdconta).qtddsdev:= rw_crapsld_1.qtddsdev;
           vr_tab_crapsld(rw_crapsld_1.nrdconta).vlsldtot:= rw_crapsld_1.vlsldtot;
           vr_tab_crapsld(rw_crapsld_1.nrdconta).vlblqjud:= rw_crapsld_1.vlblqjud;
           vr_tab_crapsld(rw_crapsld_1.nrdconta).vlblqprj:= rw_crapsld_1.vlblqprj;
         END LOOP;

         -- projeto ligeirinho abrir o cursor acima para filtar por agencia
         --Carregar tabela de memoria com as agencias
         --FOR rw_crapage IN cr_crapage (pr_cdcooper => pr_cdcooper) LOOP
           vr_tab_crapage(rw_crapage.cdagenci).cdagenci:= rw_crapage.cdagenci;
           vr_tab_crapage(rw_crapage.cdagenci).nmresage:= rw_crapage.nmresage;
       END LOOP;

       --Posicionar no primeiro registro
       vr_index_crapage:= vr_tab_crapage.FIRST;
       --Pesquisar todas as agencias
       WHILE vr_index_crapage IS NOT NULL LOOP

         --Atribuir codigo da agencia
         vr_cdagenci:= vr_tab_crapage(vr_index_crapage).cdagenci;
         --Atribuir nome resumido da agencia
         vr_nmresage:= vr_tab_crapage(vr_index_crapage).nmresage;

         --Zerar Código da empresa
         vr_cdempres:= 0;

         --Pesquisar todos os associados
         FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper
                                      ,pr_cdagenci => vr_cdagenci) LOOP

           --Incrementar a quantidade de associados ativos das agencias
           IF  rw_crapass.dtdemiss is null THEN
             IF vr_tab_crapass.EXISTS(vr_cdagenci) THEN
               --Incrementa contador de associados
               vr_tab_crapass(vr_cdagenci):= vr_tab_crapass(vr_cdagenci) + 1;
             ELSE
               vr_tab_crapass(vr_cdagenci):= 1;
             END IF;
           END IF;
           --Bloco necessário para controle de loop
           BEGIN
             --Flag gv006 recebe true
             vr_flggv006:= TRUE;

             --Se for pessoa fisica
             IF rw_crapass.inpessoa = 1 THEN
               --Montar indice para buscar titulares da conta
               vr_index_crapttl:= LPad(pr_cdcooper,10,'0')||LPad(rw_crapass.nrdconta,10,'0');
               --Selecionar informacoes dos titulares da conta
               IF vr_tab_crapttl.EXISTS(vr_index_crapttl) THEN
                 --Codigo da empresa recebe o codigo da empresa do titular da conta
                 vr_cdempres:= vr_tab_crapttl(vr_index_crapttl).cdempres;
                 --Registro de turnos recebe valor encontrado
                 rw_crapttl.cdturnos:= vr_tab_crapttl(vr_index_crapttl).cdturnos;
               ELSE
                 --Codigo da empresa recebe zero
                 vr_cdempres:= 0;
                 --Registro de turnos recebe zero
                 rw_crapttl.cdturnos:= 0;
               END IF;
             ELSE
               --Selecionar informacoes dos titulares da conta
               FOR rw_crapjur IN cr_crapjur (pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => rw_crapass.nrdconta) LOOP
                 --Codigo da empresa recebe o codigo da empresa do titular da conta
                 vr_cdempres:= rw_crapjur.cdempres;

                 /* No progress existe um problema pois estava mostrando os valores de turnos errados
                    para as pessoas físicas. A cada novo associado deveria ser realizado um release da crapttl.
                 */
                 --Registro de turnos recebe zero
                 rw_crapttl.cdturnos:= 0;
               END LOOP;
             END IF;

             -- Verificar a existencia de saldos
             IF NOT vr_tab_crapsld.EXISTS(rw_crapass.nrdconta) THEN
               -- Descricao do erro recebe mensagam da critica
               vr_cdcritic:= 10;
               -- Abortar programa
               RAISE vr_exc_saida;
             ELSE
               rw_crapsld.vlsdbloq:= vr_tab_crapsld(rw_crapass.nrdconta).vlsdbloq;
               rw_crapsld.vlsdblpr:= vr_tab_crapsld(rw_crapass.nrdconta).vlsdblpr;
               rw_crapsld.vlsdblfp:= vr_tab_crapsld(rw_crapass.nrdconta).vlsdblfp;
               rw_crapsld.vlsdchsl:= vr_tab_crapsld(rw_crapass.nrdconta).vlsdchsl;
               rw_crapsld.vlsddisp:= vr_tab_crapsld(rw_crapass.nrdconta).vlsddisp;
               rw_crapsld.vlipmfpg:= vr_tab_crapsld(rw_crapass.nrdconta).vlipmfpg;
               rw_crapsld.vlipmfap:= vr_tab_crapsld(rw_crapass.nrdconta).vlipmfap;
               rw_crapsld.dtdsdclq:= vr_tab_crapsld(rw_crapass.nrdconta).dtdsdclq;
               rw_crapsld.qtddsdev:= vr_tab_crapsld(rw_crapass.nrdconta).qtddsdev;
               rw_crapsld.vlsldtot:= vr_tab_crapsld(rw_crapass.nrdconta).vlsldtot;
               rw_crapsld.vlblqjud:= vr_tab_crapsld(rw_crapass.nrdconta).vlblqjud;
               rw_crapsld.vlblqprj:= vr_tab_crapsld(rw_crapass.nrdconta).vlblqprj;
               
             END IF;

             --Executar rotina gravar movimentos CI
             pc_grava_movimentos_ci (pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => rw_crapass.cdagenci
                                    ,pr_nrdconta => rw_crapass.nrdconta
                                    ,pr_cdempres => vr_cdempres
                                    ,pr_nmprimtl => rw_crapass.nmprimtl
                                    ,pr_inpessoa => rw_crapass.inpessoa
                                    ,pr_cdturnos => rw_crapttl.cdturnos
                                    ,pr_des_erro => vr_dscritic);
             -- Se ocorreu erro
             IF vr_dscritic IS NOT NULL THEN
               -- Sair do programa
               RAISE vr_exc_saida;
             END IF;
             -- Incluir nome do módulo logado
             GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS005' ,pr_action => NULL);

             /* Verifica se ha micro-credito  */
             -- Verifica se os valores estao zerados
             IF Nvl(rw_crapsld.vlsdbloq,0) = 0 AND  --> Se o valor bloqueado
                Nvl(rw_crapsld.vlblqjud,0) = 0 AND  --> Se o valor bloqueado Judicial
                Nvl(rw_crapsld.vlsdblpr,0) = 0 AND  --> Bloqueado praca 
                Nvl(rw_crapsld.vlsdblfp,0) = 0 AND  --> Bloqueado fora praca
                Nvl(rw_crapsld.vlsdchsl,0) = 0 AND  --> Cheque salario
                Nvl(rw_crapsld.vlsddisp,0) = 0 AND  --> Saldo disponivel
                Nvl(rw_crapass.vllimcre,0) = 0 THEN --> Limite for zero
               --Montar indice para selecionar emprestimos
               vr_index_crapepr:= LPad(pr_cdcooper,10,'0')||LPad(rw_crapass.nrdconta,10,'0');
               --Verificar se existe emprestimos
               IF NOT vr_tab_crapepr.EXISTS(vr_index_crapepr) THEN
                 --Ir para proximo registro do loop
                 RAISE vr_exc_pula;
               END IF;
               --Atribuir false para variavel
               vr_flggv006:= FALSE;
             END IF;

             --Atribuir false para flag demitido
             vr_flgdemit:= FALSE;

             --Se o mes do movimento atual <> mes do proximo movimento
             IF to_char(vr_dtmvtolt,'MM') <> To_Char(vr_dtmvtopr,'MM') THEN
               --Atribuir false para flag demitido
               vr_flgdemit:= FALSE;
             ELSIF (rw_crapass.dtdemiss + 90) < vr_dtmvtolt AND
                 Nvl(rw_crapass.vllimcre,0)  = 0 AND
                 Nvl(rw_crapsld.vlsddisp,0) >= 0 AND
                 Nvl(rw_crapsld.vlsdchsl,0) >= 0 AND
                 Nvl(rw_crapsld.vlsdbloq,0) >= 0 AND
                 Nvl(rw_crapsld.vlsdblpr,0) >= 0 AND
                 Nvl(rw_crapsld.vlsdblfp,0) >= 0 THEN
               --Se a data de demissao + 90 dias for menor data do movimento atual e o limite de credito = 0 e
               --saldo disponivel, cheque salario, saldo bloqueado, bloqueado praca e bloqueado fora praca > 0
               --Verificar se a conta possui lancamentos
               OPEN cr_craplcm (pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => rw_crapass.nrdconta);
               --Posicionar no proximo registro
               FETCH cr_craplcm INTO rw_craplcm;
               --Se nao encontrar
               IF cr_craplcm%NOTFOUND THEN
                 --Atribuir false para flag demitido
                 vr_flgdemit:= TRUE;
               END IF;
               --Fechar Cursor
               CLOSE cr_craplcm;
             END IF;

             --Montar indice para selecionar contra-ordem
             vr_index_crapcor:= LPad(pr_cdcooper,10,'0')||LPad(rw_crapass.nrdconta,10,'0');
             --verificar se existe contra-ordem
             IF vr_tab_crapcor.EXISTS(vr_index_crapcor) THEN
               --Descricao da conta recebe * concatenado situacao da conta concatenada com o tipo da conta
               vr_rel_dsdacstp:= '*' || To_Char(rw_crapass.cdsitdct,'fm0')||To_Char(rw_crapass.cdtipcta,'fm00');
             ELSE
               --Descricao da conta recebe situacao da conta concatenada com o tipo da conta
               vr_rel_dsdacstp:= ' ' || To_Char(rw_crapass.cdsitdct,'fm0')||To_Char(rw_crapass.cdtipcta,'fm00');
             END IF;

             --Formatar o cpf/cnpj do associado
             vr_rel_nrcpfcgc:= gene0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc,rw_crapass.inpessoa);

             --Montar os telefones do associado
             vr_rel_nrdofone:= fn_concatena_fones (pr_cdcooper => pr_cdcooper
                                                  ,pr_nrdconta => rw_crapass.nrdconta
                                                  ,pr_inpessoa => rw_crapass.inpessoa);

             --Valor saldo bloqueado total recebe bloqueado + bloqueado praca + bloqueado fora praca
             vr_rel_vlsdbltl:= Nvl(rw_crapsld.vlsdbloq,0) + Nvl(rw_crapsld.vlsdblpr,0) + Nvl(rw_crapsld.vlsdblfp,0);
             --Valor do saldo total recebe saldo disponivel + saldo bloqueado total + saldo cheque salario
             vr_rel_vlstotal:= Nvl(rw_crapsld.vlsddisp,0) + vr_rel_vlsdbltl + Nvl(rw_crapsld.vlsdchsl,0);
             if rw_crapass.inprejuz= 1 then
               vr_rel_vlstotal_006:= Nvl(rw_crapsld.vlblqprj,0) + vr_rel_vlsdbltl + Nvl(rw_crapsld.vlsdchsl,0);
               vr_rel_vlsddisp_006:= Nvl(rw_crapsld.vlblqprj,0);
             else
               vr_rel_vlstotal_006:= Nvl(rw_crapsld.vlsddisp,0) + vr_rel_vlsdbltl + Nvl(rw_crapsld.vlsdchsl,0);
               vr_rel_vlsddisp_006:= Nvl(rw_crapsld.vlsddisp,0);
             end if;             
             --vr_rel_vlstotal:= decode(rw_crapass.inprejuz,1,nvl(rw_crapsld.vlblqprj,0)
			       --                                        ,Nvl(rw_crapsld.vlsddisp,0) ) 
			       --                                    + vr_rel_vlsdbltl + Nvl(rw_crapsld.vlsdchsl,0);
             --aqui mario
             --vr_rel_vlstotal_006:= decode(rw_crapass.inprejuz,1,nvl(rw_crapsld.vlblqprj,0)
             --                                                 ,Nvl(rw_crapsld.vlsddisp,0) 
			       --                                      + vr_rel_vlsdbltl + Nvl(rw_crapsld.vlsdchsl,0);
             
             --vr_rel_vlsddisp_006:= decode(rw_crapass.inprejuz,1,nvl(rw_crapsld.vlblqprj,0)
			       --                                            ,Nvl(rw_crapsld.vlsddisp,0) );
             --Valor Maximo saque recebe valor disponivel - valor ipmf a pagar - valor ipmf apurado
             vr_vlsaqmax:= Nvl(rw_crapsld.vlsddisp,0) - Nvl(rw_crapsld.vlipmfpg,0) - Nvl(rw_crapsld.vlipmfap,0);
             --Valor Bloqueado Judicialmente
             --vr_rel_vlblqjud:= rw_crapsld.vlblqjud;
             --Se o valor maximo saque for negativo
             IF vr_vlsaqmax <= 0 THEN
               --Valor Maximo saque recebe 0
               vr_vlsaqmax:= 0;
             ELSE
               --Valor Maximo saque recebe valor maximo saque * reducao cpmf
               vr_vlsaqmax:= Trunc(vr_vlsaqmax * vr_txrdcpmf,2);
             END IF;

             --Guardar os saldos totais dos associados demitidos
             IF vr_flgdemit THEN
               -- Verifica se existe o valor
               IF vr_tab_dem_agpsdmax.EXISTS(rw_crapass.cdagenci) THEN
                 --Acumular Saldo maximo
                 vr_tab_dem_agpsdmax(rw_crapass.cdagenci):= vr_tab_dem_agpsdmax(rw_crapass.cdagenci) + Nvl(vr_vlsaqmax,0);
               ELSE
                 -- Atribui zero
                 vr_tab_dem_agpsdmax(rw_crapass.cdagenci) := 0;
               END IF;
               -- Verifica se existe o valor
               IF vr_tab_dem_agpsddis.EXISTS(rw_crapass.cdagenci) THEN
                 --Acumular Saldo Disponivel
                 vr_tab_dem_agpsddis(rw_crapass.cdagenci):= vr_tab_dem_agpsddis(rw_crapass.cdagenci) + Nvl(rw_crapsld.vlsddisp,0);
               ELSE
                 vr_tab_dem_agpsddis(rw_crapass.cdagenci):= 0;
               END IF;
               -- Verifica se existe o valor
               IF vr_tab_dem_agpvllim.EXISTS(rw_crapass.cdagenci) THEN
                 --Acumular Valor Limite
                 vr_tab_dem_agpvllim(rw_crapass.cdagenci):= vr_tab_dem_agpvllim(rw_crapass.cdagenci) + Nvl(rw_crapass.vllimcre,0);
               ELSE
                 vr_tab_dem_agpvllim(rw_crapass.cdagenci):= 0;
               END IF;
               -- Verifica se existe o valor
               IF vr_tab_dem_agpsdbtl.EXISTS(rw_crapass.cdagenci) THEN
                 --Acumular Saldo Bloqueado total
                 vr_tab_dem_agpsdbtl(rw_crapass.cdagenci):= vr_tab_dem_agpsdbtl(rw_crapass.cdagenci) + Nvl(vr_rel_vlsdbltl,0);
               ELSE
                 vr_tab_dem_agpsdbtl(rw_crapass.cdagenci):= 0;
               END IF;
               -- Verifica se existe o valor
               IF vr_tab_dem_agpsdchs.EXISTS(rw_crapass.cdagenci) THEN
                 --Acumular Saldo Cheque Salario Liquido
                 vr_tab_dem_agpsdchs(rw_crapass.cdagenci):= vr_tab_dem_agpsdchs(rw_crapass.cdagenci) + Nvl(rw_crapsld.vlsdchsl,0);
               ELSE
                 vr_tab_dem_agpsdchs(rw_crapass.cdagenci):= 0;
               END IF;
               -- Verifica se existe o valor
               IF vr_tab_dem_agpsdstl.EXISTS(rw_crapass.cdagenci) THEN
                 --Acumular Saldo Total
                 vr_tab_dem_agpsdstl(rw_crapass.cdagenci):= vr_tab_dem_agpsdstl(rw_crapass.cdagenci) + Nvl(vr_rel_vlstotal,0);
               ELSE
                 vr_tab_dem_agpsdstl(rw_crapass.cdagenci):= 0;
               END IF;
               -- Verifica se existe o valor
               IF vr_tab_dem_agpvlbjd.EXISTS(rw_crapass.cdagenci) THEN
                 --Acumular Saldo Bloqueado juridicamente
                 vr_tab_dem_agpvlbjd(rw_crapass.cdagenci):= vr_tab_dem_agpvlbjd(rw_crapass.cdagenci) + Nvl(rw_crapsld.vlblqjud,0);
               ELSE
                 vr_tab_dem_agpvlbjd(rw_crapass.cdagenci):= 0;
               END IF;
             ELSE
               --Se gv006 for verdadeiro
               IF vr_flggv006 THEN

                 --Encontrar proximo registro agencia:99999 + conta:9999999999
                 vr_index_crat006:= lpad(rw_crapass.cdagenci,5,'0')||lpad(rw_crapass.nrdconta,10,'0');
                 --Criar registro na crat006
                 vr_tab_crat006(vr_index_crat006).cdagenci:= rw_crapass.cdagenci;
                 vr_tab_crat006(vr_index_crat006).nrdconta:= rw_crapass.nrdconta;
                 vr_tab_crat006(vr_index_crat006).dsdacstp:= vr_rel_dsdacstp;
                 vr_tab_crat006(vr_index_crat006).vlsaqmax:= vr_vlsaqmax;
               --vr_tab_crat006(vr_index_crat006).vlsddisp:= rw_crapsld.vlsddisp;
                 vr_tab_crat006(vr_index_crat006).vlsddisp:= vr_rel_vlsddisp_006;
                 vr_tab_crat006(vr_index_crat006).vllimcre:= rw_crapass.vllimcre;
                 vr_tab_crat006(vr_index_crat006).vlsdbltl:= vr_rel_vlsdbltl;
                 vr_tab_crat006(vr_index_crat006).vlsdchsl:= rw_crapsld.vlsdchsl;
                 vr_tab_crat006(vr_index_crat006).vlblqjud:= rw_crapsld.vlblqjud;
                 vr_tab_crat006(vr_index_crat006).vlstotal:= vr_rel_vlstotal_006;
                 --Se a data saldo liquido nao for nulo
                 IF rw_crapsld.dtdsdclq IS NOT NULL THEN
                   vr_tab_crat006(vr_index_crat006).nmprimtl:=  'CL - '|| rw_crapass.nmprimtl;
                 ELSE
                   vr_tab_crat006(vr_index_crat006).nmprimtl:=  rw_crapass.nmprimtl;
                 END IF;

                 --Se for Cecred
                 IF pr_cdcooper = 3 THEN
                   --Encontrar proximo registro
                   vr_index:= vr_tab_gn006.COUNT+1;
                   --Criar registro na crat006
                   vr_tab_gn006(vr_index).cdagenci:= rw_crapass.cdagenci;
                   vr_tab_gn006(vr_index).nrdconta:= rw_crapass.nrdconta;
                   vr_tab_gn006(vr_index).vlstotal:= vr_rel_vlstotal;

                 END IF;
               END IF;
             END IF;


             /*  Resumo dos Maiores depositantes  */

             --Se o saldo total for maior ou igual valor maior deposito
             IF vr_rel_vlstotal >= vr_rel_vlmaidep THEN
               --Montar Indice para proximo registro: Agencia (99999) + sequencial (99999999999999999)
               --Esse indice deve ser montado de forma que os maiores lancamentos sejam inseridos primeiro na tabela de memória,
               --respeitando-se a ordem da agencia.
               vr_index_crat055:= lpad(rw_crapass.cdagenci,5,'0')||
                                  LPad(99999999999999999999 - (rw_crapsld.vlsldtot * 100),20,'0');
               --Criar registro na crat055
               vr_tab_crat055(vr_index_crat055).cdagenci:= rw_crapass.cdagenci;
               vr_tab_crat055(vr_index_crat055).nrdconta:= rw_crapass.nrdconta;
               vr_tab_crat055(vr_index_crat055).dsdacstp:= vr_rel_dsdacstp;
               vr_tab_crat055(vr_index_crat055).nmprimtl:= rw_crapass.nmprimtl;
               vr_tab_crat055(vr_index_crat055).nrcpfcgc:= vr_rel_nrcpfcgc;
               vr_tab_crat055(vr_index_crat055).vllimcre:= rw_crapass.vllimcre;
               vr_tab_crat055(vr_index_crat055).vlsddisp:= rw_crapsld.vlsddisp;
               vr_tab_crat055(vr_index_crat055).vlsdbltl:= vr_rel_vlsdbltl;
               vr_tab_crat055(vr_index_crat055).vlstotal:= vr_rel_vlstotal;
               vr_tab_crat055(vr_index_crat055).vlindice:= vr_index_crat055; -- projeto ligeirinho - guardar o indice para utilizar na copia da tabela wrk para a tabela de memoria
             END IF;

             /*  Resumo dos Creditos em Liquidacao  */

             --Se a data do saldo liquido não for nula
             IF rw_crapsld.dtdsdclq IS NOT NULL THEN
               --Montar indice para proximo registro agencia:99999 + conta:9999999999
               vr_index_crat030:= lpad(rw_crapass.cdagenci,5,'0')||lpad(rw_crapass.nrdconta,10,'0');
               --Criar registro na crat030
               vr_tab_crat030(vr_index_crat030).cdagenci:= rw_crapass.cdagenci;
               vr_tab_crat030(vr_index_crat030).nrdconta:= rw_crapass.nrdconta;
               vr_tab_crat030(vr_index_crat030).nmprimtl:= rw_crapass.nmprimtl;
               vr_tab_crat030(vr_index_crat030).vllimcre:= rw_crapass.vllimcre;
               vr_tab_crat030(vr_index_crat030).vlsdbltl:= vr_rel_vlsdbltl;
               vr_tab_crat030(vr_index_crat030).vlstotal:= vr_rel_vlstotal;
               vr_tab_crat030(vr_index_crat030).vlsddisp:= rw_crapsld.vlsddisp;
               vr_tab_crat030(vr_index_crat030).qtddsdev:= rw_crapsld.qtddsdev;
               vr_tab_crat030(vr_index_crat030).dtdsdclq:= rw_crapsld.dtdsdclq;
               vr_tab_crat030(vr_index_crat030).vlsdchsl:= rw_crapsld.vlsdchsl;

               --Se o saldo total for negativo
               IF vr_rel_vlstotal_006 < 0 THEN
                 --Valor adiantamentos em credito em liquidacao recebe saldo total + limite credito
                 --P450 - vr_tab_rel_vladiclq(rw_crapass.inpessoa):= vr_tab_rel_vladiclq(rw_crapass.inpessoa) + (nvl(vr_rel_vlstotal,0) + nvl(rw_crapass.vllimcre,0));
                 vr_tab_rel_vladiclq(rw_crapass.inpessoa):= vr_tab_rel_vladiclq(rw_crapass.inpessoa) + 
                                                            --> nao deve utilizar o valor bloqueado prejuizo no adiantamento
                                                            ((nvl(vr_rel_vlstotal_006,0) - nvl(rw_crapsld.vlblqprj,0)) + 
                                                            nvl(rw_crapass.vllimcre,0));
                 
               ELSE
                 --Valor adiantamentos em credito em liquidacao recebe saldo total - limite credito
                 --P450-- vr_tab_rel_vladiclq(rw_crapass.inpessoa):= vr_tab_rel_vladiclq(rw_crapass.inpessoa) + (nvl(vr_rel_vlstotal,0) - nvl(rw_crapass.vllimcre,0));
                 vr_tab_rel_vladiclq(rw_crapass.inpessoa):= vr_tab_rel_vladiclq(rw_crapass.inpessoa) + 
                                                            --> nao deve utilizar o valor bloqueado prejuizo no adiantamento
                                                            ((nvl(vr_rel_vlstotal_006,0) - nvl(rw_crapsld.vlblqprj,0)) -
                                                             nvl(rw_crapass.vllimcre,0));
               END IF;

               --Se for pessoa fisica ou juridica
               IF rw_crapass.inpessoa <= 2 THEN
                 --Verificar se é conta do bndes
                 IF vr_tab_cta_bndes.EXISTS(rw_crapass.nrdconta) THEN
                   --Se o valor total for negativo
                   IF vr_rel_vlstotal < 0 THEN
                     --Valor Deposito a vista recebe valor saldo total + limite credito
                     vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs:= nvl(vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs,0) +
                                                                      ((nvl(vr_rel_vlstotal,0) + nvl(rw_crapass.vllimcre,0)) * -1);
                   ELSE
                     --Valor Deposito a vista recebe valor saldo total - limite credito
                     vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs:= nvl(vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs,0) +
                                                                      ((nvl(vr_rel_vlstotal,0) - nvl(rw_crapass.vllimcre,0)) * -1);
                   END IF;
                 ELSE
                   --Inserir a conta
                   vr_tab_cta_bndes(rw_crapass.nrdconta).nrdconta:= rw_crapass.nrdconta;
                   --Se o valor do saldo total for negativo
                   IF vr_rel_vlstotal < 0 THEN
                     --Valor Deposito a vista recebe valor saldo total + limite credito
                     vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs:= ((nvl(vr_rel_vlstotal,0) + nvl(rw_crapass.vllimcre,0)) * -1);
                   ELSE
                     --Valor Deposito a vista recebe valor saldo total - limite credito
                     vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs:= ((nvl(vr_rel_vlstotal,0) - nvl(rw_crapass.vllimcre,0)) * -1);
                   END IF;
                 END IF;
               END IF; --rw_crapass.inpessoa <= 2

               --Verificar se existe gn099
               IF vr_tab_gn099.EXISTS(vr_cdagenci) THEN
                 --Se o valor do saldo total for negativo
                 IF vr_rel_vlstotal < 0 THEN
                   --Adiantamento deposito em conta corrente recebe saldo total + limite credito
                   vr_tab_gn099(vr_cdagenci).vladiclq:= vr_tab_gn099(vr_cdagenci).vladiclq +
                                                               (nvl(vr_rel_vlstotal,0) + nvl(rw_crapass.vllimcre,0));
                 ELSE
                   --Adiantamento deposito em conta corrente recebe saldo total - limite credito
                   vr_tab_gn099(vr_cdagenci).vladiclq:= vr_tab_gn099(vr_cdagenci).vladiclq +
                                                               (nvl(vr_rel_vlstotal,0) - nvl(rw_crapass.vllimcre,0));
                 END IF;
               ELSE
                 --Criar conta no vetor de memoria
                 vr_tab_gn099(vr_cdagenci).cdagenci:= vr_cdagenci;
                 vr_tab_gn099(vr_cdagenci).vlsutili:= 0;
                 vr_tab_gn099(vr_cdagenci).vlsaqblq:= 0;
                 vr_tab_gn099(vr_cdagenci).vlsadian:= 0;
                 --Se o valor do saldo total for negativo
                 IF vr_rel_vlstotal < 0 THEN
                   --Adiantamento deposito em conta corrente recebe saldo total + limite credito
                   vr_tab_gn099(vr_cdagenci).vladiclq:= (vr_rel_vlstotal + nvl(rw_crapass.vllimcre,0));
                 ELSE
                   --Adiantamento deposito em conta corrente recebe saldo total - limite credito
                   vr_tab_gn099(vr_cdagenci).vladiclq:= (vr_rel_vlstotal - nvl(rw_crapass.vllimcre,0));
                 END IF;

               END IF;

               /* Totais separados por tipo de pessoa - crrl006 Tipo 4 - consta que a pessoa esta em CL */
               vr_tab_rel_agpsdmax(4):= vr_tab_rel_agpsdmax(4) + nvl(vr_vlsaqmax,0);
               --P450--ODIRLEI --vr_tab_rel_agpsddis(4):= vr_tab_rel_agpsddis(4) + nvl(rw_crapsld.vlsddisp,0);
               vr_tab_rel_agpsddis(4):= vr_tab_rel_agpsddis(4) + nvl(vr_rel_vlsddisp_006,0);
               
               vr_tab_rel_agpvllim(4):= vr_tab_rel_agpvllim(4) + nvl(rw_crapass.vllimcre,0);
               vr_tab_rel_agpsdbtl(4):= vr_tab_rel_agpsdbtl(4) + nvl(vr_rel_vlsdbltl,0);
               vr_tab_rel_agpsdchs(4):= vr_tab_rel_agpsdchs(4) + nvl(rw_crapsld.vlsdchsl,0);
               --> PRJ450 - odirlei vr_tab_rel_agpsdstl(4):= vr_tab_rel_agpsdstl(4) + nvl(vr_rel_vlstotal,0);
               --> Para o relatorio crrl006 nao deve considerar saldos de contas transferidas para prejuizo
               vr_tab_rel_agpsdstl(4):= vr_tab_rel_agpsdstl(4) + nvl(vr_rel_vlstotal_006,0);
               
               vr_tab_rel_agpvlbjd(4):= vr_tab_rel_agpvlbjd(4) + Nvl(rw_crapsld.vlblqjud,0);

               --Diminuir o valor do limite de credito do valor utilizado do saldo
               vr_tab_rel_vlsutili(rw_crapass.inpessoa):= vr_tab_rel_vlsutili(rw_crapass.inpessoa) - nvl(rw_crapass.vllimcre,0);

               --Verificar se é conta do bndes
               IF vr_tab_cta_bndes.EXISTS(rw_crapass.nrdconta) THEN
                 --Acrescentar ao Valor cheque especial o valor do limite credito
                 vr_tab_cta_bndes(rw_crapass.nrdconta).vlchqesp:= nvl(vr_tab_cta_bndes(rw_crapass.nrdconta).vlchqesp,0) +
                                                                  nvl(rw_crapass.vllimcre,0);
               ELSE
                 vr_tab_cta_bndes(rw_crapass.nrdconta).nrdconta:= rw_crapass.nrdconta;
                 --Valor cheque especial recebe o limite de credito
                 vr_tab_cta_bndes(rw_crapass.nrdconta).vlchqesp:= nvl(rw_crapass.vllimcre,0);
               END IF;

               --Se for pessoa fisica ou juridica
               IF rw_crapass.inpessoa <= 2 THEN
                 --Verificar se é conta do bndes
                 IF vr_tab_cta_bndes.EXISTS(rw_crapass.nrdconta) THEN
                   --Acumular no Valor Deposito a vista o limite credito
                   vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs:= nvl(vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs,0) +
                                                                    nvl(rw_crapass.vllimcre,0);
                 ELSE
                   vr_tab_cta_bndes(rw_crapass.nrdconta).nrdconta:= rw_crapass.nrdconta;
                   --Valor Deposito a vista recebe valor do limite credito
                   vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs:= rw_crapass.vllimcre;
                 END IF;
               END IF; --rw_crapass.inpessoa <= 2


               --Verificar se existe gn099
               IF vr_tab_gn099.EXISTS(vr_cdagenci) THEN
                 --Diminuir do Total limite cheque especial o valor do limite de credito
                 vr_tab_gn099(vr_cdagenci).vlsutili:= vr_tab_gn099(vr_cdagenci).vlsutili - nvl(rw_crapass.vllimcre,0);
               ELSE
                 --Criar conta no vetor de memoria
                 vr_tab_gn099(vr_cdagenci).cdagenci:= vr_cdagenci;
                 vr_tab_gn099(vr_cdagenci).vlsutili:= rw_crapass.vllimcre * -1;
                 vr_tab_gn099(vr_cdagenci).vlsaqblq:= 0;
                 vr_tab_gn099(vr_cdagenci).vlsadian:= 0;
                 vr_tab_gn099(vr_cdagenci).vladiclq:= 0;
               END IF;

             ELSE

               /*   Totais separados por tipo de pessoa - crrl006  */
               vr_tab_rel_agpsdmax(rw_crapass.inpessoa):= vr_tab_rel_agpsdmax(rw_crapass.inpessoa) + nvl(vr_vlsaqmax,0);
               --P450 -- vr_tab_rel_agpsddis(rw_crapass.inpessoa):= vr_tab_rel_agpsddis(rw_crapass.inpessoa) + nvl(rw_crapsld.vlsddisp,0);
               vr_tab_rel_agpsddis(rw_crapass.inpessoa):= vr_tab_rel_agpsddis(rw_crapass.inpessoa) + nvl(vr_rel_vlsddisp_006,0);
               
               vr_tab_rel_agpvllim(rw_crapass.inpessoa):= vr_tab_rel_agpvllim(rw_crapass.inpessoa) + nvl(rw_crapass.vllimcre,0);
               vr_tab_rel_agpsdbtl(rw_crapass.inpessoa):= vr_tab_rel_agpsdbtl(rw_crapass.inpessoa) + nvl(vr_rel_vlsdbltl,0);
               vr_tab_rel_agpsdchs(rw_crapass.inpessoa):= vr_tab_rel_agpsdchs(rw_crapass.inpessoa) + nvl(rw_crapsld.vlsdchsl,0);
               vr_tab_rel_agpsdstl(rw_crapass.inpessoa):= vr_tab_rel_agpsdstl(rw_crapass.inpessoa) + nvl(vr_rel_vlstotal,0);
               vr_tab_rel_agpvlbjd(rw_crapass.inpessoa):= vr_tab_rel_agpvlbjd(rw_crapass.inpessoa) + nvl(rw_crapsld.vlblqjud,0);
             END IF;

             --Valor bloqueado recebe bloqueado praca + bloqueado fora praca + valor bloqueado
             vr_vlbloque:= Nvl(rw_crapsld.vlsdblpr,0) + Nvl(rw_crapsld.vlsdblfp,0) + Nvl(rw_crapsld.vlsdbloq,0);
             --Acumular Valor bloqueado no vetor de valor bloqueado
             vr_tab_rel_vlbloque(rw_crapass.inpessoa):= vr_tab_rel_vlbloque(rw_crapass.inpessoa) + nvl(vr_vlbloque,0);
             --Se o saldo disponivel for maior zero
             IF rw_crapsld.vlsddisp > 0 THEN
               --Acumular valor disponivel no vetor de valor disponivel
               vr_tab_rel_vldispos(rw_crapass.inpessoa):= vr_tab_rel_vldispos(rw_crapass.inpessoa) + nvl(rw_crapsld.vlsddisp,0);
             END IF;
             --Acumular no valor saldo liquido o valor do saldo total
             --> P450 - vr_tab_rel_vlsldliq(rw_crapass.inpessoa):= vr_tab_rel_vlsldliq(rw_crapass.inpessoa) + nvl(vr_rel_vlstotal,0);
             vr_tab_rel_vlsldliq(rw_crapass.inpessoa):= vr_tab_rel_vlsldliq(rw_crapass.inpessoa) + nvl(vr_rel_vlstotal_006,0);
             --Se o saldo disponivel for negativo
             IF rw_crapsld.vlsddisp < 0 THEN
               --Acumular valor disponivel no vetor de valor disponivel negativo
               vr_tab_rel_vldisneg(rw_crapass.inpessoa):= vr_tab_rel_vldisneg(rw_crapass.inpessoa) + nvl(rw_crapsld.vlsddisp,0);
             END IF;

             --Se for pessoa fisica ou juridica
             IF rw_crapass.inpessoa <= 2 THEN
               --Verificar se é conta do bndes
               IF vr_tab_cta_bndes.EXISTS(rw_crapass.nrdconta) THEN
                 --Acumular no Valor Deposito a vista o valor do saldo total
                 vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs:= nvl(vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs,0) +
                                                                  nvl(vr_rel_vlstotal,0);
               ELSE
                 vr_tab_cta_bndes(rw_crapass.nrdconta).nrdconta:= rw_crapass.nrdconta;
                 --Valor Deposito a vista recebe valor do saldo total
                 vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs:= nvl(vr_rel_vlstotal,0);
               END IF;
             END IF; --rw_crapass.inpessoa <= 2

             --Se valor bloqueado judicialmente maior zero
             IF rw_crapsld.vlblqjud > 0 THEN
               vr_tab_rel_vlblqjud(rw_crapass.inpessoa):= vr_tab_rel_vlblqjud(rw_crapass.inpessoa) + Nvl(rw_crapsld.vlblqjud,0);
             END IF;

             --Se valor saldo disponivel + valor saldo cheque salario for negativo
             IF (rw_crapsld.vlsddisp + rw_crapsld.vlsdchsl) < 0 THEN
               --Se o saldo disponivel + saldo cheque salario + limite de credito for > 0
               IF (rw_crapsld.vlsddisp + rw_crapsld.vlsdchsl + rw_crapass.vllimcre) > 0 THEN
                 --Acumular no Total utilizado o saldo disponivel + saldo cheque salario
                 vr_tot_vlutiliz:= nvl(vr_tot_vlutiliz,0) + nvl(rw_crapsld.vlsddisp,0) + nvl(rw_crapsld.vlsdchsl,0);
                 --Acumular no vetor do saldo utilizado o saldo disponivel + saldo cheque salario
                 vr_tab_rel_vlsutili(rw_crapass.inpessoa):= vr_tab_rel_vlsutili(rw_crapass.inpessoa) +
                                                            nvl(vr_rel_vlsddisp_006,0) + nvl(rw_crapsld.vlsdchsl,0);
                 --Verificar se é conta do bndes
                 IF vr_tab_cta_bndes.EXISTS(rw_crapass.nrdconta) THEN
                   --Acumular no Valor Cheque Especial o valor do saldo disponivel + saldo cheque salario
                   vr_tab_cta_bndes(rw_crapass.nrdconta).vlchqesp:= nvl(vr_tab_cta_bndes(rw_crapass.nrdconta).vlchqesp,0) +
                                                                    ((nvl(rw_crapsld.vlsddisp,0) + nvl(rw_crapsld.vlsdchsl,0)) * -1);
                 ELSE
                   vr_tab_cta_bndes(rw_crapass.nrdconta).nrdconta:= rw_crapass.nrdconta;
                   --Valor Cheque Especial  recebe valor do saldo disponivel + saldo cheque salario
                   vr_tab_cta_bndes(rw_crapass.nrdconta).vlchqesp:= ((nvl(rw_crapsld.vlsddisp,0) + nvl(rw_crapsld.vlsdchsl,0)) * -1);
                 END IF;

                 --Se for pessoa fisica ou juridica
                 IF rw_crapass.inpessoa <= 2 THEN
                   --Verificar se é conta do bndes
                   IF vr_tab_cta_bndes.EXISTS(rw_crapass.nrdconta) THEN
                     --Acumular no Valor Deposito a vista o valor do saldo disponivel + saldo cheque salario
                     vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs:= nvl(vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs,0) +
                                                                      ((nvl(rw_crapsld.vlsddisp,0) + nvl(rw_crapsld.vlsdchsl,0)) * -1);
                   ELSE
                     vr_tab_cta_bndes(rw_crapass.nrdconta).nrdconta:= rw_crapass.nrdconta;
                     --Valor Deposito a vista recebe valor do saldo total
                     vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs:= ((nvl(rw_crapsld.vlsddisp,0) + nvl(rw_crapsld.vlsdchsl,0)) * -1);
                   END IF;
                 END IF; --rw_crapass.inpessoa <= 2

                 --Verificar se existe gn099
                 IF vr_tab_gn099.EXISTS(vr_cdagenci) THEN
                   --Acumular no valor utilizado o valor do saldo disponivel + saldo cheque salario
                   vr_tab_gn099(vr_cdagenci).vlsutili:= vr_tab_gn099(vr_cdagenci).vlsutili +
                                                                (nvl(rw_crapsld.vlsddisp,0) + nvl(rw_crapsld.vlsdchsl,0));
                 ELSE
                   --Criar conta no vetor de memoria
                   vr_tab_gn099(vr_cdagenci).cdagenci:= vr_cdagenci;
                   vr_tab_gn099(vr_cdagenci).vlsutili:= (nvl(rw_crapsld.vlsddisp,0) + nvl(rw_crapsld.vlsdchsl,0));
                   vr_tab_gn099(vr_cdagenci).vlsaqblq:= 0;
                   vr_tab_gn099(vr_cdagenci).vlsadian:= 0;
                   vr_tab_gn099(vr_cdagenci).vladiclq:= 0;
                 END IF;
                 --linha(1051)
               ELSE
                 --Se valor disponivel + Cheque salario + limite credito + valor bloqueado for > 0
                 IF (rw_crapsld.vlsddisp + rw_crapsld.vlsdchsl + rw_crapass.vllimcre + vr_vlbloque) > 0 THEN
                   --Acumular no vetor do saldo utilizado o limite de credito
                   vr_tab_rel_vlsutili(rw_crapass.inpessoa):= vr_tab_rel_vlsutili(rw_crapass.inpessoa) +
                                                              (rw_crapass.vllimcre * -1);
                   --Acumular no Total utilizado o valor do limite de credito
                   vr_tot_vlutiliz:= nvl(vr_tot_vlutiliz,0) + (rw_crapass.vllimcre * -1);

                   --Acumular no vetor do bloqueado judicialmente o valor bloqueado judicialmente
                   --vr_tab_rel_vlblqjud(rw_crapass.inpessoa):= vr_tab_rel_vlblqjud(rw_crapass.inpessoa) +
                   --                                           Nvl(rw_crapsld.vlblqjud,0);

                   --Acumular no vetor do saque bloqueado o valor disponivel + valor cheque salario + limite de credito
                   vr_tab_rel_vlsaqblq(rw_crapass.inpessoa):= vr_tab_rel_vlsaqblq(rw_crapass.inpessoa) +
                                                              (nvl(rw_crapsld.vlsddisp,0) + nvl(rw_crapsld.vlsdchsl,0) + nvl(rw_crapass.vllimcre,0));

                   --Acumular no Total saque bloqueado o valor disponivel + valor cheque salario + limite de credito
                   vr_tot_vlsaqblq:= nvl(vr_tot_vlsaqblq,0) + nvl(rw_crapsld.vlsddisp,0) + nvl(rw_crapsld.vlsdchsl,0) + nvl(rw_crapass.vllimcre,0);

                   --Verificar se é conta do bndes
                   IF vr_tab_cta_bndes.EXISTS(rw_crapass.nrdconta) THEN
                     --Acumular no Valor Saque Bloueado o valor do saldo disponivel + saldo cheque salario + limite credito
                     vr_tab_cta_bndes(rw_crapass.nrdconta).vlsaqblq:= nvl(vr_tab_cta_bndes(rw_crapass.nrdconta).vlsaqblq,0) +
                                                                      (nvl(rw_crapsld.vlsddisp,0) + nvl(rw_crapsld.vlsdchsl,0) + nvl(rw_crapass.vllimcre,0));
                     --Acumular no Valor Cheque Especial o valor do limite credito
                     vr_tab_cta_bndes(rw_crapass.nrdconta).vlchqesp:= nvl(vr_tab_cta_bndes(rw_crapass.nrdconta).vlchqesp,0) +
                                                                      rw_crapass.vllimcre;
                   ELSE
                     vr_tab_cta_bndes(rw_crapass.nrdconta).nrdconta:= rw_crapass.nrdconta;
                     --Valor Saque Bloueado  recebe valor do saldo disponivel + saldo cheque salario + limite credito
                     vr_tab_cta_bndes(rw_crapass.nrdconta).vlsaqblq:= nvl(rw_crapsld.vlsddisp,0) + nvl(rw_crapsld.vlsdchsl,0) + nvl(rw_crapass.vllimcre,0);
                     --Valor Cheque Especial orecebe  valor do limite credito
                     vr_tab_cta_bndes(rw_crapass.nrdconta).vlchqesp:= rw_crapass.vllimcre;
                   END IF;

                   --Se for pessoa fisica ou juridica
                   IF rw_crapass.inpessoa <= 2 THEN
                     --Verificar se é conta do bndes
                     IF vr_tab_cta_bndes.EXISTS(rw_crapass.nrdconta) THEN
                       --Acumular no Valor Deposito a vista o valor do limite credito
                       vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs:= nvl(vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs,0) +
                                                                        nvl(rw_crapass.vllimcre,0) +
                                                                        ((nvl(rw_crapsld.vlsddisp,0) + nvl(rw_crapsld.vlsdchsl,0) + nvl(rw_crapass.vllimcre,0)) *-1);
                     ELSE
                       vr_tab_cta_bndes(rw_crapass.nrdconta).nrdconta:= rw_crapass.nrdconta;
                       --Valor Deposito a vista recebe valor do limite credito + disponivel + cheque salario + limite credito
                       vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs:= nvl(rw_crapass.vllimcre,0) +
                                                                        ((nvl(rw_crapsld.vlsddisp,0) + nvl(rw_crapsld.vlsdchsl,0) + nvl(rw_crapass.vllimcre,0)) *-1);
                     END IF;
                   END IF; --rw_crapass.inpessoa <= 2

                   --Verificar se existe gn099
                   IF vr_tab_gn099.EXISTS(vr_cdagenci) THEN
                     --Acumular no valor utilizado o valor do limite credito
                     vr_tab_gn099(vr_cdagenci).vlsutili:= vr_tab_gn099(vr_cdagenci).vlsutili +
                                                                  (rw_crapass.vllimcre * -1);
                     --Acumular no valor saque bloueado o valor do saldo disponivel + cheque salario + limite credito
                     vr_tab_gn099(vr_cdagenci).vlsaqblq:= vr_tab_gn099(vr_cdagenci).vlsaqblq +
                                                                 (nvl(rw_crapsld.vlsddisp,0) + nvl(rw_crapsld.vlsdchsl,0) + nvl(rw_crapass.vllimcre,0));
                   ELSE
                     --Criar conta no vetor de memoria
                     vr_tab_gn099(vr_cdagenci).cdagenci:= vr_cdagenci;
                     vr_tab_gn099(vr_cdagenci).vlsutili:= (rw_crapass.vllimcre * -1);
                     vr_tab_gn099(vr_cdagenci).vlsaqblq:= nvl(rw_crapsld.vlsddisp,0) + nvl(rw_crapsld.vlsdchsl,0) + nvl(rw_crapass.vllimcre,0);
                     vr_tab_gn099(vr_cdagenci).vlsadian:= 0;
                     vr_tab_gn099(vr_cdagenci).vladiclq:= 0;
                   END IF;
                 ELSE
                   --Se a data do saldo for nula
                   IF rw_crapsld.dtdsdclq IS NULL THEN

                     --Acumular no Total utilizado o valor do limite de credito
                     vr_tot_vlutiliz:= nvl(vr_tot_vlutiliz,0) + (rw_crapass.vllimcre * -1);

                     --Acumular no vetor do saldo utilizado o limite de credito
                     vr_tab_rel_vlsutili(rw_crapass.inpessoa):= vr_tab_rel_vlsutili(rw_crapass.inpessoa) +
                                                                (rw_crapass.vllimcre * -1);

                     --Verificar se é conta do bndes
                     IF vr_tab_cta_bndes.EXISTS(rw_crapass.nrdconta) THEN
                     --Acumular no Valor Cheque Especial o valor do limite credito
                     vr_tab_cta_bndes(rw_crapass.nrdconta).vlchqesp:= nvl(vr_tab_cta_bndes(rw_crapass.nrdconta).vlchqesp,0) +
                                                                      rw_crapass.vllimcre;
                     ELSE
                       vr_tab_cta_bndes(rw_crapass.nrdconta).nrdconta:= rw_crapass.nrdconta;
                       --Valor Cheque Especial orecebe  valor do limite credito
                       vr_tab_cta_bndes(rw_crapass.nrdconta).vlchqesp:= rw_crapass.vllimcre;
                     END IF;

                     --Se for pessoa fisica ou juridica
                     IF rw_crapass.inpessoa <= 2 THEN
                       --Verificar se é conta do bndes
                       IF vr_tab_cta_bndes.EXISTS(rw_crapass.nrdconta) THEN
                         --Acumular no Valor Deposito a vista o valor do limite credito
                         vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs:= nvl(vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs,0) +
                                                                          nvl(rw_crapass.vllimcre,0);
                       ELSE
                         vr_tab_cta_bndes(rw_crapass.nrdconta).nrdconta:= rw_crapass.nrdconta;
                         --Valor Deposito a vista recebe valor do limite credito
                         vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs:= rw_crapass.vllimcre;
                       END IF;
                     END IF; --rw_crapass.inpessoa <= 2

                     --Verificar se existe gn099
                     IF vr_tab_gn099.EXISTS(vr_cdagenci) THEN
                     --Acumular no valor utilizado o valor do limite credito
                     vr_tab_gn099(vr_cdagenci).vlsutili:= vr_tab_gn099(vr_cdagenci).vlsutili +
                                                                  (rw_crapass.vllimcre * -1);
                     ELSE
                       --Criar conta no vetor de memoria
                       vr_tab_gn099(vr_cdagenci).cdagenci:= vr_cdagenci;
                       vr_tab_gn099(vr_cdagenci).vlsutili:= (rw_crapass.vllimcre * -1);
                       vr_tab_gn099(vr_cdagenci).vlsaqblq:= 0;
                       vr_tab_gn099(vr_cdagenci).vlsadian:= 0;
                       vr_tab_gn099(vr_cdagenci).vladiclq:= 0;
                     END IF;

                     --> APenas somar no relatorio 006 caso seja negativo o valor 
                     IF vr_rel_vlsddisp_006 < 0 THEN   
                     --Acumular no Total Adiantamento deposito o disponivel + cheque salario + limite credito + bloqueado
                     vr_tab_rel_vlsadian(rw_crapass.inpessoa):= vr_tab_rel_vlsadian(rw_crapass.inpessoa) +
                                                                  --> nao deve utilizar o valor bloqueado prejuizo no adiantamento
                                                                  ((nvl(vr_rel_vlsddisp_006,0) - nvl(rw_crapsld.vlblqprj,0)) + 
                                                                   nvl(rw_crapsld.vlsdchsl,0) +
                                                                 nvl(rw_crapass.vllimcre,0) + nvl(vr_vlbloque,0));
                     END IF;

                     --Se for pessoa fisica ou juridica
                     IF rw_crapass.inpessoa <= 2 THEN
                       --Verificar se é conta do bndes
                       IF vr_tab_cta_bndes.EXISTS(rw_crapass.nrdconta) THEN
                         --Acumular no Valor Deposito a vista o valor disponivel + cheque salario + limite credito + bloqueado
                         vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs:= nvl(vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs,0) +
                                                                          ((nvl(rw_crapsld.vlsddisp,0) + nvl(rw_crapsld.vlsdchsl,0) +
                                                                            nvl(rw_crapass.vllimcre,0) + nvl(vr_vlbloque,0)) *-1);
                       ELSE
                         vr_tab_cta_bndes(rw_crapass.nrdconta).nrdconta:= rw_crapass.nrdconta;
                         --Valor Deposito a vista recebe valor do limite credito + disponivel + cheque salario + limite credito + bloqueado
                         vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs:= ((nvl(rw_crapsld.vlsddisp,0) + nvl(rw_crapsld.vlsdchsl,0) +
                                                                            nvl(rw_crapass.vllimcre,0) + nvl(vr_vlbloque,0)) *-1);
                       END IF;
                     END IF; --rw_crapass.inpessoa <= 2

                     --Verificar se existe gn099
                     IF vr_tab_gn099.EXISTS(vr_cdagenci) THEN
                     --Acumular no Total Adiantamento deposito o valor do limite credito + disponivel + cheque salario + limite credito + bloqueado
                     vr_tab_gn099(vr_cdagenci).vlsadian:= vr_tab_gn099(vr_cdagenci).vlsadian +
                                                                  (nvl(rw_crapsld.vlsddisp,0) + nvl(rw_crapsld.vlsdchsl,0) +
                                                                   nvl(rw_crapass.vllimcre,0) + nvl(vr_vlbloque,0));

                     ELSE
                       --Criar conta no vetor de memoria
                       vr_tab_gn099(vr_cdagenci).cdagenci:= vr_cdagenci;
                       vr_tab_gn099(vr_cdagenci).vlsadian:= (nvl(rw_crapsld.vlsddisp,0) + nvl(rw_crapsld.vlsdchsl,0) +
                                                                     nvl(rw_crapass.vllimcre,0) + nvl(vr_vlbloque,0));
                       vr_tab_gn099(vr_cdagenci).vlsutili:= 0;
                       vr_tab_gn099(vr_cdagenci).vlsaqblq:= 0;
                       vr_tab_gn099(vr_cdagenci).vladiclq:= 0;
                     END IF;
                   END IF;

                   --Acumular no Total saque bloqueado o valor bloqueado
                   vr_tot_vlsaqblq:= nvl(vr_tot_vlsaqblq,0) + (vr_vlbloque * -1);
                   --Acumular no vetor do saque bloqueado o valor bloqueado
                   vr_tab_rel_vlsaqblq(rw_crapass.inpessoa):= vr_tab_rel_vlsaqblq(rw_crapass.inpessoa) + (vr_vlbloque * -1);
                   --Acumular no Total adiantamento o disponivel + cheque salario + limite credito + bloqueado
                   vr_tot_vladiant:= nvl(vr_tot_vladiant,0) + ( --> nao deve utilizar o valor bloqueado prejuizo no adiantamento
                                                               (nvl(vr_rel_vlsddisp_006,0) - nvl(rw_crapsld.vlblqprj,0))  + 
                                                                nvl(rw_crapsld.vlsdchsl,0) +
                                                               nvl(rw_crapass.vllimcre,0) + nvl(vr_vlbloque,0));

                   --Verificar se é conta do bndes
                   IF vr_tab_cta_bndes.EXISTS(rw_crapass.nrdconta) THEN
                     --Acumular no Valor Saque Bloqueado o valor bloqueado
                     vr_tab_cta_bndes(rw_crapass.nrdconta).vlsaqblq:= nvl(vr_tab_cta_bndes(rw_crapass.nrdconta).vlsaqblq,0) +
                                                                      (vr_vlbloque *-1);
                     --Acumular em Adto Depositantes o disponivel + cheque salario + limite credito + bloqueado
                     vr_tab_cta_bndes(rw_crapass.nrdconta).vladtodp:= nvl(vr_tab_cta_bndes(rw_crapass.nrdconta).vladtodp,0) +
                                                                      (nvl(rw_crapsld.vlsddisp,0) + nvl(rw_crapsld.vlsdchsl,0) +
                                                                       nvl(rw_crapass.vllimcre,0) + nvl(vr_vlbloque,0));
                   ELSE
                     vr_tab_cta_bndes(rw_crapass.nrdconta).nrdconta:= rw_crapass.nrdconta;
                     --Valor Saque Bloueado recebe valor bloqueado
                     vr_tab_cta_bndes(rw_crapass.nrdconta).vlsaqblq:= (vr_vlbloque *-1);
                     --Valor Adto Depositantes recebe o saldo disponivel + cheque salario + limite credito + bloqueado
                     vr_tab_cta_bndes(rw_crapass.nrdconta).vladtodp:= (nvl(rw_crapsld.vlsddisp,0) + nvl(rw_crapsld.vlsdchsl,0) +
                                                                       nvl(rw_crapass.vllimcre,0) + nvl(vr_vlbloque,0));
                   END IF;

                   --Se for pessoa fisica ou juridica
                   IF rw_crapass.inpessoa <= 2 THEN
                     --Verificar se é conta do bndes
                     IF vr_tab_cta_bndes.EXISTS(rw_crapass.nrdconta) THEN
                       --Acumular no Valor Deposito a vista o valor bloqueado
                       vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs:= nvl(vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs,0) +
                                                                        nvl(vr_vlbloque,0);
                     ELSE
                       vr_tab_cta_bndes(rw_crapass.nrdconta).nrdconta:= rw_crapass.nrdconta;
                       --Valor Deposito a vista recebe valor bloqueado
                       vr_tab_cta_bndes(rw_crapass.nrdconta).vldepavs:= vr_vlbloque;
                     END IF;
                   END IF; --rw_crapass.inpessoa <= 2

                   --Verificar se existe gn099
                   IF vr_tab_gn099.EXISTS(vr_cdagenci) THEN
                     --Acumular no Total Saque Bloqueado o valor bloqueado
                     vr_tab_gn099(vr_cdagenci).vlsaqblq:= vr_tab_gn099(vr_cdagenci).vlsaqblq + (vr_vlbloque * -1);
                   ELSE
                     --Criar conta no vetor de memoria
                     vr_tab_gn099(vr_cdagenci).cdagenci:= vr_cdagenci;
                     vr_tab_gn099(vr_cdagenci).vlsutili:= 0;
                     vr_tab_gn099(vr_cdagenci).vlsaqblq:= (vr_vlbloque * -1);
                     vr_tab_gn099(vr_cdagenci).vlsadian:= 0;
                     vr_tab_gn099(vr_cdagenci).vladiclq:= 0;
                   END IF;
                  END IF;
                END IF;
              END IF;
               --Criar saldo contabilizacao no vetor  
               -- Projeto Ligeirinho
               vr_tab_contab(vr_cdagenci).cdagenci    := vr_cdagenci;
               vr_tab_contab(vr_cdagenci).con_vlsaqblq:= vr_tot_vlsaqblq;
               vr_tab_contab(vr_cdagenci).con_vladiant:= vr_tot_vladiant;
               vr_tab_contab(vr_cdagenci).con_vlutiliz:= vr_tot_vlutiliz;


              --linha(1341)

              --Se for viacredi
              IF pr_cdcooper = 1 THEN
                --Valor minimo conta poupança
                vr_vlminpop:= 15;
              ELSE
                vr_vlminpop:= 4.01;
              END IF;

              --Se valor disponivel > 15,00 (cooper=1) e 4,00 (demais) e tipo de conta for
              -- 6=CTA APLIC CONJ.
              -- 7=CTA APLIC INDIV
              --17=CTA APL.CNJ.ITG
              --18=CTA APL.IND.ITG


              /* Saldos conta poupanca >= 15,00 ou > 4,00*/
              IF rw_crapsld.vlsddisp >= vr_vlminpop AND rw_crapass.cdmodali = 3 THEN
                --Executar rotina
                pc_cria_crat071 (pr_cdagenci => rw_crapass.cdagenci
                                ,pr_nrdconta => rw_crapass.nrdconta
                                ,pr_cdempres => vr_cdempres
                                ,pr_dsdacstp => vr_rel_dsdacstp
                                ,pr_nrdofone => vr_rel_nrdofone
                                ,pr_vlsddisp => rw_crapsld.vlsddisp
                                ,pr_vlstotal => vr_rel_vlstotal
                                ,pr_nmprimtl => rw_crapass.nmprimtl
                                ,pr_cdturnos => rw_crapttl.cdturnos
                                ,pr_des_erro => vr_dscritic);
                --Se retornou erro
                IF vr_dscritic IS NOT NULL THEN
                  --Levantar Exceção
                  RAISE vr_exc_saida;
                END IF;
                -- Incluir nome do módulo logado
                GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS005' ,pr_action => NULL);
                
              END IF;

              --Se o valor bloqueado ou bloqueado praca ou bloqueado fora praca ou cheque salario ou disponivel for negativo
              IF Nvl(rw_crapsld.vlsdbloq,0) < 0 OR
                 Nvl(rw_crapsld.vlsdblpr,0) < 0 OR
                 Nvl(rw_crapsld.vlsdblfp,0) < 0 OR
                 Nvl(rw_crapsld.vlsdchsl,0) < 0 OR
                 Nvl(rw_crapsld.vlsddisp,0) < 0 THEN
                --Flag negativo recebe true
                vr_flgnegat:= TRUE;
                --Flag imprime recebe true
                vr_flgimprm:= TRUE;

                /*   CHEQUE ESPECIAL  */
                CADA0006.pc_permite_produto_tipo (pr_cdprodut => 13
                                                 ,pr_cdtipcta => rw_crapass.cdtipcta
                                                 ,pr_cdcooper => pr_cdcooper
                                                 ,pr_inpessoa => rw_crapass.inpessoa
                                                 ,pr_possuipr => vr_possuipr
                                                 ,pr_cdcritic => vr_cdcritic
                                                 ,pr_dscritic => vr_dscritic);
                
                IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                  RAISE vr_exc_saida;
                END IF;

                --Se o tipo da conta for ESPECIAL, ESPEC. CONJUNTA, ESPEC. CONVENIO, CONJ.ESP.CONV., ESPECIAL ITG, ESPEC.CJTA ITG
                IF vr_possuipr = 'S' THEN
                  --Se valor disponivel for maior limite de credito
                  IF (rw_crapsld.vlsddisp * -1) > rw_crapass.vllimcre THEN
                    vr_flgimprm:= TRUE;
                  ELSE
                    vr_flgimprm:= FALSE;
                  END IF;
                  --Se o saldo total for maior que o limite de credito
                  IF (vr_rel_vlstotal * -1) > rw_crapass.vllimcre THEN
                    --Acumular no Valor total limite agencia o valor do limite de credito
                    IF vr_tab_tot_agnvllim.EXISTS(rw_crapass.cdagenci) THEN
                      vr_tab_tot_agnvllim(rw_crapass.cdagenci):= vr_tab_tot_agnvllim(rw_crapass.cdagenci) + nvl(rw_crapass.vllimcre,0);
                    ELSE
                      vr_tab_tot_agnvllim(rw_crapass.cdagenci):= nvl(rw_crapass.vllimcre,0);
                    END IF;
                    --Se data saldo conta corrente nao for nula
                    IF rw_crapsld.dtdsdclq IS NOT NULL THEN
                      --Acumular no Valor limite da agencia o valor do limite de credito
                      vr_tab_rel_agnvllim(4):= vr_tab_rel_agnvllim(4) + rw_crapass.vllimcre;
                    ELSE
                      --Acumular no Valor limite da agencia o valor do limite de credito
                      vr_tab_rel_agnvllim(rw_crapass.inpessoa):= vr_tab_rel_agnvllim(rw_crapass.inpessoa) + nvl(rw_crapass.vllimcre,0);
                    END IF;
                  END IF;
                END IF;

                --Se valor saldo total for negativo
                IF vr_rel_vlstotal < 0 THEN
                  --Se o valor do saldo total for maior limite de credito
                  IF (vr_rel_vlstotal * -1) > rw_crapass.vllimcre THEN
                    --Acumular o saldo total da agencia
                    IF vr_tab_tot_agnsdstl.EXISTS(rw_crapass.cdagenci) THEN
                      vr_tab_tot_agnsdstl(rw_crapass.cdagenci):= vr_tab_tot_agnsdstl(rw_crapass.cdagenci) + nvl(vr_rel_vlstotal,0);
                    ELSE
                      vr_tab_tot_agnsdstl(rw_crapass.cdagenci):= nvl(vr_rel_vlstotal,0);
                    END IF;
                    --Se data saldo conta corrente nao for nula
                    IF rw_crapsld.dtdsdclq IS NOT NULL THEN
                      --Acumular no Saldo total da agencia o valor do limite de credito
                      vr_tab_rel_agnsdstl(4):= vr_tab_rel_agnsdstl(4) + vr_rel_vlstotal;
                    ELSE
                      --Acumular no Saldo total da agencia o valor do limite de credito
                      vr_tab_rel_agnsdstl(rw_crapass.inpessoa):= vr_tab_rel_agnsdstl(rw_crapass.inpessoa) + nvl(vr_rel_vlstotal,0);
                    END IF;
                  END IF;
                END IF;

                --Se imprime
                IF vr_flgimprm THEN
                  --Se o saldo disponivel for negativo
                  IF rw_crapsld.vlsddisp < 0 THEN
                    --Acumular o saldo total disponivel da agencia
                    IF vr_tab_tot_agnsddis.EXISTS(rw_crapass.cdagenci) THEN
                      vr_tab_tot_agnsddis(rw_crapass.cdagenci):= vr_tab_tot_agnsddis(rw_crapass.cdagenci) + nvl(rw_crapsld.vlsddisp,0);
                    ELSE
                      vr_tab_tot_agnsddis(rw_crapass.cdagenci):= nvl(rw_crapsld.vlsddisp,0);
                    END IF;
                  END IF;

                  --Acumular o bloquado judicialmente no total bloqueado
                  IF rw_crapsld.vlblqjud > 0 THEN
                    IF vr_tab_tot_agnvlbjd.EXISTS(rw_crapass.cdagenci) THEN
                      vr_tab_tot_agnvlbjd(rw_crapass.cdagenci):= vr_tab_tot_agnvlbjd(rw_crapass.cdagenci) + Nvl(rw_crapsld.vlblqjud,0);
                    ELSE
                      vr_tab_tot_agnvlbjd(rw_crapass.cdagenci):= Nvl(rw_crapsld.vlblqjud,0);
                    END IF;
                  END IF;

                  --Se o saldo bloqueado ou o saldo bloqueado praca ou o saldo bloqueado fora praca for negativo
                  IF Nvl(rw_crapsld.vlsdbloq,0) < 0   OR
                     Nvl(rw_crapsld.vlsdblpr,0) < 0   OR
                     Nvl(rw_crapsld.vlsdblfp,0) < 0   THEN
                    --Acumular o Saldo total bloqueado da agencia
                    IF vr_tab_tot_agnsdbtl.EXISTS(rw_crapass.cdagenci) THEN
                      vr_tab_tot_agnsdbtl(rw_crapass.cdagenci):= vr_tab_tot_agnsdbtl(rw_crapass.cdagenci) + nvl(vr_rel_vlsdbltl,0);
                    ELSE
                      vr_tab_tot_agnsdbtl(rw_crapass.cdagenci):= nvl(vr_rel_vlsdbltl,0);
                    END IF;
                  END IF;

                  --Se o saldo cheque salario liquido for negativo
                  IF rw_crapsld.vlsdchsl < 0 THEN
                    --Acumular o Saldo cheque salario liquido da agencia
                    IF vr_tab_tot_agnsdchs.EXISTS(rw_crapass.cdagenci) THEN
                      vr_tab_tot_agnsdchs(rw_crapass.cdagenci):= vr_tab_tot_agnsdchs(rw_crapass.cdagenci) + nvl(rw_crapsld.vlsdchsl,0);
                    ELSE
                      vr_tab_tot_agnsdchs(rw_crapass.cdagenci):= nvl(rw_crapsld.vlsdchsl,0);
                    END IF;
                  END IF;

                  /*   Credito em Liquidacao */

                  --Se data saldo conta corrente nao for nula
                  IF rw_crapsld.dtdsdclq IS NOT NULL THEN
                    --Se o saldo disponivel for negativo
                    IF rw_crapsld.vlsddisp < 0 THEN
                      --Acumular o saldo total disponivel da agencia
                      vr_tab_rel_agnsddis(4):= vr_tab_rel_agnsddis(4) + nvl(rw_crapsld.vlsddisp,0);
                    END IF;

                    --Se o saldo bloqueado ou o saldo bloqueado praca ou o saldo bloqueado fora praca for negativo
                    IF Nvl(rw_crapsld.vlsdbloq,0) < 0   OR
                       Nvl(rw_crapsld.vlsdblpr,0) < 0   OR
                       Nvl(rw_crapsld.vlsdblfp,0) < 0   THEN

                      --Acumular o Saldo total bloqueado no relatorio da agencia
                      vr_tab_rel_agnsdbtl(4):= vr_tab_rel_agnsdbtl(4) + nvl(vr_rel_vlsdbltl,0);
                    END IF;

                    --Se o saldo cheque salario liquido for negativo
                    IF rw_crapsld.vlsdchsl < 0 THEN
                      --Acumular o Saldo cheque salario no relatorio da agencia
                      vr_tab_rel_agnsdchs(4):= vr_tab_rel_agnsdchs(4) + nvl(rw_crapsld.vlsdchsl,0);
                    END IF;
                  ELSE   --rw_crapsld.dtdsdclq IS NOT NULL
                    --Se o saldo disponivel for negativo
                    IF rw_crapsld.vlsddisp < 0 THEN
                      --Acumular o saldo total disponivel da agencia
                      vr_tab_rel_agnsddis(rw_crapass.inpessoa):= vr_tab_rel_agnsddis(rw_crapass.inpessoa) + nvl(rw_crapsld.vlsddisp,0);
                    END IF;
                    --Se o saldo bloqueado ou o saldo bloqueado praca ou o saldo bloqueado fora praca for negativo
                    IF rw_crapsld.vlsdbloq < 0   OR
                       rw_crapsld.vlsdblpr < 0   OR
                       rw_crapsld.vlsdblfp < 0   THEN
                      --Acumular o Saldo total bloqueado no relatorio da agencia
                      IF vr_tab_rel_agnsdbtl.EXISTS(rw_crapass.cdagenci) THEN
                        vr_tab_rel_agnsdbtl(rw_crapass.cdagenci):= vr_tab_rel_agnsdbtl(rw_crapass.cdagenci) + nvl(vr_rel_vlsdbltl,0);
                      ELSE
                        vr_tab_rel_agnsdbtl(rw_crapass.cdagenci):= nvl(vr_rel_vlsdbltl,0);
                      END IF;
                    END IF;
                    --Se o saldo cheque salario liquido for negativo
                    IF rw_crapsld.vlsdchsl < 0 THEN
                      --Acumular o Saldo cheque salario no relatorio da agencia
                      IF vr_tab_rel_agnsdchs.EXISTS(rw_crapass.cdagenci) THEN
                        vr_tab_rel_agnsdchs(rw_crapass.cdagenci):= vr_tab_rel_agnsdchs(rw_crapass.cdagenci) + nvl(rw_crapsld.vlsdchsl,0);
                      ELSE
                        vr_tab_rel_agnsdchs(rw_crapass.cdagenci):= nvl(rw_crapsld.vlsdchsl,0);
                      END IF;
                    END IF;
                  END IF;  --Credito em Liquidacao
                END IF; --vr_flgimprm
              ELSE
                --Atribuir false para flag negativo
                vr_flgnegat:= FALSE;
              END IF;

              --Se o valor do saldo total for negativo
              IF vr_rel_vlstotal < 0 THEN
                --Se o valor do limite de credito for > 0
                IF rw_crapass.vllimcre > 0 THEN
                  --Se o valor do limite for menor que o saldo total
                  IF rw_crapass.vllimcre < (vr_rel_vlstotal * -1) THEN
                    --Valor do estouro recebe valor total + valor do limite de credito
                    vr_rel_vlestour:= (vr_rel_vlstotal + rw_crapass.vllimcre) * -1;
                  ELSE
                    --Zerar valor do estouro
                    vr_rel_vlestour:= 0;
                  END IF;
                ELSE
                  --Inverter sinal do valor do estouro
                  vr_rel_vlestour:= vr_rel_vlstotal * -1;
                END IF;
              ELSE
                --Zerar valor do estouro
                 vr_rel_vlestour:= 0;
              END IF;

              --Se for negativo e imprime
              IF vr_flgnegat AND vr_flgimprm THEN

                --Se data saldo conta corrente nao for nula
                IF rw_crapsld.dtdsdclq IS NOT NULL THEN
                  --Nome do titular recebe nome do associado
                  vr_nmprimtl:= 'CL - '||rw_crapass.nmprimtl;
                ELSE
                  --Nome do titular recebe nome do associado
                  vr_nmprimtl:= rw_crapass.nmprimtl;
                END IF;

                --Determinar a proxima chave do indice
                --Foi utilizado o valor fixo 99.999 para conseguir ordenar pelos dias devedores decrescente
                --agencia:99999 + conta:9999999999
                vr_index_crat007:= lpad(rw_crapass.cdagenci,5,'0')||
                                   to_Char(99999-Nvl(rw_crapsld.qtddsdev,0))||
                                   lpad(rw_crapass.nrdconta,10,'0');
                --Criar saldo devedores dos associados

                vr_tab_crat007(vr_index_crat007).cdagenci:= rw_crapass.cdagenci;
                vr_tab_crat007(vr_index_crat007).nrdconta:= rw_crapass.nrdconta;
                vr_tab_crat007(vr_index_crat007).nrdofone:= vr_rel_nrdofone;
                vr_tab_crat007(vr_index_crat007).qtddsdev:= rw_crapsld.qtddsdev;
                vr_tab_crat007(vr_index_crat007).vlsddisp:= rw_crapsld.vlsddisp;
                vr_tab_crat007(vr_index_crat007).vllimcre:= rw_crapass.vllimcre;
                vr_tab_crat007(vr_index_crat007).vlestour:= vr_rel_vlestour;
                vr_tab_crat007(vr_index_crat007).nmprimtl:= vr_nmprimtl;
                vr_tab_crat007(vr_index_crat007).vlsdbltl:= vr_rel_vlsdbltl;
                vr_tab_crat007(vr_index_crat007).qtcompbb:= 0;
                vr_tab_crat007(vr_index_crat007).vlcompbb:= 0;
                vr_tab_crat007(vr_index_crat007).qtcmpbcb:= 0;
                vr_tab_crat007(vr_index_crat007).vlcmpbcb:= 0;
                vr_tab_crat007(vr_index_crat007).qtcmpctl:= 0;
                vr_tab_crat007(vr_index_crat007).vlcmpctl:= 0;
                vr_tab_crat007(vr_index_crat007).qtcstdct:= 0;
                vr_tab_crat007(vr_index_crat007).vlcstdct:= 0;

                /* INICIO - Renato Darosci(Supero) - 30/09/2013 - Atualizar os dados da tabela crapcyb  */
                -- Limpa as variáveis e os registros
               /* vr_vlstotal := NULL;
                rw_crapsda  := NULL;
                vr_tbcrapcyb.DELETE;

                -- Buscar os saldos diarios dos associados
                OPEN  cr_crapsda(pr_cdcooper           -- pr_cdcooper
                                ,vr_dtmvtoan           -- pr_dtmvtoan
                                ,rw_crapass.nrdconta   -- pr_nrdconta
                                ,rw_crapass.vllimcre); -- pr_vllimcre
                FETCH cr_crapsda INTO rw_crapsda;

                -- Calcula o total
                vr_vlstotal := NVL(rw_crapsda.vlsddisp,0)
                             + NVL(rw_crapsda.vlsdbloq,0)
                             + NVL(rw_crapsda.vlsdblpr,0)
                             + NVL(rw_crapsda.vlsdblfp,0)
                             + NVL(rw_crapsda.vlsdchsl,0)
                             + NVL(rw_crapsda.vllimcre,0);

                -- Somente considerar os estouros de conta do dia
                IF NVL(vr_vlstotal,0) >= 0 AND NVL(vr_rel_vlestour,0) > 0 THEN

                  -- Definir o índice do registro de memória
                  vr_incrapcyb := vr_tbcrapcyb.COUNT() + 1;

                  -- Popular os dados do registro de memória
                  vr_tbcrapcyb(vr_incrapcyb).cdcooper := pr_cdcooper;
                  vr_tbcrapcyb(vr_incrapcyb).nrdconta := rw_crapass.nrdconta;
                  vr_tbcrapcyb(vr_incrapcyb).nrctremp := rw_crapass.nrdconta;
                  vr_tbcrapcyb(vr_incrapcyb).cdagenci := 0; -- rw_crapass.cdagenci;
                  vr_tbcrapcyb(vr_incrapcyb).cdlcremp := 0;
                  vr_tbcrapcyb(vr_incrapcyb).cdfinemp := 0;
                  vr_tbcrapcyb(vr_incrapcyb).dtmvtolt := vr_dtmvtolt;
                  vr_tbcrapcyb(vr_incrapcyb).dtdbaixa := NULL;
                  vr_tbcrapcyb(vr_incrapcyb).dtefetiv := vr_dtmvtolt;
                  vr_tbcrapcyb(vr_incrapcyb).vlemprst := NVL(vr_rel_vlestour,0);
                  vr_tbcrapcyb(vr_incrapcyb).qtpreemp := 1;
                  vr_tbcrapcyb(vr_incrapcyb).dtdpagto := vr_dtmvtolt;
                  --vr_tbcrapcyb(vr_incrapcyb).flgjudic := 0;
                  --vr_tbcrapcyb(vr_incrapcyb).flextjud := 0;
                  --vr_tbcrapcyb(vr_incrapcyb).flgehvip := 0;
                  vr_tbcrapcyb(vr_incrapcyb).flgpreju := 0;
                  vr_tbcrapcyb(vr_incrapcyb).flgresid := 0;
                  vr_tbcrapcyb(vr_incrapcyb).flgconsg := 0;
                  vr_tbcrapcyb(vr_incrapcyb).flgfolha := 0;
                  vr_tbcrapcyb(vr_incrapcyb).dtmancad := NULL;
                  vr_tbcrapcyb(vr_incrapcyb).dtmanavl := NULL;
                  vr_tbcrapcyb(vr_incrapcyb).dtmangar := NULL;

                  -- Chama a rotina de atualização de informações
                  cybe0001.pc_atualiza_dados(pr_tbcrapcyb => vr_tbcrapcyb
                                            ,pr_cdorigem  => 1 -- Fixo - Atualizar Conta
                                            ,pr_dscritic  => vr_dscritic);

                  -- Se retornou erro
                  IF vr_dscritic IS NOT NULL THEN
                    -- Levantar Exceção
                    RAISE vr_exc_saida;
                  END IF;

                END IF;

                CLOSE cr_crapsda;*/

                /* FIM - Renato Darosci(Supero) - 30/09/2013 - Atualizar os dados da tabela crapcyb */

                /* Buscar se conta possui devolucao automatica de cheques ou nao */

                cada0003.pc_verifica_sit_dev(pr_cdcooper => pr_cdcooper, 
                                             pr_nrdconta => rw_crapass.nrdconta, 
                                             pr_flgdevolu_autom => vr_flgdevolu_autom);
                                              
                --Obtem Dados Aplicacoes
                APLI0002.pc_obtem_dados_aplicacoes (pr_cdcooper    => pr_cdcooper          --Codigo Cooperativa
                                                   ,pr_cdagenci    => vr_cdagenci          --Codigo Agencia
                                                   ,pr_nrdcaixa    => 1          --Numero do Caixa
                                                   ,pr_cdoperad    => '1'          --Codigo Operador
                                                   ,pr_nmdatela    => 'CRPS005'          --Nome da Tela
                                                   ,pr_idorigem    => 1          --Origem dos Dados
                                                   ,pr_nrdconta    => rw_crapass.nrdconta  --Numero da Conta do Associado
                                                   ,pr_idseqttl    => 1          --Sequencial do Titular
                                                   ,pr_nraplica    => 0                    --Numero da Aplicacao
                                                   ,pr_cdprogra    => 'CRPS005'          --Nome da Tela
                                                   ,pr_flgerlog    => 0 /*FALSE*/          --Imprimir log
                                                   ,pr_dtiniper    => NULL                 --Data Inicio periodo   
                                                   ,pr_dtfimper    => NULL                 --Data Final periodo
                                                   ,pr_vlsldapl    => vr_vlsldtot          --Saldo da Aplicacao
                                                   ,pr_tab_saldo_rdca  => vr_tab_saldo_rdca    --Tipo de tabela com o saldo RDCA
                                                   ,pr_des_reto    => vr_des_reto          --Retorno OK ou NOK
                                                   ,pr_tab_erro    => vr_tab_erro);        --Tabela de Erros
                --Se retornou erro
                IF vr_des_reto = 'NOK' THEN
                  --Se possuir erro na temp-table
                  IF vr_tab_erro.COUNT > 0 THEN
                      vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                  ELSE
                      vr_cdcritic := 1131;
                      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                  END IF; 
                  
                  -- Limpar tabela de erros
                  vr_tab_erro.DELETE;
                  
                  RAISE vr_exc_saida;
                END IF;                            
                
                vr_vlsldapl := nvl(vr_vlsldtot,0);
               
                --> Buscar saldo das aplicacoes
                APLI0005.pc_busca_saldo_aplicacoes(pr_cdcooper => pr_cdcooper   --> Código da Cooperativa
                                                  ,pr_cdoperad => '1'   --> Código do Operador
                                                  ,pr_nmdatela => 'CRPS005'   --> Nome da Tela
                                                  ,pr_idorigem => 1   --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                                  ,pr_nrdconta => rw_crapass.nrdconta   --> Número da Conta
                                                  ,pr_idseqttl => 1   --> Titular da Conta
                                                  ,pr_nraplica => 0             --> Número da Aplicação / Parâmetro Opcional
                                                  ,pr_dtmvtolt => vr_dtmvtolt   --> Data de Movimento
                                                  ,pr_cdprodut => 0             --> Código do Produto -–> Parâmetro Opcional
                                                  ,pr_idblqrgt => 1             --> Identificador de Bloqueio de Resgate (1 – Todas / 2 – Bloqueadas / 3 – Desbloqueadas)
                                                  ,pr_idgerlog => 0             --> Identificador de Log (0 – Não / 1 – Sim)
                                                  ,pr_vlsldtot => vr_vlsldtot   --> Saldo Total da Aplicação
                                                  ,pr_vlsldrgt => vr_vlsldrgt   --> Saldo Total para Resgate
                                                  ,pr_cdcritic => vr_cdcritic   --> Código da crítica
                                                  ,pr_dscritic => vr_dscritic); --> Descrição da crítica
            																						
                IF nvl(vr_cdcritic,0) <> 0 OR 
                   TRIM(vr_dscritic) IS NOT NULL THEN
                  RAISE vr_exc_saida;
                END IF;  
                
                vr_vlsldapl := vr_vlsldapl + vr_vlsldrgt;
               
                -- Selecionar informacoes % IR para o calculo da APLI0001.pc_calc_saldo_rpp
                vr_percenir:= GENE0002.fn_char_para_number
                                    (TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                               ,pr_nmsistem => 'CRED'
                                                               ,pr_tptabela => 'CONFIG'
                                                               ,pr_cdempres => 0
                                                               ,pr_cdacesso => 'PERCIRAPLI'
                                                               ,pr_tpregist => 0));
                
                --Executar rotina consulta poupanca
                apli0001.pc_consulta_poupanca (pr_cdcooper => pr_cdcooper            --> Cooperativa 
                                              ,pr_cdagenci => vr_cdagenci            --> Codigo da Agencia
                                              ,pr_nrdcaixa => 1            --> Numero do caixa 
                                              ,pr_cdoperad => '1'            --> Codigo do Operador
                                              ,pr_idorigem => 7            --> Identificador da Origem (7 - batch)
                                              ,pr_nrdconta => rw_crapass.nrdconta            --> Nro da conta associado
                                              ,pr_idseqttl => 1            --> Identificador Sequencial
                                              ,pr_nrctrrpp => 0                      --> Contrato Poupanca Programada 
                                              ,pr_dtmvtolt => vr_dtmvtolt            --> Data do movimento atual
                                              ,pr_dtmvtopr => vr_dtmvtopr            --> Data do proximo movimento
                                              ,pr_inproces => rw_crapdat.inproces            --> Indicador de processo
                                              ,pr_cdprogra => 'CRPS005'            --> Nome do programa chamador
                                              ,pr_flgerlog => FALSE                  --> Flag erro log
                                              ,pr_percenir => vr_percenir            --> % IR para Calculo Poupanca
                                              ,pr_tab_craptab => vr_tab_conta_bloq   --> Tipo de tabela de Conta Bloqueada
                                              ,pr_tab_craplpp => vr_tab_craplpp      --> Tipo de tabela com lancamento poupanca
                                              ,pr_tab_craplrg => vr_tab_craplrg      --> Tipo de tabela com resgates
                                              ,pr_tab_resgate => vr_tab_resgate      --> Tabela com valores dos resgates das contas por aplicacao
                                              ,pr_vlsldrpp    => vr_vlsldppr         --> Valor saldo poupanca programada
                                              ,pr_retorno     => vr_des_reto         --> Descricao de erro ou sucesso OK/NOK 
                                              ,pr_tab_dados_rpp => vr_tab_dados_rpp  --> Poupancas Programadas
                                              ,pr_tab_erro      => vr_tab_erro);     --> Saida com erros;
                --Se retornou erro
                IF vr_des_reto = 'NOK' THEN
                  -- Extrair o codigo e critica de erro da tabela de erro
                  vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                  vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
                  
                  -- Limpar tabela de erros
                  vr_tab_erro.DELETE;
                  
                  RAISE vr_exc_saida;      
                END IF;
                
                vr_vlsldapl := nvl(vr_vlsldapl,0) + nvl(vr_vlsldppr,0);
                
                --Selecionar os lancamentos de cheques da conta
                FOR rw_craplcm_cheque IN cr_craplcm_cheque (pr_cdcooper => pr_cdcooper
                                                           ,pr_nrdconta => rw_crapass.nrdconta
                                                           ,pr_dtmvtolt => vr_dtmvtolt) LOOP
                  
                  -- nao possui valor aplicado maior que valor do cheque
                  IF rw_craplcm_cheque.vllanmto < nvl(vr_vlsldapl,0) THEN
                    vr_tab_crat007(vr_index_crat007).flsldapl:= 'SIM';
                  ELSE
                    vr_tab_crat007(vr_index_crat007).flsldapl:= 'NAO';
                  END IF;
                
                  vr_qtdevolu := 0;
           
                  /* Quantidade de devolucoes que o cheque ja teve */
                  FOR rw_crapneg IN cr_crapneg ( pr_cdcooper => rw_craplcm_cheque.cdcooper,
                                                 pr_nrdconta => rw_craplcm_cheque.nrdconta,
                                                 pr_nrdocmto => rw_craplcm_cheque.nrdocmto,
                                                 pr_vlestour => rw_craplcm_cheque.vllanmto) LOOP
                                       
                     vr_qtdevolu := vr_qtdevolu + 1;
                  END LOOP;
                  
                  CASE
                    --Se tiver cheque compensado no dia para Banco do Brasil
                    WHEN rw_craplcm_cheque.cdhistor IN (50,59) THEN  --cheque comp, cheque trf comp
                      --Atualizar quantidade cheques compensados BB
                      vr_tab_crat007(vr_index_crat007).qtcompbb:= vr_tab_crat007(vr_index_crat007).qtcompbb + 1;
                      --Atualizar valor compensado
                      vr_tab_crat007(vr_index_crat007).vlcompbb:= vr_tab_crat007(vr_index_crat007).vlcompbb + nvl(rw_craplcm_cheque.vllanmto,0);
                    WHEN rw_craplcm_cheque.cdhistor IN (313,340) THEN  --cheque comp, cheque trf comp
                      --Atualizar quantidade cheques compensados Bancoob
                      vr_tab_crat007(vr_index_crat007).qtcmpbcb:= vr_tab_crat007(vr_index_crat007).qtcmpbcb + 1;
                      --Atualizar valor compensado
                      vr_tab_crat007(vr_index_crat007).vlcmpbcb:= vr_tab_crat007(vr_index_crat007).vlcmpbcb + nvl(rw_craplcm_cheque.vllanmto,0);
                    WHEN rw_craplcm_cheque.cdhistor IN (524,572) THEN  --cheque comp, cheque trf comp
                      --Atualizar quantidade cheques compensados Cecred
                      vr_tab_crat007(vr_index_crat007).qtcmpctl:= vr_tab_crat007(vr_index_crat007).qtcmpctl + 1;
                      --Atualizar valor compensado
                      vr_tab_crat007(vr_index_crat007).vlcmpctl:= vr_tab_crat007(vr_index_crat007).vlcmpctl + nvl(rw_craplcm_cheque.vllanmto,0);
                    WHEN rw_craplcm_cheque.cdhistor IN (521,621,21,26) THEN  --cheque, cheque salario
                      --Ignorar lancamentos de custodia
                      IF NOT (rw_craplcm_cheque.cdagenci = 1 AND
                              rw_craplcm_cheque.cdbccxlt = 100  AND
                              rw_craplcm_cheque.nrdolote = 4500 AND
                              (rw_craplcm_cheque.cdhistor = 21 OR rw_craplcm_cheque.cdhistor = 26)) THEN
                        --Atualizar quantidade cheques custodia
                        vr_tab_crat007(vr_index_crat007).qtcstdct:= vr_tab_crat007(vr_index_crat007).qtcstdct + 1;
                        --Atualizar valor compensado
                        vr_tab_crat007(vr_index_crat007).vlcstdct:= vr_tab_crat007(vr_index_crat007).vlcstdct + nvl(rw_craplcm_cheque.vllanmto,0);
                      END IF;
                  END CASE;
                END LOOP;
                
                IF vr_flgdevolu_autom = 1 THEN
                  vr_tab_crat007(vr_index_crat007).flgdevolu_autom:= 'SIM';
                ELSE
                  vr_tab_crat007(vr_index_crat007).flgdevolu_autom:= 'NAO';
                END IF;
                
                vr_tab_crat007(vr_index_crat007).qtdevolu:= nvl(vr_qtdevolu,0);                                

                --Executar rotina para extrair digito zero da conta integracao
                gene0005.pc_conta_itg_digito_zero (pr_nrdctitg => rw_crapass.nrdctitg
                                                  ,pr_ctpsqitg => vr_ctpsqitg
                                                  ,pr_des_erro => vr_dscritic);
                --Se retornou erro
                IF vr_dscritic IS NOT NULL THEN
                  --Levantar Exceção
                  RAISE vr_exc_saida;
                END IF;

                --Selecionar Custodias de Cheques
                FOR rw_crapcst IN cr_crapcst (pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtoan => vr_dtmvtoan
                                             ,pr_dtmvtolt => vr_dtmvtolt
                                             ,pr_nrctachq => rw_crapass.nrdconta
                                             ,pr_ctpsqitg => vr_ctpsqitg
                                             ,pr_cdagectl => rw_crapcop.cdagectl
                                             ,pr_cdagebcb => rw_crapcop.cdagebcb
                                             ,pr_cdageitg => rw_crapcop.cdageitg) LOOP

                  --Incrementar quantidade cheques custodia
                  vr_tab_crat007(vr_index_crat007).qtcstdct:= vr_tab_crat007(vr_index_crat007).qtcstdct + 1;
                  --Incrementar valores de cheque em custodia
                  vr_tab_crat007(vr_index_crat007).vlcstdct:= vr_tab_crat007(vr_index_crat007).vlcstdct +
                                                              nvl(rw_crapcst.vlcheque,0);


                END LOOP;

                /* Totaliza custodia / desconto de cheque */
                --Atualizar o totalizador da quantidade de custodia
                IF vr_tab_tot_qtcstdct.EXISTS(rw_crapass.cdagenci) THEN
                  vr_tab_tot_qtcstdct(rw_crapass.cdagenci):=  vr_tab_tot_qtcstdct(rw_crapass.cdagenci) +
                                                              nvl(vr_tab_crat007(vr_index_crat007).qtcstdct,0);
                ELSE
                  vr_tab_tot_qtcstdct(rw_crapass.cdagenci):=  nvl(vr_tab_crat007(vr_index_crat007).qtcstdct,0);
                END IF;
                --Atualizar o totalizador do valor em custodia
                IF vr_tab_tot_vlcstdct.EXISTS(rw_crapass.cdagenci) THEN
                  vr_tab_tot_vlcstdct(rw_crapass.cdagenci):=  vr_tab_tot_vlcstdct(rw_crapass.cdagenci) +
                                                              nvl(vr_tab_crat007(vr_index_crat007).vlcstdct,0);
                ELSE
                  vr_tab_tot_vlcstdct(rw_crapass.cdagenci):=  nvl(vr_tab_crat007(vr_index_crat007).vlcstdct,0);
                END IF;
                /*  Lista acompanhamento de negativos  */
                IF  (vr_cdempres = 11 AND pr_cdcooper <> 1 )        OR
                    (rw_crapass.inpessoa = 2 AND pr_cdcooper <> 1 ) OR
                    (vr_rel_vlestour > vr_rel_vlsldneg)             OR
                    (rw_crapsld.vlsddisp + rw_crapass.vllimcre) < (vr_rel_vlsldneg * -1) THEN
                  --Se data saldo conta corrente nao for nula
                  IF rw_crapsld.dtdsdclq IS NOT NULL THEN
                    --Nome do titular recebe nome do associado
                    vr_nmprimtl:= 'CL - '||rw_crapass.nmprimtl;
                  ELSE
                    --Nome do titular recebe nome do associado
                    vr_nmprimtl:= rw_crapass.nmprimtl;
                  END IF;

                  --Montar indice para tabela crat225  agencia:99999 + conta:9999999999
                  vr_index_crat225:= lpad(rw_crapass.cdagenci,5,'0')||lpad(rw_crapass.nrdconta,10,'0');
                  --Criar saldo devedores dos associados

                  vr_tab_crat225(vr_index_crat225).cdagenci:= rw_crapass.cdagenci;
                  vr_tab_crat225(vr_index_crat225).nrdconta:= rw_crapass.nrdconta;
                  vr_tab_crat225(vr_index_crat225).nrdofone:= vr_rel_nrdofone;
                  vr_tab_crat225(vr_index_crat225).cdempres:= vr_cdempres;
                  vr_tab_crat225(vr_index_crat225).cdturnos:= rw_crapttl.cdturnos;
                  vr_tab_crat225(vr_index_crat225).dsdacstp:= vr_rel_dsdacstp;
                  vr_tab_crat225(vr_index_crat225).qtddsdev:= rw_crapsld.qtddsdev;
                  vr_tab_crat225(vr_index_crat225).vlsddisp:= rw_crapsld.vlsddisp;
                  vr_tab_crat225(vr_index_crat225).vllimcre:= rw_crapass.vllimcre;
                  vr_tab_crat225(vr_index_crat225).vlestour:= vr_rel_vlestour;
                  vr_tab_crat225(vr_index_crat225).nmprimtl:= vr_nmprimtl;
                  vr_tab_crat225(vr_index_crat225).vlsdbltl:= vr_rel_vlsdbltl;
                  vr_tab_crat225(vr_index_crat225).vlstotal:= vr_rel_vlstotal;

                  --Se o valor disponivel menor zero
                  IF Nvl(rw_crapsld.vlsddisp,0) < 0 THEN
                    --Somar valor disponivel na listagem por agencia
                    IF vr_tab_lis_agnsddis.EXISTS(rw_crapass.cdagenci) THEN
                      vr_tab_lis_agnsddis(rw_crapass.cdagenci):= Nvl(vr_tab_lis_agnsddis(rw_crapass.cdagenci),0) +
                                                                 nvl(rw_crapsld.vlsddisp,0);
                    ELSE
                      vr_tab_lis_agnsddis(rw_crapass.cdagenci):= nvl(rw_crapsld.vlsddisp,0);
                    END IF;
                  END IF;
                  --Se o valor bloqueado ou bloqueado praca ou bloqueado fora praca for negativo
                  IF  Nvl(rw_crapsld.vlsdbloq,0) < 0 OR
                      Nvl(rw_crapsld.vlsdblpr,0) < 0 OR
                      Nvl(rw_crapsld.vlsdblfp,0) < 0 THEN
                    --Somar valor bloqueado na listagem por agencia
                    IF vr_tab_lis_agnsdbtl.EXISTS(rw_crapass.cdagenci) THEN
                       vr_tab_lis_agnsdbtl(rw_crapass.cdagenci):= Nvl(vr_tab_lis_agnsdbtl(rw_crapass.cdagenci),0) +
                                                                 nvl(vr_rel_vlsdbltl,0);
                    ELSE
                       vr_tab_lis_agnsdbtl(rw_crapass.cdagenci):= nvl(vr_rel_vlsdbltl,0);
                    END IF;
                  END IF;
                  --Se o valor do Cheque Salario Liquido menor zero
                  IF Nvl(rw_crapsld.vlsdchsl,0) < 0 THEN
                    --Somar valor saldo cheque salario na listagem por agencia
                    IF vr_tab_lis_agnsdchs.EXISTS(rw_crapass.cdagenci) THEN
                       vr_tab_lis_agnsdchs(rw_crapass.cdagenci):= Nvl(vr_tab_lis_agnsdchs(rw_crapass.cdagenci),0) +
                                                                 nvl(rw_crapsld.vlsdchsl,0);
                    ELSE
                       vr_tab_lis_agnsdchs(rw_crapass.cdagenci):= nvl(rw_crapsld.vlsdchsl,0);
                    END IF;
                  END IF;
                  --Se o valor do saldo total for negativo e o saldo total for maior que o limite de credito
                  IF vr_rel_vlstotal < 0 AND (vr_rel_vlstotal * -1) > Nvl(rw_crapass.vllimcre,0) THEN
                    --Somar valor saldo total na listagem por agencia
                    IF vr_tab_lis_agnsdstl.EXISTS(rw_crapass.cdagenci) THEN
                      vr_tab_lis_agnsdstl(rw_crapass.cdagenci):= Nvl(vr_tab_lis_agnsdstl(rw_crapass.cdagenci),0) +
                                                                 nvl(vr_rel_vlstotal,0);
                    ELSE
                      vr_tab_lis_agnsdstl(rw_crapass.cdagenci):= nvl(vr_rel_vlstotal,0);
                    END IF;
                  END IF;
                  --Se o valor do saldo total for maior que o limite de credito
                  IF (vr_rel_vlstotal * -1) > Nvl(rw_crapass.vllimcre,0) THEN
                    --Somar valor do saldo total na listagem por agencia
                    IF vr_tab_lis_agnvllim.EXISTS(rw_crapass.cdagenci) THEN
                      vr_tab_lis_agnvllim(rw_crapass.cdagenci):= Nvl(vr_tab_lis_agnvllim(rw_crapass.cdagenci),0) +
                                                                 nvl(rw_crapass.vllimcre,0);
                    ELSE
                      vr_tab_lis_agnvllim(rw_crapass.cdagenci):= nvl(rw_crapass.vllimcre,0);
                    END IF;
                  END IF;
                END IF;

                --Se o tipo de vinculação estiver preenchido e o valor do estouro for maior zero ou
                 --valor saldo disponivel + valor limite credito for negativo

                IF nvl(rw_crapass.tpvincul,' ') <> ' ' AND
                   --Se o tipo de vinculação estiver preenchido e o valor do estouro for maior zero ou
                   --valor saldo disponivel + valor limite credito for negativo
                    rw_crapass.tpvincul IS NOT NULL AND rw_crapass.tpvincul <> ' ' AND
                   (vr_rel_vlestour > 0.01 OR (rw_crapsld.vlsddisp + rw_crapass.vllimcre) < (0.01 * -1)) THEN

                  --Se data saldo conta corrente nao for nula
                  IF rw_crapsld.dtdsdclq IS NOT NULL THEN
                    --Nome do titular recebe nome do associado
                    vr_nmprimtl:= 'CL - '||rw_crapass.nmprimtl;
                  ELSE
                    --Nome do titular recebe nome do associado
                    vr_nmprimtl:= rw_crapass.nmprimtl;
                  END IF;

                  --Encontrar o proximo registro da tabela de memoria  agencia:99999 + conta:9999999999
                  vr_index_crat226:=  lpad(rw_crapass.cdagenci,5,'0')||lpad(rw_crapass.nrdconta,10,'0');
                  --Criar saldo devedores dos associados

                  vr_tab_crat226(vr_index_crat226).cdagenci:= rw_crapass.cdagenci;
                  vr_tab_crat226(vr_index_crat226).nrdconta:= rw_crapass.nrdconta;
                  vr_tab_crat226(vr_index_crat226).tpvincul:= rw_crapass.tpvincul;
                  vr_tab_crat226(vr_index_crat226).cdturnos:= rw_crapttl.cdturnos;
                  vr_tab_crat226(vr_index_crat226).cdempres:= vr_cdempres;
                  vr_tab_crat226(vr_index_crat226).dsdacstp:= vr_rel_dsdacstp;
                  vr_tab_crat226(vr_index_crat226).qtddsdev:= rw_crapsld.qtddsdev;
                  vr_tab_crat226(vr_index_crat226).vlsddisp:= rw_crapsld.vlsddisp;
                  vr_tab_crat226(vr_index_crat226).vllimcre:= rw_crapass.vllimcre;
                  vr_tab_crat226(vr_index_crat226).vlestour:= vr_rel_vlestour;
                  vr_tab_crat226(vr_index_crat226).nmprimtl:= vr_nmprimtl;
                  vr_tab_crat226(vr_index_crat226).vlsdbltl:= vr_rel_vlsdbltl;
                  vr_tab_crat226(vr_index_crat226).vlstotal:= vr_rel_vlstotal;

                  --Se o tipo de vinculacao for funcionario
                  IF Trim(rw_crapass.tpvincul) = 'FC' THEN
                    --Atribuir verdadeiro para flag funcionario
                    vr_flgfuctl:= TRUE;
                  ELSE
                    --Atribuir verdadeiro para flag funcionario
                    vr_flgfuctl:= FALSE;
                  END IF;
                END IF;
              END IF;

              /* leitura dos saldos da conta de investimento */
              --Montar indice para saldo investimento
              vr_index_crapsli:= LPad(pr_cdcooper,10,'0')||LPad(rw_crapass.nrdconta,10,'0');
              --Verificar se existe investimento
              IF vr_tab_crapsli.EXISTS(vr_index_crapsli) THEN
                CASE rw_crapass.inpessoa
                  WHEN 1 THEN --pessoa fisica
                    --Acumular valor total disponivel pessoa fisica
                    vr_vltotfis:= nvl(vr_vltotfis,0) + nvl(vr_tab_crapsli(vr_index_crapsli).vlsddisp,0);
                  WHEN 2 THEN --pessoa juridica
                    --Acumular valor total disponivel pessoa juridica
                    vr_vltotjur:= nvl(vr_vltotjur,0) + nvl(vr_tab_crapsli(vr_index_crapsli).vlsddisp,0);
                  WHEN 3 THEN --pessoa juridica ADMINISTRATIVA (Inclusão por INC0013948)
                    --Acumular valor total disponivel pessoa juridica ADMINISTRATIVA 
                    vr_vltotjur:= nvl(vr_vltotjur,0) + nvl(vr_tab_crapsli(vr_index_crapsli).vlsddisp,0);
                END CASE;
              END IF;

              -- Só processar contas com contrato
              vr_index_crapepr:= LPad(pr_cdcooper,10,'0')||LPad(rw_crapass.nrdconta,10,'0');
              IF vr_tab_crapepr.EXISTS(vr_index_crapepr) THEN

                /* Acumula saldo do micro-credito */
                FOR rw_crapepr IN cr_crapepr (pr_cdcooper => pr_cdcooper
                                             ,pr_nrdconta => rw_crapass.nrdconta
                                             ,pr_inliquid => 0) LOOP

                 --Bloco necessário para controle do fluxo de execução
                  BEGIN

                    --Se o mes da data do movimento <> mes do proximo dia movimento
                    IF to_char(vr_dtmvtolt,'MM') <> to_char(vr_dtmvtopr,'MM') THEN
                      --Valor do saldo devedor recebe valor calculado pelo 78
                      vr_vlsdeved:= rw_crapepr.vlsdeved;
                    ELSE
                      -- Saldo calculado pelo crps616.p e crps665.p
                      vr_vlsdeved := rw_crapepr.vlsdevat;

                      -- Verifica o tipo de emprestimo
                      IF  rw_crapepr.tpemprst = 0  THEN
                        vr_qtprecal := rw_crapepr.qtlcalat;
                      ELSE
                        vr_qtprecal := rw_crapepr.qtpcalat;
                      END IF;

                    END IF;

                    --Se o valor do saldo devedor for negativo e nao for ultimo registro da linha de credito do emprestimo
                    IF vr_vlsdeved <= 0 AND rw_crapepr.nrseqlcr <> rw_crapepr.qtemplcr THEN
                      --Pular para proximo registro do cursor
                      RAISE vr_exc_pula;
                    END IF;

                    --Se o valor do saldo devedor for maior zero
                    IF vr_vlsdeved > 0 THEN

                      IF rw_crapass.inpessoa = 2 THEN   /* Juridica */
                        --Acumular saldo devedor pessoa juridica
                        vr_pessajur:= nvl(vr_pessajur,0) + nvl(vr_vlsdeved,0);
                      ELSE
                        --Acumular saldo devedor pessoa fisica
                        vr_pessafis:= nvl(vr_pessafis,0) + nvl(vr_vlsdeved,0);
                      END IF;

                      --Se o contrato de emprestimo estiver contido na lista
                      IF INSTR(vr_lispnmpo,','||rw_crapepr.cdlcremp||',') > 0 THEN
                         --Encontrar o proximo registro da tabela de memoria
                        --linha credito: 99999 + agencia: 99999 + conta: 9999999999
                        vr_index_control := 0;
                        LOOP
                          vr_index_detalhe:= LPad(rw_crapepr.cdlcremp,5,'0')||
                                             Lpad(rw_crapepr.cdagenci,5,'0')||
                                             Lpad(rw_crapepr.nrdconta,10,'0')||
                                             lpad(vr_index_control, 3,'0');

                          IF vr_tab_detalhes.EXISTS(vr_index_detalhe) THEN
                            vr_index_control := vr_index_control + 1; -- Próximo da sequencia
                          ELSE
                            EXIT; -- Sai quando encontrar o indice novo
                          END IF;

                        END LOOP;
                        --Criar saldo devedores dos associados
                        vr_tab_detalhes(vr_index_detalhe).cdagenci:= rw_crapepr.cdagenci;
                        vr_tab_detalhes(vr_index_detalhe).nrdconta:= rw_crapepr.nrdconta;
                        vr_tab_detalhes(vr_index_detalhe).nmprimtl:= rw_crapass.nmprimtl;
                        vr_tab_detalhes(vr_index_detalhe).cdlcremp:= rw_crapepr.cdlcremp;
                        vr_tab_detalhes(vr_index_detalhe).nrctremp:= rw_crapepr.nrctremp;
                        vr_tab_detalhes(vr_index_detalhe).dtmvtolt:= rw_crapepr.dtmvtolt;
                        vr_tab_detalhes(vr_index_detalhe).vlemprst:= rw_crapepr.vlemprst;
                        vr_tab_detalhes(vr_index_detalhe).vlsdeved:= vr_vlsdeved;
                      END IF;

                      --Se a data do movimento for anterior a 07/01/2013
                      IF vr_dtmvtolt < To_Date('07/01/2013','DD/MM/YYYY') THEN

                        --Se o emprestimo foi concedido a mais de 1 ano
                        IF rw_crapepr.dtmvtolt < (vr_dtmvtolt - 360) THEN

                          /* Verifica emprestimos vencidos a mais de 1 ano */
                          EMPR0001.pc_calc_dias_atraso (pr_cdcooper   => pr_cdcooper
                                                       ,pr_cdprogra   => vr_cdprogra
                                                       ,pr_nrdconta   => rw_crapepr.nrdconta
                                                       ,pr_nrctremp   => rw_crapepr.nrctremp
                                                       ,pr_rw_crapdat => rw_crapdat
                                                       ,pr_inusatab   => vr_inusatab
                                                       ,pr_vlsdeved   => vr_vlsdeved
                                                       ,pr_qtprecal   => vr_qtprecal
                                                       ,pr_qtdiaatr   => vr_dias
                                                       ,pr_cdcritic   => vr_cdcritic
                                                       ,pr_des_erro   => vr_dscritic);
                          --Se ocorreu erro
                          IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
                            --Levantar Exceção
                            RAISE vr_exc_saida;
                          END IF;

                          --Se a quantidade de dias > 360
                          IF vr_dias > 360 THEN
                             --Encontrar o proximo registro da tabela de memoria
                            --linha credito: 99999 + agencia: 99999 + conta: 9999999999
                            vr_index_atrasados:= LPad(rw_crapepr.cdlcremp,5,'0')||
                                                 lpad(rw_crapass.cdagenci,5,'0')||
                                                 lpad(rw_crapass.nrdconta,10,'0')||
                                                 lpad(vr_tab_atrasados.count,15,'0');

                            --Criar saldo devedores dos associados
                            vr_tab_atrasados(vr_index_atrasados).cdagenci:= rw_crapass.cdagenci;
                            vr_tab_atrasados(vr_index_atrasados).nrdconta:= rw_crapass.nrdconta;
                            vr_tab_atrasados(vr_index_atrasados).cdlcremp:= rw_crapepr.cdlcremp;
                            vr_tab_atrasados(vr_index_atrasados).nrctremp:= rw_crapepr.nrctremp;
                            vr_tab_atrasados(vr_index_atrasados).dtultpag:= rw_crapepr.dtultpag;
                            vr_tab_atrasados(vr_index_atrasados).vlsdeved:= vr_vlsdeved;
                            
                          END IF;
                        END IF;  --rw_crapepr.dtmvtolt < (vr_dtmvtolt - 360)
                      ELSE
                        /* Verifica emprestimos atrasados ate 59 dias */
                        EMPR0001.pc_calc_dias_atraso (pr_cdcooper   => pr_cdcooper
                                                     ,pr_cdprogra   => vr_cdprogra
                                                     ,pr_nrdconta   => rw_crapepr.nrdconta
                                                     ,pr_nrctremp   => rw_crapepr.nrctremp
                                                     ,pr_rw_crapdat => rw_crapdat
                                                     ,pr_inusatab   => vr_inusatab
                                                     ,pr_vlsdeved   => vr_vlsdeved
                                                     ,pr_qtprecal   => vr_qtprecal
                                                     ,pr_qtdiaatr   => vr_dias
                                                     ,pr_cdcritic   => vr_cdcritic
                                                     ,pr_des_erro   => vr_dscritic);
                        --Se ocorreu erro
                        IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
                          --Levantar Exceção
                          RAISE vr_exc_saida;
                        END IF;

                        --Se a quantidade de dias maior 59
                        IF vr_dias > 90 THEN -- PRJ Microcredito
                          --Encontrar o proximo registro da tabela de memoria
                          --linha credito: 99999 + agencia: 99999 + conta: 9999999999
                          vr_index_atrasados:= LPad(rw_crapepr.cdlcremp,5,'0')||
                                               lpad(rw_crapass.cdagenci,5,'0')||
                                               lpad(rw_crapass.nrdconta,10,'0')||
                                               lpad(vr_tab_atrasados.count,15,'0');

                          --Criar saldo devedores dos associados
                          vr_tab_atrasados(vr_index_atrasados).cdagenci:= rw_crapass.cdagenci;
                          vr_tab_atrasados(vr_index_atrasados).nrdconta:= rw_crapass.nrdconta;
                          vr_tab_atrasados(vr_index_atrasados).cdlcremp:= rw_crapepr.cdlcremp;
                          vr_tab_atrasados(vr_index_atrasados).nrctremp:= rw_crapepr.nrctremp;
                          vr_tab_atrasados(vr_index_atrasados).dtultpag:= rw_crapepr.dtultpag;
                          vr_tab_atrasados(vr_index_atrasados).vlsdeved:= vr_vlsdeved;
                        END IF;
                      END IF;
                    END IF;  --vr_vlsdeved > 0

                    --Se for o ultimo registro da linha de credito
                    IF (rw_crapepr.nrseqlcr = rw_crapepr.qtemplcr) THEN
                      --Selecionar informacoes dos limites de credito
                      OPEN cr_craplcr2 (pr_cdcooper => rw_crapepr.cdcooper
                                       ,pr_cdlcremp => rw_crapepr.cdlcremp);
                      --Posicionar no primeiro registro
                      FETCH cr_craplcr2 INTO rw_craplcr2;
                      --Se encontrar registro
                      IF cr_craplcr2%FOUND THEN
                        --Montar indice para tabela totais: dsorgrec char(40) + cdlcremp (char5)
                        vr_index_totais:= LPad(rw_craplcr2.dsorgrec,40,'#')||LPad(rw_crapepr.cdlcremp,5,'0');
                        --Verificar se existe na tabela de totais
                        IF vr_tab_totais.EXISTS(vr_index_totais) THEN
                          --Acumular total pessoa fisica
                          vr_tab_totais(vr_index_totais).vltttfis:= vr_tab_totais(vr_index_totais).vltttfis + nvl(vr_pessafis,0);
                          --Acumular total pessoa juridica
                          vr_tab_totais(vr_index_totais).vltttjur:= vr_tab_totais(vr_index_totais).vltttjur + nvl(vr_pessajur,0);
                        ELSE
                          --Criar registro de totais
                          vr_tab_totais(vr_index_totais).cdlcremp:= rw_crapepr.cdlcremp;
                          vr_tab_totais(vr_index_totais).tipo:= rw_craplcr2.dsorgrec;
                          vr_tab_totais(vr_index_totais).vltttfis:= nvl(vr_pessafis,0);
                          vr_tab_totais(vr_index_totais).vltttjur:= nvl(vr_pessajur,0);
                        END IF;
                      END IF;

                      --Fechar Cursor
                      CLOSE cr_craplcr2;
                      /* Zerar total para recomecar contagem por linha */
                      vr_vltttfis:= 0;
                      vr_vltttjur:= 0;
                      vr_ttpnmpof:= 0;
                      vr_ttpnmpoj:= 0;
                      vr_pessafis:= 0;
                      vr_pessajur:= 0;
                      
                    END IF;
                    
                 EXCEPTION
                    WHEN vr_exc_saida THEN
                      RAISE vr_exc_saida;
                    WHEN vr_exc_pula THEN
                      NULL;
                    WHEN OTHERS THEN
                      vr_cdcritic := 1036;
                      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' crapepr '||
                                    'com nrdconta:'||rw_crapass.nrdconta||
                                    '. '||sqlerrm;
                      -- Levantar Excecao
                      RAISE vr_exc_saida;
                  END;
                END LOOP; --rw_crapepr
              END IF; -- Conta possui contrato
            EXCEPTION
              WHEN vr_exc_saida THEN
                RAISE vr_exc_saida;
              WHEN vr_exc_pula THEN
                NULL;
              WHEN OTHERS THEN
                vr_cdcritic := 1036;  --Erro ao selecionar associado
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' associado ('||rw_crapass.nrdconta||') '||
                              'com nrdconta:'||rw_crapepr.nrdconta||
                              ', nrctremp:'  ||rw_crapepr.nrctremp||
                              '. '||sqlerrm;

                --Levantar Excecao
                RAISE vr_exc_saida;
            END;
            
        
            
          END LOOP; --rw_crapass
          -- Buscar o próximo registro da tabela
          vr_index_crapage := vr_tab_crapage.NEXT(vr_index_crapage);
        END LOOP; --vr_tab_crapage
        ------------------------------------------------------------------
        -- Lê as tabelas de memoria e salva os dados na tabela de trabalho 
        -- Somente quando for executado por paralelismo
        -- Projeto Ligeirinho
        ------------------------------------------------------------------
        if  pr_idparale > 0 and
            pr_cdagenci > 0 and
            vr_inproces > 2 and
            vr_qtdjobs  > 0 then           
            pc_log_programa(PR_DSTIPLOG           => 'O',
                            PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                            pr_cdcooper           => pr_cdcooper,
                            pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                            pr_tpocorrencia       => 4,
                            pr_dsmensagem         => 'Início grava tabela wrk. AGENCIA: '||pr_cdagenci||' - INPROCES: '||vr_inproces||' - Horário: '||to_char(sysdate,'dd/mm/yyyy hh24:mi:ss'),
                            PR_IDPRGLOG           => vr_idlog_ini_par);  

            pc_grava_tab_wrk_geral (pr_des_erro => vr_dscritic);

            --Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
               --Levantar Exceção
               RAISE vr_exc_saida;
            END IF;
            
            pc_grava_tab_wrk_crrl055 (pr_des_erro => vr_dscritic);

            --Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
               --Levantar Exceção
               RAISE vr_exc_saida;
            END IF;

            pc_grava_tab_wrk_crrl030 (pr_des_erro => vr_dscritic);

            --Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
               --Levantar Exceção
               RAISE vr_exc_saida;
            END IF;

            pc_grava_tab_wrk_crrl225 (pr_des_erro => vr_dscritic);
            
            --Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
               --Levantar Exceção
               RAISE vr_exc_saida;
            END IF;
            
            pc_grava_tab_wrk_crrl226 (pr_des_erro => vr_dscritic);
            
            --Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
               --Levantar Exceção
               RAISE vr_exc_saida;
            END IF;
            
            pc_grava_tab_wrk_crrl007 (pr_des_erro => vr_dscritic);
            
            --Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
               --Levantar Exceção
               RAISE vr_exc_saida;
            END IF;
            
            pc_grava_tab_wrk_crrl006 (pr_des_erro => vr_dscritic);
            
            --Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
               --Levantar Exceção
               RAISE vr_exc_saida;
            END IF;
            
            pc_grava_tab_wrk_crrl372 (pr_des_erro => vr_dscritic);

            --Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
               --Levantar Exceção
               RAISE vr_exc_saida;
            END IF;
            
            pc_log_programa(PR_DSTIPLOG           => 'O',
                            PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                            pr_cdcooper           => pr_cdcooper,
                            pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                            pr_tpocorrencia       => 4,
                            pr_dsmensagem         => 'Fim grava tabela wrk. AGENCIA: '||pr_cdagenci||' - INPROCES: '||vr_inproces||' - Horário: '||to_char(sysdate,'dd/mm/yyyy hh24:mi:ss'),
                            PR_IDPRGLOG           => vr_idlog_ini_par); 
        end if;                
        pc_log_programa(pr_dstiplog   => 'F',    
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                        pr_cdcooper   => pr_cdcooper, 
                        pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par,
                        pr_flgsucesso => 1); 
                        
    end if; -- end if paralelismo  - projeto ligeirinho
  
    if pr_idparale = 0 then
        
        -- P307 Totaliza conta investimento
        vr_tab_rel_vlcntinv(1) := fn_totalizar_conta_inves(pr_cdcooper => pr_cdcooper
                                                          ,pr_inpessoa => 1);
        
        vr_tab_rel_vlcntinv(2) := fn_totalizar_conta_inves(pr_cdcooper => pr_cdcooper
                                                          ,pr_inpessoa => 2);
                                                          
        vr_tab_rel_vlcntinv(3) := fn_totalizar_conta_inves(pr_cdcooper => pr_cdcooper
                                                          ,pr_inpessoa => 3);                                                          

        --------------------------------------------------------
        -- grava os dados da tabela WRK para a tabela de memoria
        -- que será utilizada pelo relatório 
        -- somente quando é executado por paraleleismo
        -- projeto ligeirinho
        ---------------------------------------------------------
        -- Grava LOG de ocorrência inicial das rotinas que gravam na tabela de memória
        if pr_idparale = 0 and
           pr_cdagenci = 0 and
           vr_qtdjobs  > 0 then
            pc_log_programa(PR_DSTIPLOG           => 'O',
                            PR_CDPROGRAMA         => vr_cdprogra,
                            pr_cdcooper           => pr_cdcooper,
                            pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                            pr_tpocorrencia       => 4,
                            pr_dsmensagem         => 'Início grava tabela memoria. AGENCIA: '||pr_cdagenci||' - INPROCES: '||vr_inproces||' - Horário: '||to_char(sysdate,'dd/mm/yyyy hh24:mi:ss'),
                            PR_IDPRGLOG           => vr_idlog_ini_ger);  
                            

            pc_grava_tab_men_geral (pr_cdcooper => pr_cdcooper,
                                      pr_dtmvtolt => vr_dtmvtolt,
                                      pr_des_erro => vr_dscritic);

            --Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
               --Levantar Exceção
               RAISE vr_exc_saida;
            END IF;

            pc_grava_tab_men_crrl055 (pr_cdcooper => pr_cdcooper,
                                      pr_dtmvtolt => vr_dtmvtolt,
                                      pr_des_erro => vr_dscritic);

            --Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
               --Levantar Exceção
               RAISE vr_exc_saida;
            END IF;

            pc_grava_tab_men_crrl030 (pr_cdcooper => pr_cdcooper,
                                      pr_dtmvtolt => vr_dtmvtolt,
                                      pr_des_erro => vr_dscritic);

            --Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
               --Levantar Exceção
               RAISE vr_exc_saida;
            END IF;

            pc_grava_tab_men_crrl225 (pr_cdcooper => pr_cdcooper,
                                      pr_dtmvtolt => vr_dtmvtolt,
                                      pr_des_erro => vr_dscritic);

            --Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
               --Levantar Exceção
               RAISE vr_exc_saida;
            END IF;
            
            pc_grava_tab_men_crrl226 (pr_cdcooper => pr_cdcooper,
                                      pr_dtmvtolt => vr_dtmvtolt,
                                      pr_des_erro => vr_dscritic);

            --Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
               --Levantar Exceção
               RAISE vr_exc_saida;
            END IF;
            
            pc_grava_tab_men_crrl007 (pr_cdcooper => pr_cdcooper,
                                      pr_dtmvtolt => vr_dtmvtolt,
                                      pr_des_erro => vr_dscritic);

            --Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
               --Levantar Exceção
               RAISE vr_exc_saida;
            END IF;

            
            pc_grava_tab_men_crrl006 (pr_cdcooper => pr_cdcooper,
                                      pr_dtmvtolt => vr_dtmvtolt,
                                      pr_des_erro => vr_dscritic);

            --Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
               --Levantar Exceção
               RAISE vr_exc_saida;
            END IF;

            pc_grava_tab_men_crrl372 (pr_cdcooper => pr_cdcooper,
                                      pr_dtmvtolt => vr_dtmvtolt,
                                      pr_des_erro => vr_dscritic);

            --Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
               --Levantar Exceção
               RAISE vr_exc_saida;
            END IF;
            
            pc_log_programa(PR_DSTIPLOG           => 'O',
                            PR_CDPROGRAMA         => vr_cdprogra,
                            pr_cdcooper           => pr_cdcooper,
                            pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                            pr_tpocorrencia       => 4,
                            pr_dsmensagem         => 'Fim grava tabela memoria. AGENCIA: '||pr_cdagenci||' - INPROCES: '||vr_inproces||' - Horário: '||to_char(sysdate,'dd/mm/yyyy hh24:mi:ss'),
                            PR_IDPRGLOG           => vr_idlog_ini_ger);  
        end if;
        --------------------------------------------
        --  Geração dos relatórios
        --------------------------------------------
        -- Grava LOG de ocorrência inicial da impressão dos relatório
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra,
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Início imprime relatórios. AGENCIA: '||pr_cdagenci||' - INPROCES: '||vr_inproces||' - Horário: '||to_char(sysdate,'dd/mm/yyyy hh24:mi:ss'),
                        PR_IDPRGLOG           => vr_idlog_ini_ger);  

        --Gerar relatorio Maiores Depositantes
        pc_imprime_crrl055(pr_des_erro => vr_dscritic); 
        
        --Se retornou erro
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Exceção
          RAISE vr_exc_saida;
        END IF;
        -- Incluir nome do módulo logado
        GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS005' ,pr_action => NULL);

        --Gerar relatorio Creditos em Liquidacao
        pc_imprime_crrl030(pr_des_erro => vr_dscritic); 
        --Se retornou erro
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Exceção
          RAISE vr_exc_saida;
        END IF;
        -- Incluir nome do módulo logado
        GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS005' ,pr_action => NULL);

        --Gerar relatorio Acompanhamento de Negativos
        pc_imprime_crrl225(pr_nmrescop => rw_crapcop.nmrescop
                          ,pr_flgfuctl => vr_flgfuctl
                          ,pr_des_erro => vr_dscritic);
        --Se retornou erro
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Exceção
          RAISE vr_exc_saida;
        END IF;
        -- Incluir nome do módulo logado
        GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS005' ,pr_action => NULL);

        --Se for viacredi
        IF pr_cdcooper = 1 THEN
          --Valor base para poupanca recebe 15
          vr_vlsaldisp:= 15;
        ELSE
          --Valor base para poupanca recebe 4
          vr_vlsaldisp:= 4;
        END IF;

        --Gerar relatorio Saldos Devedores dos Associados
        pc_imprime_crrl007(pr_vlsaldisp => vr_vlsaldisp
                          ,pr_des_erro  => vr_dscritic);
       
        --Se retornou erro
        IF vr_dscritic IS NOT NULL THEN
          -- Levantar Exceção
          RAISE vr_exc_saida;
        END IF;
        -- Incluir nome do módulo logado
        GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS005' ,pr_action => NULL);

        --Gerar relatorio Saldos dos Associados
        pc_imprime_crrl006(pr_dtmvtolt => vr_dtmvtolt
                          ,pr_dtmvtopr => vr_dtmvtopr
                          ,pr_nrctactl => rw_crapcop.nrctactl
                          ,pr_des_erro => vr_dscritic);
        --Se retornou erro
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Exceção
          RAISE vr_exc_saida;
        END IF;
        -- Incluir nome do módulo logado
        GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS005' ,pr_action => NULL);

        --Gerar relatorio Saldos Conta Investimento
        pc_imprime_crrl372(pr_des_erro => vr_dscritic);
       
        --Se retornou erro
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Exceção
          RAISE vr_exc_saida;
        END IF;

        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => vr_cdprogra,
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Fim imprime relatórios. AGENCIA: '||pr_cdagenci||' - INPROCES: '||vr_inproces||' - Horário: '||to_char(sysdate,'dd/mm/yyyy hh24:mi:ss'),
                        PR_IDPRGLOG           => vr_idlog_ini_ger);  

        GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS005' ,pr_action => NULL);

       /* Criação dos registros do BNDES quebrados por conta */

       IF  pr_cdcooper <> 3 THEN

         --Atualizar tabela BNDES
         BEGIN
           FORALL idx IN INDICES OF vr_tab_cta_bndes SAVE EXCEPTIONS
             MERGE  
               INTO crapbnd t
               USING (SELECT 1 from DUAL) s
               ON (t.cdcooper = pr_cdcooper
               AND t.dtmvtolt = vr_dtmvtolt
               AND t.nrdconta = vr_tab_cta_bndes(idx).nrdconta)
             WHEN MATCHED THEN
               UPDATE SET vladtodp = ABS(nvl(vr_tab_cta_bndes(idx).vladtodp,0))
                         ,vlsaqblq = ABS(nvl(vr_tab_cta_bndes(idx).vlsaqblq,0))
                         ,vlchqesp = ABS(nvl(vr_tab_cta_bndes(idx).vlchqesp,0))
                         ,vldepavs = nvl(vr_tab_cta_bndes(idx).vldepavs,0)
             WHEN NOT MATCHED THEN
               INSERT (cdcooper
                      ,dtmvtolt
                      ,nrdconta
                      ,vladtodp
                      ,vlsaqblq
                      ,vlchqesp
                      ,vldepavs)
               VALUES (pr_cdcooper
                      ,vr_dtmvtolt
                      ,vr_tab_cta_bndes(idx).nrdconta
                      ,ABS(nvl(vr_tab_cta_bndes(idx).vladtodp,0))
                      ,ABS(nvl(vr_tab_cta_bndes(idx).vlsaqblq,0))
                      ,ABS(nvl(vr_tab_cta_bndes(idx).vlchqesp,0))
                      ,nvl(vr_tab_cta_bndes(idx).vldepavs,0)); 
         EXCEPTION
           WHEN OTHERS THEN
             vr_cdcritic := 1035;
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' crapbnd. '||
                            SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
             --Levantar Exceção
             RAISE vr_exc_saida;
         END;  
       END IF;

       
       /* Gravacao de dados no banco generico - Relatorios Gerenciais */
       BEGIN
         FORALL idx IN INDICES OF vr_tab_gn099 SAVE EXCEPTIONS
           MERGE  
             INTO gninfpl t
             USING (SELECT 1 from DUAL) s
             ON (t.cdcooper = pr_cdcooper
             AND t.cdagenci = vr_tab_gn099(idx).cdagenci
             AND t.dtmvtolt = vr_dtmvtolt)
           WHEN MATCHED THEN
             UPDATE SET vltotlim = vr_tab_gn099(idx).vlsutili
                       ,vltotsdb = vr_tab_gn099(idx).vlsaqblq
                       ,vltotadd = vr_tab_gn099(idx).vlsadian
                       ,vltotacl = vr_tab_gn099(idx).vladiclq
           WHEN NOT MATCHED THEN
             INSERT (cdcooper
                    ,dtmvtolt
                    ,cdagenci
                    ,vltotlim
                    ,vltotsdb
                    ,vltotadd
                    ,vltotacl)
             VALUES (pr_cdcooper
                    ,vr_dtmvtolt
                    ,vr_tab_gn099(idx).cdagenci
                    ,vr_tab_gn099(idx).vlsutili
                    ,vr_tab_gn099(idx).vlsaqblq
                    ,vr_tab_gn099(idx).vlsadian
                    ,vr_tab_gn099(idx).vladiclq); 
       EXCEPTION
         WHEN OTHERS THEN
             vr_cdcritic := 1035;
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' gninfpl. '||
                            SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
           --Levantar Exceção
           RAISE vr_exc_saida;
       END;    

       --Zerar tabela de memoria auxiliar
       pc_limpa_tabela;
       -- Incluir nome do módulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS005' ,pr_action => NULL);

       --Limpa a tabela WRK utilizada na geração dos relatórios 
       --quando o processo é executado em paralelo
       --somente quando não houver jobs com erro ao final da execução.
       -- Projeto Ligeirinho
       if vr_qterro = 0 then 
          pc_limpa_tbgen_batch_rel_wrk (pr_cdcooper  => pr_cdcooper,  
                                        pr_dtmvtolt  => vr_dtmvtolt,
                                        pr_des_erro  => vr_dscritic);
          -- Testar saida com erro
          if vr_dscritic is not null then
             -- Levantar exceçao
             raise vr_exc_saida;
          end if;       
       end if;
    
      -- Processo OK, devemos chamar a fimprg
       btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_stprogra => pr_stprogra);

      if vr_idcontrole <> 0 then
        -- Atualiza finalização do batch na tabela de controle 
        gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                           ,pr_cdcritic   => pr_cdcritic     --Codigo da critica
                                           ,pr_dscritic   => vr_dscritic);
                                           
        -- Testar saida com erro
        if  vr_dscritic is not null then 
          -- Levantar exceçao
          raise vr_exc_saida;
        end if; 
                                                        
      end if;    
      
      --Grava LOG sobre o fim da execução da procedure na tabela tbgen_prglog
      pc_log_programa(pr_dstiplog   => 'F',    
                      pr_cdprograma => vr_cdprogra,           
                      pr_cdcooper   => pr_cdcooper, 
                      pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini_ger,
                      pr_flgsucesso => 1);                 

      --Salvar informacoes no banco de dados
      commit;
    
    --Se for job chamado pelo programa do batch     
    else
      -- Atualiza finalização do batch na tabela de controle 
      gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                         ,pr_cdcritic   => pr_cdcritic     --Codigo da critica
                                         ,pr_dscritic   => vr_dscritic);  
                                             
      -- Encerrar o job do processamento paralelo dessa agência
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                  ,pr_des_erro => vr_dscritic);  
    
      --Salvar informacoes no banco de dados
      commit;
    end if;

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
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '
                                                      || vr_dscritic );
         END IF;
         -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
         btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                  ,pr_cdprogra => vr_cdprogra
                                  ,pr_infimsol => pr_infimsol
                                  ,pr_stprogra => pr_stprogra);
                                  
         if pr_idparale <> 0 then 
            -- Grava LOG de Erro
            pc_log_programa(PR_DSTIPLOG           => 'E',
                            PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                            pr_cdcooper           => pr_cdcooper,
                            pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                            pr_tpocorrencia       => 2,
                            pr_dsmensagem         => 'vr_exc_fimprg - pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                     'pr_dscritic:'||vr_dscritic,
                            PR_IDPRGLOG           => vr_idlog_ini_par);  

            --Grava data fim para o JOB na tabela de LOG 
            pc_log_programa(pr_dstiplog   => 'F',    
                            pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                            pr_cdcooper   => pr_cdcooper, 
                            pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                            pr_idprglog   => vr_idlog_ini_par,
                            pr_flgsucesso => 0);  
                            
            -- Encerrar o job do processamento paralelo dessa agência
            gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                        ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                        ,pr_des_erro => vr_dscritic);
         end if;                                    
         -- Efetuar commit pois gravaremos o que foi processado até então
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

          --Grava tabela de log - Ch 822997
          pc_gera_log(pr_cdcooper      => pr_cdcooper,
                      pr_dstiplog      => 'E',
                      pr_dscritic      => pr_dscritic,
                      pr_cdcriticidade => 1,
                      pr_cdmensagem    => nvl(pr_cdcritic,0),
                      pr_ind_tipo_log  => 2);

         -- Efetuar rollback
        
         if pr_idparale <> 0 then 
            --Grava LOG
            pc_log_programa(PR_DSTIPLOG           => 'E',
                            PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                            pr_cdcooper           => pr_cdcooper,
                            pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                            pr_tpocorrencia       => 2,
                            pr_dsmensagem         => ' VR_EXC_SAIDA - pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                     'pr_dscritic:'||pr_dscritic,
                            PR_IDPRGLOG           => vr_idlog_ini_par);   

            --Grava data fim para o JOB na tabela de LOG 
            pc_log_programa(pr_dstiplog   => 'F',    
                            pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                            pr_cdcooper   => pr_cdcooper, 
                            pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                            pr_idprglog   => vr_idlog_ini_par,
                            pr_flgsucesso => 0);  
          
            -- Encerrar o job do processamento paralelo dessa agência
            gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                        ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                        ,pr_des_erro => vr_dscritic);
          end if;
         ROLLBACK;
       WHEN OTHERS THEN
         --Inclusão na tabela de erros Oracle - Chamado 822997
         CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);

         -- Efetuar retorno do erro não tratado
         pr_cdcritic := 0;
         pr_dscritic := SQLERRM;

          --Grava tabela de log - Ch 822997
          pc_gera_log(pr_cdcooper      => pr_cdcooper,
                      pr_dstiplog      => 'E',
                      pr_dscritic      => pr_dscritic,
                      pr_cdcriticidade => 2,
                      pr_cdmensagem    => nvl(pr_cdcritic,0),
                      pr_ind_tipo_log  => 3);

         -- Efetuar rollback
         ROLLBACK;
         if pr_idparale <> 0 then 
            --Grava LOG
            pc_log_programa(PR_DSTIPLOG           => 'E',
                            PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                            pr_cdcooper           => pr_cdcooper,
                            pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                            pr_tpocorrencia       => 2,
                            pr_dsmensagem         => 'WHEN OTHERS - pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                                     'pr_dscritic:'||pr_dscritic,
                            PR_IDPRGLOG           => vr_idlog_ini_par);   

            --Grava data fim para o JOB na tabela de LOG 
            pc_log_programa(pr_dstiplog   => 'F',    
                            pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                            pr_cdcooper   => pr_cdcooper, 
                            pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                            pr_idprglog   => vr_idlog_ini_par,
                            pr_flgsucesso => 0);  
          
            -- Encerrar o job do processamento paralelo dessa agência
            gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                        ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                        ,pr_des_erro => vr_dscritic);
         end if;         
     END;
   END PC_CRPS005;
/
