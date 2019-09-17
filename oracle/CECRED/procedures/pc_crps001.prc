CREATE OR REPLACE PROCEDURE CECRED.pc_crps001 (pr_cdcooper IN crapcop.cdcooper%TYPE
                                              ,pr_flgresta IN PLS_INTEGER
                                              ,pr_stprogra OUT PLS_INTEGER
                                              ,pr_infimsol OUT PLS_INTEGER
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                              ,pr_dscritic OUT VARCHAR2) IS
  BEGIN

  /* .............................................................................

   Programa: pc_crps001                      Antigo Fontes/crps001.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Novembro/91.                    Ultima atualizacao: 06/02/2019

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 001 (batch - atualizacao).
               Calcula o saldo diario e apura os saldos medios.

   Alteracoes: 10/10/94 - Alterado para registrar as devolucoes de cheques
                          no crapneg (Edson).

               25/10/94 - Alterado para tratar o historico 78, do mesmo modo que
                          o 47 (Deborah).

               03/11/94 - Alterado para incluir nrdctabb, nrdocmto, qtdiaest e
                          vllimcre e alterar vlestmfx para vlestour na gravacao
                          do arquivo crapneg. Eliminada a rotina de acesso a ta-
                          bela de moedas fixas. (Deborah).

               08/11/94 - Alterado para gravar codigos anteriores e atuais no
                          crapneg. (Deborah).

               09/11/94 - Alterado para gerar registros de credito em liquida-
                          cao no crapneg - hist. 4 (Odair).

               10/11/94 - Alterado para modificar os calculos de saldos medios
                          (Deborah).

               16/12/94 - Alterado para nao calcular IPMF depois de 31/12/94
                          (Deborah).

               14/01/97 - Alterado para tratar CPMF apos 23/01/97 (Deborah).

               21/01/97 - Alterado para tratar historico 191 no lugar do
                          47 (Deborah).

               07/07/97 - Tratar extrato quinzenal (Odair).

               16/02/98 - Alterar a data final do CPMF (Odair)

               22/04/98 - Tratamento para milenio e troca para V8 (Magui).

               26/06/98 - Alterado para NAO tratar historico 289 na leitura
                          do craplcm e a criacao do historico 289 quando
                          houver cobranca de CPMF sobre cobertura de saldo
                          devedor (Edson).

               29/07/98 - Alterado para nao compensar a CPMF em periodos
                          anteriores (Edson).

               10/08/98 - Comentar datas de cheque < 01/23/98 (Odair)

               16/12/98 - Tratar historico 47 para digitacao fora compe
                          para tratamento para contabilidade (Odair).

               22/01/99 - Calcular a base de calculo do IOF (Deborah).

               12/03/99 - Nova forma de calculo da base do IOF a partir de
                          15/03/1999 e cobranca no primeiro dia util (Deborah)

               07/06/1999 - Tratar CPMF (Deborah).

               23/06/1999 - Tratar historico 340 como 47 (Odair).

               05/10/2001 - Inclui atualizacao qtddusol (Magui).

               19/04/2002 - Nao cobrar CPMF do historico 43 (Deborah).

               15/07/2003 - Inserido o codigo para verificar, apartir do tipo de
                            registro do cadastro de tabelas, com qual numero de
                            conta que se esta trabalhando. O numero sera
                            armazenado na variavel aux_lsconta3 (Julio).
                            Alterado a quinzena do dia 15/08/03 para o dia
                            14/08/03 em virtude de manutencao (Deborah)

               06/08/2003 - Tratamento historico 156 (Julio).

               11/08/2003 - Mudar calculo do utilizado.
                            O bloqueio de emprestimo passou a ser considerado
                            bloqueado (Deborah).

               15/10/2003 - Tratamento para calculo do VAR (Magui).

               03/05/2004 - Atual.Data/Dias Credito Liquidacao Risco(Mirtes).

               08/03/2005 - Alimentar a tabela "crapsda" (Evandro).

               28/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm, crapneg, craplot, crapvar e crapsda
                            (Diego).

               09/12/2005 - Cheque salario nao existe mais (Magui).

               19/12/2005 - Atualizar o valor do cheque e da cpmf no crapfdc
                            (Edson).

               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               14/08/2006 - Alimentar o campo crapsda.dtdsdclq a partir do
                            crapsld (Edson).

               12/02/2007 - Efetuada alteracao para nova estrutura crapneg
                            (Diego).

               07/03/2007 - Ajustes para o Bancoob (Magui).

               20/04/2007 - Substituir craptab "LIMCHEQESP" pelo craplrt (Ze).

               15/01/2008 - Cobranca de IOF a partir de 03/01/2008 (Magui).

               09/09/2009 - Acerto de leitura sem cdcooper (Diego).

               19/10/2009 - Alteracao Codigo Historico (Kbase).

               08/01/2010 - Acrescentar historico 573 no mesmo CAN-DO do 338
                            (Guilherme/Precise)

               10/01/2011 - Para as ctas TCO criar o crapneg na coop 2 para os
                            historicos de devolucao (Ze).

               02/02/2011 - Melhoria na criacao do crapneg para ctas cadastra-
                            das no TCO (Ze).

               15/05/2012 - substituição do FIND craptab para os registros
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.)

               18/06/2012 - Alteracao na leitura da craptco (David Kruger).

               21/01/2013 - Conversão Progress para PLSQL (Alisson/AMcom)

               04/07/2013 - Tratamento para o Bloqueio Judicial (Guilherme/Sup)

               09/08/2013 - Inclusão de teste na pr_flgresta antes de controlar o restart (Marcos-Supero)

               14/10/2013 - Controle de criticas (Gabriel).

               25/10/2013 - Ajustar o programa conforme alteração realizadas no Progress. (Renato - Supero)
                            Incluindo: * Tratamento para o Bloqueio Judicial (Guilherme/Sup)
                                       * Tratamento para Imunidade Tributaria (Ze).

               25/11/2013 - Ajustes na passagem dos parâmetros para restart (Marcos-Supero)

               17/03/2014 - Ajustes devido critica 244 estar sendo gerada indevidamente (Marcos-Supero)

               ****** Decisoes sobre o VAR ***********************************************
               disponivel = dispon + chsl + bloq + blfp + blpr = a vista
               adiantamento = alem do limite = a vista
               contrato de limite de credito = nao lanca
               utilizado = vencimento do contrato de limite sem juros
               **************************************************************************

               26/05/2014 - Nao utilizar mais a tabela CRAPVAR (desativacao da VAR). (Andrino-RKAM)

               21/10/2014 - Implementado cobranca de juros de limite de credito para
                            o primeiro dia do mes (Jean Michel).

               24/11/2014 - Melhorias de Performance. Foi modificada a forma de atualização das tabelas
                            crapsda e crapsld para usar o forall.
                            A atualização dos indices quando o comando é executado dentro do loop, registro
                            a registro, torna a operação bastante demorada. (Alisson - AMcom).
                            
               29/05/2015 - Ajuste na gravacao do crapsld.dtrisclq. (James)

               29/10/2015 - Inclusao do pr_cdcooper na pc_informa_acesso.
                            (Jaison/Andrino - PRJ Estado de Crise)
                            
               04/12/2015 - #369383 retirado do programa pc_crps414_1 a atualização da crapsda 
                            em função do saldo de cotas e implementado na rotina para popular 
                            este campo no PC_CRPS001, diretamente na criação do registro na tabela.
                            (Carlos)
                            
               25/04/2016 - Incluso tratamento para efetuar o lancamento do juros do cheque especial  
                            na tabela CRAPLAU quando for uma conta com restricao judicial (Daniel)            
                            
               21/06/2016 - Correcao para o uso correto do indice da CRAPTAB nesta rotina.
                            (Carlos Rafael Tanholi).                                                              

               06/10/2016 - Incluido consulta de valor de acordo de emprestimo bloqueado,
                            Prj. 302 (Jean Michel)                         

               01/03/2017 - Incluir criação de craplau caso cooperado nao tenha saldo para 
                            efetuar lançamentos para o historico 323 e 38 (Lucas Ranghetti M338.1)

               03/04/2017 - Ajuste no calculo do IOF, incluir calculo da taxa adicional do IOF.
                            (Odirlei-AMcom)

                          - Adicionar Round 2 para o valor vliofmes (Lucas Ranghetti M338.1)

               26/04/2017 - Nao considerar mais valores bloqueados para composicao de saldo disponivel
                            Heitor (Mouts) - Melhoria 440

               05/06/2017 - Ajustes para incrementar/zerar variaveis quando craplau também
                            (Lucas Ranghetti/Thiago Rodrigues)
                            
               12/07/2017 - Inclusão no final do programa para execução da procedure
                            empr0002.pc_gerar_carga_vig_crapsda com o objetivo de popular o campo
                            crapsda.vllimcap - Melhoria M441 - Roberto Holz (Mout´s)
                            
               07/12/2017 - Passagem do idcobope. (Jaison/Marcos Martini - PRJ404)
                            
               28/12/2017 - #783710 Melhoria das informações dos logs quando ñ encontrar os 
                            registros crapfdc; e alterado o arquivo de log dos mesmos, de 
                            proc_batch para proc_message (Carlos)

               15/01/2018 - #828460 Colocar o valor do IOF com duas casas decimais.
                            Foi feito round no campo de IOF (Andrino-Mouts)               

               19/01/2018 - Corrigido cálculo de saldo bloqueado (Luis Fernando-Gft)
               
               06/04/2018 - Alterar o tratamento relacionado as chamadas de resgate de aplicação,
                            para que não ocorram problemas com o fluxo atual em caso de ocorrencia
                            de erros. (Renato - Supero)
                            
               08/04/2018 - Considerar apenas o valor do estouro de conta para realizar o resgate
                            automático (Renato - Supero)

               10/04/2018 - P450 - Consistencia para considerar dias úteis ou corridos na atualização do saldo - Daniel(AMcom)
               
               27/04/2018 - P450 - Novo tratamento para IOF a Debitar (Guilherme/AMcom)
			         
               29/06/2018 - Tratamento de Históricos de Credito/Debito
                                José Carvalho / Marcel (AMcom)	

			   03/07/2018 - Tratar conta corrente invalida no cadastro de lançamento.
			                craplcm - (Belli - Envolti - Chamado REQ0018868).
                      
               25/07/2018 - Deverá buscar novamente o saldo em conta e utilizar o 
                            valor final da diferença (Renato Darosci - Supero)

               26/07/2018 - P450 - Gravar saldo da conta transitória (Diego Simas/AMcom)

							 05/11/2018 - Correção na chamada da "PREJ0003.fn_verifica_preju_conta"
							              (Reginaldo / AMcom / P450)

               12/02/2019 - Ajuste feito para melhorar o desempenho do programa. (Kelvin - PRB0040461)

               12/02/2019 - Ajustes para melhorar desempenho do programa. (Jackson - PRB0041703)
			                    - Removido HINT que forçava uso de índice no cursor cr_crapass.
						              - Corrigida condição do cursor cr_crapfdc2, aplicando UPPER ao campo crapfdc.nrdctitg
                            para uso de acordo com o índice definido.

			   17/05/2019 - Adicionada verificação para recálculo somente se houve resgate (Jefferson - MoutS)

               06/02/2019 - P442 - Remoção da chamada a rotina que grava a posição do pre-aprovado para verificação na Atenda. (Marcos-Envolti)
	       
	       25/06/2019 - Correção no update da tbgen_iof_lancamento para não considerar o registro de provisão 
                            de IOF (ADP) gerado no dia. (P410 v2 Douglas Pagel / AMcom)

     ............................................................................. */

     DECLARE

       /* Tipos e registros da pc_crps001 */

       -- Definicao do tipo de registro da crapsda
       TYPE typ_reg_crapsda2 IS
       RECORD (nrdconta crapsda.nrdconta%type
              ,dtmvtolt crapsda.dtmvtolt%type
              ,vlsddisp crapsda.vlsddisp%type
              ,vlsdchsl crapsda.vlsdchsl%type
              ,vlsdbloq crapsda.vlsdbloq%type
              ,vlsdblpr crapsda.vlsdblpr%type
              ,vlsdblfp crapsda.vlsdblfp%type
              ,vlblqjud crapsda.vlblqjud%type
              ,vlsdindi crapsda.vlsdindi%type
              ,dtdsdclq crapsda.dtdsdclq%type
              ,vllimcre crapsda.vllimcre%type
              ,cdcooper crapsda.cdcooper%type
              ,vlsdcota crapsda.vlsdcota%TYPE
              ,vlblqaco crapsda.vlblqaco%TYPE
							,vlblqprj crapsda.vlblqprj%TYPE);

       TYPE typ_tab_crapsda2 IS TABLE OF typ_reg_crapsda2 INDEX BY PLS_INTEGER;
       vr_tab_crapsda2 typ_tab_crapsda2;

       -- Definicao do tipo de registro da crapsld
       TYPE typ_reg_crapsld IS
       RECORD (vlsddisp crapsld.vlsddisp%type
              ,vlsdchsl crapsld.vlsdchsl%type
              ,vlsdbloq crapsld.vlsdbloq%type
              ,vlsdblpr crapsld.vlsdblpr%type
              ,vlsdblfp crapsld.vlsdblfp%type
              ,vltsallq crapsld.vltsallq%type
              ,dtrisclq crapsld.dtrisclq%type
              ,dtdsdclq crapsld.dtdsdclq%type
              ,qtddsdev crapsld.qtddsdev%type
              ,qtddtdev crapsld.qtddtdev%type
              ,qtdriclq crapsld.qtdriclq%type
              ,vlsmnesp crapsld.vlsmnesp%type
              ,vlsmnblq crapsld.vlsmnblq%type
              ,vlsmnmes crapsld.vlsmnmes%type
              ,qtddusol crapsld.qtddusol%type
              ,vlsmpmes crapsld.vlsmpmes%type
              ,vlipmfap crapsld.vlipmfap%type
              ,vlipmfpg crapsld.vlipmfpg%type
              ,vlbasipm crapsld.vlbasipm%type
              ,vlbasiof crapsld.vlbasiof%type
              ,vliofmes crapsld.vliofmes%type
              ,qtlanmes crapsld.qtlanmes%type
              ,dtsdexes crapsld.dtsdexes%type
              ,vlsdexes crapsld.vlsdexes%type
              ,dtsdanes crapsld.dtsdanes%type
              ,vlsdanes crapsld.vlsdanes%type
              ,dtrefere crapsld.dtrefere%type
              ,vlblqjud crapsld.vlblqjud%TYPE
							,vlblqprj crapsld.vlblqprj%TYPE
              ,nrdconta crapsld.nrdconta%TYPE
              ,vr_rowid ROWID);

       TYPE typ_tab_crapsld IS TABLE OF typ_reg_crapsld INDEX BY PLS_INTEGER;
       vr_tab_crapsld typ_tab_crapsld;

       -- Definicao do tipo de registro de associados
       TYPE typ_reg_craphis IS
       RECORD (cdhistor craphis.cdhistor%TYPE
              ,inhistor craphis.inhistor%TYPE
              ,indebcre craphis.indebcre%TYPE
              ,indoipmf craphis.indoipmf%TYPE);

       -- Definicao do tipo de tabela de associados
       TYPE typ_tab_craphis IS
         TABLE OF typ_reg_craphis
         INDEX BY BINARY_INTEGER;

       -- Definicao do tipo de registro de tarifas
       TYPE typ_reg_tarifas IS  
       RECORD (cdcooper	    tbgen_iof_lancamento.cdcooper%TYPE    
              ,nrdconta     tbgen_iof_lancamento.nrdconta%TYPE    
              ,dtmvtolt     tbgen_iof_lancamento.dtmvtolt%TYPE    
              ,tpproduto    tbgen_iof_lancamento.tpproduto%TYPE   
              ,nrcontrato   tbgen_iof_lancamento.nrcontrato%TYPE  
              ,idlautom     tbgen_iof_lancamento.idlautom%TYPE    
              ,cdagenci_lcm tbgen_iof_lancamento.cdagenci_lcm%TYPE
              ,cdbccxlt_lcm tbgen_iof_lancamento.cdbccxlt_lcm%TYPE
              ,nrdolote_lcm tbgen_iof_lancamento.nrdolote_lcm%TYPE
              ,nrseqdig_lcm tbgen_iof_lancamento.nrseqdig_lcm%TYPE);
              
        -- Definicao do tipo de tabela de associados
       TYPE typ_tab_tarifas IS
         TABLE OF typ_reg_tarifas
         INDEX BY BINARY_INTEGER;

       -- Definicao do tipo de registro de associados
       TYPE typ_reg_crapass IS
       RECORD (nrdconta crapass.nrdconta%TYPE
              ,vllimcre crapass.vllimcre%TYPE
              ,tpextcta crapass.tpextcta%TYPE
              ,inpessoa crapass.inpessoa%TYPE
              ,inprejuz crapass.inprejuz%TYPE);

       -- Definicao do tipo de registro de associado juridico
       TYPE typ_reg_crapjur IS
       RECORD (natjurid crapjur.natjurid%TYPE
              ,tpregtrb crapjur.tpregtrb%TYPE);       

       -- Definicao do tipo de registro de limites de credito
       TYPE typ_reg_craplim IS
       RECORD (nrdconta craplim.nrdconta%TYPE
              ,cddlinha craplim.cddlinha%TYPE
              ,dtinivig craplim.dtinivig%TYPE
              ,vllimite craplim.vllimite%TYPE
              ,idcobope craplim.idcobope%TYPE);

       -- Definicao do tipo de tabela de associados
       TYPE typ_tab_crapass IS
         TABLE OF typ_reg_crapass
         INDEX BY BINARY_INTEGER;

       -- Definicao do tipo de tabela de associados juridicos
       TYPE typ_tab_crapjur IS
         TABLE OF typ_reg_crapjur
         INDEX BY BINARY_INTEGER;  

       -- Definicao do tipo de registro de associados
       TYPE typ_reg_crapsda IS
       RECORD (nrdconta crapsda.nrdconta%TYPE
              ,vlsddisp crapsda.vlsddisp%TYPE);

       -- Definicao do tipo de tabela de associados
       TYPE typ_tab_crapsda IS
         TABLE OF typ_reg_crapsda
         INDEX BY BINARY_INTEGER;

       -- Definicao do tipo de tabela de lancamentos
       TYPE typ_tab_craplcm IS
         TABLE OF craplcm.nrdconta%TYPE
         INDEX BY BINARY_INTEGER;

       -- Definicao do tipo de tabela de limites de credito
       TYPE typ_tab_craplim IS
         TABLE OF typ_reg_craplim
         INDEX BY BINARY_INTEGER;

       -- Definicao do tipo de tabela de linhas credito
       TYPE typ_tab_craplrt IS
         TABLE OF NUMBER
         INDEX BY PLS_INTEGER;

       -- Definicao da vigencia de linhas credito
       TYPE typ_tab_qtdiavig IS
         TABLE OF NUMBER
         INDEX BY PLS_INTEGER;

       -- Definicao do vetor de memoria
       vr_tab_craphis  typ_tab_craphis;
       vr_tab_tarifas  typ_tab_tarifas;       
       vr_tab_crapass  typ_tab_crapass;
       vr_tab_crapjur  typ_tab_crapjur;
       vr_tab_crapsda  typ_tab_crapsda;
       vr_tab_craplcm  typ_tab_craplcm;
       vr_tab_craplim  typ_tab_craplim;
       vr_tab_craplrt  typ_tab_craplrt;
       vr_tab_qtdiavig typ_tab_qtdiavig;

       /* Cursores da pc_crps001 */

       -- Selecionar os dados da Cooperativa
       CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
         SELECT cop.cdcooper
               ,cop.nmrescop
               ,cop.nrtelura
               ,cop.cdbcoctl
               ,cop.cdagectl
               ,cop.dsdircop
         FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
       rw_crapcop cr_crapcop%ROWTYPE;

       -- Selecionar os dados da tabela Generica
       CURSOR cr_craptab  (pr_cdcooper   craptab.cdcooper%TYPE
                          ,pr_nmsistem   craptab.nmsistem%TYPE
                          ,pr_tptabela   craptab.tptabela%TYPE
                          ,pr_cdempres   craptab.cdempres%TYPE
                          ,pr_cdacesso   craptab.cdacesso%TYPE
                          ,pr_tpregist   craptab.tpregist%TYPE) IS
         SELECT  craptab.dstextab
                ,craptab.rowid
         FROM craptab  craptab
         WHERE craptab.cdcooper = pr_cdcooper
         AND   UPPER(craptab.nmsistem) = pr_nmsistem
         AND   UPPER(craptab.tptabela) = pr_tptabela
         AND   craptab.cdempres = pr_cdempres
         AND   UPPER(craptab.cdacesso) = pr_cdacesso
         AND   craptab.tpregist = pr_tpregist;
       rw_craptab  cr_craptab%ROWTYPE;

       --Selecionar dados da tabela de historicos
       CURSOR cr_craphis (pr_cdcooper IN craphis.cdcooper%TYPE) IS
         SELECT craphis.cdhistor
               ,craphis.inhistor
               ,craphis.indebcre
               ,craphis.indoipmf
         FROM craphis craphis
         WHERE craphis.cdcooper = pr_cdcooper
         AND   craphis.tplotmov IN (0,1);

       --Selecionar informacoes dos saldos dos associados
       CURSOR cr_crapsld (pr_cdcooper IN crapsld.cdcooper%TYPE
                         ,pr_nrdconta IN crapsld.nrdconta%TYPE) IS
         SELECT crapsld.nrdconta
               ,crapsld.vliofmes
               ,crapsld.vlbasiof
               ,crapsld.qtlanmes
               ,crapsld.vlsdblfp
               ,crapsld.vlsdbloq
               ,crapsld.vlsdblpr
               ,crapsld.vlblqjud
               ,crapsld.vlsdchsl
               ,crapsld.vlsddisp
               ,crapsld.vltsallq
               ,crapsld.qtddsdev
               ,crapsld.dtdsdclq
               ,crapsld.qtdriclq
               ,crapsld.dtrisclq
               ,crapsld.qtddtdev
               ,crapsld.vlsmnesp
               ,crapsld.vlsmnblq
               ,crapsld.vlsmnmes
               ,crapsld.qtddusol
               ,crapsld.vlsmpmes
               ,crapsld.vlipmfap
               ,crapsld.vlipmfpg
               ,crapsld.vlbasipm
               ,crapsld.dtsdexes
               ,crapsld.dtsdanes
               ,crapsld.vlsdexes
               ,crapsld.vlsdanes
               ,crapsld.vlsdindi
               ,crapsld.dtrefere
               ,crapsld.vljuresp
               ,crapsld.rowid
         FROM  crapsld crapsld
         WHERE crapsld.cdcooper = pr_cdcooper
         AND   crapsld.nrdconta > pr_nrdconta
         ORDER BY crapsld.nrdconta;

       --Selecionar os saldos diarios dos associados
       CURSOR cr_crapsda (pr_cdcooper IN crapsda.cdcooper%TYPE
                         ,pr_dtmvtolt IN crapsda.dtmvtolt%TYPE) IS
         SELECT crapsda.vlsddisp
               ,crapsda.nrdconta
         FROM  crapsda crapsda
         WHERE crapsda.cdcooper = pr_cdcooper
         AND   crapsda.dtmvtolt = pr_dtmvtolt;


       --Selecionar informacoes dos lotes
       CURSOR cr_craplot (pr_cdcooper IN craplot.cdcooper%TYPE
                         ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                         ,pr_cdagenci IN craplot.cdagenci%TYPE
                         ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                         ,pr_nrdolote IN craplot.nrdolote%TYPE)  IS
         SELECT  craplot.dtmvtolt
                ,craplot.cdagenci
                ,craplot.cdbccxlt
                ,craplot.nrdolote
                ,craplot.nrseqdig
                ,craplot.cdcooper
                ,craplot.tplotmov
                ,craplot.vlinfodb
                ,craplot.vlcompdb
                ,craplot.qtinfoln
                ,craplot.qtcompln
                ,craplot.rowid
         FROM craplot craplot
         WHERE  craplot.cdcooper = pr_cdcooper
         AND    craplot.dtmvtolt = pr_dtmvtolt
         AND    craplot.cdagenci = pr_cdagenci
         AND    craplot.cdbccxlt = pr_cdbccxlt
         AND    craplot.nrdolote = pr_nrdolote;
       rw_craplot cr_craplot%ROWTYPE;

       vr_rw_craplot   lanc0001.cr_craplot%ROWTYPE;
       --Selecionar informacoes dos lancamentos na conta
       CURSOR cr_craplcm (pr_cdcooper IN craplcm.cdcooper%TYPE
                         ,pr_nrdconta IN craplcm.nrdconta%TYPE
                         ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE) IS
         SELECT /*+ INDEX (craplcm craplcm##craplcm2) */
                craplcm.cdhistor
               ,craplcm.vllanmto
               ,craplcm.nrdconta
               ,craplcm.nrdocmto
               ,craplcm.dtmvtolt
               ,craplcm.nrdctabb
               ,craplcm.cdbanchq
               ,craplcm.cdagechq
               ,craplcm.nrctachq
               ,craplcm.nrdctitg
               ,craplcm.cdpesqbb
               ,craplcm.cdoperad
               ,craplcm.vldoipmf
               ,craplcm.cdcooper
               ,craplcm.ROWID
         FROM craplcm craplcm
         WHERE craplcm.cdcooper = pr_cdcooper
         AND   craplcm.nrdconta = pr_nrdconta
         AND   craplcm.dtmvtolt = pr_dtmvtolt
         AND   craplcm.cdhistor <> 289;
       rw_craplcm cr_craplcm%ROWTYPE;

       --Selecionar as contas que tiveram lancamento no dia
       CURSOR cr_craplcm2 (pr_cdcooper IN craplcm.cdcooper%TYPE
                          ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE) IS
         SELECT craplcm.nrdconta
         FROM craplcm craplcm
         WHERE craplcm.cdcooper = pr_cdcooper
         AND   craplcm.dtmvtolt = pr_dtmvtolt
         AND   craplcm.cdhistor <> 289;

       --Selecionar informacoes dos associados
       CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE) IS
         SELECT  crapass.nrdconta
                ,crapass.vllimcre
                ,crapass.tpextcta
                ,crapass.inpessoa
                ,crapass.inprejuz
         FROM crapass crapass
         WHERE  crapass.cdcooper = pr_cdcooper;

       --Selecionar informacoes dos associados juridico
       CURSOR cr_crapjur (pr_cdcooper IN crapjur.cdcooper%TYPE) IS
         SELECT natjurid
               ,tpregtrb
               ,nrdconta
           FROM crapjur
          WHERE cdcooper = pr_cdcooper;

       --selecionar informacoes dos cheques emitidos
       CURSOR cr_crapfdc (pr_cdcooper IN crapfdc.cdcooper%TYPE
                         ,pr_cdbanchq IN crapfdc.cdbanchq%TYPE
                         ,pr_cdagechq IN crapfdc.cdagechq%TYPE
                         ,pr_nrctachq IN crapfdc.nrctachq%TYPE
                         ,pr_nrcheque IN crapfdc.nrcheque%TYPE) IS
         SELECT crapfdc.ROWID
               ,crapfdc.cdcooper
               ,crapfdc.nrdconta
               ,crapfdc.cdbanchq
               ,crapfdc.cdagechq
               ,crapfdc.nrctachq
               ,COUNT(1) OVER (PARTITION BY crapfdc.cdcooper) qtdregis
         FROM crapfdc crapfdc
         WHERE crapfdc.cdcooper = pr_cdcooper
         AND   crapfdc.cdbanchq = pr_cdbanchq
         AND   crapfdc.cdagechq = pr_cdagechq
         AND   crapfdc.nrctachq = pr_nrctachq
         AND   crapfdc.nrcheque = pr_nrcheque;
       rw_crapfdc cr_crapfdc%ROWTYPE;

       --selecionar informacoes dos cheques emitidos
       CURSOR cr_crapfdc2 (pr_cdcooper IN crapfdc.cdcooper%TYPE
                          ,pr_nrdctitg IN crapfdc.nrdctitg%TYPE
                          ,pr_nrcheque IN crapfdc.nrcheque%TYPE) IS
         SELECT /*+ INDEX (crapfdc crapfdc##crapfdc6) */
                crapfdc.ROWID
               ,crapfdc.cdcooper
               ,crapfdc.nrdconta
               ,crapfdc.cdbanchq
               ,crapfdc.cdagechq
               ,crapfdc.nrctachq
               ,COUNT(1) OVER (PARTITION BY crapfdc.cdcooper) qtdregis
         FROM crapfdc crapfdc
         WHERE crapfdc.cdcooper = pr_cdcooper
         AND   crapfdc.nrcheque = pr_nrcheque
         AND   UPPER(crapfdc.nrdctitg) = UPPER(pr_nrdctitg);

      --Selecionar Transferencias entre cooperativas
      CURSOR cr_craptco (pr_cdcooper IN craptco.cdcopant%TYPE
                        ,pr_nrdconta IN craptco.nrdconta%TYPE
                        ,pr_tpctatrf IN craptco.tpctatrf%TYPE
                        ,pr_flgativo IN craptco.flgativo%TYPE) IS
        SELECT craptco.cdcopant
              ,craptco.nrctaant
              ,craptco.nrdconta
              ,craptco.cdcooper
        FROM craptco craptco
        WHERE craptco.cdcooper = pr_cdcooper
        AND   craptco.nrdconta = pr_nrdconta
        AND   craptco.tpctatrf = pr_tpctatrf
        AND   craptco.flgativo = pr_flgativo;
       rw_craptco cr_craptco%ROWTYPE;

       --Selecionar informacoes de saldos negativos e controles de cheque
       CURSOR cr_crapneg2 (pr_cdcooper IN crapneg.cdcooper%TYPE
                          ,pr_nrdconta IN crapneg.nrdconta%TYPE
                          ,pr_cdhisest IN crapneg.cdhisest%TYPE) IS
         SELECT /*+ INDEX (crapneg crapneg##crapneg2) */
                crapneg.ROWID
               ,crapneg.vlestour
               ,crapneg.dtfimest
         FROM crapneg crapneg
         WHERE crapneg.cdcooper = pr_cdcooper
         AND   crapneg.nrdconta = pr_nrdconta
         AND   crapneg.cdhisest = pr_cdhisest
         ORDER BY crapneg.cdcooper
                , crapneg.nrdconta
                , crapneg.nrseqdig DESC;
       rw_crapneg2 cr_crapneg2%ROWTYPE;

       --Selecionar contratos de limites de creditos
       CURSOR cr_craplim (pr_cdcooper IN craplim.cdcooper%TYPE) IS
         SELECT craplim.nrdconta
               ,craplim.cddlinha
               ,craplim.dtinivig
               ,craplim.vllimite
               ,craplim.idcobope
               ,MAX (craplim.progress_recid) OVER (partition by craplim.nrdconta) maior
         FROM craplim craplim
         WHERE  craplim.cdcooper = pr_cdcooper
         AND    craplim.tpctrlim = 1
         AND    craplim.insitlim = 2;
       rw_craplim cr_craplim%ROWTYPE;

       --Selecionar informacoes das linhas de credito rotativos
       CURSOR cr_craplrt (pr_cdcooper IN craplrt.cdcooper%TYPE) IS
         SELECT craplrt.cddlinha
               ,craplrt.ROWID
               ,craplrt.qtdiavig
         FROM craplrt  craplrt
         WHERE  craplrt.cdcooper = pr_cdcooper;
       rw_craplrt cr_craplrt%ROWTYPE;

       -- Busca das cotas do associado
       CURSOR cr_crapcot(pr_nrdconta IN crapass.nrdconta%TYPE) IS
         SELECT cot.vldcotas
           FROM crapcot cot
          WHERE cot.cdcooper = pr_cdcooper
            AND cot.nrdconta = pr_nrdconta;
       vr_vldcotas crapcot.vldcotas%TYPE;
       
       -- Busca lancamento automatico
       CURSOR cr_craplau(pr_cdcooper IN craplau.cdcooper%TYPE,
                         pr_dtmvtolt IN craplau.dtmvtolt%TYPE) IS
         SELECT NVL(MAX(lau.nrseqdig),0) nrseqdig
           FROM craplau lau
          WHERE lau.cdcooper = pr_cdcooper
            AND lau.dtmvtolt = pr_dtmvtolt
            AND lau.cdagenci = 1
            AND lau.cdbccxlt = 100
            AND lau.nrdolote = 9999;
      rw_craplau cr_craplau%ROWTYPE;
     
      -- Controle de cobranca de lancamentos futuros em conta corrente
      CURSOR cr_tbcc_lautom_controle(pr_idlancto IN NUMBER) IS
        SELECT 1
          FROM tbcc_lautom_controle tbcc
         WHERE tbcc.idlautom = pr_idlancto;
        rw_tbcc_lautom_controle cr_tbcc_lautom_controle%ROWTYPE;


       --Selecionar informacoes da Central de Risco referente a ADP
       CURSOR cr_ris_adp (pr_nrdconta IN crapris.nrdconta%TYPE
                         ,pr_dtrefere IN crapris.dtrefere%TYPE) IS
         SELECT r.dtinictr -- Data em que entrou em ADP
               ,r.qtdriclq
           FROM crapris r
          WHERE r.cdcooper = pr_cdcooper
            AND r.nrdconta = pr_nrdconta
            AND r.dtrefere = pr_dtrefere
            AND r.nrctremp = pr_nrdconta -- Contrato ADP = NrdConta
            AND r.cdmodali = 101; -- ADP
       rw_ris_adp      cr_ris_adp%ROWTYPE;

       /* Variaveis Locais da pc_crps001 */

       --Variaveis dos Indices
       vr_index_crapsda PLS_INTEGER;
       vr_index_crapsld PLS_INTEGER;

       --Variaveis dos saldos
       vr_vlsddisp  NUMBER:= 0;
       vr_vlsdchsl  NUMBER:= 0;
       vr_vlsdbloq  NUMBER:= 0;
       vr_vlsdblpr  NUMBER:= 0;
       vr_vlsdblfp  NUMBER:= 0;
       vr_vltsallq  NUMBER:= 0;
       vr_vlutiliz  NUMBER:= 0;
       vr_vlantuti  NUMBER:= 0;
       vr_vlsmpmes  NUMBER:= 0;
       vr_vlsmnesp  NUMBER:= 0;
       vr_vlsmnmes  NUMBER:= 0;
       vr_vlsmnblq  NUMBER:= 0;
       vr_vldispon  NUMBER:= 0;
       vr_vlbloque  NUMBER:= 0;
       vr_vlcalcul  NUMBER:= 0;
       vr_vlcobsld  NUMBER:= 0;
       vr_qtddsdev  NUMBER:= 0;
       vr_qtlanmes  NUMBER:= 0;
       vr_nrseqdig  NUMBER:= 0;
       vr_nrdconta  NUMBER:= 0;
       vr_vllimcre  NUMBER:= 0;
       vr_tpextcta  NUMBER:= 0;
       vr_cdcritic  NUMBER:= 0;
       vr_nrchqsdv  NUMBER:= 0;
       vr_qtdiaute  NUMBER:= 0;
       --Variaveis de Controle de Restart
       vr_nrctares  INTEGER:= 0;
       vr_inrestar  INTEGER:= 0;
       vr_dsrestar  crapres.dsrestar%TYPE;
       vr_natjurid  crapjur.natjurid%TYPE;
       vr_tpregtrb  crapjur.tpregtrb%TYPE;
       vr_vltaxa_iof_principal NUMBER := 0;

       --Variaveis de controle de data
       vr_dtfimvig  DATE;
       vr_dtmvtolt  DATE;
       vr_dtmvtopr  DATE;
       vr_dtmvtoan  DATE;

       vr_dtrisclq_aux DATE;
	   vr_dtcorte_prm  DATE;

       vr_qtddsdev_aux  NUMBER:= 0;

       -- Variáveis de CPMF
       vr_dtinipmf DATE;
       vr_dtfimpmf DATE;
       vr_txcpmfcc NUMBER(12,6);
       vr_txrdcpmf NUMBER(12,6);
       vr_indabono INTEGER;
       vr_dtiniabo DATE;

       --Variaveis de impostos
       vr_vliofant  NUMBER:= 0;
       vr_vliofatu  NUMBER:= 0;
       vr_vldoipmf  NUMBER:= 0;
       vr_vlipmfap  NUMBER:= 0;
       vr_vlipmfpg  NUMBER:= 0;
       vr_vlbasipm  NUMBER:= 0;
       vr_vlbasiof  NUMBER:= 0;
       vr_vliof_principal NUMBER := 0;
       vr_qtdiaiof  INTEGER;

       --Variaveis diversas
       vr_flgestou  BOOLEAN;
       vr_flgquinz  BOOLEAN;
       vr_flgdcpmf  BOOLEAN;
       vr_flglimite BOOLEAN;
       vr_vldisvar  crapsld.vlsddisp%TYPE;
       vr_cdprogra  VARCHAR2(10);
       vr_dscritic  VARCHAR2(2000);
       vr_tab_erro  GENE0001.typ_tab_erro;
       vr_ingerneg  BOOLEAN := TRUE;
       vr_des_erro  VARCHAR2(100);
       vr_vlresgat  NUMBER;
       vr_vlsomvld  NUMBER;
       vr_tarindic  NUMBER := 0;
       vr_result    VARCHAR2(2000);

       vr_vliofpri NUMBER := 0; --> valor do IOF principal
       vr_vliofadi NUMBER := 0; --> valor do IOF adicional
       vr_vliofcpl NUMBER := 0; --> valor do IOF complementar
       vr_idlancto NUMBER;
       vr_flgimune PLS_INTEGER;
       --Tipo da tabela de saldos
       vr_tab_saldo EXTR0001.typ_tab_saldos;
       -- Cursor genérico de calendário
       rw_crapdat btch0001.cr_crapdat%ROWTYPE;

       --Variaveis de Excecao
       vr_exc_saida  EXCEPTION;
       vr_exc_fimprg EXCEPTION;

       vr_idprglog integer := 0;

       vr_vldjuros  NUMBER:= 0;
       vr_qtdiacor  NUMBER;
       vr_dsctajud crapprm.dsvlrprm%TYPE;

       vr_vlblqaco crapsda.vlblqaco%TYPE := 0;
			 vr_vlblqprj crapsda.vlblqprj%TYPE;
       vr_qtiasadp  PLS_INTEGER;  -- Quantidade de dias em ADP
       vr_inddebit  PLS_INTEGER;      -- 1-Debita IOF / 2 - Agenda IOF / 3 - Nao Debita
       
       -- variaveis para rotina de debito
       vr_tab_retorno   lanc0001.typ_reg_retorno;
       vr_incrineg      INTEGER;      -- Indicador de crítica do negócio

       --Procedure para limpar os dados das tabelas de memoria
       PROCEDURE pc_limpa_tabela IS
         BEGIN
           vr_tab_craphis.DELETE;
           vr_tab_crapass.DELETE;
           vr_tab_crapsda.DELETE;
           vr_tab_craplcm.DELETE;
           vr_tab_craplim.DELETE;
           vr_tab_craplrt.DELETE;
           vr_tab_qtdiavig.DELETE;
           vr_tab_crapsda2.DELETE;
           vr_tab_crapsld.DELETE;

         EXCEPTION
           WHEN OTHERS THEN
             --Variavel de erro recebe erro ocorrido
             vr_dscritic := 'Erro ao limpar tabelas de memória. Rotina pc_crps001.pc_limpa_tabela. '||sqlerrm;
             --Sair do programa
             RAISE vr_exc_saida;
         END;

     ---------------------------------------
     -- Inicio Bloco Principal pc_crps001
     ---------------------------------------
     BEGIN

       --Atribuir o nome do programa que está executando
       vr_cdprogra:= 'CRPS001';

       -- Incluir nome do módulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS001'
                                 ,pr_action => pr_cdcooper);

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
         vr_cdcritic := 1;
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
         --Atribuir a quantidade de dias uteis
         vr_qtdiaute:= rw_crapdat.qtdiaute;
       END IF;

       -- Validações iniciais do programa
       BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                 ,pr_flgbatch => 1
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_cdcritic => vr_cdcritic);

       --Se retornou critica aborta programa
       IF vr_cdcritic <> 0 THEN
         RAISE vr_exc_saida;
       END IF;

       -- Procedimento padrão de busca de informações de CPMF
       gene0005.pc_busca_cpmf(pr_cdcooper  => pr_cdcooper
                             ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
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
         -- Gerar raise
         RAISE vr_exc_saida;
       END IF;

       -- Lista de contas que nao podem debitar na conta corrente, devido a acao judicial
       vr_dsctajud := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                pr_cdcooper => pr_cdcooper,
                                                pr_cdacesso => 'CONTAS_ACAO_JUDICIAL');
     

       --Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;

       --Se a data data do movimento entiver entre a data de inicio e fim da cpmf
       vr_flgdcpmf:= vr_dtmvtolt BETWEEN vr_dtinipmf AND vr_dtfimpmf;

       /* Tratamento e retorno de valores de restart */
       BTCH0001.pc_valida_restart(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_flgresta => pr_flgresta
                                 ,pr_nrctares => vr_nrctares
                                 ,pr_dsrestar => vr_dsrestar
                                 ,pr_inrestar => vr_inrestar
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_des_erro => vr_dscritic);
       --Se ocrreu erro na validacao do restart
       IF vr_dscritic IS NOT NULL THEN
         --Levantar Excecao
         RAISE vr_exc_saida;
       ELSE
         --Atribuir valor saldo positivo no mes
         vr_vlsmpmes:= Nvl(GENE0002.fn_char_para_number(SUBSTR(vr_dsrestar,01,16)),0);
         --Atribuir valor negativo especial do mes
         vr_vlsmnesp:= Nvl(GENE0002.fn_char_para_number(SUBSTR(vr_dsrestar,18,16)),0);
         --Atribuir valor saldo negativo no mes
         vr_vlsmnmes:= Nvl(GENE0002.fn_char_para_number(SUBSTR(vr_dsrestar,35,16)),0);
         --Atribuir media saque sem bloqueado
         vr_vlsmnblq:= Nvl(GENE0002.fn_char_para_number(SUBSTR(vr_dsrestar,52,16)),0);
       END IF;

       -- Tratar restart null
       vr_nrctares := nvl(vr_nrctares,0);

       --Leitura do numero de dias para saldo devedor
       OPEN cr_craptab (pr_cdcooper => pr_cdcooper
                       ,pr_nmsistem => 'CRED'
                       ,pr_tptabela => 'USUARI'
                       ,pr_cdempres => 0
                       ,pr_cdacesso => 'DIASCREDLQ'
                       ,pr_tpregist => 0);
       --Posicionar no proximo registro
       FETCH cr_craptab INTO rw_craptab;
       --Se nao encontrou entao
       IF cr_craptab%NOTFOUND THEN
         --Fechar cursor
         CLOSE cr_craptab;
         --Buscar mensagem de erro da critica
         vr_cdcritic:= 210;
         --Sair do programa
         RAISE vr_exc_saida;
       ELSE
         --Atribuir quantidade de dias devedor
         vr_qtddsdev:= GENE0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,1,3));
       END IF;
       --Fechar cursor
       CLOSE cr_craptab;

       --Carregar tabela de memoria de historicos
       FOR rw_craphis IN cr_craphis (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_craphis(rw_craphis.cdhistor).cdhistor:= rw_craphis.cdhistor;
         vr_tab_craphis(rw_craphis.cdhistor).inhistor:= rw_craphis.inhistor;
         vr_tab_craphis(rw_craphis.cdhistor).indebcre:= rw_craphis.indebcre;
         vr_tab_craphis(rw_craphis.cdhistor).indoipmf:= rw_craphis.indoipmf;
       END LOOP;

       --Carregar tabela memoria de associados
       FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_crapass(rw_crapass.nrdconta).nrdconta:= rw_crapass.nrdconta;
         vr_tab_crapass(rw_crapass.nrdconta).vllimcre:= rw_crapass.vllimcre;
         vr_tab_crapass(rw_crapass.nrdconta).tpextcta:= rw_crapass.tpextcta;
         vr_tab_crapass(rw_crapass.nrdconta).inpessoa:= rw_crapass.inpessoa;
         vr_tab_crapass(rw_crapass.nrdconta).inprejuz:= rw_crapass.inprejuz;
       END LOOP;

       --Carregar tabela memoria de associados
       FOR rw_crapjur IN cr_crapjur (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_crapjur(rw_crapjur.nrdconta).natjurid := rw_crapjur.natjurid;
         vr_tab_crapjur(rw_crapjur.nrdconta).tpregtrb := rw_crapjur.tpregtrb;
       END LOOP;

       --Carregar tabela memoria de saldos diarios dos associados
       FOR rw_crapsda IN cr_crapsda (pr_cdcooper => pr_cdcooper
                                    ,pr_dtmvtolt => vr_dtmvtoan) LOOP
         vr_tab_crapsda(rw_crapsda.nrdconta).nrdconta:= rw_crapsda.nrdconta;
         vr_tab_crapsda(rw_crapsda.nrdconta).vlsddisp:= rw_crapsda.vlsddisp;
       END LOOP;

       --Carregar tabela memoria com as contas com lancamento no dia
       FOR rw_craplcm IN cr_craplcm2(pr_cdcooper => pr_cdcooper
                                    ,pr_dtmvtolt => vr_dtmvtolt) LOOP
		     --	 Tratar conta corrente invalida no cadastro de lançamento - 03/07/2018 - Chamado REQ0018868
         BEGIN
           vr_tab_craplcm(rw_craplcm.nrdconta):= rw_craplcm.nrdconta;
         EXCEPTION
           WHEN OTHERS THEN
             CECRED.pc_internal_exception(pr_cdcooper);
             BEGIN
               cecred.pc_log_programa(pr_dstiplog      => 'E'
                                     ,pr_cdprograma    => 'CRPS001'
                                     ,pr_cdcooper      => pr_cdcooper
                                     ,pr_tpocorrencia  => 1 -- Erro de negocio
                                     ,pr_cdcriticidade => 2
                                     ,pr_cdmensagem    => 9999
                                     ,pr_dsmensagem    => gene0001.fn_busca_critica(pr_cdcritic => 9999) ||
                                                          'Lançamento com conta invalida.' ||
                                                          '  dtmvtolt:'   || vr_dtmvtolt   ||
                                                          ', nrdconta:'   || rw_craplcm.nrdconta ||
                                                          '.' || SQLERRM
                                     ,pr_idprglog     => vr_idprglog);
             EXCEPTION
               WHEN OTHERS THEN
                 CECRED.pc_internal_exception(pr_cdcooper);
             END;
         END;
       END LOOP;

       --Carregar tabela memoria com os limites de credito das contas
       FOR rw_craplim IN cr_craplim (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_craplim(rw_craplim.nrdconta).nrdconta:= rw_craplim.nrdconta;
         vr_tab_craplim(rw_craplim.nrdconta).cddlinha:= rw_craplim.cddlinha;
         vr_tab_craplim(rw_craplim.nrdconta).dtinivig:= rw_craplim.dtinivig;
         vr_tab_craplim(rw_craplim.nrdconta).vllimite:= rw_craplim.vllimite;
         vr_tab_craplim(rw_craplim.nrdconta).idcobope:= rw_craplim.idcobope;
       END LOOP;

       --Carregar tabela memoria com as linhas de credito
       FOR rw_craplrt IN cr_craplrt (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_craplrt(rw_craplrt.cddlinha):= rw_craplrt.cddlinha;
         vr_tab_qtdiavig(rw_craplrt.cddlinha) := rw_craplrt.qtdiavig;
       END LOOP;

       --Atribuir false para flag de quinzenal
       vr_flgquinz:= FALSE;

       -- Se o dia da data de operacao for maior 15
       IF To_Number(To_Char(vr_dtmvtopr,'DD')) > 15 THEN
         --Tabela com a indicacao de execucao quinzenal
         OPEN cr_craptab (pr_cdcooper => pr_cdcooper
                       ,pr_nmsistem => 'CRED'
                       ,pr_tptabela => 'GENERI'
                       ,pr_cdempres => 0
                       ,pr_cdacesso => 'EXEQUINZEN'
                       ,pr_tpregist => 1);
         --Posicionar no proximo registro
         FETCH cr_craptab INTO rw_craptab;
         --Se nao encontrou entao
         IF cr_craptab%NOTFOUND THEN
           --Buscar mensagem de erro da critica
           vr_cdcritic := 571;
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic || ' CRED-GENERI-00-EZEQUINZEN-001');
           --Fechar cursor
           CLOSE cr_craptab;
           --Sair do programa
           RAISE vr_exc_saida;
         ELSE
           --Atribuir true/false para flag quinzenal
           vr_flgquinz:= rw_craptab.dstextab = '0';
         END IF;
         --Fechar cursor
         CLOSE cr_craptab;
       END IF;

       -- Buscar dias corridos para a cobrança de juros
       vr_qtdiacor:= gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                               pr_cdcooper => pr_cdcooper,
                                               pr_cdacesso => 'PARLIM_QTDIACOR');  
                                               
       --Pesquisar o saldo dos associados
       FOR rw_crapsld IN cr_crapsld (pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => vr_nrctares) LOOP
         --Inicio da transacao 1
         BEGIN

           --Se encontrou limite de credito para a conta
           IF vr_tab_craplim.EXISTS(rw_crapsld.nrdconta) THEN
             --Numero da conta recebe o valor do cursor
             rw_craplim.nrdconta:= vr_tab_craplim(rw_crapsld.nrdconta).nrdconta;
             --Linha de Credito recebe o valor do cursor
             rw_craplim.cddlinha:= vr_tab_craplim(rw_crapsld.nrdconta).cddlinha;
             --Data de Vigencia recebe valor do cursor
             rw_craplim.dtinivig:= vr_tab_craplim(rw_crapsld.nrdconta).dtinivig;
             --Valor do limite recebe valor do cursor
             rw_craplim.vllimite:= vr_tab_craplim(rw_crapsld.nrdconta).vllimite;
             --Valor do idcobope recebe valor do cursor
             rw_craplim.idcobope := vr_tab_craplim(rw_crapsld.nrdconta).idcobope;
             --Atribuir verdadeiro para flag existe craplim
             vr_flglimite:= TRUE;
           ELSE
             --Zerar limite de credito
             rw_craplim.vllimite:= 0;
             --Atribuir falso para flag existe craplim
             vr_flglimite:= FALSE;
           END IF;

           -- Condicao para verificar se a empresa existe
           IF vr_tab_crapjur.EXISTS(rw_crapsld.nrdconta) THEN
             -- Natureza Juridica
             vr_natjurid := vr_tab_crapjur(rw_crapsld.nrdconta).natjurid;
             -- Regime de Tributacao
             vr_tpregtrb := vr_tab_crapjur(rw_crapsld.nrdconta).tpregtrb;
           ELSE
             -- Natureza Juridica             
             vr_natjurid := 0;
             -- Regime de Tributacao
             vr_tpregtrb := 0;
           END IF;

           --Se for primeiro dia util e tiver IOF a cobrar
           IF To_Char(vr_dtmvtolt,'MM') <> To_Char(vr_dtmvtoan,'MM') THEN

             IF round(rw_crapsld.vliofmes,2) > 0 THEN

                 --Se o usuario existir na tabela de memoria e for pessoa fisica ou juridica
                 IF vr_tab_crapass.EXISTS(rw_crapsld.nrdconta) AND
                    vr_tab_crapass(rw_crapsld.nrdconta).inpessoa < 3 THEN

                    -- Verificar Saldo do cooperado
                    extr0001.pc_obtem_saldo_dia(pr_cdcooper => pr_cdcooper, 
                                                pr_rw_crapdat => rw_crapdat, 
                                                pr_cdagenci => 1, 
                                                pr_nrdcaixa => 0, 
                                                pr_cdoperad => '1', 
                                                pr_nrdconta => rw_crapsld.nrdconta, 
                                                pr_vllimcre => vr_tab_crapass(rw_crapsld.nrdconta).vllimcre, 
                                                pr_dtrefere => rw_crapdat.dtmvtolt, 
                                                pr_flgcrass => FALSE, 
                                                pr_tipo_busca => 'A', -- Tipo Busca(A-dtmvtoan)
                                                pr_des_reto => vr_des_erro, 
                                                pr_tab_sald => vr_tab_saldo, 
                                                pr_tab_erro => vr_tab_erro);
                                                                  
                    --Se ocorreu erro
                    IF vr_des_erro = 'NOK' THEN
                      -- Tenta buscar o erro no vetor de erro
                      IF vr_tab_erro.COUNT > 0 THEN
                        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_crapsld.nrdconta;
                      ELSE
                        vr_cdcritic:= 0;
                        vr_dscritic:= 'Retorno "NOK" na extr0001.pc_obtem_saldo_dia e sem informação na pr_tab_erro, Conta: '||rw_crapsld.nrdconta;
                      END IF;
                                    
                      IF vr_cdcritic <> 0 THEN
                        vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' Conta: '||rw_crapsld.nrdconta;
                      END IF;                              

                      --Levantar Excecao
                      RAISE vr_exc_saida;
                    ELSE
                      vr_dscritic:= NULL;
                    END IF;

                    --Verificar o saldo retornado
                    IF vr_tab_saldo.Count = 0 THEN
                      --Montar mensagem erro
                      vr_cdcritic:= 0;
                      vr_dscritic:= 'Nao foi possivel consultar o saldo para a operacao.';                                              
                      --Levantar Excecao
                      RAISE vr_exc_saida;
                    ELSE
                      vr_vlsddisp := nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) +
                                     nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0);
                    END IF; 

                      
                 -- BACKLOG ITEM 6761:DÉBITO IOF RENDAS A APROPRIAR
                 -- NOVAS REGRAS
                 -- Débito de IOF sobre Limite de Crédito e Conta Corrente

                 -- No primeiro mês (primeiros 30 dias) deverá ser debitado o valor de IOF
                 -- independente de possuir saldo disponível (saldo total) em conta corrente.

                 -- Após o primeiro mês o Sistema deverá verificar o saldo em conta corrente:
                 
                 -- Se houver saldo disponível para o débito de IOF (valor em conta corrente ou
                 -- dentro do limite de crédito), então o débito deverá ser efetuado. 
                 -- Se não houver saldo disponível, não será efetuado o débito. O valor deverá
                 -- permanecer na Lautom e lançado no campo IOF a debitar.
                 -- Não será estourada a conta para efetuar o débito de IOF.

                 -- Observação: Essa provisão ocorre somente se o cooperado permanecer no ADP por
                 -- dois meses consecutivos. Se durante o segundo mês o cooperado cobrir a conta
                 -- e entrar novamente no ADP a contagem de dias inicia-se novamente.
                     
                 -- VERIFICAR SE TEM ADP DA CENTRAL DE RISCO (CURSOR)
                 OPEN cr_ris_adp (pr_nrdconta => rw_crapsld.nrdconta
                                 ,pr_dtrefere => rw_crapdat.dtultdma); -- DtUltDma => pois só entra no 1ºdia mes
                 FETCH cr_ris_adp INTO rw_ris_adp;
                       
                 vr_qtiasadp := 0;
                 vr_inddebit := 0;
                       
                 IF cr_ris_adp%FOUND THEN -- ESTÁ EM ADP
                   CLOSE cr_ris_adp;
                         
                   -- QUANTOS DIAS ESTÁ NO ADP
                   vr_qtiasadp := vr_dtmvtolt - rw_ris_adp.dtinictr; -- DIAS CORRIDOS
                   IF vr_qtiasadp <= 30 THEN
                     -- SE MENOS QUE 30, DEBITA IOF
                     IF  round(rw_crapsld.vliofmes,2) > vr_vlsddisp
                     AND vr_qtdiacor > 0 THEN
                       vr_inddebit := 2;
                     ELSE
                       vr_inddebit := 1;
                     END IF;
                     
                   ELSE -- SE MAIS QUE 30, VALIDAR SALDO
                                
                     IF  round(rw_crapsld.vliofmes,2) > vr_vlsddisp THEN
                       -- SE IOF MAIOR QUE SALDO, NAO ESTOURA A CONTA, NAO DEBITA
                       vr_inddebit := 3; -- NAO DEBITA
                     ELSE
                       -- DEBITA, POREM, EFETUA VALIDAÇÃO QUE JA FAZIA
                       IF  round(rw_crapsld.vliofmes,2) > vr_vlsddisp
                       AND vr_qtdiacor > 0 THEN
                         vr_inddebit := 2;
                       ELSE
                         vr_inddebit := 1;
                       END IF;
                     END IF;
                   END IF;
             
                 ELSE -- TEVE DEBITO IOF ANTES, MAS NAO ESTÁ MAIS EM ADP
                   CLOSE cr_ris_adp;
                   -- FAZ O QUE JA FAZIA
                   IF  round(rw_crapsld.vliofmes,2) > vr_vlsddisp
                   AND vr_qtdiacor > 0 THEN
                     vr_inddebit := 2;
                   ELSE
                     vr_inddebit := 1;
                   END IF;
                 END IF;
                 
                 vr_tarindic := vr_tarindic + 1;
                 
                 -- Criado tratamento para vr_inddebit decorrente da nova regra debito IOF
                 CASE vr_inddebit
                   WHEN 1 THEN
                     -- segue criando registro na conta corrente
                   --Verificar se o lote existe
                   OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                                   ,pr_dtmvtolt => vr_dtmvtolt
                                   ,pr_cdagenci => 1
                                   ,pr_cdbccxlt => 100
                                   ,pr_nrdolote => 8450);
                   --Posicionar no proximo registro
                   FETCH cr_craplot INTO rw_craplot;
                   --Se encontrou registro
                   IF cr_craplot%NOTFOUND THEN
                     --Criar lote
                     BEGIN
                       --Inserir a capa do lote retornando informacoes para uso posterior
                       INSERT INTO craplot (cdcooper
                                           ,dtmvtolt
                                           ,cdagenci
                                           ,cdbccxlt
                                           ,nrdolote
                                           ,tplotmov)
                                   VALUES  (pr_cdcooper
                                           ,vr_dtmvtolt
                                           ,1
                                           ,100
                                           ,8450
                                           ,1)
                                   RETURNING cdcooper
                                            ,dtmvtolt
                                            ,cdagenci
                                            ,cdbccxlt
                                            ,nrdolote
                                            ,tplotmov
                                            ,ROWID
                                   INTO  rw_craplot.cdcooper
                                        ,rw_craplot.dtmvtolt
                                        ,rw_craplot.cdagenci
                                        ,rw_craplot.cdbccxlt
                                        ,rw_craplot.nrdolote
                                        ,rw_craplot.tplotmov
                                        ,rw_craplot.rowid;
                     EXCEPTION
                       WHEN OTHERS THEN
                         vr_dscritic := 'Erro ao inserir na tabela craplot. '||SQLERRM;
                         --Sair do programa
                         RAISE vr_exc_saida;
                     END;
                   END IF;
                   --Fechar Cursor
                   CLOSE cr_craplot;

                   --Inserir lancamento retornando o valor do rowid e do lançamento para uso posterior
                   BEGIN
                       LANC0001.pc_gerar_lancamento_conta(pr_cdcooper =>pr_cdcooper             -- cdcooper
                                                          ,pr_dtmvtolt =>rw_craplot.dtmvtolt     -- dtmvtolt
                                                          ,pr_cdagenci =>rw_craplot.cdagenci     -- cdagenci
                                                          ,pr_cdbccxlt =>rw_craplot.cdbccxlt     -- cdbccxlt
                                                          ,pr_nrdolote =>rw_craplot.nrdolote     -- nrdolote
                                                          ,pr_nrdconta =>rw_crapsld.nrdconta     -- nrdconta
                                                          ,pr_nrdctabb =>rw_crapsld.nrdconta     -- nrdctabb
                                                          ,pr_nrdctitg =>to_char(rw_crapsld.nrdconta,'fm00000000') -- nrdctitg
                                                          ,pr_nrdocmto =>99999323                -- nrdocmto
                                                          ,pr_cdhistor =>2323                    -- cdhistor
                                                          ,pr_nrseqdig =>Nvl(rw_craplot.nrseqdig,0) + 1 -- nrseqdig
                                                          ,pr_vllanmto =>round(rw_crapsld.vliofmes,2)   -- vllanmto
                                                          ,pr_cdpesqbb =>to_char(rw_crapsld.vlbasiof,'fm000g000g000d00')                       -- cdpesqbb
                                                          ,pr_vldoipmf =>0                       -- vldoipmf
                                                          -- OUTPUT --
                                                          ,pr_tab_retorno => vr_tab_retorno
                                                          ,pr_incrineg => vr_incrineg
                                                          ,pr_cdcritic => vr_cdcritic
                                                          ,pr_dscritic => vr_dscritic);

                       IF nvl(vr_cdcritic, 0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
                           RAISE vr_exc_saida;
                       END IF;
                       rw_craplcm.rowid := vr_tab_retorno.rowidlct;
                       vr_nrseqdig := Nvl(rw_craplot.nrseqdig,0) + 1;
                       rw_craplcm.vllanmto := round(rw_crapsld.vliofmes,2) ;


                     -- Se na carga inicial não haviam lançamentos do dia para a conta
                     IF NOT vr_tab_craplcm.EXISTS(rw_crapsld.nrdconta) THEN
                       -- Indica que agora há
                       vr_tab_craplcm(rw_crapsld.nrdconta):= rw_crapsld.nrdconta;
                     END IF;
                   EXCEPTION
										 WHEN vr_exc_saida THEN
											 RAISE vr_exc_saida; -- Relança a exceção para ser tratada fora do bloco BEGIN...END
                     WHEN OTHERS THEN
                       vr_dscritic := 'Erro ao inserir na tabela craplcm. '|| SQLERRM;
                       --Sair do programa
                       RAISE vr_exc_saida;
                   END;

                   --Atualizar capa do Lote
                   BEGIN
                     UPDATE craplot SET craplot.vlinfodb = Nvl(craplot.vlinfodb,0) + rw_craplcm.vllanmto
                                       ,craplot.vlcompdb = Nvl(craplot.vlcompdb,0) + rw_craplcm.vllanmto
                                       ,craplot.qtinfoln = Nvl(craplot.qtinfoln,0) + 1
                                       ,craplot.qtcompln = Nvl(craplot.qtcompln,0) + 1
                                       ,craplot.nrseqdig = Nvl(craplot.nrseqdig,0) + 1
                     WHERE craplot.ROWID = rw_craplot.ROWID;
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_dscritic := 'Erro ao atualizar tabela craplot. '||SQLERRM;
                       --Sair do programa
                       RAISE vr_exc_saida;
                   END;

                                        
                   --Populando a tabela temporaria com os dados
                   vr_tab_tarifas(vr_tarindic).cdcooper     := pr_cdcooper;
                   vr_tab_tarifas(vr_tarindic).nrdconta     := rw_crapsld.nrdconta;
                   vr_tab_tarifas(vr_tarindic).dtmvtolt     := rw_craplot.dtmvtolt;
                   vr_tab_tarifas(vr_tarindic).tpproduto    := 5;
                   vr_tab_tarifas(vr_tarindic).nrcontrato   := 0;
                   vr_tab_tarifas(vr_tarindic).idlautom     := NULL;
                   vr_tab_tarifas(vr_tarindic).cdagenci_lcm := rw_craplot.cdagenci;
                   vr_tab_tarifas(vr_tarindic).cdbccxlt_lcm := rw_craplot.cdbccxlt;
                   vr_tab_tarifas(vr_tarindic).nrdolote_lcm := rw_craplot.nrdolote;
                   vr_tab_tarifas(vr_tarindic).nrseqdig_lcm := vr_nrseqdig;
                   
                   --------------------------------------------------------------------------------------------------
                   -- Atualizar os dados do IOF
                   --------------------------------------------------------------------------------------------------
                   /*TIOF0001.pc_altera_iof(pr_cdcooper     => pr_cdcooper
                                         ,pr_nrdconta     => rw_crapsld.nrdconta
                                         ,pr_dtmvtolt     => rw_craplot.dtmvtolt
                                         ,pr_tpproduto    => 5
                                         ,pr_nrcontrato   => 0
                                         ,pr_cdagenci_lcm => rw_craplot.cdagenci
                                         ,pr_cdbccxlt_lcm => rw_craplot.cdbccxlt
                                         ,pr_nrdolote_lcm => rw_craplot.nrdolote
                                         ,pr_nrseqdig_lcm => vr_nrseqdig
                                         ,pr_cdcritic     => vr_cdcritic
                                         ,pr_dscritic     => vr_dscritic);
                                
                   -- Condicao para verificar se houve critica                             
                   IF vr_dscritic IS NOT NULL THEN
                     RAISE vr_exc_saida;
                   END IF;*/
                     
                   --Incrementar a quantidade de lancamentos no mes
                   rw_crapsld.qtlanmes:= Nvl(rw_crapsld.qtlanmes,0) + 1;
                   --Zerar valor iof no mes
                   rw_crapsld.vliofmes:= 0;
                   --Zerar valor base iof
                   rw_crapsld.vlbasiof:= 0;

                   WHEN 2 THEN
                     -- Se saldo do cooperado não suprir o lançamento e a qtd dias corridos for > 0
                     -- vamos agendar o lançamento na LAUTOM
                     vr_nrseqdig:= fn_sequence('CRAPLAU','NRSEQDIG',''||pr_cdcooper||';'||TO_CHAR(vr_dtmvtolt,'DD/MM/RRRR')||'');

                     BEGIN
                       INSERT INTO craplau
                                    (craplau.cdcooper
                                    ,craplau.dtmvtopg
                                    ,craplau.cdagenci
                                    ,craplau.cdbccxlt
                                    ,craplau.cdhistor
                                    ,craplau.dtmvtolt
                                    ,craplau.insitlau
                                    ,craplau.nrdconta
                                    ,craplau.nrdctabb
                                    ,craplau.nrdolote
                                    ,craplau.nrseqdig
                                    ,craplau.tpdvalor
                                    ,craplau.vllanaut
                                    ,craplau.nrdocmto
                                    ,craplau.dttransa
                                    ,craplau.hrtransa
                                    ,craplau.dsorigem)
                             VALUES (pr_cdcooper            -- craplau.cdcooper
                                    ,vr_dtmvtolt            -- craplau.dtmvtopg
                                    ,1                      -- craplau.cdagenci
                                    ,100                    -- craplau.cdbccxlt
                                    ,2323                   -- craplau.cdhistor
                                    ,vr_dtmvtolt            -- craplau.dtmvtolt
                                    ,1                      -- craplau.insitlau
                                    ,rw_crapsld.nrdconta    -- craplau.nrdconta
                                    ,rw_crapsld.nrdconta    -- craplau.nrdctabb
                                    ,8450                   -- craplau.nrdolote
                                    ,nvl(vr_nrseqdig,0) + 1 -- craplau.nrseqdig
                                    ,1                      -- craplau.tpdvalor
                                    ,round(rw_crapsld.vliofmes,2)  -- craplau.vllanaut
                                    ,99999323               -- craplau.nrdocmto
                                    ,vr_dtmvtolt            -- craplau.dttransa
                                    ,gene0002.fn_busca_time -- craplau.hrtransa
                                    ,'ADIOFJUROS')          -- craplau.dsorigem
                          RETURNING idlancto
                               INTO vr_idlancto;
                     EXCEPTION
                       WHEN OTHERS THEN
                         vr_dscritic := 'Erro ao inserir craplau: '||SQLERRM;
                         RAISE vr_exc_saida;
                     END;

                     -- Para cada craplau vamos criar um registro de controle
                     OPEN cr_tbcc_lautom_controle(pr_idlancto => vr_idlancto);
                     FETCH cr_tbcc_lautom_controle INTO rw_tbcc_lautom_controle;

                     IF cr_tbcc_lautom_controle%NOTFOUND THEN
                       CLOSE cr_tbcc_lautom_controle;

                       BEGIN
                         INSERT INTO tbcc_lautom_controle(cdcooper,
                                                          nrdconta,
                                                          dtmvtolt,
                                                          vloriginal,
                                                          idlautom,
                                                          insit_lancto,
                                                          cdhistor)
                                                   VALUES(pr_cdcooper
                                                         ,rw_crapsld.nrdconta
                                                         ,vr_dtmvtolt
                                                         ,round(rw_crapsld.vliofmes,2)
                                                         ,vr_idlancto
                                                         ,1
                                                         ,323);
                       EXCEPTION
                         WHEN OTHERS THEN
                           vr_dscritic := 'Erro ao inserir cr_tbcc_lautom_controle: '||SQLERRM;
                           RAISE vr_exc_saida;
                       END;
                     ELSE
                       CLOSE cr_tbcc_lautom_controle;
                 END IF;

                     --Populando a tabela temporaria com os dados
                     vr_tab_tarifas(vr_tarindic).cdcooper     := pr_cdcooper;
                     vr_tab_tarifas(vr_tarindic).nrdconta     := rw_crapsld.nrdconta;
                     vr_tab_tarifas(vr_tarindic).dtmvtolt     := rw_craplot.dtmvtolt;
                     vr_tab_tarifas(vr_tarindic).tpproduto    := 5;
                     vr_tab_tarifas(vr_tarindic).nrcontrato   := 0;
                     vr_tab_tarifas(vr_tarindic).idlautom     := vr_idlancto;
                     vr_tab_tarifas(vr_tarindic).cdagenci_lcm := NULL;
                     vr_tab_tarifas(vr_tarindic).cdbccxlt_lcm := NULL;
                     vr_tab_tarifas(vr_tarindic).nrdolote_lcm := NULL;
                     vr_tab_tarifas(vr_tarindic).nrseqdig_lcm := NULL;
                     
                     --------------------------------------------------------------------------------------------------
                     -- Atualizar os dados do IOF
                     --------------------------------------------------------------------------------------------------
                     /*TIOF0001.pc_altera_iof(pr_cdcooper   => pr_cdcooper
                                           ,pr_nrdconta   => rw_crapsld.nrdconta
                                           ,pr_dtmvtolt   => vr_dtmvtolt
                                           ,pr_tpproduto  => 5
                                           ,pr_nrcontrato => 0
                                           ,pr_idlautom   => vr_idlancto
                                           ,pr_cdcritic   => vr_cdcritic
                                           ,pr_dscritic   => vr_dscritic);

                     -- Condicao para verificar se houve critica
                     IF vr_dscritic IS NOT NULL THEN
                       RAISE vr_exc_saida;
                 END IF;*/

                     --Zerar valor iof no mes
                     rw_crapsld.vliofmes:= 0;
                     --Zerar valor base iof
                     rw_crapsld.vlbasiof:= 0;
                   
                   ELSE
                     -- Se 3 ou qualquer outro, nao faz nada
                     -- Deixa o IOF pendente
                     NULL;
                   
                 END CASE;
               END IF; -- FIM => é PF ou PJ
             END IF; -- FIM  vliofmes > 0

             IF rw_crapsld.vljuresp > 0 --Se o juros do cheque especial for maior zero
               AND NOT prej0003.fn_verifica_preju_conta(pr_cdcooper => pr_cdcooper
                                                      , pr_nrdconta => rw_crapsld.nrdconta) THEN -- E se a conta não estiver em prejuizo
               
               -- Condicao para verificar se permite incluir as linhas parametrizadas
               IF INSTR(',' || vr_dsctajud || ',',',' || rw_crapsld.nrdconta || ',') > 0 THEN
                 
                 OPEN cr_craplau(pr_cdcooper => pr_cdcooper,
                                 pr_dtmvtolt => vr_dtmvtolt);  
                 FETCH cr_craplau INTO rw_craplau;
                 
                 -- Fechar o cursor
                 CLOSE cr_craplau;            
               
                 BEGIN
                  INSERT INTO craplau
                              (craplau.cdcooper
                              ,craplau.dtmvtopg
                              ,craplau.cdagenci
                              ,craplau.cdbccxlt
                              ,craplau.cdhistor
                              ,craplau.dtmvtolt
                              ,craplau.insitlau
                              ,craplau.nrdconta
                              ,craplau.nrdctabb
                              ,craplau.nrdolote
                              ,craplau.nrseqdig
                              ,craplau.tpdvalor
                              ,craplau.vllanaut
                              ,craplau.nrdocmto
                              ,craplau.dttransa
                              ,craplau.hrtransa)
                       VALUES (pr_cdcooper            -- craplau.cdcooper
                              ,vr_dtmvtolt            -- craplau.dtmvtopg
                              ,1                      -- craplau.cdagenci
                              ,100                    -- craplau.cdbccxlt
                              ,38                     -- craplau.cdhistor
                              ,vr_dtmvtolt            -- craplau.dtmvtolt
                              ,1                      -- craplau.insitlau
                              ,rw_crapsld.nrdconta    -- craplau.nrdconta
                              ,rw_crapsld.nrdconta    -- craplau.nrdctabb
                              ,9999                   -- craplau.nrdolote
                              ,rw_craplau.nrseqdig + 1 -- craplau.nrseqdig
                              ,1                      -- craplau.tpdvalor
                              ,rw_crapsld.vljuresp    -- craplau.vllanaut
                              ,99999938               -- craplau.nrdocmto
                              ,vr_dtmvtolt            -- craplau.dttransa
                              ,gene0002.fn_busca_time);-- craplau.hrtransa
                  EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao inserir craplau: '||SQLERRM;
                    RAISE vr_exc_saida;
                  END;

               ELSE 
                  -- Verificar Saldo do cooperado
                  extr0001.pc_obtem_saldo_dia(pr_cdcooper => pr_cdcooper, 
                                              pr_rw_crapdat => rw_crapdat, 
                                              pr_cdagenci => 1, 
                                              pr_nrdcaixa => 0, 
                                              pr_cdoperad => '1', 
                                              pr_nrdconta => rw_crapsld.nrdconta, 
                                              pr_vllimcre => vr_tab_crapass(rw_crapsld.nrdconta).vllimcre, 
                                              pr_dtrefere => rw_crapdat.dtmvtolt, 
                                              pr_flgcrass => FALSE, 
                                              pr_tipo_busca => 'A', -- Tipo Busca(A-dtmvtoan)
                                              pr_des_reto => vr_des_erro, 
                                              pr_tab_sald => vr_tab_saldo, 
                                              pr_tab_erro => vr_tab_erro);
                                                                  
                  --Se ocorreu erro
                  IF vr_des_erro = 'NOK' THEN
                    -- Tenta buscar o erro no vetor de erro
                    IF vr_tab_erro.COUNT > 0 THEN
                      vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                      vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_crapsld.nrdconta;
                    ELSE
                      vr_cdcritic:= 0;
                      vr_dscritic:= 'Retorno "NOK" na extr0001.pc_obtem_saldo_dia e sem informação na pr_tab_erro, Conta: '||rw_crapsld.nrdconta;
                    END IF;
                                    
                    IF vr_cdcritic <> 0 THEN
                      vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' Conta: '||rw_crapsld.nrdconta;
                    END IF;                              

                    --Levantar Excecao
                    RAISE vr_exc_saida;
                  ELSE
                    vr_dscritic:= NULL;
                  END IF;
                  --Verificar o saldo retornado
                  IF vr_tab_saldo.Count = 0 THEN
                    --Montar mensagem erro
                    vr_cdcritic:= 0;
                    vr_dscritic:= 'Nao foi possivel consultar o saldo para a operacao.';                                              
                    --Levantar Excecao
                    RAISE vr_exc_saida;
                  ELSE
                    vr_vlsddisp := nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) +
                                   nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0);
                  END IF; 

                   -- Se saldo do cooperado não suprir o lançamento e a qtd dias corridos for > 0
                   -- vamos agendar o lançamento na LAUTOM
                   IF rw_crapsld.vljuresp > vr_vlsddisp AND vr_qtdiacor > 0 THEN                   
                        
                     vr_nrseqdig:= fn_sequence('CRAPLAU','NRSEQDIG',''||pr_cdcooper||';'||TO_CHAR(vr_dtmvtolt,'DD/MM/RRRR')||'');
                       
                     BEGIN
                      INSERT INTO craplau
                                  (craplau.cdcooper
                                  ,craplau.dtmvtopg
                                  ,craplau.cdagenci
                                  ,craplau.cdbccxlt
                                  ,craplau.cdhistor
                                  ,craplau.dtmvtolt
                                  ,craplau.insitlau
                                  ,craplau.nrdconta
                                  ,craplau.nrdctabb
                                  ,craplau.nrdolote
                                  ,craplau.nrseqdig
                                  ,craplau.tpdvalor
                                  ,craplau.vllanaut
                                  ,craplau.nrdocmto
                                  ,craplau.dttransa
                                  ,craplau.hrtransa
                                  ,craplau.dsorigem)
                           VALUES (pr_cdcooper            -- craplau.cdcooper
                                  ,vr_dtmvtolt            -- craplau.dtmvtopg
                                  ,1                      -- craplau.cdagenci
                                  ,100                    -- craplau.cdbccxlt
                                  ,38                    -- craplau.cdhistor
                                  ,vr_dtmvtolt            -- craplau.dtmvtolt
                                  ,1                      -- craplau.insitlau
                                  ,rw_crapsld.nrdconta    -- craplau.nrdconta
                                  ,rw_crapsld.nrdconta    -- craplau.nrdctabb
                                  ,8450                   -- craplau.nrdolote
                                  ,nvl(vr_nrseqdig,0) + 1 -- craplau.nrseqdig
                                  ,1                      -- craplau.tpdvalor
                                  ,rw_crapsld.vljuresp    -- craplau.vllanaut
                                  ,99999938               -- craplau.nrdocmto
                                  ,vr_dtmvtolt            -- craplau.dttransa
                                  ,gene0002.fn_busca_time -- craplau.hrtransa
                                  ,'ADIOFJUROS')          -- craplau.dsorigem
                        RETURNING idlancto 
                             INTO vr_idlancto; 
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_dscritic := 'Erro ao inserir craplau: '||SQLERRM;
                          RAISE vr_exc_saida;
                      END;
                         
                     -- Para cada craplau vamos criar um registro de controle
                     OPEN cr_tbcc_lautom_controle(pr_idlancto => vr_idlancto);
                     FETCH cr_tbcc_lautom_controle INTO rw_tbcc_lautom_controle;
                         
                     IF cr_tbcc_lautom_controle%NOTFOUND THEN
                       CLOSE cr_tbcc_lautom_controle;
                           
                       BEGIN
                         INSERT INTO tbcc_lautom_controle(cdcooper, 
                                                          nrdconta, 
                                                          dtmvtolt, 
                                                          vloriginal, 
                                                          idlautom, 
                                                          insit_lancto, 
                                                          cdhistor) 
                                                   VALUES(pr_cdcooper
                                                         ,rw_crapsld.nrdconta
                                                         ,vr_dtmvtolt
                                                         ,rw_crapsld.vljuresp
                                                         ,vr_idlancto
                                                         ,1
                                                         ,38);
                         EXCEPTION  
                           WHEN OTHERS THEN
                            vr_dscritic := 'Erro ao inserir cr_tbcc_lautom_controle: '||SQLERRM;
                            RAISE vr_exc_saida;
                        END;
                           
                     ELSE
                       CLOSE cr_tbcc_lautom_controle;
                     END IF;
                         
                     --Acumular o valor do lancamento nos juros
                     vr_vldjuros:= Nvl(vr_vldjuros,0) + Nvl(rw_crapsld.vljuresp,0);
                     
                   ELSE -- Caso contrario segue criando registro na conta corrente

                 --Verificar se o lote existe
                 OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                                 ,pr_dtmvtolt => vr_dtmvtolt
                                 ,pr_cdagenci => 1
                                 ,pr_cdbccxlt => 100
                                 ,pr_nrdolote => 8450);
                 --Posicionar no proximo registro
                 FETCH cr_craplot INTO rw_craplot;

                    --Se nao encontrou registro
                 IF cr_craplot%NOTFOUND THEN
                   --Criar lote
				   close cr_craplot;

                   BEGIN
                     --Inserir a capa do lote retornando informacoes para uso posterior
                        LANC0001.pc_incluir_lote(pr_dtmvtolt => vr_dtmvtolt
                                               , pr_cdagenci => 1
                                               , pr_cdbccxlt => 100
                                               , pr_nrdolote => 8450
                                               , pr_tplotmov => 1
                                               , pr_cdcooper => pr_cdcooper
                                               , pr_rw_craplot => vr_rw_craplot
                                               , pr_cdcritic => vr_cdcritic
                                               , pr_dscritic => vr_dscritic);

                        IF nvl(vr_cdcritic, 0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
                           RAISE vr_exc_saida;
                        END IF;

                        -- carrega ultmo lote criado
                        OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                                        ,pr_dtmvtolt => vr_dtmvtolt
                                        ,pr_cdagenci => 1
                                        ,pr_cdbccxlt => 100
                                        ,pr_nrdolote => 8450);
                        FETCH cr_craplot INTO rw_craplot;

                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_dscritic := 'Erro ao inserir na tabela craplot. '||SQLERRM;
                       --Sair do programa
                       RAISE vr_exc_saida;
                   END;
                 END IF;
                 --Fechar Cursor
                 CLOSE cr_craplot;

                 --Inserir lancamento retornando o valor do rowid e do lançamento para uso posterior
                 BEGIN
                     LANC0001.pc_gerar_lancamento_conta( pr_cdagenci => rw_craplot.cdagenci
                                                       , pr_cdbccxlt => rw_craplot.cdbccxlt
                                                       , pr_nrdolote => rw_craplot.nrdolote
                                                       , pr_cdhistor => 38
                                                       , pr_dtmvtolt => rw_craplot.dtmvtolt
                                                       , pr_nrdconta => rw_crapsld.nrdconta
                                                       , pr_nrdctabb => rw_crapsld.nrdconta
                                                       , pr_nrdctitg => GENE0002.FN_MASK(rw_crapsld.nrdconta, '99999999')
                                                       , pr_nrdocmto => 99999938
                                                       , pr_nrseqdig => Nvl(rw_craplot.nrseqdig,0) + 1
                                                       , pr_vllanmto => rw_crapsld.vljuresp
                                                       , pr_cdcooper => pr_cdcooper
                                                       , pr_cdcoptfn => 0
                                                       , pr_vldoipmf => TRUNC(rw_crapsld.vljuresp * vr_txcpmfcc,2)
                                                       , pr_tab_retorno => vr_tab_retorno
	                                                     , pr_incrineg => vr_incrineg
                                                       , pr_cdcritic => vr_cdcritic
                                                       , pr_dscritic => vr_dscritic
                                                       );
                      IF nvl(vr_cdcritic, 0) > 0 OR trim(vr_dscritic) IS NOT NULL
                        AND vr_incrineg = 0 THEN -- Erro de sistema/BD
                         RAISE vr_exc_saida;
                      END IF;

                      -- guarda dados par serem utilizados mais a frente
                      rw_craplcm.vllanmto := rw_crapsld.vljuresp;
                      rw_craplcm.vldoipmf := TRUNC(rw_crapsld.vljuresp * vr_txcpmfcc,2);
                      rw_craplcm.rowid    := vr_tab_retorno.rowidlct;

                   -- Se na carga inicial não haviam lançamentos do dia para a conta
                   IF NOT vr_tab_craplcm.EXISTS(rw_crapsld.nrdconta) THEN
                     -- Indica que agora há
                     vr_tab_craplcm(rw_crapsld.nrdconta):= rw_crapsld.nrdconta;
                   END IF;

                 EXCEPTION
                   WHEN OTHERS THEN
                     vr_dscritic := 'Erro ao inserir na tabela craplcm. '||SQLERRM;
                     --Sair do programa
                     RAISE vr_exc_saida;
                 END;

                 --Incrementar o total a debito
                 rw_craplot.vlinfodb:= Nvl(rw_craplot.vlinfodb,0) + Nvl(rw_craplcm.vllanmto,0);
                 --Incrementar o total a debito compensado
                 rw_craplot.vlcompdb:= Nvl(rw_craplot.vlcompdb,0) + Nvl(rw_craplcm.vllanmto,0);
                 --Incrementar a quantidade total de lancamentos
                 rw_craplot.qtinfoln:= Nvl(rw_craplot.qtinfoln,0) + 1;
                 --Incrementar a quantidade total de lancamentos compensados
                 rw_craplot.qtcompln:= Nvl(rw_craplot.qtcompln,0) + 1;
                 --Incrementar o numero sequencial da capa
                 rw_craplot.nrseqdig:= Nvl(rw_craplot.nrseqdig,0) + 1;
                 --Incrementar a quantidade de lancamentos no mes
                 rw_crapsld.qtlanmes:= Nvl(rw_crapsld.qtlanmes,0) + 1;
                 --Acumular o valor do lancamento nos juros
                 vr_vldjuros:= Nvl(vr_vldjuros,0) + Nvl(rw_craplcm.vllanmto,0);

                 --Se cobrar cpmf
                 IF vr_flgdcpmf THEN
                   --Acumular o valor do lancamento no valor base ipmf
                   vr_vlbasipm:= Nvl(vr_vlbasipm,0) + Nvl(rw_craplcm.vllanmto,0);
                   --Acumular no valor do ipmf o valor do ipmf existente no lancamento
                   vr_vldoipmf:= Nvl(vr_vldoipmf,0) + Nvl(rw_craplcm.vldoipmf,0);
                 END IF;

                 --Atualizar capa do Lote
                 BEGIN
                   UPDATE craplot SET craplot.vlinfodb = Nvl(craplot.vlinfodb,0) + rw_craplcm.vllanmto
                                     ,craplot.vlcompdb = Nvl(craplot.vlcompdb,0) + rw_craplcm.vllanmto
                                     ,craplot.qtinfoln = Nvl(craplot.qtinfoln,0) + 1
                                     ,craplot.qtcompln = Nvl(craplot.qtcompln,0) + 1
                                     ,craplot.nrseqdig = Nvl(craplot.nrseqdig,0) + 1
                   WHERE craplot.ROWID = rw_craplot.ROWID;
                 EXCEPTION
                   WHEN OTHERS THEN
                     vr_dscritic := 'Erro ao atualizar tabela craplot. '||SQLERRM;
                     --Sair do programa
                     RAISE vr_exc_saida;
                 END;
               
                 END IF; -- Final da verificacao do saldo 
               
               END IF;

             END IF;

           END IF; -- FIM bloco ==> Se for primeiro dia util e tiver IOF a cobrar

           --linha 477
           --Valor anterior utilizado recebe:
           --vlsdblfp = valor do saldo bloqueado fora da praca
           --vlsdbloq = valor saldo bloqueado
           --vlsdblpr = valor do saldo bloqueado praca
           --vlsdchsl = valor do saldo cheque salario
           --vlsddisp = valor do saldo disponivel
           vr_vlantuti:= Nvl(rw_crapsld.vlsdchsl,0) +
                         Nvl(rw_crapsld.vlsddisp,0);

           -- Inverte o sinal se o valor anterior utilizado for menor zero
           IF vr_vlantuti < 0 THEN
             vr_vlantuti:= vr_vlantuti * -1;
           ELSE
             --Zerar valor anterior
             vr_vlantuti:= 0;
           END IF;

           --Se encontrou registro saldo para a conta
           IF vr_tab_crapsda.EXISTS(rw_crapsld.nrdconta) THEN
             --Atribuir o valor saldo disponivel na tabela de saldo para o valor do iof anterior
             vr_vliofant:= vr_tab_crapsda(rw_crapsld.nrdconta).vlsddisp;
           ELSE
             --Zerar valor iof anterior
             vr_vliofant:= 0;
           END IF;

           -- Inverte o sinal se o valor do iof for negativo
           IF vr_vliofant < 0 THEN
             vr_vliofant:= vr_vliofant * -1;
           ELSE
             --Zerar valor iof anterior
             vr_vliofant:= 0;
           END IF;

           --Zerar variaveis de saldo
           vr_vlsddisp:= 0;  --saldo disponivel
           vr_vlsdchsl:= 0;  --saldo cheque salario
           vr_vlsdbloq:= 0;  --saldo bloqueado
           vr_vlsdblpr:= 0;  --saldo bloqueado praca
           vr_vlsdblfp:= 0;  --saldo bloqueado fora praca
           vr_vltsallq:= 0;  --salario liquido
           vr_vldoipmf:= 0;  --valor do ipmf
           vr_vlipmfap:= 0;  --valor do ipmf apurado
           vr_vlipmfpg:= 0;  --valor do ipmf a pagar
           vr_vlbasipm:= 0;  --base de calculo do ipmf
           vr_qtlanmes:= 0;  --quantidade de lancamentos no mes
           vr_vlbasiof:= 0;  --valor base de iof
           vr_vliof_principal := 0; --Valor do IOF Principal

           --Verificar se a conta possui lancamentos no dia
           IF vr_tab_craplcm.EXISTS(rw_crapsld.nrdconta) THEN
             --Percorrer vetor de lancamentos
             FOR rw_craplcm IN cr_craplcm (pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => rw_crapsld.nrdconta
                                          ,pr_dtmvtolt => vr_dtmvtolt) LOOP


               --Se nao encontrar o historico
               IF NOT vr_tab_craphis.EXISTS(rw_craplcm.cdhistor) THEN
                 --Buscar mensagem de erro da critica
                 vr_cdcritic := 83;
                 vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' CTA= '||rw_craplcm.nrdconta||
                                                                                         ' HST= '||rw_craplcm.cdhistor||
                                                                                         ' DOC= '||rw_craplcm.nrdocmto||
                                                                                         ' DAT= '||To_Char(rw_craplcm.dtmvtolt,'DD/MM/YYYY');
                 --Sair do programa
                 RAISE vr_exc_saida;

               ELSE
                 --Verificar o indicador do historico para somar ou subtrair o valor do lancamento
                 CASE vr_tab_craphis(rw_craplcm.cdhistor).inhistor
                   WHEN 1 THEN  --credito no vlsddisp
                     --Somar valor do lancamento ao Saldo disponivel
                     vr_vlsddisp:= Nvl(vr_vlsddisp,0) + rw_craplcm.vllanmto;
                   WHEN 2 THEN  --credito no vlsdchsl
                     --Somar valor do lancamento ao Saldo cheque salario
                     vr_vlsdchsl:= Nvl(vr_vlsdchsl,0) + rw_craplcm.vllanmto;
                   WHEN 3 THEN  --credito no vlsdbloq
                     --Somar valor do lancamento ao Saldo bloqueado
                     vr_vlsdbloq:= Nvl(vr_vlsdbloq,0) + rw_craplcm.vllanmto;
                   WHEN 4 THEN  --credito no vlsdblpr
                     --Somar valor do lancamento ao Saldo bloqueado na praca
                     vr_vlsdblpr:= Nvl(vr_vlsdblpr,0) + rw_craplcm.vllanmto;
                   WHEN 5 THEN  --credito no vlsdblfp
                     --Somar valor do lancamento ao Saldo bloqueado fora da praca
                     vr_vlsdblfp:= Nvl(vr_vlsdblfp,0) + rw_craplcm.vllanmto;
                   WHEN 11 THEN  --debito no vlsddisp
                     --Subtrair valor do lancamento do Saldo disponivel
                     vr_vlsddisp:= Nvl(vr_vlsddisp,0) - rw_craplcm.vllanmto;
                   WHEN 12 THEN  --debito no vlsdchsl
                     --Subtrair valor do lancamento do saldo cheque salario
                     vr_vlsdchsl:= Nvl(vr_vlsdchsl,0) - rw_craplcm.vllanmto;
                   WHEN 13 THEN  --debito no vlsdbloq
                     --Subtrair valor do lancamento do saldo bloqueado
                     vr_vlsdbloq:= Nvl(vr_vlsdbloq,0) - rw_craplcm.vllanmto;
                   WHEN 14 THEN  --debito no vlsdblpr
                     --Subtrair valor do lancamento do saldo bloqueado praca
                     vr_vlsdblpr:= Nvl(vr_vlsdblpr,0) - rw_craplcm.vllanmto;
                   WHEN 15 THEN --debito no vlsdblfp
                     --Subtrair valor do lancamento do saldo cheque fora praca
                     vr_vlsdblfp:= Nvl(vr_vlsdblfp,0) - rw_craplcm.vllanmto;
                   ELSE
                     --Buscar mensagem de erro da critica
                     vr_cdcritic := 83;
                     vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' CTA= '||rw_craplcm.nrdconta||
                                                                                             ' HST= '||rw_craplcm.cdhistor||
                                                                                             ' DOC= '||rw_craplcm.nrdocmto||
                                                                                             ' DAT= '||To_Char(rw_craplcm.dtmvtolt,'DD/MM/YYYY');
                     --Sair do programa
                     RAISE vr_exc_saida;
                 END CASE;
               END IF;

               --Zerar o valor do ipmf
               vr_vldoipmf:= 0;
               --Incrementar quantidade lancamentos lidos
               vr_qtlanmes:= Nvl(vr_qtlanmes,0) + 1;

               --Se for para calcular cpmf
               IF vr_flgdcpmf = TRUE THEN
                 --Se incidir impf (1-nao incide, 2-incide)
                 IF vr_tab_craphis(rw_craplcm.cdhistor).indoipmf  > 1 THEN
                   --Se a taxa da cpmf for maior zero
                   IF vr_txcpmfcc > 0 THEN
                     --Se for debito
                     IF vr_tab_craphis(rw_craplcm.cdhistor).indebcre  = 'D' THEN
                       --somar ao valor base ipmf o valor do lancamento
                       vr_vlbasipm:= Nvl(vr_vlbasipm,0) + rw_craplcm.vllanmto;
                       --valor do ipmf recebe valor do lancamento * taxa cpmf
                       vr_vldoipmf:= TRUNC(rw_craplcm.vllanmto * vr_txcpmfcc,2);
                       --somar ao valor do ipmf apurado o valor do impf
                       vr_vlipmfap:= Nvl(vr_vlipmfap,0) + Nvl(vr_vldoipmf,0);
                     ELSIF vr_tab_craphis(rw_craplcm.cdhistor).indebcre = 'C' THEN
                       --valor base ipmf recebe valor base ipmf menos valor do lancamento
                       vr_vlbasipm:= Nvl(vr_vlbasipm,0) - rw_craplcm.vllanmto;
                       --valor do ipmf recebe valor do lancamento * taxa cpmf
                       vr_vldoipmf:= TRUNC(rw_craplcm.vllanmto * vr_txcpmfcc,2);
                       --descontar o valor do impf do valor do ipmf apurado
                       vr_vlipmfap:= Nvl(vr_vlipmfap,0) - Nvl(vr_vldoipmf,0);
                     END IF;
                   END IF;
                 ELSIF vr_tab_craphis(rw_craplcm.cdhistor).inhistor = 12  THEN   --  Cheque salario
                   --Se nao for debito de transferencia de cheque salario
                   IF rw_craplcm.cdhistor <> 43   THEN
                     --somar ao valor base ipmf o valor do lancamento
                     vr_vlbasipm:= Nvl(vr_vlbasipm,0) + rw_craplcm.vllanmto;
                     --valor do ipmf recebe valor do lancamento * taxa cpmf
                     vr_vldoipmf:= TRUNC(rw_craplcm.vllanmto * vr_txcpmfcc,2);
                     --somar ao valor do ipmf apurado o valor do impf
                     vr_vlipmfap:= Nvl(vr_vlipmfap,0) + Nvl(vr_vldoipmf,0);
                     --Montar mensagem de erro
                     vr_dscritic := 'VERIFICAR  -' ||
                                   ' CTA= '|| rw_craplcm.nrdconta ||
                                   ' HST= '|| rw_craplcm.cdhistor ||
                                   ' BASE= '|| to_char(rw_craplcm.vllanmto,'FM9G999G990D00') ||
                                   ' CPMF= '|| To_Char(vr_vldoipmf,'FM9G999G990D00');
                     -- Envio centralizado de log de erro
                     btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                               ,pr_ind_tipo_log => 2 -- Erro tratato
                                               ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                || vr_cdprogra || ' --> '
                                                                || vr_dscritic);
                   END IF; --rw_craplcm.cdhistor <> 43
                 END IF;  --indoipmf  > 1
               END IF; --vr_flgdcpmf = TRUE

               /*  Atualiza os creditos de salario  */
               -- Se for credito de cheque salario ou cheque salario liquido
               IF rw_craplcm.cdhistor IN (7,8) THEN
                 --Somar o valor do lancamento ao Salario liquido
                 vr_vltsallq:= Nvl(vr_vltsallq,0) + rw_craplcm.vllanmto;
               END IF;

               -- Cria registro de devolucao de cheque
               -- Para os tipos de movimento abaixo
               -- --- ---------------
               --  47 CHQ.DEVOL.
               --  78 CH.DEV.TRF.
               -- 156 CHQ.DEVOL.COMPE CEF
               -- 191 CHQ.DEVOL.COMPE BB
               -- 338 CHQ.DEVOL.COMPE BANCOOB
               -- 573 CHQ.DEVOL.COMPE CECRED
               IF rw_craplcm.cdhistor IN (47,78,156,191,338,573) THEN
               
                 vr_ingerneg := TRUE;
               
                 --Se a conta anterior for diferente na conta do lancamento
                 IF Nvl(vr_nrdconta,0) <> rw_craplcm.nrdconta THEN
                   --Verificar se o associado existe
                   IF NOT vr_tab_crapass.EXISTS(rw_craplcm.nrdconta) THEN
                     --Buscar mensagem de erro da critica
                     vr_cdcritic := 251;
                     vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' CONTA = '||gene0002.fn_mask_conta(rw_crapsld.nrdconta);

                     --Abortar Programa
                     RAISE vr_exc_saida;
                   ELSE
                     --numero da conta anterior recebe o numero da conta do associado
                     vr_nrdconta:= vr_tab_crapass(rw_craplcm.nrdconta).nrdconta;
                     --Valor do limite de credito recebe o limite do associado
                     vr_vllimcre:= vr_tab_crapass(rw_craplcm.nrdconta).vllimcre;
                     --Tipo de extrato de conta recebe o tipo de extrato do associado
                     vr_tpextcta:= vr_tab_crapass(rw_craplcm.nrdconta).tpextcta;
                   END IF;
                 END IF;  --Nvl(vr_nrdconta,0) <> rw_craplcm.nrdconta

                 --Numero do cheque do saldo recebe o numero do documento do lancamento
                 vr_nrchqsdv := TO_NUMBER(SUBSTR(gene0002.fn_mask(rw_craplcm.nrdocmto,'9999999'),1,6));

                 --Selecionar informacoes dos cheques emitidos
                 OPEN cr_crapfdc (pr_cdcooper => pr_cdcooper
                                 ,pr_cdbanchq => rw_craplcm.cdbanchq
                                 ,pr_cdagechq => rw_craplcm.cdagechq
                                 ,pr_nrctachq => rw_craplcm.nrctachq
                                 ,pr_nrcheque => vr_nrchqsdv);
                 --Posicionar no proximo registro
                 FETCH cr_crapfdc INTO rw_crapfdc;
                 -- Deve ter encontrado apenas 1 registro (FIND PROGRESS)
                 IF cr_crapfdc%NOTFOUND OR rw_crapfdc.qtdregis <> 1 THEN
                   --Fechar cursor
                   CLOSE cr_crapfdc;
                   --Selecionar informacoes de cheques emitidos
                   OPEN cr_crapfdc2 (pr_cdcooper => pr_cdcooper
                                    ,pr_nrdctitg => rw_craplcm.nrdctitg
                                    ,pr_nrcheque => vr_nrchqsdv);
                   --posicionar no proximo registro
                   FETCH cr_crapfdc2 INTO rw_crapfdc;
                   -- Deve ter encontrado apenas 1 registro (FIND PROGRESS)
                   IF cr_crapfdc2%NOTFOUND OR rw_crapfdc.qtdregis <> 1 THEN
                     --Fechar cursor
                     CLOSE cr_crapfdc2;
                     --Selecionar transferencias entre contas
                     OPEN cr_craptco (pr_cdcooper => rw_craplcm.cdcooper
                                     ,pr_nrdconta => rw_craplcm.nrdconta
                                     ,pr_tpctatrf => 1
                                     ,pr_flgativo => 1);
                     --Posicionar no proximo registro
                     FETCH cr_craptco INTO rw_craptco;
                     --Se encontrar
                     IF cr_craptco%FOUND THEN
                       --Fechar Cursor
                       CLOSE cr_craptco;
                       --Selecionar informacoes dos cheques emitidos
                       OPEN cr_crapfdc (pr_cdcooper => rw_craptco.cdcopant
                                       ,pr_cdbanchq => rw_craplcm.cdbanchq
                                       ,pr_cdagechq => rw_craplcm.cdagechq
                                       ,pr_nrctachq => rw_craplcm.nrctachq
                                       ,pr_nrcheque => vr_nrchqsdv);
                       --Posicionar no proximo registro
                       FETCH cr_crapfdc INTO rw_crapfdc;
                       --Se nao encontrar
                       IF cr_crapfdc%NOTFOUND THEN
                         --Fechar cursor
                         CLOSE cr_crapfdc;
                         --Buscar mensagem de erro da critica
                         vr_cdcritic:= 244;
                         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                                        ' COOP ANT = ' || rw_craptco.cdcopant ||
                                        ' CONTA = '    || gene0002.fn_mask_conta(rw_crapsld.nrdconta) ||
                                        ' CHEQUE = '   || vr_nrchqsdv;
                                                                                                 
                         -- Envio centralizado de log de erro
                          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                     || vr_cdprogra || ' --> '
                                                                       || vr_dscritic
                                                   ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE'));
                          vr_cdcritic := NULL;
                          vr_dscritic := NULL;
                          -- Indicador de controle                                          
                          vr_ingerneg := FALSE;
                       END IF;
                       
                       -- Se o cursor estiver aberto
                       IF cr_crapfdc%ISOPEN THEN
                         --Fechar cursor
                         CLOSE cr_crapfdc;
                       END IF;
                     
                     ELSE
                       --Fechar cursor
                       CLOSE cr_craptco;
                       --Buscar mensagem de erro da critica
                       vr_cdcritic := 244;
                       vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || 
                                      ' CONTA = '  || gene0002.fn_mask_conta(rw_crapsld.nrdconta) ||
                                      ' CHEQUE = ' || vr_nrchqsdv;

                       -- Envio centralizado de log de erro
                        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                   || vr_cdprogra || ' --> '
                                                                   || vr_dscritic
                                                  ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE'));
                        vr_cdcritic := NULL;
                        vr_dscritic := NULL;
                        -- Indicador de controle                                             
                        vr_ingerneg := FALSE;
                     END IF; --IF cr_craptco%FOUND
                     --Fechar Cursor
                     IF cr_craptco%ISOPEN THEN
                       CLOSE cr_craptco;
                     END IF;
                   END IF; --cr_crapfdc2%NOTFOUND
                   --Fechar Cursor
                   IF cr_crapfdc2%ISOPEN THEN
                     CLOSE cr_crapfdc2;
                   END IF;
                 END IF; --cr_crapfdc%NOTFOUND
                 --Fechar Cursor se estiver aberto
                 IF cr_crapfdc%ISOPEN THEN
                   CLOSE cr_crapfdc;
                 END IF;
                 
                 IF vr_ingerneg THEN
                   -- Buscar próxima sequencia
                   vr_nrseqdig:= fn_sequence('CRAPNEG','NRSEQDIG',rw_crapfdc.cdcooper||';'||rw_crapfdc.nrdconta);
                   --Inserir saldos e cheques
                   BEGIN
                     INSERT INTO crapneg (crapneg.nrdconta
                                         ,crapneg.nrseqdig
                                         ,crapneg.cdhisest
                                         ,crapneg.cdobserv
                                         ,crapneg.dtiniest
                                         ,crapneg.nrdctabb
                                         ,crapneg.nrdocmto
                                         ,crapneg.qtdiaest
                                         ,crapneg.vlestour
                                         ,crapneg.vllimcre
                                         ,crapneg.cdtctant
                                         ,crapneg.cdtctatu
                                         ,crapneg.dtfimest
                                         ,crapneg.cdoperad
                                         ,crapneg.cdbanchq
                                         ,crapneg.cdagechq
                                         ,crapneg.nrctachq
                                         ,crapneg.cdcooper)
                                VALUES   (rw_crapfdc.nrdconta
                                         ,vr_nrseqdig
                                         ,1
                                         ,To_Number(rw_craplcm.cdpesqbb)
                                         ,rw_craplcm.dtmvtolt
                                         ,rw_craplcm.nrdctabb
                                         ,rw_craplcm.nrdocmto
                                         ,0
                                         ,rw_craplcm.vllanmto
                                         ,vr_vllimcre
                                         ,0
                                         ,0
                                         ,null
                                         ,rw_craplcm.cdoperad
                                         ,rw_crapfdc.cdbanchq
                                         ,rw_crapfdc.cdagechq
                                         ,rw_crapfdc.nrctachq
                                         ,rw_crapfdc.cdcooper);
                   EXCEPTION
                     WHEN OTHERS THEN
                     vr_dscritic := 'Erro ao inserir na tabela crapneg[1-'||rw_crapfdc.nrdconta||'-'||vr_nrseqdig||']: '||SQLERRM;
                     --Levantar Exceção
                     RAISE vr_exc_saida;
                   END;
                 END IF;
                 
               END IF;

               --Atualizar valor do ipmf  no lancamento
               BEGIN
                 UPDATE craplcm SET craplcm.vldoipmf = vr_vldoipmf
                 WHERE craplcm.ROWID = rw_craplcm.ROWID;
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_dscritic := 'Erro ao  atualizar tabela craplcm. '||SQLERRM;
                   --Sair do programa
                   RAISE vr_exc_saida;
               END;
             END LOOP;  --FOR rw_craplcm IN cr_craplcm
           END IF;  --vr_tab_craplcm.EXISTS(rw_crapsld.nrdconta)

           --Linha 851
           --Atualizar Saldo disponivel na tabela de saldo
           rw_crapsld.vlsddisp:= Nvl(rw_crapsld.vlsddisp,0) + vr_vlsddisp;
           --Atualizar Saldo Cheque Salario na tabela de saldo
           rw_crapsld.vlsdchsl:= Nvl(rw_crapsld.vlsdchsl,0) + vr_vlsdchsl;
           --Atualizar saldo bloqueado na tabela de saldo
           rw_crapsld.vlsdbloq:= Nvl(rw_crapsld.vlsdbloq,0) + vr_vlsdbloq;
           --Atualizar saldo bloqueado na praca na tabela de saldo
           rw_crapsld.vlsdblpr:= Nvl(rw_crapsld.vlsdblpr,0) + vr_vlsdblpr;
           --Atualizar saldo bloqueado fora praca na tabela de saldo
           rw_crapsld.vlsdblfp:= Nvl(rw_crapsld.vlsdblfp,0) + vr_vlsdblfp;
           --Atualizar saldo liquido na tabela de saldo
           rw_crapsld.vltsallq:= Nvl(rw_crapsld.vltsallq,0) + vr_vltsallq;
           --Atualizar quantidade de lancamentos na tabela de saldos
           rw_crapsld.qtlanmes:= Nvl(rw_crapsld.qtlanmes,0) + vr_qtlanmes;

           -- Se possui estouro de conta
           IF (rw_crapsld.vlsddisp + rw_craplim.vllimite) < 0 THEN

             --Se encontrou limite de credito para a conta
             IF vr_tab_craplim.EXISTS(rw_crapsld.nrdconta) THEN
             
               -- Somente se o contrato de limite tem cobertura de operação
               IF vr_tab_craplim(rw_crapsld.nrdconta).idcobope > 0 THEN

                 -- Tentar resgatar o valor negativo
                 vr_vlresgat := ABS(rw_crapsld.vlsddisp + rw_craplim.vllimite);

                 -- Acionaremos rotina para solicitar o resgate afim de cobrir os valores negativos
                 BLOQ0001.pc_solici_cobertura_operacao(pr_idcobope => vr_tab_craplim(rw_crapsld.nrdconta).idcobope
                                                      ,pr_flgerlog => 1
                                                      ,pr_cdoperad => '1'
                                                      ,pr_idorigem => 5
                                                      ,pr_cdprogra => vr_cdprogra
                                                      ,pr_qtdiaatr => rw_crapsld.qtddusol  /* + 1 */
                                                      ,pr_vlresgat => vr_vlresgat
                                                      ,pr_flefetiv => 'S' -- Efetivar o resgate
                                                      ,pr_dscritic => vr_dscritic);

                 -- Em caso de erro no resgate, deve limpar os erros e prosseguir normalmente, pois o rollback 
                 -- já foi efetuado
                 IF TRIM(vr_dscritic) IS NOT NULL THEN
                   -- Limpar erros
                   vr_dscritic := NULL;
                   -- Indicar que nenhum valor foi resgatado
                   vr_vlresgat := 0;
                 ELSE -- Não havendo erros
                   
				   -- Se houve resgate
				   IF vr_vlresgat > 0 THEN
                   -- Verificar Saldo do cooperado
                   extr0001.pc_obtem_saldo_dia(pr_cdcooper => pr_cdcooper 
                                              ,pr_rw_crapdat => rw_crapdat 
                                              ,pr_cdagenci => 1 
                                              ,pr_nrdcaixa => 0 
                                              ,pr_cdoperad => '1' 
                                              ,pr_nrdconta => rw_crapsld.nrdconta 
                                              ,pr_vllimcre => vr_tab_crapass(rw_crapsld.nrdconta).vllimcre 
                                              ,pr_dtrefere => rw_crapdat.dtmvtolt 
                                              ,pr_flgcrass => FALSE 
                                              ,pr_tipo_busca => 'A' -- Tipo Busca(A-dtmvtoan)
                                              ,pr_des_reto => vr_des_erro 
                                              ,pr_tab_sald => vr_tab_saldo 
                                              ,pr_tab_erro => vr_tab_erro);
                                                                  
                   -- Se ocorreu erro
                   IF vr_des_erro = 'NOK' THEN
                     -- Tenta buscar o erro no vetor de erro
                     IF vr_tab_erro.COUNT > 0 THEN
                       vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                       vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_crapsld.nrdconta;
                     ELSE
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Retorno "NOK" na extr0001.pc_obtem_saldo_dia e sem informação na pr_tab_erro, Conta: '||rw_crapsld.nrdconta;
                     END IF;
                                    
                     IF vr_cdcritic <> 0 THEN
                       vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' Conta: '||rw_crapsld.nrdconta;
                     END IF;                              

                     -- Levantar Excecao
                     RAISE vr_exc_saida;
                   ELSE
                     vr_dscritic:= NULL;
                   END IF;
                   
                   -- Buscar saldo
                   IF vr_tab_saldo.COUNT > 0 THEN
                     -- Acumular Saldo
                     vr_vlsomvld := ROUND( NVL(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) ,2); 
                   END IF;
                
                   -- Se a diferenças dos saldos é menor que o valor de resgate
                   IF ABS( rw_crapsld.vlsddisp - vr_vlsomvld ) <> vr_vlresgat THEN
                     -- A diferença deve ser utilizada como valor de resgate
                     vr_vlresgat := ABS( rw_crapsld.vlsddisp - vr_vlsomvld );
                   END IF;
                  
                   ---------------------------------------------------------
                   -- Decrementar do saldo negativo o valor resgatado
					   			 rw_crapsld.vlsddisp := rw_crapsld.vlsddisp + vr_vlresgat;
                   ---------------------------------------------------------
                   END IF; -- Se houve resgate

                 END IF;

               END IF;
             END IF;
           END IF;

           --Valor utilizado recebe:
           --vlsdblfp = valor do saldo bloqueado fora da praca
           --vlsdbloq = valor saldo bloqueado
           --vlsdblpr = valor do saldo bloqueado praca
           --vlsdchsl = valor do saldo cheque salario
           --vlsddisp = valor do saldo disponivel

           vr_vlutiliz:= Nvl(rw_crapsld.vlsdchsl,0) +
                         Nvl(rw_crapsld.vlsddisp,0);

           --Se o valor utilizado for negativo inverte sinal
           IF vr_vlutiliz < 0 THEN
             vr_vlutiliz:= vr_vlutiliz * -1;
           ELSE
             --Zerar o valor utilizado
             vr_vlutiliz:= 0;
           END IF;

           --Valor do IOF atualizado recebe saldo disponivel + saldo cheque salario
           vr_vliofatu:= Nvl(rw_crapsld.vlsddisp,0) + Nvl(rw_crapsld.vlsdchsl,0);

           --Se o valor do iof for negativo inverte sinal
           IF vr_vliofatu < 0 THEN
             vr_vliofatu:= vr_vliofatu * -1;
           ELSE
             --Zerar valor iof
             vr_vliofatu:= 0;
           END IF;

             --Se o valor do iof atual menos valor iof anterior for maior zero
             IF (vr_vliofatu - vr_vliofant) > 0 THEN
               --valor base iof recebe valor iof atual menos valor iof anterior
               vr_vlbasiof:= vr_vliofatu - vr_vliofant;
             END IF;
             
           vr_vliof_principal := 0;             
             --> calcular a quantidade de dias corridos
           vr_qtdiaiof        := vr_dtmvtolt - vr_dtmvtoan;
                   
             IF vr_qtdiaiof > 1 THEN
               -- Diminuir um dia que será calcularo com o saldo atual
               vr_qtdiaiof := vr_qtdiaiof -1;
             -----------------------------------------------------------------------------------------------
             -- Calcula o Valor do IOF Principal
             -----------------------------------------------------------------------------------------------
             TIOF0001.pc_calcula_valor_iof(pr_tpproduto  => 5                    --> Adiantamento a Depositante
                                          ,pr_tpoperacao => 1                    --> Calculo de Inclusao/Atraso
                                          ,pr_cdcooper   => pr_cdcooper
                                          ,pr_nrdconta   => rw_crapsld.nrdconta
                                          ,pr_inpessoa   => vr_tab_crapass(rw_crapsld.nrdconta).inpessoa
                                          ,pr_natjurid   => vr_natjurid
                                          ,pr_tpregtrb   => vr_tpregtrb
                                          ,pr_dtmvtolt   => vr_dtmvtolt
                                          ,pr_qtdiaiof   => vr_qtdiaiof
                                          ,pr_vloperacao => ROUND(vr_vliofant,2) --> considerando o saldo anterior
                                          ,pr_vltotalope => vr_vliofant + vr_tab_crapass(rw_crapsld.nrdconta).vllimcre
                                          ,pr_vliofpri   => vr_vliofpri
                                          ,pr_vliofadi   => vr_vliofadi
                                          ,pr_vliofcpl   => vr_vliofcpl
                                          ,pr_vltaxa_iof_principal => vr_vltaxa_iof_principal
                                          ,pr_flgimune    => vr_flgimune
                                          ,pr_dscritic   => vr_dscritic);
                                          
             -- Condicao para verificar se houve critica                             
             IF vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_saida;
             END IF;
             
             -- Valor Principal do IOF
             vr_vliof_principal := NVL(vr_vliofpri,0);             
             END IF;
                   
             IF vr_vliofatu > 0 THEN               
             -----------------------------------------------------------------------------------------------
             -- Calcula o Valor do IOF Principal
             -----------------------------------------------------------------------------------------------             
             TIOF0001.pc_calcula_valor_iof(pr_tpproduto  => 5           --> Adiantamento a Depositante
                                          ,pr_tpoperacao => 1           --> Calculo de Inclusao/Atraso
                                          ,pr_cdcooper   => pr_cdcooper
                                          ,pr_nrdconta   => rw_crapsld.nrdconta
                                          ,pr_inpessoa   => vr_tab_crapass(rw_crapsld.nrdconta).inpessoa
                                          ,pr_natjurid   => vr_natjurid
                                          ,pr_tpregtrb   => vr_tpregtrb
                                          ,pr_dtmvtolt   => vr_dtmvtolt
                                          ,pr_qtdiaiof   => 1
                                          ,pr_vloperacao => ROUND(vr_vliofatu,2)
                                          ,pr_vltotalope => vr_vliofatu + vr_tab_crapass(rw_crapsld.nrdconta).vllimcre
                                          ,pr_vliofpri   => vr_vliofpri
                                          ,pr_vliofadi   => vr_vliofadi
                                          ,pr_vliofcpl   => vr_vliofcpl
                                          ,pr_vltaxa_iof_principal => vr_vltaxa_iof_principal
                                          ,pr_flgimune   => vr_flgimune
                                          ,pr_dscritic   => vr_dscritic);
             
             -- Condicao para verificar se houve critica                             
             IF vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_saida;
             END IF;
             
             -- Valor Principal do IOF
             vr_vliof_principal := NVL(vr_vliof_principal,0) + NVL(vr_vliofpri,0);
             END IF;
           
           -----------------------------------------------------------------------------------------------
           -- Calcula o Valor do IOF Adicional
           -----------------------------------------------------------------------------------------------
           TIOF0001.pc_calcula_valor_iof(pr_tpproduto  => 5           --> Adiantamento a Depositante
                                        ,pr_tpoperacao => 1           --> Calculo de Inclusao/Atraso
                                        ,pr_cdcooper   => pr_cdcooper
                                        ,pr_nrdconta   => rw_crapsld.nrdconta
                                        ,pr_inpessoa   => vr_tab_crapass(rw_crapsld.nrdconta).inpessoa
                                        ,pr_natjurid   => vr_natjurid
                                        ,pr_tpregtrb   => vr_tpregtrb
                                        ,pr_dtmvtolt   => vr_dtmvtolt
                                        ,pr_qtdiaiof   => 0
                                        ,pr_vloperacao => ROUND(vr_vlbasiof,2)
                                        ,pr_vltotalope => vr_vliofatu + vr_tab_crapass(rw_crapsld.nrdconta).vllimcre
                                        ,pr_vliofpri   => vr_vliofpri
                                        ,pr_vliofadi   => vr_vliofadi
                                        ,pr_vliofcpl   => vr_vliofcpl
                                        ,pr_vltaxa_iof_principal => vr_vltaxa_iof_principal
                                        ,pr_flgimune   => vr_flgimune
                                        ,pr_dscritic   => vr_dscritic);
             
           -- Condicao para verificar se houve critica                             
           IF vr_dscritic IS NOT NULL THEN
             RAISE vr_exc_saida;
           END IF;
          
           -----------------------------------------------------------------------------------------------
           -- Efetuar a gravacao do IOF
           -----------------------------------------------------------------------------------------------
           TIOF0001.pc_insere_iof(pr_cdcooper   => pr_cdcooper
                                 ,pr_nrdconta   => rw_crapsld.nrdconta
                                 ,pr_dtmvtolt   => vr_dtmvtolt
                                 ,pr_tpproduto  => 5   --> Adiantamento a Depositante
                                 ,pr_nrcontrato => 0
                                 ,pr_vliofpri   => vr_vliof_principal
                                 ,pr_vliofadi   => vr_vliofadi
                                 ,pr_flgimune   => vr_flgimune
                                 ,pr_cdcritic   => vr_cdcritic
                                 ,pr_dscritic   => vr_dscritic);
                                
           -- Condicao para verificar se houve critica                             
           IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
             RAISE vr_exc_saida;
           END IF;
           
           IF vr_flgimune = 0 THEN
           --Valor base iof recebe valor base iof existente + valor base iof calculado
           rw_crapsld.vlbasiof := Nvl(rw_crapsld.vlbasiof,0) + Nvl(vr_vlbasiof,0);
           --Valor iod no mes recebe valor iof mes + valor base iof multiplicado pela taxa de iof
             rw_crapsld.vliofmes := ROUND(Nvl(rw_crapsld.vliofmes,0) + NVL(vr_vliofadi,0) + NVL(vr_vliof_principal,0),2);
           ELSE
             rw_crapsld.vlbasiof := Nvl(rw_crapsld.vlbasiof,0);
             rw_crapsld.vliofmes := Nvl(rw_crapsld.vliofmes,0);
           END IF;

            --Se deve calcular cpmf
           IF vr_flgdcpmf THEN  --linha(905)
             --Se o valor utilizado for menor valor utilizado anterior
             IF vr_vlutiliz < vr_vlantuti THEN
               --Valor cobrado saldo recebe valor utilizado anterior menos valor utilizado
               vr_vlcobsld:= Nvl(vr_vlantuti,0) - Nvl(vr_vlutiliz,0);
               --Acumular no Valor base impf o valor cobrado do saldo
               vr_vlbasipm:= Nvl(vr_vlbasipm,0) + Nvl(vr_vlcobsld,0);
               --Valor do impf recebe valor cobrado do saldo multiplicado pela taxa
               vr_vldoipmf:= TRUNC(vr_vlcobsld * vr_txcpmfcc,2);
               --acumular no valor do ipmf apurado o valor do impf
               vr_vlipmfap:= Nvl(vr_vlipmfap,0) + Nvl(vr_vldoipmf,0);

               --Atualizar capa do Lote
               BEGIN
                 UPDATE craplot SET craplot.nrseqdig = Nvl(craplot.nrseqdig,0) + 1
                                   ,craplot.qtcompln = Nvl(craplot.qtcompln,0) + 1
                                   ,craplot.qtinfoln = Nvl(craplot.qtcompln,0) + 1
                                   ,craplot.vlcompcr = Nvl(craplot.vlcompcr,0) + Nvl(vr_vlcobsld,0)
                                   ,craplot.vlinfocr = Nvl(craplot.vlcompcr,0) + Nvl(vr_vlcobsld,0)
                 WHERE craplot.cdcooper = pr_cdcooper
                 AND   craplot.dtmvtolt = vr_dtmvtolt
                 AND   craplot.cdagenci = 1
                 AND   craplot.cdbccxlt = 100
                 AND   craplot.nrdolote = 8476
                 RETURNING craplot.cdcooper
                          ,craplot.dtmvtolt
                          ,craplot.cdagenci
                          ,craplot.cdbccxlt
                          ,craplot.nrdolote
                          ,craplot.nrseqdig
                          ,craplot.rowid
                 INTO      rw_craplot.cdcooper
                          ,rw_craplot.dtmvtolt
                          ,rw_craplot.cdagenci
                          ,rw_craplot.cdbccxlt
                          ,rw_craplot.nrdolote
                          ,rw_craplot.nrseqdig
                          ,rw_craplot.rowid;

                 --Se o update não atualizou nenhuma linha entao inserir craplot pois o mesmo nao existe
                 IF SQL%ROWCOUNT = 0 THEN
                   BEGIN
                     --Inserir a capa do lote
                     INSERT INTO craplot (cdcooper
                                         ,dtmvtolt
                                         ,cdagenci
                                         ,cdbccxlt
                                         ,nrdolote
                                         ,tplotmov
                                         ,nrseqdig
                                         ,vlcompcr
                                         ,vlinfocr
                                         ,cdhistor
                                         ,cdoperad
                                         ,dtmvtopg
                                         ,qtcompln
                                         ,qtinfoln)
                                 VALUES  (pr_cdcooper
                                         ,vr_dtmvtolt
                                         ,1
                                         ,100
                                         ,8476
                                         ,1               --tplotmov
                                         ,1               --nrseqdig
                                         ,vr_vlcobsld     --vlcompcr
                                         ,vr_vlcobsld     --vlinfocr
                                         ,289             --cdhistor
                                         ,'1'             --cdoperad
                                         ,NULL            --dtmvtopg
                                         ,1               --qtcompln
                                         ,1)              --qtinfoln
                                 RETURNING ROWID
                                          ,dtmvtolt
                                          ,cdagenci
                                          ,cdbccxlt
                                          ,nrdolote
                                          ,nrseqdig
                                 INTO rw_craplot.ROWID
                                     ,rw_craplot.dtmvtolt
                                     ,rw_craplot.cdagenci
                                     ,rw_craplot.cdbccxlt
                                     ,rw_craplot.nrdolote
                                     ,rw_craplot.nrseqdig;
                   EXCEPTION
                     WHEN OTHERS THEN
                       vr_dscritic := 'Erro ao inserir na tabela craplot. '||SQLERRM;
                       --Sair do programa
                       RAISE vr_exc_saida;
                   END;
                 END IF;
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_dscritic := 'Erro ao atualizar tabela craplot. '|| SQLERRM;
                   --Sair do programa
                   RAISE vr_exc_saida;
               END;

               --Inserir lancamento

               -- cria lançamento de depositos a vista - craplcm
               -- Inserir registro de crédito:
               BEGIN
                 LANC0001.pc_gerar_lancamento_conta(pr_cdcooper =>pr_cdcooper             -- cdcooper
                                                    ,pr_dtmvtolt =>rw_craplot.dtmvtolt     -- dtmvtolt
                                                    ,pr_cdagenci =>rw_craplot.cdagenci     -- cdagenci
                                                    ,pr_cdbccxlt =>rw_craplot.cdbccxlt     -- cdbccxlt
                                                    ,pr_nrdolote =>rw_craplot.nrdolote     -- nrdolote
                                                    ,pr_nrdconta =>rw_crapsld.nrdconta     -- nrdconta
                                                    ,pr_nrdctabb =>rw_crapsld.nrdconta     -- nrdctabb
                                                    ,pr_nrdctitg =>to_char(rw_crapsld.nrdconta,'fm00000000') -- nrdctitg
                                                    ,pr_nrdocmto =>Nvl(rw_craplot.nrseqdig,0) -- nrdocmto
                                                    ,pr_cdhistor =>289                        -- cdhistor
                                                    ,pr_cdpesqbb =>' '                        -- cdpesqbb
                                                    ,pr_nrseqdig =>Nvl(rw_craplot.nrseqdig,0) --nrseqdig
                                                    ,pr_vllanmto =>vr_vlcobsld                -- vllanmto
                                                    ,pr_vldoipmf =>vr_vldoipmf                -- vldoipmf
                                                    -- OUTPUT --
                                                    ,pr_tab_retorno => vr_tab_retorno
                                                    ,pr_incrineg => vr_incrineg
                                                    ,pr_cdcritic => vr_cdcritic
                                                    ,pr_dscritic => vr_dscritic);

                 IF nvl(vr_cdcritic, 0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
                     RAISE vr_exc_saida;
                 END IF;
                 --vr_nrdrowid := vr_tab_retorno.rowidlct;


               EXCEPTION
                 WHEN OTHERS THEN
                   vr_dscritic := 'Erro ao inserir na tabela craplcm. '||SQLERRM;
                   --Sair do programa
                   RAISE vr_exc_saida;
               END;
             END IF;  --vr_vlutiliz < vr_vlantuti
           END IF; --vr_flgdcpmf   linha(958)

           --Atualizar valor do impf apurado na tabela de saldo
           rw_crapsld.vlipmfap:= Nvl(rw_crapsld.vlipmfap,0) + Nvl(vr_vlipmfap,0);
           --Atualizar valor do impf a pagar na tabela de saldo
           rw_crapsld.vlipmfpg:= Nvl(rw_crapsld.vlipmfpg,0) + Nvl(vr_vlipmfpg,0);
           --Atualizar valor base do impf na tabela de saldo
           rw_crapsld.vlbasipm:= Nvl(rw_crapsld.vlbasipm,0) + Nvl(vr_vlbasipm,0);

           --Acumular no valor disponivel o valor do cheque salario
           vr_vldispon:= Nvl(rw_crapsld.vlsddisp,0) + Nvl(rw_crapsld.vlsdchsl,0);
           --Valor calculado recebr o valor disponivel
           vr_vlcalcul:= Nvl(vr_vldispon,0);
           --Valor bloqueado recebe o valor bloqueado na praca + valor bloqueado fora praca + valor bloqueado do saldo
           vr_vlbloque:= Nvl(rw_crapsld.vlsdblpr,0) + Nvl(rw_crapsld.vlsdblfp,0) + Nvl(rw_crapsld.vlsdbloq,0);
           --Atribuir false para flag controle estouro
           vr_flgestou:= FALSE;

           /* Calcula saldo medio positivo */

           --Se o valor disponivel for positivo
           IF vr_vldispon >= 0 THEN
             --Acumular no valor saldo medio no mes o valor disponivel / quantidade dias utilizados
             rw_crapsld.vlsmpmes:= Nvl(rw_crapsld.vlsmpmes,0) + (Nvl(vr_vldispon,0) / Nvl(vr_qtdiaute,0));
             --Zerar quantidade dias devedor
             rw_crapsld.qtddsdev:= 0;
             --Zerar quantidade dias usando limite
             rw_crapsld.qtddusol:= 0;
             --Inicializar data saldo devedor liquida
             rw_crapsld.dtdsdclq:= NULL;
             --Zerar quantidade dias saldo negativo risco
             rw_crapsld.qtdriclq:= 0;
             --Inicializar data de risco liquido
             rw_crapsld.dtrisclq:= NULL;
           ELSE
             --Calcula saldos medios negativos
             IF Nvl(vr_nrdconta,0) <> rw_crapsld.nrdconta THEN
               --Se o associado nao estiver cadastrado
               IF NOT vr_tab_crapass.EXISTS(rw_crapsld.nrdconta) THEN
                 vr_cdcritic := 251;
                 --Buscar mensagem de erro da critica
                 vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' CONTA = '||gene0002.fn_mask_conta(rw_crapsld.nrdconta);
                 --Abortar Programa
                 RAISE vr_exc_saida;
               ELSE
                 --numero da conta anterior recebe o numero da conta do associado
                 vr_nrdconta:= vr_tab_crapass(rw_crapsld.nrdconta).nrdconta;
                 --Valor do limite de credito recebe o limite do associado
                 vr_vllimcre:= vr_tab_crapass(rw_crapsld.nrdconta).vllimcre;
                 --Tipo de extrato de conta recebe o tipo de extrato do associado
                 vr_tpextcta:= vr_tab_crapass(rw_crapsld.nrdconta).tpextcta;
               END IF;
             END IF; --Nvl(vr_nrdconta,0) <> rw_crapsld.nrdconta

             --Valor calculado recebe valor disponivel + valor limite credito
             vr_vlcalcul:= Nvl(vr_vldispon,0) + Nvl(vr_vllimcre,0);

             --Se valor limite credito for diferente zero
             IF vr_vllimcre <> 0   THEN
               --Incrementar a quantidade dias uso limite
               rw_crapsld.qtddusol:= Nvl(rw_crapsld.qtddusol,0) + 1;
             ELSE
               --Zerar a quantidade dias uso limite
               rw_crapsld.qtddusol:= 0;
             END IF;

             --Se o valor calculado for maior zero
             IF vr_vlcalcul > 0 THEN
               --Acumular no valor saldo negativo especial no mes o valor disponivel / quantidade dias utilizados
               rw_crapsld.vlsmnesp:= Nvl(rw_crapsld.vlsmnesp,0) + (vr_vldispon / vr_qtdiaute);
             ELSE
               --Valor calculado recebe valor calculado + valor bloqueado
               vr_vlcalcul:= Nvl(vr_vlcalcul,0) + Nvl(vr_vlbloque,0);
               --Se o valor calculado > 0
               IF vr_vlcalcul > 0 THEN
                 -- todo o limite e parte do bloqueado
                 --Acumular no valor saldo negativo especial no mes o valor do limite de credito *-1
                 --dividido pela quantidade de dias uteis
                 rw_crapsld.vlsmnesp:= Nvl(rw_crapsld.vlsmnesp,0) + ((vr_vllimcre * -1) / vr_qtdiaute);
                 --Acumular no valor media saque sem bloqueado o valor calculado menos valor bloqueado
                 --dividido pela quantidade de dias uteis
                 rw_crapsld.vlsmnblq:= Nvl(rw_crapsld.vlsmnblq,0) + ((vr_vlcalcul - vr_vlbloque) / vr_qtdiaute);
               ELSE
                 --todo o limite, todo o bloqueado e parte estouro
                 --Acumular no valor saldo negativo especial no mes o valor do limite de credito *-1
                 --dividido pela quantidade de dias uteis
                 rw_crapsld.vlsmnesp:= Nvl(rw_crapsld.vlsmnesp,0) + ((vr_vllimcre * -1) / vr_qtdiaute);
                 --Acumular no valor media saque sem bloqueado o valor bloqueado * -1
                 --dividido pela quantidade de dias uteis
                 rw_crapsld.vlsmnblq:= Nvl(rw_crapsld.vlsmnblq,0) + ((vr_vlbloque * -1) / vr_qtdiaute);
                 
                 --> incrementar valor de saldo medio apenas para contas que não estejam em prejuizo,
                 --> pois as que estão em prejuizo terão juro remuneratorio
                 IF  vr_tab_crapass(rw_crapsld.nrdconta).inprejuz = 0 THEN
                 --Acumular no valor do saldo negativo do mes o valor calculado m
                 --dividido pela quantidade de dias uteis
                 rw_crapsld.vlsmnmes:= Nvl(rw_crapsld.vlsmnmes,0) + (vr_vlcalcul / vr_qtdiaute);
                 END IF;

                 --Se o valor calculo for negativo
                 IF vr_vlcalcul < 0  THEN
                   --Atribuir true para variavel controle de estouro de limite
                   vr_flgestou:= TRUE;
                 ELSE
                   --Atribuir false para variavel controle de estouro de limite
                   vr_flgestou:= FALSE;
                 END IF;

               END IF; --vr_vlcalcul > 0
             END IF; --vr_vlcalcul > 0

             -- Atualiza dias de credito em liquidacao
             --Se estourou limite (ou se a conta está em prejuízo)
             IF vr_flgestou OR vr_tab_crapass(rw_crapsld.nrdconta).inprejuz = 1 THEN
               --
               -- Regra para cálculo de dias úteis ou dias corridos - Daniel(AMcom)
               vr_dtrisclq_aux := nvl(rw_crapsld.dtrisclq, rw_crapdat.dtmvtolt);
               --
               BEGIN
                 -- Buscar data parametro de referencia para calculo de juros
                 vr_dtcorte_prm := to_date(GENE0001.fn_param_sistema (pr_cdcooper => 0
                                                                     ,pr_nmsistem => 'CRED'
                                                                     ,pr_cdacesso => 'DT_CORTE_REGCRE')
                                                                     ,'DD/MM/RRRR');     
    	         EXCEPTION
                 WHEN OTHERS THEN
                   vr_dtcorte_prm := rw_crapdat.dtmvtolt;
               END;               
               --
               IF vr_dtrisclq_aux <= vr_dtcorte_prm
              -- Se estiver em prejuízo, deve efetuar a contagem em dias corridos
              AND vr_tab_crapass(rw_crapsld.nrdconta).inprejuz = 0 /*não está em Prejuízo*/ THEN
			     -- Considerar dias úteis -- Regra atual
               --Incrementar quantidade dias devedor
               rw_crapsld.qtddsdev:= Nvl(rw_crapsld.qtddsdev,0) + 1;
               --Incrementar quantidade total dias conta devedora
               rw_crapsld.qtddtdev:= Nvl(rw_crapsld.qtddtdev,0) + 1;
               --Incrementar quantidade dias saldo negativo risco
               rw_crapsld.qtdriclq:= Nvl(rw_crapsld.qtdriclq,0) + 1;
             ELSE
                 -- Considerar dias corridos -- Daniel(AMcom)
                 -- Guardar posição inicial de quantidade de dias SLD
                 vr_qtddsdev_aux     := nvl(rw_crapsld.qtddsdev,0);
                 --
                 IF rw_crapdat.dtmvtolt = vr_dtrisclq_aux THEN
                   -- Incrementar quantidade dias corridos devedor 
                   rw_crapsld.qtddsdev := 1;
                   -- Incrementar quantidade total dias corridos conta devedora
                   rw_crapsld.qtddtdev := nvl(rw_crapsld.qtddtdev,0)+1;
                   -- Incrementar quantidade dias corridos saldo negativo risco
                   rw_crapsld.qtdriclq := 1;
                 ELSE 
						IF vr_tab_crapass(rw_crapsld.nrdconta).inprejuz = 0 THEN
                   -- Incrementar quantidade dias corridos devedor 
                   rw_crapsld.qtddsdev := (rw_crapdat.dtmvtolt-vr_dtrisclq_aux);
                   -- Incrementar quantidade dias corridos saldo negativo risco
                   rw_crapsld.qtdriclq := (rw_crapdat.dtmvtolt-vr_dtrisclq_aux);
							ELSE
								rw_crapsld.qtddsdev := PREJ0003.fn_calc_dias_atraso_cc_prej(pr_cdcooper, rw_crapsld.nrdconta, rw_crapdat.dtmvtopr);
								rw_crapsld.qtdriclq := rw_crapsld.qtddsdev;
							END IF;

                   -- Incrementar quantidade total dias corridos conta devedora
                   rw_crapsld.qtddtdev := nvl(rw_crapsld.qtddtdev,0)+(rw_crapsld.qtddsdev-vr_qtddsdev_aux);

                 END IF;
               END IF;
             ELSE
               --Zerar quantidade dias devedor
               rw_crapsld.qtddsdev:= 0;
               --Zerar quantidade dias saldo negativo risco
               rw_crapsld.qtdriclq:= 0;
             END IF; --vr_flgestou

             --Se quantidade dias devedor do saldo for maior ou igual quantidade dias devedor
             IF rw_crapsld.qtddsdev >= vr_qtddsdev THEN
               --Se a data saldo devedor liquida for nula
               IF rw_crapsld.dtdsdclq IS NULL THEN
                 --data saldo devedor liquida recebe da data do movimento
                 rw_crapsld.dtdsdclq:= vr_dtmvtolt;
               END IF;
             ELSE
               --data de liquidacao recebe nulo
               rw_crapsld.dtdsdclq:= NULL;
             END IF;

             -- Condicao para verificar se atualiza a data do risco
             IF rw_crapsld.qtdriclq >= 1 THEN
               --Se a data de risco liquido for nula
               IF rw_crapsld.dtrisclq IS NULL THEN
                 --Data de risco liquido recebe a data do movimento
                 rw_crapsld.dtrisclq:= vr_dtmvtolt;
               END IF;
             ELSE
               --Data de risco liquido recebe nulo
               rw_crapsld.dtrisclq:= NULL;
             END IF;
           END IF;  --vr_vldispon >= 0   linha(1070)

           --Se estourou limite
           IF vr_flgestou THEN

             --Inverter sinal do valor calculado
             vr_vlcalcul:= vr_vlcalcul * -1;

             --Selecionar informacoes dos saldos negativos
             OPEN cr_crapneg2 (pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => rw_crapsld.nrdconta
                              ,pr_cdhisest => 5);
             --Posicionar no proximo registro
             FETCH cr_crapneg2 INTO rw_crapneg2;

             --Se encontrar
             IF cr_crapneg2%FOUND AND
                rw_crapneg2.vlestour = vr_vlcalcul AND
                rw_crapneg2.dtfimest = vr_dtmvtoan THEN
               BEGIN
                 --Atualizar tabela saldo negativo
                 UPDATE crapneg SET crapneg.qtdiaest = Nvl(crapneg.qtdiaest,0) + 1
                                   ,crapneg.vllimcre = vr_vllimcre
                                   ,crapneg.dtfimest = vr_dtmvtolt
                 WHERE crapneg.ROWID = rw_crapneg2.ROWID;
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_dscritic := 'Erro ao atualizar tabela crapneg. '||SQLERRM;
                   --Fechar cursor
                   CLOSE cr_crapneg2;
                   --Sair do programa
                   RAISE vr_exc_saida;
               END;
             ELSE
               -- Buscar próxima sequencia
               vr_nrseqdig:= fn_sequence('CRAPNEG','NRSEQDIG',pr_cdcooper||';'||rw_crapsld.nrdconta);
               --Inserir saldos negativos e cheques
               BEGIN
                 INSERT INTO crapneg (crapneg.nrdconta
                                     ,crapneg.nrseqdig
                                     ,crapneg.cdhisest
                                     ,crapneg.cdobserv
                                     ,crapneg.dtiniest
                                     ,crapneg.nrdctabb
                                     ,crapneg.nrdocmto
                                     ,crapneg.qtdiaest
                                     ,crapneg.vlestour
                                     ,crapneg.vllimcre
                                     ,crapneg.cdtctant
                                     ,crapneg.cdtctatu
                                     ,crapneg.dtfimest
                                     ,crapneg.cdbanchq
                                     ,crapneg.cdagechq
                                     ,crapneg.nrctachq
                                     ,crapneg.cdcooper)
                             VALUES  (vr_nrdconta
                                     ,vr_nrseqdig
                                     ,5
                                     ,0
                                     ,vr_dtmvtolt
                                     ,0
                                     ,0
                                     ,1
                                     ,vr_vlcalcul
                                     ,vr_vllimcre
                                     ,0
                                     ,0
                                     ,vr_dtmvtolt
                                     ,0
                                     ,0
                                     ,0
                                     ,pr_cdcooper);
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_dscritic := 'Erro ao inserir na tabela crapneg[2-'||vr_nrdconta||'-'||vr_nrseqdig||']: '||SQLERRM;
                   --Sair do programa
                   RAISE vr_exc_saida;
               END;
             END IF;
             --Fechar Cursor
             CLOSE cr_crapneg2;
           END IF;  --vr_flgestou   linha(1121)

           --Se a data de liquidacao for igual a data do movimento
            IF Trunc(rw_crapsld.dtdsdclq) = Trunc(vr_dtmvtolt) THEN
             -- Buscar próxima sequencia
             vr_nrseqdig:= fn_sequence('CRAPNEG','NRSEQDIG',pr_cdcooper||';'||rw_crapsld.nrdconta);
             --Inserir saldos e cheques
             BEGIN
               INSERT INTO crapneg (crapneg.nrdconta
                                   ,crapneg.nrseqdig
                                   ,crapneg.cdhisest
                                   ,crapneg.cdobserv
                                   ,crapneg.dtiniest
                                   ,crapneg.nrdctabb
                                   ,crapneg.nrdocmto
                                   ,crapneg.qtdiaest
                                   ,crapneg.vlestour
                                   ,crapneg.vllimcre
                                   ,crapneg.cdtctant
                                   ,crapneg.cdtctatu
                                   ,crapneg.dtfimest
                                   ,crapneg.cdbanchq
                                   ,crapneg.cdagechq
                                   ,crapneg.nrctachq
                                   ,crapneg.cdcooper)
                           VALUES  (vr_nrdconta
                                   ,vr_nrseqdig
                                   ,4
                                   ,0
                                   ,vr_dtmvtolt
                                   ,0
                                   ,0
                                   ,0
                                   ,0
                                   ,vr_vllimcre
                                   ,0
                                   ,0
                                   ,NULL
                                   ,0
                                   ,0
                                   ,0
                                   ,pr_cdcooper);
             EXCEPTION
               WHEN OTHERS THEN
               vr_dscritic := 'Erro ao inserir na tabela crapneg[3-'||vr_nrdconta||'-'||vr_nrseqdig||']: '||SQLERRM;
               --Sair do programa
               RAISE vr_exc_saida;
             END;

           END IF;  --rw_crapsld.dtdsdclq = vr_dtmvtolt

           --Se for execucao quinzenal
           IF vr_flgquinz THEN      --linha(1154)
             --Se a conta anterior for diferente da conta do saldo
             IF Nvl(vr_nrdconta,0) <> rw_crapsld.nrdconta THEN
               --Verificar na tabela de memoria se o associado está cadastrado
               IF NOT vr_tab_crapass.EXISTS(rw_crapsld.nrdconta) THEN
                 --Buscar mensagem de erro da critica
                 vr_cdcritic := 251;
                 vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' CONTA = '||gene0002.fn_mask_conta(rw_crapsld.nrdconta);
                 --Abortar Programa
                 RAISE vr_exc_saida;
               ELSE
                 --numero da conta anterior recebe o numero da conta do associado
                 vr_nrdconta:= vr_tab_crapass(rw_crapsld.nrdconta).nrdconta;
                 --Valor do limite de credito recebe o limite do associado
                 vr_vllimcre:= vr_tab_crapass(rw_crapsld.nrdconta).vllimcre;
                 --Tipo de extrato de conta recebe o tipo de extrato do associado
                 vr_tpextcta:= vr_tab_crapass(rw_crapsld.nrdconta).tpextcta;
               END IF;
             END IF; --Nvl(vr_nrdconta,0) <> rw_crapsld.nrdconta

             --Se o tipo de extrato da conta for quinzenal (0=nao emite, 1=mensal, 2=quinzenal)
             IF vr_tpextcta = 2 THEN
               --Referencia do saldo para extrato recebe a data referencia saldo anterior
               rw_crapsld.dtsdexes:= rw_crapsld.dtsdanes;
               --Saldo para extrato especial recebe o saldo anterior para extrato
               rw_crapsld.vlsdexes:= rw_crapsld.vlsdanes;
               --data referencia saldo anterior recebe a data do movimento
               rw_crapsld.dtsdanes:= vr_dtmvtolt;
               --saldo anterior para extrato recebe:
               --vlsdblfp = valor do saldo bloqueado fora da praca
               --vlsdbloq = valor saldo bloqueado
               --vlsdblpr = valor do saldo bloqueado praca
               --vlsdchsl = valor do saldo cheque salario
               --vlsddisp = valor do saldo disponivel
               rw_crapsld.vlsdanes:= Nvl(rw_crapsld.vlsddisp,0) + Nvl(rw_crapsld.vlsdchsl,0);
             END IF;
           END IF;  --vr_flgquinz


           --Acumular em valor saldo positivo no mes o valor da tabela
           vr_vlsmpmes:= Nvl(vr_vlsmpmes,0) + Nvl(rw_crapsld.vlsmpmes,0);
           --Acumular em valor negativo especial do mes o valor da tabela
           vr_vlsmnesp:= Nvl(vr_vlsmnesp,0) + Nvl(rw_crapsld.vlsmnesp,0);
           --Acumular em valor saldo negativo no mes o valor da tabela
           vr_vlsmnmes:= Nvl(vr_vlsmnmes,0) + Nvl(rw_crapsld.vlsmnmes,0);
           --Acumular em media saque sem bloqueado o valor da tabela
           vr_vlsmnblq:= Nvl(vr_vlsmnblq,0) + Nvl(rw_crapsld.vlsmnblq,0);

           --Criando base para calculo do VAR
           --Zerar valor limite credito
           vr_vllimcre:= 0;
           --Data final vigencia recebe proxima data movimento
           vr_dtfimvig:= vr_dtmvtopr;

           --Verificar se o associado nao está cadastrado
           IF NOT vr_tab_crapass.EXISTS(rw_crapsld.nrdconta) THEN

             --Buscar mensagem de erro da critica
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 9) || ' ERRO NO CALCULO DO VAR '||gene0002.fn_mask_conta(rw_crapsld.nrdconta);
             --Aborta o programa
             RAISE vr_exc_saida;
           ELSE
             --Se o valor do limite de credito do associado for diferente zero
             IF vr_tab_crapass(rw_crapsld.nrdconta).vllimcre <> 0 THEN
               --Atribuir para valor limite de credito o limite de credito do associado
               vr_vllimcre:= vr_tab_crapass(rw_crapsld.nrdconta).vllimcre;

               --Se existir limites de credito para o associado
               IF vr_flglimite THEN
                 --Selecionar Cadastro de linhas de credito rotativos
                 IF NOT vr_tab_craplrt.EXISTS(rw_craplim.cddlinha) THEN
                   --Buscar mensagem de erro da critica
                   vr_cdcritic := 363;
                   vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' CONTA = '||gene0002.fn_mask_conta(rw_crapsld.nrdconta);
                   --Abortar Programa
                   RAISE vr_exc_saida;
                 ELSE
                   --Data final de vigencia recebe a data de final de vigencia do limite de credito do associado
                   vr_dtfimvig:= rw_craplim.dtinivig;
                   --Enquanto a data final de vigencia for menor que a data do movimento
                   WHILE vr_dtfimvig < vr_dtmvtolt LOOP
                     --Incrementar Data final de vigencia com quantidade dias vigencia do credito rotativo
                     vr_dtfimvig:= vr_dtfimvig + vr_tab_qtdiavig(rw_craplim.cddlinha);
                   END LOOP;
                 END IF;
               END IF;
             END IF;

             --linha(1261)
             --Valor disponivel var recebe:
             --vlsdblfp = valor do saldo bloqueado fora da praca
             --vlsdbloq = valor saldo bloqueado
             --vlsdblpr = valor do saldo bloqueado praca
             --vlsdchsl = valor do saldo cheque salario
             --vlsddisp = valor do saldo disponivel

             vr_vldisvar:= Nvl(rw_crapsld.vlsddisp,0) + Nvl(rw_crapsld.vlsdchsl,0);

           END IF;  --cr_crapass_conta%NOTFOUND

           --Data de referencia do saldo recebe a data do movimento
           rw_crapsld.dtrefere:= vr_dtmvtolt;
           --Montar linha descriacao de restart com as informacoes:
           --vlsmpmes = valor saldo positivo no mes
           --vlsmnesp = valor negativo especial do mes
           --vlsmnmes = valor saldo negativo no mes
           --vlsmnblq = media saque sem bloqueado
           vr_dsrestar:= TO_CHAR(vr_vlsmpmes,'000000000000D00MI') || ' ' ||
                         TO_CHAR(vr_vlsmnesp,'000000000000D00MI') || ' ' ||
                         TO_CHAR(vr_vlsmnmes,'000000000000D00MI') || ' ' ||
                         TO_CHAR(vr_vlsmnblq,'000000000000D00MI');

           --Criar registro de saldo
           --Se nao existir limite para a conta zera valor limite
           IF NOT vr_flglimite THEN
             --Zerar o limite de credito se o valor do limite estiver nulo
             rw_craplim.vllimite:= 0;
           END IF;

           vr_vldcotas := 0;
           OPEN cr_crapcot(pr_nrdconta => rw_crapsld.nrdconta);
           FETCH cr_crapcot
           INTO vr_vldcotas;
           CLOSE cr_crapcot;
           
           -- Consulta valor bloqueado referente a acordos de emprestimos
           RECP0001.pc_ret_vlr_bloq_acordo(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => rw_crapsld.nrdconta
                                          ,pr_vlblqaco => vr_vlblqaco
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);

           -- Verifica se houve erro na consulta                               
           IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
             --Aborta o programa
             RAISE vr_exc_saida;
           END IF;                               

					 vr_vlblqprj := PREJ0003.fn_sld_cta_prj(pr_cdcooper, rw_crapsld.nrdconta, 0);

           --Proximo indice na tabela
           vr_index_crapsda:= vr_tab_crapsda2.count+1;
           vr_tab_crapsda2(vr_index_crapsda).nrdconta:= rw_crapsld.nrdconta;
           vr_tab_crapsda2(vr_index_crapsda).dtmvtolt:= vr_dtmvtolt;
           vr_tab_crapsda2(vr_index_crapsda).vlsddisp:= rw_crapsld.vlsddisp;
           vr_tab_crapsda2(vr_index_crapsda).vlsdchsl:= rw_crapsld.vlsdchsl;
           vr_tab_crapsda2(vr_index_crapsda).vlsdbloq:= rw_crapsld.vlsdbloq;
           vr_tab_crapsda2(vr_index_crapsda).vlsdblpr:= rw_crapsld.vlsdblpr;
           vr_tab_crapsda2(vr_index_crapsda).vlsdblfp:= rw_crapsld.vlsdblfp;
           vr_tab_crapsda2(vr_index_crapsda).vlblqjud:= rw_crapsld.vlblqjud;
           vr_tab_crapsda2(vr_index_crapsda).vlsdindi:= rw_crapsld.vlsdindi;
           vr_tab_crapsda2(vr_index_crapsda).dtdsdclq:= rw_crapsld.dtdsdclq;
           vr_tab_crapsda2(vr_index_crapsda).vllimcre:= rw_craplim.vllimite;
           vr_tab_crapsda2(vr_index_crapsda).cdcooper:= pr_cdcooper;
           vr_tab_crapsda2(vr_index_crapsda).vlsdcota:= vr_vldcotas;
           vr_tab_crapsda2(vr_index_crapsda).vlblqaco:= vr_vlblqaco;
					 vr_tab_crapsda2(vr_index_crapsda).vlblqprj:= vr_vlblqprj;

           --Atualizar a tabela Saldos
           vr_index_crapsld:= vr_tab_crapsld.count+1;
           vr_tab_crapsld(vr_index_crapsld).vlsddisp:= rw_crapsld.vlsddisp;
           vr_tab_crapsld(vr_index_crapsld).vlsdchsl:= rw_crapsld.vlsdchsl;
           vr_tab_crapsld(vr_index_crapsld).vlsdbloq:= rw_crapsld.vlsdbloq;
           vr_tab_crapsld(vr_index_crapsld).vlsdblpr:= rw_crapsld.vlsdblpr;
           vr_tab_crapsld(vr_index_crapsld).vlsdblfp:= rw_crapsld.vlsdblfp;
           vr_tab_crapsld(vr_index_crapsld).vltsallq:= rw_crapsld.vltsallq;
           vr_tab_crapsld(vr_index_crapsld).dtrisclq:= rw_crapsld.dtrisclq;
           vr_tab_crapsld(vr_index_crapsld).dtdsdclq:= rw_crapsld.dtdsdclq;
           vr_tab_crapsld(vr_index_crapsld).qtddsdev:= rw_crapsld.qtddsdev;
           vr_tab_crapsld(vr_index_crapsld).qtddtdev:= rw_crapsld.qtddtdev;
           vr_tab_crapsld(vr_index_crapsld).qtdriclq:= rw_crapsld.qtdriclq;
           vr_tab_crapsld(vr_index_crapsld).vlsmnesp:= rw_crapsld.vlsmnesp;
           vr_tab_crapsld(vr_index_crapsld).vlsmnblq:= rw_crapsld.vlsmnblq;
           vr_tab_crapsld(vr_index_crapsld).vlsmnmes:= rw_crapsld.vlsmnmes;
           vr_tab_crapsld(vr_index_crapsld).qtddusol:= rw_crapsld.qtddusol;
           vr_tab_crapsld(vr_index_crapsld).vlsmpmes:= rw_crapsld.vlsmpmes;
           vr_tab_crapsld(vr_index_crapsld).vlipmfap:= rw_crapsld.vlipmfap;
           vr_tab_crapsld(vr_index_crapsld).vlipmfpg:= rw_crapsld.vlipmfpg;
           vr_tab_crapsld(vr_index_crapsld).vlbasipm:= rw_crapsld.vlbasipm;
           vr_tab_crapsld(vr_index_crapsld).vlbasiof:= rw_crapsld.vlbasiof;
           vr_tab_crapsld(vr_index_crapsld).vliofmes:= rw_crapsld.vliofmes;
           vr_tab_crapsld(vr_index_crapsld).qtlanmes:= rw_crapsld.qtlanmes;
           vr_tab_crapsld(vr_index_crapsld).dtsdexes:= rw_crapsld.dtsdexes;
           vr_tab_crapsld(vr_index_crapsld).vlsdexes:= rw_crapsld.vlsdexes;
           vr_tab_crapsld(vr_index_crapsld).dtsdanes:= rw_crapsld.dtsdanes;
           vr_tab_crapsld(vr_index_crapsld).vlsdanes:= rw_crapsld.vlsdanes;
           vr_tab_crapsld(vr_index_crapsld).dtrefere:= rw_crapsld.dtrefere;
           vr_tab_crapsld(vr_index_crapsld).vlblqjud:= rw_crapsld.vlblqjud;
					 vr_tab_crapsld(vr_index_crapsld).vlblqprj:= vr_vlblqprj;
           vr_tab_crapsld(vr_index_crapsld).vr_rowid:= rw_crapsld.ROWID;

           -- Somente se a flag de restart estiver ativa
           IF pr_flgresta = 1 THEN
             --Salvar Informacoes a cada 10.000 registros
             IF MOD(cr_crapsld%ROWCOUNT,10000) = 0 THEN
               -- Atualizar tabela crapsda
               BEGIN
                 FORALL idx IN INDICES OF vr_tab_crapsda2 SAVE EXCEPTIONS
                   INSERT INTO crapsda
                          (crapsda.nrdconta
                          ,crapsda.dtmvtolt
                          ,crapsda.vlsddisp
                          ,crapsda.vlsdchsl
                          ,crapsda.vlsdbloq
                          ,crapsda.vlsdblpr
                          ,crapsda.vlsdblfp
                          ,crapsda.vlblqjud
                          ,crapsda.vlsdindi
                          ,crapsda.dtdsdclq
                          ,crapsda.vllimcre
                          ,crapsda.cdcooper
                          ,crapsda.vlsdcota
                          ,crapsda.vlblqaco
                          ,crapsda.vlblqprj)
                   VALUES (vr_tab_crapsda2(idx).nrdconta
                          ,vr_tab_crapsda2(idx).dtmvtolt
                          ,vr_tab_crapsda2(idx).vlsddisp
                          ,vr_tab_crapsda2(idx).vlsdchsl
                          ,vr_tab_crapsda2(idx).vlsdbloq
                          ,vr_tab_crapsda2(idx).vlsdblpr
                          ,vr_tab_crapsda2(idx).vlsdblfp
                          ,vr_tab_crapsda2(idx).vlblqjud
                          ,vr_tab_crapsda2(idx).vlsdindi
                          ,vr_tab_crapsda2(idx).dtdsdclq
                          ,vr_tab_crapsda2(idx).vllimcre
                          ,vr_tab_crapsda2(idx).cdcooper
                          ,vr_tab_crapsda2(idx).vlsdcota
                          ,vr_tab_crapsda2(idx).vlblqaco
                          ,vr_tab_crapsda2(idx).vlblqprj);
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_dscritic:= 'Erro ao atualizar tabela crapsda. '||SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
                   --Levantar Exceção
                   RAISE vr_exc_saida;
               END;
               -- Limpar a tabela
               vr_tab_crapsda2.DELETE;
               -- Atualizar tabela crapsld
               BEGIN
                 FORALL idx IN INDICES OF vr_tab_crapsld SAVE EXCEPTIONS
                   UPDATE crapsld SET
                      crapsld.vlsddisp = vr_tab_crapsld(idx).vlsddisp
                     ,crapsld.vlsdchsl = vr_tab_crapsld(idx).vlsdchsl
                     ,crapsld.vlsdbloq = vr_tab_crapsld(idx).vlsdbloq
                     ,crapsld.vlsdblpr = vr_tab_crapsld(idx).vlsdblpr
                     ,crapsld.vlsdblfp = vr_tab_crapsld(idx).vlsdblfp
                     ,crapsld.vltsallq = vr_tab_crapsld(idx).vltsallq
                     ,crapsld.dtrisclq = vr_tab_crapsld(idx).dtrisclq
                     ,crapsld.dtdsdclq = vr_tab_crapsld(idx).dtdsdclq
                     ,crapsld.qtddsdev = vr_tab_crapsld(idx).qtddsdev
                     ,crapsld.qtddtdev = vr_tab_crapsld(idx).qtddtdev
                     ,crapsld.qtdriclq = vr_tab_crapsld(idx).qtdriclq
                     ,crapsld.vlsmnesp = vr_tab_crapsld(idx).vlsmnesp
                     ,crapsld.vlsmnblq = vr_tab_crapsld(idx).vlsmnblq
                     ,crapsld.vlsmnmes = vr_tab_crapsld(idx).vlsmnmes
                     ,crapsld.qtddusol = vr_tab_crapsld(idx).qtddusol
                     ,crapsld.vlsmpmes = vr_tab_crapsld(idx).vlsmpmes
                     ,crapsld.vlipmfap = vr_tab_crapsld(idx).vlipmfap
                     ,crapsld.vlipmfpg = vr_tab_crapsld(idx).vlipmfpg
                     ,crapsld.vlbasipm = vr_tab_crapsld(idx).vlbasipm
                     ,crapsld.vlbasiof = vr_tab_crapsld(idx).vlbasiof
                     ,crapsld.vliofmes = vr_tab_crapsld(idx).vliofmes
                     ,crapsld.qtlanmes = vr_tab_crapsld(idx).qtlanmes
                     ,crapsld.dtsdexes = vr_tab_crapsld(idx).dtsdexes
                     ,crapsld.vlsdexes = vr_tab_crapsld(idx).vlsdexes
                     ,crapsld.dtsdanes = vr_tab_crapsld(idx).dtsdanes
                     ,crapsld.vlsdanes = vr_tab_crapsld(idx).vlsdanes
                     ,crapsld.dtrefere = vr_tab_crapsld(idx).dtrefere
                     ,crapsld.vlblqjud = vr_tab_crapsld(idx).vlblqjud
                     ,crapsld.vlblqprj = vr_tab_crapsld(idx).vlblqprj
                   WHERE rowid = vr_tab_crapsld(idx).vr_rowid;
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_dscritic:= 'Erro ao atualizar tabela crapsld. '||SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
                   --Levantar Exceção
                   RAISE vr_exc_saida;
               END;
               -- Limpar a Tabela
               vr_tab_crapsld.DELETE;
               -- Atualizar tabela crapres para controle do restart
               BEGIN
                 UPDATE crapres SET crapres.nrdconta = rw_crapsld.nrdconta
                                   ,crapres.dsrestar = vr_dsrestar
                 WHERE crapres.cdcooper = pr_cdcooper
                 AND   upper(crapres.cdprogra) = vr_cdprogra;
               EXCEPTION
               WHEN OTHERS THEN
                 --Variavel de erro recebe erro ocorrido
                 vr_dscritic := 'Erro ao atualizar tabela crapres. '||SQLERRM;
                 --Sair do programa
                 RAISE vr_exc_saida;
               END;
               COMMIT; 
             END IF;
           END IF;
         EXCEPTION
           WHEN vr_exc_saida THEN
             RAISE;
           WHEN OTHERS THEN
             cecred.pc_internal_exception(pr_cdcooper);
             vr_dscritic := 'Erro loopcrapsld('||pr_cdcooper||','||rw_crapsld.nrdconta||'):'||SQLERRM
                          ||' DbmsUtility: '||dbms_utility.format_error_backtrace
                          ||' - '||dbms_utility.format_error_stack;
             /*erro pode ser encontrado na tabela tbgen_erro_sistema*/
             cecred.pc_log_programa(PR_DSTIPLOG => 'E'
                                   ,PR_CDPROGRAMA => 'CRPS001'
                                   ,pr_cdcooper => pr_cdcooper
                                   ,pr_dsmensagem => vr_dscritic
                                   ,PR_IDPRGLOG => vr_idprglog);
             RAISE vr_exc_saida;
         END;
       END LOOP; --rw_crapsld

       BEGIN
        FORALL vr_tarindic IN INDICES OF vr_tab_tarifas SAVE EXCEPTIONS
          UPDATE tbgen_iof_lancamento SET
                 tbgen_iof_lancamento.idlautom     = vr_tab_tarifas(vr_tarindic).idlautom
                ,tbgen_iof_lancamento.dtmvtolt_lcm = vr_tab_tarifas(vr_tarindic).dtmvtolt
                ,tbgen_iof_lancamento.cdagenci_lcm = vr_tab_tarifas(vr_tarindic).cdagenci_lcm
                ,tbgen_iof_lancamento.cdbccxlt_lcm = vr_tab_tarifas(vr_tarindic).cdbccxlt_lcm
                ,tbgen_iof_lancamento.nrdolote_lcm = vr_tab_tarifas(vr_tarindic).nrdolote_lcm
                ,tbgen_iof_lancamento.nrseqdig_lcm = vr_tab_tarifas(vr_tarindic).nrseqdig_lcm
           WHERE tbgen_iof_lancamento.cdcooper   = vr_tab_tarifas(vr_tarindic).cdcooper
             AND tbgen_iof_lancamento.nrdconta   = vr_tab_tarifas(vr_tarindic).nrdconta
             AND tbgen_iof_lancamento.nrcontrato = vr_tab_tarifas(vr_tarindic).nrcontrato
             AND tbgen_iof_lancamento.tpproduto  = vr_tab_tarifas(vr_tarindic).tpproduto
             AND tbgen_iof_lancamento.idlautom     IS NULL
             AND tbgen_iof_lancamento.dtmvtolt_lcm IS NULL
             AND tbgen_iof_lancamento.cdagenci_lcm IS NULL
             AND tbgen_iof_lancamento.cdbccxlt_lcm IS NULL
             AND tbgen_iof_lancamento.nrdolote_lcm IS NULL
             AND tbgen_iof_lancamento.nrseqdig_lcm IS NULL
             AND tbgen_iof_lancamento.dtmvtolt < vr_tab_tarifas(vr_tarindic).dtmvtolt;
      EXCEPTION
        WHEN OTHERS THEN 
           FOR i IN 1..SQL%BULK_EXCEPTIONS.count LOOP
              -- Montar Mensagem
              vr_result:= 'Erro: '||i|| ' Indice: '||SQL%BULK_EXCEPTIONS(i).error_index ||' - '|| 
                          SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE);     
              -- Iniciar LOG de execução
              BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratado
                                        ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_cdprogra ||' --> '||vr_result); --> Log específico deste programa

           END LOOP;
          
           RAISE vr_exc_saida;            
      END;
       
       -- Atualizar tabela crapsda
       BEGIN
         FORALL idx IN INDICES OF vr_tab_crapsda2 SAVE EXCEPTIONS
           INSERT INTO crapsda
                  (crapsda.nrdconta
                  ,crapsda.dtmvtolt
                  ,crapsda.vlsddisp
                  ,crapsda.vlsdchsl
                  ,crapsda.vlsdbloq
                  ,crapsda.vlsdblpr
                  ,crapsda.vlsdblfp
                  ,crapsda.vlblqjud
                  ,crapsda.vlsdindi
                  ,crapsda.dtdsdclq
                  ,crapsda.vllimcre
                  ,crapsda.cdcooper
                  ,crapsda.vlsdcota
                  ,crapsda.vlblqprj)
           VALUES (vr_tab_crapsda2(idx).nrdconta
                  ,vr_tab_crapsda2(idx).dtmvtolt
                  ,vr_tab_crapsda2(idx).vlsddisp
                  ,vr_tab_crapsda2(idx).vlsdchsl
                  ,vr_tab_crapsda2(idx).vlsdbloq
                  ,vr_tab_crapsda2(idx).vlsdblpr
                  ,vr_tab_crapsda2(idx).vlsdblfp
                  ,vr_tab_crapsda2(idx).vlblqjud
                  ,vr_tab_crapsda2(idx).vlsdindi
                  ,vr_tab_crapsda2(idx).dtdsdclq
                  ,vr_tab_crapsda2(idx).vllimcre
                  ,vr_tab_crapsda2(idx).cdcooper
                  ,vr_tab_crapsda2(idx).vlsdcota
                  ,vr_tab_crapsda2(idx).vlblqprj);
       EXCEPTION
         WHEN OTHERS THEN
           vr_dscritic:= 'Erro ao atualizar tabela crapsda. '||SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
           --Levantar Exceção
           RAISE vr_exc_saida;
       END;
       -- Atualizar tabela crapsld
       BEGIN
         FORALL idx IN INDICES OF vr_tab_crapsld SAVE EXCEPTIONS
           UPDATE crapsld SET
              crapsld.vlsddisp = vr_tab_crapsld(idx).vlsddisp
             ,crapsld.vlsdchsl = vr_tab_crapsld(idx).vlsdchsl
             ,crapsld.vlsdbloq = vr_tab_crapsld(idx).vlsdbloq
             ,crapsld.vlsdblpr = vr_tab_crapsld(idx).vlsdblpr
             ,crapsld.vlsdblfp = vr_tab_crapsld(idx).vlsdblfp
             ,crapsld.vltsallq = vr_tab_crapsld(idx).vltsallq
             ,crapsld.dtrisclq = vr_tab_crapsld(idx).dtrisclq
             ,crapsld.dtdsdclq = vr_tab_crapsld(idx).dtdsdclq
             ,crapsld.qtddsdev = vr_tab_crapsld(idx).qtddsdev
             ,crapsld.qtddtdev = vr_tab_crapsld(idx).qtddtdev
             ,crapsld.qtdriclq = vr_tab_crapsld(idx).qtdriclq
             ,crapsld.vlsmnesp = vr_tab_crapsld(idx).vlsmnesp
             ,crapsld.vlsmnblq = vr_tab_crapsld(idx).vlsmnblq
             ,crapsld.vlsmnmes = vr_tab_crapsld(idx).vlsmnmes
             ,crapsld.qtddusol = vr_tab_crapsld(idx).qtddusol
             ,crapsld.vlsmpmes = vr_tab_crapsld(idx).vlsmpmes
             ,crapsld.vlipmfap = vr_tab_crapsld(idx).vlipmfap
             ,crapsld.vlipmfpg = vr_tab_crapsld(idx).vlipmfpg
             ,crapsld.vlbasipm = vr_tab_crapsld(idx).vlbasipm
             ,crapsld.vlbasiof = vr_tab_crapsld(idx).vlbasiof
             ,crapsld.vliofmes = vr_tab_crapsld(idx).vliofmes
             ,crapsld.qtlanmes = vr_tab_crapsld(idx).qtlanmes
             ,crapsld.dtsdexes = vr_tab_crapsld(idx).dtsdexes
             ,crapsld.vlsdexes = vr_tab_crapsld(idx).vlsdexes
             ,crapsld.dtsdanes = vr_tab_crapsld(idx).dtsdanes
             ,crapsld.vlsdanes = vr_tab_crapsld(idx).vlsdanes
             ,crapsld.dtrefere = vr_tab_crapsld(idx).dtrefere
             ,crapsld.vlblqjud = vr_tab_crapsld(idx).vlblqjud
             ,crapsld.vlblqprj = vr_tab_crapsld(idx).vlblqprj
           WHERE rowid = vr_tab_crapsld(idx).vr_rowid;
       EXCEPTION
         WHEN OTHERS THEN
           vr_dscritic:= 'Erro ao atualizar tabela crapsld. '||SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
           --Levantar Exceção
           RAISE vr_exc_saida;
       END;
       --Inicio da transacao 2
       OPEN cr_craptab (pr_cdcooper => pr_cdcooper
                       ,pr_nmsistem => 'CRED'
                       ,pr_tptabela => 'GENERI'
                       ,pr_cdempres => 0
                       ,pr_cdacesso => 'SALDOMEDIO'
                       ,pr_tpregist => 0);
       --Posicionar no proximo registro
       FETCH cr_craptab INTO rw_craptab;
       --Se nao encontrou entao
       IF cr_craptab%NOTFOUND THEN
         --Fechar cursor
         CLOSE cr_craptab;
         --Buscar mensagem de erro da critica
         vr_cdcritic := 55;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' CRED-GENERI-00-SALDOMEDIO-000';
         --Sair do programa
         RAISE vr_exc_saida;
       ELSE
         --Atualizar tabela craptab
         BEGIN
           UPDATE craptab SET craptab.dstextab = vr_dsrestar
           WHERE craptab.ROWID = rw_craptab.ROWID;
         EXCEPTION
           WHEN OTHERS THEN
             vr_dscritic := 'Erro ao atualizar tabela craptab. '||SQLERRM;
             --Fechar cursor
             CLOSE cr_craptab;
             --Sair do programa
             RAISE vr_exc_saida;
         END;
       END IF;
       --Fechar cursor
       CLOSE cr_craptab;

       /* Eliminação dos registros de restart */
       BTCH0001.pc_elimina_restart(pr_cdcooper => pr_cdcooper
                                  ,pr_cdprogra => vr_cdprogra
                                  ,pr_flgresta => pr_flgresta
                                  ,pr_des_erro => vr_dscritic);
       --Se ocorreu erro
       IF vr_dscritic IS NOT NULL THEN
         --Levantar Exceção
         RAISE vr_exc_saida;
       END IF;

       -- Processo OK, devemos chamar a fimprg
       btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_stprogra => pr_stprogra);


       --Salvar Informacoes no banco de dados
       COMMIT;

       --Zerar tabela de memoria auxiliar
       pc_limpa_tabela;

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

        pc_limpa_tabela;

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

        pc_limpa_tabela;

        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;

        declare
          vr_idprglog integer := 0;
        begin
          /*erro pode ser encontrado na tabela tbgen_erro_sistema*/
          cecred.pc_log_programa(PR_DSTIPLOG => 'E'
                                ,PR_CDPROGRAMA => 'CRPS001'
                                ,pr_cdcooper => pr_cdcooper
                                ,pr_dsmensagem => pr_dscritic
                                ,PR_IDPRGLOG => vr_idprglog);
        end;

        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        cecred.pc_internal_exception(pr_cdcooper);

        pc_limpa_tabela;

        declare
          vr_dscritic varchar2(32000);
          vr_idprglog integer := 0;
        begin
          vr_dscritic := 'Erro geral crps001:'||SQLERRM
                       ||' DbmsUtility: '||dbms_utility.format_error_backtrace
                       ||' - '||dbms_utility.format_error_stack;
          /*erro pode ser encontrado na tabela tbgen_erro_sistema*/
          cecred.pc_log_programa(PR_DSTIPLOG => 'E'
                                ,PR_CDPROGRAMA => 'CRPS001'
                                ,pr_cdcooper => pr_cdcooper
                                ,pr_dsmensagem => vr_dscritic
                                ,PR_IDPRGLOG => vr_idprglog);
        end;

        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
     END;
   END pc_crps001;
/
