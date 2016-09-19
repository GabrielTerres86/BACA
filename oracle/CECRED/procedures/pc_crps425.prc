create or replace procedure cecred.pc_crps425(pr_cdcooper  in craptab.cdcooper%type,
                                              pr_flgresta  in pls_integer,            --> Flag padrão para utilização de restart
                                              pr_stprogra out pls_integer,            --> Saída de termino da execução
                                              pr_infimsol out pls_integer,            --> Saída de termino da solicitação,
                                              pr_cdcritic out crapcri.cdcritic%type,
                                              pr_dscritic out varchar2) as
	/* .............................................................................

   Programa: pc_crps425 - Antigo Fontes/crps425.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Novembro/2004.                    Ultima atualizacao: 28/08/2014

   Dados referentes ao programa:

   Frequencia: Mensal.

   Objetivo  : Atende a solicitacao 39.
               Emitir relatorio (379) do resumo mensal dos historicos por PAC.

   Alteracoes: 04/01/2004 - Referenciado STREAM no comando DOWN,
                            frame f_lanctos (Evandro).

               12/09/2005 - Alterado o endereco para envio do e-mail do
                            Roberto para o Fabio (Julio)

               23/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               09/12/2005 - Considerar lancamentos COBAN - crapcbb (Evandro).

               17/02/2006 - Unificacao dos Bancos - Fernando - SQLWorks.

               25/03/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)

               09/06/2008 - Incluída a chave de acesso (craphis.cdcooper =
                            glb_cdcooper) no "find" da tabela CRAPHIS.
                          - Kbase IT Solutions - Paulo Ricardo Maciel.

               13/10/2008 - Adaptacao para desconto de titulos (David).

               12/06/2009 - Retirado e_mail Fabio(Mirtes)

               01/07/2009 - Melhoria de performance (Evandro).

               19/10/2009 - Alteracao Codigo Historico (Kbase).

               08/03/2010 - Alteracao Historico (Gati)

               06/09/2010 - Inclusao de indice na temp-table tt-hist para
                            melhoria de performance e ajuste de padrao de
                            escrita (Evandro).

               28/03/2013 - Ajustes referentes ao Projeto de tarifas fase 2
                            Grupo de cheques (Lucas R.)

               16/08/2013 - Nova forma de chamar as agencias, de PAC agora
                            a escrita será PA (André Euzébio - Supero).

               06/03/2014 - Conversão Progress >> Oracle PL/SQL (Daniel - Supero).
               
               23/05/2014 - Ajustado para converter o relatorio(ux2dos) antes de envia-lo por e-mail(Odirlei-AMcom)               
							 
							 28/08/2014 - Adicionado tratamento para lançamentos de produtos
							              de captação (Reinert)
               
  ............................................................................. */

  -- Buscar os dados da cooperativa
  cursor cr_crapcop (pr_cdcooper in craptab.cdcooper%type) is
    select crapcop.nmrescop,
           crapcop.nrtelura,
           crapcop.dsdircop,
           crapcop.cdbcoctl,
           crapcop.cdagectl
      from crapcop
     where cdcooper = pr_cdcooper;
  rw_crapcop     cr_crapcop%rowtype;
  -- Descrição dos históricos
  cursor cr_craphis (pr_cdcooper in crapcop.cdcooper%type) is
    select his.cdhistor,
           lpad(his.cdhistor, 4, '0')||' - '||his.dshistor dshistor
      from craphis his
     where his.cdcooper = pr_cdcooper;
  -- Nome das agências
  cursor cr_crapage (pr_cdcooper in crapcop.cdcooper%type) is
    select age.cdagenci,
           lpad(age.cdagenci, 3, '0')||' - '||age.nmresage nmresage
      from crapage age
     where age.cdcooper = pr_cdcooper;
  -- Cadastro dos lancamentos de aplicacoes RDCA.
  cursor cr_craplap (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtliminf in crapdat.dtmvtolt%type,
                     pr_dtlimsup in crapdat.dtmvtolt%type) is
    select ass.cdagenci,
           tab.cdhistor,
           count(*) qtlancto
      from crapass ass,
           craplap tab
     where ass.cdcooper = pr_cdcooper
       and tab.cdcooper = ass.cdcooper
       and tab.nrdconta = ass.nrdconta
       and tab.dtmvtolt between pr_dtliminf and pr_dtlimsup
     group by ass.cdagenci,
              tab.cdhistor;
							
  -- Lançamentos das aplicações
  CURSOR cr_craplac (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtliminf in crapdat.dtmvtolt%type,
                     pr_dtlimsup in crapdat.dtmvtolt%type) IS

    
    SELECT ass.cdagenci
		      ,lac.cdhistor
					,COUNT(1) qtlancto
      FROM craplac lac,
           crapass ass
		 WHERE lac.cdcooper = pr_cdcooper
       AND lac.cdcooper = ass.cdcooper
       AND lac.nrdconta = ass.nrdconta    
		   AND lac.dtmvtolt BETWEEN pr_dtliminf AND pr_dtlimsup
		 GROUP BY ass.cdagenci,
              lac.nrdconta,
		          lac.cdhistor;
  										 
  -- Lancamentos Automaticos
  cursor cr_craplau (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtliminf in crapdat.dtmvtolt%type,
                     pr_dtlimsup in crapdat.dtmvtolt%type) is
    select ass.cdagenci,
           tab.cdhistor,
           count(*) qtlancto
      from crapass ass,
           craplau tab
     where ass.cdcooper = pr_cdcooper
       and tab.cdcooper = ass.cdcooper
       and tab.nrdconta = ass.nrdconta
       and tab.dtmvtolt between pr_dtliminf and pr_dtlimsup
     group by ass.cdagenci,
              tab.cdhistor;
  -- Lancamentos de tarifas
  cursor cr_craplat (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtliminf in crapdat.dtmvtolt%type,
                     pr_dtlimsup in crapdat.dtmvtolt%type) is
    select ass.cdagenci,
           tab.cdhistor,
           count(*) qtlancto
      from crapass ass,
           craplat tab
     where ass.cdcooper = pr_cdcooper
       and tab.cdcooper = ass.cdcooper
       and tab.nrdconta = ass.nrdconta
       and tab.dtmvtolt between pr_dtliminf and pr_dtlimsup
     group by ass.cdagenci,
              tab.cdhistor;
  -- Lancamentos de cobranca.
  cursor cr_craplcb (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtliminf in crapdat.dtmvtolt%type,
                     pr_dtlimsup in crapdat.dtmvtolt%type) is
    select ass.cdagenci,
           tab.cdhistor,
           count(*) qtlancto
      from crapass ass,
           craplcb tab
     where ass.cdcooper = pr_cdcooper
       and tab.cdcooper = ass.cdcooper
       and tab.nrdconta = ass.nrdconta
       and tab.dtmvtolt between pr_dtliminf and pr_dtlimsup
     group by ass.cdagenci,
              tab.cdhistor;
  -- Lancamentos da conta investimento
  cursor cr_craplci (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtliminf in crapdat.dtmvtolt%type,
                     pr_dtlimsup in crapdat.dtmvtolt%type) is
    select ass.cdagenci,
           tab.cdhistor,
           count(*) qtlancto
      from crapass ass,
           craplci tab
     where ass.cdcooper = pr_cdcooper
       and tab.cdcooper = ass.cdcooper
       and tab.nrdconta = ass.nrdconta
       and tab.dtmvtolt between pr_dtliminf and pr_dtlimsup
     group by ass.cdagenci,
              tab.cdhistor;
  -- Lancamentos em depositos a vista
  cursor cr_craplcm (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtliminf in crapdat.dtmvtolt%type,
                     pr_dtlimsup in crapdat.dtmvtolt%type) is
    select ass.cdagenci,
           tab.cdhistor,
           count(*) qtlancto
      from crapass ass,
           craplcm tab
     where ass.cdcooper = pr_cdcooper
       and tab.cdcooper = ass.cdcooper
       and tab.nrdconta = ass.nrdconta
       and tab.dtmvtolt between pr_dtliminf and pr_dtlimsup
     group by ass.cdagenci,
              tab.cdhistor;
  -- Lancamentos de cotas/capital
  cursor cr_craplct (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtliminf in crapdat.dtmvtolt%type,
                     pr_dtlimsup in crapdat.dtmvtolt%type) is
    select ass.cdagenci,
           tab.cdhistor,
           count(*) qtlancto
      from crapass ass,
           craplct tab
     where ass.cdcooper = pr_cdcooper
       and tab.cdcooper = ass.cdcooper
       and tab.nrdconta = ass.nrdconta
       and tab.dtmvtolt between pr_dtliminf and pr_dtlimsup
     group by ass.cdagenci,
              tab.cdhistor;
  -- Lancamentos em emprestimos. (D-08)
  cursor cr_craplem (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtliminf in crapdat.dtmvtolt%type,
                     pr_dtlimsup in crapdat.dtmvtolt%type) is
    select ass.cdagenci,
           tab.cdhistor,
           count(*) qtlancto
      from crapass ass,
           craplem tab
     where ass.cdcooper = pr_cdcooper
       and tab.cdcooper = ass.cdcooper
       and tab.nrdconta = ass.nrdconta
       and tab.dtmvtolt between pr_dtliminf and pr_dtlimsup
     group by ass.cdagenci,
              tab.cdhistor;
  -- Cadastro de lancamentos de aplicacoes de poupanca programada.
  cursor cr_craplpp (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtliminf in crapdat.dtmvtolt%type,
                     pr_dtlimsup in crapdat.dtmvtolt%type) is
    select ass.cdagenci,
           tab.cdhistor,
           count(*) qtlancto
      from crapass ass,
           craplpp tab
     where ass.cdcooper = pr_cdcooper
       and tab.cdcooper = ass.cdcooper
       and tab.nrdconta = ass.nrdconta
       and tab.dtmvtolt between pr_dtliminf and pr_dtlimsup
     group by ass.cdagenci,
              tab.cdhistor;
  -- Log das transacoes efetuadas nos caixas e cash dispensers
  cursor cr_crapltr (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtliminf in crapdat.dtmvtolt%type,
                     pr_dtlimsup in crapdat.dtmvtolt%type) is
    select ass.cdagenci,
           tab.cdhistor,
           count(*) qtlancto
      from crapass ass,
           crapltr tab
     where ass.cdcooper = pr_cdcooper
       and tab.cdcooper = ass.cdcooper
       and tab.nrdconta = ass.nrdconta
       and tab.dtmvtolt between pr_dtliminf and pr_dtlimsup
     group by ass.cdagenci,
              tab.cdhistor;
  -- Tabela de Autenticacoes
  cursor cr_crapaut (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtliminf in crapdat.dtmvtolt%type,
                     pr_dtlimsup in crapdat.dtmvtolt%type) is
    select tab.cdagenci,
           9995 cdhistor,
           count(*) qtlancto
      from crapaut tab
     where tab.cdcooper = pr_cdcooper
       and tab.dtmvtolt between pr_dtliminf and pr_dtlimsup
       and exists (select 1
                     from crapass ass
                    where ass.cdcooper = tab.cdcooper
                      and ass.cdagenci = tab.cdagenci)
     group by tab.cdagenci;
  -- Lancamentos extra-sistema que compoem o boletim de caixa.
  cursor cr_craplcx (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtliminf in crapdat.dtmvtolt%type,
                     pr_dtlimsup in crapdat.dtmvtolt%type) is
    select tab.cdagenci,
           tab.cdhistor,
           count(*) qtlancto
      from craplcx tab
     where tab.cdcooper = pr_cdcooper
       and tab.dtmvtolt between pr_dtliminf and pr_dtlimsup
       and exists (select 1
                     from crapass ass
                    where ass.cdcooper = tab.cdcooper
                      and ass.cdagenci = tab.cdagenci)
     group by tab.cdagenci,
              tab.cdhistor;
  -- Lancamentos de faturas.
  cursor cr_craplft (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtliminf in crapdat.dtmvtolt%type,
                     pr_dtlimsup in crapdat.dtmvtolt%type) is
    select tab.cdagenci,
           tab.cdhistor,
           count(*) qtlancto
      from craplft tab
     where tab.cdcooper = pr_cdcooper
       and tab.dtmvtolt between pr_dtliminf and pr_dtlimsup
       and exists (select 1
                     from crapass ass
                    where ass.cdcooper = tab.cdcooper
                      and ass.cdagenci = tab.cdagenci)
     group by tab.cdagenci,
              tab.cdhistor;
  -- Titulos acolhidos
  cursor cr_craptit (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtliminf in crapdat.dtmvtolt%type,
                     pr_dtlimsup in crapdat.dtmvtolt%type) is
    select tab.cdagenci,
           9999 cdhistor,
           count(*) qtlancto
      from craptit tab
     where tab.cdcooper = pr_cdcooper
       and tab.dtmvtolt between pr_dtliminf and pr_dtlimsup
       and exists (select 1
                     from crapass ass
                    where ass.cdcooper = tab.cdcooper
                      and ass.cdagenci = tab.cdagenci)
     group by tab.cdagenci;
  -- Movimentos Correspondente Bancario - Banco do Brasil
  cursor cr_crapcbb (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtliminf in crapdat.dtmvtolt%type,
                     pr_dtlimsup in crapdat.dtmvtolt%type) is
    select tab.cdagenci,
           750 cdhistor,
           count(*) qtlancto
      from crapcbb tab
     where tab.cdcooper = pr_cdcooper
       and tab.dtmvtolt between pr_dtliminf and pr_dtlimsup
       and tab.tpdocmto < 3
       and tab.flgrgatv = 1
       and exists (select 1
                     from crapass ass
                    where ass.cdcooper = tab.cdcooper
                      and ass.cdagenci = tab.cdagenci)
     group by tab.cdagenci;

  -- Custodia de cheques
  cursor cr_crapcst (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtliminf in crapdat.dtmvtolt%type,
                     pr_dtlimsup in crapdat.dtmvtolt%type) is
    select ass.cdagenci,
           9997 cdhistor,
           count(*) qtlancto
      from crapass ass,
           crapcst tab
     where ass.cdcooper = pr_cdcooper
       and tab.cdcooper = ass.cdcooper
       and tab.nrdconta = ass.nrdconta
       and tab.dtmvtolt between pr_dtliminf and pr_dtlimsup
     group by ass.cdagenci;

  -- Cheques contidos do Bordero de desconto de cheques
  cursor cr_crapcdb (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtliminf in crapdat.dtmvtolt%type,
                     pr_dtlimsup in crapdat.dtmvtolt%type) is
    select ass.cdagenci,
           9996 cdhistor,
           count(*) qtlancto
      from crapass ass,
           crapcdb tab
     where ass.cdcooper = pr_cdcooper
       and tab.cdcooper = ass.cdcooper
       and tab.nrdconta = ass.nrdconta
       and tab.dtmvtolt between pr_dtliminf and pr_dtlimsup
     group by ass.cdagenci;

  -- Lancamento de juros de desconto de cheques
  cursor cr_crapljd (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtliminf in crapdat.dtmvtolt%type,
                     pr_dtlimsup in crapdat.dtmvtolt%type) is
    select ass.cdagenci,
           9998 cdhistor,
           count(*) qtlancto
      from crapass ass,
           crapljd tab
     where ass.cdcooper = pr_cdcooper
       and tab.cdcooper = ass.cdcooper
       and tab.nrdconta = ass.nrdconta
       and tab.dtmvtolt between pr_dtliminf and pr_dtlimsup
     group by ass.cdagenci;

  -- Titulos contidos do Bordero de desconto de titulos
  cursor cr_craptdb (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtliminf in crapdat.dtmvtolt%type,
                     pr_dtlimsup in crapdat.dtmvtolt%type) is
    select crapass.cdagenci,
           9993 cdhistor,
           count(*) qtlancto
      from crapass,
           craptdb,
           crapbdt
     where crapass.cdcooper = pr_cdcooper
       and crapbdt.cdcooper = crapass.cdcooper
       and crapbdt.nrdconta = crapass.nrdconta
       and crapbdt.dtmvtolt between pr_dtliminf and pr_dtlimsup
       and craptdb.cdcooper = crapbdt.cdcooper
       and craptdb.nrdconta = crapbdt.nrdconta
       and craptdb.nrborder = crapbdt.nrborder
     group by crapass.cdagenci;

  -- Lancamento de juros de desconto de titulos
  cursor cr_crapljt (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtliminf in crapdat.dtmvtolt%type,
                     pr_dtlimsup in crapdat.dtmvtolt%type) is
    select ass.cdagenci,
           9994 cdhistor,
           count(*) qtlancto
      from crapass ass,
           crapljt tab
     where ass.cdcooper = pr_cdcooper
       and tab.cdcooper = ass.cdcooper
       and tab.nrdconta = ass.nrdconta
       and tab.dtmvtolt between pr_dtliminf and pr_dtlimsup
     group by ass.cdagenci;

  -- PL/Table para armazenar os lançamentos por histórico
  type typ_histor is record (qtlancto    number(12));
  type typ_tab_histor is table of typ_histor index by pls_integer; -- O índice será o cdhistor

  -- PL/Table para armazenar o conjunto de lançamentos por agência
  type typ_agencia is record (vr_histor   typ_tab_histor);
  type typ_tab_agencia is table of typ_agencia index by pls_integer; -- O índice será o cdagenci

  -- O índice da pl/table é o código da agência e o código do histórico.
  vr_ind_histor      pls_integer;
  vr_ind_agencia     pls_integer;

  -- Variável para instanciar a pl/table
  vr_agencia         typ_tab_agencia;

  -- PL/Table para armazenar as descrições dos históricos
  type typ_craphis is record (dshistor   varchar2(57));
  type typ_tab_craphis is table of typ_craphis index by varchar2(5); -- O índice será o cdhistor

  -- Variável para instanciar a pl/table
  vr_craphis         typ_tab_craphis;

  -- PL/Table para armazenar os nomes das agências
  type typ_crapage is record (nmresage   varchar2(21));
  type typ_tab_crapage is table of typ_crapage index by varchar2(5); -- O índice será o cdagenci

  -- Variável para instanciar a pl/table
  vr_crapage         typ_tab_crapage;

  -- Variáveis auxiliares para agencia e histórico
  vr_nmresage        varchar2(21);
  vr_dshistor        varchar2(57);

  rw_crapdat         btch0001.cr_crapdat%rowtype;

  -- Código do programa
  vr_cdprogra        crapprg.cdprogra%type;

  -- Tratamento de erros
  vr_exc_saida       exception;
  vr_exc_fimprg      exception;
  vr_cdcritic        pls_integer;
  vr_dscritic        varchar2(4000);
  
  -- Variáveis para armazenar as informações em XML
  vr_des_xml         clob;
  
  -- Variável para armazenar os dados do XML antes de incluir no CLOB
  vr_texto_completo  varchar2(32600);
  
  -- Variável para o caminho e nome do arquivo base
  vr_nom_diretorio   varchar2(200);
  vr_nom_arquivo     varchar2(200);
  vr_nrcopias        number(1) := 1;
  
  -- Lista de destinatários do e-mail
  vr_destinatarios   varchar2(2000);
  
  -- Variáveis com o período a ser consultado
  vr_dtliminf        crapdat.dtmvtolt%type;
  vr_dtlimsup        crapdat.dtmvtolt%type;

  -- Subrotina para incluir informações na PL/Table de lançamentos
  procedure pc_insere_pltable(pr_cdagenci in crapage.cdagenci%type,
                              pr_cdhistor in craphis.cdhistor%type,
                              pr_qtlancto in number) is
  begin
    -- Acumula lançamentos
    if vr_agencia.exists(pr_cdagenci) then
      if vr_agencia(pr_cdagenci).vr_histor.exists(pr_cdhistor) then
        vr_agencia(pr_cdagenci).vr_histor(pr_cdhistor).qtlancto := vr_agencia(pr_cdagenci).vr_histor(pr_cdhistor).qtlancto + pr_qtlancto;
      else
        vr_agencia(pr_cdagenci).vr_histor(pr_cdhistor).qtlancto := pr_qtlancto;
      end if;
    else
      vr_agencia(pr_cdagenci).vr_histor(pr_cdhistor).qtlancto := pr_qtlancto;
    end if;
    -- Acumula total
    if vr_agencia.exists(99999) then
      if vr_agencia(99999).vr_histor.exists(pr_cdhistor) then
        vr_agencia(99999).vr_histor(pr_cdhistor).qtlancto := vr_agencia(99999).vr_histor(pr_cdhistor).qtlancto + pr_qtlancto;
      else
        vr_agencia(99999).vr_histor(pr_cdhistor).qtlancto := pr_qtlancto;
      end if;
    else
      vr_agencia(99999).vr_histor(pr_cdhistor).qtlancto := pr_qtlancto;
    end if;
  end;
  -- Subrotina para escrever texto na variável CLOB do XML
  procedure pc_escreve_xml(pr_des_dados in varchar2,
                           pr_fecha_xml in boolean default false) is
  begin
    gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
  end;

begin
  -- Nome do programa
  vr_cdprogra := 'CRPS425';
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS425',
                             pr_action => vr_cdprogra);
  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper,
                             pr_flgbatch => 1,
                             pr_cdprogra => vr_cdprogra,
                             pr_infimsol => pr_infimsol,
                             pr_cdcritic => vr_cdcritic);
  -- Se ocorreu erro
  if vr_cdcritic <> 0 then
    -- Envio centralizado de log de erro
    raise vr_exc_saida;
  end if;
  -- Verifica se a cooperativa esta cadastrada
  open cr_crapcop(pr_cdcooper);
    fetch cr_crapcop into rw_crapcop;
    -- Verificar se existe informação, e gerar erro caso não exista
    if cr_crapcop%notfound then
      -- Fechar o cursor
      close cr_crapcop;
      -- Gerar exceção
      vr_cdcritic := 651;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      raise vr_exc_saida;
    end if;
  close cr_crapcop;
  -- Buscar a data do movimento
  open btch0001.cr_crapdat(pr_cdcooper);
    fetch btch0001.cr_crapdat into rw_crapdat;
    -- Verificar se existe informação, e gerar erro caso não exista
    if btch0001.cr_crapdat%notfound then
      -- Fechar o cursor
      close btch0001.cr_crapdat;
      -- Gerar exceção
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      raise vr_exc_saida;
    end if;
  close btch0001.cr_crapdat;

  -- Calcular datas (o período utilizado é o mês anterior à data de movimento)
  vr_dtlimsup := rw_crapdat.dtultdma;
  vr_dtliminf := trunc(vr_dtlimsup, 'mm');
  -- Carregar PL/Table com descrição dos históricos
  for rw_craphis in cr_craphis (pr_cdcooper) loop
    vr_craphis(rw_craphis.cdhistor).dshistor := rw_craphis.dshistor;
  end loop;
  -- Incluir a descrição dos históricos não cadastrados
  vr_craphis(9993).dshistor := 'TITULOS DESCONTADOS';
  vr_craphis(9994).dshistor := 'JUROS DE TITULOS DESCONTADOS';
  vr_craphis(9995).dshistor := 'AUTENTICACOES EFETUADAS';
  vr_craphis(9996).dshistor := 'CHEQUES DESCONTADOS';
  vr_craphis(9997).dshistor := 'CUSTODIA DE CHEQUES';
  vr_craphis(9998).dshistor := 'JUROS DE CHEQUES DESCONTADOS';
  vr_craphis(9999).dshistor := 'TITULOS ACOLHIDOS';
  -- Carregar PL/Table com nome das agências
  for rw_crapage in cr_crapage (pr_cdcooper) loop
    vr_crapage(rw_crapage.cdagenci).nmresage := rw_crapage.nmresage;
  end loop;
  -- Incluir a agência totalizadora
  vr_crapage(99999).nmresage := 'TOTAL GERAL';
  -- Leitura dos cursores e carga da PL/Table
  -- Cadastro dos lancamentos de aplicacoes RDCA.
  for rw_lanctos in cr_craplap (pr_cdcooper,
                                vr_dtliminf,
                                vr_dtlimsup) loop
    pc_insere_pltable(rw_lanctos.cdagenci,
                      rw_lanctos.cdhistor,
                      rw_lanctos.qtlancto);
  end loop;
	-- Lançamentos dos produtos de captação
	FOR rw_lanctos IN cr_craplac(pr_cdcooper,
															 vr_dtliminf,
															 vr_dtlimsup) LOOP
															 
	  pc_insere_pltable(rw_lanctos.cdagenci,
                      rw_lanctos.cdhistor,
                      rw_lanctos.qtlancto);
																
  END LOOP;															
  -- Lancamentos Automaticos
  for rw_lanctos in cr_craplau (pr_cdcooper,
                                vr_dtliminf,
                                vr_dtlimsup) loop
    pc_insere_pltable(rw_lanctos.cdagenci,
                      rw_lanctos.cdhistor,
                      rw_lanctos.qtlancto);
  end loop;
  -- Lancamentos de tarifas
  for rw_lanctos in cr_craplat (pr_cdcooper,
                                vr_dtliminf,
                                vr_dtlimsup) loop
    pc_insere_pltable(rw_lanctos.cdagenci,
                      rw_lanctos.cdhistor,
                      rw_lanctos.qtlancto);
  end loop;
  -- Lancamentos de cobranca.
  for rw_lanctos in cr_craplcb (pr_cdcooper,
                                vr_dtliminf,
                                vr_dtlimsup) loop
    pc_insere_pltable(rw_lanctos.cdagenci,
                      rw_lanctos.cdhistor,
                      rw_lanctos.qtlancto);
  end loop;
  -- Lancamentos da conta investimento
  for rw_lanctos in cr_craplci (pr_cdcooper,
                                vr_dtliminf,
                                vr_dtlimsup) loop
    pc_insere_pltable(rw_lanctos.cdagenci,
                      rw_lanctos.cdhistor,
                      rw_lanctos.qtlancto);
  end loop;
  -- Lancamentos em depositos a vista
  for rw_lanctos in cr_craplcm (pr_cdcooper,
                                vr_dtliminf,
                                vr_dtlimsup) loop
    pc_insere_pltable(rw_lanctos.cdagenci,
                      rw_lanctos.cdhistor,
                      rw_lanctos.qtlancto);
  end loop;
  -- Lancamentos de cotas/capital
  for rw_lanctos in cr_craplct (pr_cdcooper,
                                vr_dtliminf,
                                vr_dtlimsup) loop
    pc_insere_pltable(rw_lanctos.cdagenci,
                      rw_lanctos.cdhistor,
                      rw_lanctos.qtlancto);
  end loop;
  -- Lancamentos em emprestimos. (D-08)
  for rw_lanctos in cr_craplem (pr_cdcooper,
                                vr_dtliminf,
                                vr_dtlimsup) loop
    pc_insere_pltable(rw_lanctos.cdagenci,
                      rw_lanctos.cdhistor,
                      rw_lanctos.qtlancto);
  end loop;
  -- Cadastro de lancamentos de aplicacoes de poupanca programada.
  for rw_lanctos in cr_craplpp (pr_cdcooper,
                                vr_dtliminf,
                                vr_dtlimsup) loop
    pc_insere_pltable(rw_lanctos.cdagenci,
                      rw_lanctos.cdhistor,
                      rw_lanctos.qtlancto);
  end loop;
  -- Log das transacoes efetuadas nos caixas e cash dispensers
  for rw_lanctos in cr_crapltr (pr_cdcooper,
                                vr_dtliminf,
                                vr_dtlimsup) loop
    pc_insere_pltable(rw_lanctos.cdagenci,
                      rw_lanctos.cdhistor,
                      rw_lanctos.qtlancto);
  end loop;
  -- Tabela de Autenticacoes
  for rw_lanctos in cr_crapaut (pr_cdcooper,
                                vr_dtliminf,
                                vr_dtlimsup) loop
    pc_insere_pltable(rw_lanctos.cdagenci,
                      rw_lanctos.cdhistor,
                      rw_lanctos.qtlancto);
  end loop;
  -- Lancamentos extra-sistema que compoem o boletim de caixa.
  for rw_lanctos in cr_craplcx (pr_cdcooper,
                                vr_dtliminf,
                                vr_dtlimsup) loop
    pc_insere_pltable(rw_lanctos.cdagenci,
                      rw_lanctos.cdhistor,
                      rw_lanctos.qtlancto);
  end loop;
  -- Lancamentos de faturas.
  for rw_lanctos in cr_craplft (pr_cdcooper,
                                vr_dtliminf,
                                vr_dtlimsup) loop
    pc_insere_pltable(rw_lanctos.cdagenci,
                      rw_lanctos.cdhistor,
                      rw_lanctos.qtlancto);
  end loop;
  -- Titulos acolhidos
  for rw_lanctos in cr_craptit (pr_cdcooper,
                                vr_dtliminf,
                                vr_dtlimsup) loop
    pc_insere_pltable(rw_lanctos.cdagenci,
                      rw_lanctos.cdhistor,
                      rw_lanctos.qtlancto);
  end loop;
  -- Movimentos Correspondente Bancario - Banco do Brasil
  for rw_lanctos in cr_crapcbb (pr_cdcooper,
                                vr_dtliminf,
                                vr_dtlimsup) loop
    pc_insere_pltable(rw_lanctos.cdagenci,
                      rw_lanctos.cdhistor,
                      rw_lanctos.qtlancto);
  end loop;
  -- Custodia de cheques
  for rw_lanctos in cr_crapcst (pr_cdcooper,
                                vr_dtliminf,
                                vr_dtlimsup) loop
    pc_insere_pltable(rw_lanctos.cdagenci,
                      rw_lanctos.cdhistor,
                      rw_lanctos.qtlancto);
  end loop;
  -- Cheques contidos do Bordero de desconto de cheques
  for rw_lanctos in cr_crapcdb (pr_cdcooper,
                                vr_dtliminf,
                                vr_dtlimsup) loop
    pc_insere_pltable(rw_lanctos.cdagenci,
                      rw_lanctos.cdhistor,
                      rw_lanctos.qtlancto);
  end loop;
  -- Lancamento de juros de desconto de cheques
  for rw_lanctos in cr_crapljd (pr_cdcooper,
                                vr_dtliminf,
                                vr_dtlimsup) loop
    pc_insere_pltable(rw_lanctos.cdagenci,
                      rw_lanctos.cdhistor,
                      rw_lanctos.qtlancto);
  end loop;
  -- Titulos contidos do Bordero de desconto de titulos
  for rw_lanctos in cr_craptdb (pr_cdcooper,
                                vr_dtliminf,
                                vr_dtlimsup) loop
    pc_insere_pltable(rw_lanctos.cdagenci,
                      rw_lanctos.cdhistor,
                      rw_lanctos.qtlancto);
  end loop;
  -- Lancamento de juros de desconto de titulos
  for rw_lanctos in cr_crapljt (pr_cdcooper,
                                vr_dtliminf,
                                vr_dtlimsup) loop
    pc_insere_pltable(rw_lanctos.cdagenci,
                      rw_lanctos.cdhistor,
                      rw_lanctos.qtlancto);
  end loop;
  -- Definição do diretório e nome do arquivo a ser gerado
  vr_nom_diretorio := gene0001.fn_diretorio('c',  -- /usr/coop/win12
                                            pr_cdcooper,
                                            'rl');
  vr_nom_arquivo := 'crrl379.lst';
  -- Leitura da PL/Table e geração do arquivo XML
  -- Inicializar o CLOB
  vr_des_xml := null;
  dbms_lob.createtemporary(vr_des_xml, true);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  -- Inicilizar as informações do XML
  vr_texto_completo := null;
  pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl379>');
  -- Leitura da PL/Table
  vr_ind_agencia := vr_agencia.first;
  while vr_ind_agencia is not null loop
    -- Inicia os dados da agência
    if vr_crapage.exists(vr_ind_agencia) then
      vr_nmresage := vr_crapage(vr_ind_agencia).nmresage;
    else
      vr_nmresage := lpad(vr_ind_agencia, 3, '0')||' - ***************';
    end if;
    pc_escreve_xml('<agencia nmresage="'||vr_nmresage||'">'||
                     '<dtrefere>'||gene0001.vr_vet_nmmesano(to_number(to_char(vr_dtliminf, 'mm')))||'/'||to_char(vr_dtliminf, 'yyyy')||'</dtrefere>');
    -- Leitura dos lançamentos da agência, por histórico
    vr_ind_histor := vr_agencia(vr_ind_agencia).vr_histor.first;
    while vr_ind_histor is not null loop
      if vr_craphis.exists(vr_ind_histor) then
        vr_dshistor := vr_craphis(vr_ind_histor).dshistor;
      else
        vr_dshistor := lpad(vr_ind_histor, 4, '0')||' - ';
      end if;
      pc_escreve_xml('<historico dshistor="'||vr_dshistor||'">'||
                       '<qtlancto>'||vr_agencia(vr_ind_agencia).vr_histor(vr_ind_histor).qtlancto||'</qtlancto>'||
                     '</historico>');
      vr_ind_histor := vr_agencia(vr_ind_agencia).vr_histor.next(vr_ind_histor);
    end loop;
    -- Fecha a agência
    pc_escreve_xml('</agencia>');
    vr_ind_agencia := vr_agencia.next(vr_ind_agencia);
  end loop;
  pc_escreve_xml('</crrl379>',
                 true);
  -- Buscar a lista de destinatários
  vr_destinatarios := gene0001.fn_param_sistema('CRED',
                                                pr_cdcooper,
                                                'CRRL379_EMAIL');
  -- A solicitação de relatório deve gerar o arquivo LST e copiá-lo para a pasta
  -- "converte", e deve enviar por e-mail para os destinatários parametrizados.
  gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                              pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                              pr_dtmvtolt  => rw_crapdat.dtmvtolt, --> Data do movimento atual
                              pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                              pr_dsxmlnode => '/crrl379/agencia/historico',      --> Nó base do XML para leitura dos dados
                              pr_dsjasper  => 'crrl379.jasper',    --> Arquivo de layout do iReport
                              pr_dsparams  => null,
                              pr_dsarqsaid => vr_nom_diretorio||'/'||vr_nom_arquivo, --> Arquivo final
                              pr_flg_gerar => 'N',
                              pr_qtcoluna  => 80,
                              pr_sqcabrel  => 1,                   --> Sequencia do relatorio (cabrel 1..5)
                              pr_flg_impri => 'N',                 --> Chamar a impressão (Imprim.p)
                              pr_nmformul  => '80d',            --> Nome do formulário para impressão
                              pr_nrcopias  => vr_nrcopias,         --> Número de cópias para impressão
                              pr_dspathcop => gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                                                    pr_cdcooper => pr_cdcooper,
                                                                    pr_nmsubdir => '/converte'),    --> Diretório a copiar o relatório
                              pr_dsextcop  => 'lst',               --> Extensão para cópia do relatório ao diretório
                              pr_fldosmail => 'S',                 --> Flag para converter o arquivo gerado em DOS antes do e-mail
                              pr_dsmailcop => vr_destinatarios,    --> Emails para envio do relatório
                              pr_dsassmail => 'RELACAO DE LANCAMENTOS GERADOS NO MES PELA '||rw_crapcop.nmrescop,    --> Assunto do e-mail que enviará o relatório
                              pr_dsextmail => 'lst',               --> Extensão para envio do relatório
                              pr_flgremarq => 'N',                 --> Flag para remover o arquivo após cópia/email
                              pr_des_erro  => vr_dscritic);        --> Saída com erro
  dbms_lob.close(vr_des_xml);
  dbms_lob.freetemporary(vr_des_xml);
  -- Testar se houve erro
  if vr_dscritic is not null then
    -- Gerar exceção
    vr_cdcritic := 0;
    raise vr_exc_saida;
  end if;
  -- Finaliza a execução com sucesso
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                            pr_cdprogra => vr_cdprogra,
                            pr_infimsol => pr_infimsol,
                            pr_stprogra => pr_stprogra);
  -- Grava a solicitação de relatório
  commit;
  
exception
  when vr_exc_fimprg then
    -- Se foi retornado apenas código
    if vr_cdcritic > 0 and vr_dscritic is null then
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    end if;
    -- Se foi gerada critica para envio ao log
    if vr_cdcritic > 0 or vr_dscritic is not null then
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
    end if;
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit pois gravaremos o que foi processo até então
    COMMIT;
    --ROLLBACK;
    
  when vr_exc_saida then
    -- Se foi retornado apenas código
    if vr_cdcritic > 0 and vr_dscritic is null then
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    end if;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := nvl(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    rollback;
  when others then
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    rollback;
end;
/

